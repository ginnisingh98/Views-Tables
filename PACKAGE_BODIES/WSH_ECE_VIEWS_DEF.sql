--------------------------------------------------------
--  DDL for Package Body WSH_ECE_VIEWS_DEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ECE_VIEWS_DEF" AS
/* $Header: WSHECVWB.pls 120.0.12010000.3 2009/11/24 11:44:57 brana ship $ */
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ECE_VIEWS_DEF';
--
--FP Bug 3989208
G_PAYMENT_TERM_TBL wsh_util_core.char500_tab_type;
G_PAYMENT_TERM_EXT_TBL wsh_util_core.char500_tab_type;
--
FUNCTION get_cont_area_code(contact_id_in NUMBER) return VARCHAR2 IS
cont_area_code_x VARCHAR2(10);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CONT_AREA_CODE';
--
BEGIN
  --Fix for Bug 2378628
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
      WSH_DEBUG_SV.log(l_module_name,'CONTACT_ID_IN',CONTACT_ID_IN);
  END IF;
  --
  SELECT  DISTINCT
    contact.PHONE_AREA_CODE   Area_Code,
    contact.PHONE_NUMBER    Phone_Number
  INTO
    cont_area_code_x,
                WSH_ECE_VIEWS_DEF.cont_phone_number_x
  FROM HZ_CONTACT_POINTS    contact,
       HZ_CUST_ACCOUNT_ROLES      acct_roles
        WHERE  acct_roles.CUST_ACCOUNT_ROLE_ID  = contact_id_in
           AND contact.OWNER_TABLE_NAME   = 'HZ_PARTIES'
           AND acct_roles.PARTY_ID              = contact.owner_table_id(+)
           AND contact.CONTACT_POINT_TYPE   IN ( 'PHONE', 'FAX', 'TELEX')
           AND contact.PHONE_LINE_TYPE    = 'GEN'
           AND contact.PRIMARY_FLAG   = 'Y';
  --End of Fix for Bug 2378628

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return cont_area_code_x;

EXCEPTION WHEN OTHERS THEN
    WSH_ECE_VIEWS_DEF.cont_phone_number_x := NULL;
    cont_area_code_x := NULL;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return cont_area_code_x;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END;

FUNCTION get_cont_phone_number RETURN VARCHAR2 IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CONT_PHONE_NUMBER';
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
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return WSH_ECE_VIEWS_DEF.cont_phone_number_x;
END;

FUNCTION get_cust_area_code(customer_id_in NUMBER) return VARCHAR2 IS
cust_area_code_x VARCHAR2(10);
--
CURSOR l_cust_ph_num_csr(p_customer_id IN NUMBER ) IS
SELECT DISTINCT
       contact.PHONE_AREA_CODE   Area_Code,
       contact.PHONE_NUMBER    Phone_Number,
       hcar.cust_acct_site_id  acct_site_id
FROM   HZ_CONTACT_POINTS        contact,
       HZ_CUST_ACCOUNT_ROLES  hcar
WHERE  hcar.CUST_ACCOUNT_ID    = p_customer_id
AND    contact.CONTACT_POINT_TYPE       = 'PHONE'
AND    contact.PRIMARY_FLAG             = 'Y'
AND    contact.OWNER_TABLE_NAME   = 'HZ_PARTIES'
AND    contact.OWNER_TABLE_ID     =  hcar.PARTY_ID
AND    contact.PHONE_LINE_TYPE    = 'GEN'
AND    hcar.status = 'A'
order  by nvl(hcar.cust_acct_site_id,-99999);

l_cust_acct_site_id NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CUST_AREA_CODE';
--
BEGIN
  --Fix for Bug 2378628
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
      WSH_DEBUG_SV.log(l_module_name,'CUSTOMER_ID_IN',CUSTOMER_ID_IN);
  END IF;
  --
  OPEN  l_cust_ph_num_csr(customer_id_in);
  FETCH l_cust_ph_num_csr INTO cust_area_code_x, WSH_ECE_VIEWS_DEF.cust_phone_number_x, l_cust_acct_site_id;
  CLOSE l_cust_ph_num_csr;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'cust_area_code_x',cust_area_code_x);
      WSH_DEBUG_SV.log(l_module_name,'phone_number',WSH_ECE_VIEWS_DEF.cust_phone_number_x);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return cust_area_code_x;

EXCEPTION WHEN OTHERS THEN
    WSH_ECE_VIEWS_DEF.cust_phone_number_x := NULL;
    cust_area_code_x := NULL;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return cust_area_code_x;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END;

FUNCTION get_cust_phone_number RETURN VARCHAR2 IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CUST_PHONE_NUMBER';
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
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return WSH_ECE_VIEWS_DEF.cust_phone_number_x;
END;


PROCEDURE get_invoice_number(p_delivery_id IN NUMBER,
                             x_invoice_number OUT NOCOPY  NUMBER) IS
l_lookup_code   Varchar2(30) := NULL;
cursor c_lookup_value is
       select lookup_code from oe_lookups where lookup_type
       = 'INVOICE_NUMBER_METHOD' and meaning = 'Delivery Name';
       --
l_debug_on BOOLEAN;
       --
       l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_INVOICE_NUMBER';
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
        x_invoice_number := NULL;
        open c_lookup_value;
        fetch c_lookup_value into l_lookup_code;
        close c_lookup_value;
        IF fnd_profile.value('WSH_INVOICE_NUMBERING_METHOD') = l_lookup_code THEN
           x_invoice_number := p_delivery_id;
        END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION WHEN OTHERS THEN
        x_invoice_number := NULL;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END;

PROCEDURE get_vehicle_type_code(
                   p_vehicle_org_id IN NUMBER,
                   p_vehicle_item_id IN NUMBER,
                   x_vehicle_type_code OUT NOCOPY  VARCHAR2 ) IS

CURSOR c_vehicle_item_type is
       SELECT item_type FROM mtl_system_items WHERE
       inventory_item_id = p_vehicle_item_id AND
       organization_id = p_vehicle_org_id AND
       vehicle_item_flag = 'Y' ;
       --
l_debug_on BOOLEAN;
       --
       l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_VEHICLE_TYPE_CODE';
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
            WSH_DEBUG_SV.log(l_module_name,'P_VEHICLE_ORG_ID',P_VEHICLE_ORG_ID);
            WSH_DEBUG_SV.log(l_module_name,'P_VEHICLE_ITEM_ID',P_VEHICLE_ITEM_ID);
        END IF;
        --
        IF p_vehicle_org_id is NULL or p_vehicle_item_id is NULL THEN
            x_vehicle_type_code :=  NULL;
        ELSE
           OPEN c_vehicle_item_type;
           FETCH c_vehicle_item_type into x_vehicle_type_code;
           IF (c_vehicle_item_type%NOTFOUND) THEN
                x_vehicle_type_code := NULL;
           END IF;
           CLOSE c_vehicle_item_type;
        END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION WHEN OTHERS THEN
        x_vehicle_type_code := NULL;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END get_vehicle_type_code;

FUNCTION get_cust_payment_term(p_payment_term_id NUMBER) return VARCHAR2 IS

l_payment_term_name    VARCHAR2(30) := NULL;
--Bug 3989208
l_return_status VARCHAR2(30);
--

CURSOR c_cust_payment_term is
       SELECT Name FROM ra_terms
       WHERE term_id = p_payment_term_id;
--
l_debug_on BOOLEAN;
       --
       l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CUST_PAYMENT_TERM';
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
            WSH_DEBUG_SV.log(l_module_name,'P_PAYMENT_TERM_ID',P_PAYMENT_TERM_ID);
        END IF;
        --
        IF p_payment_term_id is NULL THEN
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            return NULL;
        ELSE
            --Bug 3989208
            --Cache the payment_term_id and payment_term_name

            wsh_util_core.get_cached_value(
               p_cache_tbl => g_payment_term_tbl,
               p_cache_ext_tbl => g_payment_term_ext_tbl,
               p_value => l_payment_term_name,
               p_key => p_payment_term_id,
               p_action => 'GET',
               x_return_status => l_return_status);

            IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name, 'Cached l_payment_term_name', l_payment_term_name);
               wsh_debug_sv.log(l_module_name, 'Get l_return_status', l_return_status);
            END IF;

            IF l_return_status = wsh_util_core.g_ret_sts_warning
            THEN

                OPEN c_cust_payment_term;
                FETCH c_cust_payment_term into l_payment_term_name;
                IF (c_cust_payment_term%NOTFOUND) THEN
                  l_payment_term_name := NULL;
                END IF;
                 CLOSE c_cust_payment_term;

                IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name, 'New l_payment_term_name', l_payment_term_name);
                END IF;

                --Bug 3989208
                --Cache the payment_term_id and payment_term_name

                wsh_util_core.get_cached_value(
                  p_cache_tbl => g_payment_term_tbl,
                  p_cache_ext_tbl => g_payment_term_ext_tbl,
                  p_value => l_payment_term_name,
                  p_key => p_payment_term_id,
                  p_action => 'PUT',
                  x_return_status => l_return_status);

              IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name, 'Put l_return_status', l_return_status);
              END IF;

            END IF;
        END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'Returning l_payment_term_name=', l_payment_term_name);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return l_payment_term_name;

EXCEPTION WHEN OTHERS THEN
        l_payment_term_name := NULL;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return l_payment_term_name;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
END;


procedure get_cross_reference(X_INVENTORY_ITEM_ID  IN  NUMBER,
                              X_ORGANIZATION_ID    IN  NUMBER,
                              X_CROSS_REFERENCE    OUT NOCOPY   VARCHAR2) IS

CURSOR C_GET_CROSS_REFERENCE_1 IS
    SELECT CROSS_REFERENCE FROM MTL_CROSS_REFERENCES
    WHERE INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID AND
    ORG_INDEPENDENT_FLAG = 'N' AND ORGANIZATION_ID = X_ORGANIZATION_ID;

CURSOR C_GET_CROSS_REFERENCE_2 IS
    SELECT CROSS_REFERENCE FROM MTL_CROSS_REFERENCES
    WHERE INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID AND
    ORG_INDEPENDENT_FLAG = 'Y';

l_cross_reference VARCHAR2(255) := NULL; --Bugfix 9125033 increase width to 255
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CROSS_REFERENCE';
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
      WSH_DEBUG_SV.log(l_module_name,'X_INVENTORY_ITEM_ID',X_INVENTORY_ITEM_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_ORGANIZATION_ID',X_ORGANIZATION_ID);
  END IF;
  --
  IF(X_INVENTORY_ITEM_ID IS NOT NULL ) THEN
           open C_GET_CROSS_REFERENCE_1;
           fetch C_GET_CROSS_REFERENCE_1 into l_cross_reference;
           IF C_GET_CROSS_REFERENCE_1%NOTFOUND THEN
                IF X_ORGANIZATION_ID IS NOT NULL THEN
                   open C_GET_CROSS_REFERENCE_2;
                   fetch C_GET_CROSS_REFERENCE_2 into l_cross_reference;
                   IF C_GET_CROSS_REFERENCE_2%NOTFOUND THEN
                      X_CROSS_REFERENCE :=  NULL;
                   ELSE
                      X_CROSS_REFERENCE := l_cross_reference;
                   END IF;
                   close C_GET_CROSS_REFERENCE_2;
                ELSE
                   X_CROSS_REFERENCE :=  NULL;
                END IF;
           ELSE
                X_CROSS_REFERENCE := l_cross_reference;
           END IF;
           close C_GET_CROSS_REFERENCE_1;
        ELSE
           X_CROSS_REFERENCE := NULL;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
END;

procedure update_del_asn_info(X_DELIVERY_ID            IN     NUMBER,
                              X_TIME_STAMP_SEQUENCE_NUMBER        IN OUT NOCOPY  NUMBER,
                              X_TIME_STAMP_DATE        IN OUT NOCOPY  DATE,
                              X_G_TIME_STAMP_SEQUENCE_NUMBER IN OUT NOCOPY  NUMBER,
                              X_G_TIME_STAMP_DATE IN OUT NOCOPY  DATE) IS
                              --
l_debug_on BOOLEAN;
                              --
                              l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DEL_ASN_INFO';
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
      WSH_DEBUG_SV.log(l_module_name,'X_DELIVERY_ID',X_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_TIME_STAMP_SEQUENCE_NUMBER',X_TIME_STAMP_SEQUENCE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'X_TIME_STAMP_DATE',X_TIME_STAMP_DATE);
      WSH_DEBUG_SV.log(l_module_name,'X_G_TIME_STAMP_SEQUENCE_NUMBER',X_G_TIME_STAMP_SEQUENCE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'X_G_TIME_STAMP_DATE',X_G_TIME_STAMP_DATE);
  END IF;
  --
  IF(X_TIME_STAMP_SEQUENCE_NUMBER IS NOT NULL AND X_G_TIME_STAMP_SEQUENCE_NUMBER IS NULL) THEN
           X_G_TIME_STAMP_SEQUENCE_NUMBER := X_TIME_STAMP_SEQUENCE_NUMBER;
           X_G_TIME_STAMP_DATE := sysdate;
           X_TIME_STAMP_DATE := X_G_TIME_STAMP_DATE;
  ELSIF(X_G_TIME_STAMP_SEQUENCE_NUMBER IS NOT NULL) THEN
           X_TIME_STAMP_SEQUENCE_NUMBER := X_G_TIME_STAMP_SEQUENCE_NUMBER;
           X_TIME_STAMP_DATE := X_G_TIME_STAMP_DATE;
        ELSE
           SELECT wsh_asn_seq_number_s.nextval,
                  sysdate
             INTO X_G_TIME_STAMP_SEQUENCE_NUMBER,
                  X_G_TIME_STAMP_DATE
             FROM dual;

             X_TIME_STAMP_SEQUENCE_NUMBER := X_G_TIME_STAMP_SEQUENCE_NUMBER;
             X_TIME_STAMP_DATE := X_G_TIME_STAMP_DATE;
  END IF;


  UPDATE WSH_NEW_DELIVERIES
        SET asn_seq_number = X_G_TIME_STAMP_SEQUENCE_NUMBER,
            asn_date_sent  = X_G_TIME_STAMP_DATE
        WHERE delivery_id    = X_DELIVERY_ID;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END;


procedure get_location_code (
  p_location_id    IN  NUMBER,
  x_location_code  OUT NOCOPY VARCHAR2) IS

BEGIN

  IF p_location_id IS NOT NULL THEN
    x_location_code := wsh_util_core.get_location_description (
                         p_location_id => p_location_id,
                         p_format => 'CODE');
  ELSE
    x_location_code := NULL;

  END IF;

END get_location_code;


procedure get_location_info (
  p_location_id    IN NUMBER,
  p_delivery_id  	 IN NUMBER,--Bug 7371411
  x_location       OUT NOCOPY VARCHAR2,
  x_edi_loc_code   OUT NOCOPY VARCHAR2,
  x_tp_ref_ext1    OUT NOCOPY VARCHAR2,
  x_tp_ref_ext2    OUT NOCOPY VARCHAR2,
  x_customer_name  OUT NOCOPY VARCHAR2,
  x_address1       OUT NOCOPY VARCHAR2,
  x_address2       OUT NOCOPY VARCHAR2,
  x_address3       OUT NOCOPY VARCHAR2,
  x_address4       OUT NOCOPY VARCHAR2,
  x_city           OUT NOCOPY VARCHAR2,
  x_state          OUT NOCOPY VARCHAR2,
  x_postal_code    OUT NOCOPY VARCHAR2,
  x_country        OUT NOCOPY VARCHAR2,
  x_province       OUT NOCOPY VARCHAR2,
  x_county         OUT NOCOPY VARCHAR2,
  x_address_id     OUT NOCOPY NUMBER,
  x_area_code      OUT NOCOPY VARCHAR2,
  x_phone_number   OUT NOCOPY VARCHAR2) IS

  -- Bug# 7371411: Getting the operating unit value from DDs which are
  -- associated to the given delivery. Same logic is being followed
  -- for ship to locations ( pls refer the view wsh_dsno_deliveries_v)

CURSOR get_customer_info IS
SELECT CL.customer_id,
       CL.location,
       CL.tp_location_code_ext,
       ECH.tp_reference_ext1,
       ECH.tp_reference_ext2,
       CL.customer_name,
       CL.address1,
       CL.address2,
       CL.address3,
       CL.address4,
       CL.city,
       CL.postal_code,
       CL.country,
       CL.state,
       CL.province,
       CL.county,
       CL.address_id
FROM wsh_customer_locations_v CL , ece_tp_headers ECH
WHERE CL.tp_header_id    = ECH.tp_header_id (+) AND
      CL.wsh_location_id = p_location_id AND
      CL.site_use_status = 'A' AND
      CL.site_use_code   = 'SHIP_TO' AND
      ( CL.ORG_ID IS NULL  OR CL.ORG_ID IN
                           ( SELECT  first_value(wdd.org_id) over(ORDER BY COUNT(wdd.org_id) DESC ) AS ORG_ID
                             FROM    wsh_delivery_assignments wda,
                                     wsh_delivery_details wdd
                             WHERE   wdd.delivery_detail_id = wda.delivery_detail_id AND
                                     wda.delivery_id        = p_delivery_id AND
                                     wdd.container_flag     = 'N'
                             GROUP BY org_id
                           )
      );

l_customer_id      NUMBER;
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LOCATION_INFO';

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
  WSH_DEBUG_SV.log(l_module_name, 'p_location_id',p_location_id);
  WSH_DEBUG_SV.log(l_module_name, 'p_delivery_id',p_delivery_id);

END IF;
--

IF p_location_id IS NOT NULL THEN
  OPEN get_customer_info;
  FETCH get_customer_info
  INTO  l_customer_id,
        x_location,
        x_edi_loc_code,
        x_tp_ref_ext1,
        x_tp_ref_ext2,
        x_customer_name,
        x_address1,
        x_address2,
        x_address3,
        x_address4,
        x_city,
        x_postal_code,
        x_country,
        x_state,
        x_province,
        x_county,
        x_address_id;

    IF get_customer_info%NOTFOUND THEN
      CLOSE get_customer_info;
      x_location       := NULL;
      x_edi_loc_code   := NULL;
      x_tp_ref_ext1    := NULL;
      x_tp_ref_ext2    := NULL;
      x_customer_name  := NULL;
      x_address1       := NULL;
      x_address2       := NULL;
      x_address3       := NULL;
      x_address4       := NULL;
      x_city           := NULL;
      x_state          := NULL;
      x_postal_code    := NULL;
      x_country        := NULL;
      x_province       := NULL;
      x_county         := NULL;
      x_address_id     := NULL;
      x_area_code      := NULL;
      x_phone_number   := NULL;

    ELSE
      x_area_code := wsh_ece_views_def.get_cust_area_code(l_customer_id);
      x_phone_number := wsh_ece_views_def.get_cust_phone_number;
    END IF;

ELSE
  x_location       := NULL;
  x_edi_loc_code   := NULL;
  x_tp_ref_ext1    := NULL;
  x_tp_ref_ext2    := NULL;
  x_customer_name  := NULL;
  x_address1       := NULL;
  x_address2       := NULL;
  x_address3       := NULL;
  x_address4       := NULL;
  x_city           := NULL;
  x_state          := NULL;
  x_postal_code    := NULL;
  x_country        := NULL;
  x_province       := NULL;
  x_county         := NULL;
  x_address_id     := NULL;
  x_area_code      := NULL;
  x_phone_number   := NULL;

END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--

END get_location_info;


procedure get_dlvy_location_info (
  p_intmed_ship_to_location_id   IN NUMBER,
  p_pooled_ship_to_location_id   IN NUMBER,
  p_delivery_id 			   IN NUMBER, --Bug 7371411
  x_ist_location                 OUT NOCOPY VARCHAR2,
  x_ist_edi_loc_code             OUT NOCOPY VARCHAR2,
  x_ist_tp_ref_ext1              OUT NOCOPY VARCHAR2,
  x_ist_tp_ref_ext2              OUT NOCOPY VARCHAR2,
  x_ist_customer_name            OUT NOCOPY VARCHAR2,
  x_ist_address1                 OUT NOCOPY VARCHAR2,
  x_ist_address2                 OUT NOCOPY VARCHAR2,
  x_ist_address3                 OUT NOCOPY VARCHAR2,
  x_ist_address4                 OUT NOCOPY VARCHAR2,
  x_ist_city                     OUT NOCOPY VARCHAR2,
  x_ist_state                    OUT NOCOPY VARCHAR2,
  x_ist_postal_code              OUT NOCOPY VARCHAR2,
  x_ist_country                  OUT NOCOPY VARCHAR2,
  x_ist_province                 OUT NOCOPY VARCHAR2,
  x_ist_county                   OUT NOCOPY VARCHAR2,
  x_ist_address_id               OUT NOCOPY NUMBER,
  x_ist_area_code                OUT NOCOPY VARCHAR2,
  x_ist_phone_number             OUT NOCOPY VARCHAR2,
  x_pst_location                 OUT NOCOPY VARCHAR2,
  x_pst_edi_loc_code             OUT NOCOPY VARCHAR2,
  x_pst_tp_ref_ext1              OUT NOCOPY VARCHAR2,
  x_pst_tp_ref_ext2              OUT NOCOPY VARCHAR2,
  x_pst_customer_name            OUT NOCOPY VARCHAR2,
  x_pst_address1                 OUT NOCOPY VARCHAR2,
  x_pst_address2                 OUT NOCOPY VARCHAR2,
  x_pst_address3                 OUT NOCOPY VARCHAR2,
  x_pst_address4                 OUT NOCOPY VARCHAR2,
  x_pst_city                     OUT NOCOPY VARCHAR2,
  x_pst_state                    OUT NOCOPY VARCHAR2,
  x_pst_postal_code              OUT NOCOPY VARCHAR2,
  x_pst_country                  OUT NOCOPY VARCHAR2,
  x_pst_province                 OUT NOCOPY VARCHAR2,
  x_pst_county                   OUT NOCOPY VARCHAR2,
  x_pst_address_id               OUT NOCOPY NUMBER,
  x_pst_area_code                OUT NOCOPY VARCHAR2,
  x_pst_phone_number             OUT NOCOPY VARCHAR2 ) IS


l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DLVY_LOCATION_INFO';

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
  WSH_DEBUG_SV.log(l_module_name, 'p_intmed_ship_to_location_id',p_intmed_ship_to_location_id);
   WSH_DEBUG_SV.log(l_module_name, 'p_pooled_ship_to_location_id',p_pooled_ship_to_location_id);
   WSH_DEBUG_SV.log(l_module_name, 'p_delivery_id',p_delivery_id);

END IF;
--

IF  p_intmed_ship_to_location_id IS NULL THEN
  x_ist_location       := NULL;
  x_ist_edi_loc_code   := NULL;
  x_ist_tp_ref_ext1    := NULL;
  x_ist_tp_ref_ext2    := NULL;
  x_ist_customer_name  := NULL;
  x_ist_address1       := NULL;
  x_ist_address2       := NULL;
  x_ist_address3       := NULL;
  x_ist_address4       := NULL;
  x_ist_city           := NULL;
  x_ist_country        := NULL;
  x_ist_state          := NULL;
  x_ist_postal_code    := NULL;
  x_ist_province       := NULL;
  x_ist_county         := NULL;
  x_ist_address_id     :=NULL;
  x_ist_area_code      := NULL;
  x_ist_phone_number   := NULL;
ELSE
  get_location_info(
    p_location_id   => p_intmed_ship_to_location_id,
    p_delivery_id   => p_delivery_id,
    x_location      => x_ist_location,
    x_edi_loc_code  => x_ist_edi_loc_code,
    x_tp_ref_ext1   => x_ist_tp_ref_ext1,
    x_tp_ref_ext2   => x_ist_tp_ref_ext2,
    x_customer_name => x_ist_customer_name,
    x_address1      => x_ist_address1,
    x_address2      => x_ist_address2,
    x_address3      => x_ist_address3,
    x_address4      => x_ist_address4,
    x_city          => x_ist_city,
    x_state         => x_ist_state,
    x_postal_code   => x_ist_postal_code,
    x_country       => x_ist_country,
    x_province      => x_ist_province,
    x_county        => x_ist_county,
    x_address_id    => x_ist_address_id,
    x_area_code     => x_ist_area_code,
    x_phone_number  => x_ist_phone_number);

END IF;

IF p_pooled_ship_to_location_id IS NULL THEN
  x_pst_location       := NULL;
  x_pst_edi_loc_code   := NULL;
  x_pst_tp_ref_ext1    := NULL;
  x_pst_tp_ref_ext2    := NULL;
  x_pst_customer_name  := NULL;
  x_pst_address1       := NULL;
  x_pst_address2       := NULL;
  x_pst_address3       := NULL;
  x_pst_address4       := NULL;
  x_pst_city           := NULL;
  x_pst_country        := NULL;
  x_pst_state          := NULL;
  x_pst_postal_code    := NULL;
  x_pst_province       := NULL;
  x_pst_county         := NULL;
  x_pst_address_id     := NULL;
  x_pst_area_code      := NULL;
  x_pst_phone_number   := NULL;

ELSE

  get_location_info(
    p_location_id   => p_pooled_ship_to_location_id,
    p_delivery_id   => p_delivery_id,
    x_location      => x_pst_location,
    x_edi_loc_code  => x_pst_edi_loc_code,
    x_tp_ref_ext1   => x_pst_tp_ref_ext1,
    x_tp_ref_ext2   => x_pst_tp_ref_ext2,
    x_customer_name => x_pst_customer_name,
    x_address1      => x_pst_address1,
    x_address2      => x_pst_address2,
    x_address3      => x_pst_address3,
    x_address4      => x_pst_address4,
    x_city          => x_pst_city,
    x_state         => x_pst_state,
    x_postal_code   => x_pst_postal_code,
    x_country       => x_pst_country,
    x_province      => x_pst_province,
    x_county        => x_pst_county,
    x_address_id    => x_pst_address_id,
    x_area_code     => x_pst_area_code,
    x_phone_number  => x_pst_phone_number);

END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--

END get_dlvy_location_info;

procedure get_dlvy_dest_cont_info (
  p_contact_id                   IN NUMBER,
  x_dest_cont_last_name          OUT NOCOPY VARCHAR2,
  x_dest_cont_first_name         OUT NOCOPY VARCHAR2,
  x_cont_job_title               OUT NOCOPY VARCHAR2 )
IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DLVY_DEST_CONT_INFO';

cursor l_dlvy_dest_cont_csr (p_contact_id IN NUMBER ) is
select substrb( REL_PARTY.PERSON_LAST_NAME,1,50) ,
       substrb( REL_PARTY.PERSON_FIRST_NAME,1,40),
       ORG_CONT.JOB_TITLE
from   HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
       HZ_RELATIONSHIPS REL,
       HZ_ORG_CONTACTS ORG_CONT,
       HZ_PARTIES REL_PARTY
WHERE  ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_contact_id
AND    REL.PARTY_ID  = ACCT_ROLE.PARTY_ID
AND    ACCT_ROLE.ROLE_TYPE  = 'CONTACT'
AND    REL.RELATIONSHIP_ID = ORG_CONT.PARTY_RELATIONSHIP_ID
AND    REL.SUBJECT_TABLE_NAME  = 'HZ_PARTIES'
AND    REL.OBJECT_TABLE_NAME  = 'HZ_PARTIES'
AND    REL.DIRECTIONAL_FLAG  = 'F'
AND    REL.SUBJECT_ID = REL_PARTY.PARTY_ID;




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
  WSH_DEBUG_SV.log(l_module_name, p_contact_id || p_contact_id);
END IF;
--
open l_dlvy_dest_cont_csr(p_contact_id);
fetch l_dlvy_dest_cont_csr into   x_dest_cont_last_name,
                                  x_dest_cont_first_name,
                                  x_cont_job_title;
close l_dlvy_dest_cont_csr;
--
IF l_debug_on THEN
  WSH_DEBUG_SV.log(l_module_name, x_dest_cont_last_name || x_dest_cont_last_name);
  WSH_DEBUG_SV.log(l_module_name, x_dest_cont_first_name || x_dest_cont_first_name);
  WSH_DEBUG_SV.log(l_module_name, x_cont_job_title || x_cont_job_title);
END IF;
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
exception
  when others then
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END get_dlvy_dest_cont_info;



END;

/
