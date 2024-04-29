--------------------------------------------------------
--  DDL for Package WMS_WORKFLOW_WRAPPERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_WORKFLOW_WRAPPERS" AUTHID CURRENT_USER AS
/* $Header: WMSWFWRS.pls 120.1 2008/01/11 14:22:00 rkatoori ship $ */

-- This procedure is the wrapper that calls the Start_workflow procedure
-- Example is set for p_reason_name = 'INSUFFICIENT QUANTITY'
PROCEDURE wms_insuff_qty_wrapper( p_api_version_number               IN  NUMBER
				   , x_return_status                 OUT NOCOPY VARCHAR2
				   , x_msg_count                     OUT NOCOPY NUMBER
				   , x_msg_data                      OUT NOCOPY VARCHAR2
				   , p_tsk_id                        IN  NUMBER   -- task id
				   , p_user_id                       IN  VARCHAR2
				   , p_organization_id               IN  NUMBER
				   , p_rsn_id                        IN  NUMBER -- reason id
				   , p_quantity_picked	             IN  NUMBER
				   );


PROCEDURE wf_wrapper(p_api_version                     IN  NUMBER
		     , p_init_msg_list                 IN  VARCHAR2 := fnd_api.g_false
		     , p_commit	                       IN  VARCHAR2 := fnd_api.g_false
		     , x_return_status                 OUT NOCOPY VARCHAR2
		     , x_msg_count                     OUT NOCOPY NUMBER
		     , x_msg_data                      OUT NOCOPY VARCHAR2
		     , p_org_id                        IN  NUMBER
		     , p_rsn_id                        IN  NUMBER
		     , p_calling_program               IN  VARCHAR2
		     , p_tmp_id                        IN  NUMBER DEFAULT NULL
		     , p_quantity_picked               IN NUMBER DEFAULT NULL
                     , p_dest_sub                      IN VARCHAR2 DEFAULT NULL
		     , p_dest_loc                      IN NUMBER DEFAULT NULL
		     );

PROCEDURE wf_start_workflow(
P_REASON_ID				IN      NUMBER,
P_CALLING_PROGRAM_NAME			IN	VARCHAR2,
P_SOURCE_ORGANIZATION_ID		IN	NUMBER,
P_REASON_NAME				IN	VARCHAR2 DEFAULT NULL,
P_DESTINATION_ORGANIZATION_ID		IN	NUMBER DEFAULT NULL,
P_SOURCE_SUBINVENTORY			IN	VARCHAR2 DEFAULT NULL,
P_SOURCE_SUBINVENTORY_STATUS		IN	NUMBER DEFAULT NULL,
P_DESTINATION_SUBINVENTORY		IN	VARCHAR2 DEFAULT NULL,
P_DESTINATION_SUBINVENTORY_ST           IN	NUMBER DEFAULT NULL,
P_SOURCE_LOCATOR			IN	NUMBER DEFAULT NULL,
P_SOURCE_LOCATOR_STATUS			IN	NUMBER DEFAULT NULL,
P_DESTINATION_LOCATOR			IN	NUMBER DEFAULT NULL,
P_DESTINATION_LOCATOR_STATUS		IN      NUMBER DEFAULT NULL,
P_LPN_ID				IN	NUMBER DEFAULT NULL,
P_ONHAND_STATUS                         IN      VARCHAR2 DEFAULT NULL,  -- Added for Onhand material support --6633612
P_LPN_STATUS				IN	NUMBER DEFAULT NULL,
P_CONTENT_LPN_ID	       		IN	NUMBER DEFAULT NULL,
P_CONTENT_LPN_STATUS		       	IN	NUMBER DEFAULT NULL,
p_source_parent_lpn_id  		IN	NUMBER DEFAULT NULL,
P_SOURCE_parent_LPN_STATUS		IN	NUMBER DEFAULT NULL,
P_SOURCE_OUTERMOST_LPN_ID		IN	NUMBER DEFAULT NULL,
P_SOURCE_OUTERMOST_LPN_STATUS		IN	NUMBER DEFAULT NULL,
p_dest_lpn_id     		        IN	NUMBER DEFAULT NULL,
p_dest_lpn_status               	IN	NUMBER DEFAULT NULL,
p_dest_parent_lpn_id     		IN	NUMBER DEFAULT NULL,
p_dest_parent_lpn_status        	IN	NUMBER DEFAULT NULL,
P_DEST_OUTERMOST_LPN_ID  		IN	NUMBER DEFAULT NULL,
P_DEST_OUTERMOST_LPN_STATUS      	IN	NUMBER DEFAULT NULL,
P_INVENTORY_ITEM_ID			IN	NUMBER DEFAULT NULL,
P_REVISION				IN	VARCHAR2 DEFAULT NULL,
P_LOT_NUMBER				IN	VARCHAR2 DEFAULT NULL,
p_to_lot_number                         IN      VARCHAR2 DEFAULT NULL,
P_LOT_STATUS				IN	NUMBER DEFAULT NULL,
P_SERIAL_NUMBER				IN	VARCHAR2 DEFAULT NULL,
p_to_serial_number                      IN      VARCHAR2 DEFAULT NULL,
P_SERIAL_NUMBER_STATUS			IN	NUMBER DEFAULT NULL,
P_PRIMARY_UOM				IN	VARCHAR2 DEFAULT NULL,
P_TRANSACTION_UOM			IN	VARCHAR2 DEFAULT NULL,
P_PRIMARY_QUANTITY			IN	NUMBER DEFAULT NULL,
P_TRANSACTION_QUANTITY			IN	NUMBER DEFAULT NULL,
P_TRANSACTION_ACTION_ID			IN	NUMBER DEFAULT NULL,
P_TRANSACTION_SOURCE_TYPE_ID		IN	NUMBER DEFAULT NULL,
P_TRANSACTION_SOURCE			IN	NUMBER DEFAULT NULL,
P_RESERVATION_ID			IN	NUMBER DEFAULT NULL,
P_EQUIPMENT_ID				IN	NUMBER DEFAULT NULL,
P_USER_ID				IN	NUMBER DEFAULT NULL,
P_TASK_TYPE_ID				IN	NUMBER DEFAULT NULL,
P_TASK_ID				IN	NUMBER DEFAULT NULL,
p_txn_temp_id                           IN      NUMBER DEFAULT NULL,
p_update_status_method                  IN 	VARCHAR2 DEFAULT NULL,
P_PROGRAM_CONTROL_ARG1			IN	VARCHAR2 DEFAULT NULL,
P_PROGRAM_CONTROL_ARG2			IN	VARCHAR2 DEFAULT NULL,
P_PROGRAM_CONTROL_ARG3			IN	VARCHAR2 DEFAULT NULL,
P_PROGRAM_CONTROL_ARG4			IN	VARCHAR2 DEFAULT NULL,
P_PROGRAM_CONTROL_ARG5			IN	VARCHAR2 DEFAULT NULL,
P_PROGRAM_CONTROL_ARG6 			IN	VARCHAR2 DEFAULT NULL,
X_RETURN_STATUS				OUT NOCOPY	VARCHAR2,
X_MSG_DATA				OUT NOCOPY	VARCHAR2,
X_MSG_COUNT				OUT NOCOPY	NUMBER,
X_ORGANIZATION_ID			OUT NOCOPY	NUMBER,
X_SUBINVENTORY				OUT NOCOPY	VARCHAR2,
X_SUBINVENTORY_STATUS			OUT NOCOPY	NUMBER,
X_LOCATOR				OUT NOCOPY	NUMBER,
X_LOCATOR_STATUS			OUT NOCOPY	NUMBER,
X_LPN_ID				OUT NOCOPY	NUMBER,
X_LPN_STATUS				OUT NOCOPY	NUMBER,
X_INVENTORY_ITEM_ID			OUT NOCOPY	NUMBER,
X_REVISION				OUT NOCOPY	VARCHAR2,
X_LOT_NUMBER				OUT NOCOPY	VARCHAR2,
X_LOT_STATUS				OUT NOCOPY	NUMBER,
X_QUANTITY				OUT NOCOPY	NUMBER,
X_UOM_CODE				OUT NOCOPY	VARCHAR2,
X_PRIMARY_QUANTITY			OUT NOCOPY	NUMBER,
X_TRANSACTION_QUANTITY 			OUT NOCOPY	NUMBER,
X_RESERVATION_ID			OUT NOCOPY	NUMBER
);


PROCEDURE WF_SUGGEST_ALT_LOC     (itemtype	IN	VARCHAR2,
				  itemkey	IN	VARCHAR2,
				  actid		IN	NUMBER,
				  funcmode	IN	VARCHAR2,
				  result		OUT NOCOPY	VARCHAR2) ;


PROCEDURE WF_Cycle_Count                   (itemtype	IN	VARCHAR2,
					    itemkey	IN	VARCHAR2,
					    actid	IN	NUMBER,
					    funcmode	IN	VARCHAR2,
					    result	OUT NOCOPY VARCHAR2) ;

PROCEDURE WF_is_task_processed           (itemtype	IN	VARCHAR2,
					    itemkey	IN	VARCHAR2,
					    actid	IN	NUMBER,
					    funcmode	IN	VARCHAR2,
					    result	OUT NOCOPY     VARCHAR2) ;

PROCEDURE WF_generate_next_task            (itemtype	IN	VARCHAR2,
					    itemkey	IN	VARCHAR2,
					    actid	IN	NUMBER,
					    funcmode	IN	VARCHAR2,
					    result	OUT NOCOPY     VARCHAR2) ;

PROCEDURE wf_send_to_bg                   (itemtype	IN	VARCHAR2,
					    itemkey	IN	VARCHAR2,
					    actid	IN	NUMBER,
					    funcmode	IN	VARCHAR2,
					    result	OUT NOCOPY     VARCHAR2) ;

PROCEDURE wms_inadequate_quantity  (itemtype	IN	VARCHAR2,
				    itemkey	IN	VARCHAR2,
				    actid		IN	NUMBER,
				    funcmode	IN	VARCHAR2,
				    result		OUT NOCOPY	VARCHAR2) ;


END wms_workflow_wrappers;


/
