--------------------------------------------------------
--  DDL for Package Body WMS_TASK_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_LOAD" AS
  /* $Header: WMSLOADB.pls 120.20.12010000.25 2010/04/02 10:54:06 kjujjuru ship $ */

--  Global constants
  g_pkg_name                      CONSTANT VARCHAR2(30) := 'WMS_TASK_LOAD';
  l_g_ret_sts_error               CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_error;
  l_g_ret_sts_unexp_error         CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_unexp_error;
  l_g_ret_sts_success             CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_success;

  l_g_task_pending                CONSTANT NUMBER  := 1;
  l_g_task_queued                 CONSTANT NUMBER  := 2;
  l_g_task_dispatched             CONSTANT NUMBER  := 3;
  l_g_task_loaded                 CONSTANT NUMBER  := 4;
  l_g_task_active                 CONSTANT NUMBER  := 9;

  l_g_decimal_precision           CONSTANT NUMBER  := 5;
  l_g_exception_short             CONSTANT VARCHAR2(30):= 'SHORT';
  l_g_exception_over              CONSTANT VARCHAR2(30):= 'OVER';
  l_g_action_split                CONSTANT VARCHAR2(30):= 'SPLIT';
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
  l_g_action_load_single          CONSTANT VARCHAR2(80):= 'LOAD_SINGLE';
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
  l_g_action_load_multiple        CONSTANT VARCHAR2(80):= 'LOAD_MULTIPLE';
  l_g_isLotSubstitutionOK	  NUMBER  := 2; -- 1 = yes and 2 = no  /* Bug 9448490 Lot Substitution Project */

  g_debug                                  NUMBER  := 1;

  --/* Bug 9448490 Lot Substitution Project */ start
PROCEDURE proc_decrement_allocated_mtlts
              (p_temp_id			 IN	     NUMBER
              ,p_substitute_lots                  IN          VARCHAR2
              ,x_return_status                   OUT NOCOPY  VARCHAR2);

  --/* Bug 9448490 Lot Substitution Project */ end

-- Forward declarations
PROCEDURE proc_insert_update_task
              (p_action                          IN            VARCHAR2
              ,p_insert                          IN            VARCHAR2
              ,p_update                          IN            VARCHAR2
              ,p_temp_id                         IN            NUMBER
              ,p_new_temp_id                     IN            NUMBER
              ,p_merge_temp_id                   IN            NUMBER
              ,p_task_status                     IN            NUMBER
              ,p_user_id                         IN            NUMBER
              ,x_return_status                   OUT NOCOPY    VARCHAR2
              ,x_msg_count                       OUT NOCOPY    NUMBER
              ,x_msg_data                        OUT NOCOPY    VARCHAR2);

PROCEDURE proc_insert_update_mmtt
              (p_action                          IN            VARCHAR2
              ,p_insert                          IN            VARCHAR2
              ,p_update                          IN            VARCHAR2
              ,p_organization_id                 IN            NUMBER
              ,p_user_id                         IN            NUMBER
              ,p_transaction_header_id           IN            NUMBER
              ,p_transaction_temp_id             IN            NUMBER
              ,p_transaction_temp_id_to_merge    IN            NUMBER
              ,p_lpn_id                          IN            NUMBER
              ,p_content_lpn_id                  IN            NUMBER
              ,p_transfer_lpn_id                 IN            NUMBER
              ,p_confirmed_sub                   IN            VARCHAR2
              ,p_confirmed_locator_id            IN            NUMBER
              ,p_confirmed_uom                   IN            VARCHAR2
              ,p_suggested_uom                   IN            VARCHAR2
              ,p_primary_uom                     IN            VARCHAR2
              ,p_inventory_item_id               IN            NUMBER
              ,p_revision                        IN            VARCHAR2
              ,p_confirmed_trx_qty               IN            NUMBER
              ,p_confirmed_lots                  IN            VARCHAR2
              ,p_confirmed_lot_trx_qty           IN            VARCHAR2
              ,p_confirmed_sec_uom               IN            VARCHAR2
              ,p_confirmed_sec_qty               IN            VARCHAR2
              ,p_confirmed_serials               IN            VARCHAR2
              ,p_container_item_id               IN            NUMBER
              ,p_wms_task_status                 IN            NUMBER
              ,p_lpn_match                       IN            NUMBER
              ,p_lpn_match_lpn_id                IN            NUMBER
              ,p_serial_allocated_flag           IN            VARCHAR2
              ,p_lot_controlled                  IN            VARCHAR2  -- Y/N
              ,p_serial_controlled               IN            VARCHAR2  -- Y/N
              ,p_exception                       IN            VARCHAR2  -- OVER/SHORT
              ,p_parent_lpn_id                   IN            NUMBER
              ,x_new_transaction_temp_id         OUT NOCOPY    NUMBER
              ,x_return_status                   OUT NOCOPY    VARCHAR2
              ,x_msg_count                       OUT NOCOPY    NUMBER
              ,x_msg_data                        OUT NOCOPY    VARCHAR2
	      ,p_substitute_lots		 IN	       VARCHAR2); --/* Bug 9448490 Lot Substitution Project */

PROCEDURE proc_process_confirmed_lots
             ( p_action                          IN            VARCHAR2
              ,p_insert                          IN            VARCHAR2
              ,p_update                          IN            VARCHAR2
              ,p_organization_id                 IN            NUMBER
              ,p_user_id                         IN            NUMBER
              ,p_transaction_header_id           IN            NUMBER
              ,p_transaction_temp_id             IN            NUMBER
              ,p_new_transaction_temp_id         IN            NUMBER
              ,p_transaction_temp_id_to_merge    IN            NUMBER
              ,p_inventory_item_id               IN            NUMBER
              ,p_revision                        IN            VARCHAR2
              ,p_suggested_uom                   IN            VARCHAR2
              ,p_confirmed_uom                   IN            VARCHAR2
              ,p_primary_uom                     IN            VARCHAR2
              ,p_confirmed_lots                  IN            VARCHAR2
              ,p_confirmed_lot_trx_qty           IN            VARCHAR2
              ,p_confirmed_serials               IN            VARCHAR2
              ,p_serial_allocated_flag           IN            VARCHAR2
              ,p_lpn_match                       IN            NUMBER
              ,p_lpn_match_lpn_id                IN            NUMBER
              ,p_confirmed_sec_uom               IN            VARCHAR2
              ,p_confirmed_sec_qty               IN            VARCHAR2
              ,p_lot_controlled                  IN            VARCHAR2  -- Y/N
              ,p_serial_controlled               IN            VARCHAR2  -- Y/N
              ,p_exception                       IN            VARCHAR2  -- OVER/SHORT
              ,x_return_status                   OUT NOCOPY    VARCHAR2
              ,x_msg_count                       OUT NOCOPY    NUMBER
              ,x_msg_data                        OUT NOCOPY    VARCHAR2
	      ,p_substitute_lots		 IN	       VARCHAR2); --/* Bug 9448490 Lot Substitution Project */

PROCEDURE proc_process_confirmed_serials
             ( p_action                          IN            VARCHAR2
              ,p_insert                          IN            VARCHAR2
              ,p_update                          IN            VARCHAR2
              ,p_organization_id                 IN            NUMBER
              ,p_user_id                         IN            NUMBER
              ,p_transaction_header_id           IN            NUMBER
              ,p_transaction_temp_id             IN            NUMBER
              ,p_new_transaction_temp_id         IN            NUMBER
              ,p_transaction_temp_id_to_merge    IN            NUMBER
              ,p_serial_transaction_temp_id      IN            NUMBER
              ,p_mtlt_serial_temp_id             IN            NUMBER
              ,p_inventory_item_id               IN            NUMBER
              ,p_revision                        IN            VARCHAR2
              ,p_suggested_uom                   IN            VARCHAR2
              ,p_confirmed_uom                   IN            VARCHAR2
              ,p_primary_uom                     IN            VARCHAR2
              ,p_serial_lot_number               IN            VARCHAR2
              ,p_confirmed_serials               IN            VARCHAR2
              ,p_serial_allocated_flag           IN            VARCHAR2
              ,p_lpn_match                       IN            NUMBER
              ,p_lpn_match_lpn_id                IN            NUMBER
              ,p_lot_controlled                  IN            VARCHAR2  -- Y/N
              ,p_serial_controlled               IN            VARCHAR2  -- Y/N
              ,x_return_status                   OUT NOCOPY    VARCHAR2
              ,x_msg_count                       OUT NOCOPY    NUMBER
              ,x_msg_data                        OUT NOCOPY    VARCHAR2);

PROCEDURE proc_insert_mtlt
              (p_lot_record                      IN      mtl_transaction_lots_temp%ROWTYPE
              ,x_return_status                   OUT NOCOPY    VARCHAR2
              ,x_msg_count                       OUT NOCOPY    NUMBER
              ,x_msg_data                        OUT NOCOPY    VARCHAR2);

PROCEDURE proc_insert_msnt
              (p_transaction_temp_id             IN          NUMBER
              ,p_organization_id                 IN          NUMBER
              ,p_inventory_item_id               IN          NUMBER
              ,p_revision                        IN          VARCHAR2
              ,p_confirmed_serials               IN          VARCHAR2
              ,p_serial_number                   IN          VARCHAR2
              ,p_lpn_id                          IN          NUMBER
              ,p_serial_lot_number               IN          VARCHAR2
              ,p_user_id                         IN          NUMBER
              ,x_return_status                   OUT NOCOPY  VARCHAR2
              ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2);

PROCEDURE proc_mark_msn
              (p_group_mark_id                   IN          NUMBER
              ,p_organization_id                 IN          NUMBER
              ,p_inventory_item_id               IN          NUMBER
              ,p_Revision                        IN          VARCHAR2
              ,p_confirmed_serials               IN          VARCHAR2
              ,p_serial_lot_number               IN          VARCHAR2
              ,p_serial_number                   IN          VARCHAR2
              ,p_lpn_id                          IN          NUMBER
              ,p_user_id                         IN          NUMBER
              ,x_return_status                   OUT NOCOPY  VARCHAR2
              ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2);

PROCEDURE  proc_device_call
              (p_action                          IN          VARCHAR2
              ,p_employee_id                     IN          NUMBER
              ,p_transaction_temp_id             IN          NUMBER
              ,x_return_status                   OUT NOCOPY  VARCHAR2
              ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2 );

PROCEDURE  proc_process_cancelled_MOLs
              (p_organization_id                 IN           NUMBER
              ,p_user_id                         IN           NUMBER
              ,p_transaction_header_id           IN           NUMBER
              ,p_transaction_temp_id             IN           NUMBER
              ,x_return_status                   OUT NOCOPY   VARCHAR2
              ,x_msg_count                       OUT NOCOPY   NUMBER
              ,x_msg_data                        OUT NOCOPY   VARCHAR2);

PROCEDURE proc_parse_lot_serial_catchwt
              (p_inventory_item_id               IN          NUMBER
              ,p_confirmed_lots                  IN          VARCHAR2
              ,p_confirmed_lot_trx_qty           IN          VARCHAR2
              ,p_confirmed_serials               IN          VARCHAR2
              ,p_suggested_uom                   IN          VARCHAR2
              ,p_confirmed_uom                   IN          VARCHAR2
              ,p_primary_uom                     IN          VARCHAR2
              ,p_confirmed_sec_uom               IN          VARCHAR2
              ,p_confirmed_sec_qty               IN          VARCHAR2
              ,x_return_status                   OUT NOCOPY  VARCHAR2
              ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2);

PROCEDURE  proc_reset_lpn_context(
               p_organization_id                 IN          NUMBER
              ,p_user_id                         IN          NUMBER
              ,p_transaction_header_id           IN          NUMBER
              ,p_transaction_temp_id             IN          NUMBER
              ,x_return_status                   OUT NOCOPY  VARCHAR2
              ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2);

PROCEDURE  proc_reset_task_status(
               p_action                          IN          VARCHAR2
              ,p_organization_id                 IN          NUMBER
              ,p_user_id                         IN          NUMBER
              ,p_employee_id                     IN          NUMBER
              ,p_transaction_header_id           IN          NUMBER
              ,p_transaction_temp_id             IN          NUMBER
              ,x_return_status                   OUT NOCOPY  VARCHAR2
              ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2);
--viks start_over
PROCEDURE proc_start_over
                (p_transaction_header_id     IN NUMBER
                     ,p_transaction_temp_id  IN NUMBER
                     ,p_user_id              IN NUMBER
                     ,x_start_over_taskno   OUT NOCOPY NUMBER
                     ,x_return_status       OUT NOCOPY VARCHAR2
                     ,x_msg_count           OUT NOCOPY NUMBER
                     ,x_msg_data            OUT NOCOPY VARCHAR2 );



procedure validate_loaded_lpn_cg
      ( p_organization_id       IN  NUMBER,
        p_inventory_item_id     IN  NUMBER,
        p_subinventory_code     IN  VARCHAR2,
        p_locator_id            IN  NUMBER,
        p_revision              IN  VARCHAR2,
        p_lot_number            IN  VARCHAR2,
        p_lpn_id                IN  NUMBER,
        p_transfer_lpn_id       IN  NUMBER,
        p_lot_control           IN  NUMBER,
        p_revision_control      IN  NUMBER,
        x_commingle_exist       OUT NOCOPY VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        p_trx_type_id           IN  VARCHAR2, -- Bug 4632519
        p_trx_action_id         IN  VARCHAR2); -- Bug 4632519

--/* Bug 9448490 Lot Substitution Project */ start
PROCEDURE insert_mtlt (
        p_new_temp_id     IN  NUMBER
      , p_serial_temp_id  IN  NUMBER := NULL
      , p_pri_att_qty     IN  NUMBER
      , p_trx_att_qty     IN  NUMBER
      , p_lot_number      IN  VARCHAR2
      , p_item_id         IN  NUMBER
      , p_organization_id IN  NUMBER
      ,x_return_status    OUT NOCOPY    VARCHAR2) ;

--/* Bug 9448490 Lot Substitution Project */ end
PROCEDURE mydebug( p_msg        IN        VARCHAR2)
IS
BEGIN
   IF (g_debug = 1) THEN
      inv_mobile_helper_functions.tracelog(
                             p_err_msg => p_msg,
                             p_module  => g_pkg_name ,
                             p_level   => 9);

   END IF;
  --    dbms_output.put_line( p_msg );
END mydebug;

PROCEDURE mydebug(p_message IN VARCHAR2, p_module IN VARCHAR2)
IS
BEGIN
   IF (g_debug = 1) THEN
    inv_log_util.trace(p_message, p_module, 9);
   END IF;
END mydebug;

PROCEDURE update_loaded_part
  (p_user_id                   IN            NUMBER,
   p_transaction_temp_id1      IN            NUMBER,
   p_transaction_temp_id2      IN            NUMBER,
   p_transfer_lpn_id           IN            NUMBER,
   p_transaction_uom           IN            VARCHAR2,
   p_transaction_quantity      IN            NUMBER,
   p_lot_numbers               IN            VARCHAR2,
   p_lot_transaction_quantity  IN            VARCHAR2,
   p_secondary_uom             IN            VARCHAR2,
   p_secondary_quantity        IN            VARCHAR2,
   p_serial_numbers            IN            VARCHAR2,
   p_serial_allocated_flag     IN            VARCHAR2,  -- Y/N
   p_lot_controlled            IN            VARCHAR2,  -- Y/N
   p_serial_controlled         IN            VARCHAR2,  -- Y/N
   x_return_status             OUT NOCOPY    VARCHAR2,
   x_msg_count                 OUT NOCOPY    NUMBER,
   x_msg_data                  OUT NOCOPY    VARCHAR2)
  IS
     l_serial_transaction_temp_id      NUMBER;
     l_inventory_item_id               NUMBER;
     l_primary_uom                     VARCHAR2(3);
     l_primary_quantity                NUMBER;
     l_primary_quantity1               NUMBER;

   l_secondary_uom                   VARCHAR2(3);
     l_secondary_quantity              NUMBER;
     l_secondary_quantity1             NUMBER;

     l_delta_primary_quantity          NUMBER;

   l_delta_secondary_quantity        NUMBER;

     l_transaction_uom1                VARCHAR2(3);
     l_transaction_uom2                VARCHAR2(3);
     l_conversion_factor               NUMBER;
     l_conversion_factor1              NUMBER;
     l_conversion_factor2              NUMBER;
     l_mtlt_rec                        mtl_transaction_lots_temp%ROWTYPE;
     l_row_exists                      NUMBER;
     i                                 NUMBER;
     j                                 NUMBER;
     l_debug                           NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_lpn_id                          NUMBER;

     TYPE lot_record_type IS RECORD
       (lot_number                     mtl_serial_numbers.lot_number%TYPE,
        primary_quantity               NUMBER,
        delta_primary_quantity         NUMBER,
        secondary_quantity             NUMBER,
    delta_secondary_quantity       NUMBER,
        secondary_uom                  mtl_material_transactions_temp.secondary_uom_code%TYPE,
        serial_transaction_temp_id     NUMBER,
        update_mtlt                    BOOLEAN,
        delete_mtlt                    BOOLEAN);

     TYPE serial_record_type IS RECORD
       (serial_number                  mtl_serial_numbers.serial_number%TYPE,
        lot_number                     mtl_serial_numbers.lot_number%TYPE,
        transaction_temp_id            NUMBER,
        delete_msnt                    BOOLEAN);

     TYPE lot_table_type IS TABLE OF lot_record_type INDEX BY BINARY_INTEGER;
     TYPE serial_table_type IS TABLE OF serial_record_type INDEX BY BINARY_INTEGER;

     l_lot_table1                      lot_table_type;
     l_serial_table1                   serial_table_type;

     CURSOR mmtt_cursor(v_transaction_temp_id1 NUMBER, v_transaction_temp_id2 NUMBER) IS
        SELECT inventory_item_id, transaction_temp_id, primary_quantity
     , item_primary_uom_code, transaction_quantity, transaction_uom
     , secondary_transaction_quantity, secondary_uom_code
          FROM mtl_material_transactions_temp
          WHERE transaction_temp_id IN (v_transaction_temp_id1, v_transaction_temp_id2)
          FOR UPDATE;

     CURSOR mtlt_cursor(v_transaction_temp_id NUMBER) IS
        SELECT lot_number, primary_quantity, transaction_quantity, secondary_quantity
            , serial_transaction_temp_id
          FROM mtl_transaction_lots_temp
          WHERE transaction_temp_id = v_transaction_temp_id
          ORDER BY lot_number
          FOR UPDATE;

     CURSOR msnt_cursor(v_transaction_temp_id NUMBER) IS
        SELECT fm_serial_number
          FROM mtl_serial_numbers_temp
          WHERE transaction_temp_id = v_transaction_temp_id
          ORDER BY fm_serial_number
          FOR UPDATE;

     CURSOR confirmed_lot_serial_cursor IS
        SELECT
          transaction_temp_id,
          lot_number,
          serial_number,
          SUM(transaction_quantity) transaction_quantity,
          SUM(primary_quantity) primary_quantity,
          SUM(secondary_quantity) secondary_quantity
        FROM mtl_allocations_gtmp
        WHERE (lot_number IS NOT NULL OR serial_number IS NOT NULL)
        GROUP BY transaction_temp_id, lot_number, serial_number, secondary_quantity
        ORDER BY transaction_temp_id, lot_number, serial_number;

BEGIN

   x_return_status  := l_g_ret_sts_success;
   IF (l_debug = 1) THEN
      mydebug('Inside UPDATE_LOADED_PART', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
   END IF;

   FOR mmtt_rec IN mmtt_cursor(p_transaction_temp_id1, p_transaction_temp_id2) LOOP
      IF mmtt_rec.transaction_temp_id = p_transaction_temp_id1 THEN
         l_transaction_uom1 := mmtt_rec.transaction_uom;
         l_conversion_factor1 := mmtt_rec.transaction_quantity/mmtt_rec.primary_quantity;
         l_primary_quantity1 := mmtt_rec.primary_quantity;
   l_secondary_quantity1 := mmtt_rec.secondary_transaction_quantity;
       ELSE
         l_transaction_uom2 := mmtt_rec.transaction_uom;
         l_conversion_factor2 := mmtt_rec.transaction_quantity/mmtt_rec.primary_quantity;
      END IF;

      l_inventory_item_id := mmtt_rec.inventory_item_id;
      l_primary_uom := mmtt_rec.item_primary_uom_code;
  l_secondary_uom := mmtt_rec.secondary_uom_code;
   END LOOP;

   IF p_transaction_uom = l_transaction_uom1 THEN
      l_conversion_factor := l_conversion_factor1;
    ELSE
      l_conversion_factor := inv_convert.inv_um_convert(item_id        => l_inventory_item_id,
                                                        precision      => l_g_decimal_precision,
                                                        from_quantity  => 1,
                                                        from_unit      => l_primary_uom,
                                                        to_unit        => p_transaction_uom,
                                                        from_name      => NULL,
                                                        to_name        => NULL);
   END IF;

   IF (l_debug = 1) THEN
      mydebug('Conversion Factor: ' || l_conversion_factor, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
      mydebug('Conversion Factor1: ' || l_conversion_factor1, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
      mydebug('Conversion Factor2: ' || l_conversion_factor2, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
   END IF;

   IF p_lot_controlled <> 'Y' AND p_serial_controlled <> 'Y' THEN -- No Lot or serial control
         fnd_message.set_token('ROUTINE', '- proc_insert_update_task' );
         fnd_msg_pub.ADD;
      l_primary_quantity := Round(p_transaction_quantity/l_conversion_factor, l_g_decimal_precision);
      l_secondary_quantity := p_secondary_quantity;
    ELSE
      proc_parse_lot_serial_catchwt
        (p_inventory_item_id        => l_inventory_item_id,
         p_confirmed_lots           => p_lot_numbers,
         p_confirmed_lot_trx_qty    => p_lot_transaction_quantity,
         p_confirmed_serials        => p_serial_numbers,
         p_suggested_uom            => l_transaction_uom1,
         p_confirmed_uom            => p_transaction_uom,
         p_primary_uom              => l_primary_uom    ,
         p_confirmed_sec_uom        => p_secondary_uom,
         p_confirmed_sec_qty        => p_secondary_quantity,
         x_return_status            => x_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data);

      IF (l_debug = 1) THEN
         mydebug('Return Status from Lot Serial Parse: ' || x_return_status, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
      END IF;

      IF x_return_status <> l_g_ret_sts_success
        THEN
           fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR'); --NEWMSG
           -- Internal Error $ROUTINE
           fnd_message.set_token('ROUTINE', ' - proc_parse_lot_serial_catchwt API ' );
           mydebug('Error parsing lot/serial/catch weight string' );
           -- "Error reserving Serial Number/s"
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
      END IF;

      IF p_lot_controlled = 'Y' AND p_serial_controlled <> 'Y' THEN -- Lot Controlled only
         IF (l_debug = 1) THEN
            mydebug('Loaded...', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
         END IF;

         i := 1; -- lot table counter
         FOR mtlt_record IN mtlt_cursor(p_transaction_temp_id1) LOOP

            IF (l_debug = 1) THEN
               mydebug(i || ' Lot Number: ' || mtlt_record.lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
            END IF;

            l_lot_table1(i).lot_number := mtlt_record.lot_number;
            l_lot_table1(i).primary_quantity := mtlt_record.primary_quantity;
    l_lot_table1(i).secondary_quantity := mtlt_record.secondary_quantity;

            i := i + 1;
         END LOOP;

         IF (l_debug = 1) THEN
            mydebug('Confirmed...', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
         END IF;

         i := 1; -- lot table counter
         l_primary_quantity := 0;
   l_secondary_quantity := 0;
         FOR lot_serial_rec IN confirmed_lot_serial_cursor LOOP

            l_primary_quantity := l_primary_quantity + lot_serial_rec.primary_quantity;
    l_secondary_quantity := l_secondary_quantity + lot_serial_rec.secondary_quantity;

            WHILE l_lot_table1(i).lot_number <> lot_serial_rec.lot_number LOOP
               IF (l_debug = 1) THEN
                  mydebug(i || 'Marking Lot Number: ' || l_lot_table1(i).lot_number || ' to be deleted', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
               END IF;
               l_lot_table1(i).delete_mtlt := TRUE;
               l_lot_table1(i).delta_primary_quantity := l_lot_table1(i).primary_quantity;
     l_lot_table1(i).delta_secondary_quantity := l_lot_table1(i).secondary_quantity;
               i := i + 1;
            END LOOP;

            IF (l_debug = 1) THEN
               mydebug(i || ' Lot Number: ' || l_lot_table1(i).lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
            END IF;

            IF l_lot_table1(i).lot_number = lot_serial_rec.lot_number THEN
               l_lot_table1(i).secondary_quantity := lot_serial_rec.secondary_quantity;

               IF l_lot_table1(i).primary_quantity <> lot_serial_rec.primary_quantity THEN

                  IF (l_debug = 1) THEN
                     mydebug(i || 'Marking Lot Number: ' || l_lot_table1(i).lot_number || ' to be updated', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;

                  l_lot_table1(i).update_mtlt := TRUE;

                  l_lot_table1(i).delta_primary_quantity := l_lot_table1(i).primary_quantity - lot_serial_rec.primary_quantity;
                  l_lot_table1(i).primary_quantity := lot_serial_rec.primary_quantity;
      l_lot_table1(i).delta_secondary_quantity := l_lot_table1(i).secondary_quantity - lot_serial_rec.secondary_quantity;
      l_lot_table1(i).secondary_quantity := lot_serial_rec.secondary_quantity;

               END IF;
            END IF;

            i := i + 1;
         END LOOP;

         WHILE i <= l_lot_table1.COUNT LOOP
            l_lot_table1(i).delete_mtlt := TRUE;
            l_lot_table1(i).delta_primary_quantity := l_lot_table1(i).primary_quantity;
    l_lot_table1(i).delta_secondary_quantity := l_lot_table1(i).secondary_quantity;
            i := i + 1;
         END LOOP;

         FOR i IN 1..l_lot_table1.COUNT LOOP

            BEGIN
               SELECT serial_transaction_temp_id
                 INTO l_serial_transaction_temp_id
                 FROM mtl_transaction_lots_temp
                 WHERE transaction_temp_id = p_transaction_temp_id2
                 AND lot_number = l_lot_table1(i).lot_number;

               l_row_exists := 1;
            EXCEPTION
               WHEN no_data_found THEN
                  l_row_exists := 0;
            END;

            IF (l_debug = 1) THEN
               IF l_row_exists = 1 THEN
                  mydebug(i || 'Lot Number: ' || l_lot_table1(i).lot_number || ' exists in remaining', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                ELSE
                  mydebug(i || 'Lot Number: ' || l_lot_table1(i).lot_number || ' does not exist in remaining', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
               END IF;
            END IF;


            IF (l_debug = 1) THEN
               mydebug(i || 'Delta: ' || l_lot_table1(i).delta_primary_quantity, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
     mydebug(i || 'Sec Delta: ' || l_lot_table1(i).delta_secondary_quantity, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
            END IF;

            IF l_lot_table1(i).delete_mtlt THEN

               IF l_row_exists = 1 THEN

                  IF (l_debug = 1) THEN
                     mydebug(i || 'Deleting Lot Number: ' || l_lot_table1(i).lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;

                  UPDATE mtl_transaction_lots_temp
                    SET primary_quantity = primary_quantity + l_lot_table1(i).delta_primary_quantity,
                        transaction_quantity = transaction_quantity +
                                               Round(l_lot_table1(i).delta_primary_quantity * l_conversion_factor2,
                                                     l_g_decimal_precision),
        secondary_quantity = secondary_quantity + l_lot_table1(i).delta_secondary_quantity,
                        last_update_date     = Sysdate,
                        last_updated_by      = p_user_id
                    WHERE transaction_temp_id = p_transaction_temp_id2
                    AND lot_number = l_lot_table1(i).lot_number;

                  DELETE FROM mtl_transaction_lots_temp
                    WHERE transaction_temp_id = p_transaction_temp_id1
                    AND lot_number = l_lot_table1(i).lot_number;

                ELSE -- row does not exist in 2

                  IF (l_debug = 1) THEN
                     mydebug(i || 'Transferring Lot Number: ' || l_lot_table1(i).lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;

                  UPDATE mtl_transaction_lots_temp
                    SET transaction_temp_id        = p_transaction_temp_id2,
                        transaction_quantity       = Round(primary_quantity * l_conversion_factor2, l_g_decimal_precision),
                        last_update_date     = Sysdate,
                        last_updated_by      = p_user_id
                    WHERE transaction_temp_id = p_transaction_temp_id1
                    AND lot_number = l_lot_table1(i).lot_number;

               END IF;

             ELSIF l_lot_table1(i).update_mtlt THEN

               UPDATE mtl_transaction_lots_temp
                 SET primary_quantity     = l_lot_table1(i).primary_quantity,
                     transaction_quantity = Round(l_lot_table1(i).primary_quantity * l_conversion_factor, l_g_decimal_precision),
                     secondary_quantity   = l_lot_table1(i).secondary_quantity,
                     last_update_date     = Sysdate,
                     last_updated_by      = p_user_id
                 WHERE transaction_temp_id = p_transaction_temp_id1
                 AND lot_number = l_lot_table1(i).lot_number;

               IF l_row_exists = 1 THEN

                  IF (l_debug = 1) THEN
                     mydebug(i || 'Updating Lot Number: ' || l_lot_table1(i).lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;

                  UPDATE mtl_transaction_lots_temp
                    SET primary_quantity     = primary_quantity + l_lot_table1(i).delta_primary_quantity,
                        transaction_quantity = transaction_quantity + Round(l_lot_table1(i).delta_primary_quantity * l_conversion_factor2,
                                                                            l_g_decimal_precision),
        secondary_quantity     = secondary_quantity + l_lot_table1(i).delta_secondary_quantity,
                        last_update_date     = Sysdate,
                        last_updated_by      = p_user_id
                    WHERE transaction_temp_id = p_transaction_temp_id2
                    AND lot_number = l_lot_table1(i).lot_number;
                ELSE -- row does not exist in 2

                  IF (l_debug = 1) THEN
                     mydebug(i || 'Inserting Lot Number: ' || l_lot_table1(i).lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;

                  SELECT *
                    INTO l_mtlt_rec
                    FROM mtl_transaction_lots_temp
                    WHERE transaction_temp_id = p_transaction_temp_id1
                    AND lot_number = l_lot_table1(i).lot_number;

                  l_mtlt_rec.transaction_temp_id        := p_transaction_temp_id2;
                  l_mtlt_rec.transaction_quantity       := Round(l_mtlt_rec.primary_quantity * l_conversion_factor2, l_g_decimal_precision);

                  proc_insert_mtlt
                   (p_lot_record         => l_mtlt_rec,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data);

                  mydebug('x_return_status : ' || x_return_status);
                  IF x_return_status <> l_g_ret_sts_success THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;

               END IF; -- row exists

            END IF; -- delete/update mtlt

         END LOOP; -- lot loop
       ELSIF p_lot_controlled <> 'Y' AND p_serial_controlled = 'Y' THEN -- Serial controlled only

         IF (l_debug = 1) THEN
            mydebug('Loaded...', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
         END IF;

         l_secondary_quantity := p_secondary_quantity;

         j := 1; -- serial table counter
         FOR msnt_record IN msnt_cursor(p_transaction_temp_id1) LOOP
            IF (l_debug = 1) THEN
               mydebug(j || ' Serial Number: ' || msnt_record.fm_serial_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
            END IF;

            l_serial_table1(j).serial_number := msnt_record.fm_serial_number;
            j := j + 1;
         END LOOP;

         IF (l_debug = 1) THEN
            mydebug('Confirmed...', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
         END IF;

         j := 1; -- serial table counter
         l_primary_quantity := 0;
         FOR lot_serial_rec IN confirmed_lot_serial_cursor LOOP

            l_primary_quantity := l_primary_quantity + 1;

            WHILE l_serial_table1(j).serial_number <> lot_serial_rec.serial_number LOOP
               l_serial_table1(j).delete_msnt := TRUE;
               j := j + 1;
            END LOOP;

            IF (l_debug = 1) THEN
               mydebug(j || ' Serial Number: ' || l_serial_table1(j).serial_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
            END IF;

            j := j + 1;
         END LOOP;


         WHILE j <= l_serial_table1.COUNT LOOP
            l_serial_table1(j).delete_msnt := TRUE;
            j := j + 1;
         END LOOP;

         j := 1;

         WHILE  j <= l_serial_table1.COUNT LOOP

            IF l_serial_table1(j).delete_msnt THEN

               IF p_serial_allocated_flag = 'Y' THEN

                  IF (l_debug = 1) THEN
                     mydebug(j || 'Transferring Serial Number: ' || l_serial_table1(j).serial_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;

                  UPDATE mtl_serial_numbers_temp
                    SET transaction_temp_id = p_transaction_temp_id2,
                        last_update_date    = Sysdate,
                        last_updated_by     = p_user_id
                    WHERE transaction_temp_id = p_transaction_temp_id1
                    AND fm_serial_number = l_serial_table1(j).serial_number;
                ELSE

                  IF (l_debug = 1) THEN
                     mydebug(j || 'Deleting Serial Number: ' || l_serial_table1(j).serial_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;

                  DELETE FROM mtl_serial_numbers_temp
                    WHERE transaction_temp_id = p_transaction_temp_id1
                    AND fm_serial_number = l_serial_table1(j).serial_number;

                  -- unmark serial
                  UPDATE mtl_serial_numbers
                    SET group_mark_id       = NULL,
                        last_update_date    = Sysdate,
                        last_updated_by     = p_user_id
                    WHERE serial_number = l_serial_table1(j).serial_number
                    AND inventory_item_id = l_inventory_item_id;

               END IF; -- serial allocated flag
            END IF;

            j := j + 1;
         END LOOP;

       ELSIF p_lot_controlled = 'Y' AND p_serial_controlled = 'Y' THEN -- Lot and serial controlled

         IF (l_debug = 1) THEN
            mydebug('Loaded...', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
         END IF;

         i := 1; -- lot table counter
         j := 1; -- serial table counter
         FOR mtlt_record IN mtlt_cursor(p_transaction_temp_id1) LOOP

            IF (l_debug = 1) THEN
               mydebug(i || ' Lot Number: ' || mtlt_record.lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
            END IF;

            l_lot_table1(i).lot_number := mtlt_record.lot_number;
            l_lot_table1(i).primary_quantity := mtlt_record.primary_quantity;

            FOR msnt_record IN msnt_cursor(mtlt_record.serial_transaction_temp_id) LOOP
               IF (l_debug = 1) THEN
                  mydebug(j || ' Serial Number: ' || msnt_record.fm_serial_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
               END IF;

               l_serial_table1(j).transaction_temp_id := mtlt_record.serial_transaction_temp_id;
               l_serial_table1(j).serial_number := msnt_record.fm_serial_number;
               l_serial_table1(j).lot_number := mtlt_record.lot_number;

               j := j + 1;
            END LOOP;

            i := i + 1;
         END LOOP;

         IF (l_debug = 1) THEN
            mydebug('Confirmed...', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
         END IF;

         i := 1; -- lot table counter
         j := 1; -- serial table counter
         l_primary_quantity := 0;
         FOR lot_serial_rec IN confirmed_lot_serial_cursor LOOP

            l_primary_quantity := l_primary_quantity + 1;

            IF (l_debug = 1) THEN
               mydebug(i || ' Lot Number: ' || l_lot_table1(i).lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
            END IF;

            IF l_lot_table1(i).lot_number = lot_serial_rec.lot_number THEN
               l_lot_table1(i).secondary_quantity := lot_serial_rec.secondary_quantity;
            END IF;

            WHILE l_serial_table1(j).serial_number <> lot_serial_rec.serial_number LOOP

               IF (l_debug = 1) THEN
                  mydebug(j || 'Marking Serial Number: ' || l_serial_table1(j).serial_number || ' to be deleted', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
               END IF;

               l_serial_table1(j).delete_msnt := TRUE;

               l_lot_table1(i).primary_quantity := l_lot_table1(i).primary_quantity - 1;
               l_lot_table1(i).delta_primary_quantity := Nvl(l_lot_table1(i).delta_primary_quantity, 0) + 1;
               l_lot_table1(i).update_mtlt := TRUE;

               IF l_lot_table1(i).primary_quantity = 0 THEN
                  l_lot_table1(i).delete_mtlt := TRUE;

                 IF (l_debug = 1) THEN
                    mydebug(i || 'Marking Lot Number: ' || l_lot_table1(i).lot_number || ' to be deleted', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                 END IF;

                ELSE

                 IF (l_debug = 1) THEN
                    mydebug(i || 'Marking Lot Number: ' || l_lot_table1(i).lot_number || ' to be updated', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                 END IF;

               END IF;

               j := j + 1;

               IF l_serial_table1.COUNT >= j THEN
                  IF l_serial_table1(j-1).lot_number = l_lot_table1(i).lot_number AND
                    l_serial_table1(j).lot_number <> l_lot_table1(i).lot_number THEN
                     i := i + 1;
                     mydebug('Incrementing i', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;
               END IF;

            END LOOP;

            IF (l_debug = 1) THEN
               mydebug(j || ' Serial Number: ' || l_serial_table1(j).serial_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
            END IF;

            j := j + 1;

         END LOOP;

         WHILE j <= l_serial_table1.COUNT LOOP

            IF (l_debug = 1) THEN
               mydebug(j || 'Marking Serial Number: ' || l_serial_table1(j).serial_number || ' to be deleted', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
            END IF;

            l_serial_table1(j).delete_msnt := TRUE;

            l_lot_table1(i).primary_quantity := l_lot_table1(i).primary_quantity - 1;
            l_lot_table1(i).delta_primary_quantity := Nvl(l_lot_table1(i).delta_primary_quantity, 0) + 1;
            l_lot_table1(i).update_mtlt := TRUE;

            IF l_lot_table1(i).primary_quantity = 0 THEN
               l_lot_table1(i).delete_mtlt := TRUE;

               IF (l_debug = 1) THEN
                  mydebug(i || 'Marking Lot Number: ' || l_lot_table1(i).lot_number || ' to be deleted', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
               END IF;

             ELSE

               IF (l_debug = 1) THEN
                  mydebug(i || 'Marking Lot Number: ' || l_lot_table1(i).lot_number || ' to be updated', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
               END IF;

            END IF;

            j := j + 1;

            IF l_serial_table1.COUNT >= j THEN
               IF l_serial_table1(j-1).lot_number = l_lot_table1(i).lot_number AND
                 l_serial_table1(j).lot_number <> l_lot_table1(i).lot_number THEN
                  i := i + 1;
                  mydebug('Incrementing i', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
               END IF;
            END IF;

         END LOOP;

         j := 1;
         FOR i IN 1..l_lot_table1.COUNT LOOP

            l_serial_transaction_temp_id := NULL;

            BEGIN
               SELECT serial_transaction_temp_id
                 INTO l_serial_transaction_temp_id
                 FROM mtl_transaction_lots_temp
                 WHERE transaction_temp_id = p_transaction_temp_id2
                 AND lot_number = l_lot_table1(i).lot_number;

               l_row_exists := 1;
            EXCEPTION
               WHEN no_data_found THEN
                  l_row_exists := 0;

                  IF p_serial_allocated_flag = 'Y' THEN
                     SELECT mtl_material_transactions_s.NEXTVAL
                       INTO l_serial_transaction_temp_id
                       FROM dual;
                  END IF;
            END;

            IF (l_debug = 1) THEN
               IF l_row_exists = 1 THEN
                  mydebug(i || 'Lot Number: ' || l_lot_table1(i).lot_number || ' exists in remaining', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                ELSE
                  mydebug(i || 'Lot Number: ' || l_lot_table1(i).lot_number || ' does not exist in remaining', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
               END IF;
            END IF;

            WHILE j <= l_serial_table1.COUNT AND l_serial_table1(j).lot_number = l_lot_table1(i).lot_number LOOP

               IF l_serial_table1(j).delete_msnt THEN

                  IF p_serial_allocated_flag = 'Y' THEN

                     IF (l_debug = 1) THEN
                        mydebug(j || 'Transferring Serial Number: ' || l_serial_table1(j).serial_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                     END IF;

                     UPDATE mtl_serial_numbers_temp
                       SET transaction_temp_id = l_serial_transaction_temp_id,
                           last_update_date    = Sysdate,
                           last_updated_by     = p_user_id
                       WHERE transaction_temp_id = l_serial_table1(j).transaction_temp_id
                       AND fm_serial_number = l_serial_table1(j).serial_number;
                   ELSE

                     IF (l_debug = 1) THEN
                        mydebug(j || 'Deleting Serial Number: ' || l_serial_table1(j).serial_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                     END IF;

                     DELETE FROM mtl_serial_numbers_temp
                       WHERE transaction_temp_id = l_serial_table1(j).transaction_temp_id
                       AND fm_serial_number = l_serial_table1(j).serial_number;

                     -- unmark serial
                     UPDATE mtl_serial_numbers
                       SET group_mark_id       = NULL,
                           last_update_date    = Sysdate,
                           last_updated_by     = p_user_id
                       WHERE serial_number = l_serial_table1(j).serial_number
                       AND inventory_item_id = l_inventory_item_id;

                  END IF; -- serial allocated flag
                ELSE
                  IF (l_debug = 1) THEN
                     mydebug(j || ' Serial Number: ' || l_serial_table1(j).serial_number || ' left untouched', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;
               END IF;

               j := j + 1;

            END LOOP;

            IF l_lot_table1(i).delete_mtlt THEN

               IF l_row_exists = 1 THEN

                  IF (l_debug = 1) THEN
                     mydebug(i || 'Deleting Lot Number: ' || l_lot_table1(i).lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;

                  UPDATE mtl_transaction_lots_temp
                    SET primary_quantity = primary_quantity + l_lot_table1(i).delta_primary_quantity,
                        transaction_quantity = transaction_quantity +
                                               Round(l_lot_table1(i).delta_primary_quantity * l_conversion_factor2,
                                                     l_g_decimal_precision),
                        last_update_date     = Sysdate,
                        last_updated_by      = p_user_id
                    WHERE transaction_temp_id = p_transaction_temp_id2
                    AND lot_number = l_lot_table1(i).lot_number;

                  DELETE FROM mtl_transaction_lots_temp
                    WHERE transaction_temp_id = p_transaction_temp_id1
                    AND lot_number = l_lot_table1(i).lot_number;

                ELSE -- row does not exist in 2

                  IF (l_debug = 1) THEN
                     mydebug(i || 'Transferring Lot Number: ' || l_lot_table1(i).lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;

                  UPDATE mtl_transaction_lots_temp
                    SET transaction_temp_id        = p_transaction_temp_id2,
                        serial_transaction_temp_id = l_serial_transaction_temp_id,
                        transaction_quantity       = Round(primary_quantity * l_conversion_factor2, l_g_decimal_precision),
                        last_update_date           = Sysdate,
                        last_updated_by            = p_user_id
                    WHERE transaction_temp_id = p_transaction_temp_id1
                    AND lot_number = l_lot_table1(i).lot_number;

               END IF;

             ELSIF l_lot_table1(i).update_mtlt THEN

               UPDATE mtl_transaction_lots_temp
                 SET primary_quantity     = l_lot_table1(i).primary_quantity,
                     transaction_quantity = Round(l_lot_table1(i).primary_quantity * l_conversion_factor, l_g_decimal_precision),
                     secondary_quantity   = l_lot_table1(i).secondary_quantity,
                     last_update_date     = Sysdate,
                     last_updated_by      = p_user_id
                 WHERE transaction_temp_id = p_transaction_temp_id1
                 AND lot_number = l_lot_table1(i).lot_number;

               IF l_row_exists = 1 THEN

                  IF (l_debug = 1) THEN
                     mydebug(i || 'Updating Lot Number: ' || l_lot_table1(i).lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;

                  UPDATE mtl_transaction_lots_temp
                    SET primary_quantity     = primary_quantity + l_lot_table1(i).delta_primary_quantity,
                        transaction_quantity = transaction_quantity + Round(l_lot_table1(i).delta_primary_quantity * l_conversion_factor2,
                                                                            l_g_decimal_precision),
                        last_update_date     = Sysdate,
                        last_updated_by      = p_user_id
                    WHERE transaction_temp_id = p_transaction_temp_id2
                    AND lot_number = l_lot_table1(i).lot_number;
                ELSE -- row does not exist in 2

                  IF (l_debug = 1) THEN
                     mydebug(i || 'Inserting Lot Number: ' || l_lot_table1(i).lot_number, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  END IF;

                  SELECT *
                    INTO l_mtlt_rec
                    FROM mtl_transaction_lots_temp
                    WHERE transaction_temp_id = p_transaction_temp_id1
                    AND lot_number = l_lot_table1(i).lot_number;

                  l_mtlt_rec.transaction_temp_id        := p_transaction_temp_id2;
                  l_mtlt_rec.serial_transaction_temp_id := l_serial_transaction_temp_id;
                  l_mtlt_rec.transaction_quantity       := Round(l_mtlt_rec.primary_quantity * l_conversion_factor2, l_g_decimal_precision);

                  proc_insert_mtlt
                   (p_lot_record         => l_mtlt_rec,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data);

                  mydebug('Return status from insert MTLT : ' || x_return_status, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
                  IF x_return_status <> l_g_ret_sts_success THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;

               END IF; -- row exists

            END IF; -- delete/update mtlt

         END LOOP; -- lot loop

      END IF; -- lot/serial/lot serial
   END IF; -- no control/lot/serial/lot serial

   -- Update MMTT records
   l_delta_primary_quantity := l_primary_quantity1 - l_primary_quantity;
 l_delta_secondary_quantity := l_secondary_quantity1 - l_secondary_quantity;

   IF (l_debug = 1) THEN
      mydebug('Updating MMTT with delta qty: ' || l_delta_primary_quantity, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
  mydebug('Updating MMTT with delta sec qty: ' || l_delta_secondary_quantity, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
   END IF;

   UPDATE mtl_material_transactions_temp
     SET transaction_quantity           = Round(l_primary_quantity*l_conversion_factor, l_g_decimal_precision),
         transaction_uom                = p_transaction_uom,
         primary_quantity               = l_primary_quantity,
         secondary_transaction_quantity = l_secondary_quantity,
         secondary_uom_code             = p_secondary_uom,
         lpn_id                         = content_lpn_id,
         content_lpn_id                 = NULL,
         transfer_lpn_id                = p_transfer_lpn_id,
         last_update_date               = Sysdate,
         last_updated_by                = p_user_id
     WHERE transaction_temp_id = p_transaction_temp_id1
     returning lpn_id INTO l_lpn_id;

   -- Bug5659809: update last_update_date and last_update_by as well
   UPDATE wms_license_plate_numbers
     SET lpn_context = 1
       --, last_update_date = SYSDATE /* Bug 9448490 Lot Substitution Project */
       --, last_updated_by = fnd_global.user_id /* Bug 9448490 Lot Substitution Project */
     WHERE lpn_id = l_lpn_id;

   -- Update remaining MMTT record
   UPDATE mtl_material_transactions_temp
     SET transaction_quantity = transaction_quantity +  Round(l_delta_primary_quantity*l_conversion_factor2, l_g_decimal_precision),
         primary_quantity     = primary_quantity + l_delta_primary_quantity,
   secondary_transaction_quantity = secondary_transaction_quantity+l_delta_secondary_quantity,
         last_update_date     = Sysdate,
         last_updated_by      = p_user_id
     WHERE transaction_temp_id = p_transaction_temp_id2;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := l_g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
         mydebug('Error', 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
      END IF;
      ROLLBACK;

   WHEN OTHERS THEN
      x_return_status  := l_g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF (l_debug = 1) THEN
         mydebug('Error: ' || Sqlerrm, 'WMS_TASK_LOAD.UPDATE_LOADED_PART');
      END IF;
      ROLLBACK ;
END update_loaded_part;

PROCEDURE task_merge_split(
               p_action                    IN            VARCHAR2  -- LOAD_MULTIPLE/LOAD_SINGLE/SPLIT/UPDATE_LOADED
              ,p_exception                 IN            VARCHAR2  -- SHORT/OVER
              ,p_organization_id           IN            NUMBER
              ,p_user_id                   IN            NUMBER
              ,p_transaction_header_id     IN            NUMBER
              ,p_transaction_temp_id       IN            NUMBER
              ,p_parent_line_id            IN            NUMBER
              ,p_remaining_temp_id         IN            NUMBER
              ,p_lpn_id                    IN            NUMBER
              ,p_content_lpn_id            IN            NUMBER
              ,p_transfer_lpn_id           IN            NUMBER
              ,p_confirmed_sub             IN            VARCHAR2
              ,p_confirmed_locator_id      IN            NUMBER
              ,p_confirmed_uom             IN            VARCHAR2
              ,p_suggested_uom             IN            VARCHAR2
              ,p_primary_uom               IN            VARCHAR2
              ,p_inventory_item_id         IN            NUMBER
              ,p_revision                  IN            VARCHAR2
              ,p_confirmed_trx_qty         IN            NUMBER
              ,p_confirmed_lots            IN            VARCHAR2
              ,p_confirmed_lot_trx_qty     IN            VARCHAR2
              ,p_confirmed_sec_uom         IN            VARCHAR2
              ,p_confirmed_sec_qty         IN            VARCHAR2
              ,p_confirmed_serials         IN            VARCHAR2
              ,p_container_item_id         IN            NUMBER
              ,p_lpn_match                 IN            NUMBER
              ,p_lpn_match_lpn_id          IN            NUMBER
              ,p_serial_allocated_flag     IN            VARCHAR2
              ,p_lot_controlled            IN            VARCHAR2  -- Y/N
              ,p_serial_controlled         IN            VARCHAR2  -- Y/N
              ,p_parent_lpn_id             IN            NUMBER
              ,x_new_transaction_temp_id   OUT NOCOPY    NUMBER
              ,x_cms_check                 OUT NOCOPY    VARCHAR2  -- FAIL/PASS
              ,x_return_status             OUT NOCOPY    VARCHAR2
              ,x_msg_count                 OUT NOCOPY    NUMBER
              ,x_msg_data                  OUT NOCOPY    VARCHAR2
	      ,p_substitute_lots	   IN	         VARCHAR2) --/* Bug 9448490 Lot Substitution Project */
IS
   --PRAGMA AUTONOMOUS_TRANSACTION;
   l_proc_name                      VARCHAR2(30) :=  'TASK_MERGE_SPLIT';
   l_debug                          NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress                       VARCHAR2(30) :=  '100';
   l_transaction_temp_id_to_merge   NUMBER       :=  NULL;
   l_new_transaction_temp_id        NUMBER       :=  NULL;
   l_insert                         VARCHAR2(2)  :=  NULL;
   l_update                         VARCHAR2(2)  :=  NULL;
   l_action                         VARCHAR2(30) :=  p_action;
   l_pick_ok                        VARCHAR2(1)  :=  'Y';

   l_lpn_id                NUMBER := p_lpn_id;
   l_content_lpn_id        NUMBER := p_content_lpn_id;
   l_parent_lpn_id         NUMBER := p_parent_lpn_id;
   l_transfer_lpn_id       NUMBER := p_transfer_lpn_id;
   l_container_item_id     NUMBER := p_container_item_id;
   l_lpn_match_lpn_id      NUMBER := p_lpn_match_lpn_id;

   l_lpn_context_pregenerated    CONSTANT NUMBER := WMS_Container_PUB.LPN_CONTEXT_PREGENERATED;
   l_lpn_context_inv             CONSTANT NUMBER := WMS_Container_PUB.LPN_CONTEXT_INV;
   l_lpn_context_picked          CONSTANT NUMBER := WMS_Container_PUB.LPN_CONTEXT_PICKED;
   l_lpn_context_packing         CONSTANT NUMBER := WMS_Container_PUB.LPN_CONTEXT_PACKING ;

   CURSOR  cur_split_mmtts
   IS
      SELECT transaction_temp_id
      FROM   mtl_material_transactions_temp
      WHERE  transaction_header_id  = p_transaction_header_id
      AND    transaction_temp_id   <> p_transaction_temp_id
      AND    inventory_item_id      = p_inventory_item_id
      AND    nvl(revision,'@@')     = nvl(p_revision,'@@')
      AND    subinventory_code      = p_confirmed_sub
      AND    locator_id             = p_confirmed_locator_id
      AND    transaction_uom        = p_confirmed_uom
      AND    transfer_lpn_id        = p_transfer_lpn_id
      AND    nvl(content_lpn_id,0)  = nvl(p_content_lpn_id,0)
      AND    nvl(lpn_id,0)          = nvl(p_lpn_id,0);

BEGIN

   --/*
   -- P_action can have foll. values  'LOAD_MULTIPLE' , 'LOAD_SINGLE' or 'SPLIT'
   -- newly genertated LPN is already in wms_lpn table when PichMore Is pressed
   -- if fromLpn = toLPN  -- FULLY COMSUMABLE
   --    from = content_lpn_id, to=transfer_lpn_id
   --    content_lpn_id is always nested into transafer_lpn_id
   --  else  from = lpn_id, to=transfer_lpn_id.
   -- l_insert    = 'Y'  means Yes, --insert new MMTT
   -- l_update    = 'Y1' means Yes But, 1 update , update original MMTT to reduce qty
   -- l_update    = 'Y2' means Yes but, 2 updates
   -- update original MMTT to reduce qty and
   -- update mergeable MMTT to add qty
   /*  MMTT management
   --   Action l_insert  L_update  update orginalMMTT  UpdMergeMMTT  InsertNewMMTT    WMS_TASK_STATUS CHANGE
   -----------------------------------------------------------------------------------------------
   --   SPLIT  Y         Y1        N                   N             Y                new MMTT inserted with loaded status
   --   SPLIT  N         Y2        Y                   Y             N                no change
   --   LOAD_M N         Y1        Y                   N             N                original MMTT updated to loaded status
   --   LOAD_M N         Y2        Y-Delete            Y             N                no change
   --   LOAD_S N         Y1        Y                   N             N                original MMTT updated to loaded status
   --*/

   x_return_status  := l_g_ret_sts_success;
   g_debug := l_debug;

   IF p_lpn_id = 0            THEN l_lpn_id := NULL;             END IF;
   IF p_content_lpn_id = 0    THEN l_content_lpn_id := NULL;     END IF;
   IF p_parent_lpn_id = 0     THEN l_parent_lpn_id := NULL;      END IF;
   IF p_transfer_lpn_id = 0   THEN l_transfer_lpn_id := NULL;    END IF;
   IF p_container_item_id = 0 THEN l_container_item_id := NULL;  END IF;
   IF p_lpn_match_lpn_id = 0  THEN l_lpn_match_lpn_id := NULL;   END IF;

   mydebug ('p_action                 = ' || p_action                 );
   mydebug ('p_exception              = ' || p_exception              );
   mydebug ('p_transaction_header_id  = ' || p_transaction_header_id  );
   mydebug ('p_transaction_temp_id    = ' || p_transaction_temp_id    );
   mydebug ('p_remaining_temp_id      = ' || p_remaining_temp_id    );
   mydebug ('p_parent_line_id         = ' || p_parent_line_id         );
   mydebug ('p_lpn_id                 = ' || p_lpn_id || ':' || l_lpn_id);
   mydebug ('p_content_lpn_id         = ' || p_content_lpn_id || ':' || l_content_lpn_id);
   mydebug ('p_parent_lpn_id         = ' || p_parent_lpn_id || ':' ||
                                                                     l_parent_lpn_id);
   mydebug ('p_transfer_lpn_id        = ' || p_transfer_lpn_id  || ':' || l_transfer_lpn_id);
   mydebug ('p_confirmed_sub          = ' || p_confirmed_sub          );
   mydebug ('p_confirmed_locator_id   = ' || p_confirmed_locator_id   );
   mydebug ('p_confirmed_uom          = ' || p_confirmed_uom          );
   mydebug ('p_suggested_uom          = ' || p_suggested_uom          );
   mydebug ('p_primary_uom            = ' || p_primary_uom            );
   mydebug ('p_inventory_item_id      = ' || p_inventory_item_id      );
   mydebug ('p_revision               = ' || p_revision               );
   mydebug ('p_confirmed_trx_qty      = ' || p_confirmed_trx_qty      );
   mydebug ('p_confirmed_lots         = ' || p_confirmed_lots         );
   mydebug ('p_confirmed_lot_trx_qty  = ' || p_confirmed_lot_trx_qty  );
   mydebug ('p_confirmed_sec_uom      = ' || p_confirmed_sec_uom      );
   mydebug ('p_confirmed_sec_qty      = ' || p_confirmed_sec_qty      );
   mydebug ('p_confirmed_serials      = ' || p_confirmed_serials      );
   mydebug ('p_serial_allocated_flag  = ' || p_serial_allocated_flag  );
   mydebug ('p_lpn_match              = ' || p_lpn_match              );
   mydebug ('p_lpn_match_lpn_id       = ' || p_lpn_match_lpn_id  || ':' || l_lpn_match_lpn_id);
   mydebug ('p_container_item_id      = ' || p_container_item_id || ':' || l_container_item_id);
   mydebug ('p_lot_controlled      = ' || p_lot_controlled );
   mydebug ('p_serial_controlled      = ' || p_serial_controlled );

   IF p_action = 'UPDATE_LOADED' THEN
      update_loaded_part
        (p_user_id                   => p_user_id,
         p_transaction_temp_id1      => p_transaction_temp_id,
         p_transaction_temp_id2      => p_remaining_temp_id,
         p_transfer_lpn_id           => l_transfer_lpn_id,
         p_transaction_uom           => p_confirmed_uom,
         p_transaction_quantity      => p_confirmed_trx_qty,
         p_lot_numbers               => p_confirmed_lots,
         p_lot_transaction_quantity  => p_confirmed_lot_trx_qty,
         p_secondary_uom             => p_confirmed_sec_uom,
         p_secondary_quantity        => p_confirmed_sec_qty,
         p_serial_numbers            => p_confirmed_serials,
         p_serial_allocated_flag     => p_serial_allocated_flag,
         p_lot_controlled            => p_lot_controlled,
         p_serial_controlled         => p_serial_controlled,
         x_return_status             => x_return_status,
         x_msg_count                 => x_msg_count,
         x_msg_data                  => x_msg_data);

      mydebug('x_return_status : ' || x_return_status);
      IF x_return_status <> l_g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

    ELSE
       l_progress    :=  '200';
       mydebug ('l_progress: ' || l_progress  || ' : Call Can_picdrop to check Move order line status' );
       x_cms_check := 'PASS';
       -- no need to do CMS check for BULK task
       IF p_transaction_temp_id <> p_parent_line_id THEN
          x_cms_check :=  can_pickdrop(p_transaction_temp_id );
          mydebug ('x_cms_check: ' || x_cms_check );
          IF  x_cms_check = 'FAIL'
          THEN
             --fnd_message.set_name('WMS', 'WMS_CANCELLED_SOURCE');
             -- Source of the task is cancelled by source.. F2 to rollback
             --fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
          END IF;
       END IF;


       /* Update the LPN context to "Packing context" (8).
       -- if p_lpn_match = 1,3 (exact match or fully consumable LPN) then
       -- p_lpn_match_lpn_id will be set to Packing context(8) otherwise , we will not
       -- change the context of from lpn .
       -- Always set the status of p_transfer_lpn_id = Packing context(8) , whether
       -- pre-generated or already in Packing context" */
       --
        l_progress    :=  '200';
        mydebug ('l_progress: ' || l_progress );
        mydebug ('Updating LPN context for: ' || l_lpn_match_lpn_id || ' And ' || l_transfer_lpn_id);
      IF p_lpn_match in (1,3) THEN -- fully consumable lpn or exact match
         IF l_lpn_id IS NULL  THEN -- lpn_id column of MMTT
            /*If we are transferring the contents of from lpn (ie. UI had Xfr LPN enabled
              instead of INTO LPN) then do not change the context of the LPN to packing.
              TM needs it to be 'resides in inv' to be able to unpack the material */
            BEGIN
             -- Bug5659809: update last_update_date and last_update_by as well
              UPDATE wms_license_plate_numbers
                SET lpn_context = l_lpn_context_packing
                 -- , last_update_date = SYSDATE /* Bug 9448490 Lot Substitution Project */
                 -- , last_updated_by = fnd_global.user_id /* Bug 9448490 Lot Substitution Project */
              WHERE lpn_id = l_lpn_match_lpn_id
                AND lpn_context = l_lpn_context_inv --, l_transfer_lpn_id)
                AND organization_id = p_organization_id;

              IF SQL%NOTFOUND THEN
                 mydebug ('Cannot find LPNs to update the context' );
                 fnd_message.set_name('WMS', 'WMS_WRONG_FROM_LPN_CONTEXT');
                 -- FROM LPN Context is not valid '
                 fnd_msg_pub.ADD;
                 RAISE fnd_api.g_exc_error;

              END IF;
             EXCEPTION
                 WHEN OTHERS THEN
                    mydebug ('Others exception while updating From LPN context: ' || SQLCODE);
                 RAISE fnd_api.g_exc_error;
             END ;
         END IF;
      END IF;
      l_progress    :=  '300';
      mydebug ('l_progress: ' || l_progress );
      /*If we are transferring the contents of from lpn (fully consumable) (ie. UI had Xfr LPN enabled
        instead of INTO LPN) then do not change the context of the LPN to packing.
        TM needs it to be 'resides in inv' to be able to unpack the material */
      IF (l_lpn_id IS NOT NULL  AND
          l_lpn_id <> l_transfer_lpn_id)
        OR
         (l_lpn_id IS NULL)
      THEN
         BEGIN

           -- Bug5659809: update last_update_date and last_update_by as well
           UPDATE wms_license_plate_numbers
             SET lpn_context = l_lpn_context_packing
               --, last_update_date = SYSDATE /* Bug 9448490 Lot Substitution Project */
               --, last_updated_by = fnd_global.user_id /* Bug 9448490 Lot Substitution Project */
           WHERE lpn_id = l_transfer_lpn_id
             AND lpn_context in (l_lpn_context_packing , l_lpn_context_pregenerated)
             AND organization_id = p_organization_id;

           IF SQL%NOTFOUND THEN
              mydebug ('Cannot find LPNs to update the context' );
              fnd_message.set_name('WMS', 'WMS_WRONG_TO_LPN_CONTEXT');
              -- To LPN Context is not valid
              fnd_msg_pub.ADD;

              RAISE fnd_api.g_exc_error;
           END IF;
          EXCEPTION
              WHEN OTHERS THEN
                 mydebug ('Others exception while updating To LPN context: ' || SQLCODE);
                 RAISE fnd_api.g_exc_error;
          END ;
      END IF;
      -- Find a matching MMTT within the given header_id only if
      -- p_action = LOAD_MULTIPLE. for LOAD_SINGLE, we need not try to find
      -- a mergeable MMTT
        l_progress    :=  '400';
        mydebug ('l_progress: ' || l_progress );
      IF p_action = l_g_action_split  OR
        p_action = l_g_action_load_multiple --  ('SPLIT', 'LOAD_MULTIPLE')
        THEN
         l_progress    :=  '410';
         mydebug ('l_progress: ' || l_progress );
         FOR rec_split_mmtts  IN  cur_split_mmtts
           LOOP
              l_progress    :=  '420';
              mydebug ('l_progress: ' || l_progress );
              l_transaction_temp_id_to_merge := rec_split_mmtts.transaction_temp_id;
              mydebug('in loop..l_transaction_temp_id_to_merge = ' || l_transaction_temp_id_to_merge );
              EXIT;
           END LOOP;
      END IF;


      l_progress    :=  '500';
      mydebug ('l_progress: ' || l_progress );
      mydebug('l_transaction_temp_id_to_merge = ' || l_transaction_temp_id_to_merge );

      -- For pick short , it should work as a split so that we can process the workflow
      IF p_exception = l_g_exception_short
        THEN
         l_action := l_g_action_split;  -- SPLIT
       ELSE
         l_action := p_action;
      END IF;

      mydebug('l_action: ' || l_action);
      IF  l_transaction_temp_id_to_merge IS NULL
        THEN
         IF l_action = l_g_action_split  THEN
            l_insert      := 'Y';  --insert new MMTT
            l_update      := 'Y1'; -- update original MMTT to reduce qty
          ELSE  -- LOAD_SINGLE or LOAD_MULTIPLE
            l_insert      := 'N';  -- do not insert new MMTT
            l_update      := 'Y1'; -- update original MMTT = conmfirmed qty
         END IF;
       ELSE
         l_insert      := 'N';  -- Do not insert new MMTT
         l_update      := 'Y2'; -- 2 updates. 1- original MMTT to reduce qty
         --            2- mergeable MMTT to add qty
      END IF;
      mydebug('l_insert:' || l_insert || ':l_update:'|| l_update);
      proc_insert_update_mmtt
        (p_action                             => l_action
         ,p_insert                             => l_insert
         ,p_update                             => l_update
         ,p_organization_id                    => p_organization_id
         ,p_user_id                            => p_user_id
         ,p_transaction_header_id              => p_transaction_header_id
         ,p_transaction_temp_id                => p_transaction_temp_id
         ,p_transaction_temp_id_to_merge       => l_transaction_temp_id_to_merge
         ,p_lpn_id                             => l_lpn_id
         ,p_content_lpn_id                     => l_content_lpn_id
         ,p_transfer_lpn_id                    => l_transfer_lpn_id
         ,p_confirmed_sub                      => p_confirmed_sub
         ,p_confirmed_locator_id               => p_confirmed_locator_id
         ,p_confirmed_uom                      => p_confirmed_uom
         ,p_suggested_uom                      => p_suggested_uom
         ,p_primary_uom                        => p_primary_uom
         ,p_inventory_item_id                  => p_inventory_item_id
         ,p_revision                           => p_revision
         ,p_confirmed_trx_qty                  => p_confirmed_trx_qty
         ,p_confirmed_lots                     => p_confirmed_lots
         ,p_confirmed_lot_trx_qty              => p_confirmed_lot_trx_qty
         ,p_confirmed_sec_uom                  => p_confirmed_sec_uom
         ,p_confirmed_sec_qty                  => p_confirmed_sec_qty
         ,p_confirmed_serials                  => p_confirmed_serials
         ,p_container_item_id                  => l_container_item_id
         ,p_lpn_match                          => p_lpn_match
         ,p_lpn_match_lpn_id                   => l_lpn_match_lpn_id
         ,p_serial_allocated_flag              => p_serial_allocated_flag
         ,p_lot_controlled                     => p_lot_controlled
         ,p_serial_controlled                  => p_serial_controlled
         ,p_wms_task_status                    => l_g_task_loaded
         ,p_exception                          => p_exception
         ,p_parent_lpn_id                      => l_parent_lpn_id
         ,x_new_transaction_temp_id            => l_new_transaction_temp_id
         ,x_return_status                      => x_return_status
         ,x_msg_count                          => x_msg_count
         ,x_msg_data                           => x_msg_data
	 ,p_substitute_lots	               => p_substitute_lots); --/* Bug 9448490 Lot Substitution Project */
      IF x_return_status <> l_g_ret_sts_success THEN
         mydebug('x_return_status : ' || x_return_status);
         RAISE fnd_api.G_EXC_ERROR;
      END IF;
      x_new_transaction_temp_id := l_new_transaction_temp_id;
      mydebug('x_new_transaction_temp_id : '  || x_new_transaction_temp_id);

      /*  Task management
      Action l_insert   L_update  update orginalTSK UpdMergeTSK   InsertNewTSK
        SPLIT Y   Y1  N   N  Y
        SPLIT N   Y2  Y   Y  N
        LOAD_M N   Y1  Y   N  N
        LOAD_M N   Y2  Y-Delete  Y  N
        LOAD_S N   Y1  Y   N  N
        */

        l_progress    :=  '500';
      mydebug ('l_progress: ' || l_progress );
      proc_insert_update_task -- new task using p_transaction_temp_id);
        (p_action                    => l_action
         ,p_insert                    => l_insert
         ,p_update                    => l_update
         ,p_temp_id                   => p_transaction_temp_id
         ,p_new_temp_id               => l_new_transaction_temp_id -- will be notNULL only if p_insert=Y
         ,p_merge_temp_id             => l_transaction_temp_id_to_merge
         ,p_task_status               => l_g_task_loaded
         ,p_user_id                   => p_user_id
         ,x_return_status             => x_return_status
         ,x_msg_count                 => x_msg_count
         ,x_msg_data                  => x_msg_data);

      IF x_return_status <> l_g_ret_sts_success THEN
         --x_return_status  := l_g_ret_sts_success;
         RAISE fnd_api.G_EXC_ERROR;
      END IF;
   END IF;

   l_progress := 'END';
   mydebug('COmmit ' );
   COMMIT;
   mydebug('End .. ' || l_proc_name);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status  := l_g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      mydebug('ROLLBACK ' );
      ROLLBACK ;
      mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
      mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
      mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      mydebug('ROLLBACK ' );
      ROLLBACK ;
      mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
      mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
      mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
   WHEN OTHERS THEN
      x_return_status  := l_g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      mydebug('ROLLBACK ' );
      ROLLBACK ;
      mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
      mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
      mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);

END task_merge_split;


PROCEDURE  proc_insert_update_task
  (p_action                    IN            VARCHAR2
   ,p_insert                    IN            VARCHAR2
   ,p_update                    IN            VARCHAR2
   ,p_temp_id                   IN            NUMBER
   ,p_new_temp_id               IN            NUMBER
   ,p_merge_temp_id             IN            NUMBER
   ,p_task_status               IN            NUMBER
   ,p_user_id                   IN            NUMBER
   ,x_return_status             OUT NOCOPY    VARCHAR2
   ,x_msg_count                 OUT NOCOPY    NUMBER
   ,x_msg_data                  OUT NOCOPY    VARCHAR2)
  IS
     l_proc_name               VARCHAR2(30) :=  'proc_insert_update_task';
     l_progress                VARCHAR2(30) :=  '100';
     l_transaction_temp_id     NUMBER := NULL;
BEGIN
   mydebug(l_proc_name || ': Before Insert into WMSDT');

   x_return_status  := l_g_ret_sts_success;

   mydebug ('p_action         = ' || p_action);
   mydebug ('p_insert         = ' || p_insert);
   mydebug ('p_update         = ' || p_update);
   mydebug ('p_temp_id        = ' || p_temp_id);
   mydebug ('p_new_temp_id    = ' || p_new_temp_id);
   mydebug ('p_merge_temp_id  = ' || p_merge_temp_id);
   mydebug ('p_task_status    = ' || p_task_status);

   IF p_insert = 'Y' THEN
       INSERT INTO wms_dispatched_tasks
                          (task_id
                          ,transaction_temp_id
                          ,organization_id
                          ,user_task_type
                          ,person_id
                          ,effective_start_date
                          ,effective_end_date
                          ,equipment_id
                          ,equipment_instance
                          ,person_resource_id
                          ,machine_resource_id
                          ,status
                          ,dispatched_time
                          ,loaded_time
                          ,drop_off_time
                          ,last_update_date
                          ,last_updated_by
                          ,creation_date
                          ,created_by
                          ,last_update_login
                          ,attribute_category
                          ,attribute1
                          ,attribute2
                          ,attribute3
                          ,attribute4
                          ,attribute5
                          ,attribute6
                          ,attribute7
                          ,attribute8
                          ,attribute9
                          ,attribute10
                          ,attribute11
                          ,attribute12
                          ,attribute13
                          ,attribute14
                          ,attribute15
                          ,task_type
                          ,priority
                          ,task_group_id
                          ,device_id
                          ,device_inVoked
                          ,device_request_id
                          ,suggested_dest_subinventory
                          ,suggested_dest_locator_id
                          ,operation_plan_id
                          ,move_order_line_id
                          ,transfer_lpn_id )
          (SELECT wms_dispatched_tasks_s.NEXTVAL
                          ,p_new_temp_id             -- parameter
                          ,organization_id
                          ,user_task_type
                          ,person_id
                          ,effective_start_date
                          ,effective_end_date
                          ,equipment_id
                          ,equipment_instance
                          ,person_resource_id
                          ,machine_resource_id
                          ,p_task_status                -- parameter
                          ,dispatched_time
                          ,SYSDATE
                          ,drop_off_time
                          ,SYSDATE
                          ,last_updated_by
                          ,SYSDATE
                          ,p_user_id         -- parameter
                          ,last_update_login
                          ,attribute_category
                          ,attribute1
                          ,attribute2
                          ,attribute3
                          ,attribute4
                          ,attribute5
                          ,attribute6
                          ,attribute7
                          ,attribute8
                          ,attribute9
                          ,attribute10
                          ,attribute11
                          ,attribute12
                          ,attribute13
                          ,attribute14
                          ,attribute15
                          ,task_type
                          ,priority
                          ,task_group_id
                          ,device_id
                          ,device_invoked
                          ,device_request_id
                          ,suggested_dest_subinventory
                          ,suggested_dest_locator_id
                          ,operation_plan_id
                          ,move_order_line_id
                          ,transfer_lpn_id
            FROM   wms_dispatched_tasks
            WHERE transaction_temp_id = p_temp_id);
      IF SQL%NOTFOUND THEN
         myDebug('Error inserting a new task using WDT record for : '|| p_temp_id);
         fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR'); --NEWMSG
         -- Internal Error $ROUTINE
         fnd_message.set_token('ROUTINE', '- proc_insert_update_task' );
         fnd_msg_pub.ADD;
         RAISE fnd_api.G_EXC_ERROR;
      END IF;
   ELSE
      l_progress := '200';
      mydebug ('l_progress: ' || l_progress );
      IF p_update = 'Y1' THEN
         l_transaction_temp_id := p_temp_id; -- update only the original task
      ELSE
         l_transaction_temp_id := p_merge_temp_id; -- update the merged task
      END IF;
      l_progress := '250';
      mydebug('l_progress: ' || l_progress );
      mydebug('l_transaction_temp_id : ' || l_transaction_temp_id);
      UPDATE  wms_dispatched_tasks
      SET     status =  p_task_status
              ,loaded_time = SYSDATE
              ,last_update_date = SYSDATE
              ,last_updated_by   = p_user_id
      WHERE transaction_temp_id = l_transaction_temp_id;
      IF SQL%NOTFOUND THEN
            mydebug('l_progress : ' || l_progress);
         myDebug('Error updating task for : '|| l_transaction_temp_id);
         fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR'); --NEWMSG
         -- Internal Error $ROUTINE
         fnd_message.set_token('ROUTINE', '- proc_insert_update_task' );
         fnd_msg_pub.ADD;
         RAISE fnd_api.G_EXC_ERROR;
      END IF;
      IF p_update = 'Y2' AND p_action = l_g_action_load_multiple THEN
         fnd_message.set_token('ROUTINE', '- proc_insert_update_task' );
         fnd_msg_pub.ADD;
         l_progress := '300';
         mydebug('l_progress: ' || l_progress );
         -- delete the original one with p_transaction_temp_id
         DELETE  wms_dispatched_tasks
          WHERE  transaction_temp_id = p_temp_id;
         IF SQL%NOTFOUND THEN
            myDebug('Error deleting task for : '|| l_transaction_temp_id);
            fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR'); --NEWMSG
            -- Internal Error $ROUTINE
            fnd_message.set_token('ROUTINE', '- proc_insert_update_task' );
            fnd_msg_pub.ADD;
            RAISE fnd_api.G_EXC_ERROR;
         END IF;
      END IF;

   END IF;

   mydebug('End .. ' || l_proc_name);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);

END proc_insert_update_task;

PROCEDURE proc_insert_update_mmtt
              (p_action                               IN            VARCHAR2
              ,p_insert                               IN            VARCHAR2
              ,p_update                               IN            VARCHAR2
              ,p_organization_id                      IN            NUMBER
              ,p_user_id                              IN            NUMBER
              ,p_transaction_header_id                IN            NUMBER
              ,p_transaction_temp_id                  IN            NUMBER
              ,p_transaction_temp_id_to_merge         IN            NUMBER
              ,p_lpn_id                               IN            NUMBER
              ,p_content_lpn_id                       IN            NUMBER
              ,p_transfer_lpn_id                      IN            NUMBER
              ,p_confirmed_sub                        IN            VARCHAR2
              ,p_confirmed_locator_id                 IN            NUMBER
              ,p_confirmed_uom                        IN            VARCHAR2
              ,p_suggested_uom                        IN            VARCHAR2
              ,p_primary_uom                          IN            VARCHAR2
              ,p_inventory_item_id                    IN            NUMBER
              ,p_revision                             IN            VARCHAR2
              ,p_confirmed_trx_qty                    IN            NUMBER
              ,p_confirmed_lots                       IN            VARCHAR2
              ,p_confirmed_lot_trx_qty                IN            VARCHAR2
              ,p_confirmed_sec_uom                    IN            VARCHAR2
              ,p_confirmed_sec_qty                    IN            VARCHAR2
              ,p_confirmed_serials                    IN            VARCHAR2
              ,p_container_item_id                    IN            NUMBER
              ,p_wms_task_status                      IN            NUMBER
              ,p_lpn_match                            IN            NUMBER
              ,p_lpn_match_lpn_id                     IN            NUMBER
              ,p_serial_allocated_flag                IN            VARCHAR2
              ,p_lot_controlled                       IN            VARCHAR2  -- Y/N
              ,p_serial_controlled                    IN            VARCHAR2  -- Y/N
              ,p_exception                            IN            VARCHAR2 -- SHORT/OVER
              ,p_parent_lpn_id                        IN            NUMBER
              ,x_new_transaction_temp_id              OUT NOCOPY    NUMBER
              ,x_return_status                        OUT NOCOPY    VARCHAR2
              ,x_msg_count                            OUT NOCOPY    NUMBER
              ,x_msg_data                             OUT NOCOPY    VARCHAR2
	       ,p_substitute_lots		      IN	    VARCHAR2) --/* Bug 9448490 Lot Substitution Project */
IS
   l_proc_name                   VARCHAR2(30) :=  'PROC_INSERT_UPDATE_MMTT';
   l_progress                    VARCHAR2(30) :=  '100';
   l_new_transaction_temp_id     NUMBER       := NULL;
   l_confirmed_prim_qty          NUMBER       := 0;
   l_confirmed_sugg_qty          NUMBER       := 0;
   l_confirmed_sec_qty           NUMBER       := 0;
   l_confirmed_lot_trx_sec_qty   VARCHAR2(100) := NULL;
   n                             NUMBER       := 1;
   m                             NUMBER       := 1;
   l_delimiter                   VARCHAR(30)  := ':';
   l_rem_lot_pri_qty             NUMBER;
   l_rem_lot_trx_qty             NUMBER;
   l_rem_lot_sec_qty             NUMBER;


BEGIN
   mydebug('In ..' || l_proc_name );

   x_return_status  := l_g_ret_sts_success;

   mydebug ('p_action                 = ' || p_action                 );
   mydebug ('p_insert                 = ' || p_insert                 );
   mydebug ('p_update                 = ' || p_update                 );
   mydebug ('p_transaction_header_id  = ' || p_transaction_header_id  );
   mydebug ('p_transaction_temp_id    = ' || p_transaction_temp_id    );
   mydebug ('p_lpn_id                 = ' || p_lpn_id                 );
   mydebug ('p_content_lpn_id         = ' || p_content_lpn_id         );
   mydebug ('p_parent_lpn_id          = ' || p_parent_lpn_id          );
   mydebug ('p_transfer_lpn_id        = ' || p_transfer_lpn_id        );
   mydebug ('p_confirmed_sub          = ' || p_confirmed_sub          );
   mydebug ('p_confirmed_locator_id   = ' || p_confirmed_locator_id   );
   mydebug ('p_confirmed_uom          = ' || p_confirmed_uom          );
   mydebug ('p_suggested_uom          = ' || p_suggested_uom          );
   mydebug ('p_primary_uom            = ' || p_primary_uom            );
   mydebug ('p_inventory_item_id      = ' || p_inventory_item_id      );
   mydebug ('p_revision               = ' || p_revision               );
   mydebug ('p_confirmed_trx_qty      = ' || p_confirmed_trx_qty      );
   mydebug ('p_confirmed_lots         = ' || p_confirmed_lots         );
   mydebug ('p_confirmed_lot_trx_qty  = ' || p_confirmed_lot_trx_qty  );
   mydebug ('p_confirmed_sec_uom      = ' || p_confirmed_sec_uom      );
   mydebug ('p_confirmed_sec_qty      = ' || p_confirmed_sec_qty      );
   mydebug ('p_confirmed_serials      = ' || p_confirmed_serials      );
   mydebug ('p_container_item_id      = ' || p_container_item_id      );
   mydebug ('p_lpn_match              = ' || p_lpn_match              );
   mydebug ('p_lpn_match_lpn_id       = ' || p_lpn_match_lpn_id       );
   mydebug ('p_lot_controlled         = ' || p_lot_controlled         );
   mydebug ('p_exception              = ' || p_exception              );


   /* p_suggested_uom is the uom in which allocations are created. IN allocation MMTT it
 * is the transaction_uom .
 * p_confirmed_uom is the uom confirmed on the UI. This may or may not be equal
 * to suggested UOM
 * p_primary_uom is always static.*/
   IF p_primary_uom <> p_confirmed_uom
   THEN
      l_confirmed_prim_qty := inv_convert.inv_um_convert
                               (item_id          => p_inventory_item_id
                               ,precision        => l_g_decimal_precision
                               ,from_quantity    => p_confirmed_trx_qty
                               ,from_unit        => p_confirmed_uom
                               ,to_unit          => p_primary_uom
                               ,from_name        => NULL
                               ,to_name          => NULL);
   ELSE
      l_confirmed_prim_qty := p_confirmed_trx_qty;
   END IF;


   IF p_suggested_uom <> p_confirmed_uom
   THEN
      l_confirmed_sugg_qty := inv_convert.inv_um_convert
                               (item_id          => p_inventory_item_id
                               ,precision        => l_g_decimal_precision
                               ,from_quantity    => p_confirmed_trx_qty
                               ,from_unit        => p_confirmed_uom
                               ,to_unit          => p_suggested_uom
                               ,from_name        => NULL
                               ,to_name          => NULL);
   ELSE
      l_confirmed_sugg_qty := p_confirmed_trx_qty;
   END IF;


   -- Create new MMTT line

   IF p_lot_controlled = 'Y'
      -- For lot and Lot+serial controlled items, secondary quantity will be stored at lot level (MTLT)
      -- for vanilla items and serial controlled items it will be stored at MMTT level
   THEN
      WHILE  (n <> 0)
      LOOP
         n := INSTR(p_confirmed_sec_qty,l_delimiter,m,1);
         IF n = 0 THEN -- Last part OF the string
            l_confirmed_lot_trx_sec_qty :=  NVL(substr(p_confirmed_sec_qty,m,length(p_confirmed_sec_qty)), 0);
         ELSE
            l_confirmed_lot_trx_sec_qty :=  substr(p_confirmed_sec_qty,m,n-m) ;-- start at M get m-n chrs.
            m := n+1;
         END IF;
         l_confirmed_sec_qty := l_confirmed_sec_qty
                                + fnd_number.canonical_to_number(l_confirmed_lot_trx_sec_qty);
      END LOOP;
   ELSE
      l_confirmed_sec_qty := fnd_number.canonical_to_number(p_confirmed_sec_qty);
   END IF;

   mydebug ('l_confirmed_sec_qty = ' || l_confirmed_sec_qty);

   IF p_insert = 'Y' THEN
      l_progress   :=  '110';
      SELECT mtl_material_transactions_s.NEXTVAL
      INTO l_new_transaction_temp_id
      FROM DUAL;
      x_new_transaction_temp_id := l_new_transaction_temp_id;

      mydebug(l_proc_name || ': l_new_transaction_temp_id = ' || l_new_transaction_temp_id);

      INSERT INTO mtl_material_transactions_temp
                    ( TRANSACTION_HEADER_ID
                     ,TRANSACTION_TEMP_ID
                     ,SOURCE_CODE
                     ,SOURCE_LINE_ID
                     ,TRANSACTION_MODE
                     ,LOCK_FLAG
                     ,LAST_UPDATE_DATE
                     ,LAST_UPDATED_BY
                     ,CREATION_DATE
                     ,CREATED_BY
                     ,LAST_UPDATE_LOGIN
                     ,REQUEST_ID
                     ,PROGRAM_APPLICATION_ID
                     ,PROGRAM_ID
                     ,PROGRAM_UPDATE_DATE
                     ,INVENTORY_ITEM_ID
                     ,REVISION
                     ,ORGANIZATION_ID
                     ,SUBINVENTORY_CODE
                     ,LOCATOR_ID
                     ,TRANSACTION_QUANTITY
                     ,PRIMARY_QUANTITY
                     ,TRANSACTION_UOM
                     ,TRANSACTION_COST
                     ,TRANSACTION_TYPE_ID
                     ,TRANSACTION_ACTION_ID
                     ,TRANSACTION_SOURCE_TYPE_ID
                     ,TRANSACTION_SOURCE_ID
                     ,TRANSACTION_SOURCE_NAME
                     ,TRANSACTION_DATE
                     ,ACCT_PERIOD_ID
                     ,DISTRIBUTION_ACCOUNT_ID
                     ,TRANSACTION_REFERENCE
                     ,REQUISITION_LINE_ID
                     ,REQUISITION_DISTRIBUTION_ID
                     ,REASON_ID
                     ,LOT_NUMBER
                     ,LOT_EXPIRATION_DATE
                     ,SERIAL_NUMBER
                     ,RECEIVING_DOCUMENT
                     ,DEMAND_ID
                     ,RCV_TRANSACTION_ID
                     ,MOVE_TRANSACTION_ID
                     ,COMPLETION_TRANSACTION_ID
                     ,WIP_ENTITY_TYPE
                     ,SCHEDULE_ID
                     ,REPETITIVE_LINE_ID
                     ,EMPLOYEE_CODE
                     ,PRIMARY_SWITCH
                     ,SCHEDULE_UPDATE_CODE
                     ,SETUP_TEARDOWN_CODE
                     ,ITEM_ORDERING
                     ,NEGATIVE_REQ_FLAG
                     ,OPERATION_SEQ_NUM
                     ,PICKING_LINE_ID
                     ,TRX_SOURCE_LINE_ID
                     ,TRX_SOURCE_DELIVERY_ID
                     ,PHYSICAL_ADJUSTMENT_ID
                     ,CYCLE_COUNT_ID
                     ,RMA_LINE_ID
                     ,CUSTOMER_SHIP_ID
                     ,CURRENCY_CODE
                     ,CURRENCY_CONVERSION_RATE
                     ,CURRENCY_CONVERSION_TYPE
                     ,CURRENCY_CONVERSION_DATE
                     ,USSGL_TRANSACTION_CODE
                     ,VENDOR_LOT_NUMBER
                     ,ENCUMBRANCE_ACCOUNT
                     ,ENCUMBRANCE_AMOUNT
                     ,SHIP_TO_LOCATION
                     ,SHIPMENT_NUMBER
                     ,TRANSFER_COST
                     ,TRANSPORTATION_COST
                     ,TRANSPORTATION_ACCOUNT
                     ,FREIGHT_CODE
                     ,CONTAINERS
                     ,WAYBILL_AIRBILL
                     ,EXPECTED_ARRIVAL_DATE
                     ,TRANSFER_SUBINVENTORY
                     ,TRANSFER_ORGANIZATION
                     ,TRANSFER_TO_LOCATION
                     ,NEW_AVERAGE_COST
                     ,VALUE_CHANGE
                     ,PERCENTAGE_CHANGE
                     ,MATERIAL_ALLOCATION_TEMP_ID
                     ,DEMAND_SOURCE_HEADER_ID
                     ,DEMAND_SOURCE_LINE
                     ,DEMAND_SOURCE_DELIVERY
                     ,ITEM_SEGMENTS
                     ,ITEM_DESCRIPTION
                     ,ITEM_TRX_ENABLED_FLAG
                     ,ITEM_LOCATION_CONTROL_CODE
                     ,ITEM_RESTRICT_SUBINV_CODE
                     ,ITEM_RESTRICT_LOCATORS_CODE
                     ,ITEM_REVISION_QTY_CONTROL_CODE
                     ,ITEM_PRIMARY_UOM_CODE
                     ,ITEM_UOM_CLASS
                     ,ITEM_SHELF_LIFE_CODE
                     ,ITEM_SHELF_LIFE_DAYS
                     ,ITEM_LOT_CONTROL_CODE
                     ,ITEM_SERIAL_CONTROL_CODE
                     ,ITEM_INVENTORY_ASSET_FLAG
                     ,ALLOWED_UNITS_LOOKUP_CODE
                     ,DEPARTMENT_ID
                     ,DEPARTMENT_CODE
                     ,WIP_SUPPLY_TYPE
                     ,SUPPLY_SUBINVENTORY
                     ,SUPPLY_LOCATOR_ID
                     ,VALID_SUBINVENTORY_FLAG
                     ,VALID_LOCATOR_FLAG
                     ,LOCATOR_SEGMENTS
                     ,CURRENT_LOCATOR_CONTROL_CODE
                     ,NUMBER_OF_LOTS_ENTERED
                     ,WIP_COMMIT_FLAG
                     ,NEXT_LOT_NUMBER
                     ,LOT_ALPHA_PREFIX
                     ,NEXT_SERIAL_NUMBER
                     ,SERIAL_ALPHA_PREFIX
                     ,SHIPPABLE_FLAG
                     ,POSTING_FLAG
                     ,REQUIRED_FLAG
                     ,PROCESS_FLAG
                     ,ERROR_CODE
                     ,ERROR_EXPLANATION
                     ,ATTRIBUTE_CATEGORY
                     ,ATTRIBUTE1
                     ,ATTRIBUTE2
                     ,ATTRIBUTE3
                     ,ATTRIBUTE4
                     ,ATTRIBUTE5
                     ,ATTRIBUTE6
                     ,ATTRIBUTE7
                     ,ATTRIBUTE8
                     ,ATTRIBUTE9
                     ,ATTRIBUTE10
                     ,ATTRIBUTE11
                     ,ATTRIBUTE12
                     ,ATTRIBUTE13
                     ,ATTRIBUTE14
                     ,ATTRIBUTE15
                     ,MOVEMENT_ID
                     ,RESERVATION_QUANTITY
                     ,SHIPPED_QUANTITY
                     ,TRANSACTION_LINE_NUMBER
                     ,TASK_ID
                     ,TO_TASK_ID
                     ,SOURCE_TASK_ID
                     ,PROJECT_ID
                     ,SOURCE_PROJECT_ID
                     ,PA_EXPENDITURE_ORG_ID
                     ,TO_PROJECT_ID
                     ,EXPENDITURE_TYPE
                     ,FINAL_COMPLETION_FLAG
                     ,TRANSFER_PERCENTAGE
                     ,TRANSACTION_SEQUENCE_ID
                     ,MATERIAL_ACCOUNT
                     ,MATERIAL_OVERHEAD_ACCOUNT
                     ,RESOURCE_ACCOUNT
                     ,OUTSIDE_PROCESSING_ACCOUNT
                     ,OVERHEAD_ACCOUNT
                     ,FLOW_SCHEDULE
                     ,COST_GROUP_ID
                     ,TRANSFER_COST_GROUP_ID
                     ,DEMAND_CLASS
                     ,QA_COLLECTION_ID
                     ,KANBAN_CARD_ID
                     ,OVERCOMPLETION_TRANSACTION_QTY
                     ,OVERCOMPLETION_PRIMARY_QTY
                     ,OVERCOMPLETION_TRANSACTION_ID
                     ,END_ITEM_UNIT_NUMBER
                     ,SCHEDULED_PAYBACK_DATE
                     ,LINE_TYPE_CODE
                     ,PARENT_TRANSACTION_TEMP_ID
                     ,PUT_AWAY_STRATEGY_ID
                     ,PUT_AWAY_RULE_ID
                     ,PICK_STRATEGY_ID
                     ,PICK_RULE_ID
                     ,MOVE_ORDER_LINE_ID
                     ,TASK_GROUP_ID
                     ,PICK_SLIP_NUMBER
                     ,RESERVATION_ID
                     ,COMMON_BOM_SEQ_ID
                     ,COMMON_ROUTING_SEQ_ID
                     ,ORG_COST_GROUP_ID
                     ,COST_TYPE_ID
                     ,TRANSACTION_STATUS
                     ,STANDARD_OPERATION_ID
                     ,TASK_PRIORITY
                     ,WMS_TASK_TYPE
                     ,PARENT_LINE_ID
                     ,LPN_ID
                     ,TRANSFER_LPN_ID
                     ,WMS_TASK_STATUS
                     ,CONTENT_LPN_ID
                     ,CONTAINER_ITEM_ID
                     ,CARTONIZATION_ID
                     ,PICK_SLIP_DATE
                     ,REBUILD_ITEM_ID
                     ,REBUILD_SERIAL_NUMBER
                     ,REBUILD_ACTIVITY_ID
                     ,REBUILD_JOB_NAME
                     ,ORGANIZATION_TYPE
                     ,TRANSFER_ORGANIZATION_TYPE
                     ,OWNING_ORGANIZATION_ID
                     ,OWNING_TP_TYPE
                     ,XFR_OWNING_ORGANIZATION_ID
                     ,TRANSFER_OWNING_TP_TYPE
                     ,PLANNING_ORGANIZATION_ID
                     ,PLANNING_TP_TYPE
                     ,XFR_PLANNING_ORGANIZATION_ID
                     ,TRANSFER_PLANNING_TP_TYPE
                     ,SECONDARY_UOM_CODE
                     ,SECONDARY_TRANSACTION_QUANTITY
                     ,TRANSACTION_BATCH_ID
                     ,TRANSACTION_BATCH_SEQ
                     ,ALLOCATED_LPN_ID
                     ,SCHEDULE_NUMBER
                     ,SCHEDULED_FLAG
                     ,CLASS_CODE
                     ,SCHEDULE_GROUP
                     ,BUILD_SEQUENCE
                     ,BOM_REVISION
                     ,ROUTING_REVISION
                     ,BOM_REVISION_DATE
                     ,ROUTING_REVISION_DATE
                     ,ALTERNATE_BOM_DESIGNATOR
                     ,ALTERNATE_ROUTING_DESIGNATOR
                     ,OPERATION_PLAN_ID
                     ,INTRANSIT_ACCOUNT
                     ,FOB_POINT
                     ,MOVE_ORDER_HEADER_ID
                     ,SERIAL_ALLOCATED_FLAG
                    )
          (SELECT
                     TRANSACTION_HEADER_ID
                     ,l_new_transaction_temp_id
                     ,SOURCE_CODE
                     ,SOURCE_LINE_ID
                     ,TRANSACTION_MODE
                     ,LOCK_FLAG
                     ,SYSDATE -- it should not copy from original MMTT
                     ,p_user_id -- it should not copy from original MMTT
                     ,SYSDATE
                     ,p_user_id
                     ,LAST_UPDATE_LOGIN
                     ,REQUEST_ID
                     ,PROGRAM_APPLICATION_ID
                     ,PROGRAM_ID
                     ,PROGRAM_UPDATE_DATE
                     ,INVENTORY_ITEM_ID
                     ,REVISION
                     ,ORGANIZATION_ID
                     ,p_confirmed_sub
                     ,p_confirmed_locator_id
                     ,p_confirmed_trx_qty
                     ,l_confirmed_prim_qty
                     ,nvl(p_confirmed_uom, item_primary_uom_code)
                     ,TRANSACTION_COST
                     ,TRANSACTION_TYPE_ID
                     ,TRANSACTION_ACTION_ID
                     ,TRANSACTION_SOURCE_TYPE_ID
                     ,TRANSACTION_SOURCE_ID
                     ,TRANSACTION_SOURCE_NAME
                     ,TRANSACTION_DATE
                     ,ACCT_PERIOD_ID
                     ,DISTRIBUTION_ACCOUNT_ID
                     ,TRANSACTION_REFERENCE
                     ,REQUISITION_LINE_ID
                     ,REQUISITION_DISTRIBUTION_ID
                     ,REASON_ID
                     ,LOT_NUMBER
                     ,LOT_EXPIRATION_DATE
                     ,SERIAL_NUMBER
                     ,RECEIVING_DOCUMENT
                     ,DEMAND_ID
                     ,RCV_TRANSACTION_ID
                     ,MOVE_TRANSACTION_ID
                     ,COMPLETION_TRANSACTION_ID
                     ,WIP_ENTITY_TYPE
                     ,SCHEDULE_ID
                     ,REPETITIVE_LINE_ID
                     ,EMPLOYEE_CODE
                     ,PRIMARY_SWITCH
                     ,SCHEDULE_UPDATE_CODE
                     ,SETUP_TEARDOWN_CODE
                     ,ITEM_ORDERING
                     ,NEGATIVE_REQ_FLAG
                     ,OPERATION_SEQ_NUM
                     ,PICKING_LINE_ID
                     ,TRX_SOURCE_LINE_ID
                     ,TRX_SOURCE_DELIVERY_ID
                     ,PHYSICAL_ADJUSTMENT_ID
                     ,CYCLE_COUNT_ID
                     ,RMA_LINE_ID
                     ,CUSTOMER_SHIP_ID
                     ,CURRENCY_CODE
                     ,CURRENCY_CONVERSION_RATE
                     ,CURRENCY_CONVERSION_TYPE
                     ,CURRENCY_CONVERSION_DATE
                     ,USSGL_TRANSACTION_CODE
                     ,VENDOR_LOT_NUMBER
                     ,ENCUMBRANCE_ACCOUNT
                     ,ENCUMBRANCE_AMOUNT
                     ,SHIP_TO_LOCATION
                     ,SHIPMENT_NUMBER
                     ,TRANSFER_COST
                     ,TRANSPORTATION_COST
                     ,TRANSPORTATION_ACCOUNT
                     ,FREIGHT_CODE
                     ,CONTAINERS
                     ,WAYBILL_AIRBILL
                     ,EXPECTED_ARRIVAL_DATE
                     ,TRANSFER_SUBINVENTORY
                     ,TRANSFER_ORGANIZATION
                     ,TRANSFER_TO_LOCATION
                     ,NEW_AVERAGE_COST
                     ,VALUE_CHANGE
                     ,PERCENTAGE_CHANGE
                     ,MATERIAL_ALLOCATION_TEMP_ID
                     ,DEMAND_SOURCE_HEADER_ID
                     ,DEMAND_SOURCE_LINE
                     ,DEMAND_SOURCE_DELIVERY
                     ,ITEM_SEGMENTS
                     ,ITEM_DESCRIPTION
                     ,ITEM_TRX_ENABLED_FLAG
                     ,ITEM_LOCATION_CONTROL_CODE
                     ,ITEM_RESTRICT_SUBINV_CODE
                     ,ITEM_RESTRICT_LOCATORS_CODE
                     ,ITEM_REVISION_QTY_CONTROL_CODE
                     ,ITEM_PRIMARY_UOM_CODE
                     ,ITEM_UOM_CLASS
                     ,ITEM_SHELF_LIFE_CODE
                     ,ITEM_SHELF_LIFE_DAYS
                     ,ITEM_LOT_CONTROL_CODE
                     ,ITEM_SERIAL_CONTROL_CODE
                     ,ITEM_INVENTORY_ASSET_FLAG
                     ,ALLOWED_UNITS_LOOKUP_CODE
                     ,DEPARTMENT_ID
                     ,DEPARTMENT_CODE
                     ,WIP_SUPPLY_TYPE
                     ,SUPPLY_SUBINVENTORY
                     ,SUPPLY_LOCATOR_ID
                     ,VALID_SUBINVENTORY_FLAG
                     ,VALID_LOCATOR_FLAG
                     ,LOCATOR_SEGMENTS
                     ,CURRENT_LOCATOR_CONTROL_CODE
                     ,NUMBER_OF_LOTS_ENTERED
                     ,WIP_COMMIT_FLAG
                     ,NEXT_LOT_NUMBER
                     ,LOT_ALPHA_PREFIX
                     ,NEXT_SERIAL_NUMBER
                     ,SERIAL_ALPHA_PREFIX
                     ,SHIPPABLE_FLAG
                     ,POSTING_FLAG
                     ,REQUIRED_FLAG
                     ,PROCESS_FLAG
                     ,ERROR_CODE
                     ,ERROR_EXPLANATION
                     ,ATTRIBUTE_CATEGORY
                     ,ATTRIBUTE1
                     ,ATTRIBUTE2
                     ,ATTRIBUTE3
                     ,ATTRIBUTE4
                     ,ATTRIBUTE5
                     ,ATTRIBUTE6
                     ,ATTRIBUTE7
                     ,ATTRIBUTE8
                     ,ATTRIBUTE9
                     ,ATTRIBUTE10
                     ,ATTRIBUTE11
                     ,ATTRIBUTE12
                     ,ATTRIBUTE13
                     ,ATTRIBUTE14
                     ,ATTRIBUTE15
                     ,MOVEMENT_ID
                     ,RESERVATION_QUANTITY
                     ,SHIPPED_QUANTITY
                     ,TRANSACTION_LINE_NUMBER
                     ,TASK_ID
                     ,TO_TASK_ID
                     ,SOURCE_TASK_ID
                     ,PROJECT_ID
                     ,SOURCE_PROJECT_ID
                     ,PA_EXPENDITURE_ORG_ID
                     ,TO_PROJECT_ID
                     ,EXPENDITURE_TYPE
                     ,FINAL_COMPLETION_FLAG
                     ,TRANSFER_PERCENTAGE
                     ,TRANSACTION_SEQUENCE_ID
                     ,MATERIAL_ACCOUNT
                     ,MATERIAL_OVERHEAD_ACCOUNT
                     ,RESOURCE_ACCOUNT
                     ,OUTSIDE_PROCESSING_ACCOUNT
                     ,OVERHEAD_ACCOUNT
                     ,FLOW_SCHEDULE
                     ,COST_GROUP_ID
                     ,TRANSFER_COST_GROUP_ID
                     ,DEMAND_CLASS
                     ,QA_COLLECTION_ID
                     ,KANBAN_CARD_ID
                     ,OVERCOMPLETION_TRANSACTION_QTY
                     ,OVERCOMPLETION_PRIMARY_QTY
                     ,OVERCOMPLETION_TRANSACTION_ID
                     ,END_ITEM_UNIT_NUMBER
                     ,SCHEDULED_PAYBACK_DATE
                     ,LINE_TYPE_CODE
                     ,PARENT_TRANSACTION_TEMP_ID
                     ,PUT_AWAY_STRATEGY_ID
                     ,PUT_AWAY_RULE_ID
                     ,PICK_STRATEGY_ID
                     ,PICK_RULE_ID
                     ,MOVE_ORDER_LINE_ID
                     ,TASK_GROUP_ID
                     ,PICK_SLIP_NUMBER
                     ,reservation_id
                     ,COMMON_BOM_SEQ_ID
                     ,COMMON_ROUTING_SEQ_ID
                     ,ORG_COST_GROUP_ID
                     ,COST_TYPE_ID
                     ,TRANSACTION_STATUS
                     ,STANDARD_OPERATION_ID
                     ,TASK_PRIORITY
                     ,WMS_TASK_TYPE
                     ,decode(PARENT_LINE_ID, NULL,NULL,l_new_transaction_temp_id) -- Take care of BULK parent
                     ,nvl(p_lpn_id,p_parent_lpn_id)  -- process the nesting
                                                     -- fully consumble LPN Pick
                     ,p_transfer_lpn_id
                     -- Bug4185621: instead of inheriting previous line's status, use loaded as status for new line
                     , p_wms_task_status -- wms_task_status
                     ,p_content_lpn_id
                     ,nvl(p_container_item_id,container_item_id)
                     ,CARTONIZATION_ID                 --??
                     ,PICK_SLIP_DATE
                     ,REBUILD_ITEM_ID
                     ,REBUILD_SERIAL_NUMBER
                     ,REBUILD_ACTIVITY_ID
                     ,REBUILD_JOB_NAME
                     ,ORGANIZATION_TYPE
                     ,TRANSFER_ORGANIZATION_TYPE
                     ,OWNING_ORGANIZATION_ID
                     ,OWNING_TP_TYPE
                     ,XFR_OWNING_ORGANIZATION_ID
                     ,TRANSFER_OWNING_TP_TYPE
                     ,PLANNING_ORGANIZATION_ID
                     ,PLANNING_TP_TYPE
                     ,XFR_PLANNING_ORGANIZATION_ID
                     ,TRANSFER_PLANNING_TP_TYPE
                     ,p_confirmed_sec_uom
                     ,decode( p_confirmed_sec_uom, null, null, l_confirmed_sec_qty )-- Bug 4576653
                     ,TRANSACTION_BATCH_ID
                     ,TRANSACTION_BATCH_SEQ
                     ,ALLOCATED_LPN_ID
                     ,SCHEDULE_NUMBER
                     ,SCHEDULED_FLAG
                     ,CLASS_CODE
                     ,SCHEDULE_GROUP
                     ,BUILD_SEQUENCE
                     ,BOM_REVISION
                     ,ROUTING_REVISION
                     ,BOM_REVISION_DATE
                     ,ROUTING_REVISION_DATE
                     ,ALTERNATE_BOM_DESIGNATOR
                     ,ALTERNATE_ROUTING_DESIGNATOR
                     ,OPERATION_PLAN_ID
                     ,INTRANSIT_ACCOUNT
                     ,FOB_POINT
                     ,MOVE_ORDER_HEADER_ID
                     ,SERIAL_ALLOCATED_FLAG
             FROM mtl_material_transactions_temp
            WHERE transaction_temp_id = p_transaction_temp_id);
           IF SQL%NOTFOUND THEN
              mydebug (' p_transaction_temp_id: NOT found : ' || p_transaction_temp_id);
              fnd_message.set_name('WMS', 'WMS_INSERT_ALLOCATION'); -- NEWMSG
              -- "Error Inserting Allocation ."
              fnd_msg_pub.ADD;
              RAISE fnd_api.G_EXC_ERROR;
           END IF;
      l_progress    :=  '120';
      mydebug ('l_progress: ' || l_progress );
   END IF ; -- insert MMTT only if p_insert = 'Y'
   l_progress    :=  '130';
   mydebug ('l_progress: ' || l_progress );
   -- ****Lot Controlled items

   IF p_confirmed_lots     IS NOT NULL  OR
      p_confirmed_serials  IS NOT NULL
   THEN
      l_progress    :=  '140';
      mydebug ('l_progress: ' || l_progress );
       proc_parse_lot_serial_catchwt
              (p_inventory_item_id        => p_inventory_item_id
              ,p_confirmed_lots           => p_confirmed_lots
              ,p_confirmed_lot_trx_qty    => p_confirmed_lot_trx_qty
              ,p_confirmed_serials        => p_confirmed_serials
              ,p_suggested_uom            => p_suggested_uom
              ,p_confirmed_uom            => p_confirmed_uom
              ,p_primary_uom              => p_primary_uom
              ,p_confirmed_sec_uom        => p_confirmed_sec_uom
              ,p_confirmed_sec_qty        => p_confirmed_sec_qty
              ,x_return_status            => x_return_status
              ,x_msg_count                => x_msg_count
              ,x_msg_data                 => x_msg_data);
       IF x_return_status <> l_g_ret_sts_success
       THEN
           fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR'); --NEWMSG
           -- Internal Error $ROUTINE
           fnd_message.set_token('ROUTINE', ' - proc_parse_lot_serial_catchwt API ' );
           mydebug('Error parsing lot/serial/catch weight string' );
           -- "Error reserving Serial Number/s"
           RAISE fnd_api.G_EXC_ERROR;
       END IF;
   END IF;

   -- ****Lot only Controlled items  OR
   -- ****Lot and  Serial Controlled items
   IF (p_lot_controlled = 'Y' )
   THEN
       l_progress    :=  '140';
       proc_process_confirmed_lots
                  (p_action                               =>  p_action
                  ,p_insert                               =>  p_insert
                  ,p_update                               =>  p_update
                  ,p_organization_id                      =>  p_organization_id
                  ,p_user_id                              =>  p_user_id
                  ,p_transaction_header_id                =>  p_transaction_header_id
                  ,p_transaction_temp_id                  =>  p_transaction_temp_id
                  ,p_new_transaction_temp_id              =>  l_new_transaction_temp_id
                  ,p_transaction_temp_id_to_merge         =>  p_transaction_temp_id_to_merge
                  ,p_inventory_item_id                    =>  p_inventory_item_id
                  ,p_revision                             =>  p_revision
                  ,p_suggested_uom                        =>  p_suggested_uom
                  ,p_confirmed_uom                        =>  p_confirmed_uom
                  ,p_primary_uom                          =>  p_primary_uom
                  ,p_confirmed_lots                       =>  p_confirmed_lots
                  ,p_confirmed_lot_trx_qty                =>  p_confirmed_lot_trx_qty
                  ,p_confirmed_serials                    =>  p_confirmed_serials
                  ,p_serial_allocated_flag                =>  p_serial_allocated_flag
                  ,p_lpn_match                            =>  p_lpn_match
                  ,p_lpn_match_lpn_id                     =>  p_lpn_match_lpn_id
                  ,p_confirmed_sec_uom                    =>  p_confirmed_sec_uom
                  ,p_confirmed_sec_qty                    =>  p_confirmed_sec_qty
                  ,p_lot_controlled                       =>  p_lot_controlled
                  ,p_serial_controlled                    =>  p_serial_controlled
                  ,p_exception                            =>  p_exception
                  ,x_return_status                        =>  x_return_status
                  ,x_msg_count                            =>  x_msg_count
                  ,x_msg_data                             =>  x_msg_data
		  ,p_substitute_lots			  =>  p_substitute_lots); --/* Bug 9448490 Lot Substitution Project */
       IF x_return_status <> l_g_ret_sts_success THEN
           mydebug('proc_process_confirmed_lots.x_return_status : ' || x_return_status);
           fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR'); --NEWMSG
           -- Internal Error $ROUTINE
           fnd_message.set_token('ROUTINE', '- proc_process_confirmed_lots API' );
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_error;
       END IF;
       mydebug ('Return from proc_process_confirmed_lots ' );
   END IF;
   l_progress    :=  '150';
   -- ****Serial Controlled items
   IF (p_lot_controlled = 'N' AND p_serial_controlled = 'Y')
   THEN
       l_progress    :=  '300';
       mydebug ('l_progress: ' || l_progress );
       -- may not be necessary to call if p_insert = N , LOAD_SINGLE
       proc_process_confirmed_serials
                  (p_action                               =>  p_action
                  ,p_insert                               =>  p_insert
                  ,p_update                               =>  p_update
                  ,p_organization_id                      =>  p_organization_id
                  ,p_user_id                              =>  p_user_id
                  ,p_transaction_header_id                =>  p_transaction_header_id
                  ,p_transaction_temp_id                  =>  p_transaction_temp_id
                  ,p_new_transaction_temp_id              =>  l_new_transaction_temp_id
                  ,p_transaction_temp_id_to_merge         =>  p_transaction_temp_id_to_merge
                  ,p_serial_transaction_temp_id           =>  NULL
                  ,p_mtlt_serial_temp_id                  =>  NULL
                  ,p_inventory_item_id                    =>  p_inventory_item_id
                  ,p_revision                             =>  p_revision
                  ,p_suggested_uom                        =>  p_suggested_uom
                  ,p_confirmed_uom                        =>  p_confirmed_uom
                  ,p_primary_uom                          =>  p_primary_uom
                  ,p_serial_lot_number                    =>  NULL
                  ,p_confirmed_serials                    =>  p_confirmed_serials
                  ,p_serial_allocated_flag                =>  p_serial_allocated_flag
                  ,p_lpn_match                            =>  p_lpn_match
                  ,p_lpn_match_lpn_id                     =>  p_lpn_match_lpn_id
                  ,p_lot_controlled                       =>  p_lot_controlled
                  ,p_serial_controlled                    =>  p_serial_controlled
                  ,x_return_status                        =>  x_return_status
                  ,x_msg_count                            =>  x_msg_count
                  ,x_msg_data                             =>  x_msg_data);
       IF x_return_status <> l_g_ret_sts_success THEN
          mydebug('proc_process_confirmed_serials.x_return_status : ' || x_return_status);
          fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR'); --NEWMSG
          -- Internal Error $ROUTINE
          fnd_message.set_token('ROUTINE', '- proc_process_confirmed_serials API' );
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
       END IF;
       l_progress    :=  '330';
       mydebug ('l_progress: ' || l_progress );
   END IF;

   l_progress    :=  '170';
   -- update p_transaction_temp_id (reduce qty) for p_update = Y1 or Y2
   mydebug ('l_progress: ' || l_progress );
   mydebug ('p_confirmed_trx_qty: ' || p_confirmed_trx_qty);
   mydebug ('l_confirmed_prim_qty: ' || l_confirmed_prim_qty);
   mydebug ('l_confirmed_sugg_qty: ' || l_confirmed_sugg_qty);
   IF p_update = 'Y1' -- update p_transaction_temp_id  to reduce primary/trxqty
   THEN
      IF p_action = l_g_action_split  THEN
         l_progress    :=  '190';
         mydebug('l_progress : ' || l_progress);
         IF p_exception='OVER' and p_lot_controlled='Y' THEN
            select sum(primary_quantity),sum(transaction_quantity),sum(SECONDARY_QUANTITY)
            into l_rem_lot_pri_qty,l_rem_lot_trx_qty,l_rem_lot_sec_qty
            from mtl_transaction_lots_temp
            where transaction_temp_id = p_transaction_temp_id
              group by transaction_temp_id;


             UPDATE  mtl_material_transactions_temp
             SET     transaction_quantity  = l_rem_lot_trx_qty
               , primary_quantity      = l_rem_lot_pri_qty
               , secondary_transaction_quantity = l_rem_lot_sec_qty
               , last_update_date      =  SYSDATE
               , last_updated_by       =  p_user_id
             WHERE   transaction_temp_id   =  p_transaction_temp_id;
         ELSE
           UPDATE  mtl_material_transactions_temp
           SET     transaction_quantity  =  transaction_quantity - l_confirmed_sugg_qty
               , primary_quantity      =  primary_quantity - l_confirmed_prim_qty
     , secondary_transaction_quantity    =  secondary_transaction_quantity - l_confirmed_sec_qty
               , last_update_date      =  SYSDATE
               , last_updated_by       =  p_user_id
           WHERE   transaction_temp_id   =  p_transaction_temp_id;
         END IF;

         IF SQL%NOTFOUND THEN
            RAISE fnd_api.G_EXC_ERROR;
         END IF;
      ELSE  -- LOAD
         l_progress    :=  '200';
         mydebug('l_progress : ' || l_progress);
         UPDATE  mtl_material_transactions_temp
         SET     transaction_quantity  =  p_confirmed_trx_qty
               , primary_quantity      =  l_confirmed_prim_qty
               , secondary_transaction_quantity    =  decode( p_confirmed_sec_uom,
                                                              null,
                                                              null,
                                                              l_confirmed_sec_qty
                                                            ) -- Bug 4576653
               , secondary_uom_code    =  p_confirmed_sec_uom
               , lpn_id                =  nvl(p_lpn_id,p_parent_lpn_id)
                                                     -- process the nesting
                                                     -- fully consumble LPN Pick
               , content_lpn_id        =  p_content_lpn_id
               , transfer_lpn_id       =  p_transfer_lpn_id
               , subinventory_code     =  p_confirmed_sub
               , locator_id            =  p_confirmed_locator_id
               , transaction_uom        = p_confirmed_uom
               , container_item_id      = p_container_item_id
               , last_update_date      =  SYSDATE
               , last_updated_by       =  p_user_id
               , wms_task_status = p_wms_task_status -- Bug4185621: update mmtt task status to loaded
         WHERE   transaction_temp_id   =  p_transaction_temp_id;

         IF SQL%NOTFOUND THEN
            RAISE fnd_api.G_EXC_ERROR;
         END IF;
      END IF;
   END IF;

   l_progress    :=  '180';

   IF p_update = 'Y2'  -- -- and update p_transaction_temp_id_to_merge  to add qty)
   THEN
         l_progress    :=  '190';
         mydebug ('l_progress ' || l_progress);
         UPDATE  mtl_material_transactions_temp
         SET     transaction_quantity  =  transaction_quantity + p_confirmed_trx_qty
               , primary_quantity      =  primary_quantity + nvl(l_confirmed_prim_qty  ,0)
               , secondary_transaction_quantity    =  secondary_transaction_quantity +  nvl(l_confirmed_sec_qty, 0)
               , secondary_uom_code    =  p_confirmed_sec_uom
               , last_update_date      = SYSDATE
               , last_updated_by       = p_user_id
         WHERE   transaction_temp_id = p_transaction_temp_id_to_merge;
         IF SQL%NOTFOUND THEN
            RAISE fnd_api.G_EXC_ERROR;
         END IF;
         IF p_action = l_g_action_load_multiple  THEN
            l_progress    :=  '190'; -- Delete the original MMTT, if merging into another MMTT
            mydebug ('l_progress ' || l_progress);
            DELETE  mtl_material_transactions_temp
            WHERE   transaction_temp_id = p_transaction_temp_id;
            IF SQL%NOTFOUND THEN
               RAISE fnd_api.G_EXC_ERROR;
            END IF;
         ELSE -- 'SPLIT'
            l_progress    :=  '200';
            mydebug('l_progress : ' || l_progress);
            UPDATE  mtl_material_transactions_temp
            SET     transaction_quantity  =  transaction_quantity - l_confirmed_sugg_qty
                   , primary_quantity  =  primary_quantity - l_confirmed_prim_qty
               , secondary_transaction_quantity  =  secondary_transaction_quantity -  l_confirmed_sec_qty
                   , last_update_date = SYSDATE
                   , last_updated_by   = p_user_id
            WHERE   transaction_temp_id = p_transaction_temp_id;

            IF SQL%NOTFOUND THEN
               RAISE fnd_api.G_EXC_ERROR;
            END IF;
         END IF;
   END IF;
   mydebug ('End of :' || l_proc_name);

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
END proc_insert_update_mmtt;

PROCEDURE proc_process_confirmed_lots
             ( p_action                          IN            VARCHAR2
              ,p_insert                          IN            VARCHAR2
              ,p_update                          IN            VARCHAR2
              ,p_organization_id                 IN            NUMBER
              ,p_user_id                         IN            NUMBER
              ,p_transaction_header_id           IN            NUMBER
              ,p_transaction_temp_id             IN            NUMBER
              ,p_new_transaction_temp_id         IN            NUMBER
              ,p_transaction_temp_id_to_merge    IN            NUMBER
              ,p_inventory_item_id               IN            NUMBER
              ,p_revision                        IN            VARCHAR2
              ,p_suggested_uom                   IN            VARCHAR2
              ,p_confirmed_uom                   IN            VARCHAR2
              ,p_primary_uom                     IN            VARCHAR2
              ,p_confirmed_lots                  IN            VARCHAR2
              ,p_confirmed_lot_trx_qty           IN            VARCHAR2
              ,p_confirmed_serials               IN            VARCHAR2
              ,p_serial_allocated_flag           IN            VARCHAR2
              ,p_lpn_match                       IN            NUMBER
              ,p_lpn_match_lpn_id                IN            NUMBER
              ,p_confirmed_sec_uom               IN            VARCHAR2
              ,p_confirmed_sec_qty               IN            VARCHAR2
              ,p_lot_controlled                  IN            VARCHAR2  -- Y/N
              ,p_serial_controlled               IN            VARCHAR2  -- Y/N
              ,p_exception                       IN            VARCHAR2 -- SHORT/OVER
              ,x_return_status                   OUT NOCOPY    VARCHAR2
              ,x_msg_count                       OUT NOCOPY    NUMBER
              ,x_msg_data                        OUT NOCOPY    VARCHAR2
	      ,p_substitute_lots		 IN	       VARCHAR2) --/* Bug 9448490 Lot Substitution Project */
IS
   l_proc_name                         VARCHAR2(30) :=  'PROC_PROCESS_CONFIRMED_LOTS';
   l_progress                          VARCHAR2(30) :=  '100';
   l_delimiter                         VARCHAR2(30) :=  ':';
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   l_prev_lot_number                   VARCHAR2(80) :=  '@@@';
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   l_lot_number                        VARCHAR2(80) :=  NULL;
   l_lot_trx_qty                       NUMBER       :=  NULL;
   l_lot_prim_qty                      NUMBER       :=  NULL;
   l_lot_sugg_qty                      NUMBER       :=  NULL;
   l_original_lot_prim_qty             NUMBER       :=  NULL;
   l_serial_transaction_temp_id        NUMBER       :=  NULL;
   l_mtlt_serial_temp_id               NUMBER       :=  NULL;
   --/* Bug 9448490 Lot Substitution Project */ start
   l_lot_number_ls                     VARCHAR2(30)	 :=  NULL;
   l_lot_trx_qty_ls                    NUMBER       :=  NULL;
   l_lot_prim_qty_ls                   NUMBER       :=  NULL;
   l_return_status_ls		       VARCHAR2(30)  :=  NULL;

   l_ls_temp_id			       NUMBER       :=  NULL;
   l_ls_lot_number		       VARCHAR2(30) :=  NULL;
   l_ls_lot_trx_qty		       NUMBER       :=  NULL;
   l_ls_lot_prim_qty		       NUMBER       :=  NULL;
   --/* Bug 9448490 Lot Substitution Project */ end


   CURSOR  cur_mtlt_to_copy_from (p_lot_number                VARCHAR2
                                 ,p_lot_transaction_temp_id   NUMBER )  IS
   SELECT  mtlt.*
   FROM    mtl_transaction_lots_temp mtlt
   WHERE   transaction_temp_id = p_lot_transaction_temp_id
   AND     lot_number = p_lot_number;

   l_rec_mtlt_to_copy_from     mtl_transaction_lots_temp%ROWTYPE;

   CURSOR  cur_confirmed_lots_serials  IS
   SELECT  DISTINCT              -- so that we get only lot records in case of lot+Serial item control
           lot_number
          ,transaction_temp_id
          ,serial_number
          ,transaction_quantity
          ,primary_quantity
          ,suggested_quantity
          ,secondary_quantity
     FROM  mtl_allocations_gtmp
    ORDER BY
           transaction_temp_id
          ,lot_number;

  --/* Bug 9448490 Lot Substitution Project */ start
        CURSOR cur_ins_mtlt_lot_sub(p_lot_transaction_temp_id NUMBER) IS
	SELECT lot_number, transaction_quantity, primary_quantity
	FROM mtl_allocations_gtmp
	WHERE lot_number NOT IN (SELECT DISTINCT lot_number
				 FROM mtl_transaction_lots_temp
				 WHERE transaction_temp_id = p_lot_transaction_temp_id)
	ORDER BY lot_number;

	CURSOR cur_mtlts_deleted_ls IS
	SELECT mtlt.transaction_temp_id, mtlt.lot_number, mtlt.primary_quantity FROM mtl_transaction_lots_temp mtlt
		WHERE mtlt.lot_number NOT IN (SELECT mag.lot_number FROM mtl_allocations_gtmp mag)
		AND mtlt.transaction_temp_id = p_transaction_temp_id;

  --/* Bug 9448490 Lot Substitution Project */ end

BEGIN
     /*  MMTT management
      Action    l_insert        L_update        update orginalMMTT      UpdMergeMMTT    InsertNewMMTT
      -----------------------------------------------------------------------------------------------
      SPLIT     Y               Y1              N                       N               Y
      SPLIT     N               Y2              Y                       Y               N
      LOAD_M    N               Y1              Y                       N               N
      LOAD_M    N               Y2              Y-Delete                Y               N
      LOAD_S    N               Y1              Y                       N               N

      ****MTLT ****
      Action    l_insert        L_update        update orginalMTLT      UpdMergeMTLT
      -----------------------------------------------------------------------------------------------
      SPLIT     Y               Y1              Y-upd original OR       N
                                                 -ins new/upd orig
      SPLIT     N               Y2              Y                       Y if MTLT exist
                                                                        OR ins new/upd orig
      LOAD_M    N               Y1              N                       N
      LOAD_M    N               Y2              Y                       Y if MTLT exist
                                                                        OR ins new/upd orig
      LOAD_S    N               Y1              N-not necessary         N

      */

   x_return_status  := l_g_ret_sts_success;
   mydebug ('In  :' || l_proc_name );
   mydebug ('p_action                 = ' || p_action                 );
   mydebug ('p_insert                 = ' || p_insert                 );
   mydebug ('p_update                 = ' || p_update                 );
   mydebug ('p_transaction_header_id  = ' || p_transaction_header_id  );
   mydebug ('p_transaction_temp_id    = ' || p_transaction_temp_id    );
   mydebug ('p_new_transaction_temp_id= ' || p_new_transaction_temp_id);
   mydebug ('p_transaction_temp_id_to_merge = ' || p_transaction_temp_id_to_merge    );
   mydebug ('p_inventory_item_id      = ' || p_inventory_item_id  );
   mydebug ('p_revision               = ' || p_revision           );
   mydebug ('p_suggested_uom          = ' || p_suggested_uom      );
   mydebug ('p_primary_uom            = ' || p_primary_uom        );
   mydebug ('p_confirmed_uom          = ' || p_confirmed_uom      );
   mydebug ('p_confirmed_lots      = ' || p_confirmed_lots  );
   mydebug ('p_confirmed_lot_trx_qty      = ' || p_confirmed_lot_trx_qty  );
   mydebug ('p_confirmed_serials      = ' || p_confirmed_serials  );
   mydebug ('p_serial_allocated_flag  = ' || p_serial_allocated_flag  );
   mydebug ('p_lpn_match              = ' || p_lpn_match              );
   mydebug ('p_lpn_match_lpn_id       = ' || p_lpn_match_lpn_id         );
   mydebug ('p_exception       = ' || p_exception         );


  --/* Bug 9448490 Lot Substitution Project */ start
  IF p_lot_controlled = 'Y' AND  p_serial_controlled = 'N'  THEN
        BEGIN
        proc_decrement_allocated_mtlts(p_transaction_temp_id, p_substitute_lots, x_return_status);
        EXCEPTION
        WHEN OTHERS THEN
        IF l_return_status_ls <> l_g_ret_sts_success THEN
        mydebug('WMS_TASK_LOAD.proc_process_confirmed_lots - Exception is raised while calling proc_decrement_allocated_mtlts');
        RAISE fnd_api.G_EXC_ERROR;
        END IF;
        END;

        OPEN cur_ins_mtlt_lot_sub(p_transaction_temp_id);
        LOOP
        FETCH cur_ins_mtlt_lot_sub INTO l_lot_number_ls, l_lot_trx_qty_ls, l_lot_prim_qty_ls;
        EXIT WHEN cur_ins_mtlt_lot_sub%NOTFOUND;
        l_g_isLotSubstitutionOK := 1;
        mydebug('Inserting into MTLT - p_transaction_temp_id-' || p_transaction_temp_id);
        mydebug('Inserting into MTLT - l_lot_prim_qty_ls-' || l_lot_prim_qty_ls);
        mydebug('Inserting into MTLT - l_lot_trx_qty_ls-' || l_lot_trx_qty_ls);
        mydebug('Inserting into MTLT - l_lot_number_ls-' || l_lot_number_ls);
        mydebug('Inserting into MTLT - p_inventory_item_id-' || p_inventory_item_id);
        mydebug('Inserting into MTLT - p_organization_id-' || p_organization_id);

        insert_mtlt (
        p_new_temp_id => p_transaction_temp_id
        , p_serial_temp_id  => NULL
        , p_pri_att_qty    => l_lot_prim_qty_ls
        , p_trx_att_qty    => l_lot_trx_qty_ls
        , p_lot_number     => l_lot_number_ls
        , p_item_id        => p_inventory_item_id
        , p_organization_id =>  p_organization_id
        , x_return_status   => l_return_status_ls) ;
        mydebug('Inserting into MTLT - l_return_status_ls-' || l_return_status_ls);

        IF l_return_status_ls <> l_g_ret_sts_success THEN
        RAISE fnd_api.G_EXC_ERROR;
        END IF;
        END LOOP;
        CLOSE cur_ins_mtlt_lot_sub;

IF (p_action = 'LOAD_SINGLE'  AND p_insert = 'N' AND l_g_isLotSubstitutionOK = 1) THEN
	OPEN cur_mtlts_deleted_ls;
	LOOP
	     FETCH cur_mtlts_deleted_ls INTO l_ls_temp_id, l_ls_lot_number, l_ls_lot_prim_qty;
	     EXIT WHEN cur_mtlts_deleted_ls%NOTFOUND;
	     mydebug('proc_process_confirmed_lots - Deleting the following MTLT record - ');
	     mydebug('proc_process_confirmed_lots - l_ls_temp_id -' || l_ls_temp_id);
	     mydebug('proc_process_confirmed_lots - l_ls_lot_number -' || l_ls_lot_number);
	     mydebug('proc_process_confirmed_lots - l_ls_lot_prim_qty' || l_ls_lot_prim_qty);
	END LOOP;
	CLOSE cur_mtlts_deleted_ls;

	DELETE FROM mtl_transaction_lots_temp mtlt
	WHERE mtlt.lot_number NOT IN (SELECT lot_number FROM mtl_allocations_gtmp)
	AND mtlt.transaction_temp_id = p_transaction_temp_id;
	--Debug stmts
END IF;
END IF;
  --/* Bug 9448490 Lot Substitution Project */ end

   FOR  rec_confirmed_lots_serials  IN cur_confirmed_lots_serials
   LOOP
          mydebug('Group_number         : ' || rec_confirmed_lots_serials.transaction_temp_id);
          mydebug('lot_number           : ' || rec_confirmed_lots_serials.lot_number);
          mydebug('Serial_number        : ' || rec_confirmed_lots_serials.serial_number);
          mydebug('Transaction_quantity : ' || rec_confirmed_lots_serials.transaction_Quantity);
          mydebug('Primary_quantity     : ' || rec_confirmed_lots_serials.primary_quantity);
          mydebug('suggested_quantity   : ' || rec_confirmed_lots_serials.suggested_quantity);
          mydebug('Secondary_quantity   : ' || rec_confirmed_lots_serials.Secondary_quantity);
          -- Get lot record details that is attached to the original p_transaction_temp_id
          -- Only p_insert = y means a new MMTT is created and therefore new MTLT will have to
          -- be created.

      IF l_prev_lot_number <> rec_confirmed_lots_serials.lot_number
      THEN
          l_prev_lot_number := rec_confirmed_lots_serials.lot_number ;
          IF p_insert = 'Y' or p_update = 'Y2' THEN
             -- we need this only if we ever need to create a new MTLT
             FOR rec_mtlt_to_copy_from  IN cur_mtlt_to_copy_from
                           (p_lot_number                => rec_confirmed_lots_serials.lot_number,
                            p_lot_transaction_temp_id   => p_transaction_temp_id)
             LOOP
                l_progress    :=  '150';
                mydebug ('In  :  rec_mtlt_to_copy_from cursor' );
                l_rec_mtlt_to_copy_from := rec_mtlt_to_copy_from;
                --l_original_lot_prim_qty := rec_mtlt_to_copy_from.primary_quantity;
                EXIT;
             END LOOP;

             l_progress    :=  '160';
             mydebug ('l_rec_mtlt_to_copy_from.transaction_temp_id: ' ||
                       l_rec_mtlt_to_copy_from.transaction_temp_id);
             mydebug ('l_rec_mtlt_to_copy_from.serial_transaction_temp_id:' ||
                          l_rec_mtlt_to_copy_from.serial_transaction_temp_id );
             IF  l_rec_mtlt_to_copy_from.transaction_temp_id IS NULL
             THEN
                l_progress    :=  '170';
                -- lot record attached to the original MMTT should have been found
                RAISE fnd_api.G_EXC_ERROR;
             END IF;

          END IF;
          l_progress    :=  '175';
          -- For lot + serial controlled items
          IF   p_serial_controlled     = 'Y'
          THEN
             l_mtlt_serial_temp_id := l_rec_mtlt_to_copy_from.serial_transaction_temp_id;

             SELECT mtl_material_transactions_s.NEXTVAL
               INTO l_serial_transaction_temp_id
               FROM DUAL;
          ELSE
             l_serial_transaction_temp_id   := NULL;
             l_mtlt_serial_temp_id := NULL;
          END IF;

          mydebug ('l_mtlt_serial_temp_id: ' || l_mtlt_serial_temp_id);
          mydebug ('l_serial_transaction_temp_id: ' || l_serial_transaction_temp_id);
          l_progress    :=  '180';
          mydebug ('p_insert: ' || p_insert);
          IF p_insert = 'Y' THEN
             l_progress    :=  '190';
             IF  l_rec_mtlt_to_copy_from.primary_quantity <= rec_confirmed_lots_serials.primary_quantity THEN
                 -- lot qty in the selected, in the above cursor, MTLT equals qty that is needed for the new MTLT
                 -- update the MTLT with new temp id  instead of inserting a new and then deleting the old one
                 l_progress    :=  '200';
                 mydebug('l_progress: ' || l_progress );
                 UPDATE mtl_transaction_lots_temp
                 SET    transaction_temp_id        = p_new_transaction_temp_id
                      , transaction_quantity       = rec_confirmed_lots_serials.transaction_Quantity
                      , primary_quantity           = rec_confirmed_lots_serials.primary_quantity
                      , secondary_quantity         = rec_confirmed_lots_serials.secondary_quantity
                      , secondary_unit_of_measure  = p_confirmed_sec_uom
                      , serial_transaction_temp_id = l_serial_transaction_temp_id
                      , last_update_date           = SYSDATE
                      , last_updated_by            = p_user_id
                 WHERE  transaction_temp_id        = l_rec_mtlt_to_copy_from.transaction_temp_id
                 AND    lot_number                 = rec_confirmed_lots_serials.lot_number;
                 IF SQL%NOTFOUND THEN
                     RAISE fnd_api.G_EXC_ERROR;
                 END IF;
             ELSE
                 -- insert a new MTLT
                 l_progress    :=  '210';
                 mydebug('l_progress: ' || l_progress );
                 l_rec_mtlt_to_copy_from.transaction_quantity  := rec_confirmed_lots_serials.transaction_Quantity ;
                 l_rec_mtlt_to_copy_from.primary_quantity      := rec_confirmed_lots_serials.primary_quantity ;
                 l_rec_mtlt_to_copy_from.secondary_quantity    := rec_confirmed_lots_serials.secondary_quantity ;
                 l_rec_mtlt_to_copy_from.secondary_unit_of_measure    := p_confirmed_sec_uom;
                 l_rec_mtlt_to_copy_from.created_by            := p_user_id;
                 l_rec_mtlt_to_copy_from.transaction_temp_id   := p_new_transaction_temp_id;
                 -- For lot + serial controlled items
                 l_rec_mtlt_to_copy_from.serial_transaction_temp_id := l_serial_transaction_temp_id;
                 proc_insert_mtlt
                     (p_lot_record                      => l_rec_mtlt_to_copy_from
                     ,x_return_status                   => x_return_status
                     ,x_msg_count                       => x_msg_count
                     ,x_msg_data                        => x_msg_data);
                 mydebug('x_return_status : ' || x_return_status);
                 IF x_return_status <> l_g_ret_sts_success THEN
                     RAISE fnd_api.G_EXC_ERROR;
                 END IF;
                 mydebug('l_progress: ' || l_progress );
                 l_progress    :=  '220';
                 -- If new MTLT is inserted for p_new_transaction_temp_id this means
                 -- the original MTLT still has some qty remaining...so update it.
                 -- the original MTLT need not be adjusted for secondary quantity.
       -- It is not expected to be populated
                 UPDATE  mtl_transaction_lots_temp
                 SET     transaction_quantity     = transaction_quantity - rec_confirmed_lots_serials.suggested_quantity
                        ,primary_quantity         = primary_quantity - rec_confirmed_lots_serials.primary_quantity
        ,secondary_quantity       = NVL(secondary_quantity, rec_confirmed_lots_serials.secondary_quantity) - rec_confirmed_lots_serials.secondary_quantity
                        ,last_update_date         = SYSDATE
                        ,last_updated_by          = p_user_id
                 WHERE   transaction_temp_id      = p_transaction_temp_id
                 AND     lot_number = rec_confirmed_lots_serials.lot_number;
                 IF SQL%NOTFOUND THEN
                     RAISE fnd_api.G_EXC_ERROR;
                 END IF;
                 mydebug('l_progress: ' || l_progress );
             END IF;
          END IF;

          l_progress    :=  '230';
          mydebug ('p_update: ' || p_update);
          -- p_update = 'Y2' means, p_insert = N which means that current MMTT (in this call)
          -- was merged with another existing MMTT. In this case, it is possible that existing MMTT already has
          -- MTLT record for this lot number. If this is the case then update the MTLT otherwise ,
          -- insert a new MTLT  using l_rec_mtlt_to_copy_from from the above cursor
          IF p_update = 'Y2'
          THEN
             l_progress    :=  '240';
             mydebug('l_progress: ' || l_progress );
             UPDATE   mtl_transaction_lots_temp
             SET      transaction_quantity       = transaction_quantity +
                                                   rec_confirmed_lots_serials.transaction_Quantity
                     ,primary_quantity           = primary_quantity + rec_confirmed_lots_serials.primary_quantity
                     ,secondary_quantity         = secondary_quantity+ rec_confirmed_lots_serials.secondary_quantity
                     ,last_update_date           = SYSDATE
                     ,last_updated_by            = p_user_id
             WHERE   transaction_temp_id = p_transaction_temp_id_to_merge
             AND     lot_number          = rec_confirmed_lots_serials.lot_number
             -- For lot + serial controlled items
             RETURNING serial_transaction_temp_id INTO l_serial_transaction_temp_id;

             mydebug ('returned value - l_serial_transaction_temp_id: ' || l_serial_transaction_temp_id);
             IF SQL%NOTFOUND THEN
                IF  l_rec_mtlt_to_copy_from.primary_quantity = rec_confirmed_lots_serials.primary_quantity THEN
                    -- lot qty in the selected MTLT = qty that is needed for the new MTLT
                    --update the MTLT with new temp id  instead of inserting a new and then deleting the old one
                    l_progress    :=  '250';
                    mydebug('l_progress: ' || l_progress );
                    UPDATE mtl_transaction_lots_temp
                    SET    transaction_temp_id = p_transaction_temp_id_to_merge --p_new_transaction_temp_id
                         , secondary_quantity  = rec_confirmed_lots_serials.secondary_quantity
                         , secondary_unit_of_measure  = p_confirmed_sec_uom
                           -- For lot + serial controlled items
                         , serial_transaction_temp_id = l_serial_transaction_temp_id
                         , last_update_date    = SYSDATE
                         , last_updated_by     = p_user_id
                    WHERE  transaction_temp_id = l_rec_mtlt_to_copy_from.transaction_temp_id
                    AND    lot_number = rec_confirmed_lots_serials.lot_number;
                    IF SQL%NOTFOUND THEN
                        RAISE fnd_api.G_EXC_ERROR;
                    END IF;
                ELSE
                   l_progress    :=  '260';
                   mydebug('l_progress: ' || l_progress );
                   l_rec_mtlt_to_copy_from.transaction_quantity := rec_confirmed_lots_serials.transaction_Quantity ;
                   l_rec_mtlt_to_copy_from.primary_quantity     := rec_confirmed_lots_serials.primary_quantity ;
                   l_rec_mtlt_to_copy_from.secondary_quantity   := rec_confirmed_lots_serials.secondary_quantity;
                   l_rec_mtlt_to_copy_from.transaction_temp_id  := p_transaction_temp_id_to_merge;
                   -- For lot + serial controlled items
                   l_rec_mtlt_to_copy_from.serial_transaction_temp_id  := l_serial_transaction_temp_id;
                   l_rec_mtlt_to_copy_from.created_by        := p_user_id;
                   proc_insert_mtlt
                       (p_lot_record                      => l_rec_mtlt_to_copy_from
                       ,x_return_status                   => x_return_status
                       ,x_msg_count                       => x_msg_count
                       ,x_msg_data                        => x_msg_data);
                   IF x_return_status <> l_g_ret_sts_success THEN
                       mydebug('x_return_status : ' || x_return_status);
                       RAISE fnd_api.G_EXC_ERROR;
                   END IF;
                   L_progress    :=  '270';
                   mydebug('l_progress: ' || l_progress );
                   -- If new MTLT is inserted for p_transaction_temp_id_to_merge this means
                   -- the original MTLT still has some qty remaining...so update it.
                   UPDATE  mtl_transaction_lots_temp
                   SET     transaction_quantity     = transaction_quantity -
                                                      rec_confirmed_lots_serials.suggested_Quantity
                          ,primary_quantity         = primary_quantity -
                                                      rec_confirmed_lots_serials.primary_quantity
          ,secondary_quantity       = NVL(secondary_quantity, rec_confirmed_lots_serials.secondary_quantity) - rec_confirmed_lots_serials.secondary_quantity
                          ,last_update_date         = SYSDATE
                          ,last_updated_by          = p_user_id
                   WHERE   transaction_temp_id = p_transaction_temp_id --  l_rec_mtlt_to_copy_from.transaction_temp_id
                   AND     lot_number          = rec_confirmed_lots_serials.lot_number;
                   IF SQL%NOTFOUND THEN
                        RAISE fnd_api.G_EXC_ERROR;
                   END IF;
                END IF;
             ELSE  -- found mtlt for the current lot number attached to p_transaction_temp_id_to_merge
                L_progress    :=  '280';
                mydebug('l_progress: ' || l_progress );
                -- if the quantity in mtlt of orginal p_tranaction_temp_id  is equal to the qty confirmed for this lot
                -- and we merged the current lot qty with an existing mtlt record then we do not need this mtlt.
                -- delete it.
                IF  l_rec_mtlt_to_copy_from.primary_quantity = rec_confirmed_lots_serials.primary_quantity THEN
                   L_progress    :=  '290';
                   mydebug('l_progress: ' || l_progress );
                   -- If all the qty from the original  MTLT is consumed and merged to the
                   -- p_transaction_temp_id_to_merge we do not need the original MTLT ..delete it
                   DELETE  mtl_transaction_lots_temp
                   WHERE   transaction_temp_id = p_transaction_temp_id -- l_rec_mtlt_to_copy_from.transaction_temp_id
                   AND     lot_number          = rec_confirmed_lots_serials.lot_number;
                   IF SQL%NOTFOUND THEN
                         RAISE fnd_api.G_EXC_ERROR;
                   END IF;
                ELSE
                   -- If all the qty from the original MTLT is not consumed then update the original MTLT
                   -- attached to p_transaction_temp_id .. as selected in the cursor above
                   L_progress    :=  '300';
                   mydebug('l_progress: ' || l_progress );
                   UPDATE  mtl_transaction_lots_temp
                   SET     transaction_quantity     = transaction_quantity - rec_confirmed_lots_serials.suggested_Quantity
                           ,primary_quantity        = primary_quantity - rec_confirmed_lots_serials.primary_quantity
         ,secondary_quantity      = NVL(secondary_quantity, rec_confirmed_lots_serials.secondary_quantity) -
                  rec_confirmed_lots_serials.secondary_quantity
                           ,last_update_date        = SYSDATE
                           ,last_updated_by         = p_user_id
                   WHERE   transaction_temp_id = p_transaction_temp_id -- l_rec_mtlt_to_copy_from.transaction_temp_id
                   AND     lot_number          = rec_confirmed_lots_serials.lot_number;
                   IF SQL%NOTFOUND THEN
                      RAISE fnd_api.G_EXC_ERROR;
                   END IF;
                END IF;
             END IF;
          END IF;
          /* Usually for p_update = 'Y1' one does not need to update MTLT since nothing would have changed
             But, for catch weight enabled items, it is necessary */
          /* If serials are not allocateed and lpn_match = 1/3 , MSNT records need to be populated
             so, update serial_transaction_temp_id  mtlt*. MSNT gets created in process_confirmed_serials */
          IF (p_update = 'Y1' AND
              p_insert = 'N'  AND
              p_serial_controlled     = 'Y'        AND
              p_serial_allocated_flag = 'N'        AND
              p_confirmed_serials     IS NULL      AND
              p_lpn_match             IN (1,3) )
          THEN
              l_progress    :=  '350';
              mydebug('l_progress: ' || l_progress );
              UPDATE   mtl_transaction_lots_temp
              SET
                      transaction_quantity       = rec_confirmed_lots_serials.transaction_quantity  --jxlu
                     ,primary_quantity           = rec_confirmed_lots_serials.primary_quantity      --jxlu
                     ,secondary_quantity         = rec_confirmed_lots_serials.secondary_quantity
                     ,secondary_unit_of_measure  = p_confirmed_sec_uom
                     ,serial_transaction_temp_id = l_serial_transaction_temp_id
                     ,last_update_date           = SYSDATE
                     ,last_updated_by            = p_user_id
              WHERE   transaction_temp_id = p_transaction_temp_id
              AND     lot_number          = rec_confirmed_lots_serials.lot_number;
              IF SQL%NOTFOUND THEN
                 RAISE fnd_api.G_EXC_ERROR;
              END IF;
          ELSE
          /* Usually for p_update = 'Y1' one does not need to update MTLT since nothing would have changed
             But, for catch weight enabled items, Overpicking or changed TXN-UOM it is necessary
             */
          /* following condition is independent of the above condition in that :
 *             for serial controlled items, UOM cannot be different from primary
 *             UOM (atleast as of this patchset (11.5.10)) .
 *             for lpn_match 1,3 , it cannot be a case of overpick. */
          IF (p_update = 'Y1' AND
              p_insert = 'N' ) AND
              (p_confirmed_sec_qty is NOT NULL   OR
               p_confirmed_uom <> p_primary_uom  OR
               p_exception = 'OVER')
          THEN
              l_progress    :=  '360';
              mydebug('l_progress: ' || l_progress );
              UPDATE   mtl_transaction_lots_temp
              SET
                      transaction_quantity       = rec_confirmed_lots_serials.transaction_quantity
                     ,primary_quantity           = rec_confirmed_lots_serials.primary_quantity
                     ,secondary_quantity         = rec_confirmed_lots_serials.secondary_quantity
                     ,secondary_unit_of_measure  = p_confirmed_sec_uom
                     ,last_update_date           = SYSDATE
                     ,last_updated_by            = p_user_id
              WHERE   transaction_temp_id = p_transaction_temp_id
              AND     lot_number          = rec_confirmed_lots_serials.lot_number;
              IF SQL%NOTFOUND THEN
                 RAISE fnd_api.G_EXC_ERROR;
              END IF;
          END IF;
          END IF;

          -- For lot + serial controlled items, process serials for the given lot now
          L_progress    :=  '400';
          mydebug('l_progress: ' || l_progress );
          mydebug('rec_confirmed_lots_serials.serial_number: ' || rec_confirmed_lots_serials.serial_number );
          --IF  rec_confirmed_lots_serials.serial_number IS NOT NULL
          IF  p_serial_controlled     = 'Y'
          THEN
              L_progress    :=  '410';
              mydebug('l_progress: ' || l_progress );
              -- update all serial records with the serial_transaction_temp_id to be populated
              UPDATE  mtl_allocations_gtmp
                 SET  child_transaction_temp_id = l_serial_transaction_temp_id
               WHERE  lot_number          = rec_confirmed_lots_serials.lot_number
                 AND  transaction_temp_id = rec_confirmed_lots_serials.transaction_temp_id  ;
              IF SQL%NOTFOUND THEN
                 RAISE fnd_api.G_EXC_ERROR;
              END IF;
              L_progress    :=  '420';
              mydebug('l_progress: ' || l_progress );
              proc_process_confirmed_serials
                      (p_action                               =>  p_action
                      ,p_insert                               =>  p_insert
                      ,p_update                               =>  p_update
                      ,p_organization_id                      =>  p_organization_id
                      ,p_user_id                              =>  p_user_id
                      ,p_transaction_header_id                =>  p_transaction_header_id
                      ,p_transaction_temp_id                  =>  p_transaction_temp_id
                      ,p_new_transaction_temp_id              =>  p_new_transaction_temp_id --??l_serial_transaction_temp_id
                      ,p_transaction_temp_id_to_merge         =>  p_transaction_temp_id_to_merge
                      ,p_serial_transaction_temp_id           =>  l_serial_transaction_temp_id
                      ,p_mtlt_serial_temp_id                  =>  l_mtlt_serial_temp_id
                      ,p_inventory_item_id                    =>  p_inventory_item_id
                      ,p_revision                             =>  p_revision
                      ,p_suggested_uom                        =>  p_suggested_uom
                      ,p_confirmed_uom                        =>  p_confirmed_uom
                      ,p_primary_uom                          =>  p_primary_uom
                      ,p_serial_lot_number                    =>  rec_confirmed_lots_serials.lot_number
                      ,p_confirmed_serials                    =>  p_confirmed_serials
                      ,p_serial_allocated_flag                =>  p_serial_allocated_flag
                      ,p_lpn_match                            =>  p_lpn_match
                      ,p_lpn_match_lpn_id                     =>  p_lpn_match_lpn_id
                      ,p_lot_controlled                       =>  p_lot_controlled
                      ,p_serial_controlled                    =>  p_serial_controlled
                      ,x_return_status                        =>  x_return_status
                      ,x_msg_count                            =>  x_msg_count
                      ,x_msg_data                             =>  x_msg_data);
              IF x_return_status <> l_g_ret_sts_success THEN
                  RAISE fnd_api.G_EXC_ERROR;
              END IF;
          END IF;
      END IF; --  l_prev_lot_number <> rec_confirmed_lots_serials.lot_number
      L_progress    :=  '430';
      mydebug('l_progress: ' || l_progress );
   END LOOP; --rec_confirmed_lots_serials  IN cur_confirmed_lots_serials
   mydebug('End ..  ' || l_proc_name);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('fnd_api.g_exc_error: ' || SQLERRM);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('fnd_api.g_exc_error: ' || SQLERRM);
        mydebug('ROLLBACK ' );
        ROLLBACK ;

END proc_process_confirmed_lots;

PROCEDURE proc_process_confirmed_serials
             ( p_action                          IN            VARCHAR2
              ,p_insert                          IN            VARCHAR2
              ,p_update                          IN            VARCHAR2
              ,p_organization_id                 IN            NUMBER
              ,p_user_id                         IN            NUMBER
              ,p_transaction_header_id           IN            NUMBER
              ,p_transaction_temp_id             IN            NUMBER
              ,p_new_transaction_temp_id         IN            NUMBER
              ,p_transaction_temp_id_to_merge    IN            NUMBER
              ,p_serial_transaction_temp_id      IN            NUMBER
              ,p_mtlt_serial_temp_id             IN            NUMBER
              ,p_inventory_item_id               IN            NUMBER
              ,p_revision                        IN            VARCHAR2
              ,p_suggested_uom                   IN            VARCHAR2
              ,p_confirmed_uom                   IN            VARCHAR2
              ,p_primary_uom                     IN            VARCHAR2
              ,p_serial_lot_number               IN            VARCHAR2
              ,p_confirmed_serials               IN            VARCHAR2
              ,p_serial_allocated_flag           IN            VARCHAR2
              ,p_lpn_match                       IN            NUMBER
              ,p_lpn_match_lpn_id                IN            NUMBER
              ,p_lot_controlled                  IN            VARCHAR2  -- Y/N
              ,p_serial_controlled               IN            VARCHAR2  -- Y/N
              ,x_return_status                   OUT NOCOPY    VARCHAR2
              ,x_msg_count                       OUT NOCOPY    NUMBER
              ,x_msg_data                        OUT NOCOPY    VARCHAR2)
IS
   l_proc_name                        VARCHAR2(30) :=  'PROC_PROCESS_CONFIRMED_SERIALS';
   l_progress                         VARCHAR2(30) :=  '100';
   l_delimiter                        VARCHAR2(30) :=  ':';
   l_serial_number                    VARCHAR2(30) :=  NULL;
   l_n_msnt_transaction_temp_id       NUMBER;
   l_o_msnt_transaction_temp_id       NUMBER;
   l_msnt_record                      MTL_SERIAL_NUMBERS_TEMP%ROWTYPE;
   m                                  NUMBER := 1;  -- position of delimiter
   n                                  NUMBER := 1;  -- Start position for substr or search for delimiter
   CURSOR  cur_confirmed_serials  IS
   SELECT  transaction_temp_id
          ,lot_number
          ,serial_number
          ,transaction_quantity
          ,primary_quantity
     FROM  mtl_allocations_gtmp
    WHERE  NVL(lot_number,'@@') = nvl(p_serial_lot_number,'@@')
    ORDER BY
           transaction_temp_id
          --,nvl(lot_number,'@@')
          ,serial_number;

BEGIN
       /*  MMTT management
      Action    l_insert        L_update        update orginalMMTT      UpdMergeMMTT    InsertNewMMTT
      -----------------------------------------------------------------------------------------------
      SPLIT     Y               Y1              N                       N               Y
      SPLIT     N               Y2              Y                       Y               N
      LOAD_M    N               Y1              Y                       N               N
      LOAD_M    N               Y2              Y-Delete                Y               N
      LOAD_S    N               Y1              Y                       N               N

      ****MSNT ****
      Action    l_insert        L_update        update orginalMSNT
      -----------------------------------------------------------------------------------------------
      SPLIT     Y               Y1              Y-set temp_id = new temp_id
      SPLIT     N               Y2              Y-set temp_id= merge temp_id
      LOAD_M    N               Y1              N
      LOAD_M    N               Y2              Y-set temp_id= merge temp_id
      LOAD_S    N               Y1              N-not necessary
      */

   mydebug ('In : ' || l_proc_name);
   mydebug ('p_action                 = ' || p_action                 );
   mydebug ('p_insert                 = ' || p_insert                 );
   mydebug ('p_update                 = ' || p_update                 );
   mydebug ('p_transaction_header_id  = ' || p_transaction_header_id  );
   mydebug ('p_transaction_temp_id    = ' || p_transaction_temp_id    );
   mydebug ('p_new_transaction_temp_id= ' || p_new_transaction_temp_id);
   mydebug ('p_transaction_temp_id_to_merge = ' || p_transaction_temp_id_to_merge    );
   mydebug ('p_serial_transaction_temp_id = ' || p_serial_transaction_temp_id    );
   mydebug ('p_mtlt_serial_temp_id = ' || p_mtlt_serial_temp_id    );
   mydebug ('p_inventory_item_id      = ' || p_inventory_item_id  );
   mydebug ('p_revision               = ' || p_revision           );
   mydebug ('p_suggested_uom          = ' || p_suggested_uom      );
   mydebug ('p_confirmed_uom          = ' || p_confirmed_uom      );
   mydebug ('p_primary_uom            = ' || p_primary_uom        );
   mydebug ('p_serial_lot_number      = ' || p_serial_lot_number      );
   mydebug ('p_confirmed_serials      = ' || p_confirmed_serials  );
   mydebug ('p_serial_allocated_flag  = ' || p_serial_allocated_flag  );
   mydebug ('p_lpn_match              = ' || p_lpn_match              );
   mydebug ('p_lpn_match_lpn_id       = ' || p_lpn_match_lpn_id         );
   mydebug ('p_lot_controlled         = ' || p_lot_controlled         );
   mydebug ('p_serial_controlled      = ' || p_serial_controlled         );

   x_return_status  := l_g_ret_sts_success;
   -- No more serials in the string p_confirmed_serials
    mydebug ('process serials: ' );
   IF (p_serial_transaction_temp_id IS NOT NULL ) -- it is a case of lot + serial
                                                  -- and the call came from process_confirmed_lots
   THEN
       l_n_msnt_transaction_temp_id := p_serial_transaction_temp_id;
       l_o_msnt_transaction_temp_id := p_mtlt_serial_temp_id;
   ELSE
       l_o_msnt_transaction_temp_id :=p_transaction_temp_id;
      IF (p_insert = 'Y' ) THEN
          l_n_msnt_transaction_temp_id := p_new_transaction_temp_id;
          -- if a new mmtt ininserted then the MSNT
          -- should be attached to p_new_transaction_temp_id
      ELSE
         IF p_update = 'Y2' THEN
             l_n_msnt_transaction_temp_id := p_transaction_temp_id_to_merge;
             -- if current task is merged to an existing MMTT then the MSNT
             -- should be attached to p_transaction_temp_id_to_merge
         END IF;
         IF (p_update = 'Y1' ) THEN
               l_n_msnt_transaction_temp_id := p_transaction_temp_id; -- original MMTT
               --  and this will be used only if we are inserting MSNTs for
               -- no allocated serIals
         END IF;
      END IF;
   END IF;
   mydebug ('l_o_msnt_transaction_temp_id      = ' || l_o_msnt_transaction_temp_id         );
   mydebug ('l_n_msnt_transaction_temp_id      = ' || l_n_msnt_transaction_temp_id         );

   IF  p_confirmed_serials IS NOT NULL     AND
       (p_insert = 'Y'  OR p_update = 'Y2')
   THEN
      -- AND ( p_serial_allocated_flag = 'Y'))
      /* If serials are allocted then MSNT records will be associated with p_transaction_temp_id.
         If serials are not allocated but confirmed_serials is not null that means Java-UI created MSNT
            records and associated them with p_transaction_temp_id. there fore, for a case of SPLIT
            (leading to Merge or split) these MSNT records have to be moved to the confirmed_mmtt created.
             identified by l_n_msnt_transaction_temp_id */
       l_progress    :=  '110';
       mydebug('l_progress: ' || l_progress );
       -- update the existing msnt record and  set its transaction-temp_id = new_transaction-temp_id
       UPDATE mtl_serial_numbers_temp
          SET transaction_temp_id = l_n_msnt_transaction_temp_id
            , last_update_date    = SYSDATE
            , last_updated_by     = p_user_id
        WHERE transaction_temp_id = l_o_msnt_transaction_temp_id
          AND fm_serial_number IN
              (SELECT  serial_number
                 FROM  mtl_allocations_gtmp
                WHERE  NVL(lot_number,'@@') = nvl(p_serial_lot_number,'@@'));

       IF SQL%NOTFOUND THEN
          mydebug('msnt not updateed..');
          RAISE fnd_api.G_EXC_ERROR;
       ELSE
          l_progress    :=  '140';
          mydebug('l_progress: ' || l_progress );
          UPDATE  MTL_SERIAL_NUMBERS
             SET  group_mark_id   = l_n_msnt_transaction_temp_id
                 ,last_update_date= SYSDATE
                 ,last_updated_by = p_user_id
           WHERE  current_organization_id = p_organization_id
             AND  inventory_item_id       = p_inventory_item_id
             --AND  group_mark_id           IS NULL
             AND  serial_number           IN
                 (SELECT  serial_number
                    FROM  mtl_allocations_gtmp
                   WHERE  NVL(lot_number,'@@') = nvl(p_serial_lot_number,'@@'));

          IF SQL%NOTFOUND THEN
             RAISE fnd_api.G_EXC_ERROR;
          END IF;
       END IF;
   ELSE
      l_progress    :=  '170';
      mydebug('l_progress: ' || l_progress );
      ---(p_serial_allocated_flag = 'N' AND for allocated serials but lpn_match 1 or 3
      IF ( p_serial_allocated_flag = 'N'   AND
           p_confirmed_serials IS NULL     AND
           p_lpn_match         IN (1,3) )
         -- for non-catch weight enabled
         --( p_confirmed_serials    IS NOT NULL   AND p_serial_allocated_flag = 'N')
         -- Pick Load page will insert these MSNTs
      THEN
         l_progress    :=  '180';
         mydebug('l_progress: ' || l_progress );

         --proc_insert_msnt inserts into MSNT using the data from MSN and also marks MSN
         proc_insert_msnt (p_transaction_temp_id            => l_n_msnt_transaction_temp_id
                           ,p_organization_id               => p_organization_id
                           ,p_inventory_item_id             => p_inventory_item_id
                           ,p_revision                      => p_revision
                           ,p_confirmed_serials             => p_confirmed_serials
                           ,p_serial_number                 => NULL
                           ,p_lpn_id                        => p_lpn_match_lpn_id -- NULL if lpn_match!=(1,3)
                           ,p_serial_lot_number             => p_serial_lot_number
                           ,p_user_id                       => p_user_id
                           ,x_return_status                 => x_return_status
                           ,x_msg_count                     => x_msg_count
                           ,x_msg_data                      => x_msg_data);
         IF x_return_status <> l_g_ret_sts_success THEN
            mydebug('x_return_status : ' || x_return_status);
            RAISE fnd_api.G_EXC_ERROR;
         END IF;
      END IF;
      /* added on 05/04/04 : fully consumable lpn where serials are allocated,
       * java does not pass the confirmed serials string . The following logic takes
       * care of the same. */
      IF  p_confirmed_serials IS NULL     AND
          p_serial_allocated_flag = 'Y'   AND
          p_lpn_match         IN (1,3)    AND
         (p_insert = 'Y'  OR  p_update = 'Y2')
      THEN
         l_progress    :=  '200';
         mydebug('l_progress: ' || l_progress );

          -- update the existing msnt record and  set its transaction-temp_id = new_transaction-temp_id
          UPDATE mtl_serial_numbers_temp
             SET transaction_temp_id = l_n_msnt_transaction_temp_id
               , last_update_date    = SYSDATE
               , last_updated_by     = p_user_id
           WHERE transaction_temp_id = l_o_msnt_transaction_temp_id
             AND fm_serial_number IN
                 (SELECT  serial_number
                    FROM  mtl_serial_numbers msn
                         ,mtl_serial_numbers_temp msnt
                   WHERE  msn.serial_number = msnt.fm_serial_number
                     AND  msnt.transaction_temp_id = l_o_msnt_transaction_temp_id
                     AND  NVL(msn.lot_number,'@@') = nvl(p_serial_lot_number,'@@')
                     AND  msn.lpn_id = p_lpn_match_lpn_id);

          IF SQL%NOTFOUND THEN
             mydebug('msnt not updateed..');
             RAISE fnd_api.G_EXC_ERROR;
          ELSE
             l_progress    :=  '300';
             mydebug('l_progress: ' || l_progress );
             UPDATE  MTL_SERIAL_NUMBERS
                SET  group_mark_id   = l_n_msnt_transaction_temp_id
                    ,last_update_date= SYSDATE
                    ,last_updated_by = p_user_id
              WHERE  current_organization_id = p_organization_id
                AND  inventory_item_id       = p_inventory_item_id
                AND  serial_number IN
                 (SELECT  serial_number
                    FROM  mtl_serial_numbers msn
                         ,mtl_serial_numbers_temp msnt
                   WHERE  msn.serial_number = msnt.fm_serial_number
                     AND  msnt.transaction_temp_id = l_n_msnt_transaction_temp_id
                     AND  NVL(msn.lot_number,'@@') = nvl(p_serial_lot_number,'@@')
                     AND  msn.lpn_id = p_lpn_match_lpn_id);

             IF SQL%NOTFOUND THEN
                RAISE fnd_api.G_EXC_ERROR;
             END IF;
          END IF;
      END IF;
   END IF;
   mydebug('End ..  ' || l_proc_name);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('fnd_api.g_exc_error: ' || SQLERRM);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('fnd_api.g_exc_error: ' || SQLERRM);
        mydebug('ROLLBACK ' );
        ROLLBACK ;

END proc_process_confirmed_serials;

PROCEDURE proc_insert_mtlt
             ( p_lot_record                      IN            mtl_transaction_lots_temp%ROWTYPE
              ,x_return_status                   OUT NOCOPY    VARCHAR2
              ,x_msg_count                       OUT NOCOPY    NUMBER
              ,x_msg_data                        OUT NOCOPY    VARCHAR2)
IS
   l_proc_name                   VARCHAR2(30) :=  'PROC_INSERT_MTLT';
   l_progress                    VARCHAR2(30) :=  '100';
BEGIN
   mydebug('In.. ' || l_proc_name);
   x_return_status  := l_g_ret_sts_success;
   INSERT  INTO mtl_transaction_lots_temp
               (transaction_temp_id
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               ,request_id
               ,program_application_id
               ,program_id
               ,program_update_date
               ,transaction_quantity
               ,primary_quantity
               ,lot_number
               ,lot_expiration_date
               ,error_code
               ,serial_transaction_temp_id
               ,group_header_id
               ,put_away_rule_id
               ,pick_rule_id
               ,description
               ,vendor_id
               ,supplier_lot_number
               ,territory_code
               ,origination_date
               ,date_code
               ,grade_code
               ,change_date
               ,maturity_date
               ,status_id
               ,retest_date
               ,age
               ,item_size
               ,color
               ,volume
               ,volume_uom
               ,place_of_origin
               ,best_by_date
               ,length
               ,length_uom
               ,recycled_content
               ,thickness
               ,thickness_uom
               ,width
               ,width_uom
               ,curl_wrinkle_fold
               ,lot_attribute_category
               ,c_attribute1
               ,c_attribute2
               ,c_attribute3
               ,c_attribute4
               ,c_attribute5
               ,c_attribute6
               ,c_attribute7
               ,c_attribute8
               ,c_attribute9
               ,c_attribute10
               ,c_attribute11
               ,c_attribute12
               ,c_attribute13
               ,c_attribute14
               ,c_attribute15
               ,c_attribute16
               ,c_attribute17
               ,c_attribute18
               ,c_attribute19
               ,c_attribute20
               ,d_attribute1
               ,d_attribute2
               ,d_attribute3
               ,d_attribute4
               ,d_attribute5
               ,d_attribute6
               ,d_attribute7
               ,d_attribute8
               ,d_attribute9
               ,d_attribute10
               ,n_attribute1
               ,n_attribute2
               ,n_attribute3
               ,n_attribute4
               ,n_attribute5
               ,n_attribute6
               ,n_attribute7
               ,n_attribute8
               ,n_attribute9
               ,n_attribute10
               ,vendor_name
               ,sublot_num
               ,secondary_quantity
               ,secondary_unit_of_measure
               ,qc_grade
               ,reason_code
               ,product_code
               ,product_transaction_id
               ,attribute_category
               ,attribute1
               ,attribute2
               ,attribute3
               ,attribute4
               ,attribute5
               ,attribute6
               ,attribute7
               ,attribute8
               ,attribute9
               ,attribute10
               ,attribute11
               ,attribute12
               ,attribute13
               ,attribute14
               ,attribute15)
   VALUES (
                p_lot_record.transaction_temp_id
               ,p_lot_record.last_update_date
               ,p_lot_record.last_updated_by
               ,SYSDATE
               ,p_lot_record.created_by
               ,p_lot_record.last_update_login
               ,p_lot_record.request_id
               ,p_lot_record.program_application_id
               ,p_lot_record.program_id
               ,SYSDATE
               ,p_lot_record.transaction_quantity
               ,p_lot_record.primary_quantity
               ,p_lot_record.lot_number
               ,p_lot_record.lot_expiration_date
               ,p_lot_record.error_code
               ,p_lot_record.serial_transaction_temp_id
               ,p_lot_record.group_header_id
               ,p_lot_record.put_away_rule_id
               ,p_lot_record.pick_rule_id
               ,p_lot_record.description
               ,p_lot_record.vendor_id
               ,p_lot_record.supplier_lot_number
               ,p_lot_record.territory_code
               ,p_lot_record.origination_date
               ,p_lot_record.date_code
               ,p_lot_record.grade_code
               ,p_lot_record.change_date
               ,p_lot_record.maturity_date
               ,p_lot_record.status_id
               ,p_lot_record.retest_date
               ,p_lot_record.age
               ,p_lot_record.item_size
               ,p_lot_record.color
               ,p_lot_record.volume
               ,p_lot_record.volume_uom
               ,p_lot_record.place_of_origin
               ,p_lot_record.best_by_date
               ,p_lot_record.length
               ,p_lot_record.length_uom
               ,p_lot_record.recycled_content
               ,p_lot_record.thickness
               ,p_lot_record.thickness_uom
               ,p_lot_record.width
               ,p_lot_record.width_uom
               ,p_lot_record.curl_wrinkle_fold
               ,p_lot_record.lot_attribute_category
               ,p_lot_record.c_attribute1
               ,p_lot_record.c_attribute2
               ,p_lot_record.c_attribute3
               ,p_lot_record.c_attribute4
               ,p_lot_record.c_attribute5
               ,p_lot_record.c_attribute6
               ,p_lot_record.c_attribute7
               ,p_lot_record.c_attribute8
               ,p_lot_record.c_attribute9
               ,p_lot_record.c_attribute10
               ,p_lot_record.c_attribute11
               ,p_lot_record.c_attribute12
               ,p_lot_record.c_attribute13
               ,p_lot_record.c_attribute14
               ,p_lot_record.c_attribute15
               ,p_lot_record.c_attribute16
               ,p_lot_record.c_attribute17
               ,p_lot_record.c_attribute18
               ,p_lot_record.c_attribute19
               ,p_lot_record.c_attribute20
               ,p_lot_record.d_attribute1
               ,p_lot_record.d_attribute2
               ,p_lot_record.d_attribute3
               ,p_lot_record.d_attribute4
               ,p_lot_record.d_attribute5
               ,p_lot_record.d_attribute6
               ,p_lot_record.d_attribute7
               ,p_lot_record.d_attribute8
               ,p_lot_record.d_attribute9
               ,p_lot_record.d_attribute10
               ,p_lot_record.n_attribute1
               ,p_lot_record.n_attribute2
               ,p_lot_record.n_attribute3
               ,p_lot_record.n_attribute4
               ,p_lot_record.n_attribute5
               ,p_lot_record.n_attribute6
               ,p_lot_record.n_attribute7
               ,p_lot_record.n_attribute8
               ,p_lot_record.n_attribute9
               ,p_lot_record.n_attribute10
               ,p_lot_record.vendor_name
               ,p_lot_record.sublot_num
               ,p_lot_record.secondary_quantity
               ,p_lot_record.secondary_unit_of_measure
               ,p_lot_record.qc_grade
               ,p_lot_record.reason_code
               ,p_lot_record.product_code
               ,p_lot_record.product_transaction_id
               ,p_lot_record.attribute_category
               ,p_lot_record.attribute1
               ,p_lot_record.attribute2
               ,p_lot_record.attribute3
               ,p_lot_record.attribute4
               ,p_lot_record.attribute5
               ,p_lot_record.attribute6
               ,p_lot_record.attribute7
               ,p_lot_record.attribute8
               ,p_lot_record.attribute9
               ,p_lot_record.attribute10
               ,p_lot_record.attribute11
               ,p_lot_record.attribute12
               ,p_lot_record.attribute13
               ,p_lot_record.attribute14
               ,p_lot_record.attribute15);

mydebug('l_progress: ' || l_progress );
mydebug('End.. ' || l_proc_name);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
        mydebug('ROLLBACK ' );
        ROLLBACK ;

END proc_insert_mtlt;


PROCEDURE proc_insert_msnt
              (p_transaction_temp_id             IN          NUMBER
              ,p_organization_id                 IN          NUMBER
              ,p_inventory_item_id               IN          NUMBER
              ,p_revision                        IN          VARCHAR2
              ,p_confirmed_serials               IN          VARCHAR2
              ,p_serial_number                   IN          VARCHAR2
              ,p_lpn_id                          IN          NUMBER
              ,p_serial_lot_number               IN          VARCHAR2
              ,p_user_id                         IN          NUMBER
              ,x_return_status                   OUT NOCOPY  VARCHAR2
       ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2)
IS
   --p_transaction_temp_id := transaction_temp_id of the new MSNT
   l_proc_name                VARCHAR2(30) :=  'PROC_INSERT_MSNT';
   l_progress                 VARCHAR2(30) :=  '100';
   l_serial_prefix            NUMBER;
   l_real_serial_prefix       VARCHAR2(30);
   l_serial_numeric_frm       NUMBER;
   l_serial_numeric_to        NUMBER;
   l_number_of_serial_numbers NUMBER;

BEGIN
    mydebug('In ..  ' || l_proc_name);
    mydebug('p_transaction_temp_id = ' || p_transaction_temp_id);
    mydebug('p_organization_id     = ' || p_organization_id);
    mydebug('p_inventory_item_id   = ' || p_inventory_item_id);
    mydebug('p_serial_number       = ' || p_serial_number);
    mydebug('p_lpn_id              = ' || p_lpn_id);
    mydebug('p_user_id             = ' || p_user_id);

    x_return_status  := l_g_ret_sts_success;
    l_progress := '110';

    -- copied the logic from INV_TRX_UTIL_PUB.INSERT_SER_TRX
    l_real_serial_prefix  := RTRIM(p_serial_number, '0123456789');
    l_serial_numeric_frm  := TO_NUMBER(SUBSTR(p_serial_number, NVL(LENGTH(l_real_serial_prefix), 0) + 1));
    l_serial_numeric_to   := TO_NUMBER(SUBSTR(p_serial_number, NVL(LENGTH(l_real_serial_prefix), 0) + 1));
    l_serial_prefix       := (l_serial_numeric_to - l_serial_numeric_frm) + 1;

    l_progress    :=  '120';
    mydebug ('l_progress: ' || l_progress );
    -- P_serial_number is null means we are inserting a group of serials either
    -- 1. using LPN_ID passed in or serial_lot_number  passed in (p-confirmed_serials is NULL)
    -- OR 2. using the data from the gtmp table (when p_confirmed_serials is nOT NULL)
    IF p_serial_number   IS NULL
    THEN
       INSERT  INTO  mtl_serial_numbers_temp
               (transaction_temp_id
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               ,request_id
               ,program_application_id
               ,program_id
               ,program_update_date
               ,vendor_serial_number
               ,vendor_lot_number
               ,fm_serial_number
               ,to_serial_number
               ,serial_prefix
               ,error_code
               ,parent_serial_number
               ,group_header_id
               ,end_item_unit_number
               ,serial_attribute_category
               ,territory_code
               ,origination_date
               ,c_attribute1
               ,c_attribute2
               ,c_attribute3
               ,c_attribute4
               ,c_attribute5
               ,c_attribute6
               ,c_attribute7
               ,c_attribute8
               ,c_attribute9
               ,c_attribute10
               ,c_attribute11
               ,c_attribute12
               ,c_attribute13
               ,c_attribute14
               ,c_attribute15
               ,c_attribute16
               ,c_attribute17
               ,c_attribute18
               ,c_attribute19
               ,c_attribute20
               ,d_attribute1
               ,d_attribute2
               ,d_attribute3
               ,d_attribute4
               ,d_attribute5
               ,d_attribute6
               ,d_attribute7
               ,d_attribute8
               ,d_attribute9
               ,d_attribute10
               ,n_attribute1
               ,n_attribute2
               ,n_attribute3
               ,n_attribute4
               ,n_attribute5
               ,n_attribute6
               ,n_attribute7
               ,n_attribute8
               ,n_attribute9
               ,n_attribute10
               ,status_id
               ,time_since_new
               ,cycles_since_new
               ,time_since_overhaul
               ,cycles_since_overhaul
               ,time_since_repair
               ,cycles_since_repair
               ,time_since_visit
               ,cycles_since_visit
               ,time_since_mark
               ,cycles_since_mark
               ,number_of_repairs
               ,product_code
               ,product_transaction_id )
         (SELECT
                p_transaction_temp_id
               ,SYSDATE
               ,-1
               ,SYSDATE
               ,p_user_id
               ,msn.last_update_login
               ,msn.request_id
               ,msn.program_application_id
               ,msn.program_id
               ,msn.program_update_date
               ,msn.vendor_serial_number
               ,msn.vendor_lot_number
               ,msn.serial_number
               ,msn.serial_number
               ,NVL(l_serial_prefix, 1)
               ,NULL -- error code
               ,msn.parent_serial_number
               ,NULL --group_header_id
               ,msn.end_item_unit_number
               ,msn.serial_attribute_category
               ,msn.territory_code
               ,msn.origination_date
               ,msn.c_attribute1
               ,msn.c_attribute2
               ,msn.c_attribute3
               ,msn.c_attribute4
               ,msn.c_attribute5
               ,msn.c_attribute6
               ,msn.c_attribute7
               ,msn.c_attribute8
               ,msn.c_attribute9
               ,msn.c_attribute10
               ,msn.c_attribute11
               ,msn.c_attribute12
               ,msn.c_attribute13
               ,msn.c_attribute14
               ,msn.c_attribute15
               ,msn.c_attribute16
               ,msn.c_attribute17
               ,msn.c_attribute18
               ,msn.c_attribute19
               ,msn.c_attribute20
               ,msn.d_attribute1
               ,msn.d_attribute2
               ,msn.d_attribute3
               ,msn.d_attribute4
               ,msn.d_attribute5
               ,msn.d_attribute6
               ,msn.d_attribute7
               ,msn.d_attribute8
               ,msn.d_attribute9
               ,msn.d_attribute10
               ,msn.n_attribute1
               ,msn.n_attribute2
               ,msn.n_attribute3
               ,msn.n_attribute4
               ,msn.n_attribute5
               ,msn.n_attribute6
               ,msn.n_attribute7
               ,msn.n_attribute8
               ,msn.n_attribute9
               ,msn.n_attribute10
               ,msn.status_id
               ,msn.time_since_new
               ,msn.cycles_since_new
               ,msn.time_since_overhaul
               ,msn.cycles_since_overhaul
               ,msn.time_since_repair
               ,msn.cycles_since_repair
               ,msn.time_since_visit
               ,msn.cycles_since_visit
               ,msn.time_since_mark
               ,msn.cycles_since_mark
               ,msn.number_of_repairs
               ,NULL --product_code
               ,NULL --product_transaction_id
       FROM    mtl_serial_numbers  msn
       WHERE   msn.current_organization_id  = p_organization_id
       AND     msn.inventory_item_id        = p_inventory_item_id
       AND     lpn_id                       = p_lpn_id
       AND     NVL(lot_number,'@@')         = nvl(p_serial_lot_number,'@@'));
       --AND     group_mark_id                IS NULL);

       IF SQL%NOTFOUND  THEN --- MSN record not found)
           RAISE fnd_api.G_EXC_ERROR;
       END IF;

       l_progress := '130';
       mydebug('l_progress: ' || l_progress );
       proc_mark_msn (p_group_mark_id             => p_transaction_temp_id
                     ,p_organization_id           => p_organization_id
                     ,p_inventory_item_id         => p_inventory_item_id
                     ,p_revision                  => p_revision
                     ,p_confirmed_serials         => p_confirmed_serials
                     ,p_serial_lot_number         => p_serial_lot_number
                     ,p_serial_number             => p_serial_number
                     ,p_lpn_id                    => p_lpn_id
                     ,p_user_id                   => p_user_id
                     ,x_return_status             => x_return_status
              ,x_msg_count                 => x_msg_count
                     ,x_msg_data                  => x_msg_data);
       IF x_return_status <> l_g_ret_sts_success THEN
           mydebug('x_return_status : ' || x_return_status);
           RAISE fnd_api.G_EXC_ERROR;
       END IF;

    ELSE  -- confirmed_serials are no null so get the serials from mtl-allocations_gtmp table

       INSERT  INTO  mtl_serial_numbers_temp
               (transaction_temp_id
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               ,request_id
               ,program_application_id
               ,program_id
               ,program_update_date
               ,vendor_serial_number
               ,vendor_lot_number
               ,fm_serial_number
               ,to_serial_number
               ,serial_prefix
               ,error_code
               ,parent_serial_number
               ,group_header_id
               ,end_item_unit_number
               ,serial_attribute_category
               ,territory_code
               ,origination_date
               ,c_attribute1
               ,c_attribute2
               ,c_attribute3
               ,c_attribute4
               ,c_attribute5
               ,c_attribute6
               ,c_attribute7
               ,c_attribute8
               ,c_attribute9
               ,c_attribute10
               ,c_attribute11
               ,c_attribute12
               ,c_attribute13
               ,c_attribute14
               ,c_attribute15
               ,c_attribute16
               ,c_attribute17
               ,c_attribute18
               ,c_attribute19
               ,c_attribute20
               ,d_attribute1
               ,d_attribute2
               ,d_attribute3
               ,d_attribute4
               ,d_attribute5
               ,d_attribute6
               ,d_attribute7
               ,d_attribute8
               ,d_attribute9
               ,d_attribute10
               ,n_attribute1
               ,n_attribute2
               ,n_attribute3
               ,n_attribute4
               ,n_attribute5
               ,n_attribute6
               ,n_attribute7
               ,n_attribute8
               ,n_attribute9
               ,n_attribute10
               ,status_id
               ,time_since_new
               ,cycles_since_new
               ,time_since_overhaul
               ,cycles_since_overhaul
               ,time_since_repair
               ,cycles_since_repair
               ,time_since_visit
               ,cycles_since_visit
               ,time_since_mark
               ,cycles_since_mark
               ,number_of_repairs
               ,product_code
               ,product_transaction_id )
         (SELECT
                p_transaction_temp_id
               ,SYSDATE
               ,-1
               ,SYSDATE
               ,p_user_id
               ,msn.last_update_login
               ,msn.request_id
               ,msn.program_application_id
               ,msn.program_id
               ,msn.program_update_date
               ,msn.vendor_serial_number
               ,msn.vendor_lot_number
               ,msn.serial_number
               ,msn.serial_number
               ,NVL(l_serial_prefix, 1)
               ,NULL -- error code
               ,msn.parent_serial_number
               ,NULL --group_header_id
               ,msn.end_item_unit_number
               ,msn.serial_attribute_category
               ,msn.territory_code
               ,msn.origination_date
               ,msn.c_attribute1
               ,msn.c_attribute2
               ,msn.c_attribute3
               ,msn.c_attribute4
               ,msn.c_attribute5
               ,msn.c_attribute6
               ,msn.c_attribute7
               ,msn.c_attribute8
               ,msn.c_attribute9
               ,msn.c_attribute10
               ,msn.c_attribute11
               ,msn.c_attribute12
               ,msn.c_attribute13
               ,msn.c_attribute14
               ,msn.c_attribute15
               ,msn.c_attribute16
               ,msn.c_attribute17
               ,msn.c_attribute18
               ,msn.c_attribute19
               ,msn.c_attribute20
               ,msn.d_attribute1
               ,msn.d_attribute2
               ,msn.d_attribute3
               ,msn.d_attribute4
               ,msn.d_attribute5
               ,msn.d_attribute6
               ,msn.d_attribute7
               ,msn.d_attribute8
               ,msn.d_attribute9
               ,msn.d_attribute10
               ,msn.n_attribute1
               ,msn.n_attribute2
               ,msn.n_attribute3
               ,msn.n_attribute4
               ,msn.n_attribute5
               ,msn.n_attribute6
               ,msn.n_attribute7
               ,msn.n_attribute8
               ,msn.n_attribute9
               ,msn.n_attribute10
               ,msn.status_id
               ,msn.time_since_new
               ,msn.cycles_since_new
               ,msn.time_since_overhaul
               ,msn.cycles_since_overhaul
               ,msn.time_since_repair
               ,msn.cycles_since_repair
               ,msn.time_since_visit
               ,msn.cycles_since_visit
               ,msn.time_since_mark
               ,msn.cycles_since_mark
               ,msn.number_of_repairs
               ,NULL --product_code
               ,NULL --product_transaction_id
          FROM  mtl_serial_numbers  msn
          WHERE msn.current_organization_id  = p_organization_id
          AND   msn.inventory_item_id        = p_inventory_item_id
          AND   nvl(lpn_id,0)                = nvl(p_lpn_id,0)
          AND   NVL(lot_number,'@@')         = nvl(p_serial_lot_number,'@@')
          --AND   group_mark_id                IS NULL
          AND   msn.serial_number  IN
               (SELECT serial_number
                  FROM mtl_allocations_gtmp
                 WHERE NVL(lot_number,'@@')         = nvl(p_serial_lot_number,'@@'))
              );
          IF SQL%NOTFOUND  THEN --- MSN record not found)
              RAISE fnd_api.G_EXC_ERROR;
          END IF;
          l_progress := '130';
          mydebug('l_progress: ' || l_progress );
          proc_mark_msn (p_group_mark_id             => p_transaction_temp_id
                        ,p_organization_id           => p_organization_id
                        ,p_inventory_item_id         => p_inventory_item_id
                        ,p_revision                  => p_revision
                        ,p_confirmed_serials         => p_confirmed_serials
                        ,p_serial_lot_number         => p_serial_lot_number
                        ,p_serial_number             => p_serial_number
                        ,p_lpn_id                    => p_lpn_id
                        ,p_user_id                   => p_user_id
                        ,x_return_status             => x_return_status
                 ,x_msg_count                 => x_msg_count
                        ,x_msg_data                  => x_msg_data);
          IF x_return_status <> l_g_ret_sts_success THEN
              mydebug('x_return_status : ' || x_return_status);
              RAISE fnd_api.G_EXC_ERROR;
          END IF;
    END IF;

    mydebug('End ..  ' || l_proc_name);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);

END proc_insert_msnt ;

PROCEDURE proc_mark_msn
              (p_group_mark_id                   IN          NUMBER
              ,p_organization_id                 IN          NUMBER
              ,p_inventory_item_id               IN          NUMBER
              ,p_Revision                        IN          VARCHAR2
              ,p_confirmed_serials               IN          VARCHAR2
              ,p_serial_lot_number               IN          VARCHAR2
              ,p_serial_number                   IN          VARCHAR2
              ,p_lpn_id                          IN          NUMBER
              ,p_user_id                         IN          NUMBER
              ,x_return_status                   OUT NOCOPY  VARCHAR2
       ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2)
IS
   --p_transaction_temp_id := transaction_temp_id of the new MSNT
   l_proc_name                   VARCHAR2(30) :=  'PROC_MARK_MSN';
   l_progress                    VARCHAR2(30) :=  '100';
BEGIN
    mydebug('In ..  ' || l_proc_name);
    mydebug('p_group_mark_id     : ' || p_group_mark_id);
    mydebug('p_organization_id   : ' || p_organization_id);
    mydebug('p_inventory_item_id : ' || p_inventory_item_id);
    mydebug('p_serial_number     : ' || p_serial_number);
    mydebug('p_lpn_id            : ' || p_lpn_id );
    mydebug('p_user_id           : ' || p_user_id);

    x_return_status  := l_g_ret_sts_success;
    l_progress := '110';
    mydebug('l_progress: ' || l_progress );
    IF p_serial_number IS NULL
    THEN
       l_progress := '200';
       mydebug('l_progress: ' || l_progress );
       UPDATE  MTL_SERIAL_NUMBERS
       SET     group_mark_id   = p_group_mark_id
             , last_updated_by = p_user_id
       WHERE   current_organization_id     = p_organization_id
       AND     inventory_item_id           = p_inventory_item_id
       AND     lpn_id                      = p_lpn_id ;
       --AND     group_mark_id               IS NULL;

       IF SQL%NOTFOUND THEN
           fnd_message.set_name('WMS', 'WMS_ERROR_MARKING_SERIAL'); --NEWMSG
           -- "Error reserving Serial Number/s"
           fnd_msg_pub.ADD;
          RAISE fnd_api.G_EXC_ERROR;
       END IF;
    ELSE
       l_progress := '300';
       mydebug('l_progress: ' || l_progress );
       UPDATE  MTL_SERIAL_NUMBERS  msn
          SET  group_mark_id   = p_group_mark_id
             , last_updated_by = p_user_id
        WHERE  msn.current_organization_id  = p_organization_id
          AND  msn.inventory_item_id        = p_inventory_item_id
          AND  nvl(lpn_id,0)                = nvl(p_lpn_id,0)
          AND  NVL(lot_number,'@@')         = nvl(p_serial_lot_number,'@@')
          --AND  group_mark_id                IS NULL
          AND  msn.serial_number  IN
               (SELECT serial_number
                  FROM mtl_allocations_gtmp
                 WHERE NVL(lot_number,'@@') = nvl(p_serial_lot_number,'@@'));

       IF SQL%NOTFOUND THEN
           fnd_message.set_name('WMS', 'WMS_ERROR_MARKING_SERIAL'); --NEWMSG
           -- "Error reserving Serial Number/s"
           fnd_msg_pub.ADD;
          RAISE fnd_api.G_EXC_ERROR;
       END IF;
    END IF;

    mydebug('End ..  ' || l_proc_name);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);

END  proc_mark_msn ;

PROCEDURE proc_unmark_msn (p_group_mark_id                IN          NUMBER
                        ,p_organization_id                IN          NUMBER
                        ,p_inventory_item_id              IN          NUMBER
                        ,p_Revision                       IN          VARCHAR2
                        ,p_serial_number                  IN          VARCHAR2
                        ,p_lpn_id                         IN          NUMBER
                        ,p_user_id                        IN          NUMBER
                        ,x_return_status                  OUT NOCOPY  VARCHAR2
                 ,x_msg_count                      OUT NOCOPY  NUMBER
                        ,x_msg_data                       OUT NOCOPY  VARCHAR2)
IS
   --p_transaction_temp_id := transaction_temp_id of the new MSNT
   l_proc_name                   VARCHAR2(30) :=  'PROC_UNMARK_MSN';
   l_progress                    VARCHAR2(30) :=  '100';
BEGIN
    mydebug('In ..  ' || l_proc_name);
    mydebug('p_group_mark_id     : ' || p_group_mark_id);
    mydebug('p_organization_id   : ' || p_organization_id);
    mydebug('p_inventory_item_id : ' || p_inventory_item_id);
    mydebug('p_serial_number     : ' || p_serial_number);
    mydebug('p_lpn_id            : ' || p_lpn_id );
    mydebug('p_user_id           : ' || p_user_id);

    x_return_status  := l_g_ret_sts_success;
    l_progress := '110';
    mydebug('l_progress: ' || l_progress );
    UPDATE  MTL_SERIAL_NUMBERS
    SET     group_mark_id   = p_group_mark_id
          , last_updated_by = p_user_id
    WHERE   current_organization_id     = p_organization_id
    AND     inventory_item_id           = p_inventory_item_id
    AND     nvl(lpn_id,0)               = nvl(p_lpn_id,0)
    AND     DECODE(p_serial_number,NULL,'@@',serial_number) = nvl(p_serial_number,'@@')  ;
    --AND     group_mark_id  IS NULL;

    IF SQL%NOTFOUND THEN
       RAISE fnd_api.G_EXC_ERROR;
    END IF;

    mydebug('End ..  ' || l_proc_name);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);

END  proc_unmark_msn ;

/* WHen F2 is pressed, the MMTT/MTLT/MSNT that was split needs to be rolled back so that,
 * task is in its original state that is before it was split. Sice the split commits the
 * newly inserted/updated details, the rollback has to be done manually.
*/
PROCEDURE process_F2(
               p_action                 IN            VARCHAR2 -- NULL, CMS
              ,p_organization_id        IN            NUMBER
              ,p_user_id                IN            NUMBER
              ,p_employee_id            IN            NUMBER
              ,p_transaction_header_id  IN            NUMBER
              ,p_transaction_temp_id    IN            NUMBER
              ,p_original_sub           IN            VARCHAR2
              ,p_original_locator_id    IN            NUMBER
              ,p_lot_controlled         IN            VARCHAR2  -- Y/N
              ,p_serial_controlled      IN            VARCHAR2  -- Y/N
              ,p_serial_allocated_flag  IN            VARCHAR2 -- Y/N
              ,p_suggested_uom          IN            VARCHAR2  -- original allocation UOM
              ,p_start_over             IN            VARCHAR2   -- Y/N  start_over
              ,p_retain_task            IN            VARCHAR2 -- Y/N for bug 4310093
              ,x_start_over_taskno      OUT NOCOPY    NUMBER   -- start_over task
              ,x_return_status          OUT NOCOPY    VARCHAR2
              ,x_msg_count              OUT NOCOPY    NUMBER
              ,x_msg_data               OUT NOCOPY    VARCHAR2)
IS
   --PRAGMA AUTONOMOUS_TRANSACTION;

   l_proc_name                   VARCHAR2(30) :=  'PROCESS_F2';
   l_progress                    VARCHAR2(30) :=  '100';
   l_debug                       NUMBER       :=  NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_new_transaction_temp_id     NUMBER       :=  NULL;
   l_serial_transaction_temp_id  NUMBER       :=  NULL;
   l_transaction_temp_id         NUMBER       :=  NULL;
   l_original_sub_loc            VARCHAR2(1)  :=  'N';
   l_rec_mtlt_to_copy_from       mtl_transaction_lots_temp%ROWTYPE;
   l_suggested_mmtt_qty          NUMBER       := 0;
   l_suggested_mtlt_qty          NUMBER       := 0;
   -- bug #4141928 INV CONV
   l_suggested_mmtt_sec_qty          NUMBER       := 0;
   l_suggested_mtlt_sec_qty          NUMBER       := 0;

   l_op_msnt_to_delete           NUMBER       := 0;
   l_start_over_task             NUMBER       := 0;
   l_parent_posting_flag         VARCHAR2(1); -- Bug#4185621


   /* cur_mmtt1
     -- Group MMTTs(including p_transaction_temp_id) with  p_transaction_header_id
     -- by inventory_item_id,subinventory_code,locator_id.
     -- update one of the MMTTs(min temp_id) from each group and delete rest from that group */

   CURSOR  cur_mmtt1
   IS
      SELECT   sum(primary_quantity) mmtt_primary_quantity
      -- bug #4141928 INV CONV
      , sum(secondary_transaction_quantity) mmtt_secondary_quantity
      , COUNT(*) mmtt_group_count
      , MIN(transaction_temp_id) group_temp_id
      , MIN(parent_line_id) parent_line_id -- Bug#4185621
             , inventory_item_id
             , revision
             , subinventory_code
             , locator_id
             , item_primary_uom_code
      FROM   mtl_material_transactions_temp mmtt
      WHERE  mmtt.transaction_header_id  = p_transaction_header_id
      GROUP BY
              inventory_item_id
             ,revision
             ,subinventory_code
             ,locator_id
             ,item_primary_uom_code;

   CURSOR  cur_mtlt1       ( p_subinventory_code   VARCHAR2
                            ,p_locator_id          NUMBER
                            ,p_uom_code            VARCHAR2
                            ,p_inventory_item_id   VARCHAR2
                            ,p_revision            VARCHAR2
                            ,p_group_temp_id       NUMBER)
   IS
      SELECT  sum(mtlt.primary_quantity)      group_lot_primary_quantity
      -- bug #4141928 INV CONV
      , sum(mtlt.secondary_quantity)          group_lot_secondary_quantity
      ,COUNT(*)                               group_lot_count
      ,MIN(mtlt.transaction_temp_id)   group_lot_temp_id
             ,mtlt.lot_number
      FROM    mtl_transaction_lots_temp mtlt
            , mtl_material_transactions_temp mmtt
      WHERE   mmtt.transaction_header_id =  p_transaction_header_id
      AND     mmtt.transaction_temp_id   =  mtlt.transaction_temp_id
      AND     mmtt.subinventory_code     =  p_subinventory_code
      AND     mmtt.locator_id            =  p_locator_id
      AND     mmtt.item_primary_uom_code =  p_uom_code
      AND     mmtt.inventory_item_id     =  p_inventory_item_id
      AND     nvl(mmtt.revision,'@@')    =  nvl(p_revision,'@@')
      GROUP BY
              mtlt.lot_number;

   CURSOR cur_msnt_to_delete ( p_rec_mmtt1_subinventory_code   VARCHAR2
                              ,p_rec_mmtt1_locator_id          NUMBER
                              ,p_rec_mmtt1_item_primary_uom    VARCHAR2
                              ,p_rec_mmtt1_inventory_item_id   NUMBER
                              ,p_rec_mmtt1_revision            VARCHAR2)
   IS
              SELECT   msnt.transaction_temp_id
                      ,msnt.fm_serial_number
                      ,mmtt.organization_id
                      ,mmtt.inventory_item_id
                      ,msnt.creation_date
                FROM   mtl_serial_numbers_temp msnt
                      ,mtl_material_transactions_temp mmtt
               WHERE   mmtt.transaction_header_id  = p_transaction_header_id
                 AND   mmtt.transaction_temp_id   =  msnt.transaction_temp_id
                 AND   mmtt.subinventory_code     =  p_rec_mmtt1_subinventory_code
                 AND   mmtt.locator_id            =  p_rec_mmtt1_locator_id
                 AND   mmtt.item_primary_uom_code =  p_rec_mmtt1_item_primary_uom
                 AND   mmtt.inventory_item_id     =  p_rec_mmtt1_inventory_item_id
                 AND   nvl(mmtt.revision,'@@')    =  nvl(p_rec_mmtt1_revision,'@@')
               ORDER BY msnt.creation_date DESC;

   CURSOR cur_msnt_to_delete_LS (p_serial_transaction_temp_id    NUMBER)
   IS
              SELECT   msnt.transaction_temp_id
                      ,msnt.fm_serial_number
                      ,msnt.creation_date
                FROM   mtl_serial_numbers_temp msnt
               WHERE   msnt.transaction_temp_id   =  p_serial_transaction_temp_id
               ORDER BY msnt.creation_date DESC;
BEGIN
    mydebug('In ..  ' || l_proc_name);
    x_return_status  := l_g_ret_sts_success;
    g_debug := l_debug;

    mydebug ('p_action                 = ' || p_action);
    mydebug ('p_organization_id        = ' || p_organization_id);
    mydebug ('p_user_id                = ' || p_user_id);
    mydebug ('p_employee_id            = ' || p_employee_id);
    mydebug ('p_transaction_header_id  = ' || p_transaction_header_id);
    mydebug ('p_transaction_temp_id    = ' || p_transaction_temp_id);
    mydebug ('p_original_sub           = ' || p_original_sub);
    mydebug ('p_original_locator_id    = ' || p_original_locator_id);
    mydebug ('p_lot_controlled         = ' || p_lot_controlled);
    mydebug ('p_serial_controlled      = ' || p_serial_controlled);
    mydebug ('p_serial_allocated_flag  = ' || p_serial_allocated_flag);
    mydebug ('p_suggested_uom          = ' || p_suggested_uom        );

    l_progress := 110;
    mydebug('l_progress =  ' || l_progress);
    proc_device_call (
             p_action                 => p_action
           , p_employee_id            => p_employee_id
           , p_transaction_temp_id    => p_transaction_temp_id
           , x_return_status          => x_return_status
           , x_msg_count              => x_msg_count
           , x_msg_data               => x_msg_data );
    IF x_return_status <> l_g_ret_sts_success THEN
       mydebug('x_return_status : ' || x_return_status);
       --RAISE fnd_api.G_EXC_ERROR; punnet's request
    END IF;

    l_progress := 200;
    mydebug('l_progress =  ' || l_progress);

  /*{{
 *  If user had not pressed start over button we would reset the status of task
 *  as done before.All task would return to pending wdd would be deleted.
 *}}
 */

  IF p_start_over ='N' and p_retain_task='N' THEN --bug 4310093
   mydebug('viks start_over button not pressed:');

    proc_reset_task_status(
               p_action                 => p_action
              ,p_organization_id        => p_organization_id
              ,p_user_id                => p_user_id
              ,p_employee_id            => p_employee_id
              ,p_transaction_header_id  => p_transaction_header_id
              ,p_transaction_temp_id    => p_transaction_temp_id
              ,x_return_status          => x_return_status
              ,x_msg_count              => x_msg_count
              ,x_msg_data               => x_msg_data);
    IF x_return_status <> l_g_ret_sts_success THEN
          RAISE fnd_api.G_EXC_ERROR;
    END IF;
  END IF;

    l_progress := 300;
    IF l_debug = 1 THEN mydebug('l_progress =  ' || l_progress);  END IF;
    proc_process_cancelled_MOLs (
               p_organization_id        => p_organization_id
              ,p_user_id                => p_user_id
              ,p_transaction_header_id  => p_transaction_header_id
              ,p_transaction_temp_id    => p_transaction_temp_id
              ,x_return_status          => x_return_status
              ,x_msg_count              => x_msg_count
              ,x_msg_data               => x_msg_data);
    IF x_return_status <> l_g_ret_sts_success THEN
       mydebug('x_return_status : ' || x_return_status);
       RAISE fnd_api.G_EXC_ERROR;
    END IF;

    IF P_ACTION is not NULL AND p_action = 'CMS' THEN
        COMMIT;
        RETURN;
    END IF;

    -- Reset Lpn context of content_lpn_ids and transfer_lpn_ids
    l_progress := 400;
    IF l_debug = 1 THEN mydebug('l_progress =  ' || l_progress);  END IF;
    IF P_ACTION is NULL OR p_action <> 'CMS' THEN
       proc_reset_lpn_context(
               p_organization_id        => p_organization_id
              ,p_user_id                => p_user_id
              ,p_transaction_header_id  => p_transaction_header_id
              ,p_transaction_temp_id    => p_transaction_temp_id
              ,x_return_status          => x_return_status
              ,x_msg_count              => x_msg_count
              ,x_msg_data               => x_msg_data);
       IF x_return_status <> l_g_ret_sts_success THEN
          RAISE fnd_api.G_EXC_ERROR;
       END IF;
    END IF;

    -- Group MMTTs(including p_transaction_temp_id) with  p_transaction_header_id
    -- by inventory_item_id,subinventory_code,locator_id.
    -- update one of the MMTTs(min temp_id) from each group and delete rest from that group
    l_progress := 500;
    IF l_debug = 1 THEN mydebug('l_progress =  ' || l_progress);  END IF;

    DELETE  mtl_allocations_gtmp ;
    IF SQL%NOTFOUND THEN
       null;
    END IF;

    IF P_ACTION is NULL OR p_action <> 'CMS' THEN
    FOR rec_mmtt1 IN cur_mmtt1
    LOOP
       l_progress := 510;
       mydebug('l_progress                      =  ' || l_progress);
       mydebug('l_original_sub_loc              =  ' || l_original_sub_loc);
       mydebug('rec_mmtt1.mmtt_group_count      =  ' || rec_mmtt1.mmtt_group_count);
       mydebug('rec_mmtt1.group_temp_id         =  ' || rec_mmtt1.group_temp_id);
       mydebug('rec_mmtt1.subinventory_code     =  ' || rec_mmtt1.subinventory_code);
       mydebug('rec_mmtt1.locator_id            =  ' || rec_mmtt1.locator_id);
       mydebug('rec_mmtt1.item_primary_uom_code =  ' || rec_mmtt1.item_primary_uom_code);
       mydebug('rec_mmtt1.mmtt_primary_quantity =  ' || rec_mmtt1.mmtt_primary_quantity);
       mydebug('rec_mmtt1.mmtt_secondary_transaction_quantity =  ' || rec_mmtt1.mmtt_secondary_quantity);

      IF rec_mmtt1.item_primary_uom_code IS NULL THEN
         fnd_message.set_name('WMS', 'WMS_NULL_PRIM_UOM');
         -- Item primary UOM is null for this task
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- this global temp table will have a list of transaction_temp_ids of MMTTs that
      -- are confirmed to stay back in MMTT. Later we will use this list to decide on which
      -- MMTTs should be deleted that belong to the p_transaction-header_id but are not
      -- in this list
      l_progress := 600;
      INSERT
        INTO mtl_allocations_gtmp
             (transaction_temp_id)
      VALUES ( rec_mmtt1.group_temp_id);
      mydebug('Inserted temp_id into mtl_allocations_gtmp: ' || rec_mmtt1.group_temp_id);

      IF p_suggested_uom <> rec_mmtt1.item_primary_uom_code
      THEN
         l_suggested_mmtt_qty      := inv_convert.inv_um_convert
                                  (item_id          => rec_mmtt1.inventory_item_id
                                  ,precision        => l_g_decimal_precision
                                  ,from_quantity    => rec_mmtt1.mmtt_primary_quantity
                                  ,from_unit        => rec_mmtt1.item_primary_uom_code
                                  ,to_unit          => p_suggested_uom
                                  ,from_name        => NULL
                                  ,to_name          => NULL);
      ELSE
         l_suggested_mmtt_qty      := rec_mmtt1.mmtt_primary_quantity;
      END IF;
         l_suggested_mmtt_sec_qty  := rec_mmtt1.mmtt_secondary_quantity;
      mydebug('l_suggested_mmtt_qty : ' || l_suggested_mmtt_qty );
      mydebug('l_suggested_mmtt_sec_qty : ' || l_suggested_mmtt_sec_qty );
      l_progress := 650;

      -- Bug#4185621: decide whether to update posting flag
      IF (rec_mmtt1.parent_line_id = rec_mmtt1.group_temp_id) THEN
          l_parent_posting_flag := 'N';  -- bulk parent, need to update posting flag back to 'N'
      ELSE
          l_parent_posting_flag := 'Y';  -- non bulk mmtt, keep posting flag as 'Y'
      END IF;
      -- Bug# 4185621: end change

       /* Update the MMTT record with transacttion-temp_id = group_temp_id.
        Updating transaction_quantity same as primary_quantity since
        the transaction_qty should be IN same uom AS primary qty FOR this mmtt */
       UPDATE   mtl_material_transactions_temp
          SET    primary_quantity     = rec_mmtt1.mmtt_primary_quantity
               , transaction_quantity = l_suggested_mmtt_qty
               , secondary_transaction_quantity = DECODE(secondary_transaction_quantity, NULL, NULL, l_suggested_mmtt_sec_qty)
               , transaction_uom      = p_suggested_uom
               , transfer_lpn_id      = NULL
               , lpn_id               = NULL
               , content_lpn_id       = NULL
               , last_update_date     = SYSDATE
               , last_updated_by      = p_user_id
               , wms_task_status = l_g_task_pending -- Bug4185621: update mmtt task status back to pending
               , posting_flag = l_parent_posting_flag -- Bug4185621: updating posting flag
        WHERE    transaction_temp_id  = rec_mmtt1.group_temp_id;
        IF SQL%NOTFOUND THEN
           RAISE fnd_api.G_EXC_ERROR;
        END IF;

        -- Bug# 4185621: update child line posting flag back to 'Y' for bulk picking
        IF (l_parent_posting_flag = 'N') THEN
            UPDATE mtl_material_transactions_temp mmtt
               SET posting_flag = 'Y'
             WHERE parent_line_id = rec_mmtt1.group_temp_id
               AND parent_line_id <> transaction_temp_id;
        END IF;
        -- Bug# 4185621: end change

        l_progress := 700;
        mydebug('l_progress ..  ' || l_progress);

       -- PROCESS LOTS /SERIALS BEFORE DELETING ..... *****
       -- Only if the present cursor group has more than one row
       -- that it is necessary to take care of lots and  serial
       -- IF    (rec_mmtt1.mmtt_group_count > 1) THEN : for serials not allocated. It has to be processed
       IF    ((p_lot_controlled = 'Y' AND p_serial_controlled = 'Y')
           OR (p_lot_controlled = 'Y' AND p_serial_controlled <> 'Y'))

       THEN
          l_progress := 800;
          mydebug('l_progress ..  ' || l_progress);

          --IF    (rec_mmtt1.mmtt_group_count > 1)
                --OR
                --(rec_mmtt1.mmtt_group_count = 1 AND
                --p_serial_controlled = 'Y' and p_serial_allocated_flag = 'N')
          --THEN
             FOR rec_mtlt1 IN cur_mtlt1  (rec_mmtt1.subinventory_code
                                     , rec_mmtt1.locator_id
                                     , rec_mmtt1.item_primary_uom_code
                                     , rec_mmtt1.inventory_item_id
                                     , rec_mmtt1.revision
                                     , rec_mmtt1.group_temp_id)
             LOOP
             l_progress := 1000;
             mydebug('l_progress ..  ' || l_progress);
             mydebug('rec_mtlt1.lot_number : ' || rec_mtlt1.lot_number);
             mydebug('rec_mtlt1.group_lot_primary_quantity : ' || rec_mtlt1.group_lot_primary_quantity);
             mydebug('rec_mtlt1.group_lot_secondary_quantity : ' || rec_mtlt1.group_lot_secondary_quantity);
             mydebug('rec_mtlt1.group_lot_count : ' || rec_mtlt1.group_lot_count);
             mydebug('rec_mtlt1.group_lot_temp_id : ' || rec_mtlt1.group_lot_temp_id);
             mydebug('rec_mtlt1.group_lot_primary_quantity : ' || rec_mtlt1.group_lot_primary_quantity);

             l_serial_transaction_temp_id := NULL;
             SELECT mtl_material_transactions_s.NEXTVAL
             INTO   l_serial_transaction_temp_id
             FROM   DUAL;
             mydebug('l_serial_transaction_temp_id ..  ' || l_serial_transaction_temp_id);
             IF p_suggested_uom <> rec_mmtt1.item_primary_uom_code
             THEN
                l_suggested_mtlt_qty := inv_convert.inv_um_convert
                                         (item_id          => rec_mmtt1.inventory_item_id
                                         ,precision        => l_g_decimal_precision
                                         ,from_quantity    => rec_mtlt1.group_lot_primary_quantity
                                         ,from_unit        => rec_mmtt1.item_primary_uom_code
                                         ,to_unit          => p_suggested_uom
                                         ,from_name        => NULL
                                         ,to_name          => NULL);
             ELSE
                l_suggested_mtlt_qty := rec_mtlt1.group_lot_primary_quantity;
             END IF;
                l_suggested_mtlt_sec_qty := rec_mtlt1.group_lot_secondary_quantity;
             mydebug('l_suggested_mtlt_qty : ' || l_suggested_mtlt_qty);
             mydebug('l_suggested_mtlt_sec_qty : ' || l_suggested_mtlt_sec_qty);

             IF p_serial_controlled = 'Y'  THEN
                IF p_serial_allocated_flag = 'Y' THEN

                   l_progress := 1100;
                   mydebug('l_progress ..  ' || l_progress);
                   UPDATE  mtl_serial_numbers_temp
                      SET  transaction_temp_id = l_serial_transaction_temp_id
                         , last_update_date    = SYSDATE
                         , last_updated_by     = p_user_id
                    WHERE  transaction_temp_id  IN
                           (SELECT  mtlt.serial_transaction_temp_id
                              FROM  mtl_transaction_lots_temp mtlt
                                  , mtl_material_transactions_temp mmtt
                              WHERE   mmtt.transaction_header_id =  p_transaction_header_id
                              AND     mmtt.transaction_temp_id   =  mtlt.transaction_temp_id
                              AND     mmtt.subinventory_code     =  rec_mmtt1.subinventory_code
                              AND     mmtt.locator_id            =  rec_mmtt1.locator_id
                              AND     mmtt.item_primary_uom_code =  rec_mmtt1.item_primary_uom_code
                              AND     mmtt.inventory_item_id     =  rec_mmtt1.inventory_item_id
                              AND     mtlt.lot_number            =  rec_mtlt1.lot_number
                              AND     nvl(mmtt.revision,'@@')    =  nvl(rec_mmtt1.revision,'@@') );
                   mydebug ('ROW COUNT : ' || sql%rowcount);
                   IF SQL%NOTFOUND THEN
                      RAISE fnd_api.G_EXC_ERROR;
                   END IF;
                   l_progress := 1200;
                   mydebug('l_progress ..  ' || l_progress);
                   UPDATE  MTL_SERIAL_NUMBERS
                      SET  group_mark_id    = l_serial_transaction_temp_id
                         , last_updated_by  = p_user_id
                         , last_update_date = SYSDATE
                    WHERE  current_organization_id = p_organization_id
                      AND  inventory_item_id       = rec_mmtt1.inventory_item_id
                      AND  serial_number          IN
                           (SELECT fm_serial_number
                              FROM mtl_serial_numbers_temp msnt
                             WHERE msnt.transaction_temp_id   =  l_serial_transaction_temp_id);

                   IF SQL%NOTFOUND THEN
                      RAISE fnd_api.G_EXC_ERROR;
                   END IF;
                ELSE  --IF p_serial_allocated_flag = 'N' THEN
                   l_progress := 1300;
                   mydebug('l_progress ..  ' || l_progress);
                   -- First unmark serials in all MSNTS
                   UPDATE  MTL_SERIAL_NUMBERS
                   SET     group_mark_id   = NULL
                         , last_updated_by = p_user_id
                         , last_update_date = SYSDATE
                   WHERE  (current_organization_id
                          ,inventory_item_id
                          ,serial_number)
                      IN  (SELECT  mmtt.organization_id
                                  ,mmtt.inventory_item_id
                                  ,msnt.fm_serial_number
                             FROM  mtl_transaction_lots_temp      mtlt
                                  ,mtl_serial_numbers_temp        msnt
                                  ,mtl_material_transactions_temp mmtt
                            WHERE  mmtt.transaction_header_id      = p_transaction_header_id
                              AND  mmtt.transaction_temp_id        = mtlt.transaction_temp_id
                              AND  mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
                              AND  mmtt.subinventory_code          = rec_mmtt1.subinventory_code
                              AND  mmtt.locator_id                 = rec_mmtt1.locator_id
                              AND  mmtt.item_primary_uom_code      = rec_mmtt1.item_primary_uom_code
                              AND  mmtt.inventory_item_id          = rec_mmtt1.inventory_item_id
                              AND  mtlt.lot_number                 =  rec_mtlt1.lot_number
                              AND  nvl(mmtt.revision,'@@')         =  nvl(rec_mmtt1.revision,'@@') );

                   IF SQL%NOTFOUND THEN
                        mydebug('No MSNT found  ..may be because no serials were confirmed for ' ||
                                'serial_allocation= No before pressing F2' );
                   ELSE
                      -- Now delete MSNTs
                      l_progress := 1400;
                      mydebug('l_progress ..  ' || l_progress);
                      DELETE  mtl_serial_numbers_temp
                       WHERE  transaction_temp_id
                          IN
                              (SELECT  mtlt.serial_transaction_temp_id
                                 FROM  mtl_transaction_lots_temp mtlt
                                     , mtl_material_transactions_temp mmtt
                                 WHERE   mmtt.transaction_header_id =  p_transaction_header_id
                                 AND     mmtt.transaction_temp_id   =  mtlt.transaction_temp_id
                                 AND     mmtt.subinventory_code     =  rec_mmtt1.subinventory_code
                                 AND     mmtt.locator_id            =  rec_mmtt1.locator_id
                                 AND     mmtt.item_primary_uom_code =  rec_mmtt1.item_primary_uom_code
                                 AND     mmtt.inventory_item_id     =  rec_mmtt1.inventory_item_id
                                 AND     mtlt.lot_number            =  rec_mtlt1.lot_number
                                 AND     nvl(mmtt.revision,'@@')    =  nvl(rec_mmtt1.revision,'@@') );
                      IF SQL%NOTFOUND THEN
                         RAISE fnd_api.G_EXC_ERROR;
                      END IF;
                   END IF;
                END IF; --IF p_serial_allocated_flag = 'N' THEN
                l_op_msnt_to_delete  := 0;
                IF p_serial_allocated_flag = 'Y' THEN  -- to delete all overpicked serials
                   l_progress := 4000;
                   mydebug('l_progress : ' || l_progress);
                   SELECT  count(*)
                     INTO  l_op_msnt_to_delete
                     FROM  mtl_serial_numbers_temp msnt
                    WHERE  msnt.transaction_temp_id   =  l_serial_transaction_temp_id;
                   mydebug('l_op_msnt_to_delete : ' || l_op_msnt_to_delete
                            || ':' || rec_mtlt1.group_lot_primary_quantity);

                   -- only if the rec-count in msnt exceeds the total quantity in MMTT
                   --  means the serials have been  overpicked.
                   IF rec_mtlt1.group_lot_primary_quantity < l_op_msnt_to_delete
                   THEN
                   FOR rec_msnt_to_delete_LS IN cur_msnt_to_delete_LS
                                                ( l_serial_transaction_temp_id)
                   LOOP
                      mydebug('rec_msnt_to_delete_ls.fm_serial_number : ' || rec_msnt_to_delete_ls.fm_serial_number);
                      mydebug('rec_msnt_to_delete_ls.transaction_temp_id : ' || rec_msnt_to_delete_ls.transaction_temp_id);
                      /* In this cursor, we are ordering by creation date with the
                       * assumption that the overpicked serials are newly inserted MSNT records and
                       * they will have creation date higher than the originally allocated serials. */
                      IF l_op_msnt_to_delete <= rec_mtlt1.group_lot_primary_quantity
                      THEN
                         mydebug('l_op_msnt_to_delete : ' || l_op_msnt_to_delete);
                         EXIT; -- we want to process only overpicked records
                      ELSE
                         l_op_msnt_to_delete := l_op_msnt_to_delete - 1;
                         mydebug('l_op_msnt_to_delete : ' || l_op_msnt_to_delete);
                      END IF;

                      l_progress := 4300;
                      mydebug('l_progress : ' || l_progress);
                      UPDATE  MTL_SERIAL_NUMBERS
                         SET  group_mark_id    = NULL
                              ,last_updated_by  = p_user_id
                              ,last_update_date = SYSDATE
                       WHERE  current_organization_id = p_organization_id
                         AND  inventory_item_id       = rec_mmtt1.inventory_item_id
                         AND  serial_number           = rec_msnt_to_delete_ls.fm_serial_number;
                       IF SQL%NOTFOUND THEN
                          mydebug('No MSN found to be updated..not good' );
                          RAISE fnd_api.G_EXC_ERROR;
                       ELSE
                            l_progress := 4400;
                            mydebug('l_progress : ' || l_progress);
                            DELETE  mtl_serial_numbers_temp
                             WHERE  transaction_temp_id = rec_msnt_to_delete_ls.transaction_temp_id
                               AND  fm_serial_number = rec_msnt_to_delete_ls.fm_serial_number;

                            IF SQL%NOTFOUND THEN
                                 RAISE fnd_api.G_EXC_ERROR;
                            END IF;
                       END IF;
                   END LOOP;
                   END IF;
                END IF; -- serial_allocated_flag = Y and delete overpicked serials
             END IF; -- p_serial_controlled = 'Y'

             /* even if the # of records in MTLT for this lot is 1, it has to be updated
                with serial-transaction-temp_id and user_id, sysdate.
                So, there is no harm is updating qty too */
             l_progress := 1500;
             mydebug('l_progress ..  ' || l_progress);
             UPDATE   MTL_transaction_lots_temp mtlt
             SET      transaction_temp_id  = rec_mmtt1.group_temp_id
                    , primary_quantity     = rec_mtlt1.group_lot_primary_quantity
                    , transaction_quantity = l_suggested_mtlt_qty
                    , secondary_quantity   = decode (secondary_quantity, null, null, l_suggested_mtlt_sec_qty)
                    , mtlt.serial_transaction_temp_id = l_serial_transaction_temp_id
                    , last_update_date     = SYSDATE
                    , last_updated_by      = p_user_id
             WHERE    lot_number           = rec_mtlt1.lot_number
             AND      transaction_temp_id  = rec_mtlt1.group_lot_temp_id;
             IF SQL%NOTFOUND THEN
                 RAISE fnd_api.G_EXC_ERROR;
             END IF;

             l_progress := 1600;
             mydebug('l_progress ..  ' || l_progress);
             IF rec_mtlt1.group_lot_count > 1 THEN
                l_progress := 230;
                mydebug('l_progress ..  ' || l_progress);
                DELETE  mtl_transaction_lots_temp
                 WHERE  lot_number  =  rec_mtlt1.lot_number
                   AND  transaction_temp_id
                    IN
                       (SELECT  mtlt.transaction_temp_id
                          FROM  mtl_material_transactions_temp  mmtt
                               ,mtl_transaction_lots_temp       mtlt
                         WHERE  mmtt.transaction_header_id =  p_transaction_header_id
                           AND  mmtt.transaction_temp_id   <> rec_mtlt1.group_lot_temp_id
                           AND  mmtt.transaction_temp_id   =  mtlt.transaction_temp_id
                           AND  mtlt.lot_number            =  rec_mtlt1.lot_number
                           AND  mmtt.subinventory_code     =  rec_mmtt1.subinventory_code
                           AND  mmtt.locator_id            =  rec_mmtt1.locator_id
                           AND  mmtt.item_primary_uom_code =  rec_mmtt1.item_primary_uom_code
                           AND  mmtt.inventory_item_id     =  rec_mmtt1.inventory_item_id
                           AND  mtlt.lot_number            =  rec_mtlt1.lot_number
                           AND  nvl(mmtt.revision,'@@')    =  nvl(rec_mmtt1.revision,'@@') );

                IF SQL%NOTFOUND THEN
                   RAISE fnd_api.G_EXC_ERROR;
                END IF;
             END IF;
             END LOOP;

          --END IF; -- rec_mmtt1.rec_count > 1 OR
                  -- (rec_mmtt1.mmtt_group_count = 1 AND
                  -- p_serial_controlled = 'Y' and p_serial_allocated_flag = 'N')
       END IF; --lot controlled or lot +serial controlled
       l_progress := 1700;
       mydebug('l_progress : ' || l_progress);

       -- Serial Controlled items
       IF (p_lot_controlled <> 'Y' AND p_serial_controlled = 'Y') THEN
           -- serial
          l_progress := 1800;
          mydebug('l_progress : ' || l_progress);
          IF (p_serial_allocated_flag     = 'Y') THEN
             IF rec_mmtt1.mmtt_group_count > 1 THEN
                -- Now update MSNT
                l_progress := 1900;
                mydebug('l_progress : ' || l_progress);

                UPDATE  mtl_serial_numbers_temp
                   SET  transaction_temp_id = rec_mmtt1.group_temp_id
                      , last_update_date    = SYSDATE
                      , last_updated_by     = p_user_id
                 WHERE  transaction_temp_id
                    IN
                        (SELECT  msnt.transaction_temp_id
                           FROM  mtl_serial_numbers_temp msnt,
                                 mtl_material_transactions_temp mmtt
                          WHERE  mmtt.transaction_header_id = p_transaction_header_id
                            AND  mmtt.transaction_temp_id   <> rec_mmtt1.group_temp_id
                            AND  mmtt.transaction_temp_id   =  msnt.transaction_temp_id
                            AND  mmtt.subinventory_code     =  rec_mmtt1.subinventory_code
                            AND  mmtt.locator_id            =  rec_mmtt1.locator_id
                            AND  mmtt.item_primary_uom_code =  rec_mmtt1.item_primary_uom_code
                            AND  mmtt.inventory_item_id     =  rec_mmtt1.inventory_item_id
                            AND  nvl(mmtt.revision,'@@')    =  nvl(rec_mmtt1.revision,'@@') );

                 IF SQL%NOTFOUND THEN
                     RAISE fnd_api.G_EXC_ERROR;
                 END IF;
               -- REMARK MSN with new temp_id

                l_progress := 2000;
                mydebug('l_progress : ' || l_progress);
                UPDATE  MTL_SERIAL_NUMBERS
                SET     group_mark_id       = rec_mmtt1.group_temp_id
                      , last_updated_by     = p_user_id
                      , last_update_date    = SYSDATE
                 WHERE  current_organization_id = p_organization_id
                   AND  inventory_item_id       = rec_mmtt1.inventory_item_id
                   AND  serial_number
                    IN
                        (SELECT fm_serial_number
                           FROM mtl_serial_numbers_temp
                          WHERE transaction_temp_id   =  rec_mmtt1.group_temp_id);
                                                          --l_serial_transaction_temp_id);

                IF SQL%NOTFOUND THEN
                   RAISE fnd_api.G_EXC_ERROR;
                END IF;
             END IF;
          ELSE -- (p_serial_allocated_flag     = 'N' ,
                -- delete all msnts and unmark all these serials in MSN.
             l_progress := 2100;
             mydebug('l_progress : ' || l_progress);
             UPDATE  MTL_SERIAL_NUMBERS
             SET     group_mark_id  = NULL
                   , last_updated_by = p_user_id
                   , last_update_date = SYSDATE
             WHERE  (current_organization_id
                    ,inventory_item_id
                    ,serial_number)
                IN  (SELECT  mmtt.organization_id
                            ,mmtt.inventory_item_id
                            ,msnt.fm_serial_number
                       FROM  mtl_serial_numbers_temp        msnt
                            ,mtl_material_transactions_temp mmtt
                      WHERE   mmtt.transaction_header_id  = p_transaction_header_id
                        AND   mmtt.transaction_temp_id   =  msnt.transaction_temp_id
                        AND   mmtt.subinventory_code     =  rec_mmtt1.subinventory_code
                        AND   mmtt.locator_id            =  rec_mmtt1.locator_id
                        AND   mmtt.item_primary_uom_code =  rec_mmtt1.item_primary_uom_code
                        AND   mmtt.inventory_item_id     =  rec_mmtt1.inventory_item_id
                        AND   nvl(mmtt.revision,'@@')    =  nvl(rec_mmtt1.revision,'@@') );

             IF SQL%NOTFOUND THEN
                mydebug('No MSNT found  ..may be because no serials were confirmed for ' ||
                         'serial_allocation= No before pressing F2' );
             ELSE
                l_progress := 2200;
                mydebug('l_progress : ' || l_progress);

                DELETE  mtl_serial_numbers_temp
                WHERE   transaction_temp_id  IN
                (SELECT  msnt.transaction_temp_id
                 FROM    mtl_serial_numbers_temp msnt,
                         mtl_material_transactions_temp mmtt
                 WHERE   mmtt.transaction_header_id  = p_transaction_header_id
                   AND   mmtt.transaction_temp_id   =  msnt.transaction_temp_id
                   AND   mmtt.subinventory_code     =  rec_mmtt1.subinventory_code
                   AND   mmtt.locator_id            =  rec_mmtt1.locator_id
                   AND   mmtt.item_primary_uom_code =  rec_mmtt1.item_primary_uom_code
                   AND   mmtt.inventory_item_id     =  rec_mmtt1.inventory_item_id
                   AND   nvl(mmtt.revision,'@@')    =  nvl(rec_mmtt1.revision,'@@') );

                 IF SQL%NOTFOUND THEN
                     RAISE fnd_api.G_EXC_ERROR;
                 END IF;
              END IF;
          END IF;
          l_op_msnt_to_delete  := 0;
          IF p_serial_allocated_flag = 'Y' THEN  -- to delete all overpicked serials
            l_progress := 3000;
            mydebug('l_progress : ' || l_progress);
            SELECT count(*)
            INTO l_op_msnt_to_delete
            FROM mtl_serial_numbers_temp
            WHERE (transaction_temp_id   ,
                   fm_serial_number)
            IN
              (SELECT   msnt.transaction_temp_id
                      ,msnt.fm_serial_number
                FROM   mtl_serial_numbers_temp msnt
                      ,mtl_material_transactions_temp mmtt
               WHERE   mmtt.transaction_header_id  = p_transaction_header_id
                 AND   mmtt.transaction_temp_id   =  msnt.transaction_temp_id
                 AND   mmtt.subinventory_code     =  rec_mmtt1.subinventory_code
                 AND   mmtt.locator_id            =  rec_mmtt1.locator_id
                 AND   mmtt.item_primary_uom_code =  rec_mmtt1.item_primary_uom_code
                 AND   mmtt.inventory_item_id     =  rec_mmtt1.inventory_item_id
                 AND   nvl(mmtt.revision,'@@')    =  nvl(rec_mmtt1.revision,'@@'));
            mydebug('l_op_msnt_to_delete : ' || l_op_msnt_to_delete);

            -- only if the rec-count in msnt exceeds the total quantity in MMTT
            --  means the serials have been  overpicked.
            IF rec_mmtt1.mmtt_primary_quantity < l_op_msnt_to_delete
            THEN
             FOR rec_msnt_to_delete IN cur_msnt_to_delete
                             ( rec_mmtt1.subinventory_code
                              ,rec_mmtt1.locator_id
                              ,rec_mmtt1.item_primary_uom_code
                              ,rec_mmtt1.inventory_item_id
                              ,rec_mmtt1.revision    )
             LOOP
                mydebug('rec_msnt_to_delete.fm_serial_number : ' || rec_msnt_to_delete.fm_serial_number);
                mydebug('rec_msnt_to_delete.transaction_temp_id : ' || rec_msnt_to_delete.transaction_temp_id);
                mydebug('rec_msnt_to_delete.organization_id : ' || rec_msnt_to_delete.organization_id);
                mydebug('rec_msnt_to_delete.inventory_item_id : ' || rec_msnt_to_delete.inventory_item_id);
                mydebug('rec_msnt_to_delete.creation_date : ' ||
                      to_char(rec_msnt_to_delete.creation_date,'dd:mon-yyyy:hh24:mi:ss'));


                /* In this cursor, we are ordering by creation date with the
                 * assumption that the overpicked serials are newly inserted MSNT records and
                 * they will have creation date higher than the originally allocated serials. */
                IF l_op_msnt_to_delete <= rec_mmtt1.mmtt_primary_quantity
                THEN
                   l_progress := 3200;
                   mydebug('l_progress : ' || l_progress);
                   EXIT; -- we want to process only overpicked records
                ELSE
                   l_op_msnt_to_delete := l_op_msnt_to_delete - 1;
                   mydebug('l_op_msnt_to_delete : ' || l_op_msnt_to_delete);
                END IF;
                l_progress := 3300;
                mydebug('l_progress : ' || l_progress);
                UPDATE  MTL_SERIAL_NUMBERS
                   SET  group_mark_id    = NULL
                        ,last_updated_by  = p_user_id
                        ,last_update_date = SYSDATE
                 WHERE  current_organization_id = p_organization_id
                   AND  inventory_item_id       = rec_mmtt1.inventory_item_id
                   AND  serial_number           = rec_msnt_to_delete.fm_serial_number;
                 IF SQL%NOTFOUND THEN
                    mydebug('No MSN found to be updated..not good' );
                    RAISE fnd_api.G_EXC_ERROR;
                 ELSE
                      l_progress := 2200;
                      mydebug('l_progress : ' || l_progress);
                      DELETE  mtl_serial_numbers_temp
                       WHERE  transaction_temp_id = rec_msnt_to_delete.transaction_temp_id
                         AND  fm_serial_number = rec_msnt_to_delete.fm_serial_number;

                      IF SQL%NOTFOUND THEN
                           RAISE fnd_api.G_EXC_ERROR;
                      END IF;
                 END IF;
             END LOOP;
            END IF;
          END IF;
       END IF; -- Serial only Controlled
    END LOOP;  --cur_mmtt1 loop
    END IF;  --Non CMS
    l_progress := 2300;
    mydebug('l_progress ..  ' || l_progress);

      /* {{viks for start_over we need to call proc_start_over to reset the task
   *  status to dispatched and sequence  transaction_temp_ids in pl/sql table from global temp tablei
   * as they are picked.
   * }}
   */


 IF p_start_over = 'Y' THEN

    mydebug('viks start_over button pressed calling proc_start_over:');
    proc_start_over(p_transaction_header_id    => p_transaction_header_id
                     ,p_transaction_temp_id    => p_transaction_temp_id
                     ,p_user_id                => p_user_id
                     ,x_start_over_taskno      => x_start_over_taskno
                     ,x_return_status          => x_return_status
                     ,x_msg_count              => x_msg_count
                     ,x_msg_data               => x_msg_data);
       IF x_return_status <> l_g_ret_sts_success THEN
          RAISE fnd_api.G_EXC_ERROR;
       ELSE
       l_start_over_task := x_start_over_taskno;
       END IF;
  mydebug('viks l_start_over_task return froom proc_start_over :' ||l_start_over_task);
 ELSE
   mydebug('viks start_over button not pressed  :');
   --only when it is not start over case, the retain task will be used 431009
  wms_picking_pkg.g_start_over_tempid.DELETE;
  IF p_retain_task = 'Y' THEN --{ bug 4310093
      mydebug('change the task status to Dispatched if retain_task is Y');
      UPDATE wms_dispatched_tasks
      SET status = l_g_task_dispatched
          ,last_update_date = SYSDATE
          ,last_updated_by = p_user_id
      WHERE transaction_temp_id IN
            (SELECT transaction_temp_id
                     FROM mtl_allocations_gtmp);
      mydebug('nullify certain columns for all the dispatched tasks for this user');
      UPDATE  wms_dispatched_tasks
       SET   device_invoked = null
             -- Following two statement are commnet for bug 4560814
             --task_method = NULL  -- for cluster picking
             -- ,task_group_id = NULL
            ,last_update_date = SYSDATE
            ,last_updated_by = p_user_id
       WHERE  person_id = p_employee_id
          AND  status = l_g_task_dispatched;

  END IF; --}
  mydebug('viks l_start_over_task return value no :' ||l_start_over_task);



 END IF;

    x_start_over_taskno := l_start_over_task;
 mydebug('viks l_start_over_task return final value :' ||l_start_over_task);


      -- this global temp table has a list of transaction_temp_ids of MMTTs that
      -- are confirmed to stay back in MMTT and WDT. Using this we will delete WDT and MMTT

    DELETE wms_dispatched_tasks
    WHERE  transaction_temp_id IN
          (SELECT transaction_temp_id
             FROM mtl_material_transactions_temp
            WHERE transaction_header_id  = p_transaction_header_id
              AND transaction_temp_id NOT IN
                  (SELECT transaction_temp_id
                     FROM mtl_allocations_gtmp));
    IF SQL%NOTFOUND THEN
       mydebug('no extra WDTs to delete :' );
       NULL;
    END IF;

    l_progress := 2400;
    mydebug('l_progress ..  ' || l_progress);
      -- this global temp table has a list of transaction_temp_ids of MMTTs that
      -- are confirmed to stay back in MMTT and WDT. Using this we will delete WDT and MMTT
    /* {{ If start over is pressed wdd would be deleted .Lines need to stay in
 * status dispatched.
 * }}
 */

   IF p_start_over ='N' and p_retain_task='N' THEN --bug 4310093

    DELETE wms_dispatched_tasks
    WHERE  transaction_temp_id IN
          (SELECT transaction_temp_id
             FROM mtl_allocations_gtmp)
      AND  status <> l_g_task_queued;
    IF SQL%NOTFOUND THEN
       mydebug('no non queued WDTs to delete :' );
       NULL;
    END IF;
  END IF;

    l_progress := 2500;
    mydebug('l_progress ..  ' || l_progress);
    DELETE mtl_material_transactions_temp
     WHERE transaction_header_id  = p_transaction_header_id
       AND transaction_temp_id NOT IN
           (SELECT transaction_temp_id
              FROM mtl_allocations_gtmp);
    IF SQL%NOTFOUND THEN
       mydebug('no extra MMTTs to delete :' );
       NULL;
    END IF;

    --Added for Case Picking Project start

    wms_picking_pkg.clear_order_numbers(
				      x_return_status =>x_return_status,
				      x_msg_count =>x_msg_count,
				      x_msg_data => x_msg_data);
    mydebug('wms_picking_pkg.clear_order_numbers x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
    mydebug('wms_picking_pkg.clear_order_numbers x_return_status = ' ||x_return_status );
    wms_picking_pkg.clear_pick_slip_number(
				      x_return_status =>x_return_status,
				      x_msg_count =>x_msg_count,
				      x_msg_data => x_msg_data);
    mydebug('wms_picking_pkg.clear_pick_slip_number x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
    mydebug('wms_picking_pkg.clear_pick_slip_number x_return_status = ' ||x_return_status );

    --Added for Case Picking Project end


   mydebug('Commit ' );
   COMMIT;
   mydebug('End ..  ' || l_proc_name);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR'); --NEWMSG
        -- Internal Error $ROUTINE
        fnd_message.set_token('ROUTINE', '- Process_f2 API' );
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('fnd_api.g_exc_error: ' || SQLERRM);
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR'); --NEWMSG
        -- Internal Error $ROUTINE
        fnd_message.set_token('ROUTINE', '- Process_f2 API' );
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR'); --NEWMSG
        -- Internal Error $ROUTINE
        fnd_message.set_token('ROUTINE', '- Process_f2 API' );
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('fnd_api.g_exc_error: ' || SQLERRM);


END process_F2;


PROCEDURE  proc_device_call
              (p_action                          IN          VARCHAR2
              ,p_employee_id                     IN          NUMBER
              ,p_transaction_temp_id             IN          NUMBER
              ,x_return_status                   OUT NOCOPY  VARCHAR2
              ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2 )
IS
    l_debug                 NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_proc_name             VARCHAR2(30) :=  'PROC_DEVICE_CALL';
    l_progress              VARCHAR2(30) :=  '100';
    l_dev_request_msg       VARCHAR2(1000) := NULL;

      -- select all tasks that belong to this employee
      CURSOR cur_wdt_for_emp IS
      SELECT transaction_temp_id
           , device_request_id
        FROM wms_dispatched_tasks
       WHERE person_id = p_employee_id
       AND (  status  <= l_g_task_dispatched  OR
              status  = l_g_task_active)    -- (<=3, OR 9 ) ;
         AND device_request_id IS NOT NULL;

      -- select task that belong to this employee and p_transaction_temp_id
      CURSOR cur_wdt_for_temp_id IS
      SELECT transaction_temp_id
           , device_request_id
        FROM wms_dispatched_tasks
       WHERE person_id = p_employee_id
         AND transaction_temp_id = p_transaction_temp_id
         AND device_request_id IS NOT NULL;

BEGIN
    mydebug ('IN : ' || l_proc_name);
    mydebug ('p_action : ' || p_action);
    mydebug ('p_employee_id : ' || p_employee_id);
    x_return_status  := fnd_api.g_ret_sts_success;

    IF p_action is NULL OR p_action <> 'CMS' THEN
       For rec_wdt_for_emp IN cur_wdt_for_emp
       LOOP
         l_progress := '110';
         mydebug('transaction_temp_id : ' || rec_wdt_for_emp.transaction_temp_id );
         mydebug('device_request_id : ' || rec_wdt_for_emp.device_request_id );
         IF rec_wdt_for_emp.transaction_temp_id IS NOT NULL
         THEN
            wms_device_integration_pvt.device_request(
                      p_bus_event            => wms_device_integration_pvt.wms_be_task_cancel
                    , p_call_ctx             => 'U'
                    , p_task_trx_id          => rec_wdt_for_emp.transaction_temp_id
                    , p_request_id           => rec_wdt_for_emp.device_request_id
                    , x_request_msg          => l_dev_request_msg
                    , x_return_status        => x_return_status
                    , x_msg_count            => x_msg_count
                    , x_msg_data             => x_msg_data );
            IF x_return_status <> l_g_ret_sts_success THEN
               mydebug('x_return_status : ' || x_return_status);
               RAISE fnd_api.G_EXC_ERROR;
            END IF;

         END IF;
       END LOOP;
    ELSE
       For rec_wdt_for_temp_id IN cur_wdt_for_temp_id
       LOOP
         l_progress := '210';
         mydebug('transaction_temp_id : ' || rec_wdt_for_temp_id.transaction_temp_id );
         mydebug('device_request_id : ' || rec_wdt_for_temp_id.device_request_id );
         IF rec_wdt_for_temp_id.transaction_temp_id IS NOT NULL
         THEN
            wms_device_integration_pvt.device_request(
                      p_bus_event            => wms_device_integration_pvt.wms_be_task_cancel
                    , p_call_ctx             => 'U'
                    , p_task_trx_id          => rec_wdt_for_temp_id.transaction_temp_id
                    , p_request_id           => rec_wdt_for_temp_id.device_request_id
                    , x_request_msg          => l_dev_request_msg
                    , x_return_status        => x_return_status
                    , x_msg_count            => x_msg_count
                    , x_msg_data             => x_msg_data );
            IF x_return_status <> l_g_ret_sts_success THEN
               mydebug('x_return_status : ' || x_return_status);
               RAISE fnd_api.G_EXC_ERROR;
            END IF;

         END IF;
       END LOOP;
    END IF;
    mydebug ('END : ' || l_proc_name);
  EXCEPTION
  WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);

END   proc_device_call ;

PROCEDURE  proc_process_cancelled_MOLs (
               p_organization_id        IN             NUMBER
              ,p_user_id                IN             NUMBER
              ,p_transaction_header_id  IN             NUMBER
              ,p_transaction_temp_id    IN             NUMBER
              ,x_return_status          OUT NOCOPY     VARCHAR2
              ,x_msg_count              OUT NOCOPY     NUMBER
              ,x_msg_data               OUT NOCOPY     VARCHAR2)
IS
    l_debug                 NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_proc_name             VARCHAR2(30) :=  'PROC_PROCESS_CANCELLED_MOLs';
    l_progress              VARCHAR2(30) :=  '100';

    l_deleted_mmtt_qty      NUMBER       := 0;
    l_deleted_mmtt_sec_qty  NUMBER       := 0;
    l_mmtt_count            NUMBER       := 0;
    -- Select all MOLs that are cancelled , so that cancelled tasks can be reduced
    CURSOR   cur_cancelled_MOLs IS
      SELECT mtrl.line_id
           , mtrl.uom_code
        FROM mtl_material_transactions_temp mmtt
           , mtl_txn_request_lines mtrl
       WHERE (mmtt.transaction_temp_id = p_transaction_temp_id
        -- shld add : and mmtt.mmtt.transaction_temp_id <> mmtt.parent_line_id
           OR mmtt.parent_line_id      = p_transaction_temp_id)
         AND mtrl.line_id = mmtt.move_order_line_id
         AND mtrl.line_status = INV_GLOBALS.G_TO_STATUS_CANCEL_BY_SOURCE;

    -- all mmtts for the given MOL
    -- this MMTT  should not have any child records
    -- this MMTT should not have a task in WDT
    CURSOR  c_mmtt_to_del (p_mo_line_id    NUMBER )
    IS
      SELECT mmtt.transaction_temp_id
           , mmtt.inventory_item_id
           , mmtt.primary_quantity
           , mmtt.item_primary_uom_code
           , NVL(mmtt.secondary_transaction_quantity, 0) secondary_transaction_quantity
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.move_order_line_id = p_mo_line_id
         AND NOT EXISTS(SELECT 1
                          FROM mtl_material_transactions_temp t1
                         WHERE t1.parent_line_id = mmtt.transaction_temp_id)
         AND NOT EXISTS(SELECT 1
                          FROM wms_dispatched_tasks wdt
                         WHERE wdt.transaction_temp_id = mmtt.transaction_temp_id);

BEGIN
    mydebug ('IN : ' || l_proc_name);
    x_return_status  := fnd_api.g_ret_sts_success;
    FOR rec_cancelled_MOLs in cur_cancelled_MOLs
    LOOP
      IF (l_debug = 1) THEN mydebug('mo_line_id = ' || rec_cancelled_mols.line_id); END IF;
      l_deleted_mmtt_qty      := 0;
      l_deleted_mmtt_sec_qty  := 0;

      FOR rec_mmtt_to_del   IN  c_mmtt_to_del (
                                p_mo_line_id  => rec_cancelled_MOLs.line_id)
      LOOP
         -- it adjusts the bulk parent too
         inv_trx_util_pub.delete_transaction(
           x_return_status       => x_return_status
         , x_msg_data            => x_msg_data
         , x_msg_count           => x_msg_count
         , p_transaction_temp_id => rec_mmtt_to_del.transaction_temp_id);
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF l_debug = 1 THEN
               mydebug('Not able to delete the Txn = ' || rec_mmtt_to_del.transaction_temp_id);
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF (rec_mmtt_to_del.item_primary_uom_code <> rec_cancelled_mols.uom_code)
         THEN
             l_deleted_mmtt_qty  := l_deleted_mmtt_qty +
                                    INV_Convert.inv_um_convert
                                       ( item_id         => rec_mmtt_to_del.inventory_item_id
                                        ,precision       => 5
                                        ,from_quantity   => rec_mmtt_to_del.primary_quantity
                                        ,from_unit       => rec_mmtt_to_del.item_primary_uom_code
                                        ,to_unit         => rec_cancelled_mols.uom_code
                                        ,from_name       => NULL
                                        ,to_name         => NULL);


         ELSE
            l_deleted_mmtt_qty  := l_deleted_mmtt_qty + rec_mmtt_to_del.primary_quantity;
         END IF;
            l_deleted_mmtt_sec_qty  := l_deleted_mmtt_sec_qty + rec_mmtt_to_del.secondary_transaction_quantity;
      END LOOP;
       -- all MMTTs for the given MOL, this MMTT  should not have any child records

      SELECT count(*)
        INTO l_mmtt_count
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.move_order_line_id = rec_cancelled_mols.line_id
         AND NOT EXISTS ( SELECT 1
                            FROM mtl_material_transactions_temp t1
                           WHERE t1.parent_line_id = mmtt.transaction_temp_id);

      UPDATE mtl_txn_request_lines
         SET quantity_detailed =(quantity_detailed - l_deleted_mmtt_qty)
           , SECONDARY_QUANTITY_DETAILED = (SECONDARY_QUANTITY_DETAILED - l_deleted_mmtt_sec_qty)
           , line_status = DECODE(l_mmtt_count, 0, INV_GLOBALS.G_TO_STATUS_CLOSED, line_status)
           , last_update_date = SYSDATE
           , last_updated_by  = p_user_id
       WHERE line_id = rec_cancelled_mols.line_id;
       IF SQL%NOTFOUND THEN
          fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR'); --NEWMSG
          -- Internal Error $ROUTINE
          fnd_message.set_token('ROUTINE', '-proc_process_cancelled_MOLs' );
          myDebug('Error updating MTRL in proc_process_cancelled_MOLs for line: ' || rec_cancelled_mols.line_id);
           fnd_msg_pub.ADD;
       END IF;
    END LOOP;
    mydebug('END = ' || l_proc_name );
  EXCEPTION
  WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);

END  proc_process_cancelled_MOLs ;

PROCEDURE  proc_reset_lpn_context(
               p_organization_id                 IN          NUMBER
              ,p_user_id                         IN          NUMBER
              ,p_transaction_header_id           IN          NUMBER
              ,p_transaction_temp_id             IN          NUMBER
              ,x_return_status                   OUT NOCOPY  VARCHAR2
              ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2)
IS
    l_proc_name                   VARCHAR2(30) :=  'PROC_RESET_LPN_CONTEXT';
    l_progress                    VARCHAR2(30) :=  '100';
    l_other_tasks                 NUMBER := 0;
    l_lpn_context_pregenerated    CONSTANT NUMBER := WMS_Container_PUB.LPN_CONTEXT_PREGENERATED;
    l_lpn_context_inv             CONSTANT NUMBER := WMS_Container_PUB.LPN_CONTEXT_INV;
    l_lpn_context_picked          CONSTANT NUMBER := WMS_Container_PUB.LPN_CONTEXT_PICKED;
    l_lpn_context_packing         CONSTANT NUMBER := WMS_Container_PUB.LPN_CONTEXT_PACKING ;

CURSOR cur_from_lpns IS
   SELECT DISTINCT lpn_id
     FROM mtl_material_transactions_temp
    WHERE transaction_header_id = p_transaction_header_id
      AND lpn_id IS NOT NULL;

CURSOR cur_content_lpns IS
   SELECT DISTINCT content_lpn_id
     FROM mtl_material_transactions_temp
    WHERE transaction_header_id = p_transaction_header_id
      AND content_lpn_id IS NOT NULL;

--modified for bug 6642448
CURSOR cur_transfer_lpns IS
   SELECT DISTINCT transfer_lpn_id
     FROM mtl_material_transactions_temp
    WHERE transaction_header_id = p_transaction_header_id
      AND nvl(content_lpn_id , nvl(lpn_id,-999)) <> transfer_lpn_id;

BEGIN
   x_return_status  := fnd_api.g_ret_sts_success;
   mydebug ('IN : ' || l_proc_name);
   l_progress := 110;
   mydebug('l_progress =  ' || l_progress);
   mydebug ('p_transaction_header_id : ' || p_transaction_header_id);

   FOR rec_transfer_lpns IN cur_transfer_lpns
   LOOP
      l_other_tasks := 0;
      l_progress := 120;
      mydebug('rec_transfer_lpns.transfer_lpn_id =  ' || rec_transfer_lpns.transfer_lpn_id);
      mydebug('l_progress =  ' || l_progress);
      BEGIN
           SELECT 1
            INTO l_other_tasks
            FROM DUAL
           WHERE EXISTS(SELECT 1
                         FROM mtl_material_transactions_temp
                        WHERE transaction_header_id <> p_transaction_header_id
                          AND transfer_lpn_id = rec_transfer_lpns.transfer_lpn_id);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_other_tasks := 0;
      END ;
      IF l_other_tasks = 0 THEN
         l_progress := 130;
         mydebug('l_progress =  ' || l_progress);
         -- Bug5659809: update last_update_date and last_update_by as well
         UPDATE wms_license_plate_numbers
            SET lpn_context = l_lpn_context_PREGENERATED
             -- , last_update_date = SYSDATE  /* Bug 9448490 Lot Substitution Project */
             -- , last_updated_by = fnd_global.user_id /* Bug 9448490 Lot Substitution Project */
          WHERE lpn_id = rec_transfer_lpns.transfer_lpn_id
            AND lpn_context <> l_lpn_context_picked;

         IF SQL%NOTFOUND THEN
            mydebug (rec_transfer_lpns.transfer_lpn_id || 'with context <> '
                                                       || l_lpn_context_picked || ' Not found ');
         END IF;
      END IF;
   END LOOP;
   l_progress := 200;
   mydebug('l_progress =  ' || l_progress);
   FOR rec_from_lpns IN cur_from_lpns
   LOOP
        l_progress := 220;
        mydebug('rec_from_lpns.lpn_id =  ' || rec_from_lpns.lpn_id);
        mydebug('l_progress =  ' || l_progress);
        -- we need to do this since mmtt.lpn_id can be a fully consumable lpn in
        -- case where xferLPN is enabled on pickload UI.
         -- Bug5659809: update last_update_date and last_update_by as well
         UPDATE wms_license_plate_numbers
            SET lpn_context = l_lpn_context_INV
              --, last_update_date = SYSDATE  /* Bug 9448490 Lot Substitution Project */
              --, last_updated_by = fnd_global.user_id /* Bug 9448490 Lot Substitution Project */
          WHERE lpn_id = rec_from_lpns.lpn_id
            AND lpn_context = l_lpn_context_packing;

         IF SQL%NOTFOUND THEN
            mydebug (rec_from_lpns.lpn_id || 'not found with context = packing ' );
         END IF;
   END LOOP;
   l_progress := 300;
   mydebug('l_progress =  ' || l_progress);
   FOR rec_content_lpns IN cur_content_lpns
   LOOP
      l_other_tasks := 0;
      l_progress := 310;
      mydebug('rec_content_lpns.content_lpn_id =  ' || rec_content_lpns.content_lpn_id);
      mydebug('l_progress =  ' || l_progress);
      BEGIN
         SELECT 1
          INTO l_other_tasks
          FROM DUAL
         WHERE EXISTS(SELECT 1
                       FROM mtl_material_transactions_temp
                      WHERE transaction_header_id <> p_transaction_header_id
                        AND content_lpn_id = rec_content_lpns.content_lpn_id);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_other_tasks := 0;
      END ;
      IF l_other_tasks = 0 THEN
           l_progress := 320;
           mydebug('l_progress =  ' || l_progress);
           -- Bug5659809: update last_update_date and last_update_by as well
           UPDATE wms_license_plate_numbers
              SET lpn_context = l_lpn_context_inv
                --, last_update_date = SYSDATE  /* Bug 9448490 Lot Substitution Project */
                --, last_updated_by = fnd_global.user_id  /* Bug 9448490 Lot Substitution Project */
            WHERE lpn_id = rec_content_lpns.content_lpn_id
              AND lpn_context <> l_lpn_context_picked;

           IF SQL%NOTFOUND THEN
               mydebug (rec_content_lpns.content_lpn_id || 'with context <> '
                                                       || l_lpn_context_picked || ' Not found ');
           END IF;
      END IF;
   END LOOP;

mydebug('END = ' || l_proc_name );
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
END proc_reset_lpn_context;

PROCEDURE  proc_reset_task_status(
               p_action                          IN          VARCHAR2
              ,p_organization_id                 IN          NUMBER
              ,p_user_id                         IN          NUMBER
              ,p_employee_id                     IN          NUMBER
              ,p_transaction_header_id           IN          NUMBER
              ,p_transaction_temp_id             IN          NUMBER
              ,x_return_status                   OUT NOCOPY  VARCHAR2
              ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2)
IS
    l_proc_name                   VARCHAR2(30) :=  'PROC_RESET_TASK_STATUS';
    l_progress                    VARCHAR2(30) :=  '100';
    l_other_tasks                 NUMBER := 0;
    l_prev_task_status            NUMBER := 0;

CURSOR cur_reset_task_status IS
SELECT transaction_temp_id
      ,task_id
  FROM wms_dispatched_tasks
 WHERE  person_id = p_employee_id
   AND (  status  = l_g_task_dispatched  OR
          status  = l_g_task_active);  -- IN (3,9 ) ;
BEGIN
   x_return_status  := fnd_api.g_ret_sts_success;
   mydebug ('IN : ' || l_proc_name);
   mydebug ('p_action : ' || p_action);
   mydebug ('p_transaction_header_id : ' || p_transaction_header_id);
   mydebug ('p_transaction_temp_id   : ' || p_transaction_temp_id  );
   mydebug ('p_employee_id : ' || p_employee_id);
   l_progress := 110;
   mydebug('l_progress =  ' || l_progress);

   IF p_action = 'CMS' THEN

      DELETE wms_dispatched_tasks
      WHERE  transaction_temp_id IN
            (SELECT transaction_temp_id
               FROM mtl_material_transactions_temp
              WHERE transaction_header_id  = p_transaction_header_id);
      IF SQL%NOTFOUND THEN
         mydebug('no WDTs to delete for this header:' );
      ELSE
         mydebug('WDTs deleted for this header:' );
      END IF;
      RETURN;
   END IF;

    -- The idea is to delete all tasks belonging to the same header_id (as in case of splits)
    -- and also to delete all dscpatched and active tasks
    -- Decide to delete all tasks with status = dispatched (3 or Active 9).
    -- There is no need to check for a specific header_id . For F2, we anyway always
    -- delete all dispatched and active tasks

    BEGIN
       l_prev_task_status := wms_picking_pkg.g_previous_task_status(p_transaction_temp_id);
       wms_picking_pkg.g_previous_task_status.delete(p_transaction_temp_id);
    EXCEPTION
    WHEN OTHERS THEN
       mydebug('wms_picking_pkg.g_previous_task_status(p_transaction_temp_id) : ' || p_transaction_temp_id
                       || ' : not found' );
       l_prev_task_status := l_g_task_pending;
    END ;

    l_progress := 110;
    mydebug('l_progress =  ' || l_progress || ' Update status for all temp_ids in thie header_id');
    mydebug('l_prev_task_status = ' || l_prev_task_status || ' for p_transaction_temp_id:  '
                                                          || p_transaction_temp_id);
    /* this update is seperate because for a pick nmore case, there can be multiple temp_ids (MMTTs)
       for the given header id ...current task) */
    UPDATE  wms_dispatched_tasks
       SET  status = l_prev_task_status
           ,last_update_date = SYSDATE
           ,last_updated_by = p_user_id
     WHERE  person_id = p_employee_id
       AND (  status  = l_g_task_dispatched  OR
              status  = l_g_task_active)  -- IN (3,9 ) ;
       AND  transaction_temp_id in (SELECT transaction_temp_id
                                      FROM mtl_material_transactions_temp
                                     WHERE transaction_header_id = p_transaction_header_id);

    IF SQL%NOTFOUND THEN
        mydebug('no WDT to update  for this employee id  for this header id with stat in ( 3,9) ' );
    END IF;

    l_progress := 150;
    mydebug('l_progress =  ' || l_progress || ' Update status of all other tasks in this group' );
    FOR rec_reset_task_status IN cur_reset_task_status
    LOOP
       BEGIN
          l_prev_task_status := wms_picking_pkg.g_previous_task_status(rec_reset_task_status.transaction_temp_id);
          wms_picking_pkg.g_previous_task_status.delete(rec_reset_task_status.transaction_temp_id);
       EXCEPTION
          WHEN OTHERS THEN
              mydebug('wms_picking_pkg.g_previous_task_status(transaction_temp_id) : '
                       || rec_reset_task_status.transaction_temp_id || ' : not found' );
              l_prev_task_status := l_g_task_pending;
       END ;
          mydebug('l_prev_task_status = ' || l_prev_task_status || ' for transaction_temp_id:  '
                                          || rec_reset_task_status.transaction_temp_id);
          UPDATE  wms_dispatched_tasks
             SET  status =  l_prev_task_status
                 ,last_update_date = SYSDATE
                 ,last_updated_by = p_user_id
           WHERE  task_id = rec_reset_task_status.task_id;

          IF SQL%NOTFOUND THEN
              mydebug('task_id : ' || rec_reset_task_status.task_id || ' : not found to be updated');
          END IF;

    END LOOP ;

    l_progress := 200;
    mydebug('l_progress =  ' || l_progress);

    DELETE  wms_dispatched_tasks
     WHERE  person_id = p_employee_id
      AND (status  = l_g_task_pending OR
           status  = l_g_task_dispatched  OR
           status  = l_g_task_active) ; -- IN (3,9 ) ;

    IF SQL%NOTFOUND THEN
        mydebug('no WDT with status 3,9,1 remaining to delete for this employee id   ' );
       --It is OK not to find even one task to delete
    ELSE
       mydebug('Deleted all WDT with staus 3,9,1 for p_employee_id =  ' || p_employee_id);
    END IF;

    l_progress := 300;
    mydebug('l_progress =  ' || l_progress);
    UPDATE  wms_dispatched_tasks
       SET  task_method = NULL  -- for cluster picking
     WHERE  person_id = p_employee_id
       AND  status = l_g_task_queued;

    IF SQL%NOTFOUND THEN
        mydebug('no WDT to update for this employee id to be updated for cluster picking case' );
       --It is OK not to find even one task to update
    END IF;

mydebug('END = ' || l_proc_name );
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
END proc_reset_task_status;

 --viks procedure proc_start_over
 /*{{
 * When startover button is pressed proc_start_over is called which would return
 * no of task to be processed
 *}}
  */


PROCEDURE proc_start_over
             (p_transaction_header_id       IN NUMBER
                     ,p_transaction_temp_id  IN NUMBER
                     ,p_user_id             IN  NUMBER
                     ,x_start_over_taskno   OUT NOCOPY NUMBER
                     ,x_return_status       OUT NOCOPY VARCHAR2
                     ,x_msg_count           OUT NOCOPY NUMBER
                     ,x_msg_data            OUT  NOCOPY VARCHAR2 )

IS
    l_proc_name                   VARCHAR2(30) :=  'PROC_START_OVER';
    l_progress                    VARCHAR2(30) :=  '100';
    l_debug                       NUMBER       :=  NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_prev_task_status    NUMBER     :=0;
    l_last_index          NUMBER := NULL;
    l_first_index         NUMBER := NULL;
    l_existing_count      NUMBER :=0;
    l_move_index_offset   NUMBER :=0;
    new_mmtt_count            NUMBER := 0;
    m_count               NUMBER :=0;
    i               NUMBER :=0;
    p               NUMBER :=0;
    L              NUMBER :=0;


 CURSOR   tempid_cur  (v_transaction_temp_id  NUMBER)  IS
  SELECT transaction_temp_id from mtl_allocations_gtmp
  WHERE transaction_temp_id <> v_transaction_temp_id
  ORDER BY  transaction_temp_id;


BEGIN

    x_return_status  := fnd_api.g_ret_sts_success;
    mydebug ('IN : ' || l_proc_name);
   mydebug ('p_transaction_header_id : ' || p_transaction_header_id);
   mydebug ('p_transaction_temp_id   : ' || p_transaction_temp_id  );
   l_progress := 110;

  l_prev_task_status := wms_picking_pkg.g_previous_task_status(p_transaction_temp_id);

 SELECT count(*)  into new_mmtt_count from mtl_allocations_gtmp;
   mydebug('Total count in mtl_allocations_gtemp: ' || new_mmtt_count);

  l_first_index := wms_picking_pkg.g_start_over_tempid.first;
  l_existing_count := wms_picking_pkg.g_start_over_tempid.count-1;

  mydebug('l_first_index is : ' ||l_first_index);
  mydebug('l_existing_count is : ' || l_existing_count);

  IF  l_first_index IS NULL THEN
      l_first_index  :=0 ;
  END IF;

   --setting the sequence space

  IF l_first_index >0 and new_mmtt_count >0 THEN
      l_move_index_offset := (new_mmtt_count+1) - l_first_index;
      mydebug('Inl_move_index_offset:'||l_move_index_offset);
      if (l_move_index_offset >0) then  -- move forward
        for i in REVERSE l_first_index .. (l_first_index+l_existing_count) LOOP
         wms_picking_pkg.g_start_over_tempid(i+l_move_index_offset) := wms_picking_pkg.g_start_over_tempid(i);
        mydebug('In else index :' ||i);
        END LOOP;

      elsif (l_move_index_offset <0) then -- move backward
          for i in l_first_index..l_first_index+l_existing_count LOOP
           wms_picking_pkg.g_start_over_tempid(i+l_move_index_offset) := wms_picking_pkg.g_start_over_tempid(i);
           wms_picking_pkg.g_start_over_tempid.DELETE(i);
        mydebug('In else if index offset is Neg:' ||wms_picking_pkg.g_start_over_tempid(i+l_move_index_offset));
        mydebug('In elseif index :' ||i);
          END LOOP;
     end if;
  END IF;
   mydebug('Cont of table :'||wms_picking_pkg.g_start_over_tempid.COUNT);
  -- insert  temp id value into pl/sql table

   p := 1;
   FOR tempid_rec IN tempid_cur(v_transaction_temp_id => p_transaction_temp_id)
   LOOP
     wms_picking_pkg.g_start_over_tempid(p) := tempid_rec.transaction_temp_id;
     mydebug('Temp ids in plsql :'||wms_picking_pkg.g_start_over_tempid(p)||'Index:'||p);
    wms_picking_pkg.g_previous_task_status(wms_picking_pkg.g_start_over_tempid(p)) :=l_prev_task_status;
     p := p +1;
      IF SQL%NOTFOUND THEN
          mydebug('transaction_temp_id  not found only one temp_id present: ');
           p :=1;
          END IF;

   END LOOP;

   wms_picking_pkg.g_start_over_tempid(p):= p_transaction_temp_id;
   mydebug('Temp id sent last is :'||wms_picking_pkg.g_start_over_tempid(p) ||'Index is::'||p);

  L:=0;

 -- Updating wdd status and printing  final values sent in pl/sql table

    forall L in wms_picking_pkg.g_start_over_tempid.FIRST .. wms_picking_pkg.g_start_over_tempid.LAST
       UPDATE  wms_dispatched_tasks
       SET  status = l_g_task_dispatched
           ,last_update_date = SYSDATE
           ,last_updated_by = p_user_id
       WHERE transaction_temp_id = wms_picking_pkg.g_start_over_tempid(L);
       IF SQL%NOTFOUND THEN
          mydebug('transaction_temp_id : ' ||wms_picking_pkg.g_start_over_tempid(L) ||' : not found to be updated');
       END IF;

    IF (l_debug = 1) THEN
     L :=0;
    FOR  L IN  wms_picking_pkg.g_start_over_tempid.FIRST .. wms_picking_pkg.g_start_over_tempid.LAST
    LOOP
    mydebug('values sent are :' || wms_picking_pkg.g_start_over_tempid(L) || 'value of L' ||L);
      IF SQL%NOTFOUND THEN
          mydebug('transaction_temp_id : ' ||wms_picking_pkg.g_start_over_tempid(L) ||' : not found to be updated');
          END IF;
    END LOOP;
   END IF;

   x_start_over_taskno := wms_picking_pkg.g_start_over_tempid.count;
    mydebug('x_start_over_taskno in procedure start_over::'||x_start_over_taskno);
   mydebug('END = ' || l_proc_name );
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);

END  proc_start_over;



PROCEDURE proc_parse_lot_serial_catchwt
              (p_inventory_item_id               IN          NUMBER
              ,p_confirmed_lots                  IN          VARCHAR2
              ,p_confirmed_lot_trx_qty           IN          VARCHAR2
              ,p_confirmed_serials               IN          VARCHAR2
              ,p_suggested_uom                   IN          VARCHAR2
              ,p_confirmed_uom                   IN          VARCHAR2
              ,p_primary_uom                     IN          VARCHAR2
              ,p_confirmed_sec_uom               IN          VARCHAR2
              ,p_confirmed_sec_qty               IN          VARCHAR2
              ,x_return_status                   OUT NOCOPY  VARCHAR2
              ,x_msg_count                       OUT NOCOPY  NUMBER
              ,x_msg_data                        OUT NOCOPY  VARCHAR2)
IS
   l_proc_name                   VARCHAR2(30)   :=  'PROC_PARSE_LOT_SERIAL_CATCHWT';
   l_progress                    VARCHAR2(30)   :=  '100';
   l_delimiter                   VARCHAR2(30)   :=  ':';
   l_group_delimiter             VARCHAR2(30)   :=  ';';
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   l_lot_number                  VARCHAR2(80)   :=  NULL;
   l_serial_number               VARCHAR2(30)   :=  NULL;
   l_group_serials               VARCHAR2(30000) :=  NULL;  -- Bug 7518135
   l_lot_trx_qty                 NUMBER         :=  NULL;
   l_lot_prim_qty                NUMBER         :=  NULL;
   l_lot_sugg_qty                NUMBER         :=  NULL;
   l_sec_qty                     NUMBER         :=  NULL;
   -- To store a new number for each lot so that all serials for a lot will have the same number
   l_group_number                NUMBER         :=  0;
   -- To parse lots
   m                             NUMBER := 1;  -- position of delimiter
   n                             NUMBER := 1;  -- Start position for substr or search for delimiter
   i                             NUMBER := 1;  -- position of delimiter
   j                             NUMBER := 1;  -- Start position for substr or search for delimiter
   -- To parse Serials
   x                             NUMBER := 1;  -- position of delimiter
   y                             NUMBER := 1;  -- Start position for substr or search for delimiter
   s                             NUMBER := 1;  -- position of delimiter
   t                             NUMBER := 1;  -- Start position for substr or search for delimiter
   -- To parse Secondary qty
   k                             NUMBER := 1;  -- position of delimiter
   l                             NUMBER := 1;  -- Start position for substr or search for delimiter
   l_number_format_mask          VARCHAR2(30) :=   'FM9999999999.99999999999999'; --Bug#6274290

BEGIN
   x_return_status  := l_g_ret_sts_success;
   mydebug ('In  :' || l_proc_name );

   DELETE  mtl_allocations_gtmp ;
   IF SQL%NOTFOUND THEN
       null;
   END IF;

   WHILE  (j <> 0 AND n <> 0)
   LOOP
   -- Parse P_confirmed_lots and  p_confirmed_lot_trx_qty
          -- N is the delimiter position,
          -- M is the position from which to start looking for the first delimiter
          -- for string 'L001:L002:L003' M=1, N=5 for the first search .
          --             M=5+1=6, N=10 for the next search .
          --             M=10+1=11, N=0 for the next search because this is the last part of string.
          --serial_controlled ..p_confrimed_serials will have serials for a LOT delimited by :
          --AND  serials for different lots delimited by ';'
          --Have serials for a lot in l_lot_serials string and parse it

          l_progress    :=  '110';
          n := INSTR(p_confirmed_lots,l_delimiter,m,1);
          j := INSTR(p_confirmed_lot_trx_qty,l_delimiter,i,1);
          l_group_number := l_group_number + 1;

          mydebug ('m:' || m||':n:' || n || ':i:' || i||':j:'||j );
          IF n = 0 THEN -- Last part OF the string
             l_lot_number :=  substr(p_confirmed_lots,m,length(p_confirmed_lots));
          ELSE
             l_lot_number :=  substr(p_confirmed_lots,m,n-m) ;-- start at M get m-n chrs.
             m := n+1;
          END IF;
          mydebug ('l_lot_number:' || l_lot_number);
          -- Parse  p_confirmed_lot_trx_qty
          IF j = 0 THEN -- Last part OF the string
             l_lot_trx_qty :=  to_number(substr(p_confirmed_lot_trx_qty,i,length(p_confirmed_lot_trx_qty)) ,l_number_format_mask ) ; --Bug#6274290.
          ELSE
             l_lot_trx_qty :=  to_number(substr(p_confirmed_lot_trx_qty,i,j-i), l_number_format_mask ) ;-- start at i till i-j position
             i := j+1;
          END IF;

          mydebug ('m:' || m||':n:' || n || ':i:' || i||':j:'||j );
          mydebug ('l_lot_trx_qty:' || l_lot_trx_qty);
          IF p_primary_uom <> p_confirmed_uom
            THEN
             l_progress    :=  '120';
             l_lot_prim_qty := inv_convert.inv_um_convert
                               (item_id          => p_inventory_item_id
                               ,precision        => l_g_decimal_precision
                               ,from_quantity    => l_lot_trx_qty
                               ,from_unit        => p_confirmed_uom
                               ,to_unit          => p_primary_uom
                               ,from_name        => NULL
                               ,to_name          => NULL);
          ELSE
             l_progress    :=  '130';
             l_lot_prim_qty := l_lot_trx_qty;
          END IF;

          l_progress    :=  '140';
          mydebug ('l_lot_prim_qty:' || l_lot_prim_qty);

          IF p_suggested_uom <> p_confirmed_uom
            THEN
             l_progress    :=  '120';
             l_lot_sugg_qty := inv_convert.inv_um_convert
                               (item_id          => p_inventory_item_id
                               ,precision        => l_g_decimal_precision
                               ,from_quantity    => l_lot_trx_qty
                               ,from_unit        => p_confirmed_uom
                               ,to_unit          => p_suggested_uom
                               ,from_name        => NULL
                               ,to_name          => NULL);
          ELSE
             l_progress    :=  '130';
             l_lot_sugg_qty := l_lot_trx_qty;
          END IF;

          l_progress    :=  '140';
          mydebug ('l_lot_sugg_qty:' || l_lot_sugg_qty);

          IF (p_confirmed_sec_qty  IS NOT NULL)
            AND
             (p_confirmed_lots     IS NOT NULL)
          THEN
             -- Secondary qty is at lot level (MTLT) for lot and Lot+serial controlled item
             -- Secondary qty is at MMTT level for serial controlled item
             l := INSTR(p_confirmed_sec_qty,l_delimiter,k,1);
             l_group_number := l_group_number + 1;

             mydebug ('k:' || k||':l:' || l );
             IF n = 0 THEN -- Last part OF the string
                l_sec_qty := to_number( substr(p_confirmed_sec_qty,k,length(p_confirmed_sec_qty)), l_number_format_mask ); --Bug#6274290.
             ELSE
                l_sec_qty := to_number( substr(p_confirmed_sec_qty,k,l-k),l_number_format_mask );-- start at k get k-l chrs.
                k := l+1;
             END IF;
             mydebug ('l_sec_qty:' || l_sec_qty);

          END IF;

          IF ( p_confirmed_serials IS NOT NULL)
          THEN
        -- Parse p_confirmed_serials
               -- Y is the delimiter position,
               -- X is the position from which to start looking for the first delimiter l_group_delimiter
               -- for string 'L001:L002:L003;L004:L001' X=1, Y=15 for the first search .
               --             X=15+1=16, Y=0 for the next search because this is the last part of string.
               l_group_serials := NULL;
               WHILE y <> 0  -- to substr the group
               LOOP
                  y := instr(p_confirmed_serials, l_group_delimiter, x, 1);
                  IF (y=0) then
                     l_group_serials := substr(p_confirmed_serials,x,length(p_confirmed_serials));
                  ELSE
                     l_group_serials := substr(p_confirmed_serials,x,y-x);
                     x := y+1;
                  END IF;

                  s := 1;
                  t := 1;
                  WHILE  (t <> 0)
                  LOOP
                       l_progress    :=  '110';
                -- Parse l_group_serials
                       -- T is the delimiter position,
                       -- S is the position from which to start looking for the first delimiter
                       -- for string 'L001:L002:L003' S=1, T=5 for the first search .
                       --             S=5+1=6, T=10 for the next search .
                       --             S=10+1=11, T=0 for the next search because this is the last part of string.
                       t := nvl(INSTR(l_group_serials,l_delimiter,s,1),0);
                       mydebug ('s:' || s||':t:' || t );
                       IF t = 0 THEN -- Last part OF the string
                   l_serial_number :=  substr(l_group_serials,s,length(l_group_serials));
                ELSE
                   l_serial_number :=  substr(l_group_serials,s,t-s) ;-- start at M get s-t chrs.
                   s := t+1;
                END IF;
                       mydebug ('l_serial_number:' || l_serial_number);
                       mydebug ('s:' || s||':t:' || t );
                       INSERT
                         INTO mtl_allocations_gtmp
                               (transaction_temp_id
                              , lot_number
                              , serial_number
                              , transaction_quantity
                              , primary_quantity
                              , suggested_quantity
                              , secondary_quantity)
                       VALUES  (l_group_number
                              , l_lot_number
                              , l_serial_number
                              , l_lot_trx_qty
                              , l_lot_prim_qty
                              , l_lot_sugg_qty
                              , l_sec_qty );
                  END LOOP;
                  EXIT;
               END LOOP;
          ELSE
             INSERT
               INTO mtl_allocations_gtmp
                     (transaction_temp_id
                    , lot_number
                    , serial_number
                    , transaction_quantity
                    , primary_quantity
                    , suggested_quantity
                    , secondary_quantity)
             VALUES  (l_group_number
                    , l_lot_number
                    , NULL
                    , l_lot_trx_qty
                    , l_lot_prim_qty
                    , l_lot_sugg_qty
                    , l_sec_qty );
          END IF;
   END LOOP;

   mydebug('END = ' || l_proc_name );
EXCEPTION
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);

END proc_parse_lot_serial_catchwt;


PROCEDURE task_load(
               p_action                          IN            VARCHAR2
             , p_organization_id                 IN            NUMBER
             , p_user_id                         IN            NUMBER
             , p_person_id                       IN            NUMBER
             , p_transaction_header_id           IN            NUMBER
             , p_temp_id                         IN            NUMBER
             , p_parent_line_id                  IN            NUMBER    -- For bulk parent
             , p_lpn_id                          IN            NUMBER
             , p_content_lpn_id                  IN            NUMBER
             , p_transfer_lpn_id                 IN            NUMBER
             , p_confirmed_sub                   IN            VARCHAR2
             , p_confirmed_loc_id                IN            NUMBER
             , p_confirmed_uom                   IN            VARCHAR2
             , p_suggested_uom                   IN            VARCHAR2
             , p_primary_uom                     IN            VARCHAR2
             , p_item_id                         IN            NUMBER
             , p_revision                        IN            VARCHAR2
             , p_confirmed_qty                   IN            NUMBER
             , p_confirmed_lots                  IN            VARCHAR2
             , p_confirmed_lot_trx_qty           IN            VARCHAR2
             , p_confirmed_sec_uom               IN            VARCHAR2
             , p_confirmed_sec_qty               IN            VARCHAR2
             , p_confirmed_serials               IN            VARCHAR2
             , p_container_item_id               IN            NUMBER
             , p_transaction_type_id             IN            NUMBER
             , p_transaction_source_type_id      IN            NUMBER
             , p_lpn_match                       IN            NUMBER
             , p_lpn_match_lpn_id                IN            NUMBER
             , p_serial_allocated_flag           IN            VARCHAR2  -- Y/V or NULL
             , p_lot_controlled                  IN            VARCHAR2  -- Y/N
             , p_serial_controlled               IN            VARCHAR2  -- Y/N
             , p_effective_start_date            IN            DATE
             , p_effective_end_date              IN            DATE
             , p_exception                       IN            VARCHAR2  -- SHORT, OVER
             , p_discrepancies                   IN            VARCHAR2
             , p_qty_rsn_id                      IN            NUMBER
             , p_parent_lpn_id                   IN            NUMBER
             , p_lpnpickedasis                   IN            VARCHAR2    --Y/N
             , x_new_transaction_temp_id         OUT NOCOPY    NUMBER
             , x_cms_check                       OUT NOCOPY    VARCHAR2
             , x_return_status                   OUT NOCOPY    VARCHAR2
             , x_msg_count                       OUT NOCOPY    NUMBER
             , x_msg_data                        OUT NOCOPY    VARCHAR2
	     , p_substitute_lots		 IN	       VARCHAR2  --/* Bug 9448490 Lot Substitution Project */
            )
IS
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(4000);
  l_debug                 NUMBER:= NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  l_proc_name             VARCHAR2(30) :=  'TASK_LOAD';
  l_progress              VARCHAR2(30) :=  '100';
  l_temp_id               NUMBER;
  l_business_flow_code    NUMBER;
  l_label_status          VARCHAR2(300);
  l_tran_type_id          NUMBER := p_transaction_type_id; -- Bug 3693953
  l_tran_source_type_id   NUMBER := p_transaction_source_type_id; -- Bug 3693953
  l_out_temp_id           NUMBER;
  l_multiple_pick         VARCHAR2(1) := NULL;
  l_overpick              VARCHAR2(1) := NULL;
  l_new_txn_hdr_id        NUMBER;
  l_lpn_quantity	  NUMBER;

  l_parent_line_id        NUMBER := p_parent_line_id;
  l_lpn_id                NUMBER := p_lpn_id;
  l_content_lpn_id        NUMBER := p_content_lpn_id;
  l_transfer_lpn_id       NUMBER := p_transfer_lpn_id;
  l_container_item_id     NUMBER := p_container_item_id;
  l_lpn_match_lpn_id      NUMBER := p_lpn_match_lpn_id;
  l_qty_rsn_id            NUMBER := p_qty_rsn_id;
  l_parent_lpn_id         NUMBER := p_parent_lpn_id;
  l_lpn_match             NUMBER := p_lpn_match;
  l_transaction_temp_id   NUMBER := p_temp_id;
  --Bug #4762505
 	--Local variables for updating MOL
 	l_mo_line_id            NUMBER;       --Move Order Line OD
 	l_mol_uom               VARCHAR2(3);  --UOM Code of the MOL
 	l_sum_mmtt_qty          NUMBER;       --Total MMTT primary quantity
 	l_mmtt_qty_in_mol_uom   NUMBER;       --Total MMTT qty in MOL UOM

  CURSOR mmtt_csr2(p_transaction_header_id NUMBER) IS
       SELECT mmtt.transaction_temp_id
         FROM mtl_material_transactions_temp mmtt
        WHERE mmtt.transaction_header_id = p_transaction_header_id;

  CURSOR lot_csr IS
     SELECT lot_number, serial_transaction_temp_id
      FROM  mtl_transaction_lots_temp
      WHERE transaction_temp_id = p_temp_id;

  CURSOR insert_serial_allocated_csr (p_serial_lot_number  VARCHAR2) IS
   SELECT serial_number
    FROM  mtl_serial_numbers  msn
    WHERE msn.current_organization_id  = p_organization_id
    AND   msn.inventory_item_id        = p_item_id
    AND   lpn_id                       =  p_lpn_match_lpn_id
    AND   NVL(msn.lot_number,'@@')     =  NVL(p_serial_lot_number, '@@')
    AND   msn.serial_number  NOT IN
          ( select msnt.fm_serial_number
            from mtl_serial_numbers_temp  msnt,
                 mtl_transaction_lots_temp mtlt,
                 mtl_material_transactions_temp  mmtt
            where mmtt.inventory_item_id = p_item_id
             AND mmtt.organization_id = p_organization_id
             and mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
             AND msnt.transaction_temp_id = NVL(mtlt.serial_transaction_temp_id, mmtt.transaction_temp_id)
             and NVL(mtlt.lot_number, '@@') = NVL(p_serial_lot_number, '@@')
             and mmtt.transaction_temp_id = p_temp_id);

BEGIN

      x_return_status   := fnd_api.g_ret_sts_success;
      l_return_status   := fnd_api.g_ret_sts_success;
      IF p_parent_line_id = 0    THEN l_parent_line_id := NULL;     END IF;
      IF p_lpn_id = 0            THEN l_lpn_id := NULL;             END IF;
      IF p_content_lpn_id = 0    THEN l_content_lpn_id := NULL;     END IF;
      IF p_parent_lpn_id = 0     THEN l_parent_lpn_id := NULL;      END IF;
      IF p_transfer_lpn_id = 0   THEN l_transfer_lpn_id := NULL;    END IF;
      IF p_container_item_id = 0 THEN l_container_item_id := NULL;  END IF;
      IF p_lpn_match_lpn_id = 0  THEN l_lpn_match_lpn_id := NULL;   END IF;
      IF p_qty_rsn_id = 0        THEN l_qty_rsn_id := NULL;         END IF;

      IF (l_debug = 1) THEN
        mydebug ('l_progress: ' || l_progress );
        mydebug('Entered..... task_Load');
        mydebug('p_action:'||p_action);
        mydebug('p_organization_id:'||p_organization_id);
        mydebug('p_user_id:'||p_user_id);
        mydebug('p_person_id:'||p_person_id);
        mydebug('p_transaction_header_id:'||p_transaction_header_id);
        mydebug('p_temp_id:'||p_temp_id);
        mydebug('p_parent_line_id:'||p_parent_line_id ||':' || l_parent_line_id);
        mydebug('p_lpn_id:' ||p_lpn_id ||':' || l_lpn_id);
        mydebug('p_content_lpn_id:' ||p_content_lpn_id ||':'||l_content_lpn_id);
        mydebug('p_parent_lpn_id:' ||p_parent_lpn_id ||':'||l_parent_lpn_id);
        mydebug('p_transfer_lpn_id:' ||p_transfer_lpn_id ||':' || l_transfer_lpn_id);
        mydebug('p_confirmed_sub:' ||p_confirmed_sub);
        mydebug('p_confirmed_loc_id:' ||p_confirmed_loc_id);
        mydebug('p_confirmed_uom:' ||p_confirmed_uom);
        mydebug('p_suggested_uom:' ||p_suggested_uom);
        mydebug('p_primary_uom  :' ||p_primary_uom  );
        mydebug('p_item_id:' ||p_item_id);
        mydebug('p_revision:' ||p_revision);
        mydebug('p_confirmed_qty:' ||p_confirmed_qty);
        mydebug('p_confirmed_lots:' ||p_confirmed_lots);
        mydebug('p_confirmed_lot_trx_qty:' ||p_confirmed_lot_trx_qty);
        mydebug('p_confirmed_sec_uom:' ||p_confirmed_sec_uom);
        mydebug('p_confirmed_sec_qty:' ||p_confirmed_sec_qty);
        mydebug('p_confirmed_serials:' ||p_confirmed_serials);
        mydebug('p_container_item_id:' ||p_container_item_id ||':' || l_container_item_id);
        mydebug('p_transaction_type_id: ' || p_transaction_type_id);
        mydebug('p_transaction_source_type_id: ' || p_transaction_source_type_id);
        mydebug('p_lpn_match:' ||p_lpn_match);
        mydebug('p_lpn_match_lpn_id:' ||p_lpn_match_lpn_id || ':' || l_lpn_match_lpn_id);
        mydebug('p_serial_allocated_flag:' ||p_serial_allocated_flag);
        mydebug('p_lot_controlled:' ||p_lot_controlled);
        mydebug('p_serial_controlled:' ||p_serial_controlled);
        mydebug('p_effective_start_date:' ||p_effective_start_date);
        mydebug('p_exception:' ||p_exception);
        mydebug('p_discrepancies:' ||p_discrepancies);
        mydebug('p_qty_rsn_id:' ||p_qty_rsn_id || ':' || l_qty_rsn_id);
        mydebug('p_lpnpickedasis:'||p_lpnpickedasis);

      END IF;

      l_progress    :=  '130';
      IF (l_debug = 1) THEN mydebug ('l_progress: ' || l_progress ); END IF;
      IF p_confirmed_qty = 0 AND p_exception <> l_g_exception_short
      THEN
         fnd_message.set_name('WMS', 'WMS_PICK_ZERO_QTY');
         -- Confirmed qty for this task is zero
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
     BEGIN
        wms_picking_pkg.g_previous_task_status.delete(p_temp_id);
     EXCEPTION
     WHEN OTHERS THEN
       null; -- it is ok not to find it.
     END ;

     --Bug #4762505
     --Get the move_order_line_id for the current task
     BEGIN
       SELECT move_order_line_id
       INTO   l_mo_line_id
       FROM   mtl_material_transactions_temp
       WHERE  transaction_temp_id = p_temp_id;
     EXCEPTION
       WHEN OTHERS THEN
         l_mo_line_id := NULL;
     END;

     --8761670/8798363 start
     BEGIN
        SELECT Sum(quantity) INTO l_lpn_quantity
        FROM wms_lpn_contents
        WHERE parent_lpn_id = p_lpn_id
        AND organization_id = p_organization_id
        AND inventory_item_id = p_item_id ;


        IF (l_debug = 1) THEN
             mydebug ('l_lpn_quantity', l_lpn_quantity);
         END IF;

     EXCEPTION
     WHEN OTHERS THEN
        NULL;
     END;

      IF l_lpn_match = 4 AND p_exception = 'OVER' AND l_lpn_quantity = p_confirmed_qty THEN
         l_lpn_match := 3;
         l_content_lpn_id := l_lpn_id;
         l_lpn_id :=null;
         IF (l_debug = 1) THEN
            mydebug ('lpn_match is 4 and total qty in lpn is to be consumed thru over picking, so changing match to 3');
         END IF;

         /*Now that LPN is fully consumable, we need to popuate parent_lpn_id
           if the picked LPN is already nested into another LPN */
         IF (l_parent_lpn_id IS NULL ) THEN
	         SELECT parent_lpn_id INTO l_parent_lpn_id
        	 FROM WMS_LICENSE_PLATE_NUMBERS
	         WHERE lpn_id=l_content_lpn_id ;
         END IF;
         IF (l_debug = 1) THEN
            mydebug ('parent_lpn_id:'||l_parent_lpn_id||',content_lpn_id:'||l_content_lpn_id);
         END IF;
      END IF;

     --8761670/8798363 end


     -- bug 3983704
     IF l_lpn_match =4 and p_transfer_lpn_id = p_lpn_id THEN
         l_lpn_match := 1;
         l_content_lpn_id := l_lpn_id;
         l_lpn_id :=null;
         IF (l_debug = 1) THEN
             mydebug ('lpn_match is 4 and to lpn=from lpn');
         END IF;
     END IF;

     --jxlu for lpn overpicking

     IF   p_lpnpickedasis = 'Y'
     THEN
         IF (l_debug = 1) THEN
            mydebug ('lpn_match is 4 and lpnpickedasis is true, change lpn_match to 1 ');
         END IF;
         l_lpn_match := 1;
         IF     p_serial_controlled = 'Y'
            AND p_serial_allocated_flag = 'Y'
         THEN
              -- if lot controlled
              IF p_lot_controlled = 'Y' THEN
                     FOR lot_rec in lot_csr LOOP
                         IF (l_debug = 1) THEN
                             mydebug ('item is lot controlled and current lot is: '||lot_rec.lot_number);
                         END IF;
                         FOR serial_rec in insert_serial_allocated_csr(lot_rec.lot_number) LOOP
                            -- insert serial into msnt and mark msn
                              insert_serial(
                                  p_serial_transaction_temp_id  => lot_rec.serial_transaction_temp_id,
                                  p_organization_id             => p_organization_id,
                                  p_item_id                     => p_item_id,
                                  p_revision                    => p_revision,
                                  p_lot                         => lot_rec.lot_number,
                                  p_transaction_temp_id         => p_temp_id,
                                  p_created_by                  => p_user_id,
                                  p_from_serial                 => serial_rec.serial_number,
                                  p_to_serial                   => serial_rec.serial_number,
                                  p_status_id                   => NULL,
                                  x_return_status               => l_return_status,
                                  x_msg_data                    => l_msg_data);
                               IF l_return_status IN ( fnd_api.g_ret_sts_unexp_error, fnd_api.g_ret_sts_error)
                               THEN
                                      fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR');
                                      -- Internal Error $ROUTINE
                                      fnd_message.set_token('ROUTINE', '-INSERT_SERIAL API - ' || p_action);
                                      fnd_msg_pub.ADD;
                                      RAISE fnd_api.g_exc_unexpected_error;
                               ELSE
                                   IF (l_debug = 1) THEN
                                        mydebug ('the serial number is:  '|| serial_rec.serial_number);
                                   END IF;
                               END IF;
                         END LOOP;
                     END LOOP;
              ELSE
                     IF (l_debug = 1) THEN
                           mydebug ('only serial controlled item and serial is allocated');
                     END IF;
                     FOR serial_rec IN insert_serial_allocated_csr(NULL) LOOP
                          -- insert serial into msnt and mark msn
                          insert_serial(
                                  p_serial_transaction_temp_id  => l_transaction_temp_id,
                                  p_organization_id             => p_organization_id,
                                  p_item_id                     => p_item_id,
                                  p_revision                    => p_revision,
                                  p_lot                         => NULL,
                                  p_transaction_temp_id         => p_temp_id,
                                  p_created_by                  => p_user_id,
                                  p_from_serial                 => serial_rec.serial_number,
                                  p_to_serial                   => serial_rec.serial_number,
                                  p_status_id                   => NULL,
                                  x_return_status               => l_return_status,
                                  x_msg_data                    => l_msg_data);
                          IF l_return_status IN ( fnd_api.g_ret_sts_unexp_error, fnd_api.g_ret_sts_error)
                          THEN
                                 fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR');
                                 -- Internal Error $ROUTINE
                                  fnd_message.set_token('ROUTINE', '- INSERT_SERIAL API - ');
                                  fnd_msg_pub.ADD;
                                  RAISE fnd_api.g_exc_unexpected_error;
                          ELSE
                              IF (l_debug = 1) THEN
                                  mydebug ('the serial number is:  '|| serial_rec.serial_number);
                              END IF;
                         END IF;
                     END LOOP;
              END IF;
         END IF;
     END IF;

     IF p_confirmed_qty <> 0 THEN
         l_progress    :=  '140';
         IF (l_debug = 1) THEN mydebug ('l_progress: ' || l_progress ); END IF;
        task_merge_split(
                      p_action                 => p_action
                     ,p_exception              => p_exception
                     ,p_organization_id        => p_organization_id
                     ,p_user_id                => p_user_id
                     ,p_transaction_header_id  => p_transaction_header_id
                     ,p_transaction_temp_id    => p_temp_id
                     ,p_parent_line_id         => p_parent_line_id
                     ,p_remaining_temp_id      => NULL
                     ,p_lpn_id                 => l_lpn_id
                     ,p_content_lpn_id         => l_content_lpn_id
                     ,p_transfer_lpn_id        => l_transfer_lpn_id
                     ,p_confirmed_sub          => p_confirmed_sub
                     ,p_confirmed_locator_id   => p_confirmed_loc_id
                     ,p_confirmed_uom          => p_confirmed_uom
                     ,p_suggested_uom          => p_suggested_uom
                     ,p_primary_uom            => p_primary_uom
                     ,p_inventory_item_id      => p_item_id
                     ,p_revision               => p_revision
                     ,p_confirmed_trx_qty      => p_confirmed_qty
                     ,p_confirmed_lots         => p_confirmed_lots
                     ,p_confirmed_lot_trx_qty  => p_confirmed_lot_trx_qty
                     ,p_confirmed_sec_uom      => p_confirmed_sec_uom
                     ,p_confirmed_sec_qty      => p_confirmed_sec_qty
                     ,p_confirmed_serials      => p_confirmed_serials
                     ,p_container_item_id      => l_container_item_id
                     ,p_lpn_match              => l_lpn_match
                     ,p_lpn_match_lpn_id       => l_lpn_match_lpn_id
                     ,p_serial_allocated_flag  => p_serial_allocated_flag
                     ,p_lot_controlled         => p_lot_controlled
                     ,p_serial_controlled      => p_serial_controlled
                     ,p_parent_lpn_id          => l_parent_lpn_id
                     --,p_lpnpickedasis          => p_lpnpickedasis
                     ,x_new_transaction_temp_id=> l_out_temp_id
                     ,x_cms_check              => x_cms_check
                     ,x_return_status          => l_return_status
                     ,x_msg_count              => l_msg_count
                     ,x_msg_data               => l_msg_data
		     ,p_substitute_lots	       => p_substitute_lots); --/* Bug 9448490 Lot Substitution Project */

         IF l_return_status IN ( fnd_api.g_ret_sts_unexp_error, fnd_api.g_ret_sts_error)
         THEN
            fnd_message.set_name('WMS', 'WMS_INTERNAL_ERROR');
            -- Internal Error $ROUTINE
            fnd_message.set_token('ROUTINE', '-Task_Merge_Split API - ' || p_action);
            fnd_msg_pub.ADD;
            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
            ELSE
                 RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF; -- confirmed_qty <> 0

   -- REASONS ...EXCEPTION HANDLING  will deal with MOL upd'ns , deletion of MMTT and its children etc.
   -- NO REASONS ...EXCEPTION HANDLING  o  for BULJK.... Janet will call from bulk API
   -- BULK API .. to process children etc
   -- No LAbel printing of BULK

   l_progress    :=  '200';
   IF (l_debug = 1) THEN    mydebug ('l_progress: ' || l_progress );    END IF;
   IF p_action = l_g_action_load_multiple
   THEN
       l_multiple_pick := 'Y';
   ELSE
       l_multiple_pick := 'N';
   END IF;
   l_progress    :=  '210';
   IF (l_debug = 1) THEN    mydebug ('l_progress: ' || l_progress );    END IF;

   /* IF p_discrepancies IS NOT NULL
     -- there are non quantity discrepencies to be logged
     -- in wms_exceptions table.
     -- it also includes overpick and shortpick for LPN/Lot.
     -- Qty exception is one where total picked < suggested
     -- and there can be only one qty exception for a task. */

   IF p_discrepancies IS NOT NULL
   THEN
      l_progress    :=  '300';
      IF (l_debug = 1) THEN    mydebug ('l_progress: ' || l_progress );    END IF;
      wms_txnrsn_actions_pub.process_exceptions
               ( p_organization_id          => p_organization_id
                ,p_employee_id              => p_person_id
                ,p_effective_start_date     => p_effective_start_date
                ,p_effective_end_date       => p_effective_end_date
                ,p_inventory_item_id        => p_item_id
                ,p_revision                 => p_revision
                ,p_discrepancies            => p_discrepancies
                ,x_return_status            => x_return_status
                ,x_msg_count                => x_msg_count
                ,x_msg_data                 => x_msg_data );
      IF (l_debug = 1) THEN
        mydebug ('x_return_status: ' || x_return_status );
      END IF;
       IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       END IF;
   END IF;

   IF l_parent_line_id IS NULL  -- non bulk parent or non-bulk-child
       AND
      --l_qty_rsn_id  IS NOT NULL      -- There is a Curtail pick exception
      p_exception = 'SHORT'
   THEN
      -- it should be called only for qty  exceptions where picked quantity < suggested quantity
      -- and  not for overpicked qty
      l_progress    :=  '400';
      IF (l_debug = 1) THEN    mydebug ('l_progress: ' || l_progress );    END IF;
      wms_txnrsn_actions_pub.cleanup_task
                      ( p_temp_id       => p_temp_id
                      , p_qty_rsn_id    => l_qty_rsn_id
                      , p_user_id       => p_user_id
                      , p_employee_id   => p_person_id
                      , x_return_status => x_return_status
                      , x_msg_count     => x_msg_count
                      , x_msg_data      => x_msg_data);
      IF (l_debug = 1) THEN
        mydebug ('x_return_status: ' || x_return_status );
      END IF;
       IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       END IF;

   END IF;

   -- Bug #: 6908598
-- Calling label printing both for bulk and independent tasks
   BEGIN
       l_business_flow_code  := inv_label.wms_bf_pick_load;
       IF l_tran_type_id = 52 THEN -- Picking for sales order
	  l_business_flow_code  := inv_label.wms_bf_pick_load;
       ELSIF l_tran_type_id = 35 THEN -- WIP issue
	  l_business_flow_code  := inv_label.wms_bf_wip_pick_load;
       ELSIF l_tran_type_id = 51
	  AND l_tran_source_type_id = 13 THEN --Backflush
	  l_business_flow_code  := inv_label.wms_bf_wip_pick_load;
       ELSIF l_tran_type_id = 64
	  AND l_tran_source_type_id = 4 THEN --Replenishment
	     l_business_flow_code  := inv_label.wms_bf_replenishment_load;
       END IF;
       l_progress    :=  '410';
       IF (l_debug = 1) THEN mydebug ('l_business_flow_code: ' || l_business_flow_code ); END IF;

       OPEN mmtt_csr2(p_transaction_header_id);
       LOOP
	  FETCH mmtt_csr2 INTO l_temp_id;
	  EXIT WHEN mmtt_csr2%NOTFOUND;

	  IF (l_debug = 1) THEN
	     mydebug('task_load: Calling label printing for transaction:' || l_temp_id);
	  END IF;

	  inv_label.print_label_wrap(
	  x_return_status              => x_return_status
	  , x_msg_count                  => x_msg_count
	  , x_msg_data                   => x_msg_data
	  , x_label_status               => l_label_status
	  , p_business_flow_code         => l_business_flow_code
	  , p_transaction_id             => l_temp_id
	  );

	  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	     IF (l_debug = 1) THEN mydebug('Label printing failed. Continue'); END IF;
	  END IF;
       END LOOP;

       CLOSE mmtt_csr2;
       END;
 -- End of Bug #: 6908598

   IF nvl(l_parent_line_id,0) = p_temp_id
   THEN
       -- Call Bulk_API to process bulk children
       -- This API will also take care of qty exceptions workflow call for children
       -- affected by picking less than the requested qty
      l_progress    :=  '500';
      IF (l_debug = 1) THEN    mydebug ('l_progress: ' || l_progress );    END IF;
      wms_bulk_pick.bulk_pick(
                 p_temp_id                    => p_temp_id
               , p_txn_hdr_id                 => p_transaction_header_id
               , p_org_id                     => p_organization_id
               , p_multiple_pick              => l_multiple_pick
               , p_exception                  => p_exception
               , p_lot_controlled             => p_lot_controlled
               , p_user_id                    => p_user_id
               , p_employee_id                => p_person_id
               , p_reason_id                  => p_qty_rsn_id
               , x_new_txn_hdr_id             => l_new_txn_hdr_id
               , x_return_status              => x_return_status
               , x_msg_count                  => x_msg_count
               , x_msg_data                   => x_msg_data);


      IF (l_debug = 1) THEN
        mydebug ('l_new_txn_hdr_id: ' || l_new_txn_hdr_id );
        mydebug ('x_return_status: ' || x_return_status );
      END IF;
       IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          --fnd_message.set_name('WMS', 'WMS_MULT_LPN_ERROR');
          --fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          --fnd_message.set_name('WMS', 'WMS_MULT_LPN_ERROR');
          --fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
       END IF;

   /*  -- Bug #: 6908598 Commenting else part as we are calling the label printing irrespective of whether it is a bulk task or not  */
   /*
   ELSE
       -- call label printing for all tasks other than bulk tasks.
      l_progress    :=  '600';
      IF (l_debug = 1) THEN mydebug ('l_progress: ' || l_progress ); END IF;
      BEGIN
         l_business_flow_code  := inv_label.wms_bf_pick_load;
         IF l_tran_type_id = 52 THEN -- Picking for sales order
            l_business_flow_code  := inv_label.wms_bf_pick_load;
         ELSIF l_tran_type_id = 35 THEN -- WIP issue
            l_business_flow_code  := inv_label.wms_bf_wip_pick_load;
         ELSIF l_tran_type_id = 51
            AND l_tran_source_type_id = 13 THEN --Backflush
            l_business_flow_code  := inv_label.wms_bf_wip_pick_load;
         ELSIF l_tran_type_id = 64
            AND l_tran_source_type_id = 4 THEN --Replenishment
               l_business_flow_code  := inv_label.wms_bf_replenishment_load;
         END IF;
         l_progress    :=  '610';
         IF (l_debug = 1) THEN mydebug ('l_business_flow_code: ' || l_business_flow_code ); END IF;

         OPEN mmtt_csr2(p_transaction_header_id);
         LOOP
            FETCH mmtt_csr2 INTO l_temp_id;
            EXIT WHEN mmtt_csr2%NOTFOUND;

            IF (l_debug = 1) THEN
               mydebug('task_load: Calling label printing for transaction:' || l_temp_id);
            END IF;

            inv_label.print_label_wrap(
            x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , x_label_status               => l_label_status
            , p_business_flow_code         => l_business_flow_code
            , p_transaction_id             => l_temp_id
            );

            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
               IF (l_debug = 1) THEN mydebug('Label printing failed. Continue'); END IF;
            END IF;
         END LOOP;

         CLOSE mmtt_csr2;
         END;

	 */


     END IF; -- Not a bulk task.. finished label printing

     --Bug #4762505
     --At the end of the load process, we need to update the quantity_detailed
     --of the move order line. Do this for non-bulk tasks
     IF (l_mo_line_id IS NOT NULL AND l_parent_line_id IS NULL) THEN

       IF (l_debug = 1) THEN
         mydebug('Should update quantity_detailed for MO Line ID: ' || l_mo_line_id);
       END IF;

       --Fetch the UOM code of the MO line and lock the MO line
       SELECT uom_code
       INTO   l_mol_uom
       FROM   mtl_txn_request_lines
       WHERE  line_id = l_mo_line_id
       FOR UPDATE;

       --Fetch the primary quantity for all MMTTs for this MO line
       SELECT ABS(SUM(primary_quantity))
       INTO   l_sum_mmtt_qty
       FROM   mtl_material_transactions_temp
       WHERE  move_order_line_id = l_mo_line_id;

       --Convert the MMTT primary quantity into MOL UOM
       IF p_primary_uom = l_mol_uom THEN
         l_mmtt_qty_in_mol_uom := l_sum_mmtt_qty;
       ELSE
         l_mmtt_qty_in_mol_uom := inv_convert.inv_um_convert
                            (item_id          => p_item_id
                            ,precision        => l_g_decimal_precision
                            ,from_quantity    => l_sum_mmtt_qty
                            ,from_unit        => p_primary_uom
                            ,to_unit          => l_mol_uom
                            ,from_name        => NULL
                            ,to_name          => NULL);
       END IF;

       IF (l_debug = 1) THEN
         mydebug('update quantity_detailed in MOL with: ' || l_mmtt_qty_in_mol_uom);
       END IF;

       --Now update quantity_detailed as quanity_delivered + sum(mmtt qty)
       UPDATE mtl_txn_request_lines
       SET    quantity_detailed = NVL(quantity_delivered, 0) + l_mmtt_qty_in_mol_uom
            , last_update_date     = SYSDATE
            , last_updated_by      = p_user_id
       WHERE  line_id = l_mo_line_id;
     END IF;   --END IF l_mo_line_id IS NOT NULL AND l_parent_line_id IS NULL
     --End changes for Bug #4762505

     IF (l_debug = 1) THEN
           mydebug('End of load_pick');
           mydebug('x_return_status :'||x_return_status);
           mydebug('x_msg_count:'||x_msg_count);
           mydebug('x_msg_data:' || x_msg_data);
     END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_unexpected_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);
        ROLLBACK ;
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        mydebug('ROLLBACK ' );
        ROLLBACK ;
        mydebug('l_progress = ' || l_proc_name || ':'|| l_progress);
        mydebug('RAISE fnd_api.g_exc_error: ' || SQLERRM);
        mydebug('x_msg_count/Data = ' || x_msg_count || '/'|| x_msg_data);

END TASK_LOAD;

/*
     The following table gives the conditions checked by LPN Match
     and its return values

     Condition                            x_match    x_return_status
     =================================================================
     LPN already picked                       7               E
     LPN location is invalid                  6               E
     LPN SUB is null                         10               E
     LPN already staged for another SO       12               E
     Item/Lot/Revision is not in LPN         13               E
     LPN has multiple items,  item_qty<reqQty 2               S
     The user has to manually confirm the LPN
     LPN has requested item but quantity is   4               S
     more than the allocated quantity
     The user has to manually confirm the LPN
     Serial number is not valid for this     11               E
     transaction.
     LPN has requested item with sufficient   8               E
     quantity but LPN content status is
     invalid
     Serial Allocation was requested for the  9               E
     item but it is not allowed/there
     Everything allright and exact quantity   1               S
     match
     Everything allright and quantity in LPN  3               S
     is less than requested quantity

     Although x_match is being set even for error conditions
     it is used by the calling code ONLY in case of success

  */

PROCEDURE lpn_match(
    p_fromlpn_id            IN            NUMBER
  , p_org_id                IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_rev                   IN            VARCHAR2
  , p_lot                   IN            VARCHAR2
  , p_trx_qty               IN            NUMBER
  , p_trx_uom               IN            VARCHAR2
  , p_sec_qty             IN            NUMBER     -- Bug #4141928
  , p_sec_uom             IN            VARCHAR2   -- Bug #4141928
  , x_match                 OUT NOCOPY    NUMBER
  , x_sub                   OUT NOCOPY    VARCHAR2
  , x_loc                   OUT NOCOPY    VARCHAR2
  , x_trx_qty               OUT NOCOPY    NUMBER
  , x_trx_sec_qty         OUT NOCOPY    NUMBER     -- Bug #4141928
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , p_temp_id               IN            NUMBER
  , p_parent_line_id        IN            NUMBER
  , p_wms_installed         IN            VARCHAR2
  , p_transaction_type_id   IN            NUMBER
  , p_cost_group_id         IN            NUMBER
  , p_is_sn_alloc           IN            VARCHAR2
  , p_action                IN            NUMBER
  , p_split                 IN            VARCHAR2
  , p_user_id               IN            NUMBER
  , x_temp_id               OUT NOCOPY    NUMBER
  , x_loc_id                OUT NOCOPY    NUMBER
  , x_lpn_lot_vector        OUT NOCOPY    VARCHAR2
  , x_cms_check             OUT NOCOPY    VARCHAR2
  , x_parent_lpn_id         OUT NOCOPY    VARCHAR2
  , x_trx_qty_alloc         OUT NOCOPY    NUMBER
  , p_transaction_action_id IN            NUMBER
  , p_pickOverNoException   IN            VARCHAR2
  , p_toLPN_Default         IN            VARCHAR2   -- Bug 3855835
  , p_project_id            IN            NUMBER
  , p_task_id               IN            NUMBER
  , p_confirmed_sub         IN            VARCHAR2
  , p_confirmed_loc_id      IN            NUMBER
  , p_from_lpn_id           IN            NUMBER
  , x_toLPN_status          OUT NOCOPY    VARCHAR2 --Bug 3855835
  , x_lpnpickedasis         OUT NOCOPY    VARCHAR2
  , x_lpn_qoh               OUT NOCOPY    NUMBER
    , p_changelotNoException  IN            VARCHAR2 --/* Bug 9448490 Lot Substitution Project */
  ) IS
    l_proc_name              VARCHAR2(30) := 'LPN_MATCH' ;
    l_msg_cnt                NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(240);
    l_exist_qty              NUMBER;
    l_item_cnt               NUMBER;
    l_rev_cnt                NUMBER;
    l_lot_cnt                NUMBER;
    l_item_cnt2              NUMBER;
    l_cg_cnt                 NUMBER;
    l_sub                    VARCHAR2(60);
    l_loc                    VARCHAR2(60);
    l_loaded                 NUMBER         := 0;
    l_allocate_serial_flag   NUMBER         := 0;
    l_temp_serial_trans_temp NUMBER         := 0;
    l_serial_number          VARCHAR2(50);

    l_lpn_pr_qty             NUMBER;
    l_lpn_trx_qty            NUMBER;
  l_lpn_sec_qty            NUMBER;                 -- Bug #4141928

    l_pr_qty                 NUMBER;
    l_primary_uom            VARCHAR2(3);
    l_sec_qty                NUMBER;       -- Bug #4141928
    l_secondary_uom          VARCHAR2(3);       -- Bug #4141928

    l_lot_code               NUMBER;
    l_serial_code            NUMBER;

    l_mmtt_qty               NUMBER;
  l_mmtt_sec_qty           NUMBER;       -- Bug #4141928

    l_out_temp_id            NUMBER         := 0;
    l_serial_exist_cnt       NUMBER         := 0;
    l_total_serial_cnt       NUMBER         := 0;
    l_so_cnt                 NUMBER         := 0;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_mtlt_lot_number        VARCHAR2(80);

    l_mtlt_primary_qty       NUMBER;
    l_wlc_quantity           NUMBER;
    l_wlc_uom_code           VARCHAR2(3);
  l_mtlt_secondary_qty     NUMBER;       -- Bug #4141928
    l_wlc_sec_quantity       NUMBER;                 -- Bug #4141928
    l_wlc_sec_uom_code       VARCHAR2(3);            -- Bug #4141928

    l_lot_match              NUMBER;
    l_ok_to_process          VARCHAR2(5);
    l_is_revision_control    VARCHAR2(1);
    l_is_lot_control         VARCHAR2(1);
    l_is_serial_control      VARCHAR2(1);
    b_is_revision_control    BOOLEAN;
    b_is_lot_control         BOOLEAN;
    b_is_serial_control      BOOLEAN;
    l_from_lpn               VARCHAR2(30);
    l_loc_id                 NUMBER;
    l_lpn_context            NUMBER;
    l_lpn_exists             NUMBER;

    l_qoh                    NUMBER;
    l_rqoh                   NUMBER;
    l_qr                     NUMBER;
    l_qs                     NUMBER;
    l_att                    NUMBER;
    l_atr                    NUMBER;
  l_sqoh                   NUMBER;                  -- Bug #4141928
    l_srqoh                  NUMBER;                  -- Bug #4141928
    l_sqr                    NUMBER;                  -- Bug #4141928
    l_sqs                    NUMBER;                  -- Bug #4141928
    l_satt                   NUMBER;                  -- Bug #4141928
    l_satr                   NUMBER;                  -- Bug #4141928

    l_allocated_lpn_id       NUMBER;
    l_table_index            NUMBER         := 0;
    l_table_total            NUMBER         := 0;
    l_table_count            NUMBER;
    l_lpn_include_lpn        NUMBER;
    l_xfr_sub_code           VARCHAR2(30);
    l_sub_active             NUMBER         := 0;
    l_loc_active             NUMBER         := 0;
    l_mmtt_proj_id NUMBER ;  --  2774506/2905646
    l_mmtt_task_id NUMBER ;
    l_locator_id NUMBER;
    l_organization_id NUMBER;
    l_mil_proj_id NUMBER ;
    l_mil_task_id NUMBER ;   -- 2774506/2905646
    l_transaction_header_id   NUMBER;
    l_transaction_uom         VARCHAR2(3);
    l_sec_transaction_uom     VARCHAR2(3);  -- Bug #4141928
    l_lpn_id          NUMBER;
    l_content_lpn_id  NUMBER;
    --l_transfer_lpn_id NUMBER;
    l_check_tolerance   Boolean;
    l_overpicked_qty   NUMBER ;
    l_lot_string     VARCHAR2(12000);--Bug 6148865
    l_lot_qty_string VARCHAR2(12000);--Bug 6148865
  l_lot_sec_qty_string VARCHAR2(12000);  -- Bug #4141928 --Bug 6148865
    l_sec_qty_str VARCHAR2(12000);  -- Bug #4141928  --Bug 6148865
    l_serial_string  VARCHAR2(2000);
    l_check_overpick_passed VARCHAR2(1);
    l_overpick_error_code  NUMBER;
    l_match_serials      Boolean  := false;
    l_pick_to_lpn_id      NUMBER;
    l_lot_v              VARCHAR2(12000) := null;  --Bug 6148865

    --Bug5649056
    l_mmtt_sub                VARCHAR2(60);
    l_mmtt_loc                NUMBER;
    l_lpn_sub                 VARCHAR2(60);
    l_lpn_loc                 NUMBER;
    --Bug5649056
    l_value VARCHAR2(3); --bug 6651517
    CURSOR ser_csr IS
      SELECT serial_number
        FROM mtl_serial_numbers
       WHERE lpn_id = p_fromlpn_id
         AND inventory_item_id = p_item_id
         AND NVL(lot_number, -999) = NVL(p_lot, -999);

    CURSOR lot_csr IS
      SELECT mtlt.primary_quantity
       , NVL(mtlt.secondary_quantity, 0)   -- Bug #4141928
           , mtlt.lot_number
        FROM mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id = p_temp_id
       --added material status check for lot under bug8398578
       AND inv_material_status_grp.is_status_applicable(
                                        p_wms_installed
                                ,       NULL
                                ,       p_transaction_type_id
                                ,       NULL
                                ,       NULL
                                ,       p_org_id
                                ,       p_item_id
                                ,       NULL
                                ,       null
                                ,       mtlt.lot_number
                                ,       NULL
                                ,       'O') = 'Y'
    ORDER BY LOT_NUMBER;

    --jxlu 10/12/04
    CURSOR lot_att IS
      SELECT lot_number, sum(transaction_quantity) transaction_quantity
        from wms_ALLOCATIONS_GTMP
    GROUP BY LOT_NUMBER
    ORDER BY LOT_NUMBER;

    --/* Bug 9448490 Lot Substitution Project */ start
     CURSOR lot_substitution_csr IS
       SELECT NVL(SUM(primary_transaction_quantity),0)
	      , lot_number
             FROM mtl_onhand_quantities_detail
             WHERE organization_id = p_org_id
	     AND Nvl(containerized_flag, 2) = 1
	     AND lpn_id = p_fromlpn_id
             AND subinventory_code = p_confirmed_sub
             AND locator_id = p_confirmed_loc_id
             AND inventory_item_id = p_item_id
             AND (revision = p_rev OR (revision IS NULL AND p_rev IS NULL))
             AND lot_number NOT IN (
			           SELECT mtlt.lot_number
				   FROM mtl_transaction_lots_temp mtlt
				   WHERE mtlt.transaction_temp_id = p_temp_id
				   )
	    AND lot_number IS NOT NULL
	    GROUP BY lot_number
	    ORDER BY lot_number;

    --/* Bug 9448490 Lot Substitution Project */ end

    l_debug                  NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  BEGIN
   mydebug('changeLotNoException is - ' || p_changelotNoException); --/* Bug 9448490 Lot Substitution Project */

    BEGIN
       -- this is done to release a lock on LPN that was picked first and later changed
       -- so that the lock on first one is released and next one will be locked later.
       ROLLBACK TO LPN_MATCH;
    EXCEPTION
       WHEN OTHERS THEN
          IF SQLCODE = -1086 THEN --  savepoint 'XYZ' never established
             -- Ignore
              mydebug ('Save point not available.. may be the first visit to this API ' );
          END IF ;
    END ;

    SAVEPOINT LPN_MATCH ; --
    g_debug := l_debug;
    IF (l_debug = 1) THEN
      mydebug('In lpn Match');
    END IF;

    x_return_status    := fnd_api.g_ret_sts_success;
    l_lpn_exists       := 0;
    --clear the PL/SQL table each time coming in

    t_lpn_lot_qty_table.DELETE;

    x_trx_qty_alloc := 0;
    x_lpnpickedasis := 'N';

     SELECT primary_uom_code
     , secondary_uom_code           -- Bug #4141928
          , lot_control_code
          , serial_number_control_code
       INTO l_primary_uom
     , l_secondary_uom        -- Bug #4141928
          , l_lot_code
          , l_serial_code
       FROM mtl_system_items
      WHERE organization_id = p_org_id
        AND inventory_item_id = p_item_id;

        --bug 6651517
       select value
       into l_value
       from v$nls_parameters
       where parameter = 'NLS_NUMERIC_CHARACTERS';

    -- p_trx_qty was passed in transaction_uom, need to convert it to primary_uom
    IF (l_debug = 1) THEN
          mydebug('p_trx_uom :'|| p_trx_uom);
          mydebug('l_primary_uom :'|| l_primary_uom);
          mydebug('p_trx_qty in transaction uom:'|| p_trx_qty);
          mydebug('p_sec_uom :'|| p_sec_uom);                      -- Bug #4141928
          mydebug('l_secondary_uom :'|| l_secondary_uom);          -- Bug #4141928
    END IF;

    IF (p_trx_uom <> l_primary_uom) THEN
         l_pr_qty := inv_convert.inv_um_convert(
                 item_id        => p_item_id
                ,precision      => null
                ,from_quantity  => p_trx_qty
                ,from_unit      => p_trx_uom
                ,to_unit        => l_primary_uom
                ,from_name      => null
                ,to_name        => null);
         l_lpn_pr_qty := l_pr_qty;
         IF (l_debug = 1) THEN
            mydebug('transaction uom is different from primary uom');
            mydebug('p_trx_qty in primary uom is l_pri_qty:'|| l_pr_qty);
            mydebug('l_lpn_pri_qty in primary uom :'|| l_lpn_pr_qty);
         END IF;
    ELSE
       l_lpn_pr_qty           := p_trx_qty;
       l_lpn_trx_qty          := p_trx_qty;
       l_pr_qty               := p_trx_qty;
       IF (l_debug = 1) THEN
            mydebug('transaction uom is the same as primary uom');
            mydebug('l_lpn_pr_qty is the same as p_trx_qty :'|| l_lpn_pr_qty);
            mydebug('l_lpn_trx_qty is the same as p_trx_qty :'|| l_lpn_trx_qty);
       END IF;
    END IF;

  l_lpn_sec_qty          := p_sec_qty;  -- Bug #4141928
  l_sec_qty              := p_sec_qty;     -- Bug #4141928

    BEGIN
     -- Bug5649056: Added sub and loc in following query.
     SELECT 1
           , lpn_context
           , parent_lpn_id
           , subinventory_code
           , locator_id
        INTO l_lpn_exists
           , l_lpn_context
           , x_parent_lpn_id
           , l_lpn_sub
           , l_lpn_loc
        FROM wms_license_plate_numbers wlpn
       WHERE wlpn.organization_id = p_org_id
         AND wlpn.lpn_id = p_fromlpn_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('lpn does not exist in org');
        END IF;

        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    IF l_lpn_exists = 0
       OR p_fromlpn_id = 0
       OR l_lpn_context <> wms_container_pub.lpn_context_inv THEN
      IF (l_debug = 1) THEN
        mydebug('lpn does not exist in org');
      END IF;

      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('Checking if lpn has been picked already');
    END IF;

    x_match            := 0;

    BEGIN
      -- Bug#2742860 The from LPN should not be loaded,
      -- this check should not be restricted to that particular transaction header id


      SELECT 1
        INTO l_loaded
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM mtl_material_transactions_temp
                     WHERE (transfer_lpn_id = p_fromlpn_id
                            OR content_lpn_id = p_fromlpn_id));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_loaded  := 0;
    END;

    IF l_loaded > 0 THEN
      x_match  := 7;
      fnd_message.set_name('WMS', 'WMS_LOADED_ERROR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Check if locator is valid
    IF (l_debug = 1) THEN
      mydebug('Fetch sub/loc for LPN ');
    END IF;

    BEGIN
      -- WMS PJM Integration, Selecting the resolved concatenated segments instead of concatenated segments
      SELECT w.subinventory_code
           , inv_project.get_locsegs(w.locator_id, w.organization_id)
           , w.license_plate_number
           , w.locator_id
           , w.lpn_context
        INTO l_sub
           , l_loc
           , l_from_lpn
           , l_loc_id
           , l_lpn_context
        FROM wms_license_plate_numbers w
       WHERE w.lpn_id = p_fromlpn_id
         AND w.locator_id IS NOT NULL;

      IF l_sub IS NULL THEN
        -- The calling java code treats this condition as an error

        x_match  := 10;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- bug 2398247
      -- verify if sub is active
      SELECT COUNT(*)
        INTO l_sub_active
        FROM mtl_secondary_inventories
       WHERE NVL(disable_date, SYSDATE + 1) > SYSDATE
         AND organization_id = p_org_id
         AND secondary_inventory_name = l_sub;

      IF l_sub_active = 0 THEN
        x_match  := 10;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- verify if locator is active
      SELECT COUNT(*)
        INTO l_loc_active
        FROM mtl_item_locations_kfv
       WHERE NVL(disable_date, SYSDATE + 1) > SYSDATE
         AND organization_id = p_org_id
         AND subinventory_code = l_sub
         AND inventory_location_id = l_loc_id;

      IF l_loc_active = 0 THEN
        x_match  := 10;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOC');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
       -- Begin fix for 2774506


       SELECT locator_id,organization_id,
              transaction_header_id,
              transaction_uom,
        SECONDARY_UOM_CODE         -- Bug #4141928
         INTO l_locator_id, l_organization_id,
              l_transaction_header_id,
              l_transaction_uom,
        l_sec_transaction_uom      -- Bug #4141928
        from mtl_material_transactions_temp
        where transaction_temp_id = p_temp_id;

         select nvl(project_id ,-999) , nvl(task_id ,-999)
        into  l_mmtt_proj_id , l_mmtt_task_id
        from  mtl_item_locations
        where inventory_location_id = l_locator_id
        and organization_id = l_organization_id ;

      select nvl(project_id, -999) , nvl(task_id ,-999)
        into l_mil_proj_id , l_mil_task_id
        from mtl_item_locations
        where inventory_location_id = l_loc_id
        and organization_id = p_org_id ;

      mydebug('mmtt project id =  '||l_mmtt_proj_id);
      mydebug('mmtt task id =  '||l_mmtt_task_id);
      mydebug('mil project id =  '||l_mil_proj_id);
      mydebug('mil task id =  '||l_mil_task_id);

         if ((l_mil_proj_id <> l_mmtt_proj_id ) or ( l_mil_task_id <> l_mmtt_task_id )) then
         mydebug('lpn : the project/tak information does not match');
         FND_MESSAGE.SET_NAME('WMS','WMS_CONT_INVALID_LPN');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
      end if ;

     -- End fix for 2774506


      x_sub     := l_sub;
      x_loc     := l_loc;
      x_loc_id  := l_loc_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_match  := 6;
        fnd_message.set_name('WMS', 'WMS_TD_LPN_LOC_NOT_FOUND');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    IF (l_debug = 1) THEN
      mydebug('sub is ' || l_sub);
      mydebug('loc is ' || l_loc);
    END IF;

    -- Check if LPN has already been allocated for any Sales order
    -- If LPN has been picked for a sales order then it cannot be picked

    IF (l_debug = 1) THEN
      mydebug('Checking SO for lpn');
    END IF;

    BEGIN
      SELECT 1
        INTO l_so_cnt
        FROM wms_license_plate_numbers
       WHERE lpn_context = 11
         AND lpn_id = p_fromlpn_id
         AND organization_id = p_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_so_cnt  := 0;
    END;

    IF l_so_cnt > 0 THEN
      x_match  := 12;
      fnd_message.set_name('WMS', 'WMS_LPN_STAGED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

   -- SELECT primary_uom_code
   --      , lot_control_code
   ----      , serial_number_control_code
   --   INTO l_primary_uom
   --      , l_lot_code
   --      , l_serial_code
   --   FROM mtl_system_items
   --  WHERE organization_id = p_org_id
   --    AND inventory_item_id = p_item_id;

   --Bug5649056: added sub and locator below
   SELECT mmtt.transfer_subinventory
         , mmtt.subinventory_code
         , mmtt.locator_id
      INTO l_xfr_sub_code
         , l_mmtt_sub
         , l_mmtt_loc
      FROM mtl_material_transactions_temp mmtt
     WHERE mmtt.transaction_temp_id = p_temp_id;

    -- Check to see if the item is in the LPN
    IF (l_debug = 1) THEN
      mydebug('Checking to see if required  item,cg,rev,lot exist in lpn..');
    END IF;

    l_item_cnt         := 0;

    IF (l_debug = 1) THEN
      mydebug('item' || p_item_id || 'LPN' || p_fromlpn_id || 'Org' || p_org_id || ' lot' || p_lot || ' Rev' || p_rev);
    END IF;

    BEGIN
      SELECT 1
        INTO l_item_cnt
        FROM DUAL
       WHERE EXISTS(
               SELECT 1
                 FROM wms_lpn_contents wlc
                WHERE wlc.parent_lpn_id = p_fromlpn_id
                  AND wlc.organization_id = p_org_id
                  AND wlc.inventory_item_id = p_item_id
                  AND NVL(wlc.revision, '-999') = NVL(p_rev, '-999'));
    EXCEPTION
      -- Item/lot/rev combo does not exist in LPN

      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('item lot rev combo does not exist');
        END IF;

        x_match  := 13;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    IF l_item_cnt > 0
       AND l_lot_code > 1 THEN
      --Do this only for lot controlled items

      BEGIN
        SELECT 1
          INTO l_item_cnt
          FROM DUAL
         WHERE EXISTS(
                 SELECT 1
                   FROM wms_lpn_contents wlc, mtl_transaction_lots_temp mtlt
                  WHERE wlc.parent_lpn_id = p_fromlpn_id
                    AND wlc.organization_id = p_org_id
                    AND wlc.inventory_item_id = p_item_id
                    AND NVL(wlc.revision, '-999') = NVL(p_rev, '-999')
		    AND --7281311
		    (
		    (mtlt.transaction_temp_id = p_temp_id AND mtlt.lot_number = wlc.lot_number AND p_changelotNoException = 'N')
		     OR
		     p_changelotNoException <> 'N'
		     )
		     );

      EXCEPTION
        -- Item/lot/rev combo does not exist in LPN

        WHEN NO_DATA_FOUND THEN
          IF (l_debug = 1) THEN
            mydebug('lot rev combo for the item does not exist');
          END IF;

          x_match  := 5;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOT_LPN');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    -- Item with the correct lot/revision exists in LPN
    IF p_is_sn_alloc = 'Y'
       AND p_action = 4 THEN
      b_is_serial_control  := TRUE;
    ELSE
      b_is_serial_control  := FALSE;
    END IF;

    IF p_action = 4 THEN
       l_is_serial_control := 'Y';
    ELSE
       l_is_serial_control := 'N';
    END IF;

    IF l_lot_code > 1 THEN
      b_is_lot_control  := TRUE;
      l_is_lot_control  := 'Y';
    ELSE
      b_is_lot_control  := FALSE;
      l_is_lot_control  := 'N';
    END IF;

    IF p_rev IS NULL THEN
      b_is_revision_control  := FALSE;
      l_is_revision_control  := 'N';
    ELSE
      b_is_revision_control  := TRUE;
      l_is_revision_control  := 'Y';
    END IF;

    IF (l_debug = 1) THEN
      mydebug('is_serial_control:' || l_is_serial_control);
      mydebug('is_lot_control:' || l_is_lot_control);
      mydebug('is_revision_control:' || l_is_revision_control);
    END IF;

    BEGIN
      SELECT allocated_lpn_id
        INTO l_allocated_lpn_id
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_temp_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('transaction does not exist in mmtt');
        END IF;

        fnd_message.set_name('INV', 'INV_INVALID_TRANSACTION');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    -- clear quantity cache before we create qty tree.
    inv_quantity_tree_pub.clear_quantity_cache;

    -- Check if LPN has items other than the one requested

    IF (l_debug = 1) THEN
      mydebug('lpn has the requested item ');
    END IF;

    l_item_cnt2        := 0;
    l_lot_cnt          := 0;
    l_rev_cnt          := 0;
    l_cg_cnt           := 0;
    l_item_cnt2        := 0;
    l_lot_cnt          := 0;
    l_rev_cnt          := 0;
    l_cg_cnt           := 0;
    l_lpn_include_lpn  := 0;

    SELECT COUNT(DISTINCT inventory_item_id)
         , COUNT(DISTINCT lot_number)
         , COUNT(DISTINCT revision)
         , COUNT(DISTINCT cost_group_id)
      INTO l_item_cnt2
         , l_lot_cnt
         , l_rev_cnt
         , l_cg_cnt
      FROM wms_lpn_contents
     WHERE parent_lpn_id = p_fromlpn_id
       AND organization_id = p_org_id;

    SELECT COUNT(*)
      INTO l_lpn_include_lpn
      FROM wms_license_plate_numbers
     WHERE outermost_lpn_id = p_fromlpn_id
       AND organization_id = p_org_id;

    IF l_item_cnt2 > 1
       OR l_rev_cnt > 1
       OR l_lpn_include_lpn > 1 THEN
      -- LPN has multiple items
      -- Such LPN's can be picked but in such cases the user has to
      -- manually confirm the LPN.
      -- No validation for LPN contents in such a case.

      IF (l_debug = 1) THEN
        mydebug('lpn has items other than requested item ');
      END IF;

      x_match  := 2;

      IF l_lot_code > 1 THEN

        -- adding serial allocation checking for lot+serial item
         IF p_is_sn_alloc = 'Y'
             AND p_action = 4 THEN
            IF (l_debug = 1) THEN
              mydebug('SN control and SN allocation on');
            END IF;

            SELECT COUNT(fm_serial_number)
              INTO l_serial_exist_cnt
              FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
             WHERE mtlt.transaction_temp_id = p_temp_id
               AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
               AND msnt.fm_serial_number IN(
                                          SELECT serial_number
                                            FROM mtl_serial_numbers
                                           WHERE lpn_id = p_fromlpn_id
                                             AND inventory_item_id = p_item_id
                                             AND NVL(revision, '-999') = NVL(p_rev, '-999'));

            IF (l_debug = 1) THEN
              mydebug('SN exist count' || l_serial_exist_cnt);
            END IF;

            IF (l_serial_exist_cnt = 0) THEN
              IF (l_debug = 1) THEN
                mydebug('No serial allocations have occured or LPN does not have the allocated serials ');
              END IF;

              -- Serial numbers missing for the transaction
              x_match  := 9;
              fnd_message.set_name('INV', 'INV_INT_SERMISEXP');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

        l_lpn_pr_qty  := 0;
    l_lpn_sec_qty  := 0;    -- Bug #4141928
        mydebug('Opening  lot_csr cursor in lpn_match procedure ');
        OPEN lot_csr;

        LOOP
          FETCH lot_csr INTO l_mtlt_primary_qty, l_mtlt_secondary_qty, l_mtlt_lot_number; -- Bug #4141928
          EXIT WHEN lot_csr%NOTFOUND;

          IF (l_debug = 1) THEN
            mydebug('l_mtlt_lot_number : ' || l_mtlt_lot_number);
            mydebug('l_mtlt_primary_qty: ' || l_mtlt_primary_qty);
    mydebug('l_mtlt_secondary_qty: ' || l_mtlt_secondary_qty);  -- Bug #4141928
          END IF;


          IF NVL(l_allocated_lpn_id, 0) = p_fromlpn_id THEN
            --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
            -- in order to get correct att.
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => -l_mtlt_primary_qty
            , p_secondary_quantity         => -l_mtlt_secondary_qty -- Bug #4141928
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , x_sqoh                       => l_sqoh        -- Bug #4141928
            , x_srqoh                      => l_srqoh                -- Bug #4141928
            , x_sqr                        => l_sqr                  -- Bug #4141928
            , x_sqs                        => l_sqs                  -- Bug #4141928
            , x_satt                       => l_satt                 -- Bug #4141928
            , x_satr                       => l_satr                 -- Bug #4141928
            , p_lpn_id                     => p_fromlpn_id
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('after update qty tree for lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
      mydebug('after update qty tree for lpn l_satt:' || l_satt || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('calling update qty tree with lpn 1st time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          --Bug#5649056: only update if subinventory and locator match
          ELSIF ( l_lpn_sub = l_mmtt_sub AND l_lpn_loc = l_mmtt_loc ) THEN
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => -l_mtlt_primary_qty
            , p_secondary_quantity         => -l_mtlt_secondary_qty -- Bug #4141928
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , x_sqoh                       => l_sqoh        -- Bug #4141928
            , x_srqoh                      => l_srqoh                -- Bug #4141928
            , x_sqr                        => l_sqr                  -- Bug #4141928
            , x_sqs                        => l_sqs                  -- Bug #4141928
            , x_satt                       => l_satt                 -- Bug #4141928
            , x_satr                       => l_satr                 -- Bug #4141928
            --  , p_lpn_id                =>   p_fromlpn_id      withour lpn_id, only to locator level
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('after update qty tree without lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
      mydebug('after update qty tree without lpn l_satt:' || l_satt || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('calling update qty tree back without lpn 1st time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          inv_quantity_tree_pub.query_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => TRUE
          , p_is_serial_control          => b_is_serial_control
          , p_demand_source_type_id      => -9999
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => l_mtlt_lot_number
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh         -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
          , p_lpn_id                     => p_fromlpn_id
          , p_transfer_subinventory_code => l_xfr_sub_code
          , p_grade_code                 => NULL                   -- Bug #4141928
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_att > 0) THEN
              l_table_index  := l_table_index + 1;

              IF (l_debug = 1) THEN
                  mydebug('l_table_index:' || l_table_index || ' lot_number:' || l_mtlt_lot_number || ' qty: ' || l_att);
              END IF;
              -- bug 3547725, now no matter what relation it is between l_mtlt_primary_qty and l_att
              -- we always use l_att

              l_lpn_pr_qty                                   := l_lpn_pr_qty + l_att;
      l_lpn_sec_qty                                  := l_lpn_sec_qty + l_satt;
              t_lpn_lot_qty_table(l_table_index).lpn_id      := p_fromlpn_id;
              t_lpn_lot_qty_table(l_table_index).lot_number  := l_mtlt_lot_number;
              t_lpn_lot_qty_table(l_table_index).pri_qty := l_att;
      t_lpn_lot_qty_table(l_table_index).sec_qty := l_satt; -- Bug #4141928
              IF (l_primary_uom = p_trx_uom) THEN
                     t_lpn_lot_qty_table(l_table_index).trx_qty := l_att;
              ELSE
                     t_lpn_lot_qty_table(l_table_index).trx_qty := inv_convert.inv_um_convert(
                                               item_id        => p_item_id
                                              ,precision      => null
                                              ,from_quantity  => l_att
                                              ,from_unit      => l_primary_uom
                                              ,to_unit        => p_trx_uom
                                              ,from_name      => null
                                              ,to_name        => null);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('LPN does not have lot ' || l_mtlt_lot_number);
              END IF;
            --mydebug('l_table_index:'||l_table_index||' lot_number:'||l_mtlt_lot_number||' qty: 0 ');
            --t_lpn_lot_qty_table(l_table_index).lpn_id := p_fromlpn_id;
            --t_lpn_lot_qty_table(l_table_index).lot_number := l_mtlt_lot_number;
            --t_lpn_lot_qty_table(l_table_index).pri_qty := l_mtlt_primary_qty;
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('calling qty tree 1st time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          IF NVL(l_allocated_lpn_id, 0) = p_fromlpn_id THEN
            --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
            -- in order to get correct att.
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => l_mtlt_primary_qty
            , p_secondary_quantity         => l_mtlt_secondary_qty -- Bug #4141928
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , x_sqoh                       => l_sqoh        -- Bug #4141928
            , x_srqoh                      => l_srqoh                -- Bug #4141928
            , x_sqr                        => l_sqr                  -- Bug #4141928
            , x_sqs                        => l_sqs                  -- Bug #4141928
            , x_satt                       => l_satt                 -- Bug #4141928
            , x_satr                       => l_satr                 -- Bug #4141928
            , p_lpn_id                     => p_fromlpn_id
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('after update qty tree back for lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
      mydebug('after update qty tree back for lpn l_satt:' || l_satt || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('calling update qty tree back with lpn 1st time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          --Bug#5649056: only update if subinventory and locator match
          ELSIF ( l_lpn_sub = l_mmtt_sub AND l_lpn_loc = l_mmtt_loc ) THEN
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => l_mtlt_primary_qty
            , p_secondary_quantity         => l_mtlt_secondary_qty -- Bug #4141928
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , x_sqoh                       => l_sqoh        -- Bug #4141928
            , x_srqoh                      => l_srqoh                -- Bug #4141928
            , x_sqr                        => l_sqr                  -- Bug #4141928
            , x_sqs                        => l_sqs                  -- Bug #4141928
            , x_satt                       => l_satt                 -- Bug #4141928
            , x_satr                       => l_satr                 -- Bug #4141928
            --  , p_lpn_id                =>   p_fromlpn_id      withour lpn_id, only to locator level
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('after update qty tree back without lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
      mydebug('after update qty tree back without lpn l_satt:' || l_satt || ' for lot:' || l_mtlt_lot_number);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('calling update qty tree back without lpn 1st time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END LOOP;

        CLOSE lot_csr;
        -- Bug #4141928. No changes required for OPM convergence.
    -- Let primary qty drive the lpn_match
        IF  (l_lpn_pr_qty >= l_pr_qty  ) THEN
             x_match := 5;
        ELSE
             x_match := 2;
        END IF;
  -- Bug #4141928. No changes required for OPM convergence.
  -- OPM does not have a serial case
  -- bug 4277869
     /* ELSIF p_is_sn_alloc = 'Y'
            AND p_action = 4 THEN
        IF (l_debug = 1) THEN
          mydebug('SN control and SN allocation on');
        END IF;

        SELECT COUNT(fm_serial_number)
          INTO l_serial_exist_cnt
          FROM mtl_serial_numbers_temp msnt
         WHERE msnt.transaction_temp_id = p_temp_id
           AND msnt.fm_serial_number IN(
                                        SELECT serial_number
                                          FROM mtl_serial_numbers
                                         WHERE lpn_id = p_fromlpn_id
                                           AND inventory_item_id = p_item_id
                                           AND NVL(revision, '-999') = NVL(p_rev, '-999'));

        IF (l_debug = 1) THEN
          mydebug('SN exist count' || l_serial_exist_cnt);
        END IF;

        IF (l_serial_exist_cnt = 0) THEN
          IF (l_debug = 1) THEN
            mydebug('LPN does not have the allocated serials ');
          END IF;

          -- Serial numbers missing for the transaction
          x_match  := 9;
          fnd_message.set_name('INV', 'INV_INT_SERMISEXP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        SELECT COUNT(fm_serial_number)
          INTO l_total_serial_cnt
          FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
         WHERE mtlt.transaction_temp_id = p_temp_id
           AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

        IF (l_debug = 1) THEN
          mydebug('SN tot count' || l_total_serial_cnt);
        END IF;

        IF (l_total_serial_cnt = l_serial_exist_cnt) THEN
          IF (l_debug = 1) THEN
            mydebug('LPN matches exactly');
          END IF;

          --x_match  := 1;  It can not be exactly match, since lpn contains other items
          x_match := 5;
        ELSIF(l_total_serial_cnt > l_serial_exist_cnt) THEN
          IF (l_debug = 1) THEN
            mydebug('LPN has less');
          END IF;

          --x_match    := 3;  It can not be fully consumable lpn, since lpn contains other items.
          x_match := 2;
          l_lpn_pr_qty  := l_serial_exist_cnt;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('LPN has extra serials');
          END IF;

          x_match  := 4;
        END IF;
       -- end of bug 4277869
        */
      ELSE -- Plain item OR REVISION controlled item
           -- or serial controlled
        -- bug 4277869
        IF p_is_sn_alloc = 'Y'
                 AND p_action = 4 THEN
             IF (l_debug = 1) THEN
               mydebug('SN control and SN allocation on');
             END IF;

             SELECT COUNT(fm_serial_number)
               INTO l_serial_exist_cnt
               FROM mtl_serial_numbers_temp msnt
              WHERE msnt.transaction_temp_id = p_temp_id
                AND msnt.fm_serial_number IN(
                                   SELECT serial_number
                                     FROM mtl_serial_numbers
                                    WHERE lpn_id = p_fromlpn_id
                                      AND inventory_item_id = p_item_id
                                      AND NVL(revision, '-999') = NVL(p_rev, '-999'));

             IF (l_debug = 1) THEN
               mydebug('SN exist count' || l_serial_exist_cnt);
             END IF;

             IF (l_serial_exist_cnt = 0) THEN
               IF (l_debug = 1) THEN
                 mydebug('LPN does not have the allocated serials ');
               END IF;

               -- Serial numbers missing for the transaction
               x_match  := 9;
               fnd_message.set_name('INV', 'INV_INT_SERMISEXP');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
             END IF;
        END IF;
        -- end of bug 4277869

        IF (l_debug = 1) THEN
          mydebug('Getting total qty in user entered uom..');
        END IF;

        IF NVL(l_allocated_lpn_id, 0) = p_fromlpn_id THEN
          --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
          -- in order to get correct att.
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => -l_pr_qty
          , p_secondary_quantity         => -l_sec_qty -- Bug #4141928
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh         -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
          , p_lpn_id                     => p_fromlpn_id
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('update qty tree with lpn 2nd time: l_att:' || l_att);
      mydebug('update qty tree with lpn 2nd time: l_satt:' || l_satt); -- Bug #4141928
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('calling update qty tree with lpn 2nd time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        --Bug#5649056: only update if subinventory and locator match
        ELSIF ( l_lpn_sub = l_mmtt_sub AND l_lpn_loc = l_mmtt_loc ) THEN
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => -l_pr_qty
    , p_secondary_quantity         => -l_sec_qty -- Bug #4141928
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh         -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
          --  , p_lpn_id                =>   p_fromlpn_id      withour lpn_id, only to locator level
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('update qty tree without lpn 2nd time:l_att:' || l_att);
      mydebug('update qty tree with lpn 2nd time: l_satt:' || l_satt); -- Bug #4141928
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('calling update qty tree back without lpn 2nd time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        inv_quantity_tree_pub.query_quantities(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_cnt
        , x_msg_data                   => l_msg_data
        , p_organization_id            => p_org_id
        , p_inventory_item_id          => p_item_id
        , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
        , p_is_revision_control        => b_is_revision_control
        , p_is_lot_control             => FALSE
        , p_is_serial_control          => b_is_serial_control
        , p_demand_source_type_id      => -9999
        , p_revision                   => NVL(p_rev, NULL)
        , p_lot_number                 => NULL
        , p_subinventory_code          => l_sub
        , p_locator_id                 => l_loc_id
        , x_qoh                        => l_qoh
        , x_rqoh                       => l_rqoh
        , x_qr                         => l_qr
        , x_qs                         => l_qs
        , x_att                        => l_att
        , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh       -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
        , p_lpn_id                     => p_fromlpn_id
        , p_transfer_subinventory_code => l_xfr_sub_code
        , p_grade_code                 => NULL                   -- Bug #4141928
        );

        IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              l_lpn_pr_qty  := l_att;
      l_lpn_sec_qty  := l_satt;     -- Bug #4141928
      -- Bug #4141928. No changes required for OPM convergence.
      -- let primary qty drive the lpn match
              IF (l_debug = 1) THEN
                      mydebug('l_att:        ' || l_att);
                      mydebug('l_lpn_pr_qty: ' || l_lpn_pr_qty);
                      mydebug('l_pr_qty:     ' || l_pr_qty);
              END IF;
              IF (l_lpn_pr_qty >= l_pr_qty) THEN
                  x_match := 5;
              ELSE
                  x_match := 2;
              END IF;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('calling qty tree 2nd time failed ');
          END IF;

          fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
          fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF NVL(l_allocated_lpn_id, 0) = p_fromlpn_id THEN
          --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
          -- in order to get correct att.
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => l_pr_qty
    , p_secondary_quantity         => l_sec_qty   -- Bug #4141928
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh         -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
          , p_lpn_id                     => p_fromlpn_id
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('update qty tree back with lpn 2nd time: l_att:' || l_att);
      mydebug('update qty tree back with lpn 2nd time: l_satt:' || l_satt);  -- Bug #4141928
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('calling update qty tree with lpn 2nd time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        --Bug#5649056: only update if subinventory and locator match
        ELSIF ( l_lpn_sub = l_mmtt_sub AND l_lpn_loc = l_mmtt_loc ) THEN
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => l_pr_qty
    , p_secondary_quantity         => l_sec_qty   -- Bug #4141928
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh         -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
          --  , p_lpn_id                =>   p_fromlpn_id      withour lpn_id, only to locator level
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('update qty tree back without lpn 2nd time:l_att:' || l_att);
      mydebug('update qty tree back without lpn 2nd time:l_satt:' || l_satt);  -- Bug #4141928
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('calling update qty tree back without lpn 2nd time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;
    ELSE
      -- LPN has just the item requested
      -- See if quantity/details it has will match the quantity allocated
      -- Find out if the item is lot/serial controlled and UOM of item
      -- and compare with transaction details

      IF (l_debug = 1) THEN
        mydebug('lpn has only the requested item ');
      END IF;

      SELECT primary_quantity, NVL(secondary_transaction_quantity, 0) -- Bug #4141928
        INTO l_mmtt_qty, l_mmtt_sec_qty           -- Bug #4141928
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_temp_id;

      -- If item is lot controlled then validate the lots

      IF l_lot_code > 1 THEN
        IF (l_debug = 1) THEN
          mydebug('item is lot controlled');
        END IF;

        -- initialize
        l_check_tolerance := true;
        -- If item is also serial controlled and serial allocation is
        -- on then count the number of serials allocated which exist
        -- in the LPN.
        -- If the count is 0 then raise an error

        IF p_is_sn_alloc = 'Y'
           AND p_action = 4 THEN
          IF (l_debug = 1) THEN
            mydebug('SN control and SN allocation on');
          END IF;

          SELECT COUNT(fm_serial_number)
            INTO l_serial_exist_cnt
            FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
           WHERE mtlt.transaction_temp_id = p_temp_id
             AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
             AND msnt.fm_serial_number IN(
                                        SELECT serial_number
                                          FROM mtl_serial_numbers
                                         WHERE lpn_id = p_fromlpn_id
                                           AND inventory_item_id = p_item_id
                                           AND NVL(revision, '-999') = NVL(p_rev, '-999'));

          IF (l_debug = 1) THEN
            mydebug('SN exist count' || l_serial_exist_cnt);
          END IF;

          IF (l_serial_exist_cnt = 0) THEN
            IF (l_debug = 1) THEN
              mydebug('No serial allocations have occured or LPN does not have the allocated serials ');
            END IF;

            -- Serial numbers missing for the transaction
            x_match  := 9;
            fnd_message.set_name('INV', 'INV_INT_SERMISEXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        -- Check whether the Lots allocated are all in the LPN
        -- An LPN can have many lots and items/revisions, check if the
        -- lots allocated for the item exist in the LPN and if any of
        -- them has quantity less/more than what was suggested.

        IF (l_debug = 1) THEN
          mydebug('Check whether the LPN has any lot whose quantity exceeds allocated quantity');
        END IF;

        l_lpn_pr_qty  := 0;
    l_lpn_sec_qty  := 0;  -- Bug #4141928
        OPEN lot_csr;

        LOOP
          FETCH lot_csr INTO l_mtlt_primary_qty, l_mtlt_secondary_qty, l_mtlt_lot_number; -- Bug #4141928
          EXIT WHEN lot_csr%NOTFOUND;
          l_lot_match  := 0;

          IF (l_debug = 1) THEN
            mydebug('l_mtlt_lot_number : ' || l_mtlt_lot_number);
            mydebug('l_mtlt_primary_qty: ' || l_mtlt_primary_qty);
    mydebug('l_mtlt_secondary_qty: ' || l_mtlt_secondary_qty); -- Bug #4141928
          END IF;

          l_lot_cnt    := l_lot_cnt - 1;

          IF NVL(l_allocated_lpn_id, 0) = p_fromlpn_id THEN
            --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
            -- in order to get correct att.
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => -l_mtlt_primary_qty
    , p_secondary_quantity         => -l_mtlt_secondary_qty -- Bug #4141928
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , x_sqoh                       => l_sqoh        -- Bug #4141928
            , x_srqoh                      => l_srqoh                -- Bug #4141928
            , x_sqr                        => l_sqr                  -- Bug #4141928
            , x_sqs                        => l_sqs                  -- Bug #4141928
            , x_satt                       => l_satt                 -- Bug #4141928
            , x_satr                       => l_satr                 -- Bug #4141928
            , p_lpn_id                     => p_fromlpn_id
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('update qty tree 3rd time for lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
      mydebug('update qty tree 3rd time for lpn l_satt:' || l_satt || ' for lot:' || l_mtlt_lot_number);  -- Bug #4141928
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('calling update qty tree with lpn 3rd time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          --Bug#5649056: only update if subinventory and locator match
          ELSIF ( l_lpn_sub = l_mmtt_sub AND l_lpn_loc = l_mmtt_loc ) THEN
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => -l_mtlt_primary_qty
    , p_secondary_quantity         => -l_mtlt_secondary_qty -- Bug #4141928
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , x_sqoh                       => l_sqoh        -- Bug #4141928
            , x_srqoh                      => l_srqoh                -- Bug #4141928
            , x_sqr                        => l_sqr                  -- Bug #4141928
            , x_sqs                        => l_sqs                  -- Bug #4141928
            , x_satt                       => l_satt                 -- Bug #4141928
            , x_satr                       => l_satr                 -- Bug #4141928
            --  , p_lpn_id                =>   p_fromlpn_id      withour lpn_id, only to locator level
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('after update without lpn 3rd time l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
      mydebug('after update without lpn 3rd time l_satt:' || l_satt || ' for lot:' || l_mtlt_lot_number);  -- Bug #4141928
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('calling update qty tree back 3rd time without lpn 3rd time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          inv_quantity_tree_pub.query_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => TRUE
          , p_is_serial_control          => b_is_serial_control
          , p_demand_source_type_id      => -9999
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => l_mtlt_lot_number
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh         -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
          , p_lpn_id                     => p_fromlpn_id
          , p_transfer_subinventory_code => l_xfr_sub_code
          , p_grade_code                 => NULL                   -- Bug #4141928
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            l_lot_match  := 1;

            IF (l_att > 0) THEN
              l_table_index  := l_table_index + 1;
              -- bug 3547725, now no matter what relation it is between l_mtlt_primary_qty and l_att
              -- we always use l_att

              l_lpn_pr_qty := l_lpn_pr_qty + l_att;
              l_lpn_sec_qty := l_lpn_sec_qty + l_satt;  -- Bug #4141928
              IF l_att < l_qoh THEN
                  l_check_tolerance := false;
                  IF (l_debug = 1) THEN
                    mydebug('l_att < l_qoh: set l_check_tolerance to false');
                  END IF;
              END IF;

              IF (l_debug = 1) THEN
                  mydebug('l_table_index:' || l_table_index || ' lot_number:' || l_mtlt_lot_number || ' qty:' || l_att);
              END IF;

              t_lpn_lot_qty_table(l_table_index).lpn_id      := p_fromlpn_id;
              t_lpn_lot_qty_table(l_table_index).lot_number  := l_mtlt_lot_number;
              t_lpn_lot_qty_table(l_table_index).pri_qty := l_att;
      t_lpn_lot_qty_table(l_table_index).sec_qty := l_satt;  -- Bug #4141928
              IF (l_primary_uom = p_trx_uom) THEN
                   t_lpn_lot_qty_table(l_table_index).trx_qty := l_att;
              ELSE
                   t_lpn_lot_qty_table(l_table_index).trx_qty := inv_convert.inv_um_convert(
                                                 item_id        => p_item_id
                                                ,precision      => null
                                                ,from_quantity  => l_att
                                                ,from_unit      => l_primary_uom
                                                ,to_unit        => p_trx_uom
                                                ,from_name      => null
                                                ,to_name        => null);
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('LPN does not have lot ' || l_mtlt_lot_number);
              END IF;

              IF x_match <> 4 THEN
                x_match  := 3;
              END IF;

              l_lot_match  := 0;
              l_lot_cnt    := l_lot_cnt + 1;
              l_check_tolerance := false;
              IF (l_debug = 1) THEN
                  mydebug('LPN does not have lot ' || l_mtlt_lot_number);
                  mydebug('set l_check_tolerance to false');
              END IF;
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('calling qty tree 3rd time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          IF (l_lot_match <> 0)
             AND (x_match <> 4) THEN
            IF l_mtlt_primary_qty < l_att THEN
              IF (l_debug = 1) THEN
                mydebug('Qty in LPN for lot ' || l_mtlt_lot_number || ' is more than transaction qty for that lot');
              END IF;

              x_match  := 4;
            ELSIF l_mtlt_primary_qty > l_att THEN
              IF l_qoh = l_att THEN
                IF (l_debug = 1) THEN
                  mydebug('Qty in LPN for lot ' || l_mtlt_lot_number || ' is less than transaction qty for that lot');
                END IF;

                x_match  := 3;
                if (l_lot_string is null) then
                     l_lot_string := l_mtlt_lot_number;
                else
                     l_lot_string := l_lot_string ||':'||l_mtlt_lot_number;
                end if;

                if (l_lot_qty_string is null ) then
                     l_lot_qty_string := l_att;
                else
                     l_lot_qty_string := l_lot_qty_string || ':'||l_att;
                end if;

                -- Bug #4141928. Build the sec lot qty string
                if (l_lot_sec_qty_string is null ) then
                     l_lot_sec_qty_string := l_satt;
                else
                     l_lot_sec_qty_string := l_lot_sec_qty_string || ':'||l_satt;
                end if;
                -- Bug #4141928
                l_sec_qty_str := l_lot_sec_qty_string;
                IF (l_debug = 1) THEN
                       mydebug('l_lot_string:'||l_lot_string);
                       mydebug('l_lot_qty_string:'||l_lot_qty_string);
         mydebug('l_lot_sec_qty_string:'||l_lot_qty_string);
                END IF;

              ELSE  --l_qoh > l_att
                IF (l_debug = 1) THEN
                  mydebug(
                       'Qty in LPN for lot '
                    || l_mtlt_lot_number
                    || ' is less than transaction qty for that lot and lpn is for multiple task'
                  );
                END IF;

                x_match  := 4;
              END IF;
            ELSE
              IF x_match <> 3 THEN
                IF (l_debug = 1) THEN
                  mydebug('qty in LPN for lot ' || l_mtlt_lot_number || ' is equal to transaction qty for that lot');
                END IF;

                IF l_qoh = l_att THEN
                  IF (l_debug = 1) THEN
                    mydebug('lpn qoh is equal to att. Exact match');
                  END IF;
                  -- Bug #4141928
                  l_sec_qty_str := l_lot_sec_qty_string;
                  x_match  := 1;
                ELSE
                  IF (l_debug = 1) THEN
                    mydebug('lpn qoh is great than att. part of lpn is match');
                  END IF;

                  x_match  := 4;
                END IF;
              END IF;
            END IF;
          END IF;

          if x_match <> 4 then
              IF (l_debug = 1) THEN
                   mydebug('x_match is not 4.');
              END IF;
              IF x_match <> 1 THEN
                  l_check_tolerance := false;
                  IF (l_debug = 1) THEN
                        mydebug('x_match is not 1, set l_check_tolerance to false');
                  END IF;
              ELSE
                  IF (l_debug = 1) THEN
                      mydebug('x_match is 1 so far');
                  END IF;
              END IF;
          else
            IF (l_debug = 1) THEN
                    mydebug('x_match is 4');
            END IF;
            if l_check_tolerance then
                  IF (l_debug = 1) THEN
                        mydebug('l_check_tolerance is true');
                  END IF;
                  IF l_mtlt_primary_qty > l_att then
                     l_check_tolerance := false;
                     IF (l_debug = 1) THEN
                        mydebug('lpn has less qty than transaction qty for that lot. set l_check_tolerance to false');
                     END IF;
                  else -- in multiple lots case, since l_check_tolerance is for each lot, we will not
                       -- set l_check_tolerance to false when lpn_lot_qty = allocated_lot_qty.
                     IF (l_debug = 1) THEN
                        mydebug('LPN has more or equal qty than transaction qty for that lot');
                     END IF;
                     if l_qoh > l_att then
                         l_check_tolerance := false;
                         IF (l_debug = 1) THEN
                           mydebug('l_qoh > l_att, set l_check_tolerance to false');
                         END IF;
                     end if;
                  end if;
             end if;
          end if;

          IF NVL(l_allocated_lpn_id, 0) = p_fromlpn_id THEN
            --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
            -- in order to get correct att.
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => l_mtlt_primary_qty
    , p_secondary_quantity         => l_mtlt_secondary_qty -- Bug #4141928
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , x_sqoh                       => l_sqoh        -- Bug #4141928
            , x_srqoh                      => l_srqoh                -- Bug #4141928
            , x_sqr                        => l_sqr                  -- Bug #4141928
            , x_sqs                        => l_sqs                  -- Bug #4141928
            , x_satt                       => l_satt                 -- Bug #4141928
            , x_satr                       => l_satr                 -- Bug #4141928
            , p_lpn_id                     => p_fromlpn_id
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('update qty tree back 3rd time for lpn l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
      mydebug('update qty tree back 3rd time for lpn l_satt:' || l_satt || ' for lot:' || l_mtlt_lot_number);  -- Bug #4141928
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('calling update qty tree with lpn 3rd time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          --Bug#5649056: only update if subinventory and locator match
          ELSIF ( l_lpn_sub = l_mmtt_sub AND l_lpn_loc = l_mmtt_loc ) THEN
            inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_cnt
            , x_msg_data                   => l_msg_data
            , p_organization_id            => p_org_id
            , p_inventory_item_id          => p_item_id
            , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
            , p_is_revision_control        => b_is_revision_control
            , p_is_lot_control             => TRUE
            , p_is_serial_control          => b_is_serial_control
            , p_revision                   => NVL(p_rev, NULL)
            , p_lot_number                 => l_mtlt_lot_number
            , p_subinventory_code          => l_sub
            , p_locator_id                 => l_loc_id
            , p_primary_quantity           => l_mtlt_primary_qty
    , p_secondary_quantity         => l_mtlt_secondary_qty -- Bug #4141928
            , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
            , x_qoh                        => l_qoh
            , x_rqoh                       => l_rqoh
            , x_qr                         => l_qr
            , x_qs                         => l_qs
            , x_att                        => l_att
            , x_atr                        => l_atr
            , x_sqoh                       => l_sqoh        -- Bug #4141928
            , x_srqoh                      => l_srqoh                -- Bug #4141928
            , x_sqr                        => l_sqr                  -- Bug #4141928
            , x_sqs                        => l_sqs                  -- Bug #4141928
            , x_satt                       => l_satt                 -- Bug #4141928
            , x_satr                       => l_satr                 -- Bug #4141928
            --  , p_lpn_id                =>   p_fromlpn_id      withour lpn_id, only to locator level
            , p_transfer_subinventory_code => l_xfr_sub_code
            );

            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('after update qty tree back without lpn 3rd time l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
      mydebug('after update qty tree back without lpn 3rd time l_satt:' || l_satt || ' for lot:' || l_mtlt_lot_number);   -- Bug #4141928
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('calling update qty tree back without lpn 3rd time failed ');
              END IF;

              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END LOOP;

        CLOSE lot_csr;

        IF l_lot_cnt > 0 AND p_changelotNoException = 'N' THEN --/* Bug 9448490 Lot Substitution Project */
           IF (l_debug = 1) THEN
                mydebug('l_lot_cnt: '||l_lot_cnt||' l_lot_cnt > 0');
                mydebug('set l_check_tolerance to false');
           END IF;
           l_check_tolerance := false;
           x_match  := 4;
        END IF;

        -- Now that all the lots have been validated, check whether the serial
        -- numbers allocated match the ones in the lpn.

    -- Bug #4141928. No changes required for OPM convergence.
    -- since this is a serial context
        IF p_is_sn_alloc = 'Y'
           AND p_action = 4    THEN

           SELECT COUNT(fm_serial_number)
             INTO l_total_serial_cnt
             FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
            WHERE mtlt.transaction_temp_id = p_temp_id
              AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id;

           IF (l_debug = 1) THEN
                mydebug('SN tot count' || l_total_serial_cnt);
           END IF;

           IF (x_match = 1
               OR x_match = 3 ) THEN
                IF (l_total_serial_cnt = l_serial_exist_cnt) THEN
                  IF (l_debug = 1) THEN
                    mydebug('LPN matches exactly');
                  END IF;
                  x_match  := 1;
                ELSIF(l_total_serial_cnt > l_serial_exist_cnt) THEN
                  IF (l_debug = 1) THEN
                    mydebug('LPN has less');
                  END IF;
                  x_match  := 3;
                ELSE
                  IF (l_debug = 1) THEN
                    mydebug('LPN has extra serials');
                  END IF;
                  x_match  := 4;
                END IF;
            END IF;
            IF (l_check_tolerance) THEN
                IF (l_total_serial_cnt > l_serial_exist_cnt) THEN
                    IF (l_debug = 1) THEN
                         mydebug('There are serials which is not inside the lpn. set l_check_tolerance to false');
                    END IF;
                    l_check_tolerance := false;
                END IF;
            END IF;
        END IF;

        IF l_check_tolerance THEN
              l_overpicked_qty := l_lpn_pr_qty - l_pr_qty;
              IF (l_debug = 1) THEN
                   mydebug('end of mutiple lots, l_check_tolerance is true and l_overpicked_qty: '||l_overpicked_qty);
              END IF;
        END IF;

      ELSE -- Item is not lot controlled
        IF (l_debug = 1) THEN
          mydebug('Not Lot controlled ..');
        END IF;
        -- initialize
        l_check_tolerance := false;
        -- Check serial numbers if serial controlled and serial
        -- allocation is turned on

    -- Bug #4141928. No changes required for OPM convergence.
    -- since this is a serial context
        IF p_is_sn_alloc = 'Y'
           AND p_action = 4 THEN
          IF (l_debug = 1) THEN
            mydebug('SN control and SN allocation on');
          END IF;

          SELECT COUNT(fm_serial_number)
            INTO l_serial_exist_cnt
            FROM mtl_serial_numbers_temp msnt
           WHERE msnt.transaction_temp_id = p_temp_id
             AND msnt.fm_serial_number IN(
                                        SELECT serial_number
                                          FROM mtl_serial_numbers
                                         WHERE lpn_id = p_fromlpn_id
                                           AND inventory_item_id = p_item_id
                                           AND NVL(revision, '-999') = NVL(p_rev, '-999'));


          IF (l_debug = 1) THEN
            mydebug('SN exist count' || l_serial_exist_cnt);
          END IF;

          IF (l_serial_exist_cnt = 0) THEN
            IF (l_debug = 1) THEN
              mydebug('LPN does not have the allocated serials ');
            END IF;

            -- Serial numbers missing for the transaction
            x_match  := 9;
            fnd_message.set_name('INV', 'INV_INT_SERMISEXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        -- Get qty
        IF (l_debug = 1) THEN
          mydebug('get lpn quantity ');
        END IF;

        IF NVL(l_allocated_lpn_id, 0) = p_fromlpn_id THEN
          --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
          -- in order to get correct att.
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => -l_mmtt_qty
    , p_secondary_quantity         => -l_mmtt_sec_qty  -- Bug #4141928
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh         -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
          , p_lpn_id                     => p_fromlpn_id
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('update qty tree with lpn 4th time: l_att:' || l_att);
      mydebug('update qty tree with lpn 4th time: l_satt:' || l_satt);  -- Bug #4141928
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('calling update qty tree with lpn 4th time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        --Bug#5649056: only update if subinventory and locator match
        ELSIF ( l_lpn_sub = l_mmtt_sub AND l_lpn_loc = l_mmtt_loc ) THEN

          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => -l_mmtt_qty
    , p_secondary_quantity         => -l_mmtt_sec_qty  -- Bug #4141928
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh         -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
          --  , p_lpn_id                =>   p_fromlpn_id      withour lpn_id, only to locator level
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('update qty tree without lpn 4th time:l_att:' || l_att);
      mydebug('update qty tree without lpn 4th time:l_satt:' || l_satt);  -- Bug #4141928
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('calling update qty tree without lpn 4th time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        inv_quantity_tree_pub.query_quantities(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_cnt
        , x_msg_data                   => l_msg_data
        , p_organization_id            => p_org_id
        , p_inventory_item_id          => p_item_id
        , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode --??
        , p_is_revision_control        => b_is_revision_control
        , p_is_lot_control             => FALSE
        , p_is_serial_control          => b_is_serial_control
        , p_demand_source_type_id      => -9999
        , p_revision                   => NVL(p_rev, NULL)
        , p_lot_number                 => NULL
        , p_subinventory_code          => l_sub
        , p_locator_id                 => l_loc_id
        , x_qoh                        => l_qoh
        , x_rqoh                       => l_rqoh
        , x_qr                         => l_qr
        , x_qs                         => l_qs
        , x_att                        => l_att
        , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh         -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
        , p_lpn_id                     => p_fromlpn_id
        , p_transfer_subinventory_code => l_xfr_sub_code
        , p_grade_code                 => NULL                   -- Bug #4141928
        );

        IF (l_return_status = fnd_api.g_ret_sts_success) THEN
          IF (l_debug = 1) THEN
            mydebug('lpn quantity = ' || l_att);
    mydebug('lpn sec quantity = ' || l_satt);
          END IF;

     -- Bug #4141928. No changes required for OPM convergence.
     -- let primary qty drive the lpn match
          IF l_mmtt_qty = l_att THEN
            IF l_qoh = l_att THEN
              -- LPN is a match!
              IF (l_debug = 1) THEN
                mydebug('LPN matched');
              END IF;
              -- Bug #4141928
              l_sec_qty_str := l_lpn_sec_qty;
              x_match  := 1;
            ELSE
              -- LPN is for multiple task
              IF (l_debug = 1) THEN
                mydebug('LPN has multiple task.');
              END IF;

              x_match  := 4;
            END IF;

          ELSIF l_mmtt_qty > l_att THEN
            IF l_qoh = l_att THEN
              IF (l_debug = 1) THEN
                mydebug('lpn has less requested qty and lpn is whole allocation');
              END IF;
              -- Bug #4141928
              l_sec_qty_str := l_lpn_sec_qty;

              x_match  := 3;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('lpn has less than requested qty and lpn is partial allocation');
              END IF;

              x_match  := 4;
            END IF;

            l_lpn_pr_qty  := l_att;
    l_lpn_sec_qty  := l_satt;  -- Bug #4141928
          ELSE
            x_match  := 4;

            --bug 3547725
            l_lpn_pr_qty := l_att;
            l_lpn_sec_qty  := l_satt;  -- Bug #4141928
            IF l_qoh = l_att THEN
                --{{ calculate l_overpicked_qty for vanilla and serial item}}
                l_check_tolerance := true;
                l_overpicked_qty := l_lpn_pr_qty -  l_mmtt_qty;
                IF (l_debug = 1) THEN
                  mydebug('lpn has more than requested qty for loose or serial controlled item.');
                  mydebug('l_over_picked_qty is: '||l_overpicked_qty);
                END IF;
            END IF;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('calling qty tree 4th time failed');
          END IF;

          fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
          fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF NVL(l_allocated_lpn_id, 0) = p_fromlpn_id THEN
          --from lpn is the same as allocated_lpn, we need to update qty tree as negative qty
          -- in order to get correct att.
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => l_mmtt_qty
    , p_secondary_quantity         => l_mmtt_sec_qty -- Bug #4141928
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh         -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
          , p_lpn_id                     => p_fromlpn_id
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('update qty tree back with lpn 4th time: l_att:' || l_att);
      mydebug('update qty tree back with lpn 4th time: l_satt:' || l_satt);  -- Bug #4141928
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('calling update qty tree back with lpn 4th time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        --Bug#5649056: only update if subinventory and locator match
        ELSIF ( l_lpn_sub = l_mmtt_sub AND l_lpn_loc = l_mmtt_loc ) THEN
          inv_quantity_tree_pub.update_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => FALSE
          , p_is_serial_control          => b_is_serial_control
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => NULL
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , p_primary_quantity           => l_mmtt_qty
    , p_secondary_quantity         => l_mmtt_sec_qty -- Bug #4141928
          , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
    , x_sqoh                       => l_sqoh         -- Bug #4141928
    , x_srqoh                      => l_srqoh                -- Bug #4141928
    , x_sqr                        => l_sqr                  -- Bug #4141928
    , x_sqs                        => l_sqs                  -- Bug #4141928
    , x_satt                       => l_satt                 -- Bug #4141928
    , x_satr                       => l_satr                 -- Bug #4141928
          --  , p_lpn_id                =>   p_fromlpn_id      withour lpn_id, only to locator level
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('update qty tree back without lpn 4th time:l_att:' || l_att);
      mydebug('update qty tree back without lpn 4th time:l_satt:' || l_satt);
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('calling update qty tree back without lpn 4th time failed ');
            END IF;

            fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
            fnd_message.set_token('ROUTINE', 'INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        -- If the LPN quantity exactly matches/ has less than, the requested
        -- quantity then match the serial numbers also

    -- Bug #4141928. No changes required for OPM convergence.
    -- Since this is a serial context
        IF p_is_sn_alloc = 'Y'
           AND p_action = 4    THEN

           SELECT COUNT(fm_serial_number)
             INTO l_total_serial_cnt
             FROM mtl_serial_numbers_temp msnt
            WHERE msnt.transaction_temp_id = p_temp_id;

           IF (l_debug = 1) THEN
                 mydebug('SN tot count' || l_total_serial_cnt);
           END IF;
           IF (x_match = 1
               OR x_match = 3 )   THEN

                IF (l_total_serial_cnt = l_serial_exist_cnt) THEN
                  IF (l_debug = 1) THEN
                    mydebug('LPN matches exactly.');
                  END IF;

                  x_match  := 1;

                ELSIF(l_total_serial_cnt > l_serial_exist_cnt) THEN
                  IF (l_debug = 1) THEN
                    mydebug('LPN has less.');
                  END IF;

                  x_match    := 3;
                  l_lpn_pr_qty  := l_serial_exist_cnt;
                ELSE
                  IF (l_debug = 1) THEN
                    mydebug('LPN has extra serials.');
                  END IF;
                  x_match  := 4;
                END IF;
            END IF;
            IF (l_check_tolerance) THEN
               IF l_total_serial_cnt > l_serial_exist_cnt THEN
                   IF (l_debug = 1) THEN
                       mydebug('There are serials which is not inside the lpn. set l_check_tolerance to false');
                   END IF;
                   l_check_tolerance := false;
               END IF;
            END IF;
        END IF;


        IF (l_debug = 1) THEN
            mydebug('After 4');
        END IF;
      END IF; -- lot control check
    END IF; -- lpn has only one item

    --/* Bug 9448490 Lot Substitution Project */ start
     mydebug('lpn_match - lot_substitution_csr - p_transaction_action_id');
    mydebug('lpn_match - lot_substitution_csr - l_is_lot_control' || l_is_lot_control);
    mydebug('lpn_match - lot_substitution_csr - p_is_sn_alloc' || p_is_sn_alloc);
    mydebug('lpn_match - lot_substitution_csr -p_changelotNoException' || p_changelotNoException);

    IF p_transaction_action_id = 28
       AND l_is_lot_control = 'Y'
       AND p_is_sn_alloc ='N'
       AND p_changelotNoException = 'Y'
    THEN
    mydebug('before opening lot_substitution_csr');
	OPEN lot_substitution_csr;
	 LOOP
	   FETCH lot_substitution_csr INTO l_mtlt_primary_qty, l_mtlt_lot_number;
	   EXIT WHEN lot_substitution_csr%NOTFOUND;

	  IF (x_match = 1 OR x_match = 3) THEN
	      x_match :=4 ;
	  END IF;

           IF (l_debug = 1) THEN
              mydebug(' Unallocated l_mtlt_lot_number : ' || l_mtlt_lot_number);
              mydebug(' Unallocated l_mtlt_primary_qty: ' || l_mtlt_primary_qty);
           END IF;

	 inv_quantity_tree_pub.query_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => TRUE
          , p_is_serial_control          => b_is_serial_control
          , p_demand_source_type_id      => -9999
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => l_mtlt_lot_number
          , p_subinventory_code          => l_sub
          , p_locator_id                 => l_loc_id
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          , p_lpn_id                     => p_fromlpn_id
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_att > 0) THEN
              l_table_index  := l_table_index + 1;
              IF (l_debug = 1) THEN
                mydebug('Unallocated  l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
                mydebug('Unallocated  l_qoh:' || l_qoh || ' for lot:' || l_mtlt_lot_number);
              END IF;

              IF l_att < l_qoh THEN
                  l_check_tolerance := false;
                  IF (l_debug = 1) THEN
                    mydebug(' Unallocated Lots l_att < l_qoh: set l_check_tolerance to false');
                  END IF;
              END IF;

              IF (l_debug = 1) THEN
                  mydebug(' Unallocated l_table_index:' || l_table_index || ' lot_number:' || l_mtlt_lot_number || ' qty: ' || l_att);
              END IF;
              l_lpn_pr_qty                                   := l_lpn_pr_qty + l_att;
              t_lpn_lot_qty_table(l_table_index).lpn_id      := p_fromlpn_id;
              t_lpn_lot_qty_table(l_table_index).lot_number  := l_mtlt_lot_number;
              t_lpn_lot_qty_table(l_table_index).pri_qty := l_att;

              IF (l_primary_uom = p_trx_uom) THEN
                     t_lpn_lot_qty_table(l_table_index).trx_qty := l_att;
              ELSE
                     t_lpn_lot_qty_table(l_table_index).trx_qty := inv_convert.inv_um_convert(
                                               item_id        => p_item_id
                                              ,precision      => null
                                              ,from_quantity  => l_att
                                              ,from_unit      => l_primary_uom
                                              ,to_unit        => p_trx_uom
                                              ,from_name      => null
                                              ,to_name        => null);
              END IF;


            ELSE
               IF (l_debug = 1) THEN
                  mydebug('Unallocated - LPN does not have any available qty for lot ' || l_mtlt_lot_number);
                  mydebug('Unallocated - set l_check_tolerance to false');
               END IF;
              l_check_tolerance := false;
	    END IF;
	  END IF;
	  END LOOP;
	CLOSE lot_substitution_csr;

           l_overpicked_qty := l_lpn_pr_qty - l_pr_qty;
	   IF l_overpicked_qty > 0  THEN
                l_check_tolerance := true ;
            END IF;
           IF (l_debug = 1) THEN
             mydebug(' Unallocated :end of mutiple lots, l_check_tolerance is true and l_overpicked_qty: '||l_overpicked_qty);
           END IF;
      END IF;

-- Lot Substitution


    --/* Bug 9448490 Lot Substitution Project */ end

    --check ship tolerance
    IF     p_pickOverNoException = 'Y'
       AND l_check_tolerance
       AND p_transaction_action_id = 28
       AND x_match in (1, 4) --/* Bug 9448490 Lot Substitution Project */
    THEN
        IF (l_debug = 1) THEN
                       mydebug('calling INV_Replenish_Detail_PUB.check_overpick');
                       mydebug('p_transaction_temp_id: '||p_temp_id);
                       mydebug('p_overpicked_qty:      '||l_overpicked_qty);
                       mydebug('p_item_id:'             ||p_item_id);
                       mydebug('p_rev:'                 ||p_rev);
                       mydebug('p_lot_num: NULL');
                       mydebug('p_lot_exp_date: NULL');
                       mydebug('p_sub:                 '||l_sub);
                       mydebug('p_locator_id:          '||l_locator_id);
                       mydebug('p_lpn_id:              '||p_fromlpn_id);

         END IF;
         INV_Replenish_Detail_PUB.check_overpick(
           p_transaction_temp_id   => p_temp_id
         , p_overpicked_qty        => l_overpicked_qty
         , p_item_id               => p_item_id
         , p_rev                   => p_rev
         , p_lot_num               => NULL
         , p_lot_exp_date          => NULL
         , p_sub                   => l_sub
         , p_locator_id            => l_locator_id
         , p_lpn_id                => p_fromlpn_id
         , x_check_overpick_passed => l_check_overpick_passed--OUT NOCOPY    VARCHAR
         , x_ovpk_error_code       => l_overpick_error_code --OUT NOCOPY    NUMBER
         , x_return_status         => l_return_status
         , x_msg_count             => l_msg_cnt
         , x_msg_data              => l_msg_data
         );


         IF x_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF l_check_overpick_passed = 'Y' THEN
             x_lpnpickedasis := 'Y';
         ELSE
             IF (l_debug = 1) THEN
                 mydebug('over picking is not passed. the Error code is: ' || l_overpick_error_code);
             END IF;
         END IF;

    END IF;


    IF x_match = 1
       OR x_match = 3 THEN
      IF p_action = 4 THEN
        -- serial controlled - CHECK serial status
        IF (l_debug = 1) THEN
          mydebug('x_match is ' || x_match || ' and item is serial controlled ');
        END IF;

        OPEN ser_csr;

        LOOP
          FETCH ser_csr INTO l_serial_number;
          EXIT WHEN ser_csr%NOTFOUND;

          IF inv_material_status_grp.is_status_applicable(
               p_wms_installed              => p_wms_installed
             , p_trx_status_enabled         => NULL
             , p_trx_type_id                => p_transaction_type_id
             , p_lot_status_enabled         => NULL
             , p_serial_status_enabled      => NULL
             , p_organization_id            => p_org_id
             , p_inventory_item_id          => p_item_id
             , p_sub_code                   => x_sub
             , p_locator_id                 => NULL
             , p_lot_number                 => p_lot
             , p_serial_number              => l_serial_number
             , p_object_type                => 'A'
             ) = 'N' THEN
            IF (l_debug = 1) THEN
              mydebug('After 6');
            END IF;

            x_match  := 11;
            CLOSE ser_csr;
            fnd_message.set_name('INV', 'INV_SER_STATUS_NA');
            fnd_message.set_token('TOKEN', l_serial_number);
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END LOOP;

        CLOSE ser_csr;
      ELSE
        l_serial_number  := NULL;

        -- Check whether the LPN status is applicable for this transaction
        IF inv_material_status_grp.is_status_applicable(
             p_wms_installed              => p_wms_installed
           , p_trx_status_enabled         => NULL
           , p_trx_type_id                => p_transaction_type_id
           , p_lot_status_enabled         => NULL
           , p_serial_status_enabled      => NULL
           , p_organization_id            => p_org_id
           , p_inventory_item_id          => p_item_id
           , p_sub_code                   => x_sub
           , p_locator_id                 => NULL
           , p_lot_number                 => p_lot
           , p_serial_number              => l_serial_number
           , p_object_type                => 'A'
           ) = 'N' THEN
          x_match  := 8;
          -- LPN status is invalid for this operation

          fnd_message.set_name('INV', 'INV_INVALID_LPN_STATUS');
          fnd_message.set_token('TOKEN1', TO_CHAR(p_fromlpn_id));
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('x_match : ' || x_match);
      mydebug('p_is_sn_alloc : ' || p_is_sn_alloc);
      mydebug('p_action : ' || p_action);
      mydebug('l_lpn_pr_qty (in primary uom): ' || l_lpn_pr_qty);
    END IF;

    -- Now l_lpn_pr_qty is in primary uom, need to convert l_lpn_trx_qty in transaction uom (p_trx_uom)
    -- if they are different
    IF (p_trx_uom <> l_primary_uom) THEN
          l_lpn_trx_qty := inv_convert.inv_um_convert(
                     item_id        => p_item_id
                    ,precision      => null
                    ,from_quantity  => l_lpn_pr_qty
                    ,from_unit      => l_primary_uom
                    ,to_unit        => p_trx_uom
                    ,from_name      => null
                    ,to_name        => null);
          IF (l_debug = 1) THEN
              mydebug('l_lpn_trx_qty :' || l_lpn_trx_qty);
         END IF;
    ELSE
       l_lpn_trx_qty :=  l_lpn_pr_qty;
    END IF;



    -- populate the temp table to be used in lot and serial processing
    -- ideally this should be done during above process for each case, need
    -- revisit them later on


    delete from wms_allocations_gtmp;

    -- Bug #4141928. No changes required for OPM convergence.
  -- Since this is a serial context
    IF p_is_sn_alloc = 'Y'
       AND p_action = 4 THEN
        IF (l_debug = 1) THEN
          mydebug('SN control and SN allocation on');
        END IF;

        IF l_lot_code > 1 THEN

             INSERT INTO WMS_ALLOCATIONS_GTMP
             (lot_number,
              serial_number,
              transaction_quantity,
              primary_quantity)
              SELECT mtlt.lot_number,fm_serial_number,1,1
              FROM mtl_serial_numbers_temp msnt,
                   mtl_transaction_lots_temp mtlt,
                   mtl_serial_numbers msn
              WHERE mtlt.transaction_temp_id = p_temp_id
                AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
                AND msnt.fm_serial_number = msn.serial_number
                AND msn.lpn_id = p_fromlpn_id
                AND msn.inventory_item_id = p_item_id;

             -- jxlu 10/12/04 start
             IF (x_lpnpickedasis= 'Y')  THEN
                   x_trx_qty_alloc := l_lpn_trx_qty;
                   IF (l_debug = 1) THEN
                          mydebug('lot controlled.SN allocated and x_lpnpickedasis is Y. ');
                          mydebug(' x_trx_qty_alloc:'||x_trx_qty_alloc);
                   END IF;
             ELSE
                   x_trx_qty_alloc := SQL%ROWCOUNT;
                   IF (l_debug = 1) THEN
                          mydebug('lot controlled.SN allocated and x_lpnpickedasis is N. ');
                          mydebug(' x_trx_qty_alloc:'||x_trx_qty_alloc);
                   END IF;
            END IF;

             -- populate the lot vector
             l_table_index := 0;
             FOR lot_ATT_rec in lot_att LOOP
                    l_table_index := l_table_index + 1;
                    IF (l_debug = 1) THEN
                           mydebug('lot_ATT_rec.lot_number: '||lot_ATT_rec.lot_number);
                           mydebug('lot_ATT_rec.transaction_quantity: '||lot_ATT_rec.transaction_quantity);
                    END IF;
                    -- since trx_qty already populated before, we can only use
                    -- non_alloc_qty to temporarily hold the value. later when generating
                    -- string, then properly place them in the string passed back to java
                    t_lpn_lot_qty_table(l_table_index).non_alloc_qty := lot_ATT_rec.transaction_quantity;

             END LOOP;

             IF (l_debug = 1) THEN
                   mydebug('lot controlled. x_trx_qty_alloc:'||x_trx_qty_alloc);
             END IF;
             --jxlu 10/12/04 end
        ELSE -- not lot controlled
            INSERT INTO WMS_ALLOCATIONS_GTMP
             (serial_number,
              transaction_quantity,
              primary_quantity)
              SELECT fm_serial_number,1,1
              FROM mtl_serial_numbers_temp msnt,
                   mtl_serial_numbers msn
              WHERE  msnt.transaction_temp_id = p_temp_id
                AND msnt.fm_serial_number = msn.serial_number
                AND msn.lpn_id = p_fromlpn_id
                AND msn.inventory_item_id = p_item_id;

            --jxlu 10/12/04 start
            IF (x_lpnpickedasis ='Y')  THEN
                x_trx_qty_alloc := l_lpn_trx_qty;
                IF (l_debug = 1) THEN
                      mydebug('NOT lot controlled.SN allocated and x_lpnpickedasis is Y. ');
                      mydebug(' x_trx_qty_alloc:'||x_trx_qty_alloc);
                END IF;
            ELSE
                x_trx_qty_alloc := SQL%ROWCOUNT;
                IF (l_debug = 1) THEN
                      mydebug('NOT lot controlled.SN allocated and x_lpnpickedasis is N. ');
                      mydebug(' x_trx_qty_alloc:'||x_trx_qty_alloc);
                END IF;
            END IF;
            -- jxlu 10/12/04 end
       END IF;
    ELSIF p_is_sn_alloc = 'N' AND p_action = 4 AND x_match = 3 THEN

          IF (l_debug = 1) THEN
             mydebug('SN control and SN allocation off and x_match=3');
          END IF;

          IF l_lot_code > 1 THEN
                INSERT INTO wms_allocations_gtmp
                (lot_number,
                 serial_number,
                 transaction_quantity,
                 primary_quantity)
                SELECT mtlt.lot_number, serial_number, 1, 1
                FROM mtl_transaction_lots_temp mtlt,
                     mtl_serial_numbers msn
                WHERE mtlt.transaction_temp_id = p_temp_id
                  AND msn.lpn_id = p_fromlpn_id
                  AND mtlt.lot_number = msn.lot_number
                  AND msn.inventory_item_id = p_item_id
                  AND Nvl(msn.group_mark_id, -1) = -1;
          ELSE
               INSERT INTO wms_allocations_gtmp
                (serial_number,
                 transaction_quantity,
                 primary_quantity)
                SELECT serial_number,1,1
                FROM mtl_serial_numbers msn
                WHERE msn.lpn_id = p_fromlpn_id
                AND msn.inventory_item_id = p_item_id
                AND Nvl(msn.group_mark_id, -1) = -1;
          END IF;
    ELSIF l_lot_code > 1 THEN -- lot controlled

       IF (l_debug = 1) THEN
             mydebug('lot controlled....');
       END IF;

       l_table_total      := t_lpn_lot_qty_table.COUNT;
       IF l_table_total > 0 THEN
         IF (l_debug = 1) THEN
           mydebug('building lpn lot vector for ' || l_table_total || '
                   records');
         END IF;

        FOR l_table_count IN 1 .. l_table_total LOOP
            IF (l_debug = 1) THEN
              mydebug('index is : ' || l_table_count);
            END IF;

            INSERT INTO wms_allocations_gtmp(lot_number, primary_quantity,
                                             transaction_quantity, secondary_quantity)  -- Bug #4141928
                   values(t_lpn_lot_qty_table(l_table_count).lot_number,
                          t_lpn_lot_qty_table(l_table_count).pri_qty,
                          t_lpn_lot_qty_table(l_table_count).trx_qty,
          t_lpn_lot_qty_table(l_table_count).sec_qty
          );                     -- Bug #4141928

          END LOOP;
       END IF;


    END IF; -- done populating the lot


    --populate the lot in lpn vector

    l_table_total      := t_lpn_lot_qty_table.COUNT;

    IF l_table_total > 0 THEN
          IF (l_debug = 1) THEN
           mydebug('building lpn lot vector for ' || l_table_total || 'records');
          END IF;


          FOR l_table_count IN 1 .. l_table_total LOOP
                IF (l_debug = 1) THEN
                      mydebug('index is : ' || l_table_count);
                END IF;
                IF p_is_sn_alloc = 'Y'  THEN  -- serial allocated
                    IF (l_debug = 1) THEN
                          mydebug('serial is allocated');
                    END IF;
                    IF (x_lpnpickedasis ='Y') THEN
                       IF (l_debug = 1) THEN
                           mydebug('x_lpnpickedasis is Y');
                       END IF;
                         IF l_value = '.,' THEN   --bug 6651517 added if on the basis of l_value

                       x_lpn_lot_vector := x_lpn_lot_vector
                             ||t_lpn_lot_qty_table(l_table_count).lot_number ||'@@@@@'
                             ||t_lpn_lot_qty_table(l_table_count).trx_qty||'@@@@@'
                             ||t_lpn_lot_qty_table(l_table_count).trx_qty
                             || '&&&&&'
                             || t_lpn_lot_qty_table(l_table_count).sec_qty   -- Bug #4141928
                             || '#####';                                     -- Bug #4141928
                        ELSE
                              x_lpn_lot_vector := x_lpn_lot_vector
                             ||t_lpn_lot_qty_table(l_table_count).lot_number ||'@@@@@'
                             ||TO_CHAR(t_lpn_lot_qty_table(l_table_count).trx_qty,'9999999999999999999999.9999999999')||'@@@@@'
                             ||TO_CHAR(t_lpn_lot_qty_table(l_table_count).trx_qty,'9999999999999999999999.9999999999')
                             || '&&&&&'
                             || TO_CHAR(t_lpn_lot_qty_table(l_table_count).sec_qty,'9999999999999999999999.9999999999')   -- Bug #4141928
                             || '#####';
                         END IF;
                         -- end of bug 6651517
                        l_lot_v   := l_lot_v
                                ||t_lpn_lot_qty_table(l_table_count).lot_number||':'; --Bug 3855835
                    ELSE
                      IF (l_debug = 1) THEN
                           mydebug('x_lpnpickedasis is N');
                      END IF;
                        IF l_value = '.,' THEN   --bug 6651517 added if on the basis of l_value
                           x_lpn_lot_vector := x_lpn_lot_vector
                             ||t_lpn_lot_qty_table(l_table_count).lot_number ||'@@@@@'
                             ||t_lpn_lot_qty_table(l_table_count).non_alloc_qty||'@@@@@'
                             ||t_lpn_lot_qty_table(l_table_count).trx_qty
                             || '&&&&&'
                             || t_lpn_lot_qty_table(l_table_count).sec_qty   -- Bug #4141928
                             || '#####';                                     -- Bug #4141928
                          else
                            x_lpn_lot_vector := x_lpn_lot_vector
                             ||t_lpn_lot_qty_table(l_table_count).lot_number ||'@@@@@'
                             ||TO_CHAR(t_lpn_lot_qty_table(l_table_count).non_alloc_qty,'9999999999999999999999.9999999999')||'@@@@@'
                             ||TO_CHAR(t_lpn_lot_qty_table(l_table_count).trx_qty,'9999999999999999999999.9999999999')
                             || '&&&&&'
                           || TO_CHAR(t_lpn_lot_qty_table(l_table_count).sec_qty,'9999999999999999999999.9999999999')   -- Bug #4141928
                             || '#####';                                     -- Bug #4141928

                           END IF;
                            --end of bug 6651517
                        l_lot_v   := l_lot_v
                                ||t_lpn_lot_qty_table(l_table_count).lot_number||':'; --Bug 3855835
                    END IF;
                    IF (l_debug = 1) THEN
                          mydebug('x_lpn_lot_vector:'||x_lpn_lot_vector);
                    END IF;
                ELSE  -- serial is not allocated
                    IF (l_debug = 1) THEN
                        mydebug('serial is NOT allocated');
                    END IF;
                    --bug 6651517 added if on the basis of l_value
                   IF l_value = '.,'    THEN
                    x_lpn_lot_vector := x_lpn_lot_vector
                             ||t_lpn_lot_qty_table(l_table_count).lot_number ||'@@@@@'
                             ||t_lpn_lot_qty_table(l_table_count).trx_qty||'@@@@@'
                             ||t_lpn_lot_qty_table(l_table_count).trx_qty
                             || '&&&&&'
                             || t_lpn_lot_qty_table(l_table_count).sec_qty   -- Bug #4141928
                             || '#####';                                     -- Bug #4141928
                   ELSE
                     x_lpn_lot_vector := x_lpn_lot_vector
                             ||t_lpn_lot_qty_table(l_table_count).lot_number ||'@@@@@'
                             ||TO_CHAR(t_lpn_lot_qty_table(l_table_count).trx_qty,'9999999999999999999999.9999999999')||'@@@@@'
                             ||TO_CHAR(t_lpn_lot_qty_table(l_table_count).trx_qty,'9999999999999999999999.9999999999')
                             || '&&&&&'
                             || TO_CHAR(t_lpn_lot_qty_table(l_table_count).sec_qty,'9999999999999999999999.9999999999')   -- Bug #4141928
                             || '#####';                                     -- Bug #4141928
                    END IF; --end of bug 6651517
                      l_lot_v   := l_lot_v
                                ||t_lpn_lot_qty_table(l_table_count).lot_number||':'; --Bug 3855835
                     IF (l_debug = 1) THEN
                            mydebug('l_lot_v:'||l_lot_v);
                     END IF;
                END IF;
          END LOOP;
    ELSE
          IF (l_debug = 1) THEN
               mydebug('it is not lot controlled and lot in lpn vector is null... ' );
          END IF;
           x_lpn_lot_vector  := NULL;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('LPN QTY in primary uom' || l_lpn_pr_qty);
      mydebug('LPN QTY in transaction uom' || l_lpn_trx_qty);
  mydebug('LPN Secondary QTY' || l_lpn_sec_qty);  -- Bug #4141928
      mydebug('x_temp_id: ' || l_out_temp_id);
    END IF;

    x_temp_id          := l_out_temp_id;
    --bug 3547725
    --x_trx_qty              := LEAST(l_lpn_trx_qty, p_trx_qty);
    x_trx_qty          := l_lpn_trx_qty;
    x_trx_sec_qty      := l_lpn_sec_qty;   -- Bug #4141928
   -- bug 3983704
    -- get the packed qoh since the qty tree always return for both loosepack
    SELECT NVL(SUM(primary_transaction_quantity),0), NVL(SUM(secondary_transaction_quantity),0)
    INTO l_qoh, l_sqoh
    FROM mtl_onhand_quantities_detail
    WHERE lpn_id = p_fromlpn_id
      AND organization_id = p_org_id;

    IF (p_trx_uom <> l_primary_uom) THEN
          x_lpn_qoh := inv_convert.inv_um_convert(
                     item_id        => p_item_id
                    ,precision      => null
                    ,from_quantity  => l_qoh
                    ,from_unit      => l_primary_uom
                    ,to_unit        => p_trx_uom
                    ,from_name      => null
                    ,to_name        => null);
          IF (l_debug = 1) THEN
              mydebug(' x_lpn_qoh :' ||  x_lpn_qoh);
         END IF;
    ELSE x_lpn_qoh := l_qoh;
    END IF;
    --x_lpn_qoh := l_sqoh;
    x_return_status    := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('Match ' || x_match);
    END IF;

  /*  Mrana: 12/10/03: we need not change the lpn_context here . We will do it in
 *  LOAD/split merge API . to avoid hassles of setting and resetting in case
 *  users picks one lpn and then using cursor key goes up to change it .
 *  Also, with this approach , we do not need to reset lpn context in case of F2
 *  We will select this LPN for Update , so that otehr processes cannot get it.
 *  yes, there is a possibility that
 */
    IF (x_match = 3) or (x_match = 1) THEN   -- added x_match=1
       IF (l_debug = 1) THEN
         mydebug('Lock lpn_ID : ' || p_fromlpn_id);
       END IF;
      BEGIN

         SELECT lpn_context
           INTO l_lpn_context
           FROM wms_license_plate_numbers
          WHERE lpn_id = p_fromlpn_id
            FOR UPDATE NOWAIT;
      EXCEPTION
         WHEN OTHERS THEN
            IF SQLCODE  = -54 THEN  -- ORA-0054: resource busy and acquire with NOWAIT specified
               mydebug('LPN record is locked by another user... cannot pick this LPN' );
               fnd_message.set_name('WMS', 'WMS_LPN_LOCKED_ERROR');
                                  -- LPN is in use  by another user
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            ELSE
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

       END ;
    END IF;

        --Bug3855835


    IF l_lot_v IS NOT NULL THEN
     l_lot_v := SUBSTR(l_lot_v,1,LENGTH(l_lot_v)-1);
    END IF;

    IF p_toLPN_Default IS NOT NULL  THEN

    validate_pick_to_lpn
    ( p_api_version_number          =>   1.0
    , p_init_msg_lst                =>   NULL
    , x_return_status               =>   x_return_status
    , x_msg_count                   =>   l_msg_cnt
    , x_msg_data                    =>   l_msg_data
    , p_organization_id             =>   p_org_id
    , p_pick_to_lpn                 =>   p_toLPN_Default
    , p_temp_id                     =>   p_temp_id
    , p_project_id                  =>   p_project_id
    , p_task_id                     =>   p_task_id
    , p_container_item              =>   NULL
    , p_container_item_id           =>   NULL
    , p_suggested_container_item    =>   NULL
    , p_suggested_container_item_id =>   NULL
    , p_suggested_carton_name       =>   NULL
    , p_suggested_tolpn_id          =>   NULL
    , x_pick_to_lpn_id              =>   l_pick_to_lpn_id
    , p_inventory_item_id           =>   p_item_id
    , p_confirmed_sub               =>   p_confirmed_sub
    , p_confirmed_loc_id            =>   p_confirmed_loc_id
    , p_revision                    =>   p_rev
    , p_confirmed_lots              =>   l_lot_v
    , p_from_lpn_id                 =>   p_from_lpn_id
    , p_lot_control                 =>   l_is_lot_control
    , p_revision_control            =>   l_is_revision_control
    , p_serial_control              =>   l_is_serial_control
    -- Bug 4632519
    , p_trx_type_id                 =>   to_char(p_transaction_type_id)
    , p_trx_action_id               =>   to_char(p_transaction_action_id)
    -- Bug 4632519
   );


   If x_return_status <> fnd_api.g_ret_sts_success THEN
       x_toLPN_status := 'F';
     IF (l_debug = 1) THEN
      mydebug('Validate_pick_to_lpn could not validate toLPNDefault:');
     END IF;
     x_return_status := fnd_api.g_ret_sts_success;
   Else
    x_toLPN_status := 'T';
    IF (l_debug = 1) THEN
      mydebug('Validate_pick_to_lpn  validated  toLPNDefault:');
     END IF;
  End If;

 END IF;

--Added for bug 8205743 start

IF (l_debug = 1) THEN
	mydebug('lpn_match  l_lpn_pr_qty'|| l_lpn_pr_qty);
	mydebug('lpn_match  x_lpn_qoh'|| x_lpn_qoh);
	mydebug('lpn_match  x_match'|| x_match);
END IF;

IF (x_match = 1 AND x_lpn_qoh <> l_lpn_pr_qty) THEN
	x_match:=4 ;
END IF;

--Added for bug 8205743 end

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
        mydebug(' Expected Exception raised');
      END IF;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
          mydebug(' Unexpected Exception raised');
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('Other exception raised : ' || SQLERRM);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END lpn_match;


--  during the picking process. If the user does not specifies
  -- a from lpn, this procedure will figure out if the loose quantity  will
  -- satisfy the pick in question, the temp table mtl_allocations_gtmp
 -- will store the available lot and serial numbers for this pick

PROCEDURE loose_match(
        p_org_id              IN             NUMBER
      , p_item_id             IN            NUMBER
      , p_rev                 IN            VARCHAR2
      , p_trx_qty             IN            NUMBER
      , p_trx_uom             IN            VARCHAR2
      , p_pri_uom             IN            VARCHAR2
      , p_sec_uom             IN            VARCHAR2          -- Bug #4141928
  , p_sec_qty             IN            NUMBER      -- Bug #4141928
      , p_temp_id             IN            NUMBER
      , p_suggested_locator   IN            NUMBER
      , p_confirmed_locator   IN            NUMBER
      , p_confirmed_sub       IN            VARCHAR2
      , p_is_sn_alloc         IN            VARCHAR2
      , p_is_revision_control IN            VARCHAR2
      , p_is_lot_control      IN            VARCHAR2
      , p_is_serial_control   IN            VARCHAR2
      , p_is_negbal_allowed   IN            VARCHAR2
      , p_toLPN_Default       IN            VARCHAR2 --Bug 3855835
      , p_project_id          IN            NUMBER
      , p_task_id             IN            NUMBER
      , x_trx_qty             OUT NOCOPY    NUMBER
      , x_trx_sec_qty         OUT NOCOPY    NUMBER      -- Bug #4141928
      , x_return_status       OUT NOCOPY    VARCHAR2
      , x_msg_count           OUT NOCOPY    NUMBER
      , x_msg_data            OUT NOCOPY    VARCHAR2
      , x_toLPN_status        OUT NOCOPY    VARCHAR2 --Bug 3855835
      , x_lot_att_vector      OUT NOCOPY    VARCHAR2
      , x_trx_qty_alloc       OUT NOCOPY    NUMBER  -- jxlu 10/6/04
      , p_transaction_type_id IN            NUMBER  -- Bug 4632519
      , p_transaction_action_id IN          NUMBER  -- Bug 4632519
      , p_changelotNoException  IN            VARCHAR2 --/* Bug 9448490 Lot Substitution Project */
  ) IS
    l_proc_name              VARCHAR2(30) := 'LOOSE_MATCH' ;
    l_msg_cnt                NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(1);
    l_lot_primary_qty         NUMBER;
    l_att_trx_qty             NUMBER;
    l_trx_lot_qty             NUMBER;
    l_qoh                     NUMBER;
    l_trx_qoh                 NUMBER;
    l_att                     NUMBER;

    l_lot_sec_qty           NUMBER; -- Bug #4141928
    l_att_trx_sec_qty        NUMBER;   -- Bug #4141928
    l_trx_lot_sec_qty        NUMBER;   -- Bug #4141928
    l_sqoh                   NUMBER;   -- Bug #4141928
    l_trx_sec_qoh            NUMBER;   -- Bug #4141928
    l_satt                   NUMBER;   -- Bug #4141928

-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number              VARCHAR2(80) := null;
    l_debug                   NUMBER         :=
                    NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_table_index             NUMBER := 0;
    l_pick_to_lpn_id          NUMBER;
    l_lot_v                   VARCHAR2(2000) :=null ;
    l_is_lot_control          VARCHAR2(1);
    l_is_revision_control     VARCHAR2(1);
    l_is_serial_control       VARCHAR2(1);

    l_transfer_subinventory  VARCHAR2(10) := NULL; -- Bug #7257709
    CURSOR lot_csr IS
      SELECT mtlt.primary_quantity
           , mtlt.transaction_quantity
           , NVL(mtlt.secondary_quantity, 0)    -- Bug #4141928
           , mtlt.lot_number
        FROM mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id = p_temp_id
       --added material status check for lot under bug8398578
       AND inv_material_status_grp.is_status_applicable(
                                        NULL
                                ,       NULL
                                ,       p_transaction_type_id
                                ,       NULL
                                ,       NULL
                                ,       p_org_id
                                ,       p_item_id
                                ,       NULL
                                ,       null
                                ,       mtlt.lot_number
                                ,       NULL
                                ,       'O') = 'Y'
    ORDER BY LOT_NUMBER;

    CURSOR lot_att IS
      SELECT lot_number, sum(transaction_quantity) transaction_quantity
      from wms_ALLOCATIONS_GTMP
      GROUP BY LOT_NUMBER
      ORDER BY LOT_NUMBER;

    CURSOR mmtt_csr IS
      SELECT transfer_subinventory
      FROM mtl_material_transactions_temp
      WHERE transaction_temp_id = p_temp_id; -- Bug #7257709

      --/* Bug 9448490 Lot Substitution Project */ start
      CURSOR lot_substitution_att IS
       SELECT NVL(SUM(primary_transaction_quantity),0)
	      , NVL(SUM(transaction_quantity), 0)
	      , lot_number
             FROM mtl_onhand_quantities_detail
             WHERE organization_id = p_org_id
	     AND Nvl(containerized_flag, 2) = 2 -- different from lpn_match
             AND subinventory_code = p_confirmed_sub
             AND locator_id = p_confirmed_locator
             AND inventory_item_id = p_item_id
             AND (revision = p_rev OR (revision IS NULL AND p_rev IS NULL))
             AND lot_number NOT IN (
			           SELECT mtlt.lot_number
				   FROM mtl_transaction_lots_temp mtlt
				   WHERE mtlt.transaction_temp_id = p_temp_id
				   )
	    AND lot_number IS NOT NULL
	    GROUP BY lot_number
      UNION
      SELECT mtlt.primary_quantity
           , mtlt.transaction_quantity
           , mtlt.lot_number
        FROM mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id = p_temp_id
            ORDER BY lot_number;
      --/* Bug 9448490 Lot Substitution Project */ end

BEGIN

    SAVEPOINT LOOSE_MATCH ; --
    IF (l_debug = 1) THEN
      mydebug('In loose Match');
    END IF;

    x_return_status     := fnd_api.g_ret_sts_success;
    x_lot_att_vector    := null;

    DELETE wms_allocations_gtmp;
    t_lpn_lot_qty_table.DELETE;

    x_trx_qty       := 0;
    x_trx_sec_qty := 0;  -- Bug #4141928
    x_trx_qty_alloc := 0;

     -- Bug #7257709: pass destination sub code to INV_TXN_VALIDATIONS.get_available_quantity
     -- in case of move order tasks
    IF (p_transaction_type_id = 64 AND p_transaction_action_id = 2) THEN
           OPEN mmtt_csr;
           FETCH mmtt_csr INTO l_transfer_subinventory;
           CLOSE mmtt_csr;
    END IF;

            IF p_is_sn_alloc = 'Y' THEN    -- serial is allocated
       -- create the lot vector and populate the temp table for serial allocated
       -- case
             IF (l_debug = 1) THEN
                  mydebug('SN control and SN allocation on');
             END IF;

             IF p_is_lot_control ='true' THEN -- lot controlled
                 INSERT INTO wms_allocations_gtmp
                 (lot_number,
                  serial_number,
                  transaction_quantity,
                  primary_quantity)
                  SELECT mtlt.lot_number,fm_serial_number,1,1
                  FROM mtl_serial_numbers_temp msnt,
                       mtl_transaction_lots_temp mtlt,
                       mtl_serial_numbers msn
                  WHERE mtlt.transaction_temp_id = p_temp_id
                    AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
                    AND msnt.fm_serial_number = msn.serial_number
                    AND msn.lpn_id is null -- make sure it is loose pick
                    AND msn.inventory_item_id = p_item_id;

                  x_trx_qty_alloc := SQL%ROWCOUNT;
                 -- populate the lot vector
                 FOR lot_ATT_rec in lot_att LOOP
                      IF (l_debug = 1) THEN
                          mydebug('lot_ATT_rec.lot_number: '||lot_ATT_rec.lot_number);
                          mydebug('lot_ATT_rec.transaction_quantity: '||lot_ATT_rec.transaction_quantity);
                      END IF;
                      l_table_index := l_table_index + 1;
                      /*x_lot_att_alloc_v  := x_lot_att_alloc_v
                                           ||lot_ATT_rec.lot_number|| '@@@@@'
                                           ||lot_ATT_rec.transaction_quantity
                                           || '&&&&&'; */
                      t_lpn_lot_qty_table(l_table_index).lot_number  := lot_ATT_rec.lot_number;
                      t_lpn_lot_qty_table(l_table_index).trx_qty     := lot_ATT_rec.transaction_quantity;
                 END LOOP;
           ELSE -- not lot controlled
                INSERT INTO wms_ALLOCATIONS_GTMP
                 (serial_number,
                  transaction_quantity,
                  primary_quantity)
                  SELECT fm_serial_number,1,1
                  FROM mtl_serial_numbers_temp msnt,
                       mtl_serial_numbers msn
                  WHERE  msnt.transaction_temp_id = p_temp_id
                    AND msnt.fm_serial_number = msn.serial_number
                    AND msn.lpn_id is null
                    AND msn.inventory_item_id = p_item_id;

                  x_trx_qty_alloc := SQL%ROWCOUNT;
           END IF;
    END IF;

    IF (l_debug = 1) THEN
           mydebug('x_trx_qty_alloc: '||x_trx_qty_alloc);
    END IF;

    l_table_index := 0;
     mydebug('Opening  lot_csr cursor in loose_match procedure ');
     --/* Bug 9448490 Lot Substitution Project */ start
     mydebug('p_changelotNoException : ' || p_changelotNoException);

    if p_changelotNoException = 'Y' THEN
     OPEN lot_substitution_att;
    else
    OPEN lot_csr;
    end if;
    --   OPEN lot_csr;
     --/* Bug 9448490 Lot Substitution Project */ end

    LOOP

    if (p_is_lot_control ='true' ) then
    --/* Bug 9448490 Lot Substitution Project */ start
    if p_changelotNoException = 'Y' THEN
             	fetch  lot_substitution_att INTO l_lot_primary_qty, l_trx_lot_qty,l_lot_number;
             	exit when lot_substitution_att%NOTFOUND;
             else
             fetch  lot_csr INTO l_lot_primary_qty, l_trx_lot_qty, l_lot_sec_qty, l_lot_number; -- Bug #4141928
             exit when lot_csr%NOTFOUND;
	     end if; --/* Bug 9448490 Lot Substitution Project */
             IF (l_debug = 1) THEN
                 mydebug('l_mtlt_lot_number : ' || l_lot_number);
                 mydebug('l_mtlt_primary_qty: ' || l_lot_primary_qty);
                 mydebug('l_mtlt_secondary_qty: ' || l_lot_sec_qty); -- Bug #4141928
             END IF;

	     end if;

            IF (p_suggested_locator = p_confirmed_locator) THEN
                     UPDATE mtl_material_transactions_temp mmtt
                        SET posting_flag = 'N'
                      WHERE transaction_temp_id = p_temp_id;
                  END IF;


         -- End change - Bug 4185621
        -- always do one query at least for non lot controlled items

        INV_TXN_VALIDATIONS.get_available_quantity
          (x_return_status => l_return_status,
           p_tree_mode  => inv_quantity_tree_pub.g_loose_only_mode,
           p_organization_id =>p_org_id,
           p_inventory_item_id => p_item_id,
           p_is_revision_control =>p_is_revision_control,
           p_is_lot_control =>p_is_lot_control,
           p_is_serial_control =>p_is_serial_control,
           p_revision =>p_rev,
           p_lot_number =>l_lot_number,
           p_grade_code          =>    NULL,        -- Bug #4141928
           p_lot_expiration_date =>null,
           p_subinventory_code =>p_confirmed_sub,
           p_locator_id =>p_confirmed_locator,
           p_source_type_id =>-9999,
           p_cost_group_id => NULL,
           p_to_subinventory_code => l_transfer_subinventory,
           x_qoh                 =>    l_qoh,
           x_att                 =>    l_att,
           x_sqoh                =>    l_sqoh,     -- Bug #4141928
           x_satt                =>    l_satt      -- Bug #4141928
         );


            -- Start change - Bug 4185621: restore posting flag in mmtt

                 IF (p_suggested_locator = p_confirmed_locator) THEN
                     UPDATE mtl_material_transactions_temp mmtt
                        SET posting_flag = 'Y'
                      WHERE transaction_temp_id = p_temp_id;
                 END IF;

                  -- End change - Bug 4185621
           IF (l_return_status = fnd_api.g_ret_sts_success) THEN


        -- convert the qty from primary UOM to transaction UOM

             if (p_pri_uom = p_trx_uom) then
                IF (l_debug = 1) THEN
                       mydebug('primary uom is the same as transaction uom');
                END IF;
                 l_att_trx_qty := l_att;
                 l_trx_qoh := l_qoh;
             else
                 l_att_trx_qty := inv_convert.inv_um_convert(
                                                    item_id        => p_item_id
                                                   ,precision      => null
                                                   ,from_quantity  => l_att
                                                   ,from_unit      => p_pri_uom
                                                   ,to_unit        => p_trx_uom
                                                   ,from_name      => null
                                                   ,to_name        => null);
                 l_trx_qoh := inv_convert.inv_um_convert(
                                                    item_id        => p_item_id
                                                   ,precision      => null
                                                   ,from_quantity  => l_qoh
                                                   ,from_unit      => p_pri_uom
                                                   ,to_unit        => p_trx_uom
                                                   ,from_name      => null
                                                   ,to_name        => null);
             end if;

        l_att_trx_sec_qty := l_satt;   -- Bug #4141928
        l_trx_sec_qoh     := l_sqoh;   -- Bug #4141928

             IF (l_debug = 1) THEN
                   mydebug('l_att_trx_qty: '||l_att_trx_qty);
                   mydebug('l_trx_qoh: '||l_trx_qoh);
                   mydebug('l_att_trx_sec_qty: '||l_att_trx_sec_qty);  -- Bug #4141928
                   mydebug('l_trx_sec_qoh: '||l_trx_sec_qoh);          -- Bug #4141928
             END IF;


          if (p_is_lot_control ='true' ) then
                  -- populate the lot vector

           l_table_index := l_table_index + 1;
                 IF p_is_sn_alloc = 'Y' THEN
                    x_lot_att_vector  := x_lot_att_vector
                                      ||l_lot_number || '@@@@@'
                                      ||t_lpn_lot_qty_table(l_table_index).trx_qty|| '@@@@@'
                                      ||l_att_trx_qty
                                      || '&&&&&'
                                      || l_att_trx_sec_qty     -- Bug #4141928
                                      || '#####';                   -- Bug #4141928
                     l_lot_v   := l_lot_v
                                ||l_lot_number||':'; --Bug 3855835
                    IF (l_debug = 1) THEN
                           mydebug('l_table_index: '||l_table_index);
                           mydebug('x_lot_att_vector: '||x_lot_att_vector);
                    END IF;
                 ELSE -- serial number is not allocated,
                    x_lot_att_vector  := x_lot_att_vector
                                      ||l_lot_number || '@@@@@'
                                      ||l_att_trx_qty|| '@@@@@'
                                      ||l_att_trx_qty
                                      || '&&&&&'
                                      || l_att_trx_sec_qty     -- Bug #4141928
                                      || '#####';                   -- Bug #4141928
                     l_lot_v   := l_lot_v
                                ||l_lot_number||':';
                    IF (l_debug = 1) THEN
                           mydebug('inserting into global temp table for serial is non allocated....');
                    END IF;
                    -- If negative Balance allowed then update vikas 09/07/04 V1
                    if (p_is_negbal_allowed ='true') then
                        INSERT INTO wms_ALLOCATIONS_GTMP
                         (lot_number,
                          primary_quantity,
                          transaction_quantity,
                          secondary_quantity) -- Bug #4141928
                        VALUES( l_lot_number,
                                l_lot_primary_qty,
                                l_trx_lot_qty,
                                l_trx_lot_sec_qty);

                     -- vikas 09/07/04 end
                    else
                        INSERT INTO wms_ALLOCATIONS_GTMP
                          (lot_number,
                           primary_quantity,
                           transaction_quantity,
                           secondary_quantity) -- Bug #4141928
                           VALUES( l_lot_number,
                           LEAST(l_lot_primary_qty,l_att),
                           LEAST(l_trx_lot_qty,l_att_trx_qty),
                           LEAST(l_trx_lot_sec_qty,l_att_trx_sec_qty));
                         end if;
                 END IF;

                 x_trx_qty := x_trx_qty + l_att_trx_qty;
                 x_trx_sec_qty := x_trx_sec_qty + l_att_trx_sec_qty;


                 else   -- pure serial controlled
                 x_trx_qty := l_att_trx_qty;
                 x_trx_sec_qty :=  l_att_trx_sec_qty;       -- Bug #4141928
             end if;

         ELSE
            IF (l_debug = 1) THEN
                mydebug('calling qty tree 1st time failed ');
            END IF;
              fnd_message.set_name('INV', 'INV_INVALID_QUANTITY_TYPE');
              fnd_message.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES');
              fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
        END IF;

	EXIT WHEN  p_is_lot_control ='false';
    END LOOP;

    IF (l_debug = 1) THEN
          mydebug('x_trx_qty: '||x_trx_qty);
          mydebug('x_trx_sec_qty: '||x_trx_sec_qty);  -- Bug #4141928
          mydebug('x_lot_att_vector: '||x_lot_att_vector);
         mydebug('l_lot_v::' ||l_lot_v);
    END IF;

    --/* Bug 9448490 Lot Substitution Project */ start
    if lot_substitution_att%isopen THEN
      CLOSE lot_substitution_att;
    end if;
    if lot_csr%isopen THEN
        CLOSE lot_csr;
    end if;

    --/* Bug 9448490 Lot Substitution Project */ end


    IF l_lot_v IS NOT NULL THEN
     l_lot_v := SUBSTR(l_lot_v,1,LENGTH(l_lot_v)-1);
   END IF;

      --v1 calling validate_pick_to_lpn for validating toLPNdefault and if it
      --returns success then allow to set to LPN field with toLPNDefault on
      --MainPickPage. Bug 3855835


  IF p_toLPN_Default IS NOT NULL  THEN


     If p_is_lot_control ='true' THEN
          l_is_lot_control :='Y';
       Else
          l_is_lot_control :='N';
      END If;

     If p_is_serial_control ='true' THEN
        l_is_serial_control := 'Y';
     Else
       l_is_serial_control := 'N';
     END IF;

     If p_is_revision_control ='true' THEN
       l_is_revision_control := 'Y';
     Else
       l_is_revision_control :='N';
     END If;


    validate_pick_to_lpn
    ( p_api_version_number          =>   1.0
    , p_init_msg_lst                =>   NULL
    , x_return_status               =>   x_return_status
    , x_msg_count                   =>   l_msg_cnt
    , x_msg_data                    =>   l_msg_data
    , p_organization_id             =>   p_org_id
    , p_pick_to_lpn                 =>   p_toLPN_Default
    , p_temp_id                     =>   p_temp_id
    , p_project_id                  =>   p_project_id
    , p_task_id                     =>   p_task_id
    , p_container_item              =>   NULL
    , p_container_item_id           =>   NULL
    , p_suggested_container_item    =>   NULL
    , p_suggested_container_item_id =>   NULL
    , p_suggested_carton_name       =>   NULL
    , p_suggested_tolpn_id          =>   NULL
    , x_pick_to_lpn_id              =>   l_pick_to_lpn_id
    , p_inventory_item_id           =>   p_item_id
    , p_confirmed_sub               =>   p_confirmed_sub
    , p_confirmed_loc_id            =>   p_confirmed_locator
    , p_revision                    =>   p_rev
    , p_confirmed_lots              =>   l_lot_v
    , p_from_lpn_id                 =>   NULL
    , p_lot_control                 =>   l_is_lot_control
    , p_revision_control            =>   l_is_revision_control
    , p_serial_control              =>   l_is_serial_control
    -- Bug 4632519
    , p_trx_type_id                 =>   to_char(p_transaction_type_id)
    , p_trx_action_id               =>   to_char(p_transaction_action_id)
    -- Bug 4632519
   );


   If x_return_status <> fnd_api.g_ret_sts_success THEN
       x_toLPN_status := 'F';
     IF (l_debug = 1) THEN
      mydebug('Validate_pick_to_lpn could not validate toLPNDefault:');
     END IF;
     x_return_status := fnd_api.g_ret_sts_success;
   Else
    x_toLPN_status := 'T';
    IF (l_debug = 1) THEN
      mydebug('Validate_pick_to_lpn  validated  toLPNDefault:');
     END IF;
  End If;

 END IF;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
          IF (l_debug = 1) THEN
            mydebug('Exception raised');
          END IF;

          x_return_status  := fnd_api.g_ret_sts_error;
          fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            mydebug('Other exception raised : ' || SQLERRM);
          END IF;

          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END LOOSE_MATCH;


FUNCTION can_pickdrop(p_transaction_temp_id IN NUMBER) RETURN VARCHAR2 IS
      l_ret       VARCHAR2(10) := 'PASS';
      l_debug     NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    CURSOR c_cancelled_tasks IS
        --SELECT decode(mmtt.transaction_type_id, 35,'N',51,'N','Y')
        SELECT 'FAIL'
          FROM mtl_material_transactions_temp mmtt, mtl_txn_request_lines mol
         WHERE mmtt.transaction_temp_id = p_transaction_temp_id
           AND mmtt.move_order_line_id = mol.line_id
           AND mol.line_status = inv_globals.g_to_status_cancel_by_source
           AND ROWNUM = 1;
BEGIN
   g_debug := l_debug;
   mydebug('In CAN_PICKDROP for Transaction Temp ID = ' || p_transaction_temp_id);

   OPEN c_cancelled_tasks;
      FETCH c_cancelled_tasks INTO l_ret;
      IF c_cancelled_tasks%NOTFOUND THEN
          mydebug('Found no Cancelled Task' );
      ELSE
          mydebug('Found Cancelled Tasks');
      END IF;
   CLOSE c_cancelled_tasks;
   mydebug('l_ret : ' || l_ret);
   RETURN l_ret;
END  can_pickdrop;


PROCEDURE check_pack_lpn
    ( p_lpn                IN             VARCHAR2
    , p_org_id             IN             NUMBER
    , p_container_item_id  IN             NUMBER
    , p_temp_id            IN             NUMBER --Bug7120019
    , x_lpn_id        OUT NOCOPY          NUMBER
    , x_lpn_context   OUT NOCOPY          NUMBER
    , x_outermost_lpn_id   OUT NOCOPY     NUMBER
    , x_pick_to_lpn_exists OUT NOCOPY     BOOLEAN
    , x_return_status OUT NOCOPY    VARCHAR2
    , x_msg_count     OUT NOCOPY    NUMBER
    , x_msg_data      OUT NOCOPY    VARCHAR2
    ) IS
      lpn_cont        NUMBER         := 0;
      create_lpn      VARCHAR2(1)    := 'N';
      l_return_status VARCHAR2(1);
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(4000);
      l_exist         NUMBER;
      p_lpn_id        NUMBER;
      l_org_id        NUMBER;
      l_locator_id    NUMBER;
      l_debug         NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
      honor_case_pick_count NUMBER   := 0; --Bug7120019
      l_CursorStmt          VARCHAR2(32000);
      l_CursorID            INTEGER;
      l_Dummy               INTEGER;

    BEGIN
      IF (l_debug = 1) THEN
        mydebug('check_pack_lpn: check_pack_lpn begins');
      END IF;

      l_return_status  := fnd_api.g_ret_sts_success;

      IF ((p_lpn IS NULL)
          OR(p_lpn = '')) THEN
        x_return_status  := fnd_api.g_ret_sts_success;
        RETURN;
      END IF;

      BEGIN
        SELECT lpn_context
             , organization_id
             , locator_id
             , lpn_id
             , outermost_lpn_id
          INTO lpn_cont
             , l_org_id
             , l_locator_id
             , x_lpn_id
             , x_outermost_lpn_id
          FROM wms_license_plate_numbers
         WHERE license_plate_number = p_lpn;
         x_pick_to_lpn_exists := TRUE;
         x_lpn_context := lpn_cont;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          create_lpn  := 'Y';
          x_pick_to_lpn_exists := FALSE;
      END;

      IF (create_lpn = 'N'
         AND (l_org_id is not null and l_org_id <> p_org_id)
            ) THEN
           IF (l_debug = 1) THEN
             mydebug('check_pack_lpn: LPN already exists but with different context or Org');
	     END IF;--bug9165521
	     fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_ORG');
             fnd_msg_pub.ADD;


           x_return_status  := fnd_api.g_ret_sts_error;
           RETURN;
      END IF;

      --Bug7120019
      IF wms_control.g_current_release_level >= 120001 THEN
         l_CursorStmt := 'SELECT count (*) FROM mtl_material_transactions_temp mmtt, wms_user_task_type_attributes wutta '||
                         'WHERE mmtt.transaction_temp_id = :x_temp_id ' ||
                         ' AND mmtt.standard_operation_id = wutta.user_task_type_id '||
                         ' AND mmtt.organization_id = wutta.organization_id '||
                         ' AND wutta.honor_case_pick_flag = ''Y'' ';  --Added for Bug#7584906
         l_CursorID := DBMS_SQL.OPEN_CURSOR;
         DBMS_SQL.PARSE(l_CursorID, l_CursorStmt, DBMS_SQL.V7);
         DBMS_SQL.DEFINE_COLUMN(l_CursorID, 1, honor_case_pick_count);
         DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_temp_id', p_temp_id);
         l_Dummy := DBMS_SQL.EXECUTE(l_CursorID);
         l_Dummy := DBMS_SQL.FETCH_ROWS(l_CursorID);
         DBMS_SQL.COLUMN_VALUE(l_CursorID, 1, honor_case_pick_count);
         DBMS_SQL.CLOSE_CURSOR(l_CursorID);
      END IF;

      IF (create_lpn = 'N') THEN
        IF (wms_control.g_current_release_level >= 120001 AND honor_case_pick_count > 0) THEN
          IF (
               lpn_cont = wms_container_pub.lpn_context_wip
               OR lpn_cont = wms_container_pub.lpn_context_rcv
               OR lpn_cont = wms_container_pub.lpn_context_stores
               OR lpn_cont = wms_container_pub.lpn_context_intransit
               OR lpn_cont = wms_container_pub.lpn_context_vendor
               OR lpn_cont = wms_container_pub.lpn_loaded_for_shipment
               OR lpn_cont = wms_container_pub.lpn_prepack_for_wip
               OR lpn_cont = wms_container_pub.lpn_context_picked
               OR lpn_cont = wms_container_pub.LPN_CONTEXT_INV
	       OR lpn_cont = wms_container_pub.LPN_CONTEXT_PACKING
              ) THEN
              --OR (l_org_id is not null and l_org_id <> p_org_id)

             IF (l_debug = 1) THEN
               mydebug('check_pack_lpn: LPN already exists but with different context or Org');
	       END IF;--bug9165521
	       fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_CONTEXT');
               fnd_msg_pub.ADD;


             x_return_status  := fnd_api.g_ret_sts_error;
             RETURN;
          END IF;

	ELSE -- Not Honor Case Pick
          IF (
               lpn_cont = wms_container_pub.lpn_context_wip
               OR lpn_cont = wms_container_pub.lpn_context_rcv
               OR lpn_cont = wms_container_pub.lpn_context_stores
               OR lpn_cont = wms_container_pub.lpn_context_intransit
               OR lpn_cont = wms_container_pub.lpn_context_vendor
               OR lpn_cont = wms_container_pub.lpn_loaded_for_shipment
               OR lpn_cont = wms_container_pub.lpn_prepack_for_wip
               OR lpn_cont = wms_container_pub.lpn_context_picked
               OR lpn_cont = wms_container_pub.LPN_CONTEXT_INV
              ) THEN

              IF (l_debug = 1) THEN
              mydebug('check_pack_lpn: LPN already exists but with different context or Org');
	      END IF;--bug9165521
	      fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_CONTEXT');
              fnd_msg_pub.ADD;


              x_return_status  := fnd_api.g_ret_sts_error;
              RETURN;
           END IF;
         END IF;
       END IF; --Bug7120019

      IF create_lpn = 'Y' THEN
        IF (l_debug = 1) THEN
          mydebug('check_pack_lpn: calling wms_container_pub.create_lpn');
        END IF;

        wms_container_pub.create_lpn
        ( p_api_version                => 1.0
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => x_msg_data
        , p_lpn                        => p_lpn
        , p_organization_id            => p_org_id
        , p_container_item_id          => p_container_item_id
        , x_lpn_id                     => x_lpn_id
        , p_source                     => 5
        );

        IF (l_msg_count = 0) THEN
          IF (l_debug = 1) THEN
            mydebug('check_pack_lpn: Successful');
          END IF;
        ELSIF(l_msg_count = 1) THEN
          IF (l_debug = 1) THEN
            mydebug('check_pack_lpn: Not Successful');
            mydebug(REPLACE(x_msg_data, fnd_global.local_chr(0), ' '));
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('check_pack_lpn: Not Successful2');
          END IF;

          FOR i IN 1 .. l_msg_count LOOP
            x_msg_data  := fnd_msg_pub.get(i, 'F');

            IF (l_debug = 1) THEN
              mydebug(REPLACE(x_msg_data, fnd_global.local_chr(0), ' '));
            END IF;
          END LOOP;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error
           OR l_return_status = fnd_api.g_ret_sts_error THEN
           fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
           fnd_msg_pub.ADD;
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;

      IF (l_debug = 1) THEN
        mydebug('check_pack_lpn: check_pack_lpn ends');
      END IF;
    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        IF DBMS_SQL.IS_Open(l_cursorID) THEN
         DBMS_SQL.Close_Cursor(l_cursorID);
        END IF;
      WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	 IF DBMS_SQL.IS_Open(l_cursorID) THEN
         DBMS_SQL.Close_Cursor(l_cursorID);
        END IF;
END check_pack_lpn;


PROCEDURE validate_pick_to_lpn
    ( p_api_version_number          IN            NUMBER
    , p_init_msg_lst                IN            VARCHAR2
    , x_return_status               OUT NOCOPY    VARCHAR2
    , x_msg_count                   OUT NOCOPY    NUMBER
    , x_msg_data                    OUT NOCOPY    VARCHAR2
    , p_organization_id             IN            NUMBER
    , p_pick_to_lpn                 IN            VARCHAR2   --New LPN
    , p_temp_id                     IN            NUMBER
    , p_project_id                  IN            NUMBER
    , p_task_id                     IN            NUMBER
    , p_container_item              IN            VARCHAR2
    , p_container_item_id           IN            NUMBER
    , p_suggested_container_item    IN            VARCHAR2
    , p_suggested_container_item_id IN            NUMBER
    , p_suggested_carton_name       IN            VARCHAR2
    , p_suggested_tolpn_id          IN            NUMBER
    , x_pick_to_lpn_id              OUT NOCOPY    NUMBER
    , p_inventory_item_id           IN            NUMBER
    , p_confirmed_sub               IN            VARCHAR2
    , p_confirmed_loc_id            IN            NUMBER
    , p_revision                    IN            VARCHAR2
    , p_confirmed_lots              IN            VARCHAR2
    , p_from_lpn_id                 IN            NUMBER
    , p_lot_control                 IN            VARCHAR2
    , p_revision_control            IN            VARCHAR2
    , p_serial_control              IN            VARCHAR2
    , p_trx_type_id                 IN            VARCHAR2 -- Bug 4632519
    , p_trx_action_id               IN            VARCHAR2 -- Bug 4632519
    ) IS

      l_api_version_number CONSTANT NUMBER                      := 1.0;
      l_api_name           CONSTANT VARCHAR2(30)                := 'validate_pick_to_lpn';
      l_pick_to_lpn_exists          BOOLEAN                     := FALSE;
      l_current_mmtt_delivery_id    NUMBER                      := NULL;
      l_pick_to_lpn_delivery_id     NUMBER                      := NULL;
      l_pick_to_lpn_delivery_id2    NUMBER                      := -999;
      l_outermost_lpn_id            NUMBER                      := NULL;

      --Added for PJM Integration
      l_project_id                  NUMBER                      := NULL;
      l_task_id                     NUMBER                      := NULL;

      -- ********************* Start of bug fix 2078002 ********************
      l_mmtt_mo_type                NUMBER                      := NULL;
      l_mo_type_in_lpn              NUMBER                      := NULL;
      l_mmtt_wip_entity_type        NUMBER;
      l_mmtt_txn_type_id            NUMBER;
      l_wip_entity_type_in_lpn      NUMBER;
      -- ********************* End of bug fix 2078002 ********************

      l_xfr_sub                     VARCHAR2(30);
      l_xfr_to_location             NUMBER;
      l_lpn_controlled_flag         NUMBER;
      l_count                       NUMBER                      := 0;
      l_item_id                     NUMBER;
      l_operation_plan_id           NUMBER;
      l_current_carton_grouping_id  NUMBER                      := -999;
      l_carton_grouping_id          NUMBER                      := -999;
      l_parent_line_id              NUMBER;
      l_transaction_header_id       NUMBER;
      l_multiple_pick               VARCHAR2(1);
      l_bulk_task_exist             VARCHAR2(1);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      l_lot_number                  VARCHAR2(80) := null;
      l_debug                       NUMBER                      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
      --************added for cartonized check******************
      l_container_item_id           NUMBER;
      l_concatenated_segments       VARCHAR2(40);
      --***
      l_lot_control                 NUMBER  := 1;
      l_revision_control            NUMBER  := 1;
      l_commingle_exist             VARCHAR2(1);

      -- the delimiter for lot string
      l_delimiter                   VARCHAR2(30)   :=  ':';
         -- To parse lots
      m                             NUMBER := 1;  -- position of delimiter
      n                             NUMBER := 1;  -- Start position for substr or
      --
      -- Bug 4454837,this change will be removed after discussion
      /*
      l_line_rows                   WSH_UTIL_CORE.id_tab_type;
      l_grouping_rows               WSH_UTIL_CORE.id_tab_type;
      l_same_carton_grouping        BOOLEAN := FALSE;
      l_return_status               VARCHAR2(2) ;
      --
      */

      --Bug 6168447-Start
      l_lpn_name VARCHAR2(30);
      l_status_code VARCHAR2(1);
      l_delivery_id NUMBER;
      l_delivery_detail_id number;
      l_wsh_dd_upd_rec  WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
      wsh_update_tbl  WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type;
      l_IN_rec        WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
      l_OUT_rec       WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;
      --Bug 6168447-End

      TYPE lpn_rectype IS RECORD
      ( lpn_id           wms_license_plate_numbers.lpn_id%TYPE
      , lpn_context      wms_license_plate_numbers.lpn_context%TYPE
      , outermost_lpn_id wms_license_plate_numbers.outermost_lpn_id%TYPE
      );

      pick_to_lpn_rec               lpn_rectype;

      TYPE pjm_rectype IS RECORD
      ( prj_id mtl_item_locations.project_id%TYPE
      , tsk_id mtl_item_locations.task_id%TYPE
      );

      mtl_pjm_prj_tsk_rec           pjm_rectype;
      lpn_pjm_prj_tsk_rec           pjm_rectype;

      CURSOR others_in_mmtt_delivery_cursor(l_lpn_id IN NUMBER) IS
        SELECT wda.delivery_id
          FROM wsh_delivery_assignments_v        wda
             , wsh_delivery_details_ob_grp_v   wdd
             , mtl_material_transactions_temp  mmtt
         WHERE mmtt.transfer_lpn_id   = l_lpn_id
           AND wda.delivery_detail_id = wdd.delivery_detail_id
           AND wdd.move_order_line_id = mmtt.move_order_line_id
           AND wdd.organization_id    = mmtt.organization_id;
           --AND wdd.released_status    = 'X';  -- For LPN reusability ER : 6845650 Commented for Bug#7430264

      CURSOR child_lpns_cursor(l_lpn_id IN NUMBER) IS
        SELECT lpn_id
        FROM   wms_license_plate_numbers
        START  WITH lpn_id = l_lpn_id
        CONNECT BY parent_lpn_id = PRIOR lpn_id;

      child_lpns_rec  child_lpns_cursor%ROWTYPE;

      CURSOR current_delivery_cursor IS
        SELECT wda.delivery_id
          FROM wsh_delivery_assignments_v        wda
             , wsh_delivery_details_ob_grp_v   wdd
             , mtl_material_transactions_temp  mmtt
         WHERE wda.delivery_detail_id   = wdd.delivery_detail_id
           AND wdd.move_order_line_id   = mmtt.move_order_line_id
           AND wdd.organization_id      = mmtt.organization_id
           AND mmtt.transaction_temp_id = p_temp_id
           AND mmtt.organization_id     = p_organization_id;

      CURSOR drop_delivery_cursor(l_lpn_id IN NUMBER) IS
        SELECT wda.delivery_id
          FROM wsh_delivery_assignments_v       wda
             , wsh_delivery_details_ob_grp_v  wdd
         WHERE wda.parent_delivery_detail_id = wdd.delivery_detail_id
           AND wdd.lpn_id = l_lpn_id
           AND wdd.organization_id = p_organization_id
           AND wdd.released_status = 'X';  -- For LPN reusability ER : 6845650

      --
      -- This cursor gets the project and task id for the lpn to be
      -- loaded into
      --
      CURSOR lpn_project_task_cursor(p_pick_to_lpn_id NUMBER) IS
        SELECT NVL(mil.project_id, -1)
             , NVL(mil.task_id, -1)
          FROM mtl_item_locations mil, mtl_material_transactions_temp mmtt
         WHERE mil.inventory_location_id = mmtt.transfer_to_location
           AND mil.organization_id       = mmtt.organization_id
           AND mmtt.transfer_lpn_id      = p_pick_to_lpn_id
           AND mmtt.organization_id      = p_organization_id;

      --
      -- This cursor gets the project and task id of the task that is about
      -- to be packed
      --
      CURSOR mtl_project_task_cursor IS
        SELECT NVL(mil.project_id, -1)
             , NVL(mil.task_id, -1)
          FROM mtl_item_locations mil, mtl_material_transactions_temp mmtt
         WHERE mil.inventory_location_id = mmtt.transfer_to_location
           AND mil.organization_id       = mmtt.organization_id
           AND mmtt.organization_id      = p_organization_id
           AND mmtt.transaction_temp_id  = p_temp_id;

      CURSOR current_carton_grouping_cursor IS
        SELECT mol.carton_grouping_id
          FROM mtl_txn_request_lines mol, mtl_material_transactions_temp mmtt
         WHERE mmtt.transaction_temp_id = p_temp_id
           AND mmtt.organization_id     = mol.organization_id
           AND mmtt.move_order_line_id  = mol.line_id;

      CURSOR others_carton_grouping_cursor(p_lpn_id IN NUMBER) IS
        SELECT DISTINCT mol.carton_grouping_id
                   FROM mtl_txn_request_lines mol, mtl_material_transactions_temp mmtt
                  WHERE mmtt.transfer_lpn_id = p_lpn_id
                    AND mmtt.organization_id = mol.organization_id
                    AND mmtt.move_order_line_id = mol.line_id;

      -- Bug 6168447 : Cursot to check if there are any wdd present for the LPN

      CURSOR c_wdd_exists(p_lpn_id NUMBER,p_organization_id NUMBER) is
      SELECT distinct wda.delivery_id
      FROM wsh_delivery_details wdd, wsh_delivery_assignments wda
      WHERE wdd.lpn_id IN (select lpn_id from wms_license_plate_numbers
                        where organization_id = p_organization_id
                        and (lpn_id = p_lpn_id
                        or parent_lpn_id = p_lpn_id
                        or outermost_lpn_id = p_lpn_id))
      AND wda.parent_delivery_detail_id = wdd.delivery_detail_id
      AND wdd.released_status = 'X';  -- For LPN reusability ER : 6845650

    BEGIN


      IF (l_debug = 1) THEN
         mydebug('validate_pick_to_lpn: Start Validate_pick_to_lpn.');
      END IF;

      --
      -- Standard call to check for call compatibility
      --
      IF NOT fnd_api.compatible_api_call(l_api_version_number, p_api_version_number, l_api_name, g_pkg_name) THEN
         fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      --  Initialize message list.
      --
      IF fnd_api.to_boolean(p_init_msg_lst) THEN
         fnd_msg_pub.initialize;
      END IF;

      --
      -- Initialize API return status to success
      --
      x_return_status        := fnd_api.g_ret_sts_success;

      --
      -- Begin validation process:
      -- Check if drop lpn exists by trying to retrieve its lpn ID.
      -- If it does not exist, no further validations required
      -- so return success.
      --
      -- jali changed the following: If the LPN doesn't exists then create the LPN.
      -- this will resolve the issue why the key in LPN name is not working
      -- also the following change will only query the WLPN once.
      IF (p_container_item_id = -1 OR p_container_item_id = 0) THEN -- no cartonization --Bug 8810402
          l_container_item_id := NULL;
      ELSE
          l_container_item_id := p_container_item_id;
      END IF;

       check_pack_lpn
      ( p_lpn                => p_pick_to_lpn
      , p_org_id             => p_organization_id
      , p_container_item_id  => l_container_item_id    --new IN parameter
      , p_temp_id            => p_temp_id              --Bug7120019
      , x_lpn_id             => pick_to_lpn_rec.lpn_id
      , x_lpn_context        => pick_to_lpn_rec.lpn_context
      , x_outermost_lpn_id   => pick_to_lpn_rec.outermost_lpn_id
      , x_pick_to_lpn_exists => l_pick_to_lpn_exists
      , x_return_status      => x_return_status
      , x_msg_count          => x_msg_count
      , x_msg_data           => x_msg_data
      );

      IF x_return_status = fnd_api.g_ret_sts_unexp_error
         OR x_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      x_pick_to_lpn_id := pick_to_lpn_rec.lpn_id;

      IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn:x_pick_to_lpn_id:'||x_pick_to_lpn_id);
      END IF;

      IF NOT l_pick_to_lpn_exists THEN
         IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: Drop LPN is a new LPN, no checking required.');
         END IF;
         RETURN;
      --Bug 6168477 -start : Added the following ELSIF condition.
      ELSIF pick_to_lpn_rec.lpn_context = wms_container_pub.lpn_context_pregenerated THEN
         IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: Drop LPN is in context 5,check if associated records are presetn in WDD.');
	      END IF;
         OPEN c_wdd_exists(pick_to_lpn_rec.lpn_id,p_organization_id);
         FETCH c_wdd_exists into l_delivery_id;
         IF c_wdd_exists%NOTFOUND THEN
            CLOSE c_wdd_exists;
         ELSE
 	      IF (l_delivery_id IS NOT NULL )THEN
                   BEGIN
                           SELECT wlpn.LICENSE_PLATE_NUMBER
                           INTO l_lpn_name
                           FROM Wms_License_Plate_Numbers wlpn
                           WHERE organization_id = p_organization_id
                           and (lpn_id = pick_to_lpn_rec.lpn_id
                           or parent_lpn_id = pick_to_lpn_rec.lpn_id
                           or outermost_lpn_id = pick_to_lpn_rec.lpn_id);

                           SELECT wdd.released_status,wdd.delivery_detail_id
                           INTO l_status_code,l_delivery_detail_id
                           FROM wsh_delivery_details_ob_grp_v wdd
	                        WHERE wdd.container_name = l_lpn_name
                           AND wdd.released_status = 'X';      -- For LPN reusability ER : 6845650

			   /* Release 12(K): LPN Synchronization
			   1. Uniqueness constraint on WDD.container_name is removed
			      So it is not required to append characters to the LPNs
			      to get a new containers name
			   2. Replace API call to wsh_container_grp.update_container
			      with new API call WSH_WMS_LPN_GRP.Create_Update_Containers
			   */

			   IF l_status_code = 'C' THEN

			      l_wsh_dd_upd_rec.delivery_detail_id := l_delivery_detail_id;
			      l_wsh_dd_upd_rec.lpn_id := pick_to_lpn_rec.lpn_id;

			      wsh_update_tbl(1) := l_wsh_dd_upd_rec;

			      l_IN_rec.caller      := 'WMS';
			      l_IN_rec.action_code := 'UPDATE_NULL';

			      WSH_WMS_LPN_GRP.Create_Update_Containers (
			          p_api_version     => 1.0
			        , p_init_msg_list   => fnd_api.g_false
			        , p_commit          => fnd_api.g_false
			        , x_return_status   => x_return_status
			        , x_msg_count       => x_msg_count
			        , x_msg_data        => x_msg_data
			        , p_detail_info_tab => wsh_update_tbl
			        , p_IN_rec          => l_IN_rec
			        , x_OUT_rec         => l_OUT_rec );

			     IF x_return_status = fnd_api.g_ret_sts_unexp_error
				OR x_return_status = fnd_api.g_ret_sts_error THEN
				RAISE fnd_api.g_exc_error;
			     END IF;
			   ELSE
                             fnd_message.set_name('WMS','WMS_INVALID_PACK_DELIVERY');
			     fnd_msg_pub.ADD;
	                     RAISE fnd_api.g_exc_error;
			   END IF;
		   END;
        	 CLOSE c_wdd_exists;
              END IF;
	 END IF;
         --6168477 End
      END IF;


      /******** check for cartonized task***************/
      IF (p_container_item is not NULL) THEN
         IF (l_debug = 1) THEN
                mydebug('validate_pick_to_lpn: p_container_item :'||p_container_item);
                mydebug('validate_pick_to_lpn: p_container_item_id :'||p_container_item_id);
                mydebug('validate_pick_to_lpn: p_suggested_container_item :'||p_suggested_container_item);
                mydebug('validate_pick_to_lpn: p_suggested_container_item_id :'||p_suggested_container_item_id);
                mydebug('validate_pick_to_lpn: p_pick_to_lpn--new LPN:'||p_pick_to_lpn);
                mydebug('validate_pick_to_lpn: p_suggested_carton_name--old LPN:'||p_suggested_carton_name);
                mydebug('validate_pick_to_lpn: p_suggested_tolpn_id--old LPN_id:'||p_suggested_tolpn_id);
         END IF;

         IF (p_pick_to_lpn <> p_suggested_carton_name) THEN
                IF (l_debug = 1) THEN
                    mydebug('tolpn changed from:'||p_suggested_carton_name||' to:'||p_pick_to_lpn);
                END IF;
                BEGIN
                     SELECT nvl(inventory_item_id, -999)
                       INTO l_container_item_id
                      FROM  wms_license_plate_numbers
                      WHERE license_plate_number = p_pick_to_lpn
                        AND organization_id = p_organization_id
                        AND lpn_context IN (wms_container_pub.lpn_context_packing, wms_container_pub.LPN_CONTEXT_PREGENERATED);
                EXCEPTION
                      WHEN no_data_found THEN
                      -- error out and assuming it should exist
                      -- tolpn doesn't existing or if existing, but has wrong context
                       fnd_message.set_name('WMS', 'WMS_LPN_NOT_FOUND');
                       fnd_msg_pub.ADD;
                       RAISE fnd_api.g_exc_error;
                END;
                IF (l_debug = 1) THEN
                      mydebug('l_container_item_id:'||l_container_item_id);
                END IF;
                IF (l_container_item_id = -999) THEN  --lpn does not use any container
                      IF (l_debug = 1) THEN
                           mydebug('LPN does not use any container');
                      END IF;
                      fnd_message.set_name('WMS', 'WMS_LPN_NOT_LINKTO_CONT');
                      fnd_message.set_token('LPN', p_pick_to_lpn );
                      fnd_msg_pub.ADD;
                      RAISE fnd_api.g_exc_error;
                ELSIF (l_container_item_id <> p_container_item_id) THEN
                     IF (l_debug = 1) THEN
                           mydebug('The container, with which LPN associated, is different from confirmed container');
                     END IF;
                     BEGIN
                          SELECT CONCATENATED_SEGMENTS
                            INTO  l_concatenated_segments
                            FROM  MTL_SYSTEM_ITEMS_KFV
                           WHERE  inventory_item_id = l_container_item_id
                             AND  organization_id = p_organization_id;
                     EXCEPTION
                          WHEN OTHERS THEN
                              l_concatenated_segments := '';
                     END;
                     fnd_message.set_name('WMS', 'WMS_LPN_ASSOC_WITH_CONT');
                     fnd_message.set_token('LPN', p_pick_to_lpn );
                     fnd_message.set_token('CONTAINER',  l_concatenated_segments);
                     fnd_msg_pub.ADD;
                     RAISE fnd_api.g_exc_error;
                END IF;
          ELSE
             IF (l_debug = 1) THEN
               mydebug('tolpn is not changed.');
             END IF;
             IF (p_container_item = p_suggested_container_item) THEN
                  IF (l_debug = 1) THEN
                      mydebug('Container is not changed. tolpn is not change, do nothing');
                  END IF;
             ELSE
                  IF (l_debug = 1) THEN
                      mydebug('Container changed. error out');
                  END IF;
                  fnd_message.set_name('WMS', 'WMS_LPN_ASSOC_WITH_CONT');
                  fnd_message.set_token('LPN', p_pick_to_lpn );
                  fnd_message.set_token('CONTAINER', p_suggested_container_item );
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_error;
             END IF;
         END IF;
    END IF;

     /********* end of checking for cartonized task ********/

    /* check for cost group commingle   */

     IF p_serial_control = 'N' THEN

         IF p_lot_control = 'Y' THEN
            l_lot_control := 2;
         ELSE l_lot_control := 1;
         END IF;

         IF p_revision_control = 'Y' THEN
            l_revision_control := 2;
         ELSE l_revision_control := 1;
         END IF;


         WHILE  ( n <> 0)
         LOOP
           IF p_lot_control = 'Y' THEN
             n := INSTR(p_confirmed_lots,l_delimiter,m,1);
             IF n = 0 THEN -- Last part OF the string
                 l_lot_number :=
                   substr(p_confirmed_lots,m,length(p_confirmed_lots));
             ELSE
                 l_lot_number :=  substr(p_confirmed_lots,m,n-m) ;
                          -- start at M get m-n chrs
                 m := n+1;
             END IF;
             mydebug ('l_lot_number:' || l_lot_number);
           ELSE
             n := 0;
             mydebug ('not lot controlled');
           END IF;

           validate_loaded_lpn_cg(
                  p_organization_id      => p_organization_id,
                  p_inventory_item_id    => p_inventory_item_id,
                  p_subinventory_code    => p_confirmed_sub,
                  p_locator_id           => p_confirmed_loc_id,
                  p_revision             => p_revision,
                  p_lot_number           => l_lot_number,
                  p_lpn_id               => p_from_lpn_id,
                  p_transfer_lpn_id      => x_pick_to_lpn_id,
                  p_lot_control          => l_lot_control, --IN  NUMBER,
                  p_revision_control     => l_revision_control, --IN  NUMBER,
                  x_commingle_exist      => l_commingle_exist,
                  x_return_status        => x_return_status,
                  p_trx_type_id          => p_trx_type_id,
                  p_trx_action_id        => p_trx_action_id);

          IF x_return_status = fnd_api.g_ret_sts_unexp_error
             OR x_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          END IF;

          IF l_commingle_exist = 'Y' THEN
                  IF (l_debug = 1) THEN
                      mydebug('Cost group commigle exist.');
                  END IF;
                  fnd_message.set_name('WMS', 'WMS_CG_COMMINGLE');
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_error;
          ELSE
                  IF (l_debug = 1) THEN
                      mydebug('passed cost group commigle check.');
                  END IF;
          END IF;
       END LOOP;

    END IF;
    /*end of check for cost group commingle   */


     --
     -- If the drop lpn was pre-generated, no validations required
     -- Changed the context to be updated to 8 instead of 1 as done earlier
     --
     /* Mrana: 12/10/03: we need not change the context in this API. We will do it at LOAD
 *     or Pick More . i.e. Task_load or Task_merge_split API  RESP.
 *     IF pick_to_lpn_rec.lpn_context = wms_container_pub.lpn_context_pregenerated THEN
        --
        -- Update the context to "Packing Context" (8)
        --
        UPDATE wms_license_plate_numbers
           SET lpn_context = wms_container_pub.lpn_context_packing
         WHERE lpn_id = pick_to_lpn_rec.lpn_id;

        IF (l_debug = 1) THEN
           mydebug('validate_pick_to_lpn: Drop LPN is pre-generated, no checking required.');
        END IF;

        RETURN;
      END IF; */


     /**********patchset J bulk picking                **********************/
      -- move the following query up to here, so that we can query the parent line id to see if
      -- it is bulk picking or not   -----
      /***********************************************************************/
      IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: patchset J bulk picking started');
      END IF;

      SELECT mmtt.transfer_subinventory
    , mmtt.transfer_to_location
    , mmtt.inventory_item_id
    , mmtt.operation_plan_id
    , nvl(mmtt.parent_line_id,-1)
    , mmtt.transaction_header_id
      INTO l_xfr_sub
    , l_xfr_to_location
    , l_item_id
    , l_operation_plan_id
    , l_parent_line_id
    , l_transaction_header_id
      FROM mtl_material_transactions_temp mmtt
      WHERE mmtt.transaction_temp_id = p_temp_id;

      IF (l_debug = 1) THEN
           mydebug('validate_pick_to_lpn: parent line id:'||l_parent_line_id);
      END IF;


      IF l_parent_line_id = p_temp_id THEN -- bulk picking task
                       -- check to see if this is for multiple pick of the same task or not
                       -- If yes, no problem, otherwise raise error
                       -- program can come to here which means the LPN is not pregenerated LPN
                       BEGIN
          select 'N'
          into l_multiple_pick
          from dual
          where exists (select 1
            from mtl_material_transactions_temp
            where transfer_lpn_id = pick_to_lpn_rec.lpn_id
       and transaction_header_id <>l_transaction_header_id);

          fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_NOT_NEW'); -- new message
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
          EXCEPTION
       WHEN NO_DATA_FOUND THEN RETURN; -- this lpn is fine and no need to do all
           -- the following checks
         END;
                    ELSE -- regular task but maybe the lpn has contains bulk tasks
                       BEGIN
                               select 'Y'
                               into l_bulk_task_exist
                               from dual
                               where exists (select 1
                                             from mtl_material_transactions_temp
                                             where transfer_lpn_id = pick_to_lpn_rec.lpn_id
                                             and transaction_temp_id = parent_line_id  -- bulk task
                                             );
                               fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_BULK');
                               fnd_msg_pub.ADD;
                               RAISE fnd_api.g_exc_error;
                               EXCEPTION
                                   WHEN NO_DATA_FOUND THEN null;
                       END;
      END IF;

      IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: patchset J bulk picking ended');
      END IF;

      /******** end of patchset J bulk picking  ***************************/


      --
      -- *********************Start of bug fix 2078002,2095080 ********************
      -- Check if the task that is about to pack into the LPN has the same
      -- move order type as the tasks already packed into the same LPN
      --
      SELECT mtrh.move_order_type
           , mmtt.transaction_type_id
           , mmtt.wip_entity_type
        INTO l_mmtt_mo_type
           , l_mmtt_txn_type_id
           , l_mmtt_wip_entity_type
        FROM mtl_txn_request_headers         mtrh
           , mtl_txn_request_lines           mtrl
           , mtl_material_transactions_temp  mmtt
       WHERE mtrh.header_id           = mtrl.header_id
         AND mtrl.line_id             = mmtt.move_order_line_id
         AND mmtt.transaction_temp_id = p_temp_id;

      BEGIN
         SELECT mtrh.move_order_type
              , mmtt.wip_entity_type
           INTO l_mo_type_in_lpn
              , l_wip_entity_type_in_lpn
           FROM mtl_txn_request_headers         mtrh
              , mtl_txn_request_lines           mtrl
              , mtl_material_transactions_temp  mmtt
          WHERE mtrh.header_id       = mtrl.header_id
            AND mtrl.line_id         = mmtt.move_order_line_id
            AND mmtt.transfer_lpn_id = pick_to_lpn_rec.lpn_id
            AND ROWNUM < 2;
      EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 l_mo_type_in_lpn := null;
      END;

      IF (l_mo_type_in_lpn is not null ) THEN
         IF l_mo_type_in_lpn <> l_mmtt_mo_type THEN
            IF (l_debug = 1) THEN
               mydebug('validate_pick_to_lpn: Picked LPN and current MMTT have different MO type.');
               mydebug('  p_temp_id => ' || p_temp_id);
               mydebug('  lpn_id => ' || pick_to_lpn_rec.lpn_id);
               mydebug('  l_mmtt_mo_type => ' || l_mmtt_mo_type);
               mydebug('  l_mo_type_in_lpn => ' || l_mo_type_in_lpn);
            END IF;
            fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_MO_TYPE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         ELSIF l_mmtt_txn_type_id = 35
               OR l_mmtt_txn_type_id = 51 THEN -- Mfg pick
               IF l_mmtt_wip_entity_type <> l_wip_entity_type_in_lpn THEN
                  IF (l_debug = 1) THEN
                     mydebug('validate_pick_to_lpn: This is a manufacturing component pick.');
                     mydebug('WIP entity type IS NOT the same AS that OF the old mmtt RECORD');
                  END IF;
                  fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_MFG_MODE');
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_error;
               END IF;
         END IF;
      END IF;
      -- *********************End of bug fix 2078002,2095080 ********************

      --
      -- Bug 2355453: Check to see if the LPN is already going to some other lpn
      -- controlled sub. In that case, do not allow material to be picked into
      -- this LPN
      --
      IF (l_debug = 1) THEN
         mydebug('validate_pick_to_lpn: Check to see if LPN is already going to some other sub/loc');
      END IF;

      /* moved up already
                      SELECT mmtt.transfer_subinventory
           , mmtt.transfer_to_location
           , mmtt.inventory_item_id
           , mmtt.operation_plan_id
        INTO l_xfr_sub
           , l_xfr_to_location
           , l_item_id
           , l_operation_plan_id
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id; */

      l_lpn_controlled_flag  := wms_globals.g_non_lpn_controlled_sub;

      IF l_xfr_sub IS NOT NULL THEN
         SELECT lpn_controlled_flag
           INTO l_lpn_controlled_flag
           FROM mtl_secondary_inventories
          WHERE organization_id = p_organization_id
            AND secondary_inventory_name = l_xfr_sub;
      END IF;

      IF l_xfr_sub IS NOT NULL
         AND l_lpn_controlled_flag = wms_globals.g_lpn_controlled_sub THEN
         IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: Transfer Sub is LPN Controlled');
         END IF;

         --
         -- Ensure that all remaining picks on the LPN are also for the same sub
         --
         l_count  := 0;

         BEGIN
            SELECT COUNT(*)
              INTO l_count
              FROM mtl_material_transactions_temp mmtt
             WHERE mmtt.transaction_temp_id <> p_temp_id
               AND mmtt.transfer_lpn_id = pick_to_lpn_rec.lpn_id
               AND ( NVL(mmtt.transfer_subinventory, 0) <> l_xfr_sub
                     OR
                     NVL(mmtt.transfer_to_location, 0)  <> l_xfr_to_location
                   );
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 l_count  := 0;
         END;

         IF l_count > 0 THEN
            IF (l_debug = 1) THEN
               mydebug('validate_pick_to_lpn: Drop LPN is going to an LPN controlled sub');
               mydebug('validate_pick_to_lpn: Cannot add picks not going to the same sub');
            END IF;

            fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_SUBINV');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         --
         -- Current temp ID has a NULL xfer sub (issue txn)
         -- or the xfer sub is non LPN-controlled.
         -- Ensure that no other picks on the same LPN are to
         -- LPN controlled subs
         --

         IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: Transfer Sub is non LPN Controlled or null.');
         END IF;

         l_count  := 0;
         BEGIN
            SELECT 1
              INTO l_count
              FROM DUAL
             WHERE EXISTS
                 ( SELECT 'x'
                     FROM mtl_material_transactions_temp  mmtt
                        , mtl_secondary_inventories       msi
                    WHERE mmtt.transaction_temp_id    <> p_temp_id
                      AND mmtt.transfer_lpn_id         = pick_to_lpn_rec.lpn_id
                      AND msi.organization_id          = p_organization_id
                      AND msi.secondary_inventory_name = mmtt.transfer_subinventory
                      AND msi.lpn_controlled_flag      = wms_globals.g_lpn_controlled_sub
                 );
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 l_count  := 0;
         END;

         IF l_count > 0 THEN
            IF (l_debug = 1) THEN
               mydebug('validate_pick_to_lpn: Drop LPN has pick(s) for an LPN-controlled sub');
            END IF;

            fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_SUBINV');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      --
      IF (l_debug = 1) THEN
         mydebug('validate_pick_to_lpn: Check to see if LPN is associated with material' ||
                 ' FOR a different operation plan');
      END IF;

      l_count := 0;
      BEGIN
        SELECT COUNT(1)
          INTO l_count
          FROM mtl_material_transactions_temp mmtt
         WHERE mmtt.transaction_temp_id <> p_temp_id
           AND mmtt.transfer_lpn_id      = pick_to_lpn_rec.lpn_id
           AND mmtt.operation_plan_id   <> l_operation_plan_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count := 0;
      END;

      IF l_count > 0 THEN
         IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: Drop LPN is associated with material FOR a different operation plan');
         END IF;

         fnd_message.set_name('WMS', 'WMS_INVLD_PICKTO_LPN_OPER_PLAN');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;


      --
      -- No further checks required if LPN contains manufacturing picks
      -- The checks after this are related to delivery ID and PJM orgs
      --
      -- actually no further checks if it is replenishment or others except pick wave
      IF l_mmtt_mo_type <> 3 THEN
         RETURN;
      END IF;

      -- Now check if the picked LPN
      -- belongs to delivery which is different from current delivery
      --
      OPEN current_delivery_cursor;

      LOOP
        FETCH current_delivery_cursor INTO l_current_mmtt_delivery_id;
        EXIT WHEN l_current_mmtt_delivery_id IS NOT NULL
              OR current_delivery_cursor%NOTFOUND;
      END LOOP;

      CLOSE current_delivery_cursor;

      IF (l_debug = 1) THEN
        mydebug('validate_pick_to_lpn: l_current_mmtt_delivery_id:' || l_current_mmtt_delivery_id);
      END IF;

      --
      -- If the current MMTT is not associated with a delivery yet
      -- then no further checking required, return success
      --
      IF l_current_mmtt_delivery_id IS NULL THEN
        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Current MMTT is not associated with a delivery');
        END IF;

        OPEN current_carton_grouping_cursor;
        FETCH current_carton_grouping_cursor INTO l_current_carton_grouping_id;
        CLOSE current_carton_grouping_cursor;

        IF (l_current_carton_grouping_id = -999) THEN
          IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: can NOT find move order line for current task');
          END IF;

          fnd_message.set_name('WMS', 'WMS_NO_MOL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_current_carton_grouping_id IS NOT NULL THEN -- found carton_grouping_id
          OPEN others_carton_grouping_cursor(pick_to_lpn_rec.lpn_id);

          LOOP
            FETCH others_carton_grouping_cursor INTO l_carton_grouping_id;
            EXIT WHEN l_current_carton_grouping_id = NVL(l_carton_grouping_id, 0)
                  OR others_carton_grouping_cursor%NOTFOUND;
          END LOOP;

          CLOSE others_carton_grouping_cursor;

          IF l_carton_grouping_id = -999 THEN -- it is the first task in the lpn
            mydebug('validate_pick_to_lpn: This is the first task for the lpn ' ||
                    'and the task without delivery, so ok..');
            RETURN;
          END IF;

          IF l_carton_grouping_id IS NOT NULL THEN
            IF l_carton_grouping_id = l_current_carton_grouping_id THEN --the same carton_grouping_id
              IF (l_debug = 1) THEN
                mydebug('validate_pick_to_lpn: found the task in lpn which has ' ||
                        'the same carton_grouping_id as current task');
              END IF;

              OPEN others_in_mmtt_delivery_cursor(pick_to_lpn_rec.lpn_id);
              l_pick_to_lpn_delivery_id  := -999;

              LOOP
                FETCH others_in_mmtt_delivery_cursor INTO l_pick_to_lpn_delivery_id;
                EXIT WHEN l_pick_to_lpn_delivery_id IS NULL
                      OR others_in_mmtt_delivery_cursor%NOTFOUND;
              END LOOP;

              CLOSE others_in_mmtt_delivery_cursor;

              IF l_pick_to_lpn_delivery_id = -999 THEN --there is mol, but no wdd or wda, raise error
                IF (l_debug = 1) THEN
                  mydebug('validate_pick_to_lpn: can NOT find either wdd or wda for tasks in the lpn');
                END IF;

                fnd_message.set_name('WMS', 'WMS_NO_WDD_WDA');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;

              IF l_pick_to_lpn_delivery_id IS NULL THEN
                IF (l_debug = 1) THEN
                  mydebug('validate_pick_to_lpn: found a task which has ' ||
                          'the same carton_grouping_id as current task, and also no delivery.');
                END IF;

                RETURN;
              ELSE
                IF (l_debug = 1) THEN
                  mydebug('validate_pick_to_lpn: other tasks in lpn have different deliveries');
                END IF;

                fnd_message.set_name('WMS', 'WMS_PICK_TO_LPN_DIFF_DELIV');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;
            ELSE -- they have different carton_grouping_id
              --{
              IF (l_debug = 1) THEN
                mydebug('validate_pick_to_lpn: other tasks in lpn have different carton grouping id');
              END IF;
              --
              -- Start : R12 Bug 4454837, this change will be removed
              --
              /*
              BEGIN
                --{
                SELECT wdd.delivery_detail_id INTO  l_line_rows(1)
                FROM wsh_delivery_details    wdd
                    , mtl_material_transactions_temp  mmtt
                WHERE mmtt.transaction_temp_id = p_temp_id
                AND wdd.move_order_line_id = mmtt.move_order_line_id
                AND wdd.organization_id    = mmtt.organization_id;
                --
                SELECT wdd.delivery_detail_id  INTO  l_line_rows(2)
                FROM wsh_delivery_details  wdd
                     , mtl_material_transactions_temp  mmtt
                WHERE mmtt.transfer_lpn_id   = pick_to_lpn_rec.lpn_id
                AND wdd.move_order_line_id = mmtt.move_order_line_id
                AND wdd.organization_id    = mmtt.organization_id
                AND rownum<2;
                --
                IF (l_debug = 1) THEN
                  mydebug('validate_pick_to_lpn: Before calling WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping() to decide if we can load into this LPN');
                  mydebug('Parameters : delivery_detail_id(1):'|| l_line_rows(1) ||' , delivery_detail_id(2) :'||l_line_rows(2));
                END IF;
                --
                -- call to the shipping API.
                --
                WSH_DELIVERY_DETAILS_GRP.Get_Carton_Grouping(
                           p_line_rows      => l_line_rows,
                           x_grouping_rows  => l_grouping_rows,
                           x_return_status  => l_return_status);
                --
                IF (l_return_status = FND_API.G_RET_STS_SUCCESS
                   AND l_grouping_rows (1) = l_grouping_rows(2) )  THEN
                     l_same_carton_grouping := TRUE;
                ELSE
                     l_same_carton_grouping := FALSE;
                END IF;
                --
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                 IF (l_debug = 1) THEN
                    mydebug('No Data found Exception raised when matching delivery grouping attributes');
                    l_same_carton_grouping := FALSE;
                 END IF;
                WHEN OTHERS THEN
                 IF (l_debug = 1) THEN
                   mydebug('Other Exception raised when matching for delivery grouping attributes');
                   l_same_carton_grouping := FALSE;
                 END IF;
                --}
              END;
              --
              IF (l_same_carton_grouping = FALSE) then  */
               fnd_message.set_name('WMS', 'WMS_DIFF_CARTON_GROUP');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
              /*END IF;
              --
              -- End : R12 bug 4454837.
              --} */
            END IF;
          ELSE -- some of carton_grouping_id is null
            IF (l_debug = 1) THEN
              mydebug('validate_pick_to_lpn: some of tasks in lpn have NULL carton_grouping_id');
            END IF;
            fnd_message.set_name('WMS', 'WMS_CARTON_GROUP_NULL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE --carton_grouping_id is null
          IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: carton_grouping_id of current task is null');
          END IF;
           --bug3481923 only fail if it is not requisition on repl mo
            if (l_mmtt_mo_type not in(1,2)) then
               fnd_message.set_name('WMS', 'WMS_CARTON_GROUP_NULL');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            end if;
        END IF;
      END IF;

      -- Check if picked LPN has been picked_to in previous tasks, tasks that
      -- are still IN MMTT and shipping tables do not have the drop lpn yet

      OPEN others_in_mmtt_delivery_cursor(pick_to_lpn_rec.lpn_id);

      LOOP
        FETCH others_in_mmtt_delivery_cursor INTO l_pick_to_lpn_delivery_id2;
        EXIT WHEN l_pick_to_lpn_delivery_id2 IS NOT NULL
              OR others_in_mmtt_delivery_cursor%NOTFOUND;
      END LOOP;

      CLOSE others_in_mmtt_delivery_cursor;

      IF (l_debug = 1) THEN
        mydebug('validate_pick_to_lpn: l_pick_to_lpn_delivery_id2' || l_pick_to_lpn_delivery_id2);
      END IF;

      mydebug('l_pick_to_lpn_delivery_id2 : '||l_pick_to_lpn_delivery_id2);
      mydebug('l_current_mmtt_delivery_id : '||l_current_mmtt_delivery_id);

      IF (l_pick_to_lpn_delivery_id2 IS NOT NULL) AND (l_pick_to_lpn_delivery_id2 <> -999)  THEN
        IF l_pick_to_lpn_delivery_id2 <> l_current_mmtt_delivery_id THEN
          IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: Picked LPN and current MMTT go to different deliveries.');
          END IF;

          fnd_message.set_name('WMS', 'WMS_PICK_TO_LPN_DIFF_DELIV');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSIF l_pick_to_lpn_delivery_id2 IS NULL THEN
        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Picked LPN does not have deliveries.');
        END IF;

        IF l_current_mmtt_delivery_id IS NOT NULL THEN
          IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: Current task has delivery.');
            mydebug('validate_pick_to_lpn: Picked LPN does not have delivery and current task has delivery.');
          END IF;

          fnd_message.set_name('WMS', 'WMS_PICK_TO_LPN_DIFF_DELIV');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSIF l_pick_to_lpn_delivery_id2 = -999 THEN
        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: LPN does not contain other tasks. This is the first task, so ok.');
        END IF;
      END IF;

      IF pick_to_lpn_rec.outermost_lpn_id IS NOT NULL THEN
        -- We need to check delivery for outermost lpn or drill down if needed
        l_outermost_lpn_id  := pick_to_lpn_rec.outermost_lpn_id;
      ELSE
        -- We need to check delivery for pick_to_lpn or drill down if needed
        l_outermost_lpn_id  := pick_to_lpn_rec.lpn_id;
      END IF;

      --
      -- Find the outermost LPN's delivery ID
      --
      OPEN drop_delivery_cursor(l_outermost_lpn_id);
      FETCH drop_delivery_cursor INTO l_pick_to_lpn_delivery_id;
      CLOSE drop_delivery_cursor;

      mydebug('l_pick_to_lpn_delivery_id : '||l_pick_to_lpn_delivery_id);
      mydebug('l_current_mmtt_delivery_id : '||l_current_mmtt_delivery_id);

      IF l_pick_to_lpn_delivery_id IS NOT NULL THEN
        IF l_pick_to_lpn_delivery_id <> l_current_mmtt_delivery_id THEN
          IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: Picked LPN and current MMTT go to different deliveries.');
          END IF;

          fnd_message.set_name('WMS', 'WMS_PICK_TO_LPN_DIFF_DELIV');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
            NULL;
        ELSE
          --
          -- Picked LPN and current MMTT are on the same delivery
          -- return success
          --
          IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: Picked LPN and current MMTT go to same delivery: ' ||
                     l_pick_to_lpn_delivery_id);
          END IF;

          RETURN;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: Drop LPN does not have a delivery ID, checking child LPNs');
        END IF;

        OPEN child_lpns_cursor(l_outermost_lpn_id);

        LOOP
          FETCH child_lpns_cursor INTO child_lpns_rec;
          EXIT WHEN child_lpns_cursor%NOTFOUND;

          IF child_lpns_cursor%FOUND THEN
            OPEN drop_delivery_cursor(child_lpns_rec.lpn_id);
            FETCH drop_delivery_cursor INTO l_pick_to_lpn_delivery_id;
            CLOSE drop_delivery_cursor;
          END IF;

          EXIT WHEN l_pick_to_lpn_delivery_id IS NOT NULL;
        END LOOP;

        CLOSE child_lpns_cursor;

        --
        -- If the child LPNs also don't have a delivery ID
        -- then ok to deposit
        --
        IF l_pick_to_lpn_delivery_id IS NOT NULL THEN
          IF l_pick_to_lpn_delivery_id <> l_current_mmtt_delivery_id THEN
            IF (l_debug = 1) THEN
              mydebug('validate_pick_to_lpn: LPNs are on diff deliveries.');
            END IF;

            fnd_message.set_name('WMS', 'WMS_PICK_TO_LPN_DIFF_DELIV');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          ELSE
            --
            -- Child LPN has the  delivery as the current MMTT, return success
            --
            IF (l_debug = 1) THEN
              mydebug('validate_pick_to_lpn: A child LPN is on the same delivery ' ||
                      'as that OF the CURRENT MMTT, return success.');
            END IF;

            RETURN;
          END IF;
        ELSE
          --
          -- No child LPNs have a delivery ID yet
          -- return success
          --
          IF (l_debug = 1) THEN
            mydebug('validate_pick_to_lpn: Child LPNs do not have a delivery ID either, return success.');
          END IF;

          RETURN;
        END IF;
      END IF;

      --
      -- Fetch the Project/Task id associated with the LPN passed
      --
      -- PJM Integration:
      -- Check if the task that is about to pack into the LPN has the same
      -- transfer project_id and task_id as the lpn to which it is going to
      -- be loaded into.
      -- If yes, proceed, else return
      --
      IF (p_project_id IS NOT NULL) THEN
        OPEN lpn_project_task_cursor( pick_to_lpn_rec.lpn_id);

        LOOP
          FETCH lpn_project_task_cursor INTO lpn_pjm_prj_tsk_rec;
          EXIT WHEN lpn_project_task_cursor%NOTFOUND;
          OPEN mtl_project_task_cursor;

          LOOP
            FETCH mtl_project_task_cursor INTO mtl_pjm_prj_tsk_rec;
            EXIT WHEN mtl_project_task_cursor%NOTFOUND;
            -- project and task both should be the same as
            IF ((mtl_pjm_prj_tsk_rec.prj_id <> lpn_pjm_prj_tsk_rec.prj_id)
                 OR (mtl_pjm_prj_tsk_rec.tsk_id <> lpn_pjm_prj_tsk_rec.tsk_id)) THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          END LOOP;

          CLOSE mtl_project_task_cursor;
        END LOOP;

        CLOSE lpn_project_task_cursor;
      END IF;
    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        --  Get message count and data
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: @' || x_msg_data || '@');
        END IF;

        IF others_in_mmtt_delivery_cursor%ISOPEN THEN
          CLOSE others_in_mmtt_delivery_cursor;
        END IF;

        IF child_lpns_cursor%ISOPEN THEN
          CLOSE child_lpns_cursor;
        END IF;

        IF current_delivery_cursor%ISOPEN THEN
          CLOSE current_delivery_cursor;
        END IF;

        IF drop_delivery_cursor%ISOPEN THEN
          CLOSE drop_delivery_cursor;
        END IF;

        IF lpn_project_task_cursor%ISOPEN THEN
          CLOSE lpn_project_task_cursor;
        END IF;

        IF mtl_project_task_cursor%ISOPEN THEN
          CLOSE mtl_project_task_cursor;
        END IF;

        IF current_carton_grouping_cursor%ISOPEN THEN
          CLOSE current_carton_grouping_cursor;
        END IF;

        IF others_carton_grouping_cursor%ISOPEN THEN
          CLOSE others_carton_grouping_cursor;
        END IF;
      WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

        IF others_in_mmtt_delivery_cursor%ISOPEN THEN
          CLOSE others_in_mmtt_delivery_cursor;
        END IF;

        IF child_lpns_cursor%ISOPEN THEN
          CLOSE child_lpns_cursor;
        END IF;

        IF current_delivery_cursor%ISOPEN THEN
          CLOSE current_delivery_cursor;
        END IF;

        IF drop_delivery_cursor%ISOPEN THEN
          CLOSE drop_delivery_cursor;
        END IF;

        IF lpn_project_task_cursor%ISOPEN THEN
          CLOSE lpn_project_task_cursor;
        END IF;

        IF mtl_project_task_cursor%ISOPEN THEN
          CLOSE mtl_project_task_cursor;
        END IF;

        IF current_carton_grouping_cursor%ISOPEN THEN
          CLOSE current_carton_grouping_cursor;
        END IF;

        IF others_carton_grouping_cursor%ISOPEN THEN
          CLOSE others_carton_grouping_cursor;
        END IF;

        IF (l_debug = 1) THEN
          mydebug('validate_pick_to_lpn: @' || x_msg_data || '@');
        END IF;
  END validate_pick_to_lpn;


PROCEDURE validate_sub_loc_status(
      p_wms_installed    IN            VARCHAR2
    , p_temp_id          IN            NUMBER
    , p_confirmed_sub    IN            VARCHAR2
    , p_confirmed_loc_id IN            NUMBER
    , x_return_status    OUT NOCOPY    VARCHAR2
    , x_msg_count        OUT NOCOPY    NUMBER
    , x_msg_data         OUT NOCOPY    VARCHAR2
    , x_result           OUT NOCOPY    NUMBER
    ) IS
      l_transaction_type_id NUMBER;
      l_org_id              NUMBER;
      l_item_id             NUMBER;
      l_debug               NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    BEGIN
      IF (l_debug = 1) THEN
        mydebug('validate_sub_loc_status: validate_sub_loc_status begins');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;

      SELECT mmtt.transaction_type_id
           , mmtt.organization_id
           , mmtt.inventory_item_id
        INTO l_transaction_type_id
           , l_org_id
           , l_item_id
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_temp_id;

      IF inv_material_status_grp.is_status_applicable(
           p_wms_installed              => p_wms_installed
         , p_trx_status_enabled         => NULL
         , p_trx_type_id                => l_transaction_type_id
         , p_lot_status_enabled         => NULL
         , p_serial_status_enabled      => NULL
         , p_organization_id            => l_org_id
         , p_inventory_item_id          => l_item_id
         , p_sub_code                   => p_confirmed_sub
         , p_locator_id                 => p_confirmed_loc_id
         , p_lot_number                 => NULL
         , p_serial_number              => NULL
         , p_object_type                => 'Z'
         ) = 'Y'
         AND inv_material_status_grp.is_status_applicable(
              p_wms_installed              => p_wms_installed
            , p_trx_status_enabled         => NULL
            , p_trx_type_id                => l_transaction_type_id
            , p_lot_status_enabled         => NULL
            , p_serial_status_enabled      => NULL
            , p_organization_id            => l_org_id
            , p_inventory_item_id          => l_item_id
            , p_sub_code                   => p_confirmed_sub
            , p_locator_id                 => p_confirmed_loc_id
            , p_lot_number                 => NULL
            , p_serial_number              => NULL
            , p_object_type                => 'L'
            ) = 'Y' THEN
        x_result  := 1;

        IF (l_debug = 1) THEN
          mydebug('validate_sub_loc_status: Material status is correct. x_result = 1');
        END IF;
      ELSE
        x_result  := 0;

        IF (l_debug = 1) THEN
          mydebug('validate_sub_loc_status: Material status is incorrect. x_result = 0');
        END IF;
      END IF;

      IF (l_debug = 1) THEN
        mydebug('validate_sub_loc_status: End of validate_sub_loc_status');
      END IF;
    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        x_return_status  := fnd_api.g_ret_sts_error;

        IF (l_debug = 1) THEN
          mydebug('validate_sub_loc_status: Error - ' || SQLERRM);
        END IF;

        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;

        IF (l_debug = 1) THEN
          mydebug('validate_sub_loc_status: Unexpected Error - ' || SQLERRM);
        END IF;

        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
END validate_sub_loc_status;

PROCEDURE insert_serial(
    p_serial_transaction_temp_id IN OUT NOCOPY NUMBER,
    p_organization_id            IN     NUMBER,
    p_item_id                    IN     NUMBER,
    p_revision                   IN     VARCHAR2,
    p_lot                        IN     VARCHAR2,
    p_transaction_temp_id        IN     NUMBER,
    p_created_by                 IN     NUMBER,
    p_from_serial                IN     VARCHAR2,
    p_to_serial                  IN     VARCHAR2,
    p_status_id                  IN     NUMBER := NULL,
    x_return_status              OUT    NOCOPY VARCHAR2,
    x_msg_data                   OUT    NOCOPY VARCHAR2
  ) IS

      PRAGMA AUTONOMOUS_TRANSACTION;

      l_return    NUMBER;
      l_to_serial VARCHAR2(30);
      l_progress  VARCHAR2(10);
      l_msg_count NUMBER;
      l_success   NUMBER := 0;
      l_count     NUMBER := 0;
      l_temp_qty  NUMBER :=0 ;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
      x_return_status  := fnd_api.g_ret_sts_success;
      l_progress       := '10';
      IF (l_debug = 1) THEN
         mydebug('Enter insert_serial: 10:'|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
      --SAVEPOINT rcv_insert_serial_sp;
      l_to_serial      := p_to_serial;
      l_return :=2;


      l_progress := '20';
      l_count := 0;
      BEGIN
             SELECT 1
             INTO l_count
             FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt,
                  mtl_material_transactions_temp mmtt
             WHERE (p_from_serial BETWEEN msnt.fm_serial_number AND msnt.to_serial_number
                OR p_to_serial BETWEEN msnt.fm_serial_number AND msnt.to_serial_number)
               AND mmtt.inventory_item_id = p_item_id
               AND mmtt.organization_id = p_organization_id
               AND mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
               AND msnt.transaction_temp_id = nvl(mtlt.serial_transaction_temp_id, mmtt.transaction_temp_id);
      EXCEPTION
           WHEN OTHERS THEN
            l_count := 0;
      END;

      IF l_count <> 0 THEN
            fnd_message.set_name('INV', 'INVALID_SERIAL_NUMBER');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
      END IF;

      l_progress       := '30';

      IF p_serial_transaction_temp_id IS NULL THEN
         l_progress  := '40';

         SELECT serial_transaction_temp_id
           INTO p_serial_transaction_temp_id
           FROM mtl_transaction_lots_temp
          WHERE transaction_temp_id = p_transaction_temp_id
            AND lot_number= p_lot;

         IF p_serial_transaction_temp_id IS NULL THEN

              SELECT mtl_material_transactions_s.NEXTVAL
                INTO p_serial_transaction_temp_id
                FROM DUAL;

              l_progress  := '50';

              UPDATE mtl_transaction_lots_temp
                 SET serial_transaction_temp_id = p_serial_transaction_temp_id
               WHERE transaction_temp_id = p_transaction_temp_id
                 AND lot_number= p_lot;

         END IF;

      END IF;

       l_progress       := '60';
       l_return         := inv_trx_util_pub.insert_ser_trx(
                             p_trx_tmp_id => p_serial_transaction_temp_id,
                             p_user_id    => p_created_by,
                             p_fm_ser_num => p_from_serial,
                             p_to_ser_num => p_to_serial,
                             p_status_id  => p_status_id,
                             x_proc_msg   => x_msg_data
                           );
       l_progress       := '70';

       BEGIN
         UPDATE mtl_serial_numbers
            SET group_mark_id = p_serial_transaction_temp_id
          WHERE inventory_item_id = p_item_id
            AND serial_number BETWEEN p_from_serial AND p_to_serial
            AND LENGTH(serial_number) = LENGTH(p_from_serial);
       EXCEPTION
         WHEN OTHERS THEN
           IF (l_debug = 1) THEN
              mydebug('Exception updating grp. id', 4);
           END IF;
       END;

       IF (l_debug = 1) THEN
          mydebug('Insert serial vals'|| p_item_id || ':' || p_from_serial || ':' || p_to_serial, 4);
          mydebug('Insert serial, inserted with '|| p_serial_transaction_temp_id || ':' || l_success, 4);
       END IF;

       -- if the trx manager returned a 1 then it could not insert the row
       IF l_return = 1 THEN
         RAISE fnd_api.g_exc_error;
       END IF;

       l_progress       := '80';
       IF (l_debug = 1) THEN
          mydebug('Exitting insert_serial : 90  '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
       END IF;

       commit;

     EXCEPTION
       WHEN fnd_api.g_exc_error THEN
         --ROLLBACK TO rcv_insert_serial_sp;
         ROLLBACK;
         x_return_status  := fnd_api.g_ret_sts_error;
         IF (l_debug = 1) THEN
            mydebug('Exitting insert_serial - execution error:'|| l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
         END IF;
         --  Get message count and data
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_msg_data);
       WHEN OTHERS THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;

         IF SQLCODE IS NOT NULL THEN
           inv_mobile_helper_functions.sql_error('wms_task_load.insert_serial', l_progress, SQLCODE);
         END IF;

         IF (l_debug = 1) THEN
            mydebug('Exitting insert_serial - other exception:'|| l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
         END IF;

         --
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_msg_pub.add_exc_msg(g_pkg_name, 'insert_serial');
         END IF;

END insert_serial;

/*Added to validate cost group comingle bug 3858907 */
procedure validate_loaded_lpn_cg( p_organization_id       IN  NUMBER,
        p_inventory_item_id     IN  NUMBER,
        p_subinventory_code     IN  VARCHAR2,
        p_locator_id            IN  NUMBER,
        p_revision              IN  VARCHAR2,
        p_lot_number            IN  VARCHAR2,
        p_lpn_id                IN  NUMBER,
        p_transfer_lpn_id       IN  NUMBER,
        p_lot_control           IN  NUMBER,
        p_revision_control      IN  NUMBER,
        x_commingle_exist       OUT NOCOPY VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        p_trx_type_id           IN  VARCHAR2, -- Bug 4632519
        p_trx_action_id        IN  VARCHAR2) -- Bug 4632519
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_cur_cost_group_id NUMBER := NULL;
    l_exist_cost_group_id NUMBER := NULL;
    l_sub VARCHAR2(20);
    l_loc NUMBER;
    l_rev VARCHAR2(4);
    l_lpn NUMBER;
    l_ser VARCHAR2(20);
    l_lot VARCHAR2(20);
    -- Bug 4632519
    l_transaction_action_id NUMBER;
    l_transaction_type_id NUMBER;
    l_is_bf  boolean;
    -- Bug 4632519
BEGIN
   IF (l_debug = 1) THEN
      mydebug( 'In check_cg_commingle... ');
      mydebug('p_organization_id'||p_organization_id);
      mydebug('p_inventory_item_id'||p_inventory_item_id);
      mydebug('p_subinventory_code'||p_subinventory_code);
      mydebug('p_locator_id'||p_locator_id);
      mydebug('p_revision'||p_revision);
      mydebug('p_lot_number'||p_lot_number);
      mydebug('p_transfer_lpn_id'||p_transfer_lpn_id);
      mydebug('p_lpn_id'||p_lpn_id);
      mydebug('p_lot_control'||p_lot_control);
      mydebug('p_revision_control'||p_revision_control);
      mydebug('p_trx_souce_type_id' ||p_trx_type_id);
      mydebug('p_trx_action_id ' || p_trx_action_id);
   END IF;

   x_return_status  := fnd_api.g_ret_sts_success;
   x_commingle_exist := 'N';

     IF p_lot_control = 1 THEN
         select mmtt.subinventory_code,
                mmtt.locator_id,
                mmtt.revision,
                mmtt.lpn_id,
                null,
                null,
                mmtt.transaction_action_id, -- Bug 4632519
                mmtt.transaction_type_id -- Bug 4632519
           INTO l_sub,
                l_loc,
                l_rev,
                l_lpn,
                l_ser,l_lot,
                l_transaction_action_id, -- Bug 4632519
                l_transaction_type_id -- Bug 4632519
           from mtl_material_Transactions_temp mmtt
          where mmtt.inventory_item_id = p_inventory_item_id
            and mmtt.organization_id = p_organization_id
            and mmtt.transfer_lpn_id = p_transfer_lpn_id
            and mmtt.content_lpn_id is null
            and decode(p_revision_control,2,mmtt.revision,1,'~~') = nvl(p_revision,'~~')
            and rownum<2;
    ELSE
         select mmtt.subinventory_code,
                mmtt.locator_id,
                mmtt.revision,
                mmtt.lpn_id,
                null,
                mtlt.lot_number,
                mmtt.transaction_action_id,
                mmtt.transaction_type_id
         INTO l_sub,
              l_loc,
              l_rev,
              l_lpn,
              l_ser,
              l_lot,
              l_transaction_action_id, -- Bug 4632519
              l_transaction_type_id -- Bug 4632519
         from mtl_material_Transactions_temp mmtt,
              mtl_transaction_lots_temp mtlt
        where mmtt.inventory_item_id = p_inventory_item_id
          and mmtt.organization_id = p_organization_id
          and mmtt.transfer_lpn_id = p_transfer_lpn_id
          and mmtt.content_lpn_id is null
          and decode(p_revision_control,2,mmtt.revision,1,'~~') = nvl(p_revision,'~~')
          and mmtt.transaction_temp_id = mtlt.transaction_temp_id
          and mtlt.lot_number = p_lot_number
          and rownum<2;
    END IF;

    IF (l_debug = 1) THEN
        mydebug( 'Loaded LPN data From MMTT');
        mydebug('l_subinventory_code'||l_sub);
        mydebug('l_locator_id'||l_loc);
        mydebug('l_revision'||l_rev);
        mydebug('l_lot_number'||l_lot);
        mydebug('l_serial_number'||l_ser);
        mydebug('l_lpn_id'||l_lpn);
    END IF;
    --
    -- Bug 4632519
    if (p_trx_type_id='51') then
        l_is_bf := true;
    end if;
    --
     inv_cost_group_update.proc_determine_costgroup(
        p_organization_id       => p_organization_id,
        p_inventory_item_id     => p_inventory_item_id,
        p_subinventory_code     => p_subinventory_code,
        p_locator_id            => p_locator_id,
        p_revision              => p_revision,
        p_lot_number            => p_lot_number,
        p_serial_number         => null,
        p_containerized_flag    => null,
        p_lpn_id                => p_lpn_id,
        p_transaction_action_id => p_trx_action_id,
        p_is_backflush_txn      => l_is_bf,
        x_cost_group_id         => l_cur_cost_group_id,
        x_return_status         => x_return_status);

     IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     if (l_transaction_type_id=51) then
        l_is_bf := true;
     end if;
     inv_cost_group_update.proc_determine_costgroup(
           p_organization_id       => p_organization_id,
           p_inventory_item_id     => p_inventory_item_id,
           p_subinventory_code     => l_sub,
           p_locator_id            => l_loc,
           p_revision              => l_rev,
           p_lot_number            => l_lot,
           p_serial_number         => l_ser,
           p_containerized_flag    => null,
           p_lpn_id                => l_lpn,
           p_transaction_action_id => l_transaction_action_id,
           p_is_backflush_txn      => l_is_bf,
           x_cost_group_id         => l_exist_cost_group_id,
           x_return_status         => x_return_status);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
           RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF l_exist_cost_group_id <> l_cur_cost_group_id THEN
      x_return_status := fnd_api.g_ret_sts_success;
      x_commingle_exist := 'Y';
   END IF;
   --
   -- Bug 4632519
   --
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       IF (l_debug = 1) THEN
         mydebug('First record being loaded into LPN');
       END IF;
       x_return_status := fnd_api.g_ret_sts_success;
       x_commingle_exist := 'N';
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_commingle_exist := 'Y';
END validate_loaded_lpn_cg;

--/* Bug 9448490 Lot Substitution Project */ start
PROCEDURE insert_mtlt (
        p_new_temp_id     IN  NUMBER
      , p_serial_temp_id  IN  NUMBER := NULL
      , p_pri_att_qty         IN  NUMBER
      , p_trx_att_qty         IN  NUMBER
      , p_lot_number      IN  VARCHAR2
      , p_item_id         IN  NUMBER
      , p_organization_id IN  NUMBER
      , x_return_status   OUT NOCOPY VARCHAR2)  IS

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    mydebug('  Inside insert mtlt' );
    INSERT INTO mtl_transaction_lots_temp
                (
                 transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , transaction_quantity
               , primary_quantity
               , lot_number
               , lot_expiration_date
               , serial_transaction_temp_id
               , description
               , vendor_name
               , supplier_lot_number
               , origination_date
               , date_code
               , grade_code
               , change_date
               , maturity_date
               , retest_date
               , age
               , item_size
               , color
               , volume
               , volume_uom
               , place_of_origin
               , best_by_date
               , LENGTH
               , length_uom
               , recycled_content
               , thickness
               , thickness_uom
               , width
               , width_uom
               , curl_wrinkle_fold
               , lot_attribute_category
               , c_attribute1
               , c_attribute2
               , c_attribute3
               , c_attribute4
               , c_attribute5
               , c_attribute6
               , c_attribute7
               , c_attribute8
               , c_attribute9
               , c_attribute10
               , c_attribute11
               , c_attribute12
               , c_attribute13
               , c_attribute14
               , c_attribute15
               , c_attribute16
               , c_attribute17
               , c_attribute18
               , c_attribute19
               , c_attribute20
               , d_attribute1
               , d_attribute2
               , d_attribute3
               , d_attribute4
               , d_attribute5
               , d_attribute6
               , d_attribute7
               , d_attribute8
               , d_attribute9
               , d_attribute10
               , n_attribute1
               , n_attribute2
               , n_attribute3
               , n_attribute4
               , n_attribute5
               , n_attribute6
               , n_attribute7
               , n_attribute8
               , n_attribute9
               , n_attribute10
               , vendor_id
               , territory_code
                )
      (SELECT p_new_temp_id
            , sysdate
            , -9999
            , sysdate
            , -9999
            , p_trx_att_qty
            , p_pri_att_qty
            , p_lot_number
            , mln.expiration_date
            , p_serial_temp_id
            , mln.description
            , mln.vendor_name
            , mln.supplier_lot_number
            , mln.origination_date
            , mln.date_code
            , mln.grade_code
            , mln.change_date
            , mln.maturity_date
            , mln.retest_date
            , mln.age
            , mln.item_size
            , mln.color
            , mln.volume
            , mln.volume_uom
            , mln.place_of_origin
            , mln.best_by_date
            , mln.LENGTH
            , mln.length_uom
            , mln.recycled_content
            , mln.thickness
            , mln.thickness_uom
            , mln.width
            , mln.width_uom
            , mln.curl_wrinkle_fold
            , mln.lot_attribute_category
            , mln.c_attribute1
            , mln.c_attribute2
            , mln.c_attribute3
            , mln.c_attribute4
            , mln.c_attribute5
            , mln.c_attribute6
            , mln.c_attribute7
            , mln.c_attribute8
            , mln.c_attribute9
            , mln.c_attribute10
            , mln.c_attribute11
            , mln.c_attribute12
            , mln.c_attribute13
            , mln.c_attribute14
            , mln.c_attribute15
            , mln.c_attribute16
            , mln.c_attribute17
            , mln.c_attribute18
            , mln.c_attribute19
            , mln.c_attribute20
            , mln.d_attribute1
            , mln.d_attribute2
            , mln.d_attribute3
            , mln.d_attribute4
            , mln.d_attribute5
            , mln.d_attribute6
            , mln.d_attribute7
            , mln.d_attribute8
            , mln.d_attribute9
            , mln.d_attribute10
            , mln.n_attribute1
            , mln.n_attribute2
            , mln.n_attribute3
            , mln.n_attribute4
            , mln.n_attribute5
            , mln.n_attribute6
            , mln.n_attribute7
            , mln.n_attribute8
            , mln.n_attribute9
            , mln.n_attribute10
            , mln.vendor_id
            , mln.territory_code
       FROM    mtl_lot_numbers mln
       WHERE   mln.lot_number = p_lot_number
       AND    mln.inventory_item_id = p_item_id
       AND    mln.organization_id = p_organization_id);

 EXCEPTION
    WHEN OTHERS THEN
    x_return_status  := l_g_ret_sts_error;
    mydebug(' Insert mtlt returns exception' );
    mydebug ('Others exception while updating From LPN context: ' || SQLCODE);
END;


PROCEDURE populate_lot_lov(
    p_fromlpn_id            IN            NUMBER
  , p_org_id                IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_rev                   IN            VARCHAR2
  , p_lot                   IN            VARCHAR2
  , p_trx_qty               IN            NUMBER
  , p_trx_uom               IN            VARCHAR2
  , x_match                 OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , p_temp_id               IN            NUMBER
  , p_transaction_type_id   IN            NUMBER
  , p_cost_group_id         IN            NUMBER
  , p_is_sn_alloc           IN            VARCHAR2
  , p_user_id               IN            NUMBER
  , x_lpn_lot_vector        OUT NOCOPY    VARCHAR2
  , p_transaction_action_id IN            NUMBER
  , p_confirmed_sub         IN            VARCHAR2
  , p_confirmed_loc_id      IN            NUMBER
  , p_from_lpn_id           IN            NUMBER
  ) IS
    l_proc_name              VARCHAR2(30) := 'populate_lot_lov' ;
    l_msg_cnt                NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(240);
    l_exist_qty              NUMBER;
    l_item_cnt               NUMBER;
    l_rev_cnt                NUMBER;
    l_lot_cnt                NUMBER;
    l_item_cnt2              NUMBER;
    l_cg_cnt                 NUMBER;
    l_sub                    VARCHAR2(60);
    l_loc                    VARCHAR2(60);
    l_loaded                 NUMBER         := 0;
    l_allocate_serial_flag   NUMBER         := 0;
    l_temp_serial_trans_temp NUMBER         := 0;
    l_serial_number          VARCHAR2(50);
    l_lpn_pr_qty             NUMBER;
    l_lpn_trx_qty            NUMBER;
    l_pr_qty                 NUMBER;
    l_primary_uom            VARCHAR2(3);
    l_lot_code               NUMBER;
    l_serial_code            NUMBER;
    l_mmtt_qty               NUMBER;
    l_out_temp_id            NUMBER         := 0;
    l_serial_exist_cnt       NUMBER         := 0;
    l_total_serial_cnt       NUMBER         := 0;
    l_so_cnt                 NUMBER         := 0;
    l_mtlt_lot_number        VARCHAR2(30);
    l_mtlt_primary_qty       NUMBER;
    l_wlc_quantity           NUMBER;
    l_wlc_uom_code           VARCHAR2(3);
    l_lot_match              NUMBER;
    l_ok_to_process          VARCHAR2(5);
    l_is_revision_control    VARCHAR2(1);
    l_is_lot_control         VARCHAR2(1);
    l_is_serial_control      VARCHAR2(1);
    b_is_revision_control    BOOLEAN;
    b_is_lot_control         BOOLEAN;
    b_is_serial_control      BOOLEAN;
    l_from_lpn               VARCHAR2(30);
    l_loc_id                 NUMBER;
    l_lpn_context            NUMBER;
    l_lpn_exists             NUMBER;
    l_qoh                    NUMBER;
    l_rqoh                   NUMBER;
    l_qr                     NUMBER;
    l_qs                     NUMBER;
    l_att                    NUMBER;
    l_atr                    NUMBER;
    l_allocated_lpn_id       NUMBER;
    l_table_index            NUMBER         := 0;
    l_table_total            NUMBER         := 0;
    l_table_count            NUMBER;
    l_lpn_include_lpn        NUMBER;
    l_xfr_sub_code           VARCHAR2(30);
    l_sub_active             NUMBER         := 0;
    l_loc_active             NUMBER         := 0;
    l_mmtt_proj_id NUMBER ;  --  2774506/2905646
    l_mmtt_task_id NUMBER ;
    l_locator_id NUMBER;
    l_organization_id NUMBER;
    l_mil_proj_id NUMBER ;
    l_mil_task_id NUMBER ;   -- 2774506/2905646
    l_transaction_header_id   NUMBER;
    l_transaction_uom         VARCHAR2(3);
    l_lpn_id          NUMBER;
    l_content_lpn_id  NUMBER;
    --l_transfer_lpn_id NUMBER;
    l_check_tolerance   Boolean;
    l_overpicked_qty   NUMBER ;
    l_check_overpick_passed VARCHAR2(1);
    l_overpick_error_code  NUMBER;
    l_match_serials      Boolean  := false;
    l_pick_to_lpn_id      NUMBER;
    l_lot_v              VARCHAR2(2000) := null;
    l_value VARCHAR2(3);  --bug 6012428

    CURSOR lot_substitution_csr IS
       SELECT NVL(SUM(primary_transaction_quantity),0)
	      , lot_number
             FROM mtl_onhand_quantities_detail
             WHERE organization_id = p_org_id
	     AND Nvl(containerized_flag, 2) = 1 -- different from loose_match
	     AND lpn_id = p_fromlpn_id
             AND subinventory_code = p_confirmed_sub
             AND locator_id = p_confirmed_loc_id
             AND inventory_item_id = p_item_id
             AND (revision = p_rev OR (revision IS NULL AND p_rev IS NULL))
             AND lot_number NOT IN (
			           SELECT mtlt.lot_number
				   FROM mtl_transaction_lots_temp mtlt
				   WHERE mtlt.transaction_temp_id = p_temp_id
				   )
	    AND lot_number IS NOT NULL
	    GROUP BY lot_number
	    ORDER BY lot_number;

    CURSOR lot_substitution_loose_csr IS
       SELECT NVL(SUM(primary_transaction_quantity),0)
	      , lot_number
             FROM mtl_onhand_quantities_detail
             WHERE organization_id = p_org_id
	     AND Nvl(containerized_flag, 2) <> 1
             AND subinventory_code = p_confirmed_sub
             AND locator_id = p_confirmed_loc_id
             AND inventory_item_id = p_item_id
             AND (revision = p_rev OR (revision IS NULL AND p_rev IS NULL))
             AND lot_number NOT IN (
			           SELECT mtlt.lot_number
				   FROM mtl_transaction_lots_temp mtlt
				   WHERE mtlt.transaction_temp_id = p_temp_id
				   )
	    AND lot_number IS NOT NULL
	    GROUP BY lot_number
	    ORDER BY lot_number;
    l_debug                  NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  BEGIN
    x_return_status    := fnd_api.g_ret_sts_success;
    t_lpn_lot_qty_table.DELETE;

     SELECT primary_uom_code
          , lot_control_code
          , serial_number_control_code
       INTO l_primary_uom
          , l_lot_code
          , l_serial_code
       FROM mtl_system_items
      WHERE organization_id = p_org_id
        AND inventory_item_id = p_item_id;

	select value
	into l_value
	from v$nls_parameters
	where parameter = 'NLS_NUMERIC_CHARACTERS';

    -- p_trx_qty was passed in transaction_uom, need to convert it to primary_uom
    IF (l_debug = 1) THEN
          mydebug('p_trx_uom :'|| p_trx_uom);
          mydebug('l_primary_uom :'|| l_primary_uom);
          mydebug('p_trx_qty in transaction uom:'|| p_trx_qty);
    END IF;

    IF  p_transaction_action_id = 28
    THEN
	IF p_fromlpn_id IS NOT NULL THEN
	OPEN lot_substitution_csr;
	 LOOP
	   FETCH lot_substitution_csr INTO l_mtlt_primary_qty, l_mtlt_lot_number;
	   EXIT WHEN lot_substitution_csr%NOTFOUND;

           IF (l_debug = 1) THEN
              mydebug(' Unallocated l_mtlt_lot_number : ' || l_mtlt_lot_number);
              mydebug(' Unallocated l_mtlt_primary_qty: ' || l_mtlt_primary_qty);
              mydebug(' Unallocated p_org_id ' || p_org_id);
              mydebug(' Unallocated p_item_id ' || p_item_id);
              mydebug(' Unallocated NVL(p_rev, NULL) '|| p_rev);
              mydebug(' Unallocated l_mtlt_lot_number ' || l_mtlt_lot_number);
              mydebug(' Unallocated p_confirmed_sub '|| p_confirmed_sub);
              mydebug(' Unallocated p_confirmed_loc_id ' || p_confirmed_loc_id);
              mydebug(' Unallocated p_fromlpn_id ' || p_fromlpn_id);
              mydebug(' Unallocated l_xfr_sub_code ' || l_xfr_sub_code);
             END IF;

	 inv_quantity_tree_pub.query_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => TRUE
          , p_is_serial_control          => b_is_serial_control
          , p_demand_source_type_id      => -9999
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => l_mtlt_lot_number
          , p_subinventory_code          => p_confirmed_sub
          , p_locator_id                 => p_confirmed_loc_id
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          , p_lpn_id                     => p_fromlpn_id
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_att > 0) THEN
              l_table_index  := l_table_index + 1;
              IF (l_debug = 1) THEN
                mydebug('Unallocated  l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
                mydebug('Unallocated  l_qoh:' || l_qoh || ' for lot:' || l_mtlt_lot_number);
              END IF;

              IF l_att < l_qoh THEN
                  l_check_tolerance := false;
                  IF (l_debug = 1) THEN
                    mydebug(' Unallocated Lots l_att < l_qoh: set l_check_tolerance to false');
                  END IF;
              END IF;

              IF (l_debug = 1) THEN
                  mydebug(' Unallocated l_table_index:' || l_table_index || ' lot_number:' || l_mtlt_lot_number || ' qty: ' || l_att);
              END IF;
              l_lpn_pr_qty                                   := l_lpn_pr_qty + l_att;
              t_lpn_lot_qty_table(l_table_index).lpn_id      := p_fromlpn_id;
              t_lpn_lot_qty_table(l_table_index).lot_number  := l_mtlt_lot_number;
              t_lpn_lot_qty_table(l_table_index).pri_qty := l_att;

              IF (l_primary_uom = p_trx_uom) THEN
                     t_lpn_lot_qty_table(l_table_index).trx_qty := l_att;
              ELSE
                     t_lpn_lot_qty_table(l_table_index).trx_qty := inv_convert.inv_um_convert(
                                               item_id        => p_item_id
                                              ,precision      => null
                                              ,from_quantity  => l_att
                                              ,from_unit      => l_primary_uom
                                              ,to_unit        => p_trx_uom
                                              ,from_name      => null
                                              ,to_name        => null);
              END IF;
              ELSE
               IF (l_debug = 1) THEN
                  mydebug('Unallocated -- LPN does not have any available qty for lot ' || l_mtlt_lot_number);
                  mydebug('Unallocated -- set l_check_tolerance to false');
               END IF;
              l_check_tolerance := false;
	    END IF;
	  END IF;
	  END LOOP;
	CLOSE lot_substitution_csr;
	ELSE
	OPEN lot_substitution_loose_csr;
	 LOOP
	   FETCH lot_substitution_loose_csr INTO l_mtlt_primary_qty, l_mtlt_lot_number;
	   EXIT WHEN lot_substitution_loose_csr%NOTFOUND;

           IF (l_debug = 1) THEN
              mydebug(' Unallocated l_mtlt_lot_number : ' || l_mtlt_lot_number);
              mydebug(' Unallocated l_mtlt_primary_qty: ' || l_mtlt_primary_qty);
           END IF;

	 inv_quantity_tree_pub.query_quantities(
            p_api_version_number         => 1.0
          , p_init_msg_lst               => fnd_api.g_false
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_cnt
          , x_msg_data                   => l_msg_data
          , p_organization_id            => p_org_id
          , p_inventory_item_id          => p_item_id
          , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
          , p_is_revision_control        => b_is_revision_control
          , p_is_lot_control             => TRUE
          , p_is_serial_control          => b_is_serial_control
          , p_demand_source_type_id      => -9999
          , p_revision                   => NVL(p_rev, NULL)
          , p_lot_number                 => l_mtlt_lot_number
          , p_subinventory_code          => p_confirmed_sub
          , p_locator_id                 => p_confirmed_loc_id
          , x_qoh                        => l_qoh
          , x_rqoh                       => l_rqoh
          , x_qr                         => l_qr
          , x_qs                         => l_qs
          , x_att                        => l_att
          , x_atr                        => l_atr
          , p_lpn_id                     => p_fromlpn_id
          , p_transfer_subinventory_code => l_xfr_sub_code
          );

          IF (l_debug = 1) THEN
             mydebug('Unallocated  l_att:' || l_att || ' for lot:' || l_mtlt_lot_number);
             mydebug('Unallocated  l_qoh:' || l_qoh || ' for lot:' || l_mtlt_lot_number);
          END IF;
          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_att > 0) THEN
              l_table_index  := l_table_index + 1;
              IF l_att < l_qoh THEN
                  l_check_tolerance := false;
                  IF (l_debug = 1) THEN
                    mydebug(' Unallocated Lots l_att < l_qoh: set l_check_tolerance to false');
                  END IF;
              END IF;

              IF (l_debug = 1) THEN
                  mydebug(' Unallocated l_table_index:' || l_table_index || ' lot_number:' || l_mtlt_lot_number || ' qty: ' || l_att);
              END IF;
              l_lpn_pr_qty                                   := l_lpn_pr_qty + l_att;
              t_lpn_lot_qty_table(l_table_index).lpn_id      := p_fromlpn_id;
              t_lpn_lot_qty_table(l_table_index).lot_number  := l_mtlt_lot_number;
              t_lpn_lot_qty_table(l_table_index).pri_qty := l_att;

              IF (l_primary_uom = p_trx_uom) THEN
                     t_lpn_lot_qty_table(l_table_index).trx_qty := l_att;
              ELSE
                     t_lpn_lot_qty_table(l_table_index).trx_qty := inv_convert.inv_um_convert(
                                               item_id        => p_item_id
                                              ,precision      => null
                                              ,from_quantity  => l_att
                                              ,from_unit      => l_primary_uom
                                              ,to_unit        => p_trx_uom
                                              ,from_name      => null
                                              ,to_name        => null);
              END IF;


            ELSE
               IF (l_debug = 1) THEN
                  mydebug('Unallocated --- LPN does not have any available qty for lot ' || l_mtlt_lot_number);
                  mydebug('Unallocated --- set l_check_tolerance to false');
               END IF;
              l_check_tolerance := false;
	    END IF;
	  END IF;
	  END LOOP;
	CLOSE lot_substitution_loose_csr;
	END IF;
      END IF;

    IF l_lot_code > 1 THEN -- lot controlled
       l_table_total      := t_lpn_lot_qty_table.COUNT;
       IF l_table_total > 0 THEN
         IF (l_debug = 1) THEN
           mydebug('building lpn lot vector for ' || l_table_total || '
                   records');
         END IF;
        FOR l_table_count IN 1 .. l_table_total LOOP
            IF (l_debug = 1) THEN
              mydebug('index is : ' || l_table_count);
            END IF;

            INSERT INTO wms_allocations_gtmp(lot_number, primary_quantity,
                                             transaction_quantity)
                   values(t_lpn_lot_qty_table(l_table_count).lot_number,
                          t_lpn_lot_qty_table(l_table_count).pri_qty,
                          t_lpn_lot_qty_table(l_table_count).trx_qty);

          END LOOP;
       END IF;
    END IF; -- done populating the lot

    --populate the lot in lpn vector
    l_table_total      := t_lpn_lot_qty_table.COUNT;
    IF l_table_total > 0 THEN
          IF (l_debug = 1) THEN
           mydebug('building lpn lot vector for ' || l_table_total || 'records');
          END IF;
          FOR l_table_count IN 1 .. l_table_total LOOP
		  IF l_value = '.,'  THEN
			    x_lpn_lot_vector := x_lpn_lot_vector
				     ||t_lpn_lot_qty_table(l_table_count).lot_number ||'@@@@@'
				     ||t_lpn_lot_qty_table(l_table_count).trx_qty||'@@@@@'
				     ||t_lpn_lot_qty_table(l_table_count).trx_qty
				     || '&&&&&';
		     	    ELSE  --bug 6012428
		            x_lpn_lot_vector := x_lpn_lot_vector
                             ||t_lpn_lot_qty_table(l_table_count).lot_number ||'@@@@@'
                             ||TO_CHAR(t_lpn_lot_qty_table(l_table_count).trx_qty,'9999999999999999999999.9999999999')||'@@@@@'
                             ||TO_CHAR(t_lpn_lot_qty_table(l_table_count).trx_qty,'9999999999999999999999.9999999999')
                             || '&&&&&';
		 END IF;--bug 6012428
                 l_lot_v   := l_lot_v ||t_lpn_lot_qty_table(l_table_count).lot_number||':'; --Bug 3855835
                 IF (l_debug = 1) THEN
                        mydebug('l_lot_v:'||l_lot_v);
                 END IF;
          END LOOP;
    ELSE
          x_lpn_lot_vector  := NULL;
    END IF;

   x_return_status    := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('Other exception raised : ' || SQLERRM);
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
END populate_lot_lov;

PROCEDURE proc_decrement_allocated_mtlts
              (p_temp_id			 IN	     NUMBER
              ,p_substitute_lots                  IN          VARCHAR2
              ,x_return_status                   OUT NOCOPY  VARCHAR2)
IS
   l_delimiter                   VARCHAR2(30)   :=  ':';
   l_lot_number                  VARCHAR2(30)   :=  NULL;
   l_lot_prim_qty                NUMBER         :=  NULL;
   m                             NUMBER := 1;  -- position of delimiter
   n                             NUMBER := 1;  -- Start position for substr or search for delimiter
   l_number_format_mask          VARCHAR2(30) :=   'FM9999999999.99999999999999'; --Bug#6244146

BEGIN
   x_return_status  := l_g_ret_sts_success;
   mydebug ('Entered proc_decrement_allocated_mtlts');

   WHILE  (n <> 0)
   LOOP
	  n := INSTR(p_substitute_lots,l_delimiter,m,1);
          mydebug ('A-m:' || m||':A-n:' || n );
          IF n = 0 THEN -- Last part OF the string
             EXIT;
          ELSE
             l_lot_number :=  substr(p_substitute_lots,m,n-m) ;-- start at M get m-n chrs.
             m := n+1;
	     n := INSTR(p_substitute_lots,l_delimiter,m,1);
             IF n = 0 THEN -- Last part OF the string
             l_lot_prim_qty :=to_number(substr(p_substitute_lots,m,length(p_substitute_lots)) ,l_number_format_mask ) ;

             ELSE
             l_lot_prim_qty :=to_number(substr(p_substitute_lots,m,n-m), l_number_format_mask ) ;
	     END IF;
             m := n+1;
          END IF;
          mydebug ('l_lot_number:' || l_lot_number);

          mydebug ('B-m:' || m||':B-n:' || n );
          mydebug ('l_lot_prim_qty:' || l_lot_prim_qty);

	  BEGIN
          IF l_lot_prim_qty >=0 THEN
	  UPDATE mtl_transaction_lots_temp
	  SET transaction_quantity = l_lot_prim_qty
	  WHERE transaction_temp_id = p_temp_id
	  AND lot_number = l_lot_number;

          DELETE FROM mtl_transaction_lots_temp
          WHERE transaction_quantity = 0
          AND transaction_temp_id = p_temp_id
          AND lot_number = l_lot_number;
          END IF;
	  EXCEPTION
	  WHEN OTHERS THEN
	  mydebug('Exception while updating MTLT in proc_decrement_allocated_mtlts ' || SQLCODE);
	  END;

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status  := l_g_ret_sts_unexp_error;
        mydebug('Exception in proc_decrement_allocated_mtlts' );
END proc_decrement_allocated_mtlts;

--/* Bug 9448490 Lot Substitution Project */ end


END wms_task_load;

/
