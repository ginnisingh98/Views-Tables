--------------------------------------------------------
--  DDL for Package GML_RCV_STD_RCPT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_RCV_STD_RCPT_APIS" AUTHID CURRENT_USER AS
/* $Header: GMLSTDRS.pls 120.0 2005/05/25 16:42:16 appldev noship $*/

  g_header_intf_id         NUMBER := NULL;

 TYPE rcv_enter_receipts_rec_tp IS RECORD
   (LINE_CHKBOX                              CHAR(1),
    SOURCE_TYPE_CODE                         VARCHAR2(30),
    RECEIPT_SOURCE_CODE                      VARCHAR2(30),
    ORDER_TYPE_CODE                          VARCHAR2(30),
    ORDER_TYPE                               VARCHAR2(80),
    PO_HEADER_ID                             NUMBER,
    PO_NUMBER                                VARCHAR2(30),
    PO_LINE_ID                               NUMBER,
    PO_LINE_NUMBER                           NUMBER,
    PO_LINE_LOCATION_ID                      NUMBER,
    PO_SHIPMENT_NUMBER                       NUMBER,
    PO_RELEASE_ID                            NUMBER,
    PO_RELEASE_NUMBER                        NUMBER,
    REQ_HEADER_ID                            NUMBER,
    REQ_NUMBER                               VARCHAR2(80),
    REQ_LINE_ID                              NUMBER,
    REQ_LINE                                 NUMBER,
    REQ_DISTRIBUTION_ID                      NUMBER,
    RCV_SHIPMENT_HEADER_ID                   NUMBER,
   RCV_SHIPMENT_NUMBER                      VARCHAR2(30),
   RCV_SHIPMENT_LINE_ID                     NUMBER,
   RCV_LINE_NUMBER                          NUMBER,
   FROM_ORGANIZATION_ID                     NUMBER,
   TO_ORGANIZATION_ID                       NUMBER,
   VENDOR_ID                                NUMBER,
   SOURCE                                   VARCHAR2(255),
   VENDOR_SITE_ID                           NUMBER,
   OUTSIDE_OPERATION_FLAG                   VARCHAR2(1),
   ITEM_ID                                  NUMBER,
   -- bug 2073164
   -- Added extra column in the rec structure
   UOM_CODE                                 VARCHAR2(3),
   PRIMARY_UOM                              VARCHAR2(25),
   PRIMARY_UOM_CLASS                        VARCHAR2(10),
   ITEM_ALLOWED_UNITS_LOOKUP_CODE           NUMBER,
   ITEM_LOCATOR_CONTROL                     NUMBER,
   RESTRICT_LOCATORS_CODE                   VARCHAR2(1),
   RESTRICT_SUBINVENTORIES_CODE             VARCHAR2(1),
   SHELF_LIFE_CODE                          NUMBER,
   SHELF_LIFE_DAYS                          NUMBER,
   SERIAL_NUMBER_CONTROL_CODE               NUMBER,
   LOT_CONTROL_CODE                         NUMBER,
   ITEM_REV_CONTROL_FLAG_TO                 VARCHAR2(1),
   ITEM_REV_CONTROL_FLAG_FROM               VARCHAR2(1),
   ITEM_NUMBER                              VARCHAR2(40),
   ITEM_REVISION                            VARCHAR2(3),
   ITEM_DESCRIPTION                         VARCHAR2(240),
   ITEM_CATEGORY_ID                         NUMBER,
   HAZARD_CLASS                             VARCHAR2(40),
   UN_NUMBER                                VARCHAR2(30),
   VENDOR_ITEM_NUMBER                       VARCHAR2(30),
   SHIP_TO_LOCATION_ID                      NUMBER,
   SHIP_TO_LOCATION                         VARCHAR2(60),
   PACKING_SLIP                             VARCHAR2(80),
   ROUTING_ID                               NUMBER,
   ROUTING_NAME                             VARCHAR2(30),
   NEED_BY_DATE                             DATE,
   EXPECTED_RECEIPT_DATE                    DATE,
   ORDERED_QTY                              NUMBER,
   ORDERED_UOM                              VARCHAR2(25),
   USSGL_TRANSACTION_CODE                   VARCHAR2(30),
   GOVERNMENT_CONTEXT                       VARCHAR2(30),
   INSPECTION_REQUIRED_FLAG                 VARCHAR2(1),
   RECEIPT_REQUIRED_FLAG                    VARCHAR2(1),
   ENFORCE_SHIP_TO_LOCATION_CODE            VARCHAR2(30),
   UNIT_PRICE                               NUMBER,
   CURRENCY_CODE                            VARCHAR2(30),
   CURRENCY_CONVERSION_TYPE                 VARCHAR2(30),
   CURRENCY_CONVERSION_DATE                 DATE,
   CURRENCY_CONVERSION_RATE                 NUMBER,
   NOTE_TO_RECEIVER                         VARCHAR2(240),
   DESTINATION_TYPE_CODE                    VARCHAR2(30),
   DELIVER_TO_PERSON_ID                     NUMBER,
   DELIVER_TO_LOCATION_ID                   NUMBER,
   DESTINATION_SUBINVENTORY                 VARCHAR2(10),
   ATTRIBUTE_CATEGORY                       VARCHAR2(30),
   ATTRIBUTE1                               VARCHAR2(240),
   ATTRIBUTE2                               VARCHAR2(240),
   ATTRIBUTE3                               VARCHAR2(240),
   ATTRIBUTE4                               VARCHAR2(240),
   ATTRIBUTE5                               VARCHAR2(240),
   ATTRIBUTE6                               VARCHAR2(240),
   ATTRIBUTE7                               VARCHAR2(240),
   ATTRIBUTE8                               VARCHAR2(240),
   ATTRIBUTE9                               VARCHAR2(240),
   ATTRIBUTE10                              VARCHAR2(240),
   ATTRIBUTE11                              VARCHAR2(240),
   ATTRIBUTE12                              VARCHAR2(240),
   ATTRIBUTE13                              VARCHAR2(240),
   ATTRIBUTE14                              VARCHAR2(240),
   ATTRIBUTE15                              VARCHAR2(240),
   CLOSED_CODE                              VARCHAR2(30),
   ASN_TYPE                                 VARCHAR2(30),
   BILL_OF_LADING                           VARCHAR2(30),
   SHIPPED_DATE                             DATE,
   FREIGHT_CARRIER_CODE                     VARCHAR2(30),
   WAYBILL_AIRBILL_NUM                      VARCHAR2(80),
   FREIGHT_BILL_NUM                         VARCHAR2(35),
   VENDOR_LOT_NUM                           VARCHAR2(30),
   CONTAINER_NUM                            VARCHAR2(35),
   TRUCK_NUM                                VARCHAR2(35),
   BAR_CODE_LABEL                           VARCHAR2(35),
   RATE_TYPE_DISPLAY                        VARCHAR2(30),
   MATCH_OPTION                             VARCHAR2(25),
   COUNTRY_OF_ORIGIN_CODE                   VARCHAR2(2),
   OE_ORDER_HEADER_ID                       NUMBER,
   OE_ORDER_NUM                             NUMBER,
   OE_ORDER_LINE_ID                         NUMBER,
   OE_ORDER_LINE_NUM                        NUMBER,
   CUSTOMER_ID                              NUMBER,
   CUSTOMER_SITE_ID                         NUMBER,
   CUSTOMER_ITEM_NUM                        VARCHAR2(50),
   PLL_NOTE_TO_RECEIVER                     VARCHAR2(240),
   -- ABOVE FIELDS ARE FROM RCV_ENTER_RECEIPTS_V
   -- BELOW ARE MAINLY FROM PO_DISTRIBUTIONS
   PO_DISTRIBUTION_ID                       NUMBER,
   QTY_ORDERED                              NUMBER,
   WIP_ENTITY_ID                            NUMBER,
   WIP_OPERATION_SEQ_NUM                    NUMBER,
   WIP_RESOURCE_SEQ_NUM                     NUMBER,
   WIP_REPETITIVE_SCHEDULE_ID               NUMBER,
   WIP_LINE_ID                              NUMBER,
   BOM_RESOURCE_ID                          NUMBER,
   DESTINATION_TYPE                         VARCHAR2(80),
   LOCATION                                 VARCHAR2(60),
   CURRENCY_CONVERSION_RATE_POD             NUMBER,
   CURRENCY_CONVERSION_DATE_POD             DATE,
   PROJECT_ID                               NUMBER,
   TASK_ID                                  NUMBER);



 -- this is the record type for RCV_TRANSACTION Block
 -- which includes DB items from RCV_ENTER_RECEIPTS_V
 -- and NON-DB items
 TYPE rcv_transaction_rec_tp IS RECORD
   (LINE_CHKBOX                              CHAR(1)
   , SOURCE_TYPE_CODE                         VARCHAR2(30)
   , RECEIPT_SOURCE_CODE                      VARCHAR2(30)
   , ORDER_TYPE_CODE                          VARCHAR2(30)
   , ORDER_TYPE                               VARCHAR2(80)
   , PO_HEADER_ID                             NUMBER
   , PO_NUMBER                                VARCHAR2(30)
   , PO_LINE_ID                               NUMBER
   , PO_LINE_NUMBER                           NUMBER
   , PO_LINE_LOCATION_ID                      NUMBER
   , PO_SHIPMENT_NUMBER                       NUMBER
   , PO_RELEASE_ID                            NUMBER
   , PO_RELEASE_NUMBER                        NUMBER
   , REQ_HEADER_ID                            NUMBER
   , REQ_NUMBER                               VARCHAR2(80)
   , REQ_LINE_ID                              NUMBER
   , REQ_LINE                                 NUMBER
   , REQ_DISTRIBUTION_ID                      NUMBER
   , RCV_SHIPMENT_HEADER_ID                   NUMBER
   , RCV_SHIPMENT_NUMBER                      VARCHAR2(30)
   , RCV_SHIPMENT_LINE_ID                     NUMBER
   , RCV_LINE_NUMBER                          NUMBER
   , FROM_ORGANIZATION_ID                     NUMBER
   , TO_ORGANIZATION_ID                       NUMBER
   , VENDOR_ID                                NUMBER
   , SOURCE                                   VARCHAR2(255)
   , VENDOR_SITE_ID                           NUMBER
   , OUTSIDE_OPERATION_FLAG                   VARCHAR2(1)
   , ITEM_ID                                  NUMBER
   -- bug 2073164
   -- Added extra column in the rec structure
   , UOM_CODE                                 VARCHAR2(3)
   , PRIMARY_UOM                              VARCHAR2(25)
   , PRIMARY_UOM_CLASS                        VARCHAR2(10)
   , ITEM_ALLOWED_UNITS_LOOKUP_CODE           NUMBER
   , ITEM_LOCATOR_CONTROL                     NUMBER
   , RESTRICT_LOCATORS_CODE                   VARCHAR2(1)
   , RESTRICT_SUBINVENTORIES_CODE             VARCHAR2(1)
   , SHELF_LIFE_CODE                          NUMBER
   , SHELF_LIFE_DAYS                          NUMBER
   , SERIAL_NUMBER_CONTROL_CODE               NUMBER
   , LOT_CONTROL_CODE                         NUMBER
   , ITEM_REV_CONTROL_FLAG_TO                 VARCHAR2(1)
   , ITEM_REV_CONTROL_FLAG_FROM               VARCHAR2(1)
   , ITEM_NUMBER                              VARCHAR2(40)
   , ITEM_REVISION                            VARCHAR2(3)
   , ITEM_DESCRIPTION                         VARCHAR2(240)
   , ITEM_CATEGORY_ID                         NUMBER
   , HAZARD_CLASS                             VARCHAR2(40)
   , UN_NUMBER                                VARCHAR2(30)
   , VENDOR_ITEM_NUMBER                       VARCHAR2(30)
   , SHIP_TO_LOCATION_ID                      NUMBER
   , SHIP_TO_LOCATION                         VARCHAR2(60)
   , PACKING_SLIP                             VARCHAR2(30)
   , ROUTING_ID                               NUMBER
   , ROUTING_NAME                             VARCHAR2(30)
   , NEED_BY_DATE                             DATE
   , EXPECTED_RECEIPT_DATE                    DATE
   , ORDERED_QTY                              NUMBER
   , ORDERED_UOM                              VARCHAR2(25)
   , USSGL_TRANSACTION_CODE                   VARCHAR2(30)
   , GOVERNMENT_CONTEXT                       VARCHAR2(30)
   , INSPECTION_REQUIRED_FLAG                 VARCHAR2(1)
   , RECEIPT_REQUIRED_FLAG                    VARCHAR2(1)
   , ENFORCE_SHIP_TO_LOCATION_CODE            VARCHAR2(30)
   , UNIT_PRICE                               NUMBER
   , CURRENCY_CODE                            VARCHAR2(15)
   , CURRENCY_CONVERSION_TYPE                 VARCHAR2(30)
   , CURRENCY_CONVERSION_DATE                 DATE
   , CURRENCY_CONVERSION_RATE                 NUMBER
   , NOTE_TO_RECEIVER                         VARCHAR2(240)
   , DESTINATION_TYPE_CODE                    VARCHAR2(30)
   , DELIVER_TO_PERSON_ID                     NUMBER
   , DELIVER_TO_LOCATION_ID                   NUMBER
   , DESTINATION_SUBINVENTORY                 VARCHAR2(10)
   , ATTRIBUTE_CATEGORY                       VARCHAR2(30)
   , ATTRIBUTE1                               VARCHAR2(240)
   , ATTRIBUTE2                               VARCHAR2(240)
   , ATTRIBUTE3                               VARCHAR2(240)
   , ATTRIBUTE4                               VARCHAR2(240)
   , ATTRIBUTE5                               VARCHAR2(240)
   , ATTRIBUTE6                               VARCHAR2(240)
   , ATTRIBUTE7                               VARCHAR2(240)
   , ATTRIBUTE8                               VARCHAR2(240)
   , ATTRIBUTE9                               VARCHAR2(240)
   , ATTRIBUTE10                              VARCHAR2(240)
   , ATTRIBUTE11                              VARCHAR2(240)
   , ATTRIBUTE12                              VARCHAR2(240)
   , ATTRIBUTE13                              VARCHAR2(240)
   , ATTRIBUTE14                              VARCHAR2(240)
   , ATTRIBUTE15                              VARCHAR2(240)
   , CLOSED_CODE                              VARCHAR2(30)
   , ASN_TYPE                                 VARCHAR2(30)
   , BILL_OF_LADING                           VARCHAR2(30)
   , SHIPPED_DATE                             DATE
   , FREIGHT_CARRIER_CODE                     VARCHAR2(30)
   , WAYBILL_AIRBILL_NUM                      VARCHAR2(80)
   , FREIGHT_BILL_NUM                         VARCHAR2(35)
   -- vendor_lot_num is defined as a non-db item in form
   -- however seems it is queried from db only and never changed thereafter ?
   , VENDOR_LOT_NUM                           VARCHAR2(30)
   , CONTAINER_NUM                            VARCHAR2(35)
   , TRUCK_NUM                                VARCHAR2(35)
   , BAR_CODE_LABEL                           VARCHAR2(35)
   , RATE_TYPE_DISPLAY                        VARCHAR2(30)
   , MATCH_OPTION                             VARCHAR2(25)
   , COUNTRY_OF_ORIGIN_CODE                   VARCHAR2(2)
   , OE_ORDER_HEADER_ID                       NUMBER
   , OE_ORDER_NUM                             NUMBER
   , OE_ORDER_LINE_ID                         NUMBER
   , OE_ORDER_LINE_NUM                        NUMBER
   , CUSTOMER_ID                              NUMBER
   , CUSTOMER_SITE_ID                         NUMBER
   , CUSTOMER_ITEM_NUM                        VARCHAR2(50)
   -- below are NON-DB Items
   , interface_transaction_id                 NUMBER
   , primary_quantity                         NUMBER
   , transaction_qty                     NUMBER
   , transaction_uom                          VARCHAR2(25)
   , receipt_exception                        NUMBER
   , comments                                 VARCHAR2(240)
   -- this field is set in receiving form ?
   , reason_id                                NUMBER
   , substitute_receipt                       VARCHAR2(30)
   , original_item_id                         NUMBER
   , locator_id                               NUMBER
   , subinventory_dsp                         VARCHAR2(10)
   , wip_entity_id                            NUMBER
   , wip_line_id                              NUMBER
   , department_code                          NUMBER
   , wip_repetitive_schedule_id               NUMBER
   , wip_operation_seq_num                    NUMBER
   , wip_resource_seq_num                     NUMBER
   , bom_resource_id                          NUMBER
   , destination_type_code_hold               VARCHAR2(30)
   , po_distribution_id                       NUMBER
   , lpn_id                                   NUMBER
   , transfer_lpn_id                          NUMBER
   , cost_group_id                            NUMBER
   , transfer_cost_group_id                   NUMBER
   , secondary_quantity                       NUMBER
   , secondary_uom_code                VARCHAR2(3)
   , secondary_unit_of_measure                VARCHAR2(25)
   );



 TYPE rcpt_lot_qty_rec IS RECORD
   (lot_number VARCHAR2(30),
    txn_quantity NUMBER);

 TYPE rcpt_lot_qty_rec_tb_tp IS TABLE OF rcpt_lot_qty_rec
   INDEX BY BINARY_INTEGER;


 g_rcpt_lot_qty_rec_tb rcpt_lot_qty_rec_tb_tp;

 g_shipment_header_id	   NUMBER := NULL;
 g_rcpt_match_table_gross  GML_RCV_TXN_INTERFACE.cascaded_trans_tab_type;   -- input for matching algorithm
 g_receipt_detail_index    NUMBER := 1;   -- index for the row needs to be detailed for matching

 g_dummy_lpn_id NUMBER := NULL;   -- dummy lpn_id for normal ASN receipt with the same from and to lpn


 g_po_line_location_id NUMBER := 0;   -- global variable for testing only ?
 g_po_distribution_id NUMBER := 0;


 /*******************************************************
*  Name: create_std_rcpt_intf_rec
*
*  Description:
*
*  This API is a wrapper to create record in RCV_TRANSACTIONS_INTERFACE for
*  different receipt transactions.
*
*  This API takes PO_header_id or Shipment_header_id, item_id, received_qty,
*  received_UOM, received_location as input. It calls the corresponding API
*  for different txns (PO, Intransit, RMA, ASN, Int-req).
*
*  The underlying APIs will call the matching algorithm API
*  to detail the receipt to PO_line_locations.
*  Then it calls insert API, insert_txn_interface, to inserts PO line
*  location record into RCV_TRANSACTION_INTERFACE
*
*  Flow:
*
*  1. query po_startup_value and other initial values
*  2. query RCV_ENTER_RECEIPTS_V to populate DB items in rcv_transaction block
*     before calling matching algorithm
*  3. call matching algorithm to detail the receipt
*  4. call insert API
*
*  Parameters:
*
*  p_move_order_header_id
*  p_organization_id
*  p_shipment_header_id
*  p_req_header_id
*  p_po_header_id
*  p_item_id
*  p_location_id
*  p_rcv_qty
*  p_rcv_uom
*  p_source_type
*  p_from_lpn_id
*  p_lpn_id
*  p_lot_control_code
*  p_revision
*
*******************************************************/


 PROCEDURE create_std_rcpt_intf_rec(p_move_order_header_id IN OUT NOCOPY NUMBER,
				    p_organization_id      IN     NUMBER,
				    p_po_header_id         IN     NUMBER,
				    p_po_release_number_id IN     NUMBER,
				    p_po_line_id           IN     NUMBER,
				    p_shipment_header_id   IN     NUMBER,
				    p_req_header_id        IN     NUMBER,
				    p_oe_order_header_id   IN     NUMBER,
				    p_item_id              IN     NUMBER,
				    p_location_id          IN     NUMBER,
				    p_rcv_qty              IN     NUMBER,
				    p_rcv_uom              IN     VARCHAR2,
				    p_rcv_uom_code         IN     VARCHAR2,
				    p_source_type          IN     VARCHAR2,
				    p_from_lpn_id          IN     NUMBER,
				    p_lpn_id               IN     NUMBER,
				    p_lot_control_code     IN     NUMBER,
				    p_revision             IN     VARCHAR2,
				    p_inspect              IN     NUMBER,
				    x_status                  OUT NOCOPY VARCHAR2,
				    x_message                 OUT NOCOPY VARCHAR2,
				    p_inv_item_id          IN     NUMBER DEFAULT NULL,
                                    p_item_desc            IN     VARCHAR2 DEFAULT NULL,
				    p_project_id	   IN     NUMBER DEFAULT NULL,
				    p_task_id		   IN     NUMBER DEFAULT NULL,
                                    p_country_code         IN     VARCHAR2 DEFAULT NULL
                                    );


  FUNCTION insert_txn_interface(
    p_rcv_transaction_rec  IN OUT NOCOPY  rcv_transaction_rec_tp
  , p_rcv_rcpt_rec         IN OUT NOCOPY  rcv_enter_receipts_rec_tp
  , p_group_id             IN             NUMBER
  , p_transaction_type     IN             VARCHAR2
  , p_organization_id      IN             NUMBER
  , p_location_id          IN             NUMBER
  , p_source_type          IN             VARCHAR2
  , p_qa_routing_id        IN             NUMBER DEFAULT -1
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  ) RETURN NUMBER;


PROCEDURE rcv_insert_update_header
  (p_organization_id        IN     NUMBER,
   p_shipment_header_id     IN OUT NOCOPY NUMBER,
   p_source_type            IN     VARCHAR2,
   p_receipt_num            IN OUT NOCOPY VARCHAR2,
   p_vendor_id              IN     NUMBER,
   p_vendor_site_id         IN     NUMBER,
   p_shipment_num           IN     VARCHAR2,
   p_ship_to_location_id    IN     NUMBER,
   p_bill_of_lading         IN     VARCHAR2,
   p_packing_slip           IN     VARCHAR2,
   p_shipped_date           IN     DATE,
   p_freight_carrier_code   IN     VARCHAR2,
   p_expected_receipt_date  IN     DATE,
   p_num_of_containers      IN     NUMBER,
   p_waybill_airbill_num    IN     VARCHAR2,
   p_comments               IN     VARCHAR2,
   p_ussgl_transaction_code IN     VARCHAR2,
   p_government_context     IN     VARCHAR2,
   p_request_id             IN     NUMBER,
   p_program_application_id IN     NUMBER,
   p_program_id             IN     NUMBER,
   p_program_update_date    IN     DATE,
   p_customer_id            IN     NUMBER,
   p_customer_site_id       IN     NUMBER,
   x_return_status       OUT       NOCOPY VARCHAR2,
   x_msg_count           OUT       NOCOPY NUMBER,
   x_msg_data            OUT       NOCOPY VARCHAR2
  );

/*
PROCEDURE   rcv_insert_header_interface
  (p_organization_id        IN     NUMBER,
   p_source_type            IN     VARCHAR2,
   p_receipt_num            IN OUT NOCOPY VARCHAR2,
   p_vendor_id              IN     NUMBER,
   p_vendor_site_id         IN     NUMBER,
   p_shipment_num           IN     VARCHAR2,
   p_ship_to_location_id    IN     NUMBER,
   p_bill_of_lading         IN     VARCHAR2,
   p_packing_slip           IN     VARCHAR2,
   p_shipped_date           IN     DATE,
   p_freight_carrier_code   IN     VARCHAR2,
   p_expected_receipt_date  IN     DATE,
   p_num_of_containers      IN     NUMBER,
   p_waybill_airbill_num    IN     VARCHAR2,
   p_comments               IN     VARCHAR2,
   p_ussgl_transaction_code IN     VARCHAR2,
   p_government_context     IN     VARCHAR2,
   p_request_id             IN     NUMBER,
   p_program_application_id IN     NUMBER,
   p_program_id             IN     NUMBER,
   p_program_update_date    IN     DATE,
   p_customer_id            IN     NUMBER,
   p_customer_site_id       IN     NUMBER,
   x_return_status       OUT       NOCOPY VARCHAR2,
   x_msg_count           OUT       NOCOPY NUMBER,
   x_msg_data            OUT       NOCOPY VARCHAR2
     );
*/

PROCEDURE rcv_update_rti_from_header
  (p_shipment_num                  VARCHAR,
   p_freight_carrier_code          VARCHAR2,
   p_bill_of_lading                VARCHAR2,
   p_packing_slip                  VARCHAR2,
   p_num_of_containers             NUMBER,
   p_waybill_airbill_num           VARCHAR2,
   x_return_status       OUT       NOCOPY VARCHAR2,
   x_msg_count           OUT       NOCOPY NUMBER,
   x_msg_data            OUT       NOCOPY VARCHAR2);





PROCEDURE create_move_order(p_move_order_header_id IN OUT NOCOPY NUMBER,
			    p_po_line_location_id  IN     NUMBER,
			    p_po_distribution_id   IN     NUMBER,
			    p_shipment_line_id     IN     NUMBER,
			    p_oe_order_line_id     IN     NUMBER,
			    p_routing              IN     VARCHAR2,
			    p_lot_control_code     IN     NUMBER,
			    p_org_id               IN     NUMBER,
			    p_item_id              IN     NUMBER,
			    p_qty                  IN     NUMBER,
			    p_uom_code             IN     VARCHAR2,
			    p_lpn                  IN     NUMBER,
			    p_project_id           IN     NUMBER   DEFAULT NULL,
			    p_task_id              IN     NUMBER   DEFAULT NULL,
			    p_revision             IN     VARCHAR2 DEFAULT NULL,
			    p_inspect              IN     NUMBER,
			    p_txn_source_id        IN     NUMBER,
			    x_status               OUT    NOCOPY VARCHAR2,
			    x_message              OUT    NOCOPY VARCHAR2,
			    p_transfer_org_id      IN     NUMBER   DEFAULT NULL,
			    p_wms_process_flag     IN     NUMBER   DEFAULT NULL
			    );

PROCEDURE create_mo_for_correction(p_move_order_header_id IN OUT NOCOPY NUMBER,
                p_po_line_location_id  IN     NUMBER DEFAULT NULL,
		p_po_distribution_id   IN     NUMBER DEFAULT NULL,
	        p_shipment_line_id     IN     NUMBER DEFAULT NULL,
		p_oe_order_line_id     IN     NUMBER DEFAULT NULL,
                p_routing              IN     NUMBER,
                p_lot_control_code     IN     NUMBER,
                p_org_id               IN     NUMBER,
                p_item_id              IN     NUMBER,
                p_qty                  IN     NUMBER,
                p_uom_code             IN     VARCHAR2,
                p_lpn                  IN     NUMBER,
                p_revision             IN     VARCHAR2 DEFAULT NULL,
                p_inspect              IN     NUMBER,
                p_txn_source_id        IN     NUMBER,
                x_status               OUT    NOCOPY VARCHAR2,
                x_message              OUT    NOCOPY VARCHAR2,
		p_transfer_org_id      IN     NUMBER   DEFAULT NULL,
		p_wms_process_flag     IN     NUMBER   DEFAULT NULL
	        );

PROCEDURE PackUnpack_Container
  (p_api_version   	    IN	    NUMBER                        ,
   p_init_msg_list	    IN	    VARCHAR2 := fnd_api.g_false   ,
   p_commit		    IN	    VARCHAR2 := fnd_api.g_false   ,
   x_return_status	    OUT	    NOCOPY VARCHAR2                      ,
   x_msg_count		    OUT	    NOCOPY NUMBER                        ,
   x_msg_data		    OUT	    NOCOPY VARCHAR2                      ,
   p_from_lpn_id            IN      NUMBER   := NULL              ,
   p_lpn_id		    IN	    NUMBER                        ,
   p_content_lpn_id	    IN	    NUMBER   := NULL              ,
   p_content_item_id	    IN	    NUMBER   := NULL              ,
   p_content_item_desc	    IN	    VARCHAR2 := NULL              ,
   p_revision		    IN	    VARCHAR2 := NULL              ,
   p_lot_number		    IN	    VARCHAR2 := NULL              ,
   p_from_serial_number	    IN	    VARCHAR2 := NULL              ,
   p_to_serial_number	    IN	    VARCHAR2 := NULL              ,
   p_quantity		    IN	    NUMBER   := NULL              ,
   p_uom		    IN	    VARCHAR2 := NULL              ,
   p_organization_id	    IN	    NUMBER                        ,
   p_subinventory	    IN	    VARCHAR2 := NULL              ,
   p_locator_id		    IN	    NUMBER   := NULL              ,
   p_enforce_wv_constraints IN	    NUMBER   := 2                 ,
   p_operation		    IN	    NUMBER                        ,
   p_cost_group_id          IN      NUMBER   := NULL              ,
   p_source_type_id         IN      NUMBER   := NULL              ,
   p_source_header_id       IN      NUMBER   := NULL              ,
   p_source_name            IN      VARCHAR2 := NULL              ,
   p_source_line_id         IN      NUMBER   := NULL              ,
   p_source_line_detail_id  IN      NUMBER   := NULL              ,
   p_homogeneous_container  IN      NUMBER   := 2                 ,
   p_match_locations        IN      NUMBER   := 2                 ,
   p_match_lpn_context      IN      NUMBER   := 2                 ,
   p_match_lot              IN      NUMBER   := 2                 ,
   p_match_cost_groups      IN      NUMBER   := 2                 ,
   p_match_mtl_status       IN      NUMBER   := 2
  );


PROCEDURE detect_ASN_discrepancy
  (p_shipment_header_id NUMBER,
   p_lpn_id NUMBER,
   p_po_header_id NUMBER,
   x_discrepancy_flag OUT NOCOPY NUMBER,
   x_return_status       OUT       NOCOPY VARCHAR2,
   x_msg_count           OUT       NOCOPY NUMBER,
   x_msg_data            OUT       NOCOPY VARCHAR2
  );


PROCEDURE transfer_lpn_contents
  (p_to_lpn_id   IN NUMBER,
   x_return_status       OUT       NOCOPY VARCHAR2,
   x_msg_count           OUT       NOCOPY NUMBER,
   x_msg_data            OUT       NOCOPY VARCHAR2
   );


-- Check if there are LPNs on this shipment
-- If there's LPN on this shipment, lpn_flag = 1, else lpn_flag = 0

PROCEDURE check_lpn_on_shipment
  (p_shipment_number IN VARCHAR2,
   p_from_organization_id IN NUMBER,
   p_to_organization_id IN NUMBER,
   x_lpn_flag OUT NOCOPY NUMBER,
   x_return_status       OUT       NOCOPY VARCHAR2,
   x_msg_count           OUT       NOCOPY NUMBER,
   x_msg_data            OUT       NOCOPY VARCHAR2
   );


-- Check if there are LPNs on this ASN
-- If there's LPN on this shipment, lpn_flag = 1, else lpn_flag = 0

PROCEDURE check_lpn_on_ASN
  (p_shipment_header_id IN VARCHAR2,
   x_lpn_flag OUT NOCOPY NUMBER,
   x_return_status       OUT       NOCOPY VARCHAR2,
   x_msg_count           OUT       NOCOPY NUMBER,
   x_msg_data            OUT       NOCOPY VARCHAR2
   );


PROCEDURE CHECK_LPN_ON_REQ (
                                p_req_num               IN  VARCHAR2,
                                x_lpn_flag              OUT NOCOPY NUMBER,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2
                          );

PROCEDURE update_LPN_Org
  (p_organization_id IN NUMBER,
   p_lpn_id IN NUMBER,
   x_return_status       OUT       NOCOPY VARCHAR2,
   x_msg_count           OUT       NOCOPY NUMBER,
   x_msg_data            OUT       NOCOPY VARCHAR2);

PROCEDURE remove_lpn_contents
  (p_lpn_id   IN NUMBER,
   x_return_status      OUT        NOCOPY VARCHAR2,
   x_msg_count          OUT        NOCOPY NUMBER,
   x_msg_data           OUT        NOCOPY VARCHAR2,
   p_routing_id         IN         NUMBER DEFAULT NULL
  );


PROCEDURE clear_LPN_for_ship
  (p_organization_id   IN NUMBER,
   p_shipment_header_id   IN NUMBER,
   x_return_status      OUT        NOCOPY VARCHAR2,
   x_msg_count          OUT        NOCOPY NUMBER,
   x_msg_data           OUT        NOCOPY VARCHAR2,
   p_routing_id         IN         NUMBER DEFAULT NULL
  );


PROCEDURE  populate_lot_rec
  (p_lot_number IN VARCHAR2,
   p_primary_qty IN NUMBER,
   p_txn_uom_code IN VARCHAR2,
   p_org_id NUMBER,
   p_item_id IN NUMBER);

END gml_rcv_std_rcpt_apis;

 

/
