--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_SV2" as
/* $Header: POXPOH2B.pls 120.1.12010000.3 2012/01/02 09:00:20 ksrimatk ship $*/

/*===========================================================================

  PROCEDURE NAME:	val_approval_status()

===========================================================================*/

 FUNCTION  val_approval_status(X_po_header_id             IN NUMBER,
		               X_agent_id                 IN NUMBER,
                               X_vendor_site_id           IN NUMBER,
                               X_vendor_contact_id        IN NUMBER,
                               X_confirming_order_flag    IN VARCHAR2,
                               X_ship_to_location_id      IN NUMBER,
                               X_bill_to_location_id      IN NUMBER,
                               X_terms_id                 IN NUMBER,
                               X_ship_via_lookup_code     IN VARCHAR2,
                               X_fob_lookup_code          IN VARCHAR2,
                               X_freight_terms_lookup_code IN VARCHAR2,
                               X_note_to_vendor            IN VARCHAR2,
                               X_acceptance_required_flag  IN VARCHAR2,
                               X_acceptance_due_date       IN DATE,
                               X_blanket_total_amount      IN NUMBER,
                               X_start_date                IN DATE,
                               X_end_date                  IN DATE,
                               X_amount_limit             IN NUMBER
			       ,p_kterms_art_upd_date       IN DATE --<CONTERMS FPJ>
			       ,p_kterms_deliv_upd_date     IN DATE --<CONTERMS FPJ>
                               ,p_shipping_control        IN VARCHAR2  -- <INBOUND LOGISTICS FPJ>
			       )
            return boolean is
            X_unapprove_doc  boolean;

            X_progress VARCHAR2(3) := NULL;
            X_change_status varchar2(1) :=  'N';

BEGIN
         /* Check if there has been any change in the fields that
         ** affect the approval status. If so , return TRUE to
         ** indicate that the approval status has to be changed */

          SELECT 'Y'
          INTO   X_change_status
          FROM PO_HEADERS POH
          WHERE (poh.po_header_id = X_po_header_id)
          AND   ( (poh.agent_id <> X_agent_id)
                 OR
                  (poh.agent_id is NULL AND
                   X_agent_id is NOT NULL)
                 OR (poh.agent_id is NOT NULL AND
                     X_agent_id is  NULL)
                 OR (poh.vendor_site_id <> X_vendor_site_id)
                 OR (poh.vendor_site_id is NULL AND
                     X_vendor_site_id is NOT NULL)
                 OR (poh.vendor_site_id is NOT NULL AND
                     X_vendor_site_id is NULL)
                 OR (poh.vendor_contact_id <> X_vendor_contact_id )
                 OR (poh.vendor_contact_id is NULL AND
                     X_vendor_contact_id is NOT NULL)
                 OR (poh.vendor_contact_id is NOT NULL AND
                     X_vendor_contact_id is NULL)
                 OR (poh.confirming_order_flag <> X_confirming_order_flag)
                 OR (poh.confirming_order_flag is NULL AND
                     X_confirming_order_flag is NOT NULL)
                 OR (poh.confirming_order_flag is NOT NULL AND
                     X_confirming_order_flag is NULL)
                 OR (poh.ship_to_location_id <> X_ship_to_location_id)
                 OR (poh.ship_to_location_id is NULL AND
                     X_ship_to_location_id is NOT NULL)
                 OR (poh.ship_to_location_id is NOT NULL AND
                     X_ship_to_location_id is NULL)
                 OR (poh.bill_to_location_id <> X_bill_to_location_id)
                 OR (poh.bill_to_location_id is NULL AND
                     X_bill_to_location_id is NOT NULL)
                 OR (poh.bill_to_location_id is NOT NULL AND
                     X_bill_to_location_id is NULL)
                 OR (poh.terms_id <> X_terms_id )
                 OR (poh.terms_id is NULL AND
                     X_terms_id is NOT NULL)
                 OR (poh.terms_id is NOT NULL AND
                     X_terms_id is NULL)
                 OR ( poh.ship_via_lookup_code <> X_ship_via_lookup_code)
                 OR ( poh.ship_via_lookup_code is NOT NULL AND
                      X_ship_via_lookup_code is NULL)
                 OR ( poh.ship_via_lookup_code is NULL AND
                      X_ship_via_lookup_code is NOT NULL)
                 OR (poh.fob_lookup_code <> X_fob_lookup_code )
                 OR (poh.fob_lookup_code is NULL AND
                     X_fob_lookup_code is NOT NULL)
                 OR (poh.fob_lookup_code is NOT NULL AND
                     X_fob_lookup_code is NULL)
                 OR (poh.freight_terms_lookup_code <> X_freight_terms_lookup_code )
                 OR (poh.freight_terms_lookup_code is NULL AND
                     X_freight_terms_lookup_code is NOT NULL)
                 OR (poh.freight_terms_lookup_code is NOT NULL AND
                     X_freight_terms_lookup_code is  NULL)
                 OR (poh.note_to_vendor <> X_note_to_vendor )
                 OR (poh.note_to_vendor is NULL AND
                     X_note_to_vendor is NOT NULL)
                 OR (poh.note_to_vendor is NOT NULL AND
                     X_note_to_vendor is NULL)
                 OR (poh.acceptance_required_flag <> X_acceptance_required_flag)
                 OR (poh.acceptance_required_flag is NULL AND
                     X_acceptance_required_flag is NOT NULL)
                 OR (poh.acceptance_required_flag is NOT NULL AND
                     X_acceptance_required_flag is NULL)
                 OR (poh.acceptance_due_date <> X_acceptance_due_date )
                 OR (poh.acceptance_due_date is NULL AND
                     X_acceptance_due_date is NOT NULL)
                 OR (poh.acceptance_due_date is NOT NULL AND
                     X_acceptance_due_date is NULL)
                 OR (poh.blanket_total_amount <> X_blanket_total_amount)
                 OR (poh.blanket_total_amount is NULL AND
                     X_blanket_total_amount is NOT NULL)
                 OR (poh.blanket_total_amount is NOT NULL AND
                     X_blanket_total_amount is NULL)
                 OR (poh.start_date <> X_start_date)
                 OR (poh.start_date is NULL AND
                     X_start_date is NOT NULL)
                 OR (poh.start_date is NOT NULL AND
                     X_start_date is NULL)
                 OR (poh.end_date  <> X_end_date  )
                 OR (poh.end_date is NULL AND
                     X_end_date is NOT NULL)
                 OR (poh.end_date is NOT NULL AND
                     X_end_date is NULL)
                 OR (poh.amount_limit <> X_amount_limit)
                 OR (poh.amount_limit is NULL AND
                     X_amount_limit is NOT NULL)
                 OR (poh.amount_limit is NOT NULL AND
                     X_amount_limit is NULL)

		 --<CONTERMS FPJ START>
                 OR (poh.conterms_articles_upd_date <> p_kterms_art_upd_date)
                 OR (poh.conterms_articles_upd_date is NULL AND
                     p_kterms_art_upd_date is NOT NULL)
                 OR (poh.conterms_articles_upd_date is NOT NULL AND
                     p_kterms_art_upd_date is NULL)

                 OR (poh.conterms_deliv_upd_date <> p_kterms_deliv_upd_date)
                 OR (poh.conterms_deliv_upd_date is NULL AND
                     p_kterms_deliv_upd_date is NOT NULL)
                 OR (poh.conterms_deliv_upd_date is NOT NULL AND
                     p_kterms_deliv_upd_date is NULL)

		 --<CONTERMS FPJ END>

                 -- <INBOUND LOGISTICS FPJ START>
                 OR (POH.shipping_control <> p_shipping_control)
                 OR (POH.shipping_control IS NULL AND
                     p_shipping_control IS NOT NULL)
                 OR ( POH.shipping_control IS NOT NULL AND
                     p_shipping_control IS NULL)
                 -- <INBOUND LOGISTICS FPJ END>
		     );


            if X_change_status = 'Y' then
               X_unapprove_doc := TRUE;
            else
               X_unapprove_doc := FALSE;
            end if;

            return(X_unapprove_doc);


   EXCEPTION
      when no_data_found then
	   --dbms_output.put_line('No data found');
           X_unapprove_doc := FALSE;
	   return(X_unapprove_doc);
      when others then
           po_message_s.sql_error('val_approval_status', x_progress, sqlcode);
           raise;

END val_approval_status;


/*===========================================================================

  PROCEDURE NAME:	update_children()

===========================================================================*/
/*
PROCEDURE update_children() IS

x_progress VARCHAR2(3) := NULL;

BEGIN


   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('update_children', x_progress, sqlcode);
   RAISE;

END update_children;   */



/*===========================================================================

  FUNCTION NAME:	val_release_date()

===========================================================================*/

 FUNCTION val_release_date(X_po_header_id IN number,
                           X_start_date  IN date,
                           X_end_date    IN date,
                           X_type_lookup_code IN varchar2,
                           X_menu_path   IN varchar2)
          return boolean IS
          X_success     boolean := TRUE;

          X_progress VARCHAR2(3) := '';


BEGIN

       if ((X_type_lookup_code = 'PLANNED') or
           (X_type_lookup_code = 'BLANKET')) then

        /* X_progress := '010';
         X_success := val_start_date(X_po_header_id,X_start_date);  */

       /* Check that there is no release already created against the PO
       **   after the specified end date. */

         if X_success then
            X_progress := '020';
            X_success := val_end_date( X_po_header_id,X_end_date);
         end if;

         if (not X_success) then
           return(X_success);
         end if;

       end if;

/* Bug 509797 ecso 6/26/97
   Move this validation to client side

       if (X_menu_path = 'PA') then
           X_progress := '030';
           X_success := po_notif_controls_sv.val_date_notif(X_po_header_id,X_end_date);
       end if;
*/
       return(X_success);

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_release_date', X_progress, sqlcode);
   RAISE;

END val_release_date;

/*===========================================================================

  FUNCTION NAME:	val_start_date()

===========================================================================*/

FUNCTION   val_start_date(X_po_header_id IN number,
                          X_start_date IN date )
                return boolean is
                X_valid_date boolean;

     X_progress  varchar2(3) := '000';

     cursor c1 is
            SELECT 'release exist prior to the effective date'
            FROM   po_releases
            WHERE  release_date < X_start_date
            AND    po_header_id = X_po_header_id;
     Recinfo c1%rowtype;

BEGIN

     X_progress := '010';
     open c1;
     X_progress := '020';
     fetch c1 into recinfo;

     X_progress := '030';

     if (c1%notfound) then
        close c1;
        X_valid_date := TRUE;
        return(X_valid_date);
     end if;

     X_progress := '040';

     X_valid_date := FALSE;
    /* po_message_s.app_error('PO_PO_START_DATE_LT_REL_DATE'); bug # 6363130 */
     return(X_valid_date);

EXCEPTION

    when others then
     po_message_s.sql_error('val_start_date',X_progress,sqlcode);
     raise;

END val_start_date;


/*===========================================================================

  FUNCTION NAME:	val_end_date()

===========================================================================*/

 FUNCTION  val_end_date(X_po_header_id IN number,
                            X_end_date IN date )
                return boolean is
                X_valid_date boolean ;

                X_progress VARCHAR2(3) := '';

         cursor c1 is
            SELECT 'release exist after the expiration  date'
            FROM   po_releases
                   -- <Action Date TZ FPJ: trunc added>
            WHERE  TRUNC(release_date) > X_end_date
            AND    po_header_id = X_po_header_id;

         Recinfo c1%rowtype;

BEGIN
     X_progress := '010';
     open c1;
     X_progress := '020';


     /* Check that there is no release against this PO after the date
        specified */

     fetch c1 into recinfo;

     X_progress := '030';

     if (c1%notfound) then
        close c1;
        X_valid_date := TRUE;
        return(X_valid_date);
     end if;

     X_progress := '040';

     X_valid_date := FALSE;
     po_message_s.app_error('PO_PO_END_DATE_GT_RELEASE_DATE');
     return(X_valid_date);

   EXCEPTION
      when others then
      po_message_s.sql_error('val_end_date', x_progress, sqlcode);
      raise;

END val_end_date;

/*==========================================================================

  PROCEDURE NAME : update_req_link()

===========================================================================*/

 PROCEDURE   update_req_link(X_po_header_id IN number) is

             X_progress  varchar2(3) := '';

 BEGIN
          X_progress := '010';

         /*  Update po_requisition_lines to remove the link to
 	     the shipment if you are deleting a standard or planned PO */

	 -- <REQINPOOL>: added update of reqs_in_pool_flag and of
	 -- WHO columns.

          UPDATE po_requisition_lines_all
   	  SET    line_location_id       = NULL
               , reqs_in_pool_flag      = 'Y'
	       , last_update_date       = SYSDATE
               , last_updated_by        = FND_GLOBAL.USER_ID
               , last_update_login      = FND_GLOBAL.LOGIN_ID
  	  WHERE  line_location_id in (SELECT line_location_id
                                      FROM   po_line_locations_all	--bug 8777237: changed po_line_locations to po_line_locations_all
                                      WHERE  po_header_id = X_po_header_id);

 EXCEPTION

    /* It is not mandatory that every PO has been created from a Req.
       So, if there is no data found, it is NOT an error */

      when no_data_found then
           null;


      when others then
           po_message_s.sql_error('update_req_link', X_progress, sqlcode);
           raise;

 END update_req_link;

/*===========================================================================

  PROCEDURE NAME:	get_po_details()

===========================================================================*/

 PROCEDURE get_po_details(X_po_header_id 	IN     NUMBER  ,
                          X_type_lookup_code    IN OUT NOCOPY VARCHAR2,
                          X_revision_num        IN OUT NOCOPY NUMBER  ,
		          X_currency_code       IN OUT NOCOPY VARCHAR2,
                          X_supplier_id         IN OUT NOCOPY NUMBER  ,
                          X_supplier_site_id    IN OUT NOCOPY NUMBER  ,
                          X_ship_to_location_id IN OUT NOCOPY NUMBER ) IS
         CURSOR C is
         SELECT POH.currency_code,
		POH.type_lookup_code,
	        POH.revision_num,
		POH.vendor_id,
		POH.vendor_site_id,
                POH.ship_to_location_id
         FROM   PO_HEADERS POH
	 WHERE  POH.po_header_id = X_po_header_id;


         X_progress VARCHAR2(3) := '';

BEGIN
       --dbms_output.put_line('Before open cursor');

       if (X_po_header_id is not null) then
	    X_progress := '010';
            OPEN C;
	    X_progress := '020';

           /* Get the following info for a given PO */

            FETCH C into X_currency_code,
			 X_type_lookup_code,
			 X_revision_num,
			 X_supplier_id,
			 X_supplier_site_id,
                         X_ship_to_location_id;

            CLOSE C;

	    --dbms_output.put_line('Currency Code'||X_currency_code);
	    --dbms_output.put_line('Type Lookup Code'||X_type_lookup_code);
	    --dbms_output.put_line('Revision'||X_revision_num);
	    --dbms_output.put_line('Supplier'||X_supplier_id);
	    --dbms_output.put_line('Supplier_site'||X_supplier_site_id);
	    --dbms_output.put_line('Ship_to_location'||X_ship_to_location_id);

         else
	   X_progress := '030';
           po_message_s.sql_error('no header id', X_progress, sqlcode);

	 end if;


   EXCEPTION
         when others then
         po_message_s.sql_error('get_po_details', x_progress, sqlcode);
         raise;

END get_po_details;

/*===========================================================================

  PROCEDURE NAME:	get_segment1_details()

===========================================================================*/
/*
PROCEDURE get_segment1_details() IS

x_progress VARCHAR2(3) := NULL;

BEGIN


   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_segment1_details', x_progress, sqlcode);
   RAISE;

END get_segment1_details;  */


procedure test_start_date ( X_po_header_id IN number, X_start_date IN date) is
       valid_date boolean ;
   begin
         valid_date :=  po_headers_sv2.val_start_date(X_po_header_id, X_start_date);
         /*
         if valid_date  then
                --dbms_output.put_line('VALID');
         else
               --dbms_output.put_line('INVALID');
         end if;
         */
   end test_start_date;

procedure test_get_po_encumbered (X_po_header_id IN number) is
    X_encumb  boolean;

begin
      X_encumb := po_headers_sv1.get_po_encumbered(X_po_header_id);
      /*
      if X_encumb then
         --dbms_output.put_line('ENCUMBERED');
      else
               dbms_output.put_line('NOT ENCUMBERED');
      end if;
      */

end test_get_po_encumbered;
/*===========================================================================

  PROCEDURE NAME:	get_document_status()

===========================================================================*/



  procedure get_document_status(X_lookup_code IN varchar2,
				X_document_type IN varchar2,
				X_document_status IN OUT NOCOPY varchar2) is

  X_progress varchar2(3) := '';

 begin
    IF X_document_type NOT IN ('RFQ', 'QUOTATION') THEN
           X_progress :=  '010';

           select polc.displayed_field
           into   X_document_status
           from   po_lookup_codes polc
           where  polc.lookup_type = 'AUTHORIZATION STATUS'
           and    polc.lookup_code = X_lookup_code ;

    ELSE

	  X_progress :='020';

	  select polc.displayed_field
	  into   X_document_status
	  from   po_lookup_codes polc
	  where  lookup_type = 'RFQ/QUOTE STATUS'
	  and    lookup_code = X_lookup_code;

    END IF;

 exception
           when others then
               po_message_s.sql_error('get_document_status', X_progress, sqlcode);
               raise;

 end get_document_status;


-- <GC FPJ START>

/*===========================================================================

  PROCEDURE NAME:	val_contract_eff_date              <GC FPJ>

===========================================================================*/

PROCEDURE val_contract_eff_date
( p_po_header_id     IN         NUMBER,
  p_start_date       IN         DATE,
  p_end_date         IN         DATE,
  x_result           OUT NOCOPY VARCHAR2
) IS

l_invalid VARCHAR2(1);

BEGIN

    IF (p_po_header_id IS NULL
        OR
         (p_start_date IS NULL AND p_end_date IS NULL)
       ) THEN

        -- if contract is not created or no eff date is specified, there
        -- is no need to check

        x_result := FND_API.G_TRUE;
    ELSE

        -- SQL What: Return lines that reference the contract, but creation
        --           date of their headers are not within effective dates
        --           of the contract
        -- SQL Why:  Need to determine if there is any line violating
        --           the effective date rule of the contract

        SELECT 'F'
        INTO   l_invalid
        FROM   po_headers_all POH,
               po_lines_all   POL
	WHERE  (POL.contract_id = p_po_header_id
	-- Bug # 13037340 Added below condition to apply check for GBPAs as well.
	OR     POL.from_header_id = p_po_header_id)
	AND    POL.po_header_id = POH.po_header_id
	-- Bug # 13037340 Changed comparision based on approval date
	/*AND    TRUNC(POL.creation_date) NOT BETWEEN
		    NVL(TRUNC(p_start_date), POL.creation_date - 1)
	       AND  NVL(TRUNC(p_end_date), POL.creation_date + 1) */
	AND    POH.approved_date IS NOT NULL
	AND    TRUNC(POH.approved_date) > TRUNC(p_end_date+ nvl(FND_PROFILE.VALUE('PO_REL_CREATE_TOLERANCE'),0))
	AND    NVL(POH.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	AND    NVL(POH.cancel_flag, 'N') <> 'Y';


        -- return a row violating the effective dates
        x_result := FND_API.G_FALSE;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_result := FND_API.G_TRUE;     -- all line created within eff date
    WHEN TOO_MANY_ROWS THEN
        x_result := FND_API.G_FALSE;    -- mult line created outside eff dates
    WHEN OTHERS THEN
        x_result := FND_API.G_FALSE;
        RAISE;
END val_contract_eff_date;

-- <GC FPJ END>

END PO_HEADERS_SV2;

/
