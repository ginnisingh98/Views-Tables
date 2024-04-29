--------------------------------------------------------
--  DDL for Package INV_RCV_COMMON_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_COMMON_APIS" AUTHID CURRENT_USER AS
/* $Header: INVRCVCS.pls 120.8.12010000.6 2011/03/02 07:00:40 rdudani ship $*/

-- Added two new global variables to store the values for the po, WMS and inv
-- patch LEVEL.
-- Since we are hard prereqing PO ARU we do not need to check if PO.J is
-- installed. However, since all the code already is using it all we need
-- to do is assign it the value of g_inv_patch_level since if inv.J or
-- higher is installed, it will imply the PO.J functionality exists.
g_po_patch_level  NUMBER := inv_control.Get_Current_Release_Level;
g_inv_patch_level NUMBER := inv_control.Get_Current_Release_Level;
g_wms_patch_level NUMBER := wms_control.Get_Current_Release_Level;

-- Added global constant to identify patchset J
g_patchset_j      NUMBER := 110510;
g_patchset_j_po   NUMBER := 110510;


/*
 * FP-J Lot/Serial Support Enhancement
 * Added lot_number with default NULL value. Used for matching lots
 */
TYPE cascaded_trans_rec_type IS RECORD
  (
   customer_id NUMBER,
   error_message VARCHAR2(255),
   error_status VARCHAR2(1),
   expected_receipt_date DATE,
   from_organization_id NUMBER,
   group_id NUMBER,
   item_id NUMBER,
   locator_id NUMBER,
   oe_order_header_id NUMBER,
   oe_order_line_id NUMBER,
   parent_transaction_id NUMBER,
   po_distribution_id NUMBER,
   po_header_id NUMBER,
   po_line_id NUMBER,
   po_line_location_id NUMBER,
   po_release_id NUMBER,
   primary_quantity NUMBER,
   primary_unit_of_measure VARCHAR2(25),
   qty_rcv_exception_code VARCHAR2(25),
   quantity NUMBER,
   quantity_shipped NUMBER,
   revision VARCHAR2(3),
   ship_to_location_id NUMBER,
   shipment_header_id NUMBER,
   shipment_line_id NUMBER,
   source_doc_quantity NUMBER,
   source_doc_unit_of_measure VARCHAR2(25),
   subinventory VARCHAR2(10),
   tax_amount NUMBER,
   to_organization_id NUMBER,
   transaction_type VARCHAR2(25),
   unit_of_measure VARCHAR2(25),
   inspection_status_code VARCHAR2(25),
   p_lpn_id NUMBER,
   item_desc VARCHAR2(240),
   project_id number default null,
   task_id   number  default null,
   lot_number mtl_lot_numbers.lot_number%TYPE DEFAULT NULL,
   serial_number mtl_serial_numbers.serial_number%TYPE DEFAULT NULL --9651496,9764650
   );

TYPE cascaded_trans_tab_type IS TABLE OF cascaded_trans_rec_type
  INDEX BY BINARY_INTEGER;

-- po_startup_value block record type
 TYPE po_startup_value_tp IS RECORD
   (inv_org_id           NUMBER, --bug 5195963
    org_name             VARCHAR2(240),
    org_location         VARCHAR2(60),
    sob_id               NUMBER,
    ussgl_value          VARCHAR2(60),
    period_name          VARCHAR2(60),
    gl_date              DATE,
    category_set_id      NUMBER,
    structure_id         NUMBER,
    user_id              NUMBER,
    logon_id             NUMBER,
    creation_date        DATE,
    update_date          DATE,
    inv_status           VARCHAR2(1),
    po_status            VARCHAR2(1),
    qa_status            VARCHAR2(1),
    wip_status           VARCHAR2(1),
    pa_status            VARCHAR2(1),
    oe_status            VARCHAR2(1),
    override_routing     VARCHAR2(60),
    transaction_mode     VARCHAR2(60),
    receipt_traveller    VARCHAR2(60),
    receipt_num_code     VARCHAR2(60),
    receipt_num_type     VARCHAR2(60),
    po_num_type          VARCHAR2(60),
    coa_id               NUMBER,
    allow_express        VARCHAR2(1),
    allow_cascade        VARCHAR2(1),
    org_locator_control  NUMBER,
    negative_inv_receipt_code  NUMBER,
    gl_set_of_bks_id      VARCHAR2(60),
    blind_receiving_flag  VARCHAR2(1),
    allow_unordered       VARCHAR2(1),
   display_inverse_rate  VARCHAR2(60),
   currency_code         VARCHAR2(60),
   project_reference_enabled   NUMBER,
   project_control_level       NUMBER,
   employee_id           NUMBER,
   wms_install_status    VARCHAR2(1),
   wms_purchased         VARCHAR2(1),
   effectivity_control   NUMBER);

 -- po_startup_value block
 g_po_startup_value po_startup_value_tp;


-- rcv_global_var block record type
TYPE rcv_global_var_tp IS RECORD
  (interface_group_id        NUMBER,
   transaction_header_id     NUMBER,
   receipt_num               NUMBER,
   unordered_mode            VARCHAR2(30),
   receiving_dsp_val         VARCHAR2(80),
   express_mode              VARCHAR2(30));

g_rcv_global_var  rcv_global_var_tp;

-- We use the following data structure to store new lot numbers created
-- at receipt time.
TYPE lot_status_rec IS RECORD
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
  (lot_number VARCHAR2(80),
   inventory_item_id NUMBER,
   organization_id NUMBER
   );
TYPE lot_status_rec_tb_tp IS TABLE OF lot_status_rec
  INDEX BY BINARY_INTEGER;

g_lot_status_tb lot_status_rec_tb_tp;


-- We use the following data structure to store lpn_id used in this transaction cycle
TYPE lpn_id_tb_tp IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

g_lpn_id_tb lpn_id_tb_tp;


TYPE trans_rec_type IS RECORD
  (transaction_id NUMBER,
   primary_quantity NUMBER,
   secondary_quantity NUMBER --invconv kkillams
   );

TYPE trans_rec_tb_tp IS TABLE OF trans_rec_type
  INDEX BY BINARY_INTEGER;

--These constants  are used  by the  break api in
--determining the order in  which  lots are split
g_order_lots_by_exp_date NUMBER := 1;
g_order_lots_by_creation_date   NUMBER := 2;

g_order_lots_by NUMBER := g_order_lots_by_exp_date;--Default is by  exp date

PROCEDURE init_form_values(p_org_id              IN  NUMBER,
                           x_inv_org_id          OUT NOCOPY NUMBER, --bug 5195963
			   x_org_name            OUT NOCOPY VARCHAR2,
			   x_org_location        OUT NOCOPY VARCHAR2,
			   x_sob_id              OUT NOCOPY NUMBER,
			   x_ussgl_value         OUT NOCOPY VARCHAR2,
			   x_period_name         OUT NOCOPY VARCHAR2,
			   x_gl_date             OUT NOCOPY DATE,
			   x_category_set_id     OUT NOCOPY NUMBER,
			   x_structure_id        OUT NOCOPY NUMBER,
			   x_user_id             OUT NOCOPY NUMBER,
			   x_logon_id            OUT NOCOPY NUMBER,
			   x_creation_date       OUT NOCOPY DATE,
			   x_update_date         OUT NOCOPY DATE,
			   x_inv_status          OUT NOCOPY VARCHAR2,
			   x_po_status           OUT NOCOPY VARCHAR2,
			   x_qa_status           OUT NOCOPY VARCHAR2,
			   x_wip_status          OUT NOCOPY VARCHAR2,
			   x_pa_status           OUT NOCOPY VARCHAR2,
			   x_oe_status           OUT NOCOPY VARCHAR2,
			   x_override_routing    OUT NOCOPY VARCHAR2,
			   x_transaction_mode    OUT NOCOPY VARCHAR2,
			   x_receipt_traveller   OUT NOCOPY VARCHAR2,
			   x_receipt_num_code    OUT NOCOPY VARCHAR2,
			   x_receipt_num_type    OUT NOCOPY VARCHAR2,
			   x_po_num_type         OUT NOCOPY VARCHAR2,
			   x_coa_id              OUT NOCOPY NUMBER,
			   x_allow_express       OUT NOCOPY VARCHAR2,
			   x_allow_cascade       OUT NOCOPY VARCHAR2,
			   x_org_locator_control OUT NOCOPY NUMBER,
			   x_negative_inv_receipt_code OUT NOCOPY NUMBER,
			   x_gl_set_of_bks_id     OUT NOCOPY VARCHAR2,
			   x_blind_receiving_flag OUT NOCOPY VARCHAR2,
			   x_allow_unordered      OUT NOCOPY VARCHAR2,
			   x_display_inverse_rate OUT NOCOPY VARCHAR2,
			   x_currency_code        OUT NOCOPY VARCHAR2,
			   x_project_reference_enabled  OUT NOCOPY NUMBER,
                           x_project_control_level      OUT NOCOPY NUMBER,
                           x_effectivity_control  OUT NOCOPY NUMBER,
                           x_employee_id          OUT NOCOPY NUMBER,
                           x_wms_install_status   OUT NOCOPY VARCHAR2,
                           x_wms_purchased        OUT NOCOPY VARCHAR2,
                           x_message              OUT NOCOPY VARCHAR2
                           );

-- a wrapper of the above to initialize global g_startup_value block

PROCEDURE init_startup_values(p_organization_id IN NUMBER);

-- Overloaded the procedure. This will be called from patchset J development.
PROCEDURE init_rcv_ui_startup_values(p_organization_id       IN NUMBER,
				     x_org_id               OUT NOCOPY NUMBER,
				     x_org_location         OUT NOCOPY VARCHAR2,
				     x_org_locator_control  OUT NOCOPY NUMBER,
				     x_manual_po_num_type   OUT NOCOPY VARCHAR2,
				     x_wms_install_status   OUT NOCOPY VARCHAR2,
				     x_wms_purchased        OUT NOCOPY VARCHAR2,
				     x_return_status        OUT NOCOPY VARCHAR2,
				     x_msg_data             OUT NOCOPY VARCHAR2,
				     x_inv_patch_level      OUT NOCOPY NUMBER,
				     x_po_patch_level       OUT NOCOPY NUMBER,
				     x_wms_patch_level      OUT NOCOPY NUMBER);

PROCEDURE init_rcv_ui_startup_values(p_organization_id       IN NUMBER,
				     x_org_id               OUT NOCOPY NUMBER,
				     x_org_location         OUT NOCOPY VARCHAR2,
				     x_org_locator_control  OUT NOCOPY NUMBER,
				     x_manual_po_num_type   OUT NOCOPY VARCHAR2,
				     x_wms_install_status   OUT NOCOPY VARCHAR2,
				     x_wms_purchased        OUT NOCOPY VARCHAR2,
				     x_return_status        OUT NOCOPY VARCHAR2,
				     x_msg_data             OUT NOCOPY VARCHAR2);

-- break lot/serial record for transaction record

PROCEDURE break
  (p_original_tid        IN mtl_transaction_lots_temp.transaction_temp_id%TYPE,
   p_new_transactions_tb IN trans_rec_tb_tp,
   p_lot_control_code    IN NUMBER,
   p_serial_control_code IN NUMBER);

--PROCEDURE rcv_process_receive_txn;

PROCEDURE rcv_gen_receipt_num
  (x_receipt_num        OUT NOCOPY VARCHAR2,
   p_organization_id IN     NUMBER,
   x_return_status      OUT        NOCOPY VARCHAR2,
   x_msg_count          OUT        NOCOPY NUMBER,
   x_msg_data           OUT        NOCOPY VARCHAR2);



PROCEDURE rcv_clear_global;



/*************************************************
* Name: get_po_routing_id
* This API returns routing id for a given PO header ID
* Routing ID is defined at PO line-location level (po_line_locations_all)
* We use the following rule to set headers routing ID
* If there is one line detail needs inspection the entire PO needs inspection
* elsif there is one line detail needs direct receiving the entire PO direct
* else (all line detail are standard) the entire PO is standard
* rounting lookups: 1. standard   2. Inspect  3. Direct

******************************************************/


PROCEDURE get_po_routing_id (x_po_routing_id    OUT NOCOPY NUMBER,
			     x_is_expense       OUT NOCOPY VARCHAR2,
			     p_po_header_id  IN     NUMBER,
			     p_po_release_id IN     NUMBER,
			     p_po_line_id    IN     NUMBER,
			     p_item_id       IN     NUMBER,
			     p_item_desc     IN     VARCHAR2 DEFAULT NULL,
                             p_organization_id  IN  NUMBER   DEFAULT NULL);  -- Bug 8242448


/*************************************************
* Name: get_routing_id
* This API returns routing id for a given PO header ID or shipment header
* id or for the rma
* It also validates the lpn_context and the routing id
* The LPN Context can only be pregenerated and resides in inventory
* for a direct receipt and for others it can be in receiving and pregenerated.
******************************************************/
PROCEDURE get_routing_id (x_routing_id         OUT    NOCOPY NUMBER,
			  x_return_status      OUT    NOCOPY VARCHAR2,
			  x_msg_count          OUT    NOCOPY NUMBER,
			  x_msg_data           OUT    NOCOPY VARCHAR2,
			  x_is_expense         OUT    NOCOPY VARCHAR2,
			  p_po_header_id       IN     NUMBER,
			  p_po_release_id      IN     NUMBER,
			  p_po_line_id         IN     NUMBER,
			  p_shipment_header_id IN     NUMBER,
			  p_oe_order_header_id IN     NUMBER,
			  p_item_id            IN     NUMBER,
			  p_organization_id    IN     NUMBER,
			  p_vendor_id          IN     NUMBER,
			  p_lpn_id             IN     NUMBER   DEFAULT NULL,
			  p_item_desc          IN     VARCHAR2 DEFAULT NULL,
                          p_from_lpn_id        IN     NUMBER DEFAULT NULL,
                          p_project_id         IN     NUMBER DEFAULT NULL,
                          p_task_id            IN     NUMBER DEFAULT NULL);





/*************************************************
* Name: get_asn_routing_id
* This API returns routing id for a given shipment_header_ID,
* lpn_id, po_header_id combination.
* PO_header_id, po_line_id and item_id are queried based on the combination,
* and then passed to get_po_routing_id.
* If any of the lines has a direct routing, this API will return direct.
*******************************************************/

  PROCEDURE get_asn_routing_id
  (x_asn_routing_id     OUT NOCOPY NUMBER,
   x_return_status      OUT    NOCOPY VARCHAR2,
   x_msg_count          OUT    NOCOPY NUMBER,
   x_msg_data           OUT    NOCOPY VARCHAR2,
   p_shipment_header_id IN NUMBER,
   p_lpn_id             IN NUMBER,
   p_po_header_id       IN NUMBER
   );




/*********************************************
*  This api first checks if lpn exists or not by calling validate_LPN api.
*  If yes, it simply returns the lpnID,
*  If not, it calls create_LPN api and return the lpnID
********************************************************/

PROCEDURE create_lpn(p_organization_id IN     NUMBER,
		     p_lpn             IN     VARCHAR2,
		     p_lpn_ID             OUT NOCOPY NUMBER,
		     x_return_status      OUT NOCOPY VARCHAR2,
		     x_msg_data           OUT NOCOPY VARCHAR2);



-- This api creates a record in the mtl_transaction_lots_temp
-- It checks if the p_transaction_temp_id is null, if it is, then it
-- generates a new id and returns that.
PROCEDURE insert_lot(p_transaction_temp_id        IN OUT NOCOPY NUMBER,
		     p_created_by                 IN     NUMBER,
		     p_transaction_qty            IN     NUMBER,
		     p_primary_qty                IN     NUMBER,
		     p_lot_number                 IN     VARCHAR2,
		     p_expiration_date            IN     DATE,
		     p_status_id                  IN     NUMBER := NULL,
		     x_serial_transaction_temp_id    OUT NOCOPY NUMBER,
		     x_return_status                 OUT NOCOPY VARCHAR2,
		     x_msg_data                      OUT NOCOPY VARCHAR2,
                     p_secondary_quantity         IN     NUMBER DEFAULT null--OPM Convergence
          );

-- This api creates a record in the mtl_transaction_serial_temp
-- It checks if the p_transaction_temp_id is null, if it is, then it
-- generates a new id and returns that.
PROCEDURE insert_serial(p_serial_transaction_temp_id IN OUT NOCOPY NUMBER,
			p_org_id                     IN     NUMBER,
			p_item_id                    IN     NUMBER,
			p_rev                        IN     VARCHAR2,
			p_lot                        IN     VARCHAR2,
			p_txn_src_id                 IN     NUMBER,
			p_txn_action_id              IN     NUMBER,
			p_created_by                 IN     NUMBER,
			p_from_serial                IN     VARCHAR2,
			p_to_serial                  IN     VARCHAR2,
			p_status_id                  IN     NUMBER := NULL,
			x_return_status                 OUT NOCOPY VARCHAR2,
			x_msg_data                      OUT NOCOPY VARCHAR2);

-- Bug 8892966
-- Added procedure get_rma_uom_code
PROCEDURE get_rma_uom_code(x_return_status      OUT NOCOPY VARCHAR2,
               x_uom_code           OUT NOCOPY VARCHAR2,
               p_order_header_id    IN     NUMBER,
               p_item_id            IN     NUMBER,
               p_organization_id    IN     NUMBER);
-- Bug 8892966

-- Bug 8892966
-- Added procedure get_asn_uom_code
PROCEDURE get_asn_uom_code(x_return_status      OUT NOCOPY VARCHAR2,
               x_uom_code           OUT NOCOPY VARCHAR2,
               p_shipment_header_id IN     NUMBER,
               p_item_id            IN     NUMBER,
               p_organization_id    IN     NUMBER);
-- Bug 8892966

-- Bug 8892966
PROCEDURE get_asn_uom_code(
     x_return_status      OUT NOCOPY    VARCHAR2
   , x_uom_code           OUT NOCOPY    VARCHAR2
   , p_shipment_header_id IN            NUMBER
   , p_item_id            IN            NUMBER
   , p_organization_id    IN            NUMBER
   , P_item_desc          IN            Varchar2
   );
-- Bug 8892966

--BUG#3062591
--This api used to return the default UOM value from purchaseorderlines
--whenjust item is entered in the Mobile Receipt page.
--UOM is defaulted in the following way.
--if a single line for the item exist, api will return the UoM based on PO line.
--if multiple lines for the same item  exist with same UoM, api will return
--this UoM.
--multiple lines for the same item exist with  different UoM, api will not
--return any UOM and just '@@@'
PROCEDURE get_uom_code(x_return_status      OUT NOCOPY VARCHAR2,
		       x_uom_code           OUT NOCOPY VARCHAR2,
         	       p_po_header_id       IN     NUMBER,
                       p_item_id            IN     NUMBER,
		       p_organization_id    IN     NUMBER,
		       p_line_no            IN     NUMBER DEFAULT NULL,  --BUG 4500676
		       p_item_desc          IN     VARCHAR2 DEFAULT NULL --BUG 4500676
		       );
--Bug #3285227
-- This api is used to return the possible value that can be used for
-- subinventory when the item and PO/Shipment Number/RMA are entered.
-- For RMA it always returns null for subinventory.
-- Overloaded this procedure by adding two new OUT parameters
--    -> x_lpn_context    - Stores context of the LPN passed
--    -> x_default_source - Stores the defaulting source
-- This version is called from RcptGenFListener.java if
--  WMS and PO patch levels are J or higher. For all other cases,
--  the older implementation is called.
PROCEDURE get_sub_code(
           x_return_status      OUT NOCOPY VARCHAR2,
		       x_msg_count          OUT NOCOPY NUMBER,
		       x_msg_data           OUT NOCOPY VARCHAR2,
		       x_sub_code           OUT NOCOPY VARCHAR2,
		       x_locator_segs       OUT NOCOPY VARCHAR2,
		       x_locator_id         OUT NOCOPY NUMBER,
           x_lpn_context        OUT NOCOPY NUMBER,
           x_default_source     OUT NOCOPY VARCHAR2,
		       p_po_header_id       IN         NUMBER,
		       p_po_release_id      IN         NUMBER,
		       p_po_line_id         IN         NUMBER,
		       p_shipment_header_id IN         NUMBER,
		       p_oe_order_header_id IN         NUMBER,
		       p_item_id            IN         NUMBER,
		       p_organization_id    IN         NUMBER,
		       p_lpn_id             IN         NUMBER DEFAULT NULL,
           p_project_id         IN         NUMBER DEFAULT NULL,
           p_task_id            IN         NUMBER DEFAULT NULL);

-- This api is used to return the possible value that can be used for
-- subinventory when the item and PO/Shipment Number/RMA are entered.
PROCEDURE get_sub_code(
           x_return_status      OUT NOCOPY VARCHAR2,
		       x_msg_count          OUT NOCOPY NUMBER,
		       x_msg_data           OUT NOCOPY VARCHAR2,
		       x_sub_code           OUT NOCOPY VARCHAR2,
		       x_locator_segs       OUT NOCOPY VARCHAR2,
		       x_locator_id         OUT NOCOPY NUMBER,
		       p_po_header_id       IN         NUMBER,
		       p_po_release_id      IN         NUMBER,
		       p_po_line_id         IN         NUMBER,
		       p_shipment_header_id IN         NUMBER,
		       p_oe_order_header_id IN         NUMBER,
		       p_item_id            IN         NUMBER,
		       p_organization_id    IN         NUMBER,
		       p_lpn_id             IN         NUMBER DEFAULT NULL,
           p_project_id         IN         NUMBER DEFAULT NULL,
           p_task_id            IN         NUMBER DEFAULT NULL);

-- This api calls inventory api to insert a range serial

--Bug 3890706 - Added the procedure to default the location
-- 	        if line number or item is entered during the receipt

PROCEDURE get_location_code
(
 x_return_status      OUT NOCOPY VARCHAR2,
 x_location_code      OUT NOCOPY VARCHAR2,
 p_po_header_id       IN         NUMBER,
 p_item_id            IN         NUMBER,
 p_po_line_id         IN         NUMBER,
 p_po_release_id      IN         NUMBER,
 p_organization_id    IN 	 NUMBER,
 p_shipment_header_id IN         NUMBER DEFAULT NULL,  --BUG 5124472 (FP of BUG 5117987)
 p_from_lpn_id        IN         NUMBER DEFAULT NULL); --BUG 5124472 (FP of BUG 5117987)

--End of fix for Bug  3890706

--Bug 4003683 - Added the procedure to default the revision for the item.

PROCEDURE GET_REVISION_CODE(
      x_return_status      OUT NOCOPY VARCHAR2,
      x_revision_code      OUT NOCOPY VARCHAR2,
      p_document_type      IN  VARCHAR2 DEFAULT NULL,
      p_po_header_id       IN  NUMBER   DEFAULT NULL,
      p_po_line_id         IN  NUMBER   DEFAULT NULL,
      p_po_release_id      IN  NUMBER   DEFAULT NULL,
      p_req_header_id      IN  NUMBER   DEFAULT NULL,
      p_shipment_header_id IN  NUMBER   DEFAULT NULL,
      p_item_id            IN  NUMBER   DEFAULT NULL,
      p_organization_id    IN  NUMBER,
       p_oe_order_header_id IN  NUMBER DEFAULT NULL -- Bug #:5768262 Added parameter p_oe_order_header_id to default the revision of item for RMA
    )  ;

--End of fix for Bug 4003683

PROCEDURE insert_range_serial
  (p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id  IN NUMBER,
   p_organization_id    IN NUMBER,
   p_from_serial_number IN VARCHAR2,
   p_to_serial_number   IN VARCHAR2,
   p_revision           IN VARCHAR2,
   p_lot_number         IN VARCHAR2,
   p_primary_lot_quantity IN NUMBER,
   p_transaction_action_id IN NUMBER,
   p_current_status     IN NUMBER,
   p_serial_status_id   IN  NUMBER,
   p_update_serial_status IN VARCHAR2,
   p_inspection_required IN NUMBER DEFAULT NULL,
   p_hdr_id             IN  NUMBER,
   p_from_lpn_id        IN  NUMBER,
   p_to_lpn_id          IN  NUMBER,
   p_primary_uom_code   IN  VARCHAR2,
   p_call_pack_unpack   IN  VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_subinventory       IN VARCHAR2 DEFAULT NULL,
   p_locator_id         IN NUMBER DEFAULT NULL);


-- This api updates the current_status for a range of serials

PROCEDURE update_serial_status
  (p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id  IN  NUMBER,
   p_organization_id    IN  NUMBER,
   p_from_serial_number IN  VARCHAR2,
   p_to_serial_number   IN  VARCHAR2,
   p_current_status     IN  NUMBER,
   p_serial_status_id   IN  NUMBER,
   p_update_serial_status IN VARCHAR2,
   p_lot_number         IN  VARCHAR2,
   p_primary_lot_quantity IN NUMBER,
   p_inspection_required IN NUMBER,
   p_hdr_id             IN  NUMBER,
   p_from_lpn_id        IN  NUMBER,
   p_to_lpn_id          IN  NUMBER,
   p_revision           IN  VARCHAR2,
   p_primary_uom_code   IN  VARCHAR2,
   p_call_pack_unpack   IN  VARCHAR2 := 'FALSE',
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_subinventory       IN VARCHAR2 DEFAULT NULL,
   p_locator_id         IN NUMBER DEFAULT NULL,
   p_txn_src_id IN VARCHAR2 DEFAULT NULL);


-- This is a wrapper to call inventory INV_LOT_API_PUB.insertLot
-- it stores the inserted lot info in a global variable for
-- transaction exception rollback

PROCEDURE insert_dynamic_lot
  (p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id  IN NUMBER,
   p_organization_id    IN NUMBER,
   p_lot_number         IN VARCHAR2,
   p_expiration_date    IN OUT NOCOPY DATE,
   p_transaction_temp_id  IN NUMBER DEFAULT NULL,
   p_transaction_action_id IN NUMBER DEFAULT NULL,
   p_transfer_organization_id IN NUMBER DEFAULT NULL,
   p_status_id          IN NUMBER,
   p_update_status      IN VARCHAR2 := 'FALSE',
   x_object_id          OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_parent_lot_number  IN VARCHAR2 DEFAULT NULL );   -- bug 10176719 - inserting parent lot number

PROCEDURE process_lot
  (p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_inventory_item_id  IN NUMBER,
   p_organization_id    IN NUMBER,
   p_lot_number         IN VARCHAR2,
   p_expiration_date    IN OUT NOCOPY DATE,
   p_transaction_temp_id  IN NUMBER DEFAULT NULL,
   p_transaction_action_id IN NUMBER DEFAULT NULL,
   p_transfer_organization_id IN NUMBER DEFAULT NULL,
   p_status_id          IN NUMBER,
   p_update_status      IN VARCHAR2 := 'FALSE',
   p_is_new_lot         IN VARCHAR2 := 'TRUE',
   p_call_pack_unpack   IN VARCHAR2 := 'FALSE',
   p_from_lpn_id        IN NUMBER,
   p_to_lpn_id          IN NUMBER,
   p_revision           IN VARCHAR2,
   p_lot_primary_qty    IN NUMBER,
   p_primary_uom_code   IN VARCHAR2,
   p_transaction_uom_code IN VARCHAR2 DEFAULT NULL,
   x_object_id          OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_subinventory       IN VARCHAR2 DEFAULT NULL,
   p_locator_id         IN NUMBER DEFAULT NULL,
   p_lot_secondary_qty    IN NUMBER DEFAULT NULL, --OPM Convergence
   p_secondary_uom_code   IN VARCHAR2 DEFAULT null,--OPM Convergence
   p_parent_lot_number  IN VARCHAR2 DEFAULT NULL    -- bug 10176719 - inserting parent lot number
);


PROCEDURE gen_txn_group_id;

PROCEDURE validate_trx_date(p_trx_date        IN     DATE,
			    p_organization_id IN     NUMBER,
			    p_sob_id          IN     NUMBER,
			    x_return_status      OUT NOCOPY VARCHAR2,
			    x_error_code         OUT NOCOPY VARCHAR2);

PROCEDURE get_req_shipment_header_id
  (x_shipment_header_id     OUT NOCOPY NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_organization_id        IN NUMBER,
   p_requiition_header_id   IN NUMBER,
   p_item_id                IN NUMBER,
   p_rcv_txn_type           IN VARCHAR2,
   p_lpn_id                 IN NUMBER DEFAULT NULL);

-- Bug 2086271
PROCEDURE get_req_shipment_header_id
  (x_shipment_header_id     OUT NOCOPY NUMBER,
   x_from_org_id            OUT NOCOPY NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_organization_id        IN NUMBER,
   p_requiition_header_id   IN NUMBER,
   p_item_id                IN NUMBER,
   p_rcv_txn_type           IN VARCHAR2,
   p_lpn_id                 IN NUMBER DEFAULT NULL);


PROCEDURE DO_CHECK(p_organization_id	        IN     NUMBER,
		   p_inventory_item_id	        IN     NUMBER,
		   p_transaction_type_id	IN     NUMBER,
		   p_primary_quantity	        IN     NUMBER,
		   x_return_status                 OUT NOCOPY VARCHAR2,
		   x_msg_data                      OUT NOCOPY VARCHAR2,
		   x_msg_count                     OUT NOCOPY NUMBER);

PROCEDURE insert_mtlt
  (p_mtlt_rec mtl_transaction_lots_temp%ROWTYPE);

PROCEDURE insert_msnt
  (p_msnt_rec mtl_serial_numbers_temp%ROWTYPE);

PROCEDURE GET_SERIAL_CTRL
	(x_return_status   	OUT    NOCOPY VARCHAR2,
	 x_serial_control	OUT    NOCOPY NUMBER,
	 p_from_org_id		IN     NUMBER,
	 p_item_id		    IN     NUMBER
	);

PROCEDURE  GET_SERIAL_CTRL
       (x_return_status      OUT    NOCOPY VARCHAR2,
        x_serial_control     OUT    NOCOPY NUMBER,
        p_to_org_id          IN     NUMBER,
        p_ship_head_id       IN     NUMBER,
        p_requisition_id     IN     NUMBER,
        p_item_id            IN     NUMBER);

-- WMS+PJM Integration
-- returns project and task fields
PROCEDURE GET_DOCUMENT_PROJECT_TASK
       (x_return_status 	OUT NOCOPY VARCHAR2,
	x_project_tasks_count	OUT NOCOPY NUMBER,
	x_distributions_count   OUT NOCOPY NUMBER,
	p_document_type 	IN  VARCHAR2,
	p_po_header_id		IN  NUMBER,
	p_po_line_id		IN  NUMBER,
	p_oe_header_id		IN  NUMBER,
	p_req_header_id		IN  NUMBER,
	p_shipment_header_id	IN  NUMBER,
        p_item_id               IN  NUMBER DEFAULT NULL,
        p_item_rev              IN  VARCHAR2 DEFAULT NULL
       );

-- MANEESH - BEGIN CHANGES - FOR CROSS REFERENCE ITEM CREATION

PROCEDURE create_cross_reference(p_api_version IN NUMBER,
				 p_init_msg_list IN VARCHAR2 := fnd_api.g_false,
				 p_commit IN VARCHAR2 := fnd_api.g_false,
				 p_organization_id IN NUMBER,
				 p_inventory_item_id IN NUMBER,
				 p_cross_reference IN VARCHAR2,
				 p_cross_reference_type IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);

-- MANEESH - END CHANGES - FOR CROSS REFERENCE ITEM CREATION

/* bug#2156143. Added procedures to get lot control of an item
at source org, for transactions INTRANSIT SHIPMENT and
INTERNAL REQUISITION. */

PROCEDURE GET_LOT_CTRL
        (x_return_status    OUT     NOCOPY VARCHAR2,
         x_msg_count        OUT     NOCOPY NUMBER,
         x_msg_data         OUT     NOCOPY VARCHAR2,
         x_lot_control      OUT     NOCOPY NUMBER,
         p_from_org_id      IN      NUMBER,
         p_item_id          IN      NUMBER
);

PROCEDURE  GET_LOT_CTRL
       (x_return_status      OUT    NOCOPY VARCHAR2,
        x_msg_count          OUT    NOCOPY NUMBER,
        x_msg_data           OUT    NOCOPY VARCHAR2,
        x_lot_control        OUT    NOCOPY NUMBER,
        p_to_org_id          IN     NUMBER,
        p_ship_head_id       IN     NUMBER,
        p_requisition_id     IN     NUMBER,
        p_item_id            IN     NUMBER
);


 PROCEDURE get_default_task(
    x_return_status       OUT    NOCOPY VARCHAR2,
    x_task_number         OUT    NOCOPY VARCHAR2,
    p_document_type       IN     VARCHAR2,
    p_po_header_id        IN     NUMBER DEFAULT NULL,
    p_po_line_id          IN     NUMBER DEFAULT NULL,
    p_oe_header_id        IN     NUMBER DEFAULT NULL,
    p_req_header_id       IN     NUMBER DEFAULT NULL,
    p_shipment_header_id  IN     NUMBER DEFAULT NULL,
    p_item_id             IN     NUMBER DEFAULT NULL,
    p_item_rev            IN     VARCHAR2 DEFAULT NULL,
    p_project_id          IN     NUMBER DEFAULT NULL
  );

 PROCEDURE check_lot_serial_codes(
    p_lpn_id                IN NUMBER,
    p_req_header_id         IN NUMBER,
    p_shipment_header_id    IN NUMBER,
    x_lot_ser_flag          OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );


/**
  *   This procedure checks for the following
  *   1. Whether the given LPN or its child LPN has contents. If
  *   either the given
  *      LPN or its child LPNs do not have any contents then
  *   through error.
  *   2. Check If the LPN is already processed, and there is a
  *   RTI record exists
  *      for the LPN.

  *  @param  p_lpn_id
  *  @param  x_return_status
  *  @param  x_msg_count
  *  @param  x_msg_data
**/

  PROCEDURE   VALIDATE_NESTED_LPN(
    p_lpn_id            IN NUMBER,
    x_lpn_flag          OUT  NOCOPY  VARCHAR2,
    x_return_status     OUT  NOCOPY  VARCHAR2,
    x_msg_count         OUT  NOCOPY  NUMBER,
    x_msg_data          OUT  NOCOPY  VARCHAR2
);
--


-- This proecedure will return subinventory code and locator id
  -- for given receiving LPN.

/**
  * This procedure takes in the LPN and fetches the LPN context,
  * subinventory code and locator id.
  * If the LPN resides in receiving, it also fetches the subinventory
  * and locator for that LPN
  **/
  PROCEDURE get_rcv_sub_loc(
      x_return_status      OUT NOCOPY    VARCHAR2
    , x_msg_count          OUT NOCOPY    NUMBER
    , x_msg_data           OUT NOCOPY    VARCHAR2
    , x_lpn_context        OUT NOCOPY    NUMBER
    , x_locator_segs       OUT NOCOPY    VARCHAR2
    , x_location_id        OUT NOCOPY    NUMBER
    , x_location_code      OUT NOCOPY    VARCHAR2
    , x_sub_code           OUT NOCOPY    VARCHAR2
    , x_locator_id         OUT NOCOPY    NUMBER
    , p_lpn_id             IN            NUMBER
    , p_organization_id    IN            NUMBER
    );

  PROCEDURE validate_from_lpn(
    p_lpn_id            IN            NUMBER
  , p_req_id            IN            VARCHAR2 DEFAULT NULL
  , x_lpn_flag          OUT NOCOPY    VARCHAR2
  , x_count_of_lpns     OUT NOCOPY    NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  --BUG 3402623: Add 2 more parameters for SHIPMENTEXP
  , p_shipment_num      IN            VARCHAR2 DEFAULT null
  , p_org_id            IN            NUMBER DEFAULT null
  );

PROCEDURE  clear_lot_rec; -- Bug # 3156689

-- Bug 4087032 Need to write a wrapper on LENGTH function as
-- it creates compiltaion issues in 8i env.
FUNCTION get_serial_length(p_from_ser IN VARCHAR2)
  return NUMBER;

--<R12 MOAC START>
/* Function get_operating_unit_id returns the org_id. */
FUNCTION get_operating_unit_id ( p_receipt_source_code IN VARCHAR2,
                                 p_po_header_id IN NUMBER,
                                 p_req_line_id IN NUMBER,
                                 p_oe_order_header_id IN NUMBER
                                )
  RETURN NUMBER;
--<R12 MOAC END>

/** Start of fix for bug 5065079 (FP of bug 4651362)
  * Following procedure is added to count the number of open shipments for
  * an internal requisition.
  **/
PROCEDURE count_req_open_shipments
  (p_organization_id         IN NUMBER,
   p_requisition_header_id   IN NUMBER,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2,
   x_open_shipments          OUT NOCOPY    NUMBER
   );

 /* End of fix for bug 5065079 */

--BUG 5068944 (FP of BUG 4992317)
PROCEDURE get_rec_uom_code(
                          x_return_status       OUT NOCOPY   VARCHAR2
			, x_uom_code            OUT NOCOPY   VARCHAR2
			, p_shipment_header_id  IN           NUMBER
			, p_item_id            IN            NUMBER
                        , p_organization_id    IN            NUMBER
			);
--END BUG 5068944
END INV_RCV_COMMON_APIS;

/
