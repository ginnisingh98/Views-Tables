--------------------------------------------------------
--  DDL for Package INV_LOT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_APIS" AUTHID CURRENT_USER AS
  /* $Header: INVLOTAS.pls 120.3.12010000.2 2009/04/10 07:32:12 pbonthu ship $ */

  /**
   * global variable for lots attributes
   */



TYPE t_genref is REF CURSOR;

PROCEDURE EXPIRATION_ACTION_CODE( x_codes OUT NOCOPY t_genref,
                                  p_code  IN VARCHAR2 );

PROCEDURE get_grade_codes (   x_grades     OUT NOCOPY t_genref
			    , p_grade_code IN  VARCHAR2);
PROCEDURE get_grade_codes(
    x_grade_codes           OUT    NOCOPY t_genref
     );

PROCEDURE GET_YES_NO( x_option OUT NOCOPY t_genref);

PROCEDURE GET_YES_NO( x_option OUT NOCOPY t_genref
                         , p_option IN VARCHAR2);

PROCEDURE get_named_attributes (   x_lot_att 		   OUT  NOCOPY t_genref
				   , p_inventory_item_id   IN   NUMBER
    				   , p_organization_id     IN   NUMBER
				   , p_lot_number          IN   VARCHAR2
				   , p_parent_lot_number   IN   VARCHAR2); -- get_opm_lot_attributes


PROCEDURE get_opm_item_attributes (   x_item_lot_att       OUT  NOCOPY t_genref
				    , p_inventory_item_id  IN   NUMBER
				    , p_organization_id    IN   NUMBER);  -- get_opm_item_attributes


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

  g_debug                        NUMBER                                   := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  osfm_form_no_validate             CONSTANT NUMBER                       := 1;
  osfm_open_interface   	    CONSTANT NUMBER                             := 2;
  osfm_form_validate                CONSTANT NUMBER                       := 3;
  inv				    CONSTANT NUMBER					  := 4;



/****** For Checking existence of Reservation against a lot ***/
PROCEDURE check_reservations(p_inventory_item_id    IN       NUMBER
                            , p_organization_id   IN       NUMBER
                            , p_lot_number        IN       VARCHAR2
                            , p_exists            OUT  NOCOPY VARCHAR2    ) ;

 PROCEDURE  GET_COPY_LOT_ATTR_FLAG(        x_return_status           OUT   NOCOPY VARCHAR2
                   , x_msg_count               OUT   NOCOPY NUMBER
                   , x_msg_data                OUT   NOCOPY VARCHAR2
                   , x_copy_lot_attr_flag      OUT   NOCOPY VARCHAR2
                   , p_organization_id         IN    NUMBER
                   , p_inventory_item_id       IN    NUMBER
                               );





/****** Wrappers for validating Lot Attributes *****/

PROCEDURE validate_grade_code( 	p_grade_code  				        IN		VARCHAR
                             	  , p_org_id                    IN      NUMBER
  								              , p_inventory_item_id         IN      NUMBER
  								              , p_grade_control_flag        IN      VARCHAR2
                                , x_return_status 		        OUT NOCOPY VARCHAR2
                                , x_msg_count 				        OUT NOCOPY NUMBER
                                , x_msg_data 				          OUT NOCOPY VARCHAR2
                                , x_valid                     OUT NOCOPY VARCHAR2);


PROCEDURE validate_exp_action_code( 	p_expiration_action_code  				IN		VARCHAR
                            	    , p_org_id                    IN      NUMBER
  								                , p_inventory_item_id         IN      NUMBER
  								                , p_shelf_life_code           IN      VARCHAR2
                                  , x_return_status 			OUT NOCOPY VARCHAR2
                                  , x_msg_count   				OUT NOCOPY NUMBER
                                  , x_msg_data  					OUT NOCOPY VARCHAR2
                                  , x_valid               OUT NOCOPY VARCHAR2);

PROCEDURE validate_exp_action_date(
  p_expiration_action_date		IN		DATE
, p_expiration_date             IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				      OUT NOCOPY NUMBER
, x_msg_data 				        OUT NOCOPY VARCHAR2
, x_valid                   OUT NOCOPY VARCHAR2);


PROCEDURE validate_hold_date(
  p_hold_date				IN		DATE
, p_origination_date            IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2
, x_valid                                   OUT NOCOPY VARCHAR2);


PROCEDURE validate_retest_date(
  p_retest_date 				IN		DATE
, p_origination_date            IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2
, x_valid                                   OUT NOCOPY VARCHAR2);


PROCEDURE validate_maturity_date(
  p_maturity_date				IN		DATE
, p_origination_date            IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2
, x_valid                                   OUT NOCOPY VARCHAR2);

PROCEDURE get_parent_lot_attributes
(  x_lot_att             OUT nocopy t_genref
 , p_inventory_item_id   IN   NUMBER
 , p_organization_id     IN   NUMBER
 , p_lot_number          IN   VARCHAR2) ;

 PROCEDURE Set_Msi_Default_Attr(
    x_lot_att           OUT    NOCOPY t_genref
   , p_organization_id   IN     NUMBER
   , p_inventory_item_id IN     NUMBER
   , p_lot_number	       IN     VARCHAR2 DEFAULT NULL -- nsinghi bug#5209065 rework. Added this param.
   ) ;

--Added p_subinventory_code , p_locator_id in below procedure for Onhand status support
PROCEDURE get_parent_lov(x_lot_num_lov OUT NOCOPY t_genref, p_wms_installed IN VARCHAR2, p_organization_id IN NUMBER, p_txn_type_id IN NUMBER, p_inventory_item_id IN VARCHAR2 , p_lot_number IN VARCHAR2,
                         p_project_id IN NUMBER, p_task_id IN NUMBER , p_subinventory_code IN VARCHAR2 DEFAULT NULL ,p_locator_id IN NUMBER DEFAULT NULL);

-- Procedure to validate the Parent-Child Lot naming convention
-- as defined in the org/item level parameters

PROCEDURE validate_child_lot (
  p_org_id                      IN  NUMBER
, p_inventory_item_id           IN  NUMBER
, p_parent_lot_number           IN  VARCHAR2
, p_lot_number                  IN  VARCHAR2
, x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
) ;

PROCEDURE Save_Conversions (         p_org_id   IN  NUMBER,
                                     p_frm_uom  IN  VARCHAR2,
                                     p_to_uom   IN  VARCHAR2,
                                     p_saveConv OUT NOCOPY VARCHAR2) ;

 PROCEDURE Save_Lot_UOM_Conv(
  p_inventory_item_id          MTL_LOT_NUMBERS.inventory_item_id%TYPE,
 p_org_id                     NUMBER,
 P_TRANSACTION_QUANTITY           IN NUMBER,
 p_primary_quantity               IN NUMBER   ,
 P_TRANSACTION_UOM                IN VARCHAR2 ,
 p_primary_uom                    IN VARCHAR2 ,
 p_lot_number                 MTL_LOT_NUMBERS.lot_number%TYPE,
 p_expiration_date            MTL_LOT_NUMBERS.expiration_date%TYPE,
 x_return_status              OUT NOCOPY VARCHAR2,
 x_msg_data                   OUT NOCOPY VARCHAR2,
 x_msg_count                  OUT NOCOPY NUMBER,
 P_SUPPLIER_LOT_NUMBER        MTL_LOT_NUMBERS.SUPPLIER_LOT_NUMBER%TYPE,
 p_grade_code                 MTL_LOT_NUMBERS.grade_code%TYPE,
 p_ORIGINATION_DATE           MTL_LOT_NUMBERS.ORIGINATION_DATE%TYPE,
 P_STATUS_ID                  MTL_LOT_NUMBERS.STATUS_ID%TYPE,
 p_RETEST_DATE                MTL_LOT_NUMBERS.RETEST_DATE%TYPE,
 P_MATURITY_DATE              MTL_LOT_NUMBERS.MATURITY_DATE%TYPE,
 P_LOT_ATTRIBUTE_CATEGORY     MTL_LOT_NUMBERS.LOT_ATTRIBUTE_CATEGORY%TYPE,
 P_C_ATTRIBUTE1                 MTL_LOT_NUMBERS.C_ATTRIBUTE1%TYPE,
 P_C_ATTRIBUTE2                 MTL_LOT_NUMBERS.C_ATTRIBUTE2%TYPE,
 P_C_ATTRIBUTE3                 MTL_LOT_NUMBERS.C_ATTRIBUTE3%TYPE,
 P_C_ATTRIBUTE4                 MTL_LOT_NUMBERS.C_ATTRIBUTE4%TYPE,
 P_C_ATTRIBUTE5                 MTL_LOT_NUMBERS.C_ATTRIBUTE5%TYPE,
 P_C_ATTRIBUTE6                 MTL_LOT_NUMBERS.C_ATTRIBUTE6%TYPE,
 P_C_ATTRIBUTE7                 MTL_LOT_NUMBERS.C_ATTRIBUTE7%TYPE,
 P_C_ATTRIBUTE8                 MTL_LOT_NUMBERS.C_ATTRIBUTE8%TYPE,
 P_C_ATTRIBUTE9                 MTL_LOT_NUMBERS.C_ATTRIBUTE9%TYPE,
 P_C_ATTRIBUTE10                 MTL_LOT_NUMBERS.C_ATTRIBUTE10%TYPE,
 P_C_ATTRIBUTE11                 MTL_LOT_NUMBERS.C_ATTRIBUTE11%TYPE,
 P_C_ATTRIBUTE12                 MTL_LOT_NUMBERS.C_ATTRIBUTE12%TYPE,
 P_C_ATTRIBUTE13                 MTL_LOT_NUMBERS.C_ATTRIBUTE13%TYPE,
 P_C_ATTRIBUTE14                 MTL_LOT_NUMBERS.C_ATTRIBUTE14%TYPE,
 P_C_ATTRIBUTE15                 MTL_LOT_NUMBERS.C_ATTRIBUTE15%TYPE,
 P_C_ATTRIBUTE16                 MTL_LOT_NUMBERS.C_ATTRIBUTE16%TYPE,
 P_C_ATTRIBUTE17                 MTL_LOT_NUMBERS.C_ATTRIBUTE17%TYPE,
 P_C_ATTRIBUTE18                 MTL_LOT_NUMBERS.C_ATTRIBUTE18%TYPE,
 P_C_ATTRIBUTE19                 MTL_LOT_NUMBERS.C_ATTRIBUTE19%TYPE,
 P_C_ATTRIBUTE20                 MTL_LOT_NUMBERS.C_ATTRIBUTE20%TYPE,
 P_D_ATTRIBUTE1                 MTL_LOT_NUMBERS.D_ATTRIBUTE1%TYPE,
 P_D_ATTRIBUTE2                 MTL_LOT_NUMBERS.D_ATTRIBUTE2%TYPE,
 P_D_ATTRIBUTE3                 MTL_LOT_NUMBERS.D_ATTRIBUTE3%TYPE,
 P_D_ATTRIBUTE4                 MTL_LOT_NUMBERS.D_ATTRIBUTE4%TYPE,
 P_D_ATTRIBUTE5                 MTL_LOT_NUMBERS.D_ATTRIBUTE5%TYPE,
 P_D_ATTRIBUTE6                 MTL_LOT_NUMBERS.D_ATTRIBUTE6%TYPE,
 P_D_ATTRIBUTE7                 MTL_LOT_NUMBERS.D_ATTRIBUTE7%TYPE,
 P_D_ATTRIBUTE8                 MTL_LOT_NUMBERS.D_ATTRIBUTE8%TYPE,
 P_D_ATTRIBUTE9                 MTL_LOT_NUMBERS.D_ATTRIBUTE9%TYPE,
 P_D_ATTRIBUTE10                 MTL_LOT_NUMBERS.D_ATTRIBUTE10%TYPE,
 P_N_ATTRIBUTE1                 MTL_LOT_NUMBERS.N_ATTRIBUTE1%TYPE,
 P_N_ATTRIBUTE2                 MTL_LOT_NUMBERS.N_ATTRIBUTE2%TYPE,
 P_N_ATTRIBUTE3                 MTL_LOT_NUMBERS.N_ATTRIBUTE3%TYPE,
 P_N_ATTRIBUTE4                 MTL_LOT_NUMBERS.N_ATTRIBUTE4%TYPE,
 P_N_ATTRIBUTE5                 MTL_LOT_NUMBERS.N_ATTRIBUTE5%TYPE,
 P_N_ATTRIBUTE6                 MTL_LOT_NUMBERS.N_ATTRIBUTE6%TYPE,
 P_N_ATTRIBUTE7                 MTL_LOT_NUMBERS.N_ATTRIBUTE7%TYPE,
 P_N_ATTRIBUTE8                 MTL_LOT_NUMBERS.N_ATTRIBUTE8%TYPE,
 P_N_ATTRIBUTE9                 MTL_LOT_NUMBERS.N_ATTRIBUTE9%TYPE,
 P_N_ATTRIBUTE10                MTL_LOT_NUMBERS.N_ATTRIBUTE10%TYPE,
 P_SECONDARY_QUANTITY             IN NUMBER,
 P_SECONDARY_UOM_CODE             IN VARCHAR2 ,
 p_parent_lot_number          MTL_LOT_NUMBERS.parent_lot_number%TYPE,
 P_ORIGINATION_TYPE           MTL_LOT_NUMBERS.ORIGINATION_TYPE%TYPE,
 P_EXPIRATION_ACTION_DATE     MTL_LOT_NUMBERS.EXPIRATION_ACTION_DATE%TYPE,
 P_EXPIRATION_ACTION_CODE     MTL_LOT_NUMBERS.EXPIRATION_ACTION_CODE%TYPE,
 P_HOLD_DATE                  MTL_LOT_NUMBERS.HOLD_DATE%TYPE,
 P_REASON_ID                      IN VARCHAR2 ,
 p_response                       IN VARCHAR2 ,
 P_ATTRIBUTE_CATEGORY         MTL_LOT_NUMBERS.ATTRIBUTE_CATEGORY%TYPE,
 P_ATTRIBUTE1                 MTL_LOT_NUMBERS.ATTRIBUTE1%TYPE,
 P_ATTRIBUTE2                 MTL_LOT_NUMBERS.ATTRIBUTE2%TYPE,
 P_ATTRIBUTE3                 MTL_LOT_NUMBERS.ATTRIBUTE3%TYPE,
 P_ATTRIBUTE4                 MTL_LOT_NUMBERS.ATTRIBUTE4%TYPE,
 P_ATTRIBUTE5                 MTL_LOT_NUMBERS.ATTRIBUTE5%TYPE,
 P_ATTRIBUTE6                 MTL_LOT_NUMBERS.ATTRIBUTE6%TYPE,
 P_ATTRIBUTE7                 MTL_LOT_NUMBERS.ATTRIBUTE7%TYPE,
 P_ATTRIBUTE8                 MTL_LOT_NUMBERS.ATTRIBUTE8%TYPE,
 P_ATTRIBUTE9                 MTL_LOT_NUMBERS.ATTRIBUTE9%TYPE,
 P_ATTRIBUTE10                 MTL_LOT_NUMBERS.ATTRIBUTE10%TYPE,
 P_ATTRIBUTE11                 MTL_LOT_NUMBERS.ATTRIBUTE11%TYPE,
 P_ATTRIBUTE12                 MTL_LOT_NUMBERS.ATTRIBUTE12%TYPE,
 P_ATTRIBUTE13                 MTL_LOT_NUMBERS.ATTRIBUTE13%TYPE,
 P_ATTRIBUTE14                 MTL_LOT_NUMBERS.ATTRIBUTE14%TYPE,
 P_ATTRIBUTE15                 MTL_LOT_NUMBERS.ATTRIBUTE15%TYPE,
 P_ITEM_DUAL_UOM_CONTROL          IN VARCHAR2 , -- hold item's Tracking indicator
 P_copy_pnt_lot_att_flag          IN VARCHAR2 ,
 p_secondary_default_ind          IN VARCHAR2 ,
 p_disable_flag                  IN  MTL_LOT_NUMBERS.DISABLE_FLAG%TYPE DEFAULT NULL,   -- 4239238 Start
 p_territory_code                IN  MTL_LOT_NUMBERS.TERRITORY_CODE%TYPE DEFAULT NULL,
 p_date_code                     IN  MTL_LOT_NUMBERS.DATE_CODE%TYPE DEFAULT NULL,
 p_change_date                   IN  MTL_LOT_NUMBERS.CHANGE_DATE%TYPE DEFAULT NULL,
 p_age                           IN  MTL_LOT_NUMBERS.AGE%TYPE DEFAULT NULL,
 p_item_size                     IN  MTL_LOT_NUMBERS.ITEM_SIZE%TYPE DEFAULT NULL,
 p_color                         IN  MTL_LOT_NUMBERS.COLOR%TYPE DEFAULT NULL,
 p_volume                        IN  MTL_LOT_NUMBERS.VOLUME%TYPE DEFAULT NULL,
 p_volume_uom                    IN  MTL_LOT_NUMBERS.VOLUME_UOM%TYPE DEFAULT NULL,
 p_place_of_origin               IN  MTL_LOT_NUMBERS.PLACE_OF_ORIGIN%TYPE DEFAULT NULL,
 p_best_by_date                  IN  MTL_LOT_NUMBERS.BEST_BY_DATE%TYPE DEFAULT NULL,
 p_length                        IN  MTL_LOT_NUMBERS.LENGTH%TYPE DEFAULT NULL,
 p_length_uom                    IN  MTL_LOT_NUMBERS.LENGTH_UOM%TYPE DEFAULT NULL,
 p_recycled_content              IN  MTL_LOT_NUMBERS.RECYCLED_CONTENT%TYPE DEFAULT NULL,
 p_thickness                     IN  MTL_LOT_NUMBERS.THICKNESS%TYPE DEFAULT NULL,
 p_thickness_uom                 IN  MTL_LOT_NUMBERS.THICKNESS_UOM%TYPE DEFAULT NULL,
 p_width                         IN  MTL_LOT_NUMBERS.WIDTH%TYPE DEFAULT NULL,
 p_width_uom                     IN  MTL_LOT_NUMBERS.WIDTH_UOM%TYPE DEFAULT NULL,
 p_curl_wrinkle_fold             IN  MTL_LOT_NUMBERS.CURL_WRINKLE_FOLD%TYPE DEFAULT NULL,
 p_vendor_name                   IN  MTL_LOT_NUMBERS.VENDOR_NAME%TYPE DEFAULT NULL, -- 4239238 End
 p_source_lot                    IN  VARCHAR2 DEFAULT NULL,  --Bug#5349912
 p_copy_other_conversions        IN  VARCHAR2 DEFAULT 'F'    --Bug#5349912
);

--Added for bug 7426180 start
PROCEDURE  GET_ORG_COPY_LOTATTR_FLAG(
                x_return_status           OUT   NOCOPY VARCHAR2
              , x_msg_count               OUT   NOCOPY NUMBER
              , x_msg_data                OUT   NOCOPY VARCHAR2
              , x_copy_lot_attr_flag      OUT   NOCOPY VARCHAR2
              , p_organization_id         IN    NUMBER
              , p_inventory_item_id       IN    NUMBER
);

--Added for bug 7426180 end



END inv_lot_apis;

/
