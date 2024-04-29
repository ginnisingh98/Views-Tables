--------------------------------------------------------
--  DDL for Package EAM_COMPLETION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_COMPLETION" AUTHID CURRENT_USER AS
/* $Header: EAMWCMPS.pls 120.1 2005/12/05 14:46:58 baroy noship $*/
/*#
 * This is the public API for maintenance work order completion/uncompletion
 * @rep:scope public
 * @rep:product EAM
 * @rep:displayname Maintenance Work Completion
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY EAM_COMPLETE_WO_OPERATION
 */
 -- Version  Initial version    1.0     Kaweesak Boonyapornnad

INVENTORY_ITEM_NULL EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type;

TYPE Lot_Serial_Rec_Type is RECORD
(
 lot_number           VARCHAR2(80),
 serial_number          VARCHAR2(30),
 quantity  NUMBER
);

TYPE Lot_Serial_Tbl_Type is TABLE OF Lot_Serial_Rec_Type INDEX BY BINARY_INTEGER;

/***************************************************************************
 *
 * This package will be used to complete and uncomplete EAM work order
 *
 * PARAMETER:
 *
 * x_wip_entity_id        Work Order ID
 * x_rebuild_jobs         A flag used to determine work order type
 *                        (N:Regular EAM work order/ Y:Rebuild work order)
 * x_transaction_type     The type of transaction (Complete(1) / Uncomplete(2))
 * x_transaction_date     The date of transaction
 * x_user_id              User ID
 * x_request_id,          For concurrent processing
 * x_appplication_id,     For concurrent processing
 * x_program_id           For concurrent processing
 * x_reconcil_code        This parameter was predefined in FND_LOOKUP_VALUES
 *                        where lookup_type = 'WIP_EAM_RECONCILIATION_CODE'
 * x_subinventory         For rebuild work order with material issue only
 * x_locator_id           For rebuild work order with material issue only
 * x_lot_number           For rebuild work order with material issue only
 * x_serial_number        For rebuild work order with material issue only
 * x_reference            For regular EAM work order only
 * x_qa_collection_id     For regular EAM work order only
 *                        (null if the the work order is not under QA control)
 * x_shutdown_start_date  Shutdown information for regular EAM
 * x_shutdown_end_date    Shutdown information for regular EAM
 * x_quantity             Number of items for inventory
 * x_update_meter         default to fnd_api.g_true
 *                        whether to update meters
 * x_commit               default to fnd_api.g_true
 *                        whether to commit the changes to DB
 * x_attribute_category   For descriptive flex field
 * x_attribute1-15        For descriptive flex field
 * errCode  OUT           0 if procedure success, 1 otherwise
 * errMsg   OUT NOCOPY           The informative error message
 *
 *
 * This procedure will insert all the required information to
 * EAM_JOB_COMPLETION_TXNS table for tracking purpose (history), and updated
 * some information in  WIP_DISCRETE_JOBS table(status_type, last_update_date,
 * last_updated_by).
 *
 * Complete transaction:
 *
 * We can complete all the jobs, but the one that has status
 * 'Pending Routing Load'(10), 'Failed Routing Load'(11), 'Complete'(4),
 * 'Pending Bill Load'(8), and 'Failed Bill Load'(9). At the end of procudure,
 * we just change the STATUS_TYPE in WIP_DISCRETE_JOBS to be 'Complete'(4).
 *
 * <Regular EAM Work Order>
 *
 * We need to check whether the child job(rebuild job) already closed or not.
 * We cannot complete regular EAM work order if the coresponding
 * rebuild work order did not complete and there is no material issue. On the
 * other hand, if the corresponding rebuild work order is a manual job with
 * material issue, we can complete the corresponding parent job without
 * completing all the child jobs. Call eam_pm_utils.update_pm_when_complete
 * (p_org_id,p_wip_entity_id, p_completion_date) to update meter.
 * p_completion_date is equal to x_actual_end_date. If x_qa_colletion_id is
 * not null, call QA_RESULT_GRP.ENABLE to process QA data. If
 * x_shutdown_start_date and x_shutdown_end_date are not null, insert shutdown
 * history to EAM_ASSET_STATUS_HISTORY.
 *
 * <Rebuild Work Order>
 *
 * If there is material issue , this procedure will return the completed
 * rebuildable item to inventory (updating the information in
 * MTL_MATERIAL_TRANSACTIONS_TEMP, MTL_SERIAL_NUMBERS_TEMP, and
 * MTL_TRANSACTION_LOTS_TEMP table  by using the completion location
 * information provided by the user(Subinventory, Locator, Lot Number,
 * Serial Number)and call inventory processor to process assembly completion).
 *
 * Uncomplete transaction:
 *
 * We can uncomplete only the jobs that has status 'Complete'(4). At the end
 * of this procudure, we just change the STATUS_TYPE in WIP_DISCRETE_JOBS to
 * be 'Released(3)'.
 *
 * <Regular EAM Work Order>
 *
 * We don't have to check much for Regular EAM Work Order, but we need to call
 * eam_pm_utils.update_pm_when_uncomplete (p_org_id,p_wip_entity_id,
 * p_completion_date) to update meter. p_completion_date is equal to
 * x_actual_end_date. If x_qa_colletion_id is not null, call
 * QA_RESULT_GRP.ENABLE to process QA data. If x_shutdown_start_date and
 * x_shutdown_end_date are not null, insert shutdown history to
 * EAM_ASSET_STATUS_HISTORY.
 *
 * <Rebuild Work Order>
 *
 * If there is material issue, we need to deal with Inventory Assembly Return
 * to get the item back from Inventory. If there is no material issue, we need
 * to check whether the corresponding parent job(regular EAM) already completed
 * or not. If the parent job already complete, return informative error. We
 * cannot use recursive to uncomplete the parent jobs.
 *
 * Required Arguments: (For both Completion and Uncomplete)
 *
 * x_wip_entity_id
 * x_rebuild_jobs
 * x_transaction_type
 * x_transaction_date
 * x_actual_start_date
 * x_actual_end_date
 * x_actual_duration
 *
 * Arguments: (For regular EAM work order only)
 * x_reference
 * x_qa_collection_id
 * x_shutdown_start_date
 * x_shutdown_end_date
 *
 * Arguments: (For rebuild work order with material issue only)
 * x_subinventory
 * x_locator_id
 * x_lot_number
 * x_serial_number
 *
 * Arguments: (For concurrent processing)
 * x_request_id
 * x_application_id
 * x_program_id
 *
 ***************************************************************************/
/*#
 * Complete/UnComplete maintenance work order.
 * The maintenance work order can be a regular work order or a rebuild work order.
 * While completing the regular work order user can provide the Asset Shutdown history information.
 * While completing the rebuild work order with material issue ,user can specify return location by specifying subinventory/locator/lot/serial information.
 * This API can not be use to enter the collection plan results and meter readings while completing the work order.
 * @param x_wip_entity_id Work order identifier
 * @param x_rebuild_jobs Type of Work order 'N'(Normal) / 'Y' (Rebuild)
 * @param x_transaction_type Type of transaction '1'(complete) / '2' (uncomplete)
 * @param x_transaction_date Date of the complete or uncomplete transaction
 * @param x_user_id User Id
 * @param x_request_id Standard Who Column used for concurrent process
 * @param x_application_id Standard Who Column used for concurrent process
 * @param x_program_id Standard Who Column used for concurrent process
 * @param x_reconcil_code Reconciliation code used to store the result of a performed maintenance task
 * @param x_actual_start_date Actual start date of work order
 * @param x_actual_end_date Actual end date of work order
 * @param x_actual_duration Duration of work order
 * @param x_inventory_item_info A table of EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type Required for rebuild work order with material issue (Contains subinventory,locator,lot,serial information)
 * @param x_reference Reference Required for regular EAM work order only
 * @param x_qa_collection_id Quality Collection Plan Identifier Required for regular EAM work order only
 * @param x_shutdown_start_date Shutdown start date Required for regular EAM work order only
 * @param x_shutdown_end_date Shutdown end date Required for regular EAM work order only
 * @param x_commit Parameter to indicate whether to commit the changes to Database  'T'(true) / 'F'(false)
 * @param x_attribute_category Descriptive flexfield structure defining column
 * @param x_attribute1  Descriptive Flexfield Segment
 * @param x_attribute2  Descriptive Flexfield Segment
 * @param x_attribute3  Descriptive Flexfield Segment
 * @param x_attribute4  Descriptive Flexfield Segment
 * @param x_attribute5  Descriptive Flexfield Segment
 * @param x_attribute6  Descriptive Flexfield Segment
 * @param x_attribute7  Descriptive Flexfield Segment
 * @param x_attribute8  Descriptive Flexfield Segment
 * @param x_attribute9  Descriptive Flexfield Segment
 * @param x_attribute10 Descriptive Flexfield Segment
 * @param x_attribute11 Descriptive Flexfield Segment
 * @param x_attribute12 Descriptive Flexfield Segment
 * @param x_attribute13 Descriptive Flexfield Segment
 * @param x_attribute14 Descriptive Flexfield Segment
 * @param x_attribute15 Descriptive Flexfield Segment
 * @param errCode 0 if procedure success, 1 otherwise
 * @param errMsg The informative error message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Maintenance Work Completion
 */

PROCEDURE complete_work_order_generic(
          x_wip_entity_id       IN NUMBER,
	  x_rebuild_jobs        IN VARCHAR2,
          x_transaction_type    IN NUMBER,
          x_transaction_date    IN DATE,
          x_user_id             IN NUMBER   := fnd_global.user_id,
	  x_request_id          IN NUMBER   := null,
	  x_application_id      IN NUMBER   := null,
   	  x_program_id          IN NUMBER   := null,
	  x_reconcil_code       IN VARCHAR2 := null,
          x_actual_start_date   IN DATE,
          x_actual_end_date     IN DATE,
          x_actual_duration     IN NUMBER,
	  x_inventory_item_info IN EAM_WorkOrderTransactions_PUB.Inventory_Item_Tbl_Type := INVENTORY_ITEM_NULL,
          x_reference           IN VARCHAR2 := null,
          x_qa_collection_id    IN NUMBER   := null,
          x_shutdown_start_date IN DATE     := null,
          x_shutdown_end_date   IN DATE     := null,
          x_commit              IN VARCHAR2 := fnd_api.g_false,
          x_attribute_category  IN VARCHAR2 := null,
          x_attribute1          IN VARCHAR2 := null,
          x_attribute2          IN VARCHAR2 := null,
          x_attribute3          IN VARCHAR2 := null,
          x_attribute4          IN VARCHAR2 := null,
          x_attribute5          IN VARCHAR2 := null,
          x_attribute6          IN VARCHAR2 := null,
          x_attribute7          IN VARCHAR2 := null,
          x_attribute8          IN VARCHAR2 := null,
          x_attribute9          IN VARCHAR2 := null,
          x_attribute10         IN VARCHAR2 := null,
          x_attribute11         IN VARCHAR2 := null,
          x_attribute12         IN VARCHAR2 := null,
          x_attribute13         IN VARCHAR2 := null,
          x_attribute14         IN VARCHAR2 := null,
          x_attribute15         IN VARCHAR2 := null,
          errCode              OUT NOCOPY NUMBER,
          errMsg               OUT NOCOPY VARCHAR2) ;
        --  x_statement          OUT NUMBER ;

PROCEDURE complete_work_order(
          x_wip_entity_id       IN NUMBER,
	  x_rebuild_jobs        IN VARCHAR2,
          x_transaction_type    IN NUMBER,
          x_transaction_date    IN DATE,
          x_user_id             IN NUMBER   := fnd_global.user_id,
	  x_request_id          IN NUMBER   := null,
	  x_application_id      IN NUMBER   := null,
   	  x_program_id          IN NUMBER   := null,
	  x_reconcil_code       IN VARCHAR2 := null,
          x_actual_start_date   IN DATE,
          x_actual_end_date     IN DATE,
          x_actual_duration     IN NUMBER,
          x_subinventory        IN VARCHAR2 := null,
          x_locator_id          IN NUMBER   := null,
          x_lot_number          IN VARCHAR2 := null,
          x_serial_number       IN VARCHAR2 := null,
          x_reference           IN VARCHAR2 := null,
          x_qa_collection_id    IN NUMBER   := null,
          x_shutdown_start_date IN DATE     := null,
          x_shutdown_end_date   IN DATE     := null,
          x_commit              IN VARCHAR2 := fnd_api.g_false,
          x_attribute_category  IN VARCHAR2 := null,
          x_attribute1          IN VARCHAR2 := null,
          x_attribute2          IN VARCHAR2 := null,
          x_attribute3          IN VARCHAR2 := null,
          x_attribute4          IN VARCHAR2 := null,
          x_attribute5          IN VARCHAR2 := null,
          x_attribute6          IN VARCHAR2 := null,
          x_attribute7          IN VARCHAR2 := null,
          x_attribute8          IN VARCHAR2 := null,
          x_attribute9          IN VARCHAR2 := null,
          x_attribute10         IN VARCHAR2 := null,
          x_attribute11         IN VARCHAR2 := null,
          x_attribute12         IN VARCHAR2 := null,
          x_attribute13         IN VARCHAR2 := null,
          x_attribute14         IN VARCHAR2 := null,
          x_attribute15         IN VARCHAR2 := null,
          errCode              OUT NOCOPY NUMBER,
          errMsg               OUT NOCOPY VARCHAR2) ;
        --  x_statement          OUT NUMBER ;




-- This method will be called via Forms

PROCEDURE complete_work_order_form(
          x_wip_entity_id       IN NUMBER,
	        x_rebuild_jobs        IN VARCHAR2,
          x_transaction_type    IN NUMBER,
          x_transaction_date    IN DATE,
          x_user_id             IN NUMBER   := fnd_global.user_id,
	        x_request_id          IN NUMBER   := null,
	        x_application_id      IN NUMBER   := null,
   	      x_program_id          IN NUMBER   := null,
	        x_reconcil_code       IN VARCHAR2 := null,
          x_actual_start_date   IN DATE,
          x_actual_end_date     IN DATE,
          x_actual_duration     IN NUMBER,
          x_subinventory        IN VARCHAR2 := null,
          x_locator_id          IN NUMBER   := null,
          x_lot_number          IN VARCHAR2 := null,
          x_serial_number       IN VARCHAR2 := null,
          x_reference           IN VARCHAR2 := null,
          x_qa_collection_id    IN NUMBER   := null,
          x_shutdown_start_date IN DATE     := null,
          x_shutdown_end_date   IN DATE     := null,
          x_attribute_category  IN VARCHAR2 := null,
          x_attribute1          IN VARCHAR2 := null,
          x_attribute2          IN VARCHAR2 := null,
          x_attribute3          IN VARCHAR2 := null,
          x_attribute4          IN VARCHAR2 := null,
          x_attribute5          IN VARCHAR2 := null,
          x_attribute6          IN VARCHAR2 := null,
          x_attribute7          IN VARCHAR2 := null,
          x_attribute8          IN VARCHAR2 := null,
          x_attribute9          IN VARCHAR2 := null,
          x_attribute10         IN VARCHAR2 := null,
          x_attribute11         IN VARCHAR2 := null,
          x_attribute12         IN VARCHAR2 := null,
          x_attribute13         IN VARCHAR2 := null,
          x_attribute14         IN VARCHAR2 := null,
          x_attribute15         IN VARCHAR2 := null,
          errCode              OUT NOCOPY NUMBER,
          errMsg               OUT NOCOPY VARCHAR2 );
        --  x_statement          OUT NUMBER ;

/* Added for bug# 3238163 */
PROCEDURE complete_work_order_commit(
          x_wip_entity_id       IN NUMBER,
	        x_rebuild_jobs        IN VARCHAR2,
          x_transaction_type    IN NUMBER,
          x_transaction_date    IN DATE,
          x_user_id             IN NUMBER   := fnd_global.user_id,
	        x_request_id          IN NUMBER   := null,
	        x_application_id      IN NUMBER   := null,
   	      x_program_id          IN NUMBER   := null,
	        x_reconcil_code       IN VARCHAR2 := null,
          x_commit              IN VARCHAR2 := fnd_api.g_false,
          x_actual_start_date   IN DATE,
          x_actual_end_date     IN DATE,
          x_actual_duration     IN NUMBER,
          x_subinventory        IN VARCHAR2 := null,
          x_locator_id          IN NUMBER   := null,
          x_lot_number          IN VARCHAR2 := null,
          x_serial_number       IN VARCHAR2 := null,
          x_reference           IN VARCHAR2 := null,
          x_qa_collection_id    IN NUMBER   := null,
          x_shutdown_start_date IN DATE     := null,
          x_shutdown_end_date   IN DATE     := null,
          x_attribute_category  IN VARCHAR2 := null,
          x_attribute1          IN VARCHAR2 := null,
          x_attribute2          IN VARCHAR2 := null,
          x_attribute3          IN VARCHAR2 := null,
          x_attribute4          IN VARCHAR2 := null,
          x_attribute5          IN VARCHAR2 := null,
          x_attribute6          IN VARCHAR2 := null,
          x_attribute7          IN VARCHAR2 := null,
          x_attribute8          IN VARCHAR2 := null,
          x_attribute9          IN VARCHAR2 := null,
          x_attribute10         IN VARCHAR2 := null,
          x_attribute11         IN VARCHAR2 := null,
          x_attribute12         IN VARCHAR2 := null,
          x_attribute13         IN VARCHAR2 := null,
          x_attribute14         IN VARCHAR2 := null,
          x_attribute15         IN VARCHAR2 := null,
          errCode              OUT NOCOPY NUMBER,
          errMsg               OUT NOCOPY VARCHAR2 );

PROCEDURE lock_row(
  p_wip_entity_id         IN NUMBER,
  p_organization_id       IN NUMBER,
  p_rebuild_item_id       IN NUMBER,
  p_parent_wip_entity_id  IN NUMBER,
  p_asset_number          IN VARCHAR2,
  p_asset_group_id        IN NUMBER,
  p_manual_rebuild_flag   IN VARCHAR2,
  p_asset_activity_id     IN NUMBER,
  p_status_type           IN NUMBER,
  x_return_status        OUT NOCOPY NUMBER,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2);

END eam_completion;

 

/
