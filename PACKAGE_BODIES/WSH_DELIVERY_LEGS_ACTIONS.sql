--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_LEGS_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_LEGS_ACTIONS" as
/* $Header: WSHDGACB.pls 120.13 2008/03/18 11:53:24 jnpinto noship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DELIVERY_LEGS_ACTIONS';
--
g_wms_installed WSH_UTIL_CORE.Column_Tab_Type;

CURSOR C_IS_FIRST_LEG(p_trip_id in number, p_delivery_id in number, p_pickup_loc_id in number) is
select delivery_leg_id
from wsh_delivery_legs l, wsh_trip_stops s
where s.trip_id = p_trip_id
and   l.delivery_id = p_delivery_id
and   s.stop_id = l.pick_up_stop_id
and   s.stop_location_id = p_pickup_loc_id;

-- Forward Declaration
FUNCTION Check_Rate_Trip_Contents(p_trip_id IN NUMBER,
                                  x_return_status OUT nocopy VARCHAR2)
RETURN VARCHAR2;


PROCEDURE Assign_Deliveries
      (p_del_rows      IN   wsh_util_core.id_tab_type,
       p_trip_id      IN  NUMBER := NULL,
       p_pickup_stop_id     IN   NUMBER := NULL,
       p_pickup_stop_seq      IN   NUMBER := NULL,
       p_dropoff_stop_id    IN  NUMBER := NULL,
       p_dropoff_stop_seq   IN  NUMBER := NULL,
       p_pickup_location_id IN   NUMBER := NULL,
       p_dropoff_location_id   IN   NUMBER := NULL,
       p_create_flag      IN  VARCHAR2 := NULL,
       x_leg_rows       OUT NOCOPY wsh_util_core.id_tab_type,
       x_return_status    OUT NOCOPY  VARCHAR2,
       p_caller           IN VARCHAR2,
       p_pickup_arr_date   	IN   	DATE := to_date(NULL),
       p_pickup_dep_date   	IN   	DATE := to_date(NULL),
       p_dropoff_arr_date  	IN   	DATE := to_date(NULL),
       p_dropoff_dep_date  	IN   	DATE := to_date(NULL),
       p_sc_pickup_date         IN      DATE   DEFAULT NULL,
       p_sc_dropoff_date        IN      DATE   DEFAULT NULL
) IS

CURSOR stop_exists (l_trip_stop_id IN NUMBER) IS
SELECT   status_code ,
         NVL(SHIPMENTS_TYPE_FLAG,'O') SHIPMENTS_TYPE_FLAG,   -- J-IB-NPARIKH
         stop_location_id
FROM   wsh_trip_stops
WHERE stop_id = l_trip_stop_id;

CURSOR delivery_info (del_id IN NUMBER) IS
SELECT  initial_pickup_location_id,
initial_pickup_date,
ultimate_dropoff_location_id,
ultimate_dropoff_date,
organization_id,
status_code,
nvl(shipment_direction,'O') shipment_direction,    -- J-IB-NPARIKH
-- J: W/V Changes
gross_weight,
net_weight,
volume,
mode_of_transport,
freight_terms_code,
name,
customer_id
FROM    wsh_new_deliveries
WHERE delivery_id = del_id;

/* J TP Release : dels can be assigned to planned trips as long as they don't create new stops */
cursor get_trip_status(c_trip_id in NUMBER) is
select status_code, planned_flag,
       NVL(SHIPMENTS_TYPE_FLAG,'O') SHIPMENTS_TYPE_FLAG,   -- J-IB-NPARIKH
       mode_of_transport
from wsh_trips
where trip_id = c_trip_id
FOR UPDATE NOWAIT;

l_plannedflag VARCHAR2(1);

CURSOR leg_exists ( del_id IN NUMBER) IS
SELECT   dg.delivery_leg_id,
st1.stop_location_id,
st2.stop_location_id
FROM    wsh_trip_stops st1,
wsh_trip_stops st2,
wsh_delivery_legs dg
WHERE st1.stop_id = dg.pick_up_stop_id AND
st2.stop_id = dg.drop_off_stop_id AND
st1.trip_id = p_trip_id AND
st2.trip_id = p_trip_id AND
dg.delivery_id = del_id
FOR UPDATE NOWAIT;
/* H integration added sequence number logic */


e_lock_error         EXCEPTION;
pragma EXCEPTION_INIT(e_lock_error,-54);

--bug 4266758
--This cursor is opened (instead of get_stop cursor)
--When the following conditions are met
--a) The caller is form.
--b) The action is assign to trip
--c) The mod is PAD
--d) In Assign delivery to trip window, the "New" check box is checked.

CURSOR get_stop_new (l_location_id IN NUMBER,
                 l_PLANNED_ARRIVAL_DATE DATE,
                 l_PLANNED_DEPARTURE_DATE DATE
                ) IS
SELECT   stop_id, stop_sequence_number,
         NVL(SHIPMENTS_TYPE_FLAG,'O') SHIPMENTS_TYPE_FLAG   -- J-IB-NPARIKH
FROM    wsh_trip_stops
WHERE stop_location_id = l_location_id AND
trip_id = p_trip_id AND
status_code <> 'CL'
AND PLANNED_ARRIVAL_DATE = NVL(l_PLANNED_ARRIVAL_DATE,PLANNED_ARRIVAL_DATE)
AND PLANNED_DEPARTURE_DATE = NVL(l_PLANNED_DEPARTURE_DATE,PLANNED_DEPARTURE_DATE)
FOR UPDATE NOWAIT;

CURSOR get_stop (l_location_id IN NUMBER, l_stop_sequence IN NUMBER
                ) IS
SELECT   stop_id, stop_sequence_number,
         NVL(SHIPMENTS_TYPE_FLAG,'O') SHIPMENTS_TYPE_FLAG   -- J-IB-NPARIKH
FROM    wsh_trip_stops
WHERE stop_location_id = l_location_id AND
trip_id = p_trip_id AND
stop_sequence_number = nvl(l_stop_sequence,stop_sequence_number) AND
status_code <> 'CL'
FOR UPDATE NOWAIT;

CURSOR max_leg_seq_number ( del_id IN NUMBER) IS
SELECT   max(dg.sequence_number)
FROM    wsh_delivery_legs dg
WHERE dg.delivery_id = del_id;

CURSOR get_sequence (l_stop_id NUMBER) IS
SELECT stop_sequence_number
FROM wsh_trip_stops
WHERE stop_id = l_stop_id;

CURSOR c_check_dummystops(p_stop_id IN NUMBER, p_trip_id IN NUMBER) IS
SELECT 'Y'
FROM wsh_trip_stops wts1, wsh_trip_stops wts2
WHERE wts1.trip_id=p_trip_id
AND wts2.trip_id=p_trip_id
AND wts1.stop_id<>wts2.stop_id
AND wts1.stop_id=p_stop_id
AND ((wts2.physical_location_id=wts1.stop_location_id AND wts2.physical_stop_id IS NULL)
     OR (wts1.physical_location_id=wts2.stop_location_id AND  wts1.physical_stop_id IS NULL)
    );

-- c_get_seq_numbers will derive the sequence numbers
-- for all stop locations populated in wsh_tmp
CURSOR c_get_seq_numbers is
  select id,rownum*10
  from(
    select id
    from   wsh_tmp
    order  by to_date(column1,'DD-MM-RRRR HH24:MI:SS'),flag desc
  );

-- Get Previous stops W/V converted to c_wt_uom/c_vol_uom
CURSOR c_get_prev_seq_wv(p_trip_id NUMBER, p_stop_seq NUMBER, p_wt_uom VARCHAR2, p_vol_uom VARCHAR2) IS
select wsh_wv_utils.convert_uom( WEIGHT_UOM_CODE, p_wt_uom, DEPARTURE_GROSS_WEIGHT, null) gross_weight,
       wsh_wv_utils.convert_uom( WEIGHT_UOM_CODE, p_wt_uom, DEPARTURE_NET_WEIGHT, null) net_weight,
       wsh_wv_utils.convert_uom( VOLUME_UOM_CODE, p_vol_uom, DEPARTURE_VOLUME, null) volume
from   wsh_trip_stops
where  trip_id = p_trip_id
and    stop_sequence_number < p_stop_seq
order  by stop_sequence_number desc;

CURSOR c_next_seq_exists (p_trip_id NUMBER, p_stop_seq NUMBER) IS
select 'x'
from   wsh_trip_stops
where  trip_id = p_trip_id
and    stop_sequence_number > p_stop_seq;

l_customer_id NUMBER;
l_del_rows                wsh_util_core.id_tab_type;
l_pickup_location_id_tbl  wsh_util_core.id_tab_type;
l_pickup_date_tbl         wsh_util_core.date_Tab_Type;
l_dropoff_location_id_tbl wsh_util_core.id_tab_type;
l_dropoff_date_tbl        wsh_util_core.date_Tab_Type;
l_organization_id_tbl     wsh_util_core.id_tab_type;
l_status_code_tbl         wsh_util_core.column_Tab_Type;
l_shipment_direction_tbl  wsh_util_core.column_Tab_Type;
l_gross_weight_tbl        wsh_util_core.id_tab_type;
l_net_weight_tbl          wsh_util_core.id_tab_type;
l_volume_tbl              wsh_util_core.id_tab_type;
l_mode_of_transport_tbl   wsh_util_core.column_tab_type;
l_freight_terms_code_tbl  wsh_util_core.column_tab_type;
l_name_tbl                wsh_util_core.column_tab_type;

l_id         wsh_util_core.id_tab_type;
l_seq        wsh_util_core.id_tab_type;
l_pregen_seq VARCHAR2(1);
l_sysdate    DATE;
l_tmp_date   DATE := NULL;
l_gross_weight NUMBER;
l_net_weight   NUMBER;
l_volume       NUMBER;
l_dummy        VARCHAR2(1);
l_next_seq_exists BOOLEAN;

l_check_dummystops VARCHAR2(1);

l_count NUMBER := 0;


--2709662
l_trip_stop_info    wsh_trip_stops_pvt.trip_stop_rec_type;
l_delivery_leg_info   wsh_delivery_legs_pvt.delivery_leg_rec_type;
l_rowid        VARCHAR2(30);
l_pickup_stop_id    NUMBER;
l_dropoff_stop_id   NUMBER;
l_pickup_location_id  NUMBER;
l_del_pu_location_id  NUMBER;
l_old_pickup_loc_id   NUMBER;
l_pickup_date     DATE;
l_dropoff_location_id NUMBER;
l_old_dropoff_loc_id   NUMBER;
l_dropoff_date      DATE;
l_org_id        NUMBER;
l_leg_id        NUMBER;
l_leg_seq_number    NUMBER;
i          BINARY_INTEGER;
l_flag        VARCHAR2(2);
l_default_wt_uom    VARCHAR2(3);
l_default_vol_uom   VARCHAR2(3);
l_num_error     NUMBER := 0;
l_num_warn      NUMBER := 0;
l_trip_status     VARCHAR2(2);
l_delivery_status        VARCHAR2(2);
-- J: W/V Changes
l_org_gross_wt  NUMBER;
l_org_net_wt  NUMBER;
l_org_vol  NUMBER;
l_trip_mode_of_transport VARCHAR2(30);
l_delivery_mode_of_transport VARCHAR2(30);
l_dummy_leg_id NUMBER;
l_dlvy_trip_tbl WMS_SHIPPING_INTERFACE_GRP.g_dlvy_trip_tbl;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);

bad_trip_stop     EXCEPTION;
invalid_trip          EXCEPTION;
mark_reprice_error              EXCEPTION;
rate_trip_contents_fail EXCEPTION;

/* new variables for stop sequence number */
l_stop_sequence_number      NUMBER;
l_pickup_stop_seq        NUMBER;
l_dropoff_stop_seq        NUMBER;
l_new_flag            VARCHAR2(30);

/* H integration  for Multi Leg */
l_stop_rec  WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE;
l_pub_stop_rec  WSH_TRIP_STOPS_PUB.TRIP_STOP_PUB_REC_TYPE;
l_trip_rec  WSH_TRIPS_PVT.TRIP_REC_TYPE;
l_pub_trip_rec  WSH_TRIPS_PUB.TRIP_PUB_REC_TYPE;
l_return_status VARCHAR2(30);

l_pickup_seq    NUMBER;
l_dropoff_seq   NUMBER;
l_stop_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs       VARCHAR2(1);            -- DBI Project
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_DELIVERIES';
--
l_shipment_direction        VARCHAR2(30);
l_trip_shipments_type_flag  VARCHAR2(30);
l_trip_shipments_type_flag_new  VARCHAR2(30);
l_stop_shipments_type_flag  VARCHAR2(30);
l_pu_stop_shipments_type_flag  VARCHAR2(30);
l_do_stop_shipments_type_flag  VARCHAR2(30);
l_pu_stop_shipType_flag_orig   VARCHAR2(30);
l_do_stop_shipType_flag_orig   VARCHAR2(30);
l_mixed_stops               BOOLEAN := FALSE;
l_ob_to_ib_stop             BOOLEAN := FALSE;
--
l_shipping_control     VARCHAR2(30);
l_routing_response_id  NUMBER;
l_routing_request_flag VARCHAR2(30);
l_chkStop_status_code  VARCHAR2(30);
l_has_mixed_deliveries  VARCHAR2(10);
l_stop_opened           VARCHAR2(10);
l_stop_in_rec           WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type;
l_leg_complete		boolean;

l_exception_name varchar2(30);
l_msg   varchar2(2000);
l_exception_msg_count NUMBER;
l_exception_msg_data varchar2(2000);
l_dummy_exception_id NUMBER;
l_rate_trip_dels     VARCHAR2(1);
l_rate_del           VARCHAR2(1);
l_dummy_del          NUMBER;
l_freight_terms_code VARCHAR2(30);

-- 3516052
l_pickup_arr_date   DATE;
l_pickup_dep_date   DATE;
l_dropoff_arr_date   DATE;
l_dropoff_dep_date   DATE;
l_trip_ids           wsh_util_core.id_tab_type;
l_dummy_trip_ids     wsh_util_core.id_tab_type;
l_phys_trip_dropoff_loc_id NUMBER;
l_trip_pickup_loc_id      NUMBER;
l_trip_dropoff_loc_id     NUMBER;
l_delivery_name           wsh_new_deliveries.name%TYPE;

l_stop_seq_mode NUMBER; --SSN Frontport

-- K LPN CONV. rv
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
e_return_excp EXCEPTION;
-- K LPN CONV. rv

--
-- Bug 5336308
-- Added these two exceptions and cleaned up code to not use GOTO statements
-- Also removed savepoint before_Create_stop and corresponding rollbacks
-- since they were redundant.
--
e_InvalidDelExcep	EXCEPTION;
e_CommonExcep           EXCEPTION;
--
BEGIN
   -- check if trip is not closed
   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_STOP_ID',P_PICKUP_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_STOP_SEQ',P_PICKUP_STOP_SEQ);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_STOP_ID',P_DROPOFF_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_STOP_SEQ',P_DROPOFF_STOP_SEQ);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_LOCATION_ID',P_PICKUP_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_LOCATION_ID',P_DROPOFF_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CREATE_FLAG',P_CREATE_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_ARR_DATE',P_PICKUP_ARR_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_DEP_DATE',P_PICKUP_DEP_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_ARR_DATE',P_DROPOFF_ARR_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_DEP_DATE',P_DROPOFF_DEP_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_CALLER',P_CALLER);
      WSH_DEBUG_SV.log(l_module_name,'p_sc_pickup_date',p_sc_pickup_date);
      WSH_DEBUG_SV.log(l_module_name,'p_sc_dropoff_date',p_sc_dropoff_date);
   END IF;
   --
   l_stop_seq_mode := WSH_TRIPS_ACTIONS.GET_STOP_SEQ_MODE;
   --
   open get_trip_status(p_trip_id);
   fetch get_trip_status into l_trip_status, l_plannedflag, l_trip_shipments_type_flag, l_trip_mode_of_transport;
   close get_trip_status;
   --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_trip_shipments_type_flag',l_trip_shipments_type_flag);
    END IF;
    --
   IF  l_trip_status = 'CL'
   THEN
      RAISE Invalid_Trip;
   END IF;
   --
/* J TP Release : dels can be assigned to planned trips as long as they don't create new stops */
   -- Check if the pickup and dropoff stops exist and are not closed

   IF (p_pickup_stop_id IS NOT NULL) THEN

      OPEN stop_exists (p_pickup_stop_id);
      FETCH stop_exists INTO l_flag, l_pu_stop_shipments_type_flag, l_trip_pickup_loc_id;

      IF (stop_exists%NOTFOUND) THEN
         l_flag := 'XX';
         RAISE bad_trip_stop;   -- J-IB-NPARIKH
      END IF;

      CLOSE stop_exists;

      IF (l_flag NOT IN ('OP', 'AR'))
      THEN
         RAISE bad_trip_stop;
      END IF;

      l_pickup_stop_id := p_pickup_stop_id;
      l_pu_stop_shipType_flag_orig := l_pu_stop_shipments_type_flag;
   END IF;

   IF (p_dropoff_stop_id IS NOT NULL) THEN

      OPEN stop_exists (p_dropoff_stop_id);
      FETCH stop_exists INTO l_flag, l_do_stop_shipments_type_flag, l_trip_dropoff_loc_id;

      IF (stop_exists%NOTFOUND) THEN
         l_flag := 'XX';
         RAISE bad_trip_stop;   -- J-IB-NPARIKH
      END IF;

      CLOSE stop_exists;

      IF  (l_flag NOT IN ('OP', 'AR'))
      THEN
         RAISE bad_trip_stop;
      END IF;

      l_dropoff_stop_id := p_dropoff_stop_id;
      l_do_stop_shipType_flag_orig := l_do_stop_shipments_type_flag;
   END IF;

   --a) Check if pickup is being passed as same as dropoff - if yes, error
   IF p_pickup_location_id IS NOT NULL THEN
      l_trip_pickup_loc_id := p_pickup_location_id;
   END IF;
   IF p_dropoff_location_id IS NOT NULL THEN
      l_trip_dropoff_loc_id := p_dropoff_location_id;
   END IF;

   --get the physical locations
   IF (p_dropoff_stop_id IS NOT NULL OR p_dropoff_location_id IS NOT NULL) THEN
             WSH_LOCATIONS_PKG.Convert_internal_cust_location(
               p_internal_cust_location_id   => l_trip_dropoff_loc_id,
               x_internal_org_location_id    => l_phys_trip_dropoff_loc_id,
               x_return_status               => l_return_status);
         IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
            x_return_status:=l_return_status;
            --RETURN;
            raise e_return_excp; -- LPN CONV. rv
         END IF;
         IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_phys_trip_dropoff_loc_id',l_phys_trip_dropoff_loc_id);
         END IF;
   END IF;

   IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN

      l_rate_trip_dels :=  Check_Rate_Trip_Contents(p_trip_id => p_trip_id,
                                                    x_return_status => l_return_status);

      IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN

         RAISE rate_trip_contents_fail;

      END IF;

   END IF;

   -- Delivery Validations
   FOR i IN 1..p_del_rows.count LOOP --{

     OPEN delivery_info (p_del_rows(i));
     FETCH delivery_info INTO l_pickup_location_id, l_pickup_date, l_dropoff_location_id,
                              l_dropoff_date, l_org_id, l_delivery_status, l_shipment_direction,
                              l_org_gross_wt, l_org_net_wt, l_org_vol, l_delivery_mode_of_transport,
                              l_freight_terms_code, l_delivery_name, l_customer_id;
     CLOSE delivery_info;

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'Del '||p_del_rows(i)||' Status '||l_delivery_status);
     END IF;

     -- Check if the delivery is in a valid status.
     IF l_delivery_status in ('CA', 'CL') THEN
        goto skip_delivery;
     END IF;

     --if trip's dropoff is specified as internal, cannot have deliveries with ultimate dropoffs
     --which are not the same internal loc being assigned to the trip
     IF l_trip_dropoff_loc_id IS NOT NULL AND
        l_phys_trip_dropoff_loc_id IS NOT NULL AND
        l_dropoff_location_id <> l_trip_dropoff_loc_id THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DROP_NOTINT');
          FND_MESSAGE.SET_TOKEN('DEL_NAME',l_delivery_name);
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
          goto skip_delivery;
     END IF;

     l_del_rows(l_del_rows.COUNT+1)               := p_del_rows(i);
     l_pickup_location_id_tbl(l_del_rows.COUNT)   := l_pickup_location_id;
     l_pickup_date_tbl(l_del_rows.COUNT)          := l_pickup_date;
     l_dropoff_location_id_tbl (l_del_rows.COUNT) := l_dropoff_location_id;
     l_dropoff_date_tbl(l_del_rows.COUNT)         := l_dropoff_date;
     l_organization_id_tbl(l_del_rows.COUNT)      := l_org_id;
     l_status_code_tbl(l_del_rows.COUNT)          := l_delivery_status;
     l_shipment_direction_tbl(l_del_rows.COUNT)   := l_shipment_direction;
     l_gross_weight_tbl(l_del_rows.COUNT)         := l_org_gross_wt;
     l_net_weight_tbl(l_del_rows.COUNT)           := l_org_net_wt;
     l_volume_tbl(l_del_rows.COUNT)               := l_org_vol;
     l_mode_of_transport_tbl(l_del_rows.COUNT)    := l_delivery_mode_of_transport;
     l_freight_terms_code_tbl(l_del_rows.COUNT)   := l_freight_terms_code;
     l_name_tbl(l_del_rows.COUNT)                 := l_delivery_name;

     goto loop_end1;

      <<skip_delivery>>

        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGN_ERROR');
        FND_MESSAGE.SET_TOKEN('DEL_NAME',l_delivery_name);
        FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
        l_num_error := l_num_error + 1;

      <<loop_end1>>
        null;

   END LOOP; --}

   l_pregen_seq := 'N';
   IF (p_caller = 'AUTOCREATE_TRIP' ) THEN --{

     -- The following logic pre-determines the PAD and sequence numbers for each distinct location(pickup/dropoff)
     IF l_del_rows.COUNT > 1 THEN --{


       IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'Pre determining the sequence numbers/PAD');
       END IF;

       l_pregen_seq := 'Y';
       l_sysdate := sysdate;

       DELETE FROM WSH_TMP;

       IF (p_sc_pickup_date IS NOT NULL) OR (p_sc_dropoff_date IS NOT NULL) THEN --{
         FORALL i in l_del_rows.FIRST..l_del_rows.LAST
           INSERT INTO wsh_tmp(
            ID,
            FLAG,
            COLUMN1)
           SELECT l_pickup_location_id_tbl(i), 'P', to_char(nvl(p_sc_pickup_date,l_sysdate), 'DD-MM-RRRR HH24:MI:SS')
           FROM   dual
           WHERE  NOT EXISTS (
                    select 'x'
                    from  wsh_tmp wt1
                    where wt1.id = l_pickup_location_id_tbl(i)
                    and   wt1.flag='P'
                    and   wt1.column1 = to_char(nvl(p_sc_pickup_date,l_sysdate), 'DD-MM-RRRR HH24:MI:SS'))
           UNION
           SELECT l_dropoff_location_id_tbl(i), 'D', to_char(nvl(p_sc_dropoff_date,l_sysdate), 'DD-MM-RRRR HH24:MI:SS')
           FROM   dual
           WHERE  NOT EXISTS (
                    select 'x'
                    from  wsh_tmp wt1
                    where wt1.id = l_dropoff_location_id_tbl(i)
                    and   wt1.flag='D'
                    and   wt1.column1 = to_char(nvl(p_sc_dropoff_date,l_sysdate), 'DD-MM-RRRR HH24:MI:SS'));
       ELSE
         FORALL i in l_del_rows.FIRST..l_del_rows.LAST
           INSERT INTO wsh_tmp(
            ID,
            FLAG,
            COLUMN1)
           SELECT l_pickup_location_id_tbl(i), 'P', to_char(nvl(l_pickup_date_tbl(i),l_sysdate), 'DD-MM-RRRR HH24:MI:SS')
           FROM   dual
           WHERE  NOT EXISTS (
                    select 'x'
                    from  wsh_tmp wt1
                    where wt1.id = l_pickup_location_id_tbl(i)
                    and   wt1.flag='P'
                    and   wt1.column1 = to_char(nvl(l_pickup_date_tbl(i),l_sysdate), 'DD-MM-RRRR HH24:MI:SS'))
           UNION
           SELECT l_dropoff_location_id_tbl(i), 'D', to_char(nvl(l_dropoff_date_tbl(i),l_sysdate), 'DD-MM-RRRR HH24:MI:SS')
           FROM   dual
           WHERE  NOT EXISTS (
                    select 'x'
                    from  wsh_tmp wt1
                    where wt1.id = l_dropoff_location_id_tbl(i)
                    and   wt1.flag='D'
                    and   wt1.column1 = to_char(nvl(l_dropoff_date_tbl(i),l_sysdate), 'DD-MM-RRRR HH24:MI:SS'));
       END IF; --}

       -- For pickups the PAD is min of all initial_pickup_date
       DELETE FROM wsh_tmp wt1
       WHERE  wt1.flag = 'P'
       AND    exists (
               select 'x'
               from   wsh_tmp wt2
               where  wt1.id = wt2.id
               and    wt2.flag = 'P'
               and    to_date(wt2.column1,'DD-MM-RRRR HH24:MI:SS') < to_date(wt1.column1,'DD-MM-RRRR HH24:MI:SS'));

       -- For dropoffs the PAD is max of all ultimate_dropoff_date
       DELETE FROM wsh_tmp wt1
       WHERE  wt1.flag = 'D'
       AND    exists (
               select 'x'
               from   wsh_tmp wt2
               where  wt1.id = wt2.id
               and    wt2.flag = 'D'
               and    to_date(wt2.column1,'DD-MM-RRRR HH24:MI:SS') > to_date(wt1.column1,'DD-MM-RRRR HH24:MI:SS'));

       OPEN c_get_seq_numbers;
       LOOP
         FETCH c_get_seq_numbers BULK COLLECT INTO l_id,l_seq LIMIT 1000;

         IF l_id.COUNT > 0 THEN
           FORALL i in l_id.FIRST..l_id.LAST
             UPDATE wsh_tmp
             set    column2 = l_seq(i)
             WHERE  id = l_id(i);
         END IF;

         IF l_debug_on THEN
           FOR i in l_id.FIRST..l_id.LAST LOOP
             wsh_debug_sv.log(l_module_name, 'l_id '||l_id(i)||' l_seq '||l_seq(i));
           END LOOP;
         END IF;

         EXIT WHEN c_get_seq_numbers%NOTFOUND;
       END LOOP;
       CLOSE c_get_seq_numbers;

     END IF; --}

   END IF; --}

   FOR i IN 1..l_del_rows.count LOOP
    --(
    -- Bug 5336308
    -- Added BEGIN-END block within this loop, added exception handlers to replace use of GOTO logic
    --
    BEGIN
     --(
      -- Initialize cursor return variables for each loop count
      SAVEPOINT ASSIGN_DEL_TO_TRIP;

      l_leg_id := NULL;
      l_leg_seq_number := NULL;
      l_pickup_location_id := NULL;
      l_dropoff_location_id := NULL;
      l_tmp_date := NULL;

      -- Fetch delivery information including initial_pickup_location,
      -- ultimate_dropoff_location, dates and organization_id

      l_pickup_location_id  := l_pickup_location_id_tbl(i);
      l_pickup_date         := l_pickup_date_tbl(i);
      l_dropoff_location_id := l_dropoff_location_id_tbl(i);
      l_dropoff_date        := l_dropoff_date_tbl(i);
      l_org_id              := l_organization_id_tbl(i);
      l_delivery_status     := l_status_code_tbl(i);
      l_shipment_direction  := l_shipment_direction_tbl(i);
      l_org_gross_wt        := l_gross_weight_tbl(i);
      l_org_net_wt          := l_net_weight_tbl(i);
      l_org_vol             := l_volume_tbl(i);
      l_delivery_mode_of_transport   := l_mode_of_transport_tbl(i);
      l_freight_terms_code  := l_freight_terms_code_tbl(i);
      l_delivery_name       := l_name_tbl(i);

      l_del_pu_location_id := l_pickup_location_id;

      -- If the pick up date and drop off date are defaulted from the
      -- ship confirm API then use these dates.  Bug 3913206
      --
      IF (p_sc_pickup_date IS NOT NULL) OR (p_sc_dropoff_date IS NOT NULL)
      THEN --{
         l_pickup_date := p_sc_pickup_date;
         l_dropoff_date := p_sc_dropoff_date;
      END IF; --}
     --

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'Processing Del '||l_del_rows(i)||' Shipment direction '|| l_shipment_direction);
     END IF;
     --

     IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
        IF (NVL(l_rate_trip_dels, 'X') <> 'M')   THEN
        -- IF l_rate_trip_dels = 'M', then trip is already mixed, exceptions have been logged.

           l_rate_del := Check_Rate_Delivery(p_delivery_id => NULL,
                                             p_freight_terms_code => l_freight_terms_code,
                                             p_shipment_direction => l_shipment_direction,
                                             x_return_status => l_return_status);

           IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
              RAISE e_InvalidDelExcep; -- Bug 5336308
           END IF;

           IF (l_rate_del <> l_rate_trip_dels) AND (l_rate_trip_dels <> 'M') THEN
           -- We need to check for l_rate_trip_dels = 'M' again because it could have been populated in
           -- the above call.


              -- Raise Warning
              FND_MESSAGE.Set_Name('WSH', 'WSH_RATE_MIXED_TRIP_WARN');
              wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING, l_module_name);
              l_num_warn := l_num_warn + 1;

              -- Log Exception

              l_exception_name := 'WSH_RATE_MIXED_TRIP';
              l_msg := FND_MESSAGE.Get_String('WSH', 'WSH_RATE_MIXED_TRIP_EXC');


              wsh_xc_util.log_exception(
                     p_api_version             => 1.0,
                     x_return_status           => l_return_status,
                     x_msg_count               => l_exception_msg_count,
                     x_msg_data                => l_exception_msg_data,
                     x_exception_id            => l_dummy_exception_id ,
                     p_logged_at_location_id   => l_pickup_location_id,
                     p_exception_location_id   => l_pickup_location_id,
                     p_logging_entity          => 'SHIPPER',
                     p_logging_entity_id       => FND_GLOBAL.USER_ID,
                     p_exception_name          => l_exception_name,
                     p_message                 => l_msg,
                     p_trip_id                 => p_trip_id
                     );

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS  THEN
                 l_num_warn := l_num_warn + 1;
                 RAISE e_InvalidDelExcep; -- Bug 5336308
              END IF;

           END IF;
        END IF;

     END IF;
     --
      -- Get default UOMs for the shipping organization. Do not check
      -- return status as these are not mandatory parameters.

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.GET_DEFAULT_UOMS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_wv_utils.get_default_uoms(l_org_id, l_default_wt_uom, l_default_vol_uom, x_return_status);

      -- Check if delivery leg exists for the delivery/trip combination
      -- Skip this delivery if leg exists

      OPEN leg_exists (l_del_rows(i));
      FETCH leg_exists INTO l_leg_id, l_old_pickup_loc_id, l_old_dropoff_loc_id;
      CLOSE leg_exists;

      IF (l_old_pickup_loc_id = nvl(p_pickup_location_id, l_pickup_location_id)) AND
      (l_old_dropoff_loc_id = nvl(p_dropoff_location_id, l_dropoff_location_id)) THEN
         RAISE e_CommonExcep; -- Bug 5336308
      END IF;

      --TD: Check if trip stop can be created for this trip (trip should not be planned)
      -- If create flag is set and no stops exist then check if stops
      -- need to be created

      IF p_pickup_location_id IS NOT NULL THEN
         l_pickup_location_id := p_pickup_location_id;
      END IF;
      IF p_dropoff_location_id IS NOT NULL THEN
         l_dropoff_location_id := p_dropoff_location_id;
      END IF;

      IF (p_create_flag = 'Y')AND(p_pickup_stop_id IS NULL) THEN

         l_pickup_stop_id := NULL;
         /* the new Pickup takes precedence over delivery pickup location */
         IF (p_pickup_location_id IS NOT NULL) THEN
            l_pickup_location_id := p_pickup_location_id;
         END IF;

         IF p_caller = 'WSH_FSTRXASSIGNTRIP' AND p_pickup_stop_seq IS NULL THEN
            OPEN get_stop_new (l_pickup_location_id,P_PICKUP_ARR_DATE,P_PICKUP_DEP_DATE);
            FETCH get_stop_new INTO l_pickup_stop_id, l_pickup_stop_seq, l_stop_shipments_type_flag;
            CLOSE get_stop_new;
         ELSE
            OPEN get_stop (l_pickup_location_id,p_pickup_stop_seq);
            FETCH get_stop INTO l_pickup_stop_id, l_pickup_stop_seq, l_stop_shipments_type_flag;
            CLOSE get_stop;
         END IF;

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_pickup_stop_id-'||l_pickup_stop_id);
           WSH_DEBUG_SV.log(l_module_name,'l_pickup_location_id-'||l_pickup_location_id);
           WSH_DEBUG_SV.log(l_module_name,'pickup_stop_seq-'||p_pickup_stop_seq);
           WSH_DEBUG_SV.log(l_module_name,'l_stop_shipments_type_flag',l_stop_shipments_type_flag);
         END IF;
         /* H integration , for stop sequence number */
         IF p_pickup_location_id IS NOT NULL THEN
            l_new_flag := 'PICKUP';
            l_pickup_stop_seq := p_pickup_stop_seq;
         ELSE
            l_new_flag := 'DELIVERY';
            l_pickup_stop_seq := NULL;
         END IF;

         --4106241 : Call get_new_sequence_number only if l_pickup_stop_seq  and l_pickup_stop_id are null.
         If l_pickup_stop_seq is NULL  and l_pickup_stop_id is NULL THEN
           IF l_pregen_seq = 'N' THEN
           --
              --
              -- Debug Statements
              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_VALIDATIONS.GET_NEW_SEQUENCE_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              WSH_TRIP_STOPS_VALIDATIONS.get_new_sequence_number
                 (x_stop_sequence_number => l_pickup_stop_seq,
                  p_trip_id => p_trip_id,
                  p_status_code => 'OP',
                  p_stop_id => null, -- as of now no validations
                  p_new_flag => l_new_flag,
                  x_return_status => l_return_status
                 );
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 x_return_status := l_return_status;
                 raise e_return_excp; -- LPN CONV. rv
              END IF;
           ELSE
             BEGIN
               select column2, to_date(column1,'DD-MM-RRRR HH24:MI:SS')
               into   l_pickup_stop_seq,l_tmp_date
               from   wsh_tmp
               where  id = l_pickup_location_id
               and    flag = 'P';
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 raise e_return_excp; -- LPN CONV. rv
               WHEN OTHERS THEN
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 raise e_return_excp; -- LPN CONV. rv
             END;
           END IF; --}
         --
         END IF;
              /* End of H integration , for stop sequence number */

         IF (l_pickup_stop_id IS NULL) THEN
            l_trip_stop_info.trip_id := p_trip_id;
            l_trip_stop_info.status_code := 'OP';
            --l_trip_stop_info.stop_sequence_number := -99;
            l_trip_stop_info.stop_sequence_number := l_pickup_stop_seq;
            l_trip_stop_info.stop_location_id  := l_pickup_location_id;
            -- Bug 3349133
            IF l_pregen_seq = 'N' THEN
            l_trip_stop_info.planned_arrival_date := NVL(l_pickup_date, sysdate);
            ELSE
            l_trip_stop_info.planned_arrival_date := l_tmp_date;
            END IF;
            l_trip_stop_info.planned_departure_date := l_trip_stop_info.planned_arrival_date;
            l_trip_stop_info.weight_uom_code   := l_default_wt_uom;
            l_trip_stop_info.volume_uom_code   := l_default_vol_uom;

            -- Default the W/V from previous stop(sequence)
            l_gross_weight := NULL;
            l_net_weight := NULL;
            l_volume := NULL;

            OPEN c_get_prev_seq_wv(p_trip_id, l_pickup_stop_seq, l_default_wt_uom, l_default_vol_uom);
            FETCH c_get_prev_seq_wv into l_gross_weight,l_net_weight,l_volume;
            CLOSE c_get_prev_seq_wv;

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Prev stop Gross '||l_gross_weight||' Net '||l_net_weight||' Vol '||l_volume);
            END IF;

            l_trip_stop_info.departure_gross_weight := l_gross_weight;
            l_trip_stop_info.departure_net_weight   := l_net_weight;
            l_trip_stop_info.departure_volume       := l_volume;

            -- J-IB-NPARIKH-{
            --
            -- For a new stop, calculate value of shipments type flag
            -- using shipment direction of the delivery being assigned.
            --
            IF l_shipment_direction IN ('O','IO')
            THEN
                l_trip_stop_info.shipments_type_flag := 'O';
            ELSE
                l_trip_stop_info.shipments_type_flag := 'I';
            END IF;
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_trip_stop_info.shipments_type_flag',l_trip_stop_info.shipments_type_flag);
            END IF;
            --
            -- J-IB-NPARIKH-}

            IF p_pickup_location_id IS NOT NULL THEN
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'updating dates for pickup loc which is getting created',p_pickup_location_id );
               END IF;
               l_trip_stop_info.planned_arrival_date := p_pickup_arr_date;
               l_trip_stop_info.planned_departure_date := p_pickup_dep_date;
            END IF;


            /* H integration -  call Multi Leg FTE */
            IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               wsh_fte_integration.trip_stop_validations
               (p_stop_rec => l_trip_stop_info,
               p_trip_rec => l_trip_rec,
               p_action => 'ADD',
               x_return_status => l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     l_num_warn := l_num_warn + 1;
                  ELSE
                     x_return_status := l_return_status;
                     --
                     -- Debug Statements
                     --
                     --IF l_debug_on THEN
                        --WSH_DEBUG_SV.pop(l_module_name);
                     --END IF;
                     --
                     --RETURN;
                     raise e_return_excp; -- LPN CONV. rv
                  END IF;
               END IF;

            END IF;

            /* End of H integration - call Multi Leg FTE */
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.CREATE_TRIP_STOP',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            --

            wsh_trip_stops_pvt.create_trip_stop(l_trip_stop_info,l_rowid,l_pickup_stop_id, x_return_status);

            IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               RAISE e_InvalidDelExcep; -- Bug 5336308
            END IF;

            --For a Routing Firm trip, when action is assign trip, check if the new stop
            --created is a dummy stop which already has physical stop in trip or if the
            --new stop is the physical stop and dummy is already present in the trip. Only
            --in these 2 cases, we allow stop creation for Routing Firm trip. Else, this
            --delivery cannot be assigned to the trip as this entails creation of a new stop
            --This has to be done after create stop as linking happens only at creation time
            IF l_plannedflag='Y' AND p_caller like '%ASSIGNTRIP%' THEN
               OPEN c_check_dummystops(l_pickup_stop_id, p_trip_id);
               FETCH c_check_dummystops INTO l_check_dummystops;
               IF c_check_dummystops%NOTFOUND THEN
                  CLOSE c_check_dummystops;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_trips_pvt.get_name',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  FND_MESSAGE.SET_NAME('WSH','WSH_FIRMTRIP_NO_NEW_STOP');
                  FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));
                  wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
                  RAISE e_InvalidDelExcep; -- Bug 5336308
               END IF;
               CLOSE c_check_dummystops;
            END IF;

            IF( WSH_UTIL_CORE.FTE_Is_Installed = 'Y') THEN
                l_trip_mode_of_transport := NVL(l_trip_mode_of_transport, l_delivery_mode_of_transport);
                WSH_UTIL_VALIDATE.Validate_Trip_MultiStops (
                  p_trip_id           => p_trip_id,
                  p_mode_of_transport => l_trip_mode_of_transport,
                  x_return_status     => x_return_status);
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_MultiStops x_return_status',x_return_status);
                END IF;

                IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE e_InvalidDelExcep; -- Bug 5336308
                END IF;

            END IF;
            -- 3516052 keep the pickup arrival date and departure date
            l_pickup_arr_date := l_trip_stop_info.planned_arrival_date;
            l_pickup_dep_date := l_trip_stop_info.planned_departure_date;
            l_pickup_stop_seq := l_trip_stop_info.stop_sequence_number; --SSN Frontport

         ELSE
            -- Get pvt type record structure for stop
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.GET_STOP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_trip_stops_grp.get_stop_details_pvt
            (p_stop_id => l_pickup_stop_id,
            x_stop_rec => l_stop_rec,
            x_return_status => l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status;
               --
               -- Debug Statements
               --
               --IF l_debug_on THEN
                  --WSH_DEBUG_SV.pop(l_module_name);
               --END IF;
               --
               --RETURN;
               raise e_return_excp; -- LPN CONV. rv
            END IF;

            -- 3516052 keep the pickup arrival date and deaprture date
            l_pickup_arr_date := l_stop_rec.planned_arrival_date;
            l_pickup_dep_date := l_stop_rec.planned_departure_date;

            --get pickup time, if > l_pickup_date, then update pickup stop
            --with the l_pickup_date so that the earliet time is set
            /* H integration - call Multi Leg FTE */
            IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN

               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               wsh_fte_integration.trip_stop_validations
               (p_stop_rec => l_stop_rec,
               p_trip_rec => l_trip_rec,
               p_action => 'UPDATE',
               x_return_status => l_return_status);
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     l_num_warn := l_num_warn + 1;
                  ELSE
                     x_return_status := l_return_status;
                     --
                     -- Debug Statements
                     --
                     --IF l_debug_on THEN
                        --WSH_DEBUG_SV.pop(l_module_name);
                     --END IF;
                     --
                     --RETURN;
                     raise e_return_excp; -- LPN CONV. rv
                  END IF;
               END IF;

            END IF;

            -- J-IB-NPARIKH-{
            --
            --
            -- For an existing stop, calculate value of shipments type flag
            -- by calling WSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WWSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag
                (
                    p_trip_id               => p_trip_id,
                    p_stop_id               => l_pickup_stop_id,
                    p_action                => 'ASSIGN',
                    p_shipment_direction    => l_shipment_direction,
                    x_shipments_type_flag   => l_stop_shipments_type_flag,
                    x_return_status         => l_return_status
                );
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warn,
                x_num_errors    => l_num_error
              );
            --
            -- J-IB-NPARIKH-}

            /* End of H integration - call Multi Leg FTE */
            update wsh_trip_stops
            set planned_departure_date=least(nvl(l_pickup_date,sysdate),planned_departure_date),
            planned_arrival_date=least(nvl(l_pickup_date,sysdate),planned_arrival_date),
                   shipments_type_flag = l_stop_shipments_type_flag ,   -- J-IB-NPARIKH
                   last_update_date   = SYSDATE,    -- J-IB-NPARIKH
                   last_updated_by    = FND_GLOBAL.USER_ID,   -- J-IB-NPARIKH
                   last_update_login  = FND_GLOBAL.LOGIN_ID     -- J-IB-NPARIKH
            where stop_id=l_pickup_stop_id;

   --
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id -',l_pickup_stop_id);
        END IF;
	l_stop_tab(1) := l_pickup_stop_id;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
	  rollback to assign_del_to_trip;
          -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            --WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --return;
          raise e_return_excp; -- LPN CONV. rv
        END IF;
        -- End of Code for DBI Project
   --
       IF p_caller like '%ASSIGNTRIP%' THEN
               l_trip_ids(1):=p_trip_id;
               WSH_TRIPS_ACTIONS.Handle_Internal_Stops
               (   p_trip_ids          => l_trip_ids,
                  p_caller            => p_caller,
                  x_success_trip_ids  => l_dummy_trip_ids,
                  x_return_status     => l_return_status);

               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Handle_Internal_Stops after updating stop l_return_status',l_return_status);
               END IF;

               wsh_util_core.api_post_call
                (
                  p_return_status => l_return_status,
                  x_num_warnings  => l_num_warn,
                  x_num_errors    => l_num_error
                );
            END IF;
         END IF;

      END IF;

      IF (p_create_flag = 'Y')AND(p_dropoff_stop_id IS NULL) THEN

         l_dropoff_stop_id := NULL;
         l_dropoff_stop_seq := NULL;

         IF (p_dropoff_location_id IS NOT NULL) THEN
            l_dropoff_location_id := p_dropoff_location_id;
         END IF;

         IF p_caller = 'WSH_FSTRXASSIGNTRIP' AND p_dropoff_stop_seq IS NULL THEN
            OPEN get_stop_new (l_dropoff_location_id,P_DROPOFF_ARR_DATE,P_DROPOFF_DEP_DATE);
            FETCH get_stop_new INTO l_dropoff_stop_id, l_dropoff_stop_seq,l_stop_shipments_type_flag;
            CLOSE get_stop_new;
         ELSE
            OPEN get_stop (l_dropoff_location_id,p_dropoff_stop_seq);
            FETCH get_stop INTO l_dropoff_stop_id, l_dropoff_stop_seq,l_stop_shipments_type_flag;
            CLOSE get_stop;
         END IF;

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_dropoff_stop_id-'||l_dropoff_stop_id);
           WSH_DEBUG_SV.log(l_module_name,'l_dropoff_location_id-'||l_dropoff_location_id);
           WSH_DEBUG_SV.log(l_module_name,'dropoff_stop_seq-'||p_dropoff_stop_seq);
           WSH_DEBUG_SV.log(l_module_name,'l_stop_shipments_type_flag'||l_stop_shipments_type_flag);
         END IF;

         -- bug 2784197
         open get_sequence(l_pickup_stop_id);
         fetch get_sequence into l_pickup_stop_seq;
         close get_sequence;
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_pickup_stop_seq',l_pickup_stop_seq);
            WSH_DEBUG_SV.log(l_module_name,'l_dropoff_stop_seq',l_dropoff_stop_seq);
         END IF;
         IF nvl(l_dropoff_stop_seq, 0 ) = 0
         OR nvl(l_dropoff_stop_seq, 0 ) < nvl(l_pickup_stop_seq,0) THEN
           l_dropoff_stop_id := NULL;
         END IF;
         -- bug 2784197

         /* H integration , for stop sequence number */
         IF p_dropoff_location_id IS NOT NULL THEN
            l_new_flag := 'DROPOFF';
            l_dropoff_stop_seq := p_dropoff_stop_seq;
         ELSE
            l_new_flag := 'DELIVERY';
            l_dropoff_stop_seq := null;
         END IF;

         --
         -- Debug Statements
         --
         --4106241 : Call the get_new_sequence_number API only if l_dropoff_stop_seq and l_dropoff_stop_id are null.
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_dropoff_stop_seq before api call is:',l_dropoff_stop_seq);
         END IF;
         IF l_dropoff_stop_seq is NULL and l_dropoff_stop_id is NULL THEN

           IF l_pregen_seq = 'N' THEN --{
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_VALIDATIONS.GET_NEW_SEQUENCE_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --

              WSH_TRIP_STOPS_VALIDATIONS.get_new_sequence_number
                 (x_stop_sequence_number => l_dropoff_stop_seq,
                  p_trip_id => p_trip_id,
                  p_status_code => 'OP',
                  p_stop_id => null, -- as of now no validations
                  p_new_flag => l_new_flag,
                  x_return_status => l_return_status
                 );

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 x_return_status := l_return_status;
                 raise e_return_excp; -- LPN CONV. rv
              END IF;
           ELSE
             BEGIN
               select column2,to_date(column1,'DD-MM-RRRR HH24:MI:SS')
               into   l_dropoff_stop_seq,l_tmp_date
               from   wsh_tmp
               where  id = l_dropoff_location_id
               and    flag = 'D';
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 raise e_return_excp; -- LPN CONV. rv
               WHEN OTHERS THEN
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 raise e_return_excp; -- LPN CONV. rv
             END;
           END IF; --}

         END IF;
         /* End of H integration , for stop sequence number */

         IF (l_dropoff_stop_id IS NULL) THEN
            l_trip_stop_info.trip_id := p_trip_id;
            l_trip_stop_info.status_code := 'OP';
            --l_trip_stop_info.stop_sequence_number := -99;
            l_trip_stop_info.stop_sequence_number := l_dropoff_stop_seq;
            l_trip_stop_info.stop_location_id  := l_dropoff_location_id;
            IF l_pregen_seq = 'N' THEN
            l_trip_stop_info.planned_arrival_date := greatest(NVL(l_pickup_date, sysdate) + WSH_TRIPS_ACTIONS.C_TEN_MINUTES, NVL(l_dropoff_date, sysdate));
            ELSE
              l_trip_stop_info.planned_arrival_date := l_tmp_date;
            END IF;
            -- bug 3349133, the planned arrival date of pickup stop and dropoff stop is 10 minutes apart
            l_trip_stop_info.planned_departure_date := l_trip_stop_info.planned_arrival_date;
            l_trip_stop_info.weight_uom_code   := l_default_wt_uom;
            l_trip_stop_info.volume_uom_code   := l_default_vol_uom;

            -- Need to clear out all the w/v value from previous stop record
            l_trip_stop_info.departure_gross_weight := null;
            l_trip_stop_info.departure_net_weight   := null;
            l_trip_stop_info.departure_volume       := null;

            -- Default the W/V from previous stop(sequence) only if the current sequence is not the last one at this point
            l_next_seq_exists := TRUE;

            OPEN c_next_seq_exists(p_trip_id, l_dropoff_stop_seq);
            FETCH c_next_seq_exists INTO l_dummy;
            IF    c_next_seq_exists%NOTFOUND THEN
              l_next_seq_exists := FALSE;
            END IF;
            CLOSE c_next_seq_exists;

            IF l_next_seq_exists THEN
              l_gross_weight := NULL;
              l_net_weight := NULL;
              l_volume := NULL;

              OPEN c_get_prev_seq_wv(p_trip_id, l_dropoff_stop_seq, l_default_wt_uom, l_default_vol_uom);
              FETCH c_get_prev_seq_wv into l_gross_weight,l_net_weight,l_volume;
              CLOSE c_get_prev_seq_wv;

              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Prev stop Gross '||l_gross_weight||' Net '||l_net_weight||' Vol '||l_volume);
              END IF;

              l_trip_stop_info.departure_gross_weight := l_gross_weight;
              l_trip_stop_info.departure_net_weight   := l_net_weight;
              l_trip_stop_info.departure_volume       := l_volume;
            END IF;

            -- J-IB-NPARIKH-{
            --
            -- For a new stop, calculate value of shipments type flag
            -- using shipment direction of the delivery being assigned.
            --
            IF l_shipment_direction IN ('O','IO')
            THEN
                l_trip_stop_info.shipments_type_flag := 'O';
            ELSE
                l_trip_stop_info.shipments_type_flag := 'I';
            END IF;
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_trip_stop_info.shipments_type_flag',l_trip_stop_info.shipments_type_flag);
            END IF;
            --
            -- J-IB-NPARIKH-}

            IF p_dropoff_location_id IS NOT NULL THEN
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'updating dates for dropoff loc which us getting created',p_dropoff_location_id);
               END IF;
               l_trip_stop_info.planned_arrival_date := p_dropoff_arr_date;
               l_trip_stop_info.planned_departure_date := p_dropoff_dep_date;
            END IF;


            /* H integration -  call Multi Leg FTE */
            IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               wsh_fte_integration.trip_stop_validations
               (p_stop_rec => l_trip_stop_info,
               p_trip_rec => l_trip_rec,
               p_action => 'ADD',
               x_return_status => l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     l_num_warn := l_num_warn + 1;
                  ELSE
                     x_return_status := l_return_status;
                     --
                     -- Debug Statements
                     --
                     --IF l_debug_on THEN
                        --WSH_DEBUG_SV.pop(l_module_name);
                     --END IF;
                     --
                     --RETURN;
                     raise e_return_excp; -- LPN CONV. rv
                  END IF;
               END IF;

            END IF;
            /* End of H integration - call Multi Leg FTE */
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.CREATE_TRIP_STOP',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_trip_stops_pvt.create_trip_stop(l_trip_stop_info,l_rowid,l_dropoff_stop_id, x_return_status);

            IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               RAISE e_InvalidDelExcep; -- Bug 5336308
            END IF;

            --For a Routing Firm trip, when action is assign trip, check if the new stop
            --created is a dummy stop which already has physical stop in trip or if the
            --new stop is the physical stop and dummy is already present in the trip. Only
            --in these 2 cases, we allow stop creation for Routing Firm trip. Else, this
            --delivery cannot be assigned to the trip as this entails creation of a new stop
            --This has to be done after create stop as linking happens only at creation time
            IF l_plannedflag='Y' AND p_caller like '%ASSIGNTRIP%' THEN

               OPEN c_check_dummystops(l_dropoff_stop_id,p_trip_id);
               FETCH c_check_dummystops INTO l_check_dummystops;
               IF c_check_dummystops%NOTFOUND THEN
                  CLOSE c_check_dummystops;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_trips_pvt.get_name',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  FND_MESSAGE.SET_NAME('WSH','WSH_FIRMTRIP_NO_NEW_STOP');
                  FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));
                  wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
                  RAISE e_InvalidDelExcep; -- Bug 5336308
               END IF;
               CLOSE c_check_dummystops;
            END IF;

            IF( WSH_UTIL_CORE.FTE_Is_Installed = 'Y') THEN
                l_trip_mode_of_transport := NVL(l_trip_mode_of_transport, l_delivery_mode_of_transport);
                WSH_UTIL_VALIDATE.Validate_Trip_MultiStops (
                  p_trip_id           => p_trip_id,
                  p_mode_of_transport => l_trip_mode_of_transport,
                  x_return_status     => x_return_status);
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_MultiStops x_return_status',x_return_status);
                END IF;

                IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE e_InvalidDelExcep; -- Bug 5336308
                END IF;

            END IF;
            -- 3516052 keep the pickup arrival date and deaprture date
            l_dropoff_arr_date := l_trip_stop_info.planned_arrival_date;
            l_dropoff_dep_date := l_trip_stop_info.planned_departure_date;
            l_dropoff_stop_seq := l_trip_stop_info.stop_sequence_number; --SSN Frontport

         ELSE
            -- 3516052
            -- Get pvt type record structure for stop
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.GET_STOP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_trip_stops_grp.get_stop_details_pvt
            (p_stop_id => l_dropoff_stop_id,
            x_stop_rec => l_stop_rec,
            x_return_status => l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status;
               --
               -- Debug Statements
               --
               --IF l_debug_on THEN
                  --WSH_DEBUG_SV.pop(l_module_name);
               --END IF;
               --
               --RETURN;
               raise e_return_excp; -- LPN CONV. rv
            END IF;

            -- 3516052 keep the dropoff arrival date and deaprture date
            l_dropoff_arr_date := l_stop_rec.planned_arrival_date;
            l_dropoff_dep_date := l_stop_rec.planned_departure_date;


            /* H integration - call Multi Leg FTE */
            IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN

               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               wsh_fte_integration.trip_stop_validations
               (p_stop_rec => l_stop_rec,
               p_trip_rec => l_trip_rec,
               p_action => 'UPDATE',
               x_return_status => l_return_status);
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     l_num_warn := l_num_warn + 1;
                  ELSE
                     x_return_status := l_return_status;
                     --
                     -- Debug Statements
                     --
                     --IF l_debug_on THEN
                        --WSH_DEBUG_SV.pop(l_module_name);
                     --END IF;
                     --
                     --RETURN;
                     raise e_return_excp; -- LPN CONV. rv
                  END IF;
               END IF;

            END IF;

            -- J-IB-NPARIKH-{
            --
            --
            -- For an existing stop, calculate value of shipments type flag
            -- by calling WSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WWSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag
                (
                    p_trip_id               => p_trip_id,
                    p_stop_id               => l_dropoff_stop_id,
                    p_action                => 'ASSIGN',
                    p_shipment_direction    => l_shipment_direction,
                    x_shipments_type_flag   => l_stop_shipments_type_flag,
                    x_return_status         => l_return_status
                );
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warn,
                x_num_errors    => l_num_error
              );
            --
            -- J-IB-NPARIKH-}

            /* End of H integration - call Multi Leg FTE */
            update wsh_trip_stops
            set    shipments_type_flag = l_stop_shipments_type_flag  ,  -- J-IB-NPARIKH
                   last_update_date   = SYSDATE,
                   last_updated_by    = FND_GLOBAL.USER_ID,
                   last_update_login  = FND_GLOBAL.LOGIN_ID
            where stop_id=l_dropoff_stop_id;
         END IF;

      END IF;

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.CHK_DUP_PICKUP_DROPOFF_LOCNS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_delivery_validations.chk_dup_pickup_dropoff_locns
      (p_delivery_id => l_del_rows(i),
      p_pickup_location_id => l_pickup_location_id,
      p_dropoff_location_id => l_dropoff_location_id,
      x_return_status       => l_return_status);
      IF l_return_status IN (wsh_util_core.g_ret_sts_error, wsh_util_core.g_ret_sts_unexp_error) THEN
         l_num_error := l_num_error + 1;
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back to the begining of the loop',WSH_DEBUG_SV.C_PROC_LEVEL);
            WSH_DEBUG_SV.log(l_module_name,'l_num_error',l_num_error);
         END IF;
      --
         RAISE e_CommonExcep; -- Bug 5336308
      --
      END IF;
      --2709662
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_dropoff_stop_id', l_dropoff_stop_id);
         WSH_DEBUG_SV.log(l_module_name,'l_pickup_stop_id', l_pickup_stop_id);
      END IF;

      IF l_pregen_seq = 'N' THEN --{
       --
       -- SSN change
       -- The date validation is to be triggered only if profile is PAD
       -- The SSN validation is to be triggered otherwise.
       IF (l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_PAD) AND
         (l_pickup_stop_id IS NOT NULL) AND (l_dropoff_stop_id IS NOT NULL)
       THEN

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_pickup_arr_date', fnd_date.date_to_displaydt(l_pickup_arr_date));
            WSH_DEBUG_SV.log(l_module_name,'l_pickup_dep_date', fnd_date.date_to_displaydt(l_pickup_dep_date));
            WSH_DEBUG_SV.log(l_module_name,'l_dropoff_arr_date', fnd_date.date_to_displaydt (l_dropoff_arr_date));
            WSH_DEBUG_SV.log(l_module_name,'l_dropoff_dep_date', fnd_date.date_to_displaydt (l_dropoff_dep_date));
         END IF;
         -- bug 3516052
         -- bug 4036204: We relax the restriction so that p_pickup_dep_date = p_dropoff_arr_date
         -- as long as p_pickup_arr_date >= p_dropoff_arr_date
         IF (p_pickup_dep_date > p_dropoff_arr_date) OR
            ((p_pickup_dep_date = p_dropoff_arr_date) AND (p_pickup_arr_date >= p_dropoff_arr_date))
         THEN
            FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_PLANNED_DATE');
            FND_MESSAGE.SET_TOKEN('PICKUP_DATE', fnd_date.date_to_displaydt(l_pickup_dep_date));
            FND_MESSAGE.SET_TOKEN('DROPOFF_DATE', fnd_date.date_to_displaydt(l_dropoff_arr_date));
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
            l_num_error := l_num_error + 1;
            RAISE e_CommonExcep; -- Bug 5336308
         END IF;

      ELSIF (l_stop_seq_mode = WSH_INTERFACE_GRP.G_STOP_SEQ_MODE_SSN) AND
         (l_pickup_stop_id IS NOT NULL) AND (l_dropoff_stop_id IS NOT NULL) THEN

        -- check that pick up SSN is before drop off SSN.

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_pickup_stop_seq', l_pickup_stop_seq);
          WSH_DEBUG_SV.log(l_module_name,'l_dropoff_stop_seq', l_dropoff_stop_seq);
        END IF;

        IF l_pickup_stop_seq >= l_dropoff_stop_seq THEN
          FND_MESSAGE.Set_Name('WSH', 'WSH_PICKUP_STOP_SEQUENCE');
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
          l_num_error := l_num_error + 1;
          RAISE e_CommonExcep; -- Bug 5336308
        END IF;

       END IF; -- end of mode check and date/SSN validation
      END IF;

      -- If a delivery leg exists then only update is possible. If it does
      -- not exist create a new delivery leg

      IF (l_leg_id IS NOT NULL) THEN

         --TD: Check if delivery can be unassigned from old trip stops
         --TD: and assigned to new trip stops

         IF (l_pickup_stop_id IS NOT NULL) THEN

            update wsh_delivery_legs
            set pick_up_stop_id = l_pickup_stop_id
            where delivery_leg_id = l_leg_id;

            IF (SQL%NOTFOUND) THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_LEG_NOT_FOUND');
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               wsh_util_core.add_message(x_return_status);
               RAISE e_CommonExcep; -- Bug 5336308
            END IF;

  --
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id -',l_pickup_stop_id);
        END IF;
	l_stop_tab.delete;
	l_stop_tab(1) := l_pickup_stop_id;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          rollback to assign_del_to_trip;
	  -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            --WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --return;
          raise e_return_excp; -- LPN CONV. rv
        END IF;
        -- End of Code for DBI Project
 --


         END IF;

         IF (l_dropoff_stop_id IS NOT NULL) THEN

            update wsh_delivery_legs
            set drop_off_stop_id = l_dropoff_stop_id
            where delivery_leg_id = l_leg_id;

 	    IF (SQL%NOTFOUND) THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_LEG_NOT_FOUND');
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               wsh_util_core.add_message(x_return_status);
               RAISE e_CommonExcep; -- Bug 5336308
            END IF;

 --
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id -',l_dropoff_stop_id);
        END IF;
	l_stop_tab.delete;
	l_stop_tab(1) := l_dropoff_stop_id;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          rollback to assign_del_to_trip;
	  -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            --WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --return;
          raise e_return_excp; -- LPN CONV. rv
        END IF;
        -- End of Code for DBI Project
 --


         END IF;


      ELSE

         l_delivery_leg_info.delivery_id := l_del_rows(i);
         l_delivery_leg_info.pick_up_stop_id := l_pickup_stop_id;
         l_delivery_leg_info.drop_off_stop_id := l_dropoff_stop_id;


         OPEN max_leg_seq_number (l_del_rows(i));
         FETCH max_leg_seq_number INTO l_leg_seq_number;
         CLOSE max_leg_seq_number;

         IF (l_leg_seq_number IS NULL) THEN
            l_delivery_leg_info.sequence_number := 10;
         ELSE
            l_delivery_leg_info.sequence_number := l_leg_seq_number + 10;
         END IF;

         --     dbms_output.put_line('creating delivery leg....');

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_PVT.CREATE_DELIVERY_LEG',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         wsh_delivery_legs_pvt.create_delivery_leg(l_delivery_leg_info, l_rowid, l_leg_id, x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RAISE e_InvalidDelExcep; -- Bug 5336308
         END IF;

         -- J: W/V Changes
         WSH_WV_UTILS.Del_WV_Post_Process(
           p_delivery_id   => l_del_rows(i),
           p_diff_gross_wt => l_org_gross_wt,
           p_diff_net_wt   => l_org_net_wt,
           p_diff_volume   => l_org_vol,
           p_leg_id        => l_leg_id,
           x_return_status => l_return_status);

         IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           RAISE e_InvalidDelExcep; -- Bug 5336308
         END IF;

         --     dbms_output.put_line('created delivery leg#'||l_leg_id);

      END IF;

      x_leg_rows(x_leg_rows.count+1) := l_leg_id;

        -- J-IB-NPARIKH-{
        --
      IF p_pickup_stop_id IS NOT NULL
      THEN
      --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WWSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            --
            -- For an existing stop, calculate value of shipments type flag
            -- by calling WSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag
            --
            WSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag
                (
                    p_trip_id               => p_trip_id,
                    p_stop_id               => p_pickup_stop_id,
                    p_action                => 'ASSIGN',
                    p_shipment_direction    => l_shipment_direction,
                    x_shipments_type_flag   => l_pu_stop_shipments_type_flag,
                    x_return_status         => l_return_status
                );
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warn,
                x_num_errors    => l_num_error
              );

            IF p_pickup_location_id IS NOT NULL THEN
              update wsh_trip_stops
              set  planned_departure_date=p_pickup_dep_date,
                   planned_arrival_date=p_pickup_arr_date,
                   last_update_date   = SYSDATE,
                   last_updated_by    = FND_GLOBAL.USER_ID,
                   last_update_login  = FND_GLOBAL.LOGIN_ID
              where stop_id=p_pickup_stop_id;

--
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id -',p_pickup_stop_id);
        END IF;
	l_stop_tab.delete;
	l_stop_tab(1) := p_pickup_stop_id;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
           x_return_status      =>  l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          rollback to assign_del_to_trip;
	  -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||l_dbi_rs);
            --WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --return;
          raise e_return_excp; -- LPN CONV. rv
       END IF;
        -- End of Code for DBI Project
 --

            END IF;
       --}
       END IF;
        --
      IF p_dropoff_stop_id IS NOT NULL
      THEN
      --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WWSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            --
            -- For an existing stop, calculate value of shipments type flag
            -- by calling WSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag
            --
            WSH_TRIP_STOPS_VALIDATIONS.refreshShipmentsTypeFlag
                (
                    p_trip_id               => p_trip_id,
                    p_stop_id               => p_dropoff_stop_id,
                    p_action                => 'ASSIGN',
                    p_shipment_direction    => l_shipment_direction,
                    x_shipments_type_flag   => l_do_stop_shipments_type_flag,
                    x_return_status         => l_return_status
                );
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warn,
                x_num_errors    => l_num_error
              );
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_do_stop_shipments_type_flag',l_do_stop_shipments_type_flag);
            END IF;
            IF p_dropoff_location_id IS NOT NULL THEN
              update wsh_trip_stops
              set  planned_departure_date=p_dropoff_dep_date,
                   planned_arrival_date=p_dropoff_arr_date,
                   last_update_date   = SYSDATE,
                   last_updated_by    = FND_GLOBAL.USER_ID,
                   last_update_login  = FND_GLOBAL.LOGIN_ID
              where stop_id=p_dropoff_stop_id;

 --
        -- DBI Project
        -- Updating  WSH_TRIP_STOPS.
        -- Call DBI API after the Update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Stop id -',p_dropoff_stop_id);
        END IF;
	l_stop_tab.delete;
	l_stop_tab(1) := p_dropoff_stop_id;
        WSH_INTEGRATION.DBI_Update_Trip_Stop_Log
          (p_stop_id_tab	=> l_stop_tab,
           p_dml_type		=> 'UPDATE',
           x_return_status      => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          rollback to assign_del_to_trip;
	  -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            --WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --return;
          raise e_return_excp; -- LPN CONV. rv
       END IF;
        -- End of Code for DBI Project
 --

            END IF;
       --}
       END IF;
        --
        -- J-IB-NPARIKH-}


      -- Bug 3584924: Call WMS if this is the first leg of the delivery.

      IF NOT g_wms_installed.exists(l_org_id) THEN
        g_wms_installed(l_org_id) := wsh_util_validate.check_wms_org(l_org_id);
      END IF;

      IF g_wms_installed(l_org_id) = 'Y' THEN
         -- Check if it is the first leg of the delivery.
         l_dummy_leg_id := NULL;
         OPEN C_IS_FIRST_LEG(p_trip_id, l_del_rows(i), l_del_pu_location_id);
         FETCH C_IS_FIRST_LEG INTO l_dummy_leg_id;
         IF C_IS_FIRST_LEG%NOTFOUND THEN
            l_dummy_leg_id := NULL;
         END IF;
         CLOSE C_IS_FIRST_LEG;
         IF l_dummy_leg_id IS NOT NULL THEN
         -- Call wms to check if assignment is valid
            l_dlvy_trip_tbl(1).delivery_id := l_del_rows(i);
            l_dlvy_trip_tbl(1).trip_id := p_trip_id;
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_SHIPPING_INTERFACE_GRP.Process_Delivery_Trip',WSH_DEBUG_SV.C_PROC_LEVEL);
                WSH_DEBUG_SV.log(l_module_name,'trip_id',p_trip_id);
                WSH_DEBUG_SV.log(l_module_name,'del_id',l_del_rows(i));
            END IF;
            WMS_SHIPPING_INTERFACE_GRP.Process_Delivery_Trip(
                                       p_api_version        => 1.0,
                                       p_init_msg_list      => wms_shipping_interface_grp.g_false,
                                       p_commit             => wms_shipping_interface_grp.g_false,
                                       p_validation_level   => wms_shipping_interface_grp.g_full_validation,
                                       p_action             => wms_shipping_interface_grp.g_action_assign_dlvy_trip,
                                       p_dlvy_trip_tbl      => l_dlvy_trip_tbl,
                                       x_return_status      => l_return_status,
                                       x_msg_count          => l_msg_count,
                                       x_msg_data           => l_msg_data);

            IF l_dlvy_trip_tbl(1).r_message_type IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)
            OR l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR ) THEN
               FND_MESSAGE.SET_NAME(l_dlvy_trip_tbl(1).r_message_appl,l_dlvy_trip_tbl(1).r_message_code);
               IF l_dlvy_trip_tbl(1).r_message_token IS NOT NULL THEN
                  FND_MESSAGE.SET_TOKEN(l_dlvy_trip_tbl(1).r_message_token_name, l_dlvy_trip_tbl(1).r_message_token);
               END IF;
               WSH_UTIL_CORE.ADD_MESSAGE(l_dlvy_trip_tbl(1).r_message_type);
               RAISE e_InvalidDelExcep; -- Bug 5336308
            END IF;
         END IF;

      END IF;
      --
     EXCEPTION
      --
      -- Bug 5336308 : Added these exception handlers as replacement for GOTOs
      --
      WHEN e_InvalidDelExcep THEN
       --
       ROLLBACK TO ASSIGN_DEL_TO_TRIP;
       FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGN_ERROR');
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_del_rows(i)));
       -- Bug 3439165
       FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));
       wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
       l_num_error := l_num_error + 1;
       --
      WHEN e_CommonExcep THEN
       --
       ROLLBACK TO ASSIGN_DEL_TO_TRIP;
      --)
     END;
    --)
   END LOOP;

   IF p_caller like '%ASSIGNTRIP%' THEN
      l_trip_ids(1):=p_trip_id;
      WSH_TRIPS_ACTIONS.Handle_Internal_Stops
       ( p_trip_ids          => l_trip_ids,
        p_caller            => p_caller,
        x_success_trip_ids  => l_dummy_trip_ids,
        x_return_status     => l_return_status);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Handle_Internal_Stops l_return_status',l_return_status);
      END IF;

      wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warn,
                x_num_errors    => l_num_error
              );
   END IF;

   -- J-IB-NPARIKH-{
   --
   IF  p_pickup_stop_id IS NOT NULL
   AND l_pu_stop_shipments_type_flag <> l_pu_stop_shipType_flag_orig
   THEN
   --{
            -- If shipments type flag has changed due to assignment
            -- of delivery, update pickup stop with new value.
            --
            /* H integration - call Multi Leg FTE */
            IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
               -- Get pvt type record structure for stop
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.GET_STOP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               wsh_trip_stops_grp.get_stop_details_pvt
               (p_stop_id => p_pickup_stop_id,
               x_stop_rec => l_stop_rec,
               x_return_status => l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  x_return_status := l_return_status;
                  --
                  -- Debug Statements
                  --
                  --IF l_debug_on THEN
                     --WSH_DEBUG_SV.pop(l_module_name);
                  --END IF;
                  --
                  --RETURN;
                  raise e_return_excp; -- LPN CONV. rv
               END IF;

               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               wsh_fte_integration.trip_stop_validations
               (p_stop_rec => l_stop_rec,
               p_trip_rec => l_trip_rec,
               p_action => 'UPDATE',
               x_return_status => l_return_status);
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     l_num_warn := l_num_warn + 1;
                  ELSE
                     x_return_status := l_return_status;
                     --
                     -- Debug Statements
                     --
                     --IF l_debug_on THEN
                        --WSH_DEBUG_SV.pop(l_module_name);
                     --END IF;
                     --
                     --RETURN;
                     raise e_return_excp; -- LPN CONV. rv
                  END IF;
               END IF;

            END IF;


            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_pu_stop_shipments_type_flag',l_pu_stop_shipments_type_flag);
                WSH_DEBUG_SV.log(l_module_name,'l_pu_stop_shipType_flag_orig',l_pu_stop_shipType_flag_orig);
            END IF;
            --
            -- J-IB-NPARIKH-}

            /* End of H integration - call Multi Leg FTE */
            update wsh_trip_stops
            set    shipments_type_flag = l_pu_stop_shipments_type_flag,    -- J-IB-NPARIKH
                   last_update_date   = SYSDATE,
                   last_updated_by    = FND_GLOBAL.USER_ID,
                   last_update_login  = FND_GLOBAL.LOGIN_ID
            where stop_id=l_pickup_stop_id;
   --}
   END IF;
   --
   --
   IF  p_dropoff_stop_id IS NOT NULL
   AND l_do_stop_shipments_type_flag <> l_do_stop_shipType_flag_orig
   THEN
   --{
            -- If shipments type flag has changed due to assignment
            -- of delivery, update dropoff stop with new value.
            --
            /* H integration - call Multi Leg FTE */
            IF (WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y') THEN
               -- Get pvt type record structure for stop
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_GRP.GET_STOP_DETAILS_PVT',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               wsh_trip_stops_grp.get_stop_details_pvt
               (p_stop_id => p_dropoff_stop_id,
               x_stop_rec => l_stop_rec,
               x_return_status => l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  x_return_status := l_return_status;
                  --
                  -- Debug Statements
                  --
                  --IF l_debug_on THEN
                     --WSH_DEBUG_SV.pop(l_module_name);
                  --END IF;
                  --
                  --RETURN;
                  raise e_return_excp; -- LPN CONV. rv
               END IF;

               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_INTEGRATION.TRIP_STOP_VALIDATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
               wsh_fte_integration.trip_stop_validations
               (p_stop_rec => l_stop_rec,
               p_trip_rec => l_trip_rec,
               p_action => 'UPDATE',
               x_return_status => l_return_status);
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                     l_num_warn := l_num_warn + 1;
                  ELSE
                     x_return_status := l_return_status;
                     --
                     -- Debug Statements
                     --
                     --IF l_debug_on THEN
                        --WSH_DEBUG_SV.pop(l_module_name);
                     --END IF;
                     --
                     --RETURN;
                     raise e_return_excp; -- LPN CONV. rv
                  END IF;
               END IF;

            END IF;


            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_do_stop_shipments_type_flag',l_do_stop_shipments_type_flag);
                WSH_DEBUG_SV.log(l_module_name,'l_do_stop_shipType_flag_orig',l_do_stop_shipType_flag_orig);
            END IF;
            --

            /* End of H integration - call Multi Leg FTE */
            update wsh_trip_stops
            set    shipments_type_flag = l_do_stop_shipments_type_flag,    -- J-IB-NPARIKH
                   last_update_date   = SYSDATE,
                   last_updated_by    = FND_GLOBAL.USER_ID,
                   last_update_login  = FND_GLOBAL.LOGIN_ID
            where stop_id=l_dropoff_stop_id;
   --}
   END IF;
   --
   --
   --
   -- J-IB-NPARIKH-{
   --
   -- Determine new value of shipments type flag for the trip
   -- as a result of assignment operation
   --
   IF l_trip_shipments_type_flag IN ('I','O')
   THEN
   --{
        --
        -- If trip already has mixed deliveries, no further updates are required.
        -- Hence, this code is restricted only to trip shipments type flag I/O
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.has_mixed_deliveries',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        l_has_mixed_deliveries := WSH_TRIP_VALIDATIONS.has_mixed_deliveries
                                    (
                                      p_trip_id => p_trip_id
                                    );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_has_mixed_deliveries',l_has_mixed_deliveries);
        END IF;
        --
        --
        IF l_has_mixed_deliveries = 'Y'
        THEN
            l_trip_shipments_type_flag_new := 'M';
        ELSIF l_has_mixed_deliveries = 'NI'
        THEN
            l_trip_shipments_type_flag_new := 'I';
        ELSIF l_has_mixed_deliveries = 'NO'
        THEN
            l_trip_shipments_type_flag_new := 'O';
        ELSE
            l_trip_shipments_type_flag_new := l_trip_shipments_type_flag;
        END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_trip_shipments_type_flag',l_trip_shipments_type_flag);
            WSH_DEBUG_SV.log(l_module_name,'l_trip_shipments_type_flag_new',l_trip_shipments_type_flag_new);
        END IF;
        --
        --
        --
        --IF l_has_mixed_deliveries = 'Y'
        IF  l_trip_shipments_type_flag_new <>  l_trip_shipments_type_flag
        THEN
            UPDATE WSH_TRIPS
            SET    shipments_type_flag = l_trip_shipments_type_flag_new, -- 'M',
                   last_update_date   = SYSDATE,
                   last_updated_by    = FND_GLOBAL.USER_ID,
                   last_update_login  = FND_GLOBAL.LOGIN_ID
            WHERE  trip_id             = p_trip_id;

            IF (l_trip_shipments_type_flag_new <> 'M') THEN

              UPDATE WSH_TRIP_STOPS
              SET    shipments_type_flag = l_trip_shipments_type_flag_new,
                     last_update_date   = SYSDATE,
                     last_updated_by    = FND_GLOBAL.USER_ID,
                     last_update_login  = FND_GLOBAL.LOGIN_ID
              WHERE  trip_id             = p_trip_id
              and    shipments_type_flag <> l_trip_shipments_type_flag_new;

              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT After updating wts',SQL%ROWCOUNT);
              END IF;

            END IF;
        END IF;
   --}
   END IF;
   --
   --
   -- J-IB-NPARIKH-}


   Mark_Reprice_Required(
   p_entity_type => 'DELIVERY_LEG',
   p_entity_ids  => x_leg_rows,
   x_return_status => l_return_status);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
   END IF;

   IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      raise mark_reprice_error;
   ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_num_warn  := l_num_warn + 1;
   END IF;

   --
   --

   --J-IB-HEALI {
   FOR i IN 1..p_del_rows.count LOOP
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'delivery_id',p_del_rows(i));
      END IF;

      WSH_NEW_DELIVERY_ACTIONS.Process_Leg_Sequence
      ( p_delivery_id        => p_del_rows(i),
        p_update_del_flag    => 'Y',
        p_update_leg_flag    => 'N',
        x_leg_complete       => l_leg_complete,
        x_return_status      => l_return_status);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Process_Leg_Sequence l_return_status',l_return_status);
      END IF;

      wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warn,
                x_num_errors    => l_num_error
              );
   END LOOP;
   --J-IB-HEALI }

  --
  -- K LPN CONV. rv
  --
  IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
  THEN
  --{
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
        (
          p_in_rec             => l_lpn_in_sync_comm_rec,
          x_return_status      => l_return_status,
          x_out_rec            => l_lpn_out_sync_comm_rec
        );
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
      END IF;
      --
      --
      WSH_UTIL_CORE.API_POST_CALL
        (
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warn,
          x_num_errors       => l_num_error,
          p_raise_error_flag => false
        );
  --}
  END IF;
  --
  -- K LPN CONV. rv
  --
   IF (l_num_error > 0) THEN
      IF (p_del_rows.count > 1) THEN

         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGN_SUMMARY');
         FND_MESSAGE.SET_TOKEN('NUM_ERROR',l_num_error);
         FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',p_del_rows.count-l_num_error);
         FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));

         IF (l_num_error = p_del_rows.count) THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         ELSE
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
         END IF;

         wsh_util_core.add_message(x_return_status);
      ELSE
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END IF;

   ELSE
      /* H integration more changes */
      IF l_num_warn > 0 THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      ELSE
         x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;
   END IF;



   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'X_LEG_ROWS.COUNT'||x_leg_rows.count);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
    WHEN e_return_excp THEN

          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR) and x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_RETURN_EXCP');
          END IF;
          --
    -- J-IB-NPARIKH-{
      --
    WHEN FND_API.G_EXC_ERROR THEN
      IF c_is_first_leg%isopen THEN
         close c_is_first_leg;
      END IF;
      IF c_get_seq_numbers%ISOPEN THEN
         close c_get_seq_numbers;
      END IF;
      IF c_get_prev_seq_wv%ISOPEN THEN
         close c_get_prev_seq_wv;
      END IF;
      IF c_next_seq_exists%ISOPEN THEN
         close c_next_seq_exists;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF c_is_first_leg%isopen THEN
         close c_is_first_leg;
      END IF;
      IF c_get_seq_numbers%ISOPEN THEN
         close c_get_seq_numbers;
      END IF;
      IF c_get_prev_seq_wv%ISOPEN THEN
         close c_get_prev_seq_wv;
      END IF;
      IF c_next_seq_exists%ISOPEN THEN
         close c_next_seq_exists;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      END IF;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
      -- J-IB-NPARIKH-}
   WHEN mark_reprice_error THEN
      IF c_is_first_leg%isopen THEN
         close c_is_first_leg;
      END IF;
      IF c_get_seq_numbers%ISOPEN THEN
         close c_get_seq_numbers;
      END IF;
      IF c_get_prev_seq_wv%ISOPEN THEN
         close c_get_prev_seq_wv;
      END IF;
      IF c_next_seq_exists%ISOPEN THEN
         close c_next_seq_exists;
      END IF;
      FND_MESSAGE.SET_NAME('WSH', 'WSH_REPRICE_REQUIRED_ERR');
      WSH_UTIL_CORE.add_message(l_return_status);
      x_return_status := l_return_status;
      --
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
      END IF;
      --
   WHEN Invalid_Trip THEN
   IF c_is_first_leg%isopen THEN
      close c_is_first_leg;
   END IF;
      IF c_get_seq_numbers%ISOPEN THEN
         close c_get_seq_numbers;
      END IF;
      IF c_get_prev_seq_wv%ISOPEN THEN
         close c_get_prev_seq_wv;
      END IF;
      IF c_next_seq_exists%ISOPEN THEN
         close c_next_seq_exists;
      END IF;
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_TRIP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_TRIP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_TRIP');
      END IF;
      --
   WHEN bad_trip_stop THEN
   IF c_is_first_leg%isopen THEN
      close c_is_first_leg;
   END IF;
      IF c_get_seq_numbers%ISOPEN THEN
         close c_get_seq_numbers;
      END IF;
      IF c_get_prev_seq_wv%ISOPEN THEN
         close c_get_prev_seq_wv;
      END IF;
      IF c_next_seq_exists%ISOPEN THEN
         close c_next_seq_exists;
      END IF;
      FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      --
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'BAD_TRIP_STOP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:BAD_TRIP_STOP');
      END IF;
      --
  WHEN rate_trip_contents_fail THEN
   IF c_is_first_leg%isopen THEN
      close c_is_first_leg;
   END IF;
      IF c_get_seq_numbers%ISOPEN THEN
         close c_get_seq_numbers;
      END IF;
      IF c_get_prev_seq_wv%ISOPEN THEN
         close c_get_prev_seq_wv;
      END IF;
      IF c_next_seq_exists%ISOPEN THEN
         close c_next_seq_exists;
      END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('WSH', 'WSH_RATE_TRIP_CONTENTS_FAIL');
        WSH_UTIL_CORE.Add_Message(x_return_status);
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'rate_trip_contents_fail exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:rate_trip_contents_fail');
        END IF;

   WHEN e_lock_error THEN
      IF get_stop_new%ISOPEN THEN
         close get_stop_new;
      ELSIF get_stop%ISOPEN THEN
         close get_stop;
      END IF;
      IF get_trip_status%ISOPEN THEN
         close get_trip_status;
      ELSIF stop_exists%ISOPEN THEN
         close stop_exists;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

      FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
      wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'e_lock_error' ,WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_LOCK_ERROR');
      END IF;
      --
   WHEN others THEN
      IF get_trip_status%ISOPEN THEN
         close get_trip_status;
      ELSIF stop_exists%ISOPEN THEN
         close stop_exists;
      END IF;
      IF c_is_first_leg%isopen THEN
         close c_is_first_leg;
      END IF;
      IF c_get_seq_numbers%ISOPEN THEN
         close c_get_seq_numbers;
      END IF;
      IF c_get_prev_seq_wv%ISOPEN THEN
         close c_get_prev_seq_wv;
      END IF;
      IF c_next_seq_exists%ISOPEN THEN
         close c_next_seq_exists;
      END IF;
      wsh_util_core.default_handler('WSH_DELIVERY_LEGS_ACTIONS.ASSIGN_DELIVERIES');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      END IF;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Assign_Deliveries;


PROCEDURE Unassign_Deliveries
    (p_del_rows      IN   wsh_util_core.id_tab_type,
     p_trip_id      IN   NUMBER := NULL,
     p_pickup_stop_id    IN   NUMBER := NULL,
     p_dropoff_stop_id     IN   NUMBER := NULL,
     x_return_status    OUT NOCOPY VARCHAR2
     ) IS

-- Note: dont merge next two cursors due to full table scan problem

CURSOR del_pickup_exists(p_del_id IN NUMBER) IS
SELECT   delivery_leg_id
FROM    wsh_delivery_legs
WHERE pick_up_stop_id = p_pickup_stop_id
FOR UPDATE NOWAIT;

CURSOR del_dropoff_exists(p_del_id IN NUMBER) IS
SELECT   delivery_leg_id
FROM    wsh_delivery_legs
WHERE drop_off_stop_id = p_dropoff_stop_id
FOR UPDATE NOWAIT;

CURSOR del_trip_exists( p_del_id IN NUMBER) IS
SELECT   dg.delivery_leg_id, st1.stop_location_id
FROM    wsh_trip_stops st1,
    wsh_trip_stops st2,
    wsh_delivery_legs dg
WHERE st1.stop_id = dg.pick_up_stop_id AND
    st2.stop_id = dg.drop_off_stop_id AND
    st1.trip_id = p_trip_id AND
    st2.trip_id = p_trip_id AND
    dg.delivery_id = p_del_id
FOR UPDATE NOWAIT;

cursor get_del_status(c_del_id IN NUMBER) is
select status_code,
       nvl(shipment_direction,'O') shipment_direction
from wsh_new_deliveries
where delivery_id = c_del_id;

-- KLR
/*
cursor get_del_status(c_del_id IN NUMBER) is
select status_code,
       nvl(shipment_direction,'O') shipment_direction
from wsh_new_deliveries
where delivery_id = c_del_id;
*/
cursor get_del_info(c_del_id IN NUMBER) is
select status_code,
       nvl(shipment_direction,'O') shipment_direction,
       gross_weight,
       net_weight,
       volume, initial_pickup_location_id,
       organization_id
from wsh_new_deliveries
where delivery_id = c_del_id;

-- Bug 3875780
  CURSOR c_trip_stops(p_trip_id IN NUMBER) IS
  SELECT stop_id
  FROM   wsh_trip_stops
  WHERE  trip_id = p_trip_id;


  CURSOR c_trip_empty IS
  SELECT count(*)
  FROM wsh_trip_stops a,wsh_delivery_legs b
  WHERE a.stop_id = b.pick_up_stop_id
  AND   a.trip_id = p_trip_id
  AND   rownum = 1 ;

 l_cnt number;
 l_trip_empty BOOLEAN;
 --

l_del_for_update_load_seq VARCHAR2(1); -- bug 6700792:OTM Dock Door App Sched Proj

l_del_status VARCHAR2(2);
l_gross_wt number;
l_net_wt number;
l_vol number;
l_del_pu_location_id NUMBER;
l_stop_pu_location_id NUMBER;
l_org_id NUMBER;
l_dummy_leg_id NUMBER;
l_dlvy_trip_tbl WMS_SHIPPING_INTERFACE_GRP.g_dlvy_trip_tbl;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
i            NUMBER;
l_del_leg_id         NUMBER;
l_return_status      VARCHAR2(1);
l_ret_status      VARCHAR2(1);
l_num_error       NUMBER := 0;
l_num_warning       NUMBER := 0;

cannot_unassign       EXCEPTION;
lock_error         EXCEPTION;
pragma EXCEPTION_INIT(lock_error,-54);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UNASSIGN_DELIVERIES';
--
--
l_shipment_direction        VARCHAR2(30);
l_shipping_control     VARCHAR2(30);
l_routing_response_id  NUMBER;
l_routing_request_flag VARCHAR2(30);
-- K LPN CONV. rv
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
e_return_excp EXCEPTION;
-- K LPN CONV. rv
BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_STOP_ID',P_PICKUP_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_STOP_ID',P_DROPOFF_STOP_ID);
  END IF;
  --
  IF (p_trip_id IS NULL) AND (p_pickup_stop_id IS NULL) AND
   (p_dropoff_stop_id IS NULL) THEN
  RAISE cannot_unassign;
  END IF;

  FOR i IN 1..p_del_rows.count LOOP

  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_del_leg_id := NULL;

  -- bug 6700792: OTM Dock Door App Sched Proj
  -- l_del_for_update_load_seq will verrify whether the delivery was assigned to a planned trip from OTM.
  l_del_for_update_load_seq := 'N';

  --Bug 6884545 Start
  --Handling No data found
  BEGIN

  SELECT 'Y'
  INTO   l_del_for_update_load_seq
  FROM   wsh_delivery_legs wdl,
         wsh_trip_stops wts,
         wsh_trips wt
  WHERE  wdl.delivery_id = p_del_rows(i)
  AND    wdl.drop_off_stop_id = wts.stop_id
  AND    wts.trip_id = wt.trip_id
  AND    wt.ignore_for_planning = 'N'
  AND    rownum = 1; --Bug 6884545

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  l_del_for_update_load_seq := 'N';

  END; --Bug 6884545 End

-- J: W/V Changes
  open get_del_info(p_del_rows(i));
  fetch get_del_info into l_del_status, l_shipment_direction, l_gross_wt, l_net_wt, l_vol, l_del_pu_location_id, l_org_id;
  close get_del_info;

  --IF l_del_status in ('CL', 'CA', 'SR', 'SC') THEN  -- sperera 940/945
-- Bug 2307456, allow this action for status of SR and SC

      -- Check if the delivery is in a valid status.
      IF l_del_status IN ( 'CA') THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_UNASSIGN_ERROR');
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(l_return_status);
      END IF;
     --

     IF l_del_status = 'CL'
     THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_DEL_UNASSIGN_ERROR');
                l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                wsh_util_core.add_message(l_return_status);
     END IF;
     --

  l_stop_pu_location_id := NULL;

  IF (p_pickup_stop_id IS NOT NULL) THEN

    OPEN  del_pickup_exists(p_del_rows(i));
    FETCH del_pickup_exists INTO l_del_leg_id;
    CLOSE del_pickup_exists;

    IF (l_del_leg_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
      l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.add_message(l_return_status);
    END IF;

  ELSIF (p_dropoff_stop_id IS NOT NULL) THEN

    OPEN del_dropoff_exists(p_del_rows(i));
    FETCH del_dropoff_exists INTO l_del_leg_id;
    CLOSE del_dropoff_exists;

    IF (l_del_leg_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_FOUND');
    l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(l_return_status);
    END IF;

  ELSIF (p_trip_id IS NOT NULL) THEN
    OPEN del_trip_exists(p_del_rows(i));
    FETCH del_trip_exists INTO l_del_leg_id, l_stop_pu_location_id;
    CLOSE del_trip_exists;

    IF (l_del_leg_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_FOUND');
    l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(l_return_status);
    END IF;

  END IF;

  -- Bug 3584924
  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      IF NOT g_wms_installed.exists(l_org_id) THEN
        g_wms_installed(l_org_id) := wsh_util_validate.check_wms_org(l_org_id);
      END IF;

      IF g_wms_installed(l_org_id) = 'Y' THEN
         -- Check if it is the first leg of the delivery.
         l_dummy_leg_id := NULL;
         IF l_stop_pu_location_id IS NOT NULL THEN
            IF l_stop_pu_location_id = l_del_pu_location_id THEN
               l_dummy_leg_id := l_del_leg_id;
            END IF;
         ELSE
            OPEN C_IS_FIRST_LEG(p_trip_id, p_del_rows(i), l_del_pu_location_id);
            FETCH C_IS_FIRST_LEG INTO l_dummy_leg_id;
            IF C_IS_FIRST_LEG%NOTFOUND THEN
               l_dummy_leg_id := NULL;
            END IF;
            CLOSE C_IS_FIRST_LEG;
         END IF;
         IF l_dummy_leg_id IS NOT NULL THEN
         -- Call wms to check if unassignment is valid
            l_dlvy_trip_tbl(1).delivery_id := p_del_rows(i);
            l_dlvy_trip_tbl(1).trip_id := p_trip_id;
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_SHIPPING_INTERFACE_GRP.Process_Delivery_Trip',WSH_DEBUG_SV.C_PROC_LEVEL);
                WSH_DEBUG_SV.log(l_module_name,'trip_id',p_trip_id);
                WSH_DEBUG_SV.log(l_module_name,'del_id',p_del_rows(i));
            END IF;
            WMS_SHIPPING_INTERFACE_GRP.Process_Delivery_Trip(
                                       p_api_version        => 1.0,
                                       p_init_msg_list      => wms_shipping_interface_grp.g_false,
                                       p_commit             => wms_shipping_interface_grp.g_false,
                                       p_validation_level   => wms_shipping_interface_grp.g_full_validation,
                                       p_action             => wms_shipping_interface_grp.g_action_unassign_dlvy_trip,
                                       p_dlvy_trip_tbl      => l_dlvy_trip_tbl,
                                       x_return_status      => l_return_status,
                                       x_msg_count          => l_msg_count,
                                       x_msg_data           => l_msg_data);
            IF l_dlvy_trip_tbl(1).r_message_type IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)
            OR l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR ) THEN
               FND_MESSAGE.SET_NAME(l_dlvy_trip_tbl(1).r_message_appl,l_dlvy_trip_tbl(1).r_message_code);
               IF l_dlvy_trip_tbl(1).r_message_token IS NOT NULL THEN
                  FND_MESSAGE.SET_TOKEN(l_dlvy_trip_tbl(1).r_message_token_name, l_dlvy_trip_tbl(1).r_message_token);
               END IF;
               WSH_UTIL_CORE.ADD_MESSAGE(l_dlvy_trip_tbl(1).r_message_type);
               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               l_num_error := l_num_error + 1;
            END IF;
         END IF;

      END IF;
  END IF;
  -- J: W/V Changes
  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Del_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    WSH_WV_UTILS.Del_WV_Post_Process(
      p_delivery_id     => p_del_rows(i),
      p_diff_gross_wt   => -1 * l_gross_wt,
      p_diff_net_wt     => -1 * l_net_wt,
      p_diff_volume     => -1 * l_vol,
      p_check_for_empty => 'Y',
      p_leg_id          => l_del_leg_id,
      x_return_status   => l_return_status);
  END IF;

  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
    l_num_warning := l_num_warning + 1;
    ELSE
    l_num_error := l_num_error + 1;
    END IF;
  END IF;


  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_PVT.DELETE_DELIVERY_LEG',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_delivery_legs_pvt.delete_delivery_leg(NULL,
                        l_del_leg_id, l_return_status);

  END IF;

  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
    l_num_warning := l_num_warning + 1;
    ELSE
    l_num_error := l_num_error + 1;
    END IF;
  END IF;

  -- bug 6700792: OTM Dock Door Appt Sched Proj
  -- NULL out the Load Sequencing Number for WMS enabled OTM org while unassigning delivery from trip.
  IF (l_del_for_update_load_seq = 'Y' AND g_wms_installed(l_org_id) = 'Y') THEN

    DECLARE

    CURSOR c_lock_delivery_details (c_delivery_id IN number) IS
    SELECT wdd.delivery_detail_id
    FROM   wsh_delivery_assignments wda,
           wsh_delivery_details wdd
    WHERE  wda.delivery_id = c_delivery_id
    AND    wda.delivery_detail_id = wdd.delivery_detail_id
    FOR UPDATE OF wdd.load_seq_number NOWAIT;

    l_del_det_tab WSH_UTIL_CORE.ID_TAB_TYPE;

    BEGIN

      l_del_det_tab.DELETE;

      OPEN  c_lock_delivery_details (p_del_rows(i));
      FETCH c_lock_delivery_details BULK COLLECT INTO l_del_det_tab;
      IF l_del_det_tab.COUNT > 0 THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Updating Deliveries and Details With Loading Sequence as NULL');
        END IF;

        UPDATE wsh_new_deliveries
        SET    loading_sequence   = NULL,
               last_update_date   = SYSDATE,
               last_updated_by    = FND_GLOBAL.USER_ID,
               last_update_login  = FND_GLOBAL.LOGIN_ID
        WHERE  delivery_id = p_del_rows(i);

        FORALL i in l_del_det_tab.FIRST..l_del_det_tab.LAST
          UPDATE  wsh_delivery_details
          SET     load_seq_number    = NULL,
                  last_update_date   = SYSDATE,
                  last_updated_by    = FND_GLOBAL.USER_ID,
                  last_update_login  = FND_GLOBAL.LOGIN_ID
          WHERE   delivery_detail_id = l_del_det_tab(i);

      END IF;

      CLOSE c_lock_delivery_details;

    EXCEPTION
      WHEN OTHERS THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF c_lock_delivery_details%ISOPEN then
          CLOSE c_lock_delivery_details;
        END IF;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Unable to lock Deliveries/Details for delivery '||p_del_rows(i));
          WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
        END IF;
        RAISE cannot_unassign;
    END;
  END IF;
  --

  END LOOP;

  -- bug 3875780
   IF WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y' THEN
        l_trip_empty := FALSE;
	OPEN c_trip_empty ;
	FETCH c_trip_empty into l_cnt;
	CLOSE c_trip_empty;

	IF l_cnt = 0 THEN
	   l_trip_empty := TRUE;
	END IF;
	IF l_trip_empty THEN

           FOR rec IN c_trip_stops(p_trip_id) LOOP
	  	WSH_TRIPS_ACTIONS.Fte_Load_Tender(
		  p_stop_id       => rec.stop_id,
		  p_gross_weight  => null,
		  p_net_weight    => null,
		  p_volume        => null,
		  p_fill_percent  => null,
		  x_return_status => l_return_status);

		IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
		  x_return_status := l_return_status;
		  --RETURN;
                  raise e_return_excp; -- LPN CONV. rv
                ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  -- we need to return warning if FTE gives warning here.
                  l_num_warning := l_num_warning + 1;
		END IF;
           END LOOP;

        END IF;
   END IF;
  --
  -- K LPN CONV. rv
  --
  IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
  THEN
  --{
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
        (
          p_in_rec             => l_lpn_in_sync_comm_rec,
          x_return_status      => l_return_status,
          x_out_rec            => l_lpn_out_sync_comm_rec
        );
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
      END IF;
      --
      --
      WSH_UTIL_CORE.API_POST_CALL
        (
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warning,
          x_num_errors       => l_num_error,
          p_raise_error_flag => false
        );
  --}
  END IF;
  --
  -- K LPN CONV. rv
  --

  IF (l_num_error >= p_del_rows.count) THEN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF (l_num_warning > 0 OR l_num_error >0)THEN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSE
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
    WHEN e_return_excp THEN

          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR) and x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_RETURN_EXCP');
          END IF;
          --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      END IF;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      --
      IF c_is_first_leg%isopen THEN
          close c_is_first_leg;
      END IF;
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --

   WHEN lock_error THEN
   IF c_is_first_leg%isopen THEN
      close c_is_first_leg;
   END IF;
   FND_MESSAGE.SET_NAME('FND','FORM_UNABLE_TO_RESERVE_RECORD');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   wsh_util_core.add_message(x_return_status);
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'LOCK_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:LOCK_ERROR');
   END IF;
   --
  WHEN cannot_unassign THEN
    IF c_is_first_leg%isopen THEN
       close c_is_first_leg;
    END IF;
    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_UNASSIGN_ERROR');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   wsh_util_core.add_message(x_return_status);
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'CANNOT_UNASSIGN exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CANNOT_UNASSIGN');
   END IF;
   --
  WHEN others THEN
  iF c_is_first_leg%isopen THEN
     close c_is_first_leg;
  END IF;
  wsh_util_core.default_handler('WSH_DELIVERY_LEGS_ACTIONS.UNASSIGN_DELIVERIES');
  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
END IF;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Unassign_Deliveries;


/*  H integration: Pricing integration csun
*/
--
-- Name        Mark_Reprice_Required
-- Purpose     This Procedure will set REPRICE_REQUIRED of
--             delivery leg record
--
-- Input Arguments
--       p_entity_type: entity type, valid values are
--                     'DELIVERY_DETAIL', 'DELIVERY', 'TRIP',
--                     'DELIVERY_LEG'
--       p_entity_id : the entity id of the entity type
--
--TL Rating adding 'STOP' for call from create,update, delete stop
--when trip mode is 'TRUCK'

PROCEDURE Mark_Reprice_Required(
     p_entity_type           IN  VARCHAR2,
     p_entity_ids            IN  WSH_UTIL_CORE.id_tab_type,
     p_consolidation_change  IN  VARCHAR2 DEFAULT 'N',
     x_return_status         OUT NOCOPY VARCHAR2) IS

  cursor get_trip_from_det( c_delivery_detail_id NUMBER) is
    SELECT dlg.delivery_leg_id, trip.trip_id, trip.consolidation_allowed,
           trip.lane_id, trip.mode_of_transport
    FROM   wsh_delivery_legs dlg,
           wsh_delivery_assignments_v da,
           wsh_trips trip,
           wsh_trip_stops st
    WHERE  da.delivery_detail_id = c_delivery_detail_id AND
           da.delivery_id = dlg.delivery_id AND
           dlg.pick_up_stop_id = st.stop_id AND
           st.trip_id = trip.trip_id;

cursor get_trip_from_del( c_delivery_id NUMBER) is
  SELECT dlg.delivery_leg_id, trip.trip_id, trip.consolidation_allowed,
         trip.lane_id, trip.mode_of_transport
  FROM   wsh_delivery_legs dlg,
         wsh_trip_stops stop,
         wsh_trips  trip
  WHERE  dlg.delivery_id = c_delivery_id and
         dlg.pick_up_stop_id = stop.stop_id and
         stop.trip_id = trip.trip_id;

cursor get_trip_from_leg( c_leg_id NUMBER) is
  SELECT dlg.delivery_leg_id, trip.trip_id, trip.consolidation_allowed,
         trip.lane_id, trip.mode_of_transport
  FROM   wsh_delivery_legs   dlg,
         wsh_trip_stops      stop,
         wsh_trips           trip
  WHERE  dlg.delivery_leg_id = c_leg_id AND
         dlg.pick_up_stop_id = stop.stop_id AND
         stop.trip_id = trip.trip_id;

--gets all legs for the trip the stop belongs to
cursor get_trip_from_stop(c_stop_id NUMBER) is
 SELECT dlg.delivery_leg_id, trip.trip_id, trip.consolidation_allowed,
        trip.lane_id, trip.mode_of_transport
 FROM   wsh_trip_stops stop,
        wsh_trips      trip,
        wsh_delivery_legs dlg,
        wsh_trip_stops ts
 WHERE  stop.stop_id = c_stop_id AND
        stop.trip_id = trip.trip_id AND
        ts.trip_id=trip.trip_id AND
        dlg.pick_up_stop_id = ts.stop_id;

cursor get_legs_from_trip( c_trip_id NUMBER) is
 SELECT dlg.delivery_leg_id, trip.trip_id, trip.consolidation_allowed,
        trip.lane_id, trip.mode_of_transport
 FROM   wsh_trip_stops ts,
        wsh_delivery_legs dlg,
        wsh_trips trip
 WHERE  ts.trip_id = c_trip_id AND
        dlg.pick_up_stop_id = ts.stop_id AND
        ts.trip_id = trip.trip_id;

cursor legs_priced_cur( c_trip_id NUMBER) is
 select 1
 from   wsh_freight_costs wfc,
        wsh_trip_stops    wts,
        wsh_delivery_legs wdl
 where  wts.trip_id         = c_trip_id
 and    wdl.pick_up_stop_id = wts.stop_id
 and    wfc.delivery_leg_id = wdl.delivery_leg_id
 and    wfc.line_type_code  = 'SUMMARY'
 and    wfc.delivery_detail_id is null
 and    NVL(wfc.total_amount,0) > 0;


cursor leg_price_cur( c_dleg_id NUMBER) is
 select NVL(wfc.total_amount,0) price
 from   wsh_freight_costs wfc
 where  wfc.delivery_leg_id = c_dleg_id
 and    wfc.line_type_code  = 'SUMMARY'
 and    wfc.delivery_detail_id is null
 and    NVL(wfc.total_amount,0) > 0;

cursor c_lock_delivery_leg(c_delivery_leg_id NUMBER) is
 SELECT delivery_leg_id, status_code, reprice_required, parent_delivery_leg_id
 FROM wsh_delivery_legs
 WHERE delivery_leg_id = c_delivery_leg_id FOR UPDATE OF reprice_required NOWAIT;

-- Bug 4451383
cursor get_trip_details ( c_trip_id NUMBER) is
 SELECT mode_of_transport, lane_id
 --SELECT consolidation_allowed, lane_id
 FROM wsh_trips
 WHERE trip_id = c_trip_id;

l_lock_delivery_leg_rec    c_lock_delivery_leg%ROWTYPE;

l_del_leg_tab      WSH_UTIL_CORE.Id_Tab_Type;

l_final_leg_tab        WSH_UTIL_CORE.Id_Tab_Type;
l_parent_leg_tab        WSH_UTIL_CORE.Id_Tab_Type;

j NUMBER := 0;
k NUMBER := 0;

l_duplicate  NUMBER := 0;

invalid_parameter EXCEPTION;

l_at_least_one_leg_priced BOOLEAN;
l_price NUMBER := 0;

-- Bug 4451383
l_consolidation_allowed wsh_trips.consolidation_allowed%type;
l_mode_of_transport wsh_trips.mode_of_transport%type;
l_lane_id wsh_trips.lane_id%type;

delivery_leg_locked exception  ;
-- PRAGMA EXCEPTION_INIT(delivery_leg_locked, -54);

 --for mode=TRUCK
 C_TRUCK VARCHAR2(5):='TRUCK';

 --
l_debug_on BOOLEAN;
 --
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MARK_REPRICE_REQUIRED';
 --
  BEGIN
    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',P_ENTITY_TYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_CONSOLIDATION_CHANGE',P_CONSOLIDATION_CHANGE);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --bug 3413328 - consolidation_allowed flag has been removed now from UI
    --removed checking for consolidation_allowed

    IF  WSH_UTIL_CORE.FTE_Is_Installed = 'Y'  AND p_entity_ids.count > 0 THEN
      l_del_leg_tab.delete;
      l_final_leg_tab.delete;

      IF p_entity_type = 'DELIVERY_DETAIL' THEN
        FOR i IN  1 .. p_entity_ids.count LOOP
          FOR l_leg IN get_trip_from_det(p_entity_ids(i)) LOOP
            l_at_least_one_leg_priced := FALSE;
            l_price := 0;
            --
            FOR leg_price_rec IN leg_price_cur(l_leg.delivery_leg_id) LOOP
              l_price := l_price+leg_price_rec.price;
            END LOOP;
            --
            IF l_price > 0 THEN
              j := j + 1;
              l_del_leg_tab(j) := l_leg.delivery_leg_id;
              l_at_least_one_leg_priced := TRUE;
            END IF;
            --
            IF (l_leg.lane_id is not null)
            --TL Rating
            OR l_leg.mode_of_transport=C_TRUCK THEN

              IF NOT(l_at_least_one_leg_priced) THEN
                FOR legs_priced_rec IN legs_priced_cur( l_leg.trip_id ) LOOP
                  l_at_least_one_leg_priced := TRUE;
                END LOOP;
              END IF;
              --
              IF l_at_least_one_leg_priced THEN
                FOR l_other IN get_legs_from_trip( l_leg.trip_id ) LOOP
                  j := j + 1;
                  l_del_leg_tab(j) := l_other.delivery_leg_id;
                END LOOP;
              END IF;
             END IF;
           END LOOP;
        END LOOP;

      ELSIF p_entity_type = 'DELIVERY' THEN
        FOR i IN  1 .. p_entity_ids.count LOOP
          FOR l_leg IN get_trip_from_del(p_entity_ids(i)) LOOP
            l_at_least_one_leg_priced := FALSE;
            l_price := 0;
            --
            FOR leg_price_rec IN leg_price_cur(l_leg.delivery_leg_id) LOOP
              l_price := l_price+leg_price_rec.price;
            END LOOP;
            --
            IF l_price > 0 THEN
              j := j + 1;
              l_del_leg_tab(j) := l_leg.delivery_leg_id;
              l_at_least_one_leg_priced := TRUE;
            END IF;

            IF (l_leg.lane_id is not null)
            --TL Rating
            OR l_leg.mode_of_transport=C_TRUCK THEN

              IF NOT(l_at_least_one_leg_priced) THEN
                FOR legs_priced_rec IN legs_priced_cur( l_leg.trip_id ) LOOP
                  l_at_least_one_leg_priced := TRUE;
                END LOOP;
              END IF;
              --
              IF l_at_least_one_leg_priced THEN
                FOR l_other IN get_legs_from_trip( l_leg.trip_id ) LOOP
                  j := j + 1;
                  l_del_leg_tab(j) := l_other.delivery_leg_id;
                END LOOP;
              END IF;
            END IF;

          END LOOP;

        END LOOP;

      ELSIF p_entity_type = 'DELIVERY_LEG' THEN
        FOR i IN  1 .. p_entity_ids.count LOOP
          FOR l_leg IN get_trip_from_leg(p_entity_ids(i)) LOOP
            --j := j + 1;
            --l_del_leg_tab(j) := l_leg.delivery_leg_id;
            l_at_least_one_leg_priced := FALSE;
            --
---  Added the following condition for the Bug 4451383
           IF (l_leg.lane_id is not null
               OR  l_leg.mode_of_transport=C_TRUCK
              )
           THEN

             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'legs_priced_cur is being opened for dlegs');
             END IF;

             FOR legs_priced_rec IN legs_priced_cur( l_leg.trip_id ) LOOP
               l_at_least_one_leg_priced := TRUE;
             END LOOP;
           END IF;
            --
            --
            IF ((l_leg.lane_id is not null)
                --TL Rating
                OR l_leg.mode_of_transport=C_TRUCK) AND l_at_least_one_leg_priced THEN
              FOR l_other IN get_legs_from_trip( l_leg.trip_id ) LOOP
                j := j + 1;
                l_del_leg_tab(j) := l_other.delivery_leg_id;
                --
              END LOOP;
            END IF;
          END LOOP;
        END LOOP;
      ELSIF p_entity_type = 'STOP' THEN
        FOR i IN  1 .. p_entity_ids.count LOOP
          FOR l_leg IN get_trip_from_stop(p_entity_ids(i)) LOOP
            l_at_least_one_leg_priced := FALSE;

---  Added the following condition for the Bug 4451383
           IF (l_leg.lane_id is not null
               OR  l_leg.mode_of_transport=C_TRUCK
              )
           THEN

             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'legs_priced_cur is being opened for stops');
             END IF;

              FOR legs_priced_rec IN legs_priced_cur( l_leg.trip_id ) LOOP
                l_at_least_one_leg_priced := TRUE;
              END LOOP;
            END IF;

            IF ((l_leg.lane_id is not null)
                --TL Rating
                OR l_leg.mode_of_transport=C_TRUCK) AND l_at_least_one_leg_priced THEN
              FOR l_other IN get_legs_from_trip( l_leg.trip_id ) LOOP
                j := j + 1;
                l_final_leg_tab(j) := l_other.delivery_leg_id;
              END LOOP;
            END IF;
          END LOOP;
        END LOOP;

      ELSIF p_entity_type = 'TRIP' THEN
        FOR i IN  1 .. p_entity_ids.count LOOP
          l_at_least_one_leg_priced := FALSE;
 -- Bug 4451383 new cursor to get trip details
          open get_trip_details(p_entity_ids(i) );
          fetch get_trip_details into l_mode_of_transport,l_lane_id;
          close get_trip_details;

          IF (  l_mode_of_transport = C_TRUCK OR
                l_lane_id is not null) THEN

             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'legs_priced_cur is being opened for trips');
             END IF;

            FOR legs_priced_rec IN legs_priced_cur( p_entity_ids(i) ) LOOP
              l_at_least_one_leg_priced := TRUE;
            END LOOP;
          END IF;
          --
          --
          IF l_at_least_one_leg_priced THEN
            FOR l_other IN get_legs_from_trip(p_entity_ids(i)) LOOP
              IF (l_other.lane_id is not null
                  --TL Rating
                  OR l_other.mode_of_transport=C_TRUCK) THEN
                j := j + 1;
                l_final_leg_tab(j) := l_other.delivery_leg_id;
              END IF;
            END LOOP;
          END IF;
        END LOOP;

      ELSE
        RAISE invalid_parameter;
      END IF;

        -- remove duplicate delivery leg ids
      IF p_entity_type NOT IN ('TRIP', 'STOP') THEN
        FOR i in 1 .. l_del_leg_tab.count LOOP
          IF i = 1 THEN
              l_final_leg_tab(1) := l_del_leg_tab(i);
          ELSE
             l_duplicate := 0;
             FOR k in 1 .. l_final_leg_tab.count LOOP
                IF l_del_leg_tab(i) = l_final_leg_tab(k) THEN
                   l_duplicate := 1;
                   exit;
                END IF;
             END LOOP;
             IF l_duplicate = 0 THEN
                l_final_leg_tab(l_final_leg_tab.count+1) := l_del_leg_tab(i);
             END IF;
          END IF;
        END LOOP;
      END IF;

      FOR i in 1 .. l_final_leg_tab.count  LOOP
        OPEN c_lock_delivery_leg(l_final_leg_tab(i));
        FETCH c_lock_delivery_leg INTO l_lock_delivery_leg_rec;
        IF c_lock_delivery_leg%FOUND THEN
          IF l_lock_delivery_leg_rec.reprice_required <> 'Y' THEN
             UPDATE wsh_delivery_legs
             SET reprice_required = 'Y'
             WHERE CURRENT OF c_lock_delivery_leg;
             IF l_lock_delivery_leg_rec.parent_delivery_leg_id IS NOT NULL THEN
                BEGIN
                   WSH_DELIVERY_LEGS_PVT.lock_dlvy_leg_no_compare(p_dlvy_leg_id =>  l_lock_delivery_leg_rec.parent_delivery_leg_id);
                EXCEPTION
                   WHEN OTHERS THEN
                        IF c_lock_delivery_leg%ISOPEN THEN
                           CLOSE c_lock_delivery_leg;
                        END IF;
                        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                        FND_MESSAGE.Set_Name('WSH', 'WSH_DEL_LEG_LOCKED');
                        WSH_UTIL_CORE.Add_Message(x_return_status);
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'DELIVERY_LEG_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DELIVERY_LEG_LOCKED');
                        END IF;
                        RETURN;
                END;
                UPDATE wsh_delivery_legs
                SET reprice_required = 'Y'
                WHERE delivery_leg_id =  l_lock_delivery_leg_rec.parent_delivery_leg_id
                AND NVL(reprice_required, 'N') <> 'Y';
             END IF;
          END IF;
        END IF;
        CLOSE c_lock_delivery_leg;
      END LOOP;

    END IF;  -- fte is installed and p_entity_ids is not empty

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION

      WHEN invalid_parameter THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('WSH', 'WSH_PUB_INVALID_PARAMETER');
        FND_MESSAGE.Set_Token('PARAMETER', 'P_ENTITY_TYPE');
        WSH_UTIL_CORE.Add_Message(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_PARAMETER exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_PARAMETER');
END IF;
--
      WHEN delivery_leg_locked THEN
        CLOSE c_lock_delivery_leg;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('WSH', 'WSH_DEL_LEG_LOCKED');
        WSH_UTIL_CORE.Add_Message(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'DELIVERY_LEG_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DELIVERY_LEG_LOCKED');
END IF;
--
      WHEN  others THEN
        wsh_util_core.default_handler('WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Mark_Reprice_Required;

-- FUNCTION: Check_Rate_Delivery
-- PARAMETERS: p_delivery_id, p_freight_terms_code, p_shipment_direction
-- DESCRIPTION:  This API will take in a delivery id or the shipment direction and freight code
--               of a delivery. It will return values of 'Y' or 'N' depending on whether the delivery
--               needs to be rated  or does not need to be rated based on the global parameter values.


FUNCTION Check_Rate_Delivery (p_delivery_id IN NUMBER,
                              p_freight_terms_code VARCHAR2,
                              p_shipment_direction VARCHAR2,
                              x_return_status out nocopy VARCHAR2)
RETURN VARCHAR2 IS


CURSOR c_del_info(p_del_id in number) is
select freight_terms_code, nvl(shipment_direction, 'O')
from wsh_new_deliveries where delivery_id = p_del_id;


l_rate_delivery VARCHAR2(1);
l_global_params WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
l_shipment_direction VARCHAR2(10);
l_freight_terms_code VARCHAR2(30);
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Rate_Delivery';
invalid_global_params EXCEPTION;
invalid_delivery EXCEPTION;


BEGIN

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'p_delivery_id',p_delivery_id);
    END IF;


   WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(
                x_param_info => l_global_params,
                x_return_status => x_return_status);

   IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN

      RAISE invalid_global_params;

   END IF;


   IF p_shipment_direction IS NULL THEN

      OPEN c_del_info(p_delivery_id);
      FETCH c_del_info INTO l_freight_terms_code, l_shipment_direction;
      IF c_del_info%NOTFOUND THEN
         RAISE invalid_delivery;
      END IF;
      CLOSE c_del_info;


   ELSE

     l_freight_terms_code := p_freight_terms_code;
     l_shipment_direction := p_shipment_direction;

   END IF;



   IF l_shipment_direction in ('IO', 'O') THEN



      IF l_freight_terms_code = l_global_params.skip_rate_ob_dels_fgt_term THEN

         l_rate_delivery := 'N';

      ELSE

         l_rate_delivery := 'Y';

      END IF;


   ELSIF l_shipment_direction = 'I' THEN

      IF l_freight_terms_code = l_global_params.rate_ib_dels_fgt_term THEN

         l_rate_delivery := 'Y';

      ELSE

         l_rate_delivery := 'N';

      END IF;


   ELSIF l_shipment_direction = 'D' THEN

      IF l_freight_terms_code = l_global_params.rate_ds_dels_fgt_term_id THEN

         l_rate_delivery := 'Y';

      ELSE

         l_rate_delivery := 'N';

      END IF;

    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN l_rate_delivery;

EXCEPTION

  WHEN invalid_delivery THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_DELIVERY');
        WSH_UTIL_CORE.Add_Message(x_return_status);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DELIVERY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_DELIVERY');
        END IF;

  WHEN invalid_global_params THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_GLOBAL_PARAMETER');
        WSH_UTIL_CORE.Add_Message(x_return_status);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_PARAMETER exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_PARAMETER');
        END IF;

  WHEN others THEN
       wsh_util_core.default_handler('WSH_TRIP_VALIDATIONS.Check_Rate_Content_Dels');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;

END Check_Rate_Delivery;

-- FUNCTION: Check_Rate_Check_Rate_Trip_Contents
-- PARAMETERS: p_trip_id
-- DESCRIPTION:  This API will take in a trip_id, and it will return values of 'Y' or 'N'
--               depending on whether the content deliveries need to be rated or do not need
--               to be rated, or mixed based on the global parameter values.

FUNCTION Check_Rate_Trip_Contents(p_trip_id IN NUMBER,
                                  x_return_status OUT nocopy VARCHAR2)
RETURN VARCHAR2 IS

CURSOR C_TRIP_DEL_RATE(p_trip_id IN NUMBER, p_freight_terms_code_o IN VARCHAR2,
                            p_freight_terms_code_i IN VARCHAR2, p_freight_terms_code_d VARCHAR2) IS
select wnd.delivery_id
FROM   wsh_new_deliveries wnd,
       wsh_trip_stops wts,
       wsh_delivery_legs wdl
WHERE  wts.stop_id = wdl.pick_up_stop_id AND
       wts.trip_id = p_trip_id AND
       wdl.delivery_id = wnd.delivery_id AND
       wnd.freight_terms_code <> p_freight_terms_code_o and
       NVL(wnd.shipment_direction, 'O') IN ('O', 'IO')
       and rownum = 1
UNION
select wnd.delivery_id
FROM   wsh_new_deliveries wnd,
       wsh_trip_stops wts,
       wsh_delivery_legs wdl
WHERE  wts.stop_id = wdl.pick_up_stop_id AND
       wts.trip_id = p_trip_id AND
       wdl.delivery_id = wnd.delivery_id AND
       wnd.freight_terms_code <> p_freight_terms_code_i and
       wnd.shipment_direction = 'I'
       and rownum = 1
UNION
select wnd.delivery_id
FROM   wsh_new_deliveries wnd,
       wsh_trip_stops wts,
       wsh_delivery_legs wdl
WHERE  wts.stop_id = wdl.pick_up_stop_id AND
       wts.trip_id = p_trip_id AND
       wdl.delivery_id = wnd.delivery_id AND
       wnd.freight_terms_code <> p_freight_terms_code_d and
       wnd.shipment_direction = 'D'
       and rownum = 1;

CURSOR C_TRIP_DEL_NORATE(p_trip_id IN NUMBER, p_freight_terms_code_o IN VARCHAR2,
                            p_freight_terms_code_i IN VARCHAR2, p_freight_terms_code_d VARCHAR2) IS
select wnd.delivery_id
FROM   wsh_new_deliveries wnd,
       wsh_trip_stops wts,
       wsh_delivery_legs wdl
WHERE  wts.stop_id = wdl.pick_up_stop_id AND
       wts.trip_id = p_trip_id AND
       wdl.delivery_id = wnd.delivery_id AND
       wnd.freight_terms_code = p_freight_terms_code_o and
       NVL(wnd.shipment_direction, 'O') IN ('O', 'IO')
       and rownum = 1
UNION
select wnd.delivery_id
FROM   wsh_new_deliveries wnd,
       wsh_trip_stops wts,
       wsh_delivery_legs wdl
WHERE  wts.stop_id = wdl.pick_up_stop_id AND
       wts.trip_id = p_trip_id AND
       wdl.delivery_id = wnd.delivery_id AND
       wnd.freight_terms_code <> p_freight_terms_code_i and
       wnd.shipment_direction = 'I'
       and rownum = 1
UNION
select wnd.delivery_id
FROM   wsh_new_deliveries wnd,
       wsh_trip_stops wts,
       wsh_delivery_legs wdl
WHERE  wts.stop_id = wdl.pick_up_stop_id AND
       wts.trip_id = p_trip_id AND
       wdl.delivery_id = wnd.delivery_id AND
       wnd.freight_terms_code <> p_freight_terms_code_d and
       wnd.shipment_direction = 'D'
       and rownum = 1;



l_rate_trip_dels VARCHAR2(1);
l_global_params WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
l_debug_on BOOLEAN;
l_dummy_del NUMBER;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Rate_Delivery';

invalid_global_params EXCEPTION;
invalid_trip EXCEPTION;

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'p_trip_id',p_trip_id);
    END IF;


IF p_trip_id is NULL THEN

   RAISE invalid_trip;

ELSE


   WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(
                x_param_info => l_global_params,
                x_return_status => x_return_status);

   IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)  THEN
      RAISE invalid_global_params;
   END IF;

   OPEN C_TRIP_DEL_RATE(p_trip_id,
                        l_global_params.skip_rate_ob_dels_fgt_term,
                        l_global_params.rate_ib_dels_fgt_term,
                        l_global_params.rate_ds_dels_fgt_term_id);
   FETCH C_TRIP_DEL_RATE INTO l_dummy_del;
   IF C_TRIP_DEL_RATE%FOUND THEN
      l_rate_trip_dels := 'Y';
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_rate_trip_dels 1',l_rate_trip_dels);
      END IF;
   END IF;
   CLOSE C_TRIP_DEL_RATE;


   OPEN C_TRIP_DEL_NORATE(p_trip_id,
                          l_global_params.skip_rate_ob_dels_fgt_term,
                          l_global_params.rate_ib_dels_fgt_term,
                          l_global_params.rate_ds_dels_fgt_term_id);
   FETCH C_TRIP_DEL_NORATE INTO l_dummy_del;
   IF C_TRIP_DEL_NORATE%FOUND THEN
      IF l_rate_trip_dels = 'Y' THEN
         l_rate_trip_dels := 'M';
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_rate_trip_dels 2',l_rate_trip_dels);
         END IF;
      ELSE
         l_rate_trip_dels := 'N';
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_rate_trip_dels 3',l_rate_trip_dels);
         END IF;
      END IF;
   END IF;
   CLOSE C_TRIP_DEL_NORATE;

END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_rate_trip_dels',l_rate_trip_dels);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
RETURN l_rate_trip_dels;

EXCEPTION

  WHEN invalid_trip THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_TRIP');
        WSH_UTIL_CORE.Add_Message(x_return_status);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DELIVERY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_DELIVERY');
        END IF;

  WHEN invalid_global_params THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_GLOBAL_PARAMETER');
        WSH_UTIL_CORE.Add_Message(x_return_status);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_PARAMETER exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_PARAMETER');
        END IF;

  WHEN others THEN
       IF c_trip_del_norate%isopen THEN
          close c_trip_del_norate;
       END IF;
       IF c_trip_del_rate%isopen THEN
          close c_trip_del_rate;
       END IF;
       wsh_util_core.default_handler('Check_Rate_Content_Dels');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;

END Check_Rate_Trip_Contents;



END WSH_DELIVERY_LEGS_ACTIONS;

/
