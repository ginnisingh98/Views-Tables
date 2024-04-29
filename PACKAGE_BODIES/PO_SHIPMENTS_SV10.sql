--------------------------------------------------------
--  DDL for Package Body PO_SHIPMENTS_SV10
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHIPMENTS_SV10" as
/* $Header: POXPOSAB.pls 120.3 2006/07/27 23:47:08 dreddy noship $*/

/*===========================================================================

  FUNCTION  NAME:	val_approval_status

===========================================================================*/
   FUNCTION val_approval_status
		      (X_shipment_id             IN NUMBER,
		       X_shipment_type           IN VARCHAR2,
		       X_quantity                IN NUMBER,
		       X_amount                  IN NUMBER,
		       X_ship_to_location_id     IN NUMBER,
		       X_promised_date           IN DATE,
		       X_need_by_date            IN DATE,
		       X_shipment_num            IN NUMBER,
		       X_last_accept_date        IN DATE,
		       X_taxable_flag            IN VARCHAR2,
		       X_ship_to_organization_id IN NUMBER,
		       X_price_discount          IN NUMBER,
		       X_price_override          IN NUMBER,
		       X_tax_code_id		 IN NUMBER,
                       p_start_date              IN DATE,   /* <TIMEPHASED FPI> */
                       p_end_date                IN DATE,   /* <TIMEPHASED FPI> */
                       p_days_early_receipt_allowed IN NUMBER)  -- <INBOUND LOGISTICS FPJ>
RETURN NUMBER IS

      X_need_to_approve         NUMBER := NULL;
      X_progress                VARCHAR2(3)  := '';

      X_temp_quantity            NUMBER;
      X_temp_amount              NUMBER;
      X_temp_ship_to_location_id NUMBER;
      X_temp_promised_date       DATE;
      X_temp_need_by_date        DATE;
      X_temp_shipment_num        NUMBER;
      X_temp_last_accept_date    DATE;
      X_temp_price_discount      NUMBER;
      X_temp_price_override      NUMBER;
      X_temp_ship_to_organization_id NUMBER;
      X_temp_taxable_flag            VARCHAR2(1);
      l_temp_start_date          DATE;   /* <TIMEPHASED FPI> */
      l_temp_end_date            DATE;   /* <TIMEPHASED FPI> */
      l_days_early_receipt_allowed NUMBER; -- <INBOUND LOGISTICS FPJ>

      BEGIN

         IF (X_shipment_type = 'STANDARD' OR X_shipment_type = 'PLANNED' OR
             X_shipment_type = 'SCHEDULED' OR X_shipment_type = 'BLANKET' OR
             X_shipment_type = 'PRICE BREAK' ) THEN

	    X_progress := '010';

            /* <TIMEPHASED FPI> */
            /*
               Getting the start_date and end_date values to be used in determining
               whether the document requires reapproval.
            */
	    SELECT PLL.quantity,
                   PLL.amount,   -- Bug 5409088
                   PLL.ship_to_location_id,
                   PLL.promised_date,
                   PLL.need_by_date,
                   PLL.shipment_num,
                   PLL.last_accept_date,
                   PLL.price_discount,
                   PLL.price_override,
                   PLL.ship_to_organization_id,
                   PLL.taxable_flag,
                   PLL.start_date,   /* <TIMEPHASED FPI> */
                   PLL.end_date,     /* <TIMEPHASED FPI> */
                   PLL.days_early_receipt_allowed  --<INBOUND LOGISTICS FPJ>
            INTO   X_temp_quantity,
                   X_temp_amount,   -- Bug 5409088
                   X_temp_ship_to_location_id,
                   X_temp_promised_date,
                   X_temp_need_by_date,
                   X_temp_shipment_num,
                   X_temp_last_accept_date,
                   X_temp_price_discount,
                   X_temp_price_override,
                   X_temp_ship_to_organization_id,
                   X_temp_taxable_flag,
                   l_temp_start_date,   /* <TIMEPHASED FPI> */
                   l_temp_end_date,     /* <TIMEPHASED FPI> */
                   l_days_early_receipt_allowed  --<INBOUND LOGISTICS FPJ>
	    FROM   PO_LINE_LOCATIONS PLL
	    WHERE  PLL.line_location_id    = X_shipment_id;

            -- Bug 5409088 : Added amount check for service lines
	    if ((X_temp_quantity <> X_quantity )
	         OR (X_temp_quantity is NULL
	             AND
		     X_quantity is NOT NULL)
                 OR (X_temp_quantity is NOT NULL
		     AND
		     X_quantity is NULL)
               OR (X_temp_amount <> X_amount )
	       OR (X_temp_amount is NULL
	           AND
		   X_amount is NOT NULL)
               OR (X_temp_amount is NOT NULL
		   AND
		   X_amount is NULL)
	       OR (X_temp_ship_to_location_id <> X_ship_to_location_id)
	       OR (X_temp_ship_to_location_id is NULL
		   AND
		   X_ship_to_location_id IS NOT NULL)
	       OR (X_temp_ship_to_location_id IS NOT NULL
		   AND
		   X_ship_to_location_id IS NULL)
	       OR (X_temp_promised_date       <> X_promised_date)
	       OR (X_temp_promised_date IS NULL
	           AND
	           X_promised_date IS NOT NULL)
	       OR (X_temp_promised_date IS NOT NULL
		   AND
		   X_promised_date IS NULL)
	       OR (X_temp_need_by_date        <> X_need_by_date)
	       OR (X_temp_need_by_date IS NULL
		   AND
		   X_need_by_date IS NOT NULL)
	       OR (X_temp_need_by_date IS NOT NULL
		   AND
		   X_need_by_date IS NULL)
	       OR (X_temp_shipment_num        <> X_shipment_num)
	       OR (X_temp_shipment_num IS NULL
	           AND
		   X_shipment_num IS NOT NULL)
	       OR (X_temp_shipment_num IS NOT NULL
		   AND
		   X_shipment_num IS NULL)
               /* <TIMEPHASED FPI START> */
               /*
                  If the passed in dates are different that the values in the
                  database, the document needs to go through reapproval
               */
               OR (l_temp_start_date <> p_start_date)
               OR (l_temp_start_date is null AND p_start_date is not null)
               OR (l_temp_start_date is not null AND p_start_date is null)
               OR (l_temp_end_date <> p_end_date)
               OR (l_temp_end_date is null AND p_end_date is not null)
               OR (l_temp_end_date is not null AND p_end_date is null)
               /* <TIMEPHASED FPI END> */
               -- <INBOUND LOGISTICS FPJ START>
               OR (l_days_early_receipt_allowed <> p_days_early_receipt_allowed)
               OR (l_days_early_receipt_allowed IS NULL AND p_days_early_receipt_allowed IS NOT NULL)
               OR (l_days_early_receipt_allowed IS NOT NULL AND p_days_early_receipt_allowed IS NULL)
               -- <INBOUND LOGISTICS FPJ END>
               ) then

            /* Unapprove Both the doc and the shipment */

               X_need_to_approve := 2;

              end if;

	       if ( (X_temp_last_accept_date    <> X_last_accept_date)

	       OR (X_temp_last_accept_date IS NULL
		   AND
		   X_last_accept_date IS NOT NULL)
	       OR (X_temp_last_accept_date IS NOT NULL
	           AND
	           X_last_accept_date IS NULL)
                OR (X_temp_price_discount      <> X_price_discount)
	       OR (X_temp_price_discount IS NULL
		   AND
		   X_price_discount IS NOT NULL)
	       OR (X_temp_price_discount IS NOT NULL
	           AND
		   X_price_discount IS NULL)
               OR (X_temp_price_override      <> X_price_override)
	       OR (X_temp_price_override IS NULL
		   AND
		   X_temp_price_override IS NOT NULL)
	       OR (X_temp_price_override IS NOT NULL
		   AND
		   X_price_override IS NULL)
               OR (X_temp_ship_to_organization_id <> X_ship_to_organization_id)
	       OR (X_temp_ship_to_organization_id IS NULL
		   AND
		   X_ship_to_organization_id IS NOT NULL)
	       OR (X_temp_ship_to_organization_id IS NOT NULL
		   AND
		   X_ship_to_organization_id IS NULL)) then

          /* Unapprove Both the doc and the shipment */

               X_need_to_approve := 2;

              end if;

           --<Bug 5185802> Taxable flag field has been removed from the UI,
           --removed the condition to unapprove document on change of taxable
           --flag. x_need_to_approve := 1 does not exist anymore

           if X_need_to_approve is NULL then

              /* Do not Unapprove */

              X_need_to_approve := 0;

           end if;

         end if;  /* Shipment TYpe Check */


/*
	IF ((X_need_to_approve = 1) or
            (X_need_to_approve = 2)) THEN
	   dbms_output.put_line('status changed = Y');

	ELSE
	   dbms_output.put_line('status changed = N');

        END IF;
*/
        return(X_need_to_approve);

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
--	   dbms_output.put_line('No data found');
	   return(0);
	WHEN OTHERS THEN
--	  dbms_output.put_line('In UPDATE exception');
	  po_message_s.sql_error('val_approval_status', X_progress, sqlcode);
          raise;
      END val_approval_status;
/*===========================================================================

  FUNCTION  NAME:	get_rcv_routing_name

===========================================================================*/
  FUNCTION get_rcv_routing_name
		      (X_rcv_routing_id             IN NUMBER)
            return varchar2 is
    X_rcv_routing_name varchar2(80);
    X_progress  varchar2(3) := null;
  begin
      X_progress := '010';
      select routing_name
      into X_rcv_routing_name
      from rcv_routing_headers
      where routing_header_id = X_rcv_routing_id;
      return(X_rcv_routing_name);
  exception
       WHEN NO_DATA_FOUND THEN
--	   dbms_output.put_line('No data found');
	   return(null);
       when others then
--          dbms_output.put_line('In get_rcv_routing_name');
	  po_message_s.sql_error('get_rcv_routing_name', X_progress, sqlcode);
          raise;
  END get_rcv_routing_name;


/*===========================================================================

  PROCEDURE NAME:	get_original_date()

===========================================================================*/
 procedure get_shipment_post_query_info(X_line_location_id 	IN NUMBER,
					X_shipment_type    	IN VARCHAR2,
					X_item_id          	IN NUMBER,
					X_ship_to_org_id 	IN NUMBER,
					X_total			IN OUT NOCOPY NUMBER,
					X_total_rtot_db		IN OUT NOCOPY NUMBER,
                                        X_original_Date    	IN OUT NOCOPY DATE,
					X_item_status		IN OUT NOCOPY VARCHAR2,
                                        x_project_references_enabled IN OUT NOCOPY NUMBER,
                                        x_project_control_level IN OUT NOCOPY NUMBER) IS

 X_Progress varchar2(3) := '';

 BEGIN

       X_Progress := '010';

       --
       -- Get the total from distributions
       --

       X_total := 0;
       X_total_rtot_db := 0;

       IF X_shipment_type NOT IN ('BLANKET','SCHEDULED') THEN
       	     if X_line_location_id is not null then
          	select nvl(sum(quantity_ordered),0),nvl(sum(quantity_ordered),0)
          	into   X_total, X_total_rtot_db
          	from po_distributions pod
          	where pod.line_location_id = X_line_location_id;
       	     else
          	X_total := 0;
          	X_total_rtot_db := 0;
       	    end if;
	END IF;

       --
       -- Get the original commitment date
       --
       po_shipments_sv7.get_original_date (X_line_location_id,
                                           X_original_date);

       --
       -- Get the Item_status.
       --
       po_items_sv2.get_item_status (X_item_id,
                                     X_ship_to_org_id,
                                     x_item_status );

       po_core_s4.get_mtl_parameters(X_ship_to_org_id, NULL,
                                     x_project_references_enabled,
                                     x_project_control_level);

 EXCEPTION

    WHEN no_data_found then
         null;
    WHEN others then
         po_message_s.sql_error('get_shipment_post_query_info',X_Progress,sqlcode);
         raise;

 END get_shipment_post_query_info;

/*==============================================================================
Procedure       get_price_update_flag
Description:    Decides whether shipment price should be updatable or not.
==============================================================================*/
procedure get_price_update_flag(X_line_location_id      IN NUMBER,
                                X_expense_accrual_code  in varchar2,
                                X_quantity_received     in number,
                                X_quantity_billed       in number,
                                X_prevent_price_update_flag in out NOCOPY varchar2) is
-- <FPJ Retroactive Price START>
l_retroactive_update  VARCHAR2(30) := 'NEVER';
l_archive_mode_rel    PO_DOCUMENT_TYPES.archive_external_revision_code%TYPE;
l_encumbrance_on       VARCHAR2(1);
l_current_org_id       NUMBER;
-- Bug 3231062
l_retro_prj_allowed   VARCHAR2(1);
-- <FPJ Retroactive Price END>

begin


	-- <FPJ Retroactive Price START>
        l_current_org_id     := PO_GA_PVT.get_current_org;
	l_retroactive_update := PO_RETROACTIVE_PRICING_PVT.Get_Retro_Mode;
        -- Bug 3565522 : get the archive mode
        l_archive_mode_rel   := PO_DOCUMENT_ARCHIVE_PVT.get_archive_mode(
                                      p_doc_type    => 'RELEASE',
                                      p_doc_subtype => 'BLANKET');
        IF PO_CORE_S.is_encumbrance_on(p_doc_type => 'RELEASE',
                                       p_org_id   => l_current_org_id)
        THEN
           l_encumbrance_on  :=  'Y';
        ELSE
           l_encumbrance_on  :=  'N';
        END IF;
        -- Bug 3231062
        l_retro_prj_allowed := PO_RETROACTIVE_PRICING_PVT.Is_Retro_Project_Allowed(
                                 p_std_po_price_change => 'N',
                                 p_po_line_id          => NULL,
                                 p_po_line_loc_id      => X_line_location_id);

	-- <FPJ Retroactive Price END>

        /* Bug #1916593, uncommented the below sql which will allow the
 	   price updation on a Release */
        SELECT 'Y'
        INTO   x_prevent_price_update_flag
        FROM DUAL
        WHERE EXISTS
        (SELECT 'prevent price udpate'
        FROM   po_distributions
        WHERE  line_location_id = x_line_location_id
        AND
         (
            (
            (destination_type_code in ('INVENTORY','SHOP FLOOR')
                   OR (destination_type_code='EXPENSE'
                   AND (x_expense_accrual_code = 'RECEIPT'
			OR X_quantity_billed > 0)))
        AND    (x_quantity_received > 0 OR
                x_quantity_billed > 0)
	-- <FPJ Retroactive Price START>
        AND   (l_retroactive_update <> 'ALL_RELEASES' OR
               (l_retroactive_update = 'ALL_RELEASES' AND
                l_encumbrance_on = 'Y' ) OR         -- Bug 3573266
               (l_retroactive_update = 'ALL_RELEASES' AND
                l_archive_mode_rel <> 'APPROVE') OR   -- Bug 3565522
               (l_retroactive_update = 'ALL_RELEASES' AND
                l_retro_prj_allowed = 'N')) )  -- Bug 3231062
	-- <FPJ Retroactive Price END>
            --<Encumbrance FPJ>
         OR (encumbered_flag = 'Y')
         )
        );

        EXCEPTION
        WHEN NO_DATA_FOUND then null;
        WHEN OTHERS then raise;

end get_price_update_flag;


END  PO_SHIPMENTS_SV10;

/
