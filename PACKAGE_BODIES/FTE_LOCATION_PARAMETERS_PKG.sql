--------------------------------------------------------
--  DDL for Package Body FTE_LOCATION_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_LOCATION_PARAMETERS_PKG" AS
/* $Header: FTEGFACB.pls 120.1 2005/07/18 03:27:48 skattama noship $ */

-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:        FTE_LOCATION_PARAMETERS_PKG                                            --
-- TYPE:        PACKAGE BODY                                                  --
-- DESCRIPTION: Facility Creation Package.                                    --
--                                                                            --
-- PROCEDURES:                                                                --
--         i. Create_Facilities: Given location Id's from the WSH_LOCATIONS   --
--                               table, it creates a facility for each        --
--                               location.                                    --
--        ii. Create_Facility: Creates a single facility, given a location ID --
--       iii. Get_Facility_Info: Returns information about a facility, given  --
--                               a location ID.                               --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 04/07/2003    1.0     ndodoo   N/A        Created.                         --
----------------------------------------------------------------------------- --

G_PKG_NAME                   VARCHAR2(50) := 'FTE_LOCATION_PARAMETERS_PKG';
g_cache                      BOOLEAN := TRUE;
g_cached                     BOOLEAN := FALSE;

g_nonbinary_indices          NoIndex_Number_Tbl_Type := NoIndex_Number_Tbl_Type();
--
g_Facility_Descriptions      Index_Varchar100_Tbl_Type;
g_nonindexed_Descriptions    NoIndex_Varchar100_Tbl_Type := NoIndex_Varchar100_Tbl_Type();

g_dup_locations              STRINGARRAY;

g_company_names              WSH_LOCATIONS_PKG.Address_Tbl_Type;
g_site_names                 WSH_LOCATIONS_PKG.LocationCode_Tbl_Type;
g_cur_index                  NUMBER;
g_names_exist                BOOLEAN;

-----------------------------------------------------------------------------
-- PROCEDURE  LogMsg
--
-- Purpose
--
-- Parameters
--
--
-----------------------------------------------------------------------------
  PROCEDURE LogMsg (p_module_name  IN   VARCHAR2,
                    p_text         IN   VARCHAR2) IS
  BEGIN
    IF l_debug_on THEN
      WSH_DEBUG_SV.LogMsg(p_module_name, p_text);
    END IF;
--  testpkg2.print_to_file(p_text);
  END LogMsg;


-----------------------------------------------------------------------------
-- PROCEDURE  LogMsg
--
-- Purpose
--
-- Parameters
--
--
-----------------------------------------------------------------------------
  PROCEDURE LogMsg (p_module_name  IN   VARCHAR2,
                    p_attribute    IN   VARCHAR2,
                    p_value        IN   VARCHAR2) IS
  BEGIN
    IF l_debug_on THEN
      WSH_DEBUG_SV.Log(x_Module   =>   p_module_name,
                       x_Text     =>   p_attribute,
                       x_Value    =>   p_value);
    END IF;
--  testpkg2.print_to_file(p_attribute || '=> ' || p_value);
  END LogMsg;

-----------------------------------------------------------------------------
-- PROCEDURE  Init_Debug
--
-- Purpose
--
-- Parameters
--
--
-----------------------------------------------------------------------------
  PROCEDURE Init_Debug(p_module_name    IN  VARCHAR2) IS
    BEGIN

     --SETUP DEBUGGING
    --SETUP DEBUGGING
    IF (NOT g_debug_set) THEN
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      IF l_debug_on IS NULL THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      g_debug_set := TRUE;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.push(p_module_name);
    END IF;
  END Init_Debug;

-----------------------------------------------------------------------------
-- PROCEDURE  Exit_Debug
--
-- Purpose
--
-- Parameters
--
--
-----------------------------------------------------------------------------
  PROCEDURE Exit_Debug(p_module_name    IN  VARCHAR2) IS
    BEGIN
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(p_module_name);
    END IF;
  END Exit_Debug;


-----------------------------------------------------------------------------
-- PROCEDURE  Reset_All
--
-- Purpose: Reset Package Level global variables.
--
-- Parameters: None
-----------------------------------------------------------------------------
 PROCEDURE Reset_All IS
 BEGIN
  g_cache := true;
  g_cached := false;

  g_nonbinary_indices.delete;
  g_facility_descriptions.Delete;
  g_nonindexed_descriptions.delete;
 END Reset_All;

-----------------------------------------------------------------------------
-- PROCEDURE
--
-- Purpose: Returns TRUE if the number is a binary integer.
--
-- Parameters:
--      p_location_id   IN   NUMBER:  location ID of facility
--
-----------------------------------------------------------------------------
 FUNCTION Is_Binary_Integer (p_Number   IN    NUMBER) RETURN BOOLEAN IS
 BEGIN
   RETURN( p_Number >= -2147483647 AND p_Number <= 2147483647);
 END Is_Binary_Integer;

-----------------------------------------------------------------------------
-- PROCEDURE  Create_Description
--
-- Purpose: Create the company description from  the company name and site.
--
-- Parameters:
--   1. p_company_name
--   2. p_site
-----------------------------------------------------------------------------
 FUNCTION Create_Description(p_company_name IN VARCHAR2,
                             p_site         IN VARCHAR2) RETURN VARCHAR2
  IS
    l_compname_length    NUMBER;
    l_description        VARCHAR2(300);

    l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'Create_Description';
    BEGIN
      Init_Debug(l_module_name);

      l_compname_length := 59 - length(p_site);
      l_description := substrb(p_company_name, 0, l_compname_length) || '_' || p_site;

      Exit_Debug(l_module_name);
      RETURN l_description;
 END Create_Description;


-----------------------------------------------------------------------------
-- FUNCTION Fetch_Single_Facility_Info
--
-- Purpose: Fetches and derives the facility code of a facility, from the
--          facility's company information.
-- Parameters:
--      p_location_id   IN   NUMBER:  location ID of facility
--
-----------------------------------------------------------------------------
 PROCEDURE Fetch_Single_Facility_Info(p_location_id   IN NUMBER,
                                      x_description   OUT NOCOPY VARCHAR2) IS

  l_hzr              VARCHAR2(5);
  l_cdate            DATE;
  l_company_type     VARCHAR2(30);
  l_description      VARCHAR2(300);
  l_facility_code    VARCHAR2(60);
  l_company_name     VARCHAR2(300);
  l_site             VARCHAR2(50);

  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'Fetch_Single_Facility_Info';

  --Obtain company information for internal sites.
  CURSOR c_hr_descriptions IS
    --ORGANIZATION
    SELECT hou.name company_name,
           hou.name site,
           hou.creation_date cdate,
           'ORGANIZATION' company_type
      FROM wsh_locations wl, hr_organization_units hou,
           HR_ORGANIZATION_INFORMATION HOI1, MTL_PARAMETERS MP
     WHERE wl.source_location_id = p_location_id
       AND wl.location_source_code = 'HR'
       AND wl.source_location_id = hou.location_id
       AND HOU.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
    AND    HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
    AND    HOI1.ORG_INFORMATION1 = 'INV'
    AND    HOI1.ORG_INFORMATION2 = 'Y'
    AND    ( HOI1.ORG_INFORMATION_CONTEXT || '') = 'CLASS'
    ORDER BY cdate;

  --Obtain company information for external sites.
  CURSOR c_hz_descriptions IS
    --CARRIER
    SELECT wc.carrier_name Company_Name,
           wc.carrier_name||'_'||nvl(hps.party_site_name,hps.party_site_number) Site,
           hps.creation_date Cdate,
           'CARRIER' Company_Type
      FROM wsh_locations wl, hz_party_sites hps,
           wsh_carriers_v wc
     WHERE wl.source_location_id = p_location_id
       AND wl.location_source_code = 'HZ'
       AND wl.source_location_id = hps.location_id
       AND hps.party_id = wc.carrier_id
       AND wc.active= 'A'
   UNION
    --CUSTOMER
    SELECT hp.party_name Company_Name,
           hp.party_name||'_'||nvl(hps.party_site_name,hps.party_site_number) Site,
           hps.creation_date Cdate,
           'CUSTOMER' Company_Type
      FROM wsh_locations wl, hz_party_sites hps, hz_parties hp,
           hz_cust_acct_sites_all hcas
     WHERE wl.source_location_id = p_location_id
       AND wl.location_source_code = 'HZ'
       AND wl.source_location_id = hps.location_id
       AND hps.party_id=hp.party_id
       AND hp.status='A'
       AND hcas.party_site_id = hps.party_site_id
    UNION
     --SUPPLIER
     SELECT hp.party_name Company_Name,
            hp.party_name||'_'||nvl(hps.party_site_name,hps.party_site_number) Site,
            hps.creation_date Cdate,
            'SUPPLIER' Company_Type
       FROM wsh_locations wl, po_vendors po, hz_relationships rel,
            hz_party_sites hps, hz_parties hp
      WHERE wl.source_location_id = p_location_id
        AND wl.source_location_id = hps.location_id
        AND hps.party_id = hp.party_id
        AND hp.status='A'
        AND rel.relationship_type = 'POS_VENDOR_PARTY'
        AND rel.object_id = hp.party_id
        AND rel.object_table_name = 'HZ_PARTIES'
        AND rel.object_type = 'ORGANIZATION'
        AND rel.subject_table_name = 'PO_VENDORS'
        AND rel.subject_id = po.vendor_id
        AND rel.subject_type = 'POS_VENDOR'
    ORDER BY cdate;


 BEGIN
   Init_Debug(l_module_name);

   LogMsg(l_module_name, 'p_location_id' || p_location_id);
   x_description := NULL;

   BEGIN
     SELECT location_source_code INTO l_hzr
     FROM WSH_LOCATIONS
     WHERE wsh_location_id = p_location_id;
   EXCEPTION
     WHEN OTHERS THEN
      NULL;
   END;

   IF (l_hzr = 'HZ') THEN
    OPEN c_hz_descriptions;
      FETCH c_hz_descriptions INTO l_company_name, l_site, l_cdate, l_company_type;
    CLOSE c_hz_descriptions;

   ELSIF (l_hzr = 'HR') THEN
    OPEN c_hr_descriptions;
      FETCH c_hr_descriptions INTO l_company_name, l_site, l_cdate, l_company_type;
    CLOSE c_hr_descriptions;

   ELSE
     LogMsg(l_module_name, 'ERROR: LOCATION IS NEITHER HR NOR HZ. Location ID = ' || p_location_id);
     x_description := NULL;
   END IF;

   IF (l_company_name IS NOT NULL AND l_site IS NOT NULL) THEN
     x_description := create_description(l_company_name, l_site);
   END IF;

   Exit_Debug(l_module_name);
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     LogMsg(l_module_name, 'LOCATION ID ' || p_location_id || ' IS NOT A VALID FACILITY LOCATION.');
     Exit_Debug(l_module_name);
 END Fetch_Single_Facility_Info;

 -----------------------------------------------------------------------------
 -- PROCEDURE   Fetch_Facility_Descriptions
 --
 -- Purpose     Fetch company information and derive and cache the descriptions
 --             for all locations in WSH_LOCATIONS that are not already in
 --             FTE_LOCATION_PARAMETERS
 -- Parameters  None.
 -----------------------------------------------------------------------------
 PROCEDURE Fetch_Facility_Descriptions IS

   l_compNames           Index_Varchar100_Tbl_Type;
   l_compSites           Index_Varchar100_Tbl_Type;
   l_locIds              WSH_UTIL_CORE.Id_Tab_Type;
   l_company_types       Index_Varchar100_Tbl_Type;
   l_dates		 WSH_UTIL_CORE.Date_Tab_Type;
   l_locId               NUMBER;
   l_desc                VARCHAR2(100);
   l_locid_exists        BOOLEAN;

   l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'Fetch_Facility_Descriptions';

   --counters
   k                     NUMBER;
   m                     NUMBER;

   --Fetch company locations for all locations that exist in WSH_LOCATIONS
   --but NOT in FTE_LOCATION_PARAMETERS.
   --Note that this query is the same as the one in fetch_single_facility_info,
   --but without binding a location id. We order by date of creation, because
   --in the case of multiple sites for an organization, we only pick the
   --earliest one.
   CURSOR c_hzr_descriptions IS
    SELECT hou.name Company_Name,
           wl.wsh_location_id LocId,
           hou.name Site,
           hou.creation_date Cdate,
           'ORGANIZATION' Company_Type
      FROM wsh_locations wl, hr_organization_units hou,
           HR_ORGANIZATION_INFORMATION HOI1, MTL_PARAMETERS MP,fte_location_parameters flp
     WHERE wl.wsh_location_id = flp.location_id(+)
       AND flp.location_id IS NULL
       AND wl.location_source_code = 'HR'
       AND wl.source_location_id = hou.location_id
       AND HOU.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
    AND    HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
    AND    HOI1.ORG_INFORMATION1 = 'INV'
    AND    HOI1.ORG_INFORMATION2 = 'Y'
    AND    ( HOI1.ORG_INFORMATION_CONTEXT || '') = 'CLASS'
   UNION
    --CARRIER
    SELECT wc.carrier_name Company_Name,
           wl.wsh_location_id LocId,
           wc.carrier_name||'_'||nvl(hps.party_site_name,hps.party_site_number) Site,
           hps.creation_date cdate,
           'CARRIER' company_type
      FROM wsh_locations wl, hz_party_sites hps, wsh_carriers_v wc,
           fte_location_parameters flp
     WHERE wl.wsh_location_id = flp.location_id(+)
       AND flp.location_id IS NULL
       AND wl.location_source_code = 'HZ'
       AND wl.source_location_id = hps.location_id
       AND wc.active = 'A'
       AND hps.party_id = wc.carrier_id
      UNION
    --CUSTOMER
    SELECT hp.party_name Company_Name,
           wl.wsh_location_id LocId,
           hp.party_name||'_'||nvl(hps.party_site_name,hps.party_site_number) Site,
           hps.creation_date Cdate,
           'CUSTOMER' Company_Type
      FROM wsh_locations wl, hz_party_sites hps, hz_parties hp,
           hz_cust_acct_sites_all hcas, fte_location_parameters flp,
           wsh_location_owners wlo
     WHERE wl.wsh_location_id = flp.location_id(+)
       AND wl.wsh_location_id = wlo.wsh_location_id
       AND wlo.owner_type = 2
       AND wlo.owner_party_id = hp.party_id
       AND flp.location_id IS NULL
       AND wl.location_source_code = 'HZ'
       AND wl.source_location_id = hps.location_id
       AND hp.status='A'
       AND hps.party_id=hp.party_id
       AND hcas.party_site_id = hps.party_site_id
   UNION
     --SUPPLIER
     SELECT hp.party_name Company_Name,
            wl.wsh_location_id LocId,
            hp.party_name||'_'||nvl(hps.party_site_name,hps.party_site_number) Site,
            hps.creation_date Cdate, 'SUPPLIER' Company_Type
       FROM wsh_locations wl, po_vendors po, hz_relationships rel,
            hz_party_sites hps, hz_parties hp, fte_location_parameters flp
      WHERE wl.wsh_location_id = flp.location_id(+)
        AND flp.location_id IS NULL
        AND wl.source_location_id = hps.location_id
        AND hp.status='A'
        AND hps.party_id = hp.party_id
        AND rel.relationship_type = 'POS_VENDOR_PARTY'
        AND rel.object_id = hp.party_id
        AND rel.object_table_name = 'HZ_PARTIES'
        AND rel.object_type = 'ORGANIZATION'
        AND rel.subject_table_name = 'PO_VENDORS'
        AND rel.subject_id = po.vendor_id
        AND rel.subject_type = 'POS_VENDOR'
    ORDER BY locid, cdate;

 BEGIN
   Init_Debug(l_module_name);

   OPEN c_hzr_descriptions;
   FETCH c_hzr_descriptions
     BULK COLLECT INTO l_compNames, l_locIds, l_compSites, l_dates, l_company_types;
   CLOSE c_hzr_descriptions;

   IF (l_locIds.COUNT = 0) THEN
      RETURN;
   END IF;

   k := l_locIds.FIRST;
   LOOP
     l_locId := l_locIds(k);
     --If the location ID falls within the range of a binary integer,
     --then we can put it in a table indexed by the location id for
     --quicker reference.
     IF (Is_Binary_Integer(l_locId)) THEN
       l_desc := create_description(l_compNames(k), l_compSites(k));
       g_Facility_Descriptions(l_locId) := l_desc;

     --Otherwise we have to put in a non-indexed table, and search for
     --it "manually"
     ELSE
       l_locid_exists := FALSE;
       IF g_nonbinary_indices.EXISTS(1) THEN
         FOR m IN 1..g_nonbinary_indices.COUNT LOOP
           IF (g_nonbinary_indices(m) = l_locid) THEN
             l_desc := create_description(l_compNames(k), l_compSites(k));
             g_NonIndexed_Descriptions(m) := l_desc;
             l_locid_exists := TRUE;
             EXIT;  --It already exists
           END IF;
         END LOOP;
       END IF;

       IF (NOT l_locid_exists) THEN
         g_nonbinary_indices.EXTEND;
         g_Nonindexed_Descriptions.EXTEND;

         m := g_nonbinary_indices.COUNT;
         l_desc := create_description(l_compNames(k), l_compSites(k));
         g_nonbinary_indices(m)       := l_locid;
         g_Nonindexed_Descriptions(m) := l_desc;
       END IF;
     END IF;

     EXIT WHEN k = l_locIds.LAST;
     k := l_locIds.NEXT(k);
   END LOOP;


   g_cached := TRUE;
   Exit_Debug(l_module_name);
 EXCEPTION
   WHEN OTHERS THEN
    LogMsg(l_module_name, 'UNEXPECTED ERROR: ' || sqlerrm);
    Exit_Debug(l_module_name);
    RAISE;
 END Fetch_Facility_Descriptions;

 -----------------------------------------------------------------------------
 -- PROCEDURE   Get_Facility_Description
 --
 -- Purpose     Derive a description for a facility given its location ID
 --
 -- Parameters
 --      p_location_id   IN   NUMBER:  location ID of facility
 --
 -- Return
 --      The facility description.
 -----------------------------------------------------------------------------
 FUNCTION Get_Facility_Description(p_location_id   IN   NUMBER)
   RETURN VARCHAR2 IS

 l_module_name   CONSTANT VARCHAR2(100) := 'fte.plsql.'||G_PKG_NAME||'.Get_Facility_Description';
 l_debug_on               BOOLEAN;

 l_error_msg     VARCHAR2(250);
 l_description   VARCHAR2(250);
 l_company_name  VARCHAR2(100);
 l_site_name     VARCHAR2(100);

 BEGIN

   Init_Debug(l_module_name);
   logmsg(l_module_name, 'p_location_id', p_location_id);

   IF (g_names_exist) THEN

     l_company_name := g_company_names(g_cur_index);
     IF (g_site_names.EXISTS(g_cur_index)) THEN
       l_site_name  := g_site_names(g_cur_index);
     END IF;
     Exit_Debug(l_module_name);
     RETURN Create_Description(l_company_name, l_site_name);

   ELSIF (g_cache) THEN
      --derive and cache the descriptions if not already done.
      IF (NOT g_cached) THEN
        Fetch_Facility_Descriptions;
      END IF;

      IF (Is_Binary_Integer(p_location_id)) THEN
        Exit_Debug(l_module_name);
        RETURN g_Facility_Descriptions(p_location_id);
      ELSE
        --search the non-indexed tables for the description
        FOR n IN g_nonbinary_indices.FIRST .. g_nonbinary_indices.LAST LOOP
          IF (g_nonbinary_indices(n) = p_location_id) THEN
            Exit_Debug(l_module_name);
            RETURN g_Nonindexed_Descriptions(n);
          END IF;
        END LOOP;
      END IF;
   ELSE -- no caching: one-time query
     Fetch_Single_Facility_Info(p_location_id, l_description);
     Exit_Debug(l_module_name);
     RETURN l_description;
   END IF;

   Exit_Debug(l_module_name);
   RETURN NULL;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     l_error_msg := 'LOC ID '||p_location_id||' IS EITHER AN INVALID FACILITY LOCATION OR ALREADY';
     l_error_msg := l_error_msg || ' EXISTS IN FTE_LOCATION_PARAMETERS.';
     logmsg(l_module_name, l_error_msg);
     Exit_Debug(l_module_name);
     RETURN NULL;
   WHEN OTHERS THEN
     logmsg(l_module_name, 'UNEXPECTED ERROR. => ' || sqlerrm);
     Exit_Debug(l_module_name);
     RAISE;
 END Get_Facility_Description;

 -----------------------------------------------------------------------------------
 -- Start of comments
 -- API name : Create_Facilities
 -- Type     : Private
 -- Pre-reqs : None.
 -- Function : 1. Create a new facility (row in FTE_LOCATION_PARAMETERS) for each
 --               location id specified in the input table p_location_ids.
 --               NOTE: It is recommended, but not required, to pass in the corresponding
 --                  <p_company_names> and <p_site_names>.
 --                  (a). If both <p_company_names> and <p_site_names> are not empty
 --                       the facility codes are generated from a combination of
 --                       the location's company_name and site_name. (See function
 --                       Create_Description)
 --                  (b). If the <p_company_names> is NOT empty but <p_site_names> is
 --                       empty, the facility codes are derived from the company names.
 --                  (c). If both <p_company_names> AND <p_site_names> are empty,
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
 --                   ii.  WSH_UTIL_CORE.G_RET_STS_WARNING: If some of the location_ids
 --                        already had facilities created.
 --                   iii.  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
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

   CURSOR get_location_owner(c_location_id IN NUMBER) IS
   SELECT owner_type
   FROM   wsh_location_owners
   WHERE  wsh_location_id = c_location_id
   AND    rownum = 1;

   CURSOR get_uom_class(c_uom_code IN VARCHAR2) IS
   SELECT uom_class
   FROM   mtl_units_of_measure_vl
   WHERE  uom_code = c_uom_code;

   l_module_name     CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.CREATE_FACILITIES';
   l_debug_on                 BOOLEAN;

   l_facility_codes           Index_Varchar100_Tbl_Type;
   l_facility_descriptions    Index_Varchar100_Tbl_Type;
   l_loc_id                   NUMBER;
   l_facility_Description     VARCHAR2(200);

   l_start                    NUMBER;
   l_error_code               NUMBER;
   --l_userId                 NUMBER := FND_GLOBAL.USER_ID;
   l_userId                   NUMBER := 123456;
   l_msg_count                VARCHAR2(10);

   -- TP Global Attribute
   l_NPall_Loading_Rate      NUMBER       := NULL;
   l_NPall_Unloading_Rate    NUMBER       := NULL;
   l_NPall_Handling_Uom      VARCHAR2(30) := NULL;
   l_Pall_Loading_Rate       NUMBER       := NULL;
   l_Pall_Unloading_Rate     NUMBER       := NULL;
   l_Pall_Handling_Uom       VARCHAR2(30) := NULL;
   l_loadUnload_Time_Uom     VARCHAR2(30) := NULL;
   l_flow_thru_time          NUMBER       := NULL;
   l_flow_thru_time_uom      VARCHAR2(3)  := NULL;
   l_Pall_Handling_type      VARCHAR2(30) := NULL;
   l_NPall_Handling_type     VARCHAR2(30) := NULL;


   l_mvmt_required           VARCHAR2(15) := 'NEITHER';
   l_loadUnload_Protocol     VARCHAR2(15) := 'JOINT';
   l_private_residence       VARCHAR2(1)  := 'N';

   l_owner_type              NUMBER;
   l_include_mileage_flag    Index_Varchar100_Tbl_Type;
   l_Param_Info              WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
   l_return_status           VARCHAR2(1);
   l_api_version             NUMBER := 1.0;
   l_sql_str                 VARCHAR2(3000);

   --counters
   k                         NUMBER;
   l                         NUMBER;
   m                         NUMBER;
 BEGIN
   Init_Debug(l_module_name);

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   g_dup_locations := STRINGARRAY();

   --Ensure that the company_names and location_id tables are the same length;
   IF (p_company_names.COUNT <> p_location_ids.COUNT) THEN
      x_error_msg := 'PROGRAMMER ERROR?: <p_company_names> IS NOT THE SAME LENGTH AS';
      x_error_msg := x_error_msg || ' <p_location_ids>. Reverting to query';
      LogMsg(l_module_name, x_error_msg);
      g_names_exist := FALSE;
   ELSE
      LogMsg(l_module_name, 'Using Company Names Passed To Procedure ...');
      g_company_names := p_company_names;
      g_site_names    := p_site_names;
      g_names_exist   := TRUE;
   END IF;

   -- Get Facility default processing Attributes from
   -- WSH global
   WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(
         x_Param_Info       =>    l_Param_Info,
         x_return_status    =>    l_return_status );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   END IF;

   l_LoadUnload_Time_Uom := l_param_info.Time_Uom;

   --Get TP Global Attributes from TP Global Preferences
   IF (WSH_UTIL_CORE.Tp_Is_Installed = 'Y') THEN
    LogMsg(l_module_name, 'Calling TP API to Obtain Global Parameters');

    BEGIN
     l_sql_str := 'BEGIN
                    MST_GEOCODING.Get_facility_parameters(
                        p_api_version             => :1,
                        p_init_msg_list           => :2,
                        x_pallet_load_rate        => :3,
                        x_pallet_unload_rate      => :4,
                        x_non_pallet_load_rate    => :5,
                        x_non_pallet_unload_rate  => :6,
                        x_pallet_handling_uom     => :7,
                        x_non_pallet_handling_uom => :8,
                        x_return_status           => :9,
                        x_msg_count               => :10,
                        x_msg_data                => :11);
                   END;';

     LogMsg(l_module_name, l_sql_str);

     EXECUTE IMMEDIATE l_sql_str
      USING IN  l_api_version,
            IN  l_api_version,
           OUT  l_pall_loading_rate,
           OUT  l_pall_unloading_rate,
           OUT  l_NPall_loading_rate,
           OUT  l_NPall_unloading_rate,
           OUT  l_pall_handling_uom,
           OUT  l_NPall_handling_uom,
           OUT  x_return_status,
           OUT  l_msg_count,
           OUT  x_error_msg;

     IF (x_error_msg IS NOT NULL AND l_msg_count > 0) THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       RETURN;
     END IF;

    IF (l_pall_handling_uom = 'CONTAINER' OR l_pall_handling_uom = 'PALLET') THEN
       l_Pall_Handling_type := l_pall_handling_uom;
     ELSE
       OPEN get_uom_class(l_pall_handling_uom);
       FETCH get_uom_class INTO l_Pall_Handling_type;
       CLOSE get_uom_class;
     END IF;

     IF (l_NPall_handling_uom = 'CONTAINER' OR l_NPall_handling_uom = 'PALLET') THEN
       l_NPall_Handling_type := l_NPall_handling_uom;
     ELSE
       OPEN get_uom_class(l_NPall_handling_uom);
       FETCH get_uom_class INTO l_NPall_Handling_type;
       CLOSE get_uom_class;
     END IF;

    IF l_debug_on THEN
       WSH_DEBUG_SV.Log(l_module_name, 'l_pall_loading_rate', l_pall_loading_rate);
       WSH_DEBUG_SV.Log(l_module_name, 'l_pall_unloading_rate', l_pall_unloading_rate);
       WSH_DEBUG_SV.Log(l_module_name, 'l_pall_handling_uom', l_pall_handling_uom);
       WSH_DEBUG_SV.Log(l_module_name, 'l_NPall_loading_rate', l_NPall_loading_rate);
       WSH_DEBUG_SV.Log(l_module_name, 'l_NPall_unloading_rate', l_NPall_unloading_rate);
       WSH_DEBUG_SV.Log(l_module_name, 'l_NPall_handling_uom', l_NPall_handling_uom);
       WSH_DEBUG_SV.Log(l_module_name, 'l_Pall_Handling_type', l_Pall_Handling_type);
       WSH_DEBUG_SV.Log(l_module_name, 'l_NPall_Handling_type', l_NPall_Handling_type);
     END IF;

    EXCEPTION
      WHEN OTHERS THEN
        LogMsg(l_module_name, 'MST INTEGRATION CALL ERROR : ' || SQLERRM);
    END;
   END IF;

   --Derive Facility Attributes (Description, Facility Code)
   g_cur_index := p_location_ids.FIRST;
   LOOP

     l_loc_id := p_location_ids(g_cur_index);
     l_facility_description := Get_Facility_Description(l_loc_id);

     IF l_facility_description IS NULL THEN
        --To prevent null value exceptions during insertion, we generate
        --descriptions for locations with no company information.
        --These facilities are deleted later
        l_facility_description := 'BAD_FACILITY_DELETE_' || l_loc_id;
     END IF;

     l_facility_descriptions(g_cur_index) := l_facility_description;
     l_facility_codes(g_cur_index) := l_facility_description;

     -- Derive mileage_flag for a location depending on company type
     -- from WSH global parameters
     -- use wsh_location_owners to get the location company type
     l_include_mileage_flag(g_cur_index) :=  'N';

     OPEN get_location_owner(l_loc_id);
     FETCH get_location_owner INTO l_owner_type;
     CLOSE get_location_owner;

     -- 1=Organization,2=Customer,3=Carrier,4=Supplier
     IF l_owner_type = 1 THEN
        -- Organization
        l_include_mileage_flag(g_cur_index) := nvl(l_Param_Info.DEF_MILE_CALC_ON_ORG_FAC,'N');
     ELSIF l_owner_type = 2 THEN
        -- Customer
        l_include_mileage_flag(g_cur_index) := nvl(l_Param_Info.DEF_MILE_CALC_ON_CUST_FAC,'N');
     ELSIF l_owner_type = 3 THEN
        -- Carrier
        l_include_mileage_flag(g_cur_index) := nvl(l_Param_Info.DEF_MILE_CALC_ON_CARR_FAC,'N');
     ELSIF l_owner_type = 4 THEN
        -- Supplier
        l_include_mileage_flag(g_cur_index) := nvl(l_Param_Info.DEF_MILE_CALC_ON_SUPP_FAC,'N');
     END IF;

     logMsg(l_module_name, 'Facility Code', l_facility_codes(g_cur_index));
     logMsg(l_module_name, 'Facility Description', l_facility_descriptions(g_cur_index));

     EXIT WHEN g_cur_index = p_location_ids.LAST;
     g_cur_index := p_location_ids.NEXT(g_cur_index);

   END LOOP;

   --Insert into the Fte_Location_Parameters Table
   logmsg(l_Module_name, 'Inserting Facilities into FTE_LOCATION_PARAMETERS...');

   BEGIN
    l_start := p_location_ids.FIRST;

    LOOP
      BEGIN
 	FORALL k IN l_start..p_location_ids.LAST
 	 INSERT INTO fte_location_parameters (
 			  FACILITY_ID,
 			  FACILITY_CODE,
 			  LOCATION_ID,
 			  DESCRIPTION,
 			  CONSOLIDATION_ALLOWED,
 			  DECONSOLIDATION_ALLOWED,
 			  CROSSDOCKING_ALLOWED,
 			  PARCEL_LTL_CONSOLIDATION,
 			  PARCEL_TL_CONSOLIDATION,
 			  LTL_TL_CONSOLIDATION,
 			  LTL_LTL_CONSOLIDATION,
 			  LTL_PARCEL_DECONSOLIDATION,
 			  TL_PARCEL_DECONSOLIDATION,
 			  TL_LTL_DECONSOLIDATION,
 			  LTL_LTL_DECONSOLIDATION,
 			  PARCEL_INBOUND_CROSSDOCKING,
 			  LTL_INBOUND_CROSSDOCKING,
 			  TL_INBOUND_CROSSDOCKING,
 			  PARCEL_OUTBOUND_CROSSDOCKING,
 			  LTL_OUTBOUND_CROSSDOCKING,
 			  TL_OUTBOUND_CROSSDOCKING,
 			  STORAGE_FACILITY,
 			  CARRIER_OWNED_HAUL,
 			  FLOW_THROUGH_TIME,
 			  FLOW_THROUGH_TIME_UOM,
 			  NON_ADJACENT_LOADING,
 			  NON_ADJACENT_UNLOADING,
 			  MODIFIER_LIST,
 			  HANDLE_STACKED_PALLETS,
 			  NONPALLETIZED_LOADING_RATE,
 			  NONPALLETIZED_UNLOADING_RATE,
 			  NONPALLETIZED_HANDLING_UOM,
 			  NONPALLETIZED_HANDLING_TYPE,
 			  PALLETIZED_LOADING_RATE,
 			  PALLETIZED_UNLOADING_RATE,
 			  PALLETIZED_HANDLING_UOM,
 			  PALLETIZED_HANDLING_TYPE,
 			  LOAD_UNLOAD_TIME_UOM,
 			  PRIVATE_RESIDENCE,
 			  CREATION_DATE,
 			  CREATED_BY,
 			  LAST_UPDATE_DATE,
 			  LAST_UPDATED_BY,
 			  EFFECTIVE_DATE_FROM,
 			  LOAD_UNLOAD_PROTOCOL,
 			  INCLUDE_MILEAGE_FLAG)
 		 VALUES (
 			  fte_location_parameters_s.nextval,-- FACILITY_ID
 			  l_facility_codes(k),              -- FACILITY_CODE
 			  p_location_ids(k),                -- LOCATION_ID
 			  l_facility_descriptions(k),       -- DESCRIPTION
 			  'N',                              -- CONSOLIDATION_ALLOWED
 			  'N',                              -- DECONSOLIDATION_ALLOWED
 			  'N',                              -- CROSSDOCKING_ALLOWED
 			  'N',                              -- PARCEL_LTL_CONSOLIDATION
 			  'N',                              -- PARCEL_TL_CONSOLIDATION
 			  'N',                              -- LTL_TL_CONSOLIDATION
 			  'N',                              -- LTL_LTL_CONSOLIDATION
 			  'N',                              -- LTL_PARCEL_DECONSOLIDATION
 			  'N',                              -- TL_PARCEL_DECONSOLIDATION
 			  'N',                              -- TL_LTL_DECONSOLIDATION
 			  'N',                              -- LTL_LTL_DECONSOLIDATION
 			  'N',                              -- PARCEL_INBOUND_CROSSDOCKING
 			  'N',                              -- LTL_INBOUND_CROSSDOCKING
 			  'N',                              -- TL_INBOUND_CROSSDOCKING
 			  'N',                              -- PARCEL_OUTBOUND_CROSSDOCKING
 			  'N',                              -- LTL_OUTBOUND_CROSSDOCKING
 			  'N',                              -- TL_OUTBOUND_CROSSDOCKING
 			  'N',                              -- STORAGE_FACILITY
 			  'NEITHER',                        -- CARRIER_OWNED_HAUL
 			   l_flow_thru_time,                -- FLOW_THROUGH_TIME
 			   l_flow_thru_time_uom,            -- FLOW_THROUGH_TIME_UOM
 			  'N',                              -- NON_ADJACENT_LOADING
 			  'N',                              -- NON_ADJACENT_UNLOADING
 			   NULL,                            -- MODIFIER_LIST
 			  'Y',                              -- HANDLE_STACKED_PALLETS
 			  l_NPall_Loading_Rate,             -- NONPALLETIZED_LOADING_RATE
 			  l_NPall_Unloading_Rate,           -- NONPALLETIZED_UNLOADING_RATE
 			  l_NPall_Handling_Uom,             -- NONPALLETIZED_HANDLING_UOM
 			  l_NPall_Handling_type,            -- NONPALLETIZED_HANDLING_TYPE
 			  l_Pall_Loading_Rate,              -- PALLETIZED_LOADING_RATE
 			  l_Pall_Unloading_Rate,            -- PALLETIZED_UNLOADING_RATE
 			  l_Pall_Handling_Uom,              -- PALLETIZED_HANDLING_UOM
 			  l_Pall_Handling_type,             -- PALLETIZED_HANDLING_TYPE
 			  l_loadUnload_Time_Uom,            -- LOAD_UNLOAD_TIME_UOM
 			  l_private_residence,              -- PRIVATE_RESIDENCE
 			  sysdate,                          -- CREATION_DATE
 			  l_userId,                         -- CREATED_BY
 			  sysdate,                          -- LAST_UPDATE_DATE
 			  l_userId,                         -- LAST_UPDATED_BY
 			  sysdate,                          -- EFFECTIVE_DATE_FROM
 			  l_loadUnload_Protocol,            -- LOAD_UNLOAD_PROTOCOL
 			  l_include_mileage_flag(k));       --INCLUDE_MILEAGE_FLAG

 	EXIT; --exit the infinite loop
      EXCEPTION
 	WHEN OTHERS THEN
         l_error_code := SQLCODE;
           --ORA:00001 is the unique constraint violation. We are attempting
           --to insert a facility that already exists.
 	 IF (l_error_code = -1) THEN
 	   g_dup_locations.EXTEND;
 	   g_dup_locations(g_dup_locations.COUNT) := p_location_ids(l_start + sql%rowcount);
 	   l_start := l_start + sql%rowcount + 1;
 	 ELSE
	   x_error_msg := 'UNEXP. ERROR WHILE CREATING FACILITY FOR LOCATION ' || p_location_ids(l_start + sql%rowcount);
 	   x_error_msg := x_error_msg || ' => ' || SQLERRM;
 	   LogMsg(l_module_name, x_error_msg);
 	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	   Exit_Debug(l_module_name);
 	   RETURN;
         END IF;
      END;
    END LOOP;
   END;

   logMsg(l_module_name, 'Finished Inserting Facilities ');

   k := p_location_ids.COUNT - g_dup_locations.COUNT;

 -- Delete Facilities which are for dummy locations
    BEGIN
         DELETE FROM FTE_LOCATION_PARAMETERS
         WHERE location_id IN (
	   SELECT   wl.wsh_location_id WSH_LOCATION_ID
	   FROM hz_party_sites hps,
	      hz_cust_acct_sites_all hcas,
	      hz_cust_site_uses_all hcsu, po_location_associations_all pla,
	      wsh_locations wl
	   WHERE pla.customer_id = hcas.cust_account_id
	   AND pla.site_use_id = hcsu.site_use_id
	   AND hcsu.cust_acct_site_id = hcas.cust_acct_site_id
	   AND hcas.party_site_id = hps.party_site_id
	   AND hps.location_id = wl.source_location_id
	   AND wl.location_source_code = 'HZ'
	 );
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
       WHEN OTHERS THEN
         x_error_msg := 'UNEXPECTED ERROR WHILE DELETING CUSTOMER DUMMY FACILITIES ' || sqlerrm;
         LogMsg(l_module_name, x_error_msg);
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   END;

   m := SQL%ROWCOUNT;
   k := k - m;

   --Now delete the bad facilities (Those that had no valid companies)
   BEGIN
     DELETE FROM FTE_LOCATION_PARAMETERS
     WHERE Description LIKE 'BAD_FACILITY_DELETE%';
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       x_error_msg := 'UNEXPECTED ERROR WHILE DELETING BAD FACILITIES ' || sqlerrm;
       LogMsg(l_module_name, x_error_msg);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   END;

   l := SQL%ROWCOUNT;
   k := k - l;

   -- ************************** ERROR REPORTING ************************************
   x_error_msg := 'Successfully inserted '||k||' facilities ';
   x_error_msg := x_error_msg || 'into FTE_LOCATION_PARAMETERS';
   logmsg(l_module_name, x_error_msg);
   Fnd_File.Put_Line(Fnd_File.output, x_error_msg);

   IF (l > 0) THEN
     x_error_msg := 'Could not create ' || l || ' facilities because they are invalid as facility locations.';
     LogMsg(l_module_name, x_error_msg );
   END IF;

   IF (m > 0) THEN
     x_error_msg := 'Could not create ' || m || ' facilities because they are dummy customer locations.';
     LogMsg(l_module_name, x_error_msg );
   END IF;

   --Report the location IDs that already exist and set return status to warning
   IF (g_dup_locations.COUNT > 0 ) THEN
     LogMsg(l_module_name, '***************************************************************');
     Fnd_File.Put_Line(Fnd_File.output, '***************************************************************');

     LogMsg(l_module_name, '* THE FACILITIES WITH THE FOLLOWING LOCATION IDS ALREADY EXIST');
     Fnd_File.Put_Line(Fnd_File.output, '* THE FACILITIES WITH THE FOLLOWING LOCATION IDS ALREADY EXIST');

     FOR i IN g_dup_locations.FIRST..g_dup_locations.LAST LOOP
       LogMsg(l_module_name, '* ' || i || '.  Location ID ' || g_dup_locations(i));
       Fnd_File.Put_Line(Fnd_File.output, '* ' || i || '.  Location ID ' || g_dup_locations(i));
     END LOOP;
     LogMsg(l_module_name, '***************************************************************');
     Fnd_File.Put_Line(Fnd_File.output, '***************************************************************');

     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       x_error_msg := 'Some facilities already exist. Please check log file for details';
       Fnd_File.Put_Line(Fnd_File.output,
                         'WARNING: Some facilities already exist. Please check log file for details');
     END IF;
   END IF;

   -- ************************** ERROR REPORTING ************************************

   Reset_All;
   IF l_debug_on THEN
     IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
        WSH_DEBUG_SV.pop(x_Module  => l_module_name,
                         x_Context => 'EXCEPTION:OTHERS');
     ELSE
        Exit_Debug(l_module_name);
     END IF;
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
    x_error_msg := 'UNEXPECTED ERROR ' || sqlerrm;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    LogMsg(l_module_name, x_error_msg);

    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(x_Module  => l_module_name,
                        x_Context => 'EXCEPTION:OTHERS');
    END IF;
 END Create_Facilities;

 -----------------------------------------------------------------------------------
 -- Start of comments
 -- API name : Create_Facility
 -- Type     : Private
 -- Pre-reqs : None.
 -- Function : Create a new facility (row in FTE_LOCATION_PARAMETERS).
 --            Note: To create more than one facility, it might be more
 --            efficient to call Create_Facilities since this procedure
 --            does not cache common queried information from previous calls.
 -- Parameters :
 -- IN:   p_location_id    IN   NUMBER   Required
 --          The location id for the facility.
 --       p_facility_code  IN   VARCHAR2  Optional
 --          The facility code for this facility. If null, it will be automatically
 --          generated from the company name and site name.
 --
 -- OUT:  x_return_status    OUT  NOCOPY  VARCHAR2
 --          The return status is one of the following:
 --          i.   WSH_UTIL_CORE.G_RET_STS_SUCCESS: Facility created successfully
 --          iv.  WSH_UTIL_CORE.G_RET_STS_WARNING: If facility already exists.
 --          iv.  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
 --       x_error_msg        OUT  NOCOPY  VARCHAR2
 --          The error message
 -- Version : 1.0
 -- Previous version 1.0
 -- Initial version 1.0
 -- End of comments
 -----------------------------------------------------------------------------------
 PROCEDURE Create_Facility (p_location_id   IN   NUMBER,
                            p_facility_code IN   VARCHAR2  default  NULL,
                            x_return_status OUT  NOCOPY  VARCHAR2,
                            x_error_msg     OUT  NOCOPY  VARCHAR2) IS

  l_module_name        CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.CREATE_FACILITY';
  l_debug_on           BOOLEAN;
  l_location_id_tab    WSH_LOCATIONS_PKG.ID_Tbl_Type;
  l_site_names         WSH_LOCATIONS_PKG.LocationCode_Tbl_Type;
  l_company_names      WSH_LOCATIONS_PKG.Address_Tbl_Type;

  BEGIN
    Init_Debug(l_module_name);

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    g_cache := FALSE;

    --Create an ID table with a single entry and call Create_Facilities
    l_location_id_tab(1) := p_location_id;

    logmsg(l_module_name, 'Calling Create_Facilities');
    logmsg(l_module_name, 'p_location_id', l_location_id_tab(1));

    Create_Facilities( p_location_ids  => l_location_id_tab,
                       p_company_names => l_company_names,
                       p_site_names    => l_site_names,
                       x_return_status => x_return_status,
                       x_error_msg     => x_error_msg);

    --Update with the facility code, if it was supplied.
    IF (p_facility_code IS NOT NULL AND
        x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      BEGIN
        UPDATE fte_location_parameters
        SET    facility_code = p_facility_code
        WHERE  location_id   = p_location_id;
      EXCEPTION
        WHEN OTHERS THEN
         x_error_msg := ('UNEXPECTED ERROR AFTER CREATING FACILITY: ' || sqlerrm);
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         LogMsg(l_module_name, x_error_msg);
      END;
    END IF;

   IF l_debug_on THEN
     IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
       WSH_DEBUG_SV.pop(x_Module  => l_module_name,
                        x_Context => 'EXCEPTION:OTHERS');
     ELSE
       Exit_Debug(l_module_name);
     END IF;
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
    LogMsg(l_module_name, 'UNEXPECTED ERROR: ' || sqlerrm);

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(x_Module  => l_module_name,
                       x_Context => 'EXCEPTION:OTHERS');
    END IF;
 END Create_Facility;

 -----------------------------------------------------------------------------------
 -- Start of comments
 -- API name : Get_Fac_Info
 -- Type     : Public
 -- Pre-reqs : None.
 -- Function : Return Information about a Facility
 --
 -- Parameters :
 -- IN:
 --
 -- IN OUT:  x_fac_info_rows  Tl_Fac_Info_Tab_Type
 --                  The location_id  attribute of each record in x_fac_info_rows must be
 --                  populated. X_fac_info_rows is returned with information about the
 --                  facility.
 --
 -- OUT:     x_return_status  VARCHAR2
 --
 -- Version : 1.0
 -- Previous version 1.0
 -- Initial version 1.0
 -- End of comments
 -----------------------------------------------------------------------------------
 PROCEDURE Get_Fac_Info (x_fac_info_rows IN  OUT  NOCOPY Tl_Fac_Info_Tab_Type,
                         x_return_status     OUT  NOCOPY VARCHAR2) IS

  l_location_id           NUMBER;

  fac_currency            VARCHAR2(30);
  fac_pricelist_id        NUMBER;

  x_error_msg             VARCHAR2(4000);
  l_charge_basis          VARCHAR2(50);
  l_charge_basis_uom      VARCHAR2(30);
  l_error_code            NUMBER;
  k                       NUMBER;

  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'Get_Fac_Info';

 BEGIN
    Init_Debug(l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    k := x_fac_info_rows.FIRST;
    LOOP
     l_location_id := x_fac_info_rows(k).location_id;

     BEGIN
      SELECT fl.facility_code facility_code,
             fl.load_unload_protocol load_unload_protocol,
             fl.modifier_list modifier_id,
             prc_rc_id.value_from pricelist_id,
             prc_cbasis.value_from charge_basis,
             prc_cbasis_uom.value_from charge_basis_uom,
             prc_currency.value_from currency_code
      INTO   x_fac_info_rows(k).fac_code,
             x_fac_info_rows(k).loading_protocol,
             x_fac_info_rows(k).fac_modifier_id,
             x_fac_info_rows(k).fac_pricelist_id,
             l_charge_basis,
             l_charge_basis_uom,
             x_fac_info_rows(k).fac_currency
        FROM fte_location_parameters fl,
             fte_prc_parameters prc_cbasis,
             fte_prc_parameters prc_cbasis_uom,
             fte_prc_parameters prc_currency,
             fte_prc_parameters prc_rc_id
       WHERE fl.location_id = x_fac_info_rows(k).location_id
         AND prc_cbasis.list_header_id(+)    = fl.modifier_list
         AND prc_cbasis_uom.list_header_id(+)= fl.modifier_list
         AND prc_currency.list_header_id(+)  = fl.modifier_list
         AND prc_rc_id.list_header_id(+)     = fl.modifier_list
         AND prc_cbasis.parameter_id(+) = 57
         AND prc_cbasis_uom.parameter_id(+) = 58
         AND prc_rc_id.parameter_id (+)= 59
         AND prc_currency.parameter_id(+) = 60;

      --Set the charge basis uom accordingly
       IF (upper(l_charge_basis) = 'VOLUME') THEN
         x_fac_info_rows(k).fac_volume_uom := l_charge_basis_uom;
       ELSIF (upper(l_charge_basis) = 'WEIGHT') THEN
         x_fac_info_rows(k).fac_weight_uom := l_charge_basis_uom;
       END IF;

       x_fac_info_rows(k).fac_charge_basis := l_charge_basis;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        x_error_msg := 'Location ID ' || l_location_id || ' does not exist';
        LogMsg(l_module_name, x_error_msg);
       WHEN OTHERS THEN
        x_error_msg := 'UNEXPECTED ERROR WHILE GETTING FACILITY INFO ';
        x_error_msg := x_error_msg || 'for location ID ' || l_location_id;
        LogMsg(l_module_name, x_error_msg);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        Exit_Debug(l_module_name);
        RETURN;
     END;

     EXIT WHEN k = x_fac_info_rows.LAST;
     k := x_fac_info_rows.NEXT(k);

    END LOOP;
    Exit_Debug(l_module_name);
 EXCEPTION
   WHEN OTHERS THEN
    x_error_msg := 'UNEXPECTED ERROR: ' || sqlerrm;
    Exit_Debug(l_module_name);
 END Get_Fac_Info;

 -----------------------------------------------------------------------------------
 -- Start of comments
 -- API name : Get_Fac_Lat_Long_and_TimeZone
 -- Type     : Public
 -- Pre-reqs : None.
 -- Function : Return Information about Latitude, Longitude,Timezone,Geometry of a Facility
 --		given the address attributes
 -- Parameters :
 -- IN:   p_country VARCHAR2
 --	  p_city VARCHAR2
 --	  p_postalcode VARCHAR2
 --	  p_state VARCHAR2
 --	  p_county VARCHAR2
 --	  p_province VARCHAR2
 --
 --
 -- OUT:  x_return_status VARCHAR2
 --	  x_msg_count VARCHAR2
 --	  x_msg_data VARCHAR2
 --	  x_latitude NUMBER
 --	  x_longitude NUMBER
 --	  x_timezone VARCHAR2
 --	  x_geometry MDSYS.SDO_GEOMETRY
 --
 -- Version : 1.0
 -- Previous version 1.0
 -- Initial version 1.0
 -- End of comments
 -----------------------------------------------------------------------------------

PROCEDURE Get_Fac_Lat_Long_and_TimeZone(p_country IN VARCHAR2,
			p_city IN VARCHAR2,
			p_postalcode IN VARCHAR2,
			p_state IN VARCHAR2,
			p_county IN VARCHAR2,
			p_province IN VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count OUT NOCOPY VARCHAR2,
			x_msg_data OUT NOCOPY VARCHAR2,
			x_latitude OUT NOCOPY VARCHAR2,
			x_longitude OUT NOCOPY VARCHAR2,
			x_timezone OUT NOCOPY VARCHAR2,
			x_geometry OUT NOCOPY MDSYS.SDO_GEOMETRY
			) is

l_location WSH_LOCATIONS_PKG.LOCATION_REC_TYPE;
x_error_msg VARCHAR2(100);
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'Get_Fac_Lat_Long_and_TimeZone';
BEGIN
	l_location.COUNTRY       := p_country;
	l_location.STATE         := p_state;
	l_location.CITY          := p_city;
	l_location.POSTAL_CODE   := p_postalcode;
	l_location.COUNTY	 := p_county;
	l_location.PROVINCE	 := p_province;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_data := NULL;
	WSH_GEOCODING.Get_Lat_Long_and_TimeZone(p_api_version   => 1.0,
                                              p_init_msg_list => NULL,
                                              x_return_status => x_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data,
                                              l_location      => l_location);

	x_latitude := to_char(l_location.LATITUDE);
	x_longitude := to_char(l_location.LONGITUDE);
	x_timezone := l_location.TIMEZONE_CODE;
	x_geometry := l_location.GEOMETRY;

	IF (x_return_status IS NULL) THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;

     EXCEPTION
        WHEN OTHERS THEN
        x_error_msg := 'UNEXPECTED ERROR WHILE GETTING LATITUDE, LONGITUDE,TIMEZONE, GEOMETRY INFO ';
        LogMsg(l_module_name, x_error_msg);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        Exit_Debug(l_module_name);
        RETURN;

END Get_Fac_Lat_Long_and_TimeZone;

END FTE_LOCATION_PARAMETERS_PKG;


/
