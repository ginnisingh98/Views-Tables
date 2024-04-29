--------------------------------------------------------
--  DDL for Package Body WIP_SO_RESERVATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SO_RESERVATIONS" as
/* $Header: wipsorvb.pls 120.7.12000000.2 2007/02/23 22:30:49 kboonyap ship $ */


-- ---------------------------------------------------------------------------
--
-- PROCEDURE allocate_completion_to_so
--
-- ---------------------------------------------------------------------------

PROCEDURE allocate_completion_to_so (
        p_organization_id       IN  NUMBER,
        p_wip_entity_id         IN  NUMBER,
        p_inventory_item_id     IN  NUMBER,
        p_transaction_header_id IN  NUMBER,
        p_table_type            IN  VARCHAR2,--either 'MMTT' or 'WLC'
        p_primary_quantity      IN  NUMBER, --lpn passed to inv's transfer_reservation
        p_lpn_id                IN  NUMBER, --override quantity in table.
        p_lot_number            IN  VARCHAR2,
        p_txn_temp_id           IN  NUMBER := NULL,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2) IS

  l_routine_name        VARCHAR2(30) := 'ALLOCATE_COMPLETION_TO_SO';
  l_reservation_rec     inv_reservation_global.mtl_reservation_rec_type;
  l_reservation_tbl     inv_reservation_global.mtl_reservation_tbl_type;
  l_rsv_tbl_count       NUMBER;
  l_transaction_tbl     transaction_temp_tbl_type;
  l_return_status       VARCHAR(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR(2000);
  l_error_code          NUMBER;
  l_reservation_found   BOOLEAN;
  l_reservation_index   NUMBER;
  i                     NUMBER;
  l_query_reservation   VARCHAR2(1);

  l_object_id                 NUMBER;
  l_lotcount                  NUMBER := 0;



BEGIN

  SAVEPOINT allocate_completion_to_so_0;
  fnd_msg_pub.initialize;

  -------------------
  -- Get reservation
  -------------------
  l_reservation_rec.organization_id := p_organization_id;
  l_reservation_rec.supply_source_header_id := p_wip_entity_id;
  l_reservation_rec.inventory_item_id := p_inventory_item_id;
  -- l_reservation_rec.demand_source_type_id :=
  --   inv_reservation_global.g_source_type_oe;
  l_reservation_rec.supply_source_type_id :=
    inv_reservation_global.g_source_type_wip;

  -- query reservations against this particular WIP job.
  -- tell API to lock rows in mtl_reservations.
  -- records are returned based on requirement date ascending.

  l_reservation_rec.lpn_id:= null ; /* Fix for Bug#4575108 */

  inv_reservation_pub.query_reservation(
    p_api_version_number    => 1.0,
    p_init_msg_lst          => fnd_api.g_false,
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data,
    p_query_input           => l_reservation_rec,
    p_lock_records          => fnd_api.g_true,
    p_sort_by_req_date      => inv_reservation_global.g_query_req_date_asc,
    x_mtl_reservation_tbl   => l_reservation_tbl,
    x_mtl_reservation_tbl_count => l_rsv_tbl_count,
    x_error_code            => l_error_code);

  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;
    x_return_status := l_return_status;
    RAISE g_need_to_rollback_exception;
  END IF;


  ----------------------
  -- Get form txn lines
  ----------------------
  IF(p_table_type = 'MMTT') THEN
    get_transaction_lines(
      p_transaction_header_id => p_transaction_header_id,
      p_transaction_type      => WIP_CONSTANTS.WASSY_COMPLETION,
      p_txn_temp_id           => p_txn_temp_id,
      x_return_status         => l_return_status,
      x_transaction_tbl       => l_transaction_tbl);
  ELSE -- get lines from wip_lpn_completions table
    get_transaction_lines(
      p_header_id             => p_transaction_header_id,
      p_primary_quantity      => p_primary_quantity,
      p_lpn_id                => p_lpn_id,
      p_lot_number            => p_lot_number,
      p_transaction_type      => WIP_CONSTANTS.WASSY_COMPLETION,
      p_transaction_action_id => WIP_CONSTANTS.CPLASSY_ACTION,
      x_return_status         => l_return_status,
      x_transaction_tbl       => l_transaction_tbl);
  END IF;

  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    ELSE
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  END IF;

  mmtt_count := l_transaction_tbl.COUNT;
  reservation_count := l_rsv_tbl_count;

  -------------------------------------
  -- Match completion with reservation
  -------------------------------------
  FOR i in 1 .. l_transaction_tbl.COUNT LOOP

    l_reservation_found := false;

    -------------
    -- validation
    -------------
    -- if item under lot control, there must be lot number
    IF (l_transaction_tbl(i).lot_control_code = WIP_CONSTANTS.LOT
        AND l_transaction_tbl(i).lot_number IS NULL) THEN
      fnd_message.set_name('WIP', 'WIP_NO_LOT_NUMBER');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_transaction_tbl(i).primary_quantity IS NULL
        OR l_transaction_tbl(i).transaction_quantity IS NULL) THEN
      fnd_message.set_name('WIP', 'WIP_ZERO_TRANSACTION_QUANTITY');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Sales order specified in the form line
    IF (l_transaction_tbl(i).demand_source_header_id IS NOT NULL) THEN
      FOR j in 1 .. l_rsv_tbl_count LOOP
        l_reservation_index := j;
        l_reservation_found :=
          validate_txn_line_against_rsv(
            p_transaction_rec  => l_transaction_tbl(i),
            p_reservation_rec  => l_reservation_tbl(j),
            p_transaction_type => WIP_CONSTANTS.WASSY_COMPLETION,
            x_return_status    => l_return_status,
            x_query_reservation => l_query_reservation);

        IF (l_return_status = fnd_api.g_ret_sts_success) THEN
          IF (l_reservation_found) THEN
            IF (l_query_reservation = 'Y') THEN
              inv_reservation_pub.query_reservation(
                p_api_version_number    => 1.0,
                p_init_msg_lst          => fnd_api.g_false,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                p_query_input           => l_reservation_rec,
                p_lock_records          => fnd_api.g_true,
                p_sort_by_req_date      => inv_reservation_global.g_query_req_date_asc,
                x_mtl_reservation_tbl   => l_reservation_tbl,
                x_mtl_reservation_tbl_count => l_rsv_tbl_count,
                x_error_code            => l_error_code);

              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                x_msg_count := l_msg_count;
                x_msg_data := l_msg_data;
                x_return_status := l_return_status;
                RAISE g_need_to_rollback_exception;
              ELSE
                l_reservation_index := 1;
              END IF;
            END IF;
            EXIT;
          END IF;
        ELSIF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSE
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP; -- l_rsv_tbl_count

      IF(l_reservation_found) THEN
        IF(l_transaction_tbl(i).lot_number is NOT null
           AND l_transaction_tbl(i).lot_control_code = WIP_CONSTANTS.LOT)THEN
          l_lotcount := 0 ;

          SELECT count(1)
            INTO l_lotcount
            FROM MTL_LOT_NUMBERS
           WHERE INVENTORY_ITEM_ID = l_transaction_tbl(i).inventory_item_id
             AND ORGANIZATION_ID = l_transaction_tbl(i).organization_id
             AND LOT_NUMBER = l_transaction_tbl(i).lot_number;

          IF(l_lotcount=0)THEN
            INV_LOT_API_PUB.InsertLot(
              p_api_version       => 1.0,
              p_init_msg_list     => 'F',
              p_commit            => 'F',
              p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
              p_inventory_item_id => l_transaction_tbl(i).inventory_item_id,
              p_organization_id   => l_transaction_tbl(i).organization_id,
              p_lot_number        => l_transaction_tbl(i).lot_number,
              p_expiration_date   => l_transaction_tbl(i).lot_expiration_date,
              p_transaction_temp_id => l_transaction_tbl(i).transaction_temp_id,
              p_transaction_Action_id => WIP_CONSTANTS.CPLASSY_ACTION,
              p_transfer_organization_id => NULL,
              x_object_id         => l_object_id,
              x_return_status     => l_return_status,
              x_msg_count         => l_msg_count,
              x_msg_data          => l_msg_data );

            IF(l_return_status <> fnd_api.g_ret_sts_success) THEN
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;
              x_return_status := l_return_status;
              RAISE g_need_to_rollback_exception;
            END IF;
          END IF;
        END IF;

        transfer_reservation(
          p_transaction_rec   => l_transaction_tbl(i),
          p_reservation_rec  => l_reservation_tbl(l_reservation_index),
          p_transaction_type => WIP_CONSTANTS.WASSY_COMPLETION,
          x_return_status    => l_return_status);

        IF (l_return_status = fnd_api.g_ret_sts_success) THEN
          -- we have already validated that txn line primary quantity
          -- is less than or equal to reservation quantity
          l_reservation_tbl(l_reservation_index).primary_reservation_quantity :=
            l_reservation_tbl(l_reservation_index).primary_reservation_quantity -
            l_transaction_tbl(i).primary_quantity;
          l_transaction_tbl(i).primary_quantity := 0;
        ELSIF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSE
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- form line has sales order specified, but not found in
        -- mtl_reservations
      ELSE
        /* ER 4163405: Replacing message WIP_SALES_ORDER_INCONSISTENCY with
           the new message WIP_NO_SUPPLY_RESERVATIONS */
        fnd_message.set_name('WIP', 'WIP_NO_SUPPLY_RESERVATIONS');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
        END IF;  -- reservation found for this completion
      ELSE  -- demand source not specified
        WHILE (l_transaction_tbl(i).primary_quantity > 0) LOOP
          FOR j in 1 .. l_rsv_tbl_count LOOP
            l_reservation_index := j;
            l_reservation_found :=
            validate_txn_line_against_rsv(
              p_transaction_rec  => l_transaction_tbl(i),
              p_reservation_rec  => l_reservation_tbl(j),
              p_transaction_type => WIP_CONSTANTS.WASSY_COMPLETION,
              x_return_status    => l_return_status,
              x_query_reservation => l_query_reservation);

          IF(l_return_status = fnd_api.g_ret_sts_success) THEN
            IF(l_reservation_found) THEN
              EXIT;
            END IF;
          ELSIF (l_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END LOOP;  -- for each line in reservation

        IF(l_reservation_found) THEN
          /* Start of fix for bug 2861429:  Create a new lot for the
           * assembly if a lot with lot number
           *l_transaction_tbl(i).lot_number does not exist. */

          IF(l_transaction_tbl(i).lot_number is NOT null
             AND
             l_transaction_tbl(i).lot_control_code = WIP_CONSTANTS.LOT )THEN
             l_lotcount := 0 ;

            SELECT count(1)
              INTO l_lotcount
              FROM MTL_LOT_NUMBERS
             WHERE INVENTORY_ITEM_ID = l_transaction_tbl(i).inventory_item_id
               AND ORGANIZATION_ID = l_transaction_tbl(i).organization_id
               AND LOT_NUMBER = l_transaction_tbl(i).lot_number;

            IF(l_lotcount=0)THEN
              INV_LOT_API_PUB.InsertLot(
                p_api_version       => 1.0,
                p_init_msg_list     => 'F',
                p_commit            => 'F',
                p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                p_inventory_item_id => l_transaction_tbl(i).inventory_item_id,
                p_organization_id   => l_transaction_tbl(i).organization_id,
                p_lot_number        => l_transaction_tbl(i).lot_number,
                p_expiration_date   => l_transaction_tbl(i).lot_expiration_date,
                p_transaction_temp_id => l_transaction_tbl(i).transaction_temp_id,
                p_transaction_Action_id => WIP_CONSTANTS.CPLASSY_ACTION,
                p_transfer_organization_id => NULL,
                x_object_id         => l_object_id,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data );

              IF(l_return_status <> fnd_api.g_ret_sts_success) THEN
                x_msg_count := l_msg_count;
                x_msg_data := l_msg_data;
                x_return_status := l_return_status;
                RAISE g_need_to_rollback_exception;
              END IF;
            END IF;
          END IF;

          /* End of fix for bug 2861429 */
          transfer_reservation(
            p_transaction_rec  => l_transaction_tbl(i),
            p_reservation_rec  => l_reservation_tbl(l_reservation_index),
            p_transaction_type => WIP_CONSTANTS.WASSY_COMPLETION,
            x_return_status    => l_return_status);

          IF(l_return_status = fnd_api.g_ret_sts_success) THEN
            IF(l_transaction_tbl(i).primary_quantity <
               l_reservation_tbl(l_reservation_index).primary_reservation_quantity) THEN
              l_reservation_tbl(l_reservation_index).primary_reservation_quantity :=
                l_reservation_tbl(l_reservation_index).primary_reservation_quantity -
                l_transaction_tbl(i).primary_quantity;
              l_transaction_tbl(i).primary_quantity := 0;
            ELSE
              l_transaction_tbl(i).primary_quantity :=
                l_transaction_tbl(i).primary_quantity -
                l_reservation_tbl(l_reservation_index).primary_reservation_quantity;
                l_reservation_tbl(l_reservation_index).primary_reservation_quantity := 0;
            END IF;
          ELSIF (l_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE  -- no reservation found
          EXIT;  -- there is no reservation matching this form line.
                 -- proceed to the next line.
        END IF;  -- reservation found for this completion?
      END LOOP;  -- while this completion line still has quantity
    END IF;  -- demand source specified in completion form line?
  END LOOP;  -- loop through each completion form line
  x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
  WHEN g_need_to_rollback_exception THEN
    ROLLBACK TO SAVEPOINT allocate_completion_to_so_0;

  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;

    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

    ROLLBACK TO SAVEPOINT allocate_completion_to_so_0;

  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;

    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

    ROLLBACK TO SAVEPOINT allocate_completion_to_so_0;

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF(fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
      fnd_msg_pub.add_exc_msg (
        g_package_name,
        l_routine_name);
    END IF;

    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

    ROLLBACK TO SAVEPOINT allocate_completion_to_so_0;
END allocate_completion_to_so;


--by default use the MMTT table
PROCEDURE allocate_completion_to_so (
        p_organization_id       IN  NUMBER,
        p_wip_entity_id         IN  NUMBER,
        p_inventory_item_id     IN  NUMBER,
        p_transaction_header_id IN  NUMBER,
        p_txn_temp_id           IN  NUMBER := NULL,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2) IS
BEGIN
    allocate_completion_to_so(p_organization_id       => p_organization_id,
                              p_wip_entity_id         =>  p_wip_entity_id,
                              p_inventory_item_id     => p_inventory_item_id,
                              p_transaction_header_id => p_transaction_header_id,
                              p_table_type            => 'MMTT',
                              p_primary_quantity      => null,
                              p_lpn_id                => null,
                              p_lot_number            => null,
                              p_txn_temp_id           => p_txn_temp_id,
                              x_return_status         => x_return_status,
                              x_msg_count             => x_msg_count,
                              x_msg_data              => x_msg_data);
END allocate_completion_to_so;



-- ---------------------------------------------------------------------------
--
-- PROCEDURE return_reservation_to_wip
--
-- HISTORY:
-- 02-MAR-2006  spondalu  ER 4163405: If pri_qty > rsv_qty, we will set rsv_qty = pri_qty
--                        to allow return for a qty more than the reserved qty. This can
--                        happen if the rest is coming from unreserved on-hand.
--                        Replaced message WIP_SALES_ORDER_INCONSISTENCY with message
--                        WIP_NO_INVENTORY_RESERVATIONS and changed the logic that throws
--                        this error to allow for partial return of reservations.
--
-- ---------------------------------------------------------------------------
PROCEDURE return_reservation_to_wip (
        p_organization_id       IN  NUMBER,
        p_wip_entity_id         IN  NUMBER,
        p_inventory_item_id     IN  NUMBER,
        p_transaction_header_id IN  NUMBER,
        p_txn_temp_id           IN  NUMBER := NULL,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2) IS

  l_routine_name        VARCHAR2(30) := 'RETURN_RESERVATION_TO_WIP';
  l_reservation_rec     inv_reservation_global.mtl_reservation_rec_type;
  l_reservation_tbl     inv_reservation_global.mtl_reservation_tbl_type;
  l_rsv_tbl_count       NUMBER;
  l_transaction_tbl     transaction_temp_tbl_type;
  l_return_status       VARCHAR(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR(2000);
  l_error_code          NUMBER;
  l_valid_reservation   BOOLEAN; /* ER 4163405 */
  l_reservation_found   BOOLEAN;
  l_reservation_index   NUMBER;
  i                     NUMBER;
  l_query_reservation   VARCHAR2(1);
  l_wip_entity_type     number; /* Bug#4472589 */

BEGIN
  SAVEPOINT return_reservation_to_wip_0;
  fnd_msg_pub.initialize;

  /* Fix for Bug#4472589. Sales Order functionality not present for EAM WO
   * therefore no need to execute this procedure. just return back with valid
   * status
   * Must find record in wip_entities table in following sql
   */

   select we.entity_type
   into   l_wip_entity_type
   from   wip_entities we
   where  we.wip_entity_id = p_wip_entity_id ;

   if l_wip_entity_type = WIP_CONSTANTS.EAM then
       x_return_status := fnd_api.g_ret_sts_success;
       return ;
   end if ;

  -------------------
  -- Get reservation
  -------------------
  l_reservation_rec.organization_id := p_organization_id;
  l_reservation_rec.inventory_item_id := p_inventory_item_id;
  --l_reservation_rec.demand_source_type_id := inv_reservation_global.g_source_type_oe;
  l_reservation_rec.supply_source_type_id := inv_reservation_global.g_source_type_inv; -- not wip

  -- query reservations for a particular inventory item
  -- tell API to lock rows in mtl_reservations.
  -- records are returned based on requirement date ascending.
  inv_reservation_pub.query_reservation(
    p_api_version_number    => 1.0,
    p_init_msg_lst          => fnd_api.g_false,
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data,
    p_query_input           => l_reservation_rec,
    p_lock_records          => fnd_api.g_true,
    p_sort_by_req_date      => inv_reservation_global.g_query_req_date_asc,
    x_mtl_reservation_tbl   => l_reservation_tbl,
    x_mtl_reservation_tbl_count => l_rsv_tbl_count,
    x_error_code            => l_error_code);

  IF(l_return_status <> fnd_api.g_ret_sts_success) THEN
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;
    x_return_status := l_return_status;
    RETURN;
  END IF;

  ----------------------
  -- Get form txn lines
  ----------------------
  get_transaction_lines(
    p_transaction_header_id => p_transaction_header_id,
    p_transaction_type      => WIP_CONSTANTS.WASSY_RETURN,
    p_txn_temp_id           => p_txn_temp_id,
    x_return_status         => l_return_status,
    x_transaction_tbl       => l_transaction_tbl);

  IF(l_return_status <> fnd_api.g_ret_sts_success) THEN
    IF(l_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    ELSE
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  END IF;

  -------------------------------------
  -- Process completion record one by one
  -------------------------------------
  l_valid_reservation := FALSE; /* ER 4163405 */
  FOR i in 1 .. l_transaction_tbl.COUNT LOOP
    -- if item under lot control, there must be lot number
    IF(l_transaction_tbl(i).lot_control_code = WIP_CONSTANTS.LOT
       AND l_transaction_tbl(i).lot_number IS NULL) THEN
      fnd_message.set_name('WIP', 'WIP_NO_LOT_NUMBER');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF(l_transaction_tbl(i).demand_source_header_id IS NULL) THEN
      l_valid_reservation := TRUE;  /* ER 4163405 */
      EXIT;-- since form lines are ordered by demand_source_header_id
           -- once we reach a line that has no header id, all following
           -- lines have no header id, so we are done.
    END IF;

    FOR j in 1 .. l_rsv_tbl_count LOOP
      l_reservation_index := j;
      l_reservation_found :=
        validate_txn_line_against_rsv(
          p_transaction_rec  => l_transaction_tbl(i),
          p_reservation_rec  => l_reservation_tbl(j),
          p_transaction_type => WIP_CONSTANTS.WASSY_RETURN,
          x_return_status    => l_return_status,
          x_query_reservation => l_query_reservation);

      IF(l_return_status = fnd_api.g_ret_sts_success) THEN
        IF(l_reservation_found) THEN
          EXIT;
        END IF;
      ELSIF (l_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END LOOP;

    IF(l_reservation_found)THEN

      /* ER 4163405: If primary qty > reservation qty. we set reservation qty := txn qty.
         This condition is true when we are trying to return from open quantity also. */
      l_valid_reservation := TRUE;
      if(-l_transaction_tbl(i).primary_quantity
               > l_reservation_tbl(l_reservation_index).primary_reservation_quantity) then
          l_transaction_tbl(i).primary_quantity
              := -l_reservation_tbl(l_reservation_index).primary_reservation_quantity;
      end if;

      transfer_reservation(
        p_transaction_rec  => l_transaction_tbl(i),
        p_reservation_rec  => l_reservation_tbl(l_reservation_index),
        p_transaction_type => WIP_CONSTANTS.WASSY_RETURN,
        x_return_status    => l_return_status);

      IF(l_return_status = fnd_api.g_ret_sts_success) THEN
        -- we have already validated that txn line primary quantity
        -- is less than or equal to reservation quantity
        l_reservation_tbl(l_reservation_index).primary_reservation_quantity :=
          l_reservation_tbl(l_reservation_index).primary_reservation_quantity +
          l_transaction_tbl(i).primary_quantity;
        l_transaction_tbl(i).primary_quantity := 0;
      ELSIF (l_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- form line has sales order specified, but not found in
      -- mtl_reservations
    END IF;  -- reservation found for this return
  END LOOP;  -- loop through each return form line


  /* ER 4163405: We throw error WIP_SALES_ORDER_INCONSISTENCY if none of the
     transaction records containing demand information could result in a
     return of reservation. Since it is now possible that only some of the
     transaction quantity could be reserved to the sales order, it is better
     to make a consolidated check for all transaction records. Also, replaced
     error message WIP_SALES_ORDER_INCONSISTENCY with the new message
     WIP_NO_INVENTORY_RESERVATIONS for clarity. */

  if(l_valid_reservation) then
    x_return_status := fnd_api.g_ret_sts_success;
  else
    fnd_message.set_name('WIP', 'WIP_NO_INVENTORY_RESERVATIONS');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  end if;

EXCEPTION
  WHEN g_need_to_rollback_exception THEN
    ROLLBACK TO SAVEPOINT return_reservation_to_wip_0;

  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;

    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

    ROLLBACK TO SAVEPOINT return_reservation_to_wip_0;

  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;

    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

    ROLLBACK TO SAVEPOINT return_reservation_to_wip_0;

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF(fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
      fnd_msg_pub.add_exc_msg (
        g_package_name,
        l_routine_name);
    END IF;

    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

    ROLLBACK TO SAVEPOINT return_reservation_to_wip_0;
END return_reservation_to_wip;


PROCEDURE transfer_flow_lines(p_transaction_tbl IN transaction_temp_tbl_type,
                              p_table_type      IN VARCHAR2, --either 'WLC' or 'MMTT'
                              p_table_line_id   IN NUMBER,
                              x_return_status   OUT NOCOPY VARCHAR2,
                              x_msg_count       OUT NOCOPY NUMBER,
                              x_msg_data        OUT NOCOPY VARCHAR2) is

  l_line_rec                    OE_Order_PUB.Line_Rec_Type;
  l_line_id                     NUMBER;
  l_requirement_date            DATE;
  l_primary_uom_code            VARCHAR2(3);
  l_primary_open_quantity       NUMBER;
  l_routine_name                VARCHAR2(30) := 'TRANSFER_FLOW_LINES';
  l_reservation_qty             NUMBER;
  l_oe_header_id                NUMBER;
  l_so_type                     NUMBER;
  l_reservation_rec             inv_reservation_global.mtl_reservation_rec_type;
  l_expiration_date             DATE := NULL;
  l_reservation_id              NUMBER;--
  l_serial_number_tbl           inv_reservation_global.serial_number_tbl_type;--
  l_to_serial_number_tbl        inv_reservation_global.serial_number_tbl_type;--
  l_quantity_reserved           NUMBER;--
  l_lotcount                    NUMBER := 0;--
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_object_id                   NUMBER;
  l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  l_params wip_logger.param_tbl_t;
  l_wip_cfg_rsv_level         NUMBER;
  l_skip_flag                 BOOLEAN;  /* Bug 2976994 */
begin
  x_return_status := fnd_api.g_ret_sts_success;
  SAVEPOINT transfer_flow_lines_0;
  if(l_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName := 'not logging params';
    l_params(1).paramValue := null;

    wip_logger.entryPoint(p_procName => 'wip_so_reservations.transfer_flow_lines',
                          p_params => l_params,
                          x_returnStatus => l_return_status);
  end if;
  -------------------------------------
  -- Loop through each completion
  -------------------------------------
  FOR i in 1 .. p_transaction_tbl.COUNT LOOP

    -- If the completion line does not have sales order specified,
    -- then skip this line.
    -- Also since get_transaction_lines sort the lines with
    -- demand source header id, the rest of lines won't have sales
    -- order specified either.  We are done.
    IF (p_transaction_tbl(i).demand_source_header_id IS NULL) THEN
      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('no SO found', l_return_status);
      end if;
      EXIT;
    END IF;


    -- validation
    -- if item under lot control, there must be lot number
    IF (p_transaction_tbl(i).lot_control_code = WIP_CONSTANTS.LOT AND
        p_transaction_tbl(i).lot_number IS NULL) THEN
      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('no lot', l_return_status);
      end if;
      fnd_message.set_name('WIP', 'WIP_NO_LOT_NUMBER');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (p_transaction_tbl(i).primary_quantity IS NULL OR
        p_transaction_tbl(i).transaction_quantity IS NULL OR
        p_transaction_tbl(i).primary_quantity = 0 OR
        p_transaction_tbl(i).transaction_quantity = 0) THEN
      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('no qty', l_return_status);
      end if;
      fnd_message.set_name('WIP', 'WIP_ZERO_TRANSACTION_QUANTITY');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    ----------------------------------
    -- Get sales order open quantity
    ----------------------------------

    BEGIN

      l_skip_flag := FALSE;   /* Bug 2976994 */

      -- we shouldn't be locking oe_order_lines_all directly
      -- this is tempoary until ONT provides a locking api
      SELECT line_id
        INTO l_line_id
        FROM oe_order_lines_all
       WHERE line_id = p_transaction_tbl(i).demand_source_line_id
         FOR UPDATE;


      SELECT requirement_date,
             primary_uom_code,
             primary_open_quantity
        INTO l_requirement_date,
             l_primary_uom_code,
             l_primary_open_quantity
        FROM wip_open_demands_v
       WHERE organization_id = p_transaction_tbl(i).organization_id
         AND inventory_item_id = p_transaction_tbl(i).inventory_item_id
         AND demand_source_header_id = p_transaction_tbl(i).demand_source_header_id
         AND demand_source_line_id = p_transaction_tbl(i).demand_source_line_id
         AND primary_open_quantity > 0;
      --FOR UPDATE;
    EXCEPTION
      -- when there is more than one row, this an internal error.
      -- open demand should be uniquely identified by a demand_source_line_id
      -- WHEN TOO_MANY_ROWS THEN

      -- where there is no row returned, the demand information specified
      -- in the form is incorrect.  error out and provide a good explanation
      -- to the user.
      WHEN NO_DATA_FOUND THEN
        /* Fix for bug 2976994: Instead of flagging error, we complete the
           flow schedule to inventory without reserving. */
        l_skip_flag := TRUE;
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('Bad SO info or no open demand. Skipping reservation.', l_return_status);
        end if;
   /*   fnd_message.set_name('WIP', 'WIP_INVALID_SO_TXN_INFO');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error; */
    END;

   if (l_skip_flag = FALSE) then
    /* Bug 2976994: There is indeed open demand for the order line */

    ----------------------------------
    -- Check completion quantity
    -- against open quantity
    ----------------------------------
    -- ** now we allow overcompletion against sales order
    -- the over completed qty will not be reserved
    l_reservation_qty := p_transaction_tbl(i).primary_quantity;
    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('rsv qty:' || l_reservation_qty, l_return_status);
    end if;
    IF (p_transaction_tbl(i).primary_quantity > l_primary_open_quantity) THEN
      l_reservation_qty := l_primary_open_quantity;
      /*
        fnd_message.set_name('WIP', 'QUANTITY_ERROR');
      fnd_message.set_token(
                            token => 'ORDER_QUANTITY',
                            value => l_primary_open_quantity);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
      */
    END IF;


    -----------------------------------
    -- Create reservation in inventory
    -----------------------------------

    -- first determine if the sales order is an internal order
    inv_salesorder.get_oeheader_for_salesorder(p_transaction_tbl(i).demand_source_header_id,
                                               l_oe_header_id,
                                               x_return_status);
    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('inv_salesorder errorred', l_return_status);
      end if;
      RAISE fnd_api.g_exc_error;
    END IF;

    SELECT source_document_type_id
      INTO l_so_type
      FROM oe_order_headers_all
     WHERE header_id = l_oe_header_id;


    l_reservation_rec.requirement_date := l_requirement_date;
    l_reservation_rec.organization_id := p_transaction_tbl(i).organization_id;
    l_reservation_rec.inventory_item_id := p_transaction_tbl(i).inventory_item_id;


    IF (l_so_type = 10) THEN
      l_reservation_rec.demand_source_type_id := inv_reservation_global.g_source_type_internal_ord;
    ELSE
      l_reservation_rec.demand_source_type_id := inv_reservation_global.g_source_type_oe;
    END IF;

    l_reservation_rec.demand_source_name := NULL;
    l_reservation_rec.demand_source_delivery := NULL;
    l_reservation_rec.demand_source_header_id := p_transaction_tbl(i).demand_source_header_id;
    l_reservation_rec.demand_source_line_id := p_transaction_tbl(i).demand_source_line_id;
    l_reservation_rec.primary_uom_code := l_primary_uom_code;
    l_reservation_rec.primary_uom_id := NULL;
    l_reservation_rec.reservation_uom_code := NULL;
    l_reservation_rec.reservation_uom_id := NULL;
    l_reservation_rec.reservation_quantity := NULL;
    l_reservation_rec.primary_reservation_quantity := l_reservation_qty;
    --p_transaction_tbl(i).primary_quantity;
    l_reservation_rec.detailed_quantity := NULL;
    l_reservation_rec.autodetail_group_id := NULL;
    l_reservation_rec.external_source_code := NULL;
    l_reservation_rec.external_source_line_id := NULL;
    l_reservation_rec.supply_source_type_id := inv_reservation_global.g_source_type_inv;
    l_reservation_rec.supply_source_header_id := p_transaction_tbl(i).wip_entity_id;
    l_reservation_rec.supply_source_line_id := NULL;
    l_reservation_rec.supply_source_name := NULL;
    l_reservation_rec.supply_source_line_detail := NULL;
    l_reservation_rec.subinventory_code := NULL;
    l_reservation_rec.subinventory_id := NULL;
    l_reservation_rec.locator_id := NULL;
    l_reservation_rec.revision := p_transaction_tbl(i).revision;

    -- 3115629  Read the profile and set the values of subinventory / locator
    l_wip_cfg_rsv_level := fnd_profile.value('WIP:CONFIGURATION_RESERVATION_LEVEL');
    IF (l_wip_cfg_rsv_level is null) then
      l_wip_cfg_rsv_level := 2;
    END IF;

    IF (l_wip_cfg_rsv_level = 2 or p_table_type = 'WLC') then
      l_reservation_rec.subinventory_code := p_transaction_tbl(i).subinventory_code;
      l_reservation_rec.subinventory_id := NULL;
      l_reservation_rec.locator_id := p_transaction_tbl(i).locator_id;
    END IF;


    l_reservation_rec.lot_number := p_transaction_tbl(i).lot_number;
    l_reservation_rec.lot_number_id := NULL;
    l_reservation_rec.pick_slip_number := NULL;
    l_reservation_rec.lpn_id := p_transaction_tbl(i).lpn_id;
    l_reservation_rec.attribute_category := NULL;
    l_reservation_rec.attribute1 := NULL;
    l_reservation_rec.attribute2 := NULL;
    l_reservation_rec.attribute3 := NULL;
    l_reservation_rec.attribute4 := NULL;
    l_reservation_rec.attribute5 := NULL;
    l_reservation_rec.attribute6 := NULL;
    l_reservation_rec.attribute7 := NULL;
    l_reservation_rec.attribute8 := NULL;
    l_reservation_rec.attribute9 := NULL;
    l_reservation_rec.attribute10 := NULL;
    l_reservation_rec.attribute11 := NULL;
    l_reservation_rec.attribute12 := NULL;
    l_reservation_rec.attribute13 := NULL;
    l_reservation_rec.attribute14 := NULL;
    l_reservation_rec.attribute15 := NULL;
    l_reservation_rec.ship_ready_flag := NULL;

    l_expiration_date := p_transaction_tbl(i).lot_expiration_date;

    if(l_reservation_rec.lot_number is NOT null) AND
      (p_transaction_tbl(i).lot_control_code = WIP_CONSTANTS.LOT) AND
      (p_table_type = 'MMTT') then

      l_lotcount := 0 ;

      SELECT count(1)
        INTO l_lotcount
        FROM MTL_LOT_NUMBERS
       WHERE INVENTORY_ITEM_ID = l_reservation_rec.inventory_item_id
         AND ORGANIZATION_ID = l_reservation_rec.organization_id
         AND LOT_NUMBER = l_reservation_rec.lot_number;

      if (l_lotcount=0) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('inserting log', l_return_status);
        end if;

        INV_LOT_API_PUB.InsertLot(p_api_version       => 1.0,
                                  p_init_msg_list     => 'F',
                                  p_commit            => 'F',
                                  p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                  p_inventory_item_id => l_reservation_rec.inventory_item_id,
                                  p_organization_id   => l_reservation_rec.organization_id,
                                  p_lot_number        => l_reservation_rec.lot_number,
                                  p_expiration_date   => l_expiration_date,
                                  p_transaction_temp_id => p_table_line_id,
                                  p_transaction_Action_id => wip_constants.cplassy_action,
                                  p_transfer_organization_id => NULL,
                                  x_object_id         => l_object_id,
                                  x_return_status     => l_return_status,
                                  x_msg_count         => l_msg_count,
                                  x_msg_data          => l_msg_data );

        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          x_return_status := l_return_status;
          RAISE g_need_to_rollback_exception;
        END IF;
      end if;
    end if ;

    -- Fix for Bug#2268499
    inv_quantity_tree_grp.clear_quantity_cache ;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('creating reservation', l_return_status);
      wip_logger.log('item' || l_reservation_rec.inventory_item_id, l_return_status);
      wip_logger.log('sub' || l_reservation_rec.subinventory_code, l_return_status);
      wip_logger.log('loc' || l_reservation_rec.locator_id, l_return_status);
      wip_logger.log('qty' || l_reservation_rec.primary_reservation_quantity, l_return_status);
      wip_logger.log('lpn' || l_reservation_rec.lpn_id, l_return_status);
    end if;
    inv_reservation_pub.create_reservation(p_api_version_number        => 1.0,
                                           p_init_msg_lst              => fnd_api.g_false,
                                           x_return_status             => l_return_status,
                                           x_msg_count                 => l_msg_count,
                                           x_msg_data                  => l_msg_data,
                                           p_rsv_rec                   => l_reservation_rec,
                                           p_serial_number             => l_serial_number_tbl,
                                           x_serial_number             => l_to_serial_number_tbl,
                                           p_partial_reservation_flag  => fnd_api.g_false,
                                           p_force_reservation_flag    => fnd_api.g_false,
                                           p_validation_flag           => fnd_api.g_true,
                                           p_partial_rsv_exists        => TRUE, -- Bug 4166956
                                           x_quantity_reserved         => l_quantity_reserved,
                                           x_reservation_id            => l_reservation_id);


    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('reservation creation failed:' || l_msg_data, l_return_status);
      end if;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
      x_return_status := l_return_status;
      RAISE g_need_to_rollback_exception;
    END IF;

   end if; /* Bug 2976994: Continue from here if skip_flag = TRUE */

  END LOOP;  -- loop through each completion form line

  x_return_status := fnd_api.g_ret_sts_success;
  if (l_logLevel <= wip_constants.trace_logging) then
    wip_logger.exitPoint(p_procName => 'wip_so_reservations.transfer_flow_lines',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'succeeded',
                         x_returnStatus => l_return_status); --discard logging return status
  end if;
exception
  WHEN g_need_to_rollback_exception THEN
    x_return_status := fnd_api.g_ret_sts_error;
    rollback to transfer_flow_lines_0;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_so_reservations.transfer_flow_lines',
                           p_procReturnStatus => x_return_status,
                           p_msg => 'error1',
                           x_returnStatus => l_return_status); --discard logging return status
    end if;

  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
    rollback to transfer_flow_lines_0;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_so_reservations.transfer_flow_lines',
                           p_procReturnStatus => x_return_status,
                           p_msg => 'error2',
                           x_returnStatus => l_return_status); --discard logging return status
    end if;

  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
    rollback to transfer_flow_lines_0;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_so_reservations.transfer_flow_lines',
                           p_procReturnStatus => x_return_status,
                           p_msg => 'error3',
                           x_returnStatus => l_return_status); --discard logging return status
    end if;

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF(fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
      fnd_msg_pub.add_exc_msg (g_package_name,
                               l_routine_name);
    END IF;

    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);

    rollback to transfer_flow_lines_0;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_so_reservations.transfer_flow_lines',
                           p_procReturnStatus => x_return_status,
                           p_msg => 'error4',
                           x_returnStatus => l_return_status); --discard logging return status
  end if;
end transfer_flow_lines;



PROCEDURE complete_flow_sched_to_so (p_header_id             IN  NUMBER,
                                     p_lpn_id                IN  NUMBER,
                                     p_primary_quantity      IN  NUMBER, --lpn passed to inv's transfer_reservation
                                     p_lot_number            IN  VARCHAR2,
                                     x_return_status         OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2) IS

  l_routine_name                VARCHAR2(30) := 'COMPLETE_FLOW_SCHED_TO_SO';
  l_transaction_tbl             transaction_temp_tbl_type;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_params wip_logger.param_tbl_t;
  l_logLevel NUMBER := fnd_log.g_current_runtime_level;
begin
  x_return_status := fnd_api.g_ret_sts_success;
  if(l_logLevel <= wip_constants.trace_logging) then
    l_params(1).paramName := 'p_header_id';
    l_params(1).paramValue := p_header_id;
    l_params(2).paramName := 'p_lpn_id';
    l_params(2).paramValue := p_lpn_id;
    l_params(3).paramName := 'p_primary_quantity';
    l_params(3).paramValue := p_primary_quantity;
    l_params(4).paramName := 'p_lot_number';
    l_params(4).paramValue := p_lot_number;

    wip_logger.entryPoint(p_procName => 'wip_so_reservations.complete_flow_sched_to_so',
                          p_params => l_params,
                          x_returnStatus => l_return_status);
  end if;

  savepoint complete_flow_sched_to_so_1;
  get_transaction_lines(p_header_id             => p_header_id,
                        p_primary_quantity      => p_primary_quantity,
                        p_lpn_id                => p_lpn_id,
                        p_lot_number            => p_lot_number,
                        p_transaction_type      => WIP_CONSTANTS.WASSY_COMPLETION,
                        p_transaction_action_id => WIP_CONSTANTS.CPLASSY_ACTION,
                        x_return_status         => l_return_status,
                        x_transaction_tbl       => l_transaction_tbl);
  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    ELSE
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  END IF;

  if(l_logLevel <= wip_constants.full_logging) then
    wip_logger.log(l_transaction_tbl.count || ' lines fetched for so rsv xfer', l_return_status);
  end if;

  transfer_flow_lines(p_transaction_tbl => l_transaction_tbl,
                      p_table_type      => 'WLC',
                      p_table_line_id   => p_header_id,
                      x_return_status   => l_return_status,
                      x_msg_data        => l_msg_data,
                      x_msg_count       => l_msg_count);

  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    ELSE
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  END IF;

  if (l_logLevel <= wip_constants.trace_logging) then
    wip_logger.exitPoint(p_procName => 'wip_so_reservations.complete_flow_sched_to_so',
                         p_procReturnStatus => x_return_status,
                         p_msg => 'succeeded',
                         x_returnStatus => l_return_status); --discard logging return status
  end if;
EXCEPTION
   WHEN g_need_to_rollback_exception THEN
     if(l_logLevel <= wip_constants.trace_logging) then
       wip_logger.exitPoint(p_procName => 'wip_so_reservations.complete_flow_sched_to_so',
                            p_procReturnStatus => x_return_status,
                            p_msg => 'error1',
                            x_returnStatus => l_return_status); --discard logging return status
     end if;
     rollback to complete_flow_sched_to_so_1;
   WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
     if(x_msg_data is null and l_msg_data is not null) then
       x_msg_data := l_msg_data;
       x_msg_count := l_msg_count;
     end if;
     rollback to complete_flow_sched_to_so_1;
     if(l_logLevel <= wip_constants.trace_logging) then
       wip_logger.exitPoint(p_procName => 'wip_so_reservations.complete_flow_sched_to_so',
                            p_procReturnStatus => x_return_status,
                            p_msg => 'error2',
                            x_returnStatus => l_return_Status); --discard logging return status
     end if;
   WHEN fnd_api.g_exc_unexpected_error THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
     rollback to complete_flow_sched_to_so_1;
     if(l_logLevel <= wip_constants.trace_logging) then
       wip_logger.exitPoint(p_procName => 'wip_so_reservations.complete_flow_sched_to_so',
                            p_procReturnStatus => x_return_Status,
                            p_msg => 'error3',
                            x_returnStatus => l_return_Status); --discard logging return status
     end if;
   WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
       fnd_msg_pub.add_exc_msg (g_package_name,
                                l_routine_name);
     END IF;
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
     rollback to complete_flow_sched_to_so_1;
     if(l_logLevel <= wip_constants.trace_logging) then
       wip_logger.exitPoint(p_procName => 'wip_so_reservations.complete_flow_sched_to_so',
                            p_procReturnStatus => x_return_Status,
                            p_msg => 'error4',
                            x_returnStatus => l_return_Status); --discard logging return status
     end if;
END complete_flow_sched_to_so;

-- ---------------------------------------------------------------------------
--
-- PROCEDURE complete_flow_sched_to_so
--
-- ---------------------------------------------------------------------------
/*Bug 5676680: Added one extra parameter p_transaction_temp_id*/
PROCEDURE complete_flow_sched_to_so (
        p_transaction_header_id IN  NUMBER,
        p_transaction_temp_id   IN  NUMBER DEFAULT NULL,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2) IS

  l_routine_name                VARCHAR2(30) := 'COMPLETE_FLOW_SCHED_TO_SO';
  --l_reservation_rec_default   inv_reservation_global.mtl_reservation_rec_type;
  l_reservation_rec             inv_reservation_global.mtl_reservation_rec_type;
  l_transaction_tbl             transaction_temp_tbl_type;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_requirement_date            DATE;
  l_primary_uom_code            VARCHAR2(3);
  l_primary_open_quantity       NUMBER;
  l_quantity_reserved           NUMBER;
  l_reservation_id              NUMBER;
  l_serial_number_tbl           inv_reservation_global.serial_number_tbl_type;
  l_to_serial_number_tbl        inv_reservation_global.serial_number_tbl_type;
  l_line_rec                    OE_Order_PUB.Line_Rec_Type;
  l_line_id                     NUMBER;
  l_oe_header_id                NUMBER;
  l_so_type                     NUMBER;

  l_cp_transaction_id           NUMBER;
  l_trx_action_id               NUMBER;
  l_trx_temp_id               NUMBER;
  l_expiration_date           DATE := NULL;
  l_object_id                 NUMBER;
  l_lotcount                  NUMBER := 0;

  l_reservation_qty           NUMBER;

  /*Bug 5676680: Added one extra parameter p_transaction_temp_id in below
                 cursor and changed where clause to use this new parameter
   */
  cursor get_group_recs (p_transaction_header_id NUMBER,
                         p_transaction_temp_id NUMBER) IS
    select completion_transaction_id,
           transaction_action_id,
           transaction_temp_id
    from mtl_material_transactions_temp
    where transaction_header_id = p_transaction_header_id
      and transaction_temp_id = nvl(p_transaction_temp_id,transaction_temp_id);

BEGIN


        SAVEPOINT complete_flow_sched_to_so_0;

        fnd_msg_pub.initialize;

        ----------------------
        -- Get form txn lines
        ----------------------

        -- added because get_transaction_lines() expects the completion_transaction_id.
        -- the transaction_header_id in Flow and WOL is guaranteed to be unique.

        -- get the parent record of the group sharing the same header id
        l_trx_action_id := -1;

        /*Bug 5676680: Added one extra parameter p_transaction_temp_id*/
        open get_group_recs (p_transaction_header_id, p_transaction_temp_id);
        loop
          fetch get_group_recs into l_cp_transaction_id, l_trx_action_id,l_trx_temp_id;
          exit when l_trx_action_id = WIP_CONSTANTS.CPLASSY_ACTION
                 or get_group_recs%NOTFOUND;

        end loop;
        close get_group_recs;

        -- this method should only be called for completion transactions
        if (l_trx_action_id <> WIP_CONSTANTS.CPLASSY_ACTION) then
          return;
        end if;

        get_transaction_lines(
                p_transaction_header_id => l_cp_transaction_id,
                p_transaction_type      => WIP_CONSTANTS.WASSY_COMPLETION,
                x_return_status         => l_return_status,
                x_transaction_tbl       => l_transaction_tbl);


        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
           IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                RAISE fnd_api.g_exc_error;
           ELSE
                RAISE fnd_api.g_exc_unexpected_error;
           END IF;
        END IF;

        transfer_flow_lines(p_transaction_tbl => l_transaction_tbl,
                            p_table_type => 'MMTT',
                            p_table_line_id => l_trx_temp_id,
                            x_return_status   => x_return_status,
                            x_msg_data        => l_msg_data,
                            x_msg_count       => l_msg_count);


EXCEPTION
        WHEN g_need_to_rollback_exception THEN
          ROLLBACK TO SAVEPOINT complete_flow_sched_to_so_0;
           /* Fix for Bug3035884 . Added following procedure call */
           fnd_msg_pub.count_and_get(
                        p_encoded => fnd_api.g_false,
                        p_count   => x_msg_count,
                        p_data    => x_msg_data);

        WHEN fnd_api.g_exc_error THEN

           x_return_status := fnd_api.g_ret_sts_error;

           fnd_msg_pub.count_and_get(
                        p_encoded => fnd_api.g_false,
                        p_count   => x_msg_count,
                        p_data    => x_msg_data);

           ROLLBACK TO SAVEPOINT complete_flow_sched_to_so_0;

        WHEN fnd_api.g_exc_unexpected_error THEN

           x_return_status := fnd_api.g_ret_sts_unexp_error;

           fnd_msg_pub.count_and_get(
                        p_encoded => fnd_api.g_false,
                        p_count   => x_msg_count,
                        p_data    => x_msg_data);

           ROLLBACK TO SAVEPOINT complete_flow_sched_to_so_0;

        WHEN OTHERS THEN

           x_return_status := fnd_api.g_ret_sts_unexp_error;
           IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
                fnd_msg_pub.add_exc_msg (
                                g_package_name,
                                l_routine_name);
           END IF;

           fnd_msg_pub.count_and_get(
                        p_encoded => fnd_api.g_false,
                        p_count   => x_msg_count,
                        p_data    => x_msg_data);

           ROLLBACK TO SAVEPOINT complete_flow_sched_to_so_0;


END complete_flow_sched_to_so;



-- ---------------------------------------------------------------------------
--
-- PROCEDURE split_order_line
--
-- ---------------------------------------------------------------------------
PROCEDURE split_order_line(
        p_old_demand_source_line_id     IN  NUMBER,
        p_new_demand_source_line_id     IN  NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
        x_msg_count                     OUT NOCOPY NUMBER,
        x_msg_data                      OUT NOCOPY VARCHAR2) IS

  l_routine_name        VARCHAR2(30) := 'SPLIT_ORDER_LINE';

BEGIN
        UPDATE  WIP_FLOW_SCHEDULES
        SET     demand_source_line = to_char(p_new_demand_source_line_id)
        WHERE   to_number(demand_source_line) = p_old_demand_source_line_id;

        x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
        WHEN OTHERS THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_package_name, l_routine_name);
           END IF;
           fnd_msg_pub.count_and_get(
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

END split_order_line;




-- ---------------------------------------------------------------------------
--
-- PROCEDURE get_transaction_lines
--
--      This procedure returns a table of transaction records from
--      mtl_material_transactions_temp (and lots_temp if lot
--      controlled)
--      Used to match with reservation.
--
--
--      Internal helper
-- ---------------------------------------------------------------------------
     -- note: using WIP_CONSTANTS.NO_LOT in the group by expression causes
     --       ORA-3113.  So I am hardcoding the number instead.
--  HISTORY:
--  02-MAR-2006  spondalu  ER 4163405: For returns of lot-controlled assemblies,
--                         qty was coming as +ve due to bug in cursor c_transaction_lines.
--                         Corrected that.
--

PROCEDURE get_transaction_lines (
        p_transaction_header_id IN  NUMBER,
        p_transaction_type      IN  NUMBER,
        p_txn_temp_id           IN  NUMBER := NULL,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_transaction_tbl       OUT NOCOPY transaction_temp_tbl_type) IS

  CURSOR c_transaction_lines (cp_transaction_header_id NUMBER,
                              cp_transaction_action_id NUMBER) IS
        SELECT  mmtt.demand_source_header_id,
                mmtt.demand_source_line,
                mmtt.organization_id,
                mmtt.inventory_item_id,
                mmtt.revision,
                mmtt.subinventory_code,
                mmtt.locator_id,
                msi.lot_control_code ,
                mtlt.lot_number,
                mmtt.transaction_source_id,
                mmtt.transaction_uom,
                mmtt.transaction_date,
                sum(decode(msi.lot_control_code,
                           2 /*WIP_CONSTANTS.LOT*/, mtlt.primary_quantity*sign(mmtt.primary_quantity), /* ER 4163405 */
                           mmtt.primary_quantity)),
                sum(decode(msi.lot_control_code,
                           2 /*WIP_CONSTANTS.LOT*/, mtlt.transaction_quantity*sign(mmtt.transaction_quantity),
                           mmtt.transaction_quantity)),
                mmtt.demand_class,
                mtlt.lot_expiration_date,
                mmtt.transaction_temp_id,
                null --never an lpn associated with a non-lpn completion
        FROM    MTL_SYSTEM_ITEMS  MSI,
                MTL_TRANSACTION_LOTS_TEMP MTLT,
                MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
        WHERE   mmtt.completion_transaction_id = cp_transaction_header_id
                AND mmtt.transaction_action_id = cp_transaction_action_id
                AND mmtt.transaction_source_type_id = 5   /* Job or Schedule */
                AND mtlt.transaction_temp_id (+) = mmtt.transaction_temp_id
                AND MMTT.inventory_item_id = msi.inventory_item_id
                AND MMTT.organization_id = msi.organization_id
                AND (p_txn_temp_id IS NULL OR
                     mmtt.transaction_temp_id = p_txn_temp_id)
        GROUP BY
                mmtt.demand_source_header_id,
                mmtt.demand_source_line,
                mmtt.organization_id,
                mmtt.inventory_item_id,
                mmtt.revision,
                mmtt.subinventory_code,
                mmtt.locator_id,
                msi.lot_control_code,
                mtlt.lot_number,
                mmtt.transaction_source_id,
                mmtt.transaction_uom,
                mmtt.transaction_date,
                mmtt.demand_class,
                mtlt.lot_expiration_date,
                mmtt.transaction_temp_id
        ORDER BY
                mmtt.transaction_temp_id,
                mmtt.demand_source_header_id,
                mmtt.demand_source_line;


  l_routine_name        VARCHAR2(30) := 'GET_TRANSACTION_LINES';
  l_counter             NUMBER := 0;
  l_transaction_rec     transaction_temp_rec_type;
  l_transaction_action_id NUMBER := 0;

BEGIN
        x_return_status := fnd_api.g_ret_sts_unexp_error;

        IF (p_transaction_type = WIP_CONSTANTS.WASSY_COMPLETION) THEN
           l_transaction_action_id := WIP_CONSTANTS.CPLASSY_ACTION; /* 31, completion */
        ELSE
           l_transaction_action_id := WIP_CONSTANTS.RETASSY_ACTION; /* 32, return */
        END IF;

        OPEN c_transaction_lines(p_transaction_header_id, l_transaction_action_id);
        LOOP
                FETCH c_transaction_lines INTO l_transaction_rec;
                EXIT WHEN c_transaction_lines%NOTFOUND;
                l_counter := l_counter + 1;
                x_transaction_tbl(l_counter) := l_transaction_rec;
        END LOOP;
        CLOSE c_transaction_lines;
        x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
        WHEN OTHERS THEN
           IF (c_transaction_lines%ISOPEN) THEN
              CLOSE c_transaction_lines;
           END IF;
           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_package_name, l_routine_name);
           END IF;

END get_transaction_lines;


-- ---------------------------------------------------------------------------
--
-- PROCEDURE get_transaction_lines
--
--      This procedure returns a table of transaction records from
--      wip_lpn_completions
--      Used to match with reservation.
--
--
--      Internal helper
-- ---------------------------------------------------------------------------
     -- note: using WIP_CONSTANTS.NO_LOT in the group by expression causes
     --       ORA-3113.  So I am hardcoding the number instead.

PROCEDURE get_transaction_lines (
        p_header_id             IN  NUMBER,
        p_transaction_type      IN  NUMBER,
        p_transaction_action_id IN  NUMBER,
        p_primary_quantity      IN  NUMBER,
        p_lpn_id                IN  NUMBER,
        p_lot_number            IN VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_transaction_tbl       OUT NOCOPY transaction_temp_tbl_type) IS

  CURSOR c_transaction_lines (cp_header_id NUMBER,
                              cp_transaction_action_id NUMBER) IS
        SELECT  wlc.demand_source_header_id, --to_number(null),
                wlc.demand_source_line,--null,
                wlc.organization_id,
                wlc.inventory_item_id,
                decode(msi.revision_qty_control_code,2,wlc.bom_revision,null),
                wlc.subinventory_code,
                wlc.locator_id,
                msi.lot_control_code ,
                wlcl.lot_number,
                wlc.wip_entity_id,
                wlc.transaction_uom,
                wlc.transaction_date,
                p_primary_quantity,
                p_primary_quantity,
                null,
                WLCL.lot_expiration_date,
                null,
                p_lpn_id
        FROM    MTL_SYSTEM_ITEMS MSI,
                WIP_LPN_COMPLETIONS_LOTS WLCL,
                WIP_LPN_COMPLETIONS WLC
        WHERE   wlc.header_id = cp_header_id
                AND wlc.transaction_source_type_id = 5   /* Job or Schedule */
                AND wlcl.header_id (+) = wlc.header_id
                AND wlcl.lot_number (+) = p_lot_number
                AND wlc.transaction_action_id = cp_transaction_action_id
                AND wlc.inventory_item_id = msi.inventory_item_id
                AND wlc.organization_id = msi.organization_id
        GROUP BY
                wlc.demand_source_header_id,
                wlc.demand_source_line,
                wlc.organization_id,
                wlc.inventory_item_id,
                decode(msi.revision_qty_control_code,2,wlc.bom_revision,null),
                wlc.subinventory_code,
                wlc.locator_id,
                msi.lot_control_code,
                wlcl.lot_number,
                wlc.wip_entity_id,
                wlc.transaction_uom,
                wlc.primary_quantity,
                wlc.transaction_date,
                WLCL.lot_expiration_date;


  l_routine_name        VARCHAR2(30) := 'GET_TRANSACTION_LINES';
  l_counter             NUMBER := 0;
  l_transaction_rec     transaction_temp_rec_type;
  l_transaction_action_id NUMBER := 0;

BEGIN
        x_return_status := fnd_api.g_ret_sts_unexp_error;

        OPEN c_transaction_lines(p_header_id, p_transaction_action_id);
        LOOP
                FETCH c_transaction_lines INTO l_transaction_rec;
                EXIT WHEN c_transaction_lines%NOTFOUND;
                l_counter := l_counter + 1;
                x_transaction_tbl(l_counter) := l_transaction_rec;
        END LOOP;
        CLOSE c_transaction_lines;
        x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
        WHEN OTHERS THEN
           IF (c_transaction_lines%ISOPEN) THEN
              CLOSE c_transaction_lines;
           END IF;
           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_package_name, l_routine_name);
           END IF;

END get_transaction_lines;





-- ---------------------------------------------------------------------------
--
-- FUNCTION validate_txn_line_against_rsv
--
--
--   Internal helper
-- HISTORY
-- 02-MAR-2006  spondalu  ER 4163405: Included lot-checking when comparing
--                        transaction line against reservation line. Removed
--                        Error WIP_OVER_RETURN since if pri_qty > rsv_qty,
--                        then the difference could be from free on-hand.
-- ---------------------------------------------------------------------------
FUNCTION validate_txn_line_against_rsv(
        p_transaction_rec       IN  transaction_temp_rec_type,
        p_reservation_rec       IN  inv_reservation_global.mtl_reservation_rec_type,
        p_transaction_type      IN  NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_query_reservation     OUT NOCOPY VARCHAR2 )
                                RETURN BOOLEAN IS

  l_routine_name        VARCHAR2(30) := 'VALIDATE_TXN_LINE_AGAINST_RSV';
  l_oe_header_id                NUMBER;
  l_so_type                     NUMBER;
  l_reservation_rec             inv_reservation_global.mtl_reservation_rec_type;
  l_requirement_date            DATE;
  l_primary_uom_code            VARCHAR2(3);
  l_primary_open_quantity       NUMBER;
  l_line_id                     NUMBER;
  l_msg_count                   NUMBER;
  l_dummy_sn                    INV_Reservation_Global.Serial_Number_Tbl_Type;
  l_return_status                 varchar2(1);
  l_api_return_status             varchar2(1);
  l_msg_data            VARCHAR(2000);
  x_msg_count           NUMBER;
  x_msg_data            VARCHAR(2000);
  l_quantity_reserved           NUMBER;
  l_reservation_id              NUMBER;
  l_reservation_tbl     inv_reservation_global.mtl_reservation_tbl_type;
  l_rsv_tbl_count       NUMBER;
  l_error_code          NUMBER;




BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
        x_query_reservation := 'N';


        IF (p_transaction_rec.demand_source_header_id IS NOT NULL) THEN
           IF (p_transaction_type = WIP_CONSTANTS.WASSY_COMPLETION AND
              ((p_transaction_rec.demand_source_header_id <> p_reservation_rec.demand_source_header_id) or
               (p_transaction_rec.demand_source_line_id <> p_reservation_rec.demand_source_line_id) or
               (p_transaction_rec.wip_entity_id <> nvl(p_reservation_rec.supply_source_header_id,-1)) or
               (p_transaction_rec.lot_control_code = WIP_CONSTANTS.LOT AND /* ER 4163405 */
                p_transaction_rec.lot_number <> p_reservation_rec.lot_number))) THEN
                RETURN FALSE;
           END IF;

           IF (p_transaction_type = WIP_CONSTANTS.WASSY_RETURN AND
              ((p_transaction_rec.demand_source_header_id <> p_reservation_rec.demand_source_header_id) or
               (p_transaction_rec.demand_source_line_id <> p_reservation_rec.demand_source_line_id) or
               (p_transaction_rec.lot_control_code = WIP_CONSTANTS.LOT AND  /* ER 4163405 */
                p_transaction_rec.lot_number <> p_reservation_rec.lot_number))) THEN
                RETURN FALSE;
           END IF;

           IF (p_transaction_rec.demand_source_line_id IS NULL) THEN
                RETURN FALSE;
           END IF;

           -- quantity is only checked when the transaction record has
           -- a sales order line specified.
           -- in the allocation case, quantity is not checked.

           IF (p_transaction_type = WIP_CONSTANTS.WASSY_COMPLETION
               AND p_transaction_rec.primary_quantity >
                   p_reservation_rec.primary_reservation_quantity) THEN

               -- Check for overcompletion tolerance.
               -- If allowed , get details from MMTT record p_transaction_rec . ( Make sure that all details are present)
               --                call create_reservations
               --                call query_reservation and populate reservation pl/sql table.


           -- first determine if the sales order is an internal order

           inv_salesorder.get_oeheader_for_salesorder(p_transaction_rec.demand_source_header_id,
                                                      l_oe_header_id,
                                                      x_return_status);
           IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
             RAISE fnd_api.g_exc_error;
           END IF;

           SELECT  source_document_type_id
           INTO    l_so_type
           FROM    oe_order_headers_all
           WHERE   header_id = l_oe_header_id;


           ----------------------------------
           -- Get sales order open quantity
           ----------------------------------

           BEGIN

                -- we shouldn't be locking oe_order_lines_all directly
                -- this is tempoary until ONT provides a locking api
                SELECT  line_id
                INTO    l_line_id
                FROM    oe_order_lines_all
                WHERE   line_id = p_transaction_rec.demand_source_line_id ;
                -- FOR UPDATE;


                SELECT  requirement_date,
                        primary_uom_code,
                        primary_open_quantity
                INTO    l_requirement_date,
                        l_primary_uom_code,
                        l_primary_open_quantity
                FROM    wip_open_demands_v
                WHERE   organization_id = p_transaction_rec.organization_id
                        AND inventory_item_id = p_transaction_rec.inventory_item_id
                        AND demand_source_header_id
                            = p_transaction_rec.demand_source_header_id
                        AND demand_source_line_id
                            = p_transaction_rec.demand_source_line_id;
                --FOR UPDATE;
           EXCEPTION
                -- when there is more than one row, this an internal error.
                -- open demand should be uniquely identified by a demand_source_line_id
                -- WHEN TOO_MANY_ROWS THEN
                -- where there is no row returned, the demand information specified
                -- in the form is incorrect.  error out and provide a good explanation
                -- to the user.
                WHEN NO_DATA_FOUND THEN
                   fnd_message.set_name('WIP', 'WIP_INVALID_SO');
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;

           END;

           l_reservation_rec.requirement_date := l_requirement_date ;
           l_reservation_rec.organization_id := p_transaction_rec.organization_id;
           l_reservation_rec.inventory_item_id := p_transaction_rec.inventory_item_id;

           IF (l_so_type = 10) THEN
             l_reservation_rec.demand_source_type_id := inv_reservation_global.g_source_type_internal_ord;
           ELSE
             l_reservation_rec.demand_source_type_id := inv_reservation_global.g_source_type_oe;
           END IF;

           l_reservation_rec.demand_source_name := NULL;
           l_reservation_rec.demand_source_delivery := NULL;
           l_reservation_rec.demand_source_header_id := p_transaction_rec.demand_source_header_id;
           l_reservation_rec.demand_source_line_id := p_transaction_rec.demand_source_line_id;
           l_reservation_rec.primary_uom_code := l_primary_uom_code;
           l_reservation_rec.primary_uom_id := NULL;
           l_reservation_rec.reservation_uom_code := NULL;
           l_reservation_rec.reservation_uom_id := NULL;
           l_reservation_rec.reservation_quantity := NULL;
           l_reservation_rec.primary_reservation_quantity :=  p_transaction_rec.primary_quantity -
                                                                       p_reservation_rec.primary_reservation_quantity;

           if ( p_reservation_rec.primary_reservation_quantity >0 ) then
            l_reservation_rec.primary_reservation_quantity :=  p_transaction_rec.primary_quantity;
          end if ;


           l_reservation_rec.detailed_quantity := NULL;
           l_reservation_rec.autodetail_group_id := NULL;
           l_reservation_rec.external_source_code := NULL;
           l_reservation_rec.external_source_line_id := NULL;
           l_reservation_rec.supply_source_type_id := inv_reservation_global.g_source_type_wip;
           l_reservation_rec.supply_source_header_id := p_transaction_rec.wip_entity_id;
           l_reservation_rec.supply_source_line_id := NULL;
           l_reservation_rec.supply_source_name := NULL;
           l_reservation_rec.supply_source_line_detail := NULL;
           l_reservation_rec.revision := p_transaction_rec.revision;
           l_reservation_rec.subinventory_code := NULL;
           l_reservation_rec.subinventory_id := NULL;
           l_reservation_rec.locator_id := NULL;
           l_reservation_rec.lot_number := p_transaction_rec.lot_number;
           l_reservation_rec.lot_number_id := NULL;
           l_reservation_rec.pick_slip_number := NULL;
           l_reservation_rec.lpn_id := NULL;
           l_reservation_rec.attribute_category := NULL;
           l_reservation_rec.attribute1 := NULL;
           l_reservation_rec.attribute2 := NULL;
           l_reservation_rec.attribute3 := NULL;
           l_reservation_rec.attribute4 := NULL;
           l_reservation_rec.attribute5 := NULL;
           l_reservation_rec.attribute6 := NULL;
           l_reservation_rec.attribute7 := NULL;
           l_reservation_rec.attribute8 := NULL;
           l_reservation_rec.attribute9 := NULL;
           l_reservation_rec.attribute10 := NULL;
           l_reservation_rec.attribute11 := NULL;
           l_reservation_rec.attribute12 := NULL;
           l_reservation_rec.attribute13 := NULL;
           l_reservation_rec.attribute14 := NULL;
           l_reservation_rec.attribute15 := NULL;
           l_reservation_rec.ship_ready_flag := NULL;

           if ( p_reservation_rec.primary_reservation_quantity >0 ) then

               INV_Reservation_PUB.Update_Reservation
                   (
                    p_api_version_number        => 1.0
                    , p_init_msg_lst              => fnd_api.g_false
                    , x_return_status             => l_api_return_status
                    , x_msg_count                 => l_msg_count
                    , x_msg_data                  => l_msg_data
                    , p_original_rsv_rec          => p_reservation_rec
                    , p_to_rsv_rec                => l_reservation_rec
                    , p_original_serial_number    => l_dummy_sn
                    , p_to_serial_number          => l_dummy_sn
                    , p_validation_flag           => fnd_api.g_true
                    );
                 IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
                    FND_MESSAGE.SET_NAME('INV','INV_UPD_RSV_FAILED');
                    FND_MSG_PUB.Add;
                    RAISE fnd_api.g_exc_unexpected_error;
                 END IF ;
           else

                inv_reservation_pub.create_reservation(
                        p_api_version_number        => 1.0,
                        p_init_msg_lst              => fnd_api.g_false,
                        x_return_status             => l_return_status,
                        x_msg_count                 => l_msg_count,
                        x_msg_data                  => l_msg_data,
                        p_rsv_rec                   => l_reservation_rec,
                        p_serial_number             => l_dummy_sn,
                        x_serial_number             => l_dummy_sn,
                        p_partial_reservation_flag  => fnd_api.g_false,
                        p_force_reservation_flag    => fnd_api.g_false,
                        p_validation_flag           => fnd_api.g_true,
                        x_quantity_reserved         => l_quantity_reserved,
                        x_reservation_id            => l_reservation_id);


                IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                        x_msg_count := l_msg_count;
                        x_msg_data := l_msg_data;
                        x_return_status := l_return_status;
                        RAISE g_need_to_rollback_exception;
                END IF;
           END IF ;

/*              fnd_message.set_name('WIP', 'WIP_OVER_COMPLETE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_error; */
         x_query_reservation := 'Y';

           END IF;  -- check transaction type

/* fix for bug 1821610 */

        ELSE   /* demand_source_header_id  is NULL */

           IF  (p_reservation_rec.primary_reservation_quantity = 0)  THEN
              RETURN FALSE;
           END IF;


        END IF;  -- if p_transaction_rec_.demand_source_header_id IS NOT NULL


        IF (p_transaction_type = WIP_CONSTANTS.WASSY_COMPLETION
            and p_reservation_rec.subinventory_code IS NOT NULL
            and p_transaction_rec.subinventory_code <>
                p_reservation_rec.subinventory_code) THEN
           fnd_message.set_name('WIP', 'WIP_INVALID_SUBINV');
           fnd_message.set_token('TXN_SUB', p_transaction_rec.subinventory_code);
           fnd_message.set_token('SO_SUB', p_reservation_rec.subinventory_code);
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
        END IF;


        RETURN TRUE;
EXCEPTION
        WHEN fnd_api.g_exc_error THEN
           x_return_status := fnd_api.g_ret_sts_error;
           return FALSE;

        WHEN fnd_api.g_exc_unexpected_error THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           return FALSE;

        WHEN OTHERS THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_package_name, l_routine_name);
           END IF;
           return FALSE;

END validate_txn_line_against_rsv;


-- ---------------------------------------------------------------------------
--
-- PROCEDURE transfer_reservation
--
--   Internal helper
-- ---------------------------------------------------------------------------
PROCEDURE transfer_reservation(
        p_transaction_rec       IN  transaction_temp_rec_type,
        p_reservation_rec       IN  inv_reservation_global.mtl_reservation_rec_type,
        p_transaction_type      IN  NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2) IS

  l_routine_name        VARCHAR2(30) := 'TRANSFER_RESERVATION';
  l_to_reservation_rec  inv_reservation_global.mtl_reservation_rec_type;
  l_to_reservation_id   NUMBER;
  l_quantity            NUMBER;
  l_return_status       VARCHAR(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR(2000);
  l_original_serial_number inv_reservation_global.serial_number_tbl_type;
  l_to_serial_number    inv_reservation_global.serial_number_tbl_type;
  l_wip_cfg_rsv_level   NUMBER;

BEGIN
  IF(p_transaction_type = WIP_CONSTANTS.WASSY_COMPLETION) THEN
    l_quantity := p_transaction_rec.primary_quantity;

    l_to_reservation_rec.supply_source_type_id :=
      inv_reservation_global.g_source_type_inv;
    l_to_reservation_rec.supply_source_header_id := p_transaction_rec.wip_entity_id;
    l_to_reservation_rec.supply_source_line_id := NULL;
    l_to_reservation_rec.supply_source_name := NULL;
    l_to_reservation_rec.supply_source_line_detail := NULL;
    l_to_reservation_rec.lot_number := p_transaction_rec.lot_number;

    -- 3115629  Read the profile and set the values of subinventory / locator
    l_wip_cfg_rsv_level := fnd_profile.value('WIP:CONFIGURATION_RESERVATION_LEVEL');
    IF(l_wip_cfg_rsv_level is null) then
      l_wip_cfg_rsv_level := 2;
    END IF;

    IF(l_wip_cfg_rsv_level = 2) then
      l_to_reservation_rec.subinventory_code := p_transaction_rec.subinventory_code;
      l_to_reservation_rec.locator_id := p_transaction_rec.locator_id;
    END IF;

    -- Fixed Bug# 1821610. Populate item revision before calling inventory api.
    l_to_Reservation_rec.revision := p_transaction_rec.revision;

    --for lpn completions
    l_to_reservation_rec.lpn_id := p_transaction_rec.lpn_id;
  ELSE
    l_quantity := - p_transaction_rec.primary_quantity;

    l_to_reservation_rec.supply_source_type_id :=
      inv_reservation_global.g_source_type_wip;
    /* Fix for bug 4236074: The following line was commented in 115.8. Uncommented this  */
    l_to_reservation_rec.supply_source_header_id := p_transaction_rec.wip_entity_id;
    l_to_reservation_rec.supply_source_line_id := NULL;
    l_to_reservation_rec.supply_source_name := NULL;
    l_to_reservation_rec.supply_source_line_detail := NULL;
    l_to_reservation_rec.lot_number := NULL;
    l_to_reservation_rec.subinventory_code := NULL;
    l_to_reservation_rec.locator_id := NULL;
  END IF;

  IF(l_quantity > p_reservation_rec.primary_reservation_quantity) THEN
    l_to_reservation_rec.primary_reservation_quantity :=
      p_reservation_rec.primary_reservation_quantity;
  ELSE
    l_to_reservation_rec.primary_reservation_quantity := l_quantity;
  END IF;

  inv_reservation_pub.transfer_reservation(
    p_api_version_number => 1.0,
    p_init_msg_lst       => fnd_api.g_false,
    x_return_status      => l_return_status,
    x_msg_count          => l_msg_count,
    x_msg_data           => l_msg_data,
    p_is_transfer_supply => fnd_api.g_true,
    p_original_rsv_rec   => p_reservation_rec,
    p_to_rsv_rec         => l_to_reservation_rec,
    p_original_serial_number => l_original_serial_number,
    p_to_serial_number   => l_to_serial_number,
    p_validation_flag    => fnd_api.g_true,
    x_to_reservation_id     => l_to_reservation_id);

  IF(l_return_status <> fnd_api.g_ret_sts_success) THEN
    x_return_status := l_return_status;
    RETURN;
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(g_package_name, l_routine_name);
    END IF;

END transfer_reservation;


-- ---------------------------------------------------------------------------
--
-- PROCEDURE make_callback_to_workflow
--  make callback to workflow when the first reservation to the order line is
--  created(p_type = 'FIRST') or when the last reservation to the order line
--  is deleted(p_type = 'LAST')
--
--  Internal helper
-- ---------------------------------------------------------------------------
PROCEDURE make_callback_to_workflow(
        p_organization_id       IN      NUMBER,
        p_inventory_item_id     IN      NUMBER,
        p_order_line_id         IN      NUMBER,
        p_type                  IN      VARCHAR2,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2)
IS
        l_api_name CONSTANT VARCHAR2(40)   := 'Make_Callback_To_Workflow';
        IS_ATO_ITEM     VARCHAR(2);
        cnt             NUMBER;
BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        select msi.replenish_to_order_flag into IS_ATO_ITEM
        from mtl_system_items msi
        where   msi.organization_id = p_organization_id
        and     msi.inventory_item_id = p_inventory_item_id;

        if (IS_ATO_ITEM = 'Y') then
                if (p_type = 'FIRST') then
                        -- test if this is the first reservation
                        -- if yes, then
                        select count(*) into cnt
                        from mtl_reservations
                        where demand_source_line_id = p_order_line_id;

                        if (cnt = 1) then
                                CTO_WIP_WORKFLOW_API_PK.first_wo_reservation_created(
                                p_order_line_id,
                                x_return_status,
                                x_msg_count,
                                x_msg_data);
                        end if;
                elsif (p_type = 'LAST') then
                        -- test if this is the last reservation
                        -- if yes then
                        select count(*) into cnt
                        from mtl_reservations
                        where demand_source_line_id = p_order_line_id;

                        if (cnt = 0) then
                                CTO_WIP_WORKFLOW_API_PK.last_wo_reservation_deleted(
                                p_order_line_id,
                                x_return_status,
                                x_msg_count,
                                x_msg_data);
                        end if;
                end if;
        end if;

EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(g_package_name, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );

END make_callback_to_workflow;

PROCEDURE respond_to_change_order (
        p_org_id                IN      NUMBER,
        p_header_id             IN      NUMBER,
        p_line_id               IN      NUMBER,
        x_status                OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2)
IS
        l_response_code         NUMBER;
        l_wip_entity_id         NUMBER;

        cursor l_always_cursor IS
           SELECT wip_entity_id
           FROM wip_discrete_jobs wdj
           WHERE wdj.organization_id = p_org_id
           AND wdj.status_type IN (WIP_CONSTANTS.UNRELEASED, WIP_CONSTANTS.RELEASED,
                                   WIP_CONSTANTS.COMP_CHRG)
           AND wdj.wip_entity_id IN (SELECT wip_entity_id
                                  FROM wip_reservations_v
                                  WHERE demand_source_line_id = p_line_id
                                  AND demand_source_header_id = p_header_id
                                  AND organization_id = p_org_id);

        -- Bug 4890958
        -- Perf Fix for SQL Rep ID 15027638
        -- ntungare Wed May 24 22:19:14 PDT 2006
        --
        /*
        cursor l_1to1_cursor IS
           SELECT wip_entity_id
           FROM wip_discrete_jobs wdj
           WHERE wdj.organization_id = p_org_id
           AND wdj.status_type IN (WIP_CONSTANTS.UNRELEASED, WIP_CONSTANTS.RELEASED,
                                   WIP_CONSTANTS.COMP_CHRG)
           AND wdj.wip_entity_id IN (SELECT wip_entity_id
                                  FROM wip_reservations_v
                                  WHERE demand_source_line_id = p_line_id
                                  AND demand_source_header_id = p_header_id
                                  AND organization_id = p_org_id)
           AND NOT EXISTS (SELECT 1
                           FROM wip_reservations_v wrv1
                           WHERE wrv1.demand_source_line_id = p_line_id
                           AND wrv1.demand_source_header_id = p_header_id
                           AND ((wrv1.organization_id <> p_org_id)
                                OR (wrv1.wip_entity_id <> wdj.wip_entity_id)))
           AND NOT EXISTS (SELECT 1
                           FROM wip_reservations_v wrv2
                           WHERE wrv2.wip_entity_id = wdj.wip_entity_id
                           AND wrv2.organization_id = wdj.organization_id
                           AND ((wrv2.demand_source_header_id <> p_header_id)
                                OR  (wrv2.demand_source_line_id <> p_line_id)));
         */

         Cursor l_1to1_cursor IS
            SELECT wdj.wip_entity_id
            FROM wip_discrete_jobs wdj, wip_reservations_v wrv
            WHERE wdj.organization_id = p_org_id
              AND wdj.organization_id = wrv.organization_id
              AND wdj.status_type IN (WIP_CONSTANTS.UNRELEASED,
                                      WIP_CONSTANTS.RELEASED,
                                      WIP_CONSTANTS.COMP_CHRG)
              AND wdj.wip_entity_id = wrv.wip_entity_id
              AND wrv.demand_source_line_id = p_line_id
              AND wrv.demand_source_header_id = p_header_id
              AND NOT EXISTS  (SELECT 1
                               FROM wip_reservations_v wrv1
                               WHERE (wrv1.demand_source_line_id = p_line_id AND
                                      wrv1.demand_source_header_id = p_header_id AND
                                      (wrv1.organization_id <> p_org_id OR
                                       wrv1.wip_entity_id <> wdj.wip_entity_id))
                                     OR
                                     (wrv1.wip_entity_id = wdj.wip_entity_id AND
                                      wrv1.organization_id = wdj.organization_id AND
                                      (wrv1.demand_source_header_id <> p_header_id OR
                                       wrv1.demand_source_line_id <> p_line_id)));

BEGIN
  -- get the response_code from WIP_PARAMETERS TABLE
  SELECT so_change_response_type
  INTO l_response_code
  FROM wip_parameters
  WHERE organization_id = p_org_id;

  IF (l_response_code = WIP_CONSTANTS.NEVER) THEN
    x_status := fnd_api.g_ret_sts_success;
    RETURN;  -- reponse type is never

  ELSIF (l_response_code = WIP_CONSTANTS.ALWAYS) THEN
    OPEN l_always_cursor;  -- response type is always

  ELSE
    OPEN l_1to1_cursor;  -- response type is when linked 1-1
  END IF;

  LOOP
    IF (l_response_code = WIP_CONSTANTS.ALWAYS) THEN
      FETCH l_always_cursor INTO
                l_wip_entity_id;
      EXIT WHEN l_always_cursor%NOTFOUND;
    ELSE
      FETCH l_1to1_cursor INTO
                l_wip_entity_id;
      EXIT WHEN l_1to1_cursor%NOTFOUND;
    END IF;


    -- call procedure to put the Job on Hold and release it if needed
    WIP_CHANGE_STATUS.PUT_JOB_ON_HOLD(l_wip_entity_id, p_org_id);

  END LOOP;

  -- set any job still in the wip interface to status hold
  UPDATE wip_job_schedule_interface
  SET status_type = WIP_CONSTANTS.HOLD,
      last_update_date = SYSDATE
  WHERE organization_id = p_org_id
    AND source_code = 'WICDOL'
    AND source_line_id = p_line_id;

  IF (l_response_code = WIP_CONSTANTS.ALWAYS) THEN
     CLOSE l_always_cursor;
  ELSE
     CLOSE l_1to1_cursor;
  END IF;
  x_status := fnd_api.g_ret_sts_success;

EXCEPTION
  WHEN others THEN
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  x_status := fnd_api.g_ret_sts_error;
  IF (l_response_code = WIP_CONSTANTS.ALWAYS) THEN
     CLOSE l_always_cursor;
  ELSE
     CLOSE l_1to1_cursor;
  END IF;


END respond_to_change_order;

/*3017570*/
-- ---------------------------------------------------------------------------
--
-- PROCEDURE get_move_transaction_lines
--
--      This procedure returns a table of move transaction records from
--      wip_move_txn_interface
--      Used to match with WIP reservation while processing scrap transactions.
--
--
--      Internal helper
-- ---------------------------------------------------------------------------

PROCEDURE get_move_transaction_lines (
        p_group_id              IN         NUMBER,
        p_wip_entity_id         IN         NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_move_transaction_tbl  OUT NOCOPY move_transaction_intf_tbl_type) IS

Cursor c_move_transaction_lines (p_group_id number, p_wip_entity_id number) is
select  wip_entity_id,
                transaction_id,
                transaction_type,
                organization_id,
                primary_item_id,
                fm_operation_seq_num,
                fm_intraoperation_step_type,
                to_operation_seq_num,
                to_intraoperation_step_type,
                primary_quantity,
                primary_uom,
                entity_type,
                repetitive_schedule_id,
                transaction_date
from            wip_move_txn_interface wmti
where           wmti.group_id = p_group_id
and             wmti.process_phase = 2
and             wmti.process_status = 2
and             wmti.wip_entity_id = p_wip_entity_id
order by transaction_id;


  l_routine_name        VARCHAR2(30) := 'GET_MOVE_TRANSACTION_LINES';
  l_counter             NUMBER := 0;
  l_move_transaction_rec     move_transaction_intf_rec_type;

BEGIN
        x_return_status := fnd_api.g_ret_sts_unexp_error;

/*        dbms_output.put_line ('inside get_move_transaction_lines');
        dbms_output.put_line ('p_wip_entity_id: '|| p_wip_entity_id);
          dbms_output.put_line ('p_group_id : '|| p_group_id); */

        OPEN c_move_transaction_lines(p_group_id, p_wip_entity_id);
        LOOP
--              dbms_output.put_line ('inside the loop');
                FETCH c_move_transaction_lines INTO l_move_transaction_rec;
                EXIT WHEN c_move_transaction_lines%NOTFOUND;
                l_counter := l_counter + 1;
                x_move_transaction_tbl(l_counter) := l_move_transaction_rec;
        END LOOP;
        CLOSE c_move_transaction_lines;
        x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
        WHEN OTHERS THEN
           IF (c_move_transaction_lines%ISOPEN) THEN
              CLOSE c_move_transaction_lines;
           END IF;
           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_package_name, l_routine_name);
           END IF;

END get_move_transaction_lines;

-- ---------------------------------------------------------------------------
--
-- PROCEDURE scrap_txn_relieve_rsv
--
--      This procedure processes the scrap transactions in a batch
--      identified by group_id and modifies/deletes the reservations
--      from the discrete jobs in the descending order of requirement date.
--
--
--      Internal helper
-- ---------------------------------------------------------------------------

Procedure scrap_txn_relieve_rsv ( p_group_id      IN         NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2) is

--Bug   4744367:Added check on wmti.entity_type so that for lot based jobs
--scrap is not relieved.
Cursor wmti_disc_jobs (p_group_id number) is
select distinct         wdj.wip_entity_id,
                        wdj.organization_id,
                        wdj.primary_item_id,
                        wdj.start_quantity,
                        wdj.quantity_completed,
                        wdj.quantity_scrapped
from                    wip_move_txn_interface wmti, wip_discrete_jobs wdj
where             wmti.group_id = p_group_id
and                     wmti.wip_entity_id = wdj.wip_entity_id
and               wmti.organization_id = wdj.organization_id
and                     wmti.process_phase = 2
and                     wmti.process_status = 2
and                     nvl(wmti.entity_type,1) <> 5
order by wdj.wip_entity_id;

l_wip_entity_id                 Number;
l_organization_id                       Number;
l_primary_item_id                       Number;
l_job_start_quantity            Number;
l_quantity_scrapped             Number;
l_quantity_completed            Number;
l_job_reservation_quantity      Number;
l_return_status                 Varchar2(1);
l_move_transaction_tbl          move_transaction_intf_tbl_type;
l_job_unreserved_quantity     Number;
move_txn_count                  Number;
l_scrap_primary_txn_quantity  Number;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_routine_name        VARCHAR2(30) := 'SCRAP_TXN_RELIEVE_RSV' ;



Begin
        SAVEPOINT Relieve_Rsv_scrap_txn_sp;

        fnd_msg_pub.initialize;

    For current_job in wmti_disc_jobs(p_group_id)
    Loop
           l_wip_entity_id := current_job.wip_entity_id;
           l_organization_id := current_job.organization_id;
           l_primary_item_id := current_job.primary_item_id;
           l_job_start_quantity := current_job.start_quantity;
           l_quantity_scrapped := current_job.quantity_scrapped;
           l_quantity_completed := current_job.quantity_completed;

           select nvl(sum(primary_quantity),0)
         into   l_job_reservation_quantity
         from   wip_reservations_v
           where  wip_entity_id = l_wip_entity_id;
/*
           dbms_output.put_line ('wip_entity_id: '||l_wip_entity_id );
           dbms_output.put_line ('l_job_start_quantity : '||l_job_start_quantity  );
           dbms_output.put_line ('l_quantity_scrapped : '|| l_quantity_scrapped );
           dbms_output.put_line ('l_quantity_completed : '||l_quantity_completed );
           dbms_output.put_line ('l_job_reservation_quantity: '||l_job_reservation_quantity );
*/

           If (l_job_reservation_quantity > 0 ) then
            l_job_unreserved_quantity := Greatest(l_job_start_quantity - l_quantity_completed
                                    - l_quantity_scrapped - l_job_reservation_quantity, 0);

--            dbms_output.put_line ('l_job_unreserved_quantity: '||l_job_unreserved_quantity );


                get_move_transaction_lines(p_group_id    => p_group_id,
                                                   p_wip_entity_id => l_wip_entity_id,
                                       x_return_status => l_return_status,
                                                   x_move_transaction_tbl => l_move_transaction_tbl);

           If (l_return_status <> fnd_api.g_ret_sts_success) then
              If (l_return_status = fnd_api.g_ret_sts_error) then
                RAISE fnd_api.g_exc_error;
              Else
                RAISE fnd_api.g_exc_unexpected_error;
              End if;
           End if;

           move_txn_count := l_move_transaction_tbl.count;

--            dbms_output.put_line('transaction record count: '|| move_txn_count );

           For i in 1 .. move_txn_count
           Loop
                   If ((l_move_transaction_tbl(i).to_intraoperation_step_type = WIP_CONSTANTS.SCRAP) and
                   (l_move_transaction_tbl(i).to_intraoperation_step_type <> l_move_transaction_tbl(i).fm_intraoperation_step_type)) then
                   l_scrap_primary_txn_quantity := l_move_transaction_tbl(i).primary_quantity;

--                 dbms_output.put_line ('l_scrap_primary_txn_quantity : '|| l_scrap_primary_txn_quantity );

                   If ( l_job_unreserved_quantity > l_scrap_primary_txn_quantity ) then
                       l_job_unreserved_quantity := l_job_unreserved_quantity - l_scrap_primary_txn_quantity ;
                             l_scrap_primary_txn_quantity := 0;
                   Else
                       l_scrap_primary_txn_quantity := l_scrap_primary_txn_quantity - l_job_unreserved_quantity;
                       l_job_unreserved_quantity := 0;
                   End if;

--                       dbms_output.put_line ('after if condition --l_scrap_primary_txn_quantity : '|| l_scrap_primary_txn_quantity );

                   If (l_scrap_primary_txn_quantity > 0 ) then
                      Relieve_wip_reservation(  p_wip_entity_id                 => l_wip_entity_id,
                                                                p_organization_id       => l_organization_id,
                                                                p_inventory_item_id     => l_primary_item_id,
                                                                p_primary_quantity      => l_scrap_primary_txn_quantity,
                                                                x_return_status         => l_return_status,
                                                                x_msg_count                     => l_msg_count,
                                                                x_msg_data                      => l_msg_data );
                            If (l_return_status <> fnd_api.g_ret_sts_success) then
                              If (l_return_status = fnd_api.g_ret_sts_error) then
                            RAISE fnd_api.g_exc_error;
                              Else
                            RAISE fnd_api.g_exc_unexpected_error;
                              End if;
                          End if;
                   End if;
               End if;
           End Loop;
          End if;
   End Loop;
Exception
        WHEN g_need_to_rollback_exception THEN
          ROLLBACK TO SAVEPOINT Relieve_Rsv_scrap_txn_sp;

        WHEN fnd_api.g_exc_error THEN

           x_return_status := fnd_api.g_ret_sts_error;

           fnd_msg_pub.count_and_get(
                        p_encoded => fnd_api.g_false,
                        p_count   => x_msg_count,
                        p_data    => x_msg_data);

           ROLLBACK TO SAVEPOINT Relieve_Rsv_scrap_txn_sp;

        WHEN fnd_api.g_exc_unexpected_error THEN

           x_return_status := fnd_api.g_ret_sts_unexp_error;

           fnd_msg_pub.count_and_get(
                        p_encoded => fnd_api.g_false,
                        p_count   => x_msg_count,
                        p_data    => x_msg_data);

           ROLLBACK TO SAVEPOINT Relieve_Rsv_scrap_txn_sp;

        WHEN OTHERS THEN

           x_return_status := fnd_api.g_ret_sts_unexp_error;
           IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
                fnd_msg_pub.add_exc_msg (
                                g_package_name,
                                l_routine_name);
           END IF;

           fnd_msg_pub.count_and_get(
                        p_encoded => fnd_api.g_false,
                        p_count   => x_msg_count,
                        p_data    => x_msg_data);

           ROLLBACK TO SAVEPOINT Relieve_Rsv_scrap_txn_sp;

End scrap_txn_relieve_rsv;

-- ---------------------------------------------------------------------------
--
-- PROCEDURE Relieve_wip_reservation
--
--      This procedure modifies/deletes the reservations
--      from the discrete jobs in the descending order of requirement date.
--      Internal helper
-- ---------------------------------------------------------------------------

PROCEDURE Relieve_wip_reservation(
        p_wip_entity_id       IN         Number,
        p_organization_id     IN         Number,
        p_inventory_item_id   IN         Number,
        p_primary_quantity    IN         Number,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2 ) IS

  l_routine_name                VARCHAR2(30) := 'RELIEVE_WIP_RESERVATION';
  l_quantity_to_be_relieved     Number;
  l_reservation_rec             inv_reservation_global.mtl_reservation_rec_type;
  l_reservation_tbl             inv_reservation_global.mtl_reservation_tbl_type;
  l_rsv_tbl_count               NUMBER;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_to_reservation_rec          inv_reservation_global.mtl_reservation_rec_type;
  l_error_code                  NUMBER;
  l_line_reservation_quantity NUMBER;
  l_new_line_rsv_quantity       NUMBER;
  l_dummy_sn                    inv_reservation_global.serial_number_tbl_type;


BEGIN
      fnd_msg_pub.initialize;
      l_quantity_to_be_relieved := p_primary_quantity;

--      dbms_output.put_line('l_quantity_to_be_relieved : '||l_quantity_to_be_relieved );

      l_reservation_rec.organization_id := p_organization_id;
      l_reservation_rec.supply_source_header_id := p_wip_entity_id;
      l_reservation_rec.inventory_item_id := p_inventory_item_id;
      l_reservation_rec.supply_source_type_id := inv_reservation_global.g_source_type_wip;


        -- query reservations against this particular WIP job.
        -- tell API to lock rows in mtl_reservations.
        -- records are returned based on requirement date ascending.
        inv_reservation_pub.query_reservation(
                p_api_version_number        => 1.0,
                p_init_msg_lst              => fnd_api.g_false,
                x_return_status             => l_return_status,
                x_msg_count                 => l_msg_count,
                x_msg_data                  => l_msg_data,
                p_query_input               => l_reservation_rec,
                p_lock_records              => fnd_api.g_true,
                p_sort_by_req_date          => inv_reservation_global.g_query_req_date_desc,
                x_mtl_reservation_tbl       => l_reservation_tbl,
                x_mtl_reservation_tbl_count => l_rsv_tbl_count,
                x_error_code                => l_error_code);

        If (l_return_status <> fnd_api.g_ret_sts_success) then
           x_msg_count := l_msg_count;
           x_msg_data := l_msg_data;
           x_return_status := l_return_status;
           RAISE g_need_to_rollback_exception;
        End if;

--       dbms_output.put_line ('after query_reservation');
--       dbms_output.put_line ('l_rsv_tbl_count : '|| l_rsv_tbl_count );
        For j in 1 .. l_rsv_tbl_count
        Loop
           l_line_reservation_quantity := l_reservation_tbl(j).primary_reservation_quantity;

--           dbms_output.put_line ('l_line_reservation_quantity  :'|| l_line_reservation_quantity );
           If ( l_quantity_to_be_relieved >= l_line_reservation_quantity ) then
              --delete the reservation
--              dbms_output.put_line ('about to delete the reservation');
                inv_reservation_pub.delete_reservation(
                  p_api_version_number    => 1.0,
                    p_init_msg_lst          => fnd_api.g_false,
                        x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data,
                            p_rsv_rec               => l_reservation_tbl(j),
                      p_serial_number       => l_dummy_sn);

              If (l_return_status <> fnd_api.g_ret_sts_success) then
                   x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;
                   x_return_status := l_return_status;
             RAISE g_need_to_rollback_exception;
              End if;

              l_quantity_to_be_relieved := l_quantity_to_be_relieved - l_line_reservation_quantity ;
           Else
              l_new_line_rsv_quantity := l_line_reservation_quantity - l_quantity_to_be_relieved ;
              l_quantity_to_be_relieved := 0;
              -- update the reservation
              l_to_reservation_rec := l_reservation_tbl(j);
              l_to_reservation_rec.primary_reservation_quantity := l_new_line_rsv_quantity;
                inv_reservation_pub.update_reservation(
                  p_api_version_number          => 1.0,
                    p_init_msg_lst              => fnd_api.g_false,
                        x_return_status                 => l_return_status,
                  x_msg_count                   => l_msg_count,
                    x_msg_data                  => l_msg_data,
                            p_original_rsv_rec          => l_reservation_tbl(j),
                      p_to_rsv_rec              => l_to_reservation_rec,
                      p_original_serial_number  => l_dummy_sn,
                            p_to_serial_number          => l_dummy_sn,
                            p_validation_flag           => fnd_api.g_true);
              If (l_return_status <> fnd_api.g_ret_sts_success) then
                   x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;
                   x_return_status := l_return_status;
             RAISE g_need_to_rollback_exception;
              End if;
           End if;

           If (l_quantity_to_be_relieved = 0) then
              EXIT;
           End if;
        End loop;

        x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
        WHEN OTHERS THEN
           x_return_status := fnd_api.g_ret_sts_unexp_error;
           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_package_name, l_routine_name);
           END IF;
END Relieve_wip_reservation;

-- Fixed bug 5471890. Need to create PL/SQL wrapper when calling inventory
-- reservation API since some environment failed to compile if we try to
-- reference PL/SQL object from form directly.
PROCEDURE update_row(p_item_revision           IN VARCHAR2,
                     p_reservation_id          IN NUMBER,
                     p_requirement_date        IN DATE,
                     p_demand_source_header_id IN NUMBER,
                     p_demand_source_line_id   IN NUMBER,
                     p_primary_quantity        IN NUMBER,
                     p_wip_entity_id           IN NUMBER,
                     x_return_status           OUT NOCOPY VARCHAR2) IS

  l_msg_count  NUMBER;
  l_msg_data   VARCHAR2(240);
  l_dummy_sn   inv_reservation_global.serial_number_tbl_type;
  l_rsv_array  inv_reservation_global.mtl_reservation_tbl_type;
  l_size       NUMBER;
  l_error_code NUMBER;
BEGIN
  inv_reservation_form_pkg.query_reservation(
    p_api_version_number         => 1.0,
    p_reservation_id             => p_reservation_id,
    p_init_msg_lst               => fnd_api.g_true,
    p_lock_records               => fnd_api.g_true,
    p_sort_by_req_date           => 1 /* no sort */,
    p_cancel_order_mode          => 1,
    x_return_status              => x_return_status,
    x_msg_count                  => l_msg_count,
    x_msg_data                   => l_msg_data,
    x_mtl_reservation_tbl        => l_rsv_array,
    x_mtl_reservation_tbl_count  => l_size,
    x_error_code                 => l_error_code);

  IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  inv_reservation_form_pkg.update_reservation(
    p_api_version_number          => 1.0,
    p_init_msg_lst                => fnd_api.g_true,
    p_from_reservation_id         => p_reservation_id,
    p_from_requirement_date       => NULL,
    p_from_organization_id        => NULL,
    p_from_inventory_item_id      => NULL,
    p_from_demand_type_id         => NULL,
    p_from_demand_name            => NULL,
    p_from_demand_header_id       => NULL,
    p_from_demand_line_id         => NULL,
    p_from_primary_uom_code       => NULL,
    p_from_primary_uom_id         => NULL,
    p_from_reservation_uom_code   => NULL,
    p_from_reservation_uom_id     => NULL,
    p_from_reservation_quantity   => NULL,
    p_from_primary_rsv_quantity   => NULL,
    p_from_autodetail_group_id    => NULL,
    p_from_external_source_code   => NULL,
    p_from_external_source_line   => NULL,
    p_from_supply_type_id         => NULL,
    p_from_supply_header_id       => NULL,
    p_from_supply_line_id         => NULL,
    p_from_supply_name            => NULL,
    p_from_supply_line_detail     => NULL,
    p_from_revision               => NULL,
    p_from_subinventory_code      => NULL,
    p_from_subinventory_id        => NULL,
    p_from_locator_id             => NULL,
    p_from_lot_number             => NULL,
    p_from_lot_number_id          => NULL,
    p_from_pick_slip_number       => NULL,
    p_from_lpn_id                 => NULL,
    p_from_ship_ready_flag        => NULL,
    p_to_requirement_Date         => p_requirement_date,
    p_to_demand_type_id           => l_rsv_array(1).demand_source_type_id,
    p_to_demand_name              => l_rsv_array(1).demand_source_name,
    p_to_demand_header_id         => p_demand_source_header_id,
    p_to_demand_line_id           => p_demand_source_line_id,
    p_to_demand_delivery_id       => l_rsv_array(1).demand_source_delivery,
    p_to_reservation_uom_code     => l_rsv_array(1).reservation_uom_code,
    p_to_reservation_uom_id       => l_rsv_array(1).reservation_uom_id,
    p_to_reservation_quantity     => l_rsv_array(1).reservation_quantity,
    p_to_primary_rsv_quantity     => p_primary_quantity,
    p_to_autodetail_group_id      => l_rsv_array(1).autodetail_group_id,
    p_to_external_source_code     => l_rsv_array(1).external_source_code,
    p_to_external_source_line     => l_rsv_array(1).external_source_line_id,
    p_to_supply_type_id           => l_rsv_array(1).supply_source_type_id,
    p_to_supply_header_id         => p_wip_entity_id,
    p_to_supply_line_id           => l_rsv_array(1).supply_source_line_id,
    p_to_supply_name              => l_rsv_array(1).supply_source_name,
    p_to_supply_line_detail       => l_rsv_array(1).supply_source_line_detail,
    p_to_revision                 => p_item_revision,
    p_to_subinventory_code        => l_rsv_array(1).subinventory_code,
    p_to_subinventory_id          => l_rsv_array(1).subinventory_id,
    p_to_locator_id               => l_rsv_array(1).locator_id,
    p_to_lot_number               => l_rsv_array(1).lot_number,
    p_to_lot_number_id            => l_rsv_array(1).lot_number_id,
    p_to_pick_slip_number         => l_rsv_array(1).pick_slip_number,
    p_to_lpn_id                   => l_rsv_array(1).lpn_id,
    p_to_ship_ready_flag          => l_rsv_array(1).ship_ready_flag,
    p_to_attribute_category       => l_rsv_array(1).attribute_category,
    p_to_attribute1               => l_rsv_array(1).attribute1,
    p_to_attribute2               => l_rsv_array(1).attribute2,
    p_to_attribute3               => l_rsv_array(1).attribute3,
    p_to_attribute4               => l_rsv_array(1).attribute4,
    p_to_attribute5               => l_rsv_array(1).attribute5,
    p_to_attribute6               => l_rsv_array(1).attribute6,
    p_to_attribute7               => l_rsv_array(1).attribute7,
    p_to_attribute8               => l_rsv_array(1).attribute8,
    p_to_attribute9               => l_rsv_array(1).attribute9,
    p_to_attribute10              => l_rsv_array(1).attribute10,
    p_to_attribute11              => l_rsv_array(1).attribute11,
    p_to_attribute12              => l_rsv_array(1).attribute12,
    p_to_attribute13              => l_rsv_array(1).attribute13,
    p_to_attribute14              => l_rsv_array(1).attribute14,
    p_to_attribute15              => l_rsv_array(1).attribute15,
    p_validation_flag             => fnd_api.g_true,
    /* Changes for Inventory */
    p_from_serial_number_tbl      => l_dummy_sn,
    p_from_crossDock_flag         => NULL,
    p_to_serial_number_tbl        => l_dummy_sn,
    p_to_crossDock_flag           => NULL,
    /* End of Changes */
    x_return_status               => x_return_status,
    x_msg_count                   => l_msg_count,
    x_msg_data                    => l_msg_data);

  IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
    raise fnd_api.g_exc_unexpected_error;
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
END update_row;

PROCEDURE lock_row(p_reservation_id               IN NUMBER,
                   x_reservation_id               OUT NOCOPY NUMBER,
                   x_supply_source_header_id      OUT NOCOPY NUMBER,
                   x_organization_id              OUT NOCOPY NUMBER,
                   x_demand_source_header_id      OUT NOCOPY NUMBER,
                   x_primary_reservation_quantity OUT NOCOPY NUMBER,
                   x_demand_source_line_id        OUT NOCOPY NUMBER,
                   x_size                         OUT NOCOPY NUMBER,
                   x_return_status                OUT NOCOPY VARCHAR2) IS

  l_msg_count  NUMBER;
  l_msg_data   VARCHAR2(240);
  l_rsv_array  inv_reservation_global.mtl_reservation_tbl_type;
  l_error_code NUMBER;
BEGIN
  inv_reservation_form_pkg.query_reservation(
    p_api_version_number         => 1.0,
    p_reservation_id             => p_reservation_id,
    p_init_msg_lst               => fnd_api.g_true,
    p_lock_records               => fnd_api.g_true,
    p_sort_by_req_date           => 1 /* no sort */,
    p_cancel_order_mode          => 1,
    x_return_status              => x_return_status,
    x_msg_count                  => l_msg_count,
    x_msg_data                   => l_msg_data,
    x_mtl_reservation_tbl        => l_rsv_array,
    x_mtl_reservation_tbl_count  => x_size,
    x_error_code                 => l_error_code);

  -- Set OUT parameters
  x_reservation_id               := l_rsv_array(1).reservation_id;
  x_supply_source_header_id      := l_rsv_array(1).supply_source_header_id;
  x_organization_id              := l_rsv_array(1).organization_id;
  x_demand_source_header_id      := l_rsv_array(1).demand_source_header_id;
  x_primary_reservation_quantity := l_rsv_array(1).primary_reservation_quantity;
  x_demand_source_line_id        := l_rsv_array(1).demand_source_line_id;

END lock_row;

END WIP_SO_RESERVATIONS;

/
