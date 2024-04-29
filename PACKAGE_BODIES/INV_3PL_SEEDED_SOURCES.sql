--------------------------------------------------------
--  DDL for Package Body INV_3PL_SEEDED_SOURCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_3PL_SEEDED_SOURCES" AS
    /* $Header: INVSSRCB.pls 120.0.12010000.6 2010/04/06 09:01:33 damahaja noship $ */

    G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_3PL_SEEDED_SOURCES';
    g_debug       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


      PROCEDURE debug(
            p_message  IN  VARCHAR2
            ) IS
        BEGIN
            IF (g_debug = 1) THEN
            inv_log_util.trace(p_message, G_PKG_NAME , 10 );
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END debug;


        FUNCTION get_item_uom_code (p_uom_name   VARCHAR2) RETURN VARCHAR2 IS
            l_uom_code MTL_UNITS_OF_MEASURE.UOM_CODE%type := NULL;

        BEGIN

            SELECT uom_code
            INTO l_uom_code
            FROM mtl_units_of_measure_vl
            WHERE unit_of_measure = p_uom_name;

            RETURN (l_uom_code);

            EXCEPTION
                WHEN OTHERS THEN
                    debug('Error in get_item_uom_code function : '||sqlerrm);

        END get_item_uom_code;


        PROCEDURE number_receive_transactions
        (
          x_counter_value             OUT NOCOPY NUMBER,
          x_return_status             OUT NOCOPY VARCHAR2
        )
        as

        CURSOR items_record(p_client_code VARCHAR2) IS
        SELECT * FROM mtl_system_items_kfv msib
        WHERE  wms_deploy.get_client_code(msib.inventory_item_id) = p_client_code
        AND nvl(msib.USAGE_ITEM_FLAG, 'N')  = 'N'
        AND nvl(msib.SERVICE_ITEM_FLAG, 'N') = 'N'
        AND nvl(msib.VENDOR_WARRANTY_FLAG, 'N') = 'N';


        rt_counter NUMBER := 0;
        l_operating_unit NUMBER;
        l_client_code varchar2(10);
        l_temp NUMBER :=0;
        l_source_to_date date;
        l_last_computation_date date;
        l_service_line_start_date date;
        l_in_loop NUMBER := 0;

        BEGIN

        x_return_status := fnd_api.g_ret_sts_success;
        l_client_code := INV_3PL_BILLING_PUB.g_billing_source_rec.client_code; --'Business1';
        l_operating_unit := INV_3PL_BILLING_PUB.g_billing_source_rec.operating_unit; --'Business1';
        l_source_to_date := INV_3PL_BILLING_PUB.g_billing_source_rec.source_to_date;
        l_last_computation_date := INV_3PL_BILLING_PUB.g_billing_source_rec.last_computation_Date; --to_date('23-NOV-2009', 'DD-MON-YYYY'); --
        l_service_line_start_date := INV_3PL_BILLING_PUB.g_billing_source_rec.service_line_start_date;

        if l_last_computation_date is null then -- For 1st run of fresh LSP install
            l_last_computation_Date := l_service_line_start_date;
        end if;

        debug('Entered INV_3PL_SEEDED_SOURCES.number_receive_transactions ');
        debug('Got the values client_code => '|| l_client_code);
        debug('Got the values l_source_to_date => '|| l_source_to_date);
        debug('Got the values l_last_computation_date => '|| l_last_computation_date);
        debug('For client => '||l_client_code);


            FOR recs IN items_record(l_client_code)
                LOOP
                l_in_loop := 1;
                  debug('For client code =>  '||l_client_code);
                  debug('recs.item name => '||recs.segment1 ||'.'||recs.segment20);
                  debug('recs.item id =====================================> '||recs.inventory_item_id);
                  debug('recs.l_source_to_date => '|| To_Char(l_source_to_date, 'DD-MON-YYYY HH24:MI:SS'));
                  debug('recs.l_last_computation_date => '||  To_Char(l_last_computation_date, 'DD-MON-YYYY HH24:MI:SS'));

                    Select count(1) INTO l_temp
                    from rcv_transactions rt , rcv_shipment_lines rsl
                    WHERE rsl.shipment_line_id = rt.shipment_line_id
                    and rt.shipment_header_id = rt.shipment_header_id
                    AND rsl.item_id = recs.inventory_item_id
                    AND rt.creation_date <= l_source_to_date
                    AND rt.creation_date > l_last_computation_Date
                    AND rt.transaction_type = 'RECEIVE'
                    AND rt.organization_id = recs.organization_id;

                    debug('in loop fetched l_temp => '|| l_temp);
                    rt_counter := rt_counter + l_temp;
                    x_counter_value := rt_counter;
                    debug('rt_counter in loop => '||rt_counter);
                END LOOP;

                IF  l_in_loop = 0 THEN
                  FND_MESSAGE.SET_NAME('INV','INV_NO_CLIENT_ITM_OU');
                  x_return_status := fnd_api.g_ret_sts_error;
                  x_counter_value := 0;
                  RAISE fnd_api.g_exc_unexpected_error;

                END IF;

                debug('Effective Counter reading => '||rt_counter);

        EXCEPTION
                WHEN OTHERS THEN
                debug('Exception raised in seeded source '||sqlerrm);
                x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
                x_counter_value := 0;

        END number_receive_transactions;


        PROCEDURE number_shipment_lines
        (
          x_counter_value             OUT NOCOPY NUMBER,
          x_return_status             OUT NOCOPY VARCHAR2
        )
        as
        CURSOR items_record(p_client_code VARCHAR2) IS
        SELECT * FROM mtl_system_items_b msib
        WHERE  wms_deploy.get_client_code(msib.inventory_item_id) = p_client_code
        and nvl(msib.USAGE_ITEM_FLAG, 'N')  = 'N'
        AND nvl(msib.SERVICE_ITEM_FLAG, 'N') = 'N'
        AND nvl(msib.VENDOR_WARRANTY_FLAG, 'N') = 'N';

        mmt_counter NUMBER := 0;
        l_operating_unit NUMBER;
        l_client_code varchar2(10);
        l_temp NUMBER :=0;
        l_source_to_date date;
        l_last_computation_date date;
        l_service_line_start_date date;
        l_in_loop NUMBER := 0;

        BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_client_code := INV_3PL_BILLING_PUB.g_billing_source_rec.client_code; --'Business1';
        l_operating_unit := INV_3PL_BILLING_PUB.g_billing_source_rec.operating_unit; --'Business1';
        l_source_to_date := INV_3PL_BILLING_PUB.g_billing_source_rec.source_to_date;
        l_last_computation_date := INV_3PL_BILLING_PUB.g_billing_source_rec.last_computation_Date; --to_date('23-NOV-2009', 'DD-MON-YYYY'); --
        l_service_line_start_date := INV_3PL_BILLING_PUB.g_billing_source_rec.service_line_start_date;

        if l_last_computation_date is null then -- For 1st run of fresh LSP install
            l_last_computation_Date := l_service_line_start_date;
        end if;

            debug('Entered INV_3PL_SEEDED_SOURCES.number_shipment_lines ');
            debug('Got the values client_code => '|| l_client_code);
            debug('Got the values l_source_to_date => '|| l_source_to_date);
            debug('Got the values l_last_computation_date => '|| l_last_computation_date);
            debug('For client => '||l_client_code);


            FOR recs IN items_record(l_client_code)
                LOOP
                l_in_loop := 1;
                  debug('For client code =>  '||l_client_code);
                  debug('recs.item name => '||recs.segment1 ||'.'||recs.segment20);
                  debug('recs.item id =====================================> '||recs.inventory_item_id);
                  debug('recs.l_source_to_date => '|| To_Char(l_source_to_date, 'DD-MON-YYYY HH24:MI:SS'));
                  debug('recs.l_last_computation_date => '||  To_Char(l_last_computation_date, 'DD-MON-YYYY HH24:MI:SS'));

                    Select count(*) INTO l_temp
                    from mtl_material_transactions mmt
                    where transaction_source_type_id = 2
                    AND transaction_type_id = 33
                    AND transaction_action_id= 1
                    AND inventory_item_id = recs.inventory_item_id
                    AND creation_date <= l_source_to_date
                    AND creation_date > l_last_computation_date
                    AND organization_id = recs.organization_id;

                    -- debug('in loop fetched l_temp => '|| l_temp);
                    mmt_counter := mmt_counter + l_temp;
                    x_counter_value := mmt_counter;
                    -- debug('rt_counter in loop => '||mmt_counter);
                END LOOP;

                IF  l_in_loop = 0 THEN
                  FND_MESSAGE.SET_NAME('INV','INV_NO_CLIENT_ITM_OU');
                  x_return_status := fnd_api.g_ret_sts_error;
                  RAISE fnd_api.g_exc_unexpected_error;
                  x_counter_value := 0;
                END IF;

        debug('Effective Counter reading => '||mmt_counter);

        EXCEPTION
                WHEN OTHERS THEN
                debug('Exception raised in seeded source '||sqlerrm);
                x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
                x_counter_value := 0;
        END number_shipment_lines;



        PROCEDURE number_picking_transactions
        (
          x_counter_value             OUT NOCOPY NUMBER,
          x_return_status             OUT NOCOPY VARCHAR2
        )
        as

        CURSOR items_record(p_client_code VARCHAR2) IS
        SELECT * FROM mtl_system_items_b msib
        WHERE  wms_deploy.get_client_code(msib.inventory_item_id) = p_client_code
        and nvl(msib.USAGE_ITEM_FLAG, 'N')  = 'N'
        AND nvl(msib.SERVICE_ITEM_FLAG, 'N') = 'N'
        AND nvl(msib.VENDOR_WARRANTY_FLAG, 'N') = 'N';

        mmt_counter NUMBER := 0;
        l_operating_unit NUMBER;
        l_client_code varchar2(10);
        l_temp NUMBER :=0;
        l_source_to_date date;
        l_last_computation_date date;
        l_service_line_start_date date;
        l_in_loop NUMBER := 0;

        BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_client_code := INV_3PL_BILLING_PUB.g_billing_source_rec.client_code; --'Business1';
        l_operating_unit := INV_3PL_BILLING_PUB.g_billing_source_rec.operating_unit; --'Business1';
        l_source_to_date := INV_3PL_BILLING_PUB.g_billing_source_rec.source_to_date;
        l_last_computation_date := INV_3PL_BILLING_PUB.g_billing_source_rec.last_computation_Date; --to_date('23-NOV-2009', 'DD-MON-YYYY'); --
        l_service_line_start_date := INV_3PL_BILLING_PUB.g_billing_source_rec.service_line_start_date;

        if l_last_computation_date is null then -- For 1st run of fresh LSP install
            l_last_computation_Date := l_service_line_start_date;
        end if;

        debug('Entered INV_3PL_SEEDED_SOURCES.number_picking_transactions1 ');
        debug('Got the values client_code => '|| l_client_code);
        debug('Got the values l_source_to_date => '|| l_source_to_date);
        debug('Got the values l_last_computation_date => '|| l_last_computation_date);
        debug('For client => '||l_client_code);

            FOR recs IN items_record(l_client_code)
                LOOP
                l_in_loop := 1;
                  debug('For client code =>  '||l_client_code);
                  debug('recs.item name => '||recs.segment1 ||'.'||recs.segment20);
                  debug('recs.item id =====================================> '||recs.inventory_item_id);
                  debug('recs.l_source_to_date => '|| To_Char(l_source_to_date, 'DD-MON-YYYY HH24:MI:SS'));
                  debug('recs.l_last_computation_date => '||  To_Char(l_last_computation_date, 'DD-MON-YYYY HH24:MI:SS'));

              Select count(*) INTO l_temp
                from mtl_material_transactions mmt
                where transaction_source_type_id = 2
                AND transaction_type_id = 52
                AND transaction_action_id = 28
                and inventory_item_id = recs.inventory_item_id
                AND transaction_quantity > 0
                AND creation_date <= l_source_to_date
                AND creation_date > l_last_computation_date
                AND organization_id = recs.organization_id;

                    -- debug('in loop fetched l_temp => '|| l_temp);
                    mmt_counter := mmt_counter + l_temp;
                    x_counter_value := mmt_counter;
                    -- debug('rt_counter in loop => '||mmt_counter);
                END LOOP;

                IF  l_in_loop = 0 THEN
                  FND_MESSAGE.SET_NAME('INV','INV_NO_CLIENT_ITM_OU');
                  x_return_status := fnd_api.g_ret_sts_error;
                  RAISE fnd_api.g_exc_unexpected_error;
                  x_counter_value := 0;

                END IF;

        debug('Effective Counter reading => '||mmt_counter);

        EXCEPTION
                WHEN OTHERS THEN
                debug('Exception raised in seeded source '||sqlerrm);
                x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
                x_counter_value := 0;
        END number_picking_transactions;

    -- Bug 9475436 --
    -- Changed qty_receiving_transactions TO incorporate an error message
    -- WHEN the UOM conversion IS NOT defined between the two UOMS


        PROCEDURE qty_receiving_transactions
        (
          x_counter_value             OUT NOCOPY NUMBER,
          x_return_status             OUT NOCOPY VARCHAR2
        )

        as

        CURSOR items_record(p_client_code VARCHAR2) IS
        SELECT *
        FROM mtl_system_items_b msib
        WHERE  wms_deploy.get_client_code(msib.inventory_item_id) = p_client_code
        AND nvl(msib.USAGE_ITEM_FLAG, 'N')  = 'N'
        AND nvl(msib.SERVICE_ITEM_FLAG, 'N') = 'N'
        AND nvl(msib.VENDOR_WARRANTY_FLAG, 'N') = 'N';

     -- Bug 9475436 --

        Cursor rt_record(p_inventory_item_id NUMBER , p_source_to_date DATE,p_last_computation_Date DATE, p_organization_id NUMBER) IS
        Select rt.quantity quantity, NVL(rt.uom_code, get_item_uom_code(rt.unit_of_measure)) from_uom_code , rsl.item_id
        from rcv_transactions rt, rcv_shipment_lines rsl
        WHERE rsl.shipment_line_id = rt.shipment_line_id
        and rt.shipment_header_id = rt.shipment_header_id
        AND rsl.item_id = p_inventory_item_id
        AND rt.creation_date <= p_source_to_date
        AND rt.creation_date > p_last_computation_Date
        AND rt.transaction_type = 'RECEIVE'
        AND rt.organization_id = p_organization_id;

        rt_counter NUMBER :=0;
        l_quantity NUMBER :=0;
        l_operating_unit NUMBER;
        l_client_code varchar2(10);
        l_temp NUMBER :=0;
        l_source_to_date date;
        l_last_computation_date date;
        l_service_line_start_date date;
        l_last_invoice_date DATE;
        l_billing_uom VARCHAR2(5);
        l_in_loop NUMBER :=0;
    -- Bug 9475436 --
        l_temp_quantity NUMBER :=0;
        l_conversion NUMBER;
    -- Bug 9475436 --

        BEGIN

        debug('Starting of INV 3PL qty received ');

        x_return_status := fnd_api.g_ret_sts_success;
        l_client_code := INV_3PL_BILLING_PUB.g_billing_source_rec.client_code;
        l_source_to_date := INV_3PL_BILLING_PUB.g_billing_source_rec.source_to_date;
        l_last_computation_date := INV_3PL_BILLING_PUB.g_billing_source_rec.last_computation_Date;
        l_last_invoice_date := INV_3PL_BILLING_PUB.g_billing_source_rec.last_invoice_date;
        l_operating_unit := INV_3PL_BILLING_PUB.g_billing_source_rec.operating_unit;
        l_billing_uom := INV_3PL_BILLING_PUB.g_billing_source_rec.billing_uom;
        l_service_line_start_date := INV_3PL_BILLING_PUB.g_billing_source_rec.service_line_start_date;


        if l_last_computation_date is null then -- For 1st run of fresh LSP install
            l_last_computation_Date := l_service_line_start_date;
        end if;

         debug('Entered INV_3PL_SEEDED_SOURCES.qty_receiving_transactions ');
        debug('Got the values client_code => '|| l_client_code);
        debug('Got the values l_source_to_date => '|| l_source_to_date);
        debug('Got the values l_last_computation_date => '|| l_last_computation_date);
        debug(' l_billing_uom  => '|| l_billing_uom);
        debug('For client => '||l_client_code);

        FOR recs IN items_record(l_client_code)
            LOOP

                l_quantity := 0;
                l_in_loop := 1;
                debug('For client code =>  '||l_client_code);
                debug('Organization_id =>  '|| recs.organization_id);
                debug('recs.item name => '||recs.segment1 ||'.'||recs.segment20);
                debug('recs.item id =====================================> '||recs.inventory_item_id);
                debug('recs.l_source_to_date => '|| To_Char(l_source_to_date, 'DD-MON-YYYY HH24:MI:SS'));
                debug('recs.l_last_computation_date => '||  To_Char(l_last_computation_date, 'DD-MON-YYYY HH24:MI:SS'));
                debug('recs.l_last_invoice_date  => '||  To_Char(l_last_invoice_date, 'DD-MON-YYYY HH24:MI:SS'));

                BEGIN

    -- Bug 9475436 --
                   FOR items IN rt_record ( recs.inventory_item_id , l_source_to_date , l_last_computation_Date , recs.organization_id)
                    LOOP

                      SELECT inv_convert.inv_um_convert(items.item_id,items.from_uom_code,l_billing_uom)
                      INTO l_conversion
                      FROM dual;

                      debug('Conversion rate between the UOMs '|| l_conversion);
                      IF(l_conversion <= -999)
                       THEN
                        fnd_message.set_name('INV', 'INV_INVALID_UOM_CONV');
                        fnd_message.set_token('VALUE1', items.from_uom_code);
                        fnd_message.set_token('VALUE2', l_billing_uom);
                        debug('No conversion rate defined between the two UOM'|| l_conversion);
                        x_return_status := fnd_api.g_ret_sts_error;
                        x_counter_value := 0;
                        RAISE fnd_api.G_EXC_ERROR;
                       END IF;
                       l_temp_quantity := items.quantity * l_conversion;
                       l_quantity := l_quantity + l_temp_quantity;
                     END LOOP;

                END;
                debug('in loop fetched l_quantity => '|| nvl(l_quantity, 0));
                rt_counter := nvl(rt_counter, 0) + nvl(l_quantity, 0);
                debug('cummulative rt_counter in loop => '|| rt_counter);
            END LOOP;

        x_counter_value := rt_counter;
        debug('final x_counter_value => '|| rt_counter);

        IF  l_in_loop = 0 THEN
          FND_MESSAGE.SET_NAME('INV','INV_NO_CLIENT_ITM_OU');
          x_return_status := fnd_api.g_ret_sts_error;
          RAISE fnd_api.g_exc_unexpected_error;
          x_counter_value := 0;

        END IF;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    x_return_status := fnd_api.g_ret_sts_success;
                    x_counter_value := 0;
                WHEN OTHERS THEN
                    debug('Exception raised in seeded source '||sqlerrm);
                    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
                    x_counter_value := 0;
        END qty_receiving_transactions;

      PROCEDURE number_putaway_transactions
        (
          x_counter_value             OUT NOCOPY NUMBER,
          x_return_status             OUT NOCOPY VARCHAR2
        )
        as

        CURSOR items_record(p_client_code VARCHAR2) IS
        SELECT * FROM mtl_system_items_b msib
        WHERE  wms_deploy.get_client_code(msib.inventory_item_id) = p_client_code
        and nvl(msib.USAGE_ITEM_FLAG, 'N')  = 'N'
        AND nvl(msib.SERVICE_ITEM_FLAG, 'N') = 'N'
        AND nvl(msib.VENDOR_WARRANTY_FLAG, 'N') = 'N';


        rt_counter NUMBER := 0;
        l_operating_unit NUMBER;
        l_client_code varchar2(10);
        l_temp NUMBER :=0;
        l_source_to_date date;
        l_last_computation_date date;
        l_service_line_start_date date;
        l_in_loop NUMBER := 0;

        BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_client_code := INV_3PL_BILLING_PUB.g_billing_source_rec.client_code; --'Business1';
        l_operating_unit := INV_3PL_BILLING_PUB.g_billing_source_rec.operating_unit; --'Business1';
        l_source_to_date := INV_3PL_BILLING_PUB.g_billing_source_rec.source_to_date;
        l_last_computation_date := INV_3PL_BILLING_PUB.g_billing_source_rec.last_computation_Date; --to_date('23-NOV-2009', 'DD-MON-YYYY'); --
        l_service_line_start_date := INV_3PL_BILLING_PUB.g_billing_source_rec.service_line_start_date;

        if l_last_computation_date is null then -- For 1st run of fresh LSP install
            l_last_computation_Date := l_service_line_start_date;
        end if;

        debug('Entered INV_3PL_SEEDED_SOURCES.number_putaway_transactions ');
        debug('Got the values client_code => '|| l_client_code);
        debug('Got the values l_source_to_date => '|| l_source_to_date);
        debug('Got the values l_last_computation_date => '|| l_last_computation_date);

        FOR recs IN items_record(l_client_code)
            LOOP
                l_in_loop := 1;
                debug('For client code =>  '||l_client_code);
                debug('recs.item name => '||recs.segment1 ||'.'||recs.segment20);
                debug('recs.item id =====================================> '||recs.inventory_item_id);
                debug('recs.l_source_to_date => '|| To_Char(l_source_to_date, 'DD-MON-YYYY HH24:MI:SS'));
                debug('recs.l_last_computation_date => '||  To_Char(l_last_computation_date, 'DD-MON-YYYY HH24:MI:SS'));

                Select count(*) INTO l_temp
                from rcv_transactions rt, rcv_shipment_lines rsl
                WHERE rsl.shipment_line_id = rt.shipment_line_id
                and rt.shipment_header_id = rt.shipment_header_id
                AND rsl.item_id = recs.inventory_item_id
                AND rt.creation_date <= l_source_to_date
                AND rt.creation_date > l_last_computation_Date
                AND rt.transaction_type = 'DELIVER'
                AND rt.organization_id = recs.organization_id;


                debug('in loop fetched l_temp => '|| l_temp);
                rt_counter := rt_counter + l_temp;
                x_counter_value := rt_counter;
                debug('rt_counter in loop => '|| rt_counter);
            END LOOP;


                IF  l_in_loop = 0 THEN
                  FND_MESSAGE.SET_NAME('INV','INV_NO_CLIENT_ITM_OU');
                  x_return_status := fnd_api.g_ret_sts_error;
                  RAISE fnd_api.g_exc_unexpected_error;
                  x_counter_value := 0;

                END IF;


        debug('Effective Counter reading => '||rt_counter);

        EXCEPTION
                WHEN OTHERS THEN
                  debug('Exception raised in seeded source '||sqlerrm);
                x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
                x_counter_value := 0;

      END number_putaway_transactions;


    PROCEDURE capacity_number_of_days
        (
          x_counter_value             OUT NOCOPY NUMBER,
          x_return_status             OUT NOCOPY VARCHAR2
        ) as

    cursor cur_days_locator_occupied(p_client_code VARCHAR2, p_operating_unit_id NUMBER, p_source_to_date DATE)
    is
        SELECT Trunc(greatest(last_receipt_date, Nvl(last_invoiced_date, last_receipt_date))) greater_date
        , locator_id, client_code, organization_id, Trunc(transaction_date) txn_date, transaction_action_id ,
        transaction_quantity , current_onhand, Trunc(last_receipt_date) last_rcpt_date,
        number_of_days, Trunc(last_invoiced_date) last_inv_date
        from mtl_3pl_locator_occupancy inv
        WHERE  client_code = p_client_code
        and organization_id in (select organization_id from org_organization_definitions
        where operating_unit = p_operating_unit_id)
        and  (( nvl(last_invoiced_date, p_source_to_date) <= p_source_to_date )
              AND ( transaction_date <= p_source_to_date ) )
        order by organization_id, locator_id;

        l_cumm_reading_old NUMBER := 0;
        l_cumm_reading_new NUMBER := 0;
        l_count NUMBER :=0;
        l_operating_unit NUMBER;
        l_client_code varchar2(10);
        l_source_to_date date;
        l_invoice_date  date;
        l_last_computation_date date;
        l_last_invoice_date DATE;
        l_new_number_of_days NUMBER :=0;
        l_lock_record VARCHAR2(1);
        l_progid NUMBER;
        l_reqstid NUMBER;
        l_applid NUMBER;

    BEGIN

        x_return_status := fnd_api.g_ret_sts_success;
        l_client_code := INV_3PL_BILLING_PUB.g_billing_source_rec.client_code; --'Business1';
        l_invoice_date := INV_3PL_BILLING_PUB.g_billing_source_rec.source_to_date;
        l_source_to_date := INV_3PL_BILLING_PUB.g_billing_source_rec.source_to_date;
        l_last_computation_date := INV_3PL_BILLING_PUB.g_billing_source_rec.last_computation_Date;
        l_operating_unit := INV_3PL_BILLING_PUB.g_billing_source_rec.operating_unit;

        debug('Entered INV_3PL_SEEDED_SOURCES.capacity_number_of_days ');
        debug('Got the values client_code => '|| l_client_code);
        debug('Got the values l_source_to_date => '|| l_source_to_date);
        debug('Got the values l_last_computation_date => '|| l_last_computation_date);

        savepoint process_locator;
        FOR locator_occupancy_rec in cur_days_locator_occupied (l_client_code, l_operating_unit, l_invoice_date)

        LOOP
            debug(' ----------------------------------------------------------------------');
            debug(' Processing for Client_code, Locator_id -> '||locator_occupancy_rec.client_code ||' , '||locator_occupancy_rec.locator_id );
            debug(' ----------------------------------------------------------------------');

            l_cumm_reading_old := nvl(l_cumm_reading_new, 0);

            IF NOT (locator_occupancy_rec.current_onhand = 0 AND locator_occupancy_rec.number_of_days = 0) THEN

                debug(' : current_onhand, number_of_days -> '|| locator_occupancy_rec.current_onhand ||' , '|| locator_occupancy_rec.number_of_days );

                IF (locator_occupancy_rec.current_onhand = 0 ) THEN
                        debug(' : cumm reading from prev. locator => ' ||l_cumm_reading_old);
                        l_cumm_reading_new := l_cumm_reading_old + locator_occupancy_rec.number_of_days;
                      -- reset number_of_days counter to 0
                        l_new_number_of_days := 0;
                        debug(' : l_new_number_of_days -> '|| l_new_number_of_days);

                ELSIF locator_occupancy_rec.current_onhand > 0 THEN

                    debug(' : src to date, greater_date  -> '|| l_source_to_date ||', '|| locator_occupancy_rec.greater_date );
                    debug(' : cumm reading from prev. locator => ' ||l_cumm_reading_old);

                    l_cumm_reading_new := nvl(l_cumm_reading_old, 0) + locator_occupancy_rec.number_of_days +
                                      abs(trunc(l_source_to_date) - locator_occupancy_rec.greater_date);
                      debug(' : Cummulative Number of days -> '||l_cumm_reading_new );
                    -- reset number_of_days counter to 0
                      l_new_number_of_days := 0;
                      debug(' : l_new_number_of_days -> '|| l_new_number_of_days);

                END IF; /* (locator_occupancy_rec.current_onhand = 0 ) */


                    l_progid := FND_PROFILE.value('CONC_PROGRAM_ID');
                    l_reqstid := FND_PROFILE.value('CONC_REQUEST_ID');
                    l_applid := FND_PROFILE.value('PROG_APPL_ID');

                BEGIN
                    SELECT 'Y'
                    INTO l_lock_record
                    FROM mtl_3pl_locator_occupancy
                    WHERE locator_id = locator_occupancy_rec.locator_id
                    AND organization_id = locator_occupancy_rec.organization_id
                    AND client_code = locator_occupancy_rec.client_code
                    FOR UPDATE NOWAIT;

                    UPDATE mtl_3pl_locator_occupancy
                    SET number_of_days = l_new_number_of_days,
                        last_invoiced_date = l_invoice_date,
                        request_id= l_reqstid,
                        program_application_id = l_reqstid,
                        program_id = l_progid,
                        program_update_date  = SYSDATE
                    WHERE locator_id = locator_occupancy_rec.locator_id
                    AND organization_id = locator_occupancy_rec.organization_id
                    AND client_code = locator_occupancy_rec.client_code;


                    debug(' : Reset Number of days counter, rows updated -> '||sql%rowcount);

                    EXCEPTION
                        WHEN OTHERS THEN
                            debug(' : Error While resetting Number of days in mtl_3pl_locator_occupancy ' ||sqlerrm);
                            IF SQLCODE = -54 THEN
                                debug(' : Could not lock the record in mtl_3pl_locator_occupancy ');
                                FND_MESSAGE.SET_NAME('INV','INV_TRX_ROW_LOCKED');
                                x_return_status := fnd_api.g_ret_sts_error;
                                x_counter_value := 0;
                            ELSE
                                x_return_status  := fnd_api.g_ret_sts_unexp_error;
                                x_counter_value := 0;
                                -- raise fnd_api.g_exc_unexpected_error;
                            END IF;
                            rollback to process_locator;

                            debug(' : Could not get locator occupancy details for following combination ');
                            debug(' ----------------------------------------------------------------------');
                            debug(' : Client_code => '||locator_occupancy_rec.client_code );
                            debug(' : Locator_id => '||locator_occupancy_rec.locator_id );
                            RETURN;
                END;
                    debug(' : Reading returned from seeded source => '||l_cumm_reading_new);
                    x_counter_value := nvl(l_cumm_reading_new, 0);

            END IF; /* NOT (locator_occupancy_rec.current_onhand = 0 AND locator_occupancy_rec.number_of_days = 0)  */

        END LOOP; /* cur_days_locator_occupied */

    END capacity_number_of_days;


    PROCEDURE volume_utilized
        (
          x_counter_value             OUT NOCOPY NUMBER,
          x_return_status             OUT NOCOPY VARCHAR2
        ) as

    cursor cur_days_locator_occupied(p_client_code VARCHAR2, p_operating_unit_id NUMBER, p_source_to_date DATE)
    is
        SELECT Trunc(greatest(last_receipt_date, Nvl(last_invoiced_date, last_receipt_date))) greater_date
        , locator_id, client_code, organization_id, Trunc(transaction_date) txn_date, transaction_action_id ,
        transaction_quantity , current_onhand, Trunc(last_receipt_date) last_rcpt_date,
        number_of_days, Trunc(last_invoiced_date) last_inv_date
        from mtl_3pl_locator_occupancy inv
        WHERE  client_code = p_client_code
        and organization_id in (select organization_id from org_organization_definitions
        where operating_unit = p_operating_unit_id)
        and  (( nvl(last_invoiced_date, p_source_to_date) <= p_source_to_date )
              AND ( transaction_date <= p_source_to_date ) )
        order by organization_id, locator_id;

        l_cumm_reading_old NUMBER := 0;
        l_cumm_reading_new NUMBER := 0;
        l_count NUMBER :=0;
        l_operating_unit NUMBER;
        l_client_code varchar2(10);
        l_source_to_date date;
        l_invoice_date  date;
        l_last_computation_date date;
        l_last_invoice_date DATE;
        l_new_number_of_days NUMBER :=0;
        l_lock_record VARCHAR2(1);
        l_total_loc_volume NUMBER;
        l_volume_reading_old NUMBER;
        l_volume_reading_new NUMBER;
        l_volume_locator NUMBER;
        l_billing_uom VARCHAR2(10);
        l_multiply NUMBER :=0;
        l_progid NUMBER;
        l_reqstid NUMBER;
        l_applid NUMBER;

    BEGIN

        debug('Entered INV_3PL_SEEDED_SOURCES.volume_utilized initial');

        x_return_status := fnd_api.g_ret_sts_success;
        l_client_code := INV_3PL_BILLING_PUB.g_billing_source_rec.client_code; --'Business1';
        l_invoice_date := INV_3PL_BILLING_PUB.g_billing_source_rec.source_to_date;
        l_source_to_date := INV_3PL_BILLING_PUB.g_billing_source_rec.source_to_date;
        l_last_computation_date := INV_3PL_BILLING_PUB.g_billing_source_rec.last_computation_Date;
        l_operating_unit := INV_3PL_BILLING_PUB.g_billing_source_rec.operating_unit;
        l_billing_uom := INV_3PL_BILLING_PUB.g_billing_source_rec.billing_uom;

        debug('Entered INV_3PL_SEEDED_SOURCES.volume_utilized ');
        debug('Got the values client_code => '|| l_client_code);
        debug('Got the values l_source_to_date => '|| l_source_to_date);
        debug('Got the values l_last_computation_date => '|| l_last_computation_date);

        savepoint process_locator;
        FOR locator_occupancy_rec in cur_days_locator_occupied (l_client_code, l_operating_unit, l_invoice_date)

        LOOP
            debug(' ----------------------------------------------------------------------');
            debug(' Processing for Client_code, Locator_id -> '||locator_occupancy_rec.client_code ||' , '||locator_occupancy_rec.locator_id );
            debug(' ----------------------------------------------------------------------');

            l_volume_reading_old := nvl(l_volume_reading_new, 0);
            l_volume_locator := get_volume_for_locator(locator_occupancy_rec.locator_id,locator_occupancy_rec.organization_id,l_billing_uom);

            debug('locator Volume ' || l_volume_locator);
            IF ( l_volume_locator = -9999)
            THEN
                  debug('  Could not get locator occupancy details as the UOM conversion is not defined');
                  debug(' ----------------------------------------------------------------------');
                  debug('  Client_code => '||locator_occupancy_rec.client_code );
                  debug('  Locator_id => '||locator_occupancy_rec.locator_id );
                  rollback to process_locator;
                  RAISE fnd_api.G_EXC_ERROR;
                  x_counter_value := 0;
                  x_return_status := fnd_api.g_ret_sts_error;
                  RETURN;
            END IF;

            IF ( l_volume_locator = -1234)
            THEN
                  debug('  Could not get locator occupancy details as the volume is zero for the locator');
                  debug(' ----------------------------------------------------------------------');
                  debug('  Client_code => '||locator_occupancy_rec.client_code );
                  debug('  Locator_id => '||locator_occupancy_rec.locator_id );
                  rollback to process_locator;

                  FND_MESSAGE.SET_NAME('INV','INV_LOC_VOL_NOT_DEF');
                  RAISE fnd_api.G_EXC_ERROR;
                  x_return_status := fnd_api.g_ret_sts_error;
                  x_counter_value := 0;
                  RETURN;
            END IF;

            IF NOT (locator_occupancy_rec.current_onhand = 0 AND locator_occupancy_rec.number_of_days = 0) THEN
                debug(' current_onhand, number_of_days -> '|| locator_occupancy_rec.current_onhand ||' , '|| locator_occupancy_rec.number_of_days );

                IF (locator_occupancy_rec.current_onhand = 0 ) THEN

                        debug(' : cumm reading from prev. locator => ' ||l_cumm_reading_old);

                      l_total_loc_volume := l_volume_locator * (locator_occupancy_rec.number_of_days );
                      l_volume_reading_new := l_volume_reading_old + l_total_loc_volume;
                      -- reset number_of_days counter to 0
                      l_new_number_of_days := 0;
                        debug(' : l_new_number_of_days -> '|| l_new_number_of_days);

                ELSIF locator_occupancy_rec.current_onhand > 0 THEN

                    debug(' : src to date, greater_date  -> '|| l_source_to_date ||', '|| locator_occupancy_rec.greater_date );
                    debug(' : cumm reading from prev. locator => ' ||l_cumm_reading_old);

                      l_multiply := locator_occupancy_rec.number_of_days +
                                      abs(trunc(l_source_to_date) - locator_occupancy_rec.greater_date);

                     debug('Number of Days for which the locator was occupied -> '||l_multiply );

                      l_total_loc_volume := l_volume_locator * l_multiply;
                      l_volume_reading_new := l_volume_reading_old + l_total_loc_volume;

                      debug(' Total Volume Occupied  '|| l_total_loc_volume);
                      debug('Cumulative Volume Reading -> '||l_volume_reading_new );
                    -- reset number_of_days counter to 1
                      l_new_number_of_days := 0;
                      debug('l_new_number_of_days -> '|| l_new_number_of_days);

                END IF;
                 /* (locator_occupancy_rec.current_onhand = 0 ) */


                    l_progid := FND_PROFILE.value('CONC_PROGRAM_ID');
                    l_reqstid := FND_PROFILE.value('CONC_REQUEST_ID');
                    l_applid := FND_PROFILE.value('PROG_APPL_ID');

                BEGIN
                    SELECT 'Y'
                    INTO l_lock_record
                    FROM mtl_3pl_locator_occupancy
                    WHERE locator_id = locator_occupancy_rec.locator_id
                    AND organization_id = locator_occupancy_rec.organization_id
                    AND client_code = locator_occupancy_rec.client_code
                    FOR UPDATE NOWAIT;

                    UPDATE mtl_3pl_locator_occupancy
                    SET number_of_days = l_new_number_of_days,
                        last_invoiced_date = l_invoice_date,
                        request_id= l_reqstid,
                        program_application_id = l_reqstid,
                        program_id = l_progid,
                        program_update_date  = SYSDATE
                    WHERE locator_id = locator_occupancy_rec.locator_id
                    AND organization_id = locator_occupancy_rec.organization_id
                    AND client_code = locator_occupancy_rec.client_code;


                    debug(' : Reset Number of days counter, rows updated -> '||sql%rowcount);

                    EXCEPTION
                        WHEN OTHERS THEN
                            debug(' : Error While resetting Number of days in mtl_3pl_locator_occupancy ' ||sqlerrm);
                            IF SQLCODE = -54 THEN
                                debug(' : Could not lock the record in mtl_3pl_locator_occupancy ');
                                FND_MESSAGE.SET_NAME('INV','INV_TRX_ROW_LOCKED');
                                x_return_status := fnd_api.g_ret_sts_error;
                                x_counter_value := 0;
                            ELSE
                                x_return_status  := fnd_api.g_ret_sts_unexp_error;
                                x_counter_value := 0;
                                -- raise fnd_api.g_exc_unexpected_error;
                            END IF;
                            rollback to process_locator;
                            debug(' : Could not get locator occupancy details for following combination ');
                            debug(' ----------------------------------------------------------------------');
                            debug(' : Client_code => '||locator_occupancy_rec.client_code );
                            debug(' : Locator_id => '||locator_occupancy_rec.locator_id );
                            RETURN;
                    END;

                debug('Cumulative Volume Reading -> '||l_volume_reading_new );
                debug('Reading returned from seeded source => '||l_volume_reading_new);
                x_counter_value := nvl(l_volume_reading_new, 0);
            END IF; /* NOT (locator_occupancy_rec.current_onhand = 0 AND locator_occupancy_rec.number_of_days = 0)  */

        END LOOP; /* cur_days_locator_occupied */
    END volume_utilized;


    PROCEDURE area_utilized
        (
          x_counter_value             OUT NOCOPY NUMBER,
          x_return_status             OUT NOCOPY VARCHAR2
        ) as

    cursor cur_days_locator_occupied(p_client_code VARCHAR2, p_operating_unit_id NUMBER, p_source_to_date DATE)
    is
        SELECT Trunc(greatest(last_receipt_date, Nvl(last_invoiced_date, last_receipt_date))) greater_date
        , locator_id, client_code, organization_id, Trunc(transaction_date) txn_date, transaction_action_id ,
        transaction_quantity , current_onhand, Trunc(last_receipt_date) last_rcpt_date,
        number_of_days, Trunc(last_invoiced_date) last_inv_date
        from mtl_3pl_locator_occupancy inv
        WHERE  client_code = p_client_code
        and organization_id in (select organization_id from org_organization_definitions
        where operating_unit = p_operating_unit_id)
        and  (( nvl(last_invoiced_date, p_source_to_date) <= p_source_to_date )
              AND ( transaction_date <= p_source_to_date ) )
        order by organization_id, locator_id;

        l_cumm_reading_old NUMBER := 0;
        l_cumm_reading_new NUMBER := 0;
        l_count NUMBER :=0;
        l_operating_unit NUMBER;
        l_client_code varchar2(10);
        l_source_to_date date;
        l_invoice_date  date;
        l_last_computation_date date;
        l_last_invoice_date DATE;
        l_new_number_of_days NUMBER :=0;
        l_lock_record VARCHAR2(1);
        l_total_loc_area NUMBER;
        l_area_reading_old NUMBER;
        l_area_reading_new NUMBER;
        l_area_locator NUMBER;
        l_billing_uom VARCHAR2(10);
        l_multiply NUMBER :=0;
        l_progid NUMBER;
        l_reqstid NUMBER;
        l_applid NUMBER;

    BEGIN

        debug('Entered INV_3PL_SEEDED_SOURCES.area_utlized initial');

        x_return_status := fnd_api.g_ret_sts_success;
        l_client_code := INV_3PL_BILLING_PUB.g_billing_source_rec.client_code; --'Business1';
        l_invoice_date := INV_3PL_BILLING_PUB.g_billing_source_rec.source_to_date;
        l_source_to_date := INV_3PL_BILLING_PUB.g_billing_source_rec.source_to_date;
        l_last_computation_date := INV_3PL_BILLING_PUB.g_billing_source_rec.last_computation_Date;
        l_operating_unit := INV_3PL_BILLING_PUB.g_billing_source_rec.operating_unit;
        l_billing_uom := INV_3PL_BILLING_PUB.g_billing_source_rec.billing_uom;

        debug('Entered INV_3PL_SEEDED_SOURCES.area_utilized ');
        debug('Got the values client_code => '|| l_client_code);
        debug('Got the values l_source_to_date => '|| l_source_to_date);
        debug('Got the values l_last_computation_date => '|| l_last_computation_date);

        savepoint process_locator;
        FOR locator_occupancy_rec in cur_days_locator_occupied (l_client_code, l_operating_unit, l_invoice_date)

        LOOP
            debug(' ----------------------------------------------------------------------');
            debug(' Processing for Client_code, Locator_id -> '||locator_occupancy_rec.client_code ||' , '||locator_occupancy_rec.locator_id );
            debug(' ----------------------------------------------------------------------');

            l_area_reading_old := nvl(l_area_reading_new, 0);
            l_area_locator := get_area_for_locator(locator_occupancy_rec.locator_id,locator_occupancy_rec.organization_id);

            IF ( l_area_locator = -1234)
            THEN
                  debug('  Could not get locator occupancy details as the area is zero for the locator');
                  debug(' ----------------------------------------------------------------------');
                  debug('  Client_code => '||locator_occupancy_rec.client_code );
                  debug('  Locator_id => '||locator_occupancy_rec.locator_id );
                  rollback to process_locator;

                  FND_MESSAGE.SET_NAME('INV','INV_LOC_AREA_NOT_DEF');
                  RAISE fnd_api.G_EXC_ERROR;
                  x_return_status := fnd_api.g_ret_sts_error;
                  x_counter_value := 0;
                  RETURN;
            END IF;


            IF NOT (locator_occupancy_rec.current_onhand = 0 AND locator_occupancy_rec.number_of_days = 0) THEN
                debug(' current_onhand, number_of_days -> '|| locator_occupancy_rec.current_onhand ||' , '|| locator_occupancy_rec.number_of_days );

                IF (locator_occupancy_rec.current_onhand = 0 ) THEN

                        debug(' : cumm reading from prev. locator => ' ||l_cumm_reading_old);

                      l_total_loc_area := l_area_locator * (locator_occupancy_rec.number_of_days );
                      l_area_reading_new := l_area_reading_old + l_total_loc_area;
                      -- reset number_of_days counter to 0
                      l_new_number_of_days := 0;
                        debug(' : l_new_number_of_days -> '|| l_new_number_of_days);

                ELSIF locator_occupancy_rec.current_onhand > 0 THEN

                    debug(' : src to date, greater_date  -> '|| l_source_to_date ||', '|| locator_occupancy_rec.greater_date );
                    debug(' : cumm reading from prev. locator => ' ||l_cumm_reading_old);

                      l_multiply := locator_occupancy_rec.number_of_days +
                                      abs(trunc(l_source_to_date) - locator_occupancy_rec.greater_date);

                     debug('Number of Days for which the locator was occupied -> '||l_multiply );

                      l_total_loc_area := l_area_locator * l_multiply;
                      l_area_reading_new := l_area_reading_old + l_total_loc_area;

                      debug(' Total Area Occupied  '|| l_total_loc_area);
                      debug('Cumulative Area Reading -> '||l_area_reading_new );
                    -- reset number_of_days counter to 0
                      l_new_number_of_days := 0;
                      debug('l_new_number_of_days -> '|| l_new_number_of_days);

                END IF;

                 /* (locator_occupancy_rec.current_onhand = 0 ) */

                    l_progid := FND_PROFILE.value('CONC_PROGRAM_ID');
                    l_reqstid := FND_PROFILE.value('CONC_REQUEST_ID');
                    l_applid := FND_PROFILE.value('PROG_APPL_ID');

                BEGIN
                    SELECT 'Y'
                    INTO l_lock_record
                    FROM mtl_3pl_locator_occupancy
                    WHERE locator_id = locator_occupancy_rec.locator_id
                    AND organization_id = locator_occupancy_rec.organization_id
                    AND client_code = locator_occupancy_rec.client_code
                    FOR UPDATE NOWAIT;

                    UPDATE mtl_3pl_locator_occupancy
                    SET number_of_days = l_new_number_of_days,
                        last_invoiced_date = l_invoice_date,
                        request_id= l_reqstid,
                        program_application_id = l_reqstid,
                        program_id = l_progid,
                        program_update_date  = SYSDATE
                    WHERE locator_id = locator_occupancy_rec.locator_id
                    AND organization_id = locator_occupancy_rec.organization_id
                    AND client_code = locator_occupancy_rec.client_code;


                    debug(' : Reset Number of days counter, rows updated -> '||sql%rowcount);

                    EXCEPTION
                        WHEN OTHERS THEN
                            debug(' : Error While resetting Number of days in mtl_3pl_locator_occupancy ' ||sqlerrm);
                            IF SQLCODE = -54 THEN
                                debug(' : Could not lock the record in mtl_3pl_locator_occupancy ');
                                FND_MESSAGE.SET_NAME('INV','INV_TRX_ROW_LOCKED');
                                x_return_status := fnd_api.g_ret_sts_error;
                                x_counter_value := 0;
                            ELSE
                                x_return_status  := fnd_api.g_ret_sts_unexp_error;
                                x_counter_value := 0;
                                -- raise fnd_api.g_exc_unexpected_error;
                            END IF;
                            rollback to process_locator;
                            debug(' : Could not get locator occupancy details for following combination ');
                            debug(' ----------------------------------------------------------------------');
                            debug(' : Client_code => '||locator_occupancy_rec.client_code );
                            debug(' : Locator_id => '||locator_occupancy_rec.locator_id );
                            RETURN;
                    END;

                debug('Cumulative Volume Reading -> '||l_area_reading_new );
                debug('Reading returned from seeded source => '||l_area_reading_new);
                x_counter_value := nvl(l_area_reading_new, 0);
            END IF; /* NOT (locator_occupancy_rec.current_onhand = 0 AND locator_occupancy_rec.number_of_days = 0)  */

        END LOOP; /* cur_days_locator_occupied */
    END area_utilized;


     FUNCTION get_volume_for_locator(p_inventory_location_id  NUMBER , p_organization_id NUMBER , p_billing_uom VARCHAR2)
     RETURN Number IS

        x_return_status              VARCHAR2(1); -- return status (success/error/unexpected_error)
        x_msg_count                  NUMBER; -- number of messages in the message queue
        x_msg_data                   VARCHAR2(100); -- message text when x_msg_count>0
        x_volume_uom_code            VARCHAR2(10);   -- the locator's unit of measure for volume
        x_max_cubic_area             NUMBER;   -- max volume the locator can take
        x_current_cubic_area         NUMBER;   -- current volume in the locator
        x_suggested_cubic_area       NUMBER;   -- suggested volume to be put into locator
        x_available_cubic_area       NUMBER;   -- volume the locator can still take
        l_quantity                   NUMBER;
        l_conversion                 NUMBER;

      BEGIN

        INV_LOC_WMS_UTILS.get_locator_volume_capacity
          ( x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_volume_uom_code  => x_volume_uom_code,
            x_max_cubic_area => x_max_cubic_area,
            x_current_cubic_area => x_current_cubic_area,
            x_suggested_cubic_area => x_suggested_cubic_area,
            x_available_cubic_area => x_available_cubic_area,
            p_organization_id => p_organization_id,
            p_inventory_location_id => p_inventory_location_id
            );

          debug('Max Volume of Locator '|| x_max_cubic_area);
          debug('Volume UOM Code : '|| x_volume_uom_code);
          debug('Billing UOM : '|| p_billing_uom);

          IF( Nvl(x_max_cubic_area,0) = 0)
           THEN
            RETURN(-1234);
          END IF;

          SELECT inv_convert.inv_um_convert(0,x_volume_uom_code,p_billing_uom)
          INTO l_conversion
          FROM dual;

          debug('Conversion rate between the UOMs '|| l_conversion);

          IF(l_conversion <= -999)
           THEN
            fnd_message.set_name('INV', 'INV_INVALID_UOM_CONV');
            fnd_message.set_token('VALUE1', x_volume_uom_code);
            fnd_message.set_token('VALUE2', p_billing_uom);
            RETURN(-9999);
          ELSE
            l_quantity := l_conversion * x_max_cubic_area;
          RETURN(l_quantity);
          END IF;

          EXCEPTION
              WHEN OTHERS THEN
               debug('Error in get_volume_for_locator function : '||sqlerrm);
               rollback to process_locator;


       END get_volume_for_locator;

     FUNCTION get_area_for_locator(p_inventory_location_id  NUMBER , p_organization_id NUMBER )
     RETURN Number IS

        x_max_area                    NUMBER;   -- max volume the locator can take
        x_width                        NUMBER;
        x_length                    NUMBER;

      BEGIN
        Select width , length
        into x_width , x_length
        from mtl_item_locations
        where inventory_location_id = p_inventory_location_id
        and organization_id = p_organization_id;

          x_max_area := Nvl(x_width,0) * Nvl ( x_length,0);

          debug('Max area of Locator '|| x_max_area);

          IF( Nvl(x_max_area,0) = 0)
           THEN
            RETURN(-1234);
          END IF;

          RETURN(x_max_area);

          EXCEPTION
              WHEN OTHERS THEN
               debug('Error in get_area_for_locator function : '||sqlerrm);
               rollback to process_locator;

       END get_area_for_locator;

    END INV_3PL_SEEDED_SOURCES;

/
