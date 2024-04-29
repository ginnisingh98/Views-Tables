--------------------------------------------------------
--  DDL for Package Body RCV_TRANSACTION_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRANSACTION_PROCESSOR" AS
/* $Header: RCVGTPB.pls 120.10.12010000.7 2010/10/05 11:51:17 sadibhat ship $ */

	TYPE FlagTabByVC IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(256);

	g_accounting_info DBMS_SQL.number_table;
	g_installed_products FlagTabByVC;
	g_conc_request_id NUMBER := -1;
	g_conc_login_id NUMBER := -1;
	g_conc_program_id NUMBER := -1;
	g_prog_appl_id NUMBER := -1;
	g_user_id NUMBER := -1;

	FUNCTION conc_request_id
		RETURN NUMBER IS
	BEGIN
		IF g_conc_request_id = -1 THEN
			g_conc_request_id := FND_GLOBAL.conc_request_id;
		END IF;

		RETURN g_conc_request_id;
	END conc_request_id;

	FUNCTION conc_login_id
		RETURN NUMBER IS
	BEGIN
		IF g_conc_login_id = -1 THEN
			g_conc_login_id := FND_GLOBAL.conc_login_id;
		END IF;

		RETURN g_conc_login_id;
	END conc_login_id;

	FUNCTION conc_program_id
		RETURN NUMBER IS
	BEGIN
		IF g_conc_program_id = -1 THEN
			g_conc_program_id := FND_GLOBAL.conc_program_id;
		END IF;

		RETURN g_conc_program_id;
	END conc_program_id;

	FUNCTION prog_appl_id
		RETURN NUMBER IS
	BEGIN
		IF g_prog_appl_id = -1 THEN
			g_prog_appl_id := FND_GLOBAL.prog_appl_id;
		END IF;

		RETURN g_prog_appl_id;
	END prog_appl_id;

	FUNCTION user_id
		RETURN NUMBER IS
	BEGIN
		IF g_user_id = -1 THEN
			g_user_id := FND_GLOBAL.user_id;
		END IF;

		RETURN g_user_id;
	END user_id;

	FUNCTION get_product_install_status( p_product_name IN VARCHAR2 )
		RETURN VARCHAR2 IS
	BEGIN
		IF NOT g_installed_products.EXISTS(p_product_name) THEN
			g_installed_products(p_product_name) := PO_CORE_S.get_product_install_status( p_product_name );
		END IF;

		RETURN g_installed_products(p_product_name);
	END get_product_install_status;

	FUNCTION Valid_Accounting_Info( p_org_id NUMBER )
		RETURN BOOLEAN IS
	BEGIN
		IF NOT g_accounting_info.EXISTS(p_org_id) THEN
			SELECT COUNT(*)
			  INTO g_accounting_info(p_org_id)
			  FROM hr_organization_information hoi
			     , gl_sets_of_books gsob
			     , financials_system_params_all fsp
             WHERE hoi.organization_id = p_org_id
			   AND hoi.org_information_context||'' = 'Accounting Information'
			   AND (fsp.org_id IS NULL OR hoi.org_information3 = TO_CHAR(fsp.org_id))
			   AND fsp.set_of_books_id = gsob.set_of_books_id;
		END IF;

		RETURN g_accounting_info(p_org_id) > 0;
	END Valid_Accounting_Info;

	/*Bug 5517298: Added the function get_acct_period_status*/
	FUNCTION get_acct_period_status(p_trx_date IN DATE,
                              p_org_id   IN NUMBER) RETURN VARCHAR2 IS

	l_closing_status  VARCHAR2(1) := NULL;
	l_open_flag       VARCHAR2(1) := NULL;
        l_progress        VARCHAR2(3) := NULL;


	BEGIN

          l_progress := '010';

	  SELECT oap.open_flag
	  INTO   l_open_flag
	  FROM   org_acct_periods oap
	  WHERE  oap.organization_id = p_org_id
	  AND   (trunc(p_trx_date)
		BETWEEN trunc(oap.period_start_date) AND
		trunc (oap.schedule_close_date));

	  if (l_open_flag = 'Y') then
	    l_closing_status := 'O';
	  elsif (l_open_flag = 'N') then
    	    l_closing_status := 'N';
	  else
    	    l_closing_status := 'F';
	  end if;

	  RETURN l_closing_status;

	EXCEPTION
	WHEN NO_DATA_FOUND then
	    po_message_s.app_error('PO_INV_NO_OPEN_PERIOD');
	    RAISE;
	WHEN TOO_MANY_ROWS then
	    po_message_s.app_error('PO_INV_MUL_PERIODS');
	    RAISE;
	WHEN OTHERS THEN
            po_message_s.sql_error('get_acct_period_status', l_progress, sqlcode);
	    RAISE;
	END get_acct_period_status;

	PROCEDURE RVTTHIns
		( p_rti_id IN RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE
		, p_transaction_type IN RCV_TRANSACTIONS.transaction_type%TYPE
		, p_shipment_header_id IN RCV_SHIPMENT_HEADERS.shipment_header_id%TYPE
		, p_shipment_line_id IN RCV_SHIPMENT_LINES.shipment_line_id%TYPE
		, p_primary_unit_of_measure IN RCV_TRANSACTIONS.primary_unit_of_measure%TYPE
		, p_primary_quantity IN RCV_TRANSACTIONS.primary_quantity%TYPE
		, p_source_doc_unit_of_measure IN RCV_TRANSACTIONS.source_doc_unit_of_measure%TYPE
		, p_source_doc_quantity IN RCV_TRANSACTIONS.source_doc_quantity%TYPE
		, p_parent_id IN RCV_TRANSACTIONS.transaction_id%TYPE
		, p_receive_id IN OUT NOCOPY RCV_TRANSACTIONS.transaction_id%TYPE
		, p_deliver_id IN OUT NOCOPY RCV_TRANSACTIONS.transaction_id%TYPE
		, p_correct_id IN OUT NOCOPY RCV_TRANSACTIONS.transaction_id%TYPE
		, p_return_id IN OUT NOCOPY RCV_TRANSACTIONS.transaction_id%TYPE
		, x_rt_id OUT NOCOPY RCV_TRANSACTIONS.transaction_id%TYPE
		, x_error_message OUT NOCOPY VARCHAR2
		) IS
			l_rt_row RCV_TRANSACTIONS%ROWTYPE;
			l_parent_row RCV_TRANSACTIONS%ROWTYPE;
			l_rti_row RCV_TRANSACTIONS_INTERFACE%ROWTYPE;

			l_use_ship_to_flag VARCHAR2(1);
			l_common_receiving BOOLEAN;

		-- Bug 9767933
 	        l_archive_ext_rev_code VARCHAR2(100);

	/*Bug 5517289-Start*/
	CURSOR c_fob_point (l_from_org_id NUMBER,l_to_org_id NUMBER)is

	   SELECT fob_point
	   FROM   mtl_interorg_parameters
	   WHERE  from_organization_id = l_from_org_id
	   AND    to_organization_id   = l_to_org_id;

        l_fob_point number;
	/*Bug 5517289-End*/

	BEGIN
	   asn_debug.put_line('RVTTHIns(p_rti_id:' || p_rti_id
				|| ', p_transaction_type: ' || p_transaction_type
				|| ', p_shipment_header_id: ' || p_shipment_header_id
				|| ', p_shipment_line_id: ' || p_shipment_line_id
				|| ', p_primary_unit_of_measure: ' || p_primary_unit_of_measure
				|| ', p_primary_quantity: ' || p_primary_quantity
				|| ', p_source_doc_unit_of_measure: ' || p_source_doc_unit_of_measure
				|| ', p_source_doc_quantity: ' || p_source_doc_quantity
				|| ', p_parent_id: ' || p_parent_id
				|| ', p_receive_id: ' || p_receive_id
				|| ', p_deliver_id: ' || p_deliver_id
				|| ', p_correct_id: ' || p_correct_id
				|| ', p_return_id: ' || p_return_id
				|| ')');

		SELECT rcv_transactions_s.NEXTVAL
		  INTO l_rt_row.transaction_id
		  FROM DUAL;

		-- Bug 4401341
		/*Commenting the rcv_table_functions.get_rti_frow_from_id call and fetching
		  the value from rti table as lpn_id fetched from the cache table does not
		  have the value that is updated by Inventory.There may be other fields that
		  would have got updated.So fetching all the values directly from rti and then
		  use them to populate rcv_transactions table.
		*/
--		l_rti_row := RCV_TABLE_FUNCTIONS.get_rti_row_from_id( p_rti_id );

		select *
		into l_rti_row
		from rcv_transactions_interface
		where interface_transaction_id = p_rti_id;

		-- default values
		l_rt_row.user_entered_flag := 'Y';
		l_use_ship_to_flag := 'N';

		IF p_transaction_type = 'RECEIVE' THEN
			l_rt_row.parent_transaction_id := -1;
			p_receive_id := l_rt_row.transaction_id;
			IF p_transaction_type = 'SHIP' THEN
				l_rt_row.user_entered_flag := 'N';
			END IF;
			IF l_rti_row.auto_transact_code = 'DELIVER' THEN
				l_use_ship_to_flag := 'Y';
			END IF;
		ELSIF p_transaction_type = 'DELIVER' THEN
			p_deliver_id := l_rt_row.transaction_id;
			IF l_rti_row.auto_transact_code = 'DELIVER' THEN
				l_rt_row.user_entered_flag := 'N';
				l_rt_row.parent_transaction_id := p_receive_id;
			END IF;
		ELSIF p_transaction_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER') THEN
			l_parent_row := RCV_TABLE_FUNCTIONS.get_rt_row_from_id( l_rti_row.parent_transaction_id );
			IF l_parent_row.transaction_type = 'DELIVER' THEN
				l_rt_row.parent_transaction_id := l_parent_row.parent_transaction_id;
				l_use_ship_to_flag := 'Y';
			END IF;
			p_return_id := l_rt_row.transaction_id;
		ELSIF p_transaction_type = 'RETURN TO RECEIVING' THEN
			IF l_rti_row.transaction_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER') THEN
				l_rt_row.user_entered_flag := 'N';
			END IF;
			p_correct_id := l_rt_row.transaction_id;
		ELSIF p_transaction_type = 'CORRECT' THEN
			p_correct_id := l_rt_row.transaction_id;
		END IF;

		IF l_rt_row.parent_transaction_id IS NULL THEN
			l_rt_row.parent_transaction_id := p_parent_id;
		END IF;

		IF NOT Valid_Accounting_Info( l_rti_row.to_organization_id ) THEN
			x_error_message := 'RCV_INV_ACCT_INVALID';
			RETURN;
		END IF;

	/*
	 Bug 6359747
	 Changing the Created_by and Last_Updated_by from user_id to whats in RTI record.
	 Commented old lines below and add new ones.
	*/
		l_rt_row.creation_date := SYSDATE;
		--l_rt_row.created_by := user_id;
		l_rt_row.created_by := l_rti_row.created_by;

		l_rt_row.last_update_date := SYSDATE;
		--l_rt_row.last_updated_by := user_id;
		l_rt_row.last_updated_by := l_rti_row.last_updated_by;

                /* Bug# 7343638
                 * If the processing mode is ONLINE, all the below fields were
                 * being set as -1.
                 * Explicitely setting the below fields to 0 in case of ONLINE
                 * as this was the value set earlier.
                 */

                l_rt_row.last_update_login := l_rti_row.last_update_login;

                IF (l_rti_row.processing_mode_code = 'ONLINE') THEN
                  l_rt_row.request_id := 0;
                  l_rt_row.program_application_id := 0;
                  l_rt_row.program_id := 0;
                ELSE
                  l_rt_row.request_id := conc_request_id;
                  l_rt_row.program_application_id := prog_appl_id;
                  l_rt_row.program_id := conc_program_id;
                END IF;
                -- End bug# 7343638

		l_rt_row.program_update_date := SYSDATE;
		l_rt_row.interface_source_code := l_rti_row.interface_source_code;
		l_rt_row.interface_source_line_id := l_rti_row.interface_source_line_id;
		l_rt_row.transaction_type := p_transaction_type;
		l_rt_row.transaction_date := l_rti_row.transaction_date;
		l_rt_row.source_document_code := l_rti_row.source_document_code;
		IF l_use_ship_to_flag = 'Y' THEN
			l_rt_row.destination_type_code := 'RECEIVING';
		ELSE
			l_rt_row.destination_type_code := l_rti_row.destination_type_code;
		END IF;
		l_rt_row.location_id := l_rti_row.location_id;
		l_rt_row.quantity := l_rti_row.quantity;
		l_rt_row.unit_of_measure := l_rti_row.unit_of_measure;
		l_rt_row.uom_code := l_rti_row.uom_code;
		l_rt_row.primary_quantity := p_primary_quantity;
		l_rt_row.primary_unit_of_measure := p_primary_unit_of_measure;
		l_rt_row.source_doc_quantity := p_source_doc_quantity;
		l_rt_row.source_doc_unit_of_measure := p_source_doc_unit_of_measure;
		l_rt_row.shipment_header_id := p_shipment_header_id;
		l_rt_row.shipment_line_id := p_shipment_line_id;
		l_rt_row.employee_id := l_rti_row.employee_id;
		l_rt_row.po_header_id := l_rti_row.po_header_id;
		l_rt_row.po_release_id := l_rti_row.po_release_id;
		l_rt_row.po_line_id := l_rti_row.po_line_id;
		l_rt_row.po_line_location_id := l_rti_row.po_line_location_id;
		l_rt_row.po_distribution_id := l_rti_row.po_distribution_id;
		l_rt_row.po_revision_num := l_rti_row.po_revision_num;
		l_rt_row.requisition_line_id := l_rti_row.requisition_line_id;
		l_rt_row.req_distribution_id := l_rti_row.req_distribution_id;

                -- Bug 6265149 : Start
                -- It is mandatory to set the following:
                -- Purchasing > Setups > Purchasing > Document types (PO/Release) > Archive on => 'Approve'
                begin
                  if (l_rti_row.source_document_code = 'PO' and
		      l_rt_row.transaction_type in ('DELIVER', 'ACCEPT', 'REJECT')) then
                      --
                     -- Bug 9767933, Changed the below code to handle the case when Archive on => 'Communicate'
 	                   select archive_external_revision_code
 	                     into l_archive_ext_rev_code
 	                     from po_document_types
 	                    where document_type_code = 'PO'
 	                      and document_subtype = (select type_lookup_code from po_headers
 	                                               where po_header_id = l_rti_row.po_header_id);

 	          if l_archive_ext_rev_code = 'APPROVE' then
		      select   price_override
                      into     l_rt_row.po_unit_price
                      from     po_line_locations_archive
                      where    line_location_id = l_rti_row.po_line_location_id
                      and      nvl(latest_external_flag,'N') = 'Y';
                      --
                      asn_debug.put_line('PO Unit Price from pll_archive :' || l_rt_row.po_unit_price);
                      --
		      else
 	                       l_rt_row.po_unit_price := NULL;
 	            end if;
                  end if;
                exception
		  when others then
                       asn_debug.put_line('Fetching from pll_archive failed : ' || SQLERRM);
                       l_rt_row.po_unit_price := NULL;
                end;
                --
                if (l_rt_row.po_unit_price is null) then
                        l_rt_row.po_unit_price := l_rti_row.po_unit_price;
                end if;
                asn_debug.put_line('PO Unit Price is :' || l_rt_row.po_unit_price);
                --
                -- Bug 6265149 : End

		IF l_rti_row.currency_code IS NULL THEN

		/* Bug 5246147: Removed the function calls rcv_table_functions.get_fspa_row_from_org() and
				rcv_table_functions.get_sob_row_from_id() to get the currency_code value and
				added the following sql to get the currency_code */
			select gsob.currency_code into
			       l_rt_row.currency_code
			  from hr_organization_information hoi,
			       financials_system_params_all fsp,
			       gl_sets_of_books gsob
			 where hoi.organization_id = l_rti_row.to_organization_id
			   and hoi.org_information_context||'' = 'Accounting Information'
			   and (fsp.org_id is null OR hoi.org_information3 = to_char(fsp.org_id))
			   and hoi.org_information1 = to_char(fsp.set_of_books_id)
			   and fsp.set_of_books_id = gsob.set_of_books_id;
		ELSE
			l_rt_row.currency_code := l_rti_row.currency_code;
		END IF;
		IF l_rti_row.currency_conversion_rate IS NULL AND l_rti_row.source_document_code <> 'RMA' THEN
			l_rt_row.currency_conversion_rate := 1;
		ELSE
			l_rt_row.currency_conversion_rate := l_rti_row.currency_conversion_rate;
		END IF;
		l_rt_row.currency_conversion_date := l_rti_row.currency_conversion_date;
		l_rt_row.currency_conversion_type := l_rti_row.currency_conversion_type;
		l_rt_row.routing_header_id := l_rti_row.routing_header_id;
		l_rt_row.routing_step_id := l_rti_row.routing_step_id;
		l_rt_row.substitute_unordered_code := l_rti_row.substitute_unordered_code;
		l_rt_row.receipt_exception_flag := l_rti_row.receipt_exception_flag;
		CASE p_transaction_type
			WHEN 'RECEIVE' THEN l_rt_row.inspection_status_code := 'NOT INSPECTED';
			WHEN 'ACCEPT' THEN l_rt_row.inspection_status_code := 'ACCEPTED';
			WHEN 'REJECT' THEN l_rt_row.inspection_status_code := 'REJECTED';
			ELSE l_rt_row.inspection_status_code := l_rti_row.inspection_status_code;
		END CASE;
		IF p_transaction_type = 'RECEIVE' THEN
			l_rt_row.inspection_quality_code := '';
		ELSE
			l_rt_row.inspection_quality_code := l_rti_row.inspection_quality_code;
		END IF;
		l_rt_row.vendor_id := l_rti_row.vendor_id;
		l_rt_row.vendor_site_id := l_rti_row.vendor_site_id;
		l_rt_row.vendor_lot_num := l_rti_row.vendor_lot_num;
		l_rt_row.organization_id := l_rti_row.to_organization_id;
		l_rt_row.from_subinventory := l_rti_row.from_subinventory;
		l_rt_row.from_locator_id := l_rti_row.from_locator_id;
		l_rt_row.subinventory := l_rti_row.subinventory;
		l_rt_row.locator_id := l_rti_row.locator_id;
		IF ( p_transaction_type = 'RECEIVE' AND
		     l_rti_row.auto_transact_code = 'DELIVER' ) OR
		   p_transaction_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER')
		THEN
			l_rt_row.subinventory := NULL;
			l_rt_row.locator_id := NULL;
		END IF;
		IF p_transaction_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER') AND
		   l_parent_row.transaction_type = 'DELIVER'
		THEN
			l_rt_row.from_subinventory := l_rti_row.subinventory;
			l_rt_row.from_locator_id := l_rti_row.locator_id;
		END IF;
		l_rt_row.rma_reference := l_rti_row.rma_reference;
		l_rt_row.deliver_to_person_id := l_rti_row.deliver_to_person_id;
		l_rt_row.deliver_to_location_id := l_rti_row.deliver_to_location_id;
		l_rt_row.department_code := l_rti_row.department_code;
		l_rt_row.wip_entity_id := l_rti_row.wip_entity_id;
		l_rt_row.wip_line_id := l_rti_row.wip_line_id;
		l_rt_row.wip_repetitive_schedule_id := l_rti_row.wip_repetitive_schedule_id;
		l_rt_row.wip_operation_seq_num := l_rti_row.wip_operation_seq_num;
		l_rt_row.wip_resource_seq_num := l_rti_row.wip_resource_seq_num;
		l_rt_row.bom_resource_id := l_rti_row.bom_resource_id;
		IF p_transaction_type IN ('RECEIVE','DELIVER') THEN
			l_rt_row.inv_transaction_id := l_rti_row.inv_transaction_id;
		ELSE
			l_rt_row.inv_transaction_id := '';
		END IF;
		l_rt_row.reason_id := l_rti_row.reason_id;
		IF l_use_ship_to_flag = 'Y' THEN
			l_rt_row.destination_context := 'RECEIVING';
		ELSE
			l_rt_row.destination_context := l_rti_row.destination_context;
		END IF;
		l_rt_row.comments := l_rti_row.comments;
		l_rt_row.interface_transaction_id := l_rti_row.interface_transaction_id;
		l_rt_row.group_id := l_rti_row.group_id;
		l_rt_row.attribute_category := l_rti_row.attribute_category;
		l_rt_row.attribute1 := l_rti_row.attribute1;
		l_rt_row.attribute2 := l_rti_row.attribute2;
		l_rt_row.attribute3 := l_rti_row.attribute3;
		l_rt_row.attribute4 := l_rti_row.attribute4;
		l_rt_row.attribute5 := l_rti_row.attribute5;
		l_rt_row.attribute6 := l_rti_row.attribute6;
		l_rt_row.attribute7 := l_rti_row.attribute7;
		l_rt_row.attribute8 := l_rti_row.attribute8;
		l_rt_row.attribute9 := l_rti_row.attribute9;
		l_rt_row.attribute10 := l_rti_row.attribute10;
		l_rt_row.attribute11 := l_rti_row.attribute11;
		l_rt_row.attribute12 := l_rti_row.attribute12;
		l_rt_row.attribute13 := l_rti_row.attribute13;
		l_rt_row.attribute14 := l_rti_row.attribute14;
		l_rt_row.attribute15 := l_rti_row.attribute15;
		l_rt_row.movement_id := l_rti_row.movement_id;
		IF l_rti_row.vendor_site_id IS NOT NULL AND RCV_TABLE_FUNCTIONS.get_pvs_row_from_id(l_rti_row.vendor_site_id).pay_on_code IN ('RECEIPT','RECEIPT_AND_USE') THEN
			l_rt_row.invoice_status_code := 'PENDING';
		ELSE
			l_rt_row.invoice_status_code := '';
		END IF;
		l_rt_row.qa_collection_id := l_rti_row.qa_collection_id;
		l_rt_row.mvt_stat_status := 'NEW';
		l_rt_row.country_of_origin_code := l_rti_row.country_of_origin_code;
		--bug8920533
		IF l_rt_row.country_of_origin_code IS NULL AND l_rt_row.source_document_code = 'PO' AND l_rt_row.parent_transaction_id IS NOT NULL AND l_rt_row.parent_transaction_id > 0 THEN
		   SELECT country_of_origin_code
		   INTO   l_rt_row.country_of_origin_code
		   FROM   rcv_transactions
		   WHERE  transaction_id = l_rt_row.parent_transaction_id;
		END IF;
		--end bug 8920533
		l_rt_row.oe_order_header_id := l_rti_row.oe_order_header_id;
		l_rt_row.oe_order_line_id := l_rti_row.oe_order_line_id;
		l_rt_row.customer_id := l_rti_row.customer_id;
		l_rt_row.customer_site_id := l_rti_row.customer_site_id;

		IF l_rti_row.validation_flag = 'N' THEN
			IF p_transaction_type = 'RECEIVE' THEN
				l_rt_row.transfer_lpn_id := null; --bugfix 4473005
			ELSE
				l_rt_row.lpn_id := l_rti_row.lpn_id;
				l_rt_row.transfer_lpn_id := l_rti_row.transfer_lpn_id;
			END IF;
		ELSE
			--Bug 4401341 : If transaction_type is 'SHIP' and auto_transact_code is
			--'RECEIVE', then we stamp the lpn_id and transfer_lpn_id columns in
			--rcv_transactions table.
			IF p_transaction_type = 'DELIVER' AND
			   l_rti_row.transaction_type = 'RECEIVE'
			THEN
				l_rt_row.lpn_id := l_rti_row.transfer_lpn_id;
				l_rt_row.transfer_lpn_id := l_rti_row.transfer_lpn_id;
			ELSIF p_transaction_type = 'RECEIVE' AND
			      l_rti_row.transaction_type = 'SHIP'
			THEN
				l_rt_row.lpn_id := l_rti_row.transfer_lpn_id;
				l_rt_row.transfer_lpn_id := l_rti_row.lpn_id;
			ELSE
				l_rt_row.lpn_id := l_rti_row.lpn_id;
				l_rt_row.transfer_lpn_id := l_rti_row.transfer_lpn_id;
			END IF;
		END IF;

		l_rt_row.mobile_txn := l_rti_row.mobile_txn;
		l_rt_row.secondary_quantity := l_rti_row.secondary_quantity;
		l_rt_row.secondary_unit_of_measure := l_rti_row.secondary_unit_of_measure;
		IF l_rti_row.parent_transaction_id IS NULL THEN
			IF l_rti_row.po_line_location_id IS NOT NULL THEN
				l_rt_row.consigned_flag := RCV_TABLE_FUNCTIONS.get_pll_row_from_id(l_rti_row.po_line_location_id).consigned_flag;
			END IF;
		ELSE
			l_rt_row.consigned_flag := RCV_TABLE_FUNCTIONS.get_rt_row_from_id(l_rti_row.parent_transaction_id).consigned_flag;
		END IF;

		l_rt_row.lpn_group_id := l_rti_row.lpn_group_id;
		l_rt_row.amount := l_rti_row.amount;
		l_rt_row.job_id := l_rti_row.job_id;
		l_rt_row.timecard_id := l_rti_row.timecard_id;
		l_rt_row.timecard_ovn := l_rti_row.timecard_ovn;
		l_rt_row.project_id := l_rti_row.project_id;
		l_rt_row.task_id := l_rti_row.task_id;
		l_rt_row.requested_amount := l_rti_row.requested_amount;
		l_rt_row.material_stored_amount := l_rti_row.material_stored_amount;
		l_rt_row.replenish_order_line_id := l_rti_row.replenish_order_line_id;

		/*Bug 5517289-Start*/
		IF ((l_rti_row.source_document_code = 'INVENTORY') OR (l_rti_row.source_document_code = 'REQ'))  THEN

  		  OPEN c_fob_point(l_rti_row.from_organization_id,l_rti_row.to_organization_id);
		  FETCH c_fob_point INTO l_fob_point;
		  CLOSE c_fob_point;

		  asn_debug.put_line('FOB Point is :' || l_fob_point);

		  BEGIN

		    IF (l_fob_point = 2) THEN
  		      asn_debug.put_line('Validating the INV accouting period for Organization :'||l_rti_row.from_organization_id);
		      IF (RCV_TRANSACTION_PROCESSOR.get_acct_period_status(p_trx_date => l_rti_row.transaction_date,
                                                                           p_org_id   => l_rti_row.from_organization_id)
                                  NOT IN ('O', 'F')) THEN
			asn_debug.put_line('INV accounting period is not opened for the source organization :'|| l_rti_row.from_organization_id);
			x_error_message := 'PO_INV_NO_OPEN_PERIOD';
			RETURN;
		      END IF;
		    END IF;
		  EXCEPTION
		    WHEN OTHERS THEN
		      asn_debug.put_line('unexpected error in get_acct_period_status');
		      x_error_message := 'PO_INV_NO_OPEN_PERIOD';
     		      RETURN;
		  END;
		END IF;
		/*Bug 5517289-End*/

		/* Bug 5842219:
		   source_transaction_num provided in the rti table has to be
		   maintained in the rt table. */
		l_rt_row.source_transaction_num := l_rti_row.source_transaction_num;
		asn_debug.put_line('source_transaction_num:' || l_rt_row.source_transaction_num);

                /* lcm changes */
		l_rt_row.lcm_shipment_line_id := l_rti_row.lcm_shipment_line_id;
		l_rt_row.unit_landed_cost := l_rti_row.unit_landed_cost;
		l_rt_row.lcm_adjustment_num := l_rti_row.lcm_adjustment_num; --Changes for LCM-OPM integration project

		asn_debug.put_line('lcm_shipment_line_id is ' || l_rt_row.lcm_shipment_line_id);
		asn_debug.put_line('unit_landed_cost is ' || l_rt_row.unit_landed_cost);
		asn_debug.put_line('lcm_adjustment_num is ' || l_rt_row.lcm_adjustment_num); --Changes for LCM-OPM integration project

		asn_debug.put_line('Inserting RT row (' || l_rt_row.transaction_type || ')...');
		asn_debug.put_line('transaction_id: ' || l_rt_row.transaction_id
			|| ' parent_transaction_id: ' || l_rt_row.parent_transaction_id
			|| ' interface_transaction_id: ' || l_rt_row.interface_transaction_id
			|| ' group_id: ' || l_rt_row.group_id
			|| ' request_id: ' || l_rt_row.request_id
			);

		/* GSCC errors come up when we use the foll. insert.
		 * Changing to use the full insert stmts.
		INSERT INTO RCV_TRANSACTIONS
		VALUES l_rt_row;
		*/
	/* Bug: 6487371
	 *  Added exception handler to catch the exception when insertion into rcv_transactions
	 *  fails due to exception raised in the triggers(for eg; India Localisation triggers) on
	 *  rcv_transactions table. Similarly added exception handler for insertion into
	 *  po_note_references table. To this rvthinns() function as whole, added one exception handler.
	 *  While storing sqlerrm in the x_message_data getting only the first 200 bytes.
	 *  without that unhandled exception is raised while copying the sqlerrm. And moreover
	 *  in rvtth.lpc rvthinns(), x_msg_data is defined to store only 200 bytes.
	 */
	      BEGIN --Bug: 6487371
		INSERT INTO rcv_transactions
		(transaction_id,
		last_update_date,
		last_updated_by,
		created_by,
		creation_date,
		last_update_login,
		request_id,
		program_application_id,
		program_id,
		program_update_date,
		interface_source_code,
		interface_source_line_id,
		user_entered_flag,
		transaction_type,
		transaction_date,
		source_document_code,
		destination_type_code,
		location_id,
		quantity,
		unit_of_measure,
		uom_code,
		primary_quantity,
		primary_unit_of_measure,
		source_doc_quantity,
		source_doc_unit_of_measure,
		shipment_header_id,
		shipment_line_id,
		parent_transaction_id,
		employee_id,
		po_header_id,
		po_release_id,
		po_line_id,
		po_line_location_id,
		po_distribution_id,
		po_revision_num,
		requisition_line_id,
		req_distribution_id,
		po_unit_price,
		currency_code,
		currency_conversion_rate,
		currency_conversion_date,
		currency_conversion_type,
		routing_header_id,
		routing_step_id,
		substitute_unordered_code,
		receipt_exception_flag,
		inspection_status_code,
		inspection_quality_code,
		vendor_id,
		vendor_site_id,
		vendor_lot_num,
		organization_id,
		from_subinventory, /*FPJ WMS change */
		from_locator_id,
		subinventory,
		locator_id,
		rma_reference,
		deliver_to_person_id,
		deliver_to_location_id,
		department_code,
		wip_entity_id,
		wip_line_id,
		wip_repetitive_schedule_id,
		wip_operation_seq_num,
		wip_resource_seq_num,
		bom_resource_id,
		inv_transaction_id,
		reason_id,
		destination_context,
		comments,
		interface_transaction_id,
		group_id,
		attribute_category,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		movement_id,
		invoice_status_code,  /* BUG 551612 */
		qa_collection_id,
		mvt_stat_status,
		country_of_origin_code,
		oe_order_header_id,
		oe_order_line_id,
		customer_id,
		customer_site_id,
		lpn_id,
		transfer_lpn_id,
		mobile_txn,
		secondary_quantity,
		secondary_unit_of_measure,
		secondary_uom_code, --Bug 8273466
		consigned_flag, /*<CONSIGNED INV RTP FPI>*/
		lpn_group_id, /*FPJ WMS */
		amount,
		job_id,
		timecard_id,
		timecard_ovn,
		project_id,
		task_id,
		requested_amount, --Complex work
		material_stored_amount, -- Complex Work
		replenish_order_line_id, -- Bug 5367699
		source_transaction_num, -- Bug 5842219
		lcm_shipment_line_id, -- lcm changes
		unit_landed_cost,     -- lcm changes
		lcm_adjustment_num )  -- changes for LCM-OPM integration project
		VALUES
		(l_rt_row.transaction_id,
		l_rt_row.last_update_date,
		l_rt_row.last_updated_by,
		l_rt_row.created_by,
		l_rt_row.creation_date,
		l_rt_row.last_update_login,
		l_rt_row.request_id,
		l_rt_row.program_application_id,
		l_rt_row.program_id,
		l_rt_row.program_update_date,
		l_rt_row.interface_source_code,
		l_rt_row.interface_source_line_id,
		l_rt_row.user_entered_flag,
		l_rt_row.transaction_type,
		l_rt_row.transaction_date,
		l_rt_row.source_document_code,
		l_rt_row.destination_type_code,
		l_rt_row.location_id,
		l_rt_row.quantity,
		l_rt_row.unit_of_measure,
		l_rt_row.uom_code,
		l_rt_row.primary_quantity,
		l_rt_row.primary_unit_of_measure,
		l_rt_row.source_doc_quantity,
		l_rt_row.source_doc_unit_of_measure,
		l_rt_row.shipment_header_id,
		l_rt_row.shipment_line_id,
		l_rt_row.parent_transaction_id,
		l_rt_row.employee_id,
		l_rt_row.po_header_id,
		l_rt_row.po_release_id,
		l_rt_row.po_line_id,
		l_rt_row.po_line_location_id,
		l_rt_row.po_distribution_id,
		l_rt_row.po_revision_num,
		l_rt_row.requisition_line_id,
		l_rt_row.req_distribution_id,
		l_rt_row.po_unit_price,
		l_rt_row.currency_code,
		l_rt_row.currency_conversion_rate,
		l_rt_row.currency_conversion_date,
		l_rt_row.currency_conversion_type,
		l_rt_row.routing_header_id,
		l_rt_row.routing_step_id,
		l_rt_row.substitute_unordered_code,
		l_rt_row.receipt_exception_flag,
		l_rt_row.inspection_status_code,
		l_rt_row.inspection_quality_code,
		l_rt_row.vendor_id,
		l_rt_row.vendor_site_id,
		l_rt_row.vendor_lot_num,
		l_rt_row.organization_id,
		l_rt_row.from_subinventory, /*FPJ WMS change */
		l_rt_row.from_locator_id,
		l_rt_row.subinventory,
		l_rt_row.locator_id,
		l_rt_row.rma_reference,
		l_rt_row.deliver_to_person_id,
		l_rt_row.deliver_to_location_id,
		l_rt_row.department_code,
		l_rt_row.wip_entity_id,
		l_rt_row.wip_line_id,
		l_rt_row.wip_repetitive_schedule_id,
		l_rt_row.wip_operation_seq_num,
		l_rt_row.wip_resource_seq_num,
		l_rt_row.bom_resource_id,
		l_rt_row.inv_transaction_id,
		l_rt_row.reason_id,
		l_rt_row.destination_context,
		l_rt_row.comments,
		l_rt_row.interface_transaction_id,
		l_rt_row.group_id,
		l_rt_row.attribute_category,
		l_rt_row.attribute1,
		l_rt_row.attribute2,
		l_rt_row.attribute3,
		l_rt_row.attribute4,
		l_rt_row.attribute5,
		l_rt_row.attribute6,
		l_rt_row.attribute7,
		l_rt_row.attribute8,
		l_rt_row.attribute9,
		l_rt_row.attribute10,
		l_rt_row.attribute11,
		l_rt_row.attribute12,
		l_rt_row.attribute13,
		l_rt_row.attribute14,
		l_rt_row.attribute15,
		l_rt_row.movement_id,
		l_rt_row.invoice_status_code,  /* BUG 551612 */
		l_rt_row.qa_collection_id,
		l_rt_row.mvt_stat_status,
		l_rt_row.country_of_origin_code,
		l_rt_row.oe_order_header_id,
		l_rt_row.oe_order_line_id,
		l_rt_row.customer_id,
		l_rt_row.customer_site_id,
		l_rt_row.lpn_id,
		l_rt_row.transfer_lpn_id,
		l_rt_row.mobile_txn,
		l_rt_row.secondary_quantity,
		l_rt_row.secondary_unit_of_measure,
		l_rti_row.secondary_uom_code,  -- Bug 8273466
		l_rt_row.consigned_flag, /*<CONSIGNED INV RTP FPI>*/
		l_rt_row.lpn_group_id, /*FPJ WMS */
		l_rt_row.amount,
		l_rt_row.job_id,
		l_rt_row.timecard_id,
		l_rt_row.timecard_ovn,
		l_rt_row.project_id,
		l_rt_row.task_id,
		l_rt_row.requested_amount, --Complex work
		l_rt_row.material_stored_amount, -- Complex Work
		l_rt_row.replenish_order_line_id, -- Bug 5367699
		l_rt_row.source_transaction_num, -- Bug 5842219
		l_rt_row.lcm_shipment_line_id, -- lcm changes
		l_rt_row.unit_landed_cost,      -- lcm changes
		decode(l_rt_row.lcm_shipment_line_id, null, null,nvl(l_rt_row.lcm_adjustment_num,0)) );--changes for LCM-OPM integration project
	     EXCEPTION --Bug: 6487371
	        when others then
	           asn_debug.put_line('Error occured while inserting into rcv_transactions...'||sqlerrm);
	           x_error_message := substr(sqlerrm,1,200);
	           RETURN;
	     END;--Bug: 6487371

		x_rt_id := l_rt_row.transaction_id;

		BEGIN
			asn_debug.put_line('Updating child RTI rows');

			/* FPJ FASTFORWARD START.
			* If this rti row is a parent of any rti rows, then
			* we need to update the parent_transaction_id of
			* children with this new transaction id since it will
			* not be populated at the pre-processor stage.
			* Update only those rows which has parent_transaction_id
			* as null since if the user has populated parent_transaction_id
			* and parent_interface_txn_id, then we dont want to override
			* it.
			*/
			UPDATE rcv_transactions_interface
			   SET parent_transaction_id = l_rt_row.transaction_id
			     , shipment_line_id = l_rt_row.shipment_line_id
			 WHERE parent_interface_txn_id = l_rti_row.interface_transaction_id
			   AND parent_transaction_id IS NULL;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		END;

		IF NVL(l_rti_row.qa_collection_id,0) <> 0 THEN
			asn_debug.put_line('Enabling Quality Inspection Results');

			DECLARE
				l_return_status VARCHAR2(1);
				l_msg_count NUMBER := 0;
				l_msg_data VARCHAR2(2000);
			BEGIN
				QA_RESULT_GRP.enable
					( 1
					, 'F'
					, 'F'
					, 0
					, l_rti_row.qa_collection_id
					, l_return_status
					, l_msg_count
					, l_msg_data
					);

				IF l_msg_count IS NULL OR l_msg_count = -1 THEN
					asn_debug.put_line('QA Actions Failed: ' || l_msg_data);
					x_error_message := 'QA_ACTIONS_FAILED';
					RETURN;
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					asn_debug.put_line('QA Actions Failed: ' || SQLERRM);
					x_error_message := 'QA_ACTIONS_FAILED';
					RETURN;
			END;
		END IF;

		IF l_rti_row.erecord_id IS NOT NULL AND l_rti_row.erecord_id > 0 THEN
			DECLARE
				l_event_name VARCHAR2(240);
				l_event_key VARCHAR2(240);
				l_erecord_id NUMBER;
				l_return_status VARCHAR2(1);
				l_msg_count NUMBER := 0;
				l_msg_data VARCHAR2(2000);
			BEGIN
				-- FPJ EDR integration
				-- get the event name and erecord id
				CASE l_rti_row.transaction_type
					WHEN 'ACCEPT' THEN l_event_name := 'oracle.apps.po.rcv.inspect';
					WHEN 'REJECT' THEN l_event_name := 'oracle.apps.po.rcv.inspect';
					WHEN 'DELIVER' THEN l_event_name := 'oracle.apps.po.rcv.deliver';
					WHEN 'TRANSFER' THEN l_event_name := 'oracle.apps.po.rcv.transfer';
				END CASE;

				l_event_key := l_rti_row.parent_transaction_id || '-' || l_rti_row.qa_collection_id;
				l_erecord_id := l_rti_row.erecord_id;

				-- FPJ EDR integration
				-- acknowledge erecord has been enabled
			    	QA_EDR_STANDARD.SEND_ACKN
					( 1.0
					, FND_API.G_FALSE
					, l_return_status
					, l_msg_count
					, l_msg_data
					, l_event_name
					, l_event_key
					, l_rti_row.erecord_id
					, 'SUCCESS'
					, NULL
					, 'Receiving Transaction Processor'
					, FND_API.G_TRUE
					);

				IF l_return_status <> 'S' THEN
					asn_debug.put_line('QA_EDR_STANDARD.SEND_ACKN failed with return status: ' || l_return_status);
					IF l_msg_count > 0 THEN
						asn_debug.put_line(l_msg_data);
					END IF;

					x_error_message := 'EDR_SEND_ACKN_FAILED';
					RETURN;
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					asn_debug.put_line('QA_EDR_STANDARD.SEND_ACKN failed');
					IF l_msg_count > 0 THEN
						asn_debug.put_line(l_msg_data);
					END IF;

					asn_debug.put_line(SQLERRM);

					x_error_message := 'EDR_SEND_ACKN_FAILED';
					RETURN;
			END;
		END IF;

		IF get_product_install_status('CSE') = 'I' THEN
			DECLARE
				l_return_status VARCHAR2(1);
			BEGIN
				asn_debug.put_line('Calling CSE post transaction exit');
				CSE_RCVTXN_PKG.PostTransaction_Exit
					( l_rt_row.transaction_id
					, l_rti_row.interface_transaction_id
					, l_return_status
					);
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		END IF;

		l_common_receiving := p_transaction_type = 'RECEIVE' AND
		                      get_product_install_status('GMI') = 'I' AND
		                      gml_po_for_process.check_po_for_proc;

		IF l_common_receiving THEN
			BEGIN
				asn_debug.put_line('Performing Common Receiving quality event');
				gml_rcv_db_common.raise_quality_event
					( l_rt_row.transaction_id
					, l_rti_row.item_id
					, l_rti_row.to_organization_id
					);
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		END IF;

		asn_debug.put_line('Updating PO Note References');

		DECLARE
			l_row_id NUMBER;
		BEGIN
			UPDATE po_note_references
			SET table_name = 'RCV_TRANSACTIONS',
			    column_name = 'TRANSACTION_ID',
			    foreign_id = l_rt_row.transaction_id
			WHERE table_name = 'RCV_TRANSACTIONS_INTERFACE'
			AND   column_name = 'INTERFACE_TRANSACTION_ID'
			AND   foreign_id = l_rti_row.interface_transaction_id;

			IF SQL%ROWCOUNT > 0 AND
			   p_transaction_type = 'DELIVER' AND
			   l_rti_row.auto_transact_code = 'DELIVER' AND
			   p_receive_id IS NOT NULL
			THEN
				INSERT INTO po_note_references
	                (po_note_reference_id,
	                 last_update_date,
	                 last_updated_by,
	                 last_update_login,
	                 creation_date,
	                 created_by,
	                 po_note_id,
	                 table_name,
	                 column_name,
	                 foreign_id,
	                 sequence_num,
	                 storage_type,
	                 request_id,
	                 program_application_id,
	                 program_id,
	                 program_update_date,
	                 attribute_category,
	                 attribute1,
	                 attribute2,
	                 attribute3,
	                 attribute4,
	                 attribute5,
	                 attribute6,
	                 attribute7,
	                 attribute8,
	                 attribute9,
	                 attribute10,
	                 attribute11,
	                 attribute12,
	                 attribute13,
	                 attribute14,
	                 attribute15)
	           SELECT po_note_references_s.nextval,
	                 last_update_date,
	                 last_updated_by,
	                 last_update_login,
	                 creation_date,
	                 created_by,
	                 po_note_id,
	                 table_name,
	                 column_name,
	                 l_rt_row.transaction_id,
	                 sequence_num,
	                 storage_type,
	                 request_id,
	                 program_application_id,
	                 program_id,
	                 program_update_date,
	                 attribute_category,
	                 attribute1,
	                 attribute2,
	                 attribute3,
	                 attribute4,
	                 attribute5,
	                 attribute6,
	                 attribute7,
	                 attribute8,
	                 attribute9,
	                 attribute10,
	                 attribute11,
	                 attribute12,
	                 attribute13,
	                 attribute14,
	                 attribute15
	            FROM po_note_references
	            WHERE table_name = 'RCV_TRANSACTIONS'
	            AND   column_name = 'TRANSACTION_ID'
	            AND   foreign_id = p_receive_id;
			END IF;
		EXCEPTION--Bug: 6487371
		   when others then
		      asn_debug.put_line('Error while inserting into po_note_references...'||sqlerrm);
		      x_error_message := substr(sqlerrm,1,200);
		      RETURN;--Bug: 6487371
		END;
	EXCEPTION--Bug: 6487371
	   when others then
	      asn_debug.put_line('Unexpected error occured...'||sqlerrm);
	      x_error_message := substr(sqlerrm,1,200);
	      RETURN;--Bug: 6487371

	asn_debug.put_line('Done with RVTTHIns');
	END RVTTHIns;

END RCV_TRANSACTION_PROCESSOR;

/
