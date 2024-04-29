--------------------------------------------------------
--  DDL for Package Body FTE_ESTIMATE_FREIGHT_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_ESTIMATE_FREIGHT_RATE" AS
/* $Header: FTEEFREB.pls 120.2 2005/07/26 14:06:56 schennal noship $ */
/*
-- Global constants
-- +======================================================================+
--   Procedure :
--          Freight Estimate Rate Search
--
--   Description:
--      Call the Process Lines API to get the service and rates
--      for the given inputs
--       Apply discount/markup on top of the recieved rates.
--   Inputs:
--     rate input parameters ( self explained )
--   Output:
--       Insert the rows into Temp Table to populate the rows in the UI.
--       Status, and messages data
--   DB:
-- +======================================================================+
*/

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_ESTIMATE_FREIGHT_RATE';
--

PROCEDURE Rate_Search(
      p_init_msg_list           IN  VARCHAR2 default fnd_api.g_false,
      p_api_version_number      IN  NUMBER  default 1.0,
      p_origin                  IN  VARCHAR2,
      p_destination             IN  VARCHAR2,
      p_org_location_id         IN  NUMBER,
      p_dest_location_id        IN  NUMBER,
      p_org_country             IN  VARCHAR2,
      p_dest_country            IN  VARCHAR2,
      p_weight                  IN  NUMBER,
      p_weight_uom              IN  VARCHAR2,
      p_volume                  IN  NUMBER,
      p_volume_uom              IN  VARCHAR2,
      p_distance                IN  NUMBER,
      p_distance_uom            IN  VARCHAR2,
      p_show_ltl_rates_flag     IN  VARCHAR2,
      p_show_tl_rates_flag      IN  VARCHAR2,
      p_show_parcel_rates_flag  IN  VARCHAR2,
      p_ship_date               IN  VARCHAR2,
      p_del_date                IN  VARCHAR2,
      p_carrier_id              IN  NUMBER,
      p_service_level           IN  VARCHAR2,
      p_md_type                 IN  VARCHAR2,  -- Markup / Discount Type (M/D)
      p_md_percent              IN  NUMBER,
      p_commodity_catg_id       IN  NUMBER,
      p_vehicle_type_id         IN  NUMBER,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2)
is

l_vehicle_type_id number;

-- Define cursor to get the item name for the given inv.item.id
-- Here vehicle type id considered as inv item id
-- This is used to get the Vehicle type as INPUT parameter only
cursor c_get_vehicle_name(p_vehicle_type_id number) is
    SELECT m.concatenated_segments
    FROM   mtl_system_items_vl m
    WHERE  m.inventory_item_id = p_vehicle_type_id
    AND    m.organization_id in ( select p.master_organization_id
           from mtl_parameters p)
    AND rownum = 1;

-- Here vehicle type id considered as vehicle type id itself
-- This is used to get the Vehicle type as OUTPUT parameter only
cursor c_get_vehicle_type_name(l_vehicle_type_id number) is
select mtl.concatenated_segments VehicleName
from mtl_system_items_kfv mtl, fte_vehicle_types veh
where mtl.vehicle_item_flag = 'Y'
and  mtl.inventory_item_id = veh.inventory_item_id
and veh.vehicle_type_id = l_vehicle_type_id
and rownum=1;

-- Define cursor to get the carrier name
cursor c_get_carrier_name(p_carrier_id number) is
select party_name from hz_parties
where party_id = p_carrier_id;

-- define cursor for global parameter for Volume
CURSOR c_get_volume_uom IS
SELECT GU_VOLUME_UOM
FROM wsh_global_parameters;

-- Define cursor to get lookup meaning for Mode and Service
cursor c_lookup_meaning (p_lookup_type varchar2, p_lookup_code varchar2 ) is
select meaning
from fnd_lookup_values_vl
where lookup_type = p_lookup_type
and nvl(start_date_active, sysdate) <= sysdate
and nvl(end_date_active, sysdate) >= sysdate
and lookup_code = p_lookup_code
and enabled_flag='Y';

l_modes varchar2(3);
l_count number;
l_line_count number;
/* declare the variables to call process_lines */

l_source_line_tab          FTE_PROCESS_REQUESTS.fte_source_line_tab;
l_source_header_tab        FTE_PROCESS_REQUESTS.fte_source_header_tab;
l_source_type              VARCHAR2(10) := 'FTE';
l_action                   VARCHAR2(30) := 'GET_ESTIMATE_RATE';
l_source_line_rates_tab    FTE_PROCESS_REQUESTS.fte_source_line_rates_tab;
l_source_header_rates_tab  FTE_PROCESS_REQUESTS.fte_source_header_rates_tab;
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_org_location_id         NUMBER := p_org_location_id;
l_dest_location_id        NUMBER := p_dest_location_id;

-- Define orign/destination variables to split into city/state/zip code
l_origin_state varchar2(500);
l_origin_city varchar2(500);
l_origin_zip varchar2(500);
l_destination_state varchar2(500);
l_destination_city varchar2(500);
l_destination_zip varchar2(500);

/* declare local variables to apply the discounts and getting the meanings of codes/ids */

l_del_date   DATE;
l_ship_date   DATE;
l_rate_temp_id number;
l_carrier   VARCHAR2(60);
l_prev_carrier_id NUMBER;
l_volume_uom  varchar2(3);
l_carrier_id   NUMBER;
l_mode_of_transport   VARCHAR2(30);
l_prev_mode_of_transport   VARCHAR2(30);
l_mode_of_transport_parcel VARCHAR2(30);
l_mode_of_transport_tl VARCHAR2(30);
l_mode_of_transport_ltl VARCHAR2(30);
l_mode_of_transport_meaning varchar2(80);
l_service_level   VARCHAR2(60);
l_prev_service_level   VARCHAR2(30);
l_vehicle_type    VARCHAR2(60);
l_base_price      number ;
l_accessorial_charges number ;
l_estimated_rate  number;
l_markup_discount_value number;
l_base_price_c  varchar2(60);
l_estimated_rate_c  varchar2(60);
l_accessorial_charges_c varchar2(60);
l_currency_code   VARCHAR2(30);
l_markup_discount_value_c varchar2(60);
l_est_transit_time   NUMBER;
l_time_feasible_flag VARCHAR2(1);

l_org_error_flag varchar2(1);

l_precision number;
l_ext_precision number;
l_min_acct_unit number;

-- Define exception variables
e_process_lines_api_failed EXCEPTION;
e_no_data_found  EXCEPTION;
e_invalid_carrier  EXCEPTION;
e_invalid_vehicle EXCEPTION;
e_invalid_service_level  EXCEPTION;
e_invalid_mode_of_transport  EXCEPTION;
e_failed_split_csz_api  EXCEPTION;
e_org_is_too_long  EXCEPTION;
e_dest_is_too_long  EXCEPTION;
e_org_dest_is_too_long  EXCEPTION;
--
l_debug_on BOOLEAN;
l_debugfile     varchar2(2000);

--
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'RATE_SEARCH';
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
     fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
     l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'Begin of the process ',l_debugfile);

  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- delete to refresh the data from Global Temp Table
  delete from FTE_FREIGHT_ESTIMATE_TEMP;
  -- initialize old message from stack
  FND_MSG_PUB.initialize;
  -- passing null instead of 0 from UI for those null values
  if p_volume_uom is null then
     OPEN c_get_volume_uom;
     FETCH c_get_volume_uom INTO l_volume_uom;
     CLOSE c_get_volume_uom;
  end if;

  if nvl(p_carrier_id,0) = 0 then
     l_carrier_id := null;
  else
     l_carrier_id := p_carrier_id;
  end if;
  -- Building the array for multi-modes
  if p_show_parcel_rates_flag = 'Y' then
     l_mode_of_transport_parcel := 'PARCEL';
     l_modes := l_modes||'P';
  end if;
  if p_show_tl_rates_flag = 'Y' then
     l_mode_of_transport_tl := 'TRUCK';
     l_modes := l_modes||'T';
  end if;
  if p_show_ltl_rates_flag = 'Y' then
     l_mode_of_transport_ltl := 'LTL';
     l_modes := l_modes||'L';
  end if;

  l_ship_date   := fnd_date.DISPLAYDT_TO_DATE(p_ship_date,'YYYY-MM-DD HH24:MI:SS');

  if p_del_date is null then
     l_del_date   := sysdate;
  else
     l_del_date   := fnd_date.DISPLAYDT_TO_DATE(p_del_date,'YYYY-MM-DD HH24:MI:SS');
     --dbms_output.put_line('ship_date-2 :'||l_ship_date);
  end if;
  -- Splitting Orgin into City, State and ZIP Code.
  l_org_error_flag := 'N' ;
  if nvl(p_org_location_id,0) = 0 then
     l_org_location_id := null;
     FTE_ESTIMATE_FREIGHT_RATE.SPLIT_CITY_STATE_ZIP
     (p_city_state_zip=>p_origin,
      x_city  =>l_origin_city,
      x_state =>l_origin_state,
      x_zip   =>l_origin_zip,
      x_return_status=>l_return_status);
      if l_return_status <> 'S' then
         --dbms_output.put_line('Error '||sqlerrm );
         raise e_failed_split_csz_api;
      end if ;
      -- Validating that City/State/Zip should not be greater than 30 characters
      if (length(l_origin_city) > 30 or
          length(l_origin_state) > 30 or
          length(l_origin_zip) > 30 ) then
          --dbms_output.put_line('Error long origin '|| p_dest_location_id);

          l_org_error_flag := 'Y' ;

          if nvl(p_dest_location_id,0) <> 0 then
            raise e_org_is_too_long;
          end if;
      end if;
      --dbms_output.put_line('Origin : '||p_origin||'-'||l_origin_city||'-'||
       --                     l_origin_state||'-'||l_origin_zip);
  end if;
  -- Splitting Destination into City, State and ZIP Code.
  if nvl(p_dest_location_id,0) = 0  then
     l_dest_location_id := null;
     FTE_ESTIMATE_FREIGHT_RATE.SPLIT_CITY_STATE_ZIP
     (p_city_state_zip=>p_destination,
      x_city  =>l_destination_city,
      x_state =>l_destination_state,
      x_zip   =>l_destination_zip,
      x_return_status=>l_return_status);
      if l_return_status <> 'S' then
         raise e_failed_split_csz_api;
         --dbms_output.put_line('Error in .SPLIT_CITY_STATE_ZIP '||sqlerrm );
        -- dbms_output.put_line('Error '||sqlerrm );
      end if ;
      -- Validating that City/State/Zip should not be greater than 30 characters
      if (length(l_destination_city) > 30 or
          length(l_destination_state) > 30 or
          length(l_destination_zip) > 30 ) then

         --dbms_output.put_line('Error long dest ');

          if l_org_error_flag = 'Y' then
         --dbms_output.put_line('Error both ');
             raise e_org_dest_is_too_long;
          else

         --dbms_output.put_line('Error nly dest is long ');
             raise e_dest_is_too_long;
          end if;
      else
         if l_org_error_flag = 'Y' then
           raise e_org_is_too_long;
         end if;
      end if;
      --dbms_output.put_line('Dest : '||p_destination||'-'||l_destination_city||'-'|| l_destination_state||'-'||l_destination_zip);
  end if;

  --dbms_output.put_line('you are here - 1');
  --for all modes
  l_count := 1;
  -- Header Information input
  --for all modes
  l_count := 1;
  -- Header Information input
  l_source_header_tab(l_count).consolidation_id            := l_count;
  l_source_header_tab(l_count).ship_from_location_id       := l_org_location_id;
  l_source_header_tab(l_count).ship_to_location_id         := l_dest_location_id;
  l_source_header_tab(l_count).ship_date                   := l_ship_date;
  l_source_header_tab(l_count).arrival_date                := l_del_date;
  l_source_header_tab(l_count).total_weight                := p_weight;
  l_source_header_tab(l_count).weight_uom_code             := p_weight_uom;
  l_source_header_tab(l_count).total_volume                := p_volume;
  l_source_header_tab(l_count).volume_uom_code             := nvl(p_volume_uom,l_volume_uom);
  l_source_header_tab(l_count).distance                    := p_distance;
  l_source_header_tab(l_count).distance_uom                := p_distance_uom;
  l_source_header_tab(l_count).carrier_id                  := l_carrier_id;
  l_source_header_tab(l_count).service_level               := p_service_level;
  l_source_header_tab(l_count).origin_country              := p_org_country;
  --dbms_output.put_line('you are here - 1--1');
  l_source_header_tab(l_count).origin_city                 := l_origin_city;
  l_source_header_tab(l_count).origin_state                := l_origin_state;
  l_source_header_tab(l_count).origin_zip                  := l_origin_zip;
  --dbms_output.put_line('you are here - 1--2');
  l_source_header_tab(l_count).destination_country         := p_dest_country;
  l_source_header_tab(l_count).destination_state           := l_destination_state;
  l_source_header_tab(l_count).destination_city            := l_destination_city;
  l_source_header_tab(l_count).destination_zip             := l_destination_zip;
  l_source_header_tab(l_count).commodity_category_id      := p_commodity_catg_id;
  l_source_header_tab(l_count).vehicle_item_id             := p_vehicle_type_id;
  -- Lines Information input
  l_source_line_tab(l_count).source_type         := 'FTE';
  l_source_line_tab(l_count).source_line_id      := l_count;
  l_source_line_tab(l_count).consolidation_id      := l_count;
  l_source_line_tab(l_count).ship_date := l_ship_date;
  l_source_line_tab(l_count).arrival_date := l_del_date;
  l_source_line_tab(l_count).carrier_id := l_carrier_id;
  l_source_line_tab(l_count).service_level := p_service_level;
  l_source_line_tab(l_count).weight := p_weight;
  l_source_line_tab(l_count).weight_uom_code := p_weight_uom;
  l_source_line_tab(l_count).volume := p_volume;
  l_source_line_tab(l_count).volume_uom_code := p_volume_uom;
  l_source_line_tab(l_count).ship_from_location_id := l_org_location_id;
  l_source_line_tab(l_count).ship_to_location_id := l_dest_location_id;
  l_source_line_tab(l_count).origin_country := p_org_country;
  l_source_line_tab(l_count).origin_state   := l_origin_state;
  l_source_line_tab(l_count).origin_city    := l_origin_city;
  l_source_line_tab(l_count).origin_zip     := l_origin_zip;
  l_source_line_tab(l_count).destination_country := p_dest_country;
  --dbms_output.put_line('you are here - 1-1');
  l_source_line_tab(l_count).destination_state   := l_destination_state;
  l_source_line_tab(l_count).destination_city    := l_destination_city;
  l_source_line_tab(l_count).destination_zip     := l_destination_zip;
  --dbms_output.put_line('you are here - a1');
  l_source_line_tab(l_count).distance            := p_distance;
  l_source_line_tab(l_count).distance_uom        := p_distance_uom;
  l_source_line_tab(l_count).vehicle_item_id     := p_vehicle_type_id;
  l_source_line_tab(l_count).commodity_category_id := p_commodity_catg_id;
  --dbms_output.put_line('you are here - 3');

  /* Get Vehicle Name */
  --dbms_output.put_line('Vehicle type id  :'||p_vehicle_type_id);
  if p_vehicle_type_id is not null then
     open c_get_vehicle_name(p_vehicle_type_id);
     if c_get_vehicle_name%notfound then
        --dbms_output.put_line('Vehicle type id-2  :'||p_vehicle_type_id);
        close c_get_vehicle_name;
        raise e_invalid_vehicle;
     end if;
     fetch c_get_vehicle_name into l_vehicle_type;
     close c_get_vehicle_name;
  end if;
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Vehicle Name ',l_vehicle_type);
  END IF;
  --dbms_output.put_line('Vehicle name :'||l_vehicle_type);
  -- Building multiple records in the table based on the no of modes passed.
  LOOP
     --dbms_output.put_line('no of modes '||length(l_modes));
     -- populate the info to all records since the data is same
     l_source_line_tab(l_count) := l_source_line_tab(1);
     l_source_header_tab(l_count) := l_source_header_tab(1);

     -- getting the appropriate mode
     if substr(l_modes,l_count,1) = 'P' then  -- PARCEL
        l_mode_of_transport := l_mode_of_transport_parcel;
     elsif substr(l_modes,l_count,1) = 'T' then   -- TRUCK
        l_mode_of_transport := l_mode_of_transport_tl;
     else   -- LTL
        l_mode_of_transport := l_mode_of_transport_ltl;
     end if;
     l_source_header_tab(l_count).consolidation_id := l_count;
     l_source_line_tab(l_count).consolidation_id := l_count;
     l_source_line_tab(l_count).mode_of_transport := l_mode_of_transport;
     l_source_header_tab(l_count).mode_of_transport  := l_mode_of_transport;
     -- for next mode
     l_count :=l_count+1;
     if length(l_modes)<l_count then
        exit;
     end if;
  END LOOP;
  --dbms_output.put_line('no of records '||l_source_line_tab.COUNT);

  FTE_PROCESS_REQUESTS.Process_Lines(
     p_source_line_tab          =>l_source_line_tab,
     p_source_header_tab        =>l_source_header_tab,
     p_source_type              =>l_source_type,
     p_action                   =>l_action,
     x_source_line_rates_tab    =>l_source_line_rates_tab,
     x_source_header_rates_tab  =>l_source_header_rates_tab,
     x_return_status            =>l_return_status,
     x_msg_count                =>l_msg_count,
     x_msg_data                 =>l_msg_data );
  if l_return_status not in ('S','W') then
     raise e_process_lines_api_failed;
  end if;
  l_count := l_source_header_rates_tab.count;
  -- No records to process
  if nvl(l_count,0) = 0 then
     raise e_no_data_found;
  end if;
  l_count := l_source_header_rates_tab.FIRST;
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'No of records header : ',l_source_header_rates_tab.count);
     WSH_DEBUG_SV.log(l_module_name,'No of records lines : ',l_source_line_rates_tab.count);
  END IF;

  LOOP
  --dbms_output.put_line('you are here - carrier id '||l_source_header_rates_tab(l_count).carrier_id);
    /* Get Carrier Name */
    if nvl(l_source_header_rates_tab(l_count).carrier_id,-99) <> nvl(l_prev_carrier_id,-99) then
       open c_get_carrier_name(l_source_header_rates_tab(l_count).carrier_id);
       if c_get_carrier_name%notfound then
          close c_get_carrier_name;
          raise e_invalid_carrier;
       end if;
       fetch c_get_carrier_name into l_carrier;
       close c_get_carrier_name;
       l_prev_carrier_id := l_source_header_rates_tab(l_count).carrier_id;
    end if;
  --dbms_output.put_line('you are here - 5');
    /* Get Vehicle Name */
    if ((p_vehicle_type_id is null or p_vehicle_type_id = 0) and l_source_header_rates_tab(l_count).vehicle_type_id is not null) then
       if nvl(l_vehicle_type_id,-99) <> nvl(l_source_header_rates_tab(l_count).vehicle_type_id,-99) then
       --{
          l_vehicle_type := null;
          l_vehicle_type_id := l_source_header_rates_tab(l_count).vehicle_type_id;
          --dbms_output.put_line('Vehicle id :'||l_vehicle_type_id||'-'||l_vehicle_type);
          open c_get_vehicle_type_name(l_vehicle_type_id);
          if c_get_vehicle_type_name%notfound then
             close c_get_vehicle_type_name;
             raise e_invalid_vehicle;
          end if;
          fetch c_get_vehicle_type_name into l_vehicle_type;
          close c_get_vehicle_type_name;
       end if;
    end if;
    --dbms_output.put_line('Vehicle name-2 :'||l_vehicle_type_id||'-'||l_vehicle_type);
    /*Lookup Types-- 'WSH_SERVICE_LEVELS', 'WSH_MODE_OF_TRANSPORT' */
    /* Get Service Level*/
    if nvl(l_prev_service_level,'XX') <> nvl(l_source_header_rates_tab(l_count).service_level,'XX') then
       open c_lookup_meaning('WSH_SERVICE_LEVELS',
                           l_source_header_rates_tab(l_count).service_level);
       if c_lookup_meaning%notfound then
          close c_lookup_meaning;
          raise e_invalid_service_level;
       end if;
       fetch c_lookup_meaning into l_service_level;
       close c_lookup_meaning;
       l_prev_service_level := l_source_header_rates_tab(l_count).service_level;
    end if;
  --dbms_output.put_line('you are here - 6');
    /* Get Mode of Transport */
    if nvl(l_prev_mode_of_transport,'XX') <> nvl(l_source_header_rates_tab(l_count).mode_of_transport,'XX') then
       open c_lookup_meaning('WSH_MODE_OF_TRANSPORT',
                           l_source_header_rates_tab(l_count).mode_of_transport);
       if c_lookup_meaning%notfound then
          close c_lookup_meaning;
          raise e_invalid_mode_of_transport;
       end if;
       fetch c_lookup_meaning into l_mode_of_transport_meaning;
       close c_lookup_meaning;
       l_prev_mode_of_transport :=l_source_header_rates_tab(l_count).mode_of_transport;
    end if;
  --dbms_output.put_line('you are here - 7');
    l_est_transit_time   := l_source_header_rates_tab(l_count).transit_time;
    l_time_feasible_flag := 'N';

    if nvl(l_est_transit_time,0) = 0 or p_del_date is null or
       ((l_del_date - l_ship_date) >= nvl(l_est_transit_time,0)) then
       l_time_feasible_flag := 'Y';
    end if;

  --dbms_output.put_line('you are here - 8');
    l_currency_code :=l_source_header_rates_tab(l_count).currency ;
   /* get the rounding factor  before the calculation due to 0.01 descrepancy */
   FND_CURRENCY.GET_INFO(
     CURRENCY_CODE=>l_currency_code,
     PRECISION    =>l_precision,
     EXT_PRECISION =>l_ext_precision,
     MIN_ACCT_UNIT=>l_min_acct_unit);
    -- For each Line ( BASE Price and Acc Charge)
    l_line_count := l_source_header_rates_tab(l_count).first_line_index;
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Mode at header level : ',l_mode_of_transport_meaning);
       WSH_DEBUG_SV.log(l_module_name,'Carrier at header level : ',l_carrier);
       WSH_DEBUG_SV.log(l_module_name,'Vehicle at header level : ',l_vehicle_type);
       WSH_DEBUG_SV.log(l_module_name,'Service at header level : ',l_service_level);
    END IF;
    -- initialized the variable for each header
    l_base_price      := 0;
    l_accessorial_charges := 0;
    l_estimated_rate  := 0;
    l_markup_discount_value := 0;
    LOOP
  --dbms_output.put_line('you are here - line type '||l_source_line_rates_tab(l_line_count).line_type_code);
  --dbms_output.put_line('you are here - line-consolidationid '||l_source_line_rates_tab(l_line_count).consolidation_id);
  --dbms_output.put_line('you are here - header-consolidationid '||l_source_header_rates_tab(l_count).consolidation_id);
  --dbms_output.put_line('you are here - header-lane_id '||l_source_header_rates_tab(l_count).lane_id);
  --dbms_output.put_line('you are here - line-lane_id '||l_source_line_rates_tab(l_line_count).lane_id);
  --dbms_output.put_line('you are here - header-carrier_id '||l_source_header_rates_tab(l_count).carrier_id);
  --dbms_output.put_line('you are here - line-carrier_id '||l_source_line_rates_tab(l_line_count).carrier_id);
  --dbms_output.put_line('you are here - cost type '||l_source_line_rates_tab(l_line_count).cost_type);
  --dbms_output.put_line('you are here -base price '||l_source_line_rates_tab(l_line_count).adjusted_price);
       -- If consolidation id does not match between header and line
       -- no more rate for the given header
       if ((l_source_header_rates_tab(l_count).consolidation_id <>
           l_source_line_rates_tab(l_line_count).consolidation_id)
          or (l_source_header_rates_tab(l_count).lane_id <>
              l_source_line_rates_tab(l_line_count).lane_id)
          or (nvl(l_source_header_rates_tab(l_count).vehicle_type_id,-99) <>
                nvl(l_source_line_rates_tab(l_line_count).vehicle_type_id,-99))
          or  (nvl(l_source_header_rates_tab(l_count).service_level,'XX') <>
              nvl(l_source_line_rates_tab(l_line_count).service_level,'XX'))) then
          EXIT;
       end if;
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Lane ID at line level : ',l_source_line_rates_tab(l_line_count).lane_id);
          WSH_DEBUG_SV.log(l_module_name,'Consol ID at line level : ',l_source_line_rates_tab(l_line_count).consolidation_id);
          WSH_DEBUG_SV.log(l_module_name,'Carrier at line level : ',l_source_line_rates_tab(l_line_count).carrier_id);
          WSH_DEBUG_SV.log(l_module_name,'Service at line level : ',l_source_line_rates_tab(l_line_count).service_level);
          WSH_DEBUG_SV.log(l_module_name,'Vehicle at line level : ',l_source_line_rates_tab(l_line_count).vehicle_type_id);
          WSH_DEBUG_SV.log(l_module_name,'Cost Type at line level : ',l_source_line_rates_tab(l_line_count).cost_type);
          WSH_DEBUG_SV.log(l_module_name,'Adjusted Price at line level : ',l_source_line_rates_tab(l_line_count).adjusted_price);
       END IF;

  --dbms_output.put_line('you are here - 10');
       /* rounding to 4 decimal */
       if (l_source_line_rates_tab(l_line_count).line_type_code = 'PRICE' and
          l_source_line_rates_tab(l_line_count).cost_type = 'FTEPRICE') then

          --l_base_price := round(nvl(l_source_line_rates_tab(l_line_count).base_price,0),l_precision);
          -- replacing base_price with adjusted_price to apply the discounted price
          l_base_price := round(nvl(l_source_line_rates_tab(l_line_count).adjusted_price,0),l_precision);

       elsif (l_source_line_rates_tab(l_line_count).line_type_code = 'CHARGE' and
              l_source_line_rates_tab(l_line_count).cost_type = 'FTECHARGE') then

          l_accessorial_charges := round(nvl(l_source_line_rates_tab(l_line_count).adjusted_price,0),l_precision);

       end if;
  --dbms_output.put_line('you are here - 11');
       if l_line_count = l_source_line_rates_tab.LAST then
          exit;
       else
          l_line_count := l_source_line_rates_tab.NEXT(l_line_count);
       end if;

    END LOOP;
    -- Calculate Discount Amount
  --dbms_output.put_line('you are here - 12');
    if p_md_type is not null then
       l_markup_discount_value :=round((((l_base_price+l_accessorial_charges)*p_md_percent)/100),l_precision);
    end if;
    if p_md_type = 'D' then
       l_estimated_rate := l_base_price+l_accessorial_charges-l_markup_discount_value;
    elsif  p_md_type = 'M' then
       l_estimated_rate := l_base_price+l_accessorial_charges+l_markup_discount_value;
    else
       l_estimated_rate := l_base_price+l_accessorial_charges;
    end if;
    l_estimated_rate := round(l_estimated_rate,l_precision);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Base Price : ',l_base_price);
       WSH_DEBUG_SV.log(l_module_name,'Acc.Charge : ',l_accessorial_charges);
       WSH_DEBUG_SV.log(l_module_name,'Markup-Discount : ',l_markup_discount_value);
       WSH_DEBUG_SV.log(l_module_name,'Estimated Rate : ',l_estimated_rate);
       WSH_DEBUG_SV.logmsg(l_module_name,'inserting the row into temp table ');
    END IF;
    -- Padding currency with amount columns to display in the UI
    -- There is no currency conversion since there will be same currency for Charges and Base price
/* not required since it is taking care of at UI level
    l_estimated_rate_c := to_char(l_estimated_rate)||' '||l_currency_code;

    l_base_price_c := to_char(l_base_price)||' '||l_currency_code;

    l_accessorial_charges_c := to_char(l_accessorial_charges)||' '||l_currency_code;
    if p_md_type = 'D' then
    END IF;
    -- Padding currency with amount columns to display in the UI
    -- There is no currency conversion since there will be same currency for Charges and Base price
/* not required since it is taking care of at UI level
    l_estimated_rate_c := to_char(l_estimated_rate)||' '||l_currency_code;

    l_base_price_c := to_char(l_base_price)||' '||l_currency_code;

    l_accessorial_charges_c := to_char(l_accessorial_charges)||' '||l_currency_code;
    if p_md_type = 'D' then
       l_markup_discount_value_c := '( '||l_markup_discount_value||' ) '||l_currency_code;
    else
       l_markup_discount_value_c := l_markup_discount_value||' '||l_currency_code;
    end if;
*/
  --dbms_output.put_line('you are here - inserting row for '||l_carrier||' '||l_count);
    INSERT into FTE_FREIGHT_ESTIMATE_TEMP
        (
         RATE_TEMP_ID ,
         CARRIER      ,
         MODE_OF_TRANSPORT ,
         SERVICE_LEVEL     ,
         VEHICLE_TYPE      ,
         ESTIMATED_RATE    ,
         BASE_PRICE        ,
         ACCESSORIAL_CHARGES ,
         MARKUP_DISCOUNT_TYPE ,
         MARKUP_DISCOUNT_VALUE ,
         CURRENCY_CODE,
         EST_TRANSIT_TIME   ,
         TIME_FEASIBLE_FLAG ,
         CREATED_BY         ,
         CREATION_DATE      ,
         LAST_UPDATED_BY    ,
         LAST_UPDATE_DATE   ,
         LAST_UPDATE_LOGIN
         )
         values
         (
         FTE_FREIGHT_COSTS_TEMP_S.nextval,
         l_carrier      ,
         l_mode_of_transport_meaning ,
         l_service_level     ,
         decode(l_source_header_rates_tab(l_count).mode_of_transport,'TRUCK',l_vehicle_type,null) ,
         l_estimated_rate    ,
         l_base_price        ,
         l_accessorial_charges ,
         p_md_type ,
         l_markup_discount_value ,
         l_currency_code,
         l_est_transit_time   ,
         l_time_feasible_flag ,
         fnd_global.user_id,
         sysdate ,
         fnd_global.user_id ,
         sysdate ,
         fnd_global.login_id
         );
         if (SQL%NOTFOUND) then
            raise e_no_data_found;
         end if;
  --dbms_output.put_line('you are here - mode '||l_source_header_rates_tab(l_count).mode_of_transport);
  --dbms_output.put_line('you are here - after inserting row for '||l_carrier||' '||l_count);
       if l_count = l_source_header_rates_tab.LAST then
          exit;
       else
          l_count := l_source_header_rates_tab.NEXT(l_count);
       end if;
   END LOOP;
  x_return_status := l_return_status;
  --commit;
EXCEPTION
WHEN e_org_is_too_long then
    FND_MESSAGE.SET_NAME('FTE','FTE_ORG_TOO_LONG');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

WHEN e_dest_is_too_long then
    FND_MESSAGE.SET_NAME('FTE','FTE_DEST_TOO_LONG');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

WHEN e_org_dest_is_too_long then
    FND_MESSAGE.SET_NAME('FTE','FTE_ORG_DEST_TOO_LONG');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

WHEN e_process_lines_api_failed then
    FND_MESSAGE.SET_NAME('FTE','FTE_PROCESS_LINE_API_FAILED');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    --dbms_output.put_line('API FTE_PROCESS_LINE_API_FAILED call failed '||sqlerrm );

WHEN e_invalid_service_level THEN
    FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_SERVICE_LEVEL');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

WHEN e_invalid_mode_of_transport THEN
    FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_MODE');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

WHEN e_invalid_carrier THEN
    FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_CARRIER');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

WHEN e_invalid_vehicle THEN
    FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_VEHICLE');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

WHEN e_failed_split_csz_api THEN
    FND_MESSAGE.SET_NAME('FTE','FTE_FAILED_SPLIT_CSZ_API');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

WHEN e_no_data_found THEN
    FND_MESSAGE.SET_NAME('FTE','FTE_NO_RATE_EXISTS');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

WHEN others then
   wsh_util_core.default_handler('FTE_ESTIMATE_FREIGHT_RATE.RATE_SEARCH');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   --dbms_output.put_line('Unhandled Exception '||sqlerrm );
END;

/*  This API will be used to split city_state_zip into city state zip
INPUTS can be maximum 3 values seperated by comma
if there are 3, it will be converted city, state, zip
if there are 2, it will be converted state, zip
if there are 1, it will be converted zip
*/

PROCEDURE SPLIT_CITY_STATE_ZIP (
  p_city_state_zip IN VARCHAR2,
  x_city           OUT NOCOPY VARCHAR2,
  x_state          OUT NOCOPY VARCHAR2,
  x_zip            OUT NOCOPY VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2)
 IS
l_csz varchar2(2000) := p_city_state_zip;
l_length number;
l_1st_position number;
l_2nd_position number;
i number;
l_zip_exists_flag VARCHAR2(1) := 'N';
BEGIN
   l_length := length(trim(l_csz));
   l_1st_position := instr(l_csz,',');
   l_2nd_position := instr(substr(l_csz,l_1st_position+1),',');
   x_city  := trim(substr(l_csz,1,l_1st_position-1));
   x_state := trim(substr(l_csz,l_1st_position+1,l_2nd_position-1));
   x_zip   := trim(substr(l_csz,l_1st_position+l_2nd_position+1));
   i := 1;
   while (i <= length(x_zip) )
   loop
     if ascii(substr(x_zip,i,1)) >= 48 and ascii(substr(x_zip,i,1)) <= 57 then
        l_zip_exists_flag := 'Y';
        exit;
     end if;
     i := i + 1;
   end loop;
   if l_zip_exists_flag = 'Y'then
     --dbms_output.put_line('Ascii value '|| ascii(x_zip));
     if x_state is null then
        x_state := x_city;
        x_city := null;
     end if;
   else
     if x_state is null then
        x_state := x_zip;
        x_zip := null;
     end if;
   end if;
   x_return_status:= 'S' ;
EXCEPTION
  WHEN OTHERS
  THEN
     x_return_status:= 'E';
     raise;
end;

END FTE_ESTIMATE_FREIGHT_RATE;

/
