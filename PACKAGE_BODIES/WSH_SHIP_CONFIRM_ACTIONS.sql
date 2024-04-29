--------------------------------------------------------
--  DDL for Package Body WSH_SHIP_CONFIRM_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIP_CONFIRM_ACTIONS" as
/* $Header: WSHDDSHB.pls 120.19.12010000.9 2010/04/27 09:29:13 anvarshn ship $ */

c_inv_int_partial CONSTANT VARCHAR2(1) := 'P';
c_inv_int_full   CONSTANT VARCHAR2(1) := 'Y';

--Global Variables added for bug 4538005
   g_prv_from_location      NUMBER;
   g_prv_customer_site_id   NUMBER;
   g_intransit_time         NUMBER;
   g_prv_ship_method_code   VARCHAR2(30);
--

G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SHIP_CONFIRM_ACTIONS';
--

-- Bug 3628620
-- Old Procedure transfer_serial_numbers is modified to be a wrapper
-- on top of transfer_serial_numbers_pvt

--========================================================================
-- PROCEDURE : transfer_serial_numbers_pvt
--             Transfers Serial Numbers from mtl_serial_numbers_temp to
--             wsh_serial_numbers and this will be used to display the
--             Serial Numbers shipped from the Shipping Transactions Form
--
-- PARAMETERS: p_transfer_param        Input Parameter for this API
--                                     Values can be WDD or MSNT
--             p_batch_id              The batch id of trip stops being
--                                     interfaced.
--             p_interfacing           if this procedure is called during OM
--                                     interface value 'OM' is passed, otherwise
--                                     value 'INV' is passed.
--             x_return_status         return status of the API.

-- COMMENT   : This procedure is used to transfer the serial number information
--             from mtl_serial_numbers_temp to the wsh_serial_numbers table.
--             It then deletes these entries from mtl_serial_numbers_temp.
--             IF this procedure is called during the INV interface then only
--             the lines that have been interfaced to OM are processed, else
--             the non-oe lines are processed as well.
--========================================================================

PROCEDURE transfer_serial_numbers_pvt (
            p_transfer_param   IN VARCHAR2,
            p_batch_id       IN  NUMBER,
            p_interfacing    IN VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2) IS

  CURSOR dd_msnt_rec  IS
  select dd.delivery_detail_id, dd.transaction_temp_id,
         to_number(msnt.serial_prefix) "quantity",
         msnt.fm_serial_number, msnt.to_serial_number,
         msnt.attribute_category, -- Bug 3628620
         msnt.attribute1,
         msnt.attribute2,
         msnt.attribute3,
         msnt.attribute4,
         msnt.attribute5,
         msnt.attribute6,
         msnt.attribute7,
         msnt.attribute8,
         msnt.attribute9,
         msnt.attribute10,
         msnt.attribute11,
         msnt.attribute12,
         msnt.attribute13,
         msnt.attribute14,
         msnt.attribute15,   -- End of Bug 3628620
         dd.inventory_item_id -- 3704188
  from   wsh_delivery_details dd,
         wsh_delivery_assignments_v da,
         wsh_delivery_legs dg,
         wsh_new_deliveries dl,
         wsh_trip_stops st,
         mtl_serial_numbers_temp msnt
  where  st.batch_id = p_batch_id
  and    st.stop_location_id = dl.initial_pickup_location_id
  and    dg.delivery_id = dl.delivery_id
  and    da.delivery_id = dl.delivery_id
  and    dd.delivery_detail_id = da.delivery_detail_id
  -- bug 2787888 : removed oe_interfaced_flag and source_code comparison for OKE lines
  and    st.stop_id = dg.pick_up_stop_id
  and    dd.released_status = 'C'
  and    dd.container_flag='N'
  and    dd.transaction_temp_id = msnt.transaction_temp_id
--  and    msnt.fm_serial_number <> nvl(msnt.to_serial_number, msnt.fm_serial_number)
  and    nvl(dl.shipment_direction , 'O') IN ('O', 'IO');   -- J Inbound Logistics jckwok

  CURSOR dd_msnt_rec_om  IS
  select dd.delivery_detail_id, dd.transaction_temp_id,
         to_number(msnt.serial_prefix) "quantity",
         msnt.fm_serial_number, msnt.to_serial_number,
         msnt.attribute_category, -- Bug 3628620
         msnt.attribute1,
         msnt.attribute2,
         msnt.attribute3,
         msnt.attribute4,
         msnt.attribute5,
         msnt.attribute6,
         msnt.attribute7,
         msnt.attribute8,
         msnt.attribute9,
         msnt.attribute10,
         msnt.attribute11,
         msnt.attribute12,
         msnt.attribute13,
         msnt.attribute14,
         msnt.attribute15,   -- End of Bug 3628620
         dd.inventory_item_id -- 3704188
  from   wsh_delivery_details dd,
         wsh_delivery_assignments_v da,
         wsh_delivery_legs dg,
         wsh_new_deliveries dl,
         wsh_trip_stops st,
         mtl_serial_numbers_temp msnt
  where  st.batch_id = p_batch_id
  and    st.stop_location_id = dl.initial_pickup_location_id
  and    dg.delivery_id = dl.delivery_id
  and    da.delivery_id = dl.delivery_id
  and    dd.delivery_detail_id = da.delivery_detail_id
  and    st.stop_id = dg.pick_up_stop_id
  and    dd.released_status = 'C'
  and    dd.container_flag='N'
  and    NVL(dd.oe_interfaced_flag , 'N') = 'Y'
  and    dd.transaction_temp_id = msnt.transaction_temp_id
--  and    msnt.fm_serial_number <> nvl(msnt.to_serial_number, msnt.fm_serial_number)
  and    nvl(dl.shipment_direction , 'O') IN ('O', 'IO');

  CURSOR dd_wdd_rec  IS
  select dd.delivery_detail_id, msn.group_mark_id,
         dd.shipped_quantity "quantity",
         dd.serial_number, dd.serial_number "to_serial_number",
         msn.attribute_category, -- Bug 3628620
         msn.attribute1,
         msn.attribute2,
         msn.attribute3,
         msn.attribute4,
         msn.attribute5,
         msn.attribute6,
         msn.attribute7,
         msn.attribute8,
         msn.attribute9,
         msn.attribute10,
         msn.attribute11,
         msn.attribute12,
         msn.attribute13,
         msn.attribute14,
         msn.attribute15,   -- End of Bug 3628620
         dd.inventory_item_id -- 3704188
  from   wsh_delivery_details dd,
         wsh_delivery_assignments_v da,
         wsh_delivery_legs dg,
         wsh_new_deliveries dl,
         wsh_trip_stops st,
         mtl_serial_numbers msn
  where  st.batch_id = p_batch_id
  and    st.stop_location_id = dl.initial_pickup_location_id
  and    dg.delivery_id = dl.delivery_id
  and    da.delivery_id = dl.delivery_id
  and    dd.delivery_detail_id = da.delivery_detail_id
  -- bug 2787888 : removed oe_interfaced_flag and source_code comparison for OKE lines
  and    st.stop_id = dg.pick_up_stop_id
  and    dd.released_status = 'C'
  and    dd.container_flag='N'
  and    dd.serial_number = msn.serial_number
  and    dd.inventory_item_id = msn.inventory_item_id -- bug 3704188: part of mtl_serial_numbers_u1
  and    nvl(dl.shipment_direction , 'O') IN ('O', 'IO');   -- J Inbound Logistics jckwok

  CURSOR dd_wdd_rec_om  IS
  select dd.delivery_detail_id, msn.group_mark_id,
         dd.shipped_quantity "quantity",
         dd.serial_number, dd.serial_number "to_serial_number",
         msn.attribute_category, -- Bug 3628620
         msn.attribute1,
         msn.attribute2,
         msn.attribute3,
         msn.attribute4,
         msn.attribute5,
         msn.attribute6,
         msn.attribute7,
         msn.attribute8,
         msn.attribute9,
         msn.attribute10,
         msn.attribute11,
         msn.attribute12,
         msn.attribute13,
         msn.attribute14,
         msn.attribute15,   -- End of Bug 3628620
         dd.inventory_item_id -- 3704188
  from   wsh_delivery_details dd,
         wsh_delivery_assignments_v da,
         wsh_delivery_legs dg,
         wsh_new_deliveries dl,
         wsh_trip_stops st,
         mtl_serial_numbers msn
  where  st.batch_id = p_batch_id
  and    st.stop_location_id = dl.initial_pickup_location_id
  and    dg.delivery_id = dl.delivery_id
  and    da.delivery_id = dl.delivery_id
  and    dd.delivery_detail_id = da.delivery_detail_id
  and    st.stop_id = dg.pick_up_stop_id
  and    dd.released_status = 'C'
  and    dd.container_flag='N'
  and    NVL(dd.oe_interfaced_flag , 'N') = 'Y'
  and    dd.serial_number = msn.serial_number
  and    dd.inventory_item_id = msn.inventory_item_id -- bug 3704188: part of mtl_serial_numbers_u1
  and    nvl(dl.shipment_direction , 'O') IN ('O', 'IO');

  CURSOR c_get_attr_msn (x_serial_number VARCHAR2,
                         x_inventory_item_id NUMBER) IS
  select msn.attribute1,
         msn.attribute2,
         msn.attribute3,
         msn.attribute4,
         msn.attribute5,
         msn.attribute6,
         msn.attribute7,
         msn.attribute8,
         msn.attribute9,
         msn.attribute10,
         msn.attribute11,
         msn.attribute12,
         msn.attribute13,
         msn.attribute14,
         msn.attribute15
  from   mtl_serial_numbers msn
  where  msn.serial_number = x_serial_number
  and    msn.inventory_item_id = x_inventory_item_id -- bug 3704188: part of mtl_serial_numbers_u1
  ;

  TYPE t_delivery_detail_id  IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
  TYPE t_transaction_temp_id IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
  TYPE t_quantity            IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
  TYPE t_inv_item_id         IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
  TYPE t_fm_serial_number    IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE t_to_serial_number    IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  -- Bug 3628620
  TYPE t_attribute_category  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE t_attribute1          IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute2          IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute3          IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute4          IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute5          IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute6          IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute7          IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute8          IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute9          IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute10         IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute11         IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute12         IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute13         IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute14         IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE t_attribute15         IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  -- End of Bug 3628620

  l_delivery_detail_id   t_delivery_detail_id;
  l_transaction_temp_id  t_transaction_temp_id;
  l_quantity             t_quantity ;
  l_inv_item_id          t_inv_item_id ;
  l_fm_serial_number     t_fm_serial_number ;
  l_to_serial_number     t_to_serial_number ;

  -- Bug 3628620
  l_attribute_category   t_attribute_category ;
  l_attribute1           t_attribute1 ;
  l_attribute2           t_attribute2 ;
  l_attribute3           t_attribute3 ;
  l_attribute4           t_attribute4 ;
  l_attribute5           t_attribute5 ;
  l_attribute6           t_attribute6 ;
  l_attribute7           t_attribute7 ;
  l_attribute8           t_attribute8 ;
  l_attribute9           t_attribute9 ;
  l_attribute10          t_attribute10 ;
  l_attribute11          t_attribute11 ;
  l_attribute12          t_attribute12 ;
  l_attribute13          t_attribute13 ;
  l_attribute14          t_attribute14 ;
  l_attribute15          t_attribute15 ;
  -- End of Bug 3628620

  cur_fetch  NUMBER := 0;
  tot_fetch  NUMBER := 0;
  pre_fetch  NUMBER := 0;
  l_batch_size  NUMBER := 1000;
  ins_rows   NUMBER := 0;
  del_rows   NUMBER := 0;
  upd_rows   NUMBER := 0;
--
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRANSFER_SERIAL_NUMBERS_PVT';
--

BEGIN
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'p_transfer_param',p_transfer_param);
       WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
       WSH_DEBUG_SV.log(l_module_name,'p_interfacing',p_interfacing);
   END IF;
   --

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF p_interfacing = 'OM' THEN
     IF p_transfer_param = 'MSNT' THEN
        OPEN dd_msnt_rec_om;
     ELSIF p_transfer_param = 'WDD' THEN
        OPEN dd_wdd_rec_om;
     END IF;
  ELSE
     IF p_transfer_param = 'MSNT' THEN
        OPEN dd_msnt_rec;
     ELSIF p_transfer_param = 'WDD' THEN
        OPEN dd_wdd_rec;
     END IF;
  END IF;

  tot_fetch := 0;
  LOOP
    pre_fetch := tot_fetch;

    IF p_interfacing = 'OM' THEN
     IF p_transfer_param = 'MSNT' THEN
       FETCH dd_msnt_rec_om BULK COLLECT
       INTO  l_delivery_detail_id, l_transaction_temp_id,
             l_quantity, l_fm_serial_number, l_to_serial_number,
             l_attribute_category, l_attribute1, l_attribute2,
             l_attribute3,  l_attribute4,  l_attribute5,  l_attribute6,
             l_attribute7,  l_attribute8,  l_attribute9,  l_attribute10,
             l_attribute11, l_attribute12, l_attribute13, l_attribute14,
             l_attribute15,
             l_inv_item_id -- bug 3704188
       LIMIT l_batch_size ;
       tot_fetch := dd_msnt_rec_om%ROWCOUNT;
     ELSIF p_transfer_param = 'WDD' THEN
       FETCH dd_wdd_rec_om BULK COLLECT
       INTO  l_delivery_detail_id, l_transaction_temp_id,
             l_quantity, l_fm_serial_number, l_to_serial_number,
             l_attribute_category, l_attribute1, l_attribute2,
             l_attribute3,  l_attribute4,  l_attribute5,  l_attribute6,
             l_attribute7,  l_attribute8,  l_attribute9,  l_attribute10,
             l_attribute11, l_attribute12, l_attribute13, l_attribute14,
             l_attribute15,
             l_inv_item_id -- bug 3704188
       LIMIT l_batch_size ;
       tot_fetch := dd_wdd_rec_om%ROWCOUNT;
     END IF;
    ELSE
     IF p_transfer_param = 'MSNT' THEN
       FETCH dd_msnt_rec BULK COLLECT
       INTO  l_delivery_detail_id, l_transaction_temp_id,
             l_quantity, l_fm_serial_number, l_to_serial_number,
             l_attribute_category, l_attribute1, l_attribute2,
             l_attribute3,  l_attribute4,  l_attribute5,  l_attribute6,
             l_attribute7,  l_attribute8,  l_attribute9,  l_attribute10,
             l_attribute11, l_attribute12, l_attribute13, l_attribute14,
             l_attribute15,
             l_inv_item_id -- bug 3704188
       LIMIT l_batch_size ;
       tot_fetch := dd_msnt_rec%ROWCOUNT;
     ELSIF p_transfer_param = 'WDD' THEN
       FETCH dd_wdd_rec BULK COLLECT
       INTO  l_delivery_detail_id, l_transaction_temp_id,
             l_quantity, l_fm_serial_number, l_to_serial_number,
             l_attribute_category, l_attribute1, l_attribute2,
             l_attribute3,  l_attribute4,  l_attribute5,  l_attribute6,
             l_attribute7,  l_attribute8,  l_attribute9,  l_attribute10,
             l_attribute11, l_attribute12, l_attribute13, l_attribute14,
             l_attribute15,
             l_inv_item_id -- bug 3704188
       LIMIT l_batch_size ;
       tot_fetch := dd_wdd_rec%ROWCOUNT;
     END IF;
    END IF;

    cur_fetch := tot_fetch - pre_fetch;
    EXIT WHEN ( cur_fetch <= 0);

    FORALL i IN 1 .. cur_fetch
      INSERT INTO wsh_serial_numbers
                         ( delivery_detail_id,
                           quantity,
                           fm_serial_number,
                           to_serial_number,
                           creation_date,
                           created_by,
                           last_update_date,
                           last_updated_by,
                           attribute_category, -- Bug 3628620
                           attribute1, attribute2, attribute3,
                           attribute4,  attribute5, attribute6,
                           attribute7,  attribute8, attribute9,
                           attribute10, attribute11,attribute12,
                           attribute13, attribute14,attribute15 -- End of Bug 3628620
                          )
                      VALUES
                         ( l_delivery_detail_id(i),
                           l_quantity(i),
                           l_fm_serial_number(i),
                           l_to_serial_number(i),
                           sysdate,
                           FND_GLOBAL.USER_ID,
                           sysdate,
                           FND_GLOBAL.USER_ID,
                           l_attribute_category(i), -- Bug 3628620
                           l_attribute1(i), l_attribute2(i), l_attribute3(i),
                           l_attribute4(i),  l_attribute5(i),  l_attribute6(i),
                           l_attribute7(i),  l_attribute8(i),  l_attribute9(i),
                           l_attribute10(i), l_attribute11(i), l_attribute12(i),
                           l_attribute13(i), l_attribute14(i), l_attribute15(i)
                           -- End of Bug 3628620
                          );


    ins_rows := ins_rows + sql%rowcount;
    -- Bug 6625172: Removing Delete of msnt for each transaction_temp_id from here
    -- and updating wsh_delivery_details only when p_transfer_param is 'WDD'
    IF p_transfer_param = 'WDD' THEN
      /* FORALL i IN 1 .. cur_fetch
         DELETE FROM mtl_serial_numbers_temp
         WHERE  transaction_temp_id = l_transaction_temp_id(i)
         AND    fm_serial_number = l_fm_serial_number(i);

       del_rows := del_rows + sql%rowcount;
    ELSE*/
       FORALL i IN 1 .. cur_fetch
         UPDATE wsh_delivery_details
         SET    serial_number = NULL,
	        --Added as part of bug 7645262
                last_update_date    = sysdate,
                request_id          = fnd_global.conc_request_id,
                last_updated_by     = fnd_global.user_id,
                transaction_temp_id = l_transaction_temp_id(i)
         WHERE  delivery_detail_id = l_delivery_detail_id(i);

       upd_rows := upd_rows + sql%rowcount;
    END IF;

  END LOOP;

  IF p_interfacing = 'OM' THEN
     IF p_transfer_param = 'MSNT' THEN
      --{
        CLOSE dd_msnt_rec_om;
	-- bug 6625172: Deleting the msnt records for all the selected transaction_temp_id's for OM records
	IF (ins_rows > 0) THEN
        --{
           DELETE mtl_serial_numbers_temp
           WHERE  transaction_temp_id IN
              (   SELECT DISTINCT dd.transaction_temp_id
                  from  wsh_delivery_details dd,
                  wsh_delivery_assignments da,
                  wsh_delivery_legs dg,
                  wsh_new_deliveries dl,
                  wsh_trip_stops st,
                  mtl_serial_numbers_temp msnt
                  where  st.batch_id = p_batch_id
                  and    st.stop_location_id = dl.initial_pickup_location_id
                  and    dg.delivery_id = dl.delivery_id
                  and    da.delivery_id = dl.delivery_id
                  and    dd.delivery_detail_id = da.delivery_detail_id
                  and    st.stop_id = dg.pick_up_stop_id
                  and    dd.released_status = 'C'
                  and    dd.container_flag='N'
                  and    NVL(dd.oe_interfaced_flag , 'N') = 'Y'
                  and    dd.transaction_temp_id = msnt.transaction_temp_id
                  and    nvl(dl.shipment_direction , 'O') IN ('O', 'IO'));
        --}
        END IF;
      --}
     ELSIF p_transfer_param = 'WDD' THEN
        CLOSE dd_wdd_rec_om;
     END IF;
  ELSE
     IF p_transfer_param = 'MSNT' THEN
     --{
        CLOSE dd_msnt_rec;
	-- bug 6625172: Deleting the msnt records for all the selected transaction_temp_id's for non-OM records
        IF (ins_rows > 0) THEN
        --{
            DELETE mtl_serial_numbers_temp
            WHERE  transaction_temp_id IN
            ( SELECT DISTINCT dd.transaction_temp_id
                  from   wsh_delivery_details dd,
                  wsh_delivery_assignments da,
                 wsh_delivery_legs dg,
                 wsh_new_deliveries dl,
                 wsh_trip_stops st,
                 mtl_serial_numbers_temp msnt
                 where  st.batch_id = p_batch_id
                 and    st.stop_location_id = dl.initial_pickup_location_id
                 and    dg.delivery_id = dl.delivery_id
                 and    da.delivery_id = dl.delivery_id
                 and    dd.delivery_detail_id = da.delivery_detail_id
                 and    st.stop_id = dg.pick_up_stop_id
                 and    dd.released_status = 'C'
                 and    dd.container_flag='N'
                 and    dd.transaction_temp_id = msnt.transaction_temp_id
                 and    nvl(dl.shipment_direction , 'O') IN ('O', 'IO'));
         --}
       END IF;
       --}
     ELSIF p_transfer_param = 'WDD' THEN
        CLOSE dd_wdd_rec;
     END IF;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Numbers of rows inserted into wsh_serial_numbers: '|| to_char(ins_rows) ||
                                     ', Number of rows deleted from mtl_serial_numbers_temp: '|| to_char(del_rows) ||
                                     ', Number of rows updated in wsh_delivery_details: '|| to_char(upd_rows) );
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF dd_msnt_rec%ISOPEN THEN
      CLOSE dd_msnt_rec;
    END IF;
    IF dd_msnt_rec_om%ISOPEN THEN
      CLOSE dd_msnt_rec_om;
    END IF;
    IF dd_wdd_rec%ISOPEN THEN
      CLOSE dd_wdd_rec;
    END IF;
    IF dd_wdd_rec_om%ISOPEN THEN
      CLOSE dd_wdd_rec_om;
    END IF;
    IF c_get_attr_msn%ISOPEN THEN
      CLOSE c_get_attr_msn;
    END IF;
    IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| substr(SQLERRM,1,200),WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wsh_util_core.default_handler('WSH_SHIP_CONFIRM_ACTIONS.TRANSFER_SERIAL_NUMBERS_PVT');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END transfer_serial_numbers_pvt;

--========================================================================
-- PROCEDURE : transfer_serial_numbers
--             Wrapper API for Transfer_Serial_Numbers_pvt
--
-- PARAMETERS: p_batch_id              The batch id of trip stops being
--                                     interfaced.
--             p_interfacing           if this procedure is called during OM
--                                     interface value 'OM' is passed, otherwise
--                                     value 'INV' is passed.
--             x_return_status         return status of the API.
--
-- COMMENT   : This procedure is used to transfer the serial number information
--             from mtl_serial_numbers_temp to the wsh_serial_numbers table.
--             It then deletes these entries from mtl_serial_numbers_temp.
--             IF this procedure is called during the INV interface then only
--             the lines that have been interfaced to OM are processed, else
--             the non-oe lines are processed as well.
--========================================================================
PROCEDURE transfer_serial_numbers (
            p_batch_id       IN  NUMBER,
            p_interfacing    IN VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2) IS

--
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRANSFER_SERIAL_NUMBERS';
--

BEGIN
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
       WSH_DEBUG_SV.log(l_module_name,'p_interfacing',p_interfacing);
   END IF;
   --

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Call transfer_serial_numbers_pvt

  -- Case I : Serial Records where 'From Serial Number' <> 'To Serial Number'
  --          and records exist in MSNT
  -- Case II : Serial Records where 'From Serial Number' = 'To Serial Number'
  --            or 'To Serial Number' is Null and records exist in MSNT
  -- Combined, since records exist in MSNT
  transfer_serial_numbers_pvt(
                               p_transfer_param  => 'MSNT',
                               p_batch_id        => p_batch_id,
                               p_interfacing     => p_interfacing,
                               x_return_status   => x_return_status );

  -- Case III : 'Serial Number' is present in wsh_delivery_details
  transfer_serial_numbers_pvt(
                               p_transfer_param  => 'WDD',
                               p_batch_id        => p_batch_id,
                               p_interfacing     => p_interfacing,
                               x_return_status   => x_return_status );

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| substr(SQLERRM,1,200),WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    wsh_util_core.default_handler('WSH_SHIP_CONFIRM_ACTIONS.TRANSFER_SERIAL_NUMBERS');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END transfer_serial_numbers;

-- End of Changes for creating wrapper and new API transfer_serial_numbers_pvt

--
--Procedure:     Ship_Confirm_A_Trip_Stop
--Parameters:    p_stop_id,
--        x_return_status
--Description:  This procedure will ship confirm the whole trip stop.
--       It submits the inventory interface program -- inv_interface

PROCEDURE Ship_Confirm_A_Trip_Stop(p_stop_id number,
                 x_return_status out NOCOPY  varchar2) is
l_status1 varchar2(30);
l_status2 varchar2(30);
inv_inter_req_submission exception;
request_id number;
msg varchar2(2000);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SHIP_CONFIRM_A_TRIP_STOP';
--
l_log_level	NUMBER :=0;
begin
   --
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
       --
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'Submitting the request');
       l_log_level := 1;
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   -- bug 2308504: make sure to pass all parameters expected,
   --    so that code output will go into the log file.
   request_id := FND_REQUEST.submit_Request('WSH', 'WSHINTERFACE', '', '', FALSE,
                  'ALL',      -- mode
                                                p_stop_id,  -- stop
                                                '',         -- delivery
                                                l_log_level);       -- log level
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'request_id',request_id);
   END IF;
   if  (request_id = 0) THEN
     raise inv_inter_req_submission;
   else
     FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_INV_INT_SUBMITTED');
     FND_MESSAGE.SET_TOKEN('REQ_ID', to_char(request_id));
     WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
   END if;

   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   exception
     WHEN inv_inter_req_submission THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       fnd_message.set_name('WSH', 'WSH_DET_INV_INT_REQ_SUBMISSION');
       WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'INV_INTER_REQ_SUBMISSION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INV_INTER_REQ_SUBMISSION');
      END IF;
      --
      WHEN others THEN
       wsh_util_core.default_handler('WSH_SHIP_CONFRIM_ACTIONS.SHIP_CONFIRM_A_TRIP_STOP',l_module_name);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
END Ship_Confirm_A_Trip_Stop;


-- start bug 1578251: internal procedure to manage completion_status
--========================================================================
-- PROCEDURE : Update_Completion_Status
--                  Internal procedure to manage completion_status for ITS
--
-- PARAMETERS: p_num_stops             Number of the stops which are processed
--                                     by the calling API
--             p_batch_id              The batch id of trip stops being
--                                     interfaced.
--             x_master_status         The ITS status for current run
--             p_api_status            The status of the calling API
--             x_normal_count          Number of stops interfaced with NORMAL
--             x_warning_count         Number of stops interfaced with WARNING
--             x_interfaced_count      Number of stops interfaced with
--                                     INTERFACED status.
--             x_return_status         return status of the API.

-- COMMENT   : This procedure is called after each interface (OM,DSNO,INV)
--             It sets an overall return status for the ITS current run and also
--             keeps track of the completion status and number of stops
--             processed for each interface.
--             The possible values for the status processed by this API are:
--             NORMAL :     the interface completed normal
--             INTERFACED : the interface completed in INTERFACED status
--             WARNING :    There are some problems, but the ITS will not stop
--             ERROR:       There are problems preventing the ITS to complete.
--========================================================================

procedure Update_Completion_Status(p_num_stops IN NUMBER,
                           p_batch_id  IN NUMBER,
                           x_master_status IN OUT NOCOPY  VARCHAR2,
                           p_api_status      IN OUT NOCOPY  VARCHAR2,
                           x_normal_count  IN OUT NOCOPY  NUMBER,
                           x_warning_count   IN OUT NOCOPY  NUMBER,
                           x_interfaced_count IN OUT NOCOPY  NUMBER
               ) IS
               --
l_debug_on BOOLEAN;
               --
               l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_COMPLETION_STATUS';

               l_stops_in_batch      NUMBER;
               --
               CURSOR c_get_num_stops(p_batch_id NUMBER) IS
               SELECT count(*)
               FROM wsh_trip_stops
               WHERE batch_id = p_batch_id;
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
     IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
         --
         WSH_DEBUG_SV.log(l_module_name,'p_num_stops',p_num_stops);
         WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
         WSH_DEBUG_SV.log(l_module_name,'X_MASTER_STATUS',X_MASTER_STATUS);
         WSH_DEBUG_SV.log(l_module_name,'P_API_STATUS',P_API_STATUS);
         WSH_DEBUG_SV.log(l_module_name,'X_NORMAL_COUNT',X_NORMAL_COUNT);
         WSH_DEBUG_SV.log(l_module_name,'X_WARNING_COUNT',X_WARNING_COUNT);
         WSH_DEBUG_SV.log(l_module_name,'X_INTERFACED_COUNT',X_INTERFACED_COUNT);
     END IF;
     --
     IF p_num_stops IS NOT NULL THEN
        l_stops_in_batch := p_num_stops;
     ELSE
        OPEN c_get_num_stops(p_batch_id);
        FETCH c_get_num_stops INTO l_stops_in_batch;
        CLOSE c_get_num_stops;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_stops_in_batch',l_stops_in_batch);
        END IF;
     END IF;

     IF  p_api_status = 'NORMAL'  THEN
      x_normal_count := x_normal_count + l_stops_in_batch;
     ELSIF p_api_status = 'INTERFACED' THEN
      x_interfaced_count := x_interfaced_count + l_stops_in_batch;
     ELSIF p_api_status = 'WARNING' THEN
      x_warning_count := x_warning_count + l_stops_in_batch;
      IF x_master_status = 'NORMAL' THEN
        x_master_status := p_api_status;
      END IF;
     ELSIF p_api_status = 'ERROR' THEN
      IF x_master_status IN ('NORMAL', 'WARNING' ) THEN
        x_master_status := p_api_status;
      END IF;
     ELSE
        -- unknown status...
        WSH_UTIL_CORE.PrintMsg('ERROR: unknown status = '''
                         || p_api_status || '''');
        x_master_status := 'ERROR';
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'X_MASTER_STATUS',X_MASTER_STATUS);
         WSH_DEBUG_SV.log(l_module_name,'P_API_STATUS',P_API_STATUS);
         WSH_DEBUG_SV.log(l_module_name,'X_NORMAL_COUNT',X_NORMAL_COUNT);
         WSH_DEBUG_SV.log(l_module_name,'X_WARNING_COUNT',X_WARNING_COUNT);
         WSH_DEBUG_SV.log(l_module_name,'X_INTERFACED_COUNT',X_INTERFACED_COUNT);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
END Update_Completion_Status;
-- end bug 1578251: internal procedure to manage completion_status




--========================================================================
-- PROCEDURE : handle_stop_lvl_splits
--                  This procedure determines if all the trip stops within a
--                  batch can be processed together, if not, it removes the
--                  violating trip stops from the batch
--
-- PARAMETERS: x_split_stops           trip stops that are removed from the
--                                     batch
--             p_batch_id              The batch id of trip stops being
--                                     interfaced.
--             x_stop_tab              The trip stops associated with the batch
--             x_return_status         return status of the API.

-- COMMENT   : If two delivery details have the same SOURCE_LINE_ID and are
--             associated with 2 different pick up trip stops, then these 2
--             trip stops cannot be processed in the same batch (problem in
--             OM interface).  The first trip stop will be removed from
--             the batch and will be put in x_split_stops.
--             This is the flow for this API :
--             If table x_split_stops has some rows from earlier run, this
--             means that some stops were extracted from previous batch, so
--             the API will mark these stops with the current batch. then it
--             determines if there are stops in the new batch that cannot be
--             processed together.  If, for example, there are 3 stops that
--             cannot be processed together then stop 1 and 2 will be removed
--             from the batch.  Table x_split_stops will contain stop 1 and 2
--             table x_stop_tab will contain stop 3 and any other remaining
--             stop left in the batch.
--
--========================================================================

PROCEDURE handle_stop_lvl_splits(
                        x_split_stops IN OUT NOCOPY wsh_util_core.id_tab_type,
                        p_batch_id    IN NUMBER,
                        x_stop_tab    IN OUT NOCOPY wsh_util_core.id_tab_type,
                        x_return_status OUT NOCOPY VARCHAR2)
IS
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
    'handle_stop_lvl_splits';

   x  NUMBER;
   j  NUMBER;
   i  NUMBER;
   l_last NUMBER;
   z  NUMBER := 1;
   l_found BOOLEAN;

   l_new_split_stops       wsh_util_core.id_tab_type;
   l_stop_tab              wsh_util_core.id_tab_type;


   CURSOR get_stops(p_batch_id NUMBER) is
   SELECT DISTINCT wts.stop_id
   FROM wsh_trip_stops wts,
   wsh_trip_stops wts2,
   wsh_delivery_legs wdl,
   wsh_delivery_legs wdl2,
   wsh_delivery_assignments_v wda,
   wsh_delivery_assignments_v wda2,
   wsh_delivery_details wdd,
   wsh_delivery_details wdd2
   WHERE wts.batch_id = p_batch_id
   AND wts.stop_id = wdl.pick_up_stop_id
   AND wda.delivery_id = wdl.delivery_id
   AND wda.delivery_detail_id = wdd.delivery_detail_id
   AND wdd.source_code = 'OE'
   AND nvl(wdd.oe_interfaced_flag,'N') <> 'Y'
   AND wdd.released_status <> 'D'
   AND wts2.batch_id = p_batch_id
   AND wts2.stop_id = wdl2.pick_up_stop_id
   AND wda2.delivery_id = wdl2.delivery_id
   AND wda2.delivery_detail_id = wdd2.delivery_detail_id
   AND wdd2.source_line_id = wdd.source_line_id
   AND wdd2.source_code = 'OE'
   AND nvl(wdd2.oe_interfaced_flag,'N') <> 'Y'
   AND wdd2.released_status <> 'D'
   AND wts2.stop_id <> wts.stop_id;


BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'x_split_stops.count',
                                                          x_split_stops.COUNT);
       WSH_DEBUG_SV.log(l_module_name,'x_stop_tab.count', x_stop_tab.COUNT);
       WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_stop_tab := x_stop_tab;
   x_stop_tab.DELETE;

   x := x_split_stops.FIRST;
   WHILE x IS NOT NULL LOOP --{
      --
      -- if there are some stops removed from previous batch then add them to
      -- the current batch also add these stops to the x_stop_tab( first add
      -- them to l_stop_tab)
      --
      UPDATE wsh_trip_stops
      SET batch_id  = p_batch_id
      WHERE stop_id = x_split_stops(x);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Adding stop',x_split_stops(x));
      END IF;

      -- add the left over stops from previuos batch to current stops
      l_stop_tab(l_stop_tab.COUNT + 1) := x_split_stops(x);
      x:= x_split_stops.NEXT(x);
   END LOOP; --}

   x_split_stops.DELETE;

   -- get all the stops that cannot be processed in one batch
   OPEN get_stops(p_batch_id);
   FETCH get_stops BULK COLLECT INTO x_split_stops ;
   CLOSE get_stops;

   IF x_split_stops.COUNT > 1 THEN --{

      x := l_stop_tab.FIRST;
      --
      -- Remove all the stops in x_split_stops (except the last row) from
      -- the batch and put the remaining stops in x_stop_tab.  Remove the
      -- last row of x_split_stops, this stop will be processed with the batch
      --
      l_last := x_split_stops.count - 1;

      WHILE x IS NOT NULL LOOP --{

         l_found := FALSE;
         FOR i IN 1..l_last LOOP --{

            IF l_stop_tab(x) = x_split_stops(i) THEN --{
               l_found := TRUE;
               EXIT;
            END IF ; --}
         END LOOP; --}

         IF l_found THEN --{
               UPDATE wsh_trip_stops
               SET batch_id = NULL
               WHERE stop_id =  l_stop_tab(x)
               AND batch_id = p_batch_id;

               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'removing  stop',
                                                              l_stop_tab(x));
               END IF;

         ELSE --}{
               x_stop_tab(z) := l_stop_tab(x);
               z := z + 1;
         END IF; --}
         x := l_stop_tab.NEXT(x);
      END LOOP; --}
      -- do not remove the last stop
      x_split_stops.DELETE(x_split_stops.LAST);
   ELSE --}{
      x_stop_tab := l_stop_tab;
   END IF;--}


   IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'x_split_stops.count',
                                                        x_split_stops.COUNT);
         WSH_DEBUG_SV.log(l_module_name,'x_stop_tab.count',x_stop_tab.COUNT);
         WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END handle_stop_lvl_splits;



-- start bug 1578251: Interface_ALL to batch process the stops
--========================================================================
-- PROCEDURE : interface_ALL
--                  This procedure is used to interface trip stops for the mode
--                  selected by parameter p_mode.  This procedure is called from
--                  the wrapper of concurrent program "Interface Trip Stops SRS"
--                  (interface_all_wrp) to perform the single thread
--                  interfacing.
--
-- PARAMETERS: errbuf                  Used by the concurrent program for error
--                                     messages.
--             retcode                 Used by the concurrent program for return
--                                     code.
--             p_stop_id               Stop id to be interfaced.
--             p_delivery_id           Delivery id to be interfaced.
--             p_log_level             value 1 turns on the debug.
--             p_batch_id              ship confirm batch used by concurrent
--                                     program "Ship Confirm Deliveries SRS"
--             p_trip_type             Used by concurrent program "Ship Confirm
--                                     Deliveries SRS".
--             p_organization_id       If p_stop_id and p_delivery_id are left
--                                     blank use this parameter to interface all
--                                     the stops within this organization.
--             p_stops_per_batch       Indicates the number of stops that can be
--                                     marked by a batch and processed together.

-- COMMENT   : This API is called from the ITS wrapper (interface_all_wrp) to
--             perform a single thread interface of trip stops to OM, DSNO and
--             INV (depending on the value given by p_mode.)  It loops through
--             all eligible trip stops, marks as many as it is indicated by
--             parameter p_stops_per_batch with a batch_id and performs the 3
--             interfaces.
--             First, it interfaces all the trip stops within the batch to OM.
--             If some stops fails to interface to OM, filter these stops out.]
--             Run the DSNO interface for the remaining stops.  If some stops
--             fail in DSNO interface, remove them from the batch.  Run the
--             inventory interface for the remaining stops.
--             Note that if all stops failed during an interface, it does not
--             make sense to remove all of them from the batch.  The API, simply
--             will not perform the remaining interfaces.
--             If the overal API status is not ERROR, then start with the next
--             batch and processed the 3 interfaces.
--
--========================================================================

procedure interface_ALL(errbuf      OUT NOCOPY  VARCHAR2,
                  retcode     OUT NOCOPY  VARCHAR2,
                  p_mode      IN  VARCHAR2,
                  p_stop_id    IN  NUMBER,
                  p_delivery_id IN  NUMBER,
                  p_log_level   IN  NUMBER,
                  p_batch_id NUMBER DEFAULT NULL,
                  p_trip_type IN VARCHAR2 DEFAULT NULL,
                  p_organization_id IN NUMBER DEFAULT NULL,
                  p_stops_per_batch IN NUMBER DEFAULT NULL) IS

  c_stop_separator     CONSTANT VARCHAR2(100) :=
  '========================================================================';
  c_interface_separator CONSTANT VARCHAR2(100) :=
  '------------------------------------------------------------------------';

  l_stop_id          NUMBER;
  l_found            BOOLEAN := FALSE;
  l_errors           NUMBER;
  l_warn             NUMBER;

  l_interface_mode       VARCHAR2(80);
  l_completion_status     VARCHAR2(30);
  l_api_completion_status  VARCHAR2(30);

  request_id           NUMBER;
  l_error_code       NUMBER;
  l_error_text       VARCHAR2(2000);
  l_temp            BOOLEAN;
  l_stops_count         NUMBER := 0;
  l_interface_names     WSH_UTIL_CORE.Column_Tab_Type;
  l_stops_normal       WSH_UTIL_CORE.Id_Tab_Type;
  l_stops_warning     WSH_UTIL_CORE.Id_Tab_Type;
  l_stops_interfaced   WSH_UTIL_CORE.Id_Tab_Type;
  l_err_stops         WSH_UTIL_CORE.Id_Tab_Type;

  l_inv_interface   NUMBER := 0;
  l_om_interface    NUMBER := 0;
  l_dsno_interface     NUMBER := 0;
  i                  NUMBER;

  l_previous_interface  BOOLEAN;
  l_run_dsno            BOOLEAN;
  l_oke_count           NUMBER := 0;
  l_stops_per_batch     NUMBER;
  l_stop_per_batch_counter NUMBER := 1;
  l_batch_ready         BOOLEAN := FALSE;
  l_stop_batch_id       NUMBER;
   -- Stops that will be used for DSNO interface are put in  l_dsno_stop_tab.
  l_dsno_stop_tab       wsh_util_core.id_Tab_type;
   -- The stops being processed for OM interface are stored in l_stop_tab
  l_stop_tab            wsh_util_core.id_Tab_type;
  l_tab_count           NUMBER;
  l_err_stops_count     NUMBER;
  l_completion_status_bkp VARCHAR2(30);
  l_stop_count          NUMBER := 0;
  l_api_completion_status_bkp VARCHAR2(30);
  l_return_status       VARCHAR2(10);
  l_inv_batch_table     WSH_UTIL_CORE.Id_Tab_Type;
  l_index               number;
  x                     NUMBER;
  l_num_warnings        NUMBER := 0;
  l_num_errors          NUMBER := 0;
  l_invoicing_method    VARCHAR2(100);
  -- stops that are processed for INV interface are put in l_inv_stops.
  l_inv_stops           wsh_util_core.id_tab_type;
  l_split_stops         wsh_util_core.id_tab_type;

  -- bug 2657859 frontport bug 2630535: avoid deadlocks
  CURSOR lock_row ( p_stop_id in  NUMBER, p_flag in VARCHAR2 ) IS
  SELECT stop_id
  FROM wsh_trip_stops
  WHERE stop_id = p_stop_id
  AND   pending_interface_flag = p_flag
  FOR UPDATE NOWAIT;

  CURSOR lock_batch ( p_batch_id in  NUMBER, p_flag in VARCHAR2 ) IS
  SELECT stop_id
  FROM wsh_trip_stops
  WHERE batch_id = p_batch_id
  AND   pending_interface_flag = p_flag
  FOR UPDATE NOWAIT;

  l_recinfo lock_row%ROWTYPE;
  l_batchinfo lock_batch%ROWTYPE;

  trip_stop_locked exception  ;
  PRAGMA EXCEPTION_INIT(trip_stop_locked, -54);


  -- Lookup stop for this delivery
  CURSOR c_delivery_stop(p_delivery_id NUMBER) IS
   SELECT wts.stop_id
   FROM   wsh_trip_stops    wts,
         wsh_delivery_legs  wdl,
         wsh_new_deliveries wnd
   WHERE  wnd.delivery_id    = p_delivery_id
   AND   wdl.delivery_id     = wnd.delivery_id
   AND   wts.stop_id      = wdl.pick_up_stop_id
   AND   wts.stop_location_id = wnd.initial_pickup_location_id;

  -- bug 3642085
  -- Find closed stops that have pick up deliveries with lines to interface
  CURSOR c_stop_to_interface(p_trip_stop_id NUMBER) IS
   SELECT wts.stop_id
   FROM   wsh_trip_stops wts
   WHERE  wts.stop_id = p_trip_stop_id
   AND   wts.pending_interface_flag = 'Y'
   AND   nvl(wts.SHIPMENTS_TYPE_FLAG, 'O') IN  ('O', 'M');

  -- Find closed stops that have pick up deliveries with lines to interface
  CURSOR c_all_elig_stops_to_interface IS
   SELECT wts.stop_id
   FROM   wsh_trip_stops wts
   WHERE  wts.pending_interface_flag = 'Y'
   AND    nvl(wts.SHIPMENTS_TYPE_FLAG, 'O') IN  ('O', 'M')  -- J Inbound Logistics jckwok
   ORDER BY DECODE(wts.lock_stop_id, wts.stop_id, 1, NULL, 2, 3);
  -- bug 3642085

  -- Find closed stops that have pick up deliveries with lines to interface
  -- for a given organization
  CURSOR c_stops_org(p_organization_id NUMBER) IS
   SELECT DISTINCT wts.stop_id
   FROM   wsh_trip_stops wts,
          wsh_new_deliveries wnd,
          wsh_delivery_legs wdl
   WHERE   wts.pending_interface_flag = 'Y'
   AND   wdl.pick_up_stop_id = wts.stop_id
   AND   wnd.initial_pickup_location_id = wts.stop_location_id
   AND   wdl.delivery_id     = wnd.delivery_id
   AND   nvl(wts.SHIPMENTS_TYPE_FLAG, 'O') IN  ('O', 'M')
   AND   wnd.organization_id = p_organization_id
   ORDER BY  wts.stop_id;


  CURSOR c_batch_stop(p_batch_id NUMBER, p_trip_type VARCHAR2)IS
    SELECT wts.stop_id
    FROM   wsh_trip_stops    wts,
          wsh_delivery_legs  wdl,
          wsh_new_deliveries wnd,
          wsh_picking_batches wpb
    WHERE p_batch_id IS NOT NULL
    AND   wnd.batch_id    = p_batch_id
    AND   wdl.delivery_id     = wnd.delivery_id
    AND   wts.stop_id      = wdl.pick_up_stop_id
    AND   wts.stop_location_id = wnd.initial_pickup_location_id
    AND   wpb.batch_id = wnd.batch_id
    AND   (p_trip_type IS NULL OR
          (p_trip_type = 'AC' AND wpb.creation_date <= wts.creation_date) OR
          (p_trip_type = 'MC' AND wpb.creation_date > wts.creation_date))
    AND   nvl(wnd.SHIPMENT_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
    ORDER BY DECODE(wts.lock_stop_id, wts.stop_id,1,
                NULL,2,3);

CURSOR pickup_oke_headers (p_stop_id in number) IS
SELECT 1
FROM   wsh_delivery_legs dg,
      wsh_new_deliveries dl,
      wsh_trip_stops st
WHERE  st.stop_id = dg.pick_up_stop_id AND
       nvl(dl.SHIPMENT_DIRECTION , 'O') IN ('O', 'IO') AND  -- J Inbound Logistics jckwok
      st.stop_id = p_stop_id AND
      st.stop_location_id = dl.initial_pickup_location_id AND
      dg.delivery_id = dl.delivery_id  AND
	   dl.asn_seq_number is not null
	   and rownum=1;


CURSOR c_get_batch IS
SELECT WSH_STOP_BATCH_S.NEXTVAL
FROM sys.dual;

--/== Workflow Changes
CURSOR  c_stop_to_del_cur_wf( p_stop_id IN NUMBER ) IS
SELECT  wnd.delivery_id,
	wnd.organization_id,
	wnd.initial_pickup_location_id,
	wnd.delivery_scpod_wf_process,
	wnd.del_wf_interface_attr
FROM    wsh_new_deliveries wnd,
	wsh_delivery_legs wdl,
	wsh_trip_stops wts
WHERE   wnd.delivery_id = wdl.delivery_id
AND     wdl.pick_up_stop_id = p_stop_id
AND     wts.stop_id      = wdl.pick_up_stop_id
AND     wts.stop_location_id = wnd.initial_pickup_location_id;

l_del_entity_ids WSH_UTIL_CORE.column_tab_type;
l_wf_rs        VARCHAR2(1);
l_override_wf  VARCHAR2(1);
l_purged_count NUMBER;
e_trip_stop_wf_inprogress EXCEPTION;
-- Workflow Changes ==/

l_standalone VARCHAR2(1); --Standalone WMS project changes

e_continue  EXCEPTION;
--bsadri


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INTERFACE_ALL';
--
BEGIN
  --
  WSH_UTIL_CORE.Enable_Concurrent_Log_Print;
  WSH_UTIL_CORE.Set_Log_Level(p_log_level);
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
      --
      WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_LOG_LEVEL',P_LOG_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'p_organization_id',p_organization_id);
      WSH_DEBUG_SV.log(l_module_name,'p_stops_per_batch',p_stops_per_batch);
  END IF;

  --
  l_completion_status := 'NORMAL';

  -- If stop_id is given use this to query the stop, else if delivery_id is
  -- given use the delivery_id to query the stop.

  IF p_stops_per_batch IS NULL or p_stops_per_batch = 0 THEN
     l_stops_per_batch := 1;
  ELSIF p_stops_per_batch < 0 THEN
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Error negative p_stops_per_batch',
                                                          p_stops_per_batch );
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
     l_stops_per_batch := p_stops_per_batch;
  END IF;


  IF l_stops_per_batch > 1 THEN --{
     FND_PROFILE.Get('WSH_INVOICE_NUMBERING_METHOD',l_invoicing_method);

     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_invoicing_method',
                                                        l_invoicing_method );
     END IF;

     IF l_invoicing_method = 'D' THEN
        l_stops_per_batch := 1;
     END IF;

  END IF; --}

  --Standalone WMS project changes
  IF WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'D' THEN
    l_standalone := 'Y';
  ELSE
    l_standalone := 'N';
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_standalone',l_standalone );
  END IF;

  IF p_mode <> 'ALL' THEN
   l_interface_mode := p_mode;
  ELSE
   l_interface_mode := 'INV OM DSNO';
  END IF;

  IF l_standalone = 'Y' THEN  --Standalone WMS project changes
    l_interface_mode := 'INV DSNO';
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  'Standalone is enabled only INV and DSNO will be run');
    END IF;
  END IF;



  IF p_delivery_id IS NULL THEN
   l_stop_id := p_stop_id;
  ELSE
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  'INTERFACETRIPSTOP: FINDING STOP FOR DELIVERY_ID ' || P_DELIVERY_ID  );
   END IF;
   --
   OPEN  c_delivery_stop(p_delivery_id);
   FETCH c_delivery_stop INTO l_stop_id;
   IF c_delivery_stop%NOTFOUND THEN
     l_stop_id := NULL;
   END IF;
   CLOSE c_delivery_stop;
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_stop_id',l_stop_id);
   END IF;
   IF l_stop_id IS NULL THEN
     WSH_UTIL_CORE.PrintMsg('InterfaceTripStop: cannot find stop.  Exiting.');
     l_completion_status := 'WARNING';
     goto interface_end;
   END IF;
  END IF;


  IF l_stop_id IS NULL THEN
   WSH_UTIL_CORE.PrintMsg('InterfaceTripStop: processing all eligible stops for '
                    || l_interface_mode);
  ELSE
   WSH_UTIL_CORE.PrintMsg('InterfaceTripStop: processing stop_id '
                    || TO_CHAR(l_stop_id)
                    || ' for ' || l_interface_mode);
  END IF;

  -- Interface Flip: do OM/DSNO before INV

  l_interface_names(1) := 'ORDER MANAGEMENT';
  l_interface_names(2) := 'DSNO';
  l_interface_names(3) := 'INVENTORY';
  FOR i IN 1..l_interface_names.COUNT LOOP
   l_stops_normal(i)  := 0;
   l_stops_warning(i)   := 0;
   l_stops_interfaced(i) := 0;
  END LOOP;


  IF INSTR(l_interface_mode, 'INV') > 0 THEN
   l_inv_interface := 1;
  END IF;

  IF INSTR(l_interface_mode, 'OM') > 0 THEN
   l_om_interface := 1;
  END IF;

  IF INSTR(l_interface_mode, 'DSNO') > 0 THEN
   l_dsno_interface := 1;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'l_inv_interface',l_inv_interface);
     WSH_DEBUG_SV.log(l_module_name,'l_om_interface',l_om_interface);
     WSH_DEBUG_SV.log(l_module_name,'l_dsno_interface',l_dsno_interface);
     WSH_DEBUG_SV.log(l_module_name,'l_interface_mode',l_interface_mode);
     WSH_DEBUG_SV.log(l_module_name,'l_stop_id',l_stop_id);
  END IF;

  -- Based on input criteria open one of these cursors to query for the
  -- eligible trip stops.
  --

  IF p_batch_id is not null then
     open c_batch_stop(p_batch_id, p_trip_type);
  ELSIF (l_stop_id IS NULL) AND (p_organization_id is not null) THEN
     OPEN c_stops_org(p_organization_id);
  -- bug 3642085
  ELSIF l_stop_id is not null then
     open c_stop_to_interface(l_stop_id);
  ELSE
     open c_all_elig_stops_to_interface;
  -- bug 3642085
  END IF;

  LOOP --{
  BEGIN

    IF c_batch_stop%isopen THEN --{
      FETCH c_batch_stop into l_stop_id;
      IF c_batch_stop%NOTFOUND  THEN
         IF l_stop_per_batch_counter = 1 AND l_split_stops.COUNT = 0 THEN
            EXIT;
         ELSE
            l_batch_ready := TRUE;
            -- This is the case, where there are no more stops to be processed,
            --  but the the number of stops per batch is not satisfied.
            -- We mark the batch as ready, to process the remaining stops.
         END IF;
      END IF;
    -- bug 3642085
    ELSIF c_stop_to_interface%isopen THEN --}{
      FETCH c_stop_to_interface into l_stop_id;
      IF c_stop_to_interface%NOTFOUND  THEN
         IF l_stop_per_batch_counter = 1 AND l_split_stops.COUNT = 0 THEN
            EXIT;
         ELSE
            l_batch_ready := TRUE;
            -- This is the case, where there are no more stops to be processed,
            --  but the the number of stops per batch is not satisfied.
            -- We mark the batch as ready, to process the remaining stops.
         END IF;
       END IF;
    ELSIF c_all_elig_stops_to_interface%isopen THEN --}{
      FETCH c_all_elig_stops_to_interface into l_stop_id;
      IF c_all_elig_stops_to_interface%NOTFOUND  THEN
         IF l_stop_per_batch_counter = 1 AND l_split_stops.COUNT = 0 THEN
            EXIT;
         ELSE
            l_batch_ready := TRUE;
            -- This is the case, where there are no more stops to be processed,
            --  but the the number of stops per batch is not satisfied.
            -- We mark the batch as ready, to process the remaining stops.
         END IF;
       END IF;
    -- bug 3642085
    ELSIF c_stops_org%isopen THEN --}{
      FETCH c_stops_org into l_stop_id;
      IF c_stops_org%NOTFOUND  THEN
         IF l_stop_per_batch_counter = 1 AND l_split_stops.COUNT = 0 THEN
            EXIT;
         ELSE
            l_batch_ready := TRUE;
            -- This is the case, where there are no more stops to be processed,
            --  but the the number of stops per batch is not satisfied.
            -- We mark the batch as ready, to process the remaining stops.
         END IF;
       END IF; --}
    END IF;

    --/== Workflow Changes
    l_override_wf:= fnd_profile.value('WSH_OVERRIDE_SCPOD_WF');
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_override_wf',l_override_wf);
    END IF;

    IF (nvl(l_override_wf,'N') = 'N') THEN
        FOR cur_rec IN c_stop_to_del_cur_wf(l_stop_id) LOOP
	    IF (cur_rec.delivery_scpod_wf_process is not null and
			cur_rec.del_wf_interface_attr  = 'I') THEN
                l_completion_status := 'WARNING';
		RAISE e_trip_stop_wf_inprogress;
	    END IF;
	END LOOP;
    ELSE
    -- Override the Ship to Deliver Workflow
        FOR cur_rec IN c_stop_to_del_cur_wf(l_stop_id) LOOP
	    IF (WSH_WF_STD.Wf_Exists('DELIVERY_C',cur_rec.delivery_id)) THEN
		l_del_entity_ids(l_del_entity_ids.count +1) := cur_rec.delivery_id;
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.Log_Wf_Exception', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		WSH_WF_STD.Log_Wf_Exception(p_entity_type => 'DELIVERY',
				p_entity_id             => cur_rec.delivery_id,
				p_ship_from_location_id => cur_rec.initial_pickup_location_id,
				p_logging_entity        => 'SHIPPER',
				p_exception_name        => 'WSH_DEL_SCPOD_PURGED',
				x_return_status         => l_wf_rs);
		IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.Log_Wf_Exception',l_wf_rs);
		END IF;
	    END IF;
	END LOOP;
    END IF;

    -- Purging Overridden Workflows after the loop
    IF (l_del_entity_ids.count > 0) THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.PURGE_ENTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        WSH_WF_STD.Purge_Entity(
		p_entity_type => 'DELIVERY',
		p_entity_ids  => l_del_entity_ids,
		x_success_count  => l_purged_count,
		x_return_status => l_wf_rs);
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'L_PURGED_COUNT',l_purged_count);
	    WSH_DEBUG_SV.log(l_module_name,'L_WF_RS',l_wf_rs);
        END IF;
    END IF;
    -- Workflow Changes ==/

    -- Get the new batch_id for the stops (wsh_trip_stops.batch_id)
    IF l_stop_per_batch_counter = 1 THEN
       l_dsno_stop_tab.DELETE;
       l_stop_tab.DELETE;
       OPEN c_get_batch;
       FETCH c_get_batch INTO l_stop_batch_id;
       CLOSE c_get_batch;
    END IF;

   -- bug 2657859 frontport bug 2630535
   -- avoid deadlocks by marking stop as being processed:
   -- skip stops if their interface_flag is NULL or 'P'.
   DECLARE
      l_notfound BOOLEAN;
      l_action   VARCHAR2(100);
   BEGIN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                    'setting savepoint before_flag_change');
      END IF;

      SAVEPOINT before_flag_change;

      IF NOT l_batch_ready THEN --{
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,
                       'locking row for ' || l_stop_id);
         END IF;

         l_action := 'locking';
         OPEN   lock_row(l_stop_id, 'Y');
         FETCH  lock_row into l_recinfo;
         l_notfound := lock_row%NOTFOUND;
         CLOSE  lock_row;

         l_action := 'examining';

         IF l_notfound THEN
           -- probably taken care of by another request
           --COMMIT;
           GOTO next_stop;
         END IF;


         l_action := 'updating';

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,
             'updating pending_interface_flag to P for batch', l_stop_batch_id);
         END IF;


         -- mark stop as being processed; refresh its LAST_UPDATED info.
         UPDATE wsh_trip_stops
         SET    pending_interface_flag = 'P',
             request_id             = fnd_global.conc_request_id,
             last_updated_by        = fnd_global.user_id,
             last_update_date       = sysdate,
             batch_id               = l_stop_batch_id
         WHERE  stop_id = l_stop_id;

         l_stop_tab(l_stop_tab.COUNT+1) := l_stop_id;

         l_stops_count        := l_stops_count + 1;


         -- If the batch is not full, then get another stop.

         IF l_stop_per_batch_counter < l_stops_per_batch THEN
            l_stop_per_batch_counter := l_stop_per_batch_counter + 1;
            RAISE e_continue;
         END IF;

      END IF; --}

      IF (l_stops_per_batch > 1  )
          AND (l_stop_tab.COUNT > 1 OR l_split_stops.COUNT > 0) THEN   --{
         -- If some stops within this batch have lines split in WSH and
         -- these lines are in multiple stops, do not process these stops
         -- together
         handle_stop_lvl_splits(x_split_stops => l_split_stops,
                                p_batch_id    => l_stop_batch_id,
                                x_stop_tab    => l_stop_tab,
                                x_return_status => l_return_status);

          wsh_util_core.api_post_call(
            p_return_status    => l_return_status,
            x_num_warnings     => l_num_warnings,
            x_num_errors       => l_num_errors);

      END IF; --}

      COMMIT;
      l_stop_per_batch_counter := 1; --initialize for the next batch

   EXCEPTION
    WHEN trip_stop_locked THEN
       -- stop is locked; probably used by another process
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,
                    'stop is locked');
       END IF;
       WSH_UTIL_CORE.Println('Interface_All: skipping locked stop_id ' || l_stop_id || ' is locked.');
       IF lock_row%ISOPEN THEN
         CLOSE lock_row;
       END IF;
       --IF l_debug_on THEN
         --WSH_DEBUG_SV.log(l_module_name,
                    --'rollback to before_flag_change');
       --END IF;
       -- rollback to before_flag_change;
       -- why do we need rollback? nothing is updated
       --GOTO next_stop;
       RAISE e_continue;

    WHEN e_continue THEN
       RAISE e_continue;

    WHEN OTHERS THEN
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,
                    'unhandled exception for action ' || l_action);
       END IF;

       l_completion_status := 'ERROR';
       l_error_code     := SQLCODE;
       l_error_text     := SQLERRM;
       WSH_UTIL_CORE.PrintMsg('Interface_ALL failed with unexpected error in ' || l_action || ' ' || l_stop_id);
       WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
       l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
       errbuf := 'Interface trip stop failed with unexpected error';
       retcode := '2';
       IF lock_row%ISOPEN THEN
         CLOSE lock_row;
       END IF;
       rollback to before_flag_change;
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       RETURN;
   END;


   l_api_completion_status := 'NORMAL';
   l_previous_interface  := FALSE;

   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  C_STOP_SEPARATOR  );
   END IF;
   --

   -- The stops being processed for OM interface are stored in l_stop_tab
   -- the stops that are successfully processed will be stoped in
   -- l_dsno_stop_tab.  The stops that will be processed for inventory interface
   -- will be put in l_inv_stops.  Stops that cannot be processed in the current
   -- batch are put in l_split_stops.

   -- OM Interface
   IF   l_om_interface = 1
      AND l_api_completion_status = 'NORMAL' THEN --{

     IF l_previous_interface THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  C_INTERFACE_SEPARATOR  );
      END IF;
      --
     END IF;
     l_previous_interface := TRUE;


     l_err_stops_count := 0;
     oe_interface_trip_stop(p_batch_id => l_stop_batch_id,
                            p_stop_tab => l_stop_tab,
                            x_stop_tab => l_dsno_stop_tab,
                            x_num_stops_removed => l_err_stops_count,
                            x_completion_status =>l_api_completion_status);

     --
     IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'INTERFACETRIPSTOP: RESULT OF OM INTERFACING BATCH_ID ' || TO_CHAR ( l_stop_batch_id ) || ' = ' || L_API_COMPLETION_STATUS  );
     END IF;
     --

     IF NVL(l_err_stops_count,0) = 0   THEN --{
        l_dsno_stop_tab := l_stop_tab;
     END IF; --}

      IF (l_err_stops_count > 0 )  THEN --{
        l_api_completion_status_bkp := 'WARNING';
        Update_Completion_Status(l_err_stops_count,
                           NULL,
                           l_completion_status,
                           l_api_completion_status_bkp,
                           l_stops_normal(1),
                           l_stops_warning(1),
                           l_stops_interfaced(1));
     END IF; --}

     IF (l_err_stops_count = l_dsno_stop_tab.COUNT)
       AND (l_err_stops_count =  l_stop_tab.COUNT) THEN
       -- this is the case that all the lines have failed interface to OM
       -- we have already called the Update_Completion_Status for this case
       l_stop_count := 0;
     ELSE
       l_stop_count := l_dsno_stop_tab.COUNT;
     END IF;

     Update_Completion_Status(l_stop_count ,
                        NULL,
                        l_completion_status,
                        l_api_completion_status,
                        l_stops_normal(1),
                        l_stops_warning(1),
                        l_stops_interfaced(1));
   ELSE --}{

      l_dsno_stop_tab := l_stop_tab;

   END IF; --}

   -- DSNO submission
   -- Interface only if NORMAL (avoid re-submission)

   l_inv_stops.DELETE;
   l_stop_tab.DELETE;

   l_tab_count := l_dsno_stop_tab.COUNT;

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_api_completion_status',
                                                     l_api_completion_status);
      WSH_DEBUG_SV.log(l_module_name,'l_previous_interface',
                                                     l_previous_interface);
      WSH_DEBUG_SV.log(l_module_name,'l_dsno_stop_tab.COUNT',
                                                     l_tab_count);
   END IF;


   l_api_completion_status_bkp := l_api_completion_status;
   l_err_stops.DELETE;

   IF   l_dsno_interface = 1 AND l_tab_count > 0
   THEN --{

      -- save the OM completion status


      x := l_dsno_stop_tab.FIRST;
      l_index := 1;

      WHILE ( x IS NOT NULL) LOOP --{
      --fix for 2781235.
      -- if there are OKE lines, then run dsno
      -- even if om interface was not run
      -- for oke line, om interface is not applicable.
      -- so run dsno if inv.interface is pending for oke
      -- lines
      --
         l_run_dsno := FALSE;
         --
         IF l_api_completion_status_bkp = 'NORMAL'
         THEN
	     l_run_dsno := TRUE;
         ELSIF l_api_completion_status_bkp = 'INTERFACED'
         THEN
         --{
	      l_oke_count := 0;
	      --
              -- Only run DSNO interface if the DSNO has not been successfully
              -- interfaced before.

	      FOR pickup_oke_headers_rec IN pickup_oke_headers(l_dsno_stop_tab(x))
	      LOOP
	          l_oke_count := 1;
	      END LOOP;
	      --
	      IF l_oke_count = 0
	      THEN
	          l_run_dsno := TRUE;
	      END IF;
         --}
         END IF;
         --
         IF l_run_dsno
         THEN
         --{

           IF l_previous_interface THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  C_INTERFACE_SEPARATOR  );
            END IF;
            --
           END IF;
           l_previous_interface := TRUE;

           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DSNO.SUBMIT_TRIP_STOP',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           WSH_DSNO.Submit_Trip_Stop(l_dsno_stop_tab(x), l_api_completion_status);
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,  'INTERFACETRIPSTOP: RESULT OF DSNO SUBMISSION FOR STOP_ID ' || TO_CHAR ( l_dsno_stop_tab(x) ) || ' = ' || L_API_COMPLETION_STATUS  );
           END IF;
           --
           Update_Completion_Status(1,
                              NULL,
                              l_completion_status,
                              l_api_completion_status,
                              l_stops_normal(2),
                              l_stops_warning(2),
                              l_stops_interfaced(2));

            IF l_api_completion_status <> 'NORMAL' THEN --{
               l_err_stops(l_err_stops.COUNT + 1 ) := l_dsno_stop_tab(x);
            ELSE
               l_inv_stops(l_index) := l_dsno_stop_tab(x);
               l_index := l_index + 1;
            END IF; --}
            --}
         END IF;
         COMMIT;
         x := l_dsno_stop_tab.NEXT(x);
      END LOOP ; --}
   END IF; --}

   IF l_err_stops.COUNT = l_dsno_stop_tab.COUNT THEN --{

      -- if all DSNOs failed, then set the status to ERROR for the whole batch

      l_api_completion_status := 'ERROR';
   ELSE --}{
      l_api_completion_status := l_api_completion_status_bkp ;

      IF l_err_stops.COUNT > 0 THEN --{

         -- set the api status to normal for the success DSNOs and filter
         -- out the failed ones from the batch.

         l_api_completion_status := 'NORMAL';

         --print the stops being deleted from the batch

         IF l_debug_on THEN
             x := l_err_stops.FIRST;
             WHILE x IS NOT NULL LOOP
                WSH_DEBUG_SV.log(l_module_name,'Following stop failed DSNO and '
                    || ' is being removed from the batch',l_err_stops(x));
                x := l_err_stops.NEXT(x);
            END LOOP;
         END IF;

         -- Filter out the failed stops from the batch.
         FORALL x IN l_err_stops.FIRST..l_err_stops.LAST
         UPDATE wsh_trip_stops
         SET pending_interface_flag = 'Y',
           batch_id = NULL
         WHERE stop_id = l_err_stops(x);

         COMMIT;

      END IF; --}
   END IF; --}

   IF l_inv_stops.COUNT = 0 THEN
      l_inv_stops := l_dsno_stop_tab;
   END IF;

   l_err_stops.DELETE;
   l_dsno_stop_tab.DELETE;


   -- Inventory Interface
   --   OK to interface if stop is already interfaced to OM
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_api_completion_status',
                                                     l_api_completion_status);
      WSH_DEBUG_SV.log(l_module_name,'l_previous_interface',
                                                     l_previous_interface);
   END IF;

   IF   l_inv_interface = 1
      AND l_api_completion_status IN ('NORMAL', 'INTERFACED') THEN

     IF l_previous_interface THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  C_INTERFACE_SEPARATOR  );
      END IF;
      --
     END IF;
     l_previous_interface := TRUE;

     Inv_Interface_Trip_Stop(l_stop_batch_id, l_api_completion_status);
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'INTERFACETRIPSTOP: RESULT OF INVENTORY INTERFACING BATCH_ID ' || TO_CHAR ( l_stop_batch_id ) || ' = ' || L_API_COMPLETION_STATUS  );
     END IF;
     --
     Update_Completion_Status(NULL,
                           l_stop_batch_id,
                           l_completion_status,
                           l_api_completion_status,
                           l_stops_normal(3),
                           l_stops_warning(3),
                           l_stops_interfaced(3));


   END IF;

   l_dsno_stop_tab.DELETE;
   l_inv_batch_table.DELETE;



   -- bug 2657859 frontport bug 2630535
   -- re-lock stop before updating its flag to 'Y' or NULL.
   DECLARE
      l_found BOOLEAN;
      l_action   VARCHAR2(100);
      l_new_flag VARCHAR2(1);
   BEGIN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                    're-lock stop to set pending_interface_flag to Y or NULL');
      END IF;


      savepoint before_flag_reset;


      l_action := 'checking';
      IF ALL_INTERFACED(l_stop_batch_id) THEN
        l_new_flag := NULL;  -- interfaced
      ELSE
        l_new_flag := 'Y';   -- pending further interface
      END IF;

      l_action := 'locking';
      OPEN   lock_batch(l_stop_batch_id, 'P');
      FETCH  lock_batch into l_batchinfo;
      l_found := lock_batch%FOUND;
      CLOSE  lock_batch;

      -- set the pending_interface_flag to 'Y' or NULL based on the out come
      -- of the ITS.

      IF l_found THEN
        l_action := 'updating';
        UPDATE wsh_trip_stops
        SET    pending_interface_flag = l_new_flag,
                  last_updated_by          = fnd_global.user_id,
                  last_update_date         = sysdate
        WHERE  batch_id = l_stop_batch_id;
      END IF;

      --/== Workflow Changes
      IF l_new_flag is null then
          FOR cur_rec IN c_stop_to_del_cur_wf(l_stop_id) LOOP
	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.RAISE_EVENT',WSH_DEBUG_SV.C_PROC_LEVEL);
	      END IF;

	      WSH_WF_STD.RAISE_EVENT(p_entity_type   =>  'DELIVERY',
			       p_entity_id       =>  cur_rec.delivery_id,
			       p_event           =>  'oracle.apps.wsh.delivery.gen.interfaced',
			       p_organization_id =>  cur_rec.organization_id,
			       x_return_status   =>  l_wf_rs);

	      IF l_debug_on THEN
	          WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_rs);
	      END IF;
	  END LOOP;
      END IF;
      -- Workflow Changes ==/

      COMMIT;


   EXCEPTION
     WHEN trip_stop_locked THEN
       -- stop is locked; probably used by another process
       WSH_UTIL_CORE.PrintMsg('Locking issue:  batch '|| l_stop_batch_id  || ' needs pending_interface_flag updated to ' || l_new_flag);
       IF lock_row%ISOPEN THEN
         CLOSE lock_row;
       END IF;
       IF lock_batch%ISOPEN THEN
         CLOSE lock_batch;
       END IF;
       rollback to before_flag_reset;

    WHEN OTHERS THEN
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,
                       'unhandled exception for action ' || l_action);
       END IF;
       l_completion_status := 'ERROR';
       l_error_code     := SQLCODE;
       l_error_text     := SQLERRM;
       WSH_UTIL_CORE.PrintMsg('Interface_ALL failed with unexpected error in ' || l_action || ' ' || l_stop_batch_id);
       WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
       l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
       errbuf := 'Interface trip stop failed with unexpected error';
       retcode := '2';
       IF lock_row%ISOPEN THEN
         CLOSE lock_row;
       END IF;
       IF lock_batch%ISOPEN THEN
         CLOSE lock_batch;
       END IF;
       rollback to before_flag_reset;
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       RETURN;
   END;


<<next_stop>>
   IF l_completion_status = 'ERROR' THEN
     WSH_UTIL_CORE.PrintMsg('InterfaceTripStop: Stopping because of ERROR.');
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                              'InterfaceTripStop: Stopping because of ERROR.');
     END IF;
     EXIT;
   END IF;
  EXCEPTION
    WHEN e_trip_stop_wf_inprogress THEN           --/== Workflow Changes
       -- Deliveries starting or ending at this stop are being controlled by Ship to Deliver Workflow
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,
        'Ship to Deliver Workflow is enabled for one or more deliveries related to this Stop');
       END IF;
       WSH_UTIL_CORE.Println('Ship to Deliver Workflow is enabled for one or more deliveries related to this Stop');
       WSH_UTIL_CORE.Println('Interface_All: skipping stop_id ' || l_stop_id );
       --==/

    WHEN e_continue THEN
      NULL;
      -- continue with the next stop, this stop is locked by another process.
  END ;
  END LOOP; -- c_stops_to_interface}

   IF c_batch_stop%isopen THEN
       CLOSE c_batch_stop;
   -- bug 3642085
   ELSIF c_stop_to_interface%isopen THEN
       CLOSE c_stop_to_interface;
   ELSIF c_all_elig_stops_to_interface%isopen THEN
       CLOSE c_all_elig_stops_to_interface;
   -- bug 3642085
   ELSIF c_stops_org%isopen THEN
       CLOSE c_stops_org;
   END IF;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  C_STOP_SEPARATOR  );
       WSH_DEBUG_SV.log(l_module_name,'l_stops_count',l_stops_count);
   END IF;
   --

  IF l_stops_count = 0 THEN
   WSH_UTIL_CORE.PrintMsg('InterfaceTripStop: no stop is processed because no lines are eligble for interfacing.');
  ELSE
   WSH_UTIL_CORE.PrintMsg('InterfaceTripStop: total stops processed: '
                    || l_stops_count);

   FOR i IN 1..l_interface_names.COUNT LOOP
     IF  l_stops_normal(i) > 0
       OR l_stops_warning(i) > 0
       OR l_stops_interfaced(i) > 0 THEN
       WSH_UTIL_CORE.PrintMsg('Stops processed for '
                        || l_interface_names(i)
                        || ' with status NORMAL: '
                        || l_stops_normal(i));
       WSH_UTIL_CORE.PrintMsg('Stops processed for '
                        || l_interface_names(i)
                        || ' with status WARNING: '
                        || l_stops_warning(i));
       WSH_UTIL_CORE.PrintMsg('Stops interfaced for '
                        || l_interface_names(i)
                        || ': '
                        || l_stops_interfaced(i));
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Stops processed for '
                        || l_interface_names(i)
                        || ' with status NORMAL: '
                        || l_stops_normal(i));
          WSH_DEBUG_SV.log(l_module_name,'Stops processed for '
                        || l_interface_names(i)
                        || ' with status WARNING: '
                        || l_stops_warning(i));
          WSH_DEBUG_SV.log(l_module_name,'Stops interfaced for '
                        || l_interface_names(i)
                        || ': '
                        || l_stops_interfaced(i));
       END IF;

     END IF;
   END LOOP;

  END IF;

  <<interface_end>>
  l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
  IF l_completion_status = 'NORMAL' THEN
    errbuf := 'Interface trip stop is completed successfully';
    retcode := '0';
  ELSIF l_completion_status = 'WARNING' THEN
    errbuf := 'Interface trip stop is  completed with warning';
    retcode := '1';
  ELSE
    errbuf := 'Interface trip stop  is completed with error';
    retcode := '2';
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'errbuf',errbuf);
      WSH_DEBUG_SV.log(l_module_name,'retcode',retcode);
      WSH_DEBUG_SV.log(l_module_name,'l_completion_status',l_completion_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  -- bug 2657859 frontport bug 2630535
  -- automatic cleanup of stuck stops where requests completed
  DECLARE
    l_recs  NUMBER;
  BEGIN
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,
                    'Automatic clean up');
       END IF;

    UPDATE wsh_trip_stops wts
    SET    wts.pending_interface_flag = 'Y',
           wts.last_updated_by       = fnd_global.user_id,
           wts.last_update_date      = sysdate
    WHERE  wts.pending_interface_flag = 'P'
    AND    EXISTS (SELECT 'request completed'
                   FROM fnd_concurrent_requests fcr
                   WHERE  fcr.request_id = wts.request_id
                   AND    fcr.phase_code = 'C');
    l_recs := sql%rowcount;

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,
                    'l_recs = ' || l_recs);
       END IF;

    COMMIT;

    IF l_recs > 0 THEN
      WSH_UTIL_CORE.PrintMsg('Cleaned up ' || to_char(l_recs) || ' stuck stops.');
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,
                    'Cleaned up ' || to_char(l_recs) || ' stuck stops.');
       END IF;

    END IF;

  EXCEPTION
     WHEN OTHERS THEN
       NULL;  -- ignore errors from clean-up here.
  END;

  EXCEPTION
    WHEN OTHERS THEN
       l_completion_status := 'ERROR';
       l_error_code     := SQLCODE;
       l_error_text     := SQLERRM;
       WSH_UTIL_CORE.PrintMsg('Interface_ALL failed with unexpected error.');
       WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
       l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
       errbuf := 'Interface trip stop failed with unexpected error';
       retcode := '2';
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
END interface_ALL;

--========================================================================
-- PROCEDURE : inv_interface
--                  This procedure is a wrapper for Interface_AL (bug 1578251)
--                  This procedure is maintained for backward compatibility
--
-- PARAMETERS: errbuf                  Used by the concurrent program for error
--                                     messages.
--             retcode                 Used by the concurrent program for return
--                                     code.
--             p_stop_id               Stop id to be interfaced.

-- COMMENT   : This API will is a wrapper on Interface_AL to perform the INV
--             interface only.
--
--========================================================================

PROCEDURE inv_interface(errbuf out NOCOPY  varchar2,
                  retcode out NOCOPY  varchar2,
                  p_stop_id in number) is
                  --
l_debug_on BOOLEAN;
                  --
                  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INV_INTERFACE';

l_log_level	NUMBER:=0;
                  --
BEGIN
 --
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
     --
     WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);

     l_log_level := 1;
 END IF;

 --
 Interface_All(errbuf    => errbuf,
            retcode  => retcode,
            p_mode    => 'INV',
            p_stop_id  => p_stop_id,
            p_log_level => l_log_level);
 IF retcode = '0' THEN
   errbuf := 'Inventory interface is completed successfully';
 ELSIF retcode = '1' THEN
   errbuf := 'Inventory interface is completed with warning';
 ELSE
   errbuf := 'Inventory interface is completed with error';
 END IF;
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'errbuf',errbuf);
     WSH_DEBUG_SV.log(l_module_name,'retcode',retcode);
     WSH_DEBUG_SV.pop(l_module_name);
 END IF;
 --
END inv_interface;

--========================================================================
-- PROCEDURE : Insert_inv_records
--                  This procedure inserts records into INV tables:
--                  mtl_transactions_interface ,mtl_serial_numbers_interface and
--                  mtl_transaction_lots_interface
--
-- PARAMETERS: p_start_index           This is the start index of table
--                                     p_mtl_txn_if_rec that should be used for
--                                     bulk insert operations.
--             p_end_index             This is the end index of table
--                                     p_mtl_txn_if_rec that should be used for
--                                     bulk insert operations.
--             p_mtl_txn_if_rec        PLSQL table to be inserted into
--                                     mtl_transactions_interface.
--             p_mtl_ser_txn_if_rec    PLSQL table to be inserted into
--                                     mtl_serial_numbers_interface.
--             p_mtl_lot_txn_if_rec    PLSQL table to be inserted into
--                                     mtl_transaction_lots_interface.
--             p_def_inv_online        'Y' will defer the inventories process
--                                     online API.
--             x_return_status         Return status of the API.

-- COMMENT   : This API is called from Interface_Detail_To_Inv and will bulk
--             insert the inventory information into inventories interface
--             tables.  In order to perform the bulk insert operation, within
--             the rollback segment of the database, the start index and end
--             index of PLSQL table p_mtl_txn_if_rec is passed.  These
--             parameters identify the range within this table that needs to
--             be bulk inserted.
--
--========================================================================

PROCEDURE Insert_inv_records(
	p_start_index		IN number,
	p_end_index		IN number,
	p_mtl_txn_if_rec      	IN WSH_SHIP_CONFIRM_ACTIONS.Mtl_txn_if_rec_type,
       	p_mtl_ser_txn_if_rec  	IN OUT NOCOPY Mtl_ser_txn_if_rec_type,
       	p_mtl_lot_txn_if_rec  	IN OUT NOCOPY Mtl_lot_txn_if_rec_type,
        p_def_inv_online        IN VARCHAR2,
	x_return_status		OUT NOCOPY 	VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Insert_inv_records';

l_return_status	varchar2(1);
BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_start_index',p_start_index);
    WSH_DEBUG_SV.log(l_module_name,'p_end_index',p_end_index);
    WSH_DEBUG_SV.log(l_module_name,'p_mtl_txn_if_rec.count',p_mtl_txn_if_rec.source_line_id.count);
    WSH_DEBUG_SV.log(l_module_name,'p_mtl_ser_txn_if_rec.count',p_mtl_ser_txn_if_rec.source_line_id.count);
    WSH_DEBUG_SV.log(l_module_name,'p_mtl_lot_txn_if_rec.count',p_mtl_lot_txn_if_rec.source_line_id.count);
    WSH_DEBUG_SV.log(l_module_name,'p_def_inv_online',p_def_inv_online);
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


 SAVEPOINT sp_insert_inv_records;

 -- Bulk insert the INV information into mtl_transactions_interface
 IF (p_mtl_txn_if_rec.source_line_id.count > 0 ) THEN
    WSH_TRX_HANDLER.INSERT_ROW_BULK (
	p_start_index		=>p_start_index,
	p_end_index		=>p_end_index,
	p_mtl_txn_if_rec 	=>p_mtl_txn_if_rec,
        x_return_status  	=> l_return_status);

     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'WSH_TRX_HANDLER.INSERT_ROW_BULK l_return_status',l_return_status);
     END IF;

     IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) then
        raise fnd_api.g_exc_error;
     END IF;
 END IF;


 -- Bulk insert the serial number information into mtl_serial_numbers_interface
 IF (p_mtl_ser_txn_if_rec.source_line_id.count > 0 ) THEN
    WSH_TRXSN_HANDLER.INSERT_ROW_BULK
		(p_mtl_ser_txn_if_rec => p_mtl_ser_txn_if_rec,
                 x_return_status  => l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'WSH_TRXSN_HANDLER.INSERT_ROW_BULK l_return_status',l_return_status);
    END IF;

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) then
        raise fnd_api.g_exc_error;
    END IF;

    p_mtl_ser_txn_if_rec.source_code.delete;
    p_mtl_ser_txn_if_rec.source_line_id.delete;
    p_mtl_ser_txn_if_rec.fm_serial_number.delete;
    p_mtl_ser_txn_if_rec.to_serial_number.delete;
    p_mtl_ser_txn_if_rec.transaction_interface_id.delete;


 END IF;


 -- Bulk insert the lot number information into mtl_transaction_lots_interface
 IF (p_mtl_lot_txn_if_rec.source_line_id.count > 0 ) THEN
    WSH_TRXLOTS_HANDLER.insert_ROW_bulk
		(p_mtl_lot_txn_if_rec => p_mtl_lot_txn_if_rec,
                 x_return_status  => l_return_status);

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'WSH_TRXLOT_HANDLER.INSERT_ROW_BULK l_return_status',l_return_status);
    END IF;

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) then
        raise fnd_api.g_exc_error;
    END IF;

    p_mtl_lot_txn_if_rec.source_code.delete;
    p_mtl_lot_txn_if_rec.source_line_id.delete;
    p_mtl_lot_txn_if_rec.lot_number.delete;
    p_mtl_lot_txn_if_rec.trx_quantity.delete;
    p_mtl_lot_txn_if_rec.serial_transaction_temp_id.delete;
    p_mtl_lot_txn_if_rec.transaction_interface_id.delete;
-- HW OPMCONV. Need to delete grade and secondary qty
    p_mtl_lot_txn_if_rec.grade_code.delete;
    p_mtl_lot_txn_if_rec.secondary_trx_quantity.delete;

 END IF;

 IF p_def_inv_online = 'Y' THEN
   COMMIT;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

     ROLLBACK TO SAVEPOINT sp_insert_inv_records;

 WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is
 '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

     ROLLBACK TO SAVEPOINT sp_insert_inv_records;
END  Insert_inv_records;


--========================================================================
-- PROCEDURE : Interface_Detail_To_Inv
--                  This procedure gathers all the information that Inventory
--                  needs from Shipping system and does some additional
--                  validations, then it callls Insert_inv_records to insert
--                  the records into the inventories interface tables.
--
-- PARAMETERS: p_batch_id              The ITS batch_id for all the trip stops
--                                     being processed in this batch.
--             P_transaction_header_id The new trx_header_id for mtl interface
--                                     table.
--             x_opm_org_exist         This parameter tells the calling API if
--                                     the lines being processed have OPM items
--             x_non_opm_org_exist     This parameter tells the calling API if
--                                     the lines being processed have non-OPM
--                                     items
--             x_return_status         Return status of the API

-- COMMENT   : First all the information needed from shipping tables are
--             bulk fetched into PLSQL table.  If there are no eligible
--             lines, then return success.
--             loop through the lines fetched and derive additional information
--             and perform additional validations.  Mark the lines with zero
--             shipped_qty as interfaced to INV.  If ship qty > 0 and the item
--             is an OPM item, update the inventory with additional information
--             and set these lines as interfaced to INV, otherwise if the item
--             is an non-OPM item then calculate some additional info based on
--             the source_code.
--             populate the out parameters x_opm_org_exist, and
--             x_non_opm_org_exist, to signal the calling API, whether INV API
--             for non-opm items should be called or GMI API for OPM item should
--             be called.
--             Call Insert_inv_records to insert the records in the bulk size
--             Chunks specified by profile option WSH_BULK_BATCH_SIZE.
--
--========================================================================

-- HW OPMCONV. Removed the parameter x_opm_org_exist
PROCEDURE Interface_Detail_To_Inv(
	p_batch_id		IN 		NUMBER,
	P_transaction_header_id	IN 		NUMBER,
        x_non_opm_org_exist     OUT NOCOPY      BOOLEAN,
	x_return_status		OUT NOCOPY 	VARCHAR2) IS


CURSOR c_order_line_info(c_order_line_id number) is
SELECT source_document_type_id, source_document_id, source_document_line_id
FROM   oe_order_lines_all
WHERE  line_id = c_order_line_id;
l_order_line_info c_order_line_info%ROWTYPE;

/* Bug 1248431 added po_req_distributions.distribution_id */
/* 2231732  encumbrance related stuff added */
CURSOR c_po_info(c_po_line_id number, c_source_document_id number) is
SELECT   destination_type_code,
     destination_subinventory,
     source_organization_id,
     destination_organization_id,
     deliver_to_location_id,
     pl.requisition_line_id,
     pd.distribution_id,
     pl.unit_price,
     nvl(pd.budget_account_id,-1)  budget_account_id,
     decode(nvl(pd.prevent_encumbrance_flag,'N'),'N',nvl(pd.encumbered_flag,'N'),'N') encumbered_flag
FROM    po_requisition_lines_all pl,
     po_req_distributions_all pd
WHERE pl.requisition_line_id = c_po_line_id
AND     pl.requisition_header_id = c_source_document_id
AND     pl.requisition_line_id = pd.requisition_line_id;
l_po_info c_po_info%ROWTYPE;


/* Bug 2137423: checking MTL_INTERORG_PARAMETERS to internal transaction type */
CURSOR c_mtl_interorg_parameters (c_from_organization_id NUMBER , c_to_organization_id NUMBER) IS
   SELECT intransit_type
   FROM   mtl_interorg_parameters
   WHERE  from_organization_id = c_from_organization_id AND
          to_organization_id = c_to_organization_id;
l_intransit_type NUMBER;

-- Bug 2657652 : Added cursor c_serial_numbers
-- Need to add Attributes for Bug 3628620 and then pass to INV table for insertion
-- Calls Insert_Inv_Records which calls WSH_TRX_HANDLER.INSERT_ROW_BULK
-- CHECK WITH INV for record structure which needs to be passed while Inserting INV records???
CURSOR c_serial_numbers (c_delivery_detail_id NUMBER) IS
SELECT fm_serial_number,
       to_serial_number,
       rownum, --haperf
       mtl_material_transactions_s.nextval seq_num,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15
from   wsh_serial_numbers
where  delivery_detail_id = c_delivery_detail_id;

l_trx_source_type_id number := NULL;
l_trx_action_id number := NULL;
l_trx_type_code number := NULL;
l_error_code number := NULL;
l_error_text varchar2(2000) := NULL;
l_req_distribution_id NUMBER := NULL;
l_transfer_subinventory   VARCHAR2(10) := NULL;
l_transfer_organization   NUMBER := NULL;
l_ship_to_location_id   NUMBER := NULL;
l_requisition_line_id    NUMBER :=NULL;
l_dummy_ser_trx_interface_id number := NULL;
l_trx_source_id NUMBER := NULL;
l_account             NUMBER := NULL;
l_account_return_status   VARCHAR2(30) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
-- HW OPMCONV. Removed OPM local variables

l_return_status   varchar2(30);
l_message_count       NUMBER;
l_message_data      VARCHAR2(3000);

-- Bug 3628620
l_attribute_category VARCHAR2(30);
l_attribute1         VARCHAR2(150);
l_attribute2         VARCHAR2(150);
l_attribute3         VARCHAR2(150);
l_attribute4         VARCHAR2(150);
l_attribute5         VARCHAR2(150);
l_attribute6         VARCHAR2(150);
l_attribute7         VARCHAR2(150);
l_attribute8         VARCHAR2(150);
l_attribute9         VARCHAR2(150);
l_attribute10        VARCHAR2(150);
l_attribute11        VARCHAR2(150);
l_attribute12        VARCHAR2(150);
l_attribute13        VARCHAR2(150);
l_attribute14        VARCHAR2(150);
l_attribute15        VARCHAR2(150);

-- End of Bug 3628620

-- bug 1651076
l_source_code  varchar2(40) := NULL;

/* H Integration: 940/945 cogs wrudge */
l_ship_params                      WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
l_sp_ret_status                    VARCHAR2(1);


-- Bug 2231732 encumbrance enhancement
l_encumbrance_account  number := NULL;
l_encumbrance_amount  number := NULL;

-- Bug 4538005
  l_intransit_time         NUMBER;
  l_session_id          NUMBER;

l_serial_count NUMBER;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INTERFACE_DETAIL_TO_INV';

CURSOR c_convert_locId (v_location_id NUMBER) IS
SELECT source_location_id
FROM   wsh_locations
WHERE  wsh_location_id = v_location_id;

--HVOP heali
l_mtl_txn_if_rec	 	Mtl_txn_if_rec_type;
l_mtl_ser_txn_if_rec  	Mtl_ser_txn_if_rec_type;
l_mtl_lot_txn_if_rec  	Mtl_lot_txn_if_rec_type;


--haperf
CURSOR c_details_for_interface(p_batch_id number) IS
SELECT source_code,
       source_header_id,
       source_line_id,
       inventory_item_id,
       subinventory,
       trx_quantity,
       trx_date,
       organization_id,
       trx_source_id,
       trx_source_type_id,
       trx_action_id,
       trx_type_id,
       distribution_account_id,
       trx_reference,
       trx_header_id,
       trx_source_line_id,
       trx_source_delivery_id,
       revision,
       locator_id,
       picking_line_id,
       transfer_subinventory,
       transfer_organization,
       ship_to_location_id,
       requisition_line_id,
       requisition_distribution_id,
       trx_uom,
       mtl_material_transactions_s.nextval trx_interface_id,
       shipment_number,
       expected_arrival_date,
       encumbrance_account,
       encumbrance_amount,
       movement_id,
       freight_code,
       waybill_airbill,
       content_lpn_id,
       requested_quantity,
       inv_interfaced_flag,
       ship_method_code,
       cycle_count_quantity,
       src_requested_quantity_uom,
       transaction_temp_id,
       lot_number,
       serial_number,
       to_serial_number,
       trip_id,
-- HW OPMCONV. No need for sublot anymore
--     sublot_number,
       ship_tolerance_above,
       ship_tolerance_below,
       src_requested_quantity,
       org_id,
       trx_quantity2,
       error_flag,
-- HW OPMCONV. Retrieve grade and uom2
       preferred_grade,
       requested_quantity_uom2,
--added for BUG 4538005
       ship_from_location_id,
       ship_to_site_use_id
--
FROM (SELECT dd.source_code,
       dd.source_header_id,
       dd.source_line_id,
       dd.inventory_item_id,
       dd.subinventory,
       dd.shipped_quantity 	trx_quantity,
       st.actual_departure_date trx_date,
       dd.organization_id,
       NULL			trx_source_id,
       NULL			trx_source_type_id,
       NULL			trx_action_id,
       NULL			trx_type_id,
       NULL			distribution_account_id,
       dd.source_header_id	trx_reference,
       NULL			trx_header_id,
       dd.source_line_id	trx_source_line_id,
       dl.delivery_id 		trx_source_delivery_id,
       dd.revision,
       dd.locator_id,
       dd.delivery_detail_id	picking_line_id,
       NULL			transfer_subinventory,
       NULL			transfer_organization,
       dd.ship_to_location_id	ship_to_location_id,
       NULL			requisition_line_id,
       NULL			requisition_distribution_id,
       dd.requested_quantity_uom trx_uom,
       --haperf NULL			trx_interface_id,
       dl.name			shipment_number,
       dl.ultimate_dropoff_date expected_arrival_date,
       NULL			encumbrance_account,
       NULL			encumbrance_amount,
       dd.movement_id,
       wcv.freight_code		freight_code,
       dl.waybill		waybill_airbill,
       dd1.lpn_id		content_lpn_id,
       ---
       dd.requested_quantity,
       dd.inv_interfaced_flag,
       tr.ship_method_code,
       dd.cycle_count_quantity,
       dd.src_requested_quantity_uom,
       dd.transaction_temp_id,
       dd.lot_number,
       dd.serial_number,
       dd.to_serial_number,
       st.trip_id,
-- HW OPMCONV. No need for sublot anymore
--     dd.sublot_number,
       dd.ship_tolerance_above,
       dd.ship_tolerance_below,
       dd.src_requested_quantity,
       dd.org_id,
-- HW OPM 3064890 added trx_quantity2
       dd.shipped_quantity2     trx_quantity2,
       'N' error_flag,
-- HW OPMCONV. Retrieve grade and uom2
       dd.preferred_grade,
       dd.requested_quantity_uom2,
--added for BUG 4538005
       dd.ship_from_location_id  ship_from_location_id,
       dd.ship_to_site_use_id   ship_to_site_use_id
--
FROM    wsh_delivery_details dd,
        wsh_delivery_assignments_v da,
	wsh_delivery_legs dg,
        wsh_new_deliveries dl,
        wsh_trip_stops st,
	wsh_trips tr,
        wsh_carriers wcv,
        wsh_delivery_details dd1,
        wsh_delivery_assignments_v da1
WHERE   st.stop_id = dg.pick_up_stop_id
AND     st.batch_id = p_batch_id
AND     st.stop_location_id = dl.initial_pickup_location_id
AND     dg.delivery_id = dl.delivery_id
AND     da.delivery_id = dl.delivery_id
AND     dd.delivery_detail_id = da.delivery_detail_id
AND     st.trip_id = tr.trip_id
AND     dd.container_flag = 'N'
AND     dd.inv_interfaced_flag = 'N'
AND     dd.released_status <> 'D'
AND     nvl(dd.line_direction,'O') in ('O','IO')
AND     tr.carrier_id = wcv.carrier_id (+)
AND     dd.delivery_detail_id=da1.delivery_detail_id
AND     da1.parent_delivery_detail_id = dd1.delivery_detail_id(+)
ORDER BY dd.organization_id,
	 dd.source_header_id,
	 dd.ship_to_location_id);
--haperf

--added for 4538005
 CURSOR get_session_id IS
  SELECT mrp_atp_schedule_temp_s.nextVal
  FROM dual;



CURSOR get_interface_id IS
 SELECT mtl_material_transactions_s.nextval
 FROM sys.dual;


-- FP bug 4166635: cursor to look up trip's freight carrier
--              for frontporting bug 4145337 / 3901066.
CURSOR c_freight_code(p_ship_method_code varchar2,
                      p_organization_id number) is
SELECT wcv.freight_code freight_code
FROM wsh_carrier_services wcs,
     wsh_org_carrier_services wocs,
     wsh_carriers_v wcv
WHERE wcs.carrier_service_id = wocs.carrier_service_id AND
      wcs.carrier_id = wcv.carrier_id AND
      wcs.ship_method_code = p_ship_method_code AND
      wocs.organization_id = p_organization_id;

-- FP bug 4166635: cursor to look up delivery's freight carrier
CURSOR c_freight_code_del(p_delivery_id  number) is
SELECT wc.freight_code
 FROM  wsh_new_deliveries wnd,
       wsh_carriers wc
 WHERE wnd.delivery_id = p_delivery_id AND
       wc.carrier_id = wnd.carrier_id;

-- FP bug 4166635: cache single records for the default freight code
l_cache_trip_sm     WSH_TRIPS.SHIP_METHOD_CODE%TYPE;
l_cache_trip_org_id NUMBER;
l_cache_trip_fc     WSH_CARRIERS.FREIGHT_CODE%TYPE;
l_cache_del_id      NUMBER;
l_cache_del_fc      WSH_CARRIERS.FREIGHT_CODE%TYPE;



-- Define this recode type to pass to GMI_Shipping_Util.GMI_UPDATE_SHIPMENT_TXN api.
-- HW OPMCONV. Removed all OPM local variables
l_delivery_detail_tbl		WSH_BULK_TYPES_GRP.tbl_num;

e_line_error			EXCEPTION;
e_line_warning			EXCEPTION;
l_row_count			NUMBER:=0;
l_ser_count			NUMBER:=0;
l_lot_count			NUMBER:=0;
l_index				NUMBER;
l_error_count			NUMBER:=0;
l_warning_count			NUMBER:=0;
l_prev_source_header_id		NUMBER;
l_prev_ship_to_location_id	NUMBER;
l_prev_organization_id		NUMBER;
l_org_type			VARCHAR2(30);
l_interface_serial		boolean :=false;
l_interface_lot			boolean :=false;
l_bulk_count 			number := 0;
l_bulk_batch_size 		number;
l_start_index			number:=0;
l_insert_inv_calls		number:=0;
l_insert_inv_not_success		number:=0;
--HVOP heali
l_def_inv_online                VARCHAR2(10);


BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

 IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'batch_id',p_batch_id);
       WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_HEADER_ID',P_TRANSACTION_HEADER_ID);
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 -- HW OPMCONV. Removed OPM variables


 --Bulk fetch c_details_for_interface INTO l_mtl_txn_if_rec;
 OPEN c_details_for_interface(p_batch_id);
 FETCH c_details_for_interface BULK COLLECT
       INTO -- l_mtl_txn_if_rec.;  -- replaced due to 8.1.7.4 pl/sql bug 3286811
         l_mtl_txn_if_rec.source_code		,
         l_mtl_txn_if_rec.source_header_id       ,
         l_mtl_txn_if_rec.source_line_id		,
         l_mtl_txn_if_rec.inventory_item_id      ,
         l_mtl_txn_if_rec.subinventory           ,
         l_mtl_txn_if_rec.trx_quantity           ,
         l_mtl_txn_if_rec.trx_date               ,
         l_mtl_txn_if_rec.organization_id        ,
         l_mtl_txn_if_rec.trx_source_id          ,
         l_mtl_txn_if_rec.trx_source_type_id     ,
         l_mtl_txn_if_rec.trx_action_id          ,
         l_mtl_txn_if_rec.trx_type_id            ,
         l_mtl_txn_if_rec.distribution_account_id,
         l_mtl_txn_if_rec.trx_reference          ,
         l_mtl_txn_if_rec.trx_header_id          ,
         l_mtl_txn_if_rec.trx_source_line_id     ,
         l_mtl_txn_if_rec.trx_source_delivery_id ,
         l_mtl_txn_if_rec.revision              	,
         l_mtl_txn_if_rec.locator_id             ,
         l_mtl_txn_if_rec.picking_line_id        ,
         l_mtl_txn_if_rec.transfer_subinventory  ,
         l_mtl_txn_if_rec.transfer_organization  ,
         l_mtl_txn_if_rec.ship_to_location_id    ,
         l_mtl_txn_if_rec.requisition_line_id    ,
         l_mtl_txn_if_rec.requisition_distribution_id,
         l_mtl_txn_if_rec.trx_uom              	,
         l_mtl_txn_if_rec.trx_interface_id       ,
         l_mtl_txn_if_rec.shipment_number        ,
         l_mtl_txn_if_rec.expected_arrival_date  ,
         l_mtl_txn_if_rec.encumbrance_account    ,
         l_mtl_txn_if_rec.encumbrance_amount     ,
         l_mtl_txn_if_rec.movement_id            ,
         l_mtl_txn_if_rec.freight_code           ,
         l_mtl_txn_if_rec.waybill_airbill        ,
	 l_mtl_txn_if_rec.content_lpn_id		,
         l_mtl_txn_if_rec.requested_quantity	,
         l_mtl_txn_if_rec.inv_interfaced_flag	,
         l_mtl_txn_if_rec.ship_method_code	,
         l_mtl_txn_if_rec.cycle_count_quantity	,
         l_mtl_txn_if_rec.src_requested_quantity_uom,
         l_mtl_txn_if_rec.transaction_temp_id	,
         l_mtl_txn_if_rec.lot_number		,
         l_mtl_txn_if_rec.serial_number		,
         l_mtl_txn_if_rec.to_serial_number	,
         l_mtl_txn_if_rec.trip_id		,
-- HW OPMCONV. No need for sublot anymore
--       l_mtl_txn_if_rec.sublot_number		,
         l_mtl_txn_if_rec.ship_tolerance_above	,
         l_mtl_txn_if_rec.ship_tolerance_below	,
         l_mtl_txn_if_rec.src_requested_quantity	,
         l_mtl_txn_if_rec.org_id			,
         l_mtl_txn_if_rec.trx_quantity2          ,
         l_mtl_txn_if_rec.error_flag		,
-- HW OPMCONV - Added grade and UOM2
         l_mtl_txn_if_rec.GRADE_CODE          ,
         l_mtl_txn_if_rec.SECONDARY_TRX_UOM,
--Added for Bug 4538005
	 l_mtl_txn_if_rec.ship_from_location_id,
	 l_mtl_txn_if_rec.ship_to_site_use_id
--
	 ;

 l_row_count := c_details_for_interface%ROWCOUNT;
 CLOSE c_details_for_interface;


 FND_PROFILE.Get('WSH_BULK_BATCH_SIZE',l_bulk_batch_size);
 FND_PROFILE.Get('WSH_DEFER_INV_PR_ONLINE',l_def_inv_online);

 IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'No of record fetch',l_row_count);
       WSH_DEBUG_SV.log(l_module_name,'l_bulk_batch_size',l_bulk_batch_size);
       WSH_DEBUG_SV.log(l_module_name,'l_def_inv_online',l_def_inv_online);
 END IF;

 l_index := l_mtl_txn_if_rec.picking_line_id.FIRST;
 IF nvl(l_index,0) = 0 THEN
     -- perhaps the inventory transaction manager is processing this
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     WSH_UTIL_CORE.PrintMsg('No Delivery Detail Found');
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'No Delivery Detail Found',l_index);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN;
 END IF;

 l_start_index := l_index;

 -- FP bug 4166635: reset the cache for default freight code
 l_cache_trip_sm     := FND_API.G_MISS_CHAR;
 l_cache_trip_org_id := FND_API.G_MISS_NUM;
 l_cache_trip_fc     := NULL;
 l_cache_del_id      := FND_API.G_MISS_NUM;
 l_cache_del_fc      := NULL;


 WHILE l_index is not null LOOP  -- {
 BEGIN
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',l_mtl_txn_if_rec.picking_line_id(l_index));
     WSH_DEBUG_SV.log(l_module_name,'trx_interface_id',l_mtl_txn_if_rec.trx_interface_id(l_index));
     WSH_DEBUG_SV.log(l_module_name,'freight_code',l_mtl_txn_if_rec.freight_code(l_index));
     WSH_DEBUG_SV.log(l_module_name,'content_lpn_id',l_mtl_txn_if_rec.content_lpn_id(l_index));
  END IF;

  IF l_mtl_txn_if_rec.content_lpn_id(l_index) IS NULL then
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'LPN ID IS NULL FOR THE PARENT CONTAINER OF LINE '
                  ||l_mtl_txn_if_rec.picking_line_id(l_index));
     END IF;
  END IF;
  --- 1:

  ---2:
  -- check for Actual Departure Date
  IF l_mtl_txn_if_rec.trx_date(l_index) IS NULL THEN
     WSH_UTIL_CORE.PrintMsg('Actual Departure Date of Trip Stop in batch '|| p_batch_id ||' is NULL');
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Actual Departure Date of Trip Stop is NULL in batch ',p_batch_id);
     END IF;

     raise e_line_error;
  END IF;
  ---2:
    --Bug 9611416 check for Actual Departure Date > sysdate
  IF l_mtl_txn_if_rec.trx_date(l_index) > sysdate THEN
     WSH_UTIL_CORE.PrintMsg('Actual Departure Date of Trip Stop in batch '|| p_batch_id ||' is a future date');
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Actual Departure Date of Trip Stop is a future date',l_mtl_txn_if_rec.trx_date(l_index));
        WSH_DEBUG_SV.log(l_module_name, 'Delivery Detail id ',l_mtl_txn_if_rec.picking_line_id(l_index));
     END IF;

     raise e_line_warning;
  END IF;

  ---3:
  -- Set the lines with  shipped_qty=0, as interfaced to INV
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Shipped_qty',l_mtl_txn_if_rec.trx_quantity(l_index));
     WSH_DEBUG_SV.log(l_module_name,'Shipped_qty',l_mtl_txn_if_rec.inv_interfaced_flag(l_index));
  END IF;
  IF NVL(l_mtl_txn_if_rec.trx_quantity(l_index), 0) = 0 THEN
     IF NVL(l_mtl_txn_if_rec.inv_interfaced_flag(l_index), 'N') <> 'Y' THEN

        l_delivery_detail_tbl(l_delivery_detail_tbl.count + 1) := l_mtl_txn_if_rec.picking_line_id(l_index);
        IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'HAVE SET THE INV_INTERFACED_FLAG TO '|| C_INV_INT_FULL ||
                    ' FOR DELIVERY DETAIL ' ||l_mtl_txn_if_rec.picking_line_id(l_index));
        END IF;
     END IF;
  END IF;
  ---3:


  ---4:
  IF (NVL(l_mtl_txn_if_rec.trx_quantity(l_index),0) > 0 ) AND    --{
        ( UPPER(NVL(l_mtl_txn_if_rec.inv_interfaced_flag(l_index),'N')) <> c_inv_int_full) THEN


-- HW BUG#:3999479   - Always make it TRUE
     x_non_opm_org_exist := TRUE;


     -- FP bug 4166635:
     -- Freight code is being passed to inventory using the following logic :
     --        If freight_code populated at the  trip, then pass it
     --        else if Ship_method populated at trip, then get the freight code
     --        else if freght_method populated at delivery , use it
     --         (Generally Ship method or carrier_id will not null at trip )
     IF l_mtl_txn_if_rec.freight_code(l_index) IS NULL THEN  --{

       IF l_mtl_txn_if_rec.ship_method_code(l_index) IS NOT NULL THEN

         IF    l_mtl_txn_if_rec.ship_method_code(l_index) <> l_cache_trip_sm
            OR l_mtl_txn_if_rec.organization_id(l_index)  <> l_cache_trip_org_id THEN
           l_cache_trip_sm     := l_mtl_txn_if_rec.ship_method_code(l_index);
           l_cache_trip_org_id := l_mtl_txn_if_rec.organization_id(l_index);
           IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'looking up freight carrier for trip ship method', l_cache_trip_sm);
            WSH_DEBUG_SV.log(l_module_name, 'and organization_id', l_cache_trip_org_id);
           END IF;
           OPEN c_freight_code(l_mtl_txn_if_rec.ship_method_code(l_index),
                               l_mtl_txn_if_rec.organization_id(l_index));
           FETCH c_freight_code into l_cache_trip_fc;
           IF c_freight_code%NOTFOUND THEN
             IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'c_freight_code record not found');
             END IF;
             l_cache_trip_fc := NULL;
           END IF;
           CLOSE c_freight_code;
         END IF;

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name, 'defaulting freight_code with l_cache_trip_fc', l_cache_trip_fc);
         END IF;
         l_mtl_txn_if_rec.freight_code(l_index) := l_cache_trip_fc;

       ELSE

         IF l_mtl_txn_if_rec.trx_source_delivery_id(l_index) <> l_cache_del_id THEN
           l_cache_del_id := l_mtl_txn_if_rec.trx_source_delivery_id(l_index);
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'looking up freight carrier for delivery', l_cache_del_id);
           END IF;
           OPEN c_freight_code_del(l_mtl_txn_if_rec.trx_source_delivery_id(l_index) ) ;
           FETCH c_freight_code_del into l_cache_del_fc;
           IF c_freight_code_del%NOTFOUND THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'c_freight_code_del record not found');
             END IF;
             l_cache_del_fc := NULL;
           END IF;
           CLOSE c_freight_code_del;
         END IF;

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name, 'defaulting freight_code with l_cache_del_fc', l_cache_del_fc);
         END IF;
         l_mtl_txn_if_rec.freight_code(l_index) := l_cache_del_fc;

       END IF;
     END IF ; --} l_mtl_txn_if_rec.freight_code(l_index) IS NULL

        -- fabdi end : SHIPPING PIECE 12/09/2000
       /* getting the source_document_type id to see if it is an internal order or not */
       /* get order line info to decide if this is part of an internal order */
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'source_code',l_mtl_txn_if_rec.source_code(l_index));
          WSH_DEBUG_SV.log(l_module_name,'ont_source_code', WSH_SHIP_CONFIRM_ACTIONS.ont_source_code);
       END IF;

       -- for non-opm items derive additional information, based on the
       -- source_code

       IF ( l_mtl_txn_if_rec.source_code(l_index) = 'OE' ) THEN --{

         IF (WSH_SHIP_CONFIRM_ACTIONS.ont_source_code is NULL) THEN
            WSH_SHIP_CONFIRM_ACTIONS.ont_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
         END IF;

         l_source_code := WSH_SHIP_CONFIRM_ACTIONS.ont_source_code;
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_source_code',l_source_code);
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_SALESORDER.GET_SALESORDER_FOR_OEHEADER',
                                                                             WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         IF (nvl(l_prev_source_header_id,-99) <> l_mtl_txn_if_rec.source_header_id(l_index)) THEN
            l_trx_source_id := INV_SALESORDER.GET_SALESORDER_FOR_OEHEADER
					( l_mtl_txn_if_rec.source_header_id(l_index));
         END IF;
         l_prev_source_header_id:=  l_mtl_txn_if_rec.source_header_id(l_index);
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'FOUND MTL ORDER LINE: ' ||L_TRX_SOURCE_ID  );
         END IF;
         --
         OPEN c_order_line_info(l_mtl_txn_if_rec.source_line_id(l_index));
         FETCH c_order_line_info into l_order_line_info;
         IF (c_order_line_info%NOTFOUND) THEN
            CLOSE c_order_line_info;
            WSH_UTIL_CORE.PrintMsg('Sales order not valid');
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Sales order not valid');
            END IF;
            raise e_line_error;
         END if;
         CLOSE c_order_line_info;

         -- bug 1656291
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'source_document_type_id',l_order_line_info.source_document_type_id);
            WSH_DEBUG_SV.log(l_module_name,'source_document_id',l_order_line_info.source_document_id);
            WSH_DEBUG_SV.log(l_module_name,'source_document_line_id',l_order_line_info.source_document_line_id);
         END IF;

         IF (l_order_line_info.source_document_type_id = 10) THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'THIS LINE IS PART OF AN INTERNAL ORDER' );
            END IF;

            OPEN c_po_info(l_order_line_info.source_document_line_id, l_order_line_info.source_document_id);
            FETCH c_po_info into l_po_info;
            IF c_po_info%NOTFOUND THEN
              CLOSE c_po_info;
              WSH_UTIL_CORE.PrintMsg('Requisition line not found');
              IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Requisition line not found');
              END IF;
              raise e_line_error;
            END IF;
            CLOSE c_po_info;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'REQUISITION LINE ID:'||L_ORDER_LINE_INFO.SOURCE_DOCUMENT_LINE_ID);
                WSH_DEBUG_SV.log(l_module_name, 'encumbered_flag', l_po_info.encumbered_flag );
                WSH_DEBUG_SV.log(l_module_name, 'budget_account_id', l_po_info.budget_account_id);
                WSH_DEBUG_SV.log(l_module_name, 'unit_price', l_po_info.unit_price);
            END IF;

            ---  2231732  encumbrance enhancement
            If l_po_info.encumbered_flag = 'Y' then
               l_encumbrance_account := l_po_info.budget_account_id;
               ---- Bug #2813401 : Converting  the shipped qty to ordered  qty UOM
               l_encumbrance_amount := (wsh_wv_utils.convert_uom( l_mtl_txn_if_rec.trx_uom(l_index),
                                          l_mtl_txn_if_rec.src_requested_quantity_uom(l_index),
                                          l_mtl_txn_if_rec.trx_quantity(l_index),
                                          l_mtl_txn_if_rec.inventory_item_id(l_index))* l_po_info.unit_price);
            end if;
            --
            IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,
         		'DEST_TYPE_CODE:' ||
			L_PO_INFO.DESTINATION_TYPE_CODE ||
			' SOURCE ORG ID:' ||
			L_PO_INFO.SOURCE_ORGANIZATION_ID ||
			' DEST ORG ID:' ||
			L_PO_INFO.DESTINATION_ORGANIZATION_ID ||
			' ENCUMBRANCE UNIT PRICE:' ||
			TO_CHAR ( L_PO_INFO.UNIT_PRICE ) ||
			' ENCUMBRANCE ACCOUNT:'
			||TO_CHAR ( L_PO_INFO.BUDGET_ACCOUNT_ID )
			|| ' ENCUMBERED FLAG: '
			|| L_PO_INFO.ENCUMBERED_FLAG
			|| ' ENCUMBRANCE ACCOUNT : '
			||TO_CHAR ( L_ENCUMBRANCE_ACCOUNT )
			|| ' ENCUMBRANCE AMOUNT : '
			||TO_CHAR ( L_ENCUMBRANCE_AMOUNT )  );
            END IF;

            ---  2231732 encumbrance enhancement
            l_transfer_subinventory := l_po_info.destination_subinventory;
            l_transfer_organization := l_po_info.destination_organization_id;
            l_requisition_line_id := l_po_info.requisition_line_id;
            l_ship_to_location_id := l_po_info.deliver_to_location_id;
            l_req_distribution_id := l_po_info.distribution_id;

            IF (l_po_info.destination_type_code = 'EXPENSE') THEN
             l_trx_source_type_id := 8;
             l_trx_action_id := 1;
             l_trx_type_code := 34 /* Store_issue */;
            ELSIF (l_po_info.destination_type_code = 'INVENTORY') AND
                (l_po_info.source_organization_id = l_po_info.destination_organization_id) THEN
             l_trx_source_type_id := 8;
             l_trx_action_id := 2;
             l_trx_type_code := 50 /* Subinv_xfer */;
            ELSIF (l_po_info.destination_organization_id <> l_po_info.source_organization_id) THEN
                  /* Bug 2137423, check mtl_interorg_parameters to decide transaction codes */
                  OPEN c_mtl_interorg_parameters( l_po_info.source_organization_id,
                                                  l_po_info.destination_organization_id);
                  FETCH c_mtl_interorg_parameters INTO l_intransit_type;
                  IF c_mtl_interorg_parameters%NOTFOUND THEN
                  /* default to intransit */
                     l_trx_source_type_id := 8;
                     l_trx_action_id := 21;
                     l_trx_type_code := 62; /* intransit_shpmnt */
                  ELSE
                     IF l_intransit_type = 1 THEN
                        l_trx_source_type_id := 8;
                        l_trx_action_id := 3;
                        l_trx_type_code := 54; /* direct shipment */
                     ELSE
                        l_trx_source_type_id := 8;
                        l_trx_action_id := 21;
                        l_trx_type_code := 62; /* intransit_shpmnt */
                     END IF;
                  END IF;
                  CLOSE c_mtl_interorg_parameters;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_intransit_type', l_intransit_type);
                     WSH_DEBUG_SV.log(l_module_name,'l_trx_source_type_id', l_trx_source_type_id);
                     WSH_DEBUG_SV.log(l_module_name,'l_trx_action_id', l_trx_action_id);
                     WSH_DEBUG_SV.log(l_module_name,'l_trx_type_code', l_trx_type_code);
                  END IF;
            END IF;


            IF (l_po_info.destination_type_code <> 'INVENTORY') THEN

               --Bug 3391494:Onward 11.5.10 for Internal Order Expenses need to pass the
               --Shipping Goods Dispatched Account instead of Charge account from PO to Inventor for Interface.

               IF (WSH_CODE_CONTROL.Get_Code_Release_Level >= '110510') THEN
                  IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Onward 11.5.10 not requried to get the PO account',
                                                                                    WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  l_account := NULL;
               ELSE
                  IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit PO_REQ_DIST_SV1.GET_DIST_ACCOUNT',
                                                                                    WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  l_account := PO_REQ_DIST_SV1.get_dist_account( l_requisition_line_id  ) ;  -- Bug 1610178
               END IF;

               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_account',l_account);
               END IF;

               IF ( l_account = -11 ) OR l_account IS NULL THEN
                   IF l_account = -11 THEN
                      WSH_UTIL_CORE.PRINTMsg ( 'Error: More than one Distribution accounts ' || l_account );
                   ELSE
                      WSH_UTIL_CORE.PRINTMsg ( 'No Distribution account ' || l_account );
                   END IF;
                   WSH_UTIL_CORE.PRINTMsg ('Use default distribution account defined for the organization');
                   wsh_shipping_params_pvt.get(
                           p_organization_id => l_mtl_txn_if_rec.organization_id(l_index),
                           x_param_info      => l_ship_params,
                           x_return_status   => l_sp_ret_status);

                   IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,'wsh_shipping_params_pvt.get l_sp_ret_status',l_sp_ret_status);
                   END IF;
                   IF l_sp_ret_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      wsh_util_core.printmsg('Unable to get shipping parameters for org '
                                                  || l_mtl_txn_if_rec.organization_id(l_index));

                      IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'Unable to get shipping parameters for org ',
                                          l_mtl_txn_if_rec.organization_id(l_index));
                      END IF;
                      raise e_line_warning;
                   END IF;


                   l_account := l_ship_params.goods_dispatched_account;
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name, ' ACCOUNT_ID:' || L_ACCOUNT );
                   END IF;

                   IF ( l_account IS NULL ) THEN
                     WSH_UTIL_CORE.PrintMsg('There is no default goods dispatched account for org ' ||
                                                         l_mtl_txn_if_rec.organization_id(l_index));
                      raise e_line_warning;
                   END IF;

               END IF;
            END IF;
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'DISTRIBUTION ACCOUNT IS ' || L_ACCOUNT  );
            END IF;
            --

	    -- Added for bug 4538005
            IF ( nvl(g_prv_from_location, -99)      = l_mtl_txn_if_rec.ship_from_location_id(l_index) AND
                 nvl(g_prv_customer_site_id, -99)   = l_mtl_txn_if_rec.ship_to_site_use_id(l_index) AND
                 nvl(g_prv_ship_method_code, '-99') = nvl(l_mtl_txn_if_rec.ship_method_code(l_index), '-11' ) )
            THEN
               l_intransit_time := g_intransit_time;
            -- If previous record details are different from current record details and
            -- ship method is not null
            ELSIF ( l_mtl_txn_if_rec.ship_method_code(l_index) IS NOT NULL )
            THEN

               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program WSH_LOCATIONS_PKG.Get_Intransit_Time');
               END IF;

	       OPEN get_session_id;
               FETCH get_session_id INTO l_session_id;
               CLOSE get_session_id;

	       MSC_ATP_PROC.ATP_Shipping_Lead_Time (
			p_from_loc_id =>  l_mtl_txn_if_rec.ship_from_location_id(l_index),        -- From Location ID
			p_to_customer_site_id =>  l_mtl_txn_if_rec.ship_to_site_use_id(l_index),        -- To Customer Site ID
			p_session_id =>  l_session_id,        -- A Unique Session ID
		        x_ship_method =>  l_mtl_txn_if_rec.ship_method_code(l_index),  -- Ship Method to Use
			x_intransit_time  =>  l_intransit_time,       -- The calculated in-transit Lead time
		        x_return_status => l_return_status       -- A return status variable
                                        --  FND_API.G_RET_STS_SUCCESS - on success
                                        --  FND_API.G_RET_STS_ERROR - on expected error
                                        --  FND_API.G_RET_STS_UNEXP_ERROR - on unexpected error
	       );

	       IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
                  --Handle Return Status
                  x_return_status := l_return_status;

                  IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
                      WSH_DEBUG_SV.logmsg(l_module_name, 'Error returned from WSH_LOCATIONS_PKG.Get_Intransit_Time');
                      WSH_DEBUG_SV.pop(l_module_name);
                  END IF;

                  RETURN;
               END IF;

               g_prv_from_location    := l_mtl_txn_if_rec.ship_from_location_id(l_index);
               g_prv_customer_site_id := l_mtl_txn_if_rec.ship_to_site_use_id(l_index);
               g_prv_ship_method_code := l_mtl_txn_if_rec.ship_method_code(l_index);
               g_intransit_time       := l_intransit_time;
            ELSE
               l_intransit_time := 0;
            END IF;

            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'Intransit Time', l_intransit_time);
            END IF;



	     l_mtl_txn_if_rec.expected_arrival_date(l_index) :=  l_mtl_txn_if_rec.trx_date(l_index)+ nvl(l_intransit_time, 0);


	 ------------------------------------
         ELSE /* not internal order */
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'NOT AN INTERNAL ORDER'  );
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_DETAILS_PKG.GET_ACCOUNT',
                                                      WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            /* get cogs account */
            l_account := WSH_TPA_DELIVERY_DETAILS_PKG.Get_Account(
					p_delivery_detail_id  => l_mtl_txn_if_rec.picking_line_id(l_index),
                                        x_return_status     => l_account_return_status);

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'RET_STATUS:'|| L_ACCOUNT_RETURN_STATUS ||
                                                                       ' ACCOUNT_ID:' || L_ACCOUNT );
	    END IF;

            IF ( l_account_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
               WSH_UTIL_CORE.PrintMsg('Unable to get account for delivery detail id ' ||
                                                                 l_mtl_txn_if_rec.picking_line_id(l_index));
               raise e_line_warning;
            END IF ;

            l_transfer_subinventory := NULL;
            l_transfer_organization := NULL;

            IF (nvl(l_prev_ship_to_location_id,-99) <> l_mtl_txn_if_rec.ship_to_location_id(l_index)) THEN
               OPEN c_convert_locId(l_mtl_txn_if_rec.ship_to_location_id(l_index));
               FETCH c_convert_locId INTO l_ship_to_location_id;
               IF c_convert_locId%NOTFOUND THEN
                  FND_MESSAGE.SET_NAME('WSH','WSH_XC_INVALID_LOCATION');
                  wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
                  CLOSE c_convert_locId;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'c_convert_locId%NOTFOUND',
                                              l_mtl_txn_if_rec.ship_to_location_id(l_index));
                  END IF;
                  raise e_line_error;
               END IF;
               CLOSE c_convert_locId;
            END IF;

            l_prev_ship_to_location_id:=l_mtl_txn_if_rec.ship_to_location_id(l_index);

            l_requisition_line_id := NULL;
            l_trx_source_type_id := 2;
            l_trx_action_id := 1;
            l_trx_type_code := 33;
         END IF;

       ELSIF ( l_mtl_txn_if_rec.source_code(l_index) = 'OKE' ) THEN --} {
         l_source_code := 'OKE';
         l_trx_source_type_id := 16;
         l_trx_action_id := 1;
         l_trx_type_code := 77;
         l_trx_source_id := l_mtl_txn_if_rec.source_header_id(l_index);
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OKE_SHIPPING_EXT.COST_OF_SALES_ACCOUNT',
                                                                  WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         l_account := OKE_SHIPPING_EXT.COST_OF_SALES_ACCOUNT(
                                              X_Delivery_Detail_ID => l_mtl_txn_if_rec.picking_line_id(l_index));
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_account',l_account);
         END IF;

         IF l_account IS NULL THEN
            WSH_UTIL_CORE.PrintMsg('OKE_SHIPPING_EXT.Cost_Of_Sales_Account returns NULL value');
            WSH_UTIL_CORE.PRINTMsg ('Use default distribution account defined for the organization');
            wsh_shipping_params_pvt.get(
                     p_organization_id => l_mtl_txn_if_rec.organization_id(l_index),
                     x_param_info      => l_ship_params,
                     x_return_status   => l_sp_ret_status);
            IF l_sp_ret_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               wsh_util_core.printmsg('Unable to get shipping parameters for org ' ||
                                                     l_mtl_txn_if_rec.organization_id(l_index));
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,
                        'Unable to get shipping parameters for org', l_mtl_txn_if_rec.organization_id(l_index));
               END IF;
               raise e_line_warning;
            END IF;

            l_account := l_ship_params.goods_dispatched_account;
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, ' ACCOUNT_ID:' || L_ACCOUNT );
            END IF;
            --
            IF  l_account IS NULL  THEN
               WSH_UTIL_CORE.PrintMsg('There is no default goods dispatched account for org ' ||
                                                              l_mtl_txn_if_rec.organization_id(l_index));
               x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'There is no default goods dispatched account for org'
                           ,l_mtl_txn_if_rec.organization_id(l_index));
               END IF;
               raise e_line_warning;
            END IF;
         END IF;
       ELSE   -- source_code is not OE or OKE } {
         /* H Integration: 940/945 interface other source_code lines like 'WSH' to inventory */
         l_source_code := l_mtl_txn_if_rec.source_code(l_index);
         l_trx_source_type_id := 13; -- Inventory
         l_trx_action_id      := 1;
         l_trx_type_code      := 32; -- miscellaneous issue
         l_trx_source_id      := l_mtl_txn_if_rec.source_header_id(l_index);

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_source_code',l_source_code);
             WSH_DEBUG_SV.log(l_module_name,'l_trx_source_id',l_trx_source_id);
         END IF;

         wsh_shipping_params_pvt.get(
                   p_organization_id => l_mtl_txn_if_rec.organization_id(l_index),
                   x_param_info      => l_ship_params,
                   x_return_status   => l_sp_ret_status);
         IF l_sp_ret_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            wsh_util_core.printmsg('Unable to get shipping parameters for org ' ||
                                                         l_mtl_txn_if_rec.organization_id(l_index));
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Unable to get shipping parameters for org',
                                                l_mtl_txn_if_rec.organization_id(l_index));
            END IF;
            raise e_line_warning;
         END IF;

         l_account := l_ship_params.goods_dispatched_account;
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, ' ACCOUNT_ID:' || L_ACCOUNT );
         END IF;

         IF ( l_account IS NULL ) THEN
            WSH_UTIL_CORE.PrintMsg('There is no default goods dispatched account for org ' ||
                                                             l_mtl_txn_if_rec.organization_id(l_index));
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'There is no default goods dispatched account for org',
                     l_mtl_txn_if_rec.organization_id(l_index));
            END IF;
            raise e_line_warning;
         END IF;
       END IF; --}


       IF (nvl(l_prev_organization_id,-99) <> l_mtl_txn_if_rec.organization_id(l_index)) THEN
          l_org_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type(
                         p_organization_id => l_mtl_txn_if_rec.organization_id(l_index),
                         x_return_status   => x_return_status);
       END IF;

       IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_org_type',l_org_type);
        WSH_DEBUG_SV.log(l_module_name,'l_source_code',l_source_code);
       END IF;

       l_prev_organization_id := l_mtl_txn_if_rec.organization_id(l_index);

       -- TPW - Distributed changes
       IF l_org_type in ('TPW','TW2') and  l_source_code = 'OE' THEN
          l_mtl_txn_if_rec.subinventory(l_index) := NULL;
       END IF;
       --

       l_bulk_count := l_bulk_count + 1;
       l_mtl_txn_if_rec.source_code(l_index):= l_source_code;
       l_mtl_txn_if_rec.source_header_id(l_index):=NVL(l_mtl_txn_if_rec.source_header_id(l_index),111);
       l_mtl_txn_if_rec.trx_quantity(l_index):= - l_mtl_txn_if_rec.trx_quantity(l_index);
-- HW OPMCONV - Added Qty2
       l_mtl_txn_if_rec.trx_quantity2(l_index):= - l_mtl_txn_if_rec.trx_quantity2(l_index);
       l_mtl_txn_if_rec.trx_source_id(l_index):= l_trx_source_id;
       l_mtl_txn_if_rec.trx_source_type_id(l_index):= l_trx_source_type_id;
       l_mtl_txn_if_rec.trx_action_id(l_index):= l_trx_action_id;
       l_mtl_txn_if_rec.trx_type_id(l_index):= l_trx_type_code;
       l_mtl_txn_if_rec.distribution_account_id(l_index):= l_account;
       l_mtl_txn_if_rec.transfer_subinventory(l_index):=l_transfer_subinventory ;
       l_mtl_txn_if_rec.transfer_organization(l_index):= l_transfer_organization;
       l_mtl_txn_if_rec.ship_to_location_id(l_index):= l_ship_to_location_id;
       l_mtl_txn_if_rec.requisition_line_iD(L_INDEX):=l_requisition_line_id ;
       l_mtl_txn_if_rec.requisition_distribution_id(l_index):= l_req_distribution_id;
       l_mtl_txn_if_rec.encumbrance_account(l_index):=l_encumbrance_account ;
       l_mtl_txn_if_rec.encumbrance_amount(l_index):= l_encumbrance_amount;
       l_mtl_txn_if_rec.trx_header_id(l_index):= p_transaction_header_id;

       --haperf
       l_dummy_ser_trx_interface_id := null;
       --haperf

       IF (l_mtl_txn_if_rec.serial_number(l_index) is not NULL
               OR l_mtl_txn_if_rec.transaction_temp_id(l_index) is not NULL)
           AND (l_mtl_txn_if_rec.lot_number(l_index) is not NULL) THEN
         l_interface_serial := true;
         l_interface_lot := true;

       ELSIF (l_mtl_txn_if_rec.transaction_temp_id(l_index) IS NOT NULL
              OR l_mtl_txn_if_rec.serial_number(l_index) IS NOT NULL) THEN
         l_interface_serial := true;
         --haperf
         l_dummy_ser_trx_interface_id := l_mtl_txn_if_rec.trx_interface_id(l_index);

       ELSIF (l_mtl_txn_if_rec.lot_number(l_index) is not NULL) THEN
         l_interface_lot := true;
         l_dummy_ser_trx_interface_id := null;
       END IF;


       -- gather the serial number information.
       IF (l_interface_serial) THEN
         l_interface_serial := false;

         IF (l_mtl_txn_if_rec.transaction_temp_id(l_index) is NULL) THEN

           --haperf
           IF (l_interface_lot) THEN
             OPEN get_interface_id;
             FETCH get_interface_id INTO l_dummy_ser_trx_interface_id;
             CLOSE get_interface_id;
           END IF;
           --haperf

           l_bulk_count := l_bulk_count + 1;
           l_ser_count:= l_mtl_ser_txn_if_rec.source_line_id.count + 1;
           l_mtl_ser_txn_if_rec.source_code(l_ser_count):= l_source_code;
           l_mtl_ser_txn_if_rec.source_line_id(l_ser_count):= l_mtl_txn_if_rec.source_line_id(l_index);
           l_mtl_ser_txn_if_rec.fm_serial_number(l_ser_count):=l_mtl_txn_if_rec.serial_number(l_index);
           l_mtl_ser_txn_if_rec.to_serial_number(l_ser_count):= NVL(l_mtl_txn_if_rec.to_serial_number(l_index),
                                                                    l_mtl_txn_if_rec.serial_number(l_index));
           l_mtl_ser_txn_if_rec.transaction_interface_id(l_ser_count):=l_dummy_ser_trx_interface_id;

           -- Bug 36328620, do we need to look at INV MSN, MSNT tables for these attributes?
           l_mtl_ser_txn_if_rec.attribute_category(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute1(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute2(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute3(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute4(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute5(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute6(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute7(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute8(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute9(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute10(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute11(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute12(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute13(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute14(l_ser_count):=null;
           l_mtl_ser_txn_if_rec.attribute15(l_ser_count):=null;
           -- End of Bug 3628620

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'ITEM BEING ADD TO SERIAL RECORD l_mtl_ser_txn_if_rec');
             WSH_DEBUG_SV.log(l_module_name,'source_code',l_mtl_ser_txn_if_rec.source_code(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'source_line_id',l_mtl_ser_txn_if_rec.source_line_id(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'fm_serial_number',l_mtl_ser_txn_if_rec.fm_serial_number(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'to_serial_number',l_mtl_ser_txn_if_rec.to_serial_number(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'transaction_interface_id',
                                                      l_mtl_ser_txn_if_rec.transaction_interface_id(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute Category',l_mtl_ser_txn_if_rec.attribute_category(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute1',l_mtl_ser_txn_if_rec.attribute1(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute2',l_mtl_ser_txn_if_rec.attribute2(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute3',l_mtl_ser_txn_if_rec.attribute3(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute4',l_mtl_ser_txn_if_rec.attribute4(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute5',l_mtl_ser_txn_if_rec.attribute5(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute6',l_mtl_ser_txn_if_rec.attribute6(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute7',l_mtl_ser_txn_if_rec.attribute7(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute8',l_mtl_ser_txn_if_rec.attribute8(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute9',l_mtl_ser_txn_if_rec.attribute9(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute10',l_mtl_ser_txn_if_rec.attribute10(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute11',l_mtl_ser_txn_if_rec.attribute11(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute12',l_mtl_ser_txn_if_rec.attribute12(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute13',l_mtl_ser_txn_if_rec.attribute13(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute14',l_mtl_ser_txn_if_rec.attribute14(l_ser_count));
             WSH_DEBUG_SV.log(l_module_name,'Attribute15',l_mtl_ser_txn_if_rec.attribute15(l_ser_count));
           END IF;

         ELSE
            l_serial_count := 0;
            FOR ser_rec in c_serial_numbers(l_mtl_txn_if_rec.picking_line_id(l_index)) LOOP

              --haperf
              IF (l_interface_lot) THEN
                IF (ser_rec.rownum = 1 ) THEN
                   l_dummy_ser_trx_interface_id := ser_rec.seq_num;
                END IF;
              END IF;
              --haperf

              l_bulk_count := l_bulk_count + 1;
              l_ser_count:= l_mtl_ser_txn_if_rec.source_line_id.count + 1;
              l_mtl_ser_txn_if_rec.source_code(l_ser_count):= l_source_code;
              l_mtl_ser_txn_if_rec.source_line_id(l_ser_count):= l_mtl_txn_if_rec.source_line_id(l_index);
              l_mtl_ser_txn_if_rec.fm_serial_number(l_ser_count):=ser_rec.fm_serial_number;
              l_mtl_ser_txn_if_rec.to_serial_number(l_ser_count):=NVL(ser_rec.to_serial_number,
                                                                                ser_rec.fm_serial_number);
              l_mtl_ser_txn_if_rec.transaction_interface_id(l_ser_count):=l_dummy_ser_trx_interface_id;

              -- Bug 36328620,
              l_mtl_ser_txn_if_rec.attribute_category(l_ser_count):=ser_rec.attribute_category;
              l_mtl_ser_txn_if_rec.attribute1(l_ser_count):=ser_rec.attribute1;
              l_mtl_ser_txn_if_rec.attribute2(l_ser_count):=ser_rec.attribute2;
              l_mtl_ser_txn_if_rec.attribute3(l_ser_count):=ser_rec.attribute3;
              l_mtl_ser_txn_if_rec.attribute4(l_ser_count):=ser_rec.attribute4;
              l_mtl_ser_txn_if_rec.attribute5(l_ser_count):=ser_rec.attribute5;
              l_mtl_ser_txn_if_rec.attribute6(l_ser_count):=ser_rec.attribute6;
              l_mtl_ser_txn_if_rec.attribute7(l_ser_count):=ser_rec.attribute7;
              l_mtl_ser_txn_if_rec.attribute8(l_ser_count):=ser_rec.attribute8;
              l_mtl_ser_txn_if_rec.attribute9(l_ser_count):=ser_rec.attribute9;
              l_mtl_ser_txn_if_rec.attribute10(l_ser_count):=ser_rec.attribute10;
              l_mtl_ser_txn_if_rec.attribute11(l_ser_count):=ser_rec.attribute11;
              l_mtl_ser_txn_if_rec.attribute12(l_ser_count):=ser_rec.attribute12;
              l_mtl_ser_txn_if_rec.attribute13(l_ser_count):=ser_rec.attribute13;
              l_mtl_ser_txn_if_rec.attribute14(l_ser_count):=ser_rec.attribute14;
              l_mtl_ser_txn_if_rec.attribute15(l_ser_count):=ser_rec.attribute15;
              -- End of Bug 3628620

              IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'ITEM BEING ADD TO SERIAL RECORD l_mtl_ser_txn_if_rec');
               WSH_DEBUG_SV.log(l_module_name,'source_code',l_mtl_ser_txn_if_rec.source_code(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'source_line_id',l_mtl_ser_txn_if_rec.source_line_id(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'fm_serial_number',l_mtl_ser_txn_if_rec.fm_serial_number(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'to_serial_number',l_mtl_ser_txn_if_rec.to_serial_number(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'transaction_interface_id',
                                                      l_mtl_ser_txn_if_rec.transaction_interface_id(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute Category',l_mtl_ser_txn_if_rec.attribute_category(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute1',l_mtl_ser_txn_if_rec.attribute1(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute2',l_mtl_ser_txn_if_rec.attribute2(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute3',l_mtl_ser_txn_if_rec.attribute3(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute4',l_mtl_ser_txn_if_rec.attribute4(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute5',l_mtl_ser_txn_if_rec.attribute5(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute6',l_mtl_ser_txn_if_rec.attribute6(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute7',l_mtl_ser_txn_if_rec.attribute7(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute8',l_mtl_ser_txn_if_rec.attribute8(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute9',l_mtl_ser_txn_if_rec.attribute9(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute10',l_mtl_ser_txn_if_rec.attribute10(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute11',l_mtl_ser_txn_if_rec.attribute11(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute12',l_mtl_ser_txn_if_rec.attribute12(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute13',l_mtl_ser_txn_if_rec.attribute13(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute14',l_mtl_ser_txn_if_rec.attribute14(l_ser_count));
               WSH_DEBUG_SV.log(l_module_name,'Attribute15',l_mtl_ser_txn_if_rec.attribute15(l_ser_count));
              END IF;

              l_serial_count := l_serial_count + 1;
            END LOOP;

            IF (l_serial_count = 0) THEN
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: NO SERIAL RECORDS FOUND FOR TRANSACTION_TEMP_ID '||
                                                                  l_mtl_txn_if_rec.transaction_temp_id(l_index));
              END IF;
              raise e_line_error;
            ELSE
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'INSERTED '||l_serial_count||' SERIAL RECORDS ');
              END IF;
            END IF;
         END IF;
       END IF;

       -- Gather the lot information
       IF (l_interface_lot) THEN
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'ITEM IS UNDER SRL CTRL .'||
                           'INSERTING SRL NUMBER ' || l_mtl_txn_if_rec.SERIAL_NUMBER(l_index) || 'INTO MSNI.');
         END IF;
           l_interface_lot := false;
           l_bulk_count := l_bulk_count + 1;

           l_lot_count:= l_mtl_lot_txn_if_rec.source_line_id.count + 1;
           l_mtl_lot_txn_if_rec.transaction_interface_id(l_lot_count):=l_mtl_txn_if_rec.trx_interface_id(l_index); --haperf
           l_mtl_lot_txn_if_rec.source_code(l_lot_count):= l_source_code;
           l_mtl_lot_txn_if_rec.source_line_id(l_lot_count):= l_mtl_txn_if_rec.source_line_id(l_index);
           l_mtl_lot_txn_if_rec.lot_number(l_lot_count):= l_mtl_txn_if_rec.lot_number(l_index);
           l_mtl_lot_txn_if_rec.trx_quantity(l_lot_count):= l_mtl_txn_if_rec.trx_quantity(l_index);
           l_mtl_lot_txn_if_rec.serial_transaction_temp_id(l_lot_count):=l_dummy_ser_trx_interface_id;
-- HW OPMCONV. Populate grade and qty2
           l_mtl_lot_txn_if_rec.grade_code(l_lot_count):= l_mtl_txn_if_rec.grade_code(l_index);
           l_mtl_lot_txn_if_rec.secondary_trx_quantity(l_lot_count):= l_mtl_txn_if_rec.trx_quantity2 (l_index);

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'ITEM BEING ADD TO LOT RECORD l_mtl_lot_txn_if_rec');
             WSH_DEBUG_SV.log(l_module_name,'transaction_interface_id',
                                                      l_mtl_lot_txn_if_rec.transaction_interface_id(l_lot_count));
             WSH_DEBUG_SV.log(l_module_name,'source_code',l_mtl_lot_txn_if_rec.source_code(l_lot_count));
             WSH_DEBUG_SV.log(l_module_name,'source_line_id',l_mtl_lot_txn_if_rec.source_line_id(l_lot_count));
             WSH_DEBUG_SV.log(l_module_name,'lot_number',l_mtl_lot_txn_if_rec.lot_number(l_lot_count));
             WSH_DEBUG_SV.log(l_module_name,'trx_quantity',l_mtl_lot_txn_if_rec.trx_quantity(l_lot_count));
-- HW OPMCONV - Added Qty2
             WSH_DEBUG_SV.log(l_module_name,'trx_quantity2',l_mtl_lot_txn_if_rec.secondary_trx_quantity(l_lot_count));
             WSH_DEBUG_SV.log(l_module_name,'serial_transaction_temp_id',
                                                  l_mtl_lot_txn_if_rec.serial_transaction_temp_id(l_lot_count));
           END IF;
       END IF;

  --haperf
  ELSE
     l_mtl_txn_if_rec.freight_code(l_index):=null;
  --haperf
  END IF;  -- } if trx_quantity > 0
  ---4:

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_index',l_index);
    WSH_DEBUG_SV.log(l_module_name, 'l_bulk_count',l_bulk_count);
    WSH_DEBUG_SV.log(l_module_name, 'l_mtl_txn_if_rec.picking_line_id.last',l_mtl_txn_if_rec.picking_line_id.last);
 END IF;


 -- IF the profile option WSH_BULK_BATCH_SIZE is specified, then insert the
 -- data into mtl tables, based on the chunk size specified by this profile
 -- option.

 IF ((l_bulk_batch_size is not NULL and l_bulk_count >= l_bulk_batch_size)
      or l_index = l_mtl_txn_if_rec.picking_line_id.last) THEN
    l_insert_inv_calls := l_insert_inv_calls + 1;

    Insert_inv_records(
	p_start_index	=> l_start_index,
	p_end_index	=> l_index,
	p_mtl_txn_if_rec => l_mtl_txn_if_rec,
	p_mtl_ser_txn_if_rec => l_mtl_ser_txn_if_rec,
	p_mtl_lot_txn_if_rec => l_mtl_lot_txn_if_rec,
        p_def_inv_online   => l_def_inv_online,
	x_return_status	 => l_return_status);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Insert_inv_records l_return_status',l_return_status);
   END IF;
   IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
       l_insert_inv_not_success := l_insert_inv_not_success + 1;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_insert_inv_calls',l_insert_inv_calls);
      WSH_DEBUG_SV.log(l_module_name,'l_insert_inv_not_success',l_insert_inv_not_success);
   END IF;

   l_bulk_count := 0;
   l_start_index := l_index + 1;
 END IF;


 EXCEPTION
    WHEN e_line_error THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Error at line', l_mtl_txn_if_rec.picking_line_id(l_index));
         END IF;
         l_mtl_txn_if_rec.error_flag(l_index):='Y';
	 -- Bug 4615610 : Assigned some dummy value to trx_type_id to avoid SQL error while
          --inserting into MTI
         l_mtl_txn_if_rec.trx_type_id(l_index):= -1;
         l_error_count := l_error_count + 1;

         --Bug#5084133: Needs to call Insert_inv_records even when it errors out for the last record.
         IF ( l_index = l_mtl_txn_if_rec.picking_line_id.last ) THEN
         --{
             l_insert_inv_calls := l_insert_inv_calls + 1;
             Insert_inv_records(
                p_start_index   => l_start_index,
                p_end_index     => l_index,
                p_mtl_txn_if_rec => l_mtl_txn_if_rec,
                p_mtl_ser_txn_if_rec => l_mtl_ser_txn_if_rec,
                p_mtl_lot_txn_if_rec => l_mtl_lot_txn_if_rec,
                p_def_inv_online   => l_def_inv_online,
                x_return_status  => l_return_status);

             IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Insert_inv_records l_return_status',l_return_status);
             END IF;
             IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
                      l_insert_inv_not_success := l_insert_inv_not_success + 1;
             END IF;
             IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_insert_inv_calls',l_insert_inv_calls);
                  WSH_DEBUG_SV.log(l_module_name,'l_insert_inv_not_success',l_insert_inv_not_success);
             END IF;
             l_bulk_count := 0;
         --}
         END IF;

    WHEN e_line_warning THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Warning at line', l_mtl_txn_if_rec.picking_line_id(l_index));
         END IF;
         l_mtl_txn_if_rec.error_flag(l_index):='Y';
	 -- Bug 4615610 : Assigned some dummy value to trx_type_id to avoid SQL error while
          --inserting into MTI
         l_mtl_txn_if_rec.trx_type_id(l_index):= -1;
         l_warning_count := l_warning_count + 1;

         --Bug#5084133: Needs to call Insert_inv_records even when it errors out for the last record.
         IF ( l_index = l_mtl_txn_if_rec.picking_line_id.last ) THEN
         --{
             l_insert_inv_calls := l_insert_inv_calls + 1;
             Insert_inv_records(
                p_start_index   => l_start_index,
                p_end_index     => l_index,
                p_mtl_txn_if_rec => l_mtl_txn_if_rec,
                p_mtl_ser_txn_if_rec => l_mtl_ser_txn_if_rec,
                p_mtl_lot_txn_if_rec => l_mtl_lot_txn_if_rec,
                p_def_inv_online   => l_def_inv_online,
                x_return_status  => l_return_status);

             IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Insert_inv_records l_return_status',l_return_status);
             END IF;
             IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
                      l_insert_inv_not_success := l_insert_inv_not_success + 1;
             END IF;
             IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_insert_inv_calls',l_insert_inv_calls);
                  WSH_DEBUG_SV.log(l_module_name,'l_insert_inv_not_success',l_insert_inv_not_success);
             END IF;
             l_bulk_count := 0;
         --}
         END IF;

 END;

 l_index := l_mtl_txn_if_rec.picking_line_id.NEXT(l_index);
 END LOOP; --}


 --3: For Shipped_qty=0
 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_delivery_detail_tbl.count',l_delivery_detail_tbl.count);
 END IF;

 IF (l_delivery_detail_tbl.count > 0) THEN
    FORALL i IN l_delivery_detail_tbl.first..l_delivery_detail_tbl.last
    UPDATE wsh_delivery_details
    SET inv_interfaced_flag = c_inv_int_full ,
        --Added as part of bug 7645262
        last_update_date    = sysdate,
        request_id          = fnd_global.conc_request_id,
        last_updated_by     = fnd_global.user_id

    WHERE delivery_detail_id = l_delivery_detail_tbl(i)
    AND container_flag = 'N';
 END IF;

 --For OPM Lines
 -- HW OPMCONV. Removed OPM sepecific code

 IF (l_insert_inv_not_success >= l_insert_inv_calls) THEN
    raise fnd_api.g_exc_error;
 ELSIF (l_insert_inv_not_success > 0 and l_insert_inv_not_success < l_insert_inv_calls) THEN
     RAISE wsh_util_core.g_exc_warning;
 END IF;



 IF (l_error_count >= l_mtl_txn_if_rec.picking_line_id.count) THEN
    raise fnd_api.g_exc_error;
 ELSIF ((l_error_count > 0 and l_error_count<l_mtl_txn_if_rec.picking_line_id.count)
         OR l_warning_count > 0) THEN
     RAISE wsh_util_core.g_exc_warning;
 END IF;

 IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'x_return_status',x_return_status);
       WSH_DEBUG_SV.log(l_module_name, 'l_mtl_txn_if_rec.count',l_mtl_txn_if_rec.picking_line_id.count);
       WSH_DEBUG_SV.log(l_module_name, 'l_mtl_ser_txn_if_rec.count',l_mtl_ser_txn_if_rec.source_line_id.count);
       WSH_DEBUG_SV.log(l_module_name, 'l_mtl_lot_txn_if_rec.count',l_mtl_lot_txn_if_rec.source_line_id.count);
       WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
 WHEN wsh_util_core.g_exc_warning THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;

    IF l_debug_on THEN
       wsh_debug_sv.logmsg(l_module_name, 'wsh_util_core.g_exc_warning exception has occured.', wsh_debug_sv.c_excep_level);
       wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;

 WHEN fnd_api.g_exc_error THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

    IF l_debug_on THEN
       wsh_debug_sv.logmsg(l_module_name, 'FND_API.G_EXC_ERROR exception has occured.', wsh_debug_sv.c_excep_level);
       wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;


 WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    l_error_code := SQLCODE;
    l_error_text := SQLERRM;
    WSH_UTIL_CORE.PrintMsg(l_mtl_txn_if_rec.picking_line_id(l_index) ||': Interface detail to inventory failed with unexpected error');
    WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);

    IF c_freight_code%ISOPEN THEN
       CLOSE c_freight_code;
    END IF;
    IF c_freight_code_del%ISOPEN THEN
       CLOSE c_freight_code_del;
    END IF;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
       --
END Interface_Detail_To_Inv;



--========================================================================
-- PROCEDURE : inv_interface_trip_stop
--                  This procedure interfaces the trip stops within the
--                  current batch to the inventory.
--
-- PARAMETERS: p_batch_id              The ITS current batch_id
--             x_completion_status     Return status of the API.

-- COMMENT   : First this API checks to see if all the lines within the
--             batch is fully interfaced to OM (if not return warning).  It
--             Calls the transfer_serial_numbers, to populate the serial number
--             information from MTL tables into Shipping tables.  This is done
--             for non-OM lines.  Then it calls Update_Interfaced_Details to
--             set the inv_interfaced_flag for the records that have been
--             already processed by the inventory transaction manager.  If the
--             on-line processing is not deferred, then mark the records in mtl
--             interface tables, which has been failed in previous runs, with
--             the current transaction header_id.  Call Interface_Detail_To_Inv
--             to insert the records into MTL interface tables.  If the batch
--             contains lines with OPM items then call
--             GMI_UPDATE_ORDER.process_order, otherwise if there are some
--             non-opm lines and on-line processing is not deferred, then call
--             process_inv_online, to process the inventory on-line.
--
--========================================================================

procedure inv_interface_trip_stop(p_batch_id        IN  NUMBER,
                          x_completion_status OUT NOCOPY  VARCHAR2) IS
l_completion_status   VARCHAR2(30) := 'NORMAL';
l_inv_inter_status varchar2(30);
om_inter_req_submission   exception;
l_lock_desc            VARCHAR2(92) ;
l_temp                  BOOLEAN    ;

l_delivery_id number;
request_id number;
l_error_code number;
l_error_text varchar2(2000);
-- HW OPMCONV. Removed OPM variables

l_non_opm_org_exist BOOLEAN DEFAULT FALSE;
l_transaction_header_id number ;
l_return_status varchar2(30);
l_get_lock_status varchar2(30);

l_org_id   NUMBER;
l_count    NUMBER := 0;

CURSOR lock_row ( p_batch_id in  NUMBER ) IS
SELECT stop_id
FROM wsh_trip_stops
WHERE batch_id = p_batch_id
FOR UPDATE NOWAIT;
Recinfo lock_row%ROWTYPE;

l_stop_tab     wsh_util_core.id_tab_type;

-- bug 5736840

CURSOR  get_details (p_batch_id IN NUMBER) IS
SELECT  da.delivery_detail_id
FROM    wsh_delivery_assignments da , wsh_delivery_legs dg, wsh_new_deliveries dl, wsh_trip_stops st
where   dl.delivery_id = da.delivery_id
AND     da.delivery_id IS NOT NULL
AND     st.stop_id = dg.pick_up_stop_id
AND     st.batch_id = p_batch_id
AND     st.stop_location_id = dl.initial_pickup_location_id
AND     dg.delivery_id = dl.delivery_id;

l_detail_ids_tbl WSH_BULK_TYPES_GRP.tbl_num;
l_detail_ids_count        NUMBER;

--

-- bug 3588371
-- This cursor fetches the records in mti that are not being processed
-- by other transaction.  This can contain records that have errored in
-- in the previous run
CURSOR l_get_picking_ln_id_csr (p_batch_id IN NUMBER) IS
SELECT mti.picking_line_id
FROM   mtl_transactions_interface mti,
       wsh_delivery_assignments_v da ,
       wsh_delivery_legs dg,
       wsh_new_deliveries dl,
       wsh_trip_stops st
WHERE  mti.picking_line_id  = da.delivery_detail_id
AND    dl.delivery_id = da.delivery_id
AND    st.stop_id = dg.pick_up_stop_id
AND    st.batch_id = p_batch_id
AND    st.stop_location_id = dl.initial_pickup_location_id
AND    dg.delivery_id = dl.delivery_id
AND    nvl(mti.lock_flag,2) = 2;

l_picking_line_id_tbl        WSH_BULK_TYPES_GRP.tbl_num;

l_picking_lines_count        NUMBER;
l_num_warnings        NUMBER := 0;
-- bug 3588371

trip_stop_locked exception  ;
PRAGMA EXCEPTION_INIT(trip_stop_locked, -54);

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INV_INTERFACE_TRIP_STOP';

--HVOP heali
l_def_inv_online		VARCHAR2(10);
--HVOP heali
BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
   END IF;
   --
   WSH_SHIP_CONFIRM_ACTIONS.ont_source_code := NULL;


   -- the batch should be fully interfaced to OM first.

   IF NOT  OM_INTERFACED(p_batch_id) THEN
    wsh_util_core.printmsg('Batch ' || p_batch_id || ' is not yet fully interfaced to OM.');
    x_completion_status := 'WARNING';

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_completion_status',x_completion_status);
        WSH_DEBUG_SV.log(l_module_name,'Batch ' || p_batch_id || ' is not yet fully interfaced to OM.');
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
   END IF;

   -- lock the stops in the batch
   OPEN  lock_row ( p_batch_id ) ;
   FETCH lock_row INTO Recinfo;
   IF lock_row%NOTFOUND  THEN
    CLOSE lock_row;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'INV INTERFACE CANNOT FIND Stops for batch ' || P_Batch_id  );
    END IF;

    x_completion_status := 'ERROR';
   --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_completion_status', x_completion_status);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
   END IF;

   --  bug 2787888 : Added call to transfer serial records from mtl_serial_numbers_temp to wsh_serial_numbers
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'Calling TRANSFER_SERIAL_NUMBERS FOR BATCH ' || TO_CHAR ( P_batch_id ) );
   END IF;

   -- transfer the serial number information for non-om lines.
   transfer_serial_numbers (  p_batch_id => p_batch_id ,
                              p_interfacing => 'INV',
                              x_return_status =>  l_return_status );

   if (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Error encountered in call to TRANSFER_SERIAL_NUMBERS FOR BATCH' || TO_CHAR ( P_BATCH_ID ) );
          WSH_DEBUG_SV.log(l_module_name,'x_completion_status', x_completion_status);
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      x_completion_status := 'ERROR';
      return;
   end if;
   --  bug 2787888

   -- set the inv-interfaced_flag for to 'Y' for all the records that have been
   -- already successfully processed by the inventory transaction manager.

   Update_Interfaced_Details ( p_batch_id ,  l_return_status ) ;

   if (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) then
    WSH_UTIL_CORE.PrintMsg('inv_interface_trip_stop failed for batch '||p_batch_id ||':txn '||l_transaction_header_id);
        If (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
         l_completion_status := 'ERROR';
        ELSE
         l_completion_status := 'WARNING';
        END IF;
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'inv_interface_trip_stop failed for Batch '|| p_batch_id
                                                                       ||': txn ' || l_transaction_header_id  );
           WSH_DEBUG_SV.log(l_module_name,'l_completion_status', l_completion_status);
        END IF;
   end if;

   -- If all the lines are interfaced to inventory, then return success.

   if ( inv_interfaced ( p_batch_id  ))  then
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'BATCH '|| P_batch_id || ' HAS BEEN SUCCESSFULLY INTERFACED'  );
       END IF;

       x_completion_status := 'INTERFACED';
       IF lock_row%ISOPEN THEN
         CLOSE lock_row;
       END IF;

       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'x_completion_status', x_completion_status);
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;

       return ;
   end if  ;

     -- update inv_interfaced_flag = 'N' where 'P' (for stop) and not in mti
    -- The ones that got sent to MMT have been updated to 'Y' earlier by Update_Interfaced_Details.
    -- So , this statement will update the ones still in 'P' and are  neither in MMT nor in MTI

    -- sql repository performance bug 4891985 (>1M sharable memory)
    -- changed wsh_delivery_assignments_v to wsh_delivery_assignments

    -- bug 5736840
     open  get_details(p_batch_id);
     fetch get_details bulk collect into l_detail_ids_tbl;
     close get_details;

     l_detail_ids_count := l_detail_ids_tbl.COUNT;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Number of records fetched by get_details is ', l_detail_ids_count);
      END IF;

    -- Bug#7271241 :removed source_code from where clause as DDs can be
    --               associated to OKE system.
     IF (nvl(l_detail_ids_count,0) > 0) THEN
      FORALL i in l_detail_ids_tbl.FIRST..l_detail_ids_tbl.LAST
       update wsh_delivery_details dd
       set    inv_interfaced_flag = 'N' ,
              --Added as part of bug 7645262
              last_update_date    = sysdate,
              request_id          = fnd_global.conc_request_id,
              last_updated_by     = fnd_global.user_id
       where  inv_interfaced_flag = 'P'
       and    not exists (
                          select picking_line_id
                          from   mtl_transactions_interface mti
                          where  source_line_id = mti.trx_source_line_id
                          and    mti.picking_line_id   =  dd.delivery_detail_id)
       and delivery_detail_id  = l_detail_ids_tbl(i)
       and container_flag = 'N'
       and released_status <> 'D'; /* H integration: wrudge */

     END IF;
    -- bug 5736840

      SELECT mtl_material_transactions_s.nextval
      INTO l_transaction_header_id
      FROM sys.dual;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'NEW TRANSACTION_HEADER : ' || TO_CHAR ( L_TRANSACTION_HEADER_ID )  );
      END IF;
      --


     -- update the lines in mti with the new transaction_header_id  so that these are picked up
     -- by our call to process_online.

     FND_PROFILE.Get('WSH_DEFER_INV_PR_ONLINE',l_def_inv_online);

     IF (nvl(l_def_inv_online,'N') <> 'Y') THEN --{
        -- bug 3588371
        open  l_get_picking_ln_id_csr(p_batch_id);
        fetch l_get_picking_ln_id_csr bulk collect into l_picking_line_id_tbl;
        close l_get_picking_ln_id_csr;

        l_picking_lines_count := l_picking_line_id_tbl.COUNT;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Number of records fetched by l_get_picking_ln_id_csr is ', l_picking_lines_count);
        END IF;

        IF (nvl(l_picking_lines_count,0) > 0) THEN
        --{
          --
          --
          FORALL i IN l_picking_line_id_tbl.first..l_picking_line_id_tbl.last
          update mtl_transactions_interface
          set    transaction_header_id = l_transaction_header_id
          where  picking_line_id    = l_picking_line_id_tbl(i)
          and    nvl(process_flag,1) <> 3
          and    nvl(lock_flag,2) = 2;
                -- Bug 3259613:: Process should not pick record which is being
                -- updated by another process;

          l_count := SQL%ROWCOUNT;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'No. existing record updated in MTI', l_count);
          END IF;
          --
          --
          -- bug 3588371
        --}
        END IF;

      END IF; --}

   -- check if all are 'Y' then update to -1 * transation_header_id
   -- Call Interface_Detail_To_Inv to populate the MTL interface tables.

--HVOP heali
-- HW OPMCONV - No need to pass l_opm_org_exist
  Interface_Detail_To_Inv(
        p_batch_id               => p_batch_id,
        P_transaction_header_id => l_transaction_header_id,
        x_non_opm_org_exist     => l_non_opm_org_exist,
        x_return_status         => l_inv_inter_status);

   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Interface_Detail_To_Inv l_inv_inter_status',l_inv_inter_status);
   END IF;

 -- HW OPMCONV. Removed checking for non_opm lines

   IF l_count > 0 THEN
       -- if l_count > 0 means that there are mti reords updated with our
       -- transactio id
       l_non_opm_org_exist := TRUE;
   END IF;

   -- bug 3588371
   IF nvl(l_picking_lines_count,0) > 0
   AND nvl(l_count,0) < l_picking_lines_count
   THEN
   --{
     fnd_message.set_name('WSH', 'WSH_INV_INTF_ERROR_LINES');
     l_num_warnings := nvl(l_num_warnings,0) + 1;
     WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_warning,l_module_name);
   --}
-- HW OPMCONV - No need to check for l_opm_org_exist
   ELSIF (nvl(l_picking_lines_count,0) = 0
          and not(l_non_opm_org_exist)
          and nvl(l_def_inv_online,'N') <> 'Y') THEN
   --{
     fnd_message.set_name('WSH', 'WSH_INV_INTF_LINES_LOCKED');
     l_num_warnings := nvl(l_num_warnings,0) + 1;
     WSH_UTIL_CORE.ADD_MESSAGE(wsh_util_core.g_ret_sts_warning,l_module_name);
   --}
   END IF;
   -- bug 3588371

   -- Bug#4736038: If return value is WSH_UTIL_CORE.G_RET_STS_ERROR,
   --             i) It is treated as warning so that other batches can be processed.
   --            ii) No need to call process_inv_online as it represents all DD's in a batch are failed.
  IF (l_inv_inter_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     IF (l_inv_inter_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN

         IF lock_row%ISOPEN THEN
           CLOSE lock_row;
         END IF;
         x_completion_status := 'ERROR';

         IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Batch_id '||p_batch_id||' pass Inventory interface with unexpected errors');
          WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         return;
      ELSIF ( l_inv_inter_status = WSH_UTIL_CORE.G_RET_STS_ERROR ) THEN

         IF lock_row%ISOPEN THEN
           CLOSE lock_row;
         END IF;
         x_completion_status := 'WARNING';
         IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Batch_id '||p_batch_id||' pass Inventory interface with expected errors');
          WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         return;
     ELSE
          l_completion_status := 'WARNING';
      END IF;
  END IF;
--HVOP heali
   -- mark all 'N' as 'P'
   -- process online

   -- update to 'Y' where where inv_interfaced_flag = 'P' and dd_id in mmt and trx_hdr matches and mtl.delivery_id matches (procedure A)

   -- commit; /* Commented out for bug 1777401 */

     IF (nvl(l_def_inv_online,'N') <> 'Y'  and l_completion_status <> 'ERROR') THEN
        process_inv_online ( p_batch_id , l_transaction_header_id , l_return_status );

        if (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) then
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Batch '|| p_batch_id ||': TXN ' ||
                                                   L_TRANSACTION_HEADER_ID || ' : PROCESS ONLINE FAILED AGAIN'  );
          END IF;
          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            l_completion_status := 'ERROR';
          ELSE
            l_completion_status := 'WARNING';
          END IF;
        end if;
     END IF;
       --HVOP heali

   IF lock_row%ISOPEN THEN
     close lock_row;
   END IF;

   x_completion_status := l_completion_status;

   -- bug 3588371
   IF (nvl(l_num_warnings,0) > 0 AND l_completion_status <> 'ERROR') THEN
     x_completion_status := 'WARNING';
     l_num_warnings := 0;
   END IF;
   -- bug 3588371

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_completion_status',l_completion_status);
       WSH_DEBUG_SV.pop(l_module_name);

   END IF;
   --
   EXCEPTION
     when trip_stop_locked  Then
       IF lock_row%ISOPEN THEN
         CLOSE lock_row;
       END IF;
       IF get_details%ISOPEN THEN
         CLOSE get_details;
       END IF;
       WSH_UTIL_CORE.PrintMsg('This Trip Stop is locked by some other process');
         x_completion_status := 'WARNING';  -- continue processing other stops
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'TRIP_STOP_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:TRIP_STOP_LOCKED');
       END IF;
       --
     WHEN others THEN
       IF get_details%ISOPEN THEN
         CLOSE get_details;
       END IF;
       l_completion_status := 'ERROR';
       l_error_code := SQLCODE;
       l_error_text := SQLERRM;
       WSH_UTIL_CORE.PrintMsg('Interface trip_stop to inventory failed with unexpected error');
       WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
       x_completion_status := l_completion_status;
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
END inv_interface_Trip_Stop;

--
--Function:     More_Shipment_Exist
--Parameters:      p_delivery_id,
--            p_source_line_id
--Description:      This function returns a boolean value to indicate
--            if more shipments exist for the source line
--          that is being shipped within the delivery

FUNCTION More_Shipment_Exist(p_delivery_id number, p_source_code varchar2, p_source_line_id number) RETURN BOOLEAN is
cursor assigned_line_total is
   SELECT count(*)  total
   from wsh_delivery_details dd,
         wsh_delivery_assignments_v da,
         wsh_new_deliveries ds
     where dd.delivery_detail_id = da.delivery_detail_id
     and  da.delivery_id = ds.delivery_id
     and  ds.status_code NOT IN ('CL','IT','CO', 'SR', 'SC') /* Closed, In  Transit, Confirmed */
     and  da.delivery_id <> p_delivery_id
     and  da.delivery_id IS NOT NULL
     and  dd.source_line_id = p_source_line_id
     and  dd.source_code = p_source_code
     and  dd.container_flag = 'N'
          and    dd.released_status <> 'D' ;  /* H integration: wrudge */
l_assigned_total assigned_line_total%ROWTYPE;
cursor unassigned_line_total is
   SELECT count(*) total
   from wsh_delivery_details dd,
         wsh_delivery_assignments_v da
     where   dd.delivery_detail_id = da.delivery_detail_id
     and da.delivery_id is NULL
     and dd.source_line_id = p_source_line_id
     and  dd.source_code = p_source_code
     and dd.container_flag = 'N'
          and   dd.released_status <> 'D' ;  /* H integration: wrudge */
l_unassigned_total unassigned_line_total%ROWTYPE;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MORE_SHIPMENT_EXIST';
--
BEGIN
   --
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
       --
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
   END IF;
   --
   OPEN assigned_line_total;
   FETCH assigned_line_total into l_assigned_total;
   OPEN unassigned_line_total;
   FETCH unassigned_line_total into l_unassigned_total;
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_assigned_total',l_assigned_total.total);
      WSH_DEBUG_SV.log(l_module_name,'l_unassigned_total',l_unassigned_total.total);
   END IF;
   if ((l_assigned_total.total > 0) or (l_unassigned_total.total > 0) ) THEN
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return TRUE;
   else
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return FALSE;
   END if;
END More_Shipment_Exist;

--========================================================================
-- FUNCTION  : Get_Line_Expected_Qty
--                  This function returns the sum of expected quantity for
--                  a source_line_id, where these lines are not being processed
--                  by the current batch.
--
-- PARAMETERS: p_source_line_id        The source line id (order line id)
--             p_batch_id              The ITS current batch_id

-- COMMENT   : If some delivery details associated to p_source_line_id
--             are not included in the current batch and they are picked or
--             shipped but not interfaced to the inventory, return the sum of
--             planned quantity.
--
--========================================================================

FUNCTION Get_Line_Expected_Qty(p_source_line_id in number, p_batch_id in number ) RETURN NUMBER is
total_expt_qty number ;
l_planned_qty number :=0;

/* H integration: 940/945 bug 2312168 wrudge
**   we also expect shipped quantities from outbound deliveries.
*/

-- cursor other_batch_delivery_details calculates the sum of picked_quantity or
-- requested quantity for the lines, which have certain source_line_id
-- and they do not belong to the current batch and have the following release
-- status: Staged/Pick Confirmed ,or shipped but not interfaced to inv or the
-- line belong to 3'd party warehouse and the delivery is in status
-- Shipment Cancellation Request or Shipment Requested

cursor other_batch_delivery_details is
select sum(nvl(wdd.picked_quantity, wdd.requested_quantity))
from wsh_delivery_details wdd,
wsh_delivery_assignments_v da,
wsh_new_deliveries wnd
where wdd.source_line_id=p_source_line_id and
wdd.source_code = 'OE' and
wdd.delivery_detail_id=da.delivery_detail_id and
not exists (select 1 from wsh_delivery_legs lg, wsh_trip_stops st
where st.batch_id= p_batch_id and
st.stop_id = lg.pick_up_stop_id and
nvl(da.delivery_id,0)= lg.delivery_id)
and wnd.delivery_id(+) = da.delivery_id
and (   (wdd.released_status = 'Y')
     OR (wdd.released_status = 'C' AND wdd.oe_interfaced_flag <> 'Y')
     OR (wnd.status_code IN ('SR', 'SC'))
    );

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LINE_EXPECTED_QTY';
--
BEGIN

   --
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
       --
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_batch_id',P_batch_id);
   END IF;
   --
   OPEN   other_batch_delivery_details;
   FETCH  other_batch_delivery_details INTO l_planned_qty;
   IF other_batch_delivery_details%NOTFOUND THEN
     l_planned_qty := 0;
   END IF;
   CLOSE  other_batch_delivery_details;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'PLANNED QUANTITY: '|| L_PLANNED_QTY );
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return l_planned_qty;

end Get_Line_Expected_Qty ;


--R12:MOAC this API now calls WSH, instead of OM
--         renamed Get_New_Tolerance to Check_Tolerance
--         changed Function to Procedure as the old result is not needed.
--========================================================================
-- PROCEDURE  : Check_Tolerance
--                  This function is a wrapper around
--                  WSH_DETAILS_VALIDATIONS.get_min_max_tolerance_quantity
--
-- PARAMETERS: p_stop_id               This parameter is not being used.
--             p_source_line_id        The source line id for which the
--                                     tolerance is being calculated.
--             p_shipping_uom          is shipping's requested_quantity_uom
--             p_tot_shp_qty           Sum of shipped_quantity for the source
--                                     line id (not interfaced to OM)
--             p_tot_shp_qty2          Sum of shipped_quantity2 for the source
--                                     line id (not interfaced to OM)
--             x_ship_beyond_flag      Shipped beyond the tolerance
--             x_fulfilled_flag        Value 'T' means the line is fulfilled.
-- COMMENT   : This function calls get_min_max_tolerance_quantity
--             to determine if the order line is fulfilled,
--             returning the minimum quantity remaining to ship.
--
--========================================================================

PROCEDURE Check_Tolerance(
           p_stop_id  number ,
           p_source_line_id number,
           p_shipping_uom varchar2,
           p_tot_shp_qty  number ,
           p_tot_shp_qty2  number ,
           x_ship_beyond_flag out NOCOPY  varchar2,
           x_fulfilled_flag out NOCOPY  varchar2,
	   x_return_status  out NOCOPY VARCHAR2) IS

l_msg_count number;
l_msg_data varchar2(3000);
l_return_status VARCHAR2(1);
GET_TOLERANCE_FAILED exception;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_TOLERANCE';

  l_minmaxinrec          WSH_DETAILS_VALIDATIONS.MinMaxInRecType;
  l_minmaxinoutrec       WSH_DETAILS_VALIDATIONS.MinMaxInOutRecType;
  l_minmaxoutrec         WSH_DETAILS_VALIDATIONS.MinMaxOutRecType;

  -- OM call to compare


begin

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIPPING_UOM',P_SHIPPING_UOM);
       WSH_DEBUG_SV.log(l_module_name,'P_TOT_SHP_QTY',P_TOT_SHP_QTY);
       WSH_DEBUG_SV.log(l_module_name,'P_TOT_SHP_QTY2',P_TOT_SHP_QTY2);
   END IF;

  l_minmaxinrec.source_code := 'OE';
  l_minmaxinrec.line_id :=  p_source_line_id;
  l_minmaxinrec.action_flag := 'I';

   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'THE TOTAL SHIPPED QUANTITY FOR ORDER LINE ' || P_SOURCE_LINE_ID || ' IS ' || P_TOT_SHP_QTY );
   END IF;


  WSH_DETAILS_VALIDATIONS.get_min_max_tolerance_quantity
		(p_in_attributes    => l_minmaxinrec,
		 x_out_attributes   => l_minmaxoutrec,
		 p_inout_attributes => l_minmaxinoutrec,
		 x_return_status    => l_return_status,
		 x_msg_count        => l_msg_count,
		 x_msg_data         => l_msg_data
		 );

   IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                           WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
     raise GET_TOLERANCE_FAILED;
   END if;

   IF l_minmaxoutrec.min_remaining_quantity <= 0 THEN
      x_fulfilled_flag := 'T';
   ELSE
      x_fulfilled_flag := 'F';
   END IF;

   IF l_minmaxoutrec.max_remaining_quantity < 0 THEN
      x_ship_beyond_flag := 'T';
   ELSE
      x_ship_beyond_flag := 'F';
   END IF;

   x_return_status   := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'SHIP_BEYOND_FLAG', X_SHIP_BEYOND_FLAG);
      WSH_DEBUG_SV.log(l_module_name, 'FULFILLED_FLAG', X_FULFILLED_FLAG);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
     WHEN GET_TOLERANCE_FAILED THEN
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'WSH get_min_max_tolerance_quantity FAILED'  );
           WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
           WSH_DEBUG_SV.logmsg(l_module_name,'GET_TOLERANCE_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:GET_TOLERANCE_FAILED');
       END IF;
       x_return_status  := l_return_status;
       x_fulfilled_flag := NULL;

END Check_Tolerance;

--Standalone WMS Project changes ,moved common code inside this API to be used by existing code
--as well as Standalone code
--========================================================================
-- PROCEDURE : Handle_Tolerances
--                  Procedure to check tolarance and cancel remaining wdd if any.
--
-- PARAMETERS: p_batch_id            --batch_id when called from Interface_Stop_To_OM
--                                   --NULL when called from Process_Delivery_To_OM
--             p_oe_interface_rec    line details records
--             x_fulfilled_flag      Y if line is completely shipped or shipped within tolerance
--             x_over_reason         '0' in case of overshipment
--             x_return_status
--
-- COMMENT   : This API check tolerance of the line and accordingly cancel the remaing
--             wdd.Created to be used by Standalone API Process_Delivery_To_OM.
--             As well as existing API Interface_stop_to_OM
--========================================================================
PROCEDURE Handle_Tolerances(
          p_batch_id IN NUMBER,
          p_oe_interface_rec IN WSH_SHIP_CONFIRM_ACTIONS.oe_interface_rec,
          x_fulfilled_flag OUT NOCOPY VARCHAR2,
          x_over_reason OUT NOCOPY VARCHAR2,
          x_return_status   OUT NOCOPY  VARCHAR2 ) IS
  l_debug_on    BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.'|| G_PKG_NAME || '.'|| 'Handle_Tolerances';
  l_tot_dd_req_qty NUMBER;
  l_tot_dd_shp_qty NUMBER;
  l_tot_ord_qty NUMBER;
  l_ship_beyond_flag     VARCHAR2(1);
  l_fulfilled_flag       VARCHAR2(1);
  l_process_flag         VARCHAR2(1);
  l_return_status       VARCHAR2(10);
  l_delete_detail_id NUMBER;
  l_remain_detail_index NUMBER;
  l_num_warnings NUMBER;
  l_num_errors    NUMBER;
  l_prev_line_set_id     NUMBER:= -99;
  l_cancel_unpicked_details VARCHAR(1);
  l_remain_details_id WSH_UTIL_CORE.Id_Tab_Type;
  l_line_id NUMBER;
  l_dummy VARCHAR2(1);
  l_summary  VARCHAR2(2000) :=NULL;
  l_error_Code NUMBER ;
  l_error_text varchar2(2000);
  l_details  VARCHAR2(4000) :=NULL;
  l_get_msg_count          number;
  l_client_id              NUMBER;

  CURSOR c_remain_detail_id(c_source_line_id NUMBER) IS
  SELECT delivery_detail_id
  FROM   wsh_delivery_details dd
  WHERE  source_line_id   = c_source_line_id
    AND source_code      = 'OE'
    AND released_status IN ('R', 'B','N','S','X')
    AND NVL(container_flag, 'N') = 'N';

  CURSOR c_remain_lines(c_source_line_set_id NUMBER, c_source_header_id NUMBER, p_batch_id NUMBER)  IS
  SELECT DISTINCT wdd.source_line_id
  FROM   wsh_delivery_details wdd
  WHERE  wdd.source_header_id   = c_source_header_id
     AND wdd.source_code        = 'OE'
     AND wdd.source_line_set_id = c_source_line_set_id
     AND NOT EXISTS
         ( SELECT 'x'
           FROM    wsh_delivery_assignments_v wda,
                   wsh_new_deliveries wnd        ,
                   wsh_delivery_legs wdl         ,
                   wsh_trip_stops wts
           WHERE   wdd.delivery_detail_id = wda.delivery_detail_id
               AND wda.delivery_id        = wnd.delivery_id
               AND wda.delivery_id IS NOT NULL
               AND wnd.delivery_id           = wdl.delivery_id
               AND wdl.pick_up_stop_id       = wts.stop_id
               AND wdd.ship_from_location_id = wts.stop_location_id
               AND wts.batch_id              = p_batch_id);

  CURSOR c_picked_dd(c_source_line_id NUMBER, c_source_header_id NUMBER) IS
  SELECT 'x'
  FROM   wsh_delivery_details wdd      ,
         wsh_delivery_assignments_v wda,
         wsh_new_deliveries wnd
  WHERE  wdd.source_line_id     = c_source_line_id
     AND wdd.source_code        = 'OE'
     AND wdd.source_header_id   = c_source_header_id
     AND wdd.delivery_detail_id = wda.delivery_detail_id
     AND wnd.delivery_id(+)     = wda.delivery_id
     AND ( ( wdd.released_status = 'Y' ) OR
           ( wdd.released_status = 'C' AND wdd.oe_interfaced_flag <> 'Y' ) OR
           ( wnd.status_code IN ('SR','SC')));

BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
    END IF;

    IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => p_oe_interface_rec.organization_id) THEN
       l_process_flag := FND_API.G_FALSE;
    ELSE
       l_process_flag := FND_API.G_TRUE;
    END IF;

    IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_process_flag '  || l_process_flag);
    END IF;

    IF ((NVL(p_oe_interface_rec.ship_tolerance_above,0) > 0) OR (NVL(p_oe_interface_rec.ship_tolerance_below,0) > 0))THEN
    --{
        IF (p_oe_interface_rec.source_line_set_id IS NOT NULL) THEN
        --{
            SELECT SUM(dd.requested_quantity),
                  SUM( NVL(dd.shipped_quantity, 0 )),
                  max(nvl(dd.client_id,0)) -- LSP PROJECT : needs to check clientId on WDD records.
            INTO  l_tot_dd_req_qty,
                  l_tot_dd_shp_qty,
                  l_client_id             -- LSP PROJECT
            FROM  wsh_delivery_Details dd       ,
                  wsh_delivery_assignments_v da ,
                  wsh_delivery_legs dg          ,
                  wsh_new_deliveries dl         ,
                  wsh_trip_stops st
            WHERE st.stop_id          = dg.pick_up_stop_id
              AND st.batch_id         = P_batch_id
              AND st.stop_location_id = dl.initial_pickup_location_id
              AND dg.delivery_id      = dl.delivery_id
              AND dl.delivery_id      = da.delivery_id
              AND da.delivery_id IS NOT NULL
              AND da.delivery_detail_id = dd.delivery_detail_id
              AND NVL ( dd.oe_interfaced_flag , 'N' ) <> 'Y'
              AND dd.source_code = 'OE'
              AND dd.source_header_id = p_oe_interface_rec.source_header_id
              AND dd.source_line_set_id = p_oe_interface_rec.source_line_set_id
              AND dd.released_status <> 'D';

            SELECT SUM(WSH_WV_UTILS.CONVERT_UOM(ol.order_quantity_uom, p_oe_interface_rec.requested_quantity_uom, ol.ordered_quantity, ol.inventory_item_id)) order_line_quantity
            INTO  l_tot_ord_qty
            FROM  oe_order_lines_all ol
            WHERE ol.header_id   = p_oe_interface_rec.source_header_id
              AND ol.line_set_id = p_oe_interface_rec.source_line_set_id;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'l_tot_ord_qty '||l_tot_ord_qty||' l_tot_dd_req_qty '|| l_tot_dd_req_qty||' l_tot_dd_shp_qty '||l_tot_dd_shp_qty);
            END IF;
         --}
         END IF;

         -- OM bug 2022029: compare total requested quantity instead of total shipped quantity
         IF (((p_oe_interface_rec.source_line_set_id IS NULL) AND (p_oe_interface_rec.total_requested_quantity < p_oe_interface_rec.order_line_quantity)) OR
             ((p_oe_interface_rec.source_line_set_id IS NOT NULL) AND (l_tot_dd_req_qty < l_tot_ord_qty))) THEN
         --{
                 IF l_debug_on THEN
                     IF (p_oe_interface_rec.source_line_set_id IS NOT NULL) THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,  'Shipping partial quantity for the line set ' || p_oe_interface_rec.source_line_set_id);
                     ELSE
                         WSH_DEBUG_SV.logmsg(l_module_name, 'Shipping partial quantity for the order line '|| p_oe_interface_rec.source_line_id);
                     END IF;
                 END IF;
                 --haperf
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name, '===============');
                     WSH_DEBUG_SV.logmsg(l_module_name, 'Tolerance Check');
                     WSH_DEBUG_SV.logmsg(l_module_name, '===============');
                 END IF;

                 Check_Tolerance( p_stop_id => NULL ,
                                  p_source_line_id => p_oe_interface_rec.source_line_id ,
                                  p_shipping_uom => p_oe_interface_rec.requested_quantity_uom,
                                  p_tot_shp_qty => p_oe_interface_rec.total_shipped_quantity ,
                                  p_tot_shp_qty2 => p_oe_interface_rec.total_shipped_quantity2,
                                  x_ship_beyond_flag => l_ship_beyond_flag,
                                  x_fulfilled_flag => l_fulfilled_flag,
                                  x_return_status => l_return_status);
                 --haperf
                 WSH_UTIL_CORE.api_post_call( p_return_status => l_return_status,
                                              x_num_warnings =>l_num_warnings,
                                              x_num_errors =>l_num_errors);

                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name, 'fullfilled flag = '||l_fulfilled_flag);
                 END IF;

                 IF (NVL(l_fulfilled_flag, 'F') = 'T') THEN
                 --{
                       l_remain_detail_index := 0;
                       IF l_debug_on THEN
                               WSH_DEBUG_SV.logmsg(l_module_name, 'Ship within tolerance');
                       END IF;
                       -- LSP PROJECT : should set value when DeploymentMode is Integrated
                       --          or DeploymentMode is LSP but clientId is NULL (normal orders)
                       IF ((Get_Line_Expected_Qty(p_oe_interface_rec.source_line_id, p_batch_id)) > 0 and (WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'I' OR (WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'L' and l_client_id IS NULL)) ) THEN
                       --{
                           IF l_debug_on THEN
                                   WSH_DEBUG_SV.logmsg(l_module_name, 'change fulfilled_flag to P because planned_quantity > 0 for the current line');
                           END IF;
                           l_fulfilled_flag := 'P';
                       --}
                       ELSE
                       --{
                           IF l_debug_on THEN
                               WSH_DEBUG_SV.logmsg(l_module_name, 'l_fullfilled_flag is True, need to call cancel_details for source_line = '||p_oe_interface_rec.source_line_id);
                           END IF;
                           -- Handle pending delivery details for current line
                           OPEN c_remain_detail_id(p_oe_interface_rec.source_line_id);
                           LOOP
                               FETCH c_remain_detail_id
                               INTO  l_delete_detail_id;
                               EXIT WHEN c_remain_detail_id %NOTFOUND;
                               l_remain_detail_index                      := l_remain_detail_index + 1;
                               l_remain_details_id(l_remain_detail_index) := l_delete_detail_id;
                               IF l_debug_on THEN
                                   WSH_DEBUG_SV.logmsg(l_module_name, 'l_remain_detail_index =  '||l_remain_detail_index||' detail_id = '||l_delete_detail_id);
                               END IF;
                           END LOOP;
                           CLOSE c_remain_detail_id;
                       --}
                       END IF;
                       -- Handle all lines in the line set which are not there in the current stop, if not processed before
                       -- Need to cancel the delivery details for each line depending on pending quantity
                       IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name, 'oe_interace_rec.source_line_set ='|| p_oe_interface_rec.source_line_set_id);
                       END IF;
                       IF ((p_oe_interface_rec.source_line_set_id IS NOT NULL) AND
                           (p_oe_interface_rec.source_line_set_id <> l_prev_line_set_id))THEN
                       --{
                            l_prev_line_set_id := p_oe_interface_rec.source_line_set_id;
                             -- Get all lines in the line set which are not there in the specified stop
                             OPEN c_remain_lines(p_oe_interface_rec.source_line_set_id, p_oe_interface_rec.source_header_id, p_batch_id);
                             LOOP
                             --{
                                 FETCH c_remain_lines
                                 INTO  l_line_id;
                                 EXIT WHEN c_remain_lines%NOTFOUND;
                                 -- see if the line has staged/shipped delivery details
                                 OPEN c_picked_dd(l_line_id, p_oe_interface_rec.source_header_id);
                                 FETCH c_picked_dd
                                 INTO  l_dummy;

                                 IF (c_picked_dd%NOTFOUND) THEN
                                 --{
                                     -- Cancel the pending delivery details
                                     OPEN c_remain_detail_id(l_line_id);
                                     LOOP
                                     --{
                                         FETCH c_remain_detail_id
                                         INTO  l_delete_detail_id;
                                         EXIT WHEN c_remain_detail_id %NOTFOUND;
                                         l_remain_detail_index                      := l_remain_detail_index + 1;
                                         l_remain_details_id(l_remain_detail_index) := l_delete_detail_id;
                                         IF l_debug_on THEN
                                             WSH_DEBUG_SV.logmsg(l_module_name, 'l_remain_detail_index =  '||l_remain_detail_index||' detail_id = '||l_delete_detail_id);
                                         END IF;
                                     --}
                                     END LOOP;
                                     CLOSE c_remain_detail_id;
                                 --}
                                 END IF;
                                   CLOSE c_picked_dd;
                             --}
                             END LOOP;
                             CLOSE c_remain_lines;
                       --}
                       END IF;
                       --Bug 7131800 : Default Return from the Cancel_Unpicked_Details_At_ITS function is Yes (Y) --Old Behaviour
                       --
                       l_cancel_unpicked_details := NULL;
                       --
                       IF (l_process_flag = FND_API.G_FALSE ) THEN
                       --{
                             IF l_debug_on THEN
                                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CUSTOM_PUB.Cancel_Unpicked_Details_At_ITS', WSH_DEBUG_SV.C_PROC_LEVEL);
                             END IF;
                             l_cancel_unpicked_details := WSH_CUSTOM_PUB.Cancel_Unpicked_Details_At_ITS(  p_source_header_id => p_oe_interface_rec.source_header_id,
                                                                                                          p_source_line_id => p_oe_interface_rec.source_line_id,
                                                                                                          p_source_line_set_id => p_oe_interface_rec.source_line_set_id,
                                                                                                          p_remain_details_id => l_remain_details_id);
                             IF l_debug_on THEN
                                 WSH_DEBUG_SV.logmsg(l_module_name, 'l_cancel_upicked_details '|| l_cancel_unpicked_details);
                             END IF;
                             IF ( l_cancel_unpicked_details NOT IN ('Y','N') ) THEN
                                 IF l_debug_on THEN
                                         WSH_DEBUG_SV.logmsg(l_module_name, ' Error in Routine wsh_custom_pub.Cancel_Unpicked_Details_At_ITS ');
                                 END IF;
                                 RAISE FND_API.G_EXC_ERROR;
                             END IF;
                       --}
                       ELSE -- If it is an OPM Org, which is the current/default behaviour
                            l_cancel_unpicked_details := 'Y';
                       END IF;
                       --
                       IF (l_remain_detail_index > 0 AND l_cancel_unpicked_details = 'Y') THEN
                       --{
                           WSH_INTERFACE.Cancel_Details( p_details_id => l_remain_details_id,
                                                         x_return_status => l_return_status);
                           IF l_debug_on THEN
                                   WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                           END IF;
                           WSH_UTIL_CORE.api_post_call( p_return_status => l_return_status,
                                                        x_num_warnings =>l_num_warnings,
                                                        x_num_errors =>l_num_errors);
                       --}
                       END IF;
                 --}
                 END IF; -- if l_fullfilled_flag = 'T';
                 --haperf
                 -- OM bug 2022029: this case should never happen.
                 -- still in the big loop which is looping through all the source
                 -- lines in the delivery
                 -- OVERSHIPMENT
         --}
         ELSIF (((p_oe_interface_rec.source_line_set_id IS NULL)  AND   ( p_oe_interface_rec.total_shipped_quantity > p_oe_interface_rec.order_line_quantity)) OR
                 (( p_oe_interface_rec.source_line_set_id IS NOT NULL)  AND   (l_tot_dd_shp_qty > l_tot_ord_qty))) THEN
         --{
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Over Shipment for order line '|| p_oe_interface_rec.source_line_id);
             END IF;
             IF (p_oe_interface_rec.top_model_line_id IS NULL) THEN
             --{
                 -- This part actually is not being used since UI doesn't allow
                 -- over shipment beyong tolerance
                 --haperf
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name, '===============');
                     WSH_DEBUG_SV.logmsg(l_module_name, 'Tolerance Check');
                     WSH_DEBUG_SV.logmsg(l_module_name, '===============');
                 END IF;

                 Check_Tolerance( p_stop_id => NULL ,
                                  p_source_line_id => p_oe_interface_rec.source_line_id ,
                                  p_shipping_uom => p_oe_interface_rec.requested_quantity_uom,
                                  p_tot_shp_qty => p_oe_interface_rec.total_shipped_quantity ,
                                  p_tot_shp_qty2 => p_oe_interface_rec.total_shipped_quantity2 ,
                                  x_ship_beyond_flag => l_ship_beyond_flag,
                                  x_fulfilled_flag => l_fulfilled_flag,
                                  x_return_status => l_return_status);
                 --haperf
                 WSH_UTIL_CORE.api_post_call( p_return_status => l_return_status,
                                              x_num_warnings =>l_num_warnings,
                                              x_num_errors =>l_num_errors);

                 IF (l_ship_beyond_flag = 'T') THEN
                     /* if ship beyond tolerance, we need to warn the user */
                     fnd_message.set_name('WSH', 'WSH_DET_SHIP_BEYOND_TOLERANCE');
                     x_over_reason := 'O';
                 END IF;
             --}
             END IF;
         --}     --haperf
         ELSE
             l_fulfilled_flag:='T';
         END IF;
    --}
    ELSE           --tolerance is not specified
    --{
         --haperf
         IF (p_oe_interface_rec.total_requested_quantity <> p_oe_interface_rec.order_line_quantity) THEN
                 l_fulfilled_flag :='F';
         ELSE
                 l_fulfilled_flag:='T';
         END IF;
    --}
    END IF;      --End if of tolerance check

    x_fulfilled_flag := l_fulfilled_flag ;

    IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
        x_return_status := l_return_status;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION

  WHEN fnd_api.g_exc_error THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       WSH_UTIL_CORE.Get_Messages('N',l_summary, l_details, l_get_msg_count);

        IF c_remain_detail_id%ISOPEN THEN
          close c_remain_detail_id;
        END IF;

        IF c_remain_lines%ISOPEN THEN
          close c_remain_lines;
        END IF;

        IF c_picked_dd%ISOPEN THEN
          close c_picked_dd;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN Handle_Tolerances ' );
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:fnd_api.g_exc_error');
        END IF;


  WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        l_error_code := SQLCODE;
        l_error_text := SQLERRM;

        IF c_remain_detail_id%ISOPEN THEN
          close c_remain_detail_id;
        END IF;

        IF c_remain_lines%ISOPEN THEN
          close c_remain_lines;
        END IF;

        IF c_picked_dd%ISOPEN THEN
          close c_picked_dd;
        END IF;

        wsh_util_core.printMsg('API Handle_Tolerances failed with an unexpected error');
        WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'UNEXPECTED ERROR IN Handle_Tolerances ' );
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

 END Handle_Tolerances;

--
--Function:       Part_of_PTO
--Parameters:      p_source_line_id
--Description:     This function returns a boolean value to
--          indicate if the order line is part of a PTO


FUNCTION Part_Of_PTO(p_source_code varchar2,p_source_line_id number) RETURN BOOLEAN is
l_count number;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PART_OF_PTO';
--
BEGIN
   --
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
       --
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
   END IF;
   --
   SELECT count(*) into l_count
   from wsh_delivery_details
   where top_model_line_id is not null
   and source_line_id = p_source_line_id
   and source_code = p_source_code
   and   container_flag = 'N'
   and released_status <> 'D' ;  /* H integration: wrudge */

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_count',l_count);
   END IF;
   if (l_count > 0 ) THEN
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return TRUE;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   else return FALSE;
   END if;
END Part_Of_PTO;

FUNCTION Top_Of_Model(p_source_code varchar2,p_source_line_id number) RETURN number is
l_top_id number;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TOP_OF_MODEL';
--
BEGIN
   --
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
       --
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
   END IF;
   --
   if (part_of_pto(p_source_code,p_source_line_id) = TRUE) THEN
     SELECT distinct top_model_line_id  into l_top_id
     from wsh_delivery_details
     where source_line_id = p_source_line_id
     and source_code = p_source_code
     and container_flag = 'N'
          and released_status <> 'D' ;  /* H integration: wrudge */
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_top_id',l_top_id);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return l_top_id;
   else
     NULL;
   END if;
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

END Top_Of_Model;

--========================================================================
-- PROCEDURE : update_interfaced_details
--                  This procedure updates the delivery details as interfaced
--                  to INV, if the lines are successfully processed by the
--                  inventory transaction manager.
--
-- PARAMETERS: p_batch_id              The ITS batch ID
--             x_return_status         The return status of the API.

-- COMMENT   : This procedure updates the delivery details as interfaced to INV
--             if they have been already processed by inventory system
--             and the record has been entered into the table
--             mtl_material_transactions.
--
--========================================================================

procedure update_interfaced_details ( p_batch_id number  ,  x_return_status out NOCOPY  varchar2 ) is
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_INTERFACED_DETAILS';
--
begin
/* H integration: include transaction_source_type_id 13    wrudge */
/*    transaction_source_type_id 2 and 8 are for OE */
/*    transaction_source_type_id 16 is for OKE      */
    --
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
        --
        WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
    END IF;
    --
    update wsh_delivery_details  dd
    set inv_interfaced_flag   =   c_inv_int_full ,
        --Added as part of bug 7645262
        last_update_date    = sysdate,
        request_id          = fnd_global.conc_request_id,
        last_updated_by     = fnd_global.user_id

    where (exists (
                SELECT mmt.picking_line_id
                   FROM  mtl_material_transactions mmt
                   WHERE mmt.picking_line_id  =  dd.delivery_detail_id
               and transaction_source_type_id in ( 2,8,13,16 )
               and trx_source_line_id = dd.source_line_id
                   )
               )
    and container_flag = 'N'
    and nvl(inv_interfaced_flag , 'N')  <> c_inv_int_full
   and nvl(inv_interfaced_flag , 'N')  <> 'X'
    and dd.delivery_Detail_id in  (
               SELECT  da.delivery_detail_id
               FROM   wsh_delivery_assignments_v da ,
                       wsh_delivery_legs dg,
                       wsh_new_deliveries dl,
                       wsh_trip_stops st
               where   dl.delivery_id = da.delivery_id  AND
                     da.delivery_id  IS NOT NULL AND
                     st.stop_id = dg.pick_up_stop_id AND
                     st.batch_id = p_batch_id AND
                     st.stop_location_id = dl.initial_pickup_location_id AND
                     dg.delivery_id = dl.delivery_id AND
                     nvl(dl.SHIPMENT_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
                )
         and dd.released_status <> 'D';   /* H integration: wrudge */
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'NUMBER OF ROWS UPDATED AS INTERFACED TO INVENTORY = ' || SQL%ROWCOUNT  );
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    exception
       WHEN others THEN
        x_return_status :=  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.PrintMsg('UPDATE_INTERFACED_DETAILS : unexpected error ');
         WSH_UTIL_CORE.PrintMsg( SQLCODE || ' : ' || SQLERRM );

         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
end update_interfaced_details ;


/* OE_interface can be called from the ship confirm program or
   it can be called from a concurrent program by user in the case of
   oe interface failed and it needs to be re-run manually by user */
--
--Procedure:     oe_interface
--             errbuf
--             retcode
--            p_stop_id
--Description:   wrapper for Interface_ALL (bug 1578251)
PROCEDURE oe_interface(
  errbuf out NOCOPY  VARCHAR2,
  retcode out NOCOPY  VARCHAR2,
  p_stop_id in number)
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'OE_INTERFACE';
--
l_log_level	NUMBER:=0;
BEGIN
 --
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
     --
     WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);

     l_log_level :=1;
 END IF;
 --

 Interface_All(errbuf    => errbuf,
            retcode  => retcode,
            p_mode    => 'OM DSNO',
            p_stop_id  => p_stop_id,
	    p_log_level => l_log_level);
 IF retcode = '0' THEN
   errbuf := 'OM interface is completed successfully';
 ELSIF retcode = '1' THEN
   errbuf := 'OM interface is completed with warning';
 ELSE
   errbuf := 'OM interface is completed with error';
 END IF;
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'retcode',retcode);
     WSH_DEBUG_SV.pop(l_module_name);
 END IF;
 --
END oe_interface;




--========================================================================
-- PROCEDURE : Filter_Stops_From_Batch
--                  If some of stops being processed contain delivery details
--                  ,which have failed to interface to OM, then this procedure
--                  will remove these lines from the batch.
--
-- PARAMETERS: p_batch_id              The ITS batch ID
--             p_stop_tab              Table of trip stop IDs in belong to the
--                                     current batch.
--             x_num_stops_removed     Number of stops removed from the batch.
--             x_stop_tab              stop IDs left in the batch.
--             x_return_status         The return status of the API.

-- COMMENT   : If some of the trip stops being processed have delivery lines,
--             which have failed to interface to OM, this procedure, will
--             remove these stops from the batch.  The trip stops left in the
--             batch will be cached in x_stop_tab and the number of the trip
--             stops removed will be stored in x_num_stops_removed.  If all the
--             stops in the batch have failed lines then no stop is removed from
--             the batch.  x_num_stops_removed will be set to the count of all
--             the stops in the batch.  This indicates to the calling program
--             that all the stops in the batch have failed.
--
--========================================================================

PROCEDURE Filter_Stops_From_Batch (p_batch_id IN NUMBER,
                      p_stop_tab IN wsh_util_core.id_tab_type,
                      x_num_stops_removed OUT NOCOPY NUMBER,
                      x_stop_tab OUT NOCOPY wsh_util_core.id_tab_type,
                      x_return_status OUT NOCOPY VARCHAR2)
IS

   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
           'FILTER_STOPS_FROM_BATCH';

   l_count          NUMBER;
   l_start          NUMBER;
   i                NUMBER;
   j                NUMBER;
   l_all_stops_count NUMBER;

   l_found           BOOLEAN;
   l_err_stops       wsh_util_core.id_tab_type;
   l_dummy           NUMBER;

   CURSOR c_lock_batch (p_batch_id NUMBER) IS
   SELECT batch_id
   FROM wsh_trip_stops
   WHERE batch_id = p_batch_id
   FOR UPDATE NOWAIT;


   -- Cursor c_failed_stops contains stops, which have delivery details that
   -- have failed interface to OM.

   CURSOR c_failed_stops (p_batch_id NUMBER) IS
   SELECT DISTINCT stop_id
   FROM   wsh_delivery_Details dd,
      wsh_delivery_assignments_v da ,
      wsh_delivery_legs dg,
      wsh_new_deliveries dl,
      wsh_trip_stops st
   WHERE st.stop_id = dg.pick_up_stop_id
      AND st.batch_id = p_batch_id
      AND st.stop_location_id = dl.initial_pickup_location_id
      AND dg.delivery_id = dl.delivery_id
      AND dl.delivery_id = da.delivery_id
      AND da.delivery_id IS NOT NULL
      AND da.delivery_detail_id = dd.delivery_detail_id
      AND dd.oe_interfaced_flag =  'N'
      AND dd.source_code = 'OE'
      AND dd.released_status <> 'D'
      AND    nvl(dd.line_direction,'O') IN ('O','IO');

BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   x_num_stops_removed := 0;

   SAVEPOINT  s_Filter_Stops_From_Batch;

   l_all_stops_count := p_stop_tab.COUNT;

   IF l_all_stops_count = 0 THEN
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_all_stops_count',l_all_stops_count);
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
   END IF;

   --get the stops that have at least one failed lines

   OPEN c_failed_stops(p_batch_id);
   FETCH c_failed_stops BULK COLLECT INTO
      l_err_stops;
   CLOSE c_failed_stops;


   l_count := l_err_stops.COUNT;


   IF l_count = l_all_stops_count THEN --{
      --if all the stops failed then populate the number of stops that is
      -- filtered  out.
      --However, do not remove the batch_id from the stops, in the wrapper
      -- we need the batch to contain some stops to set the pending flag
      x_num_stops_removed := l_all_stops_count;
      x_stop_tab := p_stop_tab;
   ELSIF l_count = 0 THEN --}{
      --If there are not failed stops then all the stops are good
      x_stop_tab := p_stop_tab;
      x_num_stops_removed := 0;
   ELSIF l_all_stops_count > l_count THEN  --}{

      --This means there are some stops that could be processed as interfaced

      x_num_stops_removed := l_count;
      -- filter out the failed stops

      OPEN c_lock_batch(p_batch_id);
      FETCH c_lock_batch INTO l_dummy;
      CLOSE c_lock_batch;

      l_start := l_err_stops.FIRST;
      FORALL i IN l_start..l_count
      UPDATE wsh_trip_stops
      SET batch_id = NULL,
      pending_interface_flag = 'Y'
      WHERE stop_id = l_err_stops(i);

      COMMIT;

      i := p_stop_tab.FIRST;
      WHILE i IS NOT NULL LOOP --{
         l_found := FALSE;
         j := l_err_stops.FIRST;
         WHILE j IS NOT NULL LOOP --{
            IF l_err_stops(j) = p_stop_tab(i) THEN
               l_found := TRUE;
               EXIT;
            END IF;
            j := l_err_stops.NEXT(j);
         END LOOP; --}
         --
         IF NOT l_found THEN
            -- if non of the lines in the stop has failed in OM then
            -- it can be processed further to DSNO and INV, put this in
            -- x_stop_tab
            x_stop_tab(x_stop_tab.COUNT + 1) := p_stop_tab(i);
         END IF;
         i := p_stop_tab.NEXT(i);
      END LOOP; --}

   END IF; --}

   IF l_debug_on THEN --{
      i := l_err_stops.FIRST;
      WHILE i IS NOT NULL LOOP
         WSH_DEBUG_SV.log(l_module_name,'Failed to interface stop to OM',
            l_err_stops(i));
         i := l_err_stops.NEXT(i);
      END LOOP;
   END IF; --}


   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status   );
       WSH_DEBUG_SV.log(l_module_name,'l_err_stops.count',l_err_stops.COUNT );
       WSH_DEBUG_SV.log(l_module_name,'x_stop_tab.count',x_stop_tab.COUNT );
       WSH_DEBUG_SV.log(l_module_name,'l_all_stops_count',l_all_stops_count   );
       WSH_DEBUG_SV.log(l_module_name,'x_num_stops_removed',x_num_stops_removed   );
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;

   EXCEPTION

      WHEN OTHERS THEN
         ROLLBACK TO s_Filter_Stops_From_Batch;
         x_return_status := wsh_util_core.g_ret_sts_unexp_error;
         wsh_util_core.default_handler('WSH_SHIP_CONFIRM_ACTIONS.Filter_Stops_From_Batch');

         IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Unexpected error has occured. Oracle error message is ' || SQLERRM, wsh_debug_sv.c_unexpec_err_level);
            wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
         END IF;


END Filter_Stops_From_Batch;


-- start bug 1578251: move oe_interface logic to oe_interface_trip_stop and set completion_status
--
--========================================================================
-- PROCEDURE : oe_interface_trip_stop
--                  This API interfaces the trip stops being processed to the
--                  Order Management.
--
-- PARAMETERS: p_batch_id              The ITS batch ID
--             p_stop_tab              Table of trip stop IDs in belong to the
--                                     current batch.
--             x_num_stops_removed     Number of stops removed from the batch.
--                                     If this parameter is the same as
--                                     x_stop_tab.count then all the stops have
--                                     failed (but they have not been removed
--                                     from the batch)
--             x_stop_tab              stop IDs left in the batch.
--             x_completion_status     The return status of the API.
--
-- COMMENT   : This API first calls Interface_Stop_To_OM to interface the
--             trip stops within the batch to the OM.  Interface_Stop_To_OM
--             results in error or warning, then it calls
--             Filter_Stops_From_Batch to filter out the failed trip stops.
--             Then it calls transfer_serial_numbers for the successful stops
--             to transfer the serial number information from the inventory
--             tables into the shipping tables.  It populates the table
--             x_stop_tab with the stops left in the batch and populates
--             x_num_stops_removed with the number of the stops removed from the
--             batch.  If x_num_stops_removed equals the rowcount of table
--             x_stop_tab, this means that all the stops in the batch have
--             failed, but they have not been removed from the batch.
--
--========================================================================

PROCEDURE oe_interface_trip_stop(p_batch_id IN NUMBER,
                         p_stop_tab IN wsh_util_core.id_tab_type,
                         x_stop_tab OUT NOCOPY wsh_util_core.id_tab_type,
                         x_num_stops_removed OUT NOCOPY NUMBER,
                         x_completion_status OUT NOCOPY  VARCHAR2) IS

l_return_status varchar2(30);
l_prev_return_status varchar2(30);
l_completion_status      VARCHAR2(30) := 'NORMAL';
l_dummy    VARCHAR2(10);
l_num_warnings NUMBER := 0;
l_num_errors   NUMBER := 0;

CURSOR lock_row ( p_batch_id in  NUMBER ) IS
SELECT stop_id
FROM wsh_trip_stops
WHERE batch_id = p_batch_id
FOR UPDATE NOWAIT;
Recinfo lock_row%ROWTYPE;

trip_stop_locked exception  ;
e_Interface_Stop_to_om exception;
PRAGMA EXCEPTION_INIT(trip_stop_locked, -54);

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'OE_INTERFACE_TRIP_STOP';
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
  END IF;
  --

  x_num_stops_removed := 0;

  OPEN  lock_row ( p_batch_id ) ;
  FETCH lock_row INTO Recinfo;
  IF lock_row%NOTFOUND  THEN
   CLOSE lock_row;
   x_completion_status := 'ERROR';
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  'OM INTERFACE CANNOT FIND BATCH ID ' || p_batch_id  );
       WSH_DEBUG_SV.log(l_module_name,'x_completion_status',x_completion_status);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return;
  END IF;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  'OM INTERFACING BATCH ' || TO_CHAR ( p_batch_id )  );
   END IF;
   --

   WSH_SHIP_CONFIRM_ACTIONS.l_currentDate := SYSDATE;

   --HVOP heali
   Interface_Stop_To_OM(
		p_batch_id        => p_batch_id ,
                x_return_status   => l_return_status);

   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Interface_Stop_To_OM l_return_status',l_return_status);
   END IF;


   l_prev_return_status := l_return_status;
   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN --{
      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN --{
         raise e_Interface_Stop_to_om;
      END IF; --}
   ELSE --}{
      l_completion_status := 'INTERFACED' ;
   END if; --}
   --HVOP heali
   -- Bug 2657652 : Added call to transfer serial records from mtl_serial_numbers_temp to wsh_serial_numbers
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'Calling TRANSFER_SERIAL_NUMBERS FOR ' || TO_CHAR ( p_batch_id ) );
   END IF;

   IF l_prev_return_status  <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
      transfer_serial_numbers (  p_batch_id => p_batch_id ,
                                 p_interfacing => 'OM',
                                 x_return_status =>  l_return_status );

      if (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         raise e_Interface_Stop_To_OM;
      end if;
   END IF;

   IF l_prev_return_status IN ( WSH_UTIL_CORE.G_RET_STS_WARNING,
                               WSH_UTIL_CORE.G_RET_STS_ERROR ) THEN --{

      -- filter out the failed stops from the batch.

      Filter_Stops_From_Batch (p_batch_id => p_batch_id,
                               p_stop_tab => p_stop_tab,
                               x_num_stops_removed => x_num_stops_removed,
                               x_stop_tab          => x_stop_tab,
                               x_return_status => l_dummy);

      WSH_UTIL_CORE.api_post_call(p_return_status    =>l_dummy,
                                x_num_warnings     =>l_num_warnings,
                                x_num_errors       =>l_num_errors);

      -- if x_stop_tab contains less rows than p_stop_tab then this shows
      -- there are some stops are removed from the batch and the rest of
      -- the stops can be processed as interfaced.

      IF x_stop_tab.COUNT < p_stop_tab.COUNT   THEN
         l_completion_status := 'INTERFACED';
      ELSE
         raise e_Interface_Stop_to_om;
      END IF;

   END IF; --}

   IF lock_row%ISOPEN THEN
     CLOSE lock_row;
   END IF;

   x_completion_status := l_completion_status;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_completion_status',x_completion_status);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
EXCEPTION
   when trip_stop_locked  Then
     IF lock_row%ISOPEN THEN
       CLOSE lock_row;
     END IF;
     WSH_UTIL_CORE.PrintMsg('This Trip Stop is locked by some other process');
     x_completion_status := 'WARNING';  -- continue processing other stops
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'TRIP_STOP_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:TRIP_STOP_LOCKED');
     END IF;
     --

   WHEN e_Interface_Stop_To_OM then
       WSH_UTIL_CORE.PrintMsg('Failed to interface Batch  '  ||  p_batch_id
            ||  '  to Order Management because API interface_header_to_OM failed');
       IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
         x_completion_status := 'ERROR';
       ELSE
         x_completion_status := 'WARNING';
       END IF;
       IF lock_row%ISOPEN THEN  -- bug 2598688: avoid invalid cursor
         CLOSE lock_row;
       END IF;
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'e_Interface_Stop_To_OM exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.log(l_module_name,'x_completion_status',x_completion_status);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:e_Interface_Stop_To_OM');
       END IF;
       --

   WHEN others then

--  todo: Use wsh_util_core.default_handler and then get_message and println
       WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || SQLERRM || to_char(SQLCODE));
       x_completion_status := 'ERROR';
       IF lock_row%ISOPEN THEN  -- bug 2598688: avoid invalid cursor
         CLOSE lock_row;
       END IF;
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
END oe_interface_trip_stop;


--========================================================================
-- FUNCTION : Is_OM_Bulk_Enable
--                  This API determines if the specic line is bulk enabled.
--
-- PARAMETERS: p_batch_id              The ITS batch ID
--             p_requested_quantity    requested Quantity
--             p_shipped_quantity      Shipped quantity.
--             p_requested_quantity2   secondary requested quantity
--             p_shipped_quantity2     secondary shipped quantity
--             p_top_model_line_id     The top model line id
--             p_ship_set_id           The ship set id
--             p_source_line_id        Source line id
--             p_source_header_id      Source header id
--
-- COMMENT   : This API determines if a line is bulk enabled.  A line is
--             considered to be bulk enabled if it meets the following
--             conditions:
--             1. Order lines should be shipped completely.
--                  bug 5688051: secondary shipped quantity should
--                               match secondary requested quantity
--                               if not null; this is to take care
--                               of lot-specific quantity conversion.
--             2. All the models belong to same TOP_MODEL_LINE should be
--                present in the batch being processed.
--             3. Lines being processed are not split in OM before.
--             4. All the lines belonging to the same ship set must be present
--                in the batch being processed.
--             5. For standard items, check if the source line is being shipped
--                completely and that there are no delivery details associated
--                with the same source line but not associated to the trip stop.
--
--========================================================================

FUNCTION Is_OM_Bulk_Enable(
      p_batch_id		IN	NUMBER,
      p_requested_quantity	IN	NUMBER,
      p_shipped_quantity	IN	NUMBER,
      p_requested_quantity2	IN	NUMBER,
      p_shipped_quantity2	IN	NUMBER,
      p_setsmc_input_rec	IN	OE_Shipping_Integration_PUB.Setsmc_Input_Rec_Type,
      p_source_line_id		IN	NUMBER,
      p_source_header_id        IN      NUMBER) RETURN boolean IS -- bug 3642085

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Is_OM_Bulk_Enable';


CURSOR top_model_line_csr(p_batch_id NUMBER, p_top_model_line_id NUMBER, p_source_header_id NUMBER) IS
SELECT  delivery_detail_id
FROM 	wsh_delivery_details wdd
WHERE   wdd.top_model_line_id = p_top_model_line_id
AND     wdd.source_header_id = p_source_header_id -- bug 3642085
AND     wdd.source_code = 'OE'                    -- bug 3642085
MINUS
SELECT  wdd.delivery_detail_id
  from wsh_delivery_details wdd,
       wsh_delivery_assignments_v wda,
       wsh_delivery_legs wdl,
       wsh_trip_stops wts
  where wts.batch_id = p_batch_id
  and   wdl.pick_up_stop_id = wts.stop_id
  and   wda.delivery_id = wdl.delivery_id
  and   wdd.delivery_detail_id = wda.delivery_detail_id
  and   wdd.container_flag = 'N'
  and   wdd.source_code = 'OE'
  AND     wdd.source_line_set_id IS NULL
  AND   wdd.source_header_id = p_source_header_id -- frontport of bug 4324971
  and   wdd.top_model_line_id = p_top_model_line_id;

CURSOR ship_set_line_csr(p_batch_id NUMBER, p_ship_set_id NUMBER, p_source_header_id NUMBER) IS
Select  delivery_detail_id
from 	wsh_delivery_details wdd
WHERE   wdd.ship_set_id = p_ship_set_id
AND     wdd.source_header_id = p_source_header_id -- bug 3642085
AND     wdd.source_code = 'OE'                    -- bug 3642085
MINUS
select wdd.delivery_detail_id
from wsh_delivery_details wdd,
       wsh_delivery_assignments_v wda,
       wsh_delivery_legs wdl,
       wsh_trip_stops wts
  where wts.batch_id = p_batch_id
  and   wdl.pick_up_stop_id = wts.stop_id
  and   wda.delivery_id = wdl.delivery_id
  and   wdd.delivery_detail_id = wda.delivery_detail_id
  and   wdd.container_flag = 'N'
  and   wdd.source_code = 'OE'
  AND     wdd.source_line_set_id IS NULL
  and   wdd.ship_set_id = p_ship_set_id;

CURSOR std_item_line_csr (p_batch_id NUMBER, p_source_line_id NUMBER) IS
SELECT   delivery_detail_id
from wsh_delivery_details wdd
WHERE   wdd.source_line_id = p_source_line_id
AND     wdd.source_code = 'OE'                    -- bug 3642085
MINUS
SELECT  wdd.delivery_detail_id
  from wsh_delivery_details wdd,
       wsh_delivery_assignments_v wda,
       wsh_delivery_legs wdl,
       wsh_trip_stops wts
  where wts.batch_id = p_batch_id
  and   wdl.pick_up_stop_id = wts.stop_id
  and   wda.delivery_id = wdl.delivery_id
  and   wdd.delivery_detail_id = wda.delivery_detail_id
  and   wdd.container_flag = 'N'
  and   wdd.source_code = 'OE'
  AND     wdd.source_line_set_id IS NULL
  and   wdd.source_line_id = p_source_line_id;

l_return_status			varchar2(1);
l_temp				NUMBER;
l_bulk				boolean ;
l_model_cache_tbl 		WSH_UTIL_CORE.boolean_tab_type;
l_model_cache_ext_tbl 		WSH_UTIL_CORE.boolean_tab_type;
l_ship_cache_tbl 		WSH_UTIL_CORE.boolean_tab_type;
l_ship_cache_ext_tbl 		WSH_UTIL_CORE.boolean_tab_type;
l_std_cache_tbl 		WSH_UTIL_CORE.boolean_tab_type;
l_std_cache_ext_tbl 		WSH_UTIL_CORE.boolean_tab_type;
l_setsmc_output_rec             OE_Shipping_Integration_PUB.Setsmc_Output_Rec_Type;
e_raise_others                  EXCEPTION;

BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_batch_id',P_batch_id);
       WSH_DEBUG_SV.log(l_module_name,'p_requested_quantity',p_requested_quantity);
       WSH_DEBUG_SV.log(l_module_name,'p_shipped_quantity',p_shipped_quantity);
       WSH_DEBUG_SV.log(l_module_name,'p_requested_quantity2',p_requested_quantity2);
       WSH_DEBUG_SV.log(l_module_name,'p_shipped_quantity2',p_shipped_quantity2);
       WSH_DEBUG_SV.log(l_module_name,'top_model_line_id',p_setsmc_input_rec.top_model_line_id);
       WSH_DEBUG_SV.log(l_module_name,'ship_set_id',p_setsmc_input_rec.ship_set_id);
       WSH_DEBUG_SV.log(l_module_name,'p_source_line_id',p_source_line_id);
       WSH_DEBUG_SV.log(l_module_name,'p_source_header_id',p_source_header_id);
   END IF;


   IF     (p_requested_quantity =p_shipped_quantity)
      AND (nvl(p_requested_quantity2,0) = nvl(p_shipped_quantity2,0))
         THEN -- {
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Request qty and  Shipped qty are equal.');
         END IF;

         -- Processing Model Line
         IF (p_setsmc_input_rec.top_model_line_id is NOT NULL) THEN
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, ' Processing Model Line');
              END IF;

            --Check if bulk status is found for current top model line in cache
             WSH_UTIL_CORE.get_cached_value(
                             p_cache_tbl 	=> l_model_cache_tbl,
                             p_cache_ext_tbl 	=> l_model_cache_ext_tbl,
                             p_value 		=> l_bulk,
                             p_key 		=> p_setsmc_input_rec.top_model_line_id,
                             p_action 		=> 'GET',
                             x_return_status 	=> l_return_status) ;

            --IF (not found in cache) THEN
            IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN --{
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,
                    ' Calling OE_Shipping_Integration_PUB.Get_SetSMC_Interface_Status');
               END IF;
               OE_Shipping_Integration_PUB.Get_SetSMC_Interface_Status(
                   p_setsmc_input_rec    => p_setsmc_input_rec,
                   p_setsmc_output_rec   => l_setsmc_output_rec,
                   x_return_status       => l_return_status);

               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_return_status',
                                                             l_return_status);
                   WSH_DEBUG_SV.log(l_module_name,'x_interface_status',
                                    l_setsmc_output_rec.x_interface_status);
               END IF;
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  raise  FND_API.G_EXC_ERROR;
               END IF;

               IF l_setsmc_output_rec.x_interface_status = 'Y' THEN --{

                  OPEN  top_model_line_csr(p_batch_id,p_setsmc_input_rec.top_model_line_id, p_source_header_id);
                  FETCH top_model_line_csr INTO l_temp;

                  IF (top_model_line_csr%NOTFOUND) THEN
                   l_bulk:=true;
                  ELSE
                   l_bulk:=false;
                  END IF;

                  CLOSE top_model_line_csr;
               ELSE --}{
                  l_bulk:=false;
               END IF; --}

               --Cache top_model_id and bulk status.
               WSH_UTIL_CORE.get_cached_value(
                             p_cache_tbl 	=> l_model_cache_tbl,
                             p_cache_ext_tbl 	=> l_model_cache_ext_tbl,
                             p_value 		=> l_bulk,
                             p_key 		=> p_setsmc_input_rec.top_model_line_id,
                             p_action 		=> 'PUT',
                             x_return_status 	=> l_return_status) ;

               IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                  raise  FND_API.G_EXC_ERROR;
               END IF;

            ELSIF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN --}{
               raise  FND_API.G_EXC_ERROR;
            END IF; --}
         END IF;
         -- Processing Model Line


         -- Processing Ship Set Line
         IF (p_setsmc_input_rec.ship_set_id is NOT NULL)
              AND (NVL(l_bulk,TRUE) ) then
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, ' Processing Ship Set Line');
              END IF;

            --Check if bulk status is found for current ship_set line in cache
             WSH_UTIL_CORE.get_cached_value(
                             p_cache_tbl 	=> l_ship_cache_tbl,
                             p_cache_ext_tbl 	=> l_ship_cache_ext_tbl,
                             p_value 		=> l_bulk,
                             p_key 		=> p_setsmc_input_rec.ship_set_id,
                             p_action 		=> 'GET',
                             x_return_status 	=> l_return_status) ;

            --IF (not found in cache) THEN
            IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,
                    ' Calling OE_Shipping_Integration_PUB.Get_SetSMC_Interface_Status');
               END IF;
               OE_Shipping_Integration_PUB.Get_SetSMC_Interface_Status(
                   p_setsmc_input_rec    => p_setsmc_input_rec,
                   p_setsmc_output_rec   => l_setsmc_output_rec,
                   x_return_status       => l_return_status);

               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_return_status',
                                                             l_return_status);
                   WSH_DEBUG_SV.log(l_module_name,'x_interface_status',
                                    l_setsmc_output_rec.x_interface_status);
               END IF;

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  raise  FND_API.G_EXC_ERROR;
               END IF;
               IF l_setsmc_output_rec.x_interface_status = 'Y' THEN --{
                  OPEN  ship_set_line_csr(p_batch_id,p_setsmc_input_rec.ship_set_id, p_source_header_id);
                  FETCH ship_set_line_csr INTO l_temp;

                  IF (ship_set_line_csr%NOTFOUND) THEN
                   l_bulk:=true;
                  ELSE
                   l_bulk:=false;
                  END IF;

                  CLOSE ship_set_line_csr;
               ELSE --}{
                   l_bulk:=false;
               END IF; --}
               --Cache top_model_id and bulk status.
               WSH_UTIL_CORE.get_cached_value(
                             p_cache_tbl 	=> l_ship_cache_tbl,
                             p_cache_ext_tbl 	=> l_ship_cache_ext_tbl,
                             p_value 		=> l_bulk,
                             p_key 		=> p_setsmc_input_rec.ship_set_id,
                             p_action 		=> 'PUT',
                             x_return_status 	=> l_return_status) ;

               IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                  raise  FND_API.G_EXC_ERROR;
               END IF;
            ELSIF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
               raise  FND_API.G_EXC_ERROR;
            END IF;
         END IF;
         -- Processing Ship Set Line


         --Standard item
         IF (p_setsmc_input_rec.ship_set_id is NULL
            And p_setsmc_input_rec.top_model_line_id IS NULL) then
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, ' Processing Standard Line');
              END IF;

            --Check if bulk status is found for current ato_line in cache
             WSH_UTIL_CORE.get_cached_value(
                             p_cache_tbl 	=> l_std_cache_tbl,
                             p_cache_ext_tbl 	=> l_std_cache_ext_tbl,
                             p_value 		=> l_bulk,
                             p_key 		=> p_source_line_id,
                             p_action 		=> 'GET',
                             x_return_status 	=> l_return_status) ;

            --IF (not found in cache) THEN
            IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
               OPEN  std_item_line_csr(p_batch_id,p_source_line_id);
               FETCH std_item_line_csr INTO l_temp;

               IF (std_item_line_csr%NOTFOUND) THEN
                l_bulk:=true;
               ELSE
                l_bulk:=false;
               END IF;
               CLOSE std_item_line_csr;

               --Cache top_model_id and bulk status.
               WSH_UTIL_CORE.get_cached_value(
                             p_cache_tbl 	=> l_std_cache_tbl,
                             p_cache_ext_tbl 	=> l_std_cache_ext_tbl,
                             p_value 		=> l_bulk,
                             p_key 		=> p_source_line_id,
                             p_action 		=> 'PUT',
                             x_return_status 	=> l_return_status) ;

               IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                  raise  FND_API.G_EXC_ERROR;
               END IF;
            ELSIF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
               raise  FND_API.G_EXC_ERROR;
            END IF;
         END IF;
         --Standard item

   ELSE -- }{
         -- Request qty and  Shipped qty are not equal.
         l_bulk:=FALSE;
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Request qty and  Shipped qty are not equal. l_bulk is FALSE');
         END IF;
   END IF; -- }


   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;

   RETURN NVL(l_bulk, FALSE);
EXCEPTION
 WHEN others THEN
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'UNEXPECTED ERROR IN Is_OM_Bulk_Enable' );
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                  WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   raise e_raise_others;
END Is_OM_Bulk_Enable;


--========================================================================
-- PROCEDURE : print_ship_line
--                  This API prints debug information for the PLSQL table, which
--                  is being passed to OM to be interfaced.
--
-- PARAMETERS: p_bulk_mode             Bulk mode for OM interface
--             p_ship_line             Record of tables to be printed
--             p_start_index           Start index for p_ship_line.
--             p_end_index             End index for p_end_index.
--
-- COMMENT   : If p_start_index and p_end_index is passed then prints the
--             information for the rows (table p_ship_line) between these 2
--             indexes, else if print the whole table.
--
--========================================================================

PROCEDURE print_ship_line (p_bulk_mode		IN	varchar2,
			   p_ship_line	        IN OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type,
			   p_start_index	IN number default null,
			   p_end_index		IN number default null) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'print_ship_line';

l_start_index	number;
l_end_index	number;

BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'p_start_index',p_start_index);
       WSH_DEBUG_SV.log(l_module_name,'p_end_index',p_end_index);
   END IF;
 IF (p_start_index is null or p_end_index is null) THEN
  l_start_index := p_ship_line.fulfilled_flag.first;
  l_end_index := p_ship_line.fulfilled_flag.last;
 ELSE
  l_start_index := p_start_index;
  l_end_index := p_end_index;
 END IF;


   IF l_debug_on THEN

 IF (p_bulk_mode='N') THEN
 FOR i IN l_start_index..l_end_index LOOP

 WSH_DEBUG_SV.logmsg(l_module_name,'#########NON BULK##############');
 WSH_DEBUG_SV.log(l_module_name,'Index',i);
 WSH_DEBUG_SV.log(l_module_name,'fulfilled_flag',p_ship_line.fulfilled_flag(i));
 WSH_DEBUG_SV.log(l_module_name,'actual_shipment_date',p_ship_line.actual_shipment_date(i));
 WSH_DEBUG_SV.log(l_module_name,'shipping_quantity2',p_ship_line.shipping_quantity2(i));
 WSH_DEBUG_SV.log(l_module_name,'shipping_quantity',p_ship_line.shipping_quantity(i));
 WSH_DEBUG_SV.log(l_module_name,'shipping_quantity_uom2',p_ship_line.shipping_quantity_uom2(i));
 WSH_DEBUG_SV.log(l_module_name,'shipping_quantity_uom',p_ship_line.shipping_quantity_uom(i));
 WSH_DEBUG_SV.log(l_module_name,'line_id',p_ship_line.line_id(i));
 WSH_DEBUG_SV.log(l_module_name,'header_id',p_ship_line.header_id(i));
 WSH_DEBUG_SV.log(l_module_name,'top_model_line_id',p_ship_line.top_model_line_id(i));
 WSH_DEBUG_SV.log(l_module_name,'ato_line_id',p_ship_line.ato_line_id(i));
 WSH_DEBUG_SV.log(l_module_name,'ship_set_id',p_ship_line.ship_set_id(i));
 WSH_DEBUG_SV.log(l_module_name,'arrival_set_id',p_ship_line.arrival_set_id(i));
 WSH_DEBUG_SV.log(l_module_name,'inventory_item_id',p_ship_line.inventory_item_id(i));
 WSH_DEBUG_SV.log(l_module_name,'ship_from_org_id',p_ship_line.ship_from_org_id(i));
 WSH_DEBUG_SV.log(l_module_name,'line_set_id',p_ship_line.line_set_id(i));
 WSH_DEBUG_SV.log(l_module_name,'smc_flag',p_ship_line.smc_flag(i));
 WSH_DEBUG_SV.log(l_module_name,'over_ship_reason_code',p_ship_line.over_ship_reason_code(i));
 WSH_DEBUG_SV.log(l_module_name,'requested_quantity',p_ship_line.requested_quantity(i));
 WSH_DEBUG_SV.log(l_module_name,'requested_quantity2',p_ship_line.requested_quantity2(i));
 WSH_DEBUG_SV.log(l_module_name,'pending_quantity',p_ship_line.pending_quantity(i));
 WSH_DEBUG_SV.log(l_module_name,'pending_quantity2',p_ship_line.pending_quantity2(i));
 WSH_DEBUG_SV.log(l_module_name,'pending_requested_flag',p_ship_line.pending_requested_flag(i));
 WSH_DEBUG_SV.log(l_module_name,'order_quantity_uom',p_ship_line.order_quantity_uom(i));
 WSH_DEBUG_SV.log(l_module_name,'order_quantity_uom2',p_ship_line.order_quantity_uom2(i));
 WSH_DEBUG_SV.log(l_module_name,'model_remnant_flag',p_ship_line.model_remnant_flag(i));
 WSH_DEBUG_SV.log(l_module_name,'ordered_quantity',p_ship_line.ordered_quantity(i));
 WSH_DEBUG_SV.log(l_module_name,'ordered_quantity2',p_ship_line.ordered_quantity2(i));
 WSH_DEBUG_SV.log(l_module_name,'item_type_code',p_ship_line.item_type_code(i));
 WSH_DEBUG_SV.log(l_module_name,'calculate_price_flag',p_ship_line.calculate_price_flag(i));

 END LOOP;

 ELSE
 FOR i IN l_start_index..l_end_index LOOP

 WSH_DEBUG_SV.logmsg(l_module_name,'#########BULK##############');
 WSH_DEBUG_SV.log(l_module_name,'Index',i);
 WSH_DEBUG_SV.log(l_module_name,'header_id',p_ship_line.header_id(i));
 WSH_DEBUG_SV.log(l_module_name,'line_id',p_ship_line.line_id(i));
 WSH_DEBUG_SV.log(l_module_name,'top Model line_id',p_ship_line.top_model_line_id(i));
 WSH_DEBUG_SV.log(l_module_name,'ship set line_id',p_ship_line.ship_set_id(i));
 WSH_DEBUG_SV.log(l_module_name,'arrival_set_id',p_ship_line.arrival_set_id(i));
 WSH_DEBUG_SV.log(l_module_name,'actual_shipment_date',p_ship_line.actual_shipment_date(i));
 WSH_DEBUG_SV.log(l_module_name,'shipping_quantity',p_ship_line.shipping_quantity(i));
 WSH_DEBUG_SV.log(l_module_name,'shipping_quantity_uom',p_ship_line.shipping_quantity_uom(i));
 WSH_DEBUG_SV.log(l_module_name,'shipping_quantity2',p_ship_line.shipping_quantity2(i));
 WSH_DEBUG_SV.log(l_module_name,'shipping_quantity_uom2',p_ship_line.shipping_quantity_uom2(i));
 WSH_DEBUG_SV.log(l_module_name,'flow_status_code',p_ship_line.flow_status_code(i));
 WSH_DEBUG_SV.log(l_module_name,'ordered_quantity',p_ship_line.ordered_quantity(i));
 WSH_DEBUG_SV.log(l_module_name,'ordered_quantity2',p_ship_line.ordered_quantity2(i));
 END LOOP;
 END IF;

      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
    WHEN others THEN

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END print_ship_line;


--========================================================================
-- PROCEDURE : Process_Stop_To_OM
--                  This API is called from Interface_Stop_To_OM to interface
--                  the lines to the OM.
--
-- PARAMETERS: p_batch_id              ITS batch id.
--             p_bulk_ship_line        Record of tables containing order line
--                                     information.
--             p_bulk_req_line         Record of tables containing additional
--                                     information for non-bulk enabled lines.
--             p_bulk_mode             Bulk mode for OM API
--             p_org_id                org_id for non-bulk lines.
--             x_freight_costs         PLSQL table containing the freight cost
--                                     for all the lines within the batch.
--             x_charges_are_calculated Boolean, indicates if the charges have
--                                     been calculated.
--             x_return_status         The return status of the API.
--
-- COMMENT   : For non bulk mode (p_bulk_mode = 'N') all the lines in tables
--             p_bulk_ship_line and p_bulk_req_line are passed to the OM
--             API for processing.  If profile option WSH_BULK_BATCH_SIZE
--             contains a batch size and the processing mode is Bulk mode then
--             the lines in table p_bulk_ship_line are passed to OM API in
--             bulk size chunks.  Also if table p_bulk_ship_line contains lines
--             with different org_id, then OM API is called once per org_id.
--             The freight charge for each order line is calculated and passed
--             to OM API.  The first time Process_Stop_To_OM is called, all the
--             freight charges for all the lines within the batch is calculated
--             and put in table x_freight_costs.  Then for all the lines being
--             passed to OM API, the corresponding freight charges will be
--             retrieved from table x_freight_costs and passed to the OM API.
--
--========================================================================

PROCEDURE Process_Stop_To_OM (
        p_batch_id         IN    	NUMBER,
        p_bulk_ship_line  IN OUT NOCOPY OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type,
        p_bulk_req_line   IN OUT NOCOPY OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type,
        p_bulk_mode       IN    	varchar2,
        p_org_id       	  IN    	NUMBER DEFAULT NULL,
        x_freight_costs   IN OUT NOCOPY OE_Ship_Confirmation_Pub.Ship_Adj_Rec_Type,
        x_charges_are_calculated IN OUT NOCOPY BOOLEAN ,
        x_return_status   IN OUT NOCOPY varchar2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Stop_To_OM';

process_freight_costs_failed 	EXCEPTION;

l_return_status		varchar2(1);
l_summary               VARCHAR2(3000);
x_msg_count		number;
x_msg_data		VARCHAR2(3000);

l_freight_costs_all     WSH_FC_INTERFACE_PKG.OMInterfaceCostTabType;
l_ship_adj_line_all	OE_Ship_Confirmation_Pub.Ship_Adj_Rec_Type;
l_ship_adj_line		OE_Ship_Confirmation_Pub.Ship_Adj_Rec_Type;

l_total_count		NUMBER:=0;
l_start_index		NUMBER;
l_end_index		NUMBER;
l_dummy                 NUMBER;
l_error_count		NUMBER:=0;
l_warn_count		NUMBER:=0;
l_loop_count		NUMBER:=0;
l_count			NUMBER:=0;
l_row_count			NUMBER:=0;
l_bulk_count		NUMBER := 0;
l_line_idx              NUMBER;
l_charge_idx            NUMBER;
l_counter               NUMBER;
l_lines_tab             OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM();
l_stop_id               NUMBER;
l_bulk_batch_size       NUMBER;
l_index                 NUMBER;
x                       number;
l_prev_org_id           NUMBER ;
l_org_change            BOOLEAN ;
l_header_id		NUMBER;

CURSOR c_get_batch_stops (p_batch_id NUMBER) IS
SELECT stop_id
FROM wsh_trip_stops
WHERE batch_id = p_batch_id
ORDER BY stop_id ;

CURSOR c_get_stop_lines (p_stop_id NUMBER) IS
SELECT  wdd.source_line_id
FROM wsh_delivery_details wdd,
     wsh_trip_stops wts,
     wsh_delivery_legs wdl,
     wsh_delivery_assignments_v wda
WHERE wts.stop_id = p_stop_id
AND   wdl.pick_up_stop_id = wts.stop_id
AND   wdl.delivery_id = wda.delivery_id
AND   wdd.delivery_detail_id = wda.delivery_detail_id
AND   nvl(wdd.LINE_DIRECTION , 'O') IN ('O', 'IO')
AND   wdd.released_status = 'C'
AND   wdd.container_flag='N'
AND   wdd.oe_interfaced_flag <> 'Y'
AND   wdd.source_code = 'OE'
ORDER BY wdd.source_line_id;

e_next_record   EXCEPTION;

--hadcp
l_dcp_profile	NUMBER;
l_oe_interfaced_flag VARCHAR2(1);
l_container_flag VARCHAR2(1);
l_source_code VARCHAR2(2);
l_released_status VARCHAR2(2);
--hadcp
BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
       WSH_DEBUG_SV.log(l_module_name,'p_bulk_mode',p_bulk_mode);
       WSH_DEBUG_SV.log(l_module_name,'p_org_id',p_org_id);
       WSH_DEBUG_SV.log(l_module_name,'p_bulk_ship_line.count',p_bulk_ship_line.line_id.count);
       WSH_DEBUG_SV.log(l_module_name,'p_bulk_req_line.count',p_bulk_req_line.line_id.count);
       WSH_DEBUG_SV.log(l_module_name,'x_charges_are_calculated',x_charges_are_calculated);
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



   IF (p_bulk_mode='N') THEN

      l_header_id := p_bulk_ship_line.header_id(p_bulk_ship_line.header_id.FIRST);
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_header_id',l_header_id);
      END IF;

--R12:MOAC replace call, updated comment
      --Set the Policy Context for non bulk
      MO_GLOBAL.set_policy_context('S', p_org_id);
   END IF;


   FND_PROFILE.Get('WSH_BULK_BATCH_SIZE',l_bulk_batch_size);

   --hadcp
   WSH_DCP_PVT.G_CALL_DCP_CHECK := 'N';
   l_dcp_profile := WSH_DCP_PVT.G_CHECK_DCP;

   IF l_dcp_profile IS NULL THEN
       l_dcp_profile := wsh_dcp_pvt.is_dcp_enabled;
   END IF;

   --hadcp

   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_bulk_batch_size',l_bulk_batch_size);
       WSH_DEBUG_SV.log(l_module_name,'l_dcp_profile',l_dcp_profile);
   END IF;


   -- Calculate the charges for all the stops in the batch and save it into
   -- the table x_freight_costs.  If this calculation has been done once, skip
   -- this step.

   --IF x_freight_costs.line_id.COUNT = 0 THEN
   IF NOT x_charges_are_calculated THEN --{

      -- get all the stops with this batch_id

      OPEN c_get_batch_stops (p_batch_id);
      LOOP --{
         FETCH c_get_batch_stops INTO l_stop_id;
         EXIT WHEN c_get_batch_stops%NOTFOUND;

         l_lines_tab.DELETE;

         -- get all the source_lines for the stop

         OPEN c_get_stop_lines(l_stop_id);
         FETCH c_get_stop_lines BULK COLLECT INTO
            l_lines_tab;
         CLOSE c_get_stop_lines;

         l_start_index := l_lines_tab.FIRST;

         -- calculate the charges for each stop


         WSH_FC_INTERFACE_PKG.Process_Freight_Costs(
              p_stop_id           => l_stop_id,
              p_start_index	    => l_start_index,
              p_line_id_tbl       => l_lines_tab,
              x_freight_costs_all => l_freight_costs_all,
              x_freight_costs     => l_ship_adj_line_all,
              x_end_index	    => l_dummy,
              x_return_status     => l_return_status);


         IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          WSH_DEBUG_SV.log(l_module_name,'stop id',l_stop_id);
          WSH_DEBUG_SV.log(l_module_name,'l_lines_tab.count',
                                                        l_lines_tab.COUNT);
          WSH_DEBUG_SV.log(l_module_name,'l_ship_adj_line_all.line_id.count',l_ship_adj_line_all.line_id.count);
         END IF;


         IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RAISE process_freight_costs_failed;
         END IF;

         l_freight_costs_all.DELETE;

      END LOOP; --}

      x_freight_costs := l_ship_adj_line_all;
      x_charges_are_calculated := TRUE;
   END IF; --}


   l_row_count := p_bulk_ship_line.line_id.count;
   l_end_index := l_row_count;
   l_start_index := p_bulk_ship_line.line_id.first;

   IF (p_bulk_mode) = 'Y' AND (l_start_index IS NOT NULL) THEN
      l_prev_org_id := p_bulk_ship_line.org_id(l_start_index);
--R12:MOAC replace call
      MO_GLOBAL.set_policy_context('S', l_prev_org_id);
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'setting the org',l_prev_org_id);
      END IF;
   END IF;

   --hadcp
   IF (l_dcp_profile IN (1,2) ) THEN
      WSH_DCP_PVT.G_INIT_MSG_COUNT := fnd_msg_pub.count_msg;
   END IF;
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Outside Loop WSH_DCP_PVT.G_INIT_MSG_COUNT',WSH_DCP_PVT.G_INIT_MSG_COUNT);
   END IF;
   --hadcp

   l_line_idx := l_start_index;
   l_counter := 1;

   WHILE (l_line_idx IS NOT NULL) LOOP --{
    BEGIN --{ DCP Block

      BEGIN --{

         l_org_change := FALSE;

         IF p_bulk_mode = 'Y' THEN --{
            IF l_prev_org_id <> p_bulk_ship_line.org_id(l_line_idx) THEN
               l_prev_org_id := p_bulk_ship_line.org_id(l_line_idx);
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'l_prev_org_id', l_prev_org_id);
                  WSH_DEBUG_SV.log(l_module_name,'l_line_idx', l_line_idx);
                  WSH_DEBUG_SV.log(l_module_name,'l_bulk_count', l_bulk_count);
               END IF;
               IF l_bulk_count > 0 THEN
                  l_org_change := TRUE;
                  l_line_idx := p_bulk_ship_line.line_id.PRIOR(l_line_idx);
               END IF;
            END IF;
         END IF; --}
         IF NOT l_org_change THEN --{
            l_bulk_count := l_bulk_count + 1;
            --bsadri from table x_freight_costs  select only the charges needed
            --for p_bulk_ship_line.line_id table
            -- put this charges in table l_ship_adj_line

            l_charge_idx := x_freight_costs.line_id.FIRST;
            WHILE l_charge_idx IS NOT NULL LOOP --{
               IF p_bulk_ship_line.line_id(l_line_idx) =
                                     x_freight_costs.line_id(l_charge_idx)
               THEN --{
                  l_ship_adj_line.cost_id.extend;
                  l_ship_adj_line.automatic_flag.extend;
                  l_ship_adj_line.list_line_type_code.extend;
                  l_ship_adj_line.charge_type_code.extend;
                  l_ship_adj_line.header_id.extend;
                  l_ship_adj_line.line_id.extend;
                  l_ship_adj_line.adjusted_amount.extend;
                  l_ship_adj_line.arithmetic_operator.extend;
                  l_ship_adj_line.operation.extend;

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'charge matched', p_bulk_ship_line.line_id(l_line_idx));
                  END IF;

                  l_ship_adj_line.cost_id(l_counter) :=
                             x_freight_costs.cost_id(l_charge_idx);
                  l_ship_adj_line.automatic_flag(l_counter) :=
                             x_freight_costs.automatic_flag(l_charge_idx);
                  l_ship_adj_line.list_line_type_code(l_counter) :=
                             x_freight_costs.list_line_type_code(l_charge_idx);
                  l_ship_adj_line.charge_type_code(l_counter) :=
                             x_freight_costs.charge_type_code(l_charge_idx);
                  l_ship_adj_line.header_id(l_counter) :=
                             x_freight_costs.header_id(l_charge_idx);
                  l_ship_adj_line.line_id(l_counter) :=
                             x_freight_costs.line_id(l_charge_idx);
                  l_ship_adj_line.adjusted_amount(l_counter) :=
                             x_freight_costs.adjusted_amount(l_charge_idx);
                  l_ship_adj_line.arithmetic_operator(l_counter) :=
                             x_freight_costs.arithmetic_operator(l_charge_idx);
                  l_ship_adj_line.operation(l_counter) :=
                             x_freight_costs.operation(l_charge_idx);
                  l_counter := l_counter + 1;
                  l_bulk_count := l_bulk_count + 1;

               END IF ;--}

               l_charge_idx := x_freight_costs.line_id.NEXT(l_charge_idx);

            END LOOP ; --}
         END IF; --}

         --bsadri Find out if the BULK limit is reached or the loop is
         -- exhouseted

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'After while Loop');
         END IF;
         IF l_org_change THEN  --{
            l_end_index := l_line_idx;
         ELSE --}{
            IF l_line_idx < l_row_count THEN --{
               IF (l_bulk_batch_size IS NOT NULL)
                AND (p_bulk_mode = 'Y' )THEN --{
                  IF l_bulk_count >= l_bulk_batch_size THEN --{
                     l_end_index := l_line_idx;
                  ELSE --}{
                     raise e_next_record;
                  END IF ; --}
               ELSE --}{
                  raise e_next_record;
               END IF; --}
            ELSE --}{
               l_end_index := l_line_idx;
            END IF; --}
         END IF; --}

         l_loop_count := l_loop_count + 1;
         l_counter := 1;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Establishing save point l_interface_om');
         END IF;
         Savepoint l_interface_om;

          l_oe_interfaced_flag := 'P';
          l_container_flag := 'N';
          l_source_code := 'OE';
          l_released_status := 'D';
          -- bug 3761090
          FORALL i IN l_start_index..l_end_index
          UPDATE wsh_delivery_details dd
          SET    oe_interfaced_flag = l_oe_interfaced_flag ,
                 --Added as part of bug 7645262
                 last_update_date    = sysdate,
                 request_id          = fnd_global.conc_request_id,
                 last_updated_by     = fnd_global.user_id
          WHERE  source_line_id = p_bulk_ship_line.line_id(i)
          and container_flag = l_container_flag
          and source_code = l_source_code
          and released_status <> l_released_status
          and dd.delivery_detail_id in  (
            SELECT  /*+ no_unnest */ da.delivery_detail_id
            FROM wsh_delivery_assignments_v da ,
                  wsh_delivery_legs dg,
                  wsh_new_deliveries dl,
                  wsh_trip_stops st
            where   da.delivery_detail_id = dd.delivery_detail_id  AND
                  dl.delivery_id = da.delivery_id  AND
                  da.delivery_id  IS NOT NULL AND
                  st.stop_id = dg.pick_up_stop_id AND
                  st.batch_id = p_batch_id AND
                  st.stop_location_id = dl.initial_pickup_location_id AND
                  dg.delivery_id = dl.delivery_id
             );


         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'After Forall Update');
            WSH_DEBUG_SV.logmsg(l_module_name,'Printing P_ship_line_rec');
            print_ship_line(p_bulk_mode,p_bulk_ship_line,l_start_index,l_end_index);
            WSH_DEBUG_SV.log(l_module_name,'Calling OE_Ship_Confirmation_Pub.Ship_Confirm_New TIME:',SYSDATE);
         END IF;
         OE_Ship_Confirmation_Pub.Ship_Confirm_New(
           P_ship_line_rec         => p_bulk_ship_line,
           P_requested_line_rec    => p_bulk_req_line,
           P_line_adj_rec          => l_ship_adj_line,
           P_bulk_mode             => p_bulk_mode,
           P_start_index		=> l_start_index,
           P_end_index		=> l_end_index,
           x_msg_count             => x_msg_count,
           x_msg_data              => x_msg_data,
           x_return_status         => l_return_status);

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'After OE_Shipping_Integration_PUB.Ship_Confirm_New TIME:',SYSDATE);
            WSH_DEBUG_SV.log(l_module_name,'l_return_status ',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name, 'NO. OF OE MESSAGES :'||X_MSG_COUNT  );
         END IF;

         WSH_UTIL_CORE.printmsg('no. of OE messages :'||x_msg_count);

         FOR k IN 1 .. nvl(x_msg_count,0)
         LOOP
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_MSG_PUB.GET',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            x_msg_data := oe_msg_pub.get( p_msg_index => k,
            p_encoded => 'F'
            );
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, SUBSTR ( X_MSG_DATA , 1 , 255 ) );
            END IF;
            --
            WSH_UTIL_CORE.printmsg('Error msg: '||substr(x_msg_data,1,2000));
         END LOOP;

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
           AND p_bulk_mode='N' THEN

              -- for non-bulk mode handle warnings as error;

              l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

         END IF;


         IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'SUCCESS');
            END IF;

         --Bug 3482227
         IF (p_bulk_mode='N') THEN
            --Bug 3761090
            l_oe_interfaced_flag := 'Y';
            l_container_flag := 'N';
            l_source_code := 'OE';
            l_released_status := 'D';

            UPDATE wsh_delivery_details dd
            set   oe_interfaced_flag = l_oe_interfaced_flag ,
                  --Added as part of bug 7645262
                  last_update_date    = sysdate,
                  request_id          = fnd_global.conc_request_id,
                  last_updated_by     = fnd_global.user_id
            where  delivery_detail_id in  (
                   SELECT da.delivery_detail_id
                   FROM wsh_delivery_assignments_v da ,
                         wsh_delivery_legs dg,
                         wsh_new_deliveries dl,
                         wsh_trip_stops st,
                         oe_order_lines_all ol
                   where   da.delivery_detail_id = dd.delivery_detail_id  AND
                         dl.delivery_id = da.delivery_id  AND
                         da.delivery_id  IS NOT NULL AND
                         st.stop_id = dg.pick_up_stop_id AND
                         st.batch_id = p_batch_id AND
                         st.stop_location_id = dl.initial_pickup_location_id AND
                         dg.delivery_id = dl.delivery_id  AND
                         ol.line_id = dd.source_line_id AND
                         ol.shipped_quantity > 0
                    )
            and dd.source_header_id = l_header_id
            and container_flag = l_container_flag
            and source_code = l_source_code
            and released_status <> l_released_status;
          ELSE
            --Bug 3761090
            l_oe_interfaced_flag := 'Y';
            l_container_flag := 'N';
            l_source_code := 'OE';
            l_released_status := 'D';

            FORALL i IN l_start_index..l_end_index
            UPDATE wsh_delivery_details dd
            SET    oe_interfaced_flag = l_oe_interfaced_flag ,
                   --Added as part of bug 7645262
                   last_update_date    = sysdate,
                   request_id          = fnd_global.conc_request_id,
                   last_updated_by     = fnd_global.user_id

            WHERE  source_line_id = p_bulk_ship_line.line_id(i)
            and container_flag = l_container_flag
            and source_code = l_source_code
            and released_status <> l_released_status
            and dd.delivery_detail_id in  (
              SELECT  /*+ no_unnest */ da.delivery_detail_id
              FROM wsh_delivery_assignments_v da ,
                    wsh_delivery_legs dg,
                    wsh_new_deliveries dl,
                    wsh_trip_stops st
              where   da.delivery_detail_id = dd.delivery_detail_id  AND
                    dl.delivery_id = da.delivery_id  AND
                    da.delivery_id  IS NOT NULL AND
                    st.stop_id = dg.pick_up_stop_id AND
                    st.batch_id = p_batch_id AND
                    st.stop_location_id = dl.initial_pickup_location_id AND
                    dg.delivery_id = dl.delivery_id
               );

           END IF;

            l_count := SQL%ROWCOUNT;
            IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'No. Success Rec. Update to Y', l_count);
            END IF;

            --hadcp
            IF (l_dcp_profile IN (1,2)  ) THEN
               WSH_DCP_PVT.Check_ITS(
           		P_bulk_mode     => p_bulk_mode,
           		P_start_index	=> l_start_index,
           		P_end_index	=> l_end_index,
                        P_its_rec 	=> p_bulk_ship_line);
            END IF;
            IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'No DCP Error');
            END IF;

            IF (l_dcp_profile IN (1,2) ) THEN
               WSH_DCP_PVT.G_INIT_MSG_COUNT := fnd_msg_pub.count_msg;
            END IF;
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Inside Loop WSH_DCP_PVT.G_INIT_MSG_COUNT',WSH_DCP_PVT.G_INIT_MSG_COUNT);
            END IF;
            --hadcp

            commit;
         ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'WARNING');
            END IF;
            l_warn_count := l_warn_count + 1;
            --Bug 3761090
            l_container_flag := 'N';
            l_source_code := 'OE';
            l_released_status := 'D';
            FORALL i IN l_start_index..l_end_index
             UPDATE wsh_delivery_details dd
             SET oe_interfaced_flag = Decode(p_bulk_ship_line.error_flag(i),'Y','N','Y') ,
                 --Added as part of bug 7645262
                 last_update_date    = sysdate,
                 request_id          = fnd_global.conc_request_id,
                 last_updated_by     = fnd_global.user_id
             WHERE  source_line_id = p_bulk_ship_line.line_id(i)
             and container_flag = l_container_flag
             and source_code = l_source_code
             and released_status <> l_released_status
             and dd.delivery_detail_id in  (
               SELECT /*+ no_unnest */ da.delivery_detail_id
               FROM wsh_delivery_assignments_v da ,
                     wsh_delivery_legs dg,
                     wsh_new_deliveries dl,
                     wsh_trip_stops st
               where   da.delivery_detail_id = dd.delivery_detail_id  AND
                     dl.delivery_id = da.delivery_id  AND
                     da.delivery_id  IS NOT NULL AND
                     st.stop_id = dg.pick_up_stop_id AND
                     st.batch_id = p_batch_id AND
                     st.stop_location_id = dl.initial_pickup_location_id AND
                     dg.delivery_id = dl.delivery_id
                );


             l_count := SQL%ROWCOUNT;
             IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'No. Warning Rec. Update',l_count);
             END IF;

            --hadcp
            IF (l_dcp_profile IN (1,2)  ) THEN
               WSH_DCP_PVT.Check_ITS(
           		P_bulk_mode     => p_bulk_mode,
           		P_start_index	=> l_start_index,
           		P_end_index	=> l_end_index,
                        P_its_rec 	=> p_bulk_ship_line);
            END IF;
            IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'No DCP Error');
            END IF;

            IF (l_dcp_profile IN (1,2) ) THEN
               WSH_DCP_PVT.G_INIT_MSG_COUNT := fnd_msg_pub.count_msg;
            END IF;
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Inside Loop WSH_DCP_PVT.G_INIT_MSG_COUNT',WSH_DCP_PVT.G_INIT_MSG_COUNT);
            END IF;
            --hadcp

            commit;
         ELSE
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'ERROR');
            END IF;
             l_error_count := l_error_count + 1;

            --hadcp
             --Rollback to savepoint l_interface_om;

             IF (p_bulk_mode='Y') THEN
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint l_interface_om');
               END IF;
               ROLLBACK TO l_interface_om;
             ELSE
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint its_process_order_non_bulk');
               END IF;
               ROLLBACK TO its_process_order_non_bulk;
             END IF;

            IF (l_dcp_profile IN (1,2)  ) THEN
               WSH_DCP_PVT.Check_ITS(
           		P_bulk_mode       => p_bulk_mode,
           		P_start_index	  => l_start_index,
           		P_end_index	  => l_end_index,
                        P_its_rec 	  => p_bulk_ship_line,
                        p_raise_exception => 'N');

            END IF;
            IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'No DCP Error');
            END IF;

            IF (l_dcp_profile IN (1,2) ) THEN
               WSH_DCP_PVT.G_INIT_MSG_COUNT := fnd_msg_pub.count_msg;
            END IF;
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Inside Loop WSH_DCP_PVT.G_INIT_MSG_COUNT',WSH_DCP_PVT.G_INIT_MSG_COUNT);
            END IF;
            --hadcp
         END IF;
         l_start_index := l_end_index + 1;

         IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'before deleting tables', l_start_index);
         END IF;
         l_bulk_count := 0;
         l_ship_adj_line.cost_id.DELETE;
         l_ship_adj_line.automatic_flag.DELETE;
         l_ship_adj_line.list_line_type_code.DELETE;
         l_ship_adj_line.charge_type_code.DELETE;
         l_ship_adj_line.header_id.DELETE;
         l_ship_adj_line.line_id.DELETE;
         l_ship_adj_line.adjusted_amount.DELETE;
         l_ship_adj_line.arithmetic_operator.DELETE;
         l_ship_adj_line.operation.DELETE;


      EXCEPTION
         WHEN e_next_record THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Exception e_next_record');
            END IF;

            NULL;
      END ; --}

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'current index',l_line_idx);
      END IF;

      l_line_idx := p_bulk_ship_line.line_id.NEXT(l_line_idx);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'next index',l_line_idx);
      END IF;

      IF l_org_change THEN --{
--R12:MOAC replace call
         MO_GLOBAL.set_policy_context('S', l_prev_org_id);
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'setting the org', l_prev_org_id);
            WSH_DEBUG_SV.log(l_module_name,'l_line_idx', l_line_idx);
            WSH_DEBUG_SV.log(l_module_name,'l_bulk_count', l_bulk_count);
         END IF;
      END IF; --}

    --hadcp
    EXCEPTION
       WHEN WSH_DCP_PVT.data_inconsistency_exception THEN
         IF NOT l_debug_on OR  l_debug_on is null THEN
           l_debug_on := wsh_debug_sv.is_debug_enabled;
         END IF;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'DCP Exception');
         END IF;

         IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_WARNING, WSH_UTIL_CORE.G_RET_STS_SUCCESS)) THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'DCP Rollback');
            END IF;

               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint l_interface_om');
               END IF;
               ROLLBACK TO l_interface_om;

         END IF;

         l_line_idx := l_start_index;

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'DCP before deleting tables', l_start_index);
         END IF;
         l_bulk_count := 0;
         l_ship_adj_line.cost_id.DELETE;
         l_ship_adj_line.automatic_flag.DELETE;
         l_ship_adj_line.list_line_type_code.DELETE;
         l_ship_adj_line.charge_type_code.DELETE;
         l_ship_adj_line.header_id.DELETE;
         l_ship_adj_line.line_id.DELETE;
         l_ship_adj_line.adjusted_amount.DELETE;
         l_ship_adj_line.arithmetic_operator.DELETE;
         l_ship_adj_line.operation.DELETE;

         l_loop_count := l_loop_count - 1;
    END; --} DCP Block
    --hadcp
   END LOOP; --}


   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_loop_count',l_loop_count);
       WSH_DEBUG_SV.log(l_module_name,'l_error_count',l_error_count);
       WSH_DEBUG_SV.log(l_module_name,'l_warn_count',l_warn_count);
   END IF;

   IF (l_error_count = l_loop_count ) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Process Order Error', WSH_DEBUG_SV.C_EXCEP_LEVEL);
      END IF;

      --hadcp
      IF (p_bulk_mode='N') THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint its_process_order_non_bulk');
         END IF;
         ROLLBACK TO its_process_order_non_bulk;
      END IF;
      --hadcp

   ELSIF (l_warn_count > 0 OR (l_error_count > 0 and l_error_count < l_loop_count) ) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Process Order Warning'||WSH_DEBUG_SV.C_EXCEP_LEVEL);
      END IF;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN process_freight_costs_failed THEN
      WSH_UTIL_CORE.PrintMsg('process_freight_costs_failed');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'PROCESS_FREIGHT_COSTS_FAILED exception has occured.',
                                                                         WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:PROCESS_FREIGHT_COSTS_FAILED');
      END IF;

      --Rollback to savepoint l_interface_om;

      --hadcp
      IF (p_bulk_mode='N') THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint its_process_order_non_bulk');
         END IF;
         ROLLBACK TO its_process_order_non_bulk;
      END IF;
      --hadcp


   WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.printMsg('API Process_Stop_To_OM failed with an unexpected error');
      WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || sqlerrm);

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'UNEXPECTED ERROR IN Process_Stop_To_OM' );
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

      --hadcp
      IF (p_bulk_mode='Y') THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint l_interface_om');
         END IF;
         Rollback to savepoint l_interface_om;
      ELSE
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint its_process_order_non_bulk');
         END IF;
         ROLLBACK TO its_process_order_non_bulk;
      END IF;
      --hadcp

END Process_Stop_To_OM;


--========================================================================
-- PROCEDURE : extend_om_ship_line
--                  This API extend the tables need to be passed to OM API.
--
-- PARAMETERS: p_ship_line             Record of the table
--             x_return_status         The return status of the API.
--
-- COMMENT   :
--
--========================================================================

PROCEDURE extend_om_ship_line (
	p_ship_line		IN OUT NOCOPY OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type,
	x_return_status	OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'extend_om_ship_line';

BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'p_ship_line.fulfilled_flag.count', p_ship_line.fulfilled_flag.count);
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


 p_ship_line.fulfilled_flag.extend;
 p_ship_line.actual_shipment_date.extend;
 p_ship_line.shipping_quantity2.extend;
 p_ship_line.shipping_quantity.extend;
 p_ship_line.shipping_quantity_uom2.extend;
 p_ship_line.shipping_quantity_uom.extend;
 p_ship_line.line_id.extend;
 p_ship_line.header_id.extend;
 p_ship_line.top_model_line_id.extend;
 p_ship_line.ato_line_id.extend;
 p_ship_line.ship_set_id.extend;
 p_ship_line.arrival_set_id.extend;
 p_ship_line.inventory_item_id.extend;
 p_ship_line.ship_from_org_id.extend;
 p_ship_line.line_set_id.extend;
 p_ship_line.smc_flag.extend;
 p_ship_line.over_ship_reason_code.extend;
 p_ship_line.requested_quantity.extend;
 p_ship_line.requested_quantity2.extend;
 p_ship_line.pending_quantity.extend;
 p_ship_line.pending_quantity2.extend;
 p_ship_line.pending_requested_flag.extend;
 p_ship_line.order_quantity_uom.extend;
 p_ship_line.order_quantity_uom2.extend;

 p_ship_line.model_remnant_flag.extend;
 p_ship_line.ordered_quantity.extend;
 p_ship_line.ordered_quantity2.extend;
 p_ship_line.item_type_code.extend;
 p_ship_line.calculate_price_flag.extend;


   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
    WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END extend_om_ship_line;



--========================================================================
-- PROCEDURE : Interface_Stop_To_OM
--                  This API is called from oe_interface_trip_stop to interface
--                  all the lines in the batch to the OM.
--
-- PARAMETERS: p_batch_id              ITS batch id.
--             x_return_status         The return status of the API.
--
-- COMMENT   : If all the lines in the batch are bulk enabled then they will
--             be bulk collected into a record of the tables and be passed to
--             procedure process_stop_to_om.  If not all the lines are bulk
--             enabled then loop through all the lines.  If a line is bulk
--             enabled, store it to a record of table, if the line is not bulk
--             enabled then store it in a different record of tables.  For
--             bulk enabled lines call process_stop_to_om once, for non-bulk
--             enabled lines call process_stop_to_om once per sale order.
--
--             For non-bulk enabled lines call Check_Tolerance to find out if
--             the line is fulfilled in OM.  If tolerance is specified for the
--             line, for a case of under shipment, call Get_Line_Expected_Qty
--             to see if lines have planned quantity.  If the line has planned
--             quantity then set the fulfilled flag as N. Then cancel the
--             pending delivery details.
--             If a shipment is beyond the tolerance limit then give warning to
--             the user.
--
--========================================================================

PROCEDURE Interface_Stop_To_OM(
          p_batch_id        IN  NUMBER,
          x_return_status   out NOCOPY  varchar2 )
IS
--wrudge
-- OM bug 2022029: added ato_line_id, sum(dd.requested_quantity2)
--           and requested_quantity2

--Bug 2177678 ,removed the use of oe_order_lines_all
--Now OM locks oe_order_lines_all table for the associated lines
CURSOR lock_delivery_line(p_batch_id NUMBER,c_source_header_id NUMBER,c_source_line_id NUMBER) IS
SELECT dd.source_line_id
FROM   wsh_delivery_Details dd,
   wsh_delivery_assignments_v da ,
   wsh_delivery_legs dg,
   wsh_new_deliveries dl,
   wsh_trip_stops st
WHERE st.stop_id = dg.pick_up_stop_id AND
   st.batch_id = p_batch_id AND
   st.stop_location_id = dl.initial_pickup_location_id AND
   dg.delivery_id = dl.delivery_id  AND
   dl.delivery_id = da.delivery_id  AND
   da.delivery_id IS NOT NULL AND
   da.delivery_detail_id = dd.delivery_detail_id
   and nvl ( dd.oe_interfaced_flag , 'N' )  <> 'Y'
   and dd.source_code = 'OE'
   and dd.source_header_id = c_source_header_id
   and dd.source_line_id = c_source_line_id
   and dd.released_status <> 'D'  /* H integration: wrudge */
for update nowait;

CURSOR lock_dds_line_set(c_source_header_id NUMBER,
                         c_source_line_set_id NUMBER,
                         c_batch_id NUMBER) IS
SELECT wdd.delivery_detail_id
FROM   wsh_delivery_details wdd
WHERE  wdd.source_code = 'OE'
AND    wdd.source_header_id = c_source_header_id
AND    wdd.source_line_set_id = c_source_line_set_id
AND    wdd.released_status <> 'D'
AND    Wdd.delivery_detail_id in (
         SELECT wda.delivery_detail_id
         FROM wsh_trip_stops wts,
         wsh_delivery_legs wdl,
         wsh_delivery_assignments_v wda
         where wts.batch_id = c_batch_id
         AND  wts.stop_id = wdl.pick_up_stop_id
         AND wdl.delivery_id = wda.delivery_id)
for    update nowait;

CURSOR lock_dds_line(c_source_header_id NUMBER, c_source_line_id NUMBER,
                     c_batch_id NUMBER) IS
SELECT wdd.delivery_detail_id
FROM   wsh_delivery_details wdd
WHERE  wdd.source_code = 'OE'
AND    wdd.source_header_id = c_source_header_id
AND    wdd.source_line_id = c_source_line_id
AND    wdd.released_status <> 'D'
AND    Wdd.delivery_detail_id in (
         SELECT wda.delivery_detail_id
         FROM wsh_trip_stops wts,
         wsh_delivery_legs wdl,
         wsh_delivery_assignments_v wda
         where wts.batch_id = c_batch_id
         AND  wts.stop_id = wdl.pick_up_stop_id
         AND wdl.delivery_id = wda.delivery_id)
for    update nowait;


CURSOR c_remain_detail_id(c_source_line_id NUMBER) IS
SELECT delivery_detail_id
FROM wsh_delivery_details dd
WHERE source_line_id = c_source_line_id AND
     source_code = 'OE' AND
     released_status IN ('R', 'B', 'N', 'S', 'X') AND
     NVL(container_flag, 'N') = 'N';

CURSOR c_remain_lines(c_source_line_set_id NUMBER,
                      c_source_header_id NUMBER,
                      p_batch_id NUMBER) IS
SELECT DISTINCT wdd.source_line_id
from   wsh_delivery_details wdd
where  wdd.source_header_id   = c_source_header_id
and    wdd.source_code        = 'OE'
and    wdd.source_line_set_id = c_source_line_set_id
and    not exists (
         select 'x'
         from   wsh_delivery_assignments_v wda,
                wsh_new_deliveries wnd,
                wsh_delivery_legs wdl,
                wsh_trip_stops wts
         where  wdd.delivery_detail_id = wda.delivery_detail_id
         and    wda.delivery_id        = wnd.delivery_id
         and    wda.delivery_id is not null
         and    wnd.delivery_id        = wdl.delivery_id
         and    wdl.pick_up_stop_id    = wts.stop_id
         and    wdd.ship_from_location_id = wts.stop_location_id
         and    wts.batch_id               = p_batch_id);

CURSOR c_picked_dd(c_source_line_id NUMBER,
                   c_source_header_id NUMBER) IS
select 'x'
from   wsh_delivery_details wdd,
       wsh_delivery_assignments_v wda,
       wsh_new_deliveries wnd
where  wdd.source_line_id     = c_source_line_id
and    wdd.source_code        = 'OE'
and    wdd.source_header_id   = c_source_header_id
and    wdd.delivery_detail_id = wda.delivery_detail_id
and    wnd.delivery_id(+)     = wda.delivery_id
and    ( (wdd.released_status = 'Y') OR
         (wdd.released_status = 'C' AND wdd.oe_interfaced_flag <> 'Y') OR
         (wnd.status_code IN ('SR', 'SC'))
       );

l_prev_line_set_id NUMBER:= -99;
l_dummy            VARCHAR2(1);
l_line_id          NUMBER;
l_tot_ord_qty      NUMBER;
l_tot_dd_req_qty   NUMBER;
l_tot_dd_shp_qty   NUMBER;
WSH_CANCEL_DETAIL_FAILED EXCEPTION;

--After Merge

-- HW OPMCONV. Removed local variables
--bug 7131800
l_process_flag      VARCHAR2(1) :=FND_API.G_FALSE;
l_tot_shp_qty           number;
l_tot_shp_qty2         number;  -- OPM KYH 12/SEP/00
x_msg_data             varchar2(2000);
x_msg_count           number;
l_counter               number;

l_return_status          varchar2(30);
l_new_tolerance_below      number;
l_old_tolerance_below      number;
l_over_reason           VARCHAR2(1);
l_ship_beyond_flag     VARCHAR2(1);
l_fulfilled_flag       VARCHAR2(1);
l_summary               VARCHAR2(2000) :=NULL;
l_details               VARCHAR2(4000) :=NULL;
l_get_msg_count          number;
l_error_Code            number;
l_error_text            varchar2(2000);
l_remain_details_id     WSH_UTIL_CORE.Id_Tab_Type;
l_remain_detail_index      NUMBER;


l_delete_detail_id NUMBER;

--bug 2080335
t_source_line_id     NUMBER;
line_locked     EXCEPTION;
PRAGMA EXCEPTION_INIT(line_locked, -54);


-- OM bug 2022029
l_line_qtys        OE_SHIP_CONFIRMATION_PUB.Req_Quantity_Tbl_Type;

-- anxsharm for Load Tender
 l_trip_id_tab wsh_util_core.id_tab_type;

-- sql repository performance bug 4891985 (>1M sharable memory)
-- 1) changed wsh_delivery_assignments_v to wsh_delivery_assignments
-- 2) restructured the query
-- 3) added the missing condition wdd2.released_status <> 'D' not to handled the cancelled delivery lines

--HVOP heali
/*
CURSOR check_bulk_csr (cp_batch_id NUMBER) IS
select 'X'
from wsh_delivery_details
where source_line_id in (select source_line_id
                         from wsh_delivery_details wdd,
                              wsh_delivery_assignments_v wda,
                              wsh_delivery_legs wdl,
                              wsh_trip_stops wts
                         where wts.batch_id = cp_batch_id
                         and   wdl.pick_up_stop_id = wts.stop_id
                         and   wda.delivery_id = wdl.delivery_id
                         and   wdd.delivery_detail_id = wda.delivery_detail_id
                         and   wdd.container_flag = 'N'
                         and   wdd.source_code = 'OE'
                        )
  and   (delivery_detail_id not in
            (select wdd.delivery_detail_id
             from wsh_delivery_details wdd,
                  wsh_delivery_assignments_v wda,
                  wsh_delivery_legs wdl,
                  wsh_trip_stops wts
             where wts.batch_id = cp_batch_id
             and   wdl.pick_up_stop_id = wts.stop_id
             and   wda.delivery_id = wdl.delivery_id
             and   wdd.delivery_detail_id = wda.delivery_detail_id
             and   wdd.container_flag = 'N'
             and   wdd.source_code = 'OE'
            )
         or    top_model_line_id is not null
         or    ship_set_id is not null
         or    nvl(ship_model_complete_flag,'N')  = 'Y'
         or    requested_quantity <> nvl(shipped_quantity,-99)
         or    source_line_set_id IS NOT NULL
        )
  and   source_code = 'OE'
and   container_flag = 'N';
*/

CURSOR check_bulk_csr (cp_batch_id NUMBER) IS
select 'X'
  from wsh_trip_stops wts,
       wsh_delivery_legs wdl,
       wsh_delivery_assignments wda ,
       wsh_delivery_details wdd
 where wts.batch_id = cp_batch_id
   and wdl.pick_up_stop_id = wts.stop_id
   and wda.delivery_id = wdl.delivery_id
   and wdd.delivery_detail_id = wda.delivery_detail_id
   and wdd.container_flag = 'N'
   and wdd.source_code = 'OE'
   and (EXISTS (select 'any non-cancelled line outside batch'
                  from wsh_delivery_details wdd2
                 where wdd2.source_line_id = wdd.source_line_id
                   and wdd2.source_code = 'OE'
                   and wdd2.container_flag = 'N'
                   and wdd2.released_status <> 'D'
                   and wdd2.delivery_detail_id NOT IN
                       (select wda3.delivery_detail_id
                          from wsh_delivery_assignments wda3 ,
                               wsh_delivery_legs wdl3,
                               wsh_trip_stops wts3,
                               wsh_delivery_details wdd3
                         where wts3.batch_id = cp_batch_id
                           and wdl3.pick_up_stop_id = wts3.stop_id
                           and wda3.delivery_id = wdl3.delivery_id
                           and wdd3.delivery_detail_id = wda3.delivery_detail_id
                           and wdd3.source_line_id = wdd.source_line_id
                           and wdd3.source_code = 'OE'
                           and wdd3.container_flag = 'N'))
        or    wdd.top_model_line_id is not null
        or    wdd.ship_set_id is not null
        or    nvl(wdd.ship_model_complete_flag,'N')  = 'Y'
        or    wdd.requested_quantity <> nvl(wdd.shipped_quantity,-99)
              -- bug 5688051
        or    nvl(requested_quantity2, -99) <> nvl(shipped_quantity2, -99)
        or    wdd.source_line_set_id IS NOT NULL )
   and rownum = 1;


CURSOR c_oe_interface_bulk(cp_batch_id NUMBER) IS
 SELECT	dd.source_header_id		        header_id,
	dd.source_line_id			line_id,
        dd.top_model_line_id 			top_model_line_id,
        dd.ship_set_id				ship_set_id,
        dd.arrival_set_id			arrival_set_id,
	NVL(dl.initial_pickup_date,sysdate) 	actual_shipment_date,
	dd.requested_quantity_uom		shipping_quantity_uom,
	dd.requested_quantity_uom2 		shipping_quantity_uom2,
        ol.flow_status_code			flow_status_code,
        ol.ordered_quantity			ordered_quantity,
        ol.ordered_quantity2			ordered_quantity2,
        ol.org_id                               org_id,
	sum( nvl(dd.shipped_quantity,0) )	shipping_quantity,
	sum( nvl(dd.shipped_quantity2, 0 )) 	shipping_quantity2
FROM   wsh_delivery_Details dd,
   wsh_delivery_assignments_v da ,
   wsh_delivery_legs dg,
   wsh_new_deliveries dl,
   wsh_trip_stops st,
   oe_order_lines_all ol
WHERE st.stop_id = dg.pick_up_stop_id AND
   st.batch_id = cp_batch_id AND
   st.stop_location_id = dl.initial_pickup_location_id AND
   dg.delivery_id = dl.delivery_id  AND
   dl.delivery_id = da.delivery_id  AND
   da.delivery_detail_id = dd.delivery_detail_id
   and nvl ( dd.oe_interfaced_flag , 'N' )  <> 'Y'
   and dd.source_code = 'OE'
   and dd.released_status <> 'D'
   and ol.line_id = dd.source_line_id
   and dd.client_id IS NULL -- LSP PROJECT : Should not perform OM interface for LSP orders
GROUP BY
   dd.source_header_id ,
   dd.source_line_id,
   dd.top_model_line_id,
   dd.ship_set_id,
   dd.arrival_set_id,
   dl.initial_pickup_date,
   dd.requested_quantity_uom,
   dd.requested_quantity_uom2,
   ol.flow_status_code,
   ol.ordered_quantity,
   ol.ordered_quantity2,
   ol.org_id;


CURSOR c_oe_interface(cp_batch_id NUMBER) IS
   SELECT dd.source_header_id ,
   dd.source_header_number ,
   dd.source_line_set_id,
   dd.source_line_id ,
   WSH_WV_UTILS.CONVERT_UOM(ol.order_quantity_uom,
                     dd.requested_quantity_uom,
                     ol.ordered_quantity,
                     dd.inventory_item_id) order_line_quantity,
   dd.requested_quantity_uom  ,
   dd.requested_quantity_uom2 ,
   ol.ordered_quantity,
   ol.order_quantity_uom,
   ol.ordered_quantity2,
   ol.ordered_quantity_uom2,
   ol.model_remnant_flag,
   ol.item_type_code,
   ol.calculate_price_flag,
   dd.ship_tolerance_below  ,
   dd.ship_tolerance_above,
   ol.org_id org_id ,
   dd.organization_id organization_id ,
   NVL(dd.oe_interfaced_flag, 'N') oe_interfaced_flag,
   dl.initial_pickup_date,
   dd.top_model_line_id ,
   dd.ato_line_id,
   dd.ship_set_id,
   dd.ship_model_complete_flag,
   dd.arrival_set_id,
   dd.inventory_item_id,
   ol.flow_status_code,
   sum( dd.requested_quantity )     total_requested_quantity,
   sum( dd.requested_quantity2 )   total_requested_quantity2,
   sum( nvl(dd.shipped_quantity, 0 )) total_shipped_quantity ,
   sum( nvl(dd.shipped_quantity2, 0 )) total_shipped_quantity2
FROM   wsh_delivery_Details dd,
   wsh_delivery_assignments_v da ,
   wsh_delivery_legs dg,
   wsh_new_deliveries dl,
   wsh_trip_stops st,
   oe_order_lines_all ol
WHERE st.stop_id = dg.pick_up_stop_id AND
   st.batch_id = cp_batch_id AND
   st.stop_location_id = dl.initial_pickup_location_id AND
   dg.delivery_id = dl.delivery_id  AND
   dl.delivery_id = da.delivery_id  AND
   da.delivery_id IS NOT NULL AND
   da.delivery_detail_id = dd.delivery_detail_id
   and nvl ( dd.oe_interfaced_flag , 'N' )  <> 'Y'
   and dd.source_code = 'OE'
   and ol.line_id = dd.source_line_id
   and dd.released_status <> 'D'
   and dd.client_id IS NULL  -- LSP PROJECT : Should not perform OM interface for LSP orders
group by ol.org_id ,
   dd.source_header_id ,
   dd.source_header_number ,
   dd.source_line_set_id,
   dd.source_line_id,
   dd.top_model_line_id,
   dd.ship_set_id,
   dd.ato_line_id,
   dd.ship_set_id,
   dd.arrival_set_id,
   dd.inventory_item_id,
   dd.ship_model_complete_flag,
   WSH_WV_UTILS.CONVERT_UOM(ol.order_quantity_uom,
                     dd.requested_quantity_uom,
                     ol.ordered_quantity,
                     dd.inventory_item_id) ,
   dd.requested_quantity_uom,
   dd.requested_quantity_uom2,
   ol.ordered_quantity,
   ol.order_quantity_uom,
   ol.ordered_quantity2,
   ol.ordered_quantity_uom2,
   ol.model_remnant_flag,
   ol.item_type_code,
   ol.calculate_price_flag,
   dd.ship_tolerance_below ,
   dd.ship_tolerance_above ,
   dd.organization_id ,
   NVL(dd.oe_interfaced_flag, 'N') ,
   dl.initial_pickup_date,
   ol.flow_status_code
ORDER BY  ol.org_id,
        dd.source_header_id,
        dd.source_header_number,
        --bug fix 3286811 : replaced total_shipped_quantity -total_requested_quantity in order by for 8.1.7.4 compatibility
        (sum( nvl(dd.shipped_quantity, 0 )) - sum( dd.requested_quantity )),
        dd.source_line_set_id,
        dd.source_line_id,
        dd.top_model_line_id,
        dd.ato_line_id,
        dd.ship_set_id,
        dd.arrival_set_id,
        dd.inventory_item_id,
        dd.ship_model_complete_flag,
        WSH_WV_UTILS.CONVERT_UOM(ol.order_quantity_uom,
                                 dd.requested_quantity_uom,
                                 ol.ordered_quantity,
                                 dd.inventory_item_id) ,
        dd.requested_quantity_uom,
        dd.requested_quantity_uom2,
        ol.ordered_quantity,
        ol.order_quantity_uom,
        ol.ordered_quantity2,
        ol.ordered_quantity_uom2,
        ol.model_remnant_flag,
        ol.item_type_code,
        ol.calculate_price_flag,
        dd.ship_tolerance_below,
        dd.ship_tolerance_above ,
        dd.organization_id,
        NVL(dd.oe_interfaced_flag, 'N') ,
        dl.initial_pickup_date ;

l_bulk_ship_line        OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;
l_bulk_req_line        	OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;
l_non_bulk_ship_line    OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;
l_non_bulk_req_line     OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;

l_check_bulk			VARCHAR2(1);
l_prev_source_header_number 	VARCHAR2(150);
l_bulk_count			NUMBER:=0;
l_non_bulk_count		NUMBER:=0;
l_non_bulk_ship_count		NUMBER:=0;
l_non_bulk_req_count		NUMBER:=0;


l_num_errors            	NUMBER :=0;
l_num_warnings          	NUMBER :=0;

l_num_om_errors                 NUMBER :=0;
l_num_om_warnings               NUMBER :=0;
l_num_om_api_call               NUMBER :=0;

l_org_id			number;
l_prev_org_id			number;
--HVOP heali
l_freight_costs                 OE_Ship_Confirmation_Pub.Ship_Adj_Rec_Type;
l_charges_are_calculated        BOOLEAN DEFAULT FALSE;
l_setsmc_input_rec              OE_Shipping_Integration_PUB.Setsmc_Input_Rec_Type;

oe_interface_rec c_oe_interface%ROWTYPE ;
-- Bug 7131800
l_cancel_unpicked_details       VARCHAR2(1);

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INTERFACE_STOP_TO_OM';

BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
 IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
  --
 IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



 l_counter := 0;


 -- HVOP heali
 OPEN check_bulk_csr(p_batch_id);
 FETCH check_bulk_csr INTO l_check_bulk;
 CLOSE check_bulk_csr;

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_check_bulk',l_check_bulk);
 END IF;


 IF (nvl(l_check_bulk,'%%') <> 'X' ) THEN --{
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'All lines are bulk enabled');
     END IF;

      OPEN c_oe_interface_bulk(p_batch_id);
      FETCH c_oe_interface_bulk BULK COLLECT
	INTO l_bulk_ship_line.header_id,
	     l_bulk_ship_line.line_id,
	     l_bulk_ship_line.top_model_line_id,
	     l_bulk_ship_line.ship_set_id,
             l_bulk_ship_line.arrival_set_id,
	     l_bulk_ship_line.actual_shipment_date,
	     l_bulk_ship_line.shipping_quantity_uom,
	     l_bulk_ship_line.shipping_quantity_uom2,
	     l_bulk_ship_line.flow_status_code,
             l_bulk_ship_line.ordered_quantity,
             l_bulk_ship_line.ordered_quantity2,
	     l_bulk_ship_line.org_id,
	     l_bulk_ship_line.shipping_quantity,
	     l_bulk_ship_line.shipping_quantity2;


      l_bulk_count := c_oe_interface_bulk%ROWCOUNT;
      CLOSE c_oe_interface_bulk;
      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Rows insert into l_bulk_ship_line',l_bulk_count);
      END IF;

 ELSE --} {
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'All lines are NOT bulk enable');
   END IF;

   OPEN c_oe_interface(p_batch_id);
   LOOP
   BEGIN --{
     -- Need to split Bulk and Non-Bulk enable lines.

     FETCH c_oe_interface INTO oe_interface_rec;
     EXIT WHEN c_oe_interface%NOTFOUND;

  -- Commenting out the following code for the bug 5961591
  /*
     l_non_bulk_count:=l_non_bulk_count + 1;

     IF (l_non_bulk_count = 1) THEN
        l_prev_source_header_number:=oe_interface_rec.source_header_number;
     END IF;
  */
  -- End of comment for bug 5961591
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,  'INTERFACE SOURCE_LINE_ID= '||OE_INTERFACE_REC.SOURCE_LINE_ID);
     END IF;


     IF ((nvl(oe_interface_rec.ship_tolerance_above,0) > 0) OR    -- {
               (nvl(oe_interface_rec.ship_tolerance_below,0) > 0)) THEN

        IF (oe_interface_rec.source_line_set_id is not null) THEN --{
           IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Checking for Lock on dds in line set '||
                                                                       oe_interface_rec.source_line_set_id);
           END IF;

           OPEN lock_dds_line_set(oe_interface_rec.source_header_id,oe_interface_rec.source_line_set_id, p_batch_id);
           FETCH lock_dds_line_set INTO t_source_line_id;
           IF lock_dds_line_set%NOTFOUND THEN
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,  'Some or all delivery details for Line Set '||
                                    oe_interface_rec.source_line_set_id||' are already locked by another process');
              END IF;
              CLOSE lock_dds_line_set;
           END IF;
           CLOSE lock_dds_line_set;

        ELSE --}{
           IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Checking for Lock on dds in line '||
                                                                     oe_interface_rec.source_line_id);
           END IF;

           OPEN lock_dds_line(oe_interface_rec.source_header_id,oe_interface_rec.source_line_id, p_batch_id);
           FETCH lock_dds_line INTO t_source_line_id;
           if lock_dds_line%NOTFOUND then
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,  'Some or all delivery details for Line '||
                                       oe_interface_rec.source_line_id||' are already lock by another process');
              END IF;
              CLOSE lock_dds_line;
           end if;
           CLOSE lock_dds_line;
        END IF; --}

     ELSE --}{
        -- bug2080335
        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Checking for Lock on line '||oe_interface_rec.source_line_id);
        END IF;
        OPEN lock_delivery_line(p_batch_id,oe_interface_rec.source_header_id,oe_interface_rec.source_line_id);
        FETCH lock_delivery_line INTO t_source_line_id;
        IF lock_delivery_line%NOTFOUND then
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'LINE '||OE_INTERFACE_REC.SOURCE_LINE_ID||'
                                                                         IS ALREADY LOCK BY ANOTHER PROCESS'  );
         END IF;
         CLOSE lock_delivery_line;
        END IF;
        CLOSE lock_delivery_line;
     END IF; --}
-- Moved the commented out code after IF condition for bug 5961591.
     -- Issue with existing code:
     -- ===========================
     -- If above IF condition fails to obtain the lock for the processing line
     -- then it goes to LINE_LOCKED Exception however variable l_non_bulk_count is
     -- incremented before the IF condition. Based on l_non_bulk_count variable
     -- value, SAVEPOINT its_process_order_non_bulk is set
     -- If savepoint ITS_PROCESS_ORDER_NON_BULK is NOT set then ITS fails with
     -- following error
     -- ORA-01086: savepoint 'ITS_PROCESS_ORDER_NON_BULK' never established
     -- Due to above error delivery detail is stuck with OE_INTERFACED_FLAG value 'P'
     -- and this delivery detail will still be assigned to CLOSED order line.
     -- Fix done for bug 5946787 :
     -- ===========================
     -- So,  variable l_non_bulk_count should be incremented only after acquiring lock on
     -- the line being processed during ITS.
     -- Start of fix for bug the 5961591

      l_non_bulk_count:=l_non_bulk_count + 1;

     IF (l_non_bulk_count = 1) THEN
        l_prev_source_header_number:=oe_interface_rec.source_header_number;
     END IF;
     --End of fix for the bug 5961591

     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'t_source_line_id',t_source_line_id);
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_GMI_RSV_BRANCH.PROCESS_BRANCH',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     -- bug 7131800
     IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => oe_interface_rec.organization_id) THEN
       l_process_flag := FND_API.G_FALSE;
     ELSE
       l_process_flag := FND_API.G_TRUE;
     END IF;
     --
-- HW OPMCONV. Removed checking for OPM orgs

     l_tot_shp_qty := oe_interface_rec.total_shipped_quantity ;
     l_tot_shp_qty2 := oe_interface_rec.total_shipped_quantity2 ;
     l_old_tolerance_below := oe_interface_rec.ship_tolerance_below;
     l_org_id := oe_interface_rec.org_id;

     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'source_header_number',oe_interface_rec.source_header_number);
	WSH_DEBUG_SV.log(l_module_name,'l_process_flag',l_process_flag);
        WSH_DEBUG_SV.log(l_module_name,'l_prev_source_header_number',l_prev_source_header_number);
        WSH_DEBUG_SV.log(l_module_name,'l_non_bulk_ship_line.line_id.count',l_non_bulk_ship_line.line_id.count);
     END IF;
     IF (oe_interface_rec.source_header_number <> nvl(l_prev_source_header_number,'#')         -- {
             AND (l_non_bulk_ship_line.line_id.count > 0 OR l_non_bulk_req_line.line_id.count > 0)
            ) THEN

            l_num_om_api_call := l_num_om_api_call + 1;
            Process_Stop_To_OM(
                p_batch_id	     => p_batch_id,
                p_bulk_ship_line     => l_non_bulk_ship_line,
                p_bulk_req_line      => l_non_bulk_req_line,
                P_bulk_mode	     => 'N',
                p_org_id	     => l_prev_org_id,
                x_freight_costs      => l_freight_costs,
                x_charges_are_calculated => l_charges_are_calculated,
                x_return_status      => l_return_status);

            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name, 'NON BULK Process_Stop_To_OM l_return_status',l_return_status);
            END IF;

            IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Rolling back to the savepoint its_process_order_non_bulk as ITS for the order completed with an error');
              END IF;
              --ROLLBACK TO its_process_order_non_bulk;

            END IF;

            --Initialize l_non_bulk_ship_line and l_non_bulk_req_line
            l_non_bulk_ship_count:=0;

            l_non_bulk_ship_line.line_id.delete;
            l_non_bulk_ship_line.requested_quantity.delete;
            l_non_bulk_ship_line.requested_quantity2.delete;
            l_non_bulk_ship_line.shipping_quantity2.delete;
            l_non_bulk_ship_line.shipping_quantity.delete;
            l_non_bulk_ship_line.shipping_quantity_uom2.delete;
            l_non_bulk_ship_line.shipping_quantity_uom.delete;

            l_non_bulk_ship_line.order_quantity_uom.delete;
            l_non_bulk_ship_line.order_quantity_uom2.delete;
            l_non_bulk_ship_line.ordered_quantity.delete;
            l_non_bulk_ship_line.ordered_quantity2.delete;
            l_non_bulk_ship_line.fulfilled_flag.delete;
            l_non_bulk_ship_line.actual_shipment_date.delete;
	    l_non_bulk_ship_line.header_id.delete;
	    l_non_bulk_ship_line.top_model_line_id.delete;
	    l_non_bulk_ship_line.ato_line_id.delete;
	    l_non_bulk_ship_line.ship_set_id.delete;
	    l_non_bulk_ship_line.arrival_set_id.delete;
	    l_non_bulk_ship_line.inventory_item_id.delete;
	    l_non_bulk_ship_line.ship_from_org_id.delete;
	    l_non_bulk_ship_line.line_set_id.delete;
            l_non_bulk_ship_line.smc_flag.delete;
            l_non_bulk_ship_line.over_ship_reason_code.delete;
            l_non_bulk_ship_line.pending_quantity.delete;
            l_non_bulk_ship_line.pending_quantity2.delete;
            l_non_bulk_ship_line.pending_requested_flag.delete;
            l_non_bulk_ship_line.item_type_code.delete;
            l_non_bulk_ship_line.calculate_price_flag.delete;


            l_non_bulk_req_count:=0;
            l_non_bulk_req_line.line_id.delete;
            l_non_bulk_req_line.requested_quantity.delete;
            l_non_bulk_req_line.requested_quantity2.delete;
            l_non_bulk_req_line.shipping_quantity2.delete;
            l_non_bulk_req_line.shipping_quantity.delete;
            l_non_bulk_req_line.shipping_quantity_uom2.delete;
            l_non_bulk_req_line.shipping_quantity_uom.delete;
            l_non_bulk_req_line.order_quantity_uom.delete;
            l_non_bulk_req_line.order_quantity_uom2.delete;
            l_non_bulk_req_line.ordered_quantity.delete;
            l_non_bulk_req_line.ordered_quantity2.delete;
	    l_non_bulk_req_line.line_set_id.delete;
            l_non_bulk_req_line.item_type_code.delete;

	    l_non_bulk_req_line.ato_line_id.delete;
	    l_non_bulk_req_line.top_model_line_id.delete;
	    l_non_bulk_req_line.inventory_item_id.delete;
	    l_non_bulk_req_line.ship_from_org_id.delete;

            WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_om_warnings,
                                   x_num_errors       =>l_num_om_errors,
                                   p_raise_error_flag =>false);

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Setting the savepoint its_process_order_non_bulk for the next order');
       END IF;
       SAVEPOINT its_process_order_non_bulk;
     ELSIF (l_non_bulk_count = 1) THEN
     --{
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Setting the savepoint its_process_order_non_bulk for the first order');
       END IF;
       SAVEPOINT its_process_order_non_bulk;
     --}
     END IF; --}

     -- Cache the Source header Number
     IF l_debug_on THEN
-- HW OPMCONV. Comment printing value of process flag
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_PROCESS_FLAG IS ' || L_PROCESS_FLAG );
        WSH_DEBUG_SV.logmsg(l_module_name,  'L_TOT_SHP_QTY = '||L_TOT_SHP_QTY  );
     END IF;

     l_setsmc_input_rec.top_model_line_id := oe_interface_rec.top_model_line_id;
     l_setsmc_input_rec.ship_set_id := oe_interface_rec.ship_set_id;
     l_setsmc_input_rec.header_id := oe_interface_rec.source_header_id;

     --Assign record to bulk and non bulk record of table for passing to OM
     IF (Is_OM_Bulk_Enable(p_batch_id,
                           oe_interface_rec.total_requested_quantity,
                           oe_interface_rec.total_shipped_quantity,
                           -- bug 5688051
                           oe_interface_rec.total_requested_quantity2,
                           oe_interface_rec.total_shipped_quantity2,
                           l_setsmc_input_rec,
                           oe_interface_rec.source_line_id,
                           oe_interface_rec.source_header_id)
        ) THEN -- {
         l_bulk_count := l_bulk_count + 1;

	 l_bulk_ship_line.header_id.extend;
	 l_bulk_ship_line.header_id(l_bulk_count):= oe_interface_rec.source_header_id;
	 l_bulk_ship_line.line_id.extend;
	 l_bulk_ship_line.line_id(l_bulk_count):= oe_interface_rec.source_line_id;
	 l_bulk_ship_line.top_model_line_id.extend;
	 l_bulk_ship_line.top_model_line_id(l_bulk_count):= oe_interface_rec.top_model_line_id;
	 l_bulk_ship_line.ship_set_id.extend;
	 l_bulk_ship_line.ship_set_id(l_bulk_count):= oe_interface_rec.ship_set_id;
	 l_bulk_ship_line.arrival_set_id.extend;
	 l_bulk_ship_line.arrival_set_id(l_bulk_count):= oe_interface_rec.arrival_set_id;
	 l_bulk_ship_line.actual_shipment_date.extend;
	 l_bulk_ship_line.actual_shipment_date(l_bulk_count):=NVL(oe_interface_rec.initial_pickup_date,sysdate);
	 l_bulk_ship_line.shipping_quantity_uom.extend;
	 l_bulk_ship_line.shipping_quantity_uom(l_bulk_count):= oe_interface_rec.requested_quantity_uom;
	 l_bulk_ship_line.shipping_quantity_uom2.extend;
	 l_bulk_ship_line.shipping_quantity_uom2(l_bulk_count):=oe_interface_rec.requested_quantity_uom2;
	 l_bulk_ship_line.shipping_quantity.extend;
	 l_bulk_ship_line.shipping_quantity(l_bulk_count):= l_tot_shp_qty;
	 l_bulk_ship_line.shipping_quantity2.extend;
	 l_bulk_ship_line.shipping_quantity2(l_bulk_count):= l_tot_shp_qty2;
	 l_bulk_ship_line.flow_status_code.extend;
	 l_bulk_ship_line.flow_status_code(l_bulk_count):= oe_interface_rec.flow_status_code;
	 l_bulk_ship_line.ordered_quantity.extend;
	 l_bulk_ship_line.ordered_quantity(l_bulk_count):= oe_interface_rec.ordered_quantity;

	 l_bulk_ship_line.org_id.extend;
	 l_bulk_ship_line.org_id(l_bulk_count):= oe_interface_rec.org_id;

	 l_bulk_ship_line.ordered_quantity2.extend;
	 l_bulk_ship_line.ordered_quantity2(l_bulk_count):= oe_interface_rec.ordered_quantity2;
     ELSE -- } {

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Interface the Non-Bulk record for Source Header');
            WSH_DEBUG_SV.log(l_module_name,'ship_tolerance_above',oe_interface_rec.ship_tolerance_above);
            WSH_DEBUG_SV.log(l_module_name,'ship_tolerance_below',oe_interface_rec.ship_tolerance_below);
            WSH_DEBUG_SV.log(l_module_name,'total_requested_quantity',oe_interface_rec.total_requested_quantity);
            WSH_DEBUG_SV.log(l_module_name,'order_line_quantity',oe_interface_rec.order_line_quantity);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFRIM_ACTIONS.Handle_Tolerances',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         --Standllone created new API ,Moved common code inside Handle_Tolerances API
         --    to be used by existing code as well as Standalone code
         Handle_Tolerances ( p_batch_id => p_batch_id,
                             p_oe_interface_rec => oe_interface_rec,
                             x_fulfilled_flag => l_fulfilled_flag,
                             x_over_reason => l_over_reason,
                             x_return_status => l_return_status);

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_SHIP_CONFRIM_ACTIONS.Handle_Tolerances ',l_return_status);
         END IF;

         WSH_UTIL_CORE.api_post_call( p_return_status => l_return_status,
                                                    x_num_warnings =>l_num_warnings,
                                                    x_num_errors =>l_num_errors);
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_tot_shp_qty',l_tot_shp_qty);
         END IF;

         IF ( l_tot_shp_qty > 0 ) THEN  --{
              --wrudge
              -- OM bug 2022029: populate  l_line_qtys only if requested_quantity differs,
              -- and it's not PTO,
              -- and the order line is not fulfilled in this session (flag is false or pending.)
              --
              IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name, 'l_fulfilled_flag ',l_fulfilled_flag);
                   WSH_DEBUG_SV.log(l_module_name,'total_requested_quantity',oe_interface_rec.total_requested_quantity);
                   WSH_DEBUG_SV.log(l_module_name,'top_model_line_id', oe_interface_rec.top_model_line_id);
                   WSH_DEBUG_SV.log(l_module_name,'ato_line_id',oe_interface_rec.ato_line_id);
              END IF;
              --Bug 8975388: initialize the value of variable l_cancel_unpicked_details.
              --
              l_cancel_unpicked_details := NULL;
              --
              IF (l_process_flag = FND_API.G_FALSE ) THEN
              --{
                    IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CUSTOM_PUB.Cancel_Unpicked_Details_At_ITS', WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    l_cancel_unpicked_details := WSH_CUSTOM_PUB.Cancel_Unpicked_Details_At_ITS(  p_source_header_id => oe_interface_rec.source_header_id,
                                                                                                 p_source_line_id => oe_interface_rec.source_line_id,
                                                                                                 p_source_line_set_id => oe_interface_rec.source_line_set_id,
                                                                                                 p_remain_details_id => l_remain_details_id);
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'l_cancel_upicked_details '|| l_cancel_unpicked_details);
                    END IF;
                    IF ( l_cancel_unpicked_details NOT IN ('Y','N') ) THEN
                        IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name, ' Error in Routine wsh_custom_pub.Cancel_Unpicked_Details_At_ITS ');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
              --}
              ELSE -- If it is an OPM Org, which is the current/default behaviour
                   l_cancel_unpicked_details := 'Y';
              END IF;
              --
              -- End Bug 8975388

              IF    (  ( l_tot_shp_qty <> oe_interface_rec.total_requested_quantity)
                      AND (   oe_interface_rec.top_model_line_id IS NULL
                          OR NVL(oe_interface_rec.ato_line_id,-1) = oe_interface_rec.top_model_line_id  )
                      AND (NVL(l_fulfilled_flag, 'F') <> 'T'))
                 OR (l_fulfilled_flag = 'P')
                 -- Bug 7131800: if the Remaining Delivery Details were not Cancelled Earlier, then they would need to be split into another Line
                 OR ( l_cancel_unpicked_details = 'N')
              THEN
                l_non_bulk_req_count := l_non_bulk_req_count + 1;

                l_non_bulk_req_line.line_id.extend;
                l_non_bulk_req_line.requested_quantity.extend;
                l_non_bulk_req_line.requested_quantity2.extend;
                l_non_bulk_req_line.shipping_quantity2.extend;
                l_non_bulk_req_line.shipping_quantity.extend;
                l_non_bulk_req_line.shipping_quantity_uom2.extend;
                l_non_bulk_req_line.shipping_quantity_uom.extend;
                l_non_bulk_req_line.order_quantity_uom.extend;
                l_non_bulk_req_line.order_quantity_uom2.extend;
                l_non_bulk_req_line.ordered_quantity.extend;
                l_non_bulk_req_line.ordered_quantity2.extend;
                l_non_bulk_req_line.line_set_id.extend;
                l_non_bulk_req_line.item_type_code.extend;
                l_non_bulk_req_line.ato_line_id.extend;
                l_non_bulk_req_line.top_model_line_id.extend;
                l_non_bulk_req_line.inventory_item_id.extend;
                l_non_bulk_req_line.ship_from_org_id.extend;


                l_non_bulk_req_line.line_id(l_non_bulk_req_count):= oe_interface_rec.source_line_id;
                l_non_bulk_req_line.requested_quantity(l_non_bulk_req_count):=
                                                                    oe_interface_rec.total_requested_quantity;
                l_non_bulk_req_line.requested_quantity2(l_non_bulk_req_count):=
                                                                    oe_interface_rec.total_requested_quantity2;
                l_non_bulk_req_line.shipping_quantity2(l_non_bulk_req_count):= l_tot_shp_qty2;
                l_non_bulk_req_line.shipping_quantity(l_non_bulk_req_count):= l_tot_shp_qty;
                l_non_bulk_req_line.shipping_quantity_uom2(l_non_bulk_req_count):=
                                                                       oe_interface_rec.requested_quantity_uom2;
                l_non_bulk_req_line.shipping_quantity_uom(l_non_bulk_req_count):=
                                                                          oe_interface_rec.requested_quantity_uom;
                l_non_bulk_req_line.order_quantity_uom(l_non_bulk_req_count):=oe_interface_rec.order_quantity_uom;
                l_non_bulk_req_line.order_quantity_uom2(l_non_bulk_req_count):=
                                                                         oe_interface_rec.ordered_quantity_uom2;
                l_non_bulk_req_line.ordered_quantity(l_non_bulk_req_count):= oe_interface_rec.ordered_quantity;
                l_non_bulk_req_line.ordered_quantity2(l_non_bulk_req_count):= oe_interface_rec.ordered_quantity2;

                l_non_bulk_req_line.line_set_id(l_non_bulk_req_count):= oe_interface_rec.source_line_set_id;
                l_non_bulk_req_line.item_type_code(l_non_bulk_req_count):= oe_interface_rec.item_type_code;

                l_non_bulk_req_line.ato_line_id(l_non_bulk_req_count):= oe_interface_rec.ato_line_id;
                l_non_bulk_req_line.top_model_line_id(l_non_bulk_req_count):= oe_interface_rec.top_model_line_id;
                l_non_bulk_req_line.inventory_item_id(l_non_bulk_req_count):= oe_interface_rec.inventory_item_id;
                l_non_bulk_req_line.ship_from_org_id(l_non_bulk_req_count):= oe_interface_rec.organization_id;


                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'Lines in l_non_bulk_req_line');
                   WSH_DEBUG_SV.log(l_module_name,'line_id',l_non_bulk_req_line.line_id(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'requested_quantity',l_non_bulk_req_line.requested_quantity(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'requested_quantity2',l_non_bulk_req_line.requested_quantity2(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'shipping_quantity',l_non_bulk_req_line.shipping_quantity(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'shipping_quantity_uom',l_non_bulk_req_line.shipping_quantity_uom(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'shipping_quantity2',l_non_bulk_req_line.shipping_quantity2(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'shipping_quantity_uom2',l_non_bulk_req_line.shipping_quantity_uom2(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'ordered_quantity',l_non_bulk_req_line.ordered_quantity(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'order_quantity_uom',l_non_bulk_req_line.order_quantity_uom(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'ordered_quantity2',l_non_bulk_req_line.ordered_quantity2(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'order_quantity_uom2',l_non_bulk_req_line.order_quantity_uom2(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'line_set_id',l_non_bulk_req_line.line_set_id(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'item_type_code',l_non_bulk_req_line.ato_line_id(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'top_model_line_id',l_non_bulk_req_line.top_model_line_id(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'inventory_item_id',l_non_bulk_req_line.inventory_item_id(l_non_bulk_req_count));
                   WSH_DEBUG_SV.log(l_module_name,'ship_from_org_id',l_non_bulk_req_line.ship_from_org_id(l_non_bulk_req_count));
                END IF;


              END IF;

              --HVOP heali
              l_non_bulk_ship_count := l_non_bulk_ship_count + 1;

              extend_om_ship_line (l_non_bulk_ship_line,l_return_status);

              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name, 'Non Bulk Ship l_non_bulk_ship_count',l_non_bulk_ship_count);
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_warnings,
                                   x_num_errors       =>l_num_errors);


              IF (NVL(l_fulfilled_flag, 'F') = 'T') THEN
                 l_non_bulk_ship_line.fulfilled_flag(l_non_bulk_ship_count):= 'Y';
              ELSE
                 l_non_bulk_ship_line.fulfilled_flag(l_non_bulk_ship_count):= 'N';
              END IF;
              l_non_bulk_ship_line.actual_shipment_date(l_non_bulk_ship_count):=
                                                              NVL(oe_interface_rec.initial_pickup_date, sysdate);
              l_non_bulk_ship_line.shipping_quantity2(l_non_bulk_ship_count):= l_tot_shp_qty2;
              l_non_bulk_ship_line.shipping_quantity(l_non_bulk_ship_count):= l_tot_shp_qty;
              l_non_bulk_ship_line.shipping_quantity_uom2(l_non_bulk_ship_count):=
                                                               oe_interface_rec.requested_quantity_uom2;
              l_non_bulk_ship_line.shipping_quantity_uom(l_non_bulk_ship_count):=
                                                               oe_interface_rec.requested_quantity_uom;
              l_non_bulk_ship_line.line_id(l_non_bulk_ship_count):= oe_interface_rec.source_line_id;
	      l_non_bulk_ship_line.header_id(l_non_bulk_ship_count):= oe_interface_rec.source_header_id;
	      l_non_bulk_ship_line.top_model_line_id(l_non_bulk_ship_count):= oe_interface_rec.top_model_line_id;
	      l_non_bulk_ship_line.ato_line_id(l_non_bulk_ship_count):= oe_interface_rec.ato_line_id;
	      l_non_bulk_ship_line.ship_set_id(l_non_bulk_ship_count):= oe_interface_rec.ship_set_id;
	      l_non_bulk_ship_line.arrival_set_id(l_non_bulk_ship_count):= oe_interface_rec.arrival_set_id;
	      l_non_bulk_ship_line.inventory_item_id(l_non_bulk_ship_count):= oe_interface_rec.inventory_item_id;
	      l_non_bulk_ship_line.ship_from_org_id(l_non_bulk_ship_count):= oe_interface_rec.organization_id;
	      l_non_bulk_ship_line.line_set_id(l_non_bulk_ship_count):= oe_interface_rec.source_line_set_id;
              l_non_bulk_ship_line.smc_flag(l_non_bulk_ship_count):= oe_interface_rec.ship_model_complete_flag;
              l_non_bulk_ship_line.over_ship_reason_code(l_non_bulk_ship_count):= l_over_reason;
              l_non_bulk_ship_line.requested_quantity(l_non_bulk_ship_count):=
                                                                   oe_interface_rec.total_requested_quantity;
              l_non_bulk_ship_line.requested_quantity2(l_non_bulk_ship_count):=
                                                                   oe_interface_rec.total_requested_quantity2;

              l_non_bulk_ship_line.pending_quantity(l_non_bulk_ship_count):= NULL;
              l_non_bulk_ship_line.pending_quantity2(l_non_bulk_ship_count):= NULL;
              l_non_bulk_ship_line.pending_requested_flag(l_non_bulk_ship_count):= NULL;

              l_non_bulk_ship_line.order_quantity_uom(l_non_bulk_ship_count):=oe_interface_rec.order_quantity_uom;
              l_non_bulk_ship_line.order_quantity_uom2(l_non_bulk_ship_count):= oe_interface_rec.ordered_quantity_uom2;
              l_non_bulk_ship_line.model_remnant_flag(l_non_bulk_ship_count):= oe_interface_rec.model_remnant_flag;
              l_non_bulk_ship_line.ordered_quantity(l_non_bulk_ship_count):= oe_interface_rec.ordered_quantity;
              l_non_bulk_ship_line.ordered_quantity2(l_non_bulk_ship_count):= oe_interface_rec.ordered_quantity2;
              l_non_bulk_ship_line.item_type_code(l_non_bulk_ship_count):= oe_interface_rec.item_type_code;
              l_non_bulk_ship_line.calculate_price_flag(l_non_bulk_ship_count):= oe_interface_rec.calculate_price_flag;
              --HVOP heali

         END IF; -- }

     END IF; -- }


    EXCEPTION
       WHEN fnd_api.g_exc_error THEN
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'fnd_api.g_exc_error at source_line_id',
                                                                   oe_interface_rec.source_line_id);
          END IF;

       WHEN fnd_api.g_exc_unexpected_error THEN
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'fnd_api.g_exc_unexpected_error at source_line_id', oe_interface_rec.source_line_id);
          END IF;


       WHEN line_locked  THEN
          l_num_errors:=l_num_errors + 1;
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'Failure to Accrue the Lock for source_line_id: ',
                                                                   oe_interface_rec.source_line_id);
          END IF;

       WHEN others THEN
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'Errmsg: ',sqlerrm);
          END IF;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END; --}


     -- Cache the Source header Number
     l_prev_source_header_number:=oe_interface_rec.source_header_number;
     l_prev_org_id := l_org_id;
   END LOOP;  /* big loop , finished loop through the line*/
   CLOSE c_oe_interface;

 END IF; --}
 --HVOP heali


 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_non_bulk_ship_line.line_id.count',l_non_bulk_ship_line.line_id.count);
    WSH_DEBUG_SV.log(l_module_name, 'l_non_bulk_req_line.line_id.count',l_non_bulk_req_line.line_id.count);
 END IF;

 IF (l_non_bulk_ship_line.line_id.count > 0 ) THEN
            l_num_om_api_call := l_num_om_api_call + 1;
            Process_Stop_To_OM(
                p_batch_id	     => p_batch_id,
                p_bulk_ship_line     => l_non_bulk_ship_line,
                p_bulk_req_line      => l_non_bulk_req_line,
                P_bulk_mode	     => 'N',
                p_org_id	     => l_org_id,
                x_freight_costs      => l_freight_costs,
                x_charges_are_calculated => l_charges_are_calculated,
                x_return_status      => l_return_status);


    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'Process_Stop_To_OM l_return_status',l_return_status);
    END IF;

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Rolling back to the savepoint its_process_order_non_bulk as ITS for the order completed with an error 2');
      END IF;
      --ROLLBACK TO its_process_order_non_bulk;

    END IF;

    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) then
       raise fnd_api.g_exc_error;
    END IF;


    WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_om_warnings,
                                   x_num_errors       =>l_num_om_errors,
                                   p_raise_error_flag =>false);
 END IF;


 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_bulk_ship_line.line_id.count',l_bulk_ship_line.line_id.count);
    WSH_DEBUG_SV.log(l_module_name, 'l_bulk_req_line.line_id.count',l_bulk_req_line.line_id.count);
 END IF;
 IF (l_bulk_ship_line.line_id.count > 0 ) THEN
    l_num_om_api_call := l_num_om_api_call + 1;
    Process_Stop_To_OM(
                p_batch_id            => p_batch_id,
                p_bulk_ship_line     => l_bulk_ship_line,
                p_bulk_req_line      => l_bulk_req_line,
                P_bulk_mode          => 'Y',
                x_freight_costs      => l_freight_costs,
                x_charges_are_calculated => l_charges_are_calculated,
                x_return_status      => l_return_status);

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'Process_Stop_To_OM l_return_status',l_return_status);
    END IF;
    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) then
       raise fnd_api.g_exc_error;
    END IF;

    WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                   x_num_warnings     =>l_num_om_warnings,
                                   x_num_errors       =>l_num_om_errors,
                                   p_raise_error_flag =>false);
 END IF;


 IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name, 'l_num_om_api_call',l_num_om_api_call);
   WSH_DEBUG_SV.log(l_module_name, 'l_num_om_errors',l_num_om_errors);
   WSH_DEBUG_SV.log(l_module_name, 'l_num_om_warnings',l_num_om_warnings);
   WSH_DEBUG_SV.log(l_module_name, 'l_non_bulk_count',l_non_bulk_count);
   WSH_DEBUG_SV.log(l_module_name, 'l_num_errors',l_num_errors);
   WSH_DEBUG_SV.log(l_module_name, 'l_num_warnings',l_num_warnings);
 END IF;

  IF ( (l_num_errors >= l_non_bulk_count and l_non_bulk_count > 0 ) OR (l_num_om_errors >= l_num_om_api_call and l_num_om_api_call > 0) ) THEN
    raise fnd_api.g_exc_error;
  ELSIF ( (l_num_errors > 0 )  OR (l_num_om_errors > 0  and l_num_om_api_call > 0) ) THEN
    raise wsh_util_core.g_exc_warning;
  ELSIF ( (l_num_warnings > 0 ) OR (l_num_om_warnings > 0 and l_num_om_api_call > 0) ) THEN
    raise wsh_util_core.g_exc_warning;
  ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;


 IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION

  WHEN fnd_api.g_exc_error THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       WSH_UTIL_CORE.Get_Messages('N',l_summary, l_details, l_get_msg_count);
        IF c_oe_interface%ISOPEN THEN
          close c_oe_interface;
        END IF;
        IF lock_delivery_line%ISOPEN THEN
          close lock_delivery_line;
        END IF;
        IF lock_dds_line%ISOPEN THEN
          close lock_dds_line;
        END IF;
        IF lock_dds_line_set%ISOPEN THEN
          close lock_dds_line_set;
        END IF;
        IF c_remain_detail_id%ISOPEN THEN
          close c_remain_detail_id;
        END IF;
        IF c_remain_lines%ISOPEN THEN
          close c_remain_lines;
        END IF;
        IF c_picked_dd%ISOPEN THEN
          close c_picked_dd;
        END IF;

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'fnd_api.g_exc_error exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:fnd_api.g_exc_error');
       END IF;
       --

  WHEN wsh_util_core.g_exc_warning THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       WSH_UTIL_CORE.Get_Messages('N',l_summary, l_details, l_get_msg_count);
        IF c_oe_interface%ISOPEN THEN
          close c_oe_interface;
        END IF;
        IF lock_delivery_line%ISOPEN THEN
          close lock_delivery_line;
        END IF;
        IF lock_dds_line%ISOPEN THEN
          close lock_dds_line;
        END IF;
        IF lock_dds_line_set%ISOPEN THEN
          close lock_dds_line_set;
        END IF;
        IF c_remain_detail_id%ISOPEN THEN
          close c_remain_detail_id;
        END IF;
        IF c_remain_lines%ISOPEN THEN
          close c_remain_lines;
        END IF;
        IF c_picked_dd%ISOPEN THEN
          close c_picked_dd;
        END IF;

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_util_core.g_exc_warning exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_util_core.g_exc_warning');
       END IF;

  WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       WSH_UTIL_CORE.Get_Messages('N',l_summary, l_details, l_get_msg_count);
        IF c_oe_interface%ISOPEN THEN
          close c_oe_interface;
        END IF;
        IF lock_delivery_line%ISOPEN THEN
          close lock_delivery_line;
        END IF;
        IF lock_dds_line%ISOPEN THEN
          close lock_dds_line;
        END IF;
        IF lock_dds_line_set%ISOPEN THEN
          close lock_dds_line_set;
        END IF;
        IF c_remain_detail_id%ISOPEN THEN
          close c_remain_detail_id;
        END IF;
        IF c_remain_lines%ISOPEN THEN
          close c_remain_lines;
        END IF;
        IF c_picked_dd%ISOPEN THEN
          close c_picked_dd;
        END IF;

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'fnd_api.g_exc_unexpected exception has occured: '||SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_util_core.g_exc_warning');
       END IF;


  WHEN line_locked  THEN
        wsh_util_core.printMsg('Error: Failure to Accrue the Lock for above line,Please try after sometime');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF c_oe_interface%ISOPEN THEN
          close c_oe_interface;
        END IF;
        IF lock_delivery_line%ISOPEN THEN
          close lock_delivery_line;
        END IF;
        IF lock_dds_line%ISOPEN THEN
          close lock_dds_line;
        END IF;
        IF lock_dds_line_set%ISOPEN THEN
          close lock_dds_line_set;
        END IF;
        IF c_remain_detail_id%ISOPEN THEN
          close c_remain_detail_id;
        END IF;
        IF c_remain_lines%ISOPEN THEN
          close c_remain_lines;
        END IF;
        IF c_picked_dd%ISOPEN THEN
          close c_picked_dd;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'LINE_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:LINE_LOCKED');
        END IF;
        --

  WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        l_error_code := SQLCODE;
        l_error_text := SQLERRM;
        -- bug 2657859 frontport bug 2685584: close open cursors
        IF c_oe_interface%ISOPEN THEN
          close c_oe_interface;
        END IF;
        IF lock_delivery_line%ISOPEN THEN
          close lock_delivery_line;
        END IF;
        IF lock_dds_line%ISOPEN THEN
          close lock_dds_line;
        END IF;
        IF lock_dds_line_set%ISOPEN THEN
          close lock_dds_line_set;
        END IF;
        IF c_remain_detail_id%ISOPEN THEN
          close c_remain_detail_id;
        END IF;
        IF c_remain_lines%ISOPEN THEN
          close c_remain_lines;
        END IF;
        IF c_picked_dd%ISOPEN THEN
          close c_picked_dd;
        END IF;
        wsh_util_core.printMsg('API interface_line_to_OM failed with an unexpected error');
        WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'UNEXPECTED ERROR IN INTERFACE_HEADER_TO_OM ' );
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM
,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END interface_stop_to_OM;


--========================================================================
-- PROCEDURE : process_inv_online
--                  This API is a wrapper for
--                  mtl_online_transaction_pub.process_online, to interface all
--                  the lines inserted into MTL interface tables to inventory.
--
-- PARAMETERS: p_batch_id              ITS batch id.
--             p_transaction_header_id The transaction header id for
--                                     mtl_transactions_interface
--             x_return_status         The return status of the API.
--
-- COMMENT   : Sets the inv_interfaced_flag for all the lines in the batch to
--             'P' then calls the inventories process_online.  Then it calls
--             Update_Interfaced_Details to update the inv_interfaced_flag
--             accordingly.
--
--========================================================================

procedure process_inv_online  ( p_batch_id in number ,
            p_transaction_header_id  in number  ,
               x_return_status       out NOCOPY  varchar2  ) is
l_outcome BOOLEAN := TRUE;
x_error_code VARCHAR2(240) := NULL;
x_error_explanation VARCHAR2(240) := NULL;
c_time_out   CONSTANT NUMBER := 1200;
l_time_out NUMBER :=1200;
l_profile_time_out NUMBER;--Bugfix#2346011.
l_process_online_msg_count NUMBER := 0;
l_process_online_message varchar2(4000) := NULL;
l_error_Code            number;
l_error_text            varchar2(2000);
l_return_status             varchar2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_INV_ONLINE';
--
begin
   --
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
       --
       WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
       WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_HEADER_ID',P_TRANSACTION_HEADER_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   -- mark all 'N' as 'P'

   /* record is already processed by inventory */
   update wsh_delivery_details
   set inv_interfaced_flag = 'P' ,
       --Added as part of bug 7645262
       last_update_date    = sysdate,
       request_id          = fnd_global.conc_request_id,
       last_updated_by     = fnd_global.user_id

   where delivery_detail_id in  (
               SELECT  da.delivery_detail_id
               FROM   wsh_delivery_assignments_v da ,
                  wsh_delivery_legs dg,
                  wsh_new_deliveries dl,
                  wsh_trip_stops st
               where dl.delivery_id = da.delivery_id  AND
                   da.delivery_id  IS NOT NULL AND
                   st.stop_id = dg.pick_up_stop_id AND
                   st.batch_id   = p_batch_id   AND
                   st.stop_location_id = dl.initial_pickup_location_id AND
                   dg.delivery_id = dl.delivery_id AND
                   nvl(dl.SHIPMENT_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
               )
   and inv_interfaced_flag = 'N'
   and container_flag = 'N'
   and released_status <> 'D' ; /* H integration: wrudge */
--   and source_code = 'OE' ;

   -- process online
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Number of rows updated',SQL%ROWCOUNT);
       WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
       WSH_DEBUG_SV.logmsg(l_module_name,  'RIGHT BEFORE CALLING MTL_ONLINE_TRANSACTION_PUB.PROCESS_ONLINE'  );
   END IF;
   --
--Bugfix#2346011.
   l_profile_time_out := TO_NUMBER(FND_PROFILE.VALUE('INV_RPC_TIMEOUT'));

   IF l_profile_time_out > 1200 THEN
     l_time_out := l_profile_time_out;
   END IF;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  'TIMEOUT VALUE: '||L_TIME_OUT  );
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit MTL_ONLINE_TRANSACTION_PUB.PROCESS_ONLINE',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
--Bugfix#2346011.
   l_outcome := mtl_online_transaction_pub.process_online(
                p_transaction_header_id,
                l_time_out,
                x_error_code,
                x_error_explanation
                );
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
       WSH_DEBUG_SV.log(l_module_name,'l_outcome',l_outcome);
   END IF;
   --
   /* what should we do if the online processer is hanging
     because manager is not aviable. User needs to be informed */

   if (l_outcome <> TRUE )   THEN
      WSH_UTIL_CORE.printMsg('MTL_ONLINE_TRANSACTION_PUB.process_online returns false');
      WSH_UTIL_CORE.printMsg('Error Code:' || x_error_code);
      WSH_UTIL_CORE.printMsg('Error Explanation:' || x_error_explanation);
      WSH_UTIL_CORE.printMsg('Retrieving messages from the stack');
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Error Code:',x_error_code);
         WSH_DEBUG_SV.log(l_module_name,'Error Explanation::',
                                                  x_error_explanation);
      END IF;
      l_process_online_msg_count := fnd_msg_pub.count_msg;
      if l_process_online_msg_count > 0 then
         FOR i in 1 .. l_process_online_msg_count
         LOOP
            l_process_online_message := fnd_msg_pub.get(i,'T');
            l_process_online_message := replace(l_process_online_message,fnd_global.local_chr(0), ' ');
            WSH_UTIL_CORE.PrintMsg(l_process_online_message);
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Error txt:',
                                     SUBSTR(l_process_online_message,1,200));
            END IF;
         END LOOP;
      end if;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return ;
   end if  ;

   -- update to 'Y' where where inv_interfaced_flag = 'P' and dd_id in mmt and trx_hdr matches and mtl.delivery_id matches

   Update_Interfaced_Details ( p_batch_id , l_return_status ) ;

     if (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) then
      x_return_status := l_return_status ;
        WSH_UTIL_CORE.PrintMsg('process_inv_online  failed for batch '|| p_batch_id ||': txn '
                     || p_transaction_header_id  );
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'process_inv_online  failed for Batch '
              || p_batch_id|| ': txn '|| p_transaction_header_id );
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return ;
     end if;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
   EXCEPTION
     WHEN others THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       l_error_code := SQLCODE;
       l_error_text := SQLERRM;
       WSH_UTIL_CORE.PrintMsg(p_transaction_header_id  ||': process_inv_online failed ');
       WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
end process_inv_online ;

--========================================================================
-- FUNCTION  : Get_Account
--                  Purpose of the function is to get the COGS account
--                  information
--
-- PARAMETERS: p_delivery_detail_id    The delivery detail id
--             x_return_status         The return status of the API.
--
-- COMMENT   : Called from Interface_Detail_To_Inv.
--
--========================================================================

FUNCTION Get_Account(
  p_delivery_detail_id      IN   NUMBER
, x_return_status          OUT NOCOPY  VARCHAR2
) RETURN NUMBER
IS

-- CSUN 01/19/2000 need to modify this cursor once we want to include containers
CURSOR C_Details(p_del_detail_id number)  is
SELECT source_line_id, organization_id, org_id from wsh_delivery_details
where delivery_detail_id = p_del_detail_id
and container_flag = 'N'
and released_status <> 'D' ; /* H integration: wrudge */
l_detail_rec c_details%ROWTYPE;

CURSOR c_dispatch_account(p_organization_id number)
IS
SELECT goods_dispatched_account
FROM   wsh_shipping_parameters
WHERE  organization_id = p_organization_id;

l_dispatch_account c_dispatch_account%ROWTYPE;
l_cogs_return_ccid number := NULL;
l_cogs_concat_segs varchar2(1000) := NULL;
l_cogs_concat_ids varchar2(1000) := NULL;
l_cogs_concat_descrs varchar2(1000) := NULL;
l_cogs_msg_count number := NULL;
l_cogs_msg_data varchar2(4000) := NULL;
l_account            NUMBER := NULL;
l_cogs_return_status   VARCHAR2(30);

-- bug 2657859 frontport bug 2685584: to handle other exceptions
l_error_Code            number;
l_error_text            varchar2(2000);

NO_DEF_GOODS_DISPATCHED_ACCT exception;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ACCOUNT';
--
BEGIN
   --
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
       --
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   OPEN c_details(p_delivery_detail_id);
   FETCH c_details INTO l_detail_rec;
   CLOSE c_details;

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'source_line_id',l_detail_rec.source_line_id);
      WSH_DEBUG_SV.log(l_module_name,'organization_id',l_detail_rec.organization_id);
      WSH_DEBUG_SV.log(l_module_name,'org_id',l_detail_rec.org_id);
   END IF;

   IF l_detail_rec.org_id IS NULL THEN
     SELECT ORG_ID
     INTO l_detail_rec.org_id
     FROM OE_ORDER_LINES_ALL
     WHERE LINE_ID = l_detail_rec.SOURCE_LINE_ID;
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'derived org_id', l_detail_rec.org_id);
     END IF;
   END IF;

   OPEN c_dispatch_account(l_detail_rec.organization_id);
   FETCH c_dispatch_account into l_dispatch_account;
   if (c_dispatch_account%NOTFOUND) then
     RAISE NO_DEF_GOODS_DISPATCHED_ACCT;
   END if;
   CLOSE c_dispatch_account;

   MO_GLOBAL.set_policy_context('S', l_detail_rec.org_id);
   --
   -- bug 2756842 - to reset message stack
   oe_msg_pub.initialize();
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_dispatch_account',
                                  l_dispatch_account.goods_dispatched_account);
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_FLEX_COGS_PUB.START_PROCESS',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   l_cogs_return_status := OE_FLEX_COGS_PUB.Start_Process(
     1.0,
     l_detail_rec.source_line_id,
     l_cogs_return_ccid,
     l_cogs_concat_segs,
     l_cogs_concat_ids,
     l_cogs_concat_descrs,
     l_cogs_msg_count,
     l_cogs_msg_data);
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  'NO. OF OE MESSAGES :'||L_COGS_MSG_COUNT  );
       WSH_DEBUG_SV.logmsg(l_module_name,  'RETURN STATUS FROM OE_FLEX_COGS_PUB.START_PROCESS IS ' || L_COGS_RETURN_STATUS  );
       WSH_DEBUG_SV.logmsg(l_module_name,  'CONCAT_SEGS IS ' || L_COGS_CONCAT_SEGS  );
       WSH_DEBUG_SV.logmsg(l_module_name,  'CONCAT_IDS IS ' || L_COGS_CONCAT_IDS  );
       WSH_DEBUG_SV.logmsg(l_module_name,  'CONCAT_DESCRS IS ' || L_COGS_CONCAT_DESCRS  );
       WSH_DEBUG_SV.logmsg(l_module_name,  'L_CONGS_RETURN_CCID IS ' || L_COGS_RETURN_CCID  );
   END IF;
   --

   IF   l_cogs_msg_count is not null then
     for k in 1 .. l_cogs_msg_count LOOP
       --
       l_cogs_msg_data := oe_msg_pub.get(
         p_msg_index => k,
         p_encoded => 'F'
       );
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, SUBSTR ( L_COGS_MSG_DATA , 1 , 255 ) );
       END IF;
       --
     END LOOP;

   END IF;
   l_account := l_cogs_return_ccid;
   IF l_account IS NULL THEN
      l_account :=  l_dispatch_account.goods_dispatched_account;
      -- IF l_account IS NULL THEN
        -- x_return_status := l_cogs_return_status;
      -- END IF;
   END IF;
 ---  Bug 2791295 return status should be passed irrespective of l_account value
    x_return_status := l_cogs_return_status;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_account',l_account);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN(l_account);

   EXCEPTION
     WHEN NO_DEF_GOODS_DISPATCHED_ACCT THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       WSH_UTIL_CORE.PrintMsg('There is no default goods dispatched account');
       WSH_UTIL_CORE.PrintMsg('There is no default goods dispatched account');
        -- bug 2657859 frontport bug 2685584: close open cursors
        IF c_details%ISOPEN THEN
          close c_details;
        END IF;
        IF c_dispatch_account%ISOPEN THEN
          close c_dispatch_account;
        END IF;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'NO_DEF_GOODS_DISPATCHED_ACCT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DEF_GOODS_DISPATCHED_ACCT');
       END IF;
       --
       RETURN NULL;

     -- bug 2657859 frontport bug 2685584: catch other exceptions
     WHEN others THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       l_error_code := SQLCODE;
       l_error_text := SQLERRM;
       WSH_UTIL_CORE.PrintMsg(p_delivery_detail_id  ||': get_account failed ');
       WSH_UTIL_CORE.PrintMsg('The unexpected error code is ' || l_error_code);
       WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
        IF c_details%ISOPEN THEN
          close c_details;
        END IF;
        IF c_dispatch_account%ISOPEN THEN
          close c_dispatch_account;
        END IF;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unhandled exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       RETURN NULL;
--
END Get_Account;


--========================================================================
-- FUNCTION  : ALL_INTERFACED
--                  If there are any lines in the batch that have either not
--                  interfaced to OM, or not interfaced to INV, then return
--                  FALSE.
--
-- PARAMETERS: p_batch_id              ITS batch id.
--
-- COMMENT   :
--
--========================================================================

FUNCTION ALL_INTERFACED ( p_batch_id in number ) RETURN BOOLEAN  is
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ALL_INTERFACED';
--
BEGIN
     --
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
         --
         WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
     END IF;
     --
     IF INV_INTERFACED(p_batch_id) THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Returning OM_INTERFACED');
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN OM_INTERFACED(p_batch_id);
     END IF;
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return False');
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN FALSE;
   END ALL_INTERFACED;


--========================================================================
-- FUNCTION  : INV_INTERFACED
--                  If there are any lines in the batch that have not interfaced
--                  to INV, return FALSE.
--
-- PARAMETERS: p_batch_id              ITS batch id.
--
-- COMMENT   :
--
--========================================================================

   FUNCTION INV_INTERFACED ( p_batch_id in number ) RETURN BOOLEAN  is
  -- bug 1714402: make sure lines aren't checked if they don't need interface.
  -- inv_interfaced_flag = 'X' means no need to get inv interfaced
/* H integration: added 'WSH' to validate for inventory interface wrudge */
  CURSOR c_lines_not_interfaced(p_batch_id NUMBER) IS
   SELECT wdd.delivery_detail_id
   FROM   wsh_trip_stops wts,
         wsh_delivery_legs wdl,
         wsh_delivery_assignments_v wda,
         wsh_delivery_details wdd
   WHERE  wdd.inv_interfaced_flag IN ('N', 'P')
   AND   wts.batch_id = p_batch_id
   AND   wts.stop_location_id = wdd.ship_from_location_id
   AND   wts.stop_id = wdl.pick_up_stop_id
   AND   wdl.delivery_id = wda.delivery_id
   AND   wda.delivery_id IS NOT NULL
   AND   wda.delivery_detail_id = wdd.delivery_detail_id
   AND   wdd.source_code in ('OE','OKE', 'WSH')
        AND     wdd.released_status <> 'D'  /* H integration: wrudge */
   AND   nvl(wdd.LINE_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
   AND   rownum = 1;

  l_temp NUMBER;
  flag   BOOLEAN;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INV_INTERFACED';
--
BEGIN
  --
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
      --
      WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
  END IF;
  --
  OPEN  c_lines_not_interfaced(P_batch_id);
  FETCH c_lines_not_interfaced INTO l_temp;
  flag  := c_lines_not_interfaced%NOTFOUND;
  CLOSE c_lines_not_interfaced;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,' flag', flag);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN flag;
END  INV_INTERFACED ;


--========================================================================
-- FUNCTION  : OM_INTERFACED
--                  If there are any lines in the batch that have not interfaced
--                  to OM, return FALSE.
--
-- PARAMETERS: p_batch_id              ITS batch id.
--
-- COMMENT   :
--
--========================================================================

FUNCTION OM_INTERFACED ( p_batch_id in number ) RETURN BOOLEAN  is
  CURSOR c_lines_not_interfaced(p_batch_id NUMBER) IS
   SELECT wdd.delivery_detail_id
   FROM   wsh_trip_stops wts,
         wsh_delivery_legs wdl,
         wsh_delivery_assignments_v wda,
         wsh_delivery_details wdd
   WHERE -- wdd.oe_interfaced_flag <> 'Y'
         wdd.oe_interfaced_flag NOT IN ( 'Y' ,'X')  --Standalone WMS project changes
   AND   wts.batch_id = p_batch_id
   AND   wts.stop_location_id = wdd.ship_from_location_id
   AND   wts.stop_id = wdl.pick_up_stop_id
   AND   wdl.delivery_id = wda.delivery_id
   AND   wda.delivery_id IS NOT NULL
   AND   wda.delivery_detail_id = wdd.delivery_detail_id
   AND   wdd.source_code = 'OE'
        AND     wdd.released_status <> 'D'  /* H integration: wrudge */
   AND   rownum = 1;

  l_temp NUMBER;
  flag   BOOLEAN;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'OM_INTERFACED';
--
BEGIN
  --
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
      --
      WSH_DEBUG_SV.log(l_module_name,'p_batch_id',p_batch_id);
  END IF;
  --
  OPEN  c_lines_not_interfaced(p_batch_id);
  FETCH c_lines_not_interfaced INTO l_temp;
  flag  := c_lines_not_interfaced%NOTFOUND;
  CLOSE c_lines_not_interfaced;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'flag',flag);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN flag;
END  OM_INTERFACED ;


--========================================================================
-- PROCEDURE : Interface_ALL_wrp
--                  This is the main wrapper for the concurrent program
--                  interface trip stop SRS.
--
-- PARAMETERS: errbuf                  Used by the concurrent program for error
--                                     messages.
--             retcode                 Used by the concurrent program for return
--                                     code.
--             p_stop_id               Stop id to be interfaced.
--             p_delivery_id           Delivery id to be interfaced.
--             p_log_level             value 1 turns on the debug.
--             p_batch_id              ship confirm batch used by concurrent
--                                     program "Ship Confirm Deliveries SRS"
--             p_trip_type             Used by concurrent program "Ship Confirm
--                                     Deliveries SRS".
--             p_organization_id       If p_stop_id and p_delivery_id are left
--                                     blank use this parameter to interface all
--                                     the stops within this organization.
--             p_num_requests          Indicates the number of child requests
--                                     that would run in parallel.
--             p_stops_per_batch       Indicates the number of stops that can be
--                                     marked by a batch and processed together.
--
-- COMMENT   : If p_num_requests is one ( cannot be smaller than one), then
--             procedure interface_all is called to process the ITS.
--             If p_num_requests is grater than one, then this API will create
--             as many child processes as it is indicated by this parameter, and
--             waits in the pause mode for all the children to be finished.
--             Each child is spawned with p_num_requests set to one.
--             If multiple child processes are run then the parent program will
--             have a output file giving the summary of the results for each
--             child.  If all children process successfully then the return
--             status is success, else if all children errored out then return
--             status is set as error, else set the return status as warning.
--
--========================================================================

procedure interface_ALL_wrp(errbuf        OUT NOCOPY  VARCHAR2,
                        retcode       OUT NOCOPY  VARCHAR2,
                        p_mode        IN  VARCHAR2 DEFAULT 'ALL',
                        p_stop_id     IN  NUMBER   DEFAULT NULL,
                        p_delivery_id IN  NUMBER   DEFAULT NULL,
                        p_log_level   IN  NUMBER   DEFAULT 0,
                        p_batch_id IN NUMBER DEFAULT NULL,
                        p_trip_type IN VARCHAR2 DEFAULT NULL,
                        p_organization_id IN NUMBER DEFAULT NULL,
                        p_num_requests IN NUMBER DEFAULT NULL,
                        p_stops_per_batch IN NUMBER DEFAULT NULL) IS

   --
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                                       || 'INTERFACE_ALL_WRP';
   --
   l_req_data               VARCHAR2(100);
   l_num_requests           NUMBER;
   l_child_req_ids          wsh_util_core.id_tab_type;
   l_request_id             NUMBER;
   l_this_request           NUMBER;
   j                        NUMBER;
   l_dummy                  BOOLEAN;
   l_errors                 NUMBER := 0;
   l_warnings               NUMBER := 0;
   l_completion_status      VARCHAR2(30);
   l_phase                  VARCHAR2(100);
   l_status                 VARCHAR2(100);
   l_dev_phase              VARCHAR2(100);
   l_dev_status             VARCHAR2(100);
   l_message                VARCHAR2(500);
   l_error_code number := NULL;
   l_error_text varchar2(2000) := NULL;


   CURSOR c_requests (p_parent_request_id NUMBER) IS
   SELECT request_id
   FROM FND_CONCURRENT_REQUESTS
   WHERE parent_request_id = p_parent_request_id;
   e_invalid_number   EXCEPTION;

BEGIN
  --
  WSH_UTIL_CORE.Enable_Concurrent_Log_Print;
  WSH_UTIL_CORE.Set_Log_Level(p_log_level);
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
      --
      WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
      WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_LOG_LEVEL',P_LOG_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'p_organization_id',p_organization_id);
      WSH_DEBUG_SV.log(l_module_name,'p_num_requests',p_num_requests);
      WSH_DEBUG_SV.log(l_module_name,'p_stops_per_batch',p_stops_per_batch);
  END IF;
  --
  l_completion_status := 'NORMAL';

  l_num_requests := NVL(p_num_requests,1);
  IF l_num_requests = 0 THEN
     l_num_requests := 1;
  ELSIF l_num_requests < 0 THEN
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Number of requests cannot be negative'
                                                              ,l_num_requests);
     END IF;
     RAISE e_invalid_number;
  END IF;

  l_req_data := FND_CONC_GLOBAL.request_data ;
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_req_data',l_req_data);
  END IF;

  IF (l_req_data IS NULL) THEN
     IF (l_num_requests > 1)THEN --{
       FOR i IN 1..l_num_requests LOOP
        l_request_id := FND_REQUEST.submit_Request(
                                      application => 'WSH',
                                      program => 'WSHINTERFACES',
                                      sub_request => TRUE,
                                      argument1 =>p_mode,
                                      argument2 =>p_stop_id,
                                      argument3 =>p_delivery_id,
                                      argument4 =>p_log_level,
                                      argument5 =>p_batch_id,
                                      argument6 =>p_trip_type,
                                      argument7 =>p_organization_id,
                                      argument8 =>1 ,-- l_num_requests
                                      argument9 => p_stops_per_batch
        );

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'child request',l_request_id);
        END IF;

       END LOOP;
       fnd_conc_global.set_req_globals(conc_status  => 'PAUSED',
                                 request_data => to_char(l_num_requests));
    ELSE --}{
     interface_ALL(
                   errbuf => errbuf,
                   retcode => retcode,
                   p_mode  => p_mode,
                   p_stop_id => p_stop_id,
                   p_delivery_id => p_delivery_id,
                   p_log_level => p_log_level,
                   p_batch_id => p_batch_id,
                   p_trip_type => p_trip_type,
                   p_organization_id => p_organization_id,
                   p_stops_per_batch => p_stops_per_batch);
    END IF; --}
  END IF;

  IF (l_req_data IS NOT NULL) AND (l_num_requests > 1)THEN --{
     --set the l_completion_status based on the other programs
     FND_PROFILE.Get('CONC_REQUEST_ID', l_this_request);
     OPEN c_requests(l_this_request);
     FETCH c_requests BULK COLLECT INTO l_child_req_ids;
     CLOSE c_requests;

     j := l_child_req_ids.FIRST;
     WHILE j IS NOT NULL LOOP
        l_dev_status := NULL;
        l_dummy := FND_CONCURRENT.get_request_status(
                                     request_id => l_child_req_ids(j),                                               phase      => l_phase,
                                     status     => l_status,
                                     dev_phase  => l_dev_phase,
                                     dev_status => l_dev_status,
                                     message    => l_message);

        IF l_dev_status = 'WARNING' THEN
           l_warnings:= l_warnings + 1;
        ELSIF l_dev_status <> 'NORMAL' THEN
           l_errors := l_errors + 1;
        END IF;
        IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_dev_status',l_dev_status);
             WSH_DEBUG_SV.log(l_module_name,'l_child_req_id'
                                                        ,l_child_req_ids(j));
        END IF;

        FND_MESSAGE.SET_NAME('WSH','WSH_CHILD_REQ_STATUS');
        FND_MESSAGE.SET_TOKEN('REQ_ID', to_char(l_child_req_ids(j)));
        FND_MESSAGE.SET_TOKEN('STATUS', l_status);
        FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

        j := l_child_req_ids.NEXT(j);
     END LOOP;

     IF l_errors = 0  AND l_warnings = 0 THEN
        l_completion_status := 'NORMAL';
     ELSIF (l_errors > 0 ) AND (l_errors  = l_child_req_ids.count )  THEN
        l_completion_status := 'ERROR';
     ELSE
        l_completion_status := 'WARNING';
     END IF;

     l_dummy := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');

     IF l_completion_status = 'NORMAL' THEN
       errbuf := 'Interface trip stop is completed successfully';
       retcode := '0';
     ELSIF l_completion_status = 'WARNING' THEN
       errbuf := 'Interface trip stop is  completed with warning';
       retcode := '1';
     ELSE
       errbuf := 'Interface trip stop  is completed with error';
       retcode := '2';
     END IF;
     --
  END IF; --}

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'errbuf',errbuf);
      WSH_DEBUG_SV.log(l_module_name,'retcode',retcode);
      WSH_DEBUG_SV.log(l_module_name,'l_completion_status',l_completion_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --

  EXCEPTION
    WHEN e_invalid_number THEN
       l_completion_status := 'ERROR';
       l_error_code     := SQLCODE;
       l_error_text     := SQLERRM;
       l_dummy := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
       errbuf := 'Interface trip stop failed with unexpected error';
       retcode := '2';
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:e_invalid_number');
       END IF;
       --
    WHEN OTHERS THEN
       l_completion_status := 'ERROR';
       l_error_code     := SQLCODE;
       l_error_text     := SQLERRM;
       WSH_UTIL_CORE.PrintMsg('Interface_ALL_wrp failed with unexpected error.');
       WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
       l_dummy := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
       errbuf := 'Interface trip stop failed with unexpected error';
       retcode := '2';
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
END interface_ALL_wrp;

--Standalone WMS project New API
--========================================================================
-- PROCEDURE : Process_Delivery_To_OM
--                  Procedure to interface delvieries to OM
--
-- PARAMETERS: delivery_id             Delivery_id need to be interfaced
--             x_return_status         return status of the API.
--
-- COMMENT   : This API is created to be used only by Standalone code.
--             API will interfaces the delivery passed to OM only if
--             the delivery is completely shipped or shipped within tolerances.
--             For tolerance case remaining delivery details will be cancelled
--========================================================================
PROCEDURE Process_Delivery_To_OM ( p_delivery_id  IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2)IS

  l_debug_on    BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.'|| G_PKG_NAME || '.'|| 'Process_Delivery_To_OM';
  l_return_status       VARCHAR2(1);
  l_summary             VARCHAR2(3000);
  l_num_warnings        VARCHAR2(3000);
  l_num_errors          VARCHAR2(3000);
  l_ship_beyond_flag    VARCHAR2(1);
  l_fulfilled_flag      VARCHAR2(1);
  l_remain_detail_index NUMBER;
  l_remain_details_id WSH_UTIL_CORE.Id_Tab_Type ;

  --This cursor should fetch only one records per order line
  --Get total_requested_quantity and total_shipped_quantity for the order line
  --This cursor type should match with WSH_SHIP_CONFIRM_ACTIONS.oe_interface_rec

  /*Get all the details at order line level of the delivery passed which are shipped and not interfaced to OM */
  CURSOR c_get_oe_interface_line_detail(c_delivery_id NUMBER)  IS
   SELECT dd.source_header_id ,
         dd.source_header_number,
         NULL source_line_set_id,
         dd.source_line_id,
         WSH_WV_UTILS.CONVERT_UOM(ol.order_quantity_uom,
                     dd.requested_quantity_uom,
                     ol.ordered_quantity,
                     dd.inventory_item_id) order_line_quantity,
         dd.requested_quantity_uom,
         NULL requested_quantity_uom2,
         ol.ordered_quantity,
         ol.order_quantity_uom,
         NULL ordered_quantity2,
         NULL ordered_quantity_uom2,
         NULL model_remnant_flag,
         ol.item_type_code,
         ol.calculate_price_flag,
         dd.ship_tolerance_below,
         dd.ship_tolerance_above,
         NULL org_id,
         dd.organization_id,
         NVL(dd.oe_interfaced_flag,'X') oe_interfaced_flag,
         NULL initial_pickup_date ,
         NULL top_model_line_id,
         NULL ato_line_id ,
         NULL ship_set_id ,
         NULL ship_model_complete_flag  ,
         NULL arrival_set_id,
         dd.inventory_item_id,
         ol.flow_status_code,
         SUM( dd.requested_quantity ) total_requested_quantity ,
         NULL total_requested_quantity2,
         SUM( NVL(dd.shipped_quantity, 0 )) total_shipped_quantity,
         NULL total_shipped_quantity2
  FROM   wsh_delivery_Details dd ,
         oe_order_lines_all ol
  WHERE  dd.source_line_id = ol.line_id
    AND  dd.released_status = 'C'
    AND  dd.source_code = 'OE'
    AND  ol.shipped_quantity IS NULL
    AND  dd.source_line_id IN
         ( SELECT DISTINCT dd1.source_line_id
           FROM   wsh_delivery_details dd1      ,
                  wsh_delivery_assignments_v da
           WHERE  da.delivery_id = c_delivery_id
             AND  da.delivery_detail_id  = dd1.delivery_detail_id
             AND  NVL(dd1.oe_interfaced_flag,'X') = 'X'
             AND  dd1.source_code = 'OE'
             AND  dd1.released_status = 'C')
  GROUP BY  dd.source_header_id,
            dd.source_header_number,
            dd.source_line_id,
            ol.ordered_quantity,
            dd.requested_quantity_uom,
            ol.ordered_quantity,
            ol.order_quantity_uom,
            dd.inventory_item_id,
            ol.item_type_code,
            ol.calculate_price_flag,
            dd.ship_tolerance_below,
            dd.ship_tolerance_above,
            dd.organization_id,
            NVL(dd.oe_interfaced_flag, 'X') ,
            ol.flow_status_code
  ORDER BY  dd.organization_id ,
            dd.source_line_id ;

  line_rec wsh_ship_confirm_actions.oe_interface_rec;
  l_over_reason varchar2(1);
  l_delete_detail_id NUMBER;
  line_id_tab wsh_util_core.id_tab_type;
  i NUMBER :=0;
  line_locked     EXCEPTION;
  PRAGMA EXCEPTION_INIT(line_locked, -54);

BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'delivery_id ',p_delivery_id);
        WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_PKG.Lock_Detail_No_Compare',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    SAVEPOINT l_cancel_wdd;

    --This API will lock the associated delivery details
    wsh_delivery_details_pkg.lock_detail_no_compare(p_delivery_id =>  p_delivery_id);

    /*Get all the details at order line level of the delivery passed which are shipped and not interfaced to OM */
    OPEN c_get_oe_interface_line_detail(p_delivery_id);
    LOOP
    --{
        FETCH c_get_oe_interface_line_detail into line_rec;
        EXIT WHEN c_get_oe_interface_line_detail%NOTFOUND;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Inside line rec loop : line_id '|| line_rec.source_line_id);
        END IF;

        i := i + 1;
        line_id_tab(i) := line_rec.source_line_id ;

        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFRIM_ACTIONS.Handle_Tolerances',WSH_DEBUG_SV.C_PROC_LEVEL);

        /*Check the tolerances and cancel the delivery details ,if tolerances are met*/
        Handle_Tolerances ( p_batch_id => NULL,
                            p_oe_interface_rec => line_rec,
                            x_fulfilled_flag => l_fulfilled_flag,
                            x_over_reason => l_over_reason,
                            x_return_status => l_return_status);

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_SHIP_CONFRIM_ACTIONS.Handle_Tolerances ',l_return_status);
        END IF;

        WSH_UTIL_CORE.api_post_call(  p_return_status => l_return_status,
                                      x_num_warnings =>l_num_warnings,
                                      x_num_errors =>l_num_errors);
    --}
    END LOOP;
    CLOSE c_get_oe_interface_line_detail;

    --Interfaces lines to OM
    IF (line_id_tab.count > 0 ) THEN
    --{
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFIRM_ACTIONS.Process_lines_To_OM', WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         /*Interface the delivery details to OM*/
         Process_lines_To_OM(p_line_id_tab =>line_id_tab,
                                x_return_status => l_return_status);

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'After program unit Process_lines_To_OM l_return_status ' || l_return_status );
         END IF;

         WSH_UTIL_CORE.api_post_call(p_return_status => l_return_status, x_num_warnings =>l_num_warnings, x_num_errors =>l_num_errors);
    --}
    ELSE
    --{
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, '*****No eligible lines found in the delivery to interface******');
         END IF;
    --}
    END IF;

    IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
        x_return_status := l_return_status;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION
   WHEN line_locked  THEN
        wsh_util_core.printMsg('Error: Failure to Accrue the Lock ,Please try after sometime');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

        IF c_get_oe_interface_line_detail%ISOPEN THEN
           close c_get_oe_interface_line_detail;
        END IF;

        ROLLBACK TO SAVEPOINT l_cancel_wdd;
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint l_cancel_wdd');
           WSH_DEBUG_SV.logmsg(l_module_name,'LINE_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:LINE_LOCKED');
        END IF;

   WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.printMsg('API Process_Delivery_To_OM failed with an unexpected error');
        WSH_UTIL_CORE.PrintMsg('The unexpected error is '|| sqlerrm);

        IF c_get_oe_interface_line_detail%ISOPEN THEN
          close c_get_oe_interface_line_detail;
        END IF;

        ROLLBACK TO SAVEPOINT l_cancel_wdd;
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint l_cancel_wdd');
           WSH_DEBUG_SV.logmsg(l_module_name, 'UNEXPECTED ERROR IN WSH_Process_Stop_To_OM' );
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;

END Process_delivery_To_OM;

--Standalone WMS project New API
--========================================================================
-- PROCEDURE : Process_lines_to_om
--                  Procedure to interface completely shipped lines to OM
--
-- PARAMETERS: line_id_tab             table of line_ids need to be interfaced
--             x_return_status         return status of the API.
--
-- COMMENT   : This API is created to be called only from Standalone code
--             API interfaces the lines passed to OM only if there are no
--             unshipped wdd remaining for the order line.
--               -If complete quantity is shipped then BUlk mode variable are popualted
--                AND/OR
--               -If line is shipped within tolerances then Non BUlk mode variable are
--                   popualted
--             Based on Bulk and Non bulk varaiables OM API will be called in Bulk and
--	           Non Bulk mode.
----========================================================================
PROCEDURE Process_Lines_To_OM (p_line_id_tab     IN wsh_util_core.id_tab_type ,
                                  x_return_status OUT NOCOPY VARCHAR2)IS
  l_debug_on    BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.'|| G_PKG_NAME || '.'|| 'Process_lines_To_OM';
  l_return_status       VARCHAR2(1);
  x_msg_count           NUMBER;
  x_msg_data            VARCHAR2(3000);
  l_error_count         NUMBER:=0;
  l_end_index           NUMBER;
  l_start_index         NUMBER;
  l_row_count           NUMBER;
  l_end_index_nonbulk   NUMBER;
  l_start_index_nonbulk NUMBER;
  l_row_count_nonbulk   NUMBER;
  l_bulk_ship_line OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;
  l_non_bulk_ship_line OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;
  p_bulk_req_line OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;
  l_ship_adj_line OE_Ship_Confirmation_Pub.Ship_Adj_Rec_Type;
  i NUMBER:=0;

  /* Cursor should fetch the order lines which have ONLY shipped delivery details */
  CURSOR c_get_line_detail_to_interface(c_line_id NUMBER)  IS
  SELECT dd.source_header_id,
         dd.source_header_number  ,
         dd.source_line_id ,
         ol.ordered_quantity ,
         dd.requested_quantity_uom,
         ol.order_quantity_uom ,
         dd.inventory_item_id,
         ol.item_type_code  ,
         ol.org_id  ,
         ol.calculate_price_flag ,
         dd.ship_tolerance_below,
         dd.ship_tolerance_above   ,
         dd.organization_id  ,
         NVL(dd.oe_interfaced_flag, 'X') oe_interfaced_flag  ,
         ol.flow_status_code  ,
         SUM( dd.requested_quantity ) total_requested_quantity ,
         SUM( NVL(dd.shipped_quantity, 0 )) total_shipped_quantity
  FROM   wsh_delivery_Details dd ,
         oe_order_lines_all ol
  WHERE  dd.source_line_id  = ol.line_id
     AND dd.released_status = 'C'
     AND dd.source_line_id  = c_line_id
     AND dd.source_code = 'OE'
     and ol.shipped_quantity is NULL
     AND NOT EXISTS
         ( SELECT 'X'
           FROM   wsh_delivery_details wdd2
           WHERE  wdd2.source_line_id   = dd.source_line_id
             AND  wdd2.source_code = 'OE'
             AND  wdd2.released_status IN ( 'R','B','S','Y','X'))
  GROUP BY dd.source_header_id ,
         dd.source_header_number ,
         dd.source_line_id ,
         ol.ordered_quantity ,
         dd.requested_quantity_uom ,
         ol.ordered_quantity ,
         ol.order_quantity_uom ,
         dd.inventory_item_id ,
         ol.item_type_code ,
         ol.org_id ,
         ol.calculate_price_flag ,
         dd.ship_tolerance_below ,
         dd.ship_tolerance_above ,
         dd.organization_id ,
         NVL(dd.oe_interfaced_flag, 'X') ,
         ol.flow_status_code
   ORDER BY dd.organization_id ,
            dd.source_line_id ;

  line_rec c_get_line_detail_to_interface%ROWTYPE;
  l_over_reason VARCHAR2(1);
  j NUMBER :=0;
  k NUMBER :=0;
  l_pick_up_date DATE;
  l_loop_count NUMBER;

BEGIN
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'line_id_tab.count',P_line_id_tab.count);
        WSH_DEBUG_SV.logmsg(l_module_name, 'Get lines to interface - Start loop');
    END IF;

    l_bulk_ship_line.line_id.DELETE;
    l_non_bulk_ship_line.line_id.DELETE;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --If tolerances are met remaining quantity should have been cancelled till this point

    /*Process Order lines one by one*/
    FOR k IN 1..P_line_id_tab.count
    LOOP
    --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, '=======================');
           WSH_DEBUG_SV.logmsg(l_module_name, 'Before line rec line_id' || P_line_id_tab(k));
        END IF;

        /*Get the order lines which have only shipped delivery details*/
        OPEN c_get_line_detail_to_interface(P_line_id_tab(k));
        FETCH c_get_line_detail_to_interface
        INTO  line_rec;

        IF c_get_line_detail_to_interface%NOTFOUND THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Line not eligible to interface');
            END IF;
            GOTO loop_end;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'After line rec line_id ' || line_rec.source_line_id);
        END IF;

        --Get initial pick up date for the line.
        BEGIN
        --{
            SELECT initial_pickup_date
            INTO  l_pick_up_date
            FROM  wsh_delivery_details wdd    ,
                  wsh_delivery_assignments wda,
                  wsh_new_deliveries wnd
            WHERE wdd.source_line_id     = line_rec.source_line_id
              AND wda.delivery_detail_id = wdd.delivery_detail_id
              AND wnd.delivery_id        = wda.delivery_id
              AND ROWNUM =1;

            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_pick_up_date',l_pick_up_date);
            END IF;
        --}
        END;

        --for full quantity shipped ,popualate bulk mode variable
        IF ( WSH_WV_UTILS.CONVERT_UOM( line_rec.order_quantity_uom, line_rec.requested_quantity_uom, line_rec.ordered_quantity, line_rec.inventory_item_id) = line_rec.total_shipped_quantity ) THEN
        --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Total quantity shipped interface to OM');
                WSH_DEBUG_SV.log(l_module_name,'line_rec.total_ordered_quantity',line_rec.ordered_quantity);
                WSH_DEBUG_SV.log(l_module_name,'line_rec.total_requested_quantity',line_rec.total_requested_quantity);
                WSH_DEBUG_SV.log(l_module_name,'line_rec.total_shipped_quantity',line_rec.total_shipped_quantity);
                WSH_DEBUG_SV.logmsg(l_module_name, 'Populate bulk varaible');
                WSH_DEBUG_SV.log(l_module_name,'source_header_id',line_rec.source_header_id);
                WSH_DEBUG_SV.log(l_module_name,'source_line_id',line_rec.source_line_id);
                WSH_DEBUG_SV.log(l_module_name,'initial_pickup_date',l_pick_up_date);
                WSH_DEBUG_SV.log(l_module_name,'initial_pickup_date',line_rec.flow_status_code);
                WSH_DEBUG_SV.log(l_module_name,'requested_quantity_uom',line_rec.requested_quantity_uom);
                WSH_DEBUG_SV.log(l_module_name,'ordered_quantity',line_rec.ordered_quantity);
                WSH_DEBUG_SV.log(l_module_name,'total_shipped_quantity',line_rec.total_shipped_quantity);
                WSH_DEBUG_SV.log(l_module_name,'org_id',line_rec.org_id);
            END IF;
            i := i+1;
            l_bulk_ship_line.header_id.extend;
            l_bulk_ship_line.header_id(i):= line_rec.source_header_id;
            l_bulk_ship_line.line_id.extend;
            l_bulk_ship_line.line_id(i):= line_rec.source_line_id;
            l_bulk_ship_line.top_model_line_id.extend;
            l_bulk_ship_line.top_model_line_id(i):= NULL;
            l_bulk_ship_line.ship_set_id.extend;
            l_bulk_ship_line.ship_set_id(i):= NULL;
            l_bulk_ship_line.arrival_set_id.extend;
            l_bulk_ship_line.arrival_set_id(i):= NULL;
            l_bulk_ship_line.actual_shipment_date.extend;
            l_bulk_ship_line.actual_shipment_date(i):=NVL(l_pick_up_date,sysdate);
            l_bulk_ship_line.shipping_quantity_uom.extend;
            l_bulk_ship_line.shipping_quantity_uom(i):= line_rec.requested_quantity_uom;
            l_bulk_ship_line.shipping_quantity_uom2.extend;
            l_bulk_ship_line.shipping_quantity_uom2(i):=NULL;
            l_bulk_ship_line.flow_status_code.extend;
            l_bulk_ship_line.flow_status_code(i):= line_rec.flow_status_code;
            l_bulk_ship_line.ordered_quantity.extend;
            l_bulk_ship_line.ordered_quantity(i):= line_rec.ordered_quantity;
            l_bulk_ship_line.shipping_quantity.extend;
            l_bulk_ship_line.shipping_quantity(i):= line_rec.total_shipped_quantity;
            l_bulk_ship_line.shipping_quantity2.extend;
            l_bulk_ship_line.shipping_quantity2(i):= NULL ;
            l_bulk_ship_line.org_id.extend;
            l_bulk_ship_line.org_id(i):= line_rec.org_id;
            l_bulk_ship_line.ordered_quantity2.extend;
            l_bulk_ship_line.ordered_quantity2(i):= NULL;
        --}
        --line is shipped within tolerances ,popualate non bulk mode variable
        ELSIF ((NVL(line_rec.ship_tolerance_above,0) > 0) OR
                (NVL(line_rec.ship_tolerance_below,0) > 0))THEN
        --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Tolearance case');
                WSH_DEBUG_SV.log(l_module_name,'total shipped quantity',line_rec.total_shipped_quantity);
                WSH_DEBUG_SV.log(l_module_name,'ordered_quantity',line_rec.ordered_quantity);
                WSH_DEBUG_SV.log(l_module_name,'line_rec.ship_tolerance_below',line_rec.ship_tolerance_below);
                WSH_DEBUG_SV.log(l_module_name,'line_rec.ship_tolerance_above',line_rec.ship_tolerance_above);
                WSH_DEBUG_SV.logmsg(l_module_name, 'Populate non bulk varaible');
                WSH_DEBUG_SV.log(l_module_name,'source_header_id',line_rec.source_header_id);
                WSH_DEBUG_SV.log(l_module_name,'source_line_id',line_rec.source_line_id);
                WSH_DEBUG_SV.log(l_module_name,'initial_pickup_date',l_pick_up_date);
                WSH_DEBUG_SV.log(l_module_name,'requested_quantity_uom',line_rec.requested_quantity_uom);
                WSH_DEBUG_SV.log(l_module_name,'inventory_item_id',line_rec.inventory_item_id );
                WSH_DEBUG_SV.log(l_module_name,'flow_status_code',line_rec.flow_status_code);
                WSH_DEBUG_SV.log(l_module_name,'ordered_quantity',line_rec.ordered_quantity);
                WSH_DEBUG_SV.log(l_module_name,'total_shipped_quantity',line_rec.total_shipped_quantity);
                WSH_DEBUG_SV.log(l_module_name,'organization_id',line_rec.organization_id);
                WSH_DEBUG_SV.log(l_module_name,'org_id',line_rec.org_id);
                WSH_DEBUG_SV.log(l_module_name,'item_type_code',line_rec.item_type_code);
                WSH_DEBUG_SV.log(l_module_name,'item_type_code',line_rec.calculate_price_flag);
            END IF;

            j := j+1;
            l_non_bulk_ship_line.header_id.extend;
            l_non_bulk_ship_line.header_id(j):= line_rec.source_header_id;
            l_non_bulk_ship_line.line_id.extend;
            l_non_bulk_ship_line.line_id(j):= line_rec.source_line_id;
            l_non_bulk_ship_line.top_model_line_id.extend;
            l_non_bulk_ship_line.top_model_line_id(j):= NULL;
            l_non_bulk_ship_line.ato_line_id.extend;
            l_non_bulk_ship_line.ato_line_id(j):= NULL;
            l_non_bulk_ship_line.item_type_code.extend;
            l_non_bulk_ship_line.item_type_code(j):= line_rec.item_type_code;
            l_non_bulk_ship_line.ship_set_id.extend;
            l_non_bulk_ship_line.ship_set_id(j):= NULL;
            l_non_bulk_ship_line.arrival_set_id.extend;
            l_non_bulk_ship_line.arrival_set_id(j):= NULL;
            l_non_bulk_ship_line.line_set_id.extend;
            l_non_bulk_ship_line.line_set_id(j):= NULL;
            l_non_bulk_ship_line.smc_flag.extend;
            l_non_bulk_ship_line.smc_flag(j):= NULL;
            l_non_bulk_ship_line.over_ship_reason_code.extend;
            l_non_bulk_ship_line.over_ship_reason_code(j):= NULL;
            l_non_bulk_ship_line.pending_quantity.extend;
            l_non_bulk_ship_line.pending_quantity(j):= NULL;
            l_non_bulk_ship_line.pending_quantity2.extend;
            l_non_bulk_ship_line.pending_quantity2(j):= NULL;
            l_non_bulk_ship_line.pending_requested_flag.extend;
            l_non_bulk_ship_line.pending_requested_flag(j):= NULL;
            l_non_bulk_ship_line.actual_shipment_date.extend;
            l_non_bulk_ship_line.actual_shipment_date(j):=NVL(l_pick_up_date,sysdate);
            l_non_bulk_ship_line.shipping_quantity_uom.extend;
            l_non_bulk_ship_line.shipping_quantity_uom(j):= line_rec.requested_quantity_uom;
            l_non_bulk_ship_line.shipping_quantity_uom2.extend;
            l_non_bulk_ship_line.shipping_quantity_uom2(j):=NULL;
            l_non_bulk_ship_line.inventory_item_id.extend;
            l_non_bulk_ship_line.inventory_item_id(j):=NULL;
            l_non_bulk_ship_line.flow_status_code.extend;
            l_non_bulk_ship_line.flow_status_code(j):= line_rec.flow_status_code;
            l_non_bulk_ship_line.ordered_quantity.extend;
            l_non_bulk_ship_line.ordered_quantity(j):= line_rec.ordered_quantity;
            l_non_bulk_ship_line.shipping_quantity.extend;
            l_non_bulk_ship_line.shipping_quantity(j):= line_rec.total_shipped_quantity;
            l_non_bulk_ship_line.shipping_quantity2.extend;
            l_non_bulk_ship_line.shipping_quantity2(j):= NULL ;
            l_non_bulk_ship_line.ship_from_org_id.extend;
            l_non_bulk_ship_line.ship_from_org_id(j):= line_rec.organization_id;
            l_non_bulk_ship_line.org_id.extend;
            l_non_bulk_ship_line.org_id(j):= line_rec.org_id;
            l_non_bulk_ship_line.ordered_quantity2.extend;
            l_non_bulk_ship_line.ordered_quantity2(j):= NULL;
            l_non_bulk_ship_line.order_quantity_uom.extend;
            l_non_bulk_ship_line.order_quantity_uom(j):= line_rec.order_quantity_uom;
            l_non_bulk_ship_line.order_quantity_uom2.extend;
            l_non_bulk_ship_line.order_quantity_uom2(j):= NULL;
            l_non_bulk_ship_line.model_remnant_flag.extend;
            l_non_bulk_ship_line.model_remnant_flag(j):= NULL;
            l_non_bulk_ship_line.item_type_code.extend;
            l_non_bulk_ship_line.item_type_code(j):= NULL;
            l_non_bulk_ship_line.calculate_price_flag.extend;
            l_non_bulk_ship_line.calculate_price_flag(j):= NULL;
            l_non_bulk_ship_line.fulfilled_flag.extend;
            l_non_bulk_ship_line.fulfilled_flag(j):= 'Y'; --Should always be Y as we don't want order line to split
        --}
        END IF;
        <<loop_end>>
        CLOSE c_get_line_detail_to_interface;
    --}
    END LOOP; --  FOR i IN 1..line_id_tab.count LOOP

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Loop End');
    END IF;

    --If No STA STB case populate BULK variables
    l_row_count   := l_bulk_ship_line.line_id.count;
    l_end_index   := l_row_count;
    l_start_index := l_bulk_ship_line.line_id.first;

    --If STA or STB case populate NON BULK variables
    l_row_count_nonbulk   := l_non_bulk_ship_line.line_id.count;
    l_end_index_nonbulk   := l_row_count_nonbulk;
    l_start_index_nonbulk := l_non_bulk_ship_line.line_id.first;

    SAVEPOINT l_interface_om;

    --If No STA STB , call OM API in bulk mode
    IF l_row_count > 0 THEN
    --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Total bulk rows',l_row_count);
           WSH_DEBUG_SV.logmsg(l_module_name,'Establishing save point l_interface_om_bulk');
        END IF;

        SAVEPOINT l_interface_om_bulk;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Calling OE_Ship_Confirmation_Pub.Ship_Confirm_New TIME:',SYSDATE);
        END IF;

        MO_GLOBAL.set_policy_context('S', l_bulk_ship_line.org_id(l_start_index));
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Setting the org',l_bulk_ship_line.org_id(l_start_index));
        END IF;
        l_loop_count := l_loop_count +1;

        /*Call OM API in bulk mode to interface wdd to OM*/
        OE_Ship_Confirmation_Pub.Ship_Confirm_New(P_ship_line_rec => l_bulk_ship_line,
                                                  P_requested_line_rec => p_bulk_req_line,
                                                  P_line_adj_rec => l_ship_adj_line,
                                                  P_bulk_mode => 'Y',
                                                  P_start_index => l_start_index,
                                                  P_end_index => l_end_index,
                                                  x_msg_count => x_msg_count,
                                                  x_msg_data => x_msg_data,
                                                  x_return_status => l_return_status);

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'After OE_Shipping_Integration_PUB.Ship_Confirm_New TIME:',SYSDATE);
            WSH_DEBUG_SV.log(l_module_name,'l_return_status ',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name, 'NO. OF OE MESSAGES :'||X_MSG_COUNT );
        END IF;
        WSH_UTIL_CORE.printmsg('no. of OE messages :'||x_msg_count);

        FOR k IN 1 .. NVL(x_msg_count,0)
        LOOP
        --{
              --
              IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_MSG_PUB.GET',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              x_msg_data := oe_msg_pub.get( p_msg_index => k, p_encoded => 'F' );
              --
              IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, SUBSTR ( X_MSG_DATA , 1 , 255 ) );
              END IF;
              --
              WSH_UTIL_CORE.printmsg('Error msg: '||SUBSTR(x_msg_data,1,2000));
        --}
        END LOOP;

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        --{
            IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'ERROR');
            END IF;
            l_error_count := l_error_count + 1;
            IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint l_interface_om_bulk');
            END IF;
            ROLLBACK TO l_interface_om_bulk;
        --}
        END IF;
    --}
    END IF;

    --If STA or STB ,call OM API in non bulk mode
    IF l_row_count_nonbulk > 0 THEN
    --{
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Total Non bulk rows',l_row_count_nonbulk);
          END IF;
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Establishing save point l_interface_om_non_bulk');
          END IF;
          SAVEPOINT l_interface_om_non_bulk;
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Calling OE_Ship_Confirmation_Pub.Ship_Confirm_New TIME:',SYSDATE);
          END IF;

          MO_GLOBAL.set_policy_context('S', l_non_bulk_ship_line.org_id(l_start_index_nonbulk));

          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'setting the org',l_non_bulk_ship_line.org_id(l_start_index_nonbulk));
          END IF;

          l_loop_count := l_loop_count + 1;

          /*Call OM API in non bulk mode to interface WDD to OM*/
          OE_Ship_Confirmation_Pub.Ship_Confirm_New(P_ship_line_rec => l_non_bulk_ship_line,
                                                    P_requested_line_rec => p_bulk_req_line,
                                                    P_line_adj_rec => l_ship_adj_line,
                                                    P_bulk_mode => 'N',
                                                    P_start_index => l_start_index_nonbulk,
                                                    P_end_index => l_end_index_nonbulk,
                                                    x_msg_count => x_msg_count,
                                                    x_msg_data => x_msg_data,
                                                    x_return_status => l_return_status);
          IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'After OE_Shipping_Integration_PUB.Ship_Confirm_New TIME:',SYSDATE);
                  WSH_DEBUG_SV.log(l_module_name,'l_return_status ',l_return_status);
                  WSH_DEBUG_SV.logmsg(l_module_name, 'NO. OF OE MESSAGES :'
                  ||X_MSG_COUNT );
          END IF;
          WSH_UTIL_CORE.printmsg('no. of OE messages :'||x_msg_count);

          FOR k IN 1 .. NVL(x_msg_count,0)
          LOOP
                  --
                  IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_MSG_PUB.GET',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  --
                  x_msg_data := oe_msg_pub.get( p_msg_index => k, p_encoded => 'F' );
                  --
                  IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name, SUBSTR ( X_MSG_DATA , 1 , 255 ) );
                  END IF;
                  --
                  WSH_UTIL_CORE.printmsg('Error msg: '||SUBSTR(x_msg_data,1,2000));
          END LOOP;

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          --{
                IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'ERROR');
                END IF;
                l_error_count := l_error_count + 1;
                IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint l_interface_om_non_bulk');
                END IF;
                ROLLBACK TO l_interface_om_non_bulk;
          --}
          END IF;
    --}
    END IF;

    IF l_row_count = 0 AND l_row_count_nonbulk = 0 THEN
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'*******No eligible lines found*********');
      END IF;
    END IF;

    IF ( l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
        x_return_status := l_return_status;
    END IF;

    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.printMsg('API Process_lines_To_OM failed with an unexpected error');
        WSH_UTIL_CORE.PrintMsg('The unexpected error is '|| sqlerrm);

        IF c_get_line_detail_to_interface%ISOPEN THEN
           close c_get_line_detail_to_interface;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rollback to savepoint l_interface_om');
        END IF;
        ROLLBACK TO SAVEPOINT l_interface_om;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'UNEXPECTED ERROR IN Process_lines_To_OM' );
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Process_lines_To_OM;

END WSH_SHIP_CONFIRM_ACTIONS;

/
