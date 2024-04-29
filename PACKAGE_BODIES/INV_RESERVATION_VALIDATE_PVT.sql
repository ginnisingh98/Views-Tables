--------------------------------------------------------
--  DDL for Package Body INV_RESERVATION_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RESERVATION_VALIDATE_PVT" AS
/* $Header: INVRSV1B.pls 120.27.12010000.2 2010/01/22 18:20:52 mporecha ship $ */
g_pkg_name CONSTANT VARCHAR2(30) := 'INV_RESERVATION_VALIDATE_PVT';


/*** {{ R12 Enhanced reservations code changes ***/
g_debug NUMBER;

-- procedure to print a message to dbms_output
-- disable by default since dbm_s_output.put_line is not allowed
PROCEDURE debug_print(p_message IN VARCHAR2, p_level IN NUMBER := 9) IS
BEGIN
  inv_log_util.TRACE(p_message, 'INV_RESERVATION_VALIDATE_PVT', p_level);
END debug_print;
/*** End R12 }} ***/

--
-- Procedure
--   validate_organization
-- Description
--   is valid if all of the following are satisfied
--     1. p_organization_id is null
--     2. p_organization_id is in mtl_parameters
PROCEDURE validate_organization
  (
     x_return_status      OUT NOCOPY VARCHAR2
   , p_organization_id    IN  NUMBER
   , x_org_cache_index    out NOCOPY INTEGER
   ) IS
      l_return_status     VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_index             NUMBER := NULL;
      l_rec               inv_reservation_global.organization_record;

BEGIN
   --
   IF p_organization_id IS NULL THEN
      fnd_message.set_name('INV', 'INV_NO ORG INFORMATION');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;
   --
   inv_reservation_util_pvt.search_organization_cache
     (
        x_return_status     => l_return_status
      , p_organization_id   => p_organization_id
      , x_index             => l_index
     );
   --
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;
   --
   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;
   --
   IF l_index IS NULL THEN
   /*   BEGIN
	 SELECT
	   organization_id
	   , negative_inv_receipt_code
	   , project_reference_enabled
	   , stock_locator_control_code
	   INTO l_rec
	   FROM mtl_parameters
	   WHERE organization_id = p_organization_id;

      EXCEPTION
	 WHEN no_data_found THEN
	 fnd_message.set_name('INV', 'INVALID ORGANIZATION');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;
	 END;
	 */
	 -- Modified to call common API
        l_rec.organization_id:=p_organization_id;
    	IF INV_Validate.Organization(
		p_org => l_rec
					)=INV_Validate.F THEN
    	 fnd_message.set_name('INV', 'INVALID ORGANIZATION');
    	 fnd_msg_pub.add;
    	 RAISE fnd_api.g_exc_error;
    	END IF;

      --
      inv_reservation_util_pvt.add_organization_cache
	(
  	   x_return_status              => l_return_status
	 , p_organization_record        => l_rec
	 , x_index                      => l_index
	 );
      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	   RAISE fnd_api.g_exc_error;
      End IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      End IF;
      --
   END IF;
   --
   x_org_cache_index := l_index;
   x_return_status := l_return_status;
   --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Validate_Organization'
              );
        END IF;
        --
END validate_organization;
--
-- Procedure
--   validate_item
-- Description
--   is valid if all of the following are satisfied
--     1. p_inventory_item_id is not null
--     2. p_inventory_item_id is in mtl_system_items table
PROCEDURE validate_item
  (
     x_return_status      OUT NOCOPY VARCHAR2
   , p_inventory_item_id  IN  NUMBER
   , p_organization_id    IN  NUMBER
   , x_item_cache_index   OUT NOCOPY INTEGER
   ) IS
      l_return_status     VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_rec               inv_reservation_global.item_record;
      l_index             NUMBER := NULL;
       -- Added to call common API
      l_rec_org               inv_reservation_global.organization_record;

BEGIN
	 l_rec_org.organization_id:=p_organization_id;
   --
   IF p_inventory_item_id IS NULL THEN
      fnd_message.set_name('INV', 'INV_ENTER_ITEM');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;
   --
   inv_reservation_util_pvt.search_item_cache
     (
        x_return_status      => l_return_status
      , p_inventory_item_id  => p_inventory_item_id
      , p_organization_id    => p_organization_id
      , x_index              => l_index
      );
   --
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   End IF ;
   --
   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   End IF;
   --
   IF l_index IS NULL THEN
   /*   BEGIN  -- not in cache, load it
	 SELECT
	   inventory_item_id
	   , organization_id
	   , lot_control_code
	   , serial_number_control_code
	   , reservable_type
	   , restrict_subinventories_code
	   , restrict_locators_code
	   , revision_qty_control_code
	   , location_control_code
	   , primary_uom_code
	   INTO l_rec
	   FROM
	   mtl_system_items
	   WHERE
	   inventory_item_id   = p_inventory_item_id
	   AND organization_id = p_organization_id ;
      EXCEPTION
	 WHEN no_data_found THEN
	    fnd_message.set_name('INV', 'INVALID ORGANIZATION');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_error;
      END;*/
      -- Modified to call new common API
        l_rec.inventory_item_id:=p_inventory_item_id;
    	IF INV_Validate.Inventory_Item(
		p_item => l_rec,
                p_org => l_rec_org
					)=INV_Validate.F THEN
    	 fnd_message.set_name('INV', 'INVALID ITEM');
    	 fnd_msg_pub.add;
    	 RAISE fnd_api.g_exc_error;
    	END IF;

      --
      IF l_rec.reservable_type = 2 THEN  /* non reservable item */
	 fnd_message.set_name('INV','INV-ITEM NOT RESERVABLE');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;
      END IF;
      --
      inv_reservation_util_pvt.add_item_cache
	(
  	   x_return_status              => l_return_status
	 , p_item_record                => l_rec
	 , x_index                      => l_index
	 );
      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	   RAISE fnd_api.g_exc_error;
      End IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
   --
   x_item_cache_index := l_index;
   x_return_status := l_return_status;
   --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Validate_Item'
              );
        END IF;
        --
END validate_item;

--Procedure
--  validate_supply_source_po
-- Description
--    Validation for supply source of Purchase Order.
-- Currently, only validate for existence of a distribution line id
-- with the specified header id.  In future, we may also want to
-- to validate quantity.
-- Added for bug 1947824
PROCEDURE validate_supply_source_po
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER  /*** {{ R12 Enhanced reservations code changes }}***/
  , p_inventory_item_id         IN NUMBER  /*** {{ R12 Enhanced reservations code changes }}***/
  , p_demand_ship_date          IN DATE    /*** {{ R12 Enhanced reservations code changes }}***/
  , p_supply_receipt_date       IN DATE    /*** {{ R12 Enhanced reservations code changes }}***/
  , p_supply_source_type_id     IN NUMBER  /*** {{ R12 Enhanced reservations code changes }}***/
  , p_supply_source_header_id   IN NUMBER
  , p_supply_source_line_id     IN NUMBER
  , p_supply_source_line_detail IN NUMBER  /*** {{ R12 Enhanced reservations code changes }}***/
) IS

l_valid_supply    VARCHAR2(1);
/*** {{ R12 Enhanced reservations code changes }}***/
l_dropship_count  NUMBER := 0;
l_debug           NUMBER;
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
/*** End R12 }} ***/
/*** {{ R12 Enhanced reservations code changes
 comment out the cursor, since we already validate the
 document in the reservation private API before come to
 this validation.
CURSOR c_po_supply IS
   SELECT 'Y'
     FROM po_distributions_all
    WHERE po_distribution_id = p_supply_source_line_id
      AND po_header_id = p_supply_source_header_id;
 *** End R12 }} ***/
BEGIN

/*** {{ R12 Enhanced reservations code changes
 comment out the cursor, since we already validate the
 document in the reservation private API before come to
 this validation.
  OPEN c_po_supply;
  FETCH c_po_supply INTO l_valid_supply;
  IF c_po_supply%NOTFOUND OR
     l_valid_supply IS NULL OR
     l_valid_supply <> 'Y' THEN

       --error message
       fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY_PO');
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_error;
  END IF;
 *** End R12 }} ***/

  /*** {{ R12 Enhanced reservations code changes ***/
  IF (g_debug IS NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  END IF;

  l_debug := g_debug;

  IF (l_debug = 1) THEN
      debug_print('In validate_supply_source_po: supply_source_type_id = ' || p_supply_source_type_id);
  END IF;

  IF (p_supply_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_PO) THEN

     RCV_AVAILABILITY.validate_supply_demand
       (
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , x_valid_status               => l_valid_status
        , p_organization_id            => p_organization_id
        , p_item_id                    => p_inventory_item_id
        , p_supply_demand_code         => 1
        , p_supply_demand_type_id      => p_supply_source_type_id
        , p_supply_demand_header_id    => p_supply_source_header_id
        , p_supply_demand_line_id      => p_supply_source_line_id
        , p_supply_demand_line_detail  => p_supply_source_line_detail
        , p_demand_ship_date           => p_demand_ship_date
        , p_expected_receipt_date      => p_supply_receipt_date
        , p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
      );

     IF (l_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
     ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF (l_debug = 1) THEN
         debug_print('validate supply demand returns valid status: ' || l_valid_status);
     END IF;

     IF (l_valid_status = 'N') THEN
         fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY_PO');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
     END IF;

     select count(1)
     into   l_dropship_count
     from   oe_drop_ship_sources
     where  po_header_id = p_supply_source_header_id
     and    line_location_id = p_supply_source_line_id;

     IF (l_debug = 1) THEN
         debug_print('l_dropship_count = ' || l_dropship_count);
     END IF;

     IF (l_dropship_count >= 1) THEN
        fnd_message.set_name('INV', 'INV_RSV_DS_SO_SUP');
        fnd_message.set_name('SOURCE', 'PO');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;
  ELSE
       IF (l_debug = 1) THEN
           debug_print('The transation source type is not PO');
       END IF;
       RAISE fnd_api.g_exc_error;

  END IF;
  /*** End R12 }} ***/

  x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Validate_Supply_Source_PO'
              );
        END IF;
        --
END validate_supply_source_po;


--Procedure
--  validate_supply_source_req
-- Description
--    Validation for supply source of Requisition
-- Currently, only validate for existence of a requisition line id
-- with the specified header id.  In future, we may also want to
-- to validate quantity.
-- Added for bug 1947824
PROCEDURE validate_supply_source_req
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_supply_source_type_id     IN NUMBER  /*** {{ R12 Enhanced reservations code changes }}***/
  , p_supply_source_header_id   IN NUMBER
  , p_supply_source_line_id     IN NUMBER
  , p_supply_source_line_detail IN NUMBER  /*** {{ R12 Enhanced reservations code changes }}***/
) IS

l_valid_supply VARCHAR2(1);
/*** {{ R12 Enhanced reservations code changes }}***/
l_dropship_count NUMBER := 0;
l_debug          NUMBER;
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
/*** End R12 }} ***/

CURSOR c_req_supply IS
   SELECT 'Y'
     FROM po_requisition_lines_all
    WHERE requisition_line_id = p_supply_source_line_id
      AND requisition_header_id = p_supply_source_header_id;

BEGIN

  /*** {{ R12 Enhanced reservations code changes ***/
  IF (g_debug IS NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  END IF;

  l_debug := g_debug;

  IF (l_debug = 1) THEN
      debug_print('In validate_supply_source_req, supply_source_type_id = ' || p_supply_source_type_id);
  END IF;

  IF (p_supply_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_REQ) THEN

     -- validate document
     OPEN c_req_supply;
     FETCH c_req_supply INTO l_valid_supply;
     IF c_req_supply%NOTFOUND OR
        l_valid_supply IS NULL OR
        l_valid_supply <> 'Y' THEN

          --error message
          fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY_REQ');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
     END IF;

     select count(1)
     into   l_dropship_count
     from   oe_drop_ship_sources
     where  requisition_header_id = p_supply_source_header_id
     and    requisition_line_id = p_supply_source_line_id;

     IF (l_debug = 1) THEN
         debug_print('l_dropship_count = ' || l_dropship_count);
     END IF;

     IF (l_dropship_count >= 1) THEN
        fnd_message.set_name('INV', 'INV_RSV_DS_SO_SUP');
        fnd_message.set_token('SOURCE', 'requisition');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;
  ELSE
       IF (l_debug = 1) THEN
           debug_print('The transation source type is not requisition');
       END IF;
       RAISE fnd_api.g_exc_error;

  END IF;
  /*** End R12 }} ***/

  x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Validate_Supply_Source_REQ'
              );
        END IF;
        --
END validate_supply_source_req;

/*** {{ R12 Enhanced reservations code changes ***/
-- {{Procedure
--   validate_supply_source_intreq
-- Description
--   Validation for supply source of internal requisition
--   if the document is invalid, then return error. }}
PROCEDURE validate_supply_source_intreq
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_supply_source_type_id     IN NUMBER
  , p_supply_source_header_id   IN NUMBER
  , p_supply_source_line_id     IN NUMBER
  , p_supply_source_line_detail IN NUMBER
) IS
l_debug          NUMBER;
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);

BEGIN

  IF (g_debug IS NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  END IF;

  l_debug := g_debug;

  IF (l_debug = 1) THEN
      debug_print('In validate_supply_source_intreq, supply_source_type_id = ' || p_supply_source_type_id);
  END IF;

  IF (p_supply_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INTERNAL_REQ) THEN
     -- validate document
     RCV_AVAILABILITY.validate_supply_demand
       (
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , x_valid_status               => l_valid_status
        , p_organization_id            => p_organization_id
        , p_item_id                    => p_inventory_item_id
        , p_supply_demand_code         => 1
        , p_supply_demand_type_id      => p_supply_source_type_id
        , p_supply_demand_header_id    => p_supply_source_header_id
        , p_supply_demand_line_id      => p_supply_source_line_id
        , p_supply_demand_line_detail  => p_supply_source_line_detail
        , p_demand_ship_date           => p_demand_ship_date
        , p_expected_receipt_date      => p_supply_receipt_date
        , p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
      );

     IF (l_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
     ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF (l_debug = 1) THEN
         debug_print('validate supply demand returns valid status: ' || l_valid_status);
     END IF;

     IF (l_valid_status = 'N') THEN
         fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY_INTREQ');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
     END IF;
  ELSE
       IF (l_debug = 1) THEN
           debug_print('The transation source type is not internal requisition');
       END IF;
       RAISE fnd_api.g_exc_error;

  END IF;
  /*** End R12 }} ***/

  x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Supply_Source_INTREQ'
              );
        END IF;
        --
END validate_supply_source_intreq;

/*** {{ R12 Enhanced reservations code changes ***/
-- {{Procedure
--   validate_supply_source_asn
-- Description
--   Validation for supply source of ASN
--   if the organization is not WMS enabled org, then return error. }}
PROCEDURE validate_supply_source_asn
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_supply_source_type_id     IN NUMBER
  , p_supply_source_header_id   IN NUMBER
  , p_supply_source_line_id     IN NUMBER
  , p_supply_source_line_detail IN NUMBER
) IS

l_wms_enabled     VARCHAR2(1) := 'N';
l_debug           NUMBER;
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_supply_source_asn, supply_source_type_id = ' || p_supply_source_type_id);
   END IF;

   IF (p_supply_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_ASN) THEN

       -- validate the document
       RCV_AVAILABILITY.validate_supply_demand
       (
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , x_valid_status               => l_valid_status
        , p_organization_id            => p_organization_id
        , p_item_id                    => p_inventory_item_id
        , p_supply_demand_code         => 1
        , p_supply_demand_type_id      => p_supply_source_type_id
        , p_supply_demand_header_id    => p_supply_source_header_id
        , p_supply_demand_line_id      => p_supply_source_line_id
        , p_supply_demand_line_detail  => p_supply_source_line_detail
        , p_demand_ship_date           => p_demand_ship_date
        , p_expected_receipt_date      => p_supply_receipt_date
        , p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
      );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
      ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
          debug_print('validate supply demand returns valid status: ' || l_valid_status);
      END IF;

      IF (l_valid_status = 'N') THEN
          fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY_ASN');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END IF;

      SELECT wms_enabled_flag
      INTO   l_wms_enabled
      FROM   mtl_parameters
      WHERE  organization_id = p_organization_id;

      IF (l_debug = 1) THEN
          debug_print('l_wms_enabled = ' || l_wms_enabled);
      END IF;

      IF (l_wms_enabled = 'N') THEN
          fnd_message.set_name('INV', 'INV_RSV_NON_WMS');
          fnd_message.set_name('SOURCE', 'ASN');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      IF (l_debug = 1) THEN
          debug_print('The transation source type is not ASN');
      END IF;
      RAISE fnd_api.g_exc_error;

    END IF;
    x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Supply_Source_ASN'
              );
      END IF;

END validate_supply_source_asn;

-- {{Procedure
--   validate_supply_source_intransit
-- Description
--   Validation for supply source of Intransit shipment
--   if the organization is not WMS enabled org, then return error. }}
PROCEDURE validate_supply_source_intran
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_supply_source_type_id     IN NUMBER
  , p_supply_source_header_id   IN NUMBER
  , p_supply_source_line_id     IN NUMBER
  , p_supply_source_line_detail IN NUMBER
) IS

l_wms_enabled        VARCHAR2(1) := 'N';
l_replenish_to_order VARCHAR2(1) := 'N';
l_debug              NUMBER;
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_supply_source_intran, supply_source_type_id = ' || p_supply_source_type_id);
   END IF;

   IF (p_supply_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INTRANSIT) THEN

       -- validate document
       RCV_AVAILABILITY.validate_supply_demand
         (
            x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , x_valid_status               => l_valid_status
          , p_organization_id            => p_organization_id
          , p_item_id                    => p_inventory_item_id
          , p_supply_demand_code         => 1
          , p_supply_demand_type_id      => p_supply_source_type_id
          , p_supply_demand_header_id    => p_supply_source_header_id
          , p_supply_demand_line_id      => p_supply_source_line_id
          , p_supply_demand_line_detail  => p_supply_source_line_detail
          , p_demand_ship_date           => p_demand_ship_date
          , p_expected_receipt_date      => p_supply_receipt_date
          , p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
        );

       IF (l_return_status = fnd_api.g_ret_sts_error) THEN
           RAISE fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
           RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       IF (l_debug = 1) THEN
           debug_print('validate supply demand returns valid status: ' || l_valid_status);
       END IF;

       IF (l_valid_status = 'N') THEN
           fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY_INTRAN');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
       END IF;

       SELECT wms_enabled_flag
       INTO   l_wms_enabled
       FROM   mtl_parameters
       WHERE  organization_id = p_organization_id;

       IF (l_debug = 1) THEN
           debug_print('l_wms_enabled = ' || l_wms_enabled);
       END IF;

       IF (l_wms_enabled = 'N') THEN
           fnd_message.set_name('INV', 'INV_RSV_NON_WMS');
           fnd_message.set_name('SOURCE', 'intransit shipment');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
       END IF;

       SELECT replenish_to_order_flag
       INTO   l_replenish_to_order
       FROM   mtl_system_items
       WHERE  organization_id = p_organization_id
       AND    inventory_item_id = p_inventory_item_id;

       IF (l_debug = 1) THEN
           debug_print('l_replenish_to_order_flag = ' || l_replenish_to_order);
       END IF;

       IF (l_replenish_to_order = 'Y') THEN
           fnd_message.set_name('INV', 'INV_RSV_INT_REPLEN');
           fnd_message.set_token('SOURCE', 'intransit shipment');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
       END IF;
   ELSE
       IF (l_debug = 1) THEN
           debug_print('The transation source type is not intransit shipment');
       END IF;
       RAISE fnd_api.g_exc_error;

   END IF;
   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Supply_Source_Intran'
              );
      END IF;

END validate_supply_source_intran;

-- {{Procedure
--   validate_supply_source_rcv
-- Description
--   Validation for supply source of RCV
--   if the organization is not WMS enabled org, then return error. }}
PROCEDURE validate_supply_source_rcv
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_item_id                   IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_supply_source_type_id     IN NUMBER
  , p_supply_source_header_id   IN NUMBER
  , p_supply_source_line_id     IN NUMBER
  , p_supply_source_line_detail IN NUMBER
) IS

l_wms_enabled     VARCHAR2(1) := 'N';
l_debug           NUMBER;
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_supply_source_rcv, supply_source_type_id = ' || p_supply_source_type_id);
   END IF;

   IF (p_supply_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_RCV) THEN

       -- validate the document
       /*
       RCV_package.validate_supply_demand
       (
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , x_valid_status               => l_valid_status
        , p_organization_id            => p_organization_id
        , p_item_id                    => p_inventory_item_id
        , p_supply_demand_code         => 1
        , p_supply_demand_type_id      => p_supply_source_type_id
        , p_supply_demand_header_id    => p_supply_source_header_id
        , p_supply_demand_line_id      => p_supply_source_line_id
        , p_supply_demand_line_detail  => p_supply_source_line_detail
        , p_demand_ship_date           => p_demand_ship_date
        , p_expected_receipt_date      => p_supply_receipt_date
        , p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
      );
      */

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
      ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
          debug_print('validate supply demand returns valid status: ' || l_valid_status);
      END IF;

      IF (l_valid_status = 'N') THEN
          fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY_RCV');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END IF;

      SELECT wms_enabled_flag
      INTO   l_wms_enabled
      FROM   mtl_parameters
      WHERE  organization_id = p_organization_id;

      IF (l_debug = 1) THEN
          debug_print('l_wms_enabled = ' || l_wms_enabled);
      END IF;

      IF (l_wms_enabled = 'N') THEN
          fnd_message.set_name('INV', 'INV_RSV_NON_WMS');
          fnd_message.set_name('SOURCE', 'receiving');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
      END IF;
   ELSE
      IF (l_debug = 1) THEN
          debug_print('The transaction source type is not receiving');
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;
   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Supply_Source_RCV'
              );
      END IF;

END validate_supply_source_rcv;

-- {{Procedure
--   validate_supply_source_wipdisc
-- Description
--   Validation for supply source of DISCRETE
PROCEDURE validate_supply_source_wipdisc
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_supply_source_type_id     IN NUMBER
  , p_supply_source_header_id   IN NUMBER
  , p_supply_source_line_id     IN NUMBER
  , p_supply_source_line_detail IN NUMBER
  , p_wip_entity_type           IN NUMBER
) IS

l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
l_debug              NUMBER;
BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_supply_source_wipdisc, supply_source_type_id = ' || p_supply_source_type_id);
   END IF;

   IF (p_supply_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_WIP) THEN
       IF (p_wip_entity_type = INV_RESERVATION_GLOBAL.G_WIP_SOURCE_TYPE_DISCRETE) THEN


	    -- validate document
	    WIP_RESERVATIONS_GRP.validate_supply_demand
	      (
	       x_return_status              => l_return_status
	       , x_msg_count                  => l_msg_count
	       , x_msg_data                   => l_msg_data
	       , x_valid_status               => l_valid_status
	       , p_organization_id            => p_organization_id
	       , p_item_id                    => p_inventory_item_id
	       , p_supply_demand_code         => 1
	       , p_supply_demand_type_id      => p_supply_source_type_id
	       , p_supply_demand_header_id    => p_supply_source_header_id
	       , p_supply_demand_line_id      => p_supply_source_line_id
	       , p_supply_demand_line_detail  => p_supply_source_line_detail
	       , p_demand_ship_date           => p_demand_ship_date
	       , p_expected_receipt_date      => p_supply_receipt_date
	       , p_api_version_number         => 1.0
	       , p_init_msg_lst              => fnd_api.g_false
	       );

	    IF (l_debug = 1) THEN
	       debug_print('Return status after calling validate supply demand wipdisc: ' || l_valid_status || ' : ' || l_return_status);
	    END IF;

	    IF (l_valid_status = 'N') OR (l_return_status = fnd_api.g_ret_sts_error) THEN
	       fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY_DISC');
	       fnd_msg_pub.ADD;
	       RAISE fnd_api.g_exc_error;
	     ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
	ELSE
	  IF (l_debug = 1) THEN
	     debug_print('The wip entity type is not Discrete');
	  END IF;
	  RAISE fnd_api.g_exc_error;
       END IF;
    ELSE
      IF (l_debug = 1) THEN
	 debug_print('The transation source type is not WIP discrete');
      END IF;
      RAISE fnd_api.g_exc_error;

   END IF;

   x_return_status := l_return_status;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Supply_Source_WIPDISC'
              );
      END IF;

END validate_supply_source_wipdisc;

-- {{Procedure
--   validate_supply_source_osfm
-- Description
--   Validation for supply source of OSFM
--   if the item is replenish to order, then return error. }}
PROCEDURE validate_supply_source_osfm
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_supply_source_type_id     IN NUMBER
  , p_supply_source_header_id   IN NUMBER
  , p_supply_source_line_id     IN NUMBER
  , p_supply_source_line_detail IN NUMBER
  , p_wip_entity_type           IN NUMBER
) IS

l_replenish_to_order VARCHAR2(1) := 'N';
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
l_debug              NUMBER;
BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_supply_source_osfm, supply_source_type_id = ' || p_supply_source_type_id);
   END IF;

   IF (p_supply_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_WIP) THEN
       IF (p_wip_entity_type = INV_RESERVATION_GLOBAL.G_WIP_SOURCE_TYPE_OSFM) THEN

           -- validate document
           WSM_RESERVATIONS_GRP.validate_supply_demand
             (
                x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , x_valid_status               => l_valid_status
              , p_organization_id            => p_organization_id
              , p_item_id                    => p_inventory_item_id
              , p_supply_demand_code         => 1
              , p_supply_demand_type_id      => p_supply_source_type_id
              , p_supply_demand_header_id    => p_supply_source_header_id
              , p_supply_demand_line_id      => p_supply_source_line_id
              , p_supply_demand_line_detail  => p_supply_source_line_detail
              , p_demand_ship_date           => p_demand_ship_date
              , p_expected_receipt_date      => p_supply_receipt_date
              , p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
            );

           IF (l_return_status = fnd_api.g_ret_sts_error) THEN
               RAISE fnd_api.g_exc_error;
           ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
               RAISE fnd_api.g_exc_unexpected_error;
           END IF;

           IF (l_debug = 1) THEN
               debug_print('validate supply demand returns valid status: ' || l_valid_status);
           END IF;

           IF (l_valid_status = 'N') THEN
               fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY_OSFM');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
           END IF;

           SELECT replenish_to_order_flag
           INTO   l_replenish_to_order
           FROM   mtl_system_items
           WHERE  organization_id = p_organization_id
           AND    inventory_item_id = p_inventory_item_id;

           IF (l_debug = 1) THEN
               debug_print('l_replenish_to_order = ' || l_replenish_to_order);
           END IF;

           IF (l_replenish_to_order = 'Y') THEN
               fnd_message.set_name('INV', 'INV_RSV_REPLEN');
               fnd_message.set_token('SOURCE', 'OSFM');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_error;
           END IF;
       ELSE
           IF (l_debug = 1) THEN
               debug_print('The wip entity type is not OSFM');
           END IF;
           RAISE fnd_api.g_exc_error;
       END IF;
   ELSE
       IF (l_debug = 1) THEN
           debug_print('The transation source type is not WIP');
       END IF;
       RAISE fnd_api.g_exc_error;

   END IF;

   x_return_status := l_return_status;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Supply_Source_OSFM'
              );
      END IF;

END validate_supply_source_osfm;

-- {{Procedure
--   validate_supply_source_fpo
-- Description
--   Validation for supply source of FPO
--   if the item is replenish to order, then return error. }}
PROCEDURE validate_supply_source_fpo
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_supply_source_type_id     IN NUMBER
  , p_supply_source_header_id   IN NUMBER
  , p_supply_source_line_id     IN NUMBER
  , p_supply_source_line_detail IN NUMBER
  , p_wip_entity_type           IN NUMBER
) IS

l_replenish_to_order VARCHAR2(1) := 'N';
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
l_debug              NUMBER;
BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_supply_source_fpo, supply_source_type_id = ' || p_supply_source_type_id);
   END IF;

   IF (p_supply_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_WIP) THEN
       IF (p_wip_entity_type = INV_RESERVATION_GLOBAL.G_WIP_SOURCE_TYPE_FPO) THEN

           -- validate document
           /*
           FPO_package.validate_supply_demand
             (
                x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , x_valid_status               => l_valid_status
              , p_organization_id            => p_organization_id
              , p_item_id                    => p_inventory_item_id
              , p_supply_demand_code         => 1
              , p_supply_demand_type_id      => p_supply_source_type_id
              , p_supply_demand_header_id    => p_supply_source_header_id
              , p_supply_demand_line_id      => p_supply_source_line_id
              , p_supply_demand_line_detail  => p_supply_source_line_detail
              , p_demand_ship_date           => p_demand_ship_date
              , p_expected_receipt_date      => p_supply_receipt_date
              , p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
            );
           */

           IF (l_return_status = fnd_api.g_ret_sts_error) THEN
               RAISE fnd_api.g_exc_error;
           ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
               RAISE fnd_api.g_exc_unexpected_error;
           END IF;

           IF (l_debug = 1) THEN
               debug_print('validate supply demand returns valid status: ' || l_valid_status);
           END IF;

           IF (l_valid_status = 'N') THEN
               fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY_FPO');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
           END IF;

           SELECT replenish_to_order_flag
           INTO   l_replenish_to_order
           FROM   mtl_system_items
           WHERE  organization_id = p_organization_id
           AND    inventory_item_id = p_inventory_item_id;

           IF (l_debug = 1) THEN
               debug_print('l_replenish_to_order = ' || l_replenish_to_order);
           END IF;

           IF (l_replenish_to_order = 'Y') THEN
               fnd_message.set_name('INV', 'INV_RSV_REPLEN');
               fnd_message.set_token('SOURCE', 'FPO');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_error;
           END IF;
       ELSE
           IF (l_debug = 1) THEN
               debug_print('The wip entity type is not FPO');
           END IF;
           RAISE fnd_api.g_exc_error;
       END IF;
   ELSE
       IF (l_debug = 1) THEN
           debug_print('The transation source type is not WIP');
       END IF;
       RAISE fnd_api.g_exc_error;

   END IF;

   x_return_status := l_return_status;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Supply_Source_FPO'
              );
      END IF;

END validate_supply_source_fpo;

-- {{Procedure
--   validate_supply_source_batch
-- Description
--   Validation for supply source of batch
--   if the item is replenish to order, then return error. }}
PROCEDURE validate_supply_source_batch
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_supply_source_type_id     IN NUMBER
  , p_supply_source_header_id   IN NUMBER
  , p_supply_source_line_id     IN NUMBER
  , p_supply_source_line_detail IN NUMBER
  , p_wip_entity_type           IN NUMBER
) IS

l_replenish_to_order VARCHAR2(1) := 'N';
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
l_debug              NUMBER;
BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_supply_source_batch, supply_source_type_id = ' || p_supply_source_type_id);
   END IF;

   IF (p_supply_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_WIP) THEN
       IF (p_wip_entity_type = INV_RESERVATION_GLOBAL.G_WIP_SOURCE_TYPE_BATCH) THEN

           -- validate document
           /*
           BATCH_package.validate_supply_demand
             (
                x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , x_valid_status               => l_valid_status
              , p_organization_id            => p_organization_id
              , p_item_id                    => p_inventory_item_id
              , p_supply_demand_code         => 1
              , p_supply_demand_type_id      => p_supply_source_type_id
              , p_supply_demand_header_id    => p_supply_source_header_id
              , p_supply_demand_line_id      => p_supply_source_line_id
              , p_supply_demand_line_detail  => p_supply_source_line_detail
              , p_demand_ship_date           => p_demand_ship_date
              , p_expected_receipt_date      => p_supply_receipt_date
              , p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
            );
           */

           IF (l_return_status = fnd_api.g_ret_sts_error) THEN
               RAISE fnd_api.g_exc_error;
           ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
               RAISE fnd_api.g_exc_unexpected_error;
           END IF;

           IF (l_debug = 1) THEN
               debug_print('validate supply demand returns valid status: ' || l_valid_status);
           END IF;

           IF (l_valid_status = 'N') THEN
               fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY_BATCH');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
           END IF;

           SELECT replenish_to_order_flag
           INTO   l_replenish_to_order
           FROM   mtl_system_items
           WHERE  organization_id = p_organization_id
           AND    inventory_item_id = p_inventory_item_id;

           IF (l_debug = 1) THEN
               debug_print('l_replenish_to_order = ' || l_replenish_to_order);
           END IF;
           IF (l_replenish_to_order = 'Y') THEN
               fnd_message.set_name('INV', 'INV_RSV_REPLEN');
               fnd_message.set_token('SOURCE', 'Batch');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_error;
           END IF;
       ELSE
           IF (l_debug = 1) THEN
               debug_print('The wip entity type is not Batch');
           END IF;
           RAISE fnd_api.g_exc_error;
       END IF;
   ELSE
       IF (l_debug = 1) THEN
           debug_print('The transation source type is not WIP');
       END IF;
       RAISE fnd_api.g_exc_error;

   END IF;

   x_return_status := l_return_status;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Supply_Source_Batch'
              );
      END IF;

END validate_supply_source_batch;

-- {{Procedure
--   validate_demand_source_so
-- Description
--   Validation for demand source of sales order
--   if it is drop ship sales order line, then return error. }}
PROCEDURE validate_demand_source_so
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_demand_source_type_id     IN NUMBER
  , p_demand_source_header_id   IN NUMBER
  , p_demand_source_line_id     IN NUMBER
  , p_demand_source_line_detail IN NUMBER
) IS

l_dropship_count NUMBER := 0;
l_debug          NUMBER;
l_return_status  VARCHAR2(1) := fnd_api.g_ret_sts_success;

BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_demand_source_so: demand_source_type_id = ' || p_demand_source_type_id);
   END IF;

   IF (p_demand_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE) THEN
      select count(1)
      into   l_dropship_count
      from   oe_drop_ship_sources
      where  header_id = p_demand_source_header_id
      and    line_id = p_demand_source_line_id;

      IF (l_debug = 1) THEN
          debug_print('l_dropship_count = ' || l_dropship_count);
      END IF;

      IF (l_dropship_count >= 1) THEN
         fnd_message.set_name('INV', 'INV_RSV_DS_SO');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
      END IF;

   ELSE
      IF (l_debug = 1) THEN
           debug_print('The transation source type is not sales order');
       END IF;
       RAISE fnd_api.g_exc_error;

   END IF;
   IF (l_debug = 1) THEN
      debug_print('After drop ship check ' || p_demand_source_type_id);
   END IF;
   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Demand_Source_SO'
              );
        END IF;
        --
END validate_demand_source_so;

-- {{Procedure
--   validate_demand_source_cmro
-- Description
--   Validation for demand source of CMRO
--   return error is the document is invalid. }}
PROCEDURE validate_demand_source_cmro
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_demand_source_type_id     IN NUMBER
  , p_demand_source_header_id   IN NUMBER
  , p_demand_source_line_id     IN NUMBER
  , p_demand_source_line_detail IN NUMBER
  , p_wip_entity_type           IN NUMBER
) IS

l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
l_debug           NUMBER;

BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_demand_source_cmro: demand_source_type_id = ' || p_demand_source_type_id);
       debug_print('demand_source_header_id = ' || p_demand_source_header_id);
       debug_print('demand_source_line_id = ' || p_demand_source_line_id);
       debug_print('demand_source_line_detail = ' || p_demand_source_line_detail);
       debug_print('wip_entity_type = ' || p_wip_entity_type);
   END IF;

   IF (p_demand_source_type_id = inv_reservation_global.g_source_type_wip AND
         p_wip_entity_type = inv_reservation_global.g_wip_source_type_cmro) THEN
       -- validate document
       AHL_INV_RESERVATIONS_GRP.validate_supply_demand
         (
            x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , x_valid_status               => l_valid_status
          , p_organization_id            => p_organization_id
          , p_item_id                    => p_inventory_item_id
          , p_supply_demand_code         => 2
          , p_supply_demand_type_id      => p_demand_source_type_id
          , p_supply_demand_header_id    => p_demand_source_header_id
          , p_supply_demand_line_id      => p_demand_source_line_id
          , p_supply_demand_line_detail  => p_demand_source_line_detail
          , p_demand_ship_date           => p_demand_ship_date
          , p_expected_receipt_date      => p_supply_receipt_date
          , p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
        );

       IF (l_return_status = fnd_api.g_ret_sts_error) THEN
           RAISE fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
           RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       IF (l_debug = 1) THEN
           debug_print('validate supply demand returns valid status: ' || l_valid_status);
       END IF;

       IF (l_valid_status = 'N') THEN
           fnd_message.set_name('INV', 'INV_RSV_INVALID_DEMAND_CMRO');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
       END IF;
   ELSE
       -- return error since this is not wip demand source or not CMRO entity type
       fnd_message.set_name('INV', 'INV_INVALID_DEMAND_SOURCE');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Demand_Source_CMRO'
              );
        END IF;
        --
END validate_demand_source_cmro;

-- {{Procedure
--   validate_demand_source_fpo
-- Description
--   Validation for demand source of FPO
--   return error is the document is invalid. }}
PROCEDURE validate_demand_source_fpo
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_demand_source_type_id     IN NUMBER
  , p_demand_source_header_id   IN NUMBER
  , p_demand_source_line_id     IN NUMBER
  , p_demand_source_line_detail IN NUMBER
  , p_wip_entity_type           IN NUMBER
) IS

l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
l_debug           NUMBER;

BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_demand_source_cmro: demand_source_type_id = ' || p_demand_source_type_id);
       debug_print('demand_source_header_id = ' || p_demand_source_header_id);
       debug_print('demand_source_line_id = ' || p_demand_source_line_id);
       debug_print('wip_entity_type = ' || p_wip_entity_type);
   END IF;

   IF (p_demand_source_type_id = inv_reservation_global.g_source_type_wip AND
         p_wip_entity_type = inv_reservation_global.g_wip_source_type_fpo) THEN
       -- validate document
       /*
       FPO_package.validate_supply_demand
         (
            x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , x_valid_status               => l_valid_status
          , p_organization_id            => p_organization_id
          , p_item_id                    => p_inventory_item_id
          , p_supply_demand_code         => 2
          , p_supply_demand_type_id      => p_demand_source_type_id
          , p_supply_demand_header_id    => p_demand_source_header_id
          , p_supply_demand_line_id      => p_demand_source_line_id
          , p_supply_demand_line_detail  => p_demand_source_line_detail
          , p_demand_ship_date           => p_demand_ship_date
          , p_expected_receipt_date      => p_supply_receipt_date
          , p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
        );
       */

       IF (l_return_status = fnd_api.g_ret_sts_error) THEN
           RAISE fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
           RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       IF (l_debug = 1) THEN
           debug_print('validate supply demand returns valid status: ' || l_valid_status);
       END IF;

       IF (l_valid_status = 'N') THEN
           fnd_message.set_name('INV', 'INV_RSV_INVALID_DEMAND_FPO');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
       END IF;
   ELSE
       -- return error since this is not wip demand source or not FPO entity type
       fnd_message.set_name('INV', 'INV_INVALID_DEMAND_SOURCE');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Demand_Source_FPO'
              );
        END IF;
        --
END validate_demand_source_fpo;

-- {{Procedure
--   validate_demand_source_batch
-- Description
--   Validation for demand source of batch
--   return error is the document is invalid. }}
PROCEDURE validate_demand_source_batch
(
    x_return_status             OUT NOCOPY VARCHAR2
  , p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_demand_ship_date          IN DATE
  , p_supply_receipt_date       IN DATE
  , p_demand_source_type_id     IN NUMBER
  , p_demand_source_header_id   IN NUMBER
  , p_demand_source_line_id     IN NUMBER
  , p_demand_source_line_detail IN NUMBER
  , p_wip_entity_type           IN NUMBER
) IS

l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_valid_status    VARCHAR2(1);
l_debug           NUMBER;

BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_demand_source_cmro: demand_source_type_id = ' || p_demand_source_type_id);
       debug_print('demand_source_header_id = ' || p_demand_source_header_id);
       debug_print('demand_source_line_id = ' || p_demand_source_line_id);
       debug_print('wip_entity_type = ' || p_wip_entity_type);
   END IF;

   IF (p_demand_source_type_id = inv_reservation_global.g_source_type_wip AND
         p_wip_entity_type = inv_reservation_global.g_wip_source_type_batch) THEN
       -- validate document
       /*
       Batch_package.validate_supply_demand
         (
            x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , x_valid_status               => l_valid_status
          , p_organization_id            => p_organization_id
          , p_item_id                    => p_inventory_item_id
          , p_supply_demand_code         => 2
          , p_supply_demand_type_id      => p_demand_source_type_id
          , p_supply_demand_header_id    => p_demand_source_header_id
          , p_supply_demand_line_id      => p_demand_source_line_id
          , p_supply_demand_line_detail  => p_demand_source_line_detail
          , p_demand_ship_date           => p_demand_ship_date
          , p_expected_receipt_date      => p_supply_receipt_date
          , p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
        );
       */

       IF (l_return_status = fnd_api.g_ret_sts_error) THEN
           RAISE fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
           RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       IF (l_debug = 1) THEN
           debug_print('validate supply demand returns valid status: ' || l_valid_status);
       END IF;

       IF (l_valid_status = 'N') THEN
           fnd_message.set_name('INV', 'INV_RSV_INVALID_DEMAND_BATCH');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
       END IF;
   ELSE
       -- return error since this is not wip demand source or not OPM Batch entity type
       fnd_message.set_name('INV', 'INV_INVALID_DEMAND_SOURCE');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Demand_Source_Batch'
              );
        END IF;
        --
END validate_demand_source_batch;
/*** End R12 }} ***/

--
--
-- Procedure
--   validate_item_sku
-- Description
--   is valid if all of the following are satisfied
--     1. if the item is not under predefined serial control, p_serial_array
--        is empty (you can only reserve predefined serial number)
--     2. if the item is not under lot control, p_lot_number is null
--     3. if the item is not under revision control, p_revision is null
--     4. if the item is under revision control, it is not true that
--        p_revision is null and p_subinventory_code or p_locator_id is not null
--     5. if the item is under lot control, it is not true that p_lot_number
--        is null and p_subinventory_code or p_locator_id is not null
--     6. if the item is under revision and lot control, it is not true that
--        p_revision is null and p_lot_number is not null
--     7. p_subinventory_code, if not null, is a valid sub in the organization
--     8. if p_subinventory_code is not null and locator control is off,
--        p_locator_id is null
--     9. if p_subinventory_code is null, p_locator_id is null
--    10. if p_revision is not null, it is a valid revision for the item
--    11. if p_lot_number is not null, it is a valid lot number for the item
--        and the lot has not expired
--    12. if p_subiventory_code is not null and the item has restriction on
--        subinventory, p_subiventory_code is a valid sub for the item
--    13. if p_subiventory_code is not null and the item has no restriction on
--        subinventory, p_subiventory_code is a valid sub (necessary?)
--    14. if p_subiventory_code is not null, and p_locator_id is not null
--        and the item has restriction on subinventory, p_locator_id
--        is a valid locator for the sub
--    15. if p_subiventory_code is not null, and p_locator_id is not null
--        and the item has no restriction on subinventory, p_locator_id
--        is a valid locator for the sub
--    16. if p_serial_array is not empty, all serial number must have
--        valid status
-- INVCONV - Validation added for Inventory Convergence
--    17. if the item is lot_indivisible (lot_divisible_flag <> 'Y'),
--        the reservation must be detailed to lot level.
--

PROCEDURE validate_item_sku
  (
     x_return_status         OUT NOCOPY VARCHAR2
   , p_inventory_item_id     IN  NUMBER
   , p_organization_id       IN  NUMBER
   , p_revision              IN  VARCHAR2
   , p_lot_number            IN  VARCHAR2
   , p_subinventory_code     IN  VARCHAR2
   , p_locator_id            IN  NUMBER
   , p_serial_array          IN  inv_reservation_global.serial_number_tbl_type
   , p_item_cache_index      IN  INTEGER
   , p_org_cache_index       IN  INTEGER
   , x_sub_cache_index       OUT NOCOPY INTEGER
   ) IS
      l_return_status              VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_resultant_locator_control  NUMBER := NULL;
      l_loop_index                 NUMBER := NULL;
      l_sub_cache_index            NUMBER := NULL;
      l_rec                        inv_reservation_global.sub_record;
      l_found                      VARCHAR2(1);
      l_lot_expiration_date        DATE;
      l_debug NUMBER;
      l_default_onhand_status_id NUMBER; -- Bug 6870416
       -- Added for common API
      	 l_rec_loc inv_reservation_global.locator_record;
      	 l_rec_serial inv_reservation_global.serial_record;
      	 l_rec_lot inv_reservation_global.lot_record;


BEGIN

   l_debug := g_debug;
	-- Added for common API
	 l_rec_loc.inventory_location_id:=p_locator_id;
	 l_rec_lot.lot_number:=p_lot_number;
   --
   -- important: org and item should be validated before
   -- this procedure (validate_supply) is called
   -- since here we do not validate them again
   --
   -- if the item is not under predefined serial number control
   -- and the input serial number array is not empty,
	 -- raise the error
	 IF (l_debug = 1) THEN
	    debug_print('Inside validate item sku: ' || l_return_status);
	 END IF;

	 IF inv_reservation_global.g_item_record_cache(p_item_cache_index).serial_number_control_code
	   NOT IN (inv_reservation_global.g_serial_control_predefined,
		   inv_reservation_global.g_serial_control_dynamic_inv)
	   AND  p_serial_array.COUNT >0 THEN
	    fnd_message.set_name('INV', 'INV_EXTRA_SERIAL');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_error;
	 END IF;
	 --
	 IF (l_debug = 1) THEN
	    debug_print('After item cache: ' || l_return_status);
	 END IF;
	 -- if the item is not under lot control
	 -- and the input lot number is not empty,
	 -- raise the error
	 IF inv_reservation_global.g_item_record_cache
	   (p_item_cache_index).lot_control_code =
	   inv_reservation_global.g_lot_control_no
	   AND  p_lot_number IS NOT NULL THEN
	    fnd_message.set_name('INV', 'INV_NO_LOT_CONTROL');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_error;
	 END IF;
	 IF (l_debug = 1) THEN
	    debug_print('After lot cache: ' || l_return_status);
	 END IF;
	 --
	 -- if the item is not under revision control
	 -- and the input revision is not empty,
	 -- raise the error
	 IF inv_reservation_global.g_item_record_cache
	   (p_item_cache_index).revision_qty_control_code =
	   inv_reservation_global.g_revision_control_no
	   AND p_revision IS NOT NULL THEN
	    fnd_message.set_name('INV', 'INV_NO_REVISION_CONTROL');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_error;
	 END IF;
	 --
	 IF (l_debug = 1) THEN
	    debug_print('After rev cache: ' || l_return_status);
	 END IF;
	 -- if the item is under revision control
	 -- and the input revision is null but subinventory_code or locator_id is
	 -- not null, raise the error
	 IF inv_reservation_global.g_item_record_cache
	   (p_item_cache_index).revision_qty_control_code =
	   inv_reservation_global.g_revision_control_yes
	   AND p_revision IS NULL
	     AND (p_subinventory_code IS NOT NULL
		  OR
		  p_locator_id IS NOT NULL
		  ) THEN
	    fnd_message.set_name('INV', 'INV_MISSING_REV');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 IF (l_debug = 1) THEN
	    debug_print('After rev/sub/loc check cache: ' || l_return_status);
	 END IF;
	 --
	 -- if the item is under lot control
	 -- and the input lot_number is null but subinventory_code or locator_id is
	 -- not null, raise the error
	 IF inv_reservation_global.g_item_record_cache
	   (p_item_cache_index).lot_control_code
	   = inv_reservation_global.g_lot_control_yes
	   AND p_lot_number IS NULL
	     AND (p_subinventory_code IS NOT NULL
		  OR
		  p_locator_id IS NOT NULL
		  ) THEN
	    fnd_message.set_name('INV', 'INV_MISSING_LOT');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 IF (l_debug = 1) THEN
	    debug_print('After lot/sub/loc check cache: ' || l_return_status);
	 END IF;
	 --
	 -- if the item is under revision and lot control
	 -- and the input revision is null but lot_number is
	 -- not null, raise the error
	 IF  inv_reservation_global.g_item_record_cache
	   (p_item_cache_index).revision_qty_control_code =
	   inv_reservation_global.g_revision_control_yes
	   AND inv_reservation_global.g_item_record_cache
	   (p_item_cache_index).lot_control_code
	   = inv_reservation_global.g_lot_control_yes
	   AND p_revision IS NULL
	     AND p_lot_number IS NOT NULL THEN
	    fnd_message.set_name('INV', 'INV_MISSING_REV');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 IF (l_debug = 1) THEN
	    debug_print('After lot/rev check cache: ' || l_return_status);
	 END IF;
	 --
	 --
	 -- validate sub if the input is not null
	 IF p_subinventory_code IS NOT NULL THEN
	    inv_reservation_util_pvt.search_sub_cache
	      (
	       x_return_status     => l_return_status
	       , p_subinventory_code => p_subinventory_code
	       , p_organization_id   => p_organization_id
	       , x_index             => l_sub_cache_index
	       );
	    --
	    IF (l_debug = 1) THEN
	       debug_print('After search sub cache: ' || l_return_status);
	    END IF;
	 --
	    IF l_return_status = fnd_api.g_ret_sts_error THEN
	       RAISE fnd_api.g_exc_error;
	    END IF ;
	    --
	    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
	    --
	    -- if the sub is not in the cache, load it into the cache
	    IF l_sub_cache_index IS NULL THEN
	       /*   BEGIN
	       SELECT
		 secondary_inventory_name
		 , organization_id
		 , locator_type
		 , quantity_tracked
		 , asset_inventory
		 , reservable_type
		 INTO l_rec
		 FROM mtl_secondary_inventories
		 WHERE secondary_inventory_name = p_subinventory_code
		 AND organization_id = p_organization_id;
		 --
		 EXCEPTION
		 WHEN NO_DATA_FOUND then
		 fnd_message.set_name('INV','INVALID_SUB');
		 fnd_msg_pub.add;
		 RAISE fnd_api.g_exc_error;
		 END;    */
		 -- Modified to call common API
		 l_rec.secondary_inventory_name :=p_subinventory_code;
	       IF INV_Validate.subinventory
		 (
		  p_sub => l_rec,
		  p_org => inv_reservation_global.g_organization_record_cache(p_org_cache_index)
		  )=INV_Validate.F THEN
		  fnd_message.set_name('INV','INVALID_SUB');
		  fnd_msg_pub.add;
		  RAISE fnd_api.g_exc_error;
	       END IF;


	       --Bug 2334171 Check whether the sub is reservable
          -- Added the below for Bug 6870416
	     IF inv_cache.set_org_rec(p_organization_id) THEN
	        l_default_onhand_status_id := inv_cache.org_rec.default_status_id;
	     END IF;

	     IF l_default_onhand_status_id IS NULL THEN
   	       IF l_rec.reservable_type = inv_globals.g_subinventory_non_reservable
		 THEN  /* non reservable Subinventory */
		  fnd_message.set_name('INV','INV-SUBINV NOT RESERVABLE');
		  fnd_message.set_token('SUBINV', l_rec.secondary_inventory_name);
		  fnd_msg_pub.add;
		  RAISE fnd_api.g_exc_error;
	       END IF;
	     END IF;
	  -- End of changes for Bug 6870416

	       inv_reservation_util_pvt.add_sub_cache
		 (
		  x_return_status => l_return_status
		  , p_sub_record    => l_rec
		  , x_index         => l_sub_cache_index
		  );
	       --
	       IF l_return_status = fnd_api.g_ret_sts_error THEN
		  RAISE fnd_api.g_exc_error;
	       END IF ;
	       --
	       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		  RAISE fnd_api.g_exc_unexpected_error;
	       END IF;
	     ELSE
	       l_rec := inv_reservation_global.g_sub_record_cache(l_sub_cache_index);
	    END IF;
	    --
	    -- check lcator control based on settings at org, sub, item levels
	    l_resultant_locator_control :=
	      inv_reservation_util_pvt.locator_control
	      (
	       p_org_control
	       => inv_reservation_global.g_organization_record_cache
	       (p_org_cache_index)
	       .stock_locator_control_code
	       , p_sub_control
	       => inv_reservation_global.g_sub_record_cache
	       (l_sub_cache_index).locator_type
	       , p_item_control
	       => inv_reservation_global.g_item_record_cache
	       (p_item_cache_index)
	       .location_control_code
	       );
	    --
	    IF (l_resultant_locator_control = 1
	      AND p_locator_id IS NOT NULL AND p_locator_id > 0) THEN
	       fnd_message.set_name('INV', 'INV_NO_LOCATOR_CONTROL');
	       fnd_msg_pub.add;
	       RAISE fnd_api.g_exc_error;
	    END IF;
	    --
	  ELSIF p_locator_id IS NOT NULL THEN
	    -- if the sub is null, but the locator id is not null
	    -- raise the error
	    fnd_message.set_name('INV', 'INV_NO_LOCATOR_CONTROL');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_error;
	 END IF;
	 --
	 -- Now we have validated that values are there.
	 -- Now validate that values are correct
	 IF p_revision IS NOT NULL THEN
	    /* BEGIN
	    SELECT 'Y' INTO l_found
	      FROM mtl_item_revisions
	      WHERE inventory_item_id = p_inventory_item_id
	      AND organization_id = p_organization_id
	      AND revision = p_revision ;
	      --
	      EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	      fnd_message.set_name('INV','INVALID_REVISION');
	      fnd_msg_pub.add;
	      RAISE fnd_api.g_exc_error;
	      END;*/
	      IF INV_Validate.revision
	      (
	       p_revision => p_revision,
	       p_org => inv_reservation_global.g_organization_record_cache
	       (p_org_cache_index),
	       p_item => inv_reservation_global.g_item_record_cache(p_item_cache_index)					)=INV_Validate.F THEN

		 fnd_message.set_name('INV','INVALID_REVISION');
		 fnd_msg_pub.add;
		 RAISE fnd_api.g_exc_error;
	      END IF;

	 END IF;
	 --
    -- Expired lots custom hook
	 IF p_lot_number IS NOT NULL AND NOT inv_pick_release_pub.g_pick_expired_lots THEN
     BEGIN
      SELECT expiration_date INTO l_lot_expiration_date
        FROM mtl_lot_numbers
        WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND lot_number = p_lot_number;
      --
      IF l_lot_expiration_date IS NOT NULL
        AND l_lot_expiration_date < Sysdate THEN
         fnd_message.set_name('INV', 'INV_LOT_EXPIRED');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
      END IF;
      --
     EXCEPTION
      WHEN NO_DATA_FOUND then
         fnd_message.set_name('INV','INV_INVALID_LOT');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
        END;
	 END IF;
	 --
	 IF p_subinventory_code IS NOT NULL THEN
	    --
	    -- validate the sub is valid in the org

	    -- Modified for common API. This validation has already been performed above.

	    /*  BEGIN
	    SELECT 'Y' INTO l_found
	      FROM mtl_secondary_inventories
	      WHERE secondary_inventory_name = p_subinventory_code
	      AND organization_id = p_organization_id;
	      EXCEPTION
	      WHEN no_data_found THEN
	      fnd_message.set_name('INV', 'INVALID_SUB');
	      fnd_msg_pub.add;
	      RAISE fnd_api.g_exc_error;

	      END;*/


	      --
	      IF inv_reservation_global.g_item_record_cache
	      (p_item_cache_index)
	      .restrict_subinventories_code = 1 THEN
		 -- for restricted subs, use table mtl_item_subinventories
        BEGIN
	   SELECT 'Y' INTO l_found
	     FROM mtl_item_sub_trk_all_v
	     WHERE inventory_item_id = p_inventory_item_id
	     AND organization_id = p_organization_id
	     AND secondary_inventory_name = p_subinventory_code;
	   --
	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      fnd_message.set_name('INV','INVALID_SUB');
	      fnd_msg_pub.add;
	      RAISE fnd_api.g_exc_error;
	END ;
	       ELSIF inv_reservation_global.g_item_record_cache
		 (p_item_cache_index)
		 .restrict_subinventories_code = 2 THEN
	      -- item is not restricted to specific subs
        BEGIN
	   SELECT 'Y' INTO l_found
	     FROM mtl_subinventories_trk_val_v
	     WHERE organization_id = p_organization_id
	     AND secondary_inventory_name = p_subinventory_code ;
	   --
	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      fnd_message.SET_NAME('INV','INVALID_SUB');
	      fnd_msg_pub.add;
	      RAISE fnd_api.g_exc_error;
	END ;
	      END IF;
	      --
      -- now if locator id is not null then validate its value


      IF (p_locator_id IS NOT NULL AND p_locator_id > 0) THEN
	 -- check if locator is restricted to subs
	 IF inv_reservation_global.g_item_record_cache
	   (p_item_cache_index)
	   .restrict_locators_code = 1 THEN
           BEGIN
            -- Modified to call common API
	     /* SELECT 'Y' INTO l_found
		FROM
		mtl_secondary_locators msl
		, mtl_item_locations mil
		WHERE msl.inventory_item_id = p_inventory_item_id
		AND msl.organization_id = p_organization_id
		AND msl.subinventory_code = p_subinventory_code
		AND msl.secondary_locator = p_locator_id
		AND msl.secondary_locator = mil.inventory_location_id
		AND (mil.disable_date > sysdate
		     OR mil.disable_date IS NULL
		     );
		     --
	   EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		 fnd_message.set_name('INV','INV_LOCATOR_NOT_AVAILABLE');
		 fnd_msg_pub.add;
		 RAISE fnd_api.g_exc_error; */


           IF INV_Validate.validateLocator(
		p_locator => l_rec_loc,
                p_org => inv_reservation_global.g_organization_record_cache
	         (p_org_cache_index),
                p_sub =>  l_rec,
                p_item =>  inv_reservation_global.g_item_record_cache(p_item_cache_index)
					)=INV_Validate.F THEN
             fnd_message.set_name('INV','INV_LOCATOR_NOT_AVAILABLE');
    		 fnd_msg_pub.add;
    		 RAISE fnd_api.g_exc_error;
           END IF;
	   END;
	 ELSIF inv_reservation_global.g_item_record_cache
	    (p_item_cache_index)
	    .restrict_locators_code = 2 THEN
           /* BEGIN
	       SELECT 'Y' INTO l_found
		 FROM mtl_item_locations
		 WHERE organization_id = p_organization_id
		 AND subinventory_code = p_subinventory_code
		 AND inventory_location_id = p_locator_id
		 AND (disable_date > sysdate
		      OR disable_date IS NULL
		      );
		      --
	    EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		  fnd_message.set_name('INV','INV_LOCATOR_NOT_AVAILABLE');
		  fnd_msg_pub.add;
		  RAISE fnd_api.g_exc_error;
	    END;*/

	    -- Modified for common API

	     IF INV_Validate.validateLocator(
		p_locator => l_rec_loc,
                p_org => inv_reservation_global.g_organization_record_cache
	         (p_org_cache_index),
                p_sub => l_rec)=INV_Validate.F THEN
	           fnd_message.set_name('INV','INV_LOCATOR_NOT_AVAILABLE');
		       fnd_msg_pub.add;
		       RAISE fnd_api.g_exc_error;
             END IF;
	 END IF;
      END IF;      -- if p_locator_id is not null
   END IF;	  -- if p_subinventory_code is not null

   /*** {{ R12 Enhanced reservations code changes ***/
   -- We dont have to validate serial numbers as the serials are
   -- validated as part of validate_serials
   --
   -- Now validate the serial numbers if there is
   -- Check if they exist and have the
   -- right status
   -- IF p_serial_array.COUNT > 0 THEN
   --  l_loop_index := p_serial_array.first ;
   --  BEGIN
   --  LOOP
   -- Modified to call common API
   --/*
   -- SELECT 'Y' INTO l_found
   --  FROM mtl_serial_numbers
   --  WHERE serial_number = p_serial_array(l_loop_index).serial_number
   -- AND current_status IN (1,3)
   -- the next line is commented out as
   -- currently serial number table has not been
   -- updated to include reservation id as a column
   --	    AND reservation_id IS NULL ;
   -- ;*/
   --    l_rec_serial.serial_number:=p_serial_array(l_loop_index).serial_number;
   /*** {{ R12 Enhanced reservations code changes ***/
   --   IF INV_Validate.check_serial(
   --				p_serial => l_rec_serial,
   --				p_org => inv_reservation_global.g_organization_record_cache
   --				(p_org_cache_index),
   --				p_item => inv_reservation_global.g_item_record_cache(p_item_cache_index)
   --				,
   --				p_from_sub => l_rec,
   --				p_lot => l_rec_lot,
   --				p_loc => l_rec_loc,
   --				p_revision => p_revision,
   --				p_msg => 'RSV'
   --				)=INV_Validate.F THEN
   --
   --      fnd_message.set_name('INV','INVALID_SERIAL_NUMBER');
   --     fnd_message.set_token('NUMBER',p_serial_array(l_loop_index).serial_number,FALSE);
   /*** {{ R12 Enhanced ----reservations code changes ***/
   --     fnd_msg_pub.add;
   --      RAISE fnd_api.g_exc_error;
   --   END IF;
   --   EXIT WHEN l_loop_index = p_serial_array.last ;
   --  l_loop_index := p_serial_array.next(l_loop_index);
   --      END LOOP;
   --    /*EXCEPTION
   --   WHEN NO_DATA_FOUND THEN
   --     fnd_message.set_name('INV','INVALID_SERIAL_NUMBER');
   --     fnd_message.set_token('NUMBER',p_serial_array(l_loop_index),FALSE);
   --    fnd_msg_pub.add;
   --     RAISE fnd_api.g_exc_error;
   -- */
   --    END;
   --  END IF;
   /*** End R12 }} ***/

   --
   -- INVCONV BEGIN
   -- Additional validations for process attributes introduced for inventory convergence
   -- ==================================================================================
   --
   -- if the item is defined as lot_indivisible (lot_divisible_flag <> 'Y')
   -- the reservation must be detailed to lot level so ensure that the
   -- lot_number is populated
   IF inv_reservation_global.g_item_record_cache
    (p_item_cache_index).lot_divisible_flag <> 'Y' AND
    inv_reservation_global.g_item_record_cache(p_item_cache_index).lot_control_code = inv_reservation_global.g_lot_control_yes AND
    p_lot_number IS NULL THEN
      fnd_message.set_name('INV', 'INV_INDIVISIBLE_LOT_REQUIRED');      -- INVCONV New Message
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;
  -- INVCONV END
  --
  x_return_status := l_return_status;
  x_sub_cache_index:= l_sub_cache_index;
  --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Validate_Item_SKU'
              );
        END IF;
        --
END validate_item_sku;
--
-- Procedure
--   validate_supply_source
-- Description
--   is valid if all of the following are satisfied
--      1. p_supply_source_type_id is not null
-- no longer needed 2. p_supply_source_header_id or p_supply_source_name is not null
--      3. calling validate_item_sku with the sku info and returning success
PROCEDURE validate_supply_source
(
   x_return_status           OUT NOCOPY VARCHAR2
 , p_inventory_item_id       IN  NUMBER
 , p_organization_id         IN  NUMBER
 , p_supply_source_type_id   IN  NUMBER
 , p_supply_source_header_id IN  NUMBER
 , p_supply_source_line_id   IN  NUMBER
 , p_supply_source_line_detail IN NUMBER
 , p_supply_source_name      IN  VARCHAR2
 , p_demand_source_type_id   IN  NUMBER
 , p_revision                IN  VARCHAR2
 , p_lot_number              IN  VARCHAR2
 , p_subinventory_code       IN  VARCHAR2
 , p_locator_id              IN  NUMBER
 , p_serial_array            IN  inv_reservation_global.serial_number_tbl_type
 , p_demand_ship_date        IN  DATE
 , p_supply_receipt_date     IN  DATE
 , p_item_cache_index        IN  INTEGER
 , p_org_cache_index         IN  INTEGER
 , x_supply_cache_index      OUT NOCOPY INTEGER
 , x_sub_cache_index         OUT NOCOPY INTEGER
 ) IS
    l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_structure_num       NUMBER := NULL;
    l_supply_cache_index  NUMBER := NULL;
    l_sub_cache_index     NUMBER := NULL;
    l_is_valid            NUMBER := NULL;
    l_rec                 inv_reservation_global.supply_record;

    /*** {{ R12 Enhanced reservations code changes ***/
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    l_wip_entity_type NUMBER;
    l_wip_job_type    VARCHAR2(15);
    l_debug           NUMBER;
    /*** End R12 }} ***/

BEGIN
   --
   /*** {{ R12 Enhanced reservations code changes ***/
   IF (g_debug IS NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
      debug_print('In validate_supply_source: supply_source_type_id = ' || p_supply_source_type_id);
      debug_print('In validate_supply_source: supply_source_header_id = ' || p_supply_source_header_id);
      debug_print('In validate_supply_source: supply_source_line_id = ' || p_supply_source_line_id);
      debug_print('In validate_supply_source: supply_source_name = ' || p_supply_source_name);
      debug_print('In validate_supply_source: supply_source_line detail = ' || p_supply_source_line_detail);
      debug_print('In validate_supply_source: demand_source_type_id = ' || p_demand_source_type_id);
   END IF;
   /*** End R12 }} ***/

   IF p_supply_source_type_id IS NULL THEN
      fnd_message.set_name('INV', 'MISSING SUPPLY');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;
   --

   /*** {{ R12 Enhanced reservations code changes ***/
   -- Returns error if we do not support the supply type
   IF (p_supply_source_type_id NOT IN
       (inv_reservation_global.g_source_type_po,
	inv_reservation_global.g_source_type_inv, inv_reservation_global.g_source_type_req,
	inv_reservation_global.g_source_type_internal_req, inv_reservation_global.g_source_type_asn,
	inv_reservation_global.g_source_type_intransit, inv_reservation_global.g_source_type_wip,
        inv_reservation_global.g_source_type_rcv)) THEN

      fnd_message.set_name('INV', 'INV_RSV_INVALID_SUPPLY');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;
   /*** End R12 }} ***/

   IF (l_debug = 1) THEN
      debug_print('Before calling suppy cache. return status :' ||
		  l_return_status);
   END IF;
   -- search for the supply source in the cache first
   inv_reservation_util_pvt.search_supply_cache
     (
      x_return_status           => l_return_status
      , p_supply_source_type_id   => p_supply_source_type_id
      , p_supply_source_header_id => p_supply_source_header_id
      , p_supply_source_line_id   => p_supply_source_line_id
      , p_supply_source_name      => p_supply_source_name
      , x_index                   => l_supply_cache_index
      );
   --
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;
   --
   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   -- for other supply sources (wip, po), call their validation api
   -- when available
   --
   IF (l_debug = 1) THEN
      debug_print('After calling supply cache ' || p_supply_source_type_id);
      debug_print('Return status :' || l_return_status);
   END IF;

   IF p_supply_source_type_id = inv_reservation_global.g_source_type_po
     THEN
      IF (l_debug = 1) THEN
	 debug_print('Before calling validate po ' || l_return_status);
      END IF;
      validate_supply_source_po
	(
	 x_return_status	   => l_return_status
	 , p_organization_id         => p_organization_id
	 , p_inventory_item_id       => p_inventory_item_id
	 , p_demand_ship_date        => p_demand_ship_date
	 , p_supply_receipt_date     => p_supply_receipt_date
	 , p_supply_source_type_id   => p_supply_source_type_id /*** {{ R12 Enhanced reservations code changes }}***/
	 , p_supply_source_header_id => p_supply_source_header_id
	 , p_supply_source_line_id   => p_supply_source_line_id
	 , p_supply_source_line_detail => NULL  /*** {{ R12 Enhanced reservations code changes }}***/
	 );

      IF (l_debug = 1) THEN
	 debug_print('After calling validate po ' || l_return_status);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_supply_source_type_id = inv_reservation_global.g_source_type_req
      THEN
      IF (l_debug = 1) THEN
	 debug_print('Before calling validate req ' || l_return_status);
      END IF;
      validate_supply_source_req
	(
         x_return_status           => l_return_status
	 , p_organization_id         => p_organization_id
	 , p_inventory_item_id       => p_inventory_item_id
	 , p_demand_ship_date        => p_demand_ship_date
	 , p_supply_receipt_date     => p_supply_receipt_date
	 , p_supply_source_type_id   => p_supply_source_type_id /*** {{ R12 Enhanced reservations code changes }}***/
	 , p_supply_source_header_id => p_supply_source_header_id
	 , p_supply_source_line_id   => p_supply_source_line_id
	 , p_supply_source_line_detail => NULL  /*** {{ R12 Enhanced reservations code changes }}***/
	 );
      IF (l_debug = 1) THEN
	 debug_print('After calling validate req ' || l_return_status);
      END IF;
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      /*** {{ R12 Enhanced reservations code changes ***/
    ELSIF (p_supply_source_type_id = inv_reservation_global.g_source_type_internal_req) THEN
      validate_supply_source_intreq
	(
	 x_return_status             => l_return_status
	 , p_organization_id           => p_organization_id
	 , p_inventory_item_id         => p_inventory_item_id
	 , p_demand_ship_date          => p_demand_ship_date
	 , p_supply_receipt_date       => p_supply_receipt_date
	 , p_supply_source_type_id     => p_supply_source_type_id
	 , p_supply_source_header_id   => p_supply_source_header_id
	 , p_supply_source_line_id     => p_supply_source_line_id
	 , p_supply_source_line_detail => NULL
	 );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	 RAISE fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF (p_supply_source_type_id = inv_reservation_global.g_source_type_asn) THEN
      validate_supply_source_asn
	(
         x_return_status             => l_return_status
	 , p_organization_id           => p_organization_id
	 , p_inventory_item_id         => p_inventory_item_id
	 , p_demand_ship_date          => p_demand_ship_date
	 , p_supply_receipt_date       => p_supply_receipt_date
	 , p_supply_source_type_id     => p_supply_source_type_id
	 , p_supply_source_header_id   => p_supply_source_header_id
	 , p_supply_source_line_id     => p_supply_source_line_id
	 , p_supply_source_line_detail => p_supply_source_line_detail
	 );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	 RAISE fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF (p_supply_source_type_id = inv_reservation_global.g_source_type_intransit) THEN
      validate_supply_source_intran
	(
         x_return_status             => l_return_status
	 , p_organization_id           => p_organization_id
	 , p_inventory_item_id         => p_inventory_item_id
	 , p_demand_ship_date          => p_demand_ship_date
	 , p_supply_receipt_date       => p_supply_receipt_date
	 , p_supply_source_type_id     => p_supply_source_type_id
	 , p_supply_source_header_id   => p_supply_source_header_id
	 , p_supply_source_line_id     => p_supply_source_line_id
	 , p_supply_source_line_detail => NULL
	 );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	 RAISE fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF (p_supply_source_type_id = inv_reservation_global.g_source_type_rcv) THEN
      validate_supply_source_rcv
	(
	 x_return_status             => l_return_status
	 , p_organization_id           => p_organization_id
	 , p_item_id                   => p_inventory_item_id
	 , p_demand_ship_date          => p_demand_ship_date
	 , p_supply_receipt_date       => p_supply_receipt_date
	 , p_supply_source_type_id     => p_supply_source_type_id
	 , p_supply_source_header_id   => p_supply_source_header_id
	 , p_supply_source_line_id     => p_supply_source_line_id
	 , p_supply_source_line_detail => NULL
	 );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	 RAISE fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

    ELSIF (p_supply_source_type_id = inv_reservation_global.g_source_type_wip) THEN
      -- get wip entity id from wip_record_cache
      inv_reservation_util_pvt.get_wip_cache
	(
	 x_return_status            => l_return_status
	 , p_wip_entity_id            => p_supply_source_header_id
	 );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	 RAISE fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	 RAISE fnd_api.g_exc_unexpected_error;
       ELSE
	 l_wip_entity_type := inv_reservation_global.g_wip_record_cache(p_supply_source_header_id).wip_entity_type;
	 l_wip_job_type := inv_reservation_global.g_wip_record_cache(p_supply_source_header_id).wip_entity_job;
      END IF;

      IF (l_wip_entity_type NOT IN
	  (inv_reservation_global.g_wip_source_type_discrete,
	   inv_reservation_global.g_wip_source_type_osfm, inv_reservation_global.g_wip_source_type_fpo,
	   inv_reservation_global.g_wip_source_type_batch)) THEN
	 fnd_message.set_name('INV', 'INV_RSV_WIP_ENT_ERR');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;

      -- add validation to check if the supply is wip discrete and osfm, then the
      -- demand source needs to be sales order or internal order, otherwise, error out.
      IF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_discrete OR
	  l_wip_entity_type = inv_reservation_global.g_wip_source_type_osfm) THEN
	 IF (p_demand_source_type_id NOT IN (inv_reservation_global.g_source_type_oe,
					     inv_reservation_global.g_source_type_internal_ord)) THEN
	    fnd_message.set_name('INV', 'INV_INVALID_DEMAND_SOURCE');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	 END IF;
      END IF;

      IF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_discrete) THEN
	 validate_supply_source_wipdisc
	   (
	    x_return_status             => l_return_status
	    , p_organization_id           => p_organization_id
	    , p_inventory_item_id         => p_inventory_item_id
	    , p_demand_ship_date          => p_demand_ship_date
	    , p_supply_receipt_date       => p_supply_receipt_date
	    , p_supply_source_type_id     => p_supply_source_type_id
	    , p_supply_source_header_id   => p_supply_source_header_id
	    , p_supply_source_line_id     => p_supply_source_line_id
	    , p_supply_source_line_detail => NULL
	    , p_wip_entity_type           => l_wip_entity_type
	    );

	 IF (l_debug = 1) THEN
	    debug_print('Return status from supply source wipdisc :' || l_return_status);
	 END IF;

	 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	    RAISE fnd_api.g_exc_error;
	  ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

       ELSIF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_osfm) THEN
	 validate_supply_source_osfm
	   (
	    x_return_status             => l_return_status
	    , p_organization_id           => p_organization_id
	    , p_inventory_item_id         => p_inventory_item_id
	    , p_demand_ship_date          => p_demand_ship_date
	    , p_supply_receipt_date       => p_supply_receipt_date
	    , p_supply_source_type_id     => p_supply_source_type_id
	    , p_supply_source_header_id   => p_supply_source_header_id
	    , p_supply_source_line_id     => p_supply_source_line_id
	    , p_supply_source_line_detail => NULL
	    , p_wip_entity_type           => l_wip_entity_type
	    );

	 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	    RAISE fnd_api.g_exc_error;
	  ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
       ELSIF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_fpo) THEN
	 validate_supply_source_fpo
	   (
	    x_return_status             => l_return_status
	    , p_organization_id           => p_organization_id
	    , p_inventory_item_id         => p_inventory_item_id
	    , p_demand_ship_date          => p_demand_ship_date
	    , p_supply_receipt_date       => p_supply_receipt_date
	    , p_supply_source_type_id     => p_supply_source_type_id
	    , p_supply_source_header_id   => p_supply_source_header_id
	    , p_supply_source_line_id     => p_supply_source_line_id
	    , p_supply_source_line_detail => NULL
	    , p_wip_entity_type           => l_wip_entity_type
	    );
	 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	    RAISE fnd_api.g_exc_error;
	  ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
       ELSIF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_batch) THEN
	 validate_supply_source_batch
	   (
	    x_return_status             => l_return_status
	    , p_organization_id           => p_organization_id
	    , p_inventory_item_id         => p_inventory_item_id
	    , p_demand_ship_date          => p_demand_ship_date
	    , p_supply_receipt_date       => p_supply_receipt_date
	    , p_supply_source_type_id     => p_supply_source_type_id
	    , p_supply_source_header_id   => p_supply_source_header_id
	    , p_supply_source_line_id     => p_supply_source_line_id
	    , p_supply_source_line_detail => NULL
	    , p_wip_entity_type           => l_wip_entity_type
	    );
	 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	    RAISE fnd_api.g_exc_error;
	  ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
      END IF;
      /*** End R12 }} ***/
   END IF;

   -- Here we should know that the supply source is valid
   -- we can add it to cache if it is not there yet
   IF l_supply_cache_index IS NULL THEN
      l_rec.supply_source_type_id   := p_supply_source_type_id;
      l_rec.supply_source_header_id := p_supply_source_header_id;
      l_rec.supply_source_line_id   := p_supply_source_line_id;
      l_rec.supply_source_name      := p_supply_source_name;
      l_rec.is_valid                := 1; -- 1 = true
      --
      inv_reservation_util_pvt.add_supply_cache
	(
	 x_return_status    => l_return_status
	 , p_supply_record    => l_rec
	 , x_index            => l_supply_cache_index
	 );
      --

      IF (l_debug = 1) THEN
	 debug_print('After adding supply cache. Return status :' || l_return_status);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
   --
   -- call validate_item_sku
   IF p_supply_source_type_id = inv_reservation_global.g_source_type_inv
     THEN
      validate_item_sku
	(
	 x_return_status         => l_return_status
	 , p_inventory_item_id     => p_inventory_item_id
	 , p_organization_id       => p_organization_id
	 , p_revision              => p_revision
	 , p_lot_number            => p_lot_number
	 , p_subinventory_code     => p_subinventory_code
	 , p_locator_id            => p_locator_id
	 , p_serial_array          => p_serial_array
	 , p_item_cache_index      => p_item_cache_index
	 , p_org_cache_index       => p_org_cache_index
	 , x_sub_cache_index       => l_sub_cache_index
	 );
      --
      IF (l_debug = 1) THEN
	 debug_print('After adding validate item sku. Return status :' ||
		     l_return_status);
      END IF;
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_subinventory_code IS NOT NULL
      OR  p_locator_id IS NOT NULL
	THEN
      -- if the supply source is not inv, sub, locator should be null and serial number should be empty
      fnd_message.set_name('INV', 'EXTRA_SUPPLY_INFO');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;
   --
   x_sub_cache_index := l_sub_cache_index;
   x_supply_cache_index := l_supply_cache_index;
   x_return_status := l_return_status;
   --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF (l_debug = 1) THEN
	 debug_print('Return status from supply source :' || x_return_status);
      END IF;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Validate_Supply_Source'
              );
      END IF;
      --
END validate_supply_source;
--
-- Procedure
--   validate_quantity
-- Description
--   is valid if all of the following are satisfied
--     1. p_primary_uom or p_reservation_uom is not null
--     2. p_primary_quantity or p_reservation_quantity is not null
--     3. if p_has_serial_number = fnd_api.g_true, p_primary_quantity or
--        if p_primary_quantity is null, p_reservation_quantity is an integer
--     INVCONV
--     Additional validations for single/dual tracking
PROCEDURE validate_quantity
  (
     x_return_status         OUT NOCOPY VARCHAR2
   , p_primary_uom           IN  VARCHAR2
   , p_primary_quantity      IN  NUMBER
   , p_secondary_uom         IN  VARCHAR2                           -- INVCONV
   , p_secondary_quantity    IN  NUMBER                             -- INVCONV
   , p_reservation_uom       IN  VARCHAR2
   , p_reservation_quantity  IN  NUMBER
   , p_lot_number            IN  VARCHAR2                           -- INVCONV
   , p_has_serial_number     IN  VARCHAR2
   , p_item_cache_index      IN  NUMBER                             -- INVCON
   ) IS
      l_return_status              VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_quantity             NUMBER;
      l_error_message        VARCHAR2(1000);                        -- INVCONV
      l_qtys_within_dev      NUMBER DEFAULT 1;                      -- INVCONV
BEGIN
   --
   IF p_primary_uom IS NULL
     AND p_reservation_uom IS NULL THEN
      fnd_message.set_name('INV', 'MISSING UOM');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;
   --
   IF p_primary_quantity IS NULL
     AND p_reservation_quantity IS NULL THEN
      fnd_message.set_name('INV', 'MISSING RSV QUANTITY');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;
   --
   IF p_primary_quantity IS NOT NULL THEN
      l_quantity := p_primary_quantity;
    ELSE
      l_quantity := p_primary_quantity;
   END IF;
   --
   -- the quantity should be an integer
   -- if serial number is provided
   IF l_quantity <> Trunc(l_quantity)
     AND p_has_serial_number = fnd_api.g_true THEN
      fnd_message.set_name('INV', 'INV_QTY_EQ_INTEGER');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;
   --

    -- if the item is not defined as dual control
   -- secondary_uom_code and secondary_reservation_quantity
   -- should be empty
   IF inv_reservation_global.g_item_record_cache
     (p_item_cache_index).tracking_quantity_ind <> 'PS' THEN
     -- SINGLE UOM TRACKING
     -- ===================
     IF p_secondary_uom IS NOT NULL THEN
       fnd_message.set_name('INV', 'INV_SECONDARY_UOM_NOT_REQUIRED');     -- INVCONV New Message
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_error;
     ELSIF p_secondary_quantity IS NOT NULL THEN
       fnd_message.set_name('INV', 'INV_SECONDARY_QTY_NOT_REQUIRED');-- INVCONV New Message
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_error;
     END IF;
   ELSIF inv_reservation_global.g_item_record_cache
     (p_item_cache_index).tracking_quantity_ind = 'PS' THEN
     -- DUAL UOM TRACKING
     -- =================
     IF p_secondary_uom IS NULL THEN
       fnd_message.set_name('INV', 'INV_SECONDARY_UOM_REQUIRED');         -- INVCONV New Message
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_error;
     ELSIF p_secondary_uom <> inv_reservation_global.g_item_record_cache(p_item_cache_index).secondary_uom_code THEN
       fnd_message.set_name('INV', 'INV_INCORRECT_SECONDARY_UOM');        -- INVCONV New Message
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_error;
     ELSIF p_secondary_quantity IS NULL THEN
       fnd_message.set_name('INV', 'INV_SECONDARY_QTY_REQUIRED');    -- INVCONV New Message
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_error;
     END IF;
     -- Ensure that primary/secondary quantities honor the UOM conversion and deviations in place

    /* IF the Reservation UOM and Secondary UOM are the same AND the Reservation qty and the Secondary Reservation
       Qty are the same and it's a fixed conversion item , there's no need to check deviation
       INVCONV Bug#3933849 */
     IF( (inv_reservation_global.g_item_record_cache(p_item_cache_index).secondary_default_ind = 'F')
         AND (p_reservation_quantity = p_secondary_quantity) AND (p_reservation_uom = p_secondary_uom)) THEN
        NULL;
     ELSE
       l_qtys_within_dev := INV_CONVERT.Within_Deviation
                       ( p_organization_id   =>
                                 inv_reservation_global.g_item_record_cache(p_item_cache_index).organization_id
                       , p_inventory_item_id =>
                                 inv_reservation_global.g_item_record_cache(p_item_cache_index).inventory_item_id
                       , p_lot_number        => p_lot_number
                       , p_precision         => 5
                       , p_quantity         => p_primary_quantity
                       , p_uom_code1              => p_primary_uom
                       , p_quantity2         => p_secondary_quantity
                       , p_uom_code2              => p_secondary_uom
                       ) ;

        IF (l_qtys_within_dev <> 1) THEN
           --fnd_message.set_name('INV', l_error_message);
           --fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
        END IF;
     END IF; /* IF for Fixed item */
   END IF;
  -- INVCONV END


   x_return_status := l_return_status;
   --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Validate_Quantity'
              );
        END IF;
	--
END validate_quantity;


--
-- Procedure
--   validate_sales_order
-- Description
--   is valid if all of the following are satisfied
--     1. sales order is open
--     2. p_reservation_item matches the item in the sales order
--     3. p_reservation_quantity is greater or equal to the
--		  reservable quantity = ordered quantity - already reserved qty
--    Bug 1620576 - To support overpicking for pick wave move orders,
--    we have to remove the restriction that reservation quantity cannot
--    exceed sales order quantity
-- {{ R12 Enhanced reservations code changes, add validation for sales order,
--    for non-inventory supply types, if the sales order has not been booked,
--    return error. }}
PROCEDURE validate_sales_order
  (
   x_return_status             OUT NOCOPY VARCHAR2
   , p_rsv_action_name             IN VARCHAR2
   , p_reservation_id		 IN NUMBER
   , p_demand_type_id		 IN NUMBER
   , p_demand_header_id		 IN NUMBER
   , p_demand_line_id		 IN NUMBER
   , p_orig_demand_type_id       IN NUMBER
   , p_orig_demand_header_id     IN NUMBER
   , p_orig_demand_line_id       IN NUMBER
   , p_reservation_quantity	 IN NUMBER
   , p_reservation_uom_code      IN VARCHAR2
   , p_reservation_item_id       IN NUMBER
   , p_reservation_org_id	 IN NUMBER
   , p_supply_type_id            IN NUMBER  /*** {{ R12 Enhanced reservations code changes }}***/
   , p_substitute_flag           IN BOOLEAN DEFAULT FALSE  /* Bug 6044651 */
   ) IS

	l_return_status      	 VARCHAR2(1) := fnd_api.g_ret_sts_success;

	l_org_id			NUMBER;

	l_line_rec_inventory_item_id    oe_order_lines_all.inventory_item_id%TYPE;
	l_line_rec_ordered_quantity	oe_order_lines_all.ordered_quantity%TYPE;
	l_line_rec_order_quantity_uom	oe_order_lines_all.order_quantity_uom%TYPE;
	l_line_rec_org_id		oe_order_lines_all.org_id%TYPE;
	l_line_rec_open_flag	VARCHAR2(1);

	l_ordered_quantity_rsv_uom       	NUMBER := 0;
	l_primary_uom_code  	     	VARCHAR2(3);
	l_primary_reserved_quantity    	NUMBER := 0;
	l_reserved_quantity            	NUMBER := 0;
	l_source_type_code              VARCHAR2(30);
	l_flow_status_code		VARCHAR2(30); --Bug 3118495
        l_booked_flag                   VARCHAR2(1) := 'N'; /*** {{ R12 Enhanced reservations code changes ***/
	l_debug NUMBER := g_debug;
BEGIN
	-- Initialize return status
	x_return_status := fnd_api.g_ret_sts_success;

	IF p_demand_type_id in (inv_reservation_global.g_source_type_oe,
                           inv_reservation_global.g_source_type_internal_ord,
                           inv_reservation_global.g_source_type_rma) THEN

     	        -- Fetch row from oe_order_lines

	        /*l_org_id := OE_GLOBALS.G_ORG_ID;
		IF l_org_id IS NULL THEN
			OE_GLOBALS.Set_Context;
			l_org_id := OE_GLOBALS.G_ORG_ID;
		end if;*/

		l_org_id := p_reservation_org_id;

		SELECT inventory_item_id, ordered_quantity
			, order_quantity_uom, ship_from_org_id
			, open_flag, source_type_code,flow_status_code
                        , booked_flag              /*** {{ R12 Enhanced reservations code changes ***/
		INTO l_line_rec_inventory_item_id,
			 l_line_rec_ordered_quantity,
			 l_line_rec_order_quantity_uom,
			 l_line_rec_org_id,
		         l_line_rec_open_flag,
		         l_source_type_code,
			 l_flow_status_code,
                         l_booked_flag
		FROM    oe_order_lines_all
		WHERE	line_id = p_demand_line_id ;

		-- Bug 2366024 -- Do not perform the reservation check
		-- for drop ship orders - source_type_code = 'EXTERNAL'

		-- Validate 1 -- the sales order has to be open
		IF (p_rsv_action_name = 'CREATE') OR
		  ((p_rsv_action_name IN ('UPDATE','TRANSFER')) AND
		   (Nvl(p_orig_demand_type_id,-99) <>
		    Nvl(p_demand_type_id,-99)) OR
		   (Nvl(p_orig_demand_header_id,-99) <>
		    Nvl(p_demand_header_id,-99)) OR
		   (Nvl(p_orig_demand_line_id,-99) <> Nvl(p_demand_line_id,-99))) THEN
		   IF nvl(l_line_rec_open_flag, 'N') <> 'Y' AND Nvl(l_source_type_code, 'INTERNAL') <> 'EXTERNAL' THEN
		      FND_MESSAGE.SET_NAME('INV', 'INV_RESERVATION_CLOSED_SO');
		      FND_MSG_PUB.add;
		      RAISE fnd_api.g_exc_error;
		   END IF;
		END IF;

		/* Bug 3118495 -- Should not allow user to create a reservation against a shipped sales order line */
		-- Validate 2 -- the sales order line should not be in 'SHIPPED' status
		IF l_flow_status_code = 'SHIPPED' THEN
		   FND_MESSAGE.SET_NAME('INV', 'INV_RESERVATION_SHIPPED_SO');
		   FND_MSG_PUB.add;
		   RAISE fnd_api.g_exc_error;
		END IF;
		-- Validate 3 -- Item : The item on the reservation has to
		--				be the same as the item on the sales order line
		  /* Bug 6044651 Do not perform this validation if substitue item is being used in a sales order */
		  IF p_substitute_flag <> TRUE  THEN
		    IF p_reservation_org_id <> l_line_rec_org_id
			OR p_reservation_item_id <> l_line_rec_inventory_item_id THEN

			FND_MESSAGE.SET_NAME('INV', 'INV_RESERVATION_INVALID_ITEM');
			FND_MSG_PUB.add;
			RAISE fnd_api.g_exc_error;
		    END IF;
                  END IF;
		  /* End of Bug 6044651 */

                -- /*** {{ R12 Enhanced reservations code changes ***/
                -- Validate 4 -- booked_flag: If the supply is not Inventory, sales
                -- order has to be booked.
                IF (nvl(l_booked_flag, 'N') <> 'Y' AND p_supply_type_id <> inv_reservation_global.g_source_type_inv) THEN
                   FND_MESSAGE.SET_NAME('INV', 'INV_RSV_SO_NOT_BOOKED');
                   FND_MSG_PUB.ADD;
                   RAISE fnd_api.g_exc_error;
                END IF;


                -- Validate 5 -- if the demand type is sales order, call validate_demand_source_so
                -- to see if the sales order is dropship order.
                IF (p_demand_type_id = inv_reservation_global.g_source_type_oe) THEN
                    validate_demand_source_so
                       (  x_return_status             => l_return_status
                        , p_demand_source_type_id     => p_demand_type_id
                        , p_demand_source_header_id   => p_demand_header_id
                        , p_demand_source_line_id     => p_demand_line_id
                        , p_demand_source_line_detail => null
                       );

		    IF l_debug = 1 THEN
		       debug_print ('Inside validate sales order after calling validate so' || l_return_status);
		    END IF;

                    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                        RAISE fnd_api.g_exc_error;
                    ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                        RAISE fnd_api.g_exc_unexpected_error;
                    END IF;

                END IF;
                /*** End R12 }} ***/

		-- Validate 3: Reservation Qty
	        -- Bug 1620576 - We can no longer carry out this validation.
	        -- We allow over-reserving when we do an overpick.
              /*
               *-- Convert order quantity into reservation uom code
	       *l_ordered_quantity_rsv_uom := inv_convert.inv_um_convert(
	       *		l_line_rec_inventory_item_id,
	       *		NULL,
	       *		l_line_rec_ordered_quantity,
	       *		l_line_rec_order_quantity_uom,
	       *		p_reservation_uom_code,
	       *		NULL,
	       *	NULL);
       	       *
               *
	       *-- Fetch quantity reserved so far
	       *SELECT nvl(sum(primary_reservation_quantity),0)
	       *INTO l_primary_reserved_quantity
	       *FROM mtl_reservations
	       *WHERE demand_source_type_id   = p_demand_type_id
	       *AND   demand_source_header_id = p_demand_header_id
	       *AND   demand_source_line_id   = p_demand_line_id
	       *AND	reservation_id <> nvl(p_reservation_id,-1);
	       *
	       *IF l_primary_reserved_quantity > 0 then
               *
	       *	-- Get primary UOM
	       *	select primary_uom_code
	       *	into l_primary_uom_code
	       *	from mtl_system_items
	       *	where organization_id   = l_line_rec_org_id
	       *	and   inventory_item_id = l_line_rec_inventory_item_id;
               *
	       *	-- Convert primary reservation quantity into
	       *	-- reservation uom code
	       *	l_reserved_quantity :=
	       *		inv_convert.inv_um_convert
	       *		(
	       *			l_line_rec_inventory_item_id,
	       *			NULL,
	       *			l_primary_reserved_quantity,
	       *			l_primary_uom_code,
	       *			p_reservation_uom_code,
	       *			NULL,
	       *			NULL);
	       *else
	       *	l_reserved_quantity := 0;
	       *end if;
               **
	       *-- Quantity that can be still reserved must be no less than the
	       *--  reservation quantity--- can not over reserve
               **
	       *IF (l_ordered_quantity_rsv_uom - l_reserved_quantity) <
               *      p_reservation_quantity THEN
	       *	FND_MESSAGE.SET_NAME('INV','INV_RSV_ORDER_QTY_VALID');
	       *	FND_MSG_PUB.ADD;
	       *	RAISE fnd_api.g_exc_error;
	       *END IF;
	       */

		 IF (l_debug = 1) THEN
		    debug_print ('Inside validate sales order after' || l_return_status);
		 END IF;

	END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Validate_Sales_Order'
              );
        END IF;
END validate_sales_order;

--
-- Procedure
--   validate_demand_source
-- Description
--   is valid if all of the following are satisfied
--     1. p_demand_source_type_id is not null
--     2. p_demand_source_header_id
--        or p_demand_source_name is not null
--     3. if p_demand_source_type_id is inventory or the type id > 100
--        (user defined source type), the p_demand_source_name is not null
--     4. if p_demand_source_type is account, account number is valid
--     5. if p_demand_source_type is account alias, alias is valid
-- /*** {{ R12 Enhanced reservations code changes ***/
--     6. if p_demand_source_type is WIP, return errors if entity type
--        is not CMRO, OPM Batch or OPM FPO
-- /*** End R12 }} ***/
PROCEDURE validate_demand_source
  (
   x_return_status                OUT NOCOPY VARCHAR2
   , p_rsv_action_name              IN VARCHAR2
   , p_inventory_item_id            IN  NUMBER
   , p_organization_id              IN  NUMBER
   , p_demand_source_type_id        IN  NUMBER
   , p_demand_source_header_id      IN  NUMBER
   , p_demand_source_line_id        IN  NUMBER
   , p_demand_source_line_detail    IN  NUMBER
   , p_orig_demand_source_type_id   IN  NUMBER
   , p_orig_demand_source_header_id IN  NUMBER
   , p_orig_demand_source_line_id   IN  NUMBER
   , p_orig_demand_source_detail    IN  NUMBER
   , p_demand_source_name           IN  VARCHAR2
   , p_reservation_id               IN  NUMBER
   , p_reservation_quantity         IN  NUMBER
   , p_reservation_uom_code         IN  VARCHAR2
   , p_supply_type_id               IN  NUMBER
   , p_demand_ship_date             IN  DATE
   , p_supply_receipt_date          IN  DATE
   , x_demand_cache_index           OUT NOCOPY INTEGER
   , p_substitute_flag              IN BOOLEAN DEFAULT FALSE /* Bug 6044651 */
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_structure_num   NUMBER := NULL;
      l_index           NUMBER := NULL;
      l_is_valid        NUMBER := NULL;
      l_rec             inv_reservation_global.demand_record;
      /*** {{ R12 Enhanced reservations code changes ***/
      l_debug           NUMBER;
      l_msg_count       NUMBER;
      l_msg_data        VARCHAR2(1000);
      l_wip_entity_type NUMBER;
      l_wip_job_type    VARCHAR2(15);
      /*** End R12 }} ***/
BEGIN
   --
   /*** {{ R12 Enhanced reservations code changes ***/
   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
     debug_print('In validate_demand_source: ' ||
          ', rsv_action_name = ' || p_rsv_action_name ||
          ', inventory_item_id = ' || p_inventory_item_id ||
          ', organization_id = ' || p_organization_id ||
          ', demand_source_type_id = ' || p_demand_source_type_id ||
          ', demand_source_header_id = ' || p_demand_source_header_id ||
          ', demand_source_line_id = ' || p_demand_source_line_id ||
          ', demand_source_detail = ' || p_demand_source_line_detail ||
          ', orig_demand_source_type_id = ' || p_orig_demand_source_type_id ||
          ', orig_demand_source_header_id = ' || p_orig_demand_source_header_id ||
          ', orig_demand_source_line_id = ' || p_orig_demand_source_line_id ||
          ', orig_demand_source_detail = ' || p_orig_demand_source_detail ||
          ', demand_source_name = ' || p_demand_source_name ||
          ', reservation_id = ' || p_reservation_id ||
          ', reservation_quantity = ' || p_reservation_quantity ||
          ', reservation_uom_code = ' || p_reservation_uom_code ||
          ', supply_type_id = ' || p_supply_type_id ||
          ', demand_ship_date = ' || p_demand_ship_date ||
          ', supply_receipt_date = ' || p_supply_receipt_date);
   END IF;
   /*** End R12 }} ***/

   IF p_demand_source_type_id IS NULL
     OR p_demand_source_header_id IS NULL
       AND p_demand_source_name IS NULL THEN
      fnd_message.set_name('INV', 'MISSING DEMAND SOURCE');
      fnd_msg_pub.add;
   END IF;
   --
-- Bug 6124188 Added Demand Source of PO for which reservation gets created
--             in case Return is attemped with profile 'WMS:Express Return' as 'No'

   /*** {{ R12 Enhanced reservations code changes ***/
   IF (p_demand_source_type_id NOT IN
       (inv_reservation_global.g_source_type_inv,inv_reservation_global.g_source_type_po,
	inv_reservation_global.g_source_type_oe, inv_reservation_global.g_source_type_account,
	inv_reservation_global.g_source_type_account_alias,
	inv_reservation_global.g_source_type_cycle_count, inv_reservation_global.g_source_type_physical_inv,
	inv_reservation_global.g_source_type_internal_ord,
	inv_reservation_global.g_source_type_rma, inv_reservation_global.g_source_type_wip)
       AND NOT(p_demand_source_type_id >100)) THEN
      fnd_message.set_name('INV','INV_INVALID_DEMAND_SOURCE');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;
   /*** End R12 }} ***/

   -- if the demand source type is inventory, or type id > 100
   -- the source name should not be null
   IF p_demand_source_type_id = inv_reservation_global.g_source_type_inv
     OR p_demand_source_type_id > 100 THEN
      if p_demand_source_name IS NULL THEN
         fnd_message.set_name('INV','INV_INVALID_DEMAND_SOURCE');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;
   --
   -- search for the demand source in the cache first
   inv_reservation_util_pvt.search_demand_cache
     (
        x_return_status           => x_return_status
      , p_demand_source_type_id   => p_demand_source_type_id
      , p_demand_source_header_id => p_demand_source_header_id
      , p_demand_source_line_id   => p_demand_source_line_id
      , p_demand_source_name      => p_demand_source_name
      , x_index                   => l_index
      );
   --
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;
   --
   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   -- I would just put valid demand source in the cache for
   -- now. so I do not need to check is_valid
   -- if the source is already in the cache, return successful
   IF l_index IS NOT NULL THEN
      x_demand_cache_index := l_index;
      x_return_status := l_return_status;
      RETURN;
   END IF;
   --
   -- not in cache goes here
   -- if the source type is account, demand header id should not
   -- be null, and it should be a valid GL account number
   IF p_demand_source_type_id = inv_reservation_global.g_source_type_account
     THEN
      IF p_demand_source_header_id IS NOT NULL THEN
         BEGIN
            -- find the flex field structure number
            SELECT
              id_flex_num
              INTO l_structure_num
              FROM
              org_organization_definitions ood
              , fnd_id_flex_structures ffs
              WHERE
              ood.organization_id = p_organization_id
              AND ffs.id_flex_code = 'GL#'
              AND ood.chart_of_accounts_id = ffs.id_flex_num;

            -- call fnd api to validate the account id
            IF NOT fnd_flex_keyval.validate_ccid
              (
                 'SQLGL'
               , 'GL#'
               , l_structure_num
               , p_demand_source_header_id
               ) THEN
               fnd_message.set_name('INV', 'INVALID_ACCOUNT_NUMBER');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_error;
            END IF;
         EXCEPTION
            WHEN no_data_found THEN
               fnd_message.set_name('INV', 'INVALID_ACCOUNT_NUMBER');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_error;
         END;
         --
       ELSE
         fnd_message.set_name('INV', 'INVALID_ACCOUNT_NUMBER');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;
   --
   IF p_demand_source_type_id
     =  inv_reservation_global.g_source_type_account_alias
     THEN
      IF p_demand_source_header_id IS NOT NULL THEN
         IF NOT fnd_flex_keyval.validate_ccid
           (
              appl_short_name   => 'INV'
            , key_flex_code      => 'MDSP'
            , structure_number  => 101
            , combination_id    => p_demand_source_header_id
            , data_set          => p_organization_id
            ) THEN
            fnd_message.set_name('INV', 'INVALID_ACCOUNT_ALIAS');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
   END IF;

   /*** {{ R12 Enhanced reservations code changes ***/
   IF (p_demand_source_type_id = inv_reservation_global.g_source_type_wip) THEN
       -- get wip entity id from wip_record_cache
       inv_reservation_util_pvt.get_wip_cache
          (
             x_return_status            => l_return_status
           , p_wip_entity_id            => p_demand_source_header_id
          );

       IF (l_return_status = fnd_api.g_ret_sts_error) THEN
           RAISE fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
           RAISE fnd_api.g_exc_unexpected_error;
       ELSE
           l_wip_entity_type := inv_reservation_global.g_wip_record_cache(p_demand_source_header_id).wip_entity_type;
           l_wip_job_type := inv_reservation_global.g_wip_record_cache(p_demand_source_header_id).wip_entity_job;
       END IF;

       IF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_cmro) THEN
           validate_demand_source_cmro(
               x_return_status             => l_return_status
             , p_organization_id           => p_organization_id
             , p_inventory_item_id         => p_inventory_item_id
             , p_demand_ship_date          => p_demand_ship_date
             , p_supply_receipt_date       => p_supply_receipt_date
             , p_demand_source_type_id     => p_demand_source_type_id
             , p_demand_source_header_id   => p_demand_source_header_id
             , p_demand_source_line_id     => p_demand_source_line_id
             , p_demand_source_line_detail => p_demand_source_line_detail
             , p_wip_entity_type           => l_wip_entity_type
             );

           IF (l_return_status = fnd_api.g_ret_sts_error) THEN
               RAISE fnd_api.g_exc_error;
           ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
               RAISE fnd_api.g_exc_unexpected_error;
           END IF;
       ELSIF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_fpo) THEN
           validate_demand_source_fpo(
               x_return_status             => l_return_status
             , p_organization_id           => p_organization_id
             , p_inventory_item_id         => p_inventory_item_id
             , p_demand_ship_date          => p_demand_ship_date
             , p_supply_receipt_date       => p_supply_receipt_date
             , p_demand_source_type_id     => p_demand_source_type_id
             , p_demand_source_header_id   => p_demand_source_header_id
             , p_demand_source_line_id     => p_demand_source_line_id
             , p_demand_source_line_detail => null
             , p_wip_entity_type           => l_wip_entity_type
             );

           IF (l_return_status = fnd_api.g_ret_sts_error) THEN
               RAISE fnd_api.g_exc_error;
           ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
               RAISE fnd_api.g_exc_unexpected_error;
           END IF;
       ELSIF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_batch) THEN
           validate_demand_source_batch(
               x_return_status             => l_return_status
             , p_organization_id           => p_organization_id
             , p_inventory_item_id         => p_inventory_item_id
             , p_demand_ship_date          => p_demand_ship_date
             , p_supply_receipt_date       => p_supply_receipt_date
             , p_demand_source_type_id     => p_demand_source_type_id
             , p_demand_source_header_id   => p_demand_source_header_id
             , p_demand_source_line_id     => p_demand_source_line_id
             , p_demand_source_line_detail => null
             , p_wip_entity_type           => l_wip_entity_type
             );

           IF (l_return_status = fnd_api.g_ret_sts_error) THEN
               RAISE fnd_api.g_exc_error;
           ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
               RAISE fnd_api.g_exc_unexpected_error;
           END IF;
       END IF;
   END IF;

   IF (p_demand_source_type_id IN (
           inv_reservation_global.g_source_type_oe
         , inv_reservation_global.g_source_type_internal_ord
         , inv_reservation_global.g_source_type_rma)
      ) THEN
     --Bug #5202033
     --If action is UPDATE/TRANSFER and the demand source info has not changed,
     --do not call validate_sales_order
     IF ( (p_rsv_action_name = 'CREATE')
                 OR
          ( (p_rsv_action_name IN ('UPATE', 'TRANSFER')) AND
            ( (p_orig_demand_source_type_id <> p_demand_source_type_id) OR
              (p_orig_demand_source_header_id <> p_demand_source_header_id) OR
              (p_orig_demand_source_line_id <> p_demand_source_line_id)
            )
          )
        ) THEN
       validate_sales_order(
            x_return_status         => l_return_status
          , p_rsv_action_name       => p_rsv_action_name
          , p_reservation_id        => p_reservation_id
          , p_demand_type_id        => p_demand_source_type_id
          , p_demand_header_id      => p_demand_source_header_id
          , p_demand_line_id        => p_demand_source_line_id
          , p_orig_demand_type_id   => p_orig_demand_source_type_id
          , p_orig_demand_header_id => p_orig_demand_source_header_id
          , p_orig_demand_line_id   => p_orig_demand_source_line_id
          , p_reservation_quantity  => p_reservation_quantity
          , p_reservation_uom_code  => p_reservation_uom_code
          , p_reservation_item_id   => p_inventory_item_id
          , p_reservation_org_id    => p_organization_id
          , p_supply_type_id        => p_supply_type_id
	  , p_substitute_flag       => p_substitute_flag); /* Bug 6044651 */


       IF (l_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
       END IF;
     END IF;    --END IF check p_rsv_action
   END IF;    --END IF demand source in SO, Internal Order, RMA

   IF (l_debug = 1) THEN
      debug_print ('After calling validate sales order from within demand source' ||
		   l_return_status);
   END IF;

   /*** End R12 }} ***/

   --
   -- comment out lines below until R11.8 when more demand sources
   -- will be considered
   -- IF p_demand_source_type_id
   --     = inv_reservation_global.g_source_type_wip THEN
   --  call wip_validation api()
   -- IF p_demand_source_type_id
   --     = inv_reservation_global.g_source_type_oe THEN
   --  call oe_validation api()
   --
   l_rec.demand_source_type_id   := p_demand_source_type_id;
   l_rec.demand_source_header_id := p_demand_source_header_id;
   l_rec.demand_source_line_id   := p_demand_source_line_id;
   l_rec.demand_source_name      := p_demand_source_name;
   l_rec.is_valid                := 1; -- 1 = true
   --
   inv_reservation_util_pvt.add_demand_cache
     (
        x_return_status    => l_return_status
      , p_demand_record    => l_rec
      , x_index            => l_index
      );
   --
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;
   --
   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   x_demand_cache_index := l_index;
   x_return_status := l_return_status;
   --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Demand_Source'
              );
        END IF;
        --
END validate_demand_source;

/*** {{ R12 Enhanced reservations code changes ***/
-- Procedure
--   create_crossdock_reservation
-- Description
--   This procedure validates reservations that are crossdocked and
--   indicates whether the intended action can be performed on that
--   reservation record. This is called when a reservation is being
--   created.

PROCEDURE create_crossdock_reservation
 (
    x_return_status  OUT NOCOPY VARCHAR2
  , x_msg_count      OUT NOCOPY NUMBER
  , x_msg_data       OUT NOCOPY VARCHAR2
  , p_rsv_rec        IN  inv_reservation_global.mtl_reservation_rec_type
 ) IS
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_debug           NUMBER;

BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In create_crossdock_reservation');
       debug_print('crossdock_criteria_id = ' || p_rsv_rec.crossdock_criteria_id);
   END IF;

   IF ((p_rsv_rec.crossdock_criteria_id is not null) and
          (p_rsv_rec.crossdock_criteria_id <> fnd_api.g_miss_num)) THEN
       wms_xdock_utils_pvt.create_crossdock_reservation(
                   x_return_status  => l_return_status
                 , p_rsv_rec        => p_rsv_rec
                 );

       IF (l_return_status = fnd_api.g_ret_sts_error) THEN
           IF (l_debug = 1) THEN
               debug_print('create_crossdock_reservation returns error');
           END IF;
           raise fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
           IF (l_debug = 1) THEN
               debug_print('create_crossdock_reservation returns unexpected error');
           END IF;
           raise fnd_api.g_exc_unexpected_error;
       END IF;
   END IF;

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'create_crossdock_reservation'
              );
        END IF;
        --
END create_crossdock_reservation;
/*** End R12 }} ***/


/*** {{ R12 Enhanced reservations code changes ***/
-- Procedure
--   update_crossdock_reservation
-- Description
--   This procedure validates reservations that are crossdocked and
--   indicates whether the intended action can be performed on that
--   reservation record. This is called when a reservation is being
--   updated.

PROCEDURE update_crossdock_reservation
 (
    x_return_status  OUT NOCOPY VARCHAR2
  , x_msg_count      OUT NOCOPY NUMBER
  , x_msg_data       OUT NOCOPY VARCHAR2
  , p_orig_rsv_rec   IN  inv_reservation_global.mtl_reservation_rec_type
  , p_to_rsv_rec     IN  inv_reservation_global.mtl_reservation_rec_type
 ) IS
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_debug           NUMBER;

BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In update_crossdock_reservation');
       debug_print('crossdock_criteria_id = ' || p_to_rsv_rec.crossdock_criteria_id);
   END IF;

   IF ((p_to_rsv_rec.crossdock_criteria_id is not null) and
          (p_to_rsv_rec.crossdock_criteria_id <> fnd_api.g_miss_num)) THEN
       wms_xdock_utils_pvt.update_crossdock_reservation(
                   x_return_status  => l_return_status
                 , p_orig_rsv_rec   => p_orig_rsv_rec
                 , p_new_rsv_rec    => p_to_rsv_rec
                 );

       IF (l_return_status = fnd_api.g_ret_sts_error) THEN
           IF (l_debug = 1) THEN
              debug_print('update_crossdock_reservation returns error');
           END IF;
           raise fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
           IF (l_debug = 1) THEN
               debug_print('update_crossdock_reservation returns unexpected error');
           END IF;
           raise fnd_api.g_exc_unexpected_error;
       END IF;
   END IF;

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'update_crossdock_reservation'
              );
        END IF;
        --
END update_crossdock_reservation;
/*** End R12 }} ***/

/*** {{ R12 Enhanced reservations code changes ***/
-- Procedure
--   transfer_crossdock_reservation
-- Description
--   This procedure validates reservations that are crossdocked and
--   indicates whether the intended action can be performed on that
--   reservation record. This is called when a reservation is being
--   transferred.

PROCEDURE transfer_crossdock_reservation
 (
    x_return_status  OUT NOCOPY VARCHAR2
  , x_msg_count      OUT NOCOPY NUMBER
  , x_msg_data       OUT NOCOPY VARCHAR2
  , p_orig_rsv_rec   IN  inv_reservation_global.mtl_reservation_rec_type
  , p_to_rsv_rec     IN  inv_reservation_global.mtl_reservation_rec_type
 ) IS
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_debug           NUMBER;

BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In transfer_crossdock_reservation');
       debug_print('crossdock_criteria_id = ' || p_to_rsv_rec.crossdock_criteria_id);
   END IF;

   IF ((p_to_rsv_rec.crossdock_criteria_id is not null) and
          (p_to_rsv_rec.crossdock_criteria_id <> fnd_api.g_miss_num)) THEN
       wms_xdock_utils_pvt.transfer_crossdock_reservation(
                   x_return_status  => l_return_status
                 , p_orig_rsv_rec   => p_orig_rsv_rec
                 , p_new_rsv_rec    => p_to_rsv_rec
                 );
       IF (l_return_status = fnd_api.g_ret_sts_error) THEN
           IF (l_debug = 1) THEN
              debug_print('transfer_crossdock_reservation returns error');
           END IF;
           raise fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
           IF (l_debug = 1) THEN
               debug_print('transfer_crossdock_reservation returns unexpected error');
           END IF;
           raise fnd_api.g_exc_unexpected_error;
       END IF;
   END IF;

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'transfer_crossdock_reservation'
              );
        END IF;
        --
END transfer_crossdock_reservation;
/*** End R12 }} ***/

/*** {{ R12 Enhanced reservations code changes ***/
-- Procedure
--   relieve_crossdock_reservation
-- Description
--   This procedure validates reservations that are crossdocked and
--   indicates whether the intended action can be performed on that
--   reservation record. This is called when a reservation is being
--   relieved.

PROCEDURE relieve_crossdock_reservation
 (
    x_return_status  OUT NOCOPY VARCHAR2
  , x_msg_count      OUT NOCOPY NUMBER
  , x_msg_data       OUT NOCOPY VARCHAR2
  , p_rsv_rec        IN  inv_reservation_global.mtl_reservation_rec_type
 ) IS
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_debug           NUMBER;

BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In relieve_crossdock_reservation');
       debug_print('crossdock_criteria_id = ' || p_rsv_rec.crossdock_criteria_id);
   END IF;

   IF ((p_rsv_rec.crossdock_criteria_id is not null) and
          (p_rsv_rec.crossdock_criteria_id <> fnd_api.g_miss_num)) THEN
       wms_xdock_utils_pvt.relieve_crossdock_reservation(
                   x_return_status  => l_return_status
                 , p_rsv_rec        => p_rsv_rec
                 );

       IF (l_return_status = fnd_api.g_ret_sts_error) THEN
           IF (l_debug = 1) THEN
               debug_print('relieve_crossdock_reservation returns error');
           END IF;
           raise fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
           IF (l_debug = 1) THEN
               debug_print('relieve_crossdock_reservation returns unexpected error');
           END IF;
           raise fnd_api.g_exc_unexpected_error;
       END IF;
   END IF;

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'relieve_crossdock_reservation'
              );
        END IF;
        --
END relieve_crossdock_reservation;

/*** {{ R12 Enhanced reservations code changes ***/
-- Procedure
--   delete_crossdock_reservation
-- Description
--   This procedure validates reservations that are crossdocked and
--   indicates whether the intended action can be performed on that
--   reservation record. This is called when a reservation is being
--   deleted.

PROCEDURE delete_crossdock_reservation
 (
    x_return_status  OUT NOCOPY VARCHAR2
  , x_msg_count      OUT NOCOPY NUMBER
  , x_msg_data       OUT NOCOPY VARCHAR2
  , p_rsv_rec        IN  inv_reservation_global.mtl_reservation_rec_type
 ) IS
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_debug           NUMBER;

BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In delete_crossdock_reservation');
       debug_print('crossdock_criteria_id = ' || p_rsv_rec.crossdock_criteria_id);
   END IF;

   IF ((p_rsv_rec.crossdock_criteria_id is not null) and
          (p_rsv_rec.crossdock_criteria_id <> fnd_api.g_miss_num)) THEN
       wms_xdock_utils_pvt.delete_crossdock_reservation(
                   x_return_status  => l_return_status
                 , p_rsv_rec        => p_rsv_rec
                 );

       IF (l_return_status = fnd_api.g_ret_sts_error) THEN
           IF (l_debug = 1) THEN
               debug_print('delete_crossdock_reservation returns error');
           END IF;
           raise fnd_api.g_exc_error;
       ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
           IF (l_debug = 1) THEN
               debug_print('delete_crossdock_reservation returns unexpected error');
           END IF;
           raise fnd_api.g_exc_unexpected_error;
       END IF;
   END IF;

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'delete_crossdock_reservation'
              );
        END IF;
        --
END delete_crossdock_reservation;
/*** End R12 }} ***/

/*** {{ R12 Enhanced reservations code changes ***/
-- Procedure
--   validate_pjm_reservations
-- Description
--   This procedure validates reservation in PJM organization.

PROCEDURE validate_pjm_reservations
 (
    x_return_status              OUT NOCOPY VARCHAR2
  , p_organization_id            IN  NUMBER
  , p_inventory_item_id          IN  NUMBER
  , p_supply_source_type_id      IN  NUMBER
  , p_supply_source_header_id    IN  NUMBER
  , p_supply_source_line_id      IN  NUMBER
  , p_supply_source_line_detail  IN  NUMBER
  , p_project_id                 IN  NUMBER
  , p_task_id                    IN  NUMBER
 ) IS
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_wms_enabled     VARCHAR2(1) := 'N';
l_pjm_enabled     NUMBER := 1;
l_project_count   NUMBER;
l_project_id      NUMBER;
l_task_id         NUMBER;
l_wip_entity_type NUMBER;
l_wip_job_type    VARCHAR2(15);
l_debug           NUMBER;
p_mtl_maintain_rsv_rec inv_reservation_global.mtl_maintain_rsv_rec_type;
l_delete_flag     VARCHAR2(1) := 'N';
l_sort_by_criteria Number;
l_qty_modified    NUMBER := 0;
BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_pjm_reservations');
       debug_print('organization_id = ' || p_organization_id || ' , supply type = ' || p_supply_source_type_id);
   END IF;

   SELECT wms_enabled_flag, project_reference_enabled
   INTO   l_wms_enabled, l_pjm_enabled
   FROM   mtl_parameters
   WHERE  organization_id = p_organization_id;

   IF (l_pjm_enabled = 1 and l_wms_enabled = 'Y') THEN
       IF (p_supply_source_type_id = inv_reservation_global.g_source_type_intransit) THEN
           IF (l_debug = 1) THEN
               debug_print('Reservation of intransit shipment supply cannot be created in PJM and WMS organization');
           END IF;

           fnd_message.set_name('INV', 'INV_RSV_PJM_WMS_INTRAN');
           fnd_msg_pub.ADD;

           RAISE fnd_api.g_exc_error;
       ELSIF (p_supply_source_type_id = inv_reservation_global.g_source_type_po OR
                 p_supply_source_type_id = inv_reservation_global.g_source_type_asn) THEN

           SELECT count(min(po_distribution_id))
           INTO   l_project_count
           FROM   po_distributions_all
           WHERE  po_header_id = p_supply_source_header_id
           AND    line_location_id = p_supply_source_line_id
           group by project_id,  task_id;

           IF (l_project_count > 1) THEN
	      IF (l_debug = 1) THEN
		 debug_print('Multiple project and task combinations exists for the supply line');
		 debug_print('We need to delete the reservations for this supply');
	      END IF;
	      -- Call the reduce reservations API by setting the
	      -- delete_flag to yes. delete all reservations for that
	      -- supply line.
	      l_delete_flag := 'Y';
	      l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
	      p_mtl_maintain_rsv_rec.organization_id := p_organization_id;
	      p_mtl_maintain_rsv_rec.inventory_item_id := p_inventory_item_id;
	      p_mtl_maintain_rsv_rec.supply_source_type_id := p_supply_source_type_id;
	      p_mtl_maintain_rsv_rec.supply_source_header_id := p_supply_source_header_id;
	      p_mtl_maintain_rsv_rec.supply_source_line_id := p_supply_source_line_id;

	      inv_maintain_reservation_pub.reduce_reservation
		(p_api_version_number   => 1.0,
		 p_init_msg_lst         => fnd_api.g_false,
		 x_return_status        => l_return_status,
		 x_msg_count            => l_msg_count,
		 x_msg_data             => l_msg_data,
		 p_mtl_maintain_rsv_rec => p_mtl_maintain_rsv_rec,
		 p_delete_flag          => l_delete_flag,
		 p_sort_by_criteria     => l_sort_by_criteria,
		 x_quantity_modified    => l_qty_modified
		 );

	      IF l_debug=1 THEN
		 debug_print ('Return Status after calling reduce reservations: '|| l_return_status);
	      END IF;

	      IF l_return_status = fnd_api.g_ret_sts_error THEN

		 IF l_debug=1 THEN
		    debug_print('Raising expected error'||l_return_status);
		 END IF;
		 RAISE fnd_api.g_exc_error;

	       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

		 IF l_debug=1 THEN
		    debug_print('Rasing Unexpected error'||l_return_status);
		 END IF;
		 RAISE fnd_api.g_exc_unexpected_error;

	      END IF;
	   END IF; -- project count > 1

           IF ((p_project_id is not null) AND (l_project_count = 1)) THEN
	      SELECT MIN(project_id), MIN(task_id)
		INTO   l_project_id, l_task_id
		FROM   po_distributions_all
		WHERE  po_header_id = p_supply_source_header_id
		AND    line_location_id = p_supply_source_line_id;

	      IF (l_project_id <> p_project_id or l_task_id <> p_task_id) THEN
		 IF (l_debug = 1) THEN
		    debug_print('The project and task of reservation record does not match with the supply line');
		 END IF;

		 IF (l_debug = 1) THEN
		    debug_print('Multiple project and task combinations exists for the supply line');
		    debug_print('We need to delete the reservations for this supply');
		 END IF;
		 -- Call the reduce reservations API by setting the
		 -- delete_flag to yes. delete all reservations for that
		 -- supply line.
		 l_delete_flag := 'Y';
		 l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
		 p_mtl_maintain_rsv_rec.organization_id := p_organization_id;
		 p_mtl_maintain_rsv_rec.inventory_item_id := p_inventory_item_id;
		 p_mtl_maintain_rsv_rec.supply_source_type_id := p_supply_source_type_id;
		 p_mtl_maintain_rsv_rec.supply_source_header_id := p_supply_source_header_id;
		 p_mtl_maintain_rsv_rec.supply_source_line_id := p_supply_source_line_id;

		 inv_maintain_reservation_pub.reduce_reservation
		   (p_api_version_number   => 1.0,
		    p_init_msg_lst         => fnd_api.g_false,
		    x_return_status        => l_return_status,
		     x_msg_count            => l_msg_count,
		     x_msg_data             => l_msg_data,
		     p_mtl_maintain_rsv_rec => p_mtl_maintain_rsv_rec,
		     p_delete_flag          => l_delete_flag,
		     p_sort_by_criteria     => l_sort_by_criteria,
		     x_quantity_modified    => l_qty_modified
		     );

		 IF l_debug=1 THEN
		    debug_print ('Return Status after calling reduce reservations: '|| l_return_status);
		 END IF;

		 IF l_return_status = fnd_api.g_ret_sts_error THEN

		    IF l_debug=1 THEN
		       debug_print('Raising expected error'||l_return_status);
		    END IF;
		    RAISE fnd_api.g_exc_error;

		  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

		    IF l_debug=1 THEN
		       debug_print('Rasing Unexpected error'||l_return_status);
		    END IF;
		    RAISE fnd_api.g_exc_unexpected_error;

		 END IF;
	      END IF;
           END IF;
	ELSIF (p_supply_source_type_id = inv_reservation_global.g_source_type_internal_req OR
	       p_supply_source_type_id = inv_reservation_global.g_source_type_req) THEN

	  SELECT count(1)
	    INTO   l_project_count
	    FROM   po_requisition_lines_all prl, po_req_distributions_all prd
	    WHERE  prl.requisition_header_id = p_supply_source_header_id
	    AND    prl.requisition_line_id = p_supply_source_line_id
	    AND    prl.requisition_line_id = prd.requisition_line_id
	    group by prd.project_id, prd.task_id;

	  IF (l_project_count > 1) THEN
	     IF (l_debug = 1) THEN
		debug_print('Multiple project and task combinations exists for the supply line');
	     END IF;

	     fnd_message.set_name('INV', 'INV_RSV_SUP_MUL_PROJ');
	     fnd_msg_pub.ADD;
	     RAISE fnd_api.g_exc_error;
	  END IF;

	  IF((p_project_id is not null) AND (l_project_count = 1))  THEN
	     SELECT MIN(prd.project_id), MIN(prd.task_id)
               INTO   l_project_id, l_task_id
               FROM   po_requisition_lines_all prl, po_req_distributions_all prd
               WHERE  prl.requisition_header_id = p_supply_source_header_id
               AND    prl.requisition_line_id = p_supply_source_line_id
               AND    prl.requisition_line_id = prd.requisition_line_id;

	     IF (l_project_id <> p_project_id or l_task_id <> p_task_id) THEN
		IF (l_debug = 1) THEN
		   debug_print('The project and task of reservation record does not match with the supply line');
		END IF;

		fnd_message.set_name('INV', 'INV_RSV_SUP_DIFF_PROJ');
		fnd_msg_pub.ADD;
		RAISE fnd_api.g_exc_error;
	     END IF;
	  END IF;
	ELSIF (p_supply_source_type_id = inv_reservation_global.g_source_type_wip) THEN

	  -- get wip entity id from wip_record_cache
	  inv_reservation_util_pvt.get_wip_cache
	    (
	     x_return_status            => l_return_status
	     , p_wip_entity_id            => p_supply_source_header_id
	     );

	  IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	     RAISE fnd_api.g_exc_error;
           ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	     RAISE fnd_api.g_exc_unexpected_error;
           ELSE
	     l_wip_entity_type := inv_reservation_global.g_wip_record_cache(p_supply_source_header_id).wip_entity_type;
	     l_wip_job_type := inv_reservation_global.g_wip_record_cache(p_supply_source_header_id).wip_entity_job;
	  END IF;

	  -- Commenting out the code as we dont validate for these supply
	  --types
	  /************************************
	  IF (l_wip_entity_type IN (inv_reservation_global.g_wip_source_type_discrete,
	    inv_reservation_global.g_wip_source_type_osfm,
	    inv_reservation_global.g_wip_source_type_fpo,
	    inv_reservation_global.g_wip_source_type_batch)) THEN

	    SELECT count(1)
	    INTO   l_project_count
	    FROM   wip_discrete_jobs
	    WHERE  wip_entity_id = p_supply_source_header_id
	    group by project_id, task_id;

	    IF (l_project_count > 1) THEN
	    IF (l_debug = 1) THEN
	    debug_print('Multiple project and task combinations exists for the supply line');
	    END IF;

	    fnd_message.set_name('INV', 'INV_RSV_SUP_MUL_PROJ');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	    END IF;

	    IF (p_project_id is not null) THEN
	    SELECT project_id, task_id
	    INTO   l_project_id, l_task_id
	    FROM   wip_discrete_jobs
	    WHERE  wip_entity_id = p_supply_source_header_id;

	    IF (l_project_id <> p_project_id or l_task_id <> p_task_id) THEN
	    IF (l_debug = 1) THEN
	    debug_print('The project and task of reservation record does not match with the supply line');
	    END IF;

	    fnd_message.set_name('INV', 'INV_RSV_SUP_DIFF_PROJ');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	    END IF;
	    END IF;
	    END IF;
	    --commention code for pjm validations for certain supplies
	    *********************************/
	    END IF;
   END IF;

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'validate_pjm_reservations'
              );
        END IF;
        --
END validate_pjm_reservations;
/*** End R12 }} ***/

/*** {{ R12 Enhanced reservations code changes ***/
-- Procedure
--   validate_serials
-- Description
--   1. validate the supply and demand source for serial reservation
--      returns error if the supply is not INV or demand is not
--      CMRO, SO or INV.
--   2. validate if the reservation record is detailed for serial
--      reservation
--   3. validate the serial controls with the (org, item, rev, lot, sub, loc)
--      controls on the reservation record.
--      returns error if they don't match.

PROCEDURE validate_serials
 (
    x_return_status                OUT NOCOPY VARCHAR2
  , p_orig_rsv_rec                 IN  inv_reservation_global.mtl_reservation_rec_type
  , p_to_rsv_rec                   IN  inv_reservation_global.mtl_reservation_rec_type
  , p_orig_serial_array            IN  inv_reservation_global.serial_number_tbl_type
  , p_to_serial_array              IN  inv_reservation_global.serial_number_tbl_type
  , p_rsv_action_name              IN  VARCHAR2
 ) IS
l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(1000);
l_wip_entity_type  NUMBER;
l_wip_job_type     VARCHAR2(15);
l_debug            NUMBER;
l_current_status   NUMBER;
l_organization_id  NUMBER;
l_revision         VARCHAR2(3);
l_subinventory     VARCHAR2(10);
l_locator_id       NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
l_lot_number       VARCHAR2(80);
l_lpn_id           NUMBER;
l_reservation_id   NUMBER;
l_sub_cache_index  NUMBER;
l_item_cache_index NUMBER;
l_org_cache_index  NUMBER;
l_result_locator_control NUMBER;
l_orig_rsv_rec    inv_reservation_global.mtl_reservation_rec_type;
l_to_rsv_rec      inv_reservation_global.mtl_reservation_rec_type;
l_sub_rec         inv_reservation_global.sub_record;
l_org_rec         inv_reservation_global.organization_record;
l_item_rec        inv_reservation_global.item_record;

    CURSOR c_item(p_inventory_item_id NUMBER) IS
         SELECT *
           FROM mtl_system_items
          WHERE inventory_Item_Id = p_inventory_item_id;

BEGIN

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
       debug_print('In validate_serials');
       debug_print('Supply type = ' || p_orig_rsv_rec.supply_source_type_id ||
                   ' ,Demand type = ' || p_orig_rsv_rec.demand_source_type_id);
       debug_print('count of p_orig_serial_array: ' || p_orig_serial_array.COUNT);
       debug_print('count of p_to_serial_array: ' || p_to_serial_array.COUNT);
   END IF;

   IF (p_orig_serial_array.COUNT > 0 or p_to_serial_array.COUNT > 0) THEN

       IF (p_orig_serial_array.COUNT > 0) THEN
	  IF (l_debug = 1) THEN
	     debug_print('Inside from count > 0');
	  END IF;
           -- return error if the p_orig_rsv_rec is null
           IF (p_orig_rsv_rec.organization_id is null OR p_orig_rsv_rec.organization_id = fnd_api.g_miss_num) THEN
               IF (l_debug = 1) THEN
                   debug_print('The reservation record is null');
               END IF;

               fnd_message.set_name('INV', 'INV_RSV_NULL_REC');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
           END IF;

           inv_reservation_util_pvt.search_organization_cache
             (
                x_return_status     => l_return_status
              , p_organization_id   => p_orig_rsv_rec.organization_id
              , x_index             => l_org_cache_index
             );
           --
           IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
           End IF ;
           --
           IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
           End IF;
           --
           IF l_org_cache_index IS NULL THEN
                l_org_rec.organization_id:= p_orig_rsv_rec.organization_id;
            	IF INV_Validate.Organization(
	        	p_org => l_org_rec
					)=INV_Validate.F THEN
            	 fnd_message.set_name('INV', 'INVALID ORGANIZATION');
            	 fnd_msg_pub.add;
            	 RAISE fnd_api.g_exc_error;
            	END IF;

              --
              inv_reservation_util_pvt.add_organization_cache
        	(
          	   x_return_status              => l_return_status
        	 , p_organization_record        => l_org_rec
        	 , x_index                      => l_org_cache_index
        	 );
              --
              IF l_return_status = fnd_api.g_ret_sts_error THEN
        	   RAISE fnd_api.g_exc_error;
              End IF ;

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        	 RAISE fnd_api.g_exc_unexpected_error;
              End IF;

           END IF;

           -- validate the supply source for serial reservation of original reservation record
           IF (p_orig_rsv_rec.supply_source_type_id <> inv_reservation_global.g_source_type_inv) THEN
               IF (l_debug = 1) THEN
                   debug_print('Serial reservation can be created with Inventory supply only');
               END IF;

               fnd_message.set_name('INV', 'INV_RSV_SR_SUP_ERR');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
           END IF;

	   IF (l_debug = 1) THEN
	      debug_print('Before calling WIP cache');
	   END IF;
           -- validate the demand source for serial reservation of original reservation record
           IF (p_orig_rsv_rec.demand_source_type_id = inv_reservation_global.g_source_type_wip) THEN
               -- get wip entity id from wip_record_cache
               inv_reservation_util_pvt.get_wip_cache
                  (
                     x_return_status            => l_return_status
                   , p_wip_entity_id            => p_orig_rsv_rec.demand_source_header_id
                  );

               IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                   RAISE fnd_api.g_exc_error;
               ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                   RAISE fnd_api.g_exc_unexpected_error;
               ELSE
                   l_wip_entity_type := inv_reservation_global.g_wip_record_cache(p_orig_rsv_rec.demand_source_header_id).wip_entity_type;
                   l_wip_job_type := inv_reservation_global.g_wip_record_cache(p_orig_rsv_rec.demand_source_header_id).wip_entity_job;
               END IF;
           END IF;

	   IF (l_debug = 1) THEN
	      debug_print('After calling WIP cache');
	   END IF;

           IF ((p_orig_rsv_rec.demand_source_type_id NOT IN (inv_reservation_global.g_source_type_oe,
                 inv_reservation_global.g_source_type_internal_ord,inv_reservation_global.g_source_type_rma,
                 inv_reservation_global.g_source_type_inv)) AND
               (p_orig_rsv_rec.demand_source_type_id <> inv_reservation_global.g_source_type_wip AND
                  l_wip_entity_type <> inv_reservation_global.g_wip_source_type_cmro)) THEN

                IF (l_debug = 1) THEN
                    debug_print('Serial reservation can be created with Inventory, sales order or CMRO demand only');
                END IF;

                fnd_message.set_name('INV', 'INV_RSV_SR_DEM_ERR');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
           END IF;

	   IF (l_debug = 1) THEN
	      debug_print('Before calling convert missing to null');
	   END IF;
           -- convert the missing value in the reservation record to null
           inv_reservation_pvt.convert_missing_to_null
	     (
	      p_rsv_rec => p_orig_rsv_rec
	      , x_rsv_rec => l_orig_rsv_rec
              );

	   IF (l_debug = 1) THEN
	      debug_print('After convert missing to null');
	   END IF;

           -- get the revision control from item cache, first see if the item cache exists
           inv_reservation_util_pvt.search_item_cache
           (
             x_return_status      => l_return_status
            ,p_inventory_item_id  => l_orig_rsv_rec.inventory_item_id
            ,p_organization_id    => l_orig_rsv_rec.organization_id
            ,x_index              => l_item_cache_index
            );
           --
           If l_return_status = fnd_api.g_ret_sts_error Then
              RAISE fnd_api.g_exc_error;
           End If;
           --
           If l_return_status = fnd_api.g_ret_sts_unexp_error Then
              RAISE fnd_api.g_exc_unexpected_error;
           End If;
           --
           --if item isn't in cache, need to add it
           If l_item_cache_index IS NULL Then
     	      OPEN c_item(l_orig_rsv_rec.inventory_item_id);
          	 FETCH c_item into l_item_rec;
	      CLOSE c_item;

              inv_reservation_util_pvt.add_item_cache
	       (
       	        x_return_status              => l_return_status
     	       ,p_item_record                => l_item_rec
     	       ,x_index                      => l_item_cache_index
	       );
              --
              if l_return_status = fnd_api.g_ret_sts_error then
	        RAISE fnd_api.g_exc_error;
              end if;
              --
              if l_return_status = fnd_api.g_ret_sts_unexp_error then
	         RAISE fnd_api.g_exc_unexpected_error;
              end if;
           End If;

           -- if revision controlled and revision in reservation record is null, return errors
           IF (inv_reservation_global.g_item_record_cache(l_orig_rsv_rec.inventory_item_id).revision_qty_control_code =
	       inv_reservation_global.g_revision_control_yes AND l_orig_rsv_rec.revision is null) THEN
	      IF (l_debug = 1) THEN
		 debug_print('Serial reservation needs to be detailed, revision is null');
	      END IF;

	      fnd_message.set_name('INV', 'INV_RSV_SR_DETAIL');
	      fnd_msg_pub.ADD;
           END IF;

	   IF (l_debug = 1) THEN
	      debug_print('After revision check');
	   END IF;

           -- if lot controlled and lot number is null, return errors
           IF (inv_reservation_global.g_item_record_cache(l_orig_rsv_rec.inventory_item_id).lot_control_code =
                  inv_reservation_global.g_lot_control_yes AND l_orig_rsv_rec.lot_number is null) THEN
               IF (l_debug = 1) THEN
                   debug_print('Serial reservation needs to be detailed, lot number is null');
               END IF;

               fnd_message.set_name('INV', 'INV_RSV_SR_DETAIL');
               fnd_msg_pub.ADD;
           END IF;

	   IF (l_debug = 1) THEN
	      debug_print('After lot check');
	   END IF;

           -- if subinventory is null, return errors
           IF (l_orig_rsv_rec.subinventory_code is null) THEN
	      IF (l_debug = 1) THEN
		 debug_print('Serial reservation needs to be detailed, subinventory is null');
	      END IF;

	      fnd_message.set_name('INV', 'INV_RSV_SR_DETAIL');
	      fnd_msg_pub.ADD;
	    ELSE
	      -- if subinventory is locator controlled and locator is null,
	      --returns error

	      IF (l_debug = 1) THEN
		 debug_print('Before sub cache search');
	      END IF;
	      inv_reservation_util_pvt.search_sub_cache
		(
		 x_return_status     => l_return_status
		 , p_subinventory_code => l_orig_rsv_rec.subinventory_code
		 , p_organization_id   => l_orig_rsv_rec.organization_id
		 , x_index             => l_sub_cache_index
		 );
	      IF (l_debug = 1) THEN
		 debug_print('After sub cache search');
	      END IF;


	      IF l_sub_cache_index IS NULL THEN

		 -- Modified to call common API
		 l_sub_rec.secondary_inventory_name := l_orig_rsv_rec.subinventory_code;
		 l_org_rec.organization_id := l_orig_rsv_rec.organization_id;
		 IF INV_Validate.subinventory
		   (
		    p_sub => l_sub_rec,
		    p_org =>  l_org_rec
		    )=INV_Validate.F THEN
		    fnd_message.set_name('INV','INVALID_SUB');
		    fnd_msg_pub.add;
		    RAISE fnd_api.g_exc_error;
		 END IF;

		 --
		 inv_reservation_util_pvt.add_sub_cache
		   (
		    x_return_status => l_return_status
		    , p_sub_record    => l_sub_rec
		    , x_index         => l_sub_cache_index
		    );
		 --
		 IF l_return_status = fnd_api.g_ret_sts_error THEN
		    RAISE fnd_api.g_exc_error;
		 END IF ;
		 --
		 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		    RAISE fnd_api.g_exc_unexpected_error;
		 END IF;
	      END IF;


	      IF (l_debug = 1) THEN
		 debug_print('Inside checking the locator controls');
		 debug_print('l_orig_rsv_rec.organization_id' ||
			     l_orig_rsv_rec.organization_id);
		 debug_print('sub index' ||l_sub_cache_index);
		 debug_print('sub ' || l_orig_rsv_rec.subinventory_code);
		 debug_print('item id' ||
			     l_orig_rsv_rec.inventory_item_id);

		 debug_print('org control' || inv_reservation_global.g_organization_record_cache
			     (l_orig_rsv_rec.organization_id).stock_locator_control_code);
		 debug_print('sub control' || inv_reservation_global.g_sub_record_cache
			     (l_sub_cache_index).locator_type);
		 debug_print('item control' || inv_reservation_global.g_item_record_cache
			     (l_orig_rsv_rec.inventory_item_id).location_control_code);
	      END IF;

	      l_result_locator_control := inv_reservation_util_pvt.locator_control
		(  p_org_control => inv_reservation_global.g_organization_record_cache
		   (l_orig_rsv_rec.organization_id).stock_locator_control_code
		   , p_sub_control => inv_reservation_global.g_sub_record_cache
		   (l_sub_cache_index).locator_type
		   , p_item_control => inv_reservation_global.g_item_record_cache
		   (l_orig_rsv_rec.inventory_item_id).location_control_code
		   );

	      IF (l_debug = 1) THEN
		 debug_print('l_result_locator_control' || l_result_locator_control);
	      END IF;

	      IF (l_result_locator_control <> 1 AND l_orig_rsv_rec.locator_id is null) THEN
		 IF (l_debug = 1) THEN
		    debug_print('Serial reservation needs to be detailed, locator is null');
		 END IF;

		 fnd_message.set_name('INV', 'INV_RSV_SR_DETAIL');
		 fnd_msg_pub.ADD;
	      END IF;
	      IF (l_debug = 1) THEN
		 debug_print('After loc check');
	      END IF;

           END IF;

	   IF (l_debug = 1) THEN
	      debug_print('After sub/loc check');
	   END IF;

	   IF (l_debug = 1) THEN
	      debug_print('Before loop');
	   END IF;
           -- Get all information for the serial number
           FOR i in 1..p_orig_serial_array.COUNT LOOP

	      IF (l_debug = 1) THEN
		 debug_print('index = ' || i);
		 debug_print('serial number = ' || p_orig_serial_array(i).serial_number);
		 debug_print('inventory item id = ' || p_orig_serial_array(i).inventory_item_id);
	      END IF;

	      BEGIN
		 SELECT current_status,
		   reservation_id,
		   current_organization_id,
		   revision,
		   current_subinventory_code,
		   current_locator_id,
		   lot_number,
		   lpn_id
		   INTO   l_current_status,
		   l_reservation_id,
		   l_organization_id,
		   l_revision,
		   l_subinventory,
		   l_locator_id,
		   l_lot_number,
		   l_lpn_id
		   FROM   mtl_serial_numbers
		   WHERE  serial_number = p_orig_serial_array(i).serial_number
		   AND    inventory_item_id =
		   p_orig_serial_array(i).inventory_item_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF (l_debug = 1) THEN
		       debug_print('did not find any records for the passed
				   information' || SQLERRM);
				   END IF;
				   fnd_message.set_name('INV', 'INV_INVALID_SERIAL');
				   fnd_msg_pub.ADD;
				   RAISE fnd_api.g_exc_error;
				   END;
				   IF (l_debug = 1) THEN
                   debug_print('current_status = ' || l_current_status);
                   debug_print('reservation_id = ' || l_reservation_id);
                   debug_print('organization_id = ' || l_organization_id);
                   debug_print('revision = ' || l_revision);
                   debug_print('subinventory = ' || l_subinventory);
                   debug_print('locator_id = ' || l_locator_id);
                   debug_print('lot_number = ' || l_lot_number);
                   debug_print('l_lpn_id = ' || l_lpn_id);
               END IF;

               -- validate the current status of serial number of original serial number records
               -- return errors if the serial number is not in inventory.

		-- For relieving serials through the TM, the serials may
	       -- have been issued out before calling relieve. In such a
	       -- case, we should not check for status in inventory.
	       -- IF (not(cmro and relieve) and status <> 3) or
	       -- if ((cmro and relieve) and status not in (3,4))
	       -- then error.

	       IF ((NOT(p_orig_rsv_rec.demand_source_type_id =
		       inv_reservation_global.g_source_type_wip AND
		       l_wip_entity_type =
		       inv_reservation_global.g_wip_source_type_cmro) AND
		   ( p_rsv_action_name = 'RELIEVE')) AND
		 (l_current_status <> 3)) OR
		 (((p_orig_rsv_rec.demand_source_type_id =
		       inv_reservation_global.g_source_type_wip AND
		       l_wip_entity_type =
		       inv_reservation_global.g_wip_source_type_cmro) AND
		   ( p_rsv_action_name = 'RELIEVE')) AND (l_current_status NOT IN (3,4)))
		 THEN
                   IF (l_debug = 1) THEN
		      debug_print('The serial number is not in inventory for serial reservation');
                   END IF;

                   fnd_message.set_name('INV', 'INV_RSV_SR_STS_ERR');
                   fnd_msg_pub.ADD;

                   RAISE fnd_api.g_exc_error;
		END IF;

               -- for the form record, validate the serial controls with the (org, item, rev, lot, sub, loc)
               -- controls on the reservation record if we create/delete/relieve reservation
               -- for transfer/update reservation, we validate the serial information with the
               -- reservation_id on the reservation record only because the serial control has
               -- already changed when calling reservation API, we only need to validate the
               -- serial controls with to record.

               IF (p_rsv_action_name = 'CREATE' OR p_rsv_action_name = 'DELETE' OR p_rsv_action_name = 'RELIEVE') THEN

                  IF (l_reservation_id <> nvl(l_orig_rsv_rec.reservation_id, l_reservation_id) OR
                      l_organization_id <> nvl(l_orig_rsv_rec.organization_id, l_organization_id) OR
                      p_orig_serial_array(i).inventory_item_id <>
                        nvl(l_orig_rsv_rec.inventory_item_id, p_orig_serial_array(i).inventory_item_id) OR
                      l_revision <> nvl(l_orig_rsv_rec.revision, l_revision) OR
                      l_subinventory <> nvl(l_orig_rsv_rec.subinventory_code, l_subinventory) OR
                      l_locator_id <> nvl(l_orig_rsv_rec.locator_id, l_locator_id) OR
                      l_lot_number <> nvl(l_orig_rsv_rec.lot_number, l_lot_number) OR
                      l_lpn_id <> nvl(l_orig_rsv_rec.lpn_id, l_lpn_id)) THEN

                      IF (l_debug = 1) THEN
                          debug_print('The serial controls is not same as the reservation controls');
                          debug_print('inventory item id = ' || l_orig_rsv_rec.inventory_item_id);
                          debug_print('reservation_id = ' || l_orig_rsv_rec.reservation_id);
                          debug_print('organization_id = ' || l_orig_rsv_rec.organization_id);
                          debug_print('revision = ' || l_orig_rsv_rec.revision);
                          debug_print('subinventory = ' || l_orig_rsv_rec.subinventory_code);
                          debug_print('locator_id = ' || l_orig_rsv_rec.locator_id);
                          debug_print('lot_number = ' || l_orig_rsv_rec.lot_number);
                      END IF;

                      fnd_message.set_name('INV', 'INV_RSV_SR_NOT_MATCH');
                      fnd_msg_pub.ADD;

                      RAISE fnd_api.g_exc_error;
                  END IF;
               ELSE
                  IF (l_reservation_id <> nvl(l_orig_rsv_rec.reservation_id, l_reservation_id)) THEN

                      IF (l_debug = 1) THEN
                          debug_print('reservation_id = ' || l_orig_rsv_rec.reservation_id);
                      END IF;

                      fnd_message.set_name('INV', 'INV_RSV_SR_NOT_MATCH');
                      fnd_msg_pub.ADD;

                      RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;
           END LOOP;

       END IF; -- end if p_orig_serial_array is not null

       IF (p_to_serial_array.COUNT > 0) THEN
	  IF (l_debug = 1) THEN
	     debug_print('Inside to count > 0');
	  END IF;
           -- return error if the p_to_rsv_rec is null
           IF (p_to_rsv_rec.organization_id is null OR p_to_rsv_rec.organization_id = fnd_api.g_miss_num) THEN
               IF (l_debug = 1) THEN
                   debug_print('The reservation record is null');
               END IF;

               fnd_message.set_name('INV', 'INV_RSV_NULL_REC');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
           END IF;

           inv_reservation_util_pvt.search_organization_cache
             (
                x_return_status     => l_return_status
              , p_organization_id   => p_to_rsv_rec.organization_id
              , x_index             => l_org_cache_index
             );
           --
           IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
           End IF ;
           --
           IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
           End IF;
           --
           IF l_org_cache_index IS NULL THEN
                l_org_rec.organization_id:= p_to_rsv_rec.organization_id;
            	IF INV_Validate.Organization(
	        	p_org => l_org_rec
					)=INV_Validate.F THEN
            	 fnd_message.set_name('INV', 'INVALID ORGANIZATION');
            	 fnd_msg_pub.add;
            	 RAISE fnd_api.g_exc_error;
            	END IF;

              --
              inv_reservation_util_pvt.add_organization_cache
        	(
          	   x_return_status              => l_return_status
        	 , p_organization_record        => l_org_rec
        	 , x_index                      => l_org_cache_index
        	 );
              --
              IF l_return_status = fnd_api.g_ret_sts_error THEN
        	   RAISE fnd_api.g_exc_error;
              End IF ;

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        	 RAISE fnd_api.g_exc_unexpected_error;
              End IF;

           END IF;

	   IF (l_debug = 1) THEN
	     debug_print('After org check: to record: ');
	   END IF;

           -- validate the supply source for serial reservation of to reservation record
           IF (p_to_rsv_rec.supply_source_type_id <> inv_reservation_global.g_source_type_inv) THEN
               IF (l_debug = 1) THEN
                   debug_print('Serial reservation can be created with Inventory supply only');
               END IF;

               fnd_message.set_name('INV', 'INV_RSV_SR_SUP_ERR');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
           END IF;

           -- validate the demand source for serial reservation of to reservation record
           IF (p_to_rsv_rec.demand_source_type_id = inv_reservation_global.g_source_type_wip) THEN
               -- get wip entity id from wip_record_cache
               inv_reservation_util_pvt.get_wip_cache
                  (
                     x_return_status            => l_return_status
                   , p_wip_entity_id            => p_to_rsv_rec.demand_source_header_id
                  );

               IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                   RAISE fnd_api.g_exc_error;
               ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                   RAISE fnd_api.g_exc_unexpected_error;
               ELSE
                   l_wip_entity_type := inv_reservation_global.g_wip_record_cache(p_to_rsv_rec.demand_source_header_id).wip_entity_type;
                   l_wip_job_type := inv_reservation_global.g_wip_record_cache(p_to_rsv_rec.demand_source_header_id).wip_entity_job;
               END IF;
           END IF;

	  IF (l_debug = 1) THEN
	     debug_print('After wip check: to record: ');
	  END IF;

           IF ((p_to_rsv_rec.demand_source_type_id NOT IN (inv_reservation_global.g_source_type_oe,
                 inv_reservation_global.g_source_type_inv)) AND
               (p_to_rsv_rec. demand_source_type_id <> inv_reservation_global.g_source_type_wip AND
                  l_wip_entity_type <> inv_reservation_global.g_wip_source_type_cmro)) THEN

                IF (l_debug = 1) THEN
                    debug_print('Serial reservation can be created with Inventory, sales order or CMRO demand only');
                END IF;

                fnd_message.set_name('INV', 'INV_RSV_SR_DEM_ERR');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
           END IF;

	   IF (l_debug = 1) THEN
	     debug_print('After demand check: to record:');
	   END IF;

           -- convert the missing value in the reservation record to null
           inv_reservation_pvt.convert_missing_to_null
              (
                 p_rsv_rec => p_to_rsv_rec
               , x_rsv_rec => l_to_rsv_rec
              );

	    IF (l_debug = 1) THEN
	     debug_print('After convert missing to null');
	   END IF;

           -- get the revision control from item cache, first see if the item cache exists
           inv_reservation_util_pvt.search_item_cache
           (
             x_return_status      => l_return_status
            ,p_inventory_item_id  => l_to_rsv_rec.inventory_item_id
            ,p_organization_id    => l_to_rsv_rec.organization_id
            ,x_index              => l_item_cache_index
            );
           --
           If l_return_status = fnd_api.g_ret_sts_error Then
              RAISE fnd_api.g_exc_error;
           End If;
           --
           If l_return_status = fnd_api.g_ret_sts_unexp_error Then
              RAISE fnd_api.g_exc_unexpected_error;
           End If;
           --
           --if item isn't in cache, need to add it
           If l_item_cache_index IS NULL Then
     	      OPEN c_item(l_to_rsv_rec.inventory_item_id);
          	 FETCH c_item into l_item_rec;
	      CLOSE c_item;

              inv_reservation_util_pvt.add_item_cache
	       (
       	        x_return_status              => l_return_status
     	       ,p_item_record                => l_item_rec
     	       ,x_index                      => l_item_cache_index
	       );
              --
              if l_return_status = fnd_api.g_ret_sts_error then
	        RAISE fnd_api.g_exc_error;
              end if;
              --
              if l_return_status = fnd_api.g_ret_sts_unexp_error then
	         RAISE fnd_api.g_exc_unexpected_error;
              end if;
           End If;

           -- if revision controlled and revision in reservation record is null, return errors
           IF (inv_reservation_global.g_item_record_cache(l_to_rsv_rec.inventory_item_id).revision_qty_control_code =
                  inv_reservation_global.g_revision_control_yes AND l_to_rsv_rec.revision is null) THEN
               IF (l_debug = 1) THEN
                   debug_print('Serial reservation needs to be detailed, revision is null');
               END IF;

               fnd_message.set_name('INV', 'INV_RSV_SR_DETAIL');
               fnd_msg_pub.ADD;
           END IF;

           -- if lot controlled and lot number is null, return errors
           IF (inv_reservation_global.g_item_record_cache(l_to_rsv_rec.inventory_item_id).lot_control_code =
                  inv_reservation_global.g_lot_control_yes AND l_to_rsv_rec.lot_number is null) THEN
               IF (l_debug = 1) THEN
                   debug_print('Serial reservation needs to be detailed, lot number is null');
               END IF;

               fnd_message.set_name('INV', 'INV_RSV_SR_DETAIL');
               fnd_msg_pub.ADD;
           END IF;

           -- if subinventory is null, return errors
           IF (l_to_rsv_rec.subinventory_code is null) THEN
	      IF (l_debug = 1) THEN
		 debug_print('Serial reservation needs to be detailed, subinventory is null');
	      END IF;

	      fnd_message.set_name('INV', 'INV_RSV_SR_DETAIL');
	      fnd_msg_pub.ADD;
	    ELSE
	      -- if subinventory is locator controlled and locator is null, returns error
	      inv_reservation_util_pvt.search_sub_cache
		(
		 x_return_status     => l_return_status
		 , p_subinventory_code => l_to_rsv_rec.subinventory_code
		 , p_organization_id   => l_to_rsv_rec.organization_id
		 , x_index             => l_sub_cache_index
		 );

	      IF (l_debug = 1) THEN
		 debug_print('After sub cache search');
	      END IF;


	      IF l_sub_cache_index IS NULL THEN

		 -- Modified to call common API
		 l_sub_rec.secondary_inventory_name := l_to_rsv_rec.subinventory_code;
		 l_org_rec.organization_id := l_to_rsv_rec.organization_id;

                 IF (l_debug = 1) THEN
                    debug_print('l_to_rsv_rec.subinventory_code = ' || l_to_rsv_rec.subinventory_code);
                    debug_print('l_orig_rsv_rec.organization_id = ' || l_to_rsv_rec.organization_id);
                 END IF;

		 IF INV_Validate.subinventory
		   (
		    p_sub => l_sub_rec,
		    p_org => l_org_rec
		    )=INV_Validate.F THEN
		    fnd_message.set_name('INV','INVALID_SUB');
		    fnd_msg_pub.add;
		    RAISE fnd_api.g_exc_error;
		 END IF;

		 --
		 inv_reservation_util_pvt.add_sub_cache
		   (
		    x_return_status => l_return_status
		    , p_sub_record    => l_sub_rec
		    , x_index         => l_sub_cache_index
		    );
		 --
		 IF l_return_status = fnd_api.g_ret_sts_error THEN
		    RAISE fnd_api.g_exc_error;
		 END IF ;
		 --
		 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		    RAISE fnd_api.g_exc_unexpected_error;
		 END IF;
	      END IF;

	      IF (l_debug = 1) THEN
		 debug_print('After sub cache check: to record:');
	      END IF;

	      IF (l_debug = 1) THEN
		 debug_print('Inside checking the locator controls');
		 debug_print('l_to_rsv_rec.organization_id' ||
			     l_to_rsv_rec.organization_id);
		 debug_print('sub index' || l_sub_cache_index);
		 debug_print('sub ' || l_to_rsv_rec.subinventory_code);
		 debug_print('item id' ||
			     l_to_rsv_rec.inventory_item_id);

		 debug_print('org control' || inv_reservation_global.g_organization_record_cache
			     (l_to_rsv_rec.organization_id).stock_locator_control_code);
		 debug_print('sub control' || inv_reservation_global.g_sub_record_cache
			     (l_sub_cache_index).locator_type);
		 debug_print('item control' || inv_reservation_global.g_item_record_cache
			     (l_to_rsv_rec.inventory_item_id).location_control_code);
	      END IF;

              l_result_locator_control := inv_reservation_util_pvt.locator_control
                                              (  p_org_control
                                                    => inv_reservation_global.g_organization_record_cache
                                                       (l_to_rsv_rec.organization_id).stock_locator_control_code
                                               , p_sub_control
                                                    => inv_reservation_global.g_sub_record_cache
                                                       (l_sub_cache_index).locator_type
                                               , p_item_control
                                                    => inv_reservation_global.g_item_record_cache
                                                       (l_to_rsv_rec.inventory_item_id).location_control_code
                                               );
               IF (l_result_locator_control <> 1 AND l_to_rsv_rec.locator_id is null) THEN
                   IF (l_debug = 1) THEN
                       debug_print('Serial reservation needs to be detailed, locator is null');
                   END IF;

                   fnd_message.set_name('INV', 'INV_RSV_SR_DETAIL');
                   fnd_msg_pub.ADD;
               END IF;
           END IF;

	   IF (l_debug = 1) THEN
	      debug_print('After loc check: to record:');
	   END IF;
           -- Get all information for the serial number
           FOR i in 1..p_to_serial_array.COUNT LOOP
               SELECT current_status,
                      reservation_id,
                      current_organization_id,
                      revision,
                      current_subinventory_code,
                      current_locator_id,
                      lot_number,
                      lpn_id
               INTO   l_current_status,
                      l_reservation_id,
                      l_organization_id,
                      l_revision,
                      l_subinventory,
                      l_locator_id,
                      l_lot_number,
                      l_lpn_id
               FROM   mtl_serial_numbers
               WHERE  serial_number = p_to_serial_array(i).serial_number
               AND    inventory_item_id = p_to_serial_array(i).inventory_item_id;

	       IF (l_debug = 1) THEN
		  debug_print('IInside serial loop. Serial number: ' || p_to_serial_array(i).serial_number);
	       END IF;

               IF (l_debug = 1) THEN
                   debug_print('index = ' || i);
                   debug_print('serial number = ' || p_to_serial_array(i).serial_number);
                   debug_print('inventory item id = ' || p_to_serial_array(i).inventory_item_id);
                   debug_print('current_status = ' || l_current_status);
                   debug_print('reservation_id = ' || l_reservation_id);
                   debug_print('organization_id = ' || l_organization_id);
                   debug_print('revision = ' || l_revision);
                   debug_print('subinventory = ' || l_subinventory);
                   debug_print('locator_id = ' || l_locator_id);
                   debug_print('lot_number = ' || l_lot_number);
                   debug_print('lpn_id = ' || l_lpn_id);
               END IF;

               -- validate the current status of serial number of original serial number records
               -- return errors if the serial number is not in inventory.
               IF (l_current_status <> 3) THEN
                   IF (l_debug = 1) THEN
                       debug_print('The serial number is not in inventory for serial reservation');
                   END IF;

                   fnd_message.set_name('INV', 'INV_RSV_SR_STS_ERR');
                   fnd_msg_pub.ADD;

                   RAISE fnd_api.g_exc_error;
               END IF;

               -- validate the serial controls with the (org, item, rev, lot, sub, loc) controls
               -- on the reservation record, return errors if they don't match
               IF ((l_to_rsv_rec.reservation_id IS NOT NULL AND p_orig_rsv_rec.reservation_id <> fnd_api.g_miss_num AND
		    l_reservation_id NOT IN (nvl(l_to_rsv_rec.reservation_id, l_reservation_id),
					     nvl(p_orig_rsv_rec.reservation_id, l_reservation_id))) OR l_organization_id <> nvl(l_to_rsv_rec.organization_id, l_organization_id) OR
                   p_to_serial_array(i).inventory_item_id <>
                     nvl(l_to_rsv_rec.inventory_item_id, p_to_serial_array(i).inventory_item_id) OR
                   l_revision <> nvl(l_to_rsv_rec.revision, l_revision) OR
                   l_subinventory <> nvl(l_to_rsv_rec.subinventory_code, l_subinventory) OR
                   l_locator_id <> nvl(l_to_rsv_rec.locator_id, l_locator_id) OR
                   l_lot_number <> nvl(l_to_rsv_rec.lot_number, l_lot_number) OR
                   l_lpn_id <> nvl(l_to_rsv_rec.lpn_id, l_lpn_id)) THEN

                   IF (l_debug = 1) THEN
                       debug_print('The serial controls is not same as the reservation controls');
                       debug_print('inventory item id = ' || l_to_rsv_rec.inventory_item_id);
                       debug_print('orig reservation_id = ' || p_orig_rsv_rec.reservation_id);
                       debug_print('to reservation_id = ' || l_to_rsv_rec.reservation_id);
                       debug_print('l_reservation_id = ' || l_reservation_id);
                       debug_print('organization_id = ' || l_to_rsv_rec.organization_id);
                       debug_print('revision = ' || l_to_rsv_rec.revision);
                       debug_print('subinventory = ' || l_to_rsv_rec.subinventory_code);
                       debug_print('locator_id = ' || l_to_rsv_rec.locator_id);
                       debug_print('lot_number = ' || l_to_rsv_rec.lot_number);
                   END IF;

                   fnd_message.set_name('INV', 'INV_RSV_SR_NOT_MATCH');
                   fnd_msg_pub.ADD;

                   RAISE fnd_api.g_exc_error;
               END IF;
           END LOOP;

       END IF; -- end if p_to_serial_array is not null
   END IF;

   x_return_status := l_return_status;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Validate_Serials'
              );
        END IF;
        --
END validate_serials;
/*** End R12 }} ***/

--
-- Procedure
--   validate_input_parameters
-- Description
--   is valid if all of the following are satisfied
--     1. if p_rsv_action_name is CREATE, or UPDATE, or TRANSFER, or DELETE
--        validate_organization, validate_item, validate_demand_source,
--        validate_supply_source, validate_quantity, validate_sales_order
--		  with the p_orig_rsv_rec
--        (the original reservation record) return success
--     2. if p_rsv_action_name is UPDATE, or TRANSFER
--        validate_organization, validate_item, validate_demand_source,
--        validate_supply_source, validate_quantity with the p_to_rsv_rec
--        (the new reservation record) return success
--    Bug 1937201 - Changed validations so that original_rsv is only
--        validated for the CREATE actions, and that we validate
--        to_rsv for sales order during transfer or update.

PROCEDURE validate_input_parameters
 (
    x_return_status      OUT NOCOPY VARCHAR2
  , p_orig_rsv_rec       IN  inv_reservation_global.mtl_reservation_rec_type
  , p_to_rsv_rec         IN  inv_reservation_global.mtl_reservation_rec_type
  , p_orig_serial_array  IN  inv_reservation_global.serial_number_tbl_type
  , p_to_serial_array    IN  inv_reservation_global.serial_number_tbl_type
  , p_rsv_action_name    IN  VARCHAR2
  , x_orig_item_cache_index   OUT NOCOPY INTEGER
  , x_orig_org_cache_index    OUT NOCOPY INTEGER
  , x_orig_demand_cache_index OUT NOCOPY INTEGER
  , x_orig_supply_cache_index OUT NOCOPY INTEGER
  , x_orig_sub_cache_index    OUT NOCOPY INTEGER
  , x_to_item_cache_index     OUT NOCOPY INTEGER
  , x_to_org_cache_index      OUT NOCOPY INTEGER
  , x_to_demand_cache_index   OUT NOCOPY INTEGER
  , x_to_supply_cache_index   OUT NOCOPY INTEGER
  , x_to_sub_cache_index      OUT NOCOPY INTEGER
  , p_substitute_flag         IN  BOOLEAN DEFAULT FALSE /* Bug 6044651 */
 ) IS
    l_return_status      VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_has_serial_number  VARCHAR2(1);
    l_orig_item_cache_index   INTEGER := NULL;
    l_orig_org_cache_index    INTEGER := NULL;
    l_orig_demand_cache_index INTEGER := NULL;
    l_orig_supply_cache_index INTEGER := NULL;
    l_orig_sub_cache_index    INTEGER := NULL;
    l_to_item_cache_index     INTEGER := NULL;
    l_to_org_cache_index      INTEGER := NULL;
    l_to_demand_cache_index   INTEGER := NULL;
    l_to_supply_cache_index   INTEGER := NULL;
    l_to_sub_cache_index      INTEGER := NULL;
    l_item_rec  inv_reservation_global.item_record;
    /*** {{ R12 Enhanced reservations code changes ***/
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(1000);
    l_debug NUMBER;
    l_demand_source_header_id NUMBER;
    l_demand_source_line_id NUMBER;
    l_demand_ship_date DATE;
    -- Bug 4608452: Added this to check for existing crossdock reservations
    l_wip_entity_type NUMBER;
    l_wip_job_type    VARCHAR2(15);
    /*** End R12 }} ***/
    CURSOR c_item IS
	 SELECT *
	   FROM mtl_system_items
	  WHERE inventory_Item_Id = p_orig_rsv_rec.inventory_item_id;
BEGIN
   --
   -- First validate whether minimum number of arguments are provided for the
   -- listed reservation action. If not error out right away.
   --

   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF p_rsv_action_name  = 'CREATE' THEN
      -- validate item and organization information
      validate_organization
	(
 	   x_return_status   => l_return_status
	 , p_organization_id => p_orig_rsv_rec.organization_id
	 , x_org_cache_index => l_orig_org_cache_index
	 );
      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --
      validate_item
	(
	   x_return_status     => l_return_status
	 , p_inventory_item_id => p_orig_rsv_rec.inventory_item_id
	 , p_organization_id   => p_orig_rsv_rec.organization_id
	 , x_item_cache_index  => l_orig_item_cache_index
	 );
      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --
      validate_demand_source
	(
	 x_return_status           => l_return_status
	 , p_rsv_action_name       => p_rsv_action_name
	 , p_inventory_item_id       => p_orig_rsv_rec.inventory_item_id
	 , p_organization_id         => p_orig_rsv_rec.organization_id
	 , p_demand_source_type_id   => p_orig_rsv_rec.demand_source_type_id
	 , p_demand_source_header_id => p_orig_rsv_rec.demand_source_header_id
	 , p_demand_source_line_id   => p_orig_rsv_rec.demand_source_line_id
	 , p_demand_source_line_detail => p_orig_rsv_rec.demand_source_line_detail
	 , p_orig_demand_source_type_id   => NULL
	 , p_orig_demand_source_header_id => NULL
	 , p_orig_demand_source_line_id   => NULL
	 , p_orig_demand_source_detail    => NULL
	 , p_demand_source_name      => p_orig_rsv_rec.demand_source_name
         , p_reservation_id          => p_orig_rsv_rec.reservation_id   /*** {{ R12 Enhanced reservations code changes ***/
         , p_reservation_quantity    => p_orig_rsv_rec.reservation_quantity
         , p_reservation_uom_code    => p_orig_rsv_rec.reservation_uom_code
         , p_supply_type_id          => p_orig_rsv_rec.supply_source_type_id
         , p_demand_ship_date        => p_orig_rsv_rec.demand_ship_date
         , p_supply_receipt_date     => p_orig_rsv_rec.supply_receipt_date    /*** End R12 }} ***/
	 , x_demand_cache_index      => l_orig_demand_cache_index
	 , p_substitute_flag         => p_substitute_flag  /* Bug 6044651 */
	 );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --

      -- Bug: 4661026: Passing the requirement date if the demand ship date
      -- is null
      IF (p_orig_rsv_rec.supply_source_type_id = inv_reservation_global.g_source_type_wip)
	THEN
	 l_demand_ship_date := Nvl(p_orig_rsv_rec.demand_ship_date,p_orig_rsv_rec.requirement_date);

      END IF;

      validate_supply_source
	(
	   x_return_status           => l_return_status
	 , p_inventory_item_id       => p_orig_rsv_rec.inventory_item_id
	 , p_organization_id         => p_orig_rsv_rec.organization_id
	 , p_supply_source_type_id   => p_orig_rsv_rec.supply_source_type_id
	 , p_supply_source_header_id => p_orig_rsv_rec.supply_source_header_id
	 , p_supply_source_line_id   => p_orig_rsv_rec.supply_source_line_id
	 , p_supply_source_line_detail  => p_orig_rsv_rec.supply_source_line_detail
	 , p_supply_source_name      => p_orig_rsv_rec.supply_source_name
         , p_demand_source_type_id   => p_orig_rsv_rec.demand_source_type_id
	 , p_revision                => p_orig_rsv_rec.revision
	 , p_lot_number              => p_orig_rsv_rec.lot_number
	 , p_subinventory_code       => p_orig_rsv_rec.subinventory_code
	 , p_locator_id              => p_orig_rsv_rec.locator_id
	 , p_serial_array            => p_orig_serial_array
         , p_demand_ship_date        => l_demand_ship_date
         , p_supply_receipt_date     => p_orig_rsv_rec.supply_receipt_date
	 , p_item_cache_index        => l_orig_item_cache_index
	 , p_org_cache_index         => l_orig_org_cache_index
	 , x_supply_cache_index      => l_orig_supply_cache_index
	 , x_sub_cache_index         => l_orig_sub_cache_index
	 );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --
      IF p_orig_serial_array.COUNT > 0 THEN
	 l_has_serial_number := fnd_api.g_true;
       ELSE
	 l_has_serial_number := fnd_api.g_false;
      END IF;
      --
      -- INVCONV BEGIN
      -- Extend validations to cover secondary quantity
      validate_quantity
	(
	   x_return_status         => l_return_status
	 , p_primary_uom           => p_orig_rsv_rec.primary_uom_code
	 , p_primary_quantity
	         => p_orig_rsv_rec.primary_reservation_quantity
         , p_secondary_uom         => p_orig_rsv_rec.secondary_uom_code   -- INVCONV
         , p_secondary_quantity
                 => p_orig_rsv_rec.secondary_reservation_quantity         -- INVCONV
	 , p_reservation_uom       => p_orig_rsv_rec.reservation_uom_code
	 , p_reservation_quantity  => p_orig_rsv_rec.reservation_quantity
         , p_lot_number            => p_orig_rsv_rec.lot_number           -- INVCONV
	 , p_has_serial_number     => l_has_serial_number
         , p_item_cache_index      => l_orig_item_cache_index             -- INVCONV
	 );
      -- INVCONV END
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --

      /*** {{ R12 Enhanced reservations code changes ***/
      create_crossdock_reservation
        (
           x_return_status => l_return_status
         , x_msg_count     => l_msg_count
         , x_msg_data      => l_msg_data
         , p_rsv_rec       => p_orig_rsv_rec
        );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
      	 RAISE fnd_api.g_exc_error;
      ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      validate_pjm_reservations
        (
           x_return_status             => l_return_status
         , p_organization_id           => p_orig_rsv_rec.organization_id
	 , p_inventory_item_id         => p_orig_rsv_rec.inventory_item_id
         , p_supply_source_type_id     => p_orig_rsv_rec.supply_source_type_id
         , p_supply_source_header_id   => p_orig_rsv_rec.supply_source_header_id
         , p_supply_source_line_id     => p_orig_rsv_rec.supply_source_line_id
         , p_supply_source_line_detail => p_orig_rsv_rec.supply_source_line_detail
         , p_project_id                => p_orig_rsv_rec.project_id
         , p_task_id                   => p_orig_rsv_rec.task_id
        );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
      ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      validate_serials
        (
           x_return_status                => l_return_status
         , p_orig_rsv_rec                 => p_orig_rsv_rec
         , p_to_rsv_rec                   => p_to_rsv_rec
         , p_orig_serial_array            => p_orig_serial_array
         , p_to_serial_array              => p_to_serial_array
         , p_rsv_action_name              => p_rsv_action_name
        );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
      ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      /*** End R12 }} ***/

      /*** {{ R12 Enhanced reservations code changes
       -- call from validate_demand_source
      validate_sales_order
      (
          x_return_status        => l_return_status
	, p_reservation_id	 => p_orig_rsv_rec.reservation_id
	, p_demand_type_id	 => p_orig_rsv_rec.demand_source_type_id
	, p_demand_header_id	 => p_orig_rsv_rec.demand_source_header_id
	, p_demand_line_id	 => p_orig_rsv_rec.demand_source_line_id
	, p_reservation_quantity => p_orig_rsv_rec.reservation_quantity
	, p_reservation_uom_code => p_orig_rsv_rec.reservation_uom_code
	, p_reservation_item_id  => p_orig_rsv_rec.inventory_item_id
	, p_reservation_org_id	 => p_orig_rsv_rec.organization_id
      );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
      	RAISE fnd_api.g_exc_error;
      END IF;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
	*** End R12 }} ***/

	-- check to see if there are existing crossdock reservations against this
	--wip job for a different demand. If so, fail.
	IF (p_orig_rsv_rec.supply_source_type_id =
	    INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_WIP) THEN
	   IF (l_debug = 1) THEN
	      debug_print('checked wip');
	   END IF;
	   -- Bug 4608452: Get the wip entity type to check for existing reservations
	   IF (l_debug = 1) THEN
	      debug_print('Before wip job validation');
	   END IF;

	   /*** Get the wip entity type ***/
	   -- get wip entity id from wip_record_cache
	   inv_reservation_util_pvt.get_wip_cache
	     (
	      x_return_status     => l_return_status
	      , p_wip_entity_id   => p_orig_rsv_rec.supply_source_header_id
	      );

	   IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	      RAISE fnd_api.g_exc_error;
	    ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	    ELSE
	      l_wip_entity_type := inv_reservation_global.g_wip_record_cache(p_orig_rsv_rec.supply_source_header_id).wip_entity_type;
	      l_wip_job_type := inv_reservation_global.g_wip_record_cache(p_orig_rsv_rec.supply_source_header_id).wip_entity_job;
	   END IF;

	   IF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_discrete) THEN
	      IF (l_debug = 1) THEN
		 debug_print('inside wip');
	      END IF;
	     BEGIN
		SELECT distinct
		  inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id),
		  wdd.source_line_id INTO l_demand_source_header_id, l_demand_source_line_id
		  FROM mtl_txn_request_lines mtrl, wms_license_plate_numbers wlpn,
		  wsh_delivery_details wdd
		  WHERE mtrl.organization_id = p_orig_rsv_rec.organization_id
		  AND mtrl.inventory_item_id = p_orig_rsv_rec.inventory_item_id
		  AND mtrl.line_status <> 5 -- not closed move order lines
		  AND NVL(mtrl.quantity_delivered, 0) = 0
		  AND mtrl.txn_source_id = p_orig_rsv_rec.supply_source_header_id
		  AND mtrl.lpn_id = wlpn.lpn_id
		  AND wlpn.lpn_context = 2 -- WIP LPN
		  AND mtrl.crossdock_type = 1 -- Crossdocked to OE demand
		  AND mtrl.backorder_delivery_detail_id IS NOT NULL
		    AND mtrl.backorder_delivery_detail_id =
		    wdd.delivery_detail_id;
	     EXCEPTION
		WHEN no_data_found THEN
		   IF (l_debug = 1) THEN
		      debug_print('No records found for this WIP job that has been crossdocked');
		   END IF;
	     END;

	     IF (l_demand_source_header_id <>
		 p_orig_rsv_rec.demand_source_header_id) OR
	       (l_demand_source_line_id <>
		p_orig_rsv_rec.demand_source_line_id) THEN
		IF (l_debug = 1) THEN
		   debug_print('Job already has a crossdocked reservation for a different demand');
		   fnd_message.set_name('INV', 'INV_INVALID_DEMAND_SOURCE');
		   fnd_msg_pub.add;
		   RAISE fnd_api.g_exc_error;
		END IF;
	     END IF;
	   END IF;
	END IF;
	--
  ELSE  -- if we don't do validation, still need to populate item cache
      --the item cache info is used to created the quantity tree
      inv_reservation_util_pvt.search_item_cache
      (
        x_return_status      => l_return_status
       ,p_inventory_item_id  => p_orig_rsv_rec.inventory_item_id
       ,p_organization_id    => p_orig_rsv_rec.organization_id
       ,x_index              => l_orig_item_cache_index
       );
      --
      If l_return_status = fnd_api.g_ret_sts_error Then
         RAISE fnd_api.g_exc_error;
      End If;
      --
      If l_return_status = fnd_api.g_ret_sts_unexp_error Then
         RAISE fnd_api.g_exc_unexpected_error;
      End If;
      --
      --if item isn't in cache, need to add it
      If l_orig_item_cache_index IS NULL Then
	 OPEN c_item;
	 FETCH c_item into l_item_rec;
	 CLOSE c_item;

         inv_reservation_util_pvt.add_item_cache
	  (
  	   x_return_status              => l_return_status
	  ,p_item_record                => l_item_rec
	  ,x_index                      => l_orig_item_cache_index
	  );
         --
         if l_return_status = fnd_api.g_ret_sts_error then
	   RAISE fnd_api.g_exc_error;
         end if;
         --
         if l_return_status = fnd_api.g_ret_sts_unexp_error then
	    RAISE fnd_api.g_exc_unexpected_error;
         end if;
      End If;
  END IF;
  --
  IF p_rsv_action_name IN ('UPDATE', 'TRANSFER') THEN
      -- validate item and organization information
      validate_organization
	(
 	   x_return_status   => l_return_status
	 , p_organization_id => p_to_rsv_rec.organization_id
	 , x_org_cache_index => l_to_org_cache_index
	 );
      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --
      validate_item
	(
	   x_return_status     => l_return_status
	 , p_inventory_item_id => p_to_rsv_rec.inventory_item_id
	 , p_organization_id   => p_to_rsv_rec.organization_id
	 , x_item_cache_index  => l_to_item_cache_index
	 );
      --
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --
      validate_demand_source
	(
	 x_return_status           => l_return_status
	 , p_rsv_action_name       => p_rsv_action_name
	 , p_inventory_item_id       => p_to_rsv_rec.inventory_item_id
	 , p_organization_id         => p_to_rsv_rec.organization_id
	 , p_demand_source_type_id   => p_to_rsv_rec.demand_source_type_id
	 , p_demand_source_header_id => p_to_rsv_rec.demand_source_header_id
	 , p_demand_source_line_id   => p_to_rsv_rec.demand_source_line_id
	 , p_demand_source_line_detail =>
	 p_to_rsv_rec.demand_source_line_detail
	 , p_orig_demand_source_type_id   => p_orig_rsv_rec.demand_source_type_id
	 , p_orig_demand_source_header_id => p_orig_rsv_rec.demand_source_header_id
	 , p_orig_demand_source_line_id   => p_orig_rsv_rec.demand_source_line_id
	 , p_orig_demand_source_detail => p_orig_rsv_rec.demand_source_line_detail
	 , p_demand_source_name      => p_to_rsv_rec.demand_source_name
         , p_reservation_id          => p_to_rsv_rec.reservation_id   /*** {{ R12 Enhanced reservations code changes ***/
         , p_reservation_quantity    => p_to_rsv_rec.reservation_quantity
         , p_reservation_uom_code    => p_to_rsv_rec.reservation_uom_code
         , p_supply_type_id          => p_to_rsv_rec.supply_source_type_id
         , p_demand_ship_date        => p_orig_rsv_rec.demand_ship_date
         , p_supply_receipt_date     => p_orig_rsv_rec.supply_receipt_date  /*** End R12 }} ***/
	 , x_demand_cache_index      => l_to_demand_cache_index
	 );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --

      -- Bug: 4661026: Passing the requirement date if the demand ship date
      -- is null
      IF (p_to_rsv_rec.supply_source_type_id = inv_reservation_global.g_source_type_wip)
	THEN
	 l_demand_ship_date := Nvl(p_to_rsv_rec.demand_ship_date,p_to_rsv_rec.requirement_date);

      END IF;

      validate_supply_source
	(
	   x_return_status           => l_return_status
	 , p_inventory_item_id       => p_to_rsv_rec.inventory_item_id
	 , p_organization_id         => p_to_rsv_rec.organization_id
	 , p_supply_source_type_id   => p_to_rsv_rec.supply_source_type_id
	 , p_supply_source_header_id => p_to_rsv_rec.supply_source_header_id
	 , p_supply_source_line_id   => p_to_rsv_rec.supply_source_line_id
	 , p_supply_source_line_detail  => p_to_rsv_rec.supply_source_line_detail
	 , p_supply_source_name      => p_to_rsv_rec.supply_source_name
         , p_demand_source_type_id   => p_to_rsv_rec.demand_source_type_id
	 , p_revision                => p_to_rsv_rec.revision
	 , p_lot_number              => p_to_rsv_rec.lot_number
	 , p_subinventory_code       => p_to_rsv_rec.subinventory_code
	 , p_locator_id              => p_to_rsv_rec.locator_id
	 , p_serial_array            => p_to_serial_array
         , p_demand_ship_date        => l_demand_ship_date
         , p_supply_receipt_date     => p_to_rsv_rec.supply_receipt_date
	 , p_item_cache_index        => l_to_item_cache_index
	 , p_org_cache_index         => l_to_org_cache_index
	 , x_supply_cache_index      => l_to_supply_cache_index
	 , x_sub_cache_index         => l_to_sub_cache_index
	);

      IF (l_debug = 1) THEN
	 debug_print(' After calling validate supply source ' || l_return_status);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      --
      IF p_to_serial_array.COUNT > 0 THEN
	 l_has_serial_number := fnd_api.g_true;
       ELSE
	 l_has_serial_number := fnd_api.g_false;
      END IF;
      --
      -- INVCONV BEGIN
      -- Extend validations to cover secondary quantity
      validate_quantity
	(
	 x_return_status          => l_return_status
	 , p_primary_uom          => p_to_rsv_rec.primary_uom_code
	 , p_primary_quantity     => p_to_rsv_rec.primary_reservation_quantity
         , p_secondary_uom         => p_to_rsv_rec.secondary_uom_code   -- INVCONV
         , p_secondary_quantity    => p_to_rsv_rec.secondary_reservation_quantity           -- INVCONV
	 , p_reservation_uom       => p_to_rsv_rec.reservation_uom_code
	 , p_reservation_quantity  => p_to_rsv_rec.reservation_quantity
         , p_lot_number            => p_to_rsv_rec.lot_number           -- INVCONV
	 , p_has_serial_number     => l_has_serial_number
         , p_item_cache_index      => l_orig_item_cache_index             -- INVCONV
	 );
      -- INVCONV END

      IF (l_debug = 1) THEN
      debug_print(' After calling validate quantity ' || l_return_status);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;
      --
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_orig_rsv_rec.inventory_item_id
	<> p_to_rsv_rec.inventory_item_id THEN
	 fnd_message.set_name('INV', 'INVENTORY_ITEM_ID_NOT_THE_SAME');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;
      END IF;

      /*** {{ R12 Enhanced reservations code changes ***/
      IF (p_rsv_action_name = 'UPDATE') THEN
          update_crossdock_reservation
            (
               x_return_status => l_return_status
             , x_msg_count     => l_msg_count
             , x_msg_data      => l_msg_data
             , p_orig_rsv_rec  => p_orig_rsv_rec
             , p_to_rsv_rec    => p_to_rsv_rec
            );

           IF (l_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
           ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;

      ELSIF (p_rsv_action_name = 'TRANSFER') THEN
           transfer_crossdock_reservation
             (
               x_return_status => l_return_status
             , x_msg_count     => l_msg_count
             , x_msg_data      => l_msg_data
             , p_orig_rsv_rec  => p_orig_rsv_rec
             , p_to_rsv_rec    => p_to_rsv_rec
            );

	   IF (l_debug = 1) THEN
	      debug_print(' After calling validate cossdock xfer ' ||
			  l_return_status);
	   END IF;
           IF (l_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
           ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;
      END IF;

      validate_pjm_reservations
        (
           x_return_status             => l_return_status
         , p_organization_id           => p_to_rsv_rec.organization_id
	 , p_inventory_item_id         => p_to_rsv_rec.inventory_item_id
         , p_supply_source_type_id     => p_to_rsv_rec.supply_source_type_id
         , p_supply_source_header_id   => p_to_rsv_rec.supply_source_header_id
         , p_supply_source_line_id     => p_to_rsv_rec.supply_source_line_id
         , p_supply_source_line_detail => p_to_rsv_rec.supply_source_line_detail
         , p_project_id                => p_to_rsv_rec.project_id
         , p_task_id                   => p_to_rsv_rec.task_id
        );

      IF (l_debug = 1) THEN
	 debug_print(' After calling validate pjm ' || l_return_status);
      END IF;

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
      ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      validate_serials
        (
           x_return_status                => l_return_status
         , p_orig_rsv_rec                 => p_orig_rsv_rec
         , p_to_rsv_rec                   => p_to_rsv_rec
         , p_orig_serial_array            => p_orig_serial_array
         , p_to_serial_array              => p_to_serial_array
         , p_rsv_action_name              => p_rsv_action_name
        );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
         RAISE fnd_api.g_exc_error;
      ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      /*** End R12 }} ***/

      --
      -- Bug 2025212
      -- With Change Management and the way Shipping calls the INV APIs,
      -- it becomes necessary in certain situations to update quantity
      -- information on reservations against orders that are cancelled.
      -- These reservations will soon be canceled or transferred, but
      -- the quantity update must happen first.
      -- To solve this problem, only validate the sales order on
      -- update or transfer if the sales order info has changed.
      -- This change will also yield performance improvements.

      /*** {{ R12 Enhanced reservations code changes
      -- comment out the call to validate_sales_order
      -- call from validate_demand_source
      IF (p_orig_rsv_rec.demand_source_type_id <>
	  p_to_rsv_rec.demand_source_type_id) OR
         (p_orig_rsv_rec.demand_source_header_id <>
	  p_to_rsv_rec.demand_source_header_id) OR
         (p_orig_rsv_rec.demand_source_line_id <>
	  p_to_rsv_rec.demand_source_line_id)
       THEN

        validate_sales_order
        (
          x_return_status        => l_return_status
	, p_reservation_id	 => p_to_rsv_rec.reservation_id
	, p_demand_type_id	 => p_to_rsv_rec.demand_source_type_id
	, p_demand_header_id	 => p_to_rsv_rec.demand_source_header_id
	, p_demand_line_id	 => p_to_rsv_rec.demand_source_line_id
	, p_reservation_quantity => p_to_rsv_rec.reservation_quantity
	, p_reservation_uom_code => p_to_rsv_rec.reservation_uom_code
	, p_reservation_item_id  => p_to_rsv_rec.inventory_item_id
	, p_reservation_org_id	 => p_to_rsv_rec.organization_id
        );
        IF l_return_status = fnd_api.g_ret_sts_error THEN
      	  RAISE fnd_api.g_exc_error;
        END IF;
        --
        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        --
	END IF;
	*** End R12 }} ***/
	IF (l_debug = 1) THEN
	   debug_print(' Before checking for existing xdock ' ||
		       l_return_status);
	END IF;

	-- check to see if there are existing crossdock reservations against this
	--wip job for a different demand. If so, fail.
	IF (p_to_rsv_rec.supply_source_type_id = INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_WIP) THEN
	   -- Bug 4608452: Get the wip entity type to check for existing reservations
	   /*** Get the wip entity type ***/
	   -- get wip entity id from wip_record_cache
	   inv_reservation_util_pvt.get_wip_cache
	     (
	      x_return_status     => l_return_status
	      , p_wip_entity_id   => p_to_rsv_rec.supply_source_header_id
	      );

	   IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	      RAISE fnd_api.g_exc_error;
	    ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	    ELSE
	      l_wip_entity_type := inv_reservation_global.g_wip_record_cache(p_to_rsv_rec.supply_source_header_id).wip_entity_type;
	      l_wip_job_type := inv_reservation_global.g_wip_record_cache(p_to_rsv_rec.supply_source_header_id).wip_entity_job;
	   END IF;

	   IF (l_wip_entity_type = inv_reservation_global.g_wip_source_type_discrete) THEN
	     BEGIN
		SELECT distinct
		  inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id),
		  wdd.source_line_id INTO l_demand_source_header_id, l_demand_source_line_id
		  FROM mtl_txn_request_lines mtrl, wms_license_plate_numbers wlpn,
		  wsh_delivery_details wdd
		  WHERE mtrl.organization_id = p_to_rsv_rec.organization_id
		  AND mtrl.inventory_item_id = p_to_rsv_rec.inventory_item_id
		  AND mtrl.line_status <> 5 -- not closed move order lines
		  AND NVL(mtrl.quantity_delivered, 0) = 0
		  AND mtrl.txn_source_id = p_to_rsv_rec.supply_source_header_id
		  AND mtrl.lpn_id = wlpn.lpn_id
		  AND wlpn.lpn_context = 2 -- WIP LPN
		  AND mtrl.crossdock_type = 1 -- Crossdocked to OE demand
		  AND mtrl.backorder_delivery_detail_id IS NOT NULL
		    AND mtrl.backorder_delivery_detail_id =
		    wdd.delivery_detail_id;
	     EXCEPTION
		WHEN no_data_found THEN
		   IF (l_debug = 1) THEN
		      debug_print('No records found for this WIP job that has been crossdocked');
		   END IF;
	     END;

	     IF (l_demand_source_header_id <>
		 p_to_rsv_rec.demand_source_header_id) OR
	       (l_demand_source_line_id <>
		p_to_rsv_rec.demand_source_line_id) THEN
		IF (l_debug = 1) THEN
		   debug_print('Job already has a crossdocked reservation for a different demand');
		   debug_print(' Reservations exist for sales order header'
			       || l_demand_source_header_id);
		    debug_print(' Reservations exist for sales order line'
			       || l_demand_source_line_id);
		   fnd_message.set_name('INV', 'INV_INVALID_DEMAND_SOURCE');
		   fnd_msg_pub.add;
		   RAISE fnd_api.g_exc_error;
		END IF;
	     END IF;
	   END IF;
	END IF;
	IF (l_debug = 1) THEN
	   debug_print(' end of update/ transfer ' || l_return_status);
	END IF;
  END IF;
   --

  /*** {{ R12 Enhanced reservations code changes ***/
      IF (p_rsv_action_name = 'RELIEVE') THEN
	 IF (l_debug = 1) THEN
	    debug_print('Inside validate when relieve');
	 END IF;

	 validate_organization
	   (
	    x_return_status   => l_return_status
	    , p_organization_id => p_orig_rsv_rec.organization_id
	    , x_org_cache_index => l_orig_org_cache_index
	    );
	 --
	 IF l_return_status = fnd_api.g_ret_sts_error THEN
	    RAISE fnd_api.g_exc_error;
	 END IF ;
	 --
	 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

	 validate_serials
	   (
	    x_return_status                => l_return_status
	    , p_orig_rsv_rec                 => p_orig_rsv_rec
	    , p_to_rsv_rec                   => p_to_rsv_rec
	    , p_orig_serial_array            => p_orig_serial_array
	    , p_to_serial_array              => p_to_serial_array
	    , p_rsv_action_name              => p_rsv_action_name
	    );

	 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	    RAISE fnd_api.g_exc_error;
	  ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

         /*** for relieve crossdock reservation, call
          --- update_crossdock_reservation instead of relieve
          --- with to reservation record populated
	 relieve_crossdock_reservation
	   (
	    x_return_status => l_return_status
	    , x_msg_count     => l_msg_count
	    , x_msg_data      => l_msg_data
	    , p_rsv_rec       => p_orig_rsv_rec
	    );
         ****/

         update_crossdock_reservation
           (
              x_return_status => l_return_status
            , x_msg_count     => l_msg_count
            , x_msg_data      => l_msg_data
            , p_orig_rsv_rec  => p_orig_rsv_rec
            , p_to_rsv_rec    => p_to_rsv_rec
           );

	 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	    RAISE fnd_api.g_exc_error;
	  ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
      END IF;
      /*** End R12 }} ***/

      /*** {{ R12 Enhanced reservations code changes ***/
      IF (p_rsv_action_name = 'DELETE') THEN

	 validate_organization
	   (
	    x_return_status   => l_return_status
	    , p_organization_id => p_orig_rsv_rec.organization_id
	    , x_org_cache_index => l_orig_org_cache_index
	    );
	 --
	 IF l_return_status = fnd_api.g_ret_sts_error THEN
	    RAISE fnd_api.g_exc_error;
	 END IF ;
	 --
	 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

	 validate_serials
	   (
	    x_return_status                => l_return_status
	    , p_orig_rsv_rec                 => p_orig_rsv_rec
	    , p_to_rsv_rec                   => p_to_rsv_rec
	    , p_orig_serial_array            => p_orig_serial_array
	    , p_to_serial_array              => p_to_serial_array
	    , p_rsv_action_name              => p_rsv_action_name
	    );

	 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	    RAISE fnd_api.g_exc_error;
	  ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

	 delete_crossdock_reservation
	   (
	    x_return_status => l_return_status
	    , x_msg_count     => l_msg_count
	    , x_msg_data      => l_msg_data
	    , p_rsv_rec       => p_orig_rsv_rec
	    );

	 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	    RAISE fnd_api.g_exc_error;
	  ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
      END IF;
      /*** End R12 }} ***/
      IF (l_debug = 1) THEN
	 debug_print(' end validate input  ' || l_return_status);
      END IF;
  x_orig_item_cache_index   := l_orig_item_cache_index;
  x_orig_org_cache_index    := l_orig_org_cache_index;
  x_orig_demand_cache_index := l_orig_demand_cache_index;
  x_orig_supply_cache_index := l_orig_supply_cache_index;
  x_orig_sub_cache_index    := l_orig_sub_cache_index;
  x_to_item_cache_index     := l_to_item_cache_index;
  x_to_org_cache_index      := l_to_org_cache_index;
  x_to_demand_cache_index   := l_to_demand_cache_index;
  x_to_supply_cache_index   := l_to_supply_cache_index;
  x_to_sub_cache_index      := l_to_sub_cache_index;
  --
  x_return_status := l_return_status;
  --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
   --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
   --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Validate_Input_Parameters'
              );
      END IF;
      --
END validate_input_parameters;
END inv_reservation_validate_pvt;

/
