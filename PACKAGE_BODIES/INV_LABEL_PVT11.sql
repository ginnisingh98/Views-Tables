--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT11
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT11" AS
  /* $Header: INVLA11B.pls 120.2 2006/05/08 22:39:38 rahugupt noship $ */

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

	l_organization      mtl_parameters.organization_code%TYPE;

	l_item              		mtl_system_items_vl.concatenated_segments%TYPE;
	l_source_container_item 	mtl_system_items_vl.concatenated_segments%TYPE;
	l_target_container_item   	mtl_system_items_vl.concatenated_segments%TYPE;
	l_dispensed_container       mtl_system_items_vl.concatenated_segments%TYPE;
	l_material_container       mtl_system_items_vl.concatenated_segments%TYPE;

    l_quantity               NUMBER                                           := 0;
    l_revision               mtl_material_transactions.revision%TYPE;
    l_item_description       VARCHAR2(240)                                  := NULL;
    l_locator_id             NUMBER;
    l_quantity2              NUMBER;
    l_reason_id              NUMBER;
	l_uom2                   VARCHAR2(3);


	l_locator                mtl_item_locations_kfv.CONCATENATED_SEGMENTS%TYPE;
	l_count NUMBER;

	l_dispense_id  			 gmo_material_dispenses.dispense_id%TYPE;
	l_dispense_source		 gmo_material_dispenses.dispense_source%TYPE;
	l_dispense_number        gmo_material_dispenses.dispense_number%TYPE;
	l_dispense_type			 gmo_material_dispenses.dispense_type%TYPE;
	l_batchstep_no           gme_batch_steps.batchstep_no%TYPE;
	l_oprn_no                gmd_operations.oprn_no%TYPE;
	l_inventory_item_id 	 gmo_material_dispenses.inventory_item_id%TYPE;
	l_organization_id        gmo_material_dispenses.organization_id%TYPE;
	l_subinventory           gmo_material_dispenses.subinventory_code%TYPE;
	l_security_code          gmo_material_dispenses.security_code%TYPE;
	l_dispense_uom           gmo_material_dispenses.dispense_uom%TYPE;
	l_undispense_uom         gmo_material_dispenses.dispense_uom%TYPE;
	l_dispensed_date         varchar2(100);
	l_mode         			 varchar2(100);
	l_required_qty           gmo_material_dispenses.required_qty%TYPE;
	l_dispensed_qty          gmo_material_dispenses.dispensed_qty%TYPE;

	l_gross_required_weight  gmo_material_dispenses.gross_required_weight%TYPE;
	l_source_container_tare  gmo_material_dispenses.source_container_tare%TYPE;
	l_source_container_weight gmo_material_dispenses.source_container_weight%TYPE;
	l_source_container_reweight   gmo_material_dispenses.source_container_reweight%TYPE;
	l_actual_gross_weight       gmo_material_dispenses.actual_gross_weight%TYPE;
	l_target_container_tare     gmo_material_dispenses.target_container_tare%TYPE;
	l_source_container_item_id  gmo_material_dispenses.source_container_item_id%TYPE;
	l_target_container_item_id  gmo_material_dispenses.target_container_item_id%TYPE;

	l_lot_number                gmo_material_dispenses.lot_number%TYPE;
	l_hazard_class              po_hazard_classes.hazard_class%TYPE;

	/*** undispense ****/
	l_undispense_id				  gmo_material_undispenses.undispense_id%TYPE;
	l_undispense_number			  gmo_material_undispenses.undispense_number%TYPE;
	l_undispense_type			  gmo_material_undispenses.undispense_type%TYPE;
	l_undispensed_date			  varchar2(100);
	l_undispensed_qty			  gmo_material_undispenses.undispensed_qty%TYPE;
	l_undispense_source		 	  gmo_material_dispenses.dispense_source%TYPE;


	l_material_qty 				NUMBER;
    l_negation_qty			    NUMBER;

	l_print_count			 NUMBER;
	l_reprint				 VARCHAR2(10);
	l_parent_lot_number		 mtl_lot_numbers.parent_lot_number%TYPE;

	l_dispensing_mode		 varchar2(100);
	l_undispensing_mode		 varchar2(100);
	l_batch_line			 varchar2(100);


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


	/* main driving cursor */

	CURSOR c_dispense_details IS
	SELECT
	mp.ORGANIZATION_CODE,
	d.dispense_id,
	d.dispense_source,
	d.dispense_number,
	d.dispense_type,
	bh.batch_no,
	bs.batchstep_no,
	gop.oprn_no,
	msi.concatenated_segments  dispense_item,
	d.organization_id,
	d.subinventory_code,
	d.security_code,
	d.dispense_uom,
	FND_DATE.DATE_TO_DISPLAYDT(d.dispensed_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) dispensed_date,
	d.dispensing_mode,
	d.required_qty,
	d.dispensed_qty,
	d.gross_required_weight,
	d.source_container_tare,
	d.source_container_weight,
	d.source_container_reweight,
	d.actual_gross_weight,
	d.target_container_tare,
	d.source_container_item_id,
	d.target_container_item_id,
	d.lot_number,
	hzc.hazard_class,
	d.inventory_item_id
	from
	gmo_material_dispenses d, gme_batch_header bh,
	gme_batch_steps bs, mtl_parameters mp, gmd_operations  gop,
	mtl_system_items_vl msi, po_hazard_classes hzc
	where d.dispense_id = p_transaction_id AND
	d.batch_id = bh.batch_id AND
	d.organization_id = mp.organization_id AND
	d.batch_step_id = bs.batchstep_id(+) AND
	d.inventory_item_id = msi.inventory_item_id  AND
	d.organization_id = msi.organization_id  AND
	bs.oprn_id = gop.oprn_id(+) AND
	msi.hazard_class_id = hzc.hazard_class_id (+);

    /* undispense cursor */
	CURSOR c_undispense_details IS
	SELECT
	mp.ORGANIZATION_CODE,
	d.dispense_id,
	d.dispense_source,
	und.undispense_number,
	und.undispense_type,
	bh.batch_no,
	bs.batchstep_no,
	gop.oprn_no,
	msi.concatenated_segments  dispense_item,
	und.organization_id,
	und.subinventory_code,
	und.security_code,
	und.dispense_uom,
	FND_DATE.DATE_TO_DISPLAYDT(und.undispensed_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) undispensed_date,
	und.undispensing_mode,
	d.required_qty,
	und.dispensed_qty,
	und.gross_required_weight,
	und.source_container_tare,
	und.source_container_weight,
	und.source_container_reweight,
	und.actual_gross_weight,
	und.target_container_tare,
	und.source_container_item_id,
	und.target_container_item_id,
	und.lot_number,
	hzc.hazard_class,
	und.undispense_id,
	(nvl(und.undispensed_qty,0) + nvl(und.material_loss,0)) undispensed_qty,
	und.inventory_item_id
	from
	gmo_material_dispenses d, gme_batch_header bh,
	gme_batch_steps bs, mtl_parameters mp, gmd_operations  gop,
	mtl_system_items_vl msi, po_hazard_classes hzc , gmo_material_undispenses und
	where  und.undispense_id = p_transaction_id AND
	und.dispense_id = d.dispense_id AND
	und.batch_id = bh.batch_id AND
	und.organization_id = mp.organization_id AND
	und.batch_step_id = bs.batchstep_id(+) AND
	und.inventory_item_id = msi.inventory_item_id  AND
	und.organization_id = msi.organization_id  AND
	bs.oprn_id = gop.oprn_id(+) AND
	msi.hazard_class_id = hzc.hazard_class_id (+);


	cursor c_get_mode_meaning is select meaning from fnd_lookups where lookup_type='GMO_DISPENSE_MODE' and lookup_code=l_mode;

  BEGIN
    -- Initialize return status as success
    x_return_status      := fnd_api.g_ret_sts_success;
    l_debug              := inv_label.l_debug;
	l_label_status := INV_LABEL.G_SUCCESS;

    IF (l_debug = 1) THEN
      TRACE('*****  In PVT11: (GMO Label) ***********');
      TRACE(
           '  Business_flow= '
        || p_label_type_info.business_flow_code
        || ', Transaction ID= '
        || p_transaction_id
        || ', Transaction Identifier= '
        || p_transaction_identifier
		|| ', Label Type ID= '
		|| p_label_type_info.label_type_id
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
      TRACE(' Getting GMO Dispense data...');
    END IF;


	IF p_transaction_id IS NOT NULL
	THEN
     -- txn driven
     i  := 1;
     l_content_rec_index  := 0;
     l_content_item_data  := '';

     l_printer            := p_label_type_info.default_printer;
     l_label_index        := 1;
     l_prev_format_id     := p_label_type_info.default_format_id;
     l_prev_sub           := '####';


	 IF (l_debug = 1) THEN
      	   TRACE('** in GMO PVT11.get_variable_data ** , start ' || l_label_index  );
     END IF;

	 if (p_transaction_identifier = inv_label.TRX_ID_DIS)
	 THEN

	 	 OPEN c_dispense_details;

	 	 IF c_dispense_details%NOTFOUND
	 	 THEN
	 	   IF (l_debug = 1) THEN
      	   	TRACE('** Did NOT find and Dispense details ..' );
			close c_dispense_details;
		   	Return;
     	  END IF;
	 	 ELSE
 	 	   IF (l_debug = 1) THEN
      	   	TRACE('** Found data for Dispense details '  );
     	  END IF;
	 	 END IF;



	 	 FETCH c_dispense_details into
	      		l_organization ,
	    		l_dispense_id,
				l_dispense_source,
				l_dispense_number,
				l_dispense_type,
				l_batch_no,
				l_batchstep_no,
				l_oprn_no,
				l_item ,
				l_organization_id,
				l_subinventory,
				l_security_code,
				l_dispense_uom,
				l_dispensed_date,
				l_mode,
				l_required_qty,
				l_dispensed_qty,
				l_gross_required_weight,
				l_source_container_tare,
				l_source_container_weight,
				l_source_container_reweight,
				l_actual_gross_weight,
				l_target_container_tare,
				l_source_container_item_id,
				l_target_container_item_id,
				l_lot_number,
				l_hazard_class,
				l_inventory_item_id;
		close c_dispense_details;

		ELSIF (p_transaction_identifier = inv_label.TRX_ID_UNDIS) -- UNDISPENSIN transaction
		THEN
	 	 OPEN c_undispense_details;

	 	 IF c_undispense_details%NOTFOUND
	 	 THEN
	 	   IF (l_debug = 1) THEN
      	   	TRACE('Did NOT find and Dispense details ..' );
			close c_undispense_details;
		   	Return;
     	  END IF;
	 	 ELSE
 	 	   IF (l_debug = 1) THEN
      	   	TRACE('Found data for Dispense details'  );
     	  END IF;
	 	 END IF;

	 	 FETCH c_undispense_details into
	      		l_organization ,
	    		l_dispense_id,
				l_undispense_source,
				l_undispense_number,
				l_undispense_type,
				l_batch_no,
				l_batchstep_no,
				l_oprn_no,
				l_item ,
				l_organization_id,
				l_subinventory,
				l_security_code,
				l_undispense_uom,
				l_undispensed_date,
				l_mode,
				l_required_qty,
				l_dispensed_qty,
				l_gross_required_weight,
				l_source_container_tare,
				l_source_container_weight,
				l_source_container_reweight,
				l_actual_gross_weight,
				l_target_container_tare,
				l_source_container_item_id,
				l_target_container_item_id,
				l_lot_number,
				l_hazard_class,
				l_undispense_id	,
				l_undispensed_qty,
				l_inventory_item_id;

		close c_undispense_details;
	    END IF;

		/* source_container_item */
		IF l_source_container_item_id IS NOT NULL
		THEN
			Select concatenated_segments
			INTO  l_source_container_item
			from mtl_system_items_vl
			where organization_id = l_organization_id AND
			inventory_item_id = l_source_container_item_id;
		END IF;

        /* target_container_item */
		IF l_target_container_item_id IS NOT NULL
		THEN
           Select concatenated_segments
		   INTO  l_target_container_item
		   from mtl_system_items_vl
		   where organization_id = l_organization_id AND
		   inventory_item_id = l_target_container_item_id;
		END IF;

		if (l_batchstep_no is not null)
		then
			l_batch_line := l_batchstep_no || '-' || l_oprn_no;
		end if;

		/* dispensed container/material LOGIC */

		IF ( p_label_type_info.label_type_id = 11)
		-- Process Material label
		THEN
			if (p_transaction_identifier = inv_label.TRX_ID_DIS)
		 	then

		 		open c_get_mode_meaning;
		 		fetch c_get_mode_meaning into l_dispensing_mode;
		 		close c_get_mode_meaning;

				IF (l_mode = 'FULL_CONTAINER')
				THEN
					l_actual_gross_weight := NULL;
					l_material_container := NULL;

				ELSIF (l_mode = 'TARGET_CONTAINER')
				THEN
					-- l_actual_gross_weight; use db value
					l_material_container := l_source_container_item;
					l_material_qty := l_source_container_reweight - l_source_container_tare;
					l_dispensed_container := l_target_container_item;

				ELSIF (l_mode = 'SOURCE_CONTAINER')
				THEN
					l_material_container := l_target_container_item;
    				l_material_qty := l_actual_gross_weight - l_target_container_tare;
    				l_dispensed_container := l_source_container_item;
				END IF;

			ELSIF (p_transaction_identifier = inv_label.TRX_ID_UNDIS)
		 	THEN
		 		open c_get_mode_meaning;
		 		fetch c_get_mode_meaning into l_undispensing_mode;
		 		close c_get_mode_meaning;

				IF (l_mode = 'FULL_CONTAINER')
				THEN
					l_material_container := l_source_container_item;
					l_dispensed_container := NULL;
					l_actual_gross_weight := l_source_container_weight;
					l_material_qty := l_source_container_weight - l_source_container_tare;

				ELSIF (l_mode = 'TARGET_CONTAINER')
				THEN
					-- l_actual_gross_weight; use db value
					l_material_container := l_target_container_item;
					l_material_qty := l_actual_gross_weight - l_target_container_tare;
					l_dispensed_container := l_source_container_item;

				ELSIF (l_mode = 'SOURCE_CONTAINER')
				THEN
					NULL; -- this mode is not applicable for reverse dispense

				END IF;

  		    END IF;

		ELSIF ( p_label_type_info.label_type_id = 12) -- dispense material label
		THEN

			if (p_transaction_identifier = inv_label.TRX_ID_DIS)
			then
				open c_get_mode_meaning;
				fetch c_get_mode_meaning into l_dispensing_mode;
				close c_get_mode_meaning;

				IF (l_mode = 'TARGET_CONTAINER')
				THEN
					l_dispensed_container := l_target_container_item;

				ELSIF (l_mode in ('SOURCE_CONTAINER', 'FULL_CONTAINER'))
				THEN
					-- l_actual_gross_weight; use db value
					l_dispensed_container := l_source_container_item;
				END IF;


				/* dispense qty */
				l_dispensed_qty := GMO_DISPENSE_PVT.GET_NET_DISP_DISPENSED_QTY (P_DISPENSE_ID => l_dispense_id);


			ELSIF (p_transaction_identifier = inv_label.TRX_ID_UNDIS)
			THEN
				-- UNDISPENSIN transaction

				open c_get_mode_meaning;
				fetch c_get_mode_meaning into l_undispensing_mode;
				close c_get_mode_meaning;


				IF (l_mode = 'FULL_CONTAINER')
				THEN
					-- l_actual_gross_weight; use db value
					l_dispensed_container := l_source_container_item;

				ELSIF (l_mode = 'TARGET_CONTAINER')
				THEN
					l_dispensed_container := l_source_container_item;

				ELSIF (l_mode = 'SOURCE_CONTAINER')
				THEN
					NULL; -- this mode is not applicable for reverse dispense

				END IF;


			END IF;

		END IF;


		IF (l_lot_number is not null)
		THEN
			SELECT parent_lot_number
			into l_parent_lot_number
			FROM mtl_lot_numbers
			WHERE organization_id = l_organization_id
			AND inventory_item_id = l_inventory_item_id
			AND lot_number = l_lot_number;
		END IF;


        IF (l_debug = 1) THEN
               TRACE(
               		 'Organization= '
            		 || l_organization
            		 || ' ,Batch= '
            		 || l_batch_no
            		 || ' ,Item= '
            		 || l_item
          			 );
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

	  if (l_print_count > 0) then
	  		l_reprint := fnd_message.get_string('GMO', 'GMO_UTIL_YES');
	  else
	  		l_reprint := fnd_message.get_string('GMO', 'GMO_UTIL_NO');
	  end if;


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
         , p_organization_id            => l_organization_id
         , p_inventory_item_id          => l_inventory_item_id
         , p_subinventory_code          => l_subinventory
         , p_locator_id                 => l_locator_id
         , p_lpn_id                     => NULL
         , p_lot_number                 => l_lot_number
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
              trace('Custom Labels Trace [INVLA11B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
              trace('Custom Labels Trace [INVLA11B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
              trace('Custom Labels Trace [INVLA11B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
              trace('Custom Labels Trace [INVLA11B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
              trace('Custom Labels Trace [INVLA11B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
             END IF;
             l_sql_stmt := l_selected_fields(i).sql_stmt;
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP13B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
             END IF;
             l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP13B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);

             END IF;
             BEGIN
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLA11B.pls]: At Breadcrumb 1');
              trace('Custom Labels Trace [INVLA11B.pls]: LABEL_REQUEST_ID     : ' || l_label_request_id);
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
               trace('Custom Labels Trace [INVLA11B.pls]: At Breadcrumb 2');
               trace('Custom Labels Trace [INVLA11B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
               trace('Custom Labels Trace [INVLA11B.pls]: WARNING: NULL value returned.');
               trace('Custom Labels Trace [INVLA11B.pls]: l_custom_sql_ret_status is set to : ' || l_custom_sql_ret_status);
             END IF;
          ELSIF c_sql_stmt%rowcount=0 THEN
                IF (l_debug = 1) THEN
                 trace('Custom Labels Trace [INVLA11B.pls]: At Breadcrumb 3');
                 trace('Custom Labels Trace [INVLA11B.pls]: WARNING: No row returned by the Custom SQL query');
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
                 trace('Custom Labels Trace [INVLA11B.pls]: At Breadcrumb 4');
                 trace('Custom Labels Trace [INVLA11B.pls]: ERROR: Multiple values returned by the Custom SQL query');
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
                 trace('Custom Labels Trace [INVLA11B.pls]: At Breadcrumb 5');
                trace('Custom Labels Trace [INVLA11B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
              fnd_msg_pub.ADD;
              fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
           IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLA11B.pls]: At Breadcrumb 6');
              trace('Custom Labels Trace [INVLA11B.pls]: Before assigning it to l_content_item_data');
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
              trace('Custom Labels Trace [INVLA11B.pls]: At Breadcrumb 7');
              trace('Custom Labels Trace [INVLA11B.pls]: After assigning it to l_content_item_data');
           trace('Custom Labels Trace [INVLAP3B.pls]: --------------------------REPORT END-------------------------------------');
            END IF;
------------------------End of this changes for Custom Labels project code--------------------
            ELSIF LOWER(l_selected_fields(i).column_name) = 'batch_no' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_no
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'oprn_no' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_batch_line
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'dispensing_item' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_item
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_number' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_lot_number
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'organization_code' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_organization
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_code' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_subinventory
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'dispense_source' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_dispense_source
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'dispense_number' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_dispense_number
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'dispense_type' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_dispense_type
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'dispense_id' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_dispense_id
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'dispense_uom' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_dispense_uom
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'dispensed_date' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_dispensed_date
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'dispensing_mode' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_dispensing_mode
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'required_qty' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_required_Qty
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'dispensed_qty' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_dispensed_qty
                                    || variable_e;


            ELSIF LOWER(l_selected_fields(i).column_name) = 'gross_required_weight' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_gross_required_weight
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'source_container_tare' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_source_container_tare
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'source_container_weight' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_source_container_weight
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'source_container_reweight' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_source_container_reweight
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'actual_gross_weight' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_actual_gross_weight
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'target_container_tare' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_target_Container_tare
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'source_container_item' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_source_container_item
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'target_container_item' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_target_container_item
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'hazard_class' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_hazard_class
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'dispensed_container' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_dispensed_container
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'dispense_container' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_dispensed_container
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'material_container' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_material_container
                                    || variable_e;
           ELSIF LOWER(l_selected_fields(i).column_name) = 'material_quantity' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_material_qty
                                    || variable_e;

           ELSIF LOWER(l_selected_fields(i).column_name) = 'undispense_number' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_undispense_number
                                    || variable_e;
           ELSIF LOWER(l_selected_fields(i).column_name) = 'undispense_type' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_undispense_type
                                    || variable_e;
           ELSIF LOWER(l_selected_fields(i).column_name) = 'undispensed_date' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_undispensed_date
                                    || variable_e;
           ELSIF LOWER(l_selected_fields(i).column_name) = 'undispensed_qty' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_undispensed_qty
                                    || variable_e;

           ELSIF LOWER(l_selected_fields(i).column_name) = 'undispensing_mode' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_undispensing_mode
                                    || variable_e;

           ELSIF LOWER(l_selected_fields(i).column_name) = 'undispense_uom' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_undispense_uom
                                    || variable_e;

           ELSIF LOWER(l_selected_fields(i).column_name) = 'undispense_id' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_undispense_id
                                    || variable_e;

           ELSIF LOWER(l_selected_fields(i).column_name) = 'undispense_source' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_undispense_source
                                    || variable_e;

           ELSIF LOWER(l_selected_fields(i).column_name) = 'parent_lot_number' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_parent_lot_number
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
	  end if;
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
END inv_label_pvt11;

/
