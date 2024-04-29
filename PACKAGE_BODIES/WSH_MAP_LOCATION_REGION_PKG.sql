--------------------------------------------------------
--  DDL for Package Body WSH_MAP_LOCATION_REGION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_MAP_LOCATION_REGION_PKG" AS
/* $Header: WSHMLORB.pls 120.16.12010000.3 2009/04/01 08:37:06 ueshanka ship $ */

 /*===========================================================================+
 | PROCEDURE                                                                 |
 |              Map_Locations                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This procedure selects the minimum and maximum location id   |
 |              and fires the child concurrent program depending on the      |
 |              value of parameter p_num_of_instances                        |
 |                                                                           |
 +===========================================================================*/

G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_MAP_LOCATION_REGION_PKG';

-- Bug 4722963
-- Tables to be used for bulk operations on WSH_REGION_LOCATIONS in APIs, insert_records/ update_records / delete_records
l_location_id_tab       TableNumbers;
l_region_id_tab         TableNumbers;
l_region_type_tab       TableNumbers;
l_exceptions_tab        TableVarchar;
l_location_source_tab   TableVarchar;
l_parent_region_tab     TableVarchar;

/*TYPE upd_loc_id_rec IS RECORD
(
 l_upd_loc_id   NUMBER,
 l_log_excep    BOOLEAN
 );*/

--TYPE upd_loc_id_tab IS TABLE OF upd_loc_id_rec INDEX BY BINARY_INTEGER;

--l_upd_loc_id_tab        upd_loc_id_tab;
l_del_loc_id_tab        TableNumbers;
l_upd_loc_id_tab        TableNumbers;
l_upd_loc_excp_tab      TableBoolean;


-- Bug 4722963 end

PROCEDURE Map_Locations (
    p_errbuf              OUT NOCOPY   VARCHAR2,
    p_retcode             OUT NOCOPY   NUMBER,
    p_map_regions         IN   VARCHAR2,
    p_location_type       IN   VARCHAR2,
    p_num_of_instances    IN   NUMBER,
    p_start_date          IN   VARCHAR2,
    p_end_date            IN   VARCHAR2,
    p_fte_installed	  IN   VARCHAR2 default NULL,
    p_create_facilities   IN   VARCHAR2 default NULL) IS


l_worker_min_tab        WSH_UTIL_CORE.id_tab_type;
l_worker_max_tab        WSH_UTIL_CORE.id_tab_type;
l_new_request_id        NUMBER := 0;
i                       NUMBER := 0;
l_sqlcode               NUMBER;
l_sqlerr                VARCHAR2(2000);
l_return_status         VARCHAR2(10);
l_completion_status     VARCHAR2(30);
l_retcode               NUMBER;
l_errbuf                VARCHAR2(2000);
l_num_of_instances      NUMBER;
l_mode                  VARCHAR2(30);
l_insert_flag           VARCHAR2(1);
l_debug_on              BOOLEAN;
l_req_data              VARCHAR2(50);
l_temp                  BOOLEAN;
l_this_request          NUMBER;
l_module_name CONSTANT  VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAP_LOCATIONS';
l_start_date            DATE;
l_end_date              DATE;
l_import_start_date     Date;

BEGIN

    l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    WSH_UTIL_CORE.Enable_Concurrent_Log_Print;

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_TYPE',P_LOCATION_TYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_MAP_REGIONS',P_MAP_REGIONS);
        WSH_DEBUG_SV.log(l_module_name,'P_NUM_OF_INSTANCES',P_NUM_OF_INSTANCES);
        WSH_DEBUG_SV.log(l_module_name,'P_START_DATE',P_START_DATE);
        WSH_DEBUG_SV.log(l_module_name,'P_END_DATE',P_END_DATE);
        WSH_DEBUG_SV.log(l_module_name,'P_FTE_INSTALLED',P_FTE_INSTALLED);
        WSH_DEBUG_SV.log(l_module_name,'P_CREATE_FACILITIES',P_CREATE_FACILITIES);
    END IF;

    l_mode := 'MAP';
    l_completion_status := 'NORMAL';

    IF p_num_of_instances is null or p_num_of_instances = 0 then
      l_num_of_instances := 1;
    ELSE
      l_num_of_instances := p_num_of_instances;
    END IF;

    -- Bug 4740786
    l_req_data := fnd_conc_global.request_data;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,  'l_req_data', l_req_data);
    END IF;

    IF l_req_data IS NOT NULL THEN
        l_req_data          := SUBSTR(l_req_data, 1,1);
    END IF;

    l_start_date := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
    l_end_date   := to_date(p_end_date,'YYYY/MM/DD HH24:MI:SS') +1;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_START_DATE',l_START_DATE);
        WSH_DEBUG_SV.log(l_module_name,'l_END_DATE',l_END_DATE);
    END IF;

    -- If l_req_data is not null, that means, import shipping locations has been executed.
    -- Call Location to region Mapping concurrent program and return.
    IF l_req_data IS NULL THEN
        IF p_location_type = 'EXTERNAL'  THEN

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,  'Location Type is External');
            END IF;

            EXECUTE IMMEDIATE 'SELECT MIN(LOCATION_ID),MAX(LOCATION_ID)
                               FROM   ( SELECT location_id, NTILE(:num_instances) OVER (ORDER BY location_id) worker
                                        FROM   HZ_LOCATIONS
                                        WHERE  last_update_date >= nvl(:start_date, last_update_date)
                                        AND    last_update_date < nvl(:end_date, last_update_date+1)
                                      )
                               GROUP BY WORKER'
            BULK COLLECT INTO l_worker_min_tab, l_worker_max_tab
            USING l_num_of_instances, l_start_date, l_end_date;

        ELSIF p_location_type = 'INTERNAL'  THEN

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,  'Location Type is Internal');
            END IF;

             EXECUTE IMMEDIATE 'SELECT MIN(LOCATION_ID),MAX(LOCATION_ID)
                               FROM   ( SELECT location_id, NTILE(:num_instances) OVER (ORDER BY location_id) worker
                                        FROM   HR_LOCATIONS_ALL
                                        WHERE  last_update_date >= nvl(:start_date, last_update_date)
                                        AND    last_update_date < nvl(:end_date, last_update_date+1)
                                      )
                               GROUP BY WORKER'
            BULK COLLECT INTO l_worker_min_tab, l_worker_max_tab
            USING l_num_of_instances, l_start_date, l_end_date;

        ELSIF p_location_type = 'BOTH'  THEN

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,  'Location Type is Both');
            END IF;

            EXECUTE IMMEDIATE 'SELECT MIN(LOCATION_ID),MAX(LOCATION_ID)
                               FROM   ( SELECT location_id, NTILE(:num_instances) OVER (ORDER BY location_id) worker
                                        FROM   WSH_HR_LOCATIONS_V
                                        WHERE  last_update_date >= nvl(:start_date, last_update_date)
                                        AND    last_update_date < nvl(:end_date, last_update_date+1)
                                      )
                               GROUP BY WORKER'
            BULK COLLECT INTO l_worker_min_tab, l_worker_max_tab
            USING l_num_of_instances, l_start_date, l_end_date;


        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'l_worker_min_tab.count : '||l_worker_min_tab.count||
                                  ' l_worker_max_tab.count : '||l_worker_max_tab.count || ' p_num_of_instances : '||p_num_of_instances ||
                                   ' l_num_of_instances : ' ||l_num_of_instances);
        END IF;

        l_import_start_date := sysdate;

        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'l_import_start_date', l_import_start_date);
        END IF;

        IF l_worker_min_tab.count <>0 and p_num_of_instances > 0 THEN

            FOR i in 1..l_worker_min_tab.count
             LOOP

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Value of i : '|| i ||' l_worker_min_tab(i) : '||l_worker_min_tab(i)||
                                                  ' l_worker_max_tab(i) : '||l_worker_max_tab(i));
                END IF;

                l_new_request_id :=  FND_REQUEST.SUBMIT_REQUEST(
                                      application   =>  'WSH',
                                      program       =>  'WSHMAPCD',
                                      description   =>  'Import Shipping Locations - Child '||to_char(i),
                                      start_time    =>   NULL,
                                      sub_request   =>   TRUE,
                                      argument1     =>   p_location_type,
                                      argument2     =>   p_map_regions,
                                      argument3     =>   l_worker_min_tab(i),
                                      argument4     =>   l_worker_max_tab(i),
                                      argument5     =>   p_start_date,
                                      argument6     =>   p_end_date,
                                      argument7     =>   p_create_facilities);

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name, 'Child request ID ', l_new_request_id);
                  END IF;

                  IF l_new_request_id = 0 THEN
                     WSH_UTIL_CORE.printmsg('Error Submitting concurrent request for worker : '||i);
                     l_completion_status := 'ERROR';
                  END IF;

              END LOOP;

              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Setting Parent Request to pause');
              END IF;

              FND_CONC_GLOBAL.Set_Req_Globals ( Conc_Status => 'PAUSED', Request_Data => to_char(1)||':'|| to_char(l_import_start_date, 'YYYY/MM/DD HH24:MI:SS'));

        ELSIF l_worker_min_tab.count <>0 AND nvl(p_num_of_instances,0) = 0 THEN

            IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Map_Locations_Child_Program',WSH_DEBUG_SV.C_PROC_LEVEL);
                 WSH_DEBUG_SV.log(l_module_name,'l_worker_min_tab(1): ', l_worker_min_tab(1));
                 WSH_DEBUG_SV.log(l_module_name,'l_worker_max_tab(1): ', l_worker_max_tab(1));
            END IF;

            Map_Locations_Child_Program (
                  p_errbuf            => l_errbuf,
                  p_retcode           => l_retcode,
                  p_location_type     => p_location_type,
                  p_map_regions       => p_map_regions,
                  p_from_location     => l_worker_min_tab(1),
                  p_to_location       => l_worker_max_tab(1),
                  p_start_date        => p_start_date,
                  p_end_date          => p_end_date,
                  p_create_facilities => p_create_facilities );

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Return Code from Map_Locations_Child_Program : '||l_retcode);
            END IF;

            IF l_retcode = '2' THEN
               l_completion_status := 'ERROR';
            ELSIF l_retcode = '1' THEN
               l_completion_status := 'WARNING';
            END IF;

            IF p_map_regions = 'Y' THEN

                WSH_REGIONS_SEARCH_PKG.Process_All_Locations(
                       p_dummy1             => NULL,
                       p_dummy2             => NULL,
                       p_mode               => l_mode,
                       p_insert_flag        => l_insert_flag,
                       p_location_type      => p_location_type,
                       p_start_date         => p_start_date,
                       p_end_date           => p_end_date,
                       p_num_of_instances   => p_num_of_instances
                       );
            END IF;

        END IF;

    ELSIF l_req_data = '1'  and p_map_regions = 'Y' THEN

        WSH_REGIONS_SEARCH_PKG.Process_All_Locations(
                                   p_dummy1             => NULL,
                                   p_dummy2             => NULL,
                                   p_mode               => l_mode,
                                   p_insert_flag        => l_insert_flag,
                                   p_location_type      => p_location_type,
                                   p_start_date         => p_start_date,
                                   p_end_date           => p_end_date,
                                   p_num_of_instances   => p_num_of_instances
                                   );
    ELSE
        WSH_REGIONS_SEARCH_PKG.get_child_requests_status(x_completion_status =>  l_completion_status);

        l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
    END IF;

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'ERRBUF',p_errbuf);
       WSH_DEBUG_SV.log(l_module_name,'RETCODE',p_retcode);
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;

 -- end Bug 4740786
 EXCEPTION

     WHEN No_Data_Found THEN

       WSH_UTIL_CORE.printmsg('No matching records for the entered parameters');
       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
       END IF;

     WHEN others THEN
       l_sqlcode := SQLCODE;
       l_sqlerr  := SQLERRM;

       WSH_UTIL_CORE.printmsg('Exception occurred in Map_Locations Program');
       WSH_UTIL_CORE.printmsg('SQLCODE : ' || l_sqlcode);
       WSH_UTIL_CORE.printmsg('SQLERRM : '  || l_sqlerr);

       l_completion_status := 'ERROR';
       p_errbuf := 'Exception occurred in Map_Locations Program';
       p_retcode := '2';

       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;

END Map_Locations;

/*===========================================================================+
| PROCEDURE                                                                 |
|              Map_Location_Child_Program                                   |
|                                                                           |
| DESCRIPTION                                                               |
|              This is just a wrapper routine and call the main processing  |
|              API Mapping_Regions_Main. This procedure is also by the      |
|              TCA Callout API Rule_Location.                               |
|                                                                           |
+===========================================================================*/

-- Will the conc program fail because of the new parameter
PROCEDURE Map_Locations_Child_Program (
    p_errbuf              OUT NOCOPY   VARCHAR2,
    p_retcode             OUT NOCOPY   NUMBER,
    p_location_type       IN   VARCHAR2,
    p_map_regions         IN   VARCHAR2,
    p_from_location       IN   NUMBER,
    p_to_location         IN   NUMBER,
    p_start_date          IN   VARCHAR2,
    p_end_date            IN   VARCHAR2,
    p_create_facilities   IN   VARCHAR2 default NULL) IS

l_return_status      VARCHAR2(20);
l_sqlcode            NUMBER;
l_sqlerr             VARCHAR2(2000);
l_completion_status  VARCHAR2(30);
l_temp               BOOLEAN;


l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAP_LOCATIONS_CHILD_PROGRAM';

BEGIN


    WSH_UTIL_CORE.Enable_Concurrent_Log_Print;

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_TYPE',P_LOCATION_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_MAP_REGIONS',P_MAP_REGIONS);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_LOCATION',P_FROM_LOCATION);
       WSH_DEBUG_SV.log(l_module_name,'P_TO_LOCATION',P_TO_LOCATION);
       WSH_DEBUG_SV.log(l_module_name,'P_START_DATE',P_START_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_END_DATE',P_END_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_CREATE_FACILITIES',P_CREATE_FACILITIES);
    END IF;

    l_completion_status := 'NORMAL';

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LOCATIONS_PKG.Process_Locations',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    WSH_LOCATIONS_PKG.Process_Locations (
            p_location_type       => p_location_type,
            p_from_location       => p_from_location,
            p_to_location         => p_to_location,
            p_start_date          => p_start_date,
            p_end_date            => p_end_date,
            p_create_facilities   => p_create_facilities,
            x_return_status       => l_return_status,
            x_sqlcode             => l_sqlcode,
            x_sqlerr              => l_sqlerr);

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_LOCATIONS_PKG.Process_Locations : '|| l_return_status);
    END IF;


     IF l_return_status NOT IN
        (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING) THEN

         WSH_UTIL_CORE.printmsg('Failed in Procedure Process_Locations');
         WSH_UTIL_CORE.printmsg(l_sqlcode);
         WSH_UTIL_CORE.printmsg(l_sqlerr);
         l_completion_status := 'ERROR';
     END IF;

    l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');

    IF l_completion_status = 'NORMAL' THEN
       p_errbuf := 'Map_Locations_Child_Program completed successfully';
       p_retcode := '0';
    ELSIF l_completion_status = 'WARNING' THEN
       p_errbuf := 'Map_Locations_Child_Program is completed with warning';
       p_retcode := '1';
    ELSIF l_completion_status = 'ERROR' THEN
       p_errbuf := 'Map_Locations_Child_Program is completed with error';
       p_retcode := '2';
    END IF;


IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'ERRBUF',p_errbuf);
       WSH_DEBUG_SV.log(l_module_name,'RETCODE',p_retcode);
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION
   WHEN others THEN
     l_completion_status := 'ERROR';
     l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
     p_errbuf := 'Exception occurred in Map_Locations_Child_Program';
     p_retcode := '2';

     l_sqlcode := SQLCODE;
     l_sqlerr  := SQLERRM;
     WSH_UTIL_CORE.printmsg('Exception occurred in Map_Locations_Child_Program');
     WSH_UTIL_CORE.printmsg('SQLCODE : ' || l_sqlcode);
     WSH_UTIL_CORE.printmsg('SQLERRM : '  || l_sqlerr);
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END Map_Locations_Child_Program;

-- Bug 4722963

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Insert_records                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This API bulk inserts data into WSH_REGION_LOCATIONS table   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Insert_records
(
     x_return_status        OUT NOCOPY VARCHAR2
 ) IS

 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_RECORDS';
 l_exception_msg_count NUMBER;
 l_debug_on BOOLEAN;

BEGIN

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      wsh_debug_sv.logmsg(l_module_name, 'before bulk insert:' ||to_char(sysdate, 'dd/mm/yyyy hh:mi:ss'));
      wsh_debug_sv.logmsg(l_module_name, 'Number of records to be bulk inserted '||l_location_id_tab.count);
 END IF;

 FORALL i IN l_location_id_tab.first .. l_location_id_tab.last

    INSERT INTO WSH_REGION_LOCATIONS(
          region_id,
          location_id,
          exception_type,
          region_type,
          parent_region_flag,
          location_source,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login )
       values (
          l_region_id_tab(i),
          l_location_id_tab(i),
          l_exceptions_tab(i),
          l_region_type_tab(i),
          l_parent_region_tab(i),
          l_location_source_tab(i),
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id
          );


  IF l_debug_on THEN
    wsh_debug_sv.logmsg(l_module_name, 'after bulk insert:' ||to_char(sysdate,'dd/mm/yyyy hh:mi:ss'));
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
EXCEPTION

    WHEN Others THEN

       WSH_UTIL_CORE.printmsg(' Error in Insert_records : ' || sqlerrm);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
       END IF;

END Insert_records;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Delete_records                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This API bulk delete records from WSH_REGION_LOCATIONS table |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Delete_records
(
    x_return_status        OUT NOCOPY VARCHAR2
) IS

 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_RECORDS';
 l_exception_msg_count NUMBER;
 l_debug_on BOOLEAN;

 BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
	  wsh_debug_sv.log(l_module_name, 'Number of records to be bulk deleted', l_del_loc_id_tab.count);
      wsh_debug_sv.logmsg(l_module_name, 'before bulk delete:' ||to_char(sysdate, 'dd/mm/yyyy hh:mi:ss'));
 END IF;


 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 FORALL i IN l_del_loc_id_tab.first .. l_del_loc_id_tab.last

    DELETE from wsh_region_locations where location_id = l_del_loc_id_tab(i)
    and ( ( region_id in (select wrt.region_id from wsh_regions_tl wrt,
                             wsh_regions wr
                             where wrt.region_id = wr.region_id
                             and wrt.language = USERENV('LANG'))
            ) OR region_id IS NULL);


 IF l_debug_on THEN
    wsh_debug_sv.logmsg(l_module_name, 'after bulk delete:' ||to_char(sysdate,'dd/mm/yyyy hh:mi:ss'));
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

 EXCEPTION
    WHEN Others THEN
       WSH_UTIL_CORE.printmsg(' Error in  Delete_records: ' || sqlerrm);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;
END Delete_records;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Update_records                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This API updates records in WSH_REGION_LOCATIONS table       |
 |                                                                           |
 +===========================================================================*/


PROCEDURE Update_records
(
    x_return_status        OUT NOCOPY VARCHAR2
) IS

 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_RECORDS';

 l_return_status        VARCHAR2(20);
 l_exception_msg_count  NUMBER;
 l_exception_msg_data   VARCHAR2(15000);
 l_dummy_exception_id   NUMBER;
 i                      NUMBER;
 l_debug_on BOOLEAN;

 BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      wsh_debug_sv.logmsg(l_module_name, 'before bulk update:' ||to_char(sysdate, 'dd/mm/yyyy hh:mi:ss'));
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 FORALL cnt IN l_upd_loc_id_tab.first .. l_upd_loc_id_tab.last

    UPDATE wsh_region_locations
        SET    exception_type = 'Y'
        WHERE  location_id = l_upd_loc_id_tab(cnt)
        and region_id in (select wrt.region_id from wsh_regions_tl wrt,
                             wsh_regions wr
                             where wrt.region_id = wr.region_id
                             and wrt.language = USERENV('LANG'));

 IF l_debug_on THEN
    wsh_debug_sv.logmsg(l_module_name, 'after bulk update:' ||to_char(sysdate,'dd/mm/yyyy hh:mi:ss'));
 END IF;

 i := l_upd_loc_excp_tab.first;
 IF i IS NOT NULL THEN
    LOOP


       -- Vijay 08/25: added call to put exception WSH_LOCATION_REGIONS_2_ERR
       --Bug 4893034 Log exception for Active Locations only

       l_dummy_exception_id := NULL;

       IF l_upd_loc_excp_tab(i) THEN
            wsh_xc_util.log_exception(
                         p_api_version             => 1.0,
                         x_return_status           => l_return_status,
                         x_msg_count               => l_exception_msg_count,
                         x_msg_data                => l_exception_msg_data,
                         x_exception_id            => l_dummy_exception_id ,
                         p_logged_at_location_id   => l_upd_loc_id_tab(i),
                         p_exception_location_id   => l_upd_loc_id_tab(i),
                         p_logging_entity          => 'SHIPPER',
                         p_logging_entity_id       => FND_GLOBAL.USER_ID,
                         p_exception_name          => 'WSH_LOCATION_REGIONS_2',
                         p_message                 => 'WSH_LOCATION_REGIONS_2_ERR'
                         );
        END IF;

        EXIT WHEN i = l_upd_loc_excp_tab.LAST;
        i := l_upd_loc_excp_tab.NEXT(i);

    END LOOP;
  END IF;

IF l_debug_on THEN
    wsh_debug_sv.logmsg(l_module_name, 'after log exceptions:' ||to_char(sysdate,'dd/mm/yyyy hh:mi:ss'));
    WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
    WHEN Others THEN
       WSH_UTIL_CORE.printmsg(' Error in Update_records: ' || sqlerrm);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;

END Update_records;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Process_records                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This API inserts/updates/deletes records in                  |
 |              WSH_REGION_LOCATIONS table.                                  |
 |              Calls APIs Insert_records/Update_records and delete_records  |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Process_records
(
    x_return_status        OUT NOCOPY VARCHAR2
) IS

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_RECORDS';
l_return_status VARCHAR2(20);
delete_failed   EXCEPTION;
insert_failed   EXCEPTION;
update_failed   EXCEPTION;

l_debug_on BOOLEAN;

BEGIN
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
    END IF;

	IF l_debug_on THEN
	  wsh_debug_sv.log(l_module_name, 'l_location_id_tab.COUNT', l_location_id_tab.COUNT);
	  wsh_debug_sv.log(l_module_name, 'l_del_loc_id_tab.COUNT', l_del_loc_id_tab.COUNT);
	  WSH_DEBUG_SV.log(l_module_name, 'l_upd_loc_id_tab.COUNT', l_upd_loc_id_tab.COUNT);

	  wsh_debug_sv.logmsg(l_module_name, 'before process_records:' ||to_char(sysdate, 'dd/mm/yyyy hh:mi:ss'));
	END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    SAVEPOINT before_db_update;

    Delete_records(x_return_status    => l_return_status);
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        RAISE delete_failed;
    END IF;

    Insert_Records(x_return_status    => l_return_status);
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        RAISE insert_failed;
    END IF;

    Update_Records(x_return_status    => l_return_status);
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        RAISE update_failed;
    END IF;

    l_location_id_tab.delete;
    l_region_id_tab.delete;
    l_region_type_tab.delete;
    l_exceptions_tab.delete;
    l_location_source_tab.delete;
    l_parent_region_tab.delete;
    l_del_loc_id_tab.delete;
    l_upd_loc_id_tab.delete;
    l_upd_loc_excp_tab.delete;

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION

 WHEN delete_failed THEN
    WSH_UTIL_CORE.printmsg(' Error in Process_records - delete: ' || sqlerrm);
    ROLLBACK to before_db_update;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
 WHEN insert_failed THEN
    WSH_UTIL_CORE.printmsg(' Error in Process_records - insert: ' || sqlerrm);
    ROLLBACK to before_db_update;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

 WHEN update_failed THEN
    WSH_UTIL_CORE.printmsg(' Error in Process_records - update: ' || sqlerrm);
    ROLLBACK to before_db_update;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
 WHEN Others THEN
       WSH_UTIL_CORE.printmsg('Error in Process_records : ' || sqlerrm);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
END;

-- Bug 4722963 end

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Mapping_Regions_Main                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This API selects all the location data into PL/SQL table     |
 |              types and calls the Map_Location_To_Region by passing the    |
 |              location information                                         |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Mapping_Regions_Main (
    p_location_type    IN   VARCHAR2,
    p_from_location    IN   NUMBER,
    p_to_location      IN   NUMBER,
    p_start_date       IN   VARCHAR2,
    p_end_date         IN   VARCHAR2,
    p_insert_flag      IN   BOOLEAN default TRUE, -- Bug 4722963
    x_return_status    OUT NOCOPY   VARCHAR2,
    x_sqlcode          OUT NOCOPY  NUMBER,
    x_sqlerr           out NOCOPY  varchar2) IS


l_return_status VARCHAR2(20);
l_sqlcode       NUMBER;
l_sqlerr        VARCHAR2(2000);
l_current_rows  NUMBER;
l_remaining_rows NUMBER;
l_previous_rows  NUMBER;
l_batchsize      NUMBER := 500;
l_location_source  VARCHAR2(4);
l_start_date            DATE;
l_end_date              DATE;

l_loc_tab          TableNumbers; -- Location ID Table Type
l_state_tab        TableVarchar; -- State Table Type
l_city_tab         TableVarchar; -- City Table Type
l_postal_code_tab  TableVarchar; -- Postal Code Table Type
l_ter_code_tab     TableVarchar; -- Territory Code Table Type
l_ter_sn_tab       TableVarchar; -- Territory Short Name Table Type
l_loc_source_tab   TableVarchar; -- Location Source Table Type
l_inactive_date_tab TableDate;   -- Inactive Date Table Type

-- Cursor Declarations

CURSOR Get_External_Locations (l_start_date DATE, l_end_date DATE) IS
  SELECT
    l.wsh_location_id,
    t.territory_short_name,
    t.territory_code,
    nvl(l.state, l.province) state,
    l.city city,
    l.postal_code,
    l.inactive_date
  FROM
    wsh_locations l,
    fnd_territories_tl t
  WHERE
    t.territory_code = l.country and
    t.language = userenv('LANG') and
    l.wsh_location_id between p_from_location and p_to_location and
    l.location_source_code = 'HZ' and
    l.last_update_date >= nvl(l_start_date, l.last_update_date) and
    l.last_update_date < nvl(l_end_date, l.last_update_date+1)
    order by t.territory_code;

CURSOR Get_Internal_Locations (l_start_date DATE, l_end_date DATE) IS
  SELECT
    l.wsh_location_id,
    t.territory_short_name,
    t.territory_code,
    nvl(l.state, l.province) state,
    l.city city,
    l.postal_code,
    l.inactive_date
  FROM
    wsh_locations l,
    fnd_territories_tl t
  WHERE
    t.territory_code = l.country and
    t.language = userenv('LANG') and
    l.wsh_location_id between p_from_location and p_to_location and
    l.location_source_code = 'HR' and
    l.last_update_date >= nvl(l_start_date, l.last_update_date) and
    l.last_update_date < nvl(l_end_date, l.last_update_date+1)
    order by t.territory_code;

CURSOR Get_Both_Locations (l_start_date DATE, l_end_date DATE) IS
  SELECT
    l.wsh_location_id,
    t.territory_short_name,
    t.territory_code,
    nvl(l.state, l.province) state,
    l.city city,
    l.postal_code,
    l.location_source_code source,
    l.inactive_date
  FROM
    wsh_locations l,
    fnd_territories_tl t
  WHERE
    t.territory_code = l.country and
    t.language = userenv('LANG') and
    l.wsh_location_id between p_from_location and p_to_location and
    l.last_update_date >= nvl(l_start_date, l.last_update_date) and
    l.last_update_date < nvl(l_end_date, l.last_update_date+1)
    order by t.territory_code;


  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAPPING_REGIONS_MAIN';

BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_TYPE',P_LOCATION_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_LOCATION',P_FROM_LOCATION);
       WSH_DEBUG_SV.log(l_module_name,'P_TO_LOCATION',P_TO_LOCATION);
       WSH_DEBUG_SV.log(l_module_name,'P_START_DATE',P_START_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_END_DATE',P_END_DATE);
   END IF;

   l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   ----------------------------------------------------------------------
   -- Depending on the location type, fetch all the data into respective
   -- PL/SQL tables. The call Map_Location_To_Region to map the data.
   ----------------------------------------------------------------------

    l_start_date := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
    l_end_date   := to_date(p_end_date,'YYYY/MM/DD HH24:MI:SS') +1;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_START_DATE',l_START_DATE);
        WSH_DEBUG_SV.log(l_module_name,'l_END_DATE',l_END_DATE);
    END IF;

   l_previous_rows := 0;

   IF p_location_type = 'EXTERNAL'  THEN

      l_location_source := 'HZ';

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'Location Type is External');
      END IF;

       OPEN Get_External_Locations(l_start_date, l_end_date);
       LOOP
          FETCH Get_External_Locations  BULK COLLECT INTO
               l_loc_tab,
               l_ter_sn_tab,
               l_ter_code_tab,
               l_state_tab,
               l_city_tab,
               l_postal_code_tab,
               l_inactive_date_tab
          LIMIT l_Batchsize;

          l_current_rows   := Get_External_Locations%rowcount ;
          l_remaining_rows := l_current_rows - l_previous_rows;

          IF (l_remaining_rows <= 0) then
              EXIT;
          END IF;

          l_previous_rows := l_current_rows ;

          -----------------------------------------------------
          -- Loop through the entire PL/SQL table and call the
          -- Map_Location_To_Region by passing corresponding
          -- parameters.
          -----------------------------------------------------

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,  'l_ter_sn_tab.COUNT', l_ter_sn_tab.COUNT);
             END IF;

             IF l_ter_sn_tab.COUNT > 0 THEN

                FOR i in l_ter_sn_tab.FIRST..l_ter_sn_tab.LAST
                  LOOP

                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Processing Location id : '|| l_loc_tab(i));
                         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Map_Location_To_Region',WSH_DEBUG_SV.C_PROC_LEVEL);
                      END IF;

                      Map_Location_To_Region (
                         p_country          =>  l_ter_sn_tab(i),
                         p_country_code     =>  l_ter_code_tab(i),
                         p_state            =>  l_state_tab(i),
                         p_city             =>  l_city_tab(i),
                         p_postal_code      =>  l_postal_code_tab(i),
                         p_location_id      =>  l_loc_tab(i),
                         p_inactive_date    =>  l_inactive_date_tab(i),
                         p_location_source  =>  l_location_source,
                         p_insert_flag      =>  p_insert_flag,          -- Bug 4722963
                         x_return_status    =>  l_return_status,
                         x_sqlcode          =>  l_sqlcode,
                         x_sqlerr           =>  l_sqlerr );

                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from Map_Location_To_Region : '|| l_return_status);
                     END IF;

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Failed in API Map_Location_To_Region for location : '||l_loc_tab(i));
                            WSH_DEBUG_SV.logmsg(l_module_name,l_sqlcode);
                            WSH_DEBUG_SV.logmsg(l_module_name,l_sqlerr);
                         ELSE
                            WSH_UTIL_CORE.printmsg('Failed in API Map_Location_To_Region for location : '||l_loc_tab(i));
                            WSH_UTIL_CORE.printmsg(l_sqlcode);
                            WSH_UTIL_CORE.printmsg(l_sqlerr);
                         END IF;

                         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                     END IF;

                     --  WSH_UTIL_CORE.println('After call to Map_Location_To_Region');
                     --  WSH_UTIL_CORE.println('Processing Next Location');
                     --  WSH_UTIL_CORE.println('*******************************************');
                  END LOOP;

                  -- Bug 4722963

                  IF NOT p_insert_flag AND
                    (l_location_id_tab.COUNT > 0 OR l_del_loc_id_tab.COUNT > 0 OR l_upd_loc_id_tab.COUNT > 0 )
                  THEN

                    Process_Records(x_return_status    => l_return_status);

                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    END IF;

                  END IF;
                  -- Bug 4722963 end
             END IF;

             EXIT WHEN Get_External_Locations%NOTFOUND;
       END LOOP;

       IF Get_External_Locations%ISOPEN THEN
          CLOSE Get_External_Locations;
       END IF;

   ELSIF p_location_type = 'INTERNAL' then

       l_location_source := 'HR';

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'Location Type is Internal');
       END IF;
       OPEN Get_Internal_Locations(l_start_date, l_end_date);
       LOOP
          FETCH Get_Internal_Locations BULK COLLECT INTO
               l_loc_tab,
               l_ter_sn_tab,
               l_ter_code_tab,
               l_state_tab,
               l_city_tab,
               l_postal_code_tab,
               l_inactive_date_tab
          LIMIT l_Batchsize;

          l_current_rows   := Get_Internal_Locations%rowcount ;
          l_remaining_rows := l_current_rows - l_previous_rows;

            IF (l_remaining_rows <= 0) then
              EXIT;
            END IF;

            l_previous_rows := l_current_rows ;

          -----------------------------------------------------
          -- Loop through the entire PL/SQL table and call the
          -- Map_Location_To_Region by passing corresponding
          -- parameters.
          -----------------------------------------------------

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,  'l_ter_sn_tab.COUNT', l_ter_sn_tab.COUNT);
             END IF;

             IF l_ter_sn_tab.COUNT > 0 THEN

                FOR i in l_ter_sn_tab.FIRST..l_ter_sn_tab.LAST
                  LOOP

                      IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Processing Location id : '|| l_loc_tab(i));
                         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Map_Location_To_Region',WSH_DEBUG_SV.C_PROC_LEVEL);
                      END IF;

                      Map_Location_To_Region (
                         p_country          =>  l_ter_sn_tab(i),
                         p_country_code     =>  l_ter_code_tab(i),
                         p_state            =>  l_state_tab(i),
                         p_city             =>  l_city_tab(i),
                         p_postal_code      =>  l_postal_code_tab(i),
                         p_location_id      =>  l_loc_tab(i),
                         p_inactive_date    =>  l_inactive_date_tab(i),
                         p_location_source  =>  l_location_source,
                         p_insert_flag      =>  p_insert_flag,
                         x_return_status    =>  l_return_status,
                         x_sqlcode          =>  l_sqlcode,
                         x_sqlerr           =>  l_sqlerr );

                      IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from Map_Location_To_Region : '|| l_return_status);
                      END IF;

                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Failed in API Map_Location_To_Region for location : '||l_loc_tab(i));
                            WSH_DEBUG_SV.logmsg(l_module_name,l_sqlcode);
                            WSH_DEBUG_SV.logmsg(l_module_name,l_sqlerr);
                         ELSE
                            WSH_UTIL_CORE.printmsg('Failed in API Map_Location_To_Region for location : '||l_loc_tab(i));
                            WSH_UTIL_CORE.printmsg(l_sqlcode);
                            WSH_UTIL_CORE.printmsg(l_sqlerr);
                         END IF;
                         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      END IF;

                     --  WSH_UTIL_CORE.println('After call to Map_Location_To_Region');
                     --  WSH_UTIL_CORE.println('Processing Next Location');
                     --  WSH_UTIL_CORE.println('*******************************************');
                  END LOOP;

                  -- Bug 4722963

                  IF NOT p_insert_flag AND
                    (l_location_id_tab.COUNT > 0 OR l_del_loc_id_tab.COUNT > 0 OR l_upd_loc_id_tab.COUNT > 0 )
                  THEN
                      Process_Records(x_return_status    => l_return_status);
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      END IF;
                  END IF;
                  -- Bug 4722963 end
             END IF;

             EXIT WHEN Get_Internal_Locations%NOTFOUND;
       END LOOP;

       IF Get_Internal_Locations%ISOPEN THEN
          CLOSE Get_Internal_Locations;
       END IF;

    ELSIF p_location_type = 'BOTH' THEN

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'Location Type is Both');
       END IF;

       OPEN Get_Both_Locations(l_start_date, l_end_date);
       LOOP
          FETCH Get_Both_Locations BULK COLLECT INTO
               l_loc_tab,
               l_ter_sn_tab,
               l_ter_code_tab,
               l_state_tab,
               l_city_tab,
               l_postal_code_tab,
               l_loc_source_tab,
               l_inactive_date_tab
          LIMIT l_Batchsize;

          l_current_rows   := Get_Both_Locations%rowcount ;
          l_remaining_rows := l_current_rows - l_previous_rows;

            IF (l_remaining_rows <= 0) then
              EXIT;
            END IF;

          l_previous_rows := l_current_rows ;

          -----------------------------------------------------
          -- Loop through the entire PL/SQL table and call the
          -- Map_Location_To_Region by passing corresponding
          -- parameters.
          -----------------------------------------------------
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,  'l_ter_sn_tab.COUNT', l_ter_sn_tab.COUNT);
             END IF;

             IF l_ter_sn_tab.COUNT > 0 THEN

                FOR i in l_ter_sn_tab.FIRST..l_ter_sn_tab.LAST
                  LOOP

                      IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Processing Location id : '|| l_loc_tab(i));
                         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Map_Location_To_Region',WSH_DEBUG_SV.C_PROC_LEVEL);
                      END IF;
                      Map_Location_To_Region (
                         p_country          =>  l_ter_sn_tab(i),
                         p_country_code     =>  l_ter_code_tab(i),
                         p_state            =>  l_state_tab(i),
                         p_city             =>  l_city_tab(i),
                         p_postal_code      =>  l_postal_code_tab(i),
                         p_location_id      =>  l_loc_tab(i),
                         p_location_source  =>  l_loc_source_tab(i),
                         p_inactive_date    =>  l_inactive_date_tab(i),
                         p_insert_flag      =>  p_insert_flag,
                         x_return_status    =>  l_return_status,
                         x_sqlcode          =>  l_sqlcode,
                         x_sqlerr           =>  l_sqlerr );


                     IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from Map_Location_To_Region : '|| l_return_status);
                     END IF;

                     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Failed in API Map_Location_To_Region for location : '||l_loc_tab(i));
                            WSH_DEBUG_SV.logmsg(l_module_name,l_sqlcode);
                            WSH_DEBUG_SV.logmsg(l_module_name,l_sqlerr);
                         ELSE
                            WSH_UTIL_CORE.printmsg('Failed in API Map_Location_To_Region for location : '||l_loc_tab(i));
                            WSH_UTIL_CORE.printmsg(l_sqlcode);
                            WSH_UTIL_CORE.printmsg(l_sqlerr);
                         END IF;

                         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                     END IF;

                    --   WSH_UTIL_CORE.println('After call to Map_Location_To_Region');
                    --   WSH_UTIL_CORE.println('Processing Next Location');
                    --   WSH_UTIL_CORE.println('*******************************************');
                  END LOOP;

                  -- Bug 4722963
                  IF NOT p_insert_flag AND
                    (l_location_id_tab.COUNT > 0 OR l_del_loc_id_tab.COUNT > 0 OR l_upd_loc_id_tab.COUNT > 0 )
                  THEN
                      Process_Records(x_return_status    => l_return_status);
                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      END IF;
                  END IF;
                  -- Bug 4722963 end
             END IF;

             EXIT WHEN Get_Both_Locations%NOTFOUND;
       END LOOP;

       IF Get_Both_Locations%ISOPEN THEN
          CLOSE Get_Both_Locations;
       END IF;
    END IF;
    x_return_status := l_return_status;

    IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     --R12.1.1 Standalone Project - Start
     --Commit the data only if its Normal Mode
     IF G_MODE = 'STANDALONE' THEN
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Code executed in standalone mode so not commiting the data');
        END IF;
        --
     ELSE
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Code executed in normal mode, so commit the data');
        END IF;
        --
        COMMIT;
     END IF;
     --R12.1.1 Standalone Project - End
    END IF;

    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION

   WHEN No_Data_Found THEN

   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'No records found for the entered parameters');
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
    ELSE
       WSH_UTIL_CORE.printmsg('No records found for the entered parameters');
    END IF;

   WHEN Others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    x_sqlcode := SQLCODE;
    x_sqlerr := SQLERRM;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'When Others of Procedure Mapping_Regions_Main ');
       WSH_DEBUG_SV.logmsg(l_module_name,x_sqlcode);
       WSH_DEBUG_SV.logmsg(l_module_name,x_sqlerr);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    ELSE
       WSH_UTIL_CORE.printmsg('When Others of Procedure Mapping_Regions_Main ');
       WSH_UTIL_CORE.printmsg(x_sqlcode);
       WSH_UTIL_CORE.printmsg(x_sqlerr);
    END IF;

END Mapping_Regions_Main;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Map_Location_To_Region                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This API does the main mapping process. It calls the API     |
 |              WSH_REGIONS_SEARCH_PKG.Get_Region_Info which inturn returns  |
 |              the region id. For this particuar region, the parent regions |
 |              are also obtained and all these are inserted into the        |
 |              intersection table.                                          |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Map_Location_To_Region (
       p_country            IN   VARCHAR2,
       p_country_code       IN   VARCHAR2,
       p_state              IN   VARCHAR2,
       p_city               IN   VARCHAR2,
       p_postal_code        IN   VARCHAR2,
       p_location_id        IN   NUMBER,
       p_location_source    IN   VARCHAR2,
       p_inactive_date      IN   DATE,
       p_insert_flag        IN   BOOLEAN DEFAULT TRUE,      -- Bug 4722963
       x_return_status      OUT NOCOPY   VARCHAR2,
       x_sqlcode            OUT NOCOPY   NUMBER,
       x_sqlerr             OUT NOCOPY   VARCHAR2) IS


l_region_info        WSH_REGIONS_SEARCH_PKG.region_rec;
l_region_type        NUMBER := 0;
l_region_id          NUMBER := 0;
l_region_table       WSH_REGIONS_SEARCH_PKG.region_table;
l_country            l_region_info.country%TYPE;
l_return_status      VARCHAR2(10);
Insert_Failed        EXCEPTION;
l_sqlcode            NUMBER;
l_sqlerr             VARCHAR2(2000);
l_region_type_const  NUMBER := 0 ;
l_parent_region      VARCHAR2(1) := 'N';
l_rows_before        NUMBER := 0;
l_rows_after         NUMBER := 0;
l_exists             VARCHAR2(10);
l_location_source    VARCHAR2(4);
l_status             NUMBER := 0;
i                    NUMBER := 0;
j                    NUMBER := 0;
l_log_exception      BOOLEAN := FALSE;

--Variables: Start of fix for bug 5125837
TYPE Reg_Rec_Type IS RECORD (
   REGION_ID           WSH_REGION_LOCATIONS.REGION_ID%TYPE,
   REGION_TYPE         WSH_REGION_LOCATIONS.REGION_TYPE%TYPE,
   EXCEPTION_TYPE      WSH_REGION_LOCATIONS.EXCEPTION_TYPE%TYPE,
   PARENT_REGION_FLAG  WSH_REGION_LOCATIONS.PARENT_REGION_FLAG%TYPE );

TYPE Reg_Tab_Type IS TABLE OF Reg_Rec_Type INDEX BY BINARY_INTEGER;

l_region_detail_tab  Reg_Tab_Type;
l_region_counter     NUMBER;
l_max_counter        NUMBER;
l_insert             BOOLEAN;
--Variables: End of fix for bug 5125837

--Commented below 2 Cursors for bug 5125837
/****

CURSOR Check_Location_Exists(c_location_id IN NUMBER) IS
select 'exists'
from  wsh_region_locations
where location_id = c_location_id;


CURSOR get_loc_region_count (p_location_id NUMBER) IS
SELECT count(*)
FROM wsh_region_locations
WHERE location_id = p_location_id
AND ( ( region_id IN
     (
      SELECT wrt.region_id
      FROM wsh_regions_tl wrt, wsh_regions wr
      WHERE wrt.region_id = wr.region_id
      AND wrt.language = USERENV('LANG'))
      )
      OR region_id IS NULL);
****/

l_exception_msg_count NUMBER;
l_exception_msg_data  VARCHAR2(15000);
l_dummy_exception_id NUMBER;

--
l_debug_on BOOLEAN;
--

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAP_LOCATION_TO_REGION';

BEGIN
  --bug 7158136
  --x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  j := l_location_id_tab.COUNT;
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
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
       WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
       WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
       WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE',P_POSTAL_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_SOURCE',P_LOCATION_SOURCE);
       WSH_DEBUG_SV.log(l_module_name,'P_INACTIVE_DATE',P_INACTIVE_DATE);
  END IF;

  l_region_info.country_code := p_country_code;
  l_region_info.country := p_country;

  IF (p_country_code IS NULL) THEN
        l_country := p_country;
  END IF;

  --Bug 6670302 Removed the restriction on length of state and city
  l_region_info.state := p_state;
  l_region_info.city := p_city;

  l_region_info.postal_code_from := p_postal_code;
  l_region_info.postal_code_to   := p_postal_code;

  IF (p_postal_code IS NOT NULL) THEN
     l_region_type := 3;
  ELSIF (p_city IS NOT NULL) THEN
     l_region_type := 2;
  ELSIF (p_state IS NOT NULL) THEN
     l_region_type := 1;
  END IF;

  -- START affected area
  -- change call to use get_all_region_matches

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REGIONS_SEARCH_PKG.GET_ALL_REGION_MATCHES');
  END IF;

  WSH_REGIONS_SEARCH_PKG.Get_All_Region_Matches(
                  p_country => l_country,
                  p_country_region => l_region_info.country_region,
                  p_state => l_region_info.state,
                  p_city => l_region_info.city,
                  p_postal_code_from => l_region_info.postal_code_from,
                  p_postal_code_to => l_region_info.postal_code_to,
                  p_country_code => l_region_info.country_code,
                  p_country_region_code => l_region_info.country_region_code,
                  p_state_code => l_region_info.state_code,
                  p_city_code => l_region_info.city_code,
                  -- p_lang_code => null,
                  p_lang_code => USERENV('LANG'),
                  p_location_id => null,
                  p_zone_flag => 'N',
                  x_status => l_status,
                  x_regions => l_region_table);

  IF l_status = 1 THEN

   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'get_all_region_matches could not find matching regions for location : ' || p_location_id);
   END IF;

  END IF;

  -- END affected area

  --Commented for bug 5125837
/*
  OPEN Check_Location_Exists(p_location_id);
  FETCH Check_Location_Exists INTO l_exists;
  CLOSE Check_Location_Exists;
*/

  --Added for bug 5125837
  l_exists := null;
  BEGIN
    select region_id, region_type, exception_type, parent_region_flag
    BULK COLLECT INTO l_region_detail_tab
    from   wsh_region_locations
    where  location_id = p_location_id
    and  ( ( region_id in
             ( select wrt.region_id
                from  wsh_regions_tl wrt,
                      wsh_regions wr
                where wrt.region_id = wr.region_id
                and   wrt.language  = USERENV('LANG') )
        ) OR region_id IS NULL )
    order by region_type desc;

    IF l_region_detail_tab.COUNT > 0 THEN
      l_exists := 'Y';
    END IF;

  EXCEPTION
    WHEN no_data_found THEN
      l_exists := null;
  END;

  l_rows_before := l_region_detail_tab.COUNT;
  --End bug 5125837

  SAVEPOINT WSH_LOCATION_EXISTS;

  ---------------------------------------------------------------
  -- If a region is existing already, delete the records so that
  -- fresh mappings are inserted. Savepoint is issued before
  -- doing this.
  ---------------------------------------------------------------

  --Added for bug 5125837
  l_region_counter := 1;

  IF l_debug_on THEN
    --commeted during bug 7158136 as log message is not getting printed
    --WSH_DEBUG_SV.logmsg(l_module_name,'No. of existing mapped regions ',l_rows_before);
    WSH_DEBUG_SV.log(l_module_name,'No. of existing mapped regions ',l_rows_before);
  END IF;

  l_location_source := p_location_source;

  IF p_location_source = 'TCA' THEN
     l_location_source := 'HZ';
  END IF;

  IF l_region_table.COUNT = 0 THEN

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'No matching regions were found for location : ' || p_location_id);
       END IF;

       -----------------------------------------------------------
       -- If no region is found still insert the the location with
       -- region id as null and exception_flag Y
       -----------------------------------------------------------

       --Added for bug 5125837
       IF ( l_region_detail_tab.COUNT = 1 AND
            l_region_detail_tab(1).region_id   is null  AND
            l_region_detail_tab(1).region_type is null  AND
            l_region_detail_tab(1).Parent_Region_Flag = l_parent_region )
       THEN --{

         IF (l_region_detail_tab(1).Exception_Type = 'N') THEN

           UPDATE wsh_region_locations
           SET    exception_type = 'Y',
                  last_updated_by = fnd_global.user_id,
                  last_update_date = sysdate,
                  last_update_login = fnd_global.login_id
           where  location_id = p_location_id;
         END IF;
         --
       ELSE

           -- Bug 4722963 - Added p_insert_flag

           -- If p_insert_flag is false, then insert data into pl/sql tables
           -- to be bulk processed later while doing delete, insert and update operations
           -- This is done for performance reasons since bulk operations are
           -- better in terms of performance

           IF p_insert_flag THEN
                 IF ( l_region_detail_tab.COUNT > 1 ) THEN
                   DELETE from wsh_region_locations where location_id = p_location_id
                   and ( ( region_id in (select wrt.region_id from wsh_regions_tl wrt,
                                     wsh_regions wr
                                     where wrt.region_id = wr.region_id
                                     and wrt.language = USERENV('LANG'))
                       ) OR region_id IS NULL);
                 END IF;
            ELSE
                IF ( l_region_detail_tab.COUNT > 1 ) THEN
                   l_del_loc_id_tab(l_del_loc_id_tab.COUNT) := p_location_id;
                 END IF;
           END IF;

           -----------------------------------------------------------
           -- If no region is found still insert the the location with
           -- region id as null and exception_flag Y
           -----------------------------------------------------------

           IF p_insert_flag THEN
                 Insert_Record (
                   p_location_id     => p_location_id,
                   p_region_id       => NULL,
                   p_region_type     => NULL,
                   p_exception       => 'Y',
                   p_location_source => l_location_source,
                   p_parent_region   => l_parent_region,
                   x_return_status   => l_return_status);

                 IF l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'Insert failed for Null Region for Location : '||p_location_id);
                    ELSE
                       WSH_UTIL_CORE.printmsg('Insert failed for Null Region for Location : '||p_location_id);
                    END IF;
                    RAISE Insert_Failed;
                 END IF;
           ELSE

                 l_location_id_tab(j)       :=  p_location_id;
                 l_region_id_tab(j)         :=  NULL;
                 l_region_type_tab(j)       :=  NULL;
                 l_exceptions_tab(j)        :=  'Y';
                 l_location_source_tab(j)   :=  l_location_source;
                 l_parent_region_tab(j)     :=  l_parent_region;
                 j                          :=  j+1;
           END IF;

       END IF; --}

       l_rows_after := 1; -- Bug 3736133
       --End Bug 5125837

  ELSE

       --Added for bug 5125837
       --Before looping check whether wsh_region_locations table contains only
       --one record where region_id and region_type is NULL.

       IF ( l_region_detail_tab.COUNT = 1 AND
             l_region_detail_tab(1).region_id   is null  AND
             l_region_detail_tab(1).region_type is null )
       THEN
         DELETE from wsh_region_locations where location_id = p_location_id
         and ( ( region_id in (select wrt.region_id from wsh_regions_tl wrt,
                            wsh_regions wr
                            where wrt.region_id = wr.region_id
                            and wrt.language = USERENV('LANG'))
             ) OR region_id IS NULL);
        --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'No of rows deleted : ' || sql%rowcount );
         END IF;
         --
       END IF;

      -----------------------------------------------------------
      --  If some regions are found, then insert everything in the intersection
      --  table. If the region is a parent region, set the parent
      --  flag accordingly.
      -----------------------------------------------------------

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,' Looping over l_region_table for inserting into the intersection table ');
       END IF;

       l_rows_after := 0; -- Bug 3736133

       i := l_region_table.FIRST;
       --Added for bug 5125837
       l_max_counter := l_region_detail_tab.COUNT;
       LOOP  -- 3. region hierarchy

         IF l_region_table(i).region_type >= 0 THEN

          IF l_region_table(i).region_type <> l_region_type THEN
              l_parent_region := 'Y';
          ELSE
              l_parent_region := 'N';
          END IF;

          l_insert := TRUE;
          IF ( l_region_counter <= l_max_counter ) THEN --{
            LOOP --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Start of Loop' );
              END IF;

              IF ( l_region_detail_tab(l_region_counter).region_type = l_region_table(i).region_type) THEN --{

                 IF NOT ( l_region_detail_tab(l_region_counter).region_id = l_region_table(i).region_id AND
                          l_region_detail_tab(l_region_counter).exception_type = 'N' AND
                          l_region_detail_tab(l_region_counter).parent_region_flag = l_parent_region)
                 THEN --{

                   UPDATE wsh_region_locations
                   SET    region_id = l_region_table(i).region_id,
                          exception_type = 'N',
                          parent_region_flag = l_parent_region,
                          last_updated_by = fnd_global.user_id,
                          last_update_date = sysdate,
                          last_update_login = fnd_global.login_id
                   WHERE  location_id = p_location_id
                   AND    region_type = l_region_table(i).region_type;

                 END IF; --}

                l_rows_after := l_rows_after + 1;
                l_region_counter    := l_region_counter + 1;
                l_insert := FALSE;
                EXIT;

              ELSIF (l_region_detail_tab(l_region_counter).region_type < l_region_table(i).region_type) THEN
                l_insert := TRUE;
                EXIT;
              ELSE

                DELETE FROM wsh_region_locations
                WHERE  location_id = p_location_id
                AND    region_type = l_region_detail_tab(l_region_counter).region_type
                AND    region_id in
                     ( select wrt.region_id
                       from   wsh_regions_tl wrt,
                              wsh_regions wr
                       where  wr.region_id = wrt.region_id
                       and    wrt.language = USERENV('LANG') );

                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'No of Regions deleted : ' || sql%rowcount );
                END IF;

              END IF; --}

              l_region_counter    := l_region_counter + 1;
              EXIT WHEN (l_region_counter > l_max_counter);

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'End of Loop' );
              END IF;
            END LOOP; --}
          END IF; --}

          IF l_insert THEN --{

                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling Insert_Record for location id : ' || p_location_id ||
                                                    ' Region Id : '     || l_region_table(i).region_id ||
                                                    ' Region Type : '   || l_region_table(i).region_type ||
                                                    ' Parent Region : ' || l_parent_region);
                END IF;
                IF p_insert_flag THEN
                    Insert_Record (
                           p_location_id     => p_location_id,
                           p_region_id       => l_region_table(i).region_id,
                           p_region_type     => l_region_table(i).region_type,
                           p_exception       => 'N',
                           p_location_source => l_location_source,
                           p_parent_region   => l_parent_region,
                           x_return_status   => l_return_status);

                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'After calling Insert_Record for location id :' || p_location_id);
                    END IF;

                    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Insert failed for Region '||l_region_table(i).region_id||' for Location : '||p_location_id);
                       ELSE
                          WSH_UTIL_CORE.printmsg('Insert failed for Region '||l_region_table(i).region_id||' for Location : '||p_location_id);
                       END IF;
                       RAISE Insert_Failed;
                    END IF;
                ELSE
                     l_location_id_tab(j)       :=  p_location_id;
                     l_region_id_tab(j)         :=  l_region_table(i).region_id;
                     l_region_type_tab(j)       :=  l_region_table(i).region_type;
                     l_exceptions_tab(j)        :=  'N';
                     l_location_source_tab(j)   :=  l_location_source;
                     l_parent_region_tab(j)     :=  l_parent_region;
                     j                          :=  j+1;
                END IF;

                l_rows_after := l_rows_after + 1; -- Bug 3736133

            END IF; --}
       END IF;

       EXIT WHEN i = l_region_table.LAST;
       i := l_region_table.NEXT(i);

   END LOOP;   --  4. region hierarchy

  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'No. of mapped regions after deletion and reinsert ', l_rows_after);
  END IF;

  --------------------------------------------------------
  --  If the number of locations that was matching before
  --  is less than now or no match is found, update the exception flag
  --  to 'Y'
  --------------------------------------------------------

  IF (l_rows_after < l_rows_before AND l_rows_before > 0) OR l_region_table.COUNT = 0 THEN

    -- There is a possibility that exception flags are updated for mappings
    -- in one language, but they are visible in the UI
    -- from another language.
    -- 02/04 discussed and validated with Rohit
    -- the user will have to map again
    --Bug 4893034 Log exception for Active Locations only
    IF  TRUNC(sysdate) <= TRUNC(NVL(p_inactive_date, sysdate)) THEN
        l_log_exception := TRUE;
    END IF;

    IF p_insert_flag THEN
        UPDATE wsh_region_locations
        SET    exception_type = 'Y',
        --Added for bug 5125837
        last_update_date  = sysdate,
        last_updated_by   = FND_GLOBAL.user_id,
        last_update_login = FND_GLOBAL.login_id
        WHERE  location_id = p_location_id
        and region_id in (select wrt.region_id from wsh_regions_tl wrt,
                             wsh_regions wr
                             where wrt.region_id = wr.region_id
                             and wrt.language = USERENV('LANG'));

        -- Vijay 08/25: added call to put exception WSH_LOCATION_REGIONS_2_ERR

        IF  l_log_exception THEN
            wsh_xc_util.log_exception(
                 p_api_version             => 1.0,
                 x_return_status           => l_return_status,
                 x_msg_count               => l_exception_msg_count,
                 x_msg_data                => l_exception_msg_data,
                 x_exception_id            => l_dummy_exception_id ,
                 p_logged_at_location_id   => p_location_id,
                 p_exception_location_id   => p_location_id,
                 p_logging_entity          => 'SHIPPER',
                 p_logging_entity_id       => FND_GLOBAL.USER_ID,
                 p_exception_name          => 'WSH_LOCATION_REGIONS_2',
                 p_message                 => 'WSH_LOCATION_REGIONS_2_ERR'
                 );
         END IF;
    ELSE
        l_upd_loc_id_tab(l_upd_loc_id_tab.COUNT) := p_location_id;
        l_upd_loc_excp_tab(l_upd_loc_excp_tab.COUNT)  := l_log_exception;
    END IF;

  END IF;

  --------------------------------------------------------
  --  If the number of regions being matched is only one set
  --  exception WSH_LOCATION_REGIONS_1_ERR
  --------------------------------------------------------

 -- Bug 4451703
 -- l_dummy_exception_id has to be intialized to NULL otherwise
 -- it takes the same value returned by previous log_exception
 -- and errors out when trying to update the existing exception.

  IF (l_rows_after = l_rows_before AND l_rows_before = 1) THEN
    --
    l_dummy_exception_id := NULL;
    --
    --Bug 4893034 Log exception for Active Locations only
    IF  TRUNC(sysdate) <= TRUNC(NVL(p_inactive_date, sysdate)) THEN
        wsh_xc_util.log_exception(
                     p_api_version             => 1.0,
                     x_return_status           => l_return_status,
                     x_msg_count               => l_exception_msg_count,
                     x_msg_data                => l_exception_msg_data,
                     x_exception_id            => l_dummy_exception_id ,
                     p_logged_at_location_id   => p_location_id,
                     p_exception_location_id   => p_location_id,
                     p_logging_entity          => 'SHIPPER',
                     p_logging_entity_id       => FND_GLOBAL.USER_ID,
                     p_exception_name          => 'WSH_LOCATION_REGIONS_1',
                     p_message                 => 'WSH_LOCATION_REGIONS_1_ERR'
                     );
    END IF;

  END IF;

  x_return_status := l_return_status;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

    WHEN Insert_Failed THEN

     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     IF l_debug_on THEN

	       WSH_DEBUG_SV.logmsg(l_module_name,'Failed in API Insert_Record');
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INSERT_FAILED');
     ELSE
        WSH_UTIL_CORE.printmsg('Failed in API Insert_Record');
     END IF;

     rollback to wsh_location_exists;

    WHEN Others THEN

     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     l_sqlcode := SQLCODE;
     l_sqlerr := SQLERRM;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'When Others of Procedure Map_Location_To_Region for location : '||p_location_id);
        WSH_DEBUG_SV.logmsg(l_module_name,l_sqlcode);
        WSH_DEBUG_SV.logmsg(l_module_name,l_sqlerr);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     ELSE
        WSH_DEBUG_SV.logmsg(l_module_name,'When Others of Procedure Map_Location_To_Region for location : '||p_location_id);
        WSH_DEBUG_SV.logmsg(l_module_name,l_sqlcode);
        WSH_DEBUG_SV.logmsg(l_module_name,l_sqlerr);
     END IF;


     rollback to wsh_location_exists;

END Map_Location_To_Region;

/*===========================================================================+
 | FUNCTION                                                                  |
 |              Insert_Record                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This API just inserts the record into intersection table     |
 |                                                                           |
 +===========================================================================*/

Procedure Insert_Record
  (
    p_location_id         IN   NUMBER,
    p_region_id           IN   NUMBER,
    p_region_type         IN   NUMBER,
    p_exception           IN   VARCHAR2,
    p_location_source     IN   VARCHAR2,
    p_parent_region       IN   VARCHAR2,
    x_return_status       OUT NOCOPY   VARCHAR2
   ) IS

   l_region_id          NUMBER := 0;
   l_sqlcode            NUMBER;
   l_sqlerr             VARCHAR2(2000);

   BEGIN

       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       INSERT INTO WSH_REGION_LOCATIONS(
          region_id,
          location_id,
          exception_type,
          region_type,
          parent_region_flag,
          location_source,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login )
       values (
          p_region_id,
          p_location_id,
          p_exception,
          p_region_type,
          p_parent_region,
          p_location_source,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id
          );

EXCEPTION

  WHEN Others THEN

   WSH_UTIL_CORE.printmsg(' Insert into WSH_REGION_LOCATIONS failed : ' || sqlerrm);
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

End Insert_Record;


/*===========================================================================+
 | FUNCTION                                                                  |
 |              Rule_Location                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the rule function for the following TCA events :     |
 |                   # oracle.apps.ar.hz.Location.create                     |
 |                   # oracle.apps.ar.hz.Location.update                     |
 |              This calls the Mapping_Regions_Main API to recreate the      |
 |              mapping once a location gets created or a location gets      |
 |              updated.                                                     |
 |                                                                           |
 +===========================================================================*/

FUNCTION Rule_Location(
               p_subscription_guid  in raw,
               p_event              in out NOCOPY  wf_event_t)
RETURN VARCHAR2 IS

  i_status   varchar2(200);
  myList     wf_parameter_list_t;
  pos        number := 1;

  l_return_status    VARCHAR2(20);
  l_return_status1   VARCHAR2(20);
  p_location_id      NUMBER;
  l_sqlcode          NUMBER;
  l_sqlerr           VARCHAR2(2000);

  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_resp_appl_id     NUMBER;
  l_security_group_id  NUMBER;

  l_pkg_name         VARCHAR2(200);
  l_proc_name        VARCHAR2(200);
  e_loc              EXCEPTION;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Rule_Location';

BEGIN

  l_org_id := p_event.getValueForParameter('ORG_ID');
  l_user_id := p_event.getValueForParameter('USER_ID');
  l_resp_id := p_event.getValueForParameter('RESP_ID');
  l_resp_appl_id := p_event.getValueForParameter('RESP_APPL_ID');
  l_security_group_id := p_event.getValueForParameter('SECURITY_GROUP_ID');

  fnd_global.apps_initialize(l_user_id,l_resp_id,l_resp_appl_id,l_security_group_id);

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
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'USER_ID: ',l_user_id);
       WSH_DEBUG_SV.log(l_module_name,'RESP_ID : ',l_resp_id);
       WSH_DEBUG_SV.log(l_module_name,'RESP_APPL_ID: ',l_resp_appl_id);
       WSH_DEBUG_SV.log(l_module_name,'SECURITY_GROUP_ID: ',l_security_group_id);
       WSH_DEBUG_SV.log(l_module_name,'USERENV LANG: ',USERENV('LANG'));
   END IF;

  myList := p_event.getParameterList();

  IF (myList is null) THEN
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return NULL;
  END IF;

  pos := myList.LAST;

   WHILE (pos is not null)
   LOOP

     IF myList(pos).getName() = 'LOCATION_ID' THEN
          p_location_id := myList(pos).getValue();
     END IF;

     pos := myList.PRIOR(pos);

   END LOOP;


   WSH_LOCATIONS_PKG.Process_Locations(
       p_location_type     => 'EXTERNAL'
     , p_from_location     => p_location_id
     , p_to_location       => p_location_id
     , p_start_date        => NULL
     , p_end_date          => NULL
     , x_return_status     => l_return_status1
     , x_sqlcode           => l_sqlcode
     , x_sqlerr            => l_sqlerr );

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_return_status1',l_return_status1);
    END IF;

    IF ( l_return_status1 NOT IN
         (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING) ) THEN
       l_pkg_name := 'WSH_LOCATIONS_PKG';
       l_proc_name := 'Process_Locations';
       raise e_loc;
    END IF;

   WSH_MAP_LOCATION_REGION_PKG.Mapping_Regions_Main(
       p_location_type     => 'EXTERNAL'
     , p_from_location     => p_location_id
     , p_to_location       => p_location_id
     , p_start_date        => NULL
     , p_end_date          => NULL
     , p_insert_flag       => TRUE
     , x_return_status     => l_return_status
     , x_sqlcode           => l_sqlcode
     , x_sqlerr            => l_sqlerr );

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;

    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return 'SUCCESS';
    ELSE
      l_pkg_name := 'WSH_MAP_LOCATION_REGION_PKG';
      l_proc_name := 'Mapping_Regions_Main';
      raise e_loc;
      /*
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return 'ERROR';
      */
    END IF;


EXCEPTION

    WHEN e_loc THEN
      WF_CORE.CONTEXT(l_pkg_name,l_proc_name,
                            p_event.getEventName( ), p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');

      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return 'ERROR';
    WHEN Others THEN
      WF_CORE.CONTEXT('WSH_MAP_LOCATIONS_REGIONS', 'Rule_Location',
                            p_event.getEventName( ), p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return 'ERROR';

END Rule_Location;

PROCEDURE Transfer_Location (
  p_source_type           IN   VARCHAR2,
  p_source_location_id    IN   NUMBER,
  p_transfer_location     IN   BOOLEAN,
  p_online_region_mapping IN   BOOLEAN,
  p_caller                IN   VARCHAR2 DEFAULT NULL,
  x_loc_rec               OUT NOCOPY   loc_rec_type,
  x_return_status         OUT NOCOPY   VARCHAR2 ) IS

l_exists                 VARCHAR2(10);
l_errbuf                 VARCHAR2(1000);
l_retcode                NUMBER;
l_location_source_type   VARCHAR2(20);
l_map_regions            VARCHAR2(1);

CURSOR Get_Location_Data IS
  SELECT wsh_location_id,
         source_location_id,
         location_source_code,
         location_code,
         ui_location_code,
         address1,
         address2,
         address3,
         address4,
         country,
         state,
         province,
         county,
         city,
         postal_code,
         inactive_date
  FROM   wsh_locations
  WHERE  source_location_id = p_source_location_id;


CURSOR Get_Location_Data1 IS
  SELECT wsh_location_id,
         source_location_id,
         location_source_code,
         location_code,
         ui_location_code,
         address1,
         address2,
         address3,
         address4,
         country,
         state,
         province,
         county,
         city,
         postal_code,
         inactive_date
  FROM   wsh_locations
  WHERE  wsh_location_id = p_source_location_id;

  l_return_status      VARCHAR2(20);
l_sqlcode            NUMBER;
l_sqlerr             VARCHAR2(2000);
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Transfer_Location';
BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
      --
  END IF;
  --
  --  Check if the location exists. If yes, then return the
  --  location data
  --

  IF p_source_type = 'HR' or p_source_type = 'HZ' or p_source_type = 'HR_HZ' THEN

     OPEN Get_Location_Data;
     FETCH Get_Location_Data INTO
          x_loc_rec.wsh_location_id,
          x_loc_rec.source_location_id,
          x_loc_rec.location_source_code,
          x_loc_rec.location_code,
          x_loc_rec.ui_location_code,
          x_loc_rec.address1,
          x_loc_rec.address2,
          x_loc_rec.address3,
          x_loc_rec.address4,
          x_loc_rec.country,
          x_loc_rec.state,
          x_loc_rec.province,
          x_loc_rec.county,
          x_loc_rec.city,
          x_loc_rec.postal_code,
          x_loc_rec.inactive_date;

     CLOSE Get_Location_Data;

  ELSIF p_source_type = 'WSH' THEN

     OPEN Get_Location_Data1;
     FETCH Get_Location_Data1 INTO
         x_loc_rec.wsh_location_id,
         x_loc_rec.source_location_id,
         x_loc_rec.location_source_code,
         x_loc_rec.location_code,
         x_loc_rec.ui_location_code,
         x_loc_rec.address1,
         x_loc_rec.address2,
         x_loc_rec.address3,
         x_loc_rec.address4,
         x_loc_rec.country,
         x_loc_rec.state,
         x_loc_rec.province,
         x_loc_rec.county,
         x_loc_rec.city,
         x_loc_rec.postal_code,
         x_loc_rec.inactive_date;

     CLOSE Get_Location_Data1;

  END IF;

  --
  --  If a location is found, then return.
  --

  IF (x_loc_rec.wsh_location_id IS NOT NULL) THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;

  --
  -- If a location is not found and if p_transfer_location
  -- is true, then create the location record in WSH_LOCATIONS
  -- table.
  --

  IF ((p_source_location_id IS NOT NULL) AND
        (p_source_type in ('HR','HZ','HR_HZ')) AND
          (p_transfer_location)) THEN

     IF p_source_type = 'HR' THEN
        l_location_source_type := 'INTERNAL' ;
     ELSIF p_source_type = 'HZ' THEN
        l_location_source_type := 'EXTERNAL' ;
     ELSIF p_source_type = 'HR_HZ' THEN
        l_location_source_type := 'BOTH' ;
     END IF;

     IF p_online_region_mapping THEN
        l_map_regions := 'Y';
     ELSE
        l_map_regions := 'N';
     END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'-----------------------------');
      WSH_DEBUG_SV.log(l_module_name,'Calling procedure Process_Locations');
    END IF;
    WSH_LOCATIONS_PKG.Process_Locations (
            p_location_type       => l_location_source_type,
            p_from_location       => p_source_location_id,
            p_to_location         => p_source_location_id,
            p_start_date          => NULL,
            p_end_date            => NULL,
            p_caller              => p_caller,
            x_return_status       => l_return_status,
            x_sqlcode             => l_sqlcode,
            x_sqlerr              => l_sqlerr);

     IF l_return_status NOT IN
        (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
         --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Failed in Procedure Process_Locations');
        END IF;
     END IF;

   IF l_map_regions = 'Y' AND l_return_status NOT IN
        (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING) THEN

    IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'----------------------------------');
            WSH_DEBUG_SV.log(l_module_name,'*** Map Regions parameter is Yes ***');
            WSH_DEBUG_SV.log(l_module_name,'Calling procedure Mapping_Regions_Main');
    END IF;

     Mapping_Regions_Main (
        p_location_type    => l_location_source_type,
        p_from_location    => p_source_location_id,
        p_to_location      => p_source_location_id,
        p_start_date       => NULL,
        p_end_date         => NULL,
        p_insert_flag      => TRUE,
        x_return_status    => l_return_status,
        x_sqlcode          => l_sqlcode,
        x_sqlerr           => l_sqlerr);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS  THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Failed in Procedure Mapping_Regions_Main');
        END IF;
        END IF;
    END IF;

/*
        WSH_MAP_LOCATION_REGION_PKG.Map_Locations_Child_Program (
             p_errbuf           => l_errbuf,
             p_retcode          => l_retcode,
             p_location_type    => l_location_source_type,
             p_map_regions      => l_map_regions,
             p_from_location    => p_source_location_id,
             p_to_location      => p_source_location_id,
             p_start_date       => NULL,
             p_end_date         => NULL);
*/

          OPEN Get_Location_Data;
          FETCH Get_Location_Data INTO
                x_loc_rec.wsh_location_id,
                x_loc_rec.source_location_id,
                x_loc_rec.location_source_code,
                x_loc_rec.location_code,
                x_loc_rec.ui_location_code,
                x_loc_rec.address1,
                x_loc_rec.address2,
                x_loc_rec.address3,
                x_loc_rec.address4,
                x_loc_rec.country,
                x_loc_rec.state,
                x_loc_rec.province,
                x_loc_rec.county,
                x_loc_rec.city,
                x_loc_rec.postal_code,
                x_loc_rec.inactive_date;

          CLOSE Get_Location_Data;

  END IF;

  IF x_loc_rec.wsh_location_id IS NULL THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Returning wsh_location_id : '||x_loc_rec.wsh_location_id);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

END Transfer_Location;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Location_User_Hook_API                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This API is called by Create_Location/Update_Location        |
 |              Business Process -  After Process User Hook.                 |
 |              This ensures that the whenever HR location is created or     |
 |              updated, corresponding changes in WSH_LOCATIONS and          |
 |              WSH_REGION_LOCATIONS happens                                 |
 +===========================================================================*/

PROCEDURE Location_User_Hook_API(
  p_location_id       IN      NUMBER) IS

l_return_status      VARCHAR2(15);
l_return_status1     VARCHAR2(15);
l_sqlcode            NUMBER;
l_sqlerr             VARCHAR2(2000);
l_location_id        NUMBER;
l_wsh_location_id    NUMBER;
l_organization_id    NUMBER;
map_region           BOOLEAN := FALSE;
terr_short_name      FND_TERRITORIES_TL.TERRITORY_SHORT_NAME%TYPE;
terr_code            FND_TERRITORIES_TL.TERRITORY_CODE%TYPE;
l_region             HR_LOCATIONS_ALL.REGION_2%TYPE;
l_city               HR_LOCATIONS_ALL.TOWN_OR_CITY%TYPE;
l_postal_code        HR_LOCATIONS_ALL.POSTAL_CODE%TYPE;
l_location_source    VARCHAR2(4);
l_inactive_date      DATE;

--Bug 6940375
l_wsh_loc_id  	     NUMBER;
--Bug 6940375

CURSOR Get_Internal_Locations IS
  SELECT
    l.location_id,
    t.territory_short_name,
    t.territory_code,
    l.region_2 state,
    l.town_or_city city,
    l.postal_code,
    l.inactive_date
  FROM
    hr_locations_all l,
    fnd_territories_tl t
  WHERE
    t.territory_code = l.country and
    t.language = userenv('LANG') and
    l.location_id = p_location_id;

--Bug 6940375 Creating a new Cursor

 CURSOR Get_Internal_Loc IS
  SELECT
    l.location_id
  FROM
    hr_locations_all l
  WHERE
    l.location_id = p_location_id;

--Bug 6940375

CURSOR check_wsh_loc(c_loc_id IN NUMBER) IS
  SELECT wsh_location_id
  FROM   wsh_locations
  WHERE  source_location_id = c_loc_id
  AND    location_source_code = 'HR';

CURSOR check_company(c_loc_id IN NUMBER) IS
  SELECT ou.organization_id
  FROM   hr_all_organization_units ou,
         mtl_parameters mp
  WHERE  mp.organization_id = ou.organization_id
  AND    ou.location_id = c_loc_id;

BEGIN

   l_location_source := 'HR';

   --
   -- Create a record in WSH_LOCATIONS
   --
--Bug 6940375 Start (Check if the HR location is deleted,
--then delete location from wsh_locations)
   OPEN  Get_Internal_Loc;
   FETCH Get_Internal_Loc INTO
          l_wsh_loc_id;
       IF Get_Internal_Loc%NOTFOUND THEN
        CLOSE Get_Internal_Loc;
        DELETE FROM wsh_locations
        WHERE wsh_location_id = p_location_id;
        RETURN ;
       END IF;
    CLOSE Get_Internal_Loc;

   -- Should update only
   -- if caller is 'HR' and company is not found
   -- should not create
   WSH_LOCATIONS_PKG.Process_Locations(
       p_location_type     => 'INTERNAL'
     , p_from_location     => p_location_id
     , p_to_location       => p_location_id
     , p_start_date        => NULL
     , p_end_date          => NULL
     , p_caller            => 'HR'
     , x_return_status     => l_return_status1
     , x_sqlcode           => l_sqlcode
     , x_sqlerr            => l_sqlerr );

   --
   -- Create a record in WSH_REGION_LOCATIONS
   --

   OPEN  Get_Internal_Locations;
   FETCH Get_Internal_Locations INTO
          l_location_id,
          terr_short_name,
          terr_code,
          l_region,
          l_city,
          l_postal_code,
          l_inactive_date;

   CLOSE Get_Internal_Locations;


   -- if company is not found
   -- Should go forward only in case of update
   -- should not in case of create
   --
   OPEN check_wsh_loc(p_location_id);
   FETCH check_wsh_loc INTO l_wsh_location_id;
   CLOSE check_wsh_loc;

   IF l_wsh_location_id IS NOT NULL THEN
      map_region := TRUE;
   ELSE
      -- check if company exists for p_location_id
      OPEN check_company(p_location_id);
      FETCH check_company INTO l_organization_id;
      CLOSE check_company;

      IF l_organization_id IS NOT NULL  THEN
         map_region := TRUE;
      END IF;
   END IF;

   --  Calling the API Map_Location_To_Region and not Mapping_Regions_Main
   --  (as done in function rule_location) because the API that is being
   --  called during User Hook should not have any commit statements. The
   --  records will be commited by the HRMS API's.
   --
   IF map_region THEN

      Map_Location_To_Region (
       p_country          =>  terr_short_name,
       p_country_code     =>  terr_code,
       p_state            =>  l_region,
       p_city             =>  l_city,
       p_postal_code      =>  l_postal_code,
       p_location_id      =>  l_location_id,
       p_location_source  =>  l_location_source,
       p_inactive_date    =>  l_inactive_date,
       x_return_status    =>  l_return_status,
       x_sqlcode          =>  l_sqlcode,
       x_sqlerr           =>  l_sqlerr );

   END IF;

END Location_User_Hook_API;

PROCEDURE Get_Transit_Time(p_ship_from_loc_id IN      NUMBER,
                             p_ship_to_site_id  IN      NUMBER,
                             p_ship_method_code IN      VARCHAR2 DEFAULT NULL,
                             p_carrier_id       IN      NUMBER,
                             p_service_code     IN      VARCHAR2,
                             p_mode_code        IN      VARCHAR2,
                             p_from             IN      VARCHAR2,
                             x_transit_time     OUT NOCOPY NUMBER,
                             x_return_status    OUT NOCOPY VARCHAR2) IS

  l_ship_method_code    VARCHAR2(30);
  l_prev_ship_method    VARCHAR2(30);
  l_session_id          NUMBER;
  l_transit_time        NUMBER;
  Region_Loc_zone_tab  WSH_UTIL_CORE.Id_Tab_Type;
  Loc_Region_zone_tab  WSH_UTIL_CORE.Id_Tab_Type;
  get_From_Region_tab  WSH_UTIL_CORE.Id_Tab_Type;
  get_To_Region_tab    WSH_UTIL_CORE.Id_Tab_Type ;
  l_return_status     VARCHAR2(55);
  dummy number (5);
  CURSOR get_session_id IS
  SELECT mrp_atp_schedule_temp_s.nextVal
  FROM dual;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_TRANSIT_TIME';
  --
/*This Cursor gets transit time if transit time is defined between two locations */
 cursor get_Transit_Loc_Loc (p_from_loc_id NUMBER, p_to_loc_id NUMBER, p_ship_method VARCHAR2) IS
 select intransit_time
 from   mtl_interorg_ship_methods
 where  from_location_id = p_from_loc_id
 and    to_location_id   = p_to_loc_id
 and    ship_method      = p_ship_method_code;

/*This Cursor gets transit time if transit time is defined between FROM Region TO location */
 CURSOR get_Transit_Region_Loc (p_from_region_id NUMBER, p_to_loc_id NUMBER, p_ship_method VARCHAR2) IS
 SELECT intransit_time
 FROM   mtl_interorg_ship_methods
 WHERE  from_region_id  = p_from_region_id
 AND    to_location_id  = p_to_loc_id
 AND    ship_method     = p_ship_method_code;

 /*This Cursor gets transit time if transit time is defined between FROM Location TO region */
 CURSOR get_Transit_Loc_Region (p_from_loc_id NUMBER, p_to_region_id NUMBER, p_ship_method VARCHAR2) IS
 SELECT intransit_time
 FROM   mtl_interorg_ship_methods
 WHERE  from_location_id = p_from_loc_id
 AND    to_region_id     = p_to_region_id
 AND    ship_method      = p_ship_method_code;

 /*This Cursor gets transit time if transit time is defined between FROM region TO region*/
 CURSOR get_Transit_Region_Region (p_from_region_id NUMBER, p_to_region_id NUMBER, p_ship_method VARCHAR2) IS
 SELECT intransit_time
 FROM   mtl_interorg_ship_methods
 WHERE  from_region_id = p_from_region_id
 AND    to_region_id     = p_to_region_id
 AND    ship_method      = p_ship_method_code;

 CURSOR get_ship_method_cur IS
 SELECT ship_method_code
 FROM   wsh_carrier_services
 WHERE  carrier_id     = p_carrier_id
 AND    enabled_flag   = 'Y'
 AND    (    (p_mode_code IS NULL AND mode_of_transport IS NULL)
         OR  (p_mode_code IS NOT NULL AND mode_of_transport = p_mode_code)
        )
AND     (     (p_service_code IS NULL AND service_level   IS NULL)
          OR  (p_service_code IS NOT NULL AND service_level = p_service_code)
        );

  BEGIN
    --
    l_transit_time := NULL;
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
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_LOC_ID',P_SHIP_FROM_LOC_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_SITE_ID',P_SHIP_TO_SITE_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',P_SHIP_METHOD_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_ID',P_CARRIER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_SERVICE_CODE',P_SERVICE_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_MODE_CODE',P_MODE_CODE);
    END IF;
    --

    x_return_status := WSH_UTIL_CORE.g_ret_sts_success;
    x_transit_time := null;

    IF p_ship_method_code IS NULL THEN

      OPEN get_ship_method_cur;
      FETCH get_ship_method_cur INTO l_ship_method_code;
      CLOSE get_ship_method_cur;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'ship method derived is ' || l_ship_method_code);
      END IF;
    ELSE
      l_ship_method_code := p_ship_method_code;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Check for cached transit time');
    END IF;

    IF (p_from = 'OM') THEN
      -- check if the transit time for this ship method , origin and destination is already cached
      FOR k IN 1..g_ship_method_tab.COUNT LOOP
          IF (l_ship_method_code = g_ship_method_tab(k)) AND
             (p_ship_from_loc_id = g_ship_from_loc_tab(k)) AND
             (p_ship_to_site_id = g_ship_to_site_tab(k)) THEN
             --(g_transit_time_tab(k) IS NOT NULL) THEN
             x_transit_time := g_transit_time_tab(k);

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'found ship method transit time information cached');
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;

            RETURN;
          END IF;
      END LOOP;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Transit Time Not cached',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    --The ship method returned by MSC_ATP_PROC.ATP_Shipping_Lead_Time could be different
    --from the ship method passed in. If it doesn't find the transit time, it returns
    --the default ship method and default ship method transit time.
    l_prev_ship_method := l_ship_method_code;


    --OM Callers pass the ship_to_site_id, and get the transit time from the
    --MSC_ATP_PROC.Shiping_Lead_Time API
    IF (p_from = 'OM') THEN

      OPEN get_session_id;
      FETCH get_session_id INTO l_session_id;
      CLOSE get_session_id;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'MSC_ATP session id =  ' || l_session_id,WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      MSC_ATP_PROC.ATP_Shipping_Lead_Time(p_from_loc_id          => p_ship_from_loc_id,
                                          p_to_customer_site_id  => p_ship_to_site_id,
                                          p_session_id           => l_session_id,
                                          x_ship_method          => l_ship_method_code,
                                          x_intransit_time       => l_transit_time,
                                          x_return_status        => x_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'MSC_ATP_PROC.ATP_Shipping_Lead_Time is ' || l_transit_time,WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

    --FTE callers pass in the ultimate_dropoff_location_id
    ELSE

    --Bug 4653381 Start
/* From Location, To Location */
    OPEN  get_Transit_Loc_Loc(p_ship_from_loc_id,p_ship_to_site_id,l_ship_method_code);
    FETCH get_Transit_Loc_Loc INTO l_transit_time;
    CLOSE get_Transit_Loc_Loc;
    IF l_transit_time IS NOT NULL THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Found the transit time from Location to location: ', l_transit_time);
     END IF;
     x_transit_time := l_transit_time;
     RETURN;
    END IF;

    /* From Region, To Location */


    WSH_REGIONS_SEARCH_PKG.Get_All_RegionId_Matches(p_location_id =>p_ship_from_loc_id,
                                  x_region_tab => get_From_Region_tab,
			     p_lang_code=>USERENV('LANG'),
			     x_return_status =>l_return_status);

    IF get_From_Region_tab.count >0 THEN
       FOR i IN get_From_Region_tab.FIRST..get_From_Region_tab.LAST  LOOP
        OPEN  get_Transit_Region_Loc(get_From_Region_tab(i),p_ship_to_site_id,p_ship_method_code);
        FETCH get_Transit_Region_Loc into l_transit_time;
        CLOSE get_Transit_Region_Loc;

        IF l_transit_time IS NOT NULL THEN
           IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Found the transit time from Region to Location : ',l_transit_time);
           END IF;
           x_transit_time :=l_transit_time;
           RETURN;
        END IF;


        WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches(
                                             p_region_id =>get_From_Region_tab(i),
                                             x_zone_tab =>Region_Loc_zone_tab,
                                             x_return_status =>l_return_status);

        IF Region_Loc_zone_tab.count >0 THEN
           FOR j in Region_Loc_zone_tab.FIRST..Region_Loc_zone_tab.LAST LOOP
            OPEN  get_Transit_Region_Loc(Region_Loc_zone_tab(j),p_ship_to_site_id,p_ship_method_code);
            FETCH get_Transit_Region_Loc INTO l_transit_time;
            CLOSE get_Transit_Region_Loc;

            IF l_transit_time IS NOT NULL THEN
             IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Got the transit time from Region to Location : ',l_transit_time);
             END IF;
             x_transit_time :=l_transit_time;
             RETURN;
            END IF;
           END LOOP;
        END IF;
       END LOOP;
    END IF;


    /* From Location, To Region */

      WSH_REGIONS_SEARCH_PKG.Get_All_RegionId_Matches(p_location_id =>p_ship_to_site_id,
                              p_lang_code=>USERENV('LANG'),
			     x_region_tab => get_To_Region_tab,
			     x_return_status =>l_return_status);


    IF get_To_Region_tab.COUNT >0 THEN
       FOR i in get_To_Region_tab.FIRST..get_To_Region_tab.LAST LOOP
        OPEN get_Transit_Loc_Region(p_ship_from_loc_id,get_To_Region_tab(i),p_ship_method_code);
        FETCH get_Transit_Loc_Region INTO l_transit_time;
        CLOSE get_Transit_Loc_Region;

        IF l_transit_time IS NOT NULL THEN
           IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Got the transit time from Location to Region  : ',l_transit_time);
           END IF;
           x_transit_time :=l_transit_time;
           RETURN;
        END IF;


        WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches(
                                             p_region_id =>get_To_Region_tab(i),
                                             x_zone_tab =>Loc_Region_zone_tab,
                                             x_return_status =>l_return_status);

        IF Loc_Region_zone_tab.count >0 THEN
           FOR j in Loc_Region_zone_tab.FIRST..Loc_Region_zone_tab.LAST LOOP
            OPEN get_Transit_Loc_Region(p_ship_from_loc_id,Loc_Region_zone_tab(j),p_ship_method_code);
            FETCH get_Transit_Loc_Region INTO l_transit_time;
            CLOSE get_Transit_Loc_Region;
            IF l_transit_time IS NOT NULL THEN
             IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Got the transit time from Location to Region  : ',l_transit_time);
             END IF;
             x_transit_time :=l_transit_time;
             RETURN;
            END IF;
	   END LOOP;
        END IF;
       END LOOP;
    END IF;


     /* From Region, To Region */

    --1)Loop over to_region

    IF get_To_Region_tab.COUNT >0 THEN
      FOR i in get_To_Region_tab.FIRST..get_To_Region_tab.LAST LOOP
        IF get_From_Region_tab.COUNT >0 THEN
           FOR j in get_From_Region_tab.FIRST..get_From_Region_tab.LAST LOOP
            OPEN get_Transit_Region_Region (get_From_Region_tab(j),get_To_Region_tab(i),p_ship_method_code);
            FETCH get_Transit_Region_Region INTO l_transit_time;
            CLOSE get_Transit_Region_Region;

             IF  l_transit_time IS NOT NULL THEN
               IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Got the transit time from Region to Region : ',l_transit_time);
               END IF;
               x_transit_time :=l_transit_time;
               RETURN;
             END IF;

            WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches(
                                             p_region_id =>get_From_Region_tab(j),
                                             x_zone_tab =>Region_Loc_zone_tab,
                                             x_return_status =>l_return_status);
            IF Region_Loc_zone_tab.count >0 THEN
             FOR m in Region_Loc_zone_tab.FIRST..Region_Loc_zone_tab.LAST LOOP
              OPEN get_Transit_Region_Region (Region_Loc_zone_tab(m),get_To_Region_tab(i),p_ship_method_code);
              FETCH get_Transit_Region_Region INTO l_transit_time;
              CLOSE get_Transit_Region_Region;
               IF  l_transit_time IS NOT NULL THEN
                IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Got the transit time from Zone to Zone  : ',l_transit_time);
                END IF;
                x_transit_time :=l_transit_time;
                RETURN;
               END IF;
             END LOOP;
            END IF;


            WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches(
                                             p_region_id =>get_To_Region_tab(i),
                                             x_zone_tab =>Loc_Region_zone_tab,
                                             x_return_status =>l_return_status);
            IF Loc_Region_zone_tab.count >0 THEN
             FOR n IN Loc_Region_zone_tab.FIRST..Loc_Region_zone_tab.LAST LOOP
              IF Region_Loc_zone_tab.COUNT > 0 THEN
               FOR p IN Region_Loc_zone_tab.FIRST..Region_Loc_zone_tab.LAST LOOP
               OPEN get_Transit_Region_Region(Region_Loc_zone_tab(p),Loc_Region_zone_tab(n),p_ship_method_code);
               FETCH get_Transit_Region_Region INTO l_transit_time;
               CLOSE get_Transit_Region_Region;
                IF l_transit_time IS NOT NULL THEN
                 IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Got the transit time from Zone to Zone  : ',l_transit_time);
                 END IF;
                 x_transit_time :=l_transit_time;
                 RETURN;
                END IF;
               END LOOP ;
              END IF;
             END LOOP;
            END IF ;

           END LOOP; --End of from_region (j)
        END IF;
      END LOOP; --End of To_region (i)
    END IF;

   --2)Loop over from_region

    IF get_From_Region_tab.COUNT >0 THEN
     FOR i in get_From_Region_tab.FIRST..get_From_Region_tab.LAST LOOP
      IF get_To_Region_tab.COUNT >0 THEN
       FOR j in get_To_Region_tab.FIRST..get_To_Region_tab.LAST LOOP
        OPEN get_Transit_Region_Region (get_From_Region_tab(i),get_To_Region_tab(j),p_ship_method_code);
        FETCH get_Transit_Region_Region INTO l_transit_time;
        CLOSE get_Transit_Region_Region;

         IF  l_transit_time IS NOT NULL THEN
          IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Got the transit time from Region to Region : ',l_transit_time);
          END IF;
          x_transit_time :=l_transit_time;
          RETURN;
         END IF;

         WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches(
                                             p_region_id =>get_To_Region_tab(j),
                                             x_zone_tab =>Loc_Region_zone_tab,
                                             x_return_status =>l_return_status);
         IF Loc_Region_zone_tab.count >0 THEN
          FOR m in Loc_Region_zone_tab.FIRST..Loc_Region_zone_tab.LAST LOOP
           OPEN get_Transit_Region_Region (get_From_Region_tab(i),Loc_Region_zone_tab(m),p_ship_method_code);
           FETCH get_Transit_Region_Region INTO l_transit_time;
           CLOSE get_Transit_Region_Region;
            IF  l_transit_time IS NOT NULL THEN
             IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Got the transit time from from Region to Zone  : ',l_transit_time);
             END IF;
             x_transit_time :=l_transit_time;
             RETURN;
             END IF;
          END LOOP;
         END IF;


         WSH_REGIONS_SEARCH_PKG.Get_All_Zone_Matches(
                                             p_region_id =>get_From_Region_tab(i),
                                             x_zone_tab =>Region_Loc_zone_tab,
                                             x_return_status =>l_return_status);
         IF Region_Loc_zone_tab.count >0 THEN
          FOR n IN Region_Loc_zone_tab.FIRST..Region_Loc_zone_tab.LAST LOOP
           IF Loc_Region_zone_tab.COUNT >0 THEN
            FOR p IN Loc_Region_zone_tab.FIRST..Loc_Region_zone_tab.LAST LOOP
             OPEN get_Transit_Region_Region(Region_Loc_zone_tab(n),Loc_Region_zone_tab(p),p_ship_method_code);
             FETCH get_Transit_Region_Region INTO l_transit_time;
             CLOSE get_Transit_Region_Region;
              IF  l_transit_time IS NOT NULL THEN
               IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Got the transit time from Zone to Zone  : ',l_transit_time);
               END IF;
               x_transit_time :=l_transit_time;
               RETURN;
              END IF;
            END LOOP ;
           END IF;
          END LOOP;
         END IF ;

       END LOOP; --End of To_region (j)
      END IF;
     END LOOP; --End of From_region (i)
    END IF;


   --Bug 4653381 END
    END IF;

    IF (p_from = 'OM') THEN
    --Cache the transit times
    IF (l_ship_method_code IS NOT NULL) THEN
      g_ship_method_tab(g_ship_method_tab.COUNT + 1) := l_ship_method_code;
      g_ship_from_loc_tab(g_ship_from_loc_tab.COUNT + 1) := p_ship_from_loc_id;
      g_ship_to_site_tab(g_ship_to_site_tab.COUNT + 1) := p_ship_to_site_id;
      g_transit_time_tab(g_transit_time_tab.COUNT + 1) := l_transit_time;
    END IF;

    -- Bug 3357380
    -- If the ship_method is changed by ATP API, it means that Transit Time
    -- for the original ship method is not defined.
    IF (l_prev_ship_method <> l_ship_method_code) THEN
      g_ship_method_tab(g_ship_method_tab.COUNT + 1) := l_prev_ship_method;
      g_ship_from_loc_tab(g_ship_from_loc_tab.COUNT + 1) := p_ship_from_loc_id;
      g_ship_to_site_tab(g_ship_to_site_tab.COUNT + 1) := p_ship_to_site_id;
      g_transit_time_tab(g_transit_time_tab.COUNT + 1) := NULL;
      l_transit_time := NULL;
    END IF;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Transit Time: ', l_transit_time);
    END IF;

    x_transit_time := l_transit_time;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    EXCEPTION
    WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Exception occurred in WSH_MAP_LOCATION_REGION_PKG');
       WSH_DEBUG_SV.log(l_module_name,'SQLCODE: ',sqlcode);
       WSH_DEBUG_SV.log(l_module_name,'SQLERRM: ',SUBSTR(SQLERRM,1,200));
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;


  END Get_Transit_Time;

  --==============================================================================
-- PROCEDURE   : PREDEL_LOC_VALIDATION   Added for bug Bug 6940375
--
-- PARAMETERS  : p_location_id              Input location id
-- DESCRIPTION : This procedure checks if an Internal location is eligible
-- 	         for deletion. Shipping raises error if the location exists
--               in shipping tables.
--===============================================================================

PROCEDURE PREDEL_LOC_VALIDATION (p_location_id   number)
  IS
  --
  v_delete_permitted    varchar2(1) := NULL;
  l_msg 		varchar2(30) := 'WSH_LOC_RECORD_EXISTS';
  l_token               varchar2(30);
  WSH_LOC_EXISTS        EXCEPTION;
  l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PREDEL_LOC_VALIDATION';
  BEGIN

    IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
       wsh_debug_sv.LOG(l_module_name, 'p_location_id', p_location_id);
    END IF;
    BEGIN
        l_token := 'WSH_DELIVERY_DETAILS';
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'Validating records in table : ', l_token);
	END IF;
        SELECT 'N'
        INTO    v_delete_permitted
        FROM    WSH_DELIVERY_DETAILS
        WHERE   SHIP_FROM_LOCATION_ID = P_LOCATION_ID
	AND     ROWNUM =1;

	IF v_delete_permitted IS NOT NULL THEN
	RAISE WSH_LOC_EXISTS ;
	END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'No records found in table : ', l_token);
	END IF;
    END ;

    BEGIN
        l_token := 'WSH_CALENDAR_ASSIGNMENTS';
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'Validating records in table', l_token);
	END IF;
	v_delete_permitted := NULL;
	SELECT 'N'
        INTO  v_delete_permitted
        FROM  WSH_CALENDAR_ASSIGNMENTS WCA, WSH_LOCATIONS WSH
        WHERE WCA.LOCATION_ID = P_LOCATION_ID
	AND   WSH.WSH_LOCATION_ID = WCA.LOCATION_ID
	AND   WSH.LOCATION_SOURCE_CODE = 'HR'
	AND   ROWNUM = 1;

     	IF v_delete_permitted IS NOT NULL THEN
	RAISE WSH_LOC_EXISTS ;
	END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'No records found in table : ', l_token);
	END IF;
    END ;


    BEGIN
	l_token := 'WSH_DOC_SEQUENCE_CATEGORIES';
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'Validating records in table', l_token);
	END IF;
	v_delete_permitted := NULL;
	SELECT 'N'
        INTO    v_delete_permitted
        FROM    WSH_DOC_SEQUENCE_CATEGORIES WDO, WSH_LOCATIONS WSH
        WHERE   WDO.LOCATION_ID = P_LOCATION_ID
	AND     WSH.WSH_LOCATION_ID = WDO.LOCATION_ID
	AND     WSH.LOCATION_SOURCE_CODE = 'HR'
	AND     ROWNUM = 1;

	IF v_delete_permitted IS NOT NULL THEN
	RAISE WSH_LOC_EXISTS ;
	END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'No records found in table : ', l_token);
	END IF;
    END ;


    BEGIN
        l_token := 'WSH_PICKING_RULES';
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'Validating records in table', l_token);
	END IF;
	v_delete_permitted := NULL;
	SELECT 'N'
        INTO    v_delete_permitted
        FROM    WSH_PICKING_RULES
        WHERE   SHIP_FROM_LOCATION_ID = P_LOCATION_ID
	AND     ROWNUM = 1;

	IF v_delete_permitted IS NOT NULL THEN
	RAISE WSH_LOC_EXISTS ;
	END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'No records found in table : ', l_token);
	END IF;
    END ;


    BEGIN
	l_token := 'WSH_REGION_LOCATIONS';
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'Validating records in table', l_token);
	END IF;
	v_delete_permitted := NULL;
	SELECT 'N'
        INTO    v_delete_permitted
        FROM    WSH_REGION_LOCATIONS
        WHERE   LOCATION_ID = P_LOCATION_ID
	AND     REGION_ID IS NOT NULL
	AND     ROWNUM = 1 ;

	IF v_delete_permitted IS NOT NULL THEN
	RAISE WSH_LOC_EXISTS ;
	END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'No records found in table : ', l_token);
	END IF;
    END ;

    BEGIN
	l_token := 'WSH_SHIPPING_PARAMETERS';
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'Validating records in table', l_token);
	END IF;
	v_delete_permitted := NULL;
	SELECT 'N'
        INTO    v_delete_permitted
        FROM    WSH_SHIPPING_PARAMETERS
        WHERE   LOCATION_ID = P_LOCATION_ID
	AND     ROWNUM = 1 ;

	IF v_delete_permitted IS NOT NULL THEN
	RAISE WSH_LOC_EXISTS ;
	END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
	IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'No records found in table : ', l_token);
	END IF;
    END ;

 IF l_debug_on THEN
    wsh_debug_sv.LOG(l_module_name, 'No records exists in shipping tables for location id : ', p_location_id);
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;


   EXCEPTION
   WHEN WSH_LOC_EXISTS THEN
        IF l_debug_on THEN
	   wsh_debug_sv.LOG(l_module_name, 'Records found in table : ', l_token);
	   WSH_DEBUG_SV.pop(l_module_name);
	END IF;
        FND_MESSAGE.SET_NAME('WSH','WSH_LOC_RECORD_EXISTS');
	FND_MESSAGE.SET_TOKEN('TABLE_NAME', l_token);
        APP_EXCEPTION.RAISE_EXCEPTION;

  END PREDEL_LOC_VALIDATION;


END WSH_MAP_LOCATION_REGION_PKG;


/
