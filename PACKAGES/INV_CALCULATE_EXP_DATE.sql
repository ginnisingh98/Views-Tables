--------------------------------------------------------
--  DDL for Package INV_CALCULATE_EXP_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CALCULATE_EXP_DATE" AUTHID CURRENT_USER AS
/* $Header: INVCEDTS.pls 120.1 2007/12/20 18:01:24 asatpute noship $ */

g_mti_txn_id		NUMBER  := -1; -- stores the transaction_interface_id to identify row in MTI
g_mmtt_txn_id		NUMBER  := -1; -- stores the transaction_header_id to identify row in MMTT
g_mtli_txn_id		ROWID   := '-1'; -- stores the rowid to identify row in MTLI
g_mtlt_txn_id		ROWID   := '-1'; -- stores the rowid to identify row in MTLT

TYPE mmtt_tab IS TABLE OF MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
      INDEX BY BINARY_INTEGER;
g_mmtt_tbl mmtt_tab;

TYPE mtlt_tab IS TABLE OF MTL_TRANSACTION_LOTS_TEMP%ROWTYPE
      INDEX BY BINARY_INTEGER;
g_mtlt_tbl mtlt_tab;

TYPE mti_tab IS TABLE OF MTL_TRANSACTIONS_INTERFACE%ROWTYPE
      INDEX BY BINARY_INTEGER;
g_mti_tbl mti_tab;

TYPE mtli_tab IS TABLE OF MTL_TRANSACTION_LOTS_INTERFACE%ROWTYPE
      INDEX BY BINARY_INTEGER;
g_mtli_tbl mtli_tab;

PROCEDURE assign_mti_rec (
        p_inventory_item_id           IN NUMBER
      , p_revision                    IN VARCHAR2
      , p_organization_id             IN NUMBER
      , p_transaction_action_id       IN NUMBER
      , p_subinventory_code           IN VARCHAR2
      , p_locator_id                  IN NUMBER
      , p_transaction_type_id         IN NUMBER
      , p_trx_source_type_id          IN NUMBER
      , p_transaction_quantity        IN NUMBER
      , p_primary_quantity            IN NUMBER
      , p_transaction_uom             IN VARCHAR2
      , p_ship_to_location            IN NUMBER
      , p_reason_id                   IN NUMBER
      , p_user_id                     IN NUMBER
      , p_transfer_lpn_id             IN NUMBER
      , p_transaction_source_id       IN NUMBER
      , p_trx_source_line_id          IN NUMBER
      , p_project_id                  IN NUMBER
      , p_task_id                     IN NUMBER
      , p_planning_organization_id    IN NUMBER
      , p_planning_tp_type            IN NUMBER
      , p_owning_organization_id      IN NUMBER
      , p_owning_tp_type              IN NUMBER
      , p_distribution_account_id     IN NUMBER
      , p_sec_transaction_quantity    IN NUMBER
      , p_secondary_uom_code          IN VARCHAR2
      , x_return_status               OUT NOCOPY VARCHAR2
      );

FUNCTION get_mti_tbl RETURN mti_tab;

PROCEDURE purge_mti_tab;

PROCEDURE assign_mmtt_rec (
		  p_inventory_item_id		IN NUMBER
		, p_revision			IN VARCHAR2
		, p_organization_id		IN NUMBER
		, p_transaction_action_id	IN NUMBER
		, p_subinventory_code		IN VARCHAR2
		, p_locator_id			IN NUMBER
		, p_transaction_type_id		IN NUMBER
		, p_trx_source_type_id	IN NUMBER
		, p_transaction_quantity	IN NUMBER
		, p_primary_quantity		IN NUMBER
		, p_transaction_uom		IN VARCHAR2
		, p_ship_to_location		IN NUMBER
		, p_reason_id			IN NUMBER
		, p_user_id			IN NUMBER
		, p_transfer_lpn_id		IN NUMBER
		, p_transaction_source_id	IN NUMBER
		, p_transaction_cost		IN NUMBER
		, p_project_id			IN NUMBER
		, p_task_id			IN NUMBER
		, p_planning_organization_id	IN NUMBER
		, p_planning_tp_type		IN NUMBER
		, p_owning_organization_id	IN NUMBER
		, p_owning_tp_type		IN NUMBER
		, p_distribution_account_id	IN NUMBER
                , p_sec_transaction_quantity IN NUMBER
                , p_secondary_uom_code          IN VARCHAR2
		, x_return_status		OUT NOCOPY VARCHAR2
		);

FUNCTION get_mmtt_tbl RETURN mmtt_tab;

PROCEDURE purge_mmtt_tab;

FUNCTION get_txn_id  ( p_table IN NUMBER) RETURN NUMBER;

FUNCTION get_lot_txn_id ( p_table IN NUMBER) RETURN ROWID;

PROCEDURE set_txn_id  ( p_table		IN	NUMBER,
			p_header_id	IN	NUMBER) ;

PROCEDURE set_lot_txn_id  ( p_table		IN	NUMBER,
			    p_header_id		IN	ROWID);

PROCEDURE reset_header_id;

PROCEDURE get_lot_primary_onhand
(  p_inventory_item_id    IN NUMBER
  ,p_organization_id      IN NUMBER
  ,p_lot_number           IN VARCHAR2
  ,x_onhand               OUT NOCOPY NUMBER
  ,x_return_status        OUT NOCOPY VARCHAR2
  ,x_msg_count            OUT NOCOPY NUMBER
  ,x_msg_data             OUT NOCOPY VARCHAR2
) ;

PROCEDURE get_origination_date
(  p_inventory_item_id    IN NUMBER
  ,p_organization_id      IN NUMBER
  ,p_lot_number           IN VARCHAR2
  ,x_orig_date	     OUT NOCOPY DATE
  ,x_return_status        OUT NOCOPY VARCHAR2
) ;

-- bug#6073680 Added this procedure.
PROCEDURE check_lot_exists
(  p_inventory_item_id    IN NUMBER
  ,p_organization_id      IN NUMBER
  ,p_lot_number           IN VARCHAR2
  ,x_lot_exist            OUT NOCOPY VARCHAR2
  ,x_return_status        OUT NOCOPY VARCHAR2
) ;

/*
PROCEDURE update_inv_lot_attr (
   p_inventory_item_id        IN NUMBER
   , p_organization_id        IN NUMBER
   , p_lot_number             IN VARCHAR2
   , p_expiration_date          IN DATE
   , p_grade_code             IN VARCHAR2
   , p_status_id              IN NUMBER
   , p_origination_type       IN NUMBER
   , p_origination_date       IN DATE
   , p_retest_date            IN DATE
   , p_exp_action_dt          IN DATE
   , p_exp_action_code        IN VARCHAR2
   , p_hold_date              IN DATE
   , p_maturity_date          IN DATE
   , p_vendor_lot_num         IN VARCHAR2
   , x_return_status          OUT NOCOPY VARCHAR2
) ;
*/
   PROCEDURE update_inv_lot_attr(
    x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_inventory_item_id      IN            NUMBER
  , p_organization_id        IN            NUMBER
  , p_lot_number             IN            VARCHAR2
  , p_source                 IN            NUMBER
  , p_expiration_date        IN            DATE DEFAULT NULL
  , p_grade_code             IN            VARCHAR2 DEFAULT NULL
  , p_origination_date       IN            DATE DEFAULT NULL
  , p_origination_type       IN            NUMBER DEFAULT NULL
  , p_status_id              IN            NUMBER DEFAULT NULL
  , p_retest_date            IN            DATE DEFAULT NULL
  , p_maturity_date          IN            DATE DEFAULT NULL
  , p_supplier_lot_number    IN            VARCHAR2 DEFAULT NULL
  , p_expiration_action_code IN            VARCHAR2 DEFAULT NULL
  , p_expiration_action_date IN            DATE DEFAULT NULL
  , p_hold_date              IN            DATE DEFAULT NULL
  , p_c_attribute1           IN            VARCHAR2 := NULL
  , p_c_attribute2           IN            VARCHAR2 := NULL
  , p_c_attribute3           IN            VARCHAR2 := NULL
  , p_c_attribute4           IN            VARCHAR2 := NULL
  , p_c_attribute5           IN            VARCHAR2 := NULL
  , p_c_attribute6           IN            VARCHAR2 := NULL
  , p_c_attribute7           IN            VARCHAR2 := NULL
  , p_c_attribute8           IN            VARCHAR2 := NULL
  , p_c_attribute9           IN            VARCHAR2 := NULL
  , p_c_attribute10          IN            VARCHAR2 := NULL
  , p_c_attribute11          IN            VARCHAR2 := NULL
  , p_c_attribute12          IN            VARCHAR2 := NULL
  , p_c_attribute13          IN            VARCHAR2 := NULL
  , p_c_attribute14          IN            VARCHAR2 := NULL
  , p_c_attribute15          IN            VARCHAR2 := NULL
  , p_c_attribute16          IN            VARCHAR2 := NULL
  , p_c_attribute17          IN            VARCHAR2 := NULL
  , p_c_attribute18          IN            VARCHAR2 := NULL
  , p_c_attribute19          IN            VARCHAR2 := NULL
  , p_c_attribute20          IN            VARCHAR2 := NULL
  , p_d_attribute1           IN            DATE := NULL
  , p_d_attribute2           IN            DATE := NULL
  , p_d_attribute3           IN            DATE := NULL
  , p_d_attribute4           IN            DATE := NULL
  , p_d_attribute5           IN            DATE := NULL
  , p_d_attribute6           IN            DATE := NULL
  , p_d_attribute7           IN            DATE := NULL
  , p_d_attribute8           IN            DATE := NULL
  , p_d_attribute9           IN            DATE := NULL
  , p_d_attribute10          IN            DATE := NULL
  , p_n_attribute1           IN            NUMBER := NULL
  , p_n_attribute2           IN            NUMBER := NULL
  , p_n_attribute3           IN            NUMBER := NULL
  , p_n_attribute4           IN            NUMBER := NULL
  , p_n_attribute5           IN            NUMBER := NULL
  , p_n_attribute6           IN            NUMBER := NULL
  , p_n_attribute7           IN            NUMBER := NULL
  , p_n_attribute8           IN            NUMBER := NULL
  , p_n_attribute9           IN            NUMBER := NULL
  , p_n_attribute10          IN            NUMBER := NULL
   -- bug#6073680 START. Added following parameters to handle WMS Attributes
  , p_description            IN            VARCHAR2 := NULL
  , p_vendor_name            IN            VARCHAR2 := NULL
  , p_date_code              IN            VARCHAR2 := NULL
  , p_change_date            IN            DATE := NULL
  , p_age                    IN            NUMBER := NULL
  , p_item_size              IN            NUMBER := NULL
  , p_color                  IN            VARCHAR2 := NULL
  , p_volume                 IN            NUMBER := NULL
  , p_volume_uom             IN            VARCHAR2 := NULL
  , p_place_of_origin        IN            VARCHAR2 := NULL
  , p_best_by_date           IN            DATE := NULL
  , p_length                 IN            NUMBER := NULL
  , p_length_uom             IN            VARCHAR2 := NULL
  , p_recycled_content       IN            NUMBER := NULL
  , p_thickness              IN            NUMBER := NULL
  , p_thickness_uom          IN            VARCHAR2 := NULL
  , p_width                  IN            NUMBER := NULL
  , p_width_uom              IN            VARCHAR2 := NULL
  , p_curl_wrinkle_fold      IN            VARCHAR2 := NULL
  , p_lot_attribute_category IN            VARCHAR2 := NULL
  , p_territory_code         IN            VARCHAR2 := NULL
  , p_vendor_id              IN            VARCHAR2 := NULL
  , p_parent_lot_number      IN            VARCHAR2 := NULL
   -- bug#6073680 END. Added following parameters to handle WMS Attributes
);

PROCEDURE log_transaction_rec(
       p_mtli_lot_rec         IN  MTL_TRANSACTION_LOTS_INTERFACE%ROWTYPE
      ,p_mti_trx_rec          IN  MTL_TRANSACTIONS_INTERFACE%ROWTYPE
      ,p_mtlt_lot_rec         IN  MTL_TRANSACTION_LOTS_TEMP%ROWTYPE
      ,p_mmtt_trx_rec         IN  MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
      ,p_table		      IN  NUMBER
   );

PROCEDURE get_lot_expiration_date
  ( p_mtli_lot_rec         IN  MTL_TRANSACTION_LOTS_INTERFACE%ROWTYPE
   ,p_mti_trx_rec	         IN  MTL_TRANSACTIONS_INTERFACE%ROWTYPE
   ,p_mtlt_lot_rec         IN  MTL_TRANSACTION_LOTS_TEMP%ROWTYPE
   ,p_mmtt_trx_rec	      IN  MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
   ,p_table		            IN  NUMBER
   ,x_lot_expiration_date  OUT NOCOPY DATE
   ,x_return_status        OUT NOCOPY VARCHAR2
  );
END INV_CALCULATE_EXP_DATE;

/
