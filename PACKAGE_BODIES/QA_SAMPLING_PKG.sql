--------------------------------------------------------
--  DDL for Package Body QA_SAMPLING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SAMPLING_PKG" AS
/* $Header: qasamplb.pls 120.4.12010000.4 2010/02/11 08:46:02 pdube ship $ */


-- This procedure inserts the Details for the quantity left in the
-- lot, not inspected, onto the temp table - qa_insp_collections_dtl_temp.
-- Called from launch_shipment_action_int().
-- Bug 3096256. For RCV/WMS Merge. kabalakr Thu Aug 28 08:34:59 PDT 2003.

PROCEDURE post_lot_qty_not_insp(p_collection_id IN NUMBER,
                                p_quantity      IN NUMBER,
                                p_result        IN VARCHAR2) IS

  CURSOR dtl_info IS
    select organization_id, item_id, lpn_id
    from   qa_insp_collections_dtl_temp
    where  collection_id = p_collection_id
    and    rownum = 1;

  l_lpn_id   NUMBER;
  l_org_id   NUMBER;
  l_item_id  NUMBER;

BEGIN

    -- We assume that these information are common for all inspection
    -- records entered in qa_results.

    OPEN  dtl_info;
    FETCH dtl_info INTO l_org_id, l_item_id, l_lpn_id;
    CLOSE dtl_info;

    -- Insert a record onto qa_insp_collections_dtl_temp for the Quantity
    -- not inspected in the Lot.

    -- Bug 3229571. Passing Lot_number and serial_number as 'DEFERRED'. The Lot
    -- and serial numbers associated with the lot qty not inspected, will be derived
    -- and attached to the inspection txn later. kabalakr.

    insert into qa_insp_collections_dtl_temp
     (collection_id,
      occurrence,
      organization_id,
      item_id,
      lpn_id,
      xfr_lpn_id,
      lot_number,
      serial_number,
      insp_result,
      insp_qty
     )
     values
       (p_collection_id,
        NULL,
        l_org_id,
        l_item_id,
        l_lpn_id,
        l_lpn_id,
        'DEFERRED',
        'DEFERRED',
        p_result,
        p_quantity
       );

END post_lot_qty_not_insp;



-- This procedure updates the records in qa_insp_collections_dtl_temp
-- with insp_result = 'REJECT', when the lot_result is 'REJECT'.
-- Called from launch_shipment_action_int().
-- Bug 3096256. For RCV/WMS Merge. kabalakr Thu Aug 28 08:34:59 PDT 2003.

PROCEDURE upd_insp_coll_dtl_result(p_collection_id IN NUMBER) IS

  l_sql_string VARCHAR2(200);

BEGIN

    l_sql_string := 'UPDATE qa_insp_collections_dtl_temp '||
                    ' SET insp_result = ''REJECT'''||
                    ' WHERE collection_id = :1';

    EXECUTE IMMEDIATE l_sql_string USING p_collection_id;

END upd_insp_coll_dtl_result;


-- Bug 3229571. This procedure populates the qa_rcv_lot_ser_temp temp
-- table with the lot and serial info from supply tables.
-- Called from launch_shipment_action_int ().

PROCEDURE populate_lot_serial_temp(p_transaction_id IN NUMBER) IS

-- OPM Conv R12 Tracking Bug 4345760
-- change variable size for lot num

  l_lot_num    qa_results.lot_number%TYPE;


  l_serial_num VARCHAR2(30);
  l_quantity   NUMBER;

  CURSOR lot_ser_supply IS
     select rls.lot_num, rss.serial_num, decode(rss.serial_num, NULL, rls.quantity, 1)
     from rcv_lots_supply rls, rcv_serials_supply rss
     where rls.transaction_id = rss.transaction_id (+)
     and rls.transaction_id = p_transaction_id
     and rls.lot_num = rss.lot_num (+)
     UNION
     select rls.lot_num, rss.serial_num, decode(rss.serial_num, NULL, rls.quantity, 1)
     from rcv_lots_supply rls, rcv_serials_supply rss
     where rls.transaction_id (+) = rss.transaction_id
     and rss.transaction_id = p_transaction_id
     and rls.lot_num (+) = rss.lot_num;


BEGIN

  OPEN lot_ser_supply;
  LOOP

    FETCH lot_ser_supply INTO l_lot_num,
                              l_serial_num,
                              l_quantity;

    EXIT WHEN lot_ser_supply%NOTFOUND;

    -- The value for valid_flag is passes as 1 initally to indicate that the
    -- record is valid.

    insert into qa_rcv_lot_ser_temp
    (rcv_txn_id,
     lot_num,
     serial_num,
     quantity,
     valid_flag
    )
    values
       (p_transaction_id,
        l_lot_num,
        l_serial_num,
        l_quantity,
        1
       );

  END LOOP;

  CLOSE lot_ser_supply;

END populate_lot_serial_temp;


-- Bug 3229571. This procedure updates the lot serial qty in the temp
-- table to reflect the inspected quantity.
-- Called from launch_shipment_action_int ().

PROCEDURE modify_lot_serial_temp(p_transaction_id IN NUMBER,
                                 p_collection_id  IN NUMBER) IS


-- OPM Conv R12 Tracking Bug 4345760
-- change variable size for lot num

  l_lot_number    qa_results.lot_number%TYPE;


  l_serial_number VARCHAR2(30);
  l_insp_qty      NUMBER;
  l_temp_qty      NUMBER;
  l_qty_rem       NUMBER;

  CURSOR lot_ser_dtl IS
    select quantity
    from   qa_rcv_lot_ser_temp
    where  rcv_txn_id = p_transaction_id
    and    nvl(lot_num, '@@') = nvl(l_lot_number, '@@')
    and    nvl(serial_num, '@@') = nvl(l_serial_number, '@@');

  CURSOR insp_dtl IS
    select lot_number, serial_number, insp_qty
    from   qa_insp_collections_dtl_temp
    where  collection_id = p_collection_id;


BEGIN

  OPEN insp_dtl;
  LOOP

    -- Fetch the inspected lt and serial info.

    FETCH insp_dtl INTO l_lot_number,
                        l_serial_number,
                        l_insp_qty;

    EXIT WHEN insp_dtl%NOTFOUND;

    -- Exit if the lot and serial are having NULL values.

    IF (l_lot_number IS NULL) AND (l_serial_number IS NULL) THEN

      EXIT;
    END IF;

    -- Fetch the qty toatal qty for the line in the temp table.
    OPEN  lot_ser_dtl;
    FETCH lot_ser_dtl INTO l_temp_qty;

    IF (lot_ser_dtl%NOTFOUND) THEN
      CLOSE lot_ser_dtl;
      EXIT;
    END IF;

    CLOSE lot_ser_dtl;

    -- calculate the qty remaining to be inspected. This basically is the
    -- lot qty left.

    l_qty_rem := l_temp_qty - l_insp_qty;


    -- If the qty remaining is zero, update the valid_flag to 2. This indicates
    -- that the record is not to be used for further inspections.
    -- If the qty is not zero, update, the remaining qty onto the temp table.

    IF (l_qty_rem = 0) THEN

      update qa_rcv_lot_ser_temp
      set    valid_flag = 2
      where  rcv_txn_id = p_transaction_id
      and    nvl(lot_num, '@@') = nvl(l_lot_number, '@@')
      and    nvl(serial_num, '@@') = nvl(l_serial_number, '@@');

    ELSE

      update qa_rcv_lot_ser_temp
      set    quantity = l_qty_rem
      where  rcv_txn_id = p_transaction_id
      and    nvl(lot_num, '@@') = nvl(l_lot_number, '@@')
      and    nvl(serial_num, '@@') = nvl(l_serial_number, '@@');

    END IF;

  END LOOP;

END modify_lot_serial_temp;




-- Bug 3229571. This procedure takes care of inserting the lot and serial
-- info onto the corresponding interface tables for the qty left in the lot
-- after sampling inspection.
-- Called from launch_shipment_action_int (). kabalakr.

PROCEDURE insert_lot_serial_txn(p_parent_txn_id  NUMBER,
                                p_transaction_id NUMBER,
                                p_item_id        NUMBER,
                                p_org_id         NUMBER,
                                p_uom            VARCHAR2) IS


  x_return_status    VARCHAR2(5);
  x_msg_count        NUMBER;
  x_msg_data         VARCHAR2(240);

-- OPM Conv R12 Tracking Bug 4345760
-- change variable size for lot num

  l_lot_number       qa_results.lot_number%TYPE;


  l_serial_number    VARCHAR2(30);
  l_qty_rem          NUMBER;

  l_primary_uom      VARCHAR2(25);
  l_primary_qty      NUMBER;
  l_int_txn_id       NUMBER;
  l_ser_txn_id       NUMBER;
  l_rti_txn_id       NUMBER;


  CURSOR item_uom_cur IS
    select primary_unit_of_measure
    from   mtl_system_items_b
    where  inventory_item_id = p_item_id
    and    organization_id = p_org_id;


  CURSOR lot_ser_cur IS
    select lot_num, serial_num, quantity
    from   qa_rcv_lot_ser_temp
    where  rcv_txn_id = p_parent_txn_id
    and    valid_flag = 1;


BEGIN

  -- Assigning rcv_transaction_id of the inspection record to a local variable.
  -- The parent transaction id value is stored in p_parent_txn_id to retrieve
  -- the lot and serial info from the qa_rcv_lot_ser_temp temp table.

  l_rti_txn_id := p_transaction_id;


  OPEN lot_ser_cur;
  LOOP

    FETCH lot_ser_cur INTO l_lot_number,
                           l_serial_number,
                           l_qty_rem;

    EXIT WHEN lot_ser_cur%NOTFOUND;


    IF l_lot_number IS NOT NULL THEN

       -- First, fetch the primary quantity.

       OPEN  item_uom_cur;
       FETCH item_uom_cur INTO l_primary_uom;
       CLOSE item_uom_cur;

       IF (l_primary_uom = p_uom) THEN
          l_primary_qty := l_qty_rem;

       ELSE
          l_primary_qty := inv_convert.inv_um_convert
                             (p_item_id,
                              NULL,
                              l_qty_rem,
                              p_uom,
                              l_primary_uom,
                              NULL,
                              NULL);

       END IF;

       l_int_txn_id := NULL;
       l_ser_txn_id := NULL;

       -- Now, call the Inventory/WMS API for Lot Insertion.
       -- Passing NULL value to p_transaction_interface_id to allow the
       -- API to generate one.

       INV_RCV_INTEGRATION_APIS.INSERT_MTLI
               (p_api_version                => 1.0,
                p_init_msg_lst               => NULL,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data,
                p_transaction_interface_id   => l_int_txn_id,
                p_transaction_quantity       => l_qty_rem,
                p_primary_quantity           => l_primary_qty,
                p_organization_id            => p_org_id,
                p_inventory_item_id          => p_item_id,
                p_lot_number                 => l_lot_number,
                p_expiration_date            => NULL,
                p_status_id                  => NULL,
                x_serial_transaction_temp_id => l_ser_txn_id,
                p_product_code               => 'RCV',
                p_product_transaction_id     => l_rti_txn_id);

        if x_return_status <> 'S' then
                qa_skiplot_utility.insert_error_log (
                p_module_name => 'QA_SAMPLING_PKG.LAUNCH_SHIPMENT_ACTION_INT',
                p_error_message => 'QA_WMS_LOT_INSERT_FAIL',
                p_comments => x_msg_data);
                fnd_message.clear;
                fnd_message.set_name ('QA', 'QA_WMS_LOT_INSERT_FAIL');
                APP_EXCEPTION.RAISE_EXCEPTION;
        end if;


    END IF;


    IF (l_serial_number IS NOT NULL) THEN

       IF (l_lot_number IS NOT NULL) THEN
         l_int_txn_id := l_ser_txn_id;

       ELSE
         l_int_txn_id := NULL;

       END IF;

       -- Now, call the Inventory/WMS API for Serial Insertion.
       -- Passing NULL value to p_transaction_interface_id to allow the
       -- API to generate one.

       INV_RCV_INTEGRATION_APIS.INSERT_MSNI
              (p_api_version              => 1.0,
               p_init_msg_lst             => NULL,
               x_return_status            => x_return_status,
               x_msg_count                => x_msg_count,
               x_msg_data                 => x_msg_data,
               p_transaction_interface_id => l_int_txn_id,
               p_fm_serial_number         => l_serial_number,
               p_to_serial_number         => l_serial_number,
               p_organization_id          => p_org_id,
               p_inventory_item_id        => p_item_id,
               p_status_id                => NULL,
               p_product_code             => 'RCV',
               p_product_transaction_id   => l_rti_txn_id);

       if x_return_status <> 'S' then
                qa_skiplot_utility.insert_error_log (
                p_module_name => 'QA_SAMPLING_PKG.LAUNCH_SHIPMENT_ACTION_INT',
                p_error_message => 'QA_WMS_SER_INSERT_FAIL',
                p_comments => x_msg_data);
                fnd_message.clear;
                fnd_message.set_name ('QA', 'QA_WMS_SER_INSERT_FAIL');
                APP_EXCEPTION.RAISE_EXCEPTION;
       end if;

    END IF;

  END LOOP;

END insert_lot_serial_txn;



-- This procedure is an alternate wrapper for launch_shipment_action() to
-- call the RCV API to perform accept or reject. This new procedure enables
-- unit wise inspections with LPN and Lot/Serial controls. This procedure
-- will be used only if one Inspection Plan is involved. Multiple Inspection
-- Plans Inspection will be executed through launch_shipment_action().
-- This procedure is called from launch_shipment_action().
-- Bug 3096256. For RCV/WMS Merge. kabalakr Thu Aug 28 08:34:59 PDT 2003.
--

PROCEDURE launch_shipment_action_int(
              p_po_txn_processor_mode IN VARCHAR2,
              p_po_group_id           IN NUMBER,
              p_collection_id         IN NUMBER,
              p_employee_id           IN NUMBER,
              p_transaction_id        IN NUMBER,
              p_uom                   IN VARCHAR2,
              p_transaction_date      IN DATE,
              p_created_by            IN NUMBER,
              p_last_updated_by       IN NUMBER,
              p_last_update_login     IN NUMBER,
              p_lot_size              IN NUMBER,
              p_lot_result            IN VARCHAR2) IS

  l_lot_qty_not_insp NUMBER;
  l_lot_qty_insp     NUMBER;

  x_return_status    VARCHAR2(5);
  x_msg_count        NUMBER;
  x_msg_data         VARCHAR2(240);

  CURSOR lot_info_cur IS
    select lot_size, lot_result, total_rejected_qty
    from   qa_insp_collections_temp
    where  collection_id = p_collection_id;

  CURSOR lot_insp_cur IS
    select sum(insp_qty) AS total_insp_qty
    from   qa_insp_collections_dtl_temp
    where  collection_id = p_collection_id;

  CURSOR insp_coll_dtl IS
    select organization_id, item_id, lpn_id, xfr_lpn_id,
           lot_number, serial_number, insp_result, sum(insp_qty)
    from   qa_insp_collections_dtl_temp
    where  collection_id = p_collection_id
    group by organization_id, item_id, lpn_id, xfr_lpn_id,
             lot_number, serial_number, insp_result;

  CURSOR item_uom_cur(l_item NUMBER, l_org NUMBER) IS
    select primary_unit_of_measure
    from   mtl_system_items_b
    where  inventory_item_id = l_item
    and    organization_id = l_org;


  l_lpn_id           NUMBER;
  l_xfr_lpn_id       NUMBER;

  -- OPM Conv R12 Tracking Bug 4345760
  -- change variable size for lot num

  l_lot_number       qa_results.lot_number%TYPE;


  l_serial_number    VARCHAR2(30);
  l_insp_result      VARCHAR2(80);
  l_insp_qty         NUMBER;
  l_org_id           NUMBER;
  l_item_id          NUMBER;

  l_primary_uom      VARCHAR2(25);
  l_primary_qty      NUMBER;
  l_int_txn_id       NUMBER;
  l_ser_txn_id       NUMBER;

  -- Added the below cursor and variables for Bug 3225280.
  -- kabalakr Wed Oct 29 23:19:22 PST 2003.

  CURSOR int_txn (grp_id NUMBER, txn_id NUMBER) IS
    SELECT max(interface_transaction_id)
    FROM   rcv_transactions_interface
    WHERE  group_id = grp_id
    AND    parent_transaction_id = txn_id;

  l_rti_int_txn_id  NUMBER;

  -- Bug 8806035.ntungare
  -- Added this cursor and variable for copying the supplier lot number information.
  CURSOR vend_lot_num (txn_id NUMBER) IS
    SELECT vendor_lot_num
    FROM rcv_transactions
    WHERE transaction_id = txn_id;
  l_vendor_lot_num VARCHAR2(30) := NULL;

-- Bug  6781108
-- Added the following two variables to get the value
-- and pass to the RCV API
l_rti_sub_code  mtl_secondary_inventories.secondary_inventory_name%TYPE :=NULL;
l_rti_loc_id    NUMBER := NULL;
BEGIN
    -- We dont need to check the sampling flag here because
    -- launch_shipment_action() calls this only for sampling scenario.

    -- First, post the Inspection details from qa_results onto
    -- the temp table qa_insp_collections_dtl_temp.
    -- Here we build the detail temp table for the plan.

    post_insp_coll_details(p_collection_id);

    -- Bug 3229571. Once the Inspection details are posted, post the lot
    -- and serial info for the receiving txn onto qa_rcv_lot_ser_temp.

    populate_lot_serial_temp(p_transaction_id);

    -- Bug 3229571. Synch the qa_rcv_lot_ser_temp with the lot and serial
    -- numbers already used in Inspection.

    modify_lot_serial_temp(p_transaction_id,
                           p_collection_id);

    -- Fetch the total quantity inspected, in the results record.
    OPEN  lot_insp_cur;
    FETCH lot_insp_cur INTO l_lot_qty_insp;
    CLOSE lot_insp_cur;

    -- Get the total lot quantity, not inspected. This needs to be inserted
    -- onto qa_insp_collections_dtl_temp. Call the post_lot_qty_not_insp()
    -- for this.

    l_lot_qty_not_insp := p_lot_size - l_lot_qty_insp;

    -- Bug 3258383. Post the lot quantity not inpsected, only if its
    -- greater than Zero. Added the IF condition below to attain the same.
    -- kabalakr Thu Mar 4 03:36:22 PST 2004.

    IF (l_lot_qty_not_insp > 0) THEN

      post_lot_qty_not_insp(p_collection_id,
                            l_lot_qty_not_insp,
                            p_lot_result);

    END IF;


    -- If the lot_result is 'REJECT, then update the insp_result of
    -- qa_insp_collections_dtl_temp with 'REJECT' for the collection_id.

    IF p_lot_result = 'REJECT' THEN
        upd_insp_coll_dtl_result(p_collection_id);

    END IF;

    -- Bug 8806035.ntungare
    -- Added this cursor to fetch the vendor_lot_number of the
    -- transaction from the rcv_transactions table.
    OPEN vend_lot_num(p_transaction_id);
    FETCH vend_lot_num INTO l_vendor_lot_num;
    CLOSE vend_lot_num;

    -- Now, fetch the records in qa_insp_collections_dtl_temp for calling the
    -- RCV API. We have grouped the records in cursor so that it gives the
    -- consolidated picture.

    OPEN insp_coll_dtl;
    LOOP

        FETCH insp_coll_dtl INTO l_org_id,
                                 l_item_id,
                                 l_lpn_id,
                                 l_xfr_lpn_id,
                                 l_lot_number,
                                 l_serial_number,
                                 l_insp_result,
                                 l_insp_qty;

        EXIT WHEN insp_coll_dtl%NOTFOUND;

        IF l_lpn_id IS NOT NULL THEN

            IF l_xfr_lpn_id IS NULL THEN
                l_xfr_lpn_id := l_lpn_id;
                -- Bug 6781108
                -- Calling this Procedure to get subinv_code and loc_id
                -- in order to insert into RTI table
                -- pdube Wed Feb  6 04:53:32 PST 2008
                QLTDACTB.DEFAULT_LPN_SUB_LOC_INFO(L_LPN_ID,
                                                  L_XFR_LPN_ID,
                                                  l_rti_sub_code,
                                                  l_rti_loc_id);

            END IF;
        END IF;

        -- First, call the RCV API for the Inspection.

        -- Bug 6781108
        -- Passing two variables to four parameters p_sub, p_loc_id,
        -- p_from_subinv and p_from_loc_id as new API
        -- for receiving needed these parameters
        -- pdube Wed Feb  6 23:22:10 PST 2008
        RCV_INSPECTION_GRP.INSERT_INSPECTION
           (p_api_version           => 1.1,
            p_init_msg_list         => NULL,
            p_commit                => 'F',
            p_validation_level      => NULL,
            p_created_by            => p_created_by,
            p_last_updated_by       => p_last_updated_by,
            p_last_update_login     => p_last_update_login,
            p_employee_id           => p_employee_id,
            p_group_id              => p_po_group_id,
            p_transaction_id        => p_transaction_id,
            p_transaction_type      => l_insp_result,
            p_processing_mode       => p_po_txn_processor_mode,
            p_quantity              => l_insp_qty,
            p_uom                   => p_uom,
            p_quality_code          => null,
            p_transaction_date      => p_transaction_date,
            p_comments              => null,
            p_reason_id             => null,
            p_vendor_lot            => l_vendor_lot_num, -- Bug 8806035
            p_lpn_id                => l_lpn_id,
            p_transfer_lpn_id       => l_xfr_lpn_id,
            p_qa_collection_id      => p_collection_id,
            p_return_status         => x_return_status,
            p_msg_count             => x_msg_count,
            p_msg_data              => x_msg_data,
            p_subinventory          => L_RTI_SUB_CODE,
            p_locator_id            => L_RTI_LOC_ID,
            p_from_subinventory     => L_RTI_SUB_CODE,
            p_from_locator_id       => L_RTI_LOC_ID);

        -- Bug 9356158.pdube
        -- uncommented the code for getting the interface_txn_id, because this is passed
        -- to insert_mtli and insert_mtsi apis.

        -- Bug 3225280. Moved the Lot and serial insertion code after RCV
        -- insert_inspection API because, we want the interface_transaction_id
        -- of the ACCEPT and REJECT transactions to be passed to the WMS APIs
        -- as product_transaction_id.
        --
        -- For this, first we need to find the interface_transaction_id of the
        -- inspection record inserted by RCV API. The logic here is to fetch the
        -- max(interface_transaction_id) from rti for the parent_transaction_id
        -- and group_id combination. Since we are implementing this just after
        -- RCV API call, it will fetch the interface_transaction_id of the
        -- inspection record just inserted.
        -- kabalakr. Wed Oct 29 23:19:22 PST 2003.
        --

        OPEN int_txn(p_po_group_id, p_transaction_id);
        FETCH int_txn INTO l_rti_int_txn_id;
        CLOSE int_txn;

        -- Bug 6781108
        -- Commenting the following fix for 3270283
        -- as already handled above through the INSERT_INSPECTION API
        -- pdube Wed Feb  6 04:53:32 PST 2008

        /*-- Bug 3270283. For LPN inspections, we need to default the receiving
        -- subinventory and Locator for the transfer LPN, if its a newly
        -- created one OR, it has a LPN context 'Defined but not used'.
        -- The new procedure DEFAULT_LPN_SUB_LOC_INFO() takes care of this
        -- defaulting logic entirely. Hence just call this procedure if its
        -- a LPN inspection. kabalakr Mon Mar  8 08:01:35 PST 2004.

        IF l_lpn_id IS NOT NULL THEN

           QLTDACTB.DEFAULT_LPN_SUB_LOC_INFO(l_lpn_id,
                                             l_xfr_lpn_id,
                                             l_rti_int_txn_id);

        END IF; -- If l_lpn_id is not null*/
	-- End bug 6781108


        -- Bug 3229571. If the Lot_number or Serial_number is 'DEFERRED', do not
        -- process now. It means we are posting inspection txn for the qty left
        -- in the lot which is not inspected. We need to derive the lot and serials
        -- that needs to be attached to this txn.

        IF ((l_lot_number IS NOT NULL) AND (l_lot_number <> 'DEFERRED')) THEN

            OPEN  item_uom_cur(l_item_id, l_org_id);
            FETCH item_uom_cur INTO l_primary_uom;
            CLOSE item_uom_cur;

            IF (l_primary_uom = p_uom) THEN
                l_primary_qty := l_insp_qty;

            ELSE
                l_primary_qty := inv_convert.inv_um_convert
                                   (l_item_id,
                                    NULL,
                                    l_insp_qty,
                                    p_uom,
                                    l_primary_uom,
                                    NULL,
                                    NULL);

            END IF;

            l_int_txn_id := NULL;

            -- Now, call the Inventory/WMS API for Lot Insertion.
            -- Passing NULL value to p_transaction_interface_id to allow the
            -- API to generate one. Bug 3096256.

            -- Bug 3225280. Changed the value passed as p_product_transaction_id
            -- to l_rti_int_txn_id, derived above.

            INV_RCV_INTEGRATION_APIS.INSERT_MTLI
               (p_api_version                => 1.0,
                p_init_msg_lst               => NULL,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data,
                p_transaction_interface_id   => l_int_txn_id,
                p_transaction_quantity       => l_insp_qty,
                p_primary_quantity           => l_primary_qty,
                p_organization_id            => l_org_id,
                p_inventory_item_id          => l_item_id,
                p_lot_number                 => l_lot_number,
                p_expiration_date            => NULL,
                p_status_id                  => NULL,
                x_serial_transaction_temp_id => l_ser_txn_id,
                p_product_code               => 'RCV',
                p_product_transaction_id     => l_rti_int_txn_id);

            if x_return_status <> 'S' then
                qa_skiplot_utility.insert_error_log (
                p_module_name => 'QA_SAMPLING_PKG.LAUNCH_SHIPMENT_ACTION_INT',
                p_error_message => 'QA_WMS_LOT_INSERT_FAIL',
                p_comments => x_msg_data);
                fnd_message.clear;
                fnd_message.set_name ('QA', 'QA_WMS_LOT_INSERT_FAIL');
                APP_EXCEPTION.RAISE_EXCEPTION;
            end if;


        END IF;


        IF ((l_serial_number IS NOT NULL) AND (l_serial_number <> 'DEFERRED')) THEN

            IF ((l_lot_number IS NOT NULL) AND (l_lot_number <> 'DEFERRED')) THEN
                l_int_txn_id := l_ser_txn_id;

            ELSE
                l_int_txn_id := NULL;

            END IF;

            -- Now, call the Inventory/WMS API for Serial Insertion.
            -- Passing NULL value to p_transaction_interface_id to allow the
            -- API to generate one. Bug 3096256.

            -- Bug 3225280. Changed the value passed as p_product_transaction_id
            -- to l_rti_int_txn_id, derived above.

            INV_RCV_INTEGRATION_APIS.INSERT_MSNI
              (p_api_version              => 1.0,
               p_init_msg_lst             => NULL,
               x_return_status            => x_return_status,
               x_msg_count                => x_msg_count,
               x_msg_data                 => x_msg_data,
               p_transaction_interface_id => l_int_txn_id,
               p_fm_serial_number         => l_serial_number,
               p_to_serial_number         => l_serial_number,
               p_organization_id          => l_org_id,
               p_inventory_item_id        => l_item_id,
               p_status_id                => NULL,
               p_product_code             => 'RCV',
               p_product_transaction_id   => l_rti_int_txn_id);

            if x_return_status <> 'S' then
                qa_skiplot_utility.insert_error_log (
                p_module_name => 'QA_SAMPLING_PKG.LAUNCH_SHIPMENT_ACTION_INT',
                p_error_message => 'QA_WMS_SER_INSERT_FAIL',
                p_comments => x_msg_data);
                fnd_message.clear;
                fnd_message.set_name ('QA', 'QA_WMS_SER_INSERT_FAIL');
                APP_EXCEPTION.RAISE_EXCEPTION;
            end if;

        END IF;

        -- Bug 3229571. Call the procedure insert_lot_serial_txn for posting the lot
        -- and serial info for the qty not inspected. We have already assigned a value
        -- of 'DEFERRED' to identify this transaction.

        IF ((l_lot_number = 'DEFERRED') AND (l_serial_number = 'DEFERRED')) THEN

           insert_lot_serial_txn(p_transaction_id,
                                 l_rti_int_txn_id,
                                 l_item_id,
                                 l_org_id,
                                 p_uom);

        END IF;


    END LOOP;

END launch_shipment_action_int;



-- following procedure is written to avoid code duplication.
-- qa_insp_plans_temp is being updated 3 times and this procedure
-- consolidates the code.
-- anagarwa Thu Oct 25 11:08:47 PDT 2001
procedure update_qa_insp_plans_temp(p_sample_size number,
                                    p_c_num       number,
                                    p_rej_num     number,
                                    p_aql         number,
                                    p_coll_id     number,
                                    p_plan_id     number)
is

begin
     update qa_insp_plans_temp
     set sample_size     = p_sample_size,
     c_number            = p_c_num,
     rejection_number    = p_rej_num,
     aql                 = p_aql
     where collection_id = p_coll_id
     and plan_id         = p_plan_id;

end ; -- update_qa_insp_plans_temp

    --
    -- local function
    --
    function get_softcoded_column(
    p_plan_id in number) return varchar2
    is

    cursor res_cur is
        select result_column_name
        from qa_plan_chars
        where plan_id = p_plan_id
        and char_id = 8; --8 is Inspection Result

    res_col varchar2(20);

    begin
        --this function returns the softcoded column in qa_results
        --where Inspection Result is stored for the given plan_id
        open res_cur;

        fetch res_cur into res_col;

        close res_cur;

        return res_col;

    end;--end function

    --
    -- local function
    --
    function get_rcv_criteria_str(
    p_criteria_id in number,
    p_wf_role_name out NOCOPY varchar2) return varchar2 is

    cursor rcv_criteria (x_criteria_id number) is
        select vendor_name,
        vendor_site_code,
        item,
        item_revision,
        category_desc,
        project_number,
        task_number,
        wf_role_name
        from qa_sampling_rcv_criteria_v
        where criteria_id = x_criteria_id;

    cursor char_names is
        select name
        from qa_chars
        where char_id in (10, 11, 13, 26, 121, 122, 130)
        order by char_id;


    x_supplier qa_chars.name%type;
    x_supplier_site qa_chars.name%type;
    x_item qa_chars.name%type;
    x_rev qa_chars.name%type;
    x_cat qa_chars.name%type;
    x_project qa_chars.name%type;
    x_task qa_chars.name%type;

    x_criteria_str varchar2(2000) := '';
    x_vendor_name varchar2(240);
    x_vendor_site_code varchar2(100);
    x_item_name varchar2(40);
    x_item_rev varchar2(30);
    x_item_cat varchar2(500);

    x_project_number varchar2(100);
    x_task_number varchar2(25);

    begin
        --this function is used while calling reduced sampling workflow
        --concatenate the context criteria values as a string
        --this string passed to OB's workflow function
        open rcv_criteria (p_criteria_id);
        fetch rcv_criteria into
        x_vendor_name,
        x_vendor_site_code,
        x_item_name,
        x_item_rev,
        x_item_cat,
        x_project_number,
        x_task_number,
        p_wf_role_name;

        close rcv_criteria;

        if p_wf_role_name is null then
            return null;
        end if;

        -- While construction x_criteria_str, it is imperative that no
        -- hardcoding is used. Strings like 'Supplier' need to be removed and
        -- replaced by variables. This is mandatory requirement to keep the
        -- text translatable to other languages.
        -- This can be achieved by using the cursor as follows
        -- anagarwa Thu Oct 25 11:08:47 PDT 2001
       open char_names;
        fetch char_names into x_item; -- char_id 10
        fetch char_names into x_cat; -- char_id 11
        fetch char_names into x_rev; -- char_id 13
        fetch char_names into x_supplier; -- char_id 26
        fetch char_names into x_project; -- char_id 121
        fetch char_names into x_task; -- char_id 122
        fetch char_names into x_supplier_site; -- char_id 130
        close char_names;
        if x_vendor_name is not null then
            x_criteria_str := x_criteria_str ||
            x_supplier || ' = ' || x_vendor_name || '; ';
        end if;
        if x_vendor_site_code is not null then
            x_criteria_str :=  x_criteria_str ||
            x_supplier_site || ' = ' ||x_vendor_site_code || '; ';
        end if;
        if x_item_name is not null then
            x_criteria_str := x_criteria_str ||
            x_item || ' = ' || x_item_name || '; ';
        end if;
        if x_item_rev is not null then
            x_criteria_str := x_criteria_str ||
            x_rev || ' = ' || x_item_rev || '; ';
        end if;
        if x_item_cat is not null then
            x_criteria_str := x_criteria_str ||
            x_cat || ' = ' || x_item_cat || '; ';
        end if;
        if x_project_number is not null then
            x_criteria_str := x_criteria_str ||
            x_project || ' = ' || x_project_number || '; ';
        end if;
        if x_task_number is not null then
            x_criteria_str := x_criteria_str ||
            x_task || ' = ' || x_task_number || '; ';
        end if;

        return x_criteria_str;
  end; --end function


--public procedures/functions below

--the purpose of this function is to evaluate to see if there is
--applicable sampling plan for each collection plan and context values
--if sampling plan is not found, put -1 for sampling plan id
--for multiple collection plans case, if one collection plan has sampling,
--then the whole record uses sampling, and the sampling flag set to Y
--

--
-- removed parameter default values. default values should only be
-- put in spec per new coding standard
-- jezheng
-- Wed Nov 27 15:13:11 PST 2002
--
procedure eval_rcv_sampling_plan (
                        p_collection_id IN NUMBER,
                        p_organization_id IN number,
                        p_lot_size      in number,
                        p_item_id       in number ,
                        p_item_category_id in number ,
                        p_item_revision in varchar2 ,
                        p_vendor_id     in number ,
                        p_vendor_site_id in number ,
                        p_project_id    in number ,
                        p_task_id       in number ,
                        p_sampling_flag out     NOCOPY varchar2
                        )
IS
        l_sampling_plan_id number := -1;
        l_criteria_id number := -1;
        l_sampling_flag varchar2(1) := 'N';
        out_sample_size number := p_lot_size;

        cursor plan_cur
        is
                select plan_id
                from qa_insp_plans_temp qipt
                where collection_id = p_collection_id;

    --
    -- removed the rownum = 1 statement from this cursor
    -- since rownum cound is done before ordering which
    -- will give wrong criteria
    -- jezheng
    -- Thu Oct 18 18:18:29 PDT 2001
    --
        cursor criteria_cur (
                        x_organization_id IN number,
                        x_item_id       in number,
                        x_item_category_id in number,
                        x_item_revision in varchar2,
                        x_vendor_id     in number,
                        x_vendor_site_id in number,
                        x_project_id    in number,
                        x_task_id       in number,
                        x_collection_plan_id in number)
        is
                select
                        sampling_plan_id, criteria_id
                from
                        qa_sampling_rcv_criteria_val_v qsrc
                where
                        qsrc.vendor_id in (-1,  x_vendor_id) AND
                        qsrc.vendor_site_id in (-1, x_vendor_site_id) AND
                        qsrc.item_id in (-1, x_item_id)AND
                        qsrc.item_revision in ('-1', x_item_revision) AND
                        qsrc.item_category_id in (-1, x_item_category_id) AND
                        qsrc.project_id  in (-1, x_project_id) AND
                        qsrc.task_id in (-1, x_task_id) AND
                      qsrc.collection_plan_id in (-1, x_collection_plan_id) AND
                        qsrc.organization_id = x_organization_id AND
                        trunc(sysdate) BETWEEN
                        nvl(trunc(qsrc.effective_from), trunc(sysdate)) AND
                        nvl(trunc(qsrc.effective_to), trunc(sysdate))
    ORDER BY
            task_id desc, project_id desc ,
            vendor_site_id desc, vendor_id desc, item_revision desc,
            item_id desc, item_category_id desc, collection_plan_id desc,
            last_update_date desc;

    -- Bug 7270226.FP for bug#7219703
    -- Getting the categories having criterion defined
    -- for skipping or sampling for the item.
    -- pdube Thu Nov 26 03:19:15 PST 2009
    CURSOR item_categories (
                       x_item_id NUMBER,
                       x_organization_id number,
                       x_item_category_id number) IS
               SELECT Nvl(micv.category_id,-1) item_category_id
               FROM MTL_ITEM_CATEGORIES_V MICV,
                    QA_SAMPLING_PLANS qsp,
                    qa_sampling_rcv_criteria_val_v qsrcvv
               WHERE micv.inventory_item_id= x_item_id AND
                     micv.organization_id= x_organization_id AND
                     qsrcvv.item_category_id = micv.category_id AND
                     qsp.sampling_plan_id = qsrcvv.sampling_plan_id AND
                     micv.category_id <> x_item_category_id
               ORDER BY qsp.sampling_plan_code asc;


BEGIN

        p_sampling_flag := 'N'; --initialize this to N
        for plan_rec in plan_cur
        loop
                open criteria_cur(
                        x_organization_id =>p_organization_id,
                        x_item_id => nvl(p_item_id, -1),
                        x_item_category_id => nvl(p_item_category_id, -1),
                        x_item_revision => nvl(p_item_revision, '-1'),
                        x_vendor_id  => nvl(p_vendor_id, -1),
                        x_vendor_site_id => nvl(p_vendor_site_id, -1),
                        x_project_id    => nvl(p_project_id, -1),
                        x_task_id       => nvl(p_task_id, -1),
                        x_collection_plan_id => plan_rec.plan_id);
                fetch criteria_cur into l_sampling_plan_id, l_criteria_id;
                close criteria_cur;

                -- Bug 7270226.FP for bug#7219703
                -- Added this code to check for criteria based on
                -- categories defined out of "Purchasing" Category Set.
                -- pdube Thu Nov 26 03:19:15 PST 2009
                if (l_sampling_plan_id = -1) then
                        for prec in item_categories(p_item_id,p_organization_id,p_item_category_id) loop
                           open criteria_cur(
                              x_organization_id =>p_organization_id,
                              x_item_id => nvl(p_item_id, -1),
                              x_item_category_id => nvl(prec.item_category_id, -1),
                              x_item_revision => nvl(p_item_revision, '-1'),
                              x_vendor_id  => nvl(p_vendor_id, -1),
                              x_vendor_site_id => nvl(p_vendor_site_id, -1),
                              x_project_id    => nvl(p_project_id, -1),
                              x_task_id       => nvl(p_task_id, -1),
                              x_collection_plan_id => plan_rec.plan_id);
                           fetch criteria_cur into l_sampling_plan_id, l_criteria_id;
                           close criteria_cur;
                           exit when(l_sampling_plan_id <> -1);
                         end loop;
                 end if;
                 -- End of Bug 7270226.FP for bug#7219703

                if (l_sampling_plan_id <> -1) --means sampling plan present
                then
                        update qa_insp_plans_temp
                        set sampling_plan_id = l_sampling_plan_id,
                            sampling_criteria_id = l_criteria_id
                        where collection_id = p_collection_id
                        and plan_id = plan_rec.plan_id;

                        l_sampling_flag := 'Y'; --even if one sampling found
                        --also update the temp table flag
                        update qa_insp_collections_temp
                        set sampling_flag = 'Y'
                        where collection_id = p_collection_id;

                        p_sampling_flag := 'Y'; --set out parameter
                else
                        update qa_insp_plans_temp
                        set sampling_plan_id = -1,
                            sampling_criteria_id = -1
                        where collection_id = p_collection_id
                        and plan_id = plan_rec.plan_id;
                        --should NOT reset l_sampling_flag here
                end if;

                set_sample_size(l_sampling_plan_id,
                                p_collection_id,
                                plan_rec.plan_id,
                                p_lot_size,
                                out_sample_size);

                -- need to reset l_sampling_plan_id to -1
                l_sampling_plan_id := -1;

        end loop;

END; --end procedure

--
--This checks the QA_SAMPLING_CUSTOM_RULES table based on sampling plan id
--and lot size and return the custom sample size if found. Otherwise, it
--checks QA_SAMPLING_PLANS table and gets the standard code, c number
--and AQL and checks the QA_SAMPLING_STD_RULES table and return the std.
--sample size
--Note: Some alterations to the table columns were being made
--Please refer to detail design for more information
--
procedure set_sample_size(
                        p_sampling_plan_id in number,
                        p_collection_id in number,
                        p_collection_plan_id in number,
                        p_lot_size in number,
                        p_sample_size out NOCOPY number)
is
        l_sample_size number := p_lot_size;
        l_c_num number := 0;
        l_rej_num number := 1;
        l_aql number := null;
        l_std_code number := null;
        l_insp_level varchar2(5) := null;
        l_lot_size_code varchar2(1) := null;

        cursor sampling_plan_cur
        is
                select sampling_std_code, AQL, insp_level_code
                from QA_SAMPLING_PLANS qsp
                where sampling_plan_id = p_sampling_plan_id;

        cursor custom_sample_cur
        is
                select sample_size
                from QA_SAMPLING_CUSTOM_RULES   qscr
                where qscr.sampling_plan_id = p_sampling_plan_id
                and p_lot_size between qscr.min_lot_size
                                and nvl(qscr.max_lot_size,p_lot_size);
                --max lot size could be null. this is the reason for nvl

        cursor std_sample_cur(x_std_code in number,
                               x_aql in number,
                               x_table_seq in number,
                               x_lot_code in varchar2)
        is
                select sample_size, c_number, rejection_number
                from qa_sampling_std_rules qssr
                where qssr.sampling_std_code = x_std_code
                        and qssr.aql = x_aql
                        and qssr.table_seq = x_table_seq
                        and qssr.lot_size_code = x_lot_code;

        cursor lot_code_cur(x_insp_level in varchar2)
        is
                select lot_size_code
                from qa_sampling_insp_level qsil
                where qsil.insp_level_code = x_insp_level
                and   p_lot_size between qsil.min_lot_size
                                 and nvl(qsil.max_lot_size, p_lot_size);
begin
        if (p_sampling_plan_id = -1 OR p_sampling_plan_id is null)
        then
                l_sample_size := p_lot_size;
                l_c_num := 0;
                l_rej_num := 1;
                l_aql := null;

                -- replace update stmt by calling proc update_qa_insp_plans_temp
                -- anagarwa Thu Oct 25 11:08:47 PDT 2001
                update_qa_insp_plans_temp(l_sample_size, l_c_num, l_rej_num,
                                          l_aql, p_collection_id,
                                          p_collection_plan_id);

/*
                update qa_insp_plans_temp
                set sample_size = l_sample_size,
                    c_number = l_c_num,
                    rejection_number = l_rej_num,
                    aql = l_aql
                where collection_id = p_collection_id
                and plan_id = p_collection_plan_id;

*/
                p_sample_size := l_sample_size;--set out parameter
        else --p_sampling_plan_id is not -1, we can open cursor
                open sampling_plan_cur;
                fetch sampling_plan_cur into l_std_code, l_aql, l_insp_level;
                close sampling_plan_cur;

                if (l_std_code = qa_sampling_pkg.custom_sampling_plan)
                then
                        open custom_sample_cur;
                        fetch custom_sample_cur into l_sample_size;
                        close custom_sample_cur;
                        l_c_num := 0;
                        l_rej_num := 0;
                        --
                        -- bug 6122194
                        -- If sample size is larger than lot size, use lot size
                        -- bhsankar Tue Jul  3 03:40:41 PDT 2007
                        --
                        l_sample_size := least(l_sample_size, p_lot_size);

                -- replace update stmt by calling proc update_qa_insp_plans_temp
                -- anagarwa Thu Oct 25 11:08:47 PDT 2001
                        update_qa_insp_plans_temp(l_sample_size, l_c_num,
                                          l_rej_num, null, p_collection_id,
                                          p_collection_plan_id);
/*
                        update qa_insp_plans_temp
                        set sample_size = l_sample_size,
                            c_number = l_c_num,
                            rejection_number = l_rej_num,
                            aql = null -- no aql for custom sampling
                        where collection_id = p_collection_id
                                and plan_id = p_collection_plan_id;
*/

                        p_sample_size := l_sample_size;--set out param
                else --use standard sampling plan
                        open lot_code_cur(l_insp_level);
                        fetch lot_code_cur into l_lot_size_code;
                        close lot_code_cur;

                        open std_sample_cur(l_std_code, l_aql, 1,
                                                l_lot_size_code);
                        fetch std_sample_cur
                              into l_sample_size,
                                   l_c_num,
                                   l_rej_num;
                        close std_sample_cur;

            --
            -- if sample size is larger than lot size, use lot size
            -- jezheng
            -- reference bug 2331892
            --
            l_sample_size := least(l_sample_size, p_lot_size);

                -- replace update stmt by calling proc update_qa_insp_plans_temp
                -- anagarwa Thu Oct 25 11:08:47 PDT 2001
                        update_qa_insp_plans_temp(l_sample_size, l_c_num,
                                          l_rej_num, l_aql, p_collection_id,
                                          p_collection_plan_id);
/*
                        update qa_insp_plans_temp
                        set sample_size = l_sample_size,
                                c_number = l_c_num,
                                rejection_number = l_rej_num,
                                aql = l_aql
                        where collection_id = p_collection_id
                        and plan_id = p_collection_plan_id;
*/

                        p_sample_size := l_sample_size; --set out param
                end if; -- end inner if

        end if;

end; -- end procedure

--
--This procedure calculates the collection plan result based on
--the sample inspection result and the sampling plan setup
--If reduced inspection, then workflow is launched to notify
--about this reduced inspection event
-- launch_workflow is a wrapper to call OB's api
--
--
-- Bug 6129041
-- Added an IN parameter p_item_id which defaults to null.
-- The item id is required to correctly calculate the rejected quantity
-- in case of LPN Inspection.
-- skolluku Wed Jul 11 03:37:20 PDT 2007
--
procedure get_plan_result(
                        p_collection_id in number,
                        p_coll_plan_id in number,
                        out_plan_insp_result out NOCOPY varchar2,
                        p_item_id in number default null)
is
        l_sampling_flag varchar2(1) := 'N';
        in_str varchar2(3000);

        -- anagarwa Fri Mar 29 11:56:16 PST 2002
        -- result_column needs to be same length as being selected from
        -- po_lookup_codes otherwise it was causing an unhandled exception
        -- on the click of OK button in RCV TXN form if sampling was involved.

        -- result_column varchar2(10);
        result_column po_lookup_codes.displayed_field%type;

        sql_str varchar2(5000);
        result varchar2(20);
        reject_qty number;
        l_c_num number := 0;
        l_rej_num number := 1;
        l_criteria_id number;
        l_sampling_plan_id number;
        l_sampling_std_code qa_sampling_plans.sampling_std_code%type;
        out_wf_item_key number;

        cursor sampling_flag_cur
        is
                select sampling_flag
                from qa_insp_collections_temp
                where collection_id = p_collection_id;

        cursor rej_cur
        is
                select c_number, rejection_number,
                        sampling_plan_id, sampling_criteria_id
                from qa_insp_plans_temp
                where collection_id = p_collection_id
                and plan_id = p_coll_plan_id;

        cursor sampling_std_code_cur (x_sampling_plan_id number)
        is
                select sampling_std_code
                from qa_sampling_plans
                where sampling_plan_id = x_sampling_plan_id;

begin
        open sampling_flag_cur;
        fetch sampling_flag_cur into l_sampling_flag;
        close sampling_flag_cur;

        if (l_sampling_flag <> 'Y')
        then
                out_plan_insp_result := null;
                return; --terminate procedure and return
        end if;
        -- proceed beyond this point means sampling_flag is Y
        result_column := get_softcoded_column (p_coll_plan_id);

        -- select in_str from po_lookupcodes instead of fnd_lookup_values as
        -- displayed_field in po_lookup_codes is traslatable string
        -- anagarwa Thu Oct 25 11:08:47 PDT 2001

        in_str :=
        'select displayed_field ' ||
        ' from po_lookup_codes ' ||
        ' where lookup_type = ''ERT RESULTS ACTION''' ||
        ' and lookup_code = ''REJECT''';
/*
        in_str :=
        'select meaning ' ||
        'from fnd_lookup_values lv ' ||
        'where view_application_id = 201 and ' ||
        -- following line commented out based upon code review feedback
        -- anagarwa Thu Oct 25 10:52:48 PDT 2001
        -- 'security_group_id = fnd_global.lookup_security_group ' ||
        '(lv.lookup_type,lv.view_application_id) and ' ||
        'lookup_type = ''ERT RESULTS ACTION'' and lookup_code = ''REJECT''';

*/
        --
        -- check whether there is a rejection for the plan
        -- since we store the inspection result meaning which
        -- can be in any language, we use in statement to check
        -- inspection result in all possible language
        --
/*
        sql_str := 'select sum(quantity) from qa_results where exists ' ||
        '(select ' || result_column || ' from qa_results ' ||
        'where collection_id = :1 and plan_id = :2 and '||
        result_column || ' in (' || in_str || ' ))';
*/

        -- anagarwa Wed Jan  9 15:44:08 PST 2002
        -- Bug 2170122 was being caused by faulty sql above which needs to
        -- be replaced by the one below. Using 'where exists' and not
        -- restricting by plan_id and collection_id results in multiple
        -- rows being returned which are then summed up as rejected qty.
        -- This in turn causes the whole lot to be rejected inspite of high
        -- AQL. Following sql computes correct rejected qty by restricting the
        -- qa_results row by plan_id and collection_id.

        --
        -- Bug 6129041
        -- Commented the below code and replaced with the code which
        -- considers item_id to build the sql_str and then execute using p_item_id
        -- The null check is included because this procedure is also called from
        -- QLTRES.pld which does not pass item_id. Hence if p_item_id is null, the
        -- procedure executes as before.
        -- skolluku Wed Jul 11 03:37:20 PDT 2007
        --
        /*
        sql_str := 'select sum(quantity) from qa_results ' ||
        'where  collection_id = :1 and plan_id = :2 and ' ||
        result_column || ' in (' || in_str || ' )';

        execute immediate sql_str into reject_qty
        using p_collection_id, p_coll_plan_id;
        */
        sql_str := 'select sum(quantity) from qa_results ' ||
        'where  collection_id = :1 and plan_id = :2 and ';
        if p_item_id is not null then
            sql_str := sql_str || ' item_id = :3 and ';
        end if;
        sql_str := sql_str || result_column || ' in (' || in_str || ' )';

        if p_item_id is null then
            execute immediate sql_str into reject_qty
            using p_collection_id, p_coll_plan_id;
        else
            execute immediate sql_str into reject_qty
            using p_collection_id, p_coll_plan_id, p_item_id;
        end if;

        reject_qty := nvl(reject_qty, 0);

        --set the total qty rejected for this collection plan
        update qa_insp_plans_temp
        set plan_rejected_qty = reject_qty
        where collection_id = p_collection_id
        and plan_id = p_coll_plan_id;

        open rej_cur;
        fetch rej_cur into l_c_num, l_rej_num,
                           l_sampling_plan_id, l_criteria_id;
        close rej_cur;

        if reject_qty <= l_c_num
        then
                result := 'ACCEPT';
        elsif reject_qty >= l_rej_num
        then
                result := 'REJECT';
        else
                --check for reduced sampling
                open sampling_std_code_cur(l_sampling_plan_id);
                fetch sampling_std_code_cur into l_sampling_std_code;
                close sampling_std_code_cur;

                if (l_sampling_std_code = REDUCED_SAMPLING_PLAN)
                then
                        result := 'ACCEPT';
                        launch_workflow(l_criteria_id, p_coll_plan_id,
                                                out_wf_item_key);
                else
                        result := 'FUZZY';
                end if;
        end if;

        update qa_insp_plans_temp
        set plan_insp_result = result
        where collection_id = p_collection_id
        and plan_id = p_coll_plan_id;

        out_plan_insp_result := result;
    exception
        when  no_data_found then
            out_plan_insp_result := 'ACCEPT';
            return;

null;
end;

--
--This procedure is used to compute the lot inspection result
--based on the results of the collection plans
--
procedure get_lot_result(
                        p_collection_id in number,
                        lot_insp_result out NOCOPY varchar2)
is
        l_sampling_flag varchar2(1) := null;
        result varchar2(20);
        l_rejected number := 0;
        total_number_rej number := 0;

        cursor sampling_flag_cur
        is
        select sampling_flag
        from qa_insp_collections_temp
        where collection_id = p_collection_id;

        cursor plan_result_cur
        is
        select count(*) AS rejected_plans
        from qa_insp_plans_temp
        where collection_id = p_collection_id
        and plan_insp_result = 'REJECT';

        cursor total_rej_cur
        is
        select sum(plan_rejected_qty) AS total_rej_qty
        from qa_insp_plans_temp
        where collection_id = p_collection_id;

begin
        open sampling_flag_cur;
        fetch sampling_flag_cur into l_sampling_flag;
        close sampling_flag_cur;

        if (l_sampling_flag = 'Y')
        then
                open plan_result_cur;
                fetch plan_result_cur into l_rejected;
                close plan_result_cur;

                if (l_rejected > 0)
                then
                        result := 'REJECT';
                else
                        result := 'ACCEPT';
                end if;--end inner if

                update qa_insp_collections_temp
                set lot_result = result
                where collection_id = p_collection_id;
        end if;
        lot_insp_result := result; --set the out variable

        --get the total rejection for this lot and update the temptable
        open total_rej_cur;
        fetch total_rej_cur into total_number_rej;
        close total_rej_cur;

        update qa_insp_collections_temp
        set total_rejected_qty = total_number_rej
        where collection_id = p_collection_id;

null;
end;

--
--This procedure is a wrapper to call the RCV API to perform accept or reject
--From the qa_insp_collections_temp table find out the lotsize, lotresult
--based on that call the RCV API to perform the action
--this procedure called from qainspb.pls (the qainspb.pls has a wrapper)
--the qainspb.pls wrapper is called from client side QLTRES.pld
--
procedure launch_shipment_action(
    p_po_txn_processor_mode IN VARCHAR2,
    p_po_group_id IN NUMBER,
    p_collection_id IN NUMBER,
    p_employee_id IN NUMBER,
    p_transaction_id IN NUMBER,
    p_uom IN VARCHAR2,
    p_transaction_date IN DATE,
    p_created_by IN NUMBER,
    p_last_updated_by IN NUMBER,
    p_last_update_login IN NUMBER)
IS

        l_lot_size number;
        -- following 2 variables added to call PO's api twice, once for
        -- accepted quantity and once for rejected quantity
        -- anagarwa Thu Oct 25 11:08:47 PDT 2001
        l_accepted_qty number;
        l_rejected_qty number;

        l_lot_result varchar2(20);

        x_return_status varchar2(5);
        x_msg_count number;
        x_msg_data varchar2(240);

        cursor lot_info_cur
        is
        select lot_size, lot_result,total_rejected_qty
        from qa_insp_collections_temp
        where collection_id = p_collection_id;

        -- Added the below cursor and variable for RCV/WMS Merge.
        -- Bug 3096256. kabalakr Fri Aug 29 09:06:28 PDT 2003.

        cursor plan_count_cur
        is
        select count(*) AS insp_plans
        from qa_insp_plans_temp
        where collection_id = p_collection_id;

        l_plan_count    NUMBER;

        --BUG 4741324
        --Added a new variable to get a count of the LPN IDs
        --from qa_results for a particular Collection Id
        --ntungare  Mon Nov 21 20:44:54 PST 2005
        l_license_plate_no_id number;

        -- Bug 8806035.ntungare
        -- Added this cursor and variable for copying the supplier lot number information.
        CURSOR vend_lot_num (txn_id NUMBER) IS
          SELECT vendor_lot_num
           FROM rcv_transactions
          WHERE transaction_id = txn_id;

        l_vendor_lot_num VARCHAR2(30) := NULL;

begin
        --we dont need to check the sampling flag here
        --becos qa_inspection_pkg calls this only for sampling scenario
        open lot_info_cur;
        fetch lot_info_cur into l_lot_size, l_lot_result, l_rejected_qty;
        close lot_info_cur;

        -- Changes fro RCV/WMS Merge. If the Receiving Inspection involves
        -- only one Inspection Collection Plan, call the new procedure.
        -- This procedure supports unit wise inspection at lpn, lot and
        -- Serial levels.
        -- Bug 3096256. kabalakr Fri Aug 29 09:06:28 PDT 2003

        -- Check the no of plan involved from qa_insp_plans_temp.
        open  plan_count_cur;
        fetch plan_count_cur into l_plan_count;
        close plan_count_cur;

        -- Bug 8806035.ntungare
        -- Added this cursor to fetch the vendor_lot_number of the
	-- transaction from the rcv_transactions table.
        OPEN vend_lot_num(p_transaction_id);
        FETCH vend_lot_num INTO l_vendor_lot_num;
        CLOSE vend_lot_num;

        --
        -- Bug 4732741:
        -- The following select stmt is based on qa_results which is similar
        -- to the way LPN_ID's are fetched and processed in the procedure
        -- launch_shipment_action_int. In that procedure we fetch the
        -- lpn_id's from qa_results and post them in to temp table
        -- qa_insp_collections_dtl_temp and then process them. So based
        -- this cursor to fetch count of lpn_id from qa_results for the particular
        -- collection_id and if count is 0 stop calling the procedure
        -- launch_shipment_action_int.
        -- ntungare Mon Nov 14 21:11:30 PST 2005
        --
        SELECT Count(lpn_id) INTO l_license_plate_no_id
         FROM qa_results
        WHERE collection_id = p_collection_id;

        -- If the Plan count is 1, call the new procedure and return.
        -- IF (l_plan_count = 1) THEN

        --
        -- Bug 4732741
        -- If the Plan count is 1 and only when lpn_id count is non zero, call the
        -- new procedure. This new procedure has been originally written to
        -- support LPN transactions in desktop. If the extra condition based
        -- on lpn_id is not used then for all type of sampling inspection this
        -- code is called which results in bug.
        -- ntungare Mon Nov 14 21:15:35 PST 2005
        --
        IF ((l_plan_count = 1) AND (l_license_plate_no_id <>0)) THEN
           launch_shipment_action_int
             (p_po_txn_processor_mode => p_po_txn_processor_mode,
              p_po_group_id           => p_po_group_id,
              p_collection_id         => p_collection_id,
              p_employee_id           => p_employee_id,
              p_transaction_id        => p_transaction_id,
              p_uom                   => p_uom,
              p_transaction_date      => p_transaction_date,
              p_created_by            => p_created_by,
              p_last_updated_by       => p_last_updated_by,
              p_last_update_login     => p_last_update_login,
              p_lot_size              => l_lot_size,
              p_lot_result            => l_lot_result);

           -- No Need to continue as the Inspections are completed.
           -- Return from the procedure.
           return;

        END IF;


        -- calculate accepted qty
        -- anagarwa Thu Oct 25 11:08:47 PDT 2001
        l_accepted_qty := l_lot_size - l_rejected_qty;

        --call po api to launch accept/reject shipment action.
        --parameter p_transaction_type takes the result viz.Accept or Reject
        --parameter p_quantity is lot_size in the case of sampling

        -- anagarwa Thu Oct 25 11:08:47 PDT 2001
        -- if lot_result is ACCEPT then call API for accepted qty first and
        -- then look for Rejected_qty. If that's >0 then call the same API with
        -- rejected qty and result = 'REJECT'

        --
        -- modified p_commit values from 'T' to 'F' to fix
        -- bug 2056343. If p_commit = 'T', PO will commit the
        -- work and the skiplot/sampling temp table will be cleared
        -- and the sampling flag will not be available any more.
        -- This procedure is called in post-forms-commit.
        -- The transaction will be committed anyway when the
        -- forms is committed. So we should not commit here.
        -- jezheng
        -- Mon Nov 12 14:12:44 PST 2001
        --

        -- Modified the API call for RCV/EMS merge.
        -- p_api_version changed to 1.1. Also added p_lpn_id and
        -- p_transfer_lpn_id. Passed as NULL.
        -- kabalakr Thu Aug 28 08:34:59 PDT 2003.

        IF l_lot_result = 'ACCEPT' THEN
            RCV_INSPECTION_GRP.INSERT_INSPECTION(
            p_api_version           => 1.1,
            p_init_msg_list         => NULL,
            p_commit                => 'F',
            p_validation_level      => NULL,
            p_created_by            => p_created_by,
            p_last_updated_by       => p_last_updated_by,
            p_last_update_login     => p_last_update_login,
            p_employee_id           => p_employee_id,
            p_group_id              => p_po_group_id,
            p_transaction_id        => p_transaction_id,
            p_transaction_type      => l_lot_result,
            p_processing_mode       => p_po_txn_processor_mode,
            p_quantity              => l_accepted_qty,
            p_uom                   => p_uom,
            p_quality_code          => null,
            p_transaction_date      => p_transaction_date,
            p_comments              => null,
            p_reason_id             => null,
            p_vendor_lot            => l_vendor_lot_num, -- Bug 8806035
            p_lpn_id                => null,
            p_transfer_lpn_id       => null,
            p_qa_collection_id      => p_collection_id,
            p_return_status         => x_return_status,
            p_msg_count             => x_msg_count,
            p_msg_data              => x_msg_data);

          -- call this api again with rejected qty.

          IF (l_rejected_qty >0) THEN
            RCV_INSPECTION_GRP.INSERT_INSPECTION(
            p_api_version           => 1.1,
            p_init_msg_list         => NULL,
            p_commit                => 'F',
            p_validation_level      => NULL,
            p_created_by            => p_created_by,
            p_last_updated_by       => p_last_updated_by,
            p_last_update_login     => p_last_update_login,
            p_employee_id           => p_employee_id,
            p_group_id              => p_po_group_id,
            p_transaction_id        => p_transaction_id,
            p_transaction_type      => 'REJECT',
            p_processing_mode       => p_po_txn_processor_mode,
            p_quantity              => l_rejected_qty,
            p_uom                   => p_uom,
            p_quality_code          => null,
            p_transaction_date      => p_transaction_date,
            p_comments              => null,
            p_reason_id             => null,
            p_vendor_lot            => l_vendor_lot_num, -- Bug 8806035
            p_lpn_id                => null,
            p_transfer_lpn_id       => null,
            p_qa_collection_id      => p_collection_id,
            p_return_status         => x_return_status,
            p_msg_count             => x_msg_count,
            p_msg_data              => x_msg_data);
          END IF;

        -- anagarwa Thu Oct 25 11:08:47 PDT 2001
        -- if REJECT then call the API for lot_size
        ELSE
            RCV_INSPECTION_GRP.INSERT_INSPECTION(
            p_api_version           => 1.1,
            p_init_msg_list         => NULL,
            p_commit                => 'F',
            p_validation_level      => NULL,
            p_created_by            => p_created_by,
            p_last_updated_by       => p_last_updated_by,
            p_last_update_login     => p_last_update_login,
            p_employee_id           => p_employee_id,
            p_group_id              => p_po_group_id,
            p_transaction_id        => p_transaction_id,
            p_transaction_type      => l_lot_result,
            p_processing_mode       => p_po_txn_processor_mode,
            p_quantity              => l_lot_size,
            p_uom                   => p_uom,
            p_quality_code          => null,
            p_transaction_date      => p_transaction_date,
            p_comments              => null,
            p_reason_id             => null,
            p_vendor_lot            => l_vendor_lot_num, -- Bug 8806035
            p_lpn_id                => null,
            p_transfer_lpn_id       => null,
            p_qa_collection_id      => p_collection_id,
            p_return_status         => x_return_status,
            p_msg_count             => x_msg_count,
            p_msg_data              => x_msg_data);

        END IF;

null;
end; --end procedure

function is_sampling( p_collection_id in number ) return varchar2
is
        l_sampling_flag varchar2(1) := 'N';

        cursor sampling_flag_cur
        is
        select sampling_flag
        from qa_insp_collections_temp
        where collection_id = p_collection_id;

begin
        open sampling_flag_cur;
        fetch sampling_flag_cur into l_sampling_flag;
        close sampling_flag_cur;

        return l_sampling_flag;
null;
end;

procedure launch_workflow(
                        p_criteria_id IN NUMBER,
                        p_coll_plan_id IN NUMBER,
                        p_wf_item_key OUT NOCOPY NUMBER)
is
    x_plan_name varchar2(30);
    x_criteria_str varchar2(200);
    x_wf_role_name varchar2(360);
    x_wf_itemkey number;

    cursor plan_name_cur is
        select name
        from qa_plans
        where plan_id = p_coll_plan_id;

begin

  -- the below call to get_rcv_criteria_str is a local call to
  -- function in this same package
  -- similar function is available for skiplot package
  x_criteria_str := get_rcv_criteria_str(p_criteria_id,x_wf_role_name);
  if (x_wf_role_name is null) then
      return;
  end if;

  open plan_name_cur;
  fetch plan_name_cur into x_plan_name;
  close plan_name_cur;

  x_wf_itemkey := qa_inspection_wf.raise_reduced_inspection_event (
        p_lot_information => x_criteria_str,
        p_inspection_date => SYSDATE,
        p_plan_name => x_plan_name,
        p_role_name => x_wf_role_name);

  null;
end; --end launch_workflow procedure

    PROCEDURE parse_list(x_result IN VARCHAR2,
                         x_array OUT NOCOPY PlanArray) IS

        value VARCHAR2(2000) := '';
        c VARCHAR2(10);
        separator CONSTANT VARCHAR2(1) := ',';
        arr_index INTEGER := 1;
        p INTEGER := 1;
        n INTEGER := length(x_result);

    BEGIN
    --
    -- Loop until a single ',' is found or x_result is exhausted.
    --
        WHILE p <= n LOOP
            c := substr(x_result, p, 1);
            p := p + 1;
            IF (c = separator) THEN
               x_array(arr_index) := value;
               arr_index := arr_index + 1;
               value := '';
            ELSE
               value := value || c;
            END IF;

        END LOOP;
        x_array(arr_index) := value;
    END parse_list;


--
-- The procedure is typically used in WMS mobile inspection scenario
-- It takes a list of plan IDs as in parameter and get plan inpsection
-- result for each one. Then calculate lot result based on plan
-- result.
--
--
-- Bug 6129041
-- Added 2 IN params p_org_id and p_item which default to null
-- These params will be used to calculate the item_id
-- skolluku Wed Jul 11 03:37:20 PDT 2007
--
procedure calculate_lot_result(p_collection_id IN  NUMBER,
                               p_plan_ids      IN  VARCHAR2,
                               x_lot_result    OUT NOCOPY VARCHAR2,
                               x_rej_qty       OUT NOCOPY NUMBER,
                               x_acc_qty       OUT NOCOPY NUMBER,
                               p_org_id        IN  NUMBER DEFAULT NULL,
                               p_item          IN  VARCHAR2 DEFAULT NULL )
          IS

l_plan_id_array       PlanArray;
l_plan_id             NUMBER;
l_lot_size            NUMBER;
l_plan_insp_result    VARCHAR2(100);
l_lot_insp_result     VARCHAR2(100);
--
-- Bug 6129041
-- local variable hold item_id which will be calculated later.
-- skolluku Wed Jul 11 03:37:20 PDT 2007
--
l_item_id             NUMBER;

CURSOR lot_rej_cur IS
  SELECT total_rejected_qty, lot_size
  FROM   qa_insp_collections_temp
  WHERE  collection_id = p_collection_id;

BEGIN

    -- p_plan_ids is a comma separated list of plan_id
    -- parse p_plan_ids to get child plan ids in an array
     IF p_plan_ids IS NOT NULL THEN
         parse_list(p_plan_ids, l_plan_id_array);
     END IF;

     --
     -- Bug 6129041
     -- Calculate item_id if both P-org_id and p_item have been passed.
     -- Else assign null value to l_item_id.
     -- skolluku Wed Jul 11 03:37:20 PDT 2007
     --
     IF p_org_id IS NOT NULL AND p_item IS NOT NULL THEN
        l_item_id := qa_flex_util.get_item_id (p_org_id, p_item);
     ELSE
        l_item_id := null;
     END IF;

     -- for all plans do following
     FOR i IN 1..l_plan_id_array.COUNT LOOP
         l_plan_id := l_plan_id_array(i);
         -- get plan result.
         --
         -- Bug 5948234
         -- Pass l_item_id to the procedure get_plan_results
         -- skolluku Wed May 23 05:10:48 PDT 2007
         --
         get_plan_result(p_collection_id, l_plan_id, l_plan_insp_result,l_item_id);
     END LOOP; -- for loop ends here

     -- get lot result
     get_lot_result(p_collection_id, l_lot_insp_result);

     -- get total rejected qty and lot_size from temp table
     OPEN lot_rej_cur;
     FETCH lot_rej_cur INTO x_rej_qty, l_lot_size;
     CLOSE lot_rej_cur;

     IF l_lot_insp_result = 'ACCEPT' THEN
        x_acc_qty := l_lot_size - nvl(x_rej_qty,0);
     ELSIF l_lot_insp_result = 'REJECT' THEN
        x_acc_qty := 0;
        x_rej_qty := l_lot_size;
     ELSE
        x_acc_qty := 0;
        x_rej_qty := 0;
     END IF;

     x_lot_result := l_lot_insp_result;

END calculate_lot_result;


--
-- The procedure is typically used in WMS LPN based inspection scenario.
-- This procedure takes plan ID list as in parameter and call init_collection
-- for each plan. Then calls overloased procedure eval_rcv_sampling_plan to
-- check whether sampling should be used in this scenario. Sampling_flag is
-- returned
--
procedure eval_rcv_sampling_plan (
                        p_collection_id    IN NUMBER,
                        p_plan_id_list     IN VARCHAR2,
                        p_org_id           IN NUMBER,
                        p_lot_size         IN NUMBER,
                        p_lpn_id           IN NUMBER,
                        p_item             IN VARCHAR2,
                        p_item_id          IN NUMBER,
                        p_item_cat         IN VARCHAR2,
                        p_item_category_id IN NUMBER,
                        p_item_rev         IN VARCHAR2,
                        p_vendor           IN VARCHAR2,
                        p_vendor_id        IN NUMBER,
                        p_vendor_site      IN VARCHAR2,
                        p_vendor_site_id   IN NUMBER,
                        p_project_id       IN NUMBER,
                        p_task_id          IN NUMBER,
                        x_sampling_flag    OUT NOCOPY VARCHAR2
                        )
IS

l_plan_id_array       PlanArray;
l_plan_id             NUMBER;
l_project_id          NUMBER;
l_task_id             NUMBER;
l_vendor_id           NUMBER;
l_item_id             NUMBER;
l_category_id         NUMBER;
l_vendor_site_id      NUMBER;
l_category_val        VARCHAR2(1000);
l_item                VARCHAR2(2000);

BEGIN
    -- p_plan_ids is a comma separated list of plan_id
    -- parse p_plan_ids to get child plan ids in an array
     IF p_plan_id_list IS NOT NULL THEN
         parse_list(p_plan_id_list, l_plan_id_array);
     END IF;

     -- for all plans do following
     FOR i IN 1..l_plan_id_array.COUNT LOOP
         l_plan_id := l_plan_id_array(i);
         qa_inspection_pkg.init_collection(p_collection_id, p_lot_size,
                                           l_plan_id, null);
     END LOOP;

     l_item_id        := p_item_id;
     l_item           := p_item;
     l_vendor_id      := p_vendor_id;
     l_category_id    := p_item_category_id;
     l_category_val   := p_item_cat;
     l_vendor_site_id := p_vendor_site_id;

     IF ((p_item_id IS NULL OR p_item_id<1) AND
         p_item IS NOT NULL) THEN
        l_item_id := qa_flex_util.get_item_id (p_org_id, p_item);
     END IF;

     IF (p_item IS NULL AND p_item_id IS NOT NULL) THEN
        l_item := qa_flex_util.item(p_org_id, l_item_id);
     END IF;

     IF l_vendor_id IS NULL OR l_vendor_id < 1 THEN
        l_vendor_id := qa_plan_element_api.get_supplier_id(p_vendor);
     END IF;

     -- anagarwa Wed Apr  3 14:34:49 PST 2002
     -- MSCA change:  LPN is null if the txn_no =1022
     IF p_lpn_id IS NULL OR p_lpn_id = -1 THEN
        l_project_id := -1;
        l_task_id    := -1;
     ELSE
        -- txn is 1021
        l_project_id := qa_flex_util.get_project_id_from_lpn(p_org_id,
                                                             p_lpn_id);
        l_task_id    := qa_flex_util.get_task_id_from_lpn(p_org_id , p_lpn_id);
     END IF;

     IF p_item_category_id IS NULL OR p_item_category_id < 1 THEN

        qa_flex_util.get_item_category_val (p_org_id, l_item, l_item_id,
                                            l_category_val, l_category_id);
     END IF;

     IF p_vendor_site_id IS NULL OR p_vendor_site_id < 1 THEN
        l_vendor_site_id := qa_flex_util.get_vendor_site_id(p_vendor_site);
     END IF;



     eval_rcv_sampling_plan (
                        p_collection_id    => p_collection_id,
                        p_organization_id  => p_org_id,
                        p_lot_size         => p_lot_size,
                        p_item_id          => l_item_id,
                        p_item_category_id => l_category_id,
                        p_item_revision    => p_item_rev,
                        p_vendor_id        => l_vendor_id,
                        p_vendor_site_id   => l_vendor_site_id,
                        p_project_id       => l_project_id,
                        p_task_id          => l_task_id,
                        p_sampling_flag    => x_sampling_flag);

END eval_rcv_sampling_plan;


--
-- Bug 3096256. Added the following procedures for RCV/WMS Merge.
-- This procedure inserts the detailed Inspection results onto
-- qa_insp_collections_dtl_temp. This enables unit wise inspection
-- with LPN and at Lot/Serial levels.
-- Called from launch_shipment_action_int() of QA_SAMPLING_PKG and
-- QA_SKIPLOT_RES_ENGINE.
-- kabalakr Fri Aug 29 09:06:28 PDT 2003.
--

PROCEDURE post_insp_coll_details(p_collection_id IN NUMBER) IS


  TYPE insp_cur IS REF CURSOR;
  insp_acc           insp_cur;
  insp_rej           insp_cur;

  l_result_column    po_lookup_codes.displayed_field%type;

  l_occurrence       NUMBER;
  l_org_id           NUMBER;
  l_item_id          NUMBER;
  l_lpn_id           NUMBER;
  l_xfr_lpn_id       NUMBER;

  -- OPM Conv R12 Tracking Bug 4345760
  -- change variable size for lot num

  l_lot_num          qa_results.lot_number%TYPE;

  l_serial_num       VARCHAR2(25);
  l_qty              NUMBER;

  in_str_reject      VARCHAR2(240);
  in_str_accept      VARCHAR2(240);
  l_sql_rej          VARCHAR2(1000);
  l_sql_acc          VARCHAR2(1000);
  l_plan_id          NUMBER;

  CURSOR plan_cur IS
    select plan_id
    from   qa_insp_plans_temp
    where  collection_id = p_collection_id;


BEGIN

  OPEN plan_cur;
  FETCH plan_cur INTO l_plan_id;
  CLOSE plan_cur;

  -- Need to fetch the result column of the Inspection Result
  -- Collection element.

  l_result_column := get_softcoded_column(l_plan_id);

  -- Construct the SQL for fetching REJECT and ACCEPT from
  -- the results entered in Inspection Plan in qa_results.

  in_str_reject :=
    ' select displayed_field' ||
    ' from po_lookup_codes' ||
    ' where lookup_type = ''ERT RESULTS ACTION''' ||
    ' and lookup_code = ''REJECT''';


  in_str_accept :=
    ' select displayed_field' ||
    ' from po_lookup_codes ' ||
    ' where lookup_type = ''ERT RESULTS ACTION''' ||
    ' and lookup_code = ''ACCEPT''';


  l_sql_rej := 'select occurrence, organization_id, item_id, lpn_id,  xfr_lpn_id,'||
               ' lot_number, serial_number, quantity from qa_results' ||
               ' where  collection_id = :1 and plan_id = :2 and ' ||
                 l_result_column || ' in (' || in_str_reject || ' )';

  l_sql_acc := 'select occurrence, organization_id, item_id, lpn_id,  xfr_lpn_id,'||
               ' lot_number, serial_number, quantity from qa_results' ||
               ' where collection_id = :1 and plan_id = :2 and ' ||
                 l_result_column || ' in (' || in_str_accept || ' )';


  -- Get the required info from the results entered for the plan for 'ACCEPT'
  -- and insert the same onto qa_insp_collections_dtl_temp.

  OPEN insp_acc FOR l_sql_acc USING p_collection_id, l_plan_id;
  LOOP

    FETCH insp_acc INTO l_occurrence,
                        l_org_id,
                        l_item_id,
                        l_lpn_id,
                        l_xfr_lpn_id,
                        l_lot_num,
                        l_serial_num,
                        l_qty;

    EXIT WHEN insp_acc%NOTFOUND;

    insert into qa_insp_collections_dtl_temp
     (collection_id,
      occurrence,
      organization_id,
      item_id,
      lpn_id,
      xfr_lpn_id,
      lot_number,
      serial_number,
      insp_result,
      insp_qty
     )
     values
       (p_collection_id,
        l_occurrence,
        l_org_id,
        l_item_id,
        l_lpn_id,
        l_xfr_lpn_id,
        l_lot_num,
        l_serial_num,
        'ACCEPT',
        l_qty
       );

  END LOOP;

  CLOSE insp_acc;


  -- Get the required info from the results entered for the plan for 'REJECT'
  -- and insert the same onto qa_insp_collections_dtl_temp.

  OPEN insp_rej FOR l_sql_rej USING p_collection_id, l_plan_id;
  LOOP

    FETCH insp_rej INTO l_occurrence,
                        l_org_id,
                        l_item_id,
                        l_lpn_id,
                        l_xfr_lpn_id,
                        l_lot_num,
                        l_serial_num,
                        l_qty;

    EXIT WHEN insp_rej%NOTFOUND;

    insert into qa_insp_collections_dtl_temp
     (collection_id,
      occurrence,
      organization_id,
      item_id,
      lpn_id,
      xfr_lpn_id,
      lot_number,
      serial_number,
      insp_result,
      insp_qty
     )
     values
       (p_collection_id,
        l_occurrence,
        l_org_id,
        l_item_id,
        l_lpn_id,
        l_xfr_lpn_id,
        l_lot_num,
        l_serial_num,
        'REJECT',
        l_qty
       );

  END LOOP;

  CLOSE insp_rej;

END post_insp_coll_details;



END; -- End QA_SAMPLING_PKG


/
