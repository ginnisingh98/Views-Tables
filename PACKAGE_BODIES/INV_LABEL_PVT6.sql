--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT6" AS
/* $Header: INVLAP6B.pls 120.3 2005/08/25 19:23:59 satkumar ship $ */

LABEL_B		CONSTANT VARCHAR2(50) := '<label';
LABEL_E		CONSTANT VARCHAR2(50) := '</label>'||fnd_global.local_chr(10);
VARIABLE_B	CONSTANT VARCHAR2(50) := '<variable name= "';
VARIABLE_E	CONSTANT VARCHAR2(50) := '</variable>'||fnd_global.local_chr(10);
TAG_E		CONSTANT VARCHAR2(50)  := '>'||fnd_global.local_chr(10);
l_debug number;

PROCEDURE trace(p_message IN VARCHAR2) iS
BEGIN
   	INV_LABEL.trace(p_message, 'LABEL_LOCATION');
END trace;

PROCEDURE get_variable_data(
	x_variable_content 	OUT NOCOPY INV_LABEL.label_tbl_type
,	x_msg_count		OUT NOCOPY NUMBER
,	x_msg_data		OUT NOCOPY VARCHAR2
,	x_return_status		OUT NOCOPY VARCHAR2
,	p_label_type_info	IN INV_LABEL.label_type_rec
,	p_transaction_id	IN NUMBER
,	p_input_param		IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,   p_transaction_identifier IN NUMBER
) IS


	l_subinventory_code VARCHAR2(10);
	l_locator_id NUMBER;
	l_organization_id NUMBER;

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--   Following variables were added (as a part of 11i10+ 'Custom Labels' Project)            |
--   to retrieve and hold the SQL Statement and it's result.                                 |
---------------------------------------------------------------------------------------------
   l_sql_stmt  VARCHAR2(4000);
   l_sql_stmt_result VARCHAR2(4000) := NULL;
   TYPE sql_stmt IS REF CURSOR;
   c_sql_stmt sql_stmt;
   l_custom_sql_ret_status VARCHAR2(1);
   l_custom_sql_ret_msg VARCHAR2(2000);

   -- Fix for bug: 4179593 Start
   l_CustSqlWarnFlagSet BOOLEAN;
   l_CustSqlErrFlagSet BOOLEAN;
   l_CustSqlWarnMsg VARCHAR2(2000);
   l_CustSqlErrMsg VARCHAR2(2000);
   -- Fix for bug: 4179593 End

------------------------End of this change for Custom Labels project code--------------------

	CURSOR	c_all_sub IS
		SELECT secondary_inventory_name
		FROM mtl_secondary_inventories
		WHERE organization_id = l_organization_id;
	CURSOR c_all_sub_loc IS
		SELECT msi.secondary_inventory_name, milkfv.inventory_location_id
		FROM mtl_secondary_inventories msi
			,mtl_item_locations milkfv
		WHERE msi.organization_id = l_organization_id
		AND	  msi.secondary_inventory_name = nvl(l_subinventory_code, msi.secondary_inventory_name)
		AND	  milkfv.organization_id(+) = l_organization_id
		AND	  milkfv.subinventory_code(+)  = msi.secondary_inventory_name;

	CURSOR c_location IS
		SELECT
			mp.organization_id    organization_id
		,  mp.organization_code    organization
		,  msi.secondary_inventory_name     subinventory_code
		,  msi.description            subinventory_description
		,  msi.status_id           status_id
		,  mmsvl1.status_code          subinventory_status
		,  msi.pick_uom_code          subinventory_pick_uom
		,  msi.attribute_category        subinv_attribute_category
		,  msi.attribute1          subinventory_attribute1
		,  msi.attribute2          subinventory_attribute2
		,  msi.attribute3          subinventory_attribute3
		,  msi.attribute4          subinventory_attribute4
		,  msi.attribute5          subinventory_attribute5
		,  msi.attribute6          subinventory_attribute6
		,  msi.attribute7          subinventory_attribute7
		,  msi.attribute8          subinventory_attribute8
		,  msi.attribute9          subinventory_attribute9
		,  msi.attribute10         subinventory_attribute10
		,  msi.attribute11         subinventory_attribute11
		,  msi.attribute11         subinventory_attribute12
		,  msi.attribute13         subinventory_attribute13
		,  msi.attribute14         subinventory_attribute14
		,  msi.attribute15         subinventory_attribute15
		,  msi.picking_order       subinventory_pick_order
		,  msi.default_cost_group_id  subinventory_def_cost_group_id
		,  ccg.cost_group       subinventory_def_cost_group
		,  milkfv.inventory_location_id         locator_id
		,  INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id,milkfv.organization_id)  locator
		,  milkfv.description      locator_description
		,  milkfv.status_id      locator_status_id
		,  mmsvl2.status_code    locator_status
		,  milkfv.pick_uom_code    locator_pick_uom
		,  milkfv.attribute_category  locator_attribute_category
		,  milkfv.attribute1    locator_attribute1
		,  milkfv.attribute2    locator_attribute2
		,  milkfv.attribute3    locator_attribute3
		,  milkfv.attribute4    locator_attribute4
		,  milkfv.attribute5    locator_attribute5
		,  milkfv.attribute6    locator_attribute6
		,  milkfv.attribute7    locator_attribute7
		,  milkfv.attribute8    locator_attribute8
		,  milkfv.attribute9    locator_attribute9
		,  milkfv.attribute10      locator_attribute10
		,  milkfv.attribute11      locator_attribute11
		,  milkfv.attribute12      locator_attribute12
		,  milkfv.attribute13      locator_attribute13
		,  milkfv.attribute14      locator_attribute14
		,  milkfv.attribute15      locator_attribute15
		,  milkfv.project_id    locator_project_id
		,  pap.name       locator_project
		,  milkfv.task_id    locator_task_id
		,  pat.task_name     locator_task
		,  milkfv.picking_order    locator_pick_order
		,  milkfv.max_weight    locator_weight_capacity
		,  milkfv.location_weight_uom_code  locator_weight_capacity_uom
		,  milkfv.max_cubic_area      locator_volume_capacity
		,  milkfv.volume_uom_code     locator_volume_capacity_uom
		,  milkfv.location_maximum_units    locator_unit_capacity
		,  milkfv.alias    locator_alias
		FROM    mtl_parameters                       mp
			,  mtl_secondary_inventories            msi
			,  mtl_material_statuses_vl             mmsvl1
			,  mtl_material_statuses_vl             mmsvl2
			,  mtl_item_locations               milkfv
			,  pa_tasks                             pat
			,  pa_projects_all                      pap
			,  cst_cost_groups                      ccg
		WHERE	mp.organization_id                   = l_organization_id
		AND		msi.secondary_inventory_name(+)      = l_subinventory_code
		AND		msi.organization_id(+)               = mp.organization_id
		AND		mmsvl1.status_id(+)                  = msi.status_id
		AND		mmsvl2.status_id(+)                  = milkfv.status_id
		AND		milkfv.inventory_location_id(+)      = l_locator_id
		AND		milkfv.subinventory_code(+)          = l_subinventory_code
		AND		milkfv.organization_id(+)            = mp.organization_id
		AND		pap.project_id(+)                    = milkfv.project_id
		AND		pat.task_id(+)                       = milkfv.task_id
		AND		ccg.COST_GROUP_ID(+)                 = msi.DEFAULT_COST_GROUP_ID;


	l_location_data LONG;

	l_selected_fields INV_LABEL.label_field_variable_tbl_type;
	l_selected_fields_count	NUMBER;

	l_content_rec_index NUMBER := 0;

	l_label_format_id       NUMBER := 0 ;
	l_label_format     VARCHAR2(100);
	l_printer        	VARCHAR2(30);

	l_api_name VARCHAR2(20) := 'get_variable_data';

	l_return_status VARCHAR2(240);

	l_error_message  VARCHAR2(240);
	l_msg_count      NUMBER;
	l_api_status     VARCHAR2(240);
	l_msg_data		 VARCHAR2(240);

	l_print_all_mode NUMBER := 0;

	i NUMBER;

	l_label_index NUMBER;
	l_label_request_id NUMBER;

	--I cleanup, use l_prev_format_id to record the previous label format
	l_prev_format_id      NUMBER;

	-- I cleanup, user l_prev_sub to record the previous subinventory
	--so that get_printer is not called if the subinventory is the same
	l_prev_sub VARCHAR2(30);

	-- a list of columns that are selected for format
	l_column_name_list LONG;
BEGIN
    l_debug := INV_LABEL.l_debug;
	IF (l_debug = 1) THEN
   	trace('**In PVT6: Location label**');
   	trace('  Business_flow: '||p_label_type_info.business_flow_code);
   	trace('  Transaction ID:'||p_transaction_id);
	END IF;

	-- Get Org, Sub, Loc
	IF p_transaction_id IS NOT NULL THEN
		l_organization_id := null;
		l_subinventory_code := null;
		l_locator_id	:=null;
	ELSE
		-- On demand, get information from input_param
        l_organization_id := p_input_param.organization_id;
        l_subinventory_code := p_input_param.subinventory_code;
        l_locator_id := p_input_param.locator_id;
	END IF;

	IF (l_debug = 1) THEN
   	trace(' Input Organization Id = '|| l_organization_id||
   	      ',subinventory_code='|| l_subinventory_code||
   	      ',Locator Id = '|| l_locator_id);
	END IF;
	IF (l_organization_id IS NULL) THEN
		IF (l_debug = 1) THEN
   		trace(' Oranization IS NULL, cannot process ');
		END IF;
		RETURN;
	END IF;

	IF (l_debug = 1) THEN
   	trace('Getting the print all mode');
	END IF;
	--  If Sub or Loc is passed as NULL, it will print
	--		all the sub or locator
	--	If Sub or Loc is passed as -1, it will not print
	--		all the sub or locator, it will just print
	--		 the org or sub.
	-- l_print_all_mode =
	--		0: nothing to print
	--		1: print just the org
	--		2: print org and all the sub
	--		3: print just the org and sub
	--		4: print org, sub and all the locators
	--		5: print the given org, sub and locator
	IF l_subinventory_code IS NULL THEN
		-- Print just the Org
		l_print_all_mode := 1;
	ELSIF l_subinventory_code = '-1' THEN
		-- Print all the sub
		IF l_locator_id IS NULL THEN
			-- just org and sub
			l_print_all_mode := 2;
		ELSE
			l_print_all_mode := 4;
		END IF;
	ELSE
		-- Giving a subinventory
		IF l_locator_id IS NULL THEN
			-- Print just org and sub
			l_print_all_mode := 3;
		ELSIF l_locator_id = -1 THEN
			-- Finding all the locators for this sub
			l_print_all_mode := 4;
		ELSE
			-- print given org, sub and loc
			l_print_all_mode := 5;
		END IF;
	END IF;
	IF (l_debug = 1) THEN
   	trace(' Got the l_print_all_mode = '|| l_print_all_mode);
   	--trace(' Getting selected fields ');
	END IF;


	IF (l_debug = 1) THEN
   	trace(' Getting org, sub, locator based on l_print_all_mode');
	END IF;
	IF l_print_all_mode = 0 THEN
		-- Nothing to print
		RETURN;
	ELSIF l_print_all_mode = 1 THEN
		-- set sub and loc as null
		l_subinventory_code := null;
		l_locator_id := null;
	ELSIF l_print_all_mode = 2 THEN
		-- print org and all the sub
		l_subinventory_code := null;
		OPEN c_all_sub;
		FETCH c_all_sub INTO l_subinventory_code;
		IF c_all_sub%NOTFOUND THEN
			IF (l_debug = 1) THEN
   			trace(' No subinventory found for this org: '|| l_organization_id);
			END IF;
			l_subinventory_code := null;
			l_locator_id := null;
			CLOSE c_all_sub;
		END IF;
	ELSIF l_print_all_mode = 3 THEN
		-- print org and just given sub
		l_locator_id := null;
	ELSIF l_print_all_mode = 4 THEN
		-- Print org, all the locators for the given sub or all sub
		IF l_subinventory_code = '-1' THEN
			l_subinventory_code := null;
		END IF;
		l_locator_id := null;
		OPEN c_all_sub_loc;
		FETCH c_all_sub_loc INTO l_subinventory_code, l_locator_id;
		IF c_all_sub_loc%NOTFOUND THEN
			IF (l_debug = 1) THEN
   			trace(' No subinventory and locator found for this org: '|| l_organization_id || l_subinventory_code);
			END IF;
			--l_subinventory_code := null;
			l_locator_id := null;
			CLOSE c_all_sub_loc;
		END IF;
	ELSIF l_print_all_mode = 5 THEN
		null;
	END IF;

	l_content_rec_index := 0;
	l_location_data := '';
	IF (l_debug = 1) THEN
   	trace('** in PVT6.get_variable_dataa ** , start ');
	END IF;
	l_printer := p_label_type_info.default_printer;

	l_label_index := 1;
	l_prev_format_id := -999; --p_label_type_info.default_format_id;--in R12
 	l_prev_sub := '####';

	WHILE l_organization_id IS NOT NULL LOOP
		l_content_rec_index := l_content_rec_index + 1;
		IF (l_debug = 1) THEN
   		trace(' before FOR c_location org, sub, loc = '|| l_organization_id ||', '||l_subinventory_code || ', ' || l_locator_id);
		END IF;
		l_location_data := '';
		FOR v_location IN c_location LOOP
			IF (l_debug = 1) THEN
   			trace(' In Loop ' || l_content_rec_index ||' ^^^^^^^^New Label ^^^^^^^^^^^');
   			trace(' org, sub, loc = '|| l_organization_id ||', '||l_subinventory_code || ', ' || l_locator_id);
			END IF;


			--R12 : RFID compliance project
			--Calling rules engine before calling to get printer

			IF (l_debug = 1) THEN
    			trace('Apply Rules engine to get format '
 				||',manual_format_id='||p_label_type_info.manual_format_id
 				||',manual_format_name='||p_label_type_info.manual_format_name);
 			END IF;

			/* insert a record into wms_label_requests entity to
			call the label rules engine to get appropriate label */
			INV_LABEL.GET_FORMAT_WITH_RULE
			( 	p_document_id        =>p_label_type_info.label_type_id,
				P_LABEL_FORMAT_ID    => p_label_type_info.manual_format_id,
			 	p_organization_id    =>v_location.organization_id,
				p_subinventory_code  =>v_location.subinventory_code,
				p_locator_id         =>v_location.locator_id,
        			P_BUSINESS_FLOW_CODE =>   p_label_type_info.business_flow_code,
				P_LAST_UPDATE_DATE   =>sysdate,
				P_LAST_UPDATED_BY    =>FND_GLOBAL.user_id,
				P_CREATION_DATE      =>sysdate,
				P_CREATED_BY         =>FND_GLOBAL.user_id,
				--P_PRINTER_NAME   =>	l_printer,-- Removed in R12: 4396558
				x_return_status      =>l_return_status,
				x_label_format_id    =>l_label_format_id,
				x_label_format	     =>l_label_format,
				x_label_request_id   =>l_label_request_id);

			IF (l_debug = 1) THEN
			   trace('did apply label ' || l_label_format || ',' || l_label_format_id);
			END IF;
			IF l_return_status <> 'S' THEN
			   FND_MESSAGE.SET_NAME('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
			   FND_MSG_PUB.ADD;
			   l_label_format:= p_label_type_info.default_format_id;
			   l_label_format_id:= p_label_type_info.default_format_name;
			END IF;
			IF (l_debug = 1) THEN
			   trace('did apply label ' || l_label_format || ',' || l_label_format_id||',req_id '||l_label_request_id);

			   trace(' Getting printer, manual_printer='||p_label_type_info.manual_printer
 					||',sub='||v_location.subinventory_code
 					||',default printer='||p_label_type_info.default_printer);
 			END IF;

			-- IF clause Added for Add format/printer for manual request
 			IF p_label_type_info.manual_printer IS NULL THEN
 			-- The p_label_type_info.manual_printer is the one  passed from the manual page.
 			-- As per the design, if a printer is passed from the manual page, then we use that printer irrespective.

				IF (v_location.subinventory_code IS NOT NULL) AND
				   (v_location.subinventory_code <> l_prev_sub) THEN
				    IF (l_debug = 1) THEN
   				    trace('getting printer with sub '||v_location.subinventory_code);
				    END IF;
				    BEGIN
				    	WSH_REPORT_PRINTERS_PVT.GET_PRINTER(
				    		p_concurrent_program_id=>p_label_type_info.label_type_id,
				    		p_user_id              =>fnd_global.user_id,
				    		p_responsibility_id    =>fnd_global.resp_id,
				    		p_application_id       =>fnd_global.resp_appl_id,
				    		p_organization_id      =>v_location.organization_id,
				    		p_zone                 =>v_location.subinventory_code,
						p_format_id            =>l_label_format_id, --added in r12 RFID
						x_printer              =>l_printer,
				    		x_api_status           =>l_api_status,
				    		x_error_message        =>l_error_message);
				    	IF l_api_status <> 'S' THEN
				    		IF (l_debug = 1) THEN
   				    		trace('Error in calling get_printer, set printer as default printer, err_msg:'||l_error_message);
				    		END IF;
				    		l_printer := p_label_type_info.default_printer;
				    	END IF;

				    EXCEPTION
				    	WHEN others THEN
				    	l_printer := p_label_type_info.default_printer;
				    END;
				    l_prev_sub := v_location.subinventory_code;
				END IF;
			ELSE
				IF (l_debug = 1) THEN
   				trace('Set printer as Manual Printer passed in:' || p_label_type_info.manual_printer );
				END IF;
				l_printer := p_label_type_info.manual_printer;
			END IF;


			IF p_label_type_info.manual_format_id IS NOT NULL THEN
				l_label_format_id := p_label_type_info.manual_format_id;
				l_label_format := p_label_type_info.manual_format_name;
				IF (l_debug = 1) THEN
   				trace('Manual format passed in:'||l_label_format_id||','||l_label_format);
				END IF;
			END IF;
			IF (l_label_format_id IS NOT NULL) THEN
				-- Derive the fields for the format either passed in or derived via the rules engine.
				IF l_label_format_id <> l_prev_format_id
				  THEN --l_prev_format_id initial value is -999
					IF (l_debug = 1) THEN
   					trace(' Getting variables for new format ' || l_label_format);
					END IF;
					INV_LABEL.GET_VARIABLES_FOR_FORMAT(
						x_variables 		=> l_selected_fields
					,	x_variables_count	=> l_selected_fields_count
					,	p_format_id		=> l_label_format_id);

					l_prev_format_id := l_label_format_id;

					IF (l_selected_fields_count=0) OR (l_selected_fields.count =0 ) THEN
						IF (l_debug = 1) THEN
   						trace('no fields defined for this format: ' || l_label_format|| ',' ||l_label_format_id);
						END IF;
						GOTO NextLabel;
					END IF;
					IF (l_debug = 1) THEN
   					trace('   Found selected_fields for format ' || l_label_format ||', num='|| l_selected_fields_count);
					END IF;
				END IF;
			ELSE
				IF (l_debug = 1) THEN
   				trace('No format exists for this label, goto nextlabel');
				END IF;
				GOTO NextLabel;
			END IF;

 			/* variable header */
			l_location_data := l_location_data || LABEL_B;
			IF l_label_format <> nvl(p_label_type_info.default_format_name, '@@@') THEN
				l_location_data := l_location_data || ' _FORMAT="' || nvl(p_label_type_info.manual_format_name, l_label_format) || '"';
			END IF;
			IF (l_printer IS NOT NULL) AND (l_printer <> nvl(p_label_type_info.default_printer,'###')) THEN
				l_location_data := l_location_data || ' _PRINTERNAME="'||l_printer||'"';
			END IF;

			l_location_data := l_location_data || TAG_E;

			IF (l_debug = 1) THEN
   			trace('Starting assign variables, ');
			END IF;

			l_column_name_list := 'Set variables for ';

         /* Modified for Bug 4072474 -start*/
         l_custom_sql_ret_status := FND_API.G_RET_STS_SUCCESS;
         /* Modified for Bug 4072474 -End*/

         -- Fix for bug: 4179593 Start
         l_CustSqlWarnFlagSet := FALSE;
         l_CustSqlErrFlagSet := FALSE;
         l_CustSqlWarnMsg := NULL;
         l_CustSqlErrMsg := NULL;
         -- Fix for bug: 4179593 End

			/* Loop for each selected fields, find the columns and write into the XML_content*/
			FOR i IN 1..l_selected_fields.count LOOP
				IF (l_debug = 1) THEN
   					l_column_name_list := l_column_name_list || ',' ||l_selected_fields(i).column_name;
				END IF;

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--  The check (SQL_STMT <> NULL and COLUMN_NAME = NULL) implies that the field is a          |
--  Custom SQL based field. Handle it appropriately.                                         |
---------------------------------------------------------------------------------------------
   		  IF (l_selected_fields(i).SQL_STMT IS NOT NULL AND l_selected_fields(i).column_name = 'sql_stmt') THEN
   			 IF (l_debug = 1) THEN
   			  trace('Custom Labels Trace [INVLAP6B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
   			  trace('Custom Labels Trace [INVLAP6B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
   			  trace('Custom Labels Trace [INVLAP6B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
   			  trace('Custom Labels Trace [INVLAP6B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
   			  trace('Custom Labels Trace [INVLAP6B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
   			 END IF;
   			 l_sql_stmt := l_selected_fields(i).sql_stmt;
   			 IF (l_debug = 1) THEN
   			  trace('Custom Labels Trace [INVLAP6B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
   			 END IF;
   			 l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
   			 IF (l_debug = 1) THEN
   			  trace('Custom Labels Trace [INVLAP6B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);

   			 END IF;
   			 BEGIN
   			 IF (l_debug = 1) THEN
   			  trace('Custom Labels Trace [INVLAP6B.pls]: At Breadcrumb 1');
   			  trace('Custom Labels Trace [INVLAP6B.pls]: LABEL_REQUEST_ID     : ' || l_label_request_id);
   			 END IF;
   			 OPEN c_sql_stmt FOR l_sql_stmt using l_label_request_id;
   			 LOOP
   				 FETCH c_sql_stmt INTO l_sql_stmt_result;
   				 EXIT WHEN c_sql_stmt%notfound OR c_sql_stmt%rowcount >=2;
   			 END LOOP;

             IF (c_sql_stmt%rowcount=1 AND l_sql_stmt_result IS NULL) THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_custom_sql_ret_status  := INV_LABEL.G_WARNING;
                fnd_message.set_name('WMS','WMS_CS_NULL_VALUE_RETURNED');
                fnd_msg_pub.ADD;
                -- Fix for bug: 4179593 Start
                --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                l_CustSqlWarnFlagSet := TRUE;
                -- Fix for bug: 4179593 End
               IF (l_debug = 1) THEN
                trace('Custom Labels Trace [INVLAP6B.pls]: At Breadcrumb 2');
                trace('Custom Labels Trace [INVLAP6B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
                trace('Custom Labels Trace [INVLAP6B.pls]: WARNING: NULL value returned by the custom SQL Query.');
                trace('Custom Labels Trace [INVLAP6B.pls]: l_custom_sql_ret_status  is set to : ' || l_custom_sql_ret_status );
               END IF;
             ELSIF c_sql_stmt%rowcount=0 THEN
   				IF (l_debug = 1) THEN
   				 trace('Custom Labels Trace [INVLAP6B.pls]: At Breadcrumb 3');
   				 trace('Custom Labels Trace [INVLAP6B.pls]: WARNING: No row returned by the Custom SQL query');
   				END IF;
   				x_return_status := FND_API.G_RET_STS_SUCCESS;
               l_custom_sql_ret_status  := INV_LABEL.G_WARNING;
   				fnd_message.set_name('WMS','WMS_CS_NO_DATA_FOUND');
   				fnd_msg_pub.ADD;
               /* Replaced following statement for Bug 4207625: Anupam Jain*/
         		/*fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_status);*/
               -- Fix for bug: 4179593 Start
               --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
               l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
               l_CustSqlWarnMsg := l_custom_sql_ret_msg;
               l_CustSqlWarnFlagSet := TRUE;
               -- Fix for bug: 4179593 End
   			 ELSIF c_sql_stmt%rowcount>=2 THEN
   				IF (l_debug = 1) THEN
   				 trace('Custom Labels Trace [INVLAP6B.pls]: At Breadcrumb 4');
   				 trace('Custom Labels Trace [INVLAP6B.pls]: ERROR: Multiple values returned by the Custom SQL query');
   				END IF;
               l_sql_stmt_result := NULL;
   				x_return_status := FND_API.G_RET_STS_SUCCESS;
               l_custom_sql_ret_status  := FND_API.G_RET_STS_ERROR;
   				fnd_message.set_name('WMS','WMS_CS_MULTIPLE_VALUES_RETURN');
   				fnd_msg_pub.ADD;
               /* Replaced following statement for Bug 4207625: Anupam Jain*/
         		/*fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_status);*/
               -- Fix for bug: 4179593 Start
               --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
               l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
               l_CustSqlErrMsg := l_custom_sql_ret_msg;
               l_CustSqlErrFlagSet := TRUE;
               -- Fix for bug: 4179593 End
   			 END IF;
             IF (c_sql_stmt%ISOPEN) THEN
	            CLOSE c_sql_stmt;
             END IF;
   			EXCEPTION
   			WHEN OTHERS THEN
            IF (c_sql_stmt%ISOPEN) THEN
	            CLOSE c_sql_stmt;
            END IF;
   			  IF (l_debug = 1) THEN
   				trace('Custom Labels Trace [INVLAP6B.pls]: At Breadcrumb 5');
   				trace('Custom Labels Trace [INVLAP6B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
   			  END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
   			  fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
   			  fnd_msg_pub.ADD;
   			  fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
   			  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   		   END;
   		   IF (l_debug = 1) THEN
   			  trace('Custom Labels Trace [INVLAP6B.pls]: At Breadcrumb 6');
   			  trace('Custom Labels Trace [INVLAP6B.pls]: Before assigning it to l_location_data');
   		   END IF;
   			l_location_data  :=   l_location_data
   							   || variable_b
   							   || l_selected_fields(i).variable_name
   							   || '">'
   							   || l_sql_stmt_result
   							   || variable_e;
   			l_sql_stmt_result := NULL;
   			l_sql_stmt        := NULL;
   			IF (l_debug = 1) THEN
   			  trace('Custom Labels Trace [INVLAP6B.pls]: At Breadcrumb 7');
   			  trace('Custom Labels Trace [INVLAP6B.pls]: After assigning it to l_location_data');
              trace('Custom Labels Trace [INVLAP6B.pls]: --------------------------REPORT END-------------------------------------');
   			END IF;
------------------------End of this change for Custom Labels project code--------------------
	         ELSIF LOWER(l_selected_fields(i).column_name) = 'current_date' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || INV_LABEL.G_DATE || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'current_time' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || INV_LABEL.G_TIME || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'request_user' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || INV_LABEL.G_USER || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'organization' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.organization || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_code' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_code || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_description' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_description || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_status' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_status || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_pick_uom' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_pick_uom || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinv_attribute_category' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinv_attribute_category || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute1' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute1 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute2' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute2 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute3' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute3 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute4' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute4 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute5' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute5 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute6' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute6 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute7' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute7 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute8' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute8 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute9' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute9 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute10' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute10 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute11' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute11 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute12' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute12 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute13' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute13 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute14' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute14 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_attribute15' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_attribute15 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_pick_order' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_pick_order || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_def_cost_group' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.subinventory_def_cost_group || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_description' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_description || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_status' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_status || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_pick_uom' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_pick_uom || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute_category' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute_category || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute1' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute1 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute2' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute2 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute3' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute3 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute4' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute4 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute5' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute5 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute6' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute6 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute7' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute7 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute8' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute8 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute9' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute9 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute10' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute10 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute11' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute11 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute12' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute12 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute13' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute13 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute14' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute14 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_attribute15' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_attribute15 || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_project' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_project || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_task' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_task || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_pick_order' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_pick_order || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_weight_capacity' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_weight_capacity || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_weight_capacity_uom' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_weight_capacity_uom || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_volume_capacity' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_volume_capacity || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_volume_capacity_uom' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_volume_capacity_uom || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_unit_capacity' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_unit_capacity || VARIABLE_E;
				ELSIF LOWER(l_selected_fields(i).column_name) = 'locator_alias' THEN l_location_data := l_location_data || VARIABLE_B || l_selected_fields(i).variable_name || '">' || v_location.locator_alias || VARIABLE_E;
				END IF;

			END LOOP;
			l_location_data := l_location_data || LABEL_E;
			x_variable_content(l_label_index).label_content := l_location_data;
			x_variable_content(l_label_index).label_request_id := l_label_request_id;

------------------------Start of changes for Custom Labels project code------------------
        -- Fix for bug: 4179593 Start
        IF (l_CustSqlWarnFlagSet) THEN
         l_custom_sql_ret_status := INV_LABEL.G_WARNING;
         l_custom_sql_ret_msg := l_CustSqlWarnMsg;
        END IF;

        IF (l_CustSqlErrFlagSet) THEN
         l_custom_sql_ret_status := FND_API.G_RET_STS_ERROR;
         l_custom_sql_ret_msg := l_CustSqlErrMsg;
        END IF;
        -- Fix for bug: 4179593 End

        x_variable_content(l_label_index).label_status      := l_custom_sql_ret_status ;
        x_variable_content(l_label_index).error_message     := l_custom_sql_ret_msg;
------------------------End of this changes for Custom Labels project code---------------

			l_label_index := l_label_index + 1;
			<<NextLabel>>
			l_location_data := '';
			l_label_request_id := null;

------------------------Start of changes for Custom Labels project code------------------
        l_custom_sql_ret_status  := NULL;
        l_custom_sql_ret_msg    := NULL;
------------------------End of this changes for Custom Labels project code---------------

			IF(l_debug=1) THEN
				trace(l_column_name_list);
				trace('Finished writing one label');
			END IF;
		END LOOP;

		--x_variable_content := x_variable_content || l_location_data;
		IF (l_debug = 1) THEN
   		trace(' Getting the next sub/locator ');
		END IF;
		IF l_print_all_mode = 2 THEN
		-- print org and all the sub
			FETCH c_all_sub INTO l_subinventory_code;
			IF c_all_sub%NOTFOUND THEN
				l_organization_id := null;
				l_subinventory_code := null;
				l_locator_id := null;
				CLOSE c_all_sub;
			ELSE
				IF (l_debug = 1) THEN
   				trace(' Found next sub'|| l_subinventory_code );
				END IF;
			END IF;
		ELSIF l_print_all_mode = 4 THEN
			-- Print org, all the locators for the given sub or all sub
			FETCH c_all_sub_loc INTO l_subinventory_code, l_locator_id;
			IF c_all_sub_loc%NOTFOUND THEN
				IF (l_debug = 1) THEN
   				trace(' Done with org '	|| l_organization_id);
				END IF;
				l_organization_id := null;
				l_subinventory_code := null;
				l_locator_id := null;
				CLOSE c_all_sub_loc;
			ELSE
				IF (l_debug = 1) THEN
   				trace(' Found next sub, loc : '|| l_subinventory_code ||','|| l_locator_id);
				END IF;
			END IF;
		ELSE
			l_organization_id := null;
		END IF;

	END LOOP;
END get_variable_data;

PROCEDURE get_variable_data(
   x_variable_content   OUT NOCOPY LONG
,  x_msg_count    OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  p_label_type_info IN INV_LABEL.label_type_rec
,  p_transaction_id  IN NUMBER
,  p_input_param     IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,  p_transaction_identifier IN NUMBER
) IS
   l_variable_data_tbl INV_LABEL.label_tbl_type;
BEGIN
   get_variable_data(
      x_variable_content   => l_variable_data_tbl
   ,  x_msg_count    => x_msg_count
   ,  x_msg_data           => x_msg_data
   ,  x_return_status      => x_return_status
   ,  p_label_type_info => p_label_type_info
   ,  p_transaction_id  => p_transaction_id
   ,  p_input_param     => p_input_param
   ,  p_transaction_identifier=> p_transaction_identifier
   );

   x_variable_content := '';

   FOR i IN 1..l_variable_data_tbl.count() LOOP
      x_variable_content := x_variable_content || l_variable_data_tbl(i).label_content;
   END LOOP;

END get_variable_data;


END INV_LABEL_PVT6;

/
