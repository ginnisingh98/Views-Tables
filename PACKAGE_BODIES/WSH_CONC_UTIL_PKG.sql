--------------------------------------------------------
--  DDL for Package Body WSH_CONC_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CONC_UTIL_PKG" AS
/* $Header: WSHCPUTB.pls 120.7 2006/05/23 21:42:47 wrudge noship $ */


G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_CONC_UTIL_PKG';

G_BULK_SIZE CONSTANT NUMBER := 1000;   -- ECO 5069719
G_ENTITY_TRIP   CONSTANT NUMBER := 1;
G_ENTITY_DEL    CONSTANT NUMBER := 2;
G_ENTITY_DETAIL CONSTANT NUMBER := 3;

-- DESCRIPTION: This procedure updates transactions with the new/valid     |
--              Freight Code/Carrier id after upgrade. It updates the      |
--              Old/Invalid Fgt.Code with the new/valid Fgt. Code, where   |
--              ever the Old Fgt.Code-Ship.Method Combination is non-exis  |
--              -tant after the upgrade.                                   |

Procedure Worker_Upgrade_Closed_Orders(
                                errbuf    OUT NOCOPY   VARCHAR2,
                                retcode    OUT NOCOPY   VARCHAR2,
                                p_batch_commit_size IN NUMBER,
                                p_logical_worker_id IN NUMBER,
                                p_numworkers IN NUMBER) IS



cursor c_get_new_fgt_code (p_ship_method_code varchar2) is
select wc.freight_code, wc.carrier_id
from  wsh_carriers wc, wsh_carrier_services wcs
where
      wcs.ship_method_code = p_ship_method_code
 and  wcs.carrier_id  = wc.carrier_id;

-- II. Get All the Fgt.Code - S.Method not upgraded and thus would be having problem
--
cursor c_get_comb_notupg is
select wcsm.ship_method_code , wcsm.organization_id , wcsm.freight_code
from wsh_carrier_ship_methods wcsm
where
 not exists (select 'x' from wsh_carriers wc,
                    wsh_carrier_services wcs
             where
                   wc.freight_code = wcsm.freight_code
              and  wc.carrier_id  = wcs.carrier_id
              and  wcs.ship_method_code = wcsm.ship_method_code);


l_new_freight_code             VARCHAR2(30);
l_new_carrier_id             NUMBER;
l_tot_lin_upd      NUMBER;
l_tot_hdr_upd     NUMBER;



l_script_name     varchar2(30);
l_table_owner varchar2(3) ;
l_table_name varchar2(30) ;
l_worker_id NUMBER;
l_num_workers NUMBER;
l_batch_size NUMBER;
l_start_rowid     rowid;
l_end_rowid       rowid;
l_rows_processed  number;
l_any_rows_to_process boolean;


--
l_debug_on CONSTANT BOOLEAN  := WSH_DEBUG_SV.is_debug_enabled ;
--
l_module_name CONSTANT VARCHAR2(100)  := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Worker_Upgrade_Closed_Orders';

BEGIN
--


 IF l_debug_on THEN
   WSH_DEBUG_SV.push(l_module_name);
 END IF;

 l_script_name     := 'wshupoe_01';
 l_table_owner := 'ONT';
 l_table_name  := 'OE_ORDER_LINES_ALL';
 l_worker_id := p_logical_worker_id;
 l_num_workers := p_numworkers;
 l_batch_size  := p_batch_commit_size;
 l_rows_processed  := 0;

 IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit ad_parallel_updates_pkg.initialize_rowid_range',WSH_DEBUG_SV.C_PROC_LEVEL);
 END IF;
 ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           l_worker_id,
           l_num_workers,
           l_batch_size, 0);

 IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit ad_parallel_updates_pkg.get_rowid_range',WSH_DEBUG_SV.C_PROC_LEVEL);
 END IF;
 ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);
----------------------------------------------------------------
l_tot_lin_upd      := 0;
l_tot_hdr_upd     := 0;
------------------------------------------------------------------

WHILE (l_any_rows_to_process = TRUE)
LOOP


   FOR v_notupg IN c_get_comb_notupg
   LOOP

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'v_notupg.ship_method_code',v_notupg.ship_method_code);
           WSH_DEBUG_SV.log(l_module_name,'v_notupg.freight_code',v_notupg.freight_code);
        END IF;
        l_new_freight_code := null;
        l_new_carrier_id    := null;

        --For Every Comb. not existing
        -- Getting new Fgt. Code , carrier id
        OPEN  c_get_new_fgt_code (v_notupg.ship_method_code);
        FETCH c_get_new_fgt_code INTO l_new_freight_code, l_new_carrier_id;
        CLOSE c_get_new_fgt_code;

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_new_freight_code',l_new_freight_code);
           WSH_DEBUG_SV.log(l_module_name,'l_new_carrier_id',l_new_carrier_id);
        END IF;

        -- Update Closed Order Lines, Interfaced to Shpg. and Not cancelled
        update /*+ ROWID (oel) */ oe_order_lines_all oel
        set oel.freight_carrier_code = l_new_freight_code
        , oel.last_updated_by = -2950631
        , oel.last_update_date = sysdate
        where oel.open_flag = 'N'
        and oel.rowid BETWEEN l_start_rowid AND l_end_rowid
        and nvl(oel.cancelled_flag, 'N') = 'N'
        and oel.shipping_interfaced_flag = 'Y'
        and oel.freight_carrier_code = v_notupg.freight_code
        and oel.shipping_method_code = v_notupg.ship_method_code;

        IF SQL%NOTFOUND THEN
           null;
        END IF;

        -- Update Closed Headers, whose lines are closed, and Not cancelled
        update  oe_order_headers_all oeh
        set oeh.freight_carrier_code = l_new_freight_code
        , oeh.last_updated_by = -2950631
        , oeh.last_update_date = sysdate
        where oeh.open_flag = 'N'
        and nvl(oeh.cancelled_flag, 'N') = 'N'
        and oeh.freight_carrier_code = v_notupg.freight_code
        and oeh.shipping_method_code = v_notupg.ship_method_code
        and exists (select /*+ ROWID (oel) */ 'x' from oe_order_lines_all oel      -- Getting Only Shpg. Interfaced Lines
                where oel.header_id  = oeh.header_id
                and oel.rowid BETWEEN l_start_rowid AND l_end_rowid
                and oel.open_flag = 'N'
                and nvl(oel.cancelled_flag, 'N') = 'N'
                and oel.SHIPPING_INTERFACED_FLAG = 'Y');

        IF SQL%NOTFOUND THEN
           null;
        END IF;

   END LOOP;  -- FOR v_notupg in c_fgt_not_upg

   ad_parallel_updates_pkg.processed_rowid_range(
          l_rows_processed,
          l_end_rowid);

   --
   -- commit transaction here
   --

   commit;

   --
   -- get new range of rowids
   --
   ad_parallel_updates_pkg.get_rowid_range(
         l_start_rowid,
         l_end_rowid,
         l_any_rows_to_process,
         l_batch_size,
         FALSE);

END LOOP;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
EXCEPTION
WHEN OTHERS THEN
      errbuf := 'Exception occurred in Worker_Upgrade_Closed_Orders: ' ||
                 'SQLCODE: '||sqlcode||' SQLERRM: '||sqlerrm;
      retcode := '2';
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
END Worker_Upgrade_Closed_Orders;

Procedure Master_Conc_Parallel_Upgrade(
                                       errbuf    OUT NOCOPY   VARCHAR2,
                                       retcode    OUT NOCOPY   VARCHAR2,
                                       p_worker_conc_appsshortname IN VARCHAR2,
                                       p_worker_conc_program IN VARCHAR2,
                                       p_batch_commit_size IN NUMBER,
                                       p_numworkers IN NUMBER) IS

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Worker_Upgrade_Closed_Orders';
BEGIN

IF l_debug_on THEN
  WSH_DEBUG_SV.push(l_module_name);
END IF;
AD_CONC_UTILS_PKG.submit_subrequests(
        X_errbuf                    => errbuf,
        X_retcode                   => retcode,
        X_WorkerConc_app_shortname  => p_worker_conc_appsshortname,
        X_WorkerConc_progname       => p_worker_conc_program,
        X_Batch_Size                => p_batch_commit_size,
        X_Num_Workers               => p_numworkers,
        X_Argument4                 => NULL,
        X_Argument5                 => NULL,
        X_Argument6                 => NULL,
        X_Argument7                 => NULL,
        X_Argument8                 => NULL,
        X_Argument9                 => NULL,
        X_Argument10                => NULL);

IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;
END Master_Conc_Parallel_Upgrade;


-- Description: utility to lock/update entities for ECO 5069719
--              so that service level and mode of transport will be updated.
--
--              exceptions will be raised to the caller.
--
-- Parameters:
--      p_entity = G_ENTITY_TRIP, G_ENTITY_DEL, G_ENTITY_DETAIL
--      p_ship_method_code, p_carrier_id = identify records that need update
--      p_service_level, p_mode_of_transport = values to update in table
--      x_count    = count of records updated
--      x_count_nu = count of records not updated (because of locks)
--      x_sm_state = state to update UPDATE_MOT_SL:
--                          NULL -- fully processed
--                          'Y'  -- at least one record was not updated
PROCEDURE process_entity_sm(p_entity            IN NUMBER,
                            p_ship_method_code  IN VARCHAR2,
                            p_carrier_id        IN NUMBER,
                            p_service_level     IN VARCHAR2,
                            p_mode_of_transport IN VARCHAR2,
                            x_count             IN OUT NOCOPY NUMBER,
                            x_count_nu          IN OUT NOCOPY NUMBER,
                            x_sm_state          IN OUT NOCOPY VARCHAR2) IS

  CURSOR c_current_trips(x_ship_method_code IN VARCHAR2,
                         x_carrier_id       IN NUMBER) IS
  SELECT trip_id
  FROM   WSH_TRIPS
  WHERE  status_code = 'OP'
  AND    ship_method_code = x_ship_method_code
  AND    carrier_id       = x_carrier_id
  AND    mode_of_transport IS NULL
  AND    service_level     IS NULL;

  CURSOR c_current_dels(x_ship_method_code IN VARCHAR2,
                        x_carrier_id       IN NUMBER) IS
  SELECT delivery_id
  FROM   WSH_NEW_DELIVERIES
  WHERE  status_code IN ('OP', 'CO', 'SA', 'SR', 'SC')
  AND    ship_method_code = x_ship_method_code
  AND    carrier_id       = x_carrier_id
  AND    mode_of_transport IS NULL
  AND    service_level     IS NULL;

  CURSOR c_current_details(x_ship_method_code IN VARCHAR2,
                           x_carrier_id       IN NUMBER) IS
  SELECT delivery_detail_id
  FROM   WSH_DELIVERY_DETAILS
  WHERE  released_status IN ('N', 'R', 'B', 'X', 'S', 'Y')
  AND    ship_method_code = x_ship_method_code
  AND    carrier_id       = x_carrier_id
  AND    mode_of_transport IS NULL
  AND    service_level     IS NULL;

  CURSOR c_lock_trip(x_id IN NUMBER) IS
  SELECT trip_id
  FROM   WSH_TRIPS
  WHERE  trip_id = x_id
  FOR UPDATE NOWAIT;

  CURSOR c_lock_del(x_id IN NUMBER) IS
  SELECT delivery_id
  FROM   WSH_NEW_DELIVERIES
  WHERE  delivery_id = x_id
  FOR UPDATE NOWAIT;

  CURSOR c_lock_detail(x_id IN NUMBER) IS
  SELECT delivery_detail_id
  FROM   WSH_DELIVERY_DETAILS
  WHERE  delivery_detail_id = x_id
  FOR UPDATE NOWAIT;

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_ENTITY_SM';

  l_continue   BOOLEAN;
  l_work_ids   WSH_UTIL_CORE.ID_TAB_TYPE;
  l_update_ids WSH_UTIL_CORE.ID_TAB_TYPE;

  l_work_index    NUMBER;
  l_update_index  NUMBER;

  l_user_id    NUMBER;
  l_login      NUMBER;

  l_dummy_id   NUMBER;

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
    WSH_DEBUG_SV.log(l_module_name, 'p_entity',   p_entity);
    WSH_DEBUG_SV.log(l_module_name, 'in x_count',    x_count);
    WSH_DEBUG_SV.log(l_module_name, 'in x_count_nu', x_count_nu);
    WSH_DEBUG_SV.log(l_module_name, 'in x_sm_state', x_sm_state);
  END IF;

  IF    (p_entity IS NULL)
     OR (p_entity NOT IN (G_ENTITY_TRIP, G_ENTITY_DEL,G_ENTITY_DETAIL)) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'unrecognized p_entity', p_entity);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;

  IF p_entity = G_ENTITY_TRIP THEN
    OPEN c_current_trips(p_ship_method_code, p_carrier_id);
  ELSIF p_entity = G_ENTITY_DEL THEN
    OPEN c_current_dels (p_ship_method_code, p_carrier_id);
  ELSE
    OPEN c_current_details(p_ship_method_code, p_carrier_id);
  END IF;

  l_user_id := FND_GLOBAL.USER_ID;
  l_login   := FND_GLOBAL.LOGIN_ID;

  l_continue     := TRUE;
  l_update_index := 0;

  WHILE l_continue LOOP

    IF p_entity = G_ENTITY_TRIP THEN
      FETCH c_current_trips   BULK COLLECT INTO l_work_ids LIMIT G_BULK_SIZE;
      l_continue := c_current_trips%FOUND;
    ELSIF p_entity = G_ENTITY_DEL THEN
      FETCH c_current_dels    BULK COLLECT INTO l_work_ids LIMIT G_BULK_SIZE;
      l_continue := c_current_dels%FOUND;
    ELSE
      FETCH c_current_details BULK COLLECT INTO l_work_ids LIMIT G_BULK_SIZE;
      l_continue := c_current_details%FOUND;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_work_ids.COUNT', l_work_ids.COUNT);
      WSH_DEBUG_SV.log(l_module_name, 'l_continue', l_continue);
    END IF;

    IF (l_work_ids.COUNT > 0) THEN
      FOR l_work_index IN 1 .. l_work_ids.COUNT LOOP
        BEGIN
          IF p_entity = G_ENTITY_TRIP THEN
            OPEN  c_lock_trip(l_work_ids(l_work_index));
            FETCH c_lock_trip INTO l_dummy_id;
            CLOSE c_lock_trip;
          ELSIF p_entity = G_ENTITY_DEL THEN
            OPEN  c_lock_del(l_work_ids(l_work_index));
            FETCH c_lock_del INTO l_dummy_id;
            CLOSE c_lock_del;
          ELSE
            OPEN  c_lock_detail(l_work_ids(l_work_index));
            FETCH c_lock_detail INTO l_dummy_id;
            CLOSE c_lock_detail;
          END IF;

          l_update_index := l_update_index + 1;
          l_update_ids(l_update_index) := l_work_ids(l_work_index);
        EXCEPTION
          WHEN OTHERS THEN -- lock will raise exception
            IF c_lock_trip%ISOPEN   THEN  CLOSE c_lock_trip;    END IF;
            IF c_lock_del%ISOPEN    THEN  CLOSE c_lock_del;     END IF;
            IF c_lock_detail%ISOPEN THEN  CLOSE c_lock_detail;  END IF;

            x_count_nu := x_count_nu + 1;
            -- this service needs to be processed in the next request.
            x_sm_state := 'Y';
        END;
      END LOOP;
    END IF;

    IF    (l_update_index >= G_BULK_SIZE)
       OR ( (NOT l_continue) AND (l_update_index > 0) ) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_update_index', l_update_index);
      END IF;

      IF p_entity = G_ENTITY_TRIP THEN
        FORALL i IN 1 .. l_update_index
          UPDATE WSH_TRIPS
          SET    service_level     = p_service_level,
                 mode_of_transport = p_mode_of_transport,
                 last_updated_by   = l_user_id,
                 last_update_date  = sysdate,
                 last_update_login = l_login
          WHERE trip_id = l_update_ids(i)
          AND   ship_method_code = p_ship_method_code
          AND   carrier_id       = p_carrier_id;
      ELSIF p_entity = G_ENTITY_DEL THEN
        FORALL i IN 1 .. l_update_index
          UPDATE WSH_NEW_DELIVERIES
          SET    service_level     = p_service_level,
                 mode_of_transport = p_mode_of_transport,
                 last_updated_by   = l_user_id,
                 last_update_date  = sysdate,
                 last_update_login = l_login
          WHERE delivery_id = l_update_ids(i)
          AND   ship_method_code = p_ship_method_code
          AND   carrier_id       = p_carrier_id;
      ELSE
        FORALL i IN 1 .. l_update_index
          UPDATE WSH_DELIVERY_DETAILS
          SET    service_level     = p_service_level,
                 mode_of_transport = p_mode_of_transport,
                 last_updated_by   = l_user_id,
                 last_update_date  = sysdate,
                 last_update_login = l_login
          WHERE delivery_detail_id = l_update_ids(i)
          AND   ship_method_code = p_ship_method_code
          AND   carrier_id       = p_carrier_id;
      END IF;
      COMMIT;
      x_count        := x_count + l_update_index;
      l_update_index := 0; -- instead of l_update_ids.DELETE.
    END IF;

  END LOOP;

  IF c_current_trips%ISOPEN   THEN  CLOSE c_current_trips;   END IF;
  IF c_current_dels%ISOPEN    THEN  CLOSE c_current_dels;    END IF;
  IF c_current_details%ISOPEN THEN  CLOSE c_current_details; END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'out x_count',    x_count);
    WSH_DEBUG_SV.log(l_module_name, 'out x_count_nu', x_count_nu);
    WSH_DEBUG_SV.log(l_module_name, 'out x_sm_state', x_sm_state);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_current_trips%ISOPEN   THEN  CLOSE c_current_trips;   END IF;
    IF c_current_dels%ISOPEN    THEN  CLOSE c_current_dels;    END IF;
    IF c_current_details%ISOPEN THEN  CLOSE c_current_details; END IF;
    WSH_UTIL_CORE.DEFAULT_HANDLER(l_module_name);
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'OTHERS exception has occured.'
                                       ,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.log(l_module_name, 'out x_count',    x_count);
      WSH_DEBUG_SV.log(l_module_name, 'out x_count_nu', x_count_nu);
      WSH_DEBUG_SV.log(l_module_name, 'out x_sm_state', x_sm_state);
      WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:OTHERS');
    END IF;
    RAISE;

END process_entity_sm;



-- Description: utility to lock/stamp WSH_CARRIER_SERVICES for ECO 5069719
--
--              if ship method is pending in an active record, this
--              will be treated as locked.
--
--              if the service record is found and can be locked,
--              update this service as pending this request.
--
--              non-lock exceptions will be raised to callers.
-- Parameters:
--      p_carrier_service_id = WSH_CARRIER_SERVICES record to update.
--      p_new_state          = value to set UPDATE_MOT_SL:
--                        'P'  -- to be processed by this request
--                        'Y'  -- needs update, available for next request
--                        NULL -- completely processed
FUNCTION lock_stamp_service(p_carrier_service_id IN NUMBER,
                            p_new_state          IN VARCHAR2)
RETURN BOOLEAN IS

  CURSOR c_lock_service(p_id NUMBER) IS
  SELECT update_mot_sl,
         request_id
  FROM   WSH_CARRIER_SERVICES
  WHERE  carrier_service_id = p_id
  AND    update_mot_sl IN ('Y', 'P')
  FOR UPDATE NOWAIT;

  CURSOR c_request_completed(p_id NUMBER) IS
  SELECT 1
  FROM fnd_concurrent_requests fcr
  WHERE  fcr.request_id = p_id
  AND    fcr.phase_code = 'C'
  AND    rownum = 1;

  l_rec    c_lock_service%ROWTYPE;
  l_req_c  c_request_completed%ROWTYPE;
  l_found  BOOLEAN;
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_STAMP_SERVICE';

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
      WSH_DEBUG_SV.log(l_module_name,'p_carrier_service_id',
                                     p_carrier_service_id);
      WSH_DEBUG_SV.log(l_module_name,'p_new_state', p_new_state);
  END IF;
  --
  SAVEPOINT sp_before_lock;
  --
  OPEN  c_lock_service(p_carrier_service_id);
  FETCH c_lock_service INTO l_rec;
  l_found := c_lock_service%FOUND;
  CLOSE c_lock_service;

  IF     l_found
     AND l_rec.update_mot_sl = 'P'
     AND l_rec.request_id <> fnd_global.conc_request_id THEN
    -- if this service is pending, check whether its request is still running.

    OPEN  c_request_completed(l_rec.request_id);
    FETCH c_request_completed INTO l_req_c;
    l_found := c_request_completed%NOTFOUND;
    CLOSE c_request_completed;

    IF NOT l_found THEN
      -- since this request is currently not completed; release lock.
      ROLLBACK TO sp_before_lock;
    END IF;
  END IF;

  IF l_found THEN
    -- update this service for this request.
    UPDATE WSH_CARRIER_SERVICES
    SET    update_mot_sl          = p_new_state,
           request_id             = fnd_global.conc_request_id,
           last_updated_by        = fnd_global.user_id,
           last_update_date       = sysdate
    WHERE  carrier_service_id = p_carrier_service_id;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'return value', l_found);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  RETURN l_found;

EXCEPTION
  WHEN app_exception.record_lock_exception THEN
    IF c_lock_service%ISOPEN      THEN  CLOSE c_lock_service;       END IF;
    IF c_request_completed%ISOPEN THEN  CLOSE c_request_completed;  END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,
         'APP_EXCEPTION.RECORD_LOCK_EXCEPTION exception has occured.',
         WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,
                       'EXCEPTION:APP_EXCEPTION.RECORD_LOCK_EXCEPTION');
    END IF;
    RETURN FALSE;

  WHEN OTHERS THEN
    IF c_lock_service%ISOPEN      THEN  CLOSE c_lock_service;       END IF;
    IF c_request_completed%ISOPEN THEN  CLOSE c_request_completed;  END IF;
    WSH_UTIL_CORE.DEFAULT_HANDLER(l_module_name);
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'OTHERS exception has occured.'
                                       ,WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    RAISE;

END lock_stamp_service;


-- Description: Update Ship Method SRS for ECO 5069719
--              This will upgrade open shipping data with mode of transport
--              and service level that are entered on ship methods upgraded
--              from 11.0 or 10.7
-- PARAMETERS: errbuf                  Used by the concurrent program for error
--                                     messages.
--             retcode                 Used by the concurrent program for
--                                     return code.
PROCEDURE update_ship_method_SRS(
                  errbuf      OUT NOCOPY  VARCHAR2,
                  retcode     OUT NOCOPY  VARCHAR2)
IS

  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) :=
             'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_SHIP_METHOD_SRS';

  l_rc                BOOLEAN;
  l_completion_status VARCHAR2(30);
  l_errbuf            VARCHAR2(2000);
  l_retcode           VARCHAR2(2000);

  -- internal procedure to write to the output file
  --   if parameter is NULL, write the message from stack.
  --   otherwise, if there is no message, a new line will be output.
  PROCEDURE print_output(p_text IN VARCHAR2 DEFAULT NULL) IS
   l_text VARCHAR2(2000);
  BEGIN
    l_text := p_text;

    IF l_text IS NULL THEN
      l_text := FND_MESSAGE.GET;
    END IF;

    IF l_text IS NOT NULL THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_text);
    ELSE
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    END IF;
  END print_output;

BEGIN

  WSH_UTIL_CORE.Enable_Concurrent_Log_Print;

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  l_completion_status := 'NORMAL';
  l_errbuf            := '';
  l_retcode           := '';


  -- this exception handling block contains the update SM logic
  DECLARE
    CURSOR c_ship_methods IS
    SELECT carrier_service_id,
           ship_method_code,
           carrier_id,
           service_level,
           mode_of_transport
    FROM   WSH_CARRIER_SERVICES
    WHERE  UPDATE_MOT_SL IN ('Y', 'P');

    -- inc = incompletely updated
    -- nu = not updated because of locks

    l_count_sm       NUMBER;
    l_count_sm_inc    NUMBER;

    l_count_trips    NUMBER;
    l_count_trips_nu NUMBER;

    l_count_dels     NUMBER;
    l_count_dels_nu  NUMBER;

    l_count_dds      NUMBER;
    l_count_dds_nu   NUMBER;

    l_sm_state       WSH_CARRIER_SERVICES.UPDATE_MOT_SL%TYPE;

  BEGIN
    l_count_sm       := 0;
    l_count_sm_inc   := 0;
    l_count_trips    := 0;
    l_count_trips_nu := 0;
    l_count_dels     := 0;
    l_count_dels_nu  := 0;
    l_count_dds      := 0;
    l_count_dds_nu   := 0;

    FOR l_sm_rec IN c_ship_methods LOOP
      IF lock_stamp_service(l_sm_rec.carrier_service_id, 'P')  THEN
        l_sm_state := NULL;

        process_entity_sm(p_entity            => G_ENTITY_TRIP,
                          p_ship_method_code  => l_sm_rec.ship_method_code,
                          p_carrier_id        => l_sm_rec.carrier_id,
                          p_service_level     => l_sm_rec.service_level,
                          p_mode_of_transport => l_sm_rec.mode_of_transport,
                          x_count             => l_count_trips,
                          x_count_nu          => l_count_trips_nu,
                          x_sm_state          => l_sm_state);

        process_entity_sm(p_entity            => G_ENTITY_DEL,
                          p_ship_method_code  => l_sm_rec.ship_method_code,
                          p_carrier_id        => l_sm_rec.carrier_id,
                          p_service_level     => l_sm_rec.service_level,
                          p_mode_of_transport => l_sm_rec.mode_of_transport,
                          x_count             => l_count_dels,
                          x_count_nu          => l_count_dels_nu,
                          x_sm_state          => l_sm_state);

        process_entity_sm(p_entity            => G_ENTITY_DETAIL,
                          p_ship_method_code  => l_sm_rec.ship_method_code,
                          p_carrier_id        => l_sm_rec.carrier_id,
                          p_service_level     => l_sm_rec.service_level,
                          p_mode_of_transport => l_sm_rec.mode_of_transport,
                          x_count             => l_count_dds,
                          x_count_nu          => l_count_dds_nu,
                          x_sm_state          => l_sm_state);

        IF l_sm_state IS NULL THEN
          -- service is fully updated
          l_count_sm := l_count_sm + 1;
        ELSE
          -- at least one record could not be updated.
          l_count_sm_inc := l_count_sm_inc + 1;
        END IF;

        -- ignore outcome; if this record cannot be updated,
        -- the next request will process and update it.
        IF lock_stamp_service(l_sm_rec.carrier_service_id, l_sm_state) THEN
          COMMIT;
        END IF;
      END IF;
    END LOOP;

    IF l_count_sm_inc > 0 THEN
      l_completion_status := 'WARNING';
    END IF;

    FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_SM_COUNTS');
    FND_MESSAGE.SET_TOKEN('COUNT_PROCESSED',  l_count_sm);
    FND_MESSAGE.SET_TOKEN('COUNT_INCOMPLETE', l_count_sm_inc);
    print_output;

    FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_SM_TRIP_COUNTS');
    FND_MESSAGE.SET_TOKEN('COUNT_UPDATED',     l_count_trips);
    FND_MESSAGE.SET_TOKEN('COUNT_NOT_UPDATED', l_count_trips_nu);
    print_output;

    FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_SM_DEL_COUNTS');
    FND_MESSAGE.SET_TOKEN('COUNT_UPDATED',     l_count_dels);
    FND_MESSAGE.SET_TOKEN('COUNT_NOT_UPDATED', l_count_dels_nu);
    print_output;

    FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_SM_DD_COUNTS');
    FND_MESSAGE.SET_TOKEN('COUNT_UPDATED',     l_count_dds);
    FND_MESSAGE.SET_TOKEN('COUNT_NOT_UPDATED', l_count_dds_nu);
    print_output;

  EXCEPTION
    WHEN OTHERS THEN
      WSH_UTIL_CORE.DEFAULT_HANDLER(l_module_name);

      l_completion_status := 'ERROR';
      l_errbuf            := SQLERRM;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
             'Internal unexpected error has occured. Oracle error message',
             l_errbuf,
             WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      END IF;
      WSH_UTIL_CORE.printmsg(l_errbuf);

      IF c_ship_methods%ISOPEN    THEN CLOSE c_ship_methods;     END IF;
      ROLLBACK;
  END;

  IF l_completion_status IN ('WARNING', 'ERROR')  THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_SM_TRY_AGAIN');
    print_output;
  END IF;

  l_rc    := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,
                                                  'update_ship_method_SRS');
  errbuf  := l_errbuf;
  retcode := l_retcode;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'COMPLETION STATUS', l_completion_status);
    WSH_DEBUG_SV.log(l_module_name,'ERRBUF',  l_errbuf);
    WSH_DEBUG_SV.log(l_module_name,'RETCODE', l_retcode);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;


  EXCEPTION
    WHEN OTHERS THEN
      WSH_UTIL_CORE.DEFAULT_HANDLER(l_module_name);

      l_completion_status := 'ERROR';
      l_errbuf            := SQLERRM;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
             'API unexpected error has occured. Oracle error message',
             l_errbuf,
             WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      END IF;
      WSH_UTIL_CORE.printmsg(l_errbuf);

      l_rc    := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,
                                                     'update_ship_method_SRS');
      errbuf  := l_errbuf;
      retcode := l_retcode;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'COMPLETION STATUS',
                                                  l_completion_status);
        WSH_DEBUG_SV.log(l_module_name,'ERRBUF',  l_errbuf);
        WSH_DEBUG_SV.log(l_module_name,'RETCODE', l_retcode);
        WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;
      ROLLBACK;

END update_ship_method_SRS;



END WSH_CONC_UTIL_PKG;


/
