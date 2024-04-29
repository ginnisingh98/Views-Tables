--------------------------------------------------------
--  DDL for Package Body FTE_COMP_CONSTRAINT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_COMP_CONSTRAINT_UTIL" as
/* $Header: FTECCUTB.pls 120.2 2005/07/19 23:25:50 skattama noship $ */


G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_COMP_CONSTRAINT_UTIL';
-- Global Variables

    g_unexp_char         VARCHAR2(30) := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    g_unexp_num          NUMBER       := -999999;


    CURSOR  c_meaning(c_lookup_type IN VARCHAR2,c_lookup_code IN VARCHAR2) IS
      SELECT flv.meaning
      FROM   fnd_lookup_values flv, fnd_lookup_types flt
      WHERE  flv.lookup_type = flt.lookup_type
      AND    flv.lookup_code = c_lookup_code
      AND    flt.lookup_type = c_lookup_type
      AND    flv.language   = USERENV('LANG')
      AND    nvl(flv.start_date_active,sysdate)<=sysdate
      AND    nvl(flv.end_date_active,sysdate)>=sysdate
      AND    flv.enabled_flag = 'Y';


FUNCTION get_object_name(
             p_object_type             IN      VARCHAR2,
             p_object_value_num        IN      NUMBER DEFAULT NULL,
             p_object_parent_id        IN      NUMBER DEFAULT NULL,
             p_object_value_char       IN      VARCHAR2 DEFAULT NULL,
             x_fac_company_name        OUT NOCOPY      VARCHAR2,
             x_fac_company_type        OUT NOCOPY  VARCHAR2 ) RETURN VARCHAR2
IS

    CURSOR c_get_org_name(c_object_value_num IN NUMBER) IS
    SELECT HOU.NAME ORGANIZATION_NAME
    FROM   HR_ORGANIZATION_UNITS HOU, HR_ORGANIZATION_INFORMATION HOI1, MTL_PARAMETERS MP
    WHERE  HOU.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
    AND    HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
    AND    HOI1.ORG_INFORMATION1 = 'INV'
    AND    HOI1.ORG_INFORMATION2 = 'Y'
    AND    ( HOI1.ORG_INFORMATION_CONTEXT || '') = 'CLASS'
    AND    HOU.ORGANIZATION_ID = c_object_value_num;

    CURSOR  c_get_cus_name(c_object_value_num IN NUMBER) IS
    select  hp.party_name
    from    hz_parties hp ,
            hz_cust_accounts hcas
    where   hcas.cust_account_id = c_object_value_num
    and     hcas.party_id = hp.party_id;

    CURSOR  c_get_car_name(c_object_value_num IN NUMBER) IS
    select  hp.party_name
    from    hz_parties hp , wsh_carriers wc
    where   wc.carrier_id = c_object_value_num
    and     wc.carrier_id = hp.party_id;

    -- Once a constraint for a supplier has been defined,
    -- knowing party_id is enough to get the supplier name ?

    CURSOR  c_get_sup_name(c_object_value_num IN NUMBER) IS
    select  hp.party_name
    from    hz_parties hp,
            po_vendors po,
            hz_relationships rel
    where   hp.party_id = c_object_value_num
        AND rel.relationship_type = 'POS_VENDOR_PARTY'
        and rel.object_id = hp.party_id
        and rel.object_table_name = 'HZ_PARTIES'
        and rel.object_type = 'ORGANIZATION'
        and rel.subject_table_name = 'PO_VENDORS'
        and rel.subject_id = po.vendor_id
        and rel.subject_type = 'POS_VENDOR';

    CURSOR c_get_fac_comp(c_location_id IN NUMBER) IS
    SELECT  wl.wsh_location_id facility_id,
            haou.organization_id company_id,
            haou.name company_name,
            'ORGANIZATION' company_type,
            nvl(nvl(flp.facility_code,wl.location_code),to_char(wl.wsh_location_id)) facility_code,
            nvl(flp.description,wl.ui_location_code) description
    FROM   HR_ORGANIZATION_UNITS HAOU, HR_ORGANIZATION_INFORMATION HOI1, MTL_PARAMETERS MP,
           wsh_locations wl, fte_location_parameters flp
    WHERE  haou.location_id = wl.source_location_id
    AND    wl.location_source_code = 'HR'
    AND    HAOU.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
    AND    HAOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
    AND    HOI1.ORG_INFORMATION1 = 'INV'
    AND    HOI1.ORG_INFORMATION2 = 'Y'
    AND    ( HOI1.ORG_INFORMATION_CONTEXT || '') = 'CLASS'
    AND     wl.wsh_location_id = flp.location_id (+)
    AND     wl.wsh_location_id = c_location_id
    union
    SELECT  wl.wsh_location_id facility_id,
            hcas.cust_account_id company_id,
            hp.party_name company_name,
            'CUSTOMER' company_type,
            nvl(nvl(flp.facility_code,wl.location_code),to_char(wl.wsh_location_id)) facility_code,
            nvl(flp.description,wl.ui_location_code) description
    from    hz_parties hp , hz_party_sites hps,
            hz_cust_acct_sites_all hcas,
            wsh_locations wl,
            fte_location_parameters flp
    where   hcas.party_site_id = hps.party_site_id
    and     hps.party_id = hp.party_id
    AND     hps.location_id = wl.source_location_id
    and     wl.location_source_code = 'HZ'
    and     hp.status='A'
    AND     wl.wsh_location_id = flp.location_id (+)
    AND     wl.wsh_location_id = c_location_id
    union
    SELECT  wl.wsh_location_id facility_id,
            wc.carrier_id company_id,
            wc.carrier_name company_name,
            'CARRIER' company_type,
            nvl(nvl(flp.facility_code,wl.location_code),to_char(wl.wsh_location_id)) facility_code,
            nvl(flp.description,wl.ui_location_code) description
    from     hz_party_sites hps,
            wsh_carriers_v wc,
            wsh_locations wl,
            fte_location_parameters flp
    where   hps.party_id = wc.carrier_id
    AND     hps.location_id = wl.source_location_id
    and     wl.location_source_code = 'HZ'
    and     wc.active='A'
    AND     wl.wsh_location_id = c_location_id
    AND     wl.wsh_location_id = flp.location_id (+)
    union
    SELECT  wl.wsh_location_id facility_id,
            hp.party_id company_id,
            hp.party_name company_name,
            'SUPPLIER' company_type,
            nvl(nvl(flp.facility_code,wl.location_code),to_char(wl.wsh_location_id)) facility_code,
            nvl(flp.description,wl.ui_location_code) description
    FROM    hz_parties hp ,
            po_vendors po,
            hz_relationships rel,
            hz_party_sites hps,
            wsh_locations wl,
            fte_location_parameters flp
    WHERE hps.party_id = hp.party_id
        AND rel.relationship_type = 'POS_VENDOR_PARTY'
        and rel.object_id = hp.party_id
        and rel.object_table_name = 'HZ_PARTIES'
        and rel.object_type = 'ORGANIZATION'
        and rel.subject_table_name = 'PO_VENDORS'
        and rel.subject_id = po.vendor_id
        and rel.subject_type = 'POS_VENDOR'
        AND hps.location_id = wl.source_location_id
        AND wl.location_source_code = 'HZ'
        AND hp.status='A'
        AND wl.wsh_location_id = c_location_id
        AND wl.wsh_location_id = flp.location_id (+);

    CURSOR c_get_item_name(c_item_id  IN NUMBER) IS
    SELECT m.concatenated_segments
    FROM   mtl_system_items_vl m
    WHERE  m.inventory_item_id = c_item_id
    AND    m.organization_id in ( select p.master_organization_id
           from mtl_parameters p)
    AND rownum = 1;

    CURSOR c_get_vehicle_det(c_veh_type_id IN NUMBER) IS
    SELECT inventory_item_id,
           organization_id,
           vehicle_class_code
    FROM   fte_vehicle_types
    WHERE  vehicle_type_id = c_veh_type_id;


    --#REG-ZON
    CURSOR c_get_region_name(c_region_id IN NUMBER) IS
    SELECT country,
	   state,
	   city,
	   postal_code_from,
	   postal_code_to
    FROM   wsh_regions_v
    WHERE  region_id = c_region_id;

    CURSOR c_get_zone_name(c_zone_id IN NUMBER) IS
    SELECT zone
    FROM   wsh_regions_v
    WHERE  region_id = c_zone_id;
    --#REG-ZON


    l_shared_fac        BOOLEAN := FALSE;
    l_result            VARCHAR2(2000);
    l_facility_id       NUMBER;
    l_company_id        NUMBER;
    l_facility_code     VARCHAR2(100);
    l_company_name      VARCHAR2(200);
    l_company_type      VARCHAR2(30);
    l_description       VARCHAR2(200);
    l_veh_item_id       NUMBER;
    l_veh_org_id        NUMBER;
    l_veh_class_code    VARCHAR2(30);
    l_vehicle_meaning   VARCHAR2(80);
    --#REG-ZON
    l_country           WSH_REGIONS_TL.COUNTRY%TYPE;
    l_state             WSH_REGIONS_TL.STATE%TYPE;
    l_city              WSH_REGIONS_TL.CITY%TYPE;
    l_postal_code_from  WSH_REGIONS_TL.POSTAL_CODE_FROM%TYPE;
    l_postal_code_to	WSH_REGIONS_TL.POSTAL_CODE_TO%TYPE;
    --#REG-ZON

    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'get_object_name';

BEGIN

    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;
    --
    -- object1_type values : ORG CUS FAC CAR MOD ITM SUP
    -- object2_type values : FAC CAR MOD ITM VHT CUS

    /*
    p_object_type is
    1. either the first/last 3 letters of the comp class code or
    2. the first 3 letters of the lookup FTE_FACILITY_COMPANY_TYPE
    3. for vehicle (VEH) it can be VHT
    */

    IF p_object_type = 'ORG' THEN

       OPEN c_get_org_name(p_object_value_num);
       FETCH c_get_org_name INTO l_result;
       CLOSE c_get_org_name;

       x_fac_company_type := 'ORGANIZATION';
       x_fac_company_name := l_result;

    ELSIF p_object_type = 'CUS' THEN

       OPEN c_get_cus_name(p_object_value_num);
       FETCH c_get_cus_name INTO l_result;
       CLOSE c_get_cus_name;

       x_fac_company_type := 'CUSTOMER';
       x_fac_company_name := l_result;

    ELSIF p_object_type = 'SUP' THEN

       OPEN c_get_sup_name(p_object_value_num);
       FETCH c_get_sup_name INTO l_result;
       CLOSE c_get_sup_name;

       x_fac_company_type := 'SUPPLIER';
       x_fac_company_name := l_result;

    ELSIF p_object_type = 'CAR' THEN

       OPEN c_get_car_name(p_object_value_num);
       FETCH c_get_car_name INTO l_result;
       CLOSE c_get_car_name;

       x_fac_company_type := 'CARRIER';
       x_fac_company_name := l_result;

    ELSIF p_object_type = 'FAC' THEN

       OPEN c_get_fac_comp(p_object_value_num);
       LOOP
          FETCH c_get_fac_comp INTO l_facility_id, l_company_id, l_company_name, l_company_type,
                                 l_facility_code, l_description;
          EXIT WHEN c_get_fac_comp%NOTFOUND;
          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'c_get_fac_comp rowcount '|| c_get_fac_comp%ROWCOUNT);
          END IF;
          --
          IF c_get_fac_comp%ROWCOUNT > 1 THEN
             l_shared_fac := TRUE;
             EXIT;
          END IF;
       END LOOP;
       CLOSE c_get_fac_comp;

       l_result := l_facility_code;
       -- Can same location_id be share across multiple company types ??
       -- If yes, this API will return the second company type
       x_fac_company_type := l_company_type;
       IF l_shared_fac THEN
          -- Return "Multiple"
          x_fac_company_name := fnd_message.get_string('FTE','FTE_DELIVERIES_MULTIPLE_LEGS');
       ELSE
          x_fac_company_name := l_company_name;
       END IF;

    ELSIF p_object_type = 'ITM' THEN

      IF WSH_UTIL_CORE.TP_Is_Installed = 'Y' THEN

         OPEN c_get_item_name(p_object_value_num);
         FETCH c_get_item_name INTO l_result;
         CLOSE c_get_item_name;

      ELSE

      l_result :=  WSH_UTIL_CORE.Get_Item_Name
                  (p_item_id              =>   p_object_value_num,
                   p_organization_id      =>   p_object_parent_id
                   );
      END IF;

    ELSIF p_object_type = 'MOD' THEN

       OPEN c_meaning('WSH_MODE_OF_TRANSPORT',p_object_value_char);
       FETCH c_meaning INTO l_result;
       CLOSE c_meaning;

    ELSIF p_object_type = 'VHT' THEN -- Vehicle Type

       OPEN c_get_vehicle_det(p_object_value_num);
       FETCH c_get_vehicle_det INTO l_veh_item_id,l_veh_org_id,l_veh_class_code;
       CLOSE c_get_vehicle_det;

       l_result :=  WSH_UTIL_CORE.Get_Item_Name
                (p_item_id              =>   l_veh_item_id,
                 p_organization_id      =>   l_veh_org_id
                 );

       -- IMPORTANT --
       -- x_fac_company_name parameter is used for
       -- returning the vehicle class code
       -- in case of a constraint tied to vehicle type
       -- IMPORTANT --

       x_fac_company_name := l_veh_class_code;

    --#REG-ZON(S)
    ELSIF p_object_type = 'REG' THEN -- Region

	OPEN  c_get_region_name(p_object_value_num);
	FETCH c_get_region_name INTO l_country,l_state,l_city,l_postal_code_from,l_postal_code_to;
	CLOSE c_get_region_name;

	-- Country is Mandatory for a region.
	l_result := l_country;

	IF l_state IS NOT NULL THEN
             l_result := l_result||', '||l_state;
	END IF;

	IF l_city IS NOT NULL THEN
             l_result := l_result||', '||l_city;
	END IF;

	IF l_postal_code_from IS NOT NULL THEN
	     l_result := l_result||', '||l_postal_code_from;
	END IF;

	IF l_postal_code_to IS NOT NULL THEN
	     l_result := l_result||'-'||l_postal_code_to;
	END IF;

    ELSIF p_object_type = 'ZON' THEN

	OPEN  c_get_zone_name(p_object_value_num);
	FETCH c_get_zone_name INTO l_result;
	CLOSE c_get_zone_name;

    END IF;
    --#REG-ZON(E)

      --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Object Type '|| p_object_type);
        WSH_DEBUG_SV.logmsg(l_module_name,'Object Value Num '|| p_object_value_num);
        WSH_DEBUG_SV.logmsg(l_module_name,'Object Value Char '|| p_object_value_char);
        WSH_DEBUG_SV.logmsg(l_module_name,'Object parent id '|| p_object_parent_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'Object name '|| l_result);
        WSH_DEBUG_SV.logmsg(l_module_name,'Company type  '|| x_fac_company_type);
        WSH_DEBUG_SV.logmsg(l_module_name,'Company name  '|| x_fac_company_name);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
      --

    RETURN l_result;

EXCEPTION
    WHEN others THEN

      --#REG-ZON
      IF c_get_zone_name%ISOPEN THEN
         CLOSE c_get_zone_name;
      END IF;

      IF c_get_region_name%ISOPEN THEN
         CLOSE c_get_region_name;
      END IF;
      --#REG-ZON

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
      RETURN g_unexp_char;

END get_object_name;


PROCEDURE get_facility_display(
             p_source_location_id      IN VARCHAR2,
             p_source_location_code    IN VARCHAR2,
             x_fac_sites               OUT NOCOPY      VARCHAR2,
             x_fac_company_type        OUT NOCOPY      VARCHAR2,
             x_fac_company_name        OUT NOCOPY      VARCHAR2,
             x_return_status           OUT NOCOPY      VARCHAR2,
	     x_msg_count               OUT NOCOPY      NUMBER,
	     x_msg_data                OUT NOCOPY      VARCHAR2 )
IS

    cursor c_hr_details (p_locid VARCHAR2) is
    select hou.organization_id company_id, hou.name company_name,
           hou.name site, 'ORGANIZATION' company_type
    FROM   HR_ORGANIZATION_UNITS HOU, HR_ORGANIZATION_INFORMATION HOI1, MTL_PARAMETERS MP,
           wsh_locations wl
    WHERE  hou.location_id = wl.source_location_id
    AND    wl.location_source_code = 'HR'
    AND    HOU.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
    AND    HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
    AND    HOI1.ORG_INFORMATION1 = 'INV'
    AND    HOI1.ORG_INFORMATION2 = 'Y'
    AND    ( HOI1.ORG_INFORMATION_CONTEXT || '') = 'CLASS'
    AND    wl.source_location_id=p_locid;

    cursor c_hz_details (p_locid VARCHAR2) is
    select wc.carrier_id company_id, wc.carrier_name company_name,
           wc.carrier_name||'/'||nvl(hps.party_site_name,hps.party_site_number)
           site, 'CARRIER' company_type
    from   wsh_locations wl, hz_party_sites hps,  wsh_carriers_v wc
    where  wl.source_location_id=hps.location_id
    and    hps.party_id=wc.carrier_id
    and    wl.location_source_code='HZ'
    and    wc.active='A'
    and    wl.source_location_id=p_locid
    union all
    select hcas.cust_account_id company_id, hp.party_name company_name,
           hp.party_name||'/'||nvl(hps.party_site_name,hps.party_site_number)
           site, 'CUSTOMER' company_type
      from wsh_locations wl, hz_party_sites hps, hz_parties hp,
           hz_cust_acct_sites_all hcas
     where wl.source_location_id=hps.location_id
       and hps.party_id=hp.party_id
       and wl.location_source_code='HZ'
       and hcas.party_site_id=hps.party_site_id
       and hp.status='A'
       and wl.source_location_id=p_locid
    union all
    select hp.party_id company_id, hp.party_name company_name,
           hp.party_name||'/'||nvl(hps.party_site_name,hps.party_site_number)
           site, 'SUPPLIER' company_type
    FROM    hz_parties hp ,
            po_vendors po,
            hz_relationships rel,
            hz_party_sites hps,
            wsh_locations wl
     where wl.source_location_id=hps.location_id
       and hps.party_id=hp.party_id
        AND rel.relationship_type = 'POS_VENDOR_PARTY'
        and rel.object_id = hp.party_id
        and rel.object_table_name = 'HZ_PARTIES'
        and rel.object_type = 'ORGANIZATION'
        and rel.subject_table_name = 'PO_VENDORS'
        and rel.subject_id = po.vendor_id
        and rel.subject_type = 'POS_VENDOR'
       and wl.location_source_code='HZ'
       and hp.status='A'
       and wl.source_location_id=p_locid;

    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'get_facility_display';

    l_company_id              NUMBER;
    l_prev_company_id         NUMBER;
    l_fac_sites               VARCHAR2(2000) := NULL;
    l_fac_company_type        VARCHAR2(30)   := '';
    l_fac_company_name        VARCHAR2(2000) := NULL;

    invalid_loc_src_code EXCEPTION;
    others               EXCEPTION;

BEGIN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
      END IF;

      IF p_source_location_code ='HR' THEN
         FOR cur IN c_hr_details (p_source_location_id) LOOP
             IF l_fac_company_name IS NULL THEN
                l_fac_company_name := cur.company_name;
                l_fac_sites := cur.site;
             ELSE
                l_fac_company_name := fnd_message.get_string('FTE','FTE_DELIVERIES_MULTIPLE_LEGS');
                l_fac_sites:=l_fac_sites||', '||cur.site;
             END IF;
             l_fac_company_type:=cur.company_type;
         END LOOP;
      ELSIF p_source_location_code ='HZ' THEN
         FOR cur IN c_hz_details (p_source_location_id) LOOP
             IF l_fac_company_name IS NULL THEN
                l_fac_company_name := cur.company_name;
                l_fac_sites := cur.site;
             ELSE
                l_fac_company_name := fnd_message.get_string('FTE','FTE_DELIVERIES_MULTIPLE_LEGS');
                l_fac_sites:=l_fac_sites||', '||cur.site;
             END IF;
             l_fac_company_type:=cur.company_type;
         END LOOP;
      ELSE
         raise invalid_loc_src_code;
      END IF;

      x_fac_sites:=l_fac_sites;
      x_fac_company_type:=l_fac_company_type;
      x_fac_company_name:=l_fac_company_name;

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'p_source_location_id ', p_source_location_id);
        wsh_debug_sv.log(l_module_name, 'p_source_location_code ', p_source_location_code);
        wsh_debug_sv.log(l_module_name, 'x_fac_sites ', x_fac_sites);
        wsh_debug_sv.log(l_module_name, 'x_fac_company_name ', x_fac_company_name);
        wsh_debug_sv.log(l_module_name, 'x_fac_company_type ', x_fac_company_type);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

      FND_MSG_PUB.Count_And_Get (
             p_count => x_msg_count,
             p_data  => x_msg_data,
             p_encoded => FND_API.G_FALSE);

EXCEPTION
    WHEN invalid_loc_src_code THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_And_Get (
             p_count => x_msg_count,
             p_data  => x_msg_data,
             p_encoded => FND_API.G_FALSE);

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Error : Invalid Location Source Code : ', p_source_location_code);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get (
             p_count => x_msg_count,
             p_data  => x_msg_data,
             p_encoded => FND_API.G_FALSE);

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END get_facility_display;

END FTE_COMP_CONSTRAINT_UTIL;


/
