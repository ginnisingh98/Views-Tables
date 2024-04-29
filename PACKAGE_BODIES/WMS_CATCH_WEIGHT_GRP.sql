--------------------------------------------------------
--  DDL for Package Body WMS_CATCH_WEIGHT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CATCH_WEIGHT_GRP" AS
/* $Header: WMSGCWTB.pls 115.7 2004/04/08 23:53:17 jsheu noship $ */

--  Global constant holding the package name
g_pkg_name    CONSTANT VARCHAR2(30)  := 'WMS_CATCH_WEIGHT_GRP';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSGCWTB.pls 115.7 2004/04/08 23:53:17 jsheu noship $';

g_precision   CONSTANT NUMBER := 5;

PROCEDURE print_debug( p_message VARCHAR2, p_level NUMBER ) IS
BEGIN
  --dbms_output.put_line(p_message);
  inv_log_util.trace(
    p_message => p_message
  , p_module  => g_pkg_name
  , p_level   => p_level);
END print_debug;

FUNCTION Get_Default_Secondary_Quantity (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_inventory_item_id      IN         NUMBER
, p_quantity               IN         NUMBER
, p_uom_code               IN         VARCHAR2
, x_secondary_quantity     OUT NOCOPY NUMBER
, x_secondary_uom_code     OUT NOCOPY VARCHAR2
) RETURN VARCHAR2 IS
l_api_name    CONSTANT VARCHAR2(30) := 'Get_Default_Secondary_Quantity';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(500) := '0';
l_msgdata              VARCHAR2(1000);

-- Variables for validation
l_result                 NUMBER;
l_org                    inv_validate.org;
l_item                   inv_validate.item;

-- Variables for processing
l_tracking_quantity_ind  VARCHAR2(30);
l_ont_pricing_qty_source VARCHAR2(30);
l_secondary_default_ind  VARCHAR2(30);
l_secondary_quantity     NUMBER;
l_secondary_uom_code     VARCHAR2(3);
l_uom_deviation_high     NUMBER;
l_uom_deviation_low      NUMBER;

BEGIN
  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
  END IF;

  IF ( p_validation_level <> fnd_api.g_valid_level_none ) THEN
    l_progress := 'Validate Organization ID';
    l_org.organization_id  := p_organization_id;
    l_result               := inv_validate.ORGANIZATION(l_org);

    IF ( l_result = inv_validate.f ) THEN
      IF ( l_debug = 1 ) THEN
        print_debug(p_organization_id || ' is not a valid org id', 1);
      END IF;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress := 'Validate Inventory Item ID';
    l_item.inventory_item_id  := p_inventory_item_id;
    l_result                  := inv_validate.inventory_item(l_item, l_org);

    IF ( l_result = inv_validate.f ) THEN
      IF (l_debug = 1) THEN
        print_debug(p_inventory_item_id || ' is not a valid inventory item id', 1);
      END IF;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress := 'Validate Quantity';
    IF ( p_quantity < 0 ) THEN
      IF (l_debug = 1) THEN
        print_debug(p_quantity ||' is not a valid quantity', 1);
      END IF;
      fnd_message.set_name('WMS', 'WMS_INVALID_QTY');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress := 'Validate UOM code';
    l_result  := inv_validate.uom(p_uom_code, l_org, l_item);

    IF ( l_result = inv_validate.f ) THEN
      IF ( l_debug = 1 ) THEN
        print_debug(p_uom_code || ' is an invalid UOM', 1);
      END IF;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_UOM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  WMS_CATCH_WEIGHT_PVT.Get_Catch_Weight_Attributes (
    p_api_version            => 1.0
  , x_return_status          => x_return_status
  , x_msg_count              => x_msg_count
  , x_msg_data               => x_msg_data
  , p_organization_id        => p_organization_id
  , p_inventory_item_id      => p_inventory_item_id
  , x_tracking_quantity_ind  => l_tracking_quantity_ind
  , x_ont_pricing_qty_source => l_ont_pricing_qty_source
  , x_secondary_default_ind  => l_secondary_default_ind
  , x_secondary_quantity     => l_secondary_quantity
  , x_secondary_uom_code     => x_secondary_uom_code
  , x_uom_deviation_high     => l_uom_deviation_high
  , x_uom_deviation_low      => l_uom_deviation_low );

  IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
    IF ( l_debug = 1 ) THEN
      print_debug('Call to Get_Catch_Weight_Attributes failed', 1);
    END IF;
    IF ( x_return_status = fnd_api.g_ret_sts_error ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  l_progress := 'Got CW attributes';
  -- If item is secondary priced and is not default restricted calculate the default
  -- secondary value based off the secondary uom.
  IF ( l_ont_pricing_qty_source = G_PRICE_SECONDARY ) THEN
    IF ( x_secondary_uom_code IS NULL ) THEN
      IF (l_debug = 1) THEN
        print_debug('Secondary UOM is not defined for this secondary priced item', 1);
      END IF;
      fnd_message.set_name('WMS', 'WMS_SEC_UOM_UNDEF_ERROR');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_progress := 'Converting secondary qty';
    x_secondary_quantity := inv_convert.inv_um_convert(
                              p_inventory_item_id
                            , g_precision
                            , p_quantity
                            , p_uom_code
                            , x_secondary_uom_code
                            , NULL
                            , NULL );
    IF ( x_secondary_quantity < 0 ) THEN
      IF ( l_debug = 1 ) THEN
        print_debug('Error converting to from '||p_uom_code||' to '||x_secondary_uom_code, 1);
      END IF;
      fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
      fnd_message.set_token('uom1', p_uom_code);
      fnd_message.set_token('uom2', x_secondary_uom_code);
      fnd_message.set_token('module', l_api_name);
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_progress := 'Done converting secondary qty';
  ELSE
    x_secondary_quantity := NULL;
    x_secondary_uom_code := NULL;
  END IF;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Exited ret='||l_ont_pricing_qty_source, 1);
    print_debug('secqty='||x_secondary_quantity||' secuom='||x_secondary_uom_code, 4);
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  RETURN l_ont_pricing_qty_source;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      print_debug(l_api_name ||' Error progress= '||l_progress||'SQL error: '|| SQLERRM(SQLCODE), 1);
      print_debug('msg: '||l_msgdata, 1);
    END IF;
    RETURN NULL;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Error progress= '||l_progress||'SQL error: '|| SQLERRM(SQLCODE), 1);
    END IF;
    RETURN NULL;
END Get_Default_Secondary_Quantity;

END WMS_CATCH_WEIGHT_GRP;

/
