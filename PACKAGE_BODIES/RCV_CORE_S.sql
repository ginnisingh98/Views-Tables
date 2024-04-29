--------------------------------------------------------
--  DDL for Package Body RCV_CORE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_CORE_S" AS
/* $Header: RCVCOCOB.pls 120.2.12010000.2 2010/01/25 22:29:46 vthevark ship $*/

-- Read the profile option that enables/disables the debug log
   g_asn_debug         VARCHAR2(1)  := asn_debug.is_debug_on; -- Bug 9152790
   g_log_head CONSTANT VARCHAR2(30) := 'po.plsql.RCV_CORE_S.'; -- <BUG 3365446>
   e_validation_error  EXCEPTION;

/*===========================================================================

  PROCEDURE NAME: val_destination_info

===========================================================================*/
   PROCEDURE val_destination_info(
      x_receipt_source_code  IN            VARCHAR2,
      x_trx_date             IN            DATE,
      x_line_loc_id          IN            NUMBER,
      x_dist_id              IN            NUMBER,
      x_ship_line_id         IN            NUMBER,
      x_org_id               IN            NUMBER,
      x_item_id              IN            NUMBER,
      x_ship_to_loc_id       OUT NOCOPY    NUMBER,
      x_ship_to_loc_code     OUT NOCOPY    VARCHAR2,
      x_deliver_to_loc_id    OUT NOCOPY    NUMBER,
      x_deliver_to_loc_code  OUT NOCOPY    VARCHAR2,
      x_dest_subinv          OUT NOCOPY    VARCHAR2,
      x_locator_id           OUT NOCOPY    NUMBER,
      x_locator              OUT NOCOPY    VARCHAR2,
      x_dest_org_id          OUT NOCOPY    NUMBER,
      x_dest_org_code        OUT NOCOPY    VARCHAR2,
      x_dest_type_code       OUT NOCOPY    VARCHAR2,
      x_deliver_to_person_id OUT NOCOPY    NUMBER,
      x_deliver_to_person    OUT NOCOPY    VARCHAR2
   ) IS
/*
**  Procedure validates whether ship-to location, deliver-to location,
**  destination subinventory, destination organization and deliver-to person
**  specified as defaults on the purchase order are active for the transaction
**  date.  If they are not active, they are nulled out.
**  If the destination of an item is inventory, then look up default locator
**  for that subinventory for that line item.
*/
      x_progress           VARCHAR2(3)  := NULL;
      x_temp               VARCHAR2(50) := NULL;
      ship_to_loc_id       NUMBER;
      deliver_to_loc_id    NUMBER;
      dest_subinv          VARCHAR2(10);
      dest_org_id          NUMBER;
      dest_type_code       NUMBER;
      deliver_to_person_id NUMBER;
      x_ship_head_id       NUMBER;
      x_active_date        DATE;
   BEGIN
      IF (x_receipt_source_code = 'VENDOR') THEN
         x_progress  := '010';

         SELECT deliver_to_location_id,
                deliver_to_person_id,
                destination_subinventory,
                destination_organization_id,
                destination_type_code
         INTO   deliver_to_loc_id,
                deliver_to_person_id,
                dest_subinv,
                dest_org_id,
                dest_type_code
         FROM   po_distributions
         WHERE  po_distribution_id = x_dist_id;

         x_progress  := '020';

         SELECT ship_to_location_id
         INTO   ship_to_loc_id
         FROM   po_line_locations
         WHERE  line_location_id = x_line_loc_id;
      ELSE
         x_progress  := '030';

         SELECT deliver_to_location_id,
                deliver_to_person_id,
                to_subinventory,
                to_organization_id,
                destination_type_code,
                shipment_header_id
         INTO   deliver_to_loc_id,
                deliver_to_person_id,
                dest_subinv,
                dest_org_id,
                dest_type_code,
                x_ship_head_id
         FROM   rcv_shipment_lines
         WHERE  shipment_line_id = x_ship_line_id;

         x_progress  := '040';

         SELECT ship_to_location_id
         INTO   ship_to_loc_id
         FROM   rcv_shipment_headers
         WHERE  shipment_header_id = x_ship_head_id;
      END IF;

--  Validate ship_to_location_id

      x_progress  := '040';

      SELECT location_code
      INTO   x_ship_to_loc_code
      FROM   hr_locations
      WHERE  NVL(inventory_organization_id, x_org_id) = x_org_id
      AND    (   inactive_date IS NULL
              OR inactive_date > x_trx_date)
      AND    location_id = ship_to_loc_id;

      IF (SQL%NOTFOUND) THEN
         x_ship_to_loc_id    := NULL;
         x_ship_to_loc_code  := NULL;
      ELSE
         x_ship_to_loc_id  := ship_to_loc_id;
      END IF;

--  Validate deliver_to_location

      x_progress  := '050';

      SELECT location_code
      INTO   x_deliver_to_loc_code
      FROM   hr_locations
      WHERE  NVL(inventory_organization_id, x_org_id) = x_org_id
      AND    (   inactive_date IS NULL
              OR inactive_date > x_trx_date)
      AND    location_id = deliver_to_loc_id;

      IF (SQL%NOTFOUND) THEN
         x_deliver_to_loc_id    := NULL;
         x_deliver_to_loc_code  := NULL;
      ELSE
         x_deliver_to_loc_id  := deliver_to_loc_id;
      END IF;

--  Validate destination_subinventory

      x_progress  := '060';

      SELECT 'Check to see if subinventory is valid'
      INTO   x_temp
      FROM   mtl_secondary_inventories
      WHERE  (   disable_date IS NULL
              OR disable_date > x_trx_date)
      AND    organization_id = x_org_id
      AND    secondary_inventory_name = dest_subinv
      AND    (   (x_item_id IS NULL)
              OR (    x_item_id IS NOT NULL
                  AND EXISTS(SELECT 'valid subinventory'
                             FROM   mtl_system_items msi
                             WHERE  msi.organization_id = x_org_id
                             AND    msi.inventory_item_id = x_item_id
                             AND    (   msi.restrict_subinventories_code = 2
                                     OR (    msi.restrict_subinventories_code = 1
                                         AND EXISTS(SELECT 'valid subinventory'
                                                    FROM   mtl_item_sub_inventories mis
                                                    WHERE  mis.organization_id = x_org_id
                                                    AND    mis.inventory_item_id = x_item_id
                                                    AND    mis.secondary_inventory = secondary_inventory_name))))
                 )
             );

      IF (SQL%NOTFOUND) THEN
         x_dest_subinv  := NULL;
      ELSE
         x_dest_subinv  := dest_subinv;
      END IF;

--  Validate destination_organization

      x_progress  := '070';

      --perf bugfix 5217401
      SELECT  mp.organization_code
      INTO   x_dest_org_code
      FROM   HR_ORGANIZATION_UNITS HOU,
             MTL_PARAMETERS MP
      WHERE HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
        AND HOU.organization_id = dest_org_id
        AND ( HOU.DATE_TO  is NULL     OR     HOU.DATE_To > x_trx_date);

      IF (SQL%NOTFOUND) THEN
         x_dest_org_id    := NULL;
         x_dest_org_code  := NULL;
      ELSE
         x_dest_org_id  := dest_org_id;
      END IF;

--  Validate deliver_to_person

      x_progress  := '080';

      SELECT full_name
      INTO   x_deliver_to_person
      FROM   hr_employees_current_v
      WHERE  (   inactive_date IS NULL
              OR inactive_date > x_trx_date)
      AND    employee_id = deliver_to_person_id;

      IF (SQL%NOTFOUND) THEN
         x_deliver_to_person_id  := NULL;
         x_deliver_to_person     := NULL;
      ELSE
         x_deliver_to_person_id  := deliver_to_person_id;
      END IF;

--  Validate locator for INVENTORY destination

      x_progress  := '090';

      IF (dest_type_code = 'INVENTORY') THEN
         --call Thomas's get_default_locator, val_locator routines
         NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('val_destination_info',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END val_destination_info;

/*===========================================================================

  PROCEDURE NAME: get_receiving_controls

===========================================================================*/
   PROCEDURE get_receiving_controls(
      x_line_loc_id         IN            NUMBER,
      x_item_id             IN            NUMBER,
      x_vendor_id           IN            NUMBER,
      x_org_id              IN            NUMBER,
      x_enforce_ship_to_loc IN OUT NOCOPY VARCHAR2,
      x_allow_substitutes   IN OUT NOCOPY VARCHAR2,
      x_routing_id          IN OUT NOCOPY NUMBER,
      x_qty_rcv_tolerance   IN OUT NOCOPY NUMBER,
      x_qty_rcv_exception   IN OUT NOCOPY VARCHAR2,
      x_days_early_receipt  IN OUT NOCOPY NUMBER,
      x_days_late_receipt   IN OUT NOCOPY NUMBER,
      x_rcv_date_exception  IN OUT NOCOPY VARCHAR2,
      p_payment_type        IN            VARCHAR2 DEFAULT NULL
   ) IS
      x_progress     VARCHAR2(3)                             := NULL;
      l_routing_name rcv_routing_headers.routing_name%TYPE; -- <BUG 3365446>
   BEGIN
      -- <BUG 3365446 START>
      --
      rcv_core_s.get_receiving_controls(p_order_type_lookup_code         => NULL,
                                        p_purchase_basis                 => NULL,
                                        p_line_location_id               => x_line_loc_id,
                                        p_item_id                        => x_item_id,
                                        p_org_id                         => x_org_id,
                                        p_vendor_id                      => x_vendor_id,
                                        x_enforce_ship_to_loc_code       => x_enforce_ship_to_loc,
                                        x_allow_substitute_receipts      => x_allow_substitutes,
                                        x_routing_id                     => x_routing_id,
                                        x_routing_name                   => l_routing_name,
                                        x_qty_rcv_tolerance              => x_qty_rcv_tolerance,
                                        x_qty_rcv_exception_code         => x_qty_rcv_exception,
                                        x_days_early_receipt_allowed     => x_days_early_receipt,
                                        x_days_late_receipt_allowed      => x_days_late_receipt,
                                        x_receipt_days_exception_code    => x_rcv_date_exception,
					p_payment_type => p_payment_type
                                       );
   -- <BUG 3365446 END>

   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('get_receiving_controls',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END get_receiving_controls;

------------------------------------------------------------------<BUG 3365446>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_receiving_controls
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--
--  (Overloaded procedure)
--  Retrieves default Receiving Controls according to the following hierarchy:
--
--  1) PO_LINE_LOCATIONS_ALL (...from the PO Shipment)
--  2) MTL_SYSTEM_ITEMS (...from the Item Master definition)
--  3) PO_VENDORS (...from the Supplier defaults)
--  4) RCV_PARAMETERS (...from the Receiving Controls Setup)
--
--  For each Receiving Control not gotten at the first level, we will try to
--  retrieve a value for it from the next level, and so on.
--
--  For Services lines (i.e. 'FIXED PRICE/SERVICES','*/TEMP LABOR'), we will
--  directly assign values for most of the parameters regardless of what are
--  specified in the various setups:
--
--                                  FIXED PRICE/SERVICES      * / TEMP LABOR
--                                  --------------------   --------------------
--  x_enforce_ship_to_loc_code             'NONE'                 'NONE'
--  x_allow_substitute_receipts             NULL                   NULL
--  x_routing_id                             3                      3
--  x_routing_name                    'Direct Delivery'      'Direct Delivery'
--  x_qty_rcv_tolerance              <default hierarchy>    <default hierarchy>
--  x_qty_rcv_exception_code         <default hierarchy>    <default hierarchy>
--  x_days_early_receipt_allowed     <default hierarchy>           NULL
--  x_days_late_receipt_allowed      <default hierarchy>           NULL
--  x_receipt_days_exception_code    <default hierarchy>           NULL
--
--Parameters:
--IN:
--p_order_type_lookup_code
--  Value basis of Shipment on which Receiving Controls will be defaulted.
--  If NULL, Shipment will be treated as non-Fixed Price line.
--p_purchase_basis
--  Purchase basis of Shipment on which Receiving Controls will be defaulted.
--  If NULL, Shipment will be treated as non-Temp Labor line.
--p_line_location_id
--  Shipment ID to get values from PO.
--p_item_id
--  Item ID (used with Org ID) to get default from Item Master definition.
--p_org_id
--  Org ID (used with Item ID) to get default from Item Master definition.
--p_vendor_id
--  Supplier ID to get default from Supplier Setup.
--p_drop_ship_flag := 'N'
--  Drop Ship flag. If the Shipment is Drop Ship, Routing name is set to
--  'Direct Delivery' and x_routing_id = 3.
--OUT:
--x_routing_id
--x_routing_name
--x_qty_rcv_tolerance
--x_qty_rcv_exception_code
--x_days_early_receipt_allowed
--x_days_late_receipt_allowed
--x_receipt_days_exception_code
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
   PROCEDURE get_receiving_controls(
      p_order_type_lookup_code      IN            VARCHAR2,
      p_purchase_basis              IN            VARCHAR2,
      p_line_location_id            IN            NUMBER,
      p_item_id                     IN            NUMBER,
      p_org_id                      IN            NUMBER,
      p_vendor_id                   IN            NUMBER,
      p_drop_ship_flag              IN            VARCHAR2 := 'N',
      x_enforce_ship_to_loc_code    OUT NOCOPY    VARCHAR2,
      x_allow_substitute_receipts   OUT NOCOPY    VARCHAR2,
      x_routing_id                  OUT NOCOPY    NUMBER,
      x_routing_name                OUT NOCOPY    VARCHAR2,
      x_qty_rcv_tolerance           OUT NOCOPY    NUMBER,
      x_qty_rcv_exception_code      OUT NOCOPY    VARCHAR2,
      x_days_early_receipt_allowed  OUT NOCOPY    NUMBER,
      x_days_late_receipt_allowed   OUT NOCOPY    NUMBER,
      x_receipt_days_exception_code OUT NOCOPY    VARCHAR2,
      p_payment_type       	    IN            VARCHAR2 DEFAULT NULL
   ) IS
      l_api_name VARCHAR2(30)  := 'get_receiving_controls';
      l_log_head VARCHAR2(100) := g_log_head || l_api_name;
      l_progress VARCHAR2(3);
   BEGIN
      l_progress  := '000';
      po_debug.debug_begin(l_log_head);

-- PO Shipment ============================================================

      IF (p_line_location_id IS NOT NULL) THEN
         l_progress  := '010';
         po_debug.debug_stmt(l_log_head,
                             l_progress,
                             'Retrieving Receiving Controls from PO Shipment...'
                            );
         l_progress  := '020';
         po_debug.debug_var(l_log_head,
                            l_progress,
                            'p_line_location_id',
                            p_line_location_id
                           );

         BEGIN
            SELECT enforce_ship_to_location_code,
                   allow_substitute_receipts_flag,
                   receiving_routing_id,
                   qty_rcv_tolerance,
                   qty_rcv_exception_code,
                   days_early_receipt_allowed,
                   days_late_receipt_allowed,
                   receipt_days_exception_code
            INTO   x_enforce_ship_to_loc_code,
                   x_allow_substitute_receipts,
                   x_routing_id,
                   x_qty_rcv_tolerance,
                   x_qty_rcv_exception_code,
                   x_days_early_receipt_allowed,
                   x_days_late_receipt_allowed,
                   x_receipt_days_exception_code
            FROM   po_line_locations_all
            WHERE  line_location_id = p_line_location_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

-- Item Master ============================================================

      IF (p_item_id IS NOT NULL) THEN
         l_progress  := '030';
         po_debug.debug_stmt(l_log_head,
                             l_progress,
                             'Retrieving Receiving Controls from Item Master...'
                            );
         l_progress  := '040';
         po_debug.debug_var(l_log_head,
                            l_progress,
                            'p_item_id',
                            TO_NUMBER(p_item_id)
                           );
         l_progress  := '050';
         po_debug.debug_var(l_log_head,
                            l_progress,
                            'p_org_id',
                            p_org_id
                           );

         BEGIN
            SELECT NVL(x_enforce_ship_to_loc_code, enforce_ship_to_location_code),
                   NVL(x_allow_substitute_receipts, allow_substitute_receipts_flag),
                   NVL(x_routing_id, receiving_routing_id),
                   NVL(x_qty_rcv_tolerance, qty_rcv_tolerance),
                   NVL(x_qty_rcv_exception_code, qty_rcv_exception_code),
                   NVL(x_days_early_receipt_allowed, days_early_receipt_allowed),
                   NVL(x_days_late_receipt_allowed, days_late_receipt_allowed),
                   NVL(x_receipt_days_exception_code, receipt_days_exception_code)
            INTO   x_enforce_ship_to_loc_code,
                   x_allow_substitute_receipts,
                   x_routing_id,
                   x_qty_rcv_tolerance,
                   x_qty_rcv_exception_code,
                   x_days_early_receipt_allowed,
                   x_days_late_receipt_allowed,
                   x_receipt_days_exception_code
            FROM   mtl_system_items
            WHERE  inventory_item_id = p_item_id
            AND    NVL(organization_id, -99) = NVL(p_org_id, -99);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

-- Supplier ===============================================================

      IF (p_vendor_id IS NOT NULL) THEN
         l_progress  := '060';
         po_debug.debug_stmt(l_log_head,
                             l_progress,
                             'Retrieving Receiving Controls from Supplier Setup...'
                            );
         l_progress  := '070';
         po_debug.debug_var(l_log_head,
                            l_progress,
                            'p_vendor_id',
                            p_vendor_id
                           );

         BEGIN
            SELECT NVL(x_enforce_ship_to_loc_code, enforce_ship_to_location_code),
                   NVL(x_allow_substitute_receipts, allow_substitute_receipts_flag),
                   NVL(x_routing_id, receiving_routing_id),
                   NVL(x_qty_rcv_tolerance, qty_rcv_tolerance),
                   NVL(x_qty_rcv_exception_code, qty_rcv_exception_code),
                   NVL(x_days_early_receipt_allowed, days_early_receipt_allowed),
                   NVL(x_days_late_receipt_allowed, days_late_receipt_allowed),
                   NVL(x_receipt_days_exception_code, receipt_days_exception_code)
            INTO   x_enforce_ship_to_loc_code,
                   x_allow_substitute_receipts,
                   x_routing_id,
                   x_qty_rcv_tolerance,
                   x_qty_rcv_exception_code,
                   x_days_early_receipt_allowed,
                   x_days_late_receipt_allowed,
                   x_receipt_days_exception_code
            FROM   po_vendors
            WHERE  vendor_id = p_vendor_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

      -- Receiving Controls Setup ===============================================

      l_progress  := '080';
      po_debug.debug_stmt(l_log_head,
                          l_progress,
                          'Retrieving Receiving Controls from Default Setup...'
                         );

      BEGIN
         SELECT NVL(x_enforce_ship_to_loc_code, enforce_ship_to_location_code),
                NVL(x_allow_substitute_receipts, allow_substitute_receipts_flag),
                NVL(x_routing_id, receiving_routing_id),
                NVL(x_qty_rcv_tolerance, qty_rcv_tolerance),
                NVL(x_qty_rcv_exception_code, qty_rcv_exception_code),
                NVL(x_days_early_receipt_allowed, days_early_receipt_allowed),
                NVL(x_days_late_receipt_allowed, days_late_receipt_allowed),
                NVL(x_receipt_days_exception_code, receipt_days_exception_code)
         INTO   x_enforce_ship_to_loc_code,
                x_allow_substitute_receipts,
                x_routing_id,
                x_qty_rcv_tolerance,
                x_qty_rcv_exception_code,
                x_days_early_receipt_allowed,
                x_days_late_receipt_allowed,
                x_receipt_days_exception_code
         FROM   rcv_parameters
         WHERE  organization_id = p_org_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      -- Default Values =========================================================

      l_progress  := '090';
      po_debug.debug_stmt(l_log_head,
                          l_progress,
                          'Assigning default values to any unassigned values...'
                         );
      l_progress  := '100';
      po_debug.debug_var(l_log_head,
                         l_progress,
                         'p_order_type_lookup_code',
                         p_order_type_lookup_code
                        );
      l_progress  := '110';
      po_debug.debug_var(l_log_head,
                         l_progress,
                         'p_purchase_basis',
                         p_purchase_basis
                        );

      -- Fixed Price/Services Line Types
      --
      IF (    (p_order_type_lookup_code = 'FIXED PRICE')
          AND (p_purchase_basis = 'SERVICES')) THEN
         SELECT 'NONE',
                NULL,
                3 -- 'Direct Delivery'
                  ,
                NVL(x_qty_rcv_tolerance, 0),
                NVL(x_qty_rcv_exception_code, 'NONE'),
                NVL(x_days_early_receipt_allowed, 0),
                NVL(x_days_late_receipt_allowed, 0),
                NVL(x_receipt_days_exception_code, 'NONE')
         INTO   x_enforce_ship_to_loc_code,
                x_allow_substitute_receipts,
                x_routing_id,
                x_qty_rcv_tolerance,
                x_qty_rcv_exception_code,
                x_days_early_receipt_allowed,
                x_days_late_receipt_allowed,
                x_receipt_days_exception_code
         FROM   DUAL;
      -- Temp Labor Line Types
      --
      ELSIF(p_purchase_basis = 'TEMP LABOR') THEN
         SELECT 'NONE',
                NULL,
                3 -- 'Direct Delivery'
                  ,
                NVL(x_qty_rcv_tolerance, 0),
                NVL(x_qty_rcv_exception_code, 'NONE'),
                NULL,
                NULL,
                NULL
         INTO   x_enforce_ship_to_loc_code,
                x_allow_substitute_receipts,
                x_routing_id,
                x_qty_rcv_tolerance,
                x_qty_rcv_exception_code,
                x_days_early_receipt_allowed,
                x_days_late_receipt_allowed,
                x_receipt_days_exception_code
         FROM   DUAL;
      -- All other Line Types
      --
      ELSE
         SELECT NVL(x_enforce_ship_to_loc_code, 'NONE'),
                NVL(x_allow_substitute_receipts, 'N'),
                x_routing_id,
                NVL(x_qty_rcv_tolerance, 0),
                NVL(x_qty_rcv_exception_code, 'NONE'),
                NVL(x_days_early_receipt_allowed, 0),
                NVL(x_days_late_receipt_allowed, 0),
                NVL(x_receipt_days_exception_code, 'NONE')
         INTO   x_enforce_ship_to_loc_code,
                x_allow_substitute_receipts,
                x_routing_id,
                x_qty_rcv_tolerance,
                x_qty_rcv_exception_code,
                x_days_early_receipt_allowed,
                x_days_late_receipt_allowed,
                x_receipt_days_exception_code
         FROM   DUAL;
      END IF;

      -- Drop Shipments
      --
      IF (p_drop_ship_flag = 'Y') THEN
         x_routing_id  := 3;
      END IF;

      /* R12 Complex Work. Bug 4484236.
       * For Complex work POs receipt_routing is always
       * direct delivery. In addition,overreceipt tolerance is 0
       * for the payment_type MILESTONE.
      */

      If (p_payment_type is not null) then
         x_routing_id  := 3;

         If (p_payment_type = 'MILESTONE') then
		x_qty_rcv_tolerance := 0;
	 end if;
      END IF;


      -- Derive Routing Name ====================================================

      IF (x_routing_id IS NOT NULL) THEN
         l_progress  := '120';
         po_debug.debug_stmt(l_log_head,
                             l_progress,
                             'Looking up routing name...'
                            );
         l_progress  := '130';
         po_debug.debug_var(l_log_head,
                            l_progress,
                            'x_routing_id',
                            x_routing_id
                           );

         BEGIN
            SELECT routing_name
            INTO   x_routing_name
            FROM   rcv_routing_headers
            WHERE  routing_header_id = x_routing_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x_routing_name  := NULL;
         END;
      END IF;

--=========================================================================

      l_progress  := '140';
      po_debug.debug_end(l_log_head);
   EXCEPTION
      WHEN OTHERS THEN
         po_debug.debug_exc(l_log_head, l_progress);
         RAISE;
   END get_receiving_controls;

/*===========================================================================

  FUNCTION NAME:  val_unique_receipt_num

===========================================================================*/
   FUNCTION val_unique_receipt_num(
      x_receipt_num IN VARCHAR2
   )
      RETURN BOOLEAN IS
/*
**  Function checks if the receipt number passed in already exists in
**  rcv_shipment_headers.  If is does, then it returns a value of FALSE.  If
**  it doesn't, then it checks if it exists in po_history_receipts.  If it
**  does then it returns a value of FALSE.  If the receipt number doesn't
**  exist in either table, it returns a value of TRUE.
*/
      x_progress VARCHAR2(3) := NULL;
      dup_count  NUMBER      := 0;
   BEGIN
      x_progress  := '010';

      SELECT COUNT(1)
      INTO   dup_count
      FROM   rcv_shipment_headers
      WHERE  receipt_num = x_receipt_num;

      x_progress  := '020';

      IF dup_count <> 0 THEN
         RETURN(FALSE);
      ELSE
         SELECT COUNT(1)
         INTO   dup_count
         FROM   po_history_receipts
         WHERE  receipt_num = x_receipt_num;

         IF dup_count <> 0 THEN
            RETURN(FALSE);
         END IF;
      END IF;

      RETURN(TRUE);
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('val_unique_receipt_num',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END val_unique_receipt_num;

/*===========================================================================

  FUNCTION NAME:  val_unique_shipment_num

===========================================================================*/
   FUNCTION val_unique_shipment_num(
      x_shipment_num IN VARCHAR2,
      x_vendor_id    IN NUMBER
   )
      RETURN BOOLEAN IS
/*
**  Function checks if the shipment number passed in already exists in
**  rcv_shipment_headers for the current vendor.  It returns a value of TRUE
**  if the shipment number passed in is unique, FALSE if it is a duplicate
*/
      x_progress VARCHAR2(3) := NULL;
      dup_count  NUMBER      := 0;
   BEGIN
      x_progress  := '010';

      SELECT COUNT(1)
      INTO   dup_count
      FROM   rcv_shipment_headers
      WHERE  shipment_num = x_shipment_num
      AND    receipt_source_code = 'VENDOR'
      AND    vendor_id = x_vendor_id;

      IF dup_count <> 0 THEN
         RETURN(FALSE);
      ELSE
         RETURN(TRUE);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('val_unique_shipment_num',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END val_unique_shipment_num;

/*===========================================================================

  PROCEDURE NAME: get_ussgl_info

===========================================================================*/
   PROCEDURE get_ussgl_info(
      x_line_location_id IN            NUMBER,
      x_ussgl_trx_code   OUT NOCOPY    VARCHAR2,
      x_govt_context     OUT NOCOPY    VARCHAR2
   ) IS
/*
**  Procedure gets ussgl_transaction_code and government_context from
**  po_line_locations.
*/
      x_progress VARCHAR2(3) := NULL;
   BEGIN
      x_progress  := '010';

      SELECT ussgl_transaction_code,
             government_context
      INTO   x_ussgl_trx_code,
             x_govt_context
      FROM   po_line_locations
      WHERE  line_location_id = x_line_location_id;
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('get_ussgl_info',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END get_ussgl_info;

/*===========================================================================

  PROCEDURE NAME: val_po_shipment

===========================================================================*/
   PROCEDURE val_po_shipment(
      x_trx_type            IN            VARCHAR2,
      x_parent_id           IN            NUMBER,
      x_receipt_source_code IN            VARCHAR2,
      x_parent_trx_type     IN            VARCHAR2,
      x_grand_parent_id     IN            NUMBER,
      x_correction_type     IN            VARCHAR2,
      x_available_quantity  IN OUT NOCOPY NUMBER,
      x_tolerable_qty       IN OUT NOCOPY NUMBER,
      x_uom                 IN OUT NOCOPY VARCHAR2
   ) IS
      x_progress                VARCHAR2(3) := NULL;
/*Bug 1548597 */
      x_secondary_available_qty NUMBER      := 0;
   BEGIN
      x_progress  := '010';
      /*Bug 1548597 */
      rcv_quantities_s.get_available_quantity(x_trx_type,
                                              x_parent_id,
                                              x_receipt_source_code,
                                              x_parent_trx_type,
                                              x_grand_parent_id,
                                              x_correction_type,
                                              x_available_quantity,
                                              x_tolerable_qty,
                                              x_uom,
                                              x_secondary_available_qty
                                             );
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('val_po_shipment',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END val_po_shipment;

/*===========================================================================

  PROCEDURE NAME: val_exp_cas_func

===========================================================================*/
   PROCEDURE val_exp_cas_func IS
      x_progress VARCHAR2(3) := NULL;
   BEGIN
      x_progress  := '010';
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('val_exp_cas_func',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END val_exp_cas_func;

/* ==========================================================================

 PROCEDURE NAME:       PO_DIST_INFO

===========================================================================*/
   PROCEDURE po_dist_info(
      x_po_dist_id                 IN            NUMBER,
      x_wip_entity_id              OUT NOCOPY    NUMBER,
      x_wip_repetitive_schedule_id OUT NOCOPY    NUMBER,
      x_wip_operation_seq_num      OUT NOCOPY    NUMBER,
      x_wip_resource_seq_num       OUT NOCOPY    NUMBER,
      x_wip_line_id                OUT NOCOPY    NUMBER,
      x_bom_resource_id            OUT NOCOPY    NUMBER
   ) IS
      x_progress VARCHAR2(3) := NULL;
   BEGIN
      x_progress  := 10;

      SELECT wip_entity_id,
             wip_operation_seq_num,
             wip_resource_seq_num,
             wip_repetitive_schedule_id,
             wip_line_id,
             bom_resource_id
      INTO   x_wip_entity_id,
             x_wip_operation_seq_num,
             x_wip_resource_seq_num,
             x_wip_repetitive_schedule_id,
             x_wip_line_id,
             x_bom_resource_id
      FROM   po_distributions pod
      WHERE  pod.po_distribution_id = x_po_dist_id;
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('PO_DIST_INFO',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END po_dist_info;

/* ==========================================================================

 PROCEDURE NAME:       get_outside_processing_info

===========================================================================*/
   PROCEDURE get_outside_processing_info(
      x_po_distribution_id   IN            NUMBER,
      x_organization_id      IN            NUMBER,
      x_job_schedule         OUT NOCOPY    VARCHAR2,
      x_operation_seq_num    OUT NOCOPY    VARCHAR2,
      x_department           OUT NOCOPY    VARCHAR2,
      x_wip_line             OUT NOCOPY    VARCHAR2,
      x_bom_resource_id      OUT NOCOPY    NUMBER,
      x_po_operation_seq_num OUT NOCOPY    NUMBER,
      x_po_resource_seq_num  OUT NOCOPY    NUMBER
   ) IS
      x_wip_entity_id              NUMBER(10);
      x_wip_repetitive_schedule_id NUMBER(10);
      x_wip_operation_seq_num      NUMBER(10);
      x_wip_resource_seq_num       NUMBER(10);
      x_wip_line_id                NUMBER(10);
      x_progress                   VARCHAR2(3);
   BEGIN
      /*
      ** The po_operation and resource sequence numbers are off the po
      ** distribution and is used for inserting the transaction rather
      ** than the operation_seq_num which is derived from the wip tables
      ** and shows the next operation rather than the current one.  This
      ** value is used for display purposes
      */
      x_progress              := 10;
      po_dist_info(x_po_distribution_id,
                   x_wip_entity_id,
                   x_wip_repetitive_schedule_id,
                   x_wip_operation_seq_num,
                   x_wip_resource_seq_num,
                   x_wip_line_id,
                   x_bom_resource_id
                  );
      x_po_operation_seq_num  := x_wip_operation_seq_num;
      x_po_resource_seq_num   := x_wip_resource_seq_num;
      x_progress              := 20;
      rcv_core_s.out_op_info(x_wip_entity_id,
                             x_organization_id,
                             x_wip_repetitive_schedule_id,
                             x_wip_operation_seq_num,
                             x_wip_resource_seq_num,
                             x_job_schedule,
                             x_operation_seq_num,
                             x_department
                            );
      x_progress              := 30;

      IF NVL(x_wip_line_id, 0) <> 0 THEN
         rcv_core_s.wip_line_info(x_wip_line_id,
                                  x_organization_id,
                                  x_wip_line
                                 );
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('OUT_INFO',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END get_outside_processing_info;

/* ==========================================================================

 PROCEDURE NAME:       OUT_OP_INFO

===========================================================================*/
   PROCEDURE out_op_info(
      x_wip_entity_id              IN            NUMBER,
      x_organization_id            IN            NUMBER,
      x_wip_repetitive_schedule_id IN            NUMBER,
      x_wip_operation_seq_num      IN            NUMBER,
      x_wip_resource_seq_num       IN            NUMBER,
      x_job_schedule_dsp           OUT NOCOPY    VARCHAR2,
      x_op_seq_num_dsp             OUT NOCOPY    VARCHAR2,
      x_department_code            OUT NOCOPY    VARCHAR2
   ) IS
      x_progress VARCHAR2(3) := NULL;
   BEGIN
      x_progress  := 10;

--Bug# 2000013 togeorge 09/18/2001
--Eam: Split the following sql to 3 different sqls because eAM w/o would
--     not have resource information and this sql will fail.
/*
    select we.wip_entity_name,
           wn.operation_seq_num,
           bd.department_code
    into x_job_schedule_dsp,
         x_op_seq_num_dsp,
         x_department_code
    from wip_entities we,
         bom_departments bd,
         wip_operation_resources wr,
         wip_operations wn,
         wip_operations wo
    where wo.wip_entity_id                 = x_wip_entity_id
    and wo.organization_id                 = x_organization_id
    and nvl(wo.repetitive_schedule_id, -1) =
                                   nvl(x_wip_repetitive_schedule_id, -1)
    and wo.operation_seq_num               = x_wip_operation_seq_num
    and wr.wip_entity_id                   = x_wip_entity_id
    and wr.organization_id                 = x_organization_id
    and nvl(wr.repetitive_schedule_id, -1) =
                                   nvl(x_wip_repetitive_schedule_id, -1)
    and wr.operation_seq_num               = x_wip_operation_seq_num
    and wr.resource_seq_num                = x_wip_resource_seq_num
    and wn.wip_entity_id                   = x_wip_entity_id
    and wn.organization_id                 = x_organization_id
    and nvl(wn.repetitive_schedule_id, -1) =
                                  nvl(x_wip_repetitive_schedule_id, -1)
    and wn.operation_seq_num               = decode(wr.autocharge_type,
                                              4, nvl(wo.next_operation_seq_num,
                                   wo.operation_seq_num),wo.operation_seq_num)
    and bd.department_id                   = wn.department_id
    and we.wip_entity_id                   = x_wip_entity_id
    and we.organization_id                 = x_organization_id ;
*/
      IF x_wip_entity_id IS NOT NULL THEN
         BEGIN
            SELECT we.wip_entity_name job
            INTO   x_job_schedule_dsp
            FROM   wip_entities we
            WHERE  we.wip_entity_id = x_wip_entity_id
            AND    we.organization_id = x_organization_id;
         EXCEPTION
            WHEN OTHERS THEN
               x_job_schedule_dsp  := NULL;
         END;
      END IF;

      IF     x_wip_entity_id IS NOT NULL
         AND x_wip_operation_seq_num IS NOT NULL THEN
         BEGIN
            SELECT wn.operation_seq_num SEQUENCE,
                   bd.department_code department
            INTO   x_op_seq_num_dsp,
                   x_department_code
            FROM   bom_departments bd,
                   wip_operation_resources wr,
                   wip_operations wn,
                   wip_operations wo
            WHERE  wo.wip_entity_id = x_wip_entity_id
            AND    wo.organization_id = x_organization_id
            AND    NVL(wo.repetitive_schedule_id, -1) = NVL(x_wip_repetitive_schedule_id, -1)
            AND    wo.operation_seq_num = x_wip_operation_seq_num
            AND    wr.wip_entity_id = x_wip_entity_id
            AND    wr.organization_id = x_organization_id
            AND    NVL(wr.repetitive_schedule_id, -1) = NVL(x_wip_repetitive_schedule_id, -1)
            AND    wr.operation_seq_num = x_wip_operation_seq_num
            AND    wr.resource_seq_num = x_wip_resource_seq_num
            AND    wn.wip_entity_id = x_wip_entity_id
            AND    wn.organization_id = x_organization_id
            AND    NVL(wn.repetitive_schedule_id, -1) = NVL(x_wip_repetitive_schedule_id, -1)
            AND    wn.operation_seq_num = DECODE(wr.autocharge_type,
                                                 4, NVL(wo.next_operation_seq_num, wo.operation_seq_num),
                                                 wo.operation_seq_num
                                                )
            AND    bd.department_id = wn.department_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               --for EAM workorders the above sql would raise no_data_found.
               --find department code and sequence with out touching resource table.
               BEGIN
                  SELECT bd.department_code department
                  INTO   x_department_code
                  FROM   bom_departments bd,
                         wip_operations wn
                  WHERE  wn.wip_entity_id = x_wip_entity_id
                  AND    wn.organization_id = x_organization_id
                  AND    NVL(wn.repetitive_schedule_id, -1) = NVL(x_wip_repetitive_schedule_id, -1)
                  AND    bd.department_id = wn.department_id;
               EXCEPTION
                  WHEN OTHERS THEN
                     x_department_code  := NULL;
               END;

               BEGIN
                  SELECT wo.operation_seq_num SEQUENCE
                  INTO   x_op_seq_num_dsp
                  FROM   wip_operations wo
                  WHERE  wo.wip_entity_id = x_wip_entity_id
                  AND    wo.organization_id = x_organization_id
                  AND    NVL(wo.repetitive_schedule_id, -1) = NVL(x_wip_repetitive_schedule_id, -1)
                  AND    wo.operation_seq_num = x_wip_operation_seq_num;
               EXCEPTION
                  WHEN OTHERS THEN
                     x_op_seq_num_dsp  := NULL;
               END;
            WHEN OTHERS THEN
               x_op_seq_num_dsp   := NULL;
               x_department_code  := NULL;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('OUT_OP_INFO',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END out_op_info;

/* ==========================================================================

 PROCEDURE NAME:       WIP_LINE_INFO

===========================================================================*/
   PROCEDURE wip_line_info(
      x_wip_line_id  IN            NUMBER,
      x_org_id       IN            NUMBER,
      x_wip_line_dsp OUT NOCOPY    VARCHAR2
   ) IS
      x_progress VARCHAR2(3) := NULL;
   BEGIN
      x_progress  := 10;

      SELECT wl.line_code
      INTO   x_wip_line_dsp
      FROM   wip_lines wl
      WHERE  wl.organization_id = x_org_id
      AND    wl.line_id = x_wip_line_id;
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('WIP_LINE_INFO',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END wip_line_info;

/* ==========================================================================

 FUNCTION NAME:       note_info

===========================================================================*/
   FUNCTION note_info(
      x_note_attribute   VARCHAR2,
      x_note_table_name  VARCHAR2,
      x_note_column_name VARCHAR2,
      x_foreign_id       NUMBER
   )
      RETURN NUMBER IS
      x_progress   VARCHAR2(3) := NULL;
      x_note_count NUMBER;
   BEGIN
      x_progress  := 10;

      SELECT COUNT(pon.po_note_id)
      INTO   x_note_count
      FROM   po_note_references ponr,
             po_notes pon,
             po_usage_attributes poua
      WHERE  ponr.po_note_id = pon.po_note_id
      AND    pon.usage_id = poua.usage_id
      AND    poua.note_attribute = x_note_attribute
      AND    ponr.table_name = x_note_table_name
      AND    ponr.column_name = x_note_column_name
      AND    ponr.foreign_id = x_foreign_id;

      RETURN(x_note_count);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
         RETURN(0);
      WHEN OTHERS THEN
         po_message_s.sql_error('NOTE_INFO',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END note_info;

/* ==========================================================================

 FUNCTION NAME:       get_note_count

===========================================================================*/
   FUNCTION get_note_count(
      x_header_id     IN NUMBER,
      x_line_id       IN NUMBER,
      x_location_id   IN NUMBER,
      x_po_line_id    IN NUMBER,
      x_po_release_id IN NUMBER,
      x_po_header_id  IN NUMBER,
      x_item_id       IN NUMBER
   )
      RETURN NUMBER IS
      x_progress     VARCHAR2(3) := NULL;
      x_ret_note_cnt NUMBER;
   BEGIN
      x_progress      := 10;
      x_ret_note_cnt  := note_info('RVCRC',
                                   'RCV_SHIPMENT_HEADERS',
                                   'SHIPMENT_HEADER_ID',
                                   x_header_id
                                  );

      IF x_ret_note_cnt > 0 THEN
         RETURN(x_ret_note_cnt);
      END IF;

      x_progress      := 20;
      x_ret_note_cnt  := note_info('RVCRC',
                                   'RCV_SHIPMENT_LINES',
                                   'SHIPMENT_LINE_ID',
                                   x_line_id
                                  );

      IF x_ret_note_cnt > 0 THEN
         RETURN(x_ret_note_cnt);
      END IF;

      x_progress      := 30;
      x_ret_note_cnt  := note_info('RVCRC',
                                   'PO_LINE_LOCATIONS',
                                   'LINE_LOCATION_ID',
                                   x_location_id
                                  );

      IF x_ret_note_cnt > 0 THEN
         RETURN(x_ret_note_cnt);
      END IF;

      x_progress      := 40;
      x_ret_note_cnt  := note_info('RVCRC',
                                   'PO_LINES',
                                   'PO_LINE_ID',
                                   x_po_line_id
                                  );

      IF x_ret_note_cnt > 0 THEN
         RETURN(x_ret_note_cnt);
      END IF;

      x_progress      := 50;
      x_ret_note_cnt  := note_info('RVCRC',
                                   'PO_RELEASES',
                                   'PO_RELEASE_ID',
                                   x_po_release_id
                                  );

      IF x_ret_note_cnt > 0 THEN
         RETURN(x_ret_note_cnt);
      END IF;

      x_progress      := 60;
      x_ret_note_cnt  := note_info('RVCRC',
                                   'PO_HEADERS',
                                   'PO_HEADER_ID',
                                   x_po_header_id
                                  );

      IF x_ret_note_cnt > 0 THEN
         RETURN(x_ret_note_cnt);
      END IF;

      x_progress      := 70;
      x_ret_note_cnt  := note_info('ITMIT',
                                   'MTL_SYSTEM_ITEMS',
                                   'INVENTORY_ITEM_ID',
                                   x_item_id
                                  );
      RETURN(x_ret_note_cnt);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
         RETURN(0);
      WHEN OTHERS THEN
         po_message_s.sql_error('NOTE',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END get_note_count;

/* ==========================================================================

 PROCEDURE NAME:       DERIVE_SHIPMENT_INFO

===========================================================================*/
   PROCEDURE derive_shipment_info(
      x_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
   ) IS
   BEGIN
      IF x_header_record.header_record.receipt_header_id IS NOT NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Need to put a cursor to retrieve other values');
            asn_debug.put_line('Shipment header Id has been provided');
         END IF;

         RETURN;
      END IF;

      -- Check that the shipment_num is not null

      IF (   x_header_record.header_record.shipment_num IS NULL
          OR x_header_record.header_record.shipment_num = '0'
          OR REPLACE(x_header_record.header_record.shipment_num,
                     ' ',
                     ''
                    ) IS NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Cannot derive the shipment_header_id at this point');
         END IF;

         RETURN;
      END IF;

      -- Derive the shipment_header_id only for transaction_type = CANCEL

      /*
  * BUGNO: 1708017
  * The where clause used to have organization_id =
  * X_header_record.header_record.ship_to_organization_id
  * This used to be populated with ship_to_organization_id.
  * Now this is populated as null since it is supposed to
  * be from organization_id. So changed it to ship_to_org_id.
 */
      IF     x_header_record.header_record.transaction_type = 'CANCEL'
         AND x_header_record.header_record.receipt_header_id IS NULL THEN
         BEGIN
            SELECT MAX(shipment_header_id) -- if we ever have 2 shipments with the same combo
            INTO   x_header_record.header_record.receipt_header_id
            FROM   rcv_shipment_headers
            WHERE  NVL(vendor_site_id, -9999) = NVL(x_header_record.header_record.vendor_site_id, -9999)
            AND    vendor_id = x_header_record.header_record.vendor_id
            AND    ship_to_org_id = x_header_record.header_record.ship_to_organization_id
            AND    shipment_num = x_header_record.header_record.shipment_num
            AND    shipped_date >= ADD_MONTHS(x_header_record.header_record.shipped_date, -12);
         EXCEPTION
            WHEN OTHERS THEN
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line(SQLERRM);
               END IF;
         END;

         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('derive_shipment_info', '000');
         x_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         x_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END derive_shipment_info;

/* ==========================================================================

 PROCEDURE NAME:       DEFAULT_SHIPMENT_INFO

===========================================================================*/
   PROCEDURE default_shipment_info(
      x_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
   ) IS
      x_count NUMBER;
   BEGIN
      -- no need to derive shipment_header_id if it is already provided

      IF x_header_record.header_record.receipt_header_id IS NOT NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Shipment header Id has been provided');
         END IF;

         RETURN;
      END IF;

      -- Check for shipment number which is null, blank , zero

      IF     x_header_record.header_record.asn_type IN('ASN', 'ASBN')
         AND (   x_header_record.header_record.shipment_num IS NULL
              OR x_header_record.header_record.shipment_num = '0'
              OR REPLACE(x_header_record.header_record.shipment_num,
                         ' ',
                         ''
                        ) IS NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Shipment num is still null');
         END IF;

         RETURN;
      END IF;

      -- Derive the shipment_header_id based on the shipment_num for transaction_type = CANCEL

      /*
  * BUGNO: 1708017
  * The where clause used to have organization_id =
  * X_header_record.header_record.ship_to_organization_id
  * This used to be populated with ship_to_organization_id.
  * Now this is populated as null since it is supposed to
  * be from organization_id. So changed it to ship_to_org_id.
 */
      IF     x_header_record.header_record.transaction_type = 'CANCEL'
         AND x_header_record.header_record.receipt_header_id IS NULL THEN
         BEGIN
            SELECT MAX(shipment_header_id) -- if we ever have 2 shipments with the same combo
            INTO   x_header_record.header_record.receipt_header_id
            FROM   rcv_shipment_headers
            WHERE  NVL(vendor_site_id, -9999) = NVL(x_header_record.header_record.vendor_site_id, -9999)
            AND    vendor_id = x_header_record.header_record.vendor_id
            AND    ship_to_org_id = x_header_record.header_record.ship_to_organization_id
            AND    shipment_num = x_header_record.header_record.shipment_num
            AND    shipped_date >= ADD_MONTHS(x_header_record.header_record.shipped_date, -12);
         EXCEPTION
            WHEN OTHERS THEN
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line(SQLERRM);
               END IF;
         END;

         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('default_shipment_info', '000');
         x_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         x_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END default_shipment_info;

/* ==========================================================================

 PROCEDURE NAME:       VALIDATE_SHIPMENT_NUMBER

===========================================================================*/
   PROCEDURE validate_shipment_number(
      x_header_record IN OUT NOCOPY rcv_shipment_header_sv.headerrectype
   ) IS
      x_count              NUMBER;
      x_shipment_header_id NUMBER; -- added for cancel process
      x_sysdate            DATE   := SYSDATE;
   BEGIN
      -- Check for shipment number which is null, blank , zero
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Check for shipment number which is null, blank , zero ');
      END IF;

      /*dbms_output.put_line(nvl(X_header_record.header_record.shipment_num,'@@@'));*/
      IF     x_header_record.header_record.asn_type IN('ASN', 'ASBN')
         AND (   x_header_record.header_record.shipment_num IS NULL
              OR x_header_record.header_record.shipment_num = '0'
              OR REPLACE(x_header_record.header_record.shipment_num,
                         ' ',
                         ''
                        ) IS NULL) THEN
         /*dbms_output.put_line(X_header_record.header_record.asn_type);
         dbms_output.put_line(X_header_record.header_record.shipment_num);*/
         rcv_error_pkg.set_error_message('RCV_NO_SHIPMENT_NUM');
         RAISE e_validation_error;
      END IF;

      -- Check for Receipts before ASN

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Check for Receipts before ASN ');
      END IF;

        /*
    * BUGNO: 1708017
    * The where clause used to have organization_id =
    * X_header_record.header_record.ship_to_organization_id
    * This used to be populated with ship_to_organization_id.
    * Now this is populated as null since it is supposed to
    * be from organization_id. So changed it to ship_to_org_id.
   */
/* Bug 2485699- commented the condn trunc(Shipped_date) = trunc(header.record.shipped_date).
   Added  the shipped date is null since we are not populating the same in rcv_shipment_headers
     while receiving thru forms.*/
      IF     x_header_record.header_record.asn_type IN('ASN', 'ASBN')
         AND x_header_record.header_record.transaction_type <> 'CANCEL' THEN -- added this for CANCEL
         SELECT COUNT(*)
         INTO   x_count
         FROM   rcv_shipment_headers
         WHERE  NVL(vendor_site_id, -9999) = NVL(x_header_record.header_record.vendor_site_id, -9999)
         AND    vendor_id = x_header_record.header_record.vendor_id
         AND --trunc(shipped_date) = trunc(X_header_record.header_record.shipped_date) and
                (   shipped_date IS NULL
                 OR shipped_date >= ADD_MONTHS(x_sysdate, -12))
         AND    shipment_num = x_header_record.header_record.shipment_num
         AND    ship_to_org_id = x_header_record.header_record.ship_to_organization_id
         AND    receipt_num IS NOT NULL;

         IF x_count > 0 THEN
            rcv_error_pkg.set_error_message('RCV_RCV_BEFORE_ASN');
            rcv_error_pkg.set_token('SHIPMENT', x_header_record.header_record.shipment_num);
            rcv_error_pkg.set_token('ITEM', ' ');
            RAISE e_validation_error;
         END IF;
      END IF;

      -- Change transaction_type to NEW if transaction_type is REPLACE and
      -- we cannot locate the shipment notice for the vendor site with the
      -- same shipped date
             /*
        * BUGNO: 1708017
        * The where clause used to have organization_id =
        * X_header_record.header_record.ship_to_organization_id
        * This used to be populated with ship_to_organization_id.
        * Now this is populated as null since it is supposed to
        * be from organization_id. So changed it to ship_to_org_id.
       */
      IF x_header_record.header_record.transaction_type = 'REPLACE' THEN
         SELECT COUNT(*)
         INTO   x_count
         FROM   rcv_shipment_headers
         WHERE  NVL(vendor_site_id, -9999) = NVL(x_header_record.header_record.vendor_site_id, -9999)
         AND    vendor_id = x_header_record.header_record.vendor_id
         AND    TRUNC(shipped_date) = TRUNC(x_header_record.header_record.shipped_date)
         AND    shipped_date >= ADD_MONTHS(x_sysdate, -12)
         AND    ship_to_org_id = x_header_record.header_record.ship_to_organization_id
         AND    shipment_num = x_header_record.header_record.shipment_num;

         IF x_count = 0 THEN
            x_header_record.header_record.transaction_type  := 'NEW';
         END IF;
      END IF;

      -- Check for any shipment_num which exist for the same vendor site and within a year
      -- of the previous shipment with the same num. This is only done for transaction_type = NEW

      /*
   * BUGNO: 1708017
   * The where clause used to have organization_id =
   * X_header_record.header_record.ship_to_organization_id
   * This used to be populated with ship_to_organization_id.
   * Now this is populated as null since it is supposed to
   * be from organization_id. So changed it to ship_to_org_id.
  */

      /* Fix for bug 2682881.
       * No validation on shipment_num was happening if a new ASN
       * is created with the same supplier,supplier site, shipment
       * num, but with different shipped_date. Shipment_num should
       * be unique from the supplier,supplier site for a period of
       * one year. Hence commented the condition "trunc(shipped_date)
       * = trunc(X_header_record.header_record.shipped_date) and"
       * from the following sql which is not required.
      */
      IF     x_header_record.header_record.transaction_type = 'NEW'
         AND x_header_record.header_record.asn_type IN('ASN', 'ASBN') THEN
         SELECT COUNT(*)
         INTO   x_count
         FROM   rcv_shipment_headers
         WHERE  NVL(vendor_site_id, -9999) = NVL(x_header_record.header_record.vendor_site_id, -9999)
         AND    vendor_id = x_header_record.header_record.vendor_id
         AND    ship_to_org_id = x_header_record.header_record.ship_to_organization_id
         AND    shipment_num = x_header_record.header_record.shipment_num
         AND --trunc(shipped_date) = trunc(X_header_record.header_record.shipped_date) and
                shipped_date >= ADD_MONTHS(x_sysdate, -12);

         IF x_count > 0 THEN
/* Bug# 1413880
   As per the manual Shipment number should be unique for one year period for
   given supplier.Changing Warning to Error.  */
            rcv_error_pkg.set_error_message('PO_PDOI_SHIPMENT_NUM_UNIQUE');
            rcv_error_pkg.set_token('VALUE', x_header_record.header_record.shipment_num);
            RAISE e_validation_error;
         END IF;
      END IF;

      /*bug 2123721. bgopired
      We were not checking the uniqueness of shipment number incase of
      Standard Receipts. Used the same logic of Enter Receipt form to check
      the uniqueness */
      IF     x_header_record.header_record.transaction_type = 'NEW'
         AND x_header_record.header_record.asn_type IN('STD') THEN
         IF NOT val_unique_shipment_num(x_header_record.header_record.shipment_num, x_header_record.header_record.vendor_id) THEN
            rcv_error_pkg.set_error_message('PO_PDOI_SHIPMENT_NUM_UNIQUE');
            rcv_error_pkg.set_token('VALUE', x_header_record.header_record.shipment_num);
            RAISE e_validation_error;
         END IF;
      END IF;

      -- Check for matching ASN if ADD, CANCEL
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Check for matching ASN if ADD, CANCEL');
      END IF;

      /*
  * BUGNO: 1708017
  * The where clause used to have organization_id =
  * X_header_record.header_record.ship_to_organization_id
  * This used to be populated with ship_to_organization_id.
  * Now this is populated as null since it is supposed to
  * be from organization_id. So changed it to ship_to_org_id.
 */
      IF     x_header_record.header_record.transaction_type IN('ADD', 'CANCEL')
         AND x_header_record.header_record.asn_type IN('ASN', 'ASBN') THEN
         SELECT COUNT(*)
         INTO   x_count
         FROM   rcv_shipment_headers
         WHERE  NVL(vendor_site_id, -9999) = NVL(x_header_record.header_record.vendor_site_id, -9999)
         AND    vendor_id = x_header_record.header_record.vendor_id
         AND    ship_to_org_id = x_header_record.header_record.ship_to_organization_id
         AND    shipment_num = x_header_record.header_record.shipment_num
         AND    TRUNC(shipped_date) = TRUNC(x_header_record.header_record.shipped_date)
         AND    shipped_date >= ADD_MONTHS(x_sysdate, -12);

         IF x_count = 0 THEN
            rcv_error_pkg.set_error_message('RCV_NO_MATCHING_ASN');
            rcv_error_pkg.set_token('SHIPMENT', x_header_record.header_record.shipment_num);
            RAISE e_validation_error;
         END IF;
      END IF;

      -- Check that there are no receipts against the ASN for ADD, CANCEL
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Check that there are no receipts against the ASN for ADD, CANCEL');
      END IF;

      IF     x_header_record.header_record.transaction_type IN('ADD', 'CANCEL')
         AND x_header_record.header_record.asn_type IN('ASN', 'ASBN') THEN
         IF x_header_record.header_record.receipt_header_id IS NOT NULL THEN
            SELECT SUM(quantity_received)
            INTO   x_count
            FROM   rcv_shipment_lines
            WHERE  rcv_shipment_lines.shipment_header_id = x_header_record.header_record.receipt_header_id;
         ELSE
            /*
       * BUGNO: 1708017
       * The where clause used to have organization_id =
       * X_header_record.header_record.ship_to_organization_id
       * This used to be populated with ship_to_organization_id.
       * Now this is populated as null since it is supposed to
       * be from organization_id. So changed it to ship_to_org_id.
      */
            SELECT SUM(quantity_received)
            INTO   x_count
            FROM   rcv_shipment_lines
            WHERE  EXISTS(SELECT 'x'
                          FROM   rcv_shipment_headers
                          WHERE  rcv_shipment_headers.shipment_header_id = rcv_shipment_lines.shipment_header_id
                          AND    NVL(vendor_site_id, -9999) = NVL(x_header_record.header_record.vendor_site_id, -9999)
                          AND    vendor_id = x_header_record.header_record.vendor_id
                          AND    ship_to_org_id = x_header_record.header_record.ship_to_organization_id
                          AND    shipment_num = x_header_record.header_record.shipment_num
                          AND    TRUNC(shipped_date) = TRUNC(x_header_record.header_record.shipped_date)
                          AND    shipped_date >= ADD_MONTHS(x_sysdate, -12));
         END IF;

         IF NVL(x_count, 0) > 0 THEN -- Some quantity has been received
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('There are receipts against the ASN ' || x_header_record.header_record.shipment_num);
            END IF;

            rcv_error_pkg.set_error_message('RCV_ASN_QTY_RECEIVED');
            rcv_error_pkg.set_token('SHIPMENT', x_header_record.header_record.shipment_num);
            RAISE e_validation_error;
         END IF;
      END IF;

      -- If we have reached this place that means the shipment exists
      -- Make sure we have a shipment header id

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Make sure we have a shipment_header_id');
      END IF;

      /*
  * BUGNO: 1708017
  * The where clause used to have organization_id =
  * X_header_record.header_record.ship_to_organization_id
  * This used to be populated with ship_to_organization_id.
  * Now this is populated as null since it is supposed to
  * be from organization_id. So changed it to ship_to_org_id.
 */
      IF     x_header_record.header_record.transaction_type IN('CANCEL')
         AND x_header_record.header_record.receipt_header_id IS NULL THEN
         SELECT MAX(shipment_header_id)
         INTO   x_header_record.header_record.receipt_header_id
         FROM   rcv_shipment_headers
         WHERE  NVL(vendor_site_id, -9999) = NVL(x_header_record.header_record.vendor_site_id, -9999)
         AND    vendor_id = x_header_record.header_record.vendor_id
         AND    ship_to_org_id = x_header_record.header_record.ship_to_organization_id
         AND    shipment_num = x_header_record.header_record.shipment_num
         AND    TRUNC(shipped_date) = TRUNC(x_header_record.header_record.shipped_date)
         AND    shipped_date >= ADD_MONTHS(x_sysdate, -12);
      END IF;

      -- Verify that the shipment_header_id matches the derived/defaulted shipment_header_id

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Verify that the shipment_header_id matches the derived/defaulted shipment_header_id');
      END IF;

      /*
   * BUGNO: 1708017
   * The where clause used to have organization_id =
   * X_header_record.header_record.ship_to_organization_id
   * This used to be populated with ship_to_organization_id.
   * Now this is populated as null since it is supposed to
   * be from organization_id. So changed it to ship_to_org_id.
  */
      IF     x_header_record.header_record.transaction_type IN('CANCEL')
         AND x_header_record.header_record.receipt_header_id IS NOT NULL THEN
         SELECT MAX(shipment_header_id)
         INTO   x_shipment_header_id
         FROM   rcv_shipment_headers
         WHERE  NVL(vendor_site_id, -9999) = NVL(x_header_record.header_record.vendor_site_id, -9999)
         AND    vendor_id = x_header_record.header_record.vendor_id
         AND    ship_to_org_id = x_header_record.header_record.ship_to_organization_id
         AND    shipment_num = x_header_record.header_record.shipment_num
         AND    TRUNC(shipped_date) = TRUNC(x_header_record.header_record.shipped_date)
         AND    shipped_date >= ADD_MONTHS(x_sysdate, -12);

         IF x_shipment_header_id <> x_header_record.header_record.receipt_header_id THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('The shipment_header_id do not match ');
            END IF;

            rcv_error_pkg.set_error_message('RCV_ASN_MISMATCH_SHIP_ID');
            rcv_error_pkg.set_token('SHIPMENT', x_header_record.header_record.shipment_num);
            RAISE e_validation_error;
         END IF;
      END IF;
   EXCEPTION
      WHEN e_validation_error THEN
         x_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_error;
         x_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;
      WHEN OTHERS THEN
         rcv_error_pkg.set_sql_error_message('validate_shipment_number', '000');
         x_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         x_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END validate_shipment_number;
END rcv_core_s;

/
