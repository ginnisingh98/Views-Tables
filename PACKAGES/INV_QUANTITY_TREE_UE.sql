--------------------------------------------------------
--  DDL for Package INV_QUANTITY_TREE_UE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_QUANTITY_TREE_UE" AUTHID CURRENT_USER AS
  /* $Header: INVQTUES.pls 120.0.12010000.3 2009/04/29 13:47:21 adeshmuk ship $*/


g_lot_control NUMBER := 2;
g_no_lot_control NUMBER := 1;

g_serial_control NUMBER := 2;
g_no_serial_control NUMBER := 1;

g_rev_control NUMBER := 2;
g_no_rev_control NUMBER := 1;

g_no_rev_ctrl_please NUMBER := 0;
g_want_rev_ctrl NUMBER := 1;
g_refer_rev_control NUMBER := 2;

g_no_lot_ctrl_please NUMBER := 0;
g_want_lot_ctrl NUMBER := 1;
g_refer_lot_control NUMBER := 2;

g_all_subinvs NUMBER := 0;
g_asset_subinvs NUMBER := 1;


g_ONHAND NUMBER := 1;          /* Select from MTL_ONHAND_QUANTITES  */
g_TRX_TEMP NUMBER := 2;          /* MTL_MATERIAL_TRANSACTIONS_TEMP    */
g_RESERVATION NUMBER := 3;          /* From MTL_DEMAND                   */
g_qs_txn NUMBER	:= 5;          /*Suggestion in MMTT		*/

-- bug 4104123 : replaced p_demand_header_type default NULL by 0
FUNCTION create_tree(p_organization_id IN NUMBER,
		     p_inventory_item_id IN NUMBER,
		     p_revision_control IN NUMBER DEFAULT 1,
		     p_lot_control IN NUMBER DEFAULT 1,
		     p_serial_control IN NUMBER DEFAULT 1,
		     p_lot_active IN NUMBER DEFAULT 2,
		     p_demand_header_id IN NUMBER DEFAULT NULL,
		     p_demand_header_type IN NUMBER,
		     p_tree_mode In NUMBER DEFAULT 3,        --2 replaced by 3 for bug7038890
		     p_negative_inv_allowed in NUMBER DEFAULT 0,
		     p_lot_expiration_date in DATE DEFAULT NULL,
		     p_activate IN NUMBER DEFAULT 1,
		     p_uom_code IN VARCHAR2 DEFAULT NULL,
		     p_asset_subinventory_only IN NUMBER DEFAULT 0,
		     p_demand_source_name IN VARCHAR2 DEFAULT NULL,
		     p_demand_source_line_id IN NUMBER DEFAULT NULL,
		     p_demand_source_delivery IN NUMBER DEFAULT NULL,
		     p_rev_active IN NUMBER DEFAULT 2,
		     x_available_quantity OUT NOCOPY NUMBER,
		     x_onhand_quantity OUT NOCOPY NUMBER,
		     x_return_status OUT NOCOPY VARCHAR2,
		     x_message_count OUT NOCOPY NUMBER,
		     x_message_data OUT NOCOPY VARCHAR2,
		     p_lpn_id       IN NUMBER DEFAULT NULL) --added for bug7038890
		     RETURN NUMBER;

-- invConv change begin : Overloaded version of create_tree :
-- bug 4104123 : replaced p_demand_header_type default NULL by 0
FUNCTION create_tree( p_organization_id         IN NUMBER
		    , p_inventory_item_id       IN NUMBER
		    , p_revision_control        IN NUMBER DEFAULT 1
		    , p_lot_control             IN NUMBER DEFAULT 1
		    , p_serial_control          IN NUMBER DEFAULT 1
		    , p_grade_code              IN VARCHAR2 DEFAULT NULL      -- invConv change
		    , p_lot_active              IN NUMBER DEFAULT 2
		    , p_demand_header_id        IN NUMBER DEFAULT NULL
		    , p_demand_header_type      IN NUMBER DEFAULT 0
		    , p_tree_mode               IN NUMBER DEFAULT 3         --2 replaced by 3 for bug7038890
		    , p_negative_inv_allowed    IN NUMBER DEFAULT 0
		    , p_lot_expiration_date     IN DATE DEFAULT NULL
		    , p_activate                IN NUMBER DEFAULT 1
		    , p_uom_code                IN VARCHAR2 DEFAULT NULL
		    , p_asset_subinventory_only IN NUMBER DEFAULT 0
		    , p_demand_source_name      IN VARCHAR2 DEFAULT NULL
		    , p_demand_source_line_id   IN NUMBER DEFAULT NULL
		    , p_demand_source_delivery  IN NUMBER DEFAULT NULL
		    , p_rev_active              IN NUMBER DEFAULT 2
		    , x_available_quantity      OUT NOCOPY NUMBER
		    , x_available_quantity2     OUT NOCOPY NUMBER          -- invConv change
		    , x_onhand_quantity         OUT NOCOPY NUMBER
		    , x_onhand_quantity2        OUT NOCOPY NUMBER          -- invConv change
		    , x_return_status           OUT NOCOPY VARCHAR2
		    , x_message_count           OUT NOCOPY NUMBER
		    , x_message_data            OUT NOCOPY VARCHAR2
		    , p_lpn_id                  IN NUMBER DEFAULT NULL) --added for bug7038890
		    RETURN NUMBER;
-- invConv changes end.

-- bug 4104123 : replaced p_demand_header_type default NULL by 0
FUNCTION query_tree(p_organization_id IN NUMBER,
		    p_inventory_item_id IN NUMBER,
		    p_revision_control IN NUMBER DEFAULT 1,
		    p_lot_control IN NUMBER DEFAULT 1,
		    p_serial_control IN NUMBER DEFAULT 1,
		    p_demand_header_id IN NUMBER default NULL,
		    p_demand_header_type IN NUMBER,
		    p_revision in varchar2 default NULL,
		    p_lot in varchar2 default NULL,
		    P_lot_expiration_date IN DATE default NULL,
		    P_subinventory IN varchar2 default NULL,
		    P_locator in NUMBER default NULL,
		    P_transfer_subinventory VARCHAR2 default NULL,
		    P_transaction_quantity in NUMBER default 0,
		    P_uom_code in varchar2 default NULL,
		    P_lot_active IN NUMBER default 2,
		    P_activate IN NUMBER default 1,
		    P_tree_mode In NUMBER Default 3,         --2 replaced by 3 for bug7038890
		    P_demand_source_name IN varchar2 default NULL,
		    P_demand_source_line_id IN NUMBER default NULL,
		    P_demand_source_delivery in NUMBER default NULL,
		    P_rev_active in NUMBER default 2,
		    X_available_onhand out NOCOPY NUMBER,
  X_available_quantity out NOCOPY NUMBER,
  X_onhand_quantity out NOCOPY NUMBER,
  X_return_status OUT NOCOPY VARCHAR2,
  X_message_count OUT NOCOPY NUMBER,
  X_message_data Out NOCOPY VARCHAR2,
  P_lpn_id       IN NUMBER DEFAULT NULL  --added for bug7038890
  ) RETURN NUMBER;

-- invConv changes begin : overloaded version of query_tree :
-- bug 4104123 : replaced p_demand_header_type default NULL by 0
FUNCTION query_tree( p_organization_id        IN NUMBER
		   , p_inventory_item_id      IN NUMBER
		   , p_revision_control       IN NUMBER DEFAULT 1
		   , p_lot_control            IN NUMBER DEFAULT 1
		   , p_serial_control         IN NUMBER DEFAULT 1
		   , p_demand_header_id       IN NUMBER DEFAULT NULL
		   , p_demand_header_type     IN NUMBER DEFAULT 0
		   , p_revision               in VARCHAR2 DEFAULT NULL
		   , p_lot                    in VARCHAR2 DEFAULT NULL
		   , p_lot_expiration_date    IN DATE DEFAULT NULL
		   , p_subinventory           IN VARCHAR2 DEFAULT NULL
		   , p_locator                in NUMBER DEFAULT NULL
		   , p_transfer_subinventory  IN VARCHAR2 DEFAULT NULL
		   , p_transaction_quantity   IN NUMBER DEFAULT 0
		   , p_uom_code               IN VARCHAR2 DEFAULT NULL
		   , p_transaction_quantity2  IN NUMBER DEFAULT NULL          -- invConv change
		   , p_lot_active             IN NUMBER DEFAULT 2
		   , p_activate               IN NUMBER DEFAULT 1
		   , p_tree_mode              IN NUMBER DEFAULT 3             --2 replaced by 3 for bug7038890
		   , p_demand_source_name     IN VARCHAR2 DEFAULT NULL
		   , p_demand_source_line_id  IN NUMBER DEFAULT NULL
		   , p_demand_source_delivery IN NUMBER DEFAULT NULL
		   , p_rev_active             IN NUMBER DEFAULT 2
		   , x_available_onhand       OUT NOCOPY NUMBER
                   , x_available_quantity     OUT NOCOPY NUMBER
                   , x_onhand_quantity        OUT NOCOPY NUMBER
		   , x_available_onhand2      OUT NOCOPY NUMBER                     -- invConv change
                   , x_available_quantity2    OUT NOCOPY NUMBER                     -- invConv change
                   , x_onhand_quantity2       OUT NOCOPY NUMBER                     -- invConv change
                   , x_return_status          OUT NOCOPY VARCHAR2
                   , x_message_count          OUT NOCOPY NUMBER
                   , x_message_data           OUT NOCOPY VARCHAR2
		   , P_lpn_id                 IN  NUMBER DEFAULT NULL              --added for bug7038890
		   ) RETURN NUMBER;
-- invConv changes end.

-- bug 4104123 : replaced p_demand_header_type default NULL by 0
FUNCTION xact_qty(P_organization_id IN NUMBER,
		  P_inventory_item_id IN NUMBER,
		  P_demand_header_id IN NUMBER default NULL,
		  P_demand_header_type IN NUMBER,
		  P_revision_control IN NUMBER default 1,
		  P_lot_control IN NUMBER default 1,
		  P_serial_control IN NUMBER default 1,
		  P_revision in varchar2 default NULL,
		  P_lot in varchar2 default NULL,
		  P_lot_expiration_date IN DATE default NULL,
		  P_subinventory IN varchar2 default NULL,
		  P_locator in NUMBER default NULL,
		  P_xact_mode In NUMBER Default 2,
		  P_transfer_subinventory IN VARCHAR2 default NULL,
		  P_transfer_locator in NUMBER default NULL,
		  P_transaction_quantity in NUMBER default NULL,
		  P_uom_code in varchar2 default NULL,
		  P_lot_active IN NUMBER default 2,
		  P_activate IN NUMBER default 1,
		  P_demand_source_name IN varchar2 default NULL,
		  P_demand_source_line_id IN NUMBER default NULL,
		  P_demand_source_delivery in NUMBER default NULL,
		  P_rev_active in NUMBER default 2,
		  X_available_onhand out NOCOPY NUMBER,
  X_available_quantity out NOCOPY NUMBER,
  X_onhand_quantity out NOCOPY NUMBER,
  X_return_status OUT NOCOPY VARCHAR2,
  X_message_count OUT NOCOPY NUMBER,
  X_message_data Out NOCOPY VARCHAR2,
  P_tree_mode    IN NUMBER DEFAULT 3,                 --added for bug7038890
  P_lpn_id       IN NUMBER DEFAULT NULL               --added for bug7038890
  ) RETURN NUMBER;

-- invConv changes begin : overloaded version of xact_qty
-- bug 4104123 : replaced p_demand_header_type default NULL by 0
FUNCTION xact_qty( P_organization_id         IN NUMBER
		 , P_inventory_item_id       IN NUMBER
		 , P_demand_header_id        IN NUMBER DEFAULT NULL
		 , P_demand_header_type      IN NUMBER DEFAULT 0
		 , P_revision_control        IN NUMBER DEFAULT 1
		 , P_lot_control             IN NUMBER DEFAULT 1
		 , P_serial_control          IN NUMBER DEFAULT 1
		 , P_revision                IN VARCHAR2 DEFAULT NULL
		 , P_lot                     IN VARCHAR2 DEFAULT NULL
		 , P_lot_expiration_date     IN DATE DEFAULT NULL
		 , P_subinventory            IN VARCHAR2 DEFAULT NULL
		 , P_locator                 IN NUMBER DEFAULT NULL
		 , P_xact_mode               IN NUMBER DEFAULT 2
		 , P_transfer_subinventory   IN VARCHAR2 DEFAULT NULL
		 , P_transfer_locator        IN NUMBER DEFAULT NULL
		 , P_transaction_quantity    IN NUMBER DEFAULT NULL
		 , P_uom_code                IN VARCHAR2 DEFAULT NULL
		 , P_transaction_quantity2   IN NUMBER DEFAULT NULL
		 , P_lot_active              IN NUMBER DEFAULT 2
		 , P_activate                IN NUMBER DEFAULT 1
		 , P_demand_source_name      IN VARCHAR2 DEFAULT NULL
		 , P_demand_source_line_id   IN NUMBER DEFAULT NULL
		 , P_demand_source_delivery  IN NUMBER DEFAULT NULL
		 , P_rev_active              IN NUMBER DEFAULT 2
		 , X_available_onhand        OUT NOCOPY NUMBER
                 , X_available_quantity      OUT NOCOPY NUMBER
                 , X_onhand_quantity         OUT NOCOPY NUMBER
		 , X_available_onhand2       OUT NOCOPY NUMBER
                 , X_available_quantity2     OUT NOCOPY NUMBER
                 , X_onhand_quantity2        OUT NOCOPY NUMBER
                 , X_return_status           OUT NOCOPY VARCHAR2
                 , X_message_count           OUT NOCOPY NUMBER
                 , X_message_data            OUT NOCOPY VARCHAR2
		 , P_tree_mode               IN NUMBER DEFAULT 3    --added for bug7038890
		 , P_lpn_id                  IN NUMBER DEFAULT NULL) --added for bug7038890
		 RETURN NUMBER;
-- invConv changes end.

PROCEDURE print_debug(p_message IN VARCHAR2, p_level IN NUMBER DEFAULT 14);

END INV_QUANTITY_TREE_UE;

/
