--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT13
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT13" AS
  /* $Header: INVLA13B.pls 120.5 2006/05/09 21:52:10 rahugupt noship $ */

  label_b    CONSTANT VARCHAR2(50) := '<label';
  label_e    CONSTANT VARCHAR2(50) := '</label>' || fnd_global.local_chr(10);
  variable_b CONSTANT VARCHAR2(50) := '<variable name= "';
  variable_e CONSTANT VARCHAR2(50) := '</variable>' || fnd_global.local_chr(10);
  tag_e      CONSTANT VARCHAR2(50) := '>' || fnd_global.local_chr(10);
  l_debug             NUMBER;

  PROCEDURE TRACE(p_message VARCHAR2) IS
  BEGIN
    inv_label.TRACE(p_message, 'LABEL_INV_13');
  END TRACE;

  PROCEDURE get_variable_data(
    x_variable_content       OUT NOCOPY    inv_label.label_tbl_type
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , x_return_status          OUT NOCOPY    VARCHAR2
  , p_label_type_info        IN            inv_label.label_type_rec
  , p_transaction_id         IN            NUMBER
  , p_input_param            IN            mtl_material_transactions_temp%ROWTYPE
  , p_transaction_identifier IN            NUMBER
  ) IS


--    l_lpn_id                 NUMBER;
    l_transaction_id          NUMBER;
    l_content_lpn_id         NUMBER;
    l_content_item_data      LONG;
    l_selected_fields        inv_label.label_field_variable_tbl_type;
    l_selected_fields_count  NUMBER;
    l_content_rec_index      NUMBER                                  := 0;
    l_label_format_id        NUMBER                                  := 0;
    l_label_format           VARCHAR2(100);
    l_printer                VARCHAR2(30);
    l_printer_sub            VARCHAR2(30)                            := NULL;
    l_api_name               VARCHAR2(20)                     := 'get_variable_data';
    l_return_status          VARCHAR2(240);
    l_error_message          VARCHAR2(240);
    l_msg_count              NUMBER;
    l_api_status             VARCHAR2(240);
    l_msg_data               VARCHAR2(240);

    i                        NUMBER;
	j                        NUMBER;
	k                        NUMBER;

    l_transaction_identifier NUMBER                                  := 0;
    l_label_index            NUMBER;
    l_label_request_id       NUMBER;
    l_prev_format_id         NUMBER;
    l_prev_sub               VARCHAR2(30);
    l_column_name_list       LONG;

    l_label_status VARCHAR2(1);
    l_label_err_msg VARCHAR2(1000);
    l_is_epc_exist VARCHAR2(1) := 'N';

	l_batch_id          gme_batch_header.batch_id%TYPE;
	l_batch_no          gme_batch_header.batch_no%TYPE;
    l_formula_no        fm_form_mst.formula_no%TYPE;
	l_routing_no        gmd_routings.routing_no%TYPE;
	l_creation_date     varchar2(100);
	l_plan_start_date   varchar2(100);
	l_actual_start_date varchar2(100);
	l_due_date 			varchar2(100);
	l_plan_cmplt_date   varchar2(100);
	l_actual_cmplt_date varchar2(100);
	l_batch_close_date  varchar2(100)
	;
    l_organization_code mtl_parameters.organization_code%TYPE;

	l_planned_qty         gme_material_details.plan_qty%TYPE;
    l_uom                 gme_material_details.dtl_um%TYPE;
    l_actual_qty          gme_material_details.plan_qty%TYPE;
	l_material_detail_id  gme_material_details.material_detail_id%TYPE;

	l_item              mtl_system_items_vl.concatenated_segments%TYPE;

    l_quantity               NUMBER;
    l_lot_quantity           NUMBER;
    l_quantity2              NUMBER;
    l_lot_quantity2          NUMBER;

    l_revision               mtl_material_transactions.revision%TYPE;
    l_inventory_item_id      NUMBER;
    l_item_description       VARCHAR2(240)                                  := NULL;
    l_organization_id        NUMBER;
    l_lot_number             VARCHAR2(80);
    l_subinventory           VARCHAR2(30)                                   := NULL;
    l_locator_id             NUMBER;
    l_reason_id              NUMBER;
	l_uom2                   VARCHAR2(3);
	l_reason_name            mtl_transaction_reasons.reason_name%TYPE;
	l_hazard_class           po_hazard_classes.hazard_class%TYPE;
	l_locator                mtl_item_locations_kfv.CONCATENATED_SEGMENTS%TYPE;
	l_count NUMBER;

	l_parent_lot_number  	 VARCHAR2(80);
	l_grade_code         	 VARCHAR2(150);
	l_status             	 MTL_MATERIAL_STATUSES.STATUS_CODE%TYPE;
	l_lot_creation_date  	 VARCHAR2(100);
	l_lot_expiration_date 	 VARCHAR2(100);

	l_print_count			NUMBER;
	l_temp_print_count	 NUMBER;
	l_temp_transaction_id    NUMBER;
	l_reprint				VARCHAR2(10);

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
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

	l_batch_table_type inv_label_pvt13.batch_table_type;

	/* main driving cursor */

	/* dispense pallet QUERY */
	CURSOR c_batch_details (p_batch_id NUMBER) IS
	SELECT
	  mp.organization_id org_id,
	  mp.organization_code organization,
      bh.batch_id,
	  bh.batch_no batch_no,
 	  bh.formula_no formula_no,
	  bh.routing_no routing_no,
      FND_DATE.DATE_TO_DISPLAYDT(bh.creation_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) creation_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.plan_start_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) planned_start_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.actual_start_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) actual_start_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.due_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) due_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.plan_cmplt_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) planned_completion_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.actual_cmplt_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) actual_completion_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.batch_close_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) batch_close_date,
	  msi.CONCATENATED_SEGMENTS item,
	  bl.inventory_item_id item_id,
	  bl.material_detail_id,
	  decode(bh.batch_status, 1, bl.plan_qty, -1, bl.plan_qty, bl.wip_plan_qty) planned_quantity,
	  bl.dtl_um item_uom,
	  bl.actual_qty  actual_quantity,

	  (select batchstep_no || '-' || go.oprn_no
	  	  from gme_batch_steps gbs, gme_batch_step_items gbsi, gmd_operations go
	  	  where gbs.batch_id = bh.batch_id
	  	  and gbsi.batchstep_id = gbs.batchstep_id
	  	  and gbsi.material_detail_id = bl.material_detail_id
	  and go.oprn_id = gbs.oprn_id) batch_line

	  FROM gme_batch_header_vw bh, mtl_parameters mp, gme_material_details bl,
	  mtl_system_items_vl msi
      where bh.batch_id = p_batch_id  AND --  121706
	  bl.organization_id = mp.organization_id AND
	  bh.batch_id = bl.batch_id AND
	  bl.line_type = 1 AND
	  bl.line_no =1 AND
       	  --bl.inventory_item_id=p_inventory_item_id AND
	  bl.organization_id = msi.organization_id AND
	  bl.inventory_item_id = msi.inventory_item_id;



	  /* Cursor Batch Details and Product Lots */
	  CURSOR c_process_products (p_transaction_id NUMBER)
	  IS
	  SELECT
	  mp.organization_code organization,
          mmt.subinventory_code,
	  milk.concatenated_segments LOCATOR,
	  msi.concatenated_segments item,
	  bh.batch_no batch_no,
	  abs(mmt.transaction_quantity) quantity,
	  abs(mtln.transaction_quantity) lot_quantity,
          mmt.transaction_uom,
        abs(mmt.secondary_transaction_quantity) secondary_quantity,
        abs(mtln.secondary_transaction_quantity) lot_quantity2,
	  mmt.secondary_uom_code uom2 ,
	  mtr.reason_name ,
        mmt.organization_id org_id,
	  mmt.inventory_item_id item_id,
	  mmt.locator_id,
	  mmt.reason_id,
        bh.batch_id,
        bh.formula_no formula_no,
	  bh.routing_no routing_no,
      FND_DATE.DATE_TO_DISPLAYDT(bh.creation_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) creation_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.plan_start_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) planned_start_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.actual_start_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) actual_start_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.due_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) due_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.plan_cmplt_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) planned_completion_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.actual_cmplt_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) actual_completion_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.batch_close_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) batch_close_date,
	  bl.material_detail_id,
	  bl.plan_qty planned_quantity,
	  bl.dtl_um item_uom,
	  bl.actual_qty  actual_quantity	,
	  hzc.hazard_class hazard_class,
	  mtln.lot_number,
	  (select batchstep_no || '-' || go.oprn_no
	  from gme_batch_steps gbs, gme_batch_step_items gbsi, gmd_operations go
	  where gbs.batch_id = bh.batch_id
	  and gbsi.batchstep_id = gbs.batchstep_id
	  and gbsi.material_detail_id = bl.material_detail_id
	  and go.oprn_id = gbs.oprn_id) batch_line

	  FROM gme_batch_header_vw bh,
        mtl_parameters mp,
        gme_material_details bl,
	  mtl_system_items_vl msi,
	  mtl_material_transactions  mmt,
        mtl_transaction_lot_numbers mtln,
	  mtl_item_locations_kfv milk,
        mtl_transaction_reasons mtr,
	  po_hazard_classes hzc
      where mmt.transaction_id = p_transaction_id and -- 12409734 and --
	  bh.batch_id = mmt.TRANSACTION_SOURCE_ID  AND --  121706
	  bl.material_detail_id = mmt.TRX_SOURCE_LINE_ID and
	  mmt.organization_id = mp.organization_id AND
	  bh.batch_id = bl.batch_id AND
	  mmt.transaction_id  = mtln.transaction_id(+) and
	  bl.organization_id = msi.organization_id AND
	  bl.inventory_item_id = msi.inventory_item_id and
	  mmt.organization_id = milk.organization_id(+)  and
        mmt.subinventory_code = milk.subinventory_code(+) AND
        mmt.locator_id = milk.inventory_location_id(+) and
	  mmt.reason_id = mtr.reason_id (+) and
	  msi.hazard_class_id = hzc.hazard_class_id (+);

  /* Cursor Batch + Pending Lots */
	  CURSOR c_process_pendingproducts (p_transaction_id NUMBER)
	  IS
	  SELECT
	  mp.organization_code organization,
      'N/A' subinventory_code,
	  'N/A' LOCATOR,
	  msi.concatenated_segments item,
	  bh.batch_no batch_no,
	  abs(gppl.quantity) quantity,
	  abs(gppl.quantity) lot_quantity,
        bl.dtl_um        transaction_uom,
        abs(gppl.secondary_quantity) secondary_quantity,
        abs(gppl.secondary_quantity) lot_quantity2,
	  msi.secondary_uom_code uom2 ,
	  mtr.reason_name ,
        bl.organization_id org_id,
	  bl.inventory_item_id item_id,
	  NULL locator_id,
	  gppl.reason_id,
        bh.batch_id,
        bh.formula_no formula_no,
	  bh.routing_no routing_no,
      FND_DATE.DATE_TO_DISPLAYDT(bh.creation_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) creation_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.plan_start_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) planned_start_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.actual_start_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) actual_start_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.due_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) due_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.plan_cmplt_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) planned_completion_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.actual_cmplt_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) actual_completion_date,
      FND_DATE.DATE_TO_DISPLAYDT(bh.batch_close_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) batch_close_date,
	  bl.material_detail_id,
	  bl.plan_qty planned_quantity,
	  bl.dtl_um item_uom,
	  bl.actual_qty  actual_quantity	,
	  hzc.hazard_class hazard_class,
	  gppl.lot_number,
	  (select batchstep_no || '-' || go.oprn_no
	  from gme_batch_steps gbs, gme_batch_step_items gbsi, gmd_operations go
	  where gbs.batch_id = bh.batch_id
	  and gbsi.batchstep_id = gbs.batchstep_id
	  and gbsi.material_detail_id = bl.material_detail_id
	  and go.oprn_id = gbs.oprn_id) batch_line

	  FROM gme_batch_header_vw bh,
        mtl_parameters mp,
        gme_material_details bl,
	  mtl_system_items_vl msi,
	  gme_pending_product_lots  gppl,
	  po_hazard_classes hzc,
	  mtl_transaction_reasons mtr

      where gppl.PENDING_PRODUCT_LOT_ID= p_transaction_id and -- 12409734 and --
	  bh.batch_id = gppl.batch_id  AND --  121706
	  bl.material_detail_id = gppl.material_detail_id and
	  bh.organization_id = mp.organization_id AND
	  bh.batch_id = bl.batch_id AND
	  bl.organization_id = msi.organization_id AND
	  bl.inventory_item_id = msi.inventory_item_id and
	  msi.hazard_class_id = hzc.hazard_class_id (+) and
	  gppl.reason_id = mtr.reason_id (+);

	cursor c_get_print_history_dispense is
	SELECT dispense_id
	from gmo_material_dispenses
	where batch_id = l_transaction_id;

  BEGIN
    -- Initialize return status as success
    x_return_status      := fnd_api.g_ret_sts_success;
    l_debug              := inv_label.l_debug;
	l_label_status := INV_LABEL.G_SUCCESS;

    IF (l_debug = 1) THEN
      TRACE('**In PVT13: (GMO Label)**');
      TRACE(
           '  Business_flow= '
        || p_label_type_info.business_flow_code
        || ', Transaction ID= '
        || p_transaction_id
        || ', Transaction Identifier= '
        || p_transaction_identifier
      );
    END IF;

    inv_label.get_variables_for_format(
      x_variables                  => l_selected_fields
    , x_variables_count            => l_selected_fields_count
    , p_format_id                  => p_label_type_info.default_format_id
    );

    IF (l_selected_fields_count = 0)
       OR (l_selected_fields.COUNT = 0) THEN
      IF (l_debug = 1) THEN
        TRACE(
             'no fields defined for this format: '
          || p_label_type_info.default_format_id
          || ','
          || p_label_type_info.default_format_name
        );
      END IF;
    --return;
    END IF;

    IF (l_debug = 1) THEN
      TRACE(
           ' Found variable defined for this format, cont = '
        || l_selected_fields_count
      );
      TRACE(' Getting OPM batch header/details...');
    END IF;


	IF p_transaction_id IS NOT NULL
	THEN
     -- txn driven
     i  := 1;
	 j  := 1;
	 k  := 1;
     l_content_rec_index  := 0;
     l_content_item_data  := '';

     l_printer            := p_label_type_info.default_printer;
     l_label_index        := 1;
     l_prev_format_id     := p_label_type_info.default_format_id;
     l_prev_sub           := '####';

	IF (p_label_type_info.business_flow_code = 38 and
	    p_label_type_info.label_type_id = 13) -- Dispense Pallet
	THEN

	  /* get batch_id */
	  select batch_id,inventory_item_id
	  into l_transaction_id,l_inventory_item_id
	  from gmo_material_dispenses
	  where dispense_id = p_transaction_id;

      /* Fetch data for Dispense pallet label types */
      FOR v_batch_details IN c_batch_details(l_transaction_id)
	  LOOP
			 l_batch_table_type(j).organization 		:= v_batch_details.organization;
			 l_batch_table_type(j).subinventory_code 	:= NULL;
			 l_batch_table_type(j).locator 				:= NULL;
			 l_batch_table_type(j).item 	            := v_batch_details.item	;
			 l_batch_table_type(j).batch_no 			:= v_batch_details.batch_no;
			 l_batch_table_type(j).quantity 			:= NULL;
			 l_batch_table_type(j).transaction_uom 		:= NULL;
			 l_batch_table_type(j).secondary_quantity 	:= NULL;
			 l_batch_table_type(j).uom2 				:= NULL;
			 l_batch_table_type(j).reason_name 			:= NULL;
             l_batch_table_type(j).org_id  				:= v_batch_details.org_id;
	         l_batch_table_type(j).item_id 			    := v_batch_details.item_id	;
			 l_batch_table_type(j).locator_id 			:= NULL;
			 l_batch_table_type(j).reason_id 			:= NULL;
             l_batch_table_type(j).batch_id 			:= v_batch_details.batch_id;
    		 l_batch_table_type(j).formula_no   		:= v_batch_details.formula_no;
      	     l_batch_table_type(j).routing_no   		:= v_batch_details.routing_no;
			 l_batch_table_type(j).creation_date 		:= v_batch_details.creation_date;
			 l_batch_table_type(j).planned_start_date   := v_batch_details.planned_start_date;
			 l_batch_table_type(j).actual_start_date    := v_batch_details.actual_start_date	;
			 l_batch_table_type(j).due_date 		    := v_batch_details.due_date	;
			 l_batch_table_type(j).planned_completion_date   := v_batch_details.planned_completion_date	;
			 l_batch_table_type(j).actual_completion_date    := v_batch_details.actual_completion_date	;
			 l_batch_table_type(j).batch_close_date     := v_batch_details.batch_close_date	;
			 l_batch_table_type(j).material_detail_id   := v_batch_details.material_detail_id	;
			 l_batch_table_type(j).planned_quantity     := v_batch_details.planned_quantity	;
			 l_batch_table_type(j).item_uom             := v_batch_details.item_uom	;
			 l_batch_table_type(j).actual_quantity      := v_batch_details.actual_quantity	;
			 l_batch_table_type(j).hazard_class 		:= NULL;
			 l_batch_table_type(j).batch_line        := v_batch_details.batch_line;
			 j :=  j+ 1;
	END LOOP;

	l_print_count := 0;
	l_temp_print_count := 0;

 	open c_get_print_history_dispense;
	loop
	fetch c_get_print_history_dispense into l_temp_transaction_id;
	exit when c_get_print_history_dispense%NOTFOUND;

	l_temp_print_count := 0;

	GMO_LABEL_MGMT_GRP.GET_PRINT_COUNT(
                p_api_version => 1.0,
                p_init_msg_list => FND_API.G_FALSE,
                x_return_status => l_return_status,
                x_msg_count    => l_msg_count,
                x_msg_data     => l_msg_data,
                P_WMS_BUSINESS_FLOW_CODE => p_label_type_info.business_flow_code,
                P_LABEL_TYPE => p_label_type_info.label_type_id,
                P_TRANSACTION_ID => l_temp_transaction_id ,
                P_TRANSACTION_TYPE => p_transaction_identifier,
                x_print_count     => l_temp_print_count
          );
	l_print_count := l_temp_print_count + l_print_count;
	end loop;
	close c_get_print_history_dispense;


	 ELSIF (p_label_type_info.business_flow_code = 39 and
	        p_label_type_info.label_type_id = 14) -- Process Product
	 THEN

               if p_transaction_identifier = INV_LABEL.TRX_ID_MMTT then	 -- process product for transaction lot
	  		/* Fetch data for Process Product label types */
      		FOR v_batch_details IN c_process_products(p_transaction_id)
	  			LOOP
			 		l_batch_table_type(j).organization 	    := v_batch_details.organization;
			 		l_batch_table_type(j).subinventory_code := v_batch_details.subinventory_code;
			 		l_batch_table_type(j).locator 	    := v_batch_details.LOCATOR;
			 		l_batch_table_type(j).item 	          := v_batch_details.item	;
			 		l_batch_table_type(j).batch_no 	    := v_batch_details.batch_no;
			 		l_batch_table_type(j).quantity 	    := v_batch_details.quantity;
			 		l_batch_table_type(j).transaction_uom   := v_batch_details.transaction_uom;
			 		l_batch_table_type(j).secondary_quantity:= v_batch_details.secondary_quantity;
			 		l_batch_table_type(j).uom2 		    := v_batch_details.uom2;
			 		l_batch_table_type(j).reason_name 	    := v_batch_details.reason_name;
                   		l_batch_table_type(j).org_id  	    := v_batch_details.org_id;
 	             		l_batch_table_type(j).item_id 	    := v_batch_details.item_id	;
			 		l_batch_table_type(j).locator_id 	    := v_batch_details.locator_id;
			 		l_batch_table_type(j).reason_id 	    := NULL;
                   		l_batch_table_type(j).batch_id 	    := v_batch_details.batch_id;
    		       		l_batch_table_type(j).formula_no   	    := v_batch_details.formula_no;
      	       		l_batch_table_type(j).routing_no   	    := v_batch_details.routing_no;
			 		l_batch_table_type(j).creation_date     := v_batch_details.creation_date;
			 		l_batch_table_type(j).planned_start_date:= v_batch_details.planned_start_date;
			 		l_batch_table_type(j).actual_start_date := v_batch_details.actual_start_date	;
			 		l_batch_table_type(j).due_date 	    := v_batch_details.due_date	;
			 		l_batch_table_type(j).planned_start_date:= v_batch_details.planned_start_date	;
			 		l_batch_table_type(j).actual_start_date := v_batch_details.actual_start_date	;
			 		l_batch_table_type(j).batch_close_date  := v_batch_details.batch_close_date	;
			 		l_batch_table_type(j).material_detail_id:= v_batch_details.material_detail_id	;
			 		l_batch_table_type(j).planned_quantity  := v_batch_details.planned_quantity	;
			 		l_batch_table_type(j).item_uom          := v_batch_details.item_uom	;
			 		l_batch_table_type(j).actual_quantity   := v_batch_details.actual_quantity	;
			 		l_batch_table_type(j).hazard_class 	    := v_batch_details.hazard_class ;
			 		l_batch_table_type(j).lot_number        := v_batch_details.lot_number;
			 		l_batch_table_type(j).batch_line        := v_batch_details.batch_line;

			 			IF (l_batch_table_type(j).lot_number is not null)
			 			THEN
			 	 			SELECT mln.parent_lot_number, mln.grade_code,
			 	 			FND_DATE.DATE_TO_DISPLAYDT(mln.creation_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) creation_date,
			 	 			FND_DATE.DATE_TO_DISPLAYDT(mln.expiration_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) expiration_date,
                            mms.status_code
			 	 			INTO   l_parent_lot_number, l_grade_code, l_lot_creation_date,
                                                 l_lot_expiration_date, l_status
              	 				FROM mtl_lot_numbers mln, MTL_MATERIAL_STATUSES mms
			 	 			WHERE mln.organization_id = l_batch_table_type(j).org_id AND
			 	 			mln.inventory_item_id = l_batch_table_type(j).item_id AND
				 			mln.lot_number = l_batch_table_type(j).lot_number and
				 			mln.status_id = mms.status_id(+);
			 			END IF;
			 			l_batch_table_type(j).parent_lot_number    := l_parent_lot_number;
	  		 			l_batch_table_type(j).grade_code           := l_grade_code ;
	  		 			l_batch_table_type(j).status               := l_status;
	  		 			l_batch_table_type(j).lot_creation_date    := l_lot_creation_date;
	  		 			l_batch_table_type(j).lot_expiration_date  := l_lot_expiration_date;
			 			l_batch_table_type(j).lot_quantity 	       := v_batch_details.lot_quantity;
			 			l_batch_table_type(j).lot_quantity2 	 := v_batch_details.lot_quantity2;
			 			l_parent_lot_number   := NULL;
                   			l_grade_code 	    := NULL;
			 			l_lot_creation_date   := NULL;
			 			l_lot_expiration_date := NULL;
			 			l_status 		    := NULL;
	 		            	 j :=  j+ 1;
	              END LOOP;
                 ELSE
                 	  		/* Fetch data for Process Product label types for product pending lots*/
      		FOR v_batch_details IN c_process_pendingproducts(p_transaction_id)
	  			LOOP
			 		l_batch_table_type(j).organization 	    := v_batch_details.organization;
			 		l_batch_table_type(j).subinventory_code := v_batch_details.subinventory_code;
			 		l_batch_table_type(j).locator 	    := v_batch_details.LOCATOR;
			 		l_batch_table_type(j).item 	          := v_batch_details.item	;
			 		l_batch_table_type(j).batch_no 	    := v_batch_details.batch_no;
			 		l_batch_table_type(j).quantity 	    := v_batch_details.quantity;
			 		l_batch_table_type(j).transaction_uom   := v_batch_details.transaction_uom;
			 		l_batch_table_type(j).secondary_quantity:= v_batch_details.secondary_quantity;
			 		l_batch_table_type(j).uom2 		    := v_batch_details.uom2;
			 		l_batch_table_type(j).reason_name 	    := v_batch_details.reason_name;
                   		l_batch_table_type(j).org_id  	    := v_batch_details.org_id;
 	             		l_batch_table_type(j).item_id 	    := v_batch_details.item_id	;
			 		l_batch_table_type(j).locator_id 	    := v_batch_details.locator_id;
			 		l_batch_table_type(j).reason_id 	    := NULL;
                   		l_batch_table_type(j).batch_id 	    := v_batch_details.batch_id;
    		       		l_batch_table_type(j).formula_no   	    := v_batch_details.formula_no;
      	       		l_batch_table_type(j).routing_no   	    := v_batch_details.routing_no;
			 		l_batch_table_type(j).creation_date     := v_batch_details.creation_date;
			 		l_batch_table_type(j).planned_start_date:= v_batch_details.planned_start_date;
			 		l_batch_table_type(j).actual_start_date := v_batch_details.actual_start_date	;
			 		l_batch_table_type(j).due_date 	    := v_batch_details.due_date	;
			 		l_batch_table_type(j).planned_start_date:= v_batch_details.planned_start_date	;
			 		l_batch_table_type(j).actual_start_date := v_batch_details.actual_start_date	;
			 		l_batch_table_type(j).batch_close_date  := v_batch_details.batch_close_date	;
			 		l_batch_table_type(j).material_detail_id:= v_batch_details.material_detail_id	;
			 		l_batch_table_type(j).planned_quantity  := v_batch_details.planned_quantity	;
			 		l_batch_table_type(j).item_uom          := v_batch_details.item_uom	;
			 		l_batch_table_type(j).actual_quantity   := v_batch_details.actual_quantity	;
			 		l_batch_table_type(j).hazard_class 	    := v_batch_details.hazard_class ;
			 		l_batch_table_type(j).lot_number        := v_batch_details.lot_number;
			 		l_batch_table_type(j).batch_line        := v_batch_details.batch_line;

			 			IF (l_batch_table_type(j).lot_number is not null)
			 			THEN
                          begin
			 	 			SELECT mln.parent_lot_number, mln.grade_code,
			 	 			FND_DATE.DATE_TO_DISPLAYDT(mln.creation_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) creation_date,
			 	 			FND_DATE.DATE_TO_DISPLAYDT(mln.expiration_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) expiration_date,
                            mms.status_code
			 	 			INTO   l_parent_lot_number, l_grade_code, l_lot_creation_date,
                                                 l_lot_expiration_date, l_status
              	 				FROM mtl_lot_numbers mln, MTL_MATERIAL_STATUSES mms
			 	 			WHERE mln.organization_id = l_batch_table_type(j).org_id AND
			 	 			mln.inventory_item_id = l_batch_table_type(j).item_id AND
				 			mln.lot_number = l_batch_table_type(j).lot_number and
				 			mln.status_id = mms.status_id(+);
                           exception when others then
                              null;
                           end;
			 			END IF;
			 			l_batch_table_type(j).parent_lot_number    := l_parent_lot_number;
	  		 			l_batch_table_type(j).grade_code           := l_grade_code ;
	  		 			l_batch_table_type(j).status               := l_status;
	  		 			l_batch_table_type(j).lot_creation_date    := l_lot_creation_date;
	  		 			l_batch_table_type(j).lot_expiration_date  := l_lot_expiration_date;
			 			l_batch_table_type(j).lot_quantity 	       := v_batch_details.lot_quantity;
			 			l_batch_table_type(j).lot_quantity2 	 := v_batch_details.lot_quantity2;
			 			l_parent_lot_number   := NULL;
                   			l_grade_code 	    := NULL;
			 			l_lot_creation_date   := NULL;
			 			l_lot_expiration_date := NULL;
			 			l_status 		    := NULL;
	 		            	 j :=  j+ 1;
	              END LOOP;
               END IF;
	       GMO_LABEL_MGMT_GRP.GET_PRINT_COUNT(
              	  p_api_version => 1.0,
               	  p_init_msg_list => FND_API.G_FALSE,
                  x_return_status => l_return_status,
                  x_msg_count    => l_msg_count,
                  x_msg_data     => l_msg_data,
                  P_WMS_BUSINESS_FLOW_CODE => p_label_type_info.business_flow_code,
                  P_LABEL_TYPE => p_label_type_info.label_type_id,
                  P_TRANSACTION_ID => p_transaction_id ,
                  P_TRANSACTION_TYPE => p_transaction_identifier,
                  x_print_count     => l_print_count
                );
	 END IF;
 	 l_count := l_batch_table_type.COUNT;

	  if (l_print_count > 0) then
			l_reprint := fnd_message.get_string('GMO', 'GMO_UTIL_YES');
	  else
			l_reprint := fnd_message.get_string('GMO', 'GMO_UTIL_NO');
	  end if;


     FOR k IN 1 .. l_count LOOP

	IF (l_debug = 1) THEN
           TRACE('** in GMO PVT13.get_variable_data ** , start ' || l_label_index  );
           TRACE('** L_COUNT ' || l_batch_table_type.COUNT  );
        END IF;
        IF (l_debug = 1) THEN
               TRACE(
               		 'Organization= '
            		 || l_batch_table_type(k).organization
            		 || ' ,Batch= '
            		 || l_batch_table_type(k).batch_no
            		 || ' ,Item= '
            		 || l_batch_table_type(k).item
          			 );
        END IF;

        l_content_item_data  := '';

        IF (l_debug = 1) THEN
          TRACE(
               'Apply Rules engine for format, printer='
            || l_printer
            || ',manual_format_id= '
            || p_label_type_info.manual_format_id
            || ',manual_format_name= '
            || p_label_type_info.manual_format_name
          );
         END IF;

         -- insert a record into wms_label_requests entity to
         -- call the label rules engine to get appropriate label

         inv_label.get_format_with_rule(
          p_document_id                 => p_label_type_info.label_type_id
         , p_label_format_id            => p_label_type_info.manual_format_id
         , p_organization_id            => l_batch_table_type(k).org_id
         , p_inventory_item_id          => l_batch_table_type(k).item_id
         , p_subinventory_code          => l_batch_table_type(k).subinventory_code
         , p_locator_id                 => l_batch_table_type(k).locator_id
         , p_lpn_id                     => NULL
         , p_lot_number                 => l_batch_table_type(k).lot_number
         , p_revision                   => l_revision
         , p_serial_number              => NULL
         , p_business_flow_code         => p_label_type_info.business_flow_code
         , p_last_update_date           => SYSDATE
         , p_last_updated_by            => fnd_global.user_id
         , p_creation_date              => SYSDATE
         , p_created_by                 => fnd_global.user_id
         , p_printer_name               => l_printer
         , x_return_status              => l_return_status
         , x_label_format_id            => l_label_format_id
         , x_label_format               => l_label_format
         , x_label_request_id           => l_label_request_id
         );

         IF l_return_status <> 'S' THEN
           fnd_message.set_name('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
           fnd_msg_pub.ADD;
           l_label_format     := p_label_type_info.default_format_id;
           l_label_format_id  := p_label_type_info.default_format_name;
		   l_label_status := INV_LABEL.G_ERROR;
         END IF;

         IF (l_label_format_id IS NOT NULL) THEN
           -- Derive the fields for the format either passed in or derived via the rules engine.
           IF l_label_format_id <> NVL(l_prev_format_id, -999) THEN
             IF (l_debug = 1) THEN
               TRACE(' Getting variables for new format '|| l_label_format);
             END IF;

            inv_label.get_variables_for_format(
              x_variables                  => l_selected_fields
            , x_variables_count            => l_selected_fields_count
            , p_format_id                  => l_label_format_id
            );
            l_prev_format_id  := l_label_format_id;

            IF (l_selected_fields_count = 0)
               OR (l_selected_fields.COUNT = 0) THEN
              IF (l_debug = 1) THEN
                TRACE(
                     'no fields defined for this format: '
                  || l_label_format
                  || ','
                  || l_label_format_id
                );
              END IF;

            END IF;

            IF (l_debug = 1) THEN
              TRACE(
                   '   Found selected_fields for format '
                || l_label_format
                || ', num='
                || l_selected_fields_count
              );
            END IF;
          END IF;
         ELSE
          IF (l_debug = 1) THEN
            TRACE('No format exists for this label');
          END IF;
         END IF;

         -- variable header

         l_content_item_data  :=  l_content_item_data || label_b;

         IF l_label_format <> NVL(p_label_type_info.default_format_name, '@@@') THEN
           l_content_item_data  :=    l_content_item_data
                                      || ' _FORMAT="'
                                      || NVL(
                                       p_label_type_info.manual_format_name
                                       , l_label_format
                                       )
                                      || '"';
         END IF;

         IF  (l_printer IS NOT NULL)
            AND (l_printer <> NVL(p_label_type_info.default_printer, '###')) THEN
           l_content_item_data  := l_content_item_data || ' _PRINTERNAME="' || l_printer || '"';
         END IF;

         l_content_item_data  :=  l_content_item_data || tag_e;

         IF (l_debug = 1) THEN
           TRACE('Starting assign variables, ');
         END IF;

         l_column_name_list             :=     'Set variables for ';

        -- CUSTOM SQL
        l_custom_sql_ret_status := FND_API.G_RET_STS_SUCCESS;
        l_CustSqlWarnFlagSet := FALSE;
        l_CustSqlErrFlagSet := FALSE;
        l_CustSqlWarnMsg := NULL;
        l_CustSqlErrMsg := NULL;
        -- CUSTOM SQL


         -- Loop for each selected fields, find the columns and write into the XML_content

         FOR i IN 1 .. l_selected_fields.COUNT LOOP

            IF (l_debug = 1) THEN
                l_column_name_list  := l_column_name_list || ',' || l_selected_fields(i).column_name;
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
              trace('Custom Labels Trace [INVLA13B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
              trace('Custom Labels Trace [INVLA13B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
              trace('Custom Labels Trace [INVLA13B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
              trace('Custom Labels Trace [INVLA13B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
              trace('Custom Labels Trace [INVLA13B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
             END IF;
             l_sql_stmt := l_selected_fields(i).sql_stmt;
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLA13B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
             END IF;
             l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLA13B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);

             END IF;
             BEGIN
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLA13B.pls]: At Breadcrumb 1');
              trace('Custom Labels Trace [INVLA13B.pls]: LABEL_REQUEST_ID     : ' || l_label_request_id);
             END IF;
             OPEN c_sql_stmt FOR l_sql_stmt using l_label_request_id;
             LOOP
                 FETCH c_sql_stmt INTO l_sql_stmt_result;
                 EXIT WHEN c_sql_stmt%notfound OR c_sql_stmt%rowcount >=2;
             END LOOP;

          IF (c_sql_stmt%rowcount=1 AND l_sql_stmt_result IS NULL) THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_custom_sql_ret_status := INV_LABEL.G_WARNING;
                fnd_message.set_name('WMS','WMS_CS_NULL_VALUE_RETURNED');
                fnd_msg_pub.ADD;
                -- Fix for bug: 4179593 Start
                --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                l_CustSqlWarnFlagSet := TRUE;
                -- Fix for bug: 4179593 End
             IF (l_debug = 1) THEN
               trace('Custom Labels Trace [INVLA13B.pls]: At Breadcrumb 2');
               trace('Custom Labels Trace [INVLA13B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
               trace('Custom Labels Trace [INVLA13B.pls]: WARNING: NULL value returned.');
               trace('Custom Labels Trace [INVLA13B.pls]: l_custom_sql_ret_status is set to : ' || l_custom_sql_ret_status);
             END IF;
          ELSIF c_sql_stmt%rowcount=0 THEN
                IF (l_debug = 1) THEN
                 trace('Custom Labels Trace [INVLA13B.pls]: At Breadcrumb 3');
                 trace('Custom Labels Trace [INVLA13B.pls]: WARNING: No row returned by the Custom SQL query');
                END IF;
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_custom_sql_ret_status := INV_LABEL.G_WARNING;
                fnd_message.set_name('WMS','WMS_CS_NO_DATA_FOUND');
                fnd_msg_pub.ADD;
                -- Fix for bug: 4179593 Start
                --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                l_CustSqlWarnFlagSet := TRUE;
                -- Fix for bug: 4179593 End
          ELSIF c_sql_stmt%rowcount>=2 THEN
                IF (l_debug = 1) THEN
                 trace('Custom Labels Trace [INVLA13B.pls]: At Breadcrumb 4');
                 trace('Custom Labels Trace [INVLA13B.pls]: ERROR: Multiple values returned by the Custom SQL query');
                END IF;
                l_sql_stmt_result := NULL;
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_custom_sql_ret_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('WMS','WMS_CS_MULTIPLE_VALUES_RETURN');
                fnd_msg_pub.ADD;
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
                 trace('Custom Labels Trace [INVLA13B.pls]: At Breadcrumb 5');
                trace('Custom Labels Trace [INVLA13B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
              fnd_msg_pub.ADD;
              fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
           IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLA13B.pls]: At Breadcrumb 6');
              trace('Custom Labels Trace [INVLA13B.pls]: Before assigning it to l_content_item_data');
           END IF;
            l_content_item_data  :=   l_content_item_data
                               || variable_b
                               || l_selected_fields(i).variable_name
                               || '">'
                               || l_sql_stmt_result
                               || variable_e;
            l_sql_stmt_result := NULL;
            l_sql_stmt        := NULL;
            IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLA13B.pls]: At Breadcrumb 7');
              trace('Custom Labels Trace [INVLA13B.pls]: After assigning it to l_content_item_data');
              trace('Custom Labels Trace [INVLAP3B.pls]: --------------------------REPORT END-------------------------------------');
            END IF;
------------------------End of this changes for Custom Labels project code--------------------
            ELSIF LOWER(l_selected_fields(i).column_name) = 'batch_no' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).batch_no
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'batch_id' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).batch_id
                                    || variable_e;


            ELSIF LOWER(l_selected_fields(i).column_name) = 'item' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).item
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'transaction_quantity' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).quantity
                                    || variable_e;

          ELSIF LOWER(l_selected_fields(i).column_name) = 'transaction_uom' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).transaction_uom
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'secondary_transaction_quantity' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).secondary_quantity
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'secondary_uom' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).uom2
                                    || variable_e;

          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_quantity' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).lot_quantity
                                    || variable_e;

          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_quantity2' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).lot_quantity2
                                    || variable_e;

          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_status' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).status
                                    || variable_e;


            ELSIF LOWER(l_selected_fields(i).column_name) = 'parent_lot_number' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).parent_lot_number
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_number' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).lot_number
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'organization' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).organization
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_code' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).subinventory_code
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'locator' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).locator
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'reason' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).reason_name
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'routing_no' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).routing_no
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'formula_no' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).formula_no
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'creation_date' THEN
                l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).creation_date
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'planned_start_date' THEN
                l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).planned_start_date
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'actual_start_date' THEN
                l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).actual_start_date
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'due_date' THEN
                l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).due_date
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'planned_completion_date' THEN
                l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).planned_completion_date
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'actual_completion_date' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).actual_completion_date
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'batch_close_date' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).batch_close_date
                                    || variable_e;

			 /* batch material details */

             ELSIF LOWER(l_selected_fields(i).column_name) = 'actual_quantity' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).actual_quantity
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'planned_quantity' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).planned_quantity
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'item_uom' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).item_uom
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_expiration_date' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).lot_expiration_date
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_creation_date' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).lot_creation_date
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'grade_code' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_table_type(k).grade_code
                                    || variable_e;

			 ELSIF LOWER(l_selected_fields(i).column_name) = 'hazard_class' THEN
			                  l_content_item_data  :=    l_content_item_data
			                                     || variable_b
			                                     || l_selected_fields(i).variable_name
			                                     || '">'
			                                     || l_batch_table_type(k).hazard_class
                                    || variable_e;

			 ELSIF LOWER(l_selected_fields(i).column_name) = 'batch_line' THEN
			                  l_content_item_data  :=    l_content_item_data
			                                     || variable_b
			                                     || l_selected_fields(i).variable_name
			                                     || '">'
			                                     || l_batch_table_type(k).batch_line
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'print_count' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_print_count
                                    || variable_e;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'reprint' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_reprint
                                    || variable_e;



             END IF;
         END LOOP; -- l_selected_fields.COUNT

         l_content_item_data := l_content_item_data || label_e;
         x_variable_content(l_label_index).label_content := l_content_item_data;
         x_variable_content(l_label_index).label_request_id := l_label_request_id;
         x_variable_content(l_label_index).label_status  := l_label_status;
         x_variable_content(l_label_index).error_message := l_label_err_msg;


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

        -- We will concatenate the error message from Custom SQL and EPC code.
        x_variable_content(l_label_index).error_message := l_custom_sql_ret_msg || ' ' || l_label_err_msg;
        IF(l_CustSqlWarnFlagSet OR l_CustSqlErrFlagSet) THEN
         x_variable_content(l_label_index).label_status  := l_custom_sql_ret_status;
        END IF;
------------------------End of this changes for Custom Labels project code---------------
         l_label_index := l_label_index + 1;
         l_content_item_data  := '';
         l_label_request_id   := NULL;

------------------------Start of changes for Custom Labels project code------------------
        l_custom_sql_ret_status := NULL;
        l_custom_sql_ret_msg    := NULL;
------------------------End of this changes for Custom Labels project code---------------
         IF (l_debug = 1) THEN
            TRACE(l_column_name_list);
            TRACE(' Finished writing item variables ');
         END IF;

	  IF (l_debug = 1) THEN
	     	 TRACE('x_variable_content.count ' || x_variable_content.count);
	  END IF;

	 END LOOP;
	END IF;

  END get_variable_data;

  PROCEDURE get_variable_data(
    x_variable_content       OUT NOCOPY    LONG
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , x_return_status          OUT NOCOPY    VARCHAR2
  , p_label_type_info        IN            inv_label.label_type_rec
  , p_transaction_id         IN            NUMBER
  , p_input_param            IN            mtl_material_transactions_temp%ROWTYPE
  , p_transaction_identifier IN            NUMBER
  ) IS
    l_variable_data_tbl inv_label.label_tbl_type;
  BEGIN
    get_variable_data(
      x_variable_content           => l_variable_data_tbl
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_return_status              => x_return_status
    , p_label_type_info            => p_label_type_info
    , p_transaction_id             => p_transaction_id
    , p_input_param                => p_input_param
    , p_transaction_identifier     => p_transaction_identifier
    );
    x_variable_content  := '';

    FOR i IN 1 .. l_variable_data_tbl.COUNT() LOOP
      x_variable_content  :=
                     x_variable_content || l_variable_data_tbl(i).label_content;
    END LOOP;

  END get_variable_data;
END inv_label_pvt13;

/
