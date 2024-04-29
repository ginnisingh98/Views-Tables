--------------------------------------------------------
--  DDL for Package Body MST_SNAPSHOT_TASK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_SNAPSHOT_TASK_UTIL" AS
/* $Header: MSTSNTUB.pls 120.1 2005/10/04 22:37:55 saripira noship $ */

Function getCalendar(lLocationId in number,lCalendarType in VARCHAR2 )  return Varchar2
is
cursor getOwnerId is
select lo.owner_type, lo.OWNER_PARTY_ID
from wsh_location_owners lo
where lo.wsh_location_id = lLocationId;

cursor getCustomerId( lownerId in number) is
select hzc.CUST_ACCOUNT_ID
from hz_cust_accounts hzc
where party_id = lownerId
and rownum = 1;

cursor getSupplierId( lownerId in number) is
select hzpr.OBJECT_ID
from hz_relationships hzpr
where hzpr.SUBJECT_ID = lownerId
and hzpr.RELATIONSHIP_CODE = 'POS_VENDOR_PARTY'
 and  hzpr.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND  hzpr.OBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND  hzpr.DIRECTIONAL_FLAG = 'F'
and rownum = 1;

cursor  hr_Calendar(lownerId in number) is
   select assg.CALENDAR_CODE
   from wsh_calendar_assignments assg
   WHERE
     CALENDAR_TYPE = lCalendarType    --'SHIPPING' or 'RECEIVING'
     AND ( (assg.LOCATION_ID = lLocationId  AND
	    ASSOCIATION_TYPE = 'HR_LOCATION') OR
           (assg.ORGANIZATION_ID = lownerId  AND
	    ASSOCIATION_TYPE = 'ORGANIZATION')
         )
    Order By assg.LOCATION_ID;

cursor cust_loc_calendar (lCustId in number) is
 select assg.CALENDAR_CODE
   from wsh_calendar_assignments assg
   WHERE assg.LOCATION_ID = lLocationId
   AND CALENDAR_TYPE = lCalendarType    --'SHIPPING' or 'RECEIVING'
   AND ASSOCIATION_TYPE = 'CUSTOMER_SITE';

cursor cust_calendar(lCustId in number) is
 select assg.CALENDAR_CODE
   from wsh_calendar_assignments assg
   WHERE assg.CUSTOMER_ID = lCustId
   AND CALENDAR_TYPE = lCalendarType    --'SHIPPING' or 'RECEIVING'
   AND ASSOCIATION_TYPE = 'CUSTOMER';

cursor car_loc_calendar(lCarrierId in number) is
 select assg.CALENDAR_CODE
   from wsh_calendar_assignments assg
   WHERE assg.LOCATION_ID = lLocationId
   AND assg.carrier_id = lCarrierId
   AND CALENDAR_TYPE = lCalendarType    --'SHIPPING' or 'RECEIVING'
   AND ASSOCIATION_TYPE = 'CARRIER_SITE';

cursor car_calendar(lCarrier_id in number) is
 select assg.CALENDAR_CODE
   from wsh_calendar_assignments assg
   WHERE
    assg.carrier_id = lCarrier_id
   AND CALENDAR_TYPE = lCalendarType    --'SHIPPING' or 'RECEIVING'
   AND ASSOCIATION_TYPE = 'CARRIER';

cursor sup_loc_calendar(lSupplierId in number) is
 select assg.CALENDAR_CODE
   from wsh_calendar_assignments assg
   WHERE assg.LOCATION_ID = lLocationId
   AND assg.VENDOR_ID = lSupplierId
   AND assg.CALENDAR_TYPE = lCalendarType
   AND assg.ASSOCIATION_TYPE = 'VENDOR_SITE';

cursor sup_calendar(lSupplierId in number) is
 select assg.CALENDAR_CODE
   from wsh_calendar_assignments assg
   WHERE assg.VENDOR_ID = lSupplierId
   AND assg.CALENDAR_TYPE = lCalendarType
   AND assg.ASSOCIATION_TYPE = 'VENDOR';

lOwnerType	NUMBER;
lOwnerId	NUMBER;
lCustomerId	NUMBER;
lSupplierId	NUMBER;
lCalendar	VARCHAR2(30);

begin
open getOwnerId;
fetch getOwnerId into lOwnerType, lOwnerId;
close getOwnerId;

if lOwnerType = 1  then -- ORG
  open hr_Calendar(lOwnerId);
  fetch hr_Calendar into lCalendar;
  if hr_Calendar%NOTFOUND then
     lCalendar := NULL_CHAR_VALUE;
     return(lCalendar);
  end if;
  close hr_Calendar;

elsif lOwnerType = 2 then --customer
  open getCustomerId(lOwnerId);
  fetch getCustomerId into lCustomerId;
  if getCustomerId%NOTFOUND then
   lCalendar := NULL_CHAR_VALUE;
   return(lCalendar);
  end if;
  close getCustomerId;

  open cust_loc_Calendar(lCustomerId);
  fetch cust_loc_Calendar into lCalendar;
  if cust_loc_Calendar%NOTFOUND then
    open cust_calendar(lCustomerId) ;
    fetch cust_calendar into lCalendar;
    if cust_calendar%NOTFOUND then
     lCalendar := NULL_CHAR_VALUE;
    end if;
    close cust_calendar;
  end if;
  close cust_loc_Calendar;
elsif lOwnerType = 3 then --carrier
   open car_loc_Calendar(lOwnerId);
   fetch car_loc_Calendar into lCalendar;
  if car_loc_Calendar%NOTFOUND then
    open car_calendar(lOwnerId) ;
    fetch car_calendar into lCalendar;
    if car_calendar%NOTFOUND then
     lCalendar := NULL_CHAR_VALUE;
    end if;
    close car_calendar;
  end if;
  close car_loc_Calendar;
elsif lOwnerType = 4 then  --suppliers
  open getSupplierId(lOwnerId);
  fetch getSupplierId into lSupplierId;
  if getSupplierId%NOTFOUND then
   lCalendar := NULL_CHAR_VALUE;
   return(lCalendar);
  end if;
  close getSupplierId;

   open sup_loc_Calendar(lSupplierId);
   fetch sup_loc_Calendar into lCalendar;
  if sup_loc_Calendar%NOTFOUND then
    open sup_Calendar(lSupplierId) ;
    fetch sup_Calendar into lCalendar;
    if sup_Calendar%NOTFOUND then
     lCalendar := NULL_CHAR_VALUE;
    end if;
    close sup_Calendar;
  end if;
  close sup_loc_Calendar;
else
  lCalendar := NULL_CHAR_VALUE;
end if;

  if lCalendar <> NULL_CHAR_VALUE then
   /* calendar must be alredy build. */

 	select CALENDAR_CODE
        into lCalendar
 	from bom_calendar_dates
 	where CALENDAR_CODE = lCalendar
         and rownum = 1;

  end if;
 return(lCalendar);

 exception
  when no_Data_found then
      lCalendar := NULL_CHAR_VALUE;
     return(lCalendar);

end;



Function getDeliveryId (ldeliveryId in number,
		      lNullNumber in number)  return NUMBER
is
lDelId Number ;
begin
 select delivery_id
 into lDelId
 from wsh_new_Deliveries
 where Delivery_id = ldeliveryId
 AND  planned_flag in ( 'F'  ,'Y');

return(lDelId);
exception when others then
  lDelId := lNullNumber;
  return(lDelId);

  return(lDelId);
end;



Function getCMVehicleType (lMoveId in number)  return NUMBER
is
 lVehicleTypeId NUMBER;
Cursor vehileType is
  select fvt.vehicle_type_id
  from wsh_trips t,
   fte_trip_moves wt,
   fte_vehicle_types fvt
  WHERE t.trip_id = wt.TRIP_ID
  and wt.MOVE_ID = lMoveId
  and t.VEHICLE_ITEM_ID = fvt.INVENTORY_ITEM_ID
  and t.VEHICLE_ORGANIZATION_ID   = fvt.ORGANIZATION_ID;
begin
open vehileType;
fetch vehileType into lVehicleTypeId;
close vehileType;

return(lVehicleTypeId);
exception when others then
lVehicleTypeId := null;

return(lVehicleTypeId);
end;


Function GET_DEL_OSP_FLAG(ldelivery_id in NUMBER) return varchar2 is
l_osp_flag varchar2(1) ;
begin
 select decode(det.source_line_type_code, 'OSP','Y','N')
into l_osp_flag
from wsh_Delivery_details det,
wsh_delivery_assignments assg,
wsh_new_deliveries del
where del.delivery_id= ldelivery_id
AND   del.delivery_id = assg.delivery_id
AND    assg.delivery_detail_id = det.delivery_detail_id
AND   rownum = 1;
return(l_osp_flag);
exception
  when no_data_found then
   l_osp_flag := 'N';
   return(l_osp_flag);
end;


Procedure LOG_MESSAGE( pBUFF  IN  VARCHAR2)
 IS
 l number := 0;
   BEGIN
      loop
        if l > LENGTH(pBUFF) then
          exit;
        else
           if l+80 > LENGTH(pBUFF) then
              --dbms_output.put_line(substrb(pBUFF,l,LENGTH(pBUFF)- l));
		null;
           else
	     null;
             --dbms_output.put_line(substrb(pBUFF,l,80));
           end if;
           l := l+80;
        end if;
      end loop;
      --dbms_output.put_line(pBUFF);
END LOG_MESSAGE;


Procedure Get_Phase_Status_Code(p_rqst_id IN NUMBER, p_phase_code OUT NOCOPY VARCHAR2, p_status_code OUT NOCOPY VARCHAR2) is
  pragma autonomous_transaction;

  cursor Cur_Rqst_Details (l_rqst_Id IN NUMBER)
  is
  SELECT PHASE_CODE,STATUS_CODE
  FROM Fnd_Concurrent_Requests
  WHERE request_id = l_rqst_Id;

begin

  open  Cur_Rqst_Details (p_rqst_id);
  fetch Cur_Rqst_Details into p_phase_code, p_status_code;
  close Cur_Rqst_Details;

end Get_Phase_Status_Code;




END MST_SNAPSHOT_TASK_UTIL;

/
