--------------------------------------------------------
--  DDL for Package Body WMS_CATCH_WEIGHT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CATCH_WEIGHT_PVT" AS
/* $Header: WMSVCWTB.pls 120.4.12010000.3 2010/01/05 11:18:53 kkesavar ship $ */

--  Global constant holding the package name
g_pkg_name CONSTANT VARCHAR2(30) := 'WMS_CATCH_WEIGHT_PVT';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSVCWTB.pls 120.4.12010000.3 2010/01/05 11:18:53 kkesavar ship $';

g_precision CONSTANT NUMBER := 5;

PROCEDURE print_debug( p_message VARCHAR2, p_level NUMBER ) IS
BEGIN
  --dbms_output.put_line(p_message);
  inv_log_util.trace(
    p_message => p_message
  , p_module  => g_pkg_name
  , p_level   => p_level);
END print_debug;

PROCEDURE Get_Catch_Weight_Attributes (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_inventory_item_id      IN         NUMBER
, p_quantity               IN         NUMBER   := NULL
, p_uom_code               IN         VARCHAR2 := NULL
, x_tracking_quantity_ind  OUT NOCOPY VARCHAR2
, x_ont_pricing_qty_source OUT NOCOPY VARCHAR2
, x_secondary_default_ind  OUT NOCOPY VARCHAR2
, x_secondary_quantity     OUT NOCOPY NUMBER
, x_secondary_uom_code     OUT NOCOPY VARCHAR2
, x_uom_deviation_high     OUT NOCOPY NUMBER
, x_uom_deviation_low      OUT NOCOPY NUMBER
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Get_Catch_Weight_Attributes';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

l_wms_org_flag         BOOLEAN;
l_secondary_uom_code   VARCHAR2(3);
l_result               VARCHAR2(30);
BEGIN
  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
    print_debug('orgid='||p_organization_id||' itemid='||p_inventory_item_id||' qty='||p_quantity||' uom='||p_uom_code, 4);
  END IF;

  -- Check if the organization is a WMS organization
  l_wms_org_flag := wms_install.check_install (
                      x_return_status   => x_return_status
                    , x_msg_count       => x_msg_count
                    , x_msg_data        => x_msg_data
                    , p_organization_id => p_organization_id );
  IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
    IF ( l_debug = 1 ) THEN
      print_debug('Call to wms_install.check_install failed:' ||x_msg_data, 1);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '100';
  IF ( l_wms_org_flag ) THEN
  	l_progress := '200';
    SELECT NVL(tracking_quantity_ind, G_TRACK_PRIMARY),
           NVL(ont_pricing_qty_source, G_PRICE_PRIMARY),
           secondary_default_ind,
           secondary_uom_code,
           dual_uom_deviation_high,
           dual_uom_deviation_low
    INTO   x_tracking_quantity_ind,
           x_ont_pricing_qty_source,
           x_secondary_default_ind,
           x_secondary_uom_code,
           x_uom_deviation_high,
           x_uom_deviation_low
    FROM   MTL_SYSTEM_ITEMS
    WHERE  organization_id = p_organization_id
    AND    inventory_item_id = p_inventory_item_id;

    l_progress := '300';
    IF ( p_quantity IS NOT NULL ) THEN
      Get_Default_Secondary_Quantity (
        p_api_version            => 1.0
      , x_return_status          => x_return_status
      , x_msg_count              => x_msg_count
      , x_msg_data               => x_msg_data
      , p_organization_id        => p_organization_id
      , p_inventory_item_id      => p_inventory_item_id
      , p_quantity               => p_quantity
      , p_uom_code               => p_uom_code
      , p_secondary_default_ind  => x_secondary_default_ind
      , x_ont_pricing_qty_source => x_ont_pricing_qty_source
      , x_secondary_uom_code     => x_secondary_uom_code
      , x_secondary_quantity     => x_secondary_quantity);

      IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
        IF ( l_debug = 1 ) THEN
          print_debug('Call to Get_Default_Secondary_Quantity failed', 1);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  ELSE -- not a wms org
  	IF ( l_debug = 1 ) THEN
      print_debug('Not a WMS org return default values', 4);
    END IF;
    x_tracking_quantity_ind  := G_TRACK_PRIMARY;
    x_ont_pricing_qty_source := G_PRICE_PRIMARY;
    x_secondary_default_ind  := NULL;
    x_secondary_quantity     := NULL;
    x_secondary_uom_code     := NULL;
    x_uom_deviation_high     := NULL;
    x_uom_deviation_low      := NULL;
  END IF;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Exited ', 1);
    print_debug('track_ind='||x_tracking_quantity_ind||' pricesrc='||x_ont_pricing_qty_source||' defaultind='||x_secondary_default_ind , 4);
    print_debug('secqty='||x_secondary_quantity||' secuom='||x_secondary_uom_code||' devhigh='||x_uom_deviation_high||' devlow='||x_uom_deviation_low, 4);
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_GET_CWT_ATTR_FAIL');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Get_Catch_Weight_Attributes;


FUNCTION Get_Ont_Pricing_Qty_Source (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_inventory_item_id      IN         NUMBER
) RETURN VARCHAR2 IS
l_api_name    CONSTANT VARCHAR2(30) := 'Get_Ont_Pricing_Qty_Source';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

l_wms_org_flag           BOOLEAN;
l_ont_pricing_qty_source VARCHAR(30);
BEGIN
  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
    print_debug('orgid='||p_organization_id||' itemid='||p_inventory_item_id, 4);
  END IF;

  -- Check if the organization is a WMS organization
  l_wms_org_flag := wms_install.check_install (
                      x_return_status   => x_return_status
                    , x_msg_count       => x_msg_count
                    , x_msg_data        => x_msg_data
                    , p_organization_id => p_organization_id );
  IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
    IF ( l_debug = 1 ) THEN
      print_debug('Call to wms_install.check_install failed:' ||x_msg_data, 1);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ( l_wms_org_flag ) THEN
    SELECT NVL(ont_pricing_qty_source, G_PRICE_PRIMARY)
    INTO   l_ont_pricing_qty_source
    FROM   MTL_SYSTEM_ITEMS
    WHERE  organization_id = p_organization_id
    AND    inventory_item_id = p_inventory_item_id;
  ELSE -- not a wms org
  	IF ( l_debug = 1 ) THEN
      print_debug('Not a WMS org return default value', 4);
    END IF;
    l_ont_pricing_qty_source := G_PRICE_PRIMARY;
  END IF;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name||' Exited '||'ret='||l_ont_pricing_qty_source, 1);
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  RETURN l_ont_pricing_qty_source;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;

    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_API_FAIL');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Get_Ont_Pricing_Qty_Source;


PROCEDURE Get_Default_Secondary_Quantity (
  p_api_version            IN            NUMBER
, p_init_msg_list          IN            VARCHAR2 := fnd_api.g_false
, x_return_status          OUT    NOCOPY VARCHAR2
, x_msg_count              OUT    NOCOPY NUMBER
, x_msg_data               OUT    NOCOPY VARCHAR2
, p_organization_id        IN            NUMBER
, p_inventory_item_id      IN            NUMBER
, p_quantity               IN            NUMBER
, p_uom_code               IN            VARCHAR2
, p_secondary_default_ind  IN            VARCHAR2 := NULL
, x_ont_pricing_qty_source IN OUT NOCOPY VARCHAR2
, x_secondary_uom_code     IN OUT NOCOPY VARCHAR2
, x_secondary_quantity     OUT    NOCOPY NUMBER
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Get_Default_Secondary_Quantity';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

l_wms_org_flag  BOOLEAN;
l_default_ind   VARCHAR(30);
l_uom_code      VARCHAR(3);
l_secondary_uom VARCHAR(3);
BEGIN
  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
    print_debug('orgid='||p_organization_id||' itemid='||p_inventory_item_id||' qty='||p_quantity||' uom='||p_uom_code, 4);
    print_debug('pricesrc='||x_ont_pricing_qty_source||' defaultind='||p_secondary_default_ind||' secuom='||x_secondary_uom_code, 4);
  END IF;

  l_progress := '000';
  IF ( x_secondary_uom_code IS NULL OR x_ont_pricing_qty_source IS NULL OR
       p_secondary_default_ind IS NULL OR p_uom_code IS NULL ) THEN
    -- Check if the organization is a WMS organization
    l_wms_org_flag := wms_install.check_install (
                        x_return_status   => x_return_status
                      , x_msg_count       => x_msg_count
                      , x_msg_data        => x_msg_data
                      , p_organization_id => p_organization_id );
    IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
      IF ( l_debug = 1 ) THEN
        print_debug('Call to wms_install.check_install failed:' ||x_msg_data, 1);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF ( l_wms_org_flag ) THEN
      SELECT ont_pricing_qty_source,
             secondary_default_ind,
             primary_uom_code,
             secondary_uom_code
        INTO x_ont_pricing_qty_source,
             l_default_ind,
             l_uom_code,
             x_secondary_uom_code
        FROM mtl_system_items
       WHERE organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id;
    ELSE -- not a wms org
  	  IF ( l_debug = 1 ) THEN
        print_debug('Not a WMS org return default value', 4);
      END IF;
      x_ont_pricing_qty_source := G_PRICE_PRIMARY;
      l_default_ind            := NULL;
      l_uom_code               := NULL;
      x_secondary_uom_code     := NULL;
    END IF;
  ELSE -- Use the values given by user to calculate the defaults
    l_default_ind := p_secondary_default_ind;
  END IF;

  l_progress := '100';
  -- If item is secondary priced and is not default restricted calculate the default
  -- secondary value based off the secondary uom.
  IF ( x_ont_pricing_qty_source = G_PRICE_SECONDARY AND
       l_default_ind <> G_SECONDARY_NO_DEFAULT ) THEN
    l_progress := '200';
    IF ( x_secondary_uom_code IS NULL ) THEN
      IF (l_debug = 1) THEN
        print_debug('Secondary UOM is not defined for this secondary priced item', 1);
      END IF;
      fnd_message.set_name('WMS', 'WMS_SEC_UOM_UNDEF_ERROR');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Use user specified uom if passed
    IF ( p_uom_code IS NOT NULL ) THEN
      l_uom_code := p_uom_code;
    END IF;

    l_progress := '300';
    x_secondary_quantity := inv_convert.inv_um_convert(
                              p_inventory_item_id
                            , g_precision
                            , p_quantity
                            , l_uom_code
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
    l_progress := '400';
  ELSE
    x_secondary_quantity := NULL;
  END IF;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name||' Exited '||' priceind=' ||x_ont_pricing_qty_source, 1);
    print_debug('secqty='||x_secondary_quantity||' secuom='||x_secondary_uom_code, 4);
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;

    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_CALC_SEC_QTY_FAIL');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Get_Default_Secondary_Quantity;


FUNCTION Check_Secondary_Qty_Tolerance (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_inventory_item_id      IN         NUMBER
, p_quantity               IN         NUMBER
, p_uom_code               IN         VARCHAR2
, p_secondary_quantity     IN         NUMBER
, p_secondary_uom_code     IN         VARCHAR2 := NULL
, p_ont_pricing_qty_source IN         VARCHAR2 := NULL
, p_uom_deviation_high     IN         NUMBER   := NULL
, p_uom_deviation_low      IN         NUMBER   := NULL
) RETURN NUMBER IS
l_api_name    CONSTANT VARCHAR2(30) := 'Check_Secondary_Qty_Tolerance';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

l_tracking_quantity_ind  VARCHAR2(30);
l_ont_pricing_qty_source VARCHAR2(30);
l_secondary_default_ind  VARCHAR2(30);
l_secondary_quantity     NUMBER;
l_secondary_uom_code     VARCHAR2(3);
l_uom_deviation_high     NUMBER;
l_uom_deviation_low      NUMBER;
l_upper_qty_limit        NUMBER;
l_lower_qty_limit        NUMBER;
l_return                 NUMBER := 0;
l_uom_code               VARCHAR2(3) := p_uom_code;
l_converted_qty          NUMBER;
BEGIN
  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
    print_debug('orgid='||p_organization_id||' itemid='||p_inventory_item_id||' qty='||p_quantity||' uom='||p_uom_code||' secqty='||p_secondary_quantity, 4);
    print_debug('pricesrc='||p_ont_pricing_qty_source||' secuom='||p_secondary_uom_code||' devhigh='||p_uom_deviation_high||' devlow='||p_uom_deviation_low, 4);
  END IF;

  IF ( p_secondary_uom_code IS NULL OR p_ont_pricing_qty_source IS NULL OR
       p_uom_deviation_high IS NULL OR p_uom_deviation_low IS NULL ) THEN
    Get_Catch_Weight_Attributes (
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
    , x_secondary_uom_code     => l_secondary_uom_code
    , x_uom_deviation_high     => l_uom_deviation_high
    , x_uom_deviation_low      => l_uom_deviation_low );
  ELSE
    l_ont_pricing_qty_source := p_ont_pricing_qty_source;
    l_secondary_uom_code     := p_secondary_uom_code;
    l_uom_deviation_high     := p_uom_deviation_high;
    l_uom_deviation_low      := p_uom_deviation_low;
  END IF;

  IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
    IF ( l_debug = 1 ) THEN
      print_debug('Call to Get_Catch_Weight_Attributes failed', 1);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '100';
  IF ( l_ont_pricing_qty_source = G_PRICE_SECONDARY AND
       (l_uom_deviation_high IS NOT NULL OR l_uom_deviation_low IS NOT NULL) ) THEN
    l_progress := '200';
    l_converted_qty := inv_convert.inv_um_convert(
                                  p_inventory_item_id
                                , 6
                                , p_quantity
                                , l_uom_code
                                , l_secondary_uom_code
                                , NULL
                                , NULL );
    IF ( l_converted_qty < 0 ) THEN
      IF ( l_debug = 1 ) THEN
        print_debug('Error converting qty from '||l_uom_code||' to '||l_secondary_uom_code, 1);
      END IF;
      fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
      fnd_message.set_token('uom1', l_uom_code);
      fnd_message.set_token('uom2', l_secondary_uom_code);
      fnd_message.set_token('module', l_api_name);
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( l_uom_deviation_high IS NOT NULL ) THEN
      l_progress := '300';
      --l_upper_qty_limit := p_quantity converted into catch weight uom* 1+DEVIATION_HIGH/100
      l_upper_qty_limit := round(l_converted_qty*(1+(l_uom_deviation_high/100)), g_precision);

      IF ( round(p_secondary_quantity, g_precision) > l_upper_qty_limit ) THEN
        l_return := 1;
      END IF;
    END IF;

    IF ( l_return = 0 AND l_uom_deviation_low IS NOT NULL ) THEN
      l_progress := '400';
      --l_lower_qty_limit := p_quantity converted into catch weight uom* 1-DEVIATION_LOW/100
      l_lower_qty_limit := round(l_converted_qty*(1-(l_uom_deviation_low/100)), g_precision);

      IF ( round(p_secondary_quantity, g_precision) < l_lower_qty_limit ) THEN
        l_return := -1;
      END IF;
    END IF;
    l_progress := '500';
  END IF;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name||' Exited '||' ret=' ||l_return, 1);
    print_debug('uplim='||l_upper_qty_limit||' lowlim'||l_lower_qty_limit, 4);
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  RETURN l_return;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;

    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_API_FAIL');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Check_Secondary_Qty_Tolerance;


PROCEDURE Update_Shipping_Secondary_Qty (
  p_api_version        IN         NUMBER
, p_init_msg_list      IN         VARCHAR2
, p_commit             IN         VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_delivery_detail_id IN         NUMBER
, p_secondary_quantity IN         NUMBER
, p_secondary_uom_code IN         VARCHAR2 := NULL
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Update_Shipping_Secondary_Qty';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

l_shipping_attr      WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
l_shipping_in_rec    WSH_INTERFACE_EXT_GRP.detailInRecType;
l_shipping_out_rec   WSH_INTERFACE_EXT_GRP.detailOutRecType;

l_msg_details            VARCHAR2(3000);
l_pricing_ind            VARCHAR2(30);
l_tolerance              NUMBER;
l_organization_id        NUMBER;
l_inventory_item_id      NUMBER;
l_primary_uom_code       VARCHAR2(3) := NULL;
l_picked_quantity        NUMBER;
l_requested_quantity_uom VARCHAR2(3);
l_secondary_quantity     NUMBER;
l_secondary_uom_code     VARCHAR(3);

BEGIN
  SAVEPOINT UPDATE_SHIPPING_SECONDARY_QTY;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
    print_debug('deldetid='||p_delivery_detail_id||' secqty='||p_secondary_quantity||' secuom='||p_secondary_uom_code, 4);
  END IF;

  BEGIN
    SELECT organization_id, inventory_item_id, picked_quantity, requested_quantity_uom
      INTO l_organization_id, l_inventory_item_id, l_picked_quantity, l_requested_quantity_uom
      FROM wsh_delivery_details
     WHERE delivery_detail_id = p_delivery_detail_id;

    IF ( l_debug = 1 ) THEN
      print_debug('got from WDD orgid='||l_organization_id||' itemid='||l_inventory_item_id||' pkdqty='||l_picked_quantity||' requom='||l_requested_quantity_uom, 4);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WMS', 'WMS_MISSING_WDD_ERR');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  Get_Default_Secondary_Quantity (
    p_api_version            => 1.0
  , x_return_status          => x_return_status
  , x_msg_count              => x_msg_count
  , x_msg_data               => x_msg_data
  , p_organization_id        => l_organization_id
  , p_inventory_item_id      => l_inventory_item_id
  , p_quantity               => l_picked_quantity
  , p_uom_code               => l_requested_quantity_uom
  , x_ont_pricing_qty_source => l_pricing_ind
  , x_secondary_uom_code     => l_secondary_uom_code
  , x_secondary_quantity     => l_secondary_quantity); -- 8655538

  IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
    IF ( l_debug = 1 ) THEN
      print_debug('Call to Get_Default_Secondary_Quantity failed', 1);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ( l_pricing_ind = G_PRICE_SECONDARY ) THEN
    l_progress := '100';
    -- Item is catch weight enabled.
    IF ( l_secondary_uom_code <> p_secondary_uom_code ) THEN
      fnd_message.set_name('WMS', 'WMS_SEC_UOM_MISMATCH');
      fnd_message.set_token('uom1', p_secondary_uom_code);
      fnd_message.set_token('uom2', l_secondary_uom_code);
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF ( p_secondary_quantity = FND_API.G_MISS_NUM ) THEN
      l_progress := '200';

      -- User wishes to set secondary values to null
      l_secondary_quantity := FND_API.G_MISS_NUM;
      l_secondary_uom_code := FND_API.G_MISS_CHAR;
    ELSIF ( p_secondary_quantity IS NOT NULL ) THEN
      l_progress := '300';

      -- Check to make sure that the secondary qty is within tolerance
      l_tolerance := Check_Secondary_Qty_Tolerance (
                       p_api_version        => 1.0
                     , x_return_status      => x_return_status
                     , x_msg_count          => x_msg_count
                     , x_msg_data           => x_msg_data
                     , p_organization_id    => l_organization_id
                     , p_inventory_item_id  => l_inventory_item_id
                     , p_quantity           => l_picked_quantity
                     , p_uom_code           => l_requested_quantity_uom
                     , p_secondary_quantity => p_secondary_quantity );

      IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
        IF ( l_debug = 1 ) THEN
          print_debug('Check_Secondary_Qty_Tolerance failed ', 4);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_progress := '400';
      IF ( l_tolerance <> 0 ) THEN
        IF ( l_debug = 1 ) THEN
          print_debug('Secondary quantity out of tolerance', 4);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CTWT_TOLERANCE_ERROR');
        fnd_msg_pub.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- User specified sec qty, do not need to use the default value.
      l_secondary_quantity := p_secondary_quantity;
    ELSIF ( l_secondary_quantity IS NULL ) THEN
      -- cannot defualt secondary quantity error out
      IF ( l_debug = 1 ) THEN
        print_debug('Cannot default secondary quantity', 4);
      END IF;
       fnd_message.set_name('WMS','WMS_CTWT_DEFAULT_ERROR');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- If everything checks out, update wdd.picked_quantity2 with catch weight.
    l_shipping_attr(1).delivery_detail_id := p_delivery_detail_id;
    l_shipping_attr(1).picked_quantity2   := round(l_secondary_quantity, g_precision);
    l_shipping_attr(1).requested_quantity_uom2 := l_secondary_uom_code;

    l_shipping_in_rec.caller := 'WMS';
    l_shipping_in_rec.action_code := 'UPDATE';

    WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail (
      p_api_version_number => 1.0
    , p_init_msg_list      => fnd_api.g_false
    , p_commit             => fnd_api.g_false
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    , p_detail_info_tab    => l_shipping_attr
    , p_IN_rec             => l_shipping_in_rec
    , x_OUT_rec            => l_shipping_out_rec );

    IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
      --Get error messages from shipping
      WSH_UTIL_CORE.get_messages('Y', x_msg_data, l_msg_details, x_msg_count);
      IF x_msg_count > 1 then
        x_msg_data := x_msg_data || l_msg_details;
      ELSE
        x_msg_data := x_msg_data;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Error calling Create_Update_Delivery_Detail: '||x_msg_data, 9);
      END IF;
      FND_MESSAGE.SET_NAME('WMS','WMS_UPD_DELIVERY_ERROR' );
      fnd_message.set_token('MSG1', x_msg_data);
      FND_MSG_PUB.ADD;
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_progress := '400';
  END IF;

  -- End of API body
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Exited ', 1);
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;

    ROLLBACK TO UPDATE_SHIPPING_SECONDARY_QTY;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Update_Shipping_Secondary_Qty;


PROCEDURE Update_Parent_Delivery_Sec_Qty (
  p_api_version        IN         NUMBER
, p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
, p_commit             IN         VARCHAR2 := fnd_api.g_false
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_organization_id    IN         NUMBER
, p_parent_del_det_id  IN         NUMBER
, p_inventory_item_id  IN         NUMBER
, p_revision           IN         VARCHAR2 := NULL
, p_lot_number         IN         VARCHAR2 := NULL
, p_quantity           IN         NUMBER
, p_uom_code           IN         VARCHAR2
, p_secondary_quantity IN         NUMBER
, p_secondary_uom_code IN         VARCHAR2
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Update_Parent_Delivery_Sec_Qty';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

CURSOR wdd_cur IS
  SELECT wdd.delivery_detail_id, wdd.picked_quantity, wdd.requested_quantity_uom,
         wdd.picked_quantity2, wdd.requested_quantity_uom2
    FROM wsh_delivery_assignments_v wda, wsh_delivery_details wdd
   WHERE wda.parent_delivery_detail_id = p_parent_del_det_id
     AND wdd.delivery_detail_id = wda.delivery_detail_id
     AND wdd.organization_id = p_organization_id
     AND wdd.inventory_item_id = p_inventory_item_id
     AND NVL(wdd.revision, '@') = NVL(p_revision, '@')
     AND NVL(wdd.lot_number, '@') = NVL(p_lot_number, '@');

l_shipping_attr    WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
l_shipping_in_rec  WSH_INTERFACE_EXT_GRP.detailInRecType;
l_shipping_out_rec WSH_INTERFACE_EXT_GRP.detailOutRecType;
l_msg_details      VARCHAR2(3000);
l_attr_counter     NUMBER := 1;
l_del_det_id       NUMBER;
l_line_quantity    NUMBER;
l_total_quantity   NUMBER := 0;

BEGIN
  SAVEPOINT UPDATE_PARENT_DELIVERY_SEC_QTY;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
    print_debug('orgid='||p_organization_id||' parddid='||p_parent_del_det_id||' itemid='||p_inventory_item_id||' rev='||p_revision||' lot='||p_lot_number, 4);
    print_debug('qty='||p_quantity||' uom='||p_uom_code||' secqty='||p_secondary_quantity||' secuom='||p_secondary_uom_code, 4);
  END IF;

  --Updating WDD with secondary quantity information
  FOR wdd_rec IN wdd_cur LOOP
    IF ( l_debug = 1 ) THEN
      print_debug('Got from WDD deldetid='||wdd_rec.delivery_detail_id||' pkqty='||wdd_rec.picked_quantity||' requom='||wdd_rec.requested_quantity_uom, 4);
      print_debug('pkqty2='||wdd_rec.picked_quantity2||' requom2='||wdd_rec.requested_quantity_uom2, 4);
    END IF;
    IF ( p_secondary_quantity IS NULL ) THEN
      -- Caller wants to null out all secondary_quantity for item/lot
      -- but only if they are not already null
      IF ( wdd_rec.picked_quantity2 IS NOT NULL OR
           wdd_rec.requested_quantity_uom2 IS NOT NULL ) THEN
        l_shipping_attr(l_attr_counter).delivery_detail_id := wdd_rec.delivery_detail_id;
        l_shipping_attr(l_attr_counter).picked_quantity2        := FND_API.G_MISS_NUM;
        l_shipping_attr(l_attr_counter).requested_quantity_uom2 := FND_API.G_MISS_CHAR;
        l_attr_counter := l_attr_counter + 1;
      END IF;
    ELSE
      IF ( wdd_rec.requested_quantity_uom <> p_uom_code ) THEN
        l_line_quantity := inv_convert.inv_um_convert(
                              p_inventory_item_id
                            , 6
                            , wdd_rec.picked_quantity
                            , wdd_rec.requested_quantity_uom
                            , p_uom_code
                            , NULL
                            , NULL );
        IF ( l_line_quantity < 0 ) THEN
          IF (l_debug = 1) THEN
            print_debug('Error converting to picked qty from '||wdd_rec.requested_quantity_uom||' to '||p_uom_code, 1);
          END IF;
          fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
          fnd_message.set_token('uom1', wdd_rec.requested_quantity_uom);
          fnd_message.set_token('uom2', p_uom_code);
          fnd_message.set_token('module', l_api_name);
          fnd_msg_pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        l_line_quantity := wdd_rec.picked_quantity;
      END IF;

      l_shipping_attr(l_attr_counter).delivery_detail_id := wdd_rec.delivery_detail_id;
      l_shipping_attr(l_attr_counter).picked_quantity2 := round(p_secondary_quantity*(l_line_quantity/p_quantity), g_precision);
      l_shipping_attr(l_attr_counter).requested_quantity_uom2 := p_secondary_uom_code;
      l_attr_counter := l_attr_counter + 1;

      l_total_quantity := l_total_quantity + l_line_quantity;
    END IF;
  END LOOP;

  l_progress := '100';
  -- Do sanity check to make sure the correct qty of items is being updated before callin shipping api
  IF ( p_secondary_quantity IS NOT NULL AND round(p_quantity, g_precision) <> round(l_total_quantity, g_precision) ) THEN
    IF (l_debug = 1) THEN
      print_debug('p_quantity '||p_quantity||' does not match the sum quantity '||l_total_quantity, 9);
    END IF;
    FND_MESSAGE.SET_NAME('WMS','WMS_QTY_UPD_MISMATCH_ERR');
    FND_MESSAGE.SET_TOKEN('QTY1', p_quantity);
    FND_MESSAGE.SET_TOKEN('QTY2', l_total_quantity);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_progress := '200';

  IF ( l_shipping_attr.count > 0 ) THEN
    l_shipping_in_rec.caller := 'WMS';
    l_shipping_in_rec.action_code := 'UPDATE';

    IF (l_debug = 1) THEN
      print_debug('Calling Create_Update_Delivery_Detail count='||l_shipping_attr.count, 9);
    END IF;

    WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail (
      p_api_version_number => 1.0
    , p_init_msg_list      => fnd_api.g_false
    , p_commit             => fnd_api.g_false
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    , p_detail_info_tab    => l_shipping_attr
    , p_IN_rec             => l_shipping_in_rec
    , x_OUT_rec            => l_shipping_out_rec );

    IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
      --Get error messages from shipping
      WSH_UTIL_CORE.get_messages('Y', x_msg_data, l_msg_details, x_msg_count);
      IF x_msg_count > 1 then
        x_msg_data := x_msg_data || l_msg_details;
      ELSE
        x_msg_data := x_msg_data;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Error calling Create_Update_Delivery_Detail: '||x_msg_data, 9);
      END IF;
      FND_MESSAGE.SET_NAME('WMS','WMS_UPD_DELIVERY_ERROR' );
      fnd_message.set_token('MSG1', x_msg_data);
      FND_MSG_PUB.ADD;
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
  END IF;

  l_progress := '300';
  -- End of API body
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  IF ( l_debug = 1 ) THEN
    print_debug( l_api_name || ' Exited ', 1);
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;

    ROLLBACK TO UPDATE_PARENT_DELIVERY_SEC_QTY;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_API_FAIL');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Update_Parent_Delivery_Sec_Qty;

--
--  Procedure:          Update_Delivery_Detail_Secondary_Quantity
--  Parameters:
--  Description:
--
PROCEDURE Update_LPN_Secondary_Quantity (
  p_api_version        IN         NUMBER
, p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
, p_commit             IN         VARCHAR2 := fnd_api.g_false
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_record_source      IN         VARCHAR2
, p_organization_id    IN         NUMBER
, p_lpn_id             IN         NUMBER
, p_inventory_item_id  IN         NUMBER
, p_revision           IN         VARCHAR2 := NULL
, p_lot_number         IN         VARCHAR2 := NULL
, p_quantity           IN         NUMBER
, p_uom_code           IN         VARCHAR2
, p_secondary_quantity IN         NUMBER
, p_secondary_uom_code IN         VARCHAR2
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Update_LPN_Secondary_Quantity';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

CURSOR mmtt_cur IS
  SELECT rowid, transaction_temp_id, transaction_quantity, transaction_uom
    FROM mtl_material_transactions_temp
   WHERE organization_id = p_organization_id
     AND inventory_item_id = p_inventory_item_id
     AND NVL(revision, '@') = NVL(p_revision, '@')
     AND transaction_source_type_id = INV_GLOBALS.G_SourceType_SalesOrder
     AND transaction_action_id = INV_GLOBALS.G_Action_Stgxfr
     AND NVL(content_lpn_id, transfer_lpn_id) = p_lpn_id;

CURSOR mtlt_cur(p_trx_temp_id NUMBER) IS
  SELECT rowid, transaction_quantity
    FROM mtl_transaction_lots_temp
   WHERE transaction_temp_id = p_trx_temp_id
     AND lot_number = p_lot_number;

l_del_det_id     NUMBER;
l_line_quantity  NUMBER;
l_total_quantity NUMBER := 0;
BEGIN
  SAVEPOINT UPDATE_LPN_SECONDARY_QUANTITY;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
    print_debug('recsrc='||p_record_source ||' orgid='||p_organization_id||' lpnid='||p_lpn_id||' itemid='||p_inventory_item_id||' rev='||p_revision||' lot='||p_lot_number, 4);
    print_debug('qty='||p_quantity||' uom='||p_uom_code||' secqty='||p_secondary_quantity||' secuom'||p_secondary_uom_code, 4);
  END IF;

  IF ( p_record_source = 'WDD' OR p_record_source = 'wdd' ) THEN
    l_progress := '100';
    -- LPN is in staging, Update WSH_DELIVERY_DETAILS
    -- Need to retrieve the delviery_detail_id for the LPN, then pass to
    -- Other API from WDD processing
    BEGIN
      SELECT delivery_detail_id
        INTO l_del_det_id
        FROM wsh_delivery_details
       WHERE organization_id = p_organization_id
         AND lpn_id = p_lpn_id
	 AND released_status = 'X';  -- For LPN reuse ER : 6845650
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      	l_del_det_id := NULL;
    END;

    l_progress := '200';
    IF ( l_del_det_id IS NOT NULL ) THEN
      Update_Parent_Delivery_Sec_Qty (
        p_api_version        => 1.0
      , x_return_status      => x_return_status
      , x_msg_count          => x_msg_count
      , x_msg_data           => x_msg_data
      , p_organization_id    => p_organization_id
      , p_parent_del_det_id  => l_del_det_id
      , p_inventory_item_id  => p_inventory_item_id
      , p_revision           => p_revision
      , p_lot_number         => p_lot_number
      , p_quantity           => p_quantity
      , p_uom_code           => p_uom_code
      , p_secondary_quantity => p_secondary_quantity
      , p_secondary_uom_code => p_secondary_uom_code );

      IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
  ELSIF ( p_record_source = 'MMTT' OR p_record_source = 'mmtt' ) THEN
    l_progress := '300';
    -- This is assumed to be an update of LPNs that are before drop, update MMTT
    IF ( p_lot_number IS NULL ) THEN
      l_progress := '400';
      IF ( p_secondary_quantity IS NULL ) THEN
        -- Caller wants to null out all secondary_quantity for this item
        UPDATE mtl_material_transactions_temp
           SET secondary_transaction_quantity = NULL,
               secondary_uom_code = NULL
         WHERE organization_id = p_organization_id
           AND inventory_item_id = p_inventory_item_id
           AND NVL(revision, '@') = NVL(p_revision, '@')
           AND transaction_source_type_id = INV_GLOBALS.G_SourceType_SalesOrder
           AND transaction_action_id = INV_GLOBALS.G_Action_Stgxfr
           AND NVL(content_lpn_id, transfer_lpn_id) = p_lpn_id;
      ELSE
        FOR mmtt_rec IN mmtt_cur LOOP
          IF ( l_debug = 1 ) THEN
            print_debug('Got from MMTT trxtempid='||mmtt_rec.transaction_temp_id||' trxqty='||mmtt_rec.transaction_quantity||' trxuom='||mmtt_rec.transaction_uom, 4);
          END IF;

          IF ( mmtt_rec.transaction_uom <> p_uom_code ) THEN
            l_line_quantity := inv_convert.inv_um_convert(
                                  p_inventory_item_id
                                , 6
                                , mmtt_rec.transaction_quantity
                                , mmtt_rec.transaction_uom
                                , p_uom_code
                                , NULL
                                , NULL );
            IF ( l_line_quantity < 0 ) THEN
              IF ( l_debug = 1 ) THEN
                print_debug('Error converting to trx qty from '||mmtt_rec.transaction_uom||' to '||p_uom_code, 1);
              END IF;
              fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
              fnd_message.set_token('uom1', mmtt_rec.transaction_uom);
              fnd_message.set_token('uom2', p_uom_code);
              fnd_message.set_token('module', l_api_name);
              fnd_msg_pub.ADD;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          ELSE
            l_line_quantity := mmtt_rec.transaction_quantity;
          END IF;

          UPDATE mtl_material_transactions_temp
             SET secondary_transaction_quantity = round(p_secondary_quantity*(l_line_quantity/p_quantity), g_precision),
                 secondary_uom_code = p_secondary_uom_code
           WHERE rowid = mmtt_rec.rowid;

          --Add to the total primary quantity for sanity check at the end
          l_total_quantity := l_total_quantity + l_line_quantity;
        END LOOP;
      END IF;
      l_progress := '500';
    ELSE -- p_lot_number is not null
      l_progress := '600';
      IF ( p_secondary_quantity IS NULL ) THEN
        -- Caller wants to null out all secondary_quantity for this lot
        UPDATE mtl_transaction_lots_temp
           SET secondary_quantity = NULL,
               secondary_unit_of_measure = NULL
         WHERE lot_number = p_lot_number
           AND transaction_temp_id IN (
               SELECT transaction_temp_id
                 FROM mtl_material_transactions_temp mmtt
                WHERE organization_id = p_organization_id
                  AND inventory_item_id = p_inventory_item_id
                  AND NVL(revision, '@') = NVL(p_revision, '@')
                  AND transaction_source_type_id = INV_GLOBALS.G_SourceType_SalesOrder
                  AND transaction_action_id = INV_GLOBALS.G_Action_Stgxfr
                  AND NVL(content_lpn_id, transfer_lpn_id) = p_lpn_id );
      ELSE
        FOR mmtt_rec IN mmtt_cur LOOP
          IF ( l_debug = 1 ) THEN
            print_debug('Got from MMTT trxtempid='||mmtt_rec.transaction_temp_id||' trxqty='||mmtt_rec.transaction_quantity||' trxuom='||mmtt_rec.transaction_uom, 4);
          END IF;

          FOR mtlt_rec IN mtlt_cur(mmtt_rec.transaction_temp_id) LOOP
            IF ( l_debug = 1 ) THEN
              print_debug('Got form MTLT lottrxqty='||mtlt_rec.transaction_quantity, 4);
            END IF;

            IF ( mmtt_rec.transaction_uom <> p_uom_code ) THEN
              l_line_quantity := inv_convert.inv_um_convert(
                                    p_inventory_item_id
                                  , 6
                                  , mtlt_rec.transaction_quantity
                                  , mmtt_rec.transaction_uom
                                  , p_uom_code
                                  , NULL
                                  , NULL );
              IF ( l_line_quantity < 0 ) THEN
                IF ( l_debug = 1 ) THEN
                  print_debug('Error converting to trx qty from '||mmtt_rec.transaction_uom||' to '||p_uom_code, 1);
                END IF;
                fnd_message.set_name('INV', 'INV_UOM_CONVERSION_ERROR');
                fnd_message.set_token('uom1', mmtt_rec.transaction_uom);
                fnd_message.set_token('uom2', p_uom_code);
                fnd_message.set_token('module', l_api_name);
                fnd_msg_pub.ADD;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
            ELSE
              l_line_quantity := mtlt_rec.transaction_quantity;
            END IF;

            UPDATE mtl_transaction_lots_temp
               SET secondary_quantity = round(p_secondary_quantity*(l_line_quantity/p_quantity), g_precision),
                   secondary_unit_of_measure = p_secondary_uom_code
             WHERE rowid = mtlt_rec.rowid;

            --Add to the total primary quantity for sanity check at the end
            l_total_quantity := l_total_quantity + l_line_quantity;
          END LOOP;
        END LOOP;
      END IF;
    END IF;
    l_progress := '700';
    -- Sanity check to make sure the correct quantity of items were updated
    IF(p_secondary_quantity IS NOT NULL AND round(p_quantity, g_precision) <> round(l_total_quantity, g_precision) ) THEN
      IF (l_debug = 1) THEN
        print_debug('the p_quantity '||p_quantity||' does not match the sum quantity '||l_total_quantity, 9);
      END IF;
      FND_MESSAGE.SET_NAME('WMS','WMS_QTY_UPD_MISMATCH_ERROR');
      FND_MESSAGE.SET_TOKEN('QTY1', p_quantity);
      FND_MESSAGE.SET_TOKEN('QTY2', l_total_quantity);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  l_progress := '800';
  -- End of API body
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Exited ', 1);
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;

    ROLLBACK TO UPDATE_LPN_SECONDARY_QUANTITY;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_OTHERS_ERROR_CALL'||l_progress);
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Update_LPN_Secondary_Quantity;


FUNCTION Check_LPN_Secondary_Quantity (
  p_api_version      IN         NUMBER
, p_init_msg_list    IN         VARCHAR2 := fnd_api.g_false
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
, p_organization_id  IN         NUMBER
, p_outermost_lpn_id IN         NUMBER
) RETURN NUMBER IS
l_api_name    CONSTANT VARCHAR2(30) := 'Check_LPN_Secondary_Quantity';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';

CURSOR wdd_nested_lpn_cur IS
  SELECT wlpn.lpn_id, wdd.delivery_detail_id
    FROM wms_license_plate_numbers wlpn,
         wsh_delivery_details wdd
   WHERE wlpn.organization_id = p_organization_id
     AND wlpn.outermost_lpn_id = p_outermost_lpn_id
     AND wdd.organization_id = wlpn.organization_id
     AND wdd.lpn_id = wlpn.lpn_id
     AND wdd.released_status = 'X';  -- For LPN reuse ER : 6845650

CURSOR wdd_item_cur (p_parent_delivery_detail_id NUMBER) IS
  SELECT distinct wdd.organization_id, wdd.inventory_item_id, msi.primary_uom_code, msi.secondary_uom_code
    FROM mtl_system_items msi,
         wsh_delivery_details wdd,
         wsh_delivery_assignments_v wda
   WHERE wda.parent_delivery_detail_id = p_parent_delivery_detail_id
     AND wdd.delivery_detail_id = wda.delivery_detail_id
     AND wdd.line_direction = 'O'
     AND wdd.picked_quantity2 IS NULL
     AND msi.organization_id = wdd.organization_id
     AND msi.inventory_item_id = wdd.inventory_item_id
     AND msi.ont_pricing_qty_source = G_PRICE_SECONDARY
     AND msi.secondary_default_ind = G_SECONDARY_DEFAULT
   ORDER BY msi.primary_uom_code, msi.secondary_uom_code;

CURSOR mmtt_item_cur IS
  SELECT distinct inventory_item_id, organization_id
    FROM mtl_material_transactions_temp
   WHERE organization_id = p_organization_id
     AND transaction_source_type_id = INV_GLOBALS.G_SourceType_SalesOrder
     AND transaction_action_id = INV_GLOBALS.G_Action_Stgxfr
     AND ( transfer_lpn_id = p_outermost_lpn_id OR content_lpn_id = p_outermost_lpn_id )
     AND ( secondary_transaction_quantity IS NULL OR secondary_uom_code IS NULL );

l_return           NUMBER := G_CHECK_SUCCESS;
l_lpn_context      NUMBER;
l_temp             NUMBER := 0;
l_prev_org_id      NUMBER := -999;
l_prev_item_id     NUMBER := -999;
l_prev_pri_uom     VARCHAR2(3) := '@';
l_prev_sec_uom     VARCHAR2(3) := '@';

l_pricing_ind      VARCHAR2(30);
l_default_ind      VARCHAR2(30);
l_pri_uom          VARCHAR2(3);
l_sec_uom          VARCHAR2(3);
l_lot_control_code NUMBER;
l_uom_conv_rate    NUMBER;
BEGIN
  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
    print_debug('orgid='||p_organization_id||' outerlpnid='||p_outermost_lpn_id, 4);
  END IF;

  BEGIN
    SELECT lpn_context
      INTO l_lpn_context
      FROM wms_license_plate_numbers
     WHERE organization_id = p_organization_id
       AND lpn_id = p_outermost_lpn_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF ( l_debug = 1 ) THEN
        print_debug('Error Could not find outermost lpn', 1);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  l_progress := '000';
  IF ( l_lpn_context = WMS_CONTAINER_PVT.LPN_CONTEXT_PICKED OR
       l_lpn_context = WMS_CONTAINER_PVT.LPN_LOADED_FOR_SHIPMENT ) THEN
    l_progress := '100';
    -- Records should be checked in WDD to see if any catch weight item is
    -- is missing secondary quantities (picked_quantity2)
    FOR wdd_nested_lpn_rec IN wdd_nested_lpn_cur LOOP
      IF ( l_debug = 1 ) THEN
        print_debug('lpnid='||wdd_nested_lpn_rec.lpn_id||' ddid='||wdd_nested_lpn_rec.delivery_detail_id, 1);
      END IF;

      -- Check LPN that all catch weight enabled items that are not defaultable have sec qty.
      -- bug 4918256 only for WDD lines that are part of sales orders (line_direction = 'O')
      BEGIN
        SELECT 1 INTO l_temp FROM DUAL
        WHERE EXISTS (
          SELECT 1
            FROM mtl_system_items msi,
                 wsh_delivery_details wdd,
                 wsh_delivery_assignments_v wda
           WHERE wda.parent_delivery_detail_id = wdd_nested_lpn_rec.delivery_detail_id
             AND wdd.delivery_detail_id = wda.delivery_detail_id
             AND wdd.line_direction = 'O'
             AND wdd.picked_quantity2 IS NULL
             AND msi.organization_id = wdd.organization_id
             AND msi.inventory_item_id = wdd.inventory_item_id
             AND msi.ont_pricing_qty_source = G_PRICE_SECONDARY
             AND msi.secondary_default_ind = G_SECONDARY_NO_DEFAULT );

        IF ( l_temp = 1 ) THEN
          IF ( l_debug = 1 ) THEN
            print_debug('Found lpn in wdd with catch weight item that require secondary qty: lpnid=' ||wdd_nested_lpn_rec.lpn_id, 1);
          END IF;

          l_return := G_CHECK_ERROR;
          EXIT;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- All the items in this lpn check out, continue
          NULL;
        WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      -- Check LPN that all catch weight enabled items that are defaultable and do not
      -- have sec qty defined have a valid uom conversion.
      FOR wdd_item_rec IN wdd_item_cur(wdd_nested_lpn_rec.delivery_detail_id) LOOP
        -- Check that there is a valid uom conversin between primary and secondary.
        IF ( wdd_item_rec.primary_uom_code <> l_prev_pri_uom OR
             wdd_item_rec.secondary_uom_code <> l_prev_sec_uom ) THEN
          -- Call UOM API to check that there is a valid conversion rate
          INV_CONVERT.inv_um_conversion (
            from_unit => wdd_item_rec.primary_uom_code
          , to_unit   => wdd_item_rec.secondary_uom_code
          , item_id   => wdd_item_rec.inventory_item_id
          , uom_rate  => l_uom_conv_rate );

          IF ( l_uom_conv_rate < 0 ) THEN
            -- no valid connection uom conversion between these two uoms
            l_return := G_CHECK_ERROR;

            fnd_message.set_name('WMS', 'WMS_CTWT_DEFAULT_ERROR');
            fnd_msg_pub.ADD;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
          ELSE
            -- there is a valid conversion, change status to warning
            l_return := G_CHECK_WARNING;
            l_prev_pri_uom := wdd_item_rec.primary_uom_code;
            l_prev_sec_uom := wdd_item_rec.secondary_uom_code;
          END IF;
        END IF;
      END LOOP;

      -- Exit at any point when a catch weight cannot be resolved
      EXIT WHEN l_return = G_CHECK_ERROR;
    END LOOP;
  ELSIF ( l_lpn_context = WMS_CONTAINER_PVT.LPN_CONTEXT_INV OR
          l_lpn_context = WMS_CONTAINER_PVT.LPN_CONTEXT_PACKING OR
          l_lpn_context = WMS_CONTAINER_PVT.LPN_CONTEXT_PREGENERATED ) THEN
    l_progress := '600';
    -- Records should be checked in MMTT to see if any catch weight item is
    -- is missing secondary transaction quantities.  Currently during picking
    -- LPNs can only be nested one level deep.  This cursor makes that assumtion
    FOR mmtt_item_rec IN mmtt_item_cur LOOP
      BEGIN
        SELECT ont_pricing_qty_source, secondary_default_ind, primary_uom_code,
               secondary_uom_code, lot_control_code
          INTO l_pricing_ind, l_default_ind, l_pri_uom, l_sec_uom, l_lot_control_code
          FROM mtl_system_items
         WHERE organization_id = mmtt_item_rec.organization_id
           AND inventory_item_id = mmtt_item_rec.inventory_item_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF ( l_debug = 1 ) THEN
            print_debug('Error: could not find item in MSI: orgid='||mmtt_item_rec.organization_id||' itemid='||mmtt_item_rec.inventory_item_id, 1);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      IF ( l_pricing_ind = G_PRICE_SECONDARY ) THEN
        -- If the item is not lot controlled, return to user that lpn still needs catch weight
        IF (l_lot_control_code = 1 ) THEN
          -- if item can defaulted check uom conversion to make sure it is valid
          IF ( l_default_ind = G_SECONDARY_DEFAULT ) THEN
            IF ( l_prev_pri_uom <> l_pri_uom OR l_prev_sec_uom <> l_sec_uom ) THEN
              -- Call UOM API to check that there is a valid conversion rate
              INV_CONVERT.inv_um_conversion (
                from_unit => l_pri_uom
              , to_unit   => l_sec_uom
              , item_id   => mmtt_item_rec.inventory_item_id
              , uom_rate  => l_uom_conv_rate );

              IF ( l_uom_conv_rate < 0 ) THEN
                -- no valid connection uom conversion between these two uoms
                l_return := G_CHECK_ERROR;

                fnd_message.set_name('WMS', 'WMS_CTWT_DEFAULT_ERROR');
                fnd_msg_pub.ADD;
                FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              ELSE
                -- there is a valid conversion, change status to warning
                l_return := G_CHECK_WARNING;
                l_prev_pri_uom := l_pri_uom;
                l_prev_sec_uom := l_sec_uom;
              END IF;
            END IF;
          ELSE
            IF ( l_debug = 1 ) THEN
              print_debug('Found catch weight item in mmtt with item that requires secondary qty: itemid=' ||mmtt_item_rec.inventory_item_id, 1);
            END IF;

            l_return := G_CHECK_ERROR;
          END IF;
        ELSE -- Lot controlled item need to check MTLT for sec qty for
          BEGIN
            SELECT 1 INTO l_temp FROM DUAL
            WHERE EXISTS (
              SELECT 1
               FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
              WHERE mmtt.organization_id = mmtt_item_rec.organization_id
                AND mmtt.inventory_item_id = mmtt_item_rec.inventory_item_id
                AND mmtt.transaction_source_type_id = INV_GLOBALS.G_SourceType_SalesOrder
                AND mmtt.transaction_action_id = INV_GLOBALS.G_Action_Stgxfr
                AND ( mmtt.transfer_lpn_id = p_outermost_lpn_id OR mmtt.content_lpn_id = p_outermost_lpn_id )
                AND mtlt.transaction_temp_id = mmtt.transaction_temp_id
                AND ( mtlt.secondary_quantity IS NULL OR mtlt.secondary_unit_of_measure IS NULL) );
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF ( l_debug = 1 ) THEN
                print_debug('Found lot catch weight item in mtlt with item that requires secondary qty: itemid=' ||mmtt_item_rec.inventory_item_id, 1);
              END IF;

              l_temp := 0;
            WHEN OTHERS THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

          -- If this lot item was found to not have catch weigth but can be defaulted
          -- Check UOM conversion to make sure it's valid
          IF ( l_temp = 0 AND l_default_ind = G_SECONDARY_DEFAULT ) THEN
            IF ( l_prev_pri_uom <> l_pri_uom OR l_prev_sec_uom <> l_sec_uom ) THEN
              -- Call UOM API to check that there is a valid conversion rate
              INV_CONVERT.inv_um_conversion (
                from_unit => l_pri_uom
              , to_unit   => l_sec_uom
              , item_id   => mmtt_item_rec.inventory_item_id
              , uom_rate  => l_uom_conv_rate );

              IF ( l_uom_conv_rate < 0 ) THEN
                -- no valid connection uom conversion between these two uoms
                l_return := G_CHECK_ERROR;

                fnd_message.set_name('WMS', 'WMS_CTWT_DEFAULT_ERROR');
                fnd_msg_pub.ADD;
                FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              ELSE
                -- there is a valid conversion, change status to warning
                l_return := G_CHECK_WARNING;
                l_prev_pri_uom := l_pri_uom;
                l_prev_sec_uom := l_sec_uom;
              END IF;
            END IF;
          ELSE
            IF ( l_debug = 1 ) THEN
              print_debug('Found catch weight item in mtlt with item that requires secondary qty: itemid=' ||mmtt_item_rec.inventory_item_id, 1);
            END IF;

            l_return := G_CHECK_ERROR;
          END IF;
        END IF;
      END IF;

      EXIT WHEN l_return = G_CHECK_ERROR;
    END LOOP;
  END IF;

  -- if the return is a warning populate an appropreate
  -- message in the message stack
  IF ( l_return = G_CHECK_WARNING ) THEN
    fnd_message.set_name('WMS', 'WMS_CTWT_DEFAULT_WARNING');
    fnd_msg_pub.ADD;
  END IF;

  IF ( l_debug = 1 ) THEN
    print_debug(l_api_name||' Exited '||'ret='||l_return, 1);
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  RETURN l_return;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      print_debug(l_api_name||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;

    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_API_FAIL');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Check_LPN_Secondary_Quantity;


PROCEDURE GET_OUTER_CATCH_WT_LPN
   (x_lpn_lov OUT NOCOPY t_genref,
   p_org_id  IN NUMBER,
   p_lpn     IN VARCHAR2,
   p_entry_type IN VARCHAR2)
IS
BEGIN

 IF (UPPER(p_entry_type) = 'CT_WT_ALL') THEN
   OPEN x_lpn_lov FOR
   SELECT UNIQUE wlpn2.license_plate_number,
          wlpn.outermost_lpn_id outer_lpn_id, wlpn.lpn_context
   FROM   wms_license_plate_numbers wlpn, wms_license_plate_numbers wlpn2
   WHERE  wlpn.outermost_lpn_id = wlpn2.lpn_id
   AND    wlpn.lpn_context in (11,8) -- picked/loaded
   AND    wlpn.organization_id = p_org_id
   AND    wlpn.license_plate_number LIKE (p_lpn || '%')
   AND    EXISTS (
            SELECT msi.inventory_item_id
            FROM   wms_lpn_contents wlc , mtl_system_items_b msi
            WHERE  wlc.organization_id = msi.organization_id
            AND    wlc.inventory_item_id = msi.inventory_item_id
            AND    msi.ont_pricing_qty_source = 'S'
            AND    msi.organization_id = p_org_id
            AND    wlc.parent_lpn_id = wlpn.lpn_id)
   UNION
   SELECT UNIQUE wlpn.license_plate_number,
          nvl(mmtt.transfer_lpn_id,mmtt.content_lpn_id) outer_lpn,
          wlpn.lpn_context
   FROM   mtl_material_transactions_temp mmtt,
          wms_license_plate_numbers wlpn,
          mtl_system_items_b msi
   WHERE  mmtt.inventory_item_id = msi.inventory_item_id
   AND    mmtt.organization_id = msi.organization_id
   AND    mmtt.organization_id = p_org_id
   AND    wlpn.lpn_id = nvl(mmtt.transfer_lpn_id, content_lpn_id)
   AND    wlpn.lpn_context = 8  -- loaded
   AND    msi.ont_pricing_qty_source = 'S'
   AND    wlpn.license_plate_number LIKE (p_lpn || '%')
   AND    parent_line_id is null -- exclude bulk-picked tasks
   UNION
   SELECT UNIQUE wlpn.license_plate_number,
          transfer_lpn_id,
          wlpn.lpn_context
   FROM   mtl_material_transactions_temp mmtt,
          wms_license_plate_numbers wlpn,
          mtl_system_items_b msi
   WHERE  mmtt.inventory_item_id = msi.inventory_item_id
   AND    mmtt.organization_id = msi.organization_id
   AND    mmtt.organization_id = p_org_id
   AND    wlpn.lpn_id = mmtt.transfer_lpn_id
   AND    mmtt.transfer_lpn_id IS NOT NULL
   AND    EXISTS (SELECT wlpn2.lpn_id
                              FROM   wms_license_plate_numbers wlpn2
                              WHERE  wlpn2.lpn_id = mmtt.content_lpn_id
                              AND    wlpn2.lpn_context = 8)
   AND    msi.ont_pricing_qty_source = 'S'
   AND    wlpn.license_plate_number LIKE (p_lpn || '%')
   AND parent_line_id is null; -- exclude bulk-picked tasks

 ELSE
   OPEN x_lpn_lov FOR
   SELECT UNIQUE wlpn2.license_plate_number,wlpn.outermost_lpn_id,
          wlpn2.lpn_context
   FROM   wms_license_plate_numbers wlpn, wms_license_plate_numbers wlpn2
   WHERE  wlpn.outermost_lpn_id = wlpn2.lpn_id
   AND    wlpn.lpn_context in (11)  -- picked
   AND    wlpn.organization_id = p_org_id
   AND    wlpn.license_plate_number LIKE (p_lpn || '%')
   AND    EXISTS (
             SELECT msi.inventory_item_id, wddl.lpn_id
             FROM   mtl_system_items_b msi,
                    wsh_delivery_details wddl,
                    wsh_delivery_assignments_v wda,
                    wsh_delivery_details wddit
             WHERE  wddit.organization_id = msi.organization_id
             AND    wddit.inventory_item_id = msi.inventory_item_id
             AND    msi.ont_pricing_qty_source = 'S'
             AND    wddl.lpn_id = wlpn.lpn_id
	     AND    wddl.released_status = 'X'  -- For LPN reuse ER : 6845650
             AND    msi.organization_id = p_org_id
             AND    wddl.delivery_detail_id = wda.parent_delivery_detail_id
             AND    wddit.delivery_detail_id = wda.delivery_detail_id
             AND    wddit.picked_quantity2 is null )
   UNION
   SELECT UNIQUE wlpn.license_plate_number,
                 nvl(mmtt.transfer_lpn_id,mmtt.content_lpn_id) outer_lpn,
                 wlpn.lpn_context
   FROM   mtl_material_transactions_temp mmtt, wms_license_plate_numbers wlpn,
          mtl_system_items_b msi, mtl_transaction_lots_temp mtlt
   WHERE  mmtt.inventory_item_id = msi.inventory_item_id
   AND    mmtt.organization_id = msi.organization_id
   AND    mmtt.organization_id = p_org_id
   AND    msi.ont_pricing_qty_source = 'S'
   AND    wlpn.lpn_id = nvl(mmtt.transfer_lpn_id, content_lpn_id)
   AND    wlpn.lpn_context = 8  -- loaded
   AND    wlpn.license_plate_number LIKE (p_lpn || '%')
   AND    parent_line_id is null -- exclude bulk-picked tasks
   AND    secondary_transaction_quantity is null -- catch.wt not enterd
   AND    mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
   AND    mtlt.secondary_quantity IS NULL
   UNION
   SELECT UNIQUE wlpn.license_plate_number,
          transfer_lpn_id, wlpn.lpn_context
   FROM   mtl_material_transactions_temp mmtt,
          wms_license_plate_numbers wlpn,
          mtl_system_items_b msi,
          mtl_transaction_lots_temp mtlt
   WHERE  mmtt.inventory_item_id = msi.inventory_item_id
   AND    mmtt.organization_id = msi.organization_id
   AND    mmtt.organization_id = p_org_id
   AND    wlpn.lpn_id = mmtt.transfer_lpn_id
   AND    wlpn.license_plate_number LIKE (p_lpn || '%')
   AND    mmtt.transfer_lpn_id IS NOT NULL
   AND    EXISTS (SELECT wlpn2.lpn_id
                              FROM   wms_license_plate_numbers wlpn2
                              WHERE  wlpn2.lpn_id = mmtt.content_lpn_id
                              AND    wlpn2.lpn_context = 8)
   AND    mmtt.secondary_transaction_quantity is null -- catch.wt not enterd
   AND    msi.ont_pricing_qty_source = 'S'
   AND    parent_line_id is null  -- exclude bulk-picked tasks
   AND    mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
   AND    mtlt.secondary_quantity IS NULL;
 END IF;
END GET_OUTER_CATCH_WT_LPN;


PROCEDURE GET_INNER_CATCH_WT_LPN
 (x_lpn_lov OUT NOCOPY t_genref,
  p_org_id        IN  NUMBER,
  p_outer_lpn_id  IN  NUMBER,
  p_entry_type    IN  VARCHAR2,
  p_lpn_context   IN  NUMBER,
  p_inner_lpn     IN  VARCHAR2)
IS
BEGIN

 IF (UPPER(p_entry_type) = 'DIRECTSHIP') THEN

    OPEN x_lpn_lov FOR
    SELECT owlpn.license_plate_number, owlpn.lpn_id
    FROM (
         SELECT wlpn.license_plate_number, wlpn.lpn_id
         FROM   wms_license_plate_numbers wlpn
         WHERE  outermost_lpn_id = p_outer_lpn_id
         AND    EXISTS (
                   SELECT 1
                   FROM   mtl_system_items_b msi, wms_lpn_contents wlc
                   WHERE  wlc.organization_id = wlpn.organization_id
                   AND    wlc.parent_lpn_id = wlpn.lpn_id
                   AND    msi.organization_id = wlc.organization_id
                   AND    msi.inventory_item_id = wlc.inventory_item_id
                   AND    msi.ont_pricing_qty_source = 'S'
                   )
         ) owlpn
     WHERE owlpn.license_plate_number LIKE (p_inner_lpn || '%')
     AND not exists (SELECT 1 FROM WMS_DS_CT_WT_GTEMP gt
               WHERE nvl(gt.INNER_LPN_ID, gt.LPN_ID) = owlpn.lpn_id);

 ELSIF (UPPER(p_entry_type) = 'CT_WT_ALL') THEN

    OPEN x_lpn_lov FOR
         SELECT distinct wlpn.license_plate_number, lpn_id
         FROM   wms_license_plate_numbers wlpn
         WHERE  outermost_lpn_id = p_outer_lpn_id
         AND    wlpn.license_plate_number LIKE (p_inner_lpn || '%')
         AND    EXISTS (
                   SELECT msi.inventory_item_id
                   FROM   wms_lpn_contents wlc , mtl_system_items_b msi
                   WHERE  wlc.organization_id = msi.organization_id
                   AND    wlc.inventory_item_id = msi.inventory_item_id
                   AND    msi.ont_pricing_qty_source = 'S'
                   AND    wlc.parent_lpn_id = wlpn.lpn_id)
         UNION
         SELECT distinct license_plate_number, content_lpn_id
         FROM   mtl_system_items msi, mtl_material_transactions_temp mmtt,
                wms_license_plate_numbers wlpn
         WHERE  (mmtt.content_lpn_id = p_outer_lpn_id
                OR mmtt.transfer_lpn_id = p_outer_lpn_id )
         AND    mmtt.organization_id = p_org_id
         AND    mmtt.organization_id =  msi.organization_id
         AND    mmtt.inventory_item_id = msi.inventory_item_id
         AND    msi.ont_pricing_qty_source = 'S'
         AND    wlpn.lpn_id = mmtt.content_lpn_id
         AND    wlpn.license_plate_number LIKE (p_inner_lpn || '%');
         /*UNION
         SELECT distinct license_plate_number,
                transfer_lpn_id
         FROM   mtl_system_items msi,
                mtl_material_transactions_temp mmtt,
                wms_license_plate_numbers wlpn
         WHERE  (mmtt.content_lpn_id = p_outer_lpn_id
                OR mmtt.transfer_lpn_id = p_outer_lpn_id)
         AND    mmtt.organization_id = p_org_id
         AND    mmtt.organization_id =  msi.organization_id
         AND    mmtt.inventory_item_id = msi.inventory_item_id
         AND    msi.ont_pricing_qty_source = 'S'
         AND    wlpn.lpn_id = mmtt.transfer_lpn_id
         AND    wlpn.license_plate_number LIKE (p_inner_lpn || '%');
        */
 ELSE
         IF (p_lpn_context = 8 OR p_lpn_context = 1) THEN    --Packing
              OPEN x_lpn_lov FOR
                  SELECT distinct wlpn.license_plate_number, content_lpn_id
                  FROM mtl_system_items msi
                      ,mtl_material_transactions_temp mmtt
                      ,wms_license_plate_numbers wlpn
                      ,mtl_transaction_lots_temp mtlt
                  WHERE mmtt.content_lpn_id = p_outer_lpn_id
                  AND mmtt.organization_id = p_org_id
                  AND mmtt.organization_id =  msi.organization_id
                  AND mmtt.inventory_item_id = msi.inventory_item_id
                  AND msi.ont_pricing_qty_source = 'S'
                  AND mmtt.secondary_transaction_quantity is null
                  AND mmtt.content_lpn_id = wlpn.lpn_id
                  AND mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
                  AND mtlt.secondary_quantity IS NULL
                  AND wlpn.license_plate_number LIKE (p_inner_lpn || '%')
                  UNION
                  SELECT distinct wlpn.license_plate_number, content_lpn_id
                  FROM mtl_system_items msi, mtl_material_transactions_temp mmtt
                      ,wms_license_plate_numbers wlpn
                      ,mtl_transaction_lots_temp mtlt
                  WHERE mmtt.transfer_lpn_id = p_outer_lpn_id
                  AND mmtt.organization_id = p_org_id
                  AND mmtt.organization_id =  msi.organization_id
                  AND mmtt.inventory_item_id = msi.inventory_item_id
                  AND msi.ont_pricing_qty_source = 'S'
                  AND mmtt.secondary_transaction_quantity is null
                  AND wlpn.lpn_id = mmtt.content_lpn_id
                  AND mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
                  AND wlpn.license_plate_number LIKE (p_inner_lpn || '%')
                  AND mtlt.secondary_quantity is NULL;

         ELSE
              OPEN x_lpn_lov FOR
                  SELECT distinct outer.container_name, outer.lpn_id
                  FROM wsh_delivery_Details inner,
                     (SELECT wda.delivery_detail_id,
                              wdd.inventory_item_id,
                              wdd.lpn_id,wdd.container_name
                      FROM   wsh_delivery_details wdd,
                              wsh_delivery_assignments_v wda
                      WHERE  wdd.lpn_id in (
                                  SELECT wlpn.lpn_id
                                  FROM wms_license_plate_numbers wlpn
                                  WHERE outermost_lpn_id = p_outer_lpn_id)
                      AND wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
                      AND wda.parent_delivery_detail_id = wdd.delivery_detail_id
                      AND wdd.organization_id = p_org_id
                      AND wda.parent_delivery_detail_id is not null
                      AND picked_quantity2 is null) outer
                  WHERE inner.delivery_detail_id = outer.delivery_Detail_id
                  AND   outer.container_name LIKE (p_inner_lpn || '%')
                  AND exists (SELECT msi.inventory_item_id
                             FROM mtl_system_items_b msi
                             WHERE msi.organization_id = inner.organization_id
                             AND msi.organization_id = p_org_id
                             AND    msi.ont_pricing_qty_source = 'S'
                             AND msi.inventory_item_id = inner.inventory_item_id);
         END IF;
 END IF;
END GET_INNER_CATCH_WT_LPN;

PROCEDURE GET_CATCH_WT_ITEMS
  (x_item_lov OUT NOCOPY t_genref,
   p_org_id       IN NUMBER,
   p_lpn_id       IN NUMBER,
   p_entry_type   IN VARCHAR2,
   p_lpn_context  IN NUMBER,
   p_concat_item_segment IN VARCHAR2)
IS
l_append varchar2(2):='';
BEGIN

  l_append := wms_deploy.get_item_suffix_for_lov(p_concat_item_segment);

  IF (UPPER(p_entry_type) = 'DIRECTSHIP') THEN

    OPEN x_item_lov FOR
        SELECT DISTINCT msiv.concatenated_segments
                , msi.inventory_item_id
                , msi.description
                , NVL(msi.revision_qty_control_code, 1)
                , NVL(msi.lot_control_code, 1)
                , NVL(msi.serial_number_control_code, 1)
                , NVL(msi.restrict_subinventories_code, 2)
                , NVL(msi.restrict_locators_code, 2)
                , NVL(msi.location_control_code, 1)
                , msi.primary_uom_code
                , NVL(msi.inspection_required_flag, 2)
                , NVL(msi.shelf_life_code, 1)
                , NVL(msi.shelf_life_days, 0)
                , NVL(msi.allowed_units_lookup_code, 2)
                , NVL(msi.effectivity_control, 1)
                , '0'
                , '0'
                , '0'
                , '0'
                , '0'
                , '0'
                , ''
                , 'N'
                , msi.inventory_item_flag
                , 0
                , wms_deploy.get_item_client_name(msi.inventory_item_id)
              --Bug No 3952081
              --Additional Fields for Process Convergence
              , NVL(msi.GRADE_CONTROL_FLAG,'N')
              , NVL(msi.DEFAULT_GRADE,'')
              , NVL(msi.EXPIRATION_ACTION_INTERVAL,0)
              , NVL(msi.EXPIRATION_ACTION_CODE,'')
              , NVL(msi.HOLD_DAYS,0)
              , NVL(msi.MATURITY_DAYS,0)
              , NVL(msi.RETEST_INTERVAL,0)
              , NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N')
              , NVL(msi.CHILD_LOT_FLAG,'N')
              , NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N')
              , NVL(msi.LOT_DIVISIBLE_FLAG,'Y')
              , NVL(msi.SECONDARY_UOM_CODE,'')
              , NVL(msi.SECONDARY_DEFAULT_IND,'')
              , NVL(msi.TRACKING_QUANTITY_IND,'P')
              , NVL(msi.DUAL_UOM_DEVIATION_HIGH,0)
              , NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
        FROM    mtl_system_items_kfv msiv,
                wms_lpn_contents wlc,
                mtl_system_items msi
        WHERE wlc.parent_lpn_id = p_lpn_id
        AND wlc.organization_id = p_org_id
        AND msi.organization_id = wlc.organization_id
        AND msi.inventory_item_id = wlc.inventory_item_id
        AND msi.ont_pricing_qty_source = 'S'
        AND msiv.inventory_item_id = msi.inventory_item_id
        AND msiv.organization_id = msi.organization_id
        AND msiv.concatenated_segments LIKE (p_concat_item_segment || '%' || l_append)
        AND not exists (SELECT 1 FROM WMS_DS_CT_WT_GTEMP gt
                       WHERE gt.inventory_item_id = wlc.inventory_item_id
                       AND gt.org_id = wlc.organization_id
                       AND nvl(gt.INNER_LPN_ID, gt.LPN_ID) = wlc.parent_lpn_id);

  ELSIF (UPPER(p_entry_type) = 'CT_WT_ALL') THEN

    OPEN x_item_lov FOR

        SELECT DISTINCT msi.concatenated_segments
                        , msi.inventory_item_id
                        , msi.description
                        , NVL(msi.revision_qty_control_code, 1)
                        , NVL(msi.lot_control_code, 1)
                        , NVL(msi.serial_number_control_code, 1)
                        , NVL(msi.restrict_subinventories_code, 2)
                        , NVL(msi.restrict_locators_code, 2)
                        , NVL(msi.location_control_code, 1)
                        , msi.primary_uom_code
                        , NVL(msi.inspection_required_flag, 2)
                        , NVL(msi.shelf_life_code, 1)
                        , NVL(msi.shelf_life_days, 0)
                        , NVL(msi.allowed_units_lookup_code, 2)
                        , NVL(msi.effectivity_control, 1)
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , ''
                        , 'N'
                        , msi.inventory_item_flag
                        , 0
                        , wms_deploy.get_item_client_name(msi.inventory_item_id)
                       --Bug No 3952081
                       --Additional Fields for Process Convergence
                       , NVL(msi.GRADE_CONTROL_FLAG,'N')
                       , NVL(msi.DEFAULT_GRADE,'')
                       , NVL(msi.EXPIRATION_ACTION_INTERVAL,0)
                       , NVL(msi.EXPIRATION_ACTION_CODE,'')
                       , NVL(msi.HOLD_DAYS,0)
                       , NVL(msi.MATURITY_DAYS,0)
                       , NVL(msi.RETEST_INTERVAL,0)
                       , NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N')
                       , NVL(msi.CHILD_LOT_FLAG,'N')
                       , NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N')
                       , NVL(msi.LOT_DIVISIBLE_FLAG,'Y')
                       , NVL(msi.SECONDARY_UOM_CODE,'')
                       , NVL(msi.SECONDARY_DEFAULT_IND,'')
                       , NVL(msi.TRACKING_QUANTITY_IND,'P')
                       , NVL(msi.DUAL_UOM_DEVIATION_HIGH,0)
                       , NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
        FROM mtl_system_items_kfv msi, wms_lpn_contents wlc
        WHERE wlc.parent_lpn_id = p_lpn_id
        AND wlc.inventory_item_id = msi.inventory_item_id
        AND    msi.ont_pricing_qty_source = 'S'
        AND wlc.organization_id = msi.organization_id
        AND msi.organization_id = p_org_id
        UNION
        SELECT DISTINCT msi.concatenated_segments
                        , msi.inventory_item_id
                        , msi.description
                        , NVL(msi.revision_qty_control_code, 1)
                        , NVL(msi.lot_control_code, 1)
                        , NVL(msi.serial_number_control_code, 1)
                        , NVL(msi.restrict_subinventories_code, 2)
                        , NVL(msi.restrict_locators_code, 2)
                        , NVL(msi.location_control_code, 1)
                        , msi.primary_uom_code
                        , NVL(msi.inspection_required_flag, 2)
                        , NVL(msi.shelf_life_code, 1)
                        , NVL(msi.shelf_life_days, 0)
                        , NVL(msi.allowed_units_lookup_code, 2)
                        , NVL(msi.effectivity_control, 1)
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , ''
                        , 'N'
                        , msi.inventory_item_flag
                        , 0
                        , wms_deploy.get_item_client_name(msi.inventory_item_id)
                       --Bug No 3952081
                       --Additional Fields for Process Convergence
                       , NVL(msi.GRADE_CONTROL_FLAG,'N')
                       , NVL(msi.DEFAULT_GRADE,'')
                       , NVL(msi.EXPIRATION_ACTION_INTERVAL,0)
                       , NVL(msi.EXPIRATION_ACTION_CODE,'')
                       , NVL(msi.HOLD_DAYS,0)
                       , NVL(msi.MATURITY_DAYS,0)
                       , NVL(msi.RETEST_INTERVAL,0)
                       , NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N')
                       , NVL(msi.CHILD_LOT_FLAG,'N')
                       , NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N')
                       , NVL(msi.LOT_DIVISIBLE_FLAG,'Y')
                       , NVL(msi.SECONDARY_UOM_CODE,'')
                       , NVL(msi.SECONDARY_DEFAULT_IND,'')
                       , NVL(msi.TRACKING_QUANTITY_IND,'P')
                       , NVL(msi.DUAL_UOM_DEVIATION_HIGH,0)
                       , NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
        FROM mtl_system_items_kfv msi, mtl_material_transactions_temp mmtt
        WHERE    (mmtt.content_lpn_id = p_lpn_id OR mmtt.transfer_lpn_id = p_lpn_id)
        AND mmtt.organization_id = p_org_id
        AND mmtt.organization_id =  msi.organization_id
        AND    msi.ont_pricing_qty_source = 'S'
        AND mmtt.inventory_item_id = msi.inventory_item_id;

 ELSE

     IF (p_lpn_context = 8) THEN

        OPEN x_item_lov FOR

            select DISTINCT msi.concatenated_segments
                        , msi.inventory_item_id
                        , msi.description
                        , NVL(msi.revision_qty_control_code, 1)
                        , NVL(msi.lot_control_code, 1)
                        , NVL(msi.serial_number_control_code, 1)
                        , NVL(msi.restrict_subinventories_code, 2)
                        , NVL(msi.restrict_locators_code, 2)
                        , NVL(msi.location_control_code, 1)
                        , msi.primary_uom_code
                        , NVL(msi.inspection_required_flag, 2)
                        , NVL(msi.shelf_life_code, 1)
                        , NVL(msi.shelf_life_days, 0)
                        , NVL(msi.allowed_units_lookup_code, 2)
                        , NVL(msi.effectivity_control, 1)
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , ''
                        , 'N'
                        , msi.inventory_item_flag
                        , 0
                        , wms_deploy.get_item_client_name(msi.inventory_item_id)
                       --Bug No 3952081
                       --Additional Fields for Process Convergence
                       , NVL(msi.GRADE_CONTROL_FLAG,'N')
                       , NVL(msi.DEFAULT_GRADE,'')
                       , NVL(msi.EXPIRATION_ACTION_INTERVAL,0)
                       , NVL(msi.EXPIRATION_ACTION_CODE,'')
                       , NVL(msi.HOLD_DAYS,0)
                       , NVL(msi.MATURITY_DAYS,0)
                       , NVL(msi.RETEST_INTERVAL,0)
                       , NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N')
                       , NVL(msi.CHILD_LOT_FLAG,'N')
                       , NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N')
                       , NVL(msi.LOT_DIVISIBLE_FLAG,'Y')
                       , NVL(msi.SECONDARY_UOM_CODE,'')
                       , NVL(msi.SECONDARY_DEFAULT_IND,'')
                       , NVL(msi.TRACKING_QUANTITY_IND,'P')
                       , NVL(msi.DUAL_UOM_DEVIATION_HIGH,0)
                       , NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
            from mtl_system_items_kfv msi, mtl_material_transactions_temp mmtt
            where    (mmtt.content_lpn_id = p_lpn_id OR mmtt.transfer_lpn_id = p_lpn_id)
            and mmtt.organization_id = p_org_id
            and mmtt.organization_id =  msi.organization_id
            and mmtt.inventory_item_id = msi.inventory_item_id
            AND    msi.ont_pricing_qty_source = 'S'
            and mmtt.secondary_transaction_quantity is null;

     ELSE

        OPEN x_item_lov FOR
            SELECT DISTINCT msi.concatenated_segments
                        , msi.inventory_item_id
                        , msi.description
                        , NVL(msi.revision_qty_control_code, 1)
                        , NVL(msi.lot_control_code, 1)
                        , NVL(msi.serial_number_control_code, 1)
                        , NVL(msi.restrict_subinventories_code, 2)
                        , NVL(msi.restrict_locators_code, 2)
                        , NVL(msi.location_control_code, 1)
                        , msi.primary_uom_code
                        , NVL(msi.inspection_required_flag, 2)
                        , NVL(msi.shelf_life_code, 1)
                        , NVL(msi.shelf_life_days, 0)
                        , NVL(msi.allowed_units_lookup_code, 2)
                        , NVL(msi.effectivity_control, 1)
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , '0'
                        , ''
                        , 'N'
                        , msi.inventory_item_flag
                        , 0
                        , wms_deploy.get_item_client_name(msi.inventory_item_id)
                       --Bug No 3952081
                       --Additional Fields for Process Convergence
                       , NVL(msi.GRADE_CONTROL_FLAG,'N')
                       , NVL(msi.DEFAULT_GRADE,'')
                       , NVL(msi.EXPIRATION_ACTION_INTERVAL,0)
                       , NVL(msi.EXPIRATION_ACTION_CODE,'')
                       , NVL(msi.HOLD_DAYS,0)
                       , NVL(msi.MATURITY_DAYS,0)
                       , NVL(msi.RETEST_INTERVAL,0)
                       , NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N')
                       , NVL(msi.CHILD_LOT_FLAG,'N')
                       , NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N')
                       , NVL(msi.LOT_DIVISIBLE_FLAG,'Y')
                       , NVL(msi.SECONDARY_UOM_CODE,'')
                       , NVL(msi.SECONDARY_DEFAULT_IND,'')
                       , NVL(msi.TRACKING_QUANTITY_IND,'P')
                       , NVL(msi.DUAL_UOM_DEVIATION_HIGH,0)
                       , NVL(msi.DUAL_UOM_DEVIATION_LOW,0)
            FROM   mtl_system_items_kfv msi, wsh_Delivery_Details wdd1
            WHERE  wdd1.inventory_item_id = msi.inventory_item_id
            AND    wdd1.organization_id = msi.organization_id
            AND    msi.ont_pricing_qty_source = 'S'
            AND    wdd1. picked_quantity2 is NULL
            AND    wdd1.delivery_detail_id in
                  (SELECT wda.delivery_detail_id
                   FROM wsh_delivery_details wdd,
                      wsh_delivery_assignments_v wda
                   WHERE  wdd.lpn_id= p_lpn_id
		   AND wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
                   AND wdd.delivery_detail_id = wda.parent_delivery_detail_id
                   AND wdd.organization_id = p_org_id
                   AND wda.parent_delivery_detail_id is not null)
            AND    msi.organization_id = p_org_id;
    END IF;
  END IF;

END GET_CATCH_WT_ITEMS;

PROCEDURE SHOW_CT_WT_FOR_SPLIT (
  p_org_id           IN         NUMBER
, p_from_lpn_id      IN         NUMBER
, p_from_item_id     IN         NUMBER
, p_from_item_revision   IN     VARCHAR2
, p_from_item_lot_number IN     VARCHAR2
, p_to_lpn_id        IN         NUMBER
, x_show_ct_wt       OUT NOCOPY NUMBER
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_data         OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
) IS

CURSOR itemCur(in_lpn_id NUMBER) IS
       SELECT picked_quantity2
       FROM   wsh_delivery_details wdd,
              mtl_system_items_b msib
       WHERE  wdd.inventory_item_id = p_from_item_id
       AND    wdd.inventory_item_id = msib.inventory_item_id
       AND    wdd.organization_id   = p_org_id
       AND    wdd.organization_id   = msib.organization_id
       AND    NVL(wdd.revision,'@@@') = NVL(NVL(p_from_item_revision,wdd.revision),'@@@')
       AND    NVL(wdd.lot_number,'@@@') = NVL(p_from_item_lot_number,'@@@')
       AND    wdd.delivery_detail_id in (SELECT wda.delivery_detail_id
                                        FROM   wsh_delivery_assignments_v wda,
                                               wsh_delivery_details wdd1
                                        WHERE  wdd1.lpn_id = in_lpn_id
					AND    wdd1.released_status = 'X'  -- For LPN reuse ER : 6845650
                                        AND    wdd1.delivery_detail_id = wda.parent_delivery_Detail_id
                                        AND    wdd1.organization_id = p_org_id);



   l_from_sec_qty NUMBER := 0;
   l_to_sec_qty  NUMBER := 0;
   l_from_item_pri_qty NUMBER := 0 ;
   l_to_item_picked_qty NUMBER := 0;
   l_api_name    CONSTANT VARCHAR2(30) := 'SHOW_CT_WT_FOR_SPLIT';
   l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_progress VARCHAR2(30) := '0';
   itemRec itemCur%ROWTYPE;


BEGIN

--If p_to_lpn_id is NULL, THEN the context of to_lpn is 5 ELSE 11
--Check to see if ct wt for from_lpn has been entered for that item in WDD
--if YES, check to see
-- if context of to_lpn = 5, then show_ct_wt
-- if context of to_lpn = 11, then see if ct_wt has been entered in WDD for that item
   IF ( l_debug = 1 ) THEN
       print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
       print_debug('p_org_id   => ' || p_org_id||' fromlpn '||p_from_lpn_id||' fromItem =>'||p_from_item_id||' rev =>'||p_from_item_revision  , 4);
       print_debug('p_from_lot_number => ' || p_from_item_lot_number||'p_to_lpn_id =>'||p_to_lpn_id, 4);
   END IF;

   --add up all the picked_qty2 from wdd, even if 1 rec is null, then
   --the result will be null, and we should hide the ct wt entry

      OPEN itemCur(p_from_lpn_id);
        LOOP
           FETCH itemCur into l_to_item_picked_qty;
           EXIT WHEN itemCur%NOTFOUND;
           print_debug(' inside 2 Loop l_to_item_pri_qty => '||l_to_item_picked_qty,4);
           l_from_item_pri_qty := l_from_item_pri_qty + l_to_item_picked_qty;
           print_debug(' inside 2 Loop l_from_item_pri_qty => '||l_from_item_pri_qty,4);

        END LOOP;
      CLOSE itemCur;

  l_progress := '10';
           print_debug(' out 2 Loop l_from_item_pri_qty => '||l_from_item_pri_qty,4);
     if (l_from_item_pri_qty IS NULL OR l_from_item_pri_qty = 0 ) THEN
         x_show_ct_wt := 0;
         x_return_status := fnd_api.g_ret_sts_success;
         RETURN;
     END IF;

  l_progress := '20';
  if (p_to_lpn_id IS NULL) THEN
          x_show_ct_wt := 1 ;
          x_return_status := fnd_api.g_ret_sts_success;
          RETURN;
  END IF;
  IF (p_to_lpn_id IS NOT NULL) THEN
      OPEN itemCur(p_to_lpn_id);
        LOOP
           FETCH itemCur into l_to_item_picked_qty;
           EXIT WHEN itemCur%NOTFOUND;

           l_to_sec_qty := l_to_sec_qty + l_to_item_picked_qty;
           print_debug('Inside Loop l_to_item_picked_qty => ' || l_to_item_picked_qty||' l_to_sec_qty=>'||l_to_sec_qty,4);
        END LOOP;
      CLOSE itemCur;
  l_progress := '30';
           print_debug('After Loop l_to_sec_qty => '||l_to_sec_qty,4);

      if (l_to_sec_qty IS NULL) THEN
          x_show_ct_wt := 0 ;
          x_return_status := fnd_api.g_ret_sts_success;
          RETURN;
      END IF;

  l_progress := '40';
      if (l_to_sec_qty = 0) THEN
          x_show_ct_wt := 1;
          x_return_status := fnd_api.g_ret_sts_success;
          RETURN;
      END IF;
  END IF;
  l_progress := '50';

   --add up all the picked_qty2 from wdd, even if 1 rec is null, then
   --the result will be null, and we should hide the ct wt entry

      OPEN itemCur(p_from_lpn_id);
        LOOP
           FETCH itemCur into l_to_item_picked_qty;
           EXIT WHEN itemCur%NOTFOUND;
          l_from_item_pri_qty := l_from_item_pri_qty + l_to_item_picked_qty;
           print_debug(' inside 2 Loop l_from_item_pri_qty => '||l_from_item_pri_qty,4);

        END LOOP;
      CLOSE itemCur;

  l_progress := '60';
     print_debug(' Before computing l_from_item_pri_qty => '||l_from_item_pri_qty||' l_to_sec_qty =>'||l_to_sec_qty,4);

     IF (NVL(l_from_item_pri_qty,0) > 0 AND l_to_sec_qty >= 0 ) THEN
         x_show_ct_wt := 1;
     ELSE
         x_show_ct_wt := 0;
     END IF;
  l_progress := '70';
     x_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;
END SHOW_CT_WT_FOR_SPLIT;


FUNCTION IS_CT_WT_SPLIT_VALID (
  p_org_id               IN         NUMBER
, p_from_lpn_id          IN         NUMBER
, p_from_item_id         IN         NUMBER
, p_from_item_revision   IN         VARCHAR2
, p_from_item_lot_number IN         VARCHAR2
, p_from_item_pri_qty    IN         NUMBER
, p_from_item_pri_uom    IN         VARCHAR2
, p_from_item_sec_qty    IN         NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_data             OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
) RETURN NUMBER IS

CURSOR itemCur IS
       SELECT sum(inv_convert.inv_um_convert(wdd.inventory_item_id,
                                         6,
                                         wdd.REQUESTED_QUANTITY,
                                         wdd.REQUESTED_QUANTITY_UOM,
                                         --msib.primary_uom_code,
                                         p_from_item_pri_uom,
                                         NULL,
                                         NULL)) requested_quantity,
              sum(picked_quantity2) picked_quantity2,
              msib.primary_uom_code
       FROM wsh_delivery_details wdd,
            mtl_system_items_b msib
       WHERE wdd.inventory_item_id = p_from_item_id
       AND   wdd.inventory_item_id = msib.inventory_item_id
       AND   wdd.organization_id   = p_org_id
       AND   wdd.organization_id   = msib.organization_id
       AND    NVL(wdd.revision,'@@@') = NVL(p_from_item_revision,'@@@')
       AND    NVL(wdd.lot_number,'@@@') = NVL(p_from_item_lot_number,'@@@')
       AND   wdd.delivery_detail_id in (SELECT wda.delivery_detail_id
                                        FROM   wsh_delivery_assignments_v wda,
                                               wsh_delivery_Details wdd1
                                        WHERE  wdd1.lpn_id = p_from_lpn_id
					AND    wdd1.released_status = 'X'  -- For LPN reuse ER : 6845650
                                        AND    wdd1.delivery_detail_id = wda.parent_delivery_Detail_id
                                        AND    wdd1.organization_id = p_org_id)
       GROUP BY wdd.inventory_item_id, wdd.revision, wdd.lot_number, msib.primary_uom_code;

   l_progress VARCHAR2(20) := '0';
   l_api_name    CONSTANT VARCHAR2(30) := 'IS_CT_WT_SPLIT_VALID';
   l_api_version CONSTANT NUMBER       := 1.0;
   l_debug NUMBER  := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_pri_qty NUMBER := 0;
   l_sec_Qty NUMBER := 0;
   l_pri_remaining_qty NUMBER := 0;
   l_sec_remaining_qty NUMBER := 0;
   l_pri_input_qty NUMBER := 0;
   L_PRI_QTY_DIFF NUMBER := 0;
   L_SEC_QTY_DIFF NUMBER := 0;
   RETURNTOLERANCE NUMBER := 0;
   first_time BOOLEAN := TRUE;

   itemRec itemCur%ROWTYPE;

BEGIN

   IF ( l_debug = 1 ) THEN
       print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
       print_debug('p_org_id   => ' || p_org_id||' fromlpn '||p_from_lpn_id||' fromItem =>'||p_from_item_id||' rev =>'||p_from_item_revision  , 4);
       print_debug('p_from_lot_number => ' || p_from_item_lot_number||'pri uom =>'||p_from_item_pri_uom, 4);
   END IF;

   l_progress := '10';

   /**l_pri_input_qty := inv_convert.inv_um_convert(p_from_item_id,
                                         6,
                                         p_from_item_pri_qty,
                                         p_from_item_pri_uom,
                                         p_from_item_pri_uom,
                                         NULL,
                                         NULL);
  **/
   l_progress := '20';

    OPEN itemCur;
        LOOP
           FETCH itemCur into itemRec;
           EXIT WHEN itemCur%NOTFOUND;
           l_pri_input_qty := p_from_item_pri_qty;

           l_pri_qty_diff := itemRec.requested_quantity - l_pri_input_qty ;
           l_sec_qty_diff := itemRec.picked_quantity2 - p_from_item_sec_qty;
           IF ( l_debug = 1 ) THEN
                  print_debug('Inside Loop l_pri_qty_diff=>'||l_pri_qty_diff||' l_sec_qty_diff =>'||l_sec_qty_diff||' l_pri_input_qty =>'||l_pri_input_qty||' p_from_item_sec_qty =>'||p_from_item_sec_qty, 4);
           END IF;

        END LOOP;
      CLOSE itemCur;

/*

    FOR itemCur in itemRec LOOP

       --l_pri_qty_diff := itemRec.requested_quantity - l_pri_input_qty ;
       l_pri_qty_diff := itemRec.requested_quantity - l_pri_input_qty ;
       l_sec_qty_diff := itemRec.picked_quantity2 - p_from_item_sec_qty;
   l_progress := '30';

    END LOOP;
*/

   IF (l_pri_qty_diff = 0) THEN
     /** This means, entire qty was split, there is no remaining qty
      ** so there is no need for further check..this is a valid split
      **/
      RETURN 1;
   END IF;
   l_progress := '40';

   IF (l_pri_qty_diff < 0) THEN
     /** This condition should not occur, this is an error condition
      **/
      RETURN 0;
   END IF;
   l_progress := '50';

   IF (l_pri_qty_diff > 0) THEN
      /**This is a valid condition, now we need to check the
       ** tolerance for the sec_qty_diff
       **/

   l_progress := '60';
       returnTolerance := Check_Secondary_Qty_Tolerance (
                            p_api_version => 1
                          , p_init_msg_list => fnd_api.g_false
                          , x_return_status => x_return_status
                          , x_msg_count => x_msg_count
                          , x_msg_data  => x_msg_data
                          , p_organization_id => p_org_id
                          , p_inventory_item_id => p_from_item_id
                          , p_quantity => l_pri_qty_diff
                          , p_uom_code => p_from_item_pri_uom
                          , p_secondary_quantity => l_sec_qty_diff);

   l_progress := '70';
       if (returnTolerance = 0) THEN
          RETURN 1;
       else
          RETURN 0;
       end if;
   l_progress := '80';
   END IF;
  /**
   EXCEPTION
        WHEN OTHERS THEN
            IF (l_debug = 1) THEN
                print_debug(l_api_name ||' Error l_progress=' || l_progress, 1);
                IF ( SQLCODE IS NOT NULL ) THEN
                    print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
                END IF;
            END IF;
 **/

END IS_CT_WT_SPLIT_VALID;

FUNCTION VALIDATE_CT_WT_FOR_DELIVERYNUM(
  p_api_version      IN         NUMBER
, p_init_msg_list    IN         VARCHAR2 := fnd_api.g_false
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
, p_org_id           IN         NUMBER
, p_delivery_name    IN         VARCHAR2
)RETURN NUMBER AS

   CURSOR wddCur IS
          SELECT wdd.delivery_Detail_id,
                 wdd.inventory_item_id,
                 wdd.organization_id,
                 wdd.picked_quantity,
                 wdd.picked_quantity2,
                 msi.primary_uom_code,
                 msi.secondary_uom_code,
                 msi.secondary_default_ind
          FROM   wsh_delivery_Details wdd,
                 mtl_system_items msi
          WHERE  wdd.delivery_detail_id in
                       (SELECT wda.delivery_detail_id
                        FROM   wsh_delivery_assignments_v wda,
                               wsh_new_deliveries wnd
                        WHERE  wda.delivery_id = wnd.delivery_id
                        AND    wnd.name = p_delivery_name
                        AND    wda. PARENT_DELIVERY_DETAIL_ID is not NULL)
          AND    picked_quantity2 is null
          AND    wdd.inventory_item_id = msi.inventory_item_id
          AND    wdd.inventory_item_id is not null
          AND    wdd.organization_id = msi.organization_id
          AND    msi.ont_pricing_qty_source = 'S';

   l_progress VARCHAR2(20) := '0';
   l_api_name    CONSTANT VARCHAR2(30) := 'VALIDATE_CT_WT_FOR_DELIVERYNUM';
   l_api_version CONSTANT NUMBER       := 1.0;
   l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_uom_conv_rate NUMBER;
   l_return           NUMBER := G_CHECK_SUCCESS;

BEGIN


   -- Standard call to check for call compatibility.
   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
   END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status  := fnd_api.g_ret_sts_success;


   IF ( l_debug = 1 ) THEN
    print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
    print_debug('p_org_id   => '|| p_org_id||' p_delivery_number=>'||p_delivery_name , 4);
   END IF;

   l_progress := '100';


        FOR item_rec IN wddCur LOOP

          IF ( l_debug = 1 ) THEN
              print_debug('p_org_id   => ' || item_rec.organization_id||' p_inv_item_id => '||item_rec.inventory_item_id||' del_detail_id => '||item_rec.delivery_Detail_id , 4);
          END IF;

          l_progress := '200';

          IF (item_rec.secondary_default_ind = G_SECONDARY_DEFAULT AND item_rec.picked_quantity2 IS NULL) THEN

            --call the defaulting logic and see if the return < 0

               INV_CONVERT.inv_um_conversion (
                            from_unit => item_rec.primary_uom_code
                          , to_unit   => item_rec.secondary_uom_code
                          , item_id   => item_rec.inventory_item_id
                          , uom_rate  => l_uom_conv_rate );

               l_progress := '300';

               IF ( l_debug = 1 ) THEN
                   print_debug('from_unit   => ' ||item_rec.primary_uom_code||' to_unit => '||item_rec.secondary_uom_code||' item_id => '||item_rec.inventory_item_id||' uom_rate =>'||l_uom_conv_rate , 4);
               END IF;

               IF ( l_uom_conv_rate < 0 ) THEN
                -- no valid connection uom conversion between these two uoms
                   l_return := G_CHECK_ERROR;
                   fnd_message.set_name('WMS', 'WMS_CTWT_DEFAULT_ERROR');
                   fnd_msg_pub.ADD;
                   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
               ELSE
                -- there is a valid conversion, change status to warning
                   l_return := G_CHECK_WARNING;
               END IF;
          ELSE
               IF (item_rec.secondary_default_ind = G_SECONDARY_NO_DEFAULT AND item_rec.picked_quantity2 IS NULL) THEN
                   l_return := G_CHECK_ERROR;
                   fnd_message.set_name('WMS', 'WMS_CTWT_DEFAULT_ERROR');
                   fnd_msg_pub.ADD;
                   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
               END IF;

          END IF;

          l_progress := '400';

        END LOOP;


          l_progress := '500';

        RETURN l_return;

EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      print_debug(l_api_name ||' Error l_progress=' || l_progress, 1);
      IF ( SQLCODE IS NOT NULL ) THEN
        print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
      END IF;
    END IF;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('WMS', 'WMS_CALC_SEC_QTY_FAIL');
    fnd_msg_pub.ADD;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END VALIDATE_CT_WT_FOR_DELIVERYNUM;

END WMS_CATCH_WEIGHT_PVT;

/
