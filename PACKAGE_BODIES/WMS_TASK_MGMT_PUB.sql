--------------------------------------------------------
--  DDL for Package Body WMS_TASK_MGMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_MGMT_PUB" AS
/*$Header: WMSTKMPB.pls 120.13.12010000.2 2009/10/09 08:46:07 pbonthu ship $ */
------------------------------------------------------------------------------------------------------
        g_pkg_name VARCHAR2(30) := 'WMS_TASK_MGMT_PUB';
        g_debug    NUMBER       := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'),0);
------------------------------------------------------------------------------------------------------
-- START OF QUERY TASKS
PROCEDURE initialize_main_table
IS
BEGIN
        ---initialize the main table
        ---this table will have all the parameters with default values that
        ---need to be passed to wms_waveplan_tasks_pvt.query_tasks procedure
        g_main_tab(1).field_name   := 'ACTIVE';
        g_main_tab(1).field_value  := NULL;
        g_main_tab(2).field_name   := 'ASSEMBLY_ID';
        g_main_tab(2).field_value  := NULL;
        g_main_tab(3).field_name   := 'CARRIER_ID';
        g_main_tab(3).field_value  := NULL;
        g_main_tab(4).field_name   := 'CATEGORY_SET_ID';
        g_main_tab(4).field_value  := NULL;
        g_main_tab(5).field_name   := 'COMPLETED';
        g_main_tab(5).field_value  := FND_API.G_FALSE;
        g_main_tab(6).field_name   := 'CUSTOMER_CATEGORY';
        g_main_tab(6).field_value  := NULL;
        g_main_tab(7).field_name   := 'CUSTOMER_ID';
        g_main_tab(7).field_value  := NULL;
        g_main_tab(8).field_name   := 'CYCLE_COUNT_NAME';
        g_main_tab(8).field_value  := NULL;
        g_main_tab(9).field_name   := 'CYCLE_COUNT_TASKS';
        g_main_tab(9).field_value  := FND_API.G_TRUE;
        g_main_tab(10).field_name  := 'DELIVERY_ID';
        g_main_tab(10).field_value := NULL;
        g_main_tab(11).field_name  := 'DEPARTMENT_ID';
        g_main_tab(11).field_value := NULL;
        g_main_tab(12).field_name  := 'DISPATCHED';
        g_main_tab(12).field_value := FND_API.G_FALSE;
        g_main_tab(13).field_name  := 'EMPLOYEE_ID';
        g_main_tab(13).field_value := NULL;
        ---add equipment
        g_main_tab(14).field_name  := 'EQUIPMENT';
        g_main_tab(14).field_value := NULL;
        g_main_tab(15).field_name  := 'EQUIPMENT_TYPE_ID'; --14
        g_main_tab(15).field_value := NULL;
        g_main_tab(16).field_name  := 'FROM_CREATION_DATE'; -- 15
        g_main_tab(16).field_value := NULL;
        g_main_tab(17).field_name  := 'FROM_JOB'; --16
        g_main_tab(17).field_value := NULL;
        g_main_tab(18).field_name  := 'FROM_LINE'; --17
        g_main_tab(18).field_value := NULL;
        g_main_tab(19).field_name  := 'FROM_LINES_IN_SALES_ORDER'; --18
        g_main_tab(19).field_value := NULL;
        g_main_tab(20).field_name  := 'FROM_PICK_SLIP'; --19
        g_main_tab(20).field_value := NULL;
        g_main_tab(21).field_name  := 'FROM_PO_HEADER_ID'; --20
        g_main_tab(21).field_value := NULL;
        g_main_tab(22).field_name  := 'FROM_PURCHASE_ORDER'; --21
        g_main_tab(22).field_value := NULL;
        g_main_tab(23).field_name  := 'FROM_REPLENSIHMENT_MO'; --22
        g_main_tab(23).field_value := NULL;
        g_main_tab(24).field_name  := 'FROM_REQUISITION'; --23
        g_main_tab(24).field_value := NULL;
        g_main_tab(25).field_name  := 'FROM_REQUISITION_HEADER_ID'; --24
        g_main_tab(25).field_value := NULL;
        g_main_tab(26).field_name  := 'FROM_RMA'; --25
        g_main_tab(26).field_value := NULL;
        g_main_tab(27).field_name  := 'FROM_RMA_HEADER_ID'; --26
        g_main_tab(27).field_value := NULL;
        g_main_tab(28).field_name  := 'FROM_SALES_ORDER_ID'; --27
        g_main_tab(28).field_value := NULL;
        g_main_tab(29).field_name  := 'FROM_SHIPMENT'; --28
        g_main_tab(29).field_value := NULL;
        g_main_tab(30).field_name  := 'FROM_SHIPMENT_DATE'; --29
        g_main_tab(30).field_value := NULL;
        g_main_tab(31).field_name  := 'FROM_START_DATE'; --30
        g_main_tab(31).field_value := NULL;
        g_main_tab(32).field_name  := 'FROM_TASK_PRIORITY'; --31
        g_main_tab(32).field_value := NULL;
        g_main_tab(33).field_name  := 'FROM_TASK_QUANTITY'; --32
        g_main_tab(33).field_value := NULL;
        g_main_tab(34).field_name  := 'FROM_TRANSFER_ISSUE_MO'; --33
        g_main_tab(34).field_value := NULL;
        g_main_tab(35).field_name  := 'INBOUND'; --34
        g_main_tab(35).field_value := FND_API.G_FALSE;
        g_main_tab(36).field_name  := 'INDEPENDENT_TASKS'; --35
        g_main_tab(36).field_value := FND_API.G_TRUE;
        g_main_tab(37).field_name  := 'INVENTORY_ITEM_ID'; --36
        g_main_tab(37).field_value := NULL;
        g_main_tab(38).field_name  := 'ITEM_CATEGORY_ID'; --37
        g_main_tab(38).field_value := NULL;
        g_main_tab(39).field_name  := 'LOADED'; --38
        g_main_tab(39).field_value := FND_API.G_FALSE;
        g_main_tab(40).field_name  := 'LOCATOR_ID'; --39
        g_main_tab(40).field_value := NULL;
        g_main_tab(41).field_name  := 'LPN_PUTAWAY_TASKS'; --40
        g_main_tab(41).field_value := FND_API.G_TRUE;
        g_main_tab(42).field_name  := 'MANUFACTURING'; --41
        g_main_tab(42).field_value := FND_API.G_FALSE;
        g_main_tab(43).field_name  := 'MANUFACTURING_TYPE'; --42
        g_main_tab(43).field_value := NULL;
        g_main_tab(44).field_name  := 'MO_ISSUE_TASKS'; --43
        g_main_tab(44).field_value := FND_API.G_TRUE;
        g_main_tab(45).field_name  := 'MO_TRANSFER_TASKS'; --44
        g_main_tab(45).field_value := FND_API.G_TRUE;
        g_main_tab(46).field_name  := 'OP_PLAN_ACTIVITY_ID'; --45
        g_main_tab(46).field_value := NULL;
        g_main_tab(47).field_name  := 'OP_PLAN_ID'; --46
        g_main_tab(47).field_value := NULL;
        g_main_tab(48).field_name  := 'OP_PLAN_TYPE_ID'; --47
        g_main_tab(48).field_value := NULL;
        ---add ORDER_TYPE
        g_main_tab(49).field_name  := 'ORDER_TYPE';
        g_main_tab(49).field_value := NULL;
        g_main_tab(50).field_name  := 'OUTBOUND';  ---48
        g_main_tab(50).field_value := FND_API.G_FALSE;
        g_main_tab(51).field_name  := 'PENDING'; --49
        g_main_tab(51).field_value := FND_API.G_FALSE;
        g_main_tab(52).field_name  := 'PERSON_RESOURCE_ID'; --50
        g_main_tab(52).field_value := NULL;
        g_main_tab(53).field_name  := 'PLAN_ABORTED'; --51
        g_main_tab(53).field_value := FND_API.G_FALSE;
        g_main_tab(54).field_name  := 'PLAN_CANCELLED'; --52
        g_main_tab(54).field_value := FND_API.G_FALSE;
        g_main_tab(55).field_name  := 'PLAN_COMPLETED'; --53
        g_main_tab(55).field_value := FND_API.G_FALSE;
        g_main_tab(56).field_name  := 'PLAN_IN_PROGRESS'; --54
        g_main_tab(56).field_value := FND_API.G_FALSE;
        g_main_tab(57).field_name  := 'PLAN_PENDING'; --55
        g_main_tab(57).field_value := FND_API.G_FALSE;
        g_main_tab(58).field_name  := 'PLANNED_TASKS'; --56
        g_main_tab(58).field_value := FND_API.G_TRUE;
        g_main_tab(59).field_name  := 'QUEUED'; --57
        g_main_tab(59).field_value := FND_API.G_FALSE;
        g_main_tab(60).field_name  := 'REPLENISHMENT_TASKS'; --58
        g_main_tab(60).field_value := FND_API.G_TRUE;
        g_main_tab(61).field_name  := 'SHIP_METHOD_CODE'; --59
        g_main_tab(61).field_value := NULL;
        g_main_tab(62).field_name  := 'SHIP_TO_COUNTRY'; --60
        g_main_tab(62).field_value := NULL;
        g_main_tab(63).field_name  := 'SHIP_TO_POSTAL_CODE'; --61
        g_main_tab(63).field_value := NULL;
        g_main_tab(64).field_name  := 'SHIP_TO_STATE'; --62
        g_main_tab(64).field_value := NULL;
        g_main_tab(65).field_name  := 'SHIPMENT_PRIORITY'; --63
        g_main_tab(65).field_value := NULL;
        g_main_tab(66).field_name  := 'STAGING_MOVE'; --64
        g_main_tab(66).field_value := FND_API.G_FALSE;
        g_main_tab(67).field_name  := 'SUBINVENTORY'; --65
        g_main_tab(67).field_value := NULL;
        g_main_tab(68).field_name  := 'TO_CREATION_DATE'; --66
        g_main_tab(68).field_value := NULL;
        g_main_tab(69).field_name  := 'TO_JOB'; --67
        g_main_tab(69).field_value := NULL;
        g_main_tab(70).field_name  := 'TO_LINE'; --68
        g_main_tab(70).field_value := NULL;
        g_main_tab(71).field_name  := 'TO_LINES_IN_SALES_ORDER'; --69
        g_main_tab(71).field_value := NULL;
        g_main_tab(72).field_name  := 'TO_LOCATOR_ID'; --70
        g_main_tab(72).field_value := NULL;
        g_main_tab(73).field_name  := 'TO_PICK_SLIP'; --71
        g_main_tab(73).field_value := NULL;
        g_main_tab(74).field_name  := 'TO_PO_HEADER_ID'; --72
        g_main_tab(74).field_value := NULL;
        g_main_tab(75).field_name  := 'TO_PURCHASE_ORDER'; --73
        g_main_tab(75).field_value := NULL;
        g_main_tab(76).field_name  := 'TO_REPLENSIHMENT_MO'; --74
        g_main_tab(76).field_value := NULL;
        g_main_tab(77).field_name  := 'TO_REQUISITION'; --75
        g_main_tab(77).field_value := NULL;
        g_main_tab(78).field_name  := 'TO_REQUISITION_HEADER_ID';--76
        g_main_tab(78).field_value := NULL;
        g_main_tab(79).field_name  := 'TO_RMA'; --77
        g_main_tab(79).field_value := NULL;
        g_main_tab(80).field_name  := 'TO_RMA_HEADER_ID'; --78
        g_main_tab(80).field_value := NULL;
        g_main_tab(81).field_name  := 'TO_SALES_ORDER_ID'; --79
        g_main_tab(81).field_value := NULL;
        g_main_tab(82).field_name  := 'TO_SHIPMENT'; --80
        g_main_tab(82).field_value := NULL;
        g_main_tab(83).field_name  := 'TO_SHIPMENT_DATE'; --81
        g_main_tab(83).field_value := NULL;
        g_main_tab(84).field_name  := 'TO_START_DATE'; --82
        g_main_tab(84).field_value := NULL;
        g_main_tab(85).field_name  := 'TO_SUBINVENTORY'; --83
        g_main_tab(85).field_value := NULL;
        g_main_tab(86).field_name  := 'TO_TASK_PRIORITY'; --84
        g_main_tab(86).field_value := NULL;
        g_main_tab(87).field_name  := 'TO_TASK_QUANTITY'; --85
        g_main_tab(87).field_value := NULL;
        g_main_tab(88).field_name  := 'TO_TRANSFER_ISSUE_MO'; --86
        g_main_tab(88).field_value := NULL;
        g_main_tab(89).field_name  := 'TRIP_ID'; --87
        g_main_tab(89).field_value := NULL;
        g_main_tab(90).field_name  := 'UNRELEASED'; --88
        g_main_tab(90).field_value := FND_API.G_FALSE;
        g_main_tab(91).field_name  := 'USER_TASK_TYPE_ID'; --89
        g_main_tab(91).field_value := NULL;
        g_main_tab(92).field_name  := 'WAREHOUSING'; --90
        g_main_tab(92).field_value := FND_API.G_FALSE;
	g_main_tab(93).field_name  := 'CROSSDOCK'; --91--Munish added column for crossdock
        g_main_tab(93).field_value := FND_API.G_FALSE; --Munish initialized column value for crossdock
END initialize_main_table;

-------------------------------------------------------------------------------------------------------------------
/*Procedure to log error message to the x_updated_tasks rec*/
-------------------------------------------------------------------------------------------------------------------

PROCEDURE log_error(p_transaction_number IN NUMBER DEFAULT NULL ,
		    p_task_table IN WMS_TASK_MGMT_PUB.task_tab_type ,
		    p_error_msg IN VARCHAR2 ,
		    x_updated_tasks OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type) IS

BEGIN
        IF p_transaction_number is NOT NULL THEN
                x_updated_tasks(1).RESULT := 'E';
                x_updated_tasks(1).ERROR  := p_error_msg;
        ELSIF p_task_table.COUNT           > 0 THEN
                FOR i                     in 1..p_task_table.COUNT
                LOOP
                        x_updated_tasks(i).RESULT := 'E';
                        x_updated_tasks(i).ERROR  := p_error_msg;
                END LOOP;
        END IF;
END log_error;
--------------------------------------------------------------------------------------------------------
/* Check Cartonization API checks if the cartonization_id can be stamped on the
   set of input tasks.
   Even if any one of the task fail validation, the API returns error.
*/
--------------------------------------------------------------------------------------------------------
PROCEDURE check_cartonization ( p_task_table IN WMS_TASK_MGMT_PUB.task_tab_type ,
				p_new_carton_lpn_id IN NUMBER DEFAULT NULL ,
				x_error_msg OUT NOCOPY VARCHAR2 ,
				x_return_status OUT NOCOPY VARCHAR2 )
IS
        CURSOR carton_lpn_csr(c_lpn_id NUMBER)
        IS
                SELECT  lpn_context,
                        organization_id,
			inventory_item_id
                FROM    wms_license_plate_numbers wlpn
                WHERE   wlpn.lpn_id=c_lpn_id;

        CURSOR carton_lpn_del_det (c_lpn_id NUMBER)
        IS
                SELECT  wdd.delivery_detail_id,
                        wdd.move_order_line_id
                FROM    wsh_delivery_details wdd,
                        mtl_material_transactions_temp mmtt
                WHERE   wdd.move_order_line_id=mmtt.move_order_line_id
                    AND wdd.organization_id   =mmtt.organization_id
                    AND (mmtt.transfer_lpn_id  =c_lpn_id
		         OR mmtt.cartonization_id = c_lpn_id);

--                  AND ROWNUM                < 2;
/*        CURSOR carton_lpn_del_det1 (c_lpn_id NUMBER)
        IS
                SELECT  wdd.delivery_detail_id,
                        wdd.move_order_line_id
                FROM    wsh_delivery_details wdd,
                        mtl_material_transactions_temp mmtt
                WHERE   wdd.move_order_line_id=mmtt.move_order_line_id
                    AND wdd.organization_id   =mmtt.organization_id
                    AND mmtt.cartonization_id = c_lpn_id
                    AND ROWNUM                = 1;*/
        CURSOR c_get_delivery_id(p_delivery_detail_id NUMBER)
        IS
                SELECT  delivery_id
                FROM    wsh_delivery_assignments
                WHERE   delivery_detail_id = p_delivery_detail_id;
        CURSOR c_bulk_task(p_transaction_number NUMBER)
        IS
                SELECT '1'
                FROM    mtl_material_transactions_temp
                WHERE   parent_line_id = p_transaction_number
                AND rownum         = 1;

        l_carton_lpn_ctx            NUMBER;
        l_carton_lpn_org            NUMBER;
        l_carton_del_det_id         NUMBER;
        l_carton_del_id             NUMBER;
        l_carton_move_order_line_id NUMBER;
        l_temp_carton_grp_id        NUMBER;
        l_carton_grp_id_tab WSH_UTIL_CORE.id_tab_type;
        l_del_det_id_tab WSH_UTIL_CORE.id_tab_type;
	l_del_det_id_no_del_tab WSH_UTIL_CORE.id_tab_type;
        l_del_id_tab WSH_UTIL_CORE.id_tab_type;
        l_move_order_line_id_tab WSH_UTIL_CORE.id_tab_type;
        l_bulk_task          VARCHAR2(2);
        l_temp_del_detail_id NUMBER;
        l_move_order_line_id NUMBER;
        l_temp_del_id        NUMBER;
        l_debug              NUMBER         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
        l_api_name           VARCHAR2(1000) := 'CHECK_CARTONIZATION';
        l_error_msg          VARCHAR2(2000);
        l_msg_count          NUMBER;
	p_action_prms       WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
	l_validation_level          NUMBER;
	l_grouping_rows            WSH_UTIL_CORE.id_tab_type;
	l_del_id_tab_new WSH_UTIL_CORE.id_tab_type;
	l_return_status    VARCHAR2(10);
	l_msg_data         varchar2(1000);
	l_delivery_name   VARCHAR2(30) := NULL;
	l_delivery_id     NUMBER;
	l_carton_lpn_itm_id   NUMBER;

BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
        OPEN carton_lpn_csr(p_new_carton_lpn_id);
        FETCH carton_lpn_csr INTO l_carton_lpn_ctx,l_carton_lpn_org,l_carton_lpn_itm_id;
        CLOSE carton_lpn_csr;
        --if carton lpn is passed and is not valid then no need to proceed further
        IF(l_carton_lpn_ctx NOT IN (5,8)) THEN
                x_return_status := fnd_api.g_ret_sts_error;
                fnd_message.set_name('WMS', 'WMS_CARTON_LPN_CTX_ERR');
                fnd_msg_pub.ADD;
                fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE, p_count => l_msg_count, p_data => x_error_msg );
                l_error_msg                      :='Invalid context for Carton LPN:'||p_new_carton_lpn_id;
                IF(l_debug                        = 1) THEN
                        inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                END IF;
                RETURN;
	ELSIF (l_carton_lpn_itm_id is NULL) THEN
                x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('WMS', 'WMS_CARTONIZATION_ERR');
		fnd_msg_pub.ADD;
		fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE, p_count => l_msg_count, p_data => x_error_msg );
                l_error_msg                      :='Inventory item id is not present in carton LPN';
                IF(l_debug                        = 1) THEN
                        inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                END IF;
                RETURN;
        END IF;

/*        IF (l_carton_lpn_ctx = 5 ) THEN
                OPEN carton_lpn_del_det1(p_new_carton_lpn_id);
                FETCH   carton_lpn_del_det1
                INTO    l_carton_del_det_id,
                        l_carton_move_order_line_id;
                CLOSE carton_lpn_del_det1;
                IF (l_carton_del_det_id is NOT NULL and l_carton_move_order_line_id is NOT NULL) THEN
                        l_del_det_id_tab(l_del_det_id_tab.count                +1) := l_carton_del_det_id;
                        l_move_order_line_id_tab(l_move_order_line_id_tab.count+1) := l_carton_move_order_line_id;
                END IF;
        END IF;*/
        IF (l_carton_lpn_ctx in (5,8) ) THEN
                --get carton del_det_id and mover_oder_line_id
                OPEN carton_lpn_del_det(p_new_carton_lpn_id);
		LOOP
                FETCH carton_lpn_del_det
		INTO l_carton_del_det_id,
		     l_carton_move_order_line_id;

		l_del_det_id_tab(l_del_det_id_tab.count                +1) := l_carton_del_det_id;
                l_move_order_line_id_tab(l_move_order_line_id_tab.count+1) := l_carton_move_order_line_id;
		EXIT WHEN carton_lpn_del_det%NOTFOUND;
		END LOOP;

                CLOSE carton_lpn_del_det;

        END IF;
        FOR i IN 1..p_task_table.count
        LOOP
                IF (p_task_table(i).organization_id <> l_carton_lpn_org) THEN
                        x_return_status             := fnd_api.g_ret_sts_error;
                        fnd_message.set_name('WMS', 'WMS_CARTON_LPN_ORG_ERR');
                        fnd_msg_pub.ADD;
                        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE, p_count => l_msg_count, p_data => x_error_msg );
                        l_error_msg                      :='Organization is not same for Carton LPN and Task';
                        IF(l_debug                        = 1) THEN
                                inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                        END IF;
                        RETURN;
                END IF;
                --Bulk tasks cannot be cartonized
                OPEN c_bulk_task(p_task_table(i).transaction_number);
                FETCH c_bulk_task INTO l_bulk_task;
                IF c_bulk_task%NOTFOUND THEN
                        CLOSE c_bulk_task;
                ELSE
                        x_return_status := fnd_api.g_ret_sts_error;
                        fnd_message.set_name('WMS', 'WMS_CARTON_BULK_ERR');
                        fnd_msg_pub.ADD;
                        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE, p_count => l_msg_count, p_data => x_error_msg );
                        l_error_msg                      :='Bulk Tasks cannot be cartonized';
                        IF(l_debug                        = 1) THEN
                                inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                        END IF;
                        CLOSE c_bulk_task;
                        RETURN;
                END IF;
        END LOOP;
        --Fetch the delivery_detail_id's and move order line id's associated with the input task/tasks.
        FOR i IN 1..p_task_table.count
        LOOP
                BEGIN
                        SELECT  wdd.delivery_detail_id,
                                wdd.move_order_line_id
                        INTO    l_temp_del_detail_id,
                                l_move_order_line_id
                        FROM    wsh_delivery_details wdd,
                                mtl_material_transactions_temp mmtt
                        WHERE   wdd.move_order_line_id   = mmtt.move_order_line_id
                            AND mmtt.transaction_temp_id = p_task_table(i).transaction_number;
                EXCEPTION
                WHEN OTHERS THEN
                        l_temp_del_detail_id := NULL;
                END;
                IF (l_temp_del_detail_id IS NULL) THEN
                        x_return_status := fnd_api.g_ret_sts_error;
                        fnd_message.set_name('WMS', 'WMS_CARTONIZATION_ERR');
                        fnd_msg_pub.ADD;
                        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => x_error_msg );
                        l_error_msg                      :='Data not present in WDD for the corresponding task :'||p_task_table(i).transaction_number;
                        IF(l_debug                        = 1) THEN
                                inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                        END IF;
                        RETURN;
                ELSE
                        l_del_det_id_tab(l_del_det_id_tab.count                +1) := l_temp_del_detail_id;
                        l_move_order_line_id_tab(l_move_order_line_id_tab.count+1) := l_move_order_line_id;
                END IF;
        END LOOP;
        --Fetch the delivery_id associated with the tasks.
        FOR i IN 1..l_del_det_id_tab.COUNT
        LOOP
                BEGIN
                        SELECT  delivery_id
                        INTO    l_temp_del_id
                        FROM    wsh_delivery_assignments
                        WHERE   delivery_detail_id = l_del_det_id_tab(i);
                EXCEPTION
                WHEN OTHERS THEN
                        l_temp_del_id := NULL;
			--fetch the dd id's with null delivery_id into l_del_det_id_no_del_tab.
			l_del_det_id_no_del_tab(l_del_det_id_no_del_tab.count+1) := l_del_det_id_tab(i);
                END;
                l_del_id_tab(l_del_id_tab.count +1) := l_temp_del_id;
        END LOOP;
        --Need to check if all the deliveries are same or not.
        --This needs to be done only if count of delivery_detail_id is >1.
        IF l_del_det_id_tab.COUNT > 1 THEN
                FOR i            IN 1..l_del_id_tab.COUNT
                LOOP
			IF (l_del_id_tab(i) is NOT NULL) THEN
			     --copy the value to a new structure
			     l_del_id_tab_new(l_del_id_tab_new.count +1) := l_del_id_tab(i);
			END IF;
		END LOOP;

	        IF (l_del_id_tab_new.COUNT = 0) THEN
		   --all the delivery_id's are null,
		   --Call delivery_grouping API.

		   WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping( p_line_rows     => l_del_det_id_tab,
                                    x_grouping_rows => l_grouping_rows,
                                    x_return_status => l_return_status);

	          IF l_return_status = 'S' then
		    -- check if all the values in l_grouping_rows are same.
		     FOR i in 1..l_grouping_rows.COUNT LOOP
			   IF (l_grouping_rows(1) <> l_grouping_rows(i)) THEN
                                x_return_status      := fnd_api.g_ret_sts_error;
                                fnd_message.set_name('WMS', 'WMS_CARTON_DEL_GP_ERR');
                                fnd_msg_pub.ADD;
                                fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => x_error_msg );
                                l_error_msg                      :='Delivery grouping mismatch,cartonization cannot be done';
                                IF(l_debug                        = 1) THEN
                                        inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                                END IF;
                                RETURN;
		            END IF;
		   END LOOP;

		  END IF;

		ELSE --l_del_id_Tab_new.count > 0
		   --check if the delivery_id's that are present in l_del_id_tab_new are all same.
                   FOR i in 1..l_del_id_tab_new.COUNT LOOP
			   IF (l_del_id_tab_new(1) <> l_del_id_tab_new(i)) THEN
                                x_return_status      := fnd_api.g_ret_sts_error;
                                fnd_message.set_name('WMS', 'WMS_CARTON_DEL_ERR');
                                fnd_msg_pub.ADD;
                                fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => x_error_msg );
                                l_error_msg                      :='Delivery mismatch,cartonization cannot be done';
                                IF(l_debug                        = 1) THEN
                                        inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                                END IF;
                                RETURN;
		            END IF;
		   END LOOP;
		   --del_id's present are all same.
		   --call WSH API by passing deliery_id from l_del_id_tab_new and l_del_det_id_no_del_tab
		   --and see if the same delivery_id can be stamped on the null delivery records.
		   --This needs to be done only if there are some delivery_detail_ids for which there is
		   --no delivery association.
		   IF (l_del_det_id_no_del_tab.COUNT > 0 ) THEN

			l_delivery_id := l_del_id_tab_new(1);

			wsh_delivery_details_grp.detail_to_delivery(
				p_api_version        =>    1.0,
				p_init_msg_list      =>    FND_API.G_FALSE,
				p_commit             =>    FND_API.G_FALSE,
				p_validation_level   =>    l_validation_level,
				x_return_status      =>    l_return_status,
				x_msg_count          =>    l_msg_count,
				x_msg_data           =>    l_msg_data,
				p_TabOfDelDets       =>    l_del_det_id_no_del_tab,
				p_action             =>    'ASSIGN',
				p_delivery_id        =>    l_delivery_id,
				p_delivery_name      =>    l_delivery_name,
				p_action_prms        =>    p_action_prms);

		        IF l_return_status <> 'S' THEN
				fnd_message.set_name('WMS', 'WMS_CARTONIZATION_ERR');
                                fnd_msg_pub.ADD;
                                fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => x_error_msg );
                                l_error_msg                      :='Error returned from WSH API';
                                IF(l_debug                        = 1) THEN
                                        inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                                END IF;
				RETURN;
		        END IF;
		   END IF;
                END IF;
        END IF;

END check_cartonization;
-------------------------------------------------------------------------------------------------------------------
/*This procedure checks if the various attributes that are passed can be updated
on the provided task*/
-------------------------------------------------------------------------------------------------------------------

PROCEDURE modify_single_task( p_task_rec IN WMS_TASK_MGMT_PUB.task_output_rectype,
        P_new_task_status                IN NUMBER DEFAULT NULL,
        P_new_task_priority              IN NUMBER DEFAULT NULL,
        P_new_task_type                  IN VARCHAR2 DEFAULT NULL,
        P_new_carton_lpn_id              IN NUMBER DEFAULT NULL,
        p_new_operation_plan_id          IN NUMBER DEFAULT NULL,
        p_output_task_rec OUT NOCOPY WMS_TASK_MGMT_PUB.task_output_rectype,
        p_op_plan_rec IN WMS_TASK_MGMT_PUB.op_plan_rec)
IS
        l_lpn              VARCHAR2(30);
        l_return_status    VARCHAR2(10);
        l_count NUMBER DEFAULT 0;
        l_operation_plan_type_id NUMBER;
        l_msg_data         fnd_new_messages.MESSAGE_TEXT%TYPE;
        l_msg_count        NUMBER;
        l_error_code       NUMBER;
        l_std_task_type    NUMBER;
        l_usr_task_type_id NUMBER;
        l_err_msg          VARCHAR2(240);
        l_debug            NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
        l_api_name VARCHAR2(1000) := 'MODIFY_SINGLE_TASK';
        l_msg      VARCHAR2(2000);

	Cursor c_usr_task_type(p_std_task_type NUMBER,
                p_operation_code               VARCHAR2,
		p_org_id                       NUMBER) IS
		SELECT  standard_operation_id
                FROM    BOM_STANDARD_OPERATIONS_V
                WHERE   wms_task_type  = p_std_task_type
                AND operation_code = p_operation_code
		AND organization_id    = p_org_id    ;

    --operation plan code changes start 6888354

    CURSOR c_plan_detail(v_operation_plan_id NUMBER) IS
     SELECT  operation_plan_detail_id
           , operation_sequence
           , is_in_inventory
           , operation_type
     FROM WMS_OP_PLAN_DETAILS
     WHERE operation_plan_id  = v_operation_plan_id
     AND   operation_sequence = (SELECT MIN(operation_sequence)
                                       FROM WMS_OP_PLAN_DETAILS
                                      WHERE operation_plan_id=v_operation_plan_id);

    CURSOR C_OP_PLANS_B(v_operation_plan_id NUMBER) IS
     SELECT  OPERATION_PLAN_ID,
             SYSTEM_TASK_TYPE,
             ACTIVITY_TYPE_ID,
             PLAN_TYPE_ID
     FROM WMS_OP_PLANS_B
     WHERE operation_plan_id=v_operation_plan_id;

     CURSOR C_OP_OPERATIONS_STATUS(v_source_task_id NUMBER) IS
	    SELECT STATUS   FROM    wms_op_plan_instances
	    WHERE   ((
		      source_task_id in
		    (SELECT parent_line_id
		    FROM    mtl_material_transactions_temp
		    WHERE   transaction_temp_id =v_source_task_id
		      )) OR (source_task_id =v_source_task_id )); ---contains parent only

    l_op_plan_b_rec                 C_OP_PLANS_B%ROWTYPE;
    l_operation_plan_detail_rec     c_plan_detail%ROWTYPE;
    l_op_operation_status_rec       C_OP_OPERATIONS_STATUS%ROWTYPE;
    l_src_tran_id    NUMBER;
    l_src_parent_id    NUMBER;

    --operation plan code changes end  6888354


BEGIN
--6888354 START
IF (p_task_rec.status_id = 9 ) THEN
        /*If the original task status is Active, check if the user whom the tasks
        assigned is logged on to the system. If the user is logged on, updating the same is not allowed. */
        BEGIN
                SELECT  COUNT(*)
                INTO    l_count
                FROM    WMS_DISPATCHED_TASKS wdt1
                WHERE   wdt1.status              = 9
                    AND wdt1.TRANSACTION_TEMP_ID =p_task_rec.TRANSACTION_NUMBER
                    AND EXISTS
                        (SELECT 1
                        FROM    MTL_MOBILE_LOGIN_HIST MMLH,
                                WMS_DISPATCHED_TASKS wdt
                        WHERE   wdt1.TRANSACTION_TEMP_ID = wdt.TRANSACTION_TEMP_ID
                            AND MMLH.USER_ID             = wdt1.LAST_UPDATED_BY
                            AND MMLH.LOGOFF_DATE        IS NULL
                            AND MMLH.EVENT_MESSAGE      IS NULL
                        );
        EXCEPTION
        WHEN OTHERS THEN
                NULL;
                l_msg     := 'Error in querying Active tasks';
                IF(l_debug = 1) THEN
                        inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                END IF;
                p_output_task_rec.RESULT := 'E';
                p_output_task_rec.ERROR  := l_err_msg;
                RETURN;
        END;
        IF l_count > 0 THEN
                fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');--new message  WMS_ATF_ACTIVE_TASK_EXP
                fnd_msg_pub.ADD;
                fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                l_msg                              := 'Active task can be updated if tasks assigned to user is logged off the system';
                IF(l_debug                          = 1) THEN
                        inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                END IF;
                p_output_task_rec.RESULT := 'E';
                p_output_task_rec.ERROR  := l_err_msg;
                RETURN;
        END IF;
ELSIF (p_task_rec.status_id      = 3 ) THEN
		/*A task can be in dispatched status when a group of tasks are dispatched to a mobile user
		and one of the tasks in the group is in ACTIVE status and the rest in DISPATCHED status.
		Updating such dispatched tasks to pending/unreleased status SHOULD NOT be allowed. */
		BEGIN
				SELECT  COUNT(*)
				INTO    l_count
				FROM    mtl_material_transactions_temp mmtt,
						WMS_DISPATCHED_TASKS wdt
				WHERE   mmtt.transaction_temp_id = wdt.transaction_temp_id
				AND wdt.transaction_temp_id  =p_task_rec.TRANSACTION_NUMBER
				AND wdt.status               = 3
				AND EXISTS
					(SELECT 1
					FROM    WMS_DISPATCHED_TASKS wdt2
					WHERE   wdt2.person_id            = p_task_rec.PERSON_ID
						AND wdt2.status               = 9
						AND wdt2.task_method         IS NOT NULL
						AND wdt2.transaction_temp_id IN
						(SELECT transaction_temp_id
						FROM    mtl_material_transactions_temp mmtt1
						WHERE
						DECODE(wdt.TASK_METHOD, 'CARTON', mmtt1.cartonization_id, 'PICK_SLIP', mmtt1.pick_slip_number, 'DISCRETE', mmtt1.pick_slip_number, mmtt1.transaction_source_id) =
						DECODE(wdt.TASK_METHOD, 'CARTON', mmtt.cartonization_id, 'PICK_SLIP', mmtt.pick_slip_number, 'DISCRETE', mmtt.pick_slip_number, mmtt.transaction_source_id)
						)
					);
		EXCEPTION
		WHEN OTHERS THEN
				NULL;
				l_msg     := 'Error in querying Dispatched tasks';
				IF(l_debug = 1) THEN
						inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
				END IF;
				p_output_task_rec.RESULT := 'E';
				p_output_task_rec.ERROR  := l_err_msg;
				RETURN;
		END;
		IF (l_count > 0 ) THEN                                             --ANY OF GROUP TASK IS active
				fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');--new message    WMS_ATF_DISPATCH_TASK_EXP
				fnd_msg_pub.ADD;
				fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
				l_msg                              := 'Dispatcher task can be updated only if any of the task in group is not in Active status';
				IF(l_debug                          = 1) THEN
						inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
				END IF;
				p_output_task_rec.RESULT := 'E';
				p_output_task_rec.ERROR  := l_err_msg;
				RETURN;
		END IF;
END IF;

        IF (p_new_task_status IS NOT NULL) THEN
                --check the current task status and then only do the updated.
                --status_id = 1==>Pending,2==>Qued,8==>Unreleased,9==>Active.
                 IF (p_task_rec.status_id = 9 ) THEN
                      IF p_new_task_status  in (1,8) THEN
                           p_output_task_rec.status_id := p_new_task_status;
                      ELSE
                          fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');
                          fnd_msg_pub.ADD;
                          fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                          l_msg                            := 'Active task can be moved only to Pending or Unreleased state';
                          IF(l_debug                        = 1) THEN
                                  inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                          END IF;
                          p_output_task_rec.RESULT := 'E';
                          p_output_task_rec.ERROR  := l_err_msg;
                          RETURN;
                      END IF;
	                 ELSIF (p_task_rec.status_id = 3 ) THEN
                      IF p_new_task_status  in (1,8) THEN
                         p_output_task_rec.status_id := p_new_task_status;
                      ELSE
                          fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');
                          fnd_msg_pub.ADD;
                          fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                          l_msg                            := 'Dispatcher task can be moved only to Pending or Unreleased state';
                          IF(l_debug                        = 1) THEN
                                  inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                          END IF;
                          p_output_task_rec.RESULT := 'E';
                          p_output_task_rec.ERROR  := l_err_msg;
                          RETURN;
                      END IF; --6888354 END
                 ELSIF (p_task_rec.status_id = 8 ) THEN
                      IF (p_new_task_status =1 OR (p_new_task_status = 2 AND p_task_rec.task_type_id <> 2 ))THEN
                          p_output_task_rec.status_id := p_new_task_status;
                      ELSE
                          fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');
                          fnd_msg_pub.ADD;
                          fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                          l_msg                            := 'Unreleased task can be moved only to Pending or Queued state';
                          IF(l_debug                        = 1) THEN
                                  inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                          END IF;
                          p_output_task_rec.RESULT := 'E';
                          p_output_task_rec.ERROR  := l_err_msg;
                          RETURN;
                      END IF;
                 ELSIF (p_task_rec.status_id = 1 ) THEN
                      IF ( p_new_task_status = 2 AND p_task_rec.task_type_id <> 2 )THEN
                          p_output_task_rec.status_id := p_new_task_status;
                      ELSE
                          fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');
                          fnd_msg_pub.ADD;
                          fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                          l_msg                            := 'Pending task can be moved only to Queued state';
                          IF(l_debug                        = 1) THEN
                                  inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                          END IF;
                          p_output_task_rec.RESULT := 'E';
                          p_output_task_rec.ERROR  := l_err_msg;
                          RETURN;
                      END IF;
 	         ELSE
                          fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');
                          fnd_msg_pub.ADD;
                          fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                          l_msg                            := 'Invalid task status';
                          IF(l_debug                        = 1) THEN
                                  inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                          END IF;
                          p_output_task_rec.RESULT := 'E';
                          p_output_task_rec.ERROR  := l_err_msg;
                          RETURN;
                 END IF;

        END IF;

	IF (P_new_task_priority IS NOT NULL) THEN
		IF (p_task_rec.task_type_id <> 2) THEN
		        p_output_task_rec.priority := p_new_task_priority;
		ELSE
			fnd_message.set_name('WMS', 'WMS_INVALID_TASK');
			fnd_msg_pub.ADD;
			fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
			l_msg                            := 'Inbound task priority cannot be updated';
			IF(l_debug                        = 1) THEN
				inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
			END IF;
			p_output_task_rec.RESULT := 'E';
			p_output_task_rec.ERROR  := l_err_msg;
			RETURN;
		END IF;
        END IF;

        IF (P_new_carton_lpn_id IS NOT NULL) THEN
                SELECT  license_plate_number
                INTO    l_lpn
                FROM    wms_license_plate_numbers
                WHERE   lpn_id                       =P_new_carton_lpn_id;
                p_output_task_rec.cartonization_lpn := l_lpn;
                p_output_task_rec.cartonization_id  := P_new_carton_lpn_id;
        END IF;
        IF (P_new_task_type IS NOT NULL) THEN
                OPEN c_usr_task_type(p_task_rec.task_type_id,p_new_task_type,p_task_rec.organization_id);
                FETCH c_usr_task_type INTO l_usr_task_type_id;
                IF c_usr_task_type%NOTFOUND THEN
                        fnd_message.set_name('WMS', 'WMS_INVALID_USER_TASK');--new message
                        fnd_msg_pub.ADD;
                        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                        l_msg                            := 'Standard task type associated with the user task is different from the current standard task type';
                        IF(l_debug                        = 1) THEN
                                inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                        END IF;
                        p_output_task_rec.RESULT := 'E';
                        p_output_task_rec.ERROR  := l_err_msg;
                        RETURN;
                ELSE
                        p_output_task_rec.user_task_type_id := l_usr_task_type_id;
                END IF;
                CLOSE c_usr_task_type;
        END IF;
        IF (p_new_operation_plan_id IS NOT NULL) THEN
            IF (p_op_plan_rec.organization_id IS NOT NULL) THEN
                IF (p_task_rec.organization_id             <> p_op_plan_rec.organization_id) THEN
                        IF(p_op_plan_rec.common_to_all_org <> 'Y') THEN
                                fnd_message.set_name('WMS', 'WMS_OPER_PLAN_ORG_INVALID');--new message
                                fnd_msg_pub.ADD;
                                fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                                p_output_task_rec.RESULT         := 'E';
                                p_output_task_rec.ERROR          := l_err_msg;
                                l_msg                            := 'Organization associated with the operation plan is different from that of the task';
                                IF(l_debug                        = 1) THEN
                                        inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                                END IF;
                                RETURN;
                        END IF;
                END IF;
            END IF;

	    IF (p_task_rec.OPERATION_PLAN_ID IS NOT NULL  AND  p_op_plan_rec.plan_type_id IS NOT NULL) THEN
		    SELECT PLAN_TYPE_ID
		    INTO l_operation_plan_type_id
		    FROM wms_op_plans_b
		    WHERE OPERATION_PLAN_ID=p_task_rec.OPERATION_PLAN_ID;

		    IF (l_operation_plan_type_id IS NOT NULL ) THEN
			/*	An inspection operation plan can be replaced with another inspection operation plan and
			  like wise a standard operation plan can be replaced only with another Standard operation plan.   */
			/*only in case of cross dock tasks, a cross dock operation can be replaced with another cross dock operation plan or
			  it can also be replaced with a non-cross dock Operation plan    */
			  IF ( l_operation_plan_type_id   = 3  OR
			     ( p_op_plan_rec.plan_type_id = 1 AND l_operation_plan_type_id = 1) OR
			     ( p_op_plan_rec.plan_type_id = 2  AND  l_operation_plan_type_id = 2 )) THEN
				p_output_task_rec.operation_plan_id := p_new_operation_plan_id;
			  ELSE
			      fnd_message.set_name('WMS', 'WMS_OPERTN_PLAN_ID_INVALID');--new message
			      fnd_msg_pub.ADD;
			      fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
			      p_output_task_rec.RESULT         := 'E';
			      p_output_task_rec.ERROR          := l_err_msg;
			      l_msg                            := 'Inspection/Standard operation plan can only be replaced with another Inspection/Standard operation plan
								   and cross dock operation can be replaced with another cross dock operation plan or non-cross dock Operation plan ';
			      IF(l_debug                        = 1) THEN
				      inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
			      END IF;
			      RETURN;
			  END IF;
		    ELSE
			fnd_message.set_name('WMS', 'WMS_OPERTN_PLAN_ID_INVALID');--new message
			fnd_msg_pub.ADD;
			fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
			p_output_task_rec.RESULT         := 'E';
			p_output_task_rec.ERROR          := l_err_msg;
			l_msg                            := 'Current or new operation plan type is NULL';
			IF(l_debug                        = 1) THEN
				inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
			END IF;
			  RETURN;
		    END IF;
	    END IF;


            IF ( p_op_plan_rec.activity_type_id = 1) THEN                   --INBOUND CASE
                        IF(p_task_rec.task_type_id <> 2) THEN                   --putaway
                                fnd_message.set_name('WMS', 'WMS_INVALID_OP_PLAN_ACTIVITY');--new message
                                fnd_msg_pub.ADD;
                                fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                                p_output_task_rec.ERROR          := l_err_msg;
                                p_output_task_rec.RESULT         := 'E';
                                l_msg                            := 'Mismatch in the operation plan activity type and task type';
                                IF(l_debug                        = 1) THEN
                                        inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                                END IF;
                                RETURN;
                        ELSE
                           --operation plan  code changes start 6888354
                           BEGIN
                                   SAVEPOINT inb_op_sp;
                                   OPEN C_OP_OPERATIONS_STATUS(p_task_rec.transaction_number);
                                   FETCH   C_OP_OPERATIONS_STATUS
                                   INTO    l_op_operation_status_rec;
                                   IF (l_op_operation_status_rec.STATUS=1) THEN
                                           OPEN C_OP_PLANS_B(p_new_operation_plan_id);
                                           FETCH   C_OP_PLANS_B
                                           INTO    l_op_plan_b_rec;
                                           IF (C_OP_PLANS_B%NOTFOUND) THEN
                                                   IF (l_debug=1) THEN
                                                           inv_trx_util_pub.trace('Records not found in WMS_OP_PLANS_B for given p_new_operation_plan_id');
                                                           fnd_message.set_name('WMS', ' WMS_INVALID_TASK');--new message
                                                           fnd_msg_pub.ADD;
                                                           fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                                                           l_msg                              := 'No of Records found in WMS_OP_PLANS_B for given operation plan id';
                                                           IF(l_debug                          = 1) THEN
                                                                   inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                                                           END IF;
                                                           p_output_task_rec.RESULT := 'E';
                                                           p_output_task_rec.ERROR  := l_err_msg;
                                                           RETURN;
                                                   END IF;
                                                   CLOSE C_OP_PLANS_B;
                                           ELSE
                                                   inv_trx_util_pub.trace('updating wms_op_plan_instances.........');
                                                   UPDATE wms_op_plan_instances
                                                   SET     OPERATION_PLAN_ID=l_op_plan_b_rec.OPERATION_PLAN_ID,
                                                           -- SYSTEM_TASK_TYPE =l_op_plan_b_rec.SYSTEM_TASK_TYPE , Bug#8978253
                                                           ACTIVITY_TYPE_ID =l_op_plan_b_rec.ACTIVITY_TYPE_ID ,
                                                           PLAN_TYPE_ID     =l_op_plan_b_rec.PLAN_TYPE_ID
                                                   WHERE ((source_task_id  IN
                                                           (SELECT parent_line_id
                                                           FROM    mtl_material_transactions_temp
                                                           WHERE   transaction_temp_id=p_task_rec.transaction_number
                                                           ))
                                                        OR (source_task_id = p_task_rec.transaction_number)); --update parent records only
                                                   OPEN c_plan_detail(p_new_operation_plan_id);
                                                   FETCH   c_plan_detail
                                                   INTO    l_operation_plan_detail_rec;
                                                   IF (c_plan_detail%NOTFOUND) THEN
                                                           IF (l_debug=1) THEN
                                                                   inv_trx_util_pub.trace('Records not found in WMS_OP_PLAN_DETAILS for given operation plan id');
                                                                   fnd_message.set_name('WMS', ' WMS_INVALID_TASK');--new message
                                                                   fnd_msg_pub.ADD;
                                                                   fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                                                                   l_msg                              := 'No of Records found in WMS_OP_PLAN_DETAILS for given operation plan id';
                                                                   IF(l_debug                          = 1) THEN
                                                                           inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                                                                   END IF;
                                                                   p_output_task_rec.RESULT := 'E';
                                                                   p_output_task_rec.ERROR  := l_err_msg;
                                                                   RETURN;
                                                           END IF;
                                                           CLOSE c_plan_detail;
                                                   ELSE
                                                           inv_trx_util_pub.trace('updating wms_op_operation_instances.........');
                                                           UPDATE wms_op_operation_instances
                                                           --SET     OPERATION_TYPE          =l_operation_plan_detail_rec.OPERATION_TYPE           , Bug#8978253
                                                           SET     OPERATION_PLAN_DETAIL_ID=l_operation_plan_detail_rec.OPERATION_PLAN_DETAIL_ID ,
                                                                   OPERATION_SEQUENCE      =l_operation_plan_detail_rec.OPERATION_SEQUENCE       ,
                                                                   --ACTIVITY_TYPE=l_operation_plan_detail_rec.ACTIVITY_TYPE ,
                                                                   IS_IN_INVENTORY =l_operation_plan_detail_rec.IS_IN_INVENTORY
                                                           WHERE ((source_task_id IN
                                                                   (SELECT TRANSACTION_TEMP_ID
                                                                   FROM    mtl_material_transactions_temp
                                                                   WHERE   parent_line_id=p_task_rec.transaction_number
                                                                   ))
                                                                OR ( source_task_id =p_task_rec.transaction_number));--update all the children records only
                                                   END IF;
                                           END IF;

                                   ELSE
                                           fnd_message.set_name('WMS', ' WMS_INVALID_TASK');--new message
                                           fnd_msg_pub.ADD;
                                           fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                                           l_msg                              := 'STATUS in wms_op_plan_instances is not pending';
                                           IF(l_debug                          = 1) THEN
                                                   inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                                           END IF;
                                           p_output_task_rec.RESULT := 'E';
                                           p_output_task_rec.ERROR  := l_err_msg;
                                           RETURN;
                                   END IF; --  l_op_operation_status_rec.STATUS end

                                   SELECT  parent_line_id
                                   INTO    l_src_parent_id
                                   FROM    mtl_material_transactions_temp
                                   WHERE   TRANSACTION_TEMP_ID=p_task_rec.transaction_number;
                                   IF (l_src_parent_id       IS NULL) THEN
                                           l_src_tran_id     :=p_task_rec.transaction_number;
                                           UPDATE mtl_material_transactions_temp mmtt
                                           SET     mmtt.OPERATION_PLAN_ID=p_new_operation_plan_id
                                           WHERE   mmtt.PARENT_LINE_ID   = l_src_tran_id;--update child record
                                   ELSE
                                           l_src_tran_id:=l_src_parent_id;
                                           UPDATE mtl_material_transactions_temp mmtt
                                           SET     mmtt.OPERATION_PLAN_ID   =p_new_operation_plan_id
                                           WHERE   mmtt.TRANSACTION_TEMP_ID = l_src_tran_id;--update parent record
                                   END IF;                                                  --parent if end
                                   p_output_task_rec.operation_plan_id := p_new_operation_plan_id;

                           EXCEPTION
                           WHEN OTHERS THEN
                                   ROLLBACK TO inb_op_sp;
                                   p_output_task_rec.RESULT := 'E';
                                   inv_trx_util_pub.trace('Exception Occured while updating operation plan');
                                   RETURN;
                           END;
                        --operation plan  code changes end 6888354

                        END IF;
            ELSE --outbound case
                        --for outbound case wopi , wooi is not impacted as I could observe by creating records.
                        --just updating the plan id should be enough.needs to be  investigated further
                        IF (p_task_rec.task_type_id <> 1) THEN                  --if not a pick task then error out
                                fnd_message.set_name('WMS', 'WMS_INVALID_OP_PLAN_ACTIVITY');--new message
                                fnd_msg_pub.ADD;
                                fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_err_msg );
                                l_msg                            := 'Mismatch in the operation plan activity type and task type';
                                IF(l_debug                        = 1) THEN
                                        inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
                                END IF;
                                p_output_task_rec.RESULT := 'E';
                                p_output_task_rec.ERROR  := l_err_msg;
                                RETURN;
                        ELSE --update the mmtt with new plan
                                /*UPDATE mtl_material_transactions_temp
                                        SET operation_plan_id        = p_new_operation_plan_id
                                WHERE   transaction_temp_id          = p_task_rec.transaction_number;*/
                                p_output_task_rec.operation_plan_id := p_new_operation_plan_id;
                        END IF;
            END IF;
        END IF;
EXCEPTION
WHEN OTHERS THEN
        NULL;
END modify_single_task;

-------------------------------------------------------------------------------------------------------------------
/*This procedure is to create a dummy task table with only the task_idThis will be used if user gives the task_id as input.*/
PROCEDURE Create_Task_Table ( p_transaction_number IN NUMBER DEFAULT NULL ,
			      x_task_table OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type )IS

        l_task_table WMS_TASK_MGMT_PUB.task_tab_type ;
        l_task_rec WMS_TASK_MGMT_PUB.task_output_rectype;
BEGIN
        l_task_rec.TRANSACTION_NUMBER := p_transaction_number;
        l_task_table(1)               := l_task_rec ;
        x_task_table                  := l_task_table;
END Create_Task_Table ;
-------------------------------------------------------------------------------------------------------------------

/*This procedure will validate one task at a a time.*/
PROCEDURE validate_task_id ( p_init_msg_list IN VARCHAR2 DEFAULT 'Y' ,
			     p_transaction_number IN NUMBER DEFAULT NULL ,
			     p_action IN VARCHAR2 DEFAULT NULL,       --6850212
			     x_validation_status OUT NOCOPY VARCHAR2 ,
			     x_error_msg OUT NOCOPY VARCHAR2 ,
			     x_return_status OUT NOCOPY VARCHAR2 )IS

        l_wdt_status     NUMBER := 0 ;
        l_task_exists    NUMBER := 0;
        l_msg_count      NUMBER ;
        l_task_type      NUMBER ;
        l_parent_line_id NUMBER := 0 ;
BEGIN
        --initialize output variables.
        x_validation_status := 'S';
        x_return_status     := 'S';
        x_error_msg         := NULL;
        --Initialize message pub
        IF p_init_msg_list ='Y' THEN
                fnd_msg_pub.initialize;
        END IF;
        BEGIN
                --Make sure there is a task with this Id
                SELECT  1                  ,
                        mmtt.wms_task_type ,
                        parent_line_id
                INTO    l_task_exists ,
                        l_task_type   ,
                        l_parent_line_id
                FROM    MTL_MATERIAL_TRANSACTIONS_TEMP mmtt
                WHERE   mmtt.transaction_temp_id=p_transaction_number;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                null;
        WHEN OTHERS THEN
                x_return_status := 'E';
        END ;
        IF (l_task_exists = 0 ) THEN
                --Checkif it is a cycle count task
                SELECT  count(1)
                INTO    l_task_exists
                FROM    Mtl_Cycle_Count_Entries mcce
                WHERE   mcce.cycle_count_entry_id = p_transaction_number
                    AND mcce.entry_status_code   IN( 1 , 3) ;
                l_task_type                      := 3 ; --cycle count.
        END IF ;
        IF (l_task_exists = 0 ) THEN
                --Still no task, this is invalid id.
                fnd_message.set_name('WMS', 'INVALID_TASK');
                fnd_msg_pub.ADD;
                x_validation_status:= 'E';
        END IF;
        --Need to check status in WDT .
        BEGIN
                SELECT  wdt.status
                INTO    l_wdt_status
                FROM    Wms_Dispatched_Tasks wdt
                WHERE   wdt.transaction_temp_id = p_transaction_number ;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                --No WDT, so task must bein status pending/unreleased.
                l_wdt_status := 0 ;
        WHEN OTHERS THEN
                x_return_status := 'E';
        END;
        IF (l_wdt_status = 0 AND l_task_type= 2 ) THEN  --Only for putaway tasks.
                SELECT  MAX(wdt.status )
                INTO    l_wdt_status
                FROM    Wms_Dispatched_Tasks wdt
                WHERE   wdt.transaction_temp_id in
                        (SELECT transaction_temp_id      --To check the child tasks
                        FROM    MTL_MATERIAL_TRANSACTIONS_TEMP mmtt
                        WHERE   mmtt.parent_line_id = p_transaction_number
                UNION SELECT  mmtt2.transaction_temp_id    --To check the siblings
                FROM    MTL_MATERIAL_TRANSACTIONS_TEMP mmtt1 ,
                        MTL_MATERIAL_TRANSACTIONS_TEMP mmtt2
                WHERE   mmtt1.transaction_temp_id = p_transaction_number
                    AND mmtt2.parent_line_id      = mmtt1.parent_line_id
        UNION SELECT  mmtt2.transaction_temp_id     ---To check the parent task.
        FROM    MTL_MATERIAL_TRANSACTIONS_TEMP mmtt1 ,
                MTL_MATERIAL_TRANSACTIONS_TEMP mmtt2
        WHERE   mmtt1.transaction_temp_id = p_transaction_number
            AND mmtt2.transaction_temp_id = mmtt1.parent_line_id
                        ) ;
        END IF;
        IF ( l_parent_line_id         > 0 AND l_task_type = 1 ) THEN --This is nbulk pick
                IF (l_parent_line_id <> p_transaction_number ) THEN
                        --The input is a child of bulk task.Fail validation.
                        fnd_message.set_name('WMS', 'INVALID_TASK');
                        fnd_msg_pub.ADD;
                        x_validation_status:= 'E';
                END IF;
        END IF;
        --	6850212 Start
	IF p_action = 'MODIFY' THEN
		IF (l_wdt_status NOT IN (0,2,3,9)) THEN
			--fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');
			--fnd_msg_pub.ADD;
			x_validation_status:= 'E';
		END IF;
	ELSE
		IF( l_wdt_status NOT  IN (0,2) ) THEN
			--fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');
			--fnd_msg_pub.ADD;
			x_validation_status:= 'E';
		 END IF;
	END IF;
	--	6850212 End
  fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => x_error_msg );
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
END validate_task_id ;
-------------------------------------------------------------------------------------------------------------------

/*Main procedure for task validation. */
PROCEDURE validate_tasks ( p_init_msg_list IN VARCHAR2 DEFAULT 'Y' ,
			   p_transaction_number IN NUMBER DEFAULT NULL ,
			   p_task_table IN WMS_TASK_MGMT_PUB.task_tab_type ,
			   p_action IN VARCHAR2 DEFAULT NULL,       --6850212
			   x_wms_task OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type ,
			   x_return_status OUT NOCOPY VARCHAR2 ) IS

        l_validate_task_ret VARCHAR2(1) ;
        l_error_msg         VARCHAR2(240);
        l_task_table WMS_TASK_MGMT_PUB.task_tab_type ;
BEGIN
        x_return_status := 'S';
        IF ( p_transaction_number IS NOT NULL ) THEN
                Create_Task_Table (p_transaction_number => p_transaction_number,  --create a dummy table
                x_task_table                            => l_task_table );
        ELSE
                l_task_table := p_task_table ;
        END IF;
        FOR i IN 1..l_task_table.count
        LOOP --Validate each task record individually.
                validate_task_id ( p_transaction_number => l_task_table(i).TRANSACTION_NUMBER,
		                   x_validation_status => l_validate_task_ret ,
				   p_action=>p_action,--6850212
                                   x_error_msg => l_error_msg ,
				   x_return_status => x_return_status );
                IF (l_validate_task_ret                 ='E' ) THEN
                        l_task_table(i).result         := 'E';
                        l_task_table(i).error          := l_error_msg;
                END IF;
        END LOOP;
        x_wms_task := l_task_table;
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
END validate_tasks ;
---------------------------------------------------------------------------------------------------------

/*This procedure checks if cartonization can be done on the taks.
If the API returns success, then carton_lpn_id can be stamped on the tasks*/
/*PROCEDURE check_cartonization ( p_task_table IN WMS_TASK_MGMT_PUB.task_tab_type ,
				p_new_carton_lpn_id IN NUMBER DEFAULT NULL ,
				x_error_msg OUT NOCOPY VARCHAR2 ,
				x_return_status OUT NOCOPY VARCHAR2 ) IS

        CURSOR carton_lpn_csr(c_lpn_id NUMBER)
        IS
                SELECT  lpn_context,
                        organization_id
                FROM    wms_license_plate_numbers wlpn
                WHERE   wlpn.lpn_id=c_lpn_id;
        CURSOR carton_lpn_del_det (c_lpn_id NUMBER)
        IS
                SELECT  wdd.delivery_detail_id,
                        wdd.move_order_line_id
                FROM    wsh_delivery_details wdd,
                        mtl_material_transactions_temp mmtt
                WHERE   wdd.move_order_line_id=mmtt.move_order_line_id
                    AND wdd.organization_id   =mmtt.organization_id
                    AND mmtt.transfer_lpn_id  =c_lpn_id
                    AND ROWNUM                < 2;
        CURSOR carton_lpn_del_det1 (c_lpn_id NUMBER)
        IS
                SELECT  wdd.delivery_detail_id,
                        wdd.move_order_line_id
                FROM    wsh_delivery_details wdd,
                        mtl_material_transactions_temp mmtt
                WHERE   wdd.move_order_line_id=mmtt.move_order_line_id
                    AND wdd.organization_id   =mmtt.organization_id
                    AND mmtt.cartonization_id = c_lpn_id
                    AND ROWNUM                = 1;
        CURSOR c_get_delivery_id(p_delivery_detail_id NUMBER)
        IS
                SELECT  delivery_id
                FROM    wsh_delivery_assignments
                WHERE   delivery_detail_id = p_delivery_detail_id;
        CURSOR c_bulk_task(p_transaction_number NUMBER)
        IS
                SELECT '1'
                FROM    mtl_material_transactions_temp
                WHERE   parent_line_id = p_transaction_number
                    AND rownum         = 1;
        l_carton_lpn_ctx            NUMBER;
        l_carton_lpn_org            NUMBER;
        l_carton_del_det_id         NUMBER;
        l_carton_del_id             NUMBER;
        l_carton_move_order_line_id NUMBER;
        l_temp_carton_grp_id        NUMBER;
        l_carton_grp_id_tab WSH_UTIL_CORE.id_tab_type;
        l_del_det_id_tab WSH_UTIL_CORE.id_tab_type;
        l_del_id_tab WSH_UTIL_CORE.id_tab_type;
        l_move_order_line_id_tab WSH_UTIL_CORE.id_tab_type;
        l_bulk_task          VARCHAR2(2);
        l_temp_del_detail_id NUMBER;
        l_move_order_line_id NUMBER;
        l_temp_del_id        NUMBER;
        l_debug              NUMBER         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
        l_api_name           VARCHAR2(1000) := 'CHECK_CARTONIZATION';
        l_error_msg          VARCHAR2(2000);
        l_msg_count          NUMBER;
BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
        OPEN carton_lpn_csr(p_new_carton_lpn_id);
        FETCH carton_lpn_csr INTO l_carton_lpn_ctx,l_carton_lpn_org;
        CLOSE carton_lpn_csr;
        --if carton lpn is passed and is not valid then no need to proceed further
        IF(l_carton_lpn_ctx NOT IN (5,8)) THEN
                x_return_status := fnd_api.g_ret_sts_error;
                fnd_message.set_name('WMS', 'WMS_CARTONIZATION_ERR');
                fnd_msg_pub.ADD;
                fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => x_error_msg );
                l_error_msg                      :='Invalid context for Carton LPN:'||p_new_carton_lpn_id;
                IF(l_debug                        = 1) THEN
                        inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                END IF;
                RETURN;
        END IF;
        IF (l_carton_lpn_ctx = 5 ) THEN
                OPEN carton_lpn_del_det1(p_new_carton_lpn_id);
                FETCH   carton_lpn_del_det1
                INTO    l_carton_del_det_id,
                        l_carton_move_order_line_id;
                CLOSE carton_lpn_del_det1;
                IF (l_carton_del_det_id is NOT NULL and l_carton_move_order_line_id is NOT NULL) THEN
                        l_del_det_id_tab(l_del_det_id_tab.count                +1) := l_carton_del_det_id;
                        l_move_order_line_id_tab(l_move_order_line_id_tab.count+1) := l_carton_move_order_line_id;
                END IF;
        END IF;
        IF (l_carton_lpn_ctx = 8 ) THEN
                --get carton del_det_id and mover_oder_line_id
                OPEN carton_lpn_del_det(p_new_carton_lpn_id);
                FETCH carton_lpn_del_det INTO l_carton_del_det_id,l_carton_move_order_line_id;
                CLOSE carton_lpn_del_det;
                l_del_det_id_tab(l_del_det_id_tab.count                +1) := l_carton_del_det_id;
                l_move_order_line_id_tab(l_move_order_line_id_tab.count+1) := l_carton_move_order_line_id;
        END IF;
        FOR i IN 1..p_task_table.count
        LOOP
                IF (p_task_table(i).organization_id <> l_carton_lpn_org) THEN
                        x_return_status             := fnd_api.g_ret_sts_error;
                        fnd_message.set_name('WMS', 'WMS_CARTONIZATION_ERR');
                        fnd_msg_pub.ADD;
                        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => x_error_msg );
                        l_error_msg                      :='Organization is not same for Carton LPN and Task';
                        IF(l_debug                        = 1) THEN
                                inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                        END IF;
                        RETURN;
                END IF;
                --Bulk tasks cannot be cartonized
                OPEN c_bulk_task(p_task_table(i).transaction_number);
                FETCH c_bulk_task INTO l_bulk_task;
                IF c_bulk_task%NOTFOUND THEN
                        CLOSE c_bulk_task;
                ELSE
                        x_return_status := fnd_api.g_ret_sts_error;
                        fnd_message.set_name('WMS', 'WMS_CARTONIZATION_ERR');
                        fnd_msg_pub.ADD;
                        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => x_error_msg );
                        l_error_msg                      :='Bulk Tasks cannot be cartonized';
                        IF(l_debug                        = 1) THEN
                                inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                        END IF;
                        CLOSE c_bulk_task;
                        RETURN;
                END IF;
        END LOOP;
        --Fetch the delivery_detail_id's and move order line id's associated with the input task/tasks.
        FOR i IN 1..p_task_table.count
        LOOP
                BEGIN
                        SELECT  wdd.delivery_detail_id,
                                wdd.move_order_line_id
                        INTO    l_temp_del_detail_id,
                                l_move_order_line_id
                        FROM    wsh_delivery_details wdd,
                                mtl_material_transactions_temp mmtt
                        WHERE   wdd.move_order_line_id   = mmtt.move_order_line_id
                            AND mmtt.transaction_temp_id = p_task_table(i).transaction_number;
                EXCEPTION
                WHEN OTHERS THEN
                        l_temp_del_detail_id := NULL;
                END;
                IF (l_temp_del_detail_id IS NULL) THEN
                        x_return_status := fnd_api.g_ret_sts_error;
                        fnd_message.set_name('WMS', 'WMS_CARTONIZATION_ERR');
                        fnd_msg_pub.ADD;
                        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => x_error_msg );
                        l_error_msg                      :='Data not present in WDD for the corresponding task :'||p_task_table(i).transaction_number;
                        IF(l_debug                        = 1) THEN
                                inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                        END IF;
                        RETURN;
                ELSE
                        l_del_det_id_tab(l_del_det_id_tab.count                +1) := l_temp_del_detail_id;
                        l_move_order_line_id_tab(l_move_order_line_id_tab.count+1) := l_move_order_line_id;
                END IF;
        END LOOP;
        --Fetch the delivery_id associated with the tasks.
        FOR i IN 1..l_del_det_id_tab.COUNT
        LOOP
                BEGIN
                        SELECT  delivery_id
                        INTO    l_temp_del_id
                        FROM    wsh_delivery_assignments
                        WHERE   delivery_detail_id = l_del_det_id_tab(i);
                EXCEPTION
                WHEN OTHERS THEN
                        l_temp_del_id := NULL;
                END;
                l_del_id_tab(l_del_id_tab.count +1) := l_temp_del_id;
        END LOOP;
        --Need to check if all the deliveries are same or not.
        --This needs to be done only if count of delivery_detail_id is >1.
        IF l_del_det_id_tab.COUNT > 1 THEN
                FOR i            IN 1..l_del_id_tab.COUNT
                LOOP
                        IF nvl(l_del_id_tab(1),-999) <> nvl(l_del_id_tab(i),-999) THEN
                                x_return_status      := fnd_api.g_ret_sts_error;
                                fnd_message.set_name('WMS', 'WMS_CARTONIZATION_ERR');
                                fnd_msg_pub.ADD;
                                fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => x_error_msg );
                                l_error_msg                      :='Delivery mismatch,cartonization cannot be done';
                                IF(l_debug                        = 1) THEN
                                        inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                                END IF;
                                RETURN;
                        END IF;
                END LOOP;
        END IF;
        --If delivery_id is null, then check for the carton_group_id
        --See if the delivery_id is null on the first record
        --If it is null, then it will be null on all the rest as per the above validation.
        IF ((l_del_id_tab(1) is NULL) AND (l_del_det_id_tab.COUNT > 1))THEN
                FOR i                                            IN 1..l_move_order_line_id_tab.COUNT
                LOOP
                        BEGIN
                                SELECT  mtrl.carton_grouping_id
                                INTO    l_temp_carton_grp_id
                                FROM    mtl_txn_request_lines mtrl
                                WHERE   line_id = l_move_order_line_id_tab(i);
                        EXCEPTION
                        WHEN OTHERS THEN
                                l_temp_carton_grp_id := NULL;
                        END;
                        l_carton_grp_id_tab(l_carton_grp_id_tab.count+1) := l_temp_carton_grp_id;
                END LOOP;
                FOR i IN 1..l_carton_grp_id_tab.COUNT
                LOOP
                        IF nvl(l_carton_grp_id_tab(1),-999) <> nvl(l_carton_grp_id_tab(i),-999) THEN
                                x_return_status             := fnd_api.g_ret_sts_error;
                                fnd_message.set_name('WMS', 'WMS_CARTONIZATION_ERR');
                                fnd_msg_pub.ADD;
                                fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => x_error_msg );
                                l_error_msg                      :='Carton group mismatch,cartonization cannot be done';
                                IF(l_debug                        = 1) THEN
                                        inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
                                END IF;
                                RETURN;
                        END IF;
                END LOOP;
        END IF;
END check_cartonization;*/

-------------------------------------------------------------------------------------------------------------------

--START OF SPLIT TASK
PROCEDURE print_msg(p_procedure IN VARCHAR2 ,
		    p_msg IN VARCHAR2) IS

BEGIN
        inv_log_util.trace(p_msg ,g_pkg_name || '.' || p_procedure ||  ': ' ,9);
        --    dbms_output.put_line(p_procedure||' : ' || p_msg);
END print_msg;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE validate_quantities()
This procedure performs all quantity and UOM validations based on the inputs in form of tasks and
split quantity table passed
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE validate_quantities( p_transaction_temp_id IN NUMBER ,
			       p_split_quantities IN task_qty_tbl_type ,
			       x_lot_control_code OUT NOCOPY NUMBER ,
			       x_serial_control_code OUT NOCOPY NUMBER ,
			       x_split_uom_quantities OUT NOCOPY qty_changed_tbl_type ,
			       x_return_status OUT NOCOPY VARCHAR2 ,
			       x_msg_data OUT NOCOPY VARCHAR2 ,
			       x_msg_count OUT NOCOPY VARCHAR2 ) IS

        l_mmtt_inventory_item_id     NUMBER;
        l_mmtt_primary_quantity      NUMBER;
        l_mmtt_transaction_quantity  NUMBER;
        l_mmtt_transaction_uom_code  NUMBER;
        l_mmtt_organization_id       NUMBER;
        l_mmtt_transaction_uom       VARCHAR2(3);
        l_mmtt_item_primary_uom_code VARCHAR2(3);
        l_lot_control_code           NUMBER;
        l_serial_control_code        NUMBER;
        l_decimal_precision          CONSTANT NUMBER := 5;
        l_mtlt_transaction_qty       NUMBER          := 0;
        l_msnt_transaction_qty       NUMBER          := 0;
        l_task_tbl_transaction_qty   NUMBER          := 0;
        l_procedure_name             VARCHAR2(20)    := 'VALIDATE_QUANTITIES';
        l_task_tbl_primary_qty       NUMBER          := 0;
        l_sum_tbl_transaction_qty    NUMBER          := 0;
        l_sum_tbl_primary_qty        NUMBER          := 0;
        l_remaining_primary_qty      NUMBER          := 0;
        l_remaining_transaction_qty  NUMBER          := 0;
BEGIN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                print_msg(l_procedure_name, 'Entered');
        END IF;
        IF p_split_quantities.COUNT = 0 THEN
                x_return_status    := 'E';
                IF g_debug          = 1 THEN
                        print_msg(l_procedure_name, 'Quantities table is empty, exiting');
                END IF;
                RETURN;
        END IF;
        SELECT  transaction_uom       ,
                inventory_item_id     ,
                primary_quantity      ,
                transaction_quantity  ,
                item_primary_uom_code ,
                transaction_uom       ,
                organization_id
        INTO    l_mmtt_transaction_uom       ,
                l_mmtt_inventory_item_id     ,
                l_mmtt_primary_quantity      ,
                l_mmtt_transaction_quantity  ,
                l_mmtt_item_primary_uom_code ,
                l_mmtt_transaction_uom       ,
                l_mmtt_organization_id
        FROM    mtl_material_transactions_temp
        WHERE   transaction_temp_id = p_transaction_temp_id;
        SELECT  lot_control_code ,
                serial_number_control_code
        INTO    l_lot_control_code ,
                l_serial_control_code
        FROM    mtl_system_items_b
        WHERE   inventory_item_id = l_mmtt_inventory_item_id
            AND organization_id   = l_mmtt_organization_id;
        x_lot_control_code       := l_lot_control_code;
        x_serial_control_code    := l_serial_control_code;
        IF g_debug                = 1 THEN
                FOR i            IN p_split_quantities.FIRST .. p_split_quantities.LAST
                LOOP
                        print_msg(l_procedure_name ,  ' Inside For loop i = ' || i ||
			' Task :' || p_transaction_temp_id ||
			' Quantity : ' ||p_split_quantities(i).quantity ||
			' Suggested UOM :' ||p_split_quantities(i).uom ||
			' MMTT transaction UOM :' ||l_mmtt_transaction_uom);
                END LOOP;
        END IF;
        FOR i IN p_split_quantities.FIRST .. p_split_quantities.LAST
        LOOP
                IF p_split_quantities(i).uom IS NULL THEN
                        IF g_debug = 1 THEN
                                print_msg(l_procedure_name , 'UOM cannot be passed as NULL');
                        END IF;
                        x_return_status := 'E';
                        RETURN;
                END IF;
                IF RTRIM(LTRIM(p_split_quantities(i).uom)) NOT IN (l_mmtt_item_primary_uom_code,l_mmtt_transaction_uom) THEN
                        x_return_status                        := 'E';
                        IF g_debug                              = 1 THEN
                                print_msg(l_procedure_name , 'UOM validation failed, only primary or transaction UOM allowed :');
                        END IF;
                        RETURN;
                END IF;
                -- All UOMs are same
                IF l_mmtt_transaction_uom                               = l_mmtt_item_primary_uom_code THEN
                        x_split_uom_quantities(i).primary_quantity     := p_split_quantities(i).quantity;
                        x_split_uom_quantities(i).transaction_quantity := p_split_quantities(i).quantity;
                ELSE
                        IF l_mmtt_transaction_uom = p_split_quantities(i).uom THEN
                                IF g_debug        = 1 THEN
                                        print_msg(l_procedure_name , ' mmtt transaction UOM is same as UOM in quantity table');
                                END IF;
                                l_task_tbl_transaction_qty                     := p_split_quantities(i).quantity;
                                x_split_uom_quantities(i).transaction_quantity := p_split_quantities(i).quantity;
                        ELSE
                                IF g_debug = 1 THEN
                                        print_msg(l_procedure_name , ' mmtt transaction UOM quantity table UOM are not same, calling inv_convert.inv_um_convert with :');
                                        print_msg(l_procedure_name,  ' item_id  : '||l_mmtt_inventory_item_id);
                                        print_msg(l_procedure_name,  ' PRECISION : '|| l_decimal_precision);
                                        print_msg(l_procedure_name, ' from_quantity :'|| p_split_quantities(i).quantity);
                                        print_msg(l_procedure_name, ' from_unit :'||p_split_quantities(i).uom);
                                        print_msg(l_procedure_name, ' to_unit :'||l_mmtt_transaction_uom);
                                END IF;
                                l_task_tbl_transaction_qty   := inv_convert.inv_um_convert( item_id => l_mmtt_inventory_item_id ,
											    PRECISION => l_decimal_precision ,
											    from_quantity => p_split_quantities(i).quantity ,
											    from_unit => p_split_quantities(i).uom ,
											    to_unit => l_mmtt_transaction_uom ,
											    from_name => NULL ,
											    to_name => NULL );
                                IF l_task_tbl_transaction_qty = -9999 THEN
                                        IF g_debug            = 1 THEN
                                                print_msg(l_procedure_name, ' No conversion defined from :'||p_split_quantities(i).uom|| ' to :'|| l_mmtt_transaction_uom || ' , or UOM does not exist.');
                                        END IF;
                                        x_return_status := 'E';
                                        RETURN;
                                END IF;
                                x_split_uom_quantities(i).transaction_quantity := l_task_tbl_transaction_qty;
                        END IF;
                        IF l_mmtt_item_primary_uom_code = p_split_quantities(i).uom THEN
                                IF g_debug              = 1 THEN
                                        print_msg(l_procedure_name , ' primary UOM is same as UOM in quantity table');
                                END IF;
                                l_task_tbl_primary_qty                     := p_split_quantities(i).quantity;
                                x_split_uom_quantities(i).primary_quantity := p_split_quantities(i).quantity;
                        ELSE
                                IF g_debug = 1 THEN
                                        print_msg(l_procedure_name , ' primary UOM not same as UOM in quantity table');
                                        print_msg(l_procedure_name,  ' For primary quantity ');
                                        print_msg(l_procedure_name,  ' item_id  : '||l_mmtt_inventory_item_id);
                                        print_msg(l_procedure_name,  ' PRECISION : '|| l_decimal_precision);
                                        print_msg(l_procedure_name, ' from_quantity :'|| p_split_quantities(i).quantity);
                                        print_msg(l_procedure_name, ' from_unit :'||p_split_quantities(i).uom);
                                        print_msg(l_procedure_name, ' to_unit :'||l_mmtt_transaction_uom);
                                END IF;
                                l_task_tbl_primary_qty       := inv_convert.inv_um_convert(item_id => l_mmtt_inventory_item_id ,
											   PRECISION => l_decimal_precision ,
											   from_quantity => p_split_quantities(i).quantity ,
											   from_unit => p_split_quantities(i).uom ,
											   to_unit => l_mmtt_item_primary_uom_code ,
											   from_name => NULL ,
											   to_name => NULL);
                                IF l_task_tbl_transaction_qty = -9999 THEN
                                        IF g_debug            = 1 THEN
                                                print_msg(l_procedure_name, ' No conversion defined from :'||
						p_split_quantities(i).uom|| ' to :'||
						l_mmtt_transaction_uom || ' , or UOM does not exist.');
                                        END IF;
                                        x_return_status := 'E';
                                        RETURN;
                                END IF;
                                x_split_uom_quantities(i).primary_quantity := l_task_tbl_primary_qty;
                        END IF;
                END IF;
                IF x_split_uom_quantities(i).transaction_quantity <= 0 OR x_split_uom_quantities(i).primary_quantity <= 0 THEN
                        IF g_debug                                 = 1 THEN
                                print_msg(l_procedure_name ,'Negative and zero quantities are not allowed in quantities table, exiting.');
                        END IF;
                        x_return_status := 'E';
                        RETURN;
                END IF;
                l_sum_tbl_transaction_qty := l_sum_tbl_transaction_qty + x_split_uom_quantities(i).transaction_quantity;
                l_sum_tbl_primary_qty     := l_sum_tbl_primary_qty     + x_split_uom_quantities(i).primary_quantity;
        END LOOP;
        IF g_debug = 1 THEN
                print_msg(l_procedure_name , 'l_sum_tbl_transaction_qty : '||l_sum_tbl_transaction_qty);
                print_msg(l_procedure_name , 'l_sum_tbl_primary_qty : '||l_sum_tbl_primary_qty);
        END IF;
        IF l_sum_tbl_transaction_qty >= l_mmtt_transaction_quantity THEN
                IF g_debug            = 1 THEN
                        print_msg(l_procedure_name ,'Sum of qty table :'|| l_sum_tbl_transaction_qty || 'should be less than the mmtt line quantity:'||l_mmtt_transaction_quantity );
                END IF;
                x_return_status := 'E';
                RETURN;
        END IF;
        --Validate lot/serial quantity
        IF g_debug = 1 THEN
                print_msg(l_procedure_name ,'Validating lot/serial if allocations are present');
                print_msg(l_procedure_name , 'lot_control_code : '|| l_lot_control_code);
                print_msg(l_procedure_name , 'serial_control_code : '|| l_serial_control_code);
        END IF;
        IF l_lot_control_code = 2 AND l_serial_control_code IN (2,5) THEN
                BEGIN
                        --Lot quantity
                        SELECT  sum(transaction_quantity)
                        INTO    l_mtlt_transaction_qty
                        FROM    mtl_transaction_lots_temp
                        WHERE   transaction_temp_id = p_transaction_temp_id;
                        IF g_debug                  = 1 THEN
                                print_msg(l_procedure_name , 'l_mtlt_transaction_qty : '||l_mtlt_transaction_qty|| ' l_mmtt_transaction_quantity : '||l_mmtt_transaction_quantity);
                        END IF;
                        IF l_mtlt_transaction_qty <> l_mmtt_transaction_quantity THEN
                                x_return_status   := 'E';
                                IF g_debug         = 1 THEN
                                        print_msg(l_procedure_name ,'Mismatch in MMTT and MTLT quantity');
                                END IF;
                                RETURN;
                        END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := 'E';
                        IF g_debug       = 1 THEN
                                print_msg(l_procedure_name ,'No Data Found : Mismatch in MMTT and MTLT quantity');
                        END IF;
                        RETURN;
                END;
                BEGIN
                        --serial quantity
                        SELECT  sum(1)
                        INTO    l_msnt_transaction_qty
                        FROM    mtl_serial_numbers_temp
                        WHERE   transaction_temp_id IN
                                (SELECT serial_transaction_temp_id
                                FROM    mtl_transaction_lots_temp
                                WHERE   transaction_temp_id = p_transaction_temp_id
                                );
                        IF l_msnt_transaction_qty <> l_mmtt_transaction_quantity THEN
                                x_return_status   := 'E';
                                IF g_debug         = 1 THEN
                                        print_msg(l_procedure_name ,'Mismatch in MMTT and MSNT quantity');
                                END IF;
                                RETURN;
                        END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := 'E';
                        IF g_debug       = 1 THEN
                                print_msg(l_procedure_name ,'No Data Found :Mismatch in MMTT and MSNT quantity');
                        END IF;
                        RETURN;
                END;
        ELSIF l_lot_control_code = 2 AND l_serial_control_code NOT IN (2,5) THEN
                BEGIN
                        --Lot quantity
                        SELECT  sum(transaction_quantity)
                        INTO    l_mtlt_transaction_qty
                        FROM    mtl_transaction_lots_temp
                        WHERE   transaction_temp_id = p_transaction_temp_id;
                        IF l_mtlt_transaction_qty  <> l_mmtt_transaction_quantity THEN
                                x_return_status    := 'E';
                                IF g_debug          = 1 THEN
                                        print_msg(l_procedure_name ,'Mismatch in MMTT and MTLT quantity');
                                END IF;
                                RETURN;
                        END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := 'E';
                        IF g_debug       = 1 THEN
                                print_msg(l_procedure_name ,'No Data Found :Mismatch in MMTT and MTLT quantity');
                        END IF;
                        RETURN;
                END;
        ELSIF l_lot_control_code = 1 AND l_serial_control_code IN (2,5) THEN
                BEGIN
                        IF g_debug = 1 THEN
                                print_msg(l_procedure_name ,'Checking for MMTT and MSNT quantity');
                        END IF;
                        --Serial quantity
                        SELECT  sum(1)
                        INTO    l_msnt_transaction_qty
                        FROM    mtl_serial_numbers_temp
                        WHERE   transaction_temp_id = p_transaction_temp_id;
                        IF l_msnt_transaction_qty  <> l_mmtt_transaction_quantity THEN
                                x_return_status    := 'E';
                                IF g_debug          = 1 THEN
                                        print_msg(l_procedure_name ,'Mismatch in MMTT and MSNT quantity');
                                END IF;
                                RETURN;
                        END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := 'E';
                        IF g_debug       = 1 THEN
                                print_msg(l_procedure_name ,'No Data Found :Mismatch in MMTT and MSNT quantity');
                        END IF;
                        RETURN;
                END;
        END IF;
        IF g_debug = 1 THEN
                print_msg(l_procedure_name , 'l_mmtt_primary_quantity  -  l_sum_tbl_primary_qty '||l_mmtt_primary_quantity ||  ' - '||l_sum_tbl_transaction_qty);
        END IF;
        x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
END validate_quantities;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE validate_task()
This is the main procedure for all validations for the outbound task except quantity validations.
It internally calls generic procedure validate_task_id.
*/
-------------------------------------------------------------------------------------------------------------------

PROCEDURE validate_task( p_transaction_temp_id IN NUMBER ,
			 x_return_status OUT NOCOPY VARCHAR2 ,
			 x_error_msg OUT NOCOPY VARCHAR2 ,
			 x_msg_data OUT NOCOPY VARCHAR2 ,
			 x_msg_count OUT NOCOPY VARCHAR2 ) IS

        l_mmtt_id                    NUMBER;
        l_mmtt_inventory_item_id     NUMBER;
        l_mmtt_task_status           NUMBER;
        l_mmtt_allocated_lpn_id      NUMBER;
        l_mmtt_primary_quantity      NUMBER;
        l_mmtt_transaction_quantity  NUMBER;
        l_mmtt_transaction_uom_code  NUMBER;
        l_orig_mol_id                NUMBER;
        l_mmtt_mol_header_id         NUMBER;
        l_mmtt_organization_id       NUMBER;
        l_mmtt_transaction_uom       VARCHAR2(3);
        l_mmtt_item_primary_uom_code VARCHAR2(3);
        l_task_type                  NUMBER;
        l_parent_line_id             NUMBER := 0;
        l_validation_status          VARCHAR2(10);
        l_error_msg                  VARCHAR2(1000);
        l_task_return_status         VARCHAR2(10);
        l_procedure_name             VARCHAR2(20) := 'VALIDATE_TASK';
        l_task_exists                NUMBER;
BEGIN
        x_return_status := 'S'; --6870528/6851036
        validate_task_id ( p_init_msg_list  => 'Y' ,p_transaction_number=>  p_transaction_temp_id ,x_validation_status => l_validation_status ,x_error_msg => l_error_msg , x_return_status =>x_return_status );  --6850212
        IF g_debug = 1 THEN
                print_msg(l_procedure_name , 'Task :' || p_transaction_temp_id || ' not valid.');
        END IF;
        IF NVL(l_validation_status,'E') <> 'S' OR NVL(x_return_status,'E') <> 'S' THEN
                IF g_debug               = 1 THEN
                        print_msg(l_procedure_name , 'Task :' || p_transaction_temp_id || ' not valid.');
                END IF;
                x_return_status := 'E';
                RETURN;
        END IF;
        IF p_transaction_temp_id IS NULL THEN
                x_return_status := 'E';
                IF g_debug       = 1 THEN
                        print_msg(l_procedure_name, 'No transaction_temp_id passed');
                END IF;
                RETURN;
        END IF;
        BEGIN
                -- Taking locks on the task
                SELECT  transaction_temp_id   ,
                        wms_task_status       ,
                        allocated_lpn_id      ,
                        transaction_uom       ,
                        inventory_item_id     ,
                        primary_quantity      ,
                        transaction_quantity  ,
                        move_order_line_id    ,
                        move_order_header_id  ,
                        item_primary_uom_code ,
                        transaction_uom       ,
                        organization_id       ,
                        wms_task_type         ,
                        parent_line_id
                INTO    l_mmtt_id                    ,
                        l_mmtt_task_status           ,
                        l_mmtt_allocated_lpn_id      ,
                        l_mmtt_transaction_uom       ,
                        l_mmtt_inventory_item_id     ,
                        l_mmtt_primary_quantity      ,
                        l_mmtt_transaction_quantity  ,
                        l_orig_mol_id                ,
                        l_mmtt_mol_header_id         ,
                        l_mmtt_item_primary_uom_code ,
                        l_mmtt_transaction_uom       ,
                        l_mmtt_organization_id       ,
                        l_task_type                  ,
                        l_parent_line_id
                FROM    mtl_material_transactions_temp
                WHERE   transaction_temp_id = p_transaction_temp_id FOR UPDATE NOWAIT;
                IF l_mmtt_allocated_lpn_id IS NOT NULL THEN
                        x_return_status := 'E';
                        IF g_debug       = 1 THEN
                                print_msg(l_procedure_name ,'Task :' || l_mmtt_id || ' has an allocated LPN. Split not allowed');
                        END IF;
                        RETURN;
                END IF;
                IF ( l_parent_line_id    > 0 AND l_task_type = 1 AND l_parent_line_id = p_transaction_temp_id ) THEN -- This is bulk pick
                        x_return_status := 'E';
                        IF g_debug       = 1 THEN
                                print_msg(l_procedure_name ,'Task :' || l_mmtt_id || ' is a Bulk Pick task. Split not allowed');
                        END IF;
                        RETURN ;
                END IF;
                IF l_task_type          <> 1 THEN
                        x_return_status := 'E';
                        IF g_debug       = 1 THEN
                                print_msg(l_procedure_name ,'Task :' || l_mmtt_id || ' is not an outbound task. Split not allowed');
                        END IF;
                        RETURN ;
                END IF;
                IF g_debug = 1 THEN
                        print_msg(l_procedure_name , 'Calling validate_task_id for Task :' || p_transaction_temp_id);
                END IF;
               -- x_return_status := 'S';  --6870528/6851036
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                SELECT  count(1)
                INTO    l_task_exists
                FROM    mtl_cycle_count_entries mcce
                WHERE   mcce.cycle_count_entry_id = p_transaction_temp_id
                    AND mcce.entry_status_code   IN( 1 , 3) ;
                IF g_debug                        = 1 THEN
                        IF l_task_exists          > 0 THEN
                                print_msg(l_procedure_name , 'Task :' || p_transaction_temp_id || ' is a cycle count task, split not allowed.');
                        ELSE
                                print_msg(l_procedure_name , 'Task :' || p_transaction_temp_id || ' does not exist.');
                        END IF;
                END IF;
                x_return_status := 'E';
        WHEN OTHERS THEN
                x_return_status := 'E';
                IF g_debug       = 1 THEN
                        print_msg(l_procedure_name , 'Resource busy, was not able to acquire lock  on mmtt:' || p_transaction_temp_id);
                END IF;
        END;
     --   x_return_status := 'S';    --6870528/6851036
END validate_task;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE split_mtlt()
This helper procedure performs the splitting for the lot records contained in mtl_transaction_lots_temp table
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE split_mtlt ( p_new_transaction_temp_id IN NUMBER ,
		       p_transaction_qty_to_split IN NUMBER ,
		       p_primary_qty_to_split IN NUMBER ,
		       p_row_id IN ROWID ,
		       x_return_status OUT NOCOPY VARCHAR2 ,
		       x_msg_data OUT NOCOPY VARCHAR2 ,
		       x_msg_count OUT NOCOPY VARCHAR2 ) IS

BEGIN
        x_return_status := 'E';
        INSERT
        INTO    mtl_transaction_lots_temp
                (
                        TRANSACTION_TEMP_ID        ,
                        LAST_UPDATE_DATE           ,
                        LAST_UPDATED_BY            ,
                        CREATION_DATE              ,
                        CREATED_BY                 ,
                        LAST_UPDATE_LOGIN          ,
                        REQUEST_ID                 ,
                        PROGRAM_APPLICATION_ID     ,
                        PROGRAM_ID                 ,
                        PROGRAM_UPDATE_DATE        ,
                        TRANSACTION_QUANTITY       ,
                        PRIMARY_QUANTITY           ,
                        LOT_NUMBER                 ,
                        LOT_EXPIRATION_DATE        ,
                        ERROR_CODE                 ,
                        SERIAL_TRANSACTION_TEMP_ID ,
                        GROUP_HEADER_ID            ,
                        PUT_AWAY_RULE_ID           ,
                        PICK_RULE_ID               ,
                        DESCRIPTION                ,
                        VENDOR_NAME                ,
                        SUPPLIER_LOT_NUMBER        ,
                        ORIGINATION_DATE           ,
                        DATE_CODE                  ,
                        GRADE_CODE                 ,
                        CHANGE_DATE                ,
                        MATURITY_DATE              ,
                        STATUS_ID                  ,
                        RETEST_DATE                ,
                        AGE                        ,
                        ITEM_SIZE                  ,
                        COLOR                      ,
                        VOLUME                     ,
                        VOLUME_UOM                 ,
                        PLACE_OF_ORIGIN            ,
                        BEST_BY_DATE               ,
                        LENGTH                     ,
                        LENGTH_UOM                 ,
                        RECYCLED_CONTENT           ,
                        THICKNESS                  ,
                        THICKNESS_UOM              ,
                        WIDTH                      ,
                        WIDTH_UOM                  ,
                        CURL_WRINKLE_FOLD          ,
                        LOT_ATTRIBUTE_CATEGORY     ,
                        C_ATTRIBUTE1               ,
                        C_ATTRIBUTE2               ,
                        C_ATTRIBUTE3               ,
                        C_ATTRIBUTE4               ,
                        C_ATTRIBUTE5               ,
                        C_ATTRIBUTE6               ,
                        C_ATTRIBUTE7               ,
                        C_ATTRIBUTE8               ,
                        C_ATTRIBUTE9               ,
                        C_ATTRIBUTE10              ,
                        C_ATTRIBUTE11              ,
                        C_ATTRIBUTE12              ,
                        C_ATTRIBUTE13              ,
                        C_ATTRIBUTE14              ,
                        C_ATTRIBUTE15              ,
                        C_ATTRIBUTE16              ,
                        C_ATTRIBUTE17              ,
                        C_ATTRIBUTE18              ,
                        C_ATTRIBUTE19              ,
                        C_ATTRIBUTE20              ,
                        D_ATTRIBUTE1               ,
                        D_ATTRIBUTE2               ,
                        D_ATTRIBUTE3               ,
                        D_ATTRIBUTE4               ,
                        D_ATTRIBUTE5               ,
                        D_ATTRIBUTE6               ,
                        D_ATTRIBUTE7               ,
                        D_ATTRIBUTE8               ,
                        D_ATTRIBUTE9               ,
                        D_ATTRIBUTE10              ,
                        N_ATTRIBUTE1               ,
                        N_ATTRIBUTE2               ,
                        N_ATTRIBUTE3               ,
                        N_ATTRIBUTE4               ,
                        N_ATTRIBUTE5               ,
                        N_ATTRIBUTE6               ,
                        N_ATTRIBUTE7               ,
                        N_ATTRIBUTE8               ,
                        N_ATTRIBUTE9               ,
                        N_ATTRIBUTE10              ,
                        VENDOR_ID                  ,
                        TERRITORY_CODE             ,
                        SUBLOT_NUM                 ,
                        SECONDARY_QUANTITY         ,
                        SECONDARY_UNIT_OF_MEASURE  ,
                        QC_GRADE                   ,
                        REASON_CODE                ,
                        PRODUCT_CODE               ,
                        PRODUCT_TRANSACTION_ID     ,
                        ATTRIBUTE_CATEGORY         ,
                        ATTRIBUTE1                 ,
                        ATTRIBUTE2                 ,
                        ATTRIBUTE3                 ,
                        ATTRIBUTE4                 ,
                        ATTRIBUTE5                 ,
                        ATTRIBUTE6                 ,
                        ATTRIBUTE7                 ,
                        ATTRIBUTE8                 ,
                        ATTRIBUTE9                 ,
                        ATTRIBUTE10                ,
                        ATTRIBUTE11                ,
                        ATTRIBUTE12                ,
                        ATTRIBUTE13                ,
                        ATTRIBUTE14                ,
                        ATTRIBUTE15
                )
        SELECT  p_new_transaction_temp_id --TRANSACTION_TEMP_ID
                ,
                sysdate --LAST_UPDATE_DATE
                ,
                FND_GLOBAL.USER_ID ,
                sysdate --CREATION_DATE
                ,
                FND_GLOBAL.USER_ID     ,
                LAST_UPDATE_LOGIN      ,
                REQUEST_ID             ,
                PROGRAM_APPLICATION_ID ,
                PROGRAM_ID             ,
                PROGRAM_UPDATE_DATE    ,
                p_transaction_qty_to_split --TRANSACTION_QUANTITY
                ,
                p_primary_qty_to_split --PRIMARY_QUANTITY
                ,
                LOT_NUMBER                 ,
                LOT_EXPIRATION_DATE        ,
                ERROR_CODE                 ,
                SERIAL_TRANSACTION_TEMP_ID ,
                GROUP_HEADER_ID            ,
                PUT_AWAY_RULE_ID           ,
                PICK_RULE_ID               ,
                DESCRIPTION                ,
                VENDOR_NAME                ,
                SUPPLIER_LOT_NUMBER        ,
                ORIGINATION_DATE           ,
                DATE_CODE                  ,
                GRADE_CODE                 ,
                CHANGE_DATE                ,
                MATURITY_DATE              ,
                STATUS_ID                  ,
                RETEST_DATE                ,
                AGE                        ,
                ITEM_SIZE                  ,
                COLOR                      ,
                VOLUME                     ,
                VOLUME_UOM                 ,
                PLACE_OF_ORIGIN            ,
                BEST_BY_DATE               ,
                LENGTH                     ,
                LENGTH_UOM                 ,
                RECYCLED_CONTENT           ,
                THICKNESS                  ,
                THICKNESS_UOM              ,
                WIDTH                      ,
                WIDTH_UOM                  ,
                CURL_WRINKLE_FOLD          ,
                LOT_ATTRIBUTE_CATEGORY     ,
                C_ATTRIBUTE1               ,
                C_ATTRIBUTE2               ,
                C_ATTRIBUTE3               ,
                C_ATTRIBUTE4               ,
                C_ATTRIBUTE5               ,
                C_ATTRIBUTE6               ,
                C_ATTRIBUTE7               ,
                C_ATTRIBUTE8               ,
                C_ATTRIBUTE9               ,
                C_ATTRIBUTE10              ,
                C_ATTRIBUTE11              ,
                C_ATTRIBUTE12              ,
                C_ATTRIBUTE13              ,
                C_ATTRIBUTE14              ,
                C_ATTRIBUTE15              ,
                C_ATTRIBUTE16              ,
                C_ATTRIBUTE17              ,
                C_ATTRIBUTE18              ,
                C_ATTRIBUTE19              ,
                C_ATTRIBUTE20              ,
                D_ATTRIBUTE1               ,
                D_ATTRIBUTE2               ,
                D_ATTRIBUTE3               ,
                D_ATTRIBUTE4               ,
                D_ATTRIBUTE5               ,
                D_ATTRIBUTE6               ,
                D_ATTRIBUTE7               ,
                D_ATTRIBUTE8               ,
                D_ATTRIBUTE9               ,
                D_ATTRIBUTE10              ,
                N_ATTRIBUTE1               ,
                N_ATTRIBUTE2               ,
                N_ATTRIBUTE3               ,
                N_ATTRIBUTE4               ,
                N_ATTRIBUTE5               ,
                N_ATTRIBUTE6               ,
                N_ATTRIBUTE7               ,
                N_ATTRIBUTE8               ,
                N_ATTRIBUTE9               ,
                N_ATTRIBUTE10              ,
                VENDOR_ID                  ,
                TERRITORY_CODE             ,
                SUBLOT_NUM                 ,
                SECONDARY_QUANTITY         ,
                SECONDARY_UNIT_OF_MEASURE  ,
                QC_GRADE                   ,
                REASON_CODE                ,
                PRODUCT_CODE               ,
                PRODUCT_TRANSACTION_ID     ,
                ATTRIBUTE_CATEGORY         ,
                ATTRIBUTE1                 ,
                ATTRIBUTE2                 ,
                ATTRIBUTE3                 ,
                ATTRIBUTE4                 ,
                ATTRIBUTE5                 ,
                ATTRIBUTE6                 ,
                ATTRIBUTE7                 ,
                ATTRIBUTE8                 ,
                ATTRIBUTE9                 ,
                ATTRIBUTE10                ,
                ATTRIBUTE11                ,
                ATTRIBUTE12                ,
                ATTRIBUTE13                ,
                ATTRIBUTE14                ,
                ATTRIBUTE15
        FROM    mtl_transaction_lots_temp
        WHERE   rowid    = p_row_id;
        x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
        RETURN;
END split_mtlt;

-------------------------------------------------------------------------------------------------------------------
/*Procedure split_serial()
This helper procedure performs the splitting for the serial records contained in mtl_serial_numbers_temp table
*/
-------------------------------------------------------------------------------------------------------------------

PROCEDURE split_serial( p_orig_transaction_temp_id IN NUMBER ,
			p_new_transaction_temp_id IN NUMBER ,
			p_transaction_qty_to_split IN NUMBER ,
			p_primary_qty_to_split IN NUMBER ,
			p_inventory_item_id IN NUMBER ,
			p_organization_id IN NUMBER ,
			x_return_status OUT NOCOPY VARCHAR2 ,
			x_msg_data OUT NOCOPY VARCHAR2 ,
			x_msg_count OUT NOCOPY VARCHAR2 ) IS

        CURSOR C_MSNT
        IS
                SELECT  rowid,
                        msnt.*
                FROM    mtl_serial_numbers_temp msnt
                WHERE   transaction_temp_id = p_orig_transaction_temp_id
                ORDER BY fm_serial_number;
        l_procedure_name            VARCHAR2(20) := 'SPLIT_SERIAL';
        l_transaction_remaining_qty NUMBER;
        l_primary_remaining_qty     NUMBER;
BEGIN
        x_return_status             := 'E';
        l_transaction_remaining_qty := p_transaction_qty_to_split;
        l_primary_remaining_qty     := p_primary_qty_to_split;
        IF g_debug                   = 1 THEN
        print_msg(l_procedure_name,  'In for loop(cursor msnt) for transaction_temp_id : '||p_orig_transaction_temp_id ||  'l_transaction_remaining_qty : '||l_transaction_remaining_qty||  'l_primary_remaining_qty : '||l_primary_remaining_qty);
        END IF;
        FOR msnt IN C_MSNT
        LOOP
                l_transaction_remaining_qty := l_transaction_remaining_qty - 1;
                UPDATE mtl_serial_numbers_temp
                        SET transaction_temp_id = p_new_transaction_temp_id ,
                        last_updated_by         = FND_GLOBAL.USER_ID
                WHERE   rowid                   = msnt.rowid;
                UPDATE mtl_serial_numbers msn
                        SET msn.group_mark_id   = p_new_transaction_temp_id ,
                        last_updated_by         = FND_GLOBAL.USER_ID
                WHERE   msn.inventory_item_id   = p_inventory_item_id
                    AND serial_number           = msnt.fm_serial_number
                    AND current_organization_id = p_organization_id;
                IF l_transaction_remaining_qty  = 0 THEN
                        print_msg(l_procedure_name,'All the quantity has been consumed, going back');
                        EXIT;
                END IF;
        END LOOP;
        x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
        RETURN;
END split_serial;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE split_lot_serial()
This is the procedure called for splitting in case an Item is either only Lot Controlled or both Lot and
Serial Controlled. It internally calls procedures split_mtlt and split_serial.
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE split_lot_serial( p_orig_transaction_temp_id IN NUMBER ,
			    p_new_transaction_temp_id IN NUMBER ,
			    p_transaction_qty_to_split IN NUMBER ,
			    p_primary_qty_to_split IN NUMBER ,
			    p_inventory_item_id IN NUMBER ,
			    p_organization_id IN NUMBER ,
			    x_return_status OUT NOCOPY VARCHAR2 ,
			    x_msg_data OUT NOCOPY VARCHAR2 ,
			    x_msg_count OUT NOCOPY VARCHAR2 ) IS

        CURSOR C_MTLT
        IS
                SELECT  rowid,
                        mtlt.*
                FROM    mtl_transaction_lots_temp mtlt
                WHERE   transaction_temp_id = p_orig_transaction_temp_id
                ORDER BY lot_number;

        l_transaction_remaining_qty NUMBER;
        l_primary_remaining_qty     NUMBER;
        l_txn_remaining_qty_mtlt    NUMBER;
        l_prim_remaining_qty_mtlt   NUMBER;
        l_procedure_name            VARCHAR2(30) := 'SPLIT_LOT_SERIAL';
        l_lot_control_code          NUMBER;
        l_serial_control_code       NUMBER;
        l_new_serial_txn_temp_id    NUMBER;
        l_lot_control_code          NUMBER;
        l_serial_control_code       NUMBER;
	x_lot_return_status         VARCHAR2(1);
BEGIN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                print_msg(l_procedure_name, 'Entered.');
        END IF;
        l_transaction_remaining_qty := p_transaction_qty_to_split;
        l_primary_remaining_qty     := p_primary_qty_to_split;

        FOR mtlt                    IN C_MTLT
        LOOP
                IF g_debug = 1 THEN
                        print_msg(l_procedure_name,  'In for loop(cursor mtlt) for transaction_temp_id : '||
			p_orig_transaction_temp_id ||  'l_transaction_remaining_qty : '||
			l_transaction_remaining_qty||  'l_primary_remaining_qty : '||
			l_primary_remaining_qty);
                END IF;
                IF l_transaction_remaining_qty >= mtlt.transaction_quantity THEN
                        -- Then this whole row can be consumed there is not need to split.
                        -- Update the row with the new ttemp_id and transaction_quantity.
                        -- Calculate remaining quantity.
                        -- Update mtl_lot_number
                        l_transaction_remaining_qty := l_transaction_remaining_qty - mtlt.transaction_quantity;
                        l_primary_remaining_qty     := l_primary_remaining_qty     - mtlt.primary_quantity;
                        UPDATE mtl_transaction_lots_temp
                                SET transaction_temp_id = p_new_transaction_temp_id ,
                                last_updated_by         = FND_GLOBAL.USER_ID
                        WHERE   rowid                   = mtlt.rowid;
                        IF l_transaction_remaining_qty  = 0 THEN
                                EXIT;
                        END IF;
                ELSE
                        -- Oops the mtlt quantity is bigger gotta split the row.
                        -- Insert a new row with the transaction_quantity.
                        -- Update the old row with the remaining quantity.
                        -- Update mtl_lot_number
                        split_mtlt ( p_new_transaction_temp_id ,
				     l_transaction_remaining_qty ,
				     l_primary_remaining_qty ,mtlt.rowid ,
				     x_lot_return_status ,
				     x_msg_data ,
				     x_msg_count );

                        IF mtlt.serial_transaction_temp_id IS NOT NULL THEN
                                SELECT  mtl_material_transactions_s.NEXTVAL
                                INTO    l_new_serial_txn_temp_id
                                FROM    dual;
                                UPDATE mtl_transaction_lots_temp
                                        SET serial_transaction_temp_id   = l_new_serial_txn_temp_id ,
                                        last_updated_by                  = FND_GLOBAL.USER_ID
                                WHERE   transaction_temp_id              = p_new_transaction_temp_id
                                    AND lot_number                       = mtlt.lot_number;
                                split_serial( p_orig_transaction_temp_id => mtlt.serial_transaction_temp_id ,
				              p_new_transaction_temp_id => l_new_serial_txn_temp_id ,
					      p_transaction_qty_to_split => l_transaction_remaining_qty ,
					      p_primary_qty_to_split => l_primary_remaining_qty ,
					      p_inventory_item_id => p_inventory_item_id ,
					      p_organization_id => p_organization_id ,
					      x_return_status => x_return_status ,
					      x_msg_data => x_msg_data ,
					      x_msg_count => x_msg_count );
                        END IF;
                        l_txn_remaining_qty_mtlt  := mtlt.transaction_quantity - l_transaction_remaining_qty;
                        l_prim_remaining_qty_mtlt := mtlt.primary_quantity     - l_primary_remaining_qty;
                        -- Update the remaining qty in the mtlt after insert.
                        UPDATE mtl_transaction_lots_temp
                                SET transaction_quantity = l_txn_remaining_qty_mtlt  ,
                                primary_quantity         = l_prim_remaining_qty_mtlt ,
                                last_updated_by          = FND_GLOBAL.USER_ID
                        WHERE   rowid                    = mtlt.rowid;
                        -- As the remaining quantity is already consumed we can safely exit
                        EXIT ;
                END IF;
        END LOOP;
        x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
        IF g_debug = 1 THEN
                print_msg(l_procedure_name,  'Error occurred : '|| SQLERRM);
        END IF;
        x_return_status := 'E';
        RETURN;
END split_lot_serial;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE split_wdt()
This procedure is called to accordingly split the task record contained in wms_dispatched_tasks table
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE split_wdt( p_new_task_id IN NUMBER ,
		     p_new_transaction_temp_id IN NUMBER ,
		     p_new_mol_id IN NUMBER ,
		     p_orig_transaction_temp_id IN NUMBER ,
		     x_return_status OUT NOCOPY VARCHAR2 ,
		     x_msg_data OUT NOCOPY VARCHAR2 ,
		     x_msg_count OUT NOCOPY VARCHAR2 ) IS

        l_proceudre_name VARCHAR2(30) := 'SPLIT_WDT';
        l_sysdate DATE                := SYSDATE;
BEGIN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                print_msg(l_proceudre_name,  ' Entered ');
        END IF;
        INSERT
        INTO    wms_dispatched_tasks
                (
                        op_plan_instance_id         ,
                        task_method                 ,
                        task_id                     ,
                        transaction_temp_id         ,
                        organization_id             ,
                        user_task_type              ,
                        person_id                   ,
                        effective_start_date        ,
                        effective_end_date          ,
                        equipment_id                ,
                        equipment_instance          ,
                        person_resource_id          ,
                        machine_resource_id         ,
                        status                      ,
                        dispatched_time             ,
                        loaded_time                 ,
                        drop_off_time               ,
                        last_update_date            ,
                        last_updated_by             ,
                        creation_date               ,
                        created_by                  ,
                        last_update_login           ,
                        attribute_category          ,
                        attribute1                  ,
                        attribute2                  ,
                        attribute3                  ,
                        attribute4                  ,
                        attribute5                  ,
                        attribute6                  ,
                        attribute7                  ,
                        attribute8                  ,
                        attribute9                  ,
                        attribute10                 ,
                        attribute11                 ,
                        attribute12                 ,
                        attribute13                 ,
                        attribute14                 ,
                        attribute15                 ,
                        task_type                   ,
                        priority                    ,
                        task_group_id               ,
                        device_id                   ,
                        device_invoked              ,
                        device_request_id           ,
                        suggested_dest_subinventory ,
                        suggested_dest_locator_id   ,
                        operation_plan_id           ,
                        move_order_line_id          ,
                        transfer_lpn_id
                )
        SELECT  op_plan_instance_id ,
                task_method         ,
                p_new_task_id --task_id
                ,
                p_new_transaction_temp_id --transaction_temp_id
                ,
                organization_id      ,
                user_task_type       ,
                person_id            ,
                effective_start_date ,
                effective_end_date   ,
                equipment_id         ,
                equipment_instance   ,
                person_resource_id   ,
                machine_resource_id  ,
                status               ,
                dispatched_time      ,
                loaded_time          ,
                drop_off_time        ,
                l_sysdate --last_update_date
                ,
                FND_GLOBAL.USER_ID ,
                l_sysdate --creation_date
                ,
                FND_GLOBAL.USER_ID          ,
                last_update_login           ,
                attribute_category          ,
                attribute1                  ,
                attribute2                  ,
                attribute3                  ,
                attribute4                  ,
                attribute5                  ,
                attribute6                  ,
                attribute7                  ,
                attribute8                  ,
                attribute9                  ,
                attribute10                 ,
                attribute11                 ,
                attribute12                 ,
                attribute13                 ,
                attribute14                 ,
                attribute15                 ,
                task_type                   ,
                priority                    ,
                task_group_id               ,
                device_id                   ,
                device_invoked              ,
                device_request_id           ,
                suggested_dest_subinventory ,
                suggested_dest_locator_id   ,
                operation_plan_id           ,
                p_new_mol_id                ,
                transfer_lpn_id
        FROM    wms_dispatched_tasks
        WHERE   transaction_temp_id = p_orig_transaction_temp_id;
        x_return_status            := 'S';
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                print_msg(l_proceudre_name,  ' Error Code : '|| SQLCODE || ' Error Message :'||SQLERRM);
        END IF;
        RETURN;
END split_wdt;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE split_mmtt()
This procedure performs the split for the Pending task record in mtl_material_transactions_temp table
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE split_mmtt( p_orig_transaction_temp_id IN NUMBER ,
		      p_new_transaction_temp_id IN NUMBER ,
		      p_new_transaction_header_id IN NUMBER ,
		      p_new_mol_id IN NUMBER ,
		      p_transaction_qty_to_split IN NUMBER ,
		      p_primary_qty_to_split IN NUMBER ,
		      x_return_status OUT NOCOPY VARCHAR2 ,
		      x_msg_data OUT NOCOPY VARCHAR2 ,
		      x_msg_count OUT NOCOPY VARCHAR2 ) IS

        l_procedure_name VARCHAR2(30) := 'WMS_TASK_SPLIT_API.SPLIT_MMTT';
        l_sysdate DATE                := SYSDATE;
BEGIN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                print_msg(l_procedure_name,  ' Entered ');
        END IF;
        INSERT
        INTO    mtl_material_transactions_temp
                (
                        currency_conversion_date       ,
                        shipment_number                ,
                        org_cost_group_id              ,
                        cost_type_id                   ,
                        transaction_status             ,
                        standard_operation_id          ,
                        task_priority                  ,
                        wms_task_type                  ,
                        parent_line_id                 ,
                        source_lot_number              ,
                        transfer_cost_group_id         ,
                        lpn_id                         ,
                        transfer_lpn_id                ,
                        wms_task_status                ,
                        content_lpn_id                 ,
                        container_item_id              ,
                        cartonization_id               ,
                        pick_slip_date                 ,
                        rebuild_item_id                ,
                        rebuild_serial_number          ,
                        rebuild_activity_id            ,
                        rebuild_job_name               ,
                        organization_type              ,
                        transfer_organization_type     ,
                        owning_organization_id         ,
                        owning_tp_type                 ,
                        xfr_owning_organization_id     ,
                        transfer_owning_tp_type        ,
                        planning_organization_id       ,
                        planning_tp_type               ,
                        xfr_planning_organization_id   ,
                        transfer_planning_tp_type      ,
                        secondary_uom_code             ,
                        secondary_transaction_quantity ,
                        allocated_lpn_id               ,
                        schedule_number                ,
                        scheduled_flag                 ,
                        class_code                     ,
                        schedule_group                 ,
                        build_sequence                 ,
                        bom_revision                   ,
                        routing_revision               ,
                        bom_revision_date              ,
                        routing_revision_date          ,
                        alternate_bom_designator       ,
                        alternate_routing_designator   ,
                        transaction_batch_id           ,
                        transaction_batch_seq          ,
                        operation_plan_id              ,
                        intransit_account              ,
                        fob_point                      ,
                        transaction_header_id          ,
                        transaction_temp_id            ,
                        source_code                    ,
                        source_line_id                 ,
                        transaction_mode               ,
                        lock_flag                      ,
                        last_update_date               ,
                        last_updated_by                ,
                        creation_date                  ,
                        created_by                     ,
                        last_update_login              ,
                        request_id                     ,
                        program_application_id         ,
                        program_id                     ,
                        program_update_date            ,
                        inventory_item_id              ,
                        revision                       ,
                        organization_id                ,
                        subinventory_code              ,
                        locator_id                     ,
                        transaction_quantity           ,
                        primary_quantity               ,
                        transaction_uom                ,
                        transaction_cost               ,
                        transaction_type_id            ,
                        transaction_action_id          ,
                        transaction_source_type_id     ,
                        transaction_source_id          ,
                        transaction_source_name        ,
                        transaction_date               ,
                        acct_period_id                 ,
                        distribution_account_id        ,
                        transaction_reference          ,
                        requisition_line_id            ,
                        requisition_distribution_id    ,
                        reason_id                      ,
                        lot_number                     ,
                        lot_expiration_date            ,
                        serial_number                  ,
                        receiving_document             ,
                        demand_id                      ,
                        rcv_transaction_id             ,
                        move_transaction_id            ,
                        completion_transaction_id      ,
                        wip_entity_type                ,
                        schedule_id                    ,
                        repetitive_line_id             ,
                        employee_code                  ,
                        primary_switch                 ,
                        schedule_update_code           ,
                        setup_teardown_code            ,
                        item_ordering                  ,
                        negative_req_flag              ,
                        operation_seq_num              ,
                        picking_line_id                ,
                        trx_source_line_id             ,
                        trx_source_delivery_id         ,
                        physical_adjustment_id         ,
                        cycle_count_id                 ,
                        rma_line_id                    ,
                        customer_ship_id               ,
                        currency_code                  ,
                        currency_conversion_rate       ,
                        currency_conversion_type       ,
                        ship_to_location               ,
                        move_order_header_id           ,
                        serial_allocated_flag          ,
                        trx_flow_header_id             ,
                        logical_trx_type_code          ,
                        original_transaction_temp_id   ,
                        vendor_lot_number              ,
                        encumbrance_account            ,
                        encumbrance_amount             ,
                        transfer_cost                  ,
                        transportation_cost            ,
                        transportation_account         ,
                        freight_code                   ,
                        containers                     ,
                        waybill_airbill                ,
                        expected_arrival_date          ,
                        transfer_subinventory          ,
                        transfer_organization          ,
                        transfer_to_location           ,
                        new_average_cost               ,
                        value_change                   ,
                        percentage_change              ,
                        material_allocation_temp_id    ,
                        demand_source_header_id        ,
                        demand_source_line             ,
                        demand_source_delivery         ,
                        item_segments                  ,
                        item_description               ,
                        item_trx_enabled_flag          ,
                        item_location_control_code     ,
                        item_restrict_subinv_code      ,
                        item_restrict_locators_code    ,
                        item_revision_qty_control_code ,
                        item_primary_uom_code          ,
                        item_uom_class                 ,
                        item_shelf_life_code           ,
                        item_shelf_life_days           ,
                        item_lot_control_code          ,
                        item_serial_control_code       ,
                        item_inventory_asset_flag      ,
                        allowed_units_lookup_code      ,
                        department_id                  ,
                        department_code                ,
                        wip_supply_type                ,
                        supply_subinventory            ,
                        supply_locator_id              ,
                        valid_subinventory_flag        ,
                        valid_locator_flag             ,
                        locator_segments               ,
                        current_locator_control_code   ,
                        number_of_lots_entered         ,
                        wip_commit_flag                ,
                        next_lot_number                ,
                        lot_alpha_prefix               ,
                        next_serial_number             ,
                        serial_alpha_prefix            ,
                        shippable_flag                 ,
                        posting_flag                   ,
                        required_flag                  ,
                        process_flag                   ,
                        ERROR_CODE                     ,
                        error_explanation              ,
                        attribute_category             ,
                        attribute1                     ,
                        attribute2                     ,
                        attribute3                     ,
                        attribute4                     ,
                        attribute5                     ,
                        attribute6                     ,
                        attribute7                     ,
                        attribute8                     ,
                        attribute9                     ,
                        attribute10                    ,
                        attribute11                    ,
                        attribute12                    ,
                        attribute13                    ,
                        attribute14                    ,
                        attribute15                    ,
                        movement_id                    ,
                        reservation_quantity           ,
                        shipped_quantity               ,
                        transaction_line_number        ,
                        task_id                        ,
                        to_task_id                     ,
                        source_task_id                 ,
                        project_id                     ,
                        source_project_id              ,
                        pa_expenditure_org_id          ,
                        to_project_id                  ,
                        expenditure_type               ,
                        final_completion_flag          ,
                        transfer_percentage            ,
                        transaction_sequence_id        ,
                        material_account               ,
                        material_overhead_account      ,
                        resource_account               ,
                        outside_processing_account     ,
                        overhead_account               ,
                        flow_schedule                  ,
                        cost_group_id                  ,
                        demand_class                   ,
                        qa_collection_id               ,
                        kanban_card_id                 ,
                        overcompletion_transaction_qty ,
                        overcompletion_primary_qty     ,
                        overcompletion_transaction_id  ,
                        end_item_unit_number           ,
                        scheduled_payback_date         ,
                        line_type_code                 ,
                        parent_transaction_temp_id     ,
                        put_away_strategy_id           ,
                        put_away_rule_id               ,
                        pick_strategy_id               ,
                        pick_rule_id                   ,
                        move_order_line_id             ,
                        task_group_id                  ,
                        pick_slip_number               ,
                        reservation_id                 ,
                        common_bom_seq_id              ,
                        common_routing_seq_id          ,
                        ussgl_transaction_code
                )
        SELECT  currency_conversion_date       ,
                shipment_number                ,
                org_cost_group_id              ,
                cost_type_id                   ,
                transaction_status             ,
                standard_operation_id          ,
                task_priority                  ,
                wms_task_type                  ,
                parent_line_id                 ,
                source_lot_number              ,
                transfer_cost_group_id         ,
                lpn_id                         ,
                transfer_lpn_id                ,
                wms_task_status                ,
                content_lpn_id                 ,
                container_item_id              ,
                cartonization_id               ,
                pick_slip_date                 ,
                rebuild_item_id                ,
                rebuild_serial_number          ,
                rebuild_activity_id            ,
                rebuild_job_name               ,
                organization_type              ,
                transfer_organization_type     ,
                owning_organization_id         ,
                owning_tp_type                 ,
                xfr_owning_organization_id     ,
                transfer_owning_tp_type        ,
                planning_organization_id       ,
                planning_tp_type               ,
                xfr_planning_organization_id   ,
                transfer_planning_tp_type      ,
                secondary_uom_code             ,
                secondary_transaction_quantity ,
                allocated_lpn_id               ,
                schedule_number                ,
                scheduled_flag                 ,
                class_code                     ,
                schedule_group                 ,
                build_sequence                 ,
                bom_revision                   ,
                routing_revision               ,
                bom_revision_date              ,
                routing_revision_date          ,
                alternate_bom_designator       ,
                alternate_routing_designator   ,
                transaction_batch_id           ,
                transaction_batch_seq          ,
                operation_plan_id              ,
                intransit_account              ,
                fob_point                      ,
                p_new_transaction_header_id --TRANSACTION_HEADER_ID
                ,
                p_new_transaction_temp_id --TRANSACTION_TEMP_ID
                ,
                source_code      ,
                source_line_id   ,
                transaction_mode ,
                lock_flag        ,
                l_sysdate --LAST_UPDATE_DATE
                ,
                FND_GLOBAL.USER_ID ,
                l_sysdate --CREATION_DATE
                ,
                FND_GLOBAL.USER_ID     ,
                last_update_login      ,
                request_id             ,
                program_application_id ,
                program_id             ,
                program_update_date    ,
                inventory_item_id      ,
                revision               ,
                organization_id        ,
                subinventory_code      ,
                locator_id             ,
                p_transaction_qty_to_split --TRANSACTION_QUANTITY
                ,
                p_primary_qty_to_split --PRIMARY_QUANTITY
                ,
                transaction_uom                ,
                transaction_cost               ,
                transaction_type_id            ,
                transaction_action_id          ,
                transaction_source_type_id     ,
                transaction_source_id          ,
                transaction_source_name        ,
                transaction_date               ,
                acct_period_id                 ,
                distribution_account_id        ,
                transaction_reference          ,
                requisition_line_id            ,
                requisition_distribution_id    ,
                reason_id                      ,
                lot_number                     ,
                lot_expiration_date            ,
                serial_number                  ,
                receiving_document             ,
                demand_id                      ,
                rcv_transaction_id             ,
                move_transaction_id            ,
                completion_transaction_id      ,
                wip_entity_type                ,
                schedule_id                    ,
                repetitive_line_id             ,
                employee_code                  ,
                primary_switch                 ,
                schedule_update_code           ,
                setup_teardown_code            ,
                item_ordering                  ,
                negative_req_flag              ,
                operation_seq_num              ,
                picking_line_id                ,
                trx_source_line_id             ,
                trx_source_delivery_id         ,
                physical_adjustment_id         ,
                cycle_count_id                 ,
                rma_line_id                    ,
                customer_ship_id               ,
                currency_code                  ,
                currency_conversion_rate       ,
                currency_conversion_type       ,
                ship_to_location               ,
                move_order_header_id           ,
                serial_allocated_flag          ,
                trx_flow_header_id             ,
                logical_trx_type_code          ,
                original_transaction_temp_id   ,
                vendor_lot_number              ,
                encumbrance_account            ,
                encumbrance_amount             ,
                transfer_cost                  ,
                transportation_cost            ,
                transportation_account         ,
                freight_code                   ,
                containers                     ,
                waybill_airbill                ,
                expected_arrival_date          ,
                transfer_subinventory          ,
                transfer_organization          ,
                transfer_to_location           ,
                new_average_cost               ,
                value_change                   ,
                percentage_change              ,
                material_allocation_temp_id    ,
                demand_source_header_id        ,
                demand_source_line             ,
                demand_source_delivery         ,
                item_segments                  ,
                item_description               ,
                item_trx_enabled_flag          ,
                item_location_control_code     ,
                item_restrict_subinv_code      ,
                item_restrict_locators_code    ,
                item_revision_qty_control_code ,
                item_primary_uom_code          ,
                item_uom_class                 ,
                item_shelf_life_code           ,
                item_shelf_life_days           ,
                item_lot_control_code          ,
                item_serial_control_code       ,
                item_inventory_asset_flag      ,
                allowed_units_lookup_code      ,
                department_id                  ,
                department_code                ,
                wip_supply_type                ,
                supply_subinventory            ,
                supply_locator_id              ,
                valid_subinventory_flag        ,
                valid_locator_flag             ,
                locator_segments               ,
                current_locator_control_code   ,
                number_of_lots_entered         ,
                wip_commit_flag                ,
                next_lot_number                ,
                lot_alpha_prefix               ,
                next_serial_number             ,
                serial_alpha_prefix            ,
                shippable_flag                 ,
                posting_flag                   ,
                required_flag                  ,
                process_flag                   ,
                ERROR_CODE                     ,
                error_explanation              ,
                attribute_category             ,
                attribute1                     ,
                attribute2                     ,
                attribute3                     ,
                attribute4                     ,
                attribute5                     ,
                attribute6                     ,
                attribute7                     ,
                attribute8                     ,
                attribute9                     ,
                attribute10                    ,
                attribute11                    ,
                attribute12                    ,
                attribute13                    ,
                attribute14                    ,
                attribute15                    ,
                movement_id                    ,
                reservation_quantity           ,
                shipped_quantity               ,
                transaction_line_number        ,
                task_id                        ,
                to_task_id                     ,
                source_task_id                 ,
                project_id                     ,
                source_project_id              ,
                pa_expenditure_org_id          ,
                to_project_id                  ,
                expenditure_type               ,
                final_completion_flag          ,
                transfer_percentage            ,
                transaction_sequence_id        ,
                material_account               ,
                material_overhead_account      ,
                resource_account               ,
                outside_processing_account     ,
                overhead_account               ,
                flow_schedule                  ,
                cost_group_id                  ,
                demand_class                   ,
                qa_collection_id               ,
                kanban_card_id                 ,
                overcompletion_transaction_qty ,
                overcompletion_primary_qty     ,
                overcompletion_transaction_id  ,
                end_item_unit_number           ,
                scheduled_payback_date         ,
                line_type_code                 ,
                parent_transaction_temp_id     ,
                put_away_strategy_id           ,
                put_away_rule_id               ,
                pick_strategy_id               ,
                pick_rule_id                   ,
                move_order_line_id             ,
                task_group_id                  ,
                pick_slip_number               ,
                reservation_id                 ,
                common_bom_seq_id              ,
                common_routing_seq_id          ,
                ussgl_transaction_code
        FROM    mtl_material_transactions_temp
        WHERE   transaction_temp_id = p_orig_transaction_temp_id;
        x_return_status            := 'S';
EXCEPTION
WHEN OTHERS THEN
        x_return_status := 'E';
        IF g_debug       = 1 THEN
                print_msg(l_procedure_name,  ' Error Code : '|| SQLCODE || ' Error Message :'||SQLERRM);
        END IF;
        RETURN;
END split_mmtt;

-------------------------------------------------------------------------------------------------------------------
--START OF DELETE TASK Process

PROCEDURE debug_print (p_message IN VARCHAR2 ) IS
        l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
        IF (l_debug                                             = 1) THEN
                inv_mobile_helper_functions.tracelog (p_err_msg => p_message,
						      p_module => 'wms_delete_tasks',
						      p_level => 11);
        END IF;
END debug_print;
-------------------------------------------------------------------------------------------------------------------
/*FUNCTION query_rows()
This function gets the move order record for the move order line passed.
*/
-------------------------------------------------------------------------------------------------------------------
FUNCTION query_rows(p_line_id IN NUMBER := fnd_api.g_miss_num)
RETURN inv_move_order_pub.trolin_tbl_type IS

        l_trolin_rec inv_move_order_pub.trolin_rec_type;
        l_trolin_tbl inv_move_order_pub.trolin_tbl_type;
        CURSOR l_trolin_csr
        IS
                SELECT  attribute1                 ,
                        attribute10                ,
                        attribute11                ,
                        attribute12                ,
                        attribute13                ,
                        attribute14                ,
                        attribute15                ,
                        attribute2                 ,
                        attribute3                 ,
                        attribute4                 ,
                        attribute5                 ,
                        attribute6                 ,
                        attribute7                 ,
                        attribute8                 ,
                        attribute9                 ,
                        attribute_category         ,
                        created_by                 ,
                        creation_date              ,
                        date_required              ,
                        from_locator_id            ,
                        from_subinventory_code     ,
                        from_subinventory_id       ,
                        header_id                  ,
                        inventory_item_id          ,
                        last_updated_by            ,
                        last_update_date           ,
                        last_update_login          ,
                        line_id                    ,
                        line_number                ,
                        line_status                ,
                        lot_number                 ,
                        organization_id            ,
                        program_application_id     ,
                        program_id                 ,
                        program_update_date        ,
                        project_id                 ,
                        quantity                   ,
                        quantity_delivered         ,
                        quantity_detailed          ,
                        reason_id                  ,
                        REFERENCE                  ,
                        reference_id               ,
                        reference_type_code        ,
                        request_id                 ,
                        revision                   ,
                        serial_number_end          ,
                        serial_number_start        ,
                        status_date                ,
                        task_id                    ,
                        to_account_id              ,
                        to_locator_id              ,
                        to_subinventory_code       ,
                        to_subinventory_id         ,
                        transaction_header_id      ,
                        uom_code                   ,
                        transaction_type_id        ,
                        transaction_source_type_id ,
                        txn_source_id              ,
                        txn_source_line_id         ,
                        txn_source_line_detail_id  ,
                        to_organization_id         ,
                        primary_quantity           ,
                        pick_strategy_id           ,
                        put_away_strategy_id       ,
                        unit_number                ,
                        ship_to_location_id        ,
                        from_cost_group_id         ,
                        to_cost_group_id           ,
                        lpn_id                     ,
                        to_lpn_id                  ,
                        inspection_status          ,
                        pick_methodology_id        ,
                        container_item_id          ,
                        carton_grouping_id         ,
                        wms_process_flag           ,
                        pick_slip_number           ,
                        pick_slip_date             ,
                        ship_set_id                ,
                        ship_model_id              ,
                        model_quantity             ,
                        required_quantity
                FROM    mtl_txn_request_lines
                WHERE   line_id = p_line_id;
BEGIN
        debug_print(  'p_line_id ' || p_line_id);
        IF (p_line_id IS NOT NULL AND p_line_id <> fnd_api.g_miss_num ) THEN
                --  Loop over fetched records
                FOR l_implicit_rec IN l_trolin_csr
                LOOP
                        l_trolin_rec.attribute1                 := l_implicit_rec.attribute1;
                        l_trolin_rec.attribute10                := l_implicit_rec.attribute10;
                        l_trolin_rec.attribute11                := l_implicit_rec.attribute11;
                        l_trolin_rec.attribute12                := l_implicit_rec.attribute12;
                        l_trolin_rec.attribute13                := l_implicit_rec.attribute13;
                        l_trolin_rec.attribute14                := l_implicit_rec.attribute14;
                        l_trolin_rec.attribute15                := l_implicit_rec.attribute15;
                        l_trolin_rec.attribute2                 := l_implicit_rec.attribute2;
                        l_trolin_rec.attribute3                 := l_implicit_rec.attribute3;
                        l_trolin_rec.attribute4                 := l_implicit_rec.attribute4;
                        l_trolin_rec.attribute5                 := l_implicit_rec.attribute5;
                        l_trolin_rec.attribute6                 := l_implicit_rec.attribute6;
                        l_trolin_rec.attribute7                 := l_implicit_rec.attribute7;
                        l_trolin_rec.attribute8                 := l_implicit_rec.attribute8;
                        l_trolin_rec.attribute9                 := l_implicit_rec.attribute9;
                        l_trolin_rec.attribute_category         := l_implicit_rec.attribute_category;
                        l_trolin_rec.created_by                 := l_implicit_rec.created_by;
                        l_trolin_rec.creation_date              := l_implicit_rec.creation_date;
                        l_trolin_rec.date_required              := l_implicit_rec.date_required;
                        l_trolin_rec.from_locator_id            := l_implicit_rec.from_locator_id;
                        l_trolin_rec.from_subinventory_code     := l_implicit_rec.from_subinventory_code;
                        l_trolin_rec.from_subinventory_id       := l_implicit_rec.from_subinventory_id;
                        l_trolin_rec.header_id                  := l_implicit_rec.header_id;
                        l_trolin_rec.inventory_item_id          := l_implicit_rec.inventory_item_id;
                        l_trolin_rec.last_updated_by            := l_implicit_rec.last_updated_by;
                        l_trolin_rec.last_update_date           := l_implicit_rec.last_update_date;
                        l_trolin_rec.last_update_login          := l_implicit_rec.last_update_login;
                        l_trolin_rec.line_id                    := l_implicit_rec.line_id;
                        l_trolin_rec.line_number                := l_implicit_rec.line_number;
                        l_trolin_rec.line_status                := l_implicit_rec.line_status;
                        l_trolin_rec.lot_number                 := l_implicit_rec.lot_number;
                        l_trolin_rec.organization_id            := l_implicit_rec.organization_id;
                        l_trolin_rec.program_application_id     := l_implicit_rec.program_application_id;
                        l_trolin_rec.program_id                 := l_implicit_rec.program_id;
                        l_trolin_rec.program_update_date        := l_implicit_rec.program_update_date;
                        l_trolin_rec.project_id                 := l_implicit_rec.project_id;
                        l_trolin_rec.quantity                   := l_implicit_rec.quantity;
                        l_trolin_rec.quantity_delivered         := l_implicit_rec.quantity_delivered;
                        l_trolin_rec.quantity_detailed          := l_implicit_rec.quantity_detailed;
                        l_trolin_rec.reason_id                  := l_implicit_rec.reason_id;
                        l_trolin_rec.REFERENCE                  := l_implicit_rec.REFERENCE;
                        l_trolin_rec.reference_id               := l_implicit_rec.reference_id;
                        l_trolin_rec.reference_type_code        := l_implicit_rec.reference_type_code;
                        l_trolin_rec.request_id                 := l_implicit_rec.request_id;
                        l_trolin_rec.revision                   := l_implicit_rec.revision;
                        l_trolin_rec.serial_number_end          := l_implicit_rec.serial_number_end;
                        l_trolin_rec.serial_number_start        := l_implicit_rec.serial_number_start;
                        l_trolin_rec.status_date                := l_implicit_rec.status_date;
                        l_trolin_rec.task_id                    := l_implicit_rec.task_id;
                        l_trolin_rec.to_account_id              := l_implicit_rec.to_account_id;
                        l_trolin_rec.to_locator_id              := l_implicit_rec.to_locator_id;
                        l_trolin_rec.to_subinventory_code       := l_implicit_rec.to_subinventory_code;
                        l_trolin_rec.to_subinventory_id         := l_implicit_rec.to_subinventory_id;
                        l_trolin_rec.transaction_header_id      := l_implicit_rec.transaction_header_id;
                        l_trolin_rec.uom_code                   := l_implicit_rec.uom_code;
                        l_trolin_rec.transaction_type_id        := l_implicit_rec.transaction_type_id;
                        l_trolin_rec.transaction_source_type_id := l_implicit_rec.transaction_source_type_id;
                        l_trolin_rec.txn_source_id              := l_implicit_rec.txn_source_id;
                        l_trolin_rec.txn_source_line_id         := l_implicit_rec.txn_source_line_id;
                        l_trolin_rec.txn_source_line_detail_id  := l_implicit_rec.txn_source_line_detail_id;
                        l_trolin_rec.to_organization_id         := l_implicit_rec.to_organization_id;
                        l_trolin_rec.primary_quantity           := l_implicit_rec.primary_quantity;
                        l_trolin_rec.pick_strategy_id           := l_implicit_rec.pick_strategy_id;
                        l_trolin_rec.put_away_strategy_id       := l_implicit_rec.put_away_strategy_id;
                        l_trolin_rec.unit_number                := l_implicit_rec.unit_number;
                        l_trolin_rec.ship_to_location_id        := l_implicit_rec.ship_to_location_id;
                        l_trolin_rec.from_cost_group_id         := l_implicit_rec.from_cost_group_id;
                        l_trolin_rec.to_cost_group_id           := l_implicit_rec.to_cost_group_id;
                        l_trolin_rec.lpn_id                     := l_implicit_rec.lpn_id;
                        l_trolin_rec.to_lpn_id                  := l_implicit_rec.to_lpn_id;
                        l_trolin_rec.inspection_status          := l_implicit_rec.inspection_status;
                        l_trolin_rec.pick_methodology_id        := l_implicit_rec.pick_methodology_id;
                        l_trolin_rec.container_item_id          := l_implicit_rec.container_item_id;
                        l_trolin_rec.carton_grouping_id         := l_implicit_rec.carton_grouping_id;
                        l_trolin_rec.wms_process_flag           := l_implicit_rec.wms_process_flag;
                        l_trolin_rec.pick_slip_number           := l_implicit_rec.pick_slip_number;
                        l_trolin_rec.pick_slip_date             := l_implicit_rec.pick_slip_date;
                        l_trolin_rec.ship_set_id                := l_implicit_rec.ship_set_id;
                        l_trolin_rec.ship_model_id              := l_implicit_rec.ship_model_id;
                        l_trolin_rec.model_quantity             := l_implicit_rec.model_quantity;
                        l_trolin_rec.required_quantity          := l_implicit_rec.required_quantity;
                        l_trolin_tbl(l_trolin_tbl.COUNT + 1)    := l_trolin_rec;
                END LOOP;
        END IF;
        IF (p_line_id IS NOT NULL AND p_line_id <> fnd_api.g_miss_num ) AND (l_trolin_tbl.COUNT = 0) THEN
                debug_print('no data found');
                RAISE NO_DATA_FOUND;
        END IF;
        --  Return fetched table
        RETURN l_trolin_tbl;
EXCEPTION
WHEN fnd_api.g_exc_unexpected_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
WHEN OTHERS THEN
        RAISE fnd_api.g_exc_unexpected_error;
END query_rows;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE delete_transaction()
This procedure checks for lot/serial control-deletes MTLT, MSNT,
Unmarks the serials, checks if a task record exists in wms_dispatched_tasks and deletes it.
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE delete_transaction( x_return_status OUT NOCOPY VARCHAR2 ,
			      x_msg_data OUT NOCOPY VARCHAR2 ,
			      x_msg_count OUT NOCOPY NUMBER ,
			      p_transaction_temp_id NUMBER ,
			      p_update_parent BOOLEAN ) IS

        l_inventory_item_id   NUMBER;
        l_lot_control_code    NUMBER;
        l_serial_control_code NUMBER;
        l_fm_serial_number    VARCHAR2(30);
        l_to_serial_number    VARCHAR2(30);
        l_unmarked_count      NUMBER := 0;
        l_parent_line_id      NUMBER;
        l_child_txn_qty       NUMBER;
        l_child_pri_qty       NUMBER;
        l_child_uom           VARCHAR2(3);
        exc_not_deleted       EXCEPTION;
        l_msnt_count          NUMBER;
        l_wdt_count           NUMBER;
        l_msn_count           NUMBER;
        l_debug               NUMBER;
        CURSOR c_item_info
        IS
                SELECT  msi.inventory_item_id         ,
                        msi.lot_control_code          ,
                        msi.serial_number_control_code,
                        mmtt.parent_line_id
                FROM    mtl_system_items msi,
                        mtl_material_transactions_temp mmtt
                WHERE   mmtt.transaction_temp_id = p_transaction_temp_id
                    AND msi.inventory_item_id    = mmtt.inventory_item_id
                    AND msi.organization_id      = mmtt.organization_id;
BEGIN
        l_debug         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        x_return_status := fnd_api.g_ret_sts_success;
        SAVEPOINT deltxn;
        IF l_debug = 1 THEN
                debug_print(  'Cleaning up MMTT, MTLT and MSNT for Txn Temp ID = ' || p_transaction_temp_id);
        END IF;
        OPEN c_item_info;
        FETCH   c_item_info
        INTO    l_inventory_item_id  ,
                l_lot_control_code   ,
                l_serial_control_code,
                l_parent_line_id;
        CLOSE c_item_info;
        IF l_debug = 1 THEN
                debug_print(  'Item ID        = ' || l_inventory_item_id);
                debug_print(  'Lot Control    = ' || l_lot_control_code);
                debug_print(  'Serial Control = ' || l_serial_control_code);
                debug_print(  'Parent Line ID = ' || l_parent_line_id);
        END IF;
        IF l_parent_line_id IS NOT NULL AND p_update_parent THEN
                IF l_debug = 1 THEN
                        debug_print(  'Child Record... Updating the Parent: TxnTempID = ' || l_parent_line_id);
                END IF;
                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        IF l_debug  = 1 THEN
                                debug_print('Error occurred while updating parent line in MMTT');
                        END IF;
                        ROLLBACK TO deltxn;
                        RAISE exc_not_deleted;
                END IF;
        END IF;
        -- Unmarking and Deleting all the Serials associated with the Transaction
        IF l_serial_control_code     IN(2, 5) THEN --If serial controlled
                IF l_lot_control_code = 2 THEN     -- If lot controlled also
                        SELECT  count (*)
                        INTO    l_msn_count
                        FROM    mtl_serial_numbers
                        WHERE   group_mark_id IN
                                (SELECT serial_transaction_temp_id
                                FROM    mtl_transaction_lots_temp
                                WHERE   transaction_temp_id = p_transaction_temp_id
                                );
                        IF l_msn_count > 0 THEN
                                UPDATE mtl_serial_numbers
                                        SET group_mark_id = NULL,
                                        line_mark_id      = NULL,
                                        lot_line_mark_id  = NULL
                                WHERE   group_mark_id    IN
                                        (SELECT serial_transaction_temp_id
                                        FROM    mtl_transaction_lots_temp
                                        WHERE   transaction_temp_id = p_transaction_temp_id
                                        );
                                l_unmarked_count  := SQL%ROWCOUNT;
                                IF SQL%ROWCOUNT    = 0 THEN
                                        IF l_debug = 1 THEN
                                                debug_print (   'Error updating MSN  ');
                                        END IF;
                                        ROLLBACK TO deltxn;
                                        RAISE exc_not_deleted;
                                END IF;
                        END IF;
                        SELECT  count(*)
                        INTO    l_msnt_count
                        FROM    mtl_serial_numbers_temp
                        WHERE   transaction_temp_id IN
                                (SELECT serial_transaction_temp_id
                                FROM    mtl_transaction_lots_temp
                                WHERE   transaction_temp_id = p_transaction_temp_id
                                );
                        IF l_msnt_count > 0 THEN
                                DELETE mtl_serial_numbers_temp
                                WHERE   transaction_temp_id IN
                                        (SELECT serial_transaction_temp_id
                                        FROM    mtl_transaction_lots_temp
                                        WHERE   transaction_temp_id = p_transaction_temp_id
                                        );
                                IF SQL%ROWCOUNT    = 0 THEN
                                        IF l_debug = 1 THEN
                                                debug_print (   'Error deleting MSNT  ');
                                        END IF;
                                        ROLLBACK TO deltxn;
                                        RAISE exc_not_deleted;
                                END IF;
                        END IF;
                ELSE -- only serial controlled but not lot controlled.
                        SELECT  count(*)
                        INTO    l_msn_count
                        FROM    mtl_serial_numbers
                        WHERE   group_mark_id = p_transaction_temp_id ;
                        IF l_msn_count        > 0 THEN
                                UPDATE mtl_serial_numbers
                                        SET group_mark_id = NULL,
                                        line_mark_id      = NULL,
                                        lot_line_mark_id  = NULL
                                WHERE   group_mark_id     = p_transaction_temp_id ;
                                l_unmarked_count         := SQL%ROWCOUNT;
                                IF SQL%ROWCOUNT           = 0 THEN
                                        IF l_debug        = 1 THEN
                                                debug_print (   'Error updating MSN  ');
                                        END IF;
                                        ROLLBACK TO deltxn;
                                        RAISE exc_not_deleted;
                                END IF;
                        END IF;
                        SELECT  count (*)
                        INTO    l_msnt_count
                        FROM    mtl_serial_numbers_temp
                        WHERE   transaction_temp_id = p_transaction_temp_id;
                        IF l_msnt_count             > 0 THEN
                                DELETE mtl_serial_numbers_temp
                                WHERE   transaction_temp_id = p_transaction_temp_id;
                                IF SQL%ROWCOUNT             = 0 THEN
                                        IF l_debug          = 1 THEN
                                                debug_print (  'Error deleting  MSNT ');
                                        END IF;
                                        ROLLBACK TO deltxn;
                                        RAISE exc_not_deleted;
                                END IF;
                        END IF;
                END IF;
                IF l_debug = 1 THEN
                        debug_print(  'Serials unmarked in MSN = ' || l_unmarked_count);
                        debug_print(  'Records deleted in MSNT = ' || SQL%ROWCOUNT);
                END IF;
        END IF;
        -- Deleting all the Lots associated with the Transaction
        IF l_lot_control_code = 2 THEN
                DELETE mtl_transaction_lots_temp
                WHERE   transaction_temp_id = p_transaction_temp_id;
                IF SQL%ROWCOUNT             = 0 THEN
                        IF l_debug          = 1 THEN
                                debug_print (   'Error deleting MTLT  ');
                        END IF;
                        ROLLBACK TO deltxn;
                        RAISE exc_not_deleted;
                END IF;
                IF l_debug = 1 THEN
                        debug_print(  'Records deleted in MTLT = ' || SQL%ROWCOUNT);
                END IF;
        END IF;
        SELECT  count (*)
        INTO    l_wdt_count
        FROM    wms_dispatched_tasks
        WHERE   transaction_temp_id = p_transaction_temp_id;
        IF l_wdt_count              >0 THEN
                -- Deleting the Task
                DELETE wms_dispatched_tasks WHERE transaction_temp_id = p_transaction_temp_id;
                IF l_debug = 1 THEN
                        debug_print(  'Records deleted in WDT = ' || SQL%ROWCOUNT);
                END IF;
                IF SQL%ROWCOUNT = 0 THEN
                        debug_print (   'Error deleting WDT  ');
                        ROLLBACK TO deltxn;
                        RAISE exc_not_deleted;
                END IF;
        END IF;
        -- Deleting the Transaction
        DELETE mtl_material_transactions_temp
        WHERE   transaction_temp_id = p_transaction_temp_id;
        IF SQL%ROWCOUNT             = 0 THEN
                IF l_debug          = 1 THEN
                        debug_print (   'Error deleting MMTT  ');
                END IF;
                ROLLBACK TO deltxn;
                RAISE exc_not_deleted;
        END IF;
        IF l_debug = 1 THEN
                debug_print(  'Records deleted in MMTT = ' || SQL%ROWCOUNT);
        END IF;
EXCEPTION
WHEN exc_not_deleted THEN
        IF l_debug =1 THEN
                debug_print('In the exception for could not delete a record. Returning staus as E');
        END IF;
        x_return_status := 'E';
WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF l_debug       = 1 THEN
                debug_print(  'Exception Occurred = ' || SQLERRM);
        END IF;
        ROLLBACK TO deltxn;
END delete_transaction;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE delete_details()
This procedure calls inv_reservation_pub.update_reservation() to udpate/delete reservation and subsequently
calls delete_transactions.
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE delete_details( p_transaction_temp_id IN NUMBER ,
			  p_move_order_line_id IN NUMBER ,
			  p_reservation_id IN NUMBER ,
			  p_transaction_quantity IN NUMBER ,
			  p_primary_trx_qty IN NUMBER ,
			  x_return_status OUT NOCOPY VARCHAR2 ,
			  x_msg_count OUT NOCOPY NUMBER ,
			  x_msg_data OUT NOCOPY VARCHAR2 ) IS

        l_mtl_reservation_tbl inv_reservation_global.mtl_reservation_tbl_type;
        l_mtl_reservation_rec inv_reservation_global.mtl_reservation_rec_type;
        l_mtl_reservation_tbl_count NUMBER;
        l_original_serial_number inv_reservation_global.serial_number_tbl_type;
        l_to_serial_number inv_reservation_global.serial_number_tbl_type;
        l_error_code               NUMBER;
        l_count                    NUMBER;
        l_success                  BOOLEAN;
        l_umconvert_trans_quantity NUMBER := 0;
        l_mmtt_rec inv_mo_line_detail_util.g_mmtt_rec;
        l_primary_uom             VARCHAR2(10);
        l_ato_item                NUMBER := 0;
        l_debug                   NUMBER;
        l_rsv_detailed_qty        NUMBER;
        l_rsv_reservation_qty     NUMBER;
        l_rsv_pri_reservation_qty NUMBER;
        g_retain_ato_profile      VARCHAR2(1) := fnd_profile.VALUE('WSH_RETAIN_ATO_RESERVATIONS');
        exc_not_deleted           EXCEPTION;
BEGIN
        l_debug         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        x_return_status := fnd_api.g_ret_sts_success;
        SAVEPOINT delete_details;
        IF (l_debug = 1) THEN
                debug_print(  'Transaction Temp ID = ' || p_transaction_temp_id);
                debug_print(  'Move Order Line ID  = ' || p_move_order_line_id);
                debug_print(  'Transaction Qty     = ' || p_transaction_quantity);
                debug_print(  'Reservation ID      = ' || p_reservation_id);
        END IF;
        IF p_reservation_id IS NOT NULL THEN
                l_mtl_reservation_rec.reservation_id                       := p_reservation_id;
                inv_reservation_pub.query_reservation( p_api_version_number => 1.0 ,
						       x_return_status => x_return_status ,
						       x_msg_count => x_msg_count ,
						       x_msg_data => x_msg_data ,
						       p_query_input => l_mtl_reservation_rec ,
						       x_mtl_reservation_tbl => l_mtl_reservation_tbl ,
						       x_mtl_reservation_tbl_count => l_mtl_reservation_tbl_count ,
						       x_error_code => l_error_code );

                IF l_debug                                                  = 1 THEN
                        debug_print(  'x_return_status = ' || x_return_status);
                        debug_print(  'l_error_code = ' || l_error_code);
                        debug_print(  'l_mtl_reservation_tbl_count = ' || l_mtl_reservation_tbl_count);
                END IF;
                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        IF l_debug  = 1 THEN
                                debug_print('delete_mo: Error occurred while deleting MMTT');
                        END IF;
                        ROLLBACK TO delete_details;
                        RAISE exc_not_deleted ;
                END IF;
                IF l_mtl_reservation_tbl_count > 0 THEN
                        -- If reservations exist, check if the item is an ATO Item
                        --   only if the profile WSH_RETAIN_ATO_RESERVATIONS = 'Y'
                        IF g_retain_ato_profile = 'Y' THEN
                                IF l_debug      = 1 THEN
                                        debug_print('g_retain_ato_profile = Y');
                                END IF;
                                BEGIN
                                        SELECT  1,
                                                primary_uom_code
                                        INTO    l_ato_item,
                                                l_primary_uom
                                        FROM    mtl_system_items
                                        WHERE   replenish_to_order_flag = 'Y'
                                            AND bom_item_type           = 4
                                            AND inventory_item_id       = l_mtl_reservation_tbl(1).inventory_item_id
                                            AND organization_id         = l_mtl_reservation_tbl(1).organization_id;
                                EXCEPTION
                                WHEN OTHERS THEN
                                        l_ato_item := 0;
                                END;
                        END IF;
                        IF l_debug = 1 THEN
                                debug_print(  'l_ato_item = ' || l_ato_item);
                        END IF;
                        l_rsv_detailed_qty        := NVL(l_mtl_reservation_tbl(1).detailed_quantity,0);
                        l_rsv_reservation_qty     := NVL(l_mtl_reservation_tbl(1).reservation_quantity,0);
                        l_rsv_pri_reservation_qty := NVL(l_mtl_reservation_tbl(1).primary_reservation_quantity,0);
                        IF l_ato_item              = 1 THEN
                                IF l_debug         = 1 THEN
                                        debug_print('l_ato_item = 1');
                                END IF;
                                -- If item is ato item, reduce the detailed quantity by the transaction
                                -- quantity and retain the reservation. Convert to primary uom before
                                -- reducing detailed quantity.
                                l_mmtt_rec                := inv_mo_line_detail_util.query_row(p_transaction_temp_id);
                                l_umconvert_trans_quantity:= p_transaction_quantity;
                                IF l_mmtt_rec.inventory_item_id IS NOT NULL AND l_mmtt_rec.transaction_uom IS NOT NULL THEN
                                        IF l_debug = 1 THEN
                                                debug_print(  'UOM Convert = ');
                                        END IF;
                                        l_umconvert_trans_quantity := inv_convert.inv_um_convert( item_id => l_mmtt_rec.inventory_item_id ,
												  PRECISION => NULL ,
												  from_quantity => p_transaction_quantity ,
												  from_unit => l_mmtt_rec.transaction_uom ,
												  to_unit => l_primary_uom ,
												  from_name => NULL ,
												  to_name => NULL);
                                END IF;
                                l_mtl_reservation_rec                              := l_mtl_reservation_tbl(1);
                                IF(l_rsv_detailed_qty                               > ABS(l_umconvert_trans_quantity)) THEN
                                        l_mtl_reservation_tbl(1).detailed_quantity := l_rsv_detailed_qty - ABS(l_umconvert_trans_quantity);
                                ELSE
                                        l_mtl_reservation_tbl(1).detailed_quantity := 0;
                                END IF;
                                IF l_debug = 1 THEN
                                        debug_print(  'call inv_reservation_pub.update_reservation = ');
                                END IF;
                                inv_reservation_pub.update_reservation( p_api_version_number => 1.0 ,
									x_return_status => x_return_status ,
									x_msg_count => x_msg_count ,
									x_msg_data => x_msg_data ,
									p_original_rsv_rec => l_mtl_reservation_rec ,
									p_to_rsv_rec => l_mtl_reservation_tbl(1) ,
									p_original_serial_number => l_original_serial_number ,
									p_to_serial_number => l_to_serial_number);
                                IF l_debug                                                   = 1 THEN
                                        debug_print('x_return_status' || x_return_status);
                                END IF;
                                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                                        IF l_debug  = 1 THEN
                                                debug_print('delete_mo: Error occurred while updating reservations');
                                        END IF;
                                        ROLLBACK TO delete_details;
                                        RAISE exc_not_deleted ;
                                END IF;
                        ELSE
                                l_mtl_reservation_rec := l_mtl_reservation_tbl(1);
                                l_mmtt_rec            := inv_mo_line_detail_util.query_row(p_transaction_temp_id);
                                IF l_debug             = 1 THEN
                                        debug_print(  'Allocation UOM  = ' || l_mmtt_rec.transaction_uom);
                                        debug_print(  'Reservation UOM = ' || l_mtl_reservation_rec.reservation_uom_code);
                                END IF;
                                IF l_mmtt_rec.transaction_uom      <> l_mtl_reservation_rec.reservation_uom_code THEN
                                        l_umconvert_trans_quantity := inv_convert.inv_um_convert( item_id => l_mmtt_rec.inventory_item_id ,
												  PRECISION => NULL ,
												  from_quantity => ABS(p_transaction_quantity) ,
												  from_unit => l_mmtt_rec.transaction_uom ,
												  to_unit => l_mtl_reservation_rec.reservation_uom_code ,
												  from_name => NULL ,
												  to_name => NULL);
                                ELSE
                                        l_umconvert_trans_quantity := ABS(p_transaction_quantity);
                                END IF;
                                IF l_debug = 1 THEN
                                        debug_print(  'After UOM Conversion TxnQty = ' || l_umconvert_trans_quantity);
                                END IF;
                                IF(l_rsv_detailed_qty                               > ABS(p_transaction_quantity)) THEN
                                        l_mtl_reservation_tbl(1).detailed_quantity := l_rsv_detailed_qty - ABS(p_transaction_quantity);
                                ELSE
                                        l_mtl_reservation_tbl(1).detailed_quantity := 0;
                                END IF;
                                IF(l_rsv_reservation_qty                               > ABS(l_umconvert_trans_quantity)) THEN
                                        l_mtl_reservation_tbl(1).reservation_quantity := l_rsv_reservation_qty - ABS(l_umconvert_trans_quantity);
                                ELSE
                                        l_mtl_reservation_tbl(1).reservation_quantity := 0;
                                END IF;
                                IF(l_rsv_pri_reservation_qty                                   > ABS(p_primary_trx_qty)) THEN
                                        l_mtl_reservation_tbl(1).primary_reservation_quantity := l_rsv_pri_reservation_qty - ABS(p_primary_trx_qty);
                                ELSE
                                        l_mtl_reservation_tbl(1).primary_reservation_quantity := 0;
                                END IF;
                                inv_reservation_pub.update_reservation( p_api_version_number => 1.0 ,
									x_return_status => x_return_status ,
									x_msg_count => x_msg_count ,
									x_msg_data => x_msg_data ,
									p_original_rsv_rec => l_mtl_reservation_rec ,
									p_to_rsv_rec => l_mtl_reservation_tbl(1) ,
									p_original_serial_number => l_original_serial_number ,
									p_to_serial_number => l_to_serial_number);

                                IF l_debug                                                   = 1 THEN
                                        debug_print(  'x_return_status from inv_reservation_pub.update_reservation ' || x_return_status);
                                END IF;
                                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                                        IF l_debug  = 1 THEN
                                                debug_print('delete_mo: Error occurred while updating reservations');
                                        END IF;
                                        ROLLBACK TO delete_details;
                                        RAISE exc_not_deleted ;
                                END IF;
                        END IF; -- reservation count > 0
                END IF;         -- ato item check
        END IF;
        IF l_debug = 1 THEN
                debug_print(  'call delete_transaction ' );
        END IF;
        delete_transaction( x_return_status => x_return_status ,
			    x_msg_data => x_msg_data ,
			    x_msg_count => x_msg_count ,
			    p_transaction_temp_id => p_transaction_temp_id ,
			    p_update_parent => FALSE);
        IF l_debug                          = 1 THEN
                debug_print(  'x_return_status ' || x_return_status);
        END IF;
        IF x_return_status = fnd_api.g_ret_sts_error THEN
                IF l_debug = 1 THEN
                        debug_print('delete_mo: Error occurred while deleting MMTT');
                END IF;
                ROLLBACK TO delete_details;
                RAISE exc_not_deleted ;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF l_debug    = 1 THEN
                        debug_print('delete_mo: Error occurred while deleting MMTT');
                END IF;
                ROLLBACK TO delete_details;
        END IF;
EXCEPTION
WHEN exc_not_deleted THEN
        IF l_debug =1 THEN
                debug_print('In the exception for could not delete a record. Returning staus as E');
        END IF;
        x_return_status := 'E';
WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        ROLLBACK TO delete_details;
END delete_details;

-------------------------------------------------------------------------------------------------------------------

PROCEDURE backorder_source( x_return_status OUT NOCOPY VARCHAR2 ,
			    x_msg_count OUT NOCOPY NUMBER ,
			    x_msg_data OUT NOCOPY VARCHAR2 ,
			    p_move_order_type NUMBER ,
			    p_mo_line_rec inv_move_order_pub.trolin_rec_type ,
			    p_qty_to_backorder NUMBER ) IS

        l_shipping_attr wsh_interface.changedattributetabtype;
        l_released_status    VARCHAR2(1);
        l_delivery_detail_id NUMBER;
        l_source_header_id   NUMBER;
        l_source_line_id     NUMBER;
        l_qty_to_backorder   NUMBER := 0;
        l_debug              NUMBER;
        exc_not_deleted      EXCEPTION;
        CURSOR c_wsh_info
        IS
                SELECT  delivery_detail_id,
                        oe_header_id      ,
                        oe_line_id        ,
                        released_status
                FROM    wsh_inv_delivery_details_v
                WHERE   move_order_line_id = p_mo_line_rec.line_id
                    AND move_order_line_id IS NOT NULL
                    AND released_status = 'S';
BEGIN
        SAVEPOINT backorder_source;
        x_return_status            := fnd_api.g_ret_sts_success;
        l_debug                    := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        l_qty_to_backorder         := p_qty_to_backorder;
        IF l_qty_to_backorder       < 0 THEN
                l_qty_to_backorder := 0;
        END IF;
        IF l_debug = 1 THEN
                debug_print('l_qty_to_backorder' || l_qty_to_backorder);
        END IF;
        IF p_move_order_type = inv_globals.g_move_order_pick_wave THEN
                IF l_debug   = 1 THEN
                        debug_print('in mo type pick wave' );
                END IF;
                OPEN c_wsh_info;
                FETCH   c_wsh_info
                INTO    l_delivery_detail_id,
                        l_source_header_id  ,
                        l_source_line_id    ,
                        l_released_status;
                IF c_wsh_info%NOTFOUND THEN
                        CLOSE c_wsh_info;
                        IF l_debug = 1 THEN
                                debug_print('NOTFOUND c_wsh_info' );
                        END IF;
                        RAISE fnd_api.g_exc_error;
                END IF;
                CLOSE c_wsh_info;
                IF l_debug = 1 THEN
                        debug_print('finished fetching' );
                END IF;
                --Call Update_Shipping_Attributes to backorder detail line
                l_shipping_attr(1).source_header_id     := l_source_header_id;
                l_shipping_attr(1).source_line_id       := l_source_line_id;
                l_shipping_attr(1).ship_from_org_id     := p_mo_line_rec.organization_id;
                l_shipping_attr(1).released_status      := l_released_status;
                l_shipping_attr(1).delivery_detail_id   := l_delivery_detail_id;
                l_shipping_attr(1).action_flag          := 'B';
                l_shipping_attr(1).cycle_count_quantity := l_qty_to_backorder;
                l_shipping_attr(1).subinventory         := p_mo_line_rec.from_subinventory_code;
                l_shipping_attr(1).locator_id           := p_mo_line_rec.from_locator_id;
                IF (l_debug                              = 1) THEN
                        debug_print('Calling Update Shipping Attributes');
                        debug_print(  '  Source Header ID   = ' || l_shipping_attr(1).source_header_id);
                        debug_print(  '  Source Line ID     = ' || l_shipping_attr(1).source_line_id);
                        debug_print(  '  Ship From Org ID   = ' || l_shipping_attr(1).ship_from_org_id);
                        debug_print(  '  Released Status    = ' || l_shipping_attr(1).released_status);
                        debug_print(  '  Delivery Detail ID = ' || l_shipping_attr(1).delivery_detail_id);
                        debug_print(  '  Action Flag        = ' || l_shipping_attr(1).action_flag);
                        debug_print(  '  Cycle Count Qty    = ' || l_shipping_attr(1).cycle_count_quantity);
                        debug_print(  '  Subinventory       = ' || l_shipping_attr(1).subinventory);
                        debug_print(  '  Locator ID         = ' || l_shipping_attr(1).locator_id);
                END IF;
                wsh_interface.update_shipping_attributes( p_source_code => 'INV' ,
							  p_changed_attributes => l_shipping_attr ,
							  x_return_status => x_return_status );
                IF (l_debug                                             = 1) THEN
                        debug_print(  'Updated Shipping Attributes - Return Status = ' || x_return_status);
                END IF;
                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        ROLLBACK TO backorder_source;
                        RAISE exc_not_deleted ;
                END IF;
        ELSIF p_move_order_type = inv_globals.g_move_order_mfg_pick THEN
                IF l_debug      = 1 THEN
                        debug_print('Calling Unallocate WIP Material');
                        debug_print(  '  WIP Entity ID     = ' || p_mo_line_rec.txn_source_id);
                        debug_print(  '  Operation Seq Num = ' || p_mo_line_rec.txn_source_line_id);
                        debug_print(  '  Inventory Item ID = ' || p_mo_line_rec.inventory_item_id);
                        debug_print(  '  Repetitive Sch ID = ' || p_mo_line_rec.reference_id);
                        debug_print(  '  Primary Qty       = ' || l_qty_to_backorder);
                END IF;
                wip_picking_pub.unallocate_material( x_return_status => x_return_status ,
						     x_msg_data => x_msg_data ,
						     p_wip_entity_id => p_mo_line_rec.txn_source_id ,
						     p_operation_seq_num => p_mo_line_rec.txn_source_line_id ,
						     p_inventory_item_id => p_mo_line_rec.inventory_item_id ,
						     p_repetitive_schedule_id => p_mo_line_rec.reference_id ,
						     p_primary_quantity => l_qty_to_backorder );

                IF (l_debug                                          = 1) THEN
                        debug_print(  'Unallocated WIP Material  - Return Status = ' || x_return_status);
                END IF;
                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        ROLLBACK TO backorder_source;
                        RAISE exc_not_deleted ;
                END IF;
        END IF;
EXCEPTION
WHEN exc_not_deleted THEN
        IF l_debug =1 THEN
                debug_print('In the exception for could not delete a record. Returning staus as E');
        END IF;
        x_return_status := 'E';
WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        ROLLBACK TO backorder_source;
END backorder_source;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE backorder()
This procedure calls wsh_interface.update_shipping_attributes() for MO of type pick wave, else calls
wip_picking_pub.unallocate_material for MO of type WIP
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE backorder( p_line_id IN NUMBER ,
		     p_transaction_temp_id IN NUMBER ,
		     x_return_status OUT NOCOPY VARCHAR2 ,
		     x_msg_count OUT NOCOPY NUMBER ,
		     x_msg_data OUT NOCOPY VARCHAR2 ) IS

        l_mo_line_rec inv_move_order_pub.trolin_rec_type;
        l_mold_tbl inv_mo_line_detail_util.g_mmtt_tbl_type;
        l_mo_type              NUMBER;
        l_allow_backordering   VARCHAR2(1) := 'Y';
        l_debug                NUMBER;
        l_transaction_quantity NUMBER;
        exc_not_deleted        EXCEPTION;
        CURSOR c_allow_backordering
        IS
                SELECT 'N'
                FROM    DUAL
                WHERE   EXISTS
                        (SELECT 1
                        FROM    wms_dispatched_tasks wdt,
                                mtl_material_transactions_temp mmtt
                        WHERE   mmtt.move_order_line_id = l_mo_line_rec.line_id
                            AND wdt.transaction_temp_id = nvl(mmtt.parent_line_id, mmtt.transaction_temp_id)
                            AND wdt.status             IN (4,9)
                        );
        CURSOR c_mo_type
        IS
                SELECT  mtrh.move_order_type
                FROM    mtl_txn_request_headers mtrh,
                        mtl_txn_request_lines mtrl
                WHERE   mtrl.line_id   = l_mo_line_rec.line_id
                    AND mtrh.header_id = mtrl.header_id;
        CURSOR c_mmtt_info
        IS
                SELECT  mmtt.transaction_temp_id                            ,
                        ABS(mmtt.primary_quantity) primary_quantity         ,
                        ABS(mmtt.transaction_quantity) transaction_quantity ,
                        mmtt.reservation_id
                FROM    mtl_material_transactions_temp mmtt
                WHERE   mmtt.move_order_line_id = p_line_id
                    AND NOT EXISTS
                        (SELECT 1
                        FROM    mtl_material_transactions_temp t
                        WHERE   t.parent_line_id = mmtt.transaction_temp_id
                        )
                        FOR UPDATE NOWAIT;
BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
        l_debug         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        -- Set savepoint
        SAVEPOINT backorder;
        IF (l_debug = 1) THEN
                debug_print(  'Backordering for MO Line ID = ' || p_line_id);
        END IF;
        l_mo_line_rec := query_rows(p_line_id)(1);
        -- Querying the Move Order Type of the Line.
        OPEN c_mo_type;
        FETCH c_mo_type INTO l_mo_type;
        CLOSE c_mo_type;
        IF l_debug = 1 THEN
                debug_print(  'l_mo_type = ' || l_mo_type);
        END IF;
        IF (inv_install.adv_inv_installed(l_mo_line_rec.organization_id)) THEN
                OPEN c_allow_backordering;
                FETCH c_allow_backordering INTO l_allow_backordering;
                CLOSE c_allow_backordering;
        END IF;
        IF (l_debug = 1) THEN
                debug_print(  'Allow BackOrdering = ' || l_allow_backordering);
                debug_print('p_transaction_temp_id' || p_transaction_temp_id);
        END IF;
        SELECT  transaction_quantity
        INTO    l_transaction_quantity
        FROM    mtl_material_transactions_temp
        WHERE   transaction_temp_id = p_transaction_temp_id;
        IF l_debug                  = 1 THEN
                debug_print('l_transaction_quantity' || l_transaction_quantity);
        END IF;
        IF (l_allow_backordering                                                                      = 'Y') THEN
                IF NVL(l_mo_line_rec.quantity_detailed, 0) - NVL(l_mo_line_rec.quantity_delivered, 0) > 0 THEN
                        IF l_debug                                                                    = 1 THEN
                                debug_print(  'Before for loop.. l_mmtt_info ' );
                        END IF;
                        FOR l_mmtt_info IN c_mmtt_info
                        LOOP
                                IF l_debug = 1 THEN
                                        debug_print(  'In for loop.. l_mmtt_info ' );
                                        debug_print(  'l_mmtt_info.transaction_temp_id.. ' || l_mmtt_info.transaction_temp_id );
                                        debug_print(  'p_line_id.. ' || p_line_id);
                                        debug_print(  'l_mmtt_info.reservation_id.. ' || l_mmtt_info.reservation_id);
                                        debug_print(  'l_mmtt_info.transaction_quantity.. ' || l_mmtt_info.transaction_quantity);
                                        debug_print(  'l_mmtt_info.primary_quantity.. ' || l_mmtt_info.primary_quantity);
                                END IF;
                                delete_details( x_return_status => x_return_status ,
						x_msg_data => x_msg_data ,
						x_msg_count => x_msg_count ,
						p_transaction_temp_id => l_mmtt_info.transaction_temp_id ,
						p_move_order_line_id => p_line_id ,
						p_reservation_id => l_mmtt_info.reservation_id ,
						p_transaction_quantity => l_mmtt_info.transaction_quantity ,
						p_primary_trx_qty => l_mmtt_info.primary_quantity );

                                IF l_debug                      = 1 THEN
                                        debug_print(  'x_return_status ' || x_return_status);
                                END IF;
                                IF x_return_status = fnd_api.g_ret_sts_error THEN
                                        IF l_debug = 1 THEN
                                                debug_print('Error occurred while back ordering');
                                        END IF;
                                        ROLLBACK TO backorder;
                                        RAISE exc_not_deleted ;
                                ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                        IF l_debug    = 1 THEN
                                                debug_print('Unexpected error occurred while back ordering');
                                        END IF;
                                        ROLLBACK TO backorder;
                                END IF;
                        END LOOP;
                END IF;
                IF l_debug = 1 THEN
                        debug_print(  'Before calling backorder_source ');
                        debug_print('l_mo_type' || l_mo_type);
                END IF;
                backorder_source( x_return_status => x_return_status ,
				  x_msg_data => x_msg_data ,
				  x_msg_count => x_msg_count ,
				  p_move_order_type => l_mo_type ,
				  p_mo_line_rec => l_mo_line_rec ,
				  p_qty_to_backorder => l_transaction_quantity );

                IF l_debug                        = 1 THEN
                        debug_print(  'x_return_status ' || x_return_status);
                END IF;
                IF x_return_status = fnd_api.g_ret_sts_error THEN
                        IF l_debug = 1 THEN
                                debug_print('Error occurred while back ordering');
                        END IF;
                        ROLLBACK TO backorder;
                        RAISE exc_not_deleted ;
                ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        IF l_debug    = 1 THEN
                                debug_print('Unexpected Error occurred while back ordering');
                        END IF;
                        ROLLBACK TO backorder;
                END IF;
                IF l_debug = 1 THEN
                        debug_print(  'Updating Move Order Line to set Status = 5 and Qty Detailed = '
				      || l_mo_line_rec.quantity_delivered);
                        debug_print(  'Updating Move Order Line Quantity = ' || l_mo_line_rec.quantity_delivered);
                END IF;
                UPDATE mtl_txn_request_lines
                SET     line_status       = 5                         ,
                        quantity_detailed = NVL(quantity_delivered,0) ,
                        quantity          = NVL(quantity_delivered,0)
                WHERE   line_id           = p_line_id;
                IF SQL%ROWCOUNT           = 0 THEN
                        IF l_debug        = 1 THEN
                                debug_print (  'Error updating MTRL::: ');
                        END IF;
                        ROLLBACK TO backorder;
                        RAISE exc_not_deleted ;
                END IF;
        END IF;
        IF l_debug = 1 THEN
                debug_print(  'check MO type ' || l_mo_type);
        END IF;
        IF l_mo_type       = inv_globals.g_move_order_pick_wave THEN
                IF l_debug = 1 THEN
                        debug_print(  'before calling inv_transfer_order_pvt.clean_reservations ' || l_mo_line_rec.txn_source_line_id);
                END IF;
                inv_transfer_order_pvt.clean_reservations( p_source_line_id => l_mo_line_rec.txn_source_line_id ,
							   x_return_status => x_return_status ,
							   x_msg_count => x_msg_count ,
							   x_msg_data => x_msg_data );

                IF l_debug                                                  = 1 THEN
                        debug_print(  'x_return_status ' || x_return_status);
                END IF;
                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        IF l_debug  = 1 THEN
                                debug_print(  'Error occurred while cleaning reservation ');
                        END IF;
                        ROLLBACK TO backorder;
                        RAISE exc_not_deleted ;
                END IF;
        END IF;
EXCEPTION
WHEN exc_not_deleted THEN
        IF l_debug =1 THEN
                debug_print('In the exception for could not delete a record. Returning staus as E');
        END IF;
        x_return_status := 'E';
WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        ROLLBACK TO backorder;
END backorder;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE DELETE_OUTBOUND_TASKS()
This is the proceudre called from the DELETE_TASKS API when the task is an Outbound task.
Deletes Sales Orders, Internal Orders and WIP Pick tasks.
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE DELETE_OUTBOUND_TASKS (p_task_rec IN task_record_type,
				 x_task_rec OUT NOCOPY task_record_type,
				 x_return_status OUT NOCOPY VARCHAR2) IS

        l_transaction_number    NUMBER ;
        l_other_mmtt_count      NUMBER;
        l_progress              VARCHAR2(30) := '100';
        l_update_parent         BOOLEAN      := FALSE ;  -- No need to call update_parent_mmtt
        x_msg_count             NUMBER;
        x_msg_data              VARCHAR2(50);
        l_g_ret_sts_error       CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_error;
        l_g_ret_sts_unexp_error CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_unexp_error;
        l_g_ret_sts_success     CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_success;
        l_reservation_id        NUMBER;
        l_pri_rsv_qty           NUMBER;
        l_rsv_qty               NUMBER;
        l_pri_rsv_uom           VARCHAR2(3);
        l_rsv_uom               VARCHAR2(3);
        l_old_upd_resv_rec inv_reservation_global.mtl_reservation_rec_type;
        l_new_upd_resv_rec inv_reservation_global.mtl_reservation_rec_type;
        l_upd_dummy_sn inv_reservation_global.serial_number_tbl_type;
        l_task_table WMS_TASK_MGMT_PUB.task_tab_type ;
        l_task_rec WMS_TASK_MGMT_PUB.task_output_rectype;
        l_transaction_record mtl_material_transactions_temp%rowtype ; --MMTT rec
        l_move_order_rec mtl_txn_request_lines%rowtype ;              --MTRL rec
        l_mo_line_rec inv_move_order_pub.trolin_rec_type;
        l_mo_type       NUMBER;
        l_wdt_count     NUMBER;
        l_debug         NUMBER;
        exc_not_deleted EXCEPTION;
        CURSOR c_mmtt_info
        IS
                SELECT  mmtt.transaction_temp_id ,
                        mmtt.parent_line_id    --For checking bulk task
                        ,
                        mmtt.inventory_item_id    ,
                        mmtt.move_order_line_id   ,
                        mmtt.transaction_uom      ,
                        mmtt.primary_quantity     ,
                        mmtt.transaction_quantity ,
                        mmtt.wms_task_type
                FROM    mtl_material_transactions_temp mmtt
                WHERE   mmtt.transaction_temp_id = l_transaction_number
                    AND NOT EXISTS
                        (SELECT 1
                        FROM    mtl_material_transactions_temp t1
                        WHERE   t1.parent_line_id = mmtt.transaction_temp_id
                        )
        UNION ALL
        SELECT  mmtt.transaction_temp_id ,
                mmtt.parent_line_id            --For checking bulk task
                ,
                mmtt.inventory_item_id    ,
                mmtt.move_order_line_id   ,
                mmtt.transaction_uom      ,
                mmtt.primary_quantity     ,
                mmtt.transaction_quantity ,
                mmtt.wms_task_type
        FROM    mtl_material_transactions_temp mmtt
        WHERE   mmtt.parent_line_id  = l_transaction_number
            AND mmtt.parent_line_id <> mmtt.transaction_temp_id;
-- This union by will end up getting all PARENTS too *****
CURSOR c_mo_line_info
IS
        SELECT  mtrl.uom_code                   ,
                mtrl.transaction_source_type_id ,
                mtrl.transaction_type_id
        FROM    mtl_txn_request_lines mtrl
        WHERE   mtrl.line_id = l_transaction_record.move_order_line_id;
CURSOR c_get_other_mmtt
IS
        SELECT  COUNT(*)
        FROM    mtl_material_transactions_temp mmtt
        WHERE   mmtt.move_order_line_id   = l_transaction_record.move_order_line_id
            AND mmtt.transaction_temp_id <> l_transaction_record.transaction_temp_id
            AND NOT EXISTS
                (SELECT 1
                FROM    mtl_material_transactions_temp t1
                WHERE   t1.parent_line_id = mmtt.transaction_temp_id
                );
CURSOR c_mo_type
IS
        SELECT  mtrh.move_order_type
        FROM    mtl_txn_request_headers mtrh,
                mtl_txn_request_lines mtrl
        WHERE   mtrl.line_id   = l_transaction_record.move_order_line_id
            AND mtrh.header_id = mtrl.header_id;
BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
        l_progress      := '110';
        l_debug         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        IF (l_debug      = 1) THEN
                debug_print('IN DELETE_OUTBOUND_TASKS');
                debug_print (  'l_progress: ' || l_progress );
        END IF;
        SAVEPOINT delso;
        l_transaction_number := p_task_rec.transaction_number;
        IF l_debug            = 1 THEN
                debug_print (  'l_transaction_number ' || l_transaction_number );
        END IF;
        OPEN c_mmtt_info;
        LOOP
                FETCH   c_mmtt_info
                INTO    l_transaction_record.transaction_temp_id  ,
                        l_transaction_record.parent_line_id       ,
                        l_transaction_record.inventory_item_id    ,
                        l_transaction_record.move_order_line_id   ,
                        l_transaction_record.transaction_uom      ,
                        l_transaction_record.primary_quantity     ,
                        l_transaction_record.transaction_quantity ,
                        l_transaction_record.wms_task_type;
                EXIT
        WHEN c_mmtt_info%NOTFOUND;
                l_progress := '120';
                IF (l_debug = 1) THEN
                        debug_print (  'delete_so: l_progress: ' || l_progress );
                        debug_print (  'delete_so: l_transaction_record.transaction_temp_id ' || l_transaction_record.transaction_temp_id );
                        debug_print (  'delete_so: l_transaction_record.parent_line_id ' || l_transaction_record.parent_line_id );
                        debug_print (  'delete_so: l_transaction_record.inventory_item_id ' || l_transaction_record.inventory_item_id );
                        debug_print (  'delete_so: l_transaction_record.move_order_line_id ' || l_transaction_record.move_order_line_id );
                        debug_print (  'delete_so: l_transaction_record.transaction_uom ' || l_transaction_record.transaction_uom );
                        debug_print (  'delete_so: l_transaction_record.primary_quantity ' || l_transaction_record.primary_quantity );
                        debug_print (  'delete_so: l_transaction_record.transaction_quantity ' || l_transaction_record.transaction_quantity );
                        debug_print (  'delete_so: l_transaction_record.wms_task_type ' || l_transaction_record.wms_task_type );
                END IF;
                OPEN c_mo_line_info;
                FETCH   c_mo_line_info
                INTO    l_move_order_rec.uom_code                  ,
                        l_move_order_rec.transaction_source_type_id,
                        l_move_order_rec.transaction_type_id;
                CLOSE c_mo_line_info;
                l_progress := '125';
                IF (l_debug = 1) THEN
                        debug_print (  'delete_so: l_progress: ' || l_progress );
                        debug_print('delete_so: l_move_order_rec.uom_code :'|| l_move_order_rec.uom_code);
                        debug_print('delete_so: l_move_order_rec.transaction_source_type_id :'|| l_move_order_rec.transaction_source_type_id);
                        debug_print('delete_so: l_move_order_rec.transaction_type_id :'|| l_move_order_rec.transaction_type_id);
                END IF;
                l_progress := '135';
                OPEN c_get_other_mmtt;
                FETCH c_get_other_mmtt INTO l_other_mmtt_count;
                CLOSE c_get_other_mmtt;
                IF (l_debug = 1) THEN
                        debug_print (  'delete_so: l_progress: ' || l_progress );
                        debug_print(  'delete_so: Number of MMTTs other than this MMTT : ' || l_other_mmtt_count);
                END IF;
                IF l_other_mmtt_count > 0 THEN
                        IF (l_debug   = 1) THEN
                                debug_print('delete_so: Other MMTT lines exist too. So cant close MO Line');
                        END IF;
                        l_progress := '140';
                        BEGIN
                                IF (l_debug = 1) THEN
                                        debug_print (  'delete_so: l_progress: ' || l_progress );
                                        debug_print(  'delete_so: Before we update MO and delete MMTT, we need to update reservation ');
                                END IF;
                                SELECT  nvl(mmtt.reservation_id,-1)     ,
                                        mr.primary_reservation_quantity ,
                                        mr.reservation_quantity         ,
                                        mr.primary_uom_code             ,
                                        mr.reservation_uom_code
                                INTO    l_reservation_id ,
                                        l_pri_rsv_qty    ,
                                        l_rsv_qty        ,
                                        l_pri_rsv_uom    ,
                                        l_rsv_uom
                                FROM    mtl_material_transactions_temp mmtt ,
                                        mtl_reservations mr
                                WHERE   mmtt.transaction_temp_id = l_transaction_record.transaction_temp_id
                                    AND mr.reservation_id        = mmtt.reservation_id ;
                                IF (l_debug                      = 1) THEN
                                        debug_print('delete_so: l_reservation_id:'||l_reservation_id || ' ,l_pri_rsv_qty :' ||l_pri_rsv_qty||',l_rsv_qty :'||l_rsv_qty );
                                        debug_print('delete_so: MMTT.pri_qty:'||l_transaction_record.primary_quantity ||' ,l_pri_rsv_uom :'||l_pri_rsv_uom||',l_rsv_uom :'||l_rsv_uom );
                                END IF;
                                IF (l_rsv_qty                                            > l_transaction_record.primary_quantity ) THEN
                                        l_old_upd_resv_rec.reservation_id               := l_reservation_id ;
                                        l_new_upd_resv_rec.primary_reservation_quantity := l_pri_rsv_qty - l_transaction_record.primary_quantity ;
                                        IF (l_pri_rsv_uom                               <> l_rsv_uom ) THEN
                                                l_new_upd_resv_rec.reservation_quantity := l_rsv_qty - INV_Convert.inv_um_convert ( item_id => l_transaction_record.inventory_item_id,
													precision => null,
													from_quantity => l_transaction_record.primary_quantity ,
													from_unit => l_pri_rsv_uom,
													to_unit => l_rsv_uom,
													from_name => null,
													to_name => null );
                                        ELSE
                                                l_new_upd_resv_rec.reservation_quantity := l_rsv_qty - l_transaction_record.primary_quantity ;
                                        END IF;
                                        IF (l_debug = 1) THEN
                                                debug_print(  'delete_so: Calling update_reservation api : ' );
                                        END IF;
                                        inv_reservation_pub.update_reservation( p_api_version_number => 1.0 ,
										p_init_msg_lst => fnd_api.g_false ,
										x_return_status => x_return_status ,
										x_msg_count => x_msg_count ,
										x_msg_data => x_msg_data ,
										p_original_rsv_rec => l_old_upd_resv_rec ,
										p_to_rsv_rec => l_new_upd_resv_rec ,
										p_original_serial_number => l_upd_dummy_sn ,
										p_to_serial_number => l_upd_dummy_sn ,
										p_validation_flag => fnd_api.g_true );

                                        IF (l_debug                                                  = 1) THEN
                                                debug_print(  'delete_so: return of update_reservation api : ' || x_return_status);
                                        END IF;
                                        IF x_return_status <> fnd_api.g_ret_sts_success THEN
                                                x_task_rec := p_task_rec;
                                                IF (l_debug = 1) THEN
                                                        debug_print(  'delete_so: Error updating reservation ' );
                                                END IF;
                                                ROLLBACK TO delso;
                                                RAISE exc_not_deleted ;
                                        END IF;
                                END IF;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                IF (l_debug = 1) THEN
                                        debug_print(   'delete_so: There is no reservation for this MMTT  ' );
                                END IF;
                        WHEN OTHERS THEN
                                IF (l_debug = 1) THEN
                                        debug_print(  'delete_so: OTHERS EXCEPTION !!!! while Updating reservation ' );
                                END IF;
                                x_return_status:= fnd_api.g_ret_sts_unexp_error ;
                                ROLLBACK TO delso;
                        END;
                        l_progress                         := '145';
                        delete_transaction( x_return_status => x_return_status ,
					    x_msg_data => x_msg_data ,
					    x_msg_count => x_msg_count ,
					    p_transaction_temp_id => l_transaction_record.transaction_temp_id ,
					    p_update_parent => l_update_parent );

                        IF l_debug                          = 1 THEN
                                debug_print(  'x_return_status ' || x_return_status);
                        END IF;
                        IF x_return_status = fnd_api.g_ret_sts_error THEN
                                IF l_debug = 1 THEN
                                        debug_print (  'delete_so: l_progress: ' || l_progress );
                                        debug_print('delete_so: Error occurred while deleting MMTT');
                                END IF;
                                x_task_rec := p_task_rec;
                                ROLLBACK TO delso;
                                RAISE exc_not_deleted ;
                        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                IF l_debug    = 1 THEN
                                        debug_print('delete_mo: Error occurred while deleting MMTT');
                                END IF;
                                ROLLBACK TO delso;
                        END IF;
                        IF l_debug = 1 THEN
                                debug_print (  'l_transaction_record.transaction_quantity ' || l_transaction_record.transaction_quantity);
                                debug_print (  'l_transaction_record.move_order_line_id ' || l_transaction_record.move_order_line_id);
                        END IF;
                        UPDATE mtl_txn_request_lines
                        SET     quantity_detailed = quantity_detailed - l_transaction_record.transaction_quantity
                        WHERE   line_id           = l_transaction_record.move_order_line_id;
                        IF SQL%ROWCOUNT           = 0 THEN
                                IF l_debug        = 1 THEN
                                        debug_print (  'delete_so: error updateing  MTRL::: ');
                                END IF;
                                ROLLBACK TO delso;
                                RAISE exc_not_deleted ;
                        END IF;
                        -- Querying the Move Order Type of the Line.
                        OPEN c_mo_type;
                        FETCH c_mo_type INTO l_mo_type;
                        CLOSE c_mo_type;
                        IF l_debug = 1 THEN
                                debug_print (  'delete_so: l_mo_type::: ' || l_mo_type);
                        END IF;
                        l_mo_line_rec                   := inv_trolin_util.query_row(l_transaction_record.move_order_line_id);
                        backorder_source(x_return_status => x_return_status ,
					 x_msg_data => x_msg_data ,
					 x_msg_count => x_msg_count ,
					 p_move_order_type => l_mo_type ,
					 p_mo_line_rec => l_mo_line_rec ,
					 p_qty_to_backorder => l_transaction_record.primary_quantity);

                        IF x_return_status               = fnd_api.g_ret_sts_error THEN
                                IF l_debug               = 1 THEN
                                        debug_print('delete_so: Error occurred while backordering WDD');
                                END IF;
                                x_task_rec := p_task_rec;
                                ROLLBACK TO delso;
                                RAISE exc_not_deleted ;
                        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                IF l_debug    = 1 THEN
                                        debug_print('Unexpected Error occurred while backordering WDD');
                                END IF;
                                ROLLBACK TO delso;
                        END IF;
                ELSE --IF l_other_mmtt_count > 0
                        l_progress := '150';
                        if (l_debug = 1) THEN
                                debug_print (  'delete_so: l_progress: ' || l_progress );
                                debug_print('delete_so: Just one MMTT line exists. Close MO');
                        END IF;
                        l_progress := '155';
                        SELECT  count(*)
                        INTO    l_wdt_count
                        FROM    wms_dispatched_tasks
                        WHERE   transaction_temp_id = l_transaction_number;
                        IF l_wdt_count              > 0 THEN
                                DELETE
                                FROM    wms_dispatched_tasks
                                WHERE   transaction_temp_id = l_transaction_number;
                                IF SQL%ROWCOUNT             = 0 THEN
                                        IF l_debug          = 1 THEN
                                                debug_print (  'delete_so: l_progress: ' || l_progress );
                                                debug_print (  'delete_so: error deleting WDT::: ');
                                        END IF;
                                        x_task_rec := p_task_rec;
                                        ROLLBACK TO delso;
                                        RAISE exc_not_deleted ;
                                END IF;
                        END IF;
                        backorder( p_line_id => l_transaction_record.move_order_line_id ,p_transaction_temp_id => l_transaction_record.transaction_temp_id , x_return_status => x_return_status , x_msg_count => x_msg_count , x_msg_data => x_msg_data );
                        IF l_debug           = 1 THEN
                                debug_print(  'x_return_status ' || x_return_status);
                        END IF;
                        IF x_return_status = fnd_api.g_ret_sts_error THEN
                                IF l_debug = 1 THEN
                                        debug_print('delete_so: Unexpected error occurrend while calling BackOrder API');
                                END IF;
                                x_task_rec := p_task_rec;
                                ROLLBACK TO delso;
                                RAISE exc_not_deleted ;
                        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                IF l_debug    = 1 THEN
                                        debug_print('delete_so: Unexpected error occurred  while calling BackOrder API');
                                END IF;
                                ROLLBACK TO delso;
                        END IF;
                END IF;
        END LOOP;
        l_progress := '160';
        -- For checking Bulk task.Check if l_transaction_number passed is also
        --parent line id.If it's bulk task then call delete transaction.
        IF l_transaction_record.parent_line_id = l_transaction_number THEN
                IF l_debug                     = 1 THEN
                        debug_print('delete_so: Now calling delete transaction for parent line');
                END IF;
                delete_transaction( x_return_status => x_return_status ,
				    x_msg_data => x_msg_data ,
				    x_msg_count => x_msg_count ,
				    p_transaction_temp_id => l_transaction_record.parent_line_id ,
				    p_update_parent => l_update_parent );

                IF l_debug                          = 1 THEN
                        debug_print(  'x_return_status ' || x_return_status);
                END IF;
                IF x_return_status = fnd_api.g_ret_sts_error THEN
                        IF l_debug = 1 THEN
                                debug_print('delete_so: Error occurred while deleting parent line in MMTT');
                        END IF;
                        x_task_rec := p_task_rec;
                        ROLLBACK TO delso;
                        RAISE exc_not_deleted ;
                ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        IF l_debug    = 1 THEN
                                debug_print('delete_so: Error occurred while deleting MMTT');
                        END IF;
                        ROLLBACK TO delso;
                END IF;
        END IF; --for parent line IF
        CLOSE c_mmtt_info;
EXCEPTION
WHEN exc_not_deleted THEN
        IF l_debug =1 THEN
                debug_print('In the exception, could not delete a record. Returning staus as E');
        END IF;
        x_task_rec.status :='E';
        x_task_rec.ERROR  := 'Error while deleting Outbound Task';
        x_return_status   := 'E';
WHEN OTHERS THEN
        IF l_debug = 1 THEN
                debug_print('delete_so: In the When Others Exception, Rolling back.');
        END IF;
        x_task_rec        := p_task_rec;
        x_task_rec.ERROR  := 'Unexpected Error Occurred';
        x_task_rec.status :='E';
        x_return_status   := l_g_ret_sts_unexp_error;
        ROLLBACK TO delso;
END DELETE_OUTBOUND_TASKS;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE DELETE_MO_TASKS()
This is the proceudre called from the DELETE_TASKS API when the task is a Move Order.
Deletes Replenishment, MO Xfer, MO Issue tasks
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE DELETE_MO_TASKS (p_task_rec IN task_record_type,
			   x_task_rec OUT NOCOPY task_record_type,
			   x_return_status OUT NOCOPY VARCHAR2) IS

        l_transaction_number    NUMBER ;
        l_other_mmtt_count      NUMBER;
        l_progress              VARCHAR2(30) := '200';
        l_update_parent         BOOLEAN      := FALSE ;  -- No need to call update_parent_mmtt
        x_msg_count             NUMBER;
        x_msg_data              VARCHAR2(50);
        l_g_ret_sts_error       CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_error;
        l_g_ret_sts_unexp_error CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_unexp_error;
        l_g_ret_sts_success     CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_success;
        l_reservation_id        NUMBER;
        l_pri_rsv_qty           NUMBER;
        l_rsv_qty               NUMBER;
        l_pri_rsv_uom           VARCHAR2(3);
        l_rsv_uom               VARCHAR2(3);
        l_old_upd_resv_rec inv_reservation_global.mtl_reservation_rec_type;
        l_new_upd_resv_rec inv_reservation_global.mtl_reservation_rec_type;
        l_upd_dummy_sn inv_reservation_global.serial_number_tbl_type;
        l_task_table WMS_TASK_MGMT_PUB.task_tab_type ;
        l_task_rec WMS_TASK_MGMT_PUB.task_output_rectype;
        l_transaction_record mtl_material_transactions_temp%rowtype ; --MMTT rec
        l_move_order_rec mtl_txn_request_lines%rowtype ;              --MTRL rec
        l_debug         NUMBER;
        exc_not_deleted EXCEPTION;
        CURSOR c_mmtt_info
        IS
                SELECT  mmtt.transaction_temp_id ,
                        mmtt.parent_line_id    --For checking bulk task
                        ,
                        mmtt.inventory_item_id  ,
                        mmtt.move_order_line_id ,
                        mmtt.transaction_uom    ,
                        mmtt.primary_quantity   ,
                        mmtt.wms_task_type
                FROM    mtl_material_transactions_temp mmtt
                WHERE   mmtt.transaction_temp_id = l_transaction_number
                    AND NOT EXISTS
                        (SELECT 1
                        FROM    mtl_material_transactions_temp t1
                        WHERE   t1.parent_line_id = mmtt.transaction_temp_id
                        )
        UNION ALL
        SELECT  mmtt.transaction_temp_id ,
                mmtt.parent_line_id            --For checking bulk task
                ,
                mmtt.inventory_item_id  ,
                mmtt.move_order_line_id ,
                mmtt.transaction_uom    ,
                mmtt.primary_quantity   ,
                mmtt.wms_task_type
        FROM    mtl_material_transactions_temp mmtt
        WHERE   mmtt.parent_line_id  = l_transaction_number
            AND mmtt.parent_line_id <> mmtt.transaction_temp_id;
-- This union by will end up getting all PARENTS too *****
CURSOR c_mo_line_info
IS
        SELECT  mtrl.uom_code                   ,
                mtrl.transaction_source_type_id ,
                mtrl.transaction_type_id
        FROM    mtl_txn_request_lines mtrl
        WHERE   mtrl.line_id = l_transaction_record.move_order_line_id;
CURSOR c_get_other_mmtt
IS
        SELECT  COUNT(*)
        FROM    mtl_material_transactions_temp mmtt
        WHERE   mmtt.move_order_line_id   = l_transaction_record.move_order_line_id
            AND mmtt.transaction_temp_id <> l_transaction_record.transaction_temp_id
            AND NOT EXISTS
                (SELECT 1
                FROM    mtl_material_transactions_temp t1
                WHERE   t1.parent_line_id = mmtt.transaction_temp_id
                );
BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
        l_progress      := '210';
        l_debug         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        IF (l_debug      = 1) THEN
                debug_print('IN DELETE_MO_TASKS');
                debug_print (  'delete_mo: l_progress: ' || l_progress );
        END IF;
        SAVEPOINT delmo;
        l_transaction_number := p_task_rec.transaction_number;
        IF l_debug            = 1 THEN
                debug_print (  'l_transaction_number ' || l_transaction_number );
        END IF;
        OPEN c_mmtt_info;
        LOOP
                FETCH   c_mmtt_info
                INTO    l_transaction_record.transaction_temp_id ,
                        l_transaction_record.parent_line_id      ,
                        l_transaction_record.inventory_item_id   ,
                        l_transaction_record.move_order_line_id  ,
                        l_transaction_record.transaction_uom     ,
                        l_transaction_record.primary_quantity    ,
                        l_transaction_record.wms_task_type;
                EXIT
        WHEN c_mmtt_info%NOTFOUND;
                l_progress := '220';
                IF (l_debug = 1) THEN
                        debug_print (  'delete_mo: l_progress: ' || l_progress );
                        debug_print (  'delete_mo: l_transaction_record.transaction_temp_id ' || l_transaction_record.transaction_temp_id );
                        debug_print (  'delete_mo: l_transaction_record.parent_line_id ' || l_transaction_record.parent_line_id );
                        debug_print (  'delete_mo: l_transaction_record.inventory_item_id ' || l_transaction_record.inventory_item_id );
                        debug_print (  'delete_mo: l_transaction_record.move_order_line_id ' || l_transaction_record.move_order_line_id );
                        debug_print (  'delete_mo: l_transaction_record.transaction_uom ' || l_transaction_record.transaction_uom );
                        debug_print (  'delete_mo: l_transaction_record.primary_quantity ' || l_transaction_record.primary_quantity );
                        debug_print (  'delete_mo: l_transaction_record.wms_task_type ' || l_transaction_record.wms_task_type );
                END IF;
                OPEN c_mo_line_info;
                FETCH   c_mo_line_info
                INTO    l_move_order_rec.uom_code                  ,
                        l_move_order_rec.transaction_source_type_id,
                        l_move_order_rec.transaction_type_id;
                CLOSE c_mo_line_info;
                l_progress := '230';
                IF (l_debug = 1) THEN
                        debug_print (  'delete_mo: l_progress: ' || l_progress );
                        debug_print('delete_mo: l_move_order_rec.uom_code :'|| l_move_order_rec.uom_code);
                        debug_print('delete_mo: l_move_order_rec.transaction_source_type_id :'|| l_move_order_rec.transaction_source_type_id);
                        debug_print('delete_mo: l_move_order_rec.transaction_type_id :'|| l_move_order_rec.transaction_type_id);
                END IF;
                l_progress := '250';
                OPEN c_get_other_mmtt;
                FETCH c_get_other_mmtt INTO l_other_mmtt_count;
                CLOSE c_get_other_mmtt;
                IF (l_debug = 1) THEN
                        debug_print (  'delete_mo: l_progress: ' || l_progress );
                        debug_print(  'delete_mo: Number of MMTTs other than this MMTT : ' || l_other_mmtt_count);
                END IF;
                IF l_other_mmtt_count > 0 THEN
                        IF (l_debug   = 1) THEN
                                debug_print('delete_mo: Other MMTT lines exist too. So cant close MO Line');
                        END IF;
                        l_progress                         := '260';
                        delete_transaction( x_return_status => x_return_status ,
					    x_msg_data => x_msg_data ,
					    x_msg_count => x_msg_count ,
					    p_transaction_temp_id => l_transaction_record.transaction_temp_id ,
					    p_update_parent => l_update_parent );

                        IF l_debug                          = 1 THEN
                                debug_print(  'x_return_status ' || x_return_status);
                        END IF;
                        IF x_return_status = fnd_api.g_ret_sts_error THEN
                                IF l_debug = 1 THEN
                                        debug_print (  'delete_mo: l_progress: ' || l_progress );
                                        debug_print('delete_mo: Error occurred while deleting MMTT');
                                END IF;
                                x_task_rec := p_task_rec;
                                ROLLBACK TO delmo;
                                RAISE exc_not_deleted ;
                        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                IF l_debug    = 1 THEN
                                        debug_print('delete_mo: Error occurred while deleting MMTT');
                                END IF;
                                ROLLBACK TO delmo;
                        END IF;
                ELSE --IF l_other_mmtt_count > 0
                        l_progress := '280';
                        IF (l_debug = 1) THEN
                                debug_print (  'delete_mo: l_progress: ' || l_progress );
                                debug_print ('delete_mo: l_transaction_record.move_order_line_id' || l_transaction_record.move_order_line_id );
                        END IF;
                        UPDATE mtl_txn_request_lines
                        SET     quantity_detailed = nvl(quantity_delivered,0),
                                line_status       = 5                        ,
                                last_update_date  = SYSDATE
                        WHERE   line_id           = l_transaction_record.move_order_line_id;
                        IF SQL%ROWCOUNT           = 0 THEN
                                IF l_debug        = 1 THEN
                                        debug_print (  'delete_mo: error updating MTRL::: ');
                                END IF;
                                x_task_rec := p_task_rec;
                                ROLLBACK TO delmo;
                                RAISE exc_not_deleted ;
                        END IF;
                        IF l_debug = 1 THEN
                                debug_print (  'delete_mo: before calling delete transaction::: ');
                        END IF;
                        delete_transaction( x_return_status => x_return_status ,
					    x_msg_data => x_msg_data ,
					    x_msg_count => x_msg_count ,
					    p_transaction_temp_id => l_transaction_record.transaction_temp_id ,
					    p_update_parent => l_update_parent );

                        IF l_debug                          = 1 THEN
                                debug_print(  'x_return_status ' || x_return_status);
                        END IF;
                        IF x_return_status = fnd_api.g_ret_sts_error THEN
                                IF l_debug = 1 THEN
                                        debug_print('delete_mo: Error occurred while deleting MMTT');
                                END IF;
                                x_task_rec := p_task_rec;
                                ROLLBACK TO delmo;
                                RAISE exc_not_deleted ;
                        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                IF l_debug    = 1 THEN
                                        debug_print('delete_mo: Error occurred while deleting MMTT');
                                END IF;
                                ROLLBACK TO delmo;
                        END IF;
                        l_progress := '290';
                        IF (l_debug = 1) THEN
                                debug_print (  'delete_mo: l_progress: ' || l_progress );
                        END IF;
                END IF;
        END LOOP;
        CLOSE c_mmtt_info;
EXCEPTION
WHEN exc_not_deleted THEN
        IF l_debug =1 THEN
                debug_print('In the exception for could not delete a record. Returning staus as E');
        END IF;
        x_task_rec.status :='E';
        x_task_rec.ERROR  := 'Error deleting Move order tasks';
        x_return_status   := 'E';
WHEN OTHERS THEN
        IF l_debug = 1 THEN
                debug_print('delete_mo: In the When Others Exception, Rolling back.');
        END IF;
        x_task_rec        := p_task_rec;
        x_task_rec.ERROR  := 'Unexpected Error Occurred';
        x_task_rec.status :='E';
        x_return_status   := l_g_ret_sts_unexp_error;
        ROLLBACK TO delmo;
END DELETE_MO_TASKS;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE DELETE_INBOUND_TASKS
This is the proceudre called from the DELETE_TASKS API when the task is a Putaway Task.
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE DELETE_INBOUND_TASKS ( p_task_rec IN task_record_type,
				 x_task_rec OUT NOCOPY task_record_type,
				 x_return_status OUT NOCOPY VARCHAR2) IS

        l_other_mmtt_count   NUMBER;
        l_debug              NUMBER;
        l_progress           VARCHAR2(30);
        l_update_parent      BOOLEAN := FALSE ;  -- No need to call update_parent_mmtt
        x_msg_count          NUMBER;
        x_msg_data           VARCHAR2(50);
        l_return_status      VARCHAR2(1);
        l_transaction_number NUMBER ;
        l_transaction_record mtl_material_transactions_temp%rowtype ; --MMTT rec
        l_move_order_rec mtl_txn_request_lines%rowtype ;              --MTRL rec
        l_op_plan_rec wms_op_plan_instances%rowtype ;                 --WOPI rec
        exc_not_deleted         EXCEPTION;
        l_op_plan_status        NUMBER ;
        l_g_ret_sts_error       CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_error;
        l_g_ret_sts_unexp_error CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_unexp_error;
        l_g_ret_sts_success     CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_success;
        CURSOR c_mmtt_info
        IS
                SELECT  mmtt.transaction_temp_id ,
                        mmtt.parent_line_id      ,
                        mmtt.organization_id     ,
                        mmtt.inventory_item_id   ,
                        mmtt.move_order_line_id  ,
                        mmtt.transaction_uom     ,
                        mmtt.primary_quantity    ,
                        mmtt.transaction_quantity
                FROM    mtl_material_transactions_temp mmtt
                WHERE   mmtt.transaction_temp_id = l_transaction_number
                    AND NOT EXISTS
                        (SELECT 1
                        FROM    mtl_material_transactions_temp t1
                        WHERE   t1.parent_line_id = mmtt.transaction_temp_id
                        )
        UNION ALL
        SELECT  mmtt.transaction_temp_id ,
                mmtt.parent_line_id      ,
                mmtt.organization_id     ,
                mmtt.inventory_item_id   ,
                mmtt.move_order_line_id  ,
                mmtt.transaction_uom     ,
                mmtt.primary_quantity    ,
                mmtt.transaction_quantity
        FROM    mtl_material_transactions_temp mmtt
        WHERE   mmtt.parent_line_id  = l_transaction_number
            AND mmtt.parent_line_id <> mmtt.transaction_temp_id;
CURSOR c_mo_line_info
IS
        SELECT  mtrl.uom_code                   ,
                mtrl.transaction_source_type_id ,
                mtrl.transaction_type_id        ,
                backorder_delivery_detail_id
        FROM    mtl_txn_request_lines mtrl
        WHERE   mtrl.line_id = l_transaction_record.move_order_line_id;
CURSOR c_get_other_mmtt
IS
        SELECT  COUNT(*)
        FROM    mtl_material_transactions_temp mmtt
        WHERE   mmtt.move_order_line_id   = l_transaction_record.move_order_line_id
            AND mmtt.transaction_temp_id <> l_transaction_record.transaction_temp_id
            AND NOT EXISTS
                (SELECT 1
                FROM    mtl_material_transactions_temp t1
                WHERE   t1.parent_line_id = mmtt.transaction_temp_id
                );
CURSOR c_plan_instance
IS
        SELECT  status             ,
                orig_dest_sub_code ,
                orig_dest_loc_id
        FROM    WMS_OP_PLAN_INSTANCES
        WHERE   source_task_id = l_transaction_record.parent_line_id;
BEGIN
        l_debug         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        x_return_status := fnd_api.g_ret_sts_success;
        l_progress      := '300';
        IF (l_debug      = 1) THEN
                debug_print('IN DELETE_INBOUND_TASKS');
                debug_print(  'l_progress: ' || l_progress );
        END IF;
        SAVEPOINT delinb;
        l_transaction_number := p_task_rec.transaction_number;
        IF (l_debug           = 1) THEN
                debug_print(  'l_transaction_number ' || l_transaction_number );
        END IF;
        OPEN c_mmtt_info;
        LOOP
                FETCH   c_mmtt_info
                INTO    l_transaction_record.transaction_temp_id ,
                        l_transaction_record.parent_line_id      ,
                        l_transaction_record.organization_id     ,
                        l_transaction_record.inventory_item_id   ,
                        l_transaction_record.move_order_line_id  ,
                        l_transaction_record.transaction_uom     ,
                        l_transaction_record.primary_quantity    ,
                        l_transaction_record.transaction_quantity;
                EXIT
        WHEN c_mmtt_info%NOTFOUND;
                l_progress := '310';
                IF (l_debug = 1) THEN
                        debug_print (  'delete_inbound_tasks: l_progress: ' || l_progress );
                        debug_print (  'delete_inbound_tasks: l_transaction_record.transaction_temp_id ' || l_transaction_record.transaction_temp_id );
                        debug_print (  'delete_inbound_tasks: l_transaction_record.parent_line_id ' || l_transaction_record.parent_line_id );
                        debug_print (  'delete_inbound_tasks: l_transaction_record.inventory_item_id ' || l_transaction_record.inventory_item_id );
                        debug_print (  'delete_inbound_tasks: l_transaction_record.move_order_line_id ' || l_transaction_record.move_order_line_id );
                        debug_print (  'delete_inbound_tasks: l_transaction_record.transaction_uom ' || l_transaction_record.transaction_uom );
                        debug_print (  'delete_inbound_tasks: l_transaction_record.primary_quantity ' || l_transaction_record.primary_quantity );
                        debug_print (  'delete_inbound_tasks: l_transaction_record.transaction_quantity ' || l_transaction_record.transaction_quantity );
                END IF;
                --Checking for the status of the Task(as per the operation plan, if Pending or In Progress)
                l_progress := '320';
                OPEN c_plan_instance;
                FETCH   c_plan_instance
                INTO    l_op_plan_rec.status            ,
                        l_op_plan_rec.orig_dest_sub_code,
                        l_op_plan_rec.orig_dest_loc_id;
                CLOSE c_plan_instance;
                IF l_op_plan_rec.status IS NULL THEN
                        IF l_debug =1 THEN
                                debug_print('No Plan Instance record exists');
                        END IF;
                        x_task_rec := p_task_rec;
                        ROLLBACK to delinb ;
                        RAISE exc_not_deleted ;
                END IF;
                l_progress             := '330';
                IF l_op_plan_rec.status = 1 THEN
                        IF l_debug      =1 THEN
                                debug_print (  'delete_inbound_tasks: l_progress: ' || l_progress );
                        END IF;
                        OPEN c_mo_line_info;
                        FETCH   c_mo_line_info
                        INTO    l_move_order_rec.uom_code                  ,
                                l_move_order_rec.transaction_source_type_id,
                                l_move_order_rec.transaction_type_id       ,
                                l_move_order_rec.backorder_delivery_detail_id;
                        CLOSE c_mo_line_info;
                        l_progress := '340';
                        IF (l_debug = 1) THEN
                                debug_print (  'delete_inbound_tasks: l_progress: ' || l_progress );
                                debug_print('delete_inbound_tasks: l_move_order_rec.uom_code :'|| l_move_order_rec.uom_code);
                                debug_print('delete_inbound_tasks: l_move_order_rec.transaction_source_type_id :'|| l_move_order_rec.transaction_source_type_id);
                                debug_print('delete_inbound_tasks: l_move_order_rec.transaction_type_id :'|| l_move_order_rec.transaction_type_id);
                                debug_print('delete_inbound_tasks: l_move_order_rec.backorder_delivery_detail_id :'|| l_move_order_rec.backorder_delivery_detail_id);
                        END IF;
                        IF l_move_order_rec.backorder_delivery_detail_id IS NULL THEN
                                l_progress := '350';
                                --delete operation plan tables (wopi and wooi)
                                DELETE
                                FROM    wms_op_plan_instances
                                WHERE   source_task_id = l_transaction_record.parent_line_id;
                                IF SQL%ROWCOUNT        =0 THEN
                                        IF l_debug     =1 THEN
                                                debug_print('Count not delete the Plan Instance of this task');
                                        END IF;
                                        x_task_rec := p_task_rec;
                                        ROLLBACK to delinb ;
                                        RAISE exc_not_deleted ;
                                END IF;
                                DELETE
                                FROM    wms_op_operation_instances
                                WHERE   source_task_id = l_transaction_record.transaction_temp_id;
                                IF SQL%ROWCOUNT        =0 THEN
                                        IF l_debug     =1 THEN
                                                debug_print('Count not update the operation instance of this task');
                                        END IF;
                                        x_task_rec := p_task_rec;
                                        ROLLBACK to delinb ;
                                        RAISE exc_not_deleted ;
                                END IF;
                                l_progress := '360';
                                --call delete_transaction (deletes mmtt, mtlt, msnt and wdt)
                                delete_transaction( x_return_status => l_return_status ,
						    x_msg_data => x_msg_data ,
						    x_msg_count => x_msg_count ,
						    p_transaction_temp_id => l_transaction_record.transaction_temp_id ,p_update_parent => l_update_parent );
                                IF l_debug                          = 1 THEN
                                        debug_print(  'x_return_status ' || x_return_status);
                                END IF;
                                IF x_return_status = fnd_api.g_ret_sts_error THEN
                                        IF l_debug = 1 THEN
                                                debug_print('delete_inbound_tasks: Error while deleting MMTT/MTLT/MSNT/WDT');
                                        END IF;
                                        x_task_rec := p_task_rec;
                                        ROLLBACK TO delinb;
                                        RAISE exc_not_deleted ;
                                ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                        IF l_debug    = 1 THEN
                                                debug_print('delete_inbound_tasks: Error occurred while deleting MMTT');
                                        END IF;
                                        ROLLBACK TO delinb;
                                END IF;
                                l_progress := '370';
                                --delete the parent mmtt
                                DELETE
                                FROM    MTL_MATERIAL_TRANSACTIONS_TEMP
                                WHERE   transaction_temp_id = l_transaction_record.parent_line_id ;
                                IF SQL%ROWCOUNT             =0 THEN
                                        IF l_debug          =1 THEN
                                                debug_print('Count not delete the parent mmtt');
                                        END IF;
                                        x_task_rec := p_task_rec;
                                        ROLLBACK to delinb ;
                                        RAISE exc_not_deleted ;
                                END IF;
                                --call update locator capacity
                                inv_loc_wms_utils.revert_loc_suggested_cap_nauto ( x_return_status => l_return_status ,
										   x_msg_count => x_msg_count ,
										   x_msg_data => x_msg_data ,
										   p_organization_id => l_transaction_record.organization_id ,
										   p_inventory_location_id => l_op_plan_rec.orig_dest_loc_id ,
										   p_inventory_item_id => l_transaction_record.inventory_item_id ,
										   p_primary_uom_flag => 'Y' ,
										   p_transaction_uom_code => NULL ,
										   p_quantity => l_transaction_record.primary_quantity );
                                IF l_debug                                                         = 1 THEN
                                        debug_print(  'Return status from revert_loc_suggested_capacity ' || x_return_status);
                                END IF;
                                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                                        IF l_debug  = 1 THEN
                                                debug_print('delete_inbound_tasks: Error while reverting locator capacity');
                                        END IF;
                                        x_task_rec := p_task_rec;
                                        ROLLBACK TO delinb;
                                        RAISE exc_not_deleted ;
                                END IF;
                                l_progress := '380';
                                OPEN c_get_other_mmtt;
                                FETCH c_get_other_mmtt INTO l_other_mmtt_count;
                                CLOSE c_get_other_mmtt;
                                IF (l_debug = 1) THEN
                                        debug_print(  'delete_inbound_tasks: Number of MMTTs other than this MMTT : ' || l_other_mmtt_count);
                                END IF;
                                IF l_other_mmtt_count > 0 THEN
                                        UPDATE mtl_txn_request_lines
                                                SET quantity_detailed = quantity_detailed - l_transaction_record.primary_quantity
                                        WHERE   line_id               = l_transaction_record.move_order_line_id;
                                ELSE --IF l_other_mmtt_count > 0
                                        UPDATE mtl_txn_request_lines
                                                SET quantity_detailed = null
                                        WHERE   line_id               = l_transaction_record.move_order_line_id;
                                END IF;
                                IF SQL%ROWCOUNT    =0 THEN
                                        IF l_debug =1 THEN
                                                debug_print('Could not update the move order line.');
                                        END IF;
                                        x_task_rec := p_task_rec;
                                        ROLLBACK to delinb ;
                                        RAISE exc_not_deleted ;
                                END IF;
                        ELSE
                                x_task_rec      := p_task_rec;
                                x_task_rec.ERROR:= 'This is a crossdock task, not deleting';
                                x_return_status := 'E';
				--anjana
			        IF l_debug =1 THEN
					debug_print('This is a crossdock task, not deleting');
			        END IF;
                        END IF ;
                ELSE
                        x_task_rec      := p_task_rec;
                        x_task_rec.ERROR:= 'Invalid status of Operation Plan';
                        x_return_status := 'E';
			--anjana
		        IF l_debug =1 THEN
				debug_print('Invalid status of Operation Plan');
		        END IF;
                END IF;
        END LOOP;
EXCEPTION
WHEN exc_not_deleted THEN
        IF l_debug =1 THEN
                debug_print('In the exception for could not delete a record. Returning staus as E');
        END IF;
        x_task_rec.status :='E';
        x_task_rec.ERROR  := 'Error deleting Inbound Tasks';
        x_return_status   := 'E';
WHEN OTHERS THEN
        IF l_debug = 1 THEN
                debug_print('delete_inbound_tasks:In the When Others Exception, Rolling back.' );
        END IF;
        x_task_rec        := p_task_rec;
        x_task_rec.ERROR  := 'Unexpected Error Occurred';
        x_task_rec.status :='E';
        x_return_status   := l_g_ret_sts_unexp_error;
        ROLLBACK TO delinb;
END DELETE_INBOUND_TASKS;

-------------------------------------------------------------------------------------------------------------------
/*PROCEDURE DELETE_CC_TASKS
This is the proceudre called from the DELETE_TASKS API when the task is a Cycle Count Entry.
This update the entry to a Rejected Status and deletes the corresponding task record if it exists.
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE DELETE_CC_TASKS ( p_task_rec IN task_record_type,
			    x_task_rec OUT NOCOPY task_record_type,
			    x_return_status OUT NOCOPY VARCHAR2) IS

        l_cc_entry_id           NUMBER ;
        l_cyc_header_id         NUMBER;
        l_cyc_count_name        mtl_cycle_count_headers.cycle_count_header_name%TYPE ;
        l_update_cyc            NUMBER;
        l_cyc_task              NUMBER;
        l_debug                 NUMBER;
        exc_not_deleted         EXCEPTION;
        l_g_ret_sts_error       CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_error;
        l_g_ret_sts_unexp_error CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_unexp_error;
        l_g_ret_sts_success     CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_success;
BEGIN
	x_return_status := fnd_api.g_ret_sts_success;
        l_debug       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        l_cc_entry_id := p_task_rec.transaction_number ;
        SAVEPOINT delcyc;
        SELECT  cycle_count_header_id
        INTO    l_cyc_header_id
        FROM    mtl_cycle_count_entries
        WHERE   cycle_count_entry_id = l_cc_entry_id ;
        UPDATE mtl_cycle_count_entries
                SET entry_status_code = 4
        WHERE   cycle_count_entry_id  = l_cc_entry_id ;
        IF l_debug                    =1 THEN
                debug_print('delete_cc_tasks: In Delete Cycle Count Tasks');
                debug_print('delete_cc_tasks: Value of cycle count header:'||l_cyc_header_id);
                debug_print('delete_cc_tasks: Value of cycle count entry:'||l_cc_entry_id);
        END IF;
        IF SQL%ROWCOUNT    =0 THEN
                IF l_debug =1 THEN
                        debug_print('delete_cc_tasks: Could not update the cycle count entry.');
                END IF;
                x_task_rec := p_task_rec;
                ROLLBACK to delcyc ;
                RAISE exc_not_deleted ;
        END IF;
        SELECT  count(task_id)
        INTO    l_cyc_task
        FROM    wms_dispatched_tasks
        WHERE   transaction_temp_id = l_cc_entry_id
            AND task_type           = 3;
        IF l_cyc_task              <> 0 THEN
                DELETE
                FROM    wms_dispatched_tasks
                WHERE   transaction_temp_id = l_cc_entry_id
                    AND task_type           = 3;
                IF SQL%ROWCOUNT             =0 THEN
                        IF l_debug          =1 THEN
                                debug_print('delete_cc_tasks: Could not delete the cycle count task.');
                        END IF;
                        x_task_rec := p_task_rec;
                        ROLLBACK to delcyc ;
                        RAISE exc_not_deleted;
                END IF; --Rowcount for wdt delete
        END IF;         --Exists cycle count tasks in wdt
EXCEPTION
WHEN exc_not_deleted THEN
        IF l_debug =1 THEN
                debug_print('delete_cc_tasks: In the exception for could not delete a record. Returning staus as E');
        END IF;
        x_task_rec.status :='E';
        x_task_rec.ERROR  := 'Could not delete the cycle count task.';
        x_return_status   := 'E';
WHEN OTHERS THEN
        IF l_debug = 1 THEN
                debug_print('delete_cc_tasks: In the When Others Exception, Rolling back.' );
        END IF;
        x_task_rec        := p_task_rec;
        x_task_rec.status :='E';
        x_task_rec.ERROR  := 'Unexpected Error Occurred';
        x_return_status   := l_g_ret_sts_unexp_error;
        ROLLBACK TO delcyc;
END DELETE_CC_TASKS;

-------------------------------------------------------------------------------------------------------------------
--DELETE TASK
/*This Public API takes care of deleting a single task or a table of tasks as is passed to the API.
  The types of tasks that this API handles include Inbound, Outbound, Warehouse and Manufacturing Tasks.

PROCEDURE delete_tasks ( p_transaction_number IN NUMBER DEFAULT NULL ,
			 p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE ,
			 p_wms_task IN WMS_TASK_MGMT_PUB.task_tab_type ,
			 x_undeleted_tasks OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type ,
			 x_return_status OUT NOCOPY VARCHAR2 ,
			 x_msg_count OUT NOCOPY NUMBER ,
			 x_msg_data OUT NOCOPY VARCHAR2 )

Parameter		Description

p_transaction_number	This corrsponds to the task_id that user is trying to delete.
P_wms_task		This correspinds to the set of tasks that user is trying to delete.
P_Commit		This parameter decides whether to commit the changes or not.
X_undeleted_tasks	This parameter contains the set of undeleted tasks.
X_return_status		This parameter gives the return status of delete_task API.
			'S' = Success, 'U' = Unexpected Error, 'E' = Error.
X_msg_count		This gives the count of messages logged during the task deletion process.
X_msg_data		This gives the descrption of the messages that got logged during the task deletion process.
-------------------------------------------------------------------------------------------------------------------*/

PROCEDURE delete_tasks ( p_transaction_number IN NUMBER DEFAULT NULL ,
			 p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE ,
			 p_wms_task IN WMS_TASK_MGMT_PUB.task_tab_type ,
			 x_undeleted_tasks OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type ,
			 x_return_status OUT NOCOPY VARCHAR2 ,
			 x_msg_count OUT NOCOPY NUMBER ,
			 x_msg_data OUT NOCOPY VARCHAR2 ) IS

        l_task_table WMS_TASK_MGMT_PUB.task_tab_type ;
        l_task_rec task_record_type ;
        x_task_rec task_record_type ;
        l_transaction_number NUMBER;
        l_transaction_record mtl_material_transactions_temp%rowtype ;
        /*Local variable for the validate_task API*/
        l_ret_task_table WMS_TASK_MGMT_PUB.task_tab_type ;
        l_val_ret_status        VARCHAR2(30);
        l_task_type             NUMBER ;
        l_task_exists           NUMBER                :=0 ;
        l_g_ret_sts_error       CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_error;
        l_g_ret_sts_unexp_error CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_unexp_error;
        l_g_ret_sts_success     CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_success;
        exec_unexp              EXCEPTION;
        l_lock_cyc_rec          NUMBER;
        l_debug                 NUMBER;
        undel_task              NUMBER;
	l_msg			VARCHAR2(2000);--anjana
BEGIN
        x_return_status     := fnd_api.g_ret_sts_success;
	--anjana
	x_msg_count := 0;
        l_debug             := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        l_val_ret_status    :='S' ;
        l_transaction_number:= p_transaction_number ;
        l_task_table        := p_wms_task;
        IF l_debug           = 1 THEN
                debug_print('IN DELETE_TASKS' );
        END IF;
        IF l_debug = 1 THEN
                debug_print('Values passed to delete_tasks p_transaction_number:'|| p_transaction_number );
        END IF ;
        WMS_TASK_MGMT_PUB.validate_tasks( p_init_msg_list =>'Y' ,
					  p_transaction_number => l_transaction_number ,
					  p_task_table => l_task_table ,
					  x_wms_task => l_ret_task_table ,
					  x_return_status => l_val_ret_status );
        SAVEPOINT deltask ;
        IF l_val_ret_status ='S' THEN
                undel_task :=1;
                FOR i      IN 1..l_ret_task_table.count
                LOOP
                        IF (nvl(l_ret_task_table(i).result,'@@@') <> 'E') THEN
                                BEGIN
                                        BEGIN
						l_task_exists:=0;
                                                --Intitalizin the record
                                                l_task_rec.transaction_number:= l_ret_task_table(i).transaction_number ;
                                                SELECT  1,
                                                        wms_task_type
                                                INTO    l_task_exists,
                                                        l_task_type
                                                FROM    mtl_material_transactions_temp
                                                WHERE   transaction_temp_id = l_ret_task_table(i).transaction_number FOR UPDATE NOWAIT;
                                        EXCEPTION
                                        WHEN NO_DATA_FOUND THEN
                                                null;
                                        END;
                                        IF l_debug = 1 THEN
                                                debug_print('l_task_exists'|| l_task_exists );
                                                debug_print('l_task_type:'|| l_task_type );
                                        END IF;
                                        IF (l_task_exists = 0 ) THEN
                                                SELECT  count(cycle_count_entry_id)
                                                INTO    l_task_exists
                                                FROM    mtl_cycle_count_entries
                                                WHERE   cycle_count_entry_id = l_ret_task_table(i).transaction_number ;
                                                SELECT  1
                                                INTO    l_lock_cyc_rec
                                                FROM    mtl_cycle_count_entries
                                                WHERE   cycle_count_entry_id = l_ret_task_table(i).transaction_number FOR UPDATE NOWAIT;
                                                l_task_type                 := 3;
                                                IF l_task_exists             = 1 THEN
                                                        IF l_debug           = 1 THEN
                                                                debug_print('Cycle Count Task');
                                                        END IF ;
                                                        DELETE_CC_TASKS(p_task_rec => l_task_rec, x_task_rec => x_task_rec, x_return_status => x_return_status);
                                                END IF;
                                        END IF;
                                        IF l_task_type     = 1 THEN --SO, WIP
                                                IF l_debug = 1 THEN
                                                        debug_print('SO/WIP');
                                                END IF ;
                                                DELETE_OUTBOUND_TASKS(p_task_rec => l_task_rec, x_task_rec => x_task_rec, x_return_status => x_return_status);
                                        ELSIF l_task_type                        = 2 THEN --Inbound
                                                IF l_debug                       = 1 THEN
                                                        debug_print('Inbound Task');
                                                END IF ;
                                                DELETE_INBOUND_TASKS(p_task_rec => l_task_rec, x_task_rec => x_task_rec, x_return_status => x_return_status);
                                        ELSIF l_task_type                      IN (4, 5, 6) THEN --Replenishment, MO Xfer, MO Issue)
                                                IF l_debug                      = 1 THEN
                                                        debug_print('MO Tasks');
                                                END IF ;
                                                DELETE_MO_TASKS(p_task_rec => l_task_rec, x_task_rec => x_task_rec, x_return_status => x_return_status);
                                        END IF;
                                EXCEPTION
                                WHEN OTHERS THEN
                                        x_return_status := l_g_ret_sts_unexp_error;
                                        IF l_debug       = 1 THEN
                                                debug_print('In the When Others Exception in the Loop, Rolling back.' );
                                        END IF;
                                        ROLLBACK TO deltask;
                                END;
                                IF x_return_status = 'E' THEN
                                        IF l_debug = 1 THEN
                                                debug_print('The called program returned error' );
                                        END IF;
					--anjana
                                        FND_MESSAGE.SET_NAME('WMS', 'WMS_TASK_DELETE_ERROR');
					l_msg := fnd_message.get;
					x_msg_count := x_msg_count + 1;
					x_msg_data := x_msg_data || l_msg;

                                        x_undeleted_tasks(undel_task).transaction_number:= x_task_rec.transaction_number;
                                        x_undeleted_tasks(undel_task).RESULT            := x_task_rec.status;
                                        x_undeleted_tasks(undel_task).error             := l_msg;
                                        undel_task                                      :=undel_task+1;
--                                      FND_MSG_PUB.ADD;
--                                      fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
                                END IF;
                                IF x_return_status ='U' THEN
                                        IF l_debug = 1 THEN
                                                debug_print('The called program returned unexpected error status' );
                                        END IF;
                                        RAISE exec_unexp;
                                END IF;
                        ELSE
                                IF l_debug = 1 THEN
                                        debug_print('Validate_task returned error for this record' );
                                END IF;
                                FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_TASK');
				--anjana
				l_msg := fnd_message.get;
				x_msg_count := x_msg_count + 1;
				x_msg_data := x_msg_data || l_msg;
--                              FND_MSG_PUB.ADD;
--                              fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

				x_undeleted_tasks(undel_task).transaction_number:= l_ret_task_table(i).transaction_number ;  --6888354 Bug
                                x_undeleted_tasks(undel_task).RESULT   := l_ret_task_table(i).RESULT;
                                x_undeleted_tasks(undel_task).error    := l_msg;
                                undel_task                             :=undel_task+1;
                        END IF ;
                END LOOP; --Loop for task table
        ELSE
                IF l_debug = 1 THEN
                        debug_print('Invalid status returned from Validate_Task' );
                END IF;
                RAISE exec_unexp;
        END IF; --End of Validation Status 'S'.
        IF p_commit = FND_API.G_TRUE THEN
                COMMIT;
        END IF ;
EXCEPTION
WHEN exec_unexp THEN
        IF l_debug = 1 THEN
                debug_print('In the Unexpected Error of Delete_Tasks, Rolling back.' );
        END IF;
        x_return_status := l_g_ret_sts_unexp_error;
        FND_MESSAGE.SET_NAME('WMS', 'WMS_UNEXPECTED_ERROR');
        FND_MSG_PUB.ADD;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
        ROLLBACK TO deltask;
WHEN OTHERS THEN
        IF l_debug = 1 THEN
                debug_print('In the When Others Exception of Delete_Tasks, Rolling back.' );
        END IF;
        x_return_status := l_g_ret_sts_unexp_error;
        FND_MESSAGE.SET_NAME('WMS', 'WMS_UNEXPECTED_ERROR');
        FND_MSG_PUB.ADD;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
        ROLLBACK TO deltask;
END DELETE_TASKS;

-------------------------------------------------------------------------------------------------------------------
--QUERY_TASK
/*
This public API is used to query task based on the query_name or the transaction_number
provided by the user.

PROCEDURE query_task (
      p_transaction_number    IN                NUMBER DEFAULT NULL
    , p_query_name            IN                WMS_SAVED_QUERIES.QUERY_NAME%TYPE
    , x_task_tab              OUT NOCOPY   	WMS_TASKS_PUB.TASK_TABLE
    , x_return_status         OUT NOCOPY   	VARCHAR2
    , x_msg_count             OUT NOCOPY  	NUMBER
    , x_msg_data              OUT NOCOPY  	VARCHAR2 );


Parameter		Description

p_transaction_number	This corrsponds to the task_id that user is trying to update
P_query_name		This correspinds to name of any saved query from the WMS  control board.
			This is used for querying multiple tasks
P_Commit		This parameter decides whether to commit the changes or not.
X_task_tab		PL/SQL table which contains the task/tasks queried by the user.
X_return_status		This parameter gives the return status of query_task API.
			'S' = Success, 'U' = Unexpected Error, 'E' = Error.
X_msg_count		This gives the count of messages logged during the query task process.
X_msg_data		This gives the descrption of the messages that got logged during the query task process.
*/
-------------------------------------------------------------------------------------------------------------------
  PROCEDURE query_task( p_transaction_number IN          NUMBER    DEFAULT NULL
                       ,p_query_name         IN          VARCHAR2
                       ,x_task_tab           OUT NOCOPY  task_tab_type
                       ,x_return_status      OUT NOCOPY  VARCHAR2
                       ,x_msg_count          OUT NOCOPY  NUMBER
                       ,x_msg_data           OUT NOCOPY  VARCHAR2
                      )
  IS

  l_mmtt_rec                                 mtl_material_transactions_temp%ROWTYPE;
  l_mcce_rec                                 mtl_cycle_count_entries%ROWTYPE;
  l_query_tab                                query_tab_type;


  l_organization_id                          NUMBER := NULL;
  l_record_count                             NUMBER := 0;

  l_order_type                               VARCHAR2(10):= NULL;
  l_err_msg                                  VARCHAR2(2000);

  l_include_sales_orders                     BOOLEAN := FALSE;
  l_include_internal_orders                  BOOLEAN := FALSE;
  l_execute_qry                              BOOLEAN := TRUE;

  l_invalid_org                              EXCEPTION;
  l_qry_fail                                 EXCEPTION;

  l_debug                                    NUMBER         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_api_name                                 VARCHAR2(1000) := 'QUERY_TASK';

  v_cycle_count_name                         varchar2(30) := NULL;

  c_cd_exist  number;

  CURSOR c_cd_task (p_transaction_number IN NUMBER) IS
  SELECT 1  FROM mtl_material_transactions_temp mmtt,mtl_txn_request_lines mtrl
  WHERE mtrl.backorder_delivery_detail_id IS NOT NULL
  AND mtrl.line_id = mmtt.move_order_line_id
  AND transaction_temp_id = p_transaction_number;
--added for completed tasks under bug 6854145
--start changes 6854145
  l_mmt_rec             mtl_material_transactions%ROWTYPE;
  l_wdth_rec            wms_dispatched_tasks_history%ROWTYPE;
  CURSOR c_cd_task1 (p_transaction_number IN NUMBER) IS
  SELECT 1  FROM wms_dispatched_tasks_history wdth,mtl_txn_request_lines mtrl
  WHERE mtrl.backorder_delivery_detail_id IS NOT NULL
  AND mtrl.line_id = wdth.move_order_line_id
  AND transaction_id = p_transaction_number;
  --end changes 6854145
  BEGIN

  IF(p_transaction_number IS NOT NULL) THEN
    BEGIN
      SELECT *
      INTO   l_mmtt_rec
      FROM   mtl_material_transactions_temp
      WHERE  transaction_temp_id = p_transaction_number;

      IF(l_debug = 1) THEN
        l_err_msg := 'Calling API wms_waveplan_tasks_pvt.query_tasks for task: '||p_transaction_number;
        inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
      END IF;

      --Munish
      OPEN c_cd_task (p_transaction_number);
      FETCH c_cd_task into c_cd_exist;
      CLOSE c_cd_task;

      If (c_cd_exist = 1)  THEN
      --CALLL wms_waveplan_tasks_pvt.query_tasks API WITH
      --p_crossdock_include=true and p_outbound_include=false and p_inbound_include=false
	      wms_waveplan_tasks_pvt.query_tasks(
	       p_add                          => FALSE
	      ,p_organization_id              => l_mmtt_rec.organization_id
	      ,p_subinventory_code            => l_mmtt_rec.subinventory_code
	      ,p_locator_id                   => l_mmtt_rec.locator_id
	      ,p_to_subinventory_code         => l_mmtt_rec.transfer_subinventory
	      ,p_to_locator_id                => l_mmtt_rec.transfer_to_location
	      ,p_inventory_item_id            => l_mmtt_rec.inventory_item_id
	      ,p_from_task_priority           => l_mmtt_rec.task_priority
	      ,p_to_task_priority             => l_mmtt_rec.task_priority
	      ,p_from_creation_date           => l_mmtt_rec.creation_date
	      ,p_to_creation_date             => l_mmtt_rec.creation_date
	      ,p_is_unreleased                => TRUE
	      ,p_is_pending                   => TRUE
	      ,p_is_queued                    => TRUE
	      ,p_is_dispatched                => TRUE
	      ,p_is_active                    => TRUE
	      ,p_is_loaded                    => TRUE
	      ,p_is_completed                 => TRUE
	      ,p_include_inbound              => FALSE
	      ,p_include_outbound             => FALSE
	      ,p_include_crossdock            => TRUE
	      ,p_include_manufacturing        => TRUE
	      ,p_include_warehousing          => TRUE
	      ,p_from_shipment_number         => l_mmtt_rec.shipment_number
	      ,p_to_shipment_number           => l_mmtt_rec.shipment_number
	      ,p_from_pick_slip_number        => l_mmtt_rec.pick_slip_number
	      ,p_to_pick_slip_number          => l_mmtt_rec.pick_slip_number
	      ,p_delivery_id                  => l_mmtt_rec.trx_source_delivery_id
	      ,p_manufacturing_type           => 1
	      ,p_include_staging_move         => TRUE
	      ,x_return_status                => x_return_status
	      ,x_msg_data                     => x_msg_data
	      ,x_msg_count                    => x_msg_count
	      ,x_record_count                 => l_record_count
	      ,p_is_pending_plan              => FALSE
	      ,p_is_inprogress_plan           => FALSE
	      ,p_is_completed_plan            => FALSE
	      ,p_is_cancelled_plan            => FALSE
	      ,p_is_aborted_plan              => FALSE
	      );
    ELSE
    --CALLL wms_waveplan_tasks_pvt.query_tasks API WITH p_crossdock_include=false and
    --p_outbound_include=true and p_inbound_include=true
    --MKGUPTA2      6868286 Start
         IF   l_mmtt_rec.parent_line_id IS NOT NULL THEN
              l_mmtt_rec.pick_slip_number:=NULL;
         ELSE
              l_mmtt_rec.subinventory_code:=NULL;
              l_mmtt_rec.locator_id:=NULL;
         END IF;
	 --  6868286 End
              wms_waveplan_tasks_pvt.query_tasks(
	       p_add                          => FALSE
	      ,p_organization_id              => l_mmtt_rec.organization_id
	      ,p_subinventory_code            => l_mmtt_rec.subinventory_code
	      ,p_locator_id                   => l_mmtt_rec.locator_id
	      ,p_to_subinventory_code         => l_mmtt_rec.transfer_subinventory
	      ,p_to_locator_id                => l_mmtt_rec.transfer_to_location
	      ,p_inventory_item_id            => l_mmtt_rec.inventory_item_id
	      ,p_from_task_priority           => l_mmtt_rec.task_priority
	      ,p_to_task_priority             => l_mmtt_rec.task_priority
	      ,p_from_creation_date           => Trunc(l_mmtt_rec.creation_date)  --  6868286
	      ,p_to_creation_date             => Trunc(l_mmtt_rec.creation_date)  --  6868286
	      ,p_is_unreleased                => TRUE
	      ,p_is_pending                   => TRUE
	      ,p_is_queued                    => TRUE
	      ,p_is_dispatched                => TRUE
	      ,p_is_active                    => TRUE
	      ,p_is_loaded                    => TRUE
	      ,p_is_completed                 => FALSE
	      ,p_include_inbound              => TRUE
	      ,p_include_outbound             => TRUE
	      ,p_include_crossdock            => FALSE
	      ,p_include_manufacturing        => TRUE
	      ,p_include_warehousing          => TRUE
	      ,p_from_shipment_number         => l_mmtt_rec.shipment_number
	      ,p_to_shipment_number           => l_mmtt_rec.shipment_number
	      ,p_from_pick_slip_number        => l_mmtt_rec.pick_slip_number
	      ,p_to_pick_slip_number          => l_mmtt_rec.pick_slip_number
	      ,p_delivery_id                  => l_mmtt_rec.trx_source_delivery_id
	      ,p_manufacturing_type           => 1
	      ,p_include_staging_move         => TRUE
	      ,x_return_status                => x_return_status
	      ,x_msg_data                     => x_msg_data
	      ,x_msg_count                    => x_msg_count
	      ,x_record_count                 => l_record_count
	      ,p_is_pending_plan              =>TRUE
	      ,p_is_inprogress_plan           =>TRUE
	      ,p_is_completed_plan            =>TRUE
	      ,p_is_cancelled_plan            =>TRUE
	      ,p_is_aborted_plan              =>TRUE
	      );
      END IF;

      IF(l_debug = 1) THEN
        l_err_msg := 'Status returned by API wms_waveplan_tasks_pvt.query_tasks: '||x_return_status;
        inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
/*      SELECT * BULK COLLECT
        INTO   x_task_tab
        FROM   wms_waveplan_tasks_temp
        WHERE  transaction_temp_id = p_transaction_number;*/

	--Replacing the above by selecting columns from the table.
	SELECT
	 TASK_ID,
	 TRANSACTION_TEMP_ID,
	 PARENT_LINE_ID,
	 INVENTORY_ITEM_ID,
	 ITEM,
	 ITEM_DESCRIPTION,
	 UNIT_WEIGHT,
	 WEIGHT_UOM_CODE,
	 DISPLAY_WEIGHT,
	 UNIT_VOLUME,
	 VOLUME_UOM_CODE,
	 DISPLAY_VOLUME,
	 TIME_ESTIMATE,
	 ORGANIZATION_ID,
	 ORGANIZATION_CODE,
	 REVISION,
	 SUBINVENTORY,
	 LOCATOR_ID,
	 LOCATOR,
	 TRANSACTION_TYPE_ID,
	 TRANSACTION_ACTION_ID,
	 TRANSACTION_SOURCE_TYPE_ID,
	 TRANSACTION_SOURCE_TYPE,
	 TRANSACTION_SOURCE_ID,
	 TRANSACTION_SOURCE_LINE_ID,
	 TO_ORGANIZATION_ID,
	 TO_ORGANIZATION_CODE,
	 TO_SUBINVENTORY,
	 TO_LOCATOR_ID,
	 TO_LOCATOR,
	 TRANSACTION_UOM,
	 TRANSACTION_QUANTITY,
	 USER_TASK_TYPE_ID,
	 USER_TASK_TYPE,
	 PERSON_ID,
	 PERSON_ID_ORIGINAL,
	 PERSON,
	 EFFECTIVE_START_DATE,
	 EFFECTIVE_END_DATE,
	 PERSON_RESOURCE_ID,
	 PERSON_RESOURCE_CODE,
	 MACHINE_RESOURCE_ID,
	 MACHINE_RESOURCE_CODE,
	 EQUIPMENT_INSTANCE,
	 STATUS_ID,
	 STATUS_ID_ORIGINAL,
	 STATUS,
	 CREATION_TIME,
	 DISPATCHED_TIME,
	 LOADED_TIME,
	 DROP_OFF_TIME,
	 MMTT_LAST_UPDATE_DATE,
	 MMTT_LAST_UPDATED_BY,
	 WDT_LAST_UPDATE_DATE,
	 WDT_LAST_UPDATED_BY,
	 PRIORITY,
	 PRIORITY_ORIGINAL,
	 TASK_TYPE_ID,
	 TASK_TYPE,
	 MOVE_ORDER_LINE_ID,
	 PICK_SLIP_NUMBER,
	 CARTONIZATION_ID,
	 ALLOCATED_LPN_ID,
	 CONTAINER_ITEM_ID,
	 CONTENT_LPN_ID,
	 TO_LPN_ID,
	 CONTAINER_ITEM ,
	 CARTONIZATION_LPN,
	 ALLOCATED_LPN ,
	 CONTENT_LPN,
	 TO_LPN,
	 REFERENCE ,
	 REFERENCE_ID,
	 CUSTOMER_ID,
	 CUSTOMER ,
	 SHIP_TO_LOCATION_ID ,
	 SHIP_TO_STATE ,
	 SHIP_TO_COUNTRY,
	 SHIP_TO_POSTAL_CODE,
	 DELIVERY_ID ,
	 DELIVERY ,
	 SHIP_METHOD ,
	 CARRIER_ID ,
	 CARRIER ,
	 SHIPMENT_DATE ,
	 SHIPMENT_PRIORITY,
	 WIP_ENTITY_TYPE,
	 WIP_ENTITY_ID,
	 ASSEMBLY_ID,
	 ASSEMBLY ,
	 LINE_ID,
	 LINE,
	 DEPARTMENT_ID,
	 DEPARTMENT,
	 SOURCE_HEADER,
	 LINE_NUMBER,
	 OPERATION_PLAN_ID,
	 OPERATION_PLAN ,
	 RESULT ,
	 ERROR ,
	 IS_MODIFIED ,
	 EXPANSION_CODE ,
	 FROM_LPN ,
	 FROM_LPN_ID,
	 NUM_OF_CHILD_TASKS,
	 OPERATION_SEQUENCE,
	 OP_PLAN_INSTANCE_ID,
	 PLANS_TASKS ,
	 TRANSACTION_SET_ID,
	 PICKED_LPN_ID,
	 PICKED_LPN,
	 LOADED_LPN,
	 LOADED_LPN_ID,
	 DROP_LPN ,
	 SECONDARY_TRANSACTION_QUANTITY,
	 SECONDARY_TRANSACTION_UOM ,
	 PRIMARY_PRODUCT,
	 LOAD_SEQ_NUMBER
	BULK COLLECT
	INTO   x_task_tab
	FROM   wms_waveplan_tasks_temp
	WHERE  transaction_temp_id = p_transaction_number;

   END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT *
          INTO   l_mcce_rec
          FROM   mtl_cycle_count_entries
          WHERE  cycle_count_entry_id = p_transaction_number;

          BEGIN
          SELECT cycle_count_header_name
            INTO v_cycle_count_name
            FROM mtl_cycle_count_headers
           WHERE cycle_count_header_id = l_mcce_rec.cycle_count_header_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_cycle_count_name   := NULL;
          END;

          IF(l_debug = 1) THEN
            l_err_msg := 'Calling API wms_waveplan_tasks_pvt.query_tasks for cycle count task: '||p_transaction_number;
            inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
            inv_trx_util_pub.trace('Cycle Count Name '||v_cycle_count_name);
          END IF;

          wms_waveplan_tasks_pvt.query_tasks(
           p_add                          => FALSE
          ,p_organization_id              => l_mcce_rec.organization_id
          ,p_subinventory_code            => l_mcce_rec.subinventory
          ,p_locator_id                   => l_mcce_rec.locator_id
          ,p_inventory_item_id            => l_mcce_rec.inventory_item_id
          ,p_from_creation_date           => l_mcce_rec.creation_date
          ,p_to_creation_date             => l_mcce_rec.creation_date
          ,p_is_unreleased                => TRUE
          ,p_is_pending                   => TRUE
          ,p_is_queued                    => TRUE
          ,p_is_dispatched                => TRUE
          ,p_is_active                    => TRUE
          ,p_is_loaded                    => TRUE
          ,p_is_completed                 => TRUE
          ,p_include_inbound              => FALSE
          ,p_include_outbound             => FALSE
          ,p_include_manufacturing        => FALSE
          ,p_include_warehousing          => TRUE
          ,p_manufacturing_type           => 1
          ,p_include_replenishment        => FALSE
          ,p_include_mo_transfer          => FALSE
          ,p_include_mo_issue             => FALSE
          ,p_include_lpn_putaway          => FALSE
          ,p_include_staging_move         => FALSE
          ,p_include_cycle_count          => TRUE
          ,p_cycle_count_name             => v_cycle_count_name
          ,x_return_status                => x_return_status
          ,x_msg_data                     => x_msg_data
          ,x_msg_count                    => x_msg_count
          ,x_record_count                 => l_record_count
          ,p_is_pending_plan              => FALSE
          ,p_is_inprogress_plan           => FALSE
          ,p_is_completed_plan            => FALSE
          ,p_is_cancelled_plan            => FALSE
          ,p_is_aborted_plan              => FALSE
          );


          IF(l_debug = 1) THEN
            l_err_msg := 'Status returned by API wms_waveplan_tasks_pvt.query_tasks for cycle count task: '||x_return_status;
            inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
          END IF;

          IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
/*          SELECT * BULK COLLECT
            INTO   x_task_tab
            FROM   wms_waveplan_tasks_temp
            WHERE  transaction_temp_id = p_transaction_number;*/

	    --Replacing the above by selecting columns from the table.
	    SELECT
		 TASK_ID,
		 TRANSACTION_TEMP_ID,
		 PARENT_LINE_ID,
		 INVENTORY_ITEM_ID,
		 ITEM,
		 ITEM_DESCRIPTION,
		 UNIT_WEIGHT,
		 WEIGHT_UOM_CODE,
		 DISPLAY_WEIGHT,
		 UNIT_VOLUME,
		 VOLUME_UOM_CODE,
		 DISPLAY_VOLUME,
		 TIME_ESTIMATE,
		 ORGANIZATION_ID,
		 ORGANIZATION_CODE,
		 REVISION,
		 SUBINVENTORY,
		 LOCATOR_ID,
		 LOCATOR,
		 TRANSACTION_TYPE_ID,
		 TRANSACTION_ACTION_ID,
		 TRANSACTION_SOURCE_TYPE_ID,
		 TRANSACTION_SOURCE_TYPE,
		 TRANSACTION_SOURCE_ID,
		 TRANSACTION_SOURCE_LINE_ID,
		 TO_ORGANIZATION_ID,
		 TO_ORGANIZATION_CODE,
		 TO_SUBINVENTORY,
		 TO_LOCATOR_ID,
		 TO_LOCATOR,
		 TRANSACTION_UOM,
		 TRANSACTION_QUANTITY,
		 USER_TASK_TYPE_ID,
		 USER_TASK_TYPE,
		 PERSON_ID,
		 PERSON_ID_ORIGINAL,
		 PERSON,
		 EFFECTIVE_START_DATE,
		 EFFECTIVE_END_DATE,
		 PERSON_RESOURCE_ID,
		 PERSON_RESOURCE_CODE,
		 MACHINE_RESOURCE_ID,
		 MACHINE_RESOURCE_CODE,
		 EQUIPMENT_INSTANCE,
		 STATUS_ID,
		 STATUS_ID_ORIGINAL,
		 STATUS,
		 CREATION_TIME,
		 DISPATCHED_TIME,
		 LOADED_TIME,
		 DROP_OFF_TIME,
		 MMTT_LAST_UPDATE_DATE,
		 MMTT_LAST_UPDATED_BY,
		 WDT_LAST_UPDATE_DATE,
		 WDT_LAST_UPDATED_BY,
		 PRIORITY,
		 PRIORITY_ORIGINAL,
		 TASK_TYPE_ID,
		 TASK_TYPE,
		 MOVE_ORDER_LINE_ID,
		 PICK_SLIP_NUMBER,
		 CARTONIZATION_ID,
		 ALLOCATED_LPN_ID,
		 CONTAINER_ITEM_ID,
		 CONTENT_LPN_ID,
		 TO_LPN_ID,
		 CONTAINER_ITEM ,
		 CARTONIZATION_LPN,
		 ALLOCATED_LPN ,
		 CONTENT_LPN,
		 TO_LPN,
		 REFERENCE ,
		 REFERENCE_ID,
		 CUSTOMER_ID,
		 CUSTOMER ,
		 SHIP_TO_LOCATION_ID ,
		 SHIP_TO_STATE ,
		 SHIP_TO_COUNTRY,
		 SHIP_TO_POSTAL_CODE,
		 DELIVERY_ID ,
		 DELIVERY ,
		 SHIP_METHOD ,
		 CARRIER_ID ,
		 CARRIER ,
		 SHIPMENT_DATE ,
		 SHIPMENT_PRIORITY,
		 WIP_ENTITY_TYPE,
		 WIP_ENTITY_ID,
		 ASSEMBLY_ID,
		 ASSEMBLY ,
		 LINE_ID,
		 LINE,
		 DEPARTMENT_ID,
		 DEPARTMENT,
		 SOURCE_HEADER,
		 LINE_NUMBER,
		 OPERATION_PLAN_ID,
		 OPERATION_PLAN ,
		 RESULT ,
		 ERROR ,
		 IS_MODIFIED ,
		 EXPANSION_CODE ,
		 FROM_LPN ,
		 FROM_LPN_ID,
		 NUM_OF_CHILD_TASKS,
		 OPERATION_SEQUENCE,
		 OP_PLAN_INSTANCE_ID,
		 PLANS_TASKS ,
		 TRANSACTION_SET_ID,
		 PICKED_LPN_ID,
		 PICKED_LPN,
		 LOADED_LPN,
		 LOADED_LPN_ID,
		 DROP_LPN ,
		 SECONDARY_TRANSACTION_QUANTITY,
		 SECONDARY_TRANSACTION_UOM ,
		 PRIMARY_PRODUCT,
		 LOAD_SEQ_NUMBER
	    BULK COLLECT
	    INTO   x_task_tab
	    FROM   wms_waveplan_tasks_temp
	    WHERE  transaction_temp_id = p_transaction_number;

          END IF;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
	  --start changes for completed tasks
      BEGIN
      inv_trx_util_pub.trace('checking in wdth for completed inbound or crossdock tasks');
      SELECT *
      INTO   l_wdth_rec
      FROM   wms_dispatched_tasks_history
      WHERE  transaction_id = p_transaction_number;

      IF(l_debug = 1) THEN
        l_err_msg := 'Calling API wms_waveplan_tasks_pvt.query_tasks for task: '||p_transaction_number;
        inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
      END IF;

      --Munish  checking completed crossdock task
      OPEN c_cd_task1 (p_transaction_number);
      FETCH c_cd_task1 into c_cd_exist;
      CLOSE c_cd_task1;

      If (c_cd_exist = 1)  THEN
      inv_trx_util_pub.trace('calling API wms_waveplan_tasks_pvt.query_tasks for completed crossdock task');
      --CALLL wms_waveplan_tasks_pvt.query_tasks API WITH
      --p_crossdock_include=true and p_outbound_include=false and p_inbound_include=false
	      wms_waveplan_tasks_pvt.query_tasks(
	       p_add                          => FALSE
	      ,p_organization_id              => l_wdth_rec.organization_id
	      ,p_subinventory_code            => l_wdth_rec.source_subinventory_code
	      ,p_locator_id                   => l_wdth_rec.source_locator_id
	      ,p_to_subinventory_code         => l_wdth_rec.dest_subinventory_code
	      ,p_to_locator_id                => l_wdth_rec.dest_locator_id
	      ,p_inventory_item_id            => l_wdth_rec.inventory_item_id
	      ,p_from_task_priority           => l_wdth_rec.priority
	      ,p_to_task_priority             => l_wdth_rec.priority
	      ,p_from_creation_date           => TRUNC(l_wdth_rec.creation_date)
	      ,p_to_creation_date             => TRUNC(l_wdth_rec.creation_date)
	      ,p_is_unreleased                => FALSE
	      ,p_is_pending                   => FALSE
	      ,p_is_queued                    => FALSE
	      ,p_is_dispatched                => FALSE
	      ,p_is_active                    => FALSE
	      ,p_is_loaded                    => FALSE
	      ,p_is_completed                 => TRUE
	      ,p_include_inbound              => FALSE
	      ,p_include_outbound             => FALSE
	      ,p_include_crossdock            => TRUE
	      ,p_include_manufacturing        => FALSE
	      ,p_include_warehousing          => FALSE
	      ,p_from_shipment_number         => NULL
	      ,p_to_shipment_number           => NULL
	      ,p_from_pick_slip_number        => NULL
	      ,p_to_pick_slip_number          => NULL
	      ,p_delivery_id                  => NULL
	      ,p_manufacturing_type           => 1
	      ,p_include_staging_move         => FALSE
	      ,x_return_status                => x_return_status
	      ,x_msg_data                     => x_msg_data
	      ,x_msg_count                    => x_msg_count
	      ,x_record_count                 => l_record_count
	      ,p_is_pending_plan              => FALSE
	      ,p_is_inprogress_plan           => FALSE
	      ,p_is_completed_plan            => FALSE
	      ,p_is_cancelled_plan            => FALSE
	      ,p_is_aborted_plan              => FALSE
	      );
    ELSE
    --CALLL wms_waveplan_tasks_pvt.query_tasks API WITH p_crossdock_include=false and
    --p_outbound_include=true and p_inbound_include=true
    inv_trx_util_pub.trace('calling completed inbound task');--mkgupta2
    IF   l_wdth_rec.is_parent ='Y' THEN
    inv_trx_util_pub.trace('checking if its a parent task completed inbound task');
	 l_wdth_rec.source_subinventory_code:=NULL;
         l_wdth_rec.source_locator_id:=NULL;
    END IF;
    	       wms_waveplan_tasks_pvt.query_tasks(
	       p_add                          => FALSE
	      ,p_organization_id              => l_wdth_rec.organization_id
	      ,p_subinventory_code            => l_wdth_rec.source_subinventory_code
	      ,p_locator_id                   => l_wdth_rec.source_locator_id
	      ,p_to_subinventory_code         => l_wdth_rec.dest_subinventory_code
	      ,p_to_locator_id                => l_wdth_rec.dest_locator_id
	      ,p_inventory_item_id            => l_wdth_rec.inventory_item_id
	      ,p_from_task_priority           => NULL
	      ,p_to_task_priority             => NULL
	      ,p_from_creation_date           => TRUNC(l_wdth_rec.creation_date)
	      ,p_to_creation_date             => TRUNC(l_wdth_rec.creation_date)
	      ,p_is_unreleased                => FALSE
	      ,p_is_pending                   => FALSE
	      ,p_is_queued                    => FALSE
	      ,p_is_dispatched                => FALSE
	      ,p_is_active                    => FALSE
	      ,p_is_loaded                    => FALSE
	      ,p_is_completed                 => TRUE
	      ,p_include_inbound              => TRUE
	      ,p_include_outbound             => FALSE
	      ,p_include_crossdock            => FALSE
	      ,p_include_manufacturing        => FALSE
	      ,p_include_warehousing          => FALSE
	      ,p_from_shipment_number         => NULL
	      ,p_to_shipment_number           => NULL
	      ,p_from_pick_slip_number        => NULL
	      ,p_to_pick_slip_number          => NULL
	      ,p_delivery_id                  => NULL
	      ,p_manufacturing_type           => 1
	      ,p_include_staging_move         => FALSE
	      ,x_return_status                => x_return_status
	      ,x_msg_data                     => x_msg_data
	      ,x_msg_count                    => x_msg_count
	      ,x_record_count                 => l_record_count
	      ,p_is_pending_plan              =>TRUE
	      ,p_is_inprogress_plan           =>TRUE
	      ,p_is_completed_plan            =>TRUE
	      ,p_is_cancelled_plan            =>TRUE
	      ,p_is_aborted_plan              =>TRUE
	      );
      END IF;

      IF(l_debug = 1) THEN
        l_err_msg := 'Status returned by API wms_waveplan_tasks_pvt.query_tasks: '||x_return_status;
        inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
     	SELECT
	 TASK_ID,
	 TRANSACTION_TEMP_ID,
	 PARENT_LINE_ID,
	 INVENTORY_ITEM_ID,
	 ITEM,
	 ITEM_DESCRIPTION,
	 UNIT_WEIGHT,
	 WEIGHT_UOM_CODE,
	 DISPLAY_WEIGHT,
	 UNIT_VOLUME,
	 VOLUME_UOM_CODE,
	 DISPLAY_VOLUME,
	 TIME_ESTIMATE,
	 ORGANIZATION_ID,
	 ORGANIZATION_CODE,
	 REVISION,
	 SUBINVENTORY,
	 LOCATOR_ID,
	 LOCATOR,
	 TRANSACTION_TYPE_ID,
	 TRANSACTION_ACTION_ID,
	 TRANSACTION_SOURCE_TYPE_ID,
	 TRANSACTION_SOURCE_TYPE,
	 TRANSACTION_SOURCE_ID,
	 TRANSACTION_SOURCE_LINE_ID,
	 TO_ORGANIZATION_ID,
	 TO_ORGANIZATION_CODE,
	 TO_SUBINVENTORY,
	 TO_LOCATOR_ID,
	 TO_LOCATOR,
	 TRANSACTION_UOM,
	 TRANSACTION_QUANTITY,
	 USER_TASK_TYPE_ID,
	 USER_TASK_TYPE,
	 PERSON_ID,
	 PERSON_ID_ORIGINAL,
	 PERSON,
	 EFFECTIVE_START_DATE,
	 EFFECTIVE_END_DATE,
	 PERSON_RESOURCE_ID,
	 PERSON_RESOURCE_CODE,
	 MACHINE_RESOURCE_ID,
	 MACHINE_RESOURCE_CODE,
	 EQUIPMENT_INSTANCE,
	 STATUS_ID,
	 STATUS_ID_ORIGINAL,
	 STATUS,
	 CREATION_TIME,
	 DISPATCHED_TIME,
	 LOADED_TIME,
	 DROP_OFF_TIME,
	 MMTT_LAST_UPDATE_DATE,
	 MMTT_LAST_UPDATED_BY,
	 WDT_LAST_UPDATE_DATE,
	 WDT_LAST_UPDATED_BY,
	 PRIORITY,
	 PRIORITY_ORIGINAL,
	 TASK_TYPE_ID,
	 TASK_TYPE,
	 MOVE_ORDER_LINE_ID,
	 PICK_SLIP_NUMBER,
	 CARTONIZATION_ID,
	 ALLOCATED_LPN_ID,
	 CONTAINER_ITEM_ID,
	 CONTENT_LPN_ID,
	 TO_LPN_ID,
	 CONTAINER_ITEM ,
	 CARTONIZATION_LPN,
	 ALLOCATED_LPN ,
	 CONTENT_LPN,
	 TO_LPN,
	 REFERENCE ,
	 REFERENCE_ID,
	 CUSTOMER_ID,
	 CUSTOMER ,
	 SHIP_TO_LOCATION_ID ,
	 SHIP_TO_STATE ,
	 SHIP_TO_COUNTRY,
	 SHIP_TO_POSTAL_CODE,
	 DELIVERY_ID ,
	 DELIVERY ,
	 SHIP_METHOD ,
	 CARRIER_ID ,
	 CARRIER ,
	 SHIPMENT_DATE ,
	 SHIPMENT_PRIORITY,
	 WIP_ENTITY_TYPE,
	 WIP_ENTITY_ID,
	 ASSEMBLY_ID,
	 ASSEMBLY ,
	 LINE_ID,
	 LINE,
	 DEPARTMENT_ID,
	 DEPARTMENT,
	 SOURCE_HEADER,
	 LINE_NUMBER,
	 OPERATION_PLAN_ID,
	 OPERATION_PLAN ,
	 RESULT ,
	 ERROR ,
	 IS_MODIFIED ,
	 EXPANSION_CODE ,
	 FROM_LPN ,
	 FROM_LPN_ID,
	 NUM_OF_CHILD_TASKS,
	 OPERATION_SEQUENCE,
	 OP_PLAN_INSTANCE_ID,
	 PLANS_TASKS ,
	 TRANSACTION_SET_ID,
	 PICKED_LPN_ID,
	 PICKED_LPN,
	 LOADED_LPN,
	 LOADED_LPN_ID,
	 DROP_LPN ,
	 SECONDARY_TRANSACTION_QUANTITY,
	 SECONDARY_TRANSACTION_UOM ,
	 PRIMARY_PRODUCT,
	 LOAD_SEQ_NUMBER
	BULK COLLECT
	INTO   x_task_tab
	FROM   wms_waveplan_tasks_temp
	WHERE  transaction_temp_id = p_transaction_number;
        END IF;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
                inv_trx_util_pub.trace('in the NO_DATA_FOUND exception block of inbound/crossdock completed task');
             BEGIN
                inv_trx_util_pub.trace('checking in mmt for outbound/warehouse/manufacturing completed task');
               SELECT *
               INTO   l_mmt_rec
               FROM   mtl_material_transactions
               WHERE  transaction_id = p_transaction_number;
               inv_trx_util_pub.trace('task existing in mmt');

	       IF(l_debug = 1) THEN
               l_err_msg := 'Calling API wms_waveplan_tasks_pvt.query_tasks for task: '||p_transaction_number;
               inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
               END IF;

	       inv_trx_util_pub.trace('checking for bulk task');
              IF   l_mmt_rec.parent_transaction_id IS NOT NULL THEN
                   l_mmt_rec.pick_slip_number:=NULL;
              END IF;
              wms_waveplan_tasks_pvt.query_tasks(
	       p_add                          => FALSE
	      ,p_organization_id              => l_mmt_rec.organization_id
	      ,p_subinventory_code            => l_mmt_rec.subinventory_code
	      ,p_locator_id                   => l_mmt_rec.locator_id
	      ,p_to_subinventory_code         => l_mmt_rec.transfer_subinventory
	      ,p_to_locator_id                => l_mmt_rec.transfer_locator_id
	      ,p_inventory_item_id            => l_mmt_rec.inventory_item_id
	      ,p_from_task_priority           => NULL
	      ,p_to_task_priority             => NULL
	      ,p_from_creation_date           => TRUNC(l_mmt_rec.creation_date)
	      ,p_to_creation_date             => TRUNC(l_mmt_rec.creation_date)
	      ,p_is_unreleased                => FALSE
	      ,p_is_pending                   => FALSE
	      ,p_is_queued                    => FALSE
	      ,p_is_dispatched                => FALSE
	      ,p_is_active                    => FALSE
	      ,p_is_loaded                    => FALSE
	      ,p_is_completed                 => TRUE
	      ,p_include_inbound              => FALSE
	      ,p_include_outbound             => TRUE
	      ,p_include_crossdock            => FALSE
	      ,p_include_manufacturing        => TRUE
	      ,p_include_warehousing          => TRUE
	      ,p_from_shipment_number         => l_mmt_rec.shipment_number
	      ,p_to_shipment_number           => l_mmt_rec.shipment_number
	      ,p_from_pick_slip_number        => l_mmt_rec.pick_slip_number
	      ,p_to_pick_slip_number          => l_mmt_rec.pick_slip_number
	      ,p_delivery_id                  => l_mmt_rec.trx_source_delivery_id
	      ,p_manufacturing_type           => 1
	      ,p_include_staging_move         => TRUE
	      ,x_return_status                => x_return_status
	      ,x_msg_data                     => x_msg_data
	      ,x_msg_count                    => x_msg_count
	      ,x_record_count                 => l_record_count
	      ,p_is_pending_plan              =>FALSE
	      ,p_is_inprogress_plan           =>FALSE
	      ,p_is_completed_plan            =>FALSE
	      ,p_is_cancelled_plan            =>FALSE
	      ,p_is_aborted_plan              =>FALSE
	      );

            IF(l_debug = 1) THEN
             l_err_msg := 'Status returned by API wms_waveplan_tasks_pvt.query_tasks: '||x_return_status;
             inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
            END IF;

           IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         SELECT
	 TASK_ID,
	 TRANSACTION_TEMP_ID,
	 PARENT_LINE_ID,
	 INVENTORY_ITEM_ID,
	 ITEM,
	 ITEM_DESCRIPTION,
	 UNIT_WEIGHT,
	 WEIGHT_UOM_CODE,
	 DISPLAY_WEIGHT,
	 UNIT_VOLUME,
	 VOLUME_UOM_CODE,
	 DISPLAY_VOLUME,
	 TIME_ESTIMATE,
	 ORGANIZATION_ID,
	 ORGANIZATION_CODE,
	 REVISION,
	 SUBINVENTORY,
	 LOCATOR_ID,
	 LOCATOR,
	 TRANSACTION_TYPE_ID,
	 TRANSACTION_ACTION_ID,
	 TRANSACTION_SOURCE_TYPE_ID,
	 TRANSACTION_SOURCE_TYPE,
	 TRANSACTION_SOURCE_ID,
	 TRANSACTION_SOURCE_LINE_ID,
	 TO_ORGANIZATION_ID,
	 TO_ORGANIZATION_CODE,
	 TO_SUBINVENTORY,
	 TO_LOCATOR_ID,
	 TO_LOCATOR,
	 TRANSACTION_UOM,
	 TRANSACTION_QUANTITY,
	 USER_TASK_TYPE_ID,
	 USER_TASK_TYPE,
	 PERSON_ID,
	 PERSON_ID_ORIGINAL,
	 PERSON,
	 EFFECTIVE_START_DATE,
	 EFFECTIVE_END_DATE,
	 PERSON_RESOURCE_ID,
	 PERSON_RESOURCE_CODE,
	 MACHINE_RESOURCE_ID,
	 MACHINE_RESOURCE_CODE,
	 EQUIPMENT_INSTANCE,
	 STATUS_ID,
	 STATUS_ID_ORIGINAL,
	 STATUS,
	 CREATION_TIME,
	 DISPATCHED_TIME,
	 LOADED_TIME,
	 DROP_OFF_TIME,
	 MMTT_LAST_UPDATE_DATE,
	 MMTT_LAST_UPDATED_BY,
	 WDT_LAST_UPDATE_DATE,
	 WDT_LAST_UPDATED_BY,
	 PRIORITY,
	 PRIORITY_ORIGINAL,
	 TASK_TYPE_ID,
	 TASK_TYPE,
	 MOVE_ORDER_LINE_ID,
	 PICK_SLIP_NUMBER,
	 CARTONIZATION_ID,
	 ALLOCATED_LPN_ID,
	 CONTAINER_ITEM_ID,
	 CONTENT_LPN_ID,
	 TO_LPN_ID,
	 CONTAINER_ITEM ,
	 CARTONIZATION_LPN,
	 ALLOCATED_LPN ,
	 CONTENT_LPN,
	 TO_LPN,
	 REFERENCE ,
	 REFERENCE_ID,
	 CUSTOMER_ID,
	 CUSTOMER ,
	 SHIP_TO_LOCATION_ID ,
	 SHIP_TO_STATE ,
	 SHIP_TO_COUNTRY,
	 SHIP_TO_POSTAL_CODE,
	 DELIVERY_ID ,
	 DELIVERY ,
	 SHIP_METHOD ,
	 CARRIER_ID ,
	 CARRIER ,
	 SHIPMENT_DATE ,
	 SHIPMENT_PRIORITY,
	 WIP_ENTITY_TYPE,
	 WIP_ENTITY_ID,
	 ASSEMBLY_ID,
	 ASSEMBLY ,
	 LINE_ID,
	 LINE,
	 DEPARTMENT_ID,
	 DEPARTMENT,
	 SOURCE_HEADER,
	 LINE_NUMBER,
	 OPERATION_PLAN_ID,
	 OPERATION_PLAN ,
	 RESULT ,
	 ERROR ,
	 IS_MODIFIED ,
	 EXPANSION_CODE ,
	 FROM_LPN ,
	 FROM_LPN_ID,
	 NUM_OF_CHILD_TASKS,
	 OPERATION_SEQUENCE,
	 OP_PLAN_INSTANCE_ID,
	 PLANS_TASKS ,
	 TRANSACTION_SET_ID,
	 PICKED_LPN_ID,
	 PICKED_LPN,
	 LOADED_LPN,
	 LOADED_LPN_ID,
	 DROP_LPN ,
	 SECONDARY_TRANSACTION_QUANTITY,
	 SECONDARY_TRANSACTION_UOM ,
	 PRIMARY_PRODUCT,
	 LOAD_SEQ_NUMBER
	BULK COLLECT
	INTO   x_task_tab
	FROM   wms_waveplan_tasks_temp
	WHERE  transaction_temp_id = p_transaction_number;

         END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
             inv_trx_util_pub.trace('in the exception block of outbond/manufacturing/warehousing complete tasks');
             fnd_message.set_name('WMS', 'WMS_INVALID_TASK');
             fnd_msg_pub.ADD;
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
             l_err_msg := 'Failed to fetch data from MMTT,MCCE,MMT or WDTH tables for transaction number '||p_transaction_number;
             IF(l_debug = 1) THEN
              inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
             END IF;
         END;
          --end the begin block for outbond/manufacturing/warehousing complete tasks
       END;
          --end the begin block for inbound/crossdock complete tasks
      END;
          --end the begin block for cycle count tasks
      WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
        l_err_msg := substr(SQLERRM,1,1000);
        IF(l_debug = 1) THEN
          inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
        END IF;
    END;
         --end the begin block for uncompleted tasks

  ELSIF (p_query_name IS NOT NULL) THEN
  ---initialize the main table
  initialize_main_table();

  ---populate the l_query_tab table with cursor output
  BEGIN
    SELECT REPLACE(field_name,'FIND_TASKS.','') field_name,
           decode(field_value,'Y','T','N','F',field_value) field_value
           BULK COLLECT
    INTO   l_query_tab
    FROM   wms_saved_queries
    WHERE  query_name = p_query_name
    ORDER BY 1;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('WMS', 'WMS_INVALID_VALUE');
      fnd_msg_pub.ADD;
      l_err_msg := substr(SQLERRM,1,1000);
      RAISE l_qry_fail;
  END;

  IF (l_query_tab.COUNT > 0) THEN
    ---pass the field_values from l_query_tab table
    ---to the field_values in g_main_tab table for
    ---matching field_names
    FOR i IN l_query_tab.FIRST..l_query_tab.LAST
      LOOP
        FOR j IN g_main_tab.FIRST..g_main_tab.LAST
          LOOP
            IF (g_main_tab(j).field_name = l_query_tab(i).field_name) THEN
              g_main_tab(j).field_value := l_query_tab(i).field_value;
              EXIT; -- exit the inner loop
            END IF;
          END LOOP; --- loop for j
      END LOOP; --- loop for i
  END IF; ----l_query_tab.COUNT > 0

--- check the credentials of the query_name passed as input

---if 'inbound' task is queried then
--Munish is adding (g_main_tab(93).field_value = FND_API.G_TRUE) to check crossdock task
  IF(g_main_tab(35).field_value = FND_API.G_TRUE) OR (g_main_tab(93).field_value = FND_API.G_TRUE)  THEN
--  IF(g_main_tab(35).field_value = FND_API.G_TRUE) THEN
    ---if its planned or independent task
    IF ((g_main_tab(36).field_value = FND_API.G_TRUE)
    OR  (g_main_tab(58).field_value = FND_API.G_TRUE))
    THEN
      ---the status has to be either one of the following:
      ---unreleased, pending, queued, dispatched,active, loaded, completed
      IF((g_main_tab(1).field_value = FND_API.G_TRUE)
      OR (g_main_tab(5).field_value = FND_API.G_TRUE)
      OR (g_main_tab(12).field_value = FND_API.G_TRUE)
      OR (g_main_tab(39).field_value = FND_API.G_TRUE)
      OR (g_main_tab(51).field_value = FND_API.G_TRUE)
      OR (g_main_tab(59).field_value = FND_API.G_TRUE)
      OR (g_main_tab(90).field_value = FND_API.G_TRUE))
      THEN
        l_execute_qry := TRUE;
      END IF;
    --else if it's not planned or independent task then
    --it has to be either one of plan_pending, plan_in_progress, plan_completed
    --plan_cancelled or plan_aborted
    ELSIF((g_main_tab(53).field_value = FND_API.G_TRUE)
       OR (g_main_tab(54).field_value = FND_API.G_TRUE)
       OR (g_main_tab(55).field_value = FND_API.G_TRUE)
       OR (g_main_tab(56).field_value = FND_API.G_TRUE)
       OR (g_main_tab(57).field_value = FND_API.G_TRUE))
    THEN
      l_execute_qry := TRUE;
    ELSE
      l_execute_qry := FALSE;
      l_err_msg := 'Invalid query criteria';
      fnd_message.set_name('WMS', 'WMS_NO_SOURCE_ENTERED');
      fnd_msg_pub.ADD;
      RAISE l_qry_fail;
    END IF;
  END IF;

  --If its either outbound, manufacturing or warehousing tasks
  IF ((g_main_tab(50).field_value = FND_API.G_TRUE)
    OR(g_main_tab(42).field_value = FND_API.G_TRUE)
    OR(g_main_tab(92).field_value = FND_API.G_TRUE))
  THEN
      ---the status has to be either one of the following:
      ---unreleased, pending, queued, dispatched,active, loaded, completed
      IF((g_main_tab(1).field_value = FND_API.G_TRUE)
      OR (g_main_tab(5).field_value = FND_API.G_TRUE)
      OR (g_main_tab(12).field_value = FND_API.G_TRUE)
      OR (g_main_tab(39).field_value = FND_API.G_TRUE)
      OR (g_main_tab(51).field_value = FND_API.G_TRUE)
      OR (g_main_tab(59).field_value = FND_API.G_TRUE)
      OR (g_main_tab(90).field_value = FND_API.G_TRUE))
      THEN
        l_execute_qry := TRUE;
      END IF;
  ---else if its neither one of the following tasks then generate error message
  ---outbound, inbound, manufacturing, warehousing
  ELSIF ((g_main_tab(50).field_value = FND_API.G_FALSE)
      AND(g_main_tab(42).field_value = FND_API.G_FALSE)
      AND(g_main_tab(92).field_value = FND_API.G_FALSE)
      AND(g_main_tab(35).field_value = FND_API.G_FALSE)
      AND (g_main_tab(93).field_value = FND_API.G_FALSE))
  THEN
    l_execute_qry := FALSE;
    l_err_msg := 'Invalid query criteria';
    fnd_message.set_name('WMS', 'WMS_NO_SOURCE_ENTERED');
    fnd_msg_pub.ADD;
    RAISE l_qry_fail;
  END IF;

--- Derive organization_id
  BEGIN
    SELECT DISTINCT organization_id
    INTO   l_organization_id
    FROM   wms_saved_queries
    WHERE  query_name = p_query_name;
  EXCEPTION
    WHEN OTHERS THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
    fnd_msg_pub.ADD;
    l_err_msg := concat('Invalid Org: ',substr(SQLERRM,1,1000));
    RAISE l_invalid_org;
    NULL;
  END;

---logic to initialize variables
---v_include_sales_orders, v_include_internal_orders
  l_order_type := g_main_tab(49).field_value;

  IF (upper(l_order_type) = 'B') THEN
    l_include_sales_orders    := TRUE;
    l_include_internal_orders := TRUE;
  ELSIF (upper(l_order_type) = 'S') THEN
    l_include_sales_orders    := TRUE;
  ELSIF (upper(l_order_type) = 'I') THEN
    l_include_internal_orders    := TRUE;
  END IF;
---end logic to initialize variables
---v_include_sales_orders , v_include_internal_orders

---call the main API to find the queried tasks
  IF (l_execute_qry) THEN

    IF(l_debug = 1) THEN
      l_err_msg := 'Calling API wms_waveplan_tasks_pvt.query_tasks for Query: '||p_query_name;
      inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
    END IF;

      wms_waveplan_tasks_pvt.query_tasks (
      FALSE,                          ---p_add                   BOOLEAN DEFAULT FALSE,
      l_organization_id,              ---p_organization_id       NUMBER DEFAULT NULL,
      g_main_tab(67).field_value,     ---p_subinventory_code     VARCHAR2 DEFAULT NULL,
      g_main_tab(40).field_value,     ---p_locator_id            NUMBER DEFAULT NULL,
      g_main_tab(85).field_value,     ---p_to_subinventory_code  VARCHAR2 DEFAULT NULL,
      g_main_tab(72).field_value,     ---p_to_locator_id         NUMBER DEFAULT NULL,
      g_main_tab(37).field_value,     ---p_inventory_item_id     NUMBER DEFAULT NULL,
      g_main_tab(4).field_value,      ---p_category_set_id       NUMBER DEFAULT NULL,
      g_main_tab(38).field_value,     ---p_item_category_id      NUMBER DEFAULT NULL,
      g_main_tab(13).field_value,     ---p_person_id             NUMBER DEFAULT NULL,
      g_main_tab(52).field_value,     ---p_person_resource_id    NUMBER DEFAULT NULL,
      g_main_tab(15).field_value,     ---p_equipment_type_id     NUMBER DEFAULT NULL,
      NULL,                           ---p_machine_resource_id   NUMBER DEFAULT NULL,
      g_main_tab(14).field_value,     ---p_machine_instance      VARCHAR2 DEFAULT NULL,
      g_main_tab(91).field_value,     ---p_user_task_type_id     NUMBER DEFAULT NULL,
      g_main_tab(33).field_value,     ---p_from_task_quantity    NUMBER DEFAULT NULL,
      g_main_tab(87).field_value,     ---p_to_task_quantity      NUMBER DEFAULT NULL,
      g_main_tab(32).field_value,     ---p_from_task_priority    NUMBER DEFAULT NULL,
      g_main_tab(86).field_value,     ---p_to_task_priority      NUMBER DEFAULT NULL,
      g_main_tab(16).field_value,     ---p_from_creation_date    DATE DEFAULT NULL,
      g_main_tab(68).field_value,     ---p_to_creation_date      DATE DEFAULT NULL,
      fnd_api.to_boolean(g_main_tab(90).field_value),     ---p_is_unreleased         BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(51).field_value),     ---p_is_pending            BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(59).field_value),     ---p_is_queued             BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(12).field_value),     ---p_is_dispatched         BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(1).field_value),      ---p_is_active             BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(39).field_value),     ---p_is_loaded             BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(5).field_value),      ---p_is_completed          BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(35).field_value),     ---p_include_inbound       BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(50).field_value),     ---p_include_outbound      BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(93).field_value),                      ---p_include_crossdock
      fnd_api.to_boolean(g_main_tab(42).field_value),     ---p_include_manufacturing BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(92).field_value),     ---p_include_warehousing   BOOLEAN DEFAULT FALSE,
      g_main_tab(21).field_value,     ---p_from_po_header_id     NUMBER DEFAULT NULL,
      g_main_tab(74).field_value,     ---p_to_po_header_id       NUMBER DEFAULT NULL,
      g_main_tab(22).field_value,     ---p_from_purchase_order   VARCHAR2 DEFAULT NULL,
      g_main_tab(75).field_value,     ---p_to_purchase_order     VARCHAR2 DEFAULT NULL,
      g_main_tab(27).field_value,     ---p_from_rma_header_id    NUMBER DEFAULT NULL,
      g_main_tab(80).field_value,     ---p_to_rma_header_id      NUMBER DEFAULT NULL,
      g_main_tab(26).field_value,     ---p_from_rma              VARCHAR2 DEFAULT NULL,
      g_main_tab(79).field_value,     ---p_to_rma                VARCHAR2 DEFAULT NULL,
      g_main_tab(25).field_value,     ---p_from_requisition_header_id  NUMBER DEFAULT NULL,
      g_main_tab(78).field_value,     ---p_to_requisition_header_id    NUMBER DEFAULT NULL,
      g_main_tab(24).field_value,     ---p_from_requisition      VARCHAR2 DEFAULT NULL,
      g_main_tab(77).field_value,     ---p_to_requisition        VARCHAR2 DEFAULT NULL,
      g_main_tab(29).field_value,     ---p_from_shipment_number  VARCHAR2 DEFAULT NULL,
      g_main_tab(82).field_value,     ---p_to_shipment_number    VARCHAR2 DEFAULT NULL,
      l_include_sales_orders,         ---p_include_sales_orders  BOOLEAN DEFAULT TRUE,
      l_include_internal_orders,      ---p_include_internal_orders BOOLEAN DEFAULT TRUE,
      g_main_tab(28).field_value,     ---p_from_sales_order_id   NUMBER DEFAULT NULL,
      g_main_tab(81).field_value,     ---p_to_sales_order_id     NUMBER DEFAULT NULL,
      g_main_tab(20).field_value,     ---p_from_pick_slip_number NUMBER DEFAULT NULL,
      g_main_tab(73).field_value,     ---p_to_pick_slip_number   NUMBER DEFAULT NULL,
      g_main_tab(7).field_value,      ---p_customer_id           NUMBER DEFAULT NULL,
      g_main_tab(6).field_value,      ---p_customer_category     VARCHAR2 DEFAULT NULL,
      g_main_tab(10).field_value,     ---p_delivery_id           NUMBER DEFAULT NULL,
      g_main_tab(3).field_value,      ---p_carrier_id            NUMBER DEFAULT NULL,
      g_main_tab(61).field_value,     ---p_ship_method           VARCHAR2 DEFAULT NULL,
      g_main_tab(65).field_value,     ---p_shipment_priority     VARCHAR2 DEFAULT NULL,
      g_main_tab(89).field_value,     ---p_trip_id               NUMBER DEFAULT NULL,
      g_main_tab(30).field_value,     ---p_from_shipment_date    DATE DEFAULT NULL,
      g_main_tab(83).field_value,     ---p_to_shipment_date      DATE DEFAULT NULL,
      g_main_tab(64).field_value,     ---p_ship_to_state         VARCHAR2 DEFAULT NULL,
      g_main_tab(62).field_value,     ---p_ship_to_country       VARCHAR2 DEFAULT NULL,
      g_main_tab(63).field_value,     ---p_ship_to_postal_code   VARCHAR2 DEFAULT NULL,
      g_main_tab(19).field_value,     ---p_from_number_of_order_lines NUMBER DEFAULT NULL,
      g_main_tab(71).field_value,     ---p_to_number_of_order_lines   NUMBER DEFAULT NULL,
      g_main_tab(43).field_value,     ---p_manufacturing_type   VARCHAR2 DEFAULT NULL,
      g_main_tab(17).field_value,     ---p_from_job             VARCHAR2 DEFAULT NULL,
      g_main_tab(69).field_value,     ---p_to_job               VARCHAR2 DEFAULT NULL,
      g_main_tab(2).field_value,      ---p_assembly_id          NUMBER DEFAULT NULL,
      g_main_tab(31).field_value,     ---p_from_start_date      DATE DEFAULT NULL,
      g_main_tab(84).field_value,     ---p_to_start_date        DATE DEFAULT NULL,
      g_main_tab(18).field_value,     ---p_from_line            VARCHAR2 DEFAULT NULL,
      g_main_tab(70).field_value,     ---p_to_line              VARCHAR2 DEFAULT NULL,
      g_main_tab(11).field_value,     ---p_department_id        NUMBER DEFAULT NULL,
      fnd_api.to_boolean(g_main_tab(60).field_value),     ---p_include_replenishment  BOOLEAN DEFAULT TRUE,
      g_main_tab(23).field_value,     ---p_from_replenishment_mo  VARCHAR2 DEFAULT NULL,
      g_main_tab(76).field_value,     ---p_to_replenishment_mo  VARCHAR2 DEFAULT NULL,
      fnd_api.to_boolean(g_main_tab(45).field_value),     ---p_include_mo_transfer  BOOLEAN DEFAULT TRUE,
      fnd_api.to_boolean(g_main_tab(44).field_value),     ---p_include_mo_issue     BOOLEAN DEFAULT TRUE,
      g_main_tab(34).field_value,                 ---p_from_transfer_issue_mo VARCHAR2 DEFAULT NULL,
      g_main_tab(88).field_value,                 ---p_to_transfer_issue_mo VARCHAR2 DEFAULT NULL,
      fnd_api.to_boolean(g_main_tab(41).field_value),     ---p_include_lpn_putaway  BOOLEAN DEFAULT TRUE,
      fnd_api.to_boolean(g_main_tab(66).field_value),     ---p_include_staging_move BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(9).field_value),      ---p_include_cycle_count  BOOLEAN DEFAULT TRUE,
      g_main_tab(8).field_value,                  ---p_cycle_count_name     VARCHAR2 DEFAULT NULL,
      l_record_count,                             ---OUT NOCOPY   NUMBER,
      x_return_status,                            ---OUT NOCOPY   VARCHAR2,
      x_msg_data,                                 ---OUT NOCOPY   VARCHAR2,
      x_msg_count,                                ---OUT NOCOPY   NUMBER,
      fnd_api.to_boolean(g_main_tab(36).field_value),     ---p_query_independent_tasks   BOOLEAN DEFAULT TRUE,
      fnd_api.to_boolean(g_main_tab(58).field_value),     ---p_query_planned_tasks       BOOLEAN DEFAULT TRUE,
      fnd_api.to_boolean(g_main_tab(57).field_value),     ---p_is_pending_plan           BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(56).field_value),     ---p_is_inprogress_plan        BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(55).field_value),     ---p_is_completed_plan         BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(54).field_value),     ---p_is_cancelled_plan         BOOLEAN DEFAULT FALSE,
      fnd_api.to_boolean(g_main_tab(53).field_value),     ---p_is_aborted_plan           BOOLEAN DEFAULT FALSE,
      g_main_tab(46).field_value,                 ---p_activity_id   NUMBER DEFAULT NULL,
      g_main_tab(48).field_value,                 ---p_plan_type_id  NUMBER DEFAULT NULL,
      g_main_tab(47).field_value                  ---p_op_plan_id    NUMBER DEFAULT NULL
   );

    IF(l_debug = 1) THEN
      l_err_msg := 'Status returned by API wms_waveplan_tasks_pvt.query_tasks: '||x_return_status;
      inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
    END IF;

    IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
/*    SELECT * BULK COLLECT
      INTO   x_task_tab
      FROM   wms_waveplan_tasks_temp;*/
      --Replacing the above by selecting columns from the table.
      SELECT
	 TASK_ID,
	 TRANSACTION_TEMP_ID,
	 PARENT_LINE_ID,
	 INVENTORY_ITEM_ID,
	 ITEM,
	 ITEM_DESCRIPTION,
	 UNIT_WEIGHT,
	 WEIGHT_UOM_CODE,
	 DISPLAY_WEIGHT,
	 UNIT_VOLUME,
	 VOLUME_UOM_CODE,
	 DISPLAY_VOLUME,
	 TIME_ESTIMATE,
	 ORGANIZATION_ID,
	 ORGANIZATION_CODE,
	 REVISION,
	 SUBINVENTORY,
	 LOCATOR_ID,
	 LOCATOR,
	 TRANSACTION_TYPE_ID,
	 TRANSACTION_ACTION_ID,
	 TRANSACTION_SOURCE_TYPE_ID,
	 TRANSACTION_SOURCE_TYPE,
	 TRANSACTION_SOURCE_ID,
	 TRANSACTION_SOURCE_LINE_ID,
	 TO_ORGANIZATION_ID,
	 TO_ORGANIZATION_CODE,
	 TO_SUBINVENTORY,
	 TO_LOCATOR_ID,
	 TO_LOCATOR,
	 TRANSACTION_UOM,
	 TRANSACTION_QUANTITY,
	 USER_TASK_TYPE_ID,
	 USER_TASK_TYPE,
	 PERSON_ID,
	 PERSON_ID_ORIGINAL,
	 PERSON,
	 EFFECTIVE_START_DATE,
	 EFFECTIVE_END_DATE,
	 PERSON_RESOURCE_ID,
	 PERSON_RESOURCE_CODE,
	 MACHINE_RESOURCE_ID,
	 MACHINE_RESOURCE_CODE,
	 EQUIPMENT_INSTANCE,
	 STATUS_ID,
	 STATUS_ID_ORIGINAL,
	 STATUS,
	 CREATION_TIME,
	 DISPATCHED_TIME,
	 LOADED_TIME,
	 DROP_OFF_TIME,
	 MMTT_LAST_UPDATE_DATE,
	 MMTT_LAST_UPDATED_BY,
	 WDT_LAST_UPDATE_DATE,
	 WDT_LAST_UPDATED_BY,
	 PRIORITY,
	 PRIORITY_ORIGINAL,
	 TASK_TYPE_ID,
	 TASK_TYPE,
	 MOVE_ORDER_LINE_ID,
	 PICK_SLIP_NUMBER,
	 CARTONIZATION_ID,
	 ALLOCATED_LPN_ID,
	 CONTAINER_ITEM_ID,
	 CONTENT_LPN_ID,
	 TO_LPN_ID,
	 CONTAINER_ITEM ,
	 CARTONIZATION_LPN,
	 ALLOCATED_LPN ,
	 CONTENT_LPN,
	 TO_LPN,
	 REFERENCE ,
	 REFERENCE_ID,
	 CUSTOMER_ID,
	 CUSTOMER ,
	 SHIP_TO_LOCATION_ID ,
	 SHIP_TO_STATE ,
	 SHIP_TO_COUNTRY,
	 SHIP_TO_POSTAL_CODE,
	 DELIVERY_ID ,
	 DELIVERY ,
	 SHIP_METHOD ,
	 CARRIER_ID ,
	 CARRIER ,
	 SHIPMENT_DATE ,
	 SHIPMENT_PRIORITY,
	 WIP_ENTITY_TYPE,
	 WIP_ENTITY_ID,
	 ASSEMBLY_ID,
	 ASSEMBLY ,
	 LINE_ID,
	 LINE,
	 DEPARTMENT_ID,
	 DEPARTMENT,
	 SOURCE_HEADER,
	 LINE_NUMBER,
	 OPERATION_PLAN_ID,
	 OPERATION_PLAN ,
	 RESULT ,
	 ERROR ,
	 IS_MODIFIED ,
	 EXPANSION_CODE,
	 FROM_LPN ,
	 FROM_LPN_ID,
	 NUM_OF_CHILD_TASKS,
	 OPERATION_SEQUENCE,
	 OP_PLAN_INSTANCE_ID,
	 PLANS_TASKS ,
	 TRANSACTION_SET_ID,
	 PICKED_LPN_ID,
	 PICKED_LPN,
	 LOADED_LPN,
	 LOADED_LPN_ID,
	 DROP_LPN ,
	 SECONDARY_TRANSACTION_QUANTITY,
	 SECONDARY_TRANSACTION_UOM ,
	 PRIMARY_PRODUCT,
	 LOAD_SEQ_NUMBER
      BULK COLLECT
      INTO   x_task_tab
      FROM   wms_waveplan_tasks_temp;
    END IF;

  END IF; --- if l_execute_qry then

  ELSE
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WMS', 'WMS_INVALID_VALUE');
    fnd_msg_pub.ADD;
    fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
    inv_trx_util_pub.trace(l_api_name||': '||'Invalid Parameters Passed');
  END IF; ----if p_transaction_number is not null

  EXCEPTION
    WHEN l_invalid_org THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
      IF(l_debug = 1) THEN
        inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
      END IF;
      NULL;

    WHEN l_qry_fail THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
      IF(l_debug = 1) THEN
        inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
      END IF;
      NULL;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
      l_err_msg := substr(SQLERRM,1,1000);
      IF(l_debug = 1) THEN
        inv_trx_util_pub.trace(l_api_name||': '||l_err_msg);
      END IF;
      NULL;

  END query_task;
-------------------------------------------------------------------------------------------------------------------
--SPLIT TASK
/*This Public API will take care of splitting the task(only outboung)provided by the user.
  The criterion to split is only based on the quantity.

PROCEDURE split task (p_source_transaction_number IN           NUMBER DEFAULT NULL,
		        p_split_quantities          IN  	 WMS_TASKS_PUB.TASK_QUANTITY_TABLE,
		        p_commit                    IN           VARCHAR2  DEFAULT  G_FALSE,
		        x_resultant_tasks           OUT NOCOPY   WMS_TASKS_PUB.TASK_TABLE,
		        x_resultant_task_details    OUT NOCOPY   WMS_TASKS_PUB.TASK_DETAILS_TABLE,
		        x_return_status             OUT NOCOPY   VARCHAR2,
		        x_msg_count                 OUT NOCOPY   NUMBER,
		        x_msg_data                  OUT NOCOPY   VARCHAR2  );


Parameter			Description
p_transaction_number		This corrsponds to the task_id that user is trying to split.
P_split_quantities		This correspinds to the The PL/SQL table of quantities to be 	           splitted. This table will contain one or more entries with quantities to be splitted from the task.
P_Commit			This parameter decides whether to commit the changes or not.
X_resultant_tasks		PL/SQL table contains information about lot/serial allocation of the resultant tasks.
X_Resultant_task_details	PL/SQL table of type wms_query_tasks_pub.task_tab_type contains the details of the resultant tasks after the split.
X_return_status			This parameter gives the return status of split_task API. 	'S' = Success, 'U' = Unexpected Error, 'E' = Error.
X_msg_count			This gives the count of messages logged during the split task process.
X_msg_data			This gives the descrption of the messages that got logged during the split task process.
*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE split_task( p_source_transaction_number IN NUMBER DEFAULT NULL ,
		      p_split_quantities IN task_qty_tbl_type ,
		      p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE ,
		      x_resultant_tasks OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type ,
		      x_resultant_task_details OUT NOCOPY task_detail_tbl_type ,
		      x_return_status OUT NOCOPY VARCHAR2 ,
		      x_msg_count OUT NOCOPY NUMBER ,
		      x_msg_data OUT NOCOPY VARCHAR2 ) IS

        CURSOR mtlt_changed (p_ttemp_id IN NUMBER)
        IS
                SELECT  *
                FROM    mtl_transaction_lots_temp
                WHERE   transaction_temp_id = p_ttemp_id
                ORDER BY lot_number;

	--Bug 6766048
	CURSOR C_MMTT_ORG_ITM (p_txn_temp_id NUMBER)
	IS
		select inventory_item_id, organization_id
		from mtl_material_transactions_temp
		where transaction_temp_id = p_txn_temp_id;

	CURSOR C_LOT_DIVISIBLE (p_item_id NUMBER,p_organization_id NUMBER )
	IS
		select lot_divisible_flag
		from mtl_system_items
		where inventory_item_id = p_item_id
		and organization_id = p_organization_id;

	l_mtlt_row MTL_TRANSACTION_LOTS_TEMP%ROWTYPE;
        --      l_split_uom_quantities               qty_changed_tbl_type;
        l_procedure_name            VARCHAR2(30)    := 'SPLIT_TASK';
        l_task_tbl_qty_count        NUMBER          := p_split_quantities.COUNT;
        g_debug                     NUMBER          := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'),0);
        l_decimal_precision         CONSTANT NUMBER := 5;
        l_task_tbl_primary_qty      NUMBER;
        l_task_tbl_transaction_qty  NUMBER;
        l_sum_tbl_transaction_qty   NUMBER := 0;
        l_sum_tbl_primary_qty       NUMBER := 0;
        l_new_mol_id                NUMBER;
        l_orig_mol_id               NUMBER;
        l_new_transaction_temp_id   NUMBER;
        l_new_transaction_header_id NUMBER;
        l_new_task_id               NUMBER;
        l_remaining_primary_qty     NUMBER := 0;
        l_remaining_transaction_qty NUMBER := 0;
        l_mol_num                   NUMBER;
        l_serial_control_code       NUMBER;
        l_lot_control_code          NUMBER;
        l_index                     NUMBER;
        l_new_tasks_output WMS_TASK_MGMT_PUB.task_tab_type;
        l_new_tasks_tbl WMS_TASK_MGMT_PUB.task_tab_type;
        x_task_table WMS_TASK_MGMT_PUB.task_tab_type;
        l_return_status          VARCHAR2(10);
        l_msg_count              NUMBER;
        l_msg_data               VARCHAR(200);
        l_validation_status      VARCHAR2(10);
        l_error_msg              VARCHAR2(1000);
        l_task_return_status     VARCHAR2(10);
        l_mmtt_return_status     VARCHAR2(1);
        l_wdt_return_status      VARCHAR2(1);
        l_lot_ser_return_status  VARCHAR2(1);
        l_serial_return_status   VARCHAR2(1);
        l_mtlt_transaction_qty   NUMBER;
        l_msnt_transaction_qty   NUMBER;
        l_val_task_ret_status    VARCHAR2(1);
        l_mmtt_inventory_item_id NUMBER;
        l_mmtt_task_status       NUMBER;
        l_mmtt_organization_id   NUMBER;
        l_split_uom_quantities QTY_CHANGED_TBL_TYPE;
        l_val_qty_ret_status   VARCHAR2(1);
        l_invalid_task         EXCEPTION;
        l_invalid_quantities   EXCEPTION;
        l_unexpected_error     EXCEPTION;
        l_query_task_exception EXCEPTION;
	l_invalid_lot	       EXCEPTION;
	--Bug 6766048
	l_lot_divisible		    VARCHAR2(1);
	l_mmtt_itm_id		    NUMBER;
	l_mmtt_org_id		    NUMBER;

BEGIN
        g_debug   := 1;
        IF g_debug = 1 THEN
                print_msg(l_procedure_name,  'In Split Task ');
        END IF;
        x_return_status := 'S';
        new_task_table.delete;
        validate_task( p_transaction_temp_id => p_source_transaction_number ,
		       x_return_status => x_return_status ,
		       x_error_msg => l_error_msg ,
		       x_msg_data => x_msg_data ,
		       x_msg_count => x_msg_count );
        IF g_debug                           = 1 THEN
                print_msg(l_procedure_name,  ' Validate task return status : '|| x_return_status);
        END IF;
        IF NVL(x_return_status,'E') <> 'S' THEN
                RAISE l_invalid_task;
        END IF;
        validate_quantities( p_transaction_temp_id => p_source_transaction_number ,
			     p_split_quantities => p_split_quantities ,
			     x_lot_control_code => l_lot_control_code ,
			     x_serial_control_code => l_serial_control_code ,
			     x_split_uom_quantities => l_split_uom_quantities ,
			     x_return_status => x_return_status ,
			     x_msg_data => x_msg_data ,
			     x_msg_count => x_msg_count );

        IF NVL(x_return_status,'E')               <> 'S' THEN
                RAISE l_invalid_quantities;
        END IF;
	--Bug 6766048:Check if the lot item is divisble or not.If not, log error and exit.
	IF (l_lot_control_code = 2) THEN
		OPEN C_MMTT_ORG_ITM(p_source_transaction_number);
		FETCH C_MMTT_ORG_ITM into l_mmtt_itm_id,l_mmtt_org_id;
		CLOSE C_MMTT_ORG_ITM;

		OPEN C_LOT_DIVISIBLE(l_mmtt_itm_id,l_mmtt_org_id);
		FETCH C_LOT_DIVISIBLE into l_lot_divisible;
		CLOSE C_LOT_DIVISIBLE;

		IF (l_lot_divisible =  'N') THEN
			RAISE l_invalid_lot;
		END IF;
	END IF;

        IF g_debug     = 1 THEN
                FOR i in l_split_uom_quantities.FIRST .. l_split_uom_quantities.LAST
                LOOP
                        print_msg(l_procedure_name, ' l_split_uom_quantities('||i|| ').primary_quantity: '||l_split_uom_quantities(i).primary_quantity);
                        print_msg(l_procedure_name, ' l_split_uom_quantities('||i|| ').transaction_quantity: '||l_split_uom_quantities(i).transaction_quantity);
                END LOOP;
        END IF;
        SAVEPOINT wms_split_task;
        IF g_debug = 1 THEN
                print_msg(l_procedure_name, ' SAVEPOINT wms_split_task established');
        END IF;
        FOR i IN l_split_uom_quantities.FIRST .. l_split_uom_quantities.LAST
        LOOP
                SELECT  mtl_material_transactions_s.NEXTVAL
                INTO    l_new_transaction_header_id
                FROM    dual;
                SELECT  mtl_material_transactions_s.NEXTVAL
                INTO    l_new_transaction_temp_id
                FROM    dual;
                SELECT wms_dispatched_tasks_s.NEXTVAL INTO l_new_task_id FROM dual;
                IF g_debug = 1 THEN
                        print_msg(l_procedure_name,  ' Calling split_mmtt for Txn. temp id : '||p_source_transaction_number);
                END IF;
                split_mmtt( p_orig_transaction_temp_id => p_source_transaction_number ,
			    p_new_transaction_temp_id => l_new_transaction_temp_id ,
			    p_new_transaction_header_id => l_new_transaction_header_id ,
			    p_new_mol_id => l_orig_mol_id ,
			    p_transaction_qty_to_split => l_split_uom_quantities(i).transaction_quantity ,
			    p_primary_qty_to_split => l_split_uom_quantities(i).primary_quantity ,
			    x_return_status => x_return_status ,
			    x_msg_data => x_msg_data ,
			    x_msg_count => x_msg_count );

                IF g_debug                             = 1 THEN
                        print_msg(l_procedure_name,  ' x_return_status : ' || x_return_status);
                END IF;
                IF NVL(x_return_status, 'E') <> 'S' THEN
                        IF g_debug            = 1 THEN
                                print_msg(l_procedure_name, ' Unable to split MMTT, unexpected error has occurred');
                        END IF;
                        RAISE l_unexpected_error;
                END IF;
                BEGIN
                        SELECT  status
                        INTO    l_mmtt_task_status
                        FROM    wms_dispatched_tasks
                        WHERE   transaction_temp_id = p_source_transaction_number;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        l_mmtt_task_status := -9999;
                        NULL;
                END;
                IF g_debug = 1 THEN
                        print_msg(l_procedure_name,   'l_mmtt_task_status :  '|| l_mmtt_task_status);
                END IF;
                IF l_mmtt_task_status            = 2 THEN
                        split_wdt( p_new_task_id => l_new_task_id ,
			p_new_transaction_temp_id => l_new_transaction_temp_id ,
			p_new_mol_id => l_orig_mol_id ,
			p_orig_transaction_temp_id => p_source_transaction_number ,
			x_return_status => x_return_status ,
			x_msg_data => x_msg_data ,
			x_msg_count => x_msg_count );

                        IF g_debug               = 1 THEN
                                print_msg(l_procedure_name,  ' x_return_status : '||x_return_status);
                        END IF;
                        IF NVL(x_return_status, 'E') <> 'S' THEN
                                IF g_debug            = 1 THEN
                                        print_msg(l_procedure_name, ' Unable to split WDT, unexpected error has occurred');
                                END IF;
                                RAISE l_unexpected_error;
                        END IF;
                END IF;
                IF (l_lot_control_code = 2 AND l_serial_control_code IN (2,5)) OR (l_lot_control_code = 2 AND l_serial_control_code NOT IN (2,5)) THEN
                        split_lot_serial( p_source_transaction_number ,
					  l_new_transaction_temp_id ,
					  l_split_uom_quantities(i).transaction_quantity ,
					  l_split_uom_quantities(i).primary_quantity ,
					  l_mmtt_inventory_item_id ,
					  l_mmtt_organization_id ,
					  x_return_status ,
					  x_msg_data ,
					  x_msg_count );

                        IF g_debug = 1 THEN
                                print_msg(l_procedure_name,  ' x_return_status : ' || x_return_status);
                        END IF;
                        IF NVL(x_return_status, 'E') <> 'S' THEN
                                IF g_debug            = 1 THEN
                                        print_msg(l_procedure_name, ' Was not able to split lot serial');
                                END IF;
                                RAISE l_unexpected_error;
                        END IF;
                ELSIF l_lot_control_code                         = 1 AND l_serial_control_code IN (2,5) THEN
                        split_serial( p_orig_transaction_temp_id => p_source_transaction_number ,
				      p_new_transaction_temp_id => l_new_transaction_temp_id ,
				      p_transaction_qty_to_split => l_split_uom_quantities(i).transaction_quantity ,
				      p_primary_qty_to_split => l_split_uom_quantities(i).primary_quantity ,
				      p_inventory_item_id => l_mmtt_inventory_item_id ,
				      p_organization_id => l_mmtt_organization_id ,
				      x_return_status => x_return_status ,
				      x_msg_data => x_msg_data ,
				      x_msg_count => x_msg_count );
                        IF g_debug                               = 1 THEN
                                print_msg(l_procedure_name,  ' x_return_status : '||x_return_status);
                        END IF;
                        IF NVL(x_return_status, 'E') <> 'S' THEN
                                IF g_debug            = 1 THEN
                                        print_msg(l_procedure_name, ' Was not able to split serials');
                                END IF;
                                RAISE l_unexpected_error;
                        END IF;
                END IF;
                -- Update the original row
                BEGIN
                        UPDATE mtl_material_transactions_temp
                        SET     primary_quantity     = primary_quantity     - l_split_uom_quantities(i).primary_quantity     ,
                                transaction_quantity = transaction_quantity - l_split_uom_quantities(i).transaction_quantity ,
                                last_updated_by      = FND_GLOBAL.USER_ID
                        WHERE   transaction_temp_id  = p_source_transaction_number;
                EXCEPTION
                WHEN OTHERS THEN
                        IF g_debug = 1 THEN
                                print_msg(l_procedure_name,  ' Error Code : '|| SQLCODE || ' Error Message :'||SUBSTR(SQLERRM,1,100));
                        END IF;
                        RAISE l_unexpected_error;
                END;
                IF g_debug = 1 THEN
                        print_msg(l_procedure_name, ' Updated original txn. temp id :'||p_source_transaction_number);
                END IF;
                l_index                                     := new_task_table.count + 1;
                new_task_table(l_index).transaction_temp_id := l_new_transaction_temp_id;
        END LOOP;
        l_index                                     := new_task_table.count + 1;
        new_task_table(l_index).transaction_temp_id := p_source_transaction_number;
        IF g_debug                                   = 1 THEN
                print_msg(l_procedure_name, ' Split done sucessfully for txn. temp id :'||p_source_transaction_number);
        END IF;
        IF g_debug = 1 THEN
                print_msg(l_procedure_name, ' lot control code :'||l_lot_control_code ||  ' serial control code : '|| l_serial_control_code);
        END IF;
        IF g_debug = 1 THEN
                print_msg(l_procedure_name, '***********New Task Table***********');
                print_msg(l_procedure_name, '*** Transaction temp id ***');
                FOR i IN new_task_table.FIRST .. new_task_table.LAST
                LOOP
                        print_msg(l_procedure_name,   '   '|| new_task_table(i).transaction_temp_id);
                END LOOP;
        END IF;
        IF g_debug = 1 THEN
                print_msg(l_procedure_name, 'Inserting Lot/Serial details of the new tasks in X_RESULTANT_TASK_DETAILS');
        END IF;
        IF l_lot_control_code = 2 THEN
                FOR i        IN new_task_table.FIRST .. new_task_table.LAST
                LOOP
                        OPEN mtlt_changed(new_task_table(i).transaction_temp_id);
                        LOOP
                                FETCH mtlt_changed INTO l_mtlt_row;
                                EXIT
                        WHEN mtlt_changed%NOTFOUND;
                                l_index                                                    := x_resultant_task_details.count + 1;
                                x_resultant_task_details(l_index).parent_task_id           := l_mtlt_row.transaction_temp_id;
                                x_resultant_task_details(l_index).lot_number               := l_mtlt_row.lot_number;
                                x_resultant_task_details(l_index).lot_expiration_date      := l_mtlt_row.lot_expiration_date;
                                x_resultant_task_details(l_index).lot_primary_quantity     := l_mtlt_row.primary_quantity;
                                x_resultant_task_details(l_index).lot_transaction_quantity := l_mtlt_row.transaction_quantity;
                                IF l_mtlt_row.serial_transaction_temp_id IS NOT NULL THEN
                                        x_resultant_task_details(l_index).number_of_serials := l_mtlt_row.primary_quantity;
                                        SELECT  MIN(FM_SERIAL_NUMBER) ,
                                                MAX(FM_SERIAL_NUMBER) ,
                                                MAX(status_id)
                                        INTO    x_resultant_task_details(l_index).from_serial_number ,
                                                x_resultant_task_details(l_index).to_serial_number   ,
                                                x_resultant_task_details(l_index).serial_status_id
                                        FROM    mtl_serial_numbers_temp
                                        WHERE   transaction_temp_id = l_mtlt_row.serial_transaction_temp_id;
                                END IF;
                        END LOOP;
                        CLOSE mtlt_changed;
                END LOOP;
        ELSIF l_serial_control_code IN (2,5) THEN
                FOR i               IN new_task_table.FIRST .. new_task_table.LAST
                LOOP
                        l_index                                          := x_resultant_task_details.count + 1;
                        x_resultant_task_details(l_index).parent_task_id := new_task_table(i).transaction_temp_id;
                        SELECT  MIN(FM_SERIAL_NUMBER) ,
                                MAX(FM_SERIAL_NUMBER) ,
                                MAX(status_id)        ,
                                COUNT(*)
                        INTO    x_resultant_task_details(l_index).from_serial_number ,
                                x_resultant_task_details(l_index).to_serial_number   ,
                                x_resultant_task_details(l_index).serial_status_id   ,
                                x_resultant_task_details(l_index).number_of_serials
                        FROM    mtl_serial_numbers_temp
                        WHERE   transaction_temp_id = new_task_table(i).transaction_temp_id;
                END LOOP;
        END IF;
        IF g_debug                                = 1 THEN
                IF x_resultant_task_details.COUNT > 0 THEN
                        print_msg(l_procedure_name, 'Task Id    Lot    quantity  fm_serial   to_serial   num_of_serials');
                        FOR i IN x_resultant_task_details.FIRST .. x_resultant_task_details.LAST
                        LOOP
                                print_msg(l_procedure_name,
					  x_resultant_task_details(i).parent_task_id ||
					  '      '||
					  x_resultant_task_details(i).lot_number ||
					  '      '||
					  x_resultant_task_details(i).lot_primary_quantity||
					  '      '||
					  x_resultant_task_details(i).from_serial_number||
					  '      '||
					  x_resultant_task_details(i).to_serial_number||
					  '      '||
					  x_resultant_task_details(i).number_of_serials);
                        END LOOP;
                ELSE
                        print_msg(l_procedure_name,'Table x_resultant_task_details is empty, item is not serial or lot controlled');
                END IF;
        END IF;
        FOR i IN new_task_table.FIRST .. new_task_table.LAST
        LOOP
                IF g_debug = 1 THEN
                        print_msg(l_procedure_name, 'Before calling WMS_TASK_MGMT_PUB.query_task');
                        WMS_TASK_MGMT_PUB.query_task ( new_task_table(i).transaction_temp_id ,
						       NULL ,
						       l_new_tasks_tbl ,
						       l_return_status ,
						       l_msg_count ,
						       l_msg_data );

                        IF NVL(l_return_status,'N') = 'S' OR l_new_tasks_tbl.COUNT > 0 THEN
                                IF g_debug          = 1 THEN
                                        print_msg(l_procedure_name,  'WMS_TASK_MGMT_PUB.query_task returned success for task : ' || new_task_table(i).transaction_temp_id);
                                END IF;
                                IF l_new_tasks_tbl.COUNT      > 0 THEN
                                        x_resultant_tasks(i) := l_new_tasks_tbl(1);
                                END IF;
                        ELSE
                                IF g_debug = 1 THEN
                                        print_msg(l_procedure_name, 'WMS_TASK_MGMT_PUB.query_task returned error');
                                END IF;
--                               x_return_status := 'E';
                                RAISE l_query_task_exception;
                        END IF;
                END IF;
        END LOOP;
        IF g_debug                         = 1 THEN
                IF x_resultant_tasks.COUNT > 0 THEN
                        print_msg(l_procedure_name, 'Task Id   item_id  sub   locator   Qty');
                        FOR i IN x_resultant_tasks.FIRST .. x_resultant_tasks.LAST
                        LOOP
                                print_msg(l_procedure_name,
					  x_resultant_tasks(i).task_id ||
					  '     '||
					  x_resultant_tasks(i).inventory_item_id||
					  '     '||
					  x_resultant_tasks(i).subinventory||
					  '     '||
					  x_resultant_tasks(i).locator||
					  '     '||
					  x_resultant_tasks(i).transaction_quantity);
                        END LOOP;
                ELSE
                        print_msg(l_procedure_name, 'Table x_resultant_tasks is empty');
                END IF;
        END IF;
        IF p_commit        = FND_API.G_TRUE THEN
                IF g_debug = 1 THEN
                        print_msg(l_procedure_name, ' p_commit is TRUE, so COMMITING the transactions.');
                END IF;
                COMMIT;
        ELSE
                IF g_debug = 1 THEN
                        print_msg(l_procedure_name, ' p_commit is FALSE, so not COMMITING the transactions.');
                END IF;
        END IF;
        x_return_status := 'S';
EXCEPTION
WHEN L_INVALID_TASK THEN
        IF g_debug = 1 THEN
                print_msg(l_procedure_name,'EXCEPTION BLOCK  : Validate task returned error');
        END IF;
        x_return_status := 'S';
        WMS_TASK_MGMT_PUB.query_task ( p_source_transaction_number ,
				       NULL ,
				       l_new_tasks_tbl ,
				       l_return_status ,
				       l_msg_count ,
				       l_msg_data );
        fnd_message.set_name('WMS', 'WMS_INVALID_TASK');
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

        IF l_new_tasks_tbl.COUNT      > 0 THEN
                x_resultant_tasks(1)        := l_new_tasks_tbl(1);
                x_resultant_tasks(1).RESULT := 'E';
--              x_resultant_tasks(1).ERROR  := 'Invalid Task';
--		anjana
                x_resultant_tasks(1).ERROR  := x_msg_data;

        END IF;
--Bug 6766048
WHEN L_INVALID_LOT THEN
        IF g_debug = 1 THEN
                print_msg(l_procedure_name,'EXCEPTION BLOCK  : Lot split error');
        END IF;
        x_return_status := 'S';
        WMS_TASK_MGMT_PUB.query_task ( p_source_transaction_number ,
				       NULL ,
				       l_new_tasks_tbl ,
				       l_return_status ,
				       l_msg_count ,
				       l_msg_data );
        fnd_message.set_name('INV', 'INV_LOT_INDIVISIBLE');
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

        IF l_new_tasks_tbl.COUNT      > 0 THEN
                x_resultant_tasks(1)        := l_new_tasks_tbl(1);
                x_resultant_tasks(1).RESULT := 'E';
	        x_resultant_tasks(1).ERROR  := x_msg_data;
        END IF;

WHEN L_INVALID_QUANTITIES THEN
        IF g_debug = 1 THEN
                print_msg(l_procedure_name,'EXCEPTION BLOCK  : Validate quantities returned error');
        END IF;
        x_return_status := 'S';
        WMS_TASK_MGMT_PUB.query_task ( p_source_transaction_number ,
				       NULL ,
				       l_new_tasks_tbl ,
				       l_return_status ,
				       l_msg_count ,
				       l_msg_data );
        fnd_message.set_name('WMS', 'WMS_INVALID_SPLIT_QUANTITY');
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

        IF l_new_tasks_tbl.COUNT      > 0 THEN
                x_resultant_tasks(1)        := l_new_tasks_tbl(1);
                x_resultant_tasks(1).RESULT := 'E';
--              x_resultant_tasks(1).ERROR  := 'Invalid Quantities';
--		anjana
                x_resultant_tasks(1).ERROR  := x_msg_data;
        END IF;

WHEN L_QUERY_TASK_EXCEPTION THEN
        IF g_debug = 1 THEN
                print_msg(l_procedure_name,'EXCEPTION BLOCK  : Query task returned error, ROLLING BACK THE TRANSACTIONS');
        END IF;
        x_return_status := 'S';
        ROLLBACK TO wms_split_task;
        WMS_TASK_MGMT_PUB.query_task ( p_source_transaction_number ,
	                               NULL ,
				       l_new_tasks_tbl ,
				       l_return_status ,
				       l_msg_count ,
				       l_msg_data );
        fnd_message.set_name('WMS', 'WMS_QUERY_ELIG_MATRL');
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

        IF l_new_tasks_tbl.COUNT      > 0 THEN
                x_resultant_tasks(1)        := l_new_tasks_tbl(1);
                x_resultant_tasks(1).RESULT := 'E';
--              x_resultant_tasks(1).ERROR  := 'Query Task returned error or no rows';
--		anjana
                x_resultant_tasks(1).ERROR  := x_msg_data;
        END IF;

WHEN L_UNEXPECTED_ERROR THEN
        IF g_debug = 1 THEN
                print_msg(l_procedure_name,'EXCEPTION BLOCK  : Unexpected error has occured, ROLLING BACK THE TRANSACTIONS');
        END IF;
        x_return_status := 'E';
        ROLLBACK TO wms_split_task;
        fnd_message.set_name('WMS', 'WMS_UNEXPECTED_ERROR');
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
WHEN OTHERS THEN
        IF g_debug = 1 THEN
                print_msg(l_procedure_name,'EXCEPTION BLOCK  : Unexpected error has occured, ROLLING BACK THE TRANSACTIONS');
        END IF;
        x_return_status := 'E';
        ROLLBACK TO wms_split_task;
        fnd_message.set_name('WMS', 'WMS_UNEXPECTED_ERROR');
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
        x_return_status                  := 'E';
        IF g_debug                        = 1 THEN
                print_msg(l_procedure_name,  'EXCEPTION BLOCK  :  Error Code : '|| SQLCODE || 'EXCEPTION BLOCK  :  Error Message :'||SQLERRM);
        END IF;
END split_task;

-------------------------------------------------------------------------------------------------------------------
--MODIFY TASK
/*This Public API takes care of modifying the following attributes of a task or set of tasks:
1.Task Status
2.Task Priority
3.Operation Plan
4.Cartonization LPN
5.Task Type

PROCEDURE modify_task (p_transaction_number     IN              NUMBER DEFAULT NULL
		  , p_task_table                IN              WMS_TASKS_PUB.TASK_TABLE
		  , p_new_task_status     	IN              NUMBER DEFAULT NULL
		  , p_new_task_priority   	IN              NUMBER DEFAULT NULL
		  , p_new_task_type         	IN              VARCHAR2 DEFAULT NULL
		  , p_new_carton_lpn_id   	IN              NUMBER DEFAULT NULL
		  , p_new_operation_plan_id   	IN              NUMBER DEFAILUT NULL
		  , p_person_id			IN		NUMBER DEFAULT  NULL
		  , p_commit                    IN              VARCHAR2  DEFAULT  G_FALSE
		  , x_updated_tasks         	OUT 	NOCOPY  WMS_TASKS_PUB.TASK_TABLE
		  , x_return_status           	OUT 	NOCOPY  VARCHAR2
		  , x_msg_count              	OUT 	NOCOPY  NUMBER
		  , x_msg_data                 	OUT 	NOCOPY  VARCHAR2 );

Parameter		Description

p_transaction_number	This corresponds to the task_id that user is trying to update
P_task_table		This corresponds to the set of tasks that user is trying to update
P_new_task_status	This corresponds to the new status to which user wants to update the task/set of tasks
P_new_task_priority	This corresponds to new task priority which user wants to assign to the tasks/set of tasks.
P_new_task_tyoe		This corresponds to the new task type which user wants to update on the task/set of tasks.
P_new_carton_lpn_id	This is the carton_lpn_id which user wants to update on task/set of tasks.
P_new_operation_plan_id	This is the new operation plan id which user wants to update on task/set of tasks.
P_person_id		This the user to which task will be queued, if the task status is getting changed to 'Queued' state.
P_Commit		This parameter decides whether to commit the changes or not.
X_updated_tasks		This is a table of records, which contain the updated tasks. If the tasks could not be updated, the Result column in the table is updated with 'E' and the Error column is updated with the error message
X_return_status		This parameter gives the return status of Modify_task API.	'S' = Success, 'U' = Unexpected Error, 'E' = Error.
X_msg_count		This gives the count of messages logged during the task updation process.
X_msg_data		This gives the description of the messages that got logged during the task updation process.

*/
-------------------------------------------------------------------------------------------------------------------
PROCEDURE modify_task ( p_transaction_number IN NUMBER DEFAULT NULL ,
			p_task_table IN WMS_TASK_MGMT_PUB.task_tab_type ,
			p_new_task_status IN NUMBER DEFAULT NULL ,
			p_new_task_priority IN NUMBER DEFAULT NULL ,
			p_new_task_type IN VARCHAR2 DEFAULT NULL ,
			p_new_carton_lpn_id IN NUMBER DEFAULT NULL ,
			p_new_operation_plan_id IN NUMBER DEFAULT NULL ,
			p_person_id IN NUMBER DEFAULT NULL ,
			p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE ,
			x_updated_tasks OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type ,
			x_return_status OUT NOCOPY VARCHAR2 ,
			x_msg_count OUT NOCOPY NUMBER ,
			x_msg_data OUT NOCOPY VARCHAR2 ) IS

        temp_task_tab WMS_TASK_MGMT_PUB.task_tab_type;
        CURSOR op_plan_cur(c_op_plan_id NUMBER)
        IS
                SELECT  system_task_type ,
                        organization_id  ,
                        enabled_flag     ,
                        activity_type_id ,
                        common_to_all_org,
                        plan_type_id
                FROM    wms_op_plans_b
                WHERE   operation_plan_id=c_op_plan_id;
        --Cursor to lock the mmtt record before updation.
        Cursor c_lock_mmtt (p_transaction_number NUMBER)
        IS
                SELECT '1'
                FROM    mtl_material_transactions_temp
                WHERE   transaction_temp_id = p_transaction_number FOR UPDATE NOWAIT;
        --Cursor to lock the mcce record before updation.
        Cursor c_lock_mcce (p_transaction_number NUMBER)
        IS
                SELECT '1'
                FROM    mtl_cycle_count_entries
                WHERE   cycle_count_entry_id = p_transaction_number FOR UPDATE NOWAIT;
        p_return_sts         VARCHAR2(30);
        P_msg_count          NUMBER;
        l_msg_count          NUMBER;
        P_msg_data           VARCHAR2(30);
        l_valid_task_counter NUMBER;
        p_temp_task_rec WMS_TASK_MGMT_PUB.task_output_rectype;
        l_op_plan_rec WMS_TASK_MGMT_PUB.op_plan_rec;
        l_debug     NUMBER         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
        l_api_name  VARCHAR2(1000) := 'MODIFY_TASK';
        l_msg       VARCHAR2(2000);
        l_err_msg   VARCHAR2(2000);
        l_error_msg VARCHAR2(2000);
        l_lock      VARCHAR2(2);
        l_updated_tasks WMS_TASK_MGMT_PUB.task_tab_type;


	TYPE TransactionNumber IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE OrganizationId IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE  UserTaskTypeId IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE PersonId IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE PersonResourceId IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE MachineResourceId IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE StatusId IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE Priority IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE TaskTypeId IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE MoveOrderLineId IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE ToLpnId IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE OperationPlanId IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE CartonizationId IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
	TYPE DispatchedTime is TABLE OF DATE;

	l_transaction_num_table TransactionNumber;
	l_organization_id_table OrganizationId;
	l_usertask_type_id_table UserTaskTypeId;
	l_person_id_tabke PersonId;
	l_person_resource_id_tabe PersonResourceId;
	l_machine_resource_id_table MachineResourceId;
	l_status_id_table  StatusId;
	l_priority_table Priority;
	l_task_type_id_table TaskTypeId;
	l_move_order_line_id_table MoveOrderLineId;
	l_to_lpn_id_table ToLpnId;
	l_operation_plan_id_table OperationPlanId;
	l_dispatched_time_table DispatchedTime;

	l_mmtt_cartonization_id_table CartonizationId;
	l_mmtt_transaction_num_table TransactionNumber;
	l_mmtt_usertask_type_id_table UserTaskTypeId;
	l_mmtt_status_id_table  StatusId;
	l_mmtt_priority_table Priority;
	l_mmtt_operation_plan_id_table OperationPlanId;

	l_mcce_transaction_num_table TransactionNumber;
	l_mcce_usertask_type_id_table UserTaskTypeId;
	l_mcce_priority_table Priority;

	l_wdt_transaction_num_table TransactionNumber;
	l_wdt_usertask_type_id_table UserTaskTypeId;
	l_wdt_status_id_table  StatusId;
	l_wdt_priority_table Priority;
	l_wdt_operation_plan_id_table OperationPlanId;

	l_wdt_del_trns_num_table TransactionNumber;
	l_action VARCHAR2(20) := 'MODIFY'; --	6850212


BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
	--anjana
	x_msg_count := 0;
        --1.Tasks status can be updated only to to Pending or queued or unreleased state.
        IF (p_new_task_status IS NOT NULL) THEN
                IF(p_new_task_status NOT IN (1,2,8)) THEN
                        --6850212:Return status should not be set to error.
                        --x_return_status  := fnd_api.g_ret_sts_error;
                        fnd_message.set_name('WMS', 'WMS_INVALID_TASK_STATUS');--new message
                        fnd_msg_pub.ADD;
                        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_msg );
			x_msg_data := l_msg;
			x_msg_count := l_msg_count;
                        l_err_msg                        :='New task status not in Pending or Queued state or Unreleased state';
                        IF(l_debug                        = 1) THEN
                                inv_trx_util_pub.trace(l_api_name|| ': '||l_err_msg);
                        END IF;
                        log_error(p_transaction_number => p_transaction_number, p_task_table => p_task_table, p_error_msg => l_msg, x_updated_tasks => x_updated_tasks);
                        RETURN;
                END IF;
        END IF;
        --2.If operation Plan is send, then check if it is enabled in the org or not.
        IF (p_new_operation_plan_id IS NOT NULL) THEN
                OPEN op_plan_cur(p_new_operation_plan_id);
                FETCH   op_plan_cur
                INTO    l_op_plan_rec.system_task_type ,
                        l_op_plan_rec.organization_id  ,
                        l_op_plan_rec.eabled_flag      ,
                        l_op_plan_rec.activity_type_id ,
                        l_op_plan_rec.common_to_all_org,
                        l_op_plan_rec.plan_type_id;
                IF (l_op_plan_rec.eabled_flag <> 'Y') THEN--op_plan passed is not enabled
                        --6850212:Return status should not be set to error.
                        --x_return_status       := fnd_api.g_ret_sts_error;
                        fnd_message.set_name('WMS', 'WMS_OPERTN_PLAN_ID_INVALID');--new message
                        fnd_msg_pub.ADD;
                        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_msg );
			x_msg_data := l_msg;
			x_msg_count := l_msg_count;
                        l_err_msg                        :='Operation Plan is not enabled';
                        IF(l_debug                        = 1) THEN
                                inv_trx_util_pub.trace(l_api_name|| ': '||l_err_msg);
                        END IF;
                        log_error(p_transaction_number => p_transaction_number,
				  p_task_table => p_task_table,
				  p_error_msg => l_msg,
				  x_updated_tasks => x_updated_tasks);
                        RETURN;
                END IF;
                CLOSE op_plan_cur;
        END IF;
        --3.Perform Validation,Query,Check cartonization on taks/tasks.
        --  If transaction_number and task_table are both passed, honour transaction_number.
        --Call Validate task API
	validate_tasks(p_transaction_number => p_transaction_number,
		       p_task_table => p_task_table,
			p_action     => l_action,  --6850212
		       x_wms_task => l_updated_tasks,
		       x_return_status => p_return_sts);

	IF (p_return_sts                    = fnd_api.g_ret_sts_success) THEN
		l_valid_task_counter       := l_updated_tasks.count;
		FOR i                      IN 1..l_updated_tasks.count
		LOOP--Loop starts
			IF (nvl(l_updated_tasks(i).RESULT,'X')<> 'E') THEN
				temp_task_tab.delete;-- := NULL; --flush the temporary table
				WMS_TASK_MGMT_PUB.query_task( p_transaction_number => l_updated_tasks(i).transaction_number,
							      p_query_name => NULL,
							      x_task_tab => temp_task_tab,
							      x_return_status => p_return_sts,
							      x_msg_count => p_msg_count,
							      x_msg_data => p_msg_data);

				--if quey was not successfull then populate output table with passed values with error
				IF ((p_return_sts <> fnd_api.g_ret_sts_success) OR ( temp_task_tab.count = 0)) THEN
					fnd_message.set_name('WMS', 'WMS_QUERY_ELIG_MATRL');--new message
--					fnd_msg_pub.ADD;
--					fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_msg);
					--anjana
					l_msg := fnd_message.get;
					x_msg_data := x_msg_data || l_msg;
					x_msg_count := x_msg_count + 1;

					l_err_msg                        :='Error in querying task from Query_task API for transaction_number :'||p_task_table(i).transaction_number ||'This task will be skipped';
					IF(l_debug                        = 1) THEN
						inv_trx_util_pub.trace(l_api_name|| ': '||l_err_msg);
					END IF;
					x_updated_tasks(i)        := l_updated_tasks(i);
					x_updated_tasks(i).RESULT := 'E';
					x_updated_tasks(i).ERROR  := l_msg;
					l_valid_task_counter      := l_valid_task_counter - 1;
				ELSE                                           --if query success
					x_updated_tasks(i) := temp_task_tab(1);--assigning the queried results to output table
				END IF;
			ELSE
				fnd_message.set_name('WMS', 'WMS_INVALID_TASK');
--				fnd_msg_pub.ADD;
--				fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_msg );
				--anjana
				l_msg := fnd_message.get;
				x_msg_data := x_msg_data || l_msg;
				x_msg_count := x_msg_count + 1;

				x_updated_tasks(i)               := l_updated_tasks(i);
				x_updated_tasks(i).RESULT        := 'E';
				x_updated_tasks(i).ERROR         := l_msg;
				l_valid_task_counter             := l_valid_task_counter - 1;
			END IF;
		END LOOP;--Loop ends
	ELSE
		x_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_message.set_name('WMS', 'WMS_UNEXPECTED_ERROR');
		fnd_msg_pub.ADD;
		fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_msg );
		x_msg_data := l_msg;
		x_msg_count := l_msg_count;
		--      l_err_msg :='Task Validation Failed';
		IF(l_debug = 1) THEN
			inv_trx_util_pub.trace(l_api_name|| ': '||l_msg);
		END IF;
		RETURN;
	END IF;
	IF (l_valid_task_counter <=0 ) THEN
		--all the tasks are invalid.Dont proceed
		--6850212:Return status should not be set to error.
		--x_return_status := fnd_api.g_ret_sts_error;
		RETURN;
	END IF;
	--Cartonization needs to be done only if all the tasks passed are valid and the task is an outboud task(SO/WIP)
	IF (p_new_carton_lpn_id IS NOT NULL) THEN
		IF (l_updated_tasks.count = l_valid_task_counter)THEN
			FOR i         in 1..l_updated_tasks.count
			LOOP
				IF ((l_updated_tasks(1).task_type_id <> 1) OR (l_updated_tasks(i).task_type_id <> l_updated_tasks(1).task_type_id )) THEN
					fnd_message.set_name('WMS', 'WMS_CARTONIZATION_ERROR');--new message
					fnd_msg_pub.ADD;
					fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => l_msg_count, p_data => l_msg );
					l_err_msg                        :='Cartonization can be done only on Outbound tasks(Sales order/WIP)';
					x_msg_data := l_msg;
					x_msg_count := l_msg_count;
					log_error(p_transaction_number    => p_transaction_number,
						  p_task_table => l_updated_tasks,
						  p_error_msg => l_msg,
						  x_updated_tasks => x_updated_tasks);
					RETURN;
				END IF;
			END LOOP;
			check_cartonization(p_task_table => l_updated_tasks,
					    p_new_carton_lpn_id => p_new_carton_lpn_id,
					    x_error_msg => l_error_msg,
					    x_return_status => p_return_sts);

			IF (p_return_sts                <> fnd_api.g_ret_sts_success) THEN
				x_return_status         := fnd_api.g_ret_sts_error;
				fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data );
				FOR i                   IN 1..l_updated_tasks.count
				LOOP
					x_updated_tasks(i).RESULT := 'E';
					x_updated_tasks(i).ERROR  := l_error_msg;
				END LOOP;
				IF(l_debug = 1) THEN
					inv_trx_util_pub.trace(l_api_name|| ': '||l_error_msg);
				END IF;
				RETURN;
			END IF;
		ELSE
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_message.set_name('WMS', 'WMS_CARTONIZATION_ERROR');--new message
			fnd_msg_pub.ADD;
			fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data );
			l_err_msg                        := 'Some tasks have failed validation,cartonization cannot be done';
			IF(l_debug                        = 1) THEN
				inv_trx_util_pub.trace(l_api_name|| ': '||l_err_msg);
			END IF;
			RETURN;
		END IF;
	END IF;
	FOR i in 1..x_updated_tasks.count
	LOOP
		IF (nvl(x_updated_tasks(i).RESULT,'X')<> 'E') THEN
			--Lock the mmtt/mcee record
			BEGIN
				IF (x_updated_tasks(i).task_type_id <> 3) THEN
					OPEN c_lock_mmtt(x_updated_tasks(i).transaction_number);
					FETCH c_lock_mmtt INTO l_lock;
					CLOSE c_lock_mmtt;
				ELSE
					OPEN c_lock_mcce(x_updated_tasks(i).transaction_number);
					FETCH c_lock_mcce INTO l_lock;
					CLOSE c_lock_mcce;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				l_err_msg                 := substr(SQLERRM,1,1000);
				x_updated_tasks(i).RESULT := 'E';
				x_updated_tasks(i).ERROR  := l_err_msg;
				IF(l_debug                 = 1) THEN
					inv_trx_util_pub.trace(l_api_name|| ': '||l_err_msg);
				END IF;
			END;
			p_temp_task_rec              := x_updated_tasks(i);

			modify_single_task(p_task_rec => p_temp_task_rec,
					   p_new_task_status => p_new_task_status,
					   P_new_task_priority => P_new_task_priority,
					   P_new_task_type => P_new_task_type,
					   P_new_carton_lpn_id => P_new_carton_lpn_id,
					   p_new_operation_plan_id => p_new_operation_plan_id,
					   p_output_task_rec => l_updated_tasks(i),
					   p_op_plan_rec => l_op_plan_rec);

			--Copy values from l_updated_tasks to x_updated_tasks
			x_updated_tasks(i).RESULT            := nvl(l_updated_tasks(i).RESULT,x_updated_tasks(i).RESULT);
			x_updated_tasks(i).ERROR             := nvl(l_updated_tasks(i).ERROR,x_updated_tasks(i).ERROR);
			x_updated_tasks(i).status_id         := nvl(l_updated_tasks(i).status_id,x_updated_tasks(i).status_id);
			x_updated_tasks(i).operation_plan_id := nvl(l_updated_tasks(i).operation_plan_id,x_updated_tasks(i).operation_plan_id);
			x_updated_tasks(i).cartonization_id  := nvl(l_updated_tasks(i).cartonization_id,x_updated_tasks(i).cartonization_id);
			x_updated_tasks(i).priority          := nvl(l_updated_tasks(i).priority,x_updated_tasks(i).priority);
			x_updated_tasks(i).user_task_type_id := nvl(l_updated_tasks(i).user_task_type_id,x_updated_tasks(i).user_task_type_id);
			--anjana
			IF (nvl(x_updated_tasks(i).RESULT,'X') = 'E') THEN
			  x_msg_count:= x_msg_count + 1;
			  x_msg_data := x_msg_data || x_updated_tasks(i).ERROR ;
			END IF;
		END IF;
	END LOOP;


	FOR i IN 1..x_updated_tasks.count
        LOOP
              IF (nvl(x_updated_tasks(i).RESULT,'X')<> 'E') THEN
		IF p_new_task_status = 2 THEN
		  l_transaction_num_table(l_transaction_num_table.COUNT+1)		:= x_updated_tasks(i).transaction_number;
		  l_organization_id_table(l_organization_id_table.COUNT+1)		:= x_updated_tasks(i).organization_id;
		  l_usertask_type_id_table(l_usertask_type_id_table.COUNt+1)		:= x_updated_tasks(i).user_task_type_id;
		  l_person_resource_id_tabe(l_person_resource_id_tabe.COUNt+1)		:= x_updated_tasks(i).person_resource_id;
		  l_machine_resource_id_table(l_machine_resource_id_table.COUNT+1)	:= x_updated_tasks(i).machine_resource_id;
		  l_status_id_table(l_status_id_table.COUNT+1)				:= x_updated_tasks(i).status_id;
		  l_priority_table(l_priority_table.COUNT+1)				:= x_updated_tasks(i).priority;
		  l_task_type_id_table(l_task_type_id_table.COUNT+1)			:= x_updated_tasks(i).task_type_id;
		  l_move_order_line_id_table(l_move_order_line_id_table.COUNt+1)	:= x_updated_tasks(i).move_order_line_id;
		  l_to_lpn_id_table(l_to_lpn_id_table.COUNT+1)				:= x_updated_tasks(i).to_lpn_id;
		  l_operation_plan_id_table(l_operation_plan_id_table.COUNT+1)		:= x_updated_tasks(i).operation_plan_id;
	--	  l_dispatched_time_table(l_dispatched_time_table.COUNt+1)		:= x_updated_tasks(i).dispatched_time;
		END IF;
		IF x_updated_tasks(i).task_type_id <> 3 then
                --for inbound and outbound tasks,update mmtt
		  l_mmtt_cartonization_id_table(l_mmtt_cartonization_id_table.COUNt+1)	:= x_updated_tasks(i).cartonization_id;
		  l_mmtt_transaction_num_table(l_mmtt_transaction_num_table.COUNT+1)	:= x_updated_tasks(i).transaction_number;
		  l_mmtt_usertask_type_id_table(l_mmtt_usertask_type_id_table.COUNt+1)	:= x_updated_tasks(i).user_task_type_id;
		  l_mmtt_status_id_table(l_mmtt_status_id_table.COUNT+1)		:= x_updated_tasks(i).status_id;
		  l_mmtt_priority_table(l_mmtt_priority_table.COUNT+1)			:= x_updated_tasks(i).priority;
		  l_mmtt_operation_plan_id_table(l_mmtt_operation_plan_id_table.COUNT+1):= x_updated_tasks(i).operation_plan_id;
		ELSE
 		  l_mcce_transaction_num_table(l_mcce_transaction_num_table.COUNT+1)	:= x_updated_tasks(i).transaction_number;
		  l_mcce_usertask_type_id_table(l_mcce_usertask_type_id_table.COUNt+1)	:= x_updated_tasks(i).user_task_type_id;
		  l_mcce_priority_table(l_mcce_priority_table.COUNT+1)			:= x_updated_tasks(i).priority;
		END IF;

		--If the x_updated_tasks(i).status_id is 2 ,then update wdt also.
                --wdt does not have cartonization_id.
                --Also this needs to be done only if wdt was existing before.
                IF (x_updated_tasks(i).status_id = 2 AND (nvl(p_new_task_status,-99) <> 2) )THEN
		  l_wdt_transaction_num_table(l_wdt_transaction_num_table.COUNT+1)	:= x_updated_tasks(i).transaction_number;
		  l_wdt_usertask_type_id_table(l_wdt_usertask_type_id_table.COUNt+1)	:= x_updated_tasks(i).user_task_type_id;
		  l_wdt_status_id_table(l_wdt_status_id_table.COUNT+1)			:= x_updated_tasks(i).status_id;
		  l_wdt_priority_table(l_wdt_priority_table.COUNT+1)			:= x_updated_tasks(i).priority;
		  l_wdt_operation_plan_id_table(l_wdt_operation_plan_id_table.COUNT+1)	:= x_updated_tasks(i).operation_plan_id;
		END IF;

		IF (nvl(p_new_task_status,-99) in (1,8)) THEN
		  l_wdt_del_trns_num_table(l_wdt_del_trns_num_table.COUNT+1)	:= x_updated_tasks(i).transaction_number;
		END IF;

	      END IF;
	END LOOP;

        --Do BULK INSERT,UPDATE
	IF (l_transaction_num_table.COUNT > 0) THEN
	  FORALL i in 1..l_transaction_num_table.COUNT
	  INSERT
	  INTO    wms_dispatched_tasks
	  (
		task_id             ,
		transaction_temp_id ,
		organization_id     ,
		user_task_type      ,
		person_id           ,
		effective_start_date,
		effective_end_date  ,
		person_resource_id  ,
		machine_resource_id ,
		status              ,
		dispatched_time     ,
		last_update_date    ,
		last_updated_by     ,
		creation_date       ,
		created_by          ,
		task_type           ,
		priority            ,
		move_order_line_id  ,
		operation_plan_id   ,
		transfer_lpn_id
	  )
	  VALUES
	  (
		wms_dispatched_tasks_s.NEXTVAL		,
		l_transaction_num_table(i)		,
		l_organization_id_table(i)		,
		l_usertask_type_id_table(i)		,
		p_person_id				,
		sysdate					,
		sysdate					,
		l_person_resource_id_tabe(i)		,
		l_machine_resource_id_table(i)		,
		l_status_id_table(i)			,
		sysdate					,
		sysdate					,
		FND_GLOBAL.USER_ID			,
		sysdate					,
		FND_GLOBAL.USER_ID			,
		l_task_type_id_table(i)			,
		l_priority_table(i)			,
		l_move_order_line_id_table(i)		,
		l_operation_plan_id_table(i)		,
		l_to_lpn_id_table(i)			);
	END IF;

	IF (l_mmtt_transaction_num_table.COUNT > 0) THEN
  	  FORALL i in 1..l_mmtt_transaction_num_table.COUNT
	  UPDATE mtl_material_transactions_temp
	  SET    wms_task_status       = l_mmtt_status_id_table(i)       ,
	  	 operation_plan_id     = l_mmtt_operation_plan_id_table(i),
		 cartonization_id      = l_mmtt_cartonization_id_table(i) ,
		 task_priority         = l_mmtt_priority_table(i)         ,
		 standard_operation_id = l_mmtt_usertask_type_id_table(i)
	  WHERE  transaction_temp_id   = l_mmtt_transaction_num_table(i);
	END IF;

	IF (l_mcce_transaction_num_table.COUNT > 0) THEN
	  FORALL i in 1..l_mcce_transaction_num_table.COUNT
	   UPDATE mtl_cycle_count_entries
	   SET    task_priority         = l_mcce_priority_table(i)         ,
		  standard_operation_id = l_mcce_usertask_type_id_table(i)
	   WHERE  cycle_count_entry_id  = l_mcce_transaction_num_table(i);
	END IF;

	IF (l_wdt_transaction_num_table.COUNT > 0) THEN
	  FORALL i in 1..l_wdt_transaction_num_table.COUNT
	  UPDATE wms_dispatched_tasks
	  SET    status		       = l_wdt_status_id_table(i)       ,
		 operation_plan_id     = l_wdt_operation_plan_id_table(i),
		 priority	       = l_wdt_priority_table(i)         ,
		 user_task_type        = l_wdt_usertask_type_id_table(i)
	  WHERE  transaction_temp_id   = l_wdt_transaction_num_table(i);
	END IF;

	IF (l_wdt_del_trns_num_table.COUNT > 0) THEN
	  FORALL i in 1..l_wdt_del_trns_num_table.COUNT
	  DELETE from wms_dispatched_tasks
	  WHERE  transaction_temp_id   = l_wdt_del_trns_num_table(i);
	END IF;

        IF (p_commit = FND_API.G_TRUE) THEN
                COMMIT;
        END IF;
EXCEPTION
WHEN OTHERS THEN
        x_return_status                  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);
        l_err_msg                        := substr(SQLERRM,1,1000);
        IF(l_debug                        = 1) THEN
                inv_trx_util_pub.trace(l_api_name|| ': '||l_err_msg);
        END IF;

END modify_task;

-------------------------------------------------------------------------------------------------------------

/*This Public API takes care of cancelling a single or a set of crossdock tasks.

PROCEDURE cancel_task (p_transaction_number     IN                         	NUMBER DEFAULT  NULL
		   , p_task_table           	IN                         	WMS_TASKS_PUB.TASK_TABLE
		   , p_commit               	IN                         	VARCHAR2  DEFAULT  G_FALSE
		   , x_undeleted_tasks  	OUT 	NOCOPY   	WMS_TASKS_PUB.TASK_TABLE
		   , x_unprocessed_crossdock_tasks
						OUT 	NOCOPY   	WMS_TASKS_PUB.TASK_TABLE
		   , x_return_status       	OUT 	NOCOPY   	VARCHAR2
		   , x_msg_count          	OUT 	NOCOPY   	NUMBER
		   , x_msg_data            	OUT 	NOCOPY  	VARCHAR2  );


Parameter		Description

p_transaction_number	This corrsponds to the task_id that user is trying to cancel
P_task_table		This correspinds to the set of tasks that user is trying to cancel
P_Commit		This parameter decides whether to commit the changes or not.
X_unprocessed_crossdockdeleted_tasks
			This parameter contains the set of tasks that could not be cancelled.
X_return_status		This parameter gives the return status of cancel_task API. 	'S' = Success, 'U' = Unexpected Error, 'E' = Error.
X_msg_count		This gives the count of messages logged during the task deletion process.
X_msg_data		This gives the descrption of the messages that got logged during the task deletion process.
*/
-------------------------------------------------------------------------------------------------------------

PROCEDURE cancel_task(
   p_transaction_number            IN              NUMBER DEFAULT NULL,
   p_commit                        IN              VARCHAR2 DEFAULT fnd_api.g_false,
   p_wms_task                      IN              WMS_TASK_MGMT_PUB.task_tab_type,
   x_unprocessed_crossdock_tasks   OUT NOCOPY      WMS_TASK_MGMT_PUB.task_tab_type,
   x_return_status                 OUT NOCOPY      VARCHAR2,
   x_msg_count                     OUT NOCOPY      NUMBER,
   x_msg_data                      OUT NOCOPY      VARCHAR2
)
IS

   l_val_ret_status    VARCHAR2(10) ;
   l_task_table WMS_TASK_MGMT_PUB.task_tab_type ;
   l_transaction_number NUMBER ;
   l_ret_task_table  WMS_TASK_MGMT_PUB.task_tab_type;
   l_debug     NUMBER         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_unprocessed_crossdock_count     NUMBER         := 1;
   l_msg		VARCHAR2(2000);

BEGIN

   x_return_status := fnd_api.g_ret_sts_success;
   --anjana
   x_msg_count := 0;
   l_transaction_number:= p_transaction_number ;
   l_task_table        := p_wms_task;


   IF l_debug = 1 THEN
      inv_trx_util_pub.trace('CANCEL_TASK: Enter...');
   END IF;

   WMS_TASK_MGMT_PUB.validate_tasks( p_transaction_number => l_transaction_number ,
				     p_task_table => l_task_table ,
				     x_wms_task => l_ret_task_table ,
				     x_return_status => l_val_ret_status );
   IF l_debug = 1 THEN
    inv_trx_util_pub.trace('cancel_task l_val_ret_status is : '||l_val_ret_status);
   END IF;

   IF (l_val_ret_status = fnd_api.g_ret_sts_success) THEN
      IF l_debug = 1 THEN
	      inv_trx_util_pub.trace('l_ret_task_table.count :   '||l_ret_task_table.count);
      END IF;

      FOR i in 1..l_ret_task_table.count LOOP
         IF l_debug = 1 THEN
	         inv_trx_util_pub.trace('cancel_task l_ret_task_table(i).RESULT    '||l_ret_task_table(i).RESULT);
         END IF;
         IF ( nvl(l_ret_task_table(i).RESULT,'X')<> FND_API.G_RET_STS_ERROR)THEN
            IF l_debug = 1 THEN
		    inv_trx_util_pub.trace('cancel_task transaction_number    '||l_ret_task_table(i).transaction_number);
	    END IF;
            SAVEPOINT SAVEPOINT1;
            WMS_CROSS_DOCK_PVT.cancel_crossdock_task(p_transaction_temp_id => l_ret_task_table(i).transaction_number
         				            ,x_return_status => x_return_status
				                    ,x_msg_data => x_msg_data
				                    ,x_msg_count => x_msg_count);
            IF l_debug = 1 THEN
		    inv_trx_util_pub.trace('cancel_task CANCEL_TASK: x_return_status: ' || x_return_status);
	    END IF;

	    IF (x_return_status<>FND_API.G_RET_STS_SUCCESS) THEN
    		FND_MESSAGE.SET_NAME('WMS', 'WMS_CANCEL_FAILED');
		l_msg := fnd_message.get;
		x_msg_count := x_msg_count + 1;
		x_msg_data := x_msg_data || l_msg;

		x_unprocessed_crossdock_tasks(l_unprocessed_crossdock_count).transaction_number := l_transaction_number;
	        x_unprocessed_crossdock_tasks(l_unprocessed_crossdock_count).result             := x_return_status;
 	        x_unprocessed_crossdock_tasks(l_unprocessed_crossdock_count).error              := l_msg;
                l_unprocessed_crossdock_count							:=l_unprocessed_crossdock_count+1;
	        ROLLBACK TO SAVEPOINT1;
            END IF;
         ELSE
	    FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_TASK');
	    l_msg := fnd_message.get;
	    x_msg_count := x_msg_count + 1;
	    x_msg_data := x_msg_data || l_msg;
            IF l_debug = 1 THEN
		    inv_trx_util_pub.trace('Validate_task returned error for this record');
	    END IF;
            x_unprocessed_crossdock_tasks(l_unprocessed_crossdock_count).transaction_number := l_transaction_number;
	    x_unprocessed_crossdock_tasks(l_unprocessed_crossdock_count).result             := l_ret_task_table(i).RESULT;
 	    x_unprocessed_crossdock_tasks(l_unprocessed_crossdock_count).error              := l_msg;
            l_unprocessed_crossdock_count						    := l_unprocessed_crossdock_count+1;
	 END IF;
      END LOOP;
      IF l_debug = 1 THEN
	inv_trx_util_pub.trace('CANCEL_TASK: x_unprocessed_crossdock_tasks: ' || x_unprocessed_crossdock_tasks.count);
	inv_trx_util_pub.trace('CANCEL_TASK: Exiting...');
      END IF;
    ELSE
      IF l_debug = 1 THEN
        inv_trx_util_pub.trace('CANCEL_TASK: Error occured while validating the transaction_number or table of transaction_number...');
      END IF;
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;
    END IF;

    IF (p_commit= FND_API.G_TRUE ) THEN
       COMMIT;
    END IF;
EXCEPTION
  WHEN fnd_api.g_exc_error  THEN
      IF l_debug = 1 THEN
        inv_trx_util_pub.trace('CANCEL_TASK: Expected Error occurred while performing cancel cross dock task:'|| SQLCODE);
      END IF;
      x_return_status:=FND_API.G_RET_STS_ERROR;
      ROLLBACK TO SAVEPOINT1;
      RETURN;
  WHEN OTHERS  THEN
      IF l_debug = 1 THEN
        inv_trx_util_pub.trace('CANCEL_TASK: Unknown Error occurred while performing cancel cross dock task:'|| SQLCODE);
      END IF;
      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO SAVEPOINT1;
      RETURN;
END cancel_task;

END WMS_TASK_MGMT_PUB;

/
