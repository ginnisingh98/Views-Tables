--------------------------------------------------------
--  DDL for Package Body RCV_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_AVAILABILITY" AS
/* $Header: RCVAVALB.pls 120.9.12010000.7 2011/08/01 09:44:41 yjian ship $*/
   TYPE wms_install_table_type IS TABLE OF BOOLEAN
      INDEX BY BINARY_INTEGER;

   g_wms_install_table wms_install_table_type;
   g_pkg_name CONSTANT VARCHAR2(30)           := 'rcv_availability';
   g_rti_normalized    VARCHAR2(1);

   /*
   normalize_interface_tables is a private helper function for
   get_available_supply_demand in 12.0, the normalization package was
   introduced to put all of the information in RTI into a consistent
   state to allow one-stop shopping for writting SQL queries. This
   process is normally started by the preprocessor. I want to take
   advantage of this convience, but since reservations can be run at
   any time I need to manually execute the package rather than let the
   preprocessor execute it.
   The process of normalizing the data can be expensive, so in order
   to reduce the performance hit I will process the rows in the
   interface table only once. This is useful considering that this
   call may be made many times during planned cross docking execution.
   */
   PROCEDURE normalize_interface_tables IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      CURSOR get_rhi_rows IS
         SELECT *
         FROM   rcv_headers_interface
         WHERE  processing_status_code = 'PENDING';

      CURSOR get_rti_rows IS
         SELECT *
         FROM   rcv_transactions_interface
         WHERE  processing_status_code = 'PENDING';
   BEGIN
      IF (g_rti_normalized IS NOT NULL) THEN --because this is expensive, we only want to run it once per session
         RETURN;
      END IF;

      g_rti_normalized  := 'Y';

      FOR rhi_row IN get_rhi_rows LOOP
         BEGIN
            rcv_default_pkg.default_header(rhi_row);
            rcv_table_functions.update_rhi_row(rhi_row);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

      FOR rti_row IN get_rti_rows LOOP
         IF (rti_row.validation_flag = 'Y') THEN
            BEGIN
               rcv_default_pkg.default_transaction(rti_row);
               rcv_table_functions.update_rti_row(rti_row);
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;
      END LOOP;

      COMMIT; --release locks
   END normalize_interface_tables;

   /*
   get_available_supply_demand returns the available quantity in terms
   of the ***PRIMARY_UNIT_OF_MEASURE*** <-VERY IMPORTANT.  All
   quantities inside this procedure are kept in terms of
   primary_unit_of_measure. This is necessary because different
   transaction rows in rt can be transacted in different units of
   measure. There are two important quantities being tracked in this
   procedure: x_rcv_quantity - this is the quantity that has already
   been received or will be received into receiving, and
   x_rcv_order_quantity - this is the quantity that was ordered on the
   backing document. The value returned in x_available_quantity =
   x_ordered_quantity - x_rcv_quantity
   */
   PROCEDURE get_available_supply_demand(
      x_return_status             OUT NOCOPY    VARCHAR2,
      x_msg_count                 OUT NOCOPY    NUMBER,
      x_msg_data                  OUT NOCOPY    VARCHAR2,
      x_available_quantity        OUT NOCOPY    NUMBER,
      x_source_uom_code           OUT NOCOPY    VARCHAR2,
      x_source_primary_uom_code   OUT NOCOPY    VARCHAR2,
      p_supply_demand_code        IN            NUMBER,
      p_organization_id           IN            NUMBER,
      p_item_id                   IN            NUMBER,
      p_revision                  IN            VARCHAR2,
      p_lot_number                IN            VARCHAR2,
      p_subinventory_code         IN            VARCHAR2,
      p_locator_id                IN            NUMBER,
      p_supply_demand_type_id     IN            NUMBER,
      p_supply_demand_header_id   IN            NUMBER,
      p_supply_demand_line_id     IN            NUMBER,
      p_supply_demand_line_detail IN            NUMBER,
      p_lpn_id                    IN            NUMBER,
      p_project_id                IN            NUMBER,
      p_task_id                   IN            NUMBER,
      p_api_version_number        IN            NUMBER,
      p_init_msg_lst              IN            VARCHAR2
   ) IS
      l_api_version_number CONSTANT NUMBER                 := 1.0;
      l_api_name           CONSTANT VARCHAR2(30)           := 'get_available_supply_demand';
      l_lpn_id                      NUMBER;--Bug 5329067
      x_rcv_quantity                NUMBER;
      x_rcv_order_quantity          NUMBER;


      -- <Bug 9342280 : Added for CLM project>
      l_is_clm_po              VARCHAR2(5) := 'N';
      l_distribution_type      VARCHAR2(100);
      l_matching_basis         VARCHAR2(100);
      l_accrue_on_receipt_flag VARCHAR2(100);
      l_code_combination_id    NUMBER;
      l_budget_account_id      NUMBER;
      l_partial_funded_flag    VARCHAR2(100) := 'N';
      l_unit_meas_lookup_code  VARCHAR2(100);
      l_funded_value           NUMBER;
      l_quantity_funded        NUMBER;
      l_amount_funded          NUMBER;
      l_quantity_received      NUMBER;
      l_amount_received        NUMBER;
      l_quantity_delivered     NUMBER;
      l_amount_delivered       NUMBER;
      l_quantity_billed        NUMBER;
      l_amount_billed          NUMBER;
      l_quantity_cancelled     NUMBER;
      l_amount_cancelled       NUMBER;
      l_return_status          VARCHAR2(100);
      -- <CLM END>

      CURSOR get_uom_code(
         p_unit_of_measure mtl_units_of_measure.unit_of_measure%TYPE
      ) IS
         SELECT uom_code
         FROM   mtl_units_of_measure
         WHERE  unit_of_measure = p_unit_of_measure;

      /*
      The following four cursors: get_req_order, get_oe_order,
      get_ship_order, and get_po_order are responsible for getting the
      original order quantity from the backing doc regardless of the
      status of the backing doc
      */
      CURSOR get_req_order IS
         SELECT rl.quantity,
                rl.item_id,
                rl.unit_meas_lookup_code unit_of_measure,
                si.primary_unit_of_measure
         FROM   po_requisition_lines_all rl,
                mtl_system_items si
         WHERE  rl.requisition_line_id = p_supply_demand_line_id
         AND    si.inventory_item_id(+) = rl.item_id;

      CURSOR get_oe_order IS
         SELECT oel.ordered_quantity quantity,
                oel.inventory_item_id item_id,
                uom.unit_of_measure,
                si.primary_unit_of_measure
         FROM   oe_order_lines_all oel,
                mtl_units_of_measure uom,
                mtl_system_items si
         WHERE  line_id = p_supply_demand_line_id
         AND    order_quantity_uom = uom_code
         AND    si.inventory_item_id(+) = oel.inventory_item_id;

      CURSOR get_ship_order(
         p_shipment_line_id IN rcv_shipment_lines.shipment_line_id%TYPE
      ) IS
         SELECT quantity_shipped quantity,
                item_id,
                unit_of_measure,
                primary_unit_of_measure
         FROM   rcv_shipment_lines
         WHERE  shipment_line_id = p_shipment_line_id;

	/* Bug. 4693257.
	 * We need to get the quantity from po_distributions
	 * since we need to match project and task ids.
	*/
--Bug10064616<START>
      CURSOR get_po_order(
	p_project_id IN po_distributions_all.project_id%type,
	p_task_id IN po_distributions_all.task_id%type) IS
SELECT SUM(pod.quantity_ordered) quantity,
       pol.item_id,
       pol.unit_meas_lookup_code unit_of_measure,
       null primary_unit_of_measure
FROM   po_line_locations_all pll,
       po_lines_all pol,
       po_distributions_all pod
WHERE  pll.line_location_id = p_supply_demand_line_id
       AND pll.po_line_id = pol.po_line_id
       AND pol.item_id IS NULL
       AND pod.line_location_id = pll.line_location_id
       AND ( p_project_id IS NULL
              OR pod.project_id = p_project_id )
       AND ( p_task_id IS NULL
              OR pod.task_id = p_task_id )
GROUP  BY pol.item_id,
          pol.unit_meas_lookup_code,
          NULL
UNION ALL
SELECT SUM(pod.quantity_ordered) quantity,
       pol.item_id,
       pol.unit_meas_lookup_code unit_of_measure,
       si.primary_unit_of_measure primary_unit_of_measure
FROM   po_line_locations_all pll,
       po_lines_all pol,
       po_distributions_all pod,
       mtl_system_items si
WHERE  pll.line_location_id = p_supply_demand_line_id
       AND pll.po_line_id = pol.po_line_id
       AND pol.item_id IS NOT NULL
       AND si.inventory_item_id = pol.item_id
       AND si.organization_id = pll.ship_to_organization_id
       AND pod.line_location_id = pll.line_location_id
       AND ( p_project_id IS NULL
              OR pod.project_id = p_project_id )
       AND (p_task_id IS NULL
              OR pod.task_id = p_task_id )
GROUP  BY pol.item_id,
          pol.unit_meas_lookup_code,
          si.primary_unit_of_measure ;
--Bug10064616<END>

      /*
      the following cursors: get_rcv_req_row, get_rcv_oe_row,
      get_rcv_ship_row, get_rcv_po_row are all the same query, but
      with different driving where clauses. The cursor used is
      determined by p_supply_demand_type_id. The cursors return all
      the rows in RCV_SHIPMENT_LINES and all the receipts/+correction
      to receipts/shipments in RCV_TRANSACTIONS_INTERFACE that apply
      to the backing doc

      The parameters p_organization_id, p_item_id, p_revision,
      p_lot_number, p_subinventory_code, p_locator_id, p_project_id,
      and p_task_id are NOT driving parameters. They are coded into
      the queries in a way that the CBO will not attempt to use them,
      instead it will always rely on the backing doc as the driving
      column. These parameters only restrict the scope of a query,
      they do not enlargen it.
      */
      CURSOR get_rcv_req_row IS
         SELECT DECODE(rti.transaction_type,
                       'SHIP', rti.quantity,
                       'RECEIVE', rti.quantity,
                       'CORRECT', DECODE(rt.transaction_type,
                                         'SHIP', rti.quantity,
                                         'RECEIVE', rti.quantity,
                                         0
                                        ),
                       0
                      ) quantity_shipped,
                DECODE(rti.transaction_type,
                       'DELIVER', rti.quantity,
                       'CORRECT', DECODE(rt.transaction_type,
                                         'DELIVER', rti.quantity,
                                         0
                                        ),
                       DECODE(rti.auto_transact_code,
                              'DELIVER', rti.quantity,
                              0
                             )
                      ) quantity_delivered,
                rti.item_id,
                rti.unit_of_measure,
                rti.primary_unit_of_measure,
                rti.to_organization_id
         FROM   rcv_transactions_interface rti,
                rcv_transactions rt
         WHERE  rti.parent_transaction_id = rt.transaction_id(+)
         AND    rti.quantity > 0
         AND    (   rti.transaction_type IN('RECEIVE', 'SHIP', 'DELIVER')
                 OR (    rti.transaction_type = 'CORRECT'
                     AND rt.transaction_type IN('RECEIVE', 'DELIVER')))
         AND    rti.processing_status_code IN('PENDING', 'RUNNING')
         AND    (   p_organization_id IS NULL
                 OR p_organization_id = rti.to_organization_id)
         AND    (   p_item_id IS NULL
                 OR p_item_id = rti.item_id)
         AND    (   p_revision IS NULL
                 OR p_revision = rti.item_revision)
         AND    (   p_subinventory_code IS NULL
                 OR p_subinventory_code = rti.subinventory)
         AND    (   p_locator_id IS NULL
                 OR p_locator_id = rti.locator_id)
         AND    (   l_lpn_id = fnd_api.g_miss_num --Bug 5329067
                 OR l_lpn_id = rti.lpn_id --Bug 5329067
                 OR (    l_lpn_id IS NULL--Bug 5329067
                     AND rti.lpn_id IS NULL))
         AND    (   p_project_id IS NULL
                 OR p_project_id = rti.project_id)
         AND    (   p_task_id IS NULL
                 OR p_task_id = rti.task_id)
         AND    rti.requisition_line_id = p_supply_demand_line_id
         UNION ALL
         SELECT rsl.quantity_received,
                 rsl.quantity_received - NVL(rs.quantity, 0) quantity_delivered,
                rsl.item_id,
                rsl.unit_of_measure,
                rsl.primary_unit_of_measure,
                rsl.to_organization_id
         FROM   rcv_shipment_lines rsl,
                rcv_supply rs
         WHERE  rsl.shipment_line_id = rs.shipment_line_id(+)
         AND    (   p_organization_id IS NULL
                 OR p_organization_id = rsl.to_organization_id)
         AND    (   p_item_id IS NULL
                 OR p_item_id = rsl.item_id)
         AND    (   p_revision IS NULL
                 OR p_revision = rsl.item_revision)
         AND    (   p_subinventory_code IS NULL
                 OR p_subinventory_code = rsl.to_subinventory)
         AND    (   p_locator_id IS NULL
                 OR p_locator_id = rsl.locator_id)
         AND    (   l_lpn_id = fnd_api.g_miss_num --Bug 5329067
                 OR NVL(l_lpn_id, fnd_api.g_miss_num) IN(SELECT NVL(rt.lpn_id, fnd_api.g_miss_num) --Bug 5329067
                                                         FROM   rcv_transactions rt
                                                         WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    (   p_project_id IS NULL
                 OR p_project_id IN(SELECT rt.project_id
                                    FROM   rcv_transactions rt
                                    WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    (   p_task_id IS NULL
                 OR p_task_id IN(SELECT rt.task_id
                                 FROM   rcv_transactions rt
                                 WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    rsl.requisition_line_id = p_supply_demand_line_id;

      CURSOR get_rcv_oe_row IS
         SELECT DECODE(rti.transaction_type,
                       --'SHIP', rti.quantity,--dont count
                       'RECEIVE', rti.quantity,
                       'CORRECT', DECODE(rt.transaction_type,
                                         --'SHIP', rti.quantity,--dont count
                                         'RECEIVE', rti.quantity,
                                         0
                                        ),
                       0
                      ) quantity_shipped,
                DECODE(rti.transaction_type,
                       'DELIVER', rti.quantity,
                       'CORRECT', DECODE(rt.transaction_type,
                                         'DELIVER', rti.quantity,
                                         0
                                        ),
                       DECODE(rti.auto_transact_code,
                              'DELIVER', rti.quantity,
                              0
                             )
                      ) quantity_delivered,
                rti.item_id,
                rti.unit_of_measure,
                rti.primary_unit_of_measure,
                rti.to_organization_id
         FROM   rcv_transactions_interface rti,
                rcv_transactions rt
         WHERE  rti.parent_transaction_id = rt.transaction_id(+)
         AND    rti.quantity > 0
         AND    (   rti.transaction_type IN('RECEIVE', 'SHIP', 'DELIVER')
                 OR (    rti.transaction_type = 'CORRECT'
                     AND rt.transaction_type IN('RECEIVE', 'DELIVER')))
         AND    rti.processing_status_code IN('PENDING', 'RUNNING')
         AND    (   p_organization_id IS NULL
                 OR p_organization_id = rti.to_organization_id)
         AND    (   p_item_id IS NULL
                 OR p_item_id = rti.item_id)
         AND    (   p_revision IS NULL
                 OR p_revision = rti.item_revision)
         AND    (   p_subinventory_code IS NULL
                 OR p_subinventory_code = rti.subinventory)
         AND    (   p_locator_id IS NULL
                 OR p_locator_id = rti.locator_id)
         AND    (   l_lpn_id = fnd_api.g_miss_num --Bug 5329067
                 OR l_lpn_id = rti.lpn_id --Bug 5329067
                 OR (    l_lpn_id IS NULL --Bug 5329067
                     AND rti.lpn_id IS NULL))
         AND    (   p_project_id IS NULL
                 OR p_project_id = rti.project_id)
         AND    (   p_task_id IS NULL
                 OR p_task_id = rti.task_id)
         AND    rti.oe_order_line_id = p_supply_demand_line_id
         UNION ALL
         SELECT rsl.quantity_received,
                 rsl.quantity_received - NVL(rs.quantity, 0) quantity_delivered,
                rsl.item_id,
                rsl.unit_of_measure,
                rsl.primary_unit_of_measure,
                rsl.to_organization_id
         FROM   rcv_shipment_lines rsl,
                rcv_supply rs
         WHERE  rsl.shipment_line_id = rs.shipment_line_id(+)
         AND    (   p_organization_id IS NULL
                 OR p_organization_id = rsl.to_organization_id)
         AND    (   p_item_id IS NULL
                 OR p_item_id = rsl.item_id)
         AND    (   p_revision IS NULL
                 OR p_revision = rsl.item_revision)
         AND    (   p_subinventory_code IS NULL
                 OR p_subinventory_code = rsl.to_subinventory)
         AND    (   p_locator_id IS NULL
                 OR p_locator_id = rsl.locator_id)
         AND    (   l_lpn_id = fnd_api.g_miss_num --Bug 5329067
                 OR NVL(l_lpn_id, fnd_api.g_miss_num) IN(SELECT NVL(rt.lpn_id, fnd_api.g_miss_num)--Bug 5329067
                                                         FROM   rcv_transactions rt
                                                         WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    (   p_project_id IS NULL
                 OR p_project_id IN(SELECT rt.project_id
                                    FROM   rcv_transactions rt
                                    WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    (   p_task_id IS NULL
                 OR p_task_id IN(SELECT rt.task_id
                                 FROM   rcv_transactions rt
                                 WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    rsl.oe_order_line_id = p_supply_demand_line_id;

      /*
      get_rcv_ship_row is unique because I want to use it for both
      asn's and intransit so I have made the line_id a parameter
      */
      /* Bug 4642399.
       * We do not need the rti.quantity when transaction_type
       * is SHIP since it actually gets the current shipped_qty
       * for both ASN and Intrasit transactions.
      */
      CURSOR get_rcv_ship_row(
         p_shipment_line_id IN rcv_shipment_lines.shipment_line_id%TYPE
      ) IS
         SELECT DECODE(rti.transaction_type,
                       --'SHIP', rti.quantity,
                       'RECEIVE', rti.quantity,
                       'CORRECT', DECODE(rt.transaction_type,
                                         'SHIP', rti.quantity,
                                         'RECEIVE', rti.quantity,
                                         0
                                        ),
                       0
                      ) quantity_shipped,
                DECODE(rti.transaction_type,
                       'DELIVER', rti.quantity,
                       'CORRECT', DECODE(rt.transaction_type,
                                         'DELIVER', rti.quantity,
                                         0
                                        ),
                       DECODE(rti.auto_transact_code,
                              'DELIVER', rti.quantity,
                              0
                             )
                      ) quantity_delivered,
                rti.item_id,
                rti.unit_of_measure,
                rti.primary_unit_of_measure,
                rti.to_organization_id
         FROM   rcv_transactions_interface rti,
                rcv_transactions rt
         WHERE  rti.parent_transaction_id = rt.transaction_id(+)
         AND    rti.quantity > 0
         AND    (   rti.transaction_type IN('RECEIVE', 'SHIP', 'DELIVER')
                 OR (    rti.transaction_type = 'CORRECT'
                     AND rt.transaction_type IN('RECEIVE', 'DELIVER')))
         AND    rti.processing_status_code IN('PENDING', 'RUNNING')
         AND    (   p_organization_id IS NULL
                 OR p_organization_id = rti.to_organization_id)
         AND    (   p_item_id IS NULL
                 OR p_item_id = rti.item_id)
         AND    (   p_revision IS NULL
                 OR p_revision = rti.item_revision)
         AND    (   p_subinventory_code IS NULL
                 OR p_subinventory_code = rti.subinventory)
         AND    (   p_locator_id IS NULL
                 OR p_locator_id = rti.locator_id)
         AND    (   l_lpn_id = fnd_api.g_miss_num --Bug 5329067
                 OR l_lpn_id = rti.lpn_id--Bug 5329067
                 OR (    l_lpn_id IS NULL --Bug 5329067
                     AND rti.lpn_id IS NULL))
         AND    (   p_project_id IS NULL
                 OR p_project_id = rti.project_id)
         AND    (   p_task_id IS NULL
                 OR p_task_id = rti.task_id)
         AND    rti.shipment_line_id = p_shipment_line_id
         UNION ALL
         SELECT rsl.quantity_received,
                 rsl.quantity_received - NVL(rs.quantity, 0) quantity_delivered,
                rsl.item_id,
                rsl.unit_of_measure,
                rsl.primary_unit_of_measure,
                rsl.to_organization_id
         FROM   rcv_shipment_lines rsl,
                rcv_supply rs
         WHERE  rsl.shipment_line_id = rs.shipment_line_id(+)
         AND    (   p_organization_id IS NULL
                 OR p_organization_id = rsl.to_organization_id)
         AND    (   p_item_id IS NULL
                 OR p_item_id = rsl.item_id)
         AND    (   p_revision IS NULL
                 OR p_revision = rsl.item_revision)
         AND    (   p_subinventory_code IS NULL
                 OR p_subinventory_code = rsl.to_subinventory)
         AND    (   p_locator_id IS NULL
                 OR p_locator_id = rsl.locator_id)
         AND    (   l_lpn_id = fnd_api.g_miss_num --Bug 5329067
                 OR NVL(l_lpn_id, fnd_api.g_miss_num) IN(SELECT NVL(rt.lpn_id, fnd_api.g_miss_num) --Bug 5329067
                                                         FROM   rcv_transactions rt
                                                         WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    (   p_project_id IS NULL
                 OR p_project_id IN(SELECT rt.project_id
                                    FROM   rcv_transactions rt
                                    WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    (   p_task_id IS NULL
                 OR p_task_id IN(SELECT rt.task_id
                                 FROM   rcv_transactions rt
                                 WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    rsl.shipment_line_id = p_shipment_line_id;

      CURSOR get_rcv_po_row IS
         SELECT DECODE(rti.transaction_type,
                       'SHIP', rti.quantity,
                       'RECEIVE', rti.quantity,
                       'CORRECT', DECODE(rt.transaction_type,
                                         'SHIP', rti.quantity,
                                         'RECEIVE', rti.quantity,
                                         0
                                        ),
                        'RETURN TO CUSTOMER', DECODE(rt.transaction_type,
                                                   'RECEIVE', -1 * rti.quantity,
                                                               0
                                                     ), --Return txn is similar as -ve Correction. So make the qty
                                                        --as -ve in order to calculate the available qty correctly
                        'RETURN TO VENDOR', DECODE(rt.transaction_type,
                                                   'RECEIVE', -1 * rti.quantity,
                                                               0
                                                     ),

                        0
                       )quantity_received, --Bug 5329067
                DECODE(rti.transaction_type,
                       'DELIVER', rti.quantity,
                       'CORRECT', DECODE(rt.transaction_type,
                                         'DELIVER', rti.quantity,
                                         0
                                        ),
                        'RETURN TO CUSTOMER', DECODE(rt.transaction_type,
                                                     'DELIVER', -1 * rti.quantity,
                                                      0
                                                     ), --Returns txn is similar as -ve Correction. So make the qty
                                                         --as -ve in order to calculate the available qty correctly
                        'RETURN TO VENDOR', DECODE(rt.transaction_type,
                                                    'DELIVER', -1 * rti.quantity,
                                                     0
                                                     ),
                        'RETURN TO RECEIVING', DECODE(rt.transaction_type,
                                                      'DELIVER', -1 * rti.quantity,
                                                       0
                                                     ),
                        DECODE(rti.auto_transact_code,
                              'DELIVER', rti.quantity,
                              0
                             )
                      ) quantity_delivered, --Bug 5329067
                rti.item_id,
                rti.unit_of_measure,
                rti.primary_unit_of_measure,
                rti.to_organization_id
         FROM   rcv_transactions_interface rti,
                rcv_transactions rt
         WHERE  rti.parent_transaction_id = rt.transaction_id(+)
         AND    (    rti.quantity > 0
                  OR (rti.quantity < 0 AND rti.transaction_type = 'CORRECT')
                )--Bug 5329067
         AND    (    rti.transaction_type IN('RECEIVE', 'SHIP', 'DELIVER')
                  OR (    rti.transaction_type = 'CORRECT'
                      AND rt.transaction_type IN('RECEIVE', 'DELIVER')
                     )
                  OR (    rti.transaction_type IN ('RETURN TO CUSTOMER','RETURN TO VENDOR', 'RETURN TO RECEIVING')
                      AND rt.transaction_type IN('RECEIVE', 'DELIVER')
                     )
                )--Bug 5329067
         AND    rti.processing_status_code IN('PENDING', 'RUNNING')
         AND    (   p_organization_id IS NULL
                 OR p_organization_id = rti.to_organization_id)
         AND    (   p_item_id IS NULL
                 OR p_item_id = rti.item_id)
         AND    (   p_revision IS NULL
                 OR p_revision = rti.item_revision)
         AND    (   p_subinventory_code IS NULL
                 OR p_subinventory_code = rti.subinventory)
         AND    (   p_locator_id IS NULL
                 OR p_locator_id = rti.locator_id)
         AND    (   l_lpn_id = fnd_api.g_miss_num --Bug 5329067
                 OR l_lpn_id = rti.lpn_id --Bug 5329067
                 OR (    l_lpn_id IS NULL--Bug 5329067
                     AND rti.lpn_id IS NULL))
         AND    (   p_project_id IS NULL
                 OR p_project_id = rti.project_id)
         AND    (   p_task_id IS NULL
                 OR p_task_id = rti.task_id)
         AND    rti.po_line_location_id = p_supply_demand_line_id
         UNION ALL
         SELECT rsl.quantity_received quantity_received, --Bug 5329067
                 rsl.quantity_received - NVL(rs.quantity, 0) quantity_delivered,
                rsl.item_id,
                rsl.unit_of_measure,
                rsl.primary_unit_of_measure,
                rsl.to_organization_id
         FROM   rcv_shipment_lines rsl,
                rcv_supply rs
         WHERE  rsl.shipment_line_id = rs.shipment_line_id(+)
         AND    (   p_organization_id IS NULL
                 OR p_organization_id = rsl.to_organization_id)
         AND    (   p_item_id IS NULL
                 OR p_item_id = rsl.item_id)
         AND    (   p_revision IS NULL
                 OR p_revision = rsl.item_revision)
         AND    (   p_subinventory_code IS NULL
                 OR p_subinventory_code = rsl.to_subinventory)
         AND    (   p_locator_id IS NULL
                 OR p_locator_id = rsl.locator_id)
         AND    (   l_lpn_id = fnd_api.g_miss_num --Bug 5329067
                 OR NVL(l_lpn_id, fnd_api.g_miss_num) IN(SELECT NVL(rt.lpn_id, fnd_api.g_miss_num) --Bug 5329067
                                                         FROM   rcv_transactions rt
                                                         WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    (   p_project_id IS NULL
                 OR p_project_id IN(SELECT rt.project_id
                                    FROM   rcv_transactions rt
                                    WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    (   p_task_id IS NULL
                 OR p_task_id IN(SELECT rt.task_id
                                 FROM   rcv_transactions rt
                                 WHERE  rt.shipment_line_id = rsl.shipment_line_id))
         AND    rsl.po_line_location_id = p_supply_demand_line_id;

      x_order_row                   get_po_order%ROWTYPE;

      /*
      get_wms_install is a local helper function that takes an org_id
      and memoizes it in order to increase performance because we are
      likely to perform the same check against wms many times.
      */
      FUNCTION get_wms_install(
         p_organization_id NUMBER
      )
         RETURN BOOLEAN IS
      BEGIN
         IF g_wms_install_table.EXISTS(p_organization_id) THEN
            RETURN g_wms_install_table(p_organization_id);
         END IF;

         g_wms_install_table(p_organization_id)  := wms_install.check_install(x_return_status,
                                                                              x_msg_count,
                                                                              x_msg_data,
                                                                              p_organization_id
                                                                             );
         RETURN g_wms_install_table(p_organization_id);
      END get_wms_install;

      /*
      update_rcv_quantity is a local helper function that takes care
      of the house keeping to keep the code easy to read. This
      procedure increments x_local_quantity and
      x_local_quantity appropriately - ensuring to keep
      everything in the primary_unit_of_measure.
      */
      PROCEDURE update_rcv_quantity(
         p_row get_rcv_po_row%ROWTYPE
      ) IS
         x_local_quantity NUMBER;
      BEGIN
         x_local_quantity  := 0;

         IF (get_wms_install(p_row.to_organization_id)) THEN
            po_uom_s.uom_convert(NVL(p_row.quantity_received, 0),
                                 p_row.unit_of_measure,
                                 p_row.item_id,
                                 NVL(p_row.primary_unit_of_measure, p_row.unit_of_measure),
                                 x_local_quantity
                                );
         ELSE --non wms org: count the quantity delivered
            po_uom_s.uom_convert(NVL(p_row.quantity_delivered, 0),
                                 p_row.unit_of_measure,
                                 p_row.item_id,
                                 NVL(p_row.primary_unit_of_measure, p_row.unit_of_measure),
                                 x_local_quantity
                                );
         END IF;

         /*
         pessimistic logging - assume all beneficial transactions fail
         */
         /** Bug 5329067:
          *  x_local_quantity can hold -ve values in case of 'RETURN' txn and
          *  -ve CORRECTION txn. So commented the check for the value > 0 for
          *  the variable x_local_quantity.
          */
--         IF (x_local_quantity > 0) THEN
            x_rcv_quantity  := x_rcv_quantity + x_local_quantity;
--         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END update_rcv_quantity;
   BEGIN
      x_return_status       := fnd_api.g_ret_sts_error;

      --  Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call(l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         g_pkg_name
                                        ) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --  Initialize message list.
      IF fnd_api.to_boolean(p_init_msg_lst) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF (   p_supply_demand_code IS NULL
          OR p_supply_demand_type_id IS NULL
          OR p_supply_demand_header_id IS NULL
          OR p_supply_demand_line_id IS NULL) THEN
         fnd_message.set_name('RCV', 'RCV_INVALID_NULL');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

     /** Bug 5329067:
      *  If the p_lpn_id is passed as 'null' to the procedure get_available_supply_demand(), then
      *  we have to treat it same as the fnd_api.g_miss_num. As of now reservation in receiving is not
      *  maintained at the LPN level, so we can treat the 'null' value as fnd_api.g_miss_num.
      */
     IF p_lpn_id is null then --Bug 5329067
         l_lpn_id := fnd_api.g_miss_num;
     ELSE
         l_lpn_id := p_lpn_id;
     END IF;

      /* Bug 8569352:  Do not call normalize_interface_tables if this is the case of PO Approval */

      if (p_supply_demand_type_id <> 1) then
      normalize_interface_tables; --this makes sure we can query rti via the header and line id's
      end if;

      x_rcv_quantity        := 0;
      x_rcv_order_quantity  := 0;

      /*
      The logic below first defaults x_rcv_order_quantity from the
      backing docs. It then loops through all the rows in
      rcv_transactions_interface (RTI) and rcv_shipment_lines (RSL).
      If the row is in RSL then it increases the running value of
      x_rcv_quantity by shipped_quantity for non-wms orgs and increases the value
      of x_rcv_quantity by received_quantity for wms orgs. We know that RSL's
      shipped_quantity and receipt_quantity are an accurate summation of all rcv_transaction
      records for that backing doc. If the row is in RTI and the RTI
      row is a 'RECEIVE' or a positive correction to a 'RECEIVE' then
      it increases the running value of x_rcv_quantity for wms orgs, else if
      the RTI row is a 'SHIP' then it increases the running value of
      x_rcv_quantity.

      This is to avoid double counting. If I have a PO for quantity
      100, and I have already processed an ASN for quantity 50, a
      processed receipt for quantity 10, a pending delivery for
      quantity 5 for that receipt, and a new pending receipt for
      quantity 3 then in a WMS installation I want to return an
      available quantity of 87 = (100 - 10 - 3) or 50 = (100 - 50) in
      a non-WMS installation. The deliver has already been accounted
      for in the 'RECEIVE' so the reason for only looking at these RTI
      types is to avoid double counting.
      */
      IF (p_supply_demand_type_id IN(7, 17)) THEN --internal and external req
         OPEN get_req_order;
         FETCH get_req_order INTO x_order_row;
         CLOSE get_req_order;

         FOR c_rcv_row IN get_rcv_req_row LOOP
            update_rcv_quantity(c_rcv_row);
         END LOOP;
      ELSIF(p_supply_demand_type_id IN(2, 8, 12)) THEN --sales order, rma, and intenal order
         OPEN get_oe_order;
         FETCH get_oe_order INTO x_order_row;
         CLOSE get_oe_order;

         FOR c_rcv_row IN get_rcv_oe_row LOOP
            update_rcv_quantity(c_rcv_row);
         END LOOP;
      ELSIF(p_supply_demand_type_id IN(26)) THEN --intransit
         OPEN get_ship_order(p_supply_demand_line_id);
         FETCH get_ship_order INTO x_order_row;
         CLOSE get_ship_order;

         FOR c_rcv_row IN get_rcv_ship_row(p_supply_demand_line_id) LOOP
            update_rcv_quantity(c_rcv_row);
         END LOOP;
      ELSIF(p_supply_demand_type_id IN(25)) THEN --asn
         OPEN get_ship_order(p_supply_demand_line_detail);
         FETCH get_ship_order INTO x_order_row;
         CLOSE get_ship_order;

         FOR c_rcv_row IN get_rcv_ship_row(p_supply_demand_line_detail) LOOP
            update_rcv_quantity(c_rcv_row);
         END LOOP;
      ELSE --po
         OPEN get_po_order(p_project_id,p_task_id);
         FETCH get_po_order INTO x_order_row;
         CLOSE get_po_order;

         -- <Bug 9342280 : Added for CLM project>
         l_is_clm_po := po_clm_intg_grp.is_clm_po( p_po_header_id        => NULL,
                                                   p_po_line_id          => NULL,
                                                   p_po_line_location_id => p_supply_demand_line_id,
                                                   p_po_distribution_id  => NULL);


         l_partial_funded_flag := 'N';

         IF l_is_clm_po = 'Y' THEN

            po_clm_intg_grp.get_funding_info(p_po_header_id            => NULL,
                                             p_po_line_id              => NULL,
                                             p_line_location_id        => p_supply_demand_line_id,
                                             p_po_distribution_id      => NULL,
                                             x_distribution_type       => l_distribution_type,
                                             x_matching_basis          => l_matching_basis,
                                             x_accrue_on_receipt_flag  => l_accrue_on_receipt_flag,
                                             x_code_combination_id     => l_code_combination_id,
                                             x_budget_account_id       => l_budget_account_id,
                                             x_partial_funded_flag     => l_partial_funded_flag,
                                             x_unit_meas_lookup_code   => l_unit_meas_lookup_code,
                                             x_funded_value            => l_funded_value,
                                             x_quantity_funded         => l_quantity_funded,
                                             x_amount_funded           => l_amount_funded,
                                             x_quantity_received       => l_quantity_received,
                                             x_amount_received         => l_amount_received,
                                             x_quantity_delivered      => l_quantity_delivered,
                                             x_amount_delivered        => l_amount_delivered,
                                             x_quantity_billed         => l_quantity_billed,
                                             x_amount_billed           => l_amount_billed,
                                             x_quantity_cancelled      => l_quantity_cancelled,
                                             x_amount_cancelled        => l_amount_cancelled,
                                             x_return_status           => l_return_status  );

            IF l_partial_funded_flag = 'Y' AND x_order_row.quantity IS NOT NULL THEN

               x_order_row.quantity := l_quantity_funded;

            END IF;

         END IF;
         -- <CLM END>

         FOR c_rcv_row IN get_rcv_po_row LOOP
            update_rcv_quantity(c_rcv_row);
         END LOOP;
      END IF;

/* Bug 4901404: When the unit_of_measure and primary_unit_of_measure
                are null, no need to call the uom_convert procedure and
		we can default the value of x_available_quantity to Zero */

      IF x_order_row.unit_of_measure IS NOT NULL THEN --Bug: 4901404
         po_uom_s.uom_convert(NVL(x_order_row.quantity, 0),
                           x_order_row.unit_of_measure,
                           x_order_row.item_id,
                           NVL(x_order_row.primary_unit_of_measure, x_order_row.unit_of_measure),
                           x_rcv_order_quantity
                          );
         x_rcv_order_quantity  := NVL(x_rcv_order_quantity, 0);
         x_available_quantity  := x_rcv_order_quantity - x_rcv_quantity;

        --Bug 5313645
        --Since we are converting the available quantity to primary uom
        --always. We should be passing the primary uom code in x_source_uom_code        --Commenting out the following code.

       /*OPEN get_uom_code(x_order_row.unit_of_measure);
         FETCH get_uom_code INTO x_source_uom_code;
         CLOSE get_uom_code;
       */
         OPEN get_uom_code(x_order_row.primary_unit_of_measure);
         FETCH get_uom_code INTO x_source_primary_uom_code;
         CLOSE get_uom_code;

         x_source_uom_code := x_source_primary_uom_code;

         IF (x_available_quantity IS NULL) THEN
            fnd_message.set_name('RCV', 'RCV_UNEXPECTED_NULL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;

         IF (x_available_quantity < 0) THEN
            x_available_quantity  := 0;
         END IF;
      ELSE -- x_order_row.unit_of_measure is NULL
         x_available_quantity := 0;
      END IF; /* Bug:4901404 fix ends*/

      x_return_status       := fnd_api.g_ret_sts_success;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status  := fnd_api.g_ret_sts_error;
         --  Get message count and data
         fnd_msg_pub.count_and_get(p_count    => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         --  Get message count and data
         fnd_msg_pub.count_and_get(p_count    => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         --  Get message count and data
         fnd_msg_pub.count_and_get(p_count    => x_msg_count, p_data => x_msg_data);
   END get_available_supply_demand;

   /*
   validate_supply_demand does a lookup against the given backing docs
   and returns a valid flag if the document is open, approved, and
   waiting for receipts
   */
   PROCEDURE validate_supply_demand(
      x_return_status             OUT NOCOPY    VARCHAR2,
      x_msg_count                 OUT NOCOPY    NUMBER,
      x_msg_data                  OUT NOCOPY    VARCHAR2,
      x_valid_status              OUT NOCOPY    VARCHAR2,
      p_organization_id           IN            NUMBER,
      p_item_id                   IN            NUMBER,
      p_supply_demand_code        IN            NUMBER,
      p_supply_demand_type_id     IN            NUMBER,
      p_supply_demand_header_id   IN            NUMBER,
      p_supply_demand_line_id     IN            NUMBER,
      p_supply_demand_line_detail IN            NUMBER,
      p_demand_ship_date          IN            DATE,
      p_expected_receipt_date     IN            DATE,
      p_api_version_number        IN            NUMBER,
      p_init_msg_lst              IN            VARCHAR2
   ) IS
      l_api_version_number CONSTANT NUMBER       := 1.0;
      l_api_name           CONSTANT VARCHAR2(30) := 'get_available_supply_demand';
      l_lookup_code                 VARCHAR2(20);
   BEGIN
      x_return_status  := fnd_api.g_ret_sts_error;
      x_valid_status   := 'N';

      --  Standard call to check for call compatibility
      IF NOT fnd_api.compatible_api_call(l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         g_pkg_name
                                        ) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --  Initialize message list.
      IF fnd_api.to_boolean(p_init_msg_lst) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF (   p_supply_demand_code IS NULL
          OR p_supply_demand_type_id IS NULL
          OR p_supply_demand_header_id IS NULL
          OR p_supply_demand_line_id IS NULL) THEN
         fnd_message.set_name('RCV', 'RCV_INVALID_NULL');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      /*
      The following section will attempt to use the backing docs to
      query if a valid open doc exists for the various source types.
      If the query fails then the exception handler will set the valid
      flag to N
      */
      BEGIN
         IF (p_supply_demand_type_id IN(7, 17)) THEN --interanl and external req
            IF (p_supply_demand_type_id = 17) THEN --external req
               l_lookup_code  := 'PURCHASE';
            ELSE --internal req
               l_lookup_code  := 'INTERNAL';
            END IF;

	    /* Bug 4619856.
	     * Change all the table to base tables.
	    */
            SELECT 'Y'
            INTO   x_valid_status
            FROM   po_requisition_lines_all rl,
                   po_requisition_headers_all rh
            WHERE  rh.requisition_header_id = rl.requisition_header_id
            AND    type_lookup_code = l_lookup_code
            AND    authorization_status = 'APPROVED'
            AND    NVL(rl.cancel_flag, 'N') = 'N'
            AND    NVL(rl.closed_code, 'OPEN') = 'OPEN'
            AND    NVL(rh.closed_code, 'OPEN') = 'OPEN'
            AND    document_type_code IS NULL
            AND    destination_type_code <> 'EXPENSE'
            AND    (   p_organization_id IS NULL
                    OR p_organization_id = rl.destination_organization_id)
            AND    (   p_item_id IS NULL
                    OR p_item_id = rl.item_id)
            AND    rl.requisition_line_id = p_supply_demand_line_id
            AND    rh.requisition_header_id = p_supply_demand_header_id;
         ELSIF(p_supply_demand_type_id IN(2, 8, 12)) THEN --sales order, rma, and internal order
            IF (p_supply_demand_type_id = 12) THEN --rma
               l_lookup_code  := 'RETURN';
            ELSE --sales order and internal order
               l_lookup_code  := 'ORDER';
            END IF;

	    /* Bug 4619856.
	     * Change all the table to base tables.
	    */
            SELECT 'Y'
            INTO   x_valid_status
            FROM   oe_order_lines_all
            WHERE  open_flag = 'Y'
            AND    line_category_code = l_lookup_code
            AND    (   p_organization_id IS NULL
                    OR p_organization_id = deliver_to_org_id)
            AND    (   p_item_id IS NULL
                    OR p_item_id = inventory_item_id)
            AND    line_id = p_supply_demand_line_id
            AND    header_id = p_supply_demand_header_id;
         ELSIF(p_supply_demand_type_id IN(26)) THEN --intransit
            SELECT 'Y'
            INTO   x_valid_status
            FROM   rcv_shipment_lines rsl,
                   rcv_shipment_headers rsh
            WHERE  shipment_line_status_code IN('EXPECTED', 'PARTIALLY RECEIVED')
            AND    rsl.shipment_header_id = rsh.shipment_header_id
            AND    (   p_organization_id IS NULL
                    OR p_organization_id = rsl.to_organization_id)
            AND    (   p_item_id IS NULL
                    OR p_item_id = rsl.item_id)
            AND    rsl.shipment_line_id = p_supply_demand_line_id
            AND    rsl.shipment_header_id = p_supply_demand_header_id;
         ELSE --po's and asn's

      /* Bug#12320593 */
      IF (p_supply_demand_type_id IN(25)) THEN --asn
               SELECT 'Y'
               INTO   x_valid_status
               FROM   rcv_shipment_lines rsl,
                      rcv_shipment_headers rsh
               WHERE  shipment_line_status_code IN('EXPECTED', 'PARTIALLY RECEIVED')
               AND    rsl.shipment_header_id = rsh.shipment_header_id
               AND    rsl.shipment_line_id = p_supply_demand_line_detail
               AND    rsl.po_line_location_id = p_supply_demand_line_id
               AND    rsl.po_header_id = p_supply_demand_header_id;

		   x_return_status  := fnd_api.g_ret_sts_success;
	       RETURN;

      END IF;
      /*End Bug#12320593 */

	    /* Bug 4619856.
	     * Change all the table to base tables.
	    */
            SELECT 'Y'
            INTO   x_valid_status
            FROM   po_line_locations_all pll,
                   po_lines_all pol,
                   po_headers_all poh
            WHERE  pol.po_header_id = poh.po_header_id
            AND    pll.po_line_id = pol.po_line_id
            AND    NVL(pll.approved_flag, 'N') = 'Y'
            AND    NVL(pol.closed_code, 'OPEN') <> 'FINALLY CLOSED'
            AND    NVL(pll.cancel_flag, 'N') = 'N'
            AND    pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
            AND    (   p_organization_id IS NULL
                    OR p_organization_id = pll.ship_to_organization_id)
            AND    (   p_item_id IS NULL
                    OR p_item_id = pol.item_id)
            AND    pll.line_location_id = p_supply_demand_line_id
            AND    pol.po_header_id = p_supply_demand_header_id;

         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            x_valid_status  := 'N';
      END;

      x_return_status  := fnd_api.g_ret_sts_success;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status  := fnd_api.g_ret_sts_error;
         --  Get message count and data
         fnd_msg_pub.count_and_get(p_count    => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         --  Get message count and data
         fnd_msg_pub.count_and_get(p_count    => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         --  Get message count and data
         fnd_msg_pub.count_and_get(p_count    => x_msg_count, p_data => x_msg_data);
   END validate_supply_demand;
END rcv_availability;

/
