--------------------------------------------------------
--  DDL for Package Body MST_CM_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_CM_DETAILS" AS
/*$Header: MSTCMDLB.pls 115.6 2004/07/30 09:59:58 bramacha noship $ */

function get_number_of_loads(
arg_plan_id number,
arg_continuous_move_id number
) return number IS
-- local variables
l_num_of_loads number;
cursor cm_loads IS
  select count(trip_id)
  from mst_trips
  where plan_id = arg_plan_id
  and continuous_move_id = arg_continuous_move_id;
begin
  open cm_loads;
  fetch cm_loads into l_num_of_loads;
  if cm_loads%NOTFOUND then
       close cm_loads;
       raise No_Data_Found;
  end if;
  close cm_loads;
  return l_num_of_loads;
exception
  when others then
     return 0;
end get_number_of_loads;

function get_distance(
arg_plan_id number,
arg_continuous_move_id number
) return number IS
-- local variables
l_distance number;
  cursor cm_distance  IS
  select sum(total_trip_distance)
  from mst_trips
  where plan_id = arg_plan_id
  and continuous_move_id = arg_continuous_move_id;
begin
  open cm_distance;
  fetch cm_distance into l_distance;
  if cm_distance%NOTFOUND then
       close cm_distance;
       raise No_Data_Found;
  end if;
  close cm_distance;
  return l_distance;
exception
  when others then
     return 0;
end get_distance;

function get_savings(
arg_plan_id number,
arg_continuous_move_id number,
arg_total_cm_trip_cost number
) return number IS
-- local variables
l_savings number;
begin
  select nvl(total_saving, 0)
  into l_savings
  from mst_cm_trips
  where plan_id = arg_plan_id
  and continuous_move_id = arg_continuous_move_id;
  return l_savings;
exception
  when NO_DATA_FOUND then
     raise;
end get_savings;

function get_number_of_stops(
arg_plan_id number,
arg_trip_id number
) return number IS
-- local variables
l_num_of_stops number;
begin
  l_num_of_stops := 12;
  return l_num_of_stops;
exception
  when NO_DATA_FOUND then
     raise;
end get_number_of_stops;

function get_total_savings(
arg_plan_id number
) return number IS
-- local variables
l_savings number;
begin
  l_savings := 12;
  return l_savings;
exception
  when NO_DATA_FOUND then
     raise;
end get_total_savings;

function get_number_of_exceptions(
arg_plan_id number
) return number IS
-- local variables
l_number_of_exceptions number := 0;
cursor num_of_excep is select count(1)
from mst_exception_details
where plan_id = arg_plan_id
and continuous_move_id is not null;

begin
  open num_of_excep;
  fetch num_of_excep into l_number_of_exceptions;
  close num_of_excep;
  return l_number_of_exceptions;
exception
  when NO_DATA_FOUND then
     return l_number_of_exceptions;
end get_number_of_exceptions;

function get_percent_of_tl_in_cm(
arg_plan_id number
) return number IS
    l_percent NUMBER := null;
    l_tl_count NUMBER;
    l_tl_in_cm_count NUMBER;
    cursor tl_count is
    select count(1) from mst_trips
    where plan_id = arg_plan_id
    and mode_of_transport = 'TRUCK'
--Bug_Fix for 3803450
--	and move_type = 2;
    and nvl ( move_type, 2 ) = 2;

    cursor tl_in_cm_count is
    select count(1) from mst_trips
    where plan_id = arg_plan_id
    and mode_of_transport = 'TRUCK'
    and continuous_move_id is not null
--Bug_Fix for 3803450
--	and move_type = 2;
    and nvl ( move_type, 2 ) = 2;

  BEGIN
    OPEN tl_count;
    FETCH tl_count into l_tl_count;
    CLOSE tl_count;
    if l_tl_count = 0 then
      l_tl_count := 1;
    end if;

    OPEN tl_in_cm_count;
    FETCH tl_in_cm_count into l_tl_in_cm_count;
    CLOSE tl_in_cm_count;

    l_percent := round(100*(l_tl_in_cm_count/l_tl_count), 0);
    return l_percent;
end get_percent_of_tl_in_cm;

function get_trip_loading_status(
arg_plan_id number,
arg_trip_id number
) return varchar2 IS
  cursor delivery_leg_count is
  select count(1)
  from mst_delivery_legs
  where plan_id = arg_plan_id
  and trip_id = arg_trip_id;
  l_del_leg_count number;
  l_meaning varchar2(100);

  cursor loading_status(p_del_leg_count NUMBER) is
  select meaning
    from mfg_lookups
    where lookup_type = 'MST_YES_NO'
    and lookup_code = 1;

  BEGIN
    OPEN delivery_leg_count;
    FETCH delivery_leg_count into l_del_leg_count;
    CLOSE delivery_leg_count;

    if(l_del_leg_count = 0) then
       OPEN loading_status(l_del_leg_count);
       FETCH loading_status into l_meaning;
       CLOSE loading_status;
    else
       l_meaning := null;
    end if;
    return l_meaning;
end get_trip_loading_status;
END mst_cm_details;



/
