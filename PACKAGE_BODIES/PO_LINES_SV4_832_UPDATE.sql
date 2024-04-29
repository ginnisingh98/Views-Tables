--------------------------------------------------------
--  DDL for Package Body PO_LINES_SV4_832_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_SV4_832_UPDATE" AS
/* $Header: POXPILUB.pls 120.1.12000000.2 2007/07/18 12:25:14 puppulur ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
g_po_pdoi_write_to_file VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_PDOI_WRITE_TO_FILE'),'N');

/*===========================================================================*/
/*======================== SPECIFICATIONS (PRIVATE) =========================*/
/*===========================================================================*/

FUNCTION price_tolerance_check ( p_interface_header_id NUMBER,
				 p_interface_line_id NUMBER,
				 p_item_id NUMBER,
				 p_category_id NUMBER,
				 p_vendor_id NUMBER,
				 p_vendor_site_id NUMBER,
				 p_document_id NUMBER,
				 p_po_line_id  NUMBER,
				 p_unit_price NUMBER,
				 p_def_master_org_id NUMBER)
return BOOLEAN;

PROCEDURE delete_price_breaks (x_po_header_id NUMBER, x_po_line_id NUMBER);

PROCEDURE update_price_discount                            -- <2703076>
(   p_po_line_id        IN     PO_LINE_LOCATIONS.po_line_id%TYPE
,   p_unit_price        IN     PO_LINES.unit_price%TYPE
);

/*===========================================================================*/
/*============================ BODY (PUBLIC) ================================*/
/*===========================================================================*/

/*================================================================

  PROCEDURE NAME: 	update_po_line()

==================================================================*/

PROCEDURE update_po_line(  X_interface_header_id            IN NUMBER,
                           X_interface_line_id              IN NUMBER,
                           X_line_num                       IN NUMBER,
                           X_po_line_id                     IN NUMBER,
                           X_shipment_num               IN OUT NOCOPY NUMBER,
                           X_line_location_id           IN OUT NOCOPY NUMBER,
                           X_shipment_type                  IN VARCHAR2,
                           X_requisition_line_id            IN NUMBER,
                           X_document_num                   IN VARCHAR2,
                           X_po_header_id                   IN NUMBER,
                           X_release_num                    IN NUMBER,
                           X_po_release_id                  IN NUMBER,
                           X_source_shipment_id             IN NUMBER,
                           X_contract_num                   IN VARCHAR2,
                           X_line_type                      IN VARCHAR2,
                           X_line_type_id                   IN NUMBER,
                           X_item                           IN VARCHAR2,
                           X_item_id                        IN OUT NOCOPY NUMBER,
                           X_item_revision                  IN VARCHAR2,
                           X_category                       IN VARCHAR2,
                           X_category_id                    IN NUMBER,
                           X_item_description               IN VARCHAR2,
                           X_vendor_product_num             IN VARCHAR2,
                           X_uom_code                       IN VARCHAR2,
                           X_unit_of_measure                IN VARCHAR2,
                           X_quantity                       IN NUMBER,
                           X_committed_amount               IN NUMBER,
                           X_min_order_quantity             IN NUMBER,
                           X_max_order_quantity             IN NUMBER,
                           X_base_unit_price                IN NUMBER,	-- <FPJ Advanced Price>
                           X_unit_price                     IN NUMBER,
                           X_list_price_per_unit            IN NUMBER,
                           X_market_price                   IN NUMBER,
                           X_allow_price_override_flag      IN VARCHAR2,
                           X_not_to_exceed_price            IN NUMBER,
                           X_negotiated_by_preparer_flag    IN VARCHAR2,
                           X_un_number                      IN VARCHAR2,
                           X_un_number_id                   IN NUMBER,
                           X_hazard_class                   IN VARCHAR2,
                           X_hazard_class_id                IN NUMBER,
                           X_note_to_vendor                 IN VARCHAR2,
                           X_transaction_reason_code        IN VARCHAR2,
                           X_taxable_flag                   IN VARCHAR2,
                           X_tax_name                       IN VARCHAR2,
                           X_type_1099                      IN VARCHAR2,
                           X_capital_expense_flag           IN VARCHAR2,
                           X_inspection_required_flag       IN VARCHAR2,
                           X_receipt_required_flag          IN VARCHAR2,
                           X_payment_terms                  IN VARCHAR2,
                           X_terms_id                       IN NUMBER,
                           X_price_type                     IN VARCHAR2,
                           X_min_release_amount             IN NUMBER,
                           X_price_break_lookup_code        IN VARCHAR2,
                           X_ussgl_transaction_code         IN VARCHAR2,
                           X_closed_code                    IN VARCHAR2,
                           X_closed_reason                  IN VARCHAR2,
                           X_closed_date                    IN DATE,
                           X_closed_by                      IN NUMBER,
                           X_invoice_close_tolerance        IN NUMBER,
                           X_receive_close_tolerance        IN NUMBER,
                           X_firm_flag                      IN VARCHAR2,
                           X_days_early_receipt_allowed     IN NUMBER,
                           X_days_late_receipt_allowed      IN NUMBER,
                           X_enforce_ship_to_loc_code       IN VARCHAR2,
                           X_allow_sub_receipts_flag        IN VARCHAR2,
                           X_receiving_routing              IN VARCHAR2,
                           X_receiving_routing_id           IN NUMBER,
                           X_qty_rcv_tolerance              IN NUMBER,
                           X_over_tolerance_error_flag      IN VARCHAR2,
                           X_qty_rcv_exception_code         IN VARCHAR2,
                           X_receipt_days_exception_code    IN VARCHAR2,
                           X_ship_to_organization_code      IN VARCHAR2,
                           X_ship_to_organization_id        IN NUMBER,
                           X_ship_to_location               IN VARCHAR2,
                           X_ship_to_location_id            IN NUMBER,
                           X_need_by_date                   IN DATE,
                           X_promised_date                  IN DATE,
                           X_accrue_on_receipt_flag         IN VARCHAR2,
                           X_lead_time                      IN NUMBER,
                           X_lead_time_unit                 IN VARCHAR2,
                           X_price_discount                 IN NUMBER,
                           X_freight_carrier                IN VARCHAR2,
                           X_fob                            IN VARCHAR2,
                           X_freight_terms                  IN VARCHAR2,
                           X_effective_date                 IN DATE,
                           X_expiration_date                IN DATE,
                           X_from_header_id                 IN NUMBER,
                           X_from_line_id                   IN NUMBER,
                           X_from_line_location_id          IN NUMBER,
                           X_line_attribute_catg_lines      IN VARCHAR2,
                           X_line_attribute1                IN VARCHAR2,
                           X_line_attribute2                IN VARCHAR2,
                           X_line_attribute3                IN VARCHAR2,
                           X_line_attribute4                IN VARCHAR2,
                           X_line_attribute5                IN VARCHAR2,
                           X_line_attribute6                IN VARCHAR2,
                           X_line_attribute7                IN VARCHAR2,
                           X_line_attribute8                IN VARCHAR2,
                           X_line_attribute9                IN VARCHAR2,
                           X_line_attribute10               IN VARCHAR2,
                           X_line_attribute11               IN VARCHAR2,
                           X_line_attribute12               IN VARCHAR2,
                           X_line_attribute13               IN VARCHAR2,
                           X_line_attribute14               IN VARCHAR2,
                           X_line_attribute15               IN VARCHAR2,
                           X_shipment_attribute_category    IN VARCHAR2,
                           X_shipment_attribute1            IN VARCHAR2,
                           X_shipment_attribute2            IN VARCHAR2,
                           X_shipment_attribute3            IN VARCHAR2,
                           X_shipment_attribute4            IN VARCHAR2,
                           X_shipment_attribute5            IN VARCHAR2,
                           X_shipment_attribute6            IN VARCHAR2,
                           X_shipment_attribute7            IN VARCHAR2,
                           X_shipment_attribute8            IN VARCHAR2,
                           X_shipment_attribute9            IN VARCHAR2,
                           X_shipment_attribute10           IN VARCHAR2,
                           X_shipment_attribute11           IN VARCHAR2,
                           X_shipment_attribute12           IN VARCHAR2,
                           X_shipment_attribute13           IN VARCHAR2,
                           X_shipment_attribute14           IN VARCHAR2,
                           X_shipment_attribute15           IN VARCHAR2,
                           X_last_update_date               IN DATE,
                           X_last_updated_by                IN NUMBER,
                           X_last_update_login              IN NUMBER,
                           X_creation_date                  IN DATE,
                           X_created_by                     IN NUMBER,
                           X_request_id                     IN NUMBER,
                           X_program_application_id         IN NUMBER,
                           X_program_id                     IN NUMBER,
                           X_program_update_date            IN DATE,
                           X_organization_id                IN NUMBER,
			   X_item_attribute_category	    IN VARCHAR2,
                           X_item_attribute1                IN VARCHAR2,
                           X_item_attribute2                IN VARCHAR2,
                           X_item_attribute3                IN VARCHAR2,
                           X_item_attribute4                IN VARCHAR2,
                           X_item_attribute5                IN VARCHAR2,
                           X_item_attribute6                IN VARCHAR2,
                           X_item_attribute7                IN VARCHAR2,
                           X_item_attribute8                IN VARCHAR2,
                           X_item_attribute9                IN VARCHAR2,
                           X_item_attribute10               IN VARCHAR2,
                           X_item_attribute11               IN VARCHAR2,
                           X_item_attribute12               IN VARCHAR2,
                           X_item_attribute13               IN VARCHAR2,
                           X_item_attribute14               IN VARCHAR2,
                           X_item_attribute15               IN VARCHAR2,
                           X_unit_weight                    IN NUMBER,
                           X_weight_uom_code                IN VARCHAR2,
                           X_volume_uom_code                IN VARCHAR2,
                           X_unit_volume                    IN NUMBER,
                           X_template_id                    IN NUMBER,
                           X_template_name                  IN VARCHAR2,
                           X_line_reference_num             IN VARCHAR2,
                           X_sourcing_rule_name             IN VARCHAR2,
                           X_quantity_committed             IN NUMBER,
                           X_government_context             IN VARCHAR2,
	                   X_hd_load_sourcing_flag          IN  VARCHAR2,
                           X_load_sourcing_rules_flag       IN VARCHAR2,
                           X_update_po_line_flag            IN  VARCHAR2,
                           X_create_po_line_loc_flag        IN  VARCHAR2,
                           X_header_processable_flag        IN  OUT NOCOPY VARCHAR2,
                           X_create_items                   IN  VARCHAR2,    -- create or update item
                           X_def_purch_org_id               IN  NUMBER,
                           X_def_inv_org_id                 IN  NUMBER,
                           X_def_master_org_id              IN  NUMBER,
                           X_approved_flag                  IN VARCHAR2,
                           X_approved_date                  IN DATE,
                           X_vendor_id                      IN NUMBER,
                           X_document_type                  IN VARCHAR2,
                           X_current_po_header_id           IN NUMBER,
                           X_line_quantity                  IN NUMBER,
			   X_approval_status		    IN VARCHAR2,
			   X_rel_gen_method		    IN VARCHAR2,
			   X_price_tolerance_flag 	    IN OUT NOCOPY VARCHAR2,
			   X_price_breaks_deleted	    IN OUT NOCOPY VARCHAR2,
			   x_line_updated_flag		    IN OUT NOCOPY VARCHAR2,
			   --togeorge 09/28/2000
			   --added  oke variables
			   X_note_to_receiver		    IN VARCHAR2,
			   X_oke_contract_header_id         IN NUMBER,
			   X_oke_contract_version_id        IN NUMBER,
                           --<SERVICES FPJ START>
                           p_job_id                         IN NUMBER,
                           p_amount                         IN NUMBER,
                           p_order_type_lookup_code         IN VARCHAR2,
                           p_purchase_basis                 IN VARCHAR2
                           --<SERVICES FPJ END>
)
IS

	X_progress	VARCHAR2(3) := NULL;
	X_cancel_flag	VARCHAR2(1) := NULL;
	X_unordered_flag VARCHAR2(1) := NULL;
	X_result_flag   BOOLEAN := FALSE;
	X_update_item	VARCHAR2(2);
   	X_allow_item_desc_update_flag  mtl_system_items.allow_item_desc_update_flag%TYPE;
   	X_msi_item_description         mtl_system_items.description%TYPE := NULL;
	x_doc_line_unit_price	NUMBER;
	x_current_line_uom_code  varchar2(25);
	x_current_line_item_desc varchar2(240);
	X_current_expiration_date    date;
	l_process_code		 VARCHAR2(25);
        l_start_date date;
        l_end_date   date;
	/* Bug 2722795 */
	l_retroactive_date po_lines.retroactive_date%type := null;
	l_price_break_lookup_code po_lines.price_break_lookup_code%type;
    l_transaction_flow_header_id
           PO_LINE_LOCATIONS_ALL.transaction_flow_header_id%TYPE; --< Shared Proc FPJ >
    l_uom_valid boolean := TRUE; -- bug 3335027
    l_uom_different boolean := FALSE; -- bug 3335027
    l_update_exp_date boolean := FALSE; -- bug 3335027
    l_conv_price  number;
    l_conv_rate   number;
    l_precision   FND_CURRENCIES.precision%type;
    l_header_processable_flag  varchar2(1);
    l_price_break_ct number;
    l_current_line_price_limit number;

Begin

 IF (g_po_pdoi_write_to_file = 'Y') THEN
    PO_DEBUG.put_line ('Start update of line/creation of price breaks');
    PO_DEBUG.put_line ('header id:'|| to_char(X_current_po_header_id));
    PO_DEBUG.put_line ('line id:'|| to_char(X_po_line_id ));
    PO_DEBUG.put_line ('X_update_po_line_flag:' || X_update_po_line_flag );
    PO_DEBUG.put_line ('X_price_tolerance_flag:' || X_price_tolerance_flag);
 END IF;

 x_line_updated_flag := 'N';

 -- If X_update_po_line_flag is 'Y' then update corresponding line in po_lines.
 -- If X_create_po_line_loc_flag is 'Y' then create a price break in po_line_locations.

 X_progress := '010';


/* begin bug 3335027
We need to validate UOM and expiration date before updating anything. */

   select unit_meas_lookup_code ,
          not_to_exceed_price
   into x_current_line_uom_code,
        l_current_line_price_limit
   from po_lines
   where po_header_id = x_current_po_header_id
   and   po_line_id   = x_po_line_id;

   IF ((x_current_line_uom_code is null and p_order_type_lookup_code <> 'FIXED PRICE') or
    (x_unit_of_measure is not null and x_unit_of_measure <> nvl(x_current_line_uom_code,x_unit_of_measure))) then

         l_uom_valid := po_unit_of_measures_sv1.val_unit_of_measure(
                                               X_unit_of_measure,
                                               NULL);
         IF (l_uom_valid = FALSE) THEN
            po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'FATAL',
                                          null,
                                          X_interface_header_id,
                                          X_interface_line_id,
                                         'PO_PDOI_INVALID_UOM_CODE',
                                         'PO_LINES_INTERFACE',
                                         'UNIT_OF_MEASURE',
                                         'VALUE',
                                          null, null, null, null, null,
                                          X_unit_of_measure,
                                          null, null, null, null, null,
                                          X_header_processable_flag);
        ELSE
              l_uom_different := TRUE;
        END IF;

   END IF;
/* End bug 3335027 */

 IF ((X_update_po_line_flag = 'Y') and (X_header_processable_flag = 'Y')) THEN

   IF (g_po_pdoi_write_to_file = 'Y') THEN
      PO_DEBUG.put_line('Skip line validation process for line update');
   END IF;

   X_progress := '020';

   -- During validation of item we also check if the item
   -- description or price for the item is different at item master
   -- if it is different and item updates are allowed
   -- allow_item_desc_update_flag in mtl_system_items is 'Y' then we
   -- update the two in mtl_system_items table.

   -- We allow update to the master items description through the update action
   -- if allow_item_desc_update_flag is 'N' and description is different we log errors
   -- except for one-time items.

   -- we need not care about the other function performed by the call. i.e
	   --  insert_item_master()
	   --  handle_ioi_to_po_errors()  - in case there are errors in updating/creating the item.
                 --  val_item_interface()
                 -- these are for inventory interface.

   IF (g_po_pdoi_write_to_file = 'Y') THEN
      PO_DEBUG.put_line('Item description is:' || x_item_description);
   END IF;
 /*
   Bug 2696413
   While updating we do not need to check the item description. If it
   exists we can proceed with updating if required else skip the item
   updation.
 */

   /*** also need to find out if item_description is different from
        what is setup for the item. Would not allow item_description update
        if item attribute allow_item_desc_update_flag is N
   ****/
   X_progress := '021';

   if x_po_line_id is not NULL then
	   select item_description into x_current_line_item_desc
	   from po_lines
	   where po_header_id = x_current_po_header_id
	   and   po_line_id   = x_po_line_id;
   end if;

   if X_item_id is not null then  -- item exists in item master.

	/** Bug 5366732 If foreign language is used then item_desc comparision was always
Failing because derived value of X_item_description was coming from
mtl_system_items_tl to keep consistency changing below SQL to fetch item desc
from mtl_system_items_tl **/

X_msi_item_description:=null;

      SELECT    msi.allow_item_desc_update_flag,
               mtl.description
        INTO    X_allow_item_desc_update_flag,
                X_msi_item_description
       FROM     mtl_system_items msi, mtl_system_items_tl mtl
       WHERE    mtl.inventory_item_id = msi.inventory_item_id
              and mtl.organization_id = msi.organization_id
              and mtl.language = USERENV('LANG')
              and mtl.inventory_item_id = X_item_id
              and msi.organization_id = X_def_inv_org_id;
/* Bug 5366732 End */

   else
	X_allow_item_desc_update_flag := 'Y';
   end if;

   X_progress :=  '022';
   /*Bug 1267907
     On an update action if the  item description in the edi file is different from
     the description in the catalog and the allow_item_desc_flag_update is Yes, then
     update  po_lines.item_description ,need not check if create_items is Yes too
     bcos that is only for checking if the item_master needs to be updated too.
   */
   IF (X_allow_item_desc_update_flag = 'N')
	AND
      	(X_item_description <> nvl(X_msi_item_description, X_item_description)
	 OR
	 X_item_description <> x_current_line_item_desc
	 )
   THEN
		/*** error because descriptions do not match and item attribute
		     does not allow item description update  and update item runtime
		     parameter is set to N.
		     both these flags must be 'Y' for desc to be updated.
		***/

      	  	X_progress :=  '110';
		X_update_item := 'N';

          	po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'FATAL',
                                          null,
                                          X_interface_header_id,
                                          X_interface_line_id,
                                         'PO_PDOI_DIFF_ITEM_DESC',
                                         'PO_LINES_INTERFACE',
                                         'ITEM_DESCRIPTION',
                                          null, null, null, null, null, null,
                                          null, null, null, null, null, null,
                                          X_header_processable_flag);

   ELSE  /* Bug 2696413 */
      if (x_item_description is null ) then
        X_update_item := 'N';
      else
	X_update_item := 'Y';
      end if;
   END IF;

   /* Bug 1267907
   Added the check to update the item master only if
   the value of x_create_items is set to yes too.
   */

   if (X_update_item = 'Y'             and
       NVL(X_create_items, 'N') = 'Y'  and
       X_item_id is not NULL)      then

	-- Update item master ( mtl_system_items table )

	UPDATE mtl_system_items
        SET  description = x_item_description,
             last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id,
             request_id = fnd_global.conc_request_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id = fnd_global.conc_program_id,
             program_update_date = sysdate
        WHERE  inventory_item_id = X_item_id
        AND  organization_id = x_def_master_org_id;

	/* Bug 2064714 - GMudgal
	** Added the following update statement since we need to update
	** the description in the tl table as well */

	UPDATE mtl_system_items_tl
        SET  description = x_item_description
        WHERE  inventory_item_id = X_item_id
        AND  organization_id = x_def_master_org_id
		and  language = USERENV('LANG');

   end if;

   if (X_update_item = 'Y') then

        IF (g_po_pdoi_write_to_file = 'Y') THEN
   	  PO_DEBUG.put_line ('Updating the desc to:' || x_item_description);
	END IF;

	UPDATE po_lines
	SET item_description = x_item_description,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id,
            request_id = fnd_global.conc_request_id,
            program_application_id = fnd_global.prog_appl_id,
            program_id = fnd_global.conc_program_id,
            program_update_date = sysdate
	WHERE po_line_id = x_po_line_id
	AND   po_header_id = x_current_po_header_id;

	x_line_updated_flag := 'Y';

   end if;

   -- Need to populate the following fields .  These columns do not appear in the interface table.

   IF (X_document_type = 'BLANKET') THEN
	X_unordered_flag := 'N';
	X_cancel_flag    := 'N';

	select trunc(expiration_date) into x_current_expiration_date
	from po_lines
	where po_header_id = x_current_po_header_id
	and po_line_id	   = x_po_line_id;

	if (NVL(trunc(x_expiration_date), trunc(sysdate)) <> NVL(trunc(x_current_expiration_date), trunc(sysdate))
		OR
		x_expiration_date is not null and x_current_expiration_date is null ) then

        l_update_exp_date := TRUE;
--bug 3335027 comment below update since expiration date will be updated when unit_price is
	end if;

   ELSE
	X_unordered_flag := NULL;
	X_cancel_flag    := NULL;
   END IF;

   IF (g_po_pdoi_write_to_file = 'Y') THEN
      PO_DEBUG.put_line ('Unit price update - unit_price:' || to_char(X_unit_price));
   END IF;

   select unit_price, retroactive_date,price_break_lookup_code -- 2722795
   into x_doc_line_unit_price,l_retroactive_date,l_price_break_lookup_code --2722795
   from po_lines
   where po_header_id = x_current_po_header_id
   and   po_line_id   = x_po_line_id;


   IF (X_unit_price is NOT NULL and NVL(x_unit_price, x_doc_line_unit_price) <>  x_doc_line_unit_price) then

	-- Perform price tolerance check,
	-- If successful then Archive the line and then update the price information.

	-- Check price tolerance.


    if(l_uom_different = FALSE) then -- bug 3335027: check price tolerance only if UOM is same
	    X_result_flag := price_tolerance_check (X_interface_header_id,
	    				 	X_interface_line_id,
		    				X_item_id,
			    			x_category_id,
				    		X_vendor_id,
					    	NULL, -- X_vendor_site_id
			    			x_po_header_id,
			    			x_po_line_id,
			    			X_unit_price,
			    			x_def_master_org_id);
    else
        x_result_flag := TRUE;
    end if; --bug 3335027

	If X_result_flag then

	   	-- Update the price information.

		/* Bug 2722795. When we update an existing blanket with
		 * a new unit_price, retroactive_date in po_lines must
		 * be updated with the timestamp. This has to be done
		 * for non-cumulative blanket lines only.
		*/
		IF (g_po_pdoi_write_to_file = 'Y') THEN
	  	  PO_DEBUG.put_line('X_price_break_lookup_code '||X_price_break_lookup_code);
		  PO_DEBUG.put_line('X_document_type '||X_document_type);
		END IF;
		IF ((X_document_type = 'BLANKET') and
		    (nvl(l_price_break_lookup_code,'NON CUMULATIVE') =
						'NON CUMULATIVE')) THEN
			l_retroactive_date := sysdate;
		END IF;

		IF (g_po_pdoi_write_to_file = 'Y') THEN
   		PO_DEBUG.put_line ('Updating the unit price');
		END IF;


		UPDATE po_lines
		SET unit_price = X_unit_price,
            base_unit_price = NVL(X_base_unit_price, X_unit_price), -- <FPJ Advanced Price>
    	    retroactive_date = l_retroactive_date, -- 2722795
            	    last_update_date = sysdate,
              	    last_updated_by = fnd_global.user_id,
               	    last_update_login = fnd_global.login_id,
               	    request_id = fnd_global.conc_request_id,
               	    program_application_id = fnd_global.prog_appl_id,
               	    program_id = fnd_global.conc_program_id,
               	    program_update_date = sysdate
    		WHERE po_line_id = x_po_line_id
    		AND   po_header_id = x_current_po_header_id;

        -- <2703076 START>: For Blankets, we do not delete Price Breaks when
        -- updating the Line. Therefore, we need to specifically go and update
        -- price_discount in Price Breaks to reflect the new Line price.
        --
        IF ( x_document_type = 'BLANKET' ) THEN

            update_price_discount( x_po_line_id, x_unit_price );

        ELSE -- Else, for non-Blankets, delete all Price Breaks for this Line.

            delete_price_breaks ( x_current_po_header_id, x_po_line_id );
            x_price_breaks_deleted := 'Y';

        END IF;
        --
        -- <2703076>

		x_line_updated_flag := 'Y';
		X_price_tolerance_flag := 'N';
	else
		-- Price tolerance check failed.
		-- Mark the line as Notified

		update po_lines_interface
		set process_code = 'NOTIFIED'
		where interface_line_id = X_interface_line_id
		and interface_header_id = X_interface_header_id;

		X_price_tolerance_flag := 'Y';
        l_update_exp_date := FALSE; --bug 3335027

	end if;
   END IF;          -- x_unit_price not null

   --begin bug 3335027: update expiration date
   IF(l_update_exp_date) THEN
            UPDATE po_lines
            SET expiration_date = trunc(x_expiration_date),
                last_update_date = trunc(sysdate),
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id,
                request_id = fnd_global.conc_request_id,
                program_application_id = fnd_global.prog_appl_id,
                program_id = fnd_global.conc_program_id,
                program_update_date = trunc(sysdate)
             WHERE po_line_id = x_po_line_id
             AND   po_header_id = x_current_po_header_id;
   END IF;
   --end bug 3335027
   -- Update UOM


   if (x_unit_of_measure is not null and
      upper(x_unit_of_measure) <> nvl(upper(x_current_line_uom_code),upper(x_unit_of_measure))) then

        IF (g_po_pdoi_write_to_file = 'Y') THEN
          PO_DEBUG.put_line ('UOM update - current uom on line :' || x_current_line_uom_code);
          PO_DEBUG.put_line ('UOM update - new uom :' ||x_unit_of_measure );
          PO_DEBUG.put_line ('UOM update - new price :' ||X_unit_price );
        END IF;

         select fnd.precision
         into l_precision
         from fnd_currencies fnd,
         po_headers poh
         where poh.currency_code = fnd.currency_code
         and poh.po_header_id = x_current_po_header_id;

        -- Bug 3346174
        -- If a blanket line is updated with a different UOM then the
        -- unit price on the line is updated with the price converted
        -- to the new uom. Also a warning message is inserted in the
        -- interface table to let the users know that they need to update
        -- the price limit and price break prices accordingly.
        -- Bug 3489387
        -- The existing price is converted only if a new price is not
        -- specified.
        IF (X_unit_price is NULL) THEN

         Begin
           po_uom_s.po_uom_conversion(x_current_line_uom_code,
                                   x_unit_of_measure,
                                   nvl(X_item_id,0),
                                   l_conv_rate );

          l_conv_price := round((x_doc_line_unit_price/l_conv_rate),l_precision);

         Exception
          When others then
            -- Log an error message if uom conversion fails for some reason
            po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'FATAL',
                                          null,
                                          X_interface_header_id,
                                          X_interface_line_id,
                                         'PO_PDOI_INVALID_UOM_CODE',
                                         'PO_LINES_INTERFACE',
                                         'UNIT_OF_MEASURE',
                                         'VALUE',
                                          null,null, null, null, null,
                                          x_unit_of_measure,
                                          null,null, null, null, null,
                                          X_header_processable_flag );
         end;

        ELSE
          l_conv_price := X_unit_price;
        END IF;

	-- update uom and converted price on the doc.

	IF (g_po_pdoi_write_to_file = 'Y') THEN
           PO_DEBUG.put_line ('Updating the UOM to:' || x_unit_of_measure);
           PO_DEBUG.put_line ('Updating the price to:' || X_unit_price);
	END IF;

       IF (X_header_processable_flag = 'Y')  THEN

	  UPDATE po_lines
   	  SET unit_meas_lookup_code = x_unit_of_measure,
            unit_price = l_conv_price,
            base_unit_price = NVL(X_base_unit_price, l_conv_price),
    	    retroactive_date = l_retroactive_date,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id,
            request_id = fnd_global.conc_request_id,
            program_application_id = fnd_global.prog_appl_id,
            program_id = fnd_global.conc_program_id,
            program_update_date = sysdate
   	  WHERE po_line_id = x_po_line_id
	  AND   po_header_id = x_current_po_header_id;

         -- pass a local header processable flag so that the actual
         -- flag is not updated which marks the record as failed as
         -- this message is just supposed to be a warning
         -- Insert the warning only if price breaks exist
         Begin
           select count(*)
           into l_price_break_ct
           from po_line_locations_all
           where po_line_id = x_po_line_id
           and shipment_type = 'PRICE BREAK';
         Exception
           When others then
             l_price_break_ct := 0;
         End;

        IF l_price_break_ct <> 0 OR l_current_line_price_limit is not null THEN

          IF X_unit_price is null THEN  -- Bug 3489387
           po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'WARNING',
                                          null,
                                          X_interface_header_id,
                                          X_interface_line_id,
                                         'PO_BLANKET_UPDATE_PRICE_BREAKS',
                                         'PO_LINES_INTERFACE',
                                         'UNIT_OF_MEASURE',
                                          null,null, null, null, null, null,
                                          null,null, null, null, null, null,
                                          l_header_processable_flag );
          ELSE
           po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'WARNING',
                                          null,
                                          X_interface_header_id,
                                          X_interface_line_id,
                                         'PO_BLANKET_UPDATE_PB_NO_CONV',
                                         'PO_LINES_INTERFACE',
                                         'UNIT_OF_MEASURE',
                                          null,null, null, null, null, null,
                                          null,null, null, null, null, null,
                                          l_header_processable_flag );

          END IF;  -- unit price populated in the interface

        END IF; -- price limit or price breaks exist

 	x_line_updated_flag := 'Y';

       END IF;
   end if;

   -- Update URL

   If (X_line_attribute14 is not NULL) then

	-- Note that URL changes do not require archiving hence x_line_updated_flag is not set to 'Y'
	IF (g_po_pdoi_write_to_file = 'Y') THEN
   	PO_DEBUG.put_line ('Updating the URL to:' || X_line_attribute14);
	END IF;

	UPDATE po_lines
	SET ATTRIBUTE14 = X_line_attribute14,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id,
            request_id = fnd_global.conc_request_id,
            program_application_id = fnd_global.prog_appl_id,
            program_id = fnd_global.conc_program_id,
            program_update_date = sysdate
	WHERE po_line_id = x_po_line_id
	AND   po_header_id = x_current_po_header_id;

   end if;

   --<SERVICES FPJ START>
   X_progress := '030';

   IF (g_po_pdoi_write_to_file = 'Y') THEN
     PO_DEBUG.put_line ('Start updating amount');
   END IF;

   IF (NVL(p_amount, 0) <> 0) THEN
      UPDATE PO_LINES
      SET    amount = p_amount,
             last_update_date = sysdate,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id,
             request_id = FND_GLOBAL.conc_request_id,
             program_application_id = FND_GLOBAL.prog_appl_id,
             program_id = FND_GLOBAL.conc_program_id,
             program_update_date = sysdate
      WHERE  po_line_id = x_po_line_id
	     AND po_header_id = x_current_po_header_id;
   END IF;

   --<SERVICES FPJ END>

 END IF;   --  condition for (X_update_po_line_flag = 'Y') and ...


 --<SERVICES FPJ START>
 --Add price differential records to an existing blanket line
 X_progress := '040';

 IF (g_po_pdoi_write_to_file = 'Y') THEN
   PO_DEBUG.put_line ('Start create price differentials for the line');
   PO_DEBUG.put_line('**update_po_line_flag: '||x_update_po_line_flag
                     || ' header_processable_flag: '||x_header_processable_flag
                     || 'order_type_lookup_code: '||p_order_type_lookup_code);

 END IF;


 IF ((X_update_po_line_flag = 'Y') AND (X_header_processable_flag = 'Y')) THEN
   IF  (p_order_type_lookup_code = 'RATE') THEN

     PO_PRICE_DIFFERENTIALS_PVT.validate_price_differentials(
                  p_interface_header_id     => X_interface_header_id,
                  p_interface_line_id       => X_interface_line_id,
                  p_entity_type             => 'BLANKET LINE',
                  p_entity_id               => X_po_line_id,
                  p_header_processable_flag => X_header_processable_flag);

     IF (g_po_pdoi_write_to_file = 'Y') THEN
       PO_DEBUG.put_line ('interface_line_id: '||x_interface_line_id||
                          ' entity_id: ' ||x_po_line_id);
     END IF;

     --create price differential records
     PO_PRICE_DIFFERENTIALS_PVT.create_from_interface(
                  p_interface_line_id        => X_interface_line_id,
                  p_entity_id                => X_po_line_id);

   END IF; --IF  (p_order_type_lookup_code = 'RATE')
 END IF; --IF ((X_update_po_line_flag = 'Y')...
 --<SERVICES FPJ END>

 --
 -- Line is a price break line if X_create_po_line_loc_flag = 'Y' - insert in po_line_locations.
 --

 IF (X_create_po_line_loc_flag = 'Y') AND
    (X_header_processable_flag = 'Y') AND
    (X_price_tolerance_flag = 'N') THEN

        /* <TIMEPHASED FPI START> */
        /* If the document is a Blanket Agreement, pricebreak deletion is prevented */
        if (X_document_type <> 'BLANKET') then
	   IF NVL(X_price_breaks_deleted, 'N') = 'N' then

		-- Delete all the price breaks for this line - if any
		delete_price_breaks (x_current_po_header_id, x_po_line_id);
		X_price_breaks_deleted := 'Y';
	   END IF;
        end if;
        /* <TIMEPHASED FPI END> */

	IF (g_po_pdoi_write_to_file = 'Y') THEN
   	PO_DEBUG.put_line ('Start Creating Price Break/ Shipment Line - X_price_breaks_deleted:' || X_price_breaks_deleted);
	END IF;

	X_progress := '055';
	x_line_updated_flag := 'Y';
        IF (g_po_pdoi_write_to_file = 'Y') THEN
           PO_DEBUG.put_line('Start validate po_line_coordination process');
        END IF;

        /* call this procedure to make sure that for each po_line_location
           record that we are going to create, we will always be able to
           find a coordinated match in po_lines
        */

	--
	-- We derive the shipment number and line_location_id at this stage as the original price breaks
	-- have already been deleted.
	--

	IF (X_shipment_num IS NULL ) THEN
	   SELECT NVL(MAX(shipment_num),0) +1
             INTO X_shipment_num
	     FROM po_line_locations
	    WHERE po_header_id = X_po_header_id
	      AND po_line_id = X_po_line_id
	      --Bug# 1549896
	      --togeorge 01/29/2001
	      --The above condition only takes care of the case of BLANKETS
	      --but ignores the case of QUOTATIONS which have a shipment_type='QUOTATION'
	      --Hence using X_shipment_type instead of  PRICE BREAK below.
              AND shipment_type = X_shipment_type;
              --AND shipment_type = 'PRICE BREAK';
	END IF;
/* Bug 2794986 commented if condition which generates line_location_id
   rather we will generate the new id everytime.
   earlier it was retaining old line_location_id which was in turn
   creating problems in PO change history comparisons.
*/



         SELECT po_line_locations_s.nextval
             INTO X_line_location_id
             FROM dual;


        /* Bug 2845962. Added a new parameter, X_line_num. */
        po_line_locations_sv7.validate_po_line_coordination(
                                    X_interface_header_id,
                                    X_interface_line_id,
                                    X_item_id,
                                    X_item_description,
                                    X_item_revision,
                                    X_po_line_id,
                                    X_current_po_header_id,
                                    X_unit_of_measure,
                                    X_line_type_id,
                                    X_category_id,
                                    X_document_type,
                                    X_header_processable_flag,
                                    X_line_num,
                                    p_job_id); --<SERVICES FPJ>

  	X_progress := '060';
        /* if after line default, the create_po_line_location_flag
           is 'Y', then we will go ahead and validate line location */
           IF (g_po_pdoi_write_to_file = 'Y') THEN
              PO_DEBUG.put_line('Start validate line locations');
           END IF;

	--
	-- DO WE perform a complete validation. YES as we are creating a new line
	--

        po_line_locations_sv7.validate_po_line_locations(
                       	X_interface_header_id,
                       	X_interface_line_id,
                       	X_line_location_id,
 		       	X_last_update_date,
 		       	X_last_updated_by,
 		       	X_current_po_header_id,
 		 	X_po_line_id,
 			X_last_update_login ,
 			X_creation_date,
 			X_created_by,
 			X_quantity,
 			NULL,  /* quantity_received */
 			NULL,  /* quantity_accepted */
 			NULL,  /* quantity_rejected */
 			NULL,  /* quantity_billed */
 			NULL,  /* quantity_cancelled */
 			X_unit_of_measure,
 			X_po_release_id,
 			X_ship_to_location_id,
 			X_freight_carrier,
 			X_need_by_date,
 			X_promised_date,
 			NULL, /* last_accept_date */
 			X_unit_price, /* price_override */
 			NULL, /* encumbered_flag*/
                        NULL, /* encumbered_date */
 			X_fob,
 			X_freight_terms,
 			X_taxable_flag,
 			X_tax_name,
                        NULL, /* estimated_tax_amount */
 			X_from_header_id,
 			X_from_line_id,
 			X_from_line_location_id,
 			X_effective_date,
 			X_expiration_date,
 			X_lead_time,
 			X_lead_time_unit,
 			X_price_discount,
                        X_terms_id,
 			X_approved_flag,
                        X_approved_date,
 			NULL, /* closed_flag */
 			NULL, /* X_cancel_flag */
 			NULL, /*cancelled_by */
 			NULL, /*cancel_date*/
 			NULL, /*cancel_reason*/
 			NULL,  /* firm_status_lookup_code */
                        NULL, /* firm_date */
 			X_shipment_attribute_category,
 			X_shipment_attribute1,
 			X_shipment_attribute2,
 			X_shipment_attribute3,
 			X_shipment_attribute4,
 			X_shipment_attribute5,
 			X_shipment_attribute6,
 			X_shipment_attribute7,
 			X_shipment_attribute8,
 			X_shipment_attribute9,
 			X_shipment_attribute10,
                        NULL,  /* unit_of_measure_class */
 			X_shipment_attribute11,
 			X_shipment_attribute12,
 			X_shipment_attribute13,
 			X_shipment_attribute14,
 			X_shipment_attribute15,
 			X_inspection_required_flag,
 			X_receipt_required_flag,
 			X_qty_rcv_tolerance,
 			X_qty_rcv_exception_code,
                        X_enforce_ship_to_loc_code,
 			X_allow_sub_receipts_flag,
 			X_days_early_receipt_allowed,
 			X_days_late_receipt_allowed,
 			X_receipt_days_exception_code,
 			X_invoice_close_tolerance,
 			X_receive_close_tolerance,
 			X_ship_to_organization_id,
 			X_shipment_num,
 			X_source_shipment_id ,
 			X_shipment_type,
 			X_closed_code,
 			X_request_id,
 			X_program_application_id,
 			X_program_id,
 			X_program_update_date,
 			NULL,  -- <R12 SLA replaced by null>
 			X_government_context,
			X_receiving_routing_id,
 			NULL,    /* accrue_on_receipt_flag */
 			X_closed_reason,
 			X_closed_date,
 			X_closed_by,
			X_organization_id,
                        X_def_inv_org_id,
                        X_header_processable_flag,
                        X_document_type,
                        X_item_id,
                        X_item_revision,
                        x_category_id,                 --< Shared Proc FPJ >
                        l_transaction_flow_header_id, --< Shared Proc FPJ >
                        p_order_type_lookup_code, --<SERVICES FPJ>
                        p_purchase_basis,         --<SERVICES FPJ>
                        p_job_id);                --<SERVICES FPJ>
 END IF;

 IF (X_header_processable_flag = 'Y') AND
    (X_create_po_line_loc_flag = 'Y') AND
    (X_price_tolerance_flag = 'N') then

    /* if no error found after line location validation,
       then insert a new rec in line_locaiton table */

	X_progress := '070';
        IF (g_po_pdoi_write_to_file = 'Y') THEN
           PO_DEBUG.put_line('Start insert new record into line location');
        END IF;

	--
	-- UPDATE THE PRICE BREAK INFORMATION HERE - note that any old price breaks,if any,
	-- 					     would have been deleted by now.
	-- ASSUMPTION - We always update a line before updating the price breaks for that line.
	-- 		this is a safe assumption as the price break creation will fail if the line
	--		for which we are creating the price break does not exist in po_lines table.
	--		Coordination check will fail.
	--

        /* <TIMEPHASED FPI START> */
    --Bug#4040677 Start
    --This SQL neglects QUOTATIONS. Fixing to check shipment_type against argument provided
    -- and not to look for type_lookup_code. Hence, removed the condition for type_lookup_code

        BEGIN
           SELECT NVL(MAX(pll.shipment_num),0) + 1
           INTO X_shipment_num
           FROM po_line_locations pll,
                po_headers_all poh
           WHERE pll.po_header_id = X_po_header_id
           AND pll.po_line_id = X_po_line_id
           AND poh.po_header_id = pll.po_header_id
           AND pll.shipment_type = x_shipment_type;
        EXCEPTION
           when others then
              null;
        END;
    --Bug#4040677 End
        /* <TIMEPHASED FPI END> */

        /* Bug 2722795. Insert retroactive_Date in po_lines with the timestamp
         * if a price break row is inserted.
        */

        IF ((X_document_type = 'BLANKET') and
             (nvl(l_price_break_lookup_code,'NON CUMULATIVE') =
                                          'NON CUMULATIVE')) THEN
                po_lines_sv2.retroactive_change(X_po_Line_id);
        END IF;

	po_line_locations_sv6.insert_po_line_locations(
                                 X_line_location_id,
                            	 X_last_update_date,
                            	 X_last_updated_by,
                            	 X_current_po_header_id,
                            	 X_po_line_id,
                            	 X_last_update_login,
                            	 X_creation_date,
                            	 X_created_by,
                           	 X_quantity,
                           	 NULL, /* quantity_received  */
                            	 NULL, /* quantity_accepted */
                             	 NULL, /* quantity_rejected */
                            	 NULL, /* quantity_billed */
                            	 NULL, /* quantity_cancelled */
                             	 X_unit_of_measure,
				 X_po_release_id,
                            	 X_ship_to_location_id,
                            	 X_freight_carrier,
                            	 X_need_by_date,
                            	 X_promised_date,
                            	 NULL, /* last_accept_date */
                            	 X_unit_price, /* price_override */
                            	 NULL, /* X_encumbered_flag*/
				 NULL, /*encumbered_date*/
                            	 X_fob,
                            	 X_freight_terms,
                            	 X_taxable_flag,
                            	 to_number(null),  -- tax_id
				 X_from_header_id,
				 X_from_line_id,
                             	 X_from_line_location_id,
                            	 X_effective_date,
                            	 X_expiration_date,
                            	 X_lead_time,
                            	 X_lead_time_unit,
                            	 X_price_discount,
                            	 X_terms_id,
                             	 X_approved_flag,
                             	 NULL, /* closed_flag */
                            	 NULL, /* cancel_flag*/
                            	 NULL, /*cancelled_by*/
                            	 NULL, /*cancel_date*/
                            	 NULL, /* cancel_reason */
                             	 NULL, /* firm_status_lookup_code*/
                            	 X_shipment_attribute_category,
                            	 X_shipment_attribute1,
                             	 X_shipment_attribute2,
                            	 X_shipment_attribute3,
                            	 X_shipment_attribute4,
                             	 X_shipment_attribute5,
                             	 X_shipment_attribute6,
                             	 X_shipment_attribute7,
                            	 X_shipment_attribute8,
                            	 X_shipment_attribute9,
                             	 X_shipment_attribute10,
                            	 X_shipment_attribute11,
                            	 X_shipment_attribute12,
                             	 X_shipment_attribute13,
                             	 X_shipment_attribute14,
                            	 X_shipment_attribute15,
                            	 X_inspection_required_flag,
                             	 X_receipt_required_flag,
                            	 X_qty_rcv_tolerance,
                            	 X_qty_rcv_exception_code,
                             	 X_enforce_ship_to_loc_code,
                             	 X_allow_sub_receipts_flag,
                            	 X_days_early_receipt_allowed,
                             	 X_days_late_receipt_allowed,
                            	 X_receipt_days_exception_code,
                            	 X_invoice_close_tolerance,
                            	 X_receive_close_tolerance,
                             	 X_ship_to_organization_id,
                            	 X_shipment_num,
                             	 X_source_shipment_id,
                            	 X_shipment_type,
                            	 X_closed_code,
                            	 X_request_id,
                            	 X_program_application_id,
                            	 X_program_id,
				 X_program_update_date,
                            	 NULL,  -- <R12 SLA replaced by null>
                            	 X_government_context,
                             	 X_receiving_routing_id,
				 X_accrue_on_receipt_flag,
                            	 X_closed_reason,
                            	 X_closed_date,
				 X_closed_by,
                             	 X_organization_id,
                                 l_transaction_flow_header_id,  --< Shared Proc FPJ >
                                 --<SERVICES FPJ START>
                                 p_amount,
                                 p_order_type_lookup_code,
                                 p_purchase_basis,
                                 --<SERVICES FPJ END>
                                 NULL,  --< Shared Proc FPJ > explicit NULL was missing
			         --togeorge 09/28/2000
			         --added  note to receiver
				 X_note_to_receiver
				 );

 END IF;

 --<SERVICES FPJ START>
 --Add new price differential records to an existing price break

 IF ((X_create_po_line_loc_flag = 'Y')
    AND (X_header_processable_flag = 'Y')) THEN

    X_progress := '080';
    IF (g_po_pdoi_write_to_file = 'Y') THEN
       PO_DEBUG.put_line('Start insert price differentials '||
                         'for the price break');
    END IF;

    If  (p_order_type_lookup_code = 'RATE') then

          PO_PRICE_DIFFERENTIALS_PVT.validate_price_differentials(
                  p_interface_header_id     => X_interface_header_id,
                  p_interface_line_id       => X_interface_line_id,
                  p_entity_type             => 'PRICE BREAK',
                  p_entity_id               => X_line_location_id,
                  p_header_processable_flag => X_header_processable_flag);

          --create price differential records
          PO_PRICE_DIFFERENTIALS_PVT.create_from_interface(
                  p_interface_line_id       => X_interface_line_id,
                  p_entity_id               => X_line_location_id);

    END IF; --IF (p_order_type_lookup_code = 'RATE')
 END IF; --IF ((X_create_po_line_loc_flag = 'Y')...
 --<SERVICES FPJ END>


 select process_code into l_process_code
 from   po_headers_interface
 where  interface_header_id = X_interface_header_id;

 if NVL(l_process_code, 'UPDATE') = 'NOTIFIED' then

	-- This flag should not be set to 'Y' when processing notified rows.
	X_price_tolerance_flag := 'N';
 end if;

EXCEPTION
 WHEN others THEN
         po_message_s.sql_error('update_po_line', X_progress, sqlcode);
         raise;

END update_po_line;


--
--   PROCEDURE NAME: 	delete_po_line() - ** NOT USED ANY MORE **
--

PROCEDURE delete_po_line(
                        X_interface_header_id	NUMBER,
			X_interface_line_id	NUMBER,
                        X_po_line_id		NUMBER,
                        X_line_location_id	NUMBER,
                        X_shipment_type		VARCHAR2,
			X_document_num		VARCHAR2,
			X_po_header_id		NUMBER,
			X_item			NUMBER,
 			X_item_id		NUMBER,
 			X_item_revision		VARCHAR2,
 			X_category		VARCHAR2,
 			X_category_id		NUMBER,
 			X_item_description	VARCHAR2,
 			X_vendor_product_num	VARCHAR2)
IS
  x_progress            VARCHAR2(100) := NULL;
BEGIN

	-- We can use a soft_cancel_line flag (po_lines table) that when enabled, the line
	-- will not show up in the blanket/quotation or appear when creating releases.
	-- Would also need to modify sourcing, auto-create, ASL etc. and add this column to
	-- the PO_LINES_ALL table and PO_LINES view.

	-- Can use expiration date as well. That is the item would not show up in any of the
	-- above after that expiration date.

	-- Cannot cancel item if open releases.
/*
	update po_lines
	set deleted_item_flag = 'Y'
	    --	set expiration_date = (select sysdate from sys.dual) or X_expiration_date
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id,
            request_id = fnd_global.conc_request_id,
            program_application_id = fnd_global.prog_appl_id,
            program_id = fnd_global.conc_program_id,
            program_update_date = sysdate
	where po_header_id = X_po_header_id
	and   po_line_id   = X_po_line_id;
*/

	NULL;

EXCEPTION
 WHEN others THEN
         po_message_s.sql_error('delete_po_line', X_progress, sqlcode);
         raise;

END delete_po_line;

--
--  PROCEDURE NAME : item_exists
--

PROCEDURE item_exists ( X_ItemType 	IN  VARCHAR2,
                        X_ItemKey  	IN  VARCHAR2,
			X_Item_exist 	OUT NOCOPY VARCHAR2,
                        X_Item_end_date OUT NOCOPY DATE)
IS
  l_progress            VARCHAR2(300) := NULL;

BEGIN

   l_progress := 'PO_LINES_SV4_832_UPDATE.Item_Exists: 01';
   -- /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(X_itemtype,X_itemkey,l_progress);

   -- initialize the return variables
   X_item_exist := NULL;
   X_item_end_date := NULL;

	SELECT		'Y', WI.end_date
	  INTO	        X_item_exist, X_item_end_date
          FROM		WF_ITEMS_V WI
	 WHERE		WI.ITEM_TYPE = X_ItemType
           AND          WI.ITEM_KEY  = X_ItemKey;


    l_progress := 'PO_LINES_SV4_832_UPDATE.Item_Exists: 900 ';
    -- /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(X_itemtype,X_itemkey,l_progress);

 EXCEPTION
  WHEN NO_DATA_FOUND THEN

	-- item key does not exist
	X_item_exist := 'N';
        X_item_end_date := NULL;

  WHEN OTHERS THEN

     wf_core.context ('PO_LINES_SV4_832_UPDATE','Item_exists','SQL error ' || sqlcode);
     l_progress := 'PO_LINES_SV4_832_UPDATE.Item_Exists: 990 - ' ||
 		           'EXCEPTION - sql error: ' || sqlcode;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(X_itemtype,X_itemkey,l_progress);
     END IF;

     RAISE;

END item_exists;


--
--   PROCEDURE NAME: 	Start_Pricat_WF()
--

PROCEDURE Start_Pricat_WF ( X_ItemType      	  IN  VARCHAR2,
                            X_ItemKey       	  IN  VARCHAR2,
			    X_interface_header_id IN  NUMBER,
			    X_po_header_id        IN  NUMBER,
			    X_batch_id		  IN  NUMBER,
			    X_document_type_code  IN  VARCHAR2,
			    X_document_sub_type   IN  VARCHAR2,
			    X_commit_interval	  IN  NUMBER,
			    X_any_item_udpated    IN  VARCHAR2,
			    X_buyer_id		  IN  NUMBER )
IS
	l_orig_system        VARCHAR2(5);
	l_agent_username     VARCHAR2(240);
	l_agent_display_name VARCHAR2(240);
	l_progress	     VARCHAR2(240);
	x_agent_id 	     NUMBER;
	X_supplier_id 	     NUMBER;
--
-- For bug 2834902. Current field size change from 80 -> 240
     x_vendor_name         PO_VENDORS.vendor_name%TYPE;
--
	l_open_form	     VARCHAR2(240);
	l_number_of_items    NUMBER;
	l_document_num	     VARCHAR2(20);
Begin

	IF (g_po_pdoi_write_to_file = 'Y') THEN
   	PO_DEBUG.put_line ('Start Notifications Workflow');
	END IF;

	begin
		select count(*) into l_number_of_items
		from   po_lines_interface
		where  interface_header_id = X_interface_header_id
		and    process_code = 'NOTIFIED'
		and    nvl(price_break_flag,'N') = 'N';

		IF (g_po_pdoi_write_to_file = 'Y') THEN
   		PO_DEBUG.put_line('number of line items failing tolerance :' || to_char(l_number_of_items));
		END IF;
	exception
		when others then
		l_number_of_items := NULL;
	end;


	begin
		select segment1 into l_document_num
		from po_headers
		where po_header_id = X_po_header_id;

	exception
		when others then
		NULL;
	end;

	wf_engine.createProcess     ( ItemType  => X_ItemType,
                                      ItemKey   => X_ItemKey,
				      Process   => 'PROCESS_LINE_ITEMS');

        wf_engine.SetItemAttrNumber ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'INTERFACE_HEADER_ID',
                                      avalue    => X_interface_header_id );

        wf_engine.SetItemAttrNumber ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'DOCUMENT_ID',
                                      avalue    => X_po_header_id );

	wf_engine.SetItemAttrText   ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'DOCUMENT_NUM',
                                      avalue    => l_document_num);

        wf_engine.SetItemAttrNumber ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'BATCH_ID',
                                      avalue    => X_batch_id );

	wf_engine.SetItemAttrText   ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'DOCUMENT_TYPE_CODE',
                                      avalue    => X_document_type_code);

	wf_engine.SetItemAttrText   ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'DOCUMENT_SUBTYPE',
                                      avalue    => X_document_sub_type);

        wf_engine.SetItemAttrNumber ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'COMMIT_INTERVAL',
                                      avalue    => X_commit_interval );

        wf_engine.SetItemAttrNumber ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'NUMBER_OF_ITEMS',
                                      avalue    => l_number_of_items );

	wf_engine.SetItemAttrText   ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'ANY_LINE_ITEM_UPDATED',
                                      avalue    => X_any_item_udpated);

        wf_engine.SetItemAttrNumber ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'BUYER_ID',
                                      avalue    => X_buyer_id );

	select agent_id, vendor_id into x_agent_id, X_supplier_id
	from po_headers
	where po_header_id = X_po_header_id;

  	l_orig_system:= 'PER';

  	WF_DIRECTORY.GetUserName( l_orig_system,
                           	  x_agent_id,
                           	  l_agent_username,
                           	  l_agent_display_name );

        wf_engine.SetItemAttrText   ( itemtype  => X_itemtype,
                                      itemkey   => X_itemkey,
                                      aname     => 'BUYER_USER_NAME',
                                      avalue    => l_agent_username );

        wf_engine.SetItemAttrText   ( itemtype  => X_itemtype,
                                      itemkey   => X_itemkey,
                                      aname     => 'BUYER_DISPLAY_NAME',
                                      avalue    => l_agent_display_name );

    	l_open_form := 'PO_POXPCATN:INTERFACE_HEADER_ID="' || '&' || 'INTERFACE_HEADER_ID"' ||
                    		    ' ACCESS_LEVEL_CODE="' || '&' || 'ACCESS_LEVEL_CODE"';

     	wf_engine.SetItemAttrText ( itemtype   => X_itemType,
                              	    itemkey    => X_itemkey,
                              	    aname      => 'OPEN_FORM_COMMAND' ,
                              	    avalue     => l_open_form );

	-- Need to set Supplier attributes as well
	-- using X_supplier_id

	begin
		select vendor_name into x_vendor_name
		from po_vendors
		where vendor_id = x_supplier_id ;
	exception
		when others then
		null;
	end;

        wf_engine.SetItemAttrNumber ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'SUPPLIER_ID',
                                      avalue    => x_supplier_id );

	wf_engine.SetItemAttrText   ( itemtype  => X_ItemType,
                                      itemkey   => X_itemkey,
                                      aname     => 'SUPPLIER',
                                      avalue    => x_vendor_name );

	-- setting workflow owner

  	wf_engine.SetItemOwner ( itemtype => X_ItemType,
                           	 itemkey  => X_itemkey,
                           	 owner    => l_agent_username );

	IF (g_po_pdoi_write_to_file = 'Y') THEN
   	PO_DEBUG.put_line ('Done setting workflow attributes');
	END IF;

	-- Start Workflow

	wf_engine.startprocess ( itemtype => X_ItemType,
				 itemkey  => X_itemkey );

	IF (g_po_pdoi_write_to_file = 'Y') THEN
   	PO_DEBUG.put_line ('Workflow started');
	END IF;

EXCEPTION
WHEN OTHERS THEN

     wf_core.context ('PO_LINES_SV4_832_UPDATE','Start_Pricat_WF','SQL error ' || sqlcode);
     l_progress := 'PO_LINES_SV4_832_UPDATE.Start_Pricat_WF: 990 - ' || 'EXCEPTION - sql error: ' || sqlcode;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(X_itemtype,X_itemkey,l_progress);
     END IF;

     RAISE;

end Start_Pricat_WF;


/*===========================================================================*/
/*============================ BODY (PRIVATE) ===============================*/
/*===========================================================================*/

FUNCTION price_tolerance_check ( p_interface_header_id NUMBER,
				 p_interface_line_id NUMBER,
				 p_item_id NUMBER,
				 p_category_id NUMBER,
				 p_vendor_id NUMBER,
				 p_vendor_site_id NUMBER,
				 p_document_id NUMBER,
				 p_po_line_id  NUMBER,
				 p_unit_price NUMBER,
				 p_def_master_org_id NUMBER)  -- X_org_id
RETURN Boolean
IS
	l_original_price 	 NUMBER;
	l_price_update_tolerance NUMBER;
	l_progress	     	 VARCHAR2(240);
	l_asl_id		 NUMBER;
	l_vendor_product_num	 VARCHAR2(25);
	l_purchasing_uom	 VARCHAR2(25);
	l_process_code		 VARCHAR2(25);
	l_acceptance_flag	 VARCHAR2(1);

	cursor C1 is
		SELECT   price_update_tolerance
		FROM     po_asl_attributes
		WHERE    (item_id = p_item_id or
          	category_id = p_category_id or
          	category_id in (SELECT MIC.category_id
                           	FROM   MTL_ITEM_CATEGORIES MIC
                           	WHERE MIC.inventory_item_id = p_item_id
                           	AND MIC.organization_id = p_def_master_org_id))
		AND
         	vendor_id = p_vendor_id
		AND
         	( NVL(vendor_site_id, 1) = NVL(p_vendor_site_id, 1)
		  OR
		  vendor_site_id is NULL or p_vendor_site_id is NULL )
		AND
         	using_organization_id IN (-1, p_def_master_org_id)
		ORDER BY  item_id ASC, using_organization_id DESC;

	x_asl_rows	C1%ROWTYPE;

begin
	IF (g_po_pdoi_write_to_file = 'Y') THEN
   	PO_DEBUG.put_line ('$ Checking price tolerance');
	END IF;

	select process_code into l_process_code
	from   po_headers_interface
	where  interface_header_id = p_interface_header_id;

	select price_chg_accept_flag into l_acceptance_flag
	from   po_lines_interface
	where  interface_header_id = p_interface_header_id
	and    interface_line_id   = p_interface_line_id;

	IF (g_po_pdoi_write_to_file = 'Y') THEN
   	PO_DEBUG.put_line ('p_vendor_id:' || to_char(p_vendor_id));
   	PO_DEBUG.put_line ('p_category_id:' || to_char(p_category_id));
   	PO_DEBUG.put_line ('p_def_master_org_id' || to_char(p_def_master_org_id));
   	PO_DEBUG.put_line ('l_process_code:' || l_process_code);
   	PO_DEBUG.put_line ('l_acceptance_flag:' || l_acceptance_flag);
	END IF;

	if NVL(l_process_code, 'UPDATE') = 'NOTIFIED' and NVL(l_acceptance_flag, 'N') = 'Y' then
		return TRUE;
	end if;

	--
	-- Try to get the price tolerance percentage in following sequence
	-- from the
	--	1. item supplier (ASL)
	--	2. commodity (category) supplier (ASL)
	--	3. original document (Blanket Only)
	--	4. system level profile

	-- item supplier or commodity supplier
	-- get it from item-supplier, if not found then get it from category-supplier.

	begin

		Open C1;
			fetch C1 into x_asl_rows;
			l_price_update_tolerance := x_asl_rows.price_update_tolerance;
		Close C1;

		IF (g_po_pdoi_write_to_file = 'Y') THEN
   		PO_DEBUG.put_line ('ASL tolerance' || to_char(l_price_update_tolerance));
		END IF;

	exception
		when others then
		null;
		IF (g_po_pdoi_write_to_file = 'Y') THEN
   		PO_DEBUG.put_line ('ASL tolerance - exception');
		END IF;
	end;

	if l_price_update_tolerance is null then

		begin
			-- original document (blanket)

			select price_update_tolerance into l_price_update_tolerance
			from po_headers
			where po_header_id = p_document_id
			and type_lookup_code = 'BLANKET';

		exception
			when others then
			null;
		end;
	end if;

	if l_price_update_tolerance is null then

		-- system profile

		fnd_profile.get('PO_PRICE_UPDATE_TOLERANCE',l_price_update_tolerance);

	end if;

	if l_price_update_tolerance is null then

		-- no price tolerance specified.

		return TRUE;
	else

		IF (g_po_pdoi_write_to_file = 'Y') THEN
   		PO_DEBUG.put_line('Price_update_tolerance_percent specified:' || to_char(l_price_update_tolerance));
		END IF;

		-- need to save the tolerance value at the line level as we would have to display it in the PRICAT form

		update po_lines_interface
		set price_update_tolerance = l_price_update_tolerance
		where interface_header_id  = p_interface_header_id
		and   interface_line_id	   = p_interface_line_id;

		select unit_price into l_original_price
		from po_lines
		where po_header_id = p_document_id
		and   po_line_id   = p_po_line_id;

		If (((1 + (l_price_update_tolerance/100)) * l_original_price) >= p_unit_price) then
			IF (g_po_pdoi_write_to_file = 'Y') THEN
   			PO_DEBUG.put_line('Price_update_tolerance_percent exceeded');
			END IF;
			return TRUE;
		else
			IF (g_po_pdoi_write_to_file = 'Y') THEN
   			PO_DEBUG.put_line('Price_update_tolerance_percent NOT exceeded');
			END IF;
			return FALSE;
		end if;
	end if;

EXCEPTION
WHEN OTHERS THEN
         po_message_s.sql_error('price_tolerance_check', l_progress, sqlcode);
         raise;

end price_tolerance_check;


PROCEDURE delete_price_breaks (x_po_header_id NUMBER, x_po_line_id NUMBER)
IS

	Cursor    C_line_locations  Is
	   SELECT line_location_id
	   FROM   po_line_locations
	   WHERE  po_line_id = x_po_line_id
	   AND    po_header_id = x_po_header_id;

	x_line_location_id 	NUMBER;
	rows_processed_counter 	NUMBER := 0;
	new_revision_num	NUMBER;

BEGIN

   IF (g_po_pdoi_write_to_file = 'Y') THEN
      PO_DEBUG.put_line ('Deleting price breaks on original catalog/blanket');
      PO_DEBUG.put_line ('x_po_header_id:' || to_char(x_po_header_id));
      PO_DEBUG.put_line ('x_po_line_id:' || to_char(x_po_line_id));
   END IF;

   -- delete all price breaks for this line.
-- Bug: 1588445 While deleting price breaks take into consideration shipment
--      type QUOTATION also. Otherwise for shipment type quotation it does not
--      delete the old price breaks.

   DELETE FROM PO_LINE_LOCATIONS
   WHERE PO_LINE_ID = X_po_line_id
   AND   PO_HEADER_ID = X_po_header_id
   AND   SHIPMENT_TYPE in ('PRICE BREAK','QUOTATION');

END;


/*=============================================================================

    PROCEDURE:      update_price_discount                   <2703076>

    DESCRIPTION:    Updates the price_discount field for all Price Breaks
                    of the given po_line_id with respect to the unit_price.

=============================================================================*/
PROCEDURE update_price_discount
(
    p_po_line_id               IN       PO_LINE_LOCATIONS.po_line_id%TYPE,
    p_unit_price               IN       PO_LINES.unit_price%TYPE
)
IS BEGIN

    UPDATE PO_LINE_LOCATIONS
    SET    price_discount = round(((p_unit_price - price_override)/p_unit_price * 100), 2)
    WHERE  po_line_id = p_po_line_id;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('update_price_discount','000',sqlcode);
        RAISE;

END update_price_discount;


END PO_LINES_SV4_832_UPDATE;

/
