--------------------------------------------------------
--  DDL for Package WMS_DEVHIST_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_DEVHIST_HANDLER_PKG" AUTHID CURRENT_USER as
/* $Header: WMSDVTHS.pls 115.2 2002/12/01 04:58:55 rbande noship $ */
procedure INSERT_ROW (
 X_ROWID 		             in OUT NOCOPY VARCHAR2,
 X_REQUEST_ID                        IN   NUMBER,--
 X_TASK_ID                           IN   NUMBER,--
 X_RELATION_ID                           IN  NUMBER,
 X_SEQUENCE_ID                           IN  NUMBER,
 X_TASK_SUMMARY                          IN  VARCHAR2,
 X_TASK_TYPE_ID                          IN  NUMBER,
 X_BUSINESS_EVENT_ID                 IN   NUMBER,--
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
);

procedure LOCK_ROW (
 X_ROWID 		             in varchar2,
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
 );

procedure UPDATE_ROW (
 X_ROWID 		in varchar2,
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
 );

procedure DELETE_ROW (
 X_ROWID 		in varchar2
 );

procedure UPDATE_CHILD_RECORDS (

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
);

procedure delete_CHILD_RECORDS
  (X_REQUEST_ID                        IN   NUMBER,
   X_TASK_ID                           IN   NUMBER,
   X_RELATION_ID                       IN   NUMBER,
   X_SEQUENCE_ID                       IN   NUMBER,
   X_BUSINESS_EVENT_ID                 IN   NUMBER
   );


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
 x_is_new_row                        IN NUMBER  --1 =YES, 0=NO
) ;
end WMS_DEVHIST_HANDLER_PKG;

 

/
