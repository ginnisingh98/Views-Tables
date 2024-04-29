--------------------------------------------------------
--  DDL for Package Body INV_RCV_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_CACHE" AS
/* $Header: INVRCSHB.pls 120.3.12010000.2 2010/05/20 09:40:04 skommine ship $*/

PROCEDURE print_debug(p_err_msg VARCHAR2
		      ,p_module IN VARCHAR2 := ' '
		      ,p_level NUMBER := 4)
  IS
     l_debug NUMBER;
BEGIN
   l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg
      ,p_module => 'INV_RCV_CACHE.'||p_module
      ,p_level => p_level);
END;

FUNCTION convert_qty
  (p_inventory_item_id   IN NUMBER
   ,p_from_qty           IN NUMBER
   ,p_from_uom_code      IN VARCHAR2
   ,p_to_uom_code        IN VARCHAR2
   ,p_precision          IN NUMBER DEFAULT NULL
   , p_organization_id   IN NUMBER DEFAULT NULL --Bug#9570776
   , p_lot_number        IN VARCHAR2 DEFAULT NULL --Bug#9570776
   )
  RETURN NUMBER IS
     l_conversion_rate          NUMBER;
     l_to_qty                   NUMBER;

     l_debug                    NUMBER;
     l_progress                 VARCHAR2(10);
     l_module_name              VARCHAR2(30);

BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'CONVERT_QTY';

   IF (l_debug = 1) THEN
      print_debug('Entering convert_qty...',l_module_name,4);
      print_debug(' p_inventory_item_id => '||p_inventory_item_id,l_module_name,4);
      print_debug(' p_from_uom_code     => '||p_from_uom_code,l_module_name,4);
      print_debug(' p_to_uom_code       => '||p_to_uom_code,l_module_name,4);
      print_debug(' p_from_qty          => '||p_from_qty,l_module_name,4);
      print_debug(' p_precision         => '||p_precision,l_module_name,4);
   END IF;

   IF (p_inventory_item_id IS NULL) THEN
      IF (l_debug = 1) THEN
	 print_debug(' No caching for cases without item_id',4);
      END IF;

      l_to_qty := inv_convert.inv_um_convert
	             (item_id           => p_inventory_item_id,
		      precision         => Nvl(p_precision,g_conversion_precision),
		      from_quantity     => p_from_qty,
		      from_unit         => p_from_uom_code,
		      to_unit           => p_to_uom_code,
		      from_name         => null,
		      to_name           => null);

      IF (l_debug = 1) THEN
	 print_debug(' x_to_qty            => '||l_to_qty,l_module_name,4);
      END IF;

      RETURN l_to_qty;
   /*Bug#9570776 Added the below elsif to consider the lot specific conversion
      when the lot number is not passed */
   ELSIF (p_inventory_item_id IS NOT NULL) AND (p_lot_number IS NOT NULL) THEN
      IF (l_debug = 1) THEN
	 print_debug(' lot specific conversion ',4);
      END IF;

      l_to_qty := inv_convert.inv_um_convert
	             (item_id           => p_inventory_item_id,
                      organization_id    => p_organization_id,
		      lot_number         => p_lot_number,
		      precision         => Nvl(p_precision,g_conversion_precision),
		      from_quantity     => p_from_qty,
		      from_unit         => p_from_uom_code,
		      to_unit           => p_to_uom_code,
		      from_name         => null,
		      to_name           => null);

      IF (l_debug = 1) THEN
	 print_debug(' x_to_qty            => '||l_to_qty,l_module_name,4);
      END IF;

      RETURN l_to_qty;
   END IF;

   IF (g_item_uom_conversion_tb.exists(p_inventory_item_id) AND
       g_item_uom_conversion_tb(p_inventory_item_id).exists(p_from_uom_code) AND
       g_item_uom_conversion_tb(p_inventory_item_id)(p_from_uom_code).exists(p_to_uom_code)) THEN
      l_conversion_rate := g_item_uom_conversion_tb(p_inventory_item_id)(p_from_uom_code)(p_to_uom_code);
    ELSE
      inv_convert.inv_um_conversion(from_unit  => p_from_uom_code,
				    to_unit    => p_to_uom_code,
				    item_id    => p_inventory_item_id,
				    uom_rate   => l_conversion_rate);

      IF (l_conversion_rate < 0) THEN
	 RAISE fnd_api.g_exc_error;
      END IF;

      g_item_uom_conversion_tb(p_inventory_item_id)(p_from_uom_code)(p_to_uom_code) := l_conversion_rate;
      g_item_uom_conversion_tb(p_inventory_item_id)(p_to_uom_code)(p_from_uom_code) := 1 / l_conversion_rate;

   END IF;

   l_to_qty := Round(l_conversion_rate*p_from_qty,Nvl(p_precision,g_conversion_precision));

   IF (l_debug = 1) THEN
      print_debug(' x_to_qty            => '||l_to_qty,l_module_name,4);
   END IF;

   RETURN l_to_qty;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred inside convert_qty!',l_module_name,4);
      END IF;
      RETURN -1;
END convert_qty;

FUNCTION get_primary_uom_code
  (p_organization_id     IN NUMBER
   ,p_inventory_item_id  IN NUMBER
   ) RETURN VARCHAR2 IS
      l_debug                    NUMBER;
      l_progress                 VARCHAR2(10);
      l_module_name              VARCHAR2(30);
BEGIN
   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'GET_PRIMARY_UOM_CODE';

   IF (l_debug = 1) THEN
      print_debug('Entering get_primary_uom_code...',l_module_name,4);
      print_debug(' p_inventory_item_id    => '||p_inventory_item_id,l_module_name,4);
      print_debug(' p_organization_id      => '||p_organization_id,l_module_name,4);
   END IF;

   IF (g_org_item_attrib_tb.exists(p_organization_id) AND
       g_org_item_attrib_tb(p_organization_id).exists(p_inventory_item_id)) THEN
      IF (l_debug = 1) THEN
	 print_debug(' x_prim_uom_code (Cache) => '||
		     g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).primary_uom_code,l_module_name,4);
      END IF;
      RETURN g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).primary_uom_code;
    ELSE
      BEGIN
	 SELECT primary_uom_code
	   ,    secondary_uom_code
	   ,    lot_control_code
	   ,    serial_number_control_code
	   INTO g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).primary_uom_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).secondary_uom_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).lot_control_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).serial_number_control_code
	   FROM   mtl_system_items
	   WHERE  organization_id = p_organization_id
	   AND    inventory_item_id = p_inventory_item_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Unable to query from db!',l_module_name,4);
	    END IF;
	    RAISE fnd_api.g_exc_error;
      END;

      IF (l_debug = 1) THEN
	 print_debug(' x_prim_uom_code (DB)     => '||
		     g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).primary_uom_code,l_module_name,4);
      END IF;

      RETURN g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).primary_uom_code;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred inside GET_PRIMARY_UOM_CODE!',l_module_name,4);
      END IF;
      RETURN NULL;
END get_primary_uom_code;

FUNCTION get_secondary_uom_code
  (p_organization_id     IN NUMBER
   ,p_inventory_item_id  IN NUMBER
   ) RETURN VARCHAR2 IS
      l_debug                    NUMBER;
      l_progress                 VARCHAR2(10);
      l_module_name              VARCHAR2(30);
BEGIN
   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'GET_SECONDARY_UOM_CODE';

   IF (l_debug = 1) THEN
      print_debug('Entering get_secondary_uom_code...',l_module_name,4);
      print_debug(' p_inventory_item_id    => '||p_inventory_item_id,l_module_name,4);
      print_debug(' p_organization_id      => '||p_organization_id,l_module_name,4);
   END IF;

   IF (g_org_item_attrib_tb.exists(p_organization_id) AND
       g_org_item_attrib_tb(p_organization_id).exists(p_inventory_item_id)) THEN
      IF (l_debug = 1) THEN
	 print_debug(' x_prim_uom_code (Cache) => '||
		     g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).secondary_uom_code,l_module_name,4);
      END IF;
      RETURN g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).secondary_uom_code;
    ELSE
      BEGIN
	 SELECT primary_uom_code
	   ,    secondary_uom_code
	   ,    lot_control_code
	   ,    serial_number_control_code
	   INTO g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).primary_uom_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).secondary_uom_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).lot_control_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).serial_number_control_code
	   FROM   mtl_system_items
	   WHERE  organization_id = p_organization_id
	   AND    inventory_item_id = p_inventory_item_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Unable to query from db!',l_module_name,4);
	    END IF;
	    RAISE fnd_api.g_exc_error;
      END;

      IF (l_debug = 1) THEN
	 print_debug(' x_prim_uom_code (DB)     => '||
		     g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).secondary_uom_code,l_module_name,4);
      END IF;

      RETURN g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).secondary_uom_code;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred inside GET_SECONDARY_UOM_CODE!',l_module_name,4);
      END IF;
      RETURN NULL;
END get_secondary_uom_code;

FUNCTION get_sn_ctrl_code
  (p_organization_id     IN NUMBER
   ,p_inventory_item_id  IN NUMBER
   ) RETURN NUMBER IS
      l_debug                    NUMBER;
      l_progress                 VARCHAR2(10);
      l_module_name              VARCHAR2(30);
BEGIN
   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'GET_SN_CTRL_CODE';

   IF (l_debug = 1) THEN
      print_debug('Entering get_sn_ctrl_code...',l_module_name,4);
      print_debug(' p_inventory_item_id    => '||p_inventory_item_id,l_module_name,4);
      print_debug(' p_organization_id      => '||p_organization_id,l_module_name,4);
   END IF;

   IF (g_org_item_attrib_tb.exists(p_organization_id) AND
       g_org_item_attrib_tb(p_organization_id).exists(p_inventory_item_id)) THEN
      IF (l_debug = 1) THEN
	 print_debug(' x_sn_ctrl_code (Cache) => '||
		     g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).serial_number_control_code,l_module_name,4);
      END IF;
      RETURN g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).serial_number_control_code;
    ELSE
      BEGIN
	 SELECT primary_uom_code
	   ,    secondary_uom_code
	   ,    lot_control_code
	   ,    serial_number_control_code
	   INTO g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).primary_uom_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).secondary_uom_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).lot_control_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).serial_number_control_code
	   FROM   mtl_system_items
	   WHERE  organization_id = p_organization_id
	   AND    inventory_item_id = p_inventory_item_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Unable to query from db!',l_module_name,4);
	    END IF;
	    RAISE fnd_api.g_exc_error;
      END;

      IF (l_debug = 1) THEN
	 print_debug(' x_sn_ctrl_code (DB)     => '||
		     g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).serial_number_control_code,l_module_name,4);
      END IF;

      RETURN g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).serial_number_control_code;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred inside GET_SN_CTRL_CODE!',l_module_name,4);
      END IF;
      RETURN NULL;
END get_sn_ctrl_code;

FUNCTION get_lot_control_code
  (p_organization_id     IN NUMBER
   ,p_inventory_item_id  IN NUMBER
   ) RETURN NUMBER IS
      l_debug                    NUMBER;
      l_progress                 VARCHAR2(10);
      l_module_name              VARCHAR2(30);
BEGIN
   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'GET_LOT_CONTROL_CODE';

   IF (l_debug = 1) THEN
      print_debug('Entering get_lot_control_code...',l_module_name,4);
      print_debug(' p_inventory_item_id    => '||p_inventory_item_id,l_module_name,4);
      print_debug(' p_organization_id      => '||p_organization_id,l_module_name,4);
   END IF;

   IF (g_org_item_attrib_tb.exists(p_organization_id) AND
       g_org_item_attrib_tb(p_organization_id).exists(p_inventory_item_id)) THEN
      IF (l_debug = 1) THEN
	 print_debug(' x_lot_control_code (Cache) => '||
		     g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).lot_control_code,l_module_name,4);
      END IF;
      RETURN g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).lot_control_code;
    ELSE
      BEGIN
	 SELECT primary_uom_code
	   ,    secondary_uom_code
	   ,    lot_control_code
	   ,    serial_number_control_code
	   INTO g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).primary_uom_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).secondary_uom_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).lot_control_code
	   ,    g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).serial_number_control_code
	   FROM   mtl_system_items
	   WHERE  organization_id = p_organization_id
	   AND    inventory_item_id = p_inventory_item_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Unable to query from db!',l_module_name,4);
	    END IF;
	    RAISE fnd_api.g_exc_error;
      END;

      IF (l_debug = 1) THEN
	 print_debug(' x_lot_control_code (DB)     => '||
		     g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).lot_control_code,l_module_name,4);
      END IF;

      RETURN g_org_item_attrib_tb(p_organization_id)(p_inventory_item_id).lot_control_code;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred inside GET_LOT_CONTROL_CODE!',l_module_name,4);
      END IF;
      RETURN NULL;
END get_lot_control_code;

FUNCTION get_conversion_rate
  (p_inventory_item_id   IN NUMBER
   ,p_from_uom_code      IN VARCHAR2
   ,p_to_uom_code        IN VARCHAR2
   )
   RETURN NUMBER IS

     l_conversion_rate          NUMBER;

     l_debug                    NUMBER;
     l_progress                 VARCHAR2(10);
     l_module_name              VARCHAR2(30);
BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'GET_CONVERSION_RATE';

   IF (l_debug = 1) THEN
      print_debug('Entering convert_qty...',l_module_name,4);
      print_debug(' p_inventory_item_id => '||p_inventory_item_id,l_module_name,4);
      print_debug(' p_from_uom_code     => '||p_from_uom_code,l_module_name,4);
      print_debug(' p_to_uom_code       => '||p_to_uom_code,l_module_name,4);
   END IF;

   IF (g_item_uom_conversion_tb.exists(p_inventory_item_id) AND
       g_item_uom_conversion_tb(p_inventory_item_id).exists(p_from_uom_code) AND
       g_item_uom_conversion_tb(p_inventory_item_id)(p_from_uom_code).exists(p_to_uom_code)) THEN
      l_conversion_rate := g_item_uom_conversion_tb(p_inventory_item_id)(p_from_uom_code)(p_to_uom_code);
    ELSE
      inv_convert.inv_um_conversion(from_unit  => p_from_uom_code,
				    to_unit    => p_to_uom_code,
				    item_id    => p_inventory_item_id,
				    uom_rate   => l_conversion_rate);

      IF (l_conversion_rate < 0) THEN
	 RAISE fnd_api.g_exc_error;
      END IF;

      g_item_uom_conversion_tb(p_inventory_item_id)(p_from_uom_code)(p_to_uom_code) := l_conversion_rate;
      g_item_uom_conversion_tb(p_inventory_item_id)(p_to_uom_code)(p_from_uom_code) := 1 / l_conversion_rate;

   END IF;

   IF (l_debug = 1) THEN
      print_debug(' x_conversion_rate   => '||l_conversion_rate,l_module_name,4);
   END IF;

   RETURN l_conversion_rate;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred inside get_conversion_rate!',l_module_name,4);
      END IF;
      RETURN -1;
END get_conversion_rate;
END inv_rcv_cache;


/
