--------------------------------------------------------
--  DDL for Package INV_LOT_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_API_PKG" 
  /* $Header: INVVLTPS.pls 120.0 2005/05/25 05:25:00 appldev noship $ */
 AUTHID CURRENT_USER AS

  g_ret_sts_success         CONSTANT VARCHAR2(1)       := 'S';
  g_ret_sts_error           CONSTANT VARCHAR2(1)       := 'E';
  g_ret_sts_unexp_error     CONSTANT VARCHAR2(1)       := 'U';
  g_miss_num                CONSTANT NUMBER            := 9.99e125;
  g_miss_char               CONSTANT VARCHAR2(1)       := CHR(0);
  g_miss_date               CONSTANT DATE              := TO_DATE('1', 'j');
  osfm_form_no_validate     CONSTANT NUMBER            := 1;
  osfm_open_interface       CONSTANT NUMBER            := 2;
  osfm_form_validate        CONSTANT NUMBER            := 3;
  inv			    CONSTANT NUMBER            := 4;
  G_WMS_INSTALLED           VARCHAR2(10);

  /*Exception definitions */
  g_exc_error               EXCEPTION;
  g_exc_unexpected_error    EXCEPTION;

 /*Local variable for stoRing the INV:DEBUG TRACE profile value */
  g_debug                   NUMBER            := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);



-- This procedure populates the parent and child lot records and
-- returns them to the Create_Inv_Lot procedure.
PROCEDURE Populate_Lot_Records (
   x_return_status              OUT   NOCOPY VARCHAR2
 , x_msg_count                  OUT   NOCOPY NUMBER
 , x_msg_data                   OUT   NOCOPY VARCHAR2
 , x_child_lot_rec              OUT   NOCOPY MTL_LOT_NUMBERS%ROWTYPE
 , p_lot_rec                    IN    MTL_LOT_NUMBERS%ROWTYPE
 , p_copy_lot_attribute_flag    IN    VARCHAR2
 , p_source                     IN    NUMBER
 , p_api_version                IN    NUMBER
 , p_init_msg_list              IN    VARCHAR2
 , p_commit                     IN    VARCHAR2
);

-- This procedure populates the  grade code, origination type, expiration date,
-- retest date, expiration action code, expiration action date,hold date and
-- maturity date based on the values from mtl_system_items for a given
-- organization and inventory item id.
 PROCEDURE Set_Msi_Default_Attr (
                    p_lot_rec           IN OUT NOCOPY mtl_lot_numbers%ROWTYPE
                  , x_return_status     OUT    NOCOPY VARCHAR2
                  , x_msg_count         OUT    NOCOPY NUMBER
                  , x_msg_data          OUT    NOCOPY VARCHAR2
  )  ;

-- This procedure performs the validations on the lot and defaults the missing attributes
-- as per the logic existing in the earlier create_inv_lot procedure.It returns the populate
-- lot record.
PROCEDURE Validate_Lot_Attributes(
  x_return_status           OUT    NOCOPY VARCHAR2
, x_msg_count               OUT    NOCOPY NUMBER
, x_msg_data                OUT    NOCOPY VARCHAR2
, x_lot_rec                 IN OUT NOCOPY Mtl_Lot_Numbers%ROWTYPE
, p_source                  IN     NUMBER
) ;

-- This procedure validates the OMP related attributes like validations for parent lot , origination
-- type, grade code, expiration action date/code, retest date, maturity date , hold date.
PROCEDURE Validate_Additional_Attr(
  x_return_status          OUT    NOCOPY VARCHAR2
, x_msg_count              OUT    NOCOPY NUMBER
, x_msg_data               OUT    NOCOPY VARCHAR2
, p_inventory_item_id      IN     NUMBER
, p_organization_id        IN     NUMBER
, p_lot_number             IN     VARCHAR2
, p_source                 IN     NUMBER
, p_grade_code             IN     VARCHAR2
, p_retest_date            IN     DATE
, p_maturity_date          IN     DATE
, p_parent_lot_number      IN     VARCHAR2
, p_origination_date       IN     DATE
, p_origination_type       IN     NUMBER
, p_expiration_action_code IN     VARCHAR2
, p_expiration_action_date IN     DATE
, p_expiration_date        IN     DATE
, p_hold_date	             IN     DATE
)  ;


 PROCEDURE Delete_Lot(
     x_return_status          OUT    NOCOPY VARCHAR2
   , x_msg_count              OUT    NOCOPY NUMBER
   , x_msg_data               OUT    NOCOPY VARCHAR2
   , p_inventory_item_id      IN     NUMBER
   , p_organization_id        IN     NUMBER
   , p_lot_number             IN     VARCHAR2
    ) ;

/** INVCONV ANTHIYAG 04-Nov-2004 Start **/
-- This Function would be used to check whether the lot number passed
-- exists in the database or not. As this uses Pragma Autonomous_transaction
-- it would check for the lots existing prior to the uncommitted transactions

    FUNCTION Check_Existing_Lot_Db
    (
     p_org_id              IN   NUMBER
    ,p_inventory_item_id   IN   NUMBER
    ,p_lot_number          IN   VARCHAR2
    ) RETURN BOOLEAN;

/** INVCONV ANTHIYAG 04-Nov-2004 End **/

 END INV_LOT_API_PKG ;

 

/
