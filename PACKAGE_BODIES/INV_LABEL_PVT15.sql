--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT15
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT15" AS
  /* $Header: INVLA15B.pls 120.2 2006/05/08 22:46:36 rahugupt noship $ */
  label_b    CONSTANT VARCHAR2(50) := '<label';
  label_e    CONSTANT VARCHAR2(50) := '</label>' || fnd_global.local_chr(10);
  variable_b CONSTANT VARCHAR2(50) := '<variable name= "';
  variable_e CONSTANT VARCHAR2(50) := '</variable>' || fnd_global.local_chr(10);
  tag_e      CONSTANT VARCHAR2(50) := '>' || fnd_global.local_chr(10);
  l_debug             NUMBER;

  PROCEDURE TRACE(p_message VARCHAR2) IS
  BEGIN
    inv_label.TRACE(p_message, 'INV_LABEL_15');
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
    --I cleanup, use l_prev_format_id to record the previous label format
    l_prev_format_id         NUMBER;
    -- I cleanup, user l_prev_sub to record the previous subinventory
    --so that get_printer is not called if the subinventory is the same
    l_prev_sub               VARCHAR2(30);
    -- a list of columns that are selected for format
    l_column_name_list       LONG;
--    l_patch_level NUMBER;


    l_label_status VARCHAR2(1);
    l_label_err_msg VARCHAR2(1000);
    l_is_epc_exist VARCHAR2(1) := 'N';

    l_revision               mtl_material_transactions.revision%TYPE;
	l_organization          mtl_parameters.organization_code%TYPE;
	l_organization_id		NUMBER;

	l_item              	mtl_system_items_vl.concatenated_segments%TYPE;
	l_item_id               NUMBER;
	l_locator_id            NUMBER;

    l_sample_id 			 gmd_samples.sample_id%TYPE;
    l_orgn_code				 mtl_parameters.organization_code%TYPE;
	l_sample_no  			 gmd_samples.sample_no%TYPE;
	l_sample_desc 		 	 gmd_samples.sample_desc%TYPE;
	l_sample_qty        	 gmd_samples.sample_qty%TYPE;
	l_sample_uom        	 gmd_samples.sample_qty_uom%TYPE;
	l_retain_as				 gmd_samples.retain_as%TYPE;
	l_priority 				 gmd_samples.priority%TYPE;
	l_source 				 varchar2(100);
	l_subinventory           gmd_samples.subinventory%TYPE;
	l_lot_expiry        	 varchar2(100);
	l_lot_manufacturing_dat  varchar2(100);
    l_sample_expirt			 varchar2(100);
	l_lot_number             gmd_samples.lot_number%TYPE;
	l_parent_lot_number      gmd_samples.parent_lot_number%TYPE;
    l_qc_lab_orgn_code       gmd_samples.qc_lab_orgn_code%TYPE;
    l_sample_instant         gmd_samples.instance_id%TYPE;

	l_batch_no               gme_batch_header.batch_no%TYPE;
	l_formula_no             fm_form_mst_b.formula_no%TYPE;
	l_oprn_no  	             gmd_operations.oprn_no%TYPE;
	l_recipe_no		         gmd_recipes_b.recipe_no%TYPE;
	l_routing_no 		     gmd_routings_b.routing_no%TYPE;

	l_item_description		 mtl_system_items_vl.description%type;
	l_sample_disposition     varchar2(100);
	l_date_drawn			 varchar2(100);
	l_sample_instance		 gmd_samples.sample_instance%type;
	l_print_count			 NUMBER;
	l_reprint				 VARCHAR2(10);

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

	CURSOR c_sample_details IS
		SELECT
	    para.ORGANIZATION_CODE,
		msi.Concatenated_segments,
        gsmp.sample_id,
		para.organization_code,
		gsmp.sample_no,
		gsmp.sample_desc,
		gsmp.inventory_item_id,
		gsmp.sample_qty,
		gsmp.sample_qty_uom,
		gsmp.retain_as,
		gsmp.priority,
		(select meaning from gem_lookups where lookup_type='GMD_QC_SOURCE' and lookup_code=gsmp.source) source,
		gsmp.subinventory,
		gsmp.parent_lot_number,
		gsmp.lot_number,
		FND_DATE.DATE_TO_DISPLAYDT(mln.expiration_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) lot_expiry,
		FND_DATE.DATE_TO_DISPLAYDT(mln.creation_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) lot_manufacturing_date,
		FND_DATE.DATE_TO_DISPLAYDT(gsmp.expiration_date, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) sample_expirt,
		para2.organization_code qc_lab_orgn_code,
		gsmp.instance_id sample_instant,
		batchheader.batch_no,
		formulamst.formula_no,
		operations.oprn_no,
		recipes.recipe_no,
		routings.routing_no ,
	    gsmp.organization_id,
	    msi.description item_description,
	    (select lkups.meaning from gem_lookups lkups, gmd_sample_spec_disp disp where disp.sample_id=gsmp.sample_id and lookup_type='GMD_QC_SAMPLE_DISP' and lookup_code=disp.disposition) sample_disposition,
	    FND_DATE.DATE_TO_DISPLAYDT(gsmp.date_drawn, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE) date_drawn,
	    gsmp.sample_instance

		from gmd_samples gsmp, mtl_lot_numbers mln,
		     fm_form_mst_b formulamst , gme_batch_header batchheader ,
			 gmd_operations operations , gmd_recipes_b recipes ,
			 gmd_routings_b routings , mtl_parameters para,
			 mtl_system_items_vl msi, mtl_parameters para2
		where
		gsmp.sample_id = p_transaction_id AND
		gsmp.inventory_item_id = mln.inventory_item_id(+) and
		gsmp.organization_id = mln.organization_id (+)and
		gsmp.organization_id = para.organization_id AND
		gsmp.lot_number = mln.lot_number(+) and
	    gsmp.inventory_item_id = msi.inventory_item_id  AND
	    gsmp.organization_id = msi.organization_id  AND
	    gsmp.lab_organization_id = para2.organization_id AND
        gsmp.batch_id = batchheader.batch_id(+) and
        gsmp.formula_id = formulamst.formula_id(+) and
        gsmp.oprn_id = operations.oprn_id(+) and
        gsmp.recipe_id = recipes.recipe_id(+) and
        gsmp.routing_id = routings.routing_id(+);


  BEGIN
    -- Initialize return status as success
    x_return_status      := fnd_api.g_ret_sts_success;
    l_debug              := inv_label.l_debug;
	l_label_status := INV_LABEL.G_SUCCESS;

    IF (l_debug = 1) THEN
      TRACE('*****  In PVT15: ***********');
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
      TRACE(' Getting Sample data...');
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
      	   TRACE('** in PVT15.get_variable_data ** , start ' || l_label_index  );
     END IF;

	 OPEN c_sample_details ;

	 IF c_sample_details%NOTFOUND
	 THEN
	 	 IF (l_debug = 1) THEN
      	   	TRACE('No data found .. Sample details' );
      	   	close c_sample_details ;
		   	Return;
     	 END IF;
	 ELSE
 	 	 IF (l_debug = 1) THEN
      	   	TRACE('Found data for Sample  details '  );
     	 END IF;
	 END IF;


	 FETCH c_sample_details  into
	    l_organization ,
		l_item,
	    l_sample_id,
	    l_orgn_code,
		l_sample_no,
		l_sample_desc,
		l_item_id,
		l_sample_qty,
		l_sample_uom,
		l_retain_as,
		l_priority,
		l_source,
		l_subinventory,
		l_parent_lot_number,
		l_lot_number,
		l_lot_expiry,
		l_lot_manufacturing_dat,
	    l_sample_expirt,
	    l_qc_lab_orgn_code,
	    l_sample_instant,
		l_batch_no,
		l_formula_no,
		l_oprn_no,
		l_recipe_no,
		l_routing_no,
		l_organization_id,
		l_item_description,
		l_sample_disposition,
		l_date_drawn,
		l_sample_instance;


        IF (l_debug = 1) THEN
               TRACE(
               		 'Organization= '
            		 || l_organization
            		 || ' ,Sample No= '
            		 || l_sample_no
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
           p_document_id                => p_label_type_info.label_type_id
         , p_label_format_id            =>  p_label_type_info.manual_format_id
         , p_organization_id            => l_organization_id
         , p_inventory_item_id          => l_item_id
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
              trace('Custom Labels Trace [INVLA15B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
              trace('Custom Labels Trace [INVLA15B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
              trace('Custom Labels Trace [INVLA15B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
              trace('Custom Labels Trace [INVLA15B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
              trace('Custom Labels Trace [INVLA15B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
             END IF;
             l_sql_stmt := l_selected_fields(i).sql_stmt;
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLA15B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
             END IF;
             l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLA15B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);

             END IF;
             BEGIN
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLA15B.pls]: At Breadcrumb 1');
              trace('Custom Labels Trace [INVLA15B.pls]: LABEL_REQUEST_ID     : ' || l_label_request_id);
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
               trace('Custom Labels Trace [INVLA15B.pls]: At Breadcrumb 2');
               trace('Custom Labels Trace [INVLA15B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
               trace('Custom Labels Trace [INVLA15B.pls]: WARNING: NULL value returned.');
               trace('Custom Labels Trace [INVLA15B.pls]: l_custom_sql_ret_status is set to : ' || l_custom_sql_ret_status);
             END IF;
          ELSIF c_sql_stmt%rowcount=0 THEN
                IF (l_debug = 1) THEN
                 trace('Custom Labels Trace [INVLA15B.pls]: At Breadcrumb 3');
                 trace('Custom Labels Trace [INVLA15B.pls]: WARNING: No row returned by the Custom SQL query');
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
                 trace('Custom Labels Trace [INVLA15B.pls]: At Breadcrumb 4');
                 trace('Custom Labels Trace [INVLA15B.pls]: ERROR: Multiple values returned by the Custom SQL query');
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
                 trace('Custom Labels Trace [INVLA15B.pls]: At Breadcrumb 5');
                trace('Custom Labels Trace [INVLA15B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
              fnd_msg_pub.ADD;
              fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
           IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLA15B.pls]: At Breadcrumb 6');
              trace('Custom Labels Trace [INVLA15B.pls]: Before assigning it to l_content_item_data');
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
              trace('Custom Labels Trace [INVLA15B.pls]: At Breadcrumb 7');
              trace('Custom Labels Trace [INVLA15B.pls]: After assigning it to l_content_item_data');
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
            ELSIF LOWER(l_selected_fields(i).column_name) = 'sample_no' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_sample_no
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'sample_desc' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_sample_desc
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'orgn_code' THEN
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

            ELSIF LOWER(l_selected_fields(i).column_name) = 'item' THEN
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

           ELSIF LOWER(l_selected_fields(i).column_name) = 'parent_lot_number' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_parent_lot_number
                                    || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'sample_qty' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_sample_qty
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'sample_uom' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_sample_uom
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'retain_as' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_retain_as
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'priority' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_priority
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'source' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_source
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_expiry' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_lot_expiry
                                    || variable_e;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_manufacturing_date' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_lot_manufacturing_dat
                                    || variable_e;
           ELSIF LOWER(l_selected_fields(i).column_name) = 'sample_expiry' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_sample_expirt
                                    || variable_e;
           ELSIF LOWER(l_selected_fields(i).column_name) = 'qc_lab_orgn' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_qc_lab_orgn_code
                                    || variable_e;
           ELSIF LOWER(l_selected_fields(i).column_name) = 'sample_instant' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_sample_instant
                                    || variable_e;
           ELSIF LOWER(l_selected_fields(i).column_name) = 'formula_no' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_formula_no
                                    || variable_e;
           ELSIF LOWER(l_selected_fields(i).column_name) = 'oprn_no' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_oprn_no
                                    || variable_e;
           ELSIF LOWER(l_selected_fields(i).column_name) = 'recipe_no' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_recipe_no
                                    || variable_e;
           ELSIF LOWER(l_selected_fields(i).column_name) = 'routing_no' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_routing_no
                                    || variable_e;

           ELSIF LOWER(l_selected_fields(i).column_name) = 'sample_id' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_sample_id
                                    || variable_e;

           ELSIF LOWER(l_selected_fields(i).column_name) = 'item_desc' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_item_description
                                    || variable_e;

           ELSIF LOWER(l_selected_fields(i).column_name) = 'disposition' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_sample_disposition
                                    || variable_e;

           ELSIF LOWER(l_selected_fields(i).column_name) = 'date_drawn' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_date_drawn
                                    || variable_e;

           ELSIF LOWER(l_selected_fields(i).column_name) = 'sample_instance' THEN
                 l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_sample_instance
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

	  close c_sample_details;
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
END inv_label_pvt15;

/
