--------------------------------------------------------
--  DDL for Package Body WSH_ITM_EXPORT_SCREENING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_EXPORT_SCREENING" AS
/* $Header: WSHITESB.pls 120.3.12010000.3 2010/02/12 09:35:21 gbhargav ship $ */



    G_PKG_NAME CONSTANT VARCHAR2(50)                   := 'WSH_ITM_EXPORT_SCREENING';
    G_REQ_PICK_RELEASE_EXCEPTION CONSTANT VARCHAR2(30) := 'WSH_PR_REQ_EXPORT_COMPL';
    G_REQ_SHIP_CONFIRM_EXCEPTION CONSTANT VARCHAR2(30) := 'WSH_SC_REQ_EXPORT_COMPL';
    G_SUB_PICK_RELEASE_EXCEPTION CONSTANT VARCHAR2(30) := 'WSH_PR_SUB_EXPORT_COMPL';
    G_SUB_SHIP_CONFIRM_EXCEPTION CONSTANT VARCHAR2(30) := 'WSH_SC_SUB_EXPORT_COMPL';
    G_APPLICATION_ID             CONSTANT NUMBER       :=  665;
    G_PICK_RELEASE_EVENT         CONSTANT VARCHAR2(50) := 'PICK_RELEASE';
    G_SHIP_CONFIRM_EVENT         CONSTANT VARCHAR2(50) := 'SHIP_CONFIRM';
    G_SERVICE_TYPE_CODE          CONSTANT VARCHAR2(50) := 'WSH_EXPORT_COMPLIANCE';

    --Workflow Global values
	G_WF_ENTITY_TYPE CONSTANT VARCHAR2(30) := 'DELIVERY';
	G_WF_PICK_RELEASE_EVENT_NAME CONSTANT VARCHAR2(100) :=
		'oracle.apps.wsh.delivery.itm.submittedscreeningatdelcreate';
	G_WF_SHIP_CONFIRM_EVENT_NAME CONSTANT VARCHAR2(100) :=
		'oracle.apps.wsh.delivery.itm.submittedscreeningatship';


     TYPE delivery_detail_rec_type IS RECORD
          ( delivery_detail_id               NUMBER ,
            transaction_temp_id              NUMBER ,
            inventory_item_id               NUMBER
           );

   --TYPE delivery_detail_tab_type IS TABLE OF delivery_detail_rec_type INDEX BY BINARY_INTEGER;

    TYPE sn_range_rec_type IS RECORD
          ( delivery_detail_id               NUMBER ,
            transaction_temp_id              NUMBER ,
            from_serial_number               VARCHAR2(30),
            to_serial_number                 VARCHAR2(30),
            quantity                         NUMBER
           );

    --TYPE sn_range_tab_type IS TABLE OF sn_range_rec_type INDEX BY BINARY_INTEGER;


PROCEDURE PROCESS_SERIAL_NUMBERS(p_sn_range_rec_type  IN sn_range_rec_type,
                                 p_request_control_id IN NUMBER,
                                 p_delivery_id        IN NUMBER,
                                 x_return_status      OUT NOCOPY VARCHAR2
)

IS

    l_from_serial_num       VARCHAR2(30);
    l_to_serial_num         VARCHAR2(30);
    l_debug_on              BOOLEAN;
    l_real_serial_prefix    VARCHAR2(30);
    l_prefix_length         NUMBER;
    l_from_numeric          NUMBER;
    l_to_numeric            NUMBER;
    l_range_count                NUMBER;
    l_new_serial_number     VARCHAR2(30);

    l_module_name CONSTANT VARCHAR2(100) :=  G_PKG_NAME || '.' || 'PROCESS_SERIAL_NUMBERS';


BEGIN

            l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

            IF l_debug_on IS NULL
            THEN
                l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
            END IF;
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'ENTERING '||l_module_name);
            END IF;

             IF p_sn_range_rec_type.from_serial_number IS NOT NULL THEN

                    l_from_serial_num := p_sn_range_rec_type.from_serial_number;
                    l_to_serial_num   := p_sn_range_rec_type.to_serial_number;

                   IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_from_serial_num ',l_from_serial_num);
                   END IF;

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_to_serial_num ',l_to_serial_num);
                  END IF;

                   --Addded in bug 9265708.Trim function here will return null if serial number ends with a number ,will return
                  --last chracter of the serial number if serial number ends with a character.
                  IF (TRIM(TRANSLATE(SubStr(p_sn_range_rec_type.from_serial_number,
                               Length(p_sn_range_rec_type.from_serial_number)), '0123456789',' ' )) IS NULL ) THEN
                  --{
                        l_real_serial_prefix := RTRIM(p_sn_range_rec_type.from_serial_number,
                                                      '0123456789');

                         IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'l_real_serial_prefix ',l_real_serial_prefix);
                         END IF;

                         l_prefix_length :=  NVL(LENGTH(l_real_serial_prefix), 0);

                         IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'l_prefix_length ',l_prefix_length);
                         END IF;

                         l_from_numeric  :=  TO_NUMBER(SUBSTR(p_sn_range_rec_type.from_serial_number,
                                                 l_prefix_length + 1));

                         IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'l_from_numeric ',l_from_numeric);
                         END IF;

                         l_to_numeric    :=  TO_NUMBER(SUBSTR(p_sn_range_rec_type.to_serial_number,
                                                  l_prefix_length + 1));

                         IF l_debug_on THEN
                           WSH_DEBUG_SV.log(l_module_name,'l_to_numeric ',l_to_numeric);
                         END IF;

                         l_range_count  := l_to_numeric - l_from_numeric ;
                  --}
                    ELSE
                  --{
                       l_range_count := 0 ;
                  --}
                  END IF;

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_range_count ',l_range_count);
                  END IF;

                    -- If range count is zero, means from and to are same and no new
                    -- serial numbers need to be generated
                    IF l_range_count = 0 THEN

                       IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'Inside l_range_count ',l_range_count);
                       END IF;
                       IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_from_serial_num ',l_from_serial_num);
                       END IF;

                       -- Only one serial number needs to go in either From or to as both are same.
                       INSERT INTO WSH_ITM_SERIAL_NUMBERS
                       (request_control_id,
                        delivery_id,
                        delivery_detail_id,
                        serial_number)
                       VALUES
                       ( p_request_control_id,
                         p_delivery_id,
                         p_sn_range_rec_type.delivery_detail_id,
                         l_from_serial_num
                        );
                    ELSE
                        -- If range_count is > 0 then generate new serial numbers
                        -- starting with 0 to that range count
                        FOR i IN 0..l_range_count LOOP

                           l_new_serial_number := l_real_serial_prefix || LPAD(TO_CHAR(l_from_numeric+i),
                                                  LENGTH(p_sn_range_rec_type.from_serial_number)
                                                  - l_prefix_length, '0');

                           IF l_debug_on THEN
                              WSH_DEBUG_SV.log(l_module_name,'New Serial Number ',l_new_serial_number);
                           END IF;

                           INSERT INTO WSH_ITM_SERIAL_NUMBERS
                           (request_control_id,
                            delivery_id,
                            delivery_detail_id,
                            serial_number)
                           VALUES
                           ( p_request_control_id,
                             p_delivery_id,
                             p_sn_range_rec_type.delivery_detail_id,
                             l_new_serial_number
                            );
                        END LOOP;
                    END IF;
             END IF;

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WSH_ITM_EXPORT_COMPLIANCE;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'The unexpected Error Code ' || SQLCODE || ' : ' || SQLERRM);
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'EXITING '||l_module_name);
        END IF;


END PROCESS_SERIAL_NUMBERS;


 PROCEDURE POPULATE_SERIAL_NUMBERS(
              p_request_control_id IN NUMBER,
              p_delivery_id        IN NUMBER,
              x_return_status      OUT NOCOPY VARCHAR2
              )
 IS

    l_debug_on              BOOLEAN;

    l_delv_detail_rec delivery_detail_rec_type;
    l_sn_range_rec_type sn_range_rec_type;

    CURSOR c_get_delivery_details(c_delivery_id IN NUMBER)
    IS
    SELECT wdd.delivery_detail_id, wdd.transaction_temp_id, wdd.inventory_item_id
    FROM WSH_DELIVERY_DETAILS wdd,wsh_delivery_assignments wda
    WHERE wda.delivery_id = c_delivery_id
    AND wda.delivery_detail_id = wdd.delivery_detail_id;

    --Bug 9265708  removed join with wsh_delivery_details
    CURSOR c_get_serial_num_range(c_transaction_temp_id IN NUMBER, c_delivery_detail_id IN NUMBER)
    IS
    SELECT c_delivery_detail_id,c_transaction_temp_id,mt.fm_serial_number,
    mt.to_serial_number , to_number(mt.serial_prefix) quantity
    FROM mtl_serial_numbers_temp mt
    WHERE mt.transaction_temp_id = c_transaction_temp_id;

    CURSOR c_get_serial_number_from_wdd(c_delivery_detail_id IN NUMBER)
    IS
    SELECT wdd.delivery_detail_id,null,wdd.serial_number,wdd.to_serial_number,shipped_quantity
    FROM wsh_delivery_details wdd
    WHERE wdd.delivery_detail_id = c_delivery_detail_id;

    l_module_name CONSTANT VARCHAR2(100) := G_PKG_NAME || '.' || 'POPULATE_SERIAL_NUMBERS';

BEGIN

        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'ENTERING '||l_module_name);
        END IF;



        OPEN c_get_delivery_details(p_delivery_id);
        LOOP
            FETCH c_get_delivery_details INTO l_delv_detail_rec;
            EXIT  WHEN c_get_delivery_details%NOTFOUND;
             IF l_debug_on THEN
                 WSH_DEBUG_SV.push(l_module_name);
                 WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',
                                           l_delv_detail_rec.delivery_detail_id);
                 WSH_DEBUG_SV.log(l_module_name,'transaction_temp_id',
                                           l_delv_detail_rec.transaction_temp_id);
             END IF;

             IF l_delv_detail_rec.transaction_temp_id IS NULL THEN
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'TRANSACTION_TEMP_ID IS NULL');
                END IF;

                 OPEN c_get_serial_number_from_wdd (l_delv_detail_rec.delivery_detail_id);
                 LOOP
                     FETCH c_get_serial_number_from_wdd INTO l_sn_range_rec_type;

                     EXIT WHEN c_get_serial_number_from_wdd%NOTFOUND;
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',
                                                  l_sn_range_rec_type.delivery_detail_id);
                         WSH_DEBUG_SV.log(l_module_name,'to_serial_number',
                                                   l_sn_range_rec_type.to_serial_number);
                         WSH_DEBUG_SV.log(l_module_name,'from_serial_number',
                                                   l_sn_range_rec_type.from_serial_number);
                     END IF;
                     PROCESS_SERIAL_NUMBERS(
                                    p_sn_range_rec_type => l_sn_range_rec_type,
                                    p_request_control_id => p_request_control_id,
                                    p_delivery_id => p_delivery_id,
                                    x_return_status => x_return_status);
                 END LOOP;
                 CLOSE c_get_serial_number_from_wdd;
             ELSE
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'TRANSACTION_TEMP_ID IS NOT NULL');
                END IF;

                 OPEN c_get_serial_num_range (l_delv_detail_rec.transaction_temp_id,l_delv_detail_rec.delivery_detail_id);
                 LOOP
                     FETCH c_get_serial_num_range INTO l_sn_range_rec_type;

                     EXIT WHEN c_get_serial_num_range%NOTFOUND;
                     IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',
                                                   l_sn_range_rec_type.delivery_detail_id);
                         WSH_DEBUG_SV.log(l_module_name,'to_serial_number',
                                                   l_sn_range_rec_type.to_serial_number);
                         WSH_DEBUG_SV.log(l_module_name,'from_serial_number',
                                                   l_sn_range_rec_type.from_serial_number);
                     END IF;
                     PROCESS_SERIAL_NUMBERS(
                                    p_sn_range_rec_type => l_sn_range_rec_type,
                                    p_request_control_id => p_request_control_id,
                                    p_delivery_id => p_delivery_id,
                                    x_return_status => x_return_status);
                 END LOOP;
                 CLOSE c_get_serial_num_range;
             END IF;
        END LOOP;
        CLOSE c_get_delivery_details;

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO WSH_ITM_EXPORT_COMPLIANCE;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'The unexpected Error Code ' || SQLCODE || ' : ' || SQLERRM);
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'EXITING '||l_module_name);
        END IF;


END POPULATE_SERIAL_NUMBERS;



    /*==========================================================================+
    | PROCEDURE                                                                 |
    |              SCREEN_EVENT_DELIVERIES                                      |
    | PARAMETERS                                                                |
    |                                                                           |
    |  x_return_status     => This is updated with the process status which     |
    |                          could either be a success of warning or an error.|
    |  p_organization_id   => This parameter is used to filter the deliveries   |
    |                            based on organization.                         |
    |                                                                           |
    |  p_delivery_from_id  => This parameter indicates the starting of the      |
    |                           range of deliveries to be processed.            |
    |  p_delivery_to_id    => This parameter indicates the ending of the        |
    |                           range of deliveries to be processed.            |
    |  p_event_name        => This parameter indicates the event on which the   |
    |                            the export screening was initiated.            |
    |  p_ship_method_code  => This paramter indicates the ship method of the    |
    |			       delivery                                         |
    |  p_pickup_date_from  => This parameter indicates the initail pickup date  |                                             |                                                                           |
    |  p_pickup_date_to    => This parameter indicates the last pick up date    |
    |	                                                                        |
    |  p_event_name        => This parameter indicates the event on which the   |
    |                            the export screening was initiated.            |
    | DESCRIPTION                                                               |
    |              This procedure is called For the deliveries of a             |
    |              Specific event. It  Logs and Handles Appropriate             |
    |              Exceptions which hold the delivery until the export          |
    |              screening is done for the delivery ad populates data into    |
    |              WSH_ITM_REQUEST_CONTROL Table.                               |
    |                                                                           |
    +===========================================================================*/

    PROCEDURE SCREEN_EVENT_DELIVERIES (
                x_return_status                 OUT NOCOPY   VARCHAR2,
                p_organization_id               IN           NUMBER,
                p_delivery_from_id              IN           NUMBER,
                p_delivery_to_id                IN           NUMBER,
                p_event_name                    IN           VARCHAR2,
                p_ship_method_code              IN           VARCHAR2,
                p_pickup_date_from              IN           VARCHAR2,
                p_pickup_date_to                IN           VARCHAR2
              )IS
        -- Declaration Section For Log/close Exception Section

        i                               NUMBER;
        l_api_version                   NUMBER := 1.0;
        l_return_status                 VARCHAR2(1);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(200);
        l_exception_id                  NUMBER;
        x_exception_id                  NUMBER;
        l_old_status                    VARCHAR2(30);
        l_new_status                    VARCHAR2(30);
        l_default_status                VARCHAR2(1);
        l_validation_level              NUMBER DEFAULT  FND_API.G_VALID_LEVEL_FULL;
        l_exception_message             VARCHAR2(2000);
        l_exception_name                VARCHAR2(30);

        l_CursorID                      NUMBER;
        l_ignore                        NUMBER;
        l_tempStr                       VARCHAR2(10000) := ' ';

        --Declaration Section For Bulk Select PL/SQL Tables
        l_num_exception_id_tab          DBMS_SQL.Number_Table;
        l_varchar_status_tab            DBMS_SQL.Varchar2_Table;
        l_num_location_id_tab           DBMS_SQL.Number_Table;
        l_num_delivery_id_tab           DBMS_SQL.Number_Table;
        l_varchar_delivery_name_tab     DBMS_SQL.Varchar2_Table;

        --AJPRABHA for inserting DATA into Transactions History.
        l_tranx_history_rec             WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type;
        x_txns_id                       NUMBER;
        l_rec_found                     NUMBER          DEFAULT 0;
        l_request_control_id_s          NUMBER;

        -- Declaration Section for columns(Non - PL/SQL Table) used in Interface Table Population
        l_user_id                       NUMBER;
        l_login_id                      NUMBER;
        l_LanguageCode                  VARCHAR2(20);

	--Added for Raising tracking Workflows
	l_wf_event_name			VARCHAR2(1000);
	l_wf_return_status		VARCHAR2(1);
	l_num_organization_id_tab	DBMS_SQL.Number_Table;
        l_parameter_list		wf_parameter_list_t;
         --BUG 6700736 Added variable to store master_organization_id
        l_num_master_org_id_tab  DBMS_SQL.Number_Table;

        l_debug_on                      BOOLEAN;
        l_module_name CONSTANT          VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||'SCREEN_EVENT_DELIVERIES';

        --Addded condition to get deliveries that contains items Bug Number 3411941
        --BUG 6700736 Fetching master_organization_id to populate into wsh_itm_request_control
        l_exp_compliance_dlvy_query     VARCHAR2(1800) :=
                ' SELECT                                                          '||
                '       WE.EXCEPTION_ID            AS EXCEPTION_ID,               '||
                '       WE.EXCEPTION_LOCATION_ID   AS LOCATION_ID,                '||
                '       WND.DELIVERY_ID            AS DELIVERY_ID,                '||
                '       WE.STATUS                  AS STATUS,                     '||
                '       WND.NAME		           AS DELIVERY_NAME,              '||
		        ' 	    WND.ORGANIZATION_ID	       AS ORGANIZATION_ID,	          '||
                '       MTL.MASTER_ORGANIZATION_ID AS MASTER_ORGANIZATION_ID      '||
                ' FROM                                                            '||
                '       WSH_EXCEPTIONS WE ,                                       '||
                '       WSH_NEW_DELIVERIES WND,                                   '||
                '       MTL_PARAMETERS MTL                                        '||
                ' WHERE                                                           '||
                '       WE.STATUS <> ''CLOSED''                                   '||
                '   AND WND.ORGANIZATION_ID = MTL.ORGANIZATION_ID                 '||
                '   AND WND.DELIVERY_ID = WE.DELIVERY_ID                          '||
                '   AND WND.DELIVERY_ID = (SELECT                                 '||
                '                               WDA.DELIVERY_ID                   '||
                '                           FROM                                  '||
                '                               WSH_DELIVERY_ASSIGNMENTS WDA      '||
                '                           WHERE                                 '||
                '                               WDA.DELIVERY_ID = WND.DELIVERY_ID '||
                '                            AND ROWNUM = 1) ' ;
        l_Delivery_Table                    WSH_ITM_QUERY_CUSTOM.g_CondnValTableType;
        l_Delivery_Condn1Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
        l_Delivery_Condn2Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
        l_Delivery_Condn3Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
        l_Delivery_Condn4Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
        l_Delivery_Condn5Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
        l_Delivery_Condn6Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
        l_Delivery_Condn7Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
        l_Delivery_Condn71Tab               WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
        l_Delivery_Condn8Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
        l_Delivery_Condn9Tab                WSH_ITM_QUERY_CUSTOM.g_ValueTableType;
    BEGIN

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',p_organization_id);
            WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_FROM_ID',p_delivery_from_id);
            WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_TO_ID',p_delivery_to_id);
            WSH_DEBUG_SV.log(l_module_name,'P_EVENT_NAME',p_event_name);
            WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',p_ship_method_code);
            WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_DATE_FROM',p_pickup_date_from);
            WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_DATE_TO',p_pickup_date_to);
        END IF;

        -------------------------------------------------------------------------------
        -- Pickup Deliveries which require export screening
        -------------------------------------------------------------------------------
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'This Section Picks up the Deliveries Which Require Screeenig For '||p_event_name||' event ');
        END IF;

        -- This sub section prepares the query to pick up the Deliveries which require screening
        IF p_event_name = G_PICK_RELEASE_EVENT THEN
            l_Delivery_Condn1Tab(1).g_varchar_val  :=  G_REQ_PICK_RELEASE_EXCEPTION;
            l_Delivery_Condn1Tab(1).g_Bind_Literal := ':b_req_pick_release';
            WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Delivery_Table, ' AND WE.EXCEPTION_NAME  = :b_req_pick_release', l_Delivery_Condn1Tab, 'VARCHAR');
        ELSIF p_event_name = G_SHIP_CONFIRM_EVENT THEN
            l_Delivery_Condn2Tab(1).g_varchar_val :=  G_REQ_SHIP_CONFIRM_EXCEPTION;
            l_Delivery_Condn2Tab(1).g_Bind_Literal := ':b_req_ship_confirm';
            WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Delivery_Table, ' AND WE.EXCEPTION_NAME  = :b_req_ship_confirm', l_Delivery_Condn2Tab, 'VARCHAR');
        END IF;

        IF p_organization_id is not null THEN
            l_Delivery_Condn3Tab(1).g_number_val   :=  p_organization_id;
            l_Delivery_Condn3Tab(1).g_Bind_Literal := ':b_org_id';
            WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Delivery_Table, ' AND WND.ORGANIZATION_ID = :b_org_id', l_Delivery_Condn3Tab, 'NUMBER');
        END IF;

        IF p_delivery_from_id is not null THEN
            l_Delivery_Condn4Tab(1).g_number_val :=  p_delivery_from_id;
            l_Delivery_Condn4Tab(1).g_Bind_Literal := ':b_delivery_from_id';
            WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Delivery_Table, ' AND WE.DELIVERY_ID >= :b_delivery_from_id', l_Delivery_Condn4Tab, 'NUMBER');
        END IF;


        IF p_delivery_to_id is not null THEN
            l_Delivery_Condn5Tab(1).g_number_val :=  p_delivery_to_id;
            l_Delivery_Condn5Tab(1).g_Bind_Literal := ':b_delivery_to_id';
            WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Delivery_Table, ' AND WE.DELIVERY_ID <= :b_delivery_to_id', l_Delivery_Condn5Tab, 'NUMBER');
        END IF;


        IF p_ship_method_code is not null THEN
            l_Delivery_Condn6Tab(1).g_varchar_val :=  p_ship_method_code;
            l_Delivery_Condn6Tab(1).g_Bind_Literal := ':b_ship_method_code';
            WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Delivery_Table, ' AND WND.SHIP_METHOD_CODE = :b_ship_method_code', l_Delivery_Condn6Tab, 'VARCHAR');
        END IF;

        IF p_pickup_date_from is not null  THEN
            l_Delivery_Condn8Tab(1).g_date_val :=  FND_DATE.CANONICAL_TO_DATE(p_pickup_date_from);
            l_Delivery_Condn8Tab(1).g_Bind_Literal := ':b_pickup_date_from';
            WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Delivery_Table, ' AND WND.INITIAL_PICKUP_DATE >= :b_pickup_date_from', l_Delivery_Condn8Tab, 'DATE');
        END IF;

        IF  p_pickup_date_to is not null THEN
            l_Delivery_Condn9Tab(1).g_date_val :=  FND_DATE.CANONICAL_TO_DATE(p_pickup_date_to);
            l_Delivery_Condn9Tab(1).g_Bind_Literal := ':b_pickup_date_to';
            WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_Delivery_Table, ' AND WND.INITIAL_PICKUP_DATE <= :b_pickup_date_to', l_Delivery_Condn9Tab, 'DATE');
        END IF;

         FOR I IN 1..l_Delivery_Table.COUNT
         LOOP
             l_tempStr := l_tempStr || ' ' || l_Delivery_table(i).g_Condn_Qry;
         END LOOP;



            l_exp_compliance_dlvy_query :=  l_exp_compliance_dlvy_query||l_tempStr||' ';
        IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' The Query executed ',l_exp_compliance_dlvy_query);
        END IF;



        -- This sub section executes the query and collects the result set into PL/SQL Tables

        l_CursorID := DBMS_SQL.Open_Cursor;
        DBMS_SQL.PARSE(l_CursorID,   l_exp_compliance_dlvy_query,  DBMS_SQL.v7);
        DBMS_SQL.DEFINE_ARRAY(l_CursorID, 1, l_num_exception_id_tab, 100, 0);
        DBMS_SQL.DEFINE_ARRAY(l_CursorID, 2, l_num_location_id_tab, 100, 0);
        DBMS_SQL.DEFINE_ARRAY(l_CursorID, 3, l_num_delivery_id_tab, 100, 0);
        DBMS_SQL.DEFINE_ARRAY(l_CursorID, 4, l_varchar_status_tab, 100, 0);
        DBMS_SQL.DEFINE_ARRAY(l_CursorID, 6, l_num_organization_id_tab,  100, 0);
	    DBMS_SQL.DEFINE_ARRAY(l_CursorID, 5, l_varchar_delivery_name_tab, 100, 0);
        --Bug 6700736 Defined array for master_organization_id
        DBMS_SQL.DEFINE_ARRAY(l_CursorID, 7, l_num_master_org_id_tab, 100, 0);

        WSH_ITM_QUERY_CUSTOM.BIND_VALUES(l_Delivery_Table,l_CursorID);
        l_ignore := DBMS_SQL.EXECUTE(l_CursorID);


        LOOP
            l_ignore := DBMS_SQL.FETCH_ROWS(l_CursorID);
            DBMS_SQL.COLUMN_VALUE(l_CursorID, 1,l_num_exception_id_tab);
            DBMS_SQL.COLUMN_VALUE(l_CursorID, 2,l_num_location_id_tab);
            DBMS_SQL.COLUMN_VALUE(l_CursorID, 3,l_num_delivery_id_tab );
            DBMS_SQL.COLUMN_VALUE(l_CursorID, 4,l_varchar_status_tab);
            DBMS_SQL.COLUMN_VALUE(l_CursorID, 5,l_varchar_delivery_name_tab );
	        DBMS_SQL.COLUMN_VALUE(l_CursorID, 6, l_num_organization_id_tab);
            --Bug 6700736 Associated array variables master_organization_id
            DBMS_SQL.COLUMN_VALUE(l_CursorID, 7,l_num_master_org_id_tab );
            EXIT WHEN l_ignore <> 100;
        END LOOP;

        DBMS_SQL.CLOSE_CURSOR(l_CursorID);

        IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,' No Of Deliveries Selected For Screening ',l_num_delivery_id_tab.count);
        END IF;

        IF l_num_delivery_id_tab.count < 1 THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    RETURN;
        END IF;


        FOR j in l_num_delivery_id_tab.first .. l_num_delivery_id_tab.last LOOP
        ---------------------------------------------------------------------------------
        -- Handling Require Export Screening Exceptions
        ---------------------------------------------------------------------------------
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'This Section Handles The REQUIRE Export Screening Exception for'||p_event_name||' event ');
        END IF;

        l_return_status  := NULL;
        l_msg_count      := NULL;
        l_msg_data       := NULL;
        l_exception_id   := l_num_exception_id_tab(j);
        l_old_status     := l_varchar_status_tab(j);
        l_new_status     := 'CLOSED';
        l_default_status := 'F';

        WSH_XC_UTIL.change_status (
            p_api_version           => l_api_version,
            p_init_msg_list         => FND_API.g_false,
            p_commit                => FND_API.g_false,
            p_validation_level      => l_validation_level,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_exception_id          => l_exception_id,
            p_old_status            => l_old_status,
            p_set_default_status    => l_default_status,
            x_new_status            => l_new_status
        );

        -- Error Handling Section

        IF l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,' Error Handling the exception for Delivery Id : '||l_num_delivery_id_tab(j));
            END IF;

            IF l_msg_count IS NOT NULL THEN
                WSH_UTIL_CORE.Add_Message(l_return_status);
                FOR i IN 1 ..l_msg_count LOOP
                    l_msg_data := FND_MSG_PUB.get
                    (
                        p_msg_index => i,
                        p_encoded => 'F'
                    );
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,l_msg_data);
                    END IF;
                END LOOP;
            END IF;

            -- Cleaning Operation
            ROLLBACK TO WSH_ITM_EXPORT_COMPLIANCE;

            x_return_status := l_return_status;
            IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
        END IF;

        --------------------------------------------------------------------------------------------------------
        -- Logging exceptions for Deliveries submitted for export screening
        ---------------------------------------------------------------------------------------------------------

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'This Section Logs a Submitted For Export Screening For Delivery which Require Export Screening and Handles the Existing Require Export Screening Exceptions for '||p_event_name||' event ');
        END IF;

        l_return_status  := NULL;
        l_msg_count      := NULL;
        l_msg_data       := NULL;
        l_exception_id   := NULL;
        l_exception_name := NULL;
        l_exception_message := 'Delivery has been submitted for export screening';

        IF p_event_name = G_PICK_RELEASE_EVENT THEN
            l_exception_name := G_SUB_PICK_RELEASE_EXCEPTION;
	    l_wf_event_name  := G_WF_PICK_RELEASE_EVENT_NAME;
        ELSIF p_event_name = G_SHIP_CONFIRM_EVENT THEN
	    l_exception_name := G_SUB_SHIP_CONFIRM_EXCEPTION;
  	    l_wf_event_name  := G_WF_SHIP_CONFIRM_EVENT_NAME;
        END IF;


        WSH_XC_UTIL.log_exception(
            p_api_version            => l_api_version,
            p_init_msg_list          => FND_API.g_false,
            p_commit                 => FND_API.g_false,
            p_validation_level       => l_validation_level,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data,
            x_exception_id           => l_exception_id,
            p_exception_location_id  => l_num_location_id_tab(j),
            p_logged_at_location_id  => l_num_location_id_tab(j),
            p_logging_entity         => 'SHIPPER',
            p_logging_entity_id      => FND_GLOBAL.USER_ID,
            p_exception_name         => l_exception_name,
            p_message                => l_exception_message,
            p_delivery_id            => l_num_delivery_id_tab(j),
            p_delivery_name          => l_varchar_delivery_name_tab(j)
        );

        IF l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,' Error Logging the exception for Delivery Id : ',l_num_delivery_id_tab(j));
            END IF;

            IF l_msg_count IS NOT NULL THEN
                WSH_UTIL_CORE.Add_Message(l_return_status);
                FOR i in 1 ..l_msg_count LOOP
                    l_msg_data := FND_MSG_PUB.get
                    (
                        p_msg_index => i,
                        p_encoded => 'F'
                     );
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.log(l_module_name,l_msg_data);
                    END IF;
                END LOOP;
            END IF;

            -- Cleaning Operation
            ROLLBACK TO WSH_ITM_EXPORT_COMPLIANCE;

            x_return_status := l_return_status;
            IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
        END IF;

	RAISE_ITM_EVENT
		(
		p_event_name => l_wf_event_name ,
		p_delivery_id => l_num_delivery_id_tab(j),
		p_organization_id => l_num_organization_id_tab(j),
		x_return_status => l_wf_return_status
		);

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_WF_STD.RAISE_EVENT => ',l_wf_return_status);
	END IF;

   END LOOP;

        -------------------------------------------------------------------------------
        -- Populates Deliveries Into ITM Request Control Tables
        -------------------------------------------------------------------------------
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'This Section Populates The Delivery Information Into Request Control Table for '||p_event_name||' event ');
        END IF;

        -- This sub section Prepares the data to be inserted into ITM Request Control Table
        -- Fetch user and login information
        l_user_id  := FND_GLOBAL.USER_ID;
        l_login_id := FND_GLOBAL.CONC_LOGIN_ID;

        -- Getting the Base Language into the variable

        SELECT LANGUAGE_CODE INTO l_LanguageCode FROM
        FND_LANGUAGES WHERE INSTALLED_FLAG = 'B';
        -- AJPRABHA INSERTING Records INTO TransactionsHistory Table
        -- Check for existing records
        -- If NO insert rec by using API

        FOR k IN l_num_delivery_id_tab.FIRST .. l_num_delivery_id_tab.LAST LOOP

            --Checking if record Exists for this delivery in
            -- Transactions Hsitory Table
            BEGIN
                SELECT 1 INTO l_rec_found
                FROM WSH_TRANSACTIONS_HISTORY
                WHERE DOCUMENT_TYPE = 'SS' AND
                ENTITY_NUMBER = l_varchar_delivery_name_tab(k);

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                NULL;
            END;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Records found for delivery ' || l_rec_found);
                END IF;

                IF (l_rec_found = 0) THEN
                        -- Get the ORGANIZATION_IF of the delivery
                        --  and setting the TRADING_PARTNER_ID.
                    BEGIN
                        SELECT ORGANIZATION_ID INTO l_tranx_history_rec.trading_partner_id
                        FROM WSH_NEW_DELIVERIES
                        WHERE DELIVERY_ID = l_num_delivery_id_tab(k);

                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        NULL;
                    END;
                    --
                    l_tranx_history_rec.document_type       :=  'SS';   --ShipmentScreening
                    l_tranx_history_rec.document_direction  :=  'O';    --Outbound
                    l_tranx_history_rec.transaction_status  :=  'ST';   --Sent to
                    l_tranx_history_rec.entity_type         :=  'DLVY'; --Delivery
                    l_tranx_history_rec.entity_number       :=  l_varchar_delivery_name_tab(k);--DELIVERY NUMBER
                    l_tranx_history_rec.action_type         :=  'A';    --Sending new Msg

                    SELECT  WSH_DOCUMENT_NUMBER_S.NEXTVAL
                    INTO l_tranx_history_rec.document_number FROM DUAL;

                    WSH_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History(
                            l_tranx_history_rec,
                            x_txns_id,
                            x_return_status
                        );
                    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        ROLLBACK TO WSH_ITM_EXPORT_COMPLIANCE;
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'Create_Update_Txns_History failed ' || x_return_status);
                            WSH_DEBUG_SV.pop(l_module_name);
                        END IF;
                        RETURN;
                     END IF;

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'Created Transaction for Delivery txns_id = ' || x_txns_id );
                    END IF;
                 END IF;
        END LOOP;

        -------------------------------------------------------------

        -- This Sub Section Does the Bulk Insert to Request Control Table
    FOR k IN l_num_delivery_id_tab.FIRST .. l_num_delivery_id_tab.LAST
    LOOP
        SELECT  WSH_ITM_REQUEST_CONTROL_S.NEXTVAL
        INTO l_request_control_id_s FROM DUAL;
        --Bug 6700736 Populating  master_organization_id
        INSERT INTO WSH_ITM_REQUEST_CONTROL(
                    REQUEST_CONTROL_ID,
                    APPLICATION_ID,
                    APPLICATION_USER_ID,
                    SERVICE_TYPE_CODE,
                    TRANSACTION_DATE,
                    ORIGINAL_SYSTEM_REFERENCE,
                    PROCESS_FLAG,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN,
                    LANGUAGE_CODE,
                    TRIGGERING_POINT,
		    ORGANIZATION_ID,
            MASTER_ORGANIZATION_ID
                )
                VALUES(
                    l_request_control_id_s,
                    G_APPLICATION_ID,
                    l_user_id,
                    G_SERVICE_TYPE_CODE,
                    SYSDATE,
                    l_num_delivery_id_tab(k),
                    0,
                    SYSDATE,
                    l_user_id,
                    l_user_id,
                    SYSDATE,
                    l_login_id,
                    l_LanguageCode,
                    p_event_name,
	  	   l_num_organization_id_tab(k),
           l_num_master_org_id_tab(k)
                );
                WSH_ITM_EXPORT_SCREENING.POPULATE_SERIAL_NUMBERS(l_request_control_id_s
                                                                ,l_num_delivery_id_tab(k)
                                                                , x_return_status);

                IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        ROLLBACK TO WSH_ITM_EXPORT_COMPLIANCE;
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'Create_Serial_numbers_failed ' || x_return_status);
                            WSH_DEBUG_SV.pop(l_module_name);
                        END IF;
                        RETURN;
                END IF;

                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Before Calling  WSH_ITM_CUSTOM_PROCESS.PRE_PROCESS_WSH_REQUEST');
                        END IF;

                         WSH_ITM_CUSTOM_PROCESS.PRE_PROCESS_WSH_REQUEST
                         (
                            p_request_control_id => l_request_control_id_s
                         );

                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'After Calling  WSH_ITM_CUSTOM_PROCESS.PRE_PROCESS_WSH_REQUEST');
                END IF;
        END LOOP;

        EXCEPTION
        WHEN OTHERS THEN


            ROLLBACK TO WSH_ITM_EXPORT_COMPLIANCE;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'The unexpected Error Code ' || SQLCODE || ' : ' || SQLERRM);
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;

 END SCREEN_EVENT_DELIVERIES;


/*==========================================================================+
    | PROCEDURE                                                                 |
    |              RAISE_ITM_EVENT                                              |
    | PARAMETERS                                                                |
    |                                                                           |
    |   p_event_name       => The WF event name that has to be raised		|
    |                         by the procedure					|
    |   p_organization_id  => This parameter is used to indiate the organization|
    |                         of the delivery.					|
    |                                                                           |
    |   p_delivery_id =>    This delivery for which the workflow		|
    |                       event has to be raised				|
    |                                                                           |
    | DESCRIPTION                                                               |
    |              This procedure is called when the concurrent program is      |
    |              Launched. It is invoked by the screen_event_deliveries	|
    |              Procedure							|
    |                                                                           |
    +===========================================================================
   */


    PROCEDURE  RAISE_ITM_EVENT(
		p_event_name IN VARCHAR2,
		p_delivery_id IN NUMBER,
		p_organization_id IN NUMBER,
		x_return_status OUT NOCOPY VARCHAR2
	) IS
	  l_parameter_list     wf_parameter_list_t;
          l_debug_on             BOOLEAN;
           --
           l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||'RAISE_ITM_EVENT';

    BEGIN
		SAVEPOINT RAISE_ITM_EVENT;

		--
		l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
		--
		IF l_debug_on IS NULL THEN
		    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
		END IF;

		IF l_debug_on THEN
		    WSH_DEBUG_SV.push(l_module_name);
		    WSH_DEBUG_SV.log(l_module_name,'P_EVENT_NAME',p_event_name);
		    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',p_delivery_id);
		    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',p_organization_id);
		END IF;

                wf_event.AddParameterToList(
                         p_name=>'ORGANIZATION_ID',
                         p_value  => p_organization_id,
                         p_parameterlist=> l_parameter_list);

		WSH_WF_STD.raise_event(
			p_entity_type		=> G_WF_ENTITY_TYPE,
			p_entity_id		=> p_delivery_id,
			p_event			=> p_event_name,
			p_parameters            => l_parameter_list,
			p_organization_id	=> p_organization_id,
			x_return_status		=> x_return_status);

    --Debug message added  in bug 9226895
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

	EXCEPTION
	 WHEN OTHERS THEN
	     ROLLBACK TO RAISE_ITM_EVENT;
	     IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'The unexpected Error Code ' || SQLCODE || ' : ' || SQLERRM);
		WSH_DEBUG_SV.pop(l_module_name);
	     END IF;
	END RAISE_ITM_EVENT;


    /*==========================================================================+
    | PROCEDURE                                                                 |
    |              SCREEN_DELIVERIES                                            |
    | PARAMETERS                                                                |
    |                                                                           |
    |   ret_code           => This is updated with the process status which     |
    |                            could either be a success or  error.           |
    |   p_organization_id  => This parameter is used to filter the deliveries   |
    |                         based on organization.                            |
    |                                                                           |
    |   p_delivery_from_id => This parameter indicates the starting of the      |
    |                           range of deliveries to be processed.            |
    |   p_delivery_to_id   => This parameter indicates the ending of the        |
    |                           range of deliveries to be processed.            |
    |                                                                           |
    | DESCRIPTION                                                               |
    |              This procedure is called when the concurrent program is      |
    |              Launched. It invokes the screen_event_deliveries Procedure   |
    |              for handling the export screening requests for both          |
    |              Pick Release and Ship Conifirm Events.                       |
    |                                                                           |
    +===========================================================================*/




    PROCEDURE SCREEN_DELIVERIES (
            errbuf                 OUT NOCOPY   VARCHAR2,
            retcode                OUT NOCOPY   NUMBER,
            p_organization_id      IN           NUMBER,
            p_delivery_from_id     IN           NUMBER,
            p_delivery_to_id       IN           NUMBER,
            p_ship_method_code     IN           VARCHAR2,
            p_pickup_date_from     IN           VARCHAR2,
            p_pickup_date_to       IN          VARCHAR2
            )IS

            l_return_status        VARCHAR2(1);
            l_temp                 BOOLEAN;
            l_debug_on             BOOLEAN;
            --
            l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||'SCREEN_DELIVERIES';

    BEGIN
            SAVEPOINT WSH_ITM_EXPORT_COMPLIANCE;

            --
            l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
            --
            IF l_debug_on IS NULL THEN
                    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
            END IF;

            IF l_debug_on THEN
                    WSH_DEBUG_SV.push(l_module_name);
                    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION ID',p_organization_id);
                    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_FROM_ID',p_delivery_from_id);
                    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_TO_ID',p_delivery_to_id);
                    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',p_ship_method_code);
                    WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_DATE_FROM',p_pickup_date_from);
                    WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_DATE_TO',p_pickup_date_to);
            END IF;

            ------------------------------------------------------------------------------------------
            -- Performs Export Screening For Deliveries on Pick Release Event
            ------------------------------------------------------------------------------------------
            l_return_status := NULL;

            WSH_ITM_EXPORT_SCREENING.SCREEN_EVENT_DELIVERIES(l_return_status,p_organization_id,p_delivery_from_id,p_delivery_to_id,G_PICK_RELEASE_EVENT,p_ship_method_code,p_pickup_date_from,p_pickup_date_to);


            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error in  procedure WSH_ITM_EXPORT_SCREENING.SCREEN_DELIVERIES for Pick Release event ');
                    retcode := 2;
                    IF l_debug_on THEN
                            WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    RETURN;
            END IF;

            ------------------------------------------------------------------------------------------
            -- Performs Export Screening For Deliveries on Ship Confirm Event
            ------------------------------------------------------------------------------------------
            l_return_status := NULL;

            WSH_ITM_EXPORT_SCREENING.SCREEN_EVENT_DELIVERIES(l_return_status,p_organization_id,p_delivery_from_id,p_delivery_to_id,G_SHIP_CONFIRM_EVENT,p_ship_method_code,p_pickup_date_from,p_pickup_date_to);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error in  procedure WSH_ITM_EXPORT_SCREENING.SCREEN_DELIVERIES for Ship Confirm event ');
                    retcode := 2;
                    IF l_debug_on THEN
                             WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    RETURN;
            END IF;

            IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
            END IF;

            EXCEPTION
            WHEN OTHERS THEN

            ROLLBACK TO WSH_ITM_EXPORT_COMPLIANCE;
            IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'The unexpected Error Code ' || SQLCODE || ' : ' || SQLERRM);
            END IF;
            retcode := 2;

            IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
            END IF;

    END SCREEN_DELIVERIES;


END WSH_ITM_EXPORT_SCREENING;

/
