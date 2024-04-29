--------------------------------------------------------
--  DDL for Package Body INV_RCV_STD_INSPECT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_STD_INSPECT_APIS" AS
/* $Header: INVSTDIB.pls 120.9.12010000.5 2009/08/21 11:03:50 avuppala ship $ */

/*
** -------------------------------------------------------------------------
** Function:    main_process
** Description:
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**
** Returns:
** --------------------------------------------------------------------------
*/
g_pkg_name CONSTANT VARCHAR2(30) := 'INV_RCV_STD_INSPECT_APIS';

g_to_be_inspected  	CONSTANT NUMBER := 1;
g_accept   		CONSTANT NUMBER := 2;
g_reject   		CONSTANT NUMBER := 3;

g_inspection_routing 	CONSTANT NUMBER := 2;

-- From mfg_lookups,
-- lookup_type = WMS_LPN_CONTEXT
-- lookup_code = 3
-- meaning     = Resides in Receiving
g_resides_in_receiving  CONSTANT NUMBER := 3;

g_interface_transaction_id NUMBER;

PROCEDURE print_debug(p_err_msg VARCHAR2,
                      p_level 	NUMBER)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
     (p_err_msg 	=> p_err_msg,
      p_module 		=> g_pkg_name||'($Revision: 120.9.12010000.5 $)',
      p_level 		=> p_level);
   END IF;

--   dbms_output.put_line(p_err_msg);
END print_debug;

  /* FP-J Lot/Serial Support Enhancement
   * Helper routine to create interface records for the inspected lot number
   * (in MTL_TRANSACTION_LOT_NUMBERS) and/or the inspected serial number (in
   * MTL_SERIAL_NUMBERS_INTERFACE) if the item is lot and/or serial controlled.
   * The interface records created here would be used by the receiving TM to
   * update the receiving onhand for the lots and serials (RCV_LOTS_SUPPLY and
   * RCV_SERIALS_SUPPLY)
   */
  PROCEDURE process_lot_serial_intf(
      x_return_status           OUT NOCOPY  VARCHAR2
    , x_msg_count               OUT NOCOPY  NUMBER
    , x_msg_data                OUT NOCOPY  VARCHAR2
    , p_organization_id         IN          NUMBER
    , p_inventory_item_id       IN          NUMBER
    , p_lot_control_code        IN          NUMBER
    , p_serial_control_code     IN          NUMBER
    , p_lot_number              IN          VARCHAR2
    , p_txn_qty                 IN          NUMBER
    , p_primary_qty             IN          NUMBER
    , p_serial_number           IN          VARCHAR2
    , p_product_transaction_id  IN          NUMBER
    , p_lpn_id                  IN          NUMBER
    , p_sec_txn_qty             IN          NUMBER --OPM Convergence
    ) IS

    l_txn_if_id             NUMBER;
    l_serial_temp_id        NUMBER;
    l_lot_status_id         NUMBER;
    l_serial_status_id      NUMBER;
    l_lot_expiration_date   DATE;
    l_prod_code             VARCHAR2(5) := inv_rcv_integration_apis.G_PROD_CODE;
    l_product_txn_id        NUMBER;
    l_yes                   VARCHAR2(1) := inv_rcv_integration_apis.G_YES;
    l_no                    VARCHAR2(1) := inv_rcv_integration_apis.G_NO;
    l_false                 VARCHAR2(1) := inv_rcv_integration_apis.G_FALSE;
    l_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_is_rma                NUMBER;

    l_origination_type number;--OPM Convergence
    l_expiration_action_code VARCHAR2(32);--OPM Convergence
    l_expiration_action_date DATE;--OPM Convergence
    l_hold_date DATE;--OPM Convergence
    l_reason_id  number;--OPM Convergence
  BEGIN

    --Initialize the return status
    x_return_status := fnd_api.g_ret_sts_success;

    l_product_txn_id := p_product_transaction_id;

    --First create the MTLI record for the lot that was inspected
    IF (p_lot_control_code > 1 AND p_lot_number IS NOT NULL) THEN
      SELECT  expiration_date
            , status_id
            , origination_type --OPM Convergence
            , expiration_action_code --OPM Convergence
            , expiration_action_date --OPM Convergence
            , hold_date --OPM Convergence
      INTO    l_lot_expiration_date
            , l_lot_status_id
            , l_origination_type --OPM Convergence
            , l_expiration_action_code --OPM Convergence
            , l_expiration_action_date --OPM Convergence
            , l_hold_date --OPM Convergence
      FROM    mtl_lot_numbers
      WHERE   lot_number = p_lot_number
      AND     inventory_item_id = p_inventory_item_id
      AND     organization_id = p_organization_id;

      --Call the insert_mtli API
      inv_rcv_integration_apis.insert_mtli(
            p_api_version                 =>  1.0
          , p_init_msg_lst                =>  l_false
          , x_return_status               =>  x_return_status
          , x_msg_count                   =>  x_msg_count
          , x_msg_data                    =>  x_msg_data
          , p_transaction_interface_id    =>  l_txn_if_id
          , p_lot_number                  =>  p_lot_number
          , p_transaction_quantity        =>  p_txn_qty
          , p_primary_quantity            =>  p_primary_qty
          , p_organization_id             =>  p_organization_id
          , p_inventory_item_id           =>  p_inventory_item_id
          , p_expiration_date             =>  l_lot_expiration_date
          , p_status_id                   =>  l_lot_status_id
          , x_serial_transaction_temp_id  =>  l_serial_temp_id
          , p_product_transaction_id      =>  l_product_txn_id
          , p_product_code                =>  l_prod_code
          , p_att_exist                   =>  l_yes
          , p_update_mln                  =>  l_no
          , p_origination_type            => l_origination_type--OPM Convergence
          , p_expiration_action_code      => l_expiration_action_code--OPM Convergence
          , p_expiration_action_date      => l_expiration_action_date--OPM Convergence
          , p_hold_date                   => l_hold_date);--OPM Convergence



      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('process_lot_serial_intf 1.1: Created MTLI record for lot: txn if: ' || l_txn_if_id || ', serial_temp_id: ' ||
            l_serial_temp_id || ', prod_txn_id: ' || l_product_txn_id , 4);
      END IF;

     --Bug #3405320
     --For items that are serial controlled at SO Issue, need to NULL out
     --serial_transaction_temp_id in the MTLI just generated (for split_lot_serial).
     --However, if there is a serial to be inspected, in which case the serial
     --number is passed, do not NULL out the serial_transaction_temp_id
      IF (p_serial_control_code = 6 AND p_serial_number IS NULL) THEN
  	    IF (l_debug = 1) THEN
  	    print_debug('process_lot_serial_intf 1.2: serial_control_code IS 6, need TO NULL OUT mtli', 4);
  	    END IF;

  	    UPDATE mtl_transaction_lots_interface
  	    SET  serial_transaction_temp_id = NULL
  	    WHERE product_transaction_id = l_product_txn_id
  	    AND   product_code = 'RCV';
  	  END IF; -- IF (l_is_rma = 1)
    END IF;   --END IF for a lot controlled item

    IF (p_serial_control_code > 1 AND p_serial_number IS NOT NULL) THEN
      --Get the serial status
      SELECT  status_id
      INTO    l_serial_status_id
      FROM    mtl_serial_numbers
      WHERE   serial_number = p_serial_number
      AND     inventory_item_id = p_inventory_item_id;

      --If the item is also lot controlled then set use the serial_transaction_temp_id
      --of the MTLI record to create the MSNI record
      IF (p_lot_control_code > 1 AND p_lot_number IS NOT NULL) THEN
        l_txn_if_id := l_serial_temp_id;
      END IF;

      --Call the insert_msni API
      inv_rcv_integration_apis.insert_msni(
            p_api_version                 =>  1.0
          , p_init_msg_lst                =>  l_false
          , x_return_status               =>  x_return_status
          , x_msg_count                   =>  x_msg_count
          , x_msg_data                    =>  x_msg_data
          , p_transaction_interface_id    =>  l_txn_if_id
          , p_fm_serial_number            =>  p_serial_number
          , p_to_serial_number            =>  p_serial_number
          , p_organization_id             =>  p_organization_id
          , p_inventory_item_id           =>  p_inventory_item_id
          , p_status_id                   =>  l_serial_status_id
          , p_product_transaction_id      =>  l_product_txn_id
          , p_product_code                =>  l_prod_code
          , p_att_exist                   =>  l_yes
          , p_update_msn                  =>  l_no);

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('process_lot_serial_intf 1.2: Created MSNI record for serial: ' ||  p_serial_number || ' with txn_if_id: '
            || l_txn_if_id || ', prod_txn_id: ' || l_product_txn_id , 4);
      END IF;
    END IF;   --END IF for a serial controlled item

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'process_lot_serial_intf');
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END process_lot_serial_intf;

  PROCEDURE main_process(
    x_return_status       OUT NOCOPY     VARCHAR2
  , x_msg_count           OUT NOCOPY     NUMBER
  , x_msg_data            OUT NOCOPY     VARCHAR2
  , p_inventory_item_id   IN             NUMBER
  , p_organization_id     IN             NUMBER
  , p_lpn_id              IN             NUMBER
  , p_revision            IN             VARCHAR2
  , p_lot_number          IN             VARCHAR2
  , p_uom_code            IN             VARCHAR2
  , p_quantity            IN             NUMBER
  , p_inspection_code     IN             VARCHAR2
  , p_quality_code        IN             VARCHAR2
  , p_transaction_type    IN             VARCHAR2
  , p_reason_id           IN             NUMBER
  , p_serial_number       IN             VARCHAR2
  , p_accept_lpn_id       IN             NUMBER
  , p_reject_lpn_id       IN             NUMBER
  , p_transaction_date    IN             DATE DEFAULT SYSDATE
  , p_qa_collection_id    IN             NUMBER DEFAULT NULL
  , p_vendor_lot          IN             VARCHAR2 DEFAULT NULL
  , p_comments            IN             VARCHAR2 DEFAULT NULL
  , p_attribute_category  IN             VARCHAR2 DEFAULT NULL
  , p_attribute1          IN             VARCHAR2 DEFAULT NULL
  , p_attribute2          IN             VARCHAR2 DEFAULT NULL
  , p_attribute3          IN             VARCHAR2 DEFAULT NULL
  , p_attribute4          IN             VARCHAR2 DEFAULT NULL
  , p_attribute5          IN             VARCHAR2 DEFAULT NULL
  , p_attribute6          IN             VARCHAR2 DEFAULT NULL
  , p_attribute7          IN             VARCHAR2 DEFAULT NULL
  , p_attribute8          IN             VARCHAR2 DEFAULT NULL
  , p_attribute9          IN             VARCHAR2 DEFAULT NULL
  , p_attribute10         IN             VARCHAR2 DEFAULT NULL
  , p_attribute11         IN             VARCHAR2 DEFAULT NULL
  , p_attribute12         IN             VARCHAR2 DEFAULT NULL
  , p_attribute13         IN             VARCHAR2 DEFAULT NULL
  , p_attribute14         IN             VARCHAR2 DEFAULT NULL
  , p_attribute15         IN             VARCHAR2 DEFAULT NULL
  , p_secondary_qty               IN  NUMBER      DEFAULT NULL) --OPM Convergence
   IS
    l_inventory_item_id      NUMBER         := p_inventory_item_id;
    l_organization_id        NUMBER         := p_organization_id;
    l_lpn_id                 NUMBER         := p_lpn_id;
    l_revision               VARCHAR2(10)   := p_revision;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number             VARCHAR2(80)   := p_lot_number;
    l_uom_code               VARCHAR2(5)    := p_uom_code;
    l_uom                    VARCHAR2(30);
    l_quantity               NUMBER         := p_quantity;
    l_serial_number          VARCHAR2(30)   := p_serial_number;
    l_accept_lpn_id          NUMBER         := p_accept_lpn_id;
    l_reject_lpn_id          NUMBER         := p_reject_lpn_id;
    l_rti_lpn_id             NUMBER;
    l_rti_transfer_lpn_id    NUMBER;
    l_inspection_code        VARCHAR2(25)   := p_inspection_code;
    l_quality_code           VARCHAR2(25)   := p_quality_code;
    l_transaction_date       DATE           := p_transaction_date;
    l_comments               VARCHAR2(240)  := p_comments;
    l_attribute_category     VARCHAR2(30)   := p_attribute_category;
    l_attribute1             VARCHAR2(150)  := p_attribute1;
    l_attribute2             VARCHAR2(150)  := p_attribute2;
    l_attribute3             VARCHAR2(150)  := p_attribute3;
    l_attribute4             VARCHAR2(150)  := p_attribute4;
    l_attribute5             VARCHAR2(150)  := p_attribute5;
    l_attribute6             VARCHAR2(150)  := p_attribute6;
    l_attribute7             VARCHAR2(150)  := p_attribute7;
    l_attribute8             VARCHAR2(150)  := p_attribute8;
    l_attribute9             VARCHAR2(150)  := p_attribute9;
    l_attribute10            VARCHAR2(150)  := p_attribute10;
    l_attribute11            VARCHAR2(150)  := p_attribute11;
    l_attribute12            VARCHAR2(150)  := p_attribute12;
    l_attribute13            VARCHAR2(150)  := p_attribute13;
    l_attribute14            VARCHAR2(150)  := p_attribute14;
    l_attribute15            VARCHAR2(150)  := p_attribute15;
    l_transaction_type       VARCHAR2(30)   := p_transaction_type;
    l_vendor_lot             VARCHAR2(30)   := p_vendor_lot;
    l_reason_id              NUMBER         := p_reason_id;
    l_qa_collection_id       NUMBER         := p_qa_collection_id;
    l_primary_qty            NUMBER;
    l_primary_uom_code       VARCHAR2(5);
    l_mol_line_id            NUMBER;
    l_mol_new_line_id        NUMBER;
    l_mol_header_id          NUMBER;
    l_mol_uom_code           VARCHAR2(5);
    l_mol_qty                NUMBER;
    l_rcv_transaction_id     NUMBER;
    l_rtv_qty                NUMBER;
    l_rls_qty                NUMBER;
    l_cnv_rls_qty            NUMBER;   -- Added for bug 6688055
    l_rtv_uom                VARCHAR2(25);  /* Each */
    l_rtv_uom_code           VARCHAR2(5);  /* Ea */
    l_receipt_source_code    VARCHAR2(25);
    l_tolerable_qty          NUMBER;
    l_remaining_qty          NUMBER;
    l_remaining_mol_qty      NUMBER;
    l_inspection_status      NUMBER;
    l_return_status          VARCHAR2(5);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);
    l_rec_count              NUMBER;

  l_secondary_qty    NUMBER := p_secondary_qty; --OPM COnvergence
  l_remaining_sec_qty NUMBER; --OPM Convergence
  l_rtv_sec_uom VARCHAR2(25);--OPM Convergence
  l_sec_uom_code VARCHAR2(3);--OPM Convergence
  l_sec_uom VARCHAR2(25);--OPM Convergence
  l_sec_mol_qty NUMBER;--OPM COnvergence
  l_sec_remaining_mol_qty NUMBER;--OPM Convergence
  l_sec_remaining_qty NUMBER; --OPM Convergence
  l_rtv_sec_qty NUMBER;--OPM Convergence
  l_processed_lot_prim_qty NUMBER;

    TYPE number_tb_tp IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

    l_mmtt_ids               number_tb_tp;
    l_primary_quantities     number_tb_tp;
    l_transaction_quantities number_tb_tp;
    L_SECONDARY_TXN_QUANTITIES number_tb_tp; --OPM Convergence


    /* FP-J Lot/Serial Support Enhancement
     * If WMS and PO J are installed, then the move order line quantity updates
     * will be handled by the receiving TM. The logic for MO handling would be:
     *  If MOL quantity > Inspection Quantity Then
     *    Do not update quantity. Set the process_flag to 2 so that
     *    this line does not get picked up again.
     *    Split the move order line to create one for the uninspected quantity
     *  Else
     *    Do not update quantity. Set the process_flag to 2 so that this line
     *    does not get picked up again.
     *  End If
     *  If either WMS or PO J are not installed, retain the original processing
     *  So am opening the cursor with a new parameter k_wms_po_j_higher.
     *  If this flag is set, then filter the move order lines on process_flag (=1)
     *  If this flag is not set, then filter lines on quantity
     */
    CURSOR mol_cursor(
      k_inventory_item_id  NUMBER
    , k_organization_id    NUMBER
    , k_lpn_id             NUMBER
    , k_revision           VARCHAR2
    , k_lot_number         VARCHAR2
    ) IS
      SELECT line_id
           , header_id
           , uom_code
           , quantity - NVL(quantity_delivered,0)
           , secondary_quantity - NVL(secondary_quantity_delivered,0) --OPM Convergence
      FROM   mtl_txn_request_lines
      WHERE  inventory_item_id = k_inventory_item_id
      AND    organization_id = k_organization_id
      AND    lpn_id = k_lpn_id
      AND    (revision = k_revision
              OR revision IS NULL
                 AND p_revision IS NULL)
      AND    (lot_number = k_lot_number
              OR lot_number IS NULL
                 AND p_lot_number IS NULL)
      AND    inspection_status is not null --8405606
      AND    line_status = 7
      AND    quantity - Nvl(quantity_delivered,0) > 0
      AND wms_process_flag = 1
      ;

    -- MOLCON
    --bug 8405606 removed the condition for rt.inspection_status_code = 'NOT INSPECTED'
    CURSOR rtv_van_cursor(k_item_id NUMBER,
			  k_item_revision VARCHAR2,
			  k_lpn_id NUMBER) IS
      SELECT rs.rcv_transaction_id
           , rsh.receipt_source_code
           , rs.unit_of_measure
           , rs.secondary_unit_of_measure --OPM Convergence
      FROM   rcv_supply rs, rcv_transactions rt, rcv_shipment_headers rsh
      WHERE  rs.rcv_transaction_id = rt.transaction_id
      AND    rsh.shipment_header_id = rs.shipment_header_id
      AND    rs.supply_type_code = 'RECEIVING'
      AND    rt.transaction_type <> 'UNORDERED'
      AND    rt.routing_header_id = g_inspection_routing
      AND    rs.item_id = k_item_id
      AND    (k_item_revision IS NULL     -- Bug : 6139900
              OR nvl(rs.item_revision,'@#*') = nvl(k_item_revision,'@#*'))
      AND    rs.lpn_id = k_lpn_id; --l_lpn_id should always be NOT NULL

    CURSOR rtv_lot_cursor(k_item_id NUMBER,
			  k_item_revision VARCHAR2,
			  k_lpn_id NUMBER,
			  k_lot_number VARCHAR2) IS
      SELECT rs.rcv_transaction_id
           , rsh.receipt_source_code
           , rs.unit_of_measure
           , rs.secondary_unit_of_measure --OPM Convergence
	   , rls.quantity quantity
      FROM   rcv_supply rs, rcv_lots_supply rls, rcv_transactions rt, rcv_shipment_headers rsh
      WHERE  rs.rcv_transaction_id = rt.transaction_id
      AND    rsh.shipment_header_id = rs.shipment_header_id
      AND    rs.supply_type_code = 'RECEIVING'
      AND    rt.transaction_type <> 'UNORDERED'
      AND    rt.routing_header_id = g_inspection_routing
      AND    rs.item_id = k_item_id
      AND    (k_item_revision IS NULL     -- Bug : 6139900
              OR nvl(rs.item_revision,'@#*') = nvl(k_item_revision,'@#*'))
      AND    rs.lpn_id = k_lpn_id --l_lpn_id should always be NOT NULL
      AND    rls.transaction_id = rs.rcv_transaction_id
      AND    rls.lot_num = k_lot_number;

    CURSOR rtv_serial_cursor(k_item_id NUMBER,
			     k_item_revision VARCHAR2,
			     k_lpn_id NUMBER,
			     k_serial_number VARCHAR2,
			     k_lot_number VARCHAR2) IS
      SELECT rs.rcv_transaction_id
           , rsh.receipt_source_code
           , rs.unit_of_measure
           , rs.secondary_unit_of_measure --OPM Convergence
      FROM   rcv_supply rs, rcv_serials_supply rss, rcv_transactions rt, rcv_shipment_headers rsh
      WHERE  rs.rcv_transaction_id = rt.transaction_id
      AND    rsh.shipment_header_id = rs.shipment_header_id
      AND    rs.supply_type_code = 'RECEIVING'
      AND    rt.transaction_type <> 'UNORDERED'
      AND    rt.routing_header_id = g_inspection_routing
      AND    rs.item_id = k_item_id
      AND    (k_item_revision IS NULL     -- Bug : 6139900
              OR nvl(rs.item_revision,'@#*') = nvl(k_item_revision,'@#*'))
      AND    rs.lpn_id = k_lpn_id --l_lpn_id should always be NOT NULL
      AND    rss.transaction_id = rs.rcv_transaction_id
      AND    rss.serial_num = k_serial_number
      AND    rss.supply_type_code = 'RECEIVING'
      AND    Nvl(rss.lot_num,'@#@') = Nvl(k_lot_number,'@#@');
    -- MOLCON

    l_debug                  NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --New variables for Lot/Serial Support
    l_lot_control_code        NUMBER;
    l_serial_control_code     NUMBER;
    l_mo_splt_tb              inv_rcv_integration_apis.mo_in_tb_tp;
    l_txn_qty_to_split        NUMBER;
    l_primary_qty_to_split    NUMBER;
    l_new_mol_id              NUMBER;
    l_split_line_id           NUMBER;   --for debug
    l_progress VARCHAR2(10) := '0';

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('main_process: Just entering main_process', 4);
      print_debug('p_inventory_item_id => '||p_inventory_item_id,4);
      print_debug('p_organization_id   => '||p_organization_id,4);
      print_debug('p_lpn_id            => '||p_lpn_id,4);
      print_debug('p_revision          => '||p_revision,4);
      print_debug('p_lot_number        => '||p_lot_number,4);
      print_debug('p_uom_code          => '||p_uom_code,4);
      print_debug('p_quantity          => '||p_quantity,4);
      print_debug('p_serial_number     => '||p_serial_number,4);
      print_debug('p_inspection_code   => '||p_inspection_code,4);
    END IF;

    --First check if the transaction date satisfies the validation.
    --If the transaction date is invalid then error out the transaction
    IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
       --BUG 3444196: Used the HR view instead for performance reasons
       SELECT TO_NUMBER(hoi.org_information1)
        INTO inv_rcv_common_apis.g_po_startup_value.sob_id
	FROM hr_organization_information hoi
	WHERE hoi.organization_id = p_organization_id
	AND (hoi.org_information_context || '') = 'Accounting Information' ;
    END IF;

    inv_rcv_common_apis.validate_trx_date(
      p_trx_date            => SYSDATE
    , p_organization_id     => p_organization_id
    , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
    , x_return_status       => x_return_status
    , x_error_code          => x_msg_data
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    SAVEPOINT inspect_main_sp;

    -- Quantity entered on form
    l_remaining_qty := l_quantity;

    -- Mapping of Inspection code values from Receiving to WMS/Inventory.
    -- Wrong habit to hardcode but that's what receiving
    -- transactions interface expects.
    -- Inspection Status values:
    -- 1 - Yet to be inspected
    -- 2 - Accepted
    -- 3 - Rejected


    IF l_inspection_code = 'ACCEPT' THEN
      l_inspection_status := g_accept;  /* Accept */
    ELSE
      l_inspection_status := g_reject;  /* Reject */
    END IF;

    l_primary_uom_code := inv_rcv_cache.get_primary_uom_code(l_organization_id,l_inventory_item_id);
    l_sec_uom_code := inv_rcv_cache.get_secondary_uom_code(l_organization_id,l_inventory_item_id);

    -- Purchasing/receiving uses unit of measure (Each)
    -- rather than uom code(Ea) and hence the following..
    -- This will be used later while inserting into interface table

    SELECT unit_of_measure
    INTO   l_uom
    FROM   mtl_units_of_measure
    WHERE  uom_code = l_uom_code;

    /*OPM Convergence */
    IF l_sec_uom_code IS NOT NULL THEN

       SELECT unit_of_measure
       INTO   l_sec_uom
       FROM   mtl_units_of_measure
       WHERE  uom_code = l_sec_uom_code;

    END IF;

    -- Open Move Order Line cursor
    OPEN mol_cursor(
          l_inventory_item_id
        , l_organization_id
        , l_lpn_id
        , l_revision
        , l_lot_number
                   );

    WHILE(l_remaining_qty > 0) LOOP

      IF (l_debug = 1) THEN
        print_debug('Main process l_remaining_qty : ' || TO_CHAR(l_remaining_qty), 4);
      END IF;

      -- MOLCON
      FETCH  mol_cursor
      INTO 	       l_mol_line_id
		     , l_mol_header_id
		     , l_mol_uom_code
		     , l_mol_qty
                     , l_sec_mol_qty; --OPM Convergence
      -- MOLCON

      IF mol_cursor%NOTFOUND THEN
        EXIT;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug(' l_mol_line_id  :'||l_mol_line_id,4);
	 print_debug(' l_mol_header_id:'||l_mol_header_id,4);
	 print_debug(' l_mol_qty      :'||l_mol_qty,4);
	 print_debug(' l_mol_uom_code :'||l_mol_uom_code,4);
	 print_debug(' l_uom_code     :'||l_uom_code,4);
	 print_debug(' l_sec_mol_qty  :'||l_sec_mol_qty,4);
      END IF;

      -- If inspection uom is not same as move order uom, we convert
      IF (l_uom_code <> l_mol_uom_code) THEN
	 l_mol_qty := inv_rcv_cache.convert_qty
	                 (p_inventory_item_id => l_inventory_item_id
			  ,p_from_qty         => l_mol_qty
			  ,p_from_uom_code    => l_mol_uom_code
			  ,p_to_uom_code      => l_uom_code);
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('main process l_mol_qty ' || TO_CHAR(l_mol_qty), 4);
	 print_debug('main process l_mol_line_id ' || l_mol_line_id, 4);
      END IF;

      -- l_remaing_mol_qty := min(l_remaining_qty, l_mol_qty)
      IF (l_mol_qty >= l_remaining_qty) THEN
        l_remaining_mol_qty := l_remaining_qty;
        l_sec_remaining_mol_qty := l_sec_remaining_qty; --OPM Convergence
        l_remaining_qty := 0;
        l_sec_remaining_qty := 0; --OPM Convergence
      ELSE
        l_remaining_mol_qty := l_mol_qty;
        l_sec_remaining_mol_qty := l_sec_mol_qty; --OPM Convergence
        l_remaining_qty := l_remaining_qty - l_mol_qty;
        l_sec_remaining_qty := l_sec_remaining_qty - l_sec_mol_qty; --OPM Convergence
      END IF;

      IF (l_debug = 1) THEN
        print_debug('main process: l_remaining_mol_qty = min(l_mol_qty, l_remaining_qty) = ' || l_remaining_mol_qty, 4);
      END IF;

      -- Open Rcv Transactions cursor
      -- MOLCON
      IF (l_serial_number IS NOT NULL) THEN
	 OPEN rtv_serial_cursor(
            l_inventory_item_id
          , l_revision
          , l_lpn_id
          , l_serial_number
          , l_lot_number);
       ELSIF (l_lot_number IS NOT NULL) THEN
	 OPEN rtv_lot_cursor(
            l_inventory_item_id
          , l_revision
          , l_lpn_id
          , l_lot_number);
       ELSE
	 OPEN rtv_van_cursor(
            l_inventory_item_id
          , l_revision
          , l_lpn_id);
      END IF;

      -- One MOL can only be tied to 1 RT, which can only has 1 RS
      -- So, at least for J or higher, assume that this loop
      -- will only be executed once

      WHILE(l_remaining_mol_qty > 0) LOOP
        IF (l_debug = 1) THEN
          print_debug('Main process l_remaining_mol_qty : ' || TO_CHAR(l_remaining_mol_qty), 4);
        END IF;

        -- MOLCON
        -- LOOP FROM THE FETCH HERE FOR RTV CURSOR
        -- AS THERE MAY BE MULTIPLE RT ROWS FOR SINGLE MOL LINE NOW
        -- RTV_CURSOR IF NOTHING IS FOUND AND STILL REMAINING QTY EXISTS FAIL THE TXN
        -- ALSO FOR THE CONDITION for L_RTV_QTY > 0 , THE ELSE PART IS NOT NEEDED
        -- AS IF THERE ARE MULTIPLE RT's FETCHED THEN THERE ARE PARENT RECEIPT TXN's
        -- FOR WHICH SOME RTI  IS ALREADY CREATED FOR INSPECTION TXN.
        -- MOLCON

	IF (l_serial_number IS NOT NULL) THEN
	   FETCH rtv_serial_cursor
	     INTO  l_rcv_transaction_id
	     , l_receipt_source_code
	     , l_rtv_uom
	     , l_rtv_sec_uom; --OPM Convergence

	   IF rtv_serial_cursor%NOTFOUND THEN
	      -- MOLCON
	      -- CHECK FOR ERROR HERE
	      IF l_remaining_mol_qty > 0 then
		 fnd_message.set_name('INV', 'INV_RCV_NO_ROWS');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;
	      -- MOLCON
	      EXIT;
	   END IF;

	 ELSIF (l_lot_number IS NOT NULL) THEN
	   FETCH rtv_lot_cursor
	     INTO  l_rcv_transaction_id
	     , l_receipt_source_code
	     , l_rtv_uom
	     , l_rtv_sec_uom--OPM Convergence
	     , l_rls_qty;

	   IF rtv_lot_cursor%NOTFOUND THEN
	      -- MOLCON
	      -- CHECK FOR ERROR HERE
	      IF l_remaining_mol_qty > 0 then
		 fnd_message.set_name('INV', 'INV_RCV_NO_ROWS');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;
	      -- MOLCON
	      EXIT;
	   END IF;

	 ELSE
	   FETCH rtv_van_cursor
	     INTO  l_rcv_transaction_id
	     , l_receipt_source_code
	     , l_rtv_uom
	     , l_rtv_sec_uom; --OPM Convergence

	   IF rtv_van_cursor%NOTFOUND THEN
	      -- MOLCON
	      -- CHECK FOR ERROR HERE
	      IF l_remaining_mol_qty > 0 then
		 fnd_message.set_name('INV', 'INV_RCV_NO_ROWS');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;
	      -- MOLCON
	      EXIT;
	   END IF;
        END IF; --END IF (l_serial_number IS NOT NULL) THEN

        IF (l_debug = 1) THEN
          print_debug('l_rcv_transaction_id:'||l_rcv_transaction_id||
		      ' l_receipt_source_code:'||l_receipt_source_code||
		      ' l_rtv_uom:'||l_rtv_uom||
		      ' l_rtv_sec_uom:'||l_rtv_sec_uom||
		      ' l_rls_qty:'||l_rls_qty,4);
        END IF;

	IF (l_serial_number IS NOT NULL) THEN
	   l_rtv_qty := 1;
	 ELSIF (l_lot_number IS NOT NULL) THEN
	   BEGIN
	      SELECT SUM(Nvl(mtli.primary_quantity,0))
		INTO l_processed_lot_prim_qty
		FROM mtl_transaction_lots_interface mtli
		,    rcv_transactions_interface rti
		WHERE mtli.product_code = 'RCV'
		AND   mtli.product_transaction_id = rti.interface_transaction_id
		AND   mtli.lot_number = l_lot_number
		AND   rti.parent_transaction_id = l_rcv_transaction_id
		AND   rti.transaction_status_code = 'PENDING'
		AND   rti.processing_status_code <> 'ERROR';

	      IF (l_processed_lot_prim_qty IS NULL) THEN
		 l_processed_lot_prim_qty := 0;
	      END IF;
	   EXCEPTION
	      WHEN OTHERS THEN
		 l_processed_lot_prim_qty := 0;
	   END;

	   IF (l_debug = 1) THEN
	      print_debug('l_processed_lot_prim_qty: '||l_processed_lot_prim_qty,4);
	   END IF;

	-- Modified for bug 6688055
	-- Convert l_rtv_uom(Each) into l_rtv_uom_code(Ea)
	SELECT uom_code
		INTO   l_rtv_uom_code
		FROM   mtl_units_of_measure
		WHERE  unit_of_measure = l_rtv_uom;

	IF (l_debug = 1) THEN
		print_debug('l_rtv_uom_code: '||l_rtv_uom_code||' l_uom_code : '||l_uom_code,4);
	END IF;

	IF (l_uom_code <> l_rtv_uom_code) THEN
		l_cnv_rls_qty := inv_rcv_cache.convert_qty
			 (p_inventory_item_id => l_inventory_item_id
			  ,p_from_qty         => l_rls_qty
			  ,p_from_uom_code    => l_rtv_uom_code
			  ,p_to_uom_code      => l_uom_code);
	ELSE
		l_cnv_rls_qty := l_rls_qty;
	END IF;

	IF (l_debug = 1) THEN
		print_debug('l_cnv_rls_qty : '||l_cnv_rls_qty,4);
	END IF;


	-- If inspection uom is not same as receipt uom, convert
	/*
		IF (l_primary_uom_code <> l_uom_code) THEN
			l_rtv_qty := l_rls_qty - inv_rcv_cache.convert_qty
				  (p_inventory_item_id => l_inventory_item_id
				   ,p_from_qty         => l_processed_lot_prim_qty
				   ,p_from_uom_code    => l_primary_uom_code
				   ,p_to_uom_code      => l_uom_code);
		ELSE
			l_rtv_qty := l_rls_qty - l_processed_lot_prim_qty;
		END IF;
	*/
	IF (l_primary_uom_code <> l_uom_code) THEN
		l_rtv_qty := l_cnv_rls_qty - inv_rcv_cache.convert_qty
					  (p_inventory_item_id => l_inventory_item_id
					   ,p_from_qty         => l_processed_lot_prim_qty
					   ,p_from_uom_code    => l_primary_uom_code
					   ,p_to_uom_code      => l_uom_code);
	ELSE
		l_rtv_qty := l_cnv_rls_qty - l_processed_lot_prim_qty;
	END IF;


	-- Modification for bug 6688055 ended
	 ELSE
           rcv_quantities_s.get_available_quantity(
	        'INSPECT'
	        , l_rcv_transaction_id
	        , l_receipt_source_code
	        , NULL
	        , l_rcv_transaction_id
	        , NULL
	        , l_rtv_qty
	        , l_tolerable_qty
	        , l_rtv_uom);

	   IF (l_debug = 1) THEN
	      print_debug('main process l_rtv_qty : ' || TO_CHAR(l_rtv_qty), 4);
	   END IF;

	   IF (l_rtv_qty > 0) THEN
	      -- Purchasing/receiving uses unit of measure (Each)
	      -- rather than uom code(Ea) and hence the following..
	      -- Convert l_rtv_uom(Each) into l_rtv_uom_code(Ea)
	      SELECT uom_code
		INTO   l_rtv_uom_code
		FROM   mtl_units_of_measure
		WHERE  unit_of_measure = l_rtv_uom;

	      -- If inspection uom is not same as receipt uom, convert

	      IF (l_uom_code <> l_rtv_uom_code) THEN
		 l_rtv_qty := inv_rcv_cache.convert_qty
		                 (p_inventory_item_id => l_inventory_item_id
				  ,p_from_qty         => l_rtv_qty
				  ,p_from_uom_code    => l_rtv_uom_code
				  ,p_to_uom_code      => l_uom_code);
	      END IF;
	   END IF;
	END IF;

	IF (l_rtv_qty > 0) THEN
          IF l_rtv_qty >= l_remaining_mol_qty THEN
            IF (l_debug = 1) THEN
              print_debug('main_process: l_rtv >= l_remaining_mol_qty', 4);
            END IF;
            l_rtv_qty := l_remaining_mol_qty;
            l_remaining_mol_qty := 0;
          ELSE
            IF (l_debug = 1) THEN
              print_debug('main_process: l_rtv < l_remaining_mol_qty', 4);
            END IF;
            l_remaining_mol_qty := l_remaining_mol_qty - l_rtv_qty;
          END IF;

          IF (l_debug = 1) THEN
            print_debug('main_process: l_rtv_qty = min(available qty, l_remaining_mol_qty) = ' || l_rtv_qty, 4);
          END IF;

          -- If required convert into primary unit of measure
          IF (l_uom_code <> l_primary_uom_code) THEN
	     l_primary_qty := inv_rcv_cache.convert_qty
		                 (p_inventory_item_id => l_inventory_item_id
				  ,p_from_qty         => l_rtv_qty
				  ,p_from_uom_code    => l_uom_code
				  ,p_to_uom_code      => l_primary_uom_code);
          ELSE
            l_primary_qty := l_rtv_qty;
          END IF;

          IF l_inspection_status = g_accept THEN
            IF (l_accept_lpn_id > 0) THEN
              l_rti_lpn_id := l_lpn_id;
              l_rti_transfer_lpn_id := l_accept_lpn_id;
            ELSE
              l_rti_lpn_id := l_lpn_id;
            END IF;
          ELSE
            IF (l_reject_lpn_id > 0) THEN
              l_rti_lpn_id := l_lpn_id;
              l_rti_transfer_lpn_id := l_reject_lpn_id;
            ELSE
              l_rti_lpn_id := l_lpn_id;
            END IF;
          END IF;

	  -- If l_rtv_quantity < l_mol_qty
	  -- Split MOL
	  -- Create new RTI for each MMTT in the new MOL
	  -- Insert Lot/Serials Interface record for each of these RTI
	  -- Call ATF API
	  IF (l_debug = 1) THEN
	     print_debug('main_process : inside RTV cursor Loop, before split_mo', 4);
	     print_debug('    l_rtv_qty =======> ' || l_rtv_qty, 4);
	     print_debug('    l_remaining_mol_qty => ' || l_remaining_mol_qty, 4);
	     print_debug('    l_primary_qty ===> ' || l_primary_qty, 4);
	     print_debug('    l_mol_qty =======> ' || l_mol_qty, 4);
	     print_debug('    l_remaining_qty => ' || l_remaining_qty, 4);
	     print_debug('    l_mol_line_id ===> ' || l_mol_line_id, 4);
	  END IF;

	  IF (l_rtv_qty < l_mol_qty) THEN
	     l_mo_splt_tb(1).prim_qty := l_primary_qty;

	     IF (l_debug = 1) THEN
                print_debug('main_process : Calling split_mo: ' || l_return_status, 4);
                print_debug('   p_orig_mol_id ============> ' || l_mol_line_id, 4);
                print_debug('   p_mo_splt_tb(1).prim_qty => ' || l_mo_splt_tb(1).prim_qty, 4);
	     END IF;

	     inv_rcv_integration_apis.split_mo(
					       p_orig_mol_id     => l_mol_line_id
					       , p_mo_splt_tb      => l_mo_splt_tb
					       , x_return_status   => l_return_status
					       , x_msg_count       => l_msg_count
					       , x_msg_data        => l_msg_data);

	     IF (l_debug = 1) THEN
                print_debug('main_process : Call to split_mo returns: ' || l_return_status, 4);
	     END IF;

	     IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
	     END IF;

	     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
	     END IF;
	     l_new_mol_id := l_mo_splt_tb(1).line_id;
	   ELSE
	     l_new_mol_id := l_mol_line_id;
	  END IF; -- IF (l_remaining_mol_qty < l_mol_qty) THEN

	  l_progress := '50';
	  -- clear records before bulk collecting
	  IF (l_mmtt_ids.COUNT > 0) THEN
	     l_mmtt_ids.DELETE;
	  END IF;

	  l_progress := '60';
	  IF (l_transaction_quantities.COUNT > 0) THEN
	     l_transaction_quantities.DELETE;
	  END IF;

	  /* OPM Convergence */
	  IF (l_secondary_txn_quantities.COUNT > 0) THEN
	     l_secondary_txn_quantities.DELETE;
	  END IF;
	  l_progress := '70';
	  IF (l_primary_quantities.COUNT > 0) THEN
	     l_primary_quantities.DELETE;
	  END IF;

	  l_progress := '80';
          BEGIN
           print_debug('Select mmtt records based on move_order_line_id order by transaction_temp_id', 4);  --6160359,6189438
	     SELECT transaction_temp_id
	       , primary_quantity
	       , DECODE(transaction_uom
			, l_uom_code
			, transaction_quantity   /*Bug6133345*/
			, inv_rcv_cache.convert_qty
			     (l_inventory_item_id
			      ,transaction_quantity
			      ,transaction_uom
			      ,l_uom_code
			      ,NULL)
			) quantity
	       , secondary_transaction_quantity --OPM Convergence
	       BULK COLLECT INTO
	       l_mmtt_ids
	       , l_primary_quantities
	       , l_transaction_quantities
	       , l_secondary_txn_quantities --OPM Convergence
	       FROM   mtl_material_transactions_temp
	       WHERE  move_order_line_id = l_new_mol_id;
	  EXCEPTION
	     WHEN OTHERS THEN
                l_mmtt_ids(1) := NULL;
                l_primary_quantities(1) := l_primary_qty;
                l_transaction_quantities(1) := l_rtv_qty;
                l_secondary_txn_quantities(1) := l_rtv_sec_qty; --OPM Convergence
	  END;

	  l_progress := '90';
	  -- IF there are no mmtts, then insert RTI with no MMTT id
	  -- with l_rtv_qty and l_primary_qty
	  IF (l_mmtt_ids.COUNT = 0) THEN
	     l_mmtt_ids(1) := NULL;
	     l_primary_quantities(1) := l_primary_qty;
	     l_transaction_quantities(1) := l_rtv_qty;
	     l_secondary_txn_quantities(1) := l_rtv_sec_qty; --OPM Convergence
	  END IF;

	  l_progress := '100';

	  FOR i IN 1 .. l_mmtt_ids.COUNT LOOP
	     IF (l_debug = 1) THEN
                print_debug('Main process inserting RTI for MMTT:' || NVL(l_mmtt_ids(i), -1)
			    || ' quantity:' || l_transaction_quantities(i) || ' uom:' || l_uom, 4);
	     END IF;

	     l_progress := '110';
	     insert_inspect_rec_rti(
				    x_return_status        => l_return_status
				    , x_msg_count            => l_msg_count
				    , x_msg_data             => l_msg_data
				    , p_rcv_transaction_id   => l_rcv_transaction_id
				    , p_quantity             => l_transaction_quantities(i)
				    , p_uom                  => l_uom
				    , p_inspection_code      => l_inspection_code
				    , p_quality_code         => l_quality_code
				    , p_transaction_date     => l_transaction_date
				    , p_transaction_type     => l_transaction_type
				    , p_vendor_lot           => l_vendor_lot
				    , p_reason_id            => l_reason_id
				    , p_primary_qty          => l_primary_quantities(i)
				    , p_organization_id      => l_organization_id
				    , p_comments             => l_comments
				    , p_attribute_category   => l_attribute_category
				    , p_attribute1           => l_attribute1
				    , p_attribute2           => l_attribute2
				    , p_attribute3           => l_attribute3
	       , p_attribute4           => l_attribute4
	       , p_attribute5           => l_attribute5
	       , p_attribute6           => l_attribute6
	       , p_attribute7           => l_attribute7
	       , p_attribute8           => l_attribute8
	       , p_attribute9           => l_attribute9
	       , p_attribute10          => l_attribute10
	       , p_attribute11          => l_attribute11
	       , p_attribute12          => l_attribute12
	       , p_attribute13          => l_attribute13
	       , p_attribute14          => l_attribute14
	       , p_attribute15          => l_attribute15
	       , p_qa_collection_id     => l_qa_collection_id
	       , p_lpn_id               => l_rti_lpn_id
	       , p_transfer_lpn_id      => l_rti_transfer_lpn_id
	       , p_mmtt_temp_id         => l_mmtt_ids(i)
	       , p_sec_uom   => l_sec_uom --OPM Convergence
	       , p_secondary_qty => l_rtv_sec_qty); --OPM Convergence

	     IF l_return_status = fnd_api.g_ret_sts_error THEN
                RAISE fnd_api.g_exc_error;
	     END IF;

	     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE fnd_api.g_exc_unexpected_error;
	     END IF;

	     /* FP-J Lot/Serial Support Enhancement
	     * Process the lot numbers and serial numbers corresponding to the RTI
               * that was just created.
               * Since the lots and serials are stored by receiving tables, the
               * changes to RTI must be reflected in RCV_LOTS_SUPPLY (lot controlled item)
               * and RCV_SERIALS_SUPPLY (serial controlled item).
               * We would be creating the interface records in MTLI and MSNI corresponding
               * to the inspected quantity, lot number and the serial numbers inspected
               * Do this only if WMS and PO patch levels are J or higher
               */
	       SELECT lot_control_code
	       , serial_number_control_code
	       INTO   l_lot_control_code
	       , l_serial_control_code
	       FROM   mtl_system_items
	       WHERE  inventory_item_id = p_inventory_item_id
	       AND    organization_id = p_organization_id;

	     IF (l_lot_control_code > 1 OR l_serial_control_code > 1) THEN
                IF (l_debug = 1) THEN
		   print_debug('creating lots and/or serials interface records with product_transaction_id : '
			       || g_interface_transaction_id, 4);
                END IF;

                process_lot_serial_intf(
					x_return_status            => l_return_status
					, x_msg_count                => l_msg_count
					, x_msg_data                 => l_msg_data
					, p_organization_id          => p_organization_id
					, p_inventory_item_id        => p_inventory_item_id
					, p_lot_control_code         => l_lot_control_code
					, p_serial_control_code      => l_serial_control_code
					, p_lot_number               => p_lot_number
					, p_txn_qty                  => l_transaction_quantities(i)
					, p_primary_qty              => l_primary_quantities(i)
					, p_serial_number            => p_serial_number
					, p_product_transaction_id   => g_interface_transaction_id
					, p_lpn_id                   => p_lpn_id
					, p_sec_txn_qty              => l_secondary_txn_quantities(i) ); --OPM Convergence

		IF (l_debug = 1) THEN
		   print_debug('main_process: process_lot_serial_intf returns: ' || l_return_status, 4);
                END IF;

                IF l_return_status = fnd_api.g_ret_sts_error THEN
		   RAISE fnd_api.g_exc_error;
                END IF;

                IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		   RAISE fnd_api.g_exc_unexpected_error;
                END IF;
	     END IF; --END IF check lot and serial controls
	  END LOOP; -- End MMTT Loop

	  -- Activate the INSPECT operation
	  l_rec_count := wms_putaway_utils.activate_plan_for_inspect(
								     x_return_status   => x_return_status
								     , x_msg_count       => x_msg_count
								     , x_msg_data        => x_msg_data
								     , p_org_id          => l_organization_id
								     , p_mo_line_id      => l_new_mol_id);

	  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	     IF (l_debug = 1) THEN
                print_debug(' Error in Activate_Plan_For_Load ' || x_msg_data, 1);
	     END IF;
	     RAISE fnd_api.g_exc_error;
	   ELSE
	     IF (l_debug = 1) THEN
                print_debug('Successfully called Activate_Plan_For_Load for ' || l_rec_count || ' row(s)', 9);
	     END IF;
	  END IF;

	  -- Activate the INSPECT operation
	  --Update the wms_process_flag for the current MOL so that one else
	  --messes with it
	  UPDATE mtl_txn_request_lines
            SET wms_process_flag = 2
            WHERE  line_id = l_new_mol_id;
	 ELSE

          IF (l_debug = 1) THEN
            print_debug('main_process: There is no quantity available to Inspect: ', 4);
          END IF;

          -- MOLCON COMMENTED THIS CALL HERE
          -- THIS HAS TO BE TRACKED ABOVE
          -- fnd_message.set_name('INV', 'INV_RCV_NO_ROWS');
          -- fnd_msg_pub.ADD;
          -- RAISE fnd_api.g_exc_error;

        END IF; --END IF IF (l_rtv_qty > 0)
      END LOOP;

      IF (rtv_van_cursor%ISOPEN) THEN
        CLOSE rtv_van_cursor;
      END IF;

      IF (rtv_lot_cursor%isopen) THEN
	 CLOSE rtv_lot_cursor;
      END IF;

      IF (rtv_serial_cursor%isopen) THEN
	 CLOSE rtv_serial_cursor;
      END IF;
    END LOOP; -- WHILE(l_remaining_qty > 0) LOOP

    CLOSE mol_cursor;

    IF (l_remaining_qty > 0) THEN
       IF (l_debug = 1) THEN
          print_debug('main_process: No more MOL, but remaining qty still exists', 4);
       END IF;
       RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
        print_debug('Exception raised in main_process at progress: ' || l_progress, 4);
      END IF;

      ROLLBACK TO inspect_main_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (mol_cursor%ISOPEN) THEN
        CLOSE mol_cursor;
      END IF;

      IF (rtv_van_cursor%ISOPEN) THEN
        CLOSE rtv_van_cursor;
      END IF;

      IF (rtv_lot_cursor%isopen) THEN
	 CLOSE rtv_lot_cursor;
      END IF;

      IF (rtv_serial_cursor%isopen) THEN
	 CLOSE rtv_serial_cursor;
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
        print_debug('Exception raised in main_process at progress: ' || l_progress, 4);
      END IF;

      ROLLBACK TO inspect_main_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (mol_cursor%ISOPEN) THEN
        CLOSE mol_cursor;
      END IF;


      IF (rtv_van_cursor%ISOPEN) THEN
        CLOSE rtv_van_cursor;
      END IF;

      IF (rtv_lot_cursor%isopen) THEN
	 CLOSE rtv_lot_cursor;
      END IF;

      IF (rtv_serial_cursor%isopen) THEN
	 CLOSE rtv_serial_cursor;
      END IF;
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        print_debug('Exception raised in main_process at progress: ' || l_progress, 4);
      END IF;

      ROLLBACK TO inspect_main_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'main_process');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (mol_cursor%ISOPEN) THEN
        CLOSE mol_cursor;
      END IF;

      IF (rtv_van_cursor%ISOPEN) THEN
        CLOSE rtv_van_cursor;
      END IF;

      IF (rtv_lot_cursor%isopen) THEN
	 CLOSE rtv_lot_cursor;
      END IF;

      IF (rtv_serial_cursor%isopen) THEN
	 CLOSE rtv_serial_cursor;
      END IF;
  END main_process;

procedure range_serial_process(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN  NUMBER
, p_organization_id             IN  NUMBER
, p_lpn_id                      IN  NUMBER
, p_revision                    IN  VARCHAR2
, p_lot_number                  IN  VARCHAR2
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_type            IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_from_serial_number          IN  VARCHAR2
, p_to_serial_number            IN  VARCHAR2
, p_accept_lpn_id               IN  NUMBER
, p_reject_lpn_id               IN  NUMBER
, p_transaction_date            IN  DATE        DEFAULT SYSDATE
, p_vendor_lot                  IN  VARCHAR2    DEFAULT NULL
, p_comments                    IN  VARCHAR2    DEFAULT NULL
, p_attribute_category          IN  VARCHAR2    DEFAULT NULL
, p_attribute1                  IN  VARCHAR2    DEFAULT NULL
, p_attribute2                  IN  VARCHAR2    DEFAULT NULL
, p_attribute3                  IN  VARCHAR2    DEFAULT NULL
, p_attribute4                  IN  VARCHAR2    DEFAULT NULL
, p_attribute5                  IN  VARCHAR2    DEFAULT NULL
, p_attribute6                  IN  VARCHAR2    DEFAULT NULL
, p_attribute7                  IN  VARCHAR2    DEFAULT NULL
, p_attribute8                  IN  VARCHAR2    DEFAULT NULL
, p_attribute9                  IN  VARCHAR2    DEFAULT NULL
, p_attribute10                 IN  VARCHAR2    DEFAULT NULL
, p_attribute11                 IN  VARCHAR2    DEFAULT NULL
, p_attribute12                 IN  VARCHAR2    DEFAULT NULL
, p_attribute13                 IN  VARCHAR2    DEFAULT NULL
, p_attribute14                 IN  VARCHAR2    DEFAULT NULL
, p_attribute15                 IN  VARCHAR2    DEFAULT NULL)
is
	l_temp_prefix 		varchar2(30);

        l_from_ser_number	number;
        l_to_ser_number		number;
 	l_range_numbers         number;
        l_cur_ser_number        number;
        l_cur_serial_number     varchar2(30);

        l_primary_uom_code      varchar2(5);

	l_return_status 	varchar2(5);
  	l_msg_count            	number;
  	l_msg_data              varchar2(1000);

-- Increased lot size to 80 Char - 3ercy Thomas - B4625329
        l_lot_number            varchar2(80);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
   x_return_status     := fnd_api.g_ret_sts_success;

   savepoint process_sl_sp;

   --
   -- Get the primary uom of item. If we are here the item should be serial
   -- controlled. Most probably the uom should be 'Ea' but then we can't assume
   -- this. This would also not be a right assumption for non English cases
   --
   select primary_uom_code
   into l_primary_uom_code
   from mtl_system_items
   where organization_id   = p_organization_id
   and   inventory_item_id = p_inventory_item_id
   and   serial_number_control_code in (2,5,6);

   -- get the number part of the from serial
   inv_validate.number_from_sequence(p_from_serial_number,
                                     l_temp_prefix,
                                     l_from_ser_number);

   -- get the number part of the to serial
   inv_validate.number_from_sequence(p_to_serial_number,
                                     l_temp_prefix,
                                     l_to_ser_number);

   -- total number of serials
   l_range_numbers := l_to_ser_number - l_from_ser_number + 1;

   FOR i IN 1..l_range_numbers LOOP
      -- Number part of serial number like 123
      l_cur_ser_number := l_from_ser_number + i -1;

      -- concatenate the serial number to be inserted like XYZ123
      -- l_cur_serial_number := l_temp_prefix || l_cur_ser_number;

      l_cur_serial_number := Substr(p_from_serial_number, 1,
                                    Length(p_from_serial_number) - Length(l_cur_ser_number))
                             || l_cur_ser_number;

      -- dbms_output.put_line('Curr Sl No:' || l_cur_serial_number || 'ZZZ');

      -- We cannot assume that the serial number range belong to the samelot..
      select lot_number
      into l_lot_number
      from mtl_serial_numbers
      where inventory_item_id = p_inventory_item_id
      and   serial_number     = l_cur_serial_number;

      -- Call processing for each serial number
      -- A new parameter qa_collection_id has been added to
      -- main process for QA, but QA will not inspect range of
      -- sl. nos. Hence passing it a value of NULL
      main_process(
        x_return_status               => l_return_status
      , x_msg_count                   => l_msg_count
      , x_msg_data                    => l_msg_data
      , p_inventory_item_id           => p_inventory_item_id
      , p_organization_id             => p_organization_id
      , p_lpn_id                      => p_lpn_id
      , p_revision                    => p_revision
      , p_lot_number                  => l_lot_number
      , p_uom_code                    => l_primary_uom_code
      , p_quantity                    => 1 -- 1 Primary UOM
      , p_inspection_code             => p_inspection_code
      , p_quality_code                => p_quality_code
      , p_transaction_type            => p_transaction_type
      , p_reason_id                   => p_reason_id
      , p_serial_number               => l_cur_serial_number
      , p_accept_lpn_id               => p_accept_lpn_id
      , p_reject_lpn_id               => p_reject_lpn_id
      , p_transaction_date            => p_transaction_date
      , p_qa_collection_id            => NULL
      , p_vendor_lot                  => p_vendor_lot
      , p_comments                    => p_comments
      , p_attribute_category          => p_attribute_category
      , p_attribute1                  => p_attribute1
      , p_attribute2                  => p_attribute2
      , p_attribute3                  => p_attribute3
      , p_attribute4                  => p_attribute4
      , p_attribute5                  => p_attribute5
      , p_attribute6                  => p_attribute6
      , p_attribute7                  => p_attribute7
      , p_attribute8                  => p_attribute8
      , p_attribute9                  => p_attribute9
      , p_attribute10                 => p_attribute10
      , p_attribute11                 => p_attribute11
      , p_attribute12                 => p_attribute12
      , p_attribute13                 => p_attribute13
      , p_attribute14                 => p_attribute14
      , p_attribute15                 => p_attribute15);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
      	RAISE fnd_api.g_exc_error;
      END IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   END LOOP;

exception
   when fnd_api.g_exc_error THEN
      rollback to process_sl_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

   when fnd_api.g_exc_unexpected_error THEN
      rollback to process_sl_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

   when others THEN
      rollback to process_sl_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'range_serial_process'
              );
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
end range_serial_process;

procedure main_process_po(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN  NUMBER
, p_organization_id             IN  NUMBER
, p_po_header_id                IN  NUMBER
, p_revision                    IN  VARCHAR2
, p_uom_code                    IN  VARCHAR2
, p_quantity                    IN  NUMBER
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_type            IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_transaction_date            IN  DATE        DEFAULT SYSDATE
, p_qa_collection_id            IN  NUMBER      DEFAULT NULL
, p_vendor_lot                  IN  VARCHAR2    DEFAULT NULL
, p_comments                    IN  VARCHAR2	DEFAULT NULL
, p_attribute_category          IN  VARCHAR2    DEFAULT NULL
, p_attribute1                  IN  VARCHAR2    DEFAULT NULL
, p_attribute2                  IN  VARCHAR2    DEFAULT NULL
, p_attribute3                  IN  VARCHAR2    DEFAULT NULL
, p_attribute4                  IN  VARCHAR2    DEFAULT NULL
, p_attribute5                  IN  VARCHAR2    DEFAULT NULL
, p_attribute6                  IN  VARCHAR2    DEFAULT NULL
, p_attribute7                  IN  VARCHAR2    DEFAULT NULL
, p_attribute8                  IN  VARCHAR2    DEFAULT NULL
, p_attribute9                  IN  VARCHAR2    DEFAULT NULL
, p_attribute10                 IN  VARCHAR2    DEFAULT NULL
, p_attribute11                 IN  VARCHAR2    DEFAULT NULL
, p_attribute12                 IN  VARCHAR2    DEFAULT NULL
, p_attribute13                 IN  VARCHAR2    DEFAULT NULL
, p_attribute14                 IN  VARCHAR2    DEFAULT NULL
, p_attribute15                 IN  VARCHAR2    DEFAULT NULL
, p_secondary_qty               IN  NUMBER      DEFAULT NULL) --OPM Convergence
is
  l_inventory_item_id           NUMBER 		:= p_inventory_item_id;
  l_organization_id             NUMBER 		:= p_organization_id;
  l_revision                    VARCHAR2(10)    := p_revision;
  l_revision_control            NUMBER; -- Added for bug 3134272
  l_uom_code                    VARCHAR2(5)     := p_uom_code;
  l_uom                         VARCHAR2(30);
  l_quantity                    NUMBER          := p_quantity;
  l_po_header_id		NUMBER		:= p_po_header_id;

  l_inspection_code          VARCHAR2(25)   := p_inspection_code;
  l_quality_code             VARCHAR2(25)   := p_quality_code;
  l_transaction_date         DATE           := p_transaction_date;
  l_comments                 VARCHAR2(240)  := p_comments;
  l_attribute_category       VARCHAR2(30)   := p_attribute_category;
  l_attribute1               VARCHAR2(150)  := p_attribute1;
  l_attribute2               VARCHAR2(150)  := p_attribute2;
  l_attribute3               VARCHAR2(150)  := p_attribute3;
  l_attribute4               VARCHAR2(150)  := p_attribute4;
  l_attribute5               VARCHAR2(150)  := p_attribute5;
  l_attribute6               VARCHAR2(150)  := p_attribute6;
  l_attribute7               VARCHAR2(150)  := p_attribute7;
  l_attribute8               VARCHAR2(150)  := p_attribute8;
  l_attribute9               VARCHAR2(150)  := p_attribute9;
  l_attribute10              VARCHAR2(150)  := p_attribute10;
  l_attribute11              VARCHAR2(150)  := p_attribute11;
  l_attribute12              VARCHAR2(150)  := p_attribute12;
  l_attribute13              VARCHAR2(150)  := p_attribute13;
  l_attribute14              VARCHAR2(150)  := p_attribute14;
  l_attribute15              VARCHAR2(150)  := p_attribute15;
  l_transaction_type         VARCHAR2(30)   := p_transaction_type;
  l_vendor_lot               VARCHAR2(30)   := p_vendor_lot;
  l_reason_id                NUMBER         := p_reason_id;

  l_qa_collection_id         NUMBER         := p_qa_collection_id;

  l_primary_qty              NUMBER;
  l_primary_uom_code         varchar2(5);

  l_rcv_transaction_id       number;
  l_rtv_qty                  number;
  l_rtv_uom                  varchar2(25); /* Each */
  l_rtv_uom_code             varchar2(5);  /* Ea */
  l_receipt_source_code      varchar2(25);
  l_tolerable_qty            number;

  l_remaining_qty            number;
  l_transacted_qty           number;

  l_return_status            varchar2(5);
  l_msg_count                number;
  l_msg_data                 varchar2(1000);

  l_secondary_qty    NUMBER := p_secondary_qty; --OPM COnvergence
  l_remaining_sec_qty NUMBER; --OPM Convergence
  l_rtv_sec_uom VARCHAR2(25);--OPM Convergence
  l_sec_uom_code VARCHAR2(3);--OPM Convergence
  l_sec_uom VARCHAR2(25);--OPM Convergence
  l_rtv_sec_qty NUMBER;--OPM COnvergence
  L_SEC_REMAINING_QTY NUMBER;--OPM Convergence
/*  cursor rtv_cursor(
    k_po_header_id         number
  , k_organization_id      number
  , k_inventory_item_id    number
  , k_revision             varchar2)
  is
  select
    rcv_transaction_id
  , receipt_source_code
  , unit_of_measure
  from rcv_transactions_v
  where  po_header_id       = k_po_header_id
  and    to_organization_id = k_organization_id
  and    item_id            = k_inventory_item_id
  and   (item_revision      = k_revision OR
         item_revision is null and p_revision is null)
  and    inspection_status_code = 'NOT INSPECTED'
  and    routing_id             = g_inspection_routing;
*/
/* Bug 1542687: For performance reasons, the cursor is based on base tables below.*/

 --bug 8405606 removed the condition for rt.inspection_status_code = 'NOT INSPECTED'
  cursor rtv_cursor(
    k_po_header_id         number
  , k_organization_id      number
  , k_inventory_item_id    number
  , k_revision             varchar2
  , k_revision_control     number -- Added for bug 3134272
  ) is
  select
    rs.rcv_transaction_id
  , rsh.receipt_source_code
  , rs.unit_of_measure
  , rs.secondary_unit_of_measure --OPM Convergence
  from rcv_supply rs, rcv_transactions rt, rcv_shipment_headers rsh
  where  rs.po_header_id              = k_po_header_id
  and    rs.to_organization_id        = k_organization_id
  and    rs.item_id                   = k_inventory_item_id
  and   (k_revision_control = 2
         and Nvl(rs.item_revision,-1)         = Nvl(k_revision,-1)
	 OR k_revision_control = 1)
  -- Changed the above for bug 3134272
  and    rs.rcv_transaction_id     = rt.transaction_id
  and    rsh.shipment_header_id    = rs.shipment_header_id
  and    rs.supply_type_code       = 'RECEIVING'
  and    rt.transaction_type      <> 'UNORDERED'
  and    rt.routing_header_id      = g_inspection_routing;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
  x_return_status := fnd_api.g_ret_sts_success;

  -- dbms_output.put_line('main_process_po: Just entering main_process_po');

  --First check if the transaction date satisfies the validation.
  --If the transaction date is invalid then error out the transaction
  IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
     --BUG 3444196: Used the HR view instead for performance reasons
    SELECT TO_NUMBER(hoi.org_information1)
      INTO inv_rcv_common_apis.g_po_startup_value.sob_id
      FROM hr_organization_information hoi
      WHERE hoi.organization_id = p_organization_id
      AND (hoi.org_information_context || '') = 'Accounting Information' ;
  END IF;

  inv_rcv_common_apis.validate_trx_date(
    p_trx_date            => SYSDATE
  , p_organization_id     => p_organization_id
  , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
  , x_return_status       => x_return_status
  , x_error_code          => x_msg_data
  );

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RETURN;
  END IF;

  savepoint inspect_main_po_sp;

  -- Quantity entered on form
  l_remaining_qty := l_quantity;
  l_remaining_sec_qty := l_secondary_qty; --OPM Convergence

  -- Quantity successfully transacted
  l_transacted_qty := 0;

  -- One time fetch of item's primary uom code
  -- Fetching revision control for bug 3134272
  select primary_uom_code,revision_qty_control_code, secondary_uom_code --OPM Convergence
  into l_primary_uom_code,l_revision_control, l_sec_uom_code --OPM Convergence
  from mtl_system_items
  where organization_id   = l_organization_id
  and   inventory_item_id = l_inventory_item_id;

  -- dbms_output.put_line('main_process_po: Fetched item primary uom code');

  -- Purchasing/receiving uses unit of measure (Each)
  -- rather than uom code(Ea) and hence the following..
  -- This will be used later while inserting into interface table

  SELECT unit_of_measure
  INTO l_uom
  FROM mtl_units_of_measure
  WHERE  uom_code = l_uom_code;
/* OPM Convergence */
    IF l_sec_uom_code IS NOT NULL THEN

       SELECT unit_of_measure
       INTO   l_sec_uom
       FROM   mtl_units_of_measure
       WHERE  uom_code = l_sec_uom_code;

    END IF;
  -- dbms_output.put_line('main_process_po: Convert inspection uom code into uom');

  -- Open RCV Transactions V cursor
  open rtv_cursor(
    l_po_header_id
  , l_organization_id
  , l_inventory_item_id
  , l_revision
  , l_revision_control -- Added for bug 3134272
  );

  -- dbms_output.put_line('main_process_po: Opened RTV Cursor');

  while(l_remaining_qty > 0)
  loop
        fetch rtv_cursor into
           l_rcv_transaction_id
         , l_receipt_source_code
         , l_rtv_uom
         , l_rtv_sec_uom; --OPM Convergence

        if rtv_cursor%notfound then
                exit;
        end if;

        -- Get quantity that can be still inspected

        RCV_QUANTITIES_S.GET_AVAILABLE_QUANTITY (
          'INSPECT'
        , l_rcv_transaction_id
        , l_receipt_source_code
        , null
        , l_rcv_transaction_id
        , null
        , l_rtv_qty
        , l_tolerable_qty
        , l_rtv_uom );

        if (l_rtv_qty > 0) then

	  -- dbms_output.put_line('main_process_po: convert rtv uom into uom code');

          SELECT uom_code
          INTO l_rtv_uom_code
          FROM mtl_units_of_measure
          WHERE  unit_of_measure = l_rtv_uom;

          -- If inspection uom is not same as receipt uom, convert

          if (l_uom_code <> l_rtv_uom_code) then
        	l_rtv_qty := inv_convert.inv_um_convert(
                               l_inventory_item_id
                             , NULL
                             , l_rtv_qty
                             , l_rtv_uom_code
                             , l_uom_code
                             , NULL
                             , NULL);
          end if;

          if l_rtv_qty >= l_remaining_qty then
             l_rtv_qty       := l_remaining_qty;
             l_rtv_sec_qty   := l_sec_remaining_qty; --OPM Convergence
             l_remaining_qty := 0;
             l_sec_remaining_qty :=0; --OPM Convergence
          else
             l_remaining_qty := l_remaining_qty - l_rtv_qty;
             l_sec_remaining_qty := l_sec_remaining_qty - l_rtv_sec_qty; --OPM Convergence
          end if;

	  -- If required convert into primary unit of measure
	  if (l_uom_code <> l_primary_uom_code) then

              	-- dbms_output.put_line('main_process_po: convert inspect uom into primary uom');

		l_primary_qty := inv_convert.inv_um_convert(
                               l_inventory_item_id
			     , NULL
                             , l_rtv_qty
                             , l_uom_code
                             , l_primary_uom_code
                   	     , NULL
			     , NULL);
          else
		l_primary_qty := l_rtv_qty;
	  end if;

          -- dbms_output.put_line('main_process_po: Calling insert_inspect_rec_rti');

          -- Insert into rti, passing l_rtv_qty, inspection information
          insert_inspect_rec_rti (
                  x_return_status  	=> l_return_status
                , x_msg_count           => l_msg_count
                , x_msg_data            => l_msg_data
                , p_rcv_transaction_id  => l_rcv_transaction_id
                , p_quantity            => l_rtv_qty
                , p_uom                 => l_uom
                , p_inspection_code     => l_inspection_code
                , p_quality_code        => l_quality_code
                , p_transaction_date    => l_transaction_date
		          , p_transaction_type    => l_transaction_type
                , p_vendor_lot          => l_vendor_lot
 	             , p_reason_id           => l_reason_id
	             , p_primary_qty         => l_primary_qty
	             , p_organization_id     => l_organization_id
		, p_comments            => l_comments
		, p_attribute_category  => l_attribute_category
		, p_attribute1          => l_attribute1
		, p_attribute2          => l_attribute2
		, p_attribute3          => l_attribute3
		, p_attribute4          => l_attribute4
		, p_attribute5          => l_attribute5
		, p_attribute6          => l_attribute6
		, p_attribute7          => l_attribute7
		, p_attribute8          => l_attribute8
		, p_attribute9          => l_attribute9
		, p_attribute10         => l_attribute10
		, p_attribute11         => l_attribute11
		, p_attribute12         => l_attribute12
		, p_attribute13         => l_attribute13
		, p_attribute14         => l_attribute14
		, p_attribute15         => l_attribute15
                , p_qa_collection_id    => l_qa_collection_id
                , p_sec_uom   => l_sec_uom --OPM Convergence
                , p_secondary_qty => l_rtv_sec_qty); --OPM Convergence

          IF l_return_status = fnd_api.g_ret_sts_error THEN
         		RAISE fnd_api.g_exc_error;
	  END IF ;

    	  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         		RAISE fnd_api.g_exc_unexpected_error;
    	  END IF;

          -- dbms_output.put_line('main_process_po: Successful insert_inspect_rec_rti');

          -- Count successfully transacted qty
          l_transacted_qty       := l_transacted_qty + l_rtv_qty;
        end if;
  end loop;

  IF l_remaining_qty > 0 THEN
     FND_MESSAGE.set_name('INV','INV_QTY_LESS_OR_EQUAL');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  close rtv_cursor;

exception
   when fnd_api.g_exc_error THEN
      rollback to inspect_main_po_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;

   when fnd_api.g_exc_unexpected_error THEN
      rollback to inspect_main_po_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;

   when others THEN
      rollback to inspect_main_po_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'main_process_po'
              );
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;

end main_process_po;

procedure main_process_intransit(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN  NUMBER
, p_organization_id             IN  NUMBER
, p_shipment_header_id          IN  NUMBER
, p_revision                    IN  VARCHAR2
, p_uom_code                    IN  VARCHAR2
, p_quantity                    IN  NUMBER
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_type            IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_transaction_date            IN  DATE        DEFAULT SYSDATE
, p_qa_collection_id            IN  NUMBER      DEFAULT NULL
, p_vendor_lot                  IN  VARCHAR2    DEFAULT NULL
, p_comments                    IN  VARCHAR2	DEFAULT NULL
, p_attribute_category          IN  VARCHAR2    DEFAULT NULL
, p_attribute1                  IN  VARCHAR2    DEFAULT NULL
, p_attribute2                  IN  VARCHAR2    DEFAULT NULL
, p_attribute3                  IN  VARCHAR2    DEFAULT NULL
, p_attribute4                  IN  VARCHAR2    DEFAULT NULL
, p_attribute5                  IN  VARCHAR2    DEFAULT NULL
, p_attribute6                  IN  VARCHAR2    DEFAULT NULL
, p_attribute7                  IN  VARCHAR2    DEFAULT NULL
, p_attribute8                  IN  VARCHAR2    DEFAULT NULL
, p_attribute9                  IN  VARCHAR2    DEFAULT NULL
, p_attribute10                 IN  VARCHAR2    DEFAULT NULL
, p_attribute11                 IN  VARCHAR2    DEFAULT NULL
, p_attribute12                 IN  VARCHAR2    DEFAULT NULL
, p_attribute13                 IN  VARCHAR2    DEFAULT NULL
, p_attribute14                 IN  VARCHAR2    DEFAULT NULL
, p_attribute15                 IN  VARCHAR2    DEFAULT NULL
, p_secondary_qty               IN  NUMBER      DEFAULT NULL) --OPM Convergence
is
  l_inventory_item_id           NUMBER 		:= p_inventory_item_id;
  l_organization_id             NUMBER 		:= p_organization_id;
  l_revision                    VARCHAR2(10)    := p_revision;
  l_revision_control            NUMBER; -- Added for bug 3134272
  l_uom_code                    VARCHAR2(5)     := p_uom_code;
  l_uom                         VARCHAR2(30);
  l_quantity                    NUMBER          := p_quantity;
  l_shipment_header_id 		NUMBER		:= p_shipment_header_id;

  l_inspection_code          VARCHAR2(25)   := p_inspection_code;
  l_quality_code             VARCHAR2(25)   := p_quality_code;
  l_transaction_date         DATE           := p_transaction_date;
  l_comments                 VARCHAR2(240)  := p_comments;
  l_attribute_category       VARCHAR2(30)   := p_attribute_category;
  l_attribute1               VARCHAR2(150)  := p_attribute1;
  l_attribute2               VARCHAR2(150)  := p_attribute2;
  l_attribute3               VARCHAR2(150)  := p_attribute3;
  l_attribute4               VARCHAR2(150)  := p_attribute4;
  l_attribute5               VARCHAR2(150)  := p_attribute5;
  l_attribute6               VARCHAR2(150)  := p_attribute6;
  l_attribute7               VARCHAR2(150)  := p_attribute7;
  l_attribute8               VARCHAR2(150)  := p_attribute8;
  l_attribute9               VARCHAR2(150)  := p_attribute9;
  l_attribute10              VARCHAR2(150)  := p_attribute10;
  l_attribute11              VARCHAR2(150)  := p_attribute11;
  l_attribute12              VARCHAR2(150)  := p_attribute12;
  l_attribute13              VARCHAR2(150)  := p_attribute13;
  l_attribute14              VARCHAR2(150)  := p_attribute14;
  l_attribute15              VARCHAR2(150)  := p_attribute15;
  l_transaction_type         VARCHAR2(30)   := p_transaction_type;
  l_vendor_lot               VARCHAR2(30)   := p_vendor_lot;
  l_reason_id                NUMBER         := p_reason_id;

  l_qa_collection_id         NUMBER         := p_qa_collection_id;

  l_primary_qty              NUMBER;
  l_primary_uom_code         varchar2(5);

  l_rcv_transaction_id       number;
  l_rtv_qty                  number;
  l_rtv_uom                  varchar2(25); /* Each */
  l_rtv_uom_code             varchar2(5);  /* Ea */
  l_receipt_source_code      varchar2(25);
  l_tolerable_qty            number;

  l_remaining_qty            number;
  l_transacted_qty           number;

  l_return_status            varchar2(5);
  l_msg_count                number;
  l_msg_data                 varchar2(1000);

  l_secondary_qty    NUMBER := p_secondary_qty; --OPM COnvergence
  l_remaining_sec_qty NUMBER; --OPM Convergence
  l_rtv_sec_uom VARCHAR2(25);--OPM Convergence
  l_sec_uom_code VARCHAR2(3);--OPM Convergence
  l_sec_uom VARCHAR2(25);--OPM Convergence
  l_rtv_sec_qty NUMBER;--OPM COnvergence
   l_sec_remaining_qty NUMBER; --OPM Convergence

/*  cursor rtv_cursor(
    k_shipment_header_id   number
  , k_organization_id      number
  , k_inventory_item_id    number
  , k_revision             varchar2)
  is
  select
    rcv_transaction_id
  , receipt_source_code
  , unit_of_measure
  from rcv_transactions_v
  where  receipt_source_code <> 'VENDOR'
  and    shipment_header_id = k_shipment_header_id
  and    to_organization_id = k_organization_id
  and    item_id            = k_inventory_item_id
  and   (item_revision      = k_revision OR
         item_revision is null and p_revision is null)
  and    inspection_status_code = 'NOT INSPECTED'
  and    routing_id             = g_inspection_routing;
*/
/* Bug 1542687: For performance reasons, the cursor is based on base tables below.*/

 --bug 8405606 removed the condition for rt.inspection_status_code = 'NOT INSPECTED'
  cursor rtv_cursor(
    k_shipment_header_id   number
  , k_organization_id      number
  , k_inventory_item_id    number
  , k_revision             varchar2
  , k_revision_control     number -- Added for bug 3134272
  ) is
  select
    rs.rcv_transaction_id
  , rsh.receipt_source_code
  , rs.unit_of_measure
  , rs.secondary_unit_of_measure --OPM Convergence
  from rcv_supply rs, rcv_transactions rt, rcv_shipment_headers rsh
  where  rsh.receipt_source_code <> 'VENDOR'
  and    rs.shipment_header_id = k_shipment_header_id
  and    rs.to_organization_id = k_organization_id
  and    rs.item_id            = k_inventory_item_id
  and   (k_revision_control = 2
         and Nvl(rs.item_revision,-1)      = Nvl(k_revision,-1)
	 OR k_revision_control = 1)
  -- Changed the above for bug 3134272
  and    rs.rcv_transaction_id     = rt.transaction_id
  and    rsh.shipment_header_id    = rs.shipment_header_id
  and    rs.supply_type_code       = 'RECEIVING'
  and    rt.transaction_type      <> 'UNORDERED'
  and    rt.routing_header_id      = g_inspection_routing;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
  x_return_status := fnd_api.g_ret_sts_success;

  -- dbms_output.put_line('main_process_intransit: Just entering main_process_intransit');

    --First check if the transaction date satisfies the validation.
    --If the transaction date is invalid then error out the transaction
    IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
       --BUG 3444196: Used the HR view instead for performance reasons
       SELECT TO_NUMBER(hoi.org_information1)
	 INTO inv_rcv_common_apis.g_po_startup_value.sob_id
	 FROM hr_organization_information hoi
	 WHERE hoi.organization_id = p_organization_id
	 AND (hoi.org_information_context || '') = 'Accounting Information' ;
    END IF;

    inv_rcv_common_apis.validate_trx_date(
      p_trx_date            => SYSDATE
    , p_organization_id     => p_organization_id
    , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
    , x_return_status       => x_return_status
    , x_error_code          => x_msg_data
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

  savepoint inspect_main_intransit_sp;

  -- Quantity entered on form
  l_remaining_qty := l_quantity;

  -- Quantity successfully transacted
  l_transacted_qty := 0;

  -- One time fetch of item's primary uom code
  -- Fetching revision control for bug 3134272
  select primary_uom_code,revision_qty_control_code, secondary_uom_code --OPM Convergence
  into l_primary_uom_code,l_revision_control, l_rtv_sec_uom --OPM Convergence
  from mtl_system_items
  where organization_id   = l_organization_id
  and   inventory_item_id = l_inventory_item_id;

  -- dbms_output.put_line('main_process_intransit: Fetched item primary uom code');

  -- Purchasing/receiving uses unit of measure (Each)
  -- rather than uom code(Ea) and hence the following..
  -- This will be used later while inserting into interface table

  SELECT unit_of_measure
  INTO l_uom
  FROM mtl_units_of_measure
  WHERE  uom_code = l_uom_code;

  /* OPM Convergence */
    IF l_sec_uom_code IS NOT NULL THEN

       SELECT unit_of_measure
       INTO   l_sec_uom
       FROM   mtl_units_of_measure
       WHERE  uom_code = l_sec_uom_code;

    END IF;

  -- dbms_output.put_line('main_process_intransit: Convert inspection uom code into uom');

  -- Open RCV Transactions V cursor
  open rtv_cursor(
    l_shipment_header_id
  , l_organization_id
  , l_inventory_item_id
  , l_revision
  , l_revision_control -- Added for bug 3134272
  );

  -- dbms_output.put_line('main_process_intransit: Opened RTV Cursor');

  while(l_remaining_qty > 0)
  loop
        fetch rtv_cursor into
           l_rcv_transaction_id
         , l_receipt_source_code
         , l_rtv_uom
         , l_rtv_sec_qty; --OPM Convergence

        if rtv_cursor%notfound then
                exit;
        end if;

        -- Get quantity that can be still inspected

        RCV_QUANTITIES_S.GET_AVAILABLE_QUANTITY (
          'INSPECT'
        , l_rcv_transaction_id
        , l_receipt_source_code
        , null
        , l_rcv_transaction_id
        , null
        , l_rtv_qty
        , l_tolerable_qty
        , l_rtv_uom );

        if (l_rtv_qty > 0) then

	  -- dbms_output.put_line('main_process_intransit: convert rtv uom into uom code');

          SELECT uom_code
          INTO l_rtv_uom_code
          FROM mtl_units_of_measure
          WHERE  unit_of_measure = l_rtv_uom;

          -- If inspection uom is not same as receipt uom, convert

          if (l_uom_code <> l_rtv_uom_code) then
        	l_rtv_qty := inv_convert.inv_um_convert(
                               l_inventory_item_id
                             , NULL
                             , l_rtv_qty
                             , l_rtv_uom_code
                             , l_uom_code
                             , NULL
                             , NULL);
          end if;

          if l_rtv_qty >= l_remaining_qty then
             l_rtv_qty       := l_remaining_qty;
             l_rtv_sec_qty       := l_sec_remaining_qty;
             l_remaining_qty := 0;
             l_sec_remaining_qty := 0;
          else
             l_remaining_qty := l_remaining_qty - l_rtv_qty;
             l_sec_remaining_qty := l_sec_remaining_qty - l_rtv_sec_qty;
          end if;

	  -- If required convert into primary unit of measure
	  if (l_uom_code <> l_primary_uom_code) then

              	-- dbms_output.put_line('main_process_intransit: convet inspect uom into primary uom');

		l_primary_qty := inv_convert.inv_um_convert(
                               l_inventory_item_id
			     , NULL
                             , l_rtv_qty
                             , l_uom_code
                             , l_primary_uom_code
                   	     , NULL
			     , NULL);
          else
		l_primary_qty := l_rtv_qty;
	  end if;

          -- dbms_output.put_line('main_process_intransit: Calling insert_inspect_rec_rti');

          -- Insert into rti, passing l_rtv_qty, inspection information
          insert_inspect_rec_rti (
                  x_return_status  	=> l_return_status
                , x_msg_count           => l_msg_count
                , x_msg_data            => l_msg_data
                , p_rcv_transaction_id  => l_rcv_transaction_id
                , p_quantity            => l_rtv_qty
                , p_uom                 => l_uom
                , p_inspection_code     => l_inspection_code
                , p_quality_code        => l_quality_code
                , p_transaction_date    => l_transaction_date
		, p_transaction_type    => l_transaction_type
                , p_vendor_lot          => l_vendor_lot
 		, p_reason_id           => l_reason_id
		, p_primary_qty         => l_primary_qty
		, p_organization_id     => l_organization_id
		, p_comments            => l_comments
		, p_attribute_category  => l_attribute_category
		, p_attribute1          => l_attribute1
		, p_attribute2          => l_attribute2
		, p_attribute3          => l_attribute3
		, p_attribute4          => l_attribute4
		, p_attribute5          => l_attribute5
		, p_attribute6          => l_attribute6
		, p_attribute7          => l_attribute7
		, p_attribute8          => l_attribute8
		, p_attribute9          => l_attribute9
		, p_attribute10         => l_attribute10
		, p_attribute11         => l_attribute11
		, p_attribute12         => l_attribute12
		, p_attribute13         => l_attribute13
		, p_attribute14         => l_attribute14
		, p_attribute15         => l_attribute15
                , p_qa_collection_id    => l_qa_collection_id
                   , p_sec_uom   => l_sec_uom --OPM Convergence
                , p_secondary_qty => l_rtv_sec_qty); --OPM Convergence

          IF l_return_status = fnd_api.g_ret_sts_error THEN
         		RAISE fnd_api.g_exc_error;
	  END IF ;

    	  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         		RAISE fnd_api.g_exc_unexpected_error;
    	  END IF;

          -- dbms_output.put_line('main_process_intransit: Successful insert_inspect_rec_rti');

          -- Count successfully transacted qty
          l_transacted_qty       := l_transacted_qty + l_rtv_qty;
        end if;
  end loop;

  IF l_remaining_qty > 0 THEN
     FND_MESSAGE.set_name('INV','INV_QTY_LESS_OR_EQUAL');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  close rtv_cursor;

exception
   when fnd_api.g_exc_error THEN
      rollback to inspect_main_intransit_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;

   when fnd_api.g_exc_unexpected_error THEN
      rollback to inspect_main_intransit_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;

   when others THEN
      rollback to inspect_main_intransit_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'main_process_intransit'
              );
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;

end main_process_intransit;

procedure main_process_rma(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN  NUMBER
, p_organization_id             IN  NUMBER
, p_oe_order_header_id          IN  NUMBER
, p_revision                    IN  VARCHAR2
, p_uom_code                    IN  VARCHAR2
, p_quantity                    IN  NUMBER
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_type            IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_transaction_date            IN  DATE        DEFAULT SYSDATE
, p_qa_collection_id            IN  NUMBER      DEFAULT NULL
, p_vendor_lot                  IN  VARCHAR2    DEFAULT NULL
, p_comments                    IN  VARCHAR2	DEFAULT NULL
, p_attribute_category          IN  VARCHAR2    DEFAULT NULL
, p_attribute1                  IN  VARCHAR2    DEFAULT NULL
, p_attribute2                  IN  VARCHAR2    DEFAULT NULL
, p_attribute3                  IN  VARCHAR2    DEFAULT NULL
, p_attribute4                  IN  VARCHAR2    DEFAULT NULL
, p_attribute5                  IN  VARCHAR2    DEFAULT NULL
, p_attribute6                  IN  VARCHAR2    DEFAULT NULL
, p_attribute7                  IN  VARCHAR2    DEFAULT NULL
, p_attribute8                  IN  VARCHAR2    DEFAULT NULL
, p_attribute9                  IN  VARCHAR2    DEFAULT NULL
, p_attribute10                 IN  VARCHAR2    DEFAULT NULL
, p_attribute11                 IN  VARCHAR2    DEFAULT NULL
, p_attribute12                 IN  VARCHAR2    DEFAULT NULL
, p_attribute13                 IN  VARCHAR2    DEFAULT NULL
, p_attribute14                 IN  VARCHAR2    DEFAULT NULL
, p_attribute15                 IN  VARCHAR2    DEFAULT NULL
, p_secondary_qty               IN  NUMBER      DEFAULT NULL) --OPM Convergence)
is
  l_inventory_item_id           NUMBER 		:= p_inventory_item_id;
  l_organization_id             NUMBER 		:= p_organization_id;
  l_revision                    VARCHAR2(10)    := p_revision;
  l_revision_control            NUMBER; -- Added for bug 3134272
  l_uom_code                    VARCHAR2(5)     := p_uom_code;
  l_uom                         VARCHAR2(30);
  l_quantity                    NUMBER          := p_quantity;
  l_oe_order_header_id 		NUMBER		:= p_oe_order_header_id;

  l_inspection_code          VARCHAR2(25)   := p_inspection_code;
  l_quality_code             VARCHAR2(25)   := p_quality_code;
  l_transaction_date         DATE           := p_transaction_date;
  l_comments                 VARCHAR2(240)  := p_comments;
  l_attribute_category       VARCHAR2(30)   := p_attribute_category;
  l_attribute1               VARCHAR2(150)  := p_attribute1;
  l_attribute2               VARCHAR2(150)  := p_attribute2;
  l_attribute3               VARCHAR2(150)  := p_attribute3;
  l_attribute4               VARCHAR2(150)  := p_attribute4;
  l_attribute5               VARCHAR2(150)  := p_attribute5;
  l_attribute6               VARCHAR2(150)  := p_attribute6;
  l_attribute7               VARCHAR2(150)  := p_attribute7;
  l_attribute8               VARCHAR2(150)  := p_attribute8;
  l_attribute9               VARCHAR2(150)  := p_attribute9;
  l_attribute10              VARCHAR2(150)  := p_attribute10;
  l_attribute11              VARCHAR2(150)  := p_attribute11;
  l_attribute12              VARCHAR2(150)  := p_attribute12;
  l_attribute13              VARCHAR2(150)  := p_attribute13;
  l_attribute14              VARCHAR2(150)  := p_attribute14;
  l_attribute15              VARCHAR2(150)  := p_attribute15;
  l_transaction_type         VARCHAR2(30)   := p_transaction_type;
  l_vendor_lot               VARCHAR2(30)   := p_vendor_lot;
  l_reason_id                NUMBER         := p_reason_id;

  l_qa_collection_id         NUMBER         := p_qa_collection_id;

  l_primary_qty              NUMBER;
  l_primary_uom_code         varchar2(5);

  l_rcv_transaction_id       number;
  l_rtv_qty                  number;
  l_rtv_uom                  varchar2(25); /* Each */
  l_rtv_uom_code             varchar2(5);  /* Ea */
  l_receipt_source_code      varchar2(25);
  l_tolerable_qty            number;

  l_remaining_qty            number;
  l_transacted_qty           number;

  l_return_status            varchar2(5);
  l_msg_count                number;
  l_msg_data                 varchar2(1000);

    l_secondary_qty    NUMBER := p_secondary_qty; --OPM COnvergence
  l_remaining_sec_qty NUMBER; --OPM Convergence
  l_rtv_sec_uom VARCHAR2(25);--OPM Convergence
  l_sec_uom_code VARCHAR2(3);--OPM Convergence
  l_sec_uom VARCHAR2(25);--OPM Convergence
l_rtv_sec_qty NUMBER;--OPM COnvergence
 l_sec_remaining_qty NUMBER; --OPM Convergence
/* cursor rtv_cursor(
    k_oe_order_header_id   number
  , k_organization_id      number
  , k_inventory_item_id    number
  , k_revision             varchar2)
  is
  select
    rcv_transaction_id
  , receipt_source_code
  , unit_of_measure
  from rcv_transactions_v
  where  receipt_source_code = 'CUSTOMER'
  and    oe_order_header_id = k_oe_order_header_id
  and    to_organization_id = k_organization_id
  and    item_id            = k_inventory_item_id
  and   (item_revision      = k_revision OR
         item_revision is null and p_revision is null)
  and    inspection_status_code = 'NOT INSPECTED'
  and    routing_id             = g_inspection_routing;
*/
/* Bug 1542687: For performance reasons, the cursor is based on base tables below.*/

 --bug 8405606 removed the condition for rt.inspection_status_code = 'NOT INSPECTED'

  cursor rtv_cursor(
    k_oe_order_header_id   number
  , k_organization_id      number
  , k_inventory_item_id    number
  , k_revision             varchar2
  , k_revision_control     number -- Added for bug 3134272
  ) is
  select
    rs.rcv_transaction_id
  , rsh.receipt_source_code
  , rs.unit_of_measure
  , rs.secondary_unit_of_measure --OPM Convergence
  from rcv_supply rs, rcv_transactions rt, rcv_shipment_headers rsh
  where  rsh.receipt_source_code = 'CUSTOMER'
  and    rs.oe_order_header_id = k_oe_order_header_id
  and    rs.to_organization_id = k_organization_id
  and    rs.item_id            = k_inventory_item_id
  and   (k_revision_control = 2
         and Nvl(rs.item_revision,-1)      = Nvl(k_revision,-1)
	 OR k_revision_control = 1)
  -- Changed the above for bug 3134272
  and    rs.rcv_transaction_id     = rt.transaction_id
  and    rsh.shipment_header_id    = rs.shipment_header_id
  and    rs.supply_type_code       = 'RECEIVING'
  and    rt.transaction_type      <> 'UNORDERED'
  and    rt.routing_header_id      = g_inspection_routing;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
  x_return_status := fnd_api.g_ret_sts_success;

  -- dbms_output.put_line('main_process_rma: Just entering main_process_rma');
  --First check if the transaction date satisfies the validation.
  --If the transaction date is invalid then error out the transaction
  IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
     --BUG 3444196: Used the HR view instead for performance reasons
     SELECT TO_NUMBER(hoi.org_information1)
       INTO inv_rcv_common_apis.g_po_startup_value.sob_id
       FROM hr_organization_information hoi
       WHERE hoi.organization_id = p_organization_id
       AND (hoi.org_information_context || '') = 'Accounting Information' ;
  END IF;

  inv_rcv_common_apis.validate_trx_date(
    p_trx_date            => SYSDATE
  , p_organization_id     => p_organization_id
  , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
  , x_return_status       => x_return_status
  , x_error_code          => x_msg_data
  );

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RETURN;
  END IF;

  savepoint inspect_main_rma_sp;

  -- Quantity entered on form
  l_remaining_qty := l_quantity;

  -- Quantity successfully transacted
  l_transacted_qty := 0;

  -- One time fetch of item's primary uom code
  -- Fetching revision control for bug 3134272
  select primary_uom_code,revision_qty_control_code, secondary_uom_code --OPM Convergence
  into l_primary_uom_code,l_revision_control, l_sec_uom_code --OPM Convergence
  from mtl_system_items
  where organization_id   = l_organization_id
  and   inventory_item_id = l_inventory_item_id;

  -- dbms_output.put_line('main_process_rma: Fetched item primary uom code');

  -- Purchasing/receiving uses unit of measure (Each)
  -- rather than uom code(Ea) and hence the following..
  -- This will be used later while inserting into interface table

  SELECT unit_of_measure
  INTO l_uom
  FROM mtl_units_of_measure
  WHERE  uom_code = l_uom_code;

  /* OPM Convergence */
    IF l_sec_uom_code IS NOT NULL THEN

       SELECT unit_of_measure
       INTO   l_sec_uom
       FROM   mtl_units_of_measure
       WHERE  uom_code = l_sec_uom_code;

    END IF;
  -- dbms_output.put_line('main_process_rma: Convert inspection uom code into uom');

  -- Open RCV Transactions V cursor
  open rtv_cursor(
    l_oe_order_header_id
  , l_organization_id
  , l_inventory_item_id
  , l_revision
  , l_revision_control -- added for bug 3134272
  );

  -- dbms_output.put_line('main_process_rma: Opened RTV Cursor');

  while(l_remaining_qty > 0)
  loop
        fetch rtv_cursor into
           l_rcv_transaction_id
         , l_receipt_source_code
         , l_rtv_uom
         , l_rtv_sec_uom;

        if rtv_cursor%notfound then
                exit;
        end if;

        -- Get quantity that can be still inspected

        RCV_QUANTITIES_S.GET_AVAILABLE_QUANTITY (
          'INSPECT'
        , l_rcv_transaction_id
        , l_receipt_source_code
        , null
        , l_rcv_transaction_id
        , null
        , l_rtv_qty
        , l_tolerable_qty
        , l_rtv_uom );

        if (l_rtv_qty > 0) then

	  -- dbms_output.put_line('main_process_rma: convert rtv uom into uom code');

          SELECT uom_code
          INTO l_rtv_uom_code
          FROM mtl_units_of_measure
          WHERE  unit_of_measure = l_rtv_uom;

          -- If inspection uom is not same as receipt uom, convert

          if (l_uom_code <> l_rtv_uom_code) then
        	l_rtv_qty := inv_convert.inv_um_convert(
                               l_inventory_item_id
                             , NULL
                             , l_rtv_qty
                             , l_rtv_uom_code
                             , l_uom_code
                             , NULL
                             , NULL);
          end if;

          if l_rtv_qty >= l_remaining_qty then
             l_rtv_qty       := l_remaining_qty;
             l_remaining_qty := 0;
          else
             l_remaining_qty := l_remaining_qty - l_rtv_qty;
          end if;

	  -- If required convert into primary unit of measure
	  if (l_uom_code <> l_primary_uom_code) then

              	-- dbms_output.put_line('main_process_rma: convet inspect uom into primary uom');

		l_primary_qty := inv_convert.inv_um_convert(
                               l_inventory_item_id
			     , NULL
                             , l_rtv_qty
                             , l_uom_code
                             , l_primary_uom_code
                   	     , NULL
			     , NULL);
          else
		l_primary_qty := l_rtv_qty;
	  end if;

          -- dbms_output.put_line('main_process_rma: Calling insert_inspect_rec_rti');

          -- Insert into rti, passing l_rtv_qty, inspection information
          insert_inspect_rec_rti (
                  x_return_status  	=> l_return_status
                , x_msg_count           => l_msg_count
                , x_msg_data            => l_msg_data
                , p_rcv_transaction_id  => l_rcv_transaction_id
                , p_quantity            => l_rtv_qty
                , p_uom                 => l_uom
                , p_inspection_code     => l_inspection_code
                , p_quality_code        => l_quality_code
                , p_transaction_date    => l_transaction_date
		, p_transaction_type    => l_transaction_type
                , p_vendor_lot          => l_vendor_lot
 		, p_reason_id           => l_reason_id
		, p_primary_qty         => l_primary_qty
		, p_organization_id     => l_organization_id
		, p_comments            => l_comments
		, p_attribute_category  => l_attribute_category
		, p_attribute1          => l_attribute1
		, p_attribute2          => l_attribute2
		, p_attribute3          => l_attribute3
		, p_attribute4          => l_attribute4
		, p_attribute5          => l_attribute5
		, p_attribute6          => l_attribute6
		, p_attribute7          => l_attribute7
		, p_attribute8          => l_attribute8
		, p_attribute9          => l_attribute9
		, p_attribute10         => l_attribute10
		, p_attribute11         => l_attribute11
		, p_attribute12         => l_attribute12
		, p_attribute13         => l_attribute13
		, p_attribute14         => l_attribute14
		, p_attribute15         => l_attribute15
                , p_qa_collection_id    => l_qa_collection_id
                   , p_sec_uom   => l_sec_uom --OPM Convergence
                , p_secondary_qty => l_rtv_sec_qty); --OPM Convergence);

          IF l_return_status = fnd_api.g_ret_sts_error THEN
         		RAISE fnd_api.g_exc_error;
	  END IF ;

    	  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         		RAISE fnd_api.g_exc_unexpected_error;
    	  END IF;

          -- dbms_output.put_line('main_process_rma: Successful insert_inspect_rec_rti');

          -- Count successfully transacted qty
          l_transacted_qty       := l_transacted_qty + l_rtv_qty;
        end if;
  end loop;

  IF l_remaining_qty > 0 THEN
     FND_MESSAGE.set_name('INV','INV_QTY_LESS_OR_EQUAL');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  close rtv_cursor;

exception
   when fnd_api.g_exc_error THEN
      rollback to inspect_main_rma_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;

   when fnd_api.g_exc_unexpected_error THEN
      rollback to inspect_main_rma_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;

   when others THEN
      rollback to inspect_main_rma_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'main_process_rma'
              );
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;
end main_process_rma;

procedure main_process_receipt(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN  NUMBER
, p_organization_id             IN  NUMBER
, p_receipt_num                 IN  VARCHAR2
, p_revision                    IN  VARCHAR2
, p_uom_code                    IN  VARCHAR2
, p_quantity                    IN  NUMBER
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_type            IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_transaction_date            IN  DATE        DEFAULT SYSDATE
, p_qa_collection_id            IN  NUMBER      DEFAULT NULL
, p_vendor_lot                  IN  VARCHAR2    DEFAULT NULL
, p_comments                    IN  VARCHAR2	DEFAULT NULL
, p_attribute_category          IN  VARCHAR2    DEFAULT NULL
, p_attribute1                  IN  VARCHAR2    DEFAULT NULL
, p_attribute2                  IN  VARCHAR2    DEFAULT NULL
, p_attribute3                  IN  VARCHAR2    DEFAULT NULL
, p_attribute4                  IN  VARCHAR2    DEFAULT NULL
, p_attribute5                  IN  VARCHAR2    DEFAULT NULL
, p_attribute6                  IN  VARCHAR2    DEFAULT NULL
, p_attribute7                  IN  VARCHAR2    DEFAULT NULL
, p_attribute8                  IN  VARCHAR2    DEFAULT NULL
, p_attribute9                  IN  VARCHAR2    DEFAULT NULL
, p_attribute10                 IN  VARCHAR2    DEFAULT NULL
, p_attribute11                 IN  VARCHAR2    DEFAULT NULL
, p_attribute12                 IN  VARCHAR2    DEFAULT NULL
, p_attribute13                 IN  VARCHAR2    DEFAULT NULL
, p_attribute14                 IN  VARCHAR2    DEFAULT NULL
, p_attribute15                 IN  VARCHAR2    DEFAULT NULL
, p_secondary_qty               IN  NUMBER      DEFAULT NULL) --OPM Convergence)
is
  l_inventory_item_id           NUMBER 		:= p_inventory_item_id;
  l_organization_id             NUMBER 		:= p_organization_id;
  l_revision                    VARCHAR2(10)    := p_revision;
  l_revision_control            NUMBER; -- Added for bug 3134272
  l_uom_code                    VARCHAR2(5)     := p_uom_code;
  l_uom                         VARCHAR2(30);
  l_quantity                    NUMBER          := p_quantity;
  l_receipt_num 		NUMBER		:= p_receipt_num;

  l_inspection_code          VARCHAR2(25)   := p_inspection_code;
  l_quality_code             VARCHAR2(25)   := p_quality_code;
  l_transaction_date         DATE           := p_transaction_date;
  l_comments                 VARCHAR2(240)  := p_comments;
  l_attribute_category       VARCHAR2(30)   := p_attribute_category;
  l_attribute1               VARCHAR2(150)  := p_attribute1;
  l_attribute2               VARCHAR2(150)  := p_attribute2;
  l_attribute3               VARCHAR2(150)  := p_attribute3;
  l_attribute4               VARCHAR2(150)  := p_attribute4;
  l_attribute5               VARCHAR2(150)  := p_attribute5;
  l_attribute6               VARCHAR2(150)  := p_attribute6;
  l_attribute7               VARCHAR2(150)  := p_attribute7;
  l_attribute8               VARCHAR2(150)  := p_attribute8;
  l_attribute9               VARCHAR2(150)  := p_attribute9;
  l_attribute10              VARCHAR2(150)  := p_attribute10;
  l_attribute11              VARCHAR2(150)  := p_attribute11;
  l_attribute12              VARCHAR2(150)  := p_attribute12;
  l_attribute13              VARCHAR2(150)  := p_attribute13;
  l_attribute14              VARCHAR2(150)  := p_attribute14;
  l_attribute15              VARCHAR2(150)  := p_attribute15;
  l_transaction_type         VARCHAR2(30)   := p_transaction_type;
  l_vendor_lot               VARCHAR2(30)   := p_vendor_lot;
  l_reason_id                NUMBER         := p_reason_id;

  l_qa_collection_id         NUMBER         := p_qa_collection_id;

  l_primary_qty              NUMBER;
  l_primary_uom_code         varchar2(5);

  l_rcv_transaction_id       number;
  l_rtv_qty                  number;
  l_rtv_uom                  varchar2(25); /* Each */
  l_rtv_uom_code             varchar2(5);  /* Ea */
  l_receipt_source_code      varchar2(25);
  l_tolerable_qty            number;

  l_remaining_qty            number;
  l_transacted_qty           number;

  l_return_status            varchar2(5);
  l_msg_count                number;
  l_msg_data                 varchar2(1000);

    l_secondary_qty    NUMBER := p_secondary_qty; --OPM COnvergence
  l_remaining_sec_qty NUMBER; --OPM Convergence
  l_rtv_sec_uom VARCHAR2(25);--OPM Convergence
  l_sec_uom_code VARCHAR2(3);--OPM Convergence
  l_sec_uom VARCHAR2(25);--OPM Convergence
  l_rtv_sec_qty NUMBER;--OPM COnvergence
   l_sec_remaining_qty NUMBER; --OPM Convergence

/*  cursor rtv_cursor(
    k_receipt_num          varchar2
  , k_organization_id      number
  , k_inventory_item_id    number
  , k_revision             varchar2)
  is
  select
    rcv_transaction_id
  , receipt_source_code
  , unit_of_measure
  from rcv_transactions_v
  where  receipt_num        = k_receipt_num
  and    to_organization_id = k_organization_id
  and    item_id            = k_inventory_item_id
  and   (item_revision      = k_revision OR
         item_revision is null and p_revision is null)
  and    inspection_status_code = 'NOT INSPECTED'
  and    routing_id             = g_inspection_routing;
*/
/* Bug 1542687: For performance reasons, the cursor is based on base tables below.*/

 --bug 8405606 removed the condition for rt.inspection_status_code = 'NOT INSPECTED'

  cursor rtv_cursor(
    k_receipt_num          varchar2
  , k_organization_id      number
  , k_inventory_item_id    number
  , k_revision             varchar2
  , k_revision_control     number -- Added for bug 3134272
  ) is
  select
    rs.rcv_transaction_id
  , rsh.receipt_source_code
  , rs.unit_of_measure
  , rs.secondary_unit_of_measure --OPM Convergence
  from rcv_supply rs, rcv_transactions rt, rcv_shipment_headers rsh
  where  rsh.receipt_num           = k_receipt_num
  and    rs.to_organization_id     = k_organization_id
  and    rs.item_id                = k_inventory_item_id
  and   (k_revision_control = 2
         and Nvl(rs.item_revision,-1)          = Nvl(k_revision,-1)
	 OR k_revision_control = 1)
  -- Changed the above for bug 3134272
  and    rs.rcv_transaction_id     = rt.transaction_id
  and    rsh.shipment_header_id    = rs.shipment_header_id
  and    rs.supply_type_code       = 'RECEIVING'
  and    rt.transaction_type      <> 'UNORDERED'
  and    rt.routing_header_id      = g_inspection_routing;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
  x_return_status := fnd_api.g_ret_sts_success;

  -- dbms_output.put_line('main_process_receipt: Just entering main_process_receipt');
  --First check if the transaction date satisfies the validation.
  --If the transaction date is invalid then error out the transaction
  IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
     --BUG 3444196: Used the HR view instead for performance reasons
     SELECT TO_NUMBER(hoi.org_information1)
       INTO inv_rcv_common_apis.g_po_startup_value.sob_id
       FROM hr_organization_information hoi
       WHERE hoi.organization_id = p_organization_id
       AND (hoi.org_information_context || '') = 'Accounting Information' ;
  END IF;

  inv_rcv_common_apis.validate_trx_date(
    p_trx_date            => SYSDATE
  , p_organization_id     => p_organization_id
  , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
  , x_return_status       => x_return_status
  , x_error_code          => x_msg_data
  );

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RETURN;
  END IF;

  savepoint inspect_main_receipt_sp;

  -- Quantity entered on form
  l_remaining_qty := l_quantity;

  -- Quantity successfully transacted
  l_transacted_qty := 0;

  -- One time fetch of item's primary uom code
  -- Fetching revision control for bug 3134272
  select primary_uom_code,revision_qty_control_code, secondary_uom_code --OPM Convergence
  into l_primary_uom_code,l_revision_control, l_sec_uom_code --OPM Convergence
  from mtl_system_items
  where organization_id   = l_organization_id
  and   inventory_item_id = l_inventory_item_id;

  -- dbms_output.put_line('main_process_receipt: Fetched item primary uom code');

  -- Purchasing/receiving uses unit of measure (Each)
  -- rather than uom code(Ea) and hence the following..
  -- This will be used later while inserting into interface table

  SELECT unit_of_measure
  INTO l_uom
  FROM mtl_units_of_measure
  WHERE  uom_code = l_uom_code;

  /* OPM Convergence */
    IF l_sec_uom_code IS NOT NULL THEN

       SELECT unit_of_measure
       INTO   l_sec_uom
       FROM   mtl_units_of_measure
       WHERE  uom_code = l_sec_uom_code;

    END IF;
  -- dbms_output.put_line('main_process_receipt: Convert inspection uom code into uom');

  -- Open RCV Transactions V cursor
  open rtv_cursor(
    l_receipt_num
  , l_organization_id
  , l_inventory_item_id
  , l_revision
  , l_revision_control -- Added for bug 3134272
  );

  -- dbms_output.put_line('main_process_receipt: Opened RTV Cursor');

  IF (l_debug = 1) THEN
     print_debug('l_receipt_num is ' || to_char(l_receipt_num), 4);
  END IF;

  while(l_remaining_qty > 0)
  loop
        fetch rtv_cursor into
           l_rcv_transaction_id
         , l_receipt_source_code
         , l_rtv_uom
         , l_rtv_sec_uom; --OPM Convergence

        if rtv_cursor%notfound then
		IF (l_debug = 1) THEN
   		print_debug('exited from cursor', 4);
		END IF;
                exit;
        end if;

        -- Get quantity that can be still inspected

	IF (l_debug = 1) THEN
   	print_debug('l_rcv_transaction_id is  ' || to_char(l_rcv_transaction_id), 4);
   	print_debug('l_receipt_source_code is  ' || l_receipt_source_code, 4);
	END IF;
        RCV_QUANTITIES_S.GET_AVAILABLE_QUANTITY (
          'INSPECT'
        , l_rcv_transaction_id
        , l_receipt_source_code
        , null
        , l_rcv_transaction_id
        , null
        , l_rtv_qty
        , l_tolerable_qty
        , l_rtv_uom );

    	/*  print_debug('l_rtv_qty is ' || to_char(l_rtv_qty), 4);  */

        if (l_rtv_qty > 0) then

	  -- dbms_output.put_line('main_process_receipt: convert rtv uom into uom code');

          SELECT uom_code
          INTO l_rtv_uom_code
          FROM mtl_units_of_measure
          WHERE  unit_of_measure = l_rtv_uom;

          -- If inspection uom is not same as receipt uom, convert

          if (l_uom_code <> l_rtv_uom_code) then
        	l_rtv_qty := inv_convert.inv_um_convert(
                               l_inventory_item_id
                             , NULL
                             , l_rtv_qty
                             , l_rtv_uom_code
                             , l_uom_code
                             , NULL
                             , NULL);
          end if;

          if l_rtv_qty >= l_remaining_qty then
             l_rtv_qty       := l_remaining_qty;
             l_rtv_sec_qty       := l_sec_remaining_qty; --OPM Convergence
             l_remaining_qty := 0;
             l_sec_remaining_qty := 0; --OPM Convergence
          else
             l_remaining_qty := l_remaining_qty - l_rtv_qty;
             l_sec_remaining_qty := l_sec_remaining_qty - l_rtv_sec_qty; --OPM Convergence
          end if;

	  -- If required convert into primary unit of measure
	  if (l_uom_code <> l_primary_uom_code) then

              	-- dbms_output.put_line('main_process_receipt: convet inspect uom into primary uom');

		l_primary_qty := inv_convert.inv_um_convert(
                               l_inventory_item_id
			     , NULL
                             , l_rtv_qty
                             , l_uom_code
                             , l_primary_uom_code
                   	     , NULL
			     , NULL);
          else
		l_primary_qty := l_rtv_qty;
	  end if;

          -- dbms_output.put_line('main_process_receipt: Calling insert_inspect_rec_rti');

          -- Insert into rti, passing l_rtv_qty, inspection information
          insert_inspect_rec_rti (
                  x_return_status  	=> l_return_status
                , x_msg_count           => l_msg_count
                , x_msg_data            => l_msg_data
                , p_rcv_transaction_id  => l_rcv_transaction_id
                , p_quantity            => l_rtv_qty
                , p_uom                 => l_uom
                , p_inspection_code     => l_inspection_code
                , p_quality_code        => l_quality_code
                , p_transaction_date    => l_transaction_date
		, p_transaction_type    => l_transaction_type
                , p_vendor_lot          => l_vendor_lot
 		, p_reason_id           => l_reason_id
		, p_primary_qty         => l_primary_qty
		, p_organization_id     => l_organization_id
		, p_comments            => l_comments
		, p_attribute_category  => l_attribute_category
		, p_attribute1          => l_attribute1
		, p_attribute2          => l_attribute2
		, p_attribute3          => l_attribute3
		, p_attribute4          => l_attribute4
		, p_attribute5          => l_attribute5
		, p_attribute6          => l_attribute6
		, p_attribute7          => l_attribute7
		, p_attribute8          => l_attribute8
		, p_attribute9          => l_attribute9
		, p_attribute10         => l_attribute10
		, p_attribute11         => l_attribute11
		, p_attribute12         => l_attribute12
		, p_attribute13         => l_attribute13
		, p_attribute14         => l_attribute14
		, p_attribute15         => l_attribute15
                , p_qa_collection_id    => l_qa_collection_id ,
                  p_sec_uom   => l_sec_uom --OPM Convergence
                , p_secondary_qty => l_rtv_sec_qty); --OPM Convergence

          IF l_return_status = fnd_api.g_ret_sts_error THEN
		IF (l_debug = 1) THEN
   		print_debug('exc_error ' || l_return_status, 4);
		END IF;
         		RAISE fnd_api.g_exc_error;
	  END IF ;

    	  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		IF (l_debug = 1) THEN
   		print_debug('exc_unexpected_error ' || l_return_status, 4);
		END IF;
         		RAISE fnd_api.g_exc_unexpected_error;
    	  END IF;

          -- dbms_output.put_line('main_process_receipt: Successful insert_inspect_rec_rti');

          -- Count successfully transacted qty
          l_transacted_qty       := l_transacted_qty + l_rtv_qty;
		IF (l_debug = 1) THEN
   		print_debug('transacted qty ' || l_transacted_qty, 4);
		END IF;
        end if;
		IF (l_debug = 1) THEN
   		print_debug('remaining qty ' || l_remaining_qty, 4);
		END IF;
  end loop;

  IF l_remaining_qty > 0 THEN
     FND_MESSAGE.set_name('INV','INV_QTY_LESS_OR_EQUAL');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  close rtv_cursor;

exception
   when fnd_api.g_exc_error THEN
	IF (l_debug = 1) THEN
   	print_debug('Jumped to Exception exc_error ', 4);
	END IF;
      rollback to inspect_main_receipt_sp;

      x_return_status := fnd_api.g_ret_sts_error;
	IF (l_debug = 1) THEN
   	print_debug('Jumped to Exception exc_error ' || x_return_status, 4);
	END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;

   when fnd_api.g_exc_unexpected_error THEN
	IF (l_debug = 1) THEN
   	print_debug('Jumped to Exception unexpected_exc_error ', 4);
	END IF;
      rollback to inspect_main_receipt_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;
	IF (l_debug = 1) THEN
   	print_debug('Jumped to Exception unexpected_exc_error ' || x_return_status, 4);
	END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;

   when others THEN
	IF (l_debug = 1) THEN
   	print_debug('Jumped to Exception others', 4);
	END IF;
      rollback to inspect_main_receipt_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;
	IF (l_debug = 1) THEN
   	print_debug('Jumped to Exception others' || x_return_status, 4);
	END IF;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'main_process_receipt'
              );
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (rtv_cursor%isopen) THEN
	CLOSE rtv_cursor;
      END IF;
end main_process_receipt;

procedure insert_inspect_rec_rti (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_rcv_transaction_id          IN  NUMBER
, p_quantity                    IN  NUMBER
, p_uom                         IN  VARCHAR2
, p_inspection_code             IN  VARCHAR2
, p_quality_code                IN  VARCHAR2
, p_transaction_date            IN  DATE
, p_transaction_type            IN  VARCHAR2
, p_vendor_lot                  IN  VARCHAR2
, p_reason_id                   IN  NUMBER
, p_primary_qty                 IN  NUMBER
, p_organization_id             IN  NUMBER
, p_comments                    IN  VARCHAR2 DEFAULT NULL
, p_attribute_category          IN  VARCHAR2 DEFAULT NULL
, p_attribute1                  IN  VARCHAR2 DEFAULT NULL
, p_attribute2                  IN  VARCHAR2 DEFAULT NULL
, p_attribute3                  IN  VARCHAR2 DEFAULT NULL
, p_attribute4                  IN  VARCHAR2 DEFAULT NULL
, p_attribute5                  IN  VARCHAR2 DEFAULT NULL
, p_attribute6                  IN  VARCHAR2 DEFAULT NULL
, p_attribute7                  IN  VARCHAR2 DEFAULT NULL
, p_attribute8                  IN  VARCHAR2 DEFAULT NULL
, p_attribute9                  IN  VARCHAR2 DEFAULT NULL
, p_attribute10                 IN  VARCHAR2 DEFAULT NULL
, p_attribute11                 IN  VARCHAR2 DEFAULT NULL
, p_attribute12                 IN  VARCHAR2 DEFAULT NULL
, p_attribute13                 IN  VARCHAR2 DEFAULT NULL
, p_attribute14                 IN  VARCHAR2 DEFAULT NULL
, p_attribute15                 IN  VARCHAR2 DEFAULT NULL
, p_qa_collection_id            IN  NUMBER   DEFAULT NULL
, p_lpn_id                      IN  NUMBER   DEFAULT NULL
, p_transfer_lpn_id             IN  NUMBER   DEFAULT NULL
, p_mmtt_temp_id                IN  NUMBER   DEFAULT NULL
, p_sec_uom                     IN  VARCHAR2 DEFAULT NULL --OPM Convergenc
, p_secondary_qty               IN  NUMBER   DEFAULT NULL
  ) --OPM Convergence)
  is
  l_interface_transaction_id NUMBER;
  l_group_id                 NUMBER;

  l_user_id            	     NUMBER;
  l_logon_id                 NUMBER;
  l_employee_id              NUMBER;
  l_processor_value          VARCHAR2(10);

  l_dest_type_code           VARCHAR2(25)   := 'RECEIVING';
  l_po_dist_id               NUMBER         := NULL;
  l_deliver_to_location_id   NUMBER         := NULL;
  l_dest_context             VARCHAR2(30)   := 'RECEIVING';
  l_movement_id              NUMBER         := NULL;

  l_inspection_type          VARCHAR2(30);

  l_rcv_transaction_id       NUMBER         := p_rcv_transaction_id;
  l_quantity                 NUMBER         := p_quantity;
  l_uom                      VARCHAR2(25)   := p_uom;
  l_inspection_code          VARCHAR2(25)   := p_inspection_code;
  l_quality_code             VARCHAR2(25)   := p_quality_code;
  l_transaction_date         DATE           := p_transaction_date;
  l_organization_id          NUMBER         := p_organization_id;
  l_comments                 VARCHAR2(240)  := p_comments;
  l_attribute_category       VARCHAR2(30)   := p_attribute_category;
  l_attribute1               VARCHAR2(150)  := p_attribute1;
  l_attribute2               VARCHAR2(150)  := p_attribute2;
  l_attribute3               VARCHAR2(150)  := p_attribute3;
  l_attribute4               VARCHAR2(150)  := p_attribute4;
  l_attribute5               VARCHAR2(150)  := p_attribute5;
  l_attribute6               VARCHAR2(150)  := p_attribute6;
  l_attribute7               VARCHAR2(150)  := p_attribute7;
  l_attribute8               VARCHAR2(150)  := p_attribute8;
  l_attribute9               VARCHAR2(150)  := p_attribute9;
  l_attribute10              VARCHAR2(150)  := p_attribute10;
  l_attribute11              VARCHAR2(150)  := p_attribute11;
  l_attribute12              VARCHAR2(150)  := p_attribute12;
  l_attribute13              VARCHAR2(150)  := p_attribute13;
  l_attribute14              VARCHAR2(150)  := p_attribute14;
  l_attribute15              VARCHAR2(150)  := p_attribute15;
  l_transaction_type         VARCHAR2(30)   := p_transaction_type;
  l_vendor_lot               VARCHAR2(30)   := p_vendor_lot;
  l_reason_id                NUMBER         := p_reason_id;
  l_primary_qty              NUMBER         := p_primary_qty;

  l_sec_uom VARCHAR2(25) := p_sec_uom;--OPM Convergence
  l_secondary_qty number := p_secondary_qty; --OPM Convergence

  l_receipt_source_code      VARCHAR2(25);
  l_source_document_code     VARCHAR2(25);
  l_shipment_hdr_id          NUMBER;
  l_shipment_line_id         NUMBER;
  l_substitute_code          VARCHAR2(25);
  l_transaction_id           NUMBER;
  l_po_hdr_id                NUMBER;
  l_po_release_id            NUMBER;
  l_po_line_id               NUMBER;
  l_po_line_location_id      NUMBER;
  l_po_rev_num               NUMBER;
  l_po_unit_price            NUMBER;
  l_currency_code            VARCHAR2(15);
  l_currency_conv_rate       NUMBER;
  l_currency_conv_date       DATE;
  l_currency_conv_type       VARCHAR2(30);
  l_req_line_id              NUMBER;
  l_req_dist_id              NUMBER;
  l_routing_id               NUMBER;
  l_routing_step_id          NUMBER;
  l_location_id              NUMBER;
  l_category_id              NUMBER;
  l_primary_uom              VARCHAR2(25);
  l_item_id                  NUMBER;
  l_item_revision            VARCHAR2(3);
  l_vendor_id                NUMBER;
  l_mtl_lot                  NUMBER;
  l_mtl_serial               NUMBER;
  l_routing_header_id        NUMBER;
  l_qa_collection_id         NUMBER;
  l_ussgl_transaction_code   VARCHAR2(30);
  l_government_context       VARCHAR2(30);
  l_vendor_site_id           NUMBER;
  l_oe_order_header_id       NUMBER;
  l_oe_order_line_id         NUMBER;
  l_customer_id              NUMBER;
  l_customer_site_id         NUMBER;
  l_customer_item_number     VARCHAR2(30);
  l_lpn_id                   NUMBER := p_lpn_id;
  l_transfer_lpn_id          NUMBER := p_transfer_lpn_id;
  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_receipt_num              VARCHAR2(30);
  l_validation_flag          VARCHAR2(1);
  l_lpn_group_id             NUMBER;
  l_mmtt_temp_id             NUMBER := p_mmtt_temp_id;
  l_lpn_sub                  mtl_secondary_inventories.secondary_inventory_name%TYPE;
  l_lpn_loc_id               NUMBER;
  l_xfer_lpn_sub             mtl_secondary_inventories.secondary_inventory_name%TYPE;
  l_xfer_lpn_loc_id          NUMBER;
  l_xfer_lpn_ctxt            NUMBER;
  l_rti_sub_code             mtl_secondary_inventories.secondary_inventory_name%TYPE;
  l_rti_loc_id               NUMBER;

  l_rti_project_id           NUMBER := NULL;
  l_rti_task_id              NUMBER := NULL;


-- For Bug 7440217
     v_lcm_enabled_org  varchar2(1);
     v_pre_receive      varchar2(1);
     v_lcm_ship_line_id NUMBER;
     v_unit_landed_cost NUMBER;
-- End for Bug 7440217


  l_operating_unit_id MO_GLOB_ORG_ACCESS_TMP.ORGANIZATION_ID%TYPE;   --<R12 MOAC>

begin
  x_return_status     := fnd_api.g_ret_sts_success;

  savepoint insert_rti_sp;

  SELECT
    rsh.RECEIPT_SOURCE_CODE
    , rt.SOURCE_DOCUMENT_CODE
    , rsup.SHIPMENT_HEADER_ID
    , rsup.SHIPMENT_LINE_ID
    , rt.SUBSTITUTE_UNORDERED_CODE
    , rsup.RCV_TRANSACTION_ID
    , rsup.PO_HEADER_ID
    , rsup.PO_RELEASE_ID
    , rsup.PO_LINE_ID
    , rsup.PO_LINE_LOCATION_ID
    , rt.PO_REVISION_NUM
    , NVL(PLL.PRICE_OVERRIDE, POL.UNIT_PRICE)
    , rt.CURRENCY_CODE
    , rt.CURRENCY_CONVERSION_RATE
    , rt.CURRENCY_CONVERSION_DATE
    , rt.CURRENCY_CONVERSION_TYPE
    , rsup.REQ_LINE_ID
    , rsl.REQ_DISTRIBUTION_ID
    , rt.ROUTING_header_ID
    , rt.ROUTING_STEP_ID
    , rt.LOCATION_ID
    , rsl.CATEGORY_ID
    , rt.PRIMARY_Unit_of_measure
    , rsup.ITEM_ID
    , rsup.ITEM_REVISION
    , rsh.VENDOR_ID
    , msi.LOT_CONTROL_CODE
    , msi.SERIAL_NUMBER_CONTROL_CODE
    , rt.ROUTING_HEADER_ID
    , rt.QA_COLLECTION_ID
    , rsl.USSGL_TRANSACTION_CODE
    , rsl.GOVERNMENT_CONTEXT
    , rt.VENDOR_SITE_ID
    , rsup.OE_ORDER_HEADER_ID
    , rsup.OE_ORDER_LINE_ID
    , rsh.CUSTOMER_ID
    , rsh.CUSTOMER_SITE_ID
    , decode(oel.item_identifier_type, 'CUST', MCI.CUSTOMER_ITEM_NUMBER, '')
  INTO
    l_receipt_source_code
    , l_source_document_code
    , l_shipment_hdr_id
    , l_shipment_line_id
    , l_substitute_code
    , l_transaction_id
    , l_po_hdr_id
    , l_po_release_id
    , l_po_line_id
    , l_po_line_location_id
    , l_po_rev_num
    , l_po_unit_price
    , l_currency_code
    , l_currency_conv_rate
    , l_currency_conv_date
    , l_currency_conv_type
    , l_req_line_id
    , l_req_dist_id
    , l_routing_id
    , l_routing_step_id
    , l_location_id
    , l_category_id
    , l_primary_uom
    , l_item_id
    , l_item_revision
    , l_vendor_id
    , l_mtl_lot
    , l_mtl_serial
    , l_routing_header_id
    , l_qa_collection_id
    , l_USSGL_TRANSACTION_CODE
    , l_GOVERNMENT_CONTEXT
    , l_vendor_site_id
    , l_oe_order_header_id
    , l_oe_order_line_id
    , l_customer_id
    , l_customer_site_id
    , l_customer_item_number
    FROM rcv_supply rsup
        ,rcv_shipment_headers rsh
        ,rcv_shipment_lines rsl
        ,rcv_transactions rt
        ,po_line_locations pll
        ,po_lines pol
        ,mtl_system_items msi
        ,mtl_customer_items mci
        ,oe_order_lines_all oel
    WHERE rt.transaction_id = l_rcv_transaction_id
    AND   rt.transaction_type <> 'UNORDERED'
    AND   rsup.supply_type_code = 'RECEIVING'
    AND   rsup.rcv_transaction_id = rt.transaction_id
    AND   rsh.shipment_header_id = rsup.shipment_header_id
    AND   rsl.shipment_line_id = rsup.shipment_line_id
    AND   pll.line_location_id(+)    = rsup.po_line_location_id
    AND   pol.po_line_id(+)          = rsup.po_line_id
    AND   msi.organization_id  (+)  = rsup.to_organization_id
    AND   msi.inventory_item_id (+)  = rsup.item_id
    AND   oel.line_id(+)             = rsup.oe_order_line_id
    AND   oel.ordered_item_id       = mci.customer_item_id(+);

Begin
       IF (l_debug = 1) THEN
          print_debug('IN INSERT_INSPECT_REC_RTF ',9);
       END IF;
       SELECT receipt_num
       INTO   l_receipt_num
       FROM   rcv_shipment_headers
       WHERE  shipment_header_id = l_shipment_hdr_id
       AND    ship_to_org_id = p_organization_id;

       inv_rcv_common_apis.g_rcv_global_var.receipt_num := l_receipt_num;
       IF (l_debug = 1) THEN
          print_debug('create_intship_rcpt_intf_rec: 10.1 '|| inv_rcv_common_apis.g_rcv_global_var.receipt_num, 9);
       END IF;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_receipt_num := NULL;
END; --end of changes for bug 2894137

/*
  dbms_output.put_line('insinsprecrti: rcvtcnid '    || l_rcv_transaction_id);
  dbms_output.put_line('insinsprecrti: poid '        || l_po_hdr_id);
  dbms_output.put_line('insinsprecrti: polineid '    || l_po_line_id);
  dbms_output.put_line('insinsprecrti: polinelocid ' || l_po_line_location_id);
  */
  INV_RCV_COMMON_APIS.init_startup_values(l_organization_id);

  l_user_id          := INV_RCV_COMMON_APIS.g_po_startup_value.user_id;
  l_logon_id         := INV_RCV_COMMON_APIS.g_po_startup_value.logon_id;
  l_employee_id      := INV_RCV_COMMON_APIS.g_po_startup_value.employee_id;
  l_processor_value  := INV_RCV_COMMON_APIS.g_po_startup_value.transaction_mode;

  IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id is NULL THEN
      SELECT rcv_interface_groups_s.nextval
      INTO   l_group_id FROM   dual;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
  ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
  END IF;

  select rcv_transactions_interface_s.nextval
  into l_interface_transaction_id from dual;


  if l_inspection_code = 'ACCEPT' then
    l_inspection_type := 'ACCEPTED';
  else
    l_inspection_type := 'REJECTED';
  end if;

  SELECT RT.MOVEMENT_ID
  INTO   l_movement_id
  FROM   RCV_TRANSACTIONS RT
  WHERE  RT.TRANSACTION_ID = l_rcv_transaction_id;

  --<R12 MOAC>
  l_operating_unit_id := inv_rcv_common_apis.get_operating_unit_id( l_receipt_source_code,
                                                                    l_po_hdr_id,
                                                                    l_req_line_id,
                                                                    l_oe_order_header_id );

  /*
  ** If collection id is passed (by QA) use it i.e.overwrite
  ** l_qa_collection_id
  */

  if (p_qa_collection_id is not null) then
	l_qa_collection_id := p_qa_collection_id;
  end if;

  /* FP-J Enhancement
   * Populate the LPN_GROUP_ID, validation_flag columns, subinventory
   * and locator_id columns in RTI if WMS and PO patch levels are J or higher
   */
  IF ((inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
      (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
    l_validation_flag := 'Y';
    l_lpn_group_id    := l_group_id;

    /* If the current transaction is LPN-based (for a WMS org), then we need to
     * populate the subinventory,locator_id columns in the RTI record
     * If the transfer LPN has context "Resides in Receiving" Then
     *   Populate the RTI record from WLPN for the transfer LPN
     * Else
     *  Populate the RTI record from WLPN for the inspected LPN
     * End If
     */
    IF (p_lpn_id IS NOT NULL OR p_transfer_lpn_id IS NOT NULL) THEN
      BEGIN
        SELECT   lpn_context
               , subinventory_code
               , locator_id
        INTO     l_xfer_lpn_ctxt
               , l_xfer_lpn_sub
               , l_xfer_lpn_loc_id
        FROM     wms_license_plate_numbers
        WHERE    lpn_id = p_transfer_lpn_id;

        IF (NVL(l_xfer_lpn_ctxt, 5) = 3) THEN
          l_rti_sub_code := l_xfer_lpn_sub;
          l_rti_loc_id   := l_xfer_lpn_loc_id;
        ELSE
          --Transfer LPN has been generated afresh, so we need to default the RTI
          --with the sub/locator of the inspected LPN
          BEGIN
            SELECT   subinventory_code
                   , locator_id
            INTO     l_lpn_sub
                   , l_lpn_loc_id
            FROM     wms_license_plate_numbers
            WHERE    lpn_id = p_lpn_id;

            l_rti_sub_code := l_lpn_sub;
            l_rti_loc_id   := l_lpn_loc_id;

          EXCEPTION
            WHEN OTHERS THEN
              l_rti_sub_code := NULL;
              l_rti_loc_id   := NULL;
          END;
        END IF;   --END IF check xfer lpn context
      EXCEPTION
        WHEN OTHERS THEN
          l_rti_sub_code := NULL;
          l_rti_loc_id   := NULL;
      END;

      -- For lpn transactions we also need to populate project and task
      -- FROM mol
      IF (p_lpn_id IS NOT NULL) THEN
          IF (l_debug = 1) THEN
                 print_debug('insert_inspect_rec_rti: Before calculating project ' , 4);
          END IF;
	 BEGIN
	    SELECT project_id
	      , task_id
	      INTO l_rti_project_id
	      , l_rti_task_id
	      FROM mtl_txn_request_lines
	      WHERE lpn_id = p_lpn_id
	      AND inventory_item_id = l_item_id
              -- Bug 3366617
              -- The following check was not needed as the process_flag is not yet updated.
	      -- AND wms_process_flag = 2
	      AND ROWNUM < 2;
	 EXCEPTION
	    WHEN OTHERS THEN
              IF (l_debug = 1) THEN
                 print_debug('insert_inspect_rec_rti: In the exception of calculating project ' , 4);
              END IF;
	       l_rti_project_id := NULL;
	       l_rti_task_id    := NULL;
	 END;
      END IF; --IF (p_lpn_id IN NOT NULL) THEN
     ELSE
	   --For a non-LPN based transaction, subinventory/locator would be NULL
	   l_rti_sub_code := NULL;
	   l_rti_loc_id   := NULL;
	   --For non-lpn based transactions, project/task will also be null
	   l_rti_project_id := NULL;
	   l_rti_task_id    := NULL;
    END IF;
    --WMS or PO patch levels are < J, default the values for these new columns to NULL
  ELSE
    l_validation_flag := NULL;
    l_lpn_group_id    := NULL;
    l_rti_sub_code    := NULL;
    l_rti_loc_id      := NULL;
    l_rti_project_id  := NULL;
    l_rti_task_id     := NULL;
  END IF;

  IF (l_debug = 1) THEN
    print_debug('insert_inspect_rec_rti: validation_flag : ' || l_validation_flag || ', lpn_group_id: ' || l_lpn_group_id, 4);
    print_debug('insert_inspect_rec_rti: subinventory : ' || l_rti_sub_code || ', locator_id: ' || l_rti_loc_id, 4);
  END IF;

  -- bug 3452845
  IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
      (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
     l_transaction_date := Sysdate;
   ELSE
     l_transaction_date := Trunc(Sysdate);
  END IF;

  insert into RCV_TRANSACTIONS_INTERFACE
      (
        receipt_source_code,
        interface_transaction_id,
        group_id,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        last_update_login,
        interface_source_code,
        source_document_code,
        destination_type_code,
        transaction_date,
        quantity,
        unit_of_measure,
        shipment_header_id,
        shipment_line_id,
        substitute_unordered_code,
        employee_id,
        parent_transaction_id,
        inspection_status_code,
        inspection_quality_code,
        po_header_id,
        po_release_id,
        po_line_id,
        po_line_location_id,
        po_distribution_id,
        po_revision_num,
        po_unit_price,
        currency_code,
        currency_conversion_rate,
        requisition_line_id,
        req_distribution_id,
        routing_header_id,
        routing_step_id,
        comments,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        transaction_type,
        location_id,
        processing_status_code,
        processing_mode_code,
        transaction_status_code,
        category_id,
        vendor_lot_num,
        reason_id,
        primary_quantity,
        primary_unit_of_measure,
        item_id,
        item_revision,
        to_organization_id,
        deliver_to_location_id,
        destination_context,
        vendor_id,
        use_mtl_lot,
        use_mtl_serial,
        movement_id,
        currency_conversion_date,
        currency_conversion_type,
        qa_collection_id,
        ussgl_transaction_code,
        government_context,
        vendor_site_id,
        oe_order_header_id,
        oe_order_line_id,
        customer_id,
        customer_site_id,
        lpn_id,
        transfer_lpn_id,
        mobile_txn,
        validation_flag,
        lpn_group_id,
        mmtt_temp_id,
        subinventory,
        locator_id,
        project_id,
        task_id,
        secondary_quantity, --OPM Convergence
        secondary_unit_of_measure, --OPM Convergence
        org_id              --<R12 MOAC>
        )
  values
      (
        l_receipt_source_code,
        l_interface_transaction_id,
        l_group_id,
        SYSDATE,
        l_user_id,
        l_user_id,
        SYSDATE,
        l_logon_id,
        'RCV',
        l_source_document_code,
        l_dest_type_code,
        l_transaction_date,
        l_quantity,
        l_uom,
        l_shipment_hdr_id,
        l_shipment_line_id,
        l_substitute_code,
        l_employee_id,
        l_transaction_id,
        l_inspection_type,
        l_quality_code,
        l_po_hdr_id,
        l_po_release_id,
        l_po_line_id,
        l_po_line_location_id,
        l_po_dist_id,
        l_po_rev_num,
        l_po_unit_price,
        l_currency_code,
        l_currency_conv_rate,
        l_req_line_id,
        l_req_dist_id,
        l_routing_id,
        l_routing_step_id,
        l_comments,
        l_attribute_category,
        l_attribute1,
        l_attribute2,
        l_attribute3,
        l_attribute4,
        l_attribute5,
        l_attribute6,
        l_attribute7,
        l_attribute8,
        l_attribute9,
        l_attribute10,
        l_attribute11,
        l_attribute12,
        l_attribute13,
        l_attribute14,
        l_attribute15,
        l_transaction_type,
        l_location_id,
        'PENDING', -- Formerly INSPECTION
        l_processor_value,
        'PENDING', -- Formerly INSPECTION
        l_category_id,
        l_vendor_lot,
        l_reason_id,
        l_primary_qty,
        l_primary_uom,
        l_item_id,
        l_item_revision,
        l_organization_id,
        l_deliver_to_location_id,
        l_dest_context,
        l_vendor_id,
        l_mtl_lot,
        l_mtl_serial,
        l_movement_id,
        Trunc(l_currency_conv_date),
        l_currency_conv_type,
        l_qa_collection_id,
        l_ussgl_transaction_code,
        l_government_context,
        l_vendor_site_id,
        l_oe_order_header_id,
        l_oe_order_line_id,
        l_customer_id,
        l_customer_site_id,
        l_lpn_id,
        l_transfer_lpn_id,
        'Y',
        l_validation_flag,
        l_lpn_group_id,
        l_mmtt_temp_id,
        l_rti_sub_code,
        l_rti_loc_id,
        l_rti_project_id,
        l_rti_task_id,
        l_secondary_qty, --OPM Convergence
        l_sec_uom, --OPM Convergence
        l_operating_unit_id  --<R12 MOAC>
        );



-- For Bug 7440217 added the following code to update RTI with the status as PENDING so that it gets picked up for processing
  SELECT  mp.lcm_enabled_flag
  INTO    v_lcm_enabled_org
  FROM    mtl_parameters mp
  WHERE	  mp.organization_id = l_organization_id;

  SELECT  rp.pre_receive
  INTO    v_pre_receive
  FROM    rcv_parameters rp
  WHERE	  rp.organization_id = l_organization_id;

  IF	nvl(v_lcm_enabled_org, 'N') = 'Y' THEN

		  SELECT	LCM_SHIPMENT_LINE_ID, UNIT_LANDED_COST
		  INTO		v_lcm_ship_line_id, v_unit_landed_cost
		  FROM		rcv_shipment_lines
		  WHERE		shipment_line_id = l_shipment_line_id;

		  UPDATE	rcv_transactions_interface
		  SET		lcm_shipment_line_id = v_lcm_ship_line_id,
				    unit_landed_cost = v_unit_landed_cost
		  WHERE		interface_transaction_id = l_interface_transaction_id
		  AND		to_organization_id = l_organization_id;
 END IF;
-- End for Bug 7440217



  --Set the global variable for interface_transaction_id to be used in
  --setting product_transaction_id for the MTLI/MSNI records
  g_interface_transaction_id := l_interface_transaction_id;

exception
   when fnd_api.g_exc_error THEN
      rollback to insert_rti_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

   when fnd_api.g_exc_unexpected_error THEN
      rollback to insert_rti_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

   when others THEN
      rollback to insert_rti_sp;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'insert_inspect_rec_rti'
              );
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
end insert_inspect_rec_rti;

procedure rcv_manager_rpc_call(
  x_return_status out NOCOPY varchar2
, x_return_code   out NOCOPY number)
is
   rc 		NUMBER;
   --l_timeout 	NUMBER 		:= 300;
   l_timeout    NUMBER; ----bug 5169107
   l_outcome 	VARCHAR2(200) 	:= NULL;
   l_message 	VARCHAR2(200) 	:= NULL;
   x_str 	varchar2(4000) 	:= NULL;

  r_val1 varchar2(200) := NULL;
  r_val2 varchar2(200) := NULL;
  r_val3 varchar2(200) := NULL;
  r_val4 varchar2(200) := NULL;
  r_val5 varchar2(200) := NULL;
  r_val6 varchar2(200) := NULL;
  r_val7 varchar2(200) := NULL;
  r_val8 varchar2(200) := NULL;
  r_val9 varchar2(200) := NULL;
  r_val10 varchar2(200) := NULL;
  r_val11 varchar2(200) := NULL;
  r_val12 varchar2(200) := NULL;
  r_val13 varchar2(200) := NULL;
  r_val14 varchar2(200) := NULL;
  r_val15 varchar2(200) := NULL;
  r_val16 varchar2(200) := NULL;
  r_val17 varchar2(200) := NULL;
  r_val18 varchar2(200) := NULL;
  r_val19 varchar2(200) := NULL;
  r_val20 varchar2(200) := NULL;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
         x_return_status     := fnd_api.g_ret_sts_success;

         /*
         dbms_output.put_line('rcv_mgr_rpc_call: group_id '
             || inv_RCV_COMMON_APIS.g_rcv_global_var.interface_group_id);
         */
	 --bug 5169107
	 l_timeout := fnd_profile.value('INV_RPC_TIMEOUT');
	 if l_timeout is null then
	   l_timeout := 300;
	 end if;
	 --bug 5169107

         rc := fnd_transaction.synchronous (
     		l_timeout, l_outcome, l_message, 'PO', 'RCVTPO',
     		'ONLINE',  inv_RCV_COMMON_APIS.g_rcv_global_var.interface_group_id,
     		NULL, NULL, NULL, NULL, NULL, NULL,
     		NULL, NULL, NULL, NULL, NULL, NULL,
     		NULL, NULL, NULL, NULL, NULL, NULL);

         -- dbms_output.put_line('rc of RPC:' || rc);

	 x_return_code := rc;

         IF (rc = 0 and (l_outcome NOT IN ('WARNING', 'ERROR'))) THEN
            NULL;
         ELSIF (rc = 1) THEN
            x_return_status := fnd_api.g_ret_sts_error;
         ELSIF (rc = 2) THEN
            x_return_status := fnd_api.g_ret_sts_error;
         ELSIF (rc = 3 or (l_outcome IN ('WARNING', 'ERROR'))) THEN
            x_return_status := fnd_api.g_ret_sts_error;

	    rc := fnd_transaction.get_values (
           r_val1, r_val2, r_val3, r_val4, r_val5,
           r_val6, r_val7, r_val8, r_val9, r_val10,
           r_val11, r_val12, r_val13, r_val14, r_val15,
           r_val16, r_val17, r_val18, r_val19, r_val20);

           /*
           dbms_output.put_line('r_val1 :' || r_val1);
           dbms_output.put_line('r_val2 :' || r_val2);
           dbms_output.put_line('r_val3 :' || r_val3);
           dbms_output.put_line('r_val4 :' || r_val4);
           dbms_output.put_line('r_val5 :' || r_val5);
           dbms_output.put_line('r_val6 :' || r_val6);
           dbms_output.put_line('r_val7 :' || r_val7);
           dbms_output.put_line('r_val8 :' || r_val8);
           dbms_output.put_line('r_val9 :' || r_val9);
           dbms_output.put_line('r_val10:' || r_val10);
           dbms_output.put_line('r_val11:' || r_val11);
           dbms_output.put_line('r_val12:' || r_val12);
           dbms_output.put_line('r_val13:' || r_val13);
           dbms_output.put_line('r_val14:' || r_val14);
           dbms_output.put_line('r_val15:' || r_val15);
           dbms_output.put_line('r_val16:' || r_val16);
           dbms_output.put_line('r_val17:' || r_val17);
           dbms_output.put_line('r_val18:' || r_val18);
           dbms_output.put_line('r_val19:' || r_val19);
           dbms_output.put_line('r_val20:' || r_val20);
           */

         END IF;

         -- reset group id
         inv_RCV_COMMON_APIS.g_rcv_global_var.interface_group_id := '';
end rcv_manager_rpc_call;








  PROCEDURE launch_rcv_manager_rpc(
        x_return_status OUT NOCOPY VARCHAR2
      , x_return_code OUT NOCOPY NUMBER) IS
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(400);
    l_label_status  VARCHAR2(500);
    l_txn_id_tbl    inv_label.transaction_id_rec_type;
    l_counter       NUMBER      := 0;
    CURSOR c_rti_txn_id IS
    -- Bug 2377796
    -- LPN lables are not getting printed for rejected LPNS
    --SELECT MIN(rti.interface_transaction_id)
      SELECT rti.interface_transaction_id
      FROM   rcv_transactions_interface rti
      WHERE  rti.GROUP_ID = inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    -- GROUP BY rti.lpn_id;
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN

    --Commenting out the commit below since it would be done by the wrapper
    --to the receiving manager call (INV_RCV_MOBILE_PROCESS_TXN)
    --COMMIT;

    -- calling label printing API
    /* FP-J Lot/Serial Support Enhancement
     * If WMS and PO patch levels are J or higher then the label printing calls
     * would be done from the receiving TM and should NOT be done here.
     * If either of these are lower than J, then retain the original processing
     */
    IF ((inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j) OR
        (inv_rcv_common_apis.g_po_patch_level  < inv_rcv_common_apis.g_patchset_j_po)) THEN
      IF (l_debug = 1) THEN
        print_debug('create_std_rcpt_intf_rec: 8.1 before  inv_label.print_label ', 4);
      END IF;

      l_counter := 1;
      OPEN c_rti_txn_id;

      LOOP
        FETCH c_rti_txn_id INTO l_txn_id_tbl(l_counter);
        EXIT WHEN c_rti_txn_id%NOTFOUND;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcpt_intf_rec calling printing for:' || l_txn_id_tbl(l_counter), 4);
        END IF;

        l_counter := l_counter + 1;
      END LOOP;

      CLOSE c_rti_txn_id;
      inv_label.print_label(
        x_return_status          => l_return_status
      , x_msg_count              => l_msg_count
      , x_msg_data               => l_msg_data
      , x_label_status           => l_label_status
      , p_api_version            => 1.0
      , p_print_mode             => 1
      , p_business_flow_code     => 2
      , p_transaction_id         => l_txn_id_tbl
      );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;
        x_return_status := 'W';

        IF (l_debug = 1) THEN
          print_debug('create_std_rcpt_intf_rec 8.2: inv_label.print_label FAILED;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
      END IF;
    --If both WMS and PO are at Patchset J or higher
    ELSE
      IF (l_debug = 1) THEN
        print_debug('launch_rcv_manager_rpc 6.3: WMS and PO patch levels are J or higher. So NO label printing from UI', 4);
      END IF;
    END IF;   --END IF check WMS and PO patch levels

    --Calling the receiving manager using the wrapper to honor the processing mode profile
    --instead of the direct RPC call
    --rcv_manager_rpc_call(x_return_status, x_return_code);


    IF (l_debug =1 ) THEN
       print_debug('********* PROCESSING_MODE IS :' ||
		   INV_RCV_COMMON_APIS.g_po_startup_value.transaction_mode
		   || ' ************',4);
    END IF;

    INV_RCV_MOBILE_PROCESS_TXN.rcv_process_receive_txn(
        x_return_status =>  x_return_status
      , x_msg_data      =>  l_msg_data);

    IF (l_debug = 1) THEN
      print_debug('return status is launch procedure ' || x_return_status, 4);
      print_debug('return msg data l_msg_data: ' || l_msg_data, 4);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      IF (l_debug = 1) THEN
        print_debug('launch_rcv_manager_rpc 6.5: Encountered g_exc_error while calling receiving manager;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF (l_debug = 1) THEN
        print_debug('launch_rcv_manager_rpc 6.6: Encountered g_exc_unexp_error while calling receiving manager;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF (c_rti_txn_id%ISOPEN) THEN
        CLOSE c_rti_txn_id;
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (c_rti_txn_id%ISOPEN) THEN
        CLOSE c_rti_txn_id;
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (c_rti_txn_id%ISOPEN) THEN
        CLOSE c_rti_txn_id;
      END IF;
  END launch_rcv_manager_rpc;






procedure rcv_manager_conc_call
is
	v_req_id number;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
	v_req_id := fnd_request.submit_request('PO',
                'RVCTP',
                null,
                null,
                false,
                'IMMEDIATE',
                inv_RCV_COMMON_APIS.g_rcv_global_var.interface_group_id,
                '0', --fnd_char.local_chr(0), ?
                NULL,
                NULL,
                NULL,
                NULL,
                NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,

                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,

                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);

        /*
        dbms_output.put_line('request id:' || v_req_id);
        */

        if (v_req_id <= 0 or v_req_id is null) then
           -- concurrent manager error, Handle error and rollback
           -- need error message etc. here ?
           NULL;
        ELSE
	   NULL;
        end if;

        -- reset group id
        inv_RCV_COMMON_APIS.g_rcv_global_var.interface_group_id := '';

end rcv_manager_conc_call;

procedure launch_rcv_manager_conc
is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
	commit;
        rcv_manager_conc_call;
end launch_rcv_manager_conc;



--------------------------------------------------------
----------ADDED BY MANU GUPTA 10-18-2000 ---------------
-- returns S if ok, E if not
-- type=LPN,RMA,INTSHIP,PO,RECEIPT

FUNCTION get_inspection_qty(
  p_type 		IN VARCHAR2
, p_lpn_id 		IN NUMBER := NULL
, p_po_header_id 	IN NUMBER := NULL
, p_po_release_id 	IN NUMBER := NULL
, p_po_line_id 		IN NUMBER := NULL
, p_shipment_header_id 	IN NUMBER := NULL
, p_oe_order_header_id 	IN NUMBER := NULL
, p_organization_id 	IN NUMBER
, p_item_id 		IN NUMBER
, p_uom_code 		IN VARCHAR2
, x_inspection_qty     OUT NOCOPY NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_data           OUT NOCOPY VARCHAR2) RETURN NUMBER
IS
  l_total_qty 		NUMBER;
  l_cur_qty 		NUMBER;
  --The variable will hold the value of UOM
  l_cur_uom_code 	VARCHAR2(26); --Bug #3908752
  l_msg_count 		NUMBER;
  l_rcv_transaction_id 	NUMBER;
  l_tolerable_qty 	NUMBER;

  CURSOR c_txn_lines IS
    SELECT uom_code, quantity
    FROM mtl_txn_request_lines
    WHERE inspection_status is not null --8405606
      AND organization_id 	= p_organization_id
      AND inventory_item_id 	= p_item_id
      AND lpn_id 		= p_lpn_id;

 -- bug 8405606 removed the condition for rt.inspection_status_code = 'NOT INSPECTED'

  CURSOR c_po_source_lines IS
    SELECT rs.rcv_transaction_id
      FROM rcv_supply rs
         , rcv_transactions rt
     WHERE rs.item_id = p_item_id
       AND rs.po_header_id 	     = p_po_header_id
       AND nvl(rs.po_release_id,-1)  = nvl(p_po_release_id,nvl(rs.po_release_id,-1))
       AND nvl(rs.po_line_id,-1)     = nvl(p_po_line_id, nvl(rs.po_line_id,-1))
       AND rs.rcv_transaction_id     = rt.transaction_id
       AND rs.supply_type_code       = 'RECEIVING'
       AND rt.transaction_type      <> 'UNORDERED'
       AND rt.routing_header_id      = 2
       --BUG 4103743: Need to query on org id also
       AND rs.to_organization_id     = p_organization_id; /* Inspection routing */

  -- use this for receipts also --
  CURSOR c_intship_source_lines IS
    SELECT rs.rcv_transaction_id
      FROM rcv_supply rs
         , rcv_transactions rt
     WHERE rs.item_id = p_item_id
       AND rs.shipment_header_id     = p_shipment_header_id
       AND rs.rcv_transaction_id     = rt.transaction_id
       AND rs.supply_type_code       = 'RECEIVING'
       AND rt.transaction_type      <> 'UNORDERED'
       AND rt.routing_header_id      = 2; /* Inspection routing */

  CURSOR c_rma_source_lines IS
    SELECT rs.rcv_transaction_id
      FROM rcv_supply rs
         , rcv_transactions rt
     WHERE rs.item_id = p_item_id
       AND rs.oe_order_header_id     = p_oe_order_header_id
       AND rs.rcv_transaction_id     = rt.transaction_id
       AND rs.supply_type_code       = 'RECEIVING'
       AND rt.transaction_type      <> 'UNORDERED'
       AND rt.routing_header_id      = 2; /* Inspection routing */

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  l_total_qty := 0;

  -- lpn section --
  IF (p_type = 'LPN') THEN

    --print_debug('Inside get_inspection_qty LPN...', 4);

    OPEN c_txn_lines;
    LOOP
      FETCH c_txn_lines INTO l_cur_uom_code, l_cur_qty;
        EXIT WHEN c_txn_lines%NOTFOUND;

	--print_debug('LPN l_cur_qty is ' || to_char(l_cur_qty), 4);

        IF (l_cur_uom_code <> p_uom_code) THEN
           l_cur_qty := inv_convert.inv_um_convert(
		  p_item_id
		, null
		, l_cur_qty
		, l_cur_uom_code
		, p_uom_code
		, ''
		, '');
        END IF;

        l_total_qty := l_total_qty + l_cur_qty;
    END LOOP;
    CLOSE c_txn_lines;

  -- po section --
  ELSE IF (p_type = 'PO') THEN
    --print_debug('Inside get_inspection_qty PO...', 4);

    OPEN c_po_source_lines;
    LOOP
      FETCH c_po_source_lines INTO l_rcv_transaction_id;
      EXIT WHEN c_po_source_lines%NOTFOUND;
	--print_debug('PO l_supply_source_id is ' || to_char(l_rcv_transaction_id), 4);

      	rcv_quantities_s.get_available_quantity(
		 'INSPECT'
		,l_rcv_transaction_id
		,''
		,''
		,null
		,''
		,l_cur_qty
		,l_tolerable_qty
		,l_cur_uom_code);

      -- they pass me unit of measure, now i get uom code

      	select uom_code
	into l_cur_uom_code
	from mtl_units_of_measure
	where unit_of_measure = l_cur_uom_code;

      IF (l_cur_uom_code <> p_uom_code) THEN
         l_cur_qty := inv_convert.inv_um_convert(
	 	  p_item_id
		, null
		, l_cur_qty
		, l_cur_uom_code
		, p_uom_code
		, ''
		,'');
      END IF;
      l_total_qty := l_total_qty + l_cur_qty;
    END LOOP;
    CLOSE c_po_source_lines;

  -- intransit or receipt section --
  ELSE IF (p_type in ('INTSHIP','RECEIPT')) THEN
    --print_debug('Inside get_inspection_qty RECEIPT...', 4);

    OPEN c_intship_source_lines;
    LOOP
      FETCH c_intship_source_lines INTO l_rcv_transaction_id;

      --print_debug('before exit RECEIPT l_rcv_transaction_id is ' || l_rcv_transaction_id, 4);

      EXIT WHEN c_intship_source_lines%NOTFOUND;

      --print_debug('after exit RECEIPT l_rcv_transaction_id is ' || l_rcv_transaction_id, 4);

      rcv_quantities_s.get_available_quantity(
 	 'INSPECT'
      	,l_rcv_transaction_id
        ,''
	,''
	,null
        ,''
        ,l_cur_qty
        ,l_tolerable_qty
        ,l_cur_uom_code);

      -- they pass me unit of measure, now i get uom code
      select uom_code
      into l_cur_uom_code
      from mtl_units_of_measure
      where unit_of_measure = l_cur_uom_code;

      IF (l_cur_uom_code <> p_uom_code) THEN
         l_cur_qty := inv_convert.inv_um_convert(
           	  p_item_id
		, null
		, l_cur_qty
		, l_cur_uom_code
		, p_uom_code
		, ''
		, '');
      END IF;
      l_total_qty := l_total_qty + l_cur_qty;
    END LOOP;
    CLOSE c_intship_source_lines;

  -- rma section --
  ELSE IF (p_type = 'RMA') THEN
    OPEN c_rma_source_lines;
    LOOP
      FETCH c_rma_source_lines INTO l_rcv_transaction_id;
      EXIT WHEN c_rma_source_lines%NOTFOUND;

      rcv_quantities_s.get_available_quantity(
		 'INSPECT'
		,l_rcv_transaction_id
		,''
		,''
		,null
		,''
		,l_cur_qty
		,l_tolerable_qty
		,l_cur_uom_code);

      -- they pass me unit of measure, now i get uom code
      select uom_code
      into l_cur_uom_code
      from mtl_units_of_measure
      where unit_of_measure = l_cur_uom_code;

      IF (l_cur_uom_code <> p_uom_code) THEN
         l_cur_qty := inv_convert.inv_um_convert(
             p_item_id
           , null
           , l_cur_qty
	   , l_cur_uom_code
	   , p_uom_code
           , ''
           , '');
      END IF;
      l_total_qty := l_total_qty + l_cur_qty;
    END LOOP;
    CLOSE c_rma_source_lines;

  END IF;
  END IF;
  END IF;
  END IF;

  x_inspection_qty := l_total_qty;
  x_return_status  := fnd_api.g_ret_sts_success;

  return x_inspection_qty;

EXCEPTION
   when fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
       --  Get message count and data
      fnd_msg_pub.count_and_get (  p_count  => l_msg_count , p_data   => x_msg_data);
      print_debug('***Execution error occured***', 4);
      return 0; --Bug #3908752
   when fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get (  p_count  => l_msg_count , p_data   => x_msg_data);
      print_debug('***Unexpected error occured***', 4);
      return 0;
   when others THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg ( g_pkg_name, 'get_inspection_qty');
      END IF;
      --  Get message count and data
      fnd_msg_pub.count_and_get ( p_count => l_msg_count, p_data  => x_msg_data);
      IF (c_txn_lines%isopen) THEN
        CLOSE c_txn_lines;
      END IF;
      print_debug('***Error occured while getting Inspection Qty : ' || sqlerrm || ' ***' , 4);
      return 0;
END get_inspection_qty;

-------------------------------------------------------------
--------- wrapper function
-------------------------------------------------------------
FUNCTION get_inspection_qty_wrapper(
  p_type 		IN VARCHAR2
, p_id1 		IN NUMBER 	:= NULL
, p_id2 		IN NUMBER 	:= NULL
, p_id3 		IN NUMBER 	:= NULL
, p_organization_id 	IN NUMBER
, p_item_id 		IN NUMBER
, p_uom_code 		IN VARCHAR2) RETURN NUMBER
IS
   l_inspection_qty NUMBER;
   l_return_status VARCHAR2(10);
   l_msg_data VARCHAR2(5000);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   --print_debug('Inside wrapper, p_type is ' || p_type, 4);
   --print_debug('Inside wrapper, p_id1 is '  || p_id1, 4);
   --print_debug('Inside wrapper, p_org is '  || to_char(p_organization_id), 4);
   --print_debug('Inside wrapper, p_item is ' || to_char(p_item_id), 4);
   --print_debug('Inside wrapper,p_uom is '   || p_uom_code, 4);

   IF (p_type = 'LPN') THEN
     --print_debug('Inside LPN...', 4);

     return inv_rcv_std_inspect_apis.get_inspection_qty(
                  p_type 		=> p_type
 		, p_lpn_id 		=> p_id1
		, p_po_header_id 	=> NULL
		, p_po_release_id 	=> NULL
		, p_po_line_id 		=> NULL
		, p_shipment_header_id  => NULL
		, p_oe_order_header_id  => NULL
		, p_organization_id 	=> p_organization_id
		, p_item_id 		=> p_item_id
		, p_uom_code 		=> p_uom_code
		, x_inspection_qty 	=> l_inspection_qty
		, x_return_status 	=> l_return_status
		, x_msg_data 		=> l_msg_data);

   ELSE IF (p_type = 'RMA') THEN
	--print_debug('Inside RMA...', 4);

     	return inv_rcv_std_inspect_apis.get_inspection_qty(
		  p_type 		=> p_type
		, p_lpn_id 		=> NULL
		, p_po_header_id 	=> NULL
		, p_po_release_id 	=> NULL
		, p_po_line_id 		=> NULL
		, p_shipment_header_id 	=> NULL
		, p_oe_order_header_id 	=> p_id1
		, p_organization_id 	=> p_organization_id
		, p_item_id 		=> p_item_id
		, p_uom_code 		=> p_uom_code
		, x_inspection_qty 	=> l_inspection_qty
		, x_return_status 	=> l_return_status
		, x_msg_data => l_msg_data);

   ELSE IF (p_type in ('INTSHIP', 'RECEIPT')) THEN
	--print_debug('Inside Intship/Receipt...', 4);

        --print_debug('p_shipment_header_id=p_id1 is ' || to_char(p_id1), 4);

     	return inv_rcv_std_inspect_apis.get_inspection_qty(
		  p_type 		=> p_type
		, p_lpn_id 		=> NULL
		, p_po_header_id 	=> NULL
		, p_po_release_id 	=> NULL
		, p_po_line_id 		=> NULL
		, p_shipment_header_id 	=> p_id1
		, p_oe_order_header_id 	=> NULL
		, p_organization_id 	=> p_organization_id
		, p_item_id 		=> p_item_id
		, p_uom_code 		=> p_uom_code
		, x_inspection_qty 	=> l_inspection_qty
		, x_return_status 	=> l_return_status
		, x_msg_data 		=> l_msg_data);

   ELSE IF (p_type = 'PO') THEN
	--print_debug('Inside PO...', 4);

     	return inv_rcv_std_inspect_apis.get_inspection_qty(
		  p_type 		=> p_type
		, p_lpn_id 		=> NULL
		, p_po_header_id 	=> p_id1
		, p_po_release_id 	=> p_id2
		, p_po_line_id 		=> p_id3
		, p_shipment_header_id 	=> NULL
		, p_oe_order_header_id 	=> NULL
		, p_organization_id 	=> p_organization_id
		, p_item_id 		=> p_item_id
		, p_uom_code 		=> p_uom_code
		, x_inspection_qty 	=> l_inspection_qty
		, x_return_status 	=> l_return_status
		, x_msg_data 		=> l_msg_data);
  END IF;
  END IF;
  END IF;
  END IF;

END get_inspection_qty_wrapper;








-- given a particular lpn id, organization, and item, this method will return
-- the po associated with that item.  if there are multiple po's associated with
-- that restriction criteria, then it will return a status of 1.
-- if successful, then a status of 0.
PROCEDURE obtain_receiving_information(
          p_lpn_id IN NUMBER
        , p_organization_id IN NUMBER
        , p_inventory_item_id IN NUMBER
        , x_po_id OUT NOCOPY VARCHAR2
        , x_po_number OUT NOCOPY VARCHAR2
        , x_po_return_status OUT NOCOPY VARCHAR2
        , x_vendor_id OUT NOCOPY VARCHAR2
        , x_vendor_name OUT NOCOPY VARCHAR2
        , x_asl_status_id OUT NOCOPY VARCHAR2
        , x_asl_status_dsp OUT NOCOPY VARCHAR2
        , x_rma_id OUT NOCOPY VARCHAR2
        , x_rma_number OUT NOCOPY VARCHAR2
        , x_rma_return_status OUT NOCOPY VARCHAR2
        , x_customer_id OUT NOCOPY VARCHAR2
        , x_customer_number OUT NOCOPY VARCHAR2
        , x_customer_name OUT NOCOPY VARCHAR2
        , x_intshp_id OUT NOCOPY VARCHAR2
        , x_intshp_number OUT NOCOPY VARCHAR2
        , x_intshp_return_status OUT NOCOPY VARCHAR2
        , x_receipt_number OUT NOCOPY VARCHAR2
        , x_receipt_return_status OUT NOCOPY VARCHAR2
        , x_msg_count OUT NOCOPY VARCHAR2
        , x_msg_data OUT NOCOPY VARCHAR2)
IS
 v_count_po NUMBER;
 v_count_rma NUMBER;
 v_count_intshp NUMBER;
 v_po_line_id NUMBER;

 l_progress VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1) THEN
     print_debug('begin obtain_receiving_info in db', 4);
     print_debug('passed in lpn, org, item' || p_lpn_id || ':' || p_organization_id || ':' || p_inventory_item_id, 4);
  END IF;
  l_progress := '0';

  --BUG 3444196: Modify the following query to avoid the
  --'Non-mergable view exists for the following SQL' complaints
  SELECT COUNT(DISTINCT pha.po_header_id)
    INTO v_count_po
    FROM mtl_txn_request_lines mtrl, po_line_locations_all plla, po_headers_all pha
    WHERE reference = 'PO_LINE_LOCATION_ID'
    AND mtrl.reference_id = plla.line_location_id
    AND plla.po_header_id = pha.po_header_id
    AND mtrl.quantity > nvl(mtrl.quantity_delivered, 0)
    AND mtrl.lpn_id = p_lpn_id
    AND mtrl.organization_id = p_organization_id
    AND mtrl.inventory_item_id = p_inventory_item_id ;

  --dbms_output.put_line('vcountpo=' || v_count_po);
  l_progress := '10';
  IF (l_debug = 1) THEN
     print_debug('obtain_receiving_info:progress=' || l_progress, 4);
  END IF;

  --if only 1 line is returned by the above query, then we need to retrieve multiple values
  -- for that line and set the status to 0, representing success
  if (v_count_po = 1) then
    x_po_return_status := 0;
    x_msg_count := ' ';
    x_msg_data := ' ';

    select distinct pha.po_header_id, pha.segment1, pv.vendor_id, pv.vendor_name,  plla.po_line_id
    into x_po_id, x_po_number, x_vendor_id, x_vendor_name, v_po_line_id
    from mtl_txn_request_lines mtrl, po_line_locations_all plla, po_headers_all pha, po_vendors pv
    where reference = 'PO_LINE_LOCATION_ID'
    and mtrl.reference_id = plla.line_location_id
    and plla.po_header_id = pha.po_header_id
    and mtrl.quantity > nvl(mtrl.quantity_delivered, 0)
    and pha.vendor_id = pv.vendor_id
    and mtrl.lpn_id = p_lpn_id
    and mtrl.organization_id = p_organization_id
    and mtrl.inventory_item_id = p_inventory_item_id;
    l_progress := '20';
  IF (l_debug = 1) THEN
     print_debug('obtain_receiving_info:progress=' || l_progress, 4);
  END IF;


    ----dbms_output.put_line('x_po_id=' || x_po_id);
    --dbms_output.put_line('x_po_number=' || x_po_number);
    --dbms_output.put_line('x_vendor_id=' || x_vendor_id);


begin
    -- get ASL -- query provided by jenny zheng from QA team
     SELECT pasv.asl_status_id, pasv.asl_status_dsp
     into x_asl_status_id, x_asl_status_dsp
     FROM   po_asl_suppliers_v pasv, po_lines pl, po_headers ph
     WHERE  pl.item_id = pasv.item_id
     AND    pl.po_line_id = v_po_line_id  -- here use the variable from above
     AND    pl.po_header_id = ph.po_header_id
     AND    ph.vendor_id(+) = pasv.vendor_id
     AND    ph.vendor_site_id(+) = pasv.vendor_site_id
     AND    (p_organization_id = pasv.using_organization_id
      OR    pasv.using_organization_id = -1);
    l_progress := '30';
  IF (l_debug = 1) THEN
     print_debug('obtain_receiving_info:progress=' || l_progress, 4);
  END IF;
exception
   when others then
     x_asl_status_id := ' ';
     x_asl_status_dsp := ' ';
end;


begin
   -- obtain receipt number
    select distinct rsh.receipt_num, '0'
    into x_receipt_number, x_receipt_return_status
    from mtl_txn_request_lines mtrl, rcv_transactions rt, rcv_shipment_headers rsh
    where reference = 'PO_LINE_LOCATION_ID'
    and mtrl.reference_id = rt.po_line_location_id
    and mtrl.quantity > nvl(mtrl.quantity_delivered, 0)
    and rt.shipment_header_id = rsh.shipment_header_id
    and mtrl.lpn_id = p_lpn_id
    and mtrl.lpn_id = rt.transfer_lpn_id --Bug#7390895
    and mtrl.organization_id = p_organization_id
    and mtrl.inventory_item_id = p_inventory_item_id;
    l_progress := '40';
  IF (l_debug = 1) THEN
     print_debug('obtain_receiving_info:progress=' || l_progress, 4);
  END IF;
exception
   when others then
     x_receipt_number := ' ';
     x_receipt_return_status := ' ';
end;


  else if (v_count_po = 0) then
    x_po_return_status := -1;
    x_msg_count := ' ';
    x_msg_data := 'NO PO LINES FOUND';
    --dbms_output.put_line('no po lines found');

  else if (v_count_po > 1) then
    x_po_return_status := 1;
    x_msg_count := ' ';
    x_msg_data := 'MULTIPLE PO LINES FOUND';
    --dbms_output.put_line('many po lines found');

  end if;
  end if;
  end if;




  --obtain RMA, CUSTOMER INFO
  --BUG 3444196: Modify the following query to avoid the
  --'Non-mergable view exists for the following SQL' complaints
  SELECT COUNT(DISTINCT oeh.header_id)
    INTO v_count_rma
    FROM mtl_txn_request_lines mtrl, oe_order_lines_all oel, oe_order_headers_all oeh
    WHERE reference = 'ORDER_LINE_ID'
    AND   mtrl.reference_id = oel.line_id
    AND   mtrl.quantity > nvl(mtrl.quantity_delivered, 0)
    AND   oel.header_id = oeh.header_id
    AND   mtrl.lpn_id = p_lpn_id
    AND   mtrl.organization_id = p_organization_id
    AND   mtrl.inventory_item_id = p_inventory_item_id;

    l_progress := '50';
  IF (l_debug = 1) THEN
     print_debug('obtain_receiving_info:progress=' || l_progress, 4);
  END IF;
  if (v_count_rma = 1) then
    x_rma_return_status := 0;
    x_msg_count := ' ';
    x_msg_data := ' ';

    select distinct oeh.header_id, oeh.order_number, oest.customer_id, oest.customer_number, oest.name
    into x_rma_id, x_rma_number, x_customer_id, x_customer_number, x_customer_name
    from mtl_txn_request_lines mtrl, oe_order_lines_all oel, oe_order_headers_all oeh, oe_sold_to_orgs_v oest
    where reference = 'ORDER_LINE_ID'
    and mtrl.reference_id = oel.line_id
    and mtrl.quantity > nvl(mtrl.quantity_delivered, 0)
    and oel.header_id = oeh.header_id
    and oeh.sold_to_org_id = oest.customer_id
    and mtrl.lpn_id = p_lpn_id
    and mtrl.organization_id = p_organization_id
    and mtrl.inventory_item_id = p_inventory_item_id;
    l_progress := '60';
  IF (l_debug = 1) THEN
     print_debug('obtain_receiving_info:progress=' || l_progress, 4);
  END IF;

begin
    --obtain the receipt number
    select distinct rsh.receipt_num, '0'
    into x_receipt_number, x_receipt_return_status
    from mtl_txn_request_lines mtrl, rcv_transactions rt, rcv_shipment_headers rsh
    where reference = 'ORDER_LINE_ID'
    and mtrl.reference_id = rt.oe_order_line_id
    and mtrl.quantity > nvl(mtrl.quantity_delivered, 0)
    and rt.shipment_header_id = rsh.shipment_header_id
    and mtrl.lpn_id = p_lpn_id
    and mtrl.organization_id = p_organization_id
    and mtrl.inventory_item_id = p_inventory_item_id;
    l_progress := '70';
  IF (l_debug = 1) THEN
     print_debug('obtain_receiving_info:progress=' || l_progress, 4);
  END IF;
exception
   when others then
     x_receipt_number := ' ';
     x_receipt_return_status := ' ';
end;


  else if (v_count_rma = 0) then
    x_rma_return_status := -1;
    x_msg_count := ' ';
    x_msg_data := x_msg_data ||  'NO RMA LINES FOUND';

  else if (v_count_rma > 1) then
    x_rma_return_status := 1;
    x_msg_count := ' ';
    x_msg_data := x_msg_data || 'MULTIPLE RMA LINES FOUND';

  end if;
  end if;
  end if;



  -- obtain SHIPMENT RECEIPT INFORMATION
  SELECT COUNT(DISTINCT rsl.shipment_header_id)
    INTO v_count_intshp
    FROM mtl_txn_request_lines mtrl, rcv_shipment_lines rsl
    WHERE reference = 'SHIPMENT_LINE_ID'
    AND   mtrl.reference_id = rsl.shipment_line_id
    AND   mtrl.quantity > nvl(mtrl.quantity_delivered, 0)
    AND   mtrl.lpn_id = p_lpn_id
    AND   mtrl.organization_id = p_organization_id
    AND   mtrl.inventory_item_id = p_inventory_item_id;

  l_progress := '80';
  IF (l_debug = 1) THEN
     print_debug('obtain_receiving_info:progress=' || l_progress, 4);
  END IF;

  if (v_count_intshp = 1) then
    x_intshp_return_status := 0;
    x_msg_count := ' ';
    x_msg_data := ' ';

    select distinct rsl.shipment_header_id, rsh.shipment_num, rsh.receipt_num
    into x_intshp_id, x_intshp_number, x_receipt_number
    from mtl_txn_request_lines mtrl, rcv_shipment_lines rsl, rcv_shipment_headers rsh
    where reference = 'SHIPMENT_LINE_ID'
    and mtrl.quantity > nvl(mtrl.quantity_delivered, 0)
    and mtrl.reference_id = rsl.shipment_line_id
    and rsl.shipment_header_id = rsh.shipment_header_id
    and mtrl.lpn_id = p_lpn_id
    and mtrl.organization_id = p_organization_id
    and mtrl.inventory_item_id = p_inventory_item_id;
    l_progress := '90';
  IF (l_debug = 1) THEN
     print_debug('obtain_receiving_info:progress=' || l_progress, 4);
  END IF;

  else if (v_count_intshp = 0) then
    x_intshp_return_status := -1;
    x_msg_count := ' ';
    x_msg_data := x_msg_data ||  'NO SHIPMENT RECEIPT LINES FOUND';

  else if (v_count_intshp > 1) then
    x_intshp_return_status := 1;
    x_msg_count := ' ';
    x_msg_data := x_msg_data || 'MULTIPLE SHIPMENT RECEIPT LINES FOUND';

  end if;
  end if;
  end if;

exception
  when others then
      IF SQLCODE IS NOT NULL THEN
         inv_mobile_helper_functions.sql_error('inv_rcv_std_inspect_apis.obtain_receiving_information', l_progress, SQLCODE);
      END IF;




end obtain_receiving_information;


---------------- END OF SECTION ADDED BY MANU GUPTA --------------------
------------------------------------------------------------------------


FUNCTION is_revision_required (
			       p_source_type        IN VARCHAR2
			       , p_source_id        IN NUMBER
			       , p_item_id 	    IN NUMBER
			       ) RETURN NUMBER
  IS
l_count NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   l_count := 1;

   IF (p_source_type = 'PO') THEN
      BEGIN
	 SELECT 1
	   INTO l_count
	   FROM rcv_supply rs
	   , rcv_transactions rt
	   WHERE rs.item_id = p_item_id
	   AND rs.item_revision IS NULL
	   AND rs.po_header_id 	     = p_source_id
	   AND rs.rcv_transaction_id     = rt.transaction_id
	   AND rt.inspection_status_code = 'NOT INSPECTED'
	   AND rs.supply_type_code       = 'RECEIVING'
	   AND rt.transaction_type      <> 'UNORDERED'
	   AND ROWNUM < 2;
      EXCEPTION
	 WHEN no_data_found THEN
	   l_count := 0;
      END;
    ELSE IF (p_source_type IN ('INTSHIP', 'RECEIPT')) THEN
       BEGIN
	  SELECT 1
	    INTO l_count
	    FROM rcv_supply rs
	    , rcv_transactions rt
	    WHERE rs.item_id = p_item_id
	    AND rs.item_revision IS NULL
	    AND rs.shipment_header_id     = p_source_id
	    AND rs.rcv_transaction_id     = rt.transaction_id
	    AND rt.inspection_status_code = 'NOT INSPECTED'
	    AND rs.supply_type_code       = 'RECEIVING'
	    AND rt.transaction_type      <> 'UNORDERED'
	    AND ROWNUM < 2;
       EXCEPTION
	  WHEN no_data_found THEN
	     l_count := 0;
       END;
     ELSE IF (p_source_type = 'RMA') THEN
        BEGIN
	   SELECT 1
	     INTO l_count
	     FROM rcv_supply rs
	     , rcv_transactions rt
	     WHERE rs.item_id = p_item_id
	     AND rs.item_revision IS NULL
	     AND rs.oe_order_header_id     = p_source_id
	     AND rs.rcv_transaction_id     = rt.transaction_id
	     AND rt.inspection_status_code = 'NOT INSPECTED'
	     AND rs.supply_type_code       = 'RECEIVING'
	     AND rt.transaction_type      <> 'UNORDERED'
	     AND ROWNUM < 2;
	EXCEPTION
	   WHEN no_data_found THEN
	      l_count := 0;
	END;
     END IF;
     END IF;
     END IF;

     RETURN l_count;
END is_revision_required;


end inv_rcv_std_inspect_apis;

/
