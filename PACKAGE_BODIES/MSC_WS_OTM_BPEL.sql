--------------------------------------------------------
--  DDL for Package Body MSC_WS_OTM_BPEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_OTM_BPEL" AS
/* $Header: MSCWOTMB.pls 120.16.12010000.6 2008/09/11 21:15:50 bnaghi ship $  */


g_UserId NUMBER:=0;
--========= PRIVATE FUNCTIONS ===========================
function GetLeadTime(itemId IN NUMBER,
                     orgId IN NUMBER,
                     planId IN NUMBER,
                     srInstanceId IN NUMBER,
                     newArrivalDate IN DATE,
                     adjustedArrivalDate OUT nocopy DATE) RETURN boolean;


function getLastRefreshNumber(orderNumber IN VARCHAR2,
                              lineNumber IN VARCHAR2,
                              releaseNumber IN VARCHAR2) RETURN NUMBER;

function GetProfilePlanId return NUMBER;

--========= IMPLEMENTATION ===========================

function GetLeadTime(itemId IN NUMBER,
                     orgId IN NUMBER,
                     planId IN NUMBER,
                     srInstanceId IN NUMBER,
                     newArrivalDate IN DATE,
                     adjustedArrivalDate OUT nocopy DATE) RETURN boolean is
v_leadTime NUMBER :=0;
v_offset NUMBER :=0;
d1 DATE;
d2 DATE;
d3 DATE;
d4 DATE;
calendarCode varchar2(100);
seq NUMBER :=0;
begin


/*dbms_output.put_line('itemId, ' ||itemId );
dbms_output.put_line(' orgid' || orgid );
dbms_output.put_line(' planId' || planId );
dbms_output.put_line('srInstanceId' || srInstanceId);*/

    select POSTPROCESSING_LEAD_TIME into v_leadTime
    from msc_system_items
    where inventory_item_id = itemId
    and organization_id    = orgid    -- You need both organziation id and inventory_item_id to get an unique item
    and msc_system_items.plan_id = planId
    and msc_system_items.sr_instance_id = srInstanceId;

    if v_leadTime is null then
    	v_leadTime :=0;
    end if;

--dbms_output.put_line('v_leadTime' || v_leadTime);

select calendar_code into calendarCode
from msc_trading_partners
where partner_type = 3
and sr_instance_id = srInstanceId
and sr_tp_id = orgId;

--dbms_output.put_line('Cal Code' || calendarCode);
--dbms_output.put_line('newArrivalDate' || newarrivalDate);

    select n.calendar_date into d4
    from msc_calendar_dates original,
            msc_calendar_dates n
    where original.calendar_code = calendarCode
    and    original.exception_set_id = -1
    and    original.sr_instance_id = srInstanceId
    and    original.calendar_date = newarrivalDate
    and    n.calendar_code = original.calendar_code
    and    n.exception_set_id = original.exception_set_id
    and    n.sr_instance_id = original.sr_instance_id
    and    n.seq_num =  original.seq_num + v_leadTime;

-- SET D4  !!!!!!!!!!!!!
adjustedArrivalDate := d4;
return true;

EXCEPTION
WHEN no_data_found THEN
    adjustedArrivalDate := newarrivalDate + v_leadTime;
    return true;
when  others then
--dbms_output.put_line('Error in calendar');
     return false;

end GetLeadTime;



procedure UpdateKeyDateInCP ( status OUT NOCOPY VARCHAR2) is
cursor getLineIds is
SELECT
   po_line_location_id  , UPDATED_ARRIVAL_DATE
FROM
    MSC_transportation_updates
WHERE order_type = 1;

v_line_location_id NUMBER :=0;
v_arrival_Date DATE;

begin
            AppsInit;

            OPEN getLineIds;
            LOOP
                FETCH getLineIds into  v_line_location_id, v_arrival_Date;
                EXIT WHEN getLineIds%NOTFOUND;
                Update_CP(v_line_location_id,v_arrival_Date, status );

            END LOOP;
            CLOSE getLineIds;

end UpdateKeyDateInCP;


procedure UpdateCP_1 ( tranzId IN NUMBER,
                       status OUT NOCOPY VARCHAR2) is
v_line_location_id NUMBER :=0;
v_arrival_Date DATE;

begin
if tranzId is null then
   status := 'NO_RECORD_TO_UPDATE';
    return;
end if;
            AppsInit;

            SELECT po_line_location_id  , UPDATED_ARRIVAL_DATE
            INTO v_line_location_id, v_arrival_Date
            FROM MSC_transportation_updates
            WHERE order_type = 1
            AND trans_Update_id = tranzId;

            Update_CP(v_line_location_id,v_arrival_Date, status );

end UpdateCP_1;

procedure Update_CP ( lineLocationId IN NUMBER, arrivalDate IN DATE, status OUT NOCOPY VARCHAR2) is
v_cnt NUMBER :=0;
v_last_refresh_number NUMBER;
v_old_key_date date;
v_order_Number varchar2(100);
orderNumber varchar2(240);
v_line_Number NUMBER;
lineNumber varchar2(100);
releaseNumber VARCHAR2(200);
srInstanceId NUMBER:=0;
v_order_Type NUMBER := 0;
req_id NUMBER :=0;
profile_exceptions NUMBER :=0;
userId NUMBER :=0;
location NUMBER :=1;
cursor lookUpSupplies( C_lineLocationId NUMBER, C_srInstanceId NUMBER) is
 SELECT  order_number, purch_line_num, order_type
 --INTO v_order_Number, v_line_Number, v_order_type
    FROM msc_supplies
    WHERE msc_supplies.po_line_location_id = c_lineLocationId
        and plan_id = -1
        and msc_supplies.sr_instance_id = c_srInstanceId
         and msc_supplies.order_type in (1, 11);


begin
srInstanceId := fnd_profile.value('MSC_EBS_INSTANCE_FOR_OTM');
userId := fnd_global.User_id();


OPEN lookUpSupplies(lineLocationId, srInstanceId);
LOOP
FETCH lookUpSupplies  INTO v_order_Number, v_line_Number, v_order_type ;
EXIT WHEN lookUpSupplies%NOTFOUND;


if (v_order_type = 1) then
    select decode(instr(v_order_Number,'('), 0, v_order_Number, substr(v_order_Number, 1, instr(v_order_Number,'(') - 1))
   into orderNumber
     from dual;

      select decode(v_order_type, 1, nvl(substr(v_order_number,instr(v_order_number,'(')+1,instr(v_order_number,'(',1,2)-2
       - instr(v_order_number,'(')),' ') ,  decode(instr(v_order_number,'('),               0, to_char(null),
       substr(v_order_number, instr(v_order_number,'('))))
       into releaseNumber
    from dual;

    else

    orderNumber :=v_order_Number;

     end if;




    lineNumber := v_line_Number; -- number to chars conversion

    select count(*) into v_cnt
    from msc_sup_dem_entries
    where msc_sup_dem_entries.order_number = to_char(orderNumber)
    and msc_sup_dem_entries.line_number = to_number(lineNumber)
--    and msc_sup_dem_entries.release_number = releaseNumber
    and msc_sup_dem_entries.publisher_order_type in (13, 15);


    if v_cnt = 0 then
        status := 'Order not in CP';
        return;
    end if;

   v_last_refresh_number:= getLastRefreshNumber(orderNumber, lineNumber, releaseNumber);

   if ( v_last_refresh_number = 0) then
        status := 'UNKNOWN ERROR';
        return;
   end if;

   v_old_key_date := getKeyDate(orderNumber, lineNumber, releaseNumber, v_last_refresh_number);

   if ( v_old_key_date <> arrivalDate ) then
        update msc_sup_dem_entries
        set key_date = arrivalDate,
            receipt_date = arrivalDate,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = userId
        where msc_sup_dem_entries.order_number = orderNumber
        and msc_sup_dem_entries.line_number = lineNumber
       -- and msc_sup_dem_entries.release_number = releaseNumber
        and msc_sup_dem_entries.last_refresh_number = v_last_refresh_number
        and msc_sup_dem_entries.publisher_order_type in (13, 15)
        and msc_sup_dem_entries.plan_id = -1;

       -- dbms_output.put_line('arrivalDate= ' || arrivalDate || ' orderNumber=' || orderNumber||
     --   ' lineNumber=' || lineNumber || ' releaseNumber= ' || releaseNumber ||
     --   ' v_last_refresh_number=' || v_last_refresh_number);
    end if;

    ---- TO BE DONE
    -- READ PROFILE FOR IF TO GENERATE EXCEPTIONS OR NOT


    profile_exceptions := fnd_profile.value('MSC_WS_OTM_GEN_EXC_CP');
    if ( profile_exceptions = 1) then
        -- GENERATE EXCEPTIONS
           req_id := fnd_request.submit_request('MSC','MSCXNETG','Exception Manager',NULL, false,
                                                   'Y', /*p_early_order*/
                                                   'N', /* p_changed_order */
                                                   'N',/* p_forecast_accuracy*/
                                                   'N',/* p_forecast_mismatch*/
                                                   'Y',/* p_late_order*/
                                                   'N',/* p_material_excess*/
                                                   'N', /* p_material_shortage*/
                                                   'N',/* p_performance*/
                                                   'N',/* p_potential_late_order*/
                                                   'Y',/* p_response_required*/
                                                   'N'); /* p_custom_exception*/


            IF(req_id = 0) THEN
                   status := 'ERROR_GENERATING_EXCEPTIONS_CP' ;
                   return;
            END IF ;
        end if;
        END LOOP;
 CLOSE lookUpSupplies;
 /*   SELECT distinct order_number, purch_line_num, order_type
 INTO v_order_Number, v_line_Number, v_order_type
    FROM msc_supplies
    WHERE msc_supplies.po_line_location_id = lineLocationId
        and plan_id = -1
        and msc_supplies.sr_instance_id = srInstanceId
     --  and msc_supplies.order_type in (1, 11);
      and msc_supplies.order_type=11;*/



status := 'SUCCESS';
EXCEPTION
when no_data_found then
status := 'No CP data found';
return;
when others then
status := 'ERROR in CP';

end Update_CP;

function getLastRefreshNumber(orderNumber IN VARCHAR2,
                              lineNumber IN VARCHAR2,
                              releaseNumber IN VARCHAR2) RETURN NUMBER is
v_last_refresh_number NUMBER :=0;
--cursor get_last(orN VARCHAR2, lN VARCHAR2, rN VARCHAR2) is

cursor get_last(orN VARCHAR2, lN VARCHAR2) is
SELECT
    last_refresh_number
FROM
    msc_sup_dem_entries
WHERE
    msc_sup_dem_entries.order_number = orN
    and msc_sup_dem_entries.line_number = lN
   -- and msc_sup_dem_entries.release_number = rN
ORDER BY last_refresh_number DESC;

begin
            -- don't loop , bring just the first element
           -- OPEN get_last(orderNumber, lineNumber, releaseNumber);
            OPEN get_last(orderNumber, lineNumber);

                FETCH get_last into v_last_refresh_number;

            CLOSE get_last;
return     v_last_refresh_number;
end getLastRefreshNumber;

function getKeyDate(orderNumber IN VARCHAR2,
                              lineNumber IN VARCHAR2,
                              releaseNumber IN VARCHAR2,
                              lastRefreshNumber IN NUMBER) RETURN DATE is
v_old_key_date DATE;

begin
SELECT
    key_date    into v_old_key_date
FROM
    msc_sup_dem_entries
WHERE
    msc_sup_dem_entries.order_number = orderNumber
    and msc_sup_dem_entries.line_number = lineNumber
    --and msc_sup_dem_entries.release_number = releaseNumber
    and msc_sup_dem_entries.last_refresh_number = lastRefreshNumber;

return     v_old_key_date;
end getKeyDate;


procedure UpdatePDS( status OUT nocopy VARCHAR2) is

cursor c_getLineIds is
SELECT
   order_type, TRANS_UPDATE_ID
FROM
    MSC_TRANSPORTATION_UPDATES;

v_order_type NUMBER :=0;
v_id NUMBER :=0;
plan_id NUMBER :=0;

begin
    AppsInit;


  --plan_id := fnd_profile.value('MSC_PROD_PLAN_ID_FOR_OTM_UPDATES');
  plan_id := GetProfilePlanId();

  if ( plan_Id = -3 ) then  -- planId is NONE
    status := 'No Plan to Update.';
    return;
  end if;

  begin
            OPEN c_getLineIds;
            LOOP
                FETCH c_getLineIds into  v_order_type, v_id;
                EXIT WHEN c_getLineIds%NOTFOUND;
                UpdatePDS_Order(v_id, v_order_type, status );
            END LOOP;
            CLOSE c_getLineIds;
 end;

    status := 'SUCCESS';

EXCEPTION when others then
status := 'EXCEPTION_IN_PDS';
END UpdatePDS;

procedure UpdatePDS_1( tranzId IN NUMBER,
                       bpelOrderType IN NUMBER,
                       status OUT nocopy VARCHAR2) is
plan_id NUMBER :=0;
begin

if tranzId is null then
    status := 'NO_RECORD_TO_UPDATE';
    return;
end if;

    AppsInit;

  --plan_id := fnd_profile.value('MSC_PROD_PLAN_ID_FOR_OTM_UPDATES');
  plan_id := GetProfilePlanId();

  if ( plan_Id = -3 ) then  -- planId is NONE
    status := 'No Plan to Update.';
    return;
  end if;

   UpdatePDS_Order(tranzId, bpelOrderType, status );

EXCEPTION when others then
status := 'EXCEPTION_IN_PDS';

END UpdatePDS_1;



PROCEDURE UpdatePDS_Order( transId IN NUMBER ,
                           order_type IN NUMBER,
                           status OUT nocopy varchar2) IS
cursor getProductionPlans is
SELECT plans.plan_id
FROM  msc_plans plans, msc_designators desig
WHERE plans.curr_plan_type in (1,2,3,5)
       AND   plans.organization_id = desig.organization_id
       AND   plans.sr_instance_id = desig.sr_instance_id
       AND   plans.compile_designator = desig.designator
       AND   NVL(desig.disable_date, TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
       AND   plans.organization_selection <> 1
       and   desig.PRODUCTION = 1
       AND   NVL(plans.copy_plan_id,-1) = -1
       AND   NVL(desig.copy_designator_id, -1) = -1;

v_plan_id NUMBER:=0; -- in case planId = -2, we'll use local var
planId NUMBER :=0;

begin

--planId := fnd_profile.value('MSC_PROD_PLAN_ID_FOR_OTM_UPDATES');
planId := GetProfilePlanId();

           if ( planId <> -2) then -- not ALL, but just single value
               if (order_type = 1) then
                    UpdatePDS_PO(planId, transId, status);
               else
                    UpdatePDS_SO(planId, transId, status);
               end if;
            end if;

            if (planId = -2) then -- ALL PLANS
                     OPEN getProductionPlans;
                     LOOP
                         FETCH getProductionPlans into  v_plan_id;
                         EXIT WHEN getProductionPlans%NOTFOUND;
                         if (order_type = 1) then
                            UpdatePDS_PO(v_plan_id, transId, status);
                        else
                            UpdatePDS_SO(v_plan_id, transId, status);
                        end if;
                     END LOOP;
                     CLOSE getProductionPlans;
            end if;

-- no EXCEPTION handling here; let it go up to UpdatePds
end UpdatePDS_Order;

PROCEDURE UpdatePDS_PO( planId IN NUMBER,
                        transId IN NUMBER,
                        status OUT nocopy varchar2) IS
isPoShipment NUMBER :=0;
begin
     UpdateNewColumnAndFirmDate_PO(planId, transId, isPoShipment, status);
     if ( status = 'SUCCESS') then
        GenerateException(planId, transId, isPoShipment, status);
    end if;
end UpdatePDS_PO;

PROCEDURE UpdatePDS_SO( planId IN NUMBER,
                        transId IN NUMBER,
                        status OUT nocopy varchar2) IS
begin
       UpdateNewColumnAndFirmDate_SO(planId, transId, status);
       if ( status = 'SUCCESS') then
            GenerateException_SO(planId, transId, status);
       end if;
end UpdatePDS_SO;


PROCEDURE GenerateException( planId IN NUMBER,
                                transId IN NUMBER,
                                isPoShipment IN NUMBER,
                                status out nocopy varchar2) IS
newArrivalDate DATE;
srInstanceId NUMBER :=0;
v_org_id NUMBER :=0;
v_inv_item_id NUMBER:=0;
v_supplier_id NUMBER:=0;
v_q NUMBER :=0;
v_supplier_site_id NUMBER:=0;
v_source_sr_inst_id NUMBER :=0;
v_sr_org_id NUMBER :=0;
v_order_number varchar2(240);
userId NUMBER;
v_old_dock_date DATE;
excType NUMBER :=0;
countItemExc NUMBER :=0;
supp_Transaction_id NUMBER :=0;
count_exc_this_order NUMBER :=0;

-- IF I NEED TO PUT TRANSACTION_ID, I NEED TO GENERATE ONE EXCEPTION FOR EACH ROW !! IF NOT, JUST ONE EXC PER LINE ITEM
begin

if ( isPoShipment = 1) then
            SELECT distinct s.transaction_id, tu.UPDATED_ARRIVAL_DATE, tu.EBS_SR_INSTANCE_ID, s.ORGANIZATION_ID, s.INVENTORY_ITEM_ID, s.supplier_id, s.supplier_site_id,
            s.new_dock_date, s.order_number,
            s.NEW_ORDER_QUANTITY, s.SOURCE_SR_INSTANCE_ID, s.SOURCE_ORGANIZATION_ID
            INTO supp_Transaction_id, newArrivalDate, srInstanceId, v_org_id, v_inv_item_id, v_supplier_id, v_supplier_site_id, v_old_dock_date, v_order_number, v_q,
            v_source_sr_inst_id, v_sr_org_id
            FROM MSC_SUPPLIES s, MSC_TRANSPORTATION_UPDATES tu
            WHERE s.ORDER_TYPE = 11
                AND s.PO_LINE_LOCATION_ID = tu.PO_LINE_LOCATION_ID
                AND  s.SUPPLIER_ID is not null
                AND s.PLAN_ID = planId
                AND s.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
                AND tu.TRANS_UPDATE_ID = transId;


else
            SELECT distinct s.transaction_id, tu.UPDATED_ARRIVAL_DATE, tu.EBS_SR_INSTANCE_ID,s.ORGANIZATION_ID, s.INVENTORY_ITEM_ID, s.supplier_id,
            s.supplier_site_id, s.new_dock_date, s.order_number,
            s.NEW_ORDER_QUANTITY, s.SOURCE_SR_INSTANCE_ID,s.SOURCE_ORGANIZATION_ID
            INTO supp_Transaction_id, newArrivalDate, srInstanceId, v_org_id, v_inv_item_id, v_supplier_id, v_supplier_site_id, v_old_dock_date, v_order_number, v_q,
            v_source_sr_inst_id, v_sr_org_id
            FROM MSC_SUPPLIES s, MSC_TRANSPORTATION_UPDATES tu
             WHERE s.ORDER_TYPE = 1
                AND s.PO_LINE_LOCATION_ID = tu.PO_LINE_LOCATION_ID
                AND s.PO_LINE_ID = tu.PO_LINE_ID
                AND s.PLAN_ID =planId
                AND s.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
                AND tu.TRANS_UPDATE_ID = transId;

end if;

            --userId := fnd_global.USER_ID();
            userId := g_UserId;

            if v_old_dock_date < newArrivalDate then
                excType := 119;  -- late replenishment
            else
                excType := 118; -- early replenishment
            end if;

select count(1)
into count_exc_this_order
from msc_exception_details
where exception_type = excType
and plan_id = planId
and organization_id =v_org_id
and inventory_item_id =v_inv_item_id
and resource_id =-1 and department_id = -1
and sr_Instance_id = srInstanceId
and supplier_id = v_supplier_id
and order_number =v_order_number;

if ( count_exc_this_order > 0) then
                        update msc_exception_details
                        set   date2=newArrivalDate
                        where exception_type = excType
                                and plan_id = planId
                                and organization_id =v_org_id
                                and inventory_item_id =v_inv_item_id
                                and resource_id =-1 and department_id = -1
                                and sr_Instance_id = srInstanceId
                                and supplier_id = v_supplier_id
                                and order_number =v_order_number;

    status := 'Exception for this order already inserted. Updated new Arrival Date';
    return;
end if;



select count(1)
into countItemExc
from msc_item_exceptions
where  plan_id = planId
and organization_id = v_org_id
and sr_Instance_id = srInstanceId
and inventory_item_id = v_inv_item_id
and exception_type = excType;



if ( countItemExc = 0) then
        INSERT INTO msc_item_exceptions(plan_id, organization_id, sr_Instance_id, inventory_item_id, exception_type,
                                         exception_group,
                                         LAST_UPDATE_DATE , LAST_UPDATED_BY , CREATION_DATE ,CREATED_BY,
                                         supplier_id, supplier_site_id, exception_count)
                                VALUES(planId, v_org_id, srInstanceId,v_inv_item_id, excType,
                                          21,
                                          SYSDATE, userId, SYSDATE, userId,
                                          v_supplier_id, v_supplier_site_id, 1);

else
        select exception_count
        into countItemExc
        from msc_item_exceptions
        where  plan_id = planId
        and organization_id = v_org_id
        and sr_Instance_id = srInstanceId
        and inventory_item_id = v_inv_item_id
        and exception_type = excType;

        countItemExc := countItemExc +1;
        --dbms_output.put_line('countExc=' || countItemExc);

        update msc_item_exceptions
        set exception_count = countItemExc,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = userId
         where  plan_id = planId
        and organization_id = v_org_id
        and sr_Instance_id = srInstanceId
        and inventory_item_id = v_inv_item_id
        and exception_type = excType;

end if;

INSERT into msc_exception_details
                        (
                        exception_detail_id, exception_type, plan_id, organization_id, inventory_item_id, resource_id, -- -1
			department_id, sr_Instance_id, LAST_UPDATE_DATE , LAST_UPDATED_BY , CREATION_DATE ,CREATED_BY,
			supplier_id, supplier_site_id, order_number, date2, date1, quantity, number1, number2,
                        transaction_id
			)

                        VALUES (MSC_EXCEPTION_DETAILS_S.nextval,  excType, planId, v_org_id, v_inv_item_id, -1,
                        -1, srInstanceId, SYSDATE, userId, SYSDATE, userId,
                        v_supplier_id, v_supplier_site_id, v_order_number, newArrivalDate, v_old_dock_date,v_q, v_sr_org_id, v_source_sr_inst_id,
                        supp_Transaction_id);


status := 'SUCCESS';

EXCEPTION
when no_data_found then
status := 'No exception generated';
return;
when others then
status := 'ERROR in Gen Exceptions';
return;

end GenerateException;

PROCEDURE GenerateException_SO( planId IN NUMBER,
                                transId IN NUMBER,
                                status out nocopy varchar2) IS
cursor GetSupplierDataForIR_shipment( srIId IN NUMBER) is
SELECT s2.transaction_id, s2.supplier_id, s2.supplier_site_id, s2.new_dock_date, s2.order_number, s2.INVENTORY_ITEM_ID,
 s2.SOURCE_ORGANIZATION_ID , s2.ORGANIZATION_ID, s2.NEW_ORDER_QUANTITY, s2.SR_INSTANCE_ID
        FROM MSC_SUPPLIES s2, MSC_SALES_ORDERS sO, MSC_DELIVERY_DETAILS dd, MSC_TRANSPORTATION_UPDATES tu
        WHERE s2.ORDER_TYPE = 11 -- IR Shipment
            AND s2.PLAN_ID =planId
            AND s2.SR_INSTANCE_ID = srIId
            AND SO.SR_INSTANCE_ID = srIId
        AND dd.SR_INSTANCE_ID = srIId
        AND tu.EBS_SR_INSTANCE_ID = srIId
        AND s2.REQ_LINE_ID = SO.ORIGINAL_SYSTEM_LINE_REFERENCE
        AND sO.DEMAND_SOURCE_LINE = dd.SOURCE_LINE_ID
        AND dd.DELIVERY_DETAIL_ID = tu.OTM_RELEASE_LINE_GID
        AND tu.Trans_update_id = transId;

newArrivalDate DATE;
SrInstanceId NUMBER :=0;
v_org_id NUMBER :=0;
v_sr_org_id NUMBER :=0;
v_inv_item_id NUMBER:=0;
v_supplier_id NUMBER:=0;
v_q NUMBER :=0;
v_source_sr_Inst_id NUMBEr :=0;
v_supplier_site_id NUMBER:=0;
v_demand_id NUMBER :=0;
v_order_number varchar2(240);
userId NUMBER;
v_old_dock_date DATE;
excType NUMBER :=0;
countItemExc NUMBER :=0;
supp_Transaction_id NUMBER :=0;
ISOID1 NUMBER :=0;
count_exc_this_order NUMBER :=0;

-- IF I NEED TO PUT TRANSACTION_ID, I NEED TO GENERATE ONE EXCEPTION FOR EACH ROW !! IF NOT, JUST ONE EXC PER LINE ITEM
begin

            select UPDATED_ARRIVAL_DATE, EBS_SR_INSTANCE_ID  into newArrivalDate, SrInstanceId
            from msc_transportation_updates
            where TRANS_UPDATE_ID = transId;

            SELECT distinct d.DEMAND_ID
            INTO ISOID1
            FROM MSC_DEMANDS d, MSC_DELIVERY_DETAILS dd, MSC_TRANSPORTATION_UPDATES tu
            WHERE d.SALES_ORDER_LINE_ID = dd.SOURCE_LINE_ID
                    AND dd.DELIVERY_DETAIL_ID = tu.OTM_RELEASE_LINE_GID
                    AND dd.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
                    AND d.PLAN_ID = planId
                    AND d.ORIGINATION_TYPE = 30
                    AND tu.Trans_update_id = transId;

            SELECT distinct s.transaction_id, s.supplier_id, s.supplier_site_id, s.new_dock_date, s.order_number, d.INVENTORY_ITEM_ID,
                    d.SOURCE_ORGANIZATION_ID , d.ORGANIZATION_ID, s.NEW_ORDER_QUANTITY, s.SR_INSTANCE_ID--IR
            INTO  supp_Transaction_id, v_supplier_id, v_supplier_site_id, v_old_dock_date, v_order_number, v_inv_item_id,
                v_sr_org_id, v_org_id, v_q, v_source_sr_Inst_id
            FROM MSC_SUPPLIES s,  MSC_DEMANDS d
            WHERE s.ORDER_TYPE = 2 -- IR
                AND s.TRANSACTION_ID = d.DISPOSITION_ID
                AND s.PLAN_ID =planId
                AND s.SR_INSTANCE_ID = SrInstanceId
                AND d.DEMAND_ID  = ISOID1;

           /* if ( v_inv_item_id =0  ) then
                   OPEN GetSupplierDataForIR_shipment(SrInstanceId);
                    LOOP
                    FETCH GetSupplierDataForIR_shipment into  supp_Transaction_id, v_supplier_id, v_supplier_site_id, v_old_dock_date, v_order_number, v_inv_item_id,
                        v_sr_org_id, v_org_id, v_q, v_source_sr_Inst_id;
                    EXIT WHEN GetSupplierDataForIR_shipment%NOTFOUND;
                    END LOOP;
                    CLOSE GetSupplierDataForIR_shipment;
            end if;*/

--dbms_output.put_line('passed 2');

            --userId := fnd_global.USER_ID();
            userId := g_UserId;

            if v_old_dock_date < newArrivalDate then
                excType := 119;  -- late replenishment
            else
                excType := 118; -- early replenishment
            end if;


select count(1)
into count_exc_this_order
from msc_exception_details
where exception_type = excType
and plan_id = planId
and organization_id =v_org_id
and inventory_item_id =v_inv_item_id
and resource_id =-1 and department_id = -1
and sr_Instance_id = srInstanceId
and supplier_id = v_supplier_id
and order_number =v_order_number;

if ( count_exc_this_order > 0) then
                        update msc_exception_details
                        set   date2=newArrivalDate
                        where exception_type = excType
                                and plan_id = planId
                                and organization_id =v_org_id
                                and inventory_item_id =v_inv_item_id
                                and resource_id =-1 and department_id = -1
                                and sr_Instance_id = srInstanceId
                                and supplier_id = v_supplier_id
                                and order_number =v_order_number;

    status := 'Exception for this order already inserted. Updated new Arrival Date';
    return;
end if;

select count(1)
into countItemExc
from msc_item_exceptions
where  plan_id = planId
and organization_id = v_org_id
and sr_Instance_id = srInstanceId
and inventory_item_id = v_inv_item_id
and exception_type = excType;

--dbms_output.put_line('countItemExec=' || countItemExc);


if ( countItemExc = 0) then
        INSERT INTO msc_item_exceptions(plan_id, organization_id, sr_Instance_id, inventory_item_id, exception_type,
                                        exception_group,
                                         LAST_UPDATE_DATE , LAST_UPDATED_BY , CREATION_DATE ,CREATED_BY,
                                         supplier_id, supplier_site_id, exception_count)
                                VALUES(planId, v_org_id, srInstanceId,v_inv_item_id, excType,
                                         21,
                                          SYSDATE, userId, SYSDATE, userId,
                                          v_supplier_id, v_supplier_site_id, 1);

else
/*dbms_output.put_line('plan_id=' || planId);
dbms_output.put_line('v_org_id=' || v_org_id);
dbms_output.put_line('srInstanceId=' || srInstanceId);
dbms_output.put_line('v_inv_item_id=' || v_inv_item_id);
dbms_output.put_line('excType=' || excType);*/

        select exception_count
        into countItemExc
        from msc_item_exceptions
        where  plan_id = planId
        and organization_id = v_org_id
        and sr_Instance_id = srInstanceId
        and inventory_item_id = v_inv_item_id
        and exception_type = excType;

        countItemExc := countItemExc +1;
        --dbms_output.put_line('countExc=' || countItemExc);

        update msc_item_exceptions
        set exception_count = countItemExc,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = userId
         where  plan_id = planId
        and organization_id = v_org_id
        and sr_Instance_id = srInstanceId
        and inventory_item_id = v_inv_item_id
        and exception_type = excType;


end if;

--dbms_output.put_line(supp_Transaction_id);
INSERT into msc_exception_details
                        (
                        exception_detail_id, exception_type, plan_id, organization_id, inventory_item_id, resource_id, -- -1
			department_id, sr_Instance_id, LAST_UPDATE_DATE , LAST_UPDATED_BY , CREATION_DATE ,CREATED_BY,
			supplier_id, supplier_site_id, order_number, date2, date1, quantity, number1, number2,
                        transaction_id
			)

                        VALUES (MSC_EXCEPTION_DETAILS_S.nextval,  excType, planId, v_org_id, v_inv_item_id, -1,
                        -1, srInstanceId, SYSDATE, userId, SYSDATE, userId,
                        v_supplier_id, v_supplier_site_id, v_order_number, newArrivalDate, v_old_dock_date, v_q,
                        v_sr_org_id, v_source_sr_Inst_id, supp_Transaction_id);


status := 'SUCCESS';

EXCEPTION
when others then
status := 'ERROR in Gen Exceptions';


end GenerateException_SO;

PROCEDURE UpdateNewColumnAndFirmDate_PO( planId IN NUMBER,
                        transId IN NUMBER,
                        isPoShipment out nocopy NUMBER,
                        status out nocopy varchar2) IS

cursor GetPOIds is
        SELECT s.TRANSACTION_ID
        FROM MSC_SUPPLIES s, MSC_TRANSPORTATION_UPDATES tu
        WHERE s.ORDER_TYPE = 1
                AND s.PO_LINE_LOCATION_ID = tu.PO_LINE_LOCATION_ID
                AND s.PO_LINE_ID = tu.PO_LINE_ID
                AND s.PLAN_ID =planId
                AND s.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
                AND tu.TRANS_UPDATE_ID = transId;

cursor GetPOShipmentIds is
        SELECT s.TRANSACTION_ID
        FROM MSC_SUPPLIES s, MSC_TRANSPORTATION_UPDATES tu
        WHERE s.ORDER_TYPE = 11
                AND s.PO_LINE_LOCATION_ID = tu.PO_LINE_LOCATION_ID
                AND  s.SUPPLIER_ID is not null
                AND s.PLAN_ID = planId
                AND s.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
                AND tu.TRANS_UPDATE_ID = transId;


PO_Ids MscNumberArr := MscNumberArr();
--PO_Shipment_ids MscNumberArr := MscNumberArr();
invItemId NUMBER :=0;
orgId NUMBER :=0;
newArrivalDate DATE;
v_new_firm_Date DATE;
SrInstanceId NUMBER :=0;
v_temp NUMBER :=0;
i NUMBER :=0;
userId NUMBER :=0;
begin

select UPDATED_ARRIVAL_DATE, EBS_SR_INSTANCE_ID  into newArrivalDate, SrInstanceId
from msc_transportation_updates
where TRANS_UPDATE_ID = transId;

--- Get PO_Ids
            i:=1;
            OPEN GetPOIds;
            LOOP
                FETCH GetPOIds into  v_temp;
                EXIT WHEN GetPOIds%NOTFOUND;
                PO_Ids.extend;
                PO_Ids(i) := v_temp;
                i := i+1;
            END LOOP;
            CLOSE GetPOIds;

if ( i = 1) then  --  PO shipment, not PO
   isPoShipment := 1;
   select distinct s.INVENTORY_ITEM_ID, s.ORGANIZATION_ID into invItemId, orgId
    FROM MSC_SUPPLIES s, MSC_TRANSPORTATION_UPDATES tu
    WHERE s.ORDER_TYPE = 11
    AND s.PO_LINE_LOCATION_ID = tu.PO_LINE_LOCATION_ID
    AND s.PLAN_ID =planId
    AND s.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
    AND tu.TRANS_UPDATE_ID = transId;

else
  isPoShipment := 0;
   select distinct s.INVENTORY_ITEM_ID, s.ORGANIZATION_ID into invItemId, orgId
    FROM MSC_SUPPLIES s, MSC_TRANSPORTATION_UPDATES tu
    WHERE s.ORDER_TYPE = 1
    AND s.PO_LINE_LOCATION_ID = tu.PO_LINE_LOCATION_ID
    AND s.PO_LINE_ID = tu.PO_LINE_ID
    AND s.PLAN_ID =planId
    AND s.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
    AND tu.TRANS_UPDATE_ID = transId;

end if;

--dbms_output.put_line( ' passed 3');

--- Get PO_Shipment_ids  ( add them in same array, so that looping done easier

            OPEN GetPOShipmentIds;
            LOOP
                FETCH GetPOShipmentIds into  v_temp;
                EXIT WHEN GetPOShipmentIds%NOTFOUND;
                PO_Ids.extend;
                PO_Ids(i) := v_temp;
                i := i+1;
            END LOOP;
            CLOSE GetPOShipmentIds;

if ( i =1 ) then  -- no orders found, no PO, no PO shipment
    status := 'NO_ORDERS_FOUND_TO_UPDATE';
    return;
end if;

if ( GetLeadTime(invItemId, orgId, planId, SrInstanceId, newArrivalDate, v_new_firm_Date) = false) then
  v_new_firm_Date := newArrivalDate;
end if;

    --userId := fnd_global.User_id();
    userId := g_UserId;
--dbms_output.put_line('got leadTime' || v_new_firm_date);

    UPDATE msc_transportation_updates
    SET UPDATED_DUE_DATE = v_new_firm_Date,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = userId
    WHERE TRANS_UPDATE_ID = transId;

    i:=0;
     FOR i IN 1 .. PO_Ids.COUNT
     LOOP
     --dbms_output.put_line(' tranz_id = ' || PO_Ids(i));
            UPDATE MSC_SUPPLIES
            Set   FIRM_DATE = v_new_firm_Date,
                  APPLIED = 2,
                  STATUS  = 0,
                  FIRM_PLANNED_TYPE = 1,
                  OTM_ARRIVAL_DATE = newArrivalDate,
                  FIRM_QUANTITY = NEW_ORDER_QUANTITY,
                  LAST_UPDATE_DATE = SYSDATE,
                  LAST_UPDATED_BY = userId
            WHERE TRANSACTION_ID = PO_Ids(i)
                  AND SR_INSTANCE_ID = SrInstanceId
                  AND PLAN_ID = planId;

    END LOOP ;

status := 'SUCCESS';

EXCEPTION
when no_data_found then
status := ' NO_ORDERS_FOUND_TO_UPDATE_IN_PDS';

when others then
status := 'ERROR_PDS_PO';

end UpdateNewColumnAndFirmDate_PO;


PROCEDURE UpdateNewColumnAndFirmDate_SO( planId IN NUMBER,
                        transId IN NUMBER , status out nocopy varchar2) IS
/*cursor GetIR_Shipments( srIId IN NUMBER ) is
SELECT s2.TRANSACTION_ID
        FROM MSC_SUPPLIES s2, MSC_SALES_ORDERS sO, MSC_DELIVERY_DETAILS dd, MSC_TRANSPORTATION_UPDATES tu
        WHERE s2.ORDER_TYPE = 11 -- IR Shipment
            AND s2.PLAN_ID =planId
            AND s2.SR_INSTANCE_ID = srIId
            AND SO.SR_INSTANCE_ID = srIId
        AND dd.SR_INSTANCE_ID = srIId
        AND tu.EBS_SR_INSTANCE_ID = srIId
        AND s2.REQ_LINE_ID = SO.ORIGINAL_SYSTEM_LINE_REFERENCE
        AND sO.DEMAND_SOURCE_LINE = dd.SOURCE_LINE_ID
        AND dd.DELIVERY_DETAIL_ID = tu.OTM_RELEASE_LINE_GID
        AND tu.Trans_update_id = transId;*/

/*ISO_Ids MscNumberArr := MscNumberArr();
IR_Ids MscNumberArr := MscNumberArr();
IR_Shipment_ids MscNumberArr := MscNumberArr();*/

ISOID1 NUMBER :=0;
IRID1 NUMBER :=0;

invItemId NUMBER :=0;
orgId NUMBER :=0;
newArrivalDate DATE;
v_new_firm_Date DATE;
SrInstanceId NUMBER :=0;
i NUMBER :=0;
v_temp NUMBER :=0;
userId NUMBER :=0;
begin

--dbms_output.put_line(fnd_profile.value('MSC_EBS_INSTANCE_FOR_OTM'));

select UPDATED_ARRIVAL_DATE, EBS_SR_INSTANCE_ID  into newArrivalDate, SrInstanceId
from msc_transportation_updates
where TRANS_UPDATE_ID = transId;

-- is this only one result ????? or more ???
    select  distinct d.INVENTORY_ITEM_ID, d.SOURCE_ORGANIZATION_ID into invItemId, orgId
    FROM MSC_DEMANDS d, MSC_DELIVERY_DETAILS dd, MSC_TRANSPORTATION_UPDATES tu
    WHERE d.SALES_ORDER_LINE_ID = to_char(dd.SOURCE_LINE_ID)
       AND d.SR_INSTANCE_ID = dd.SR_INSTANCE_ID
       AND dd.DELIVERY_DETAIL_ID = tu.OTM_RELEASE_LINE_GID
       AND dd.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
       AND d.PLAN_ID = planId
       AND d.ORIGINATION_TYPE = 30
       AND tu.TRANS_UPDATE_ID = transId;

        SELECT distinct d.DEMAND_ID
        into ISOID1
        FROM MSC_DEMANDS d, MSC_DELIVERY_DETAILS dd, MSC_TRANSPORTATION_UPDATES tu
        WHERE d.SALES_ORDER_LINE_ID = dd.SOURCE_LINE_ID
                AND d.SR_INSTANCE_ID = dd.SR_INSTANCE_ID
                AND dd.DELIVERY_DETAIL_ID = tu.OTM_RELEASE_LINE_GID
                AND dd.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
                AND d.PLAN_ID = planId
                AND d.ORIGINATION_TYPE = 30
                AND tu.Trans_update_id = transId;

--userId := fnd_global.User_id();
userId := g_UserId;


--Update all ISOs

            UPDATE MSC_DEMANDS
            Set   OTM_ARRIVAL_DATE = newArrivalDate,
                  LAST_UPDATE_DATE = SYSDATE,
                  LAST_UPDATED_BY = userId
            WHERE PLAN_ID = planId
                 AND  SR_INSTANCE_ID = SrInstanceId
                 AND DEMAND_ID = ISOID1;

--Select all IRs ---------------------

--dbms_output.put_line(ISOID1);
            SELECT distinct s.TRANSACTION_ID --IR_Ids
            INTO IRID1
            FROM MSC_SUPPLIES s,  MSC_DEMANDS d
            WHERE s.ORDER_TYPE = 2 -- IR
                AND s.TRANSACTION_ID = d.DISPOSITION_ID
                AND s.PLAN_ID =planId
                AND d.PLAN_ID =planId
                AND s.SR_INSTANCE_ID = srInstanceId
                AND d.DEMAND_ID  = ISOID1;

-- select all IR shipments -- put all IR_Shipment ids in same array as IR_IDs, easier to loop
     /*  OPEN GetIR_Shipments(SrInstanceId);
            LOOP
                FETCH GetIR_Shipments into  v_temp;
                EXIT WHEN GetIR_Shipments%NOTFOUND;
                IR_Ids.extend;
                IR_Ids(i) := v_temp;
                i := i+1;
            END LOOP;
            CLOSE GetIR_Shipments;*/


if ( ISOID1=0 and IRID1 = 0) then
 status := 'NO_ISO_IR_IRSHIPMENTS_FOUND';
 return;
end if;


if ( GetLeadTime(invItemId, orgId, planId, SrInstanceId, newArrivalDate, v_new_firm_Date) = false) then
  v_new_firm_Date := newArrivalDate;
end if;

    UPDATE msc_transportation_updates
    SET UPDATED_DUE_DATE = v_new_firm_Date,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = userId
    WHERE TRANS_UPDATE_ID = transId;

    -- IR for now, IR shipment later
            --update both IRs and IR shipments
            UPDATE MSC_SUPPLIES
            Set FIRM_DATE = v_new_firm_Date,
                  APPLIED = 2,
                  STATUS  = 0,
                  FIRM_PLANNED_TYPE = 1,
                 OTM_ARRIVAL_DATE = newArrivalDate,
                 FIRM_QUANTITY = NEW_ORDER_QUANTITY,
                 LAST_UPDATE_DATE = SYSDATE,
                 LAST_UPDATED_BY = userId
            WHERE
                 PLAN_ID =planId
                 AND  SR_INSTANCE_ID = SrInstanceId
                 AND TRANSACTION_ID = IRID1;


status := 'SUCCESS';

EXCEPTION
when no_data_found then
status := 'NO_ISO_IR_FOUND';
return;
when others then
status := 'ERROR_in_PDS_SO';
return;
end UpdateNewColumnAndFirmDate_SO;

PROCEDURE UpdateNewColumnAndFirmDate_SO_( planId IN NUMBER,
                        transId IN NUMBER , status out nocopy varchar2) IS
cursor GetISOs is
        SELECT d.DEMAND_ID
        FROM MSC_DEMANDS d, MSC_DELIVERY_DETAILS dd, MSC_TRANSPORTATION_UPDATES tu
        WHERE d.SALES_ORDER_LINE_ID = dd.SOURCE_LINE_ID
                AND d.SR_INSTANCE_ID = dd.SR_INSTANCE_ID
                AND dd.DELIVERY_DETAIL_ID = tu.OTM_RELEASE_LINE_GID
                AND dd.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
                AND d.PLAN_ID = planId
                AND d.ORIGINATION_TYPE = 30
                AND tu.Trans_update_id = transId;

cursor GetIR_IDs (srIId IN NUMBER)   is
            SELECT s.TRANSACTION_ID --IR_Ids
            FROM MSC_SUPPLIES s,  MSC_DEMANDS d
            WHERE s.ORDER_TYPE = 2 -- IR
                AND s.TRANSACTION_ID = d.DISPOSITION_ID
                AND s.PLAN_ID =planId
                AND s.SR_INSTANCE_ID = srIId
                AND d.DEMAND_ID  IN ( SELECT d.DEMAND_ID
                                    FROM MSC_DEMANDS d, MSC_DELIVERY_DETAILS dd, MSC_TRANSPORTATION_UPDATES tu
                                    WHERE d.SALES_ORDER_LINE_ID = dd.SOURCE_LINE_ID
                                            AND dd.DELIVERY_DETAIL_ID = tu.OTM_RELEASE_LINE_GID
                                            AND dd.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
                                            AND d.PLAN_ID = planId
                                            AND d.ORIGINATION_TYPE = 30
                                            AND tu.Trans_update_id = transId);


cursor GetIR_Shipments( srIId IN NUMBER ) is
SELECT s2.TRANSACTION_ID
        FROM MSC_SUPPLIES s2, MSC_SALES_ORDERS sO, MSC_DELIVERY_DETAILS dd, MSC_TRANSPORTATION_UPDATES tu
        WHERE s2.ORDER_TYPE = 11 -- IR Shipment
            AND s2.PLAN_ID =planId
            AND s2.SR_INSTANCE_ID = srIId
            AND SO.SR_INSTANCE_ID = srIId
        AND dd.SR_INSTANCE_ID = srIId
        AND tu.EBS_SR_INSTANCE_ID = srIId
        AND s2.REQ_LINE_ID = SO.ORIGINAL_SYSTEM_LINE_REFERENCE
        AND sO.DEMAND_SOURCE_LINE = dd.SOURCE_LINE_ID
        AND dd.DELIVERY_DETAIL_ID = tu.OTM_RELEASE_LINE_GID -- maybe use wsh_delive from MTU
        AND tu.Trans_update_id = transId;




ISO_Ids MscNumberArr := MscNumberArr();
IR_Ids MscNumberArr := MscNumberArr();
IR_Shipment_ids MscNumberArr := MscNumberArr();
invItemId NUMBER :=0;
orgId NUMBER :=0;
newArrivalDate DATE;
v_new_firm_Date DATE;
SrInstanceId NUMBER :=0;
i NUMBER :=0;
v_temp NUMBER :=0;
userId NUMBER :=0;
begin

--dbms_output.put_line(fnd_profile.value('MSC_EBS_INSTANCE_FOR_OTM'));



select UPDATED_ARRIVAL_DATE, EBS_SR_INSTANCE_ID  into newArrivalDate, SrInstanceId
from msc_transportation_updates
where TRANS_UPDATE_ID = transId;

--dbms_output.put_line(planId);

-- is this only one result ????? or more ???
select  d.INVENTORY_ITEM_ID, d.SOURCE_ORGANIZATION_ID into invItemId, orgId
FROM MSC_DEMANDS d, MSC_DELIVERY_DETAILS dd, MSC_TRANSPORTATION_UPDATES tu
WHERE d.SALES_ORDER_LINE_ID = dd.SOURCE_LINE_ID
       AND d.SR_INSTANCE_ID = dd.SR_INSTANCE_ID
       AND dd.DELIVERY_DETAIL_ID = tu.OTM_RELEASE_LINE_GID
       AND dd.SR_INSTANCE_ID = tu.EBS_SR_INSTANCE_ID
     AND d.PLAN_ID = planId
     AND d.ORIGINATION_TYPE = 30
     AND tu.TRANS_UPDATE_ID = transId;


--select all ISO
            i:=1;
            OPEN GetISOs;
            LOOP
                FETCH GetISOs into  v_temp;
                EXIT WHEN GetISOs%NOTFOUND;
                ISO_Ids.extend;
                ISO_Ids(i) := v_temp;
                i := i+1;
            END LOOP;
            CLOSE GetISOs;

--userId := fnd_global.User_id();
userId := g_UserId;


--Update all ISOs
    i:=1;
     FOR i IN 1 .. ISO_Ids.COUNT
     LOOP
            UPDATE MSC_DEMANDS
            Set   OTM_ARRIVAL_DATE = newArrivalDate,
                  LAST_UPDATE_DATE = SYSDATE,
                  LAST_UPDATED_BY = userId
            WHERE PLAN_ID = planId
                 AND  SR_INSTANCE_ID = SrInstanceId
                 AND DEMAND_ID = ISO_Ids(i);

     END LOOP;


--Select all IRs ---------------------

            i:=1;
            OPEN GetIR_IDs(SrInstanceId);
            LOOP
                FETCH GetIR_IDs into  v_temp;
                EXIT WHEN GetIR_IDs%NOTFOUND;
                IR_Ids.extend;
                IR_Ids(i) := v_temp;
                i := i+1;
            END LOOP;
            CLOSE GetIR_IDs;


-- select all IR shipments -- put all IR_Shipment ids in same array as IR_IDs, easier to loop
     /*  OPEN GetIR_Shipments(SrInstanceId);
            LOOP
                FETCH GetIR_Shipments into  v_temp;
                EXIT WHEN GetIR_Shipments%NOTFOUND;
                IR_Ids.extend;
                IR_Ids(i) := v_temp;
                i := i+1;
            END LOOP;
            CLOSE GetIR_Shipments;*/


if ( i = 1) then
 status := 'NO_ISO_IR_IRSHIPMENTS_FOUND';
 return;
end if;


if ( GetLeadTime(invItemId, orgId, planId, SrInstanceId, newArrivalDate, v_new_firm_Date) = false) then
  v_new_firm_Date := newArrivalDate;
end if;

    UPDATE msc_transportation_updates
    SET UPDATED_DUE_DATE = v_new_firm_Date,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = userId
    WHERE TRANS_UPDATE_ID = transId;

     FOR i IN 1 .. IR_Ids.COUNT
     LOOP
            --update both IRs and IR shipments
            UPDATE MSC_SUPPLIES
            Set FIRM_DATE = v_new_firm_Date,
                  APPLIED = 2,
                  STATUS  = 0,
                  FIRM_PLANNED_TYPE = 1,
                 OTM_ARRIVAL_DATE = newArrivalDate,
                 FIRM_QUANTITY = NEW_ORDER_QUANTITY,
                 LAST_UPDATE_DATE = SYSDATE,
                 LAST_UPDATED_BY = userId
            WHERE
                 PLAN_ID =planId
                 AND  SR_INSTANCE_ID = SrInstanceId
                 AND TRANSACTION_ID = IR_Ids(i); --in (IR_Ids, IR_Shipment_ids);
     END LOOP;

status := 'SUCCESS';

EXCEPTION
when no_data_found then
status := 'NO_ISO_IR_FOUND';
return;
when others then
status := 'ERROR_in_PDS_SO';
return;
end UpdateNewColumnAndFirmDate_SO_;


procedure GetPlanner_1( srInstanceId IN NUMBER,
                      inventoryItemId IN NUMBER,
                      orgId IN NUMBER,
                      planner OUT nocopy varchar2,
                      status OUT nocopy varchar2) is
v_plannerCode varchar2(100);
begin

--dbms_output.put_line('srInstanceId=' || srInstanceId);

select PLANNER_CODE into v_plannerCode
from MSC_SYSTEM_ITEMS
where INVENTORY_ITEM_ID = inventoryItemId
        and plan_id = -1
        and ORGANIZATION_ID = orgId;

select USER_NAME into planner
from MSC_PLANNERS
where PLANNER_CODE = v_plannerCode
        and ORGANIZATION_ID = orgId
        and SR_INSTANCE_ID = srInstanceId;

status:='SUCCESS';

EXCEPTION
        when NO_DATA_FOUND then
            planner := '0';
            status :='NO_PLANNER';
            return;
        when others then
            planner := '0';
            status :='ERROR_GETTING_PLANNER';
            return;
end GetPlanner_1;




procedure   AddLineId ( poIdString IN varchar2,
                        pnewArrivalDate IN varchar2,
                        ReleaseGid  IN  varchar2,
                        ReleaseLineGid IN varchar2,
                        tranzId out nocopy NUMBER,
                        status out nocopy varchar2) is
poId NUMBER :=0;
locationLineId NUMBER :=0;
indexI NUMBER :=0;
temp varchar2(100);
lg NUMBER :=0;
userId NUMBER :=0;
d1 DATE;
key NUMBER :=0;
srInstanceId NUMBER :=0;
nCount NUMBER :=0;
begin

    -- this procedure adds PO s of type order_type =1 only !
SAVEPOINT sv_addLineId;
    AppsInit;
    --userId := fnd_global.User_id();
    userId := g_UserId;

    indexI := INSTR(poIdString,'SCHED');
    poId := to_NUMBER( substr(poIdString, 6, indexI-7) );
    --dbms_output.put_line(poId);

    lg := LENGTH(poIdString);
    locationLineId := to_number( substr(poIdString, indexI + 6, lg - indexI -6 +1));
    --dbms_output.put_line(locationLineId);

    d1 := to_date(pnewArrivalDate, 'YYYY/MM/DD HH24:MI:SS');
    --dbms_output.put_line('d1 = ' || d1);
    srInstanceId := fnd_profile.value('MSC_EBS_INSTANCE_FOR_OTM');

    select count(1) into nCount
    from MSC_TRANSPORTATION_UPDATES
    where OTM_RELEASE_LINE_GID = ReleaseLineGid;

    if ( nCount =0 ) then

             select MSC_TRANSPORTATION_UPDATES_s.nextval into key from dual;

             insert into MSC_TRANSPORTATION_UPDATES (TRANS_UPDATE_ID, ORDER_TYPE, PO_LINE_LOCATION_ID, PO_LINE_ID, UPDATED_ARRIVAL_DATE, EBS_SR_INSTANCE_ID,
                                                    OTM_RELEASE_GID, OTM_RELEASE_LINE_GID,
                                                    LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY)
                                            VALUES (key, 1, locationLineId,poId, d1, srInstanceId,
                                                    ReleaseGid, ReleaseLineGid, SYSDATE, userId, SYSDATE, userId);

            status:= 'SUCCESS';
            tranzId := key;
    else
             update MSC_TRANSPORTATION_UPDATES
             set UPDATED_ARRIVAL_DATE = d1,
                 LAST_UPDATE_DATE = SYSDATE,
                 LAST_UPDATED_BY = userId
             where OTM_RELEASE_LINE_GID = ReleaseLineGid;

             select trans_update_id into tranzId
             from msc_transportation_updates
             where OTM_RELEASE_LINE_GID = ReleaseLineGid;

             status:= 'SUCCESS';
    end if;


 EXCEPTION when others then
 ROLLBACK to sv_addLineId;
 status := 'ERROR';

end AddLineId;

procedure   AddLineSO ( pnewArrivalDate IN varchar2,
                        ReleaseGid  IN  varchar2,
                        ReleaseLineGid IN varchar2,
                        isInternalSO IN varchar2,
                        tranzId out nocopy NUMBER,
                        status out nocopy varchar2) is
key NUMBER :=0;
d1 DATE;
userId NUMBER :=0;
isOrg varchar2(3);
nCount NUMBER :=0;
srInstanceId NUMBER :=0;
begin

    AppsInit;
    --userId := fnd_global.User_id();
    userId := g_UserId;

    -- if not internal sales order, then just exit
    isOrg := substr(isInternalSO, 1, 3);
    if ( isOrg <> 'ORG') then
        status := 'NOT_INTERNAL_SO';
        return;
    end if;

    d1 := to_date(pnewArrivalDate, 'YYYY/MM/DD HH24:MI:SS');


    select count(1) into nCount
    from MSC_TRANSPORTATION_UPDATES
    where OTM_RELEASE_LINE_GID = ReleaseLineGid;

     --dbms_output.put_line('count = '|| nCount);
     --dbms_output.put_line('ReleaseLineGid = '|| '<' || ReleaseLineGid || '>');

      srInstanceId := fnd_profile.value('MSC_EBS_INSTANCE_FOR_OTM');

    if ( nCount =0 ) then
                select MSC_TRANSPORTATION_UPDATES_s.nextval into key from dual;

                insert into MSC_TRANSPORTATION_UPDATES (TRANS_UPDATE_ID, ORDER_TYPE, UPDATED_ARRIVAL_DATE,EBS_SR_INSTANCE_ID,
                                                        OTM_RELEASE_GID,OTM_RELEASE_LINE_GID,WSH_DELIVERY_DETAIL_ID,
                                                        LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY)
                                                VALUES (key, 2,  d1, srInstanceId, ReleaseGid, ReleaseLineGid, ReleaseLineGid, SYSDATE, userId, SYSDATE, userId);

                status:= 'SUCCESS';
                tranzId := key;
    else
             update MSC_TRANSPORTATION_UPDATES
             set UPDATED_ARRIVAL_DATE = d1,
                 LAST_UPDATE_DATE = SYSDATE,
                 LAST_UPDATED_BY = userId
             where OTM_RELEASE_LINE_GID = ReleaseLineGid;

              select trans_update_id into tranzId
             from msc_transportation_updates
             where OTM_RELEASE_LINE_GID = ReleaseLineGid;

             status:= 'SUCCESS';

    end if;

EXCEPTION when others then
 status := 'ERROR';

end AddLineSO;

--========================= NOTIFICATION =====================================



procedure SendNotification_1 ( tranzId IN NUMBER,
                               status out nocopy varchar2) is
userId NUMBER :=0;
respId NUMBER :=0;
planner varchar2(40);
tokenValues MsgTokenValuePairList;
v_arrival_Date DATE;
v_po_line_id NUMBER :=0;
v_line_location_id NUMBER :=0;
v_tranzId NUMBER :=0;
v_srInstanceId NUMBER :=0;
v_orderNumber varchar2(100) :='';
v_Http varchar2(200);
otmReleaseGid varchar2(100);
v_order_type NUMBER :=0;
v_itemId NUMBER :=0;
v_orgId NUMBER :=0;

begin

if tranzId is null then
   status := 'NO_NOTIFICATION_TO_BE_SEND';
    return;
end if;

if  fnd_profile.value('MSC_GEN_NOTIFICATION_FOR_OTM') = 2  then
    status := 'NOTIFICATION_NOT_ALLOWED_BY PROFILE_OPTION';
    return;
end if;

    AppsInit;
    userId := fnd_global.USER_ID();
    respId := fnd_global.RESP_ID();

    if ( userId =0 or  respId =0) then
        status := 'ERROR_USER_RESP_PROFILES_NOT_SET';
    end if;

    tokenValues  := MsgTokenValuePairList();

    select order_type , EBS_SR_INSTANCE_ID, OTM_RELEASE_GID, updated_Arrival_Date
    into v_order_type, v_srInstanceId, otmReleaseGid, v_arrival_Date
    from msc_transportation_updates
    where trans_update_id = tranzId;

     v_Http := GetPunchoutURI( 0, otmReleaseGid);
--dbms_output.put_line(v_Http);

    -- order number needed, that is different for PO and SO.
    if (v_order_type  = 1) then
                SELECT po_line_location_id
                INTO v_line_location_id
                FROM MSC_TRANSPORTATION_UPDATES
                WHERE trans_update_id = tranzId;

                GetDataForNotification( v_line_location_id, v_srInstanceId, v_orderNumber, v_itemId, v_orgId);
                --dbms_output.put_line(v_itemId || ' ' ||  v_orderNumber );
    else
            SELECT s2.order_number, s2.INVENTORY_ITEM_ID, s2.ORGANIZATION_ID
            INTO v_orderNumber, v_itemId, v_orgId
            FROM MSC_SUPPLIES s2, MSC_SALES_ORDERS sO, MSC_DELIVERY_DETAILS dd, MSC_TRANSPORTATION_UPDATES tu
            WHERE s2.PLAN_ID =-1
                AND s2.SR_INSTANCE_ID = v_srInstanceId
                AND SO.SR_INSTANCE_ID = v_srInstanceId
                AND dd.SR_INSTANCE_ID = v_srInstanceId
                AND tu.EBS_SR_INSTANCE_ID = v_srInstanceId
                AND s2.TRANSACTION_ID = SO.SUPPLY_ID
                AND sO.DEMAND_SOURCE_LINE = dd.SOURCE_LINE_ID
                AND dd.DELIVERY_DETAIL_ID = tu.OTM_RELEASE_LINE_GID
                AND tu.Trans_update_id = tranzId
                AND s2.order_type = 2;

          --dbms_output.put_line(v_itemId || ' ' ||  v_orderNumber );
    end if;

    GetPlanner_1( v_srInstanceId, v_itemId, v_orgId, planner, status);

    if ( planner <> '0') then
            tokenValues.extend;
            tokenValues(1) := MsgTokenValuePair('PO_ORDERNUMBER', v_orderNumber);
            tokenValues.extend;
            tokenValues(2) :=  MsgTokenValuePair('PO_ARRIVALDATE', v_arrival_Date);
            tokenValues.extend;
            tokenValues(3) :=  MsgTokenValuePair('PO_URI', v_Http);

            status := MSC_WS_NOTIFICATION_BPEL.SendFYINotification ( userId, respID, planner, 'EN', 'W_OTM_UP', 'W_OTM_PROC', tokenValues);

    end if;


EXCEPTION when no_data_found then
status := 'NO_DATA_FOUND_FOR_NOTIFICATION';
when others then
status := 'ERROR_IN_NOTIFICATION ' || fnd_message.get();
end SendNotification_1;


procedure GetDataForNotification(lineLocationId IN NUMBER,
                                 srInstanceId IN NUMBER,
                                 orderNumber OUT nocopy VARCHAR2,
                                 inventoryItemId out nocopy NUMBER,
                                 orgId out nocopy NUMBER) is
cursor GetOrderNumber is
select distinct order_number, inventory_item_id, ORGANIZATION_ID
from msc_supplies
WHERE PLAN_ID= -1
  AND SR_INSTANCE_ID=srInstanceId
  AND ORDER_TYPE= 1
  AND PO_line_LOCATION_ID = lineLocationId;

begin

open GetOrderNumber;
    loop
    FETCH GetOrderNumber into orderNumber, inventoryItemId, orgId;
    EXIT WHEN GetOrderNumber%NOTFOUND;
    end loop;
close GetOrderNumber;

return;

end GetDataForNotification;


procedure AppsInit is
userId NUMBER :=0;
respId NUMBER :=0;
appId NUMBER :=0;
begin
    userId := fnd_profile.value('MSC_WS_OTM_USERID');
    respId := fnd_profile.value('MSC_WS_OTM_RESPID');
    if ( respId = 0) then
        respId := fnd_profile.value('MSC: OTM RESPONSIBILITY');
    end if;
    SELECT application_id INTO appId FROM fnd_responsibility WHERE responsibility_id = respId;
    fnd_global.apps_initialize(userId, respId, appId);

    g_UserId := userId;

    --dbms_output.put_line(userId || ' ' || respId || ' ' || appId);
end AppsInit;

function GetProfilePlanId return NUMBER is
planId NUMBER :=0;
begin
 planId := fnd_profile.value('MSC_PROD_PLAN_ID_FOR_OTM_UPDATES');
return planId;

EXCEPTION when others then
return 0;

end GetProfilePlanId;

function GetPunchoutURI(srInstanceId IN NUMBER,
                        otmReleaseGid IN varchar2) return varchar2 is
v_Http varchar2(200);

lg NUMBER:=0;
strTemp varchar2(200);
t1 varchar2(10);
t2 varchar2(100);

begin
-- srInstanceId is not used right now. Will be used when multi-Instance allowed.

 -- http://otm-it1-55-oas.us.oracle.com/GC3/OrderReleaseCustManagement?management_action=view=ORDER_RELEASE_VIEW=GUEST.20011214-0001-001
    --server from OTM: Servlet URI
    --pk = DOMAIN.OTM_RELEASE_GID
    -- where DOMAIN taken from OTM: Domain Name

    strTemp := fnd_profile.value('MSC_OTM_PUNCHOUT_URI');
    lg := LENGTH(strTemp);

    t1 := substr(strTemp, lg , lg) ;

    if ( t1 = '/') then
            t2 := substr(strTemp, 1 , lg-1) ;
     else
            t2 := strTemp;
    end if;

    v_Http := t2
              ||'/GC3/OrderReleaseCustManagement' || '?management_action=view'||'&'||'manager_layout_gid=ORDER_RELEASE_VIEW'||'&'||'pk='
              || fnd_profile.value('WSH_OTM_DOMAIN_NAME')
              || '.'
              || otmReleaseGid;

    return v_Http;

EXCEPTION when others then
return '';

end GetPunchoutURI;


procedure PurgeTransportationUpdates is
cursor c_getLine is
SELECT
   TRANS_UPDATE_ID, updated_Due_Date
FROM
    MSC_TRANSPORTATION_UPDATES;

v_trans_id NUMBER :=0;
v_due_Date DATE;
v_adj_date DATE;

begin
            AppsInit;

            OPEN c_getLine;
            LOOP
                FETCH c_getLine into  v_trans_id, v_due_Date;
                EXIT WHEN c_getLine%NOTFOUND;
                v_adj_date := v_due_Date + 90;
                --dbms_output.put_line(v_adj_date);
                if ( v_adj_Date  < SYSDATE ) then
                    delete from msc_transportation_updates where trans_update_id = v_trans_id;
                end if;

            END LOOP;
            CLOSE c_getLine;

end PurgeTransportationUpdates;


END MSC_WS_OTM_BPEL;

/
