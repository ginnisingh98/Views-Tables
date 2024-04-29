--------------------------------------------------------
--  DDL for Package EAM_WORKORDERTRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WORKORDERTRANSACTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPWOTS.pls 120.1.12010000.2 2008/11/06 23:51:58 mashah ship $ */

     -- Version  Initial version    1.0    Alice Yang

G_PKG_NAME		CONSTANT VARCHAR2(50) := 'EAM_WorkOrderTransactions_PUB';

-- Transaction Type Constants
G_TXN_TYPE_COMPLETE 	CONSTANT NUMBER := 1;
G_TXN_TYPE_UNCOMPLETE	CONSTANT NUMBER := 2;

-- For rebuild work order with material issue only
TYPE Inventory_Item_Rec_Type is RECORD
(
	subinventory		VARCHAR2(30),
	locator			VARCHAR2(30),
	lot_number		VARCHAR2(80),
	serial_number		VARCHAR2(30),
	quantity		NUMBER
);

TYPE Inventory_Item_Tbl_Type is TABLE OF Inventory_Item_Rec_Type
	INDEX BY BINARY_INTEGER;

TYPE Attributes_Rec_Type is RECORD
(
          p_attribute_category   VARCHAR2(30)  := null,
          p_attribute1           VARCHAR2(150) := null,
          p_attribute2           VARCHAR2(150) := null,
          p_attribute3           VARCHAR2(150) := null,
          p_attribute4           VARCHAR2(150) := null,
          p_attribute5           VARCHAR2(150) := null,
          p_attribute6           VARCHAR2(150) := null,
          p_attribute7           VARCHAR2(150) := null,
          p_attribute8           VARCHAR2(150) := null,
          p_attribute9           VARCHAR2(150) := null,
          p_attribute10          VARCHAR2(150) := null,
          p_attribute11          VARCHAR2(150) := null,
          p_attribute12          VARCHAR2(150) := null,
          p_attribute13          VARCHAR2(150) := null,
          p_attribute14          VARCHAR2(150) := null,
          p_attribute15          VARCHAR2(150) := null
);

/***************************************************************************
 *
 * This package will be used to complete and uncomplete EAM work order and operations
 *
 * PARAMETERS:
 *
 * STANDARD API PARAMS:
 * p_api_version          version number of incoming call
 * p_commit               whether to commit the changes to DB
 *                        can be FND_API.G_TRUE or FND_API.G_FALSE
 * x_return_status        result of calling this API
 *                        can be FND_API.G_RET_STS_SUCCESS, G_RET_STS_ERROR, or G_RET_STS_UNEXP_ERROR
 * x_msg_count            message count
 * x_msg_data             message data
 *
 * CUSTOM PARAMS:
 * p_wip_entity_id        Work Order ID
 * p_transaction_type     The type of transaction (Complete(1) / Uncomplete(2))
 * p_transaction_date     The date of transaction
 * p_transaction_quantity Number of items for inventory (Install Base Instance ID unit quantity)
 * p_instance_id          Install Base Instance ID for this Work Order (for retreiving serial info)
 * p_user_id              User ID
 * p_request_id,          For concurrent processing
 * p_application_id,      For concurrent processing
 * p_program_id           For concurrent processing
 * p_reconciliation_code  This parameter was predefined in FND_LOOKUP_VALUES
 *                        where lookup_type = 'WIP_EAM_RECONCILIATION_CODE'
 * p_actual_start_date    Actual Start Date of Work Order
 * p_actual_end_date      Actual End Date of Work Order
 * p_actual_duration      Actual Duration of Work Order
 * p_subinventory         For rebuild work order with material issue only
 * p_locator              For rebuild work order with material issue only
 * p_lot_serial           Lot Serial information for rebuild work order only
 * p_reference            For regular EAM work order only
 * p_reason               For regular EAM work order only
 * p_shutdown_start_date  Asset Shutdown information for regular EAM
 * p_shutdown_end_date    Asset Shutdown information for regular EAM
 * p_shutdown_duration    Asset Shutdown information for regular EAM
 * p_meter_reading_tbl    For entering meter readings for this work order
 * p_attibuites_rec       For descriptive flex field
 *
 * Required Arguments:
 *
 * p_api_version
 *
 * p_wip_entity_id
 * p_rebuild_jobs
 * p_transaction_type
 * p_transaction_date
 * p_meter_readings_tbl
 * p_attributes
 *
 ***************************************************************************/

PROCEDURE Complete_Work_Order(
          p_api_version          IN NUMBER,
          p_init_msg_list        IN VARCHAR2 := fnd_api.g_false,
          p_commit               IN VARCHAR2 := fnd_api.g_false,
          x_return_status        OUT NOCOPY VARCHAR2,
          x_msg_count            OUT NOCOPY NUMBER,
          x_msg_data             OUT NOCOPY VARCHAR2,
          p_wip_entity_id        IN NUMBER,
          p_transaction_type     IN NUMBER,
          p_transaction_date     IN DATE,
          p_instance_id          IN NUMBER   := null,
          p_user_id              IN NUMBER   := fnd_global.user_id,
          p_request_id           IN NUMBER   := null,
          p_application_id       IN NUMBER   := null,
          p_program_id           IN NUMBER   := null,
          p_reconciliation_code  IN VARCHAR2 := null,
          p_actual_start_date    IN DATE     := null,
          p_actual_end_date      IN DATE     := null,
          p_actual_duration      IN NUMBER   := null,
          p_shutdown_start_date  IN DATE     := null,
          p_shutdown_end_date    IN DATE     := null,
          p_shutdown_duration    IN NUMBER   := null,
          p_inventory_item_info  IN Inventory_Item_Tbl_Type,
          p_reference            IN VARCHAR2 := null,
          p_reason               IN VARCHAR2 := null,
	  p_attributes_rec       IN Attributes_Rec_Type
);

procedure complete_operation(
    p_api_version                  IN    NUMBER  :=1.0,
    p_init_msg_list                IN    VARCHAR2 := FND_API.G_FALSE,
    p_commit                       IN    VARCHAR2 := fnd_api.g_false,
    x_return_status                OUT NOCOPY   VARCHAR2,
    x_msg_count                    OUT NOCOPY   NUMBER,
    x_msg_data                     OUT NOCOPY   VARCHAR2,
    p_wip_entity_id                IN    NUMBER,
    p_operation_seq_num            IN    NUMBER,
    p_transaction_date             IN    DATE := SYSDATE,
    p_transaction_type             IN    NUMBER,
    p_actual_start_date            IN    DATE := null,
    p_actual_end_date              IN    DATE := null,
    p_actual_duration              IN    NUMBER := null,
    p_shutdown_start_date          IN    DATE := null,
    p_shutdown_end_date            IN    DATE := null,
    p_shutdown_duration            IN    NUMBER := null,
    p_reconciliation_code          IN    NUMBER := null,
    p_attribute_rec                IN    Attributes_Rec_Type
);

procedure SET_MANUAL_REB_FLAG(p_wip_entity_id        IN  NUMBER,
                              p_organization_id      IN  NUMBER,
                              p_manual_rebuild_flag  IN  VARCHAR2,
                              x_return_status        OUT NOCOPY VARCHAR2);

procedure SET_OWNING_DEPARTMENT(p_wip_entity_id      IN  NUMBER,
                                p_organization_id    IN  NUMBER,
                                p_owning_department  IN  NUMBER,
                                x_return_status      OUT NOCOPY VARCHAR2);

/*********************************************************************
  * Procedure     : Update_EWOD
  * Parameters IN : group_id
  *                 organization_id
  *                 user_defined_status_id
  * Parameters OUT NOCOPY:
  *   errbuf         error messages
  *   retcode        return status. 0 for success, 1 for warning and 2 for error.
  * Purpose       : Procedure will update the EWOD table in database with the user_defined_status_id passed.
  *                 This procedure was added for a WIP bug 6718091
***********************************************************************/

PROCEDURE Update_EWOD
        ( p_group_id            IN  NUMBER,
          p_organization_id     IN  NUMBER,
	  p_new_status          IN  NUMBER,
          ERRBUF               OUT NOCOPY VARCHAR2,
          RETCODE              OUT NOCOPY VARCHAR2
         );


/*********************************************************************
  * Procedure     : RAISE_WORKFLOW_STATUS_PEND_CLS
  * Parameters IN : group_id
  *                 user_defined_status_id
  * Parameters OUT NOCOPY:
  *   errbuf         error messages
  *   retcode        return status. 0 for success, 1 for warning and 2 for error.
  * Purpose       : Procedure will update workflow status to pending close for all wip_entity_ids provided in the group_id.
  *                 This procedure was added for a WIP bug 6718091
***********************************************************************/
PROCEDURE RAISE_WORKFLOW_STATUS_PEND_CLS
(  p_group_id            IN  NUMBER,
   p_new_status          IN  NUMBER,
   ERRBUF               OUT NOCOPY VARCHAR2 ,
   RETCODE              OUT NOCOPY VARCHAR2
  );


END EAM_WorkOrderTransactions_PUB;


/
