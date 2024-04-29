--------------------------------------------------------
--  DDL for Package INV_RCV_INTEGRATION_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_INTEGRATION_APIS" AUTHID CURRENT_USER AS
/* $Header: INVRCVIS.pls 120.0.12010000.2 2012/06/14 06:14:43 jianpyu ship $*/

G_EXISTS_ONLY	         CONSTANT	NUMBER := 1;
G_EXISTS_OR_CREATE       CONSTANT	NUMBER := 2;
G_EXISTS_OR_VALIDATE     CONSTANT       NUMBER := 3;

G_SHIP		               CONSTANT	NUMBER := 1;
G_RECEIVE		       CONSTANT	NUMBER := 2;
G_DELIVER		       CONSTANT	NUMBER := 3;
G_TRANSFER	               CONSTANT	NUMBER := 4;
G_CORRECT		       CONSTANT	NUMBER := 5;
G_RETURN_TO_RCV	               CONSTANT	NUMBER := 6;
G_RETURN_TO_VENDOR             CONSTANT	NUMBER := 7;
G_ACCEPT		       CONSTANT	NUMBER := 8;
G_REJECT		       CONSTANT	NUMBER := 8;

G_RET_STS_ERROR	       CONSTANT	VARCHAR2(1) := fnd_api.g_ret_sts_error;
G_RET_STS_UNEXP_ERR    CONSTANT	VARCHAR2(1) := fnd_api.g_ret_sts_unexp_error;
G_RET_STS_SUCCESS      CONSTANT	VARCHAR2(1) := FND_API.g_ret_sts_success;
G_TRUE		       CONSTANT	VARCHAR2(1) := fnd_api.g_true;
G_FALSE		       CONSTANT	VARCHAR2(1) := fnd_api.g_false;

G_PROD_CODE            CONSTANT VARCHAR2(5) := 'RCV';

G_YES             CONSTANT VARCHAR2(1) := 'Y';
G_NO              CONSTANT VARCHAR2(1) := 'N';

g_empty_char_tbl  inv_lot_api_pub.char_tbl;
g_empty_num_tbl   inv_lot_api_pub.number_tbl;
g_empty_date_tbl  inv_lot_api_pub.date_tbl;

-- Bug 3446419
-- Added primary quantity for Lot/Serial validations in the record type
-- if uom_code, organization_id,item_id is not passed then we will
-- get info from RTI to convert quantity to primary_quantity
-- to do the validation

TYPE child_record_info IS RECORD
  (orig_interface_trx_id	NUMBER,
   new_interface_trx_id		NUMBER,
   quantity       	        NUMBER,
   to_organization_id           NUMBER      default null,
   item_id                      NUMBER      default null,
   uom_code                     varchar2(3) default null,
   sec_uom_code VARCHAR2(3) DEFAULT NULL,
   sec_qty NUMBER DEFAULT NULL,
   lot_number VARCHAR(80) ); -- for 13972742

TYPE child_rec_tb_tp IS TABLE OF child_record_info
  INDEX BY BINARY_INTEGER;

TYPE number_tb_type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

TYPE mol_in_rec IS RECORD
  ( prim_qty NUMBER,
    line_id NUMBER,
    sec_qty NUMBER,
    wdd_id NUMBER,
    reservation_id NUMBER
    );

TYPE mo_in_tb_tp IS TABLE OF mol_in_rec
  INDEX BY BINARY_INTEGER;

procedure insert_wlpni
  (p_api_version		        IN  	NUMBER
   , p_init_msg_lst		        IN  	VARCHAR2 DEFAULT g_false
   , x_return_status              OUT 	NOCOPY	VARCHAR2
   , x_msg_count                  OUT 	NOCOPY	NUMBER
   , x_msg_data                   OUT 	NOCOPY	VARCHAR2
   , p_ORGANIZATION_ID            	IN 	NUMBER
   , p_LPN_ID                		IN	NUMBER
   , p_license_plate_number             IN 	VARCHAR2
   , p_LPN_GROUP_ID                  	IN 	NUMBER
   , p_PARENT_LPN_ID                 	IN 	NUMBER   DEFAULT NULL
   , p_PARENT_LICENSE_PLATE_NUMBER      IN 	VARCHAR2 DEFAULT NULL
   , p_REQUEST_ID                    	IN 	NUMBER   DEFAULT NULL
   , p_INVENTORY_ITEM_ID       	        IN 	NUMBER   DEFAULT NULL
   , p_REVISION                      	IN 	VARCHAR2 DEFAULT NULL
   , p_LOT_NUMBER                    	IN 	VARCHAR2 DEFAULT NULL
   , p_SERIAL_NUMBER                 	IN 	VARCHAR2 DEFAULT NULL
   , p_SUBINVENTORY_CODE     	        IN 	VARCHAR2 DEFAULT NULL
   , p_LOCATOR_ID                    	IN 	NUMBER   DEFAULT NULL
   , p_GROSS_WEIGHT_UOM_CODE            IN 	VARCHAR2 DEFAULT NULL
   , p_GROSS_WEIGHT                  	IN 	NUMBER   DEFAULT NULL
  , p_CONTENT_VOLUME_UOM_CODE           IN 	VARCHAR2 DEFAULT NULL
  , p_CONTENT_VOLUME          	        IN 	NUMBER   DEFAULT NULL
  , p_TARE_WEIGHT_UOM_CODE              IN 	VARCHAR2 DEFAULT NULL
  , p_TARE_WEIGHT                   	IN 	NUMBER   DEFAULT NULL
  , p_STATUS_ID                     	IN 	NUMBER   DEFAULT NULL
  , p_SEALED_STATUS                 	IN 	NUMBER   DEFAULT NULL
  , p_ATTRIBUTE_CATEGORY    	        IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE1                    	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE2                    	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE3                    	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE4                    	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE5                    	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE6                    	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE7                    	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE8                    	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE9                    	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE10                   	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE11                   	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE12                   	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE13                   	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE14                   	IN 	VARCHAR2 DEFAULT NULL
  , p_ATTRIBUTE15                   	IN 	VARCHAR2 DEFAULT NULL
  , p_COST_GROUP_ID                 	IN 	NUMBER   DEFAULT NULL
  , p_LPN_CONTEXT                   	IN 	NUMBER   DEFAULT NULL
  , p_LPN_REUSABILITY             	IN 	NUMBER   DEFAULT NULL
  , p_OUTERMOST_LPN_ID        	        IN 	NUMBER   DEFAULT NULL
  , p_outermost_lpn                     IN 	VARCHAR2 DEFAULT NULL
  , p_HOMOGENEOUS_CONTAINER             IN 	NUMBER   DEFAULT NULL
  , p_SOURCE_TYPE_ID                	IN 	NUMBER   DEFAULT NULL
  , p_SOURCE_HEADER_ID         	        IN 	NUMBER   DEFAULT NULL
  , p_SOURCE_LINE_ID                	IN 	NUMBER   DEFAULT NULL
  , p_SOURCE_LINE_DETAIL_ID	        IN 	NUMBER   DEFAULT NULL
  , p_SOURCE_NAME                   	IN 	VARCHAR2 DEFAULT NULL
  );

/*----------------------------------------------------------------------------
  * PROCEDURE: insert_mtli
  * Description:
  *   This procedure inserts a record into MTL_TRANSACTION_LOTS_INTERFACE
  *     If there already exists a record with the transaction_interface_id
  *           and lot_number combination THEN
  *       Update transaction_quantity and primary_quantity
  *     Else
  *       Insert a new record into MTL_TRANSACTION_LOTS_INTERFACE
  *
  *    @param p_api_version             - Version of the API
  *    @param p_init_msg_lst            - Flag to initialize message list
  *    @param x_return_status
  *      Return status indicating Success (S), Error (E), Unexpected Error (U)
  *    @param x_msg_count
  *      Number of messages in  message list
  *    @param x_msg_data
  *      Stacked messages text
  *    @param p_transaction_interface_id - MTLI.Interface Transaction ID
  *    @param p_lot_number              - Lot Number
  *    @param p_transaction_quantity    - Transaction Quantity for the lot
  *    @param p_primary_quantity        - Primary Quantity for the lot
  *    @param p_organization_id         - Organization ID
  *    @param p_inventory_item_id       - Inventory Item ID
  *    @param p_expiration_date         - Lot Expiration Date
  *    @param p_status_id               - Material Status for the lot
  *    @param x_serial_transaction_temp_id
  *           - Serial Transaction Temp Id (for lot and serial controlled item)
  *    @param p_product_transaction_id  - Product Transaction Id. This parameter
  *           is stamped with the transaction identifier with
  *    @param p_product_code            - Code of the product creating this record
  *    @param p_att_exist               - Flag to indicate if attributes exist
  *    @param p_update_mln              - Flag to update MLN with attributes
  *    @param named attributes          - Named attributes
  *    @param C Attributes              - Character atributes (1 - 20)
  *    @param D Attributes              - Date atributes (1 - 10)
  *    @param N Attributes              - Number atributes (1 - 10)
  *    @param p_attribute_cateogry      - Attribute Category
  *    @param Attribute1-15             - INV Lot Attributes
  *
  * @ return: NONE
  *---------------------------------------------------------------------------*/

  PROCEDURE insert_mtli (
      p_api_version                IN             NUMBER
    , p_init_msg_lst               IN             VARCHAR2  DEFAULT G_FALSE
    , x_return_status              OUT  NOCOPY    VARCHAR2
    , x_msg_count                  OUT  NOCOPY    NUMBER
    , x_msg_data                   OUT  NOCOPY    VARCHAR2
    , p_transaction_interface_id   IN OUT NOCOPY  NUMBER
    , p_lot_number                 IN             VARCHAR2
    , p_transaction_quantity       IN             NUMBER
    , p_primary_quantity           IN             NUMBER
    , p_organization_id            IN             NUMBER
    , p_inventory_item_id          IN             NUMBER
    , p_expiration_date            IN             DATE
    , p_status_id                  IN             NUMBER
    , x_serial_transaction_temp_id OUT  NOCOPY    NUMBER
    , p_product_transaction_id     IN OUT NOCOPY  NUMBER
    , p_product_code               IN             VARCHAR2  DEFAULT G_PROD_CODE
    , p_att_exist                  IN             VARCHAR2  DEFAULT G_YES
    , p_update_mln                 IN             VARCHAR2  DEFAULT G_NO
    , p_description                IN             VARCHAR2  DEFAULT NULL
    , p_vendor_name                IN             VARCHAR2  DEFAULT NULL
    , p_supplier_lot_number        IN             VARCHAR2  DEFAULT NULL
    , p_origination_date           IN             DATE      DEFAULT NULL
    , p_date_code                  IN             VARCHAR2  DEFAULT NULL
    , p_grade_code                 IN             VARCHAR2  DEFAULT NULL
    , p_change_date                IN             DATE      DEFAULT NULL
    , p_maturity_date              IN             DATE      DEFAULT NULL
    , p_retest_date                IN             DATE      DEFAULT NULL
    , p_age                        IN             NUMBER    DEFAULT NULL
    , p_item_size                  IN             NUMBER    DEFAULT NULL
    , p_color                      IN             VARCHAR2  DEFAULT NULL
    , p_volume                     IN             NUMBER    DEFAULT NULL
    , p_volume_uom                 IN             VARCHAR2  DEFAULT NULL
    , p_place_of_origin            IN             VARCHAR2  DEFAULT NULL
    , p_best_by_date               IN             DATE      DEFAULT NULL
    , p_length                     IN             NUMBER    DEFAULT NULL
    , p_length_uom                 IN             VARCHAR2  DEFAULT NULL
    , p_recycled_content           IN             NUMBER    DEFAULT NULL
    , p_thickness                  IN             NUMBER    DEFAULT NULL
    , p_thickness_uom              IN             VARCHAR2  DEFAULT NULL
    , p_width                      IN             NUMBER    DEFAULT NULL
    , p_width_uom                  IN             VARCHAR2  DEFAULT NULL
    , p_curl_wrinkle_fold          IN             VARCHAR2  DEFAULT NULL
    , p_vendor_id                  IN             NUMBER    DEFAULT NULL
    , p_territory_code             IN             VARCHAR2  DEFAULT NULL
    , p_lot_attribute_category     IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute1               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute2               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute3               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute4               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute5               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute6               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute7               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute8               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute9               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute10              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute11              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute12              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute13              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute14              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute15              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute16              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute17              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute18              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute19              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute20              IN             VARCHAR2  DEFAULT NULL
    , p_d_attribute1               IN             DATE      DEFAULT NULL
    , p_d_attribute2               IN             DATE      DEFAULT NULL
    , p_d_attribute3               IN             DATE      DEFAULT NULL
    , p_d_attribute4               IN             DATE      DEFAULT NULL
    , p_d_attribute5               IN             DATE      DEFAULT NULL
    , p_d_attribute6               IN             DATE      DEFAULT NULL
    , p_d_attribute7               IN             DATE      DEFAULT NULL
    , p_d_attribute8               IN             DATE      DEFAULT NULL
    , p_d_attribute9               IN             DATE      DEFAULT NULL
    , p_d_attribute10              IN             DATE      DEFAULT NULL
    , p_n_attribute1               IN             NUMBER    DEFAULT NULL
    , p_n_attribute2               IN             NUMBER    DEFAULT NULL
    , p_n_attribute3               IN             NUMBER    DEFAULT NULL
    , p_n_attribute4               IN             NUMBER    DEFAULT NULL
    , p_n_attribute5               IN             NUMBER    DEFAULT NULL
    , p_n_attribute6               IN             NUMBER    DEFAULT NULL
    , p_n_attribute7               IN             NUMBER    DEFAULT NULL
    , p_n_attribute8               IN             NUMBER    DEFAULT NULL
    , p_n_attribute9               IN             NUMBER    DEFAULT NULL
    , p_n_attribute10              IN             NUMBER    DEFAULT NULL
    , p_attribute_category         IN             VARCHAR2  DEFAULT NULL
    , p_attribute1                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute2                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute3                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute4                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute5                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute6                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute7                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute8                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute9                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute10                IN             VARCHAR2  DEFAULT NULL
    , p_attribute11                IN             VARCHAR2  DEFAULT NULL
    , p_attribute12                IN             VARCHAR2  DEFAULT NULL
    , p_attribute13                IN             VARCHAR2  DEFAULT NULL
    , p_attribute14                IN             VARCHAR2  DEFAULT NULL
    , p_attribute15                IN             VARCHAR2  DEFAULT NULL
    , p_from_org_id                IN             NUMBER    DEFAULT NULL
    , p_secondary_quantity         IN             NUMBER  DEFAULT NULL--OPM Convergence
    , p_origination_type           IN             NUMBER DEFAULT NULL--OPM Convergence
    , p_expiration_action_code     IN             VARCHAR2 DEFAULT NULL--OPM Convergence
    , p_expiration_action_date     IN             DATE DEFAULT NULL-- OPM Convergence
    , p_hold_date                  IN             DATE DEFAULT NULL--OPM Convergence
    , p_parent_lot_number          IN             VARCHAR2 DEFAULT NULL--OPM Convergence
    , p_reasond_id                 IN             NUMBER DEFAULT NULL--OPM convergence
    );

/*----------------------------------------------------------------------------
  * PROCEDURE: insert_msni
  * Description:
  *   This procedure inserts a record into MTL_SERIAL_NUMBERS_INTERFACE
  *     Generate transaction_interface_id if the parameter is NULL
  *     Generate product_transaction_id if the parameter is NULL
  *     The insert logic is based on the parameter p_att_exist.
  *     If p_att_exist is "N" Then (attributes are not available in table)
  *       Read the input parameters (including attributes) into a PL/SQL table
  *       Insert one record into MSNI with the from and to serial numbers passed
  *     Else
  *       Loop through each serial number between the from and to serial number
  *       Fetch the attributes into one row of the PL/SQL table and
  *     For each row in the PL/SQL table, insert one MSNI record
  *     End If
  *
  *    @param p_api_version             - Version of the API
  *    @param p_init_msg_lst            - Flag to initialize message list
  *    @param x_return_status
  *      Return status indicating Success (S), Error (E), Unexpected Error (U)
  *    @param x_msg_count
  *      Number of messages in  message list
  *    @param x_msg_data
  *      Stacked messages text
  *    @param p_transaction_interface_id - MTLI.Interface Transaction ID
  *    @param p_fm_serial_number         - From Serial Number
  *    @param p_to_serial_number         - To Serial Number
  *    @param p_organization_id         - Organization ID
  *    @param p_inventory_item_id       - Inventory Item ID
  *    @param p_status_id               - Material Status for the lot
  *    @param p_product_transaction_id  - Product Transaction Id. This parameter
  *           is stamped with the transaction identifier with
  *    @param p_product_code            - Code of the product creating this record
  *    @param p_att_exist               - Flag to indicate if attributes exist
  *    @param p_update_msn              - Flag to update MSN with attributes
  *    @param named attributes          - Named attributes
  *    @param C Attributes              - Character atributes (1 - 20)
  *    @param D Attributes              - Date atributes (1 - 10)
  *    @param N Attributes              - Number atributes (1 - 10)
  *    @param p_attribute_cateogry      - Attribute Category
  *    @param Attribute1-15             - INV Lot Attributes
  *
  * @ return: NONE
  *---------------------------------------------------------------------------*/

  PROCEDURE insert_msni (
      p_api_version                IN             NUMBER
    , p_init_msg_lst               IN             VARCHAR2  DEFAULT G_FALSE
    , x_return_status              OUT  NOCOPY    VARCHAR2
    , x_msg_count                  OUT  NOCOPY    NUMBER
    , x_msg_data                   OUT  NOCOPY    VARCHAR2
    , p_transaction_interface_id   IN OUT NOCOPY  NUMBER
    , p_fm_serial_number           IN             VARCHAR2
    , p_to_serial_number           IN             VARCHAR2
    , p_organization_id            IN             NUMBER
    , p_inventory_item_id          IN             NUMBER
    , p_status_id                  IN             NUMBER
    , p_product_transaction_id     IN OUT NOCOPY  NUMBER
    , p_product_code               IN             VARCHAR2
    , p_att_exist                  IN             VARCHAR2  DEFAULT G_YES
    , p_update_msn                 IN             VARCHAR2  DEFAULT G_NO
    , p_vendor_serial_number       IN             VARCHAR2  DEFAULT NULL
    , p_vendor_lot_number          IN             VARCHAR2  DEFAULT NULL
    , p_parent_serial_number       IN             VARCHAR2  DEFAULT NULL
    , p_origination_date           IN             DATE      DEFAULT NULL
    , p_territory_code	           IN             VARCHAR2  DEFAULT NULL
    , p_time_since_new             IN             NUMBER    DEFAULT NULL
    , p_cycles_since_new           IN             NUMBER    DEFAULT NULL
    , p_time_since_overhaul        IN             NUMBER    DEFAULT NULL
    , p_cycles_since_overhaul      IN             NUMBER    DEFAULT NULL
    , p_time_since_repair          IN             NUMBER    DEFAULT NULL
    , p_cycles_since_repair        IN             NUMBER    DEFAULT NULL
    , p_time_since_visit           IN             NUMBER    DEFAULT NULL
    , p_cycles_since_visit         IN             NUMBER    DEFAULT NULL
    , p_time_since_mark            IN             NUMBER    DEFAULT NULL
    , p_cycles_since_mark          IN             NUMBER    DEFAULT NULL
    , p_number_of_repairs          IN             NUMBER    DEFAULT NULL
    , p_serial_attribute_category  IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute1               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute2               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute3               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute4               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute5               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute6               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute7               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute8               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute9               IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute10              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute11              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute12              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute13              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute14              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute15              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute16              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute17              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute18              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute19              IN             VARCHAR2  DEFAULT NULL
    , p_c_attribute20              IN             VARCHAR2  DEFAULT NULL
    , p_d_attribute1               IN             DATE      DEFAULT NULL
    , p_d_attribute2               IN             DATE      DEFAULT NULL
    , p_d_attribute3               IN             DATE      DEFAULT NULL
    , p_d_attribute4               IN             DATE      DEFAULT NULL
    , p_d_attribute5               IN             DATE      DEFAULT NULL
    , p_d_attribute6               IN             DATE      DEFAULT NULL
    , p_d_attribute7               IN             DATE      DEFAULT NULL
    , p_d_attribute8               IN             DATE      DEFAULT NULL
    , p_d_attribute9               IN             DATE      DEFAULT NULL
    , p_d_attribute10              IN             DATE      DEFAULT NULL
    , p_n_attribute1               IN             NUMBER    DEFAULT NULL
    , p_n_attribute2               IN             NUMBER    DEFAULT NULL
    , p_n_attribute3               IN             NUMBER    DEFAULT NULL
    , p_n_attribute4               IN             NUMBER    DEFAULT NULL
    , p_n_attribute5               IN             NUMBER    DEFAULT NULL
    , p_n_attribute6               IN             NUMBER    DEFAULT NULL
    , p_n_attribute7               IN             NUMBER    DEFAULT NULL
    , p_n_attribute8               IN             NUMBER    DEFAULT NULL
    , p_n_attribute9               IN             NUMBER    DEFAULT NULL
    , p_n_attribute10              IN             NUMBER    DEFAULT NULL
    , p_attribute_category         IN             VARCHAR2  DEFAULT NULL
    , p_attribute1                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute2                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute3                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute4                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute5                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute6                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute7                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute8                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute9                 IN             VARCHAR2  DEFAULT NULL
    , p_attribute10                IN             VARCHAR2  DEFAULT NULL
    , p_attribute11                IN             VARCHAR2  DEFAULT NULL
    , p_attribute12                IN             VARCHAR2  DEFAULT NULL
    , p_attribute13                IN             VARCHAR2  DEFAULT NULL
    , p_attribute14                IN             VARCHAR2  DEFAULT NULL
    , p_attribute15                IN             VARCHAR2  DEFAULT NULL
    );

function validate_lot_number
  (p_api_version	      IN  	    NUMBER
   , p_init_msg_lst	      IN  	    VARCHAR2 DEFAULT g_false
   , x_return_status          OUT NOCOPY    VARCHAR2
   , x_msg_count              OUT NOCOPY    NUMBER
   , x_msg_data               OUT NOCOPY    VARCHAR2
   , x_is_new_lot             OUT NOCOPY    VARCHAR2
   , p_validation_mode	      IN	    NUMBER   DEFAULT G_EXISTS_ONLY
   , p_org_id                 IN       	    NUMBER
   , p_inventory_item_id      IN       	    NUMBER
   , p_lot_number     	      IN       	    VARCHAR2
   , p_expiration_date        IN            DATE     DEFAULT NULL
   , p_txn_type	              IN	    NUMBER   DEFAULT G_SHIP
   , p_disable_flag           IN            NUMBER   DEFAULT NULL
   , p_attribute_category     IN            VARCHAR2 DEFAULT NULL
   , p_lot_attribute_category IN            VARCHAR2 DEFAULT NULL
   , p_attributes_tbl         IN            inv_lot_api_pub.char_tbl   DEFAULT g_empty_char_tbl
   , p_c_attributes_tbl       IN            inv_lot_api_pub.char_tbl   DEFAULT g_empty_char_tbl
   , p_n_attributes_tbl       IN            inv_lot_api_pub.number_tbl DEFAULT g_empty_num_tbl
   , p_d_attributes_tbl       IN            inv_lot_api_pub.date_tbl   DEFAULT g_empty_date_tbl
   , p_grade_code             IN            VARCHAR2 DEFAULT NULL
   , p_origination_date       IN            DATE     DEFAULT NULL
   , p_date_code              IN            VARCHAR2 DEFAULT NULL
   , p_status_id              IN            NUMBER   DEFAULT NULL
   , p_change_date            IN            DATE     DEFAULT NULL
   , p_age                    IN            NUMBER   DEFAULT NULL
   , p_retest_date            IN            DATE     DEFAULT NULL
   , p_maturity_date          IN            DATE     DEFAULT NULL
   , p_item_size              IN            NUMBER   DEFAULT NULL
   , p_color                  IN            VARCHAR2 DEFAULT NULL
   , p_volume                 IN            NUMBER   DEFAULT NULL
   , p_volume_uom             IN            VARCHAR2 DEFAULT NULL
   , p_place_of_origin        IN            VARCHAR2 DEFAULT NULL
   , p_best_by_date           IN            DATE     DEFAULT NULL
   , p_length                 IN            NUMBER   DEFAULT NULL
   , p_length_uom             IN            VARCHAR2 DEFAULT NULL
   , p_recycled_content       IN            NUMBER   DEFAULT NULL
   , p_thickness              IN            NUMBER   DEFAULT NULL
   , p_thickness_uom          IN            VARCHAR2 DEFAULT NULL
   , p_width                  IN            NUMBER   DEFAULT NULL
   , p_width_uom              IN            VARCHAR2 DEFAULT NULL
   , p_territory_code         IN            VARCHAR2 DEFAULT NULL
   , p_supplier_lot_number    IN            VARCHAR2 DEFAULT NULL
   , p_vendor_name            IN            VARCHAR2 DEFAULT NULL
   ) return boolean;

function validate_serial_range
  (p_api_version	 IN  		NUMBER
   , p_init_msg_lst	 IN  		VARCHAR2 DEFAULT g_false
   , x_return_status     OUT 	NOCOPY	VARCHAR2
   , x_msg_count         OUT 	NOCOPY	NUMBER
   , x_msg_data          OUT 	NOCOPY	VARCHAR2
   , p_validation_mode	 IN		NUMBER   DEFAULT G_EXISTS_ONLY
   , p_org_id            IN       	NUMBER
   , p_inventory_item_id IN             NUMBER
   , p_quantity	         IN       	NUMBER
   , p_revision	         IN       	VARCHAR2
   , p_lot_number	 IN       	VARCHAR2
   , p_fm_serial_number  IN       	VARCHAR2
   , p_to_serial_number	 IN OUT	NOCOPY	VARCHAR2
   , p_txn_type	         IN		NUMBER   DEFAULT G_SHIP
   ) return boolean;

function validate_lot_serial_info
  (p_api_version	IN  		NUMBER
   , p_init_msg_lst	IN  		VARCHAR2 DEFAULT g_false
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_validation_mode	IN		NUMBER   DEFAULT G_EXISTS_OR_CREATE
   , p_rti_id           IN       	NUMBER
   ) return boolean;

function generate_lot_number
  (p_api_version	 IN  		NUMBER
   , p_init_msg_lst	 IN  		VARCHAR2 DEFAULT g_false
   , p_commit	         IN		VARCHAR2 DEFAULT g_false
   , x_return_status     OUT 	NOCOPY	VARCHAR2
   , x_msg_count         OUT 	NOCOPY	NUMBER
   , x_msg_data          OUT 	NOCOPY	VARCHAR2
   , p_org_id            IN       	NUMBER
   , p_inventory_item_id IN       	NUMBER
   ) return VARCHAR2;

procedure generate_serial_numbers
  (p_api_version	 IN  		NUMBER
   , p_init_msg_lst	 IN  		VARCHAR2 DEFAULT g_false
   , p_commit	         IN		VARCHAR2 DEFAULT g_false
   , x_return_status     OUT 	NOCOPY	VARCHAR2
   , x_msg_count         OUT 	NOCOPY	NUMBER
   , x_msg_data          OUT 	NOCOPY	VARCHAR2
   , p_org_id            IN       	NUMBER
   , p_inventory_item_id IN       	NUMBER
   , p_quantity	         IN       	NUMBER
   , p_revision	         IN       	VARCHAR2
   , p_lot_number	 IN       	VARCHAR2
   , x_start_serial	 OUT	NOCOPY	VARCHAR2
   , x_end_serial	 OUT	NOCOPY	VARCHAR2
   );

function validate_lpn
  (p_api_version	IN  		NUMBER
   , p_init_msg_lst	IN  		VARCHAR2 DEFAULT g_false
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_validation_mode	IN		NUMBER   DEFAULT G_EXISTS_ONLY
   , p_org_id           IN       	NUMBER
   , p_lpn_id     	IN OUT	NOCOPY	NUMBER
   , p_lpn     		IN       	VARCHAR2
   , p_parent_lpn_id	IN		NUMBER   DEFAULT NULL
   ) return boolean;

function validate_lpn_info
  (p_api_version	IN  		NUMBER DEFAULT 1.0
   , p_init_msg_lst	IN  		VARCHAR2 DEFAULT g_false
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_validation_mode	IN		NUMBER   DEFAULT G_EXISTS_OR_CREATE
   , p_lpn_group_id	IN       	NUMBER
   ) return boolean;

procedure generate_lpn
  (p_api_version	IN  		NUMBER
   , p_init_msg_lst	IN  		VARCHAR2 DEFAULT g_false
   , p_commit	        IN	    	VARCHAR2 DEFAULT g_false
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_lpn_id           OUT 	NOCOPY 	NUMBER
   , p_lpn              OUT     NOCOPY  VARCHAR2
   , p_organization_id	IN       	NUMBER
   );

procedure explode_lpn
  (p_api_version	IN  		NUMBER
   , p_init_msg_lst	IN  		VARCHAR2 DEFAULT g_false
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_group_id	        IN       	NUMBER
   , p_request_id	IN       	NUMBER
   );

procedure validate_sub_loc
  (p_api_version	IN  		NUMBER
   , p_init_msg_lst	IN  		VARCHAR2 DEFAULT g_false
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_group_id	        IN       	NUMBER
   , p_request_id	IN       	NUMBER
   , p_rti_id		IN		NUMBER
   , p_validation_mode	IN		NUMBER   DEFAULT G_EXISTS_OR_CREATE
   );

function split_lot_serial
  (p_api_version	IN  		NUMBER DEFAULT 1.0
   , p_init_msg_lst	IN  		VARCHAR2 DEFAULT g_false
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_new_rti_info	IN		inv_rcv_integration_apis.child_rec_tb_tp
   ) return boolean;

function process_transaction
  (p_api_version	IN  		NUMBER
   , p_init_msg_lst	IN  		VARCHAR2 DEFAULT g_false
   , x_return_status    OUT 	NOCOPY	VARCHAR2
   , x_msg_count        OUT 	NOCOPY	NUMBER
   , x_msg_data         OUT 	NOCOPY	VARCHAR2
   , p_rti_id           IN       	NUMBER
   ) return boolean;

function complete_lpn_group
  (p_api_version	  IN  		NUMBER
   , p_init_msg_lst	  IN  		VARCHAR2 DEFAULT g_false
   , x_return_status      OUT 	NOCOPY	VARCHAR2
   , x_msg_count          OUT 	NOCOPY	NUMBER
   , x_msg_data           OUT 	NOCOPY	VARCHAR2
   , p_lpn_group_id       IN       	NUMBER
   , p_group_id        	  IN       	NUMBER
   , p_shipment_header_id IN		NUMBER
   ) return boolean;

 /*-----------------------------------------------------------------------------
  * PROCEDURE: split_mo
  * Description:
  *  Takes in an original MOL id, and a table of quantities as
[ *  arguments.  This procedure will split the original MOL, and return
  *  a table of MOL id, each of them having the quantities specified in
  *  the input quantities table.  This procedure will also split the MMTTS
  *  corresponding to the original MOL and associate them with the new
  *  MOLs.  For example:
  *
  *  MOL1   Quantity:14   Quantity_delivered:4 Quantity_detailed:8
  *
  *  Calling split_mo(p_orig_mol_id => MOL1, ( 7, 2 )) will create the
  *  following entries:
  *
  *  MOL1 QUANTITY 5      Quantity_delivered:4 Quantity_detailed:0
  *  MMTT2 MOL1 QUANTITY 1
  *
  *  MOL2   QUANTITY7     Quantity_delivered:0 Quantity_detailed:7
  *  MMTT1 MOL2 QUANTITY 4
  *  MMTT3 MOL2 QUANTITY 3
  *
  *  MOL3  QUANTITY 2     Quantity_delivered:0 Quantity_detailed:1
  *  MMTT2 MOL3 QUANTITY:1
  *
  *  Note that there the specific association of MMTTs with MOLs will
  *  depends on the original MOL, and this procedure will only guarantee that the
  *  final values will be consistent
  *  consistent.
  * Output Parameters:
  *    x_mol_id_tb
  *      - new MOL ids created.  Its index correspond to the index of
  *        p_prim_qty_tb, i.e. x_mol_id_tb(1) has quantity
  *        p_prim_qty_tb(1)
  *    x_return_status
  *      - Return status indicating Success (S), Error (E), Unexpected
  *        Error (U)
  *    x_msg_count
  *      - Number of messages in  message list
  *    x_msg_data
  *      - Stacked messages text
  *
  * Input Parameters:
  *    p_orig_mol_id     - The line_id of the mol to be split
  *    p_prim_qty_tb     - primary_quantity to be split
  * Returns: NONE
  *---------------------------------------------------------------------------*/
PROCEDURE split_mo
  (p_orig_mol_id    IN NUMBER,
   p_mo_splt_tb     IN OUT nocopy mo_in_tb_tp,
   p_updt_putaway_temp_tbl IN VARCHAR2 DEFAULT fnd_api.g_false,
   p_txn_header_id  IN NUMBER DEFAULT NULL,
   p_operation_type IN VARCHAR2 DEFAULT NULL,
   x_return_status  OUT   NOCOPY VARCHAR2,
   x_msg_count      OUT   NOCOPY NUMBER,
   x_msg_data       OUT   NOCOPY VARCHAR2
   );

PROCEDURE split_mmtt
  (p_orig_mmtt_id      NUMBER
   ,p_prim_qty_to_splt NUMBER
   ,p_prim_uom_code    VARCHAR2
   ,x_new_mmtt_id      OUT nocopy NUMBER
   ,x_return_status    OUT NOCOPY VARCHAR2
   ,x_msg_count        OUT NOCOPY NUMBER
   ,x_msg_data         OUT NOCOPY VARCHAR2
   );
END inv_rcv_integration_apis;

/
