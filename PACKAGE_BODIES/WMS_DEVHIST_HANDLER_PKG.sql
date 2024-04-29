--------------------------------------------------------
--  DDL for Package Body WMS_DEVHIST_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_DEVHIST_HANDLER_PKG" as
/* $Header: WMSDVTHB.pls 115.7 2003/02/06 05:04:46 satkumar noship $ */
procedure INSERT_ROW (
 X_ROWID 		             IN OUT  NOCOPY VARCHAR2,
 X_REQUEST_ID                        IN   NUMBER,
 X_TASK_ID                           IN   NUMBER,
 X_RELATION_ID                           IN  NUMBER,
 X_SEQUENCE_ID                           IN  NUMBER,
 X_TASK_SUMMARY                          IN  VARCHAR2,
 X_TASK_TYPE_ID                          IN  NUMBER,
 X_BUSINESS_EVENT_ID                     IN   NUMBER,
 X_ORGANIZATION_ID                       IN  NUMBER,
 X_SUBINVENTORY_CODE                     IN  VARCHAR2,
 X_LOCATOR_ID                            IN  NUMBER,
 X_TRANSFER_ORG_ID                       IN  NUMBER,
 X_TRANSFER_SUB_CODE                     IN  VARCHAR2,
 X_TRANSFER_LOC_ID                       IN  NUMBER,
 X_INVENTORY_ITEM_ID                     IN  NUMBER,
 X_REVISION                              IN  VARCHAR2,
 X_UOM                                   IN  VARCHAR2,
 X_LOT_NUMBER                            IN  VARCHAR2,
 X_LOT_QTY                               IN  NUMBER,
 X_SERIAL_NUMBER                          IN    VARCHAR2,
 X_LPN_ID                                 IN    NUMBER,
 X_TRANSACTION_QUANTITY                   IN    NUMBER,
 X_DEVICE_ID                              IN    NUMBER,
 X_STATUS_CODE                            IN    VARCHAR2,
 X_STATUS_MSG                             IN    VARCHAR2,
 X_OUTFILE_NAME                           IN    VARCHAR2,
 X_REQUEST_DATE                           IN    DATE,
 X_RESUBMIT_DATE                          IN    DATE,
 X_REQUESTED_BY                           IN    NUMBER,
 X_RESP_APPLICATION_ID                    IN    NUMBER,
 X_RESPONSIBILITY_ID                      IN    NUMBER,
 X_CONCURRENT_REQUEST_ID                  IN    NUMBER,
 X_PROGRAM_APPLICATION_ID                IN        NUMBER,
 X_PROGRAM_ID                       IN        NUMBER,
 X_PROGRAM_UPDATE_DATE              IN        NUMBER,
 X_CREATION_DATE                           IN  DATE,
 X_CREATED_BY                              IN  NUMBER,
 X_LAST_UPDATE_DATE                        IN  DATE,
 X_LAST_UPDATED_BY                         IN  NUMBER,
 X_LAST_UPDATE_LOGIN                       IN  NUMBER,
 X_DEVICE_STATUS                           IN  VARCHAR2,
 X_REASON_ID                               IN  NUMBER,
 X_XFER_LPN_ID                             IN  NUMBER
) is

   CURSOR C IS SELECT rowid FROM wms_device_requests_hist
     WHERE request_id = X_REQUEST_ID
     AND task_id = X_TASK_ID
     AND business_event_id =  x_business_event_id
     AND task_summary = x_task_summary
     AND Nvl(sequence_id,-999) = Nvl(x_sequence_id,-999);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      inv_log_util.trace('inside inserting for HIST form','WMS_DEVHIST_HANDLER_PKG',9);
   END IF;
   insert into WMS_DEVICE_REQUESTS_HIST (
 REQUEST_ID ,
 TASK_ID ,
 RELATION_ID,
 SEQUENCE_ID,
 task_summary,
 task_type_id,
 business_event_id,
 organization_id,
 subinventory_code,
 locator_id,
 transfer_org_id,
 transfer_sub_code,
 transfer_loc_id,
 inventory_item_id,
 revision,
 uom,
 lot_number,
 lot_qty,
 serial_number,
 lpn_id,
 transaction_quantity,
 device_id,
 status_code,
 status_msg,
 outfile_name,
 request_date,
 resubmit_date,
 requested_by,
 responsibility_application_id,
 responsibility_id,
 concurrent_request_id,
 program_application_id,
 program_id,
 program_update_date,
 creation_date,
 created_by,
 last_update_date,
 last_updated_by,
 last_update_login,
 device_status,
 reason_id,
 XFER_LPN_ID
 ) values (
 X_REQUEST_ID ,
 X_TASK_ID ,
 X_RELATION_ID,
 X_SEQUENCE_ID,
 x_task_summary,
 x_task_type_id,
 x_business_event_id,
 x_organization_id,
 x_subinventory_code,
 x_locator_id,
 x_transfer_org_id,
 x_transfer_sub_code,
 x_transfer_loc_id,
 x_inventory_item_id,
 x_revision,
 x_uom,
 x_lot_number,
 x_lot_qty,
 x_serial_number,
 x_lpn_id,
 x_transaction_quantity,
 x_device_id,
 x_status_code,
 x_status_msg,
 x_outfile_name,
 x_request_date,
 x_resubmit_date,
 x_requested_by,
 x_resp_application_id,
 x_responsibility_id,
 x_concurrent_request_id,
 x_program_application_id,
 x_program_id,
 x_program_update_date,
 x_creation_date,
 x_created_by,
 x_last_update_date,
 x_last_updated_by,
 x_last_update_login,
 x_device_status,
 x_reason_id,
 X_XFER_LPN_ID
 );

     OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

end INSERT_ROW;

procedure LOCK_ROW (
 X_ROWID 		in VARCHAR2,
 X_REQUEST_ID                        IN   NUMBER,
 X_TASK_ID                           IN   NUMBER,
 X_RELATION_ID                           IN  NUMBER,
 X_SEQUENCE_ID                           IN  NUMBER,
 X_TASK_SUMMARY                          IN  VARCHAR2,
 X_TASK_TYPE_ID                          IN  NUMBER,
 X_BUSINESS_EVENT_ID                 IN   NUMBER,
 X_ORGANIZATION_ID                       IN  NUMBER,
 X_SUBINVENTORY_CODE                     IN  VARCHAR2,
 X_LOCATOR_ID                            IN  NUMBER,
 X_TRANSFER_ORG_ID                       IN  NUMBER,
 X_TRANSFER_SUB_CODE                     IN  VARCHAR2,
 X_TRANSFER_LOC_ID                       IN  NUMBER,
 X_INVENTORY_ITEM_ID                     IN  NUMBER,
 X_REVISION                              IN  VARCHAR2,
 X_UOM                                   IN  VARCHAR2,
 X_LPN_ID                                 IN    NUMBER,
 X_TRANSACTION_QUANTITY                   IN    NUMBER,
 X_DEVICE_ID                              IN    NUMBER,
 X_STATUS_CODE                            IN    VARCHAR2,
 X_STATUS_MSG                             IN    VARCHAR2,
 X_OUTFILE_NAME                           IN    VARCHAR2,
 X_REQUEST_DATE                           IN    DATE,
 X_RESUBMIT_DATE                          IN    DATE,
 X_REQUESTED_BY                           IN    NUMBER,
 X_RESP_APPLICATION_ID                    IN    NUMBER,
 X_RESPONSIBILITY_ID                      IN    NUMBER,
 X_CONCURRENT_REQUEST_ID                  IN    NUMBER,
 X_PROGRAM_APPLICATION_ID                IN        NUMBER,
 X_PROGRAM_ID                       IN        NUMBER,
 X_PROGRAM_UPDATE_DATE              IN        NUMBER,
 X_DEVICE_STATUS                           IN  VARCHAR2,
 X_REASON_ID                               IN  NUMBER,
 X_XFER_LPN_ID                             IN  NUMBER
) is
   cursor c is SELECT
     REQUEST_ID ,
     TASK_ID ,
     RELATION_ID,
     SEQUENCE_ID,
     task_summary,
     task_type_id,
     business_event_id,
     organization_id,
     subinventory_code,
     locator_id,
     transfer_org_id,
     transfer_sub_code,
     transfer_loc_id,
     inventory_item_id,
     revision,
     uom,
     lpn_id,
     transaction_quantity,
     device_id,
     status_code,
     status_msg,
     outfile_name,
     request_date,
     resubmit_date,
     requested_by,
     /*responsibility_application_id,
     responsibility_id,*/
     concurrent_request_id,
     /*program_application_id,
     program_id,
     program_update_date,*/
     device_status,
     reason_id,
     XFER_LPN_ID
     FROM wms_device_requests_hist
     WHERE ROWID = x_rowid
     for update OF request_id,task_id,business_event_id,organization_id nowait;

   recinfo c%rowtype;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  open c;
  fetch c into recinfo;
  if (c%notfound) then
     close c;
      IF (l_debug = 1) THEN
         inv_log_util.trace('inside LOCK ROW c%notfound','WMS_DEVHIST_HANDLER_PKG',9);
      END IF;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  IF (l_debug = 1) THEN
     inv_log_util.trace('inside LOCK ROW','WMS_DEVHIST_HANDLER_PKG',9);
  END IF;
  if (     (recinfo.request_id = x_request_id)
	   AND (recinfo.task_id = X_task_id)
	   AND (recinfo.business_event_id = X_business_event_id)
	   AND (recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
	   AND ((recinfo.RELATION_ID = X_RELATION_ID)
               OR ((recinfo.RELATION_ID is null) AND (X_RELATION_ID is null)))
	  AND ((recinfo.sequence_id = X_sequence_id)
               OR ((recinfo.sequence_id is null) AND (X_sequence_id is null)))
	   AND ((recinfo.task_summary = X_task_summary)
               OR ((recinfo.task_summary is null) AND (X_task_summary is null)))
	   AND ((recinfo.task_type_id = X_task_type_id)
		OR ((recinfo.task_type_id is null) AND (X_task_type_id is null)))
	   AND ((recinfo.subinventory_code = X_subinventory_code)
		OR ((recinfo.subinventory_code is null) AND (X_subinventory_code is null)))
	   AND ((recinfo.locator_id = X_locator_id)
		OR ((recinfo.locator_id is null) AND (X_locator_id is null)))
	   AND ((recinfo.transfer_org_id = X_transfer_org_id)
		OR ((recinfo.transfer_org_id is null) AND (X_transfer_org_id is null)))
	   AND ((recinfo.transfer_sub_code = X_transfer_sub_code)
		OR ((recinfo.transfer_sub_code is null) AND (X_transfer_sub_code is null)))
	   AND ((recinfo.transfer_loc_id = X_transfer_loc_id)
		OR ((recinfo.transfer_loc_id is null) AND (X_transfer_loc_id is null)))
	   AND ((recinfo.inventory_item_id = X_inventory_item_id)
	       OR ((recinfo.inventory_item_id is null) AND (X_inventory_item_id is  null)))
	   AND ((recinfo.revision = X_revision)
		OR ((recinfo.revision is null) AND (X_revision is null)))
	   AND ((recinfo.uom = X_uom)
		OR ((recinfo.uom is null) AND (X_uom is null)))
	   AND ((recinfo.lpn_id = X_lpn_id)
		OR ((recinfo.lpn_id is null) AND (X_lpn_id is null)))
	   AND ((recinfo.transaction_quantity = X_transaction_quantity)
	      OR ((recinfo.transaction_quantity is null) AND (X_transaction_quantity is null)))
	   AND ((recinfo.device_id = X_device_id)
		OR ((recinfo.device_id is null) AND (X_device_id is null)))
	   AND ((recinfo.status_code = X_status_code)
		OR ((recinfo.status_code is null) AND (X_status_code is null)))
	   AND ((recinfo.status_msg = X_status_msg)
		OR ((recinfo.status_msg is null) AND (X_status_msg is null)))
	   AND ((recinfo.outfile_name = X_outfile_name)
		OR ((recinfo.outfile_name is null) AND (X_outfile_name is null)))
	   AND ((recinfo.request_date = X_request_date)
		OR ((recinfo.request_date is null) AND (X_request_date is null)))
	   AND ((recinfo.resubmit_date = X_resubmit_date)
		OR ((recinfo.resubmit_date is null) AND (X_resubmit_date is null)))
	   AND ((recinfo.requested_by = X_requested_by)
		OR ((recinfo.requested_by is null) AND (X_requested_by is null)))
	   /*AND ((recinfo.responsibility_application_id = X_resp_application_id)
		OR ((recinfo.responsibility_application_id is null) AND (X_resp_application_id is null)))
	   AND ((recinfo.responsibility_id = X_responsibility_id)
		OR ((recinfo.responsibility_id is null) AND (X_responsibility_id is null)))*/
	   AND ((recinfo.concurrent_request_id = X_concurrent_request_id)
		OR ((recinfo.concurrent_request_id is null) AND (X_concurrent_request_id is null)))
	   /*AND ((recinfo.program_application_id = X_program_application_id)
		OR ((recinfo.program_application_id is null) AND (X_program_application_id is null)))
	   AND ((recinfo.program_id = X_program_id)
		OR ((recinfo.program_id is null) AND (X_program_id is null)))
	   AND ((recinfo.program_update_date = X_program_update_date)
		  OR ((recinfo.program_update_date is null) AND (X_program_update_date is null)))*/
	   AND ((recinfo.device_status = X_device_status)
		OR ((recinfo.device_status is null) AND (X_device_status is null)))
	   AND ((recinfo.reason_id = X_reason_id)--
		OR ((recinfo.reason_id is null) AND (X_reason_id is null)))
	  AND ((recinfo.XFER_LPN_ID = X_XFER_LPN_ID)
                OR ((recinfo.XFER_LPN_ID is null) AND (X_XFER_LPN_ID is null)))
    ) then
    return;
   ELSE
     IF (l_debug = 1) THEN
        inv_log_util.trace('inside LOCK ROW WILL SHOW CHNAGED MESG','WMS_DEVHIST_HANDLER_PKG',9);
     END IF;
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
end LOCK_ROW;

procedure UPDATE_ROW (
 X_ROWID 		in VARCHAR2,
 X_REQUEST_ID                        IN   NUMBER,
 X_TASK_ID                           IN   NUMBER,
 X_RELATION_ID                           IN  NUMBER,
 X_SEQUENCE_ID                           IN  NUMBER,
 X_TASK_SUMMARY                          IN  VARCHAR2,
 X_TASK_TYPE_ID                          IN  NUMBER,
 X_BUSINESS_EVENT_ID                 IN   NUMBER,
 X_ORGANIZATION_ID                       IN  NUMBER,
 X_SUBINVENTORY_CODE                     IN  VARCHAR2,
 X_LOCATOR_ID                            IN  NUMBER,
 X_TRANSFER_ORG_ID                       IN  NUMBER,
 X_TRANSFER_SUB_CODE                     IN  VARCHAR2,
 X_TRANSFER_LOC_ID                       IN  NUMBER,
 X_INVENTORY_ITEM_ID                     IN  NUMBER,
 X_REVISION                              IN  VARCHAR2,
 X_UOM                                   IN  VARCHAR2,
 X_LOT_NUMBER                            IN  VARCHAR2,
 X_LOT_QTY                               IN  NUMBER,
 X_SERIAL_NUMBER                          IN    VARCHAR2,
 X_LPN_ID                                 IN    NUMBER,
 X_TRANSACTION_QUANTITY                   IN    NUMBER,
 X_DEVICE_ID                              IN    NUMBER,
 X_STATUS_CODE                            IN    VARCHAR2,
 X_STATUS_MSG                             IN    VARCHAR2,
 X_OUTFILE_NAME                           IN    VARCHAR2,
 X_REQUEST_DATE                           IN    DATE,
 X_RESUBMIT_DATE                          IN    DATE,
 X_REQUESTED_BY                           IN    NUMBER,
 X_RESP_APPLICATION_ID          IN    NUMBER,
 X_RESPONSIBILITY_ID                      IN    NUMBER,
 X_CONCURRENT_REQUEST_ID                  IN    NUMBER,
 X_PROGRAM_APPLICATION_ID                IN        NUMBER,
 X_PROGRAM_ID                       IN        NUMBER,
 X_PROGRAM_UPDATE_DATE              IN        NUMBER,
 X_CREATION_DATE                           IN  DATE,
 X_CREATED_BY                              IN  NUMBER,
 X_LAST_UPDATE_DATE                        IN  DATE,
 X_LAST_UPDATED_BY                         IN  NUMBER,
 X_LAST_UPDATE_LOGIN                       IN  NUMBER,
 X_DEVICE_STATUS                           IN  VARCHAR2,
 X_REASON_ID                               IN  NUMBER,
 X_XFER_LPN_ID                             IN  NUMBER
) is

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   /*
 IF (l_debug = 1) THEN
    inv_log_util.trace('inside updating for HIST form','WMS_DEVHIST_HANDLER_PKG',9);
 END IF;

   */

   update wms_device_requests_hist set
    REQUEST_ID   = X_REQUEST_ID,
    TASK_ID      = X_TASK_ID ,
    relation_id  = x_RELATION_ID,
    sequence_id  = X_SEQUENCE_ID,
    task_summary = X_task_summary,
    task_type_id = X_task_type_id,
    business_event_id = X_business_event_id,
    organization_id   = X_organization_id,
    subinventory_code = X_subinventory_code,
    locator_id        = X_locator_id,
    transfer_org_id   = X_transfer_org_id,
    transfer_sub_code = X_transfer_sub_code,
    transfer_loc_id   = X_transfer_loc_id,
    inventory_item_id = X_inventory_item_id,
    revision          = X_revision,
    uom               = X_uom,
    lot_number        = X_lot_number,
    lot_qty           = X_lot_qty,
    serial_number     = X_serial_number,
    lpn_id            = X_lpn_id,
    transaction_quantity = X_transaction_quantity,
    device_id         = X_device_id,
    status_code       = X_status_code,
    status_msg        = X_status_msg,
    outfile_name      = X_outfile_name,
    request_date      = X_request_date,
    resubmit_date     = X_resubmit_date,
    requested_by      = X_requested_by,
    responsibility_application_id = X_resp_application_id,
    responsibility_id      = X_responsibility_id,
    concurrent_request_id  = X_concurrent_request_id,
    program_application_id = X_program_application_id,
    program_id             = X_program_id,
    program_update_date    = X_program_update_date,
    creation_date          = X_creation_date,
    created_by             = X_created_by,
    last_update_date       = X_last_update_date,
    last_updated_by        = X_last_updated_by,
    last_update_login      = X_last_update_login,
    device_status          = X_device_status,
    reason_id              = X_reason_id,
    xfer_lpn_id            = x_xfer_lpn_id
    WHERE  rowid = x_rowid;


  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
 X_ROWID 		in varchar2
) is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin

   /*
   IF (l_debug = 1) THEN
     inv_log_util.trace('inside inserting for HIST form','WMS_DEVHIST_HANDLER_PKG',9);
     END IF;
     */

   delete from wms_device_requests_hist
    WHERE ROWID=X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure UPDATE_CHILD_RECORDS
  (
 X_REQUEST_ID                        IN   NUMBER,
 X_TASK_ID                           IN   NUMBER,
 X_RELATION_ID                           IN  NUMBER,
 X_SEQUENCE_ID                           IN  NUMBER,
 X_TASK_TYPE_ID                          IN  NUMBER,
 X_BUSINESS_EVENT_ID                 IN   NUMBER,
 X_ORGANIZATION_ID                       IN  NUMBER,
 X_SUBINVENTORY_CODE                     IN  VARCHAR2,
 X_LOCATOR_ID                            IN  NUMBER,
 X_TRANSFER_ORG_ID                       IN  NUMBER,
 X_TRANSFER_SUB_CODE                     IN  VARCHAR2,
 X_TRANSFER_LOC_ID                       IN  NUMBER,
 X_INVENTORY_ITEM_ID                     IN  NUMBER,
 X_REVISION                              IN  VARCHAR2,
 X_UOM                                   IN  VARCHAR2,
 X_LPN_ID                                 IN    NUMBER,
 X_TRANSACTION_QUANTITY                   IN    NUMBER,
 X_DEVICE_ID                              IN    NUMBER,
 X_STATUS_CODE                            IN    VARCHAR2,
 X_STATUS_MSG                             IN    VARCHAR2,
 X_OUTFILE_NAME                           IN    VARCHAR2,
 X_REQUEST_DATE                           IN    DATE,
 X_RESUBMIT_DATE                          IN    DATE,
 X_REQUESTED_BY                           IN    NUMBER,
 X_RESP_APPLICATION_ID          IN    NUMBER,
 X_RESPONSIBILITY_ID                      IN    NUMBER,
 X_CONCURRENT_REQUEST_ID                  IN    NUMBER,
 X_CREATION_DATE                           IN  DATE,
 X_CREATED_BY                              IN  NUMBER,
 X_LAST_UPDATE_DATE                        IN  DATE,
 X_LAST_UPDATED_BY                         IN  NUMBER,
 X_LAST_UPDATE_LOGIN                       IN  NUMBER,
 X_DEVICE_STATUS                           IN  VARCHAR2,
 X_REASON_ID                               IN  NUMBER,
 X_XFER_LPN_ID                             IN  NUMBER
) is


   CURSOR C_child_records IS SELECT
     request_id,
     task_id,
     relation_id,
     sequence_id,
     business_event_id
     FROM wms_device_requests_hist
     WHERE  REQUEST_ID  = X_REQUEST_ID
     AND TASK_ID      = X_TASK_ID
     --AND relation_id  = x_relation_id
     AND Nvl(sequence_id,-1)  = Nvl(x_sequence_id,-1)
     AND task_summary = 'N'
     AND business_event_id = X_business_event_id
     FOR UPDATE OF
     transaction_quantity,transfer_loc_id,transfer_sub_code,reason_id,device_status NOWAIT;

   recinfo_child_records C_child_records%ROWTYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
/*
   IF (l_debug = 1) THEN
      inv_log_util.trace(' '||X_REQUEST_ID,'WMS_DEVHIST_HANDLER_PKG',9);
      inv_log_util.trace(' '||X_TASK_ID,'WMS_DEVHIST_HANDLER_PKG',9);
      inv_log_util.trace(' ' ||x_RELATION_ID,'WMS_DEVHIST_HANDLER_PKG',9);
      inv_log_util.trace(''||X_SEQUENCE_ID,'WMS_DEVHIST_HANDLER_PKG',9);
      inv_log_util.trace(' '||X_business_event_id,'WMS_DEVHIST_HANDLER_PKG',9);
   END IF;
*/
   OPEN C_child_records;
   FETCH C_child_records INTO recinfo_child_records;
   IF (C_child_records%notfound) THEN
      CLOSE C_child_records;
      IF (l_debug = 1) THEN
         inv_log_util.trace('Return:No chldRec to update','WMS_DEVHIST_HANDLER_PKG',9);
      END IF;
      --fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      RETURN;
    ELSE
      IF (l_debug = 1) THEN
         inv_log_util.trace('updating the child rec','WMS_DEVHIST_HANDLER_PKG',9);
      END IF;
      update wms_device_requests_hist set
	task_type_id      = X_task_type_id,
	organization_id   = X_organization_id,
	subinventory_code = X_subinventory_code,
	locator_id        = X_locator_id,
	transfer_org_id   = X_transfer_org_id,
	transfer_sub_code = X_transfer_sub_code,
	transfer_loc_id   = X_transfer_loc_id,
	inventory_item_id = X_inventory_item_id,
	revision          = X_revision,
	uom               = X_uom,
	lpn_id            = X_lpn_id,
	transaction_quantity = X_transaction_quantity,
	device_id         = X_device_id,
	status_code       = X_status_code,
	status_msg        = X_status_msg,
	outfile_name      = X_outfile_name,
	request_date      = X_request_date,
	resubmit_date     = X_resubmit_date,
	requested_by      = X_requested_by,
	responsibility_application_id = X_resp_application_id,
	responsibility_id      = X_responsibility_id,
	concurrent_request_id  = X_concurrent_request_id,
	creation_date          = X_creation_date,
	created_by             = X_created_by,
	last_update_date       = X_last_update_date,
	last_updated_by        = X_last_updated_by,
	last_update_login      = X_last_update_login,
	device_status          = X_device_status,
	reason_id              = X_reason_id,
	xfer_lpn_id            = x_xfer_lpn_id,
	relation_id            = x_relation_id
	WHERE  REQUEST_ID  = X_REQUEST_ID
	AND TASK_ID      = X_TASK_ID
	--AND relation_id  = x_relation_id
	AND Nvl(sequence_id,-1)  = Nvl(x_sequence_id,-1)
	AND task_summary = 'N'
	AND business_event_id = x_business_event_id;

   END IF;
   CLOSE C_child_records;

EXCEPTION
   WHEN OTHERS THEN
           IF (l_debug = 1) THEN
              inv_log_util.trace('inside exception'||SQLCODE,'WMS_DEVHIST_HANDLER_PKG',9);
           END IF;
      IF SQLCODE = -54 THEN --record locked by other session
	 fnd_message.set_name('FND','FORM_RECORD_CHANGED');
	 app_exception.raise_exception;
      END IF;


end UPDATE_CHILD_RECORDS;

procedure delete_CHILD_RECORDS
  (X_REQUEST_ID                        IN   NUMBER,
   X_TASK_ID                           IN   NUMBER,
   X_RELATION_ID                       IN   NUMBER,
   X_SEQUENCE_ID                       IN   NUMBER,
   X_BUSINESS_EVENT_ID                 IN   NUMBER
   ) IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  /*
   IF (l_debug = 1) THEN
      inv_log_util.trace('Inside delete_CHILD_RECORDS','WMS_DEVHIST_HANDLER_PKG',9);
   END IF;
   */
   delete from wms_device_requests_hist
     WHERE  REQUEST_ID   = X_REQUEST_ID
     AND TASK_ID      = X_TASK_ID
     AND relation_id  = x_RELATION_ID
     AND Nvl(sequence_id,-1) = Nvl(x_sequence_id,-1)
     AND task_summary = 'N'
     AND business_event_id = X_business_event_id;

END delete_child_records;


procedure lock_child_row (
			  X_ROWID 		in VARCHAR2,
			  X_REQUEST_ID                        IN   NUMBER,
			  X_TASK_ID                           IN   NUMBER,
			  X_RELATION_ID                           IN  NUMBER,
			  X_BUSINESS_EVENT_ID                 IN   NUMBER,
			  X_ORGANIZATION_ID                       IN  NUMBER,
			  X_LOT_NUMBER                            IN  VARCHAR2,
			  X_LOT_QTY                               IN  NUMBER,
			  X_SERIAL_NUMBER                          IN    VARCHAR2,
			  x_is_new_row                           IN NUMBER --1 =YES, 0=NO
			  ) is
     cursor c is SELECT
       REQUEST_ID ,
       TASK_ID ,
       RELATION_ID,
       business_event_id,
       organization_id,
       lot_number,
       lot_qty,
       serial_number
       FROM wms_device_requests_hist
       WHERE ROWID = x_rowid
       for update OF lot_number,lot_qty,serial_number nowait;

     recinfo c%rowtype;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  /*
   IF (l_debug = 1) THEN
      inv_log_util.trace('Inside lock_CHILD_RECORDS:::'||x_is_new_row,'WMS_DEVHIST_HANDLER_PKG',9);
     END IF;
*/

   open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (     (recinfo.request_id = x_request_id)
	   AND (recinfo.task_id = X_task_id)
	   AND (recinfo.business_event_id = X_business_event_id)
	   AND (recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
	   AND ((recinfo.RELATION_ID = X_RELATION_ID)
               OR ((recinfo.RELATION_ID is null) AND (X_RELATION_ID is null)))
	   AND ((recinfo.lot_number = X_lot_number)
		OR ((recinfo.lot_number is null) AND (X_lot_number is null)))
	   AND ((recinfo.lot_qty = X_lot_qty)
		OR ((recinfo.lot_qty is null) AND (X_lot_qty is null)))
	   AND ((recinfo.serial_number = X_serial_number)
		OR ((recinfo.serial_number is null) AND (X_serial_number is null)))

    ) then
    return;
   ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
--END IF;

END lock_child_row;


END WMS_DEVHIST_HANDLER_PKG;

/
