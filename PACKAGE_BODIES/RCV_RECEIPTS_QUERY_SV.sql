--------------------------------------------------------
--  DDL for Package Body RCV_RECEIPTS_QUERY_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_RECEIPTS_QUERY_SV" AS
/* $Header: RCVRCPQB.pls 120.2.12010000.4 2010/01/29 02:48:19 jastang ship $*/

/*===========================================================================

  PROCEDURE NAME: post_query()

===========================================================================*/
/* Note: This package has been overloaded as a bug fix of 2730828 */

/* Bug# 1942953 - Added x_from_org_id as a new parameter in the POST_QUERY */

PROCEDURE  POST_QUERY (  x_line_location_id      IN NUMBER,
          x_shipment_line_id      IN NUMBER,
                         x_receipt_source_code           IN VARCHAR2,
                         x_org_id                        IN NUMBER,
          x_item_id         IN NUMBER,
          x_unit_of_measure_class    IN VARCHAR2,
          x_ship_to_location_id      IN NUMBER,
          x_vendor_id                   IN NUMBER,
          x_customer_id              IN NUMBER,
          x_item_rev_control_flag_to    IN VARCHAR2,
                         x_available_qty                 IN OUT NOCOPY NUMBER,
                         x_primary_qty        IN OUT NOCOPY NUMBER,
          x_tolerable_qty           IN OUT NOCOPY NUMBER,
                         x_uom                       IN OUT NOCOPY VARCHAR2,
          x_primary_uom        IN OUT NOCOPY VARCHAR2,
          x_valid_ship_to_location   IN OUT NOCOPY BOOLEAN,
             x_num_of_distributions     IN OUT NOCOPY NUMBER,
             x_po_distributions_id      IN OUT NOCOPY NUMBER,
             x_destination_type_code    IN OUT NOCOPY VARCHAR2,
             x_destination_type_dsp     IN OUT NOCOPY VARCHAR2,
             x_deliver_to_location_id   IN OUT NOCOPY NUMBER,
             x_deliver_to_location      IN OUT NOCOPY VARCHAR2,
             x_deliver_to_person_id     IN OUT NOCOPY NUMBER,
             x_deliver_to_person     IN OUT NOCOPY VARCHAR2,
             x_deliver_to_sub     IN OUT NOCOPY VARCHAR2,
             x_deliver_to_locator_id    IN OUT NOCOPY NUMBER,
             x_wip_entity_id                 IN OUT NOCOPY NUMBER,
             x_wip_repetitive_schedule_id    IN OUT NOCOPY NUMBER,
             x_wip_line_id                    IN OUT NOCOPY NUMBER,
             x_wip_operation_seq_num          IN OUT NOCOPY NUMBER,
             x_wip_resource_seq_num           IN OUT NOCOPY NUMBER,
             x_bom_resource_id                IN OUT NOCOPY NUMBER,
             x_to_organization_id             IN OUT NOCOPY NUMBER,
             x_job                            IN OUT NOCOPY VARCHAR2,
             x_line_num                       IN OUT NOCOPY VARCHAR2,
             x_sequence                       IN OUT NOCOPY NUMBER,
             x_department                     IN OUT NOCOPY VARCHAR2,
          x_enforce_ship_to_loc      IN OUT NOCOPY VARCHAR2,
          x_allow_substitutes        IN OUT NOCOPY VARCHAR2,
          x_routing_id               IN OUT NOCOPY NUMBER,
          x_qty_rcv_tolerance        IN OUT NOCOPY NUMBER,
          x_qty_rcv_exception        IN OUT NOCOPY VARCHAR2,
          x_days_early_receipt       IN OUT NOCOPY NUMBER,
          x_days_late_receipt        IN OUT NOCOPY NUMBER,
          x_rcv_days_exception       IN OUT NOCOPY VARCHAR2,
          x_item_revision      IN OUT NOCOPY VARCHAR2,
          x_locator_control       IN OUT NOCOPY NUMBER,
          x_inv_destinations      IN OUT NOCOPY BOOLEAN,
                         x_rate                          IN OUT NOCOPY NUMBER,
                         x_rate_date                     IN OUT NOCOPY DATE,
                         x_asn_type                      IN     VARCHAR2,
          x_oe_order_header_id       IN     NUMBER,
          x_oe_order_line_id      IN     NUMBER,
                         x_from_org_id                   IN NUMBER DEFAULT NULL,
-- <RCV ENH FPI START>
                         x_kanban_card_number         OUT NOCOPY VARCHAR2,
                         x_project_number             OUT NOCOPY VARCHAR2,
                         x_task_number                OUT NOCOPY VARCHAR2,
                         x_charge_account             OUT NOCOPY VARCHAR2
-- <RCV ENH FPI END>
   ) IS

   x_progress          VARCHAR2(3) := '010';
   p_rev_exists      BOOLEAN := FALSE;
   x_success      BOOLEAN := FALSE;
   /*
   ** This is strickly a throwaway argument for some of these calls.  They
   ** should not be using the _kfv to return this value
   */
   x_deliver_to_locator         VARCHAR2(1000) := NULL;
   x_default_subinventory       VARCHAR2(10);
   X_default_locator_id         NUMBER;
/*Bug 2675920 Added the following variables*/
   X_cancel_qty                 NUMBER :=0;  --- primary uom
   X_cancel_qty_po_uom          NUMBER :=0;
   primary_uom                  VARCHAR2(26);

   X_quantity_shipped           NUMBER :=0;   -- ASN Phase 2
   X_quantity_returned          NUMBER :=0;   -- ASN Phase 2
   X_available_qty_hold    NUMBER :=0;   -- ASN Phase 2
   X_ship_qty_in_int    NUMBER :=0;   -- ASN Phase 2 bug 623925
   X_uom_hold        VARCHAR2(26); -- 661871 change length to 26 chars
   x_req_distribution_id   number ;    --Bug 1205660
   X_project_id                 NUMBER ;   -- Bug 1662321
   X_task_id         NUMBER ;   -- Bug 1662321

   /* Bug# 1548597 */
   X_secondary_available_qty  NUMBER := 0;

   /* Bug# 3672978 */
     /* Bug# 3680886 : Removed the initialization to zero for X_ms_routing_id  */
   X_ms_routing_id           NUMBER;

-- <RCV ENH FPI START>
   l_code_combination_id PO_DISTRIBUTIONS.code_combination_id%TYPE;
-- <RCV ENH FPI END>
   x_subinv  VARCHAR2 (60); -- bug 9298154
BEGIN
      X_progress := '010';

-- <RCV ENH FPI>
-- No Need to initialize x_job
      -- x_job := 'GVQ';

      /* Go get the quanity to show as available and the total they
      ** can receive.  Make sure to check what type of transaction you're
      ** attempting to fetch the quantity for.
      */
      IF nvl(x_asn_type,'STD') NOT IN  ('ASN','ASBN','LCM') THEN    -- ASN Phase 2 -- lcm changes
         IF (x_receipt_source_code = 'VENDOR') THEN

       /* Bug# 1548597 */
            rcv_quantities_s.get_available_quantity ('RECEIVE',
                x_line_location_id,
                'VENDOR', NULL, NULL, NULL, x_available_qty,
                x_tolerable_qty, x_uom, X_secondary_available_qty);

           -- Added this for ASN Phase 2 to account for shipped_quantity

            select nvl(quantity_shipped,0)
            into X_quantity_shipped
            from po_line_locations
            where
              line_location_id = x_line_location_id;

/*Bug 2675920 When an ASN is cancelled from Manageshipments form in Batch mode and
  if the record with transaction type as 'CANCEL' is existing in rti with pending
  status then we are restricting the user to query that ASN in Enter Receipts form
  Modifications done in poxrcv.odf. But at the sametime we need to adjust the quantity
  inorder to display correct transaction quantity for non ASN line when quried by PO number
  in Enter receipts form. Hence we are reducing the quantity shipped by the
  sum(cancelled ASN Quantity) in rti so that x_available_qty is determined correctly. */


        SELECT nvl(sum(primary_quantity),0),
               decode(min(item_id),null,min(unit_of_measure),min(primary_unit_of_measure))
        INTO   x_cancel_qty,
               primary_uom
        FROM   rcv_transactions_interface
        WHERE  transaction_status_code = 'PENDING'
        AND    transaction_type = 'CANCEL'
        AND    po_line_location_id = x_line_location_id;
       if (x_cancel_qty = 0) then
              x_cancel_qty_po_uom := 0;
       else
            if (x_uom <> primary_uom) then
              po_uom_s.uom_convert(x_cancel_qty, primary_uom, x_item_id,
                                   x_uom, x_cancel_qty_po_uom);
            else
                x_cancel_qty_po_uom := x_cancel_qty;
            end if;
       end if;
           X_quantity_shipped := X_quantity_shipped - x_cancel_qty_po_uom;

            IF X_quantity_shipped > 0 then

               x_available_qty := x_available_qty - X_quantity_shipped;
               x_tolerable_qty := x_tolerable_qty - X_quantity_shipped;

               If x_available_qty < 0 THEN
                  x_available_qty := 0;
               end if;

               IF x_tolerable_qty < 0 THEN
                  x_tolerable_qty := 0;
               end if;

            END IF;

    ELSIF (x_receipt_source_code = 'CUSTOMER') THEN

/*
   For use if we need to account for pending transactions in the interface
   table.
*/
      /* Bug# 1548597 */
            rcv_quantities_s.get_available_rma_quantity('RECEIVE',
                     null,
                     'CUSTOMER',
                     null,null,null,
                              x_oe_order_header_id,
                     x_oe_order_line_id,
                              x_available_qty,
                              x_tolerable_qty,
                     x_uom,
                     X_secondary_available_qty);

         ELSE    -- INTERNAL
             /* Bug# 1548597 */
            rcv_quantities_s.get_available_quantity ('RECEIVE',
                x_shipment_line_id,
                'INVENTORY', NULL, NULL, NULL, x_available_qty,
                x_tolerable_qty, x_uom, X_secondary_available_qty);

                /*  If it is an ASN/ASBN we cannot overreceive

                     x_tolerable_qty := x_available_qty;  -- ASN Phase 2 */

         END IF;


      ELSE

      /*
           ** If ASN, ASBN then we need to return the available qty
      ** from rcv_shipment_lines. Faking the call to make it look
      ** like an internal transfer so the code changes are
      ** minimal and making use of existing API
      */
      /* Bug# 1548597 */
           rcv_quantities_s.get_available_quantity ('RECEIVE',
                x_shipment_line_id,
                'INVENTORY', NULL, NULL, NULL, x_available_qty,
                x_tolerable_qty, x_uom, X_secondary_available_qty);

       /*
       ** Now get the tolerable quantity based on the available amount
            ** on the shipment.  The beta users wanted to be able to
       ** receive more than what was stated on the asn since it all
            ** gets applied to the shipment line as receipt quantity anyway.
            */
            /* Bug# 1548597 */
            rcv_quantities_s.get_available_quantity ('RECEIVE',
                x_line_location_id,
                'VENDOR', NULL, NULL, NULL, x_available_qty_hold,
                x_tolerable_qty, x_uom_hold, X_secondary_available_qty);

           -- Added this for ASN Phase 2 to account for shipped_quantity
            select nvl(quantity_shipped,0)
            into X_quantity_shipped
            from po_line_locations
            where
              line_location_id = x_line_location_id;

       /*
       ** Adjust only the tolerable quantity here since this is an
       ** ASN line and will display the quantity shipped
       */
            IF X_quantity_shipped > 0 then

               /* bug 623925
               /* if we are in this condition, that means we have ASN shipment against a PO shipment,
                  the x_tolerable_qty has been subtracted by all pending qty in RTI against this PO shipment
                  the x_available_qty has been subtracted by all pending qty in RTI against this ASN shipment
                  there can be potential double counting, we need to add qty that are both
                  against the PO shipment and ASN shipment in RTI, this would only happen when we are using
        BATCH mode */

               rcv_quantities_s.get_ship_qty_in_int(x_shipment_line_id, x_line_location_id, x_ship_qty_in_int);

               /* the real tolerable qty should be as follows */

               x_tolerable_qty := x_tolerable_qty - X_quantity_shipped + x_available_qty + x_ship_qty_in_int ;

               IF x_tolerable_qty < 0 THEN
                  x_tolerable_qty := 0;
               end if;

            END IF;

            -- Bug 7681237:  Removed the Return qty subtraction code
      END IF;

      /*
      ** If you're receiving a one time item then go get the primary
      ** Unit of measure based on the unit of measure class that is
      ** assigned to the base transaction unit of measure.
      */

      IF (x_item_id IS NULL) THEN

         X_progress := '020';

         SELECT  unit_of_measure
         INTO    X_primary_uom
         FROM    mtl_units_of_measure mum
         WHERE   uom_class = x_unit_of_measure_class
         AND     mum.base_uom_flag = 'Y';

      ELSE

         X_progress := '025';

         /*
         ** Debug: This is only here so that we don't have to patch the
         ** server.  Once RCVRCERC.sql v  is in place in the patch driver
         ** then remove this call.  This will then just overwrite the correct
         ** value.
         */
         SELECT  msi.primary_unit_of_measure
         INTO    X_primary_uom
         FROM    mtl_system_items msi
         WHERE   inventory_item_id = x_item_id
         AND     organization_id = x_org_id;


      END IF;


      X_progress := '030';

      /*
      ** Chk if transaction UOM is same as transaction's Primary UOM
      ** If not same, then convert the transaction qty to Primary QTy's UOM
      ** Only to be done if transaction qty > 0
      */
      if (x_uom <> x_primary_uom AND x_available_qty <> 0) THEN

         /* Convert the transaction quantity to Primary UOM quantity */
         PO_UOM_S.UOM_CONVERT ( x_available_qty, x_uom, x_item_id,
      x_primary_uom, X_primary_qty );

      else

         X_primary_qty := x_available_qty;

      end if; /* transaction UOM VS Primary UOM */

      X_progress := '040';

      /*
      ** Check to make sure the ship to location is still valid
      */
      x_valid_ship_to_location := po_locations_s.val_receipt_site_in_org (
         x_ship_to_location_id, x_org_id);

    /*
    ** IF this is a po based transaction then go get the distribution info
    ** and validate it if there is one distribution.  If there's more than
    ** one then show multiple as the destination type and leave the other
    ** destination fields blank.  If this is an internal based transaction then
    ** there is only one distribution and that data should be fetched through the view
    ** and this function is not called but because the view naming conflicts
    ** with the form I need to do this select temporarily until I can fix the
    ** view.
    */
    IF (x_receipt_source_code = 'VENDOR') THEN

      X_progress := '060';

       rcv_distributions_s.get_distributions_info (x_line_location_id,
      x_shipment_line_id, x_item_id, x_num_of_distributions,
      x_po_distributions_id, x_destination_type_code,
      x_destination_type_dsp, x_deliver_to_location_id ,
      x_deliver_to_location,
      x_deliver_to_person_id, x_deliver_to_person,
           x_deliver_to_sub, x_deliver_to_locator_id, x_deliver_to_locator,
           x_wip_entity_id,  x_wip_repetitive_schedule_id, x_wip_line_id,
           x_wip_operation_seq_num, x_wip_resource_seq_num, x_bom_resource_id,
           x_to_organization_id, x_job, x_line_num, x_sequence, x_department,
           x_rate, x_rate_date,
        -- <RCV ENH FPI START>
           x_kanban_card_number,
           x_project_number,
           x_task_number,
           x_charge_account);
        -- <RCV ENH FPI END>

   ELSIF (x_receipt_source_code = 'CUSTOMER') THEN

    /* -- moved to procedure RCV_TRANSACTIONS_SV.get_rma_dest_info()

   select displayed_field, lookup_code into x_destination_type_dsp, x_destination_type_code
   from po_lookup_codes where
   lookup_CODE = 'RECEIVING' and
   lookup_type = 'RCV DESTINATION TYPE'; */

           /* Bug#4684017 START */

        IF (x_oe_order_line_id IS NOT NULL) THEN

             SELECT project_id, task_id
             INTO   X_project_id,X_task_id
             FROM   oe_order_lines_all
             WHERE  line_id = x_oe_order_line_id;

                IF ( X_project_id IS NOT NULL AND
                     X_task_id IS NOT NULL ) THEN

                   Begin

                     select pa.project_number,pt.task_number
                       into x_project_number,x_task_number
                       from pjm_projects_all_v pa,
                            pa_tasks_expend_v pt
                      where pa.project_id = X_project_id
                        and pt.task_id = X_task_id
                        and pa.project_id=pt.project_id;


                     Exception
                        when no_data_found then
                        null;
                   End;

                ELSIF (  X_project_id IS NOT NULL AND
                         X_task_id IS NULL ) THEN

                     Begin

                       select project_number
                         into x_project_number
                         from pjm_projects_all_v
                        where project_id = X_project_id;

                       Exception
                          when no_data_found then
                          null;
                     End;

                END IF;

        END IF;

     /* Bug#4684017 END */

   /* Bug# 1717095 - Need to get the Currency details for the Order */

        -- <ENT RCPT PERF FPI START>
        -- We will query from RCV_ENTER_RECEIPTS_RMA_V instead of
        -- RCV_ENTER_RECEIPTS_V to reduce complexity of the view for the same result.
        -- Actually in Receiving Forms we do not need this SQL because the view for
        -- block RCV_TRANSACTION has already got the value. This is called for
        -- INV code that calls this procedure

   /*   SELECT currency_conversion_rate,currency_conversion_date
        INTO   x_rate,x_rate_date
        FROM   rcv_enter_receipts_rma_v
        WHERE  oe_order_header_id = x_oe_order_header_id
        AND    oe_order_line_id = x_oe_order_line_id;    */

        -- <ENT RCPT PERF FPI END>

   /* Bug# 2864540 - Due to performance problems replaced the view
      rcv_enter_receipts_rma_v with the underlying base table */

      /* -- moved to procedure RCV_TRANSACTIONS_SV.get_rma_dest_info()
        SELECT conversion_rate, conversion_rate_date
        INTO   x_rate, x_rate_date
        FROM   oe_order_headers_all
        WHERE  header_id = x_oe_order_header_id; */

   /* Bug 3378162 - For RMA, we need to default the subinventory and
    * location from the backing OE line -pjiang*/
   -- get default subinventory, location, location_id from OE
   -- get the conversion rate and destination_type info
   RCV_TRANSACTIONS_SV.get_rma_dest_info(x_oe_order_header_id,
                                         x_oe_order_line_id,
                                         x_item_id,
                                         x_deliver_to_sub,
                                         x_deliver_to_location_id,
                                         x_deliver_to_location,
                                         x_destination_type_dsp,
                                         x_destination_type_code,
                                         x_to_organization_id,
                                         x_rate,
                                         x_rate_date);

   ELSE

      X_progress := '070';

   /* bug : 971489 - moved the join to hr_employees_current_v into
      a different select to improve performance.The deliver to
      person's full name is got from the above view only when
      the deliver_to_person_id is not null.

     Bug 1205660 - Select the req distribution id which will be used
     later to get the project_id and task_id from req distributions.
     GMudgal 2-28-2000
   */

      SELECT rsl.destination_type_code,
             polc.displayed_field,
             rsl.deliver_to_person_id,
             rsl.deliver_to_location_id,
             hlo.location_code,
        rsl.to_subinventory,
             rsl.req_distribution_id,
             MKC.kanban_card_number,   -- <RCV ENH FPI>
             PPA.project_number,       -- <RCV ENH FPI>
             PTE.task_number,          -- <RCV ENH FPI>
             PRD.code_combination_id   -- <RCV ENH FPI>
      INTO   x_destination_type_code,
             x_destination_type_dsp,
        x_deliver_to_person_id,
        x_deliver_to_location_id ,
             x_deliver_to_location,
             x_deliver_to_sub,
             x_req_distribution_id,
             x_kanban_card_number,     -- <RCV ENH FPI>
             x_project_number,         -- <RCV ENH FPI>
             x_task_number,            -- <RCV ENH FPI>
             l_code_combination_id     -- <RCV ENH FPI>
      FROM   rcv_shipment_lines rsl,
             hr_locations hlo,
             po_lookup_codes polc,
             po_requisition_lines PRL, -- <RCV ENH FPI>
             po_req_distributions PRD, -- <RCV ENH FPI>
             mtl_kanban_cards MKC,     -- <RCV ENH FPI>
             pjm_projects_all_v PPA,   -- <RCV ENH FPI>
             pa_tasks_expend_v PTE     -- <RCV ENH FPI>
      WHERE  polc.lookup_type = 'RCV DESTINATION TYPE'
      AND    polc.lookup_code = NVL( rsl.destination_type_code, 'INVENTORY')
      AND    rsl.shipment_line_id = x_shipment_line_id
      AND    hlo.location_id(+) = rsl.deliver_to_location_id
      AND    RSL.requisition_line_id = PRL.requisition_line_id (+) -- <RCV ENH FPI>
      AND    PRL.kanban_card_id = MKC.kanban_card_id (+)       -- <RCV ENH FPI>
      AND    PRL.requisition_line_id = PRD.requisition_line_id (+) -- <RCV ENH FPI>
      AND    PRD.project_id = PPA.project_id (+)               -- <RCV ENH FPI>
      AND    PRD.task_id = PTE.task_id (+);                    -- <RCV ENH FPI>

      IF (x_deliver_to_person_id is not null) THEN

        /* Bug# 1840300 - Cannot receive against Internal Requisition
           if requestor has been terminated */

        /* Bug 3582515 : The change in maiden name was not handled correctly by
                         the earlier SQL query. We now call the function
                         po_inq_sv.get_person_name() to get the full name
                         of requester in the variable X_deliver_to_person.
        */

          X_deliver_to_person := po_inq_sv.get_person_name(X_deliver_to_person_id);

      END IF;

-- <RCV ENH FPI START>
      x_progress := '075';

      x_charge_account :=
          PO_COMPARE_REVISIONS.get_charge_account(l_code_combination_id);
-- <RCV ENH FPI END>

    END IF;

    /* get receiving controls */
    IF (x_receipt_source_code = 'VENDOR') THEN

       X_progress := '080';

       rcv_core_s.get_receiving_controls(
         x_line_location_id,
         x_item_id,
    x_vendor_id,
    x_org_id,
    x_enforce_ship_to_loc,
    x_allow_substitutes,
    x_routing_id,
    x_qty_rcv_tolerance,
    x_qty_rcv_exception,
    x_days_early_receipt,
    x_days_late_receipt,
    x_rcv_days_exception);

     ELSE

       X_progress := '090';

       rcv_core_s.get_receiving_controls(
         NULL,
         x_item_id,
    x_vendor_id,
    x_org_id,
    x_enforce_ship_to_loc,
    x_allow_substitutes,
    x_routing_id,
    x_qty_rcv_tolerance,
    x_qty_rcv_exception,
    x_days_early_receipt,
    x_days_late_receipt,
    x_rcv_days_exception);

      /*
      ** If this is an internal transaction then you cannot over receive
      ** this shipment.  We copy 'INTERNAL' into qty_rcv_exception_code
      ** on post query for an internal transaction and in the uom_qty_conversion
      ** we'll check against the origanal quantity instead of the tolerable
      ** quantity.  THis is used for WVI on the transaction quantity.
      */
        x_qty_rcv_exception := 'INTERNAL';

       /* Bug# 1942953 - Intransit receipts doesn't follow shipping network
          routing */

       IF (x_receipt_source_code <> 'CUSTOMER') THEN
          x_progress := '092';

          IF (NVL(x_item_id,0) <> 0) THEN
             x_progress := '094';

             BEGIN

             SELECT NVL(receiving_routing_id,0)
             INTO   x_routing_id
             FROM   mtl_system_items
             WHERE  inventory_item_id = x_item_id
             AND    organization_id = x_org_id;

             EXCEPTION
                WHEN NO_DATA_FOUND THEN NULL;
                WHEN OTHERS THEN RAISE;
             END;

             IF (x_routing_id = 0) THEN
                x_progress := '096';

                BEGIN

                SELECT NVL(ROUTING_HEADER_ID,0)
                INTO   x_routing_id
                FROM   MTL_INTERORG_PARAMETERS
                WHERE  FROM_ORGANIZATION_ID = x_from_org_id
                AND    TO_ORGANIZATION_ID   = x_org_id;

                EXCEPTION
                   WHEN NO_DATA_FOUND THEN NULL;
                   WHEN OTHERS THEN RAISE;
                END;

             END IF;

             /* Bug# 2194792 - For Internal Orders when Routing is 'Direct',
                ROUTING_HEADER_ID is null. So default the routing from the
                Receiving Organization */

             IF (x_routing_id = 0) THEN
                x_progress := '098';

                BEGIN

                SELECT NVL(RECEIVING_ROUTING_ID,0)
                INTO   x_routing_id
                FROM   RCV_PARAMETERS
                WHERE  ORGANIZATION_ID = x_org_id;

                EXCEPTION
                   WHEN NO_DATA_FOUND THEN NULL;
                   WHEN OTHERS THEN RAISE;
                END;

             END IF;

             /* x_routing_id will be zero if none of the above statements
                returns a value */

          END IF;

       END IF;

     END IF;

     /* Begin Bug# 3672978 - Routing change in the Manage Shipments form
        was not considered in the Receiving forms */

     IF (x_receipt_source_code <> 'CUSTOMER') THEN
         x_progress := '100';

         BEGIN
             SELECT routing_header_id
             INTO   x_ms_routing_id
             FROM   rcv_shipment_lines
             WHERE  shipment_line_id = x_shipment_line_id;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN NULL;
         END;

         IF x_ms_routing_id is not null THEN
             x_routing_id := x_ms_routing_id;
         END IF;
     END IF;

     /* End Bug# 3555251 */

     X_progress := '105';


     /* get latest item revision IF null */
     IF (x_destination_type_code = 'INVENTORY' AND
     x_item_id is not null AND
          x_item_revision is not null AND
          NVL(x_item_rev_control_flag_to, 'N') = 'Y') THEN

         po_items_sv2.get_latest_item_rev(
        x_item_id,
        x_org_id,
        x_item_revision,
        p_rev_exists);

     END IF;

     -- Bug 9298154
      IF (x_deliver_to_sub IS NOT NULL) AND (x_org_id IS NOT NULL) THEN
        BEGIN
          X_progress := 106;

          SELECT 'Check to see if subinventory is valid'
          INTO   x_subinv
          FROM   mtl_secondary_inventories
          WHERE  (disable_date IS NULL OR disable_date > SYSDATE)
          AND    organization_id = x_org_id
          AND    secondary_inventory_name = x_deliver_to_sub;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_deliver_to_sub := '';
          WHEN OTHERS THEN
            RAISE;
        END;
      END IF;
      -- End bug 9298154

      X_progress := '110';

      IF (x_destination_type_code = 'INVENTORY' AND
          x_deliver_to_sub IS NULL) THEN

          po_subinventories_s.get_default_subinventory (
              x_org_id,
              x_item_id,
              x_deliver_to_sub);

      END IF;

      X_progress := '120';

      /*
      ** Go get the locator control value if the locator control has
      ** not already been selected or if the subinventory has been
      ** modified
      */
      IF (x_destination_type_code = 'INVENTORY' AND
            x_locator_control IS NULL AND
         x_deliver_to_sub IS NOT NULL) THEN

           po_subinventories_s.get_locator_control (
                 x_org_id,
                 x_deliver_to_sub,
                 x_item_id,
                 x_locator_control);

       END IF;

       X_progress := '130';

       IF (x_destination_type_code = 'INVENTORY' AND
         x_deliver_to_sub IS NOT NULL) THEN

        /*
        ** get default locator
        */
        /*
        ** Anytime a subinventory is selected then the locator field
   ** should be prepopulated with the default locator_id from
   ** mtl_item_loc_defaults for the item, org and subinventory
   ** and where the default_type = 2
        */

        po_subinventories_s.get_default_locator (
           x_org_id,
           x_item_id,
            x_deliver_to_sub,
           x_deliver_to_locator_id);


   /* Bug 3537022.
      * Get locator_id from rcv_shipment_lines for intransit
      * shipments.
     */
          x_progress := 80;

     if (x_receipt_source_code = 'INVENTORY') then
         select locator_id
         into x_deliver_to_locator_id
         from rcv_shipment_lines
         where shipment_line_id = x_shipment_line_id;
     end if;

     x_progress := 90;



      END IF;

      IF (x_destination_type_code = 'INVENTORY') THEN

         X_default_subinventory := x_deliver_to_sub;
         X_default_locator_id   := x_deliver_to_locator_id;

         X_success := rcv_sub_locator_sv.put_away_api (
                   x_line_location_id  ,
                         x_po_distributions_id  ,
                   x_shipment_line_id  ,
                         x_receipt_source_code  ,
                         x_org_id               ,
                         x_to_organization_id   ,
                   x_item_id     ,
                   x_item_revision  ,
                   x_vendor_id               ,
                   x_ship_to_location_id  ,
                   x_deliver_to_location_id,
                   x_deliver_to_person_id ,
                         x_available_qty        ,
                         x_primary_qty    ,
                   x_primary_uom    ,
                   x_tolerable_qty  ,
                         x_uom              ,
                   x_routing_id           ,
                         x_default_subinventory ,
                         x_default_locator_id   ,
                         x_deliver_to_sub       ,
                         x_deliver_to_locator_id);

          X_progress := '132';

      IF (x_receipt_source_code <> 'CUSTOMER') THEN

          IF (X_po_distributions_id IS NOT NULL AND
              x_deliver_to_locator_id IS NOT NULL) THEN

             X_progress := '133';

             SELECT project_id, task_id
             INTO   X_project_id, X_task_id
             FROM   po_distributions
             WHERE  po_distribution_id = X_po_distributions_id;

          ELSIF (x_req_distribution_id IS NOT NULL AND
              x_deliver_to_locator_id IS NOT NULL) THEN

          /* Bug 1205660. Locator defaulting for Internal Orders */

         /* Fix for 2444052.
            Ported the fix as done in Rel 10.7 by adding an exception handler
            for the following select statement.
         */

             begin
             X_progress := '134';

             SELECT project_id, task_id
             INTO   X_project_id, X_task_id
             FROM   po_req_distributions
             WHERE  distribution_id = x_req_distribution_id;

             exception
             when no_data_found then
             null;
             end;

           END IF;

       ELSE
            /* Locator field defaulting for rma's */
             X_progress := '135';

            IF (x_oe_order_line_id IS NOT NULL AND
              x_deliver_to_locator_id IS NOT NULL) THEN

             SELECT project_id, task_id
             INTO   X_project_id,X_task_id
             FROM   oe_order_lines_all
             WHERE  line_id = x_oe_order_line_id;

           END IF;

        END IF;
             /*
             ** Set the default values for the locator based on a
             ** project manufacturing call.  If the default locator
             ** does not have the project and task that is specified
             ** on the po and the locator control is dynamic then
             ** project manufacturing will create a new locator row
             ** copying all values from the existing locator row while
             ** adding the new project and task is values
             */
          /* Bug 1349864 - 25-JUL-2000: GMudgal
          ** Added a begin-end construct around the PJM call
          ** We don't really need to default the project
          ** locators when doing a standard receipt. We need
          ** to still be able to query up the document even if
          ** we are unable to default the locators.
          */
             IF (X_project_id IS NOT NULL AND
             -- X_locator_control = 3 AND--for bug 588172 as part of bug 1662321
             X_deliver_to_sub is not null) THEN
           begin

               X_progress := '150';

                X_default_locator_id := X_deliver_to_locator_id; -- Bug 2772050
                PJM_PROJECT_LOCATOR.Get_DefaultProjectLocator(
                           X_to_organization_id,
                           X_default_locator_id, -- Bug 2772050
                           X_project_id,
                           X_task_id,
                           X_deliver_to_locator_id);
           exception
            when others then
               null ;
           end ;

             END IF;


      END IF;

      X_progress := '160';

      /*
      ** Figure out if any distribution for this shipment has an inventory
      ** destination.  If it does and item is under rev control then the
      ** item revision must be required.  If there are inventory destinations
      ** but the item is not under item rev control then the rev must be
      ** disabled. If there are no inventory destinations then it does not
      ** matter
      */
      x_inv_destinations := rcv_transactions_sv.val_if_inventory_destination (
            x_line_location_id,
            x_shipment_line_id);


EXCEPTION

   WHEN OTHERS THEN
      po_message_s.sql_error('post_query', x_progress, sqlcode);
      RAISE;

END post_query;

/* Bug 2668645- Added the following procedure to get the default value for the
DFF. This procedure is called in the block level post-query of rcv_transactions block . */

/* Bug 3775987. Removing the get_dff_default procedure as it is raising
 * flex errors related to Receiving Transactions DFF and not allowing to
 * create receipts.
 **/

/*===========================================================================

  PROCEDURE NAME: post_query()

===========================================================================*/
/* bug2730828 */
/* This procedure overloads another post_query procedure within this package.
   This procedure is used by other team and for bug fixes of post_query
   please make changes to the one that this procedure is calling.
 */

PROCEDURE  post_query (  x_line_location_id      IN NUMBER,
          x_shipment_line_id      IN NUMBER,
                         x_receipt_source_code           IN VARCHAR2,
                         x_org_id                        IN NUMBER,
          x_item_id         IN NUMBER,
          x_unit_of_measure_class    IN VARCHAR2,
          x_ship_to_location_id      IN NUMBER,
          x_vendor_id                   IN NUMBER,
          x_customer_id              IN NUMBER,
          x_item_rev_control_flag_to    IN VARCHAR2,
                         x_available_qty                 IN OUT NOCOPY NUMBER,
                         x_primary_qty        IN OUT NOCOPY NUMBER,
          x_tolerable_qty           IN OUT NOCOPY NUMBER,
                         x_uom                       IN OUT NOCOPY VARCHAR2,
          x_primary_uom        IN OUT NOCOPY VARCHAR2,
          x_valid_ship_to_location   IN OUT NOCOPY BOOLEAN,
             x_num_of_distributions     IN OUT NOCOPY NUMBER,
             x_po_distributions_id      IN OUT NOCOPY NUMBER,
             x_destination_type_code    IN OUT NOCOPY VARCHAR2,
             x_destination_type_dsp     IN OUT NOCOPY VARCHAR2,
             x_deliver_to_location_id   IN OUT NOCOPY NUMBER,
             x_deliver_to_location      IN OUT NOCOPY VARCHAR2,
             x_deliver_to_person_id     IN OUT NOCOPY NUMBER,
             x_deliver_to_person     IN OUT NOCOPY VARCHAR2,
             x_deliver_to_sub     IN OUT NOCOPY VARCHAR2,
             x_deliver_to_locator_id    IN OUT NOCOPY NUMBER,
             x_wip_entity_id                 IN OUT NOCOPY NUMBER,
             x_wip_repetitive_schedule_id    IN OUT NOCOPY NUMBER,
             x_wip_line_id                    IN OUT NOCOPY NUMBER,
             x_wip_operation_seq_num          IN OUT NOCOPY NUMBER,
             x_wip_resource_seq_num           IN OUT NOCOPY NUMBER,
             x_bom_resource_id                IN OUT NOCOPY NUMBER,
             x_to_organization_id             IN OUT NOCOPY NUMBER,
             x_job                            IN OUT NOCOPY VARCHAR2,
             x_line_num                       IN OUT NOCOPY VARCHAR2,
             x_sequence                       IN OUT NOCOPY NUMBER,
             x_department                     IN OUT NOCOPY VARCHAR2,
          x_enforce_ship_to_loc      IN OUT NOCOPY VARCHAR2,
          x_allow_substitutes        IN OUT NOCOPY VARCHAR2,
          x_routing_id               IN OUT NOCOPY NUMBER,
          x_qty_rcv_tolerance        IN OUT NOCOPY NUMBER,
          x_qty_rcv_exception        IN OUT NOCOPY VARCHAR2,
          x_days_early_receipt       IN OUT NOCOPY NUMBER,
          x_days_late_receipt        IN OUT NOCOPY NUMBER,
          x_rcv_days_exception       IN OUT NOCOPY VARCHAR2,
          x_item_revision      IN OUT NOCOPY VARCHAR2,
          x_locator_control       IN OUT NOCOPY NUMBER,
          x_inv_destinations      IN OUT NOCOPY BOOLEAN,
                         x_rate                          IN OUT NOCOPY NUMBER,
                         x_rate_date                     IN OUT NOCOPY DATE,
                         x_asn_type                      IN     VARCHAR2,
          x_oe_order_header_id       IN     NUMBER,
          x_oe_order_line_id      IN     NUMBER,
                         x_from_org_id                   IN NUMBER DEFAULT NULL) IS
/* create dummy variables just to store throw-away values */
l_dummy1       MTL_KANBAN_CARDS.kanban_card_number%TYPE;
l_dummy2       PJM_PROJECTS_ALL_V.project_number%TYPE;
l_dummy3       PA_TASKS_EXPEND_V.task_number%TYPE;
l_dummy4       GL_CODE_COMBINATIONS_KFV.concatenated_segments%TYPE;

BEGIN
  RCV_RECEIPTS_QUERY_SV.post_query(
    x_line_location_id,
    x_shipment_line_id,
    x_receipt_source_code,
    x_org_id,
    x_item_id,
    x_unit_of_measure_class,
    x_ship_to_location_id,
    x_vendor_id,
    x_customer_id,
    x_item_rev_control_flag_to,
    x_available_qty,
    x_primary_qty,
    x_tolerable_qty,
    x_uom,
    x_primary_uom,
    x_valid_ship_to_location,
    x_num_of_distributions,
    x_po_distributions_id,
    x_destination_type_code,
    x_destination_type_dsp,
    x_deliver_to_location_id,
    x_deliver_to_location,
    x_deliver_to_person_id,
    x_deliver_to_person,
    x_deliver_to_sub,
    x_deliver_to_locator_id,
    x_wip_entity_id,
    x_wip_repetitive_schedule_id,
    x_wip_line_id,
    x_wip_operation_seq_num,
    x_wip_resource_seq_num,
    x_bom_resource_id,
    x_to_organization_id,
    x_job,
    x_line_num,
    x_sequence,
    x_department,
    x_enforce_ship_to_loc,
    x_allow_substitutes,
    x_routing_id,
    x_qty_rcv_tolerance,
    x_qty_rcv_exception,
    x_days_early_receipt,
    x_days_late_receipt,
    x_rcv_days_exception,
    x_item_revision,
    x_locator_control,
    x_inv_destinations,
    x_rate,
    x_rate_date,
    x_asn_type,
    x_oe_order_header_id,
    x_oe_order_line_id,
    x_from_org_id,
    l_dummy1,
    l_dummy2,
    l_dummy3,
    l_dummy4);

END post_query;

-- <ENT RCPT PERF FPI START>


/**
* Public Procedure: exec_dynamic_sql
* Requires: the number of records in p_val has to match the number of
*           bind variables in p_query, which is a sql string
*           the sql to execute should be a clause that check
*           existence only
*           The number of bind variables should also be less than or equal
*           to 7 unless modified.
* Modifies: None
* Effects: Executes a dynamic sql defined in p_query. the value of bind
*          variables will be defined in p_val
* Returns:
* x_exist - FND_API.G_TRUE if sql is executed successfully without any error
*           FND_API.G_FALSE if sql returns NO_DATA_FOUND
* The procedure raises an exception if p_query returns an error other than
* NO_DATA_FOUND
*/

PROCEDURE exec_dynamic_sql(p_query      IN VARCHAR2,
                           p_val        IN RCV_RECEIPTS_QUERY_SV.NUM_TBL_TYPE,
                           x_exist      OUT NOCOPY VARCHAR2) IS
l_tmp       NUMBER;
l_progress  VARCHAR2(3) := '000';
l_exception EXCEPTION;
l_num_bind  NUMBER;
BEGIN

  l_num_bind := p_val.COUNT;

  IF (l_num_bind = 0) THEN
    l_progress := '000';
    EXECUTE IMMEDIATE p_query INTO l_tmp;

  ELSIF (l_num_bind = 1) THEN
    l_progress := '010';
    EXECUTE IMMEDIATE p_query INTO l_tmp USING p_val(1);

  ELSIF (l_num_bind = 2) THEN
    l_progress := '020';
    EXECUTE IMMEDIATE p_query INTO l_tmp USING p_val(1), p_val(2);

  ELSIF (l_num_bind = 3) THEN
    l_progress := '030';
    EXECUTE IMMEDIATE p_query INTO l_tmp USING p_val(1), p_val(2), p_val(3);

  ELSIF (l_num_bind = 4) THEN
    l_progress := '040';
    EXECUTE IMMEDIATE p_query INTO l_tmp USING p_val(1), p_val(2), p_val(3),
                                               p_val(4);

  ELSIF (l_num_bind = 5) THEN
    l_progress := '050';
    EXECUTE IMMEDIATE p_query INTO l_tmp USING p_val(1), p_val(2), p_val(3),
                                               p_val(4), p_val(5);

  ELSIF (l_num_bind = 6) THEN
    l_progress := '060';
    EXECUTE IMMEDIATE p_query INTO l_tmp USING p_val(1), p_val(2), p_val(3),
                                               p_val(4), p_val(5), p_val(6);

  ELSIF (l_num_bind = 7) THEN
    l_progress := '070';
    EXECUTE IMMEDIATE p_query INTO l_tmp USING p_val(1), p_val(2), p_val(3),
                                               p_val(4), p_val(5), p_val(6),
                                               p_val(7);
  ELSE
    l_progress := '080';
    RAISE l_exception;
  END IF;

  x_exist := FND_API.G_TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_exist := FND_API.G_FALSE;
  WHEN OTHERS THEN
    PO_MESSAGE_S.sql_error('exec_dynamic_sql', l_progress, sqlcode);
    RAISE;
END exec_dynamic_sql;


-- <ENT RCPT PERF FPI END>

END RCV_RECEIPTS_QUERY_SV;

/
