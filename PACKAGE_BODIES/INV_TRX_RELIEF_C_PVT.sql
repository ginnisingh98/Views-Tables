--------------------------------------------------------
--  DDL for Package Body INV_TRX_RELIEF_C_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRX_RELIEF_C_PVT" AS
/* $Header: INVRSV8B.pls 120.5.12010000.2 2010/06/28 09:20:01 viiyer ship $*/
--
g_pkg_name CONSTANT VARCHAR2(30) := 'INV_TRX_RELIEF_C_PVT';
TYPE query_cur_ref_type IS REF CURSOR; --3347075
PROCEDURE debug_print(p_message IN VARCHAR2, p_level IN NUMBER := 9)
  IS
     --Bug 3559328: Performance bug fix. The fnd_profile.value call was put in
     --debug_print. So, this gets called everytime we try to print to the debug
     --file. Removing the call from here.
     --l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- IF (l_debug = 1) THEN
   INV_LOG_UTIL.TRACE(p_message, 'INV_TRX_RELIEF_C_PVT', p_level);
   -- END IF;
END debug_print;

--
-- This procedure should be called only by TrxRsvRelief in inldqc.ppc
PROCEDURE rsv_relief
  ( x_return_status       OUT nocopy VARCHAR2, -- return status
    x_msg_count           OUT nocopy NUMBER,
    x_msg_data            OUT nocopy VARCHAR2,
    x_ship_qty            OUT nocopy NUMBER,   -- shipped quantity
    x_userline            OUT nocopy VARCHAR2, -- user line number
    x_demand_class        OUT nocopy VARCHAR2, -- demand class
    x_mps_flag            OUT nocopy NUMBER,   -- mrp installed or not (1 yes, 0 no)
    p_organization_id 	  IN  NUMBER,   -- org id
    p_inventory_item_id   IN  NUMBER,   -- inventory item id
    p_subinv              IN  VARCHAR2, -- subinventory
    p_locator             IN  NUMBER,   -- locator id
    p_lotnumber           IN  VARCHAR2, -- lot number
    p_revision            IN  VARCHAR2, -- revision
    p_dsrc_type       	  IN  NUMBER,   -- demand source type
    p_header_id       	  IN  NUMBER,   -- demand source header id
    p_dsrc_name           IN  VARCHAR2, -- demand source name
    p_dsrc_line           IN  NUMBER,   -- demand source line id
    p_dsrc_delivery       IN  NUMBER,   -- demand source delivery
    p_qty_at_puom         IN  NUMBER,   -- primary quantity
    p_lpn_id		  IN  NUMBER
  )
  IS
     l_primary_qty    	    NUMBER;
     l_reservation_id 	    NUMBER;
     l_rsv_rec        	    inv_reservation_global.mtl_reservation_rec_type;
     l_total_qty_to_relieve NUMBER;
     l_qty_to_relieve       NUMBER;
     l_qty_reserved         NUMBER;
     l_dummy_serial_numbers inv_reservation_global.serial_number_tbl_type;
     l_qty_relieved         NUMBER;
     l_remain_qty           NUMBER;
     l_ship_qty             NUMBER;
     l_msg_count            NUMBER;
     l_msg_data             VARCHAR2(240);
     l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_relieve_all          VARCHAR2(1);
     l_api_name             CONSTANT VARCHAR2(30) := 'rsv_relief';
     l_stmt                 VARCHAR2(10) := '0';
     -- begin declaration for 3347075
     l_rsv_cur2             query_cur_ref_type;
     l_demand_source        VARCHAR2(2000);
     l_miss_char            VARCHAR2(1);
     l_miss_num             NUMBER;
     l_supply_src_type_id   NUMBER := 13;
     -- end declaration for 3347075

      -- INVCONV BEGIN
     l_secondary_qty_relieved NUMBER; -- INVCONV
     l_secondary_remain_qty   NUMBER; -- INVCONV
     -- INVCONV END

     CURSOR l_mps_flag_cur IS
	SELECT 1 FROM dual WHERE exists (SELECT NULL FROM mrp_parameters);

     CURSOR l_oe_cur IS
        select to_char(line_number), demand_class_code
        from oe_order_lines_all
        where line_id = p_dsrc_line;

    /* CURSOR l_rsv_cur2 IS
	SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
	FROM mtl_reservations
	WHERE organization_id    	= p_organization_id
        AND   inventory_item_id  	= p_inventory_item_id
        AND   supply_source_type_id 	= 13 -- Inventory
        AND   ((subinventory_code  = p_subinv) OR
	      (subinventory_code IS NULL AND p_subinv IS NULL))
        AND   ((locator_id = p_locator) OR
	      (locator_id IS NULL AND p_locator IS NULL))
        AND   ((lot_number = p_lotnumber) OR
	      (lot_number IS NULL AND p_lotnumber IS NULL))
        AND   ((revision = p_revision) OR
	      (revision IS NULL AND p_revision IS NULL))
        AND   ((lpn_id = p_lpn_id) OR (lpn_id IS NULL))
        AND   demand_source_type_id = p_dsrc_type
        AND   ((demand_source_header_id = p_header_id) OR
	      (demand_source_header_id IS NULL AND (p_header_id = 0 or p_header_id IS NULL)))
        AND   ((demand_source_name = p_dsrc_name) OR
	      (demand_source_name IS NULL AND p_dsrc_name IS NULL))
	AND   ((p_dsrc_type NOT IN (2,8,12))
                OR  (p_dsrc_type IN (2,8,12)
                     AND ((demand_source_line_id = p_dsrc_line) OR
	                 (demand_source_line_id IS NULL
                          AND p_dsrc_line IS NULL))
                     AND ((demand_source_delivery = p_dsrc_delivery) OR
	                 (demand_source_delivery IS NULL
                          AND p_dsrc_delivery IS NULL))))
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE;  */
	-- commented the above for bug 3347075
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   l_stmt := '1';
   -- Begin changes for bug 3347075
   l_miss_char := fnd_api.g_miss_char;
   l_miss_num  := fnd_api.g_miss_num;
   -- End changes for bug 3347075
   x_return_status := fnd_api.g_ret_sts_success;

   IF (p_qty_at_puom IS NULL OR p_qty_at_puom < 0) THEN
      x_return_status := fnd_api.g_ret_sts_success;
      RETURN;
   END IF;

   l_stmt := '2';

   SAVEPOINT trx_relieve_sa;

   l_total_qty_to_relieve := p_qty_at_puom;

   l_stmt := '3';

   -- check if MRP is installed (might need to be changed)
   OPEN l_mps_flag_cur;
   FETCH l_mps_flag_cur INTO x_mps_flag;
   IF l_mps_flag_cur%notfound THEN
      x_mps_flag := 0;
   END IF;
   CLOSE l_mps_flag_cur;

   l_stmt := '4';

   -- open the appropriate cursor
   -- begin changes for bug 3347075
   -- OPEN l_rsv_cur2;
   IF (p_dsrc_type IN (2,8,12)) THEN
      IF  p_header_id <> l_miss_num AND p_header_id IS NOT NULL
          AND p_dsrc_line <> l_miss_num AND p_dsrc_line IS NOT NULL
	  AND p_dsrc_type <> l_miss_num AND p_dsrc_type IS NOT NULL THEN

          OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
	FROM mtl_reservations
	WHERE demand_source_header_id = :demand_source_header_id
	AND   demand_source_line_id = :demand_source_line_id
	AND   demand_source_type_id = :demand_source_type_id
        AND   supply_source_type_id = :supply_source_type_id
	AND   (:demand_source_delivery = :l_miss_num
	       OR :demand_source_delivery IS NULL
	       AND demand_source_delivery IS NULL
	       OR :demand_source_delivery = demand_source_delivery)
        AND   (:organization_id = :l_miss_num
	       OR :organization_id IS NULL
	       AND organization_id IS NULL
	       OR :organization_id = organization_id)
        AND   (:inventory_item_id = :l_miss_num
	       OR :inventory_item_id IS NULL
	       AND inventory_item_id IS NULL
	       OR :inventory_item_id = inventory_item_id)
        AND   (:subinventory_code = :l_miss_char
	       OR :subinventory_code IS NULL
	       AND subinventory_code IS NULL
	       OR :subinventory_code = subinventory_code)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id IS NULL
	       AND locator_id IS NULL
	       OR :locator_id = locator_id)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number IS NULL
	       AND lot_number IS NULL
	       OR :lot_number = lot_number)
        AND   (:revision = :l_miss_char
	       OR :revision IS NULL
	       AND revision IS NULL
	       OR :revision = revision)
        AND   (:lpn_id = :l_miss_num
	       OR   ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE '
	USING p_header_id
	    , p_dsrc_line
	    , p_dsrc_type
	    , l_supply_src_type_id
	    , p_dsrc_delivery
	    , l_miss_num
	    , p_dsrc_delivery
	    , p_dsrc_delivery
	    , p_organization_id
	    , l_miss_num
	    , p_organization_id
	    , p_organization_id
	    , p_inventory_item_id
	    , l_miss_num
	    , p_inventory_item_id
	    , p_inventory_item_id
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
       , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;

    ELSIF p_organization_id <> l_miss_num AND p_organization_id IS NOT NULL
       AND p_inventory_item_id <> l_miss_num AND p_inventory_item_id IS NOT NULL THEN

	  OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
	FROM mtl_reservations
	WHERE organization_id       = :organization_id
        AND   inventory_item_id     = :inventory_item_id
        AND   supply_source_type_id = :supply_source_type_id
	AND   (:demand_source_header_id = :l_miss_num
	       OR :demand_source_header_id IS NULL
	       AND demand_source_header_id IS NULL
	       OR :demand_source_header_id = demand_source_header_id)
        AND   (:demand_source_line_id = :l_miss_num
	       OR :demand_source_line_id IS NULL
	       AND demand_source_line_id IS NULL
	       OR :demand_source_line_id = demand_source_line_id)
        AND   (:demand_source_type_id = :l_miss_num
	       OR :demand_source_type_id IS NULL
	       AND demand_source_type_id IS NULL
	       OR :demand_source_type_id = demand_source_type_id)
	AND   (:demand_source_delivery = :l_miss_num
	       OR :demand_source_delivery IS NULL
	       AND demand_source_delivery IS NULL
	       OR :demand_source_delivery = demand_source_delivery)
        AND   (:subinventory_code = :l_miss_char
	       OR :subinventory_code IS NULL
	       AND subinventory_code IS NULL
	       OR :subinventory_code = subinventory_code)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id IS NULL
	       AND locator_id IS NULL
	       OR :locator_id = locator_id)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number IS NULL
	       AND lot_number IS NULL
	       OR :lot_number = lot_number)
        AND   (:revision = :l_miss_char
	       OR :revision IS NULL
	       AND revision IS NULL
	       OR :revision = revision)
        AND   (:lpn_id = :l_miss_num
	       OR ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE '
	USING p_organization_id
	    , p_inventory_item_id
	    , l_supply_src_type_id
	    , p_header_id
	    , l_miss_num
	    , p_header_id
	    , p_header_id
	    , p_dsrc_line
	    , l_miss_num
	    , p_dsrc_line
	    , p_dsrc_line
	    , p_dsrc_type
	    , l_miss_num
	    , p_dsrc_type
	    , p_dsrc_type
	    , p_dsrc_delivery
	    , l_miss_num
	    , p_dsrc_delivery
	    , p_dsrc_delivery
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
       , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;
   ELSE
       	  OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
	FROM mtl_reservations
	WHERE (:organization_id  = :l_miss_num
	       OR :organization_id IS NULL
	       AND organization_id IS NULL
	       OR :organization_id = organization_id)
        AND   (:inventory_item_id  = :l_miss_num
	       OR :inventory_item_id IS NULL
	       AND inventory_item_id IS NULL
	       OR :inventory_item_id = inventory_item_id)
        AND   supply_source_type_id = :supply_source_type_id
	AND   (:demand_source_header_id = :l_miss_num
	       OR :demand_source_header_id IS NULL
	       AND demand_source_header_id IS NULL
	       OR :demand_source_header_id = demand_source_header_id)
        AND   (:demand_source_line_id = :l_miss_num
	       OR :demand_source_line_id IS NULL
	       AND demand_source_line_id IS NULL
	       OR :demand_source_line_id = demand_source_line_id)
        AND   (:demand_source_type_id = :l_miss_num
	       OR :demand_source_type_id IS NULL
	       AND demand_source_type_id IS NULL
	       OR :demand_source_type_id = demand_source_type_id)
	AND   (:demand_source_delivery = :l_miss_num
	       OR :demand_source_delivery IS NULL
	       AND demand_source_delivery IS NULL
	       OR :demand_source_delivery = demand_source_delivery)
        AND   (:subinventory_code = :l_miss_char
	       OR :subinventory_code IS NULL
	       AND subinventory_code IS NULL
	       OR :subinventory_code = subinventory_code)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id IS NULL
	       AND locator_id IS NULL
	       OR :locator_id = locator_id)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number IS NULL
	       AND lot_number IS NULL
	       OR :lot_number = lot_number)
        AND   (:revision = :l_miss_char
	       OR :revision IS NULL
	       AND revision IS NULL
	       OR :revision = revision)
        AND   (:lpn_id = :l_miss_num
	       OR ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE '
	USING p_organization_id
	    , l_miss_num
	    , p_organization_id
	    , p_organization_id
	    , p_inventory_item_id
	    , l_miss_num
	    , p_inventory_item_id
	    , p_inventory_item_id
	    , l_supply_src_type_id
	    , p_header_id
	    , l_miss_num
	    , p_header_id
	    , p_header_id
	    , p_dsrc_line
	    , l_miss_num
	    , p_dsrc_line
	    , p_dsrc_line
	    , p_dsrc_type
	    , l_miss_num
	    , p_dsrc_type
	    , p_dsrc_type
	    , p_dsrc_delivery
	    , l_miss_num
	    , p_dsrc_delivery
	    , p_dsrc_delivery
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
       , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;

    END IF;
 ELSE
     --Bug 4376838 adding p_header_id <> 0, since for misc. issue p_header_id gets passed as 0.
     IF p_header_id <> l_miss_num AND p_header_id IS NOT NULL AND p_header_id <> 0
       AND p_dsrc_type <> l_miss_num AND p_dsrc_type IS NOT NULL THEN
     /* Bug 6072316 - For the below SQL, modified the where clause for the columns subinventory_code, locator_id,
                      lot_number, revision and the order by clause */

       OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
	FROM mtl_reservations
	WHERE demand_source_header_id = :demand_source_header_id
	AND   demand_source_type_id = :demand_source_type_id
        AND   supply_source_type_id = :supply_source_type_id
	AND   (:organization_id = :l_miss_num
	       OR :organization_id IS NULL
	       AND organization_id IS NULL
	       OR :organization_id = organization_id)
        AND   (:inventory_item_id = :l_miss_num
	       OR :inventory_item_id IS NULl
	       AND inventory_item_id IS NULL
	       OR :inventory_item_id = inventory_item_id)
        AND   (:subinventory_code = :l_miss_char
               OR :subinventory_code = subinventory_code
	       OR subinventory_code IS NULL)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id = locator_id
	       OR locator_id IS NULL)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number = lot_number
	       OR lot_number IS NULL)
        AND   (:revision = :l_miss_char
	       OR :revision = revision
	       OR revision IS NULL)
        AND   (:lpn_id = :l_miss_num
	       OR ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY lpn_id, revision, lot_number, subinventory_code, locator_id FOR UPDATE '
	USING p_header_id
	    , p_dsrc_type
	    , l_supply_src_type_id
	    , p_organization_id
	    , l_miss_num
	    , p_organization_id
	    , p_organization_id
	    , p_inventory_item_id
	    , l_miss_num
	    , p_inventory_item_id
	    , p_inventory_item_id
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
       , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;
     ELSIF p_organization_id <> l_miss_num AND p_organization_id IS NOT NULL
          AND p_inventory_item_id <> l_miss_num AND p_inventory_item_id IS NOT NULL THEN

        --Bug 4376838 adding :demand_source_header_id = 0, since for misc. issue p_header_id gets passed as 0.
         /* Bug 6921615  - For the below SQL, modified the where clause for the columns subinventory_code, locator_id,
                      lot_number, revision and the order by clause */
        OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
	FROM mtl_reservations
	WHERE organization_id = :organization_id
	AND   inventory_item_id = :inventory_item_id
        AND   supply_source_type_id = :supply_source_type_id
	AND   (:demand_source_header_id = :l_miss_num
	       OR :demand_source_header_id IS NULL OR :demand_source_header_id = 0
	       AND demand_source_header_id IS NULL
	       OR :demand_source_header_id = demand_source_header_id)
        AND   (:demand_source_type_id = :l_miss_num
	       OR :demand_source_type_id IS NULL
	       AND demand_source_type_id IS NULL
	       OR :demand_source_type_id = demand_source_type_id)
        AND   (:subinventory_code = :l_miss_char
               OR :subinventory_code = subinventory_code
	       OR subinventory_code IS NULL)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id = locator_id
	       OR locator_id IS NULL)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number = lot_number
	       OR lot_number IS NULL)
        AND   (:revision = :l_miss_char
	       OR :revision = revision
	       OR revision IS NULL)
        AND   (:lpn_id = :l_miss_num
	       OR ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY lpn_id, revision, lot_number, subinventory_code, locator_id FOR UPDATE '
	USING p_organization_id
	    , p_inventory_item_id
	    , l_supply_src_type_id
	    , p_header_id
	    , l_miss_num
	    , p_header_id
	    , p_header_id
            , p_header_id       --Added for bug 4376838
	    , p_dsrc_type
	    , l_miss_num
	    , p_dsrc_type
	    , p_dsrc_type
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
            , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;
     ELSE
         --Bug 4376838 adding :demand_source_header_id = 0, since for misc. issue p_header_id gets passed as 0.
         OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
	FROM mtl_reservations
	WHERE supply_source_type_id = :supply_source_type_id
        AND   (:demand_source_header_id = :l_miss_num
	       OR :demand_source_header_id IS NULL OR :demand_source_header_id = 0
	       AND demand_source_header_id IS NULL
	       OR :demand_source_header_id = demand_source_header_id)
        AND   (:demand_source_type_id = :l_miss_num
	       OR :demand_source_type_id IS NULL
	       AND demand_source_type_id IS NULL
	       OR :demand_source_type_id = demand_source_type_id)
	AND   (:organization_id = :l_miss_num
	       OR :organization_id IS NULL
	       AND organization_id IS NULL
	       OR :organization_id = organization_id)
        AND   (:inventory_item_id = :l_miss_num
	       OR :inventory_item_id IS NULl
	       AND inventory_item_id IS NULL
	       OR :inventory_item_id = inventory_item_id)
        AND   (:subinventory_code = :l_miss_char
	       OR :subinventory_code IS NULL
	       AND subinventory_code IS NULL
	       OR :subinventory_code = subinventory_code)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id IS NULL
	       AND locator_id IS NULL
	       OR :locator_id = locator_id)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number IS NULL
	       AND lot_number IS NULL
	       OR :lot_number = lot_number)
        AND   (:revision = :l_miss_char
	       OR :revision IS NULL
	       AND revision IS NULL
	       OR :revision = revision)
        AND   (:lpn_id = :l_miss_num
	       OR ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE '
	USING l_supply_src_type_id
	    , p_header_id
	    , l_miss_num
	    , p_header_id
	    , p_header_id
	    , p_header_id     --Added for Bug 4376838
	    , p_dsrc_type
	    , l_miss_num
	    , p_dsrc_type
	    , p_dsrc_type
	    , p_organization_id
	    , l_miss_num
	    , p_organization_id
	    , p_organization_id
	    , p_inventory_item_id
	    , l_miss_num
	    , p_inventory_item_id
	    , p_inventory_item_id
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
       , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;
     END IF;
 END IF;
-- end changes for bug 3347075
   l_stmt := '5';

   -- Added debug messages
      IF (l_debug = 1) THEN
         debug_print('l total qty to relieve ' || l_total_qty_to_relieve);
   END IF;
   -- fetch reservation records and do relief
   WHILE (l_total_qty_to_relieve is not null AND
          l_total_qty_to_relieve > 0) LOOP

      l_stmt := '6';

      FETCH l_rsv_cur2 INTO
		l_reservation_id,
		l_qty_reserved;
      IF l_rsv_cur2%notfound THEN
	    l_reservation_id := NULL;
      END IF;

      l_stmt := '9';

         IF (l_debug = 1) THEN
            debug_print('Inside l_rsv_cur2 cursor');
            debug_print(' reservation id ' ||l_reservation_id || ' qty reserved = primary - detailed ' || l_qty_reserved);
      END IF;

      -- exit the loop if no more reservation to relieve
      IF l_reservation_id IS NULL THEN
	 EXIT;
      END IF;

      l_stmt := '10';

      -- call reservation api to relieve the reservation
      l_rsv_rec.reservation_id := l_reservation_id;

      l_stmt := '11';

      IF l_total_qty_to_relieve > l_qty_reserved THEN
	 l_qty_to_relieve := l_qty_reserved;
       ELSE
	 l_qty_to_relieve := l_total_qty_to_relieve;
      END IF;

      l_stmt := '12';

      IF l_qty_to_relieve = l_qty_reserved THEN
		  l_relieve_all := fnd_api.g_true;
   		   IF (l_debug = 1) THEN
      		   debug_print(' relieve all');
		   END IF;
       ELSE
		  l_relieve_all := fnd_api.g_false;
   		  IF (l_debug = 1) THEN
      		  debug_print('dont  relieve all');
   		  END IF;
      END IF;

		  l_stmt := '13';
   		  IF (l_debug = 1) THEN
      		  debug_print(' before calling relieve rsv. Qty to relieve
			      = ' || l_qty_to_relieve || ' relieve all ' ||  l_relieve_all);
		  END IF;

      inv_reservation_pvt.relieve_reservation
	(p_api_version_number          => 1.0,
	 p_init_msg_lst                => fnd_api.g_false,
	 x_return_status               => l_return_status,
	 x_msg_count                   => l_msg_count,
	 x_msg_data                    => l_msg_data,
	 p_rsv_rec                     => l_rsv_rec,
	 p_primary_relieved_quantity   => l_qty_to_relieve,
         p_secondary_relieved_quantity => NULL,          -- INVCONV
	 p_relieve_all                 => l_relieve_all,
	 p_original_serial_number      => l_dummy_serial_numbers,
	 p_validation_flag             => fnd_api.g_true,
	 x_primary_relieved_quantity   => l_qty_relieved,
         x_secondary_relieved_quantity => l_secondary_qty_relieved, -- INVCONV
	 x_primary_remain_quantity     => l_remain_qty,
         x_secondary_remain_quantity   => l_secondary_remain_qty    -- INVCONV
	 );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt := '14';

         IF (l_debug = 1) THEN
            debug_print(' after calling relieve rsv. Qty relieved = ' ||
		  l_qty_relieved || ' primary remaining qty = ' ||
		  l_remain_qty);
      END IF;

      l_total_qty_to_relieve := l_total_qty_to_relieve - l_qty_relieved;

         IF (l_debug = 1) THEN
            debug_print (' total qty TO relieve ' || l_total_qty_to_relieve);
      END IF;
   END LOOP;

   if (p_dsrc_type in (inv_reservation_global.g_source_type_oe,
                       inv_reservation_global.g_source_type_internal_ord)) then
      l_stmt := '15';

      open l_oe_cur ;
      fetch l_oe_cur into
        x_userline,
        x_demand_class;
   end if;

   l_stmt := '16';

   -- BUG 2666911. From now on, the x_ship_qty will be used to pass the
   -- actual relieved quantity. Change has been made in the relieve MRP API
   -- to check for the ship quantity and call the MPR relief interface
   -- whether the reservation quantity is relieved or not.
   -- The x_ship_qty will be henceforth be used to compare the actual ship
   -- quantity with the relieved quantity to see if the quantity tree
   -- validation has to be done or not.

   x_ship_qty := p_qty_at_puom - l_total_qty_to_relieve;

   IF (l_debug = 1) THEN
      debug_print (' p_qty_at_uom ' || p_qty_at_puom || ' L-total-qty-to-relieve ' || l_total_qty_to_relieve);
      debug_print (' Ship qty after calling l_oe_cur ' || x_ship_qty);
   END IF;

   l_stmt := '17';

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO trx_relieve_sa;
        x_return_status := fnd_api.g_ret_sts_error;

        l_stmt := 'Stmt' || l_stmt;
        fnd_message.set_name('INV', 'INV-Request failed');
        fnd_message.set_token('ENTITY',l_api_name);
        fnd_message.set_token('ERRORCODE',l_stmt);
        fnd_msg_pub.add;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO trx_relieve_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        l_stmt := 'Stmt' || l_stmt;
        fnd_message.set_name('INV', 'INV-Request failed');
        fnd_message.set_token('ENTITY',l_api_name);
        fnd_message.set_token('ERRORCODE',l_stmt);
        fnd_msg_pub.add;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
   WHEN OTHERS THEN
        ROLLBACK TO trx_relieve_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        l_stmt := 'Stmt' || l_stmt;
        fnd_message.set_name('INV', 'INV-Request failed');
        fnd_message.set_token('ENTITY',l_api_name);
        fnd_message.set_token('ERRORCODE',l_stmt);
        fnd_msg_pub.add;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END rsv_relief;

-- INVCONV NOTE
-- This is an overload of rsv_relief to handle input/output of secondary quantities
PROCEDURE rsv_relief
  ( x_return_status       OUT nocopy VARCHAR2, -- return status
    x_msg_count           OUT nocopy NUMBER,
    x_msg_data            OUT nocopy VARCHAR2,
    x_ship_qty            OUT nocopy NUMBER,   -- shipped quantity
    x_secondary_ship_qty  OUT nocopy NUMBER,   -- secondary shipped quantity  INVCONV
    x_userline            OUT nocopy VARCHAR2, -- user line number
    x_demand_class        OUT nocopy VARCHAR2, -- demand class
    x_mps_flag            OUT nocopy NUMBER,   -- mrp installed or not (1 yes, 0 no)
    p_organization_id 	  IN  NUMBER,   -- org id
    p_inventory_item_id   IN  NUMBER,   -- inventory item id
    p_subinv              IN  VARCHAR2, -- subinventory
    p_locator             IN  NUMBER,   -- locator id
    p_lotnumber           IN  VARCHAR2, -- lot number
    p_revision            IN  VARCHAR2, -- revision
    p_dsrc_type       	  IN  NUMBER,   -- demand source type
    p_header_id       	  IN  NUMBER,   -- demand source header id
    p_dsrc_name           IN  VARCHAR2, -- demand source name
  p_dsrc_line           IN  NUMBER,   -- demand source line id
  p_dsrc_delivery       IN  NUMBER,   -- demand source delivery
  p_qty_at_puom         IN  NUMBER,   -- primary quantity
  p_qty_at_suom         IN  NUMBER,   -- secondary quantity      INVCONV
  p_lpn_id		  IN  NUMBER,
  p_transaction_id      IN NUMBER   DEFAULT NULL -- Bug 3517647: Passing transaction id
  )
  IS
     l_primary_qty    	    NUMBER;
     l_reservation_id 	    NUMBER;
     l_rsv_rec        	    inv_reservation_global.mtl_reservation_rec_type;
     l_total_qty_to_relieve NUMBER;
     l_total_secondary_to_relieve NUMBER;   -- INVCONV
     l_qty_to_relieve       NUMBER;
     l_secondary_to_relieve NUMBER;         -- INVCONV
     l_qty_reserved         NUMBER;
     l_secondary_qty_reserved NUMBER;       -- INVCONV
     l_original_serial_numbers inv_reservation_global.serial_number_tbl_type;
     l_qty_relieved         NUMBER;
     l_secondary_qty_relieved NUMBER;       -- INVCONV
     l_remain_qty           NUMBER;
     l_secondary_remain_qty NUMBER;         -- INVCONV
     l_ship_qty             NUMBER;
     l_msg_count            NUMBER;
     l_msg_data             VARCHAR2(240);
     l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_relieve_all          VARCHAR2(1);
     l_api_name             CONSTANT VARCHAR2(30) := 'rsv_relief';
     l_stmt                 VARCHAR2(10) := '0';
     -- begin declaration for 3347075
     l_rsv_cur2             query_cur_ref_type;
     l_demand_source        VARCHAR2(2000);
     l_miss_char            VARCHAR2(1);
     l_miss_num             NUMBER;
     l_supply_src_type_id   NUMBER := 13;
     -- end declaration for 3347075
     l_tracking_quantity_ind VARCHAR2(30);           -- INVCONV
     l_serial_number_table inv_reservation_global.serial_number_tbl_type;

     CURSOR l_mps_flag_cur IS
	SELECT 1 FROM dual WHERE exists (SELECT NULL FROM mrp_parameters);

     CURSOR l_oe_cur IS
        select to_char(line_number), demand_class_code
        from oe_order_lines_all
        where line_id = p_dsrc_line;

     -- INVCONV BEGIN
     CURSOR l_tracking_qty_cur IS
        select tracking_quantity_ind
        from mtl_system_items
        where organization_id = p_organization_id and inventory_item_id = p_inventory_item_id;
     -- INVCONV END

    /* CURSOR l_rsv_cur2 IS
	SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
	FROM mtl_reservations
	WHERE organization_id    	= p_organization_id
        AND   inventory_item_id  	= p_inventory_item_id
        AND   supply_source_type_id 	= 13 -- Inventory
        AND   ((subinventory_code  = p_subinv) OR
	      (subinventory_code IS NULL AND p_subinv IS NULL))
        AND   ((locator_id = p_locator) OR
	      (locator_id IS NULL AND p_locator IS NULL))
        AND   ((lot_number = p_lotnumber) OR
	      (lot_number IS NULL AND p_lotnumber IS NULL))
        AND   ((revision = p_revision) OR
	      (revision IS NULL AND p_revision IS NULL))
        AND   ((lpn_id = p_lpn_id) OR (lpn_id IS NULL))
        AND   demand_source_type_id = p_dsrc_type
        AND   ((demand_source_header_id = p_header_id) OR
	      (demand_source_header_id IS NULL AND (p_header_id = 0 or p_header_id IS NULL)))
        AND   ((demand_source_name = p_dsrc_name) OR
	      (demand_source_name IS NULL AND p_dsrc_name IS NULL))
	AND   ((p_dsrc_type NOT IN (2,8,12))
                OR  (p_dsrc_type IN (2,8,12)
                     AND ((demand_source_line_id = p_dsrc_line) OR
	                 (demand_source_line_id IS NULL
                          AND p_dsrc_line IS NULL))
                     AND ((demand_source_delivery = p_dsrc_delivery) OR
	                 (demand_source_delivery IS NULL
                          AND p_dsrc_delivery IS NULL))))
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE;  */
	-- commented the above for bug 3347075
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   l_stmt := '1';
   -- Begin changes for bug 3347075
   l_miss_char := fnd_api.g_miss_char;
   l_miss_num  := fnd_api.g_miss_num;
   -- End changes for bug 3347075
   x_return_status := fnd_api.g_ret_sts_success;

   IF (p_qty_at_puom IS NULL OR p_qty_at_puom < 0) THEN
      x_return_status := fnd_api.g_ret_sts_success;
      RETURN;
   END IF;

   l_stmt := '2';

   SAVEPOINT trx_relieve_sa;

   -- INVCONV BEGIN
   OPEN l_tracking_qty_cur;
   FETCH l_tracking_qty_cur INTO l_tracking_quantity_ind;
   IF l_tracking_qty_cur%notfound THEN
     RAISE fnd_api.g_exc_error;
   END IF;
   -- INVCONV END

   l_total_qty_to_relieve := p_qty_at_puom;

   -- INVCONV BEGIN
   IF l_tracking_quantity_ind = 'PS' THEN
     l_total_secondary_to_relieve := p_qty_at_suom;             -- INVCONV
   END IF;
   -- INVCONV END

   l_stmt := '3';

   -- check if MRP is installed (might need to be changed)
   OPEN l_mps_flag_cur;
   FETCH l_mps_flag_cur INTO x_mps_flag;
   IF l_mps_flag_cur%notfound THEN
      x_mps_flag := 0;
   END IF;
   CLOSE l_mps_flag_cur;

   l_stmt := '4';


   -- open the appropriate cursor
   -- begin changes for bug 3347075
   -- OPEN l_rsv_cur2;
   -- Bug 4764790: Need to relieve for CMRO jobs based on the
   -- relieve reservations flag in MMTT

   IF (p_dsrc_type IN (2,8,12)) THEN
      IF  p_header_id <> l_miss_num AND p_header_id IS NOT NULL
          AND p_dsrc_line <> l_miss_num AND p_dsrc_line IS NOT NULL
	  AND p_dsrc_type <> l_miss_num AND p_dsrc_type IS NOT NULL THEN

          OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
        , NVL(secondary_reservation_quantity,0) - NVL(secondary_detailed_quantity,0) -- INVCONV
	FROM mtl_reservations
	WHERE demand_source_header_id = :demand_source_header_id
	AND   demand_source_line_id = :demand_source_line_id
	AND   demand_source_type_id = :demand_source_type_id
        AND   supply_source_type_id = :supply_source_type_id
	AND   (:demand_source_delivery = :l_miss_num
	       OR :demand_source_delivery IS NULL
	       AND demand_source_delivery IS NULL
	       OR :demand_source_delivery = demand_source_delivery)
        AND   (:organization_id = :l_miss_num
	       OR :organization_id IS NULL
	       AND organization_id IS NULL
	       OR :organization_id = organization_id)
        AND   (:inventory_item_id = :l_miss_num
	       OR :inventory_item_id IS NULL
	       AND inventory_item_id IS NULL
	       OR :inventory_item_id = inventory_item_id)
        AND   (:subinventory_code = :l_miss_char
	       OR :subinventory_code IS NULL
	       AND subinventory_code IS NULL
	       OR :subinventory_code = subinventory_code)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id IS NULL
	       AND locator_id IS NULL
	       OR :locator_id = locator_id)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number IS NULL
	       AND lot_number IS NULL
	       OR :lot_number = lot_number)
        AND   (:revision = :l_miss_char
	       OR :revision IS NULL
	       AND revision IS NULL
	       OR :revision = revision)
        AND   (:lpn_id = :l_miss_num
	       OR   ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE '
	USING p_header_id
	    , p_dsrc_line
	    , p_dsrc_type
	    , l_supply_src_type_id
	    , p_dsrc_delivery
	    , l_miss_num
	    , p_dsrc_delivery
	    , p_dsrc_delivery
	    , p_organization_id
	    , l_miss_num
	    , p_organization_id
	    , p_organization_id
	    , p_inventory_item_id
	    , l_miss_num
	    , p_inventory_item_id
	    , p_inventory_item_id
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
       , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;

    ELSIF p_organization_id <> l_miss_num AND p_organization_id IS NOT NULL
       AND p_inventory_item_id <> l_miss_num AND p_inventory_item_id IS NOT NULL THEN

	  OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
        , NVL(secondary_reservation_quantity,0) - NVL(secondary_detailed_quantity,0) -- INVCONV
	FROM mtl_reservations
	WHERE organization_id       = :organization_id
        AND   inventory_item_id     = :inventory_item_id
        AND   supply_source_type_id = :supply_source_type_id
	AND   (:demand_source_header_id = :l_miss_num
	       OR :demand_source_header_id IS NULL
	       AND demand_source_header_id IS NULL
	       OR :demand_source_header_id = demand_source_header_id)
        AND   (:demand_source_line_id = :l_miss_num
	       OR :demand_source_line_id IS NULL
	       AND demand_source_line_id IS NULL
	       OR :demand_source_line_id = demand_source_line_id)
        AND   (:demand_source_type_id = :l_miss_num
	       OR :demand_source_type_id IS NULL
	       AND demand_source_type_id IS NULL
	       OR :demand_source_type_id = demand_source_type_id)
	AND   (:demand_source_delivery = :l_miss_num
	       OR :demand_source_delivery IS NULL
	       AND demand_source_delivery IS NULL
	       OR :demand_source_delivery = demand_source_delivery)
        AND   (:subinventory_code = :l_miss_char
	       OR :subinventory_code IS NULL
	       AND subinventory_code IS NULL
	       OR :subinventory_code = subinventory_code)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id IS NULL
	       AND locator_id IS NULL
	       OR :locator_id = locator_id)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number IS NULL
	       AND lot_number IS NULL
	       OR :lot_number = lot_number)
        AND   (:revision = :l_miss_char
	       OR :revision IS NULL
	       AND revision IS NULL
	       OR :revision = revision)
        AND   (:lpn_id = :l_miss_num
	       OR ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE '
	USING p_organization_id
	    , p_inventory_item_id
	    , l_supply_src_type_id
	    , p_header_id
	    , l_miss_num
	    , p_header_id
	    , p_header_id
	    , p_dsrc_line
	    , l_miss_num
	    , p_dsrc_line
	    , p_dsrc_line
	    , p_dsrc_type
	    , l_miss_num
	    , p_dsrc_type
	    , p_dsrc_type
	    , p_dsrc_delivery
	    , l_miss_num
	    , p_dsrc_delivery
	    , p_dsrc_delivery
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
       , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;
   ELSE
       	  OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
        , NVL(secondary_reservation_quantity,0) - NVL(secondary_detailed_quantity,0) -- INVCONV
	FROM mtl_reservations
	WHERE (:organization_id  = :l_miss_num
	       OR :organization_id IS NULL
	       AND organization_id IS NULL
	       OR :organization_id = organization_id)
        AND   (:inventory_item_id  = :l_miss_num
	       OR :inventory_item_id IS NULL
	       AND inventory_item_id IS NULL
	       OR :inventory_item_id = inventory_item_id)
        AND   supply_source_type_id = :supply_source_type_id
	AND   (:demand_source_header_id = :l_miss_num
	       OR :demand_source_header_id IS NULL
	       AND demand_source_header_id IS NULL
	       OR :demand_source_header_id = demand_source_header_id)
        AND   (:demand_source_line_id = :l_miss_num
	       OR :demand_source_line_id IS NULL
	       AND demand_source_line_id IS NULL
	       OR :demand_source_line_id = demand_source_line_id)
        AND   (:demand_source_type_id = :l_miss_num
	       OR :demand_source_type_id IS NULL
	       AND demand_source_type_id IS NULL
	       OR :demand_source_type_id = demand_source_type_id)
	AND   (:demand_source_delivery = :l_miss_num
	       OR :demand_source_delivery IS NULL
	       AND demand_source_delivery IS NULL
	       OR :demand_source_delivery = demand_source_delivery)
        AND   (:subinventory_code = :l_miss_char
	       OR :subinventory_code IS NULL
	       AND subinventory_code IS NULL
	       OR :subinventory_code = subinventory_code)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id IS NULL
	       AND locator_id IS NULL
	       OR :locator_id = locator_id)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number IS NULL
	       AND lot_number IS NULL
	       OR :lot_number = lot_number)
        AND   (:revision = :l_miss_char
	       OR :revision IS NULL
	       AND revision IS NULL
	       OR :revision = revision)
        AND   (:lpn_id = :l_miss_num
	       OR ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE '
	USING p_organization_id
	    , l_miss_num
	    , p_organization_id
	    , p_organization_id
	    , p_inventory_item_id
	    , l_miss_num
	    , p_inventory_item_id
	    , p_inventory_item_id
	    , l_supply_src_type_id
	    , p_header_id
	    , l_miss_num
	    , p_header_id
	    , p_header_id
	    , p_dsrc_line
	    , l_miss_num
	    , p_dsrc_line
	    , p_dsrc_line
	    , p_dsrc_type
	    , l_miss_num
	    , p_dsrc_type
	    , p_dsrc_type
	    , p_dsrc_delivery
	    , l_miss_num
	    , p_dsrc_delivery
	    , p_dsrc_delivery
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
       , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;

    END IF;
 ELSE
 --Bug# 9856174: Added p_header_id <> 0
     IF p_header_id <> l_miss_num AND p_header_id IS NOT NULL  AND p_header_id <> 0
       AND p_dsrc_type <> l_miss_num AND p_dsrc_type IS NOT NULL THEN

       OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
        , NVL(secondary_reservation_quantity,0) - NVL(secondary_detailed_quantity,0) -- INVCONV
	FROM mtl_reservations
	WHERE demand_source_header_id = :demand_source_header_id
	AND   demand_source_type_id = :demand_source_type_id
        AND   supply_source_type_id = :supply_source_type_id
	AND   (:organization_id = :l_miss_num
	       OR :organization_id IS NULL
	       AND organization_id IS NULL
	       OR :organization_id = organization_id)
        AND   (:inventory_item_id = :l_miss_num
	       OR :inventory_item_id IS NULl
	       AND inventory_item_id IS NULL
	       OR :inventory_item_id = inventory_item_id)
        AND   (:subinventory_code = :l_miss_char
	       OR :subinventory_code IS NULL
	       AND subinventory_code IS NULL
	       OR :subinventory_code = subinventory_code)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id IS NULL
	       AND locator_id IS NULL
	       OR :locator_id = locator_id)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number IS NULL
	       AND lot_number IS NULL
	       OR :lot_number = lot_number)
        AND   (:revision = :l_miss_char
	       OR :revision IS NULL
	       AND revision IS NULL
	       OR :revision = revision)
        AND   (:lpn_id = :l_miss_num
	       OR ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE '
	USING p_header_id
	    , p_dsrc_type
	    , l_supply_src_type_id
	    , p_organization_id
	    , l_miss_num
	    , p_organization_id
	    , p_organization_id
	    , p_inventory_item_id
	    , l_miss_num
	    , p_inventory_item_id
	    , p_inventory_item_id
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
       , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;
     ELSIF p_organization_id <> l_miss_num AND p_organization_id IS NOT NULL
          AND p_inventory_item_id <> l_miss_num AND p_inventory_item_id IS NOT NULL THEN

        OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
        , NVL(secondary_reservation_quantity,0) - NVL(secondary_detailed_quantity,0) -- INVCONV
	FROM mtl_reservations
	WHERE organization_id = :organization_id
	AND   inventory_item_id = :inventory_item_id
        AND   supply_source_type_id = :supply_source_type_id
	AND   (:demand_source_header_id = :l_miss_num
	       OR :demand_source_header_id IS NULL OR :demand_source_header_id = 0 --Bug# 9856174
	       AND demand_source_header_id IS NULL
	       OR :demand_source_header_id = demand_source_header_id)
        AND   (:demand_source_type_id = :l_miss_num
	       OR :demand_source_type_id IS NULL
	       AND demand_source_type_id IS NULL
	       OR :demand_source_type_id = demand_source_type_id)
        AND   (:subinventory_code = :l_miss_char
	       OR :subinventory_code IS NULL
	       AND subinventory_code IS NULL
	       OR :subinventory_code = subinventory_code)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id IS NULL
	       AND locator_id IS NULL
	       OR :locator_id = locator_id)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number IS NULL
	       AND lot_number IS NULL
	       OR :lot_number = lot_number)
        AND   (:revision = :l_miss_char
	       OR :revision IS NULL
	       AND revision IS NULL
	       OR :revision = revision)
        AND   (:lpn_id = :l_miss_num
	       OR ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE '
	USING p_organization_id
	    , p_inventory_item_id
	    , l_supply_src_type_id
	    , p_header_id
	    , l_miss_num
	    , p_header_id
	    , p_header_id
	    , p_header_id --Bug# 9856174
	    , p_dsrc_type
	    , l_miss_num
	    , p_dsrc_type
	    , p_dsrc_type
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
       , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;
     ELSE

         OPEN l_rsv_cur2 FOR  ' SELECT
          reservation_id
        , primary_reservation_quantity - NVL(detailed_quantity,0)
        , NVL(secondary_reservation_quantity,0) - NVL(secondary_detailed_quantity,0) -- INVCONV
	FROM mtl_reservations
	WHERE supply_source_type_id = :supply_source_type_id
        AND   (:demand_source_header_id = :l_miss_num
	       OR :demand_source_header_id IS NULL OR :demand_source_header_id = 0 --Bug# 9856174
	       AND demand_source_header_id IS NULL
	       OR :demand_source_header_id = demand_source_header_id)
        AND   (:demand_source_type_id = :l_miss_num
	       OR :demand_source_type_id IS NULL
	       AND demand_source_type_id IS NULL
	       OR :demand_source_type_id = demand_source_type_id)
	AND   (:organization_id = :l_miss_num
	       OR :organization_id IS NULL
	       AND organization_id IS NULL
	       OR :organization_id = organization_id)
        AND   (:inventory_item_id = :l_miss_num
	       OR :inventory_item_id IS NULl
	       AND inventory_item_id IS NULL
	       OR :inventory_item_id = inventory_item_id)
        AND   (:subinventory_code = :l_miss_char
	       OR :subinventory_code IS NULL
	       AND subinventory_code IS NULL
	       OR :subinventory_code = subinventory_code)
        AND   (:locator_id = :l_miss_num
	       OR :locator_id IS NULL
	       AND locator_id IS NULL
	       OR :locator_id = locator_id)
        AND   (:lot_number = :l_miss_char
	       OR :lot_number IS NULL
	       AND lot_number IS NULL
	       OR :lot_number = lot_number)
        AND   (:revision = :l_miss_char
	       OR :revision IS NULL
	       AND revision IS NULL
	       OR :revision = revision)
        AND   (:lpn_id = :l_miss_num
	       OR ((lpn_id IS NULL) OR (:lpn_id = lpn_id)))
        AND   (:demand_source_name = :l_miss_char
	       OR :demand_source_name IS NULL
	       AND demand_source_name IS NULL
	       OR :demand_source_name = demand_source_name)
        AND (primary_reservation_quantity - NVL(detailed_quantity,0)) > 0
	ORDER BY NVL(lpn_id, 0) DESC, reservation_id FOR UPDATE '
	USING l_supply_src_type_id
	    , p_header_id
	    , l_miss_num
	    , p_header_id
	    , p_header_id
	    , p_header_id --Bug# 9856174
	    , p_dsrc_type
	    , l_miss_num
	    , p_dsrc_type
	    , p_dsrc_type
	    , p_organization_id
	    , l_miss_num
	    , p_organization_id
	    , p_organization_id
	    , p_inventory_item_id
	    , l_miss_num
	    , p_inventory_item_id
	    , p_inventory_item_id
	    , p_subinv
	    , l_miss_char
	    , p_subinv
	    , p_subinv
	    , p_locator
	    , l_miss_num
	    , p_locator
	    , p_locator
	    , p_lotnumber
	    , l_miss_char
	    , p_lotnumber
	    , p_lotnumber
	    , p_revision
	    , l_miss_char
	    , p_revision
	    , p_revision
	    , p_lpn_id
	    , l_miss_num
	    , p_lpn_id
       , p_dsrc_name
	    , l_miss_char
	    , p_dsrc_name
	    , p_dsrc_name ;
     END IF;
 END IF;
-- end changes for bug 3347075
   l_stmt := '5';

   -- Added debug messages
   IF (l_debug = 1) THEN
      debug_print('l total qty to relieve ' || l_total_qty_to_relieve);
   END IF;
   -- fetch reservation records and do relief
   WHILE (l_total_qty_to_relieve is not null AND
          l_total_qty_to_relieve > 0) LOOP

      l_stmt := '6';

      FETCH l_rsv_cur2 INTO
		l_reservation_id,
		l_qty_reserved,
                l_secondary_qty_reserved;              -- INVCONV
      IF l_rsv_cur2%notfound THEN
	    l_reservation_id := NULL;
      END IF;

      l_stmt := '9';

         IF (l_debug = 1) THEN
            debug_print('Inside l_rsv_cur2 cursor');
            debug_print(' reservation id ' ||l_reservation_id || ' qty reserved = primary - detailed ' || l_qty_reserved);
            debug_print('secondary qty reserved ' || l_secondary_qty_reserved);  --INVCONV
      END IF;

      -- exit the loop if no more reservation to relieve
      IF l_reservation_id IS NULL THEN
	 EXIT;
      END IF;

      l_stmt := '10';

      -- call reservation api to relieve the reservation
      l_rsv_rec.reservation_id := l_reservation_id;

      l_stmt := '11';

      IF l_total_qty_to_relieve > l_qty_reserved THEN
	 l_qty_to_relieve := l_qty_reserved;
          -- INVCONV BEGIN
         IF l_tracking_quantity_ind = 'PS' THEN
           l_secondary_to_relieve := l_secondary_qty_reserved;
         END IF;
         -- INVCONV END
       ELSE
	 l_qty_to_relieve := l_total_qty_to_relieve;
         -- INVCONV BEGIN
         IF l_tracking_quantity_ind = 'PS' THEN
           l_secondary_to_relieve := l_total_secondary_to_relieve;
         END IF;
         -- INVCONV END
      END IF;

      l_stmt := '12';

      IF l_qty_to_relieve = l_qty_reserved THEN
	 l_relieve_all := fnd_api.g_true;
	 IF (l_debug = 1) THEN
	    debug_print(' relieve all');
	 END IF;
       ELSE
	 l_relieve_all := fnd_api.g_false;
	 IF (l_debug = 1) THEN
	    debug_print('dont  relieve all');
	 END IF;
	 --Bug 4764790: Query the serials for that reservation id
	 --that are being transacted and pass them to
	 -- relieve_reservations API - only if not all are
	 -- relieved. If relieve all is true, we will unreserve
	 --the serials anyways

         BEGIN
	    SELECT msn.inventory_item_id, msn.serial_number bulk collect INTO
	      l_serial_number_table FROM
	      mtl_serial_numbers msn, mtl_unit_transactions mut  WHERE
	      msn.reservation_id = l_reservation_id AND msn.current_organization_id =
	      p_organization_id AND msn.inventory_item_id = p_inventory_item_id
	      AND mut.transaction_id = p_transaction_id AND msn.serial_number =
	      mut.serial_number AND msn.inventory_item_id = mut.inventory_item_id
	      AND msn.current_organization_id = mut.organization_id;
	 EXCEPTION WHEN no_data_found THEN
	    IF (l_debug = 1) THEN
	       debug_print('No serial numbers reserved for this transaction.' || l_total_qty_to_relieve);
	    END IF;
	 END;

	 IF (l_serial_number_table.COUNT > 0) THEN
	    l_original_serial_numbers := l_serial_number_table;
	 END IF;
	 -- End Bug  Fix 4764790

      END IF;

      l_stmt := '13';
      IF (l_debug = 1) THEN
	 debug_print(' before calling relieve rsv. Qty to relieve = ' || l_qty_to_relieve || ' relieve all ' ||  l_relieve_all);
	 debug_print(' before calling relieve rsv. Secondary to relieve = ' || l_secondary_to_relieve ); 				-- INVCONV
      END IF;

      inv_reservation_pvt.relieve_reservation
	(p_api_version_number          => 1.0,
	 p_init_msg_lst                => fnd_api.g_false,
	 x_return_status               => l_return_status,
	 x_msg_count                   => l_msg_count,
	 x_msg_data                    => l_msg_data,
	 p_rsv_rec                     => l_rsv_rec,
	 p_primary_relieved_quantity   => l_qty_to_relieve,
         p_secondary_relieved_quantity => NULL,          -- INVCONV
	 p_relieve_all                 => l_relieve_all,
	 p_original_serial_number      => l_original_serial_numbers,
	 p_validation_flag             => fnd_api.g_true,
	 x_primary_relieved_quantity   => l_qty_relieved,
         x_secondary_relieved_quantity => l_secondary_qty_relieved, -- INVCONV
	 x_primary_remain_quantity     => l_remain_qty,
         x_secondary_remain_quantity   => l_secondary_remain_qty    -- INVCONV
	 );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
      END IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt := '14';

      IF (l_debug = 1) THEN
	 debug_print(' after calling relieve rsv. Qty relieved = ' || l_qty_relieved || ' primary remaining qty = ' || l_remain_qty);
      END IF;

      l_total_qty_to_relieve := l_total_qty_to_relieve - l_qty_relieved;
      -- INVCONV BEGIN
      IF l_tracking_quantity_ind = 'PS' THEN
	 l_total_secondary_to_relieve := l_total_secondary_to_relieve - l_secondary_qty_relieved;
      END IF;
      -- INVCONV END

      IF (l_debug = 1) THEN
      debug_print (' total qty TO relieve ' || l_total_qty_to_relieve);
      debug_print (' total secondary TO relieve ' || l_total_secondary_to_relieve); -- INVCONV
      END IF;
   END LOOP;

   if (p_dsrc_type in (inv_reservation_global.g_source_type_oe,
                       inv_reservation_global.g_source_type_internal_ord)) then
      l_stmt := '15';

      open l_oe_cur ;
      fetch l_oe_cur into
        x_userline,
        x_demand_class;
   end if;

   l_stmt := '16';

   -- BUG 2666911. From now on, the x_ship_qty will be used to pass the
   -- actual relieved quantity. Change has been made in the relieve MRP API
   -- to check for the ship quantity and call the MPR relief interface
   -- whether the reservation quantity is relieved or not.
   -- The x_ship_qty will be henceforth be used to compare the actual ship
   -- quantity with the relieved quantity to see if the quantity tree
   -- validation has to be done or not.

   x_ship_qty := p_qty_at_puom - l_total_qty_to_relieve;

    --INVCONV BEGIN
   IF l_tracking_quantity_ind = 'PS' THEN
     x_secondary_ship_qty := p_qty_at_suom - l_total_secondary_to_relieve;
   END IF;
   --INVCONV END

   IF (l_debug = 1) THEN
      debug_print (' p_qty_at_uom ' || p_qty_at_puom || ' L-total-qty-to-relieve ' || l_total_qty_to_relieve);
      debug_print (' Ship qty after calling l_oe_cur ' || x_ship_qty);
      debug_print (' Secondary Ship qty after calling l_oe_cur ' || x_secondary_ship_qty); -- INVCONV
   END IF;

   l_stmt := '17';

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO trx_relieve_sa;
        x_return_status := fnd_api.g_ret_sts_error;

        l_stmt := 'Stmt' || l_stmt;
        fnd_message.set_name('INV', 'INV-Request failed');
        fnd_message.set_token('ENTITY',l_api_name);
        fnd_message.set_token('ERRORCODE',l_stmt);
        fnd_msg_pub.add;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO trx_relieve_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        l_stmt := 'Stmt' || l_stmt;
        fnd_message.set_name('INV', 'INV-Request failed');
        fnd_message.set_token('ENTITY',l_api_name);
        fnd_message.set_token('ERRORCODE',l_stmt);
        fnd_msg_pub.add;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
   WHEN OTHERS THEN
        ROLLBACK TO trx_relieve_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        l_stmt := 'Stmt' || l_stmt;
        fnd_message.set_name('INV', 'INV-Request failed');
        fnd_message.set_token('ENTITY',l_api_name);
        fnd_message.set_token('ERRORCODE',l_stmt);
        fnd_msg_pub.add;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END rsv_relief;

FUNCTION rsv_relieve(p_transaction_header_id NUMBER) RETURN NUMBER IS

     CURSOR trc1 IS
     SELECT A.ORGANIZATION_ID,
            A.INVENTORY_ITEM_ID,
            NVL(A.TRANSACTION_SOURCE_ID, 0) TRANSACTION_SOURCE_ID,
            A.TRANSACTION_SOURCE_TYPE_ID,
            A.TRX_SOURCE_DELIVERY_ID,
            A.TRX_SOURCE_LINE_ID,
            A.REVISION,
            DECODE(C.LOT_CONTROL_CODE, 2, B.LOT_NUMBER, A.LOT_NUMBER) LOT_NUMBER,
            A.SUBINVENTORY_CODE,
            A.LOCATOR_ID,
            DECODE (C.LOT_CONTROL_CODE, 2,
                         ABS(NVL(B.PRIMARY_QUANTITY,0)),
                         A.PRIMARY_QUANTITY *(-1)) PRIMARY_QUANTITY,
            A.TRANSACTION_SOURCE_NAME,
            FND_DATE.DATE_TO_CANONICAL(A.TRANSACTION_DATE) TRANSACTION_DATE
     FROM   MTL_SYSTEM_ITEMS C,
            MTL_TRANSACTION_LOTS_TEMP B,
            MTL_MATERIAL_TRANSACTIONS_TEMP A
     WHERE  A.TRANSACTION_HEADER_ID = p_transaction_header_id
     AND    A.ORGANIZATION_ID = C.ORGANIZATION_ID
     AND    A.INVENTORY_ITEM_ID = C.INVENTORY_ITEM_ID
     AND    B.TRANSACTION_TEMP_ID (+) = A.TRANSACTION_TEMP_ID
     AND    A.PRIMARY_QUANTITY < 0
     ORDER BY A.TRANSACTION_SOURCE_TYPE_ID,
                 A.TRANSACTION_SOURCE_ID,
                 A.TRANSACTION_SOURCE_NAME,
                 A.TRX_SOURCE_LINE_ID,
                 A.TRX_SOURCE_DELIVERY_ID,
                 A.INVENTORY_ITEM_ID,
                 A.ORGANIZATION_ID;

     l_api_return_status    VARCHAR2(1);
     o_msg_count            NUMBER;
     o_msg_data             VARCHAR2(2000);
     o_ship_qty             NUMBER;
     o_userline             VARCHAR2(40);
     o_demand_class         VARCHAR2(30);
     o_mps_flag             NUMBER;
BEGIN

   SAVEPOINT TRXRELIEF;

   FOR rec1 in trc1 LOOP
       inv_trx_relief_c_pvt.rsv_relief
                (x_return_status       => L_api_return_status,
                 x_msg_count           => o_msg_count,
                 x_msg_data            => o_msg_data,
                 x_ship_qty            => o_ship_qty,
                 x_userline            => o_userline,
                 x_demand_class        => o_demand_class,
                 x_mps_flag            => o_mps_flag,
                 p_organization_id     => rec1.organization_id,
                 p_inventory_item_id   => rec1.inventory_item_id,
                 p_subinv              => rec1.subinventory_code,
                 p_locator             => rec1.locator_id,
                 p_lotnumber           => rec1.lot_number,
                 p_revision            => rec1.revision,
                 p_dsrc_type           => rec1.transaction_source_type_id,
                 p_header_id           => rec1.transaction_source_id,
                 p_dsrc_name           => rec1.transaction_source_name,
                 p_dsrc_line           => rec1.trx_source_line_id,
                 p_dsrc_delivery       => rec1.trx_source_delivery_id,
                 p_qty_at_puom         => abs(rec1.primary_quantity)
                 );

       IF l_api_return_status <> 'S' THEN
          ROLLBACK TO TRXRELIEF;
          RETURN -1;
       END IF;

       IF ((o_ship_qty <> 0) AND
           (rec1.transaction_source_type_id = 2 OR rec1.transaction_source_type_id = 8) AND
           (o_mps_flag <> 0))
       THEN

          IF(NOT inv_txn_manager_pub.mrp_ship_order(
                         rec1.trx_source_line_id,
                         rec1.inventory_item_id,
                         o_ship_qty,
                         fnd_global.user_id,
                         rec1.organization_id,
                         o_userline,
                         rec1.transaction_date,
                         o_demand_class) ) THEN
                ROLLBACK TO TRXRELIEF;
                RETURN -1;
           END IF;
       END IF;
   END LOOP;
   RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK TO TRXRELIEF;
       RETURN -1;
END rsv_relieve;

END inv_trx_relief_c_pvt;

/
