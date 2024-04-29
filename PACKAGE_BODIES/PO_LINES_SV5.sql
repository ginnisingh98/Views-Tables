--------------------------------------------------------
--  DDL for Package Body PO_LINES_SV5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_SV5" as
/* $Header: POXPOL5B.pls 120.1.12010000.3 2014/07/17 10:36:19 yuandli ship $ */

/*=============================  PO_LINES_SV  ===============================*/


/*===========================================================================

  PROCEDURE NAME:	po_lines_post_query()

===========================================================================*/

  g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
  g_pkg_name    CONSTANT VARCHAR2(30) := 'PO_LINES_SV5';
  g_log_head    CONSTANT VARCHAR2(30) := 'po.plsql.PO_LINES_SV5.';


  procedure po_lines_post_query (    X_po_Line_id IN number,
                                  X_from_header_id IN number,
                                  X_from_line_id IN number,
                                  X_line_type_id IN number,
                                  X_item_id IN number,
                                  X_inventory_org_id IN number,
                                  X_expense_accrual_code IN varchar2,
                                  X_po_header_id IN number,
                                  X_type_lookup_code IN varchar2,
                                  X_receipt_required_flag IN OUT NOCOPY varchar2,
                                  X_quantity_received IN OUT NOCOPY number,
                                  X_quantity_billed IN OUT NOCOPY number,
                                  X_encumbered_flag IN OUT NOCOPY varchar2,
                                  X_prevent_price_update_flag IN OUT NOCOPY varchar2,
                                  X_online_req_flag IN OUT NOCOPY varchar2,
                                  X_quantity_released IN OUT NOCOPY number,
                                  X_amount_released IN OUT NOCOPY number,
                                  X_quotation_number IN OUT NOCOPY varchar2,
                                  X_quotation_line IN OUT NOCOPY number,
                                  X_quotation_type IN OUT NOCOPY varchar2,
                                  X_vendor_quotation_number IN OUT NOCOPY varchar2,
                                  X_num_of_ship IN OUT NOCOPY number,
                                  --< NBD TZ/Timestamp FPJ Start >
                                  --X_promised_date IN OUT NOCOPY varchar2,
                                  --X_need_by IN OUT NOCOPY varchar2,
                                  X_promised_date IN OUT NOCOPY DATE,
                                  X_need_by IN OUT NOCOPY DATE,
                                  --< NBD TZ/Timestamp FPJ End >
                                  X_num_of_dist IN OUT NOCOPY number,
                                  X_code_combination_id IN OUT NOCOPY number,
                                  X_line_total IN OUT NOCOPY number,
                                  X_ship_total IN OUT NOCOPY number,
                                  X_ship_total_rtot_db IN OUT NOCOPY number,
				  --togeorge 10/03/2000
				  --added oke variables
				  X_oke_contract_header_id IN number,
				  X_oke_contract_num IN OUT NOCOPY varchar2
                                  )  is

   X_Progress          varchar2(3)  := NULL;
/* 1063532 - FRKHAN: New param. added to get_quotation_info proc. */

  x_quote_terms_id number := null;
  x_quote_ship_via_lookup_code varchar2(25) := null;
  x_quote_fob_lookup_code      varchar2(25) := null;
  x_quote_freight_terms  varchar2(25) := null;

   begin
           X_Progress := '010';
          /* Call the get_total api for the Lines */

          X_line_total := po_core_s.get_total('L',
                                              X_po_line_id,
                                              FALSE);

          X_Progress := '020';
         /* Maintain the Total for Shipment Quantity for this Line */

         po_lines_pkg_scu.select_ship_total( X_po_line_id,
                                             X_ship_total,
                                             X_ship_total_rtot_db);

         X_Progress := '030';
        /* Figure out how many shipments and distributions exist */
        po_lines_sv4.get_ship_dist_num(X_po_line_id,
                                       X_num_of_ship,
                                       X_promised_date,
                                       X_need_by,
                                       X_num_of_dist,
                                       X_code_combination_id);

         X_Progress := '040';
         /* Populate the receipt Required Flag first from po_line_types and then,
         ** IF it is Not a one-time item from the mtl_system_item
         */
         X_receipt_required_flag := po_lines_sv4.get_receipt_required_flag (X_line_type_id,
                                                                            X_item_id,
                                                                            X_inventory_org_id);

         X_Progress := '050';
         po_lines_sv4.get_ship_quantity_info (X_po_line_id,
                                             X_expense_accrual_code,
                                             X_po_header_id,
                                             X_type_lookup_code,
                                             X_quantity_received,
                                             X_quantity_billed,
                                             X_encumbered_flag,
                                             X_prevent_price_update_flag,
                                             X_online_req_flag,
                                             X_quantity_released,
                                             X_amount_released  );
         X_Progress := '060';
	 --FRKHAN 07/31/98. Bug 706970. Removed clause 'X_item_id is not null'
	 --so that quotation info is copied even if you don't have an item id
         if  X_from_header_id is not null THEN
             po_lines_sv4.get_quotation_info (X_from_header_id,
                                            X_from_line_id,
                                            X_quotation_number,
                                            X_quotation_line,
                                            X_quotation_type,
                                            X_vendor_quotation_number,
                       			    x_quote_terms_id,
                   		            x_quote_ship_via_lookup_code,
                           		    x_quote_fob_lookup_code,
                   			    x_quote_freight_terms);
         end if;

	     --togeorge 10/03/2000
	     --added a call to get the oke header info
	     if X_oke_contract_header_id is not null then
	        po_lines_sv4.get_oke_contract_header_info(
					X_oke_contract_header_id,
	     				X_oke_contract_num);
	     end if;

  exception
        when others then
             po_message_s.sql_error('po_lines_post_query', x_progress, sqlcode);
             raise;
  end po_lines_post_query;

/* Bug 4188362 : this function is called from when-new-item-instance from
 * Unit_price field to check whether price is updateable or not */

    FUNCTION price_update_allowed(p_po_line_id NUMBER)
    return BOOLEAN IS
    x_quantity_billed   NUMBER;
    x_quantity_received NUMBER;
    x_accrual_option    VARCHAR2(1);
    x_encumbered_flag   VARCHAR2(1);
	x_retroactive_value VARCHAR2(20) := 'NEVER';
	x_destination_code	VARCHAR2(20);
	l_retro_prj_allowed VARCHAR2(1) := 'N';
	l_archive_mode_po	PO_DOCUMENT_TYPES.archive_external_revision_code%TYPE;

	l_progress VARCHAR2(3) := '000';
	l_api_name VARCHAR2(30) := 'PRICE_UPDATE_ALLOWED';

      --<Bug 18372756>:
      l_calling_sequence VARCHAR2(100) := 'PO_AP_DEBIT_MEMO_UNVALIDATED';
      l_unvalidated_debit_memo NUMBER;
      --<End bug 18372756>
    Begin
		l_progress := '010';
		IF g_debug_stmt THEN
			PO_DEBUG.debug_begin(p_log_head => g_log_head||l_api_name);
		END IF;

		/* Get Retrocative Profile Value */
		l_progress := '020';
		x_retroactive_value := PO_RETROACTIVE_PRICING_PVT.Get_Retro_Mode;

		IF g_debug_stmt THEN
			PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
								p_token    => l_progress,
								p_message  => 'Retroactive Value ::'|| x_retroactive_value);
		END IF;

		/* Get if PO has Project Information */
		l_progress := '030';
		l_retro_prj_allowed := PO_RETROACTIVE_PRICING_PVT.Is_Retro_Project_Allowed(
												p_std_po_price_change => 'Y',
												p_po_line_id          => p_po_line_id,
												p_po_line_loc_id      => NULL);

		IF g_debug_stmt THEN
			PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
								p_token    => l_progress,
								p_message  => 'l_retro_prj_allowed Value ::'|| l_retro_prj_allowed);
		END IF;

		/* Get Archival Mode */
		l_archive_mode_po   := PO_DOCUMENT_ARCHIVE_PVT.get_archive_mode(
                                                    p_doc_type    => 'PO',
                                                    p_doc_subtype => 'STANDARD');
		IF g_debug_stmt THEN
			PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
								p_token    => l_progress,
								p_message  => 'l_archive_mode_po Value ::'|| l_archive_mode_po);
		END IF;

		/* Getting destination type for First distribution of the Shipment */
		l_progress := '040';

		x_destination_code:='INVENTORY'; --Setting destination_code to Inventory

		BEGIN

			--Checking if there is any destination_code = EXPENSE
			SELECT 'EXPENSE'
			INTO x_destination_code
			FROM DUAL
			WHERE EXISTS (
			  select destination_type_code
			  from po_distributions_all
			  where po_line_id = p_po_line_id
				and destination_type_code IN ('EXPENSE')
			);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_destination_code:='INVENTORY';
		END;

		IF g_debug_stmt THEN
			PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
								p_token    => l_progress,
								p_message  => 'x_destination_code Value ::'|| x_destination_code);
		END IF;


		/* Considering Sum of all Shipments of the Line */
		l_progress := '050';
       select sum(quantity_received),
              sum(quantity_billed),
              max(nvl(accrue_on_receipt_flag,'N')),
              max(nvl(encumbered_flag,'N'))
         into x_quantity_received,
              x_quantity_billed,
              x_accrual_option,
              x_encumbered_flag
         from po_line_locations
        where po_line_id = p_po_line_id;

		IF g_debug_stmt THEN
			PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
								p_token    => l_progress,
								p_message  => 'x_quantity_received Value ::'|| x_quantity_received);
			PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
								p_token    => l_progress,
								p_message  => 'x_quantity_billed Value ::'|| x_quantity_billed);
			PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
								p_token    => l_progress,
								p_message  => 'x_accrual_option Value ::'|| x_accrual_option);
			PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
								p_token    => l_progress,
								p_message  => 'x_encumbered_flag Value ::'|| x_encumbered_flag);
		END IF;

		l_progress := '060';
		if	( x_encumbered_flag = 'Y' OR --Encumbrance not supported
				(
					--If Received/Billed
					( nvl(x_quantity_received,0) > 0 OR nvl(x_quantity_billed,0) > 0 ) AND

					--Checking Destination Type
					( x_destination_code IN ('INVENTORY','SHOP FLOOR') OR
						( x_destination_code='EXPENSE' AND ( x_accrual_option = 'RECEIPT' OR x_quantity_billed > 0 ) )
					) AND

					-- Checking Retroactive Profile Value
					(  x_retroactive_value <> 'ALL_RELEASES' OR
						( x_retroactive_value = 'ALL_RELEASES' AND l_archive_mode_po <> 'APPROVE' ) OR
						( x_retroactive_value = 'ALL_RELEASES' AND l_retro_prj_allowed = 'N' )
					)
				)
			)
		 then

			l_progress := '070';
			IF g_debug_stmt THEN
			PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
								p_token    => l_progress,
								p_message  => 'Returning::FALSE');
			END IF;

			return (FALSE); /* Price Update NOT Allowed */

        else
    --<Bug 18372756>:
    ----------------------------------------------------------------------------
    l_progress := '079';
    -- SQL What: Returns 1 if there are any unvalidated debit memo
    --           for the shipments of this line, 0 otherwise.
    -- SQL Why:  To prevent price changes if there are unvalidated debit memo.
    SELECT count(*)
    INTO l_unvalidated_debit_memo
    FROM dual
    WHERE EXISTS
      ( SELECT 1
        FROM  PO_HEADERS_ALL POH,
                po_lines_all POL,
                po_releases_all por,
                po_line_locations_all poll
          WHERE POL.po_line_id = p_po_line_id
        AND POH.po_header_id = POL.po_header_id
        AND por.po_header_id(+) = poh.po_header_id
        AND poll.po_line_id = pol.po_line_id
        AND (poll.quantity_billed = 0 or poll.quantity_billed is null)
        AND PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, por.po_release_id, pol.po_line_id, poll.line_location_id, NULL, NULL, l_calling_sequence) = 1
        );
    IF (l_unvalidated_debit_memo > 0) THEN
       RETURN (FALSE);
    END IF;
    --<End bug 18372756>
			l_progress := '080';
			IF g_debug_stmt THEN
				PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
									p_token    => l_progress,
									p_message  => 'Returning::TRUE');
			END IF;

			return (TRUE); /* Price Update Allowed */

        end if;

		IF g_debug_stmt THEN
			PO_DEBUG.debug_end(p_log_head => g_log_head||l_api_name);
		END IF;

    Exception
     When NO_DATA_FOUND then
        return (FALSE); /* Price Update NOT Allowed */
     WHEN others then
        raise;
     end;

END PO_LINES_SV5;

/
