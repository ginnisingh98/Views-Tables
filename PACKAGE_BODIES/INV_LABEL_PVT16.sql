--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT16
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT16" AS
  /* $Header: INVLA16B.pls 120.2 2007/12/18 19:11:43 hjogleka noship $ */
  label_b    CONSTANT VARCHAR2(50)              := '<label';
  label_e    CONSTANT VARCHAR2(50)              := '</label>' || fnd_global.local_chr(10);
  variable_b CONSTANT VARCHAR2(50)              := '<variable name= "';
  variable_e CONSTANT VARCHAR2(50)              := '</variable>' || fnd_global.local_chr(10);
  tag_e      CONSTANT VARCHAR2(50)              := '>' || fnd_global.local_chr(10);
  l_debug             NUMBER;
  -- Bug 2795525 : This mask is used to mask all date fields.
  g_date_format_mask  VARCHAR2(100)             := inv_label.g_date_format_mask;
  g_header_printed    BOOLEAN                   := FALSE;
  g_user_name         fnd_user.user_name%TYPE   := fnd_global.user_name;

  PROCEDURE TRACE(p_message VARCHAR2) IS
  BEGIN
    IF (g_header_printed = FALSE) THEN
      inv_label.TRACE('$Header: INVLA16B.pls 120.2 2007/12/18 19:11:43 hjogleka noship $', g_pkg_name || ' - ' || 'LABEL_WIP_MOVE_CONT');
      g_header_printed  := TRUE;
    END IF;

    inv_label.TRACE(g_user_name || ': ' || p_message, 'LABEL_WIP_MOVE_CONT');
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
    l_api_name               VARCHAR2(20)                            := 'get_variable_data';

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


    CURSOR wip_move_lines_cur IS
      SELECT WMT.ACCT_PERIOD_ID                 move_acct_period
           , WMT.ATTRIBUTE_CATEGORY             move_attribute_catagory
           , WMT.ATTRIBUTE1                     move_attribute1
           , WMT.ATTRIBUTE2                     move_attribute2
           , WMT.ATTRIBUTE3                     move_attribute3
           , WMT.ATTRIBUTE4                     move_attribute4
           , WMT.ATTRIBUTE5                     move_attribute5
           , WMT.ATTRIBUTE6                     move_attribute6
           , WMT.ATTRIBUTE7                     move_attribute7
           , WMT.ATTRIBUTE8                     move_attribute8
           , WMT.ATTRIBUTE9                     move_attribute9
           , WMT.ATTRIBUTE10                    move_attribute10
           , WMT.ATTRIBUTE11                    move_attribute11
           , WMT.ATTRIBUTE12                    move_attribute12
           , WMT.ATTRIBUTE13                    move_attribute13
           , WMT.ATTRIBUTE14                    move_attribute14
           , WMT.ATTRIBUTE15                    move_attribute15
           , WMT.CREATED_BY                     move_created_by
           , WMT.CREATION_DATE                  move_creation_date
           -- , WMT.EMPLOYEE_ID                    move_employee_id
           , MEV.FULL_NAME                      move_employee_id
           , WMT.FM_OPERATION_SEQ_NUM           move_fm_operation_seq_num
           , WMT.FM_OPERATION_CODE              move_fm_operation_code
           , BD1.DEPARTMENT_CODE                move_fm_department
           , ML1.MEANING                        move_fm_intraoperation_step
           , WMT.JOB_QUANTITY_SNAPSHOT          move_job_quantity_snapshot
           , WMT.LAST_UPDATED_BY                move_last_updated_by
           , WMT.LAST_UPDATE_DATE               move_last_update_date
           , WMT.LAST_UPDATE_LOGIN              move_last_update_login
           , WL.LINE_CODE                       move_line
           , WMT.ORGANIZATION_ID                move_organization_id
           , MP.ORGANIZATION_CODE               move_organization_code
           , HAOU.NAME                          move_organization_name
           , WMT.OVERCOMPLETION_PRIMARY_QTY     move_overcomp_primary_quantity
           , WMT.OVERCOMPLETION_TRANSACTION_QTY move_overcomp_txn_quantity
           , WE.primary_item_id                 move_primary_item_id
           , msik3.CONCATENATED_SEGMENTS        move_primary_item
           , WMT.PRIMARY_QUANTITY               move_primary_quantity
           , WMT.PRIMARY_UOM                    move_primary_uom
           , WMT.QA_COLLECTION_ID               move_qa_collection_id
           , MTR.REASON_NAME                    move_reason
           , WMT.REFERENCE                      move_reference
--         , WMT.SCRAP_ACCOUNT_ID               move_scrap_account
           , glcc.concatenated_segments         move_scrap_account
           , WMT.TO_OPERATION_SEQ_NUM           move_to_operation_seq_num
           , WMT.TO_OPERATION_CODE              move_to_operation_code
           , BD2.DEPARTMENT_CODE                move_to_department
           , ML2.MEANING                        move_to_intraoperation_step
           , TO_CHAR(WMT.TRANSACTION_DATE, g_date_format_mask)           move_transaction_date
           , WMT.TRANSACTION_ID                 move_transaction_id
           , WMT.TRANSACTION_QUANTITY           move_transaction_quantity
           , WMT.TRANSACTION_UOM                move_transaction_uom
           , WMT.WIP_ENTITY_ID                  wip_entity_id
           , WE.WIP_ENTITY_NAME                 wip_job_name
           , mfglkp2.meaning                    wip_job_type
           , wipdj.start_quantity               wip_job_start_quantity
           , TO_CHAR(wipdj.scheduled_start_date, g_date_format_mask)      wip_job_start_date
           , TO_CHAR(wipdj.scheduled_completion_date, g_date_format_mask) wip_job_completion_date
           , mmt.subinventory_code              job_completion_subinventory
           , inv_project.get_locsegs(mmt.locator_id, mmt.organization_id) job_completion_locator
        FROM MFG_LOOKUPS ML1
           , MFG_LOOKUPS ML2
           , MTL_TRANSACTION_REASONS MTR
           , BOM_DEPARTMENTS BD1
           , BOM_DEPARTMENTS BD2
           , WIP_ENTITIES WE
           , WIP_LINES WL
           , WIP_MOVE_TRANSACTIONS WMT
           , WIP_DISCRETE_JOBS wipdj
           , MTL_PARAMETERS MP
           , HR_ALL_ORGANIZATION_UNITS HAOU
           , mtl_system_items_vl msik3
           , MFG_LOOKUPS mfglkp2
           , GL_CODE_COMBINATIONS_KFV glcc
           , MTL_EMPLOYEES_VIEW MEV
           , MTL_MATERIAL_TRANSACTIONS mmt
       WHERE WMT.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
         AND WMT.ORGANIZATION_ID = WE.ORGANIZATION_ID
         AND WMT.LINE_ID = WL.LINE_ID (+)
         AND WMT.ORGANIZATION_ID = WL.ORGANIZATION_ID (+)
         AND WMT.FM_DEPARTMENT_ID = BD1.DEPARTMENT_ID
         AND ML1.LOOKUP_CODE = WMT.FM_INTRAOPERATION_STEP_TYPE
         AND ML1.LOOKUP_TYPE = 'WIP_INTRAOPERATION_STEP'
         AND WMT.TO_DEPARTMENT_ID = BD2.DEPARTMENT_ID
         AND ML2.LOOKUP_CODE = WMT.TO_INTRAOPERATION_STEP_TYPE
         AND ML2.LOOKUP_TYPE = 'WIP_INTRAOPERATION_STEP'
         AND WMT.REASON_ID = MTR.REASON_ID (+)
         AND WMT.ORGANIZATION_ID = MP.ORGANIZATION_ID
         AND WMT.ORGANIZATION_ID = HAOU.ORGANIZATION_ID
         AND msik3.inventory_item_id(+) = WE.primary_item_id
         AND msik3.organization_id(+) = WE.organization_id
         AND wipdj.wip_entity_id(+) = WE.wip_entity_id
         AND wipdj.organization_id(+) = WE.organization_id
         AND mfglkp2.lookup_code(+) = wipdj.job_type
         AND mfglkp2.lookup_type(+) = 'WIP_DISCRETE_JOB'
         AND glcc.code_combination_id(+) = WMT.SCRAP_ACCOUNT_ID
         AND MEV.ORGANIZATION_ID(+) = WMT.ORGANIZATION_ID
         AND MEV.EMPLOYEE_ID(+)     = WMT.EMPLOYEE_ID
         AND mmt.MOVE_TRANSACTION_ID(+) = wmt.TRANSACTION_ID
         AND mmt.INVENTORY_ITEM_ID(+) = wmt.PRIMARY_ITEM_ID
         AND mmt.ORGANIZATION_ID(+) = wmt.ORGANIZATION_ID
         AND mmt.TRANSACTION_SOURCE_ID(+) = wmt.WIP_ENTITY_ID
         AND WMT.TRANSACTION_ID = p_transaction_id;

    l_selected_fields        inv_label.label_field_variable_tbl_type;
    l_selected_fields_count  NUMBER;
    l_label_format_id        NUMBER                                  := 0;
    l_label_format           VARCHAR2(100);
    l_printer                VARCHAR2(30);
    l_content_item_data      LONG;
    l_content_rec_index      NUMBER                                  := 0;
    l_return_status          VARCHAR2(240);
    l_error_message          VARCHAR2(240);
    l_msg_count              NUMBER;
    l_api_status             VARCHAR2(240);
    l_msg_data               VARCHAR2(240);
    i                        NUMBER;
    l_id                     NUMBER;
    l_label_index            NUMBER;
    l_label_request_id       NUMBER;
    --I cleanup, use l_prev_format_id to record the previous label format
    l_prev_format_id         NUMBER;
    -- I cleanup, user l_prev_sub to record the previous subinventory
    --so that get_printer is not called if the subinventory is the same
    l_subinventory           VARCHAR2(30);
    l_organization_id        NUMBER;
    l_prev_sub               VARCHAR2(30);
    -- a list of columns that are selected for format
    l_column_name_list       LONG;
    v_wip_move_lines_content wip_move_lines_cur%ROWTYPE;
  BEGIN
    l_debug              := inv_label.l_debug;
    -- Initialize return status as success
    x_return_status      := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      TRACE('**In PVT16: Wip Move Content label**');
      TRACE('  Business_flow: ' || p_label_type_info.business_flow_code);
      TRACE('  Transaction ID:' || p_transaction_id);
    END IF;

    -- Get
    IF p_transaction_id IS NOT NULL THEN
      -- txn driven
      IF p_label_type_info.business_flow_code IN (41) THEN
        -- WIP Move Transaction
        OPEN wip_move_lines_cur;

        FETCH wip_move_lines_cur
         INTO v_wip_move_lines_content;

        IF wip_move_lines_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' No record found for Wip Move Transaction, no WIP Move content label print');
          END IF;

          CLOSE wip_move_lines_cur;

          RETURN;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          TRACE(' Invalid business flow code ' || p_label_type_info.business_flow_code);
        END IF;

        RETURN;
      END IF;
    ELSE
      -- On demand, get information from input_param
      IF (l_debug = 1) THEN
        TRACE('Manual mode, not available yet');
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      TRACE(' Getting selected fields ');
    END IF;

    inv_label.get_variables_for_format(x_variables => l_selected_fields, x_variables_count => l_selected_fields_count
    , p_format_id                  => p_label_type_info.default_format_id);

    IF (l_selected_fields_count = 0)
       OR(l_selected_fields.COUNT = 0) THEN
      IF (l_debug = 1) THEN
        TRACE('no fields defined for this format: ' || p_label_type_info.default_format_id || ',' || p_label_type_info.default_format_name);
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      TRACE(' Found variable defined for this format, count = ' || l_selected_fields_count);
    END IF;

    l_content_rec_index  := 0;

    IF (l_debug = 1) THEN
      TRACE('** in PVT16.get_variable_data ** , start ');
    END IF;

    l_printer            := p_label_type_info.default_printer;
    l_label_index        := 1;
    l_prev_format_id     := p_label_type_info.default_format_id;
    l_prev_sub           := '####';

    l_content_item_data  := '';

    IF (l_debug = 1) THEN
      TRACE(' New WIP Move Content label ');
    END IF;

    l_content_rec_index                                 := l_content_rec_index + 1;

    IF (l_debug = 1) THEN
      TRACE(' New Label ' || l_content_rec_index);
    END IF;


    --R12 : RFID compliance project
    --Calling rules engine before calling to get printer

    IF (l_debug = 1) THEN
      TRACE(
           'Apply Rules engine for format'
        || ',manual_format_id='
        || p_label_type_info.manual_format_id
        || ',manual_format_name='
        || p_label_type_info.manual_format_name
      );
    END IF;

    /* insert a record into wms_label_requests entity to
    call the label rules engine to get appropriate label */

    inv_label.get_format_with_rule(
      p_document_id                => p_label_type_info.label_type_id
    , p_label_format_id            => p_label_type_info.manual_format_id
    , p_organization_id            => v_wip_move_lines_content.move_organization_id
    , p_inventory_item_id          => v_wip_move_lines_content.move_primary_item_id
    , p_lpn_id                     => NULL  -- Bug 5509692.
    , p_last_update_date           => SYSDATE
    , p_last_updated_by            => fnd_global.user_id
    , p_creation_date              => SYSDATE
    , p_created_by                 => fnd_global.user_id
    --, p_printer_name               => l_printer-- Removed in R12: 4396558
    , p_business_flow_code         => p_label_type_info.business_flow_code
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
    END IF;

    IF (l_debug = 1) THEN
      TRACE('did apply label ' || l_label_format || ',' || l_label_format_id || ',req_id ' || l_label_request_id);
    END IF;

    IF p_label_type_info.manual_format_id IS NOT NULL THEN
      l_label_format_id  := p_label_type_info.manual_format_id;
      l_label_format     := p_label_type_info.manual_format_name;

      IF (l_debug = 1) THEN
        TRACE('Manual format passed in:' || l_label_format_id || ',' || l_label_format);
      END IF;
    END IF;


    IF (l_debug = 1) THEN
      TRACE(
           ' Getting printer, manual_printer='
        || p_label_type_info.manual_printer
        || ',sub='
        || l_subinventory
        || ',default printer='
        || p_label_type_info.default_printer
      );
    END IF;

    -- IF clause Added for Add format/printer for manual request
    IF p_label_type_info.manual_printer IS NULL THEN
      IF (l_subinventory IS NOT NULL)
         AND(l_subinventory <> l_prev_sub) THEN
        IF (l_debug = 1) THEN
          TRACE('getting printer with org, sub' || l_organization_id || ',' || l_subinventory);
        END IF;

        BEGIN
          wsh_report_printers_pvt.get_printer(
            p_concurrent_program_id      => p_label_type_info.label_type_id
          , p_user_id                    => fnd_global.user_id
          , p_responsibility_id          => fnd_global.resp_id
          , p_application_id             => fnd_global.resp_appl_id
          , p_organization_id            => l_organization_id
          , p_format_id                  =>l_label_format_id --added in r12 RFID 4396558
          , p_zone                       => l_subinventory
          , x_printer                    => l_printer
          , x_api_status                 => l_api_status
          , x_error_message              => l_error_message
          );

          IF l_api_status <> 'S' THEN
            IF (l_debug = 1) THEN
              TRACE('Error in calling get_printer, set printer as default printer, err_msg:' || l_error_message);
            END IF;

            l_printer  := p_label_type_info.default_printer;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            l_printer  := p_label_type_info.default_printer;
        END;

        l_prev_sub  := l_subinventory;

      END IF;
    ELSE
      IF (l_debug = 1) THEN
        TRACE('Set printer as Manual Printer passed in:' || p_label_type_info.manual_printer);
      END IF;

      l_printer  := p_label_type_info.manual_printer;
    END IF;




    IF (l_label_format_id IS NOT NULL) THEN
      -- Derive the fields for the format either passed in or derived via the rules engine.
      IF l_label_format_id <> NVL(l_prev_format_id, -999) THEN
        IF (l_debug = 1) THEN
          TRACE(' Getting variables for new format ' || l_label_format);
        END IF;

        inv_label.get_variables_for_format(x_variables => l_selected_fields, x_variables_count => l_selected_fields_count
        , p_format_id                  => l_label_format_id);
        l_prev_format_id  := l_label_format_id;

        IF (l_selected_fields_count = 0)
           OR(l_selected_fields.COUNT = 0) THEN
          IF (l_debug = 1) THEN
            TRACE('no fields defined for this format: ' || l_label_format || ',' || l_label_format_id);
          END IF;

          GOTO nextlabel;
        END IF;

        IF (l_debug = 1) THEN
          TRACE('   Found selected_fields for format ' || l_label_format || ', num=' || l_selected_fields_count);
        END IF;
      END IF;
    ELSE
      IF (l_debug = 1) THEN
        TRACE('No format exists for this label, goto nextlabel');
      END IF;

      GOTO nextlabel;
    END IF;

    /* variable header */
    l_content_item_data                                 := l_content_item_data || label_b;

    IF l_label_format <> NVL(p_label_type_info.default_format_name, '@@@') THEN
      l_content_item_data  := l_content_item_data || ' _FORMAT="' || NVL(p_label_type_info.manual_format_name, l_label_format) || '"';
    END IF;

    IF (l_printer IS NOT NULL)
       AND(l_printer <> NVL(p_label_type_info.default_printer, '###')) THEN
      l_content_item_data  := l_content_item_data || ' _PRINTERNAME="' || l_printer || '"';
    END IF;

    l_content_item_data                                 := l_content_item_data || tag_e;

    IF (l_debug = 1) THEN
      TRACE('Starting assign variables, ');
    END IF;

    l_column_name_list                                  := 'Set variables for ';

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
                      trace('Custom Labels Trace [INVLA16B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
                      trace('Custom Labels Trace [INVLA16B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
                      trace('Custom Labels Trace [INVLA16B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
                      trace('Custom Labels Trace [INVLA16B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
                      trace('Custom Labels Trace [INVLA16B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
                     END IF;
                     l_sql_stmt := l_selected_fields(i).sql_stmt;
                     IF (l_debug = 1) THEN
                      trace('Custom Labels Trace [INVLA16B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
                     END IF;
                     l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
                     IF (l_debug = 1) THEN
                      trace('Custom Labels Trace [INVLA16B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);

                     END IF;
                     BEGIN
                     IF (l_debug = 1) THEN
                      trace('Custom Labels Trace [INVLA16B.pls]: At Breadcrumb 1');
                      trace('Custom Labels Trace [INVLA16B.pls]: LABEL_REQUEST_ID     : ' || l_label_request_id);
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
              trace('Custom Labels Trace [INVLA16B.pls]: At Breadcrumb 2');
              trace('Custom Labels Trace [INVLA16B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
              trace('Custom Labels Trace [INVLA16B.pls]: WARNING: NULL value returned by the custom SQL Query.');
              trace('Custom Labels Trace [INVLA16B.pls]: l_custom_sql_ret_status  is set to : ' || l_custom_sql_ret_status );
             END IF;
            ELSIF c_sql_stmt%rowcount=0 THEN
                            IF (l_debug = 1) THEN
                             trace('Custom Labels Trace [INVLA16B.pls]: At Breadcrumb 3');
               trace('Custom Labels Trace [INVLA16B.pls]: WARNING: No row returned by the Custom SQL query');
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
                             trace('Custom Labels Trace [INVLA16B.pls]: At Breadcrumb 4');
                             trace('Custom Labels Trace [INVLA16B.pls]: ERROR: Multiple values returned by the Custom SQL query');
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
                            trace('Custom Labels Trace [INVLA16B.pls]: At Breadcrumb 5');
                            trace('Custom Labels Trace [INVLA16B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
                      END IF;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END;
               IF (l_debug = 1) THEN
                      trace('Custom Labels Trace [INVLA16B.pls]: At Breadcrumb 6');
                      trace('Custom Labels Trace [INVLA16B.pls]: Before assigning it to l_content_item_data');
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
                      trace('Custom Labels Trace [INVLA16B.pls]: At Breadcrumb 7');
                      trace('Custom Labels Trace [INVLA16B.pls]: After assigning it to l_content_item_data');
             trace('Custom Labels Trace [INVLA16B.pls]: --------------------------REPORT END-------------------------------------');
                    END IF;
--------------------End of this change for Custom Labels project code--------------------
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_acct_period' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_acct_period
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute_catagory' THEN
        l_content_item_data  :=
             l_content_item_data
          || variable_b
          || l_selected_fields(i).variable_name
          || '">'
          || v_wip_move_lines_content.move_attribute_catagory
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute1' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute1
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute2' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute2
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute3' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute3
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute4' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute4
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute5' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute5
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute6' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute6
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute7' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute7
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute8' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute8
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute9' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute9
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute10' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute10
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute11' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute11
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute12' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute12
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute13' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute13
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute14' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute14
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_attribute15' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_attribute15
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_created_by' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_created_by
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_creation_date' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_creation_date
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_employee' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_employee_id
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_fm_operation_seq_num' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_fm_operation_seq_num
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_fm_operation_code' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_fm_operation_code
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_fm_department' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_fm_department
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_fm_intraoperation_step' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_fm_intraoperation_step
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_job_quantity_snapshot' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_job_quantity_snapshot
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_last_updated_by' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_last_updated_by
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_last_update_date' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_last_update_date
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_last_update_login' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_last_update_login
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_line' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_line
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_organization_code' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_organization_code
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_organization_name' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_organization_name
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_overcomp_primary_quantity' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_overcomp_primary_quantity
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_overcomp_txn_quantity' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_overcomp_txn_quantity
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_primary_item' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_primary_item
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_primary_quantity' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_primary_quantity
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_primary_uom' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_primary_uom
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_qa_collection_id' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_qa_collection_id
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_reason' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_reason
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_reference' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_reference
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_scrap_account' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_scrap_account
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_to_operation_seq_num' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_to_operation_seq_num
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_to_operation_code' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_to_operation_code
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_to_department' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_to_department
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_to_intraoperation_step' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_to_intraoperation_step
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_transaction_date' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_transaction_date
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_transaction_id' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_transaction_id
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_transaction_quantity' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_transaction_quantity
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'move_transaction_uom' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.move_transaction_uom
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'wip_entity_id' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.wip_entity_id
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'job_name' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.wip_job_name
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'job_type' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.wip_job_type
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'job_qty' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.wip_job_start_quantity
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'job_scheduled_start_date' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.wip_job_start_date
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'job_scheduled_completion_date' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.wip_job_completion_date
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'job_completion_subinventory' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.job_completion_subinventory
          || variable_e;
      ELSIF LOWER(l_selected_fields(i).column_name) = 'job_completion_locator' THEN
        l_content_item_data  :=
          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_move_lines_content.job_completion_locator
          || variable_e;
      END IF;
    END LOOP;

    l_content_item_data                                 := l_content_item_data || label_e;
    x_variable_content(l_label_index).label_content     := l_content_item_data;
    x_variable_content(l_label_index).label_request_id  := l_label_request_id;

--------------------Start of changes for Custom Labels project code------------------
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

--------------------End of this changes for Custom Labels project code---------------

    l_label_index                                       := l_label_index + 1;

    <<nextlabel>>
      l_content_item_data                                 := '';
    l_custom_sql_ret_status  := NULL;
    l_custom_sql_ret_msg     := NULL;

    IF (l_debug = 1) THEN
      TRACE(l_column_name_list);
      TRACE('       Finished writing variables ');
    END IF;

    CLOSE wip_move_lines_cur;

    --x_variable_content := x_variable_content || l_content_item_data ;


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
      x_variable_content  := x_variable_content || l_variable_data_tbl(i).label_content;
    END LOOP;
  END get_variable_data;
END inv_label_pvt16;

/
