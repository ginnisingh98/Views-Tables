--------------------------------------------------------
--  DDL for Package Body PO_SHIPMENTS_SV8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHIPMENTS_SV8" as
/* $Header: POXPOS8B.pls 120.1.12010000.12 2014/01/20 08:52:36 mazhong ship $*/

/*===========================================================================

  FUNCTION NAME:	val_start_dates()

===========================================================================*/

FUNCTION val_start_dates(X_start_date	  IN	DATE,
			 X_po_header_id   IN	NUMBER) RETURN BOOLEAN IS

/*  This procedure is used by RFQs and Quotations to verify the
**  START_DATE which has been entered on the header level is not
**  later than the earliest START_DATE of it's shipments.
*/

x_progress		VARCHAR2(3) := '';
x_start_date_count	NUMBER;

BEGIN
  x_progress := '010';
  /*
  ** Verify that the start date entered on the header is earlier than
  ** the start dates of it's shipments.
  */

  SELECT count(*)
  INTO   x_start_date_count
  FROM   po_line_locations
  WHERE  start_date < X_start_date
  AND    po_header_id = X_po_header_id;

  x_progress := '020';

  if x_start_date_count > 0 then
    RETURN(FALSE);
    -- dbms_output.put_line('FALSE: start date invalid');
  else
    RETURN(TRUE);
    -- dbms_output.put_line('TRUE: start date valid');
  end if;

EXCEPTION
    when no_data_found then
         return(TRUE);
    WHEN OTHERS THEN
         po_message_s.sql_error('val_start_dates', x_progress, sqlcode);
         raise;
END val_start_dates;
/*===========================================================================

  FUNCTION NAME:	val_end_dates()

===========================================================================*/

FUNCTION val_end_dates(X_end_date	IN	DATE,
		       X_po_header_id	IN	NUMBER) RETURN BOOLEAN IS

--  This procedure is used by RFQs and Quotations to verify the
--  END_DATE which has been entered on the header level is not
--  earlier than than the latest END_DATE of it's shipments.


x_progress 		VARCHAR2(3) 	:= '';
x_end_date_count	NUMBER;

BEGIN
  x_progress := '010';

  --
  -- Verify that the end date entered on the header is later than
  -- the end dates of it's shipments.


  SELECT count(*)
  INTO   x_end_date_count
  FROM   po_line_locations
  WHERE  end_date > X_end_date
  AND    po_header_id = X_po_header_id;

  x_progress := '020';

  if x_end_date_count > 0 then
    RETURN(FALSE);
    -- dbms_output.put_line('FALSE: start date invalid');
  else
    RETURN(TRUE);
    -- dbms_output.put_line('TRUE: start date valid');
  end if;

EXCEPTION
    when no_data_found then
         return(TRUE);
  WHEN OTHERS THEN
    po_message_s.sql_error('val_end_dates', x_progress, sqlcode);
    raise;

END val_end_dates;

 /*==============================================================================
 ** PROCEDURE : autocreate_ship()
 Modified        26-FEB-01       MCHANDAK(OPM-GML)
                 Bug# 1548597.. Added 3 process related fields.
                 X_secondary_unit_of_measure,X_secondary_quantity and
                 X_preferred_grade.

 **=============================================================================*/

 procedure autocreate_ship ( X_line_location_id        IN OUT NOCOPY NUMBER,
                             X_last_update_date               DATE,
                             X_last_updated_by                NUMBER,
                             X_creation_date                  DATE,
                             X_created_by                     NUMBER,
                             X_last_update_login              NUMBER,
                             X_po_header_id                   NUMBER,
                             X_po_line_id                     NUMBER,
                             X_type_lookup_code               VARCHAR2,
                             X_quantity                       NUMBER,
                             X_ship_to_location_id            NUMBER,
                             X_ship_org_id                    NUMBER,
                             X_need_by_date                   DATE,
                             X_promised_date                  DATE,
                             X_unit_price                     NUMBER,
                             X_tax_code_id		      NUMBER,
                             X_taxable_flag                   VARCHAR2,
                             X_enforce_ship_to_location       VARCHAR2,
                             X_receiving_routing_id           NUMBER,
                             X_inspection_required_flag       VARCHAR2,
                             X_receipt_required_flag          VARCHAR2,
                             X_qty_rcv_tolerance              NUMBER,
                             X_qty_rcv_exception_code         VARCHAR2,
                             X_days_early_receipt_allowed     NUMBER,
                             X_days_late_receipt_allowed      NUMBER,
                             X_allow_substitute_receipts      VARCHAR2,
                             X_receipt_days_exception_code    VARCHAR2,
                             X_invoice_close_tolerance        NUMBER,
                             X_receive_close_tolerance        NUMBER,
                             X_item_status                    VARCHAR2,
                             X_outside_operation_flag         VARCHAR2,
                             X_destination_type_code          VARCHAR2,
                             X_expense_accrual_code           VARCHAR2,
                             X_item_id                        NUMBER,
					     X_ussgl_transaction_code		  VARCHAR2,
                             X_accrue_on_receipt_flag  IN OUT NOCOPY VARCHAR2,
                             X_autocreated_ship        IN OUT NOCOPY BOOLEAN,
                             X_unit_meas_lookup_code   IN     VARCHAR2, -- Added Bug 731564
                             p_value_basis             IN     VARCHAR2, -- <Complex Work R12>
                             p_matching_basis          IN     VARCHAR2, -- <Complex Work R12>
-- start of bug# 1548597
                             X_secondary_unit_of_measure IN   VARCHAR2,
                             X_secondary_quantity    IN   NUMBER,
                             X_preferred_grade       IN   VARCHAR2,
                             p_consigned_from_supplier_flag IN VARCHAR2 --bug 3523348
-- end of bug# 1548597
                           ,p_org_id                     IN     NUMBER                  -- <R12.MOAC>
			   ,p_outsourced_assembly	IN NUMBER -- <R12 SHIKYU>
)
  is

  X_Progress                 varchar2(3)  :=  '';
  x_vendor_site_id           number;      -- Bug 880864
  x_vendor_id                number;
  X_invoice_match_option     VARCHAR2(25);
  x_country_of_origin_code   VARCHAR2(2); -- bug 2350043 by jbalakri

  /* CONSIGNED FPI START */

  x_consigned_flag
    po_line_locations.consigned_flag%TYPE               := NULL;

  -- OPEN is the default if the shipment line is not consigned
  x_closed_code
    po_line_locations.closed_code%TYPE                  := 'OPEN';

  x_closed_reason
    po_line_locations.closed_reason%TYPE                := NULL;

  l_invoice_close_tolerance      number                 := X_invoice_close_tolerance;

  l_inspection_required_flag
    po_line_locations.inspection_required_flag%TYPE     := X_inspection_required_flag;

  l_receipt_required_flag
    po_line_locations.receipt_required_flag%TYPE        := X_receipt_required_flag;

  /* CONSIGNED FPI END */

  l_from_line_id number;   -- GA FPI
  l_from_header_id number;  -- GA FPI
  l_amount  number;

  /*Bug 8559443 - Variable initialization start*/
  l_transaction_flow_header_id  PO_LINE_LOCATIONS_ALL.transaction_flow_header_id%TYPE;
  l_is_valid        BOOLEAN;
  l_in_current_sob  BOOLEAN;
  l_check_txn_flow  BOOLEAN;
  l_return_status   VARCHAR2(1);
  p_item_category_id NUMBER;
  /*Bug 8559443 - Variable initialization end*/

  --Bug#18050242
  l_api_name CONSTANT VARCHAR2(50) := 'po.plsql.po_shipments_sv8.autocreate_ship';

  begin

              X_Progress := '010';
              IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN

                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_api_name
                   || X_Progress,'X_outside_operation_flag:'||X_outside_operation_flag);

                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_api_name
                   || X_Progress,'X_item_status:'||X_item_status);

                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_api_name
                   || X_Progress,'X_destination_type_code:'||X_destination_type_code);

                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_api_name
                   || X_Progress,'X_receipt_required_flag:'||X_receipt_required_flag);

                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_api_name
                   || X_Progress,'X_expense_accrual_code:'||X_expense_accrual_code);
	      END IF;

              if X_item_id is NULL then
                 if X_destination_type_code = 'INVENTORY' then
                    /* invalid Defaults */
                    null;
                 else
                    /*copy expense to world and more */
                    null;
                 end if;
              end if;


              /* Algorithm for figuring out the value of accrue_on_receipt */

              if X_outside_operation_flag = 'Y' then

                 X_accrue_on_receipt_flag := 'Y';

              elsif X_item_status = 'E' then

                    if ( X_destination_type_code = '' OR
                         X_destination_type_code = 'INVENTORY') then

                          X_accrue_on_receipt_flag := 'Y';

                    elsif (X_destination_type_code = 'EXPENSE') then

                          if  X_expense_accrual_code = 'RECEIPT' then

                              X_accrue_on_receipt_flag := X_receipt_required_flag;

                          elsif X_expense_accrual_code = 'PERIOD END' then

                                X_accrue_on_receipt_flag := 'N';

                          end if;

                   end if;
              --Bug#18050242
              else
                   if  X_expense_accrual_code = 'PERIOD END' then
                        X_accrue_on_receipt_flag := 'N';
                   else
                        X_accrue_on_receipt_flag := X_receipt_required_flag;
                   end if;
              end if;

	    /** Bug 880864 , bgu, Apr. 28, 1999
             *  Need to autocreate match_option into the shipment
             */
	    X_Progress := '015';

            /* Bug 16655207. Inovice Match option should be defauled to R for LCM enabled shipments.*/
            if ( x_item_id IS NOT NULL ) THEN
              l_return_status := inv_utilities.inv_check_lcm(x_item_id,
                                                x_ship_org_id,
                                                p_consigned_from_supplier_flag,
                                                X_outside_operation_flag,
                                                x_vendor_id,
                                                x_vendor_site_id,
                                                X_line_location_id);
              if(l_return_status = 'Y') then
                x_invoice_match_option := 'R';
              end if;
            end if;
            /* Bug 16655207.End */

            -- Get vendor site id from po header
            if(x_invoice_match_option is NULL) then
              select vendor_site_id, vendor_id
              into   x_vendor_site_id, x_vendor_id
              from   po_headers
              where  po_header_id  =  x_po_header_id;
            end if;
            -- The following code is copied from
            -- PO_SHIPMENTS_C22.invoice_match_option, POXPOPOS.pld
            if (X_vendor_site_id is not null) then
              /* Retrieve Invoice Match Option from Vendor site*/
              SELECT match_option
              INTO   x_invoice_match_option
              FROM   po_vendor_sites
              WHERE  vendor_site_id = X_vendor_site_id;
            end if;

            if(x_invoice_match_option is NULL) then
              /* Retrieve Invoice Match option from Vendor */
              if (X_vendor_id is not null) then
                SELECT match_option
                INTO   x_invoice_match_option
                FROM   po_vendors
                WHERE  vendor_id = X_vendor_id;
              end if;
            end if;

            if(x_invoice_match_option is NULL) then
              /* Retrieve Invoice Match Option from Financial System
               * Parameters */

	    /*  Bug 9484848 start
	    As per new data model chnges in R12, invoice match option field
	    at shipment level should be defaulted from ap_product_setup table.
	    */
     	    /*  SELECT fsp.match_option
     	      INTO   x_invoice_match_option
     	      FROM   financials_system_parameters fsp;
   	    end if;
	    */
	    SELECT aps.match_option
 	    INTO   x_invoice_match_option
     	    FROM   ap_product_setup aps;
	    end if;

	    /* Bug 9484848 end*/

            X_Progress := '020';

            SELECT po_line_locations_s.nextval
            INTO   X_line_location_id
            FROM   sys.dual;
--   Added for bug 2350043 by jbalakri
            X_Progress:= '025';

       po_coo_s.get_default_country_of_origin(x_item_id,
                x_ship_org_id,
                x_vendor_id,
                x_vendor_site_id,
                x_country_of_origin_code);
-- end of 2350043

            X_Progress := '030';

         /*Bug 8559443*/

              SELECT category_id
                INTO p_item_category_id
                FROM po_lines
               WHERE po_line_id = X_po_line_id;

        /*Bug 8559443*/

        --bug 3523348: move logic to POXPIPOL.pld so we can remove source doc
        --             Now we pass p_consigned_from_supplier_flag parameter
        /* CONSIGNED FPI START */
             -- Set the new shipment as consigned if the corresponding
	         -- ASL entry is consigned and item is not expense

       IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     		FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_api_name
          || X_Progress,'p_consigned_from_supplier_flag:'|| p_consigned_from_supplier_flag);
       END IF;

        /* Bug 8559443: Add the procedure validate_ship_to_org to get the transaction_flow_header_id */

       IF(p_consigned_from_supplier_flag = 'Y')
             THEN
               -- set shipment line as consigned
               x_consigned_flag := 'Y';
               X_accrue_on_receipt_flag := 'N';
               l_invoice_close_tolerance := 100;
	           x_closed_code := 'CLOSED FOR INVOICE';
	           FND_MESSAGE.SET_NAME('PO', 'PO_SUP_CONS_CLOSED_REASON');
               x_closed_reason := FND_MESSAGE.GET;
               l_inspection_required_flag := 'N';
               l_receipt_required_flag := 'N';
               X_invoice_match_option := 'P';
        ELSE
                /* Bug 8559443 - start */
                 PO_SHARED_PROC_PVT.validate_ship_to_org
                      (p_init_msg_list        => 'T',
                      x_return_status        => l_return_status,
                      p_ship_to_org_id       => X_ship_org_id,
                      p_item_category_id     => p_item_category_id,
                      p_item_id              => X_item_id,
                      x_is_valid             => l_is_valid,
                      x_in_current_sob       => l_in_current_sob,
                      x_check_txn_flow       => l_check_txn_flow,
                      x_transaction_flow_header_id => l_transaction_flow_header_id);



                  IF (l_return_status <> 'S') THEN
                      -- Null out the txn flow header on error
                      l_transaction_flow_header_id := NULL;
                  ELSIF (NOT l_is_valid) THEN
                      -- Null out the txn flow header on validation failure
                      l_transaction_flow_header_id := NULL;

                  END IF;
                /* Bug 8559443 - end */
	    END IF;
	     /* CONSIGNED FPI END */

         /* GA FPI start : we need to insert the source doc info from the lines to shipments */
         /* SERVICES FPJ : We also need to insert the line amount to the shipments */
         begin
            select from_line_id,from_header_id,amount
            into l_from_line_id, l_from_header_id,l_amount
            from po_lines
            where po_line_id = X_po_line_id ;
         exception
           when others then
            l_from_line_id := null;
            l_from_header_id := null;
         end;
	 /* GA FPI end */

            INSERT into po_line_locations
                       (line_location_id        ,
                        last_update_date        ,
                        last_updated_by         ,
                        creation_date           ,
                        created_by              ,
                        last_update_login       ,
                        po_header_id            ,
                        po_line_id              ,
                        shipment_num            ,
                        shipment_type           ,
                        quantity                ,
                        quantity_received       ,
                        quantity_accepted       ,
                        quantity_rejected       ,
                        quantity_billed         ,
                        quantity_cancelled      ,
                        ship_to_location_id     ,
                        ship_to_organization_id ,
                        need_by_date            ,
                        promised_date           ,
                        last_accept_date        ,
                        cancel_flag             ,
                        closed_code             ,
                        approved_flag           ,
                        price_override          ,
                        encumbered_flag         ,
                        tax_code_id             ,
                        taxable_flag            ,
                        enforce_ship_to_location_code,
                        receiving_routing_id    ,
                        inspection_required_flag,
                        receipt_required_flag   ,
                        qty_rcv_tolerance       ,
                        qty_rcv_exception_code  ,
                        days_early_receipt_allowed,
                        days_late_receipt_allowed,
                        allow_substitute_receipts_flag,
                        receipt_days_exception_code,
                        invoice_close_tolerance ,
                        receive_close_tolerance,
                        accrue_on_receipt_flag,
			tax_user_override_flag,
			calculate_tax_flag,
                        unit_meas_lookup_code,    -- Added Bug 731564
                        match_option,             -- Bug 880864
-- start of bug# 1548597
                        secondary_unit_of_measure,
                        secondary_quantity,
                        preferred_grade,
                        secondary_quantity_received,
                        secondary_quantity_accepted,
                        secondary_quantity_rejected,
                        secondary_quantity_cancelled,
                        country_of_origin_code, -- bug 2350043
-- end  of bug# 1548597
			consigned_flag,         /* CONSIGNED FPI */
			closed_reason  ,        /* CONSIGNED FPI */
                        from_header_id,         -- GA FPI
                        from_line_id ,           -- GA FPI
                        amount
                         --<DBI Req Fulfillment 11.5.11 Start >
                         ,shipment_closed_date
                         ,closed_for_receiving_date
                         ,closed_for_invoice_date
                         --<DBI Req Fulfillment 11.5.11 End >
                        ,Org_Id                     -- <R12.MOAC>
                        , value_basis               -- <Complex Work R12>
                        , matching_basis            -- <Complex Work R12>
			,outsourced_assembly --<R12 SHIKYU>
                        ,transaction_flow_header_id    -- Bug8559443
                        )
           VALUES
                      (X_line_location_id      ,
                       X_last_update_date      ,
                       X_last_updated_by       ,
                       X_creation_date         ,
                       X_created_by            ,
                       X_last_update_login     ,
                       X_po_header_id          ,
                       X_po_line_id            ,
                       '1'                     ,
                       X_type_lookup_code      ,
                       X_quantity              ,
                       '0'     ,
                       '0'     ,
                       '0'     ,
                       '0'     ,
                       '0'     ,
                       X_ship_to_location_id   ,
                       X_ship_org_id           ,
                       X_need_by_date          ,
                       X_promised_date         ,
                       ''      ,
                       'N'     ,
                       x_closed_code,   /* CONSIGNED FPI */ --'OPEN'  ,
                       'N'     ,
                       X_unit_price,
                       'N'     ,
                       X_tax_code_id                      ,
                       X_taxable_flag                  ,
                       X_enforce_ship_to_location         ,
                       X_receiving_routing_id             ,
                       l_inspection_required_flag         , /* CONSIGNED FPI */
                       l_receipt_required_flag         ,    /* CONSIGNED FPI */
                       X_qty_rcv_tolerance                ,
                       X_qty_rcv_exception_code           ,
                       X_days_early_receipt_allowed       ,
                       X_days_late_receipt_allowed        ,
                       X_allow_substitute_receipts        ,
                       X_receipt_days_exception_code      ,
                       l_invoice_close_tolerance       ,  /* CONSIGNED FPI */
                       X_receive_close_tolerance       ,
                       nvl(X_accrue_on_receipt_flag,'N'),
		       'N',
		       'Y',
                       X_unit_meas_lookup_code,   -- Added Bug 731564
		       X_invoice_match_option,   -- Bug 880864
-- start of bug# 1548597
                       X_secondary_unit_of_measure,
                       X_secondary_quantity,
                       X_preferred_grade,
                       decode(X_secondary_unit_of_measure,NULL,NULL,0),
                       decode(X_secondary_unit_of_measure,NULL,NULL,0),
                       decode(X_secondary_unit_of_measure,NULL,NULL,0),
                       decode(X_secondary_unit_of_measure,NULL,NULL,0),
                       x_country_of_origin_code, -- bug 2350043
-- end  of bug# 1548597
		       x_consigned_flag,           /* CONSIGNED FPI */
		       x_closed_reason,            /* CONSIGNED FPI */
                       l_from_header_id,           -- GA FPI
                       l_from_line_id,             -- GA FPI
                       l_amount                    -- SERVICES FPJ
                       --<DBI Req Fulfillment 11.5.11 Start >
                       ,decode(x_closed_code,'CLOSED',
                                   sysdate, null)            -- Shipment_closed_date
                       ,decode(x_closed_code,'CLOSED',sysdate,
                                'CLOSED FOR RECEIVING',sysdate,null)        -- Closed_for_receiving_date
                        ,decode(x_closed_code,'CLOSED',sysdate,
                                'CLOSED FOR INVOICE',sysdate,null)          -- closed_for_invoice_date
                        --<DBI Req Fulfillment 11.5.11 End >
                       ,p_org_id                                 -- <R12.MOAC>
                       , p_value_basis      -- <Complex Work R12>
                       , p_matching_basis   -- <Complex Work R12>
		       , p_outsourced_assembly -- <R12 SHIKYU>
                       ,l_transaction_flow_header_id    -- Bug8559443
                       );

           X_autocreated_ship := TRUE;


  exception

           when others then
                po_message_s.sql_error('autocreate_ship', X_progress, sqlcode);
                raise;

  end autocreate_ship;

PROCEDURE get_matching_controls(X_vendor_id    IN number,
			       X_line_type_id IN number,
			       X_item_id    IN number,
			       X_receipt_required_flag IN OUT NOCOPY VARCHAR2,
			       X_inspection_required_flag IN OUT NOCOPY VARCHAR2) IS

   x_progress 				VARCHAR2(3) := '';
   X_receipt_required_flag_tmp 		VARCHAR2(1) := '';
   X_inspection_required_flag_tmp 	VARCHAR2(1) := '';


   BEGIN

      -- Get receipt required flag and inspection required flags
      -- in the following order:
      --	item
      --	line type (only for receipt required)
      --	vendor
      --	system options

      x_progress := '010';

      -- bug 413511
      -- Set default values from PO system options

      -- bug 10216286 : null handling for X_receipt_required_flag
      -- and X_inspection_required_flag was missing

      BEGIN

       SELECT receiving_flag,
	      inspection_required_flag
       INTO   X_receipt_required_flag,
	      X_inspection_required_flag
       FROM   po_system_parameters;

      EXCEPTION
        WHEN OTHERS THEN
	  X_receipt_required_flag := NULL;
          X_inspection_required_flag := NULL;

      END;

      x_progress := '020';

      IF (X_vendor_id is NOT null) THEN

	SELECT receipt_required_flag,
	       inspection_required_flag
	INTO   X_receipt_required_flag_tmp,
	       X_inspection_required_flag_tmp
        FROM   po_vendors
	WHERE  vendor_id = X_vendor_id;

        -- bug 413511
        -- If the flags are not null,take them; Otherwise, bypass them

        IF X_receipt_required_flag_tmp is not NULL AND
           X_inspection_required_flag_tmp is not NULL THEN
           X_receipt_required_flag := X_receipt_required_flag_tmp;
	   X_inspection_required_flag := X_inspection_required_flag_tmp;
        END IF;

      END IF;

      x_progress := '030';

      IF (X_line_type_id is NOT null) THEN

         SELECT receiving_flag
	 INTO   X_receipt_required_flag_tmp
	 FROM   po_line_types
	 WHERE  line_type_id = X_line_type_id;

        -- bug 413511
        -- If the flag is not null, take it; Otherwise bypass it

        IF X_receipt_required_flag_tmp is not NULL THEN
           X_receipt_required_flag := X_receipt_required_flag_tmp;

     /* Bug 2174318 If the RR_flag is N then the IR_flag should
     ** be made null to override the default from vendors
     */
            IF  X_receipt_required_flag_tmp = 'N' THEN
             X_inspection_required_flag := null;
            END IF;

        END IF;

      END IF;

      x_progress := '040';

      IF (X_item_id is NOT null) THEN

         SELECT receipt_required_flag,
	        inspection_required_flag
         INTO   X_receipt_required_flag_tmp,
	        X_inspection_required_flag_tmp
	 FROM   mtl_system_items,
	        financials_system_parameters
         WHERE  inventory_item_id = X_item_id
         AND    organization_id = inventory_organization_id;

        -- bug 413511
        -- If the flags are not null,take them; Otherwise, bypass them

 	-- Bug 475621
 	-- INV Item forms allow user to set the RR_flag and IR_flag separately
 	-- need to handle one null value, change AND to OR


 -- Bug 12791538 start. Making the conditions similar to autocreate code since there is mismatch between
  -- the Defaulted Invoice Matching in Enter PO form and through Autocreate.


 IF X_receipt_required_flag_tmp is not NULL THEN

 	 X_receipt_required_flag := X_receipt_required_flag_tmp;

 end if;


 IF X_inspection_required_flag_tmp is not NULL THEN

 	 X_inspection_required_flag := X_inspection_required_flag_tmp;

 end if;

 --Bug 12791538 end.


      END IF;

   EXCEPTION
     when others then
        po_message_s.sql_error('get_matching_controls', x_progress, sqlcode);
        raise;

END get_matching_controls;



/* <TIMEPHASED FPI START> */

/*
   This procedure is used to perform the various validations on the price break
   effective Start Date, End Date and the line level Expiration Date
*/
PROCEDURE validate_effective_dates(p_start_date      IN         date,
                                   p_end_date        IN         date,
                                   p_from_date       IN         date,
                                   p_to_date         IN         date,
                                   p_expiration_date IN         date,
                                   x_errormsg        OUT NOCOPY varchar2)
IS
l_progress VARCHAR2(3) := '';

   BEGIN
      l_progress := '000';
      /* Validation for expiration date */
      if (p_expiration_date is not null) then
         if (p_start_date > p_expiration_date OR p_end_date < p_expiration_date) then

-- bug2735633
-- Error message to be returned here should be POX_EXPIRATION_DATES
-- instead of POX_EXPIRATION_DATES1

              --  x_errormsg := 'POX_EXPIRATION_DATES1';
              x_errormsg := 'POX_EXPIRATION_DATES';
            return;
         end if;
      end if;

      l_progress := '001';
      /*
         Pricebreak effective From Date cannot be earlier than Blanket Agreement header
         start date
      */
      if (p_from_date is not null AND p_from_date < p_start_date) then
         x_errormsg := 'POX_EFFECTIVE_DATES1';
         return;
      end if;


      l_progress := '002';
      /*
         Pricebreak effective From Date cannot be later than Blanket Agreement header
         end date
      */
      if (p_from_date is not null AND p_from_date > p_end_date) then
         x_errormsg := 'POX_EFFECTIVE_DATES4';
         return;
      end if;

      l_progress := '003';
      /* Pricebreak effective From Date cannot be later than Pricebreak effective To Date */
      /* Bug 2691705
       * Changed the message name to POX_EFFECTIVE_DATES3.
      */
      if (p_to_date is not null AND p_from_date is not null AND p_from_date > p_to_date ) then
         x_errormsg := 'POX_EFFECTIVE_DATES3';
         return;
      end if;

      /* Bug 2691705.
       * Price break from date cannot be greater than the blanket line
       * expiration date.
      */
      l_progress := '035';

      if (p_from_date is not null and p_from_date > p_expiration_date ) then
         x_errormsg := 'POX_EFFECTIVE_DATES6';
         return;
      end if;
      l_progress := '004';
      /*
         Pricebreak effective To Date cannot be later than Expiration date, if Expiration
         Date exists
      */
      /* Bug 2691705
       * Changed the message name to POX_EFFECTIVE_DATES2.
      */
      if (p_expiration_date is not null AND p_to_date > p_expiration_date) then
         x_errormsg := 'POX_EFFECTIVE_DATES2';
         return;
      end if;

      l_progress := '005';
      /*
         If expiration date does not exist and Pricebreak To Date is greater than Header End
         date, raise an error message
      */
      if (p_expiration_date is null AND p_end_date is not null AND p_to_date > p_end_date) then
         x_errormsg := 'POX_EFFECTIVE_DATES';
         return;
      end if;

      l_progress := '006';
      /* Pricebreak To Date cannot be earlier than Header Start date */
      if (p_start_date is not null AND p_to_date < p_start_date) then
         x_errormsg := 'POX_EFFECTIVE_DATES5';
         return;
      end if;

      l_progress := '007';
      /* Pricebreak effective To Date cannot be earlier than Pricebreak effective From Date */
      /* Bug 2691705
       * Changed the message name to POX_EFFECTIVE_DATES3.
      */
      if (p_to_date is not null AND p_from_date is not null AND p_to_date < p_from_date) then
         x_errormsg := 'POX_EFFECTIVE_DATES3';
         return;
      end if;

   EXCEPTION
      when others then
         po_message_s.sql_error('validate_effective_dates', l_progress, sqlcode);
         raise;

   END validate_effective_dates;



PROCEDURE validate_pricebreak_attributes(p_from_date        IN         date,
                                         p_to_date          IN         date,
                                         p_quantity         IN         varchar2,
                                         p_ship_to_org      IN         varchar2,
                                         p_ship_to_location IN         varchar2,
                                         x_errormsg_name    OUT NOCOPY varchar2)
IS
l_progress VARCHAR2(3) := '';

   BEGIN
      l_progress := '001';
      if (p_from_date is null AND p_to_date is null
          AND (p_quantity is null OR (to_number(p_quantity) <= 0))
          AND p_ship_to_org is null AND p_ship_to_location is null) then
          x_errormsg_name := 'POX_PRICEBREAK_ITEM_FAILED';
          return;
      end if;

   EXCEPTION
      when others then
         po_message_s.sql_error('validate_pricebreak_attributes', l_progress, sqlcode);
         raise;

   END validate_pricebreak_attributes;

/* <TIMEPHASED FPI END> */



END PO_SHIPMENTS_SV8;

/
