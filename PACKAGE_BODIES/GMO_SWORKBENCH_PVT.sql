--------------------------------------------------------
--  DDL for Package Body GMO_SWORKBENCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_SWORKBENCH_PVT" AS
/* $Header: GMOVSWBB.pls 120.2 2007/08/06 06:09:45 rvsingh noship $ */
G_PKG_NAME CONSTANT VARCHAR2(40) := 'GMO_SWORKBENCH_PVT';
PROCEDURE UPDATE_PLANNING_STATUS
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,
    P_RESERVATION_ID        IN NUMBER,
    P_DISPENSE_ID           IN NUMBER,
    P_DISPENSED_DATE        IN DATE,
    P_DISPENSE_TYPE         IN VARCHAR2,
    P_DISPENSE_AREA_ID      IN NUMBER,
    P_DISP_ORG_ID           IN NUMBER
) is
 gmo_dispensing_planning_rec GMO_DISPENSING_PLANNING%ROWTYPE;
 task_id GMO_DISPENSING_PLANNING.PLANNED_TASK_ID%TYPE;
 l_count number;
 L_CREATION_DATE DATE;
 L_CREATED_BY NUMBER;
 L_LAST_UPDATE_DATE DATE;
 L_LAST_UPDATED_BY NUMBER;
 L_LAST_UPDATE_LOGIN NUMBER;
 L_DISP_AREA_ID NUMBER;
begin
select count(*) into l_count from gmo_dispensing_planning
where reservation_id = P_RESERVATION_ID
and status = 'PLANNED';
if (l_count > 0) then  -- for planned dispense and partial dispenses
   if ( P_DISPENSE_TYPE = 'DISPENSE' ) then
  	update gmo_dispensing_planning
    set
    status = 'DISPENSD',
    dispense_id = P_DISPENSE_ID,
    dispensed_date = P_DISPENSED_DATE
   	where reservation_id = P_RESERVATION_ID
   	and status ='PLANNED';
   -- for partial dispense
   elsif ( P_DISPENSE_TYPE = 'PDISPENSE' ) then

   	--copy the record
    select * into gmo_dispensing_planning_rec from gmo_dispensing_planning
   	where reservation_id = P_RESERVATION_ID
   	and status ='PLANNED';

   	--change the status to dispensed
   	update gmo_dispensing_planning
    set
    status = 'DISPENSD',
    dispense_id = P_DISPENSE_ID,
    dispensed_date = P_DISPENSED_DATE
   	where reservation_id = P_RESERVATION_ID
   	and status ='PLANNED';

   	GMO_UTILITIES.GET_WHO_COLUMNS
   	(
	X_CREATION_DATE => L_CREATION_DATE,
	X_CREATED_BY => L_CREATED_BY,
	X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
	X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
	X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );
  	insert into gmo_dispensing_planning (
	PLANNED_TASK_ID,
	RESERVATION_ID,
	DISPENSE_AREA_ID ,
	PRIORITY ,
	PLANNED_DISPENSING_DATE,
	OPER_ID,
	STATUS ,
	DISPENSE_ID ,
    DISPENSED_DATE,
	CREATED_BY  ,
	CREATION_DATE   ,
	LAST_UPDATED_BY ,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
   	)
   	values
 	(
         GMO_DISPENSING_PLANNING_S.nextval, --- get the next value from sequence
         P_RESERVATION_ID,
         gmo_dispensing_planning_rec.DISPENSE_AREA_ID,
 	     gmo_dispensing_planning_rec.PRIORITY,
         gmo_dispensing_planning_rec.PLANNED_DISPENSING_DATE,
         gmo_dispensing_planning_rec.OPER_ID,
         --'PDISPENSE', ---signifying partial dispense----
         gmo_dispensing_planning_rec.status,
         null,
         gmo_dispensing_planning_rec.DISPENSED_DATE,
         --L_CREATED_BY,
         gmo_dispensing_planning_rec.created_by,
         L_CREATION_DATE,
  	     --L_LAST_UPDATED_BY,
  	     gmo_dispensing_planning_rec.last_updated_by,
         L_LAST_UPDATE_DATE,
	     --L_LAST_UPDATE_LOGIN
	     gmo_dispensing_planning_rec.last_update_login
  	);
  end if; --- dispense_type
else  --- l_count = 0  for unplanned dispenses
	GMO_UTILITIES.GET_WHO_COLUMNS
   	 (
	X_CREATION_DATE => L_CREATION_DATE,
	X_CREATED_BY => L_CREATED_BY,
	X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
	X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
	X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    	);

   select count(*) into l_count from gmo_dispensing_planning
    where reservation_id = P_RESERVATION_ID
    and status = 'UNPLANNED';

    if( l_count = 0) then
      	insert into gmo_dispensing_planning (
    	PLANNED_TASK_ID,
    	RESERVATION_ID,
    	DISPENSE_AREA_ID,
    	PRIORITY,
    	PLANNED_DISPENSING_DATE,
    	OPER_ID,
    	STATUS,
    	DISPENSE_ID,
                      dispensed_date,
    	CREATED_BY,
    	CREATION_DATE,
    	LAST_UPDATED_BY,
    	LAST_UPDATE_DATE,
    	LAST_UPDATE_LOGIN
   	    )
       	values
 	      (
         GMO_DISPENSING_PLANNING_S.nextval, --- get the next value from sequence
         P_RESERVATION_ID,
         P_DISPENSE_AREA_ID,
         'MEDIUM',
         null,
         null,
         --'UNPDISPENSE', ---signifying unplanned dispense----
         'DISPENSD',
         P_DISPENSE_ID,
         P_DISPENSED_DATE,
         L_CREATED_BY,
         L_CREATION_DATE,
  	      L_LAST_UPDATED_BY,
     	 L_LAST_UPDATE_DATE,
    	 L_LAST_UPDATE_LOGIN
  	  );
    else
             update gmo_dispensing_planning
            set
            status = 'DISPENSD',
            dispense_id = P_DISPENSE_ID,
            dispense_area_id = P_DISPENSE_AREA_ID,
            dispensed_date = P_DISPENSED_DATE
           	where reservation_id = P_RESERVATION_ID
           	and status ='UNPLANNED';
   end if;

       select DISPENSE_AREA_ID into L_DISP_AREA_ID
        from gmo_dispense_area_b ar
        where ar.organization_id = P_DISP_ORG_ID and ar.default_area_ind = 'Y';

       	insert into gmo_dispensing_planning (
	       PLANNED_TASK_ID,
        	RESERVATION_ID,
        	DISPENSE_AREA_ID,
        	PRIORITY,
        	PLANNED_DISPENSING_DATE,
        	OPER_ID,
        	STATUS,
        	DISPENSE_ID,
                         dispensed_date,
        	CREATED_BY,
        	CREATION_DATE,
        	LAST_UPDATED_BY,
        	LAST_UPDATE_DATE,
        	LAST_UPDATE_LOGIN
       	)
   	    values
     	(
        	GMO_DISPENSING_PLANNING_S.nextval,
     	    P_RESERVATION_ID,
             L_DISP_AREA_ID,
             'MEDIUM',
             null,
             null,
             --'UNPDISPENSE', ---signifying unplanned dispense----
             'UNPLANNED',
             null,
             null,
             L_CREATED_BY,
             L_CREATION_DATE,
      	     L_LAST_UPDATED_BY,
         	 L_LAST_UPDATE_DATE,
    	     L_LAST_UPDATE_LOGIN
     	);

end if; --- l_count
      x_return_status := GMO_CONSTANTS_GRP.RETURN_STATUS_SUCCESS;
EXCEPTION
	WHEN OTHERS THEN
		X_RETURN_STATUS := GMO_CONSTANTS_GRP.RETURN_STATUS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_UNEXPECTED_DB_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
		FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
		X_MSG_DATA := fnd_message.get;
end; ---procedure;



FUNCTION GET_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,date_value Date) RETURN Number
IS
plannedPer number default 0;
dispensedPer number default 0;
totalPer number default 0;

begin

select count(*) into plannedPer from gmo_dispensing_planning
where dispense_area_id = area_id
and to_char(planned_dispensing_date,'dd-mon-rr') = to_char(date_value,'dd-mon-rr')
and status = 'PLANNED'
and dispense_id is null;

select count(*) into dispensedPer from gmo_dispensing_planning
where dispense_area_id = area_id
and to_char(dispensed_date,'dd-mon-rr') = to_char(date_value,'dd-mon-rr')
and dispense_id is not null;



totalPer := plannedPer + dispensedPer;

if(max_no_of_tasks = -1) then
return totalPer;
else
totalPer := (totalPer *100)/max_no_of_tasks;
return round(totalPer,2);
end if;
end;




FUNCTION GET_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,date_value Date,oper NUMBER) RETURN Number
IS
plannedPer number default 0;
dispensedPer number default 0;
totalPer number default 0;
begin

select count(*) into plannedPer from gmo_dispensing_planning
where dispense_area_id = area_id
and to_char(planned_dispensing_date,'dd-mon-rr') = to_char(date_value,'dd-mon-rr')
and OPER_ID = oper
and status = 'PLANNED'
and dispense_id is null;

select count(*) into dispensedPer from gmo_dispensing_planning
where dispense_area_id = area_id
and to_char(dispensed_date,'dd-mon-rr') = to_char(date_value,'dd-mon-rr')
and OPER_ID = oper
and dispense_id is not null;




totalPer := plannedPer + dispensedPer;
if(max_no_of_tasks = -1) then
return totalPer;
else
totalPer := (totalPer *100)/max_no_of_tasks;
return round(totalPer,2);
end if;
end;


FUNCTION GET_WEEKLY_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,week_start_date Date,week_end_date Date) RETURN Number
IS

plannedPer number default 0;
dispensedPer number default 0;
totalPer number default 0;

noofdays number;
begin
select count(*) into plannedPer from gmo_dispensing_planning
where dispense_area_id = area_id
and planned_dispensing_date between week_start_date and week_end_date
and status = 'PLANNED'
and dispense_id is null;

select count(*) into dispensedPer from gmo_dispensing_planning
where dispense_area_id = area_id
and dispensed_date between week_start_date and week_end_date
and dispense_id is not null;

noofdays := (week_end_date - week_start_date);
noofdays := noofdays + 1;



totalPer := plannedPer + dispensedPer;
if(max_no_of_tasks = -1) then
return totalPer;
else

totalPer := (totalPer *100)/(noofdays * max_no_of_tasks);
return round(totalPer,2);
end if;
end;

FUNCTION GET_WEEKLY_TASK_PERCENTAGE(area_id number,max_no_of_tasks number,week_start_date Date,week_end_date Date,oper NUMBER) RETURN Number
IS
plannedPer number default 0;
dispensedPer number default 0;
totalPer number default 0;
noofdays number;
begin

select count(*) into plannedPer from gmo_dispensing_planning
where dispense_area_id = area_id
and OPER_ID = oper
and planned_dispensing_date between week_start_date and week_end_date
and status = 'PLANNED'
and dispense_id is null;

select count(*) into dispensedPer from gmo_dispensing_planning
where dispense_area_id = area_id
and OPER_ID = oper
and dispensed_date between week_start_date and week_end_date
and dispense_id is not null;


noofdays := (week_end_date - week_start_date);
noofdays := noofdays + 1;



totalPer := plannedPer + dispensedPer;
if(max_no_of_tasks = -1) then
return totalPer;
else
totalPer := (totalPer *100)/(noofdays * max_no_of_tasks);
return round(totalPer,2);
end if;
end;





function get_days(timevalue varchar2)return number
as
position number;
days varchar2(10);
begin
position := instr(timevalue,':',1,1);

if (position > 1) then

days := substr(timevalue,1,position-1);



elsif (position = 1 ) then
days := '0';
else days := timevalue;
end if;

return to_number(days);

end;

function get_hours(timevalue varchar2)return number
as
position1 number;
position2 number;
hours varchar2(2);
begin
position1 := instr(timevalue,':',1,1);
position2 := instr(timevalue,':',1,2);



if (position1 > 1) then

 if(position2 = 0) then
 hours := substr(timevalue,position1+1);
 elsif (position2 - position1 > 1) then
 hours := substr(timevalue,position1+1,position2-position1-1);
 else hours := '0';
 end if;
else
hours := '0';
end if;

return to_number(hours);

end;


function get_minutes(timevalue varchar2)return number
as
position number;
mins varchar2(2);
begin

position := instr(timevalue,':',1,2);


if (position = 0 ) then
mins := '0';
else
mins := substr(timevalue,position+1);
end if;

return to_number(mins);

end;





procedure create_material_reservation(
 p_org_id                  IN              NUMBER
,p_material_detail_id      IN              NUMBER
,p_resv_qty                IN              NUMBER DEFAULT NULL
,p_sec_resv_qty            IN              NUMBER DEFAULT NULL
,p_resv_um                 IN              VARCHAR2 DEFAULT NULL
,p_subinventory            IN              VARCHAR2 DEFAULT NULL
,p_locator_id              IN              NUMBER DEFAULT NULL
,p_lot_number              IN              VARCHAR2 DEFAULT NULL
,x_res_id                  OUT NOCOPY NUMBER
,x_msg_data                OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
,x_return_status           OUT    NOCOPY      VARCHAR2
)
IS
l_matl_dtl_rec              gme_material_details%ROWTYPE;
error_get_item             EXCEPTION;
CURSOR cur_get_mtl_dtl_rec (v_org_id NUMBER, v_material_detail_id NUMBER)
IS
   SELECT *
     FROM gme_material_details
    WHERE material_detail_id = v_material_detail_id
      AND organization_id = v_org_id;
BEGIN
OPEN cur_get_mtl_dtl_rec (p_org_id, p_material_detail_id);
FETCH cur_get_mtl_dtl_rec INTO l_matl_dtl_rec;
CLOSE cur_get_mtl_dtl_rec;
IF l_matl_dtl_rec.material_detail_id IS NULL THEN  -- not found
 RAISE error_get_item;
END IF;
/*ns_debug_call('p_org_id'|| p_org_id||
              'p_material_detail_id'||p_material_detail_id||
              'p_resv_qty'||p_resv_qty||
              'p_sec_resv_qty'||p_sec_resv_qty||
              'p_resv_um'||p_resv_um||
              'p_subinventory'||p_subinventory||
              'p_locator_id'||p_locator_id||
              'p_lot_number'||p_lot_number
              );
 */
create_material_reservation
                                (p_matl_dtl_rec            => l_matl_dtl_rec
                                ,p_resv_qty                => p_resv_qty
                                ,p_sec_resv_qty            => p_sec_resv_qty
                                ,p_resv_um                 => p_resv_um
                                ,p_subinventory            => p_subinventory
                                ,p_locator_id              => p_locator_id
                                ,p_lot_number              => p_lot_number
                                ,x_return_status           => x_return_status
                                ,x_msg_count                     => x_msg_count
                                ,x_msg_data                      => x_msg_data
                                );
--ns_debug_call('in create1'|| x_msg_data       );
select reservation_id into x_res_id from mtl_reservations RES,gme_material_details GMD where GMD.organization_id =p_org_id and
GMD.material_detail_id =p_material_detail_id and  RES.DEMAND_SOURCE_HEADER_ID (+) = GMD.BATCH_ID
AND RES.DEMAND_SOURCE_LINE_ID(+) = GMD.MATERIAL_DETAIL_ID;
EXCEPTION
      WHEN error_get_item THEN
         x_return_status := fnd_api.g_ret_sts_error;
        WHEN OTHERS THEN
            --ns_debug_call('create  Mtl Reservation :  ERROR_TEXT :'||SQLERRM);
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
 END create_material_reservation;
    PROCEDURE create_material_reservation (
      p_matl_dtl_rec    IN              gme_material_details%ROWTYPE
     ,p_resv_qty        IN              NUMBER DEFAULT NULL
     ,p_sec_resv_qty    IN              NUMBER DEFAULT NULL
     ,p_resv_um         IN              VARCHAR2 DEFAULT NULL
     ,p_subinventory    IN              VARCHAR2 DEFAULT NULL
     ,p_locator_id      IN              NUMBER DEFAULT NULL
     ,p_lot_number      IN              VARCHAR2 DEFAULT NULL
     ,x_msg_data       OUT NOCOPY VARCHAR2
     , x_msg_count                 OUT NOCOPY NUMBER
      ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)    := 'create_material_reservation';
      l_return_status       VARCHAR2 (1);
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_qty_reserved        NUMBER;
      l_reservation_id      NUMBER;
      l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
      l_in_serial_num       inv_reservation_global.serial_number_tbl_type;
      l_out_serial_num      inv_reservation_global.serial_number_tbl_type;
      --Bug#4604943
      invalid_mtl_for_rsrv  EXCEPTION;
      create_resvn_err      EXCEPTION;
      l_get_revision              mtl_onhand_quantities%ROWTYPE;
 CURSOR cur_get_revision (v_org_id NUMBER, v_inventory_item_id NUMBER,v_subinv varchar2,v_lot varchar2,v_locator number)
   IS
   SELECT *
     FROM mtl_onhand_quantities
    WHERE inventory_item_id = v_inventory_item_id
      AND organization_id = v_org_id
      AND subinventory_code = v_subinv
      AND ((v_lot IS NULL AND lot_number is null) or (lot_number = v_lot))
      AND ((v_locator IS NULL AND locator_id is null) or (locator_id = v_locator));
   BEGIN
  /*    IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
         gme_debug.put_line ('input value p_resv_qty     => ' || p_resv_qty);
         gme_debug.put_line ('input value p_sec_resv_qty => ' || p_sec_resv_qty);
         gme_debug.put_line ('input value plan_qty       => ' || p_matl_dtl_rec.plan_qty);
         gme_debug.put_line ('input value resv_um        => ' || p_resv_um );
         gme_debug.put_line ('input value release_type   => ' || p_matl_dtl_rec.release_type );
      END IF;*/
      x_return_status := fnd_api.g_ret_sts_success;
      --Bug#4604943 Begin validate the batch and material line
      validate_mtl_for_reservation(
                 p_material_detail_rec => p_matl_dtl_rec
                ,x_return_status       => l_return_status
                ,x_msg_count                     => x_msg_count
                ,x_msg_data                      => x_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE invalid_mtl_for_rsrv;
      END IF;
      --Bug#4604943 End
      l_rsv_rec.requirement_date := p_matl_dtl_rec.material_requirement_date;
      l_rsv_rec.organization_id := p_matl_dtl_rec.organization_id;
      l_rsv_rec.inventory_item_id := p_matl_dtl_rec.inventory_item_id;
      l_rsv_rec.demand_source_type_id := gme_common_pvt.g_txn_source_type;
      l_rsv_rec.demand_source_header_id := p_matl_dtl_rec.batch_id;
      l_rsv_rec.demand_source_line_id := p_matl_dtl_rec.material_detail_id;
      l_rsv_rec.reservation_uom_code := NVL (p_resv_um, p_matl_dtl_rec.dtl_um);
      l_rsv_rec.reservation_quantity :=
                                     NVL (p_resv_qty, p_matl_dtl_rec.plan_qty);
      l_rsv_rec.secondary_reservation_quantity := p_sec_resv_qty;
      if(p_matl_dtl_rec.revision is not null)then
        l_rsv_rec.revision := p_matl_dtl_rec.revision;
      else
        OPEN cur_get_revision (p_matl_dtl_rec.organization_id , p_matl_dtl_rec.inventory_item_id
                                               ,p_subinventory,p_lot_number,p_locator_id);
        FETCH cur_get_revision INTO l_get_revision;
        CLOSE cur_get_revision;
        l_rsv_rec.revision :=l_get_revision.revision;
      end if;
      l_rsv_rec.subinventory_code := p_subinventory;
      l_rsv_rec.locator_id := p_locator_id;
      l_rsv_rec.lot_number := p_lot_number;
      l_rsv_rec.lpn_id := NULL;
      l_rsv_rec.demand_source_name := NULL;
      l_rsv_rec.demand_source_delivery := NULL;
      l_rsv_rec.primary_uom_code := NULL;
      l_rsv_rec.primary_uom_id := NULL;
      l_rsv_rec.secondary_uom_code := NULL;
      l_rsv_rec.secondary_uom_id := NULL;
      l_rsv_rec.reservation_uom_id := NULL;
      l_rsv_rec.ship_ready_flag := NULL;
      l_rsv_rec.attribute_category := NULL;
      l_rsv_rec.attribute1 := NULL;
      l_rsv_rec.attribute2 := NULL;
      l_rsv_rec.attribute3 := NULL;
      l_rsv_rec.attribute4 := NULL;
      l_rsv_rec.attribute5 := NULL;
      l_rsv_rec.attribute6 := NULL;
      l_rsv_rec.attribute7 := NULL;
      l_rsv_rec.attribute8 := NULL;
      l_rsv_rec.attribute9 := NULL;
      l_rsv_rec.attribute10 := NULL;
      l_rsv_rec.attribute11 := NULL;
      l_rsv_rec.attribute12 := NULL;
      l_rsv_rec.attribute13 := NULL;
      l_rsv_rec.attribute14 := NULL;
      l_rsv_rec.attribute15 := NULL;
      l_rsv_rec.subinventory_id := NULL;
      l_rsv_rec.lot_number_id := NULL;
      l_rsv_rec.pick_slip_number := NULL;
      l_rsv_rec.primary_reservation_quantity := NULL;
      l_rsv_rec.detailed_quantity := NULL;
      l_rsv_rec.secondary_detailed_quantity := NULL;
      l_rsv_rec.autodetail_group_id := NULL;
      l_rsv_rec.external_source_code := NULL;
      l_rsv_rec.external_source_line_id := NULL;
      l_rsv_rec.supply_source_type_id :=
                                      inv_reservation_global.g_source_type_inv;
      l_rsv_rec.supply_source_header_id := NULL;
      l_rsv_rec.supply_source_line_id := NULL;
      l_rsv_rec.supply_source_name := NULL;
      l_rsv_rec.supply_source_line_detail := NULL;
     /* IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Calling inv_reservation_pub.create_reservation');
      END IF;*/
-- nsinghi Bug5176319. Commented p_force_reservation_flag parameter. As per inv team, onhand could be -ve
-- before reservation, and hence this parameter should not be used.
      inv_reservation_pub.create_reservation
                                (p_api_version_number            => 1.0
                                ,p_init_msg_lst                  => fnd_api.g_false
                                ,x_return_status                 => l_return_status
                                ,x_msg_count                     => x_msg_count
                                ,x_msg_data                      => x_msg_data
                                ,p_rsv_rec                       => l_rsv_rec
                                ,p_serial_number                 => l_in_serial_num
                                ,x_serial_number                 => l_out_serial_num
                                ,p_partial_reservation_flag      => fnd_api.g_true
--                                ,p_force_reservation_flag        => fnd_api.g_true
                                ,p_validation_flag               => fnd_api.g_true
                                ,x_quantity_reserved             => l_qty_reserved
                                ,x_reservation_id                => l_reservation_id
                                ,p_partial_rsv_exists            => TRUE);
--ns_debug_call('in create2'|| x_msg_data       );
    /*  IF (g_debug <= gme_debug.g_log_unexpected) THEN
        gme_debug.put_line (   g_pkg_name
                           || '.'
                           || l_api_name
                           || ' inv_reservation_pub.create_reservation returns status of '
                           || l_return_status
                           || ' for material_detail_id '
                           || p_matl_dtl_rec.material_detail_id
                           || ' qty reserved IS  '
                           || l_qty_reserved );
      END IF;*/
      IF (l_return_status IN
                     (fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error) ) THEN
         RAISE create_resvn_err;
      END IF;
   /*   IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;*/
   EXCEPTION
      WHEN create_resvn_err THEN
         /*IF (g_debug <= gme_debug.g_log_error) THEN
            gme_debug.put_line
                        (   'inv_reservation_pub.create_reservation returns '
                         || l_return_status);
            gme_debug.put_line ('error message is ' || l_msg_data);
         END IF;*/
         x_return_status := l_return_status;
      --Bug#4604943 just pass the actual return status from validate procedure
      WHEN invalid_mtl_for_rsrv THEN
         x_return_status := l_return_status;
      WHEN OTHERS THEN
      /*   IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;*/
        --fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END create_material_reservation;
      PROCEDURE validate_mtl_for_reservation(
      p_material_detail_rec    IN              GME_MATERIAL_DETAILS%ROWTYPE
      ,x_msg_data              OUT NOCOPY VARCHAR2
      , x_msg_count            OUT NOCOPY NUMBER
      , x_return_status          OUT NOCOPY      VARCHAR2) IS
     l_api_name         VARCHAR2(30) := 'VALIDATE_MTL_FOR_RESERVATION';
     l_batch_header_rec gme_batch_header%ROWTYPE;
     l_step_id          NUMBER;
     l_step_status      NUMBER;
     fetch_failure      EXCEPTION;
     demand_line_error  EXCEPTION;
     batch_status_error EXCEPTION;
   BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
     l_batch_header_rec.batch_id := p_material_detail_rec.batch_id;
     IF NOT (gme_batch_header_dbl.fetch_row (l_batch_header_rec, l_batch_header_rec)) THEN
      RAISE fetch_failure;
     END IF;
    IF l_batch_header_rec.batch_status = gme_common_pvt.g_batch_pending THEN
       --pending batch just return
      /* IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Batch is Pending status');
       END IF;*/
       RETURN;
    ELSIF l_batch_header_rec.batch_status = gme_common_pvt.g_batch_wip THEN
      /* In WIP Bathes, do not create reservations for automatic and automatic by step if assoc step is not released*/
      IF p_material_detail_rec.release_type IN (gme_common_pvt.g_mtl_manual_release,gme_common_pvt.g_mtl_incremental_release) THEN
     /*    IF g_debug <= gme_debug.g_log_statement THEN
           gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Batch is in WIP and material line is manual/incremental');
         END IF;*/
         RETURN;
      ELSIF p_material_detail_rec.release_type = gme_common_pvt.g_mtl_autobystep_release THEN
        /* if automatic by step then check step status */
/*	IF g_debug <= gme_debug.g_log_statement THEN
           gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Batch is in WIP and material line is Autoby step');
         END IF;*/
	IF NOT gme_common_pvt.get_assoc_step(p_material_detail_rec.material_detail_id,l_step_id,l_step_status) THEN
         RAISE demand_line_error;
        ELSIF l_step_id IS NOT NULL AND NVL(l_step_status,-1) <> gme_common_pvt.g_step_pending THEN
         RAISE demand_line_error;
        END IF;
      ELSE
       /* IF g_debug <= gme_debug.g_log_statement THEN
          gme_debug.put_line(g_pkg_name||'.'||l_api_name||' Batch is in WIP and material line is automatic');
        END IF;*/
        RAISE demand_line_error;
      END IF; /*end of validations for WIP Batch*/
    ELSE
      RAISE batch_status_error;
    END IF; /* outer most if */
    --ns_debug_call('in validate'|| x_msg_data       );
   EXCEPTION
    WHEN fetch_failure THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN demand_line_error THEN
      gme_common_pvt.log_message('GME_INVALID_DEMAND_LINE');
      x_msg_data:='GME_INVALID_DEMAND_LINE';
       x_return_status := fnd_api.g_ret_sts_error;
    WHEN batch_status_error THEN
      gme_common_pvt.log_message('GME_INVALID_BATCH_STATUS','PROCESS','RESERVATIONS');
      x_msg_data:='GME_INVALID_BATCH_STATUS';
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
    /*  IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;*/
         --fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END validate_mtl_for_reservation;
      PROCEDURE update_reservation (
      p_reservation_id   IN              NUMBER
     ,p_revision         IN              VARCHAR2 DEFAULT NULL
     ,p_subinventory     IN              VARCHAR2 DEFAULT NULL
     ,p_locator_id       IN              NUMBER DEFAULT NULL
     ,p_lot_number       IN              VARCHAR2 DEFAULT NULL
     ,p_new_qty          IN              NUMBER DEFAULT NULL
     ,p_new_sec_qty      IN              NUMBER DEFAULT NULL
     ,p_new_uom          IN              VARCHAR2 DEFAULT NULL
     ,p_new_date         IN              DATE DEFAULT NULL
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)             := 'update_reservation';
      l_return_status       VARCHAR2 (1);
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
      l_orig_rsv_rec        inv_reservation_global.mtl_reservation_rec_type;
      l_serial_number       inv_reservation_global.serial_number_tbl_type;
      update_resvn_error    EXCEPTION;
      query_resvn_error     EXCEPTION;
      l_get_revision              mtl_onhand_quantities%ROWTYPE;
 CURSOR cur_get_revision (v_org_id NUMBER, v_inventory_item_id NUMBER,v_subinv varchar2,v_lot varchar2,v_locator number)
   IS
   SELECT *
     FROM mtl_onhand_quantities
    WHERE inventory_item_id = v_inventory_item_id
      AND organization_id = v_org_id
      AND subinventory_code = v_subinv
      AND ((v_lot IS NULL AND lot_number is null) or (lot_number = v_lot))
      AND ((v_locator IS NULL AND locator_id is null) or (locator_id = v_locator));
   BEGIN
     /* IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;*/
      x_return_status := fnd_api.g_ret_sts_success;
      query_reservation (p_reservation_id       => p_reservation_id
                        ,x_reservation_rec      => l_orig_rsv_rec
                        ,x_return_status        => l_return_status);
      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE query_resvn_error;
      END IF;
      l_rsv_rec.reservation_id := p_reservation_id;
      if(p_revision is not null)then
        l_rsv_rec.revision := p_revision;
      else
        OPEN cur_get_revision (l_orig_rsv_rec.organization_id , l_orig_rsv_rec.inventory_item_id
                                               ,p_subinventory,p_lot_number,p_locator_id);
        FETCH cur_get_revision INTO l_get_revision;
        CLOSE cur_get_revision;
        l_rsv_rec.revision :=l_get_revision.revision;
      end if;
      l_rsv_rec.subinventory_code := p_subinventory;
      l_rsv_rec.locator_id := p_locator_id;
      l_rsv_rec.lot_number := p_lot_number;
      l_rsv_rec.reservation_quantity := p_new_qty;
      l_rsv_rec.secondary_reservation_quantity := p_new_sec_qty;
      l_rsv_rec.reservation_uom_code := p_new_uom;
      l_rsv_rec.requirement_date := p_new_date;
     /* IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ':Calling inv_reservation_pub.update_reservation with reservation_id = '
             || p_reservation_id);
      END IF;*/
      inv_reservation_pub.update_reservation
                                 (p_api_version_number          => 1.0
                                 ,p_init_msg_lst                => fnd_api.g_false
                                 ,x_return_status               => l_return_status
                                 ,x_msg_count                   => l_msg_count
                                 ,x_msg_data                    => l_msg_data
                                 ,p_original_rsv_rec            => l_orig_rsv_rec
                                 ,p_to_rsv_rec                  => l_rsv_rec
                                 ,p_original_serial_number      => l_serial_number
                                 ,p_to_serial_number            => l_serial_number
                                 ,p_validation_flag             => fnd_api.g_true
                                 ,p_check_availability          => fnd_api.g_true);
      /*IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || 'Return status from inv_reservation_pub.update_reservation is '
             || l_return_status);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || 'Error is :'
                             || l_msg_data);
      END IF;*/
      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE update_resvn_error;
      END IF;
    /*  IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;*/
   EXCEPTION
      WHEN query_resvn_error THEN
         x_return_status := l_return_status;
      WHEN update_resvn_error THEN
         x_return_status := l_return_status;
      WHEN OTHERS THEN
        /* IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;*/
         --fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END update_reservation;

      PROCEDURE query_reservation (
      p_reservation_id    IN              NUMBER
     ,x_reservation_rec   OUT NOCOPY      inv_reservation_global.mtl_reservation_rec_type
     ,x_return_status     OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)              := 'query_reservation';
      l_return_status       VARCHAR2 (1);
      l_error_code          NUMBER;
      l_rsv_count           NUMBER;
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_tbl             inv_reservation_global.mtl_reservation_tbl_type;
      l_serial_number       inv_reservation_global.serial_number_tbl_type;
      update_resvn_error    EXCEPTION;
   BEGIN
      /*IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;*/
      x_return_status := fnd_api.g_ret_sts_success;
      l_rsv_rec.reservation_id := p_reservation_id;
     /* IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || ':Calling inv_reservation_pub.query_reservation with reservation_id = '
             || p_reservation_id);
      END IF;*/
      inv_reservation_pub.query_reservation
             (p_api_version_number             => 1.0
             ,p_init_msg_lst                   => fnd_api.g_false
             ,x_return_status                  => l_return_status
             ,x_msg_count                      => l_msg_count
             ,x_msg_data                       => l_msg_data
             ,p_query_input                    => l_rsv_rec
             ,p_lock_records                   => fnd_api.g_false
             ,p_sort_by_req_date               => inv_reservation_global.g_query_no_sort
             ,p_cancel_order_mode              => inv_reservation_global.g_cancel_order_no
             ,x_mtl_reservation_tbl            => l_rsv_tbl
             ,x_mtl_reservation_tbl_count      => l_rsv_count
             ,x_error_code                     => l_error_code);
   /*   IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line
            (   g_pkg_name
             || '.'
             || l_api_name
             || 'Return status from inv_reservation_pub.query_reservation is '
             || l_return_status);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || 'Error is :'
                             || l_msg_data);
      END IF;*/
      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE update_resvn_error;
      END IF;
      x_reservation_rec := l_rsv_tbl (1);
   /*   IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;*/
   EXCEPTION
      WHEN update_resvn_error THEN
         x_return_status := l_return_status;
      WHEN OTHERS THEN
        /* IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);*/
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END query_reservation;




END; ---package;

/
