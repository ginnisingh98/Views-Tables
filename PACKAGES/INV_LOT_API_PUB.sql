--------------------------------------------------------
--  DDL for Package INV_LOT_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_API_PUB" AUTHID CURRENT_USER AS
  /* $Header: INVPLOTS.pls 120.3.12010000.10 2011/11/11 13:03:13 kbavadek ship $ */

  /**
   * global variable for lots attributes
   */
  g_lot_attributes_tbl           inv_lot_sel_attr.lot_sel_attributes_tbl_type;
  g_firstscan                    BOOLEAN                                      := TRUE;

  G_WMS_INSTALLED 		 VARCHAR2(10);

  TYPE char_tbl IS TABLE OF VARCHAR2(1000)
    INDEX BY BINARY_INTEGER;

  TYPE number_tbl IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  TYPE date_tbl IS TABLE OF DATE
    INDEX BY BINARY_INTEGER;

  TYPE WMS_NAMED_ATTRIBUTES IS RECORD
  (      grade_code         VARCHAR2(150)
       , DISABLE_FLAG       NUMBER
       , origination_date   DATE
       , date_code          VARCHAR2(150)
       , change_date        DATE
       , age                NUMBER
       , retest_date        DATE
       , maturity_date      DATE
       , item_size          NUMBER
       , color              VARCHAR2(150)
       , volume             NUMBER
       , volume_uom         VARCHAR2(3)
       , place_of_origin    VARCHAR2(150)
       , best_by_date       DATE
       , length             NUMBER
       , length_uom         VARCHAR2(3)
       , recycled_content   NUMBER
       , thickness          NUMBER
       , thickness_uom      VARCHAR2(3)
       , width              NUMBER
       , width_uom          VARCHAR2(3)
       , territory_code     VARCHAR2(30)
       , supplier_lot_number VARCHAR2(150)
       , VENDOR_NAME         VARCHAR2(240)
   );

  g_ret_sts_success     CONSTANT VARCHAR2(1)                                  := 'S';
  g_ret_sts_error       CONSTANT VARCHAR2(1)                                  := 'E';
  g_ret_sts_unexp_error CONSTANT VARCHAR2(1)                                  := 'U';
  g_miss_num            CONSTANT NUMBER                                       := 9.99e125;
  g_miss_char           CONSTANT VARCHAR2(1)                                  := CHR(0);
  g_miss_date           CONSTANT DATE                                         := TO_DATE('1', 'j');
  /*Exception definitions */
  g_exc_error                    EXCEPTION;
  g_exc_unexpected_error         EXCEPTION;
  /*Local variable for stoRing the INV:DEBUG TRACE profile value */
  g_debug                        NUMBER                                       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  osfm_form_no_validate             CONSTANT NUMBER                                       := 1;
  osfm_open_interface   	    CONSTANT NUMBER                                       := 2;
  osfm_form_validate                CONSTANT NUMBER                                       := 3;
  inv				    CONSTANT NUMBER					  := 4;

  PROCEDURE populateattributescolumn;

  PROCEDURE set_firstscan(p_firstscan BOOLEAN);

  /**
   *  This procedure inserts a lot into the MTL_LOT_NUMBERS table.
   *  It does all the necessary validation before inserting the lot.
   *  It derives the expiration date depending on the controls set
   *  for shelf_life_code and shelf_life_days for the item.
   *  Returns success if it is able to insert the lot.
   *  If the lot already exists for the same item and org, it still
   *  returns success. However, it places a message on the stack
   *  informing that the lot already exists.
   *  It returns error if there is any validation error.
   *  Standard WHO information is used from the fnd_global api.
   */
  PROCEDURE insertlot(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false
  , p_commit                   IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level         IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id        IN            NUMBER
  , p_organization_id          IN            NUMBER
  , p_lot_number               IN            VARCHAR2
  , p_expiration_date          IN OUT NOCOPY DATE
  , p_transaction_temp_id      IN            NUMBER DEFAULT NULL
  , p_transaction_action_id    IN            NUMBER DEFAULT NULL
  , p_transfer_organization_id IN            NUMBER DEFAULT NULL
  , x_object_id                OUT NOCOPY    NUMBER
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , p_parent_lot_number        IN            VARCHAR2 DEFAULT NULL -- bug 10176719 - inserting parent lot number
  );

  PROCEDURE inserttrxlot(
    p_api_version                IN            NUMBER
  , p_init_msg_list              IN            VARCHAR2 := fnd_api.g_false
  , p_commit                     IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level           IN            NUMBER := fnd_api.g_valid_level_full
  , p_primary_quantity           IN            NUMBER DEFAULT NULL
  , p_transaction_id             IN            NUMBER
  , p_inventory_item_id          IN            NUMBER
  , p_organization_id            IN            NUMBER
  , p_transaction_date           IN            DATE
  , p_transaction_source_id      IN            NUMBER
  , p_transaction_source_name    IN            VARCHAR2
  , p_transaction_source_type_id IN            NUMBER
  , p_transaction_temp_id        IN            NUMBER
  , p_transaction_action_id      IN            NUMBER
  , p_serial_transaction_id      IN            NUMBER
  , p_lot_number                 IN            VARCHAR2
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_count                  OUT NOCOPY    NUMBER
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  );

  /* This function (validate_unique_lot) validates a given lot number for an organization and item
     depending on the uniqueness level set
     This function is called from auto_gen_lot function in order to check the uniqueness of
      the generated lot number*/
  FUNCTION validate_unique_lot(p_org_id IN NUMBER, p_inventory_item_id IN NUMBER, p_lot_uniqueness IN NUMBER, p_auto_lot_number IN VARCHAR2)
    RETURN BOOLEAN;

  /* Created a wrapper around validate_unique_lot to be able to call it thru Mobile apps  */
  PROCEDURE validate_unique_lot(
    p_org_id            IN            NUMBER
  , p_inventory_item_id IN            NUMBER
  , p_lot_uniqueness    IN            NUMBER
  , p_auto_lot_number   IN            VARCHAR2
  , p_check_same_item   IN            VARCHAR2
  , x_is_unique         OUT NOCOPY    VARCHAR2
  );



/*================================================
   This function inserts mtl_child_lot_numbers.
  ================================================*/

FUNCTION ins_mtl_child_lot_num (
    p_org_id                     IN            NUMBER
  , p_inventory_item_id          IN            NUMBER
  , p_parent_lot_number          IN            VARCHAR2
  , p_last_child_lot_seq         IN            NUMBER
)
RETURN NUMBER;

/*================================================
   This function updates mtl_child_lot_numbers.
  ================================================*/

FUNCTION upd_mtl_child_lot_num (
    p_org_id                     IN            NUMBER
  , p_inventory_item_id          IN            NUMBER
  , p_parent_lot_number          IN            VARCHAR2
  , p_last_child_lot_seq         IN            NUMBER
)
RETURN NUMBER;







  /**
   * This function ( auto_gen_lot) replaces the auto_gen_lot function in the INVTTELT.pld .
   * It generates a lot number for for a given organization and item id and
   *     these 2 are the mandatory parameters.
   * Other input parameters if not provided, are retrieved in the function .
   * This function calls a user defined pl/sql procedure to generate lot numbers
   * if the user_defined_proc returns a lot number then it validtes the lot_number and returns to the caller
   * if the user_defined_proc returns null then this function generates a lot number, checks for its
   *    validity and returns the lot_number along with the return_status
   */
-- Fix for Bug#12925054
-- Added new parameters p_transaction_source_id and p_transaction_source_line_id

  FUNCTION auto_gen_lot(
    p_org_id                     IN            NUMBER
  , p_inventory_item_id          IN            NUMBER
  , p_lot_generation             IN            NUMBER := NULL
  , p_lot_uniqueness             IN            NUMBER := NULL
  , p_lot_prefix                 IN            VARCHAR2 := NULL
  , p_zero_pad                   IN            NUMBER := NULL
  , p_lot_length                 IN            NUMBER := NULL
  , p_transaction_date           IN            DATE := NULL
  , p_revision                   IN            VARCHAR2 := NULL
  , p_subinventory_code          IN            VARCHAR2 := NULL
  , p_locator_id                 IN            NUMBER := NULL
  , p_transaction_type_id        IN            NUMBER := NULL
  , p_transaction_action_id      IN            NUMBER := NULL
  , p_transaction_source_type_id IN            NUMBER := NULL
  , p_lot_number                 IN            VARCHAR2 := NULL
  , p_api_version                IN            NUMBER
  , p_init_msg_list              IN            VARCHAR2 := fnd_api.g_false
  , p_commit                     IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level           IN            NUMBER := fnd_api.g_valid_level_full
  , p_parent_lot_number          IN            VARCHAR2
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_count                  OUT NOCOPY    NUMBER
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  , p_transaction_source_id      IN            NUMBER DEFAULT  NULL  /* 13368816 */
  , p_transaction_source_line_id IN            NUMBER DEFAULT  NULL  /* 13368816 */
  )
    RETURN VARCHAR2;

  /*	This is a procedure that accepts the Named WMS attributes, C_Attributes,
	N_Attributes, D_attributes, and INV attributes as pl/sql table input parameter
	and validates the values passed as input parameters against the valueset attached to it.
	This has flex Api call that does the actual validation
  */

  PROCEDURE validate_lot_attr_info(
    x_return_status          OUT    NOCOPY VARCHAR2
  , x_msg_count              OUT    NOCOPY NUMBER
  , x_msg_data               OUT    NOCOPY VARCHAR2
  , p_wms_is_installed       IN     VARCHAR2
  , p_attribute_category     IN     VARCHAR2
  , p_lot_attribute_category IN     VARCHAR2
  , p_inventory_item_id      IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_attributes_tbl         IN     inv_lot_api_pub.char_tbl
  , p_c_attributes_tbl       IN     inv_lot_api_pub.char_tbl
  , p_n_attributes_tbl       IN     inv_lot_api_pub.number_tbl
  , p_d_attributes_tbl       IN     inv_lot_api_pub.date_tbl
  , p_disable_flag           IN     NUMBER
  , p_grade_code             IN     VARCHAR2
  , p_origination_date       IN     DATE
  , p_date_code              IN     VARCHAR2
  , p_change_date            IN     DATE
  , p_age                    IN     NUMBER
  , p_retest_date            IN     DATE
  , p_maturity_date          IN     DATE
  , p_item_size              IN     NUMBER
  , p_color                  IN     VARCHAR2
  , p_volume                 IN     NUMBER
  , p_volume_uom             IN     VARCHAR2
  , p_place_of_origin        IN     VARCHAR2
  , p_best_by_date           IN     DATE
  , p_length                 IN     NUMBER
  , p_length_uom             IN     VARCHAR2
  , p_recycled_content       IN     NUMBER
  , p_thickness              IN     NUMBER
  , p_thickness_uom          IN     VARCHAR2
  , p_width                  IN     NUMBER
  , p_width_uom              IN     VARCHAR2
  , p_territory_code         IN     VARCHAR2
  , p_supplier_lot_number    IN     VARCHAR2
  , p_vendor_name            IN     VARCHAR2
  );

  /*

  This is a procedure that accepts the lot attributes as input parameters.
  This procedure validates some the input parameters like lot_number, expiration date,
  INV attributes, C_ATTRIBUTES, N_ATTRIBUTES and D_ATTRIBUTES.
  If all the validations go through fine, data is inserted into mtl_lot_numbers
  */
-- This procedure has now be converted into a stub and it internally calls
-- the overloaded create_inv_lot procedure.

  PROCEDURE create_inv_lot(
    x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_inventory_item_id      IN            NUMBER
  , p_organization_id        IN            NUMBER
  , p_lot_number             IN            VARCHAR2
  , p_expiration_date        IN            DATE
  , p_disable_flag           IN            NUMBER
  , p_attribute_category     IN            VARCHAR2
  , p_lot_attribute_category IN            VARCHAR2
  , p_attributes_tbl         IN            inv_lot_api_pub.char_tbl
  , p_c_attributes_tbl       IN            inv_lot_api_pub.char_tbl
  , p_n_attributes_tbl       IN            inv_lot_api_pub.number_tbl
  , p_d_attributes_tbl       IN            inv_lot_api_pub.date_tbl
  , p_grade_code             IN            VARCHAR2
  , p_origination_date       IN            DATE
  , p_date_code              IN            VARCHAR2
  , p_status_id              IN            NUMBER
  , p_change_date            IN            DATE
  , p_age                    IN            NUMBER
  , p_retest_date            IN            DATE
  , p_maturity_date          IN            DATE
  , p_item_size              IN            NUMBER
  , p_color                  IN            VARCHAR2
  , p_volume                 IN            NUMBER
  , p_volume_uom             IN            VARCHAR2
  , p_place_of_origin        IN            VARCHAR2
  , p_best_by_date           IN            DATE
  , p_length                 IN            NUMBER
  , p_length_uom             IN            VARCHAR2
  , p_recycled_content       IN            NUMBER
  , p_thickness              IN            NUMBER
  , p_thickness_uom          IN            VARCHAR2
  , p_width                  IN            NUMBER
  , p_width_uom              IN            VARCHAR2
  , p_territory_code         IN            VARCHAR2
  , p_supplier_lot_number    IN            VARCHAR2
  , p_vendor_name            IN            VARCHAR2
  , p_source                 IN            NUMBER
  , p_init_msg_list          IN            VARCHAR2  DEFAULT fnd_api.g_false -- bug 7513308
  );

  /*
	This is a procedure that validates the input parameters to the API.
	It does the following validations
	a.	Check if the item passed is a lot controlled Item
	b.	Check for lot uniqueness
	c.	Also has a call to validate the DFF attributes values against the value set
		attached to each of the segments
  */

  PROCEDURE validate_lot_attr_in_param(
    x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_inventory_item_id      IN            NUMBER
  , p_organization_id        IN            NUMBER
  , p_lot_number             IN            VARCHAR2
  , p_attribute_category     IN            VARCHAR2
  , p_lot_attribute_category IN            VARCHAR2
  , p_attributes_tbl         IN            inv_lot_api_pub.char_tbl
  , p_c_attributes_tbl       IN            inv_lot_api_pub.char_tbl
  , p_n_attributes_tbl       IN            inv_lot_api_pub.number_tbl
  , p_d_attributes_tbl       IN            inv_lot_api_pub.date_tbl
  , p_wms_is_installed       IN            VARCHAR2
  , p_source                 IN            NUMBER
  , p_disable_flag           IN            NUMBER
  , p_grade_code             IN            VARCHAR2
  , p_origination_date       IN            DATE
  , p_date_code              IN            VARCHAR2
  , p_change_date            IN            DATE
  , p_age                    IN            NUMBER
  , p_retest_date            IN            DATE
  , p_maturity_date          IN            DATE
  , p_item_size              IN            NUMBER
  , p_color                  IN            VARCHAR2
  , p_volume                 IN            NUMBER
  , p_volume_uom             IN            VARCHAR2
  , p_place_of_origin        IN            VARCHAR2
  , p_best_by_date           IN            DATE
  , p_length                 IN            NUMBER
  , p_length_uom             IN            VARCHAR2
  , p_recycled_content       IN            NUMBER
  , p_thickness              IN            NUMBER
  , p_thickness_uom          IN            VARCHAR2
  , p_width                  IN            NUMBER
  , p_width_uom              IN            VARCHAR2
  , p_territory_code         IN            VARCHAR2
  , p_supplier_lot_number    IN            VARCHAR2
  , p_vendor_name            IN            VARCHAR2
  );

  /*
	This is a procedure that accepts the lot attributes as input parameters.
	This procedure validates some the input parameters like lot_number, expiration_date,
	INV attributes, C_ATTRIBUTES, N_ATTRIBUTES and D_ATTRIBUTES.
	If all the validations go through fine, data is updated in mtl_lot_numbers table
  */
  PROCEDURE update_inv_lot(
    x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_inventory_item_id      IN            NUMBER
  , p_organization_id        IN            NUMBER
  , p_lot_number             IN            VARCHAR2
  , p_expiration_date        IN            DATE DEFAULT NULL
  , p_disable_flag           IN            NUMBER DEFAULT NULL
  , p_attribute_category     IN            VARCHAR2 DEFAULT NULL
  , p_lot_attribute_category IN            VARCHAR2 DEFAULT NULL
  , p_attributes_tbl         IN            inv_lot_api_pub.char_tbl
  , p_c_attributes_tbl       IN            inv_lot_api_pub.char_tbl
  , p_n_attributes_tbl       IN            inv_lot_api_pub.number_tbl
  , p_d_attributes_tbl       IN            inv_lot_api_pub.date_tbl
  , p_grade_code             IN            VARCHAR2 DEFAULT NULL
  , p_origination_date       IN            DATE DEFAULT NULL
  , p_date_code              IN            VARCHAR2 DEFAULT NULL
  , p_status_id              IN            NUMBER DEFAULT NULL
  , p_change_date            IN            DATE DEFAULT NULL
  , p_age                    IN            NUMBER DEFAULT NULL
  , p_retest_date            IN            DATE DEFAULT NULL
  , p_maturity_date          IN            DATE DEFAULT NULL
  , p_item_size              IN            NUMBER DEFAULT NULL
  , p_color                  IN            VARCHAR2 DEFAULT NULL
  , p_volume                 IN            NUMBER DEFAULT NULL
  , p_volume_uom             IN            VARCHAR2 DEFAULT NULL
  , p_place_of_origin        IN            VARCHAR2 DEFAULT NULL
  , p_best_by_date           IN            DATE DEFAULT NULL
  , p_length                 IN            NUMBER DEFAULT NULL
  , p_length_uom             IN            VARCHAR2 DEFAULT NULL
  , p_recycled_content       IN            NUMBER DEFAULT NULL
  , p_thickness              IN            NUMBER DEFAULT NULL
  , p_thickness_uom          IN            VARCHAR2 DEFAULT NULL
  , p_width                  IN            NUMBER DEFAULT NULL
  , p_width_uom              IN            VARCHAR2 DEFAULT NULL
  , p_territory_code         IN            VARCHAR2 DEFAULT NULL
  , p_supplier_lot_number    IN            VARCHAR2 DEFAULT NULL
  , p_vendor_name            IN            VARCHAR2 DEFAULT NULL
  , p_source                 IN            NUMBER
  );

-- nsinghi bug#5209065 START. Added following procedure.
  /*
	This is a procedure that accepts the lot record as input parameters.
	This procedure validates some the input parameters like lot_number, expiration_date,
	INV attributes, C_ATTRIBUTES, N_ATTRIBUTES and D_ATTRIBUTES.
	If all the validations go through fine, data is updated in mtl_lot_numbers table
  */

  PROCEDURE update_inv_lot(
            x_return_status         OUT    NOCOPY VARCHAR2
          , x_msg_count             OUT    NOCOPY NUMBER
          , x_msg_data              OUT    NOCOPY VARCHAR2
          , x_lot_rec               OUT    NOCOPY MTL_LOT_NUMBERS%ROWTYPE
          , p_lot_rec               IN     MTL_LOT_NUMBERS%ROWTYPE
          , p_source                IN     NUMBER
          , p_api_version           IN     NUMBER
          , p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
          , p_commit                IN     VARCHAR2 := fnd_api.g_false);
-- nsinghi bug#5209065 END.

  /*
	This is a procedure that accepts all the unnamed and named WMS attributes and
	validates the values against the valueset attached to it.
  */

  PROCEDURE wms_lot_attr_validate(
    x_return_status          OUT    NOCOPY VARCHAR2
  , x_msg_count              OUT    NOCOPY NUMBER
  , x_msg_data               OUT    NOCOPY VARCHAR2
  , p_inventory_item_id      IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_disable_flag           IN     NUMBER
  , p_lot_attribute_category IN     VARCHAR2
  , p_c_attributes_tbl       IN     inv_lot_api_pub.char_tbl
  , p_n_attributes_tbl       IN     inv_lot_api_pub.number_tbl
  , p_d_attributes_tbl       IN     inv_lot_api_pub.date_tbl
  , p_grade_code             IN     VARCHAR2
  , p_origination_date       IN     DATE
  , p_date_code              IN     VARCHAR2
  , p_change_date            IN     DATE
  , p_age                    IN     NUMBER
  , p_retest_date            IN     DATE
  , p_maturity_date          IN     DATE
  , p_item_size              IN     NUMBER
  , p_color                  IN     VARCHAR2
  , p_volume                 IN     NUMBER
  , p_volume_uom             IN     VARCHAR2
  , p_place_of_origin        IN     VARCHAR2
  , p_best_by_date           IN     DATE
  , p_length                 IN     NUMBER
  , p_length_uom             IN     VARCHAR2
  , p_recycled_content       IN     NUMBER
  , p_thickness              IN     NUMBER
  , p_thickness_uom          IN     VARCHAR2
  , p_width                  IN     NUMBER
  , p_width_uom              IN     VARCHAR2
  , p_territory_code         IN     VARCHAR2
  , p_supplier_lot_number    IN     VARCHAR2
  , p_vendor_name            IN     VARCHAR2
  );

  PROCEDURE set_wms_installed_flag(
	p_wms_installed_flag IN VARCHAR2);



-- This procedure validates child lots against either org
-- or item setup parameters.  Child lots must conform to
-- the setup defined for them.


PROCEDURE validate_child_lot
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_parent_lot_number    IN  VARCHAR2
, p_child_lot_number     IN  VARCHAR2
, x_return_status        OUT NOCOPY      VARCHAR2
, x_msg_count            OUT NOCOPY      NUMBER
, x_msg_data             OUT NOCOPY      VARCHAR2
);

-- This function validates, from the IN parameters,
-- whether a lot transaction can be added into the inventory
-- regarding the lot definition.
FUNCTION validate_lot_indivisible
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_transaction_type_id  IN  NUMBER
, p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_revision             IN  VARCHAR2
, p_subinventory_code    IN  VARCHAR2
, p_locator_id           IN  NUMBER
, p_lot_number           IN  VARCHAR2
, p_primary_quantity     IN  NUMBER
, p_qoh                  IN  NUMBER DEFAULT NULL
, p_atr                  IN  NUMBER DEFAULT NULL
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

--Overloaded function which returns
--the Quantity as well
FUNCTION validate_lot_indivisible
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_transaction_type_id  IN  NUMBER
, p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_revision             IN  VARCHAR2
, p_subinventory_code    IN  VARCHAR2
, p_locator_id           IN  NUMBER
, p_lot_number           IN  VARCHAR2
, p_lpn_id               IN  NUMBER DEFAULT NULL /*Bug#10113239 */
, p_primary_quantity     IN  NUMBER
, p_secondary_quantity   IN  NUMBER DEFAULT NULL /*Bug#11729772*/
, p_qoh                  IN  NUMBER DEFAULT NULL
, p_atr                  IN  NUMBER DEFAULT NULL
, x_primary_quantity     OUT NOCOPY NUMBER
, x_secondary_quantity   OUT NOCOPY NUMBER /*Bug#11729772*/
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


/* INVCONV, NSRIVAST, Start*/
-- This is the overloaded procedure for the exisiting Create_Inv_Lot procedure.
-- It inserts a record in mtl_lot_numbers table. Apart from this, it creates a
-- UOM Conversion record based on the value of copy_lot_uom_conversion.

  PROCEDURE Create_Inv_lot(
    x_return_status         OUT    NOCOPY VARCHAR2
  , x_msg_count             OUT    NOCOPY NUMBER
  , x_msg_data              OUT    NOCOPY VARCHAR2
  , x_row_id                OUT    NOCOPY ROWID
  , x_lot_rec       	    OUT    NOCOPY MTL_LOT_NUMBERS%ROWTYPE
  , p_lot_rec               IN     MTL_LOT_NUMBERS%ROWTYPE
  , p_source                IN     NUMBER
  , p_api_version           IN     NUMBER
  , p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
  , p_commit                IN     VARCHAR2 := fnd_api.g_false
  , p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
  , p_origin_txn_id         IN     NUMBER
  ) ;

/* INVCONV, NSRIVAST, End*/

/* INVCONV , HVERDDIN ADDED AUTO_GEN_LOT Wrapper for MSCA, Start */
-- Fix for Bug#12925054
-- Added new parameters p_transaction_source_id and p_transaction_source_line_id


  FUNCTION auto_gen_lot(
    p_org_id                     IN            NUMBER
  , p_inventory_item_id          IN            NUMBER
  , p_lot_generation             IN            NUMBER := NULL
  , p_lot_uniqueness             IN            NUMBER := NULL
  , p_lot_prefix                 IN            VARCHAR2 := NULL
  , p_zero_pad                   IN            NUMBER := NULL
  , p_lot_length                 IN            NUMBER := NULL
  , p_transaction_date           IN            DATE := NULL
  , p_revision                   IN            VARCHAR2 := NULL
  , p_subinventory_code          IN            VARCHAR2 := NULL
  , p_locator_id                 IN            NUMBER := NULL
  , p_transaction_type_id        IN            NUMBER := NULL
  , p_transaction_action_id      IN            NUMBER := NULL
  , p_transaction_source_type_id IN            NUMBER := NULL
  , p_lot_number                 IN            VARCHAR2 := NULL
  , p_api_version                IN            NUMBER
  , p_init_msg_list              IN            VARCHAR2 := fnd_api.g_false
  , p_commit                     IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level           IN            NUMBER := fnd_api.g_valid_level_full
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_count                  OUT NOCOPY    NUMBER
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  , p_transaction_source_id      IN            NUMBER DEFAULT  NULL /* 13368816 */
  , p_transaction_source_line_id IN            NUMBER DEFAULT  NULL /* 13368816 */
  )
    RETURN VARCHAR2;

/* INVCONV , HVERDDIN ADDED AUTO_GEN_LOT Wrapper for MSCA , End*/

/*INVCONV, Punit Kumar*/

   PROCEDURE CHECK_LOT_INDIVISIBILITY (  p_api_version          IN  NUMBER     DEFAULT 1.0
                                       ,p_init_msg_list        IN  VARCHAR2   DEFAULT FND_API.G_FALSE
                                       ,p_commit               IN  VARCHAR2   DEFAULT FND_API.G_FALSE
                                       ,p_validation_level     IN  NUMBER     DEFAULT FND_API.G_VALID_LEVEL_FULL
                                       ,p_rti_id               IN  NUMBER
                                       ,p_transaction_type_id  IN  NUMBER
                                       ,p_lot_number           IN  VARCHAR2
                                       ,p_lot_quantity         IN  NUMBER
                                       ,p_revision             IN  VARCHAR2
                                       ,p_qoh                  IN  NUMBER     DEFAULT NULL
                                       ,p_atr                  IN  NUMBER     DEFAULT NULL
                                       ,x_return_status        OUT NOCOPY     VARCHAR2
                                       ,x_msg_count            OUT NOCOPY     NUMBER
                                       ,x_msg_data             OUT NOCOPY     VARCHAR2
                                      ) ;
/*end, INVCONV, Punit Kumar*/

-----------------------------------------------------------------------
-- Name : validate_quantities
-- Desc : This procedure is used to validate transaction quantity2
--
-- I/P Params :
--     All the relevant transaction details :
--        - organization id
--        - item_id
--        - lot, revision, subinventory
--        - transaction quantities
-- O/P Params :
--     x_rerturn_status.
-- RETURN VALUE :
--   TRUE : IF the transaction is valid regarding Quantity2 and lot indivisible
--   FALSE : IF the transaction is NOT valid regarding Quantity2 and lot indivisible
--
-----------------------------------------------------------------------
FUNCTION validate_quantities(
  p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
, p_transaction_type_id  IN  NUMBER
, p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_revision             IN  VARCHAR2
, p_subinventory_code    IN  VARCHAR2
, p_locator_id           IN  NUMBER
, p_lot_number           IN  VARCHAR2
, p_transaction_quantity IN OUT  NOCOPY NUMBER
, p_transaction_uom_code IN  VARCHAR2
, p_primary_quantity     IN OUT NOCOPY NUMBER
, p_primary_uom_code	 OUT NOCOPY VARCHAR2
, p_secondary_quantity   IN OUT NOCOPY NUMBER
, p_secondary_uom_code   IN OUT NOCOPY VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

--This procedure checks whether lot specific conversion exist in source org or not
--If lot specific conversion exist then it will create the lot specific conversion
-- in desitnation org
--BUG#10202198

PROCEDURE lot_UOM_conv_OrgTxf (
  p_organization_id      IN  NUMBER
, p_inventory_item_id    IN  NUMBER
, p_xfr_organization_id    IN  NUMBER
, p_lot_number           IN  VARCHAR2
, p_transaction_temp_id  IN   NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2);

--this procedure inserts data in MTL_LOT_UOM_CLASS_CONVERSIONS table
--Bug#10202198
PROCEDURE create_lot_UOM_conv_orgtxf (
                 p_organization_id      IN  NUMBER
               , p_inventory_item_id    IN  NUMBER
               , p_xfr_organization_id    IN  NUMBER
               , p_lot_number           IN  VARCHAR2
               , x_return_status        OUT NOCOPY VARCHAR2
               , x_msg_count            OUT NOCOPY NUMBER
               , x_msg_data             OUT NOCOPY VARCHAR2);

END inv_lot_api_pub;

/
