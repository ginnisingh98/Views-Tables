--------------------------------------------------------
--  DDL for Package Body MST_AGG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_AGG_PKG" AS
/*$Header: MSTAGGQB.pls 115.46 2004/07/01 14:41:21 skakani noship $ */
/* Plan Summary*/
  function get_loads_count(p_plan_id in number)
    return number is
  l_count number;
  begin
    select count(1)
    into l_count
    from mst_trips
    where plan_id = p_plan_id
	and nvl(move_type, 2) <> 1;
    return l_count;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 0;
  end;

  function get_trip_count(p_plan_id in number, p_mode_of_transport in varchar2)
    return number is
  l_count number;
  begin
    select count(1)
    into l_count
    from mst_trips
    where plan_id = p_plan_id
    and mode_of_transport = p_mode_of_transport
    and nvl(move_type, 2) <> 1 ;
    return l_count;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 0;
  end;

  function get_cm_count(p_plan_id in number)
    return number is
  l_count number;
  begin
    select count(1)
    into l_count
    from mst_cm_trips
    where plan_id = p_plan_id;
    return l_count;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 0;
  end;

  function get_loads_orders(p_plan_id in number)
    return number is
  l_count number;
  begin
    select total_orders
    into l_count
    from mst_plans
    where plan_id = p_plan_id;
    return l_count;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 0;
  end;

  function get_trip_orders(p_plan_id in number, p_mode_of_transport in varchar2)
    return number is
  l_count number;
  begin
    select decode(p_mode_of_transport, 'TRUCK', total_tl_orders, 'LTL', total_ltl_orders, 'PARCEL', total_parcel_orders, 0)
    into l_count
    from mst_plans
    where plan_id = p_plan_id;
    return l_count;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 0;
  end;

  function get_cm_orders(p_plan_id in number)
    return number is
  l_count number;
  begin
    select total_cm_orders
    into l_count
    from mst_plans
    where plan_id = p_plan_id;
    return l_count;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 0;
  end;


  function get_unassigned_order_count(p_plan_id in number)
    return number is
  l_count number;
  begin
    select count(1)
    into l_count
    from mst_deliveries
    where plan_id = p_plan_id
    and delivery_id not in (
      select delivery_id
      from mst_delivery_legs
      where plan_id = p_plan_id
     );
    return nvl(l_count,0);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 0;
  end;

  function get_unassigned_order_weight(p_plan_id in number)
    return number is
  l_count number;
  begin
    select sum(gross_weight)
    into l_count
    from mst_deliveries
    where plan_id = p_plan_id
    and delivery_id not in (
      select delivery_id
      from mst_delivery_legs
      where plan_id = p_plan_id
     );
    return nvl(l_count,0);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 0;
  end;
  function get_unassigned_order_cube(p_plan_id in number)
    return number is
  l_count number;
  begin
    select sum(volume)
    into l_count
    from mst_deliveries
    where plan_id = p_plan_id
    and delivery_id not in (
      select delivery_id
      from mst_delivery_legs
      where plan_id = p_plan_id
     );
    return nvl(l_count,0);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 0;
  end;

  function get_unassigned_order_pieces(p_plan_id in number)
    return number is
  l_count number;
  begin
    select sum(number_of_pieces)
    into l_count
    from mst_deliveries
    where plan_id = p_plan_id
    and delivery_id not in (
      select delivery_id
      from mst_delivery_legs
      where plan_id = p_plan_id
     );
    return nvl(l_count,0);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 0;
  end;

    function get_unassigned_order_pallets(p_plan_id in number)
    return number is
  l_count number;
  begin
    select sum(number_of_pallets)
    into l_count
    from mst_deliveries
    where plan_id = p_plan_id
    and delivery_id not in (
      select delivery_id
      from mst_delivery_legs
      where plan_id = p_plan_id
     );
    return nvl(l_count,0);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 0;
  end;

/* All Truckloads Summary */
  function get_summary_fixed_charge(p_plan_id in number, p_mode in varchar2)
    return number is
  l_fixed_charge number;
  begin
    select sum(total_basic_transport_cost)
    into l_fixed_charge
    from mst_trips
    where plan_id = p_plan_id
    and mode_of_transport = p_mode;
    return l_fixed_charge;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_fixed_charge := 0;
        return l_fixed_charge;
  end;

  function get_summary_stop_charge(p_plan_id in number)
    return number is
  l_stop_charge number;
  begin
    select sum(total_stop_cost)
    into l_stop_charge
    from mst_trips
    where plan_id = p_plan_id
    and mode_of_transport = 'TRUCK';
    return l_stop_charge;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_stop_charge := 0;
    return l_stop_charge;
  end;

  function get_summary_ld_unld_charge(p_plan_id in number)
    return number is
  l_ld_unld_charge number;
  begin
    select sum(total_load_unload_cost)
    into l_ld_unld_charge
    from mst_trips
    where plan_id = p_plan_id
    and mode_of_transport = 'TRUCK';
    return l_ld_unld_charge;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_ld_unld_charge := 0;
    return l_ld_unld_charge;
  end;

  function get_summary_layover_charge(p_plan_id in number)
    return number is
  l_layover_charge number;
  begin
    select sum(total_layover_cost)
    into l_layover_charge
    from mst_trips
    where plan_id = p_plan_id
    and mode_of_transport = 'TRUCK';
    return l_layover_charge;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_layover_charge := 0;
    return l_layover_charge;
  end;

  function get_summary_assessorial_charge(p_plan_id in number, p_mode in varchar2)
    return number is
  l_assessorial_charge number;
  begin
    select sum(total_accessorial_cost)
    into l_assessorial_charge
    from mst_trips
    where plan_id = p_plan_id
    and mode_of_transport = p_mode;
    return l_assessorial_charge;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_assessorial_charge := 0;
    return l_assessorial_charge;
  end;

/* TruckLoad Details */
FUNCTION Get_alloc_cost_for_delivery(p_plan_id IN NUMBER,
                                     p_delivery_id IN NUMBER)
    RETURN NUMBER IS

    CURSOR cur_alloc_cost IS
    SELECT SUM(dd.allocated_Cost)
    FROM   mst_delivery_details dd,
           mst_delivery_assignments da
    WHERE  dd.plan_id = p_plan_id
    AND    da.plan_id = dd.plan_id
    AND    da.delivery_detail_id = dd.delivery_detail_id
    and    da.parent_delivery_detail_id is null
    AND    da.delivery_id = p_delivery_id;

    l_cost NUMBER;

BEGIN
    OPEN cur_alloc_cost;
    FETCH cur_alloc_cost INTO l_cost;
    CLOSE cur_alloc_cost;
    RETURN l_cost;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END Get_alloc_cost_for_delivery;

/* Vehicle Trip Stop Details */
  function get_loading_charge(p_plan_id IN NUMBER,
                              p_stop_id in number)
    return number is
  l_loading_charge number;
  begin
    -- SQL repository issues as on 25-05-04:
      -- Added new parameter plan_id
      -- Added join for plan id
    select sum(mdl.allocated_fac_loading_cost)
    into l_loading_charge
    from mst_trip_stops mts,
         mst_delivery_legs mdl
    where mts.stop_id = p_stop_id
    AND mts.plan_id = P_PLAN_ID
    AND mts.plan_id = mdl.plan_Id
    and mts.stop_id = mdl.pick_up_stop_id;
    return l_loading_charge;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

  function get_unloading_charge(p_stop_id in number)
    return number is
  l_unloading_charge number;
  begin
    select sum(mdl.allocated_fac_unloading_cost)
    into l_unloading_charge
    from mst_trip_stops mts,
         mst_delivery_legs mdl
    where mts.stop_id = p_stop_id
    and mts.stop_id = mdl.drop_off_stop_id;
    return l_unloading_charge;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;
-- Loading Weight/Cube/Pallets/Pieces
  function get_loading_weight(p_stop_id in number)
    return number is
  l_loading_weight number;
  begin
    select sum(md.gross_weight)
    into l_loading_weight
    from mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mts.stop_id = p_stop_id
    and mts.stop_id = mdl.pick_up_stop_id
    and mdl.delivery_id = md.delivery_id;
    return l_loading_weight;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

  function get_loading_volume(p_stop_id in number)
    return number is
  l_loading_volume number;
  begin
    select sum(md.volume)
    into l_loading_volume
    from mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mts.stop_id = p_stop_id
    and mts.stop_id = mdl.pick_up_stop_id
    and mdl.delivery_id = md.delivery_id;
    return l_loading_volume;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

  function get_loading_pallets(p_stop_id in number)
    return number is
  l_loading_pallets number;
  begin
    select sum(md.volume)
    into l_loading_pallets
    from mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mts.stop_id = p_stop_id
    and mts.stop_id = mdl.pick_up_stop_id
    and mdl.delivery_id = md.delivery_id;
    return l_loading_pallets;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

  function get_loading_pieces(p_stop_id in number)
    return number is
  l_loading_pieces number;
  begin
    select sum(md.number_of_pieces)
    into l_loading_pieces
    from mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mts.stop_id = p_stop_id
    and mts.stop_id = mdl.pick_up_stop_id
    and mdl.delivery_id = md.delivery_id;
    return l_loading_pieces;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

-- Unloading Weight/Cube/Pallets/Pieces
  function get_unloading_weight(p_stop_id in number)
    return number is
  l_unloading_weight number;
  begin
    select sum(md.gross_weight)
    into l_unloading_weight
    from mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mts.stop_id = p_stop_id
    and mts.stop_id = mdl.drop_off_stop_id
    and mdl.delivery_id = md.delivery_id;
    return l_unloading_weight;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

  function get_unloading_volume(p_stop_id in number)
    return number is
  l_unloading_volume number;
  begin
    select sum(md.volume)
    into l_unloading_volume
    from mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mts.stop_id = p_stop_id
    and mts.stop_id = mdl.drop_off_stop_id
    and mdl.delivery_id = md.delivery_id;
    return l_unloading_volume;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

  function get_unloading_pallets(p_stop_id in number)
    return number is
  l_unloading_pallets number;
  begin
    select sum(md.number_of_pallets)
    into l_unloading_pallets
    from mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mts.stop_id = p_stop_id
    and mts.stop_id = mdl.drop_off_stop_id
    and mdl.delivery_id = md.delivery_id;
    return l_unloading_pallets;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

  function get_unloading_pieces(p_stop_id in number)
    return number is
  l_unloading_pieces number;
  begin
    select sum(md.number_of_pieces)
    into l_unloading_pieces
    from mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mts.stop_id = p_stop_id
    and mts.stop_id = mdl.drop_off_stop_id
    and mdl.delivery_id = md.delivery_id;

    return l_unloading_pieces;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

/* Vehicle Trip Leg Details */
-- None aggregation fields:
-- On board weight/cube/pallets/pieces can be fetched directly from MST_TRIP_STOPS
-- the columns are departure weight/cube/pieces/pallets of the first stop

-- On board orders:
---- ?????

-- Distance Charge:
---- ?????

-- Max weight/cube/pallets for a vehicle
/*
select
item.maximum_load_weight max_load_weight,
??decode() max_load_volume -- based on direct move, pool move, stop numbers, the effective cap could be different
pallet_floor_space * pallet_stacking_height max_number_of_pallets
from fte_vehicle_types fte, mtl_system_items item
where vehicle_type_id = p_vehicle_type_id
and fte.organization_id = item.organization_id
and fte.inventory_item_id = item.inventory_item_id
*/

/* Delivery Details */
  function get_delivery_cost(p_delivery_id in number)
    return number is
  l_delivery_cost number;
  begin
    select sum(allocated_transport_cost + allocated_fac_loading_cost + allocated_fac_unloading_cost)
    into l_delivery_cost
    from mst_delivery_legs
    where delivery_id = p_delivery_id;

    return l_delivery_cost;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

/* LTL/Parcel Summary */
-- Weight Based/Minimum charges
---- use get_summary_fixed_charge() with appropriate mode and plan_id

-- Assessorial charges
---- use get_summary_assessorial_charge() with appropriate mode and plan_id

/* LTL/Parcel Details */
-- no aggregate functions, cost/weight/cube/pallets/pieces can be fetched
--  directly from base tables in view


/* All Continuous Moves */
  function get_total_savings(p_plan_id in number)
    return number is
  l_total_cm_cost number;
  l_total_cost_for_TLs_with_CMs number;
  l_total_savings number;
  begin
    select total_cm_cost
    into l_total_cm_cost
    from mst_plans
    where plan_id = p_plan_id;

    select
    sum(total_basic_transport_cost + total_stop_cost
     + total_load_unload_cost + total_layover_cost
     + total_accessorial_cost + total_handling_cost)
    into l_total_cost_for_TLs_with_CMs
    from mst_trips
    where plan_id = p_plan_id
    and continuous_move_id is not null
    and mode_of_transport = 'TRUCK';

    l_total_savings := l_total_cost_for_TLs_with_CMs - l_total_cm_cost;
    return l_total_savings;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

  function get_percent_of_tl_in_cm(p_plan_id in number)
    return number is
  l_total_number_of_tl number;
  l_total_number_of_tl_in_cm number;
  l_percent number;
  begin
    select count(1)
    into l_total_number_of_tl
    from mst_trips
    where plan_id = p_plan_id
    and mode_of_transport = 'TRUCK';

    select count(1)
    into l_total_number_of_tl_in_cm
    from mst_trips
    where plan_id = p_plan_id
    and continuous_move_id is not null
    and mode_of_transport = 'TRUCK';

    l_percent := l_total_number_of_tl_in_cm/l_total_number_of_tl;
    return l_percent;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

/* Continuous Move Details */
-- open issues

/* All Orders */
-- number of orders, total costs can be fetched directly from MST_PLANS
/* Order Details */
   function get_order_weight(p_source_code in varchar2,
                                   p_source_header_number in varchar2)
      return number is

      l_order_weight number;

   begin
      select sum(mdd.net_weight)
      into   l_order_weight
      from  mst_delivery_details mdd
      where mdd.source_code = p_source_code
      and   mdd.source_header_number = p_source_header_number;

      return l_order_weight;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_order_cube(p_source_code in varchar2,
                                   p_source_header_number in varchar2)
      return number is

      l_order_cube number;

   begin
      select sum(mdd.volume)
      into   l_order_cube
      from  mst_delivery_details mdd
      where mdd.source_code = p_source_code
      and   mdd.source_header_number = p_source_header_number;

      return l_order_cube;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_order_pallets(p_source_code in varchar2,
                                   p_source_header_number in varchar2)
      return number is

      l_order_pallets number;

   begin
      select sum(ceil(mdd.number_of_pallets))
      into   l_order_pallets
      from  mst_delivery_details mdd
      where mdd.source_code = p_source_code
      and   mdd.source_header_number = p_source_header_number;

      return l_order_pallets;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_order_pieces(p_source_code in varchar2,
                                   p_source_header_number in varchar2)
      return number is

      l_order_pieces number;

   begin
      select sum(mdd.requested_quantity)
      into   l_order_pieces
      from  mst_delivery_details mdd
      where mdd.source_code = p_source_code
      and   mdd.source_header_number = p_source_header_number;

      return l_order_pieces;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

/* Carrier Details */

   function get_carrier_total_cost(p_plan_id in number, p_carrier_id in number)
      return number is
      l_carrier_cost number;
      l_carrier_tl_cost number;
      l_carrier_ltl_parcel_cost number;
      l_carrier_cm_cost number;

   begin
     select sum(total_basic_transport_cost + total_stop_cost + total_load_unload_cost + total_layover_cost + total_accessorial_cost + total_handling_cost)
     into l_carrier_tl_cost
     from mst_trips
     where plan_id = p_plan_id
     and carrier_id = p_carrier_id
     and mode_of_transport = 'TRUCK'
     and continuous_move_id is null;

     select sum(total_basic_transport_cost + total_accessorial_cost)
     into l_carrier_ltl_parcel_cost
     from mst_trips
     where plan_id = p_plan_id
     and carrier_id = p_carrier_id
     and mode_of_transport in ('LTL', 'PARCEL');

     select sum(TOTAL_TRANSPORTATION_COST)
     into l_carrier_cm_cost
     from mst_cm_trips
     where plan_id = p_plan_id
     and carrier_id = p_carrier_id;
     l_carrier_cost := l_carrier_tl_cost + l_carrier_cm_cost + l_carrier_ltl_parcel_cost;
      return l_carrier_cost;
   EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   FUNCTION get_carrier_weight(p_plan_id IN NUMBER, p_carrier_id IN NUMBER)
      RETURN NUMBER IS
      l_carrier_weight NUMBER;
      l_carrier_weight_tmp NUMBER;
   BEGIN
     -- ----------------------------------
     -- Re-writing the sql for bug#3335462
     -- ----------------------------------
     /*
     SELECT SUM(md.gross_weight)
     INTO l_carrier_weight
     FROM MST_DELIVERIES md
     WHERE md.plan_id = p_plan_id
     AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM MST_DELIVERY_LEGS mdl,
                   MST_TRIPS mt,
                   MST_TRIP_STOPS mts
              WHERE mt.plan_id = md.plan_id
              AND mt.carrier_id = p_carrier_id
              AND mt.plan_id = mdl.plan_id
              AND mt.trip_id = mdl.trip_id
              AND mt.plan_id = mts.plan_id
              AND mt.trip_id = mts.trip_id
              AND mts.stop_location_id in
                (SELECT wlo.wsh_location_id
                 FROM  WSH_LOCATION_OWNERS wlo
                 WHERE wlo.owner_party_id = mt.carrier_id) );
                 */
    -- ----------------------------------------------------------------------------
    -- As per bug#3546059 and 3546163, We need to consider all the trips that touch
    -- the facility owned by a specific carrier.
    -- Also, we need to double count KPIs - weight/Cube/pallets/Pieces/Orders
    -- for unload and load.
    -- ----------------------------------------------------------------------------
    SELECT SUM(md.gross_weight)
    INTO l_carrier_weight
    FROM mst_deliveries md
    WHERE md.plan_id = p_plan_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.pick_up_stop_id = mts.stop_id
              AND EXISTS
                (SELECT 1
                 FROM  wsh_location_owners wlo
                 WHERE wlo.owner_party_id = p_carrier_id
                 AND   wlo.owner_type = CARRIER
                 AND   wlo.wsh_location_id = mts.stop_location_id) );
    l_carrier_weight_tmp := NVL(l_carrier_weight,0);

    l_carrier_weight := 0;

    SELECT SUM(md.gross_weight)
    INTO l_carrier_weight
    FROM mst_deliveries md
    WHERE md.plan_id = p_plan_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.drop_off_stop_id = mts.stop_id
              AND   EXISTS
                (SELECT 1
                 FROM  wsh_location_owners wlo
                 WHERE wlo.owner_party_id = p_carrier_id
                 AND   wlo.owner_type = CARRIER
                 AND   wlo.wsh_location_id = mts.stop_location_id) );

      l_carrier_weight := l_carrier_weight_tmp + NVL(l_carrier_weight,0);
      RETURN l_carrier_weight;
   EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   END get_carrier_weight;

   FUNCTION get_carrier_volume(p_plan_id IN NUMBER,p_carrier_id IN NUMBER)
      RETURN NUMBER IS
      l_carrier_volume NUMBER;
      l_carrier_volume_tmp NUMBER;
   BEGIN
     -- ----------------------------------
     -- Re-writing the sql for bug#3335462
     -- ----------------------------------
     /*********************
    SELECT SUM(md.volume)
    INTO l_carrier_volume
    FROM MST_DELIVERIES md
    WHERE md.plan_id = p_plan_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM MST_DELIVERY_LEGS mdl,
                   MST_TRIPS mt,
                   MST_TRIP_STOPS mts
              WHERE mt.plan_id = md.plan_id
              AND mt.carrier_id = p_carrier_id
              AND mt.plan_id = mdl.plan_id
              AND mt.trip_id = mdl.trip_id
              AND mt.plan_id = mts.plan_id
              AND mt.trip_id = mts.trip_id
              AND mts.stop_location_id in
                (SELECT wlo.wsh_location_id
                 FROM  WSH_LOCATION_OWNERS wlo
                 WHERE wlo.owner_party_id = mt.carrier_id) );
      **************************/
    -- ----------------------------------------------------------------------------
    -- As per bug#3546059 and 3546163, We need to consider all the trips that touch
    -- the facility owned by a specific carrier.
    -- Also, we need to double count KPIs - weight/Cube/pallets/Pieces/Orders
    -- for unload and load.
    -- ----------------------------------------------------------------------------
    SELECT SUM(md.volume)
    INTO l_carrier_volume
    FROM mst_deliveries md
    WHERE md.plan_id = p_plan_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.pick_up_stop_id = mts.stop_id
              AND EXISTS
                (SELECT 1
                 FROM  wsh_location_owners wlo
                 WHERE wlo.owner_party_id = p_carrier_id
                 AND   wlo.owner_type = CARRIER
                 AND   wlo.wsh_location_id = mts.stop_location_id) );
    l_carrier_volume_tmp := NVL(l_carrier_volume,0);

    l_carrier_volume := 0;

    SELECT SUM(md.volume)
    INTO l_carrier_volume
    FROM mst_deliveries md
    WHERE md.plan_id = p_plan_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.drop_off_stop_id = mts.stop_id
              AND EXISTS
                (SELECT 1
                 FROM  wsh_location_owners wlo
                 WHERE wlo.owner_party_id = p_carrier_id
                 AND   wlo.owner_type = CARRIER
                 AND   wlo.wsh_location_id = mts.stop_location_id) );

      l_carrier_volume := l_carrier_volume_tmp + NVL(l_carrier_volume,0);

      RETURN l_carrier_volume;
   EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   END get_carrier_volume;

   function get_carrier_pallets(p_plan_id in number,p_carrier_id in number)
      return number is
      l_carrier_pallets number;
      l_carrier_pallets_tmp number;
   begin
     -- ----------------------------------
     -- Re-writing the sql for bug#3335462
     -- ----------------------------------
    /******************************
    SELECT SUM(md.number_of_pallets)
    INTO l_carrier_pallets
    FROM MST_DELIVERIES md
    WHERE md.plan_id = p_plan_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM MST_DELIVERY_LEGS mdl,
                   MST_TRIPS mt,
                   MST_TRIP_STOPS mts
              WHERE mt.plan_id = md.plan_id
              AND mt.carrier_id = p_carrier_id
              AND mt.plan_id = mdl.plan_id
              AND mt.trip_id = mdl.trip_id
              AND mt.plan_id = mts.plan_id
              AND mt.trip_id = mts.trip_id
              AND mts.stop_location_id in
                (SELECT wlo.wsh_location_id
                 FROM  WSH_LOCATION_OWNERS wlo
                 WHERE wlo.owner_party_id = mt.carrier_id) );
        **************************/
    -- ----------------------------------------------------------------------------
    -- As per bug#3546059 and 3546163, We need to consider all the trips that touch
    -- the facility owned by a specific carrier.
    -- Also, we need to double count KPIs - weight/Cube/pallets/Pieces/Orders
    -- for unload and load.
    -- ----------------------------------------------------------------------------
    SELECT SUM(md.number_of_pallets)
    INTO l_carrier_pallets
    FROM mst_deliveries md
    WHERE md.plan_id = p_plan_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.pick_up_stop_id = mts.stop_id
              AND EXISTS
                (SELECT 1
                 FROM  wsh_location_owners wlo
                 WHERE wlo.owner_party_id = p_carrier_id
                 AND   wlo.owner_type = CARRIER
                 AND   wlo.wsh_location_id = mts.stop_location_id) );
    l_carrier_pallets_tmp := NVL(l_carrier_pallets,0);

    l_carrier_pallets := 0;

    SELECT SUM(md.number_of_pallets)
    INTO l_carrier_pallets
    FROM mst_deliveries md
    WHERE md.plan_id = p_plan_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.drop_off_stop_id = mts.stop_id
              AND EXISTS
                (SELECT 1
                 FROM  wsh_location_owners wlo
                 WHERE wlo.owner_party_id = p_carrier_id
                 AND   wlo.owner_type = CARRIER
                 AND   wlo.wsh_location_id = mts.stop_location_id) );

      l_carrier_pallets := l_carrier_pallets_tmp + NVL(l_carrier_pallets,0);
      RETURN l_carrier_pallets;
   EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   END get_carrier_pallets;

   function get_carrier_pieces(p_plan_id in number,p_carrier_id in number)
      return number is
      l_carrier_pieces number;
      l_carrier_pieces_tmp number;
   begin
     -- ----------------------------------
     -- Re-writing the sql for bug#3335462
     -- ----------------------------------
    /******************************
    SELECT SUM(md.number_of_pieces)
    INTO l_carrier_pieces
    FROM MST_DELIVERIES md
    WHERE md.plan_id = p_plan_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM MST_DELIVERY_LEGS mdl,
                   MST_TRIPS mt,
                   MST_TRIP_STOPS mts
              WHERE mt.plan_id = md.plan_id
              AND mt.carrier_id = p_carrier_id
              AND mt.plan_id = mdl.plan_id
              AND mt.trip_id = mdl.trip_id
              AND mt.plan_id = mts.plan_id
              AND mt.trip_id = mts.trip_id
              AND mts.stop_location_id in
                (SELECT wlo.wsh_location_id
                 FROM  WSH_LOCATION_OWNERS wlo
                 WHERE wlo.owner_party_id = mt.carrier_id) );
        **************************/
    -- ----------------------------------------------------------------------------
    -- As per bug#3546059 and 3546163, We need to consider all the trips that touch
    -- the facility owned by a specific carrier.
    -- Also, we need to double count KPIs - weight/Cube/pallets/Pieces/Orders
    -- for unload and load.
    -- ----------------------------------------------------------------------------
    SELECT SUM(md.number_of_pieces)
    INTO l_carrier_pieces
    FROM mst_deliveries md
    WHERE md.plan_id = p_plan_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.pick_up_stop_id = mts.stop_id
              AND EXISTS
                (SELECT 1
                 FROM  wsh_location_owners wlo
                 WHERE wlo.owner_party_id = p_carrier_id
                 AND   wlo.owner_type = CARRIER
                 AND   wlo.wsh_location_id = mts.stop_location_id) );
    l_carrier_pieces_tmp := NVL(l_carrier_pieces,0);

    l_carrier_pieces := 0;

    SELECT SUM(md.number_of_pieces)
    INTO l_carrier_pieces
    FROM mst_deliveries md
    WHERE md.plan_id = p_plan_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.drop_off_stop_id = mts.stop_id
              AND EXISTS
                (SELECT 1
                 FROM  wsh_location_owners wlo
                 WHERE wlo.owner_party_id = p_carrier_id
                 AND   wlo.owner_type = CARRIER
                 AND   wlo.wsh_location_id = mts.stop_location_id) );

      l_carrier_pieces := l_carrier_pieces_tmp + NVL(l_carrier_pieces,0);

    RETURN l_carrier_pieces;
   EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   END get_carrier_pieces;

-- get carrier orders
   function get_carrier_orders(p_plan_id in number,p_carrier_id in number)
      return number is
      l_carrier_orders number;
      l_carrier_orders_tmp NUMBER;
   begin
     -- ------------------------------------------ -
     -- As per bug#3244044, we need to consider    -
     -- Distinct orders instead of raw orders.     -
     -- ------------------------------------------ -
     -- ----------------------------------
     -- Modifying the sql for bug#3335462
     -- ----------------------------------
     /*********************************************
     SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
      INTO l_carrier_orders
      FROM MST_DELIVERY_DETAILS MDD,
           MST_DELIVERIES MD,
           MST_DELIVERY_ASSIGNMENTS MDA
      WHERE MD.PLAN_ID     = MDA.PLAN_ID
      AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
      AND   MD.DELIVERY_ID IN
                (SELECT MDL.DELIVERY_ID
                 FROM MST_TRIPS T,
                      MST_TRIP_STOPS TS,
                      MST_DELIVERY_LEGS MDL
                 WHERE MDL.PLAN_ID = MD.PLAN_ID
                 AND   TS.PLAN_ID  = MDL.PLAN_ID
                 AND  (   TS.STOP_ID  = MDL.PICK_UP_STOP_ID
                       OR TS.STOP_ID  = MDL.DROP_OFF_STOP_ID )
                 AND   TS.PLAN_ID  = T.PLAN_ID
                 AND   TS.TRIP_ID  = T.TRIP_ID
                 AND   T.CARRIER_ID = P_CARRIER_ID
                 AND ts.stop_location_id in
                    (SELECT wlo.wsh_location_id
                     FROM  WSH_LOCATION_OWNERS wlo
                     WHERE wlo.owner_party_id = t.carrier_id))
      AND   MDA.PLAN_ID = MDD.PLAN_ID
      AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
      AND   MD.PLAN_ID = P_PLAN_ID;
      ************************************/
    -- ----------------------------------------------------------------------------
    -- As per bug#3546059 and 3546163, We need to consider all the trips that touch
    -- the facility owned by a specific carrier.
    -- Also, we need to double count KPIs - weight/Cube/pallets/Pieces/Orders
    -- for unload and load.
    -- ----------------------------------------------------------------------------
    SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
    INTO l_carrier_orders
    FROM mst_delivery_details mdd,
         mst_deliveries md,
         mst_delivery_assignments mda
    WHERE md.plan_id = p_plan_id
    and   md.plan_id     = mda.plan_id
    and   md.delivery_id = mda.delivery_id
    and   mda.plan_id = mdd.plan_id
    and   mda.delivery_detail_id = mdd.delivery_detail_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.pick_up_stop_id = mts.stop_id
              AND EXISTS
                (SELECT 1
                 FROM  wsh_location_owners wlo
                 WHERE wlo.owner_party_id = p_carrier_id
                 AND   wlo.owner_type = CARRIER
                 AND   wlo.wsh_location_id = mts.stop_location_id) );
    l_carrier_orders_tmp := NVL(l_carrier_orders,0);

    l_carrier_orders := 0;

    SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
    INTO l_carrier_orders
    FROM mst_delivery_details mdd,
         mst_deliveries md,
         mst_delivery_assignments mda
    WHERE md.plan_id = p_plan_id
    and   md.plan_id     = mda.plan_id
    and   md.delivery_id = mda.delivery_id
    and   mda.plan_id = mdd.plan_id
    and   mda.delivery_detail_id = mdd.delivery_detail_id
    AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.drop_off_stop_id = mts.stop_id
              AND EXISTS
                (SELECT 1
                 FROM  wsh_location_owners wlo
                 WHERE wlo.owner_party_id = p_carrier_id
                 AND   wlo.owner_type = CARRIER
                 AND   wlo.wsh_location_id = mts.stop_location_id) );

      l_carrier_orders := l_carrier_orders_tmp + NVL(l_carrier_orders,0);

      RETURN l_carrier_orders;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   END get_carrier_orders;

/* Service Details */
-- Should we exclude cost for tls in CM for mode = TL?
   function get_carrier_service_total_cost(p_plan_id in number,
                p_carrier_id in number, p_mode in varchar2, p_service in varchar2)
      return number is
      l_carrier_service_cost number;
      l_carrier_tl_cost number;
      l_carrier_ltl_cost number;
      l_carrier_parcel_cost number;
   begin
     if p_mode = 'TRUCK' then
       select sum(total_basic_transport_cost + total_stop_cost + total_load_unload_cost+ total_layover_cost+ total_accessorial_cost + total_handling_cost)
       into l_carrier_tl_cost
       from mst_trips
       where plan_id = p_plan_id
       and carrier_id = p_carrier_id
       and mode_of_transport = 'TRUCK'
       and service_level = p_service
       and continuous_move_id is null;
       l_carrier_service_cost := l_carrier_tl_cost;
     elsif p_mode = 'LTL' then
       select sum(total_basic_transport_cost +  total_accessorial_cost)
       into l_carrier_ltl_cost
       from mst_trips
       where plan_id = p_plan_id
       and carrier_id = p_carrier_id
       and mode_of_transport = 'LTL'
       and service_level = p_service;
       l_carrier_service_cost := l_carrier_ltl_cost;
     elsif p_mode = 'PARCEL' then
       select sum(total_basic_transport_cost + total_accessorial_cost)
       into l_carrier_parcel_cost
       from mst_trips
       where plan_id = p_plan_id
       and carrier_id = p_carrier_id
       and mode_of_transport = 'LTL'
       and service_level = p_service;
       l_carrier_service_cost := l_carrier_parcel_cost;
     end if;
      return l_carrier_service_cost;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_carrier_service_weight(p_plan_id in number, p_carrier_id in number, p_mode in varchar2, p_service in varchar2)
      return number is
      l_carrier_weight number;
   begin
     select sum(gross_weight)
     into l_carrier_weight
     from(
       select distinct md.delivery_id, md.gross_weight gross_weight
       from mst_delivery_legs mdl,
            mst_deliveries md,
            mst_trips mt,
            mst_trip_stops mts
       where mt.plan_id = p_plan_id
       and mt.mode_of_transport = p_mode
       and mt.service_level = p_service
       and mt.carrier_id = p_carrier_id
       and mt.trip_id = mts.trip_id
       and mts.stop_id = mdl.pick_up_stop_id
       and mdl.delivery_id = md.delivery_id
     );

      return l_carrier_weight;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_carrier_service_volume(p_plan_id in number,p_carrier_id in number, p_mode in varchar2, p_service in varchar2)
      return number is
      l_carrier_volume number;
   begin
     select sum(volume)
     into l_carrier_volume
     from(
       select distinct md.delivery_id, md.volume volume
       from mst_delivery_legs mdl,
            mst_deliveries md,
            mst_trips mt,
            mst_trip_stops mts
       where mt.plan_id = p_plan_id
       and mt.mode_of_transport = p_mode
       and mt.service_level = p_service
       and mt.carrier_id = p_carrier_id
       and mt.trip_id = mts.trip_id
       and mts.stop_id = mdl.pick_up_stop_id
       and mdl.delivery_id = md.delivery_id
     );

      return l_carrier_volume;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;
   function get_carrier_service_pallets(p_plan_id in number,p_carrier_id in number, p_mode in varchar2, p_service in varchar2)
      return number is
      l_carrier_pallets number;
   begin
     select sum(number_of_pallets)
     into l_carrier_pallets
     from(
       select distinct md.delivery_id, md.number_of_pallets number_of_pallets
       from mst_delivery_legs mdl,
            mst_deliveries md,
            mst_trips mt,
            mst_trip_stops mts
       where mt.plan_id = p_plan_id
       and mt.mode_of_transport = p_mode
       and mt.service_level = p_service
       and mt.carrier_id = p_carrier_id
       and mt.trip_id = mts.trip_id
       and mts.stop_id = mdl.pick_up_stop_id
       and mdl.delivery_id = md.delivery_id
     );

      return l_carrier_pallets;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;
   function get_carrier_service_pieces(p_plan_id in number,p_carrier_id in number, p_mode in varchar2, p_service in varchar2)
      return number is
      l_carrier_pieces number;
   begin
     select sum(number_of_pieces)
     into l_carrier_pieces
     from(
       select distinct md.delivery_id, md.number_of_pieces number_of_pieces
       from mst_delivery_legs mdl,
            mst_deliveries md,
            mst_trips mt,
            mst_trip_stops mts
       where mt.plan_id = p_plan_id
       and mt.mode_of_transport = p_mode
       and mt.service_level = p_service
       and mt.carrier_id = p_carrier_id
       and mt.trip_id = mts.trip_id
       and mts.stop_id = mdl.pick_up_stop_id
       and mdl.delivery_id = md.delivery_id
     );

      return l_carrier_pieces;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

/* Customer Details */
   function get_total_cost_cust (p_plan_id in number,
                                   p_customer_id in number)
      return number is

      l_total_cost number;

   begin
      -- SQL repository issues as on 25-05-04:
      -- Added join for plan id
      select sum(mdl.allocated_fac_loading_cost   +
                 mdl.allocated_fac_unloading_cost +
                 mdl.ALLOCATED_FAC_SHP_HAND_COST  +
                 mdl.ALLOCATED_FAC_REC_HAND_COST  +
                 mdl.allocated_transport_cost      )
      into   l_total_cost
      from  mst_deliveries md,
            mst_delivery_legs mdl
      where md.plan_id = p_plan_id
      and   md.customer_id = p_customer_id
      AND   md.plan_id = mdl.plan_id
      and   md.delivery_id = mdl.delivery_id;

      return l_total_cost;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_total_weight_cust (p_plan_id in number,
                                   p_customer_id in number)
      return number is

      l_total_weight number;

   BEGIN
      -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
      -- --------------------
      -- Bug#3423219
      -- Need to show net wt.
      -- --------------------
      --select sum(md.gross_weight)
/*      select sum(md.net_weight)
      into   l_total_weight
      from  mst_deliveries md
      where md.plan_id = p_plan_id
      and   md.customer_id = p_customer_id;
*/
      --and exists (select 1 from mst_delivery_legs mdl
      --           where md.delivery_id = mdl.delivery_id
      --          );


      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(nvl(mdd.net_weight,0))
      into   l_total_weight
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and md.customer_id = p_customer_id;

      return l_total_weight;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;



   function get_total_cube_cust (p_plan_id in number,
                                   p_customer_id in number)
      return number is

      l_total_volume number;

   BEGIN
      -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
/*      select sum(md.volume)
      into   l_total_volume
      from  mst_deliveries md
      where md.plan_id = p_plan_id
      and   md.customer_id = p_customer_id;
*/
      --and exists (select 1 from mst_delivery_legs mdl
      --           where md.delivery_id = mdl.delivery_id
      --          );


      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(nvl(mdd.volume,0))
      into   l_total_volume
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and md.customer_id = p_customer_id;

      return l_total_volume;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_total_pallets_cust (p_plan_id in number,
                                    p_customer_id in number)
      return number is

      l_total_pallets number;

   begin
      -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
/*      select sum(md.number_of_pallets)
      into   l_total_pallets
      from  mst_deliveries md
      where md.plan_id = p_plan_id
      and   md.customer_id = p_customer_id;
*/
      --and exists (select 1 from mst_delivery_legs mdl
      --           where md.delivery_id = mdl.delivery_id
      --          );


      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(ceil(nvl(mdd.number_of_pallets,0)))
      into   l_total_pallets
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and md.customer_id = p_customer_id;

      return l_total_pallets;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;



   function get_total_pieces_cust  (p_plan_id in number,
                                    p_customer_id in number)
      return number is

      l_total_pieces number;

   begin
      -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
/*      select sum(md.number_of_pieces)
      into   l_total_pieces
      from  mst_deliveries md
      where md.plan_id = p_plan_id
      and   md.customer_id = p_customer_id;
*/
      --and exists (select 1 from mst_delivery_legs mdl
      --           where md.delivery_id = mdl.delivery_id
      --          );


      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(nvl(mdd.requested_quantity,0))
      into   l_total_pieces
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and md.customer_id = p_customer_id;

      return l_total_pieces;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;



   function get_total_orders_cust  (p_plan_id in number,
                                    p_customer_id in number)
      return number is

      l_total_orders number;

   BEGIN
   -- ----------------------------------------
   -- As per bug#3283569, we need to consider
   -- raw orders instead of TP order lines.
   -- ----------------------------------------
   /***

      select count(1)
      into l_total_orders
      from mst_delivery_details mdd,
           mst_delivery_assignments mda
      where mdd.plan_id = p_plan_id
      and mdd.customer_id = p_customer_id
      and mdd.split_from_delivery_detail_id is null
      and mdd.delivery_detail_id = mda.delivery_detail_id
      and mda.parent_delivery_detail_id is null
      and exists (select 1
                 from mst_delivery_legs mdl
                 where mdl.delivery_id = mda.delivery_id
                );
      ***/
      /*SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      FROM MST_DELIVERY_DETAILS MDD,
           MST_DELIVERIES MD,
           MST_DELIVERY_ASSIGNMENTS MDA
      WHERE MD.PLAN_ID     = MDA.PLAN_ID
      AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
      AND   MD.DELIVERY_ID IN
                (SELECT MDL.DELIVERY_ID
                 FROM  MST_DELIVERY_LEGS MDL
                 WHERE MDL.PLAN_ID = MD.PLAN_ID)
      AND   MDA.PLAN_ID = MDD.PLAN_ID
      AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
      AND   MD.PLAN_ID = P_PLAN_ID
      AND   MD.CUSTOMER_ID = p_customer_id;*/
      -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
      SELECT COUNT(DISTINCT dd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      from (
            SELECT mdd.SOURCE_HEADER_NUMBER
            FROM MST_DELIVERY_DETAILS MDD,
                 MST_DELIVERIES MD,
                 MST_DELIVERY_ASSIGNMENTS MDA
            WHERE MD.PLAN_ID     = MDA.PLAN_ID
            AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
            AND   MD.DELIVERY_ID IN
                    (SELECT MDL.DELIVERY_ID
                     FROM  MST_DELIVERY_LEGS MDL
                    WHERE MDL.PLAN_ID = MD.PLAN_ID)
            AND   MDA.PLAN_ID = MDD.PLAN_ID
            AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
            AND   MD.PLAN_ID = p_PLAN_ID
            AND   MD.CUSTOMER_ID = p_customer_id
            union all
            SELECT mdd.SOURCE_HEADER_NUMBER
            FROM MST_DELIVERY_DETAILS MDD,
                 MST_DELIVERIES MD,
                 MST_DELIVERY_ASSIGNMENTS MDA
            WHERE MD.PLAN_ID     = MDA.PLAN_ID
            AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
            AND   not exists
                    (SELECT 1
                     FROM  MST_DELIVERY_LEGS MDL
                     WHERE MDL.PLAN_ID = MD.PLAN_ID
                     and MDL.DELIVERY_ID = md.plan_id)
            AND   MDA.PLAN_ID = MDD.PLAN_ID
            AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
            AND   MD.PLAN_ID = p_PLAN_ID
            AND   MD.CUSTOMER_ID = p_customer_id) dd;
      return l_total_orders;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;


/*   function get_total_trip_count_cust  (p_plan_id in number,
                                   p_customer_id in number )

      return varchar2 is
   cursor mst_d is
     select delivery_id
     from mst_deliveries md
     where md.plan_id = p_plan_id
     and   md.customer_id = p_customer_id;

   cursor mst_d_l_count (p_delivery_id NUMBER) is
     select count(mdl.delivery_leg_id)
     from mst_delivery_legs mdl
     where mdl.delivery_id = p_delivery_id
        and   mdl.plan_id = p_plan_id;

   cursor mst_d_l (p_delivery_id NUMBER) is
     select mdl.delivery_leg_id
     from mst_delivery_legs mdl
     where mdl.delivery_id = p_delivery_id
     and   mdl.plan_id = p_plan_id;

   cursor mst_mode_of_transport (p_delivery_leg_id NUMBER) is
     select mt.mode_of_transport mode_of_transport, mt.trip_id trip_id
     from mst_delivery_legs mdl, mst_trip_stops mts, mst_trips mt
     where mdl.delivery_leg_id = p_delivery_leg_id
     and mdl.plan_id = mts.plan_id
     and mdl.pick_up_stop_id = mts.stop_id
     and mdl.plan_id = mt.plan_id
     and mts.trip_id = mt.trip_id;

   cursor mst_pickup_stop_location (p_delivery_leg_id NUMBER) is
    select mts.stop_location_id location_id
    from mst_delivery_legs mdl, mst_trip_stops mts
    where delivery_leg_id = p_delivery_leg_id
    and mdl.plan_id = mts.plan_id
    and mdl.pick_up_stop_id = mts.stop_id ;

   cursor mst_dropoff_stop_location (p_delivery_leg_id NUMBER) is
    select mts.stop_location_id location_id
    from mst_delivery_legs mdl, mst_trip_stops mts
    where delivery_leg_id = p_delivery_leg_id
    and mdl.plan_id = mts.plan_id
    and mdl.drop_off_stop_id = mts.stop_id ;

     l_num_of_direct_tls number := 0;
     l_num_of_multi_stop_tls number := 0;
     l_num_of_ltls number := 0;
     l_num_of_parcels number := 0;

     l_delivery_leg_count number;
     l_delivery_leg_id number;
     l_mode_of_transport varchar2(50);
     l_trip_id number;
     l_first_leg_id number;
     l_last_leg_id number;
     l_pickup_location_id number;
     l_dropoff_location_id number;
     l_source_code VARCHAR2(10);
     i number;
     l_num_string varchar2(100);
     l_delivery_id number;
     l_num_of_stops_for_tl number;
     l_customer_facilities NumList := NumList();
   begin
    for c_mst_d in mst_d loop
      l_source_code := null;
      l_delivery_id := c_mst_d.delivery_id;
      open mst_d_l_count(l_delivery_id);
      fetch mst_d_l_count into l_delivery_leg_count;
      close mst_d_l_count;
      -- if l_delivery_leg_count = 0, this is a unassigned delivery, no trip
      if l_delivery_leg_count = 1 then
        open  mst_d_l(l_delivery_id);
        fetch mst_d_l into l_delivery_leg_id;
        close mst_d_l;
        open mst_mode_of_transport(l_delivery_leg_id);
        fetch mst_mode_of_transport into l_mode_of_transport, l_trip_id;
        close mst_mode_of_transport;
        if l_mode_of_transport = 'LTL' then
          l_num_of_ltls := l_num_of_ltls + 1;
        elsif l_mode_of_transport = 'PARCEL' then
          l_num_of_parcels := l_num_of_parcels + 1;
        elsif l_mode_of_transport = 'TRUCK' then
          l_num_of_stops_for_tl := get_num_of_stops_for_tl(l_trip_id, p_plan_id);
          if l_num_of_stops_for_tl = 2 then
            l_num_of_direct_tls := l_num_of_direct_tls + 1;
          else
            l_num_of_multi_stop_tls := l_num_of_multi_stop_tls + 1;
          end if;
        end if;
      elsif l_delivery_leg_count > 1 then
        l_first_leg_id := get_first_or_last_delivery_leg (p_plan_id, c_mst_d.delivery_id, 0);
        l_last_leg_id := get_first_or_last_delivery_leg (p_plan_id, c_mst_d.delivery_id, 1);

        l_customer_facilities := get_customer_facilities(p_plan_id, p_customer_id );
        open mst_dropoff_stop_location(l_last_leg_id);
        fetch mst_dropoff_stop_location into l_dropoff_location_id;
        close mst_dropoff_stop_location;
        for i in 1..g_num_of_facilities loop
          if l_customer_facilities(i) = l_dropoff_location_id then
            l_source_code := OE;
            open mst_mode_of_transport(l_last_leg_id) ;
            fetch mst_mode_of_transport into l_mode_of_transport, l_trip_id;
            close mst_mode_of_transport;
            if l_mode_of_transport = 'LTL' then
              l_num_of_ltls := l_num_of_ltls + 1;
            elsif l_mode_of_transport = 'PARCEL' then
              l_num_of_parcels := l_num_of_parcels + 1;
            elsif l_mode_of_transport = 'TRUCK' then
              l_num_of_stops_for_tl := get_num_of_stops_for_tl(l_trip_id, p_plan_id);
              if l_num_of_stops_for_tl = 2 then
                l_num_of_direct_tls := l_num_of_direct_tls + 1;
              else
                l_num_of_multi_stop_tls := l_num_of_multi_stop_tls + 1;
              end if;
            end if;
          end if;
        end loop;

        if l_source_code = null then -- if not RFC then must be OE
          --fetch mst_pickup_stop_location(l_last_leg_id) into l_pickup_location_id;
            open mst_mode_of_transport(l_first_leg_id);
            fetch mst_mode_of_transport into l_mode_of_transport, l_trip_id;
            close mst_mode_of_transport;
            if l_mode_of_transport = 'LTL' then
              l_num_of_ltls := l_num_of_ltls + 1;
            elsif l_mode_of_transport = 'PARCEL' then
              l_num_of_parcels := l_num_of_parcels + 1;
            elsif l_mode_of_transport = 'TRUCK' then
              l_num_of_stops_for_tl := get_num_of_stops_for_tl(l_trip_id, p_plan_id);
              if l_num_of_stops_for_tl = 2 then
                l_num_of_direct_tls := l_num_of_direct_tls + 1;
              else
                l_num_of_multi_stop_tls := l_num_of_multi_stop_tls + 1;
              end if;
            end if;
        end if;
      end if;
    end loop;

    l_num_string := l_num_of_direct_tls || p_delim ||l_num_of_multi_stop_tls ||
                     p_delim||l_num_of_ltls||p_delim||l_num_of_parcels;

      return l_num_string;
   end;
*/

  -- this function should be used to get the trip counts for both Customer and Suppliers
   function get_total_trip_count_partner(p_plan_id in number,
                                   p_partner_id in number, p_partner_type in number )

      return varchar2 is

   -- p_partner_type: 0 -- customer, 1 -- supplier
   cursor mst_d is
     select delivery_id
     from mst_deliveries md
     where md.plan_id = p_plan_id
     and   decode(p_partner_type, 0, md.customer_id, md.supplier_id) = p_partner_id;

   cursor mst_d_l_count (p_delivery_id NUMBER) is
     select count(mdl.delivery_leg_id)
     from mst_delivery_legs mdl
     where mdl.delivery_id = p_delivery_id
        and   mdl.plan_id = p_plan_id;

   cursor mst_d_l (p_delivery_id NUMBER) is
     select mdl.delivery_leg_id
     from mst_delivery_legs mdl
     where mdl.delivery_id = p_delivery_id
     and   mdl.plan_id = p_plan_id;

   cursor mst_mode_of_transport (p_delivery_leg_id NUMBER) is
     select mt.mode_of_transport mode_of_transport, mt.trip_id trip_id
     from mst_delivery_legs mdl, mst_trip_stops mts, mst_trips mt
     where mdl.delivery_leg_id = p_delivery_leg_id
     and mdl.plan_id = mts.plan_id
     and mdl.pick_up_stop_id = mts.stop_id
     and mdl.plan_id = mt.plan_id
     and mts.trip_id = mt.trip_id;

   cursor mst_pickup_stop_location (p_delivery_leg_id NUMBER) is
    select mts.stop_location_id location_id
    from mst_delivery_legs mdl, mst_trip_stops mts
    where delivery_leg_id = p_delivery_leg_id
    and mdl.plan_id = mts.plan_id
    and mdl.pick_up_stop_id = mts.stop_id ;

   cursor mst_dropoff_stop_location (p_delivery_leg_id NUMBER) is
    select mts.stop_location_id location_id
    from mst_delivery_legs mdl, mst_trip_stops mts
    where delivery_leg_id = p_delivery_leg_id
    and mdl.plan_id = mts.plan_id
    and mdl.drop_off_stop_id = mts.stop_id ;

     l_num_of_direct_tls number := 0;
     l_num_of_multi_stop_tls number := 0;
     l_num_of_ltls number := 0;
     l_num_of_parcels number := 0;

     l_delivery_leg_count number;
     l_delivery_leg_id number;
     l_mode_of_transport varchar2(50);
     l_trip_id number;
     l_first_leg_id number;
     l_last_leg_id number;
     l_pickup_location_id number;
     l_dropoff_location_id number;
     l_source_code VARCHAR2(10);
     i number;
     l_num_string varchar2(100);
     l_delivery_id number;
     l_num_of_stops_for_tl number;
     l_partner_facilities NumList := NumList();
   begin
  /*
    for c_mst_d in mst_d loop
      l_source_code := null;
      l_delivery_id := c_mst_d.delivery_id;
      open mst_d_l_count(l_delivery_id);
      fetch mst_d_l_count into l_delivery_leg_count;
      close mst_d_l_count;
      -- if l_delivery_leg_count = 0, this is a unassigned delivery, no trip
      if l_delivery_leg_count = 1 then
        open  mst_d_l(l_delivery_id);
        fetch mst_d_l into l_delivery_leg_id;
        close mst_d_l;
        open mst_mode_of_transport(l_delivery_leg_id);
        fetch mst_mode_of_transport into l_mode_of_transport, l_trip_id;
        close mst_mode_of_transport;
        if l_mode_of_transport = 'LTL' then
          l_num_of_ltls := l_num_of_ltls + 1;
        elsif l_mode_of_transport = 'PARCEL' then
          l_num_of_parcels := l_num_of_parcels + 1;
        elsif l_mode_of_transport = 'TRUCK' THEN
          -- -----------------------------------------------
          -- skakani - 01.12.2003 - Changing for bug#3283545
          -- -----------------------------------------------
          --l_num_of_stops_for_tl := get_num_of_stops_for_tl(l_trip_id, p_plan_id);
          l_num_of_stops_for_tl := get_num_of_stops_for_tl(p_plan_id, l_trip_id);
          if l_num_of_stops_for_tl = 2 then
            l_num_of_direct_tls := l_num_of_direct_tls + 1;
          else
            l_num_of_multi_stop_tls := l_num_of_multi_stop_tls + 1;
          end if;
        end if;
      elsif l_delivery_leg_count > 1 then
        l_first_leg_id := get_first_or_last_delivery_leg (p_plan_id, c_mst_d.delivery_id, 0);
        l_last_leg_id := get_first_or_last_delivery_leg (p_plan_id, c_mst_d.delivery_id, 1);
        if p_partner_type = 0 then
          l_partner_facilities := get_customer_facilities(p_plan_id, p_partner_id );
        else
          l_partner_facilities := get_supplier_facilities(p_plan_id, p_partner_id );
        end if;
        if l_partner_facilities.FIRST is not null then
          open mst_dropoff_stop_location(l_last_leg_id);
          fetch mst_dropoff_stop_location into l_dropoff_location_id;
          close mst_dropoff_stop_location;
          for i in l_partner_facilities.FIRST..l_partner_facilities.LAST loop
            if l_partner_facilities(i) = l_dropoff_location_id then
              if p_partner_type = 0 then
                l_source_code := OE;
              else
                l_source_code := RTV; -- RTS;
              end if;
              open mst_mode_of_transport(l_last_leg_id) ;
              fetch mst_mode_of_transport into l_mode_of_transport, l_trip_id;
              close mst_mode_of_transport;
              if l_mode_of_transport = 'LTL' then
                l_num_of_ltls := l_num_of_ltls + 1;
              elsif l_mode_of_transport = 'PARCEL' then
                l_num_of_parcels := l_num_of_parcels + 1;
              elsif l_mode_of_transport = 'TRUCK' THEN
                -- -----------------------------------------------
                -- skakani - 01.12.2003 - Changing for bug#3283545
                -- -----------------------------------------------
                --l_num_of_stops_for_tl := get_num_of_stops_for_tl(l_trip_id, p_plan_id);
                l_num_of_stops_for_tl := get_num_of_stops_for_tl(p_plan_id, l_trip_id);
                if l_num_of_stops_for_tl = 2 then
                  l_num_of_direct_tls := l_num_of_direct_tls + 1;
                else
                  l_num_of_multi_stop_tls := l_num_of_multi_stop_tls + 1;
                end if;
              end if;
            end if;
          end loop;

          if l_source_code = null then -- if not OE/RTV then must be RFC/PO
            --fetch mst_pickup_stop_location(l_last_leg_id) into l_pickup_location_id;
              open mst_mode_of_transport(l_first_leg_id);
              fetch mst_mode_of_transport into l_mode_of_transport, l_trip_id;
              close mst_mode_of_transport;
              if l_mode_of_transport = 'LTL' then
                l_num_of_ltls := l_num_of_ltls + 1;
              elsif l_mode_of_transport = 'PARCEL' then
                l_num_of_parcels := l_num_of_parcels + 1;
              elsif l_mode_of_transport = 'TRUCK' then
                -- -----------------------------------------------
                -- skakani - 01.12.2003 - Changing for bug#3283545
                -- -----------------------------------------------
                --l_num_of_stops_for_tl := get_num_of_stops_for_tl(l_trip_id, p_plan_id);
                l_num_of_stops_for_tl := get_num_of_stops_for_tl(p_plan_id, l_trip_id);
                if l_num_of_stops_for_tl = 2 then
                  l_num_of_direct_tls := l_num_of_direct_tls + 1;
                else
                  l_num_of_multi_stop_tls := l_num_of_multi_stop_tls + 1;
                end if;
              end if;
          end if;
        else
          --dbms_output.put_line('Error: Customer or supplier facilities are not defined!');
          null;
        end if;
      end if;
    end loop;

    l_num_string := l_num_of_direct_tls || p_delim ||l_num_of_multi_stop_tls ||
                     p_delim||l_num_of_ltls||p_delim||l_num_of_parcels;

      return l_num_string;

*/

  if p_partner_type = 0 then    -- partner_type = 0 means for customer
--for DTLs
  select count(mt.trip_id)
  into l_num_of_direct_tls
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.customer_id = p_partner_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) =2
        group by ts.trip_id);

-- for MultiStop TLs
  select count(mt.trip_id)
  into l_num_of_multi_stop_tls
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.customer_id = p_partner_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) >2
        group by ts.trip_id);

--for LTLs
  select count(mt.trip_id)
  into l_num_of_ltls
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.customer_id = p_partner_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'LTL';

--for Parcels
  select count(mt.trip_id)
  into l_num_of_parcels
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.customer_id = p_partner_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'PARCEL';

  elsif p_partner_type = 1 then    -- partner_type = 1 means for supplier
--for DTLs
  select count(mt.trip_id)
  into l_num_of_direct_tls
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.supplier_id = p_partner_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.pickup_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.pick_up_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) =2
        group by ts.trip_id);

-- for MultiStop TLs
  select count(mt.trip_id)
  into l_num_of_multi_stop_tls
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.supplier_id = p_partner_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.pickup_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.pick_up_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) >2
        group by ts.trip_id);

--for LTLs
  select count(mt.trip_id)
  into l_num_of_ltls
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.supplier_id = p_partner_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.pickup_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.pick_up_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'LTL';

--for Parcels
  select count(mt.trip_id)
  into l_num_of_parcels
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.supplier_id = p_partner_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.pickup_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.pick_up_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'PARCEL';

  else
    null;
  end if;

  l_num_string := l_num_of_direct_tls || p_delim ||l_num_of_multi_stop_tls ||
                   p_delim||l_num_of_ltls||p_delim||l_num_of_parcels;

  return l_num_string;

EXCEPTION
    WHEN OTHERS THEN
        RETURN p_delim||p_delim||p_delim;
   end get_total_trip_count_partner;




  function get_customer_facilities(p_plan_id in number,
                                   p_customer_id in number)
   return NumList is
  l_c_facilities NumList := NumList();
  -- SQL repository issues as on 25-05-04:
      -- Rewritten sql to avoid distinct clause
    CURSOR customer_facilities IS
    SELECT fte.location_id customer_facility_id,
            fte.facility_code facility_code,
            fte.description description
    FROM fte_location_parameters fte
    WHERE fte.location_id IN
                (SELECT DECODE(mdd.source_code, OE , mdd.ship_to_location_id,
                                                RFC, mdd.ship_from_location_id) location_id
                 FROM mst_delivery_details mdd
                 WHERE mdd.plan_id = p_plan_id
                 AND   mdd.customer_id = p_customer_id
                 AND   mdd.source_code IN (OE, RFC)                          );
  /*cursor customer_facilities is
     select distinct decode(source_code, OE, ship_to_location_id,
                                         RFC, ship_from_location_id) customer_facility_id,
            fte.facility_code facility_code,
            fte.description description
     from mst_delivery_details, fte_location_parameters fte
     where plan_id = p_plan_id
     and customer_id = p_customer_id
     and source_code in (OE, RFC)
     and decode(source_code, RFC, ship_from_location_id, ship_to_location_id) = fte.location_id;*/

   j number:=1;
   begin
    --g_num_of_facilities := 0;
    for c_customer_facility in customer_facilities loop
      l_c_facilities.EXTEND;
      l_c_facilities(j) := c_customer_facility.customer_facility_id;
      j := j + 1;
      --g_num_of_facilities := g_num_of_facilities + 1;
    end loop;
    return l_c_facilities;
   end;

  function get_supplier_facilities(p_plan_id in number,
                                   p_supplier_id in number)
   return NumList is
  l_c_facilities NumList := NumList();
  -- SQL repository issues as on 25-05-04:
      -- Rewritten sql to avoid distinct clause
  CURSOR supplier_facilities is
  SELECT fte.location_id supplier_facility_id,
         fte.facility_code facility_code,
         fte.description description
  FROM fte_location_parameters fte
  WHERE fte.location_id in
                 (SELECT DECODE(mdd.source_code, RTV, mdd.ship_to_location_id,
                                                 PO, mdd.ship_from_location_id) location_id
                  FROM mst_delivery_details mdd
                  WHERE mdd.plan_id = p_plan_id
                  AND   mdd.supplier_id = p_supplier_id
                  AND   mdd.source_code in (PO, RTV));
  /*cursor supplier_facilities is
     select distinct decode(source_code, RTV, ship_to_location_id,
                                         PO, ship_from_location_id) supplier_facility_id,
            fte.facility_code facility_code,
            fte.description description
     from mst_delivery_details, fte_location_parameters fte
     where plan_id = p_plan_id
     and supplier_id = p_supplier_id
     and source_code in (PO, RTV)
     and decode(source_code, RTV, ship_to_location_id, PO, ship_from_location_id) = fte.location_id;*/
   j number:=1;
   begin
    --g_num_of_facilities := 0;
    for c_supplier_facility in supplier_facilities loop
      l_c_facilities.EXTEND;
      l_c_facilities(j) := c_supplier_facility.supplier_facility_id;
      j := j + 1;
      --g_num_of_facilities := g_num_of_facilities + 1;
    end loop;
    return l_c_facilities;
   end;

  FUNCTION get_num_of_stops_for_tl(p_plan_id IN NUMBER, p_trip_id IN NUMBER)
  RETURN NUMBER IS
  CURSOR tl_stops is
  SELECT count(stop_id)
  FROM mst_trip_stops
  WHERE plan_id = p_plan_id
  AND   trip_id = p_trip_id;

  l_num_of_stops number;
  BEGIN
    OPEN tl_stops;
    FETCH tl_stops into l_num_of_stops;
    CLOSE tl_stops;
    RETURN l_num_of_stops;
  END;

  FUNCTION get_first_or_last_delivery_leg(p_plan_id IN NUMBER, p_delivery_id IN NUMBER, p_type IN NUMBER)
  RETURN NUMBER IS

  CURSOR Cur_First_Delivery_Leg IS
    SELECT DL.delivery_leg_id
    FROM mst_delivery_legs DL
    WHERE DL.plan_id         = p_plan_id
    AND   DL.delivery_id     = p_delivery_id
    AND   DL.sequence_number = (SELECT min(DL1.sequence_number) seq_no
                                FROM mst_delivery_legs DL1
                                WHERE DL1.plan_id     = DL.plan_id
                                AND   DL1.delivery_id = DL.delivery_id);

    CURSOR Cur_Last_Delivery_Leg IS
    SELECT DL.delivery_leg_id
    FROM mst_delivery_legs DL
    WHERE DL.plan_id         = p_plan_id
    AND   DL.delivery_id     = p_delivery_id
    AND   DL.sequence_number = (SELECT max(DL1.sequence_number) seq_no
                                FROM mst_delivery_legs DL1
                                WHERE DL1.plan_id     = DL.plan_id
                                AND   DL1.delivery_id = DL.delivery_id);
   /*
  cursor seq_no is
  select decode (p_type, 0, min(sequence_number),
                         1, max(sequence_number)) seq_no
  from mst_delivery_legs
  where plan_id = p_plan_id
  and delivery_id = p_delivery_id;

  cursor delivery_leg (p_seq_no number) is
  select delivery_leg_id
  from mst_delivery_legs
  where plan_id = p_plan_id
  and delivery_id = p_delivery_id
  and sequence_number = p_seq_no;
  */
  l_seq_no number;
  l_leg_id number;
  BEGIN
    IF p_type = 0 THEN
        OPEN Cur_First_Delivery_Leg;
        FETCH Cur_First_Delivery_Leg INTO l_leg_id;
        CLOSE Cur_First_Delivery_Leg;
    ELSIF p_type = 1 THEN
        OPEN Cur_Last_Delivery_Leg;
        FETCH Cur_Last_Delivery_Leg INTO l_leg_id;
        CLOSE Cur_Last_Delivery_Leg;
    END IF;

    RETURN l_leg_id;
    /*
    open seq_no;
    fetch seq_no into l_seq_no;
    close seq_no;
    open delivery_leg(l_seq_no);
    fetch delivery_leg into l_leg_id;
    close delivery_leg;
    return l_leg_id;
    */
  end;
/* Supplier Details */

   function get_total_cost_supp (p_plan_id in number,
                                   p_supplier_id in number)
      return number is

      l_total_cost number;

   begin
      select sum(mdl.allocated_fac_loading_cost + mdl.allocated_fac_unloading_cost
               + mdl.ALLOCATED_FAC_SHP_HAND_COST + mdl.ALLOCATED_FAC_REC_HAND_COST + mdl.allocated_transport_cost)
      into   l_total_cost
      from  mst_deliveries md,
            mst_delivery_legs mdl
      where md.plan_id = p_plan_id
      and   md.supplier_id = p_supplier_id
      and   md.delivery_id = mdl.delivery_id;

      return l_total_cost;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_total_weight_supp (p_plan_id in number,
                                   p_supplier_id in number)
      return number is

      l_total_weight number;

   begin
      -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
      -- --------------------
      -- Bug#3423219
      -- Need to show net wt.
      -- --------------------
      --select sum(md.gross_weight)
/*      select sum(md.net_weight)
      into   l_total_weight
      from  mst_deliveries md
      where md.plan_id = p_plan_id
      and   md.supplier_id = p_supplier_id;
*/
      --and exists (select 1 from mst_delivery_legs mdl
      --           where md.delivery_id = mdl.delivery_id
      --          );

      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(nvl(mdd.net_weight,0))
      into   l_total_weight
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and md.supplier_id = p_supplier_id;

      return l_total_weight;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;



   function get_total_cube_supp (p_plan_id in number,
                                   p_supplier_id in number)
      return number is

      l_total_volume number;

   BEGIN
      -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
/*      select sum(md.volume)
      into   l_total_volume
      from  mst_deliveries md
      where md.plan_id = p_plan_id
      and   md.supplier_id = p_supplier_id;
*/
      --and exists (select 1 from mst_delivery_legs mdl
      --           where md.delivery_id = mdl.delivery_id
      --          );

      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(nvl(mdd.volume,0))
      into   l_total_volume
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and md.supplier_id = p_supplier_id;

      return l_total_volume;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;



   function get_total_pallets_supp (p_plan_id in number,
                                    p_supplier_id in number)
      return number is

      l_total_pallets number;

   begin
      -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
/*      select sum(md.number_of_pallets)
      into   l_total_pallets
      from  mst_deliveries md
      where md.plan_id = p_plan_id
      and   md.supplier_id = p_supplier_id;
*/
      --and exists (select 1 from mst_delivery_legs mdl
      --           where md.delivery_id = mdl.delivery_id
      --          );

      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(ceil(nvl(mdd.number_of_pallets,0)))
      into   l_total_pallets
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and md.supplier_id = p_supplier_id;

      return l_total_pallets;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;



   function get_total_pieces_supp  (p_plan_id in number,
                                    p_supplier_id in number)
      return number is

      l_total_pieces number;

   begin
      -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
/*      select sum(md.number_of_pieces)
      into   l_total_pieces
      from  mst_deliveries md
      where md.plan_id = p_plan_id
      and   md.supplier_id = p_supplier_id;
*/
      --and exists (select 1 from mst_delivery_legs mdl
      --           where md.delivery_id = mdl.delivery_id
      --          );

      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(nvl(mdd.requested_quantity,0))
      into   l_total_pieces
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and md.supplier_id = p_supplier_id;

      return l_total_pieces;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;



   function get_total_orders_supp  (p_plan_id in number,
                                    p_supplier_id in number)
      return number is

      l_total_orders number;

   begin
      -- ----------------------------------------
      -- As per bug#3283569, we need to consider
      -- raw orders instead of TP order lines.
      -- ----------------------------------------
      /***
      select count(1)
      into l_total_orders
      from mst_delivery_details mdd,
           mst_delivery_assignments mda
      where mdd.plan_id = p_plan_id
      and mdd.supplier_id = p_supplier_id
      and mdd.split_from_delivery_detail_id is null
      and mdd.delivery_detail_id = mda.delivery_detail_id
      and mda.parent_delivery_detail_id is null
      and exists (select 1
                 from mst_delivery_legs mdl
                 where mdl.delivery_id = mda.delivery_id
                );
      ***/
      /*SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      FROM MST_DELIVERY_DETAILS MDD,
           MST_DELIVERIES MD,
           MST_DELIVERY_ASSIGNMENTS MDA
      WHERE MD.PLAN_ID     = MDA.PLAN_ID
      AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
      AND   MD.DELIVERY_ID IN
                (SELECT MDL.DELIVERY_ID
                 FROM  MST_DELIVERY_LEGS MDL
                 WHERE MDL.PLAN_ID = MD.PLAN_ID)
      AND   MDA.PLAN_ID = MDD.PLAN_ID
      AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
      AND   MD.PLAN_ID = P_PLAN_ID
      AND   MD.SUPPLIER_ID = p_supplier_id;*/
      -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
      SELECT COUNT(DISTINCT dd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      from (
            SELECT mdd.SOURCE_HEADER_NUMBER
            FROM MST_DELIVERY_DETAILS MDD,
                 MST_DELIVERIES MD,
                 MST_DELIVERY_ASSIGNMENTS MDA
            WHERE MD.PLAN_ID     = MDA.PLAN_ID
            AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
            AND   MD.DELIVERY_ID IN
                    (SELECT MDL.DELIVERY_ID
                     FROM  MST_DELIVERY_LEGS MDL
                    WHERE MDL.PLAN_ID = MD.PLAN_ID)
            AND   MDA.PLAN_ID = MDD.PLAN_ID
            AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
            AND   MD.PLAN_ID = p_PLAN_ID
            AND   MD.SUPPLIER_ID = p_supplier_id
            union all
            SELECT mdd.SOURCE_HEADER_NUMBER
            FROM MST_DELIVERY_DETAILS MDD,
                 MST_DELIVERIES MD,
                 MST_DELIVERY_ASSIGNMENTS MDA
            WHERE MD.PLAN_ID     = MDA.PLAN_ID
            AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
            AND   not exists
                    (SELECT 1
                     FROM  MST_DELIVERY_LEGS MDL
                     WHERE MDL.PLAN_ID = MD.PLAN_ID
                     and MDL.DELIVERY_ID = md.plan_id)
            AND   MDA.PLAN_ID = MDD.PLAN_ID
            AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
            AND   MD.PLAN_ID = p_PLAN_ID
            AND   MD.SUPPLIER_ID = p_supplier_id) dd;
      return l_total_orders;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;



/* Customer/Supplier Facility Details */
   function get_total_cost_c_s_fac (p_plan_id in number, p_facility_type in number,
                                    p_cust_or_supp_id in number, p_location_id in number)
      return number is

      l_total_cost number;

   begin
      select sum(mdl.allocated_fac_loading_cost + mdl.allocated_fac_unloading_cost
               + mdl.ALLOCATED_FAC_SHP_HAND_COST + mdl.ALLOCATED_FAC_REC_HAND_COST + mdl.allocated_transport_cost)
      into   l_total_cost
      from  mst_deliveries md,
            mst_delivery_legs mdl
      where md.plan_id = p_plan_id
      and decode(p_facility_type, 0, md.customer_id, md.supplier_id) = p_cust_or_supp_id
      and (md.pickup_location_id = p_location_id
           or md.dropoff_location_id = p_location_id)
      and   md.delivery_id = mdl.delivery_id;
      l_total_cost := NVL(l_total_cost,0);
      return l_total_cost;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;


   function get_total_weight_c_s_fac  (p_plan_id in number, p_facility_type in number,
                                    p_cust_or_supp_id in number, p_location_id in number)
      return number is

      l_total_weight number;

   begin
     -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
      -- --------------------
      -- Bug#3423219
      -- Need to show net wt.
      -- --------------------
      --select sum(md.gross_weight)
/*     select sum(md.net_weight)
     into l_total_weight
     from mst_deliveries md
     where md.plan_id = p_plan_id
     and decode(p_facility_type, 0, md.customer_id, md.supplier_id) = p_cust_or_supp_id
     and (md.pickup_location_id = p_location_id
           or md.dropoff_location_id = p_location_id);
*/
     --and exists (select * from mst_delivery_legs mdl
     --            where md.delivery_id = mdl.delivery_id
     --           );
     -- l_total_weight := NVL(l_total_weight,0);

      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(nvl(mdd.net_weight,0))
      into l_total_weight
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and decode(p_facility_type, 0, md.customer_id, md.supplier_id) = p_cust_or_supp_id
      and (md.pickup_location_id = p_location_id
           or md.dropoff_location_id = p_location_id);

      return l_total_weight;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_total_cube_c_s_fac  (p_plan_id in number,p_facility_type in number,
                                    p_cust_or_supp_id in number, p_location_id in number)
      return number is

      l_total_cube number;

   begin
     -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
/*     select sum(md.volume)
     into l_total_cube
     from mst_deliveries md
     where md.plan_id = p_plan_id
     and decode(p_facility_type, 0, md.customer_id, md.supplier_id) = p_cust_or_supp_id
     and (md.pickup_location_id = p_location_id
           or md.dropoff_location_id = p_location_id);
*/
     --and exists (select * from mst_delivery_legs mdl
     --            where md.delivery_id = mdl.delivery_id
     --           );
--      l_total_cube := NVL(l_total_cube,0);

      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(nvl(mdd.volume,0))
      into l_total_cube
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and decode(p_facility_type, 0, md.customer_id, md.supplier_id) = p_cust_or_supp_id
      and (md.pickup_location_id = p_location_id
           or md.dropoff_location_id = p_location_id);

      return l_total_cube;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_total_pallets_c_s_fac  (p_plan_id in number, p_facility_type in number,
                                    p_cust_or_supp_id in number, p_location_id in number)
      return number is

      l_total_pallets number;

   begin
     -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
/*     select sum(md.number_of_pallets)
     into l_total_pallets
     from mst_deliveries md
     where md.plan_id = p_plan_id
     and decode(p_facility_type, 0, md.customer_id, md.supplier_id) = p_cust_or_supp_id
     and (md.pickup_location_id = p_location_id
           or md.dropoff_location_id = p_location_id);
*/
     --and exists (select * from mst_delivery_legs mdl
     --            where md.delivery_id = mdl.delivery_id
     --           );

--      l_total_pallets := NVL(l_total_pallets,0);

      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(ceil(nvl(mdd.number_of_pallets,0)))
      into l_total_pallets
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and decode(p_facility_type, 0, md.customer_id, md.supplier_id) = p_cust_or_supp_id
      and (md.pickup_location_id = p_location_id
           or md.dropoff_location_id = p_location_id);

      return l_total_pallets;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_total_pieces_c_s_fac  (p_plan_id in number, p_facility_type in number,
                                    p_cust_or_supp_id in number, p_location_id in number)
      return number is

      l_total_pieces number;

   begin
     -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
/*     select sum(md.number_of_pieces)
     into l_total_pieces
     from mst_deliveries md
     where md.plan_id = p_plan_id
     and decode(p_facility_type, 0, md.customer_id, md.supplier_id) = p_cust_or_supp_id
     and (md.pickup_location_id = p_location_id
           or md.dropoff_location_id = p_location_id);
*/
     --and exists (select 1 from mst_delivery_legs mdl
     --            where md.delivery_id = mdl.delivery_id
     --           );

  --    l_total_pieces := NVL(l_total_pieces, 0);


      -- ----------------------------------------
      -- Changing as per bug#3548552
      -- ----------------------------------------

      select sum(nvl(mdd.requested_quantity,0))
      into l_total_pieces
      from mst_delivery_details mdd
      , mst_delivery_assignments mda
      , mst_deliveries md
      where md.plan_id = mda.plan_id
      and md.delivery_id = mda.delivery_id
      and mda.plan_id = mdd.plan_id
      and mda.delivery_detail_id = mdd.delivery_detail_id
      and mdd.container_flag = 2
      and md.plan_id = p_plan_id
      and decode(p_facility_type, 0, md.customer_id, md.supplier_id) = p_cust_or_supp_id
      and (md.pickup_location_id = p_location_id
           or md.dropoff_location_id = p_location_id);

      return l_total_pieces;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   end;

   function get_total_order_c_s_fac (p_plan_id in number, p_facility_type in number,
                                    p_cust_or_supp_id in number,p_location_id in number)
       return number is
       l_total_orders number;
    BEGIN
        -- ----------------------------------------
        -- As per bug#3283731, we need to consider
        -- raw orders instead of TP order lines.
        -- ----------------------------------------
      /***
      select count(1)
      into l_total_orders
      from mst_delivery_details mdd,
           mst_delivery_assignments mda
      where mdd.plan_id = p_plan_id
      and decode(p_facility_type, 0, mdd.customer_id, mdd.supplier_id) = p_cust_or_supp_id
      and (mdd.ship_from_location_id = p_location_id or
           mdd.ship_to_location_id = p_location_id)
      and mdd.split_from_delivery_detail_id is null
      and mdd.delivery_detail_id = mda.delivery_detail_id
      and mda.parent_delivery_detail_id is null
      and exists (select 1
                 from mst_delivery_legs mdl
                 where mdl.delivery_id = mda.delivery_id
                );
    ***/
      -- ----------------------------------------
      -- As per bug#3316114, we need to consider
      -- both Assigned and Unassigned deliveries.
      -- ----------------------------------------
    IF p_facility_type = 0 THEN
        SELECT COUNT(DISTINCT dd.SOURCE_HEADER_NUMBER)
        INTO l_total_orders
        FROM (
            SELECT mdd.SOURCE_HEADER_NUMBER
            FROM MST_DELIVERY_DETAILS MDD,
                 MST_DELIVERIES MD,
                 MST_DELIVERY_ASSIGNMENTS MDA
            WHERE MD.PLAN_ID     = MDA.PLAN_ID
            AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
            AND   MDA.PLAN_ID = MDD.PLAN_ID
            AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
            AND   MD.PLAN_ID = P_PLAN_ID
            AND   MD.CUSTOMER_ID = P_CUST_OR_SUPP_ID
            AND   MD.DELIVERY_ID IN
                    (SELECT MDL.DELIVERY_ID
                     FROM  MST_DELIVERY_LEGS MDL,
                           MST_TRIP_STOPS MTS
                     WHERE MDL.PLAN_ID = MD.PLAN_ID
                     AND   MDL.PLAN_ID = MTS.PLAN_ID
                     AND (   MDL.PICK_UP_STOP_ID = MTS.STOP_ID
                          OR MDL.DROP_OFF_STOP_ID = MTS.STOP_ID)
                     AND   MTS.STOP_LOCATION_ID = P_LOCATION_ID)
            union ALL
            SELECT mdd.SOURCE_HEADER_NUMBER
            FROM MST_DELIVERY_DETAILS MDD,
                 MST_DELIVERIES MD,
                 MST_DELIVERY_ASSIGNMENTS MDA
            WHERE MD.PLAN_ID     = MDA.PLAN_ID
            AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
            AND   MDA.PLAN_ID = MDD.PLAN_ID
            AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
            AND   MD.PLAN_ID = P_PLAN_ID
            AND   MD.CUSTOMER_ID = P_CUST_OR_SUPP_ID
            AND   md.dropoff_location_id = p_location_id
            AND   NOT EXISTS (SELECT 1 FROM mst_delivery_legs mdl
                              WHERE mdl.plan_id=md.plan_id
                              AND   mdl.delivery_id = md.delivery_id)) dd;
      ELSE
        SELECT COUNT(DISTINCT dd.SOURCE_HEADER_NUMBER)
        INTO l_total_orders
        FROM (
                SELECT mdd.SOURCE_HEADER_NUMBER
                FROM MST_DELIVERY_DETAILS MDD,
                     MST_DELIVERIES MD,
                     MST_DELIVERY_ASSIGNMENTS MDA
                WHERE MD.PLAN_ID     = MDA.PLAN_ID
                AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
                AND   MDA.PLAN_ID = MDD.PLAN_ID
                AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
                AND   MD.PLAN_ID = P_PLAN_ID
                AND   MD.SUPPLIER_ID = P_CUST_OR_SUPP_ID
                AND   MD.DELIVERY_ID IN
                    (SELECT MDL.DELIVERY_ID
                     FROM  MST_DELIVERY_LEGS MDL,
                           MST_TRIP_STOPS MTS
                     WHERE MDL.PLAN_ID = MD.PLAN_ID
                     AND   MDL.PLAN_ID = MTS.PLAN_ID
                     AND (   MDL.PICK_UP_STOP_ID = MTS.STOP_ID
                          OR MDL.DROP_OFF_STOP_ID = MTS.STOP_ID)
                     AND   MTS.STOP_LOCATION_ID = P_LOCATION_ID)
                union ALL
                SELECT mdd.SOURCE_HEADER_NUMBER
                FROM MST_DELIVERY_DETAILS MDD,
                     MST_DELIVERIES MD,
                     MST_DELIVERY_ASSIGNMENTS MDA
                WHERE MD.PLAN_ID     = MDA.PLAN_ID
                AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
                AND   MDA.PLAN_ID = MDD.PLAN_ID
                AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
                AND   MD.PLAN_ID = P_PLAN_ID
                AND   MD.SUPPLIER_ID = P_CUST_OR_SUPP_ID
                AND   md.dropoff_location_id = p_location_id
                AND   NOT EXISTS (SELECT 1 FROM mst_delivery_legs mdl
                                  WHERE mdl.plan_id=md.plan_id
                                  AND   mdl.delivery_id = md.delivery_id)) dd;

        END IF;
      l_total_orders := NVL(l_total_orders, 0);
      return l_total_orders;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
    end;
-- This function is merged from Sasidhar's package
-- the function name has been changed from get_total_direct_tls_facility for consistency
   FUNCTION get_total_tl_count_c_s_fac
                                      (p_plan_id        IN NUMBER,
                                       p_partner_id     IN NUMBER,
                                       p_partner_type   IN NUMBER,
                                       p_location_id    IN NUMBER,
                                       p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER IS

      l_total_trips NUMBER;

   BEGIN
        -- Used in Customer/Supplier Facility Details UI
        IF p_mode_of_transport = DTL THEN -- Direct TL
            IF (p_partner_type = CUSTOMER) THEN
                -- ---------------------------------------------------- --
                -- For a given customer facility and mode of transport, --
                -- consider all those deliveries handled by that trip.  --
                -- Verify for origin (OE) or destination (RFC)Locations --
                -- of these diliveries to be custmer facility. Also,    --
                -- verify if these deliveries been assigned to one or   --
                -- more delivery legs. Check the number of stops for    --
                -- each trip to be 2 (Direct)Get count of such trips.   --
                -- ---------------------------------------------------- --
                SELECT COUNT(mt.trip_id)
                INTO   l_total_trips
                FROM mst_trips mt
                WHERE mt.plan_id = p_plan_id
                AND   mt.trip_id IN
                                 (select distinct mts.trip_id
                                  from mst_trip_stops mts
                                  , mst_delivery_legs mdl
                                  , mst_deliveries md
                                  where md.plan_id = mt.plan_id
                                  and md.customer_id = p_partner_id
                                  and mts.plan_id = md.plan_id
                                  and mts.stop_location_id = md.dropoff_location_id
                                  and md.dropoff_location_id = p_location_id
                                  and mdl.plan_id = md.plan_id
                                  and mdl.delivery_id = md.delivery_id
                                  and mdl.trip_id = mts.trip_id
                                  and mdl.drop_off_stop_id = mts.stop_id)
                AND   mt.mode_of_transport = TRUCK -- p_mode_of_transport
                AND   EXISTS
                        (SELECT ts.trip_id
                         FROM mst_trip_stops ts
                         WHERE ts.plan_id = mt.plan_id
                         AND   ts.trip_id = mt.trip_ID
                         HAVING COUNT(ts.stop_id) =2
                         GROUP BY ts.trip_id) ;

            ELSIF (p_partner_type = SUPPLIER) THEN
                -- ---------------------------------------------------- --
                -- For a given supplier facility and mode of transport, --
                -- consider all those deliveries handled by that trip.  --
                -- Verify for origin (PO) or destination (RTV)Locations --
                -- of these diliveries to be supplier facility. Also,    --
                -- verify if these deliveries been assigned to one or   --
                -- more delivery legs. Check the number of stops for    --
                -- each trip to be 2 (Direct)Get count of such trips.   --
                -- ---------------------------------------------------- --
                SELECT COUNT(mt.trip_id)
                INTO   l_total_trips
                FROM mst_trips mt
                WHERE mt.plan_id = p_plan_id
                AND   mt.trip_id IN
                                 (select distinct mts.trip_id
                                  from mst_trip_stops mts
                                  , mst_delivery_legs mdl
                                  , mst_deliveries md
                                  where md.plan_id = mt.plan_id
                                  and md.supplier_id = p_partner_id
                                  and mts.plan_id = md.plan_id
                                  and mts.stop_location_id = md.pickup_location_id
                                  and md.pickup_location_id = p_location_id
                                  and mdl.plan_id = md.plan_id
                                  and mdl.delivery_id = md.delivery_id
                                  and mdl.trip_id = mts.trip_id
                                  and mdl.pick_up_stop_id = mts.stop_id)
                AND   mt.mode_of_transport = TRUCK -- p_mode_of_transport
                AND   EXISTS
                        (SELECT ts.trip_id
                         FROM mst_trip_stops ts
                         WHERE ts.plan_id = mt.plan_id
                         AND   ts.trip_id = mt.trip_ID
                         HAVING COUNT(ts.stop_id) =2
                         GROUP BY ts.trip_id) ;

            END IF;
        ELSE
            IF (p_partner_type = CUSTOMER) THEN
                -- ---------------------------------------------------- --
                -- For a given customer facility and mode of transport, --
                -- consider all those deliveries handled by that trip.  --
                -- Verify for origin (OE) or destination (RFC)Locations --
                -- of these diliveries to be custmer facility. Also,    --
                -- verify if these deliveries been assigned to one or   --
                -- more delivery legs. Check number of stops in each    --
                -- trip to be > 2 (Multi stop)Get count of such trips.  --
                -- ---------------------------------------------------- --
                SELECT COUNT(mt.trip_id)
                INTO   l_total_trips
                FROM mst_trips mt
                WHERE mt.plan_id = p_plan_id
                AND   mt.trip_id IN
                                 (select distinct mts.trip_id
                                  from mst_trip_stops mts
                                  , mst_delivery_legs mdl
                                  , mst_deliveries md
                                  where md.plan_id = mt.plan_id
                                  and md.customer_id = p_partner_id
                                  and mts.plan_id = md.plan_id
                                  and mts.stop_location_id = md.dropoff_location_id
                                  and md.dropoff_location_id = p_location_id
                                  and mdl.plan_id = md.plan_id
                                  and mdl.delivery_id = md.delivery_id
                                  and mdl.trip_id = mts.trip_id
                                  and mdl.drop_off_stop_id = mts.stop_id)
                AND   mt.mode_of_transport = TRUCK -- p_mode_of_transport
                AND   EXISTS
                        (SELECT ts.trip_id
                         FROM mst_trip_stops ts
                         WHERE ts.plan_id = mt.plan_id
                         AND   ts.trip_id = mt.trip_ID
                         HAVING COUNT(ts.stop_id) > 2
                         GROUP BY ts.trip_id) ;

            ELSIF (p_partner_type = SUPPLIER) THEN
                -- ---------------------------------------------------- --
                -- For a given supplier facility and mode of transport, --
                -- consider all those deliveries handled by that trip.  --
                -- Verify for origin (PO) or destination (RTV)Locations --
                -- of these diliveries to be supplier facility. Also,    --
                -- verify if these deliveries been assigned to one or   --
                -- more delivery legs. Check number of stops in each    --
                -- trip to be > 2 (Multi stop)Get count of such trips.  --
                -- ---------------------------------------------------- --
                SELECT COUNT(mt.trip_id)
                INTO   l_total_trips
                FROM mst_trips mt
                WHERE mt.plan_id = p_plan_id
                AND   mt.trip_id IN
                                 (select distinct mts.trip_id
                                  from mst_trip_stops mts
                                  , mst_delivery_legs mdl
                                  , mst_deliveries md
                                  where md.plan_id = mt.plan_id
                                  and md.supplier_id = p_partner_id
                                  and mts.plan_id = md.plan_id
                                  and mts.stop_location_id = md.pickup_location_id
                                  and md.pickup_location_id = p_location_id
                                  and mdl.plan_id = md.plan_id
                                  and mdl.delivery_id = md.delivery_id
                                  and mdl.trip_id = mts.trip_id
                                  and mdl.pick_up_stop_id = mts.stop_id)
                AND   mt.mode_of_transport = TRUCK -- p_mode_of_transport
                AND   EXISTS
                        (SELECT ts.trip_id
                         FROM mst_trip_stops ts
                         WHERE ts.plan_id = mt.plan_id
                         AND   ts.trip_id = mt.trip_ID
                         HAVING COUNT(ts.stop_id) >2
                         GROUP BY ts.trip_id) ;
            END IF;
        END IF;
      l_total_trips := NVL(l_total_trips,0);
      RETURN l_total_trips;
   EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   END get_total_tl_count_c_s_fac;

-- This function is merged from Sasidhar's package
-- the function name has been changed from get_total_trips_facility for consistency
    FUNCTION get_total_trips_c_s_fac(    p_plan_id      IN NUMBER,
                                         p_partner_id   IN NUMBER,
                                         p_partner_type IN NUMBER,
                                         p_location_id  IN NUMBER,
                                         p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER IS

      l_total_trips NUMBER := 0;

   BEGIN
      -- Used in Customer/Supplier Facility Details UI
      IF (p_partner_type = CUSTOMER) THEN
        -- ---------------------------------------------------- --
        -- For a given customer facility and mode of transport, --
        -- consider all those deliveries handled by that trip.  --
        -- Verify for origin (OE) or destination (RFC)Locations --
        -- of these diliveries to be custmer facility. Also,    --
        -- verify if these deliveries been assigned to one or   --
        -- more delivery legs.                                  --
        -- ---------------------------------------------------- --
         /*SELECT COUNT(mt.trip_id)
         INTO   l_total_trips
         FROM mst_trips mt
         WHERE mt.plan_id   = p_plan_id
         AND   mt.trip_id IN
                    (SELECT mdl.trip_id
                     FROM mst_delivery_legs mdl,
                          mst_deliveries md
                     WHERE mdl.plan_id    = mt.plan_id
                     AND   md.plan_id     = mdl.plan_id
                     AND   md.delivery_id = mdl.delivery_id
                     AND   md.customer_id = p_partner_id
                     AND   (   md.pickup_location_id = p_location_id
                            OR md.dropoff_location_id = p_location_id))
         AND   mt.mode_of_transport       = p_mode_of_transport;*/
         -- Rewritten for bug#3598252.
         SELECT COUNT(mt.trip_id)
         INTO   l_total_trips
         FROM mst_trips mt
         WHERE mt.plan_id   = p_plan_id
         AND   mt.trip_id IN
                    (SELECT mdl.trip_id
                     FROM mst_delivery_legs mdl,
                          mst_deliveries md,
						  mst_trip_stops mts
                     WHERE mdl.plan_id    = mt.plan_id
                     AND   md.plan_id     = mdl.plan_id
                     AND   md.delivery_id = mdl.delivery_id
                     AND   md.customer_id = p_partner_id
					 AND   mts.plan_id = mdl.plan_id
					 AND   (   mdl.pick_up_stop_id = mts.stop_id
                            OR mdl.drop_off_stop_id = mts.stop_id)
					 AND   mts.stop_location_id =  p_location_id)
         AND   mt.mode_of_transport       = p_mode_of_transport;

      ELSIF (p_partner_type = SUPPLIER) THEN
        -- ---------------------------------------------------- --
        -- For a given supplier facility and mode of transport, --
        -- consider all those deliveries handled by that trip.  --
        -- Verify for origin (PO) or destination (RTV)Locations --
        -- of these diliveries to be custmer facility. Also,    --
        -- verify if these deliveries been assigned to one or   --
        -- more delivery legs.                                  --
        -- ---------------------------------------------------- --
         /*SELECT COUNT(mt.trip_id)
         INTO   l_total_trips
         FROM mst_trips mt
         WHERE mt.plan_id   = p_plan_id
         AND   mt.trip_id IN
                    (SELECT mdl.trip_id
                     FROM mst_delivery_legs mdl,
                          mst_deliveries md
                     WHERE mdl.plan_id    = mt.plan_id
                     AND   md.plan_id     = mdl.plan_id
                     AND   md.delivery_id = mdl.delivery_id
                     AND   md.supplier_id = p_partner_id
                     AND   (   md.pickup_location_id = p_location_id
                            OR md.dropoff_location_id = p_location_id))
         AND   mt.mode_of_transport       = p_mode_of_transport;*/
         -- Rewritten for bug#3598252.
         SELECT COUNT(mt.trip_id)
         INTO   l_total_trips
         FROM mst_trips mt
         WHERE mt.plan_id   = p_plan_id
         AND   mt.trip_id IN
                    (SELECT mdl.trip_id
                     FROM mst_delivery_legs mdl,
                          mst_deliveries md,
						  mst_trip_stops mts
                     WHERE mdl.plan_id    = mt.plan_id
                     AND   md.plan_id     = mdl.plan_id
                     AND   md.delivery_id = mdl.delivery_id
                     AND   md.supplier_id = p_partner_id
					 AND   mts.plan_id = mdl.plan_id
					 AND   (   mdl.pick_up_stop_id = mts.stop_id
                            OR mdl.drop_off_stop_id = mts.stop_id)
					 AND   mts.stop_location_id =  p_location_id)
         AND   mt.mode_of_transport       = p_mode_of_transport;
      END IF;

      l_total_trips := NVL(l_total_trips,0);
      RETURN l_total_trips;

   EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   END get_total_trips_c_s_fac;

/* My Facility Details*/
-- This function is merged from Sasidhar's package
-- the function name has been changed from get_total_trips_Myfacility for consistency
   FUNCTION get_total_trips_for_myfac( p_plan_id           IN NUMBER,
                                        p_fac_loc_id        IN NUMBER,
                                        p_mode_of_transport IN VARCHAR2,
                                        p_location_type     IN VARCHAR2)
      RETURN NUMBER IS

      CURSOR get_trips IS
      SELECT COUNT(mt.trip_id)
      FROM mst_trips mt
      WHERE mt.plan_id = p_plan_id
      AND   mt.mode_of_transport = p_mode_of_transport
      AND   mt.trip_id IN (
                    SELECT ts.trip_id
                    FROM mst_trip_stops ts,
                         mst_delivery_legs mdl
                    WHERE ts.plan_id = p_plan_id
                    AND   ts.stop_location_id = p_fac_loc_id
                    AND   ts.plan_Id = mdl.plan_Id
                    AND   (   ts.stop_id = mdl.pick_up_stop_id
                           OR ts.stop_id = mdl.drop_off_stop_id));

      CURSOR get_empty_trips IS
      SELECT COUNT(mt.trip_id)
      FROM mst_trips mt
      WHERE mt.plan_id = p_plan_id
      AND   mt.mode_of_transport = p_mode_of_transport
      AND   mt.continuous_move_id IS NULL
      AND   EXISTS (SELECT 1
                    FROM mst_trip_stops mts
                    WHERE mts.plan_id = mt.plan_id
                    AND   mts.trip_id = mt.trip_id
                    AND   mts.stop_location_id = p_fac_loc_id)
      AND   NOT EXISTS (SELECT 1
                        FROM mst_delivery_legs mdl
                        WHERE mdl.plan_id = mt.plan_id
                        AND   mdl.trip_id = mt.trip_id);

      CURSOR get_trips_load IS
      SELECT COUNT(mt.trip_id)
      FROM mst_trips mt
      WHERE mt.plan_id = p_plan_id
      AND   mt.mode_of_transport = p_mode_of_transport
      AND   mt.trip_id IN (
                    SELECT ts.trip_id
                    FROM mst_trip_stops ts,
                         mst_delivery_legs mdl
                    WHERE ts.plan_id = p_plan_id
                    AND   ts.stop_location_id = p_fac_loc_id
                    AND   ts.stop_id          = mdl.pick_up_stop_id
                    AND   ts.plan_id          = mdl.plan_id);

      CURSOR get_trips_unload IS
      SELECT count(mt.trip_id)
      FROM mst_trips mt
      WHERE mt.plan_id = p_plan_id
      AND   mt.mode_of_transport = p_mode_of_transport
      AND   mt.trip_id IN (
                    SELECT ts.trip_id
                    FROM mst_trip_stops ts,
                         mst_delivery_legs mdl
                    WHERE ts.plan_id = p_plan_id
                    AND   ts.stop_location_id = p_fac_loc_id
                    AND   ts.stop_id          = mdl.drop_off_stop_id
                    AND   ts.plan_id          = mdl.plan_id);

      l_total_trips NUMBER := 0;
      l_empty_trips NUMBER := 0;

   BEGIN
   -- Used in MyFacility Details UI
    IF p_location_type IS NULL THEN
        OPEN get_trips;
        FETCH get_trips INTO l_total_trips;
        CLOSE get_trips;

        OPEN get_empty_trips;
        FETCH get_empty_trips INTO l_empty_trips;
        CLOSE get_empty_trips;
        l_total_trips := NVL(l_total_trips,0) + NVL(l_empty_trips,0);
    ELSIF p_location_type = 'L' THEN
        OPEN get_trips_load;
        FETCH get_trips_load INTO l_total_trips;
        CLOSE get_trips_load;
    ELSIF p_location_type = 'U' THEN
        OPEN get_trips_unload;
        FETCH get_trips_unload INTO l_total_trips;
        CLOSE get_trips_unload;
    END IF;

    RETURN l_total_trips;

   EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   END get_total_trips_for_myfac;

-- This function is merged from Sasidhar's package
-- the function name has been changed from get_total_orders_Myfacility for consistency
-- the implementation logic has also been changed to aggregate on TP orders instead of raw orders
   FUNCTION get_total_orders_for_myfac(  p_plan_id            IN NUMBER,
                                         p_my_fac_location_id IN NUMBER,
                                         p_mode               IN VARCHAR2 DEFAULT null,
                                         p_activity_type      IN VARCHAR2 DEFAULT null)
      RETURN NUMBER IS

      l_orders  NUMBER;
      l_total_orders NUMBER;

   BEGIN
/*      -- Used in MyFacility Details UI
        -- -------------------------------------------
        -- Deliveries with delivery legs whose
        -- intermediate drop-off is at my facility.
        -- It was assumed that at an intermediate
        -- stop, all the deliveries that are getting
        -- dropped off (from one trip), will be picked
        -- up (by other trip).
        -- -------------------------------------------
        SELECT COUNT(DISTINCT mdd.source_header_number)
        INTO   l_orders
        FROM  mst_delivery_details mdd
        WHERE mdd.plan_id = p_plan_id
        AND   mdd.delivery_detail_id IN
                (SELECT mda.delivery_detail_id
                 FROM mst_delivery_assignments mda,
                      mst_trips mt,
                      mst_trip_stops mts,
                      mst_delivery_legs mdl,
                      mst_deliveries md
                 WHERE mda.plan_id      = mdd.plan_id
                 AND   mda.plan_id      = md.plan_id
                 AND   mda.delivery_id  = md.delivery_id
                 AND   md.plan_id       = mdl.plan_id
                 AND   md.delivery_id   = mdl.delivery_id
                 AND   mdl.plan_id      = mts.plan_id
                 AND   mdl.drop_off_stop_id = mts.stop_id
                 AND   mts.stop_location_id = p_fac_loc_id
                 AND   mt.plan_id       = mts.plan_id
                 AND   mt.trip_id       = mts.trip_id
                 AND   mt.mode_of_transport = p_mode_of_transport
                 AND  (   md.pickup_location_id <> p_fac_loc_id
                       OR md.dropoff_location_id <> p_fac_loc_id ));

        l_total_orders := l_orders;
        l_orders := 0;
    IF p_activity_type IS NULL THEN
        -- ------------------------------
        -- deliveries whose origination
        -- or destination is my facility:
        -- ------------------------------
        SELECT COUNT(DISTINCT mdd.source_header_number)
        INTO   l_orders
        FROM   mst_delivery_details mdd
        WHERE mdd.plan_id = p_plan_id
        AND   mdd.delivery_detail_id IN
                      ( SELECT mda.delivery_detail_id
                        FROM  mst_delivery_assignments mda,
                              mst_deliveries md,
                              mst_trips mt,
                              mst_delivery_legs mdl
                        WHERE mda.plan_id       = mdd.plan_id
                        AND   mda.plan_id       = md.plan_id
                        AND   mda.delivery_id   = md.delivery_id
                        AND   md.plan_id        = mdl.plan_id
                        AND   md.delivery_id    = mdl.delivery_id
                        AND   mdl.plan_id       = mt.plan_Id
                        AND   mdl.trip_id       = mt.trip_id
                        AND   mt.mode_of_transport = p_mode_of_transport
                        AND   (   md.pickup_location_id = p_fac_loc_id
                               OR md.dropoff_location_id = p_fac_loc_id));

        l_total_orders := l_total_orders + l_orders;

    ELSIF p_activity_type = 'L' THEN
        -- ------------------------------
        -- deliveries whose origination
        -- is my facility:
        -- ------------------------------
        SELECT COUNT(DISTINCT mdd.source_header_number)
        INTO   l_orders
        FROM   mst_delivery_details mdd
        WHERE mdd.plan_id = p_plan_id
        AND   mdd.delivery_detail_id IN
                      ( SELECT mda.delivery_detail_id
                        FROM  mst_delivery_assignments mda,
                              mst_deliveries md,
                              mst_trips mt,
                              mst_delivery_legs mdl
                        WHERE mda.plan_id       = mdd.plan_id
                        AND   mda.plan_id       = md.plan_id
                        AND   mda.delivery_id   = md.delivery_id
                        AND   md.plan_id        = mdl.plan_id
                        AND   md.delivery_id    = mdl.delivery_id
                        AND   mdl.plan_id       = mt.plan_Id
                        AND   mdl.trip_id       = mt.trip_id
                        AND   mt.mode_of_transport = p_mode_of_transport
                        AND   md.pickup_location_id = p_fac_loc_id );

        l_total_orders := l_total_orders + l_orders;

    ELSIF p_location_type = 'U' THEN
        -- ------------------------------
        -- deliveries whose destination
        -- is my facility:
        -- ------------------------------
        SELECT COUNT(DISTINCT mdd.source_header_number)
        INTO   l_orders
        FROM   mst_delivery_details mdd
        WHERE mdd.plan_id = p_plan_id
        AND   mdd.delivery_detail_id IN
                      ( SELECT mda.delivery_detail_id
                        FROM  mst_delivery_assignments mda,
                              mst_deliveries md,
                              mst_trips mt,
                              mst_delivery_legs mdl
                        WHERE mda.plan_id     = mdd.plan_id
                        AND   mda.plan_id     = md.plan_id
                        AND   mda.delivery_id = md.delivery_id
                        AND   md.plan_id      = mdl.plan_id
                        AND   md.delivery_id  = mdl.delivery_id
                        AND   mdl.plan_id     = mt.plan_Id
                        AND   mdl.trip_id     = mt.trip_id
                        AND   mt.mode_of_transport = p_mode_of_transport
                        AND   md.dropoff_location_id = p_fac_loc_id );

        l_total_orders := l_total_orders + l_orders;

    END IF;
*/

 --as per requirements in bug # 3364598
 --total orders for a given facility location
 if (p_activity_type is null and p_mode is null) then
   select count(distinct mdd.source_header_number)
   into l_total_orders
   from mst_delivery_details mdd,
        mst_deliveries md,
        mst_delivery_assignments mda
   where md.plan_id     = mda.plan_id
   and   md.delivery_id = mda.delivery_id
   and   md.delivery_id in
                (select mdl.delivery_id
                 from mst_trips t,
                      mst_trip_stops ts,
                      mst_delivery_legs mdl
                 where mdl.plan_id = md.plan_id
                 and   ts.plan_id  = mdl.plan_id
                 and   (ts.stop_id  = mdl.pick_up_stop_id
		        or ts.stop_id = mdl.drop_off_stop_id)
                 and   ts.stop_location_id = p_my_fac_location_id
                 and   ts.plan_id  = t.plan_id
                 and   ts.trip_id  = t.trip_id)
   and   mda.plan_id = mdd.plan_id
   and   mda.delivery_detail_id = mdd.delivery_detail_id
   and   md.plan_id = p_plan_id
   and   mdd.container_flag = 2;
 end if;


    -- total orders for a given mode_of_transport
    if p_activity_type is null and p_mode is not null then
      select count(mdd.delivery_detail_id)
      into l_total_orders
      from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md,
         mst_delivery_details mdd,
         mst_delivery_assignments mda
      where mt.plan_id = p_plan_id
      and   mt.mode_of_transport = p_mode
      and   mt.trip_id = mts.trip_id
      and   mt.trip_id = mdl.trip_id
      and   (mdl.pick_up_stop_id = mts.stop_id or
             mdl.drop_off_stop_id = mts.stop_id)
      and   mts.stop_location_id = p_my_fac_location_id
      and   mdl.delivery_id = md.delivery_id
      and   md.delivery_id = mda.delivery_id
      and   mda.delivery_detail_id = mdd.delivery_detail_id
      and   mda.parent_delivery_detail_id is null
      and   mdd.split_from_delivery_detail_id is null;

    elsif p_activity_type = 'L' THEN
    /*
     - ------------------------------------------ -
     - As per bug#3244044, we need to consider    -
     - Distinct orders instead of raw orders.     -
     - ------------------------------------------ -
     */
      /*select count(mdd.delivery_detail_id)
      into l_total_orders
      from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md,
         mst_delivery_details mdd,
         mst_delivery_assignments mda
      where mt.plan_id = p_plan_id
      and   mt.mode_of_transport = p_mode
      and   mt.trip_id = mts.trip_id
      and   mt.trip_id = mdl.trip_id
      and   mdl.pick_up_stop_id = mts.stop_id
      and   mts.stop_location_id = p_my_fac_location_id
      and   mdl.delivery_id = md.delivery_id
      and   md.delivery_id = mda.delivery_id
      and   mda.delivery_detail_id = mdd.delivery_detail_id
      and   mda.parent_delivery_detail_id is null
      and   mdd.split_from_delivery_detail_id is null;*/

      SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      FROM MST_DELIVERY_DETAILS MDD,
           MST_DELIVERIES MD,
           MST_DELIVERY_ASSIGNMENTS MDA
      WHERE MD.PLAN_ID     = MDA.PLAN_ID
      AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
      AND   MD.DELIVERY_ID IN
                (SELECT MDL.DELIVERY_ID
                 FROM MST_TRIPS T,
                      MST_TRIP_STOPS TS,
                      MST_DELIVERY_LEGS MDL
                 WHERE MDL.PLAN_ID = MD.PLAN_ID
                 AND   TS.PLAN_ID  = MDL.PLAN_ID
                 AND   TS.STOP_ID  = MDL.PICK_UP_STOP_ID
                 AND   TS.STOP_LOCATION_ID = p_my_fac_location_id
                 AND   TS.PLAN_ID  = T.PLAN_ID
                 AND   TS.TRIP_ID  = T.TRIP_ID
                 AND   T.MODE_OF_TRANSPORT = P_MODE)
      AND   MDA.PLAN_ID = MDD.PLAN_ID
      AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
      AND   MD.PLAN_ID = P_PLAN_ID
      AND   MDD.CONTAINER_FLAG = 2;
--      AND   MDD.SPLIT_FROM_DELIVERY_DETAIL_ID IS NULL;
      --OR TS.STOP_ID = MDL.DROP_OFF_STOP_ID)
    elsif p_activity_type = 'U' then
      /*
     - ------------------------------------------ -
     - As per bug#3244044, we need to consider    -
     - Distinct orders instead of raw orders.     -
     - ------------------------------------------ -
     */
      /*select count(mdd.delivery_detail_id)
      into l_total_orders
      from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md,
         mst_delivery_details mdd,
         mst_delivery_assignments mda
      where mt.plan_id = p_plan_id
      and   mt.mode_of_transport = p_mode
      and   mt.trip_id = mts.trip_id
      and   mt.trip_id = mdl.trip_id
      and   mdl.drop_off_stop_id = mts.stop_id
      and   mts.stop_location_id = p_my_fac_location_id
      and   mdl.delivery_id = md.delivery_id
      and   md.delivery_id = mda.delivery_id
      and   mda.delivery_detail_id = mdd.delivery_detail_id
      and   mda.parent_delivery_detail_id is null
      and   mdd.split_from_delivery_detail_id is null;*/
      SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      FROM MST_DELIVERY_DETAILS MDD,
           MST_DELIVERIES MD,
           MST_DELIVERY_ASSIGNMENTS MDA
      WHERE MD.PLAN_ID     = MDA.PLAN_ID
      AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
      AND   MD.DELIVERY_ID IN
                (SELECT MDL.DELIVERY_ID
                 FROM MST_TRIPS T,
                      MST_TRIP_STOPS TS,
                      MST_DELIVERY_LEGS MDL
                 WHERE MDL.PLAN_ID = MD.PLAN_ID
                 AND   TS.PLAN_ID  = MDL.PLAN_ID
                 AND   TS.STOP_ID  = MDL.DROP_OFF_STOP_ID
                 AND   TS.STOP_LOCATION_ID = p_my_fac_location_id
                 AND   TS.PLAN_ID  = T.PLAN_ID
                 AND   TS.TRIP_ID  = T.TRIP_ID
                 AND   T.MODE_OF_TRANSPORT = P_MODE)
      AND   MDA.PLAN_ID = MDD.PLAN_ID
      AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
      AND   MD.PLAN_ID = P_PLAN_ID
      AND   MDD.CONTAINER_FLAG = 2;
      --AND   MDD.SPLIT_FROM_DELIVERY_DETAIL_ID IS NULL;
    end if;

      RETURN l_total_orders;
   EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   END get_total_orders_for_myfac;

-- loading/unloading/total cost for TL/LTL/Parcel
   FUNCTION get_loading_cost_for_myfac(p_plan_id            IN NUMBER,
                                       p_my_fac_location_id IN NUMBER,
                                       p_mode               IN VARCHAR2)
      RETURN NUMBER IS

      l_loading_cost NUMBER;
      l_loading_cost_temp NUMBER;
   BEGIN
     /*
     - ------------------------------------------ -
     - As per bug#3244044, we need to consider    -
     - transportation, and facility related costs -
     - along with loading cost.                   -
     - ------------------------------------------ -
     */
     -- -----------------------------------------
     -- Modified for performance ( bug#3379415).
     -- -----------------------------------------
     -- -----------------------------------------
     -- Bug#3403402 - we should consider cost of
     -- the delivery as a whole instead of a
     -- Particular leg.
     -- -----------------------------------------
    /*SELECT SUM(NVL(mdl.allocated_fac_loading_cost,0) +
               NVL(mdl.allocated_transport_cost,0)   +
               NVL(mdl.allocated_fac_shp_hand_cost,0) )
    INTO l_loading_cost
    FROM mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl
    WHERE mt.plan_id = p_plan_id
    AND   mt.mode_of_transport = p_mode
    AND   mt.plan_id = mts.plan_id
    AND   mt.trip_id = mts.trip_id
    AND   mts.plan_id = mdl.plan_id
    AND   mdl.pick_up_stop_id = mts.stop_id
    AND   mts.stop_location_id = p_my_fac_location_id;*/

    SELECT SUM(NVL(mdl.allocated_fac_loading_cost,0)  +
               NVL(mdl.allocated_transport_cost,0)    +
               NVL(mdl.allocated_fac_shp_hand_cost,0)  )
    INTO l_loading_cost
    FROM mst_delivery_legs mdl
    WHERE mdl.plan_id = p_plan_id
    AND mdl.delivery_id IN
             ( SELECT md.delivery_id
               FROM  mst_delivery_legs mdl1,
                     mst_deliveries md,
                     mst_trips mt,
                     mst_trip_stops mts
                WHERE mt.plan_id = mdl1.plan_id
                AND   mt.trip_id  = mdl1.trip_id
                AND   mt.mode_of_transport = p_mode
                and   mt.plan_id = mts.plan_Id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = p_my_fac_location_id
                AND   md.plan_id = mdl1.plan_id
                AND   md.delivery_id  = mdl1.delivery_id
                AND   md.plan_id = mdl.plan_id
                AND   md.PICKUP_LOCATION_ID = p_my_fac_location_id);
    -- ----------------------------------------
    -- As per bug#3508237, we need to consider
    -- cost of cross-dock deliveries as well.
    -- ----------------------------------------
    SELECT SUM(NVL(mdl.allocated_fac_loading_cost,0)  +
               NVL(mdl.allocated_transport_cost,0)    +
               NVL(mdl.allocated_fac_shp_hand_cost,0)  )
    INTO l_loading_cost_temp
    FROM mst_delivery_legs mdl
    WHERE mdl.plan_id = p_plan_id
    AND mdl.delivery_id IN
             ( SELECT md.delivery_id
               FROM  mst_delivery_legs mdl1,
                     mst_deliveries md,
                     mst_trips mt,
                     mst_trip_stops mts
                WHERE mt.plan_id = mdl1.plan_id
                AND   mt.trip_id  = mdl1.trip_id
                AND   mt.mode_of_transport = p_mode
                and   mt.plan_id = mts.plan_Id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = p_my_fac_location_id
                AND   MTS.STOP_ID = mdl.pick_up_stop_id
                AND   md.plan_id = mdl1.plan_id
                AND   md.delivery_id  = mdl1.delivery_id
                AND   md.plan_id = mdl.plan_id
                AND   md.PICKUP_LOCATION_ID <> mts.stop_location_id
                AND   MD.DROPOFF_LOCATION_ID <> mts.stop_location_id);

    IF l_loading_cost IS NULL THEN
        l_loading_cost := 0;
    END IF;

    IF l_loading_cost_temp IS NULL THEN
        l_loading_cost_temp := 0;
    END IF;
    RETURN l_loading_cost + l_loading_cost_temp;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  END get_loading_cost_for_myfac;

  FUNCTION get_unloading_cost_for_myfac(p_plan_id            IN NUMBER,
                                        p_my_fac_location_id IN NUMBER,
                                        p_mode               IN VARCHAR2)
      RETURN NUMBER IS

      l_unloading_cost NUMBER;
      l_unloading_cost_temp NUMBER;
   BEGIN
    /*
     - ------------------------------------------ -
     - As per bug#3244044, we need to consider    -
     - transportation, and facility related costs -
     - along with unloading cost.                 -
     - ------------------------------------------ -
     */
     -- -----------------------------------------
     -- Modified for performance ( bug#3379415).
     -- -----------------------------------------
     -- -----------------------------------------
     -- Bug#3403402 - we should consider cost of
     -- the delivery as a whole instead of just
     -- leg cost for those deliveries whose legs
     -- touch the facility.
     -- -----------------------------------------
    /*select sum(NVL(mdl.allocated_fac_unloading_cost,0)+
               NVL(mdl.allocated_transport_cost,0)    +
               NVL(mdl.allocated_fac_rec_hand_cost,0)  )
    into l_unloading_cost
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mt.plan_id = mts.plan_id
    and   mt.trip_id = mts.trip_id
    and   mts.plan_id = mdl.plan_id
    and   mdl.drop_off_stop_id = mts.stop_id
    and   mts.stop_location_id = p_my_fac_location_id;*/

    SELECT SUM(NVL(mdl.allocated_fac_unloading_cost,0)  +
               NVL(mdl.allocated_transport_cost,0)    +
               NVL(mdl.allocated_fac_rec_hand_cost,0)  )
    INTO l_unloading_Cost
    FROM mst_delivery_legs mdl
    WHERE mdl.plan_id = p_plan_id
    AND mdl.delivery_id IN
             ( SELECT md.delivery_id
               FROM  mst_delivery_legs mdl1,
                     mst_deliveries md,
                     mst_trips mt,
                     mst_trip_stops mts
                WHERE mt.plan_id = mdl1.plan_id
                AND   mt.trip_id  = mdl1.trip_id
                AND   mt.mode_of_transport = p_mode
                and   mt.plan_id = mts.plan_Id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = p_my_fac_location_id
                --AND   mts.stop_id = mdl.drop_off_stop_id
                AND   md.plan_id = mdl1.plan_id
                AND   md.delivery_id  = mdl1.delivery_id
                AND   md.plan_id = mdl.plan_id
                AND   md.DROPOFF_LOCATION_ID = p_my_fac_location_id);

    -- ----------------------------------------
    -- As per bug#3508237, we need to consider
    -- cost of cross-dock deliveries as well.
    -- ----------------------------------------
    SELECT SUM(NVL(mdl.allocated_fac_loading_cost,0)  +
               NVL(mdl.allocated_transport_cost,0)    +
               NVL(mdl.allocated_fac_shp_hand_cost,0)  )
    INTO l_unloading_cost_temp
    FROM mst_delivery_legs mdl
    WHERE mdl.plan_id = p_plan_id
    AND mdl.delivery_id IN
             ( SELECT md.delivery_id
               FROM  mst_delivery_legs mdl1,
                     mst_deliveries md,
                     mst_trips mt,
                     mst_trip_stops mts
                WHERE mt.plan_id = mdl1.plan_id
                AND   mt.trip_id  = mdl1.trip_id
                AND   mt.mode_of_transport = p_mode
                and   mt.plan_id = mts.plan_Id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = p_my_fac_location_id
                AND   MTS.STOP_ID = mdl.drop_off_stop_id
                AND   md.plan_id = mdl1.plan_id
                AND   md.delivery_id  = mdl1.delivery_id
                AND   md.plan_id = mdl.plan_id
                AND   md.PICKUP_LOCATION_ID <> mts.stop_location_id
                AND   MD.DROPOFF_LOCATION_ID <> mts.stop_location_id);

    IF l_unloading_Cost IS NULL THEN
        l_unloading_Cost := 0;
    END IF;
    IF l_unloading_cost_temp IS NULL THEN
        l_unloading_cost_temp := 0;
    END IF;
    RETURN l_unloading_cost + l_unloading_cost_temp;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  END get_unloading_cost_for_myfac;

  function get_total_cost_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number is

      l_total_cost number;
      l_total_departing_cost number;
      l_total_arriving_cost number;

      cursor departing_delivery_leg is
      select sum(mdl.allocated_fac_loading_cost + mdl.ALLOCATED_FAC_SHP_HAND_COST + mdl.allocated_transport_cost) total_departing_cost
      from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl
      where mt.plan_id = p_plan_id
      and   mt.mode_of_transport = p_mode
      and   mt.trip_id = mts.trip_id
      and   mdl.pick_up_stop_id = mts.stop_id
      and   mts.stop_location_id = p_my_fac_location_id;

      cursor arriving_delivery_leg is
      select sum(mdl.allocated_fac_unloading_cost + mdl.ALLOCATED_FAC_REC_HAND_COST+ mdl.allocated_transport_cost) total_arriving_cost
      from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl
      where mt.plan_id = p_plan_id
      and   mt.mode_of_transport = p_mode
      and   mt.trip_id = mts.trip_id
      and   mdl.drop_off_stop_id = mts.stop_id
      and   mts.stop_location_id = p_my_fac_location_id;
   begin
     open departing_delivery_leg;
     fetch departing_delivery_leg into l_total_departing_cost;
     close departing_delivery_leg;
     fetch arriving_delivery_leg into l_total_arriving_cost;
     close arriving_delivery_leg;
     l_total_cost := l_total_departing_cost + l_total_arriving_cost;
    return l_total_cost;
  end;

-- loading/unloading weight/cube/pallets/pieces for TL/LTL/Parcels


   function get_loading_weight_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number is

      l_loading_weight number;

   BEGIN
    -- -----------------------------------------
    -- Modified for performance ( bug#3379415).
    -- -----------------------------------------
    select sum(md.gross_weight)
    into l_loading_weight
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mt.plan_id = mts.plan_id
    and   mt.trip_id = mts.trip_id
    and   mts.plan_id = mdl.plan_id
    and   mdl.pick_up_stop_id = mts.stop_id
    and   mts.stop_location_id = p_my_fac_location_id
    and   mdl.plan_id = md.plan_id
    and   mdl.delivery_id = md.delivery_id;
    IF l_loading_weight IS NULL THEN
        l_loading_weight := 0;
    END IF;
    return l_loading_weight;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

   function get_unloading_weight_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number is

      l_unloading_weight number;

   BEGIN
    -- -----------------------------------------
    -- Modified for performance ( bug#3379415).
    -- -----------------------------------------
    select sum(md.gross_weight)
    into l_unloading_weight
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mt.plan_id = mts.plan_id
    and   mt.trip_id = mts.trip_id
    and   mts.plan_id = mdl.plan_id
    and   mdl.drop_off_stop_id = mts.stop_id
    and   mts.stop_location_id = p_my_fac_location_id
    and   mdl.plan_id     = md.plan_id
    and   mdl.delivery_id = md.delivery_id;
    IF l_unloading_weight IS NULL THEN
        l_unloading_weight := 0;
    END IF;
    return l_unloading_weight;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

   function get_loading_cube_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number is

      l_loading_cube number;

   begin
    -- -----------------------------------------
    -- Modified for performance ( bug#3379415).
    -- -----------------------------------------
    select sum(md.volume)
    into l_loading_cube
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mt.plan_id = mts.plan_id
    and   mt.trip_id = mts.trip_id
    and   mts.plan_id = mdl.plan_id
    and   mdl.pick_up_stop_id = mts.stop_id
    and   mts.stop_location_id = p_my_fac_location_id
    and   mdl.plan_id = md.plan_id
    and   mdl.delivery_id = md.delivery_id;
    IF l_loading_cube IS NULL THEN
        l_loading_cube := 0;
    END IF;
    return l_loading_cube;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

   function get_unloading_cube_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number is

      l_unloading_cube number;

   begin
    -- -----------------------------------------
    -- Modified for performance ( bug#3379415).
    -- -----------------------------------------
    select sum(md.volume)
    into l_unloading_cube
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mt.plan_id = mts.plan_id
    and   mt.trip_id = mts.trip_id
    and   mts.plan_id = mdl.plan_id
    and   mdl.drop_off_stop_id = mts.stop_id
    and   mts.stop_location_id = p_my_fac_location_id
    and   mdl.plan_id = md.plan_id
    and   mdl.delivery_id = md.delivery_id;
    IF l_unloading_cube IS NULL THEN
        l_unloading_cube := 0;
    END IF;
    return l_unloading_cube;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

   function get_loading_pallet_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number is

      l_loading_pallets number;

   begin
    -- -----------------------------------------
    -- Modified for performance ( bug#3379415).
    -- -----------------------------------------
    select sum(md.number_of_pallets)
    into l_loading_pallets
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mt.plan_id = mts.plan_id
    and   mt.trip_id = mts.trip_id
    and   mdl.plan_id = mts.plan_id
    and   mdl.pick_up_stop_id = mts.stop_id
    and   mts.stop_location_id = p_my_fac_location_id
    and   mdl.plan_id = md.plan_id
    and   mdl.delivery_id = md.delivery_id;
    IF l_loading_pallets IS NULL THEN
        l_loading_pallets := 0;
    END IF;
    return l_loading_pallets;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

   function get_unloading_pallet_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number is

      l_unloading_pallets number;

   begin
    -- -----------------------------------------
    -- Modified for performance ( bug#3379415).
    -- -----------------------------------------
    select sum(md.number_of_pallets)
    into l_unloading_pallets
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mt.plan_id = mts.plan_id
    and   mt.trip_id = mts.trip_id
    and   mdl.plan_id = mts.plan_id
    and   mdl.drop_off_stop_id = mts.stop_id
    and   mts.stop_location_id = p_my_fac_location_id
    and   mdl.plan_id = md.plan_id
    and   mdl.delivery_id = md.delivery_id;
    IF l_unloading_pallets IS NULL THEN
        l_unloading_pallets := 0;
    END IF;
    return l_unloading_pallets;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

   function get_loading_piece_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number is

      l_loading_pieces number;

   begin
    -- -----------------------------------------
    -- Modified for performance ( bug#3379415).
    -- -----------------------------------------
    select sum(md.number_of_pieces)
    into l_loading_pieces
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mt.plan_id = mts.plan_id
    and   mt.trip_id = mts.trip_id
    and   mdl.plan_id = mts.plan_id
    and   mdl.pick_up_stop_id = mts.stop_id
    and   mts.stop_location_id = p_my_fac_location_id
    and   mdl.plan_id = md.plan_id
    and   mdl.delivery_id = md.delivery_id;
    IF l_loading_pieces IS NULL THEN
        l_loading_pieces := 0;
    END IF;
    return l_loading_pieces;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

   function get_unloading_piece_for_myfac  (p_plan_id in number, p_my_fac_location_id in number,
                                                  p_mode in varchar2)
      return number is

      l_unloading_pieces number;

   begin
    -- -----------------------------------------
    -- Modified for performance ( bug#3379415).
    -- -----------------------------------------
    SELECT sum(md.number_of_pieces)
    into l_unloading_pieces
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mt.plan_id = mts.plan_id
    and   mt.trip_id = mts.trip_id
    and   mdl.plan_id = mts.plan_id
    and   mdl.drop_off_stop_id = mts.stop_id
    and   mts.stop_location_id = p_my_fac_location_id
    and   mdl.plan_id = md.plan_id
    and   mdl.delivery_id = md.delivery_id;
    IF l_unloading_pieces IS NULL THEN
        l_unloading_pieces := 0;
    END IF;
    return l_unloading_pieces;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  end;

/* Carrier Details */
/* Carrier Facility Details */
/* The following functions for Carrier Details and Carrier Facility Details windows were created by Sasidhar */

  /****************************************************************
  FUNCTION get_total_trips_carrier(p_plan_id           IN NUMBER,
                                   p_carrier_id        IN NUMBER )
    RETURN VARCHAR2 IS

      -- CURSOR carr_facilities IS
      -- SELECT location_id
      -- FROM   fte_facility_carriers
      -- WHERE carrier_id = p_carrier_id;

      --CURSOR partner_trips(p_location_id IN NUMBER) IS

      --CURSOR get_carrier_facilities IS
      --SELECT wlo.wsh_location_id
      --FROM wsh_location_owners wlo
      --WHERE owner_party_id = p_carrier_id
      --AND   owner_type = 3; -- 'carrier'

      CURSOR carrier_trips IS
      SELECT t.trip_id, t.mode_of_transport
      FROM mst_trips t
      WHERE t.plan_id = p_plan_id
      AND   t.carrier_id = p_carrier_id
      ORDER BY t.mode_of_transport;

      CURSOR stop_locations(p_trip_id IN NUMBER) IS
      SELECT ts.stop_location_id
      FROM mst_trip_stops ts,
           wsh_location_owners wlo
      WHERE plan_id = p_plan_id
      AND   ts.trip_id = p_trip_id
      AND   ts.stop_location_id = wlo.wsh_location_id
      AND   owner_party_id = p_carrier_id
      AND   owner_type = CARRIER; -- 'carrier'

      CURSOR total_stops(P_TRIP IN NUMBER) IS
      SELECT COUNT(mst.stop_id)
      FROM mst_trip_stops mst
      WHERE mst.plan_id = p_plan_id
      AND   mst.trip_id = P_TRIP;

    l_stops               NUMBER;

    --l_carr_locations      NUM_LIST;

    l_Stop_locations      NUMBER;
    l_is_carrier_location BOOLEAN := FALSE;
    l_total_direct_TLs    NUMBER := 0;
    l_total_Multistop_TLs NUMBER := 0;
    l_Total_LTLs          NUMBER := 0;
    l_Total_PARCELS       NUMBER := 0;

    l_trips_str           VARCHAR2(200);
  BEGIN
    --FOR CUR_carr_facilities IN carr_facilities LOOP
        -- FOR cur_partner_trips IN partner_trips(CUR_carr_facilities.location_id) LOOP
    --OPEN get_carrier_facilities;
    --FETCH get_carrier_facilities BULK COLLECT INTO l_carr_locations;
    --CLOSE get_carrier_facilities;

    FOR cur_carrier_trips IN carrier_trips LOOP
        l_is_carrier_location := FALSE;
        OPEN stop_locations(cur_carrier_trips.TRIP_ID);
        FETCH stop_locations INTO l_Stop_locations;
        IF stop_locations%FOUND THEN
            l_is_carrier_location := TRUE;
        END IF;
        CLOSE stop_locations;
        IF l_is_carrier_location THEN
            IF cur_carrier_trips.mode_of_transport = TRUCK THEN
                OPEN total_stops(cur_carrier_trips.TRIP_ID);
                FETCH total_stops INTO l_stops;
                CLOSE total_stops;
                IF l_stops = 2 THEN
                    l_total_direct_TLs := l_total_direct_TLs + 1;
                ELSE
                    l_total_Multistop_TLs := l_total_Multistop_TLs + 1;
                END IF;
            ELSIF cur_carrier_trips.mode_of_transport = LTL THEN
                l_Total_LTLs := l_Total_LTLs + 1 ;
            ELSIF cur_carrier_trips.mode_of_transport = PARCEL THEN
                l_Total_PARCELS := l_Total_PARCELS + 1 ;
            END IF;
        END IF;
    END LOOP;
    l_trips_str := l_total_direct_TLs   ||G_delim||
                   l_total_Multistop_TLs||G_delim||
                   l_Total_LTLs         ||G_delim||
                   l_Total_PARCELS;
    RETURN l_trips_str;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
  END get_total_trips_carrier;
  -- ----------------------------------------------
  -- As per bug#3546059 and 3546163,
  -- We need to consider all the carrier trips
  -- that touch the facility owned by a specific
  -- carrier. Hence, function was re-written below.
  -- ----------------------------------------------
  *****************************************************/

  FUNCTION get_total_trips_carrier(p_plan_id    IN NUMBER,
                                   p_carrier_id IN NUMBER ) RETURN VARCHAR2 IS

      CURSOR get_carrier_facilities IS
      SELECT wlo.wsh_location_id
      FROM wsh_location_owners wlo
      WHERE owner_party_id = p_carrier_id
      AND   owner_type = CARRIER;

      CURSOR trips_to_location(p_location_id IN NUMBER) IS
      SELECT t.trip_id, t.mode_of_transport
      FROM mst_trips t,
           mst_trip_stops ts
      WHERE t.plan_id = p_plan_id
      AND   t.plan_id = ts.plan_id
      AND   t.trip_id = ts.trip_id
      AND   ts.stop_location_id = p_location_id
      ORDER BY t.mode_of_transport;

      CURSOR total_stops(P_TRIP IN NUMBER) IS
      SELECT COUNT(mst.stop_id)
      FROM mst_trip_stops mst
      WHERE mst.plan_id = p_plan_id
      AND   mst.trip_id = P_TRIP;

    l_stops               NUMBER;

    l_total_direct_TLs    NUMBER := 0;
    l_total_Multistop_TLs NUMBER := 0;
    l_Total_LTLs          NUMBER := 0;
    l_Total_PARCELS       NUMBER := 0;

    l_trips_str           VARCHAR2(200);
  BEGIN

    FOR l_carrier_facilities IN get_carrier_facilities LOOP
        FOR l_trips_to_location in trips_to_location(l_carrier_facilities.wsh_location_id) loop
            l_stops := 0;
            IF l_trips_to_location.mode_of_transport = TRUCK THEN
                OPEN total_stops(l_trips_to_location.TRIP_ID);
                FETCH total_stops INTO l_stops;
                CLOSE total_stops;
                IF l_stops = 2 THEN
                    l_total_direct_TLs := l_total_direct_TLs + 1;
                ELSE
                    l_total_Multistop_TLs := l_total_Multistop_TLs + 1;
                END IF;
            ELSIF l_trips_to_location.mode_of_transport = LTL THEN
                l_Total_LTLs := l_Total_LTLs + 1 ;
            ELSIF l_trips_to_location.mode_of_transport = PARCEL THEN
                l_Total_PARCELS := l_Total_PARCELS + 1 ;
            END IF;
        END LOOP;
    END LOOP;
    l_trips_str := l_total_direct_TLs   ||G_delim||
                   l_total_Multistop_TLs||G_delim||
                   l_Total_LTLs         ||G_delim||
                   l_Total_PARCELS;
    RETURN l_trips_str;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
  END get_total_trips_carrier;

  FUNCTION get_total_cost_carrier(p_plan_id           IN NUMBER,
                                  p_carrier_id        IN NUMBER)
    RETURN NUMBER IS

    -- ----------------------------------------------
    -- As per bug#3546059 and 3546163,
    -- We need to consider all the carrier trips
    -- that touch the facility owned by a specific
    -- carrier.
    -- ----------------------------------------------
    /*CURSOR cur_total_cost IS
    SELECT SUM(mdl.allocated_transport_cost +
                 DECODE(mts.stop_id,
                            mdl.pick_up_stop_id,
                                mdl.allocated_fac_loading_cost,
                            mdl.drop_off_stop_id,
                                mdl.allocated_fac_unloading_cost,0))
      FROM mst_delivery_legs mdl,
           mst_trip_stops mts,
           mst_trips mt
      WHERE mdl.plan_id = p_plan_id
      AND   mts.plan_id = mdl.plan_id
      AND   (   mts.stop_id = mdl.pick_up_stop_id
             OR mts.stop_id = mdl.drop_off_stop_id)
      AND   mt.plan_id = mts.plan_Id
      AND   mt.trip_id = mts.trip_id
      AND   mt.carrier_id = p_carrier_id
      AND   EXISTS (SELECT 1
                    FROM wsh_location_owners wlo
                    WHERE wlo.owner_party_id = mt.carrier_id
                    AND   wlo.wsh_location_id = mts.stop_location_id
                    AND   wlo.owner_type = CARRIER);*/

    CURSOR cur_total_cost IS
    SELECT SUM(mdl.allocated_transport_cost +
                 DECODE(mts.stop_id,
                            mdl.pick_up_stop_id,
                                mdl.allocated_fac_loading_cost,
                            mdl.drop_off_stop_id,
                                mdl.allocated_fac_unloading_cost,0) +
                 DECODE(mts.stop_id,
                            mdl.pick_up_stop_id,
                                mdl.allocated_fac_shp_hand_cost,
                            mdl.drop_off_stop_id,
                                mdl.allocated_fac_Rec_hand_cost,0) )
      FROM mst_delivery_legs mdl,
           mst_trip_stops mts,
           mst_trips mt
      WHERE mdl.plan_id = p_plan_id
      AND   mt.plan_id = mdl.plan_id
      AND   mt.trip_id = mdl.trip_id
      AND   mt.plan_id = mts.plan_Id
      AND   mt.trip_id = mts.trip_id
      AND   EXISTS (SELECT 1
                    FROM wsh_location_owners wlo
                    WHERE wlo.owner_party_id = p_carrier_id
                    AND   wlo.wsh_location_id = mts.stop_location_id
                    AND   wlo.owner_type = CARRIER);
    l_total_cost NUMBER;

  BEGIN
    OPEN cur_total_cost;
    FETCH cur_total_cost INTO l_total_cost;
    CLOSE cur_total_cost;
    l_total_cost := NVL(l_total_cost,0);
    RETURN l_total_cost;

  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  END get_total_cost_carrier;

  FUNCTION get_total_weight_carr_facility(p_plan_id       IN NUMBER,
                                          p_carrier_id    IN NUMBER,
                                          p_location_id   IN NUMBER,
                                          p_location_type IN VARCHAR2,
                                          p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER IS

      l_total_weight NUMBER := 0;
      l_total_weight_tmp NUMBER := 0;
  BEGIN
    -- ---------------------------------------------------
    -- As per bug#3546059 and 3546163, we need to consider
    -- all trips touching the specific carrier facility.
    -- ---------------------------------------------------

    IF p_location_type = 'U' THEN
        -- ---------------------------------------------
        -- Need to show weight in transit by all trips
        -- (Unload) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------

        SELECT SUM(md.gross_weight)
        INTO   l_total_weight
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id );
                         --AND   mt.carrier_id = p_carrier_id);

    ELSIF p_LOCATION_type = 'L' THEN
        -- ---------------------------------------------
        -- Need to show weight in transit by all trips
        -- (load) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        SELECT SUM(md.gross_weight)
        INTO l_total_weight
        FROM mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);
                         --AND   mt.carrier_id = p_carrier_id);
    ELSIF p_mode_of_transport IS NOT NULL THEN
        -- ---------------------------------------------
        -- Need to show weight in transit by all trips
        -- (load/Unload) by a given mode of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        -- -------------------------------------
        -- 28-jUN-04 - Per bug#3713507,
        -- we need to double count KPIs
        --   - weight/Cube/pallets/Pieces/Orders
        -- for unload and load.
        -- -------------------------------------
        /*
        SELECT SUM(md.gross_weight)
        INTO   l_total_weight
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   (   mts.stop_id = mdl.pick_up_stop_id
                                OR mts.stop_id = mdl.drop_off_stop_id)
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         --AND   mt.carrier_id = p_carrier_id
                         AND   mt.mode_of_transport = p_mode_of_transport);
                        */
        SELECT SUM(md.gross_weight)
        INTO   l_total_weight
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.mode_of_transport = p_mode_of_transport);

        l_total_weight_tmp := NVL(l_total_weight,0);
        l_total_weight := 0;

        SELECT SUM(md.gross_weight)
        INTO   l_total_weight
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.mode_of_transport = p_mode_of_transport);

        l_total_weight := l_total_weight_tmp + NVL(l_total_weight,0);
    ELSIF p_mode_of_transport IS NULL THEN
        -- ---------------------------------------------
        -- Need to show weight in transit by all trips
        -- (load/Unload) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        -- ------------------------------------------------------------------
        -- Also, as per bug#3546059 and 3546163, we need to double count KPIs
        -- - weight/Cube/pallets/Pieces/Orders for unload and load.
        -- ------------------------------------------------------------------
        /*************************
        SELECT SUM(md.gross_weight)
        INTO   l_total_weight
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   (   mts.stop_id = mdl.pick_up_stop_id
                                OR mts.stop_id = mdl.drop_off_stop_id)
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.carrier_id = p_carrier_id);
        ***************************/
        SELECT SUM(md.gross_weight)
        INTO   l_total_weight
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);

        l_total_weight_tmp := NVL(l_total_weight,0);
        l_total_weight := 0;

        SELECT SUM(md.gross_weight)
        INTO   l_total_weight
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);

        l_total_weight := l_total_weight_tmp + NVL(l_total_weight,0);
    END IF;

    l_total_weight := NVL(l_total_weight,0);

    RETURN l_total_weight;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  END get_total_weight_carr_facility;

  FUNCTION get_total_Cube_carr_facility(p_plan_id       IN NUMBER,
                                        p_carrier_id    IN NUMBER,
                                        p_location_id   IN NUMBER,
                                        p_location_type IN VARCHAR2,
                                        p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER IS

      l_total_volume NUMBER :=0;
      l_total_volume_tmp NUMBER :=0;
  BEGIN

    -- ---------------------------------------------------
    -- As per bug#3546059 and 3546163, we need to consider
    -- all trips touching the specific carrier facility.
    -- ---------------------------------------------------
    IF p_location_type = 'U' THEN
        -- ---------------------------------------------
        -- Need to show volume in transit by all trips
        -- (Unload) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        SELECT SUM(md.volume)
        INTO   l_total_volume
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);
                         --AND   mt.carrier_id = p_carrier_id);

    ELSIF p_LOCATION_type = 'L' THEN
        -- ---------------------------------------------
        -- Need to show volume in transit by all trips
        -- (load) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        SELECT SUM(md.volume)
        INTO l_total_volume
        FROM mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);
                         --AND   mt.carrier_id = p_carrier_id);
    ELSIF p_mode_of_transport IS NOT NULL THEN
        -- ---------------------------------------------
        -- Need to show volume in transit by all trips
        -- (load/Unload) by a given mode of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        -- -------------------------------------
        -- 28-jUN-04 - Per bug#3713507,
        -- we need to double count KPIs
        --   - weight/Cube/pallets/Pieces/Orders
        -- for unload and load.
        -- -------------------------------------
        /*
        SELECT SUM(md.volume)
        INTO   l_total_volume
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   (mts.stop_id = mdl.pick_up_stop_id
                               OR mts.stop_id = mdl.drop_off_stop_id)
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         --AND   mt.carrier_id = p_carrier_id
                         AND   mt.mode_of_transport = p_mode_of_transport);
                        */
        SELECT SUM(md.volume)
        INTO   l_total_volume
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.mode_of_transport = p_mode_of_transport);

        l_total_volume_tmp := NVL(l_total_volume,0);
        l_total_volume := 0;

        SELECT SUM(md.volume)
        INTO   l_total_volume
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.mode_of_transport = p_mode_of_transport);

        l_total_volume := l_total_volume_tmp + NVL(l_total_volume,0);
    ELSIF p_mode_of_transport IS NULL THEN
        -- ---------------------------------------------
        -- Need to show volume in transit by all trips
        -- (load/Unload) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        -- ------------------------------------------------------------------
        -- Also, as per bug#3546059 and 3546163, we need to double count KPIs
        -- - weight/Cube/pallets/Pieces/Orders for unload and load.
        -- ------------------------------------------------------------------
        /*************************
        SELECT SUM(md.volume)
        INTO   l_total_volume
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   (mts.stop_id = mdl.pick_up_stop_id
                               OR mts.stop_id = mdl.drop_off_stop_id)
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.carrier_id = p_carrier_id);
        *****************************/
        SELECT SUM(md.volume)
        INTO   l_total_volume
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);

        l_total_volume_tmp := NVL(l_total_volume,0);
        l_total_volume := 0;

        SELECT SUM(md.volume)
        INTO   l_total_volume
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id );
       l_total_volume := l_total_volume_tmp + NVL(l_total_volume,0);
    END IF;
    l_total_volume := NVL(l_total_volume, 0);
    RETURN l_total_volume;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  END get_total_cube_carr_facility;

  FUNCTION get_tot_Pal_carr_facility(p_plan_id       IN NUMBER,
                                     p_carrier_id    IN NUMBER,
                                     p_location_id   IN NUMBER,
                                     p_location_type IN VARCHAR2,
                                     p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER IS

      l_total_Pallets NUMBER := 0;
      l_total_Pallets_tmp NUMBER := 0;

  BEGIN

    -- ---------------------------------------------------
    -- As per bug#3546059 and 3546163, we need to consider
    -- all trips touching the specific carrier facility.
    -- ---------------------------------------------------
    IF p_location_type = 'U' THEN
        -- ---------------------------------------------
        -- Need to show pallets in transit by all trips
        -- (Unload) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        SELECT SUM(md.number_of_pallets)
        INTO   l_total_Pallets
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id );
                         --AND   mt.carrier_id = p_carrier_id);

    ELSIF p_LOCATION_type = 'L' THEN
        -- ---------------------------------------------
        -- Need to show pallets in transit by all trips
        -- (load) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        SELECT SUM(md.number_of_pallets)
        INTO l_total_Pallets
        FROM mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);
                         --AND   mt.carrier_id = p_carrier_id);
    ELSIF p_mode_of_transport IS NOT NULL THEN
        -- ---------------------------------------------
        -- Need to show pallets in transit by all trips
        -- (load/Unload) by a given mode of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        -- -------------------------------------
        -- 28-jUN-04 - Per bug#3713507,
        -- we need to double count KPIs
        --   - weight/Cube/pallets/Pieces/Orders
        -- for unload and load.
        -- -------------------------------------
        /*
        SELECT SUM(md.number_of_pallets)
        INTO   l_total_Pallets
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   (   mts.stop_id = mdl.pick_up_stop_id
                               OR  mts.stop_id = mdl.drop_off_stop_id)
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.carrier_id = p_carrier_id);
                         --AND   mt.mode_of_transport = p_mode_of_transport);
                        */
        SELECT SUM(md.number_of_pallets)
        INTO   l_total_Pallets
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.carrier_id = p_carrier_id);

        l_total_Pallets_tmp := NVL(l_total_Pallets,0);
        l_total_Pallets := 0;

        SELECT SUM(md.number_of_pallets)
        INTO   l_total_Pallets
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.carrier_id = p_carrier_id);

        l_total_Pallets := l_total_Pallets_tmp + NVL(l_total_Pallets,0);
    ELSIF p_mode_of_transport IS NULL THEN
        -- ---------------------------------------------
        -- Need to show pallets in transit by all trips
        -- (load/Unload) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        -- ------------------------------------------------------------------
        -- Also, as per bug#3546059 and 3546163, we need to double count KPIs
        -- - weight/Cube/pallets/Pieces/Orders for unload and load.
        -- ------------------------------------------------------------------
        /*************************
        SELECT SUM(md.number_of_pallets)
        INTO   l_total_Pallets
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   (   mts.stop_id = mdl.pick_up_stop_id
                               OR  mts.stop_id = mdl.drop_off_stop_id)
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.carrier_id = p_carrier_id);
        ************************/
        SELECT SUM(md.number_of_pallets)
        INTO   l_total_Pallets
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);

        l_total_Pallets_tmp := NVL(l_total_Pallets,0);
        l_total_Pallets := 0;

        SELECT SUM(md.number_of_pallets)
        INTO   l_total_Pallets
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);
       l_total_Pallets := l_total_Pallets_tmp + NVL(l_total_Pallets,0);
    END IF;
    l_total_Pallets := NVL(l_total_Pallets,0);
    RETURN l_total_Pallets;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  END get_tot_Pal_carr_facility;

  FUNCTION get_tot_Pieces_carr_facility(p_plan_id       IN NUMBER,
                                        p_carrier_id    IN NUMBER,
                                        p_location_id   IN NUMBER,
                                        p_location_type IN VARCHAR2,
                                        p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER IS

      l_total_Pieces NUMBER := 0;
      l_total_Pieces_tmp NUMBER := 0;

  BEGIN

    -- ---------------------------------------------------
    -- As per bug#3546059 and 3546163, we need to consider
    -- all trips touching the specific carrier facility.
    -- ---------------------------------------------------
    IF p_location_type = 'U' THEN
        -- ---------------------------------------------
        -- Need to show pieces in transit by all trips
        -- (Unload) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        SELECT SUM(md.number_of_pieces)
        INTO   l_total_Pieces
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);
                         --AND   mt.carrier_id = p_carrier_id);

    ELSIF p_LOCATION_type = 'L' THEN
        -- ---------------------------------------------
        -- Need to show pieces in transit by all trips
        -- (load) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        SELECT SUM(md.number_of_pieces)
        INTO l_total_Pieces
        FROM mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);
                         --AND   mt.carrier_id = p_carrier_id);
    ELSIF p_mode_of_transport IS NOT NULL THEN
        -- ---------------------------------------------
        -- Need to show pallets in transit by all trips
        -- (load/Unload) by a given mode of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        -- -------------------------------------
        -- 28-jUN-04 - Per bug#3713507,
        -- we need to double count KPIs
        --   - weight/Cube/pallets/Pieces/Orders
        -- for unload and load.
        -- -------------------------------------
        /*
        SELECT SUM(md.number_of_pieces)
        INTO   l_total_Pieces
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   (  mts.stop_id = mdl.pick_up_stop_id
                               OR mts.stop_id = mdl.drop_off_stop_id)
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         --AND   mt.carrier_id = p_carrier_id
                         AND   mt.mode_of_transport = p_mode_of_transport);
                        */
        SELECT SUM(md.number_of_pieces)
        INTO   l_total_Pieces
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.mode_of_transport = p_mode_of_transport);

        l_total_Pieces_tmp := NVL(l_total_Pieces,0);
        l_total_Pieces := 0;

        SELECT SUM(md.number_of_pieces)
        INTO   l_total_Pieces
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.mode_of_transport = p_mode_of_transport);

        l_total_Pieces := l_total_Pieces_tmp + NVL(l_total_Pieces,0);
    ELSIF p_mode_of_transport IS NULL THEN
        -- ---------------------------------------------
        -- Need to show pallets in transit by all trips
        -- (load/Unload) by all modes of transport
        -- for a specified carrier facility.
        -- ---------------------------------------------
        -- ------------------------------------------------------------------
        -- Also, as per bug#3546059 and 3546163, we need to double count KPIs
        -- - weight/Cube/pallets/Pieces/Orders for unload and load.
        -- ------------------------------------------------------------------
        /*************************
        SELECT SUM(md.number_of_pieces)
        INTO   l_total_Pieces
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   (  mts.stop_id = mdl.pick_up_stop_id
                               OR mts.stop_id = mdl.drop_off_stop_id)
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id
                         AND   mt.carrier_id = p_carrier_id);
        *************************/
        SELECT SUM(md.number_of_pieces)
        INTO   l_total_Pieces
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);

        l_total_Pieces_tmp := NVL(l_total_Pieces,0);
        l_total_Pieces := 0;

        SELECT SUM(md.number_of_pieces)
        INTO   l_total_Pieces
        FROM   mst_deliveries md
        WHERE md.plan_id = p_plan_id
        AND   md.delivery_id IN
                        (SELECT mdl.delivery_id
                         FROM   mst_delivery_legs mdl,
                                mst_trips mt,
                                mst_trip_stops mts
                         WHERE mdl.plan_id = md.plan_id
                         AND   mts.plan_Id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id
                         AND   mdl.plan_id = mt.plan_id
                         AND   mdl.trip_id = mt.trip_id);
        l_total_Pieces := l_total_Pieces_tmp + NVL(l_total_Pieces,0);
    END IF;
    l_total_Pieces := NVL(l_total_Pieces, 0);
    RETURN l_total_Pieces;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  END get_tot_Pieces_carr_facility;

-- the implementation logic has been changed to aggregate on TP orders instead of raw orders
  FUNCTION get_tot_Orders_carr_facility(p_plan_id       IN NUMBER,
                                        p_carrier_id    IN NUMBER,
                                        p_fac_location_id   IN NUMBER,
                                        p_activity_type IN VARCHAR2,
                                        p_mode IN VARCHAR2
                                        )
      RETURN NUMBER IS

      l_total_orders NUMBER := 0;
      l_total_orders_tmp NUMBER := 0;
  BEGIN

    if p_mode is not null THEN
     -- ---------------------------------------------------
     -- As per bug#3546059 and 3546163, we need to consider
     -- all trips touching the specific carrier facility.
     -- ---------------------------------------------------
     -- ------------------------------------------ -
     -- As per bug#3244044, we need to consider    -
     -- Distinct orders instead of raw orders.     -
     -- ------------------------------------------ -
        -- -------------------------------------
        -- 28-jUN-04 - Per bug#3713507,
        -- we need to double count KPIs
        --   - weight/Cube/pallets/Pieces/Orders
        -- for unload and load.
        -- -------------------------------------
        /*
      SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      FROM MST_DELIVERY_DETAILS MDD,
           MST_DELIVERIES MD,
           MST_DELIVERY_ASSIGNMENTS MDA
      WHERE MD.PLAN_ID     = MDA.PLAN_ID
      AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
      AND   MD.DELIVERY_ID IN
                (SELECT MDL.DELIVERY_ID
                 FROM MST_TRIPS T,
                      MST_TRIP_STOPS TS,
                      MST_DELIVERY_LEGS MDL
                 WHERE MDL.PLAN_ID = MD.PLAN_ID
                 AND   TS.PLAN_ID  = MDL.PLAN_ID
                 AND  (   TS.STOP_ID  = MDL.PICK_UP_STOP_ID
                       OR TS.STOP_ID  = MDL.DROP_OFF_STOP_ID )
                 AND   TS.STOP_LOCATION_ID = P_FAC_LOCATION_ID
                 AND   TS.PLAN_ID  = T.PLAN_ID
                 AND   TS.TRIP_ID  = T.TRIP_ID
                 --AND   T.CARRIER_ID = P_CARRIER_ID
                 AND   T.MODE_OF_TRANSPORT = P_MODE)
      AND   MDA.PLAN_ID = MDD.PLAN_ID
      AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
      AND   MD.PLAN_ID = P_PLAN_ID;
    */
        SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
        INTO l_total_orders
        FROM MST_DELIVERY_DETAILS MDD,
             MST_DELIVERIES MD,
             MST_DELIVERY_ASSIGNMENTS MDA
        WHERE MD.PLAN_ID     = MDA.PLAN_ID
        AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
        AND   MD.DELIVERY_ID IN
                (SELECT MDL.DELIVERY_ID
                 FROM MST_TRIPS T,
                      MST_TRIP_STOPS TS,
                      MST_DELIVERY_LEGS MDL
                 WHERE MDL.PLAN_ID = MD.PLAN_ID
                 AND   TS.PLAN_ID  = MDL.PLAN_ID
                 AND   TS.STOP_ID  = MDL.PICK_UP_STOP_ID
                 AND   TS.STOP_LOCATION_ID = P_FAC_LOCATION_ID
                 AND   TS.PLAN_ID  = T.PLAN_ID
                 AND   TS.TRIP_ID  = T.TRIP_ID
                 AND   T.MODE_OF_TRANSPORT = P_MODE)
        AND   MDA.PLAN_ID = MDD.PLAN_ID
        AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
        AND   MD.PLAN_ID = P_PLAN_ID;

        l_total_orders_tmp := NVL(l_total_orders,0);
        l_total_orders := 0;

        SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
        INTO l_total_orders
        FROM MST_DELIVERY_DETAILS MDD,
             MST_DELIVERIES MD,
             MST_DELIVERY_ASSIGNMENTS MDA
        WHERE MD.PLAN_ID     = MDA.PLAN_ID
        AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
        AND   MD.DELIVERY_ID IN
                (SELECT MDL.DELIVERY_ID
                 FROM MST_TRIPS T,
                      MST_TRIP_STOPS TS,
                      MST_DELIVERY_LEGS MDL
                 WHERE MDL.PLAN_ID = MD.PLAN_ID
                 AND   TS.PLAN_ID  = MDL.PLAN_ID
                 AND   TS.STOP_ID  = MDL.DROP_OFF_STOP_ID
                 AND   TS.STOP_LOCATION_ID = P_FAC_LOCATION_ID
                 AND   TS.PLAN_ID  = T.PLAN_ID
                 AND   TS.TRIP_ID  = T.TRIP_ID
                 AND   T.MODE_OF_TRANSPORT = P_MODE)
        AND   MDA.PLAN_ID = MDD.PLAN_ID
        AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
        AND   MD.PLAN_ID = P_PLAN_ID;

        l_total_orders := l_total_orders_tmp + NVL(l_total_orders,0);
    ELSIF p_activity_type IS NULL AND p_mode IS NULL THEN
        -- ------------------------------------------------------------------
        -- Also, as per bug#3546059 and 3546163, we need to double count KPIs
        -- - weight/Cube/pallets/Pieces/Orders for unload and load.
        -- ------------------------------------------------------------------
        -- ------------------------------------------ -
        -- As per bug#3244044, we need to consider    -
        -- Distinct orders instead of raw orders.     -
        -- ------------------------------------------ -
      /*******
      SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      FROM MST_DELIVERY_DETAILS MDD,
           MST_DELIVERIES MD,
           MST_DELIVERY_ASSIGNMENTS MDA
      WHERE MD.PLAN_ID     = MDA.PLAN_ID
      AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
      AND   MD.DELIVERY_ID IN
                (SELECT MDL.DELIVERY_ID
                 FROM MST_TRIPS T,
                      MST_TRIP_STOPS TS,
                      MST_DELIVERY_LEGS MDL
                 WHERE MDL.PLAN_ID = MD.PLAN_ID
                 AND   TS.PLAN_ID  = MDL.PLAN_ID
                 AND  (   TS.STOP_ID  = MDL.PICK_UP_STOP_ID
                       OR TS.STOP_ID  = MDL.DROP_OFF_STOP_ID )
                 AND   TS.STOP_LOCATION_ID = P_FAC_LOCATION_ID
                 AND   TS.PLAN_ID  = T.PLAN_ID
                 AND   TS.TRIP_ID  = T.TRIP_ID
                 AND   T.CARRIER_ID = P_CARRIER_ID)
      AND   MDA.PLAN_ID = MDD.PLAN_ID
      AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
      AND   MD.PLAN_ID = P_PLAN_ID;
      ***********/
      SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      FROM mst_delivery_details mdd,
           mst_deliveries md,
           mst_delivery_assignments mda
      WHERE md.plan_id = p_plan_id
      AND   md.plan_id     = mda.plan_id
      AND   md.delivery_id = mda.delivery_id
      AND   mda.plan_id = mdd.plan_id
      AND   mda.delivery_detail_id = mdd.delivery_detail_id
      AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.pick_up_stop_id = mts.stop_id
              AND   mts.stop_location_id = p_fac_location_id);

      l_total_orders_tmp := NVL(l_total_orders,0);
      l_total_orders := 0;

      SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      FROM mst_delivery_details mdd,
           mst_deliveries md,
           mst_delivery_assignments mda
      WHERE md.plan_id = p_plan_id
      AND   md.plan_id     = mda.plan_id
      AND   md.delivery_id = mda.delivery_id
      AND   mda.plan_id = mdd.plan_id
      AND   mda.delivery_detail_id = mdd.delivery_detail_id
      AND   md.delivery_id IN
            ( SELECT mdl.delivery_id
              FROM mst_delivery_legs mdl,
                   mst_trip_stops mts
              WHERE mdl.plan_id = md.plan_id
              AND   mdl.plan_id = mts.plan_id
              AND   mdl.drop_off_stop_id = mts.stop_id
              AND   mts.stop_location_id = p_fac_location_id);

      l_total_orders := l_total_orders_tmp + NVL(l_total_orders,0);
    elsif p_activity_type = 'L' THEN
     -- ------------------------------------------ -
     -- As per bug#3244044, we need to consider    -
     -- Distinct orders instead of raw orders.     -
     -- ------------------------------------------ -
      SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      FROM MST_DELIVERY_DETAILS MDD,
           MST_DELIVERIES MD,
           MST_DELIVERY_ASSIGNMENTS MDA
      WHERE MD.PLAN_ID     = MDA.PLAN_ID
      AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
      AND   MD.DELIVERY_ID IN
                (SELECT MDL.DELIVERY_ID
                 --FROM MST_TRIPS T,
                 FROM MST_TRIP_STOPS TS,
                      MST_DELIVERY_LEGS MDL
                 WHERE MDL.PLAN_ID = MD.PLAN_ID
                 AND   TS.PLAN_ID  = MDL.PLAN_ID
                 AND   TS.STOP_ID  = MDL.PICK_UP_STOP_ID
                 AND   TS.STOP_LOCATION_ID = P_FAC_LOCATION_ID)
                 --AND   TS.PLAN_ID  = T.PLAN_ID
                 --AND   TS.TRIP_ID  = T.TRIP_ID
                 --AND   T.CARRIER_ID = P_CARRIER_ID)
      AND   MDA.PLAN_ID = MDD.PLAN_ID
      AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
      AND   MD.PLAN_ID = P_PLAN_ID;
    elsif p_activity_type = 'U' THEN
     -- ------------------------------------------ -
     -- As per bug#3244044, we need to consider    -
     -- Distinct orders instead of raw orders.     -
     -- ------------------------------------------ -
      SELECT COUNT(DISTINCT mdd.SOURCE_HEADER_NUMBER)
      INTO l_total_orders
      FROM MST_DELIVERY_DETAILS MDD,
           MST_DELIVERIES MD,
           MST_DELIVERY_ASSIGNMENTS MDA
      WHERE MD.PLAN_ID     = MDA.PLAN_ID
      AND   MD.DELIVERY_ID = MDA.DELIVERY_ID
      AND   MD.DELIVERY_ID IN
                (SELECT MDL.DELIVERY_ID
                 --FROM MST_TRIPS T,
                 FROM MST_TRIP_STOPS TS,
                      MST_DELIVERY_LEGS MDL
                 WHERE MDL.PLAN_ID = MD.PLAN_ID
                 AND   TS.PLAN_ID  = MDL.PLAN_ID
                 AND   TS.STOP_ID  = MDL.DROP_OFF_STOP_ID
                 AND   TS.STOP_LOCATION_ID = P_FAC_LOCATION_ID)
                 --AND   TS.PLAN_ID  = T.PLAN_ID
                 --AND   TS.TRIP_ID  = T.TRIP_ID
                 --AND   T.CARRIER_ID = P_CARRIER_ID)
      AND   MDA.PLAN_ID = MDD.PLAN_ID
      AND   MDA.DELIVERY_DETAIL_ID = MDD.DELIVERY_DETAIL_ID
      AND   MD.PLAN_ID = P_PLAN_ID;
    end if;
    l_total_orders := NVL(l_total_orders,0);
      RETURN l_total_orders;
   EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;

  END get_tot_Orders_carr_facility;

  FUNCTION get_tot_trips_carr_Facility(p_plan_id     IN NUMBER,
                                       p_carrier_id  IN NUMBER,
                                       P_LOCATION_ID IN NUMBER,
                                       p_location_type IN VARCHAR2,
                                       p_mode_of_transport IN VARCHAR2)
    RETURN NUMBER IS
    l_total_trips NUMBER;
    l_total_trips_tmp NUMBER;
  BEGIN
     -- ---------------------------------------------------
     -- As per bug#3546059 and 3546163, we need to consider
     -- all trips touching the specific carrier facility.
     -- ---------------------------------------------------
    IF p_location_type = 'U' THEN
        -- ---------------------------------------------
        -- Need to show all trips (Unload) and
        -- by a given mode of transport by the specified
        -- carrier facility.
        -- ---------------------------------------------
        SELECT COUNT(mt.trip_id)
        INTO l_total_trips
        FROM   mst_trips mt
        WHERE mt.plan_id = p_plan_id
        AND   mt.trip_id IN
                    (SELECT mdl.trip_id
                     FROM   mst_delivery_legs mdl,
                            mst_trip_stops mts
                         WHERE mdl.plan_id     = mt.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = P_location_id)
        --AND   mt.carrier_id  = p_carrier_id
        AND   mt.mode_of_transport = p_mode_of_transport;
    ELSIF p_location_type = 'L' THEN
        -- ---------------------------------------------
        -- Need to show all trips (load) and
        -- by a given mode of transport by the specified
        -- carrier facility.
        -- ---------------------------------------------
        SELECT COUNT(mt.trip_id)
        INTO l_total_trips
        FROM   mst_trips mt
        WHERE mt.plan_id = p_plan_id
        AND   mt.trip_id IN
                    (SELECT mdl.trip_id
                     FROM   mst_deliveries md,
                            mst_delivery_legs mdl,
                            mst_trip_stops mts
                         WHERE mdl.plan_id     = mt.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = p_location_Id)
        --AND   mt.carrier_id  = p_carrier_id
        AND   mt.mode_of_transport = p_mode_of_transport;
    ELSIF p_mode_of_transport IS NOT NULL THEN
        -- ------------------------------------------
        -- Need to show all trips (Load/Unload) by a
        -- given mode of transport, by the specified
        -- carrier facility.
        -- ------------------------------------------
        SELECT COUNT(mt.trip_id)
        INTO l_total_trips
        FROM   mst_trips mt
        WHERE mt.plan_id = p_plan_id
        AND   mt.trip_id IN
                    (SELECT mdl.trip_id
                     FROM   mst_delivery_legs mdl,
                            mst_trip_stops mts
                         WHERE mdl.plan_id     = mt.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   (   mts.stop_id = mdl.pick_up_stop_id
                                OR mts.stop_id = mdl.drop_off_stop_id)
                         AND   mts.stop_location_id = P_location_id)
        --AND   mt.carrier_id  = p_carrier_id
        AND   mt.mode_of_transport = p_mode_of_transport;
    ELSIF p_mode_of_transport IS NULL THEN
        -- ------------------------------------------
        -- Need to show all trips (Load/Unload) and
        -- by all modes of transport by the specified
        -- carrier facility.
        -- ------------------------------------------
        -- ------------------------------------------------------------------
        -- Also, as per bug#3546059 and 3546163, we need to double count KPIs
        -- - weight/Cube/pallets/Pieces/Orders for unload and load.
        -- ------------------------------------------------------------------
        /***********************
        SELECT COUNT(mt.trip_id)
        INTO l_total_trips
        FROM   mst_trips mt
        WHERE mt.plan_id = p_plan_id
        AND   mt.trip_id IN
                    (SELECT mdl.trip_id
                     FROM   mst_delivery_legs mdl,
                            mst_trip_stops mts
                         WHERE mdl.plan_id     = mt.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   (   mts.stop_id = mdl.pick_up_stop_id
                                OR mts.stop_id = mdl.drop_off_stop_id)
                         AND   mts.stop_location_id = P_location_id)
        AND   mt.carrier_id  = p_carrier_id;
        *************************/
        SELECT COUNT(mt.trip_id)
        INTO l_total_trips
        FROM   mst_trips mt
        WHERE mt.plan_id = p_plan_id
        AND   mt.trip_id IN
                    (SELECT mdl.trip_id
                     FROM   mst_delivery_legs mdl,
                            mst_trip_stops mts
                         WHERE mdl.plan_id     = mt.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_id
                         AND   mts.stop_location_id = P_location_id);

        l_total_trips_tmp := NVL(l_total_trips,0);
        l_total_trips := 0;

        SELECT COUNT(mt.trip_id)
        INTO l_total_trips
        FROM   mst_trips mt
        WHERE mt.plan_id = p_plan_id
        AND   mt.trip_id IN
                    (SELECT mdl.trip_id
                     FROM   mst_delivery_legs mdl,
                            mst_trip_stops mts
                         WHERE mdl.plan_id     = mt.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = P_location_id);

        l_total_trips := l_total_trips_tmp + NVL(l_total_trips,0);
    END IF;
    RETURN l_total_trips;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  END get_tot_trips_carr_Facility;

  FUNCTION get_direct_tls_carr_facility
                                      (p_plan_id        IN NUMBER,
                                       p_carrier_id     IN NUMBER,
                                       p_location_id    IN NUMBER,
                                       p_Location_type  IN VARCHAR2,
                                       p_mode_of_transport IN VARCHAR2)
      RETURN NUMBER IS

      l_total_trips NUMBER;

   BEGIN
        -- Used in Carrier Facility Details UI
        -- ---------------------------------------------------
        -- As per bug#3546059 and 3546163, we need to consider
        -- all trips touching the specific carrier facility.
        -- ---------------------------------------------------
        IF p_mode_of_transport =DTL THEN -- Direct TLs
                -- ---------------------------------------------------- --
                -- For a given carrier facility and mode of transport,  --
                -- consider those delivery legs involved in that trip.  --
                -- Verify for pickup(LOAD)/drop off(UNLOAD) locations   --
                -- of these dilivery legs to be carrier facility. Also, --
                -- verify if these deliveries been assigned to one or   --
                -- more delivery legs. Check number of stops in each    --
                -- trip to be 2 ( Direct )Get count of such trips.      --
                -- ---------------------------------------------------- --
                IF p_Location_type = 'L' THEN

                    SELECT COUNT(mt.trip_id)
                    INTO   l_total_trips
                    FROM mst_trips mt
                    WHERE mt.plan_id = p_plan_id
                    AND   mt.trip_id IN
                        (SELECT mdl.trip_id
                         FROM mst_delivery_legs mdl,
                              mst_trip_stops mts
                         WHERE mdl.plan_id = mt.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_Id
                         AND   mts.stop_location_id = p_location_id)
                    AND   mt.mode_of_transport = TRUCK -- p_mode_of_transport
                    --AND   mt.carrier_id = p_carrier_id
                    AND   EXISTS (SELECT mts1.trip_id
                                  FROM mst_trip_stops mts1
                                  WHERE mts1.plan_id = mt.plan_id
                                  AND   mts1.trip_Id = mt.trip_ID
                                  HAVING COUNT(mts1.stop_id) =2
                                  GROUP BY mts1.trip_id);
                ELSIF p_Location_type = 'U' THEN

                    SELECT COUNT(mt.trip_id)
                    INTO   l_total_trips
                    FROM mst_trips mt
                    WHERE mt.plan_id = p_plan_id
                    AND   mt.trip_id IN
                        (SELECT mdl.trip_id
                         FROM mst_delivery_legs mdl,
                              mst_trip_stops mts
                         WHERE mdl.plan_id = mt.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_id
                         AND   mts.stop_location_id = p_location_id)
                    AND   mt.mode_of_transport = TRUCK -- p_mode_of_transport
                    --AND   mt.carrier_id = p_carrier_id
                    AND   EXISTS (SELECT mts1.trip_id
                                  FROM mst_trip_stops mts1
                                  WHERE mts1.plan_id = mt.plan_id
                                  AND   mts1.trip_Id = mt.trip_ID
                                  HAVING COUNT(mts1.stop_id) =2
                                  GROUP BY mts1.trip_id);

                END IF;
        ELSE -- Multi-stop TLs
                -- ---------------------------------------------------- --
                -- For a given carrier facility and mode of transport,  --
                -- consider those delivery legs involved in that trip.  --
                -- Verify for pickup(LOAD)/drop off(UNLOAD) locations   --
                -- of these dilivery legs to be carrier facility. Also, --
                -- verify if these deliveries been assigned to one or   --
                -- more delivery legs. Check number of stops in each    --
                -- trip to be > 2 (Multi stop)Get count of such trips.  --
                -- ---------------------------------------------------- --
                IF p_Location_type = 'L' THEN
                    SELECT COUNT(mt.trip_id)
                    INTO   l_total_trips
                    FROM mst_trips mt
                    WHERE mt.plan_id = p_plan_id
                    AND   mt.trip_id IN
                        (SELECT mdl.trip_id
                         FROM mst_delivery_legs mdl,
                              mst_trip_stops mts
                         WHERE mdl.plan_id = mt.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.pick_up_stop_Id
                         AND   mts.stop_location_id = p_location_id)
                    AND   mt.mode_of_transport = TRUCK -- p_mode_of_transport
                    --AND   mt.carrier_id = p_carrier_id
                    AND   EXISTS (SELECT mts1.trip_id
                                  FROM mst_trip_stops mts1
                                  WHERE mts1.plan_id = mt.plan_id
                                  AND   mts1.trip_Id = mt.trip_ID
                                  HAVING COUNT(mts1.stop_id) > 2
                                  GROUP BY mts1.trip_id);
                ELSIF p_Location_type = 'U' THEN

                    SELECT COUNT(mt.trip_id)
                    INTO   l_total_trips
                    FROM mst_trips mt
                    WHERE mt.plan_id = p_plan_id
                    AND   mt.trip_id IN
                        (SELECT mdl.trip_id
                         FROM mst_delivery_legs mdl,
                              mst_trip_stops mts
                         WHERE mdl.plan_id = mt.plan_id
                         AND   mts.plan_id = mdl.plan_id
                         AND   mts.stop_id = mdl.drop_off_stop_Id
                         AND   mts.stop_location_id = p_location_id)
                    AND   mt.mode_of_transport = TRUCK -- p_mode_of_transport
                    --AND   mt.carrier_id = p_carrier_id
                    AND   EXISTS (SELECT mts1.trip_id
                                  FROM mst_trip_stops mts1
                                  WHERE mts1.plan_id = mt.plan_id
                                  AND   mts1.trip_Id = mt.trip_ID
                                  HAVING COUNT(mts1.stop_id) > 2
                                  GROUP BY mts1.trip_id);
                END IF;
        END IF;

      RETURN l_total_trips;
   EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
   END get_direct_tls_carr_facility;

  FUNCTION get_total_cost_carr_fac(p_plan_id           IN NUMBER,
                                   p_carrier_id        IN NUMBER,
                                   p_location_id       IN NUMBER,
                                   p_mode_of_transport IN VARCHAR2)
    RETURN NUMBER IS
        -- ---------------------------------------------
        -- Need to show cost of all trips (load/Unload)
        -- by a given mode of transport by the specified
        -- carrier facility.
        -- ---------------------------------------------
    CURSOR cur_total_cost_by_mode IS
    SELECT NVL(SUM(NVL(mdl.allocated_transport_cost,0) +
                 DECODE(mts.stop_id,
                            mdl.pick_up_stop_id,
                                NVL(mdl.allocated_fac_loading_cost,0),
                            mdl.drop_off_stop_id,
                                NVL(mdl.allocated_fac_unloading_cost,0),0)+
                 DECODE(mts.stop_id,
                            mdl.pick_up_stop_id,
                                NVL(mdl.allocated_fac_shp_hand_cost,0),
                            mdl.drop_off_stop_id,
                                NVL(mdl.allocated_fac_Rec_hand_cost,0),0) ), 0)
      FROM mst_delivery_legs mdl,
           mst_trip_stops mts,
           mst_trips mt
      WHERE mdl.plan_id = p_plan_id
      AND   mt.plan_id = mdl.plan_id
      AND   mt.trip_id = mdl.trip_id
      AND   mt.plan_id = mts.plan_Id
      AND   mt.trip_id = mts.trip_id
      AND   mt.mode_of_transport = p_mode_of_transport
      AND   mts.stop_location_id = p_location_id;

        -- ---------------------------------------------
        -- Need to show cost of all trips (load/Unload)
        -- by a all modes of transport by the specified
        -- carrier facility.
        -- ---------------------------------------------
    CURSOR cur_total_cost IS
    SELECT NVL(SUM(NVL(mdl.allocated_transport_cost,0) +
                 DECODE(mts.stop_id,
                            mdl.pick_up_stop_id,
                                NVL(mdl.allocated_fac_loading_cost,0),
                            mdl.drop_off_stop_id,
                                NVL(mdl.allocated_fac_unloading_cost,0),0) +
                  DECODE(mts.stop_id,
                            mdl.pick_up_stop_id,
                                NVL(mdl.allocated_fac_shp_hand_cost,0),
                            mdl.drop_off_stop_id,
                                NVL(mdl.allocated_fac_Rec_hand_cost,0),0) ), 0)
      FROM mst_delivery_legs mdl,
           mst_trip_stops mts,
           mst_trips mt
      WHERE mdl.plan_id = p_plan_id
      AND   mt.plan_id = mdl.plan_id
      AND   mt.trip_id = mdl.trip_id
      AND   mt.plan_id = mts.plan_Id
      AND   mt.trip_id = mts.trip_id
      AND   mts.stop_location_id = p_location_id;

    l_total_cost NUMBER :=0;

  BEGIN

    IF p_mode_of_transport IS NOT NULL THEN
        OPEN cur_total_cost_by_mode;
        FETCH cur_total_cost_by_mode INTO l_total_cost;
        CLOSE cur_total_cost_by_mode;
    ELSE
        OPEN cur_total_cost;
        FETCH cur_total_cost INTO l_total_cost;
        CLOSE cur_total_cost;
    END IF;
    RETURN l_total_cost;

  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  END get_total_cost_carr_fac;
/* End of Carrier Details/Carrier Facility Details functions */


-- Used by view definitions of Delivery Line grids:
-- 1. Call this function when source_code = OE for the Destination Company Name:
-- p_location_id = MST_DELIVERY_DETAILS.ship_to_location_id
-- p_customer_id = MST_DELIVERY_DETAILS.customer_id
-- 2. Call this function when source_code = OE for the Origin Company Name:
-- p_location_id = MST_DELIVERY_DETAILS.ship_from_location_id
-- p_customer_id = null

function get_owner_name_for_del_line(p_location_id IN number, p_customer_id IN number)
  return varchar2 is

l_location_source_code varchar2(30);
l_owner_name varchar2(360);

begin

  select location_source_code
  into l_location_source_code
  from wsh_locations loc
  where loc.wsh_location_id = p_location_id;
  -- including both customer and carrier, don't care it's customer/carrier
  if l_location_source_code = 'HZ' then
    select hzp.party_name
    into l_owner_name
    from hz_cust_accounts hzc,
         hz_parties hzp
    where hzc.cust_account_id = p_customer_id
    and hzc.party_id = hzp.party_id;

  -- p_party_id is orgnization_id from mst_delivery_details
  elsif l_location_source_code = 'HR' then
    l_owner_name := fnd_profile.value('MST_COMPANY_NAME');
  end if;
  return l_owner_name;
end;

-- Used by view definitions of Delivery Leg grids:
-- Call this function to get both the Origin Company Name and the Destination Company Name

function get_owner_name_for_del_leg(p_location_id IN number,
                                    p_plan_id IN NUMBER,
                                    p_delivery_id IN number)
  return varchar2 is

l_location_source_code varchar2(30);
l_owner_name varchar2(360) := null;

  -- SQL repository issues as on 25-05-04:
      -- Added new parameter plan_id
      -- added filter for plan_id
  cursor customer_account is
  select party_name
  from hz_locations hzl,
       hz_party_sites hzs,
       hz_cust_acct_sites_all hzcas,
       hz_cust_accounts hzca,
       hz_parties hzp,
       mst_deliveries md
  where md.plan_id = p_plan_id
  AND md.delivery_id = p_delivery_id
  and hzl.location_id = p_location_id
  and hzl.location_id = hzs.location_id
  and hzs.party_site_id = hzcas.party_site_id
  and hzcas.cust_account_id = hzca.cust_account_id
  and hzcas.cust_account_id = md.customer_id
  and hzca.party_id = hzp.party_id;

  cursor carriers is
  select car.freight_code
  from hz_locations hzl,
       hz_party_sites hzs,
       hz_parties hzp,
       wsh_carriers car
  where hzl.location_id = p_location_id
  and hzl.location_id = hzs.location_id
  and hzs.party_id = hzp.party_id
  and hzp.party_id = car.carrier_id;

begin

  select location_source_code
  into l_location_source_code
  from wsh_locations loc
  where loc.wsh_location_id = p_location_id;
  -- including both customer and carrier, don't care it's customer/carrier
  if l_location_source_code = 'HZ' then
    fetch customer_account into l_owner_name;
    if l_owner_name = null then
      fetch carriers into l_owner_name;
    end if;

  elsif l_location_source_code = 'HR' then
    l_owner_name := fnd_profile.value('MST_COMPANY_NAME');
  end if;
  return l_owner_name;
end;

-- Used by view definitions of Trips/Loads/Stops/Trip-legs grids:
-- Call this function to get both the Origin Company Name and the Destination Company Name

function get_owner_name_for_trip(p_location_id IN number)
  return varchar2 is

l_location_source_code varchar2(30);
l_owner_name varchar2(360) := null;
l_next_owner_name varchar2(360) := null;
    -- SQL repository issues as on 25-05-04:
      -- Rewritten sql to avoid distinct clause
      CURSOR customer_account IS
      SELECT hzp.party_name
      FROM hz_parties hzp
      WHERE hzp.party_id IN (SELECT hzca.party_id
                             FROM hz_locations hzl            , hz_party_sites hzs,
                                  hz_cust_acct_sites_all hzcas, hz_cust_accounts hzca
                             WHERE hzl.location_id = p_location_id
                             AND   hzl.location_id = hzs.location_id
                             AND hzs.party_site_id = hzcas.party_site_id
                             AND hzcas.cust_account_id = hzca.cust_account_id);

      /*
  cursor customer_account is
  select distinct party_name
  from hz_locations hzl,
       hz_party_sites hzs,
       hz_cust_acct_sites_all hzcas,
       hz_cust_accounts hzca,
       hz_parties hzp
  where hzl.location_id = p_location_id
  and hzl.location_id = hzs.location_id
  and hzs.party_site_id = hzcas.party_site_id
  and hzcas.cust_account_id = hzca.cust_account_id
  and hzca.party_id = hzp.party_id;*/

  cursor carriers is
  select car.freight_code
  from hz_locations hzl,
       hz_party_sites hzs,
       hz_parties hzp,
       wsh_carriers car
  where hzl.location_id = p_location_id
  and hzl.location_id = hzs.location_id
  and hzs.party_id = hzp.party_id
  and hzp.party_id = car.carrier_id;

begin

  select location_source_code
  into l_location_source_code
  from wsh_locations loc
  where loc.wsh_location_id = p_location_id;
  -- including both customer and carrier, don't care it's customer/carrier
  if l_location_source_code = 'HZ' then
    fetch customer_account into l_owner_name;
    if l_owner_name = null then
      fetch carriers into l_owner_name;
    else
      fetch customer_account into l_next_owner_name;
      if l_next_owner_name is not null then
        l_owner_name := 'MULTIPLE'; -- should be translatable, hardcode for now
      end if;
    end if;

  elsif l_location_source_code = 'HR' then
    l_owner_name := fnd_profile.value('MST_COMPANY_NAME');
  end if;
  return l_owner_name;
end;


function get_total_tls_in_cms(p_plan_id in number)
return number is
   l_count number;
begin
   select count(mt.trip_id)
   into l_count
   from mst_trips mt
   where plan_id = p_plan_id
   and mt.continuous_move_id in (select cm.continuous_move_id
                                   from   mst_cm_trips cm
                                   where  cm.plan_id = p_plan_id);
   return l_count;
end;


function get_total_excp_in_plan(p_plan_id in number)  --get_total_excp
return number is
   l_count number;
begin
   select sum(exception_count)
   into l_count
   from mst_exceptions
   where plan_id = p_plan_id;
   return l_count;
end;

function get_total_excp_in_trip(p_plan_id in number, p_trip_id in number)  --any_exceptions
return number is
   l_count number;
begin
   select count(*)
   into l_count
   from mst_exception_details
   where plan_id = p_plan_id
   and  (trip_id1 = p_trip_id
   or    trip_id2 = p_trip_id);
   return l_count;
end;

function get_total_trip_weight(p_plan_id in number,
                               p_trip_id in number)
return number is
   l_total_weight number;
begin
      select NVL(sum(nvl(md.gross_weight, 0)),0)
      into   l_total_weight
      from   mst_deliveries md
      where  md.plan_id = p_plan_id
      and    exists (select 1
                     from   mst_delivery_legs mdl,
                            mst_trip_stops mts,
                            mst_trips mt
                     where  mdl.delivery_id = md.delivery_id
                     and    mdl.pick_up_stop_id = mts.stop_id
                     and    mt.trip_id = p_trip_id
                     and    mts.trip_id = mt.trip_id
                     and    mt.plan_id = p_plan_id
                     and    mts.plan_id = p_plan_id
                     and    mdl.plan_id = p_plan_id);
   return l_total_weight;
end;

function get_total_trip_volume(p_plan_id in number,
                               p_trip_id in number)
return number is
   l_total_volume number;
begin
      select NVL(sum(md.volume),0)
      into   l_total_volume
      from   mst_deliveries md
      where  md.plan_id = p_plan_id
      and    exists (select 1
                     from   mst_delivery_legs mdl,
                            mst_trip_stops mts,
                            mst_trips mt
                     where  mdl.delivery_id = md.delivery_id
                     and    mdl.pick_up_stop_id = mts.stop_id
                     and    mt.trip_id = p_trip_id
                     and    mts.trip_id = mt.trip_id
                     and    mt.plan_id = p_plan_id
                     and    mts.plan_id = p_plan_id
                     and    mdl.plan_id = p_plan_id);
   return l_total_volume;
end;

function get_total_trip_pallets(p_plan_id in number,
                                p_trip_id in number)
return number is
   l_total_pallets number;
begin
      select NVL(sum(nvl(md.number_of_pallets,0)), 0)
      into   l_total_pallets
      from   mst_deliveries md
      where  md.plan_id = p_plan_id
      and    exists (select 1
                     from   mst_delivery_legs mdl,
                            mst_trip_stops mts,
                            mst_trips mt
                     where  mdl.delivery_id = md.delivery_id
                     and    mdl.pick_up_stop_id = mts.stop_id
                     and    mt.trip_id = p_trip_id
                     and    mts.trip_id = mt.trip_id
                     and    mt.plan_id = p_plan_id
                     and    mts.plan_id = p_plan_id
                     and    mdl.plan_id = p_plan_id);
   return l_total_pallets;
end;

function get_total_trip_pieces(p_plan_id in number,
                               p_trip_id in number)
return number is
   l_total_pieces number;
begin
      select sum(nvl(md.number_of_pieces, 0))
      into   l_total_pieces
      from   mst_deliveries md
      where  md.plan_id = p_plan_id
      and    exists (select 1
                     from   mst_delivery_legs mdl,
                            mst_trip_stops mts,
                            mst_trips mt
                     where  mdl.delivery_id = md.delivery_id
                     and    mdl.pick_up_stop_id = mts.stop_id
                     and    mt.trip_id = p_trip_id
                     and    mts.trip_id = mt.trip_id
                     and    mt.plan_id = p_plan_id
                     and    mts.plan_id = p_plan_id
                     and    mdl.plan_id = p_plan_id);
   return l_total_pieces;
end;

function get_total_direct_tls(p_plan_id in number)
return number is
   l_count number;
begin
   select count(mt.trip_id)
   into l_count
   from mst_trips mt
   where mt.mode_of_transport = 'TRUCK'
   and   mt.plan_id = p_plan_id
   and   mt.trip_id in (select mts.trip_id
                        from   mst_trip_stops mts
                        where  mt.trip_id = mts.trip_id
                        and    mt.plan_id = mts.plan_id
                        having count(mts.trip_id) = 2
                        group by mts.trip_id);
   return l_count;
end;

function get_total_direct_mstop_tls(p_plan_id in number)
return number is
   l_count number;
begin
   select count(mt.trip_id)
   into l_count
   from mst_trips mt
   where mt.mode_of_transport = 'TRUCK'
   and   mt.plan_id = p_plan_id
   and   mt.trip_id in (select mts.trip_id
                        from   mst_trip_stops mts
                        where  mt.trip_id = mts.trip_id
                        and    mt.plan_id = mts.plan_id
                        having count(mts.trip_id) > 2
                        group by mts.trip_id);
   return l_count;
end;


function get_auto_release_trip_count (p_plan_id number, p_mode varchar2)
return number is
  l_count number;
begin
  select count('x')
  into l_count
  from mst_trips
  where plan_id = p_plan_id
  and auto_release_flag = 1
  and mode_of_transport = p_mode;
  return l_count;
end get_auto_release_trip_count;

function get_released_trip_count (p_plan_id number, p_mode varchar2)
return number is
  l_count number;
begin
  select count('x')
  into l_count
  from mst_trips
  where plan_id = p_plan_id
  and release_status <> 4
  and release_date is not null
  and auto_release_flag <> 1
  and mode_of_transport = p_mode;
  return l_count;
end get_released_trip_count;


function get_release_failed_trip_count (p_plan_id number, p_mode varchar2)
return number is
  l_count number;
begin
  select count('x')
  into l_count
  from mst_trips
  where plan_id = p_plan_id
  and release_status = 4
  and release_date is not null
  and mode_of_transport = p_mode;
  return l_count;
end get_release_failed_trip_count;

function get_flag_for_rel_trip_count (p_plan_id number, p_mode varchar2)
return number is
  l_count number;
begin
  select count('x')
  into l_count
  from mst_trips
  where plan_id = p_plan_id
  and selected_for_release = 1
  and mode_of_transport = p_mode;
  return l_count;
end get_flag_for_rel_trip_count;

function get_not_rel_trip_count (p_plan_id number, p_mode varchar2)
return number is
  l_count number;
begin
  select count('x')
  into l_count
  from mst_trips
  where plan_id = p_plan_id
  and release_date is null
  and mode_of_transport = p_mode;
  return l_count;
end get_not_rel_trip_count;

function get_auto_release_cm_count (p_plan_id number)
return number is
  l_count number;
begin
  select count('x')
  into l_count
  from mst_cm_trips
  where plan_id = p_plan_id
  and auto_release_flag = 1;
  return l_count;
end get_auto_release_cm_count;

function get_released_cm_count (p_plan_id number)
return number is
  l_count number;
begin
  select count('x')
  into l_count
  from mst_cm_trips
  where plan_id = p_plan_id
  and release_status <> 4
  and release_date is not null
  and auto_release_flag <> 1;
  return l_count;
end get_released_cm_count;


function get_rel_failed_cm_count (p_plan_id number)
return number is
  l_count number;
begin
  select count('x')
  into l_count
  from mst_cm_trips
  where plan_id = p_plan_id
  and release_status = 4
  and release_date is not null;
  return l_count;
end get_rel_failed_cm_count;

function get_flag_for_rel_cm_count (p_plan_id number)
return number is
  l_count number;
begin
  select count('x')
  into l_count
  from mst_cm_trips
  where plan_id = p_plan_id
  and selected_for_release = 1;
  return l_count;
end get_flag_for_rel_cm_count;

function get_not_rel_cm_count (p_plan_id number)
return number is
  l_count number;
begin
  select count('x')
  into l_count
  from mst_cm_trips
  where plan_id = p_plan_id
  and release_date is null;
  return l_count;
end get_not_rel_cm_count;

function get_total_excp_in_cm(p_plan_id in number, p_cm_id in number)
return number is
   l_count number;
begin
   select count(*)
   into l_count
   from mst_exception_details
   where plan_id = p_plan_id
   and  continuous_move_id = p_cm_id;
   return l_count;
end;

END MST_AGG_PKG;

/
