--------------------------------------------------------
--  DDL for Package Body PO_SOURCING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SOURCING_PVT" AS
/* $Header: POXVCPAB.pls 120.4.12010000.4 2012/04/23 13:25:49 smvinod ship $*/


---
--- +=======================================================================+
--- |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
--- |                         All rights reserved.                          |
--- +=======================================================================+
--- |
--- | FILENAME
--- |     POXVCPAB.pls
--- |
--- |
--- | DESCRIPTION
--- |
--- |     This package contains procedures called from the sourcing
--- |     to create CPA in PO
--- |
--- | HISTORY
--- |
--- |     30-Sep-2004 rbairraj   Initial version
--- |
--- +=======================================================================+
---

--------------------------------------------------------------------------------

g_pkg_name    CONSTANT VARCHAR2(30) := 'PO_SOURCING_PVT';
g_log_head    CONSTANT VARCHAR2(30) := 'po.plsql.PO_SOURCING_PVT.';
g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;


 --SQL WHAT: Selects the records from the po_headers_interface table
 --SQL WHY: These values are used in creating a Purchase Order
 --SQl Join:None

CURSOR g_interface_cursor(p_interface_header_id NUMBER) IS
       SELECT phi.interface_header_id interface_header_id,
              phi.interface_source_code interface_source_code,
              phi.document_type_code,
              phi.batch_id batch_id,
              phi.action action,
              phi.document_subtype document_subtype,
              phi.document_num document_num,
              phi.po_header_id po_header_id,
              phi.agent_id agent_id,
              phi.vendor_id vendor_id,
              phi.vendor_site_id vendor_site_id,
              phi.vendor_contact_id vendor_contact_id,
              phi.ship_to_location_id ship_to_location_id,
              phi.bill_to_location_id bill_to_location_id,
              phi.terms_id terms_id,
              phi.freight_carrier ship_via_lookup_code,
              phi.fob fob_lookup_code,
              phi.pay_on_code pay_on_code,
              phi.freight_terms freight_terms_lookup_code,
              phi.creation_date creation_date,
              phi.created_by created_by,
              phi.last_update_date last_update_date,
              phi.last_updated_by last_updated_by,
              phi.last_update_login last_update_login,
              phi.revision_num revision_num,
              phi.print_count print_count,
              phi.closed_code h_closed_code,
              phi.frozen_flag frozen_flag,
              phi.firm_flag h_firm_status_lookup_code,
              phi.confirming_order_flag confirming_order_flag,
              phi.acceptance_required_flag acceptance_required_flag,
              phi.currency_code h_currency_code,
              phi.rate_type_code h_rate_type,
              phi.rate_date h_rate_date,
              phi.rate h_rate,
              phi.amount_agreed,
    	      phi.effective_date,
	          phi.expiration_date,
	          phi.amount_limit,
              phi.global_agreement_flag,
              phi.shipping_control,
              phi.org_id
         FROM po_headers_interface phi
        WHERE phi.interface_header_id = p_interface_header_id;

-- Type declaration for  System Parameters structure
TYPE system_parameters_rec_type IS RECORD
(currency_code             GL_SETS_OF_BOOKS.currency_code%type,
 coa_id                    GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE,
 po_encumbrance_flag       FINANCIALS_SYSTEM_PARAMETERS.purch_encumbrance_flag%TYPE,
 req_encumbrance_flag      FINANCIALS_SYSTEM_PARAMETERS.req_encumbrance_flag%TYPE,
 sob_id                    GL_SETS_OF_BOOKS.set_of_books_id%TYPE,
 ship_to_location_id       FINANCIALS_SYSTEM_PARAMETERS.ship_to_location_id%TYPE,
 bill_to_location_id       FINANCIALS_SYSTEM_PARAMETERS.bill_to_location_id%TYPE,
 fob_lookup_code           FINANCIALS_SYSTEM_PARAMETERS.fob_lookup_code%type,
 freight_terms_lookup_code
               FINANCIALS_SYSTEM_PARAMETERS.freight_terms_lookup_code%type,
 terms_id                  PO_SYSTEM_PARAMETERS.term_id%TYPE,
 default_rate_type         PO_SYSTEM_PARAMETERS.default_rate_type%type,
 taxable_flag              PO_SYSTEM_PARAMETERS.taxable_flag%TYPE,
 receiving_flag            PO_SYSTEM_PARAMETERS.receiving_flag%TYPE,
 enforce_buyer_name_flag   PO_SYSTEM_PARAMETERS.enforce_buyer_name_flag%TYPE,
 enforce_buyer_auth_flag   PO_SYSTEM_PARAMETERS.enforce_buyer_authority_flag%TYPE,
 line_type_id              PO_SYSTEM_PARAMETERS.line_type_id%TYPE := null,
 manual_po_num_type        PO_SYSTEM_PARAMETERS.manual_po_num_type%TYPE,
 po_num_code               PO_SYSTEM_PARAMETERS.user_defined_po_num_code%TYPE,
 price_type_lookup_code    PO_SYSTEM_PARAMETERS.price_type_lookup_code%TYPE,
 invoice_close_tolerance   PO_SYSTEM_PARAMETERS.invoice_close_tolerance%TYPE,
 receive_close_tolerance   PO_SYSTEM_PARAMETERS.receive_close_tolerance%TYPE,
 security_structure_id     PO_SYSTEM_PARAMETERS.security_position_structure_id%TYPE,
 expense_accrual_code      PO_SYSTEM_PARAMETERS.price_type_lookup_code%TYPE,
 inventory_organization_id FINANCIALS_SYSTEM_PARAMETERS.inventory_organization_id%TYPE,
 rev_sort_ordering         FINANCIALS_SYSTEM_PARAMETERS.revision_sort_ordering%TYPE,
 min_rel_amount            PO_SYSTEM_PARAMETERS.min_release_amount%TYPE,
 notify_blanket_flag       PO_SYSTEM_PARAMETERS.notify_if_blanket_flag%TYPE,
 budgetary_control_flag    GL_SETS_OF_BOOKS.enable_budgetary_control_flag%TYPE,
 user_defined_req_num_code PO_SYSTEM_PARAMETERS.user_defined_req_num_code%type,
 rfq_required_flag         PO_SYSTEM_PARAMETERS.rfq_required_flag%TYPE,
 manual_req_num_type       PO_SYSTEM_PARAMETERS.manual_req_num_type%type,
 enforce_full_lot_qty      PO_SYSTEM_PARAMETERS.enforce_full_lot_quantities%type,
 disposition_warning_flag    PO_SYSTEM_PARAMETERS.disposition_warning_flag%TYPE,
 reserve_at_completion_flag  FINANCIALS_SYSTEM_PARAMETERS.reserve_at_completion_flag%TYPE,
 user_defined_rcpt_num_code
                       PO_SYSTEM_PARAMETERS.user_defined_receipt_num_code%type,
 manual_rcpt_num_type        PO_SYSTEM_PARAMETERS.manual_receipt_num_type%type,
 use_positions_flag	         FINANCIALS_SYSTEM_PARAMETERS.use_positions_flag%TYPE,
 default_quote_warning_delay PO_SYSTEM_PARAMETERS.default_quote_warning_delay%TYPE,
 inspection_required_flag    PO_SYSTEM_PARAMETERS.inspection_required_flag%TYPE,
 user_defined_quote_num_code
                       PO_SYSTEM_PARAMETERS.user_defined_quote_num_code%type,
 manual_quote_num_type PO_SYSTEM_PARAMETERS.manual_quote_num_type%type,
 user_defined_rfq_num_code
                       PO_SYSTEM_PARAMETERS.user_defined_rfq_num_code%type,
 manual_rfq_num_type	     PO_SYSTEM_PARAMETERS.manual_rfq_num_type%type,
 ship_via_lookup_code  FINANCIALS_SYSTEM_PARAMETERS.ship_via_lookup_code%type,
 qty_rcv_tolerance           rcv_parameters.qty_rcv_tolerance%TYPE,
 period_name                 GL_PERIOD_STATUSES.period_name%type);

-- Type declaration for Vendor defaults structure
TYPE vendor_defaults_rec_type IS RECORD
(vendor_id                 PO_VENDORS.vendor_id%TYPE := null,
-- Bug# 4546121:All columns that referred to the obsolete columns in po_vendors have
--              been modified to point to PO_HEADERS_ALL type.
 ship_to_location_id       PO_HEADERS_ALL.ship_to_location_id%TYPE := null,
 bill_to_location_id       PO_HEADERS_ALL.bill_to_location_id%TYPE := null,
 ship_via_lookup_code      PO_HEADERS_ALL.ship_via_lookup_code%TYPE := null,
 fob_lookup_code           PO_HEADERS_ALL.fob_lookup_code%TYPE := null,
 pay_on_code               PO_VENDOR_SITES_ALL.pay_on_code%TYPE := null,
 freight_terms_lookup_code PO_HEADERS_ALL.freight_terms_lookup_code%TYPE := null,
 terms_id                  po_vendors.terms_id%TYPE := null,
 type_1099                 PO_VENDORS.type_1099%TYPE := null,
 hold_flag                 PO_VENDORS.hold_flag%TYPE := null,
 invoice_currency_code     PO_VENDORS.invoice_currency_code%TYPE := null,
 receipt_required_flag     PO_VENDORS.receipt_required_flag%TYPE := null,
 num_1099                  PO_VENDORS.num_1099%TYPE := null,
 vat_registration_num      PO_VENDORS.vat_registration_num%TYPE := NULL,
 /*Bug 10203569 the variable vat_registration_num was initially declared as number but
 in the view po_vendors this variable is a varchar, hence ORA-06502: PL/SQL:
 numeric or value error:  character to number conversion error. was encountered.
 Changed the data type to PO_VENDORS.vat_registration_num%TYPE := NULL*/
 inspection_required_flag  PO_VENDORS.inspection_required_flag%TYPE := null,
 invoice_match_option      PO_VENDORS.match_option%TYPE := null,
 shipping_control          PO_VENDOR_SITES.shipping_control%TYPE := NULL
);

-- Type declaration for WHO information structure
TYPE who_rec_type IS RECORD
(user_id           NUMBER := 0,
 login_id          NUMBER := 0,
 resp_id           NUMBER := 0);

g_cpa_csr                   g_interface_cursor%ROWTYPE;
g_who_rec                   who_rec_type;
g_params_rec                system_parameters_rec_type;
g_vendor_rec                vendor_defaults_rec_type;
g_vendor_default_rec        vendor_defaults_rec_type;
g_progress                  VARCHAR2(2000) := '000';
g_style_id                  PO_HEADERS_INTERFACE.style_id%TYPE;    -- bug 10017321

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_SYSTEM_DEFAULTS
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  This procedure is called for getting the default po paramters
--Parameters:
--IN:
--p_interface_header_id
--   Id that uniquely identifies a row in po_headers_interface table
--OUT:
--   None
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE get_system_defaults(p_interface_header_id IN PO_HEADERS_INTERFACE.interface_header_id%TYPE) IS
x_date date;
l_api_name CONSTANT VARCHAR2(30) := 'get_system_defaults';
BEGIN
     IF g_debug_stmt THEN
         PO_DEBUG.debug_begin(p_log_head => g_log_head||l_api_name);
     END IF;

    -- Get WHO column values
    g_who_rec.user_id  := nvl(fnd_global.user_id,0);
    g_who_rec.login_id := nvl(fnd_global.login_id,0);
    g_who_rec.resp_id  := nvl(fnd_global.resp_id,0);

    g_progress:='010';

    -- Get system defaults
    PO_CORE_S.get_po_parameters(
                     x_currency_code                 => g_params_rec.currency_code,
                     x_coa_id                        => g_params_rec.coa_id,
                     x_po_encumberance_flag          => g_params_rec.po_encumbrance_flag,
                     x_req_encumberance_flag         => g_params_rec.req_encumbrance_flag,
                     x_sob_id                        => g_params_rec.sob_id,
                     x_ship_to_location_id           => g_params_rec.ship_to_location_id,
                     x_bill_to_location_id           => g_params_rec.bill_to_location_id,
                     x_fob_lookup_code               => g_params_rec.fob_lookup_code,
                     x_freight_terms_lookup_code     => g_params_rec.freight_terms_lookup_code,
                     x_terms_id                      => g_params_rec.terms_id,
                     x_default_rate_type             => g_params_rec.default_rate_type,
                     x_taxable_flag                  => g_params_rec.taxable_flag,
                     x_receiving_flag                => g_params_rec.receiving_flag,
                     x_enforce_buyer_name_flag       => g_params_rec.enforce_buyer_name_flag,
                     x_enforce_buyer_auth_flag       => g_params_rec.enforce_buyer_auth_flag,
                     x_line_type_id                  => g_params_rec.line_type_id,
                     x_manual_po_num_type            => g_params_rec.manual_po_num_type,
                     x_po_num_code                   => g_params_rec.po_num_code,
                     x_price_lookup_code             => g_params_rec.price_type_lookup_code,
                     x_invoice_close_tolerance       => g_params_rec.invoice_close_tolerance,
                     x_receive_close_tolerance       => g_params_rec.receive_close_tolerance,
                     x_security_structure_id         => g_params_rec.security_structure_id,
                     x_expense_accrual_code          => g_params_rec.expense_accrual_code,
                     x_inv_org_id                    => g_params_rec.inventory_organization_id,
                     x_rev_sort_ordering             => g_params_rec.rev_sort_ordering,
                     x_min_rel_amount                => g_params_rec.min_rel_amount,
                     x_notify_blanket_flag           => g_params_rec.notify_blanket_flag,
                     x_budgetary_control_flag        => g_params_rec.budgetary_control_flag,
                     x_user_defined_req_num_code     => g_params_rec.user_defined_req_num_code,
                     x_rfq_required_flag             => g_params_rec.rfq_required_flag,
                     x_manual_req_num_type           => g_params_rec.manual_req_num_type,
                     x_enforce_full_lot_qty          => g_params_rec.enforce_full_lot_qty,
                     x_disposition_warning_flag      => g_params_rec.disposition_warning_flag,
                     x_reserve_at_completion_flag    => g_params_rec.reserve_at_completion_flag,
                     x_user_defined_rcpt_num_code    => g_params_rec.user_defined_rcpt_num_code,
                     x_manual_rcpt_num_type          => g_params_rec.manual_rcpt_num_type,
			         x_use_positions_flag	         => g_params_rec.use_positions_flag,
                     x_default_quote_warning_delay   => g_params_rec.default_quote_warning_delay,
                     x_inspection_required_flag      => g_params_rec.inspection_required_flag,
                     x_user_defined_quote_num_code   => g_params_rec.user_defined_quote_num_code,
                     x_manual_quote_num_type	     => g_params_rec.manual_quote_num_type,
                     x_user_defined_rfq_num_code     => g_params_rec.user_defined_rfq_num_code,
                     x_manual_rfq_num_type	         => g_params_rec.manual_rfq_num_type,
                     x_ship_via_lookup_code	         => g_params_rec.ship_via_lookup_code,
                     x_qty_rcv_tolerance	         => g_params_rec.qty_rcv_tolerance);

        g_progress:='020';

        IF(g_params_rec.po_encumbrance_flag = 'Y') THEN
          PO_CORE_S.get_period_name(
                    x_sob_id  => g_params_rec.sob_id,
                    x_period  => g_params_rec.period_name,
                    x_gl_date => x_date);
        END IF;

     IF g_debug_stmt THEN
         PO_DEBUG.debug_end(p_log_head => g_log_head||l_api_name);
     END IF;

EXCEPTION
  WHEN OTHERS THEN
      g_progress:='030';
      IF g_debug_unexp THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => SQLERRM);
      END IF;

      FND_MSG_PUB.add_exc_msg(
               p_pkg_name       => 'PO_SOURCING_PVT',
               p_procedure_name => l_api_name,
               p_error_text     => NULL);
END get_system_defaults;

-------------------------------------------------------------------------------
--Start of Comments
--Name: DEFAULT_CPA
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  This procedure is called for defaulting all the values that are left null in
--  the headers_interface_table but are required for creating the CPA and can be
--  defaulted from one or more sources
--Parameters:
--IN:
--  None
--OUT:
--x_return_status
--   The standard OUT parameter giving return status of the API call.
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE DEFAULT_CPA (
    x_return_status       OUT    NOCOPY    VARCHAR2
) IS
    l_api_name                   VARCHAR2(30) := 'DEFAULT_CPA';
    l_terms_id                   PO_HEADERS.terms_id%TYPE;
    l_fob_lookup_code            PO_HEADERS.fob_lookup_code%TYPE;
    l_freight_lookup_code        PO_HEADERS.freight_terms_lookup_code%TYPE;
    l_ship_via_lookup_code       PO_HEADERS_ALL.ship_via_lookup_code%TYPE;
    l_vs_terms_id                PO_HEADERS.terms_id%TYPE;
    l_vs_fob_lookup_code         PO_HEADERS.fob_lookup_code%TYPE;
    l_vs_freight_lookup_code     PO_HEADERS.freight_terms_lookup_code%TYPE;
    l_vs_ship_via_lookup_code    PO_HEADERS_ALL.ship_via_lookup_code%TYPE;

BEGIN
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	--Default all the required default po parameters from the financial system
	--parameters,Po_system_parameters, receiving options and gl set of books.
	--Using the procedure po_core_s.get_po_parameters
    g_progress := '200';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'Before calling get_system_defaults');
    END IF;

    get_system_defaults(p_interface_header_id => g_cpa_csr.interface_header_id);

    g_progress := '201';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'After calling get_system_defaults');
    END IF;

	 IF (g_params_rec.po_num_code='AUTOMATIC') THEN
       -- This is necessary to ensure that concurrency issues do not crop up.
       -- We would actually pick the value from the db just before the commit action
         g_cpa_csr.document_num := 'CPA 11.5.10+';
     END IF;

	--  Default the relevant vendor information
    IF(g_cpa_csr.vendor_id is not null) THEN
          g_progress := '202';
          IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'Before calling get_vendor_info');
          END IF;

          PO_VENDORS_SV.get_vendor_info (
                      X_vendor_id                 => g_cpa_csr.vendor_id,
                      X_ship_to_location_id       => g_vendor_default_rec.ship_to_location_id,
                      X_bill_to_location_id       => g_vendor_default_rec.bill_to_location_id,
                      X_ship_via_lookup_code      => l_ship_via_lookup_code,
                      X_fob_lookup_code           => l_fob_lookup_code,
                      X_freight_terms_lookup_code => l_freight_lookup_code,
                      X_terms_id                  => l_terms_id,
                      X_type_1099                 => g_vendor_default_rec.type_1099,
                      X_hold_flag                 => g_vendor_default_rec.hold_flag,
                      X_invoice_currency_code     => g_vendor_default_rec.invoice_currency_code,
                      X_receipt_required_flag     => g_vendor_default_rec.receipt_required_flag,
                      X_num_1099                  => g_vendor_default_rec.num_1099,
                      X_vat_registration_num      => g_vendor_default_rec.vat_registration_num,
                      X_inspection_required_flag  => g_vendor_default_rec.inspection_required_flag
                      );

          g_progress := '203';
          IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'After calling get_vendor_info');
          END IF;

    END IF;
	--  Default the relevant vendor site information. You would then require this for
    --  defaulting the pay_on_code , shipping_control using the procedure
	--  po_vendor_sites_sv.get_vendor_site_info
    IF(g_cpa_csr.vendor_site_id is not null) THEN
          g_progress := '204';
          IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'Before calling get_vendor_site_info');
          END IF;

             PO_VENDOR_SITES_SV.get_vendor_site_info(
                          X_vendor_site_id               => g_cpa_csr.vendor_site_id,
                          X_vs_ship_to_location_id       => g_vendor_rec.ship_to_location_id,
                          X_vs_bill_to_location_id       => g_vendor_rec.bill_to_location_id,
                          X_vs_ship_via_lookup_code      => l_vs_ship_via_lookup_code,
                          X_vs_fob_lookup_code           => l_vs_fob_lookup_code,
                          X_vs_pay_on_code               => g_vendor_rec.pay_on_code,
                          X_vs_freight_terms_lookup_code => l_vs_freight_lookup_code,
                          X_vs_terms_id                  => l_vs_terms_id,
                          X_vs_invoice_currency_code     => g_vendor_rec.invoice_currency_code,
                          x_vs_shipping_control          => g_vendor_rec.shipping_control
                         );

          g_progress := '205';
          IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'After calling get_vendor_site_info');
          END IF;

             --  Default the pay_on_code for a CPA   based
             --  on the vendor site value.
             if (g_vendor_rec.pay_on_code = 'RECEIPT_AND_USE') then
                g_vendor_rec.pay_on_code := 'RECEIPT';
             elsif (g_vendor_rec.pay_on_code = 'USE') then
                g_vendor_rec.pay_on_code := null;
             end if;
    END IF; -- End of vendor_site_id is not null

  -- IF the value of shipping_control in the interface table is null
  -- then Copy the value from terms value defaulted from vendor site Information
     IF g_cpa_csr.shipping_control IS NULL THEN
       g_cpa_csr.shipping_control := g_vendor_rec.shipping_control;
     END IF;

     -- If global_agreement_flag is 'N' set it to null
     IF g_cpa_csr.global_agreement_flag = 'N' THEN
       g_cpa_csr.global_agreement_flag := NULL;
     END IF;

    -- Defaulting the terms id
    IF g_cpa_csr.terms_id IS NULL THEN
       if l_vs_terms_id is not null then
          po_terms_sv.val_ap_terms(
                                   X_temp_terms_id => l_vs_terms_id,
                                   X_res_terms_id => g_cpa_csr.terms_id
                                   );
       end if;
      IF g_cpa_csr.terms_id IS NULL THEN
       if l_terms_id is not null then
          po_terms_sv.val_ap_terms(
                                   X_temp_terms_id => l_terms_id,
                                   X_res_terms_id => g_cpa_csr.terms_id
                                   );
       end if;
        IF g_cpa_csr.terms_id IS NULL THEN
          g_cpa_csr.terms_id := g_params_rec.terms_id;
        END IF;
      END IF;
    END IF;

    -- Defaulting the ship_via_lookup_code
    IF g_cpa_csr.ship_via_lookup_code IS NULL THEN
       if l_vs_ship_via_lookup_code is not null then
          po_vendors_sv.val_freight_carrier(
                                   X_temp_ship_via => l_vs_ship_via_lookup_code,
                                   X_org_id => g_params_rec.inventory_organization_id,
                                   X_res_ship_via => g_cpa_csr.ship_via_lookup_code
                                           );
       end if;
      IF g_cpa_csr.ship_via_lookup_code IS NULL THEN
       if l_ship_via_lookup_code is not null then
          po_vendors_sv.val_freight_carrier(
                                   X_temp_ship_via => l_ship_via_lookup_code,
                                   X_org_id => g_params_rec.inventory_organization_id,
                                   X_res_ship_via => g_cpa_csr.ship_via_lookup_code
                                           );
       end if;
        IF g_cpa_csr.ship_via_lookup_code IS NULL THEN
          g_cpa_csr.ship_via_lookup_code := g_params_rec.ship_via_lookup_code;
        END IF;
      END IF;
    END IF;

    -- Defaulting the fob_lookup_code
    IF g_cpa_csr.fob_lookup_code IS NULL THEN
       if l_vs_fob_lookup_code is not null then
          po_vendors_sv.val_fob(
                               X_temp_fob_lookup_code => l_vs_fob_lookup_code,
                               X_res_fob => g_cpa_csr.fob_lookup_code
                               );
       end if;
      IF g_cpa_csr.fob_lookup_code IS NULL THEN
       if l_fob_lookup_code is not null then
          po_vendors_sv.val_fob(
                               X_temp_fob_lookup_code => l_fob_lookup_code,
                               X_res_fob => g_cpa_csr.fob_lookup_code
                               );
       end if;
        IF g_cpa_csr.fob_lookup_code IS NULL THEN
          g_cpa_csr.fob_lookup_code := g_params_rec.fob_lookup_code;
        END IF;
      END IF;
    END IF;

    -- Defaulting the pay_on_code
    IF g_cpa_csr.pay_on_code IS NULL THEN
      g_cpa_csr.pay_on_code := g_vendor_rec.pay_on_code;
    END IF;

    -- Defaulting the freight_terms_lookup_code
    IF g_cpa_csr.freight_terms_lookup_code IS NULL THEN
       if l_vs_freight_lookup_code is not null then
          po_vendors_sv.val_freight_terms(
                                   X_temp_freight_terms => l_vs_freight_lookup_code,
                                   X_res_freight_terms => g_cpa_csr.freight_terms_lookup_code
                                           );
       end if;
      IF g_cpa_csr.freight_terms_lookup_code IS NULL THEN
       if l_freight_lookup_code is not null then
          po_vendors_sv.val_freight_terms(
                                   X_temp_freight_terms => l_freight_lookup_code,
                                   X_res_freight_terms => g_cpa_csr.freight_terms_lookup_code
                                           );
       end if;
        IF g_cpa_csr.freight_terms_lookup_code IS NULL THEN
          g_cpa_csr.freight_terms_lookup_code := g_params_rec.freight_terms_lookup_code;
        END IF;
      END IF;
    END IF;

     g_cpa_csr.revision_num := 0;
     g_cpa_csr.h_closed_code := 'OPEN';
     g_cpa_csr.print_count := 0;
     g_cpa_csr.confirming_order_flag := 'N';
     g_cpa_csr.frozen_flag := 'N';

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         g_progress := '210';
         IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => 'Expected Error');
         END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         g_progress := '211';
         IF g_debug_unexp THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => 'Unexpected Error');
         END IF;
   WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         g_progress := '212';
         IF g_debug_unexp THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => SQLERRM);
         END IF;
         FND_MSG_PUB.add_exc_msg(
               p_pkg_name       => 'PO_SOURCING_PVT',
               p_procedure_name => l_api_name,
               p_error_text     => NULL);

END DEFAULT_CPA;
-------------------------------------------------------------------------------
--Start of Comments
--Name: VALIDATE_CPA
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  validates the data in the interface table to create CPA
--Parameters:
--IN:
--   None
--OUT:
--x_return_status
--   The standard OUT parameter giving return status of the API call.
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE VALIDATE_CPA (
    x_return_status           OUT    NOCOPY    VARCHAR2
) IS
  is_valid                    BOOLEAN := FALSE;
  l_error_code                VARCHAR2(30);
  l_api_name CONSTANT         VARCHAR2(30) := 'VALIDATE_CPA';
  l_fob_lookup_code           PO_LOOKUP_CODES.lookup_code%TYPE;
  l_freight_terms_lookup_code PO_LOOKUP_CODES.lookup_code%TYPE;
  l_freight_carrier           ORG_FREIGHT.freight_code%TYPE;
  l_terms_id                  AP_TERMS.term_id%TYPE;
BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- validate document number
  IF g_cpa_csr.document_num IS NOT NULL THEN
    IF g_cpa_csr.document_num <> 'CPA 11.5.10+' THEN
       g_progress := '300';
       IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => 'Before calling PO_HEADERS_SV6.val_doc_num');
       END IF;
      is_valid := PO_HEADERS_SV6.val_doc_num(
                           X_doc_type                   => g_cpa_csr.document_type_code,
                           X_doc_num                    => g_cpa_csr.document_num,
                           X_user_defined_num           => g_params_rec.manual_po_num_type,
                           X_user_defined_po_num_code   => g_params_rec.po_num_code,
                           X_error_code                 => l_error_code);
       g_progress := '301';
       IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => 'After calling PO_HEADERS_SV6.val_doc_num. X_error_code = '||l_error_code);
       END IF;

     IF (is_valid = FALSE ) THEN
         IF (l_error_code = 'PO_PDOI_DOC_NUM_UNIQUE') THEN
            g_progress := '302';
            IF g_debug_stmt THEN
                PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                    p_token    => g_progress,
                                    p_message  => 'PO_PDOI_DOC_NUM_UNIQUE');
            END IF;
            Fnd_message.set_name('PO','PO_PDOI_DOC_NUM_UNIQUE');
            Fnd_message.set_token( token  => 'VALUE'
                                 , VALUE => g_cpa_csr.document_num);
            FND_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;

         ELSIF (l_error_code = 'PO_PDOI_VALUE_NUMERIC') THEN
            g_progress := '303';
            IF g_debug_stmt THEN
                PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                    p_token    => g_progress,
                                    p_message  => 'PO_PDOI_VALUE_NUMERIC');
            END IF;
            Fnd_message.set_name('PO','PO_PDOI_VALUE_NUMERIC');
            Fnd_message.set_token( token  => 'COLUMN_NAME'
                                 , VALUE => 'Document Number');
            Fnd_message.set_token( token  => 'VALUE'
                                 , VALUE => g_cpa_csr.document_num);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
         ELSIF (l_error_code = 'PO_PDOI_LT_ZERO') THEN
            g_progress := '304';
            IF g_debug_stmt THEN
                PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                    p_token    => g_progress,
                                    p_message  => 'PO_PDOI_LT_ZERO');
            END IF;
            Fnd_message.set_name('PO','PO_PDOI_LT_ZERO');
            Fnd_message.set_token( token  => 'COLUMN_NAME'
                                 , VALUE => 'Document Number');
            Fnd_message.set_token( token  => 'VALUE'
                                 , VALUE => g_cpa_csr.document_num);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
     END IF; -- If is_valid = FALSE
    END IF;  -- End of IF g_cpa_csr.document_num <> 'CPA 11.5.10+'
  ELSE
    -- This code executes when the document num creation is manual
    -- and no data is passed from sourcing for document num
    g_progress := '305';
    IF g_debug_stmt THEN
       PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                           p_token    => g_progress,
                           p_message  => 'PO_PDOI_COLUMN_NOT_NULL');
    END IF;
    Fnd_message.set_name('PO','PO_PDOI_COLUMN_NOT_NULL');
    Fnd_message.set_token( token  => 'COLUMN_NAME'
                         , VALUE => 'Document Number');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF; -- End of IF g_cpa_csr.document_num IS NOT NULL

  -- Validate ship_to_location
  IF g_cpa_csr.ship_to_location_id IS NOT NULL THEN
     g_progress := '306';
     IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                             p_token    => g_progress,
                             p_message  => 'Before calling PO_LINE_LOCATIONS_SV1.val_location_id for Ship to location');
     END IF;

    is_valid := PO_LINE_LOCATIONS_SV1.val_location_id(
                                          X_location_id     => g_cpa_csr.ship_to_location_id,
                         		          X_location_type   => 'SHIP_TO');
     g_progress := '307';
     IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                             p_token    => g_progress,
                             p_message  => 'After calling PO_LINE_LOCATIONS_SV1.val_location_id for Ship to Location');
     END IF;
    IF (is_valid = FALSE) THEN
         g_progress := '308';
         IF g_debug_stmt THEN
             PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                 p_token    => g_progress,
                                 p_message  => 'PO_PDOI_INVALID_SHIP_LOC_ID');
         END IF;
         g_cpa_csr.ship_to_location_id := NULL;
    END IF;
  END IF; -- End of validate ship_to_location

  -- Validate bill_to_location
  IF g_cpa_csr.bill_to_location_id IS NOT NULL THEN
     g_progress := '309';
     IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                             p_token    => g_progress,
                             p_message  => 'Before calling PO_LINE_LOCATIONS_SV1.val_location_id for Bill to location');
     END IF;

    is_valid := PO_LINE_LOCATIONS_SV1.val_location_id(
                                          X_location_id     => g_cpa_csr.bill_to_location_id,
                         		          X_location_type   => 'BILL_TO');
     g_progress := '310';
     IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                             p_token    => g_progress,
                             p_message  => 'After calling PO_LINE_LOCATIONS_SV1.val_location_id for Bill to location');
     END IF;

    IF (is_valid = FALSE) THEN
         g_progress := '311';
         IF g_debug_stmt THEN
             PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                 p_token    => g_progress,
                                 p_message  => 'PO_PDOI_INVALID_BILL_LOC_ID');
         END IF;
         g_cpa_csr.bill_to_location_id := NULL;
    END IF;
  END IF; -- End of validate bill_to_location
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     g_progress := '320';
     IF g_debug_stmt THEN
       PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                           p_token    => g_progress,
                           p_message  => 'Expected Error');
     END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_progress := '321';
     IF g_debug_unexp THEN
       PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                           p_token    => g_progress,
                           p_message  => 'Unexpected Error');
     END IF;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_progress := '322';
     IF g_debug_unexp THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(
               p_pkg_name       => 'PO_SOURCING_PVT',
               p_procedure_name => l_api_name,
               p_error_text     => NULL);
END VALIDATE_CPA;

-------------------------------------------------------------------------------
--Start of Comments
--Name: INSERT_CPA
--Pre-reqs:
--  None
--Modifies:
--  Transaction tables for the requested document
--Locks:
--  None.
--Function:
--  inserts the data into the PO_HEADERS table to create CPA
--Parameters:
--IN:
--p_auction_header_id
--  Id of the negotiation
--p_bid_number
--  Bid Number for which is negotiation is awarded
--p_sourcing_k_doc_type
--   Represents the OKC document type that would be created into a CPA
--   The document type that Sourcing has seeded in Contracts.
--p_conterms_exist_flag
--   Whether the sourcing document has contract template attached.
--p_document_creation_method
--   Column specific to DBI. Sourcing will pass a value of AWARD_SOURCING
--OUT:
--x_document_id
--   The unique identifier for the newly created document.
--x_document_number
--   The document number that would uniquely identify a document in a given organization.
--x_return_status
--   The standard OUT parameter giving return status of the API call.
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE INSERT_CPA (
    p_auction_header_id        IN               PON_AUCTION_HEADERS_ALL.auction_header_id%TYPE,
    p_bid_number               IN               PON_BID_HEADERS.bid_number%TYPE,
    p_sourcing_k_doc_type      IN               VARCHAR2,
    p_conterms_exist_flag      IN               PO_HEADERS_ALL.conterms_exist_flag%TYPE,
    p_document_creation_method IN               VARCHAR2,
    x_document_id              OUT    NOCOPY    PO_HEADERS_ALL.po_header_id%TYPE,
    x_document_number          OUT    NOCOPY    PO_HEADERS_ALL.segment1%TYPE,
    x_return_status            OUT    NOCOPY    VARCHAR2
) IS
   l_rowid                     VARCHAR2(30);
   l_po_header_id              PO_HEADERS_ALL.po_header_id%TYPE;
   l_document_num              PO_HEADERS_INTERFACE.document_num%TYPE;
   l_current_org               PO_SYSTEM_PARAMETERS.org_id%TYPE;
   l_org_assign_rec            PO_GA_ORG_ASSIGNMENTS%ROWTYPE;
   l_org_row_id                ROWID;
   l_return_status	           VARCHAR2(1);
   l_contract_doc_type         VARCHAR2(150);
   l_contracts_call_exception  EXCEPTION;
   l_msg_data                  VARCHAR2(2000);
   l_msg_count                 NUMBER;
   l_manual                    BOOLEAN;
   x_document_num              PO_HEADERS.segment1%TYPE:=null;
   l_api_name CONSTANT VARCHAR2(30) := 'INSERT_CPA';

   -- Start PO AME Approval workflow change
   l_ame_approval_id         po_headers_all.ame_approval_id%TYPE;
   l_ame_transaction_type    po_headers_all.ame_transaction_type%TYPE;
   l_new_ame_appr_id_req varchar2(1);
   -- End PO AME Approval workflow change

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_document_num := g_cpa_csr.document_num;
  x_document_number := g_cpa_csr.document_num;

  IF (g_params_rec.po_num_code = 'AUTOMATIC') THEN
      l_manual := FALSE;
  ELSE
      l_manual := TRUE;
  END IF;

  g_progress := '400';
  IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                          p_token    => g_progress,
                          p_message  => 'Before calling PO_HEADERS_PKG_S0.Insert_Row');
  END IF;
  l_current_org := PO_GA_PVT.get_current_org;   -- <R12 MOAC>
  PO_HEADERS_PKG_S0.Insert_Row(
                       X_Rowid                          => l_rowid,
                       X_Po_Header_Id                   => l_po_header_id,
                       X_Agent_Id                       => g_cpa_csr.agent_id,
                       X_Type_Lookup_Code               => g_cpa_csr.document_subtype,
                       X_Last_Update_Date               => g_cpa_csr.last_update_date,
                       X_Last_Updated_By                => g_cpa_csr.last_updated_by,
                       X_Segment1                       => x_document_num,
                       X_Summary_Flag                   => 'N',
                       X_Enabled_Flag                   => 'Y',
                       X_Segment2                       => NULL,
                       X_Segment3                       => NULL,
                       X_Segment4                       => NULL,
                       X_Segment5                       => NULL,
                       X_Start_Date_Active              => NULL,
                       X_End_Date_Active                => NULL,
                       X_Last_Update_Login              => nvl(g_cpa_csr.last_update_login,fnd_global.login_id),
                       X_Creation_Date                  => g_cpa_csr.creation_date,
                       X_Created_By                     => g_cpa_csr.created_by,
                       X_Vendor_Id                      => g_cpa_csr.vendor_id,
                       X_Vendor_Site_Id                 => g_cpa_csr.vendor_site_id,
                       X_Vendor_Contact_Id              => g_cpa_csr.vendor_contact_id,
                       X_Ship_To_Location_Id            => g_cpa_csr.ship_to_location_id,
                       X_Bill_To_Location_Id            => g_cpa_csr.bill_to_location_id,
                       X_Terms_Id                       => g_cpa_csr.terms_id,
                       X_Ship_Via_Lookup_Code           => g_cpa_csr.ship_via_lookup_code,
                       X_Fob_Lookup_Code                => g_cpa_csr.fob_lookup_code,
                       X_Pay_On_Code                    => g_cpa_csr.pay_on_code,
                       X_Freight_Terms_Lookup_Code      => g_cpa_csr.freight_terms_lookup_code,
                       X_Status_Lookup_Code             => NULL,
                       X_Currency_Code                  => g_cpa_csr.h_currency_code,
                       X_Rate_Type                      => g_cpa_csr.h_rate_type,
                       X_Rate_Date                      => nvl(g_cpa_csr.h_rate_date,trunc(sysdate)),
                       X_Rate                           => g_cpa_csr.h_rate,
                       X_From_Header_Id                 => NULL,
                       X_From_Type_Lookup_Code          => NULL,
                       X_Start_Date                     => g_cpa_csr.effective_date,
                       X_End_Date                       => g_cpa_csr.expiration_date,
                       X_Blanket_Total_Amount           => g_cpa_csr.amount_agreed,
                       X_Authorization_Status           => NULL,
                       X_Revision_Num                   => g_cpa_csr.revision_num,
                       X_Revised_Date                   => NULL,
                       X_Approved_Flag                  => NULL,
                       X_Approved_Date                  => NULL,
                       X_Amount_Limit                   => nvl(g_cpa_csr.amount_limit, g_cpa_csr.amount_agreed),
                       X_Min_Release_Amount             => NULL,
                       X_Note_To_Authorizer             => NULL,
                       X_Note_To_Vendor                 => NULL,
                       X_Note_To_Receiver               => NULL,
                       X_Print_Count                    => g_cpa_csr.print_count,
                       X_Printed_Date                   => NULL,
                       X_Vendor_Order_Num               => NULL,
                       X_Confirming_Order_Flag          => g_cpa_csr.confirming_order_flag,
                       X_Comments                       => NULL,
                       X_Reply_Date                     => NULL,
                       X_Reply_Method_Lookup_Code       => NULL,
                       X_Rfq_Close_Date                 => NULL,
                       X_Quote_Type_Lookup_Code         => NULL,
                       X_Quotation_Class_Code           => NULL,
                       X_Quote_Warning_Delay_Unit       => NULL,
                       X_Quote_Warning_Delay            => NULL,
                       X_Quote_Vendor_Quote_Number      => NULL,
                       X_Acceptance_Required_Flag       => g_cpa_csr.acceptance_required_flag,
                       X_Acceptance_Due_Date            => NULL,
                       X_Closed_Date                    => NULL,
                       X_User_Hold_Flag                 => NULL,
                       X_Approval_Required_Flag         => NULL,
                       X_Cancel_Flag                    => 'N',
                       X_Firm_Status_Lookup_Code        => nvl(g_cpa_csr.h_firm_status_lookup_code,'N'),
                       X_Firm_Date                      => NULL,
                       X_Frozen_Flag                    => g_cpa_csr.frozen_flag,
		               X_Global_Agreement_Flag		    => g_cpa_csr.global_agreement_flag,
                       X_Attribute_Category             => NULL,
                       X_Attribute1                     => NULL,
                       X_Attribute2                     => NULL,
                       X_Attribute3                     => NULL,
                       X_Attribute4                     => NULL,
                       X_Attribute5                     => NULL,
                       X_Attribute6                     => NULL,
                       X_Attribute7                     => NULL,
                       X_Attribute8                     => NULL,
                       X_Attribute9                     => NULL,
                       X_Attribute10                    => NULL,
                       X_Attribute11                    => NULL,
                       X_Attribute12                    => NULL,
                       X_Attribute13                    => NULL,
                       X_Attribute14                    => NULL,
                       X_Attribute15                    => NULL,
                       X_Closed_Code                    => g_cpa_csr.h_closed_code,
                       X_Ussgl_Transaction_Code         => NULL,
                       X_Government_Context             => NULL,
                       X_Supply_Agreement_flag          => 'N',
                       X_Manual                         => l_manual,
                       X_Price_Update_Tolerance         => NULL,
	                   X_Global_Attribute_Category      => NULL,
                       X_Global_Attribute1              => NULL,
                       X_Global_Attribute2              => NULL,
                       X_Global_Attribute3              => NULL,
                       X_Global_Attribute4              => NULL,
                       X_Global_Attribute5              => NULL,
                       X_Global_Attribute6              => NULL,
                       X_Global_Attribute7              => NULL,
                       X_Global_Attribute8              => NULL,
                       X_Global_Attribute9              => NULL,
                       X_Global_Attribute10             => NULL,
                       X_Global_Attribute11             => NULL,
                       X_Global_Attribute12             => NULL,
                       X_Global_Attribute13             => NULL,
                       X_Global_Attribute14             => NULL,
                       X_Global_Attribute15             => NULL,
                       X_Global_Attribute16             => NULL,
                       X_Global_Attribute17             => NULL,
                       X_Global_Attribute18             => NULL,
                       X_Global_Attribute19             => NULL,
                       X_Global_Attribute20             => NULL,
                       p_shipping_control               => g_cpa_csr.shipping_control,
                       p_encumbrance_required_flag      => NULL,
                       p_org_id                         => l_current_org,           -- <R12 MOAC>
		       p_style_id => g_style_id        -- bug 10017321: Adding g_style_id while call
                       );

           x_document_id := l_po_header_id;
  g_progress := '401';
  IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                          p_token    => g_progress,
                          p_message  => 'After calling PO_HEADERS_PKG_S0.Insert_Row. po_header_id = '||l_po_header_id||': Segment1 = '||l_document_num);

  END IF;

        -- After insert into po_headers, insert a row into org_assignments for a global agreement
           IF nvl(g_cpa_csr.global_agreement_flag, 'N') = 'Y' then

             l_current_org := PO_GA_PVT.get_current_org;

               -- call the GA org assignments table handler to insert a row
               -- for the owning org into the org assignments table
               l_org_assign_rec.po_header_id      := l_po_header_id;
               l_org_assign_rec.organization_id   := l_current_org;
               l_org_assign_rec.purchasing_org_id := l_org_assign_rec.organization_id;
               l_org_assign_rec.enabled_flag      := 'Y';
               l_org_assign_rec.vendor_site_id    := g_cpa_csr.vendor_site_id;
               l_org_assign_rec.last_update_date  := g_cpa_csr.last_update_date;
               l_org_assign_rec.last_updated_by   := g_cpa_csr.last_updated_by;
               l_org_assign_rec.creation_date     := g_cpa_csr.creation_date;
               l_org_assign_rec.created_by        := g_cpa_csr.created_by;
               l_org_assign_rec.last_update_login := g_cpa_csr.last_update_login;

               g_progress := '402';
               IF g_debug_stmt THEN
                   PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                       p_token    => g_progress,
                                       p_message  => 'Before calling PO_GA_ORG_ASSIGN_PVT.Insert_Row');
               END IF;

               PO_GA_ORG_ASSIGN_PVT.insert_row(
                                        p_init_msg_list  => FND_API.g_true,
                                        x_return_status  => l_return_status,
                                        p_org_assign_rec => l_org_assign_rec,
                                        x_row_id         => l_org_row_id);
               g_progress := '403';
               IF g_debug_stmt THEN
                   PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                       p_token    => g_progress,
                                       p_message  => 'After calling PO_GA_ORG_ASSIGN_PVT.Insert_Row');
               END IF;

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;

            END IF;

    g_progress := '404';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'Before calling PO_NEGOTIATIONS_SV2.copy_attachments fro PON_AUCTION_HEADERS_ALL');
    END IF;

	-- Copy attachments from negotiation header to CPA using the procedure
    PO_NEGOTIATIONS_SV2.copy_attachments(
            X_from_entity_name       => 'PON_AUCTION_HEADERS_ALL',
			X_from_pk1_value         => p_auction_header_id,
			X_from_pk2_value         => NULL,
			X_from_pk3_value         => NULL,
			X_from_pk4_value         => NULL,
			X_from_pk5_value         => NULL,
			X_to_entity_name         => 'PO_HEADERS',
			X_to_pk1_value           => l_po_header_id,
			X_to_pk2_value           => NULL,
			X_to_pk3_value           => NULL,
			X_to_pk4_value           => NULL,
			X_to_pk5_value           => NULL,
			X_created_by             => g_cpa_csr.created_by,
			X_last_update_login      => g_cpa_csr.last_update_login,
			X_program_application_id => NULL,
			X_program_id             => NULL,
			X_request_id             => NULL,
			X_column1                => 'NEG');

    g_progress := '405';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'After calling PO_NEGOTIATIONS_SV2.copy_attachments for PON_AUCTION_HEADERS_ALL');
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'Before calling PO_NEGOTIATIONS_SV2.copy_attachments for PON_BID_HEADERS');
    END IF;

   --copy attachment from bid header to cpa header
    PO_NEGOTIATIONS_SV2.copy_attachments(
            X_from_entity_name       => 'PON_BID_HEADERS',
			X_from_pk1_value         => p_auction_header_id,
			X_from_pk2_value         => p_bid_number,
			X_from_pk3_value         => '',
			X_from_pk4_value         => '',
			X_from_pk5_value         => '',
			X_to_entity_name         => 'PO_HEADERS',
			X_to_pk1_value           => l_po_header_id,
			X_to_pk2_value           => '',
			X_to_pk3_value           => '',
			X_to_pk4_value           => '',
			X_to_pk5_value           => '',
			X_created_by             => g_cpa_csr.created_by,
			X_last_update_login      => g_cpa_csr.last_update_login,
			X_program_application_id => '',
			X_program_id             => '',
			X_request_id             => NULL,
			X_column1                => 'NEG');

    g_progress := '406';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'After calling PO_NEGOTIATIONS_SV2.copy_attachments for PON_BID_HEADERS');
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'Before calling PO_NEGOTIATIONS_SV2.add_attch_dynamic for PON_BID_BUYER_NOTES');
    END IF;

 	-- build and attach bid notes as internal to PO attachments on cpa header.
    PO_NEGOTIATIONS_SV2.add_attch_dynamic(
			x_from_entity_name 		 => 'PON_BID_BUYER_NOTES',
			x_auction_header_id		 => p_auction_header_id,
			x_auction_line_number	 => NULL,
			x_bid_number			 => p_bid_number,
			x_bid_line_number		 => NULL,
			x_to_entity_name 		 => 'PO_HEADERS',
			x_to_pk1_value 	  		 => l_po_header_id,
			x_created_by 			 => g_cpa_csr.created_by,
			x_last_update_login      => g_cpa_csr.last_update_login,
			x_program_application_id => NULL,
			x_program_id 			 => NULL,
			x_request_id 			 => NULL);

    g_progress := '407';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'After calling PO_NEGOTIATIONS_SV2.add_attch_dynamic for PON_BID_BUYER_NOTES');
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'Before calling PO_NEGOTIATIONS_SV2.add_attch_dynamic for PON_AUC_SUPPLIER_HEADER_NOTES');
    END IF;

 	-- Build and attach negotiation header notes as 'To Supplier' attachments on CPA header
    PO_NEGOTIATIONS_SV2.add_attch_dynamic(
			x_from_entity_name 		 => 'PON_AUC_SUPPLIER_HEADER_NOTES',
			x_auction_header_id		 => p_auction_header_id,
			x_auction_line_number	 => NULL,
			x_bid_number			 => NULL,
			x_bid_line_number		 => NULL,
			x_to_entity_name 		 => 'PO_HEADERS',
			x_to_pk1_value 	  		 => l_po_header_id,
			x_created_by 			 => g_cpa_csr.created_by,
			x_last_update_login      => g_cpa_csr.last_update_login,
			x_program_application_id => NULL,
			x_program_id 			 => NULL,
			x_request_id 			 => NULL);

    g_progress := '408';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'After calling PO_NEGOTIATIONS_SV2.add_attch_dynamic for PON_AUC_SUPPLIER_HEADER_NOTES');
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'Before calling PO_NEGOTIATIONS_SV2.add_attch_dynamic for PON_BID_HEADER_ATTRIBUTES');
    END IF;
	-- Build and attach negotiation/bid header attributes as 'To Supplier'attachment on CPA Header
    PO_NEGOTIATIONS_SV2.add_attch_dynamic(
			x_from_entity_name 		 => 'PON_BID_HEADER_ATTRIBUTES',
			x_auction_header_id		 => p_auction_header_id,
			x_auction_line_number	 => NULL,
			x_bid_number			 => p_bid_number,
			x_bid_line_number		 => NULL,
			x_to_entity_name 		 => 'PO_HEADERS',
			x_to_pk1_value 	  		 => l_po_header_id,
			x_created_by 			 => g_cpa_csr.created_by,
			x_last_update_login      => g_cpa_csr.last_update_login,
			x_program_application_id => NULL,
			x_program_id 			 => NULL,
			x_request_id 			 => NULL);

    g_progress := '409';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'After calling PO_NEGOTIATIONS_SV2.add_attch_dynamic for PON_BID_HEADER_ATTRIBUTES');
    END IF;
    IF (g_params_rec.po_num_code='AUTOMATIC') AND
       (g_cpa_csr.document_num  = 'CPA 11.5.10+') THEN

       g_progress:= '410';
       IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => 'Before Selecting document number from po_unique_identifier_cont_all');
       END IF;

       -- bug5176308
       -- Consolidate PO # generation code into one API

       x_document_num :=
         PO_CORE_SV1.default_po_unique_identifier
         ( p_table_name => 'PO_HEADERS',
           p_org_id => g_cpa_csr.org_id
         );

       g_progress:= '411';
       IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => 'After Selecting document number from po_unique_identifier_cont_all');
       END IF;


         x_document_number := x_document_num;
    END IF;

    g_progress:= '412';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'Before updating po_headers_all for conterms_exist_flag and document number');
    END IF;

    --SQL WHAT: Updates Conterms_exist_flag, segment1 and document_creation_method
    --SQL WHY: To handle creation of an automatic document_number when the po_num_code is AUTOMATIC
    --         Update pf conterms_exist_flag and document_creation_method should have been
    --         handled in PO_HEADERS_PKG_S0.Insert_Row table handler.
    --          As this file is not allowed to update for 11.5.10, added separate update statement.
    --SQl Join:None

    UPDATE PO_HEADERS_ALL
    SET    conterms_exist_flag = decode(p_conterms_exist_flag,'Y','Y','N'),
           document_creation_method = p_document_creation_method,
           segment1 = x_document_num
    WHERE  po_header_id = l_po_header_id;

    g_progress:= '413';
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => g_progress,
                            p_message  => 'Before updating po_headers_all for conterms_exist_flag and document number');
    END IF;

	--Copy contract terms if sourcing doc had a template attached.
    IF (p_conterms_exist_flag = 'Y') THEN

      l_contract_doc_type:= PO_CONTERMS_UTL_GRP.GET_PO_CONTRACT_DOCTYPE(
					                    p_sub_doc_type=>g_cpa_csr.document_subtype);
      g_progress:= '414';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                             p_token    => g_progress,
                             p_message  => 'Contracts template attached'||'-'||'l_contract_doc_type:'||l_contract_doc_type);
         PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                             p_token    => g_progress,
                             p_message  => 'before call okc_terms_copy_grp.copy_doc');
      END IF;

      OKC_TERMS_COPY_GRP.copy_doc(
                        p_api_version             => 1.0,
                        p_source_doc_type	      => p_sourcing_k_doc_type,
                        p_source_doc_id	          => p_bid_number,
                        p_target_doc_type	      => l_contract_doc_type,
                        p_target_doc_id	          => l_po_header_id,
                        p_keep_version	          => 'Y',
                        p_article_effective_date  => sysdate,
                        p_initialize_status_yn	  => 'N',
                        p_reset_Fixed_Date_yn     => 'N',
                        p_copy_del_attachments_yn => 'Y',
                        p_copy_deliverables	      => 'Y',
                        p_document_number	      => x_document_num,
                        x_return_status	          => l_return_status,
                        x_msg_data	              => l_msg_data,
                        x_msg_count	              => l_msg_count
                        );

      g_progress:='415';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                             p_token    => g_progress,
                             p_message  => 'after call okc_terms_copy_grp.copy_doc.Return status:'||l_return_status);
      END IF;

	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
         RAISE l_Contracts_call_exception;
      END IF; -- Return status from contracts

	END IF; -- if p_conterms_exist_flag = Y
	   /* PO AME Approval workflow change : Updating po_headers_all with ame_transaction_type and ame_approval_id
	     in case AME transaction type is populated in Style Headers page*/
	   -- Start : PO AME Approval workflow

			BEGIN
			SELECT 'Y',
				   podsh.ame_transaction_type
			INTO   l_new_ame_appr_id_req,
				   l_ame_transaction_type
			FROM   po_headers_all poh,
				   po_doc_style_headers podsh
			WHERE  poh.style_id = podsh.style_id
            AND podsh.ame_transaction_type IS NOT NULL
            AND poh.po_header_id = l_po_header_id;

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
				l_new_ame_appr_id_req := 'N';
			END;

			UPDATE po_headers_all
			SET ame_approval_id = DECODE(l_new_ame_appr_id_req,
                                   'Y', po_ame_approvals_s.NEXTVAL,
										ame_approval_id),
			ame_transaction_type = DECODE(l_new_ame_appr_id_req,
                                        'Y', l_ame_transaction_type,
                                        ame_transaction_type)
			WHERE po_header_id = l_po_header_id;
	  -- End :  PO AME Approval workflow

EXCEPTION
  WHEN l_Contracts_call_exception then
       g_progress := '416';
       x_return_status := FND_API.G_RET_STS_ERROR;

       -- put error messages in log
        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                p_token    => g_progress,
                                p_message  => 'Insert_CPA: Inside l_contracts_call_exception');
        END IF;
          Fnd_message.set_name('PO','PO_API_ERROR');
          Fnd_message.set_token( token  => 'PROC_CALLER'
                               , VALUE => 'PO_INTERFACE_S.INSERT_CPA');
          Fnd_message.set_token( token  => 'PROC_CALLED'
                               , VALUE => 'OKC_TERMS_CPOY_GRP.COPY_DOC');
          FND_MSG_PUB.Add;

        IF g_debug_stmt THEN
            l_msg_count := FND_MSG_PUB.Count_Msg;
            FOR i IN 1..l_msg_count LOOP
                PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                    p_token    => g_progress||'_EXCEPTION_'||i,
                                    p_message  => FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F'));
            END LOOP;
        END IF;
   WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         g_progress := '417';
         IF g_debug_unexp THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => SQLERRM);
         END IF;
         FND_MSG_PUB.add_exc_msg(
               p_pkg_name       => 'PO_SOURCING_PVT',
               p_procedure_name => l_api_name,
               p_error_text     => NULL);
END INSERT_CPA;

-------------------------------------------------------------------------------
--Start of Comments
--Name: create_cpa
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Creates Contract Purchase Agreement from Sourcing document
--Parameters:
--IN:
--p_interface_header_id
--  The id that will be used to uniquely identify a row in the PO_HEADERS_INTERFACE table
--p_auction_header_id
--  Id of the negotiation
--p_bid_number
--  Bid Number for which is negotiation is awarded
--p_sourcing_k_doc_type
--   Represents the OKC document type that would be created into a CPA
--   The document type that Sourcing has seeded in Contracts.
--p_conterms_exist_flag
--   Whether the sourcing document has contract template attached.
--p_document_creation_method
--   Column specific to DBI. Sourcing will pass a value of AWARD_SOURCING
--OUT:
--x_document_id
--   The unique identifier for the newly created document.
--x_document_number
--   The document number that would uniquely identify a document in a given organization.
--x_return_status
--   The standard OUT parameter giving return status of the API call.
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE create_cpa (
    x_return_status              OUT    NOCOPY    VARCHAR2,
    x_msg_count                  OUT    NOCOPY    NUMBER,
    x_msg_data                   OUT    NOCOPY    VARCHAR2,
    p_interface_header_id        IN               PO_HEADERS_INTERFACE.interface_header_id%TYPE,
    p_auction_header_id          IN               PON_AUCTION_HEADERS_ALL.auction_header_id%TYPE,
    p_bid_number                 IN               PON_BID_HEADERS.bid_number%TYPE,
    p_sourcing_k_doc_type        IN               VARCHAR2,
    p_conterms_exist_flag        IN               PO_HEADERS_ALL.conterms_exist_flag%TYPE,
    p_document_creation_method   IN               PO_HEADERS_ALL.document_creation_method%TYPE,
    x_document_id                OUT    NOCOPY    PO_HEADERS_ALL.po_header_id%TYPE,
    x_document_number            OUT    NOCOPY    PO_HEADERS_ALL.segment1%TYPE
) IS
  l_return_status VARCHAR2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'create_cpa';

    l_document_type       PO_HEADERS_INTERFACE.document_type_code%TYPE;
    l_document_subtype    PO_HEADERS_INTERFACE.document_subtype%TYPE;
    l_action              PO_HEADERS_INTERFACE.action%TYPE;
BEGIN
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

      g_progress:='500';
      IF g_interface_cursor%ISOPEN THEN
        CLOSE g_interface_cursor;
      END IF;
      OPEN g_interface_cursor(p_interface_header_id);

      FETCH g_interface_cursor INTO g_cpa_csr;

      IF g_interface_cursor%NOTFOUND THEN
        CLOSE g_interface_cursor;
           IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'PO_ALL_NO_DRILLDOWN: '||SQLERRM);
           END IF;
           Fnd_message.set_name('PO','PO_ALL_NO_DRILLDOWN');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  l_document_type    := g_cpa_csr.document_type_code;
  l_document_subtype := g_cpa_csr.document_subtype;
  l_action           := g_cpa_csr.action;

  /* bug 10017321 : Fetching style_id from po_hedaers_interface and populating it in
     global variable g_style_id */
  BEGIN
     SELECT phi.style_id
       INTO g_style_id
       FROM po_headers_interface phi
      WHERE phi.interface_header_id=p_interface_header_id;

   EXCEPTION
     WHEN OTHERS THEN
        g_style_id := NULL;
   END;

	IF l_document_subtype = 'CONTRACT' THEN
		IF l_action = 'NEW' THEN
            g_progress := '501';
            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'Before calling po_sourcing_pvt.default_cpa');
            END IF;
    		-- Default the required fields in the record
			DEFAULT_CPA(
                        x_return_status       => l_return_status
                       );

            g_progress := '502';
            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'After calling po_sourcing_pvt.default_cpa');
            END IF;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

			-- Validate the required fields in the record
            g_progress := '503';
            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'Before calling po_sourcing_pvt.validate_cpa');
            END IF;

            VALIDATE_CPA(
                        x_return_status      => l_return_status
                        );

            g_progress := '504';
            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'After calling po_sourcing_pvt.validate_cpa');
            END IF;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

			-- Insert record in the po_headers table and add attachments and contract terms
            g_progress := '505';
            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'Before calling po_sourcing_pvt.insert_cpa');
            END IF;

            INSERT_CPA (
                       p_auction_header_id        => p_auction_header_id,
                       p_bid_number               => p_bid_number,
                       p_sourcing_k_doc_type      => p_sourcing_k_doc_type,
                       p_conterms_exist_flag      => p_conterms_exist_flag,
                       p_document_creation_method => p_document_creation_method,
                       x_document_id              => x_document_id,
                       x_document_number          => x_document_number,
                       x_return_status            => l_return_status
                       );

            g_progress := '506';
            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'After calling po_sourcing_pvt.insert_cpa');
            END IF;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

		ELSE
            g_progress := '507';
            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'Invalid Action in the interface table');
            END IF;
            Fnd_message.set_name('PO','PO_PDOI_INVALID_ACTION');
            Fnd_message.set_token( token  => 'VALUE'
                                 , VALUE => g_cpa_csr.action);
            FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
        END IF; -- End of l_action = 'NEW'
	ELSE
            g_progress := '508';
            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => g_progress,
                                  p_message  => 'Invalid Document Subtype Code in the interface table');
            END IF;
            Fnd_message.set_name('PO','PO_PDOI_INVALID_VALUE');
            Fnd_message.set_token( token  => 'COLUMN_NAME'
                                 , VALUE => 'Document Subtype');
            Fnd_message.set_token( token  => 'VALUE'
                                 , VALUE => 'CONTRACT');
            FND_MSG_PUB.Add;

     		RAISE FND_API.G_EXC_ERROR;
    END IF; -- End of l_document_type = 'CONTRACT'
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
         x_document_number := NULL;
         x_document_id := NULL;
         x_return_status := FND_API.G_RET_STS_ERROR;
         g_progress := '510';
         IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => 'Expected Error');
         END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_document_number := NULL;
         x_document_id := NULL;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         g_progress := '511';
         IF g_debug_unexp THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => 'Unexpected Error');
         END IF;
   WHEN OTHERS THEN
         x_document_number := NULL;
         x_document_id := NULL;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         g_progress := '512';
         IF g_debug_unexp THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => SQLERRM);
         END IF;

         FND_MSG_PUB.add_exc_msg(
                 p_pkg_name       => 'PO_SOURCING_PVT',
                 p_procedure_name => l_api_name,
                 p_error_text     => NULL);
END CREATE_CPA;


-------------------------------------------------------------------------------
--Start of Comments
--Name: DELETE_INTERFACE_HEADER
--Pre-reqs:
--  None
--Modifies:
--  po_headers_interface
--Locks:
--  None.
--Function:
--  This deletes the interface header row from interface table
--Parameters:
--IN:
--p_interface_header_id
--  The id that will be used to uniquely identify a row in the PO_HEADERS_INTERFACE table
--OUT:
--x_return_status
--   The standard OUT parameter giving return status of the API call.
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE DELETE_INTERFACE_HEADER (
    p_interface_header_id     IN  PO_HEADERS_INTERFACE.INTERFACE_HEADER_ID%TYPE,
    x_return_status           OUT NOCOPY    VARCHAR2
) IS
   l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_INTERFACE_HEADER';
BEGIN
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   DELETE po_headers_interface
   WHERE interface_header_id = p_interface_header_id;

   g_progress := '600';
   IF g_debug_stmt THEN
       PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                           p_token    => g_progress,
                           p_message  => 'No of Records deleted from PO_HEADERS_INTERFACE'||SQL%rowcount);
   END IF;
EXCEPTION
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       g_progress := '601';
       IF g_debug_unexp THEN
           PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                               p_token    => g_progress,
                               p_message  => SQLERRM);
       END IF;
       FND_MSG_PUB.add_exc_msg(
               p_pkg_name       => 'PO_SOURCING_PVT',
               p_procedure_name => l_api_name,
               p_error_text     => NULL);
END DELETE_INTERFACE_HEADER;


END PO_SOURCING_PVT;

/
