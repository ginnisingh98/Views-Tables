--------------------------------------------------------
--  DDL for Package Body WSH_TRX_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRX_HANDLER" AS
/* $Header: WSHIIXIB.pls 120.0.12010000.2 2009/04/27 13:50:00 selsubra ship $ */
--
-- PACKAGE VARIABLES
--

   g_userid             NUMBER;

-- ===========================================================================
--
-- Name:
--
--   insert_row
--
-- Description:
--
--   Called by the client to insert a row into the
--   MTL_TRANSACTIONS_INTERFACE table.
--
-- ===========================================================================
   --
   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRX_HANDLER';
   --

--HVOP heali
PROCEDURE INSERT_ROW_BULK (
     p_start_index	IN	NUMBER,
     p_end_index	IN	NUMBER,
     p_mtl_txn_if_rec   IN              WSH_SHIP_CONFIRM_ACTIONS.mtl_txn_if_rec_type,
     x_return_status    OUT NOCOPY      VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW_BULK';

l_bulk_batch_size	NUMBER;
l_total_row_count	NUMBER:=0;
l_start_index		NUMBER ;
l_end_index		NUMBER ;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'p_start_index',p_start_index);
     WSH_DEBUG_SV.log(l_module_name,'p_end_index',p_end_index);
     WSH_DEBUG_SV.log(l_module_name,'p_mtl_txn_if_rec.count',p_mtl_txn_if_rec.picking_line_id.count);
  END IF;

  x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  fnd_profile.get('USER_ID',g_userid);

  FORALL i IN p_start_index..p_end_index
        INSERT INTO mtl_transactions_interface (
         source_code,
         source_header_id,
         source_line_id,
         inventory_item_id,
         subinventory_code,
         transaction_quantity,
         transaction_date,
         organization_id,
         transaction_source_id,
         transaction_source_type_id,
         transaction_action_id,
         transaction_type_id,
         distribution_account_id,
         transaction_reference,
         transaction_header_id,
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
         transaction_uom,
         transaction_interface_id,
         shipment_number,
         expected_arrival_date,
         encumbrance_account,
         encumbrance_amount,
         movement_id,
         freight_code,
         waybill_airbill,
	 content_lpn_id,
         process_flag,
         transaction_mode,
-- HW OPMCONV. Added secondary_qty and secondary_uom
         SECONDARY_TRANSACTION_QUANTITY,
         SECONDARY_UOM_CODE,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by

      ) VALUES (
         p_mtl_txn_if_rec.source_code(i),
         p_mtl_txn_if_rec.source_header_id(i),
         p_mtl_txn_if_rec.source_line_id(i),
         p_mtl_txn_if_rec.inventory_item_id(i),
         p_mtl_txn_if_rec.subinventory(i),
         p_mtl_txn_if_rec.trx_quantity(i),
         p_mtl_txn_if_rec.trx_date(i),
         p_mtl_txn_if_rec.organization_id(i),
         p_mtl_txn_if_rec.trx_source_id(i),
         p_mtl_txn_if_rec.trx_source_type_id(i),
         p_mtl_txn_if_rec.trx_action_id(i),
         p_mtl_txn_if_rec.trx_type_id(i),
         p_mtl_txn_if_rec.distribution_account_id(i),
         p_mtl_txn_if_rec.trx_reference(i),
         p_mtl_txn_if_rec.trx_header_id(i),
         p_mtl_txn_if_rec.trx_source_line_id(i),
         p_mtl_txn_if_rec.trx_source_delivery_id(i),
         p_mtl_txn_if_rec.revision(i),
         p_mtl_txn_if_rec.locator_id(i),
         p_mtl_txn_if_rec.picking_line_id(i),
         p_mtl_txn_if_rec.transfer_subinventory(i),
         p_mtl_txn_if_rec.transfer_organization(i),
         p_mtl_txn_if_rec.ship_to_location_id(i),
         p_mtl_txn_if_rec.requisition_line_id(i),
         p_mtl_txn_if_rec.requisition_distribution_id(i),
         p_mtl_txn_if_rec.trx_uom(i),
         p_mtl_txn_if_rec.trx_interface_id(i),
         p_mtl_txn_if_rec.shipment_number(i),
         p_mtl_txn_if_rec.expected_arrival_date(i),
         p_mtl_txn_if_rec.encumbrance_account(i),
         p_mtl_txn_if_rec.encumbrance_amount(i),
         p_mtl_txn_if_rec.movement_id(i),
         p_mtl_txn_if_rec.freight_code(i),
         p_mtl_txn_if_rec.waybill_airbill(i),  --Bug 7503285
         p_mtl_txn_if_rec.content_lpn_id(i),
         '1',
         '3',
-- HW OPMCONV. Added secondary_qty and secondary_uom
         p_mtl_txn_if_rec.trx_quantity2(i),
         p_mtl_txn_if_rec.SECONDARY_TRX_UOM(i),
         SYSDATE,
         g_userid,
         SYSDATE,
         g_userid
         );

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Rows inserted in mtl_transactions_interface',SQL%ROWCOUNT);
    END IF;

    -- Delete all the record with error_flag 'Y'
    FORALL i IN p_start_index..p_end_index
      DELETE mtl_transactions_interface
      WHERE picking_line_id = decode(p_mtl_txn_if_rec.error_flag(i),
                                  'Y',p_mtl_txn_if_rec.picking_line_id(i),
                                  'N',-99999);
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Rows Delete in mtl_transactions_interface',SQL%ROWCOUNT);
    END IF;

    FORALL i IN p_start_index..p_end_index
      UPDATE wsh_delivery_details
         SET inv_interfaced_flag='P'
         WHERE delivery_detail_id = decode(p_mtl_txn_if_rec.error_flag(i),
                                           'N',p_mtl_txn_if_rec.picking_line_id(i),
                                           'Y',-99999);
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Rows Updated in wsh_delivery_details',SQL%ROWCOUNT);
    END IF;

 IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
 WHEN OTHERS THEN
    x_return_status:= WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END insert_row_bulk;
--HVOP heali



   PROCEDURE Insert_Row (
      x_rowid					IN OUT NOCOPY  VARCHAR2,
      x_trx_interface_id			IN OUT NOCOPY  NUMBER,
      p_trx_header_id				IN NUMBER,
      p_trx_source_id				IN NUMBER,
      p_source_code				IN VARCHAR2,
      p_source_line_id				IN NUMBER,
      p_source_header_id			IN NUMBER,
      p_inventory_item_id			IN NUMBER,
      p_subinventory_code			IN VARCHAR2,
      p_trx_quantity				IN NUMBER,
      p_transaction_date			IN DATE,
      p_organization_id				IN NUMBER,
      p_dsp_segment1				IN VARCHAR2,
      p_dsp_segment2				IN VARCHAR2,
      p_dsp_segment3				IN VARCHAR2,
      p_trx_source_type_id			IN NUMBER,
      p_trx_action_id				IN NUMBER,
      p_trx_type_id				IN NUMBER,
      p_distribution_account_id			IN NUMBER,
      p_dst_segment1				IN VARCHAR2,
      p_dst_segment2				IN VARCHAR2,
      p_dst_segment3				IN VARCHAR2,
      p_dst_segment4				IN VARCHAR2,
      p_dst_segment5				IN VARCHAR2,
      p_dst_segment6				IN VARCHAR2,
      p_dst_segment7				IN VARCHAR2,
      p_dst_segment8				IN VARCHAR2,
      p_dst_segment9				IN VARCHAR2,
      p_dst_segment10				IN VARCHAR2,
      p_dst_segment11				IN VARCHAR2,
      p_dst_segment12				IN VARCHAR2,
      p_dst_segment13				IN VARCHAR2,
      p_dst_segment14				IN VARCHAR2,
      p_dst_segment15				IN VARCHAR2,
      p_dst_segment16				IN VARCHAR2,
      p_dst_segment17				IN VARCHAR2,
      p_dst_segment18				IN VARCHAR2,
      p_dst_segment19				IN VARCHAR2,
      p_dst_segment20				IN VARCHAR2,
      p_dst_segment21				IN VARCHAR2,
      p_dst_segment22				IN VARCHAR2,
      p_dst_segment23				IN VARCHAR2,
      p_dst_segment24				IN VARCHAR2,
      p_dst_segment25				IN VARCHAR2,
      p_dst_segment26				IN VARCHAR2,
      p_dst_segment27				IN VARCHAR2,
      p_dst_segment28				IN VARCHAR2,
      p_dst_segment29				IN VARCHAR2,
      p_dst_segment30				IN VARCHAR2,
      p_trx_reference				IN VARCHAR2,
      p_trx_source_line_id			IN NUMBER,
      p_trx_source_delivery_id			IN NUMBER,
      p_revision				IN VARCHAR2,
      p_locator_id				IN NUMBER,
      p_loc_segment1				IN VARCHAR2,
      p_loc_segment2				IN VARCHAR2,
      p_loc_segment3				IN VARCHAR2,
      p_loc_segment4				IN VARCHAR2,
      p_picking_line_id				IN NUMBER,
      p_transfer_subinventory			IN VARCHAR2,
      p_transfer_organization			IN NUMBER,
      p_ship_to_location_id			IN NUMBER,
      p_requisition_line_id			IN NUMBER,
      p_trx_uom					IN VARCHAR2,
      p_demand_id				IN NUMBER,
      p_shipment_number				IN VARCHAR2,
      p_expected_arrival_date             	IN DATE,
      p_encumbrance_account			IN NUMBER,
      p_encumbrance_amount			IN NUMBER,
      p_movement_id				IN NUMBER,
      p_freight_code				IN VARCHAR2,
      p_waybill_airbill				IN VARCHAR2,
      p_last_update_date			IN DATE,
      p_last_updated_by				IN NUMBER,
      p_creation_date				IN DATE,
      p_created_by				IN NUMBER,
      p_last_update_login              		IN NUMBER DEFAULT NULL,
      p_request_id				IN NUMBER DEFAULT NULL,
      p_program_application_id                  IN NUMBER DEFAULT NULL,
      p_program_id                              IN NUMBER DEFAULT NULL,
      p_program_update_date                     IN DATE DEFAULT NULL,
      p_process_flag				IN NUMBER DEFAULT 1,
      p_trx_mode				IN NUMBER DEFAULT 3,
 -- rec in MTI shold be locked, since the Inv worker is called to process the interface records.
      p_lock_flag				IN NUMBER DEFAULT 2,
      p_acct_period_id				IN NUMBER DEFAULT NULL,
      p_required_flag				IN VARCHAR2 DEFAULT NULL,
      p_currency_code				IN VARCHAR2 DEFAULT NULL,
      p_currency_conversion_type		IN VARCHAR2 DEFAULT NULL,
      p_currency_conversion_date		IN DATE DEFAULT NULL,
      p_currency_conversion_rate		IN NUMBER DEFAULT NULL,
      p_project_id				IN NUMBER DEFAULT NULL,
      p_task_id					IN NUMBER DEFAULT NULL,
      p_validation_required         		IN NUMBER DEFAULT NULL,
      p_item_segment1         			IN VARCHAR2 DEFAULT NULL,
      p_item_segment2         			IN VARCHAR2 DEFAULT NULL,
      p_item_segment3                		IN VARCHAR2 DEFAULT NULL,
      p_item_segment4                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment5                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment6                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment7                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment8                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment9                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment10                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment11                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment12                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment13                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment14                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment15                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment16                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment17                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment18                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment19                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment20                    	IN VARCHAR2 DEFAULT NULL,
      p_primary_quantity                  	IN NUMBER DEFAULT NULL,
      p_loc_segment5                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment6                      	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment7                      	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment8                      	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment9                      	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment10                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment11                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment12                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment13                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment14                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment15                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment16                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment17                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment18                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment19                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment20                     	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment4                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment5                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment6                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment7                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment8                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment9                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment10                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment11                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment12                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment13                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment14                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment15                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment16                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment17                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment18                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment19                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment20                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment21                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment22                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment23                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment24                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment25                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment26                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment27                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment28                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment29                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment30                          	IN VARCHAR2 DEFAULT NULL,
      p_trx_source_name                         IN VARCHAR2 DEFAULT NULL,
      p_reason_id                    		IN NUMBER DEFAULT NULL,
      p_trx_cost                     		IN NUMBER DEFAULT NULL,
      p_ussgl_transaction_code      		IN VARCHAR2 DEFAULT NULL,
      p_wip_entity_type                  	IN NUMBER DEFAULT NULL,
      p_schedule_id                      	IN NUMBER DEFAULT NULL,
      p_employee_code                   	IN VARCHAR2 DEFAULT NULL,
      p_department_id                    	IN NUMBER DEFAULT NULL,
      p_schedule_update_code             	IN NUMBER DEFAULT NULL,
      p_setup_teardown_code              	IN NUMBER DEFAULT NULL,
      p_primary_switch                   	IN NUMBER DEFAULT NULL,
      p_mrp_code                         	IN NUMBER DEFAULT NULL,
      p_operation_seq_num                	IN NUMBER DEFAULT NULL,
      p_repetitive_line_id               	IN NUMBER DEFAULT NULL,
      p_customer_ship_id                  	IN NUMBER DEFAULT NULL,
      p_line_item_num             		IN NUMBER DEFAULT NULL,
      p_receiving_document        		IN VARCHAR2 DEFAULT NULL,
      p_rcv_transaction_id                	IN NUMBER DEFAULT NULL,
      p_vendor_lot_number                 	IN VARCHAR2 DEFAULT NULL,
      p_transfer_locator                  	IN NUMBER DEFAULT NULL,
      p_xfer_loc_segment1                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment2                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment3                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment4                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment5                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment6                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment7                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment8                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment9                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment10                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment11                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment12                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment13                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment14                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment15                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment16                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment17                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment18                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment19                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment20                	IN VARCHAR2 DEFAULT NULL,
      p_transportation_cost               	IN NUMBER DEFAULT NULL,
      p_transportation_account            	IN NUMBER DEFAULT NULL,
      p_transfer_cost                     	IN NUMBER DEFAULT NULL,
      p_containers                       	IN NUMBER DEFAULT NULL,
      p_new_average_cost                 	IN NUMBER DEFAULT NULL,
      p_value_change                     	IN NUMBER DEFAULT NULL,
      p_percentage_change                	IN NUMBER DEFAULT NULL,
      p_demand_source_header_id          	IN NUMBER DEFAULT NULL,
      p_demand_source_line           		IN VARCHAR2 DEFAULT NULL,
      p_demand_source_delivery      		IN VARCHAR2 DEFAULT NULL,
      p_negative_req_flag                	IN NUMBER DEFAULT NULL,
      p_error_explanation 			IN VARCHAR2 DEFAULT NULL,
      p_shippable_flag 				IN VARCHAR2 DEFAULT NULL,
      p_error_code 				IN VARCHAR2 DEFAULT NULL,
      p_attribute_category               	IN VARCHAR2 DEFAULT NULL,
      p_attribute1                 		IN VARCHAR2 DEFAULT NULL,
      p_attribute2      			IN VARCHAR2 DEFAULT NULL,
      p_attribute3                    		IN VARCHAR2 DEFAULT NULL,
      p_attribute4             			IN VARCHAR2 DEFAULT NULL,
      p_attribute5 				IN VARCHAR2 DEFAULT NULL,
      p_attribute6            			IN VARCHAR2 DEFAULT NULL,
      p_attribute7   				IN VARCHAR2 DEFAULT NULL,
      p_attribute8 				IN VARCHAR2 DEFAULT NULL,
      p_attribute9          			IN VARCHAR2 DEFAULT NULL,
      p_attribute10         			IN VARCHAR2 DEFAULT NULL,
      p_attribute11             		IN VARCHAR2 DEFAULT NULL,
      p_attribute12                       	IN VARCHAR2 DEFAULT NULL,
      p_attribute13                       	IN VARCHAR2 DEFAULT NULL,
      p_attribute14                       	IN VARCHAR2 DEFAULT NULL,
      p_attribute15                       	IN VARCHAR2 DEFAULT NULL,
      p_requisition_distribution_id      	IN NUMBER DEFAULT NULL,
      p_reservation_quantity             	IN NUMBER DEFAULT NULL,
      p_shipped_quantity                 	IN NUMBER DEFAULT NULL,
      p_inventory_item                    	IN VARCHAR2 DEFAULT NULL,
      p_locator_name                      	IN VARCHAR2 DEFAULT NULL,
      p_to_task_id                       	IN NUMBER DEFAULT NULL,
      p_source_task_id                   	IN NUMBER DEFAULT NULL,
      p_to_project_id                     	IN NUMBER DEFAULT NULL,
      p_source_project_id                 	IN NUMBER DEFAULT NULL,
      p_pa_expenditure_org_id             	IN NUMBER DEFAULT NULL,
      p_expenditure_type                  	IN VARCHAR2 DEFAULT NULL,
      p_final_completion_flag            	IN VARCHAR2 DEFAULT NULL,
      p_transfer_percentage              	IN NUMBER DEFAULT NULL,
      p_trx_sequence_id              		IN NUMBER DEFAULT NULL,
      p_material_account                 	IN NUMBER DEFAULT NULL,
      p_material_overhead_account        	IN NUMBER DEFAULT NULL,
      p_resource_account                 	IN NUMBER DEFAULT NULL,
      p_outside_processing_account       	IN NUMBER DEFAULT NULL,
      p_overhead_account                 	IN NUMBER DEFAULT NULL,
      p_bom_revision                  		IN VARCHAR2 DEFAULT NULL,
      p_routing_revision          		IN VARCHAR2 DEFAULT NULL,
      p_bom_revision_date              		IN DATE DEFAULT NULL,
      p_routing_revision_date          		IN DATE DEFAULT NULL,
      p_alternate_bom_designator      		IN VARCHAR2 DEFAULT NULL,
      p_alternate_routing_designator    	IN VARCHAR2 DEFAULT NULL,
      p_accounting_class             		IN VARCHAR2 DEFAULT NULL,
      p_demand_class                		IN VARCHAR2 DEFAULT NULL,
      p_parent_id                        	IN NUMBER DEFAULT NULL,
      p_substitution_type_id             	IN NUMBER DEFAULT NULL,
      p_substitution_item_id             	IN NUMBER DEFAULT NULL,
      p_schedule_group                   	IN NUMBER DEFAULT NULL,
      p_build_sequence                   	IN NUMBER DEFAULT NULL,
      p_schedule_number		     		IN VARCHAR2 DEFAULT NULL,
      p_scheduled_flag                   	IN NUMBER DEFAULT NULL,
      p_flow_schedule           		IN VARCHAR2 DEFAULT NULL,
      p_cost_group_id                    	IN NUMBER DEFAULT NULL,
      p_content_lpn_id                       IN NUMBER DEFAULT NULL,
-- HW OPMCONV. Added p_secondary_trx_quantity
-- and p_secondary_uom_code
      p_secondary_trx_quantity                  IN NUMBER DEFAULT NULL,
      p_secondary_uom_code                      IN VARCHAR2 DEFAULT NULL
      )
   IS

      CURSOR row_id IS
         SELECT rowid FROM mtl_transactions_interface
         WHERE transaction_interface_id = x_trx_interface_id;

      CURSOR get_interface_id IS
         SELECT mtl_material_transactions_s.nextval
         FROM sys.dual;

	 --
l_debug_on BOOLEAN;
	 --
	 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW';
	 --
   BEGIN

/*      wsh_server_debug.log_event('WSH_TRX_HANDLER.INSERT_ROW',
         'START',
         'Start of procedure INSERT_ROW, input parameters:
            source_code='||p_source_code||
            ', source_line_id='||p_source_line_id||
            ', source_header_id='||p_source_header_id||
            ', inventory_item='||p_inventory_item||
            ', subinventory_code='||p_subinventory_code||
            ', transaction_quantity='||p_trx_quantity||
            ', transaction_date='||p_transaction_date||
            ', organization_id='||p_organization_id);
      wsh_server_debug.debug_message(
            ', dsp_segment1='||p_dsp_segment1||
            ', dsp_segment2='||p_dsp_segment2||
            ', dsp_segment3='||p_dsp_segment3||
            ', transaction_source_type_id='||p_trx_source_type_id||
            ', transaction_action_id='||p_trx_action_id||
            ', transaction_type_id='||p_trx_type_id||
            ', distribution_account_id='||p_distribution_account_id);
      wsh_server_debug.debug_message(
            ', dst_segment1='||p_dst_segment1||
            ', dst_segment2='||p_dst_segment2||
            ', dst_segment3='||p_dst_segment3||
            ', dst_segment4='||p_dst_segment4||
            ', dst_segment5='||p_dst_segment5||
            ', dst_segment6='||p_dst_segment6||
            ', dst_segment7='||p_dst_segment7||
            ', dst_segment8='||p_dst_segment8||
            ', dst_segment9='||p_dst_segment9||
            ', dst_segment10='||p_dst_segment10);
      wsh_server_debug.debug_message(
            ', dst_segment11='||p_dst_segment11||
            ', dst_segment12='||p_dst_segment12||
            ', dst_segment13='||p_dst_segment13||
            ', dst_segment14='||p_dst_segment14||
            ', dst_segment15='||p_dst_segment15||
            ', dst_segment16='||p_dst_segment16||
            ', dst_segment17='||p_dst_segment17||
            ', dst_segment18='||p_dst_segment18||
            ', dst_segment19='||p_dst_segment19||
            ', dst_segment20='||p_dst_segment20);
      wsh_server_debug.debug_message(
            ', dst_segment21='||p_dst_segment21||
            ', dst_segment22='||p_dst_segment22||
            ', dst_segment23='||p_dst_segment23||
            ', dst_segment24='||p_dst_segment24||
            ', dst_segment25='||p_dst_segment25||
            ', dst_segment26='||p_dst_segment26||
            ', dst_segment27='||p_dst_segment27||
            ', dst_segment28='||p_dst_segment28||
            ', dst_segment29='||p_dst_segment29||
            ', dst_segment30='||p_dst_segment30);
      wsh_server_debug.debug_message(
            ', transaction_reference='||p_trx_reference||
            ', trx_source_line_id='||p_trx_source_line_id||
            ', trx_source_delivery_id='||p_trx_source_delivery_id||
            ', revision='||p_revision||
            ', locator_id='||p_locator_id||
            ', loc_segment1='||p_loc_segment1||
            ', loc_segment2='||p_loc_segment2||
            ', loc_segment3='||p_loc_segment3||
            ', loc_segment4='||p_loc_segment4||
            ', picking_line_id='||p_picking_line_id||
            ', transfer_subinventory='||p_transfer_subinventory||
            ', transfer_organization='||p_transfer_organization);
      wsh_server_debug.debug_message(
            ', ship_to_location_id='||p_ship_to_location_id||
            ', requisition_line_id='||p_requisition_line_id||
            ', transaction_uom='||p_trx_uom||
            ', transaction_interface_id='||x_trx_interface_id||
            ', demand_id='||p_demand_id||
            ', shipment_number='||p_shipment_number||
            ', expected_arrival_date='||p_expected_arrival_date||
            ', encumbrance_account='||p_encumbrance_account||
            ', encumbrance_amount='||p_encumbrance_amount||
            ', movement_id='||p_movement_id);
      wsh_server_debug.debug_message(
            ', freight_code='||p_freight_code||
            ', waybill_airbill='||p_waybill_airbill||
            ', last_update_date='||p_last_update_date||
            ', last_updated_by='||p_last_updated_by||
            ', creation_date='||p_creation_date||
            ', created_by='||p_created_by||
            ', last_update_login='||p_last_update_login||
            ', request_id='||p_request_id||
            ', program_application_id='||p_program_application_id||
            ', program_id='||p_program_id||
            ', program_update_date='||p_program_update_date);
      wsh_server_debug.debug_message(
            ', process_flag='||p_process_flag||
            ', transaction_mode='||p_trx_mode||
            ', lock_flag='||p_lock_flag||
            ', transaction_header_id='||p_trx_header_id||
            ', acct_period_id='||p_acct_period_id||
            ', transaction_source_id='||p_trx_source_id||
            ', required_flag='||p_required_flag||
            ', currency_code='||p_currency_code||
            ', currency_conversion_type='||p_currency_conversion_type||
            ', currency_conversion_date='||p_currency_conversion_date||
            ', currency_conversion_rate='||p_currency_conversion_rate);
      wsh_server_debug.debug_message(
            ', project_id='||p_project_id||
            ', task_id='||p_task_id||
            ', validation_required='||p_validation_required||
            ', item_segment1='||p_item_segment1||
            ', item_segment2='||p_item_segment2||
            ', item_segment3='||p_item_segment3||
            ', item_segment4='||p_item_segment4||
            ', item_segment5='||p_item_segment5||
            ', item_segment6='||p_item_segment6||
            ', item_segment7='||p_item_segment7||
            ', item_segment8='||p_item_segment8||
            ', item_segment9='||p_item_segment9);
      wsh_server_debug.debug_message(
            ', item_segment10='||p_item_segment10||
            ', item_segment11='||p_item_segment11||
            ', item_segment12='||p_item_segment12||
            ', item_segment13='||p_item_segment13||
            ', item_segment14='||p_item_segment14||
            ', item_segment15='||p_item_segment15||
            ', item_segment16='||p_item_segment16||
            ', item_segment17='||p_item_segment17||
            ', item_segment18='||p_item_segment18||
            ', item_segment19='||p_item_segment19||
            ', item_segment20='||p_item_segment20);
      wsh_server_debug.debug_message(
            ', primary_quantity='||p_primary_quantity||
            ', loc_segment5='||p_loc_segment5||
            ', loc_segment6='||p_loc_segment6||
            ', loc_segment7='||p_loc_segment7||
            ', loc_segment8='||p_loc_segment8||
            ', loc_segment9='||p_loc_segment9||
            ', loc_segment10='||p_loc_segment10||
            ', loc_segment11='||p_loc_segment11||
            ', loc_segment12='||p_loc_segment12||
            ', loc_segment13='||p_loc_segment13||
            ', loc_segment14='||p_loc_segment14||
            ', loc_segment15='||p_loc_segment15);
      wsh_server_debug.debug_message(
            ', loc_segment16='||p_loc_segment16||
            ', loc_segment17='||p_loc_segment17||
            ', loc_segment18='||p_loc_segment18||
            ', loc_segment19='||p_loc_segment19||
            ', loc_segment20='||p_loc_segment20||
            ', dsp_segment4='||p_dsp_segment4||
            ', dsp_segment5='||p_dsp_segment5||
            ', dsp_segment6='||p_dsp_segment6||
            ', dsp_segment7='||p_dsp_segment7||
            ', dsp_segment8='||p_dsp_segment8||
            ', dsp_segment9='||p_dsp_segment9);
      wsh_server_debug.debug_message(
            ', dsp_segment10='||p_dsp_segment10||
            ', dsp_segment11='||p_dsp_segment11||
            ', dsp_segment12='||p_dsp_segment12||
            ', dsp_segment13='||p_dsp_segment13||
            ', dsp_segment14='||p_dsp_segment14||
            ', dsp_segment15='||p_dsp_segment15||
            ', dsp_segment16='||p_dsp_segment16||
            ', dsp_segment17='||p_dsp_segment17||
            ', dsp_segment18='||p_dsp_segment18||
            ', dsp_segment19='||p_dsp_segment19);
      wsh_server_debug.debug_message(
            ', dsp_segment20='||p_dsp_segment20||
            ', dsp_segment21='||p_dsp_segment21||
            ', dsp_segment22='||p_dsp_segment22||
            ', dsp_segment23='||p_dsp_segment23||
            ', dsp_segment24='||p_dsp_segment24||
            ', dsp_segment25='||p_dsp_segment25||
            ', dsp_segment26='||p_dsp_segment26||
            ', dsp_segment27='||p_dsp_segment27||
            ', dsp_segment28='||p_dsp_segment28||
            ', dsp_segment29='||p_dsp_segment29||
            ', dsp_segment30='||p_dsp_segment30);
      wsh_server_debug.debug_message(
            ', transaction_source_name='||p_trx_source_name||
            ', reason_id='||p_reason_id||
            ', transaction_cost='||p_trx_cost||
            ', ussgl_transaction_code='||p_ussgl_transaction_code||
            ', wip_entity_type='||p_wip_entity_type||
            ', schedule_id='||p_schedule_id||
            ', employee_code='||p_employee_code||
            ', department_id='||p_department_id||
            ', schedule_update_code='||p_schedule_update_code||
            ', setup_teardown_code='||p_setup_teardown_code);
      wsh_server_debug.debug_message(
            ', primary_switch='||p_primary_switch||
            ', mrp_code='||p_mrp_code||
            ', operation_seq_num='||p_operation_seq_num||
            ', repetitive_line_id='||p_repetitive_line_id||
            ', customer_ship_id='||p_customer_ship_id||
            ', line_item_num='||p_line_item_num||
            ', receiving_document='||p_receiving_document||
            ', rcv_transaction_id='||p_rcv_transaction_id||
            ', vendor_lot_number='||p_vendor_lot_number||
            ', transfer_locator='||p_transfer_locator);
      wsh_server_debug.debug_message(
            ', xfer_loc_segment1='||p_xfer_loc_segment1||
            ', xfer_loc_segment2='||p_xfer_loc_segment2||
            ', xfer_loc_segment3='||p_xfer_loc_segment3||
            ', xfer_loc_segment4='||p_xfer_loc_segment4||
            ', xfer_loc_segment5='||p_xfer_loc_segment5||
            ', xfer_loc_segment6='||p_xfer_loc_segment6||
            ', xfer_loc_segment7='||p_xfer_loc_segment7||
            ', xfer_loc_segment8='||p_xfer_loc_segment8||
            ', xfer_loc_segment9='||p_xfer_loc_segment9||
            ', xfer_loc_segment10='||p_xfer_loc_segment10);
      wsh_server_debug.debug_message(
            ', xfer_loc_segment11='||p_xfer_loc_segment11||
            ', xfer_loc_segment12='||p_xfer_loc_segment12||
            ', xfer_loc_segment13='||p_xfer_loc_segment13||
            ', xfer_loc_segment14='||p_xfer_loc_segment14||
            ', xfer_loc_segment15='||p_xfer_loc_segment15||
            ', xfer_loc_segment16='||p_xfer_loc_segment16||
            ', xfer_loc_segment17='||p_xfer_loc_segment17||
            ', xfer_loc_segment18='||p_xfer_loc_segment18||
            ', xfer_loc_segment19='||p_xfer_loc_segment19||
            ', xfer_loc_segment20='||p_xfer_loc_segment20);
      wsh_server_debug.debug_message(
            ', transportation_cost='||p_transportation_cost||
            ', transportation_account='||p_transportation_account||
            ', transfer_cost='||p_transfer_cost||
            ', containers='||p_containers||
            ', new_average_cost='||p_new_average_cost||
            ', value_change='||p_value_change||
            ', percentage_change='||p_percentage_change||
            ', demand_source_header_id='||p_demand_source_header_id||
            ', demand_source_line='||p_demand_source_line||
            ', demand_source_delivery='||p_demand_source_delivery);
      wsh_server_debug.debug_message(
            ', negative_req_flag='||p_negative_req_flag||
            ', error_explanation='||p_error_explanation||
            ', shippable_flag='||p_shippable_flag||
            ', error_code='||p_error_code||
            ', attribute_category='||p_attribute_category||
            ', attribute1='||p_attribute1||
            ', attribute2='||p_attribute2||
            ', attribute3='||p_attribute3||
            ', attribute4='||p_attribute4||
            ', attribute5='||p_attribute5);
      wsh_server_debug.debug_message(
            ', attribute6='||p_attribute6||
            ', attribute7='||p_attribute7||
            ', attribute8='||p_attribute8||
            ', attribute9='||p_attribute9||
            ', attribute10='||p_attribute10||
            ', attribute11='||p_attribute11||
            ', attribute12='||p_attribute12||
            ', attribute13='||p_attribute13||
            ', attribute14='||p_attribute14||
            ', attribute15='||p_attribute15);
      wsh_server_debug.debug_message(
            ', requisition_distribution_id='||p_requisition_distribution_id||
            ', reservation_quantity='||p_reservation_quantity||
            ', shipped_quantity='||p_shipped_quantity||
            ', locator_name='||p_locator_name||
            ', to_task_id='||p_to_task_id||
            ', source_task_id='||p_source_task_id||
            ', to_project_id='||p_to_project_id||
            ', source_project_id='||p_source_project_id||
            ', pa_expenditure_org_id='||p_pa_expenditure_org_id||
            ', expenditure_type='||p_expenditure_type);
      wsh_server_debug.debug_message(
            ', final_completion_flag='||p_final_completion_flag||
            ', transfer_percentage='||p_transfer_percentage||
            ', transaction_sequence_id='||p_trx_sequence_id||
            ', material_account='||p_material_account||
            ', material_overhead_account='||p_material_overhead_account||
            ', resource_account='||p_resource_account||
            ', outside_processing_account='||p_outside_processing_account||
            ', overhead_account='||p_overhead_account);
      wsh_server_debug.debug_message(
            ', bom_revision='||p_bom_revision||
            ', routing_revision='||p_routing_revision||
            ', bom_revision_date='||p_bom_revision_date||
            ', routing_revision_date='||p_routing_revision_date||
            ', alternate_bom_designator='||p_alternate_bom_designator||
            ', alternate_routing_designator='||p_alternate_routing_designator||
            ', accounting_class='||p_accounting_class||
            ', demand_class='||p_demand_class);
      wsh_server_debug.debug_message(
            ', parent_id='||p_parent_id||
            ', substitution_type_id='||p_substitution_type_id||
            ', substitution_item_id='||p_substitution_item_id||
            ', schedule_group='||p_schedule_group||
            ', build_sequence='||p_build_sequence||
            ', schedule_number='||p_schedule_number||
            ', scheduled_flag='||p_scheduled_flag||
            ', flow_schedule='||p_flow_schedule||
            ', cost_group_id='||p_cost_group_id );
*/

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
          WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
          WSH_DEBUG_SV.log(l_module_name,'X_TRX_INTERFACE_ID',X_TRX_INTERFACE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_HEADER_ID',P_TRX_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_ID',P_TRX_SOURCE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY_CODE',P_SUBINVENTORY_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_QUANTITY',P_TRX_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_DATE',P_TRANSACTION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT1',P_DSP_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT2',P_DSP_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT3',P_DSP_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_TYPE_ID',P_TRX_SOURCE_TYPE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_ACTION_ID',P_TRX_ACTION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_TYPE_ID',P_TRX_TYPE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DISTRIBUTION_ACCOUNT_ID',P_DISTRIBUTION_ACCOUNT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT1',P_DST_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT2',P_DST_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT3',P_DST_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT4',P_DST_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT5',P_DST_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT6',P_DST_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT7',P_DST_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT8',P_DST_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT9',P_DST_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT10',P_DST_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT11',P_DST_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT12',P_DST_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT13',P_DST_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT14',P_DST_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT15',P_DST_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT16',P_DST_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT17',P_DST_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT18',P_DST_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT19',P_DST_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT20',P_DST_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT21',P_DST_SEGMENT21);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT22',P_DST_SEGMENT22);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT23',P_DST_SEGMENT23);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT24',P_DST_SEGMENT24);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT25',P_DST_SEGMENT25);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT26',P_DST_SEGMENT26);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT27',P_DST_SEGMENT27);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT28',P_DST_SEGMENT28);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT29',P_DST_SEGMENT29);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT30',P_DST_SEGMENT30);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_REFERENCE',P_TRX_REFERENCE);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_LINE_ID',P_TRX_SOURCE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_DELIVERY_ID',P_TRX_SOURCE_DELIVERY_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_REVISION',P_REVISION);
          WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_ID',P_LOCATOR_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT1',P_LOC_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT2',P_LOC_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT3',P_LOC_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT4',P_LOC_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_PICKING_LINE_ID',P_PICKING_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_SUBINVENTORY',P_TRANSFER_SUBINVENTORY);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_ORGANIZATION',P_TRANSFER_ORGANIZATION);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_LOCATION_ID',P_SHIP_TO_LOCATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUISITION_LINE_ID',P_REQUISITION_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_UOM',P_TRX_UOM);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_ID',P_DEMAND_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_NUMBER',P_SHIPMENT_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_EXPECTED_ARRIVAL_DATE',P_EXPECTED_ARRIVAL_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_ENCUMBRANCE_ACCOUNT',P_ENCUMBRANCE_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_ENCUMBRANCE_AMOUNT',P_ENCUMBRANCE_AMOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_MOVEMENT_ID',P_MOVEMENT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_CODE',P_FREIGHT_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_WAYBILL_AIRBILL',P_WAYBILL_AIRBILL);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'P_CREATION_DATE',P_CREATION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_CREATED_BY',P_CREATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUEST_ID',P_REQUEST_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_APPLICATION_ID',P_PROGRAM_APPLICATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_ID',P_PROGRAM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_UPDATE_DATE',P_PROGRAM_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_PROCESS_FLAG',P_PROCESS_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_MODE',P_TRX_MODE);
          WSH_DEBUG_SV.log(l_module_name,'P_LOCK_FLAG',P_LOCK_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_ACCT_PERIOD_ID',P_ACCT_PERIOD_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUIRED_FLAG',P_REQUIRED_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CODE',P_CURRENCY_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CONVERSION_TYPE',P_CURRENCY_CONVERSION_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CONVERSION_DATE',P_CURRENCY_CONVERSION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CONVERSION_RATE',P_CURRENCY_CONVERSION_RATE);
          WSH_DEBUG_SV.log(l_module_name,'P_PROJECT_ID',P_PROJECT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TASK_ID',P_TASK_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_REQUIRED',P_VALIDATION_REQUIRED);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT1',P_ITEM_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT2',P_ITEM_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT3',P_ITEM_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT4',P_ITEM_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT5',P_ITEM_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT6',P_ITEM_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT7',P_ITEM_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT8',P_ITEM_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT9',P_ITEM_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT10',P_ITEM_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT11',P_ITEM_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT12',P_ITEM_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT13',P_ITEM_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT14',P_ITEM_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT15',P_ITEM_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT16',P_ITEM_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT17',P_ITEM_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT18',P_ITEM_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT19',P_ITEM_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT20',P_ITEM_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_QUANTITY',P_PRIMARY_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT5',P_LOC_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT6',P_LOC_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT7',P_LOC_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT8',P_LOC_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT9',P_LOC_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT10',P_LOC_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT11',P_LOC_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT12',P_LOC_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT13',P_LOC_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT14',P_LOC_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT15',P_LOC_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT16',P_LOC_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT17',P_LOC_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT18',P_LOC_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT19',P_LOC_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT20',P_LOC_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT4',P_DSP_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT5',P_DSP_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT6',P_DSP_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT7',P_DSP_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT8',P_DSP_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT9',P_DSP_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT10',P_DSP_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT11',P_DSP_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT12',P_DSP_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT13',P_DSP_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT14',P_DSP_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT15',P_DSP_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT16',P_DSP_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT17',P_DSP_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT18',P_DSP_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT19',P_DSP_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT20',P_DSP_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT21',P_DSP_SEGMENT21);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT22',P_DSP_SEGMENT22);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT23',P_DSP_SEGMENT23);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT24',P_DSP_SEGMENT24);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT25',P_DSP_SEGMENT25);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT26',P_DSP_SEGMENT26);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT27',P_DSP_SEGMENT27);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT28',P_DSP_SEGMENT28);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT29',P_DSP_SEGMENT29);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT30',P_DSP_SEGMENT30);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_NAME',P_TRX_SOURCE_NAME);
          WSH_DEBUG_SV.log(l_module_name,'P_REASON_ID',P_REASON_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_COST',P_TRX_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_USSGL_TRANSACTION_CODE',P_USSGL_TRANSACTION_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_WIP_ENTITY_TYPE',P_WIP_ENTITY_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_ID',P_SCHEDULE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_EMPLOYEE_CODE',P_EMPLOYEE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_DEPARTMENT_ID',P_DEPARTMENT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_UPDATE_CODE',P_SCHEDULE_UPDATE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_SETUP_TEARDOWN_CODE',P_SETUP_TEARDOWN_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_SWITCH',P_PRIMARY_SWITCH);
          WSH_DEBUG_SV.log(l_module_name,'P_MRP_CODE',P_MRP_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_OPERATION_SEQ_NUM',P_OPERATION_SEQ_NUM);
          WSH_DEBUG_SV.log(l_module_name,'P_REPETITIVE_LINE_ID',P_REPETITIVE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_SHIP_ID',P_CUSTOMER_SHIP_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_LINE_ITEM_NUM',P_LINE_ITEM_NUM);
          WSH_DEBUG_SV.log(l_module_name,'P_RECEIVING_DOCUMENT',P_RECEIVING_DOCUMENT);
          WSH_DEBUG_SV.log(l_module_name,'P_RCV_TRANSACTION_ID',P_RCV_TRANSACTION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_VENDOR_LOT_NUMBER',P_VENDOR_LOT_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_LOCATOR',P_TRANSFER_LOCATOR);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT1',P_XFER_LOC_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT2',P_XFER_LOC_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT3',P_XFER_LOC_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT4',P_XFER_LOC_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT5',P_XFER_LOC_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT6',P_XFER_LOC_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT7',P_XFER_LOC_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT8',P_XFER_LOC_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT9',P_XFER_LOC_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT10',P_XFER_LOC_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT11',P_XFER_LOC_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT12',P_XFER_LOC_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT13',P_XFER_LOC_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT14',P_XFER_LOC_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT15',P_XFER_LOC_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT16',P_XFER_LOC_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT17',P_XFER_LOC_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT18',P_XFER_LOC_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT19',P_XFER_LOC_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT20',P_XFER_LOC_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSPORTATION_COST',P_TRANSPORTATION_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSPORTATION_ACCOUNT',P_TRANSPORTATION_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_COST',P_TRANSFER_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_CONTAINERS',P_CONTAINERS);
          WSH_DEBUG_SV.log(l_module_name,'P_NEW_AVERAGE_COST',P_NEW_AVERAGE_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_VALUE_CHANGE',P_VALUE_CHANGE);
          WSH_DEBUG_SV.log(l_module_name,'P_PERCENTAGE_CHANGE',P_PERCENTAGE_CHANGE);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_SOURCE_HEADER_ID',P_DEMAND_SOURCE_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_SOURCE_LINE',P_DEMAND_SOURCE_LINE);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_SOURCE_DELIVERY',P_DEMAND_SOURCE_DELIVERY);
          WSH_DEBUG_SV.log(l_module_name,'P_NEGATIVE_REQ_FLAG',P_NEGATIVE_REQ_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_ERROR_EXPLANATION',P_ERROR_EXPLANATION);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIPPABLE_FLAG',P_SHIPPABLE_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_ERROR_CODE',P_ERROR_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE_CATEGORY',P_ATTRIBUTE_CATEGORY);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE1',P_ATTRIBUTE1);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE2',P_ATTRIBUTE2);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE3',P_ATTRIBUTE3);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE4',P_ATTRIBUTE4);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE5',P_ATTRIBUTE5);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE6',P_ATTRIBUTE6);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE7',P_ATTRIBUTE7);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE8',P_ATTRIBUTE8);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE9',P_ATTRIBUTE9);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE10',P_ATTRIBUTE10);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE11',P_ATTRIBUTE11);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE12',P_ATTRIBUTE12);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE13',P_ATTRIBUTE13);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE14',P_ATTRIBUTE14);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE15',P_ATTRIBUTE15);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUISITION_DISTRIBUTION_ID',P_REQUISITION_DISTRIBUTION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_RESERVATION_QUANTITY',P_RESERVATION_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIPPED_QUANTITY',P_SHIPPED_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM',P_INVENTORY_ITEM);
          WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_NAME',P_LOCATOR_NAME);
          WSH_DEBUG_SV.log(l_module_name,'P_TO_TASK_ID',P_TO_TASK_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_TASK_ID',P_SOURCE_TASK_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TO_PROJECT_ID',P_TO_PROJECT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_PROJECT_ID',P_SOURCE_PROJECT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PA_EXPENDITURE_ORG_ID',P_PA_EXPENDITURE_ORG_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_EXPENDITURE_TYPE',P_EXPENDITURE_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_FINAL_COMPLETION_FLAG',P_FINAL_COMPLETION_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_PERCENTAGE',P_TRANSFER_PERCENTAGE);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SEQUENCE_ID',P_TRX_SEQUENCE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_MATERIAL_ACCOUNT',P_MATERIAL_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_MATERIAL_OVERHEAD_ACCOUNT',P_MATERIAL_OVERHEAD_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_RESOURCE_ACCOUNT',P_RESOURCE_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_OUTSIDE_PROCESSING_ACCOUNT',P_OUTSIDE_PROCESSING_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_OVERHEAD_ACCOUNT',P_OVERHEAD_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_BOM_REVISION',P_BOM_REVISION);
          WSH_DEBUG_SV.log(l_module_name,'P_ROUTING_REVISION',P_ROUTING_REVISION);
          WSH_DEBUG_SV.log(l_module_name,'P_BOM_REVISION_DATE',P_BOM_REVISION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_ROUTING_REVISION_DATE',P_ROUTING_REVISION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_ALTERNATE_BOM_DESIGNATOR',P_ALTERNATE_BOM_DESIGNATOR);
          WSH_DEBUG_SV.log(l_module_name,'P_ALTERNATE_ROUTING_DESIGNATOR',P_ALTERNATE_ROUTING_DESIGNATOR);
          WSH_DEBUG_SV.log(l_module_name,'P_ACCOUNTING_CLASS',P_ACCOUNTING_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_CLASS',P_DEMAND_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'P_PARENT_ID',P_PARENT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SUBSTITUTION_TYPE_ID',P_SUBSTITUTION_TYPE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SUBSTITUTION_ITEM_ID',P_SUBSTITUTION_ITEM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_GROUP',P_SCHEDULE_GROUP);
          WSH_DEBUG_SV.log(l_module_name,'P_BUILD_SEQUENCE',P_BUILD_SEQUENCE);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_NUMBER',P_SCHEDULE_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULED_FLAG',P_SCHEDULED_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_FLOW_SCHEDULE',P_FLOW_SCHEDULE);
          WSH_DEBUG_SV.log(l_module_name,'P_COST_GROUP_ID',P_COST_GROUP_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_CONTENT_LPN_ID',P_CONTENT_LPN_ID);
-- HW OPMCONV. Added debugging msgs
          WSH_DEBUG_SV.log(l_module_name,'P_SECONDARY_TRX_QUANTITY',P_SECONDARY_TRX_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'p_secondary_uom_code',p_secondary_uom_code);
      END IF;
      --
      fnd_profile.get('USER_ID',g_userid);

      -- Set interface id if necessary
      IF x_trx_interface_id IS NULL THEN
         OPEN get_interface_id;
         FETCH get_interface_id INTO x_trx_interface_id;
         CLOSE get_interface_id;
      END IF;

      INSERT INTO mtl_transactions_interface (
         source_code,
         source_line_id,
         source_header_id,
         inventory_item_id,
         subinventory_code,
         transaction_quantity,
         transaction_date,
         organization_id,
         dsp_segment1,
         dsp_segment2,
         dsp_segment3,
         transaction_source_type_id,
         transaction_action_id,
         transaction_type_id,
         distribution_account_id,
         dst_segment1,
         dst_segment2,
         dst_segment3,
         dst_segment4,
         dst_segment5,
         dst_segment6,
         dst_segment7,
         dst_segment8,
         dst_segment9,
         dst_segment10,
         dst_segment11,
         dst_segment12,
         dst_segment13,
         dst_segment14,
         dst_segment15,
         dst_segment16,
         dst_segment17,
         dst_segment18,
         dst_segment19,
         dst_segment20,
         dst_segment21,
         dst_segment22,
         dst_segment23,
         dst_segment24,
         dst_segment25,
         dst_segment26,
         dst_segment27,
         dst_segment28,
         dst_segment29,
         dst_segment30,
         transaction_reference,
         trx_source_line_id,
         trx_source_delivery_id,
         revision,
         locator_id,
         loc_segment1,
         loc_segment2,
         loc_segment3,
         loc_segment4,
         picking_line_id,
         transfer_subinventory,
         transfer_organization,
         ship_to_location_id,
         requisition_line_id,
         transaction_uom,
         transaction_interface_id,
         demand_id,
         shipment_number,
         expected_arrival_date,
         encumbrance_account,
         encumbrance_amount,
         movement_id,
         freight_code,
         waybill_airbill,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         process_flag,
         transaction_mode,
         lock_flag,
         transaction_header_id,
         acct_period_id,
         transaction_source_id,
         required_flag,
         currency_code,
         currency_conversion_type,
         currency_conversion_date,
         currency_conversion_rate,
         project_id,
         task_id,
         validation_required,
         item_segment1,
         item_segment2,
         item_segment3,
         item_segment4,
         item_segment5,
         item_segment6,
         item_segment7,
         item_segment8,
         item_segment9,
         item_segment10,
         item_segment11,
         item_segment12,
         item_segment13,
         item_segment14,
         item_segment15,
         item_segment16,
         item_segment17,
         item_segment18,
         item_segment19,
         item_segment20,
         primary_quantity,
         loc_segment5,
         loc_segment6,
         loc_segment7,
         loc_segment8,
         loc_segment9,
         loc_segment10,
         loc_segment11,
         loc_segment12,
         loc_segment13,
         loc_segment14,
         loc_segment15,
         loc_segment16,
         loc_segment17,
         loc_segment18,
         loc_segment19,
         loc_segment20,
         dsp_segment4,
         dsp_segment5,
         dsp_segment6,
         dsp_segment7,
         dsp_segment8,
         dsp_segment9,
         dsp_segment10,
         dsp_segment11,
         dsp_segment12,
         dsp_segment13,
         dsp_segment14,
         dsp_segment15,
         dsp_segment16,
         dsp_segment17,
         dsp_segment18,
         dsp_segment19,
         dsp_segment20,
         dsp_segment21,
         dsp_segment22,
         dsp_segment23,
         dsp_segment24,
         dsp_segment25,
         dsp_segment26,
         dsp_segment27,
         dsp_segment28,
         dsp_segment29,
         dsp_segment30,
         transaction_source_name,
         reason_id,
         transaction_cost,
         ussgl_transaction_code,
         wip_entity_type,
         schedule_id,
         employee_code,
         department_id,
         schedule_update_code,
         setup_teardown_code,
         primary_switch,
         mrp_code,
         operation_seq_num,
         repetitive_line_id,
         customer_ship_id,
         line_item_num,
         receiving_document,
         rcv_transaction_id,
         vendor_lot_number,
         transfer_locator,
         xfer_loc_segment1,
         xfer_loc_segment2,
         xfer_loc_segment3,
         xfer_loc_segment4,
         xfer_loc_segment5,
         xfer_loc_segment6,
         xfer_loc_segment7,
         xfer_loc_segment8,
         xfer_loc_segment9,
         xfer_loc_segment10,
         xfer_loc_segment11,
         xfer_loc_segment12,
         xfer_loc_segment13,
         xfer_loc_segment14,
         xfer_loc_segment15,
         xfer_loc_segment16,
         xfer_loc_segment17,
         xfer_loc_segment18,
         xfer_loc_segment19,
         xfer_loc_segment20,
         transportation_cost,
         transportation_account,
         transfer_cost,
         containers,
         new_average_cost,
         value_change,
         percentage_change,
         demand_source_header_id,
         demand_source_line,
         demand_source_delivery,
         negative_req_flag,
         error_explanation,
         shippable_flag,
         error_code,
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
         attribute15,
         requisition_distribution_id,
         reservation_quantity,
         shipped_quantity,
         inventory_item,
         locator_name,
         to_task_id,
         source_task_id,
         to_project_id,
         source_project_id,
         pa_expenditure_org_id,
         expenditure_type,
         final_completion_flag,
         transfer_percentage,
         transaction_sequence_id,
         material_account,
         material_overhead_account,
         resource_account,
         outside_processing_account,
         overhead_account,
         bom_revision,
         routing_revision,
         bom_revision_date,
         routing_revision_date,
         alternate_bom_designator,
         alternate_routing_designator,
         accounting_class,
         demand_class,
         parent_id,
         substitution_type_id,
         substitution_item_id,
         schedule_group,
         build_sequence,
         schedule_number,
         scheduled_flag,
         flow_schedule,
         cost_group_id,
         content_lpn_id, 	/* Bug 1549125 */
-- HW OPMCONV. Added secondary_qty and secondary_uom
        SECONDARY_TRANSACTION_QUANTITY,
        SECONDARY_UOM_CODE
      ) VALUES (
         p_source_code,
         p_source_line_id,
         p_source_header_id,
         p_inventory_item_id,
         p_subinventory_code,
         p_trx_quantity,
         p_transaction_date,
         p_organization_id,
         p_dsp_segment1,
         p_dsp_segment2,
         p_dsp_segment3,
         p_trx_source_type_id,
         p_trx_action_id,
         p_trx_type_id,
         p_distribution_account_id,
         p_dst_segment1,
         p_dst_segment2,
         p_dst_segment3,
         p_dst_segment4,
         p_dst_segment5,
         p_dst_segment6,
         p_dst_segment7,
         p_dst_segment8,
         p_dst_segment9,
         p_dst_segment10,
         p_dst_segment11,
         p_dst_segment12,
         p_dst_segment13,
         p_dst_segment14,
         p_dst_segment15,
         p_dst_segment16,
         p_dst_segment17,
         p_dst_segment18,
         p_dst_segment19,
         p_dst_segment20,
         p_dst_segment21,
         p_dst_segment22,
         p_dst_segment23,
         p_dst_segment24,
         p_dst_segment25,
         p_dst_segment26,
         p_dst_segment27,
         p_dst_segment28,
         p_dst_segment29,
         p_dst_segment30,
         p_trx_reference,
         p_trx_source_line_id,
         p_trx_source_delivery_id,
         p_revision,
         p_locator_id,
         p_loc_segment1,
         p_loc_segment2,
         p_loc_segment3,
         p_loc_segment4,
         p_picking_line_id,
         p_transfer_subinventory,
         p_transfer_organization,
         p_ship_to_location_id,
         p_requisition_line_id,
         p_trx_uom,
         x_trx_interface_id,
         p_demand_id,
         p_shipment_number,
         p_expected_arrival_date,
         p_encumbrance_account,
         p_encumbrance_amount,
         p_movement_id,
         p_freight_code,
         p_waybill_airbill,  --Bug 7503285
         NVL(p_last_update_date,SYSDATE),
         NVL(p_last_updated_by,g_userid),
         NVL(p_creation_date,SYSDATE),
         NVL( p_created_by,g_userid),
         p_last_update_login,
         p_request_id,
         p_program_application_id,
         p_program_id,
         p_program_update_date,
         p_process_flag,
         p_trx_mode,
         p_lock_flag,
         p_trx_header_id,
         p_acct_period_id,
         p_trx_source_id,
         p_required_flag,
         p_currency_code,
         p_currency_conversion_type,
         p_currency_conversion_date,
         p_currency_conversion_rate,
         p_project_id,
         p_task_id,
         p_validation_required,
         p_item_segment1,
         p_item_segment2,
         p_item_segment3,
         p_item_segment4,
         p_item_segment5,
         p_item_segment6,
         p_item_segment7,
         p_item_segment8,
         p_item_segment9,
         p_item_segment10,
         p_item_segment11,
         p_item_segment12,
         p_item_segment13,
         p_item_segment14,
         p_item_segment15,
         p_item_segment16,
         p_item_segment17,
         p_item_segment18,
         p_item_segment19,
         p_item_segment20,
         p_primary_quantity,
         p_loc_segment5,
         p_loc_segment6,
         p_loc_segment7,
         p_loc_segment8,
         p_loc_segment9,
         p_loc_segment10,
         p_loc_segment11,
         p_loc_segment12,
         p_loc_segment13,
         p_loc_segment14,
         p_loc_segment15,
         p_loc_segment16,
         p_loc_segment17,
         p_loc_segment18,
         p_loc_segment19,
         p_loc_segment20,
         p_dsp_segment4,
         p_dsp_segment5,
         p_dsp_segment6,
         p_dsp_segment7,
         p_dsp_segment8,
         p_dsp_segment9,
         p_dsp_segment10,
         p_dsp_segment11,
         p_dsp_segment12,
         p_dsp_segment13,
         p_dsp_segment14,
         p_dsp_segment15,
         p_dsp_segment16,
         p_dsp_segment17,
         p_dsp_segment18,
         p_dsp_segment19,
         p_dsp_segment20,
         p_dsp_segment21,
         p_dsp_segment22,
         p_dsp_segment23,
         p_dsp_segment24,
         p_dsp_segment25,
         p_dsp_segment26,
         p_dsp_segment27,
         p_dsp_segment28,
         p_dsp_segment29,
         p_dsp_segment30,
         p_trx_source_name,
         p_reason_id,
         p_trx_cost,
         p_ussgl_transaction_code,
         p_wip_entity_type,
         p_schedule_id,
         p_employee_code,
         p_department_id,
         p_schedule_update_code,
         p_setup_teardown_code,
         p_primary_switch,
         p_mrp_code,
         p_operation_seq_num,
         p_repetitive_line_id,
         p_customer_ship_id,
         p_line_item_num,
         p_receiving_document,
         p_rcv_transaction_id,
         p_vendor_lot_number,
         p_transfer_locator,
         p_xfer_loc_segment1,
         p_xfer_loc_segment2,
         p_xfer_loc_segment3,
         p_xfer_loc_segment4,
         p_xfer_loc_segment5,
         p_xfer_loc_segment6,
         p_xfer_loc_segment7,
         p_xfer_loc_segment8,
         p_xfer_loc_segment9,
         p_xfer_loc_segment10,
         p_xfer_loc_segment11,
         p_xfer_loc_segment12,
         p_xfer_loc_segment13,
         p_xfer_loc_segment14,
         p_xfer_loc_segment15,
         p_xfer_loc_segment16,
         p_xfer_loc_segment17,
         p_xfer_loc_segment18,
         p_xfer_loc_segment19,
         p_xfer_loc_segment20,
         p_transportation_cost,
         p_transportation_account,
         p_transfer_cost,
         p_containers,
         p_new_average_cost,
         p_value_change,
         p_percentage_change,
         p_demand_source_header_id,
         p_demand_source_line,
         p_demand_source_delivery,
         p_negative_req_flag,
         p_error_explanation,
         p_shippable_flag,
         p_error_code,
         p_attribute_category,
         p_attribute1,
         p_attribute2,
         p_attribute3,
         p_attribute4,
         p_attribute5,
         p_attribute6,
         p_attribute7,
         p_attribute8,
         p_attribute9,
         p_attribute10,
         p_attribute11,
         p_attribute12,
         p_attribute13,
         p_attribute14,
         p_attribute15,
         p_requisition_distribution_id,
         p_reservation_quantity,
         p_shipped_quantity,
         p_inventory_item,
         p_locator_name,
         p_to_task_id,
         p_source_task_id,
         p_to_project_id,
         p_source_project_id,
         p_pa_expenditure_org_id,
         p_expenditure_type,
         p_final_completion_flag,
         p_transfer_percentage,
         p_trx_sequence_id,
         p_material_account,
         p_material_overhead_account,
         p_resource_account,
         p_outside_processing_account,
         p_overhead_account,
         p_bom_revision,
         p_routing_revision,
         p_bom_revision_date,
         p_routing_revision_date,
         p_alternate_bom_designator,
         p_alternate_routing_designator,
         p_accounting_class,
         p_demand_class,
         p_parent_id,
         p_substitution_type_id,
         p_substitution_item_id,
         p_schedule_group,
         p_build_sequence,
         p_schedule_number,
         p_scheduled_flag,
         p_flow_schedule,
         p_cost_group_id,
         p_content_lpn_id,  -- Bug 1549125
-- HW OPMCONV. Added secondary_qty and grade
         p_secondary_trx_quantity,
         p_secondary_uom_code
      );
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Rows inserted',SQL%ROWCOUNT);
      END IF;

      OPEN row_id;

      FETCH row_id INTO x_rowid;

      IF (row_id%NOTFOUND) then
/*         wsh_server_debug.log_event('WSH_TRX_HANDLER.INSERT_ROW',
            'END',
            'No rowid found. Raising NO_DATA_FOUND.');
*/
         CLOSE row_id;
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name,'NO_DATA_FOUND');
         END IF;
         RAISE  NO_DATA_FOUND;
      END IF;

      CLOSE row_id;

/*      wsh_server_debug.log_event('WSH_TRX_HANDLER.INSERT_ROW',
         'END',
         'End of procedure INSERT_ROW');
*/
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
   END Insert_Row;

-- ===========================================================================
--
-- Name:
--
--   update_row
--
-- Description:
--
--   Called by the client to update a row in the
--   MTL_TRANSACTIONS_INTERFACE table.
--
-- ===========================================================================

   PROCEDURE Update_Row (
      x_rowid					IN OUT NOCOPY  VARCHAR2,
      p_trx_interface_id			IN NUMBER,
      p_trx_header_id              IN NUMBER,
      p_trx_source_id              IN NUMBER,
      p_source_code				IN VARCHAR2,
      p_source_line_id				IN NUMBER,
      p_source_header_id			IN NUMBER,
      p_inventory_item_id			IN NUMBER,
      p_subinventory_code			IN VARCHAR2,
      p_trx_quantity				IN NUMBER,
      p_transaction_date			IN DATE,
      p_organization_id				IN NUMBER,
      p_dsp_segment1				IN VARCHAR2,
      p_dsp_segment2				IN VARCHAR2,
      p_dsp_segment3				IN VARCHAR2,
      p_trx_source_type_id			IN NUMBER,
      p_trx_action_id				IN NUMBER,
      p_trx_type_id				IN NUMBER,
      p_distribution_account_id			IN NUMBER,
      p_dst_segment1				IN VARCHAR2,
      p_dst_segment2				IN VARCHAR2,
      p_dst_segment3				IN VARCHAR2,
      p_dst_segment4				IN VARCHAR2,
      p_dst_segment5				IN VARCHAR2,
      p_dst_segment6				IN VARCHAR2,
      p_dst_segment7				IN VARCHAR2,
      p_dst_segment8				IN VARCHAR2,
      p_dst_segment9				IN VARCHAR2,
      p_dst_segment10				IN VARCHAR2,
      p_dst_segment11				IN VARCHAR2,
      p_dst_segment12				IN VARCHAR2,
      p_dst_segment13				IN VARCHAR2,
      p_dst_segment14				IN VARCHAR2,
      p_dst_segment15				IN VARCHAR2,
      p_dst_segment16				IN VARCHAR2,
      p_dst_segment17				IN VARCHAR2,
      p_dst_segment18				IN VARCHAR2,
      p_dst_segment19				IN VARCHAR2,
      p_dst_segment20				IN VARCHAR2,
      p_dst_segment21				IN VARCHAR2,
      p_dst_segment22				IN VARCHAR2,
      p_dst_segment23				IN VARCHAR2,
      p_dst_segment24				IN VARCHAR2,
      p_dst_segment25				IN VARCHAR2,
      p_dst_segment26				IN VARCHAR2,
      p_dst_segment27				IN VARCHAR2,
      p_dst_segment28				IN VARCHAR2,
      p_dst_segment29				IN VARCHAR2,
      p_dst_segment30				IN VARCHAR2,
      p_trx_reference				IN VARCHAR2,
      p_trx_source_line_id			IN NUMBER,
      p_trx_source_delivery_id			IN NUMBER,
      p_revision				IN VARCHAR2,
      p_locator_id				IN NUMBER,
      p_loc_segment1				IN VARCHAR2,
      p_loc_segment2				IN VARCHAR2,
      p_loc_segment3				IN VARCHAR2,
      p_loc_segment4				IN VARCHAR2,
      p_picking_line_id				IN NUMBER,
      p_transfer_subinventory			IN VARCHAR2,
      p_transfer_organization			IN NUMBER,
      p_ship_to_location_id			IN NUMBER,
      p_requisition_line_id			IN NUMBER,
      p_trx_uom					IN VARCHAR2,
      p_demand_id				IN NUMBER,
      p_shipment_number				IN VARCHAR2,
      p_expected_arrival_date             	IN DATE,
      p_encumbrance_account			IN NUMBER,
      p_encumbrance_amount			IN NUMBER,
      p_movement_id				IN NUMBER,
      p_freight_code				IN VARCHAR2,
      p_waybill_airbill				IN VARCHAR2,
      p_last_update_date			IN DATE,
      p_last_updated_by				IN NUMBER,
      p_last_update_login              		IN NUMBER DEFAULT NULL,
      p_request_id				IN NUMBER DEFAULT NULL,
      p_program_application_id                  IN NUMBER DEFAULT NULL,
      p_program_id                              IN NUMBER DEFAULT NULL,
      p_program_update_date                     IN DATE DEFAULT NULL,
      p_process_flag                            IN NUMBER DEFAULT 1,
      p_trx_mode                                IN NUMBER DEFAULT 3,
      p_lock_flag                               IN NUMBER DEFAULT 2,
      p_acct_period_id                          IN NUMBER DEFAULT NULL,
      p_required_flag                           IN VARCHAR2 DEFAULT NULL,
      p_currency_code                           IN VARCHAR2 DEFAULT NULL,
      p_currency_conversion_type                IN VARCHAR2 DEFAULT NULL,
      p_currency_conversion_date                IN DATE DEFAULT NULL,
      p_currency_conversion_rate                IN NUMBER DEFAULT NULL,
      p_project_id                              IN NUMBER DEFAULT NULL,
      p_task_id                                 IN NUMBER DEFAULT NULL,
      p_validation_required         		IN NUMBER DEFAULT NULL,
      p_item_segment1         			IN VARCHAR2 DEFAULT NULL,
      p_item_segment2         			IN VARCHAR2 DEFAULT NULL,
      p_item_segment3                		IN VARCHAR2 DEFAULT NULL,
      p_item_segment4                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment5                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment6                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment7                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment8                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment9                     	IN VARCHAR2 DEFAULT NULL,
      p_item_segment10                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment11                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment12                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment13                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment14                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment15                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment16                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment17                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment18                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment19                    	IN VARCHAR2 DEFAULT NULL,
      p_item_segment20                    	IN VARCHAR2 DEFAULT NULL,
      p_primary_quantity                  	IN NUMBER DEFAULT NULL,
      p_loc_segment5                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment6                      	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment7                      	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment8                      	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment9                      	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment10                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment11                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment12                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment13                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment14                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment15                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment16                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment17                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment18                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment19                     	IN VARCHAR2 DEFAULT NULL,
      p_loc_segment20                     	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment4                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment5                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment6                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment7                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment8                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment9                           	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment10                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment11                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment12                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment13                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment14                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment15                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment16                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment17                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment18                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment19                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment20                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment21                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment22                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment23                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment24                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment25                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment26                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment27                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment28                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment29                          	IN VARCHAR2 DEFAULT NULL,
      p_dsp_segment30                          	IN VARCHAR2 DEFAULT NULL,
      p_trx_source_name                         IN VARCHAR2 DEFAULT NULL,
      p_reason_id                    		IN NUMBER DEFAULT NULL,
      p_trx_cost                     		IN NUMBER DEFAULT NULL,
      p_ussgl_transaction_code      		IN VARCHAR2 DEFAULT NULL,
      p_wip_entity_type                  	IN NUMBER DEFAULT NULL,
      p_schedule_id                      	IN NUMBER DEFAULT NULL,
      p_employee_code                   	IN VARCHAR2 DEFAULT NULL,
      p_department_id                    	IN NUMBER DEFAULT NULL,
      p_schedule_update_code             	IN NUMBER DEFAULT NULL,
      p_setup_teardown_code              	IN NUMBER DEFAULT NULL,
      p_primary_switch                   	IN NUMBER DEFAULT NULL,
      p_mrp_code                         	IN NUMBER DEFAULT NULL,
      p_operation_seq_num                	IN NUMBER DEFAULT NULL,
      p_repetitive_line_id               	IN NUMBER DEFAULT NULL,
      p_customer_ship_id                  	IN NUMBER DEFAULT NULL,
      p_line_item_num             		IN NUMBER DEFAULT NULL,
      p_receiving_document        		IN VARCHAR2 DEFAULT NULL,
      p_rcv_transaction_id                	IN NUMBER DEFAULT NULL,
      p_vendor_lot_number                 	IN VARCHAR2 DEFAULT NULL,
      p_transfer_locator                  	IN NUMBER DEFAULT NULL,
      p_xfer_loc_segment1                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment2                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment3                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment4                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment5                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment6                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment7                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment8                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment9                 	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment10                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment11                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment12                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment13                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment14                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment15                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment16                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment17                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment18                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment19                	IN VARCHAR2 DEFAULT NULL,
      p_xfer_loc_segment20                	IN VARCHAR2 DEFAULT NULL,
      p_transportation_cost               	IN NUMBER DEFAULT NULL,
      p_transportation_account            	IN NUMBER DEFAULT NULL,
      p_transfer_cost                     	IN NUMBER DEFAULT NULL,
      p_containers                       	IN NUMBER DEFAULT NULL,
      p_new_average_cost                 	IN NUMBER DEFAULT NULL,
      p_value_change                     	IN NUMBER DEFAULT NULL,
      p_percentage_change                	IN NUMBER DEFAULT NULL,
      p_demand_source_header_id          	IN NUMBER DEFAULT NULL,
      p_demand_source_line           		IN VARCHAR2 DEFAULT NULL,
      p_demand_source_delivery      		IN VARCHAR2 DEFAULT NULL,
      p_negative_req_flag                	IN NUMBER DEFAULT NULL,
      p_error_explanation 			IN VARCHAR2 DEFAULT NULL,
      p_shippable_flag 				IN VARCHAR2 DEFAULT NULL,
      p_error_code 				IN VARCHAR2 DEFAULT NULL,
      p_attribute_category               	IN VARCHAR2 DEFAULT NULL,
      p_attribute1                 		IN VARCHAR2 DEFAULT NULL,
      p_attribute2      			IN VARCHAR2 DEFAULT NULL,
      p_attribute3                    		IN VARCHAR2 DEFAULT NULL,
      p_attribute4             			IN VARCHAR2 DEFAULT NULL,
      p_attribute5 				IN VARCHAR2 DEFAULT NULL,
      p_attribute6            			IN VARCHAR2 DEFAULT NULL,
      p_attribute7   				IN VARCHAR2 DEFAULT NULL,
      p_attribute8 				IN VARCHAR2 DEFAULT NULL,
      p_attribute9          			IN VARCHAR2 DEFAULT NULL,
      p_attribute10         			IN VARCHAR2 DEFAULT NULL,
      p_attribute11             		IN VARCHAR2 DEFAULT NULL,
      p_attribute12                       	IN VARCHAR2 DEFAULT NULL,
      p_attribute13                       	IN VARCHAR2 DEFAULT NULL,
      p_attribute14                       	IN VARCHAR2 DEFAULT NULL,
      p_attribute15                       	IN VARCHAR2 DEFAULT NULL,
      p_requisition_distribution_id      	IN NUMBER DEFAULT NULL,
      p_reservation_quantity             	IN NUMBER DEFAULT NULL,
      p_shipped_quantity                 	IN NUMBER DEFAULT NULL,
      p_inventory_item                    	IN VARCHAR2 DEFAULT NULL,
      p_locator_name                      	IN VARCHAR2 DEFAULT NULL,
      p_to_task_id                       	IN NUMBER DEFAULT NULL,
      p_source_task_id                   	IN NUMBER DEFAULT NULL,
      p_to_project_id                     	IN NUMBER DEFAULT NULL,
      p_source_project_id                 	IN NUMBER DEFAULT NULL,
      p_pa_expenditure_org_id             	IN NUMBER DEFAULT NULL,
      p_expenditure_type                  	IN VARCHAR2 DEFAULT NULL,
      p_final_completion_flag            	IN VARCHAR2 DEFAULT NULL,
      p_transfer_percentage              	IN NUMBER DEFAULT NULL,
      p_trx_sequence_id              		IN NUMBER DEFAULT NULL,
      p_material_account                 	IN NUMBER DEFAULT NULL,
      p_material_overhead_account        	IN NUMBER DEFAULT NULL,
      p_resource_account                 	IN NUMBER DEFAULT NULL,
      p_outside_processing_account       	IN NUMBER DEFAULT NULL,
      p_overhead_account                 	IN NUMBER DEFAULT NULL,
      p_bom_revision                  		IN VARCHAR2 DEFAULT NULL,
      p_routing_revision          		IN VARCHAR2 DEFAULT NULL,
      p_bom_revision_date              		IN DATE DEFAULT NULL,
      p_routing_revision_date          		IN DATE DEFAULT NULL,
      p_alternate_bom_designator      		IN VARCHAR2 DEFAULT NULL,
      p_alternate_routing_designator    	IN VARCHAR2 DEFAULT NULL,
      p_accounting_class             		IN VARCHAR2 DEFAULT NULL,
      p_demand_class                		IN VARCHAR2 DEFAULT NULL,
      p_parent_id                        	IN NUMBER DEFAULT NULL,
      p_substitution_type_id             	IN NUMBER DEFAULT NULL,
      p_substitution_item_id             	IN NUMBER DEFAULT NULL,
      p_schedule_group                   	IN NUMBER DEFAULT NULL,
      p_build_sequence                   	IN NUMBER DEFAULT NULL,
      p_schedule_number		     		IN VARCHAR2 DEFAULT NULL,
      p_scheduled_flag                   	IN NUMBER DEFAULT NULL,
      p_flow_schedule           		IN VARCHAR2 DEFAULT NULL,
      p_cost_group_id                    	IN NUMBER DEFAULT NULL,
-- HW OPMCONV. Added p_secondary_trx_quantity
-- and p_secondary_uom_code
      p_secondary_trx_quantity                  IN NUMBER DEFAULT NULL,
      p_secondary_uom_code                      IN VARCHAR2 DEFAULT NULL
      )
   IS
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROW';
   --
   BEGIN
/*      wsh_server_debug.log_event('WSH_TRX_HANDLER.INSERT_ROW',
         'START',
         'Start of procedure INSERT_ROW, input parameters:
            source_code='||p_source_code||
            ', source_line_id='||p_source_line_id||
            ', source_header_id='||p_source_header_id||
            ', inventory_item='||p_inventory_item||
            ', subinventory_code='||p_subinventory_code||
            ', transaction_quantity='||p_trx_quantity||
            ', transaction_date='||p_transaction_date||
            ', organization_id='||p_organization_id);
      wsh_server_debug.debug_message(
            ', dsp_segment1='||p_dsp_segment1||
            ', dsp_segment2='||p_dsp_segment2||
            ', dsp_segment3='||p_dsp_segment3||
            ', transaction_source_type_id='||p_trx_source_type_id||
            ', transaction_action_id='||p_trx_action_id||
            ', transaction_type_id='||p_trx_type_id||
            ', distribution_account_id='||p_distribution_account_id);
      wsh_server_debug.debug_message(
            ', dst_segment1='||p_dst_segment1||
            ', dst_segment2='||p_dst_segment2||
            ', dst_segment3='||p_dst_segment3||
            ', dst_segment4='||p_dst_segment4||
            ', dst_segment5='||p_dst_segment5||
            ', dst_segment6='||p_dst_segment6||
            ', dst_segment7='||p_dst_segment7||
            ', dst_segment8='||p_dst_segment8||
            ', dst_segment9='||p_dst_segment9||
            ', dst_segment10='||p_dst_segment10);
      wsh_server_debug.debug_message(
            ', dst_segment11='||p_dst_segment11||
            ', dst_segment12='||p_dst_segment12||
            ', dst_segment13='||p_dst_segment13||
            ', dst_segment14='||p_dst_segment14||
            ', dst_segment15='||p_dst_segment15||
            ', dst_segment16='||p_dst_segment16||
            ', dst_segment17='||p_dst_segment17||
            ', dst_segment18='||p_dst_segment18||
            ', dst_segment19='||p_dst_segment19||
            ', dst_segment20='||p_dst_segment20);
      wsh_server_debug.debug_message(
            ', dst_segment21='||p_dst_segment21||
            ', dst_segment22='||p_dst_segment22||
            ', dst_segment23='||p_dst_segment23||
            ', dst_segment24='||p_dst_segment24||
            ', dst_segment25='||p_dst_segment25||
            ', dst_segment26='||p_dst_segment26||
            ', dst_segment27='||p_dst_segment27||
            ', dst_segment28='||p_dst_segment28||
            ', dst_segment29='||p_dst_segment29||
            ', dst_segment30='||p_dst_segment30);
      wsh_server_debug.debug_message(
            ', transaction_reference='||p_trx_reference||
            ', trx_source_line_id='||p_trx_source_line_id||
            ', trx_source_delivery_id='||p_trx_source_delivery_id||
            ', revision='||p_revision||
            ', locator_id='||p_locator_id||
            ', loc_segment1='||p_loc_segment1||
            ', loc_segment2='||p_loc_segment2||
            ', loc_segment3='||p_loc_segment3||
            ', loc_segment4='||p_loc_segment4||
            ', picking_line_id='||p_picking_line_id||
            ', transfer_subinventory='||p_transfer_subinventory||
            ', transfer_organization='||p_transfer_organization);
      wsh_server_debug.debug_message(
            ', ship_to_location_id='||p_ship_to_location_id||
            ', requisition_line_id='||p_requisition_line_id||
            ', transaction_uom='||p_trx_uom||
            ', transaction_interface_id='||p_trx_interface_id||
            ', demand_id='||p_demand_id||
            ', shipment_number='||p_shipment_number||
            ', expected_arrival_date='||p_expected_arrival_date||
            ', encumbrance_account='||p_encumbrance_account||
            ', encumbrance_amount='||p_encumbrance_amount||
            ', movement_id='||p_movement_id);
      wsh_server_debug.debug_message(
            ', freight_code='||p_freight_code||
            ', waybill_airbill='||p_waybill_airbill||
            ', last_update_date='||p_last_update_date||
            ', last_updated_by='||p_last_updated_by||
            ', last_update_login='||p_last_update_login||
            ', request_id='||p_request_id||
            ', program_application_id='||p_program_application_id||
            ', program_id='||p_program_id||
            ', program_update_date='||p_program_update_date);
      wsh_server_debug.debug_message(
            ', process_flag='||p_process_flag||
            ', transaction_mode='||p_trx_mode||
            ', lock_flag='||p_lock_flag||
            ', transaction_header_id='||p_trx_header_id||
            ', acct_period_id='||p_acct_period_id||
            ', transaction_source_id='||p_trx_source_id||
            ', required_flag='||p_required_flag||
            ', currency_code='||p_currency_code||
            ', currency_conversion_type='||p_currency_conversion_type||
            ', currency_conversion_date='||p_currency_conversion_date||
            ', currency_conversion_rate='||p_currency_conversion_rate);
      wsh_server_debug.debug_message(
            ', project_id='||p_project_id||
            ', task_id='||p_task_id||
            ', validation_required='||p_validation_required||
            ', item_segment1='||p_item_segment1||
            ', item_segment2='||p_item_segment2||
            ', item_segment3='||p_item_segment3||
            ', item_segment4='||p_item_segment4||
            ', item_segment5='||p_item_segment5||
            ', item_segment6='||p_item_segment6||
            ', item_segment7='||p_item_segment7||
            ', item_segment8='||p_item_segment8||
            ', item_segment9='||p_item_segment9);
      wsh_server_debug.debug_message(
            ', item_segment10='||p_item_segment10||
            ', item_segment11='||p_item_segment11||
            ', item_segment12='||p_item_segment12||
            ', item_segment13='||p_item_segment13||
            ', item_segment14='||p_item_segment14||
            ', item_segment15='||p_item_segment15||
            ', item_segment16='||p_item_segment16||
            ', item_segment17='||p_item_segment17||
            ', item_segment18='||p_item_segment18||
            ', item_segment19='||p_item_segment19||
            ', item_segment20='||p_item_segment20);
      wsh_server_debug.debug_message(
            ', primary_quantity='||p_primary_quantity||
            ', loc_segment5='||p_loc_segment5||
            ', loc_segment6='||p_loc_segment6||
            ', loc_segment7='||p_loc_segment7||
            ', loc_segment8='||p_loc_segment8||
            ', loc_segment9='||p_loc_segment9||
            ', loc_segment10='||p_loc_segment10||
            ', loc_segment11='||p_loc_segment11||
            ', loc_segment12='||p_loc_segment12||
            ', loc_segment13='||p_loc_segment13||
            ', loc_segment14='||p_loc_segment14||
            ', loc_segment15='||p_loc_segment15);
      wsh_server_debug.debug_message(
            ', loc_segment16='||p_loc_segment16||
            ', loc_segment17='||p_loc_segment17||
            ', loc_segment18='||p_loc_segment18||
            ', loc_segment19='||p_loc_segment19||
            ', loc_segment20='||p_loc_segment20||
            ', dsp_segment4='||p_dsp_segment4||
            ', dsp_segment5='||p_dsp_segment5||
            ', dsp_segment6='||p_dsp_segment6||
            ', dsp_segment7='||p_dsp_segment7||
            ', dsp_segment8='||p_dsp_segment8||
            ', dsp_segment9='||p_dsp_segment9);
      wsh_server_debug.debug_message(
            ', dsp_segment10='||p_dsp_segment10||
            ', dsp_segment11='||p_dsp_segment11||
            ', dsp_segment12='||p_dsp_segment12||
            ', dsp_segment13='||p_dsp_segment13||
            ', dsp_segment14='||p_dsp_segment14||
            ', dsp_segment15='||p_dsp_segment15||
            ', dsp_segment16='||p_dsp_segment16||
            ', dsp_segment17='||p_dsp_segment17||
            ', dsp_segment18='||p_dsp_segment18||
            ', dsp_segment19='||p_dsp_segment19);
      wsh_server_debug.debug_message(
            ', dsp_segment20='||p_dsp_segment20||
            ', dsp_segment21='||p_dsp_segment21||
            ', dsp_segment22='||p_dsp_segment22||
            ', dsp_segment23='||p_dsp_segment23||
            ', dsp_segment24='||p_dsp_segment24||
            ', dsp_segment25='||p_dsp_segment25||
            ', dsp_segment26='||p_dsp_segment26||
            ', dsp_segment27='||p_dsp_segment27||
            ', dsp_segment28='||p_dsp_segment28||
            ', dsp_segment29='||p_dsp_segment29||
            ', dsp_segment30='||p_dsp_segment30);
      wsh_server_debug.debug_message(
            ', transaction_source_name='||p_trx_source_name||
            ', reason_id='||p_reason_id||
            ', transaction_cost='||p_trx_cost||
            ', ussgl_transaction_code='||p_ussgl_transaction_code||
            ', wip_entity_type='||p_wip_entity_type||
            ', schedule_id='||p_schedule_id||
            ', employee_code='||p_employee_code||
            ', department_id='||p_department_id||
            ', schedule_update_code='||p_schedule_update_code||
            ', setup_teardown_code='||p_setup_teardown_code);
      wsh_server_debug.debug_message(
            ', primary_switch='||p_primary_switch||
            ', mrp_code='||p_mrp_code||
            ', operation_seq_num='||p_operation_seq_num||
            ', repetitive_line_id='||p_repetitive_line_id||
            ', customer_ship_id='||p_customer_ship_id||
            ', line_item_num='||p_line_item_num||
            ', receiving_document='||p_receiving_document||
            ', rcv_transaction_id='||p_rcv_transaction_id||
            ', vendor_lot_number='||p_vendor_lot_number||
            ', transfer_locator='||p_transfer_locator);
      wsh_server_debug.debug_message(
            ', xfer_loc_segment1='||p_xfer_loc_segment1||
            ', xfer_loc_segment2='||p_xfer_loc_segment2||
            ', xfer_loc_segment3='||p_xfer_loc_segment3||
            ', xfer_loc_segment4='||p_xfer_loc_segment4||
            ', xfer_loc_segment5='||p_xfer_loc_segment5||
            ', xfer_loc_segment6='||p_xfer_loc_segment6||
            ', xfer_loc_segment7='||p_xfer_loc_segment7||
            ', xfer_loc_segment8='||p_xfer_loc_segment8||
            ', xfer_loc_segment9='||p_xfer_loc_segment9||
            ', xfer_loc_segment10='||p_xfer_loc_segment10);
      wsh_server_debug.debug_message(
            ', xfer_loc_segment11='||p_xfer_loc_segment11||
            ', xfer_loc_segment12='||p_xfer_loc_segment12||
            ', xfer_loc_segment13='||p_xfer_loc_segment13||
            ', xfer_loc_segment14='||p_xfer_loc_segment14||
            ', xfer_loc_segment15='||p_xfer_loc_segment15||
            ', xfer_loc_segment16='||p_xfer_loc_segment16||
            ', xfer_loc_segment17='||p_xfer_loc_segment17||
            ', xfer_loc_segment18='||p_xfer_loc_segment18||
            ', xfer_loc_segment19='||p_xfer_loc_segment19||
            ', xfer_loc_segment20='||p_xfer_loc_segment20);
      wsh_server_debug.debug_message(
            ', transportation_cost='||p_transportation_cost||
            ', transportation_account='||p_transportation_account||
            ', transfer_cost='||p_transfer_cost||
            ', containers='||p_containers||
            ', new_average_cost='||p_new_average_cost||
            ', value_change='||p_value_change||
            ', percentage_change='||p_percentage_change||
            ', demand_source_header_id='||p_demand_source_header_id||
            ', demand_source_line='||p_demand_source_line||
            ', demand_source_delivery='||p_demand_source_delivery);
      wsh_server_debug.debug_message(
            ', negative_req_flag='||p_negative_req_flag||
            ', error_explanation='||p_error_explanation||
            ', shippable_flag='||p_shippable_flag||
            ', error_code='||p_error_code||
            ', attribute_category='||p_attribute_category||
            ', attribute1='||p_attribute1||
            ', attribute2='||p_attribute2||
            ', attribute3='||p_attribute3||
            ', attribute4='||p_attribute4||
            ', attribute5='||p_attribute5);
      wsh_server_debug.debug_message(
            ', attribute6='||p_attribute6||
            ', attribute7='||p_attribute7||
            ', attribute8='||p_attribute8||
            ', attribute9='||p_attribute9||
            ', attribute10='||p_attribute10||
            ', attribute11='||p_attribute11||
            ', attribute12='||p_attribute12||
            ', attribute13='||p_attribute13||
            ', attribute14='||p_attribute14||
            ', attribute15='||p_attribute15);
      wsh_server_debug.debug_message(
            ', requisition_distribution_id='||p_requisition_distribution_id||
            ', reservation_quantity='||p_reservation_quantity||
            ', shipped_quantity='||p_shipped_quantity||
            ', locator_name='||p_locator_name||
            ', to_task_id='||p_to_task_id||
            ', source_task_id='||p_source_task_id||
            ', to_project_id='||p_to_project_id||
            ', source_project_id='||p_source_project_id||
            ', pa_expenditure_org_id='||p_pa_expenditure_org_id||
            ', expenditure_type='||p_expenditure_type);
      wsh_server_debug.debug_message(
            ', final_completion_flag='||p_final_completion_flag||
            ', transfer_percentage='||p_transfer_percentage||
            ', transaction_sequence_id='||p_trx_sequence_id||
            ', material_account='||p_material_account||
            ', material_overhead_account='||p_material_overhead_account||
            ', resource_account='||p_resource_account||
            ', outside_processing_account='||p_outside_processing_account||
            ', overhead_account='||p_overhead_account);
      wsh_server_debug.debug_message(
            ', bom_revision='||p_bom_revision||
            ', routing_revision='||p_routing_revision||
            ', bom_revision_date='||p_bom_revision_date||
            ', routing_revision_date='||p_routing_revision_date||
            ', alternate_bom_designator='||p_alternate_bom_designator||
            ', alternate_routing_designator='||p_alternate_routing_designator||
            ', accounting_class='||p_accounting_class||
            ', demand_class='||p_demand_class);
      wsh_server_debug.debug_message(
            ', parent_id='||p_parent_id||
            ', substitution_type_id='||p_substitution_type_id||
            ', substitution_item_id='||p_substitution_item_id||
            ', schedule_group='||p_schedule_group||
            ', build_sequence='||p_build_sequence||
            ', schedule_number='||p_schedule_number||
            ', scheduled_flag='||p_scheduled_flag||
            ', flow_schedule='||p_flow_schedule||
            ', cost_group_id='||p_cost_group_id );
*/
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
          WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_INTERFACE_ID',P_TRX_INTERFACE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_HEADER_ID',P_TRX_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_ID',P_TRX_SOURCE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY_CODE',P_SUBINVENTORY_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_QUANTITY',P_TRX_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_DATE',P_TRANSACTION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT1',P_DSP_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT2',P_DSP_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT3',P_DSP_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_TYPE_ID',P_TRX_SOURCE_TYPE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_ACTION_ID',P_TRX_ACTION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_TYPE_ID',P_TRX_TYPE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DISTRIBUTION_ACCOUNT_ID',P_DISTRIBUTION_ACCOUNT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT1',P_DST_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT2',P_DST_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT3',P_DST_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT4',P_DST_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT5',P_DST_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT6',P_DST_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT7',P_DST_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT8',P_DST_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT9',P_DST_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT10',P_DST_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT11',P_DST_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT12',P_DST_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT13',P_DST_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT14',P_DST_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT15',P_DST_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT16',P_DST_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT17',P_DST_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT18',P_DST_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT19',P_DST_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT20',P_DST_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT21',P_DST_SEGMENT21);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT22',P_DST_SEGMENT22);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT23',P_DST_SEGMENT23);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT24',P_DST_SEGMENT24);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT25',P_DST_SEGMENT25);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT26',P_DST_SEGMENT26);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT27',P_DST_SEGMENT27);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT28',P_DST_SEGMENT28);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT29',P_DST_SEGMENT29);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT30',P_DST_SEGMENT30);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_REFERENCE',P_TRX_REFERENCE);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_LINE_ID',P_TRX_SOURCE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_DELIVERY_ID',P_TRX_SOURCE_DELIVERY_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_REVISION',P_REVISION);
          WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_ID',P_LOCATOR_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT1',P_LOC_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT2',P_LOC_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT3',P_LOC_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT4',P_LOC_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_PICKING_LINE_ID',P_PICKING_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_SUBINVENTORY',P_TRANSFER_SUBINVENTORY);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_ORGANIZATION',P_TRANSFER_ORGANIZATION);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_LOCATION_ID',P_SHIP_TO_LOCATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUISITION_LINE_ID',P_REQUISITION_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_UOM',P_TRX_UOM);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_ID',P_DEMAND_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_NUMBER',P_SHIPMENT_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_EXPECTED_ARRIVAL_DATE',P_EXPECTED_ARRIVAL_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_ENCUMBRANCE_ACCOUNT',P_ENCUMBRANCE_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_ENCUMBRANCE_AMOUNT',P_ENCUMBRANCE_AMOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_MOVEMENT_ID',P_MOVEMENT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_CODE',P_FREIGHT_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_WAYBILL_AIRBILL',P_WAYBILL_AIRBILL);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUEST_ID',P_REQUEST_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_APPLICATION_ID',P_PROGRAM_APPLICATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_ID',P_PROGRAM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_UPDATE_DATE',P_PROGRAM_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_PROCESS_FLAG',P_PROCESS_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_MODE',P_TRX_MODE);
          WSH_DEBUG_SV.log(l_module_name,'P_LOCK_FLAG',P_LOCK_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_ACCT_PERIOD_ID',P_ACCT_PERIOD_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUIRED_FLAG',P_REQUIRED_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CODE',P_CURRENCY_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CONVERSION_TYPE',P_CURRENCY_CONVERSION_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CONVERSION_DATE',P_CURRENCY_CONVERSION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CONVERSION_RATE',P_CURRENCY_CONVERSION_RATE);
          WSH_DEBUG_SV.log(l_module_name,'P_PROJECT_ID',P_PROJECT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TASK_ID',P_TASK_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_REQUIRED',P_VALIDATION_REQUIRED);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT1',P_ITEM_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT2',P_ITEM_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT3',P_ITEM_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT4',P_ITEM_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT5',P_ITEM_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT6',P_ITEM_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT7',P_ITEM_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT8',P_ITEM_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT9',P_ITEM_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT10',P_ITEM_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT11',P_ITEM_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT12',P_ITEM_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT13',P_ITEM_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT14',P_ITEM_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT15',P_ITEM_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT16',P_ITEM_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT17',P_ITEM_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT18',P_ITEM_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT19',P_ITEM_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT20',P_ITEM_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_QUANTITY',P_PRIMARY_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT5',P_LOC_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT6',P_LOC_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT7',P_LOC_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT8',P_LOC_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT9',P_LOC_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT10',P_LOC_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT11',P_LOC_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT12',P_LOC_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT13',P_LOC_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT14',P_LOC_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT15',P_LOC_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT16',P_LOC_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT17',P_LOC_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT18',P_LOC_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT19',P_LOC_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT20',P_LOC_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT4',P_DSP_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT5',P_DSP_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT6',P_DSP_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT7',P_DSP_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT8',P_DSP_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT9',P_DSP_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT10',P_DSP_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT11',P_DSP_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT12',P_DSP_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT13',P_DSP_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT14',P_DSP_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT15',P_DSP_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT16',P_DSP_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT17',P_DSP_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT18',P_DSP_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT19',P_DSP_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT20',P_DSP_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT21',P_DSP_SEGMENT21);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT22',P_DSP_SEGMENT22);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT23',P_DSP_SEGMENT23);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT24',P_DSP_SEGMENT24);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT25',P_DSP_SEGMENT25);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT26',P_DSP_SEGMENT26);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT27',P_DSP_SEGMENT27);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT28',P_DSP_SEGMENT28);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT29',P_DSP_SEGMENT29);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT30',P_DSP_SEGMENT30);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_NAME',P_TRX_SOURCE_NAME);
          WSH_DEBUG_SV.log(l_module_name,'P_REASON_ID',P_REASON_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_COST',P_TRX_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_USSGL_TRANSACTION_CODE',P_USSGL_TRANSACTION_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_WIP_ENTITY_TYPE',P_WIP_ENTITY_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_ID',P_SCHEDULE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_EMPLOYEE_CODE',P_EMPLOYEE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_DEPARTMENT_ID',P_DEPARTMENT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_UPDATE_CODE',P_SCHEDULE_UPDATE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_SETUP_TEARDOWN_CODE',P_SETUP_TEARDOWN_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_SWITCH',P_PRIMARY_SWITCH);
          WSH_DEBUG_SV.log(l_module_name,'P_MRP_CODE',P_MRP_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_OPERATION_SEQ_NUM',P_OPERATION_SEQ_NUM);
          WSH_DEBUG_SV.log(l_module_name,'P_REPETITIVE_LINE_ID',P_REPETITIVE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_SHIP_ID',P_CUSTOMER_SHIP_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_LINE_ITEM_NUM',P_LINE_ITEM_NUM);
          WSH_DEBUG_SV.log(l_module_name,'P_RECEIVING_DOCUMENT',P_RECEIVING_DOCUMENT);
          WSH_DEBUG_SV.log(l_module_name,'P_RCV_TRANSACTION_ID',P_RCV_TRANSACTION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_VENDOR_LOT_NUMBER',P_VENDOR_LOT_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_LOCATOR',P_TRANSFER_LOCATOR);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT1',P_XFER_LOC_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT2',P_XFER_LOC_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT3',P_XFER_LOC_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT4',P_XFER_LOC_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT5',P_XFER_LOC_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT6',P_XFER_LOC_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT7',P_XFER_LOC_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT8',P_XFER_LOC_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT9',P_XFER_LOC_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT10',P_XFER_LOC_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT11',P_XFER_LOC_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT12',P_XFER_LOC_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT13',P_XFER_LOC_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT14',P_XFER_LOC_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT15',P_XFER_LOC_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT16',P_XFER_LOC_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT17',P_XFER_LOC_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT18',P_XFER_LOC_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT19',P_XFER_LOC_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT20',P_XFER_LOC_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSPORTATION_COST',P_TRANSPORTATION_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSPORTATION_ACCOUNT',P_TRANSPORTATION_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_COST',P_TRANSFER_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_CONTAINERS',P_CONTAINERS);
          WSH_DEBUG_SV.log(l_module_name,'P_NEW_AVERAGE_COST',P_NEW_AVERAGE_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_VALUE_CHANGE',P_VALUE_CHANGE);
          WSH_DEBUG_SV.log(l_module_name,'P_PERCENTAGE_CHANGE',P_PERCENTAGE_CHANGE);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_SOURCE_HEADER_ID',P_DEMAND_SOURCE_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_SOURCE_LINE',P_DEMAND_SOURCE_LINE);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_SOURCE_DELIVERY',P_DEMAND_SOURCE_DELIVERY);
          WSH_DEBUG_SV.log(l_module_name,'P_NEGATIVE_REQ_FLAG',P_NEGATIVE_REQ_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_ERROR_EXPLANATION',P_ERROR_EXPLANATION);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIPPABLE_FLAG',P_SHIPPABLE_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_ERROR_CODE',P_ERROR_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE_CATEGORY',P_ATTRIBUTE_CATEGORY);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE1',P_ATTRIBUTE1);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE2',P_ATTRIBUTE2);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE3',P_ATTRIBUTE3);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE4',P_ATTRIBUTE4);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE5',P_ATTRIBUTE5);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE6',P_ATTRIBUTE6);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE7',P_ATTRIBUTE7);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE8',P_ATTRIBUTE8);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE9',P_ATTRIBUTE9);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE10',P_ATTRIBUTE10);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE11',P_ATTRIBUTE11);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE12',P_ATTRIBUTE12);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE13',P_ATTRIBUTE13);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE14',P_ATTRIBUTE14);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE15',P_ATTRIBUTE15);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUISITION_DISTRIBUTION_ID',P_REQUISITION_DISTRIBUTION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_RESERVATION_QUANTITY',P_RESERVATION_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIPPED_QUANTITY',P_SHIPPED_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM',P_INVENTORY_ITEM);
          WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_NAME',P_LOCATOR_NAME);
          WSH_DEBUG_SV.log(l_module_name,'P_TO_TASK_ID',P_TO_TASK_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_TASK_ID',P_SOURCE_TASK_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TO_PROJECT_ID',P_TO_PROJECT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_PROJECT_ID',P_SOURCE_PROJECT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PA_EXPENDITURE_ORG_ID',P_PA_EXPENDITURE_ORG_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_EXPENDITURE_TYPE',P_EXPENDITURE_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_FINAL_COMPLETION_FLAG',P_FINAL_COMPLETION_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_PERCENTAGE',P_TRANSFER_PERCENTAGE);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SEQUENCE_ID',P_TRX_SEQUENCE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_MATERIAL_ACCOUNT',P_MATERIAL_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_MATERIAL_OVERHEAD_ACCOUNT',P_MATERIAL_OVERHEAD_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_RESOURCE_ACCOUNT',P_RESOURCE_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_OUTSIDE_PROCESSING_ACCOUNT',P_OUTSIDE_PROCESSING_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_OVERHEAD_ACCOUNT',P_OVERHEAD_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_BOM_REVISION',P_BOM_REVISION);
          WSH_DEBUG_SV.log(l_module_name,'P_ROUTING_REVISION',P_ROUTING_REVISION);
          WSH_DEBUG_SV.log(l_module_name,'P_BOM_REVISION_DATE',P_BOM_REVISION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_ROUTING_REVISION_DATE',P_ROUTING_REVISION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_ALTERNATE_BOM_DESIGNATOR',P_ALTERNATE_BOM_DESIGNATOR);
          WSH_DEBUG_SV.log(l_module_name,'P_ALTERNATE_ROUTING_DESIGNATOR',P_ALTERNATE_ROUTING_DESIGNATOR);
          WSH_DEBUG_SV.log(l_module_name,'P_ACCOUNTING_CLASS',P_ACCOUNTING_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_CLASS',P_DEMAND_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'P_PARENT_ID',P_PARENT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SUBSTITUTION_TYPE_ID',P_SUBSTITUTION_TYPE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SUBSTITUTION_ITEM_ID',P_SUBSTITUTION_ITEM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_GROUP',P_SCHEDULE_GROUP);
          WSH_DEBUG_SV.log(l_module_name,'P_BUILD_SEQUENCE',P_BUILD_SEQUENCE);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_NUMBER',P_SCHEDULE_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULED_FLAG',P_SCHEDULED_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_FLOW_SCHEDULE',P_FLOW_SCHEDULE);
          WSH_DEBUG_SV.log(l_module_name,'P_COST_GROUP_ID',P_COST_GROUP_ID);
-- HW OPMCONV. Added debugging msgs
          WSH_DEBUG_SV.log(l_module_name,'P_SECONDARY_TRX_QUANTITY',P_SECONDARY_TRX_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_secondary_uom_code',p_secondary_uom_code);
      END IF;
      --
      fnd_profile.get('USER_ID',g_userid);

      UPDATE mtl_transactions_interface SET
         source_code                = p_source_code,
         source_line_id             = p_source_line_id,
         source_header_id           = p_source_header_id,
         inventory_item_id          = p_inventory_item_id,
         subinventory_code          = p_subinventory_code,
         transaction_quantity       = p_trx_quantity,
         transaction_date           = p_transaction_date,
         organization_id            = p_organization_id,
         dsp_segment1               = p_dsp_segment1,
         dsp_segment2               = p_dsp_segment2,
         dsp_segment3               = p_dsp_segment3,
         transaction_source_type_id = p_trx_source_type_id,
         transaction_action_id      = p_trx_action_id,
         transaction_type_id        = p_trx_type_id,
         distribution_account_id    = p_distribution_account_id,
         dst_segment1               = p_dst_segment1,
         dst_segment2               = p_dst_segment2,
         dst_segment3               = p_dst_segment3,
         dst_segment4               = p_dst_segment4,
         dst_segment5               = p_dst_segment5,
         dst_segment6               = p_dst_segment6,
         dst_segment7               = p_dst_segment7,
         dst_segment8               = p_dst_segment8,
         dst_segment9               = p_dst_segment9,
         dst_segment10              = p_dst_segment10,
         dst_segment11              = p_dst_segment11,
         dst_segment12              = p_dst_segment12,
         dst_segment13              = p_dst_segment13,
         dst_segment14              = p_dst_segment14,
         dst_segment15              = p_dst_segment15,
         dst_segment16              = p_dst_segment16,
         dst_segment17              = p_dst_segment17,
         dst_segment18              = p_dst_segment18,
         dst_segment19              = p_dst_segment19,
         dst_segment20              = p_dst_segment20,
         dst_segment21              = p_dst_segment21,
         dst_segment22              = p_dst_segment22,
         dst_segment23              = p_dst_segment23,
         dst_segment24              = p_dst_segment24,
         dst_segment25              = p_dst_segment25,
         dst_segment26              = p_dst_segment26,
         dst_segment27              = p_dst_segment27,
         dst_segment28              = p_dst_segment28,
         dst_segment29              = p_dst_segment29,
         dsT_Segment30              = p_dst_segment30,
         transaction_reference      = p_trx_reference,
         trx_source_line_id         = p_trx_source_line_id,
         trx_source_delivery_id     = p_trx_source_delivery_id,
         revision                   = p_revision,
         locator_id                 = p_locator_id,
         loc_segment1               = p_loc_segment1,
         loc_segment2               = p_loc_segment2,
         loc_segment3               = p_loc_segment3,
         loc_segment4               = p_loc_segment4,
         picking_line_id            = p_picking_line_id,
         transfer_subinventory      = p_transfer_subinventory,
         transfer_organization      = p_transfer_organization,
         ship_to_location_id        = p_ship_to_location_id,
         requisition_line_id        = p_requisition_line_id,
         transaction_uom            = p_trx_uom,
         transaction_interface_id   = p_trx_interface_id,
         demand_id                  = p_demand_id,
         shipment_number            = p_shipment_number,
         expected_arrival_date      = p_expected_arrival_date,
         encumbrance_account        = p_encumbrance_account,
         encumbrance_amount         = p_encumbrance_amount,
         movement_id                = p_movement_id,
         freight_code               = p_freight_code,
         waybill_airbill            = p_waybill_airbill,  --Bug 7503285
         last_update_date           = NVL(p_last_update_date,SYSDATE),
         last_updated_by            = NVL(p_last_updated_by,g_userid),
         last_update_login          = p_last_update_login,
         request_id                 = p_request_id,
         program_application_id     = p_program_application_id,
         program_id                 = p_program_id,
         program_update_date        = p_program_update_date,
         process_flag               = p_process_flag,
         transaction_mode           = p_trx_mode,
         lock_flag                  = p_lock_flag,
         transaction_header_id      = p_trx_header_id,
         acct_period_id             = p_acct_period_id,
         transaction_source_id      = p_trx_source_id,
         required_flag              = p_required_flag,
         currency_code              = p_currency_code,
         currency_conversion_type   = p_currency_conversion_type,
         currency_conversion_date   = p_currency_conversion_date,
         currency_conversion_rate   = p_currency_conversion_rate,
         project_id                 = p_project_id,
         task_id                    = p_task_id,
         validation_required        = p_validation_required,
         item_segment1	            = p_item_segment1,
         item_segment2	            = p_item_segment2,
         item_segment3	            = p_item_segment3,
         item_segment4		    = p_item_segment4,
         item_segment5		    = p_item_segment5,
         item_segment6		    = p_item_segment6,
         item_segment7		    = p_item_segment7,
         item_segment8		    = p_item_segment8,
         item_segment9		    = p_item_segment9,
         item_segment10		    = p_item_segment10,
         item_segment11		    = p_item_segment11,
         item_segment12		    = p_item_segment12,
         item_segment13		    = p_item_segment13,
         item_segment14		    = p_item_segment14,
         item_segment15		    = p_item_segment15,
         item_segment16		    = p_item_segment16,
         item_segment17		    = p_item_segment17,
         item_segment18		    = p_item_segment18,
         item_segment19		    = p_item_segment19,
         item_segment20		    = p_item_segment20,
         primary_quantity           = p_primary_quantity,
         loc_segment5		    = p_loc_segment5,
         loc_segment6		    = p_loc_segment6,
         loc_segment7		    = p_loc_segment7,
         loc_segment8		    = p_loc_segment8,
         loc_segment9		    = p_loc_segment9,
         loc_segment10		    = p_loc_segment10,
         loc_segment11		    = p_loc_segment11,
         loc_segment12		    = p_loc_segment12,
         loc_segment13		    = p_loc_segment13,
         loc_segment14		    = p_loc_segment14,
         loc_segment15		    = p_loc_segment15,
         loc_segment16		    = p_loc_segment16,
         loc_segment17		    = p_loc_segment17,
         loc_segment18		    = p_loc_segment18,
         loc_segment19		    = p_loc_segment19,
         loc_segment20		    = p_loc_segment20,
         dsp_segment4		    = p_dsp_segment4,
         dsp_segment5		    = p_dsp_segment5,
         dsp_segment6		    = p_dsp_segment6,
         dsp_segment7		    = p_dsp_segment7,
         dsp_segment8		    = p_dsp_segment8,
         dsp_segment9		    = p_dsp_segment9,
         dsp_segment10		    = p_dsp_segment10,
         dsp_segment11		    = p_dsp_segment11,
         dsp_segment12		    = p_dsp_segment12,
         dsp_segment13		    = p_dsp_segment13,
         dsp_segment14		    = p_dsp_segment14,
         dsp_segment15		    = p_dsp_segment15,
         dsp_segment16		    = p_dsp_segment16,
         dsp_segment17		    = p_dsp_segment17,
         dsp_segment18	  	    = p_dsp_segment18,
         dsp_segment19		    = p_dsp_segment19,
         dsp_segment20		    = p_dsp_segment20,
         dsp_segment21		    = p_dsp_segment21,
         dsp_segment22		    = p_dsp_segment22,
         dsp_segment23		    = p_dsp_segment23,
         dsp_segment24		    = p_dsp_segment24,
         dsp_segment25		    = p_dsp_segment25,
         dsp_segment26		    = p_dsp_segment26,
         dsp_segment27		    = p_dsp_segment27,
         dsp_segment28		    = p_dsp_segment28,
         dsp_segment29		    = p_dsp_segment29,
         dsp_segment30		    = p_dsp_segment30,
         transaction_source_name    = p_trx_source_name,
         reason_id	            = p_reason_id,
         transaction_cost           = p_trx_cost,
         ussgl_transaction_code	    = p_ussgl_transaction_code,
         wip_entity_type	    = p_wip_entity_type,
         schedule_id		    = p_schedule_id,
         employee_code		    = p_employee_code,
         department_id	            = p_department_id,
         schedule_update_code	    = p_schedule_update_code,
         setup_teardown_code	    = p_setup_teardown_code,
         primary_switch		    = p_primary_switch,
         mrp_code		    = p_mrp_code,
         operation_seq_num	    = p_operation_seq_num,
         repetitive_line_id	    = p_repetitive_line_id,
         customer_ship_id	    = p_customer_ship_id,
         line_item_num		    = p_line_item_num,
         receiving_document	    = p_receiving_document,
         rcv_transaction_id	    = p_rcv_transaction_id,
         vendor_lot_number	    = p_vendor_lot_number,
         transfer_locator	    = p_transfer_locator,
         xfer_loc_segment1	    = p_xfer_loc_segment1,
         xfer_loc_segment2	    = p_xfer_loc_segment2,
         xfer_loc_segment3	    = p_xfer_loc_segment3,
         xfer_loc_segment4	    = p_xfer_loc_segment4,
         xfer_loc_segment5	    = p_xfer_loc_segment5,
         xfer_loc_segment6	    = p_xfer_loc_segment6,
         xfer_loc_segment7	    = p_xfer_loc_segment7,
         xfer_loc_segment8	    = p_xfer_loc_segment8,
         xfer_loc_segment9	    = p_xfer_loc_segment9,
         xfer_loc_segment10	    = p_xfer_loc_segment10,
         xfer_loc_segment11	    = p_xfer_loc_segment11,
         xfer_loc_segment12	    = p_xfer_loc_segment12,
         xfer_loc_segment13	    = p_xfer_loc_segment13,
         xfer_loc_segment14	    = p_xfer_loc_segment14,
         xfer_loc_segment15	    = p_xfer_loc_segment15,
         xfer_loc_segment16	    = p_xfer_loc_segment16,
         xfer_loc_segment17	    = p_xfer_loc_segment17,
         xfer_loc_segment18	    = p_xfer_loc_segment18,
         xfer_loc_segment19	    = p_xfer_loc_segment19,
         xfer_loc_segment20	    = p_xfer_loc_segment20,
         transportation_cost	    = p_transportation_cost,
         transportation_account	    = p_transportation_account,
         transfer_cost		    = p_transfer_cost,
         containers		    = p_containers,
         new_average_cost	    = p_new_average_cost,
         value_change		    = p_value_change,
         percentage_change	    = p_percentage_change,
         demand_source_header_id    = p_demand_source_header_id,
         demand_source_line	    = p_demand_source_line,
         demand_source_delivery	    = p_demand_source_delivery,
         negative_req_flag	    = p_negative_req_flag,
         error_explanation	    = p_error_explanation,
         shippable_flag		    = p_shippable_flag,
         error_code		    = p_error_code,
         attribute_category	    = p_attribute_category,
         attribute1		    = p_attribute1,
         attribute2		    = p_attribute2,
         attribute3		    = p_attribute3,
         attribute4		    = p_attribute4,
         attribute5		    = p_attribute5,
         attribute6		    = p_attribute6,
         attribute7		    = p_attribute7,
         attribute8		    = p_attribute8,
         attribute9		    = p_attribute9,
         attribute10		    = p_attribute10,
         attribute11		    = p_attribute11,
         attribute12		    = p_attribute12,
         attribute13		    = p_attribute13,
         attribute14		    = p_attribute14,
         attribute15		    = p_attribute15,
         requisition_distribution_id = p_requisition_distribution_id,
         reservation_quantity	    = p_reservation_quantity,
         shipped_quantity	    = p_shipped_quantity,
         inventory_item		    = p_inventory_item,
         locator_name		    = p_locator_name,
         to_task_id		    = p_to_task_id,
         source_task_id		    = p_source_task_id,
         to_project_id		    = p_to_project_id,
         source_project_id	    = p_source_project_id,
         pa_expenditure_org_id	    = p_pa_expenditure_org_id,
         expenditure_type	    = p_expenditure_type,
         final_completion_flag	    = p_final_completion_flag,
         transfer_percentage	    = p_transfer_percentage,
         transaction_sequence_id    = p_trx_sequence_id,
         material_account	    = p_material_account,
         material_overhead_account  = p_material_overhead_account,
         resource_account	    = p_resource_account,
         outside_processing_account = p_outside_processing_account,
         overhead_account	    = p_overhead_account,
         bom_revision		    = p_bom_revision,
         routing_revision	    = p_routing_revision,
         bom_revision_date	    = p_bom_revision_date,
         routing_revision_date	    = p_routing_revision_date,
         alternate_bom_designator   = p_alternate_bom_designator,
         alternate_routing_designator = p_alternate_routing_designator,
         accounting_class	    = p_accounting_class,
         demand_class		    = p_demand_class,
         parent_id		    = p_parent_id,
         substitution_type_id	    = p_substitution_type_id,
         substitution_item_id	    = p_substitution_item_id,
         schedule_group		    = p_schedule_group,
         build_sequence		    = p_build_sequence,
         schedule_number	    = p_schedule_number,
         scheduled_flag		    = p_scheduled_flag,
         flow_schedule		    = p_flow_schedule,
         cost_group_id              = p_cost_group_id,
-- HW OPMCONV. Added secondary_qty and secondary_uom
         SECONDARY_TRANSACTION_QUANTITY = p_secondary_trx_quantity,
         SECONDARY_UOM_CODE          = p_secondary_uom_code
      WHERE rowid = x_rowid;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Rows Updated',SQL%ROWCOUNT);
      END IF;
      IF (SQL%NOTFOUND) THEN
/*         wsh_server_debug.log_event('WSH_TRX_HANDLER.UPDATE_ROW',
            'END',
            'No rows updated. Raising NO_DATA_FOUND.');
*/
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name,'NO_DATA_FOUND');
         END IF;
         RAISE NO_DATA_FOUND;
      END IF;

/*      wsh_server_debug.log_event('WSH_TRX_HANDLER.UPDATE_ROW',
         'END',
         'End of procedure UPDATE_ROW');
*/
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
   END Update_Row;

-- ===========================================================================
--
-- Name:
--
--   delete_row
--
-- Description:
--
--   Called by the client to delete a row in the
--   MTL_TRANSACTIONS_INTERFACE table.
--
-- ===========================================================================

   PROCEDURE Delete_Row (
      x_rowid					IN OUT NOCOPY  VARCHAR2 )
   IS
      l_trx_interface_id               NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_ROW';
--
   BEGIN
/*      wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
         'START',
         'Start of procedure DELETE_ROW');
*/

      -- get the column which may map to another table
/*      wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
         'START',
         'Select transaction_interface_id INTO l_trx_interface_id
          FROM mtl_transactions_interface');
*/
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
          WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
      END IF;
      --
      SELECT transaction_interface_id INTO l_trx_interface_id
      FROM mtl_transactions_interface
      WHERE rowid = x_rowid;

/*      wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
       'END',
       'Finish selecting transaction_header_id');
*/
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_trx_interface_id',l_trx_interface_id);
       END IF;

      -- If column is not NULL, child table exists
      IF (l_trx_interface_id is NOT NULL) THEN

         -- delete from mtl_serial_numbers_interface if there are mappings
         -- of mtl_transaction_lots_interface to the two other tables
/*          wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
                 'START',
                 'Delete mtl_serial_numbers_interface,
                  if it is one of two child tables');
        wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
			'START',
               'interface_id ' || l_trx_interface_id);
*/
         DELETE FROM mtl_serial_numbers_interface
         WHERE transaction_interface_id IN
            ( SELECT serial_transaction_temp_id
              FROM mtl_transaction_lots_interface
              WHERE transaction_interface_id = l_trx_interface_id );

/*          wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
            'END',
            'Finish delete mtl_serial_numbers_interface, if any');
*/
         -- delete from mtl_transaction_lots_interface, if there is mapping
/*          wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
            'START',
            'Delete mtl_transaction_lots_interface, if there is mapping');
*/
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Rows deleted',SQL%ROWCOUNT);
         END IF;
         DELETE FROM mtl_transaction_lots_interface
         WHERE transaction_interface_id = l_trx_interface_id;

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Rows deleted',SQL%ROWCOUNT);
         END IF;
         IF (SQL%NOTFOUND) THEN
            -- there is no mapping to mtl_transaction_lots_interface
/*             wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
               'START',
               'Delete mtl_serial_numbers_interface -- only child');
*/

            DELETE FROM mtl_serial_numbers_interface
            WHERE transaction_interface_id = l_trx_interface_id;
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Rows deleted',SQL%ROWCOUNT);
            END IF;

/*             wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
               'END',
               'Finish delete mtl_serial_numbers_interface');
*/
         END IF;
      END IF;

/*      wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
         'START',
         'Delete mtl_transactions_interface');
*/
      DELETE FROM mtl_transactions_interface WHERE rowid = x_rowid;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Rows deleted',SQL%ROWCOUNT);
      END IF;

      IF (SQL%NOTFOUND) THEN
/*         wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
            'END',
            'No rows deleted from mtl_transactions_interface.
             Raising NO_DATA_FOUND');
*/
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name,'NO_DATA_FOUND');
         END IF;
         RAISE NO_DATA_FOUND;
      END IF;

/*      wsh_server_debug.log_event('WSH_TRX_HANDLER.DELETE_ROW',
         'END',
         'End of procedure DELETE_ROW');
*/
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
   END Delete_Row;

-- ===========================================================================
--
-- Name:
--
--   lock_row
--
-- Description:
--
--   Called by the client to lock a row in the
--   MTL_TRANSACTION_LOTS_INTERFACE table.
--
-- ===========================================================================

   PROCEDURE Lock_Row (
      x_rowid					IN OUT NOCOPY  VARCHAR2,
      p_trx_interface_id  	        	IN NUMBER,
      p_trx_header_id      	  		IN NUMBER,
      p_source_code 				IN VARCHAR2,
      p_source_line_id 				IN NUMBER,
      p_source_header_id              		IN NUMBER,
      p_process_flag 			  	IN NUMBER,
      p_validation_required         		IN NUMBER,
      p_transaction_mode 			IN NUMBER,
      p_lock_flag                      		IN NUMBER,
      p_inventory_item_id			IN NUMBER,
      p_item_segment1         			IN VARCHAR2,
      p_item_segment2         			IN VARCHAR2,
      p_item_segment3                		IN VARCHAR2,
      p_item_segment4                     	IN VARCHAR2,
      p_item_segment5                     	IN VARCHAR2,
      p_item_segment6                     	IN VARCHAR2,
      p_item_segment7                     	IN VARCHAR2,
      p_item_segment8                     	IN VARCHAR2,
      p_item_segment9                     	IN VARCHAR2,
      p_item_segment10                    	IN VARCHAR2,
      p_item_segment11                    	IN VARCHAR2,
      p_item_segment12                    	IN VARCHAR2,
      p_item_segment13                    	IN VARCHAR2,
      p_item_segment14                    	IN VARCHAR2,
      p_item_segment15                    	IN VARCHAR2,
      p_item_segment16                    	IN VARCHAR2,
      p_item_segment17                    	IN VARCHAR2,
      p_item_segment18                    	IN VARCHAR2,
      p_item_segment19                    	IN VARCHAR2,
      p_item_segment20                    	IN VARCHAR2,
      p_revision                          	IN VARCHAR2,
      p_organization_id         		IN NUMBER,
      p_transaction_quantity 			IN NUMBER,
      p_primary_quantity                  	IN NUMBER,
      p_trx_uom                 		IN VARCHAR2,
      p_trx_date                		IN DATE,
      p_acct_period_id                    	IN NUMBER,
      p_subinventory_code                 	IN VARCHAR2,
      p_locator_id                        	IN NUMBER,
      p_loc_segment1                      	IN VARCHAR2,
      p_loc_segment2                      	IN VARCHAR2,
      p_loc_segment3                     	IN VARCHAR2,
      p_loc_segment4                     	IN VARCHAR2,
      p_loc_segment5                     	IN VARCHAR2,
      p_loc_segment6                      	IN VARCHAR2,
      p_loc_segment7                      	IN VARCHAR2,
      p_loc_segment8                      	IN VARCHAR2,
      p_loc_segment9                      	IN VARCHAR2,
      p_loc_segment10                     	IN VARCHAR2,
      p_loc_segment11                     	IN VARCHAR2,
      p_loc_segment12                     	IN VARCHAR2,
      p_loc_segment13                     	IN VARCHAR2,
      p_loc_segment14                     	IN VARCHAR2,
      p_loc_segment15                     	IN VARCHAR2,
      p_loc_segment16                     	IN VARCHAR2,
      p_loc_segment17                     	IN VARCHAR2,
      p_loc_segment18                     	IN VARCHAR2,
      p_loc_segment19                     	IN VARCHAR2,
      p_loc_segment20                     	IN VARCHAR2,
      p_trx_source_id            		IN NUMBER,
      p_dsp_segment1                           	IN VARCHAR2,
      p_dsp_segment2                           	IN VARCHAR2,
      p_dsp_segment3                           	IN VARCHAR2,
      p_dsp_segment4                           	IN VARCHAR2,
      p_dsp_segment5                           	IN VARCHAR2,
      p_dsp_segment6                           	IN VARCHAR2,
      p_dsp_segment7                           	IN VARCHAR2,
      p_dsp_segment8                           	IN VARCHAR2,
      p_dsp_segment9                           	IN VARCHAR2,
      p_dsp_segment10                          	IN VARCHAR2,
      p_dsp_segment11                          	IN VARCHAR2,
      p_dsp_segment12                          	IN VARCHAR2,
      p_dsp_segment13                          	IN VARCHAR2,
      p_dsp_segment14                          	IN VARCHAR2,
      p_dsp_segment15                          	IN VARCHAR2,
      p_dsp_segment16                          	IN VARCHAR2,
      p_dsp_segment17                          	IN VARCHAR2,
      p_dsp_segment18                          	IN VARCHAR2,
      p_dsp_segment19                          	IN VARCHAR2,
      p_dsp_segment20                          	IN VARCHAR2,
      p_dsp_segment21                          	IN VARCHAR2,
      p_dsp_segment22                          	IN VARCHAR2,
      p_dsp_segment23                          	IN VARCHAR2,
      p_dsp_segment24                          	IN VARCHAR2,
      p_dsp_segment25                          	IN VARCHAR2,
      p_dsp_segment26                          	IN VARCHAR2,
      p_dsp_segment27                          	IN VARCHAR2,
      p_dsp_segment28                          	IN VARCHAR2,
      p_dsp_segment29                          	IN VARCHAR2,
      p_dsp_segment30                          	IN VARCHAR2,
      p_trx_source_name                         IN VARCHAR2,
      p_trx_source_type_id         		IN NUMBER,
      p_trx_action_id            		IN NUMBER,
      p_trx_type_id           			IN NUMBER,
      p_reason_id                    		IN NUMBER,
      p_trx_reference            		IN VARCHAR2,
      p_trx_cost                     		IN NUMBER,
      p_distribution_acct_id          		IN NUMBER,
      p_dst_segment1                      	IN VARCHAR2,
      p_dst_segment2                      	IN VARCHAR2,
      p_dst_segment3                      	IN VARCHAR2,
      p_dst_segment4                      	IN VARCHAR2,
      p_dst_segment5                      	IN VARCHAR2,
      p_dst_segment6                      	IN VARCHAR2,
      p_dst_segment7                      	IN VARCHAR2,
      p_dst_segment8                      	IN VARCHAR2,
      p_dst_segment9                      	IN VARCHAR2,
      p_dst_segment10                     	IN VARCHAR2,
      p_dst_segment11                     	IN VARCHAR2,
      p_dst_segment12                     	IN VARCHAR2,
      p_dst_segment13                     	IN VARCHAR2,
      p_dst_segment14                     	IN VARCHAR2,
      p_dst_segment15                     	IN VARCHAR2,
      p_dst_segment16                     	IN VARCHAR2,
      p_dst_segment17                     	IN VARCHAR2,
      p_dst_segment18                     	IN VARCHAR2,
      p_dst_segment19                     	IN VARCHAR2,
      p_dst_segment20                     	IN VARCHAR2,
      p_dst_segment21                     	IN VARCHAR2,
      p_dst_segment22                     	IN VARCHAR2,
      p_dst_segment23                     	IN VARCHAR2,
      p_dst_segment24                     	IN VARCHAR2,
      p_dst_segment25                     	IN VARCHAR2,
      p_dst_segment26                     	IN VARCHAR2,
      p_dst_segment27                     	IN VARCHAR2,
      p_dst_segment28                     	IN VARCHAR2,
      p_dst_segment29                     	IN VARCHAR2,
      p_dst_segment30                     	IN VARCHAR2,
      p_requisition_line_id               	IN NUMBER,
      p_currency_code                     	IN VARCHAR2,
      p_currency_conversion_date         	IN DATE,
      p_currency_conversion_type        	IN VARCHAR2,
      p_currency_conversion_rate          	IN NUMBER,
      p_ussgl_transaction_code      		IN VARCHAR2,
      p_wip_entity_type                  	IN NUMBER,
      p_schedule_id                      	IN NUMBER,
      p_employee_code                   	IN VARCHAR2,
      p_department_id                    	IN NUMBER,
      p_schedule_update_code             	IN NUMBER,
      p_setup_teardown_code              	IN NUMBER,
      p_primary_switch                   	IN NUMBER,
      p_mrp_code                         	IN NUMBER,
      p_operation_seq_num                	IN NUMBER,
      p_repetitive_line_id               	IN NUMBER,
      p_picking_line_id                  	IN NUMBER,
      p_trx_source_line_id         		IN NUMBER,
      p_trx_source_delivery_id        		IN NUMBER,
      p_demand_id                         	IN NUMBER,
      p_customer_ship_id                  	IN NUMBER,
      p_line_item_num             		IN NUMBER,
      p_receiving_document        		IN VARCHAR2,
      p_rcv_transaction_id                	IN NUMBER,
      p_ship_to_location_id               	IN NUMBER,
      p_encumbrance_account               	IN NUMBER,
      p_encumbrance_amount                	IN NUMBER,
      p_vendor_lot_number                 	IN VARCHAR2,
      p_transfer_subinventory             	IN VARCHAR2,
      p_transfer_organization             	IN NUMBER,
      p_transfer_locator                  	IN NUMBER,
      p_xfer_loc_segment1                 	IN VARCHAR2,
      p_xfer_loc_segment2                 	IN VARCHAR2,
      p_xfer_loc_segment3                 	IN VARCHAR2,
      p_xfer_loc_segment4                 	IN VARCHAR2,
      p_xfer_loc_segment5                 	IN VARCHAR2,
      p_xfer_loc_segment6                 	IN VARCHAR2,
      p_xfer_loc_segment7                 	IN VARCHAR2,
      p_xfer_loc_segment8                 	IN VARCHAR2,
      p_xfer_loc_segment9                 	IN VARCHAR2,
      p_xfer_loc_segment10                	IN VARCHAR2,
      p_xfer_loc_segment11                	IN VARCHAR2,
      p_xfer_loc_segment12                	IN VARCHAR2,
      p_xfer_loc_segment13                	IN VARCHAR2,
      p_xfer_loc_segment14                	IN VARCHAR2,
      p_xfer_loc_segment15                	IN VARCHAR2,
      p_xfer_loc_segment16                	IN VARCHAR2,
      p_xfer_loc_segment17                	IN VARCHAR2,
      p_xfer_loc_segment18                	IN VARCHAR2,
      p_xfer_loc_segment19                	IN VARCHAR2,
      p_xfer_loc_segment20                	IN VARCHAR2,
      p_shipment_number                 	IN VARCHAR2,
      p_transportation_cost               	IN NUMBER,
      p_transportation_account            	IN NUMBER,
      p_transfer_cost                     	IN NUMBER,
      p_freight_code                      	IN VARCHAR2,
      p_containers                       	IN NUMBER,
      p_waybill_airbill            		IN VARCHAR2,
      p_expected_arrival_date         		IN DATE,
      p_new_average_cost                 	IN NUMBER,
      p_value_change                     	IN NUMBER,
      p_percentage_change                	IN NUMBER,
      p_demand_source_header_id          	IN NUMBER,
      p_demand_source_line           		IN VARCHAR2,
      p_demand_source_delivery      		IN VARCHAR2,
      p_negative_req_flag                	IN NUMBER,
      p_error_explanation 			IN VARCHAR2,
      p_shippable_flag 				IN VARCHAR2,
      p_error_code 				IN VARCHAR2,
      p_required_flag 				IN VARCHAR2,
      p_attribute_category               	IN VARCHAR2,
      p_attribute1                 		IN VARCHAR2,
      p_attribute2      			IN VARCHAR2,
      p_attribute3                    		IN VARCHAR2,
      p_attribute4             			IN VARCHAR2,
      p_attribute5 				IN VARCHAR2,
      p_attribute6            			IN VARCHAR2,
      p_attribute7   				IN VARCHAR2,
      p_attribute8 				IN VARCHAR2,
      p_attribute9          			IN VARCHAR2,
      p_attribute10         			IN VARCHAR2,
      p_attribute11             		IN VARCHAR2,
      p_attribute12                       	IN VARCHAR2,
      p_attribute13                       	IN VARCHAR2,
      p_attribute14                       	IN VARCHAR2,
      p_attribute15                       	IN VARCHAR2,
      p_requisition_distribution_id      	IN NUMBER,
      p_movement_id                      	IN NUMBER,
      p_reservation_quantity             	IN NUMBER,
      p_shipped_quantity                 	IN NUMBER,
      p_inventory_item                    	IN VARCHAR2,
      p_locator_name                      	IN VARCHAR2,
      p_task_id     				IN NUMBER,
      p_to_task_id                       	IN NUMBER,
      p_source_task_id                   	IN NUMBER,
      p_project_id                       	IN NUMBER,
      p_to_project_id                     	IN NUMBER,
      p_source_project_id                 	IN NUMBER,
      p_pa_expenditure_org_id             	IN NUMBER,
      p_expenditure_type                  	IN VARCHAR2,
      p_final_completion_flag            	IN VARCHAR2,
      p_transfer_percentage              	IN NUMBER,
      p_trx_sequence_id              		IN NUMBER,
      p_material_account                 	IN NUMBER,
      p_material_overhead_account        	IN NUMBER,
      p_resource_account                 	IN NUMBER,
      p_outside_processing_account       	IN NUMBER,
      p_overhead_account                 	IN NUMBER,
      p_bom_revision                  		IN VARCHAR2,
      p_routing_revision          		IN VARCHAR2,
      p_bom_revision_date              		IN DATE,
      p_routing_revision_date          		IN DATE,
      p_alternate_bom_designator      		IN VARCHAR2,
      p_alternate_routing_designator    	IN VARCHAR2,
      p_accounting_class             		IN VARCHAR2,
      p_demand_class                		IN VARCHAR2,
      p_parent_id                        	IN NUMBER,
      p_substitution_type_id             	IN NUMBER,
      p_substitution_item_id             	IN NUMBER,
      p_schedule_group                   	IN NUMBER,
      p_build_sequence                   	IN NUMBER,
      p_schedule_number		     		IN VARCHAR2,
      p_scheduled_flag                   	IN NUMBER,
      p_flow_schedule           		IN VARCHAR2,
      p_cost_group_id                    	IN NUMBER,

-- HW OPMCONV. Added p_secondary_trx_quantity
-- and p_secondary_uom_code
      p_secondary_trx_quantity                  IN NUMBER DEFAULT NULL,
      p_secondary_uom_code                      IN VARCHAR2 DEFAULT NULL
--      p_qa_collection_id                 	IN NUMBER,
--      p_kanban_card_id                   	IN NUMBER,
--      p_end_item_unit_number	      		IN VARCHAR2,
--      p_overcompletion_transaction_qty   	IN NUMBER,
--      p_overcompletion_primary_qty       	IN NUMBER,
--      p_overcompletion_transaction_id    	IN NUMBER,
--      p_scheduled_payback_date           	IN DATE
   )
   IS
      CURSOR lock_record IS
         SELECT * FROM mtl_transactions_interface
         WHERE rowid = x_rowid
         FOR UPDATE NOWAIT;

      rec_info lock_record%ROWTYPE;

 --
l_debug_on BOOLEAN;
 --
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ROW';
 --
   BEGIN

/*      wsh_server_debug.log_event('WSH_TRX_HANDLER.LOCK_ROW',
         'START',
         'Start of procedure LOCK_ROW, input parameters:
            transaction_interface_id='||p_trx_interface_id||
            ',transaction_header_id='||p_trx_header_id||
            ',source_code='||p_source_code||
            ',source_line_id='||p_source_line_id||
            ',source_header_id='||p_source_header_id||
            ',process_flag='||p_process_flag||
            ',validation_required='||p_validation_required||
            ',transaction_mode='||p_transaction_mode||
            ',lock_flag='||p_lock_flag||
            ',inventory_item_id='||p_inventory_item_id||
            ',item_segment1='||p_item_segment1||
            ',item_segment2='||p_item_segment2||
            ',item_segment3='||p_item_segment3||
            ',item_segment4='||p_item_segment4||
            ',item_segment5='||p_item_segment5||
            ',item_segment6='||p_item_segment6||
            ',item_segment7='||p_item_segment7||
            ',item_segment8='||p_item_segment8||
            ',item_segment9='||p_item_segment9||
            ',item_segment10='||p_item_segment10||
            ',item_segment11='||p_item_segment11||
            ',item_segment12='||p_item_segment12||
            ',item_segment13='||p_item_segment13||
            ',item_segment14='||p_item_segment14||
            ',item_segment15='||p_item_segment15||
            ',item_segment16='||p_item_segment16||
            ',item_segment17='||p_item_segment17||
            ',item_segment18='||p_item_segment18||
            ',item_segment19='||p_item_segment19||
            ',item_segment20='||p_item_segment20||
            ',revision='||p_revision||
            ',organization_id='||p_organization_id||
            ',transaction_quantity='||p_transaction_quantity||
            ',primary_quantity='||p_primary_quantity||
            ',transaction_uom='||p_trx_uom||
            ',transaction_date='||p_trx_date||
            ',acct_period_id='||p_acct_period_id||
            ',subinventory_code='||p_subinventory_code||
            ',locator_id='||p_locator_id||
            ',loc_segment1='||p_loc_segment1||
            ',loc_segment2='||p_loc_segment2||
            ',loc_segment3='||p_loc_segment3||
            ',loc_segment4='||p_loc_segment4||
            ',loc_segment5='||p_loc_segment5||
            ',loc_segment6='||p_loc_segment6||
            ',loc_segment7='||p_loc_segment7||
            ',loc_segment8='||p_loc_segment8||
            ',loc_segment9='||p_loc_segment9||
            ',loc_segment10='||p_loc_segment10||
            ',loc_segment11='||p_loc_segment11||
            ',loc_segment12='||p_loc_segment12||
            ',loc_segment13='||p_loc_segment13||
            ',loc_segment14='||p_loc_segment14||
            ',loc_segment15='||p_loc_segment15||
            ',loc_segment16='||p_loc_segment16||
            ',loc_segment17='||p_loc_segment17||
            ',loc_segment18='||p_loc_segment18||
            ',loc_segment19='||p_loc_segment19||
            ',loc_segment20='||p_loc_segment20||
            ',transaction_source_id='||p_trx_source_id||
            ',dsp_segment1='||p_dsp_segment1||
            ',dsp_segment2='||p_dsp_segment2||
            ',dsp_segment3='||p_dsp_segment3||
            ',dsp_segment4='||p_dsp_segment4||
            ',dsp_segment5='||p_dsp_segment5||
            ',dsp_segment6='||p_dsp_segment6||
            ',dsp_segment7='||p_dsp_segment7||
            ',dsp_segment8='||p_dsp_segment8||
            ',dsp_segment9='||p_dsp_segment9||
            ',dsp_segment10='||p_dsp_segment10||
            ',dsp_segment11='||p_dsp_segment11||
            ',dsp_segment12='||p_dsp_segment12||
            ',dsp_segment13='||p_dsp_segment13||
            ',dsp_segment14='||p_dsp_segment14||
            ',dsp_segment15='||p_dsp_segment15||
            ',dsp_segment16='||p_dsp_segment16||
            ',dsp_segment17='||p_dsp_segment17||
            ',dsp_segment18='||p_dsp_segment18||
            ',dsp_segment19='||p_dsp_segment19||
            ',dsp_segment20='||p_dsp_segment20||
            ',dsp_segment21='||p_dsp_segment21||
            ',dsp_segment22='||p_dsp_segment22||
            ',dsp_segment23='||p_dsp_segment23||
            ',dsp_segment24='||p_dsp_segment24||
            ',dsp_segment25='||p_dsp_segment25||
            ',dsp_segment26='||p_dsp_segment26||
            ',dsp_segment27='||p_dsp_segment27||
            ',dsp_segment28='||p_dsp_segment28||
            ',dsp_segment29='||p_dsp_segment29||
            ',dsp_segment30='||p_dsp_segment30||
            ',transaction_source_name='||p_trx_source_name||
            ',transaction_source_type_id='||p_trx_source_type_id||
            ',transaction_action_id='||p_trx_action_id||
            ',transaction_type_id='||p_trx_type_id||
            ',reason_id='||p_reason_id||
            ',transaction_reference='||p_trx_reference||
            ',transaction_cost='||p_trx_cost||
            ',distribution_account_id='||p_distribution_acct_id||
            ',dst_segment1='||p_dst_segment1||
            ',dst_segment2='||p_dst_segment2||
            ',dst_segment3='||p_dst_segment3||
            ',dst_segment4='||p_dst_segment4||
            ',dst_segment5='||p_dst_segment5||
            ',dst_segment6='||p_dst_segment6||
            ',dst_segment7='||p_dst_segment7||
            ',dst_segment8='||p_dst_segment8||
            ',dst_segment9='||p_dst_segment9||
            ',dst_segment10='||p_dst_segment10||
            ',dst_segment11='||p_dst_segment11||
            ',dst_segment12='||p_dst_segment12||
            ',dst_segment13='||p_dst_segment13||
            ',dst_segment14='||p_dst_segment14||
            ',dst_segment15='||p_dst_segment15||
            ',dst_segment16='||p_dst_segment16||
            ',dst_segment17='||p_dst_segment17||
            ',dst_segment18='||p_dst_segment18||
            ',dst_segment19='||p_dst_segment19||
            ',dst_segment20='||p_dst_segment20||
            ',dst_segment21='||p_dst_segment21||
            ',dst_segment22='||p_dst_segment22||
            ',dst_segment23='||p_dst_segment23||
            ',dst_segment24='||p_dst_segment24||
            ',dst_segment25='||p_dst_segment25||
            ',dst_segment26='||p_dst_segment26||
            ',dst_segment27='||p_dst_segment27||
            ',dst_segment28='||p_dst_segment28||
            ',dst_segment29='||p_dst_segment29||
            ',dst_segment30='||p_dst_segment30||
            ',requisition_line_id='||p_requisition_line_id||
            ',currency_code='||p_currency_code||
            ',currency_conversion_date='||p_currency_conversion_date||
            ',currency_conversion_type='||p_currency_conversion_type||
            ',currency_conversion_rate='||p_currency_conversion_rate||
            ',ussgl_transaction_code='||p_ussgl_transaction_code||
            ',wip_entity_type='||p_wip_entity_type||
            ',schedule_id='||p_schedule_id||
            ',employee_code='||p_employee_code||
            ',department_id='||p_department_id||
            ',schedule_update_code='||p_schedule_update_code||
            ',setup_teardown_code='||p_setup_teardown_code||
            ',primary_switch='||p_primary_switch||
            ',mrp_code='||p_mrp_code||
            ',operation_seq_num='||p_operation_seq_num||
            ',repetitive_line_id='||p_repetitive_line_id||
            ',picking_line_id='||p_picking_line_id||
            ',trx_source_line_id='||p_trx_source_line_id||
            ',trx_source_delivery_id='||p_trx_source_delivery_id||
            ',demand_id='||p_demand_id||
            ',customer_ship_id='||p_customer_ship_id||
            ',line_item_num='||p_line_item_num||
            ',receiving_document='||p_receiving_document||
            ',rcv_transaction_id='||p_rcv_transaction_id||
            ',ship_to_location_id='||p_ship_to_location_id||
            ',encumbrance_account='||p_encumbrance_account||
            ',encumbrance_amount='||p_encumbrance_amount||
            ',vendor_lot_number='||p_vendor_lot_number||
            ',transfer_subinventory='||p_transfer_subinventory||
            ',transfer_organization='||p_transfer_organization||
            ',transfer_locator='||p_transfer_locator||
            ',xfer_loc_segment1='||p_xfer_loc_segment1||
            ',xfer_loc_segment2='||p_xfer_loc_segment2||
            ',xfer_loc_segment3='||p_xfer_loc_segment3||
            ',xfer_loc_segment4='||p_xfer_loc_segment4||
            ',xfer_loc_segment5='||p_xfer_loc_segment5||
            ',xfer_loc_segment6='||p_xfer_loc_segment6||
            ',xfer_loc_segment7='||p_xfer_loc_segment7||
            ',xfer_loc_segment8='||p_xfer_loc_segment8||
            ',xfer_loc_segment9='||p_xfer_loc_segment9||
            ',xfer_loc_segment10='||p_xfer_loc_segment10||
            ',xfer_loc_segment11='||p_xfer_loc_segment11||
            ',xfer_loc_segment12='||p_xfer_loc_segment12||
            ',xfer_loc_segment13='||p_xfer_loc_segment13||
            ',xfer_loc_segment14='||p_xfer_loc_segment14||
            ',xfer_loc_segment15='||p_xfer_loc_segment15||
            ',xfer_loc_segment16='||p_xfer_loc_segment16||
            ',xfer_loc_segment17='||p_xfer_loc_segment17||
            ',xfer_loc_segment18='||p_xfer_loc_segment18||
            ',xfer_loc_segment19='||p_xfer_loc_segment19||
            ',xfer_loc_segment20='||p_xfer_loc_segment20||
            ',shipment_number='||p_shipment_number||
            ',transportation_cost='||p_transportation_cost||
            ',transportation_account='||p_transportation_account||
            ',transfer_cost='||p_transfer_cost||
            ',freight_code='||p_freight_code||
            ',containers='||p_containers||
            ',waybill_airbill='||p_waybill_airbill||
            ',expected_arrival_date='||p_expected_arrival_date||
            ',new_average_cost='||p_new_average_cost||
            ',value_change='||p_value_change||
            ',percentage_change='||p_percentage_change||
            ',demand_source_header_id='||p_demand_source_header_id||
            ',demand_source_line='||p_demand_source_line||
            ',demand_source_delivery='||p_demand_source_delivery||
            ',negative_req_flag='||p_negative_req_flag||
            ',error_explanation='||p_error_explanation||
            ',shippable_flag='||p_shippable_flag||
            ',error_code='||p_error_code||
            ',required_flag='||p_required_flag||
            ',attribute_category='||p_attribute_category||
            ',attribute1='||p_attribute1||
            ',attribute2='||p_attribute2||
            ',attribute3='||p_attribute3||
            ',attribute4='||p_attribute4||
            ',attribute5='||p_attribute5||
            ',attribute6='||p_attribute6||
            ',attribute7='||p_attribute7||
            ',attribute8='||p_attribute8||
            ',attribute9='||p_attribute9||
            ',attribute10='||p_attribute10||
            ',attribute11='||p_attribute11||
            ',attribute12='||p_attribute12||
            ',attribute13='||p_attribute13||
            ',attribute14='||p_attribute14||
            ',attribute15='||p_attribute15||
            ',requisition_distribution_id='||p_requisition_distribution_id||
            ',movement_id='||p_movement_id||
            ',reservation_quantity='||p_reservation_quantity||
            ',shipped_quantity='||p_shipped_quantity||
            ',inventory_item='||p_inventory_item||
            ',locator_name='||p_locator_name||
            ',task_id='||p_task_id||
            ',to_task_id='||p_to_task_id||
            ',source_task_id='||p_source_task_id||
            ',project_id='||p_project_id||
            ',to_project_id='||p_to_project_id||
            ',source_project_id='||p_source_project_id||
            ',pa_expenditure_org_id='||p_pa_expenditure_org_id||
            ',expenditure_type='||p_expenditure_type||
            ',final_completion_flag='||p_final_completion_flag||
            ',transfer_percentage='||p_transfer_percentage||
            ',transaction_sequence_id='||p_trx_sequence_id||
            ',material_account='||p_material_account||
            ',material_overhead_account='||p_material_overhead_account||
            ',resource_account='||p_resource_account||
            ',outside_processing_account='||p_outside_processing_account||
            ',overhead_account='||p_overhead_account||
            ',bom_revision='||p_bom_revision||
            ',routing_revision='||p_routing_revision||
            ',bom_revision_date='||p_bom_revision_date||
            ',routing_revision_date='||p_routing_revision_date||
            ',alternate_bom_designator='||p_alternate_bom_designator||
            ',alternate_routing_designator='||p_alternate_routing_designator||
            ',accounting_class='||p_accounting_class||
            ',demand_class='||p_demand_class||
            ',parent_id='||p_parent_id||
            ',substitution_type_id='||p_substitution_type_id||
            ',substitution_item_id='||p_substitution_item_id||
            ',schedule_group='||p_schedule_group||
            ',build_sequence='||p_build_sequence||
            ',schedule_number='||p_schedule_number||
            ',scheduled_flag='||p_scheduled_flag||
            ',flow_schedule='||p_flow_schedule||
            ',cost_group_id='||p_cost_group_id);
*/
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
          WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_INTERFACE_ID',P_TRX_INTERFACE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_HEADER_ID',P_TRX_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROCESS_FLAG',P_PROCESS_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_REQUIRED',P_VALIDATION_REQUIRED);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_MODE',P_TRANSACTION_MODE);
          WSH_DEBUG_SV.log(l_module_name,'P_LOCK_FLAG',P_LOCK_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT1',P_ITEM_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT2',P_ITEM_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT3',P_ITEM_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT4',P_ITEM_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT5',P_ITEM_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT6',P_ITEM_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT7',P_ITEM_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT8',P_ITEM_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT9',P_ITEM_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT10',P_ITEM_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT11',P_ITEM_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT12',P_ITEM_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT13',P_ITEM_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT14',P_ITEM_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT15',P_ITEM_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT16',P_ITEM_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT17',P_ITEM_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT18',P_ITEM_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT19',P_ITEM_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_ITEM_SEGMENT20',P_ITEM_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_REVISION',P_REVISION);
          WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSACTION_QUANTITY',P_TRANSACTION_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_QUANTITY',P_PRIMARY_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_UOM',P_TRX_UOM);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_DATE',P_TRX_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_ACCT_PERIOD_ID',P_ACCT_PERIOD_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY_CODE',P_SUBINVENTORY_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_ID',P_LOCATOR_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT1',P_LOC_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT2',P_LOC_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT3',P_LOC_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT4',P_LOC_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT5',P_LOC_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT6',P_LOC_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT7',P_LOC_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT8',P_LOC_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT9',P_LOC_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT10',P_LOC_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT11',P_LOC_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT12',P_LOC_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT13',P_LOC_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT14',P_LOC_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT15',P_LOC_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT16',P_LOC_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT17',P_LOC_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT18',P_LOC_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT19',P_LOC_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_LOC_SEGMENT20',P_LOC_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_ID',P_TRX_SOURCE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT1',P_DSP_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT2',P_DSP_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT3',P_DSP_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT4',P_DSP_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT5',P_DSP_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT6',P_DSP_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT7',P_DSP_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT8',P_DSP_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT9',P_DSP_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT10',P_DSP_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT11',P_DSP_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT12',P_DSP_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT13',P_DSP_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT14',P_DSP_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT15',P_DSP_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT16',P_DSP_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT17',P_DSP_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT18',P_DSP_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT19',P_DSP_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT20',P_DSP_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT21',P_DSP_SEGMENT21);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT22',P_DSP_SEGMENT22);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT23',P_DSP_SEGMENT23);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT24',P_DSP_SEGMENT24);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT25',P_DSP_SEGMENT25);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT26',P_DSP_SEGMENT26);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT27',P_DSP_SEGMENT27);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT28',P_DSP_SEGMENT28);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT29',P_DSP_SEGMENT29);
          WSH_DEBUG_SV.log(l_module_name,'P_DSP_SEGMENT30',P_DSP_SEGMENT30);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_NAME',P_TRX_SOURCE_NAME);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_TYPE_ID',P_TRX_SOURCE_TYPE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_ACTION_ID',P_TRX_ACTION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_TYPE_ID',P_TRX_TYPE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_REASON_ID',P_REASON_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_REFERENCE',P_TRX_REFERENCE);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_COST',P_TRX_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_DISTRIBUTION_ACCT_ID',P_DISTRIBUTION_ACCT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT1',P_DST_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT2',P_DST_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT3',P_DST_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT4',P_DST_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT5',P_DST_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT6',P_DST_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT7',P_DST_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT8',P_DST_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT9',P_DST_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT10',P_DST_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT11',P_DST_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT12',P_DST_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT13',P_DST_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT14',P_DST_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT15',P_DST_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT16',P_DST_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT17',P_DST_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT18',P_DST_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT19',P_DST_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT20',P_DST_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT21',P_DST_SEGMENT21);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT22',P_DST_SEGMENT22);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT23',P_DST_SEGMENT23);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT24',P_DST_SEGMENT24);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT25',P_DST_SEGMENT25);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT26',P_DST_SEGMENT26);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT27',P_DST_SEGMENT27);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT28',P_DST_SEGMENT28);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT29',P_DST_SEGMENT29);
          WSH_DEBUG_SV.log(l_module_name,'P_DST_SEGMENT30',P_DST_SEGMENT30);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUISITION_LINE_ID',P_REQUISITION_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CODE',P_CURRENCY_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CONVERSION_DATE',P_CURRENCY_CONVERSION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CONVERSION_TYPE',P_CURRENCY_CONVERSION_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_CURRENCY_CONVERSION_RATE',P_CURRENCY_CONVERSION_RATE);
          WSH_DEBUG_SV.log(l_module_name,'P_USSGL_TRANSACTION_CODE',P_USSGL_TRANSACTION_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_WIP_ENTITY_TYPE',P_WIP_ENTITY_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_ID',P_SCHEDULE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_EMPLOYEE_CODE',P_EMPLOYEE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_DEPARTMENT_ID',P_DEPARTMENT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_UPDATE_CODE',P_SCHEDULE_UPDATE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_SETUP_TEARDOWN_CODE',P_SETUP_TEARDOWN_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_SWITCH',P_PRIMARY_SWITCH);
          WSH_DEBUG_SV.log(l_module_name,'P_MRP_CODE',P_MRP_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_OPERATION_SEQ_NUM',P_OPERATION_SEQ_NUM);
          WSH_DEBUG_SV.log(l_module_name,'P_REPETITIVE_LINE_ID',P_REPETITIVE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PICKING_LINE_ID',P_PICKING_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_LINE_ID',P_TRX_SOURCE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SOURCE_DELIVERY_ID',P_TRX_SOURCE_DELIVERY_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_ID',P_DEMAND_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_SHIP_ID',P_CUSTOMER_SHIP_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_LINE_ITEM_NUM',P_LINE_ITEM_NUM);
          WSH_DEBUG_SV.log(l_module_name,'P_RECEIVING_DOCUMENT',P_RECEIVING_DOCUMENT);
          WSH_DEBUG_SV.log(l_module_name,'P_RCV_TRANSACTION_ID',P_RCV_TRANSACTION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_LOCATION_ID',P_SHIP_TO_LOCATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_ENCUMBRANCE_ACCOUNT',P_ENCUMBRANCE_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_ENCUMBRANCE_AMOUNT',P_ENCUMBRANCE_AMOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_VENDOR_LOT_NUMBER',P_VENDOR_LOT_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_SUBINVENTORY',P_TRANSFER_SUBINVENTORY);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_ORGANIZATION',P_TRANSFER_ORGANIZATION);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_LOCATOR',P_TRANSFER_LOCATOR);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT1',P_XFER_LOC_SEGMENT1);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT2',P_XFER_LOC_SEGMENT2);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT3',P_XFER_LOC_SEGMENT3);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT4',P_XFER_LOC_SEGMENT4);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT5',P_XFER_LOC_SEGMENT5);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT6',P_XFER_LOC_SEGMENT6);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT7',P_XFER_LOC_SEGMENT7);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT8',P_XFER_LOC_SEGMENT8);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT9',P_XFER_LOC_SEGMENT9);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT10',P_XFER_LOC_SEGMENT10);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT11',P_XFER_LOC_SEGMENT11);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT12',P_XFER_LOC_SEGMENT12);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT13',P_XFER_LOC_SEGMENT13);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT14',P_XFER_LOC_SEGMENT14);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT15',P_XFER_LOC_SEGMENT15);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT16',P_XFER_LOC_SEGMENT16);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT17',P_XFER_LOC_SEGMENT17);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT18',P_XFER_LOC_SEGMENT18);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT19',P_XFER_LOC_SEGMENT19);
          WSH_DEBUG_SV.log(l_module_name,'P_XFER_LOC_SEGMENT20',P_XFER_LOC_SEGMENT20);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_NUMBER',P_SHIPMENT_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSPORTATION_COST',P_TRANSPORTATION_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSPORTATION_ACCOUNT',P_TRANSPORTATION_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_COST',P_TRANSFER_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_CODE',P_FREIGHT_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_CONTAINERS',P_CONTAINERS);
          WSH_DEBUG_SV.log(l_module_name,'P_WAYBILL_AIRBILL',P_WAYBILL_AIRBILL);
          WSH_DEBUG_SV.log(l_module_name,'P_EXPECTED_ARRIVAL_DATE',P_EXPECTED_ARRIVAL_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_NEW_AVERAGE_COST',P_NEW_AVERAGE_COST);
          WSH_DEBUG_SV.log(l_module_name,'P_VALUE_CHANGE',P_VALUE_CHANGE);
          WSH_DEBUG_SV.log(l_module_name,'P_PERCENTAGE_CHANGE',P_PERCENTAGE_CHANGE);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_SOURCE_HEADER_ID',P_DEMAND_SOURCE_HEADER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_SOURCE_LINE',P_DEMAND_SOURCE_LINE);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_SOURCE_DELIVERY',P_DEMAND_SOURCE_DELIVERY);
          WSH_DEBUG_SV.log(l_module_name,'P_NEGATIVE_REQ_FLAG',P_NEGATIVE_REQ_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_ERROR_EXPLANATION',P_ERROR_EXPLANATION);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIPPABLE_FLAG',P_SHIPPABLE_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_ERROR_CODE',P_ERROR_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUIRED_FLAG',P_REQUIRED_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE_CATEGORY',P_ATTRIBUTE_CATEGORY);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE1',P_ATTRIBUTE1);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE2',P_ATTRIBUTE2);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE3',P_ATTRIBUTE3);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE4',P_ATTRIBUTE4);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE5',P_ATTRIBUTE5);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE6',P_ATTRIBUTE6);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE7',P_ATTRIBUTE7);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE8',P_ATTRIBUTE8);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE9',P_ATTRIBUTE9);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE10',P_ATTRIBUTE10);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE11',P_ATTRIBUTE11);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE12',P_ATTRIBUTE12);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE13',P_ATTRIBUTE13);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE14',P_ATTRIBUTE14);
          WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE15',P_ATTRIBUTE15);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUISITION_DISTRIBUTION_ID',P_REQUISITION_DISTRIBUTION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_MOVEMENT_ID',P_MOVEMENT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_RESERVATION_QUANTITY',P_RESERVATION_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_SHIPPED_QUANTITY',P_SHIPPED_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM',P_INVENTORY_ITEM);
          WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_NAME',P_LOCATOR_NAME);
          WSH_DEBUG_SV.log(l_module_name,'P_TASK_ID',P_TASK_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TO_TASK_ID',P_TO_TASK_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_TASK_ID',P_SOURCE_TASK_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROJECT_ID',P_PROJECT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TO_PROJECT_ID',P_TO_PROJECT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_PROJECT_ID',P_SOURCE_PROJECT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PA_EXPENDITURE_ORG_ID',P_PA_EXPENDITURE_ORG_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_EXPENDITURE_TYPE',P_EXPENDITURE_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_FINAL_COMPLETION_FLAG',P_FINAL_COMPLETION_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_TRANSFER_PERCENTAGE',P_TRANSFER_PERCENTAGE);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_SEQUENCE_ID',P_TRX_SEQUENCE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_MATERIAL_ACCOUNT',P_MATERIAL_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_MATERIAL_OVERHEAD_ACCOUNT',P_MATERIAL_OVERHEAD_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_RESOURCE_ACCOUNT',P_RESOURCE_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_OUTSIDE_PROCESSING_ACCOUNT',P_OUTSIDE_PROCESSING_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_OVERHEAD_ACCOUNT',P_OVERHEAD_ACCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_BOM_REVISION',P_BOM_REVISION);
          WSH_DEBUG_SV.log(l_module_name,'P_ROUTING_REVISION',P_ROUTING_REVISION);
          WSH_DEBUG_SV.log(l_module_name,'P_BOM_REVISION_DATE',P_BOM_REVISION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_ROUTING_REVISION_DATE',P_ROUTING_REVISION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_ALTERNATE_BOM_DESIGNATOR',P_ALTERNATE_BOM_DESIGNATOR);
          WSH_DEBUG_SV.log(l_module_name,'P_ALTERNATE_ROUTING_DESIGNATOR',P_ALTERNATE_ROUTING_DESIGNATOR);
          WSH_DEBUG_SV.log(l_module_name,'P_ACCOUNTING_CLASS',P_ACCOUNTING_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'P_DEMAND_CLASS',P_DEMAND_CLASS);
          WSH_DEBUG_SV.log(l_module_name,'P_PARENT_ID',P_PARENT_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SUBSTITUTION_TYPE_ID',P_SUBSTITUTION_TYPE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SUBSTITUTION_ITEM_ID',P_SUBSTITUTION_ITEM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_GROUP',P_SCHEDULE_GROUP);
          WSH_DEBUG_SV.log(l_module_name,'P_BUILD_SEQUENCE',P_BUILD_SEQUENCE);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_NUMBER',P_SCHEDULE_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULED_FLAG',P_SCHEDULED_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_FLOW_SCHEDULE',P_FLOW_SCHEDULE);
          WSH_DEBUG_SV.log(l_module_name,'P_COST_GROUP_ID',P_COST_GROUP_ID);
-- HW OPMCONV. Added debugging msgs
          WSH_DEBUG_SV.log(l_module_name,'P_SECONDARY_TRX_QUANTITY',P_SECONDARY_TRX_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'p_secondary_uom_code',p_secondary_uom_code);
      END IF;
      --
      OPEN lock_record;

      FETCH lock_record into rec_info;

      IF (lock_record%NOTFOUND) THEN
/*        wsh_server_debug.log_event('WSH_TRX_HANDLER.LOCK_ROW',
             'END',
             'Lock record failed.  Raising exception FORM_RECORD_DELETED');
*/
         CLOSE lock_record;

         fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name,'FORM_RECORD_DELETED');
         END IF;
         app_exception.raise_exception;
      END IF;

      CLOSE lock_record;

      IF ( ( (rec_info.transaction_interface_id = p_trx_interface_id)
            OR ((rec_info.transaction_interface_id IS NULL)
               AND (p_trx_interface_id IS NULL)))
         AND ((rec_info.transaction_header_id = p_trx_header_id)
            OR ((rec_info.transaction_header_id IS NULL)
               AND (p_trx_header_id IS NULL)))
         AND (rec_info.source_code = p_source_code)
         AND (rec_info.source_line_id = p_source_line_id)
         AND (rec_info.source_header_id = p_source_header_id)
         AND (rec_info.process_flag = p_process_flag)
         AND ((rec_info.validation_required = p_validation_required)
            OR ((rec_info.validation_required IS NULL)
               AND (p_validation_required IS NULL)))
         AND (rec_info.transaction_mode = p_transaction_mode)
         AND ((rec_info.lock_flag = p_lock_flag)
            OR ((rec_info.lock_flag IS NULL) AND (p_lock_flag IS NULL)))
         AND ((rec_info.inventory_item_id = p_inventory_item_id)
            OR ((rec_info.inventory_item_id IS NULL)
               AND (p_inventory_item_id IS NULL)))
         AND ((rec_info.item_segment1 = p_item_segment1)
            OR ((rec_info.item_segment1 IS NULL) AND (p_item_segment1 IS NULL)))
         AND ((rec_info.item_segment2 = p_item_segment2)
            OR ((rec_info.item_segment2 IS NULL) AND (p_item_segment2 IS NULL)))
         AND ((rec_info.item_segment3 = p_item_segment3)
            OR ((rec_info.item_segment3 IS NULL) AND (p_item_segment3 is NULL)))
         AND ((rec_info.item_segment4 = p_item_segment4)
            OR ((rec_info.item_segment4 IS NULL) AND (p_item_segment4 is NULL)))
         AND ((rec_info.item_segment5 = p_item_segment5)
            OR ((rec_info.item_segment5 IS NULL) AND (p_item_segment5 is NULL)))
         AND ((rec_info.item_segment6 = p_item_segment6)
            OR ((rec_info.item_segment6 IS NULL) AND (p_item_segment6 is NULL)))
         AND ((rec_info.item_segment7 = p_item_segment7)
            OR ((rec_info.item_segment7 IS NULL) AND (p_item_segment7 is NULL)))
         AND ((rec_info.item_segment8 = p_item_segment8)
            OR ((rec_info.item_segment8 IS NULL) AND (p_item_segment8 is NULL)))
         AND ((rec_info.item_segment9 = p_item_segment9)
            OR ((rec_info.item_segment9 IS NULL) AND (p_item_segment9 is NULL)))
         AND ((rec_info.item_segment10 = p_item_segment10)
            OR ((rec_info.item_segment10 IS NULL)
               AND (p_item_segment10 is NULL)))
         AND ((rec_info.item_segment11 = p_item_segment11)
            OR ((rec_info.item_segment11 IS NULL)
               AND (p_item_segment11 is NULL)))
         AND ((rec_info.item_segment12 = p_item_segment12)
            OR ((rec_info.item_segment12 IS NULL)
               AND (p_item_segment12 is NULL)))
         AND ((rec_info.item_segment13 = p_item_segment13)
            OR ((rec_info.item_segment13 IS NULL)
               AND (p_item_segment13 is NULL)))
         AND ((rec_info.item_segment14 = p_item_segment14)
            OR ((rec_info.item_segment14 IS NULL)
               AND (p_item_segment14 is NULL)))
         AND ((rec_info.item_segment15 = p_item_segment15)
            OR ((rec_info.item_segment15 IS NULL)
               AND (p_item_segment15 is NULL)))
         AND ((rec_info.item_segment16 = p_item_segment16)
            OR ((rec_info.item_segment16 IS NULL)
               AND (p_item_segment16 is NULL)))
         AND ((rec_info.item_segment17 = p_item_segment17)
            OR ((rec_info.item_segment17 IS NULL)
               AND (p_item_segment17 is NULL)))
         AND ((rec_info.item_segment18 = p_item_segment18)
            OR ((rec_info.item_segment18 IS NULL)
               AND (p_item_segment18 is NULL)))
         AND (( rec_info.item_segment19 = p_item_segment19)
            OR ((rec_info.item_segment19 IS NULL)
               AND (p_item_segment19 is NULL)))
         AND (( rec_info.item_segment20 = p_item_segment20)
            OR ((rec_info.item_segment20 IS NULL)
               AND (p_item_segment20 is NULL)))
         AND ((rec_info.revision = p_revision)
            OR ((rec_info.revision IS NULL) AND (p_revision is NULL)))
         AND (rec_info.organization_id = p_organization_id)
         AND (rec_info.transaction_quantity = p_transaction_quantity)
         AND ((rec_info.primary_quantity = p_primary_quantity)
            OR ((rec_info.primary_quantity IS NULL)
               AND (p_primary_quantity is NULL)))
         AND (rec_info.transaction_uom = p_trx_uom)
         AND (rec_info.transaction_date = p_trx_date)
         AND ((rec_info.acct_period_id = p_acct_period_id)
            OR ((rec_info.acct_period_id IS NULL)
               AND (p_acct_period_id is NULL)))
         AND ((rec_info.subinventory_code = p_subinventory_code)
            OR ((rec_info.subinventory_code IS NULL)
               AND (p_subinventory_code is NULL)))
         AND ((rec_info.locator_id = p_locator_id)
            OR ((rec_info.locator_id IS NULL) AND (p_locator_id is NULL)))
         AND ((rec_info.loc_segment1 = p_loc_segment1)
            OR ((rec_info.loc_segment1 IS NULL) AND (p_loc_segment1 is NULL)))
         AND ((rec_info.loc_segment2 = p_loc_segment2)
            OR ((rec_info.loc_segment2 IS NULL) AND (p_loc_segment2 is NULL)))
         AND ((rec_info.loc_segment3 = p_loc_segment3)
            OR ((rec_info.loc_segment3 IS NULL) AND (p_loc_segment3 is NULL)))
         AND ((rec_info.loc_segment4 = p_loc_segment4)
            OR ((rec_info.loc_segment4 IS NULL) AND (p_loc_segment4 is NULL)))
         AND ((rec_info.loc_segment5 = p_loc_segment5)
            OR ((rec_info.loc_segment5 IS NULL) AND (p_loc_segment5 is NULL)))
         AND ((rec_info.loc_segment6 = p_loc_segment6)
            OR ((rec_info.loc_segment6 IS NULL) AND (p_loc_segment6 is NULL)))
         AND ((rec_info.loc_segment7 = p_loc_segment7)
            OR ((rec_info.loc_segment7 IS NULL) AND (p_loc_segment7 is NULL)))
         AND ((rec_info.loc_segment8 = p_loc_segment8)
            OR ((rec_info.loc_segment8 IS NULL) AND (p_loc_segment8 is NULL)))
         AND ((rec_info.loc_segment9 = p_loc_segment9)
            OR ((rec_info.loc_segment9 IS NULL) AND (p_loc_segment9 is NULL)))
         AND ((rec_info.loc_segment10 = p_loc_segment10)
            OR ((rec_info.loc_segment10 IS NULL) AND (p_loc_segment10 is NULL)))
         AND ((rec_info.loc_segment11 = p_loc_segment11)
            OR ((rec_info.loc_segment11 IS NULL) AND (p_loc_segment11 is NULL)))
         AND ((rec_info.loc_segment12 = p_loc_segment12)
            OR ((rec_info.loc_segment12 IS NULL) AND (p_loc_segment12 is NULL)))
         AND ((rec_info.loc_segment13 = p_loc_segment13)
            OR ((rec_info.loc_segment13 IS NULL) AND (p_loc_segment13 is NULL)))
         AND ((rec_info.loc_segment14 = p_loc_segment14)
            OR ((rec_info.loc_segment14 IS NULL) AND (p_loc_segment14 is NULL)))
         AND ((rec_info.loc_segment15 = p_loc_segment15)
            OR ((rec_info.loc_segment15 IS NULL) AND (p_loc_segment15 is NULL)))
         AND ((rec_info.loc_segment16 = p_loc_segment16)
            OR ((rec_info.loc_segment16 IS NULL) AND (p_loc_segment16 is NULL)))
         AND ((rec_info.loc_segment17 = p_loc_segment17)
            OR ((rec_info.loc_segment17 IS NULL) AND (p_loc_segment17 is NULL)))
         AND ((rec_info.loc_segment18 = p_loc_segment18)
            OR ((rec_info.loc_segment18 IS NULL) AND (p_loc_segment18 is NULL)))
         AND ((rec_info.loc_segment19 = p_loc_segment19)
            OR ((rec_info.loc_segment19 IS NULL) AND (p_loc_segment19 is NULL)))
         AND ((rec_info.loc_segment20 = p_loc_segment20)
            OR ((rec_info.loc_segment20 IS NULL) AND (p_loc_segment20 is NULL)))
         AND ((rec_info.transaction_source_id = p_trx_source_id)
            OR ((rec_info.transaction_source_id IS NULL)
               AND (p_trx_source_id is NULL)))
         AND ((rec_info.dsp_segment1 = p_dsp_segment1)
            OR ((rec_info.dsp_segment1 IS NULL) AND (p_dsp_segment1 is NULL)))
         AND ((rec_info.dsp_segment2 = p_dsp_segment2)
            OR ((rec_info.dsp_segment2 IS NULL) AND (p_dsp_segment2 is NULL)))
         AND ((rec_info.dsp_segment3 = p_dsp_segment3)
            OR ((rec_info.dsp_segment3 IS NULL) AND (p_dsp_segment3 is NULL)))
         AND ((rec_info.dsp_segment4 = p_dsp_segment4)
            OR ((rec_info.dsp_segment4 IS NULL) AND (p_dsp_segment4 is NULL)))
         AND ((rec_info.dsp_segment5 = p_dsp_segment5)
            OR ((rec_info.dsp_segment5 IS NULL) AND (p_dsp_segment5 is NULL)))
         AND ((rec_info.dsp_segment6 = p_dsp_segment6)
            OR ((rec_info.dsp_segment6 IS NULL) AND (p_dsp_segment6 is NULL)))
         AND ((rec_info.dsp_segment7 = p_dsp_segment7)
            OR ((rec_info.dsp_segment7 IS NULL) AND (p_dsp_segment7 is NULL)))
         AND ((rec_info.dsp_segment8 = p_dsp_segment8)
            OR ((rec_info.dsp_segment8 IS NULL) AND (p_dsp_segment8 is NULL)))
         AND ((rec_info.dsp_segment9 = p_dsp_segment9)
            OR ((rec_info.dsp_segment9 IS NULL) AND (p_dsp_segment9 is NULL)))
         AND ((rec_info.dsp_segment10 = p_dsp_segment10)
            OR ((rec_info.dsp_segment10 IS NULL) AND (p_dsp_segment10 is NULL)))
         AND ((rec_info.dsp_segment11 = p_dsp_segment11)
            OR ((rec_info.dsp_segment11 IS NULL) AND (p_dsp_segment11 is NULL)))
         AND ((rec_info.dsp_segment12 = p_dsp_segment12)
            OR ((rec_info.dsp_segment12 IS NULL) AND (p_dsp_segment12 is NULL)))
         AND ((rec_info.dsp_segment13 = p_dsp_segment13)
            OR ((rec_info.dsp_segment13 IS NULL) AND (p_dsp_segment13 is NULL)))
         AND ((rec_info.dsp_segment14 = p_dsp_segment14)
            OR ((rec_info.dsp_segment14 IS NULL) AND (p_dsp_segment14 is NULL)))
         AND ((rec_info.dsp_segment15 = p_dsp_segment15)
            OR ((rec_info.dsp_segment15 IS NULL) AND (p_dsp_segment15 is NULL)))
         AND ((rec_info.dsp_segment16 = p_dsp_segment16)
            OR ((rec_info.dsp_segment16 IS NULL) AND (p_dsp_segment16 is NULL)))
         AND ((rec_info.dsp_segment17 = p_dsp_segment17)
            OR ((rec_info.dsp_segment17 IS NULL) AND (p_dsp_segment17 is NULL)))
         AND ((rec_info.dsp_segment18 = p_dsp_segment18)
            OR ((rec_info.dsp_segment18 IS NULL) AND (p_dsp_segment18 is NULL)))
         AND ((rec_info.dsp_segment19 = p_dsp_segment19)
            OR ((rec_info.dsp_segment19 IS NULL) AND (p_dsp_segment19 is NULL)))
         AND ((rec_info.dsp_segment20 = p_dsp_segment20)
            OR ((rec_info.dsp_segment20 IS NULL) AND (p_dsp_segment20 is NULL)))
         AND ((rec_info.dsp_segment21 = p_dsp_segment21)
            OR ((rec_info.dsp_segment21 IS NULL) AND (p_dsp_segment21 is NULL)))
         AND ((rec_info.dsp_segment22 = p_dsp_segment22)
            OR ((rec_info.dsp_segment22 IS NULL) AND (p_dsp_segment22 is NULL)))
         AND ((rec_info.dsp_segment23 = p_dsp_segment23)
            OR ((rec_info.dsp_segment23 IS NULL) AND (p_dsp_segment23 is NULL)))
         AND ((rec_info.dsp_segment24 = p_dsp_segment24)
            OR ((rec_info.dsp_segment24 IS NULL) AND (p_dsp_segment24 is NULL)))
         AND ((rec_info.dsp_segment25 = p_dsp_segment25)
            OR ((rec_info.dsp_segment25 IS NULL) AND (p_dsp_segment25 is NULL)))
         AND ((rec_info.dsp_segment26 = p_dsp_segment26)
            OR ((rec_info.dsp_segment26 IS NULL) AND (p_dsp_segment26 is NULL)))
         AND ((rec_info.dsp_segment27 = p_dsp_segment27)
            OR ((rec_info.dsp_segment27 IS NULL) AND (p_dsp_segment27 is NULL)))
         AND ((rec_info.dsp_segment28 = p_dsp_segment28)
            OR ((rec_info.dsp_segment28 IS NULL) AND (p_dsp_segment28 is NULL)))
         AND ((rec_info.dsp_segment29 = p_dsp_segment29)
            OR ((rec_info.dsp_segment29 IS NULL) AND (p_dsp_segment29 is NULL)))
         AND ((rec_info.dsp_segment30 = p_dsp_segment30)
            OR ((rec_info.dsp_segment30 IS NULL) AND (p_dsp_segment30 is NULL)))
         AND ((rec_info.transaction_source_name = p_trx_source_name)
            OR ((rec_info.transaction_source_name IS NULL)
               AND (p_trx_source_type_id is NULL)))
         AND ((rec_info.transaction_source_type_id = p_trx_source_type_id)
            OR ((rec_info.transaction_source_type_id IS NULL)
               AND (p_trx_source_type_id is NULL)))
         AND ((rec_info.transaction_action_id = p_trx_action_id)
            OR ((rec_info.transaction_action_id IS NULL)
               AND (p_trx_action_id is NULL)))
         AND (rec_info.transaction_type_id = p_trx_type_id)
         AND ((rec_info.reason_id = p_reason_id)
            OR ((rec_info.reason_id IS NULL) AND (p_reason_id is NULL)))
         AND ((rec_info.transaction_reference = p_trx_reference)
            OR ((rec_info.transaction_reference IS NULL)
               AND (p_trx_reference is NULL)))
         AND ((rec_info.transaction_cost = p_trx_cost)
            OR ((rec_info.transaction_cost IS NULL) AND (p_trx_cost is NULL)))
         AND ((rec_info.distribution_account_id = p_distribution_acct_id)
            OR ((rec_info.distribution_account_id IS NULL)
               AND (p_distribution_acct_id is NULL)))
         AND ((rec_info.dst_segment1 = p_dst_segment1)
            OR ((rec_info.dst_segment1 IS NULL) AND (p_dst_segment1 is NULL)))
         AND ((rec_info.dst_segment2 = p_dst_segment2)
            OR ((rec_info.dst_segment2 IS NULL) AND (p_dst_segment2 is NULL)))
         AND ((rec_info.dst_segment3 = p_dst_segment3)
            OR ((rec_info.dst_segment3 IS NULL) AND (p_dst_segment3 is NULL)))
         AND ((rec_info.dst_segment4 = p_dst_segment4)
            OR ((rec_info.dst_segment4 IS NULL) AND (p_dst_segment4 is NULL)))
         AND ((rec_info.dst_segment5 = p_dst_segment5)
            OR ((rec_info.dst_segment5 IS NULL) AND (p_dst_segment5 is NULL)))
         AND ((rec_info.dst_segment6 = p_dst_segment6)
            OR ((rec_info.dst_segment6 IS NULL) AND (p_dst_segment6 is NULL)))
         AND ((rec_info.dst_segment7 = p_dst_segment7)
            OR ((rec_info.dst_segment7 IS NULL) AND (p_dst_segment7 is NULL)))
         AND ((rec_info.dst_segment8 = p_dst_segment8)
            OR ((rec_info.dst_segment8 IS NULL) AND (p_dst_segment8 is NULL)))
         AND ((rec_info.dst_segment9 = p_dst_segment9)
            OR ((rec_info.dst_segment9 IS NULL) AND (p_dst_segment9 is NULL)))
         AND ((rec_info.dst_segment10 = p_dst_segment10)
            OR ((rec_info.dst_segment10 IS NULL) AND (p_dst_segment10 is NULL)))
         AND ((rec_info.dst_segment11 = p_dst_segment11)
            OR ((rec_info.dst_segment11 IS NULL) AND (p_dst_segment11 is NULL)))
         AND ((rec_info.dst_segment12 = p_dst_segment12)
            OR ((rec_info.dst_segment12 IS NULL) AND (p_dst_segment12 is NULL)))
         AND ((rec_info.dst_segment13 = p_dst_segment13)
            OR ((rec_info.dst_segment13 IS NULL) AND (p_dst_segment13 is NULL)))
         AND ((rec_info.dst_segment14 = p_dst_segment14)
            OR ((rec_info.dst_segment14 IS NULL) AND (p_dst_segment14 is NULL)))
         AND ((rec_info.dst_segment15 = p_dst_segment15)
            OR ((rec_info.dst_segment15 IS NULL) AND (p_dst_segment15 is NULL)))
         AND ((rec_info.dst_segment16 = p_dst_segment16)
            OR ((rec_info.dst_segment16 IS NULL) AND (p_dst_segment16 is NULL)))
         AND ((rec_info.dst_segment17 = p_dst_segment17)
            OR ((rec_info.dst_segment17 IS NULL) AND (p_dst_segment17 is NULL)))
         AND ((rec_info.dst_segment18 = p_dst_segment18)
            OR ((rec_info.dst_segment18 IS NULL) AND (p_dst_segment18 is NULL)))
         AND ((rec_info.dst_segment19 = p_dst_segment19)
            OR ((rec_info.dst_segment19 IS NULL) AND (p_dst_segment19 is NULL)))
         AND ((rec_info.dst_segment20 = p_dst_segment20)
            OR ((rec_info.dst_segment20 IS NULL) AND (p_dst_segment20 is NULL)))
         AND ((rec_info.dst_segment21 = p_dst_segment21)
            OR ((rec_info.dst_segment21 IS NULL) AND (p_dst_segment21 is NULL)))
         AND ((rec_info.dst_segment22 = p_dst_segment22)
            OR ((rec_info.dst_segment22 IS NULL) AND (p_dst_segment22 is NULL)))
         AND ((rec_info.dst_segment23 = p_dst_segment23)
            OR ((rec_info.dst_segment23 IS NULL) AND (p_dst_segment23 is NULL)))
         AND ((rec_info.dst_segment24 = p_dst_segment24)
            OR ((rec_info.dst_segment24 IS NULL) AND (p_dst_segment24 is NULL)))
         AND ((rec_info.dst_segment25 = p_dst_segment25)
            OR ((rec_info.dst_segment25 IS NULL) AND (p_dst_segment25 is NULL)))
         AND ((rec_info.dst_segment26 = p_dst_segment26)
            OR ((rec_info.dst_segment26 IS NULL) AND (p_dst_segment26 is NULL)))
         AND ((rec_info.dst_segment27 = p_dst_segment27)
            OR ((rec_info.dst_segment27 IS NULL) AND (p_dst_segment27 is NULL)))
         AND ((rec_info.dst_segment28 = p_dst_segment28)
            OR ((rec_info.dst_segment28 IS NULL) AND (p_dst_segment28 is NULL)))
         AND ((rec_info.dst_segment29 = p_dst_segment29)
            OR ((rec_info.dst_segment29 IS NULL) AND (p_dst_segment29 is NULL)))
         AND ((rec_info.dst_segment30 = p_dst_segment30)
            OR ((rec_info.dst_segment30 IS NULL) AND (p_dst_segment30 is NULL)))
         AND ((rec_info.requisition_line_id = p_requisition_line_id)
            OR ((rec_info.requisition_line_id IS NULL)
               AND (p_requisition_line_id is NULL)))
         AND ((rec_info.currency_code = p_currency_code)
            OR ((rec_info.currency_code IS NULL) AND (p_currency_code is NULL)))
         AND ((rec_info.currency_conversion_date = p_currency_conversion_date)
            OR ((rec_info.currency_conversion_date IS NULL)
               AND (p_currency_conversion_date is NULL)))
         AND ((rec_info.currency_conversion_type = p_currency_conversion_type)
            OR ((rec_info.currency_conversion_type IS NULL)
               AND (p_currency_conversion_type is NULL)))
         AND ((rec_info.currency_conversion_rate = p_currency_conversion_rate)
            OR ((rec_info.currency_conversion_rate IS NULL)
               AND (p_currency_conversion_rate is NULL)))
         AND ((rec_info.ussgl_transaction_code = p_ussgl_transaction_code)
            OR ((rec_info.ussgl_transaction_code IS NULL)
               AND (p_ussgl_transaction_code is NULL)))
         AND ((rec_info.wip_entity_type = p_wip_entity_type)
            OR ((rec_info.wip_entity_type IS NULL)
               AND (p_wip_entity_type is NULL)))
         AND ((rec_info.schedule_id = p_schedule_id)
            OR ((rec_info.schedule_id IS NULL) AND (p_schedule_id is NULL)))
         AND ((rec_info.employee_code = p_employee_code)
            OR ((rec_info.employee_code IS NULL) AND (p_employee_code is NULL)))
         AND ((rec_info.department_id = p_department_id)
            OR ((rec_info.department_id IS NULL) AND (p_department_id is NULL)))
         AND ((rec_info.schedule_update_code = p_schedule_update_code)
            OR ((rec_info.schedule_update_code IS NULL)
               AND (p_schedule_update_code is NULL)))
         AND ((rec_info.setup_teardown_code = p_setup_teardown_code)
            OR ((rec_info.setup_teardown_code IS NULL)
               AND (p_setup_teardown_code is NULL)))
         AND ((rec_info.primary_switch = p_primary_switch)
            OR ((rec_info.primary_switch IS NULL)
               AND (p_primary_switch is NULL)))
         AND ((rec_info.mrp_code = p_mrp_code)
            OR ((rec_info.mrp_code IS NULL) AND (p_mrp_code is NULL)))
         AND ((rec_info.operation_seq_num = p_operation_seq_num)
            OR ((rec_info.operation_seq_num IS NULL)
               AND (p_operation_seq_num is NULL)))
         AND ((rec_info.repetitive_line_id = p_repetitive_line_id)
            OR ((rec_info.repetitive_line_id IS NULL)
               AND (p_repetitive_line_id is NULL)))
         AND ((rec_info.picking_line_id = p_picking_line_id)
            OR ((rec_info.picking_line_id IS NULL)
               AND (p_picking_line_id is NULL)))
         AND ((rec_info.trx_source_line_id = p_trx_source_line_id)
            OR ((rec_info.trx_source_line_id IS NULL)
               AND (p_trx_source_line_id is NULL)))
         AND ((rec_info.trx_source_delivery_id = p_trx_source_delivery_id)
            OR ((rec_info.trx_source_delivery_id IS NULL)
               AND (p_trx_source_delivery_id is NULL)))
         AND ((rec_info.demand_id = p_demand_id)
            OR ((rec_info.demand_id IS NULL) AND (p_demand_id is NULL)))
         AND ((rec_info.customer_ship_id = p_customer_ship_id)
            OR ((rec_info.customer_ship_id IS NULL)
               AND (p_customer_ship_id is NULL)))
         AND ((rec_info.line_item_num = p_line_item_num)
            OR ((rec_info.line_item_num IS NULL) AND (p_line_item_num is NULL)))
         AND ((rec_info.receiving_document = p_receiving_document)
            OR ((rec_info.receiving_document IS NULL)
               AND (p_receiving_document is NULL)))
         AND ((rec_info.rcv_transaction_id = p_rcv_transaction_id)
            OR ((rec_info.rcv_transaction_id IS NULL)
               AND (p_rcv_transaction_id is NULL)))
         AND ((rec_info.ship_to_location_id = p_ship_to_location_id)
            OR ((rec_info.ship_to_location_id IS NULL)
               AND (p_ship_to_location_id is NULL)))
         AND ((rec_info.encumbrance_account = p_encumbrance_account)
            OR ((rec_info.encumbrance_account IS NULL)
               AND (p_encumbrance_account is NULL)))
         AND ((rec_info.encumbrance_amount = p_encumbrance_amount)
            OR ((rec_info.encumbrance_amount IS NULL)
               AND (p_encumbrance_amount is NULL)))
         AND ((rec_info.vendor_lot_number = p_vendor_lot_number)
            OR ((rec_info.vendor_lot_number IS NULL)
               AND (p_vendor_lot_number is NULL)))
         AND ((rec_info.transfer_subinventory = p_transfer_subinventory)
            OR ((rec_info.transfer_subinventory IS NULL)
               AND (p_transfer_subinventory is NULL)))
         AND ((rec_info.transfer_organization = p_transfer_organization)
            OR ((rec_info.transfer_organization IS NULL)
               AND (p_transfer_organization is NULL)))
         AND ((rec_info.transfer_locator = p_transfer_locator)
            OR ((rec_info.transfer_locator IS NULL) AND (p_transfer_locator is NULL)))
         AND ((rec_info.xfer_loc_segment1 = p_xfer_loc_segment1)
            OR ((rec_info.xfer_loc_segment1 IS NULL)
               AND (p_xfer_loc_segment1 is NULL)))
         AND ((rec_info.xfer_loc_segment2 = p_xfer_loc_segment2)
            OR ((rec_info.xfer_loc_segment2 IS NULL)
               AND (p_xfer_loc_segment2 is NULL)))
         AND ((rec_info.xfer_loc_segment3 = p_xfer_loc_segment3)
            OR ((rec_info.xfer_loc_segment3 IS NULL)
               AND (p_xfer_loc_segment3 is NULL)))
         AND ((rec_info.xfer_loc_segment4 = p_xfer_loc_segment4)
            OR ((rec_info.xfer_loc_segment4 IS NULL)
               AND (p_xfer_loc_segment4 is NULL)))
         AND ((rec_info.xfer_loc_segment5 = p_xfer_loc_segment5)
            OR ((rec_info.xfer_loc_segment5 IS NULL)
               AND (p_xfer_loc_segment5 is NULL)))
         AND ((rec_info.xfer_loc_segment6 = p_xfer_loc_segment6)
            OR ((rec_info.xfer_loc_segment6 IS NULL)
               AND (p_xfer_loc_segment6 is NULL)))
         AND ((rec_info.xfer_loc_segment7 = p_xfer_loc_segment7)
            OR ((rec_info.xfer_loc_segment7 IS NULL)
               AND (p_xfer_loc_segment7 is NULL)))
         AND ((rec_info.xfer_loc_segment8 = p_xfer_loc_segment8)
            OR ((rec_info.xfer_loc_segment8 IS NULL)
               AND (p_xfer_loc_segment8 is NULL)))
         AND ((rec_info.xfer_loc_segment9 = p_xfer_loc_segment9)
            OR ((rec_info.xfer_loc_segment9 IS NULL)
               AND (p_xfer_loc_segment9 is NULL)))
         AND ((rec_info.xfer_loc_segment10 = p_xfer_loc_segment10)
            OR ((rec_info.xfer_loc_segment10 IS NULL)
               AND (p_xfer_loc_segment10 is NULL)))
         AND ((rec_info.xfer_loc_segment11 = p_xfer_loc_segment11)
            OR ((rec_info.xfer_loc_segment11 IS NULL)
               AND (p_xfer_loc_segment11 is NULL)))
         AND ((rec_info.xfer_loc_segment12 = p_xfer_loc_segment12)
            OR ((rec_info.xfer_loc_segment12 IS NULL)
               AND (p_xfer_loc_segment12 is NULL)))
         AND ((rec_info.xfer_loc_segment13 = p_xfer_loc_segment13)
            OR ((rec_info.xfer_loc_segment13 IS NULL)
               AND (p_xfer_loc_segment13 is NULL)))
         AND ((rec_info.xfer_loc_segment14 = p_xfer_loc_segment14)
            OR ((rec_info.xfer_loc_segment14 IS NULL)
               AND (p_xfer_loc_segment14 is NULL)))
         AND ((rec_info.xfer_loc_segment15 = p_xfer_loc_segment15)
            OR ((rec_info.xfer_loc_segment15 IS NULL)
               AND (p_xfer_loc_segment15 is NULL)))
         AND ((rec_info.xfer_loc_segment16 = p_xfer_loc_segment16)
            OR ((rec_info.xfer_loc_segment16 IS NULL)
               AND (p_xfer_loc_segment16 is NULL)))
         AND ((rec_info.xfer_loc_segment17 = p_xfer_loc_segment17)
            OR ((rec_info.xfer_loc_segment17 IS NULL)
               AND (p_xfer_loc_segment17 is NULL)))
         AND ((rec_info.xfer_loc_segment18 = p_xfer_loc_segment18)
            OR ((rec_info.xfer_loc_segment18 IS NULL)
               AND (p_xfer_loc_segment18 is NULL)))
         AND ((rec_info.xfer_loc_segment19 = p_xfer_loc_segment19)
            OR ((rec_info.xfer_loc_segment19 IS NULL)
               AND (p_xfer_loc_segment19 is NULL)))
         AND ((rec_info.xfer_loc_segment20 = p_xfer_loc_segment20)
            OR ((rec_info.xfer_loc_segment20 IS NULL)
               AND (p_xfer_loc_segment20 is NULL)))
         AND ((rec_info.shipment_number = p_shipment_number)
            OR ((rec_info.shipment_number IS NULL)
               AND (p_shipment_number is NULL)))
         AND ((rec_info.transportation_cost = p_transportation_cost)
            OR ((rec_info.transportation_cost IS NULL)
               AND (p_transportation_cost is NULL)))
         AND ((rec_info.transportation_account = p_transportation_account)
            OR ((rec_info.transportation_account IS NULL)
               AND (p_transportation_account is NULL)))
         AND ((rec_info.transfer_cost = p_transfer_cost)
            OR ((rec_info.transfer_cost IS NULL) AND (p_transfer_cost is NULL)))
         AND ((rec_info.freight_code = p_freight_code)
            OR ((rec_info.freight_code IS NULL) AND (p_freight_code is NULL)))
         AND ((rec_info.containers = p_containers)
            OR ((rec_info.containers IS NULL) AND (p_containers is NULL)))
         AND ((rec_info.waybill_airbill = p_waybill_airbill)
            OR ((rec_info.waybill_airbill IS NULL)
               AND (p_waybill_airbill is NULL)))
         AND ((rec_info.expected_arrival_date = p_expected_arrival_date)
            OR ((rec_info.expected_arrival_date IS NULL)
               AND (p_expected_arrival_date is NULL)))
         AND ((rec_info.new_average_cost = p_new_average_cost)
            OR ((rec_info.new_average_cost IS NULL)
               AND (p_new_average_cost is NULL)))
         AND ((rec_info.value_change = p_value_change)
            OR ((rec_info.value_change IS NULL) AND (p_value_change is NULL)))
         AND ((rec_info.percentage_change = p_percentage_change)
            OR ((rec_info.percentage_change IS NULL)
               AND (p_percentage_change is NULL)))
         AND ((rec_info.demand_source_header_id = p_demand_source_header_id)
            OR ((rec_info.demand_source_header_id IS NULL)
               AND (p_demand_source_header_id is NULL)))
         AND ((rec_info.demand_source_line = p_demand_source_line)
            OR ((rec_info.demand_source_line IS NULL)
               AND (p_demand_source_line is NULL)))
         AND ((rec_info.demand_source_delivery = p_demand_source_delivery)
            OR ((rec_info.demand_source_delivery IS NULL)
               AND (p_demand_source_delivery is NULL)))
         AND ((rec_info.negative_req_flag = p_negative_req_flag)
            OR ((rec_info.negative_req_flag IS NULL)
               AND (p_negative_req_flag is NULL)))
         AND ((rec_info.error_explanation = p_error_explanation)
            OR ((rec_info.error_explanation IS NULL)
               AND (p_error_explanation is NULL)))
         AND ((rec_info.shippable_flag = p_shippable_flag)
            OR ((rec_info.shippable_flag IS NULL)
               AND (p_shippable_flag is NULL)))
         AND ((rec_info.error_code = p_error_code)
            OR ((rec_info.error_code IS NULL) AND (p_error_code is NULL)))
         AND ((rec_info.required_flag = p_required_flag)
            OR ((rec_info.required_flag IS NULL) AND (p_required_flag is NULL)))
         AND ((rec_info.attribute_category = p_attribute_category)
            OR ((rec_info.attribute_category IS NULL)
               AND (p_attribute_category is NULL)))
         AND ((rec_info.attribute1 = p_attribute1)
            OR ((rec_info.attribute1 IS NULL) AND (p_attribute1 is NULL)))
         AND ((rec_info.attribute2 = p_attribute2)
            OR ((rec_info.attribute2 IS NULL) AND (p_attribute2 is NULL)))
         AND ((rec_info.attribute3 = p_attribute3)
            OR ((rec_info.attribute3 IS NULL) AND (p_attribute3 is NULL)))
         AND ((rec_info.attribute4 = p_attribute4)
            OR ((rec_info.attribute4 IS NULL) AND (p_attribute4 is NULL)))
         AND ((rec_info.attribute5 = p_attribute5)
            OR ((rec_info.attribute5 IS NULL) AND (p_attribute5 is NULL)))
         AND ((rec_info.attribute6 = p_attribute6)
            OR ((rec_info.attribute6 IS NULL) AND (p_attribute6 is NULL)))
         AND ((rec_info.attribute7 = p_attribute7)
            OR ((rec_info.attribute7 IS NULL) AND (p_attribute7 is NULL)))
         AND ((rec_info.attribute8 = p_attribute8)
            OR ((rec_info.attribute8 IS NULL) AND (p_attribute8 is NULL)))
         AND ((rec_info.attribute9 = p_attribute9)
            OR ((rec_info.attribute9 IS NULL) AND (p_attribute9 is NULL)))
         AND ((rec_info.attribute10 = p_attribute10)
            OR ((rec_info.attribute10 IS NULL) AND (p_attribute10 is NULL)))
         AND ((rec_info.attribute11 = p_attribute11)
            OR ((rec_info.attribute11 IS NULL) AND (p_attribute11 is NULL)))
         AND ((rec_info.attribute12 = p_attribute12)
            OR ((rec_info.attribute12 IS NULL) AND (p_attribute12 is NULL)))
         AND ((rec_info.attribute13 = p_attribute13)
            OR ((rec_info.attribute13 IS NULL) AND (p_attribute13 is NULL)))
         AND ((rec_info.attribute14 = p_attribute14)
            OR ((rec_info.attribute14 IS NULL) AND (p_attribute14 is NULL)))
         AND ((rec_info.attribute15 = p_attribute15)
            OR ((rec_info.attribute15 IS NULL) AND (p_attribute15 is NULL)))
         AND ((rec_info.requisition_distribution_id = p_requisition_distribution_id)
            OR ((rec_info.requisition_distribution_id IS NULL)
               AND (p_requisition_distribution_id is NULL)))
         AND ((rec_info.movement_id = p_movement_id)
            OR ((rec_info.movement_id IS NULL) AND (p_movement_id is NULL)))
         AND ((rec_info.reservation_quantity = p_reservation_quantity)
            OR ((rec_info.reservation_quantity IS NULL)
               AND (p_reservation_quantity is NULL)))
         AND ((rec_info.shipped_quantity = p_shipped_quantity)
            OR ((rec_info.shipped_quantity IS NULL)
               AND (p_shipped_quantity is NULL)))
         AND ((rec_info.inventory_item = p_inventory_item)
            OR ((rec_info.inventory_item IS NULL)
               AND (p_inventory_item is NULL)))
         AND ((rec_info.locator_name = p_locator_name)
            OR ((rec_info.locator_name IS NULL) AND (p_locator_name is NULL)))
         AND ((rec_info.task_id = p_task_id)
            OR ((rec_info.task_id IS NULL) AND (p_task_id is NULL)))
         AND ((rec_info.to_task_id = p_to_task_id)
            OR ((rec_info.to_task_id IS NULL) AND (p_to_task_id is NULL)))
         AND ((rec_info.source_task_id = p_source_task_id)
            OR ((rec_info.source_task_id IS NULL)
               AND (p_source_task_id is NULL)))
         AND ((rec_info.project_id = p_project_id)
            OR ((rec_info.project_id IS NULL) AND (p_project_id is NULL)))
         AND ((rec_info.to_project_id = p_to_project_id)
            OR ((rec_info.to_project_id IS NULL) AND (p_to_project_id is NULL)))
         AND ((rec_info.source_project_id = p_source_project_id)
            OR ((rec_info.source_project_id IS NULL) AND (p_source_project_id is NULL)))
         AND ((rec_info.pa_expenditure_org_id = p_pa_expenditure_org_id)
            OR ((rec_info.pa_expenditure_org_id IS NULL)
               AND (p_pa_expenditure_org_id is NULL)))
         AND ((rec_info.expenditure_type = p_expenditure_type)
            OR ((rec_info.expenditure_type IS NULL) AND (p_expenditure_type is NULL)))
         AND ((rec_info.final_completion_flag = p_final_completion_flag)
            OR ((rec_info.final_completion_flag IS NULL)
               AND (p_final_completion_flag is NULL)))
         AND ((rec_info.transfer_percentage = p_transfer_percentage)
            OR ((rec_info.transfer_percentage IS NULL)
               AND (p_transfer_percentage is NULL)))
         AND ((rec_info.transaction_sequence_id = p_trx_sequence_id)
            OR ((rec_info.transaction_sequence_id IS NULL)
               AND (p_trx_sequence_id is NULL)))
         AND ((rec_info.material_account = p_material_account)
            OR ((rec_info.material_account IS NULL)
               AND (p_material_account is NULL)))
         AND ((rec_info.material_overhead_account = p_material_overhead_account)
            OR ((rec_info.material_overhead_account IS NULL)
               AND (p_material_overhead_account is NULL)))
         AND ((rec_info.resource_account = p_resource_account)
            OR ((rec_info.resource_account IS NULL)
               AND (p_resource_account is NULL)))
         AND ((rec_info.outside_processing_account = p_outside_processing_account)
            OR ((rec_info.outside_processing_account IS NULL)
               AND (p_outside_processing_account is NULL)))
         AND ((rec_info.overhead_account = p_overhead_account)
            OR ((rec_info.overhead_account IS NULL)
               AND (p_overhead_account is NULL)))
         AND ((rec_info.bom_revision = p_bom_revision)
            OR ((rec_info.bom_revision IS NULL) AND (p_bom_revision is NULL)))
         AND ((rec_info.routing_revision = p_routing_revision)
            OR ((rec_info.routing_revision IS NULL)
               AND (p_routing_revision is NULL)))
         AND ((rec_info.bom_revision_date = p_bom_revision_date)
            OR ((rec_info.bom_revision_date IS NULL)
               AND (p_bom_revision_date is NULL)))
         AND ((rec_info.routing_revision_date = p_routing_revision_date)
            OR ((rec_info.routing_revision_date IS NULL)
               AND (p_routing_revision_date is NULL)))
         AND ((rec_info.alternate_bom_designator = p_alternate_bom_designator)
            OR ((rec_info.alternate_bom_designator IS NULL)
               AND (p_alternate_bom_designator is NULL)))
         AND ((rec_info.alternate_routing_designator = p_alternate_routing_designator)
            OR ((rec_info.alternate_routing_designator IS NULL)
               AND (p_alternate_routing_designator is NULL)))
         AND ((rec_info.accounting_class = p_accounting_class)
            OR ((rec_info.accounting_class IS NULL)
               AND (p_accounting_class is NULL)))
         AND ((rec_info.demand_class = p_demand_class)
            OR ((rec_info.demand_class IS NULL) AND (p_demand_class is NULL)))
         AND ((rec_info.parent_id = p_parent_id)
            OR ((rec_info.parent_id IS NULL) AND (p_parent_id is NULL)))
         AND ((rec_info.substitution_type_id = p_substitution_type_id)
            OR ((rec_info.substitution_type_id IS NULL)
               AND (p_substitution_type_id is NULL)))
         AND ((rec_info.substitution_item_id = p_substitution_item_id)
            OR ((rec_info.substitution_item_id IS NULL)
               AND (p_substitution_item_id is NULL)))
         AND ((rec_info.schedule_group = p_schedule_group)
            OR ((rec_info.schedule_group IS NULL)
               AND (p_schedule_group is NULL)))
         AND ((rec_info.build_sequence = p_build_sequence)
            OR ((rec_info.build_sequence IS NULL)
               AND (p_build_sequence is NULL)))
         AND ((rec_info.schedule_number = p_schedule_number)
            OR ((rec_info.schedule_number IS NULL)
               AND (p_schedule_number is NULL)))
         AND ((rec_info.scheduled_flag = p_scheduled_flag)
            OR ((rec_info.scheduled_flag IS NULL)
               AND (p_scheduled_flag is NULL)))
         AND ((rec_info.flow_schedule = p_flow_schedule)
            OR ((rec_info.flow_schedule IS NULL) AND (p_flow_schedule is NULL)))
         AND ((rec_info.cost_group_id = p_cost_group_id)
            OR ((rec_info.cost_group_id IS NULL) AND (p_cost_group_id IS NULL)))

-- HW OPMCONV. Added secondary_qty and secondary_uom
         AND ((rec_info.SECONDARY_UOM_CODE = p_secondary_uom_code)
            OR ((rec_info.SECONDARY_UOM_CODE IS NULL) AND (p_secondary_uom_code IS NULL)))
         AND ((rec_info.SECONDARY_TRANSACTION_QUANTITY  = p_secondary_trx_quantity)
            OR ((rec_info.SECONDARY_TRANSACTION_QUANTITY IS NULL) AND (p_secondary_trx_quantity IS NULL)))
      ) THEN
/*         wsh_server_debug.log_event('WSH_TRX_HANDLER.LOCK_ROW',
            'END',
            'End of procedure LOCK_ROW');
*/
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name,'Nothing Changed');
         END IF;
         --
         return;
      ELSE
/*         wsh_server_debug.log_event('WSH_TRX_HANDLER.LOCK_ROW',
            'END',
            'Lock record failed.  Raising exception FORM_RECORD_CHANGED');
*/
         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name,'FORM_RECORD_CHANGED');
         END IF;
         app_exception.raise_exception;
      END IF;

      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
   END Lock_Row;

END WSH_TRX_HANDLER;

/
