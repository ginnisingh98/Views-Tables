--------------------------------------------------------
--  DDL for Package Body FTE_ACS_RULE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_ACS_RULE_UTIL_PKG" AS
/* $Header: FTEACSXB.pls 120.3 2005/07/14 22:47:52 alksharm noship $ */
-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:        FTE_ACS_RULE_UTIL_PKG                                        --
-- TYPE:        PACKAGE BODY                                                  --
-- DESCRIPTION: Contains utility procedures for carrier selection module      --
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2002/02/04  H        ABLUNDEL           Created.                           --
--                                                                            --
-- 2002/04/15  H        ABLUNDEL  2322867  Changed the location cursor to     --
--                                         get info from wsh_hr_locations_v   --
--                                         instead of hz_locations            --
--                                                                            --
-- 2002/04/15  H        ABLUNDEL  2322867  changed the cursor in insert_temp_ --
--                                         table procedure to check for LIKE  --
--                                         from and to regions as the atribute--
--                                         FROM_REGION_ID is not stored       --
--                                                                            --
-- 2002/04/24  H        ABLUNDEL  2338937  PROCEDURE: UPDATE_REGION_INFO      --
--                                         changed the cursor in update_region--
--                                         _info procedure to check for LIKE  --
--                                         from and to regions as the atribute--
--                                         FROM_REGION_ID is not stored       --
--                                                                            --
-- 2002/04/30  H        ABLUNDEL  2345069  PROCEDURE: UPDATE_REGION_INFO      --
--                                         added a check to make sure that the--
--                                         regions table coming back has at   --
--                                         least one record - was causing an  --
--                                         unexpected error                   --
--                                                                            --
-- 2002/06/11  POST H   ABLUNDEL  -------  Made code more generic and made    --
--                                         performance changes                --
--                                                                            --
-- 2003/01/02  I        DEHSU     2734094  PROCEDURE: PROCESS_TEMP_DATA       --
--                                         to check for zones use region_type --
--                                         instead of zone_level              --
--                                                                            --
-- 2003/01/09  I        ABLUNDEL  2733856  PROCEDURE: INSERT_TEMP_DATA        --
--                                         added debug messages to show the   --
--                                         data being added into the global   --
--                                         temp table.                        --
--                                         PROCEDURE: PROCESS_TEMP_DATA       --
--                                         After the from zip code is returned--
--                                         in a cached situation the to_zip   --
--                                         value was being ignored and the    --
--                                         from zip value was inserted into   --
--                                         the global temp table in the value --
--                                         for the to-zip, thus this was      --
--                                         causing the first pass to work, but--
--                                         the second pass would not. added   --
--                                         a reset of l_zip_code after getting--
--                                         the from_zip value                 --
--                                                                            --
--                                                                            --
-- 2003/02/10  I        ABLUNDEL  2742257  PROCEDURE: PROCESS_TEMP_DATA       --
--                                         modified the code to return back   --
--                                         a transit time even if a transit   --
--                                         time value has been passed in.     --
--                                                                            --
-- 2003/01/20  I        ABLUNDEL  2759845  PROCEDURE: GET_LOCATION_DATA       --
--                                         replaced the two location cursors  --
--                                         to use WSH_LOCATIONS_V             --
--                                                                            --
-- 2003/01/21  I        ABLUNDEL  2761503  PROCEDURE: PROCESS_TEMP_DATA       --
--                                         PROCEDURE: GET_LOCATION_DATA       --
--                                         FUNCTION:  COMPARE_REGION_TYPES    --
--                                         FUNCTION:  GET_OBJECT_ID           --
--                                         FUNCTION:  DERIVE_LEAD_TIME        --
--                                         In the exception handlers added    --
--                                         code to check if all cursors are   --
--                                         closed - if not close them         --
--                                                                            --
-- 2003/02/21  I        ABLUNDEL  2807908  PROCEDURE: PROCESS_TEMP_DATA       --
--                                         Modified code for transit time     --
--                                         processing to do generic T-Time    --
--                                         value if T-Time is <1, 0 or null   --
--                                                                            --
-- -------------------------------------------------------------------------- --

--
--R12 Enhancement
--
TYPE fte_cs_bulk_entity_gtt IS RECORD(  delivery_id_tab			WSH_UTIL_CORE.ID_TAB_TYPE,
				        trip_id_tab			WSH_UTIL_CORE.ID_TAB_TYPE,
				        delivery_name_tab		WSH_UTIL_CORE.COLUMN_TAB_TYPE,
					trip_name_tab			WSH_UTIL_CORE.COLUMN_TAB_TYPE,
					organization_id_tab		WSH_UTIL_CORE.ID_TAB_TYPE,
					triporigin_internal_org_id_tab	WSH_UTIL_CORE.ID_TAB_TYPE,
					customer_id_tab	                WSH_UTIL_CORE.ID_TAB_TYPE,
					customer_site_id_tab	        WSH_UTIL_CORE.ID_TAB_TYPE,
					gross_weight_tab		WSH_UTIL_CORE.ID_TAB_TYPE,
					weight_uom_code_tab	        WSH_UTIL_CORE.COLUMN_TAB_TYPE,
					volume_tab			WSH_UTIL_CORE.ID_TAB_TYPE,
					volume_uom_code_tab	        WSH_UTIL_CORE.COLUMN_TAB_TYPE,
					initial_pickup_loc_id_tab	WSH_UTIL_CORE.ID_TAB_TYPE,
					ultimate_dropoff_loc_id_tab	WSH_UTIL_CORE.ID_TAB_TYPE,
					initial_pickup_date_tab		WSH_UTIL_CORE.DATE_TAB_TYPE,
					ultimate_dropoff_date_tab	WSH_UTIL_CORE.DATE_TAB_TYPE,
					freight_terms_code_tab		WSH_UTIL_CORE.COLUMN_TAB_TYPE,
					fob_code_tab			WSH_UTIL_CORE.COLUMN_TAB_TYPE,
					search_level_tab		WSH_UTIL_CORE.COLUMN_TAB_TYPE,
					transit_time_tab		WSH_UTIL_CORE.ID_TAB_TYPE);

TYPE fte_cs_group_rec_type IS RECORD(GROUP_ID	NUMBER,
				     START_DATE	DATE,
				     END_DATE	DATE);

TYPE fte_cs_group_rec_tab       IS TABLE OF fte_cs_group_rec_type INDEX BY BINARY_INTEGER;
TYPE fte_cs_entity_group_cache	IS TABLE OF fte_cs_group_rec_tab INDEX BY BINARY_INTEGER;

--
-- Global caches
--
g_site_cache_tab		fte_cs_entity_group_cache;
g_cust_cache_tab		fte_cs_entity_group_cache;
g_org_cache_tab			fte_cs_entity_group_cache;

-- Enterprise level cache is not indexed by any number.
g_ship_cache_tab		fte_cs_group_rec_tab;
g_flag_active			VARCHAR2(1) :='A';
g_object_id			NUMBER := 1;

--
--R12 Data Strucutes End
--

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_ACS_RULE_UTIL_PKG';
--
-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                CONV_TO_BASE_UOM                                      --
--                                                                            --
-- TYPE:                FUNCTION                                              --
--                                                                            --
-- PARAMETERS (IN):     p_input_value          IN NUMBER                      --
--                      p_from_uom             IN VARCHAR2 (Input UoM)        --
--                      p_to_uom               IN VARCHAR2 (base UoM)         --
--                                                                            --
-- PARAMETERS (OUT):    none                                                  --
--                                                                            --
-- PARAMETERS (IN OUT): none                                                  --
--                                                                            --
-- RETURN:              NUMBER   - the converted value                        --
--                                                                            --
-- DESCRIPTION:         This function converts a value from the input         --
--                      attribute uom to a base uom to be used in the query   --
--                      for the selection search                              --
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- ------------------                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2002/07/01  POST H   ABLUNDEL           Created                            --
--                                                                            --
-- -------------------------------------------------------------------------- --
FUNCTION CONV_TO_BASE_UOM(p_input_value IN NUMBER,
                          p_from_uom    IN VARCHAR2,
                          p_to_uom      IN VARCHAR2) RETURN NUMBER IS

--
-- Local Variable Definitions
--
l_error_text      VARCHAR2(2000);

l_new_conv_value  NUMBER;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONV_TO_BASE_UOM';
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
       WSH_DEBUG_SV.log(l_module_name,'P_INPUT_VALUE',P_INPUT_VALUE);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_UOM',P_FROM_UOM);
       WSH_DEBUG_SV.log(l_module_name,'P_TO_UOM',P_TO_UOM);
   END IF;
   --
   IF (p_input_value = 0) THEN
      --
      -- Zero is always zero!
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN(0);
   END IF;


   IF ((p_from_uom is null) OR
       (p_to_uom is null)) THEN
      --
      -- One or both of the UoMs is null, therfore
      -- we cannot perform the conversion
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN(-99999);
   ELSE
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_CONVERT.INV_UM_CONVERT',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_new_conv_value := INV_CONVERT.inv_um_convert(null,
                                                     5,
                                                     p_input_value,
                                                     p_from_uom,
                                                     p_to_uom,
                                                     null,
                                                     null);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN(l_new_conv_value);

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      l_error_text := SQLERRM;
      FND_MESSAGE.SET_NAME('FTE','FTE_CS_CONV_VALUE_TO_UOM_ERR');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM FTE_ACS_RULE_UTIL_PKG.CONV_VAL_TO_BASE_UOM IS ' ||L_ERROR_TEXT  );
      END IF;
      --
      WSH_UTIL_CORE.default_handler('FTE_ACS_RULE_UTIL_PKG.CONV_TO_BASE_UOM');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN(-99999);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END CONV_TO_BASE_UOM;

PROCEDURE compare_ranges(p_attr_name            IN VARCHAR2,
                         p_attr_from_number_tab IN FTE_ID_TAB_TYPE,
                         p_attr_to_number_tab   IN FTE_ID_TAB_TYPE,
                         p_attr_from_char_tab   IN FTE_NAME_TAB_TYPE,
                         p_attr_to_char_tab     IN FTE_NAME_TAB_TYPE,
                         p_compare_start        IN NUMBER,
                         p_compare_end          IN NUMBER,
                         p_overlap_flag_tab IN OUT NOCOPY FTE_NAME_TAB_TYPE) is

  base_value_from VARCHAR2(30);
  base_value_to   VARCHAR2(30);
  cmp_value_from  VARCHAR2(30);
  cmp_value_to    VARCHAR2(30);

  base_value_from_number NUMBER;
  base_value_to_number   NUMBER;
  cmp_value_from_number  NUMBER;
  cmp_value_to_number    NUMBER;

begin

  if (p_attr_name like '%CODE') then
    FOR base_idx in p_compare_start..p_compare_end-1 LOOP
      base_value_from := p_attr_from_char_tab(base_idx);
      base_value_to := p_attr_to_char_tab(base_idx);
      if (base_value_to is null) then
        base_value_to := base_value_from;
      end if;

      FOR cmp_idx in base_idx+1..p_compare_end LOOP
        cmp_value_from := p_attr_from_char_tab(cmp_idx);
        cmp_value_to := p_attr_to_char_tab(cmp_idx);
        if (cmp_value_to is null) then
          cmp_value_to := cmp_value_from;
        end if;

        if (cmp_value_to >= base_value_from AND
            cmp_value_from <= base_value_to) then

          FOR idx in p_compare_start..p_compare_end LOOP
            p_overlap_flag_tab(idx) := 'Y';
          END LOOP;
          return;

        end if;
      END LOOP;
    END LOOP;
  else
    FOR base_idx in p_compare_start..p_compare_end-1 LOOP
      base_value_from_number := p_attr_from_number_tab(base_idx);
      base_value_to_number := p_attr_to_number_tab(base_idx);

      FOR cmp_idx in base_idx+1..p_compare_end LOOP
        cmp_value_from_number := p_attr_from_number_tab(cmp_idx);
        cmp_value_to_number := p_attr_to_number_tab(cmp_idx);

        if (cmp_value_to_number > base_value_from_number AND
            cmp_value_from_number < base_value_to_number) then

          FOR idx in p_compare_start..p_compare_end LOOP
            p_overlap_flag_tab(idx) := 'Y';
          END LOOP;
          return;

        end if;
      END LOOP;
    END LOOP;
  end if;

  FOR idx in p_compare_start..p_compare_end LOOP
    p_overlap_flag_tab(idx) := 'N';
  END LOOP;

end COMPARE_RANGES;

PROCEDURE set_attr_overlap_flag(p_group_id  IN NUMBER,
                                p_attr_name IN VARCHAR2) is
  l_prev_region_from NUMBER := -2;
  l_prev_region_to   NUMBER := -2;
  l_compare_start    NUMBER := 0;
  l_compare_end      NUMBER := 0;

  l_from_region_tab       FTE_ID_TAB_TYPE    := FTE_ID_TAB_TYPE();
  l_to_region_tab         FTE_ID_TAB_TYPE    := FTE_ID_TAB_TYPE();
  l_attr_from_number_tab  FTE_ID_TAB_TYPE    := FTE_ID_TAB_TYPE();
  l_attr_to_number_tab    FTE_ID_TAB_TYPE    := FTE_ID_TAB_TYPE();
  l_attr_from_char_tab    FTE_NAME_TAB_TYPE  := FTE_NAME_TAB_TYPE();
  l_attr_to_char_tab      FTE_NAME_TAB_TYPE  := FTE_NAME_TAB_TYPE();
  l_rule_attribute_id_tab FTE_ID_TAB_TYPE    := FTE_ID_TAB_TYPE();
  l_overlap_flag_tab      FTE_NAME_TAB_TYPE  := FTE_NAME_TAB_TYPE();


  -- Cursor to grab the specified attribute values ordered by
  -- FROM_REGION_ID and TO_REGION_ID
  -- If FROM_REGION_ID or TO_REGION_ID attribute doesn't exist in the table
  -- convert the value to -1 for number comparision purpose
  -- Note that this query joins with FTE_SEL_RULES table
  -- to eliminate the junk data that exist in FTE_SEL_RULE_RESTRICTIONS table
  -- but don't have the corresponding rule in FTE_SEL_RULES table

  CURSOR c_get_ranges(x_group_id NUMBER, x_attr_name VARCHAR2) IS
  select nvl(fr.attribute_value_from_number, -1) from_region,
         nvl(tr.attribute_value_from_number, -1) to_region,
         attr.attribute_value_from_number, attr.attribute_value_to_number,
         attr.attribute_value_from, attr.attribute_value_to,
         attr.rule_attribute_id, attr.range_overlap_flag
    from fte_sel_rule_restrictions attr, fte_sel_rule_restrictions fr,
         fte_sel_rule_restrictions tr, fte_sel_rules rr
   where attr.group_id = x_group_id and attr.attribute_name = x_attr_name
     and fr.rule_id (+)= attr.rule_id
     and fr.attribute_name (+)= 'FROM_REGION_ID'
     and tr.rule_id (+)= attr.rule_id
     and tr.attribute_name (+)= 'TO_REGION_ID'
     and rr.rule_id = attr.rule_id
  order by from_region, to_region;

BEGIN

  OPEN c_get_ranges(p_group_id, p_attr_name);
  FETCH c_get_ranges BULK COLLECT INTO
        l_from_region_tab, l_to_region_tab,
        l_attr_from_number_tab, l_attr_to_number_tab,
        l_attr_from_char_tab, l_attr_to_char_tab,
        l_rule_attribute_id_tab, l_overlap_flag_tab;
  CLOSE c_get_ranges;

  if (l_rule_attribute_id_tab.COUNT > 1) then

    FOR lc IN 1..l_rule_attribute_id_tab.COUNT LOOP

      if (l_from_region_tab(lc) <> l_prev_region_from or
          l_to_region_tab(lc) <> l_prev_region_to) then

        l_compare_end := lc-1;
        if (l_compare_start = l_compare_end) then
          if (l_compare_start <> 0) then
            l_overlap_flag_tab(lc-1) := 'N';
          end if;
        else
          compare_ranges(p_attr_name,
                         l_attr_from_number_tab, l_attr_to_number_tab,
                         l_attr_from_char_tab, l_attr_to_char_tab,
                         l_compare_start, l_compare_end, l_overlap_flag_tab);
        end if;
        l_compare_start := lc;
        l_prev_region_from := l_from_region_tab(lc);
        l_prev_region_to := l_to_region_tab(lc);
      end if;
    END LOOP;

    l_compare_end := l_rule_attribute_id_tab.COUNT;
    if (l_compare_start = l_compare_end) then
      l_overlap_flag_tab(l_rule_attribute_id_tab.COUNT) := 'N';
    else
      compare_ranges(p_attr_name,
                     l_attr_from_number_tab, l_attr_to_number_tab,
                     l_attr_from_char_tab, l_attr_to_char_tab,
                     l_compare_start, l_compare_end, l_overlap_flag_tab);
    end if;

  elsif (l_rule_attribute_id_tab.COUNT = 1) then
    l_overlap_flag_tab(1) := 'N';
  end if;

  if (l_rule_attribute_id_tab.COUNT >= 1) then

    FORALL i IN 1..l_rule_attribute_id_tab.COUNT
      UPDATE fte_sel_rule_restrictions
         SET range_overlap_flag = l_overlap_flag_tab(i)
       WHERE rule_attribute_id = l_rule_attribute_id_tab(i);
  end if;

END SET_ATTR_OVERLAP_FLAG;


PROCEDURE SET_RANGE_OVERLAP_FLAG(p_group_id IN NUMBER) is
begin
  set_attr_overlap_flag(p_group_id, 'DISPLAY_WEIGHT');
  set_attr_overlap_flag(p_group_id, 'DISPLAY_VOLUME');
  set_attr_overlap_flag(p_group_id, 'TRANSIT_TIME');
  set_attr_overlap_flag(p_group_id, 'FROM_REGION_POSTAL_CODE');
  set_attr_overlap_flag(p_group_id, 'TO_REGION_POSTAL_CODE');
end SET_RANGE_OVERLAP_FLAG;

-- SBAKSHI (R12- Enhancement)
--***************************************************************************--
--========================================================================
-- PROCEDURE : get_formatted_regions            PRIVATE
--
-- PARAMETERS: p_location_id		  Location id.
--	       x_region_tab		  Has regions of type 0,1,2
--             x_all_region_tab		  Has regions of type 0,1,2 and the zones.
--             x_postal_zone_tab	  Has zones associated with region of type 3
--	       x_return_status		  Return Status
--
-- COMMENT   : The API returns the regions and  zones associated with a location.Sequence of
--             regions is same as is returned by WSH_REGIONS_SEARCH_PKG.Get_All_Region_Matches
--
--***************************************************************************--
PROCEDURE GET_FORMATED_REGIONS( p_location_id		IN  NUMBER,
			        x_region_tab		OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
			        x_all_region_tab	OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
			        x_postal_zone_tab	OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
				x_return_status		OUT NOCOPY VARCHAR2)
IS

 l_postal_tab		WSH_UTIL_CORE.ID_TAB_TYPE;
 l_region_tab		WSH_UTIL_CORE.ID_TAB_TYPE;
 l_postal_code_tab	WSH_UTIL_CORE.ID_TAB_TYPE;
 l_region_table         WSH_REGIONS_SEARCH_PKG.region_table;

 l_language		VARCHAR2(720);
 l_zone_flag            VARCHAR2(1):='Y';

 itr			NUMBER;
 l_count		NUMBER;

 l_debug_on     CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
 l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'get_formatted_regions';

BEGIN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on THEN
	   wsh_debug_sv.push (l_module_name);
        END IF;

	IF (l_language is null) THEN
	   l_language := nvl(userenv('LANG'),'US');
	END IF;

 	WSH_REGIONS_SEARCH_PKG.Get_All_Region_Matches(p_country             => null,
	                                               p_country_region      => null,
                                                       p_state               => null, --l_state,
                                                       p_city                => null, -- l_city,
                                                       p_postal_code_from    => null,
                                                       p_postal_code_to      => null,
                                                       p_country_code        => null, --l_country,
                                                       p_country_region_code => null,
                                                       p_state_code          => null,
                                                       p_city_code           => null,
                                                       p_lang_code           => l_language,
                                                       p_location_id         => p_location_id,
                                                       p_zone_flag           => l_zone_flag,
                                                       x_status              => x_return_status,
                                                       x_regions             => l_region_table);


	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		   raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	itr := l_region_table.FIRST;

	IF itr IS NOT NULL THEN
	LOOP
		IF (l_region_table(itr).region_type IN (0,1,2)) THEN
			 l_count := x_region_tab.COUNT;
			 x_region_tab(l_count) := l_region_table(itr).region_id;
		END IF;

	 	IF (l_region_table(itr).region_type NOT IN (3,11) AND l_region_table(itr).zone_level<>3) THEN
      		   	l_count := x_all_region_tab.COUNT;
			x_all_region_tab(l_count) := l_region_table(itr).region_id;
		END IF;

		IF (l_region_table(itr).zone_level = 3 AND l_region_table(itr).region_type = 10) THEN
			l_count := x_postal_zone_tab.COUNT;
			x_postal_zone_tab(l_count) := l_region_table(itr).region_id;
		END IF;

		EXIT WHEN itr = l_region_table.LAST;
		itr := l_region_table.NEXT(itr);

	END LOOP;
	END IF;

       IF l_debug_on THEN
	   WSH_DEBUG_SV.log(l_module_name,'Found Regions for location ',p_location_id);
           WSH_DEBUG_SV.POP(l_module_name);
       END IF;

EXCEPTION

WHEN others THEN

      WSH_UTIL_CORE.default_handler('FTE_ACS_UTIL_PKG.GET_FORMATTED_REGION');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END GET_FORMATED_REGIONS;

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_postal_code            PRIVATE
--
-- PARAMETERS: p_location_id		  Location id.
--	       x_postal_code		  Postal Code associated with the location
--	       x_return_status		  Return Status
--
-- COMMENT   : The API returns the postal codes for a location.
--
--***************************************************************************--
PROCEDURE  GET_POSTAL_CODE(p_location_id   IN	    NUMBER,
			   x_postal_code   OUT NOCOPY VARCHAR2,
			   x_return_status OUT NOCOPY VARCHAR2)

IS

CURSOR c_get_postal_code IS
SELECT postal_code
FROM   wsh_locations
WHERE  wsh_location_id = p_location_id;

l_postal_code	WSH_LOCATIONS.POSTAL_CODE%TYPE;

l_debug_on     CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'get_postal_code';

BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on THEN
 	   wsh_debug_sv.push (l_module_name);
	END IF;

	OPEN  c_get_postal_code;
	FETCH c_get_postal_code INTO l_postal_code;
	CLOSE c_get_postal_code;

	x_postal_code := l_postal_code;

	IF l_debug_on THEN
	     WSH_DEBUG_SV.POP (l_module_name);
	END IF;

EXCEPTION

    WHEN OTHERS THEN
      IF c_get_postal_code%ISOPEN THEN
 	 CLOSE c_get_postal_code;
      END IF;

      WSH_UTIL_CORE.default_handler('FTE_ACS_UTIL_PKG.get_postal_code');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END GET_POSTAL_CODE;


--***************************************************************************--
--========================================================================
-- PROCEDURE : insert_into_gtt     PRIVATE
--
-- PARAMETERS: p_input_data	    Entity related information.
--  	       x_return_status      Return Status
--
-- COMMENT   : Inserts the entity related data into Global Temporary Table
--
--***************************************************************************--
PROCEDURE INSERT_INTO_GTT(p_input_data	   IN	        FTE_ACS_PKG.fte_cs_entity_tab_type,
			  x_return_status  OUT NOCOPY  VARCHAR2)
IS
   l_cnt	       NUMBER;
   l_debug_on          CONSTANT BOOLEAN	      := WSH_DEBUG_SV.is_debug_enabled;
   l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_INTO_GTT';
   l_first	       NUMBER;
   l_last	       NUMBER;
   l_insert_gtt_rec    FTE_CS_BULK_ENTITY_GTT;
   i		       NUMBER;
   itr		       NUMBER;

BEGIN
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  	 IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	      WSH_DEBUG_SV.logmsg(l_module_name,'Number of input records'||p_input_data.COUNT);
  	      WSH_DEBUG_SV.logmsg(l_module_name,'Inserting data into GTT');
	      itr := p_input_data.FIRST;
	      LOOP
			WSH_DEBUG_SV.logmsg(l_module_name,'***NEW RECORD ********');
			WSH_DEBUG_SV.log(l_module_name,'delivery_id ',p_input_data(itr).delivery_id);
			WSH_DEBUG_SV.log(l_module_name,'trip_id	',p_input_data(itr).trip_id);
			WSH_DEBUG_SV.log(l_module_name,'delivery_name ',p_input_data(itr).delivery_name);
			WSH_DEBUG_SV.log(l_module_name,'trip_name ',p_input_data(itr).trip_name);
			WSH_DEBUG_SV.log(l_module_name,'organization_id ',p_input_data(itr).organization_id);
			WSH_DEBUG_SV.log(l_module_name,'triporigin_internalorg_id ',p_input_data(itr).triporigin_internalorg_id);
			WSH_DEBUG_SV.log(l_module_name,'customer_id ',p_input_data(itr).customer_id);
			WSH_DEBUG_SV.log(l_module_name,'customer_site_id ',p_input_data(itr).customer_site_id);
			WSH_DEBUG_SV.log(l_module_name,'gross_weight ',	p_input_data(itr).gross_weight);
			WSH_DEBUG_SV.log(l_module_name,'weight_uom_code ',p_input_data(itr).weight_uom_code);
			WSH_DEBUG_SV.log(l_module_name,'volume ', p_input_data(itr).volume);
			WSH_DEBUG_SV.log(l_module_name,'volume_uom_code ', p_input_data(itr).volume_uom_code);
			WSH_DEBUG_SV.log(l_module_name,'initial_pickup_loc_id ', p_input_data(itr).initial_pickup_loc_id);
			WSH_DEBUG_SV.log(l_module_name,'ultimate_dropoff_loc_id ', p_input_data(itr).ultimate_dropoff_loc_id);
			WSH_DEBUG_SV.log(l_module_name,'initial_pickup_date ', nvl(p_input_data(itr).initial_pickup_date,SYSDATE));
			WSH_DEBUG_SV.log(l_module_name,'ultimate_dropoff_date ', p_input_data(itr).ultimate_dropoff_date);
			WSH_DEBUG_SV.log(l_module_name,'freight_terms_code ',p_input_data(itr).freight_terms_code);
			WSH_DEBUG_SV.log(l_module_name,'fob_code ',p_input_data(itr).fob_code);
			WSH_DEBUG_SV.log(l_module_name,'start_search_level ',p_input_data(itr).start_search_level);
			WSH_DEBUG_SV.log(l_module_name,'transit_time ',p_input_data(itr).transit_time);

			EXIT WHEN itr = p_input_data.LAST;
			itr := p_input_data.NEXT(itr);
	      END LOOP;
   	 END IF;

	 --
	 -- For Bulk insert we need to have record of tables instead of table of records.
	 --

	 i := 1;
	 l_first := i;
	 itr := p_input_data.FIRST;
	 LOOP
		l_insert_gtt_rec.delivery_id_tab(i)			:=  p_input_data(itr).delivery_id;
		l_insert_gtt_rec.trip_id_tab(i)				:=  p_input_data(itr).trip_id;
		l_insert_gtt_rec.delivery_name_tab(i)			:=  p_input_data(itr).delivery_name;
		l_insert_gtt_rec.trip_name_tab(i)			:=  p_input_data(itr).trip_name;
		l_insert_gtt_rec.organization_id_tab(i)			:=  p_input_data(itr).organization_id;
		l_insert_gtt_rec.triporigin_internal_org_id_tab(i)	:=  p_input_data(itr).triporigin_internalorg_id;
		l_insert_gtt_rec.customer_id_tab(i)			:=  p_input_data(itr).customer_id;
		l_insert_gtt_rec.customer_site_id_tab(i)	       	:=  p_input_data(itr).customer_site_id;
		l_insert_gtt_rec.gross_weight_tab(i)			:=  p_input_data(itr).gross_weight;
		l_insert_gtt_rec.weight_uom_code_tab(i)	       		:=  p_input_data(itr).weight_uom_code;
		l_insert_gtt_rec.volume_tab(i)				:=  p_input_data(itr).volume;
		l_insert_gtt_rec.volume_uom_code_tab(i)	       		:=  p_input_data(itr).volume_uom_code;
		l_insert_gtt_rec.initial_pickup_loc_id_tab(i)		:=  p_input_data(itr).initial_pickup_loc_id;
		l_insert_gtt_rec.ultimate_dropoff_loc_id_tab(i)		:=  p_input_data(itr).ultimate_dropoff_loc_id;
		l_insert_gtt_rec.initial_pickup_date_tab(i)		:=  nvl(p_input_data(itr).initial_pickup_date,SYSDATE);
		l_insert_gtt_rec.ultimate_dropoff_date_tab(i)		:=  p_input_data(itr).ultimate_dropoff_date;
		l_insert_gtt_rec.freight_terms_code_tab(i)		:=  p_input_data(itr).freight_terms_code;
		l_insert_gtt_rec.fob_code_tab(i)			:=  p_input_data(itr).fob_code;
		l_insert_gtt_rec.search_level_tab(i)			:=  p_input_data(itr).start_search_level;
		l_insert_gtt_rec.transit_time_tab(i)			:=  p_input_data(itr).transit_time;

		EXIT WHEN itr = p_input_data.LAST;
		itr := p_input_data.NEXT(itr);
		i := i+1;
	 END LOOP;
	 l_last	:= i;

 	 FORALL j IN l_first..l_last

            INSERT INTO FTE_SEL_SEARCH_ENTITIES_TMP(
			delivery_id,
			trip_id	,
			delivery_name,
			trip_name,
			organization_id,
			triporigin_internalorg_id,
			customer_id,
			customer_site_id,
			gross_weight,
			weight_uom_code,
			volume,
			volume_uom_code,
			initial_pickup_loc_id,
			ultimate_dropoff_loc_id,
			initial_pickup_date,
			ultimate_dropoff_date,
			freight_terms_code,
			fob_code,
			search_level,
			transit_time)
	    VALUES(
			l_insert_gtt_rec.delivery_id_tab(j),
			l_insert_gtt_rec.trip_id_tab(j),
			l_insert_gtt_rec.delivery_name_tab(j),
			l_insert_gtt_rec.trip_name_tab(j),
			l_insert_gtt_rec.organization_id_tab(j),
			l_insert_gtt_rec.triporigin_internal_org_id_tab(j),
			l_insert_gtt_rec.customer_id_tab(j),
			l_insert_gtt_rec.customer_site_id_tab(j),
			l_insert_gtt_rec.gross_weight_tab(j),
			l_insert_gtt_rec.weight_uom_code_tab(j),
			l_insert_gtt_rec.volume_tab(j),
			l_insert_gtt_rec.volume_uom_code_tab(j),
			l_insert_gtt_rec.initial_pickup_loc_id_tab(j),
			l_insert_gtt_rec.ultimate_dropoff_loc_id_tab(j),
			l_insert_gtt_rec.initial_pickup_date_tab(j),
			l_insert_gtt_rec.ultimate_dropoff_date_tab(j),
			l_insert_gtt_rec.freight_terms_code_tab(j),
			l_insert_gtt_rec.fob_code_tab(j),
			l_insert_gtt_rec.search_level_tab(j),
			l_insert_gtt_rec.transit_time_tab(j));

	 IF l_debug_on THEN
	      wsh_debug_sv.pop (l_module_name);
         END IF;

EXCEPTION
WHEN OTHERS THEN
      --
      WSH_UTIL_CORE.default_handler('FTE_ACS_RULE_UTIL_PKG.INSERT_INTO_GTT');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END insert_into_gtt;


--***************************************************************************--
--========================================================================
-- PROCEDURE : format_entity_info   PRIVATE
--
-- PARAMETERS: p_input_cs_tab	    Input Data to be formated.
--	       p_entity		    Entity information
--  	       x_return_status      Return Status
--
-- COMMENT   : a) Determines the transit time if not specified.
--	       b) Determines the start search level.
--
--***************************************************************************--
PROCEDURE FORMAT_ENTITY_INFO( p_input_cs_tab	IN  OUT NOCOPY	FTE_ACS_PKG.fte_cs_entity_tab_type,
			      p_entity		IN		VARCHAR2,
			      x_return_status   OUT NOCOPY	VARCHAR2)
IS

    itr			NUMBER;
    l_param_rec		WSH_SHIPPING_PARAMS_PVT.PARAMETER_VALUE_REC_TYP;
    l_search_level	VARCHAR2(1);
    l_itr		NUMBER;
    l_sysdate           DATE := sysdate;

    l_debug_on          CONSTANT BOOLEAN	      := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FORMAT_ENTITY_INFO';

BEGIN

	 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  	 IF l_debug_on THEN
	      wsh_debug_sv.push (l_module_name);
	      WSH_DEBUG_SV.logmsg(l_module_name,'Number of input records'||p_input_cs_tab.COUNT);
	 END IF;

	 itr := p_input_cs_tab.FIRST;

	 IF (itr IS NOT NULL) THEN
	 LOOP
		--

                -- 3. AG modify initial pickupdate and ultimatedropoff date if required
                IF (p_input_cs_tab(itr).initial_pickup_date is not null) THEN
                   IF (p_input_cs_tab(itr).initial_pickup_date < l_sysdate) THEN
                      p_input_cs_tab(itr).initial_pickup_date := l_sysdate;
                   END IF;
                ELSE
                   p_input_cs_tab(itr).initial_pickup_date := l_sysdate;
                END IF;

                IF (p_input_cs_tab(itr).ultimate_dropoff_date is not null) THEN
                   IF (p_input_cs_tab(itr).ultimate_dropoff_date < l_sysdate) THEN
                       p_input_cs_tab(itr).ultimate_dropoff_date := l_sysdate;
                   END IF;
                END IF;

		--1) When Caller is order management.Transit time is passed.
		--
		IF ( p_input_cs_tab(itr).transit_time IS NULL) THEN
			IF ( p_input_cs_tab(itr).ultimate_dropoff_date is NOT NULL) THEN
				p_input_cs_tab(itr).transit_time := p_input_cs_tab(itr).ultimate_dropoff_date
								- nvl(p_input_cs_tab(itr).initial_pickup_date, sysdate);
			END IF;
		END IF;


		IF (p_entity IN ('DLVY','PSEUDO_DLVY')) THEN
			--
			-- 2) Get the Start Search Level based on the Freight Term.
			--
			l_param_rec.organization_id :=  p_input_cs_tab(itr).organization_id;
			l_param_rec.param_name(1)   := 'FREIGHT_TERMS';

			WSH_SHIPPING_PARAMS_PVT.GET( x_param_value_info => l_param_rec,
					     x_return_status    => x_return_status);

		        IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
				 raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

			l_itr := l_param_rec.param_value_chr.FIRST;

			l_search_level := 'S';
			IF (l_itr IS NOT NULL) THEN
			LOOP
				IF ( p_input_cs_tab(itr).freight_terms_code = l_param_rec.param_value_chr(l_itr)) THEN
					--For the freight term start at Organization level.
					l_search_level := 'O';
					EXIT;
				END IF;
				EXIT WHEN l_itr = l_param_rec.param_value_chr.LAST;
				l_itr := l_param_rec.param_value_chr.NEXT(l_itr);
			END LOOP;
			END IF;

			p_input_cs_tab(itr).start_search_level := l_search_level;
		ELSE
			-- In trip we always start with internal organization id
			p_input_cs_tab(itr).start_search_level := 'I';
		END IF;

		EXIT WHEN itr = p_input_cs_tab.LAST;
	        itr := p_input_cs_tab.NEXT(itr);
	END LOOP;
	END IF;

	IF l_debug_on THEN
              wsh_debug_sv.pop (l_module_name);
        END IF;
EXCEPTION
WHEN OTHERS THEN
      --
      WSH_UTIL_CORE.default_handler('FTE_ACS_RULE_UTIL_PKG.FORMAT_ENTITY_INFO');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
END FORMAT_ENTITY_INFO;

--***************************************************************************--
--==========================================================================
-- PROCEDURE : get_ship_method_code PRIVATE
--
-- PARAMETERS: p_carrier_id 		Carrier Id
--	       p_service_level    	Service Level
--	       p_mode_of_transport      Mode of Transport
--	       p_org_id			Organization Id
--	       x_ship_method_code	Ship Method Code
--	       x_return_message		Return Message
--  	       x_return_status		Return Status
--
-- COMMENT   :  Determines the ship method for input carrier id, service level and
--		mode of transport.
--***************************************************************************--
PROCEDURE GET_SHIP_METHOD_CODE(p_carrier_id	    IN NUMBER,
			       p_service_level      IN VARCHAR2,
                               p_mode_of_transport  IN VARCHAR2,
                               p_org_id             IN NUMBER,
                               x_ship_method_code   OUT NOCOPY VARCHAR2,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_return_message     OUT NOCOPY VARCHAR2)
IS
	l_error_code         NUMBER;                               -- Oracle SQL Error code
	l_error_text         VARCHAR2(2000);                       -- Oracle SQL Error Text
	l_enabled_flag       VARCHAR2(1) := 'Y';                   -- Indicates enabled status
	l_ship_method_code   VARCHAR2(30);                         -- holder to return ship method code

cursor c_get_ship_method(p_carrier_id          NUMBER,
                         p_service_level       VARCHAR2,
                         p_mode_of_transport   VARCHAR2,
                         p_organization_id     NUMBER) IS
select wcs.ship_method_code
from   wsh_org_carrier_services wocs,
       wsh_carrier_services     wcs
where  wcs.carrier_id         = p_carrier_id
and    wcs.service_level      = p_service_level
and    wcs.mode_of_transport  = p_mode_of_transport
and    wcs.enabled_flag       = 'Y'
and    wcs.carrier_service_id = wocs.carrier_service_id
and    wocs.organization_id   = p_organization_id
and    wocs.enabled_flag      = 'Y';
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_SHIP_METHOD_CODE';
--
BEGIN

   --
   -- Initialize the return parameters
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   x_return_message := null;

   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.logmsg(l_module_name, 'Carrier Id        '||p_carrier_id);
       WSH_DEBUG_SV.logmsg(l_module_name, 'Service Level     '||p_service_level);
       WSH_DEBUG_SV.logmsg(l_module_name, 'Mode of transport '||p_mode_of_transport);
       WSH_DEBUG_SV.logmsg(l_module_name, 'Organization Id   '||p_org_id);
   END IF;
   --

   IF (p_carrier_id IS NOT NULL) THEN

         OPEN c_get_ship_method(p_carrier_id,
                                p_service_level,
                                p_mode_of_transport,
                                p_org_id);
         FETCH c_get_ship_method INTO x_ship_method_code;
         CLOSE c_get_ship_method;

   ELSE
	x_ship_method_code := null;
   END IF; --

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'Ship Method Code'||x_ship_method_code);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

EXCEPTION
   WHEN OTHERS THEN
      l_error_code := SQLCODE;
      l_error_text := SQLERRM;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM WSH_UTIL_CORE.GET_SHIP_METHOD_CODE IS ' ||L_ERROR_TEXT  );
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      WSH_UTIL_CORE.default_handler('WSH_UTIL_CORE.GET_SHIP_METHOD_CODE');
      FND_MESSAGE.SET_NAME('WSH','WSH_FTE_GET_SMC_ERROR');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := 'WSH_FTE_GET_SMC_ERROR';
      WSH_UTIL_CORE.add_message(x_return_status);

END GET_SHIP_METHOD_CODE;


--***************************************************************************--
--==========================================================================
-- PROCEDURE : get_candidate_records    PRIVATE
--
-- PARAMETERS: p_search_level		Whether search has to be done at customer site, customer,
--					organization or enterprise level.
--	       p_guery_gtt		Should the GTT  be used or not.
--	       p_single_rec		This parameter is used for single records(GTT is not used)
--	       x_output_tab		Output result table.
--	       x_return_status		Return status
--
-- COMMENT   :  Determines the candidate records at the given level.
--		a) For multiple records queries global temp table and returns the associated group
--		b) For single record uses the group cache to determine the associated group.
--
-- Groups that lie within the following limits are valid at a level
--
--	START DATE		|	END DATE
--	----------------------------------------------------
--	<= pickupdate		|	NULL
--	<= pickupdate		|	>= pickupdate
--	NULL			|	>= pickupdate
--	NULL			|	NULL
--
--
--***************************************************************************--
PROCEDURE GET_CANDIDATE_RECORDS( p_search_level		IN         VARCHAR2,
				 p_query_gtt		IN	   BOOLEAN,
				 p_single_rec		IN	   FTE_ACS_PKG.FTE_CS_ENTITY_REC_TYPE DEFAULT NULL,
				 x_output_tab		OUT NOCOPY FTE_ACS_CACHE_PKG.FTE_CS_ENTITY_ATTR_TAB,
				 x_return_status	OUT NOCOPY VARCHAR2)
IS


CURSOR  c_get_entity_by_site IS
SELECT  fsg.group_id,
	fsset.delivery_id,
	fsset.trip_id,
	fsset.gross_weight,
	fsset.weight_uom_code,
	fsset.volume,
	fsset.volume_uom_code,
	fsset.transit_time,
	fsset.initial_pickup_loc_id,
	fsset.ultimate_dropoff_loc_id,
	fsset.fob_code
--      We do not fetch start date and end date here as we are not going to cache this information.
FROM  	FTE_SEL_SEARCH_ENTITIES_TMP FSSET,
	FTE_SEL_GROUP_ASSIGNMENTS FSGA,
	FTE_SEL_GROUPS FSG
WHERE	fsga.customer_site_id  = fsset.customer_site_id
AND     fsga.group_id 	       = fsg.group_id
AND     fsg.object_id          = g_object_id
--AND     nvl(fsg.group_status_flag,'A')  NOT IN ('D','I')
AND     nvl(fsg.group_status_flag,'A') = g_flag_active
AND    (fsg.start_date < fsset.initial_pickup_date OR
        fsg.start_date is null)
AND    (fsg.end_date   > fsset.initial_pickup_date OR
        fsg.end_date is null)
AND     fsset.rule_id IS NULL
AND     fsset.search_level <> 'O'
ORDER BY fsg.group_id;


CURSOR  c_get_entity_by_cust IS
SELECT  fsg.group_id,
	fsset.delivery_id,
	fsset.trip_id,
	fsset.gross_weight,
	fsset.weight_uom_code,
	fsset.volume,
	fsset.volume_uom_code,
	fsset.transit_time,
	fsset.initial_pickup_loc_id,
	fsset.ultimate_dropoff_loc_id,
	fsset.fob_code
--      We do not fetch start date and end date here as we are not going to cache this information.
FROM  	FTE_SEL_SEARCH_ENTITIES_TMP FSSET,
	FTE_SEL_GROUP_ASSIGNMENTS FSGA,
	FTE_SEL_GROUPS FSG
WHERE	fsga.customer_id      = fsset.customer_id
AND     fsga.group_id         = fsg.group_id
AND     fsg.object_id         = g_object_id
--AND     nvl(fsg.group_status_flag,'A')  NOT IN ('D','I')
AND     nvl(fsg.group_status_flag,'A') = g_flag_active
AND    (fsg.start_date < fsset.initial_pickup_date OR
        fsg.start_date is null)
AND    (fsg.end_date   > fsset.initial_pickup_date OR
        fsg.end_date is null)
AND	fsset.rule_id IS NULL
AND     fsset.search_level <>'O'
ORDER BY fsg.group_id;


CURSOR  c_get_entity_by_org IS
SELECT  fsg.group_id,
	fsset.delivery_id,
	fsset.trip_id,
	fsset.gross_weight,
	fsset.weight_uom_code,
	fsset.volume,
	fsset.volume_uom_code,
	fsset.transit_time,
	fsset.initial_pickup_loc_id,
	fsset.ultimate_dropoff_loc_id,
	fsset.fob_code
--      We do not fetch start date and end date here as we are not going to cache this information.
FROM    FTE_SEL_SEARCH_ENTITIES_TMP FSSET,
	FTE_SEL_GROUP_ASSIGNMENTS FSGA,
	FTE_SEL_GROUPS FSG
WHERE   fsga.organization_id   = fsset.organization_id
AND     fsga.group_id          = fsg.group_id
AND     fsg.object_id          = g_object_id
--AND     nvl(fsg.group_status_flag,'A')  NOT IN ('D','I')
AND     nvl(fsg.group_status_flag,'A') = g_flag_active
AND    (fsg.start_date < fsset.initial_pickup_date OR
        fsg.start_date is null)
AND    (fsg.end_date   > fsset.initial_pickup_date OR
        fsg.end_date is null)
AND	fsset.rule_id IS NULL
ORDER BY fsg.group_id;


--
-- All entities that have a matching trip origin organziation id;
--
CURSOR  c_get_entity_by_trip_org IS
SELECT  fsg.group_id,
	fsset.delivery_id,
	fsset.trip_id,
	fsset.gross_weight,
	fsset.weight_uom_code,
	fsset.volume,
	fsset.volume_uom_code,
	fsset.transit_time,
	fsset.initial_pickup_loc_id,
	fsset.ultimate_dropoff_loc_id,
	fsset.fob_code
--      We do not fetch start date and end date here as we are not going to cache this information.
FROM    FTE_SEL_SEARCH_ENTITIES_TMP FSSET,
	FTE_SEL_GROUP_ASSIGNMENTS FSGA,
	FTE_SEL_GROUPS FSG
WHERE   fsga.organization_id   = fsset.triporigin_internalorg_id
AND     fsga.group_id          = fsg.group_id
AND     fsg.object_id          = g_object_id
--AND     nvl(fsg.group_status_flag,'A')  NOT IN ('D','I')
AND     nvl(fsg.group_status_flag,'A') = g_flag_active
AND    (fsg.start_date < fsset.initial_pickup_date OR
        fsg.start_date is null)
AND    (fsg.end_date   > fsset.initial_pickup_date OR
        fsg.end_date is null)
AND	fsset.rule_id IS NULL
ORDER BY fsg.group_id;

--
-- All the deliveries with enterprise rules have to be queried
--
CURSOR  c_get_entity_by_ship IS
SELECT  fsg.group_id,
	fsset.delivery_id,
	fsset.trip_id,
	fsset.gross_weight,
	fsset.weight_uom_code,
	fsset.volume,
	fsset.volume_uom_code,
	fsset.transit_time,
	fsset.initial_pickup_loc_id,
	fsset.ultimate_dropoff_loc_id,
	fsset.fob_code
--      We do not fetch start date and end date here as we are not going to cache this information.
FROM  	FTE_SEL_SEARCH_ENTITIES_TMP FSSET,
 	FTE_SEL_GROUPS FSG,
    FTE_SEL_GROUP_ASSIGNMENTS assign
WHERE   --assigned_flag = 'E'
--AND
fsg.object_id =  g_object_id
--AND     nvl(fsg.group_status_flag,'A')  NOT IN ('D','I')
AND     nvl(fsg.group_status_flag,'A') = g_flag_active
AND    (fsg.start_date < fsset.initial_pickup_date OR
         fsg.start_date is null)
AND    (fsg.end_date   > fsset.initial_pickup_date OR
         fsg.end_date is null)
AND	fsset.rule_id IS NULL
and fsg.group_id = assign.group_id
and assign.customer_id is null and assign.CUSTOMER_SITE_ID is null and assign.ORGANIZATION_ID is null

ORDER BY fsg.group_id;

--
-- For individual entity - We will not be using GTT in this case.
-- As this information is cached we need to maintain the start date and end date.
--
CURSOR c_get_site_group(p_customer_site_id    NUMBER,
                        p_ship_date           DATE) IS
SELECT fsg.group_id,
       fsg.start_date,
       fsg.end_date
FROM   fte_sel_group_assignments fsga,
       fte_sel_groups            fsg
WHERE  fsga.customer_site_id  = p_customer_site_id
AND    fsga.group_id          = fsg.group_id
AND    fsg.object_id          = g_object_id
--AND     nvl(fsg.group_status_flag,'A')  NOT IN ('D','I')
AND    nvl(fsg.group_status_flag,'A') = g_flag_active
AND    (fsg.start_date < p_ship_date OR
        fsg.start_date is null)
AND    (fsg.end_date   > p_ship_date OR
        fsg.end_date is null);

--
-- For Customers
--
CURSOR c_get_cust_group(p_customer_id         NUMBER,
                        p_ship_date           DATE) IS
SELECT fsg.group_id,
       fsg.start_date,
       fsg.end_date
FROM   fte_sel_group_assignments fsga,
       fte_sel_groups fsg
WHERE  fsga.customer_id       = p_customer_id
AND    fsga.group_id          = fsg.group_id
AND    fsg.object_id          = g_object_id
--AND     nvl(fsg.group_status_flag,'A')  NOT IN ('D','I')
AND    nvl(fsg.group_status_flag,'A') = g_flag_active
AND   (fsg.start_date < p_ship_date OR
       fsg.start_date is null)
AND   (fsg.end_date   > p_ship_date OR
       fsg.end_date is null);

--
-- For Organizations , The Same cursor can be used for using Trip Internal Organzations
--
CURSOR c_get_org_group(p_org_id               NUMBER,
                       p_ship_date            DATE) IS
SELECT fsg.group_id,
       fsg.start_date,
       fsg.end_date
FROM   fte_sel_group_assignments fsga,
       fte_sel_groups            fsg
WHERE  fsga.organization_id    = p_org_id
AND    fsga.group_id           = fsg.group_id
AND    fsg.object_id           = g_object_id
--AND     nvl(fsg.group_status_flag,'A')  NOT IN ('D','I')
AND    nvl(fsg.group_status_flag,'A') = g_flag_active
AND    (fsg.start_date < p_ship_date OR
        fsg.start_date is null)
AND    (fsg.end_date   > p_ship_date OR
        fsg.end_date is null);

--
-- For Enterprise
--
CURSOR c_get_ship_group(p_ship_date  DATE) IS
SELECT fsg.group_id,
       fsg.start_date,
       fsg.end_date
FROM   fte_sel_groups fsg,
        FTE_SEL_GROUP_ASSIGNMENTS assign
WHERE  --assigned_flag          = 'E'
--AND
fsg.object_id          = g_object_id
--AND     nvl(fsg.group_status_flag,'A')  NOT IN ('D','I')
AND    nvl(fsg.group_status_flag,'A') = g_flag_active
AND    (fsg.start_date < p_ship_date OR
        fsg.start_date is null)
AND    (fsg.end_date   > p_ship_date OR
        fsg.end_date is null)
 and fsg.group_id = assign.group_id
and assign.customer_id is null and assign.CUSTOMER_SITE_ID is null and assign.ORGANIZATION_ID is null;

itr			 NUMBER;

l_group_rec_tab		 FTE_CS_GROUP_REC_TAB;
l_group_rec		 FTE_CS_GROUP_REC_TYPE;
l_organization_id	 NUMBER;


l_result_found		 BOOLEAN := FALSE;
l_group_id		 NUMBER;

l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||'GET_CANDIDATE_RECORDS';
BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF l_debug_on THEN

	     wsh_debug_sv.push(l_module_name);
	     WSH_DEBUG_SV.log(l_module_name,'p_search_level',p_search_level);

	     IF (p_query_gtt) THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Use Global Temporary Table');
	     ELSE
	        WSH_DEBUG_SV.logmsg(l_module_name,'Use Single Record');
	     END IF;

	END IF;

	--
	-- If we are using GTT then we do not need to store this information anywhere else.
	--
	IF (p_query_gtt) THEN

		IF (p_search_level = 'S') THEN

			OPEN  c_get_entity_by_site;
			FETCH c_get_entity_by_site BULK COLLECT INTO x_output_tab;
			CLOSE c_get_entity_by_site;

		ELSIF (p_search_level ='C') THEN

			OPEN  c_get_entity_by_cust;
			FETCH c_get_entity_by_cust BULK COLLECT INTO x_output_tab;
			CLOSE c_get_entity_by_cust;

		ELSIF (p_search_level ='O') THEN

			OPEN  c_get_entity_by_org;
			FETCH c_get_entity_by_org BULK COLLECT INTO x_output_tab;
			CLOSE c_get_entity_by_org;

		ELSIF (p_search_level ='E') THEN

			OPEN  c_get_entity_by_ship;
			FETCH c_get_entity_by_ship BULK COLLECT INTO x_output_tab;
			CLOSE c_get_entity_by_ship;

		ElSIF (p_search_level ='I') THEN
			--
			-- We cannot use same cursor as organization ,because column in the
			-- join changes here
			--
			OPEN  c_get_entity_by_trip_org;
			FETCH c_get_entity_by_trip_org BULK COLLECT INTO x_output_tab;
			CLOSE c_get_entity_by_trip_org;

		END IF;
	 ELSE

		-- Single Record.
		-- And start level of the delivery is not 'O'
		IF (p_search_level = 'S' AND p_single_rec.start_search_level <> 'O') THEN

		    IF (g_site_cache_tab.EXISTS(p_single_rec.customer_site_id)) THEN

			l_group_rec_tab := g_site_cache_tab(p_single_rec.customer_site_id);
			itr := l_group_rec_tab.FIRST;

			IF (itr IS NOT NULL) THEN
			LOOP
				l_group_rec := l_group_rec_tab(itr);

				IF (l_group_rec.start_date IS NULL AND (l_group_rec.end_date IS NULL OR l_group_rec.end_date >= p_single_rec.initial_pickup_date))
				    OR (l_group_rec.start_date <= p_single_rec.initial_pickup_date AND( l_group_rec.end_date IS NULL OR l_group_rec.end_date >= p_single_rec.initial_pickup_date))
				THEN
						l_group_id := l_group_rec.group_id;
						l_result_found := TRUE;
						EXIT ;
				END IF;
				EXIT WHEN itr = l_group_rec_tab.LAST;
				itr := l_group_rec_tab.NEXT(itr);
			END LOOP;
			END IF;
  		    END IF;

		    --
		    -- Record could have been there in the cache.But its not necessary that a match will happen
		    -- Dates may not match
		    --
		    IF  NOT(l_result_found) THEN

			OPEN c_get_site_group( p_customer_site_id => p_single_rec.customer_site_id,
					       p_ship_date  => nvl(p_single_rec.initial_pickup_date,sysdate));

			FETCH c_get_site_group INTO l_group_rec;
			CLOSE c_get_site_group;

			IF (l_group_rec.group_id IS NOT NULL) THEN
				l_result_found := TRUE;
				l_group_id       := l_group_rec.group_id;

				-- This may be the first time the database query is run
				IF (g_site_cache_tab.EXISTS(p_single_rec.customer_site_id)) THEN
					l_group_rec_tab	:= g_site_cache_tab(p_single_rec.customer_site_id);
					l_group_rec_tab(l_group_rec_tab.COUNT+1) :=  l_group_rec;
					g_site_cache_tab(p_single_rec.customer_site_id) := l_group_rec_tab;
				ELSE
					l_group_rec_tab(0) := l_group_rec;
					g_site_cache_tab(p_single_rec.customer_site_id) := l_group_rec_tab;
				END IF;

			END IF;
		     END IF;

		ELSIF (p_search_level ='C' AND p_single_rec.start_search_level <> 'O') THEN

		     IF (g_cust_cache_tab.EXISTS(p_single_rec.customer_id))	THEN

			l_group_rec_tab := g_cust_cache_tab(p_single_rec.customer_id);
			itr := l_group_rec_tab.FIRST;
			IF (itr IS NOT NULL) THEN
			LOOP
				l_group_rec := l_group_rec_tab(itr);
				IF (l_group_rec.start_date IS NULL AND (l_group_rec.end_date IS NULL OR l_group_rec.end_date >= p_single_rec.initial_pickup_date))
				    OR (l_group_rec.start_date <= p_single_rec.initial_pickup_date AND ( l_group_rec.end_date IS NULL OR l_group_rec.end_date >= p_single_rec.initial_pickup_date))
				THEN
					l_group_id := l_group_rec.group_id;
					l_result_found := TRUE;
					EXIT ;
				END IF;
				EXIT WHEN itr = l_group_rec_tab.LAST;
				itr := l_group_rec_tab.NEXT(itr);
			END LOOP;
			END IF;
		     END IF;

		     IF  NOT(l_result_found) THEN

			OPEN  c_get_cust_group(p_customer_id   => p_single_rec.customer_id,
				 	       p_ship_date     => nvl(p_single_rec.initial_pickup_date,sysdate));
			FETCH c_get_cust_group INTO l_group_rec;
			CLOSE c_get_cust_group;

			IF (l_group_rec.group_id IS NOT NULL) THEN
				l_result_found := TRUE;
				l_group_id     := l_group_rec.group_id;

				IF (g_cust_cache_tab.EXISTS(p_single_rec.customer_id)) THEN
					l_group_rec_tab	:= g_cust_cache_tab(p_single_rec.customer_id);
					l_group_rec_tab(l_group_rec_tab.COUNT+1)   := l_group_rec;
					g_cust_cache_tab(p_single_rec.customer_id) := l_group_rec_tab;
				ELSE
					l_group_rec_tab(0) := l_group_rec;
					g_cust_cache_tab(p_single_rec.customer_id) := l_group_rec_tab;
				END IF;
			END IF;

		     END IF;

		ELSIF (p_search_level ='O' OR p_search_level= 'I') THEN


			IF (p_search_level = 'O' ) THEN
				l_organization_id := p_single_rec.organization_id ;
			ELSE
				l_organization_id := p_single_rec.triporigin_internalorg_id;
			END IF;


			IF (g_org_cache_tab.EXISTS(l_organization_id)) THEN
			      l_group_rec_tab := g_org_cache_tab(l_organization_id);
			      itr := l_group_rec_tab.FIRST;

			      IF (itr IS NOT NULL) THEN
			      LOOP
				   l_group_rec := l_group_rec_tab(itr);

				   IF (l_group_rec.start_date IS NULL AND (l_group_rec.end_date IS NULL OR l_group_rec.end_date >= p_single_rec.initial_pickup_date))
				       OR  (l_group_rec.start_date <= p_single_rec.initial_pickup_date AND ( l_group_rec.end_date IS NULL OR l_group_rec.end_date >= p_single_rec.initial_pickup_date))
				   THEN
					l_group_id := l_group_rec.group_id;
				        l_result_found := TRUE;
				        EXIT ;
				   END IF;

				   EXIT WHEN itr = l_group_rec_tab.LAST;
				   itr := l_group_rec_tab.NEXT(itr);
			       END LOOP;
			       END IF;
			END IF;

			IF NOT(l_result_found) THEN

				OPEN  c_get_org_group( p_org_id	     => l_organization_id,
						       p_ship_date   => nvl(p_single_rec.initial_pickup_date,sysdate));
				FETCH c_get_org_group INTO l_group_rec;
				CLOSE c_get_org_group;

				IF (l_group_rec.group_id IS NOT NULL) THEN
					l_result_found := TRUE;
					l_group_id     := l_group_rec.group_id;

					IF (g_org_cache_tab.EXISTS(l_organization_id)) THEN
						l_group_rec_tab	:= g_org_cache_tab(l_organization_id);
						l_group_rec_tab(l_group_rec_tab.COUNT+1)      := l_group_rec;
						g_org_cache_tab(l_organization_id) := l_group_rec_tab;
					ELSE
						l_group_rec_tab(0) := l_group_rec;
						g_org_cache_tab(l_organization_id) := l_group_rec_tab;
					END IF;
				END IF;
		 	 END IF;

		ELSIF (p_search_level ='E') THEN

			--
			-- Here we will not index by id.
			-- The treatement will be different here
			-- We have only 1 ENTERPRISE;
			--
			itr := g_ship_cache_tab.FIRST;
			IF (itr IS NOT NULL) THEN
			LOOP
				l_group_rec := g_ship_cache_tab(itr);
				IF (l_group_rec.start_date IS NULL AND (l_group_rec.end_date IS NULL OR l_group_rec.end_date >= p_single_rec.initial_pickup_date))
				   OR(l_group_rec.start_date <= p_single_rec.initial_pickup_date AND ( l_group_rec.end_date IS NULL OR l_group_rec.end_date >= p_single_rec.initial_pickup_date))
				THEN
					l_group_id := l_group_rec.group_id;
					l_result_found := TRUE;
					EXIT ;
				END IF;
				EXIT WHEN itr = g_ship_cache_tab.LAST;
				itr := g_ship_cache_tab.NEXT(itr);
			 END LOOP;
			 END IF;

			 IF NOT(l_result_found) THEN

				OPEN  c_get_ship_group( p_ship_date => nvl(p_single_rec.initial_pickup_date,sysdate));
				FETCH c_get_ship_group INTO l_group_rec;
				CLOSE c_get_ship_group;

				IF (l_group_rec.group_id IS NOT NULL) THEN
					l_group_id     := l_group_rec.group_id;
					l_result_found := TRUE;
					g_ship_cache_tab(g_ship_cache_tab.COUNT)    := l_group_rec;
				END IF;
			 END IF;

		END IF;--(if p_search_level)

		IF (l_result_found) THEN
			--
			-- Assign values to out records.
			--
			x_output_tab(1).group_id			:= l_group_id;
			x_output_tab(1).delivery_id			:= p_single_rec.delivery_id;
			x_output_tab(1).trip_id				:= p_single_rec.trip_id;
			x_output_tab(1).weight				:= p_single_rec.gross_weight;
			x_output_tab(1).weight_uom_code			:= p_single_rec.weight_uom_code;
			x_output_tab(1).volume				:= p_single_rec.volume;
			x_output_tab(1).volume_uom_code		        := p_single_rec.volume_uom_code;
			x_output_tab(1).transit_time			:= p_single_rec.transit_time;
			x_output_tab(1).ship_from_location_id		:= p_single_rec.initial_pickup_loc_id;
			x_output_tab(1).ship_to_location_id		:= p_single_rec.ultimate_dropoff_loc_id;
			x_output_tab(1).fob_code			:= p_single_rec.fob_code;
		END IF;

	END IF; --IF (p_query_gtt) THEN

	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name, 'CANDIDATE RECORDS RETURNED',x_output_tab.COUNT);
            WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
  WHEN others THEN

	IF (c_get_entity_by_site%ISOPEN) THEN
		CLOSE c_get_entity_by_site;
	END IF;

	IF (c_get_entity_by_cust%ISOPEN) THEN
		CLOSE c_get_entity_by_cust ;
	END IF;

	IF (c_get_entity_by_org%ISOPEN) THEN
		CLOSE c_get_entity_by_org;
	END IF;

	IF (c_get_entity_by_ship%ISOPEN) THEN
		CLOSE c_get_entity_by_ship  ;
	END IF;

	IF (c_get_site_group%ISOPEN) THEN
		CLOSE c_get_site_group;
	END IF;

	IF ( c_get_cust_group%ISOPEN) THEN
		CLOSE c_get_cust_group;
	END IF;

	IF ( c_get_org_group%ISOPEN) THEN
		CLOSE c_get_org_group;
	END IF;

	IF (c_get_ship_group%ISOPEN) THEN
		CLOSE c_get_ship_group ;
	END IF;

        WSH_UTIL_CORE.default_handler('FTE_ACS_UTIL_PKG.get_candidate_records');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
        END IF;
        --
END GET_CANDIDATE_RECORDS;

--
-- R12 End Enhancement
--
END FTE_ACS_RULE_UTIL_PKG;

/
