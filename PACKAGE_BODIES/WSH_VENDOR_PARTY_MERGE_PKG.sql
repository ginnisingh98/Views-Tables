--------------------------------------------------------
--  DDL for Package Body WSH_VENDOR_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_VENDOR_PARTY_MERGE_PKG" AS
/* $Header: WSHVMRGB.pls 120.21 2006/02/22 04:14:45 pkaliyam noship $ */
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_VENDOR_PARTY_MERGE_PKG';
--
TYPE g_LocChangeRec IS RECORD
      (
        location_id          NUMBER,
        old_loc_code         VARCHAR2(40),
        new_loc_code         VARCHAR2(40));
--
TYPE locChangeTab IS TABLE OF g_LocChangeRec INDEX BY BINARY_INTEGER;
g_LocChangeTab    locChangeTab;
--

--
--
--========================================================================
-- PROCEDURE :  InactivatePartySites
-- PARAMETERS:
--                 P_party_id              Merge from party ID
--                 P_party_site_id         Party Site ID
--                 p_process_locations     Determines whether Process_Locations()
--                                         API should be called or not.
--                 p_to_id                 Merge To Party ID
--                 p_to_vendor_id          Merge To Vendor ID
--                 X_return_status         Return status
--
-- COMMENT :
--           This is a private procedure that is used to inactivate
--           party sites for a given party ID.  For a given party ID,
--           it gets a list of party Sites and for each party site ID,
--           it looks for any delivery tied to that location.  If there
--           are no such deliveries, it calls HZ API to set the status
--           of that particular party Site to 'I'.
--
--           If parameter p_process_locations is TRUE, then it also calls
--           Process_Locations() to transfer the old SF location from the
--           old vendor to the new vendor.  Process_Locations() should be
--           called only when parameter p_party_site_id IS NOT NULL.
--
--========================================================================
PROCEDURE InactivatePartySites(p_party_id       IN NUMBER,
                               p_party_site_id  IN NUMBER DEFAULT NULL,
                               p_process_locations IN BOOLEAN DEFAULT FALSE,
                               p_to_id          IN NUMBER,
                               p_to_vendor_id   IN NUMBER,
                               x_return_status  OUT NOCOPY VARCHAR2)
IS
  --
  CURSOR get_party_site_csr(p_party_id NUMBER, p_site_id NUMBER) IS
  SELECT location_id,
         hps.party_site_id,
         hps.object_version_number
  FROM hz_party_sites hps,
       hz_party_site_uses hpsu
  WHERE  hps.party_id = p_party_id
  AND hps.party_site_id = hpsu.party_site_id
  AND hpsu.site_use_type = 'SUPPLIER_SHIP_FROM'
  AND hpsu.status = 'A'
  AND hps.party_site_id = NVL(p_site_id, hps.party_site_id);
  --
  l_module_name CONSTANT  VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'InactivatePartySites';
  l_debug_on BOOLEAN;
  --
  l_from_party_rec           hz_party_site_v2pub.party_site_rec_type;
  l_msg_data                 VARCHAR2(32767);
  l_num_warnings             NUMBER :=0;
  l_num_errors               NUMBER :=0;
  l_object_version_number    NUMBER;
  l_msg                      VARCHAR2(32767);
  l_query_count              NUMBER :=0;
  l_msg_count                NUMBER ;
  l_return_status            VARCHAR2(1);
  l_sql_code                 NUMBER;
  l_sql_err                  VARCHAR2(32767);
  --
BEGIN
  --{
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.push(l_module_name);
   WSH_DEBUG_SV.log(l_module_name, 'p_party_id', p_party_id);
   WSH_DEBUG_SV.log(l_module_name, 'p_party_site_id', p_party_site_id);
   WSH_DEBUG_SV.log(l_module_name, 'p_process_locations', p_process_locations);
   WSH_DEBUG_SV.log(l_module_name, 'p_to_id', p_to_id);
   WSH_DEBUG_SV.log(l_module_name, 'p_to_vendor_id', p_to_vendor_id);
  END IF;
  --
  FOR get_party_site_rec IN get_party_site_csr(p_party_id => p_party_id,
                                               p_site_id  => p_party_site_id)
  LOOP
   --{
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.logmsg(l_module_name, '----------------', WSH_DEBUG_SV.C_STMT_LEVEL);
    WSH_DEBUG_SV.log(l_module_name,'LOCATION_ID' , get_party_site_rec.location_id);
    WSH_DEBUG_SV.log(l_module_name,'PARTY_SITE_ID',  get_party_site_rec.party_site_id);
    WSH_DEBUG_SV.log(l_module_name,'OBJECT_VERSION_NUMBER', get_party_site_rec.object_version_number);
    --
   END IF;
   --
   -- Check if we have any deliveries tied to the
   -- SF location associated with the old party ID
   --
   BEGIN
    --
    -- R12 Perf Bug 4949639 : Replace WND with WDD
    -- since all we are checking for is existence of records
    -- with a particular SF location ID
    --
    SELECT 1
    INTO l_query_count
    FROM wsh_delivery_details wdd,
         wsh_locations wl
    WHERE wdd.ship_from_location_id = wl.wsh_location_id
    AND wl.source_location_id =  get_party_site_rec.location_id
    AND wdd.party_id = p_party_id
    AND rownum=1;
    --
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
     l_query_count := 0;
   END;
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'L_QUERY_COUNT', l_query_count);
   END IF;
   --
   IF l_query_count = 0 AND p_party_site_id IS NOT NULL THEN
    --{
    -- Make party site inactive.
    --
    l_from_party_rec.party_site_id  := get_party_site_rec.party_site_id ;
    l_object_version_number         :=  get_party_site_rec.object_version_number;
    l_from_party_rec.status         := 'I' ;
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_SITE_V2PUB.UPDATE_PARTY_SITE_USE',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    hz_party_site_v2pub.update_party_site
            (
              p_party_site_rec        => l_from_party_rec,
              p_object_version_number => l_object_version_number,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg
             );
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from HZ_PARTY_SITE_V2PUB.UPDATE_PARTY_SITE is ' || l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call
            (
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors,
              p_msg_data      => l_msg
            );
    --
    IF p_process_locations THEN
     --{
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Process_Location API', WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_LOCATIONS_PKG.Process_Locations
            (
             p_location_type       => 'EXTERNAL',
             p_from_location       => get_party_site_rec.location_id,
             p_to_location         => get_party_site_rec.location_id,
             p_start_date          => NULL,
             p_end_date            => NULL,
             p_caller              => 'PO',
             x_return_status       => l_return_status,
             x_sqlcode             => l_sql_code,
             x_sqlerr              => l_sql_err
            );
     --
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'After Process_Location API', WSH_DEBUG_SV.C_PROC_LEVEL);
      WSH_DEBUG_SV.log(l_module_name, 'l_sql_code', l_sql_code);
      WSH_DEBUG_SV.log(l_module_name, 'l_sql_err', l_sql_err);
      WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
     END IF;
     --
     WSH_UTIL_CORE.api_post_call
            (
             p_return_status    => l_return_status,
             x_num_warnings     => l_num_warnings,
             x_num_errors       => l_num_errors
            );
     --}
    END IF;
    --}
   ELSIF l_query_count = 0 THEN
    --{
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Create_Site', WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    Create_Site
     (
       p_from_id         => p_party_id,
       p_to_id           => p_to_id,
       p_to_vendor_id    => p_to_vendor_id,
       p_delivery_id     => NULL,
       p_delivery_name   => NULL,
       p_location_id     => get_party_site_rec.location_id,
       x_return_Status   => l_return_status
     );
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'After calling create_Site', WSH_DEBUG_SV.C_PROC_LEVEL);
     WSH_DEBUG_SV.log(l_module_name, 'Return Status', l_return_status);
    END IF;
    --
    WSH_UTIL_CORE.api_post_call
            (
             p_return_status    => l_return_status,
             x_num_warnings     => l_num_warnings,
             x_num_errors       => l_num_errors
            );
    --}
   END IF;
   --}
  END LOOP;
  --
  IF l_num_errors > 0
  THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF l_num_warnings > 0
  THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSE
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
   WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --}
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   --
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.logmsg(l_module_name,'Error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    --
   END IF;
   --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
   --
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    --
   END IF;
   --
  WHEN OTHERS THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
   wsh_util_core.default_handler('WSH_VENDOR_PARTY_MERGE_PKG.InactivatePartySites');
   --
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.log(l_module_name,'Unexpected error has occured. Oracle error message is ', SUBSTRB(SQLERRM,1,200));
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    --
   END IF;
   --
END InactivatePartySites;


--
--
--========================================================================
-- PROCEDURE :  Create_Site
-- PARAMETERS:
--                 P_from_id              Merge from party ID
--                 P_to_id                Merge to party ID
--                 P_to_vendor_id         Merge to vendor ID
--                 P_delivery_id          Delivery ID
--                 P_delivery_name        Delivery Name
--                 P_location_id          SF Location ID
--                 X_return_status        Return status
--
-- COMMENT : This is a private procedure to create a new party site.
--           It also creates a corresponding party site use record and
--           calls Process_Locations() to update information in WSH
--           location tables.
--========================================================================
PROCEDURE Create_Site(
                     p_from_id            IN   NUMBER,
                     p_to_id              IN   NUMBER,
                     p_to_vendor_id       IN   NUMBER,
                     p_delivery_id        IN   NUMBER,
                     p_delivery_name      IN   VARCHAR2,
                     p_location_id        IN   NUMBER,
                     x_return_status      OUT  NOCOPY VARCHAR2
                     )
IS
  --
  l_module_name CONSTANT  VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_SITE';
  l_debug_on BOOLEAN;
  --
  CURSOR check_location_id IS
  SELECT 'x', hps.party_site_id
  FROM hz_party_sites hps,
       hz_party_site_uses hpsu
  WHERE hps.party_id = p_to_id
  AND hps.location_id = p_location_id
  AND hps.party_site_id = hpsu.party_site_id
  AND hpsu.site_use_type = 'SUPPLIER_SHIP_FROM';
  --
  CURSOR check_location_code IS
  SELECT substr(party_site_number, 1,
                instr(party_site_number, '|')-1) location_code,
         hps.party_site_id
  FROM hz_party_sites hps,
       hz_party_site_uses hpsu
  WHERE hps.location_id = p_location_id
  AND  hps.party_id = p_from_id
  AND hps.party_site_id = hpsu.party_site_id
  AND hpsu.site_use_type = 'SUPPLIER_SHIP_FROM';
  --
  l_partySiteId               NUMBER;
  l_location_code             VARCHAR2(40);
  l_new_location_code         VARCHAR2(40);
  l_from_party_site_id        NUMBER;
  --
  CURSOR chk_locn_csr (p_site_number IN VARCHAR2) IS
  SELECT 'x'
  FROM hz_party_sites hps,
       hz_party_site_uses hpsu
  WHERE hps.party_id = p_to_id
  AND hps.party_site_number = p_site_number
  AND hps.party_site_id = hpsu.party_site_id
  AND hpsu.site_use_type = 'SUPPLIER_SHIP_FROM';
  --
  l_dummy         VARCHAR2(1);
  --
        CURSOR Get_Contact_info ( p_party_id      NUMBER,
                                  p_party_site_id NUMBER ) IS
        SELECT contact_person.party_name shipper_name,
              phone_record.phone_number phone_number,
              email_record.email_address email_address
        FROM hz_party_sites    hps,
             hz_parties        contact_person,
             hz_org_contacts   supplier_contact,
             hz_contact_points phone_record,
             hz_contact_points email_record,
             hz_relationships  hrel
        WHERE hrel.subject_id = contact_person.party_id
             AND  hrel.subject_table_name = 'HZ_PARTIES'
             AND  hrel.subject_type = 'PERSON'
             AND  hrel.object_id = hps.party_id
             AND  hrel.object_table_name = 'HZ_PARTIES'
             AND  hrel.object_type = 'ORGANIZATION'
             AND  hrel.relationship_code = 'CONTACT_OF'
             AND  hrel.directional_flag = 'F'
             AND  supplier_contact.party_relationship_id =hrel.relationship_id
             AND  supplier_contact.party_site_id = hps.party_site_id
             AND  phone_record.owner_table_name(+) = 'HZ_PARTIES'
             AND  phone_record.owner_table_id(+) = hrel.party_id
             AND  phone_record.contact_point_type(+) = 'PHONE'
             AND  email_record.owner_table_name = 'HZ_PARTIES'
             AND  email_record.owner_table_id = hrel.party_id
             AND  email_record.contact_point_type = 'EMAIL'
             AND  hps.party_site_id =p_party_site_id
             AND  hps.party_id  = p_party_id;
  --
  l_contact_rec  get_contact_info%ROWTYPE;
  --
  CURSOR get_supplier_name (p_vendor_id NUMBER) IS
  SELECT vendor_name
  FROM po_vendors
  WHERE vendor_id = p_vendor_id;
  --
  l_supplier_name varchar2(360);
  l_return_status            VARCHAR2(2);
  l_exception_id             NUMBER;
  l_msg                      VARCHAR2(32767);
  l_xc_msg_count             NUMBER;
  l_xc_msg_data              VARCHAR2(2000);
  l_site_number              VARCHAR2(40);
  l_to_party_site_id         NUMBER;
  l_loc_chg                  BOOLEAN;
  l_location_id              NUMBER;
  l_msg_data                 VARCHAR2(32767);
  l_num_warnings             NUMBER :=0;
  l_num_errors               NUMBER :=0;
  l_sql_code                 NUMBER;
  l_sql_err                  VARCHAR2(32767);
  l_party_site_use_id        NUMBER;
  l_LocationIdTbl            WSH_LOCATIONS_PKG.ID_Tbl_Type;
  l_count                    NUMBER;
  --
BEGIN
  --{
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
   --
   WSH_DEBUG_SV.push(l_module_name);
   WSH_DEBUG_SV.log(l_module_name,'P_FROM_ID', p_from_id );
   WSH_DEBUG_SV.log(l_module_name,'P_TO_ID', p_to_id );
   WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID', p_delivery_id );
   WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_NAME', p_delivery_name );
   WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID', p_location_id );
   --
  END IF;
  --
  l_dummy := NULL;
  OPEN check_location_id;
  FETCH check_location_id INTO  l_dummy, l_partySiteId;
  CLOSE check_location_id;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_dummy', l_dummy);
    WSH_DEBUG_SV.log(l_module_name, 'l_partySiteId', l_partySiteId);
  END IF;
  --
  IF  l_dummy IS NOT NULL THEN
   --{
   IF p_from_id <> p_to_id THEN
    --{
    IF l_debug_on THEN
     wsh_debug_sv.logmsg(l_module_name, 'Calling InactivatePartySites', WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    InactivatePartySites
     (
      p_party_id          => p_from_id,
      p_to_id             => p_to_id,
      p_party_site_id     => l_partySiteId,
      p_process_locations => TRUE,
      p_to_vendor_id      => p_to_vendor_id,
      x_return_status     => l_return_status
     );
    --
    IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'Return Status from inactivatePartySites', l_return_status);
    END IF;
    --
    WSH_UTIL_CORE.api_post_call
     (
       p_return_status    => l_return_status,
       x_num_warnings     => l_num_warnings,
       x_num_errors       => l_num_errors
     );
    --}
   END IF;
   --
   IF p_delivery_id IS NOT NULL THEN
    --{
    FOR i IN g_LocChangeTab.FIRST..g_LocChangeTab.LAST LOOP
     --{
     IF g_LocChangeTab(i).location_id = p_location_id THEN
      --{
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'Logging SF code change exception');
      END IF;
      --
      fnd_message.set_name ( 'WSH', 'WSH_IB_SF_LOCN_CODE_CHG');
      fnd_message.set_token( 'L_LOCATION_CODE' , g_LocChangeTab(i).old_loc_code);
      fnd_message.set_token( 'L_NEW_LOCATION_CODE', g_LocChangeTab(i).new_loc_code);
      fnd_message.set_token( 'DELIVERY_NAME' , p_delivery_name );
      l_msg := FND_MESSAGE.GET;
      WSH_UTIL_CORE.printMsg(l_msg);
      --
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_xc_util.log_exception (
                           p_api_version           => 1.0,
                           p_exception_name        => 'WSH_IB_SF_LOCN_CODE_CHG',
                           p_logging_entity        => 'SHIPPER',
                           p_logging_entity_id     => FND_GLOBAL.USER_ID,
                           x_return_status         => l_return_status,
                           x_exception_id          => l_exception_id,
                           x_msg_data              => l_xc_msg_data,
                           x_msg_count             => l_xc_msg_count,
                           p_message               => substrb ( l_msg, 1, 2000 ),
                           p_delivery_id           => p_delivery_id,
                           p_exception_location_id => p_location_id,
                           p_logged_at_location_id => p_location_id
                          );
      --
      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Return Status from WSH_XC_UTIL.LOG_EXCEPTION is ', l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
                        p_return_status    => l_return_status,
                        x_num_warnings     => l_num_warnings,
                        x_num_errors       => l_num_errors,
                        p_msg_data         => l_xc_msg_data
                        );
      --
      EXIT;
      --}
     END IF;
     --}
    END LOOP;
    --}
   END IF;
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN;
   --}
  END IF;
  --
  OPEN check_location_code ;
  FETCH check_location_code INTO l_location_code, l_from_party_site_id;
  CLOSE check_location_code;
  --
  IF l_debug_on THEN
   --
   WSH_DEBUG_SV.log(l_module_name,'cursor check_location_code : L_LOCATION_CODE', l_location_code);
   WSH_DEBUG_SV.log(l_module_name,'cursor check_location_code : L_FROM_PARTY_SITE_ID ', l_from_party_site_id);
   --
  END IF;
  --
  OPEN get_contact_info(p_party_id => p_from_id,
                        p_party_site_id => l_from_party_site_id );
  FETCH get_contact_info INTO l_contact_rec;
  CLOSE get_contact_info;
  --
  IF l_debug_on THEN
   --
   WSH_DEBUG_SV.log(l_module_name,'cursor get_contact_info : L_CONTACT_REC.SHIPPER_NAME', l_contact_rec.shipper_name);
   WSH_DEBUG_SV.log(l_module_name,'cursor get_contact_info : L_CONTACT_REC.PHONE_NUMBER', l_contact_rec.phone_number);
   WSH_DEBUG_SV.log(l_module_name,'cursor get_contact_info : L_CONTACT_REC.EMAIL_ADDRESS',l_contact_rec.email_address);
   --
  END IF;
  --
  l_site_number := l_location_code || '|' || p_to_id;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'L_SITE_NUMBER', l_site_number);
  END IF;
  --
  -- Check if we have an entry in hz_party_sites with the same
  -- party_site_number and merge TO vendor ID
  --
  l_dummy := NULL;
  OPEN chk_locn_csr( p_site_number => l_site_number );
  FETCH chk_locn_csr INTO l_dummy;
  CLOSE chk_locn_csr;
  --
  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'After chk_loc_csr, l_dummy', l_dummy);
  END IF;
  --
  IF l_dummy IS NOT NULL THEN
   --{
   IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'Looping to create unique SF', l_dummy);
   END IF;
   --
   l_loc_chg := TRUE;
   --
   FOR I in 1..999 LOOP
    --{
    l_dummy := null;
    l_new_location_code := l_location_code || '-VM'|| lpad(I, 3, '0');
    l_site_number := l_new_location_code || '|' || p_to_id;
    --
    OPEN chk_locn_csr(p_site_number => l_site_number);
    FETCH chk_locn_csr INTO l_dummy;
    CLOSE chk_locn_csr;
    --
    IF l_dummy IS NULL THEN
     --
     l_new_location_code := l_site_number;
     EXIT;
     --
    END IF;
    --}
   END LOOP;
   --
   IF l_new_location_code is null THEN
    --{
    OPEN get_supplier_name ( p_vendor_id => p_to_vendor_id ) ;
    FETCH get_supplier_name INTO l_supplier_name;
    CLOSE get_supplier_name;
    --
    fnd_message.set_name ( 'WSH', 'WSH_IB_SF_LOCN_CODE_CONFLICT' );
    fnd_message.set_token( 'LOC_CODE', l_location_code );
    fnd_message.set_token( 'SUPPLIER_NAME', l_supplier_name );
    l_msg := FND_MESSAGE.GET;
    wsh_util_core.printMsg( l_msg );
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
    --}
   END IF;
   --}
  ELSE
   l_new_location_code := l_site_number;
   l_loc_chg := FALSE;
  END IF;
  --
  IF l_debug_on THEN
   --{
   WSH_DEBUG_SV.log(l_module_name, 'l_new_location_code', l_new_location_code);
   WSH_DEBUG_SV.log(l_module_name, 'l_loc_chg', l_loc_chg);
   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SUPPLIER_PARTY.CREATE_HZ_PARTY_SITE',WSH_DEBUG_SV.C_PROC_LEVEL);
   --}
  END IF;
  --
  Wsh_supplier_party.create_hz_party_site(
                              P_party_id        => p_to_id,
                              P_location_id     => p_location_id,
                              P_location_code   => l_new_location_code,
                              x_party_site_id   => l_to_party_site_id,
                              x_return_status   => l_return_status
                             );
  --
  IF l_debug_on THEN
   --
   WSH_DEBUG_SV.log(l_module_name, 'x_party_site_id', l_to_party_site_id);
   WSH_DEBUG_SV.log(l_module_name,'Return Status from WSH_SUPPLIER_PARTY.CREATE_HZ_PARTY_SITE is', l_return_status);
   --
  END IF;
  --
  wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors
                  );
  --
  l_location_id := p_location_id;
  --
  -- Now create a party Site use record for the party site that we
  -- just created above.
  --
  WSH_SUPPLIER_PARTY.Create_HZ_Party_Site_uses
       (
        P_party_site_id     => l_to_party_site_id,
        P_site_use_type     => 'SUPPLIER_SHIP_FROM',
        x_party_site_use_id => l_party_site_use_id,
        x_return_status     => l_return_status
       );
  --
  IF l_debug_on THEN
   wsh_debug_sv.log(l_module_name, 'l_return_status', l_return_status);
   wsh_debug_sv.log(l_module_name, 'l_party_site_use_id', l_party_site_use_id);
  END IF;
  --
  wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors
                  );
  --
  l_LocationIdTbl.DELETE;
  l_LocationIdTbl(l_LocationIdTbl.COUNT+1) := l_location_id;
  --
  WSH_LOCATIONS_PKG.Insert_Location_Owners
      (
       pLocationIdTbl    => l_LocationIdTbl,
       p_location_source_code => 'HZ',
       x_return_status   => l_return_status
      );
  --
  wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors
                  );
  --
  -- Inactivate party site for the old vendor
  --
  IF l_debug_on THEN
    wsh_debug_sv.logmsg(l_module_name, 'Calling InactivatePartySites', WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  InactivatePartySites
      (
        p_party_id          => p_from_id,
        p_party_site_id     => l_from_party_site_id,
        p_process_locations => TRUE,
        p_to_id             => p_to_id,
        p_to_vendor_id      => p_to_vendor_id,
        x_return_status     => l_return_status
      );
  --
  IF l_debug_on THEN
   wsh_debug_sv.log(l_module_name, 'Return status from InactivatePartySite', l_return_status);
  END IF;
  --
  wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors
                  );
  --
  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'l_loc_chg', l_loc_chg);
  END IF;
  --
  IF  l_loc_chg AND p_delivery_id IS NOT NULL THEN
   --{
   -- Store this location ID in a global table, so for any other
   -- delivery with this ID we log an exception
   --
   l_count := g_LocChangeTab.COUNT + 1;
   g_LocChangeTab(l_count).location_id := p_location_id;
   g_LocChangeTab(l_count).old_loc_code := l_location_code;
   g_LocChangeTab(l_count).new_loc_code := l_new_location_code;
   --
   -- Log an exception against delivery, if the SF location changes
   --
   fnd_message.set_name ( 'WSH', 'WSH_IB_SF_LOCN_CODE_CHG' );
   fnd_message.set_token( 'L_LOCATION_CODE' , l_location_code  );
   fnd_message.set_token( 'L_NEW_LOCATION_CODE', l_new_location_code );
   fnd_message.set_token( 'DELIVERY_NAME' , p_delivery_name );
   l_msg := FND_MESSAGE.GET;
   WSH_UTIL_CORE.printMsg(l_msg);
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_xc_util.log_exception (
                           p_api_version           => 1.0,
                           p_exception_name        => 'WSH_IB_SF_LOCN_CODE_CHG',
                           p_logging_entity        => 'SHIPPER',
                           p_logging_entity_id     => FND_GLOBAL.USER_ID,
                           x_return_status         => l_return_status,
                           x_exception_id          => l_exception_id,
                           x_msg_data              => l_xc_msg_data,
                           x_msg_count             => l_xc_msg_count,
                           p_message               => substrb ( l_msg, 1, 2000 ),
                           p_delivery_id           => p_delivery_id,
                           p_exception_location_id => p_location_id,
                           p_logged_at_location_id => p_location_id
                          );
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Return Status from WSH_XC_UTIL.LOG_EXCEPTION is ', l_return_status);
   END IF;
   --
   wsh_util_core.api_post_call(
                        p_return_status    => l_return_status,
                        x_num_warnings     => l_num_warnings,
                        x_num_errors       => l_num_errors,
                        p_msg_data         => l_xc_msg_data
                        );

   --}
  END IF;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SUPPLIER_PARTY.PROCESS_HZ_CONTACT',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  Wsh_supplier_party.Process_HZ_contact(
                                    p_party_id      => p_to_id,
                                    p_party_site_id => l_to_party_site_id,
                                    p_person_name   => l_contact_rec.shipper_name,
                                    p_phone         => l_contact_rec.phone_number,
                                    p_email         => l_contact_rec.email_address,
                                    x_return_status => l_return_status
                                    );
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'Return Status from WSH_SUPPLIER_PARTY.PROCESS_HZ_CONTACT', l_return_status);
  END IF;
  --
  wsh_util_core.api_post_call(
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors
                  );
  --
  IF l_num_errors > 0 THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF l_num_warnings > 0 THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;
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
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
   END IF;
   --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
   END IF;
   --
  WHEN OTHERS THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
   wsh_util_core.default_handler('WSH_VENDOR_PARTY_MERGE_PKG.Create_Site');
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Unexpected error has occured. Oracle error message is ', SUBSTRB(SQLERRM,1,200));
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
  --}
END Create_Site;
--



--========================================================================
-- PROCEDURE :        Update_New_Delivery
-- PARAMETERS:
--              P_from_iD                   Merge from vendor ID
--              P_to_id                     Merge to vendor ID
--              P_to_party_id               Merge to party ID
--              P_from_party_id             Merge from party ID
--              P_delivery_id               Delivery ID
--              P_from_site_id              Merge from site ID
--              P_old_delivery_id           Previous delivery ID
--              P_temp_update_flag          Flag to update the temp table or not
--              P_location_id   Delivery    SF Location id
--
-- COMMENT : This is a private procedure to update the delivery records
--                     with new vendor_id for the vendor merge.
--========================================================================

PROCEDURE   Update_New_Delivery (
                        p_from_id           IN   NUMBER,
                        p_to_id             IN   NUMBER,
                        p_to_party_id       IN   NUMBER,
                        p_from_party_id     IN   NUMBER,
                        p_delivery_id       IN   NUMBER,
                        p_from_site_id      IN   NUMBER,
                        p_old_delivery_id   IN   NUMBER,
                        p_temp_update_flag  IN   VARCHAR2,
                        p_location_id       IN   NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2
                        ) IS
--
        l_module_name CONSTANT  VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_NEW_DELIVERY';
        l_debug_on          BOOLEAN;
--
        l_return_status     VARCHAR2(2);
        l_dlvy_name         VARCHAR2(30);
        l_location_id       NUMBER;
        l_msg_data          VARCHAR2(32767);
        l_num_warnings      NUMBER :=0;
        l_num_errors        NUMBER :=0;

--
BEGIN
--{
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        IF l_debug_on IS NULL THEN
        --{
                l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        --}
        END IF;

        --
        IF l_debug_on THEN
        --{
                WSH_DEBUG_SV.push(l_module_name);
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_ID', p_from_id );
                WSH_DEBUG_SV.log(l_module_name,'P_TO_ID', p_to_id );
                WSH_DEBUG_SV.log(l_module_name,'P_TO_PARTY_ID', p_to_party_id );
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_PARTY_ID', p_from_party_id );
                WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID', p_delivery_id );
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_SITE_ID', p_from_site_id );
                WSH_DEBUG_SV.log(l_module_name,'P_OLD_DELIVERY_ID', p_old_delivery_id );
                WSH_DEBUG_SV.log(l_module_name,'P_TEMP_UPDATE_FLAG', p_temp_update_flag );
                WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID', p_location_id );
        --}
        END IF;


        IF (p_delivery_id IS NOT NULl) THEN
        --{
                UPDATE wsh_new_deliveries
                SET vendor_id = p_to_id,
                    party_id = p_to_party_id,
                    last_update_date = sysdate,
                    last_updated_by = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                WHERE delivery_id = p_delivery_id
                RETURNING name INTO l_dlvy_name;
                IF l_debug_on THEN
                --{
                       WSH_DEBUG_SV.logmsg(l_module_name,'Updated wsh_new_deliveries. Number of Rows updated is ' || sql%rowcount, WSH_DEBUG_SV.C_STMT_LEVEL);
                --}
                END IF;

        ELSE

                UPDATE wsh_new_deliveries
                SET vendor_id = p_to_id,
                    party_id = p_to_party_id,
                    last_update_date = sysdate,
                    last_updated_by = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                WHERE delivery_id
                          IN  ( SELECT delivery_id
                                FROM wsh_delivery_assignments
                                WHERE delivery_detail_id
                                        IN  ( SELECT delivery_detail_id
                                              FROM wsh_delivery_details
                                              WHERE source_code = 'PO'
                                                   AND  vendor_id = p_from_id
                                                   AND  ship_from_site_id = p_from_site_id
                                                   AND  source_header_id
                                                         IN  (SELECT po_header_id
                                                              FROM po_headers_all
                                                              WHERE vendor_id = p_to_id
                                                             )
                                              )
                                )
                     AND vendor_id = p_from_id;
                  IF l_debug_on THEN
                  --{
                        WSH_DEBUG_SV.logmsg(l_module_name,'Updated wsh_new_deliveries. Number of Rows updated is ' || sql%rowcount, WSH_DEBUG_SV.C_STMT_LEVEL);
                  --}
                  END IF;
        --}
        END IF;


        IF (p_temp_update_flag = 'Y') THEN
        --{
                UPDATE wsh_wms_sync_tmp
                SET temp_col = 'Y',
                    parent_delivery_detail_id = p_delivery_id
                WHERE delivery_id = p_old_delivery_id
                    AND operation_type = 'VENDOR_MRG';
        ELSIF (p_temp_update_flag = 'N') THEN
                UPDATE wsh_wms_sync_tmp
                SET temp_col = 'Y'
                WHERE delivery_id = p_old_delivery_id
                    AND operation_type = 'VENDOR_MRG';
        --}
        END IF;

        IF l_debug_on THEN
        --{
                 WSH_DEBUG_SV.logmsg(l_module_name,'Updated wsh_wms_sync_tmp. Number of Rows updated is ' || sql%rowcount, WSH_DEBUG_SV.C_STMT_LEVEL);
        --}
        END IF;


        IF p_location_id IS NOT NULL THEN
        --{
                SELECT source_location_id INTO l_location_id
                FROM wsh_locations
                WHERE wsh_location_id = p_location_id;

                IF l_debug_on THEN
                --{
                      WSH_DEBUG_SV.log(l_module_name, 'l_location_id', l_location_id);
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_VENDOR_PARTY_MERGE_PKG.CREATE_SITE' || l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
                --}
                END IF;

                create_site (
                        p_from_id       =>p_from_party_id,
                        p_to_id         =>p_to_party_id,
                        p_to_vendor_id => p_to_id,
                        p_delivery_id   =>p_delivery_id,
                        P_delivery_name =>l_dlvy_name,
                        P_location_id   =>l_location_id,
                        x_return_status =>l_return_status
                        );
                wsh_util_core.api_post_call(
                        p_return_status    => l_return_status,
                        x_num_warnings     => l_num_warnings,
                        x_num_errors       => l_num_errors
                        );
                IF l_debug_on THEN
                --{
                      WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_VENDOR_PARTY_MERGE_PKG.CREATE_SITE is ' || l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
                --}
                END IF;
        --}
        END IF;

        IF l_num_errors > 0 THEN
        --{
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        ELSIF l_num_warnings > 0 THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        --}
        END IF;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   --
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.logmsg(l_module_name,'Error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    --
   END IF;
   --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
   --
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    --
   END IF;
   --
   WHEN OTHERS THEN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    wsh_util_core.default_handler('WSH_VENDOR_PARTY_MERGE_PKG.Update_New_Delivery');
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --

--}
END Update_New_Delivery;


--
--
--========================================================================
-- PROCEDURE :  Update_Non_PO_Entities
-- PARAMETERS:
--                     P_to_id               Merge to vendor ID
--                     P_from_id             Merge from vendor ID
--                     P_from_party_id       Merge from party ID
--                     P_to_party_id         Merge to party ID
--                     P_from_site_id        Merge from vendor site ID
--                     P_to_site_id          Merge to vendor site ID
--                     X_return_status       Return status
--                     p_site_merge          Site level Merge
--                     p_from_supplier_name  Merge from Supplier Name

-- COMMENT : This is a procedure to Update for entities which are
--           not dependent on the invoice/PO selection
--========================================================================
PROCEDURE Update_Non_PO_Entities(
                        p_to_id         IN NUMBER,
                        p_from_id       IN NUMBER,
                        p_from_party_id IN NUMBER,
                        p_to_party_id   IN NUMBER,
                        p_to_site_id    IN NUMBER,
                        p_from_site_id  IN NUMBER,
                        p_site_merge    IN BOOLEAN,
                        p_from_supplier_name IN VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2
                        ) IS

        l_return_status        VARCHAR2(1);
        l_debug_on             BOOLEAN;
        l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_NON_PO_ENTITIES';


        CURSOR check_calendar IS
        SELECT calendar_type,
                calendar_assignment_id,
                vendor_site_id,
                association_type,
                freight_code
        FROM wsh_calendar_assignments a
        WHERE vendor_id = p_from_id
            AND vendor_site_id IS NULL;

        CURSOR check_site_calendar IS
        SELECT a.calendar_type,
               a.calendar_assignment_id,
               a.vendor_site_id,
               a.association_type,
               a.freight_code,
               b.vendor_site_code,
               a.calendar_code
        FROM wsh_calendar_assignments a,
             po_vendor_sites_all b
        WHERE a.vendor_id = p_from_id
            AND a.vendor_site_id = p_from_site_id
            AND  b.vendor_site_id = a.vendor_site_id;

        CURSOR check_dup_assignment( p_vendor_id NUMBER,
                                     p_calendar_Type VARCHAR2,
                                     p_vendor_site_id NUMBER,
                                     p_association_type VARCHAR2,
                                     p_freight_code VARCHAR2 )
        IS
        SELECT 1
        FROM wsh_calendar_assignments
        WHERE vendor_id = p_vendor_id
            AND calendar_type=p_calendar_type
            AND nvl( vendor_site_id,-999999 ) = nvl( p_vendor_site_id,-999999 )
            AND association_type = p_association_type
            AND nvl( freight_code, '!!!' ) = nvl( p_freight_code, '!!!' );
       --
       l_dummy       NUMBER;
       --

        CURSOR get_party_site_csr(p_party_id NUMBER) IS
        SELECT location_id,
               hps.party_site_id,
               hps.object_version_number
        FROM hz_party_sites hps,
             hz_party_site_uses hpsu
        WHERE  hps.party_id = p_party_id
            AND hps.party_site_id = hpsu.party_site_id
            AND hpsu.site_use_type = 'SUPPLIER_SHIP_FROM'
            AND hpsu.status = 'A';


        l_from_party_rec           hz_party_site_v2pub.party_site_rec_type;
        l_msg_data                 VARCHAR2(32767);
        l_num_warnings             NUMBER :=0;
        l_num_errors               NUMBER :=0;
        l_object_version_number    NUMBER;
        l_msg                      VARCHAR2(32767);
        l_query_count              NUMBER :=0;
        l_msg_count                NUMBER ;
        --
        CURSOR c_VendorLvlCalAsg(p_vendorID NUMBER,
                                 p_assnType VARCHAR2,
                                 p_caltype  VARCHAR2) IS
        SELECT 1
        FROM wsh_calendar_assignments
        WHERE vendor_id = p_vendorID
        AND association_type = p_assnType
        AND calendar_type = p_calType
        AND vendor_site_id IS NULL;
        --
        v_VendorLvlCalAsg          NUMBER := 0;
        l_CalAsgInfo               WSH_CAL_ASG_PKG.CalAsgRecType;
        l_CalAsgId                 NUMBER;
        --
BEGIN


        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF l_debug_on IS NULL THEN
        --{
                l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        --}
        END IF;


        IF l_debug_on THEN
        --{
                WSH_DEBUG_SV.push(l_module_name);
                WSH_DEBUG_SV.log(l_module_name,'P_TO_ID',p_to_id);
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_ID',p_from_id);
                WSH_DEBUG_SV.log(l_module_name,'P_TO_PARTY_ID',p_to_party_id);
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_PARTY_ID',p_from_party_id);
                WSH_DEBUG_SV.log(l_module_name,'P_TO_SITE_ID',p_to_site_id);
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_SITE_ID',p_from_site_id);
                WSH_DEBUG_SV.log(l_module_name,'P_SITE_MERGE',p_site_merge);
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_SUPPLIER_NAME',p_from_supplier_name);
        --}
        END IF;

        -- Update WSH_CARRIERS with the merge to vendor/vendor site
        UPDATE  wsh_carriers
        SET supplier_id = p_to_id,
            supplier_site_id = p_to_site_id,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id
        WHERE supplier_id = p_from_id
        AND      supplier_site_id = p_from_site_id;
        --
        IF l_debug_on THEN
         --{
               WSH_DEBUG_SV.logmsg(l_module_name,'Updated wsh_carriers. Number of Rows updated is ' || sql%rowcount, WSH_DEBUG_SV.C_STMT_LEVEL);
         --}
        END IF;
        --
        -- Update WSH_CARRIER_SITES with the merge to vendor site
        --
        UPDATE wsh_carrier_sites
        SET supplier_site_id = p_to_site_id,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id
        WHERE  supplier_site_id = p_from_site_id;
        --
        IF l_debug_on THEN
         --{
               WSH_DEBUG_SV.logmsg(l_module_name,'Updated wsh_carrier_sites. Number of Rows updated is ' || sql%rowcount, WSH_DEBUG_SV.C_STMT_LEVEL);
         --}
        END IF;
        --
        WSH_PARTY_MERGE.Update_Entities_During_Merge
            (
              p_to_id              => p_to_id,
              p_from_id            => p_from_id,
              p_from_party_id      => p_from_party_id ,
              p_to_party_id        => p_to_party_id ,
              p_to_site_id         => p_to_site_id,
              p_from_site_id       => p_from_site_id,
              p_site_merge         => p_site_merge,
              p_from_supplier_name => p_from_supplier_name,
              x_return_status      => l_return_status
            );
        --
        wsh_util_core.api_post_call
            (
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors
            );
        --
        -- Now, update/delete vendor site level calendar assignments if any
        --
        FOR check_site_calendar_rec IN check_site_calendar
        LOOP
        --{
                IF l_debug_on THEN
                --{
                      WSH_DEBUG_SV.logmsg(l_module_name, '-----------------------', WSH_DEBUG_SV.C_STMT_LEVEL);
                      WSH_DEBUG_SV.logmsg(l_module_name,'CHECK_SITE_CALENDAR_REC.CALENDAR_TYPE = ' || check_site_calendar_rec.calendar_type, WSH_DEBUG_SV.C_STMT_LEVEL);
                      WSH_DEBUG_SV.logmsg(l_module_name,'CHECK_SITE_CALENDAR_REC.CALENDAR_ASSIGNMENT_ID = ' || check_site_calendar_rec.calendar_assignment_id, WSH_DEBUG_SV.C_STMT_LEVEL);
                      WSH_DEBUG_SV.logmsg(l_module_name,'CHECK_SITE_CALENDAR_REC.VENDOR_SITE_ID = ' || check_site_calendar_rec.vendor_site_id, WSH_DEBUG_SV.C_STMT_LEVEL);
                      WSH_DEBUG_SV.logmsg(l_module_name,'CHECK_SITE_CALENDAR_REC.ASSOCIATION_TYPE = ' || check_site_calendar_rec.association_type, WSH_DEBUG_SV.C_STMT_LEVEL);
                      WSH_DEBUG_SV.logmsg(l_module_name,'CHECK_SITE_CALENDAR_REC.FREIGHT_CODE = ' || check_site_calendar_rec.freight_code, WSH_DEBUG_SV.C_STMT_LEVEL);
                      WSH_DEBUG_SV.logmsg(l_module_name,'CHECK_SITE_CALENDAR_REC.VENDOR_SITE_CODE = ' || check_site_calendar_rec.vendor_site_code, WSH_DEBUG_SV.C_STMT_LEVEL);
                      WSH_DEBUG_SV.logmsg(l_module_name,'CHECK_SITE_CALENDAR_REC.calendar_CODE = ' || check_site_calendar_rec.calendar_code, WSH_DEBUG_SV.C_STMT_LEVEL);
                --}
                END IF;
                OPEN check_dup_assignment(  p_vendor_id => p_to_id,
                                            p_calendar_Type => check_site_calendar_rec.calendar_type,
                                            p_vendor_site_id=> p_to_site_id,
                                            p_association_type => check_site_calendar_rec.association_type ,
                                            p_freight_code=> check_site_calendar_rec.freight_code );
                FETCH check_dup_assignment INTO l_dummy;

                IF (check_dup_assignment%NOTFOUND) THEN
                 --{
                        -- Update vendor site level assignments
                        UPDATE wsh_calendar_assignments
                        SET vendor_id = p_to_id,
                            vendor_site_id = p_to_site_id,
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                        WHERE calendar_assignment_id = check_site_calendar_rec.calendar_assignment_id;
                        --
                        IF l_debug_on THEN
                         --{
                              WSH_DEBUG_SV.log(l_module_name, 'Calendar Assgn ID updated',
                                               check_site_calendar_rec.calendar_assignment_id);
                              WSH_DEBUG_SV.logmsg(l_module_name,'Updated wsh_calendar_assignments. Number of Rows updated is ' || sql%rowcount, WSH_DEBUG_SV.C_STMT_LEVEL);
                         --}
                        END IF;
                        --
                        -- Is there a vendor level calendar assignment ? If not, create one
                        -- otherwise, the above entry will never show up in the form
                        --
                        OPEN c_VendorLvlCalAsg(p_vendorID => p_to_id,
                                               p_assnType => 'VENDOR',
                                               p_calType  => check_site_calendar_rec.calendar_type);
                        FETCH c_VendorLvlCalAsg INTO v_VendorLvlCalAsg;
                        CLOSE c_VendorLvlCalAsg;
                        --
                        IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name, 'Vendor Lvl Cal. Asg Exists ? ', v_VendorLvlCalAsg);
                        END IF;
                        --
                        IF v_VendorLvlCalAsg = 0 THEN
                         --{
                         --
                         IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name, 'Creating vendor level Cal. Asg', p_to_id);
                         END IF;
                         --
                         l_CalAsgInfo.CALENDAR_CODE := check_site_calendar_rec.calendar_code;
                         l_CalAsgInfo.CALENDAR_TYPE := check_site_calendar_rec.calendar_type;
                         l_CalAsgInfo.ENABLED_FLAG := 'Y';
                         l_CalAsgInfo.ASSOCIATION_TYPE := 'VENDOR';
                         l_CalAsgInfo.VENDOR_ID := p_to_id;
                         --
                         WSH_CAL_ASG_PKG.Create_Cal_Asg
                         (
                           p_api_version_number      => 1.0,
                           p_cal_asg_info            => l_CalAsgInfo,
                           x_return_status           => l_return_status,
                           x_msg_count               => l_msg_count,
                           x_msg_data                => l_msg_data,
                           x_Calendar_Aassignment_Id => l_CalAsgId
                         );
                         --
                         IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name, 'Return status from CAL. API', l_return_status);
                          WSH_DEBUG_SV.log(l_module_name, 'Calendar Assgn ID', l_CalAsgId);
                         END IF;
                         --
                         wsh_util_core.api_post_call
                         (
                           p_return_status => l_return_status,
                           x_num_warnings  => l_num_warnings,
                           x_num_errors    => l_num_errors,
                           p_msg_data      => l_msg
                         );
                         --}
                        END IF;
                        --

                 --}
                ELSE
                 --{
                        DELETE wsh_calendar_assignments
                        WHERE calendar_assignment_id = check_site_calendar_rec.calendar_assignment_id;
                        IF l_debug_on THEN
                        --{
                              WSH_DEBUG_SV.log(l_module_name, 'Calendar Assgn ID deleted',
                                               check_site_calendar_rec.calendar_assignment_id);
                              WSH_DEBUG_SV.logmsg(l_module_name,'Deleted record(s) from wsh_calendar_assignments. Number of Rows deleted is ' || sql%rowcount, WSH_DEBUG_SV.C_STMT_LEVEL);
                        --}
                        END IF;

                        IF check_site_calendar_rec.freight_code IS NULL THEN
                        --{
                                fnd_message.set_name ( 'WSH', 'WSH_IB_DEL_SP_SITE_CAL_ASGN' );
                        ELSE
                                fnd_message.set_name ( 'WSH', 'WSH_IB_DEL_SP_SITE_FC_CAL_ASGN' );
                                fnd_message.set_token( 'FREIGHT_CODE' , check_site_calendar_rec.freight_code );
                        --}
                        END IF;
                        fnd_message.set_token( 'SUPPLIER_NAME' , p_from_supplier_name );
                        fnd_message.set_token( 'CAL_TYPE' , check_site_calendar_rec.calendar_type );
                        fnd_message.set_token( 'SITE_CODE' , check_site_calendar_rec.vendor_site_code );
                        l_msg := FND_MESSAGE.GET;
                        wsh_util_core.printMsg( l_msg );
                 --}
                END IF;--IF (check_dup_assignment%NOTFOUND)

                CLOSE check_dup_assignment;
        --}
        END LOOP;--   FOR check_site_calendar_rec IN check_site_calendar
        --
        -- Inactive the party_site
        --
        IF NOT p_site_merge THEN
         --{
         IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Calling InactivatePartySites', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         InactivatePartySites
            (
              p_party_id => p_from_party_id,
              p_to_id    => p_to_party_id,
              p_to_vendor_id  => p_to_id,
              x_return_status => l_return_status
            );
         --
         IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name, 'Return Status from InactivatePartySites', l_return_status);
         END IF;
         --
         wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors,
                p_msg_data      => l_msg
              );
         --}
        END IF;
        --
        IF l_num_errors > 0 THEN
        --{
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        ELSIF l_num_warnings > 0 THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        --}
        END IF;
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
   --
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.logmsg(l_module_name,'Error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    --
   END IF;
   --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
   --
   IF l_debug_on THEN
    --
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    --
   END IF;
   --
   WHEN OTHERS THEN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    wsh_util_core.default_handler('WSH_VENDOR_PARTY_MERGE_PKG.Update_Non_PO_Entities');
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Update_Non_PO_Entities;


--========================================================================
-- PROCEDURE :Vendor_Merge
-- PARAMETERS:
--              P_from_id             Merge from vendor ID
--              P_to_id               Merge to vendor ID
--              P_from_party_id       Merge from party ID
--              P_to_party_id         Merge to party ID
--              P_from_site_id        Merge from vendor site ID
--              P_to_site_id          Merge to vendor site ID
--              p_calling_mode        Either 'INVOICE' or 'PO'
--              x_return_status       Return status
--
-- COMMENT :
--           This is the core WSH Vendor merge routine that is called from
--           Vendor_Party_Merge() API.
--           This procedure can be divided into two portions, merge validation and merge.
--           In the first portion, it will determine if the vendor merge is allowed.
--           In the second portion, it will update all the affected tables if merge is allowed
--
--           Parameter p_calling_mode indicates what updates to perform.
--           'INVOICE' ==> Update only non-PO entities
--           'PO'      ==> Update PO related entities
--========================================================================
PROCEDURE Vendor_Merge (
                     p_from_id         IN   NUMBER,
                     p_to_id           IN   NUMBER,
                     p_from_party_id   IN   NUMBER,
                     p_to_party_id     IN   NUMBER,
                     p_from_site_id    IN   NUMBER,
                     p_to_site_id      IN   NUMBER,
                     p_calling_mode    IN   VARCHAR2,
                     x_return_status   OUT  NOCOPY VARCHAR2 ) IS
 --
 l_return_status        VARCHAR2(1);
 l_debug_on             BOOLEAN;
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VENDOR_MERGE';
 --
 CURSOR check_vendor_active (p_vendor_id NUMBER) IS
 SELECT end_date_active,
        vendor_name
 FROM po_vendors
 WHERE vendor_id = p_vendor_id;
 --
 l_end_date_active         DATE;
 l_supplier_name           VARCHAR2(360);
 --
 /*
  * R12 Perf Bug 4949639 : Do not need this cursor any more
  * since we rely on the parameter p_calling_mode
 CURSOR check_option IS
 SELECT process
 FROM  ap_duplicate_vendors_all
 WHERE vendor_id = p_to_id
 AND  vendor_site_id = p_to_site_id
 AND  duplicate_vendor_id = p_from_id
 AND  duplicate_vendor_site_id = p_from_site_id;
 */
 --
 l_option     VARCHAR2(25);
 --
 CURSOR check_po IS
 SELECT w.delivery_id,
        d.delivery_detail_id
 FROM po_headers_all p,
      wsh_delivery_details d,
      wsh_delivery_assignments w,
      Wsh_new_deliveries wnd
 WHERE p.vendor_id = p_to_id
 AND  d.source_code = 'PO'
 AND  p.po_header_id = d.source_header_id
 AND  p.vendor_site_id = p_to_site_id
 AND  d.vendor_id = p_from_id
 AND  d.ship_From_site_id=p_from_site_id
 AND  d.delivery_detail_id = w.delivery_detail_id
 AND  w.delivery_id = wnd.delivery_id(+)
 AND  nvl(w.type, 'S') IN ('S' ,'O');
 --
 l_delivery_list      wsh_util_core.id_tab_type;
 l_dd_list            wsh_util_core.id_tab_type;
 --

        CURSOR find_delivery IS
        SELECT distinct delivery_id
        FROM  wsh_wms_sync_tmp
        WHERE operation_type = 'VENDOR_MRG'
            AND  temp_col IS NULL
            AND  delivery_id IS NOT NULL;
        --
        TYPE l_dlvy_rec IS RECORD (delivery_id NUMBER);
        TYPE t_delivery_tbl IS TABLE OF  l_dlvy_rec INDEX BY BINARY_INTEGER;
        l_delivery_rec_tbl   t_delivery_tbl;
        l_delivery_rec l_dlvy_rec;
        --

        CURSOR check_duplicate_vendor(p_del_id NUMBER) IS
        SELECT 'Y' ,
               wnd.initial_pickup_location_id,
               wnd.status_code,
               wnd.routing_response_id,
               wnd.name,
               wnd.ultimate_dropoff_location_id
        FROM wsh_new_deliveries wnd,
             wsh_delivery_details wdd,
             wsh_delivery_assignments wda
        WHERE wnd.delivery_id = p_del_id
            AND wnd.delivery_id = wda.delivery_id
            AND wdd.delivery_detail_id = wda.delivery_detail_id
            AND wdd.ship_from_site_id <> p_from_site_id
            AND wdd.ship_from_site_id <> p_to_site_id
            AND wdd.vendor_id = p_from_id
            AND nvl(wda.type,'S') IN ('S' , 'O')
            AND NOT EXISTS (SELECT 1
                            FROM ap_duplicate_vendors_all
                            WHERE process_flag IN ('S', 'D')
                                AND process IN ('P','B')
                                AND duplicate_vendor_id = wdd.vendor_id
                                AND duplicate_vendor_site_id = wdd.ship_from_site_id
                                AND vendor_id = p_to_id
                            );
        --
        l_dup                  VARCHAR2(1) := 'N';
        l_location_id          NUMBER;
        l_dlvy_status_code     VARCHAR2(30);
        l_routing_response_id  NUMBER;
        l_dlvy_name            VARCHAR2(30);
        l_ult_dropoff_loc_id   NUMBER;
        --

        CURSOR check_temp (p_delivery_id NUMBER) IS
        SELECT parent_delivery_detail_id
        FROM wsh_wms_sync_tmp wwst,
             wsh_delivery_details wdd
        WHERE wwst.delivery_id = p_delivery_id
            AND wwst.temp_col IS NOT NULL
            AND operation_type = 'VENDOR_MRG'
            AND wdd.delivery_detail_id = wwst.delivery_detail_id
            AND wdd.vendor_id = p_to_id
            AND wwst.parent_delivery_detail_id IS NOT NULL;
        --
        l_temp                 NUMBER;
        --

        CURSOR check_detail(p_delivery_id NUMBER) IS
        SELECT delivery_detail_id
        FROM wsh_wms_sync_tmp
        WHERE  delivery_id = p_delivery_id
            AND operation_type = 'VENDOR_MRG'
            AND temp_col IS NULL;
       --
        l_delivery_detail_tbl    wsh_util_core.id_tab_type;
       --
        CURSOR dlvy_rr_csr(p_delivery_id NUMBER) IS
        SELECT wdd.delivery_detail_id,
               wdd.routing_req_id,
               wdd.vendor_id,
               wth.receipt_number rr_number,
               wth.revision_number,
               wnd.ultimate_dropoff_location_id,
               wnd.name
        FROM wsh_delivery_details wdd,
             wsh_delivery_assignments wda ,
             wsh_inbound_txn_history wth,
             wsh_new_deliveries wnd
        WHERE  wda.delivery_id = p_delivery_id
            AND nvl(wda.type,'S') IN ('S','O')
            AND wda.delivery_detail_Id = wdd.delivery_detail_id
            AND wdd.routing_req_id = wth.transaction_id
            AND wth.transaction_type='ROUTING_REQUEST'
            AND wdd.vendor_id <> wth.supplier_id
            AND wnd.delivery_id = wda.delivery_id
        ORDER BY routing_req_id;
        --
        TYPE l_delivery_rr_rec IS RECORD(
                                        delivery_detail_id NUMBER,
                                        routing_req_id     NUMBER,
                                        vendor_id          NUMBER,
                                        rr_number          VARCHAR2(40),
                                        revision_number    NUMBER,
                                        ult_dropoff_loc_id NUMBER,
                                        name               VARCHAR2(30)
                                        );
        TYPE  t_delivery_rr_type IS TABLE OF l_delivery_rr_rec INDEX BY BINARY_INTEGER;
        l_dlvy_rr_rec_tbl  t_delivery_rr_type;
        l_dlvy_rr_rec l_delivery_rr_rec;

        l_prev_old_rr_id          NUMBER;
        l_new_rr_id               NUMBER;
        l_new_rr_number           VARCHAR2(40);
        --

        CURSOR chk_rreq_csr(p_supplier_id NUMBER,
                            p_rr_number VARCHAR2) IS
        SELECT transaction_id,
               revision_number,
               parent_shipment_header_id
        FROM wsh_inbound_txn_history
        WHERE  supplier_id = p_supplier_id
            AND receipt_number = p_rr_number
            AND transaction_type='ROUTING_REQUEST'
        ORDER BY revision_number DESC;
        --
        l1_transaction_id            NUMBER;
        l1_revision_number           NUMBER;
        l1_parent_shipment_header_id NUMBER;
        --

        l_delivery_cache_tbl       wsh_util_core.id_tab_type;
        l_dlvy_rr_cache_tbl        wsh_util_core.id_tab_type;
        l_dlvy_rr_tbl              wsh_new_deliveries_pvt.Delivery_Attr_Tbl_Type;
        l_dlvy_tbl                 wsh_util_core.id_tab_type;
        l_chk_delivery_id          NUMBER :=0;
        l_prev_new_rr_id           NUMBER :=0;
        l_site_merge               BOOLEAN;
        l_new_delivery_id          NUMBER;
        j                          NUMBER := 0;
        i                          NUMBER;
        l_exception_id             NUMBER;
        l_msg                      VARCHAR2(32767);
        l_msg_count                NUMBER ;
        l_xc_msg_data              VARCHAR2(2000);
        l_num_warnings             NUMBER :=0;
        l_num_errors               NUMBER :=0;
        l_tmp_rr_number            VARCHAR2(40);
        l_txn_history_rec          wsh_inbound_txn_history_pkg.ib_txn_history_rec_type;
        l_cache_index              NUMBER;
        l_action_prms              WSH_DELIVERIES_GRP.action_parameters_rectype;
        l_delivery_out_rec         WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
        l_defaults_rec             WSH_DELIVERIES_GRP.default_parameters_rectype;
        l_msg_data                 VARCHAR2(32767);
        l_xc_msg_count             NUMBER;
        l_respIndex                NUMBER;
        l_numRowsUpdated           NUMBER;
        --
BEGIN
--{
       --
       SAVEPOINT WSH_Vendor_Merge;
       --
       l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       wsh_util_core.g_call_fte_load_tender_api := FALSE;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       IF l_debug_on IS NULL THEN
        --{
                l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        --}
       END IF;


       IF l_debug_on THEN
        --{
                WSH_DEBUG_SV.push(l_module_name);
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_ID',p_from_id);
                WSH_DEBUG_SV.log(l_module_name,'P_TO_ID',p_to_id);
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_PARTY_ID',p_from_party_id);
                WSH_DEBUG_SV.log(l_module_name,'P_TO_PARTY_ID',p_to_party_id);
                WSH_DEBUG_SV.log(l_module_name,'P_FROM_SITE_ID',p_from_site_id);
                WSH_DEBUG_SV.log(l_module_name,'P_TO_SITE_ID',p_to_site_id);
                WSH_DEBUG_SV.log(l_module_name,'P_CALLING_MODE', p_calling_mode);
        --}
       END IF;

       wsh_util_core.enable_concurrent_log_print ;

       -- find out if it is a vendor merge OR vendor site merge
       OPEN check_vendor_active(p_vendor_id => p_from_id);
       FETCH check_vendor_active INTO l_end_date_active, l_supplier_name;

       IF check_vendor_active%NOTFOUND THEN
        --{
                CLOSE check_vendor_active;
                IF l_debug_on THEN
                --{
                        WSH_DEBUG_SV.logmsg(l_module_name,'Error : No Record exists in PO_VENDOR for vendor id : ' || p_from_id, WSH_DEBUG_SV.C_STMT_LEVEL);
                --}
                END IF;
                fnd_message.set_name ( 'WSH', 'WSH_IB_VENDOR_NOT_EXISTS' );
                fnd_message.set_token( 'VENDOR_ID' , to_char(p_from_id) );
                l_msg := FND_MESSAGE.GET;
                wsh_util_core.printMsg( l_msg );
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                --
                IF l_debug_on THEN
                 WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
                RETURN;
        --}
       END IF;

       CLOSE check_vendor_active;

       IF nvl(l_end_date_active,sysdate+1) <= sysdate THEN
        --{
                l_site_merge := false;
       ELSE
                l_site_merge := true;
        --}
       END IF;

       IF l_debug_on THEN
        --{
                  WSH_DEBUG_SV.log(l_module_name,'End date for Vendor ID : ' || p_from_id || ' is ',l_end_date_active, WSH_DEBUG_SV.C_STMT_LEVEL);
                  WSH_DEBUG_SV.log(l_module_name,'L_SITE_MERGE =  ',l_site_merge, WSH_DEBUG_SV.C_STMT_LEVEL);
        --}
       END IF;

       -- Update for entities which are not dependent on the invoice/PO selection
       IF l_debug_on THEN
        --{
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_VENDOR_PARTY_MERGE_PKG.UPDATE_NON_PO_ENTITIES',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
       END IF;
       --
       -- Update non-PO entities irrespective of calling mode
       --
       Update_Non_PO_Entities(
                                p_to_id              => p_to_id,
                                p_from_id            => p_from_id,
                                p_from_party_id      => p_from_party_id ,
                                p_to_party_id        => p_to_party_id ,
                                p_to_site_id         => p_to_site_id,
                                p_from_site_id       => p_from_site_id,
                                p_site_merge         => l_site_merge,
                                p_from_supplier_name => l_supplier_name,
                                X_return_status      => l_return_status
                                );
       --
       wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_num_warnings,
                      x_num_errors    => l_num_errors
                      );
       --
       -- Update PO related entities only when the mode is PO
       --
       IF (p_calling_mode = 'PO') THEN
        --{
        -- Determine the invoice/PO selections
        --
        -- R12 Perf Bug 4949639 : Do not need this any more since we rely
        -- on the parameter p_calling_mode
        --
        --OPEN  check_option;
        --FETCH check_option INTO l_option;
        --CLOSE check_option;
        --
        --IF l_debug_on THEN
         --WSH_DEBUG_SV.logmsg(l_module_name,'l_OPTION = ' || l_option, WSH_DEBUG_SV.C_STMT_LEVEL);
        --END IF;
        --

        --IF (l_option= 'B' OR  l_option = 'P') THEN
        --{
                --Find out all delivery detail lines impacted by the site merge AND insert the records into a temp table
                OPEN  check_po;
                FETCH check_po BULK COLLECT INTO l_delivery_list, l_dd_list;
                CLOSE check_po;
                IF l_debug_on THEN
                --{
                      WSH_DEBUG_SV.logmsg(l_module_name,'Count of Rows fetched from Cursor CHECK_PO  = ' || l_delivery_list.count, WSH_DEBUG_SV.C_STMT_LEVEL);
                --}
                END IF;

                IF l_dd_list.COUNT > 0 THEN
                --{
                        FORALL j IN l_dd_list.FIRST..l_dd_list.LAST
                                INSERT INTO wsh_wms_sync_tmp
                                        ( delivery_detail_id,
                                          delivery_id,
                                          operation_type,
                                          creation_date )
                                VALUES (  l_dd_list(j),
                                          l_delivery_list(j),
                                          'VENDOR_MRG',
                                          sysdate );

                         IF l_debug_on THEN
                         --{
                                WSH_DEBUG_SV.logmsg(l_module_name,'Inserted records into wsh_wms_sync_tmp. Number of Rows inserted is ' || l_dd_list.count, WSH_DEBUG_SV.C_STMT_LEVEL);
                         --}
                         END IF;

                        --
                        FORALL j IN l_dd_list.FIRST..l_dd_list.LAST
                                UPDATE wsh_delivery_details
                                SET vendor_id = p_to_id,
                                    ship_from_site_id = p_to_site_id,
                                    party_id = p_to_party_id,
                                    last_update_date = sysdate,
                                    last_updated_by = fnd_global.user_id,
                                    last_update_login = fnd_global.login_id
                                WHERE delivery_detail_id = l_dd_list(j);
                        IF SQL%ROWCOUNT <> l_dd_list.count THEN
                        --{
                                IF l_debug_on THEN
                                 --{
                                 WSH_DEBUG_SV.log(l_module_name, 'Updated WDD records with vendor/vendor site', p_to_id || ' - ' || p_To_site_id);
                                 WSH_DEBUG_SV.logmsg( l_module_name,'Out of ' || l_dd_list.count || ' delivery details, only ' || sql%rowcount || ' were updated.', WSH_DEBUG_SV.C_STMT_LEVEL);
                                 --}
                                END IF;
                                fnd_message.set_name ( 'WSH', 'WSH_IB_DLY_DET_UPDT_MISMATCH' );
                                fnd_message.set_token( 'NUM_DETAILS_AFFECTED' , to_char(l_dd_list.count) );
                                fnd_message.set_token( 'NUM_DETAILS_UPDATED' , to_char(SQL%ROWCOUNT) );
                                l_msg := FND_MESSAGE.GET;
                                wsh_util_core.printMsg( l_msg );
                        --}
                        END IF;
                         IF l_debug_on THEN
                         --{
                                WSH_DEBUG_SV.logmsg(l_module_name,'Updated wsh_delivery_details. Number of Rows updated is ' || sql%rowcount, WSH_DEBUG_SV.C_STMT_LEVEL);
                         --}
                         END IF;

                --}
                END IF;--IF l_dd_list.COUNT > 0
                --
                IF p_from_id <> p_to_id THEN
                 --{
                 -- Determine how many deliveries that are impacted
                 --
                 OPEN find_delivery;
                 FETCH find_delivery BULK COLLECT INTO l_delivery_rec_tbl;
                 CLOSE find_delivery;
                 --}
                END IF;
                --
                IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Rows fetched from Cursor FIND_DELIVERY', l_delivery_rec_tbl.count);
                END IF;

                IF l_delivery_rec_tbl.COUNT > 0 THEN
                 --{
                 FOR k IN l_delivery_rec_tbl.FIRST..l_delivery_rec_tbl.LAST
                 LOOP
                 --{
                    --
                    IF l_debug_on THEN
                     wsh_debug_sv.logmsg(l_module_name, '**********************************', WSH_DEBUG_SV.C_STMT_LEVEL);
                     wsh_debug_sv.log(l_module_name, 'Processing delivery', l_delivery_rec_tbl(k).delivery_id);
                     wsh_debug_sv.logmsg(l_module_name, '**********************************', WSH_DEBUG_SV.C_STMT_LEVEL);
                    END IF;
                    --
                        l_delivery_rec := l_delivery_rec_tbl(k);
                        l_dup                  :=NULL;
                        l_location_id          :=NULL;
                        l_dlvy_status_code     :=NULL;
                        l_routing_response_id  :=NULL;
                        OPEN check_duplicate_vendor( p_del_id => l_delivery_rec.delivery_id );
                        FETCH check_duplicate_vendor INTO l_dup,
                                                          l_location_id,
                                                          l_dlvy_status_code,
                                                          l_routing_response_id,
                                                          l_dlvy_name,
                                                          l_ult_dropoff_loc_id;
                        CLOSE check_duplicate_vendor;
                        IF l_debug_on THEN
                        --{
                              WSH_DEBUG_SV.logmsg(l_module_name,'Cursor CHECK_DUPLICATE_VENDOR : L_DUP =' || l_dup, WSH_DEBUG_SV.C_STMT_LEVEL);
                              WSH_DEBUG_SV.logmsg(l_module_name,'Cursor CHECK_DUPLICATE_VENDOR : L_LOCATION_ID =' || l_location_id, WSH_DEBUG_SV.C_STMT_LEVEL);
                              WSH_DEBUG_SV.logmsg(l_module_name,'Cursor CHECK_DUPLICATE_VENDOR : L_DLVY_STATUS_CODE =' || l_dlvy_status_code, WSH_DEBUG_SV.C_STMT_LEVEL);
                              WSH_DEBUG_SV.logmsg(l_module_name,'Cursor CHECK_DUPLICATE_VENDOR : L_ROUTING_RESPONSE_ID =' || l_routing_response_id, WSH_DEBUG_SV.C_STMT_LEVEL);
                              WSH_DEBUG_SV.logmsg(l_module_name,'Cursor CHECK_DUPLICATE_VENDOR : L_DLVY_NAME =' || l_dlvy_name, WSH_DEBUG_SV.C_STMT_LEVEL);
                              WSH_DEBUG_SV.logmsg(l_module_name,'Cursor CHECK_DUPLICATE_VENDOR : L_ULT_DROPOFF_LOC_ID =' || l_ult_dropoff_loc_id, WSH_DEBUG_SV.C_STMT_LEVEL);
                        --}
                        END IF;


                        IF (l_dup = 'Y') THEN
                        --{
                                l_temp := NULL;
                                OPEN check_temp( p_delivery_id => l_delivery_rec.delivery_id );
                                FETCH check_temp INTO l_temp;
                                CLOSE check_temp;
                                IF l_debug_on THEN
                                --{
                                      WSH_DEBUG_SV.logmsg(l_module_name,'Cursor CHECK_TEMP : L_TEMP =' || l_temp, WSH_DEBUG_SV.C_STMT_LEVEL);
                                --}
                                END IF;

                                IF ( l_temp IS NULL ) THEN
                                --{
                                        -- Call Split_Delivery to split the delivery line

                                        OPEN check_detail ( l_delivery_rec.delivery_id );
                                        FETCH check_detail BULK COLLECT INTO l_delivery_detail_tbl;
                                        CLOSE check_detail;
                                        IF l_debug_on THEN
                                        --{
                                              WSH_DEBUG_SV.logmsg(l_module_name,'Count of Rows fetched from Cursor  CHECK_DETAIL = ' || l_delivery_detail_tbl.count, WSH_DEBUG_SV.C_STMT_LEVEL);
                                        --}
                                        END IF;

                                        IF l_debug_on THEN
                                        --{
                                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.SPLIT_INBOUND_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
                                        --}
                                        END IF;

                                        l_new_delivery_id := NULL;
                                        wsh_inbound_util_pkg.split_inbound_delivery(
                                                      p_delivery_detail_id_tbl => l_delivery_detail_tbl,
                                                      p_delivery_id            => l_delivery_rec.delivery_id,
                                                      x_delivery_id            => l_new_delivery_id,
                                                      x_return_status          => l_return_status,
                                                      p_caller                 => 'WSH_VENDOR_MERGE'
                                                      );
                                        IF l_debug_on THEN
                                        --{
                                          WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_INBOUND_UTIL_PKG.SPLIT_INBOUND_DELIVERY is ' || l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
                                          WSH_DEBUG_SV.log(l_module_name, 'New Delivery ID', l_new_delivery_id);
                                         --}
                                         END IF;

                                        wsh_util_core.api_post_call(
                                                      p_return_status => l_return_status,
                                                      x_num_warnings  => l_num_warnings,
                                                      x_num_errors    => l_num_errors
                                                      );

                                        l_chk_delivery_id := l_new_delivery_id;

                                        --Update WSH_NEW_DELIVERIES with the merge to vendor
                                        IF l_debug_on THEN
                                        --{
                                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_VENDOR_PARTY_MERGE_PKG.UPDATE_NEW_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
                                        --}
                                        END IF;

                                        Update_new_delivery(
                                                     p_from_id          => p_from_id,
                                                     p_to_id            => p_to_id,
                                                     p_to_party_id      => p_to_party_id,
                                                     p_from_party_id    => p_from_party_id,
                                                     p_delivery_id      => l_new_delivery_id,
                                                     p_from_site_id     => p_from_site_id,
                                                     p_old_delivery_id  => l_delivery_rec.delivery_id,
                                                     p_temp_update_flag => 'Y',
                                                     p_location_id      => l_location_id,
                                                     x_return_status    => l_return_status
                                                     );
                                        IF l_debug_on THEN
                                        --{
                                                 WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_VENDOR_PARTY_MERGE_PKG.UPDATE_NEW_DELIVERY is ' || l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
                                         --}
                                         END IF;

                                        wsh_util_core.api_post_call(
                                                     p_return_status => l_return_status,
                                                     x_num_warnings  => l_num_warnings,
                                                     x_num_errors    => l_num_errors
                                                     );

                                        l_delivery_cache_tbl(l_new_delivery_id):= l_new_delivery_id;
                                        l_delivery_cache_tbl(l_delivery_rec.delivery_id) := l_delivery_rec.delivery_id;

                                        IF l_dlvy_status_code ='OP' AND l_routing_response_id IS NOT NULL THEN
                                        --{
                                                l_dlvy_rr_cache_tbl(l_new_delivery_id) := l_new_delivery_id;
                                        --}
                                        END IF;
                                 --}
                                ELSE  --IF  ( l_temp is NULL )
                                 --{
                                        OPEN check_detail( l_delivery_rec.delivery_id );
                                        FETCH check_detail BULK COLLECT INTO l_delivery_detail_tbl;
                                        CLOSE check_detail;
                                        IF l_debug_on THEN
                                        --{
                                              WSH_DEBUG_SV.logmsg(l_module_name,'Count of Rows fetched from Cursor CHECK_DETAIL  = ' || l_delivery_detail_tbl.count, WSH_DEBUG_SV.C_STMT_LEVEL);
                                              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.SPLIT_INBOUND_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
                                        --}
                                        END IF;

                                        Wsh_inbound_util_pkg.split_inbound_delivery(
                                                      p_delivery_detail_id_tbl => l_delivery_detail_tbl,
                                                      p_delivery_id            => l_delivery_rec.delivery_id,
                                                      x_delivery_id            => l_temp,
                                                      x_return_status          => l_return_status,
                                                      p_caller                 => 'WSH_VENDOR_MERGE'
                                                      );
                                        IF l_debug_on THEN
                                        --{
                                                 WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_INBOUND_UTIL_PKG.SPLIT_INBOUND_DELIVERY is ' || l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
                                         --}
                                         END IF;

                                        wsh_util_core.api_post_call(
                                                        p_return_status => l_return_status,
                                                        x_num_warnings  => l_num_warnings,
                                                        x_num_errors    => l_num_errors
                                                        );

                                        l_chk_delivery_id := l_temp;
                                        l_delivery_cache_tbl(l_temp) := l_temp;
                                        l_delivery_cache_tbl(l_delivery_rec.delivery_id) := l_delivery_rec.delivery_id;

                                        IF l_dlvy_status_code ='OP' AND l_routing_response_id IS NOT NULL THEN
                                        --{
                                                l_dlvy_rr_cache_tbl(l_temp) := l_temp;
                                        --}
                                        END IF;

                                --}
                                END IF;
                         --}
                        ELSE --l_dup<>'Y'
                         --{
                         -- Need to select all delivery level attributes again
                         --
                         SELECT initial_pickup_location_id, routing_response_id,
                                 name, status_code
                         INTO l_location_id, l_routing_response_id, l_dlvy_name, l_dlvy_status_code
                         FROM wsh_new_deliveries
                         WHERE delivery_id = l_delivery_rec.delivery_id;
                         --
                         --Update WSH_NEW_DELIVERIES with the merge to vendor
                                IF l_debug_on THEN
                                --{
                                  --wsh_debug_sv.log(l_module_name, 'l_dup', l_dup);
                                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_VENDOR_PARTY_MERGE_PKG.UPDATE_NEW_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
                                --}
                                END IF;

                                Update_new_delivery(
                                        p_from_id        => p_from_id,
                                        p_to_id          => p_to_id,
                                        p_to_party_id    => p_to_party_id,
                                        p_from_party_id  => p_from_party_id,
                                        p_delivery_id    => l_delivery_rec.delivery_id,
                                        p_from_site_id   => p_from_site_id,
                                        p_old_delivery_id=> l_delivery_rec.delivery_id,
                                        p_temp_update_flag=> 'N',
                                        p_location_id    =>l_location_id,
                                        x_return_status  => l_return_status
                                        );
                                        IF l_debug_on THEN
                                        --{
                                                 WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_VENDOR_PARTY_MERGE_PKG.UPDATE_NEW_DELIVERY is ' || l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
                                         --}
                                         END IF;

                                wsh_util_core.api_post_call(
                                        p_return_status => l_return_status,
                                        x_num_warnings  => l_num_warnings,
                                        x_num_errors    => l_num_errors
                                        );
                                --
                                l_chk_delivery_id := l_delivery_rec.delivery_id;
                                --
                                IF  l_routing_response_id IS NOT NULL THEN
                                --{
                                        UPDATE wsh_inbound_txn_history
                                        SET  supplier_id = p_to_id,
                                             last_update_date = sysdate,
                                             last_updated_by = fnd_global.user_id,
                                             last_update_login = fnd_global.login_id
                                        WHERE transaction_type = 'ROUTING_RESPONSE'
                                            AND shipment_header_id = l_delivery_rec.delivery_id
                                            AND supplier_id = p_from_id;
                                       IF l_debug_on THEN
                                        --{
                                        WSH_DEBUG_SV.log(l_module_name, 'Updated ROUTING_RESP record for', l_delivery_rec.delivery_id);
                                        WSH_DEBUG_SV.logmsg(l_module_name,'Updated wsh_inbound_txn_history. Number of Rows updated is ' || sql%rowcount, WSH_DEBUG_SV.C_STMT_LEVEL);
                                        --}
                                       END IF;

                                --}
                                END IF;

                        --}
                        END IF;    -- if l_dup ='Y'
                        --
                        IF l_debug_on THEN
                         wsh_debug_sv.log(l_module_name, 'Updating vendor info. on containers assigned to delivery', l_chk_delivery_id);
                        END IF;
                        --
                        UPDATE wsh_delivery_details
                        SET  vendor_id = p_to_id,
                             party_id = p_to_party_id,
                             last_update_date = sysdate,
                             last_updated_by = fnd_global.user_id,
                             last_update_login = fnd_global.login_id
                        WHERE container_flag = 'Y'
                        AND vendor_id = p_from_id
                        AND delivery_detail_id
                        IN (
                            SELECT delivery_detail_id
                            FROM wsh_delivery_assignments
                            WHERE nvl(type,'S') in ('S','O')
                            AND delivery_id = l_chk_delivery_id
                           );
                        --
                        IF l_debug_on THEN
                         wsh_debug_sv.log(l_module_name, 'No. of container records updated', SQL%ROWCOUNT);
                        END IF;
                        --
                        OPEN dlvy_rr_csr(l_chk_delivery_id);
                        FETCH dlvy_rr_csr BULK COLLECT INTO l_dlvy_rr_rec_tbl;
                        CLOSE  dlvy_rr_csr;
                        --
                        IF l_debug_on THEN
                        --{
                              WSH_DEBUG_SV.logmsg(l_module_name,'Count of Rows fetched from Cursor  DLVY_RR_CSR = ' || l_dlvy_rr_rec_tbl.count, WSH_DEBUG_SV.C_STMT_LEVEL);
                        --}
                        END IF;

                        IF l_dlvy_rr_rec_tbl.COUNT > 0 THEN
                        --{
                        FOR l in l_dlvy_rr_rec_tbl.FIRST..l_dlvy_rr_rec_tbl.LAST
                        LOOP
                        --{
                                l_dlvy_rr_rec := l_dlvy_rr_rec_tbl(l);
                                IF l_prev_old_rr_id = l_dlvy_rr_rec.routing_req_id THEN
                                --{
                                        l_new_rr_id := l_prev_new_rr_id;
                                ELSE
                                        l_new_rr_id                  := NULL;
                                        l_new_rr_number              := NULL;
                                        l1_transaction_id            := NULL;
                                        l1_revision_number           := NULL;
                                        l1_parent_shipment_header_id := NULL;
                                        --
                                        OPEN chk_rreq_csr( p_supplier_id => l_dlvy_rr_rec.vendor_id,
                                                           p_rr_number => l_dlvy_rr_Rec.rr_number );
                                        FETCH chk_rreq_csr INTO l1_transaction_id,
                                                                l1_revision_number,
                                                                l1_parent_shipment_header_id;
                                        CLOSE chk_rreq_csr;
                                        IF l_debug_on THEN
                                        --{
                                              WSH_DEBUG_SV.logmsg(l_module_name,'Cursor CHK_RREQ_CSR : L1_TRANSACTION_ID =' || l1_transaction_id, WSH_DEBUG_SV.C_STMT_LEVEL);
                                              WSH_DEBUG_SV.logmsg(l_module_name,'Cursor CHK_RREQ_CSR : L1_REVISION_NUMBER =' || l1_revision_number, WSH_DEBUG_SV.C_STMT_LEVEL);
                                              WSH_DEBUG_SV.logmsg(l_module_name,'Cursor CHK_RREQ_CSR : L1_PARENT_SHIPMENT_HEADER_ID =' || l1_parent_shipment_header_id, WSH_DEBUG_SV.C_STMT_LEVEL);
                                        --}
                                        END IF;

                                        IF   l1_revision_number = l_dlvy_rr_rec.revision_number
                                             AND l1_parent_shipment_header_id = l_dlvy_rr_Rec.routing_req_id  Then
                                        --{
                                                l_new_rr_id := l1_transaction_id;
                                                l_new_rr_number := l_dlvy_rr_Rec.rr_number;
                                        ELSIF l1_revision_number IS NOT NULL THEN
                                         --{
                                                FOR I IN 1..999
                                                LOOP
                                                --{
                                                        l_tmp_rr_number   := l_dlvy_rr_rec.rr_number || '-VM'|| lpad(I,3,'0');

                                                        l1_transaction_id := NULL;
                                                        l1_revision_number:= NULL;
                                                        l1_parent_shipment_header_id := NULL;
                                                        --
                                                        OPEN chk_rreq_csr( p_supplier_id => l_dlvy_rr_rec.vendor_id,
                                                                           p_rr_number => l_tmp_rr_number );
                                                        FETCH chk_rreq_csr INTO l1_transaction_id,
                                                                                l1_revision_number,
                                                                                l1_parent_shipment_header_id;
                                                        CLOSE chk_rreq_csr;

                                                        IF l1_revision_number = l_dlvy_rr_rec.revision_number
                                                            AND l1_parent_shipment_header_id = l_dlvy_rr_Rec.routing_req_id  THEN
                                                        --{
                                                                l_new_rr_id := l1_transaction_id;
                                                                l_new_rr_number := l_tmp_rr_number;
                                                                EXIT;
                                                                --
                                                        ELSIF l1_revision_number IS NULL
                                                                AND   l1_parent_shipment_header_id IS NULL THEN
                                                                --
                                                                l_new_rr_number := l_tmp_rr_number;
                                                                EXIT;
                                                                --
                                                        --}
                                                        END IF;
                                                --}
                                                END LOOP;--FOR I IN 1..999

                                                IF  l_new_rr_id IS NULL AND l_new_rr_number IS NULL THEN
                                                --{
                                                        --
                                                        --
                                                        fnd_message.set_name ( 'WSH', 'WSH_IB_RR_NUMBER_CONFLICT' );
                                                        fnd_message.set_token( 'SUPPLIER_NAME', l_supplier_name);
                                                        l_msg := FND_MESSAGE.GET;
                                                        wsh_util_core.printMsg( l_msg );

                                                        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                                                        IF  NOT(wsh_util_core.g_call_fte_load_tender_api) THEN
                                                        --{
                                                                  wsh_util_core.Reset_stops_for_load_tender(
                                                                                 p_reset_flags=>true,
                                                                                 x_return_status=>l_return_status
                                                                                 );
                                                                  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                                                                  --{
                                                                           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                                                                  --}
                                                                  END IF;
                                                        --}
                                                        END IF;
                                                        --
                                                        IF l_debug_on THEN
                                                          WSH_DEBUG_SV.pop(l_module_name);
                                                        END IF;
                                                        --
                                                        RETURN;
                                                --}
                                                END IF;
                                         --}
                                        ELSE   --ELSIF l1_revision_number IS NOT NULL THEN

                                                l_new_rr_number := l_dlvy_rr_Rec.rr_number;

                                        --}
                                        END IF; --IF   l1_revision_number = l_dlvy_rr_rec.revision_number
                                                 --       AND l1_parent_shipment_header_id = l_dlvy_rr_Rec.routing_req_id


                                        IF l_new_rr_id IS NULL THEN
                                        --{
                                                IF l_debug_on THEN
                                                --{
                                                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.GET_TXN_HISTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
                                                --}
                                                END IF;
                                                WSH_INBOUND_TXN_HISTORY_PKG.get_txn_history(
                                                                  p_transaction_id => l_dlvy_rr_rec.routing_req_id,
                                                                  x_txn_history_rec => l_txn_history_rec,
                                                                  x_return_status => l_return_status
                                                                  );
                                                IF l_debug_on THEN
                                                --{
                                                         WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_INBOUND_TXN_HISTORY_PKG.GET_TXN_HISTORY is ' || l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
                                                --}
                                                END IF;
                                                wsh_util_core.api_post_call(
                                                                  p_return_status => l_return_status,
                                                                  x_num_warnings  => l_num_warnings,
                                                                  x_num_errors    => l_num_errors
                                                                  );
                                                --
                                                l_txn_history_Rec.receipt_number := l_new_rr_number;
                                                l_txn_history_Rec.parent_shipment_header_id := l_dlvy_rr_rec.routing_req_id;
                                                l_txn_history_rec.supplier_id := p_to_id;
                                                --
                                                IF l_debug_on THEN
                                                --{
                                                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.CREATE_TXN_HISTORY',WSH_DEBUG_SV.C_PROC_LEVEL);
                                                --}
                                                END IF;
                                                WSH_INBOUND_TXN_HISTORY_PKG.create_txn_history(
                                                                  p_txn_history_rec => l_txn_history_rec,
                                                                  x_txn_id => l_new_rr_id,
                                                                  x_return_status => l_return_status
                                                                  );
                                                IF l_debug_on THEN
                                                --
                                                  WSH_DEBUG_SV.log(l_module_name,'Return Status from WSH_INBOUND_TXN_HISTORY_PKG.CREATE_TXN_HISTORY is ' , l_return_status);
                                                  WSH_DEBUG_SV.log(l_module_name, 'New Txn ID', l_new_rr_id);

                                                 --
                                                 END IF;
                                                wsh_util_core.api_post_call(
                                                                  p_return_status => l_return_status,
                                                                  x_num_warnings  => l_num_warnings,
                                                                  x_num_errors    => l_num_errors
                                                                  );

                                                --
                                        --}
                                        END IF;--IF l_new_rr_id IS NULL
                                        --
                                        -- Log an exception against delivery, if the routing req number has changed
                                        --
                                        IF (l_new_rr_number <> l_dlvy_rr_rec.rr_number) THEN
                                         --{
                                         fnd_message.set_name ( 'WSH', 'WSH_IB_RR_NUMBER_CHG' );
                                         fnd_message.set_token('OLD_RR_NUMBER',to_char(l_dlvy_rr_rec.rr_number));
                                         fnd_message.set_token( 'NEW_RR_NUMBER', to_char( l_new_rr_number ) );
                                         fnd_message.set_token( 'DELIVERY_NAME', l_dlvy_rr_rec.name );
                                         l_msg := FND_MESSAGE.GET;
                                         --
                                         WSH_UTIL_CORE.printMsg(l_msg);
                                         --
                                         l_exception_id := NULL;
                                         --
                                         wsh_xc_util.log_exception (
                                                p_api_version       => 1.0,
                                                p_exception_name    => 'WSH_IB_RR_NUMBER_CHG',
                                                p_logging_entity    => 'SHIPPER',
                                                p_logging_entity_id => FND_GLOBAL.USER_ID,
                                                x_return_status     => l_return_status,
                                                x_exception_id      => l_exception_id,
                                                x_msg_data          => l_xc_msg_data,
                                                x_msg_count         => l_xc_msg_count,
                                                p_message           => substrb ( l_msg, 1, 2000 ),
                                                p_delivery_id       =>  l_chk_delivery_id,
                                                p_exception_location_id =>l_dlvy_rr_rec.ult_dropoff_loc_id,
                                                p_logged_at_location_id =>l_dlvy_rr_rec.ult_dropoff_loc_id
                                                );
                                         --
                                         IF l_debug_on THEN
                                          --
                                          WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_XC_UTIL.LOG_EXCEPTION is ' || l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
                                          --
                                         END IF;
                                         --
                                         wsh_util_core.api_post_call(
                                                p_return_status    => l_return_status,
                                                x_num_warnings     => l_num_warnings,
                                                x_num_errors       => l_num_errors,
                                                p_msg_data         => l_xc_msg_data
                                                );
                                         --}
                                        END IF;
                                --}
                                END IF;--IF l_prev_old_rr_id = l_dlvy_rr_rec.routing_req_id
                                --
                                IF l_debug_on THEN
                                 wsh_debug_sv.log(l_module_name, 'WDD ID to update', l_dlvy_rr_rec.delivery_detail_id);
                                 wsh_debug_sv.log(l_module_name, 'Routing Req ID to update with', l_new_rr_id);
                                END IF;
                                --
                                UPDATE wsh_delivery_details
                                SET routing_req_Id = l_new_rr_id,
                                    last_update_date = sysdate,
                                    last_updated_by = fnd_global.user_id,
                                    last_update_login = fnd_global.login_id
                                WHERE delivery_detail_id = l_dlvy_rr_rec.delivery_detail_id;
                                --
                               IF l_debug_on THEN
                               --{
                                   WSH_DEBUG_SV.logmsg(l_module_name,'Updated wsh_delivery_details. Number of Rows updated is ' || sql%rowcount, WSH_DEBUG_SV.C_STMT_LEVEL);
                              --}
                              END IF;

                                l_prev_old_rr_id := l_dlvy_rr_rec.routing_req_id;
                                l_prev_new_rr_id := l_new_rr_id;

                        --}
                        END LOOP;--FOR l_dlvy_rr_rec in l_dlvy_rr_rec_tbl.FIRST..l_dlvy_rr_rec_tbl.LAST
                        --}
                       END IF;
                 --}
                 END LOOP;--FOR l_delivery_rec IN l_delivery_rec_tbl.FIRST..l_delivery_rec_tbl.LAST LOOP
                 --}
                END IF; --IF l_delivery_rec_tbl.COUNT > 0
                --
                IF p_From_id <> p_to_id THEN
                 --{
                 -- Update WSH_INBOUND_TXN_HISTORY with the merge to vendor
                 --
                 UPDATE wsh_inbound_txn_history a
                 SET  supplier_id = p_to_id,
                     last_update_date = sysdate,
                     last_updated_by = fnd_global.user_id,
                     last_update_login = fnd_global.login_id
                 WHERE  supplier_id = p_from_id
                 AND transaction_type not in ('ROUTING_REQUEST','ROUTING_RESPONSE')
                 AND exists (SELECT shipment_header_id
                                FROM rcv_shipment_headers b
                                WHERE b.shipment_header_id = a.shipment_header_id
                                   AND b.vendor_id = p_to_id
                                );
                 --
                 l_numRowsUpdated := SQL%ROWCOUNT;
                 --
                 IF l_debug_on THEN
                   --{
                   WSH_DEBUG_SV.log(l_module_name, 'Updated ASN/RECEIPT records with vendor', p_to_id);
                   WSH_DEBUG_SV.logmsg(l_module_name,'Updated wsh_inbound_txn_history. Number of Rows updated is ' || l_numRowsUpdated, WSH_DEBUG_SV.C_STMT_LEVEL);
                   --}
                 END IF;
                 --}
                END IF;
                --
                -- Convert l_dlvy_rr_cache_tbl to a new contiguous table (l_dlvy_rr_tbl)
                -- call WSH_DELIVERIES_GRP.delivery_action passing l_dlvy_rr_tbl
                -- AND action_code = 'GENERATE-ROUTING-RESPONSE'.
                -- l_dlvy_rr_tbl.delete;
                l_cache_index := l_dlvy_rr_cache_tbl.FIRST ;
                WHILE l_cache_index IS NOT NULL
                LOOP
                --{
                    l_respIndex := l_dlvy_rr_tbl.COUNT+1;
                    l_dlvy_rr_tbl(l_respIndex).delivery_id :=  l_dlvy_rr_cache_tbl( l_cache_index );
                    --
                    SELECT organization_id
                    INTO l_dlvy_rr_tbl(l_respIndex).organization_id
                    FROM wsh_new_deliveries
                    WHERE delivery_id = l_dlvy_rr_tbl(l_respIndex).delivery_id;
                    --
                    l_cache_index := l_dlvy_rr_cache_tbl.Next( l_cache_index );
                --}
                END LOOP;
                --
                l_action_prms.action_code :=  'GENERATE-ROUTING-RESPONSE' ;
                l_action_prms.caller      :=  'WSH_PUB';
                --
                IF l_debug_on THEN
                --{
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERIES_GRP.DELIVERY_ACTION',WSH_DEBUG_SV.C_PROC_LEVEL);
                  WSH_DEBUG_SV.log(l_module_name, 'l_dlvy_rr_tbl.COUNT', l_dlvy_rr_tbl.COUNT);
                --}
                END IF;
                --
                IF l_dlvy_rr_tbl.COUNT > 0 THEN
                 --{
                 WSH_DELIVERIES_GRP.delivery_action(
                               p_api_version_number => 1.0,
                               p_init_msg_list      => FND_API.G_FALSE,
                               p_commit             => FND_API.G_FALSE,
                               p_action_prms        => l_action_prms,
                               p_rec_attr_tab       => l_dlvy_rr_tbl,
                               x_delivery_out_rec   => l_delivery_out_rec,
                               x_defaults_rec       => l_defaults_rec,
                               x_return_status      => l_return_status,
                               x_msg_count          => l_msg_count,
                               x_msg_data           => l_msg
                               );
                 IF l_debug_on THEN
                  --{
                         WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_DELIVERIES_GRP.DELIVERY_ACTION is ' || l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
                  --}
                 END IF;

                 wsh_util_core.api_post_call(
                                       p_return_status => l_return_status,
                                       x_num_warnings  => l_num_warnings,
                                       x_num_errors    => l_num_errors,
                                       p_msg_data      => l_msg
                                       );
                 --}
                END IF;

                 --
                 --Convert l_dlvy_cache_tbl  into a contiguous table l_dlvy_tbl
                 --            AND call WSH_WV_UTILS.delivery_weight_volume
                 --l_dlvy_tbl.delete;
                 l_cache_index := l_delivery_cache_tbl.FIRST ;
                 WHILE l_cache_index IS NOT NULL
                 LOOP
                --{
                        l_dlvy_tbl( l_dlvy_tbl.count + 1 ) :=  l_delivery_cache_tbl( l_cache_index );
                        l_cache_index := l_delivery_cache_tbl.Next( l_cache_index );
                --}
                END LOOP;

                IF l_debug_on THEN
                --{
                   WSH_DEBUG_SV.logmsg( l_module_name,'Calling program unit WSH_WV_UTILS.DELIVERY_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL );
                   WSH_DEBUG_SV.log(l_module_name, 'l_dlvy_tbl.COUNT', l_dlvy_tbl.COUNT);
                   FOR i IN 1..l_dlvy_tbl.COUNT LOOP
                    wsh_debug_sv.log(l_module_name, 'l_dlvy_tbl(i)', l_dlvy_tbl(i));
                   END LOOP;
                   --
                --}
                END IF;
                --
                IF l_dlvy_tbl.COUNT > 0 THEN
                 --{
                 WSH_WV_UTILS.delivery_weight_volume(
                                        p_del_rows           => l_dlvy_tbl,
                                        p_update_flag       => 'Y',
                                        p_calc_wv_if_frozen  => 'N',
                                        x_return_status     => l_return_status
                                        );
                 IF l_debug_on THEN
                  --{
                         WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_WV_UTILS.DELIVERY_WEIGHT_VOLUME is ' || l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
                  --}
                 END IF;

                 wsh_util_core.api_post_call(
                                       p_return_status => l_return_status,
                                       x_num_warnings  => l_num_warnings,
                                       x_num_errors    => l_num_errors
                                       );
                 --}
                END IF;

                /*
                FORALL I IN l_dlvy_tbl.first..l_dlvy_tbl.last
                UPDATE wsh_delivery_legs
                SET   reprice_required = 'Y',
                        last_update_date = sysdate,
                        last_updated_by = fnd_global.user_id,
                        last_update_login = fnd_global.login_id
                WHERE delivery_id = l_dlvy_tbl(i);

        ELSIF (l_option = 'B' or l_option = 'I') THEN

                --Update FTE_INVOICE_HEADERS with the merge to vendor/vendor site
                UPDATE  fte_invoice_headers a
                SET  supplier_id = p_to_id,
                        supplier_site_id = p_to_site_id,
                        last_update_date = sysdate,
                        last_updated_by = fnd_global.user_id,
                        last_update_login = fnd_global.login_id
                WHERE    supplier_id = p_from_id
                        AND supplier_site_id = p_from_site_id
                        AND exists (SELECT 1
                                        FROM  ap_invoices_all
                                        WHERE    vendor_id = p_to_id
                                                AND vendor_site_id = p_to_site_id
                                                AND invoice_num = a.bill_number
                                        );  */

        --}
       -- END IF; --IF (l_option= 'B' OR  l_option = 'P')

         --
         IF  NOT(wsh_util_core.g_call_fte_load_tender_api) THEN
         --{
                  wsh_util_core.Process_stops_for_load_tender(
                                         p_reset_flags=>true,
                                         x_return_status=>l_return_status);
                  wsh_util_core.api_post_call(
                                 p_return_status => l_return_status,
                                 x_num_warnings  => l_num_warnings,
                                 x_num_errors    => l_num_errors
                                 );
        --}
        END IF;
        --}
       END IF;
       --
       IF l_num_errors > 0 THEN
        --{
           ROLLBACK TO WSH_Vendor_Merge;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       ELSIF l_num_warnings > 0 THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        --}
       END IF;
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Final return status', x_return_status);
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;

EXCEPTION
 --
 WHEN FND_API.G_EXC_ERROR THEN
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ROLLBACK TO WSH_Vendor_Merge;
  --
  IF l_debug_on THEN
   --
   WSH_DEBUG_SV.logmsg(l_module_name,'Error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_EXCEP_LEVEL);
   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
   --
  END IF;
  --
  IF  NOT(wsh_util_core.g_call_fte_load_tender_api) THEN
   --
   wsh_util_core.Reset_stops_for_load_tender(
                  p_reset_flags=>true,
                  x_return_status=>l_return_status);
   --
   IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   END IF;
   --
  END IF;
  --
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
  ROLLBACK TO WSH_Vendor_Merge;
  --
  IF l_debug_on THEN
   --
   WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
   --
  END IF;
  --
  IF  NOT(wsh_util_core.g_call_fte_load_tender_api) THEN
   --
   wsh_util_core.Reset_stops_for_load_tender(
                 p_reset_flags=>true,
                 x_return_status=>l_return_status);
   --
  END IF;
  --
 WHEN OTHERS THEN
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
  ROLLBACK TO WSH_Vendor_Merge;
  wsh_util_core.default_handler('WSH_VENDOR_PARTY_MERGE_PKG.Vendor_Merge');
  --
  IF l_debug_on THEN
   --
   WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   --
  END IF;
  --
  IF  NOT(wsh_util_core.g_call_fte_load_tender_api) THEN
   --
   wsh_util_core.Reset_stops_for_load_tender(
               p_reset_flags=>true,
               x_return_status=>l_return_status);
   --
  END IF;
  --
--}
END Vendor_Merge;




--========================================================================
-- PROCEDURE :Vendor_Party_Merge
-- PARAMETERS:
--              P_from_vendor_id               Merge from vendor ID
--              P_to_vendor_id                 Merge to vendor ID
--              P_from_party_id                Merge from party ID
--              P_to_party_id                  Merge to party ID
--              P_from_vendor_site_id          Merge from vendor site ID
--              P_to_vendor_site_id            Merge to vendor site ID
--              P_from_party_site_id           Merge from party site ID
--              P_to_party_site_id             Merge to party site ID
--              X_return_status                Return status
--
-- COMMENTS
--         This is the API that is called by APXINUPD.rdf.  This in turn
--         will call the core Vendor_Merge() procedure to
--         perform all the necessary updates to WSH data.
--
-- HISTORY
--         rlanka      7/27/2005     Created
--         rlanka      8/09/2005     Added new parameter p_calling_mode
--
--========================================================================

PROCEDURE Vendor_Party_Merge
             (
               p_from_vendor_id          IN         NUMBER,
               p_to_vendor_id            IN         NUMBER,
               p_from_party_id           IN         NUMBER,
               p_to_party_id             IN         NUMBER,
               p_from_vendor_site_id     IN         NUMBER,
               p_to_vendor_site_id       IN         NUMBER,
               p_from_party_site_id      IN         NUMBER,
               p_to_partysite_id         IN         NUMBER,
               p_calling_mode            IN         VARCHAR2,
               x_return_status           OUT NOCOPY VARCHAR2,
               x_msg_count               OUT NOCOPY NUMBER,
               x_msg_data                OUT NOCOPY VARCHAR2
             )
IS
  --
  l_return_status        VARCHAR2(1);
  l_debug_on             BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VENDOR_PARTY_MERGE';
  --
  l_fromPartyId          NUMBER;
  l_toPartyId            NUMBER;
  --
  -- Bug 4658824 : Use po_vendors, so we are isolated from any changes
  -- that AP makes to their data model
  CURSOR c_getParty(p_vendorId IN NUMBER) IS
  SELECT party_id
  FROM po_vendors
  WHERE vendor_id = p_vendorId;
  --
BEGIN
  --{
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
   --
   WSH_DEBUG_SV.push(l_module_name);
   WSH_DEBUG_SV.log(l_module_name,'P_FROM_VENDOR_ID', p_from_vendor_id);
   WSH_DEBUG_SV.log(l_module_name,'P_TO_VENDOR_ID', p_to_vendor_id);
   WSH_DEBUG_SV.log(l_module_name,'P_FROM_PARTY_ID', p_from_party_id);
   WSH_DEBUG_SV.log(l_module_name,'P_TO_PARTY_ID', p_to_party_id);
   WSH_DEBUG_SV.log(l_module_name,'P_FROM_VENDOR_SITE_ID', p_from_vendor_site_id);
   WSH_DEBUG_SV.log(l_module_name,'P_TO_VENDOR_SITE_ID', p_to_vendor_site_id);
   WSH_DEBUG_SV.log(l_module_name,'P_FROM_PARTY_SITE_ID', p_from_party_site_id);
   WSH_DEBUG_SV.log(l_module_name,'P_TO_PARTYSITE_ID', p_to_partysite_id);
   WSH_DEBUG_SV.log(l_module_name,'P_CALLING_MODE', p_calling_mode);
   --
  END IF;
  --
  -- Clear up global table of location IDs
  --
  g_LocChangeTab.DELETE;
  --
  -- Bug 4658824 : Now AP passes us the party ID, so we derive
  -- it only if the input parameter is NULL.
  --
  IF p_to_party_id IS NULL THEN
    --
    OPEN c_getParty(p_to_vendor_id);
    FETCH c_getParty INTO l_toPartyId;
    IF (c_getParty%NOTFOUND) THEN
      Null;
    END IF;
    CLOSE c_getParty;
    --
  END IF;
  --
  IF p_from_party_id IS NULL THEN
    --
    OPEN c_getParty(p_from_vendor_id);
    FETCH c_getParty INTO l_fromPartyId;
    IF (c_getParty%NOTFOUND) THEN
     Null;
    END IF;
    CLOSE c_getParty;
    --
  END IF;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name, 'l_fromPartyId', l_fromPartyId);
   WSH_DEBUG_SV.log(l_module_name, 'l_toPartyId', l_toPartyId);
  END IF;
  --
  -- Now call the core Vendor Merge routine to update WSH data
  --
  WSH_VENDOR_PARTY_MERGE_PKG.Vendor_Merge
    (
      p_from_id       => p_from_vendor_id,
      p_to_id         => P_to_vendor_id,
      p_from_party_id => NVL(p_from_party_id, l_fromPartyId),
      p_to_party_id   => NVL(p_to_party_id, l_toPartyId),
      p_from_site_id  => p_from_vendor_site_id,
      p_to_site_id    => p_to_vendor_site_id,
      p_calling_mode  => p_calling_mode,
      x_return_status => l_return_status
    );
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name, 'After calling core vendor_merge API', WSH_DEBUG_SV.C_STMT_LEVEL);
   WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
  END IF;
  --
  -- For AP, we interpret 'W' as 'S' status.
  --
  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  ELSE
   x_return_status := l_return_status;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get
    (
      p_count  => x_msg_count,
      p_data  =>  x_msg_data,
      p_encoded => FND_API.G_FALSE
    );
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --}
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
   END IF;
   --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
   END IF;
   --
  WHEN OTHERS THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
   WSH_UTIL_CORE.ADD_MESSAGE(l_return_status, l_module_name);
   WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_VENDOR_PARTY_MERGE_PKG.VENDOR_PARTY_MERGE',l_module_name);
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'Unexpected error', substrb(sqlerrm, 1, 200));
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
END Vendor_Party_Merge;


END WSH_VENDOR_PARTY_MERGE_PKG;

/
