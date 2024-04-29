--------------------------------------------------------
--  DDL for Package Body MST_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_REPORTS_PKG" AS
/* $Header: MSTREPOB.pls 115.15 2004/07/02 19:25:33 bramacha noship $ */

  --define/declare package level variables here
  -- g_release_type                number; -- being used in MSTEXCEP.pld

  --declare internal functions/procedures here
  --

  --start procedure/function definition here
  --


-- p_report_for    =>   0 -> Entire Plan ;  1 -> My Facility ;  2 -> Customer ;  4 -> Supplier
-- p_report_for_id =>   My Facility ID / Customer ID / Carrier ID / Supplier ID
function get_plan_order_count (p_plan_id       in number
                             , p_report_for    in number
			     , p_report_for_id in number)
return number is
  l_plan_order_count number;

  cursor cur_plan_orders (l_plan_id in number) is
  select nvl(mp.total_orders,0)
  from mst_plans mp
  where mp.plan_id = l_plan_id;


  cursor cur_plan_orders_myfac (l_plan_id  in number
                            , l_myfac_id in number) is
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
     , mst_deliveries md
     , mst_delivery_assignments mda
  where md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id
  and md.delivery_id in
        (select mdl.delivery_id
         from mst_trips t
            , mst_trip_stops ts
            , mst_delivery_legs mdl
            , fte_location_parameters flp
         where mdl.plan_id = md.plan_id
         and ts.plan_id  = mdl.plan_id
         and ts.stop_id  = mdl.pick_up_stop_id
         and ts.stop_location_id = flp.location_id
	 and flp.facility_id = l_myfac_id
         and ts.plan_id  = t.plan_id
         and ts.trip_id  = t.trip_id)
  and   mda.plan_id = mdd.plan_id
  and   mda.delivery_detail_id = mdd.delivery_detail_id
  and   md.plan_id = l_plan_id
  and   mdd.container_flag = 2;
--  and   mdd.split_from_delivery_detail_id is null;


  --considering both assigned and unassigned deliveries
  cursor cur_plan_orders_c_s (l_plan_id      in number
                            , l_c_s_ident    in number
                            , l_cust_supp_id in number) is
  select count(distinct dd.source_header_number)
  from (
        select mdd.source_header_number
        from mst_delivery_details mdd
           , mst_deliveries md
           , mst_delivery_assignments mda
        where md.plan_id = mda.plan_id
        and   md.delivery_id = mda.delivery_id
        and   mda.plan_id = mdd.plan_id
        and   mda.delivery_detail_id = mdd.delivery_detail_id
        and   md.plan_id = l_plan_id
        and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
        and   md.delivery_id in
                    (select mdl.delivery_id
                     from  mst_delivery_legs mdl
                         , mst_trip_stops mts
                     where mdl.plan_id = md.plan_id
                     and   mdl.plan_id = mts.plan_id
                     and ( mdl.pick_up_stop_id = mts.stop_id
                          or mdl.drop_off_stop_id = mts.stop_id))
  union all
  select mdd.source_header_number
  from mst_delivery_details mdd
     , mst_deliveries md
     , mst_delivery_assignments mda
  where md.plan_id = mda.plan_id
  and   md.delivery_id = mda.delivery_id
  and   mda.plan_id = mdd.plan_id
  and   mda.delivery_detail_id = mdd.delivery_detail_id
  and   md.plan_id = l_plan_id
  and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and   not exists (select 1 from mst_delivery_legs mdl
                    where mdl.plan_id=md.plan_id
                    and   mdl.delivery_id = md.delivery_id)) dd;

  cursor cur_plan_orders_carr (l_plan_id      in number
                             , l_carrier_id   in number) is
  select count(distinct nvl(mdd.split_from_delivery_detail_id, mdd.delivery_detail_id))
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  where mdd.plan_id = l_plan_id
  and mdd.plan_id = mda.plan_id
  and mdd.delivery_detail_id = mda.delivery_detail_id
  and mda.parent_delivery_detail_id is null
  and md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);

begin
  if p_report_for = 0 then
    open cur_plan_orders (p_plan_id);
    fetch cur_plan_orders into l_plan_order_count;
    close cur_plan_orders;
  elsif p_report_for = 1 then
    open cur_plan_orders_myfac (p_plan_id, p_report_for_id);
    fetch cur_plan_orders_myfac into l_plan_order_count;
    close cur_plan_orders_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_plan_orders_c_s (p_plan_id, p_report_for, p_report_for_id);
    fetch cur_plan_orders_c_s into l_plan_order_count;
    close cur_plan_orders_c_s;
  elsif p_report_for = 3 then
    open cur_plan_orders_carr (p_plan_id, p_report_for_id);
    fetch cur_plan_orders_carr into l_plan_order_count;
    close cur_plan_orders_carr;
  end if;

  return l_plan_order_count;
exception
when others then
	 return 0;
end get_plan_order_count;


-- Logical Order Groups KPI
function get_order_group_count (p_plan_id       in number
                             , p_report_for     in number
			     , p_report_for_id  in number)
return number is
  l_order_groups number;

  cursor cur_order_groups (l_plan_id in number) is
  select count(*)
  from mst_deliveries md
  where md.plan_id = l_plan_id;


  cursor cur_order_groups_myfac (l_plan_id  in number
                               , l_myfac_id in number) is
  select count(*)
  from mst_deliveries md
  , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id;


  cursor cur_order_groups_c_s (l_plan_id      in number
                             , l_c_s_ident    in number
    	                     , l_cust_supp_id in number) is
  select count(*)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_order_groups_carr (l_plan_id    in number
                              , l_carrier_id in number) is
  select count(*)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 0 then
    open cur_order_groups (p_plan_id);
    fetch cur_order_groups into l_order_groups;
    close cur_order_groups;
  elsif p_report_for = 1 then
    open cur_order_groups_myfac (p_plan_id, p_report_for_id);
    fetch cur_order_groups_myfac into l_order_groups;
    close cur_order_groups_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_order_groups_c_s (p_plan_id, p_report_for, p_report_for_id);
    fetch cur_order_groups_c_s into l_order_groups;
    close cur_order_groups_c_s;
  elsif p_report_for = 3 then
    open cur_order_groups_carr (p_plan_id, p_report_for_id);
    fetch cur_order_groups_carr into l_order_groups;
    close cur_order_groups_carr;
  end if;

return l_order_groups;
exception
when others then
	 return 0;
end get_order_group_count;


-- Weight KPI
function get_weight (p_plan_id       in number
                   , p_report_for    in number
		   , p_report_for_id in number)
return number is
  l_weight number;

  cursor cur_weight (l_plan_id in number) is
  select nvl(mp.total_weight,0)
  from mst_plans mp
  where mp.plan_id = l_plan_id;


  cursor cur_weight_myfac (l_plan_id  in number
                         , l_myfac_id in number) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
     , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id;


  cursor cur_weight_c_s (l_plan_id      in number
                       , l_c_s_ident    in number
  		       , l_cust_supp_id in number) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_weight_carr (l_plan_id       in number
                        , l_carrier_id    in number) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 0 then
    open cur_weight (p_plan_id);
    fetch cur_weight into l_weight;
    close cur_weight;
  elsif p_report_for = 1 then
    open cur_weight_myfac (p_plan_id, p_report_for_id);
    fetch cur_weight_myfac into l_weight;
    close cur_weight_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_weight_c_s (p_plan_id, p_report_for, p_report_for_id);
    fetch cur_weight_c_s into l_weight;
    close cur_weight_c_s;
  elsif p_report_for = 3 then
    open cur_weight_carr (p_plan_id, p_report_for_id);
    fetch cur_weight_carr into l_weight;
    close cur_weight_carr;
  end if;

return l_weight;
exception
when others then
	 return 0;
end get_weight;


-- Volums KPI
function get_volume (p_plan_id       in number
                   , p_report_for    in number
		   , p_report_for_id in number)
return number is
  l_volume number;

  cursor cur_volume (l_plan_id in number) is
  select nvl(mp.total_volume,0)
  from mst_plans mp
  where mp.plan_id = l_plan_id;


  cursor cur_volume_myfac (l_plan_id  in number
                         , l_myfac_id in number) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
     , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id;


  cursor cur_volume_c_s (l_plan_id      in number
                       , l_c_s_ident    in number
  		       , l_cust_supp_id in number) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_volume_carr (l_plan_id       in number
                        , l_carrier_id    in number) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 0 then
    open cur_volume (p_plan_id);
    fetch cur_volume into l_volume;
    close cur_volume;
  elsif p_report_for = 1 then
    open cur_volume_myfac (p_plan_id, p_report_for_id);
    fetch cur_volume_myfac into l_volume;
    close cur_volume_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_volume_c_s (p_plan_id, p_report_for, p_report_for_id);
    fetch cur_volume_c_s into l_volume;
    close cur_volume_c_s;
  elsif p_report_for = 3 then
    open cur_volume_carr (p_plan_id, p_report_for_id);
    fetch cur_volume_carr into l_volume;
    close cur_volume_carr;
  end if;

return l_volume;
exception
when others then
	 return 0;
end get_volume;


-- Pieces KPI
function get_pieces (p_plan_id       in number
                   , p_report_for    in number
		   , p_report_for_id in number)
return number is
  l_pieces number;

  cursor cur_pieces (l_plan_id in number) is
  select nvl(mp.total_pieces,0)
  from mst_plans mp
  where mp.plan_id = l_plan_id;


  cursor cur_pieces_myfac (l_plan_id  in number
                         , l_myfac_id in number) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
     , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id;


  cursor cur_pieces_c_s (l_plan_id      in number
                       , l_c_s_ident    in number
  		       , l_cust_supp_id in number) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_pieces_carr (l_plan_id       in number
                        , l_carrier_id    in number) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 0 then
    open cur_pieces (p_plan_id);
    fetch cur_pieces into l_pieces;
    close cur_pieces;
  elsif p_report_for = 1 then
    open cur_pieces_myfac (p_plan_id, p_report_for_id);
    fetch cur_pieces_myfac into l_pieces;
    close cur_pieces_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_pieces_c_s (p_plan_id, p_report_for, p_report_for_id);
    fetch cur_pieces_c_s into l_pieces;
    close cur_pieces_c_s;
  elsif p_report_for = 3 then
    open cur_pieces_carr (p_plan_id, p_report_for_id);
    fetch cur_pieces_carr into l_pieces;
    close cur_pieces_carr;
  end if;

return l_pieces;
exception
when others then
	 return 0;
end get_pieces;


function get_plan_value (p_plan_id in number
                       , p_report_for    in number
		       , p_report_for_id in number)
return number is
  l_plan_value number;

  cursor cur_plan_value (l_plan_id in number) is
  select sum(nvl(mdd.unit_price,0)* nvl(mdd.requested_quantity,0))
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  where mdd.plan_id = l_plan_id
  and mda.plan_id = mdd.plan_id
  and mda.delivery_detail_id = mdd.delivery_detail_id
  and mda.parent_delivery_detail_id is null
  and md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id;

  cursor cur_plan_value_myfac (l_plan_id  in number
                             , l_myfac_id in number) is
  select sum(nvl(mdd.unit_price,0)* nvl(mdd.requested_quantity,0))
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  , fte_location_parameters flp
  where mdd.plan_id = l_plan_id
  and mda.plan_id = mdd.plan_id
  and mda.delivery_detail_id = mdd.delivery_detail_id
  and mda.parent_delivery_detail_id is null
  and md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id;

  cursor cur_plan_value_c_s (l_plan_id in number
                           , l_c_s_ident    in number
     		           , l_cust_supp_id in number) is
  select sum(nvl(mdd.unit_price,0)* nvl(mdd.requested_quantity,0))
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  where mdd.plan_id = l_plan_id
  and mda.plan_id = mdd.plan_id
  and mda.delivery_detail_id = mdd.delivery_detail_id
  and mda.parent_delivery_detail_id is null
  and md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_plan_value_carr (l_plan_id      in number
                            , l_carrier_id   in number) is
  select sum(nvl(mdd.unit_price,0)* nvl(mdd.requested_quantity,0))
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  where mdd.plan_id = l_plan_id
  and mdd.plan_id = mda.plan_id
  and mdd.delivery_detail_id = mda.delivery_detail_id
  and mda.parent_delivery_detail_id is null
  and md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 0 then
    open cur_plan_value (p_plan_id);
    fetch cur_plan_value into l_plan_value;
    close cur_plan_value;
  elsif p_report_for = 1 then
    open cur_plan_value_myfac (p_plan_id, p_report_for_id);
    fetch cur_plan_value_myfac into l_plan_value;
    close cur_plan_value_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_plan_value_c_s (p_plan_id, p_report_for, p_report_for_id);
    fetch cur_plan_value_c_s into l_plan_value;
    close cur_plan_value_c_s;
  elsif p_report_for = 3 then
    open cur_plan_value_carr (p_plan_id, p_report_for_id);
    fetch cur_plan_value_carr into l_plan_value;
    close cur_plan_value_carr;
  end if;

   return l_plan_value;
exception
when others then
	 return 0;
end get_plan_value;


function get_trips_per_mode (p_plan_id       in number
                           , p_report_for    in number
		           , p_report_for_id in number
			   , p_mode          in varchar2)
return number is
  l_trips_per_mode number;

  cursor cur_trips (l_plan_id in number
                  , l_mode    in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode;

  cursor cur_trips_myfac (l_plan_id  in number
                        , l_myfac_id in number
			, l_mode     in varchar2) is
  select count(*)
  from mst_trips mt
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and flp.location_id in (select mts.stop_location_id
                          from mst_trip_stops mts
			  where mts.plan_id = mt.plan_id
			  and mts.trip_id = mt.trip_id)
  and flp.facility_id = l_myfac_id;

  cursor cur_trips_c_s (l_plan_id      in number
                      , l_c_s_ident    in number
                      , l_cust_supp_id in number
		      , l_mode         in varchar2) is
  select count(mt.trip_id)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   mt.mode_of_transport = l_mode
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) >= 2
        group by ts.trip_id);

  cursor cur_trips_carr (l_plan_id in number
                       , l_carrier_id in number
                       , l_mode    in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.carrier_id = l_carrier_id
  and mt.mode_of_transport = l_mode;

begin
  if p_report_for = 0 then
    open cur_trips (p_plan_id, p_mode);
    fetch cur_trips into l_trips_per_mode;
    close cur_trips;
  elsif p_report_for = 1 then
    open cur_trips_myfac (p_plan_id, p_report_for_id, p_mode);
    fetch cur_trips_myfac into l_trips_per_mode;
    close cur_trips_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_trips_c_s (p_plan_id, p_report_for, p_report_for_id, p_mode);
    fetch cur_trips_c_s into l_trips_per_mode;
    close cur_trips_c_s;
  elsif p_report_for = 3 then
    open cur_trips_carr (p_plan_id, p_report_for_id, p_mode);
    fetch cur_trips_carr into l_trips_per_mode;
    close cur_trips_carr;
  end if;

   return l_trips_per_mode;
exception
when others then
	 return 0;
end get_trips_per_mode;


function get_trans_cost_per_mode (p_plan_id       in number
                                , p_report_for    in number
		                , p_report_for_id in number
			        , p_mode          in varchar2)
return number is
  l_trans_cost_per_mode number;

  cursor cur_trans_cost (l_plan_id in number
                       , l_mode    in varchar2) is
  select decode(l_mode,'TRUCK',nvl(mp.total_tl_cost,0)
                      ,'LTL'  ,nvl(mp.total_ltl_cost,0)
		              ,nvl(mp.total_parcel_cost,0))
  from mst_plans mp
  where mp.plan_id = l_plan_id;

  cursor cur_trans_cost_myfac (l_plan_id  in number
                             , l_myfac_id in number
			     , l_mode     in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_transport_cost,0)
               + nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
		   , fte_location_parameters flp
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = flp.location_id
                and   flp.facility_id = l_myfac_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   (md.pickup_location_id = flp.location_id
                       or md.dropoff_location_id = flp.location_id));
*/
--Bug_Fix for 3696518 - II
  ( select nvl(sum(nvl(mdl.allocated_transport_cost,0)
               + nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and flp.facility_id = l_myfac_id
  and ( md.pickup_location_id = flp.location_id
        or md.dropoff_location_id = flp.location_id ) );


  cursor cur_trans_cost_c_s (l_plan_id      in number
                           , l_c_s_ident    in number
                           , l_cust_supp_id in number
		           , l_mode         in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_transport_cost,0)
               + nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                and   (md.pickup_location_id = mts.stop_location_id
		       or md.dropoff_location_id = mts.stop_location_id));
*/
--Bug_Fix for 3696518 - II
  ( select nvl(sum(nvl(mdl.allocated_transport_cost,0)
               + nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
--  and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id );

  cursor cur_trans_cost_carr (l_plan_id  in number
                            , l_carrier_id in number
			    , l_mode     in varchar2) is
  select nvl(sum(decode(mt.mode_of_transport
                       , 'TRUCK', (nvl(mt.total_basic_transport_cost,0)
                                 + nvl(mt.total_stop_cost,0)
		                 + nvl(mt.total_load_unload_cost,0)
			         + nvl(mt.total_layover_cost,0)
			         + nvl(mt.total_accessorial_cost,0))
		       , (nvl(mt.total_basic_transport_cost,0)
		       + nvl(mt.total_accessorial_cost,0)))),0)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.carrier_id = l_carrier_id
  and mt.mode_of_transport = l_mode;
--  and mt.continuous_move_id is null;

begin
  if p_report_for = 0 then
    open cur_trans_cost (p_plan_id, p_mode);
    fetch cur_trans_cost into l_trans_cost_per_mode;
    close cur_trans_cost;
  elsif p_report_for = 1 then
    open cur_trans_cost_myfac (p_plan_id, p_report_for_id, p_mode);
    fetch cur_trans_cost_myfac into l_trans_cost_per_mode;
    close cur_trans_cost_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_trans_cost_c_s (p_plan_id, p_report_for, p_report_for_id, p_mode);
    fetch cur_trans_cost_c_s into l_trans_cost_per_mode;
    close cur_trans_cost_c_s;
  elsif p_report_for = 3 then
    open cur_trans_cost_carr (p_plan_id, p_report_for_id, p_mode);
    fetch cur_trans_cost_carr into l_trans_cost_per_mode;
    close cur_trans_cost_carr;
  end if;

   return l_trans_cost_per_mode;
exception
when others then
	 return 0;
end get_trans_cost_per_mode;

function get_handl_cost_per_mode (p_plan_id       in number
                                , p_report_for    in number
		                , p_report_for_id in number
		                , p_mode         in varchar2)
return number is
  l_handl_cost_per_mode number;

  cursor cur_handl_cost (l_plan_id in number
                       , l_mode    in varchar2) is
  select nvl(sum(nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_plans mp
  , mst_delivery_legs mdl
  where mp.plan_id = mdl.plan_id
  and mdl.trip_id in (select mt.trip_id
                      from mst_trips mt
		      where mt.plan_id = mp.plan_id
		      and   mt.mode_of_transport = l_mode)
  and mdl.plan_id = l_plan_id;

  cursor cur_handl_cost_myfac (l_plan_id  in number
                             , l_myfac_id in number
			     , l_mode     in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
		   , fte_location_parameters flp
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = flp.location_id
                and   flp.facility_id = l_myfac_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   (md.pickup_location_id = flp.location_id
                       or md.dropoff_location_id = flp.location_id));
*/
--Bug_Fix for 3696518 - II
  ( select nvl(sum(nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and flp.facility_id = l_myfac_id
  and ( md.pickup_location_id = flp.location_id
        or md.dropoff_location_id = flp.location_id ) );

  cursor cur_handl_cost_c_s (l_plan_id      in number
                           , l_c_s_ident    in number
                           , l_cust_supp_id in number
			   , l_mode         in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                and   (md.pickup_location_id = mts.stop_location_id
		       or md.dropoff_location_id = mts.stop_location_id));
*/
--Bug_Fix for 3696518 - II
  (select nvl(sum(nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
--  and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id );


  cursor cur_handl_cost_carr (l_plan_id  in number
                            , l_carrier_id in number
			    , l_mode     in varchar2) is
  select nvl(sum(decode(mt.mode_of_transport
                       , 'TRUCK', (nvl(mt.total_handling_cost,0))
		       , (nvl(mt.total_handling_cost,0)))),0)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.carrier_id = l_carrier_id
  and mt.mode_of_transport = l_mode;
--  and mt.continuous_move_id is null;

begin
  if p_report_for = 0 then
    open cur_handl_cost (p_plan_id, p_mode);
    fetch cur_handl_cost into l_handl_cost_per_mode;
    close cur_handl_cost;
  elsif p_report_for = 1 then
    open cur_handl_cost_myfac (p_plan_id, p_report_for_id, p_mode);
    fetch cur_handl_cost_myfac into l_handl_cost_per_mode;
    close cur_handl_cost_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_handl_cost_c_s (p_plan_id, p_report_for, p_report_for_id, p_mode);
    fetch cur_handl_cost_c_s into l_handl_cost_per_mode;
    close cur_handl_cost_c_s;
  elsif p_report_for = 3 then
    open cur_handl_cost_carr (p_plan_id, p_report_for_id, p_mode);
    fetch cur_handl_cost_carr into l_handl_cost_per_mode;
    close cur_handl_cost_carr;
  end if;

   return l_handl_cost_per_mode;
exception
when others then
	 return 0;
end get_handl_cost_per_mode;

function get_total_cost_per_mode (p_plan_id       in number
                                , p_report_for    in number
      		                , p_report_for_id in number
		                , p_mode          in varchar2)
return number is
  l_total_cost_per_mode number;

  cursor cur_total_cost (l_plan_id in number
                       , l_mode    in varchar2) is
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_plans mp
  , mst_delivery_legs mdl
  where mp.plan_id = mdl.plan_id
  and mdl.trip_id in (select mt.trip_id
                      from mst_trips mt
		      where mt.plan_id = mp.plan_id
		      and   mt.mode_of_transport = l_mode)
  and mdl.plan_id = l_plan_id;

  cursor cur_total_cost_myfac (l_plan_id  in number
                             , l_myfac_id in number
                             , l_mode     in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
		   , fte_location_parameters flp
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = flp.location_id
                and   flp.facility_id = l_myfac_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   (md.pickup_location_id = flp.location_id
                       or md.dropoff_location_id = flp.location_id));
*/
--Bug_Fix for 3696518 - II
  ( select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and flp.facility_id = l_myfac_id
  and ( md.pickup_location_id = flp.location_id
        or md.dropoff_location_id = flp.location_id ) );

  cursor cur_total_cost_c_s (l_plan_id      in number
                           , l_c_s_ident    in number
                           , l_cust_supp_id in number
			   , l_mode         in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                and   (md.pickup_location_id = mts.stop_location_id
		       or md.dropoff_location_id = mts.stop_location_id));
*/
--Bug_Fix for 3696518 - II
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
--  and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id );

  cursor cur_total_cost_carr (l_plan_id  in number
                            , l_carrier_id in number
			    , l_mode     in varchar2) is
  select nvl(sum(decode(mt.mode_of_transport
                       , 'TRUCK', (nvl(mt.total_basic_transport_cost,0)
                                 + nvl(mt.total_stop_cost,0)
		                 + nvl(mt.total_load_unload_cost,0)
			         + nvl(mt.total_layover_cost,0)
			         + nvl(mt.total_accessorial_cost,0)
			         + nvl(mt.total_handling_cost,0))
		       , (nvl(mt.total_basic_transport_cost,0)
		        + nvl(mt.total_accessorial_cost,0)))),0)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.carrier_id = l_carrier_id
  and mt.mode_of_transport = l_mode;
--  and mt.continuous_move_id is null;

begin
  if p_report_for = 0 then
    open cur_total_cost (p_plan_id, p_mode);
    fetch cur_total_cost into l_total_cost_per_mode;
    close cur_total_cost;
  elsif p_report_for = 1 then
    open cur_total_cost_myfac (p_plan_id, p_report_for_id, p_mode);
    fetch cur_total_cost_myfac into l_total_cost_per_mode;
    close cur_total_cost_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_total_cost_c_s (p_plan_id, p_report_for, p_report_for_id, p_mode);
    fetch cur_total_cost_c_s into l_total_cost_per_mode;
    close cur_total_cost_c_s;
  elsif p_report_for = 3 then
    open cur_total_cost_carr (p_plan_id, p_report_for_id, p_mode);
    fetch cur_total_cost_carr into l_total_cost_per_mode;
    close cur_total_cost_carr;
  end if;

   return l_total_cost_per_mode;
exception
when others then
	 return 0;
end get_total_cost_per_mode;


function get_stops_per_load (p_plan_id       in number
                           , p_report_for    in number
      		           , p_report_for_id in number)
return number is
  l_TL_stops_per_load number;
  l_TL_stops          number;
  l_TLs               number;
  l_denom             number;

  cursor cur_TL_stops (l_plan_id in number) is
  select count(*)
  from mst_trip_stops mts
  , mst_trips mt
  where mt.plan_id = mts.plan_id
  and mt.trip_id = mts.trip_id
  and mt.mode_of_transport = 'TRUCK'
  and mts.plan_id = l_plan_id;

  cursor cur_TL_stops_myfac (l_plan_id  in number
                           , l_myfac_id in number) is
/*
  select count(*)
  from mst_trip_stops mts
  , mst_trips mt
  , fte_location_parameters flp
  where mt.plan_id = mts.plan_id
  and mt.trip_id = mts.trip_id
  and mt.mode_of_transport = 'TRUCK'
  and flp.location_id = mts.stop_location_id
  and flp.facility_id = l_myfac_id
  and mts.plan_id = l_plan_id;
*/
/*
--Bug_Fix for 3693925
  select count(*)
  from mst_trip_stops mts
  where mts.plan_id = l_plan_id
  and mts.trip_id in ( select distinct mt.trip_id
                    from mst_trips mt
                    , mst_trip_stops mts1
                    , fte_location_parameters flp
                    where mt.plan_id = mts.plan_id
                    and mt.trip_id = mts.trip_id
                    and mt.mode_of_transport = 'TRUCK'
                    and mts1.plan_id = mt.plan_id
                    and mts1.trip_id = mt.trip_id
                    and flp.facility_id = l_myfac_id
                    and flp.location_id = mts1.stop_location_id );
*/
--Bug_Fix for 3696518 - II
  select count ( * )
  from mst_trips mt
  , mst_trip_stops mts
  where mts.plan_id = l_plan_id
  and mts.trip_id = mt.trip_id
  and mt.plan_id= mts.plan_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.trip_id in ( select mdl.trip_id
                      from mst_deliveries md
					  , mst_delivery_legs mdl
					  , fte_location_parameters flp
					  where md.plan_id = l_plan_id
					  and flp.facility_id = l_myfac_id
					  and ( md.dropoff_location_id = flp.location_id
					        or md.pickup_location_id = flp.location_id )
					  and mdl.plan_id = md.plan_id
					  and mdl.delivery_id = md.delivery_id );

  cursor cur_TL_stops_c_s (l_plan_id      in number
                         , l_c_s_ident    in number
                         , l_cust_supp_id in number) is
  select count(*)
  from mst_trip_stops mts
  , mst_trips mt
  where mt.plan_id = mts.plan_id
  and mt.trip_id = mts.trip_id
  and mt.mode_of_transport = 'TRUCK'
  and mts.plan_id = l_plan_id
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_delivery_legs mdl
		     , mst_deliveries md
		     where mdl.plan_id = mt.plan_id
		     and md.plan_id = mdl.plan_id
		     and md.delivery_id = mdl.delivery_id
                     and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id);

  cursor cur_TL_stops_carr (l_plan_id    in number
                          , l_carrier_id in number) is
  select count(*)
  from mst_trip_stops mts
  , mst_trips mt
  where mt.plan_id = mts.plan_id
  and mt.trip_id = mts.trip_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.carrier_id = l_carrier_id
  and mts.plan_id = l_plan_id;

  cursor cur_TLs (l_plan_id in number) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'TRUCK';

  cursor cur_TLs_myfac (l_plan_id  in number
                      , l_myfac_id in number) is
/*
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.trip_id in (select distinct mts.trip_id
                     from mst_trip_stops mts
		     , fte_location_parameters flp
		     where mts.plan_id = mt.plan_id
		     and mts.stop_location_id = flp.location_id
		     and flp.facility_id = l_myfac_id);
*/
--Bug_Fix for 3696518 - II
  select count ( * )
  from mst_trips mt
  where mt.plan_id= l_plan_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.trip_id in ( select mdl.trip_id
                      from mst_deliveries md
					  , mst_delivery_legs mdl
					  , fte_location_parameters flp
					  where md.plan_id = l_plan_id
					  and flp.facility_id = l_myfac_id
					  and ( md.dropoff_location_id = flp.location_id
					        or md.pickup_location_id = flp.location_id )
					  and mdl.plan_id = md.plan_id
					  and mdl.delivery_id = md.delivery_id );

  cursor cur_TLs_c_s (l_plan_id      in number
                    , l_c_s_ident    in number
                    , l_cust_supp_id in number) is
/*
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_trip_stops mts
		     , mst_delivery_legs mdl
		     , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) >= 2
        group by ts.trip_id);
*/
--Bug_Fix for 3696518 - II
  select count ( * )
  from mst_trips mt
  where mt.plan_id= l_plan_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.trip_id in ( select mdl.trip_id
                      from mst_deliveries md
					  , mst_delivery_legs mdl
					  where md.plan_id = l_plan_id
					  and mdl.plan_id = md.plan_id
					  and mdl.delivery_id = md.delivery_id
					  and decode ( l_c_s_ident, 2, md.customer_id, md.supplier_id ) = l_cust_supp_id );

  cursor cur_TLs_carr (l_plan_id in number
                     , l_carrier_id in number) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.carrier_id = l_carrier_id;

begin
  if p_report_for = 0 then
    open cur_TL_stops (p_plan_id);
    fetch cur_TL_stops into l_TL_stops;
    close cur_TL_stops;

    open cur_TLs (p_plan_id);
    fetch cur_TLs into l_TLs;
    close cur_TLs;

  elsif p_report_for = 1 then
    open cur_TL_stops_myfac (p_plan_id, p_report_for_id);
    fetch cur_TL_stops_myfac into l_TL_stops;
    close cur_TL_stops_myfac;

    open cur_TLs_myfac (p_plan_id, p_report_for_id);
    fetch cur_TLs_myfac into l_TLs;
    close cur_TLs_myfac;

  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_TL_stops_c_s (p_plan_id, p_report_for, p_report_for_id);
    fetch cur_TL_stops_c_s into l_TL_stops;
    close cur_TL_stops_c_s;

    open cur_TLs_c_s (p_plan_id, p_report_for, p_report_for_id);
    fetch cur_TLs_c_s into l_TLs;
    close cur_TLs_c_s;

  elsif p_report_for = 3 then
    open cur_TL_stops_carr (p_plan_id, p_report_for_id);
    fetch cur_TL_stops_carr into l_TL_stops;
    close cur_TL_stops_carr;

    open cur_TLs_carr (p_plan_id, p_report_for_id);
    fetch cur_TLs_carr into l_TLs;
    close cur_TLs_carr;

  end if;

--handling the divide by zero problem
  if nvl(l_TLs,0) = 0 then
     l_denom := 1;
     return 0;
  else
     l_denom := l_TLs;
  end if;

--actual calculation of the KPI
  l_TL_stops_per_load := (l_TL_stops - l_TLs) / l_denom;

--resetting negative KPI value to zero
  if nvl(l_TL_stops,0) < nvl(l_TLs,0) then
    l_TL_stops_per_load := 0;
  end if;

 return l_TL_stops_per_load;
exception
when others then
	 return 0;
end get_stops_per_load;


function get_TL_distance (p_plan_id       in number
                        , p_report_for    in number
                        , p_report_for_id in number)
return number is
  l_TL_distance number;

  cursor cur_TL_distance (l_plan_id in number) is
  select nvl(sum(mt.total_trip_distance),0)
  from mst_trips mt
  where mt.plan_id= l_plan_id
  and mt.mode_of_transport = 'TRUCK';

  cursor cur_TL_distance_myfac (l_plan_id  in number
                              , l_myfac_id in number) is
/*
  select nvl(sum(mt.total_trip_distance),0)
  from mst_trips mt
  where mt.plan_id= l_plan_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.trip_id in (select distinct mts.trip_id
                     from mst_trip_stops mts
		     , fte_location_parameters flp
		     where mts.plan_id = mt.plan_id
		     and mts.stop_location_id = flp.location_id
		     and flp.facility_id = l_myfac_id);
*/
--Bug_Fix for 3696518 - II
  select nvl(sum(nvl(mt.total_trip_distance,0)),0)
  from mst_trips mt
  where mt.plan_id= l_plan_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.trip_id in ( select mdl.trip_id
                      from mst_deliveries md
					  , mst_delivery_legs mdl
					  , fte_location_parameters flp
					  where md.plan_id = l_plan_id
					  and flp.facility_id = l_myfac_id
					  and ( md.dropoff_location_id = flp.location_id
					        or md.pickup_location_id = flp.location_id )
					  and mdl.plan_id = md.plan_id
					  and mdl.delivery_id = md.delivery_id );


  cursor cur_TL_distance_c_s (l_plan_id      in number
                           , l_c_s_ident    in number
                           , l_cust_supp_id in number) is
/*
  select nvl(sum(mt.total_trip_distance),0)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_trip_stops mts
		     , mst_delivery_legs mdl
		     , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) >= 2
        group by ts.trip_id);
*/
--Bug_Fix for 3696518 - II
  select nvl(sum(nvl(mt.total_trip_distance,0)),0)
  from mst_trips mt
  where mt.plan_id= l_plan_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.trip_id in ( select mdl.trip_id
                      from mst_deliveries md
					  , mst_delivery_legs mdl
					  where md.plan_id = l_plan_id
					  and mdl.plan_id = md.plan_id
					  and mdl.delivery_id = md.delivery_id
					  and decode ( l_c_s_ident, 2, md.customer_id, md.supplier_id ) = l_cust_supp_id );

  cursor cur_TL_distance_carr (l_plan_id in number
                             , l_carrier_id in number) is
  select nvl(sum(mt.total_trip_distance),0)
  from mst_trips mt
  where mt.plan_id= l_plan_id
  and mt.mode_of_transport = 'TRUCK'
  and mt.carrier_id = l_carrier_id;

begin
  if p_report_for = 0 then
    open cur_TL_distance (p_plan_id);
    fetch cur_TL_distance into l_TL_distance;
    close cur_TL_distance;
  elsif p_report_for = 1 then
    open cur_TL_distance_myfac (p_plan_id, p_report_for_id);
    fetch cur_TL_distance_myfac into l_TL_distance;
    close cur_TL_distance_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_TL_distance_c_s (p_plan_id, p_report_for, p_report_for_id);
    fetch cur_TL_distance_c_s into l_TL_distance;
    close cur_TL_distance_c_s;
  elsif p_report_for = 3 then
    open cur_TL_distance_carr (p_plan_id, p_report_for_id);
    fetch cur_TL_distance_carr into l_TL_distance;
    close cur_TL_distance_carr;
  end if;

   return l_TL_distance;
exception
when others then
	 return 0;
end get_TL_distance;


function get_carr_movements(p_plan_id       in number
                          , p_report_for    in number
                          , p_report_for_id in number
			  , p_carrier_id    in number)
return number is
  l_carr_moves number;

  cursor cur_carr_moves (l_plan_id in number
                       , l_carrier_id in number) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.carrier_id = l_carrier_id;

  cursor cur_carr_moves_myfac (l_plan_id    in number
                             , l_myfac_id   in number
			     , l_carrier_id in number) is
/*
  select count(*)
  from mst_trips mt
  , mst_trip_stops mts
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.carrier_id = l_carrier_id
  and mts.plan_id = mt.plan_id
  and mts.trip_id = mt.trip_id
  and mts.stop_location_id = flp.location_id
  and flp.facility_id = l_myfac_id;
*/
--Bug_Fix for 3696518 - II
  select count ( distinct mt.trip_id )
  from mst_deliveries md
  , fte_location_parameters flp
  , mst_delivery_legs mdl
  , mst_trips mt
  where md.plan_id = l_plan_id
  and flp.facility_id = l_myfac_id
  and ( md.dropoff_location_id = flp.location_id
        or md.pickup_location_id = flp.location_id )
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mt.carrier_id = l_carrier_id;

  cursor cur_carr_moves_c_s (l_plan_id      in number
                           , l_c_s_ident    in number
			   , l_cust_supp_id in number
			   , l_carrier_id   in number) is
/*
  select count(mt.trip_id)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and   mt.carrier_id = l_carrier_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) >= 2
        group by ts.trip_id);
*/
--Bug_Fix for 3696518 - II
  select count ( distinct mt.trip_id )
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  where md.plan_id = l_plan_id
  and decode ( l_c_s_ident, 2, md.customer_id, md.supplier_id ) = l_cust_supp_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mt.carrier_id = l_carrier_id;

begin
  if (p_report_for = 0 OR p_report_for = 3) then
    open cur_carr_moves (p_plan_id, p_carrier_id);
    fetch cur_carr_moves into l_carr_moves;
    close cur_carr_moves;
  elsif p_report_for = 1 then
    open cur_carr_moves_myfac (p_plan_id, p_report_for_id, p_carrier_id);
    fetch cur_carr_moves_myfac into l_carr_moves;
    close cur_carr_moves_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_carr_moves_c_s (p_plan_id, p_report_for, p_report_for_id, p_carrier_id);
    fetch cur_carr_moves_c_s into l_carr_moves;
    close cur_carr_moves_c_s;
  end if;

   return l_carr_moves;
exception
when others then
	 return 0;
end get_carr_movements;


function get_carr_cost(p_plan_id       in number
                     , p_report_for    in number
                     , p_report_for_id in number
		     , p_carrier_id    in number)
return number is
  l_carr_cost number;

  cursor cur_carr_cost (l_plan_id in number
                      , l_carrier_id in number) is
  select nvl(sum(nvl(mdl.allocated_transport_cost,0)),0)
  from mst_plans mp
  , mst_delivery_legs mdl
  where mp.plan_id = mdl.plan_id
  and mdl.trip_id in (select mt.trip_id
                      from mst_trips mt
		      where mt.plan_id = mp.plan_id
		      and   mt.carrier_id = l_carrier_id)
  and mdl.plan_id = l_plan_id;

  cursor cur_carr_cost_myfac (l_plan_id    in number
                            , l_myfac_id   in number
			    , l_carrier_id in number) is
/*
  select nvl(sum(nvl(mdl.allocated_transport_cost,0)),0)
  from mst_trips mt
     , mst_trip_stops mts
     , mst_delivery_legs mdl
     , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and   mt.plan_id = mts.plan_id
  and   mt.trip_id = mts.trip_id
  and   mt.carrier_id = l_carrier_id
  and   mts.plan_id = mdl.plan_id
--  and   mdl.pick_up_stop_id = mts.stop_id
-- Bug_Fix for 3694008
  and ( mdl.pick_up_stop_id = mts.stop_id
      or mdl.drop_off_stop_id = mts.stop_id )
  and   mts.stop_location_id = flp.location_id
  and   flp.facility_id = l_myfac_id;
*/
--Bug_Fix for 3696518 - II
  select sum ( nvl ( mdl.allocated_transport_cost, 0 ) )
  from mst_deliveries md
  , fte_location_parameters flp
  , mst_delivery_legs mdl
  , mst_trips mt
  where md.plan_id = l_plan_id
  and flp.facility_id = l_myfac_id
  and ( md.dropoff_location_id = flp.location_id
        or md.pickup_location_id = flp.location_id )
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mt.carrier_id = l_carrier_id;

  cursor cur_carr_cost_c_s (l_plan_id      in number
                          , l_c_s_ident    in number
			  , l_cust_supp_id in number
			  , l_carrier_id   in number) is
/*
  select nvl(sum(nvl(mdl.allocated_transport_cost,0)),0)
  from  mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  where md.plan_id = l_plan_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and   md.plan_id = mdl.plan_id
  and   md.delivery_id = mdl.delivery_id
  and   mt.plan_id = mdl.plan_id
  and   mt.trip_id = mdl.trip_id
  and   mt.carrier_id = l_carrier_id;
*/
--Bug_Fix for 3696518 - II
  select sum ( nvl ( mdl.allocated_transport_cost, 0 ) )
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  where md.plan_id = l_plan_id
  and decode ( l_c_s_ident, 2, md.customer_id, md.supplier_id ) = l_cust_supp_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mt.carrier_id = l_carrier_id;

begin
  if (p_report_for = 0 OR p_report_for = 3) then
    open cur_carr_cost (p_plan_id, p_carrier_id);
    fetch cur_carr_cost into l_carr_cost;
    close cur_carr_cost;
  elsif p_report_for = 1 then
    open cur_carr_cost_myfac (p_plan_id, p_report_for_id, p_carrier_id);
    fetch cur_carr_cost_myfac into l_carr_cost;
    close cur_carr_cost_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_carr_cost_c_s (p_plan_id, p_report_for, p_report_for_id, p_carrier_id);
    fetch cur_carr_cost_c_s into l_carr_cost;
    close cur_carr_cost_c_s;
  end if;

   return l_carr_cost;
exception
when others then
	 return 0;
end get_carr_cost;


--originwise summary functions
--
function get_orders_orig(p_plan_id       in number
                       , p_report_for    in number
                       , p_report_for_id in number
		       , p_orig_state    in varchar2)
return number is
  l_orders_orig number;

  cursor cur_orders_orig (l_plan_id    in number
                        , l_orig_state in varchar2) is
--  select count(distinct nvl(mdd.split_from_delivery_detail_id, mdd.delivery_detail_id))
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  , wsh_locations wl
  where md.plan_id = mda.plan_id
  and   md.delivery_id = mda.delivery_id
  and   md.pickup_location_id = wl.wsh_location_id
  and   wl.state = l_orig_state
  and   mdd.plan_id = mda.plan_id
  and   mdd.delivery_detail_id = mda.delivery_detail_id
  and   mda.parent_delivery_detail_id is null
  and   md.plan_id = l_plan_id;

  cursor cur_orders_orig_myfac (l_plan_id    in number
                              , l_myfac_id   in number
			      , l_orig_state in varchar2) is
/*
--  select count(distinct nvl(mdd.split_from_delivery_detail_id, mdd.delivery_detail_id))
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  , fte_location_parameters flp
  , wsh_locations wl
  where md.plan_id = mda.plan_id
  and   md.delivery_id = mda.delivery_id
  and   md.pickup_location_id = wl.wsh_location_id
  and   wl.state = l_orig_state
  and   flp.location_id = md.pickup_location_id
  and   flp.facility_id = l_myfac_id
  and   mdd.plan_id = mda.plan_id
  and   mdd.delivery_detail_id = mda.delivery_detail_id
  and   mda.parent_delivery_detail_id is null
  and   md.plan_id = l_plan_id;
*/
--Bug_Fix for 3696518 - II
  select count(distinct mdd.source_header_number)
  from mst_delivery_assignments mda
  , mst_delivery_details mdd
  where mdd.plan_id = l_plan_id
  and mdd.plan_id = mda.plan_id
  and mdd.delivery_detail_id = mda.delivery_detail_id
  and mda.delivery_id in (select mdl.delivery_id
                         from mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts
                         , fte_location_parameters flp
                         , wsh_locations wl
                         where mdl.plan_id = l_plan_id
                         and mdl.plan_id = mts.plan_id
                         and mdl.trip_id = mts.trip_id
                         and ( mdl.pick_up_stop_id = mts.stop_id
                               or mdl.drop_off_stop_id = mts.stop_id )
                         and mts.stop_location_id = flp.location_id
                         and flp.facility_id = l_myfac_id
                         and mdl.plan_id = md.plan_id
                         and mdl.delivery_id = md.delivery_id
                         and md.pickup_location_id = wl.wsh_location_id
                         and wl.state = l_orig_state);

  cursor cur_orders_orig_c_s (l_plan_id      in number
                            , l_c_s_ident    in number
			    , l_cust_supp_id in number
			    , l_orig_state   in varchar2) is
--  select count(distinct nvl(mdd.split_from_delivery_detail_id, mdd.delivery_detail_id))
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  , wsh_locations wl
  where md.plan_id = mda.plan_id
  and   md.delivery_id = mda.delivery_id
  and   md.pickup_location_id = wl.wsh_location_id
  and   wl.state = l_orig_state
  and   mdd.plan_id = mda.plan_id
  and   mdd.delivery_detail_id = mda.delivery_detail_id
  and   mda.parent_delivery_detail_id is null
  and   md.plan_id = l_plan_id
  and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;


  cursor cur_orders_orig_carr (l_plan_id  in number
                             , l_carrier_id in number
			     , l_orig_state in varchar2) is
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
     , mst_deliveries md
     , mst_delivery_assignments mda
  where md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id
  and md.delivery_id in
        (select mdl.delivery_id
         from mst_trips t
         , mst_trip_stops ts
         , mst_delivery_legs mdl
         , wsh_locations wl
         where mdl.plan_id = md.plan_id
         and ts.plan_id  = mdl.plan_id
         and ts.stop_id  = mdl.pick_up_stop_id
	 and wl.wsh_location_id = md.pickup_location_id
         and ts.stop_location_id = wl.wsh_location_id
	 and wl.state = l_orig_state
         and ts.plan_id  = t.plan_id
         and ts.trip_id  = t.trip_id
	 and t.carrier_id = l_carrier_id)
  and   mda.plan_id = mdd.plan_id
  and   mda.delivery_detail_id = mdd.delivery_detail_id
  and   md.plan_id = l_plan_id
  and   mdd.container_flag = 2;

begin
  if p_report_for = 0 then
    open cur_orders_orig (p_plan_id, p_orig_state);
    fetch cur_orders_orig into l_orders_orig;
    close cur_orders_orig;
  elsif p_report_for = 1 then
    open cur_orders_orig_myfac (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_orders_orig_myfac into l_orders_orig;
    close cur_orders_orig_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_orders_orig_c_s (p_plan_id, p_report_for, p_report_for_id, p_orig_state);
    fetch cur_orders_orig_c_s into l_orders_orig;
    close cur_orders_orig_c_s;
  elsif p_report_for = 3 then
    open cur_orders_orig_carr (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_orders_orig_carr into l_orders_orig;
    close cur_orders_orig_carr;
  end if;

   return l_orders_orig;
exception
when others then
	 return 0;
end get_orders_orig;


function get_weight_orig(p_plan_id       in number
                       , p_report_for    in number
                       , p_report_for_id in number
		       , p_orig_state    in varchar2)
return number is
  l_weight_orig number;

  cursor cur_weight_orig (l_plan_id in number
                        , l_orig_state in varchar2) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state;

  cursor cur_weight_orig_myfac (l_plan_id    in number
                              , l_myfac_id   in number
			      , l_orig_state in varchar2) is
/*
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
  and flp.location_id = md.pickup_location_id
  and flp.facility_id = l_myfac_id;
*/
--Bug_Fix for 3696518 - II
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and md.delivery_id in (select mdl.delivery_id
                         from mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts
                         , fte_location_parameters flp
                         , wsh_locations wl
                         where mdl.plan_id = l_plan_id
                         and mdl.plan_id = mts.plan_id
                         and mdl.trip_id = mts.trip_id
                         and ( mdl.pick_up_stop_id = mts.stop_id
                               or mdl.drop_off_stop_id = mts.stop_id )
                         and mts.stop_location_id = flp.location_id
                         and flp.facility_id = l_myfac_id
                         and mdl.plan_id = md.plan_id
                         and mdl.delivery_id = md.delivery_id
                         and md.pickup_location_id = wl.wsh_location_id
                         and wl.state = l_orig_state);

  cursor cur_weight_orig_c_s (l_plan_id      in number
                            , l_c_s_ident    in number
			    , l_cust_supp_id in number
			    , l_orig_state   in varchar2) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_weight_orig_carr (l_plan_id       in number
                             , l_carrier_id    in number
			     , l_orig_state    in varchar2) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 0 then
    open cur_weight_orig (p_plan_id, p_orig_state);
    fetch cur_weight_orig into l_weight_orig;
    close cur_weight_orig;
  elsif p_report_for = 1 then
    open cur_weight_orig_myfac (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_weight_orig_myfac into l_weight_orig;
    close cur_weight_orig_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_weight_orig_c_s (p_plan_id, p_report_for, p_report_for_id, p_orig_state);
    fetch cur_weight_orig_c_s into l_weight_orig;
    close cur_weight_orig_c_s;
  elsif p_report_for = 3 then
    open cur_weight_orig_carr (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_weight_orig_carr into l_weight_orig;
    close cur_weight_orig_carr;
  end if;

   return l_weight_orig;
exception
when others then
	 return 0;
end get_weight_orig;


function get_volume_orig(p_plan_id       in number
                       , p_report_for    in number
                       , p_report_for_id in number
		       , p_orig_state    in varchar2)
return number is
  l_volume_orig number;

  cursor cur_volume_orig (l_plan_id in number
                        , l_orig_state in varchar2) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state;

  cursor cur_volume_orig_myfac (l_plan_id    in number
                              , l_myfac_id   in number
			      , l_orig_state in varchar2) is
/*
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
  and flp.location_id = md.pickup_location_id
  and flp.facility_id = l_myfac_id;
*/
--Bug_Fix for 3693518
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and md.delivery_id in (select mdl.delivery_id
                         from mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts
                         , fte_location_parameters flp
                         , wsh_locations wl
                         where mdl.plan_id = l_plan_id
                         and mdl.plan_id = mts.plan_id
                         and mdl.trip_id = mts.trip_id
                         and ( mdl.pick_up_stop_id = mts.stop_id
                               or mdl.drop_off_stop_id = mts.stop_id )
                         and mts.stop_location_id = flp.location_id
                         and flp.facility_id = l_myfac_id
                         and mdl.plan_id = md.plan_id
                         and mdl.delivery_id = md.delivery_id
                         and md.pickup_location_id = wl.wsh_location_id
                         and wl.state = l_orig_state);

  cursor cur_volume_orig_c_s (l_plan_id      in number
                            , l_c_s_ident    in number
			    , l_cust_supp_id in number
			    , l_orig_state   in varchar2) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_volume_orig_carr (l_plan_id       in number
                             , l_carrier_id    in number
			     , l_orig_state    in varchar2) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 0 then
    open cur_volume_orig (p_plan_id, p_orig_state);
    fetch cur_volume_orig into l_volume_orig;
    close cur_volume_orig;
  elsif p_report_for = 1 then
    open cur_volume_orig_myfac (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_volume_orig_myfac into l_volume_orig;
    close cur_volume_orig_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_volume_orig_c_s (p_plan_id, p_report_for, p_report_for_id, p_orig_state);
    fetch cur_volume_orig_c_s into l_volume_orig;
    close cur_volume_orig_c_s;
  elsif p_report_for = 3 then
    open cur_volume_orig_carr (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_volume_orig_carr into l_volume_orig;
    close cur_volume_orig_carr;
  end if;

   return l_volume_orig;
exception
when others then
	 return 0;
end get_volume_orig;


function get_pieces_orig(p_plan_id       in number
                       , p_report_for    in number
                       , p_report_for_id in number
		       , p_orig_state    in varchar2)
return number is
  l_pieces_orig number;

  cursor cur_pieces_orig (l_plan_id in number
                        , l_orig_state in varchar2) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state;

  cursor cur_pieces_orig_myfac (l_plan_id    in number
                              , l_myfac_id   in number
			      , l_orig_state in varchar2) is
/*
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
  and flp.location_id = md.pickup_location_id
  and flp.facility_id = l_myfac_id;
*/
--Bug_Fix for 3696518
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and md.delivery_id in (select mdl.delivery_id
                         from mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts
                         , fte_location_parameters flp
                         , wsh_locations wl
                         where mdl.plan_id = l_plan_id
                         and mdl.plan_id = mts.plan_id
                         and mdl.trip_id = mts.trip_id
                         and ( mdl.pick_up_stop_id = mts.stop_id
                               or mdl.drop_off_stop_id = mts.stop_id )
                         and mts.stop_location_id = flp.location_id
                         and flp.facility_id = l_myfac_id
                         and mdl.plan_id = md.plan_id
                         and mdl.delivery_id = md.delivery_id
                         and md.pickup_location_id = wl.wsh_location_id
                         and wl.state = l_orig_state);

  cursor cur_pieces_orig_c_s (l_plan_id      in number
                            , l_c_s_ident    in number
			    , l_cust_supp_id in number
			    , l_orig_state   in varchar2) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_pieces_orig_carr (l_plan_id       in number
                             , l_carrier_id    in number
			     , l_orig_state    in varchar2) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 0 then
    open cur_pieces_orig (p_plan_id, p_orig_state);
    fetch cur_pieces_orig into l_pieces_orig;
    close cur_pieces_orig;
  elsif p_report_for = 1 then
    open cur_pieces_orig_myfac (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_pieces_orig_myfac into l_pieces_orig;
    close cur_pieces_orig_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_pieces_orig_c_s (p_plan_id, p_report_for, p_report_for_id, p_orig_state);
    fetch cur_pieces_orig_c_s into l_pieces_orig;
    close cur_pieces_orig_c_s;
  elsif p_report_for = 3 then
    open cur_pieces_orig_carr (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_pieces_orig_carr into l_pieces_orig;
    close cur_pieces_orig_carr;
  end if;

   return l_pieces_orig;
exception
when others then
	 return 0;
end get_pieces_orig;


function get_MTL_orig(p_plan_id       in number
                    , p_report_for    in number
                    , p_report_for_id in number
		    , p_orig_state    in varchar2)
return number is
  l_MTL_orig number;

  cursor cur_MTL_orig (l_plan_id in number
                     , l_orig_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.pick_up_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.pickup_location_id
			   and wl.state = l_orig_state)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops > 2;

  cursor cur_MTL_orig_myfac (l_plan_id    in number
                           , l_myfac_id   in number
		           , l_orig_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
                           , fte_location_parameters flp
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.pick_up_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.pickup_location_id
			   and wl.state = l_orig_state
                           and flp.location_id = mts1.stop_location_id
                           and flp.facility_id = l_myfac_id)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops > 2;

  cursor cur_MTL_orig_c_s (l_plan_id      in number
                         , l_c_s_ident    in number
		         , l_cust_supp_id in number
			 , l_orig_state   in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	and mt.trip_id in
	          (select distinct mdl.trip_id
	           from mst_deliveries md
		   , mst_delivery_legs mdl
		   , mst_trip_stops mts1
		   , wsh_locations wl
		   where mdl.plan_id = mt.plan_id
		   and mdl.pick_up_stop_id = mts1.stop_id
		   and mdl.trip_id = mts1.trip_id
		   and mts1.plan_id = mt.plan_id
		   and mts1.stop_location_id = wl.wsh_location_id
		   and mts1.stop_location_id = md.pickup_location_id
		   and wl.state = l_orig_state
		   and md.plan_id = mdl.plan_id
		   and md.delivery_id = mdl.delivery_id
                   and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id)
	group by mt.trip_id) temp
  where temp.num_stops > 2;

  cursor cur_MTL_orig_carr (l_plan_id in number
                          , l_carrier_id in number
                          , l_orig_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.carrier_id = l_carrier_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.pick_up_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.pickup_location_id
			   and wl.state = l_orig_state)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops > 2;

begin
  if p_report_for = 0 then
    open cur_MTL_orig (p_plan_id, p_orig_state);
    fetch cur_MTL_orig into l_MTL_orig;
    close cur_MTL_orig;
  elsif p_report_for = 1 then
    open cur_MTL_orig_myfac (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_MTL_orig_myfac into l_MTL_orig;
    close cur_MTL_orig_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_MTL_orig_c_s (p_plan_id, p_report_for, p_report_for_id, p_orig_state);
    fetch cur_MTL_orig_c_s into l_MTL_orig;
    close cur_MTL_orig_c_s;
  elsif p_report_for = 3 then
    open cur_MTL_orig_carr (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_MTL_orig_carr into l_MTL_orig;
    close cur_MTL_orig_carr;
  end if;

   return l_MTL_orig;
exception
when others then
	 return 0;
end get_MTL_orig;


function get_DTL_orig(p_plan_id       in number
                    , p_report_for    in number
                    , p_report_for_id in number
		    , p_orig_state    in varchar2)
return number is
  l_DTL_orig number;

  cursor cur_DTL_orig (l_plan_id in number
                     , l_orig_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.pick_up_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.pickup_location_id
			   and wl.state = l_orig_state)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops = 2;

  cursor cur_DTL_orig_myfac (l_plan_id    in number
                           , l_myfac_id   in number
		           , l_orig_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
                           , fte_location_parameters flp
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.pick_up_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.pickup_location_id
			   and wl.state = l_orig_state
                           and flp.location_id = mts1.stop_location_id
                           and flp.facility_id = l_myfac_id)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops = 2;

  cursor cur_DTL_orig_c_s (l_plan_id      in number
                         , l_c_s_ident    in number
		         , l_cust_supp_id in number
			 , l_orig_state   in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	and mt.trip_id in
	          (select distinct mdl.trip_id
	           from mst_deliveries md
		   , mst_delivery_legs mdl
		   , mst_trip_stops mts1
		   , wsh_locations wl
		   where mdl.plan_id = mt.plan_id
		   and mdl.pick_up_stop_id = mts1.stop_id
		   and mdl.trip_id = mts1.trip_id
		   and mts1.plan_id = mt.plan_id
		   and mts1.stop_location_id = wl.wsh_location_id
		   and mts1.stop_location_id = md.pickup_location_id
		   and wl.state = l_orig_state
		   and md.plan_id = mdl.plan_id
		   and md.delivery_id = mdl.delivery_id
                   and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id)
	group by mt.trip_id) temp
  where temp.num_stops = 2;

  cursor cur_DTL_orig_carr (l_plan_id in number
                          , l_carrier_id in number
                          , l_orig_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.carrier_id = l_carrier_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.pick_up_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.pickup_location_id
			   and wl.state = l_orig_state)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops = 2;

begin
  if p_report_for = 0 then
    open cur_DTL_orig (p_plan_id, p_orig_state);
    fetch cur_DTL_orig into l_DTL_orig;
    close cur_DTL_orig;
  elsif p_report_for = 1 then
    open cur_DTL_orig_myfac (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_DTL_orig_myfac into l_DTL_orig;
    close cur_DTL_orig_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_DTL_orig_c_s (p_plan_id, p_report_for, p_report_for_id, p_orig_state);
    fetch cur_DTL_orig_c_s into l_DTL_orig;
    close cur_DTL_orig_c_s;
  elsif p_report_for = 3 then
    open cur_DTL_orig_carr (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_DTL_orig_carr into l_DTL_orig;
    close cur_DTL_orig_carr;
  end if;

   return l_DTL_orig;
exception
when others then
	 return 0;
end get_DTL_orig;


function get_LTL_orig(p_plan_id       in number
                    , p_report_for    in number
                    , p_report_for_id in number
		    , p_orig_state    in varchar2)
return number is
  l_LTL_orig number;

  cursor cur_LTL_orig (l_plan_id in number
                     , l_orig_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'LTL'
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
		     and mdl.plan_id = md.plan_id
		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.pick_up_stop_id
 	 	     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.pickup_location_id
		     and wl.state = l_orig_state);

  cursor cur_LTL_orig_myfac (l_plan_id    in number
                           , l_myfac_id   in number
		           , l_orig_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'LTL'
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , fte_location_parameters flp
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
		     and mdl.plan_id = md.plan_id
		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.pick_up_stop_id
	 	     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.pickup_location_id
		     and wl.state = l_orig_state
		     and flp.location_id = mts1.stop_location_id
		     and flp.facility_id = l_myfac_id);

  cursor cur_LTL_orig_c_s (l_plan_id      in number
                         , l_c_s_ident    in number
		         , l_cust_supp_id in number
			 , l_orig_state   in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'LTL'
  and mt.trip_id in
	          (select distinct mdl.trip_id
	           from mst_deliveries md
		   , mst_delivery_legs mdl
		   , mst_trip_stops mts1
		   , wsh_locations wl
		   where mdl.plan_id = mt.plan_id
		   and mdl.pick_up_stop_id = mts1.stop_id
		   and mdl.trip_id = mts1.trip_id
		   and mts1.plan_id = mt.plan_id
		   and mts1.stop_location_id = wl.wsh_location_id
		   and mts1.stop_location_id = md.pickup_location_id
		   and wl.state = l_orig_state
		   and md.plan_id = mdl.plan_id
		   and md.delivery_id = mdl.delivery_id
                   and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id);

  cursor cur_LTL_orig_carr (l_plan_id in number
                          , l_carrier_id in number
                          , l_orig_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'LTL'
  and mt.carrier_id = l_carrier_id
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
		     and mdl.plan_id = md.plan_id
		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.pick_up_stop_id
 	 	     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.pickup_location_id
		     and wl.state = l_orig_state);
begin
  if p_report_for = 0 then
    open cur_LTL_orig (p_plan_id, p_orig_state);
    fetch cur_LTL_orig into l_LTL_orig;
    close cur_LTL_orig;
  elsif p_report_for = 1 then
    open cur_LTL_orig_myfac (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_LTL_orig_myfac into l_LTL_orig;
    close cur_LTL_orig_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_LTL_orig_c_s (p_plan_id, p_report_for, p_report_for_id, p_orig_state);
    fetch cur_LTL_orig_c_s into l_LTL_orig;
    close cur_LTL_orig_c_s;
  elsif p_report_for = 3 then
    open cur_LTL_orig_carr (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_LTL_orig_carr into l_LTL_orig;
    close cur_LTL_orig_carr;
  end if;

   return l_LTL_orig;
exception
when others then
	 return 0;
end get_LTL_orig;


function get_PCL_orig(p_plan_id       in number
                    , p_report_for    in number
                    , p_report_for_id in number
		    , p_orig_state    in varchar2)
return number is
  l_PCL_orig number;

  cursor cur_PCL_orig (l_plan_id in number
                     , l_orig_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'PARCEL'
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
		     and mdl.plan_id = md.plan_id
		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.pick_up_stop_id
		     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.pickup_location_id
		     and wl.state = l_orig_state);

  cursor cur_PCL_orig_myfac (l_plan_id    in number
                           , l_myfac_id   in number
		           , l_orig_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'PARCEL'
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , fte_location_parameters flp
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
		     and mdl.plan_id = md.plan_id
		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.pick_up_stop_id
		     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.pickup_location_id
		     and wl.state = l_orig_state
		     and flp.location_id = mts1.stop_location_id
		     and flp.facility_id = l_myfac_id);

  cursor cur_PCL_orig_c_s (l_plan_id      in number
                         , l_c_s_ident    in number
		         , l_cust_supp_id in number
			 , l_orig_state   in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'PARCEL'
  and mt.trip_id in
	          (select distinct mdl.trip_id
	           from mst_deliveries md
		   , mst_delivery_legs mdl
		   , mst_trip_stops mts1
		   , wsh_locations wl
		   where mdl.plan_id = mt.plan_id
		   and mdl.pick_up_stop_id = mts1.stop_id
		   and mdl.trip_id = mts1.trip_id
		   and mts1.plan_id = mt.plan_id
		   and mts1.stop_location_id = wl.wsh_location_id
		   and mts1.stop_location_id = md.pickup_location_id
		   and wl.state = l_orig_state
		   and md.plan_id = mdl.plan_id
		   and md.delivery_id = mdl.delivery_id
                   and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id);

  cursor cur_PCL_orig_carr (l_plan_id in number
                          , l_carrier_id in number
                          , l_orig_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'PARCEL'
  and mt.carrier_id = l_carrier_id
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
		     and mdl.plan_id = md.plan_id
		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.pick_up_stop_id
		     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.pickup_location_id
		     and wl.state = l_orig_state);
begin
  if p_report_for = 0 then
    open cur_PCL_orig (p_plan_id, p_orig_state);
    fetch cur_PCL_orig into l_PCL_orig;
    close cur_PCL_orig;
  elsif p_report_for = 1 then
    open cur_PCL_orig_myfac (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_PCL_orig_myfac into l_PCL_orig;
    close cur_PCL_orig_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_PCL_orig_c_s (p_plan_id, p_report_for, p_report_for_id, p_orig_state);
    fetch cur_PCL_orig_c_s into l_PCL_orig;
    close cur_PCL_orig_c_s;
  elsif p_report_for = 3 then
    open cur_PCL_orig_carr (p_plan_id, p_report_for_id, p_orig_state);
    fetch cur_PCL_orig_carr into l_PCL_orig;
    close cur_PCL_orig_carr;
  end if;

   return l_PCL_orig;
exception
when others then
	 return 0;
end get_PCL_orig;


function get_total_cost_mode_orig (p_plan_id       in number
                                 , p_report_for    in number
      		                 , p_report_for_id in number
		                 , p_mode          in varchar2
				 , p_orig_state     in varchar2)
return number is
  l_total_cost_per_mode number;

  cursor cur_total_cost (l_plan_id   in number
                       , l_mode      in varchar2
		       , l_orig_state in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
		   , wsh_locations wl
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
	        and   mts.stop_location_id = wl.wsh_location_id
	        and   wl.state = l_orig_state
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   md.pickup_location_id = mts.stop_location_id);
*/
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
--  , mst_trip_stops mts
  , wsh_locations wl
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and wl.state = l_orig_state
  and md.pickup_location_id = wl.wsh_location_id );
/*
  and mts.stop_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
  and mt.plan_id = mts.plan_id
  and mt.trip_id = mts.trip_id
  and md.pickup_location_id = mts.stop_location_id);
*/


  cursor cur_total_cost_myfac (l_plan_id   in number
                             , l_myfac_id  in number
                             , l_mode      in varchar2
			     , l_orig_state in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
		   , fte_location_parameters flp
		   , wsh_locations wl
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = flp.location_id
                and   flp.facility_id = l_myfac_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   md.pickup_location_id = flp.location_id
	        and   flp.location_id = wl.wsh_location_id
	        and   wl.state = l_orig_state);
*/
/*
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
--  , mst_trip_stops mts
  , wsh_locations wl
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
--  and mts.stop_location_id = wl.wsh_location_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
--  and mt.plan_id = mts.plan_id
--  and mt.trip_id = mts.trip_id
  and flp.facility_id = l_myfac_id
  and md.pickup_location_id = flp.location_id );
--  and md.pickup_location_id = mts.stop_location_id );
*/
--Bug_Fix for 3696518 - II
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  , mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.delivery_id in (select mdl.delivery_id
                         from mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts
                         , fte_location_parameters flp
                         , wsh_locations wl
                         where mdl.plan_id = l_plan_id
                         and mdl.plan_id = mts.plan_id
                         and mdl.trip_id = mts.trip_id
                         and ( mdl.pick_up_stop_id = mts.stop_id
                               or mdl.drop_off_stop_id = mts.stop_id )
                         and mts.stop_location_id = flp.location_id
                         and flp.facility_id = l_myfac_id
                         and mdl.plan_id = md.plan_id
                         and mdl.delivery_id = md.delivery_id
                         and md.pickup_location_id = wl.wsh_location_id
                         and wl.state = l_orig_state);

  cursor cur_total_cost_c_s (l_plan_id      in number
                           , l_c_s_ident    in number
                           , l_cust_supp_id in number
			   , l_mode         in varchar2
			   , l_orig_state    in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from mst_trips mt
                , mst_trip_stops mts
                , mst_delivery_legs mdl1
                , mst_deliveries md
		, wsh_locations wl
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = wl.wsh_location_id
	        and   wl.state = l_orig_state
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                and   md.pickup_location_id = mts.stop_location_id);
*/
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
--  , mst_trip_stops mts
  , wsh_locations wl
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
--  and mts.stop_location_id = wl.wsh_location_id
  and md.pickup_location_id = wl.wsh_location_id
  and wl.state = l_orig_state
--  and mt.plan_id = mts.plan_id
--  and mt.trip_id = mts.trip_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id );
--  and md.pickup_location_id = mts.stop_location_id );


  cursor cur_total_cost_carr (l_plan_id   in number
                            , l_carrier_id in number
                            , l_mode      in varchar2
		            , l_orig_state in varchar2) is
/*
  select nvl(sum(decode(mt.mode_of_transport
                       , 'TRUCK', (nvl(mt.total_basic_transport_cost,0)
                                 + nvl(mt.total_stop_cost,0)
		                 + nvl(mt.total_load_unload_cost,0)
			         + nvl(mt.total_layover_cost,0)
			         + nvl(mt.total_accessorial_cost,0)
			         + nvl(mt.total_handling_cost,0))
		       , (nvl(mt.total_basic_transport_cost,0)
		        + nvl(mt.total_accessorial_cost,0)))),0)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.carrier_id = l_carrier_id
  and mt.mode_of_transport = l_mode
--  and mt.continuous_move_id is null --check
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    , wsh_locations wl
                    where md.plan_id = mt.plan_id
                    and mts.plan_id = md.plan_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
		    and mts.stop_id = mdl.pick_up_stop_id
                    and mts.stop_location_id = md.pickup_location_id
		    and wl.wsh_location_id = mts.stop_location_id
		    and wl.state = l_orig_state);
*/
	select  nvl ( sum(nvl(mdl.allocated_fac_loading_cost,0)
        	  + nvl(mdl.allocated_fac_unloading_cost,0)
	          + nvl(mdl.allocated_fac_shp_hand_cost,0)
                  + nvl(mdl.allocated_fac_rec_hand_cost,0)
    	  	  + nvl(mdl.allocated_transport_cost,0)), 0 )
	from  mst_deliveries md
	, mst_delivery_legs mdl
	, mst_trips mt
	, wsh_locations wl
	, mst_trip_stops mts
	where md.plan_id = l_plan_id
	and md.plan_id = mt.plan_id
	and md.plan_id = mdl.plan_id
	and md.plan_id = mts.plan_id
	and md.delivery_id = mdl.delivery_id
	and mt.trip_id = mdl.trip_id
	and mt.carrier_id = l_carrier_id
	and mt.mode_of_transport = l_mode
	and mts.trip_id = mt.trip_id
	and mts.stop_location_id = wl.wsh_location_id
	and mdl.pick_up_stop_id = mts.stop_id
	and wl.state = l_orig_state;
begin
  if p_report_for = 0 then
    open cur_total_cost (p_plan_id, p_mode, p_orig_state);
    fetch cur_total_cost into l_total_cost_per_mode;
    close cur_total_cost;
  elsif p_report_for = 1 then
    open cur_total_cost_myfac (p_plan_id, p_report_for_id, p_mode, p_orig_state);
    fetch cur_total_cost_myfac into l_total_cost_per_mode;
    close cur_total_cost_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_total_cost_c_s (p_plan_id, p_report_for, p_report_for_id, p_mode, p_orig_state);
    fetch cur_total_cost_c_s into l_total_cost_per_mode;
    close cur_total_cost_c_s;
  elsif p_report_for = 3 then
    open cur_total_cost_carr (p_plan_id, p_report_for_id, p_mode, p_orig_state);
    fetch cur_total_cost_carr into l_total_cost_per_mode;
    close cur_total_cost_carr;
  end if;

   return nvl ( l_total_cost_per_mode, 0 );
exception
when others then
	 return 0;
end get_total_cost_mode_orig;


function get_orders_dest(p_plan_id           in number
                       , p_report_for        in number
                       , p_report_for_id     in number
		       , p_destination_state    in varchar2)
return number is
  l_orders_dest number;

  cursor cur_orders_dest (l_plan_id        in number
                        , l_destination_state in varchar2) is
--  select count(distinct nvl(mdd.split_from_delivery_detail_id, mdd.delivery_detail_id))
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  , wsh_locations wl
  where md.plan_id = mda.plan_id
  and   md.delivery_id = mda.delivery_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state
  and   mdd.plan_id = mda.plan_id
  and   mdd.delivery_detail_id = mda.delivery_detail_id
  and   mda.parent_delivery_detail_id is null
  and   md.plan_id = l_plan_id;

  cursor cur_orders_dest_myfac (l_plan_id        in number
                              , l_myfac_id       in number
			      , l_destination_state in varchar2) is
/*
--  select count(distinct nvl(mdd.split_from_delivery_detail_id, mdd.delivery_detail_id))
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  , fte_location_parameters flp
  , wsh_locations wl
  where md.plan_id = mda.plan_id
  and   md.delivery_id = mda.delivery_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state
  and   flp.location_id = md.dropoff_location_id
  and   flp.facility_id = l_myfac_id
  and   mdd.plan_id = mda.plan_id
  and   mdd.delivery_detail_id = mda.delivery_detail_id
  and   mda.parent_delivery_detail_id is null
  and   md.plan_id = l_plan_id;
*/
--Bug_Fix for 3696518 - II
  select count(distinct mdd.source_header_number)
  from mst_delivery_assignments mda
  , mst_delivery_details mdd
  where mdd.plan_id = l_plan_id
  and mdd.plan_id = mda.plan_id
  and mdd.delivery_detail_id = mda.delivery_detail_id
  and mda.delivery_id in (select mdl.delivery_id
                         from mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts
                         , fte_location_parameters flp
                         , wsh_locations wl
                         where mdl.plan_id = l_plan_id
                         and mdl.plan_id = mts.plan_id
                         and mdl.trip_id = mts.trip_id
                         and ( mdl.pick_up_stop_id = mts.stop_id
                               or mdl.drop_off_stop_id = mts.stop_id )
                         and mts.stop_location_id = flp.location_id
                         and flp.facility_id = l_myfac_id
                         and mdl.plan_id = md.plan_id
                         and mdl.delivery_id = md.delivery_id
                         and md.dropoff_location_id = wl.wsh_location_id
                         and wl.state = l_destination_state);

  cursor cur_orders_dest_c_s (l_plan_id          in number
                            , l_c_s_ident        in number
			    , l_cust_supp_id     in number
			    , l_destination_state   in varchar2) is
--  select count(distinct nvl(mdd.split_from_delivery_detail_id, mdd.delivery_detail_id))
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  , wsh_locations wl
  where md.plan_id = mda.plan_id
  and   md.delivery_id = mda.delivery_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state
  and   mdd.plan_id = mda.plan_id
  and   mdd.delivery_detail_id = mda.delivery_detail_id
  and   mda.parent_delivery_detail_id is null
  and   md.plan_id = l_plan_id
  and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_orders_dest_carr (l_plan_id  in number
                             , l_carrier_id in number
			     , l_destination_state in varchar2) is
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
     , mst_deliveries md
     , mst_delivery_assignments mda
  where md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id
  and md.delivery_id in
        (select mdl.delivery_id
         from mst_trips t
         , mst_trip_stops ts
         , mst_delivery_legs mdl
         , wsh_locations wl
         where mdl.plan_id = md.plan_id
         and ts.plan_id  = mdl.plan_id
         and ts.stop_id  = mdl.drop_off_stop_id
	 and wl.wsh_location_id = md.dropoff_location_id
         and ts.stop_location_id = wl.wsh_location_id
	 and wl.state = l_destination_state
         and ts.plan_id  = t.plan_id
         and ts.trip_id  = t.trip_id
	 and t.carrier_id = l_carrier_id)
  and   mda.plan_id = mdd.plan_id
  and   mda.delivery_detail_id = mdd.delivery_detail_id
  and   md.plan_id = l_plan_id
  and   mdd.container_flag = 2;

begin
  if p_report_for = 0 then
    open cur_orders_dest (p_plan_id, p_destination_state);
    fetch cur_orders_dest into l_orders_dest;
    close cur_orders_dest;
  elsif p_report_for = 1 then
    open cur_orders_dest_myfac (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_orders_dest_myfac into l_orders_dest;
    close cur_orders_dest_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_orders_dest_c_s (p_plan_id, p_report_for, p_report_for_id, p_destination_state);
    fetch cur_orders_dest_c_s into l_orders_dest;
    close cur_orders_dest_c_s;
  elsif p_report_for = 3 then
    open cur_orders_dest_carr (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_orders_dest_carr into l_orders_dest;
    close cur_orders_dest_carr;
  end if;

   return l_orders_dest;
exception
when others then
	 return 0;
end get_orders_dest;


function get_weight_dest(p_plan_id           in number
                       , p_report_for        in number
                       , p_report_for_id     in number
		       , p_destination_state    in varchar2)
return number is
  l_weight_dest number;

  cursor cur_weight_dest (l_plan_id        in number
                        , l_destination_state in varchar2) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state;

  cursor cur_weight_dest_myfac (l_plan_id        in number
                              , l_myfac_id       in number
			      , l_destination_state in varchar2) is
/*
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state
  and flp.location_id = md.dropoff_location_id
  and flp.facility_id = l_myfac_id;
*/
--Bug_Fix for 3696518 - II
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and md.delivery_id in (select mdl.delivery_id
                         from mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts
                         , fte_location_parameters flp
                         , wsh_locations wl
                         where mdl.plan_id = l_plan_id
                         and mdl.plan_id = mts.plan_id
                         and mdl.trip_id = mts.trip_id
                         and ( mdl.pick_up_stop_id = mts.stop_id
                               or mdl.drop_off_stop_id = mts.stop_id )
                         and mts.stop_location_id = flp.location_id
                         and flp.facility_id = l_myfac_id
                         and mdl.plan_id = md.plan_id
                         and mdl.delivery_id = md.delivery_id
                         and md.dropoff_location_id = wl.wsh_location_id
                         and wl.state = l_destination_state);

  cursor cur_weight_dest_c_s (l_plan_id          in number
                            , l_c_s_ident        in number
			    , l_cust_supp_id     in number
			    , l_destination_state   in varchar2) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_weight_dest_carr (l_plan_id       in number
                             , l_carrier_id    in number
			     , l_destination_state    in varchar2) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.dropoff_location_id = wl.wsh_location_id
  and wl.state = l_destination_state
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 0 then
    open cur_weight_dest (p_plan_id, p_destination_state);
    fetch cur_weight_dest into l_weight_dest;
    close cur_weight_dest;
  elsif p_report_for = 1 then
    open cur_weight_dest_myfac (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_weight_dest_myfac into l_weight_dest;
    close cur_weight_dest_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_weight_dest_c_s (p_plan_id, p_report_for, p_report_for_id, p_destination_state);
    fetch cur_weight_dest_c_s into l_weight_dest;
    close cur_weight_dest_c_s;
  elsif p_report_for = 3 then
    open cur_weight_dest_carr (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_weight_dest_carr into l_weight_dest;
    close cur_weight_dest_carr;
  end if;

   return l_weight_dest;
exception
when others then
	 return 0;
end get_weight_dest;


function get_volume_dest(p_plan_id           in number
                       , p_report_for        in number
                       , p_report_for_id     in number
		       , p_destination_state    in varchar2)
return number is
  l_volume_dest number;

  cursor cur_volume_dest (l_plan_id        in number
                        , l_destination_state in varchar2) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state;

  cursor cur_volume_dest_myfac (l_plan_id        in number
                              , l_myfac_id       in number
			      , l_destination_state in varchar2) is
/*
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state
  and flp.location_id = md.dropoff_location_id
  and flp.facility_id = l_myfac_id;
*/
--Bug_Fix for 3696518 - II
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and md.delivery_id in (select mdl.delivery_id
                         from mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts
                         , fte_location_parameters flp
                         , wsh_locations wl
                         where mdl.plan_id = l_plan_id
                         and mdl.plan_id = mts.plan_id
                         and mdl.trip_id = mts.trip_id
                         and ( mdl.pick_up_stop_id = mts.stop_id
                               or mdl.drop_off_stop_id = mts.stop_id )
                         and mts.stop_location_id = flp.location_id
                         and flp.facility_id = l_myfac_id
                         and mdl.plan_id = md.plan_id
                         and mdl.delivery_id = md.delivery_id
                         and md.dropoff_location_id = wl.wsh_location_id
                         and wl.state = l_destination_state);

  cursor cur_volume_dest_c_s (l_plan_id          in number
                            , l_c_s_ident        in number
			    , l_cust_supp_id     in number
			    , l_destination_state   in varchar2) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_volume_dest_carr (l_plan_id       in number
                             , l_carrier_id    in number
			     , l_destination_state    in varchar2) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.dropoff_location_id = wl.wsh_location_id
  and wl.state = l_destination_state
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 0 then
    open cur_volume_dest (p_plan_id, p_destination_state);
    fetch cur_volume_dest into l_volume_dest;
    close cur_volume_dest;
  elsif p_report_for = 1 then
    open cur_volume_dest_myfac (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_volume_dest_myfac into l_volume_dest;
    close cur_volume_dest_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_volume_dest_c_s (p_plan_id, p_report_for, p_report_for_id, p_destination_state);
    fetch cur_volume_dest_c_s into l_volume_dest;
    close cur_volume_dest_c_s;
  elsif p_report_for = 3 then
    open cur_volume_dest_carr (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_volume_dest_carr into l_volume_dest;
    close cur_volume_dest_carr;
  end if;

   return l_volume_dest;
exception
when others then
	 return 0;
end get_volume_dest;


function get_pieces_dest(p_plan_id           in number
                       , p_report_for        in number
                       , p_report_for_id     in number
		       , p_destination_state    in varchar2)
return number is
  l_pieces_dest number;

  cursor cur_pieces_dest (l_plan_id        in number
                        , l_destination_state in varchar2) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state;

  cursor cur_pieces_dest_myfac (l_plan_id        in number
                              , l_myfac_id       in number
			      , l_destination_state in varchar2) is
/*
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state
  and flp.location_id = md.dropoff_location_id
  and flp.facility_id = l_myfac_id;
*/
--Bug_Fix for 3696518 - II
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and md.delivery_id in (select mdl.delivery_id
                         from mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts
                         , fte_location_parameters flp
                         , wsh_locations wl
                         where mdl.plan_id = l_plan_id
                         and mdl.plan_id = mts.plan_id
                         and mdl.trip_id = mts.trip_id
                         and ( mdl.pick_up_stop_id = mts.stop_id
                               or mdl.drop_off_stop_id = mts.stop_id )
                         and mts.stop_location_id = flp.location_id
                         and flp.facility_id = l_myfac_id
                         and mdl.plan_id = md.plan_id
                         and mdl.delivery_id = md.delivery_id
                         and md.dropoff_location_id = wl.wsh_location_id
                         and wl.state = l_destination_state);

  cursor cur_pieces_dest_c_s (l_plan_id          in number
                            , l_c_s_ident        in number
			    , l_cust_supp_id     in number
			    , l_destination_state   in varchar2) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and   md.dropoff_location_id = wl.wsh_location_id
  and   wl.state = l_destination_state
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_pieces_dest_carr (l_plan_id       in number
                             , l_carrier_id    in number
			     , l_destination_state    in varchar2) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  , wsh_locations wl
  where md.plan_id = l_plan_id
  and md.dropoff_location_id = wl.wsh_location_id
  and wl.state = l_destination_state
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 0 then
    open cur_pieces_dest (p_plan_id, p_destination_state);
    fetch cur_pieces_dest into l_pieces_dest;
    close cur_pieces_dest;
  elsif p_report_for = 1 then
    open cur_pieces_dest_myfac (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_pieces_dest_myfac into l_pieces_dest;
    close cur_pieces_dest_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_pieces_dest_c_s (p_plan_id, p_report_for, p_report_for_id, p_destination_state);
    fetch cur_pieces_dest_c_s into l_pieces_dest;
    close cur_pieces_dest_c_s;
  elsif p_report_for = 3 then
    open cur_pieces_dest_carr (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_pieces_dest_carr into l_pieces_dest;
    close cur_pieces_dest_carr;
  end if;

   return l_pieces_dest;
exception
when others then
	 return 0;
end get_pieces_dest;


function get_MTL_dest(p_plan_id           in number
                    , p_report_for        in number
                    , p_report_for_id     in number
		    , p_destination_state    in varchar2)
return number is
  l_MTL_dest number;

  cursor cur_MTL_dest (l_plan_id        in number
                     , l_destination_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.drop_off_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.dropoff_location_id
			   and wl.state = l_destination_state)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops > 2;

  cursor cur_MTL_dest_myfac (l_plan_id        in number
                           , l_myfac_id       in number
		           , l_destination_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
                           , fte_location_parameters flp
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.drop_off_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.dropoff_location_id
			   and wl.state = l_destination_state
                           and flp.location_id = mts1.stop_location_id
                           and flp.facility_id = l_myfac_id)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops > 2;

  cursor cur_MTL_dest_c_s (l_plan_id          in number
                         , l_c_s_ident        in number
		         , l_cust_supp_id     in number
			 , l_destination_state   in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	and mt.trip_id in
	          (select distinct mdl.trip_id
	           from mst_deliveries md
		   , mst_delivery_legs mdl
		   , mst_trip_stops mts1
		   , wsh_locations wl
		   where mdl.plan_id = mt.plan_id
		   and mdl.drop_off_stop_id = mts1.stop_id
		   and mdl.trip_id = mts1.trip_id
		   and mts1.plan_id = mt.plan_id
		   and mts1.stop_location_id = wl.wsh_location_id
		   and mts1.stop_location_id = md.dropoff_location_id
		   and wl.state = l_destination_state
		   and md.plan_id = mdl.plan_id
		   and md.delivery_id = mdl.delivery_id
                   and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id)
	group by mt.trip_id) temp
  where temp.num_stops > 2;

  cursor cur_MTL_dest_carr (l_plan_id        in number
                          , l_carrier_id     in number
                          , l_destination_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.carrier_id = l_carrier_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.drop_off_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.dropoff_location_id
			   and wl.state = l_destination_state)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops > 2;
begin
  if p_report_for = 0 then
    open cur_MTL_dest (p_plan_id, p_destination_state);
    fetch cur_MTL_dest into l_MTL_dest;
    close cur_MTL_dest;
  elsif p_report_for = 1 then
    open cur_MTL_dest_myfac (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_MTL_dest_myfac into l_MTL_dest;
    close cur_MTL_dest_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_MTL_dest_c_s (p_plan_id, p_report_for, p_report_for_id, p_destination_state);
    fetch cur_MTL_dest_c_s into l_MTL_dest;
    close cur_MTL_dest_c_s;
  elsif p_report_for = 3 then
    open cur_MTL_dest_carr (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_MTL_dest_carr into l_MTL_dest;
    close cur_MTL_dest_carr;
  end if;

   return l_MTL_dest;
exception
when others then
	 return 0;
end get_MTL_dest;


function get_DTL_dest(p_plan_id           in number
                    , p_report_for        in number
                    , p_report_for_id     in number
		    , p_destination_state    in varchar2)
return number is
  l_DTL_dest number;

  cursor cur_DTL_dest (l_plan_id        in number
                     , l_destination_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.drop_off_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.dropoff_location_id
			   and wl.state = l_destination_state)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops = 2;

  cursor cur_DTL_dest_myfac (l_plan_id        in number
                           , l_myfac_id       in number
		           , l_destination_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
                           , fte_location_parameters flp
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.drop_off_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.dropoff_location_id
			   and wl.state = l_destination_state
                           and flp.location_id = mts1.stop_location_id
                           and flp.facility_id = l_myfac_id)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops = 2;

  cursor cur_DTL_dest_c_s (l_plan_id          in number
                         , l_c_s_ident        in number
		         , l_cust_supp_id     in number
			 , l_destination_state   in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	and mt.trip_id in
	          (select distinct mdl.trip_id
	           from mst_deliveries md
		   , mst_delivery_legs mdl
		   , mst_trip_stops mts1
		   , wsh_locations wl
		   where mdl.plan_id = mt.plan_id
		   and mdl.drop_off_stop_id = mts1.stop_id
		   and mdl.trip_id = mts1.trip_id
		   and mts1.plan_id = mt.plan_id
		   and mts1.stop_location_id = wl.wsh_location_id
		   and mts1.stop_location_id = md.dropoff_location_id
		   and wl.state = l_destination_state
		   and md.plan_id = mdl.plan_id
		   and md.delivery_id = mdl.delivery_id
                   and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id)
	group by mt.trip_id) temp
  where temp.num_stops = 2;

  cursor cur_DTL_dest_carr (l_plan_id        in number
                          , l_carrier_id in number
                          , l_destination_state in varchar2) is
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.carrier_id = l_carrier_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
			   , wsh_locations wl
			   where md.plan_id = mt.plan_id
			   and mdl.plan_id = md.plan_id
			   and mdl.delivery_id = md.delivery_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
			   and mts1.stop_id = mdl.drop_off_stop_id
			   and mts1.stop_location_id = wl.wsh_location_id
			   and mts1.stop_location_id = md.dropoff_location_id
			   and wl.state = l_destination_state)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops = 2;

begin
  if p_report_for = 0 then
    open cur_DTL_dest (p_plan_id, p_destination_state);
    fetch cur_DTL_dest into l_DTL_dest;
    close cur_DTL_dest;
  elsif p_report_for = 1 then
    open cur_DTL_dest_myfac (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_DTL_dest_myfac into l_DTL_dest;
    close cur_DTL_dest_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_DTL_dest_c_s (p_plan_id, p_report_for, p_report_for_id, p_destination_state);
    fetch cur_DTL_dest_c_s into l_DTL_dest;
    close cur_DTL_dest_c_s;
  elsif p_report_for = 3 then
    open cur_DTL_dest_carr (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_DTL_dest_carr into l_DTL_dest;
    close cur_DTL_dest_carr;
  end if;

   return l_DTL_dest;
exception
when others then
	 return 0;
end get_DTL_dest;


function get_LTL_dest(p_plan_id           in number
                    , p_report_for        in number
                    , p_report_for_id     in number
		    , p_destination_state    in varchar2)
return number is
  l_LTL_dest number;

  cursor cur_LTL_dest (l_plan_id        in number
                     , l_destination_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'LTL'
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
		     and mdl.plan_id = md.plan_id
		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.drop_off_stop_id
		     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.dropoff_location_id
		     and wl.state = l_destination_state);

  cursor cur_LTL_dest_myfac (l_plan_id        in number
                           , l_myfac_id       in number
		           , l_destination_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'LTL'
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , fte_location_parameters flp
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
		     and mdl.plan_id = md.plan_id
		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.drop_off_stop_id
		     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.dropoff_location_id
		     and wl.state = l_destination_state
		     and flp.location_id = mts1.stop_location_id
		     and flp.facility_id = l_myfac_id);

  cursor cur_LTL_dest_c_s (l_plan_id          in number
                         , l_c_s_ident        in number
		         , l_cust_supp_id     in number
			 , l_destination_state   in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'LTL'
  and mt.trip_id in
	          (select distinct mdl.trip_id
	           from mst_deliveries md
		   , mst_delivery_legs mdl
		   , mst_trip_stops mts1
		   , wsh_locations wl
		   where mdl.plan_id = mt.plan_id
		   and mdl.drop_off_stop_id = mts1.stop_id
		   and mdl.trip_id = mts1.trip_id
		   and mts1.plan_id = mt.plan_id
		   and mts1.stop_location_id = wl.wsh_location_id
		   and mts1.stop_location_id = md.dropoff_location_id
		   and wl.state = l_destination_state
		   and md.plan_id = mdl.plan_id
		   and md.delivery_id = mdl.delivery_id
                   and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id);

  cursor cur_LTL_dest_carr (l_plan_id        in number
                          , l_carrier_id in number
                          , l_destination_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'LTL'
  and mt.carrier_id = l_carrier_id
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
		     and mdl.plan_id = md.plan_id
		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.drop_off_stop_id
		     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.dropoff_location_id
		     and wl.state = l_destination_state);
begin
  if p_report_for = 0 then
    open cur_LTL_dest (p_plan_id, p_destination_state);
    fetch cur_LTL_dest into l_LTL_dest;
    close cur_LTL_dest;
  elsif p_report_for = 1 then
    open cur_LTL_dest_myfac (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_LTL_dest_myfac into l_LTL_dest;
    close cur_LTL_dest_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_LTL_dest_c_s (p_plan_id, p_report_for, p_report_for_id, p_destination_state);
    fetch cur_LTL_dest_c_s into l_LTL_dest;
    close cur_LTL_dest_c_s;
  elsif p_report_for = 3 then
    open cur_LTL_dest_carr (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_LTL_dest_carr into l_LTL_dest;
    close cur_LTL_dest_carr;
  end if;

   return l_LTL_dest;
exception
when others then
	 return 0;
end get_LTL_dest;


function get_PCL_dest(p_plan_id           in number
                    , p_report_for        in number
                    , p_report_for_id     in number
		    , p_destination_state    in varchar2)
return number is
  l_PCL_dest number;

  cursor cur_PCL_dest (l_plan_id        in number
                     , l_destination_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'PARCEL'
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
		     and mdl.plan_id = md.plan_id
		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.drop_off_stop_id
		     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.dropoff_location_id
		     and wl.state = l_destination_state);

  cursor cur_PCL_dest_myfac (l_plan_id        in number
                           , l_myfac_id       in number
		           , l_destination_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'PARCEL'
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , fte_location_parameters flp
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
 	             and mdl.plan_id = md.plan_id
  		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.drop_off_stop_id
		     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.dropoff_location_id
		     and wl.state = l_destination_state
		     and flp.location_id = mts1.stop_location_id
		     and flp.facility_id = l_myfac_id);

  cursor cur_PCL_dest_c_s (l_plan_id          in number
                         , l_c_s_ident        in number
		         , l_cust_supp_id     in number
			 , l_destination_state   in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'PARCEL'
  and mt.trip_id in
	          (select distinct mdl.trip_id
	           from mst_deliveries md
		   , mst_delivery_legs mdl
		   , mst_trip_stops mts1
		   , wsh_locations wl
		   where mdl.plan_id = mt.plan_id
		   and mdl.drop_off_stop_id = mts1.stop_id
		   and mdl.trip_id = mts1.trip_id
		   and mts1.plan_id = mt.plan_id
		   and mts1.stop_location_id = wl.wsh_location_id
		   and mts1.stop_location_id = md.dropoff_location_id
		   and wl.state = l_destination_state
		   and md.plan_id = mdl.plan_id
		   and md.delivery_id = mdl.delivery_id
                   and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id);

  cursor cur_PCL_dest_carr (l_plan_id        in number
                          , l_carrier_id     in number
                          , l_destination_state in varchar2) is
  select count(*)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = 'PARCEL'
  and mt.carrier_id = l_carrier_id
  and mt.trip_id in (select distinct mdl.trip_id
                     from mst_deliveries md
		     , mst_delivery_legs mdl
                     , mst_trip_stops mts1
		     , wsh_locations wl
		     where md.plan_id = mt.plan_id
		     and mdl.plan_id = md.plan_id
		     and mdl.delivery_id = md.delivery_id
                     and mts1.plan_id = mdl.plan_id
		     and mts1.trip_id = mdl.trip_id
		     and mts1.stop_id = mdl.drop_off_stop_id
		     and mts1.stop_location_id = wl.wsh_location_id
		     and mts1.stop_location_id = md.dropoff_location_id
		     and wl.state = l_destination_state);
begin
  if p_report_for = 0 then
    open cur_PCL_dest (p_plan_id, p_destination_state);
    fetch cur_PCL_dest into l_PCL_dest;
    close cur_PCL_dest;
  elsif p_report_for = 1 then
    open cur_PCL_dest_myfac (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_PCL_dest_myfac into l_PCL_dest;
    close cur_PCL_dest_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_PCL_dest_c_s (p_plan_id, p_report_for, p_report_for_id, p_destination_state);
    fetch cur_PCL_dest_c_s into l_PCL_dest;
    close cur_PCL_dest_c_s;
  elsif p_report_for = 3 then
    open cur_PCL_dest_carr (p_plan_id, p_report_for_id, p_destination_state);
    fetch cur_PCL_dest_carr into l_PCL_dest;
    close cur_PCL_dest_carr;
  end if;

   return l_PCL_dest;
exception
when others then
	 return 0;
end get_PCL_dest;


function get_total_cost_mode_dest (p_plan_id            in number
                                 , p_report_for         in number
      		                 , p_report_for_id      in number
		                 , p_mode               in varchar2
				 , p_destination_state     in varchar2)
return number is
  l_total_cost_per_mode number;

  cursor cur_total_cost (l_plan_id        in number
                       , l_mode           in varchar2
		       , l_destination_state in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
		   , wsh_locations wl
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
	        and   mts.stop_location_id = wl.wsh_location_id
	        and   wl.state = l_destination_state
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   md.dropoff_location_id = mts.stop_location_id);
*/
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
--  , mst_trip_stops mts
  , wsh_locations wl
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and wl.state = l_destination_state
  and md.dropoff_location_id = wl.wsh_location_id );
/*
  and mts.stop_location_id = wl.wsh_location_id
  and wl.state = l_destination_state
  and mt.plan_id = mts.plan_id
  and mt.trip_id = mts.trip_id
  and md.dropoff_location_id = mts.stop_location_id);
*/

  cursor cur_total_cost_myfac (l_plan_id        in number
                             , l_myfac_id       in number
                             , l_mode           in varchar2
			     , l_destination_state in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
		   , fte_location_parameters flp
		   , wsh_locations wl
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = flp.location_id
                and   flp.facility_id = l_myfac_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   md.dropoff_location_id = flp.location_id
		and   flp.location_id = wl.wsh_location_id
		and   wl.state = l_destination_state);
*/
/*
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
--  , mst_trip_stops mts
  , wsh_locations wl
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
--  and mts.stop_location_id = wl.wsh_location_id
  and wl.state = l_destination_state
  and md.dropoff_location_id = wsh_location_id
--  and mt.plan_id = mts.plan_id
--  and mt.trip_id = mts.trip_id
  and flp.facility_id = l_myfac_id
  and md.dropoff_location_id = flp.location_id );
--  and md.dropoff_location_id = mts.stop_location_id );
*/
--Bug_Fix for 3696518 - II
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  , mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.delivery_id in (select mdl.delivery_id
                         from mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts
                         , fte_location_parameters flp
                         , wsh_locations wl
                         where mdl.plan_id = l_plan_id
                         and mdl.plan_id = mts.plan_id
                         and mdl.trip_id = mts.trip_id
                         and ( mdl.pick_up_stop_id = mts.stop_id
                               or mdl.drop_off_stop_id = mts.stop_id )
                         and mts.stop_location_id = flp.location_id
                         and flp.facility_id = l_myfac_id
                         and mdl.plan_id = md.plan_id
                         and mdl.delivery_id = md.delivery_id
                         and md.dropoff_location_id = wl.wsh_location_id
                         and wl.state = l_destination_state);

  cursor cur_total_cost_c_s (l_plan_id      in number
                           , l_c_s_ident         in number
                           , l_cust_supp_id      in number
			   , l_mode              in varchar2
			   , l_destination_state    in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from mst_trips mt
                , mst_trip_stops mts
                , mst_delivery_legs mdl1
                , mst_deliveries md
		, wsh_locations wl
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = wl.wsh_location_id
	        and   wl.state = l_destination_state
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                and   md.dropoff_location_id = mts.stop_location_id);
*/
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
--  , mst_trip_stops mts
  , wsh_locations wl
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
--  and mts.stop_location_id = wl.wsh_location_id
  and wl.state = l_destination_state
  and md.dropoff_location_id = wl.wsh_location_id
--  and mt.plan_id = mts.plan_id
--  and mt.trip_id = mts.trip_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id );
--  and md.dropoff_location_id = mts.stop_location_id );


  cursor cur_total_cost_carr (l_plan_id        in number
                            , l_carrier_id     in number
                            , l_mode           in varchar2
		            , l_destination_state in varchar2) is
/*
  select nvl(sum(decode(mt.mode_of_transport
                       , 'TRUCK', (nvl(mt.total_basic_transport_cost,0)
                                 + nvl(mt.total_stop_cost,0)
		                 + nvl(mt.total_load_unload_cost,0)
			         + nvl(mt.total_layover_cost,0)
			         + nvl(mt.total_accessorial_cost,0)
			         + nvl(mt.total_handling_cost,0))
		       , (nvl(mt.total_basic_transport_cost,0)
		        + nvl(mt.total_accessorial_cost,0)))),0)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.carrier_id = l_carrier_id
  and mt.mode_of_transport = l_mode
--  and mt.continuous_move_id is null --check
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    , wsh_locations wl
                    where md.plan_id = mt.plan_id
                    and mts.plan_id = md.plan_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mts.stop_id = mdl.drop_off_stop_id
                    and mts.stop_location_id = md.dropoff_location_id
		    and wl.wsh_location_id = mts.stop_location_id
		    and wl.state = l_destination_state);
*/
	select  nvl ( sum(nvl(mdl.allocated_fac_loading_cost,0)
        	+ nvl(mdl.allocated_fac_unloading_cost,0)
                + nvl(mdl.allocated_fac_shp_hand_cost,0)
	        + nvl(mdl.allocated_fac_rec_hand_cost,0)
    	        + nvl(mdl.allocated_transport_cost,0)), 0 )
	from  mst_deliveries md
	, mst_delivery_legs mdl
	, mst_trips mt
	, wsh_locations wl
	, mst_trip_stops mts
	where md.plan_id = l_plan_id
	and md.plan_id = mt.plan_id
	and md.plan_id = mdl.plan_id
	and md.plan_id = mts.plan_id
	and md.delivery_id = mdl.delivery_id
	and mt.trip_id = mdl.trip_id
	and mt.carrier_id = l_carrier_id
	and mt.mode_of_transport = l_mode
	and mts.trip_id = mt.trip_id
	and mts.stop_location_id = wl.wsh_location_id
	and mdl.drop_off_stop_id = mts.stop_id
	and wl.state = l_destination_state;
begin
  if p_report_for = 0 then
    open cur_total_cost (p_plan_id, p_mode, p_destination_state);
    fetch cur_total_cost into l_total_cost_per_mode;
    close cur_total_cost;
  elsif p_report_for = 1 then
    open cur_total_cost_myfac (p_plan_id, p_report_for_id, p_mode, p_destination_state);
    fetch cur_total_cost_myfac into l_total_cost_per_mode;
    close cur_total_cost_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_total_cost_c_s (p_plan_id, p_report_for, p_report_for_id, p_mode, p_destination_state);
    fetch cur_total_cost_c_s into l_total_cost_per_mode;
    close cur_total_cost_c_s;
  elsif p_report_for = 3 then
    open cur_total_cost_carr (p_plan_id, p_report_for_id, p_mode, p_destination_state);
    fetch cur_total_cost_carr into l_total_cost_per_mode;
    close cur_total_cost_carr;
  end if;

   return nvl ( l_total_cost_per_mode, 0 );
exception
when others then
	 return 0;
end get_total_cost_mode_dest;


-- Myfac related functions

function get_orders_myfac (p_plan_id       in number
                         , p_report_for    in number
			 , p_report_for_id in number
			 , p_myfac_id      in number)
return number is
  l_orders number;

  cursor cur_plan_orders_myfac (l_plan_id  in number
                              , l_myfac_id in number) is
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
     , mst_deliveries md
     , mst_delivery_assignments mda
  where md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id
  and md.delivery_id in
        (select mdl.delivery_id
         from -- mst_trips t -- Removing the join with mst_trips
            mst_trip_stops ts
            , mst_delivery_legs mdl
            , fte_location_parameters flp
         where mdl.plan_id = md.plan_id
         and ts.plan_id  = mdl.plan_id
--         and ts.stop_id  = mdl.pick_up_stop_id
-- Bug_Fix for 3693945
         and ( ts.stop_id = mdl.pick_up_stop_id
             or ts.stop_id = mdl.drop_off_stop_id )
         and ts.stop_location_id = flp.location_id
	 and flp.facility_id = l_myfac_id ) -- ending the subquery here, with the join with mst_trips removed
--         and ts.plan_id  = t.plan_id
--         and ts.trip_id  = t.trip_id)
  and   mda.plan_id = mdd.plan_id
  and   mda.delivery_detail_id = mdd.delivery_detail_id
  and   md.plan_id = l_plan_id
  and   mdd.container_flag = 2;
--  and   mdd.split_from_delivery_detail_id is null;


  --considering both assigned and unassigned deliveries
  cursor cur_plan_orders_c_s (l_plan_id      in number
                            , l_myfac_id     in number
                            , l_c_s_ident    in number
                            , l_cust_supp_id in number) is
  select count(distinct dd.source_header_number)
  from (
        select mdd.source_header_number
        from mst_delivery_details mdd
           , mst_deliveries md
           , mst_delivery_assignments mda
        where md.plan_id = mda.plan_id
        and   md.delivery_id = mda.delivery_id
        and   mda.plan_id = mdd.plan_id
        and   mda.delivery_detail_id = mdd.delivery_detail_id
        and   md.plan_id = l_plan_id
        and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
        and   md.delivery_id in
                    (select mdl.delivery_id
                     from  mst_delivery_legs mdl
                         , mst_trip_stops mts
			 , fte_location_parameters flp
                     where mdl.plan_id = md.plan_id
                     and   mdl.plan_id = mts.plan_id
                     and ( mdl.pick_up_stop_id = mts.stop_id
                          or mdl.drop_off_stop_id = mts.stop_id)
		     and   flp.location_id = mts.stop_location_id
		     and   flp.facility_id = l_myfac_id)
  union all
  select mdd.source_header_number
  from mst_delivery_details mdd
     , mst_deliveries md
     , mst_delivery_assignments mda
  where md.plan_id = mda.plan_id
  and   md.delivery_id = mda.delivery_id
  and   mda.plan_id = mdd.plan_id
  and   mda.delivery_detail_id = mdd.delivery_detail_id
  and   md.plan_id = l_plan_id
  and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and   not exists (select 1 from mst_delivery_legs mdl
                    where mdl.plan_id=md.plan_id
                    and   mdl.delivery_id = md.delivery_id)) dd;

  cursor cur_plan_orders_carr (l_plan_id  in number
                             , l_myfac_id in number
                             , l_carrier_id in number) is
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
     , mst_deliveries md
     , mst_delivery_assignments mda
  where md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id
  and md.delivery_id in
        (select mdl.delivery_id
         from mst_trips t
            , mst_trip_stops ts
            , mst_delivery_legs mdl
            , fte_location_parameters flp
         where mdl.plan_id = md.plan_id
         and ts.plan_id  = mdl.plan_id
--         and ts.stop_id  = mdl.pick_up_stop_id
-- Bug_Fix for 3693945
         and ( ts.stop_id = mdl.pick_up_stop_id
             or ts.stop_id = mdl.drop_off_stop_id )
         and ts.stop_location_id = flp.location_id
	 and flp.facility_id = l_myfac_id
         and ts.plan_id  = t.plan_id
         and ts.trip_id  = t.trip_id
	 and t.carrier_id = l_carrier_id)
  and   mda.plan_id = mdd.plan_id
  and   mda.delivery_detail_id = mdd.delivery_detail_id
  and   md.plan_id = l_plan_id
  and   mdd.container_flag = 2;

begin
  if (p_report_for = 0 or p_report_for = 1) then
    open cur_plan_orders_myfac (p_plan_id, p_myfac_id);
    fetch cur_plan_orders_myfac into l_orders;
    close cur_plan_orders_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_plan_orders_c_s (p_plan_id, p_myfac_id, p_report_for, p_report_for_id);
    fetch cur_plan_orders_c_s into l_orders;
    close cur_plan_orders_c_s;
  elsif p_report_for = 3 then
    open cur_plan_orders_carr (p_plan_id, p_myfac_id, p_report_for_id);
    fetch cur_plan_orders_carr into l_orders;
    close cur_plan_orders_carr;
  end if;

  return l_orders;
exception
when others then
	 return 0;
end get_orders_myfac;


-- Weight KPI
function get_weight_myfac (p_plan_id       in number
                         , p_report_for    in number
   	  	         , p_report_for_id in number
		         , p_myfac_id      in number)
return number is
  l_weight number;

  cursor cur_weight_myfac (l_plan_id  in number
                         , l_myfac_id in number) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
     , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id;


  cursor cur_weight_c_s (l_plan_id      in number
                       , l_myfac_id     in number
                       , l_c_s_ident    in number
  		       , l_cust_supp_id in number) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_weight_carr (l_plan_id       in number
                        , l_myfac_id      in number
                        , l_carrier_id    in number) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if (p_report_for = 0 or p_report_for =1) then
    open cur_weight_myfac (p_plan_id, p_myfac_id);
    fetch cur_weight_myfac into l_weight;
    close cur_weight_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_weight_c_s (p_plan_id, p_myfac_id, p_report_for, p_report_for_id);
    fetch cur_weight_c_s into l_weight;
    close cur_weight_c_s;
  elsif p_report_for = 3 then
    open cur_weight_carr (p_plan_id, p_myfac_id, p_report_for_id);
    fetch cur_weight_carr into l_weight;
    close cur_weight_carr;
  end if;

return l_weight;
exception
when others then
	 return 0;
end get_weight_myfac;


-- Volums KPI
function get_volume_myfac (p_plan_id       in number
                         , p_report_for    in number
		         , p_report_for_id in number
			 , p_myfac_id      in number)
return number is
  l_volume number;

  cursor cur_volume_myfac (l_plan_id  in number
                         , l_myfac_id in number) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
     , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id;


  cursor cur_volume_c_s (l_plan_id      in number
                       , l_myfac_id     in number
                       , l_c_s_ident    in number
  		       , l_cust_supp_id in number) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_volume_carr (l_plan_id       in number
                        , l_myfac_id      in number
                        , l_carrier_id    in number) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if (p_report_for = 0 OR p_report_for = 1) then
    open cur_volume_myfac (p_plan_id, p_myfac_id);
    fetch cur_volume_myfac into l_volume;
    close cur_volume_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_volume_c_s (p_plan_id, p_myfac_id, p_report_for, p_report_for_id);
    fetch cur_volume_c_s into l_volume;
    close cur_volume_c_s;
  elsif p_report_for = 3 then
    open cur_volume_carr (p_plan_id, p_myfac_id, p_report_for_id);
    fetch cur_volume_carr into l_volume;
    close cur_volume_carr;
  end if;

return l_volume;
exception
when others then
	 return 0;
end get_volume_myfac;


-- Pieces KPI
function get_pieces_myfac (p_plan_id       in number
                         , p_report_for    in number
		         , p_report_for_id in number
			 , p_myfac_id      in number)
return number is
  l_pieces number;

  cursor cur_pieces_myfac (l_plan_id  in number
                         , l_myfac_id in number) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
     , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id;


  cursor cur_pieces_c_s (l_plan_id      in number
                       , l_myfac_id     in number
                       , l_c_s_ident    in number
  		       , l_cust_supp_id in number) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_pieces_carr (l_plan_id       in number
                        , l_myfac_id      in number
                        , l_carrier_id    in number) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if (p_report_for = 0 OR p_report_for = 1) then
    open cur_pieces_myfac (p_plan_id, p_myfac_id);
    fetch cur_pieces_myfac into l_pieces;
    close cur_pieces_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_pieces_c_s (p_plan_id, p_myfac_id, p_report_for, p_report_for_id);
    fetch cur_pieces_c_s into l_pieces;
    close cur_pieces_c_s;
  elsif p_report_for = 3 then
    open cur_pieces_carr (p_plan_id, p_myfac_id, p_report_for_id);
    fetch cur_pieces_carr into l_pieces;
    close cur_pieces_carr;
  end if;

return l_pieces;
exception
when others then
	 return 0;
end get_pieces_myfac;


function get_trips_per_mode_myfac (p_plan_id       in number
                                 , p_report_for    in number
		                 , p_report_for_id in number
			         , p_mode          in varchar2
			         , p_myfac_id      in number)
return number is
  l_trips_per_mode number;

  cursor cur_trips_myfac (l_plan_id  in number
                        , l_myfac_id in number
			, l_mode     in varchar2) is
  select count(*)
  from mst_trips mt
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and flp.location_id in (select mts.stop_location_id
                          from mst_trip_stops mts
			  where mts.plan_id = mt.plan_id
			  and mts.trip_id = mt.trip_id)
  and flp.facility_id = l_myfac_id;

  cursor cur_trips_c_s (l_plan_id      in number
                      , l_myfac_id     in number
                      , l_c_s_ident    in number
                      , l_cust_supp_id in number
		      , l_mode         in varchar2) is
  select count(mt.trip_id)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
		    , fte_location_parameters flp
                    where md.plan_id = mt.plan_id
                    and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
		    and flp.location_id = mts.stop_location_id
		    and flp.facility_id = l_myfac_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   mt.mode_of_transport = l_mode
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) >= 2
        group by ts.trip_id);

  cursor cur_trips_carr (l_plan_id  in number
                       , l_myfac_id in number
		       , l_carrier_id in number
		       , l_mode     in varchar2) is
  select count(*)
  from mst_trips mt
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.carrier_id = l_carrier_id
  and flp.location_id in (select mts.stop_location_id
                          from mst_trip_stops mts
			  where mts.plan_id = mt.plan_id
			  and mts.trip_id = mt.trip_id)
  and flp.facility_id = l_myfac_id;
begin
  if (p_report_for = 0 OR p_report_for = 1) then
    open cur_trips_myfac (p_plan_id, p_myfac_id, p_mode);
    fetch cur_trips_myfac into l_trips_per_mode;
    close cur_trips_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_trips_c_s (p_plan_id, p_myfac_id, p_report_for, p_report_for_id, p_mode);
    fetch cur_trips_c_s into l_trips_per_mode;
    close cur_trips_c_s;
  elsif p_report_for = 3 then
    open cur_trips_carr (p_plan_id, p_myfac_id, p_report_for_id, p_mode);
    fetch cur_trips_carr into l_trips_per_mode;
    close cur_trips_carr;
  end if;

   return l_trips_per_mode;
exception
when others then
	 return 0;
end get_trips_per_mode_myfac;


function get_cost_per_mode_myfac (p_plan_id         in number
                                  , p_report_for    in number
         	                  , p_report_for_id in number
		                  , p_mode          in varchar2
				  , p_myfac_id      in number)
return number is
  l_total_cost_per_mode number;
  l_total_cost_per_mode_cd number;
  l_total_cost number;
  l_loc_id number;

  cursor cur_total_cost_myfac (l_plan_id  in number
                             , l_myfac_id in number
                             , l_mode     in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
		   , fte_location_parameters flp
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = flp.location_id
                and   flp.facility_id = l_myfac_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   (md.pickup_location_id = flp.location_id
                       or md.dropoff_location_id = flp.location_id));
*/
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and flp.facility_id = l_myfac_id
  and ( md.pickup_location_id = flp.location_id
        or md.dropoff_location_id = flp.location_id ) );

  cursor cur_total_cost_c_s (l_plan_id      in number
                           , l_myfac_id     in number
                           , l_c_s_ident    in number
                           , l_cust_supp_id in number
			   , l_mode         in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
		   , fte_location_parameters flp
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = flp.location_id
		and   flp.facility_id = l_myfac_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                and   (md.pickup_location_id = flp.location_id
		       or md.dropoff_location_id = flp.location_id));
*/
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and flp.facility_id = l_myfac_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and ( md.pickup_location_id = flp.location_id
        or md.dropoff_location_id = flp.location_id ) );

/*  cursor cur_total_cost_carr (l_plan_id      in number
                            , l_myfac_id     in number
                            , l_carrier_id   in number
			    , l_mode         in varchar2) is
  select nvl(sum(decode(mt.mode_of_transport
                       , 'TRUCK', (nvl(mt.total_basic_transport_cost,0)
                                 + nvl(mt.total_stop_cost,0)
		                 + nvl(mt.total_load_unload_cost,0)
			         + nvl(mt.total_layover_cost,0)
			         + nvl(mt.total_accessorial_cost,0)
			         + nvl(mt.total_handling_cost,0))
		       , (nvl(mt.total_basic_transport_cost,0)
		        + nvl(mt.total_accessorial_cost,0)))),0)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.carrier_id = l_carrier_id
  and mt.mode_of_transport = l_mode
--  and mt.continuous_move_id is null  --check
  and mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    , fte_location_parameters flp
                    where md.plan_id = mt.plan_id
                    and mts.plan_id = md.plan_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mts.stop_location_id = flp.location_id
		    and (md.pickup_location_id = flp.location_id
		        or md.dropoff_location_id = flp.location_id)
		    and flp.facility_id = l_myfac_id);
*/
cursor cur_total_cost_carr (l_plan_id      in number
                            , l_location_id     in number
                            , l_carrier_id   in number
			    , l_mode         in varchar2) is
/*
 select sum(nvl(mdl.allocated_fac_loading_cost,0)  +
            nvl(mdl.allocated_transport_cost,0)    +
            nvl(mdl.allocated_fac_shp_hand_cost,0)  )
 from mst_delivery_legs mdl
 where mdl.plan_id = l_plan_id
 and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1,
                     mst_deliveries md,
                     mst_trips mt,
                     mst_trip_stops mts
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   mt.carrier_id = l_carrier_id
                and   mts.stop_location_id = l_location_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and  (  md.pickup_location_id = mts.stop_location_id
                     or md.dropoff_location_id = mts.stop_location_id));
*/
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  , mst_trip_stops mts
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mt.carrier_id = l_carrier_id
  and mts.stop_location_id = l_location_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and mt.plan_id = mts.plan_id
  and mt.trip_id = mts.trip_id
  and ( md.pickup_location_id = mts.stop_location_id
        or md.dropoff_location_id = mts.stop_location_id ) );

-- for cross dock cost calculation
  cursor cur_total_cost_carr_cd (l_plan_id      in number
                            , l_location_id     in number
                            , l_carrier_id   in number
			    , l_mode         in varchar2) is
/*
  select sum(nvl(mdl.allocated_fac_loading_cost,0)  +
             nvl(mdl.allocated_transport_cost,0)    +
             nvl(mdl.allocated_fac_shp_hand_cost,0)  )
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1,
                     mst_deliveries md,
                     mst_trips mt,
                     mst_trip_stops mts
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
		and   mt.carrier_id = l_carrier_id
                and   mts.stop_location_id = l_location_id
                and   (mts.stop_id = mdl.pick_up_stop_id
                      or mts.stop_id = mdl.drop_off_stop_id)
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   md.pickup_location_id <> mts.stop_location_id
                and   md.dropoff_location_id <> mts.stop_location_id);
*/
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  , mst_trip_stops mts
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mt.carrier_id = l_carrier_id
  and mts.stop_location_id = l_location_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and mt.plan_id = mts.plan_id
  and mt.trip_id = mts.trip_id
  and ( mts.stop_id = mdl.pick_up_stop_id
        or mts.stop_id = mdl.drop_off_stop_id )
  and md.pickup_location_id <> mts.stop_location_id
  and md.dropoff_location_id <> mts.stop_location_id );

begin
  if (p_report_for = 0 OR p_report_for = 1) then
    open cur_total_cost_myfac (p_plan_id, p_myfac_id, p_mode);
    fetch cur_total_cost_myfac into l_total_cost_per_mode;
    close cur_total_cost_myfac;
  elsif (p_report_for = 2 OR p_report_for = 4) then
    open cur_total_cost_c_s (p_plan_id, p_myfac_id, p_report_for, p_report_for_id, p_mode);
    fetch cur_total_cost_c_s into l_total_cost_per_mode;
    close cur_total_cost_c_s;
  elsif p_report_for = 3 then
    --get the facility location
    select flp.location_id
    into l_loc_id
    from fte_location_parameters flp
    where flp.facility_id = p_myfac_id;
    open cur_total_cost_carr (p_plan_id, l_loc_id, p_report_for_id, p_mode);
    fetch cur_total_cost_carr into l_total_cost;
    close cur_total_cost_carr;
    open cur_total_cost_carr_cd (p_plan_id, l_loc_id, p_report_for_id, p_mode);
    fetch cur_total_cost_carr_cd into l_total_cost_per_mode_cd;
    close cur_total_cost_carr_cd;
    l_total_cost_per_mode := nvl(l_total_cost,0) + nvl(l_total_cost_per_mode_cd, 0);
  end if;

   return l_total_cost_per_mode;
exception
when others then
	 return 0;
end get_cost_per_mode_myfac;


-- customer/supplier related functions
function get_orders_c_s (p_plan_id       in number
                       , p_report_for    in number
		       , p_report_for_id in number
		       , p_c_s_ident     in number
		       , p_cust_supp_id  in number)
return number is
  l_plan_order_count number;

  cursor cur_plan_orders_myfac (l_plan_id      in number
                              , l_c_s_ident    in number
			      , l_cust_supp_id in number
                              , l_myfac_id     in number) is
  select count(distinct mdd.source_header_number)
  from mst_delivery_details mdd
     , mst_deliveries md
     , mst_delivery_assignments mda
  where md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and md.delivery_id in
        (select mdl.delivery_id
         from -- mst_trips t -- removing this join
              mst_trip_stops ts
            , mst_delivery_legs mdl
            , fte_location_parameters flp
         where mdl.plan_id = md.plan_id
         and ts.plan_id  = mdl.plan_id
--         and ts.stop_id  = mdl.pick_up_stop_id
-- Bug_Fix for 3694008
         and ( ts.stop_id = mdl.pick_up_stop_id
             or ts.stop_id = mdl.drop_off_stop_id )
         and ts.stop_location_id = flp.location_id
	 and flp.facility_id = l_myfac_id ) -- end of subquery, as the join with t has been removed
         -- and ts.plan_id  = t.plan_id
         -- and ts.trip_id  = t.trip_id)
  and   mda.plan_id = mdd.plan_id
  and   mda.delivery_detail_id = mdd.delivery_detail_id
  and   md.plan_id = l_plan_id
  and   mdd.container_flag = 2
  and   mdd.split_from_delivery_detail_id is null;


  --considering both assigned and unassigned deliveries
  cursor cur_plan_orders_c_s (l_plan_id       in number
  			    , l_report_for    in number
  			    , l_report_for_id in number
                            , l_c_s_ident     in number
                            , l_cust_supp_id  in number) is
  select count(distinct dd.source_header_number)
  from (
        select mdd.source_header_number
        from mst_delivery_details mdd
           , mst_deliveries md
           , mst_delivery_assignments mda
        where md.plan_id = mda.plan_id
        and   md.delivery_id = mda.delivery_id
        and   mda.plan_id = mdd.plan_id
        and   mda.delivery_detail_id = mdd.delivery_detail_id
        and   md.plan_id = l_plan_id
        and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
	and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
        and   md.delivery_id in
                    (select mdl.delivery_id
                     from  mst_delivery_legs mdl
                         , mst_trip_stops mts
                     where mdl.plan_id = md.plan_id
                     and   mdl.plan_id = mts.plan_id
                     and ( mdl.pick_up_stop_id = mts.stop_id
                          or mdl.drop_off_stop_id = mts.stop_id))
  union all
  select mdd.source_header_number
  from mst_delivery_details mdd
     , mst_deliveries md
     , mst_delivery_assignments mda
  where md.plan_id = mda.plan_id
  and   md.delivery_id = mda.delivery_id
  and   mda.plan_id = mdd.plan_id
  and   mda.delivery_detail_id = mdd.delivery_detail_id
  and   md.plan_id = l_plan_id
  and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
  and   not exists (select 1 from mst_delivery_legs mdl
                    where mdl.plan_id=md.plan_id
                    and   mdl.delivery_id = md.delivery_id)) dd;

  cursor cur_plan_orders_carr (l_plan_id      in number
                             , l_c_s_ident    in number
                             , l_cust_supp_id in number
			     , l_carrier_id   in number) is
  select count(distinct dd.source_header_number)
  from (
        select mdd.source_header_number source_header_number
        from mst_delivery_details mdd
           , mst_deliveries md
           , mst_delivery_assignments mda
        where md.plan_id = mda.plan_id
        and   md.delivery_id = mda.delivery_id
        and   mda.plan_id = mdd.plan_id
        and   mda.delivery_detail_id = mdd.delivery_detail_id
        and   md.plan_id = l_plan_id
        and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
        and   md.delivery_id in
                    (select mdl.delivery_id
                     from  mst_delivery_legs mdl
                         , mst_trip_stops mts
			 , mst_trips mt
                     where mdl.plan_id = md.plan_id
                     and   mdl.plan_id = mts.plan_id
                     and ( mdl.pick_up_stop_id = mts.stop_id
                          or mdl.drop_off_stop_id = mts.stop_id)
		     and   mdl.trip_id = mts.trip_id
		     and   mt.plan_id = mts.plan_id
		     and   mt.trip_id = mts.trip_id
		     and   mt.carrier_id = l_carrier_id)) dd;
begin
  if p_report_for = 1 then
    open cur_plan_orders_myfac (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_plan_orders_myfac into l_plan_order_count;
    close cur_plan_orders_myfac;
  elsif (p_report_for = 0 OR p_report_for = 2 OR p_report_for = 4) then
    --open cur_plan_orders_c_s (p_plan_id, p_c_s_ident, p_cust_supp_id);
    open cur_plan_orders_c_s ( p_plan_id, p_report_for, p_report_for_id, p_c_s_ident, p_cust_supp_id );
    fetch cur_plan_orders_c_s into l_plan_order_count;
    close cur_plan_orders_c_s;
  elsif p_report_for = 3 then
    open cur_plan_orders_carr (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_plan_orders_carr into l_plan_order_count;
    close cur_plan_orders_carr;
  end if;

  return l_plan_order_count;
exception
when others then
	 return 0;
end get_orders_c_s;


-- Weight KPI
function get_weight_c_s (p_plan_id       in number
                       , p_report_for    in number
   		       , p_report_for_id in number
		       , p_c_s_ident     in number
		       , p_cust_supp_id  in number)
return number is
  l_weight number;

  cursor cur_weight_myfac (l_plan_id      in number
                         , l_c_s_ident    in number
			 , l_cust_supp_id in number
                         , l_myfac_id     in number) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
     , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id;


  cursor cur_weight_c_s (l_plan_id       in number
  		       , l_report_for	 in number
  		       , l_report_for_id in number
                       , l_c_s_ident     in number
  		       , l_cust_supp_id  in number) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_weight_carr (l_plan_id      in number
                        , l_c_s_ident    in number
  		        , l_cust_supp_id in number
			, l_carrier_id   in number) is
  select nvl(sum(nvl(md.gross_weight,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 1 then
    open cur_weight_myfac (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_weight_myfac into l_weight;
    close cur_weight_myfac;
  elsif (p_report_for = 0 OR p_report_for = 2 OR p_report_for = 4) then
    --open cur_weight_c_s (p_plan_id, p_c_s_ident, p_cust_supp_id);
    open cur_weight_c_s ( p_plan_id, p_report_for, p_report_for_id, p_c_s_ident, p_cust_supp_id );
    fetch cur_weight_c_s into l_weight;
    close cur_weight_c_s;
  elsif p_report_for = 3 then
    open cur_weight_carr (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_weight_carr into l_weight;
    close cur_weight_carr;
  end if;

return l_weight;
exception
when others then
	 return 0;
end get_weight_c_s;


-- Volums KPI
function get_volume_c_s (p_plan_id       in number
                       , p_report_for    in number
		       , p_report_for_id in number
		       , p_c_s_ident     in number
		       , p_cust_supp_id  in number)
return number is
  l_volume number;

  cursor cur_volume_myfac (l_plan_id  in number
                         , l_c_s_ident in number
			 , l_cust_supp_id in number
                         , l_myfac_id in number) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
     , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id;


  cursor cur_volume_c_s (l_plan_id       in number
                       , l_report_for    in number
                       , l_report_for_id in number
                       , l_c_s_ident     in number
  		       , l_cust_supp_id  in number) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_volume_carr (l_plan_id      in number
                        , l_c_s_ident    in number
  		        , l_cust_supp_id in number
			, l_carrier_id   in number) is
  select nvl(sum(nvl(md.volume,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 1 then
    open cur_volume_myfac (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_volume_myfac into l_volume;
    close cur_volume_myfac;
  elsif (p_report_for = 0 OR p_report_for = 2 OR p_report_for = 4) then
    open cur_volume_c_s (p_plan_id, p_report_for, p_report_for_id, p_c_s_ident, p_cust_supp_id);
    fetch cur_volume_c_s into l_volume;
    close cur_volume_c_s;
  elsif p_report_for = 3 then
    open cur_volume_carr (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_volume_carr into l_volume;
    close cur_volume_carr;
  end if;

return l_volume;
exception
when others then
	 return 0;
end get_volume_c_s;


-- Pieces KPI
function get_pieces_c_s (p_plan_id       in number
                       , p_report_for    in number
		       , p_report_for_id in number
		       , p_c_s_ident     in number
		       , p_cust_supp_id  in number)
return number is
  l_pieces number;

  cursor cur_pieces_myfac (l_plan_id  in number
                         , l_c_s_ident in number
			 , l_cust_supp_id in number
                         , l_myfac_id in number) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
     , fte_location_parameters flp
  where md.plan_id = l_plan_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and (md.pickup_location_id = flp.location_id
      or md.dropoff_location_id = flp.location_id)
  and flp.facility_id = l_myfac_id;


  cursor cur_pieces_c_s (l_plan_id       in number
  		       , l_report_for 	 in number
  		       , l_report_for_id in number
                       , l_c_s_ident     in number
  		       , l_cust_supp_id  in number) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id;

  cursor cur_pieces_carr (l_plan_id      in number
                        , l_c_s_ident    in number
  		        , l_cust_supp_id in number
			, l_carrier_id   in number) is
  select nvl(sum(nvl(md.number_of_pieces,0)),0)
  from mst_deliveries md
  where md.plan_id = l_plan_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and md.delivery_id in (select distinct mdl.delivery_id
                         from mst_delivery_legs mdl
			 , mst_trips mt
			 where mdl.plan_id = md.plan_id
			 and mt.plan_id = mdl.plan_id
			 and mt.trip_id = mdl.trip_id
			 and mt.carrier_id = l_carrier_id);
begin
  if p_report_for = 1 then
    open cur_pieces_myfac (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_pieces_myfac into l_pieces;
    close cur_pieces_myfac;
  elsif (p_report_for = 0 OR p_report_for = 2 OR p_report_for = 4) then
    --open cur_pieces_c_s (p_plan_id, p_c_s_ident, p_cust_supp_id);
    open cur_pieces_c_s (p_plan_id, p_report_for, p_report_for_id, p_c_s_ident, p_cust_supp_id);
    fetch cur_pieces_c_s into l_pieces;
    close cur_pieces_c_s;
  elsif p_report_for = 3 then
    open cur_pieces_carr (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_pieces_carr into l_pieces;
    close cur_pieces_carr;
  end if;

return l_pieces;
exception
when others then
	 return 0;
end get_pieces_c_s;


function get_trips_per_mode_c_s (p_plan_id       in number
                               , p_report_for    in number
		               , p_report_for_id in number
			       , p_mode          in varchar2
			       , p_c_s_ident     in number
			       , p_cust_supp_id  in number)
return number is
  l_trips_per_mode number;

  cursor cur_trips_myfac (l_plan_id  in number
                        , l_c_s_ident in number
			, l_cust_supp_id in number
                        , l_myfac_id in number
			, l_mode     in varchar2) is
  select count(*)
  from mst_trips mt
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and flp.location_id in (select distinct mts.stop_location_id
                          from mst_trip_stops mts
			  , mst_delivery_legs mdl
			  , mst_deliveries md
			  where mts.plan_id = mt.plan_id
			  and mts.trip_id = mt.trip_id
			  and mdl.plan_id = mts.plan_id
			  and mdl.trip_id = mts.trip_id
			  and md.plan_id = mdl.plan_id
			  and md.delivery_id = mdl.delivery_id
			  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id)
  and flp.facility_id = l_myfac_id;

  cursor cur_trips_c_s (l_plan_id       in number
  		      , l_report_for	in number
  		      , l_report_for_id	in number
                      , l_c_s_ident     in number
                      , l_cust_supp_id  in number
		      , l_mode          in varchar2) is
  select count(mt.trip_id)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
		    and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
                    and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   mt.mode_of_transport = l_mode
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) >= 2
        group by ts.trip_id);

  cursor cur_trips_carr (l_plan_id      in number
                       , l_c_s_ident    in number
                       , l_cust_supp_id in number
		       , l_carrier_id   in number
		       , l_mode         in varchar2) is
  select count(mt.trip_id)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and   mt.carrier_id = l_carrier_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                    and mts.plan_id = md.plan_id
--                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   mt.mode_of_transport = l_mode
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) >= 2
        group by ts.trip_id);
begin
  if p_report_for = 1 then
    open cur_trips_myfac (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id, p_mode);
    fetch cur_trips_myfac into l_trips_per_mode;
    close cur_trips_myfac;
  elsif (p_report_for = 0 OR p_report_for = 2 OR p_report_for = 4) then
    --open cur_trips_c_s (p_plan_id, p_c_s_ident, p_cust_supp_id, p_mode);
    open cur_trips_c_s (p_plan_id, p_report_for, p_report_for_id, p_c_s_ident, p_cust_supp_id, p_mode);
    fetch cur_trips_c_s into l_trips_per_mode;
    close cur_trips_c_s;
  elsif p_report_for = 3 then
    open cur_trips_carr (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id, p_mode);
    fetch cur_trips_carr into l_trips_per_mode;
    close cur_trips_carr;
  end if;

   return l_trips_per_mode;
exception
when others then
	 return 0;
end get_trips_per_mode_c_s;


function get_cost_per_mode_c_s (p_plan_id       in number
                              , p_report_for    in number
      		              , p_report_for_id in number
		              , p_mode          in varchar2
			      , p_c_s_ident     in number
			      , p_cust_supp_id  in number)
return number is
  l_total_cost_per_mode number;

  cursor cur_total_cost_myfac (l_plan_id  in number
                             , l_c_s_ident in number
			     , l_cust_supp_id in number
                             , l_myfac_id in number
                             , l_mode     in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
		   , fte_location_parameters flp
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   mts.stop_location_id = flp.location_id
		and   flp.facility_id = l_myfac_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
                and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                and   (md.pickup_location_id = flp.location_id
		       or md.dropoff_location_id = flp.location_id));
*/
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  , fte_location_parameters flp
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and flp.facility_id = l_myfac_id
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and ( md.pickup_location_id = flp.location_id
        or md.dropoff_location_id = flp.location_id ) );

  cursor cur_total_cost_c_s (l_plan_id       in number
  			   , l_report_for    in number
  			   , l_report_for_id in number
                           , l_c_s_ident     in number
                           , l_cust_supp_id  in number
			   , l_mode          in varchar2) is
/*
  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_delivery_legs mdl
  where mdl.plan_id = l_plan_id
  and mdl.delivery_id in
             ( select md.delivery_id
               from  mst_delivery_legs mdl1
                   , mst_deliveries md
                   , mst_trips mt
                   , mst_trip_stops mts
                where mt.plan_id = mdl1.plan_id
                and   mt.trip_id  = mdl1.trip_id
                and   mt.mode_of_transport = l_mode
                and   mt.plan_id = mts.plan_id
                and   mt.trip_id = mts.trip_id
                and   md.plan_id = mdl1.plan_id
                and   md.delivery_id  = mdl1.delivery_id
                and   md.plan_id = mdl.plan_id
  		and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
                and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                and   (md.pickup_location_id = mts.stop_location_id
		       or md.dropoff_location_id = mts.stop_location_id));
*/
--Bug_Fix for 3696518
  (select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
	       + nvl(mdl.allocated_transport_cost,0)
	       + nvl(mdl.allocated_fac_shp_hand_cost,0)
               + nvl(mdl.allocated_fac_rec_hand_cost,0)),0)
  from mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.mode_of_transport = l_mode
  and mt.plan_id = mdl.plan_id
  and mt.trip_id = mdl.trip_id
  and mdl.plan_id = md.plan_id
  and mdl.delivery_id = md.delivery_id
  and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
  and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id );

  cursor cur_total_cost_carr (l_plan_id      in number
                            , l_c_s_ident    in number
                            , l_cust_supp_id in number
                            , l_carrier_id   in number
			    , l_mode         in varchar2) is
/*  select nvl(sum(decode(mt.mode_of_transport
                       , 'TRUCK', (nvl(mt.total_basic_transport_cost,0)
                                 + nvl(mt.total_stop_cost,0)
		                 + nvl(mt.total_load_unload_cost,0)
			         + nvl(mt.total_layover_cost,0)
			         + nvl(mt.total_accessorial_cost,0)
			         + nvl(mt.total_handling_cost,0))
		       , (nvl(mt.total_basic_transport_cost,0)
		        + nvl(mt.total_accessorial_cost,0)))),0)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and mt.carrier_id = l_carrier_id
  and mt.mode_of_transport = l_mode
--  and mt.continuous_move_id is null  --check
  and mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and mts.plan_id = md.plan_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
--		    and (md.pickup_location_id = mts.stop_location_id
--		        or md.dropoff_location_id = mts.stop_location_id)
		    and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id);
*/
 select sum(nvl(mdl.allocated_fac_loading_cost,0)
          + nvl(mdl.allocated_fac_unloading_cost,0)
          + nvl(mdl.allocated_fac_shp_hand_cost,0)
	  + nvl(mdl.allocated_fac_rec_hand_cost,0)
	  + nvl(mdl.allocated_transport_cost,0))
  from  mst_deliveries md,
        mst_delivery_legs mdl,
        mst_trips mt
  where md.plan_id = l_plan_id
  and   decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
  and   md.delivery_id = mdl.delivery_id
  and   mt.plan_id = mdl.plan_id
  and   mt.trip_id = mdl.trip_id
  and   mt.carrier_id = l_carrier_id
  and   mt.mode_of_transport = l_mode;

begin
  if p_report_for = 1 then
    open cur_total_cost_myfac (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id, p_mode);
    fetch cur_total_cost_myfac into l_total_cost_per_mode;
    close cur_total_cost_myfac;
  elsif (p_report_for = 0 OR p_report_for = 2 OR p_report_for = 4) then
    --open cur_total_cost_c_s (p_plan_id, p_c_s_ident, p_cust_supp_id, p_mode);
    open cur_total_cost_c_s (p_plan_id, p_report_for, p_report_for_id, p_c_s_ident, p_cust_supp_id, p_mode);
    fetch cur_total_cost_c_s into l_total_cost_per_mode;
    close cur_total_cost_c_s;
  elsif p_report_for = 3 then
    open cur_total_cost_carr (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id, p_mode);
    fetch cur_total_cost_carr into l_total_cost_per_mode;
    close cur_total_cost_carr;
  end if;

   return nvl(l_total_cost_per_mode,0);
exception
when others then
	 return 0;
end get_cost_per_mode_c_s;


function get_DTL_c_s (p_plan_id       in number
                     , p_report_for    in number
		    , p_report_for_id in number
		    , p_c_s_ident     in number
		    , p_cust_supp_id  in varchar2)
return number is
  l_DTL number;

  cursor cur_DTL_myfac (l_plan_id  in number
                      , l_c_s_ident    in number
                      , l_cust_supp_id in number
                      , l_myfac_id in number) is
-- Bug_Fix for 3694008 -- optimized query
  SELECT count(mt.trip_id) num_stops
  FROM mst_trips mt
  WHERE mt.plan_id = l_plan_id
  AND mt.trip_id IN ( SELECT mdl.trip_id
	                 FROM mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts1
                         , fte_location_parameters flp
                         WHERE mdl.plan_id = mt.plan_id
                         AND md.plan_id = mdl.plan_id
                         AND md.delivery_id = mdl.delivery_id
                         AND decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                         AND mts1.plan_id = mdl.plan_id
                         AND mts1.trip_id = mdl.trip_id
                         -- and mts1.stop_id = mdl.pick_up_stop_id
                         -- Bug_Fix for 3694008
                         AND ( mts1.stop_id = mdl.pick_up_stop_id
                             OR mts1.stop_id = mdl.drop_off_stop_id )
                         AND flp.location_id = mts1.stop_location_id
                         AND flp.facility_id = l_myfac_id )
  AND mt.mode_of_transport = 'TRUCK'
  AND EXISTS
       ( SELECT ts.trip_id
         FROM mst_trip_stops ts
         WHERE ts.plan_id = mt.plan_id
         AND   ts.trip_id = mt.trip_id
         HAVING COUNT(ts.stop_id) = 2
         GROUP BY ts.trip_id );
/*
  SELECT COUNT(*)
  FROM (SELECT DISTINCT mt.trip_id, count(*) num_stops
        FROM mst_trips mt
           , mst_trip_stops mts
	    WHERE mt.plan_id = l_plan_id
	    AND mt.trip_id in (SELECT DISTINCT mdl.trip_id
	                       FROM   mst_deliveries md
			                    , mst_delivery_legs mdl
			                    , mst_trip_stops mts1
                                , fte_location_parameters flp
			               WHERE mdl.plan_id = mt.plan_id
			               AND md.plan_id = mdl.plan_id
			               AND md.delivery_id = mdl.delivery_id
			               AND decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                           AND mts1.plan_id = mdl.plan_id
			               AND mts1.trip_id = mdl.trip_id
                           --			   and mts1.stop_id = mdl.pick_up_stop_id
                           -- Bug_Fix for 3694008
                           AND ( mts1.stop_id = mdl.pick_up_stop_id
                                OR mts1.stop_id = mdl.drop_off_stop_id )
                           AND flp.location_id = mts1.stop_location_id
                           AND flp.facility_id = l_myfac_id)
	    AND mt.mode_of_transport = 'TRUCK'
	    AND mts.plan_id = mt.plan_id
	    AND mts.trip_id = mt.trip_id
	    GROUP BY mt.trip_id) temp
        WHERE temp.num_stops = 2;
*/

  cursor cur_DTL_c_s (l_plan_id       in number
  		    , l_report_for    in number
  		    , l_report_for_id in number
                    , l_c_s_ident     in number
                    , l_cust_supp_id  in number) is
  select count(mt.trip_id)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
                    and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) = 2
        group by ts.trip_id);

  cursor cur_DTL_carr (l_plan_id      in number
                     , l_c_s_ident    in number
                     , l_cust_supp_id in number
		     , l_carrier_id   in number) is
  select count(mt.trip_id)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and   mt.carrier_id = l_carrier_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                    and mts.plan_id = md.plan_id
--                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) = 2
        group by ts.trip_id);
begin
  if p_report_for = 1 then
    open cur_DTL_myfac (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_DTL_myfac into l_DTL;
    close cur_DTL_myfac;
  elsif (p_report_for = 0 OR p_report_for = 2 OR p_report_for = 4) then
    --open cur_DTL_c_s (p_plan_id, p_c_s_ident, p_cust_supp_id);
    open cur_DTL_c_s (p_plan_id, p_report_for, p_report_for_id, p_c_s_ident, p_cust_supp_id);
    fetch cur_DTL_c_s into l_DTL;
    close cur_DTL_c_s;
  elsif p_report_for = 3 then
    open cur_DTL_carr (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_DTL_carr into l_DTL;
    close cur_DTL_carr;
  end if;

   return l_DTL;
exception
when others then
	 return 0;
end get_DTL_c_s;


function get_MTL_c_s (p_plan_id       in number
                    , p_report_for    in number
		    , p_report_for_id in number
		    , p_c_s_ident     in number
		    , p_cust_supp_id  in varchar2)
return number is
  l_MTL number;

  cursor cur_MTL_myfac (l_plan_id  in number
                      , l_c_s_ident    in number
                      , l_cust_supp_id in number
                      , l_myfac_id in number) is
-- Bug_Fix for 3694008 -- optimized query
  SELECT count(mt.trip_id) num_stops
  FROM mst_trips mt
  WHERE mt.plan_id = l_plan_id
  AND mt.trip_id IN ( SELECT mdl.trip_id
	                 FROM mst_deliveries md
                         , mst_delivery_legs mdl
                         , mst_trip_stops mts1
                         , fte_location_parameters flp
                         WHERE mdl.plan_id = mt.plan_id
                         AND md.plan_id = mdl.plan_id
                         AND md.delivery_id = mdl.delivery_id
                         AND decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                         AND mts1.plan_id = mdl.plan_id
                         AND mts1.trip_id = mdl.trip_id
                         -- and mts1.stop_id = mdl.pick_up_stop_id
                         -- Bug_Fix for 3694008
                         AND ( mts1.stop_id = mdl.pick_up_stop_id
                             OR mts1.stop_id = mdl.drop_off_stop_id )
                         AND flp.location_id = mts1.stop_location_id
                         AND flp.facility_id = l_myfac_id )
  AND mt.mode_of_transport = 'TRUCK'
  AND EXISTS
       ( SELECT ts.trip_id
         FROM mst_trip_stops ts
         WHERE ts.plan_id = mt.plan_id
         AND   ts.trip_id = mt.trip_id
         HAVING COUNT(ts.stop_id) > 2
         GROUP BY ts.trip_id );
/*
  select count(*)
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = l_plan_id
	and mt.trip_id in (select distinct mdl.trip_id
	                   from mst_deliveries md
			   , mst_delivery_legs mdl
			   , mst_trip_stops mts1
                           , fte_location_parameters flp
			   where mdl.plan_id = mt.plan_id
			   and md.plan_id = mdl.plan_id
			   and md.delivery_id = mdl.delivery_id
			   and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                           and mts1.plan_id = mdl.plan_id
			   and mts1.trip_id = mdl.trip_id
--			   and mts1.stop_id = mdl.pick_up_stop_id
-- Bug_Fix for 3694008
                           and ( mts1.stop_id = mdl.pick_up_stop_id
                               or mts1.stop_id = mdl.drop_off_stop_id )
                           and flp.location_id = mts1.stop_location_id
                           and flp.facility_id = l_myfac_id)
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops > 2;
*/

  cursor cur_MTL_c_s (l_plan_id       in number
  		    , l_report_for    in number
  		    , l_report_for_id in number
                    , l_c_s_ident     in number
                    , l_cust_supp_id  in number) is
  select count(mt.trip_id)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
  		    and decode ( l_report_for, 2, md.customer_id, 4, md.supplier_id, 0 ) = decode ( l_report_for, 2, l_report_for_id, 4, l_report_for_id, 0 )
                    and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) > 2
        group by ts.trip_id);

  cursor cur_MTL_carr (l_plan_id      in number
                     , l_c_s_ident    in number
                     , l_cust_supp_id in number
		     , l_carrier_id   in number) is
  select count(mt.trip_id)
  from mst_trips mt
  where mt.plan_id = l_plan_id
  and   mt.carrier_id = l_carrier_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and decode(l_c_s_ident, 2, md.customer_id, md.supplier_id) = l_cust_supp_id
                    and mts.plan_id = md.plan_id
--                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) > 2
        group by ts.trip_id);
begin
  if p_report_for = 1 then
    open cur_MTL_myfac (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_MTL_myfac into l_MTL;
    close cur_MTL_myfac;
  elsif (p_report_for = 0 OR p_report_for = 2 OR p_report_for = 4) then
    --open cur_MTL_c_s (p_plan_id, p_c_s_ident, p_cust_supp_id);
    open cur_MTL_c_s (p_plan_id, p_report_for, p_report_for_id, p_c_s_ident, p_cust_supp_id);
    fetch cur_MTL_c_s into l_MTL;
    close cur_MTL_c_s;
  elsif p_report_for = 3 then
    open cur_MTL_carr (p_plan_id, p_c_s_ident, p_cust_supp_id, p_report_for_id);
    fetch cur_MTL_carr into l_MTL;
    close cur_MTL_carr;
  end if;

   return l_MTL;
exception
when others then
	 return 0;
end get_MTL_c_s;


PROCEDURE Populate_Master_Summary_GTT (p_plan_id       in number
                                     , p_report_for    in number
				     , p_report_for_id in number default 0) is
  -- local variables
  l_c_s_ident number;
BEGIN

  -- populate header section
  -- (view_id = 1)
  insert into mst_mast_sum_report_temp_gt
  ( view_id
  , plan_id
  , compile_designator
  , report_date
  , plan_start_date
  , plan_end_date
  , orders
  , order_groups
  , weight
  , volume
  , pieces
  , pallets
  , allocated_cost  ---not used anymore
  , plan_value
  , total_tl_count
  , ltl_count
  , parcel_count
  , tl_cost
  , ltl_cost
  , parcel_cost
  , transportation_cost
  , handling_cost
  , total_cost
  , tl_stops
  , tl_distance
  , percent_alloc_cost  ---not used anymore
  , percent_value
  )
 (SELECT 1
  , mp.plan_id
  , mp.compile_designator
  , sysdate
  , mp.start_date
  , mp.cutoff_date
  , mst_reports_pkg.get_plan_order_count(p_plan_id, p_report_for, p_report_for_id)
  , mst_reports_pkg.get_order_group_count(p_plan_id, p_report_for, p_report_for_id)
  , mst_reports_pkg.get_weight(p_plan_id, p_report_for, p_report_for_id)
  , mst_reports_pkg.get_volume(p_plan_id, p_report_for, p_report_for_id)
  , mst_reports_pkg.get_pieces(p_plan_id, p_report_for, p_report_for_id)
  , 0
  , 0
  , mst_reports_pkg.get_plan_value(p_plan_id, p_report_for, p_report_for_id)
  , mst_reports_pkg.get_trips_per_mode(p_plan_id, p_report_for, p_report_for_id,'TRUCK')
  , mst_reports_pkg.get_trips_per_mode(p_plan_id, p_report_for, p_report_for_id,'LTL')
  , mst_reports_pkg.get_trips_per_mode(p_plan_id, p_report_for, p_report_for_id,'PARCEL')
  , mst_reports_pkg.get_trans_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'TRUCK')
  , mst_reports_pkg.get_trans_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'LTL')
  , mst_reports_pkg.get_trans_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'PARCEL')
  , mst_reports_pkg.get_trans_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'TRUCK')
   +mst_reports_pkg.get_trans_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'LTL')
   +mst_reports_pkg.get_trans_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'PARCEL')
  , mst_reports_pkg.get_handl_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'TRUCK')
   +mst_reports_pkg.get_handl_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'LTL')
   +mst_reports_pkg.get_handl_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'PARCEL')
  , mst_reports_pkg.get_total_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'TRUCK')
   +mst_reports_pkg.get_total_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'LTL')
   +mst_reports_pkg.get_total_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'PARCEL')
  , mst_reports_pkg.get_stops_per_load(p_plan_id, p_report_for, p_report_for_id)
  , mst_reports_pkg.get_TL_distance(p_plan_id, p_report_for, p_report_for_id)
  , 0
  , ( ( mst_reports_pkg.get_total_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'TRUCK')
       +mst_reports_pkg.get_total_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'LTL')
       +mst_reports_pkg.get_total_cost_per_mode(p_plan_id, p_report_for, p_report_for_id,'PARCEL')
       ) / decode( mst_reports_pkg.get_plan_value(p_plan_id, p_report_for, p_report_for_id)
                 , 0, 1
	         , mst_reports_pkg.get_plan_value(p_plan_id, p_report_for, p_report_for_id)) ) * 100
  from mst_plans mp
  where mp.plan_id = p_plan_id
 );


  -- populate Business Unit section
  -- (view_id = 2)
  insert into mst_mast_sum_report_temp_gt
  ( view_id
  , plan_id
  , facility_name
  , orders
  , weight
  , volume
  , pieces
  , tl_cost
  , ltl_cost
  , parcel_cost
  , total_cost
  , cost_per_unit_weight
  , cost_per_unit_volume
  , percent_value
  , percent_alloc_cost
  )
  (SELECT 2
  , temp.plan_id
  , fte.facility_code
  , mst_reports_pkg.get_orders_myfac(p_plan_id,p_report_for,p_report_for_id,fte.facility_id)
  , mst_reports_pkg.get_weight_myfac(p_plan_id,p_report_for,p_report_for_id,fte.facility_id)
  , mst_reports_pkg.get_volume_myfac(p_plan_id,p_report_for,p_report_for_id,fte.facility_id)
  , mst_reports_pkg.get_pieces_myfac(p_plan_id,p_report_for,p_report_for_id,fte.facility_id)
  , mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'TRUCK',fte.facility_id)
  , mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'LTL',fte.facility_id)
  , mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'PARCEL',fte.facility_id)
  , mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'TRUCK',fte.facility_id)
    +mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'LTL',fte.facility_id)
    +mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'PARCEL',fte.facility_id)
  ,( mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'TRUCK',fte.facility_id)
    +mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'LTL',fte.facility_id)
    +mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'PARCEL',fte.facility_id)
   ) / decode( mst_reports_pkg.get_weight_myfac(p_plan_id,p_report_for,p_report_for_id,fte.facility_id)
              ,0 ,1
              , mst_reports_pkg.get_weight_myfac(p_plan_id,p_report_for,p_report_for_id,fte.facility_id))
  ,( mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'TRUCK',fte.facility_id)
    +mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'LTL',fte.facility_id)
    +mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'PARCEL',fte.facility_id)
   ) / decode( mst_reports_pkg.get_volume_myfac(p_plan_id,p_report_for,p_report_for_id,fte.facility_id)
              ,0 ,1
	      , mst_reports_pkg.get_volume_myfac(p_plan_id,p_report_for,p_report_for_id,fte.facility_id))
, ( ( mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'TRUCK',fte.facility_id)
     +mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'LTL',fte.facility_id)
     +mst_reports_pkg.get_cost_per_mode_myfac(p_plan_id,p_report_for,p_report_for_id,'PARCEL',fte.facility_id)
     ) / decode( nvl(mst_reports_pkg.get_plan_value(p_plan_id,p_report_for,p_report_for_id),0)
                 , 0, 1
		 , mst_reports_pkg.get_plan_value(p_plan_id,p_report_for,p_report_for_id)) ) * 100
  , 0
  from (select distinct mts.plan_id plan_id, mts.stop_location_id loc_id
        from mst_trip_stops mts
        , mst_trips mt
        where mts.plan_id = mt.plan_id
        and mts.trip_id = mt.trip_id) temp,
  mst_plans mp,
  wsh_location_owners wlo,
  wsh_locations wl,
  fte_location_parameters fte
  where mp.plan_id = temp.plan_id
  and temp.loc_id = fte.location_id
  and fte.location_id = wl.wsh_location_id
  and wl.wsh_location_id = wlo.wsh_location_id
  and wlo.owner_type = 1
  and mp.plan_id = p_plan_id
  and decode ( p_report_for, 1, fte.facility_id, p_report_for_id ) = p_report_for_id
);


  -- populate Carrier section
  -- (view_id = 3)
  insert into mst_mast_sum_report_temp_gt
  ( view_id
  , plan_id
  , carrier_name
  , carr_moves
  , total_cost
  , mode_of_transport
  )
  (SELECT 3
  , mt.plan_id
  , wc.freight_code
  , mst_reports_pkg.get_carr_movements(p_plan_id,p_report_for,p_report_for_id,mt.carrier_id)
  , mst_reports_pkg.get_carr_cost(p_plan_id,p_report_for,p_report_for_id,mt.carrier_id)
  , mt.mode_of_transport
  from mst_trips mt
  , wsh_carriers wc
  WHERE mt.carrier_id = wc.carrier_id
  and mt.plan_id = p_plan_id
  and decode ( p_report_for, 3, mt.carrier_id, p_report_for_id ) = p_report_for_id
  group by mt.plan_id
  , mt.carrier_id
  , wc.freight_code
  ,mt.mode_of_transport
 );



  -- populate Originwise summary section
  -- (view_id = 4)
  insert into mst_mast_sum_report_temp_gt
  ( view_id
  , plan_id
  , origin_name
  , orders
  , weight
  , volume
  , pieces
  , mtl_count
  , dtl_count
  , ltl_count
  , parcel_count
  , tl_cost
  , ltl_cost
  , parcel_cost
  , total_cost
  , cost_per_unit_weight
  , cost_per_unit_volume
  , percent_value
  , percent_alloc_cost
  )
  (SELECT distinct 4
  , mp.plan_id
  , wl.state
  , mst_reports_pkg.get_orders_orig(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_weight_orig(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_volume_orig(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_pieces_orig(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_MTL_orig(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_DTL_orig(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_LTL_orig(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_PCL_orig(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'TRUCK',wl.state)
  , mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'LTL',wl.state)
  , mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'PARCEL',wl.state)
  , mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'TRUCK',wl.state)
       +mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'LTL',wl.state)
       +mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'PARCEL',wl.state)
  , ( mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'TRUCK',wl.state)
     +mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'LTL',wl.state)
     +mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'PARCEL',wl.state)
    ) / decode( mst_reports_pkg.get_weight_orig(p_plan_id,p_report_for,p_report_for_id,wl.state)
               ,0 ,1
	       ,mst_reports_pkg.get_weight_orig(p_plan_id,p_report_for,p_report_for_id,wl.state))
  , ( mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'TRUCK',wl.state)
     +mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'LTL',wl.state)
     +mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'PARCEL',wl.state)
    ) / decode( mst_reports_pkg.get_volume_orig(p_plan_id,p_report_for,p_report_for_id,wl.state)
               ,0 ,1
 	       ,mst_reports_pkg.get_volume_orig(p_plan_id,p_report_for,p_report_for_id,wl.state))
  ,( mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'TRUCK',wl.state)
    +mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'LTL',wl.state)
    +mst_reports_pkg.get_total_cost_mode_orig(p_plan_id,p_report_for,p_report_for_id,'PARCEL',wl.state)
   ) / decode( nvl(mst_reports_pkg.get_plan_value(p_plan_id,p_report_for,p_report_for_id),0)
             , 0, 1
 	     , mst_reports_pkg.get_plan_value(p_plan_id,p_report_for,p_report_for_id) ) * 100
  , 0
  from mst_plans mp
  ,wsh_locations wl
  WHERE mp.plan_id = p_plan_id
  and wl.wsh_location_id in (select distinct md.pickup_location_id
                             from mst_deliveries md
                             where md.plan_id = mp.plan_id)
  );


  -- populate Destinationwise summary section
  -- (view_id = 5)
  insert into mst_mast_sum_report_temp_gt
  ( view_id
  , plan_id
  , destination_name
  , orders
  , weight
  , volume
  , pieces
  , mtl_count
  , dtl_count
  , ltl_count
  , parcel_count
  , tl_cost
  , ltl_cost
  , parcel_cost
  , total_cost
  , cost_per_unit_weight
  , cost_per_unit_volume
  , percent_value
  , percent_alloc_cost
  )
  (SELECT distinct 5
  , mp.plan_id
  , wl.state
  , mst_reports_pkg.get_orders_dest(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_weight_dest(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_volume_dest(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_pieces_dest(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_MTL_dest(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_DTL_dest(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_LTL_dest(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_PCL_dest(p_plan_id,p_report_for,p_report_for_id,wl.state)
  , mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'TRUCK',wl.state)
  , mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'LTL',wl.state)
  , mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'PARCEL',wl.state)
  , mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'TRUCK',wl.state)
    +mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'LTL',wl.state)
    +mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'PARCEL',wl.state)
  , ( mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'TRUCK',wl.state)
     +mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'LTL',wl.state)
     +mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'PARCEL',wl.state)
    ) / decode( mst_reports_pkg.get_weight_dest(p_plan_id,p_report_for,p_report_for_id,wl.state)
               ,0 ,1
               ,mst_reports_pkg.get_weight_dest(p_plan_id,p_report_for,p_report_for_id,wl.state))
  , ( mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'TRUCK',wl.state)
     +mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'LTL',wl.state)
     +mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'PARCEL',wl.state)
    ) / decode( mst_reports_pkg.get_volume_dest(p_plan_id,p_report_for,p_report_for_id,wl.state)
               ,0 ,1
               ,mst_reports_pkg.get_volume_dest(p_plan_id,p_report_for,p_report_for_id,wl.state))
  ,( mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'TRUCK',wl.state)
    +mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'LTL',wl.state)
    +mst_reports_pkg.get_total_cost_mode_dest(p_plan_id,p_report_for,p_report_for_id,'PARCEL',wl.state)
   ) / decode( nvl(mst_reports_pkg.get_plan_value(p_plan_id,p_report_for,p_report_for_id),0)
               , 0, 1
               , mst_reports_pkg.get_plan_value(p_plan_id,p_report_for,p_report_for_id) ) * 100
  , 0
  from mst_plans mp
  ,wsh_locations wl
  WHERE mp.plan_id = p_plan_id
  and wl.wsh_location_id in (select distinct md.dropoff_location_id
                             from mst_deliveries md
                             where md.plan_id = mp.plan_id)
  );


  -- populate Customer summary section
  -- (view_id = 6)
  --l_c_s_ident is the customer/supplier identifier.
  --it is set to 2 here as it is populating the customer data in the following sql
  l_c_s_ident := 2;

  insert into mst_mast_sum_report_temp_gt
  ( view_id
  , plan_id
  , customer_name
  , orders
  , weight
  , volume
  , pieces
  , mtl_count
  , dtl_count
  , ltl_count
  , parcel_count
  , tl_cost
  , ltl_cost
  , parcel_cost
  , total_cost
  , cost_per_unit_weight
  , cost_per_unit_volume
  , percent_value
  , percent_alloc_cost
  )
  (SELECT 6
  , mp.plan_id
  , hzp.party_name
  , mst_reports_pkg.get_orders_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,hzc.cust_account_id)
  , mst_reports_pkg.get_weight_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,hzc.cust_account_id)
  , mst_reports_pkg.get_volume_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,hzc.cust_account_id)
  , mst_reports_pkg.get_pieces_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,hzc.cust_account_id)
  , mst_reports_pkg.get_MTL_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,hzc.cust_account_id)
  , mst_reports_pkg.get_DTL_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,hzc.cust_account_id)
  , mst_reports_pkg.get_trips_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,hzc.cust_account_id)
  , mst_reports_pkg.get_trips_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,hzc.cust_account_id)
  , mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'TRUCK',l_c_s_ident,hzc.cust_account_id)
  , mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,hzc.cust_account_id)
  , mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,hzc.cust_account_id)
  , mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'TRUCK',l_c_s_ident,hzc.cust_account_id)
   +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,hzc.cust_account_id)
   +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,hzc.cust_account_id)
  , ( mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'TRUCK',l_c_s_ident,hzc.cust_account_id)
     +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,hzc.cust_account_id)
     +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,hzc.cust_account_id)
	) / decode( mst_reports_pkg.get_weight_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,hzc.cust_account_id)
	            ,0 ,1
	            ,mst_reports_pkg.get_weight_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,hzc.cust_account_id))
  , ( mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'TRUCK',l_c_s_ident,hzc.cust_account_id)
     +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,hzc.cust_account_id)
     +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,hzc.cust_account_id)
	) / decode( mst_reports_pkg.get_volume_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,hzc.cust_account_id)
	            ,0 ,1
                    ,mst_reports_pkg.get_volume_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,hzc.cust_account_id))
  , (( mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'TRUCK',l_c_s_ident,hzc.cust_account_id)
      +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,hzc.cust_account_id)
      +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,hzc.cust_account_id)
     ) / decode( nvl(mst_reports_pkg.get_plan_value(p_plan_id,p_report_for,p_report_for_id),0)
                 , 0, 1
		 , mst_reports_pkg.get_plan_value(p_plan_id,p_report_for,p_report_for_id)) ) * 100
  ,0
  from mst_plans mp
  , hz_parties hzp
  , hz_cust_accounts hzc
  WHERE mp.plan_id = p_plan_id
  and hzp.party_id = hzc.party_id
  and hzc.cust_account_id in (select distinct md.customer_id
                              from mst_deliveries md
                              where md.plan_id = mp.plan_id)
  and decode ( p_report_for, 2, hzc.cust_account_id, p_report_for_id ) = p_report_for_id
  );


  -- populate Supplier Summary section
  -- (view_id = 7)
  --l_c_s_ident is the customer/supplier identifier.
  --it is set to 4 here as it is populating the supplier data in the following sql
  l_c_s_ident := 4;

  insert into mst_mast_sum_report_temp_gt
  ( view_id
  , plan_id
  , supplier_name
  , orders
  , weight
  , volume
  , pieces
  , mtl_count
  , dtl_count
  , ltl_count
  , parcel_count
  , tl_cost
  , ltl_cost
  , parcel_cost
  , total_cost
  , cost_per_unit_weight
  , cost_per_unit_volume
  , percent_value
  , percent_alloc_cost
  )
  (SELECT 7
  , mp.plan_id
  , hz.party_name
  , mst_reports_pkg.get_orders_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,pov.vendor_id)
  , mst_reports_pkg.get_weight_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,pov.vendor_id)
  , mst_reports_pkg.get_volume_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,pov.vendor_id)
  , mst_reports_pkg.get_pieces_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,pov.vendor_id)
  , mst_reports_pkg.get_MTL_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,pov.vendor_id)
  , mst_reports_pkg.get_DTL_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,pov.vendor_id)
  , mst_reports_pkg.get_trips_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,pov.vendor_id)
  , mst_reports_pkg.get_trips_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,pov.vendor_id)
  , mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'TRUCK',l_c_s_ident,pov.vendor_id)
  , mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,pov.vendor_id)
  , mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,pov.vendor_id)
  , mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'TRUCK',l_c_s_ident,pov.vendor_id)
   +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,pov.vendor_id)
   +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,pov.vendor_id)
  , ( mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'TRUCK',l_c_s_ident,pov.vendor_id)
     +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,pov.vendor_id)
     +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,pov.vendor_id)
	) / decode( mst_reports_pkg.get_weight_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,pov.vendor_id)
	            ,0 ,1
	            ,mst_reports_pkg.get_weight_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,pov.vendor_id))
  , ( mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'TRUCK',l_c_s_ident,pov.vendor_id)
     +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,pov.vendor_id)
     +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,pov.vendor_id)
	) / decode( mst_reports_pkg.get_volume_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,pov.vendor_id)
	            ,0 ,1
                    ,mst_reports_pkg.get_volume_c_s(p_plan_id,p_report_for,p_report_for_id,l_c_s_ident,pov.vendor_id))
  , (( mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'TRUCK',l_c_s_ident,pov.vendor_id)
      +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'LTL',l_c_s_ident,pov.vendor_id)
      +mst_reports_pkg.get_cost_per_mode_c_s(p_plan_id,p_report_for,p_report_for_id,'PARCEL',l_c_s_ident,pov.vendor_id)
     ) / decode( nvl(mst_reports_pkg.get_plan_value(p_plan_id,p_report_for,p_report_for_id),0)
                 , 0, 1
		 , mst_reports_pkg.get_plan_value(p_plan_id,p_report_for,p_report_for_id)) ) * 100
  ,0
  from mst_plans mp
     , po_vendors pov
     , hz_relationships hzr
     , hz_parties hz
  WHERE mp.plan_id = p_plan_id
  and pov.vendor_id = hzr.subject_id
  and hzr.object_id = hz.party_id
  and hzr.relationship_type = 'POS_VENDOR_PARTY'
  and pov.vendor_id in (select mdd.supplier_id
                        from  mst_delivery_details mdd
                        where mdd.plan_id = mp.plan_id)
  and decode ( p_report_for, 4, pov.vendor_id , p_report_for_id ) = p_report_for_id
  );


exception
  when others then
    null;

END Populate_Master_Summary_GTT;


function get_freight_classes_per_order (p_plan_id              in number
                                      , p_source_header_number in number)
return varchar2 is
  l_freight_classes_str varchar2(500);
  l_freight_class       varchar2(40);

  cursor cur_freight_classes(l_plan_id              in number
                           , l_source_header_number in number) is
  select distinct mc.segment2
  from mtl_category_sets mcs
  , mtl_categories mc
  , mst_delivery_details mdd
  where mcs.structure_id = mc.structure_id
  and UPPER(mcs.category_set_name) = 'WSH_COMMODITY_CODE'    --'FREIGHT CLASS'
  and mc.category_id = mdd.commodity_code_cat_id             --mdd.freight_class_cat_id
  and mdd.plan_id = l_plan_id
  and mdd.source_header_number = l_source_header_number;

begin
  open cur_freight_classes(p_plan_id, p_source_header_number);
  --will loop maximum 10 times to fetch 10 records. This is because the HLD puts an upper bound on this
  for i in 1..10 loop
    fetch cur_freight_classes into l_freight_class;
    exit when cur_freight_classes%NOTFOUND;
    l_freight_classes_str := l_freight_classes_str||' '||l_freight_class;
  end loop;
  close cur_freight_classes;

  return l_freight_classes_str;
exception
  when others then
    null;
end get_freight_classes_per_order;

/*
 * To calculate the wait time at a particular stop for a given trip in a given plan
 */
FUNCTION get_wait_time_at_stop (   p_plan_id 	IN NUMBER
                                 , p_trip_id 	IN NUMBER
                                 , p_stop_id 	IN NUMBER )
RETURN VARCHAR2 IS

  CURSOR cur_wait_time (   l_plan_id 	IN NUMBER
                         , l_trip_id 	IN NUMBER
                         , l_stop_id 	IN NUMBER ) IS
  SELECT mts2.planned_arrival_date   planned_arrival_date,
         mts1.planned_departure_date planned_departure_date,
         mts1.drv_time_to_next_stop  drv_time_to_next_stop,
         mts1.total_layover_duration total_layover_duration
  FROM mst_trip_stops mts1
       ,mst_trip_stops mts2
  WHERE mts1.plan_id = l_plan_id
  AND   mts1.trip_id = l_trip_id
  AND   mts1.stop_id = l_stop_id
  AND   mts2.plan_id = mts1.plan_id
  AND   mts2.trip_id = mts1.trip_id
  AND   mts2.stop_sequence_number = ( SELECT MIN( mts3.stop_sequence_number )
                                      FROM mst_trip_stops mts3
                                      WHERE mts3.plan_id = mts1.plan_id
                                      AND  mts3.trip_id = mts1.trip_id
                                      AND  mts3.stop_sequence_number > mts1.stop_sequence_number );
 l_rec_wait_time cur_wait_time%ROWTYPE;
 l_wait_time NUMBER;
 l_wait_time_str VARCHAR2(100);
BEGIN

  OPEN cur_wait_time ( p_plan_id, p_trip_id, p_stop_id );
  FETCH cur_wait_time INTO l_rec_wait_time;
  IF cur_wait_time%NOTFOUND THEN
    l_wait_time_str := '00:00';
  ELSE
    l_wait_time :=  NVL ( ( l_rec_wait_time.planned_arrival_date -
                            l_rec_wait_time.planned_departure_date ) * 24, 0 )-
                    NVL ( l_rec_wait_time.drv_time_to_next_stop, 0 )          -
                    NVL ( l_rec_wait_time.total_layover_duration, 0 )           ;
    IF l_wait_time < 0 THEN
        l_wait_time := 0;
    END IF;
    l_wait_time_str:= mst_wb_util.get_hr_min(l_wait_time);
  END IF;
  CLOSE cur_wait_time;

  RETURN l_wait_time_str;

EXCEPTION
  WHEN OTHERS THEN
    l_wait_time_str := '00:00';
    RETURN l_wait_time_str;
END get_wait_time_at_stop;

END MST_REPORTS_PKG;

/
