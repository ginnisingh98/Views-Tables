--------------------------------------------------------
--  DDL for Package WMS_CARTNZN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CARTNZN_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSCRTNS.pls 120.3.12010000.3 2009/05/27 12:11:24 abasheer ship $*/


-- File        : WMSCRTNS.pls
-- Content     : WMS_CARTNZN_PUB package specification
-- Description : WMS cartonization API
-- Notes       :
-- Modified    : 09/12/2000 cjandhya created

-- MOdified    : 03/13/2002 cjandhya Added Multilevel Cartonization

-- API name    : cartonize
-- Type        : group
-- Function    : populates the cartonization_id, container_item_id columns,
--               of rows belonging to a particular move order header id in
--               mtl_material_transactions_temp.

-- Pre-reqs    :  Those columns won't be populated if the cartonization_id
--                for that row is already populated,
--                or if values for organization_id, inventory_item_id ,
--                primary qunatity, transaction_quantity,  transaction_uom,
--                trans action_temp_id are not all filled or if there is no
--                conversion defined between primary and transaction uoms of
--                the item of interest. each item has to be assigned to a
--                category of contained_item category set and that category
--                should have some container items.
--                The lines that can be packed together are identified by the
--                carton_grouping_id(MTL_TXN_REQEST_LINES) for the
--                move_order_line_id of that line.


-- Parameters  :
--   p_api_version          Standard Input Parameter
--   p_init_msg_list        Standard Input Parameter
--   p_commit               Standard Input Parameter
--   p_validation_level     Standard Input Parameter
--   l_out_bound            specifies if the call is for outbound process
--   org_id                 organization_id
--   l_move_order_header_id header_id for the lines to be cartonized


-- Output Parameters
--   x_return_status        Standard Output Parameter
--   x_msg_count            Standard Output Parameter
--   x_msg_data             Standard Output Parameter

-- Version
--   Currently version is 1.0



-- Package constants for different modes in which cartonization is called

PR_pKG_mode              NUMBER := 1;--Pick Release Mode
int_bP_pkg_mode          NUMBER := 2;--Bulk Pack mode, invoked from interface tables
mob_bP_pKG_mode          NUMBER := 3;--Bulk Pack mode, invoked from mobile forms
prepack_pkg_mode         NUMBER := 4;--Prepack mode, invoked by prepack conc prog
mfg_pr_pkg_mode          NUMBER := 5;--Manufacturing Pick Release Mode


g_org_cartonization_value      NUMBER;
g_org_cartonize_so_flag        VARCHAR2(1) := 'N';
g_org_cartonize_mfg_flag       VARCHAR2(1) := 'N';
g_org_allocate_serial_flag     VARCHAR2(1) := 'N';
g_default_pick_op_plan_id      NUMBER;
g_auto_pick_confirm_flag       VARCHAR2(1);
g_percent_fill_basis           VARCHAR2(1) :='W';
g_autocreate_delivery_flag     VARCHAR2(1);
g_cartonize_pick_slip VARCHAR2(1) := 'N'; --WMS High Vol Support

--Bug 2745834 fix
g_wms_pack_hist_seq NUMBER := 1;

-- start for adding WMS High Vol Support
-- Bug 3528061 fix
-- Variable storing the allocate_serials_flag for the organization
g_allocate_serial_flag VARCHAR2(1) := NULL;

-- Bug#7168367.This will hold if cartonization is enabled at sublevel or not
--   1 - At org level
--   3 - At sublevel
g_sublvlctrl    VARCHAR2(1) := '2';

-- Cartonization package global flags
pack_level   NUMBER      := 0;
outbound     VARCHAR2(1) := 'N';

-- Sets the table on which we want to perform the operations insert,
-- delete, update etc
table_name   VARCHAR2(200) := 'mtl_material_transactions_temp';

TYPE attr_rec IS  RECORD
( inventory_item_id       NUMBER
, gross_weight            NUMBER
, content_volume          NUMBER
, gross_weight_uom_code   VARCHAR2(3)
, content_volume_uom_code VARCHAR2(3)
, tare_weight             NUMBER
, tare_weight_uom_code    VARCHAR2(3)
);

TYPE  attr_tb  IS TABLE OF  attr_rec INDEX BY BINARY_INTEGER;

lpn_attr_table attr_tb;
pkg_attr_table attr_tb;



  --for device integration
SUBTYPE mmtt_row     IS mtl_material_transactions_temp%ROWTYPE;
SUBTYPE wct_row_type IS wms_cartonization_temp%ROWTYPE;

lpns_generated_tb  inv_label.transaction_id_rec_type;



TYPE lpn_alloc_flag_rec IS RECORD
( transaction_temp_id    mtl_material_transactions_temp.transaction_temp_id%TYPE
, lpn_alloc_flag    VARCHAR2(1)
);

TYPE lpn_alloc_flag_tb IS TABLE OF lpn_alloc_flag_rec INDEX BY LONG;

-- TABLE used to store whether transaction_temp_id is fully allocated
-- partially allocated, or not allocated
t_lpn_alloc_flag_table  lpn_alloc_flag_tb;

-- end for adding WMS High Vol Support


FUNCTION get_lpn_alloc_flag(p_temp_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE cartonize(
		    p_api_version           IN    NUMBER,
		    p_init_msg_list         IN    VARCHAR2 :=fnd_api.g_false,
		    p_commit                IN    VARCHAR2 :=fnd_api.g_false,
		    p_validation_level      IN    NUMBER   :=fnd_api.g_valid_level_full,
                    x_return_status	    OUT   NOCOPY VARCHAR2,
		    x_msg_count       	    OUT   NOCOPY NUMBER,
		    x_msg_data        	    OUT   NOCOPY VARCHAR2,
		    p_out_bound             IN    VARCHAR2 DEFAULT 'Y',
                    p_org_id                IN    NUMBER,
		    p_move_order_header_id  IN    NUMBER   DEFAULT  0,
		    p_disable_cartonization IN    VARCHAR2 DEFAULT 'N',
		    p_transaction_header_id IN    NUMBER   DEFAULT  0,
		    p_stop_level            IN    NUMBER   DEFAULT  -1,
		    p_PACKAGING_mode        IN    NUMBER   DEFAULT  1,
		    p_input_for_bulk        IN    WMS_BULK_PICK.bulk_input_rec  DEFAULT null);

PROCEDURE UPDATE_MMTT(
		      p_transaction_temp_id  	IN  	NUMBER,
		      p_primary_quantity        IN      NUMBER,
		      p_transaction_quantity    IN      NUMBER,
                      p_secondary_quantity      IN      NUMBER DEFAULT NULL, --invconv kkillams
		      p_LPN_string              IN      VARCHAR2 DEFAULT NULL,
		      p_lpn_id                  IN      NUMBER DEFAULT NULL,
		      p_container_item_id       IN      NUMBER,
		      p_parent_line_id          IN      NUMBER := -99999,
		      p_upd_qty_flag            IN      VARCHAR2 DEFAULT 'Y',
		      x_return_status	        OUT 	NOCOPY VARCHAR2,
		      x_msg_count       	OUT 	NOCOPY NUMBER,
		      x_msg_data        	OUT 	NOCOPY VARCHAR2);

PROCEDURE INSERT_MMTT(
		      p_transaction_temp_id  	IN  	NUMBER,
		      p_primary_quantity        IN      NUMBER,
		      p_transaction_quantity    IN      NUMBER,
                      p_secondary_quantity      IN      NUMBER DEFAULT NULL, --invconv kkillams
		      p_LPN_string              IN      VARCHAR2 DEFAULT NULL,
		      p_lpn_id                  IN      NUMBER DEFAULT NULL,
		      p_container_item_id       IN      NUMBER DEFAULT NULL,
		      p_new_txn_hdr_id          IN      NUMBER DEFAULT NULL,
		      p_new_txn_tmp_id          IN      NUMBER DEFAULT NULL,
		      p_clpn_id                 IN      NUMBER DEFAULT NULL,
		      p_item_id                 IN      NUMBER DEFAULT NULL,
		      x_return_status	        OUT 	NOCOPY VARCHAR2,
		      x_msg_count       	OUT 	NOCOPY NUMBER,
		      x_msg_data        	OUT 	NOCOPY VARCHAR2);

PROCEDURE log_event(p_message	VARCHAR2);

PROCEDURE test;

FUNCTION get_log_flag RETURN VARCHAR2;

FUNCTION do_cartonization( mohdrid NUMBER,trxhdrid number, outbound VARCHAR2, sublvlctrl VARCHAR2, per_fill VARCHAR2) RETURN NUMBER;


PROCEDURE ins_wct_rows_into_mmtt(
				 p_m_o_h_id           IN       NUMBER,
				 p_outbound           IN       VARCHAR2,
				 x_return_status      OUT      NOCOPY VARCHAR2,
				 x_msg_count          OUT      NOCOPY NUMBER,
				 x_msg_data           OUT      NOCOPY VARCHAR2);

FUNCTION get_lpn_Itemid(P_lpn_id IN NUMBER) return NUMBER;

FUNCTION get_PACKAGE_Itemid(P_PACKAGE_id IN NUMBER) return NUMBER;

FUNCTION get_next_package_id RETURN NUMBER;


PROCEDURE get_package_attributes(
				 p_org_id                  IN  NUMBER,
				 p_package_id                IN  NUMBER,
				 x_inventory_item_id       OUT NOCOPY NUMBER,
				 x_gross_weight            OUT NOCOPY NUMBER,
				 x_content_volume          OUT NOCOPY NUMBER,
				 x_gross_weight_uom_code   OUT NOCOPY VARCHAR2,
				 x_content_volume_uom_code OUT NOCOPY VARCHAR2,
				 x_tare_weight             OUT NOCOPY NUMBER,
				 x_tare_weight_uom_code    OUT NOCOPY VARCHAR2 );

PROCEDURE get_lpn_attributes(
			     p_lpn_id                  IN  NUMBER,
			     x_inventory_item_id       OUT NOCOPY NUMBER,
			     x_gross_weight            OUT NOCOPY NUMBER,
			     x_content_volume          OUT NOCOPY NUMBER,
			     x_gross_weight_uom_code   OUT NOCOPY VARCHAR2,
			     x_content_volume_uom_code OUT NOCOPY VARCHAR2,
			     x_tare_weight             OUT NOCOPY NUMBER,
			     x_tare_weight_uom_code    OUT NOCOPY VARCHAR2 );


--This procedure inserts records into wms_device_requests table for further
-- processing by device integration code.This procedure is called from
-- WMSCRTNB.pls and WMSTSKUB.pls
PROCEDURE insert_device_request_rec(p_mmtt_row IN mmtt_row);


PROCEDURE cartonize_single_item
( x_return_status         OUT   NOCOPY VARCHAR2
, x_msg_count             OUT   NOCOPY NUMBER
, x_msg_data              OUT   NOCOPY VARCHAR2
, p_out_bound             IN    VARCHAR2
, p_org_id                IN    NUMBER
, p_move_order_header_id  IN    NUMBER
, p_subinventory_name     IN    VARCHAR2 DEFAULT NULL
);

PROCEDURE cartonize_mixed_item
( x_return_status         OUT   NOCOPY VARCHAR2
, x_msg_count             OUT   NOCOPY NUMBER
, x_msg_data              OUT   NOCOPY VARCHAR2
, p_out_bound             IN    VARCHAR2
, p_org_id                IN    NUMBER
, p_move_order_header_id  IN    NUMBER
, p_transaction_header_id IN    NUMBER
, p_disable_cartonization IN    VARCHAR2 DEFAULT  'N'
, p_subinventory_name     IN    VARCHAR2 DEFAULT NULL
, p_stop_level            IN    NUMBER DEFAULT NULL
, p_pack_level            IN    NUMBER
);


PROCEDURE cartonize_pick_slip
( p_org_id                IN    NUMBER
, p_move_order_header_id  IN    NUMBER
, p_subinventory_name     IN    VARCHAR2
, x_return_status         OUT   NOCOPY VARCHAR2
);


PROCEDURE cartonize_customer_logic
( p_org_id                IN    NUMBER
, p_move_order_header_id  IN    NUMBER
, p_subinventory_name     IN    VARCHAR2
, x_return_status         OUT   NOCOPY VARCHAR2
);


PROCEDURE cartonize_default_logic
( p_org_id                IN    NUMBER
, p_move_order_header_id  IN    NUMBER
, p_out_bound             IN    VARCHAR2
, x_return_status         OUT   NOCOPY VARCHAR2
, x_msg_count             OUT   NOCOPY NUMBER
, x_msg_data              OUT   NOCOPY VARCHAR2
);


PROCEDURE insert_ph
( p_move_order_header_id IN NUMBER
, p_current_header_id    IN NUMBER
, x_return_status        OUT NOCOPY NUMBER
);


PROCEDURE generate_lpns
( p_header_id        IN  NUMBER
, p_organization_id  IN  NUMBER
);


PROCEDURE split_lot_serials (p_organization_id  IN  NUMBER);

FUNCTION  get_next_header_id  RETURN NUMBER;

FUNCTION  get_next_temp_id  RETURN NUMBER;

PROCEDURE insert_ph
( p_orig_header_id       IN  NUMBER
, p_transaction_temp_id  IN  NUMBER
);



END WMS_CARTNZN_PUB;

/
