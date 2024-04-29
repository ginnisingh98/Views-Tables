--------------------------------------------------------
--  DDL for Package INV_RCV_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_INTEGRATION_PVT" AUTHID CURRENT_USER AS
  /* $Header: INVRCVVS.pls 120.7.12010000.5 2012/08/23 10:52:57 raminoch ship $*/

TYPE child_record_info IS RECORD
  (orig_interface_trx_id NUMBER,
   new_interface_trx_id NUMBER,
   quantity NUMBER);

TYPE child_rec_tb_tp IS TABLE OF child_record_info
  INDEX BY BINARY_INTEGER;

-- 14408061
TYPE lpn_tbl_typ IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;
g_lpn_tbl lpn_tbl_typ;
-- 14408061

g_atf_api_complete     CONSTANT NUMBER := 1;
g_atf_api_cancel       CONSTANT NUMBER := 2;
g_atf_api_abort        CONSTANT NUMBER := 3;
g_atf_api_cleanup      CONSTANT NUMBER := 4;

-- Description
-- Wrapper to be used by PO
-- if the LPN_GROUP is null then all LPN columns should be null, if not null then fail
-- Loop through all the distinct lpn_groups for the passed request_id and group_id and
-- lpn_groupis not null
-- For the rows fetched  for each lpn_group call explode_lpn_contents
--

PROCEDURE Explode_lpn(p_request_id       IN         NUMBER,
                      p_group_id         IN  NUMBER );

--  Description
--  Procedure to Explode LPN when Iten info is Null
PROCEDURE Explode_lpn_contents(p_lpn_group_id     IN         NUMBER,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2);

--Description
--Procedure to call the appropriate ATF api
PROCEDURE call_atf_api(x_return_status OUT nocopy VARCHAR2,
		       x_msg_data OUT nocopy VARCHAR2,
		       x_msg_count OUT nocopy NUMBER,
		       x_error_code OUT nocopy NUMBER,
		       p_source_task_id IN NUMBER,
		       p_activity_type_id IN NUMBER,
		       p_operation_type_id IN NUMBER DEFAULT NULL,
		       p_mol_id IN NUMBER,
		       p_atf_api_name IN NUMBER,
		       p_mmtt_error_code   IN   VARCHAR2 DEFAULT NULL,
		       p_mmtt_error_explanation   IN   VARCHAR2 DEFAULT NULL,
		       p_retain_mmtt IN VARCHAR2 DEFAULT 'N');
--  Description
--  Procedure to Validate LPN for each LPN group.
PROCEDURE Validate_lpn_info(p_lpn_group_id    IN         NUMBER,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2);

-- Description
-- Inserts a row in WLPNI
--
PROCEDURE insert_wlpni(p_LPN_ID                   IN NUMBER ,
		       p_LICENSE_PLATE_NUMBER     IN VARCHAR2 DEFAULT NULL,
		       p_PARENT_LPN_ID                 IN NUMBER DEFAULT NULL,
		       p_PARENT_LICENSE_PLATE_NUMBER   IN VARCHAR2 DEFAULT NULL,
		       p_REQUEST_ID                    IN NUMBER   DEFAULT NULL,
		       p_INVENTORY_ITEM_ID             IN NUMBER   DEFAULT NULL,
		       p_REVISION                      IN VARCHAR2 DEFAULT NULL,
		       p_LOT_NUMBER                    IN VARCHAR2 DEFAULT NULL,
		       p_SERIAL_NUMBER                 IN VARCHAR2 DEFAULT NULL,
		       p_ORGANIZATION_ID               IN NUMBER ,
		       p_SUBINVENTORY_CODE             IN VARCHAR2 DEFAULT NULL,
		       p_LOCATOR_ID                    IN NUMBER   DEFAULT NULL,
		       p_GROSS_WEIGHT_UOM_CODE         IN VARCHAR2 DEFAULT NULL,
		       p_GROSS_WEIGHT                  IN NUMBER   DEFAULT NULL,
		       p_CONTENT_VOLUME_UOM_CODE       IN VARCHAR2 DEFAULT NULL,
		       p_CONTENT_VOLUME                IN NUMBER   DEFAULT NULL,
  p_TARE_WEIGHT_UOM_CODE          IN VARCHAR2 DEFAULT NULL,
  p_TARE_WEIGHT                   IN NUMBER   DEFAULT NULL,
  p_STATUS_ID                     IN NUMBER   DEFAULT NULL,
  p_SEALED_STATUS                 IN NUMBER   DEFAULT NULL,
  p_ATTRIBUTE_CATEGORY            IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE1                    IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE2                    IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE3                    IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE4                    IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE5                    IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE6                    IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE7                    IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE8                    IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE9                    IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE10                   IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE11                   IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE12                   IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE13                   IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE14                   IN VARCHAR2 DEFAULT NULL,
  p_ATTRIBUTE15                   IN VARCHAR2 DEFAULT NULL,
  p_COST_GROUP_ID                 IN NUMBER   DEFAULT NULL,
  p_LPN_CONTEXT                   IN NUMBER   DEFAULT NULL,
  p_LPN_REUSABILITY               IN NUMBER   DEFAULT NULL,
  p_OUTERMOST_LPN_ID              IN NUMBER   DEFAULT NULL,
  p_outermost_lpn                 IN VARCHAR2 DEFAULT NULL,
  p_HOMOGENEOUS_CONTAINER         IN NUMBER   DEFAULT NULL,
  p_SOURCE_TYPE_ID                IN NUMBER   DEFAULT NULL,
  p_SOURCE_HEADER_ID              IN NUMBER   DEFAULT NULL,
  p_SOURCE_LINE_ID                IN NUMBER   DEFAULT NULL,
  p_SOURCE_LINE_DETAIL_ID         IN NUMBER   DEFAULT NULL,
  p_SOURCE_NAME                   IN VARCHAR2 DEFAULT NULL,
  p_LPN_GROUP_ID                  IN NUMBER,
  x_return_status                 OUT NOCOPY VARCHAR2,
  x_msg_count                     OUT NOCOPY NUMBER,
  x_msg_data                      OUT NOCOPY VARCHAR2);


--  Description
--  Splits LOT/SERIAL
PROCEDURE split_lot_serial(p_rti_tb         IN  inv_rcv_integration_apis.child_rec_tb_tp,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2);

PROCEDURE validate_lpn_locator( p_lpn_id           IN NUMBER,
                                p_subinventory     IN VARCHAR2,
                                p_locator_id       IN NUMBER,
                                p_organization_id  IN NUMBER,
                                x_lpn_match        OUT NOCOPY VARCHAR2,
                                x_return_status    OUT NOCOPY VARCHAR2,
                                x_msg_count        OUT NOCOPY NUMBER,
                                x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE process_txn(p_txn_id                   IN NUMBER,
                      x_return_status            OUT NOCOPY VARCHAR2,
                      x_msg_count                OUT NOCOPY NUMBER,
                      x_msg_data                 OUT NOCOPY VARCHAR2
                     ) ;

function get_primary_qty(
                p_organization_id       IN      NUMBER,
                p_inventory_item_id     IN      NUMBER,
                p_uom                   IN      VARCHAR2,
                p_quantity              IN      NUMBER,
		p_lot_number            IN      VARCHAR2 DEFAULT NULL) return number; --Bug#9570776

--  Description
--  Split the RTI based on the parent RT and
--  also update the parent_transaction_id information in RTI rows
--PROCEDURE Txn_match(p_group_id         IN         NUMBER,
--                    x_return_status    OUT NOCOPY VARCHAR2,
--                    x_msg_count        OUT NOCOPY NUMBER,
--                    x_msg_data         OUT NOCOPY VARCHAR2);
--



--  Description
--  Validate the LPN Status/ Lock the LPN row if needed
--PROCEDURE Check_lpn_status   (p_group_id         IN  NUMBER default null,
--                              p_lpn_group_id     IN NUMBER default null,
--                              x_return_status    OUT NOCOPY VARCHAR2,
--                              x_msg_count        OUT NOCOPY NUMBER,
--                              x_msg_data         OUT NOCOPY VARCHAR2);
--
--TYPE cas_trans_rec_type IS RECORD
--  (
--   transaction_id NUMBER,
--   primary_quantity NUMBER
--  );

--TYPE trans_rec_tb_tp IS TABLE OF cas_trans_rec_type
--  INDEX BY BINARY_INTEGER;

--  Description
--  Gets the LOT/SERIAL CONTROL CODE
--  Splits MTLI/ MSNI
--  Creates new MTLT / MSNT
--PROCEDURE break(p_org_tid IN NUMBER,
--                p_new_transactions_tb IN trans_rec_tb_tp
--               );
--
--
-- Description
-- Pack Unpack Container
-- Update subinv/locator
-- Create MOL
-- Call ATF API

--PROCEDURE packunpack_complete ( p_transaction_id IN NUMBER);
--
--
--
-- Description
-- update lpn_id and transfer_lpn_id based on license_plate_number
-- and transfer_license_plate_number in RTI .

--PROCEDURE update_lpn_id ( p_lpn_group_id IN NUMBER);
--


-- Procedure validate_lot_Serial_info to validate lot/serial
-- information entered on receiving interface.
PROCEDURE VALIDATE_LOT_SERIAL_INFO (P_RTI_ID IN NUMBER,
			       	    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
			            X_MSG_COUNT OUT NOCOPY NUMBER,
			            X_MSG_DATA OUT NOCOPY VARCHAR2);

TYPE cas_mol_rec_type IS RECORD
  (  transaction_type       VARCHAR2(25)
    ,organization_id        NUMBER
    ,lpn_id                 NUMBER
    ,inventory_item_id      NUMBER
    ,lot_number             VARCHAR2(80)
    ,item_revision          VARCHAR2(3)
    ,from_subinventory_code VARCHAR2(10)
    ,from_locator_id        NUMBER
    ,cost_group_id          NUMBER
    ,project_id             NUMBER
    ,task_id                NUMBER
    ,uom_code               VARCHAR2(3)
    ,backorder_delivery_detail_id NUMBER
    ,crossdock_type         NUMBER
    ,inspection_status      NUMBER
    ,quantity               NUMBER
    ,secondary_quantity     NUMBER
    ,secondary_uom          VARCHAR2(3)
    ,transfer_org_id        NUMBER
    ,line_id                NUMBER
    ,primary_qty            NUMBER
    ,primary_uom_code       VARCHAR2(3)
    ,po_header_id           NUMBER
    ,po_line_location_id    NUMBER
    ,shipment_line_id       NUMBER
    ,requisition_line_id    NUMBER
    ,auto_transact_code     VARCHAR2(25)
    ,wip_supply_type        NUMBER
    ,routing_header_id      NUMBER
    ,source_document_code   varchar2(25)
    ,parent_transaction_id  NUMBER
    ,parent_txn_type        VARCHAR2(25)
    ,grand_parent_txn_type  VARCHAR2(25)
    ,call_atf_api           NUMBER --used for DELIVER
    ,mmtt_id                NUMBER --used for DELIVER
    ,asn_line_flag          VARCHAR2(1)
    ,subinventory_code      VARCHAR2(10) --xfer sub. Used for deliver
    ,locator_id             NUMBER       --xfer sub. Used for deliver
  );

TYPE cas_mol_rec_tb_tp IS TABLE OF cas_mol_rec_type
  INDEX BY BINARY_INTEGER;

PROCEDURE insert_mtli(p_product_transaction_id  IN NUMBER,
                      p_product_code                      IN VARCHAR2,
                      p_interface_id                      IN NUMBER,
                      p_org_id                            IN NUMBER,
                      p_item_id                           IN NUMBER,
                      p_lot_number                        IN VARCHAR2,
                      p_transaction_quantity              IN NUMBER,
                      p_primary_quantity                  IN NUMBER,
                      p_serial_interface_id               IN NUMBER,
                      x_return_status                     OUT NOCOPY VARCHAR2,
                      x_msg_count                         OUT NOCOPY NUMBER,
                      x_msg_data                          OUT NOCOPY VARCHAR2,
                      p_sec_qty                           IN NUMBER DEFAULT NULL
		      );

--  Description
/*
This processdure validates the LPN to restrict multiple users doing transactions on same LPN
Added for the Bug:13613257
*/

PROCEDURE Validate_Receiving_LPN(p_lpn_id    IN         NUMBER,
                      p_routing_id     IN         NUMBER,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2
					  );

END inv_rcv_integration_pvt;

/
