--------------------------------------------------------
--  DDL for Package CSD_BULK_RECEIVE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_BULK_RECEIVE_UTIL" AUTHID CURRENT_USER AS
/* $Header: csdubrus.pls 120.3.12010000.4 2009/09/02 05:28:41 subhat ship $ */

/* ---------------------------------------------------------*/
/* Define global variables                                  */
/* ---------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_BULK_RECEIVE_UTIL';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvbuts.pls';

/*--------------------------------------------------*/
/* Record name : Bulk_Receive_Rec                   */
/* description : Bulk Receive Rec record type       */
/*               definition                         */
/*--------------------------------------------------*/
TYPE BULK_RECEIVE_REC  IS RECORD
(
 BULK_RECEIVE_ID        NUMBER,
 TRANSACTION_NUMBER     NUMBER,
 ORIG_PARTY_ID          NUMBER,
 ORIG_CUST_ACCOUNT_ID   NUMBER,
 PARTY_ID               NUMBER,
 CUST_ACCOUNT_ID        NUMBER,
 SERIAL_NUMBER          VARCHAR2(30),
 INVENTORY_ITEM_ID      NUMBER,
 INSTANCE_ID            NUMBER,
 QUANTITY               NUMBER,
 UOM_CODE               VARCHAR2(3),
 STATUS                 VARCHAR2(30),
 PROCESS_STATUS         VARCHAR2(30),
 CHANGE_OWNER_FLAG      VARCHAR2(1),
 INTERNAL_SR_FLAG       VARCHAR2(1),
 WARNING_FLAG           VARCHAR2(1),
 WARNING_REASON_CODE    VARCHAR2(80),
 INCIDENT_ID            NUMBER,
 REPAIR_LINE_ID         NUMBER,
 ATTRIBUTE_CATEGORY     VARCHAR2(30),
 ATTRIBUTE1             VARCHAR2(150),
 ATTRIBUTE2             VARCHAR2(150),
 ATTRIBUTE3             VARCHAR2(150),
 ATTRIBUTE4             VARCHAR2(150),
 ATTRIBUTE5             VARCHAR2(150),
 ATTRIBUTE6             VARCHAR2(150),
 ATTRIBUTE7             VARCHAR2(150),
 ATTRIBUTE8             VARCHAR2(150),
 ATTRIBUTE9             VARCHAR2(150),
 ATTRIBUTE10            VARCHAR2(150),
 ATTRIBUTE11            VARCHAR2(150),
 ATTRIBUTE12            VARCHAR2(150),
 ATTRIBUTE13            VARCHAR2(150),
 ATTRIBUTE14            VARCHAR2(150),
 ATTRIBUTE15            VARCHAR2(150),
 OBJECT_VERSION_NUMBER  NUMBER,
 CREATED_BY             NUMBER(15),
 CREATION_DATE          DATE,
 LAST_UPDATED_BY        NUMBER(15),
 LAST_UPDATE_DATE       DATE,
 LAST_UPDATE_LOGIN      NUMBER(15)
);


/*--------------------------------------------------*/
/* Record name : Bulk_AutoReceive_Rec               */
/* description : Bulk AutoReceive Record definition */
/*                                                  */
/*--------------------------------------------------*/
TYPE BULK_AUTORCV_REC IS RECORD
(

  BULK_RECEIVE_ID     NUMBER,
  REPAIR_LINE_ID      NUMBER,
  ORDER_LINE_ID       NUMBER,
  ORDER_HEADER_ID     NUMBER,
  -- new parameters added. 12.2 subhat
  UNDER_RECEIPT_FLAG  VARCHAR2(5),
  RECEIPT_QTY         NUMBER,
  LOCATOR_ID          NUMBER,
  SUBINVENTORY        VARCHAR2(30),
  LOT_NUMBER          VARCHAR2(30),
  ITEM_REVISION       VARCHAR2(3),
  SERIAL_NUMBER       VARCHAR2(30)
);

TYPE BULK_AUTORCV_TBL IS TABLE OF BULK_AUTORCV_REC INDEX BY BINARY_INTEGER;

/*------------------------------------------------------------*/
/* Record Name : SR_RO_RMA_REC                                */
/* Description : Record Definition used by the find RO/RMA    */
/*               program									  */
/*------------------------------------------------------------*/
TYPE SR_RO_RMA_REC IS RECORD (
INCIDENT_ID         NUMBER,
REPAIR_LINE_ID      NUMBER,
ORDER_LINE_ID       NUMBER,
ORDER_HEADER_ID     NUMBER,
BULK_RECEIVE_ID     NUMBER,
CREATE_SR_FLAG      VARCHAR2(3),
CREATE_RO_FLAG      VARCHAR2(3),
FOUND_RMA_FLAG      VARCHAR2(3),
RO_QUANTITY         NUMBER,
CUST_ACCT_ID        NUMBER,
PARTY_ID            NUMBER,
QUANTITY            NUMBER,
INVENTORY_ITEM_ID   NUMBER,
SERIAL_NUMBER       VARCHAR2(30),
INSTANCE_ID         NUMBER,
NEW_RMA             VARCHAR2(3),
SPLIT_RMA_QTY       NUMBER,
NEW_RMA_QTY         NUMBER,
SPLIT_RMA           VARCHAR2(3),
rev_control_flag    VARCHAR2(3),
revision            VARCHAR2(3),
UI_INCIDENT_ID      NUMBER,
SERIAL_CONTROL_FLAG NUMBER
);

TYPE SR_RO_RMA_TBL IS TABLE OF SR_RO_RMA_REC INDEX BY BINARY_INTEGER;

TYPE MATCHING_RMA_REC IS RECORD (
PROD_TXN_STATUS       VARCHAR2(30),
SOURCE_SERIAL_NUMBER  VARCHAR2(30),
SOURCE_INSTANCE_ID    NUMBER,
RMA_QUANTITY          NUMBER,
HEADER_ID             NUMBER,
LINE_ID               NUMBER,
INV_ITEM_ID           NUMBER
);

TYPE MATCHING_RMA_TBL IS TABLE OF MATCHING_RMA_REC INDEX BY BINARY_INTEGER;

TYPE SERIAL_CONTROL_FLAG IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

-- global cache variable.
G_SERIAL_CONTROL_FLAG SERIAL_CONTROL_FLAG;

/*-----------------------------------------------------------------*/
/* procedure name: validate_bulk_receive_rec                       */
/* description   : Validate Bulk Receive record definition         */
/*                                                                 */
/*-----------------------------------------------------------------*/
PROCEDURE validate_bulk_receive_rec
(
  p_party_id             IN         NUMBER,
  p_quantity             IN         NUMBER,
  p_serial_number        IN         VARCHAR2,
  p_inventory_item_id    IN         NUMBER,
  x_warning_flag         OUT NOCOPY VARCHAR2,
  x_warning_reason_code  OUT NOCOPY VARCHAR2,
  x_change_owner_flag    OUT NOCOPY VARCHAR2,
  x_internal_sr_flag     OUT NOCOPY VARCHAR2
);

/*-----------------------------------------------------------------*/
/* procedure name: create_blkrcv_sr                                */
/* description   : Procedure to create Service Request             */
/*                                                                 */
/*-----------------------------------------------------------------*/
PROCEDURE create_blkrcv_sr
(
  p_bulk_receive_rec    IN     csd_bulk_receive_util.bulk_receive_rec,
  p_sr_notes_tbl        IN     cs_servicerequest_pub.notes_table,
  x_incident_id         OUT    NOCOPY NUMBER,
  x_incident_number     OUT    NOCOPY VARCHAR2,
  x_return_status       OUT    NOCOPY VARCHAR2,
  x_msg_count           OUT    NOCOPY NUMBER,
  x_msg_data            OUT    NOCOPY VARCHAR2
 );

/*-----------------------------------------------------------------*/
/* procedure name: create_blkrcv_ro                                */
/* description   : Procedure to create Repair Orders               */
/*                                                                 */
/*-----------------------------------------------------------------*/
 PROCEDURE create_blkrcv_ro
 (
   p_bulk_receive_id     IN     NUMBER,
   x_repair_line_id      OUT    NOCOPY NUMBER,
   x_repair_number       OUT    NOCOPY VARCHAR2,
   x_ro_status           OUT    NOCOPY VARCHAR2,
   x_return_status       OUT    NOCOPY VARCHAR2,
   x_msg_count           OUT    NOCOPY NUMBER,
   x_msg_data            OUT    NOCOPY VARCHAR2
 ) ;

/*------------------------------------------------------------------*/
/* procedure name: create_blkrcv_default_prod_txn                   */
/* description   : Procedure to create Default Product Transactions */
/*                                                                  */
/*------------------------------------------------------------------*/
 PROCEDURE create_blkrcv_default_prod_txn
 (
   p_bulk_receive_id     IN     NUMBER,
   x_return_status       OUT    NOCOPY VARCHAR2,
   x_msg_count           OUT    NOCOPY NUMBER,
   x_msg_data            OUT    NOCOPY VARCHAR2
 );

/*-----------------------------------------------------------------*/
/* procedure name: change_blkrcv_ib_owner                          */
/* description   : Procedure to Change the Install Base Owner      */
/*                                                                 */
/*-----------------------------------------------------------------*/
 PROCEDURE change_blkrcv_ib_owner
 (
  p_bulk_receive_id       IN     NUMBER,
  x_return_status         OUT    NOCOPY VARCHAR2,
  x_msg_count             OUT    NOCOPY NUMBER,
  x_msg_data              OUT    NOCOPY VARCHAR2
 );

/*-----------------------------------------------------------------*/
/* procedure name: bulk_auto_receive                               */
/* description   : Procedure to Auto Receive                       */
/*                                                                 */
/*-----------------------------------------------------------------*/
 PROCEDURE bulk_auto_receive
 (
  p_bulk_autorcv_tbl IN OUT  NOCOPY csd_bulk_receive_util.bulk_autorcv_tbl,
  x_return_status       OUT  NOCOPY VARCHAR2,
  x_msg_count           OUT  NOCOPY NUMBER,
  x_msg_data            OUT  NOCOPY VARCHAR2
 );

/*-----------------------------------------------------------------*/
/* procedure name: write_to_conc_log                               */
/* description   : Procedure to write the error stack to the the   */
/*                 Concurrent log                                  */
/*-----------------------------------------------------------------*/
 PROCEDURE write_to_conc_log
 (
  p_msg_count   IN NUMBER,
  p_msg_data    IN VARCHAR2
 );

/*-----------------------------------------------------------------*/
/* procedure name: write_to_conc_output                            */
/* description   : Procedure to write the output to the Concurrent */
/*                 Output                                          */
/*-----------------------------------------------------------------*/
 PROCEDURE write_to_conc_output
 (
  p_transaction_number  IN NUMBER
 );

-- swai: bug 7657379
-- added function to get default repair type and use bulk receiving
-- profile option value as backup default value.
/*-----------------------------------------------------------------*/
/* function name:  get_bulk_rcv_def_repair_type                    */
/* description   : Function to get the default repair type for     */
/*                 bulk receiving, based on defaulting rules and   */
/*                 bulk receiving profile option.                  */
/*                 Output    Repair Type ID                        */
/*-----------------------------------------------------------------*/
 FUNCTION get_bulk_rcv_def_repair_type
 (
   p_incident_id              IN     NUMBER,
   p_ro_inventory_item_id     IN     NUMBER
 ) return NUMBER;

-- swai: bug 7663674
-- added function to get default rma subinv and use bulk receiving
-- profile option value as backup default value.
/*-----------------------------------------------------------------*/
/* function name:  get_bulk_rcv_def_sub_inv                        */
/* description   : Function to get the default rma subinv for      */
/*                 bulk receiving, based on defaulting rules and   */
/*                 bulk receiving profile option.                  */
/*                 Output    RMA Subinventory Code                 */
/*-----------------------------------------------------------------*/
 FUNCTION get_bulk_rcv_def_sub_inv
 (
   p_repair_line_id              IN     NUMBER
 ) return VARCHAR2;

/*-----------------------------------------------------------------*/
/* procedure name: get_sr_ro_rma_details                           */
/* description   : Procedure to get the existing SR,RO,RMA         */
/*                 combination                                     */
/*-----------------------------------------------------------------*/
 PROCEDURE get_sr_ro_rma_details
   (
     p_transaction_number IN NUMBER,
     x_sr_ro_rma_tbl      IN OUT NOCOPY sr_ro_rma_tbl
   );

 /*-----------------------------------------------------------------*/
 /* procedure name: matching_rma_found                              */
 /* description   : Procedure to get the RMA for the repair order   */
 /*                 passed.                                         */
 /*-----------------------------------------------------------------*/


  PROCEDURE matching_rma_found
   (
     p_repair_line_id        IN NUMBER,
     p_blk_rec_qty           IN NUMBER,
     p_blk_rec_serial_number IN VARCHAR2,
     p_blk_rec_instance_id   IN NUMBER,
     p_blk_rec_inv_id        IN NUMBER,
     x_rma_found             OUT NOCOPY VARCHAR2,
     x_new_rma               OUT NOCOPY VARCHAR2,
     x_split_rma_qty         OUT NOCOPY NUMBER,
     x_new_rma_qty           OUT NOCOPY NUMBER,
     x_split_rma             OUT NOCOPY VARCHAR2,
     x_order_header_id       OUT NOCOPY NUMBER,
     x_order_line_id         OUT NOCOPY NUMBER
   );

 /*-----------------------------------------------------------------*/
 /* procedure name: create_new_rma	                               */
 /* description   : Procedure to get the create a new RMA for the   */
 /*                 over receipt case.                              */
 /*-----------------------------------------------------------------*/

 PROCEDURE create_new_rma
  (
     p_api_version    IN NUMBER DEFAULT 1,
     p_init_msg_list   IN VARCHAR2 DEFAULT 'F',
     p_commit          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_order_header_id IN NUMBER,
     p_new_rma_qty     IN NUMBER,
     p_repair_line_id  IN NUMBER,
     p_incident_id     IN NUMBER,
     p_rma_quantity    IN NUMBER,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_order_line_id   OUT NOCOPY NUMBER,
     x_order_header_id OUT NOCOPY NUMBER
  ) ;

 /*-----------------------------------------------------------------*/
 /* procedure name: link_sr_ro_rma_oa_wrapper                       */
 /* description   : Procedure called from OA page to retreive the   */
 /*                 SR, RO and RMA.                                 */
 /*-----------------------------------------------------------------*/

   PROCEDURE link_sr_ro_rma_oa_wrapper(
     p_bulk_rcv_dtls_tbl IN  VARCHAR2_TABLE_200,
     p_mode              IN  VARCHAR2,
     p_incident_id       IN  NUMBER DEFAULT NULL,
     x_repair_line_id    OUT NOCOPY JTF_NUMBER_TABLE,
     x_incident_id       OUT NOCOPY JTF_NUMBER_TABLE,
     x_unplanned_receipt_flag OUT NOCOPY VARCHAR2_TABLE_100,
     x_over_receipt_flag      OUT NOCOPY VARCHAR2_TABLE_100,
     x_under_receipt_flag     OUT NOCOPY VARCHAR2_TABLE_100,
     x_order_header_id        OUT NOCOPY JTF_NUMBER_TABLE,
     x_order_line_id          OUT NOCOPY JTF_NUMBER_TABLE,
     x_over_receipt_qty       OUT NOCOPY JTF_NUMBER_TABLE,
     x_under_receipt_qty      OUT NOCOPY JTF_NUMBER_TABLE
  ) ;


 /* ***************************************************************************/
 /* Procedure Name: after_receipt 											 */
 /* Description: Performs the action after the PO Receipt concurrent program  */
 /*              is finished													*/
 /* params: @p_request_group_id: Group Id for receipts submitted. 			*/
 /*         @p_transaction_number: Bulk Receive Transaction Number.			*/
 /* ***************************************************************************/

 procedure after_receipt(p_request_group_id IN NUMBER,
 						p_transaction_number IN NUMBER
 						);

 /* ***************************************************************************/
 /* Procedure Name: pre_process_rma.                                          */
 /* Description: Checks if the RMA is ready to be received. If the RMA is in  */
 /*              SUBMITTED status, books the RMA and if the RMA is in ENTERED */
 /*              status, then it submits the RMA to OM and books it.          */
 /* ***************************************************************************/

 procedure pre_process_rma (p_repair_line_id  IN NUMBER,
 						   px_order_header_id IN OUT NOCOPY NUMBER,
 						   px_order_line_id   IN OUT NOCOPY NUMBER,
 						   x_return_status   OUT NOCOPY VARCHAR2,
 						   x_msg_count       OUT NOCOPY NUMBER,
 						   x_msg_data        OUT NOCOPY VARCHAR2
 						   );

 /* ***************************************************************************/
 /* Procedure Name: create_new_ship_line.                                     */
 /* Description : Creates a new Ship line for the over-receipt quantity       */
 /* ***************************************************************************/

 procedure create_new_ship_line
 					(
              		 p_api_version 	   IN VARCHAR2,
              		 p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
              		 p_commit      	   IN VARCHAR2 DEFAULT  FND_API.G_FALSE,
              		 p_order_header_id IN NUMBER,
              		 p_new_ship_qty    IN NUMBER,
              		 p_repair_line_id  IN NUMBER,
              		 p_incident_id     IN NUMBER,
              		 x_return_status   OUT NOCOPY VARCHAR2,
 					 x_msg_count       OUT NOCOPY NUMBER,
                      x_msg_data        OUT NOCOPY VARCHAR2
                      );
 -- 12.2, subhat
 FUNCTION split_varchar2_tbl (
         px_tbl_type IN OUT NOCOPY VARCHAR2,
         p_delimiter IN VARCHAR2
 ) RETURN VARCHAR2;
 /*-----------------------------------------------------------------*/
 /* Function name: get_latest_open_sr                               */
 /* description   : The function will return the latest open SR     */
 /*                 if any for the customer account.                */
 /*-----------------------------------------------------------------*/

 FUNCTION get_latest_open_sr
   (
    p_account_id in NUMBER,
    p_party_id   in NUMBER) RETURN NUMBER;

 /*-----------------------------------------------------------------*/
 /* Function name: get_num_in_list                                  */
 /* description   : The function will return the JTF_NUMBER_TABLE   */
 /*                 type when a string containing numbers is passed to it.*/
 /*-----------------------------------------------------------------*/

FUNCTION get_num_in_list(p_in_string IN varchar2) RETURN JTF_NUMBER_TABLE;

END CSD_BULK_RECEIVE_UTIL;

/
