--------------------------------------------------------
--  DDL for Package Body PO_LINES_SV4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_SV4" as
/* $Header: POXPOL4B.pls 120.0.12010000.2 2011/05/03 23:26:54 ajunnikr ship $ */

/*=============================  PO_LINES_SV4  ==============================*/


--Global Variables

 	     g_org_id NUMBER; -- <bug 8247574 used for caching org_id>
 	     g_inv_org_id NUMBER; -- <bug 8247574 used for caching inv_org_id>

/*=============================================================================

    FUNCTION:       get_line_num                        <GA FPI>

    DESCRIPTION:    Returns the line number (line_num) based on the po_line_id.

=============================================================================*/

FUNCTION get_line_num
(
    p_po_line_id          IN     PO_LINES_ALL.po_line_id%TYPE
)
RETURN PO_LINES_ALL.line_num%TYPE
IS
    x_line_num          PO_LINES_ALL.line_num%TYPE;
BEGIN

    SELECT    line_num
    INTO      x_line_num
    FROM      po_lines_all
    WHERE     po_line_id = p_po_line_id;

    return (x_line_num);

EXCEPTION
    WHEN OTHERS THEN
        po_message_s.sql_error('get_line_num', '000', sqlcode);
        raise;

END get_line_num;


/*=============================================================================

    FUNCTION:     is_cumulative_pricing               <GA FPI>

    DESCRIPTION:  Returns TRUE if the price_break_lookup_code for the input
                  po_line_id is of type 'CUMULATIVE'. FALSE, otherwise.

=============================================================================*/
FUNCTION is_cumulative_pricing
(
    p_po_line_id            IN     PO_LINES_ALL.po_line_id%TYPE
)
RETURN BOOLEAN
IS
    l_price_break_lookup_code     PO_LINES_ALL.price_break_lookup_code%TYPE;
BEGIN

    SELECT  price_break_lookup_code
    INTO    l_price_break_lookup_code
    FROM    po_lines_all
    WHERE   po_line_id = p_po_line_id;

    IF ( l_price_break_lookup_code = 'CUMULATIVE' ) THEN
        return(TRUE);
    ELSE
        return(FALSE);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        po_message_s.sql_error('is_cumulative_pricing', '000', sqlcode);
        raise;

END is_cumulative_pricing;


--=============================================================================
-- Function    : effective_dates_exist                 -- <GA FPI>
-- Type        : Private
--
-- Pre-reqs    : -
-- Modifies    : -
-- Description : Determines if any Price Breaks with Effectivity Dates exist
--               for the given po_line_id. Automatically returns FALSE if the
--               po_line_id is NULL or does not refer to a Blanket line.
--
-- Parameters  : p_po_line_id - Line ID for the Blanket line.
--
-- Returns     : TRUE if Price Breaks with Effectivity Dates exist.
--               FALSE otherwise.
-- Exceptions  : -
--=============================================================================
FUNCTION effective_dates_exist
(
    p_po_line_id            IN      PO_LINES_ALL.po_line_id%TYPE
)
RETURN BOOLEAN
IS
    l_count                 NUMBER;
BEGIN

    SELECT    count('Price Breaks with Effectivity Dates')
    INTO      l_count
    FROM      po_line_locations_all
    WHERE     po_line_id = p_po_line_id
    AND       (   ( start_date IS NOT NULL )
              OR  ( end_date IS NOT NULL ) );

    IF ( l_count > 0 ) THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        return (FALSE);

END effective_dates_exist;


--=============================================================================
-- Function    : allow_price_override                  <2716528>
-- Type        : Private
--
-- Pre-reqs    : p_po_line_id must refer to an existing line.
-- Modifies    : -
-- Description : Determines if the 'Allow Price Override Flag' is set.
--
-- Parameters  : p_po_line_id - Line ID
--
-- Returns     : TRUE if ALLOW_PRICE_OVERRIDE_FLAG is set to 'Y'.
--               FALSE otherwise.
-- Exceptions  : -
--=============================================================================
FUNCTION allow_price_override
(
    p_po_line_id          PO_LINES_ALL.po_line_id%TYPE
)
RETURN BOOLEAN
IS
    l_allow_price_override_flag    PO_LINES_ALL.allow_price_override_flag%TYPE;
BEGIN

    SELECT    allow_price_override_flag
    INTO      l_allow_price_override_flag
    FROM      po_lines_all
    WHERE     po_line_id = p_po_line_id;

    IF ( l_allow_price_override_flag = 'Y' )
    THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        return (TRUE);

END allow_price_override;



 /*===========================================================================
 **  PROCEDURE : get_ship_dist_num()
 **===========================================================================*/


 procedure get_ship_dist_num(X_po_line_id          IN NUMBER,
                             X_num_of_ship         IN OUT NOCOPY NUMBER,
                             --< NBD TZ/Timestamp FPJ Start >
                             --X_promised_date       IN OUT NOCOPY VARCHAR2,
                             --X_need_by             IN OUT NOCOPY VARCHAR2,
                             X_promised_date       IN OUT NOCOPY DATE,
                             X_need_by             IN OUT NOCOPY DATE,
                             --< NBD TZ/Timestamp FPJ End >
                             X_num_of_dist         IN OUT NOCOPY NUMBER,
                             X_code_combination_id IN OUT NOCOPY NUMBER)    is


      X_Progress   varchar2(3);
      X_line_location_id  number;


 begin

      X_Progress := '010';

      begin

      select line_location_id ,
             --< NBD TZ/Timestamp FPJ Start >
             --fnd_date.date_to_chardate(promised_date),
             --fnd_date.date_to_chardate(need_by_date),
             promised_date,
             need_by_date
             --< NBD TZ/Timestamp FPJ End >
      into   X_line_location_id,
             X_promised_date,
             X_need_by
      from   po_line_locations
      where  po_line_id = X_po_line_id;


      exception
               when no_data_found then
                    X_num_of_ship := 0 ; /* Set the value to 0 */
               when too_many_rows then
                    X_num_of_ship := 2; /* Set it to a value > 1 */
               when others then
                    po_message_s.sql_error('get_ship_dist_num', x_progress, sqlcode);
                    raise;
      end;

     /* If the control ever went into the above anonymous block's exception,
     ** if there were no shipments OR there were more than ONE shipment,
     ** return back without getting the code combination id. We would
     ** assume that if there is > 1 shipment, there will be multiple distributions */

     if X_num_of_ship = 0 then

        X_num_of_dist := 0;

        return;

     elsif X_num_of_ship = 2 then

        X_num_of_dist := 2;

        return;

     else

        X_num_of_ship := 1;

        X_Progress := '020';

        if X_line_location_id is not null then

           select code_combination_id
           into   X_code_combination_id
           from   po_distributions
           where  line_location_id = X_line_location_id;

           X_num_of_dist := 1;

        else

           X_num_of_dist := NULL;

        end if;

     end if;


  exception

     when no_data_found then
          X_num_of_dist := 0;
     when too_many_rows then
          X_num_of_dist := 2;
     when others then
            po_message_s.sql_error('get_ship_dist_num', x_progress, sqlcode);
            raise;
 end get_ship_dist_num;



/*===========================================================================

  FUNCTION NAME:	get_encumbered_quantity

===========================================================================*/
  FUNCTION get_encumbered_quantity
		      (X_po_line_id           IN     NUMBER) RETURN NUMBER IS


      X_progress             VARCHAR2(3) := '';
      X_encumbered_quantity  NUMBER      := 0;

      BEGIN

	 X_progress := '010';

   --<Encumbrance FPJ>
   SELECT sum(POD.quantity_ordered)
   INTO X_encumbered_quantity
   FROM PO_DISTRIBUTIONS_ALL POD
   WHERE POD.po_line_id = X_po_line_id
   AND   POD.encumbered_flag = 'Y'
   AND   POD.distribution_type in ('STANDARD', 'PLANNED')
   ;

      RETURN(X_encumbered_quantity);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN (0);
	WHEN OTHERS THEN
--	  dbms_output.put_line('In exception');
	  po_message_s.sql_error('get_encumbered_quantity', X_progress, sqlcode);
          RAISE;

 END get_encumbered_quantity;



/*===========================================================================

  FUNCTION NAME:	get_receipt_required_flag

===========================================================================*/
  FUNCTION get_receipt_required_flag (X_line_type_id           IN     NUMBER,
                                      X_item_id                IN     NUMBER,
				      X_inventory_org_id       IN     NUMBER)
		   		      RETURN VARCHAR2          	      IS

      X_progress            	 VARCHAR2(3) := '';
      X_receipt_required_flag    VARCHAR2(1) := '';

      BEGIN



        IF X_item_id is  not null then
            X_progress := '010';
            SELECT nvl(msi.receipt_required_flag, X_receipt_required_flag)
            INTO   X_receipt_required_flag
            FROM   mtl_system_items msi
            WHERE  msi.inventory_item_id = X_item_id
            AND    msi.organization_id   = X_inventory_org_id;
        ELSE
            X_progress := '020';
            SELECT receiving_flag
            INTO   X_receipt_required_flag
            FROM   po_line_types
            WHERE  line_type_id = X_line_type_id;
        END IF;


      RETURN(X_receipt_required_flag);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN (NULL);
	WHEN OTHERS THEN
--	  dbms_output.put_line('In exception');
	  po_message_s.sql_error('get_receipt_required_flag', X_progress, sqlcode);
          RAISE;

 END get_receipt_required_flag;


/*===========================================================================

  PROCEDURE NAME: get_ship_quantity_info ()

============================================================================*/


 PROCEDURE  get_ship_quantity_info (X_po_line_id          	IN NUMBER,
                                    X_expense_accrual_code      IN VARCHAR2,
                                    X_po_header_id              IN NUMBER,
                                    X_type_lookup_code          IN VARCHAR2,
                            	    X_quantity_received   	IN OUT NOCOPY NUMBER,
                              	    X_quantity_billed     	IN OUT NOCOPY NUMBER,
                                    X_encumbered_flag     	IN OUT NOCOPY VARCHAR2,
                                    X_prevent_price_update_flag IN OUT NOCOPY VARCHAR2,
                                    X_online_req_flag 		IN OUT NOCOPY VARCHAR2,
                                    X_quantity_released         IN OUT NOCOPY NUMBER,
                                    X_amount_released           IN OUT NOCOPY NUMBER)  IS

      X_progress   varchar2(3);
      X_row_exists number := 0;

      l_is_global_agreement       BOOLEAN;                    -- <GA FPI>
      l_value_basis               PO_LINES_ALL.order_type_lookup_code%TYPE;
      X_amount_received  NUMBER;
      X_amount_billed  NUMBER;

      -- <FPJ Retroactive Price START>
      l_retroactive_update    VARCHAR2(30) := 'NEVER';
      l_archive_mode_std_po  PO_DOCUMENT_TYPES.archive_external_revision_code%TYPE;
      l_encumbrance_on      VARCHAR2(1) ;
      l_current_org_id       NUMBER;
      -- Bug 3231062
      l_retro_prj_allowed   VARCHAR2(1);
      -- <FPJ Retroactive Price END>

 BEGIN
        X_progress := '010';
	--<Encumbrance FPJ>
	PO_CORE_S.should_display_reserved(
		p_doc_type => PO_CORE_S.g_doc_type_PO
	,	p_doc_level => PO_CORE_S.g_doc_level_LINE
	,	p_doc_level_id => x_po_line_id
	,	x_display_reserved_flag => x_encumbered_flag
	);


      /* Find out if the shipments are encumbered and also the qty billed /recd */

      BEGIN
           X_progress := '020';
           SELECT sum(nvl(quantity_received,0)),
                  sum(nvl(quantity_billed,0)),
                  sum(nvl(amount_received,0)),
                  sum(nvl(amount_billed,0))
           INTO   X_quantity_received,
                  X_quantity_billed,
                  X_amount_received,
                  X_amount_billed
           FROM   po_line_locations
           WHERE  po_line_id = X_po_line_id
           AND    shipment_type in ('STANDARD', 'PLANNED');

           X_Progress := '030';
           l_is_global_agreement := PO_GA_PVT.is_global_agreement(X_po_header_id);

           X_Progress := '040';
           if X_type_lookup_code in ('BLANKET', 'PLANNED') then
              /* Get the corresponding release information .
                 The price_override column WILL always be a
                 NOT NULL value ( although it is not defined
                 as such in the table, The Enter Releases
                 form should ensure that the value is not null.*/

            if  ( X_type_lookup_code = 'BLANKET' ) AND
                ( NOT l_is_global_agreement ) then               -- <GA FPI>

               X_Progress := '050';
               -- <SERVICES FPJ START>
               -- Added a decode in the SELECT statement to use Amount
               -- instead of quantity for Fixed Price Services lines
               -- <SERVICES FPJ END>
               SELECT sum(nvl(quantity,0) - nvl(quantity_cancelled,0)),
                      sum(decode(quantity,
                                 null,
                                 (nvl(amount, 0)
                                 - nvl(amount_cancelled, 0)),
                                 (price_override* (nvl(quantity,0) -
                                 nvl(quantity_cancelled,0)))
                                )
                         )
               INTO   X_quantity_released,
                      X_amount_released
               FROM   po_line_locations
               WHERE  po_header_id  = X_po_header_id and
                      shipment_type = 'BLANKET'and
                      po_line_id    = X_po_line_id;

            -- <GA FPI START>
            --
            ELSIF ( l_is_global_agreement ) THEN

                X_Progress := '060';
                PO_CORE_S.get_ga_line_amount_released( X_po_line_id,         -- IN
                                                       X_po_header_id,       -- OUT
                                                       X_quantity_released,  -- OUT
                                                       X_amount_released );  -- OUT
            -- <GA FPI END>

            elsif X_type_lookup_code = 'PLANNED' then


               X_Progress := '070';
               SELECT sum(nvl(quantity,0) - nvl(quantity_cancelled,0)),
                      sum(price_override* (nvl(quantity,0) -
				nvl(quantity_cancelled,0)))
               INTO   X_quantity_released,
                      X_amount_released
               FROM   po_line_locations
               WHERE  po_header_id = X_po_header_id and
                      shipment_type = 'SCHEDULED' and
                      po_line_id    = X_po_line_id;
            end if;

          end if;

       EXCEPTION
          /* If no shipments found or any database error,
          ** set fields to default values
          */
          WHEN NO_DATA_FOUND THEN
               X_Progress := '080';
               X_quantity_received := 0;
               X_quantity_billed   := 0;
               X_amount_received := 0;
               X_amount_billed   := 0;
               X_encumbered_flag   := 'N';
               X_quantity_released := 0;
               X_amount_released   := 0;
       END;

          X_Progress := '100';
          Select order_type_lookup_code
          into   l_value_basis
          from   po_lines_all
          where  po_line_id =  X_po_line_id;

          -- <FPJ Retroactive Price START>
          X_Progress := '110';
          l_current_org_id     := PO_GA_PVT.get_current_org;
          X_Progress := '120';
          l_retroactive_update := PO_RETROACTIVE_PRICING_PVT.Get_Retro_Mode;
          -- Bug 3565522 : get the archive mode
          X_Progress := '130';
          l_archive_mode_std_po := PO_DOCUMENT_ARCHIVE_PVT.get_archive_mode(
                                      p_doc_type    => 'PO',
                                      p_doc_subtype => 'STANDARD');
          X_Progress := '140';
          IF PO_CORE_S.is_encumbrance_on( p_doc_type => 'PO',
                                          p_org_id   => l_current_org_id)
          THEN
            l_encumbrance_on  :=  'Y';
          ELSE
            l_encumbrance_on  :=  'N';
          END IF;
          -- Bug 3231062
          X_Progress := '150';
          l_retro_prj_allowed := PO_RETROACTIVE_PRICING_PVT.Is_Retro_Project_Allowed(
                                   p_std_po_price_change => 'Y',
                                   p_po_line_id          => X_po_line_id,
                                   p_po_line_loc_id      => NULL);

          -- <FPJ Retroactive Price END>

        BEGIN

           X_Progress := '160';
           IF l_value_basis in ('QUANTITY','AMOUNT') THEN
             X_progress := '170';

             SELECT COUNT(1)
             INTO   X_row_exists
             FROM   po_distributions
             WHERE  po_line_id = X_po_line_id
             AND    (destination_type_code in ('INVENTORY','SHOP FLOOR')
                    OR (destination_type_code = 'EXPENSE'
                        AND (X_expense_accrual_code = 'RECEIPT'
                                OR X_quantity_billed > 0)))
             AND    (X_quantity_received > 0 OR
                     X_quantity_billed > 0)
             -- <FPJ Retroactive Price START>
             AND    (l_retroactive_update <> 'ALL_RELEASES' OR
                     (l_retroactive_update = 'ALL_RELEASES' AND
                      l_encumbrance_on = 'Y') OR               -- Bug 3573266
                     (l_retroactive_update = 'ALL_RELEASES' AND
                      l_archive_mode_std_po <> 'APPROVE' ) OR -- Bug 3565522
                     (l_retroactive_update = 'ALL_RELEASES' AND
                      l_retro_prj_allowed = 'N' ));  -- Bug 3231062
             -- <FPJ Retroactive Price END>
           ELSE
	     X_progress := '180';
             -- Bug 3524527 : check for amounts on service lines
             SELECT COUNT(1)
             INTO   X_row_exists
             FROM   po_distributions
             WHERE  po_line_id = X_po_line_id
             AND    (destination_type_code = 'EXPENSE'
                        AND (X_expense_accrual_code = 'RECEIPT'
                                OR X_amount_billed > 0))
             AND    (X_amount_received > 0 OR
                     X_amount_billed > 0);

           END IF;  -- end of qty and amount based lines

           IF X_row_exists > 0 THEN
              X_prevent_price_update_flag := 'Y';
           ELSE
              X_prevent_price_update_flag  := 'N';
           END IF;

           EXCEPTION
       	       WHEN NO_DATA_FOUND THEN
       		    X_prevent_price_update_flag  := 'N';

       END;


       /* Find out if this  is based on an ONLINE REQ */

       BEGIN
            X_progress := '200';
            X_row_exists := 0;

 	    SELECT COUNT(1)
 	    INTO   X_row_exists
 	    FROM   po_distributions pod
 	    WHERE  pod.po_Line_id = X_po_line_id
 	    AND    req_distribution_id is not null;

            IF X_row_exists > 0 THEN
               X_online_req_flag := 'Y';
            ELSE
               X_online_req_flag := 'N';
            END IF;

 	EXCEPTION
 	    /* If no distributions found, set it to 'N'
 	    */
 	    WHEN NO_DATA_FOUND THEN
 		 X_online_req_flag := 'N';
       END;



   EXCEPTION

	WHEN OTHERS THEN
--	  dbms_output.put_line('In exception');
	  po_message_s.sql_error('PO_LINES_SV4','get_ship_quantity_info',
	                         x_progress, sqlcode, sqlerrm);
          RAISE;


 END get_ship_quantity_info;


/*===========================================================================

  PROCEDURE NAME: get_quotation_info ()

============================================================================*/


 PROCEDURE  get_quotation_info   (X_from_header_id      	IN NUMBER,
				  X_from_line_id        	IN NUMBER,
                            	  X_quotation_number    	IN OUT NOCOPY VARCHAR2,
             			  X_quotation_line		IN OUT NOCOPY NUMBER,
				  X_quotation_type	     	IN OUT NOCOPY VARCHAR2,
                              	  X_vendor_quotation_number    	IN OUT NOCOPY VARCHAR2,
                                  x_quote_terms_id              IN OUT NOCOPY NUMBER,
                                  x_quote_ship_via_lookup_code  IN OUT NOCOPY VARCHAR2,
                                  x_quote_fob_lookup_code       IN OUT NOCOPY VARCHAR2,
                                  x_quote_freight_terms         IN OUT NOCOPY VARCHAR2) IS

      X_progress               varchar2(3);
      X_from_type_lookup_code  varchar2(25);
      X_quote_type_lookup_code varchar2(25);

 BEGIN

      BEGIN

        X_progress := '010';
        SELECT segment1,
               type_lookup_code,
               quote_type_lookup_code,
               quote_vendor_quote_number,
               terms_id,
               ship_via_lookup_code,
               fob_lookup_code,
               freight_terms_lookup_code
        INTO   X_quotation_number,
               X_from_type_lookup_code,
               X_quote_type_lookup_code,
               X_vendor_quotation_number,
               x_quote_terms_id,
               x_quote_ship_via_lookup_code,
               x_quote_fob_lookup_code,
               x_quote_freight_terms
        FROM   po_headers
        WHERE  po_header_id = X_from_header_id
        AND    type_lookup_code = 'QUOTATION';

        X_progress := '020';

        SELECT podt.type_name
        INTO   X_quotation_type
        FROM   po_document_types podt
        WHERE  podt.document_type_code = X_from_type_lookup_code
        AND    podt.document_subtype   = X_quote_type_lookup_code;



       EXCEPTION
 	    /* If no record found,set return fields to null */

 	    WHEN NO_DATA_FOUND THEN
 		 X_quotation_number := '';
                 X_quotation_type := '';
                 X_vendor_quotation_number :='';
                 X_quotation_line := '';
                 x_quote_terms_id := '';
                 x_quote_ship_via_lookup_code := '';
                 x_quote_fob_lookup_code := '';
                 x_quote_freight_terms := '';

      END;


      IF X_from_type_lookup_code = 'QUOTATION' THEN

         BEGIN

           X_progress := '020';

           SELECT line_num
           INTO   X_quotation_line
           FROM   po_lines
           WHERE  po_line_id = X_from_line_id;

         EXCEPTION

           WHEN NO_DATA_FOUND THEN
                X_quotation_line := '';

         END;
      END IF;


   EXCEPTION

	WHEN OTHERS THEN
--	  dbms_output.put_line('In exception');
	  po_message_s.sql_error('get_quotation_info', X_progress, sqlcode);
          RAISE;


 END get_quotation_info;

/*===========================================================================

  PROCEDURE NAME:	get_lookup_code_dsp()

===========================================================================*/


 procedure get_lookup_code_dsp	 (X_lookup_type        	        IN VARCHAR2,
				  X_lookup_code 	        IN VARCHAR2,
                            	  X_displayed_field             IN OUT NOCOPY VARCHAR2) is

  X_progress varchar2(3) := '';

 begin
           X_progress := '010';

           select polc.displayed_field
           into   X_displayed_field
           from   po_lookup_codes polc
           where  polc.lookup_type = X_lookup_type
           and    polc.lookup_code = X_lookup_code ;

 exception
           when others then
               po_message_s.sql_error('get_lookup_code_dsp', X_progress, sqlcode);
               raise;

 end get_lookup_code_dsp;


/*===========================================================================

  PROCEDURE NAME:	online_req

===========================================================================*/

FUNCTION online_req(x_po_line_id    IN  NUMBER) return BOOLEAN
IS
	x_progress  		VARCHAR2(3) := NULL;
	x_row_exists 		NUMBER := 0;
	x_online_req_flag	BOOLEAN := FALSE;
BEGIN

    x_progress := '010';

    SELECT COUNT(1)
    INTO   x_row_exists
    FROM   po_distributions pod
    WHERE  pod.po_line_id = X_po_line_id
    AND    req_distribution_id is not null;

   IF x_row_exists > 0 THEN
       x_online_req_flag := TRUE;
   END IF;

   return x_online_req_flag;

EXCEPTION
   /* If no distributions found, return FALSE */
   WHEN NO_DATA_FOUND THEN
       X_online_req_flag := FALSE;
       return x_online_req_flag;
   WHEN OTHERS THEN
       raise;
END online_req;

/*===========================================================================

  PROCEDURE NAME:	get_item_id()

===========================================================================*/

 /* PROCEDURE get_item_id
                (X_item_id_record		IN OUT	rcv_shipment_line_sv.item_id_record_type) is

 BEGIN

   if (X_item_id_record.item_num is not null) then

      select min(inventory_item_id),
	     min(primary_unit_of_measure)
      into   x_item_id_record.item_id,
	     x_item_id_record.primary_unit_of_measure
      from   mtl_item_flexfields
      where  item_number	= X_item_id_record.item_num and
	     organization_id	= X_item_id_record.to_organization_id;

      if (x_item_id_record.item_id is null) then

          select min(inventory_item_id),
		 min(primary_unit_of_measure)
          into   x_item_id_record.item_id,
		 x_item_id_record.primary_unit_of_measure
          from   mtl_item_flexfields
          where  item_number		= X_item_id_record.vendor_item_num and
		 organization_id	= X_item_id_record.to_organization_id;

      end if;

   end if;

   if (x_item_id_record.item_id is null) then
	x_item_id_record.error_record.error_status	:= 'W';
	x_item_id_record.error_record.error_message	:= 'RCV_ITEM_ID';
   end if;

 exception
   when others then
	x_item_id_record.error_record.error_status	:= 'U';

 END get_item_id; */


/*===========================================================================

  PROCEDURE NAME:	get_sub_item_id()

===========================================================================*/

 /* PROCEDURE get_sub_item_id
                (X_sub_item_id_record		IN OUT	rcv_shipment_line_sv.sub_item_id_record_type) is

 BEGIN

   if (X_sub_item_id_record.substitute_item_num is not null) then
      select max(inventory_item_id)
      into   x_sub_item_id_record.substitute_item_id
      from   mtl_system_items_kfv
      where  concatenated_segments = X_sub_item_id_record.substitute_item_num;
   else
      select max(inventory_item_id)
      into   x_sub_item_id_record.substitute_item_id
      from   mtl_system_items_kfv
      where  concatenated_segments = X_sub_item_id_record.vendor_item_num;
   end if;

   if (x_sub_item_id_record.substitute_item_id is null) then
	x_sub_item_id_record.error_record.error_status	:= 'F';
	x_sub_item_id_record.error_record.error_message	:= 'RCV_ITEM_SUB_ID';
   end if;

 exception
   when others then
	x_sub_item_id_record.error_record.error_status	:= 'U';

 END get_sub_item_id;  */

/*===========================================================================

  PROCEDURE NAME:	get_po_line_id()

===========================================================================*/

 /* PROCEDURE get_po_line_id
                (X_po_line_id_record		IN OUT	rcv_shipment_line_sv.po_line_id_record_type) is

 BEGIN

   select po_line_id, item_id
   into   x_po_line_id_record.po_line_id, X_po_line_id_record.item_id
   from   po_lines
   where  po_header_id = X_po_line_id_record.po_header_id and
          line_num     = X_po_line_id_record.document_line_num;

   if (x_po_line_id_record.po_line_id is null) then
	x_po_line_id_record.error_record.error_status	:= 'F';
	x_po_line_id_record.error_record.error_message := 'RCV_ITEM_PO_LINE_ID';
   end if;

 exception
   when others then
	x_po_line_id_record.error_record.error_status	:= 'U';

 END get_po_line_id; */

 --togeorge 10/03/2000
 procedure get_oke_contract_header_info(
		X_oke_contract_header_id	IN 		NUMBER,
	     	X_oke_contract_num		IN OUT	NOCOPY 	VARCHAR2
		) is
      X_Progress   varchar2(3);

 begin

      X_Progress := '010';

      begin

      select contract_number
      into   X_oke_contract_num
      from   okc_k_headers_b
      where  id = X_oke_contract_header_id;


      exception
               when no_data_found then
                    X_oke_contract_num := to_char(null) ; /* Set the value to null */
               when others then
                    po_message_s.sql_error('get_oke_contract_header_info', x_progress, sqlcode);
                    raise;
      end;

  exception
     when others then
                    po_message_s.sql_error('get_oke_contract_header_info', x_progress, sqlcode);
            raise;
 end get_oke_contract_header_info;

 --Bug# 1625462
 --togeorge 01/30/2001
 --Now displaying translated values for uom.
 procedure get_unit_meas_lookup_code_tl(
		X_unit_meas_lookup_code		IN 		VARCHAR2,
	     	X_unit_meas_lookup_code_tl	IN OUT	NOCOPY 	VARCHAR2
		) is
      X_Progress   varchar2(3);

 begin
      X_Progress := '010';
       select mum.unit_of_measure_tl
	 into x_unit_meas_lookup_code_tl
   	 from mtl_units_of_measure mum
	where mum.unit_of_measure = x_unit_meas_lookup_code;

  exception
     when others then
          /*
		  ** Bug 1689746
		  ** In the Receiving transactions form you can't query up
		  ** RMA receipts. Commenting out the error and raise so that
		  ** transaction may proceed.
		  po_message_s.sql_error('get_unit_meas_lookup_code_tl', x_progress, sqlcode);
          raise;
		  */
		  null;

 end get_unit_meas_lookup_code_tl;

 --Bug# 1751180
 --togeorge 04/27/2001
 --This procedure would select the translated uom using uom_code since om stores uom_code unlike units_of_measure as po.
 procedure get_om_uom_tl(
		X_uom_code		        IN 		VARCHAR2,
	     	X_unit_meas_lookup_code_tl	IN OUT	NOCOPY 	VARCHAR2
		) is
      X_Progress   varchar2(3);

 begin
      X_Progress := '010';
       select mum.unit_of_measure_tl
	 into x_unit_meas_lookup_code_tl
   	 from mtl_units_of_measure mum
	where mum.uom_code = rtrim(x_uom_code);

  exception
     when others then
		  null;

 end get_om_uom_tl;

 /*
 	 Bug 8247574: Introduced the below function to fetch inventory_org_id.
 	  This function will be called in the query of the view po_lines_v.
 	  This is done for performance gains.
 	 */

 	 /**
 	  * Function: get_inventory_orgid
 	  * Requires:
 	  *   IN PARAMETERS:
 	  *    p_org_id: Operating unit id
 	  *
 	  * Modifies: None.
 	  * Effects:  This procedure gets the inventory organization id
 	  *           from financial system parameters
 	  *
 	  * Returns:
 	  *    Inventory Organization id
 	  */

 	 FUNCTION get_inventory_orgid
 	 (
 	     p_org_id          number
 	 )
 	 RETURN number
 	 IS

 	 l_inv_org_id NUMBER;

 	 BEGIN

 	  IF g_org_id IS NULL OR (g_org_id <> p_org_id) THEN

 	     BEGIN
 	       SELECT FSP.inventory_organization_id
 	         INTO l_inv_org_id
 	         FROM financials_system_params_all FSP
 	        WHERE org_id = p_org_id;
 	     EXCEPTION
 	       WHEN OTHERS THEN
 	         l_inv_org_id := NULL;
 	     END;

 	     g_org_id := p_org_id;
 	     g_inv_org_id :=  l_inv_org_id;
 	  ELSE
 	    l_inv_org_id := g_inv_org_id;
 	  END IF;
 	     RETURN l_inv_org_id;
 	 END;

END PO_LINES_SV4;

/
