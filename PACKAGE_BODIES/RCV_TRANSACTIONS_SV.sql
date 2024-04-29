--------------------------------------------------------
--  DDL for Package Body RCV_TRANSACTIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRANSACTIONS_SV" AS
/* $Header: RCVTXTXB.pls 120.1.12010000.3 2010/02/02 09:37:05 honwei ship $*/

/*===========================================================================

  FUNCTION NAME:	val_receiving_controls


      1. Receiving controls are only checked for vendor receipts. Intransit
         shipments cannot be rejected and we have not way to define org->org
         receiving controls.
      2. Controls are only checked if the exception level is 'REJECT'
      3. Quantity tolerances are not checked. It is not possible to
         over-receive an express receipt.
      4. Standard receipts will be created for the ship-to location
         specified on the PO so the 'enforce ship-to location' control
         is not tested.
      5. Routing controls are checked for both Vendor sourced and
         intransit receipts.

===========================================================================*/

FUNCTION val_receiving_controls (
X_transaction_type      IN VARCHAR2,
X_auto_transact_code    IN VARCHAR2,
X_expected_receipt_date IN DATE,
X_transaction_date      IN DATE,
X_routing_header_id     IN NUMBER,
X_po_line_location_id   IN NUMBER,
X_item_id               IN NUMBER,
X_vendor_id             IN NUMBER,
X_to_organization_id    IN NUMBER)
RETURN NUMBER IS

transaction_ok          NUMBER := 1;
enforce_ship_to_loc	VARCHAR2(20);
allow_substitutes   	VARCHAR2(20);
routing_id          	NUMBER;
qty_rcv_tolerance   	NUMBER;
qty_rcv_exception   	VARCHAR2(20);
days_early_receipt  	NUMBER;
days_late_receipt   	NUMBER;
rcv_date_exception  	VARCHAR2(20);
allow_routing_override  VARCHAR2(20);
expected_date           DATE;
high_range_date         DATE;
low_range_date          DATE;
X_progress 	        VARCHAR2(4)  := '000';

--Bug : 3724862
l_drop_ship_flag        po_line_locations.drop_ship_flag%type;


BEGIN

   /*
   ** Get the receiving controls for this transaction.
   */

   /*
   **  DEBUG: Will this function work properly on getting the routing control
   **  for internally sourced shipments
   */
   X_progress := '200';
   rcv_core_s.get_receiving_controls (X_po_line_location_id,
				      X_item_id,
				      X_vendor_id,
				      X_to_organization_id,
				      enforce_ship_to_loc,
				      allow_substitutes,
				      routing_id,
				      qty_rcv_tolerance,
				      qty_rcv_exception,
				      days_early_receipt,
				      days_late_receipt,
				      rcv_date_exception);

/*   -- dbms_output.put_line ('Val Receiving Controls : enforce_ship_to_loc : ' ||
--	enforce_ship_to_loc);
   -- dbms_output.put_line ('Val Receiving Controls : allow_substitutes : ' ||
--	allow_substitutes);
   -- dbms_output.put_line ('Val Receiving Controls : routing_id : ' ||
--	to_char(routing_id));
   -- dbms_output.put_line ('Val Receiving Controls : qty_rcv_tolerance : ' ||
 --	to_char(qty_rcv_tolerance));
   -- dbms_output.put_line ('Val Receiving Controls : rcv_date_exception : ' ||
--	rcv_date_exception);
   -- dbms_output.put_line ('Val Receiving Controls : qty_rcv_exception : ' ||
 --	qty_rcv_exception);*/
  /* -- dbms_output.put_line ('Val Receiving Controls : days_early_receipt : ' ||
--	substr(to_char(days_early_receipt),1,3));
   -- dbms_output.put_line ('Val Receiving Controls : days_late_receipt : ' ||
--	substr(to_char(days_late_receipt),1,3));
   -- dbms_output.put_line ('Val Receiving Controls : rcv_date_exception : ' ||
--	rcv_date_exception);*/
   /*
   ** if the days exception is set to reject then verify that the receipt
   ** falls within the date tolerances
   */
   IF (rcv_date_exception='REJECT') THEN

	/*
	** Check to see that you have a promised date on the po.  If not
	** then see if you have an expected date.  If not then the trx
	** passed date validation
	** I have placed either the promised date if it is set or the
	** need by date into the expected_receipt date column in the interface
	*/
	IF (X_expected_receipt_date IS NOT NULL) THEN

	      expected_date := X_expected_receipt_date;

	ELSE
              transaction_ok := 0;

        END IF;

	/*
	** If you have a date to compare against then set up the range
	** based on the days early and late parameters
	*/
	IF ( transaction_ok > 0 ) THEN

           low_range_date  := expected_date - days_early_receipt;
   	   high_range_date := expected_date + days_late_receipt;

	   -- dbms_output.put_line ('val_receiving_controls : expected_date : ' ||
	--	to_char(expected_date));
	   -- dbms_output.put_line ('val_receiving_controls : low_range_date : ' ||
--		to_char(low_range_date));
	   -- dbms_output.put_line ('val_receiving_controls : high_range_date : ' ||
--		to_char(high_range_date));

           /*
           ** If the transaction date is between the range then it's okay
	   ** to process.
	   */
	   IF (X_transaction_date >= low_range_date AND
	       X_transaction_date <= high_range_date) THEN

	       transaction_ok := 0;

           ELSE
                /* Transaction_Ok = 1 indicates that
                ** receipt date tolerance is exceeded. */
                 transaction_ok  := 1;
           END IF;

        END IF; -- (transaction_ok > 0)

   ELSE  --(rcv_date_exception <> REJECT)
        transaction_ok := 0;
   END IF;

   /* Bug 3724862 : If the Express receipt is against a DropShip PO line then
   **        the routing can only be 'Direct Delivery'. We will error out if
   **        the routing is not 'Direct Delivery' in the rti.
   */

   IF ( X_po_line_location_id is not null and
        transaction_ok = 0                  ) THEN

     select nvl(drop_ship_flag,'N')
       into l_drop_ship_flag
       from po_line_locations_all
     where line_location_id = X_po_line_location_id;

     IF ( l_drop_ship_flag = 'Y' and
          X_transaction_type = 'RECEIVE' and
          X_auto_transact_code <> 'DELIVER' ) THEN

          transaction_ok := 3;

     END IF;
   END IF;

   /*
   ** Check the routing controls to see if the transaction type matches the
   ** routing specfied on the po or by the hierarchy for item, vendor for
   ** internally sourced shipments
   */

   /*
   ** This component of the check is a little different thab others since
   ** we have a carry over of the transaction_ok flag.  If the flag is
   ** already set to false then you don't want to perform any other checks
   */
   IF (transaction_ok = 0 ) THEN
      /*
      ** Go get the routing override value to see if you need to check the
      ** routing control.  If routing override is set to 'Y' then you don't
      ** need to perform this check since any routing is allowed
      */
      X_progress := '300';

      -- dbms_output.put_line('Getting the Routing Info ');

      allow_routing_override := rcv_setup_s.get_override_routing;

      -- dbms_output.put_line ('val_receiving_controls : allow_routing_override : ' ||
--	allow_routing_override);
      -- dbms_output.put_line ('val_receiving_controls : transaction_type : '||
--	X_transaction_type);
      -- dbms_output.put_line ('val_receiving_controls : routing_id : ' ||
--	to_char(routing_id));

      /*
      ** Check the routing controls.  If routing_override is set to Y then you
      ** don't care about the routing controls.  Otherwise check to make sure
      ** you're express option is in line with the routing id
      */
      IF (allow_routing_override = 'N' AND transaction_ok = 0 ) THEN

           /*
           ** You can only do express direct if routing is set to direct
           */
           IF (X_transaction_type = 'RECEIVE' AND
                X_auto_transact_code = 'DELIVER' AND
	         (routing_id IN (3,0))) THEN

   	       /*
	       ** Direct delivery is allowed
	       */
	       transaction_ok := 0;

           /*
	   ** You can only do express receipt if routing is set to
	   ** standard receipt or inspection required
	   */
	   ELSIF (X_transaction_type = 'RECEIVE' AND
                   X_auto_transact_code = 'RECEIVE' AND
	            (X_routing_header_id IN (1, 2, 0))) THEN
              /*
              ** standard receipt is allowed
              */
              transaction_ok := 0;

           ELSE
           /*
           ** Routing Control is On and the Routing Definitions
           ** cannot be overridden.Set the return value to
           ** flag Routing Information as the cause of Failure.
           */
              transaction_ok := 2;

           END IF;

      ELSE
         transaction_ok := 0;

      END IF;

   END IF;


   RETURN(transaction_ok);


  EXCEPTION
    WHEN OTHERS THEN
       po_message_s.sql_error('val_receiving_controls', x_progress, sqlcode);
       RAISE;

END val_receiving_controls;

/*===========================================================================

 FUNCTION NAME:	val_wip_info

===========================================================================*/
FUNCTION val_wip_info (
X_to_organization_id         IN NUMBER,
X_wip_entity_id              IN NUMBER,
X_wip_operation_seq_num      IN NUMBER,
X_wip_resource_seq_num       IN NUMBER,
X_wip_line_id                IN NUMBER,
X_wip_repetitive_schedule_id IN NUMBER,
p_po_line_id                 IN NUMBER) -- bug 2619164
RETURN NUMBER IS

valid_open_job        NUMBER      := 0;
X_progress            VARCHAR2(4) := '000';
l_osp_flag            po_line_types_b.outside_operation_flag%TYPE; -- bug 2619164


BEGIN

   /*
   ** The required info for shop floor is the
   ** job, the op seq num, the reource seq num, the
   ** repetive schedule and the wip line
   */

   /*
   ** First make sure all the required id elemnts are present.  If not
   ** then these rows cannot be transacted.
   */
   IF X_to_organization_id IS NULL THEN

       return 10;

   END IF;

   IF X_wip_entity_id IS NULL THEN

      return 20;

   END IF;

   IF (l_osp_flag = 'Y') AND (X_wip_operation_seq_num IS NULL) THEN

      return 30;

   END IF;

   -- bug 2619164 start
   -- for direct item, wip_resource_seq_num will always be null
   -- for outside service, wip_resource_seq_num can not be null

   SELECT plt.outside_operation_flag
     INTO l_osp_flag
     FROM po_line_types plt,
          po_lines      pl
    WHERE plt.line_type_id = pl.line_type_id
      AND pl.po_line_id = p_po_line_id;

   IF (l_osp_flag = 'Y') AND (X_wip_resource_seq_num IS NULL) THEN

       RETURN 40;

   END IF;
   -- bug 2619164 end

   /*
   ** If this is an repetitive job then make sure that the job is
   ** open.  If it is not then this cannot be transacted.
   */
   IF (X_wip_repetitive_schedule_id IS NOT NULL AND
         X_wip_line_id IS NOT NULL) THEN

      /* DEBUG:
      ** We need a function or a view from mike to determine if a job
      ** is still open or not
      */
      BEGIN

      X_progress := '1250';
      SELECT 1
      INTO   valid_open_job
      FROM   WIP_REPETITIVE_SCHEDULES WRS
      WHERE  WRS.ORGANIZATION_ID = X_to_organization_id
      AND    WRS.REPETITIVE_SCHEDULE_ID =
		X_wip_repetitive_schedule_id
      AND    WRS.STATUS_TYPE IN (3,4);

      /* If the status of the job is closed then return */
      IF (valid_open_job = 0) THEN
          RETURN 50;
      END IF;

      /*
      ** If the status of the job is no longed open then you won't
      ** return a row and therefore the row cannot be transacted
      */
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 50;
      END;

   /*
   ** If this is an discrete job then make sure that the job is
   ** open.  If it is not then this cannot be transacted.
   */
   ELSIF (X_wip_repetitive_schedule_id IS NULL AND
         X_wip_line_id IS NULL) THEN

      /* DEBUG:
      ** We need a function or a view from mike to determine if a job
      ** is still open or not
      */
      BEGIN

      X_progress := '1260';
      SELECT 1
      INTO   valid_open_job
      FROM   WIP_DISCRETE_JOBS WDJ
      WHERE  WDJ.ORGANIZATION_ID = X_to_organization_id
      AND    WDJ.WIP_ENTITY_ID   = X_wip_entity_id
      AND    WDJ.STATUS_TYPE IN (3,4);

      /* If the status of the job is closed then return */
      IF (valid_open_job = 0) THEN
          RETURN 60;
      END IF;

      /*
      ** If the status of the job is no longed open then you won't
      ** return a row and therefore the row cannot be transacted
      */
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 60;

      END;

   ELSE
      /*
      ** one or the other, but not both, of the repetitive
      ** schedule and wip line have been specified
      */
      RETURN 70;

   END IF;

   RETURN 0;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_wip_info', X_progress, sqlcode);
   RAISE;

END val_wip_info;

/*===========================================================================

  PROCEDURE NAME:	val_if_inventory_destination

===========================================================================*/

/*
**   Check to see if any of the distributions are of type inventory
*/
FUNCTION val_if_inventory_destination (X_line_location_id  IN NUMBER,
				       X_shipment_line_id     IN NUMBER)
RETURN BOOLEAN IS

X_number_of_inv_dest         NUMBER := 0;
X_progress       	     VARCHAR2(4)  := '000';

BEGIN

   X_progress := '600';
   /*
   ** Check to see which id is set to know which table to check for
   ** inventory destination_type_code
   */
   IF (X_line_location_id IS NOT NULL) THEN

      X_progress := '610';

      SELECT count(1)
      INTO   X_number_of_inv_dest
      FROM   po_distributions pd
      WHERE  pd.line_location_id = X_line_location_id
      AND    pd.destination_type_code = 'INVENTORY';

   ELSE

      X_progress := '620';

      SELECT count(1)
      INTO   X_number_of_inv_dest
      FROM   rcv_shipment_lines rsl
      WHERE  rsl.shipment_line_id = X_shipment_line_id
      AND    rsl.destination_type_code = 'INVENTORY';
   END IF;

   IF (X_number_of_inv_dest > 0) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_if_inventory_destination', x_progress, sqlcode);
   RAISE;

END val_if_inventory_destination;

/*===========================================================================

 FUNCTION NAME:	val_deliver_destination

 Ensure that all mandatory columns for each destination type are
 populated. If a mandatory column is not specified, the transaction
 cannot be processed via express.
 The exceptions are subinventory and locator. If a sub is provided
 it will be used otherwise the default receiving subinventory will
 be used (if available). Locator control is evaluated if a sub is
 provided or defaulted and if locator control is required, the default
 locator for the sub will be used.

=============================================================================*/

FUNCTION val_deliver_destination (
X_to_organization_id     IN NUMBER,
X_item_id                IN NUMBER,
X_destination_type_code  IN VARCHAR2,
X_deliver_to_location_id IN NUMBER,
X_subinventory           IN VARCHAR2)
RETURN NUMBER IS

under_lot_control     BOOLEAN     := FALSE;
under_serial_control  BOOLEAN     := FALSE;
valid_subinventory    NUMBER      := 0;
location_is_valid     NUMBER      := 1;
X_progress            VARCHAR2(4) := '000';

BEGIN

   /*
   ** Make sure the destination organization is not null since that
   ** is a requirement irregardless of the desintation type
   */
   IF (X_to_organization_id IS NULL) THEN
      RETURN (10);
   END IF;

   IF (X_destination_type_code IN ('EXPENSE', 'SHOP FLOOR')) THEN

       -- dbms_output.put_line ('val_deliver_destination : validating location');

        /*
        ** The only required info for expense is the
        **  deliver to location
        */
        IF (X_deliver_to_location_id IS NULL) THEN
            RETURN (20);

        ELSE
           /*
           ** Make sure that the location is still valid
           */
           location_is_valid := po_locations_s.val_location (
               X_deliver_to_location_id,
               X_destination_type_code,
	       X_to_organization_id);

           /*
           ** if the location is not valid then this transaction cannot be
           ** processed
           */
           IF (location_is_valid <> 0) THEN
               RETURN (30);

               -- dbms_output.put_line ('val_deliver_destination : invalid location');

           END IF;

        END IF;

   ELSIF (X_destination_type_code = 'INVENTORY') THEN

       -- dbms_output.put_line ('val_deliver_destination : validating sub');

      /*
      ** Make sure that you have a  subinventory defined
      */
      IF (X_subinventory IS NULL) THEN

         -- dbms_output.put_line ('val_deliver_destination : invalid sub');
         RETURN (40);

      END IF;


      /*
      ** Validate that the sub on the po was valid
      ** Validate sub should only  return true or false
      ** or have predefined values as defines so we don't have to
      ** know the codes
      */

      X_progress := '1210';
      valid_subinventory := po_subinventories_s.val_subinventory (
                 X_subinventory,
                 X_to_organization_id,
                 TRUNC(sysdate),
                 X_item_id,
                 X_destination_type_code);

       IF (valid_subinventory <> 0) THEN

            -- dbms_output.put_line ('val_deliver_destination : invalid sub');
            RETURN (50);

       END IF;


   ELSE
        /*
        ** The destination type code is goofed and we cannot therefore
        ** transact the row.
        */
        RETURN (60);

   END IF;

   RETURN (0);

   EXCEPTION
   WHEN OTHERS THEN
      -- dbms_output.put_line('Progess is :' || X_Progress);
      po_message_s.sql_error('val_deliver_destination', X_progress, sqlcode);
   RAISE;

END val_deliver_destination;

/*===========================================================================

 PROCEDURE NAME:	val_destination_info

 Ensure that all destination information is still valid at the time of
 receipt.  A po can be created with a ship to location or a deliver to
 location that could become invalid by the time the receipt is entered.
 To ensure that the lov's for one of these fields does not come up
 because the item is not in the valid list, we will not populate the
 column if it is disabled

=============================================================================*/

PROCEDURE val_destination_info (
X_to_organization_id        IN NUMBER,
X_item_id                   IN NUMBER,
X_ship_to_location_id       IN NUMBER,
X_deliver_to_location_id    IN NUMBER,
X_deliver_to_person_id      IN NUMBER,
X_subinventory              IN VARCHAR2,
X_valid_ship_to_location    OUT NOCOPY BOOLEAN,
X_valid_deliver_to_location OUT NOCOPY BOOLEAN,
X_valid_deliver_to_person   OUT NOCOPY BOOLEAN,
X_valid_subinventory        OUT NOCOPY BOOLEAN) IS

X_return_val          NUMBER      := 0;
location_is_valid     NUMBER      := 1;
X_progress            VARCHAR2(4) := '000';
x_del_per_val         VARCHAR2(240);   -- for bug 2392074

BEGIN

   X_progress := '000';

   /*
   ** Make sure that the ship to location is still valid
   */
   IF (X_ship_to_location_id IS NOT NULL) THEN

      X_valid_ship_to_location := po_locations_s.val_receipt_site_in_org (
         X_ship_to_location_id,
         X_to_organization_id);

   END IF;

   X_progress := '010';

   /*
   ** Make sure that the deliver to location is still valid
   */
   IF (X_deliver_to_location_id IS NOT NULL) THEN

      X_return_val := po_locations_s.val_location (
         X_deliver_to_location_id,
         'RECEIVING',
         X_to_organization_id);

      /*
      ** The return for this is a number: 0 is valid, anything else is invalid
      */
      IF (X_return_val = 0) THEN

         X_valid_deliver_to_location := TRUE;

      ELSE

         X_valid_deliver_to_location := FALSE;

      END IF; --(X_return_val = 0)

   END IF; -- (X_deliver_to_location_id IS NOT NULL)

   X_progress := '020';

   /*
   ** Make sure that the deliver to person is still valid
   */
   IF (X_deliver_to_person_id IS NOT NULL) THEN

      /*
      ** Debug: Need to add a function to PO_EMPLOYEES_SV to
      ** ensure this person is still active when the receipt
      ** is done.  We'll set it to true for now
      */

       /* Added the validation on deliver to person
         for Bug 2392074.
      */
      /* Replace view hr_employees_current_v with view
         per_workforce_current_x to enable requester from
	 another BG for bug 9157396
      */
      SELECT  nvl(max(hre.full_name),'notfound')
        INTO  x_del_per_val
        FROM   per_workforce_current_x hre
       WHERE (hre.termination_date IS NULL
        OR  hre.termination_date > sysdate)
        AND hre.person_id = x_deliver_to_person_id;

      if (x_del_per_val='notfound') then
        X_valid_deliver_to_person := FALSE;
      else
       X_valid_deliver_to_person :=TRUE;
      end if;


   END IF;

   X_progress := '030';

   /*
   ** Make sure that the subinventory is still valid
   */
   -- Bug 5495768 : Validation os subinventory should be done only if
   -- item_id is not null.In case of one time items, the item_id is
   -- nul.So subinventory validation is not needed.

   IF (X_subinventory IS NOT NULL AND x_item_id IS NOT NULL) THEN

      X_return_val := po_subinventories_s.val_subinventory (
         x_subinventory, x_to_organization_id, sysdate,
         x_item_id, 'INVENTORY');

      /*
      ** The return for this is a number: 0 is valid, anything else is invalid
      */
      IF (X_return_val = 0) THEN

         X_valid_subinventory := TRUE;

      ELSE

         X_valid_subinventory := FALSE;

      END IF; --(X_return_val = 0)

   END IF; -- (X_subinventory IS NOT NULL)

   RETURN;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_destination_info', x_progress, sqlcode);
   RAISE;

END val_destination_info;

/*===========================================================================

  FUNCTION NAME:	val_pending_receipt_trx

===========================================================================*/
/*
** If there are any receipt supply rows that have not been delivered
** and this line location has multiple distributions then it cannot be
** transacted since you don't know how the user will distribute that
** quantity
*/

FUNCTION val_pending_receipt_trx (
X_po_line_location_id IN NUMBER,
X_group_id            IN NUMBER)
RETURN BOOLEAN IS

X_num_of_distributions       NUMBER  := 0;
X_num_of_receipts            NUMBER  := 0;
X_progress       	     VARCHAR2(4)  := '000';

BEGIN

   /*
   ** This is only an issue for vendor sourced express transactions since
   ** they are the only ones that can have multiple distributions
   */

   /*
   ** Get the number of distributions for this line_location.
   */
   X_progress := '500';

   SELECT count (1)
   INTO   X_num_of_distributions
   FROM   po_distributions pod
   WHERE  pod.line_location_id = X_po_line_location_id;

   -- dbms_output.put_line ('val_pending_transactions : X_num_of_distribtions : ' ||
--	TO_CHAR(X_num_of_distributions));

   IF (X_num_of_distributions > 1) THEN

      SELECT count (1)
      INTO   X_num_of_receipts
      FROM   rcv_supply rs
      WHERE  rs.po_line_location_id = X_po_line_location_id;

      -- dbms_output.put_line ('val_pending_transactions : X_num_of_receipts : ' ||
--	   TO_CHAR(X_num_of_receipts));

      /*
      ** If there is any receiving supply for this line location and there
      ** are multiple distributions then fail the transaction
      */
      IF (X_num_of_receipts > 0) THEN

         RETURN FALSE;

      END IF ;

   END IF;

   RETURN TRUE;

   EXCEPTION
   /*
   ** If no rows were found then the transaction is ok
   */
   WHEN NO_DATA_FOUND THEN
      RETURN TRUE;
   WHEN OTHERS THEN
      po_message_s.sql_error('val_pending_receipt_trx', x_progress, sqlcode);
   RAISE;

END val_pending_receipt_trx;

/*===========================================================================

  PROCEDURE NAME:	get_wip_info

===========================================================================*/
/*
** Go get the outside processing information for a given receipt line
*/

PROCEDURE get_wip_info
(X_wip_entity_id              IN          NUMBER,
 X_wip_repetitive_schedule_id IN          NUMBER,
 X_wip_line_id                IN          NUMBER,
 X_wip_operation_seq_num      IN          NUMBER,
 X_wip_resource_seq_num       IN          NUMBER,
 X_to_organization_id         IN          NUMBER,
 X_job                        IN OUT NOCOPY      VARCHAR2,
 X_line_num                   IN OUT NOCOPY      VARCHAR2,
 X_sequence                   IN OUT NOCOPY      NUMBER,
 X_department                 IN OUT NOCOPY      VARCHAR2) IS

X_progress       	     VARCHAR2(4)  := '000';

BEGIN
--Bug# 2000013 togeorge 09/18/2001
--Eam: Split the following sql to 3 different sqls because eAM w/o would
--     not have resource information and this sql will fail.
/*
   SELECT   we.wip_entity_name   job,
            wn.operation_seq_num sequence,
            bd.department_code   department
   INTO     X_job,
            X_sequence,
            X_department
   FROM     wip_entities we,
            bom_departments bd,
            wip_operation_resources wr,
            wip_operations wn,
            wip_operations wo
   WHERE    wo.wip_entity_id = X_wip_entity_id
   AND      wo.organization_id = X_to_organization_id
   AND      nvl(wo.repetitive_schedule_id, -1) =
               nvl(X_wip_repetitive_schedule_id, -1)
   AND      wo.operation_seq_num = X_wip_operation_seq_num
   AND      wr.wip_entity_id = X_wip_entity_id
   AND      wr.organization_id = X_to_organization_id
   AND      nvl(wr.repetitive_schedule_id, -1) =
               nvl(X_wip_repetitive_schedule_id, -1)
   AND      wr.operation_seq_num = X_wip_operation_seq_num
   AND      wr.resource_seq_num = X_wip_resource_seq_num
   AND      wn.wip_entity_id = X_wip_entity_id
   AND      wn.organization_id = X_to_organization_id
   AND      nvl(wn.repetitive_schedule_id, -1) =
               nvl(X_wip_repetitive_schedule_id, -1)
   AND      wn.operation_seq_num =
              decode(wr.autocharge_type,  4,
                 nvl(wo.next_operation_seq_num, wo.operation_seq_num),
                   wo.operation_seq_num)
   AND      bd.department_id = wn.department_id
   AND      we.wip_entity_id = X_wip_entity_id
   AND      we.organization_id = X_to_organization_id;
*/

  if X_wip_entity_id is not null then
   begin
   SELECT we.wip_entity_name job
     INTO X_job
     FROM wip_entities we
    WHERE we.wip_entity_id = X_wip_entity_id
      AND we.organization_id = X_to_organization_id;
   exception
   when others then
   X_job := null;
   end;
  end if;

  if X_wip_entity_id is not null and X_wip_operation_seq_num is not null then
   begin
   SELECT  wn.operation_seq_num sequence,
           bd.department_code   department
     INTO  X_sequence, X_department
     FROM  bom_departments bd,
           wip_operation_resources wr,
           wip_operations wn,
           wip_operations wo
    WHERE  wo.wip_entity_id = X_wip_entity_id
      AND  wo.organization_id = X_to_organization_id
      AND  nvl(wo.repetitive_schedule_id, -1) =
           nvl(X_wip_repetitive_schedule_id, -1)
      AND  wo.operation_seq_num = X_wip_operation_seq_num
      AND  wr.wip_entity_id = X_wip_entity_id
      AND  wr.organization_id = X_to_organization_id
      AND  nvl(wr.repetitive_schedule_id, -1) =
           nvl(X_wip_repetitive_schedule_id, -1)
      AND  wr.operation_seq_num = X_wip_operation_seq_num
      AND  wr.resource_seq_num = X_wip_resource_seq_num
      AND  wn.wip_entity_id = X_wip_entity_id
      AND  wn.organization_id = X_to_organization_id
      AND  nvl(wn.repetitive_schedule_id, -1) =
           nvl(X_wip_repetitive_schedule_id, -1)
      AND  wn.operation_seq_num = wo.operation_seq_num
   -- Bug#2738959 : Removed the decode statement for autocharge_type 4
   --               Replaced the following statement with the one above.
   --               Comparing with operation_seq_num instead of next_operation_seq_num
   --   AND  wn.operation_seq_num =
   --        decode(wr.autocharge_type,  4,
   --            nvl(wo.next_operation_seq_num, wo.operation_seq_num),
   --               wo.operation_seq_num)
      AND  bd.department_id = wn.department_id;
   exception
      when no_data_found then
       --for EAM workorders the above sql would raise no_data_found.
       --find department code and sequence with out touching resource table.
       begin
       select bd.department_code department
         into X_department
         from bom_departments bd,wip_operations wn
        where wn.wip_entity_id = X_wip_entity_id
          and wn.organization_id = X_to_organization_id
          and nvl(wn.repetitive_schedule_id, -1) =
    	  nvl(X_wip_repetitive_schedule_id, -1)
          and bd.department_id = wn.department_id;
          exception
          when others then
          X_department :=null;
       end;

	begin
        SELECT  wo.operation_seq_num sequence
          INTO  X_sequence
          FROM  wip_operations wo
         WHERE  wo.wip_entity_id = X_wip_entity_id
           AND  wo.organization_id = X_to_organization_id
           AND  nvl(wo.repetitive_schedule_id, -1) =
               nvl(X_wip_repetitive_schedule_id, -1)
           AND  wo.operation_seq_num = X_wip_operation_seq_num;
        exception
	 when others then
	 X_sequence := null;
	end;
   when others then
        X_sequence :=null;
        X_department :=null;
   end;
  end if;
  --
   IF (X_wip_line_id IS NOT NULL) THEN

	select wl.line_code
	into   X_line_num
	from   wip_lines wl
	where  wl.organization_id = X_to_organization_id
	and    wl.line_id = X_wip_line_id;

   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_wip_info', x_progress, sqlcode);
   RAISE;

END get_wip_info;

/*===========================================================================
 *
 *   PROCEDURE NAME:       get_rma_dest_info
 *
 *===========================================================================*/
/*
 * ** Get the destination info for the RMA line.
 * */

PROCEDURE get_rma_dest_info
(x_oe_order_header_id    IN NUMBER,
x_oe_order_line_id       IN NUMBER,
x_item_id                IN NUMBER,
x_deliver_to_sub         IN OUT NOCOPY VARCHAR2,
x_deliver_to_location_id IN OUT NOCOPY NUMBER,
x_deliver_to_location    IN OUT NOCOPY VARCHAR2,
x_destination_type_dsp   IN OUT NOCOPY VARCHAR2,
x_destination_type_code  IN OUT NOCOPY VARCHAR2,
x_to_organization_id     IN OUT NOCOPY NUMBER,
x_rate                   IN OUT NOCOPY NUMBER,
x_rate_date              IN OUT NOCOPY DATE) IS

X_progress                   VARCHAR2(4)  := '000';

X_valid_ship_to_location     BOOLEAN;
X_valid_deliver_to_location  BOOLEAN;
X_valid_deliver_to_person    BOOLEAN;
X_valid_subinventory         BOOLEAN;

BEGIN

      X_progress := '010';

      select displayed_field, lookup_code
      into   x_destination_type_dsp, x_destination_type_code
      from   po_lookup_codes
      where  lookup_code = 'RECEIVING'
      and    lookup_type = 'RCV DESTINATION TYPE';

      X_progress := '020';

      /* get subinventory, rate, rate_date, item_id, to_organization_id */
      select oel.subinventory,
             NVL(oel.ship_from_org_id, oeh.ship_from_org_id),
             oeh.conversion_rate,
             oeh.conversion_rate_date
      into   x_deliver_to_sub,
             x_to_organization_id,
             x_rate,
             x_rate_date
      from   oe_order_lines_all oel,
             oe_order_headers_all oeh
      where  oeh.header_id = x_oe_order_header_id
      and    oel.line_id = x_oe_order_line_id;

      X_progress := '030';

      /* get location_id and location_code */
      select haou.location_id,
             hla.location_code
      into   x_deliver_to_location_id,
             x_deliver_to_location
      from   hr_all_organization_units haou,
             hr_locations_all hla
      where  haou.organization_id = x_to_organization_id
      and    haou.location_id = hla.location_id;


      /*
      ** Make sure the dest information is still valid
      */
      rcv_transactions_sv.val_destination_info (
         X_to_organization_id,
         X_item_id,
         NULL,
         X_deliver_to_location_id,
         NULL,
         X_deliver_to_sub,
         X_valid_ship_to_location,
         X_valid_deliver_to_location,
         X_valid_deliver_to_person,
         X_valid_subinventory);

      IF (NOT X_valid_deliver_to_location) THEN
         X_deliver_to_location_id := NULL;
         X_deliver_to_location := NULL;
      END IF;

      IF (NOT X_valid_subinventory) THEN
         X_deliver_to_sub := NULL;
      END IF;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_rma_dest_info', x_progress, sqlcode);
      RAISE;

END get_rma_dest_info;

END RCV_TRANSACTIONS_SV;

/
