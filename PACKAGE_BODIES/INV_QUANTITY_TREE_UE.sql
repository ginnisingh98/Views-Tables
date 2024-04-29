--------------------------------------------------------
--  DDL for Package Body INV_QUANTITY_TREE_UE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_QUANTITY_TREE_UE" AS
  /* $Header: INVQTUEB.pls 120.2.12010000.3 2009/04/28 15:35:27 adeshmuk ship $*/

g_debug                         NUMBER := NULL;
PROCEDURE print_debug(p_message IN VARCHAR2, p_level IN NUMBER DEFAULT 14) IS
BEGIN
   IF g_debug IS NULL THEN
      g_debug :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   IF (g_debug = 1) THEN
      inv_log_util.trace(p_message, 'INV_QUANTITY_TREE_UE', p_level);
   END IF;
END;

-- bug 4104123 : replace p_demand_header_type default NULL by 0
FUNCTION create_tree(p_organization_id IN NUMBER,
		     p_inventory_item_id IN NUMBER,
		     p_revision_control IN NUMBER DEFAULT 1,
		     p_lot_control IN NUMBER DEFAULT 1,
		     p_serial_control IN NUMBER DEFAULT 1,
		     p_lot_active IN NUMBER DEFAULT 2,
		     p_demand_header_id IN NUMBER DEFAULT NULL,
		     p_demand_header_type IN NUMBER,
		     p_tree_mode IN NUMBER DEFAULT 3,         --2 replaced by 3 for bug7038890
		     p_negative_inv_allowed IN NUMBER DEFAULT 0,
		     p_lot_expiration_date IN DATE DEFAULT NULL,
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
		     RETURN NUMBER
  IS

l_QTY                  NUMBER;
l_grade_code           VARCHAR2(150) := NULL;
l_available_quantity2  NUMBER := NULL;
l_onhand_quantity2     NUMBER := NULL;
BEGIN
-- invConv changes begin : calling the overloaded function :
l_QTY := create_tree( p_organization_id         => p_organization_id
		    , p_inventory_item_id       => p_inventory_item_id
		    , p_revision_control        => p_revision_control
		    , p_lot_control             => p_lot_control
		    , p_serial_control          => p_serial_control
		    , p_grade_code              => l_grade_code
		    , p_lot_active              => p_lot_active
		    , p_demand_header_id        => p_demand_header_id
		    , p_demand_header_type      => p_demand_header_type
		    , p_tree_mode               => p_tree_mode
		    , p_negative_inv_allowed    => p_negative_inv_allowed
		    , p_lot_expiration_date     => p_lot_expiration_date
		    , p_activate                => p_activate
		    , p_uom_code                => p_uom_code
		    , p_asset_subinventory_only => p_asset_subinventory_only
		    , p_demand_source_name      => p_demand_source_name
		    , p_demand_source_line_id   => p_demand_source_line_id
		    , p_demand_source_delivery  => p_demand_source_delivery
		    , p_rev_active              => p_rev_active
		    , x_available_quantity      => x_available_quantity
		    , x_available_quantity2     => l_available_quantity2
		    , x_onhand_quantity         => x_onhand_quantity
		    , x_onhand_quantity2        => l_onhand_quantity2
		    , x_return_status           => x_return_status
		    , x_message_count           => x_message_count
		    , x_message_data            => x_message_data
		    , p_lpn_id                   => p_lpn_id); --added for bug7038890
-- invConv changes end.

RETURN l_QTY;

END create_tree;

-- invConv changes begin : overloaded version of create_tree:
-- bug 4104123 : replace p_demand_header_type default NULL by 0
FUNCTION create_tree( p_organization_id         IN NUMBER
		    , p_inventory_item_id       IN NUMBER
		    , p_revision_control        IN NUMBER DEFAULT 1
		    , p_lot_control             IN NUMBER DEFAULT 1
		    , p_serial_control          IN NUMBER DEFAULT 1
		    , p_grade_code              IN VARCHAR2 DEFAULT NULL      -- invConv change
		    , p_lot_active              IN NUMBER DEFAULT 2
		    , p_demand_header_id        IN NUMBER DEFAULT NULL
		    , p_demand_header_type      IN NUMBER DEFAULT 0
		    , p_tree_mode               IN NUMBER DEFAULT 3           --2 replaced by 3 for bug7038890
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
		    RETURN NUMBER
IS
     l_tree_id INTEGER := NULL;
     l_tree_mode NUMBER := NULL;
     l_return_status varchar2(1) := fnd_api.g_ret_sts_success;
     l_msg_data VARCHAR2(2000) := NULL;
     l_msg_count NUMBER := NULL;
     l_is_revision_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_asset_sub_only  BOOLEAN := FALSE;
     l_include_suggestion BOOLEAN := TRUE;
     l_expiration_date DATE := NULL;
     l_onhand_source NUMBER := NULL;
     l_qoh NUMBER := NULL;
     l_rqoh NUMBER := NULL;
     l_qr NUMBER := NULL;
     l_qs NUMBER := NULL;
     l_att NUMBER := NULL;
     l_atr NUMBER := NULL;
     l_sqoh NUMBER := NULL;                        -- invConv change
     l_srqoh NUMBER := NULL;                       -- invConv change
     l_sqr NUMBER := NULL;                         -- invConv change
     l_sqs NUMBER := NULL;                         -- invConv change
     l_satt NUMBER := NULL;                        -- invConv change
     l_satr NUMBER := NULL;                        -- invConv change
     l_available_quantity NUMBER := NULL;
     l_available_quantity2 NUMBER := NULL;         -- invConv change
     l_onhand_quantity NUMBER := NULL;
     l_onhand_quantity2 NUMBER := NULL;            -- invConv change
     l_available_conv_quantity NUMBER := NULL;
     l_onhand_conv_quantity NUMBER := NULL;
     l_primary_uom_code VARCHAR2(3) := NULL;

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_demand_header_type NUMBER;
BEGIN

   IF (l_debug = 1) then
      print_debug('New profile value INV_MATERIAL_STATUS ='||NVL(FND_PROFILE.VALUE('INV_MATERIAL_STATUS'),'x') );
      print_debug('Create_tree Inputs Org:'||p_organization_id||'itm:'||p_inventory_item_id||
		  'RevCtrl:'||p_revision_control||'LotCtrl:'||p_lot_control||
		  'SerCtrl:'||p_serial_control||'LotAct:'||p_lot_active);
      print_debug('DHdrId:'||p_demand_header_id||'DHdrTyp:'||p_demand_header_type||
		  'TMode:'||p_tree_mode||'NegInv:'||p_negative_inv_allowed||
		  'LExpDate:'||p_lot_expiration_date||'Act:'||p_activate||
		  'UOM:'||p_uom_code||'AssetOnly:'||p_asset_subinventory_only);
      print_debug('DSName:'||p_demand_source_name||'DSLine:'||p_demand_source_line_id||
		  'DSDel:'||p_demand_source_delivery||'RevAct:'||p_rev_active);
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

-- bug 4104123 : I don't know why the default of p_demand_header_type doesnt work.
l_demand_header_type := p_demand_header_type;
if p_demand_header_type IS NULL
THEN
   IF (l_debug = 1) then
     print_debug('... p_demand_header_type IS NULL... reset to 0');
   END IF;
  l_demand_header_type := 0;
ELSE
   IF (l_debug = 1) then
     print_debug('... p_demand_header_type IS NOT NULL... ');
   END IF;
END IF;

    --start changes for bug7038890
   -- l_tree_mode := inv_quantity_tree_pvt.g_loose_only_mode;--??????????????
     IF p_lpn_id IS NOT NULL THEN
      l_tree_mode := 2;
     ELSE
     l_tree_mode := inv_quantity_tree_pvt.g_loose_only_mode;
     END IF;
    --end changes for bug7038890

   IF p_activate <> 1 THEN
      x_available_quantity := 0;
      x_onhand_quantity := 0;
      RETURN 1;
   END IF;

   IF p_lot_control NOT IN (g_lot_control,g_no_lot_control) THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_LOT_CTRL_OPTION');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- invConv removed this test : serial_control can have other values.
   -- IF p_serial_control NOT IN (g_serial_control,g_no_serial_control) THEN
   --    FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SER_CTRL_OPTION');
   --    FND_MSG_PUB.ADD;
   --    RAISE FND_API.G_EXC_ERROR;
   -- END IF;

   IF p_rev_active = g_no_rev_ctrl_please THEN
      l_is_revision_control := FALSE;
    ELSIF p_rev_active = g_want_rev_ctrl then
      l_is_revision_control := TRUE;
    ELSE
      IF p_revision_control = g_no_rev_control THEN
	 l_is_revision_control := FALSE;
       ELSE
	 l_is_revision_control := TRUE;
      END IF;
   END IF;

   IF p_lot_active = g_no_lot_ctrl_please THEN
      l_is_lot_control := FALSE;
    ELSIF p_lot_active = g_want_lot_ctrl then
      l_is_lot_control := TRUE;
    ELSE
      IF p_lot_control = g_no_lot_control THEN
	 l_is_lot_control := FALSE;
       ELSE
	 l_is_lot_control := TRUE;
      END IF;
   END IF;

   IF p_asset_subinventory_only = g_asset_subinvs THEN
      l_asset_sub_only := TRUE;
    ELSE
      l_asset_sub_only := FALSE;
   END IF;

   l_onhand_source := inv_quantity_tree_pvt.g_all_subs;

   l_expiration_date := NULL;--???????

   IF p_serial_control = g_no_serial_control THEN
      l_is_serial_control := FALSE;
    ELSE
      l_is_serial_control := TRUE;
   END IF;

   l_include_suggestion := TRUE;

   IF (l_debug = 1) then
      print_debug('Calling inv_quantity_tree_pvt.create_tree');
   END IF;

   inv_quantity_tree_pvt.create_tree
     (
      p_api_version_number 	   => 1.0,
      p_init_msg_lst       	   => fnd_api.g_true,
      x_return_status      	   => l_return_status,
      x_msg_count          	   => l_msg_count,
      x_msg_data           	   => l_msg_data,
      p_organization_id    	   => p_organization_id,
      p_inventory_item_id  	   => p_inventory_item_id,
      p_tree_mode          	   => l_tree_mode,
      p_is_revision_control        => l_is_revision_control,
      p_is_lot_control             => l_is_lot_control,
      p_is_serial_control          => l_is_serial_control,
      p_grade_code                 => p_grade_code,                 -- invConv change
      p_asset_sub_only             => l_asset_sub_only,
      p_include_suggestion         => l_include_suggestion,
      p_demand_source_type_id      => l_demand_header_type,
      p_demand_source_header_id    => p_demand_header_id,
      p_demand_source_line_id      => p_demand_source_line_id,
      p_demand_source_name         => p_demand_source_name,
      p_demand_source_delivery     => p_demand_source_delivery,
      p_lot_expiration_date        => l_expiration_date,
      p_onhand_source	           => l_onhand_source,
      x_tree_id                    => l_tree_id
      );

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      IF (l_debug = 1) then
	 print_debug('Error from inv_quantity_tree_pvt.create_tree');
	 print_debug('l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data);
      END IF;
      FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_CREATE_TREE');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Tree_id:'||l_tree_id);
      print_debug('Calling inv_quantity_tree_pvt.query_tree');
   END IF;

   inv_quantity_tree_pvt.query_tree
     (
      p_api_version_number   => 1.0,
      p_init_msg_lst         => fnd_api.g_true,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data,
      p_tree_id              => l_tree_id,
      p_revision             => NULL,
      p_lot_number           => NULL,
      p_subinventory_code    => NULL,
      p_locator_id           => NULL,
      x_qoh                  => l_qoh,
      x_rqoh                 => l_rqoh,
      x_qr                   => l_qr,
      x_qs                   => l_qs,
      x_att                  => l_att,
      x_atr                  => l_atr,
      x_sqoh                 => l_sqoh,      -- invConv change
      x_srqoh                => l_srqoh,     -- invConv change
      x_sqr                  => l_sqr,       -- invConv change
      x_sqs                  => l_sqs,       -- invConv change
      x_satt                 => l_satt,      -- invConv change
      x_satr                 => l_satr       -- invConv change
      );

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      IF (l_debug = 1) then
	 print_debug('Error from inv_quantity_tree_pvt.query_tree');
	 print_debug('l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data);
      END IF;
      FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_QUERY_TREE');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Primary Qties : l_qoh:'||l_qoh||'l_rqoh:'||l_rqoh||'l_qr:'||l_qr||
		  'l_qs:'||l_qs||'l_att:'||l_att||'l_atr:'||l_atr);
      print_debug('Secondary Qties : l_sqoh:'||l_sqoh||'l_srqoh:'||l_srqoh||'l_sqr:'||l_sqr||
		  'l_sqs:'||l_sqs||'l_satt:'||l_satt||'l_satr:'||l_satr);
   END IF;

   IF l_tree_mode IN (inv_quantity_tree_pvt.g_transaction_mode,
		      inv_quantity_tree_pvt.g_loose_only_mode) THEN
      l_available_quantity := l_att;
      l_available_quantity2 := l_satt;    -- invConv change
    ELSE
      l_available_quantity := l_atr;
      l_available_quantity2 := l_satr;    -- invConv change
   END IF;

   l_onhand_quantity := l_qoh;
   l_onhand_quantity2 := l_sqoh;          -- invConv change

   --UOM Conversion
   IF p_uom_code IS NOT NULL THEN
      BEGIN
	 SELECT Primary_Uom_Code
	   INTO l_primary_uom_code
	   FROM MTL_SYSTEM_ITEMS
	   WHERE Organization_Id = p_organization_id
	   AND   Inventory_Item_Id = p_inventory_item_id;
      EXCEPTION
	 WHEN no_data_found THEN
	    IF (l_debug = 1) THEN
	       print_debug('Primary UOM not found');
	    END IF;
	    FND_MESSAGE.SET_NAME('INV', 'INV_NO_PRIMARY_UOM');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
      END;

      IF (l_debug = 1) THEN
	 print_debug('l_primary_uom_code'||l_primary_uom_code);
      END IF;

      IF p_uom_code <> l_primary_uom_code THEN
	 l_available_conv_quantity := inv_convert.inv_um_convert
	   (item_id => p_inventory_item_id,
	    precision => NULL,
	    from_quantity => Abs(l_available_quantity),
	    from_unit => l_primary_uom_code,
	    to_unit   => p_uom_code,
	    from_name => null,
	    to_name   => NULL
	    );
	 IF l_available_conv_quantity < 0 THEN
	    IF (l_debug = 1) THEN
	       print_debug('Error converting l_available_quantity');
	    END IF;
	    FND_MESSAGE.SET_NAME('INV', 'INV_UOM_CANNOT_CONVERT');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 IF l_available_quantity < 0 THEN
	    l_available_quantity := 0 - l_available_conv_quantity;
         ELSE
	    l_available_quantity := l_available_conv_quantity;
	 END IF;
         IF (l_debug = 1) then
           print_debug('1 conversion result: qty='||l_available_quantity||', convQ='||l_available_conv_quantity);
         END IF;

	 l_onhand_conv_quantity := inv_convert.inv_um_convert
	   (item_id => p_inventory_item_id,
	    precision => NULL,
	    from_quantity => Abs(l_onhand_quantity),
	    from_unit => l_primary_uom_code,
	    to_unit   => p_uom_code,
	    from_name => null,
	    to_name   => NULL
	    );
	 IF l_onhand_conv_quantity < 0 THEN
	    IF (l_debug = 1) THEN
	       print_debug('Error converting l_onhand_quantity');
	    END IF;
	    FND_MESSAGE.SET_NAME('INV', 'INV_UOM_CANNOT_CONVERT');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 IF l_onhand_quantity < 0 THEN
	    l_onhand_quantity := 0 - l_onhand_conv_quantity;
         ELSE
	    l_onhand_quantity := l_onhand_conv_quantity;
	 END IF;
         IF (l_debug = 1) then
           print_debug('2 conversion result: qty='||l_onhand_quantity||', convQ='||l_onhand_conv_quantity);
         END IF;
      END IF;
   END IF;

   x_available_quantity := ROUND(l_available_quantity, 5);
   x_available_quantity2 := ROUND(l_available_quantity2, 5);     -- invConv change
   x_onhand_quantity := ROUND(l_onhand_quantity, 5);
   x_onhand_quantity2 := ROUND(l_onhand_quantity2, 5);           -- invConv change

   IF (l_debug = 1) THEN
      print_debug('returning x_return_status:'||x_return_status||
		  'x_available_quantity='||x_available_quantity||
		  'x_onhand_quantity='||x_onhand_quantity||
		  'x_available_quantity2='||x_available_quantity2||
		  'x_onhand_quantity2='||x_onhand_quantity2);
   END IF;

   RETURN 1;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN

      IF (l_debug = 1) THEN
	 print_debug('fnd_api.g_exc_error');
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      x_available_quantity := 0;
      x_onhand_quantity := 0;

      fnd_msg_pub.count_and_get
	(  p_count => x_message_count
	   , p_data  => x_message_data
	   );

      IF (l_debug = 1) THEN
	 FOR i IN 1 .. x_message_count LOOP
	    print_debug(fnd_msg_pub.get(x_message_count - i + 1, 'F'));
	 END LOOP;
      END IF;

      RETURN 0;

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('OTHERS error');
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  'INV_QUANTITY_TREE_UE'
              ,'CREATE_TREE'
              );
      END IF;

      x_available_quantity := 0;
      x_onhand_quantity := 0;

      fnd_msg_pub.count_and_get
	(  p_count => x_message_count
	   , p_data  => x_message_data
	   );
      IF (l_debug = 1) THEN
	 FOR i IN 1 .. x_message_count LOOP
	    print_debug(fnd_msg_pub.get(x_message_count - i + 1, 'F'));
	 END LOOP;
      END IF;

      RETURN 0;
END create_tree;

-- bug 4104123 : replace p_demand_header_type default NULL by 0
FUNCTION query_tree(p_organization_id IN NUMBER,
		    p_inventory_item_id IN NUMBER,
		    p_revision_control IN NUMBER DEFAULT 1,
		    p_lot_control IN NUMBER DEFAULT 1,
		    p_serial_control IN NUMBER DEFAULT 1,
		    p_demand_header_id IN NUMBER default NULL,
		    p_demand_header_type IN NUMBER,
		    p_revision in varchar2 default NULL,
		    p_lot in varchar2 default NULL,
		    p_lot_expiration_date IN DATE default NULL,
		    p_subinventory IN varchar2 default NULL,
		    p_locator in NUMBER default NULL,
		    p_transfer_subinventory VARCHAR2 default NULL,
		    p_transaction_quantity in NUMBER default 0,
		    p_uom_code in varchar2 default NULL,
		    P_lot_active IN NUMBER default 2,
		    P_activate IN NUMBER default 1,
		    P_tree_mode In NUMBER Default 3,     --2 replaced by 3 for bug7038890
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
  P_lpn_id       IN NUMBER DEFAULT NULL         --added for bug7038890
  ) RETURN NUMBER IS

l_QTY                   NUMBER;
l_available_onhand2     NUMBER;
l_available_quantity2   NUMBER;
l_onhand_quantity2      NUMBER;
l_transaction_quantity2 NUMBER;
BEGIN
-- invConv change : Calling the overloaded query_tree :
l_QTY := query_tree( p_organization_id        => p_organization_id
		   , p_inventory_item_id      => p_inventory_item_id
		   , p_revision_control       => p_revision_control
		   , p_lot_control            => p_lot_control
		   , p_serial_control         => p_serial_control
		   , p_demand_header_id       => P_demand_header_id
		   , p_demand_header_type     => p_demand_header_type
		   , p_revision               => P_revision
		   , p_lot                    => P_lot
		   , p_lot_expiration_date    => P_lot_expiration_date
		   , p_subinventory           => P_subinventory
		   , p_locator                => P_locator
		   , p_transfer_subinventory  => P_transfer_subinventory
		   , p_transaction_quantity   => P_transaction_quantity
		   , p_uom_code               => P_uom_code
		   , p_transaction_quantity2  => l_transaction_quantity2      -- invConv change.
		   , p_lot_active             => P_lot_active
		   , p_activate               => P_activate
		   , p_tree_mode              => P_tree_mode
		   , P_demand_source_name     => P_demand_source_name
		   , P_demand_source_line_id  => P_demand_source_line_id
		   , P_demand_source_delivery => P_demand_source_delivery
		   , P_rev_active             => P_rev_active
		   , X_available_onhand       => X_available_onhand
                   , X_available_quantity     => X_available_quantity
                   , X_onhand_quantity        => X_onhand_quantity
		   , X_available_onhand2      => l_available_onhand2         -- invConv change
                   , X_available_quantity2    => l_available_quantity2       -- invConv change
                   , X_onhand_quantity2       => l_onhand_quantity2          -- invConv change
                   , X_return_status          => X_return_status
                   , X_message_count          => X_message_count
                   , X_message_data           => X_message_data
		   , P_lpn_id                 => P_lpn_id);                 --added for bug7038890

RETURN l_QTY;
-- invConv changes end.
END query_tree;

-- invConv changes begin : overloaded query_tree
-- bug 4104123 : replace p_demand_header_type default NULL by 0
FUNCTION query_tree( p_organization_id        IN NUMBER
		   , p_inventory_item_id      IN NUMBER
		   , p_revision_control       IN NUMBER DEFAULT 1
		   , p_lot_control            IN NUMBER DEFAULT 1
		   , p_serial_control         IN NUMBER DEFAULT 1
		   , P_demand_header_id       IN NUMBER DEFAULT NULL
		   , p_demand_header_type     IN NUMBER DEFAULT 0
		   , P_revision               in VARCHAR2 DEFAULT NULL
		   , P_lot                    in VARCHAR2 DEFAULT NULL
		   , P_lot_expiration_date    IN DATE DEFAULT NULL
		   , P_subinventory           IN VARCHAR2 DEFAULT NULL
		   , P_locator                in NUMBER DEFAULT NULL
		   , P_transfer_subinventory  IN VARCHAR2 DEFAULT NULL
		   , P_transaction_quantity   IN NUMBER DEFAULT 0
		   , P_uom_code               IN VARCHAR2 DEFAULT NULL
		   , P_transaction_quantity2  IN NUMBER DEFAULT NULL           -- invConv change.
		   , P_lot_active             IN NUMBER DEFAULT 2
		   , P_activate               IN NUMBER DEFAULT 1
		   , P_tree_mode              IN NUMBER DEFAULT 3              --2 replaced by 3 for bug7038890
		   , P_demand_source_name     IN VARCHAR2 DEFAULT NULL
		   , P_demand_source_line_id  IN NUMBER DEFAULT NULL
		   , P_demand_source_delivery IN NUMBER DEFAULT NULL
		   , P_rev_active             IN NUMBER DEFAULT 2
		   , X_available_onhand       OUT NOCOPY NUMBER
                   , X_available_quantity     OUT NOCOPY NUMBER
                   , X_onhand_quantity        OUT NOCOPY NUMBER
		   , X_available_onhand2      OUT NOCOPY NUMBER                     -- invConv change
                   , X_available_quantity2    OUT NOCOPY NUMBER                     -- invConv change
                   , X_onhand_quantity2       OUT NOCOPY NUMBER                     -- invConv change
                   , X_return_status          OUT NOCOPY VARCHAR2
                   , X_message_count          OUT NOCOPY NUMBER
                   , X_message_data           OUT NOCOPY VARCHAR2
		   , P_lpn_id                 IN  NUMBER DEFAULT NULL            --added for bug7038890
		   ) RETURN NUMBER
IS
     l_tree_id INTEGER := NULL;
     l_tree_mode NUMBER := NULL;
     l_return_status varchar2(1) := fnd_api.g_ret_sts_success;
     l_msg_data VARCHAR2(2000) := NULL;
     l_msg_count NUMBER := NULL;
     l_is_revision_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_asset_sub_only  BOOLEAN := FALSE;
     l_include_suggestion BOOLEAN := TRUE;
     l_expiration_date DATE := NULL;
     l_onhand_source NUMBER := NULL;
     l_qoh NUMBER := NULL;
     l_rqoh NUMBER := NULL;
     l_qr NUMBER := NULL;
     l_qs NUMBER := NULL;
     l_att NUMBER := NULL;
     l_atr NUMBER := NULL;
     l_sqoh NUMBER := NULL;       -- invConv change
     l_srqoh NUMBER := NULL;      -- invConv change
     l_sqr NUMBER := NULL;        -- invConv change
     l_sqs NUMBER := NULL;        -- invConv change
     l_satt NUMBER := NULL;       -- invConv change
     l_satr NUMBER := NULL;       -- invConv change

     l_available_quantity NUMBER := NULL;
     l_onhand_quantity NUMBER := NULL;
     l_avail_qoh NUMBER := NULL;
     l_available_quantity2 NUMBER := NULL;   -- invConv change
     l_onhand_quantity2 NUMBER := NULL;      -- invConv change
     l_avail_qoh2 NUMBER := NULL;            -- invConv change
     l_available_conv_quantity NUMBER := NULL;
     l_onhand_conv_quantity NUMBER := NULL;
     l_avail_qoh_conv_quantity NUMBER := NULL;
     l_original_avail_qoh NUMBER := NULL;
     l_original_avail_qoh2 NUMBER := NULL;      -- invConv change
     l_locator_id  NUMBER := NULL;
     l_dyn_loc BOOLEAN := FALSE;
     l_tqoh NUMBER := NULL;
     l_stqoh NUMBER := NULL;                    -- invConv change
     l_transaction_quantity NUMBER := NULL;
     l_transaction_quantity2 NUMBER := NULL;       -- invConv change
     l_transaction_conv_quantity NUMBER := NULL;
     l_primary_uom_code VARCHAR2(3) := NULL;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

l_lot_control NUMBER;
CURSOR get_item_details( org_id IN NUMBER
                       , item_id IN NUMBER) IS
SELECT NVL(lot_control_code, 1)
FROM mtl_system_items
WHERE inventory_item_id = item_id
AND organization_id = org_id;

l_demand_header_type  NUMBER;
BEGIN

   IF (l_debug = 1) then
      print_debug('query_tree Inputs Org:'||p_organization_id||'itm:'||p_inventory_item_id||
		  'RevCtrl:'||p_revision_control||'LotCtrl:'||p_lot_control||
		  'SerCtrl:'||p_serial_control||'LotAct:'||p_lot_active);
      print_debug('DHdrId:'||p_demand_header_id||'DHdrTyp:'||p_demand_header_type||
		  'TMode:'||p_tree_mode||'Rev:'||p_revision||'Lot:'||p_lot||
		  'LExpDate:'||p_lot_expiration_date||'Act:'||p_activate);
      print_debug('UOM:'||p_uom_code||'sub:'||p_subinventory||'Loc:'||p_locator||
		  'XSub:'||p_transfer_subinventory||'TxnQty:'||p_transaction_quantity||
		  'DSName:'||p_demand_source_name||'DSLine:'||p_demand_source_line_id||
		  'DSDel:'||p_demand_source_delivery||'RevAct:'||p_rev_active);
   END IF;

-- bug 4104123 : I don't know why the default of p_demand_header_type doesnt work.
l_demand_header_type := p_demand_header_type;
if p_demand_header_type IS NULL
THEN
  IF (l_debug = 1) then
    print_debug('... p_demand_header_type IS NULL... reset to 0');
  END IF;
  l_demand_header_type := 0;
ELSE
   IF (l_debug = 1) then
     print_debug('... p_demand_header_type IS NOT NULL... ');
   END IF;
END IF;

   x_return_status := fnd_api.g_ret_sts_success;

   IF p_activate <> 1 THEN
      x_available_quantity := 0;
      x_available_onhand := 0;
      x_onhand_quantity := 0;
      RETURN 1;
   END IF;

  --start changes for bug7038890
  -- l_tree_mode := inv_quantity_tree_pvt.g_loose_only_mode;--??????????????
    IF p_lpn_id IS NOT NULL
    THEN
    l_tree_mode := 2;
    else
    l_tree_mode := inv_quantity_tree_pvt.g_loose_only_mode;
    END IF ;
  --end changes for bug7038890

   IF p_locator = -1 THEN
      l_locator_id := NULL;
      l_dyn_loc := TRUE;
    ELSE
      l_locator_id := p_locator;
   END IF;

   IF p_rev_active = g_no_rev_ctrl_please THEN
      l_is_revision_control := FALSE;
    ELSIF p_rev_active = g_want_rev_ctrl then
      l_is_revision_control := TRUE;
    ELSE
      IF p_revision_control = g_no_rev_control THEN
	 l_is_revision_control := FALSE;
       ELSE
	 l_is_revision_control := TRUE;
      END IF;
   END IF;

   IF p_lot_active = g_no_lot_ctrl_please THEN
      l_is_lot_control := FALSE;
    ELSIF p_lot_active = g_want_lot_ctrl then
      l_is_lot_control := TRUE;
    ELSE
      IF p_lot_control = g_no_lot_control THEN
	 l_is_lot_control := FALSE;
       ELSE
	 l_is_lot_control := TRUE;
      END IF;
   END IF;
   -- invConv changes begin :
   -- Because of Material Status : Need to know whether the item is lot_control : MANDATORY.
   IF (l_debug = 1) then
     print_debug('... g_is_mat_status_used='||INV_QUANTITY_TREE_PVT.g_is_mat_status_used);
   END IF;
   IF (l_is_lot_control = FALSE
       AND INV_QUANTITY_TREE_PVT.g_is_mat_status_used = 1)
   THEN
         -- Get Item Details:
         OPEN get_item_details(p_organization_id, p_inventory_item_id);
         FETCH get_item_details
          INTO l_lot_control;

         IF (get_item_details%NOTFOUND)
         THEN
            CLOSE get_item_details;
            -- The item doesn't exist under this organization.
            FND_MESSAGE.SET_NAME('INV', 'ITEM_NOTFOUND');
            FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inventory_item_id);
            FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', p_organization_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE get_item_details;
   END IF;
   -- invConv changes end.

   --?????????????????????
   l_asset_sub_only := FALSE;
   --IF p_asset_subinventory_only = g_asset_subinvs THEN
   --      l_asset_sub_only := TRUE;
   --    ELSE
   --      l_asset_sub_only := FALSE;
   -- END IF;

   l_onhand_source := inv_quantity_tree_pvt.g_all_subs;

   l_expiration_date := NULL;--???????

   IF p_serial_control = g_no_serial_control THEN
      l_is_serial_control := FALSE;
    ELSE
      l_is_serial_control := TRUE;
   END IF;

   l_include_suggestion := TRUE;

   IF (l_debug = 1) THEN
      print_debug('calling inv_quantity_tree_pvt.find_rootinfo.');
   END IF;

   l_tree_id :=
     inv_quantity_tree_pvt.find_rootinfo
     (
	x_return_status           => l_return_status,
	p_organization_id         => p_Organization_id,
	p_inventory_item_id       => p_Inventory_item_id,
	p_tree_mode               => l_Tree_Mode,
	p_is_revision_control     => l_is_revision_control,
	p_is_lot_control          => l_is_lot_control,
	p_is_serial_control       => l_is_serial_control,
	p_asset_sub_only          => l_asset_sub_only,
	p_include_suggestion      => TRUE,
	p_demand_source_type_id   => l_demand_header_type,
	p_demand_source_header_id => p_demand_header_id,
	p_demand_source_line_id   => p_demand_source_line_id,
	p_demand_source_name      => p_demand_source_name,
	p_demand_source_delivery  => p_demand_source_Delivery,
	p_lot_expiration_date     => NULL,
	p_onhand_source           => l_onhand_source
	);

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      IF (l_debug = 1) then
	 print_debug('Error from inv_quantity_tree_pvt.find_rootinfo');
	 print_debug('l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data);
      END IF;
      FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_FIND_ROOTINFO');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) then
      print_debug('After inv_quantity_tree_pvt.find_rootinfo tree_id:'||l_tree_id);
      print_debug('calling inv_quantity_tree_pvt.query_tree');
   END IF;


   inv_quantity_tree_pvt.query_tree
     (
      p_api_version_number   => 1.0,
      p_init_msg_lst         => fnd_api.g_true,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data,
      p_tree_id              => l_tree_id,
      p_revision             => p_Revision,
      p_lot_number           => p_Lot,
      p_subinventory_code    => p_Subinventory,
      p_locator_id           => l_locator_id,
      x_qoh                  => l_qoh,
      x_rqoh                 => l_rqoh,
      x_qr                   => l_qr,
      x_qs                   => l_qs,
      x_att                  => l_att,
      x_atr                  => l_atr,
      x_sqoh                 => l_sqoh,       -- invConv change
      x_srqoh                => l_srqoh,      -- invConv change
      x_sqr                  => l_sqr,        -- invConv change
      x_sqs                  => l_sqs,        -- invConv change
      x_satt                 => l_satt,       -- invConv change
      x_satr                 => l_satr,       -- invConv change
      p_transfer_subinventory_code => p_Transfer_Subinventory,
      p_lpn_id               => p_lpn_id      --added for bug7038890
      );

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
       IF (l_debug = 1) then
	  print_debug('Error from inv_quantity_tree_pvt.query_tree');
	  print_debug('l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data);
       END IF;
       FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_QUERY_TREE');
       FND_MSG_PUB.ADD;
       RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Primaries : l_qoh:'||l_qoh||'l_rqoh:'||l_rqoh||'l_qr:'||l_qr||
		  'l_qs:'||l_qs||'l_att:'||l_att||'l_atr:'||l_atr);
      print_debug('Secondaries : l_sqoh:'||l_sqoh||'l_srqoh:'||l_srqoh||'l_sqr:'||l_sqr||
		  'l_sqs:'||l_sqs||'l_satt:'||l_satt||'l_satr:'||l_satr);
      print_debug('Calling inv_quantity_tree_pvt.get_total_qoh');
   END IF;

   IF p_tree_mode IN (inv_quantity_tree_pvt.g_transaction_mode,
		      inv_quantity_tree_pvt.g_loose_only_mode) THEN
      l_available_quantity := l_att;
      l_available_quantity2 := l_satt;              -- invConv change
    ELSE
      l_available_quantity := l_atr;
      l_available_quantity2 := l_satr;              -- invConv change
   END IF;

   l_onhand_quantity := l_qoh;
   l_onhand_quantity2 := l_sqoh;                    -- invConv change
   l_original_avail_qoh := l_onhand_quantity;
   l_original_avail_qoh2 := l_onhand_quantity2;     -- invConv change
   IF (l_debug = 1) then
     print_debug(' odab l_original_avail_qoh='||l_original_avail_qoh||', l_original_avail_qoh2='||l_original_avail_qoh2);
   END IF;

   inv_quantity_tree_pvt.get_total_qoh
     (x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data,
      p_tree_id              => l_tree_id,
      p_revision             => p_Revision,
      p_lot_number           => p_Lot,
      p_subinventory_code    => p_Subinventory,
      p_locator_id           => l_locator_id,
      x_tqoh                 => l_tqoh,
      x_stqoh                => l_stqoh             -- invConv change
      );

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      IF (l_debug = 1) then
	 print_debug('Error from inv_quantity_tree_pvt.get_total_qoh');
	 print_debug('l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data);
      END IF;
      FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_GET_TOTAL_QOH');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (l_debug = 1) THEN
       print_debug('l_tqoh:'||l_tqoh||', l_stqoh='||l_stqoh);
   END IF;


    l_avail_qoh := l_tqoh;
    l_avail_qoh2 := l_stqoh;               -- invConv change

   IF p_uom_code IS NOT NULL THEN
       BEGIN
	  SELECT Primary_Uom_Code
	    INTO l_primary_uom_code
	    FROM MTL_SYSTEM_ITEMS
	    WHERE Organization_Id = p_organization_id
	    AND   Inventory_Item_Id = p_inventory_item_id;
       EXCEPTION
	  WHEN no_data_found THEN
	     IF (l_debug = 1) then
		print_debug('Cannot Find primary UOM');
	     END IF;
	     FND_MESSAGE.SET_NAME('INV', 'INV_NO_PRIMARY_UOM');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
       END;
   END IF;

   IF (l_debug = 1) then
     print_debug('odab transaction_qty='||p_transaction_quantity||', transaction_qty2='||p_transaction_quantity2||'.');
   END IF;
   l_transaction_quantity := p_transaction_quantity;
   l_transaction_quantity2 := NVL(p_transaction_quantity2, 0);

   IF l_transaction_quantity <> 0 AND
     p_uom_code <> l_primary_uom_code THEN
      l_transaction_conv_quantity := inv_convert.inv_um_convert
	(item_id => p_inventory_item_id,
	 precision => NULL,
	 from_quantity => Abs(l_transaction_quantity),
	 from_unit => p_uom_code,
	 to_unit   => l_primary_uom_code,
	 from_name => null,
	 to_name   => NULL
	 );
      IF l_transaction_conv_quantity < 0 THEN
	 IF (l_debug = 1) THEN
	    print_debug('Error converting l_transaction_quantity');
	 END IF;
	 FND_MESSAGE.SET_NAME('INV', 'INV_UOM_CANNOT_CONVERT');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Bug 4094112 : Added the ELSE clause to the test to convert the QTY when >0
      IF l_transaction_quantity < 0 THEN
        l_transaction_quantity := l_transaction_conv_quantity * (-1);
      ELSE
        l_transaction_quantity := l_transaction_conv_quantity;
      END IF;

      IF (l_debug = 1) THEN
         print_debug('3 conversion result: qty='||l_transaction_quantity||', convQ='||l_transaction_conv_quantity);
      END IF;
   END IF;    -- IF l_transaction_quantity <> 0

   --??????????????????
   IF l_dyn_loc THEN
      IF l_available_quantity > 0 THEN
	  l_available_quantity := 0;
	  l_available_quantity2 := 0;                       -- invConv change
	  l_avail_qoh := 0;
	  l_avail_qoh2 := 0;                                -- invConv change
	ELSE
	  l_available_quantity := l_available_quantity;
	  l_available_quantity2 := l_available_quantity2;   -- invConv change
	  l_avail_qoh := l_available_quantity;
	  l_avail_qoh2 := l_available_quantity2;            -- invConv change
       END IF;
    END IF;
    --????????????

    l_avail_qoh := l_avail_qoh - l_transaction_quantity;
    l_avail_qoh2 := l_avail_qoh2 - l_transaction_quantity2;                       -- invConv change
    l_available_quantity := l_available_quantity - l_transaction_quantity;
    l_available_quantity2 := l_available_quantity2 - l_transaction_quantity2;     -- invConv change

    IF l_dyn_loc THEN
       l_transaction_quantity := 0 - l_transaction_quantity;
       l_transaction_quantity2 := 0 - l_transaction_quantity2;                    -- invConv change
    else
       l_transaction_quantity := l_original_avail_qoh - l_transaction_quantity;
       l_transaction_quantity2 := l_original_avail_qoh2 - l_transaction_quantity2;   -- invConv change
    END IF;

    IF p_uom_code <> l_primary_uom_code THEN

       l_available_conv_quantity := inv_convert.inv_um_convert
	    (item_id => p_inventory_item_id,
	     precision => NULL,
	     from_quantity => Abs(l_available_quantity),
	     from_unit => l_primary_uom_code,
	     to_unit   => p_uom_code,
	     from_name => null,
	     to_name   => NULL
	     );
       IF l_available_conv_quantity < 0 THEN
	  IF (l_debug = 1) THEN
	     print_debug('Error converting l_available_quantity');
	  END IF;
	  FND_MESSAGE.SET_NAME('INV', 'INV_UOM_CANNOT_CONVERT');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_available_quantity < 0 THEN
	  l_available_quantity := l_available_conv_quantity * (-1);
       ELSE
          l_available_quantity := l_available_conv_quantity;
       END IF;
       IF (l_debug = 1) then
         print_debug('4 conversion result: qty='||l_available_quantity||', convQ='||l_available_conv_quantity);
       END IF;

       l_avail_qoh_conv_quantity := inv_convert.inv_um_convert
	 (item_id => p_inventory_item_id,
	  precision => NULL,
	  from_quantity => Abs(l_avail_qoh),
	  from_unit => l_primary_uom_code,
	  to_unit   => p_uom_code,
	  from_name => null,
	  to_name   => NULL
	  );
       IF l_avail_qoh_conv_quantity < 0 THEN
	  IF (l_debug = 1) THEN
	     print_debug('Error converting l_avail_qoh');
	  END IF;
	  FND_MESSAGE.SET_NAME('INV', 'INV_UOM_CANNOT_CONVERT');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_avail_qoh < 0 THEN
	  l_avail_qoh := l_avail_qoh_conv_quantity * (-1);
       ELSE
	  l_avail_qoh := l_avail_qoh_conv_quantity;
       END IF;
       IF (l_debug = 1) then
       print_debug('5 conversion result: qty='||l_avail_qoh||', convQ='||l_avail_qoh_conv_quantity);
       END IF;

       l_transaction_conv_quantity := inv_convert.inv_um_convert
	 (item_id => p_inventory_item_id,
	  precision => NULL,
	  from_quantity => Abs(l_transaction_quantity),
	  from_unit => l_primary_uom_code,
	  to_unit   => p_uom_code,
	  from_name => null,
	  to_name   => NULL
	  );
       IF l_transaction_conv_quantity < 0 THEN
	  IF (l_debug = 1) THEN
	     print_debug('Error converting l_transaction_quantity');
	  END IF;
	  FND_MESSAGE.SET_NAME('INV', 'INV_UOM_CANNOT_CONVERT');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_transaction_quantity < 0 THEN
	  l_transaction_quantity := l_transaction_conv_quantity * (-1);
       ELSE
          l_transaction_quantity := l_transaction_conv_quantity;
       END IF;
       IF (l_debug = 1) then
         print_debug('6 conversion result: qty='||l_transaction_quantity||', convQ='||l_transaction_conv_quantity);
       END IF;
    END IF; -- IF p_uom_code <> l_primary_uom_code THEN

    x_available_quantity := ROUND(l_available_quantity, 5);
    x_available_onhand := ROUND(l_avail_qoh, 5);
    x_onhand_quantity := ROUND(l_transaction_quantity, 5);
    x_available_quantity2 := ROUND(l_available_quantity2, 5);
    x_available_onhand2 := ROUND(l_avail_qoh2, 5);
    x_onhand_quantity2 := ROUND(l_transaction_quantity2, 5);


    IF (l_debug = 1) THEN
       print_debug('returning x_return_status:'||x_return_status||
		   'x_available_quantity:'||x_available_quantity||
		   'x_available_onhand :'||x_available_onhand||
		   'x_onhand_quantity:'||x_onhand_quantity);
       print_debug('Secondaries : '||
		   'x_available_quantity2='||x_available_quantity2||
		   'x_available_onhand2='||x_available_onhand2||
		   'x_onhand_quantity2='||x_onhand_quantity2);
    END IF;
    --?????????????????
    --Investigate why the l_transaction_quantity is used for onhand_quantity
    IF (l_debug = 1) then
      print_debug(' odab returning 1');
    END IF;
    RETURN 1;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
	 print_debug('fnd_api.g_exc_error');
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      x_available_quantity := 0;
      x_available_onhand := 0;
      x_onhand_quantity := 0;

      fnd_msg_pub.count_and_get
	(  p_count => x_message_count
	   , p_data  => x_message_data
	   );

      IF (l_debug = 1) THEN
	  FOR i IN 1 .. x_message_count LOOP
	     print_debug(fnd_msg_pub.get(x_message_count - i + 1, 'F'));
	  END LOOP;
      END IF;
      RETURN 0;
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Others error');
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  'INV_QUANTITY_TREE_UE'
              ,'QUERY_TREE'
              );
      END IF;

      x_available_quantity := 0;
      x_available_onhand := 0;
      x_onhand_quantity := 0;

      fnd_msg_pub.count_and_get
	(  p_count => x_message_count
	   , p_data  => x_message_data
	   );
      IF (l_debug = 1) THEN
	 FOR i IN 1 .. x_message_count LOOP
	    print_debug(fnd_msg_pub.get(x_message_count - i + 1, 'F'));
	  END LOOP;
      END IF;
      RETURN 0;
END query_tree;

-- bug 4104123 : replace p_demand_header_type default NULL by 0
FUNCTION xact_qty(p_organization_id IN NUMBER,
		  p_inventory_item_id IN NUMBER,
		  p_demand_header_id IN NUMBER default NULL,
		  p_demand_header_type IN NUMBER,
		  p_revision_control IN NUMBER default 1,
		  p_lot_control IN NUMBER default 1,
		  p_serial_control IN NUMBER default 1,
		  p_revision in varchar2 default NULL,
		  p_lot in varchar2 default NULL,
		  p_lot_expiration_date IN DATE default NULL,
		  p_subinventory IN varchar2 default NULL,
		  p_locator in NUMBER default NULL,
		  p_xact_mode In NUMBER Default 2,
		  p_transfer_subinventory IN VARCHAR2 default NULL,
		  p_transfer_locator in NUMBER default NULL,
		  p_transaction_quantity in NUMBER default NULL,
		  p_uom_code in varchar2 default NULL,
		  p_lot_active IN NUMBER default 2,
		  p_activate IN NUMBER default 1,
		  p_demand_source_name IN varchar2 default NULL,
		  p_demand_source_line_id IN NUMBER default NULL,
		  p_demand_source_delivery in NUMBER default NULL,
		  p_rev_active in NUMBER default 2,
		  x_available_onhand out NOCOPY NUMBER,
  x_available_quantity out NOCOPY NUMBER,
  x_onhand_quantity out NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_message_count OUT NOCOPY NUMBER,
  x_message_data Out NOCOPY VARCHAR2,
  p_tree_mode    IN NUMBER DEFAULT 3,    --added for bug7038890
  p_lpn_id       IN NUMBER DEFAULT NULL  --added for bug7038890
  ) RETURN NUMBER
  IS

l_QTY                     NUMBER := NULL;
l_transaction_quantity2   NUMBER := NULL;
l_available_onhand2       NUMBER := NULL;
l_available_quantity2     NUMBER := NULL;
l_onhand_quantity2        NUMBER := NULL;
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
-- invConv change : callng the new signature xact_qty :
IF (l_debug = 1) then
  print_debug(' in old call of xact_qty...');
END IF;
l_QTY := xact_qty( P_organization_id         => P_organization_id
		 , P_inventory_item_id       => P_inventory_item_id
		 , P_demand_header_id        => P_demand_header_id
		 , p_demand_header_type      => p_demand_header_type
		 , P_revision_control        => P_revision_control
		 , P_lot_control             => P_lot_control
		 , P_serial_control          => P_serial_control
		 , P_revision                => P_revision
		 , P_lot                     => P_lot
		 , P_lot_expiration_date     => P_lot_expiration_date
		 , P_subinventory            => P_subinventory
		 , P_locator                 => P_locator
		 , P_xact_mode               => P_xact_mode
		 , P_transfer_subinventory   => P_transfer_subinventory
		 , P_transfer_locator        => P_transfer_locator
		 , P_transaction_quantity    => P_transaction_quantity
		 , P_uom_code                => P_uom_code
		 , P_transaction_quantity2   => l_transaction_quantity2
		 , P_lot_active              => P_lot_active
		 , P_activate                => P_activate
		 , P_demand_source_name      => P_demand_source_name
		 , P_demand_source_line_id   => P_demand_source_line_id
		 , P_demand_source_delivery  => P_demand_source_delivery
		 , P_rev_active              => P_rev_active
		 , X_available_onhand        => X_available_onhand
                 , X_available_quantity      => X_available_quantity
                 , X_onhand_quantity         => X_onhand_quantity
		 , X_available_onhand2       => l_available_onhand2
                 , X_available_quantity2     => l_available_quantity2
                 , X_onhand_quantity2        => l_onhand_quantity2
                 , X_return_status           => X_return_status
                 , X_message_count           => X_message_count
                 , X_message_data            => X_message_data
		 , P_tree_mode               => p_tree_mode    --added for bug7038890
		 , P_lpn_id                  => p_lpn_id       --added for bug7038890
		 );

RETURN l_QTY;
-- invConv changes end.


END xact_qty;

-- invConv changes begin :Overloaded version of xact_qty :
-- bug 4104123 : replace p_demand_header_type default NULL by 0
FUNCTION xact_qty( P_organization_id         IN NUMBER
		 , P_inventory_item_id       IN NUMBER
		 , P_demand_header_id        IN NUMBER DEFAULT NULL
		 , p_demand_header_type      IN NUMBER DEFAULT 0
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
		 , P_tree_mode               IN NUMBER DEFAULT 3       --added for bug7038890
		 , P_lpn_id                  IN NUMBER DEFAULT NULL    --added for bug7038890
		 ) RETURN NUMBER
IS

     l_tree_id INTEGER := NULL;
     l_tree_mode NUMBER := NULL;
     l_return_status varchar2(1) := fnd_api.g_ret_sts_success;
     l_msg_data VARCHAR2(2000) := NULL;
     l_msg_count NUMBER := NULL;
     l_is_revision_control BOOLEAN := FALSE;
     l_is_lot_control BOOLEAN := FALSE;
     l_is_serial_control BOOLEAN := FALSE;
     l_asset_sub_only  BOOLEAN := FALSE;
     l_include_suggestion BOOLEAN := TRUE;
     l_expiration_date DATE := NULL;
     l_onhand_source NUMBER := NULL;
     l_qoh NUMBER := NULL;
     l_rqoh NUMBER := NULL;
     l_qr NUMBER := NULL;
     l_qs NUMBER := NULL;
     l_att NUMBER := NULL;
     l_atr NUMBER := NULL;
     l_sqoh NUMBER := NULL;                        -- invConv change
     l_srqoh NUMBER := NULL;                       -- invConv change
     l_sqr NUMBER := NULL;                         -- invConv change
     l_sqs NUMBER := NULL;                         -- invConv change
     l_satt NUMBER := NULL;                        -- invConv change
     l_satr NUMBER := NULL;                        -- invConv change

     l_available_quantity NUMBER := NULL;
     l_available_quantity2 NUMBER := NULL;           -- invconv change
     l_onhand_quantity NUMBER := NULL;
     l_onhand_quantity2 NUMBER := NULL;              -- invconv change
     l_avail_qoh NUMBER := NULL;
     l_avail_qoh2 NUMBER := NULL;                    -- invconv change
     l_available_conv_quantity NUMBER := NULL;
     l_onhand_conv_quantity NUMBER := NULL;
     l_avail_qoh_conv_quantity NUMBER := NULL;
     l_original_avail_qoh NUMBER := NULL;
     l_locator_id  NUMBER := NULL;
     l_transfer_locator_id NUMBER := NULL;
     l_dyn_loc BOOLEAN := FALSE;
     l_tqoh NUMBER := NULL;
     l_stqoh NUMBER := NULL;                               -- invConv change
     l_transaction_quantity NUMBER := NULL;
     l_transaction_quantity2 NUMBER := NULL;                               -- invConv change
     l_transaction_conv_quantity NUMBER := NULL;
     l_primary_uom_code VARCHAR2(3) := NULL;
     l_xact_mode NUMBER := NULL;
     l_process_type NUMBER := NULL;
     l_temp_trx_quantity NUMBER := NULL;
     l_temp_trx_quantity2 NUMBER := NULL;

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

l_lot_control NUMBER;
CURSOR get_item_details( org_id IN NUMBER
                       , item_id IN NUMBER) IS
SELECT NVL(lot_control_code, 1)
FROM mtl_system_items
WHERE inventory_item_id = item_id
AND organization_id = org_id;

l_demand_header_type  NUMBER;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1) then
      print_debug('Xact_qty Inputs Org='||p_organization_id||' itm='||p_inventory_item_id||
		  ' RevCtrl='||p_revision_control||' LotCtrl='||p_lot_control||
		  ' SerCtrl='||p_serial_control||' LotAct='||p_lot_active);
      print_debug(' DHdrId='||p_demand_header_id||' DHdrTyp='||p_demand_header_type||
		  ' XactMode='||p_Xact_mode||' Rev='||p_revision||' Lot='||p_lot||
		  ' LExpDate='||p_lot_expiration_date||' Act='||p_activate);
      print_debug(' UOM='||p_uom_code||' sub='||p_subinventory||' Loc='||p_locator||
		  ' XSub='||p_transfer_subinventory||' Xloc='||p_transfer_locator||
		  ' TxnQty='||p_transaction_quantity||' '||P_uom_code||' TxnQty2='||p_transaction_quantity2||
                  ' DSName='||p_demand_source_name||
		  ' DSLine='||p_demand_source_line_id||
		  ' DSDel='||p_demand_source_delivery||' RevAct:'||p_rev_active);
   END IF;

-- bug 4104123 : I don't know why the default of p_demand_header_type doesnt work.
l_demand_header_type := p_demand_header_type;
if p_demand_header_type IS NULL
THEN
  IF (l_debug = 1) then
    print_debug('... p_demand_header_type IS NULL... reset to 0');
  END IF;
  l_demand_header_type := 0;
ELSE
   IF (l_debug = 1) then
     print_debug('... p_demand_header_type IS NOT NULL... ');
   END IF;
END IF;

   IF p_activate <> 1 THEN
      x_available_quantity := 0;
      x_available_onhand := 0;
      x_onhand_quantity := 0;
      IF p_transaction_quantity2 IS NOT NULL
      THEN
         x_available_onhand2   := 0;
         x_available_quantity2 := 0;
         x_onhand_quantity2    := 0;
      END IF;
      RETURN 1;
   END IF;

   --start changes for bug7038890
   --l_tree_mode := inv_quantity_tree_pvt.g_loose_only_mode;--??????????????
   IF p_lpn_id IS NOT NULL
   THEN
   l_tree_mode :=2;
   ELSE
   l_tree_mode := inv_quantity_tree_pvt.g_loose_only_mode;
   END IF;
   --end changes for bug7038890

   IF p_rev_active = g_no_rev_ctrl_please THEN
      l_is_revision_control := FALSE;
    ELSIF p_rev_active = g_want_rev_ctrl then
      l_is_revision_control := TRUE;
    ELSE
      IF p_revision_control = g_no_rev_control THEN
	 l_is_revision_control := FALSE;
       ELSE
	 l_is_revision_control := TRUE;
      END IF;
   END IF;

   IF p_lot_active = g_no_lot_ctrl_please THEN
      l_is_lot_control := FALSE;
    ELSIF p_lot_active = g_want_lot_ctrl then
      l_is_lot_control := TRUE;
    ELSE
      IF p_lot_control = g_no_lot_control THEN
	 l_is_lot_control := FALSE;
       ELSE
	 l_is_lot_control := TRUE;
      END IF;
   END IF;
   -- invConv changes begin :
   -- Because of Material Status : Need to know whether the item is lot_control : MANDATORY.
   IF (l_debug = 1) then
     print_debug('+++ g_is_mat_status_used='||INV_QUANTITY_TREE_PVT.g_is_mat_status_used);
   END IF;
   IF (l_is_lot_control = FALSE
       AND INV_QUANTITY_TREE_PVT.g_is_mat_status_used = 1)
   THEN
         -- Get Item Details:
         OPEN get_item_details(p_organization_id, p_inventory_item_id);
         FETCH get_item_details
          INTO l_lot_control;

         IF (get_item_details%NOTFOUND)
         THEN
            CLOSE get_item_details;
            -- The item doesn't exist under this organization.
            FND_MESSAGE.SET_NAME('INV', 'ITEM_NOTFOUND');
            FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inventory_item_id);
            FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', p_organization_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE get_item_details;
   END IF;
   -- invConv changes end.

   IF p_locator = -1 THEN
      l_locator_id := 0;
    ELSE
      l_locator_id := p_locator;
   END IF;

   IF p_transfer_locator = -1 THEN
      l_transfer_locator_id := 0;
    ELSE
      l_transfer_locator_id :=p_transfer_locator;
   END IF;

   if (p_Xact_Mode = g_TRX_TEMP) THEN
      l_Xact_Mode := g_ONHAND;
    ELSE
      l_Xact_Mode := p_Xact_Mode;
   END IF;

    IF p_uom_code IS NOT NULL THEN
       BEGIN
	  SELECT Primary_Uom_Code
	    INTO l_primary_uom_code
	    FROM MTL_SYSTEM_ITEMS
	    WHERE Organization_Id = p_organization_id
	       AND   Inventory_Item_Id = p_inventory_item_id;
       EXCEPTION
	  WHEN no_data_found THEN
	     IF (l_debug = 1) then
		print_debug('Cannot Find primary UOM');
	     END IF;
	     FND_MESSAGE.SET_NAME('INV', 'INV_NO_PRIMARY_UOM');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
       END;
    END IF;


    l_transaction_quantity := p_transaction_quantity;
    l_transaction_quantity2 := p_transaction_quantity2;

    IF l_transaction_quantity <> 0 AND
      p_uom_code <> l_primary_uom_code THEN
       l_transaction_conv_quantity := inv_convert.inv_um_convert
	 (item_id => p_inventory_item_id,
	  precision => NULL,
	  from_quantity => Abs(l_transaction_quantity),
	  from_unit => p_uom_code,
	  to_unit   => l_primary_uom_code,
	  from_name => null,
	  to_name   => NULL
	  );
       IF l_transaction_conv_quantity < 0 THEN
	  IF (l_debug = 1) THEN
	     print_debug('Error converting l_transaction_quantity');
	  END IF;
	  FND_MESSAGE.SET_NAME('INV', 'INV_UOM_CANNOT_CONVERT');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Bug 4094112 : Added the ELSE clause in the test, in order to convert QTY when >0
       IF l_transaction_quantity < 0 THEN
          l_transaction_quantity := l_transaction_conv_quantity * (-1);
       ELSE
          l_transaction_quantity := l_transaction_conv_quantity;
       END IF;

       IF (l_debug = 1) THEN
          print_debug('7 conversion result: qty='||l_transaction_quantity||', convQ='||l_transaction_conv_quantity);
       END IF;
    END IF;

    --?????????????????????
    l_asset_sub_only := FALSE;
    --IF p_asset_subinventory_only = g_asset_subinvs THEN
    --      l_asset_sub_only := TRUE;
    --    ELSE
    --      l_asset_sub_only := FALSE;
    -- END IF;

    l_onhand_source := inv_quantity_tree_pvt.g_all_subs;

    l_expiration_date := NULL;--???????

    IF p_serial_control = g_no_serial_control THEN
       l_is_serial_control := FALSE;
     ELSE
       l_is_serial_control := TRUE;
    END IF;

    l_include_suggestion := TRUE;

    IF (l_debug = 1) THEN
       print_debug('calling inv_quantity_tree_pvt.find_rootinfo');
    END IF;

    l_tree_id :=
      inv_quantity_tree_pvt.find_rootinfo
      (  x_return_status           => l_return_status,
	 p_organization_id         => p_organization_id,
	 p_inventory_item_id       => p_inventory_item_id,
	 p_tree_mode               => l_tree_Mode,
	 p_is_revision_control     => l_is_revision_control,
	 p_is_lot_control          => l_is_lot_control,
	 p_is_serial_control       => l_is_serial_control,
	 p_asset_sub_only          => l_asset_sub_only,
	 p_include_suggestion      => TRUE,
	 p_demand_source_type_id   => l_demand_header_type,
	 p_demand_source_header_id => p_demand_header_id,
	 p_demand_source_line_id   => p_demand_source_line_id,
	 p_demand_source_name      => p_demand_source_name,
	 p_demand_source_delivery  => p_demand_source_Delivery,
	 p_lot_expiration_date     => NULL,
	 p_onhand_source           => l_onhand_source
	 );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
       IF (l_debug = 1) then
	  print_debug('Error from inv_quantity_tree_pvt.find_rootinfo');
	  print_debug('l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data);
       END IF;
       FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_FIND_ROOTINFO');
       FND_MSG_PUB.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) then
      print_debug('After inv_quantity_tree_pvt.find_rootinfo tree_id:'||l_tree_id);
      print_debug('Will call update_qties for xact_mode='||l_xact_mode||', g_qs_txn='||g_qs_txn||', subinv='||p_transfer_subinventory);
    END IF;

    IF p_transfer_subinventory IS NOT NULL AND
      l_xact_mode <> g_qs_txn THEN

       IF (l_debug = 1) THEN
	  print_debug('Calling update_quantities_for_form for xact_mode='||l_xact_mode||', trx_qty='||l_transaction_quantity||', trx_qty2='||p_transaction_quantity2||'.');
       END IF;

       inv_quantity_tree_pvt.update_quantities_for_form
	 (  p_api_version_number    => 1.0,
	    p_init_msg_lst          => fnd_api.g_true,
	    x_return_status         => l_return_status,
	    x_msg_count             => l_msg_count,
	    x_msg_data              => l_msg_data,
	    p_tree_id               => l_tree_id,
	    p_revision              => p_Revision,
	    p_lot_number            => p_Lot,
	    p_subinventory_code     => p_transfer_Subinventory,
	    p_locator_id            => l_transfer_Locator_id,
	    p_primary_quantity      => l_transaction_quantity,
	    p_secondary_quantity    => p_transaction_quantity2,     -- invConv change
	    p_quantity_type         => inv_quantity_tree_pvt.g_qoh,
	    x_qoh                   => l_qoh,
	    x_rqoh                  => l_rqoh,
	    x_qr                    => l_qr,
	    x_qs                    => l_qs,
	    x_att                   => l_att,
	    x_atr                   => l_atr,
	    x_sqoh                  => l_sqoh,              -- invConv change
	    x_srqoh                 => l_srqoh,             -- invConv change
	    x_sqr                   => l_sqr,               -- invConv change
	    x_sqs                   => l_sqs,               -- invConv change
	    x_satt                  => l_satt,              -- invConv change
	    x_satr                  => l_satr,              -- invConv change
	    p_call_for_form        => fnd_api.g_true,
	    p_lpn_id               =>p_lpn_id            --added for bug7038890
	    );

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
	  IF (l_debug = 1) then
	     print_debug('Error from inv_quantity_tree_pvt.update_quantities_for_form 1');
	     print_debug('l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data);
	  END IF;
	  FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_UPDATE_QUANTITIES');
	  FND_MSG_PUB.ADD;
	  RAISE fnd_api.g_exc_error;
       END IF;

       IF (l_debug = 1) THEN
	  print_debug('Primaries l_qoh:'||l_qoh||'l_rqoh:'||l_rqoh||'l_qr:'||l_qr||
		      'l_qs:'||l_qs||'l_att:'||l_att||'l_atr:'||l_atr);
	  print_debug('Secondaries l_sqoh:'||l_sqoh||'l_srqoh:'||l_srqoh||'l_sqr:'||l_qr||
		      'l_sqs:'||l_sqs||'l_satt:'||l_satt||'l_satr:'||l_satr);
       END IF;

       IF (l_debug = 1) THEN
	  print_debug('Calling update_quantities_for_form for trx_qty='||(0 - l_transaction_quantity)||', trx_qty2='||(0 - p_transaction_quantity2)||'.');
       END IF;

       inv_quantity_tree_pvt.update_quantities_for_form
	 (  p_api_version_number    => 1.0,
	    p_init_msg_lst          => fnd_api.g_true,
	    x_return_status         => l_return_status,
	    x_msg_count             => l_msg_count,
	    x_msg_data              => l_msg_data,
	    p_tree_id               => l_tree_id,
	    p_revision              => p_Revision,
	    p_lot_number            => p_Lot,
	    p_subinventory_code     => p_Subinventory,
	    p_locator_id            => l_Locator_id,
	    p_primary_quantity      => (0 - l_transaction_quantity),
	    p_secondary_quantity    => (0 - p_transaction_quantity2),
	    p_quantity_type         => inv_quantity_tree_pvt.g_qoh,
	    x_qoh                   => l_qoh,
	    x_rqoh                  => l_rqoh,
	    x_qr                    => l_qr,
	    x_qs                    => l_qs,
	    x_att                   => l_att,
	    x_atr                   => l_atr,
	    x_sqoh                  => l_sqoh,                 -- invConv change
	    x_srqoh                 => l_srqoh,                -- invConv change
	    x_sqr                   => l_sqr,                  -- invConv change
	    x_sqs                   => l_sqs,                  -- invConv change
	    x_satt                  => l_satt,                 -- invConv change
	    x_satr                  => l_satr,                 -- invConv change
	    p_call_for_form        => fnd_api.g_true,
	    p_lpn_id               =>p_lpn_id                  --added for bug7038890
	    );

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
	  IF (l_debug = 1) then
	     print_debug('Error from inv_quantity_tree_pvt.update_quantities_for_form 2');
	     print_debug('l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data);
	  END IF;
	  FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_UPDATE_QUANTITIES');
	  FND_MSG_PUB.ADD;
	  RAISE fnd_api.g_exc_error;
       END IF;

       IF (l_debug = 1) THEN
	  print_debug('Primaries l_qoh:'||l_qoh||'l_rqoh:'||l_rqoh||'l_qr:'||l_qr||
		      'l_qs:'||l_qs||'l_att:'||l_att||'l_atr:'||l_atr);
	  print_debug('Secondaries l_sqoh:'||l_sqoh||'l_srqoh:'||l_srqoh||'l_sqr:'||l_sqr||
		      'l_sqs:'||l_sqs||'l_satt:'||l_satt||'l_satr:'||l_satr);
       END IF;

       IF (l_debug = 1) THEN
	  print_debug('calling inv_quantity_tree_pvt.query_tree');
       END IF;

       inv_quantity_tree_pvt.query_tree
	 (p_api_version_number   => 1.0,
	  p_init_msg_lst         => fnd_api.g_true,
	  x_return_status        => l_return_status,
	  x_msg_count            => l_msg_count,
	  x_msg_data             => l_msg_data,
	  p_tree_id              => l_tree_id,
	  p_revision             => p_Revision,
	  p_lot_number           => p_Lot,
	  p_subinventory_code    => p_Subinventory,
	  p_locator_id           => l_locator_id,
	  x_qoh                  => l_qoh,
	  x_rqoh                 => l_rqoh,
	  x_qr                   => l_qr,
	  x_qs                   => l_qs,
	  x_att                  => l_att,
	  x_atr                  => l_atr,
	  x_sqoh                 => l_sqoh,             -- invConv change
	  x_srqoh                => l_srqoh,            -- invConv change
	  x_sqr                  => l_sqr,              -- invConv change
	  x_sqs                  => l_sqs,              -- invConv change
	  x_satt                 => l_satt,             -- invConv change
	  x_satr                 => l_satr,             -- invConv change
	  p_transfer_subinventory_code => p_Transfer_Subinventory,
	  p_lpn_id               => p_lpn_id            --added for bug7038890
	  );

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
	  IF (l_debug = 1) then
	     print_debug('Error from inv_quantity_tree_pvt.query_tree');
	     print_debug('l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data);
	  END IF;
	  FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_QUERY_TREE');
	  FND_MSG_PUB.ADD;
	  RAISE fnd_api.g_exc_error;
       END IF;

       IF (l_debug = 1) THEN
	  print_debug('l_qoh:'||l_qoh||'l_rqoh:'||l_rqoh||'l_qr:'||l_qr||
		      'l_qs:'||l_qs||'l_att:'||l_att||'l_atr:'||l_atr);
       END IF;

     ELSE
       IF l_xact_mode IN (g_reservation, g_qs_txn) THEN
	  l_temp_trx_quantity := l_transaction_quantity;
	  l_temp_trx_quantity2 := p_transaction_quantity2;          -- invConv change
	ELSE
	  l_temp_trx_quantity := 0 - l_transaction_quantity;
	  l_temp_trx_quantity2 := 0 - p_transaction_quantity2;      -- invConv change
       END IF;

       IF (l_debug = 1) THEN
	  print_debug('Calling update_quantities_for_form for temp_trx_qty='||l_temp_trx_quantity||', temp_trx_qty2='||l_temp_trx_quantity2||'.');
       END IF;

       inv_quantity_tree_pvt.update_quantities_for_form
	 (  p_api_version_number    => 1.0,
	    p_init_msg_lst          => fnd_api.g_true,
	    x_return_status         => l_return_status,
	    x_msg_count             => l_msg_count,
	    x_msg_data              => l_msg_data,
	    p_tree_id               => l_tree_id,
	    p_revision              => p_Revision,
	    p_lot_number            => p_Lot,
	    p_subinventory_code     => p_Subinventory,
	    p_locator_id            => l_Locator_id,
	    p_primary_quantity      => l_temp_trx_quantity,
	    p_secondary_quantity    => l_temp_trx_quantity2,      -- invConv change
	    p_quantity_type         => l_xact_mode,
	    x_qoh                   => l_qoh,
	    x_rqoh                  => l_rqoh,
	    x_qr                    => l_qr,
	    x_qs                    => l_qs,
	    x_att                   => l_att,
	    x_atr                   => l_atr,
	    x_sqoh                  => l_sqoh,                    -- invConv change
	    x_srqoh                 => l_srqoh,                   -- invConv change
	    x_sqr                   => l_sqr,                     -- invConv change
	    x_sqs                   => l_sqs,                     -- invConv change
	    x_satt                  => l_satt,                    -- invConv change
	    x_satr                  => l_satr,                    -- invConv change
	    p_call_for_form         => fnd_api.g_true,
	    p_lpn_id                => p_lpn_id                  --added for bug7038890
	    );

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
	  IF (l_debug = 1) then
	     print_debug('Error from inv_quantity_tree_pvt.update_quantities_for_form 3');
	     print_debug('l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data);
	  END IF;
	  FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_UPDATE_QUANTITIES');
	  FND_MSG_PUB.ADD;
	  RAISE fnd_api.g_exc_error;
       END IF;

       IF (l_debug = 1) THEN
	  print_debug('Primaries l_qoh:'||l_qoh||'l_rqoh:'||l_rqoh||'l_qr:'||l_qr||
		      'l_qs:'||l_qs||'l_att:'||l_att||'l_atr:'||l_atr);
	  print_debug('Secondaries l_sqoh:'||l_sqoh||'l_srqoh:'||l_srqoh||'l_sqr:'||l_sqr||
		      'l_sqs:'||l_sqs||'l_satt:'||l_satt||'l_satr:'||l_satr);
       END IF;
    END IF;

    IF l_tree_mode IN (inv_quantity_tree_pvt.g_transaction_mode,
		       inv_quantity_tree_pvt.g_loose_only_mode) THEN
       l_available_quantity := l_att;
       l_available_quantity2 := l_satt;         -- invConv change
     ELSE
       l_available_quantity := l_atr;
       l_available_quantity2 := l_satr;         -- invConv change
    END IF;

    l_onhand_quantity := l_qoh;
    l_onhand_quantity2 := l_sqoh;               -- invConv change

    l_transaction_quantity := l_onhand_quantity;
    l_transaction_quantity2 := l_onhand_quantity2;     -- invconv change
    IF (l_debug = 1) then
      print_debug(' odab before get_total_qoh l_original_avail_qoh='||l_onhand_quantity||', l_original_avail_qoh2='||l_onhand_quantity2);
    END IF;

    IF (l_debug = 1) THEN
       print_debug('Calling inv_quantity_tree_pvt.get_total_qoh');
    END IF;

    inv_quantity_tree_pvt.get_total_qoh
      (x_return_status        => l_return_status,
       x_msg_count            => l_msg_count,
       x_msg_data             => l_msg_data,
       p_tree_id              => l_tree_id,
       p_revision             => p_Revision,
       p_lot_number           => p_Lot,
       p_subinventory_code    => p_Subinventory,
       p_locator_id           => l_locator_id,
       x_tqoh                 => l_tqoh,
       x_stqoh                 => l_stqoh,           -- invConv change
       p_lpn_id                => p_lpn_id           --added for bug7038890
       );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
       IF (l_debug = 1) then
	  print_debug('Error from inv_quantity_tree_pvt.get_total_qoh');
	  print_debug('l_return_status:'||l_return_status||'l_msg_data:'||l_msg_data);
       END IF;
       FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_GET_TOTAL_QOH');
       FND_MSG_PUB.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('l_tqoh:'||l_tqoh);
    END IF;

     l_avail_qoh := l_tqoh;
     l_avail_qoh2 := l_stqoh;               -- invConv change

    IF p_uom_code <> l_primary_uom_code THEN

       l_available_conv_quantity := inv_convert.inv_um_convert
	 (item_id => p_inventory_item_id,
	  precision => NULL,
	  from_quantity => Abs(l_available_quantity),
	  from_unit => l_primary_uom_code,
	  to_unit   => p_uom_code,
	  from_name => null,
	  to_name   => NULL
	  );
       IF l_available_conv_quantity < 0 THEN
	  IF (l_debug = 1) THEN
	     print_debug('Error converting l_available_quantity');
	 END IF;
	  FND_MESSAGE.SET_NAME('INV', 'INV_UOM_CANNOT_CONVERT');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_available_quantity < 0 THEN
	  l_available_quantity := l_available_conv_quantity * (-1);
       ELSE
          l_available_quantity := l_available_conv_quantity;
       END IF;
       IF (l_debug = 1) then
         print_debug('8 conversion result: qty='||l_available_quantity||', convQ='||l_available_conv_quantity);
       END IF;

       l_avail_qoh_conv_quantity := inv_convert.inv_um_convert
	 (item_id => p_inventory_item_id,
	  precision => NULL,
	  from_quantity => Abs(l_avail_qoh),
	  from_unit => l_primary_uom_code,
	  to_unit   => p_uom_code,
	  from_name => null,
	  to_name   => NULL
	  );
       IF l_avail_qoh_conv_quantity < 0 THEN
	  IF (l_debug = 1) THEN
	     print_debug('Error converting l_avail_qoh');
	  END IF;
	  FND_MESSAGE.SET_NAME('INV', 'INV_UOM_CANNOT_CONVERT');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_avail_qoh < 0 THEN
	  l_avail_qoh := l_avail_qoh_conv_quantity * (-1);
       ELSE
          l_avail_qoh := l_avail_qoh_conv_quantity;
       END IF;
       IF (l_debug = 1) then
         print_debug('9 conversion result: qty='||l_avail_qoh||', convQ='||l_avail_qoh_conv_quantity);
       END IF;

       l_transaction_conv_quantity := inv_convert.inv_um_convert
	 (item_id => p_inventory_item_id,
	  precision => NULL,
	  from_quantity => Abs(l_transaction_quantity),
	  from_unit => l_primary_uom_code,
	  to_unit   => p_uom_code,
	  from_name => null,
	  to_name   => NULL
	  );
       IF l_transaction_conv_quantity < 0 THEN
	  IF (l_debug = 1) THEN
	     print_debug('Error converting l_transaction_quantity');
	  END IF;
	  FND_MESSAGE.SET_NAME('INV', 'INV_UOM_CANNOT_CONVERT');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_transaction_quantity < 0 THEN
	  l_transaction_quantity := l_transaction_conv_quantity * (-1);
       ELSE
	  l_transaction_quantity := l_transaction_conv_quantity;
       END IF;
       IF (l_debug = 1) then
         print_debug('0 conversion result: qty='||l_transaction_quantity||', convQ='||l_transaction_conv_quantity);
       END IF;
   END IF;
    x_available_quantity := ROUND(l_available_quantity, 5);
    x_available_onhand := ROUND(l_avail_qoh, 5);
    x_onhand_quantity := ROUND(l_transaction_quantity, 5);
    x_available_quantity2 := ROUND(l_available_quantity2, 5);         -- invConv change
    x_available_onhand2 := ROUND(l_avail_qoh2, 5);                    -- invConv change
    x_onhand_quantity2 := ROUND(l_transaction_quantity2, 5);          -- invConv change

    IF (l_debug = 1) THEN
       print_debug('xact_tree returning x_return_status:'||x_return_status||
		   ' x_available_quantity:'||x_available_quantity||
		   ' x_available_onhand:'||x_available_onhand||
		   ' x_onhand_quantity:'||x_onhand_quantity||
		   ' x_available_quantity2:'||x_available_quantity2||
		   ' x_available_onhand2:'||x_available_onhand2||
		   ' x_onhand_quantity2:'||x_onhand_quantity2);
    END IF;

    RETURN 1;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
	 print_debug('fnd_api.g_exc_error');
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      x_available_quantity := 0;
      x_available_onhand := 0;
      x_onhand_quantity := 0;

      -- invConv changes begin :
      IF p_transaction_quantity2 IS NOT NULL
      THEN
         x_available_quantity2 := 0;
         x_available_onhand2   := 0;
         x_onhand_quantity2    := 0;
      END IF;
      -- invConv changes end.

      fnd_msg_pub.count_and_get
	(  p_count => x_message_count
	   , p_data  => x_message_data
	   );

      IF (l_debug = 1) THEN
	 FOR i IN 1 .. x_message_count LOOP
	    print_debug(fnd_msg_pub.get(x_message_count - i + 1, 'F'));
	 END LOOP;
      END IF;

      RETURN 0;
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Others error');
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  'INV_QUANTITY_TREE_UE'
              ,'XACT_QTY'
              );
      END IF;

      x_available_quantity := 0;
      x_available_onhand := 0;
      x_onhand_quantity := 0;
      -- invConv changes begin :
      IF p_transaction_quantity2 IS NOT NULL
      THEN
         x_available_quantity2 := 0;
         x_available_onhand2   := 0;
         x_onhand_quantity2   := 0;
      END IF;
      -- invConv changes end.

      fnd_msg_pub.count_and_get
	(  p_count => x_message_count
	   , p_data  => x_message_data
	   );

      IF (l_debug = 1) THEN
	 FOR i IN 1 .. x_message_count LOOP
	    print_debug(fnd_msg_pub.get(x_message_count - i + 1, 'F'));
	 END LOOP;
      END IF;

      RETURN 0;
END xact_qty;

END INV_QUANTITY_TREE_UE;

/
