--------------------------------------------------------
--  DDL for Package Body WMS_OPP_CYC_COUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_OPP_CYC_COUNT" AS
/* $Header: WMSOPCCB.pls 120.1.12010000.13 2010/05/03 14:03:14 abasheer noship $ */

  g_pkg_name      CONSTANT VARCHAR2(30) := 'WMS_OPP_CYC_COUNT';
  g_pkg_version   CONSTANT VARCHAR2(100) := '$Header: WMSOPCCB.pls 120.1.12010000.13 2010/05/03 14:03:14 abasheer noship $';

  -- Various debug levels
  g_error         CONSTANT NUMBER := 1;
  g_info          CONSTANT NUMBER := 5;
  g_message       CONSTANT NUMBER := 9;

  g_org_level     CONSTANT NUMBER := 1;
  g_sub_level     CONSTANT NUMBER := 2;

  g_cycle_count_header_id  NUMBER;


  PROCEDURE mdebug
       (msg    IN VARCHAR2,
        LEVEL  NUMBER := g_message)
  IS
  BEGIN
--    DBMS_OUTPUT.put_line(msg);
    inv_trx_util_pub.Trace(msg,g_pkg_name,LEVEL);
  END mdebug;

  /*

  This function will return the total primary qty of an item
  for the SKU passed after discarding the loaded qty.

  */
  FUNCTION Get_total_item_qty
       (p_organization_id    IN NUMBER,
        p_subinventory_code  IN VARCHAR2,
        p_loc_id             IN NUMBER,
        p_inventory_item_id  IN NUMBER)
  RETURN NUMBER
  IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Get_total_item_qty';
    l_api_version           CONSTANT NUMBER := 1.0;
    l_debug                          NUMBER := Nvl(fnd_profile.Value('INV_DEBUG_TRACE'),0);

    l_tot_qty                        NUMBER;
    l_loaded_sys_qty                 NUMBER;
    l_serial_number_control_code     NUMBER;


  BEGIN

    IF ( l_debug = 1 ) THEN
              Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
              Mdebug ( l_api_name||' : p_organization_id = ' || p_organization_id , g_message);
              Mdebug ( l_api_name||' : p_subinventory_code = ' || p_subinventory_code , g_message);
              Mdebug ( l_api_name||' : p_loc_id = ' || p_loc_id , g_message);
              Mdebug ( l_api_name||' : p_inventory_item_id = ' || p_inventory_item_id , g_message);
    END IF;


    l_serial_number_control_code := inv_cache.item_rec.serial_number_control_code;

    IF ( l_serial_number_control_code IN ( 1, 6 ) )  THEN
      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : Non serial controlled item' , g_message);
      END IF;

      BEGIN

        SELECT NVL ( SUM ( primary_transaction_quantity ), 0 )
        INTO   l_tot_qty
        FROM   MTL_ONHAND_QUANTITIES_DETAIL
        WHERE  inventory_item_id = p_inventory_item_id
        AND    organization_id = p_organization_id
        AND    subinventory_code = p_subinventory_code
        AND    locator_id = p_loc_id;

      EXCEPTION
        WHEN no_data_found THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : No data found exception.. So l_tot_qty = 0 ' , g_message);
        END IF;
        l_tot_qty := 0;
      END;

      IF ( l_debug = 1 ) THEN
        Mdebug ( l_api_name||' : MOQD qty is ' || l_tot_qty , g_message);
      END IF;

      BEGIN

        SELECT NVL ( SUM ( quantity ), 0 )
        INTO   l_loaded_sys_qty
        FROM   WMS_LOADED_QUANTITIES_V
        WHERE  inventory_item_id = p_inventory_item_id
        AND    organization_id = p_organization_id
        AND    subinventory_code = p_subinventory_code
        AND    locator_id = p_loc_id
        AND    qty_type = 'LOADED';

      EXCEPTION
        WHEN no_data_found THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : No data found exception.. So l_loaded_sys_qty = 0 ' , g_message);
        END IF;
        l_loaded_sys_qty := 0;
      END;


      IF ( l_debug = 1 ) THEN
        Mdebug ( l_api_name||' : Loaded qty is ' || l_loaded_sys_qty , g_message);
      END IF;

    ELSIF ( l_serial_number_control_code IN ( 2, 5 )) THEN
      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : Serial controlled item' , g_message);
      END IF;

      BEGIN

        SELECT NVL ( SUM ( DECODE ( current_status, 3, 1, 0 ) ), 0 )
        INTO   l_tot_qty
        FROM   mtl_serial_numbers
        WHERE  inventory_item_id = p_inventory_item_id
        AND    current_organization_id = p_organization_id
        AND    current_subinventory_code = p_subinventory_code
        AND    current_locator_id = p_loc_id;

      EXCEPTION
        WHEN no_data_found THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : No data found exception.. So l_tot_qty = 0 ' , g_message);
        END IF;
        l_tot_qty := 0;
      END;

      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : MOQD qty is ' || l_tot_qty , g_message);
      END IF;

      BEGIN

        SELECT Count(DISTINCT msn.serial_number)
        INTO   l_loaded_sys_qty
        FROM   mtl_serial_numbers_temp msnt, mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn, wms_dispatched_tasks wdt
        WHERE  mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
        AND   ((msnt.transaction_temp_id = mmtt.transaction_temp_id and
                mtlt.lot_number is null) or
              (msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
                and mtlt.lot_number is not null))
        AND    mmtt.inventory_item_id = p_inventory_item_id
        AND    mmtt.organization_id = p_organization_id
        AND    mmtt.subinventory_code = p_subinventory_code
        AND    mmtt.locator_id = p_loc_id
        AND    msn.serial_number BETWEEN msnt.FM_SERIAL_NUMBER AND msnt.TO_SERIAL_NUMBER
        AND    msn.inventory_item_id = mmtt.inventory_item_id
        AND    msn.CURRENT_ORGANIZATION_ID=mmtt.organization_id
        AND    wdt.transaction_temp_id = mmtt.transaction_temp_id
        AND    wdt.task_type <> 2
        AND    wdt.status = 4;

      EXCEPTION
        WHEN no_data_found THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : No data found exception.. So l_loaded_sys_qty = 0 ' , g_message);
        END IF;
        l_loaded_sys_qty := 0;
      END;

      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : Loaded qty is ' || l_loaded_sys_qty , g_message);
      END IF;

    END IF;

    IF l_loaded_sys_qty > 0 THEN
      l_tot_qty := l_tot_qty - l_loaded_sys_qty;
    END IF;


    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Total sys qty is ' || l_tot_qty , g_message);
    END IF;

    RETURN l_tot_qty;

  END get_total_item_qty;


  /*

  This function will return the no of days since there was a cycle counting
  performed for this item for the passed SKU.

  */

  FUNCTION Get_latest_cc_days
       (p_organization_id    IN NUMBER,
        p_subinventory_code  IN VARCHAR2,
        p_loc_id             IN NUMBER,
        p_inventory_item_id  IN NUMBER)
  RETURN NUMBER
  IS
    l_api_name     CONSTANT VARCHAR2(30) := 'Get_latest_cc_days';
    l_api_version  CONSTANT NUMBER := 1.0;
    l_debug        NUMBER := Nvl(fnd_profile.Value('INV_DEBUG_TRACE'),0);

    l_no_of_days   NUMBER;
    l_opp_cyc_count_days NUMBER:=0;

  BEGIN

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
      Mdebug ( l_api_name||' : p_organization_id = ' || p_organization_id , g_message);
      Mdebug ( l_api_name||' : p_subinventory_code = ' || p_subinventory_code , g_message);
      Mdebug ( l_api_name||' : p_loc_id = ' || p_loc_id , g_message);
      Mdebug ( l_api_name||' : p_inventory_item_id = ' || p_inventory_item_id , g_message);
    END IF;

    IF (inv_cache.set_fromsub_rec(p_organization_id,p_subinventory_code)) THEN
        IF (inv_cache.fromsub_rec.enable_opp_cyc_count = 'Y') THEN
           l_opp_cyc_count_days := inv_cache.fromsub_rec.opp_cyc_count_days;
         END IF;
    ELSE
        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : '||p_subinventory_code||' is an invalid subinv',g_error);
        END IF;
        fnd_message.Set_name('WMS','WMS_CONT_INVALID_SUB');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END IF;

    SELECT NVL((Trunc(SYSDATE) - Trunc(Max(count_date_current))),l_opp_cyc_count_days)
    INTO   l_no_of_days
    FROM   mtl_cycle_count_entries
    WHERE  subinventory = p_subinventory_code
    AND    inventory_item_id = p_inventory_item_id
    AND    organization_id = p_organization_id
    AND    locator_id = p_loc_id
    AND    ENTRY_STATUS_CODE NOT IN (1,3);

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : l_no_of_days is ' || l_no_of_days , g_message);
    END IF;

    RETURN l_no_of_days;

  EXCEPTION
    WHEN no_data_found THEN
      IF ( l_debug = 1 ) THEN
        Mdebug ( l_api_name||' : No data found exception.. So returning l_opp_cyc_count_days = '||l_opp_cyc_count_days , g_message);
      END IF;
      RETURN l_opp_cyc_count_days;
  END get_latest_cc_days;

  /*

  This function will return whether opportunistic cycle counting is required for
  this item in the passed SKU.

  This will return the default cycle count header id.

  */
  FUNCTION Is_cyc_count_enabled
       (p_organization_id    IN NUMBER,
        p_subinventory_code  IN VARCHAR2,
        p_loc_id             IN NUMBER,
        p_inventory_item_id  IN NUMBER)
  RETURN NUMBER
  IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Is_cyc_count_enabled';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_debug                NUMBER := Nvl(fnd_profile.Value('INV_DEBUG_TRACE'),0);
    l_progress             VARCHAR2(500) := 'Entered API';

    l_tot_qty              NUMBER;
    l_sub_tol_qty          NUMBER;
    l_no_of_days           NUMBER;
    l_cyc_count_header_id  NUMBER:=-1;
		l_item_exists					 VARCHAR2(1) := 'N'; -- Added for bug 9676695

  BEGIN

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
      Mdebug ( l_api_name||' : p_organization_id = ' || p_organization_id , g_message);
      Mdebug ( l_api_name||' : p_subinventory_code = ' || p_subinventory_code , g_message);
      Mdebug ( l_api_name||' : p_loc_id = ' || p_loc_id , g_message);
      Mdebug ( l_api_name||' : p_inventory_item_id = ' || p_inventory_item_id , g_message);
    END IF;

    l_progress := 'Validate Item';

    IF (NOT inv_cache.Set_item_rec(p_organization_id => p_organization_id, p_item_id => p_inventory_item_id)) THEN

      IF (l_debug = 1) THEN
        mdebug(l_api_name||' : '||p_inventory_item_id||' is an invalid item',g_error);
      END IF;

      fnd_message.Set_name('WMS','WMS_CONT_INVALID_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

    END IF;

    l_progress := 'After Validating Item';

    -- Added for bug 9676695
		IF (inv_cache.item_rec.cycle_count_enabled_flag<>'Y') THEN
				RETURN l_cyc_count_header_id;
		END IF;


    l_progress := 'Validate Subinventory';

    IF (NOT inv_cache.Set_fromsub_rec(p_subinventory_code => p_subinventory_code,
                                        p_organization_id => p_organization_id)) THEN

        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : '||p_subinventory_code||' is an invalid subinv',g_error);
        END IF;

        fnd_message.Set_name('WMS','WMS_CONT_INVALID_SUB');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;

    END IF;

    l_progress := 'After validating Subinventory';

    IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : Opp cyc count @ Subinv level ',g_message);
    END IF;

    IF ( l_debug = 1 ) THEN
        Mdebug ( l_api_name||' : inv_cache.fromsub_rec.enable_opp_cyc_count = ' || inv_cache.fromsub_rec.enable_opp_cyc_count , g_message);
        Mdebug ( l_api_name||' : inv_cache.fromsub_rec.opp_cyc_count_header_id = ' || inv_cache.fromsub_rec.opp_cyc_count_header_id , g_message);
        Mdebug ( l_api_name||' : inv_cache.fromsub_rec.pick_uom_code = ' || inv_cache.fromsub_rec.pick_uom_code , g_message);
        Mdebug ( l_api_name||' : inv_cache.fromsub_rec.opp_cyc_count_quantity = ' || inv_cache.fromsub_rec.opp_cyc_count_quantity , g_message);
        Mdebug ( l_api_name||' : inv_cache.fromsub_rec.opp_cyc_count_days = ' || inv_cache.fromsub_rec.opp_cyc_count_days , g_message);
        Mdebug ( l_api_name||' : inv_cache.item_rec.primary_uom_code = ' || inv_cache.item_rec.primary_uom_code , g_message);
    END IF;



    IF (inv_cache.fromsub_rec.enable_opp_cyc_count = 'Y'
          AND Nvl(inv_cache.fromsub_rec.opp_cyc_count_header_id,-1) > 0) THEN

				-- Added for bug 9676695

				BEGIN

					SELECT 'Y'
					INTO l_item_exists
					FROM mtl_cycle_count_items
					WHERE cycle_count_header_id = inv_cache.fromsub_rec.opp_cyc_count_header_id
					AND inventory_item_id = p_inventory_item_id;

				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_item_exists := 'N';

				END;

				IF (l_item_exists<>'Y') THEN
						RETURN l_cyc_count_header_id;
				END IF;

        l_progress := 'Calling Get_total_item_qty';

        l_tot_qty := Get_total_item_qty(p_organization_id,p_subinventory_code,p_loc_id,
                                        p_inventory_item_id);

        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : l_tot_qty = '||l_tot_qty,g_message);
        END IF;

        l_progress := 'Calling Get_latest_cc_days';

        l_no_of_days := Get_latest_cc_days(p_organization_id,p_subinventory_code,p_loc_id,
                                           p_inventory_item_id);

        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : l_no_of_days = '||l_no_of_days,g_message);
        END IF;

        l_progress := 'Calling inv_convert.inv_um_convert';

        IF (inv_cache.fromsub_rec.pick_uom_code IS NOT NULL) THEN

	        l_sub_tol_qty :=
                inv_convert.inv_um_convert ( p_inventory_item_id,
                                          5,
                                          inv_cache.fromsub_rec.opp_cyc_count_quantity,
                                          inv_cache.fromsub_rec.pick_uom_code,
                                          inv_cache.item_rec.primary_uom_code,
                                          NULL,
                                          NULL
                                        );
        ELSE
	        l_sub_tol_qty := inv_cache.fromsub_rec.opp_cyc_count_quantity;
        END IF;

        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : l_sub_tol_qty = '||l_sub_tol_qty,g_message);
        END IF;

        IF (l_tot_qty <= l_sub_tol_qty
            AND l_no_of_days >= inv_cache.fromsub_rec.opp_cyc_count_days) THEN

          l_cyc_count_header_id := inv_cache.fromsub_rec.opp_cyc_count_header_id;

        END IF;

        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : l_cyc_count_header_id = '||l_cyc_count_header_id,g_message);
        END IF;


   END IF;

   RETURN l_cyc_count_header_id;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : l_progress is ' || l_progress);
          Mdebug(l_api_name||' : RAISE fnd_api.g_exc_error: ' || SQLERRM, g_error);
        END IF;
    WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : l_progress is ' || l_progress);
          Mdebug(l_api_name||' : RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM, g_error);
        END IF;

  END is_cyc_count_enabled;

  /*

  This procedure will return the existing uncounted cycle count tasks for this item for this SKU.

  */
  PROCEDURE delete_existing_cyc_count
  (p_organization_id          IN    NUMBER            ,
   p_subinventory             IN    VARCHAR2          ,
   p_locator_id               IN    NUMBER            ,
   p_inventory_item_id        IN    NUMBER
   )
  IS
    l_api_name             CONSTANT VARCHAR2(30) := 'delete_existing_cyc_count';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
  BEGIN

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
      Mdebug ( l_api_name||' : p_organization_id = ' || p_organization_id , g_message);
      Mdebug ( l_api_name||' : p_subinventory = ' || p_subinventory , g_message);
      Mdebug ( l_api_name||' : p_locator_id = ' || p_locator_id , g_message);
      Mdebug ( l_api_name||' : p_inventory_item_id = ' || p_inventory_item_id , g_message);
    END IF;
    -- Delete WDT

    DELETE FROM wms_dispatched_tasks
    WHERE transaction_temp_id IN (SELECT CYCLE_COUNT_ENTRY_ID
                                    FROM mtl_cycle_count_entries
                                    WHERE ENTRY_STATUS_CODE IN (1,3)
                                    AND ORGANIZATION_ID=p_organization_id
                                    AND SUBINVENTORY=p_subinventory
                                    AND LOCATOR_ID=p_locator_id
                                    AND INVENTORY_ITEM_ID=p_inventory_item_id)
    AND ORGANIZATION_ID=p_organization_id;

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : *** Deleted '||sql%rowcount||' WDT records' , g_message);
    END IF;

    -- delete MCCE

    DELETE FROM mtl_cycle_count_entries
    WHERE ENTRY_STATUS_CODE IN (1, 3)
    AND   ORGANIZATION_ID=p_organization_id
    AND   SUBINVENTORY=p_subinventory
    AND   LOCATOR_ID=p_locator_id
    AND   INVENTORY_ITEM_ID=p_inventory_item_id;

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : *** Deleted '||sql%rowcount||' MCCE records' , g_message);
    END IF;

  END delete_existing_cyc_count;

  /*

  This function will return the total primary qty of an item
  for the parameters passed after discarding the loaded qty.

  */
  PROCEDURE get_system_qty
     (p_organization_id     IN NUMBER,
      p_subinventory_code   IN VARCHAR2,
      p_loc_id              IN NUMBER,
      p_parent_lpn_id       IN NUMBER DEFAULT NULL,
      p_inventory_item_id   IN NUMBER,
      p_revision            IN VARCHAR2 DEFAULT NULL,
      p_lot_number          IN VARCHAR2 DEFAULT NULL,
      p_from_Serial_number  IN VARCHAR2 DEFAULT NULL,
      p_to_Serial_number    IN VARCHAR2 DEFAULT NULL,
      p_uom_code            IN VARCHAR2,
      x_system_quantity     OUT NOCOPY NUMBER)
  IS
    l_api_name              CONSTANT VARCHAR2(30) := 'get_system_qty';
    l_api_version           CONSTANT NUMBER := 1.0;
    l_debug                          NUMBER := Nvl(fnd_profile.Value('INV_DEBUG_TRACE'),0);

    l_tot_qty                        NUMBER;
		l_cnt_qty												 NUMBER:=0;
    l_loaded_sys_qty                 NUMBER;
    l_serial_number_control_code     NUMBER;


  BEGIN

    IF ( l_debug = 1 ) THEN
              Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
              Mdebug ( l_api_name||' : p_organization_id = ' || p_organization_id , g_message);
              Mdebug ( l_api_name||' : p_subinventory_code = ' || p_subinventory_code , g_message);
              Mdebug ( l_api_name||' : p_loc_id = ' || p_loc_id , g_message);
              Mdebug ( l_api_name||' : p_inventory_item_id = ' || p_inventory_item_id , g_message);
              Mdebug ( l_api_name||' : p_parent_lpn_id = ' || p_parent_lpn_id , g_message);
              Mdebug ( l_api_name||' : p_revision = ' || p_revision , g_message);
              Mdebug ( l_api_name||' : p_lot_number = ' || p_lot_number , g_message);
              Mdebug ( l_api_name||' : p_from_Serial_number = ' || p_from_Serial_number , g_message);
              Mdebug ( l_api_name||' : p_to_Serial_number = ' || p_to_Serial_number , g_message);
              Mdebug ( l_api_name||' : p_uom_code = ' || p_uom_code , g_message);
    END IF;


    l_serial_number_control_code := inv_cache.item_rec.serial_number_control_code;

    IF ( l_serial_number_control_code IN ( 1, 6 ) )  THEN
      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : Non serial controlled item' , g_message);
      END IF;

      BEGIN

        SELECT NVL ( SUM ( primary_transaction_quantity ), 0 )
        INTO   l_tot_qty
        FROM   MTL_ONHAND_QUANTITIES_DETAIL
        WHERE  inventory_item_id = p_inventory_item_id
        AND    organization_id = p_organization_id
        AND    subinventory_code = p_subinventory_code
        AND    locator_id = p_loc_id
        AND    (    (p_parent_lpn_id IS NOT NULL
                      AND NVL ( containerized_flag, 2 ) = 1)
                      AND lpn_id = p_parent_lpn_id
                  OR (p_parent_lpn_id IS NULL
                      AND NVL ( containerized_flag, 2 ) = 2)
                )
        AND    (    lot_number = p_lot_number
                  OR p_lot_number IS NULL
                )
        AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' );

      EXCEPTION
        WHEN no_data_found THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : No data found exception.. So l_tot_qty = 0 ' , g_message);
        END IF;
        l_tot_qty := 0;
      END;

      IF ( l_debug = 1 ) THEN
        Mdebug ( l_api_name||' : MOQD qty is ' || l_tot_qty , g_message);
      END IF;

      BEGIN

        SELECT NVL ( SUM ( quantity ), 0 )
        INTO   l_loaded_sys_qty
        FROM   WMS_LOADED_QUANTITIES_V
        WHERE  inventory_item_id = p_inventory_item_id
        AND    organization_id = p_organization_id
        AND    subinventory_code = p_subinventory_code
        AND    locator_id = p_loc_id
        AND    qty_type = 'LOADED'
        AND    (    (p_parent_lpn_id IS NOT NULL
                      AND NVL ( containerized_flag, 2 ) = 1)
                      AND NVL ( lpn_id, NVL ( content_lpn_id, -1 ) ) = p_parent_lpn_id
                  OR (p_parent_lpn_id IS NULL
                      AND NVL ( containerized_flag, 2 ) = 2)
                )
        AND    (    lot_number = p_lot_number
                  OR p_lot_number IS NULL
                )
        AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' );

      EXCEPTION
        WHEN no_data_found THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : No data found exception.. So l_loaded_sys_qty = 0 ' , g_message);
        END IF;
        l_loaded_sys_qty := 0;
      END;


      IF ( l_debug = 1 ) THEN
        Mdebug ( l_api_name||' : Loaded qty is ' || l_loaded_sys_qty , g_message);
      END IF;

    ELSIF ( l_serial_number_control_code IN ( 2, 5 )) THEN
      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : Serial controlled item' , g_message);
      END IF;

      BEGIN

        SELECT NVL ( SUM ( DECODE ( current_status, 3, 1, 0 ) ), 0 )
        INTO   l_tot_qty
        FROM   mtl_serial_numbers
        WHERE  inventory_item_id = p_inventory_item_id
        AND    current_organization_id = p_organization_id
        AND    current_subinventory_code = p_subinventory_code
        AND    current_locator_id = p_loc_id
        AND    (    (p_parent_lpn_id IS NOT NULL
                      AND lpn_id = p_parent_lpn_id)
                  OR (p_parent_lpn_id IS NULL
											AND lpn_id IS NULL)
                )
        AND    (    lot_number = p_lot_number
                  OR p_lot_number IS NULL
                )
        AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
        AND    (p_from_Serial_number IS NULL OR p_to_Serial_number IS NULL OR serial_number BETWEEN p_from_Serial_number AND p_to_Serial_number);

      EXCEPTION
        WHEN no_data_found THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : No data found exception.. So l_tot_qty = 0 ' , g_message);
        END IF;
        l_tot_qty := 0;
      END;

      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : MOQD qty is ' || l_tot_qty , g_message);
      END IF;

      BEGIN

        SELECT Count(DISTINCT msn.serial_number)
        INTO   l_loaded_sys_qty
        FROM   mtl_serial_numbers_temp msnt, mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn, wms_dispatched_tasks wdt
        WHERE  mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
        AND   ((msnt.transaction_temp_id = mmtt.transaction_temp_id and
                mtlt.lot_number is null) or
              (msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
                and mtlt.lot_number is not null))
        AND    mmtt.inventory_item_id = p_inventory_item_id
        AND    mmtt.organization_id = p_organization_id
        AND    mmtt.subinventory_code = p_subinventory_code
        AND    mmtt.locator_id = p_loc_id
        AND    (    (p_parent_lpn_id IS NOT NULL
                      AND NVL ( mmtt.lpn_id, NVL ( content_lpn_id, -1 ) ) = p_parent_lpn_id)
                  OR (p_parent_lpn_id IS NULL
											AND NVL ( mmtt.lpn_id, NVL ( content_lpn_id, -1 ) ) = -1)
                )
        AND    (    mtlt.lot_number = p_lot_number
                  OR p_lot_number IS NULL
                )
        AND    NVL ( mmtt.revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
        AND    (p_from_Serial_number IS NULL OR p_to_Serial_number IS NULL OR msn.serial_number BETWEEN p_from_Serial_number AND p_to_Serial_number)
        AND    msn.serial_number BETWEEN msnt.FM_SERIAL_NUMBER AND msnt.TO_SERIAL_NUMBER
        AND    msn.revision = mmtt.revision
        AND    msn.inventory_item_id = mmtt.inventory_item_id
        AND    msn.CURRENT_ORGANIZATION_ID=mmtt.organization_id
        AND    wdt.transaction_temp_id = mmtt.transaction_temp_id
        AND    wdt.task_type <> 2
        AND    wdt.status = 4;

      EXCEPTION
        WHEN no_data_found THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : No data found exception.. So l_loaded_sys_qty = 0 ' , g_message);
        END IF;
        l_loaded_sys_qty := 0;
      END;

      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : Loaded qty is ' || l_loaded_sys_qty , g_message);
      END IF;

      BEGIN

        SELECT Nvl(Sum(Decode(count_uom_current,
													inv_cache.item_rec.primary_uom_code,
													adj_cnt_qty,
													(inv_convert.inv_um_convert(p_inventory_item_id,
																											5,
																											adj_cnt_qty,
																											count_uom_current,
																											inv_cache.item_rec.primary_uom_code,
																											NULL,
																											NULL
																											)
													)
												 )
									),0)
        INTO   l_cnt_qty
        FROM   (SELECT count_uom_current, (system_quantity_current - count_quantity_current) adj_cnt_qty
								FROM	 mtl_cycle_count_entries
								WHERE  inventory_item_id = p_inventory_item_id
								AND    organization_id = p_organization_id
								AND    subinventory = p_subinventory_code
								AND    locator_id = p_loc_id
								AND    cycle_count_header_id = g_cycle_count_header_id
								AND		 entry_status_code = 2
								AND    (    (p_parent_lpn_id IS NOT NULL
															AND parent_lpn_id = p_parent_lpn_id)
													OR (p_parent_lpn_id IS NULL
															AND parent_lpn_id IS NULL)
											 )
								AND    (    lot_number = p_lot_number
													OR p_lot_number IS NULL
											 )
								AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
								AND    (p_from_Serial_number IS NULL OR p_to_Serial_number IS NULL OR serial_number BETWEEN p_from_Serial_number AND p_to_Serial_number)
								AND		 system_quantity_current <> count_quantity_current
								UNION ALL
								SELECT mcce.count_uom_current, (mcce.count_quantity_current - mcce.system_quantity_current) adj_cnt_qty
								FROM	 mtl_cycle_count_entries mcce, mtl_serial_numbers msn
								WHERE  mcce.inventory_item_id = p_inventory_item_id
								AND    mcce.organization_id = p_organization_id
								AND    mcce.cycle_count_header_id = g_cycle_count_header_id
								AND		 mcce.entry_status_code = 2
								AND    (p_from_Serial_number IS NULL OR p_to_Serial_number IS NULL OR mcce.serial_number BETWEEN p_from_Serial_number AND p_to_Serial_number)
								AND		 mcce.serial_number = msn.serial_number
								AND    msn.inventory_item_id = mcce.inventory_item_id
								AND    msn.CURRENT_ORGANIZATION_ID=mcce.organization_id
								AND    msn.current_subinventory_code = p_subinventory_code
								AND    msn.current_locator_id = p_loc_id
								AND    (  (   msn.lot_number = p_lot_number
													AND msn.lot_number = mcce.lot_number
													)
													OR p_lot_number IS NULL
												)
								AND    NVL ( msn.revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
								AND    NVL ( mcce.revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
								AND    (	mcce.subinventory <> msn.current_subinventory_code
											 OR mcce.locator_id <> msn.current_locator_id
											 )
								AND		 mcce.system_quantity_current <> mcce.count_quantity_current);

      EXCEPTION
        WHEN no_data_found THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : No data found exception.. So l_cnt_qty = 0 ' , g_message);
        END IF;
        l_cnt_qty := 0;
      END;

      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : Pending cycle count qty is ' || l_cnt_qty , g_message);
      END IF;


    END IF;

    IF l_loaded_sys_qty > 0 THEN
      l_tot_qty := l_tot_qty - l_loaded_sys_qty-l_cnt_qty;
		ELSE
      l_tot_qty := l_tot_qty - l_cnt_qty;
    END IF;


    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Total sys qty is ' || l_tot_qty , g_message);
    END IF;

    x_system_quantity := l_tot_qty;

  END get_system_qty;

/*

  This procedure will get the detailed allocated pending qty at the locator level for the item.

   x_det_alloc_cur - A cursor which will give the pending allocations for the parameters passed.
   x_allocated_qty - Total allocated pending qty for the parameters passed.
  */

  PROCEDURE get_locator_quantity
	(p_organization_id		IN					NUMBER,
 	 p_subinventory				IN					VARCHAR2,
	 p_locator_id					IN					NUMBER,
	 p_inventory_item_id	IN					NUMBER,
	 p_revision						IN					VARCHAR2,
	 p_lot_number					IN					VARCHAR2,
	 p_from_serial_number IN					VARCHAR2 DEFAULT NULL,
	 p_to_serial_number		IN					VARCHAR2 DEFAULT NULL,
	 x_system_quantity		OUT NOCOPY	NUMBER
  )
  IS
    l_api_name             CONSTANT VARCHAR2(30) := 'get_locator_quantity';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_serial_number_control_code NUMBER;
    l_progress VARCHAR2 ( 10 );
    l_loaded_sys_qty NUMBER;
		l_cnt_qty NUMBER:=0;
    l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

   BEGIN

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
      Mdebug ( l_api_name||' : p_organization_id = ' || p_organization_id , g_message);
      Mdebug ( l_api_name||' : p_subinventory = ' || p_subinventory , g_message);
      Mdebug ( l_api_name||' : p_locator_id = ' || p_locator_id , g_message);
      Mdebug ( l_api_name||' : p_inventory_item_id = ' || p_inventory_item_id , g_message);
      Mdebug ( l_api_name||' : p_revision = ' || p_revision , g_message);
      Mdebug ( l_api_name||' : p_lot_number = ' || p_lot_number , g_message);
      Mdebug ( l_api_name||' : p_from_serial_number = ' || p_from_serial_number , g_message);
      Mdebug ( l_api_name||' : p_to_serial_number = ' || p_to_serial_number , g_message);
    END IF;

    -- Initialize the output variable
    x_system_quantity := 0;
    l_progress  := '10';

    IF (NOT inv_cache.Set_item_rec(p_organization_id => p_organization_id, p_item_id => p_inventory_item_id)) THEN

      IF (l_debug = 1) THEN
        mdebug(l_api_name||' : '||p_inventory_item_id||' is an invalid item',g_error);
      END IF;

      fnd_message.Set_name('WMS','WMS_CONT_INVALID_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

    END IF;

    l_serial_number_control_code := inv_cache.item_rec.serial_number_control_code;

    l_progress  := '20';

    IF ( l_serial_number_control_code IN ( 1, 6 ) ) THEN
      IF ( l_debug = 1 ) THEN
        mdebug ( 'Non serial controlled item' );
      END IF;

      l_progress  := '30';

      SELECT NVL ( SUM ( primary_transaction_quantity ), 0 )
      INTO   x_system_quantity
      FROM   MTL_ONHAND_QUANTITIES_DETAIL
      WHERE  inventory_item_id = p_inventory_item_id
      AND    organization_id = p_organization_id
      AND    subinventory_code = p_subinventory
      AND    locator_id = p_locator_id
      AND    (    lot_number = p_lot_number
                OR p_lot_number IS NULL
              )
      AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' );

      SELECT NVL ( SUM ( quantity ), 0 )
      INTO   l_loaded_sys_qty
      FROM   WMS_LOADED_QUANTITIES_V
      WHERE  inventory_item_id = p_inventory_item_id
      AND    organization_id = p_organization_id
      AND    subinventory_code = p_subinventory
      AND    locator_id = p_locator_id
      AND    (    lot_number = p_lot_number
                OR p_lot_number IS NULL
              )
      AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
      AND    qty_type = 'LOADED';

      IF ( l_debug = 1 ) THEN
        mdebug ( 'Loaded qty is ' || l_loaded_sys_qty );
      END IF;

      IF l_loaded_sys_qty > 0 THEN
        x_system_quantity := x_system_quantity - l_loaded_sys_qty;
      END IF;

      l_progress  := '40';

		ELSIF ( l_serial_number_control_code IN ( 2, 5 ) ) THEN
      IF ( l_debug = 1 ) THEN
        mdebug ( 'Serial controlled item' );
      END IF;

      l_progress  := '50';

      SELECT NVL ( SUM ( DECODE ( current_status, 3, 1, 0 ) ), 0 )
      INTO   x_system_quantity
      FROM   mtl_serial_numbers
      WHERE  inventory_item_id = p_inventory_item_id
      AND    current_organization_id = p_organization_id
      AND    current_subinventory_code = p_subinventory
      AND    current_locator_id = p_locator_id
      AND    (    lot_number = p_lot_number
                OR p_lot_number IS NULL
              )
      AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' );

		  SELECT Count(DISTINCT msn.serial_number)
		  INTO   l_loaded_sys_qty
		  FROM   mtl_serial_numbers_temp msnt, mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn, wms_dispatched_tasks wdt
		  WHERE  mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
		  AND    ((msnt.transaction_temp_id = mmtt.transaction_temp_id AND
                mtlt.lot_number is null) OR
						  (msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
                AND mtlt.lot_number = p_lot_number)
					  )
		  AND    mmtt.inventory_item_id = p_inventory_item_id
		  AND    mmtt.organization_id = p_organization_id
		  AND    mmtt.subinventory_code = p_subinventory
		  AND    mmtt.locator_id = p_locator_id
		  AND    (p_from_serial_number IS NULL OR p_to_serial_number IS NULL OR msn.serial_number between p_from_serial_number AND p_to_serial_number)
		  AND    msn.serial_number BETWEEN msnt.FM_SERIAL_NUMBER AND msnt.TO_SERIAL_NUMBER
		  AND    msn.inventory_item_id = mmtt.inventory_item_id
		  AND    msn.CURRENT_ORGANIZATION_ID=mmtt.organization_id
		  AND    mmtt.transaction_temp_id=wdt.transaction_temp_id
		  AND    NVL(wdt.status, 1) = 4;

      BEGIN

        SELECT Nvl(Sum(Decode(count_uom_current,
													inv_cache.item_rec.primary_uom_code,
													adj_cnt_qty,
													(inv_convert.inv_um_convert(p_inventory_item_id,
																											5,
																											adj_cnt_qty,
																											count_uom_current,
																											inv_cache.item_rec.primary_uom_code,
																											NULL,
																											NULL
																											)
													)
												 )
									),0)
        INTO   l_cnt_qty
        FROM   (SELECT count_uom_current, (system_quantity_current - count_quantity_current) adj_cnt_qty
								FROM	 mtl_cycle_count_entries
								WHERE  inventory_item_id = p_inventory_item_id
								AND    organization_id = p_organization_id
								AND    subinventory = p_subinventory
								AND    locator_id = p_locator_id
								AND    cycle_count_header_id = g_cycle_count_header_id
								AND		 entry_status_code = 2
								AND    (    lot_number = p_lot_number
													OR p_lot_number IS NULL
											 )
								AND    NVL ( revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
								AND    (p_from_Serial_number IS NULL OR p_to_Serial_number IS NULL OR serial_number BETWEEN p_from_Serial_number AND p_to_Serial_number)
								AND		 system_quantity_current <> count_quantity_current
								UNION ALL
								SELECT mcce.count_uom_current, (mcce.count_quantity_current - mcce.system_quantity_current) adj_cnt_qty
								FROM	 mtl_cycle_count_entries mcce, mtl_serial_numbers msn
								WHERE  mcce.inventory_item_id = p_inventory_item_id
								AND    mcce.organization_id = p_organization_id
								AND    mcce.cycle_count_header_id = g_cycle_count_header_id
								AND		 mcce.entry_status_code = 2
								AND    (p_from_Serial_number IS NULL OR p_to_Serial_number IS NULL OR mcce.serial_number BETWEEN p_from_Serial_number AND p_to_Serial_number)
								AND		 mcce.serial_number = msn.serial_number
								AND    msn.inventory_item_id = mcce.inventory_item_id
								AND    msn.CURRENT_ORGANIZATION_ID=mcce.organization_id
								AND    msn.current_subinventory_code = p_subinventory
								AND    msn.current_locator_id = p_locator_id
								AND    (  (   msn.lot_number = p_lot_number
													AND msn.lot_number = mcce.lot_number
													)
													OR p_lot_number IS NULL
												)
								AND    NVL ( msn.revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
								AND    NVL ( mcce.revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
								AND    (	mcce.subinventory <> msn.current_subinventory_code
											 OR mcce.locator_id <> msn.current_locator_id
											 )
								AND		 mcce.system_quantity_current <> mcce.count_quantity_current);

      EXCEPTION
        WHEN no_data_found THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : No data found exception.. So l_cnt_qty = 0 ' , g_message);
        END IF;
        l_cnt_qty := 0;
      END;

      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : Pending cycle count qty is ' || l_cnt_qty , g_message);
      END IF;




      IF l_loaded_sys_qty > 0 THEN
        x_system_quantity := x_system_quantity - l_loaded_sys_qty - l_cnt_qty;
			ELSE
        x_system_quantity := x_system_quantity - l_cnt_qty;
      END IF;

      l_progress  := '60';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF ( l_debug = 1 ) THEN
        mdebug (    'Exiting get_locator_quantity - other exceptions:'
                      || l_progress
                      || ' '
                      || TO_CHAR ( SYSDATE, 'YYYY-MM-DD HH:DD:SS' )
                    );
      END IF;
  END get_locator_quantity;

  /*

  This procedure will get the total allocated pending qty for the selected item and SKU.

   x_alloc_cur - A cursor which will give the pending allocations for the selected item and SKU ordered by priority.
   x_allocated_qty - Total allocated pending qty for the selected item and SKU ordered by priority.


  */
  PROCEDURE get_allocated_qty
  (p_organization_id          IN    NUMBER            ,
   p_subinventory             IN    VARCHAR2          ,
   p_locator_id               IN    NUMBER   := NULL  ,
   p_parent_lpn_id            IN    NUMBER   := NULL  ,
   p_inventory_item_id        IN    NUMBER            ,
   p_revision                 IN    VARCHAR2 := NULL  ,
   p_lot_number               IN    VARCHAR2 := NULL  ,
   p_from_serial_number       IN    VARCHAR2 := NULL  ,
   p_to_serial_number         IN    VARCHAR2 := NULL  ,
   x_alloc_cur                  OUT NOCOPY t_genref,
   x_allocated_qty            OUT NOCOPY NUMBER
   )
  IS
    l_api_name             CONSTANT VARCHAR2(30) := 'get_allocated_qty';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_serial_number_control_code NUMBER;
    l_progress VARCHAR2 ( 10 );
    l_allocated_pri_qty NUMBER;
    l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

  BEGIN

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
      Mdebug ( l_api_name||' : p_organization_id = ' || p_organization_id , g_message);
      Mdebug ( l_api_name||' : p_subinventory = ' || p_subinventory , g_message);
      Mdebug ( l_api_name||' : p_locator_id = ' || p_locator_id , g_message);
      Mdebug ( l_api_name||' : p_parent_lpn_id = ' || p_parent_lpn_id , g_message);
      Mdebug ( l_api_name||' : p_inventory_item_id = ' || p_inventory_item_id , g_message);
      Mdebug ( l_api_name||' : p_revision = ' || p_revision , g_message);
      Mdebug ( l_api_name||' : p_lot_number = ' || p_lot_number , g_message);
      Mdebug ( l_api_name||' : p_from_serial_number = ' || p_from_serial_number , g_message);
      Mdebug ( l_api_name||' : p_to_serial_number = ' || p_to_serial_number , g_message);
    END IF;


      -- Initialize the output variable

    l_progress  := '10';

    IF (NOT inv_cache.Set_item_rec(p_organization_id => p_organization_id, p_item_id => p_inventory_item_id)) THEN

      IF (l_debug = 1) THEN
        mdebug(l_api_name||' : '||p_inventory_item_id||' is an invalid item',g_error);
      END IF;

      fnd_message.Set_name('WMS','WMS_CONT_INVALID_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

    END IF;

    IF (NOT inv_cache.Set_org_rec(p_organization_id => p_organization_id)) THEN
      IF (l_debug = 1) THEN
        mdebug(l_api_name||' : '||p_organization_id||' is an invalid organization id',g_error);
      END IF;

      fnd_message.Set_name('WMS','WMS_CONT_INVALID_ORG');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

   END IF;


    l_progress  := '20';

    l_serial_number_control_code := inv_cache.item_rec.serial_number_control_code;

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : l_serial_number_control_code = ' || l_serial_number_control_code , g_message);
    END IF;


    l_progress  := '30';

    IF (( l_serial_number_control_code IN ( 1, 6 ) ) OR ( l_serial_number_control_code IN ( 2, 5 ) AND Nvl(inv_cache.org_rec.ALLOCATE_SERIAL_FLAG, 'N')='N')) THEN

      IF ( l_debug = 1 ) THEN
        Mdebug ( l_api_name||' : Non serial controlled item / serial item with no serial allocation' , g_message);
      END IF;

      l_progress  := '40';

      BEGIN
        SELECT NVL ( SUM ( Nvl(mtlt.primary_quantity, mmtt.primary_quantity) ), 0 )
        INTO l_allocated_pri_qty
        FROM mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt, mtl_transaction_lots_temp mtlt
        WHERE mmtt.inventory_item_id = p_inventory_item_id
        AND   mmtt.organization_id = p_organization_id
        AND   (p_parent_lpn_id IS NULL OR NVL ( mmtt.allocated_lpn_id, NVL ( mmtt.lpn_id, NVL ( mmtt.content_lpn_id, -1 ) ) ) = p_parent_lpn_id)
        AND   mmtt.subinventory_code = p_subinventory
        AND   mmtt.locator_id = p_locator_id
        AND   NVL ( mmtt.revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
        AND   mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
        AND   NVL ( mtlt.lot_number, 'XX' ) = NVL ( p_lot_number, 'XX' )
	AND   mmtt.transaction_temp_id=wdt.transaction_temp_id(+)
	AND   NVL(wdt.status, 1) <> 4;


        OPEN x_alloc_cur FOR
        SELECT mmtt.TRANSACTION_TEMP_ID, Nvl(Nvl(mtlt.primary_quantity, mmtt.primary_quantity), 0) primary_quantity, Nvl(mmtt.TASK_PRIORITY,0)
        FROM mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt, mtl_transaction_lots_temp mtlt
        WHERE mmtt.inventory_item_id = p_inventory_item_id
        AND   mmtt.organization_id = p_organization_id
        AND   (p_parent_lpn_id IS NULL OR NVL ( mmtt.allocated_lpn_id, NVL ( mmtt.lpn_id, NVL ( mmtt.content_lpn_id, -1 ) ) ) = p_parent_lpn_id)
        AND   mmtt.subinventory_code = p_subinventory
        AND   mmtt.locator_id = p_locator_id
        AND   NVL ( mmtt.revision, 'XXX' ) = NVL ( p_revision, 'XXX' )
        AND   mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
        AND   NVL ( mtlt.lot_number, 'XX' ) = NVL ( p_lot_number, 'XX')
	AND   mmtt.transaction_temp_id=wdt.transaction_temp_id(+)
	AND   NVL(wdt.status, 1) NOT IN (3, 4, 9)
        ORDER BY Nvl(mmtt.TASK_PRIORITY,0);


      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_allocated_pri_qty := 0;
      END;

      l_progress  := '50';

    ELSIF ( l_serial_number_control_code IN ( 2, 5 ) AND Nvl(inv_cache.org_rec.ALLOCATE_SERIAL_FLAG, 'N')='Y') THEN

      IF ( l_debug = 1 ) THEN
        Mdebug ( l_api_name||' : Serial controlled item with serial allocation' , g_message);
      END IF;

      l_progress  := '60';

      SELECT Count(DISTINCT msn.serial_number)
      INTO   l_allocated_pri_qty
      FROM   mtl_serial_numbers_temp msnt, mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn, wms_dispatched_tasks wdt
      WHERE  mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
      AND    ((msnt.transaction_temp_id = mmtt.transaction_temp_id AND
                mtlt.lot_number IS NULL) OR
              (msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
                AND mtlt.lot_number IS NOT NULL)
             )
      AND    (p_parent_lpn_id IS NULL OR NVL ( mmtt.allocated_lpn_id, NVL ( mmtt.lpn_id, NVL ( mmtt.content_lpn_id, -1 ) ) ) = p_parent_lpn_id)
      AND    mmtt.inventory_item_id = p_inventory_item_id
      AND    mmtt.organization_id = p_organization_id
      AND    mmtt.subinventory_code = p_subinventory
      AND    mmtt.locator_id = p_locator_id
      AND    nvl(mtlt.lot_number,'@@@') = nvl(p_lot_number,'@@@')
      AND    nvl(mmtt.revision,'##') = nvl(p_revision,'##')
      AND    (p_from_serial_number IS NULL OR p_to_serial_number IS NULL OR msn.serial_number between p_from_serial_number AND p_to_serial_number)
      AND    msn.serial_number BETWEEN msnt.FM_SERIAL_NUMBER AND msnt.TO_SERIAL_NUMBER
      AND    msn.inventory_item_id = mmtt.inventory_item_id
      AND    (p_parent_lpn_id IS NULL OR NVL(msn.lpn_id, -1) = p_parent_lpn_id)
      AND    msn.CURRENT_ORGANIZATION_ID=mmtt.organization_id
	    AND    mmtt.transaction_temp_id=wdt.transaction_temp_id(+)
	    AND    NVL(wdt.status, 1) <> 4;


      OPEN x_alloc_cur FOR
      SELECT DISTINCT mmtt.TRANSACTION_TEMP_ID, Count(DISTINCT msn.serial_number) primary_quantity, Nvl(mmtt.TASK_PRIORITY,0)
      FROM   mtl_serial_numbers_temp msnt, mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn, wms_dispatched_tasks wdt
      WHERE  mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
      AND    ((msnt.transaction_temp_id = mmtt.transaction_temp_id AND
                mtlt.lot_number is null) OR
              (msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
                AND mtlt.lot_number is not null)
             )
      AND    (p_parent_lpn_id IS NULL OR NVL ( mmtt.allocated_lpn_id, NVL ( mmtt.lpn_id, NVL ( mmtt.content_lpn_id, -1 ) ) ) = p_parent_lpn_id)
      AND    mmtt.inventory_item_id = p_inventory_item_id
      AND    mmtt.organization_id = p_organization_id
      AND    mmtt.subinventory_code = p_subinventory
      AND    mmtt.locator_id = p_locator_id
      AND    nvl(mtlt.lot_number,'@@@') = nvl(p_lot_number,'@@@')
      AND    nvl(mmtt.revision,'##') = nvl(p_revision,'##')
      AND    (p_from_serial_number IS NULL OR p_to_serial_number IS NULL OR msn.serial_number between p_from_serial_number AND p_to_serial_number)
      AND    msn.serial_number BETWEEN msnt.FM_SERIAL_NUMBER AND msnt.TO_SERIAL_NUMBER
      AND    msn.inventory_item_id = mmtt.inventory_item_id
      AND    (p_parent_lpn_id IS NULL OR NVL(msn.lpn_id, -1) = p_parent_lpn_id)
      AND    msn.CURRENT_ORGANIZATION_ID=mmtt.organization_id
	    AND    mmtt.transaction_temp_id=wdt.transaction_temp_id(+)
	    AND    NVL(wdt.status, 1) NOT IN (3, 4, 9)
      GROUP BY mmtt.TRANSACTION_TEMP_ID, mmtt.TASK_PRIORITY
      ORDER BY Nvl(mmtt.TASK_PRIORITY,0);

      l_progress  := '70';

    END IF;

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Allocated primary qty is ' || l_allocated_pri_qty , g_message);
    END IF;


    l_progress  := '80';

    x_allocated_qty:= l_allocated_pri_qty;

  EXCEPTION
    WHEN OTHERS THEN
      IF ( l_debug = 1 ) THEN
        Mdebug(l_api_name||' : l_progress is ' || l_progress);
        Mdebug (    l_api_name||' : Exiting get_allocated_qty - other exceptions: '
                      || SQLERRM, g_error
                    );
      END IF;

      x_allocated_qty:= 0;

      RAISE fnd_api.g_exc_unexpected_error;

  END get_allocated_qty;

  /*

  This procedure will get the total allocated pending serial qty for the selected item and SKU.

   x_alloc_cur - A cursor which will give the pending allocations for the selected item and SKU ordered by priority.
   x_allocated_qty - Total allocated pending qty for the selected item and SKU ordered by priority.


  */

  PROCEDURE get_serial_allocated_qty
  (p_organization_id          IN    NUMBER            ,
   p_inventory_item_id        IN    NUMBER            ,
   p_from_serial_number       IN    VARCHAR2 := NULL  ,
   p_to_serial_number         IN    VARCHAR2 := NULL  ,
   x_det_alloc_cur                  OUT NOCOPY t_genref,
   x_det_allocated_qty            OUT NOCOPY NUMBER
   )
  IS
    l_api_name             CONSTANT VARCHAR2(30) := 'get_serial_allocated_qty';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_serial_number_control_code NUMBER;
    l_progress VARCHAR2 ( 10 );
    l_allocated_pri_qty NUMBER;
    l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
  BEGIN

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
      Mdebug ( l_api_name||' : p_organization_id = ' || p_organization_id , g_message);
      Mdebug ( l_api_name||' : p_inventory_item_id = ' || p_inventory_item_id , g_message);
      Mdebug ( l_api_name||' : p_from_serial_number = ' || p_from_serial_number , g_message);
      Mdebug ( l_api_name||' : p_to_serial_number = ' || p_to_serial_number , g_message);
    END IF;


      -- Initialize the output variable

    l_progress  := '10';

    SELECT Count(DISTINCT msn.serial_number)
		INTO   l_allocated_pri_qty
		FROM   mtl_serial_numbers_temp msnt, mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn, wms_dispatched_tasks wdt
		WHERE  mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
		AND    ((msnt.transaction_temp_id = mmtt.transaction_temp_id AND
              mtlt.lot_number is null) OR
						(msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
              AND mtlt.lot_number is not null)
					 )
		AND    mmtt.inventory_item_id = p_inventory_item_id
		AND    mmtt.organization_id = p_organization_id
		AND    (p_from_serial_number IS NULL OR p_to_serial_number IS NULL OR msn.serial_number between p_from_serial_number AND p_to_serial_number)
		AND    msn.serial_number BETWEEN msnt.FM_SERIAL_NUMBER AND msnt.TO_SERIAL_NUMBER
		AND    msn.inventory_item_id = mmtt.inventory_item_id
		AND    msn.CURRENT_ORGANIZATION_ID=mmtt.organization_id
		AND    mmtt.transaction_temp_id=wdt.transaction_temp_id(+)
		AND    NVL(wdt.status, 1) <> 4;


		OPEN x_det_alloc_cur FOR
		SELECT DISTINCT mmtt.TRANSACTION_TEMP_ID, Count(DISTINCT msn.serial_number) primary_quantity, Nvl(mmtt.TASK_PRIORITY,0)
		FROM   mtl_serial_numbers_temp msnt, mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn, wms_dispatched_tasks wdt
		WHERE  mmtt.transaction_temp_id = mtlt.transaction_temp_id (+)
		AND    ((msnt.transaction_temp_id = mmtt.transaction_temp_id AND
              mtlt.lot_number is null) OR
						(msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
              AND mtlt.lot_number is not null)
					 )
		AND    mmtt.inventory_item_id = p_inventory_item_id
		AND    mmtt.organization_id = p_organization_id
		AND    (p_from_serial_number IS NULL OR p_to_serial_number IS NULL OR msn.serial_number between p_from_serial_number AND p_to_serial_number)
		AND    msn.serial_number BETWEEN msnt.FM_SERIAL_NUMBER AND msnt.TO_SERIAL_NUMBER
		AND    msn.inventory_item_id = mmtt.inventory_item_id
		AND    msn.CURRENT_ORGANIZATION_ID=mmtt.organization_id
		AND    mmtt.transaction_temp_id=wdt.transaction_temp_id(+)
		AND    NVL(wdt.status, 1) NOT IN (3, 4, 9)
		GROUP BY mmtt.TRANSACTION_TEMP_ID, mmtt.TASK_PRIORITY
		ORDER BY Nvl(mmtt.TASK_PRIORITY,0);

		l_progress  := '20';


    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Allocated primary qty is ' || l_allocated_pri_qty , g_message);
    END IF;


    l_progress  := '130';

    x_det_allocated_qty:= l_allocated_pri_qty;



  EXCEPTION
    WHEN OTHERS THEN
      IF ( l_debug = 1 ) THEN
        Mdebug(l_api_name||' : l_progress is ' || l_progress);
        Mdebug (    l_api_name||' : Exiting get_serial_allocated_qty - other exceptions: '
                      || SQLERRM, g_error
                    );
      END IF;

      x_det_allocated_qty:= 0;

      RAISE fnd_api.g_exc_unexpected_error;

  END get_serial_allocated_qty;


   /*

  This procedure will backordering the tasks based on the cursor, and quantities passed.

   x_det_alloc_cur - A cursor which will give the pending allocations for the parameters passed.
   x_allocated_qty - Total allocated pending qty for the parameters passed.


  */
  PROCEDURE process_backorder
  (p_count_qty        IN    NUMBER            ,
   p_alloc_cur        IN		t_genref,
	 p_user_id	        IN    VARCHAR2,
   p_allocated_qty    IN		NUMBER,
   x_return_status                   OUT NOCOPY    VARCHAR2,
   x_msg_count                       OUT NOCOPY    NUMBER,
   x_msg_data                        OUT NOCOPY    VARCHAR2
   )
  IS
    l_api_name             CONSTANT VARCHAR2(30) := 'process_backorder';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_progress VARCHAR2 ( 10 );
    l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

    l_min_backorder_qty NUMBER;
    l_tot_backorder_qty NUMBER:=0;
    l_trx_tmp_id NUMBER;
    l_pri_qty NUMBER;
    l_priority NUMBER;

  BEGIN

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
      Mdebug ( l_api_name||' : p_count_qty = ' || p_count_qty , g_message);
      Mdebug ( l_api_name||' : p_allocated_qty = ' || p_allocated_qty , g_message);
    END IF;

		x_return_status := fnd_api.G_RET_STS_SUCCESS;

    l_progress  := '10';


    IF (p_allocated_qty>p_count_qty) THEN

      l_min_backorder_qty := p_allocated_qty - p_count_qty;

      IF ( l_debug = 1 ) THEN
        Mdebug ( l_api_name||' : ***l_min_backorder_qty*** '||l_min_backorder_qty , g_message);
      END IF;

      l_progress    :=  '20';

      LOOP
      FETCH p_alloc_cur INTO l_trx_tmp_id, l_pri_qty, l_priority;
      EXIT WHEN p_alloc_cur%NOTFOUND;

        l_progress    :=  '30';

        wms_txnrsn_actions_pub.cleanup_task
                        ( p_temp_id       => l_trx_tmp_id
                        , p_qty_rsn_id    => 0
                        , p_user_id       => p_user_id
                        , p_employee_id   => -1
                        , p_envoke_workflow => 'N'
                        , x_return_status => x_return_status
                        , x_msg_count     => x_msg_count
                        , x_msg_data      => x_msg_data);

        IF (l_debug = 1) THEN
          mdebug (l_api_name||' : x_return_status for wms_txnrsn_actions_pub.cleanup_task : ' || x_return_status  , g_message);
        END IF;

        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
        END IF;

				l_tot_backorder_qty:= l_tot_backorder_qty+l_pri_qty;

        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : ***l_tot_backorder_qty*** '||l_tot_backorder_qty , g_message);
        END IF;

        l_progress    :=  '40';

        EXIT WHEN l_tot_backorder_qty>= l_min_backorder_qty;

      END LOOP;

      l_progress  := '50';

			IF (p_alloc_cur%ISOPEN) THEN
				CLOSE p_alloc_cur;
			END IF;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF ( l_debug = 1 ) THEN
        Mdebug(l_api_name||' : l_progress is ' || l_progress);
        Mdebug (    l_api_name||' : Exiting process_backorder - other exceptions: '
                      || SQLERRM, g_error
                    );
      END IF;

      x_msg_data := SQLERRM;

      RAISE fnd_api.g_exc_unexpected_error;

  END process_backorder;



   /*

  This procedure will backorder the pending tasks for this item for the passed SKU based on the priority
  if the counted qty is less than the allocated qty.

	Allocations can be of three types.
	1. Allocation at the serial level (if serial allocation is set as Yes).
	2. Allocation at the lpn level (Allocate lpn mode in rules).
	3. Allocation at the locator level.

	Backordering needs to take care of the following conditions.

	1. Counted lpn is in a diff location.
	   a. Delete all the lpn level allocations for this lpn.
		 b. Delete all the serial level allocations for the serial item inside this lpn, if serial allocation is set as Yes.
		 c. Check for the total remaining qty at the locator level for each item inside the lpn, and delete the required allocations.

	2. Counted serial is in a diff location.
	   a. Delete all the serial level allocations for the serials, if serial allocation is set as Yes.
		 b. Check for the total remaining qty at the locator level for the item, and delete the required allocations.

	3. Counted lpn in the same location.
	   a. Check for the total lpn level allocations for this lpn, and backorder the allocations till the allocated qty is <= the count qty.
		 b. If the counted item is serial controlled and if serial allocation is set as Yes, delete the required allocations if the system qty is less than count qty.
		 c. Check for the total remaining qty at the locator level for the item, and delete the required allocations.

	4. Counted serials in the same location.
	   a. If the counted item is serial controlled and if serial allocation is set as Yes, delete the required allocations if the system qty is less than count qty.
		 b. Check for the total remaining qty at the locator level for the item, and delete the required allocations.

	5. Counted for non serial loose qties in the same location.
		 a. Check for the total remaining qty at the locator level for the item, and delete the required allocations.

  */
  PROCEDURE backorder_pending_tasks
  (p_organization_id          IN    NUMBER            ,
   p_subinventory             IN    VARCHAR2          ,
   p_locator_id               IN    NUMBER   := NULL  ,
   p_parent_lpn_id            IN    NUMBER   := NULL  ,
   p_inventory_item_id        IN    NUMBER            ,
   p_revision                 IN    VARCHAR2 := NULL  ,
   p_lot_number               IN    VARCHAR2 := NULL  ,
   p_from_serial_number       IN    VARCHAR2 := NULL  ,
   p_to_serial_number         IN    VARCHAR2 := NULL  ,
   p_count_quantity           IN    NUMBER            ,
   p_count_uom                IN    VARCHAR2          ,
   p_user_id                  IN    NUMBER,
   p_cost_group_id            IN    NUMBER   := NULL,
   p_secondary_uom           IN VARCHAR2    := NULL,
   p_secondary_qty           IN NUMBER      := NULL,
   x_return_status                   OUT NOCOPY    VARCHAR2,
   x_msg_count                       OUT NOCOPY    NUMBER,
   x_msg_data                        OUT NOCOPY    VARCHAR2
   )
  IS

    l_api_name             CONSTANT VARCHAR2(30) := 'backorder_pending_tasks';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_progress VARCHAR2 ( 10 );
    l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

    l_count_primary_qty NUMBER;
    l_count_qty NUMBER;
    l_alloc_qty NUMBER;
    l_alloc_cur t_genref;
    l_det_alloc_qty NUMBER;
    l_det_alloc_cur t_genref;
    l_serial_number_control_code NUMBER;
    l_sys_det_qty NUMBER:=0;
		l_sys_ser_qty NUMBER:=0;
    l_sys_tot_qty NUMBER:=0;
    l_lpn_subinv VARCHAR2(80);
    l_lpn_locator_id NUMBER;
    l_lpn_context NUMBER;
  BEGIN

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
      Mdebug ( l_api_name||' : p_organization_id = ' || p_organization_id , g_message);
      Mdebug ( l_api_name||' : p_subinventory = ' || p_subinventory , g_message);
      Mdebug ( l_api_name||' : p_locator_id = ' || p_locator_id , g_message);
      Mdebug ( l_api_name||' : p_parent_lpn_id = ' || p_parent_lpn_id , g_message);
      Mdebug ( l_api_name||' : p_inventory_item_id = ' || p_inventory_item_id , g_message);
      Mdebug ( l_api_name||' : p_revision = ' || p_revision , g_message);
      Mdebug ( l_api_name||' : p_lot_number = ' || p_lot_number , g_message);
      Mdebug ( l_api_name||' : p_from_serial_number = ' || p_from_serial_number , g_message);
      Mdebug ( l_api_name||' : p_to_serial_number = ' || p_to_serial_number , g_message);
      Mdebug ( l_api_name||' : p_count_quantity = ' || p_count_quantity , g_message);
      Mdebug ( l_api_name||' : p_count_uom = ' || p_count_uom , g_message);
      Mdebug ( l_api_name||' : p_user_id = ' || p_user_id , g_message);
      Mdebug ( l_api_name||' : p_cost_group_id = ' || p_cost_group_id , g_message);
      Mdebug ( l_api_name||' : p_secondary_uom = ' || p_secondary_uom , g_message);
      Mdebug ( l_api_name||' : p_secondary_qty = ' || p_secondary_qty , g_message);
    END IF;

    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    -- backorder pending tasks if needed.

    l_progress    :=  '10';

    IF (NOT inv_cache.Set_org_rec(p_organization_id => p_organization_id)) THEN

      IF (l_debug = 1) THEN
        mdebug(l_api_name||' : '||p_organization_id||' is an invalid organization id',g_error);
      END IF;

      fnd_message.Set_name('WMS','WMS_CONT_INVALID_ORG');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

    END IF;


    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : ***backorder_pending_tasks***' , g_message);
    END IF;

    l_serial_number_control_code := inv_cache.item_rec.serial_number_control_code;

    l_count_primary_qty :=
          inv_convert.inv_um_convert ( p_inventory_item_id,
                                    5,
                                    p_count_quantity,
                                    p_count_uom,
                                    inv_cache.item_rec.primary_uom_code,
                                    NULL,
                                    NULL
                                  );

    l_progress  := '15';

		get_system_qty
			( p_organization_id          => p_organization_id
			, p_subinventory_code        => p_subinventory
			, p_loc_id                   => p_locator_id
			, p_parent_lpn_id            => p_parent_lpn_id
			, p_inventory_item_id        => p_inventory_item_id
			, p_revision                 => p_revision
			, p_lot_number               => p_lot_number
			, p_uom_code                 => inv_cache.item_rec.primary_uom_code
			, x_system_quantity					 => l_sys_det_qty
			);

    IF ( l_debug = 1 ) THEN
			Mdebug ( l_api_name||' : l_sys_det_qty = ' || l_sys_det_qty , g_message);
		END IF;

		IF (l_serial_number_control_code IN ( 2, 5 )) THEN

			l_progress  := '17';

			get_system_qty
				( p_organization_id          => p_organization_id
				, p_subinventory_code        => p_subinventory
				, p_loc_id                   => p_locator_id
				, p_parent_lpn_id            => p_parent_lpn_id
				, p_inventory_item_id        => p_inventory_item_id
				, p_revision                 => p_revision
				, p_lot_number               => p_lot_number
				, p_from_serial_number       => p_from_serial_number
				, p_to_serial_number         => p_to_serial_number
				, p_uom_code                 => inv_cache.item_rec.primary_uom_code
				, x_system_quantity					 => l_sys_ser_qty
				);

			IF ( l_debug = 1 ) THEN
				Mdebug ( l_api_name||' : l_sys_ser_qty = ' || l_sys_ser_qty , g_message);
			END IF;

		END IF;

    IF (p_from_serial_number IS NOT NULL AND p_to_serial_number IS NOT NULL) THEN

			FOR ser_cur IN (SELECT current_subinventory_code, current_locator_id, serial_number
											FROM   mtl_serial_numbers
											WHERE  inventory_item_id = p_inventory_item_id
											AND    current_organization_id = p_organization_id
											AND    serial_number BETWEEN p_from_serial_number AND p_to_serial_number
											AND		 (current_subinventory_code<>p_subinventory
															OR current_locator_id<>p_locator_id)) LOOP

				l_progress  := '18';

				get_serial_allocated_qty
					( p_organization_id          => p_organization_id
					, p_inventory_item_id        => p_inventory_item_id
					, p_from_serial_number       => ser_cur.serial_number
					, p_to_serial_number         => ser_cur.serial_number
					, x_det_allocated_qty        => l_det_alloc_qty
					, x_det_alloc_cur            => l_det_alloc_cur
					);

				IF ( l_debug = 1 ) THEN
					Mdebug ( l_api_name||' : ***l_ser_alloc_qty*** '||l_det_alloc_qty , g_message);
				END IF;

				l_progress  := '19';

				process_backorder
					( p_count_qty			=>	0
					, p_alloc_cur			=>	l_det_alloc_cur
					, p_user_id				=>	p_user_id
					, p_allocated_qty	=>	l_det_alloc_qty
					, x_return_status => x_return_status
					, x_msg_count     => x_msg_count
					, x_msg_data      => x_msg_data
					);

				IF (l_debug = 1) THEN
					mdebug (l_api_name||' : x_return_status for process_backorder : ' || x_return_status  , g_message);
				END IF;

				IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
						RAISE fnd_api.g_exc_unexpected_error;
				ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
						RAISE fnd_api.g_exc_error;
				END IF;

			END LOOP;

      IF (l_sys_ser_qty>l_count_primary_qty) THEN

				l_progress  := '20';

        get_serial_allocated_qty
					( p_organization_id          => p_organization_id
					, p_inventory_item_id        => p_inventory_item_id
					, p_from_serial_number       => p_from_serial_number
					, p_to_serial_number         => p_to_serial_number
					, x_det_allocated_qty        => l_det_alloc_qty
					, x_det_alloc_cur            => l_det_alloc_cur
					);

				IF ( l_debug = 1 ) THEN
					Mdebug ( l_api_name||' : ***l_ser_alloc_qty*** '||l_det_alloc_qty , g_message);
				END IF;

        l_progress  := '21';

				process_backorder
					( p_count_qty			=>	l_count_primary_qty
					, p_alloc_cur			=>	l_det_alloc_cur
					, p_user_id				=>	p_user_id
					, p_allocated_qty	=>	l_det_alloc_qty
          , x_return_status => x_return_status
          , x_msg_count     => x_msg_count
          , x_msg_data      => x_msg_data
					);

        IF (l_debug = 1) THEN
          mdebug (l_api_name||' : x_return_status for process_backorder : ' || x_return_status  , g_message);
        END IF;

        l_progress  := '22';

        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

		END IF;


    l_progress  := '25';

    IF ( p_parent_lpn_id IS NOT NULL ) THEN

      SELECT NVL ( subinventory_code, '###' ),
            NVL ( locator_id, -99 ),
            lpn_context
      INTO   l_lpn_subinv,
            l_lpn_locator_id,
            l_lpn_context
      FROM   WMS_LICENSE_PLATE_NUMBERS
      WHERE  lpn_id = p_parent_lpn_id ;

      l_progress  := '30';

      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : l_lpn_subinv: ===> ' || l_lpn_subinv , g_message);
          Mdebug ( l_api_name||' : l_lpn_locator_id: => ' || l_lpn_locator_id , g_message);
          Mdebug ( l_api_name||' : l_lpn_context: => ' || l_lpn_context , g_message);
      END IF;

      IF (l_lpn_context = 8 or l_lpn_context = 9 or l_lpn_context = 4 or l_lpn_context = 6) THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : Returning as lpn is not in inventory' , g_message);
        END IF;

        RETURN;
			ELSIF (p_subinventory=l_lpn_subinv AND p_locator_id=l_lpn_locator_id) THEN

				IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : LPN is already in the count subinv. So backorder only required allocations.' , g_message);
        END IF;

        l_progress  := '40';

        IF ((l_serial_number_control_code IN ( 1, 6 ) AND l_sys_det_qty>l_count_primary_qty)
            OR (l_serial_number_control_code IN ( 2,5 ) AND l_sys_ser_qty>l_count_primary_qty AND Nvl(inv_cache.org_rec.ALLOCATE_SERIAL_FLAG, 'N')='N')) THEN

					get_allocated_qty
						( p_organization_id          => p_organization_id
						, p_subinventory             => p_subinventory
						, p_locator_id               => p_locator_id
						, p_parent_lpn_id            => p_parent_lpn_id
						, p_inventory_item_id        => p_inventory_item_id
						, p_revision                 => p_revision
						, p_lot_number               => p_lot_number
						, x_allocated_qty						 => l_det_alloc_qty
						, x_alloc_cur								 => l_det_alloc_cur
						);

					IF ( l_debug = 1 ) THEN
						Mdebug ( l_api_name||' : ***l_det_alloc_qty*** '||l_det_alloc_qty , g_message);
					END IF;

          l_progress  := '50';

					IF (l_serial_number_control_code IN ( 1, 6 )) THEN
						l_count_qty := l_count_primary_qty;
					ELSE
						l_count_qty := (l_sys_det_qty-(l_sys_ser_qty-l_count_primary_qty));
					END IF;

					process_backorder
						( p_count_qty			=>	l_count_qty
						, p_alloc_cur			=>	l_det_alloc_cur
						, p_user_id				=>	p_user_id
						, p_allocated_qty	=>	l_det_alloc_qty
						, x_return_status => x_return_status
						, x_msg_count     => x_msg_count
						, x_msg_data      => x_msg_data
						);


          l_progress  := '60';

          IF (l_debug = 1) THEN
            mdebug (l_api_name||' : x_return_status for process_backorder : ' || x_return_status  , g_message);
          END IF;

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

			ELSE

				IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : LPN is in different subinv. So backorder all lpn allocations.' , g_message);
        END IF;

        l_progress  := '70';

        FOR lpn_contents_cur IN (SELECT DISTINCT wlc.inventory_item_id, wlc.lot_number, wlc.revision, DECODE(NVL(msn.serial_number, 'XXXX'), 'XXXX', wlc.primary_quantity, 1) primary_quantity, msn.serial_number
																	 FROM wms_lpn_contents wlc, mtl_serial_numbers msn
																	WHERE wlc.parent_lpn_id=p_parent_lpn_id
																		AND wlc.inventory_item_id = msn.inventory_item_id (+)
																		AND ( msn.inventory_item_id IS NULL
																				OR (msn.current_organization_id = p_organization_id
																						AND msn.lpn_id=wlc.parent_lpn_id)))
				LOOP

          IF (NOT inv_cache.Set_item_rec(p_organization_id => p_organization_id, p_item_id => lpn_contents_cur.inventory_item_id)) THEN

              IF (l_debug = 1) THEN
                mdebug(l_api_name||' : '||lpn_contents_cur.inventory_item_id||' is an invalid item',g_error);
              END IF;

              fnd_message.Set_name('WMS','WMS_CONT_INVALID_ITEM');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;

          END IF;

          l_progress  := '80';

				  get_allocated_qty
					  ( p_organization_id          => p_organization_id
					  , p_subinventory             => l_lpn_subinv
					  , p_locator_id               => l_lpn_locator_id
					  , p_parent_lpn_id            => p_parent_lpn_id
					  , p_inventory_item_id        => lpn_contents_cur.inventory_item_id
					  , p_revision                 => lpn_contents_cur.revision
					  , p_lot_number               => lpn_contents_cur.lot_number
					  , p_from_serial_number       => lpn_contents_cur.serial_number
					  , p_to_serial_number         => lpn_contents_cur.serial_number
					  , x_allocated_qty						 => l_det_alloc_qty
					  , x_alloc_cur								 => l_det_alloc_cur
					  );

				  IF ( l_debug = 1 ) THEN
					  Mdebug ( l_api_name||' : ***l_det_alloc_qty*** '||l_det_alloc_qty , g_message);
				  END IF;

          l_progress  := '100';

				  process_backorder
					  ( p_count_qty			=>	0
					  , p_alloc_cur			=>	l_det_alloc_cur
					  , p_user_id				=>	p_user_id
					  , p_allocated_qty	=>	l_det_alloc_qty
            , x_return_status => x_return_status
            , x_msg_count     => x_msg_count
            , x_msg_data      => x_msg_data
				    );

          IF (l_debug = 1) THEN
            mdebug (l_api_name||' : x_return_status for process_backorder : ' || x_return_status  , g_message);
          END IF;

          l_progress  := '110';

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
          END IF;


				  IF ( Nvl(inv_cache.org_rec.ALLOCATE_SERIAL_FLAG, 'N')='Y' AND lpn_contents_cur.serial_number IS NOT NULL) THEN

					  l_progress  := '120';

            get_serial_allocated_qty
						  ( p_organization_id          => p_organization_id
						  , p_inventory_item_id        => lpn_contents_cur.inventory_item_id
						  , p_from_serial_number       => lpn_contents_cur.serial_number
						  , p_to_serial_number         => lpn_contents_cur.serial_number
						  , x_det_allocated_qty        => l_det_alloc_qty
						  , x_det_alloc_cur            => l_det_alloc_cur
						  );

					  IF ( l_debug = 1 ) THEN
						  Mdebug ( l_api_name||' : ***l_ser_alloc_qty*** '||l_det_alloc_qty , g_message);
					  END IF;

					  l_progress  := '130';

            process_backorder
						  ( p_count_qty			=>	0
						  , p_alloc_cur			=>	l_det_alloc_cur
						  , p_user_id				=>	p_user_id
						  , p_allocated_qty	=>	l_det_alloc_qty
              , x_return_status => x_return_status
              , x_msg_count     => x_msg_count
              , x_msg_data      => x_msg_data
						  );

            IF (l_debug = 1) THEN
              mdebug (l_api_name||' : x_return_status for process_backorder : ' || x_return_status  , g_message);
            END IF;

            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
            END IF;

					END IF;

        END LOOP;

				FOR lpn_contents_cur IN (SELECT wlc.inventory_item_id, wlc.lot_number, wlc.revision, Sum(wlc.primary_quantity) primary_quantity
																	 FROM wms_lpn_contents wlc
																	WHERE wlc.parent_lpn_id=p_parent_lpn_id
                                  GROUP BY wlc.inventory_item_id, wlc.lot_number, wlc.revision)
				LOOP

          IF (NOT inv_cache.Set_item_rec(p_organization_id => p_organization_id, p_item_id => lpn_contents_cur.inventory_item_id)) THEN

              IF (l_debug = 1) THEN
                mdebug(l_api_name||' : '||lpn_contents_cur.inventory_item_id||' is an invalid item',g_error);
              END IF;

              fnd_message.Set_name('WMS','WMS_CONT_INVALID_ITEM');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;

          END IF;

          l_progress  := '131';

					get_locator_quantity
						( p_organization_id          => p_organization_id
						, p_subinventory             => l_lpn_subinv
						, p_locator_id               => l_lpn_locator_id
						, p_inventory_item_id        => lpn_contents_cur.inventory_item_id
						, p_revision                 => lpn_contents_cur.revision
						, p_lot_number               => lpn_contents_cur.lot_number
						, x_system_quantity					 => l_sys_tot_qty
						);

					IF ( l_debug = 1 ) THEN
						Mdebug ( l_api_name||' : System qty at the locator = ' || l_sys_tot_qty , g_message);
					END IF;

					l_progress  := '140';

					get_allocated_qty
						( p_organization_id          => p_organization_id
						, p_subinventory             => l_lpn_subinv
						, p_locator_id               => l_lpn_locator_id
						, p_inventory_item_id        => lpn_contents_cur.inventory_item_id
						, p_revision                 => lpn_contents_cur.revision
						, p_lot_number               => lpn_contents_cur.lot_number
						, x_allocated_qty						 => l_alloc_qty
						, x_alloc_cur								 => l_alloc_cur
						);

					IF ( l_debug = 1 ) THEN
						Mdebug ( l_api_name||' : ***l_alloc_qty*** '||l_alloc_qty , g_message);
					END IF;

					IF (l_alloc_qty>(l_sys_tot_qty-(lpn_contents_cur.primary_quantity)))	THEN

						l_progress  := '160';

						process_backorder
							( p_count_qty			=>	(l_sys_tot_qty-(lpn_contents_cur.primary_quantity))
							, p_alloc_cur			=>	l_alloc_cur
							, p_user_id				=>	p_user_id
							, p_allocated_qty	=>	l_alloc_qty
							, x_return_status => x_return_status
							, x_msg_count     => x_msg_count
							, x_msg_data      => x_msg_data
							);

						IF (l_debug = 1) THEN
							mdebug (l_api_name||' : x_return_status for process_backorder : ' || x_return_status  , g_message);
						END IF;

						IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
								RAISE fnd_api.g_exc_unexpected_error;
						ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
								RAISE fnd_api.g_exc_error;
						END IF;

					END IF;
				END LOOP;

        l_progress  := '170';

        IF (NOT inv_cache.Set_item_rec(p_organization_id => p_organization_id, p_item_id => p_inventory_item_id)) THEN

          IF (l_debug = 1) THEN
            mdebug(l_api_name||' : '||p_inventory_item_id||' is an invalid item',g_error);
          END IF;

          fnd_message.Set_name('WMS','WMS_CONT_INVALID_ITEM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;

        END IF;

        l_progress  := '180';

        l_count_primary_qty :=
          inv_convert.inv_um_convert ( p_inventory_item_id,
                                    5,
                                    p_count_quantity,
                                    p_count_uom,
                                    inv_cache.item_rec.primary_uom_code,
                                    NULL,
                                    NULL
                                  );

        l_progress  := '190';

      END IF;

    END IF;

    IF (p_from_serial_number IS NOT NULL AND p_to_serial_number IS NOT NULL) THEN

			FOR ser_cur IN (SELECT current_subinventory_code, current_locator_id, Count(DISTINCT serial_number) ser_cnt
											FROM   mtl_serial_numbers
											WHERE  inventory_item_id = p_inventory_item_id
											AND    current_organization_id = p_organization_id
											AND    serial_number BETWEEN p_from_serial_number AND p_to_serial_number
											AND		 (current_subinventory_code<>p_subinventory
															OR current_locator_id<>p_locator_id)
											GROUP BY current_subinventory_code, current_locator_id) LOOP

				l_progress  := '193';

				get_locator_quantity
					( p_organization_id          => p_organization_id
					, p_subinventory             => ser_cur.current_subinventory_code
					, p_locator_id               => ser_cur.current_locator_id
					, p_inventory_item_id        => p_inventory_item_id
					, p_revision                 => p_revision
					, p_lot_number               => p_lot_number
					, x_system_quantity					 => l_sys_tot_qty
					);

				IF ( l_debug = 1 ) THEN
					Mdebug ( l_api_name||' : System qty at the locator = ' || l_sys_tot_qty , g_message);
				END IF;

				l_progress  := '194';

				get_allocated_qty
					( p_organization_id          => p_organization_id
					, p_subinventory             => ser_cur.current_subinventory_code
					, p_locator_id               => ser_cur.current_locator_id
					, p_inventory_item_id        => p_inventory_item_id
					, p_revision                 => p_revision
					, p_lot_number               => p_lot_number
					, x_allocated_qty						 => l_alloc_qty
					, x_alloc_cur								 => l_alloc_cur
					);

				IF ( l_debug = 1 ) THEN
					Mdebug ( l_api_name||' : ***l_alloc_qty*** '||l_alloc_qty , g_message);
				END IF;

				IF (l_alloc_qty>(l_sys_tot_qty-(ser_cur.ser_cnt)))	THEN

					l_progress  := '195';

					process_backorder
						( p_count_qty			=>	(l_sys_tot_qty-(ser_cur.ser_cnt))
						, p_alloc_cur			=>	l_alloc_cur
						, p_user_id				=>	p_user_id
						, p_allocated_qty	=>	l_alloc_qty
						, x_return_status => x_return_status
						, x_msg_count     => x_msg_count
						, x_msg_data      => x_msg_data
						);

					IF (l_debug = 1) THEN
						mdebug (l_api_name||' : x_return_status for process_backorder : ' || x_return_status  , g_message);
					END IF;

					IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
							RAISE fnd_api.g_exc_unexpected_error;
					ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
							RAISE fnd_api.g_exc_error;
					END IF;

				END IF;

			END LOOP;

    END IF;

		IF ( l_debug = 1 ) THEN
			Mdebug ( l_api_name||' : l_serial_number_control_code = ' || l_serial_number_control_code , g_message);
		END IF;

    IF ((l_serial_number_control_code IN ( 1, 6 ) AND l_sys_det_qty>l_count_primary_qty)
        OR (l_serial_number_control_code IN ( 2,5 ) AND l_sys_ser_qty>l_count_primary_qty AND Nvl(inv_cache.org_rec.ALLOCATE_SERIAL_FLAG, 'N')='N')) THEN

      l_progress  := '210';

			get_locator_quantity
				( p_organization_id          => p_organization_id
				, p_subinventory             => p_subinventory
				, p_locator_id               => p_locator_id
				, p_inventory_item_id        => p_inventory_item_id
				, p_revision                 => p_revision
				, p_lot_number               => p_lot_number
				, x_system_quantity					 => l_sys_tot_qty
				);

			IF ( l_debug = 1 ) THEN
				Mdebug ( l_api_name||' : System qty at the locator = ' || l_sys_tot_qty , g_message);
			END IF;

			l_progress  := '260';

			get_allocated_qty
				( p_organization_id          => p_organization_id
				, p_subinventory             => p_subinventory
				, p_locator_id               => p_locator_id
				, p_inventory_item_id        => p_inventory_item_id
				, p_revision                 => p_revision
				, p_lot_number               => p_lot_number
				, x_allocated_qty						 => l_alloc_qty
				, x_alloc_cur								 => l_alloc_cur
				);

			IF ( l_debug = 1 ) THEN
				Mdebug ( l_api_name||' : ***l_alloc_qty*** '||l_alloc_qty , g_message);
			END IF;

			l_progress  := '270';

			IF (l_serial_number_control_code IN ( 1, 6 )) THEN
				l_count_qty := (l_sys_tot_qty-(l_sys_det_qty-l_count_primary_qty));
			ELSE
				l_count_qty := (l_sys_tot_qty-(l_sys_ser_qty-l_count_primary_qty));
			END IF;

			IF (l_alloc_qty>l_count_qty)	THEN

				process_backorder
					( p_count_qty			=>	l_count_qty
					, p_alloc_cur			=>	l_alloc_cur
					, p_user_id				=>	p_user_id
					, p_allocated_qty	=>	l_alloc_qty
					, x_return_status => x_return_status
					, x_msg_count     => x_msg_count
					, x_msg_data      => x_msg_data
					);

				IF (l_debug = 1) THEN
					mdebug (l_api_name||' : x_return_status for process_backorder : ' || x_return_status  , g_message);
				END IF;

				l_progress  := '280';

				IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
						RAISE fnd_api.g_exc_unexpected_error;
				ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
						RAISE fnd_api.g_exc_error;
				END IF;

			END IF;

    END IF;

    l_progress    :=  '290';

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF (x_msg_count IS NULL AND x_msg_data IS NULL) THEN
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      END IF;
      IF (l_debug = 1) THEN
        Mdebug(l_api_name||' : l_progress is ' || l_progress);
        Mdebug(l_api_name||' : RAISE fnd_api.g_exc_error: ' || SQLERRM);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (x_msg_count IS NULL AND x_msg_data IS NULL) THEN
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      END IF;
      IF (l_debug = 1) THEN
        Mdebug(l_api_name||' : l_progress is ' || l_progress);
        Mdebug(l_api_name||' : RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
      END IF;

  END backorder_pending_tasks;

  /*

  This procedure will be processing the cyc count request.

  */
  PROCEDURE process_entry
  (p_cycle_count_header_id    IN    NUMBER            ,
   p_organization_id          IN    NUMBER            ,
   p_subinventory             IN    VARCHAR2          ,
   p_locator_id               IN    NUMBER   := NULL  ,
   p_parent_lpn_id            IN    NUMBER   := NULL  ,
   p_inventory_item_id        IN    NUMBER            ,
   p_revision                 IN    VARCHAR2 := NULL  ,
   p_lot_number               IN    VARCHAR2 := NULL  ,
   p_from_serial_number       IN    VARCHAR2 := NULL  ,
   p_to_serial_number         IN    VARCHAR2 := NULL  ,
   p_sys_quantity             IN    NUMBER            ,
   p_count_quantity           IN    NUMBER            ,
   p_count_uom                IN    VARCHAR2          ,
   p_unscheduled_count_entry  IN    NUMBER            ,
   p_user_id                  IN    NUMBER            ,
   p_cost_group_id            IN    NUMBER   := NULL  ,
   p_secondary_uom            IN    VARCHAR2 := NULL  ,
   p_secondary_qty            IN    NUMBER   := NULL
   )
  IS
     l_api_name             CONSTANT VARCHAR2(30) := 'process_entry';
     l_api_version          CONSTANT NUMBER := 1.0;
     l_sys_quantity        NUMBER := p_sys_quantity;
     l_return_status       VARCHAR2(1):= fnd_api.G_RET_STS_SUCCESS;
     l_progress             VARCHAR2(500) := 'Entered API';
     l_msg_count           NUMBER;
     l_msg_data            VARCHAR2(4000);
     l_debug               NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );

  BEGIN

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
      Mdebug ( l_api_name||' : p_cycle_count_header_id = ' || p_cycle_count_header_id , g_message);
      Mdebug ( l_api_name||' : p_organization_id = ' || p_organization_id , g_message);
      Mdebug ( l_api_name||' : p_subinventory = ' || p_subinventory , g_message);
      Mdebug ( l_api_name||' : p_locator_id = ' || p_locator_id , g_message);
      Mdebug ( l_api_name||' : p_parent_lpn_id = ' || p_parent_lpn_id , g_message);
      Mdebug ( l_api_name||' : p_inventory_item_id = ' || p_inventory_item_id , g_message);
      Mdebug ( l_api_name||' : p_revision = ' || p_revision , g_message);
      Mdebug ( l_api_name||' : p_lot_number = ' || p_lot_number , g_message);
      Mdebug ( l_api_name||' : p_from_serial_number = ' || p_from_serial_number , g_message);
      Mdebug ( l_api_name||' : p_to_serial_number = ' || p_to_serial_number , g_message);
      Mdebug ( l_api_name||' : p_sys_quantity = ' || p_sys_quantity , g_message);
      Mdebug ( l_api_name||' : p_count_quantity = ' || p_count_quantity , g_message);
      Mdebug ( l_api_name||' : p_count_uom = ' || p_count_uom , g_message);
      Mdebug ( l_api_name||' : p_user_id = ' || p_user_id , g_message);
      Mdebug ( l_api_name||' : p_cost_group_id = ' || p_cost_group_id , g_message);
      Mdebug ( l_api_name||' : p_secondary_uom = ' || p_secondary_uom , g_message);
      Mdebug ( l_api_name||' : p_secondary_qty = ' || p_secondary_qty , g_message);
    END IF;

    g_cycle_count_header_id :=  p_cycle_count_header_id;

    IF (l_debug = 1) THEN
      mdebug (l_api_name||' : g_cycle_count_header_id : ' || g_cycle_count_header_id  , g_message);
    END IF;

    l_progress := 'Validate Organization';

    IF (NOT inv_cache.Set_org_rec(p_organization_id => p_organization_id)) THEN

      IF (l_debug = 1) THEN
        mdebug(l_api_name||' : '||p_organization_id||' is an invalid organization id',g_error);
      END IF;

      fnd_message.Set_name('WMS','WMS_CONT_INVALID_ORG');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

    END IF;

    l_progress := 'After Validating Organization';

    l_progress := 'Validate Item';

    IF (NOT inv_cache.Set_item_rec(p_organization_id => p_organization_id, p_item_id => p_inventory_item_id)) THEN

      IF (l_debug = 1) THEN
        mdebug(l_api_name||' : '||p_inventory_item_id||' is an invalid item',g_error);
      END IF;

      fnd_message.Set_name('WMS','WMS_CONT_INVALID_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

    END IF;

    -- backorder pending tasks if needed.

    backorder_pending_tasks
    ( p_organization_id          => p_organization_id
    , p_subinventory             => p_subinventory
    , p_locator_id               => p_locator_id
    , p_parent_lpn_id            => p_parent_lpn_id
    , p_inventory_item_id        => p_inventory_item_id
    , p_revision                 => p_revision
    , p_lot_number               => p_lot_number
    , p_from_serial_number       => p_from_serial_number
    , p_to_serial_number         => p_to_serial_number
    , p_count_quantity           => p_count_quantity
    , p_count_uom                => p_count_uom
    , p_user_id                  => p_user_id
    , p_cost_group_id            => p_cost_group_id
    , p_secondary_uom            => p_secondary_uom
    , p_secondary_qty            => p_secondary_qty
    , x_return_status            => l_return_status
    , x_msg_count                => l_msg_count
    , x_msg_data                 => l_msg_data
    );

    l_progress := 'After backorder_pending_tasks';

    IF (l_debug = 1) THEN
      mdebug (l_api_name||' : x_return_status of backorder_pending_tasks : ' || l_return_status  , g_message);
    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_unexp_error AND  l_return_status <> fnd_api.g_ret_sts_error THEN

          l_progress := 'INV_CYC_LOVS.process_entry';

          INV_CYC_LOVS.process_entry
            ( p_cycle_count_header_id     => p_cycle_count_header_id
            , p_organization_id          => p_organization_id
            , p_subinventory             => p_subinventory
            , p_locator_id               => p_locator_id
            , p_parent_lpn_id            => p_parent_lpn_id
            , p_inventory_item_id        => p_inventory_item_id
            , p_revision                 => p_revision
            , p_lot_number               => p_lot_number
            , p_from_serial_number       => p_from_serial_number
            , p_to_serial_number         => p_to_serial_number
            , p_count_quantity           => p_count_quantity
            , p_count_uom                => p_count_uom
            , p_unscheduled_count_entry  => p_unscheduled_count_entry
            , p_user_id                  => p_user_id
            , p_cost_group_id            => p_cost_group_id
            , p_secondary_uom            => p_secondary_uom
            , p_secondary_qty            => p_secondary_qty
            );

          l_progress := 'delete_existing_cyc_count';


          -- Delete existing cyc count tasks.

          delete_existing_cyc_count
              (p_organization_id          => p_organization_id
              , p_subinventory             => p_subinventory
              , p_locator_id               => p_locator_id
              , p_inventory_item_id        => p_inventory_item_id);

          l_progress := 'After delete_existing_cyc_count';


    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : l_progress is ' || l_progress);
          Mdebug(l_api_name||' : RAISE fnd_api.g_exc_error: ' || SQLERRM);
        END IF;
    WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : l_progress is ' || l_progress);
          Mdebug(l_api_name||' : RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        END IF;

  END process_entry;

  /*

  This procedure will be processing the summary cyc count request .

  */
  PROCEDURE process_summary
  (p_cycle_count_header_id    IN    NUMBER            ,
   p_organization_id          IN    NUMBER            ,
   p_subinventory             IN    VARCHAR2          ,
   p_locator_id               IN    NUMBER   := NULL  ,
   p_parent_lpn_id            IN    NUMBER   := NULL  ,
   p_inventory_item_id        IN    NUMBER            ,
   p_unscheduled_count_entry  IN    NUMBER            ,
   p_user_id                  IN    NUMBER
   )
  IS
    l_api_name             CONSTANT VARCHAR2(30) := 'process_summary';
    l_api_version          CONSTANT NUMBER := 1.0;
    l_return_status       VARCHAR2(1):= fnd_api.G_RET_STS_SUCCESS;
    l_progress             VARCHAR2(500) := 'Entered API';
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(4000);
    l_debug               NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
    l_alloc_qty NUMBER;
    l_alloc_cur t_genref;
    l_det_alloc_qty NUMBER;
    l_det_alloc_cur t_genref;
    l_sys_tot_qty NUMBER:=0;
    l_lpn_subinv VARCHAR2(80);
    l_lpn_locator_id NUMBER;
    l_lpn_context NUMBER;

  BEGIN

    IF ( l_debug = 1 ) THEN
      Mdebug ( l_api_name||' : Entered api ' || l_api_name , g_message);
      Mdebug ( l_api_name||' : p_cycle_count_header_id = ' || p_cycle_count_header_id , g_message);
      Mdebug ( l_api_name||' : p_organization_id = ' || p_organization_id , g_message);
      Mdebug ( l_api_name||' : p_subinventory = ' || p_subinventory , g_message);
      Mdebug ( l_api_name||' : p_locator_id = ' || p_locator_id , g_message);
      Mdebug ( l_api_name||' : p_parent_lpn_id = ' || p_parent_lpn_id , g_message);
      Mdebug ( l_api_name||' : p_inventory_item_id = ' || p_inventory_item_id , g_message);
      Mdebug ( l_api_name||' : p_user_id = ' || p_user_id , g_message);
      Mdebug ( l_api_name||' : p_unscheduled_count_entry = ' || p_unscheduled_count_entry , g_message);
    END IF;

    l_progress := 'Validate Organization';

    IF (NOT inv_cache.Set_org_rec(p_organization_id => p_organization_id)) THEN

      IF (l_debug = 1) THEN
        mdebug(l_api_name||' : '||p_organization_id||' is an invalid organization id',g_error);
      END IF;

      fnd_message.Set_name('WMS','WMS_CONT_INVALID_ORG');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

    END IF;

    l_progress := 'After Validating Organization';

    l_progress := 'Validate Item';

    IF (NOT inv_cache.Set_item_rec(p_organization_id => p_organization_id, p_item_id => p_inventory_item_id)) THEN

      IF (l_debug = 1) THEN
        mdebug(l_api_name||' : '||p_inventory_item_id||' is an invalid item',g_error);
      END IF;

      fnd_message.Set_name('WMS','WMS_CONT_INVALID_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

    END IF;

    IF ( p_parent_lpn_id IS NOT NULL ) THEN

      SELECT NVL ( subinventory_code, '###' ),
            NVL ( locator_id, -99 ),
            lpn_context
      INTO   l_lpn_subinv,
            l_lpn_locator_id,
            l_lpn_context
      FROM   WMS_LICENSE_PLATE_NUMBERS
      WHERE  lpn_id = p_parent_lpn_id ;

      l_progress  := '30';

      IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : l_lpn_subinv: ===> ' || l_lpn_subinv , g_message);
          Mdebug ( l_api_name||' : l_lpn_locator_id: => ' || l_lpn_locator_id , g_message);
          Mdebug ( l_api_name||' : l_lpn_context: => ' || l_lpn_context , g_message);
      END IF;

      IF (l_lpn_context = 8 or l_lpn_context = 9 or l_lpn_context = 4 or l_lpn_context = 6) THEN
        IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : Returning as lpn is not in inventory' , g_message);
        END IF;

        RETURN;
			ELSIF (p_subinventory<>l_lpn_subinv OR p_locator_id<>l_lpn_locator_id) THEN

				IF ( l_debug = 1 ) THEN
          Mdebug ( l_api_name||' : LPN is in different subinv. So backorder all lpn allocations.' , g_message);
        END IF;

        l_progress  := '70';

				FOR lpn_contents_cur IN (SELECT DISTINCT wlc.inventory_item_id, wlc.lot_number, wlc.revision, DECODE(NVL(msn.serial_number, 'XXXX'), 'XXXX', wlc.primary_quantity, 1) primary_quantity, msn.serial_number
																	 FROM wms_lpn_contents wlc, mtl_serial_numbers msn
																	WHERE wlc.parent_lpn_id=p_parent_lpn_id
																		AND wlc.inventory_item_id = msn.inventory_item_id (+)
																		AND ( msn.inventory_item_id IS NULL
																				OR (msn.current_organization_id = p_organization_id
																						AND msn.lpn_id=wlc.parent_lpn_id)))
				LOOP

          IF (NOT inv_cache.Set_item_rec(p_organization_id => p_organization_id, p_item_id => lpn_contents_cur.inventory_item_id)) THEN

              IF (l_debug = 1) THEN
                mdebug(l_api_name||' : '||lpn_contents_cur.inventory_item_id||' is an invalid item',g_error);
              END IF;

              fnd_message.Set_name('WMS','WMS_CONT_INVALID_ITEM');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;

          END IF;

          l_progress  := '80';

				  get_allocated_qty
					  ( p_organization_id          => p_organization_id
					  , p_subinventory             => l_lpn_subinv
					  , p_locator_id               => l_lpn_locator_id
					  , p_parent_lpn_id            => p_parent_lpn_id
					  , p_inventory_item_id        => lpn_contents_cur.inventory_item_id
					  , p_revision                 => lpn_contents_cur.revision
					  , p_lot_number               => lpn_contents_cur.lot_number
					  , p_from_serial_number       => lpn_contents_cur.serial_number
					  , p_to_serial_number         => lpn_contents_cur.serial_number
					  , x_allocated_qty						 => l_det_alloc_qty
					  , x_alloc_cur								 => l_det_alloc_cur
					  );

				  IF ( l_debug = 1 ) THEN
					  Mdebug ( l_api_name||' : ***l_det_alloc_qty*** '||l_det_alloc_qty , g_message);
				  END IF;

          l_progress  := '100';

				  process_backorder
					  ( p_count_qty			=>	0
					  , p_alloc_cur			=>	l_det_alloc_cur
					  , p_user_id				=>	p_user_id
					  , p_allocated_qty	=>	l_det_alloc_qty
            , x_return_status => l_return_status
            , x_msg_count     => l_msg_count
            , x_msg_data      => l_msg_data
				    );

          IF (l_debug = 1) THEN
            mdebug (l_api_name||' : x_return_status for process_backorder : ' || l_return_status  , g_message);
          END IF;

          l_progress  := '110';

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
          END IF;


				  IF ( Nvl(inv_cache.org_rec.ALLOCATE_SERIAL_FLAG, 'N')='Y' AND lpn_contents_cur.serial_number IS NOT NULL) THEN

					  l_progress  := '120';

            get_serial_allocated_qty
						  ( p_organization_id          => p_organization_id
						  , p_inventory_item_id        => lpn_contents_cur.inventory_item_id
						  , p_from_serial_number       => lpn_contents_cur.serial_number
						  , p_to_serial_number         => lpn_contents_cur.serial_number
						  , x_det_allocated_qty        => l_det_alloc_qty
						  , x_det_alloc_cur            => l_det_alloc_cur
						  );

					  IF ( l_debug = 1 ) THEN
						  Mdebug ( l_api_name||' : ***l_ser_alloc_qty*** '||l_det_alloc_qty , g_message);
					  END IF;

					  l_progress  := '130';

            process_backorder
						  ( p_count_qty			=>	0
						  , p_alloc_cur			=>	l_det_alloc_cur
						  , p_user_id				=>	p_user_id
						  , p_allocated_qty	=>	l_det_alloc_qty
              , x_return_status =>  l_return_status
              , x_msg_count     =>  l_msg_count
              , x_msg_data      =>  l_msg_data
						  );

            IF (l_debug = 1) THEN
              mdebug (l_api_name||' : l_return_status for process_backorder : ' || l_return_status  , g_message);
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
            END IF;

					END IF;

        END LOOP;

				FOR lpn_contents_cur IN (SELECT wlc.inventory_item_id, wlc.lot_number, wlc.revision, Sum(wlc.primary_quantity) primary_quantity
																	 FROM wms_lpn_contents wlc
																	WHERE wlc.parent_lpn_id=p_parent_lpn_id
                                  GROUP BY wlc.inventory_item_id, wlc.lot_number, wlc.revision)
				LOOP

          IF (NOT inv_cache.Set_item_rec(p_organization_id => p_organization_id, p_item_id => lpn_contents_cur.inventory_item_id)) THEN

              IF (l_debug = 1) THEN
                mdebug(l_api_name||' : '||lpn_contents_cur.inventory_item_id||' is an invalid item',g_error);
              END IF;

              fnd_message.Set_name('WMS','WMS_CONT_INVALID_ITEM');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;

          END IF;

          l_progress  := '131';

					get_locator_quantity
						( p_organization_id          => p_organization_id
						, p_subinventory             => l_lpn_subinv
						, p_locator_id               => l_lpn_locator_id
						, p_inventory_item_id        => lpn_contents_cur.inventory_item_id
						, p_revision                 => lpn_contents_cur.revision
						, p_lot_number               => lpn_contents_cur.lot_number
						, x_system_quantity					 => l_sys_tot_qty
						);

					IF ( l_debug = 1 ) THEN
						Mdebug ( l_api_name||' : System qty at the locator = ' || l_sys_tot_qty , g_message);
					END IF;

					l_progress  := '140';

					get_allocated_qty
						( p_organization_id          => p_organization_id
						, p_subinventory             => l_lpn_subinv
						, p_locator_id               => l_lpn_locator_id
						, p_inventory_item_id        => lpn_contents_cur.inventory_item_id
						, p_revision                 => lpn_contents_cur.revision
						, p_lot_number               => lpn_contents_cur.lot_number
						, x_allocated_qty						 => l_alloc_qty
						, x_alloc_cur								 => l_alloc_cur
						);

					IF ( l_debug = 1 ) THEN
						Mdebug ( l_api_name||' : ***l_alloc_qty*** '||l_alloc_qty , g_message);
					END IF;

					IF (l_alloc_qty>(l_sys_tot_qty-(lpn_contents_cur.primary_quantity)))	THEN

						l_progress  := '160';

						process_backorder
							( p_count_qty			=>	(l_sys_tot_qty-(lpn_contents_cur.primary_quantity))
							, p_alloc_cur			=>	l_alloc_cur
							, p_user_id				=>	p_user_id
							, p_allocated_qty	=>	l_alloc_qty
							, x_return_status =>  l_return_status
							, x_msg_count     =>  l_msg_count
							, x_msg_data      =>  l_msg_data
							);

						IF (l_debug = 1) THEN
							mdebug (l_api_name||' : l_return_status for process_backorder : ' || l_return_status  , g_message);
						END IF;

						IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
								RAISE fnd_api.g_exc_unexpected_error;
						ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
								RAISE fnd_api.g_exc_error;
						END IF;

					END IF;
				END LOOP;

        l_progress  := '170';

        IF (NOT inv_cache.Set_item_rec(p_organization_id => p_organization_id, p_item_id => p_inventory_item_id)) THEN

          IF (l_debug = 1) THEN
            mdebug(l_api_name||' : '||p_inventory_item_id||' is an invalid item',g_error);
          END IF;

          fnd_message.Set_name('WMS','WMS_CONT_INVALID_ITEM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;

        END IF;

        l_progress  := '180';

      END IF;

    END IF;

    l_progress := 'INV_CYC_LOVS.process_summary';

    INV_CYC_LOVS.process_summary
      ( p_cycle_count_header_id    => p_cycle_count_header_id
      , p_organization_id          => p_organization_id
      , p_subinventory             => p_subinventory
      , p_locator_id               => p_locator_id
      , p_parent_lpn_id            => p_parent_lpn_id
      , p_unscheduled_count_entry  => p_unscheduled_count_entry
      , p_user_id                  => p_user_id
      );

    l_progress := 'delete_existing_cyc_count';


    -- Delete existing cyc count tasks.

    delete_existing_cyc_count
        (p_organization_id          => p_organization_id
        , p_subinventory             => p_subinventory
        , p_locator_id               => p_locator_id
        , p_inventory_item_id        => p_inventory_item_id);

    l_progress := 'After delete_existing_cyc_count';


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : l_progress is ' || l_progress);
          Mdebug(l_api_name||' : RAISE fnd_api.g_exc_error: ' || SQLERRM);
        END IF;
    WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          Mdebug(l_api_name||' : l_progress is ' || l_progress);
          Mdebug(l_api_name||' : RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        END IF;

  END process_summary;

END wms_opp_cyc_count;

/
