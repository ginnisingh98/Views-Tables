--------------------------------------------------------
--  DDL for Package INV_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CACHE" AUTHID CURRENT_USER AS
/* $Header: INVCACHS.pls 120.3.12010000.4 2010/06/22 16:08:59 mporecha ship $ */

org_rec		mtl_parameters%ROWTYPE;
tosub_rec	mtl_secondary_inventories%ROWTYPE;
fromsub_rec	mtl_secondary_inventories%ROWTYPE;
item_rec	mtl_system_items%ROWTYPE;
mmtt_rec	mtl_material_transactions_temp%ROWTYPE;
mol_rec		mtl_txn_request_lines%ROWTYPE;
mtrh_rec	mtl_txn_request_headers%ROWTYPE;
wdd_rec		wsh_delivery_details%ROWTYPE;
mtt_rec		mtl_transaction_types%ROWTYPE;
mso_rec		mtl_sales_orders%ROWTYPE;

--Bug 4171297
oola_rec        oe_order_lines_all%ROWTYPE;

-- Bug# 4258360: Added the following for R12 Crossdock Pegging Project
wpb_rec         wsh_picking_batches%ROWTYPE;

-- Onhand Material Status Support
loc_rec         mtl_item_locations%ROWTYPE;
moqd_rec        mtl_onhand_quantities_detail%ROWTYPE;
-- Onhand Material Status Support

-- 8809951 High Volume Project Phase-2
pjm_org_parms_rec  pjm_org_parameters%ROWTYPE;


/* Added for LSP Project */

TYPE ct_rec_type IS RECORD ( client_rec MTL_CLIENT_PARAMETERS%ROWTYPE ) ;
TYPE ct_rec_table IS TABLE OF ct_rec_type INDEX BY BINARY_INTEGER;
ct_table        ct_rec_table;

/* End of changes for LSP Project */

-- Serial Tagging

TYPE serial_tag_rec_table IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
serial_tag_table        serial_tag_rec_table;

-- Bug# 4951639: Added to set move order transaction date during pick release
mo_transaction_date  DATE;

wms_installed	BOOLEAN;
is_pickrelease	BOOLEAN;
oe_header_id	NUMBER;
tolocator_id	NUMBER;
tosubinventory_code	VARCHAR2(10);

FUNCTION set_org_rec
  (
   p_organization_id IN NUMBER
   ) RETURN BOOLEAN;

FUNCTION set_org_rec
  (
   p_organization_code IN VARCHAR2
   ) RETURN BOOLEAN;

FUNCTION set_item_rec
  (
   p_organization_id IN NUMBER,
   p_item_id IN NUMBER
   ) RETURN BOOLEAN;

FUNCTION set_tosub_rec
  (
   p_organization_id IN NUMBER,
   p_subinventory_code IN VARCHAR2
   ) RETURN BOOLEAN;

FUNCTION set_fromsub_rec
  (
   p_organization_id IN NUMBER,
   p_subinventory_code IN VARCHAR2
   ) RETURN BOOLEAN;

FUNCTION set_mmtt_rec
  (
   p_transaction_temp_id IN NUMBER
   ) RETURN BOOLEAN;

FUNCTION set_mol_rec
  (
   p_line_id IN NUMBER
   ) RETURN BOOLEAN;

FUNCTION set_mtrh_rec
  (
   p_header_id IN NUMBER
   ) RETURN BOOLEAN;

FUNCTION set_wdd_rec
  (
   p_move_order_line_id IN NUMBER
   ) RETURN BOOLEAN;

FUNCTION set_mso_rec
  (
   p_oe_header_id IN NUMBER
   ) RETURN BOOLEAN;

FUNCTION set_oeh_id
  (
   p_salesorder_id IN NUMBER
   ) RETURN BOOLEAN;

FUNCTION set_mtt_rec
  (
   p_transaction_type_id IN NUMBER
   ) RETURN BOOLEAN;

FUNCTION set_wms_installed
  (
   p_organization_id IN NUMBER
   ) RETURN BOOLEAN;

FUNCTION set_pick_release
  (
   p_value IN BOOLEAN
   ) RETURN BOOLEAN;

FUNCTION set_to_locator
  (
   p_locator_id IN NUMBER
   ) RETURN BOOLEAN;

FUNCTION set_to_subinventory
  (
   p_subinventory_code IN NUMBER
   ) RETURN BOOLEAN;

--4171297
FUNCTION set_oola_rec
  (
   p_order_line_id IN NUMBER
   ) RETURN BOOLEAN;

-- Bug# 4258360: Added for R12 Crossdock Pegging Project
FUNCTION set_wpb_rec
  (
   p_batch_id       IN NUMBER,
   p_request_number IN VARCHAR2
   ) RETURN BOOLEAN;

-- Onhand Material Status Support
FUNCTION set_loc_rec
  (
   p_organization_id IN NUMBER,
   p_locator_id IN VARCHAR2
  ) RETURN BOOLEAN;

-- Onhand Material Status Support
FUNCTION set_moqd_status_rec
  (
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_sub_code IN VARCHAR2,
   p_loc_id IN NUMBER,
   p_lot_number IN VARCHAR2,
   p_lpn_id IN NUMBER
  ) RETURN BOOLEAN;

  -- 8809951 High Volume Project Phase-2
  FUNCTION set_pjm_org_parms_rec
  (
  p_organization_id IN NUMBER
  ) RETURN BOOLEAN;

/* Added for LSP Project */

  PROCEDURE get_client_default_parameters
          (
                p_client_id          IN MTL_CLIENT_PARAMETERS.CLIENT_ID%TYPE
              , x_return_status        OUT NOCOPY VARCHAR2
              , x_client_parameters_rec OUT NOCOPY ct_rec_type
          );

/* End of changes for LSP Project */

--Serial Tagged
FUNCTION get_serial_tagged
          (
                p_organization_id      IN         NUMBER
              , p_inventory_item_id    IN         NUMBER
              , p_transaction_type_id  IN         NUMBER
          ) RETURN NUMBER;

END inv_cache;

/
