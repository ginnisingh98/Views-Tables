--------------------------------------------------------
--  DDL for Package Body PO_R12_CAT_UPG_DEF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_R12_CAT_UPG_DEF_PVT" AS
/* $Header: PO_R12_CAT_UPG_DEF_PVT.plb 120.7 2006/08/12 00:13:49 pthapliy noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_R12_CAT_UPG_DEF_PVT';
g_module_prefix CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';

g_debug BOOLEAN := PO_R12_CAT_UPG_DEBUG.is_logging_enabled;
g_err_num NUMBER := PO_R12_CAT_UPG_PVT.g_application_err_num;

-- BEGIN: Forward function declarations

PROCEDURE default_info_from_vendor
(
  p_key                        IN NUMBER,
  p_headers_rec                IN PO_R12_CAT_UPG_PVT.record_of_headers_type,
  x_invoice_currency_codes     OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR15,
  x_terms_ids                  OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
);

PROCEDURE default_vendor_sites
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
);

PROCEDURE default_info_from_vendor_site
(
  p_key                        IN NUMBER,
  p_headers_rec                IN PO_R12_CAT_UPG_PVT.record_of_headers_type,
  x_fob_lookup_codes           OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25,
  x_ship_via_lookup_codes      OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25,
  x_freight_terms_lookup_codes OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25,
  x_ship_to_location_ids       OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_bill_to_location_ids       OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_invoice_currency_codes     OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR15,
  x_terms_ids                  OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_pay_on_codes               OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25,
  x_shipping_controls          OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR30
);

PROCEDURE default_vendor_contact_info
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
);

PROCEDURE default_buyer
(
  p_key         IN NUMBER
, x_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
);

-- END: Forward function declarations

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_headers
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: Defaults a value in some columns.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Defaults the header level column values, if no value is given in the
--  interface tables.
--  This API should be called during the upgrade phase only.
--Parameters:
--IN OUT:
-- p_headers_rec
--  A record of plsql tables containing a batch of headers.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_headers
(
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_headers';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_vendor_site_ids              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_vendor_currency_codes        PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR15;
  l_vendor_terms_ids             PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_site_fob_lookup_codes        PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;
  l_site_ship_via_lookup_codes   PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;
  l_site_freight_terms_luc       PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;
  l_site_ship_to_location_ids    PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_site_bill_to_location_ids    PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_site_currency_codes          PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR15;
  l_site_terms_ids               PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_site_shipping_controls       PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR30;
  l_site_pay_on_codes            PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;

  l_vendor_contact_ids           PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_is_fixed_rate VARCHAR2(10);

  l_key PO_SESSION_GT.key%TYPE;
  i NUMBER;
  rate NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.interface_header_id.COUNT='||p_headers_rec.interface_header_id.COUNT); END IF;

  -- pick a new key from temp table which will be used in all default logic
  --l_key := PO_CORE_S.get_session_gt_nextval;
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key
  FROM DUAL;

  l_progress := '020';
  -- default information from vendor
  default_info_from_vendor
  (
    p_key                        => l_key,
    p_headers_rec                => p_headers_rec,
    x_invoice_currency_codes     => l_vendor_currency_codes,
    x_terms_ids                  => l_vendor_terms_ids
  );

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.interface_header_id.COUNT='||p_headers_rec.interface_header_id.COUNT); END IF;

  l_progress := '030';
  -- Default Vendor Site, if only 1 site exist for the vendor
  -- The vendor site id will be populated in the p_header_rec
  default_vendor_sites
  (
    p_key         => l_key,        -- IN
    p_headers_rec => p_headers_rec -- IN OUT
  );

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.interface_header_id.COUNT='||p_headers_rec.interface_header_id.COUNT); END IF;

  l_progress := '040';
  -- default information from vendor site
  default_info_from_vendor_site
  (
    p_key                        => l_key,
    p_headers_rec                => p_headers_rec,
    x_fob_lookup_codes           => l_site_fob_lookup_codes,
    x_ship_via_lookup_codes      => l_site_ship_via_lookup_codes,
    x_freight_terms_lookup_codes => l_site_freight_terms_luc,
    x_ship_to_location_ids       => l_site_ship_to_location_ids,
    x_bill_to_location_ids       => l_site_bill_to_location_ids,
    x_invoice_currency_codes     => l_site_currency_codes,
    x_terms_ids                  => l_site_terms_ids,
    x_pay_on_codes               => l_site_pay_on_codes,
    x_shipping_controls          => l_site_shipping_controls
  );

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.interface_header_id.COUNT='||p_headers_rec.interface_header_id.COUNT); END IF;

  l_progress := '050';
  -- default vendor contact information
  default_vendor_contact_info
  (
    p_key         => l_key,        -- IN
    p_headers_rec => p_headers_rec -- IN OUT
  );

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.interface_header_id.COUNT='||p_headers_rec.interface_header_id.COUNT); END IF;

  l_progress := '055';
  -- default buyer
  default_buyer
  (
    p_key         => l_key,        -- IN
    x_headers_rec => p_headers_rec -- IN OUT
  );

  l_progress := '060';
  -- set default value on a row base
  FOR i IN 1 .. p_headers_rec.vendor_id.COUNT
  LOOP
    l_progress := '070';
    IF (--p_headers_rec.has_errors(i) = 'Y' OR
        p_headers_rec.action(i) <> PO_R12_CAT_UPG_PVT.g_action_header_create) THEN
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Skipping rec#'||i||' has_errors='||p_headers_rec.has_errors(i)||'action='||p_headers_rec.action(i)); END IF;
      goto END_OF_HEADERS_LOOP;
    END IF;

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'i='||i); END IF;

    --p_headers_rec.po_header_id(i)                   := NULL; -- From sequence PO_HEADERS_S

    l_progress := '071';

    --p_headers_rec.agent_id(i)                     -- TODO: Open issue with PM
    p_headers_rec.document_type_code(i)             := 'PO'; -- Only present in interface table, not in txn table
    p_headers_rec.document_subtype(i)               := 'BLANKET'; -- TYPE_LOOKUP_CODE in txn tables
    p_headers_rec.last_update_date(i)               := sysdate; -- who column
    p_headers_rec.last_updated_by(i)                := FND_GLOBAL.user_id; -- who column

    l_progress := '072';
    --p_headers_rec.summary_flag(i)                   := 'N';  -- Key flexfield related, for future use. Not present in interface tables
    --p_headers_rec.enabled_flag(i)                   := 'Y';  -- Key flexfield related, for future use. Not present in interface tables
    --p_headers_rec.segment1(i)                     := NULL; -- will be populated in the end: Auto: From seq Manual: Open issue
    --p_headers_rec.segment2(i)                     := NULL; Not present in interface tables
    --p_headers_rec.segment3(i)                     := NULL;
    --p_headers_rec.segment4(i)                     := NULL;
    --p_headers_rec.segment5(i)                     := NULL;
    --p_headers_rec.start_date_active(i)            := NULL; -- Key Flexfield start date. Not present in interface tables
    --p_headers_rec.end_date_active(i)                := NULL; -- Key Flexfield start date. Not present in interface tables
    p_headers_rec.last_update_login(i)              := FND_GLOBAL.login_id; -- who column
    p_headers_rec.creation_date(i)                  := sysdate; -- who column
    p_headers_rec.created_by(i)                     := PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER; -- -12

    l_progress := '073';
    --p_headers_rec.vendor_id(i)                    -- Copy value from interface table
    --p_headers_rec.vendor_site_id(i)               -- Copy value from interface table. If NULL, default as in PDOI
    --p_headers_rec.vendor_contact_id(i)            -- Default as in PDOI (iP will not provide)
    --p_headers_rec.ship_to_location_id(i)          -- Default as in PDOI (iP will not provide)
    --p_headers_rec.bill_to_location_id(i)          -- Default as in PDOI (iP will not provide)
    --p_headers_rec.terms_id(i)                     -- Default as in PDOI (iP will not provide)
    --p_headers_rec.ship_via_lookup_code(i)         -- Default as in PDOI (iP will not provide)
    --p_headers_rec.fob_lookup_code(i)              -- Default as in PDOI (iP will not provide)
    --p_headers_rec.freight_terms_lookup_code(i)    -- Default as in PDOI (iP will not provide)
    --p_headers_rec.status_lookup_code(i)             := NULL; -- Only used for Quotations. Not present in interface tables
    --p_headers_rec.currency_code(i)                -- Copy value from interface table. If NULL, default as in PDOI
    --p_headers_rec.rate_type(i)                    -- Default as in PDOI (iP will not provide)
    --p_headers_rec.rate_date(i)                    -- Default as in PDOI (iP will not provide)
    --p_headers_rec.rate(i)                         -- Default as in PDOI (iP will not provide)
    p_headers_rec.from_header_id(i)                 := NULL;
    p_headers_rec.from_type_lookup_code(i)          := NULL;
    --p_headers_rec.start_date(i)                   -- Copy value from interface table
    --p_headers_rec.end_date(i)                     -- Copy value from interface table
    --p_headers_rec.blanket_total_amount(i)         -- Copy value from interface table
    p_headers_rec.approval_status(i)                := 'IN PROCESS'; -- AUTHORIZATION_STATUS in txn tables
    p_headers_rec.revision_num(i)                   := 0;
    p_headers_rec.revised_date(i)                   := sysdate;
    --p_headers_rec.approved_flag(i)                  := 'N'; Not present in interface tables
    p_headers_rec.approved_date(i)                  := NULL;
    --p_headers_rec.amount_limit(i)                 -- Copy value from interface table
    --p_headers_rec.min_release_amount(i)           -- Copy value from interface table
    --p_headers_rec.note_to_authorizer(i)             := NULL; -- Not present in interface tables
    p_headers_rec.note_to_vendor(i)                 := NULL;
    p_headers_rec.note_to_receiver(i)               := NULL;
    p_headers_rec.print_count(i)                    := 0;
    p_headers_rec.printed_date(i)                   := NULL;

    l_progress := '074';
    --p_headers_rec.vendor_order_num(i)               := NULL; Not present in interface tables
    p_headers_rec.confirming_order_flag(i)          := 'N';
    --p_headers_rec.comments(i)                       := NULL;
    p_headers_rec.reply_date(i)                     := NULL;
    --p_headers_rec.reply_method_lookup_code(i)       := NULL; Not present in interface tables
    p_headers_rec.rfq_close_date(i)                 := NULL;
    --p_headers_rec.quote_type_lookup_code(i)         := NULL; Not present in interface tables
    --p_headers_rec.quotation_class_code(i)           := NULL; Not present in interface tables
    --p_headers_rec.quote_warning_delay_unit(i)       := NULL; Not present in interface tables
    p_headers_rec.quote_warning_delay(i)            := NULL;
    --p_headers_rec.quote_vendor_quote_number(i)      := NULL; Not present in interface tables
    p_headers_rec.acceptance_required_flag(i)       := 'N';
    p_headers_rec.acceptance_due_date(i)            := NULL;
    p_headers_rec.closed_date(i)                    := NULL;
    --p_headers_rec.user_hold_flag(i)                 := NULL; Not present in interface tables
    p_headers_rec.approval_required_flag(i)         := NULL;
    --p_headers_rec.cancel_flag(i)                    := 'N'; Not present in interface tables
    --p_headers_rec.firm_status_lookup_code(i)        := 'N'; Not present in interface tables
    --p_headers_rec.firm_date(i)                      := NULL; Not present in interface tables
    p_headers_rec.frozen_flag(i)                    := 'N';

    l_progress := '075';
    p_headers_rec.attribute_category(i)             := NULL;
    p_headers_rec.attribute1(i)                     := NULL;
    p_headers_rec.attribute2(i)                     := NULL;
    p_headers_rec.attribute3(i)                     := NULL;
    p_headers_rec.attribute4(i)                     := NULL;
    p_headers_rec.attribute5(i)                     := NULL;
    p_headers_rec.attribute6(i)                     := NULL;
    p_headers_rec.attribute7(i)                     := NULL;
    p_headers_rec.attribute8(i)                     := NULL;
    p_headers_rec.attribute9(i)                     := NULL;
    p_headers_rec.attribute10(i)                    := NULL;
    p_headers_rec.attribute11(i)                    := NULL;
    p_headers_rec.attribute12(i)                    := NULL;
    p_headers_rec.attribute13(i)                    := NULL;
    p_headers_rec.attribute14(i)                    := NULL;
    p_headers_rec.attribute15(i)                    := NULL;
    p_headers_rec.closed_code(i)                    := NULL;
    p_headers_rec.ussgl_transaction_code(i)         := NULL;
    l_progress := '076';

    --p_headers_rec.government_context(i)             := NULL; Not present in interface tables
    p_headers_rec.request_id(i) := FND_GLOBAL.conc_request_id;  -- NUMBER iPs conc program request id
    p_headers_rec.program_application_id(i) := FND_GLOBAL.prog_appl_id;  -- NUMBER
    p_headers_rec.program_id(i) := FND_GLOBAL.conc_program_id;  -- NUMBER
    p_headers_rec.program_update_date(i) := sysdate;  -- DATE

    l_progress := '077';
    --p_headers_rec.org_id(i)                       -- Copy value from interface table.
    --p_headers_rec.supply_agreement_flag(i)          := 'N'; Not present in interface tables
    --p_headers_rec.edi_processed_flag(i)             := NULL; Not present in interface tables
    --p_headers_rec.edi_processed_status(i)           := NULL; Not present in interface tables
    --p_headers_rec.global_attribute_category(i)      := NULL; Not present in interface tables
    --p_headers_rec.global_attribute1(i)              := NULL; Not present in interface tables
    --p_headers_rec.global_attribute2(i)              := NULL; Not present in interface tables
    --p_headers_rec.global_attribute3(i)              := NULL; Not present in interface tables
    --p_headers_rec.global_attribute4(i)              := NULL; Not present in interface tables
    --p_headers_rec.global_attribute5(i)              := NULL; Not present in interface tables
    --p_headers_rec.global_attribute6(i)              := NULL; Not present in interface tables
    --p_headers_rec.global_attribute7(i)              := NULL; Not present in interface tables
    --p_headers_rec.global_attribute8(i)              := NULL; Not present in interface tables
    --p_headers_rec.global_attribute9(i)              := NULL; Not present in interface tables
    --p_headers_rec.global_attribute10(i)             := NULL; Not present in interface tables
    --p_headers_rec.global_attribute11(i)             := NULL; Not present in interface tables
    --p_headers_rec.global_attribute12(i)             := NULL; Not present in interface tables
    --p_headers_rec.global_attribute13(i)             := NULL; Not present in interface tables
    --p_headers_rec.global_attribute14(i)             := NULL; Not present in interface tables
    --p_headers_rec.global_attribute15(i)             := NULL; Not present in interface tables
    --p_headers_rec.global_attribute16(i)             := NULL; Not present in interface tables
    --p_headers_rec.global_attribute17(i)             := NULL; Not present in interface tables
    --p_headers_rec.global_attribute18(i)             := NULL; Not present in interface tables
    --p_headers_rec.global_attribute19(i)             := NULL; Not present in interface tables
    --p_headers_rec.global_attribute20(i)             := NULL; Not present in interface tables
    p_headers_rec.interface_source_code(i)          := NULL;
    p_headers_rec.reference_num(i)                  := NULL;
    --p_headers_rec.wf_item_type(i)                   := NULL; Not present in interface tables
    --p_headers_rec.wf_item_key(i)                    := NULL; Not present in interface tables
    --p_headers_rec.mrc_rate_type(i)                  := NULL; Not present in interface tables
    --p_headers_rec.mrc_rate_date(i)                  := NULL; Not present in interface tables
    --p_headers_rec.mrc_rate(i)                       := NULL; Not present in interface tables
    p_headers_rec.pcard_id(i)                       := NULL;

    l_progress := '078';
    --p_headers_rec.price_update_tolerance(i)         := NULL; Not present in interface tables
    --p_headers_rec.pay_on_code(i)                  -- Default as in PDOI (iP will not provide)
    --p_headers_rec.xml_flag(i)                       := NULL; Not present in interface tables
    --p_headers_rec.xml_send_date(i)                  := NULL; Not present in interface tables
    --p_headers_rec.xml_change_send_date(i)           := NULL; Not present in interface tables
    p_headers_rec.global_agreement_flag(i)          := 'Y';
    --p_headers_rec.consigned_consumption_flag(i)     := NULL; Not present in interface tables
    --p_headers_rec.cbc_accounting_date(i)            := NULL; Not present in interface tables
    p_headers_rec.consume_req_demand_flag(i)        := NULL;
    --p_headers_rec.change_requested_by(i)            := NULL; Not present in interface tables
    --p_headers_rec.shipping_control(i)             -- Default as in PDOI (iP will not provide)
    --p_headers_rec.conterms_exist_flag(i)            := NULL; Not present in interface tables
    --p_headers_rec.conterms_articles_upd_date(i)     := NULL; Not present in interface tables
    --p_headers_rec.conterms_deliv_upd_date(i)        := NULL; Not present in interface tables
    --p_headers_rec.pending_signature_flag(i)         := NULL; Not present in interface tables

    --p_headers_rec.change_summary(i)                 := NULL;-- Not present in 11.5.9.
    --p_headers_rec.encumbrance_required_flag(i)      := NULL;-- Not present in 11.5.9.

    l_progress := '079';
    --p_headers_rec.document_creation_method(i)       := NULL; -- Not present in 11.5.9. For 11.5.10, default CATALOG_MIGRATION (Open issue)  Not present in interface tables
    --p_headers_rec.submit_date(i)                    := NULL; -- Not present in 11.5.9. For 11.5.10, default NULL (Open issue) Not present in interface tables
    --p_headers_rec.supplier_notif_method(i)          := NULL; -- Not present in 11.5.9, 11.5.10 Not present in interface tables
    --p_headers_rec.fax(i)                            := NULL; -- Not present in 11.5.9, 11.5.10 Not present in interface tables
    --p_headers_rec.email_address(i)                  := NULL; -- Not present in 11.5.9, 11.5.10 Not present in interface tables
    --p_headers_rec.retro_price_comm_updates_flag(i)  := NULL; -- Not present in 11.5.9, 11.5.10 Not present in interface tables
    --p_headers_rec.retro_price_apply_updates_flag(i) := NULL; -- Not present in 11.5.9, 11.5.10 Not present in interface tables
    --p_headers_rec.update_sourcing_rules_flag(i)     := NULL; -- Not present in 11.5.9, 11.5.10 Not present in interface tables
    --p_headers_rec.auto_sourcing_flag(i)             := NULL; -- Not present in 11.5.9, 11.5.10 Not present in interface tables
    --p_headers_rec.created_language(i)             -- Copy value from interface table.
    --p_headers_rec.cpa_reference(i)                -- Copy value from interface table.
    --p_headers_rec.ip_category_id(i)               -- Copy value from interface table.
    --p_headers_rec.last_updated_program(i)             := 'CATALOG_MIGRATION'; -- TODO: Confirm with Sareddy. Not present in interface tables
    --p_headers_rec.style_id(i)                       := NULL; -- Not present in 11.5.9, 11.5.10 Not present in interface tables

    l_progress := '080';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'PO_R12_CAT_UPG_PVT.g_sys.fob_lookup_code='||PO_R12_CAT_UPG_PVT.g_sys.fob_lookup_code); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_site_fob_lookup_codes(i)='||l_site_fob_lookup_codes(i)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.fob(i)='||p_headers_rec.fob(i)); END IF;

    p_headers_rec.fob(i) :=
        NVL(p_headers_rec.fob(i),
            NVL(l_site_fob_lookup_codes(i),
                PO_R12_CAT_UPG_PVT.g_sys.fob_lookup_code));

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.fob(i)='||p_headers_rec.fob(i)); END IF;

    l_progress := '082';
    -- default freight_carrier(ship_via_lookup_code)
    p_headers_rec.freight_carrier(i) :=
        NVL(p_headers_rec.freight_carrier(i),
            NVL(l_site_ship_via_lookup_codes(i),
                PO_R12_CAT_UPG_PVT.g_sys.ship_via_lookup_code));

    l_progress := '083';
    -- default freight_terms
    p_headers_rec.freight_terms(i) :=
        NVL(p_headers_rec.freight_terms(i),
            NVL(l_site_freight_terms_luc(i),
                PO_R12_CAT_UPG_PVT.g_sys.freight_terms_lookup_code));

    l_progress := '084';
    -- default ship_to_location_id
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'PO_R12_CAT_UPG_PVT.g_sys.ship_to_location_id='||PO_R12_CAT_UPG_PVT.g_sys.ship_to_location_id); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_site_ship_to_location_ids(i)='||l_site_ship_to_location_ids(i)); END IF;
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.ship_to_location_id(i)='||p_headers_rec.ship_to_location_id(i)); END IF;

    p_headers_rec.ship_to_location_id(i) :=
        NVL(p_headers_rec.ship_to_location_id(i),
            NVL(l_site_ship_to_location_ids(i),
                PO_R12_CAT_UPG_PVT.g_sys.ship_to_location_id));

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_headers_rec.ship_to_location_id(i)=<'||p_headers_rec.ship_to_location_id(i)||'>'); END IF;

    l_progress := '085';
    -- default bill_to_location_id
    p_headers_rec.bill_to_location_id(i) :=
        NVL(p_headers_rec.bill_to_location_id(i),
            NVL(l_site_bill_to_location_ids(i),
                  PO_R12_CAT_UPG_PVT.g_sys.bill_to_location_id));

    l_progress := '086';
    -- default currency_code
    p_headers_rec.currency_code(i) :=
        NVL(p_headers_rec.currency_code(i),
            NVL(l_site_currency_codes(i),
                NVL(l_vendor_currency_codes(i),
                    PO_R12_CAT_UPG_PVT.g_sys.currency_code)));

    l_progress := '087';
    -- default terms_id
    p_headers_rec.terms_id(i) :=
        NVL(p_headers_rec.terms_id(i),
            NVL(l_site_terms_ids(i),
                l_vendor_terms_ids(i)));

    l_progress := '088';
    -- default shipping_control
    p_headers_rec.shipping_control(i) :=
        NVL(p_headers_rec.shipping_control(i),
            l_site_shipping_controls(i));

    l_progress := '089';
    -- default pay_on_code
    p_headers_rec.pay_on_code(i) := l_site_pay_on_codes(i);

    l_progress := '090';
    -- default rate info after currency default
    IF (p_headers_rec.currency_code(i) <> PO_R12_CAT_UPG_PVT.g_sys.currency_code)
    THEN
      l_progress := '100';
      -- deafult rate_date
      p_headers_rec.rate_date(i) := sysdate;

      l_progress := '110';
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Calling GL_CURRENCY_API.is_fixed_rate()'); END IF;
      -- default rate_type
      l_is_fixed_rate := 'N';
      BEGIN
        l_is_fixed_rate := GL_CURRENCY_API.is_fixed_rate
                           (
                             x_from_currency  => p_headers_rec.currency_code(i),
                             x_to_currency    => PO_R12_CAT_UPG_PVT.g_sys.currency_code,
                             x_effective_date => p_headers_rec.rate_date(i)
                           );
      EXCEPTION
        WHEN OTHERS THEN
          IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception from GL_CURRENCY_API.is_fixed_rate(): '|| SQLERRM(SQLCODE)); END IF;
          -- Mark this record as errored and continue. Do not raise the exception
          -- because we want to procss as many records as possible.
          p_headers_rec.has_errors(i) := 'Y';

          -- Add error message into INTERFACE_ERRORS table
          -- ICX_CAT_ERR_IN_GL_CURR_API
          -- "An error occurred in the call to API_NAME while retrieving the currency conversion rate."
          PO_R12_CAT_UPG_UTL.add_fatal_error(
                      p_interface_header_id => p_headers_rec.interface_header_id(i),
                      --p_error_message_name  => 'PO_CAT_UPG_GL_API1_EXCEPTION',
                      p_error_message_name  => 'ICX_CAT_ERR_IN_GL_CURR_API',
                      p_table_name          => 'PO_HEADERS_INTERFACE',
                      p_column_name         => 'API_NAME',
                      p_column_value        => 'GL_CURRENCY_API.is_fixed_rate',
                      p_token1_name         => 'API_NAME',
                      p_token1_value        => 'GL_CURRENCY_API.is_fixed_rate'
                      );
      END;

      IF (p_headers_rec.has_errors(i) <> 'Y' AND
          l_is_fixed_rate = 'Y') THEN
        p_headers_rec.rate_type_code(i) := 'EMU FIXED';
      ELSE
        p_headers_rec.rate_type_code(i) :=
               NVL(p_headers_rec.rate_type_code(i),
                   PO_R12_CAT_UPG_PVT.g_sys.default_rate_type);
      END IF;

      l_progress := '120';
      -- default rate
      IF (p_headers_rec.has_errors(i) <> 'Y' AND
          (p_headers_rec.rate(i) IS NULL OR
           p_headers_rec.rate_type_code(i) = 'EMU FIXED')) THEN
        l_progress := '130';
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Calling GL_CURRENCY_API.get_rate()'); END IF;
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'x_set_of_books_id='||PO_R12_CAT_UPG_PVT.g_sys.sob_id); END IF;
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'x_from_currency='||p_headers_rec.currency_code(i)); END IF;
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'x_conversion_date='||p_headers_rec.rate_date(i)); END IF;
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'x_conversion_type='||p_headers_rec.rate_type_code(i)); END IF;

        BEGIN
          rate := NULL; -- Bug 5461235
          rate := GL_CURRENCY_API.get_rate
                  (
                    x_set_of_books_id => PO_R12_CAT_UPG_PVT.g_sys.sob_id,
                    x_from_currency   => p_headers_rec.currency_code(i),
                    x_conversion_date => p_headers_rec.rate_date(i),
                    x_conversion_type => p_headers_rec.rate_type_code(i)
                  );
          -- Bug 5461235: Start
          l_progress := '132';
          IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'GL_CURRENCY_API.get_rate() returned rate='||rate); END IF;

          l_progress := '134';
          IF (rate IS NULL) THEN
            IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'GL_CURRENCY_API.get_rate() returned rate as NULL, raising NO_RATE exception.'); END IF;
            RAISE GL_CURRENCY_API.NO_RATE;
          END IF;
          -- Bug 5461235: End
        EXCEPTION
          -- Bug 5461235: Start
          WHEN GL_CURRENCY_API.NO_RATE THEN
            l_progress := '136';
            IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'GL_CURRENCY_API.get_rate() throws GL_CURRENCY_API.NO_RATE exception'); END IF;
            p_headers_rec.has_errors(i) := 'Y';
            -- Add error message into INTERFACE_ERRORS table
            -- ICX_CAT_RATE_REQD
            -- "There is no rate for the rate date and type default combination."
            PO_R12_CAT_UPG_UTL.add_fatal_error(
                        p_interface_header_id => p_headers_rec.interface_header_id(i),
                        p_error_message_name  => 'ICX_CAT_RATE_REQD',
                        p_table_name          => 'PO_HEADERS_INTERFACE',
                        p_column_name         => 'CURRENCY_CODE',
                        p_column_value        => p_headers_rec.currency_code(i),
                        p_token1_name         => 'API_NAME',
                        p_token1_value        => 'GL_CURRENCY_API.get_rate'
                        );
          WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
            l_progress := '138';
            IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'GL_CURRENCY_API.get_rate() throws GL_CURRENCY_API.INVALID_CURRENCY exception'); END IF;
            p_headers_rec.has_errors(i) := 'Y';
            -- Add error message into INTERFACE_ERRORS table
            -- ICX_CAT_INVALID_CURRENCY
            -- "Default currency code is inactive or invalid."
            PO_R12_CAT_UPG_UTL.add_fatal_error(
                        p_interface_header_id => p_headers_rec.interface_header_id(i),
                        p_error_message_name  => 'ICX_CAT_INVALID_CURRENCY',
                        p_table_name          => 'PO_HEADERS_INTERFACE',
                        p_column_name         => 'CURRENCY_CODE',
                        p_column_value        => p_headers_rec.currency_code(i),
                        p_token1_name         => 'API_NAME',
                        p_token1_value        => 'GL_CURRENCY_API.get_rate'
                        );
          -- Bug 5461235: End
          WHEN OTHERS THEN
            l_progress := '139';
            IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception from GL_CURRENCY_API.get_rate(): '|| SQLERRM(SQLCODE)); END IF;
            -- Mark this record as errored and continue. Do not raise the exception
            -- because we want to procss as many records as possible.
            p_headers_rec.has_errors(i) := 'Y';

            -- Add error message into INTERFACE_ERRORS table
            -- ICX_CAT_ERR_IN_GL_CURR_API
            -- "An error occurred in the call to API_NAME while retrieving the currency conversion rate."
            PO_R12_CAT_UPG_UTL.add_fatal_error(
                        p_interface_header_id => p_headers_rec.interface_header_id(i),
                        --p_error_message_name  => 'PO_CAT_UPG_GL_API2_EXCEPTION',
                        p_error_message_name  => 'ICX_CAT_ERR_IN_GL_CURR_API',
                        p_table_name          => 'PO_HEADERS_INTERFACE',
                        p_column_name         => 'API_NAME',
                        p_column_value        => 'GL_CURRENCY_API.get_rate',
                        p_token1_name         => 'API_NAME',
                        p_token1_value        => 'GL_CURRENCY_API.get_rate'
                        );
        END; -- Exception block around GL_CURRENCY_API.get_rate API

        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Return Value, rate='||rate); END IF;

        l_progress := '140';
        p_headers_rec.rate(i) := ROUND(rate, 15);
      END IF; -- IF (p_headers_rec.has_errors(i) <> 'Y' AND
              --    (p_headers_rec.rate(i) IS NULL OR
              --     p_headers_rec.rate_type_code(i) = 'EMU FIXED'))

    END IF; -- IF (p_headers_rec.currency_code(i) <> g_sys.currency_code)

    <<END_OF_HEADERS_LOOP>>
    l_progress := '150';
  END LOOP;

  l_progress := '160';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'|| ','|| SQLERRM(SQLCODE)); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_headers;

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_vendor
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: Defaults a value in some columns.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Defaults the following header level fields from vendor:
--
--           invoice_currency_code
--           terms_id
--
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--p_headers_rec
--  A record of plsql tables containing a batch of headers. The value of
--  vendor_id will be picked up from this record.
--OUT:
--x_invoice_currency_codes
--  A pl/sql table in which the default values of invoice_currency_codes
--  would be returned.
--x_terms_ids
--  A pl/sql table in which the default values of terms_ids
--  would be returned.
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_info_from_vendor
(
  p_key                        IN NUMBER,
  p_headers_rec                IN PO_R12_CAT_UPG_PVT.record_of_headers_type,
  x_invoice_currency_codes     OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR15,
  x_terms_ids                  OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_info_from_vendor';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_currency_codes        PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR15;
  l_terms_ids             PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes               PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(l_size);

  l_progress := '020';
  -- SQL What: Get vendor related info into session GT table
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: vendor_id
  FORALL i IN 1 .. p_headers_rec.vendor_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              char1,
                              num2)
    SELECT p_key,
           l_subscript_array(i),
           vendor.invoice_currency_code,
           vendor.terms_id
    FROM   po_vendors vendor
    WHERE  vendor.vendor_id = p_headers_rec.vendor_id(i)
    AND    p_headers_rec.vendor_id(i) IS NOT NULL
    --AND    p_headers_rec.has_errors(i) = 'N'
    AND    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, char1, num2
  BULK COLLECT INTO l_indexes, l_currency_codes, l_terms_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  FOR i IN 1 .. p_headers_rec.vendor_id.COUNT
  LOOP
    x_invoice_currency_codes(i) := NULL;
    x_terms_ids(i) := NULL;
  END LOOP;

  l_progress := '040';
  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);

    x_invoice_currency_codes(l_index) := l_currency_codes(i);
    x_terms_ids(l_index) := l_terms_ids(i);
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_info_from_vendor;

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_vendor_sites
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: Defaults a value in some columns.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- Gets the default vendor_site_id if the site_id is NULL in the interface table.
-- The site would default only if there is exactly 1 site for the given vendor.
--
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. The value of
--  vendor_id will be picked up from this record. The default values of
--  vendor site will be written in the tables in this record.
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_vendor_sites
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_vendor_sites';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_vendor_site_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes         PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_index NUMBER;
  i NUMBER;

  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.vendor_site_id.COUNT);

  l_progress := '020';
  -- SQL What: Get the default vendor_site_id if the site_id is NULL in the
  --           interface table. The site would default only if there is exactly
  --           1 site for the given vendor.
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: vendor_id
  FORALL i IN 1 .. p_headers_rec.vendor_id.COUNT
    INSERT INTO PO_SESSION_GT(key, num1, num2, num3)
    SELECT p_key,
           l_subscript_array(i),
           min(vendor_site.vendor_site_id),
           vendor_site.vendor_id
    FROM   po_vendor_sites_all vendor_site
    WHERE  p_headers_rec.vendor_id(i) IS NOT NULL
    AND    p_headers_rec.vendor_site_id(i) IS NULL
    --AND    p_headers_rec.has_errors(i) = 'N'
    AND    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create
    AND    vendor_site.vendor_id = p_headers_rec.vendor_id(i)
    AND    vendor_site.purchasing_site_flag = 'Y'
    AND    TRUNC(sysdate) < nvl(vendor_site.inactive_date, TRUNC(sysdate + 1))
    AND    NVL(vendor_site.rfq_only_site_flag, 'N') <> 'Y'
    GROUP BY vendor_site.vendor_id
    HAVING count(vendor_site.vendor_site_id) = 1;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1,
            num2
  BULK COLLECT INTO l_indexes, l_vendor_site_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.vendor_site_id(l_index) := l_vendor_site_ids(i);
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_vendor_sites;

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_vendor_site
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: Defaults a value in some columns.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Defaults the following header level fields from vendor:
--
--           fob_lookup_code
--           ship_via_lookup_code
--           freight_terms_lookup_code
--           ship_to_location_id
--           bill_to_location_id
--           invoice_currency_code
--           terms_id
--           pay_on_codes
--           shipping_controls
--
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. The value of
--  vendor_id will be picked up from this record. The default values from
--  vendor site will be written in the tables in this record.
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_info_from_vendor_site
(
  p_key                        IN NUMBER,
  p_headers_rec                IN PO_R12_CAT_UPG_PVT.record_of_headers_type,
  x_fob_lookup_codes           OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25,
  x_ship_via_lookup_codes      OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25,
  x_freight_terms_lookup_codes OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25,
  x_ship_to_location_ids       OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_bill_to_location_ids       OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_invoice_currency_codes     OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR15,
  x_terms_ids                  OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_pay_on_codes               OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25,
  x_shipping_controls          OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR30
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_info_from_vendor_site';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_fob_lookup_codes      PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;
  l_ship_via_lookup_codes PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;
  l_freight_terms_luc     PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;
  l_ship_to_location_ids  PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_bill_to_location_ids  PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_currency_codes        PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR15;
  l_terms_ids             PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_shipping_controls     PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR30;
  l_pay_on_codes          PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;
  l_indexes               PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_index NUMBER;
  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.vendor_site_id.COUNT);

  l_progress := '020';
  -- SQL What: Get vendor site related info into session GT table
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: vendor_site_id
  FORALL i IN 1 .. p_headers_rec.vendor_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              char1,
                              char2,
                              char3,
                              num2,
                              num3,
                              char4,
                              num4,
                              char5,
                              index_char1)
    SELECT p_key,
           l_subscript_array(i),
           vendor_site.fob_lookup_code,
           vendor_site.ship_via_lookup_code,
           vendor_site.freight_terms_lookup_code,
           vendor_site.ship_to_location_id,
           vendor_site.bill_to_location_id,
           vendor_site.invoice_currency_code,
           vendor_site.terms_id,
           vendor_site.pay_on_code,
           vendor_site.shipping_control -- (not present in 11.5.9)
    FROM   po_vendor_sites_all vendor_site
    WHERE  p_headers_rec.vendor_id(i) IS NOT NULL
    AND    p_headers_rec.vendor_site_id(i) IS NOT NULL
    --AND    p_headers_rec.has_errors(i) = 'N'
    AND    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create
    AND    vendor_site.vendor_site_id = p_headers_rec.vendor_site_id(i)
    AND    vendor_site.purchasing_site_flag = 'Y'
    AND    TRUNC(sysdate) < nvl(vendor_site.inactive_date, TRUNC(sysdate + 1))
    AND    NVL(vendor_site.rfq_only_site_flag, 'N') <> 'Y';

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1,
            char1,
            char2,
            char3,
            num2,
            num3,
            char4,
            num4,
            char5,
            index_char1
  BULK COLLECT INTO l_indexes, l_fob_lookup_codes, l_ship_via_lookup_codes,
                    l_freight_terms_luc, l_ship_to_location_ids,
                    l_bill_to_location_ids, l_currency_codes, l_terms_ids,
                    l_pay_on_codes, l_shipping_controls;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  FOR i IN 1 .. p_headers_rec.vendor_id.COUNT
  LOOP
    x_fob_lookup_codes(i) := NULL;
    x_ship_via_lookup_codes(i) := NULL;
    x_freight_terms_lookup_codes(i) := NULL;
    x_ship_to_location_ids(i) := NULL;
    x_bill_to_location_ids(i) := NULL;
    x_invoice_currency_codes(i) := NULL;
    x_terms_ids(i) := NULL;
    x_pay_on_codes(i) := NULL;
    x_shipping_controls(i) := NULL;
  END LOOP;

  l_progress := '040';
  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);

    x_fob_lookup_codes(l_index) := l_fob_lookup_codes(i);
    x_ship_via_lookup_codes(l_index) := l_ship_via_lookup_codes(i);
    x_freight_terms_lookup_codes(l_index) := l_freight_terms_luc(i);
    x_ship_to_location_ids(l_index) := l_ship_to_location_ids(i);
    x_bill_to_location_ids(l_index) := l_bill_to_location_ids(i);
    x_invoice_currency_codes(l_index) := l_currency_codes(i);
    x_terms_ids(l_index) := l_terms_ids(i);
    x_pay_on_codes(l_index) := l_pay_on_codes(i);
    x_shipping_controls(l_index) := l_shipping_controls(i);
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_info_from_vendor_site;

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_vendor_contact_info
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: Defaults a value in some columns.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Defaults the vendor contact id from vendor site.
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. The value of
--  vendor_site_id will be picked up from this record. The default values
--  of vendor_contact_id will be written in the tables in this record.
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_vendor_contact_info
(
  p_key         IN NUMBER,
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_vendor_contact_info';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_headers_rec.interface_header_id.COUNT;

  l_contact_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes     PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_index NUMBER;

  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_headers_rec.vendor_site_id.COUNT);

  l_progress := '020';
  -- SQL What: Get vendor contact id into session GT table
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: vendor_site_id
  FORALL i IN 1 .. p_headers_rec.vendor_site_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2,
                              num3)
    SELECT p_key,
           l_subscript_array(i),
           min(pvc.vendor_contact_id),
           pvc.vendor_site_id
    FROM   po_vendor_contacts pvc
    WHERE  p_headers_rec.vendor_id(i) IS NOT NULL
    AND    p_headers_rec.vendor_site_id(i) IS NOT NULL
    AND    p_headers_rec.vendor_contact_id(i) IS NULL
    --AND    p_headers_rec.has_errors(i) = 'N'
    AND    p_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create
    AND    pvc.vendor_site_id = p_headers_rec.vendor_site_id(i)
    AND    TRUNC(sysdate) < nvl(pvc.inactive_date, TRUNC(sysdate + 1))
    GROUP BY pvc.vendor_site_id
    HAVING count(pvc.vendor_contact_id) = 1;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2
  BULK COLLECT INTO l_indexes, l_contact_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    p_headers_rec.vendor_contact_id(l_index) := l_contact_ids(i);
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_vendor_contact_info;

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_buyer
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--  The defaulting of vendor/site and currency has already happenned.
--Modifies:
--  a) Input pl/sql table: Defaults a value in some columns.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- Gets the default buyer (agent_id) if the agent_id is NULL in the interface table.
-- The defaulting rules are as follows:
-- 1) Get the buyer from the referenced CPA
-- 2) For those headers that do not have any CPA reference, try to source
--    a document to obtain a buyer. The sourcing rule will look for
--    the most recent created document in any status. The matching
--    will be based on supplier, supplier site, currency and OU. It
--    will follow the order below:
--             a.  Matching BPA Header
--             b.  Matching CPA
--             c.  Matching Standard PO
-- 3) If there is no CPA reference, and no source doc is found,
--    then get the latest buyer created for the current business group.
--
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--p_headers_rec
--  A record of plsql tables containing a batch of headers. The value of
--  vendor_id, site_id, currency_code, org_id, cpa_reference will be picked up
--  from this record. The default values of agent_id will be written in the
--  tables in this record.
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_buyer
(
  p_key         IN NUMBER
, x_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_buyer';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_agent_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes   PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_index NUMBER;

  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(x_headers_rec.po_header_id.COUNT);

  l_progress := '020';
  -- SQL What: Get the buyer from the referenced CPA
  -- SQL Why : It will be used to populate the OUT parameters (to default the
  --           agent_id into the new GBPA)
  -- SQL Join: segment1, org_id
  FORALL i IN 1 .. x_headers_rec.po_header_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2)
    SELECT p_key,
           l_subscript_array(i),
           POH.agent_id
    FROM   PO_HEADERS_ALL POH
    WHERE  POH.po_header_id = x_headers_rec.cpa_reference(i)
    AND    x_headers_rec.cpa_reference(i) IS NOT NULL
    AND    x_headers_rec.agent_id(i) IS NULL
    --AND    x_headers_rec.has_errors(i) = 'N'
    AND    x_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create
    AND    EXISTS
            (SELECT 'Its a valid buyer'
             FROM PO_BUYERS_VAL_V VALID_BUYER
             WHERE VALID_BUYER.employee_id = POH.agent_id);

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2
  BULK COLLECT INTO l_indexes, l_agent_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    x_headers_rec.agent_id(l_index) := l_agent_ids(i);
  END LOOP;

  l_progress := '050';
  -- SQL What: For data that does not have any CPA reference, try to source
  --           a document to obtain a buyer. The sourcing rule will look for
  --           the most recent created document in any status. The matching
  --           will be based on supplier, supplier site, currency and OU. It
  --           will follow the order below:
  --                 1.  Matching BPA Header
  --                 2.  Matching CPA
  --                 3.  Matching Standard PO
  -- SQL Why : It will be used to populate the OUT parameters (to default the
  --           agent_id into the new GBPA)
  -- SQL Join: vendor_id, vendor_site_id, currency_code, org_id, type_lookup_code
  FORALL i IN 1 .. x_headers_rec.po_header_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2)
    SELECT p_key,
           l_subscript_array(i),
           SUB_QUERY.agent_id
    FROM   (
            SELECT agent_id
            FROM
             (SELECT POH.agent_id
              FROM PO_HEADERS_ALL POH
              WHERE POH.vendor_id = x_headers_rec.vendor_id(i)
                AND POH.vendor_site_id = x_headers_rec.vendor_site_id(i)
                AND POH.currency_code = x_headers_rec.currency_code(i)
                AND POH.org_id = x_headers_rec.org_id(i)
                AND POH.type_lookup_code IN ('BLANKET', 'CONTRACT', 'STANDARD')
                AND EXISTS
                      (SELECT 'Its a valid buyer'
                       FROM PO_BUYERS_VAL_V VALID_BUYER
                       WHERE VALID_BUYER.employee_id = POH.agent_id)
              ORDER BY
                DECODE(POH.type_lookup_code,
                       'BLANKET',  1,
                       'CONTRACT', 2,
                       'STANDARD', 3) ASC,
                POH.creation_date DESC)
            WHERE rownum = 1
           ) SUB_QUERY
    WHERE  x_headers_rec.agent_id(i) IS NULL
    --AND    x_headers_rec.has_errors(i) = 'N'
    AND    x_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '060';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2
  BULK COLLECT INTO l_indexes, l_agent_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '070';
  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    x_headers_rec.agent_id(l_index) := l_agent_ids(i);
  END LOOP;

  l_progress := '080';
  -- SQL What: If there is no CPA reference, and no source doc is found,
  --           then get the latest buyer created for the current business group.
  -- SQL Why : It will be used to populate the OUT parameters (to default the
  --           agent_id into the new GBPA)
  -- SQL Join: org_id, business_group_id, agent_id

  -- Note: In this query, we need the sub query because the view PO_BUYERS_VAL_V
  -- does not have the column CREATION_DATE, on which we want to sort.
  -- Bug#5389286 use PER_EMPLOYEES_CURRENT_X instead of POBUYERS_VAL_V
  --             and collapsed 2 subqueries into 1 subquery to get newest valid
  --             buyer in the current business group
  FORALL i IN 1 .. x_headers_rec.po_header_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2)
    SELECT p_key,
           l_subscript_array(i),
           SUB_QUERY.agent_id
    FROM   (
            SELECT agent_id
            FROM
            (
              SELECT BUYER.agent_id
              FROM PO_AGENTS BUYER, PER_EMPLOYEES_CURRENT_X HRE,
                   HR_ALL_ORGANIZATION_UNITS HROU
              WHERE HRE.EMPLOYEE_ID = BUYER.AGENT_ID
                AND SYSDATE BETWEEN NVL(BUYER.START_DATE_ACTIVE, SYSDATE-1)
                                AND NVL(BUYER.END_DATE_ACTIVE, SYSDATE+1)
                AND HROU.organization_id = x_headers_rec.org_id(i)
                AND HROU.business_group_id = HRE.business_group_id
              ORDER BY BUYER.creation_date DESC
            )
            WHERE rownum = 1
           ) SUB_QUERY
    WHERE  x_headers_rec.agent_id(i) IS NULL
    --AND    x_headers_rec.has_errors(i) = 'N'
    AND    x_headers_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_header_create;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '090';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = p_key
  RETURNING num1, num2
  BULK COLLECT INTO l_indexes, l_agent_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '100';
  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    x_headers_rec.agent_id(l_index) := l_agent_ids(i);
  END LOOP;

  l_progress := '110';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_buyer;


----------------------------------------------------------------------------------
-- Lines
----------------------------------------------------------------------------------

-- Forward function declarations

PROCEDURE default_hdr_info
(
  p_key                  IN PO_SESSION_GT.key%TYPE,
  p_lines_rec            IN PO_R12_CAT_UPG_PVT.record_of_lines_type,
  x_org_ids              OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_vendor_ids           OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_vendor_site_ids      OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_ship_to_location_ids OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_min_release_amounts  OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_po_header_ids        OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
);

PROCEDURE copy_info_from_hdr
(
  p_hdr_org_ids   IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  p_po_header_ids IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_lines_rec     IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
);

PROCEDURE default_line_type
(
  p_key         IN PO_SESSION_GT.key%TYPE,
  p_hdr_org_ids IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_lines_rec   IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
);

PROCEDURE default_info_from_line_type
(
  p_key                     IN PO_SESSION_GT.key%TYPE,
  x_lines_rec               IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
);

PROCEDURE default_info_from_item
(
  p_key       IN PO_SESSION_GT.key%TYPE,
  x_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
);

PROCEDURE default_hzd_cls_from_un_num
(
  p_key       IN PO_SESSION_GT.key%TYPE,
  x_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
);

PROCEDURE get_ship_to_org_from_location
(
  p_key              IN PO_SESSION_GT.key%TYPE,
  p_location_ids     IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_org_ids          OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
);

-- END: Forward function declarations

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_lines
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) Input pl/sql table: Overwrites the defaulted value.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Defaults the line level column values, if no value is given in the
--  interface tables.
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
-- p_lines_rec
--  A table of plsql records containing a batch of lines.
--OUT:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_lines
(
  p_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_lines';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_lines_rec.interface_line_id.COUNT;

  l_key PO_SESSION_GT.key%TYPE;
  i NUMBER;

  l_hdr_org_ids              PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_hdr_vendor_ids           PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_hdr_vendor_site_ids      PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_hdr_ship_to_location_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_hdr_min_release_amounts  PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_po_header_ids            PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_it_inspection_required_flags PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR1;
  l_ship_to_org_ids          PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '020';
  -- pick a new key from temp table which will be used in all default logic
  --l_key := PO_CORE_S.get_session_gt_nextval;
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key
  FROM DUAL;

  l_progress := '030';
  -- some information for the lines has to be copied from the respective
  -- header level. Each of the arrays that are OUT parameters will have
  -- an entry for every record in the p_lines array.
  default_hdr_info
  (
    p_key                  => l_key,
    p_lines_rec            => p_lines_rec,
    x_org_ids              => l_hdr_org_ids,
    x_vendor_ids           => l_hdr_vendor_ids,
    x_vendor_site_ids      => l_hdr_vendor_site_ids,
    x_ship_to_location_ids => l_hdr_ship_to_location_ids,
    x_min_release_amounts  => l_hdr_min_release_amounts,
    x_po_header_ids        => l_po_header_ids
  );

  l_progress := '040';
  -- copy the org_id and po_header_id from header
  copy_info_from_hdr
  (
    p_hdr_org_ids   => l_hdr_org_ids,
    p_po_header_ids => l_po_header_ids,
    x_lines_rec     => p_lines_rec -- IN OUT
  );

  l_progress := '050';
  -- default line_type_id that will be used in other defaulting logic
  default_line_type
  (
    p_key         => l_key,
    p_hdr_org_ids => l_hdr_org_ids,
    x_lines_rec   => p_lines_rec -- IN OUT
  );

  l_progress := '060';
  -- Get default info from line type definition,
  -- The attributes we default from line type are:
  --     order_type_lookup_code,
  --     purchase_basis,
  --     matching_basis
  -- The following default in PDOI, but in catalog migration iP will
  -- provide a value for these and therefore, they are not required
  -- to be defaulted.
  --     category_id,
  --     unit_of_measure,
  --     unit_price
  default_info_from_line_type
  (
    p_key                     => l_key,
    x_lines_rec               => p_lines_rec -- IN OUT
  );

  l_progress := '070';
  -- Get default info from item definition
  -- The attributes we default from item are:
  --     un_number_id,
  --     hazard_class_id,
  --     market_price
  --     inspection_required_flag
  -- The following default in PDOI, but in catalog migration iP will
  -- provide a value for these and therefore, they are not required
  -- to be defaulted.
  --     item_description,
  --     unit_of_measure,
  --     unit_price
  --     category_id
  default_info_from_item(
      p_key       => l_key,
      x_lines_rec => p_lines_rec);

  l_progress := '080';
  -- If hazard_class_id is NULL at item level and un_number_id is not null,
  -- then default hazard_class_id from UN Number.
  default_hzd_cls_from_un_num(
      p_key       => l_key,
      x_lines_rec => p_lines_rec);

  l_progress := '090';
  -- On the Header, only the ship_to_location_id is present, so we need to
  -- get the ship_to_org_id's here
  get_ship_to_org_from_location(p_key          => l_key,
                                p_location_ids => l_hdr_ship_to_location_ids,
                                x_org_ids      => l_ship_to_org_ids);

  l_progress := '100';
  -- default all other attributes
  FOR i IN 1 .. p_lines_rec.interface_line_id.COUNT
  LOOP
    l_progress := '110';
    IF (--p_lines_rec.has_errors(i) = 'Y' OR
        p_lines_rec.action(i) <> PO_R12_CAT_UPG_PVT.g_action_line_create) THEN
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Skipping rec#'||i||' has_errors='||p_lines_rec.has_errors(i)||'action='||p_lines_rec.action(i)); END IF;
      goto END_OF_LINES_LOOP;
    END IF;

    -- default base_unit_price
    IF (p_lines_rec.base_unit_price(i) IS NULL AND
        p_lines_rec.order_type_lookup_code(i) <> 'FIXED PRICE') THEN
      p_lines_rec.base_unit_price(i) := p_lines_rec.unit_price(i);
    END IF;

    -- default list_price_per_unit
    -- TODO: ONLY PRESENT IN TXN TABLES
    --IF (p_lines_rec.list_prices_per_unit(i) IS NULL AND
    --    p_lines_rec.item_id(i) IS NOT NULL) THEN
    --  p_lines_rec.list_prices_per_unit(i) := p_lines_rec.unit_price(i);
    --END IF;

    l_progress := '120';
    -- default market_price
    IF (p_lines_rec.market_price(i) IS NULL AND
        p_lines_rec.item_id(i) IS NOT NULL) THEN
      p_lines_rec.market_price(i) := p_lines_rec.unit_price(i);
    END IF;

    l_progress := '130';
    --------------------------------------------------------------
    --p_lines_rec.po_line_id(i) := NULL;  -- NOT NULL  NUMBER  From sequence PO_LINES_S
    p_lines_rec.last_update_date(i) := sysdate;  -- NOT NULL  DATE  Sysdate
    l_progress := '131';
    p_lines_rec.last_updated_by(i) := FND_GLOBAL.user_id; -- NOT NULL  NUMBER  FND_GLOBAL.user_id
    --p_lines_rec.po_header_id(i) := NULL;  -- NOT NULL  NUMBER  From the PO header created in the same flow
    --p_lines_rec.line_type_id(i) := NULL;  -- NOT NULL  NUMBER  Default as in PDOI(Open issue) In PDOI it is a must column/parameter like buyer
    --p_lines_rec.line_num(i) := NULL;  -- NOT NULL  NUMBER  Default as in PDOI
    p_lines_rec.last_update_login(i) := FND_GLOBAL.login_id;  -- NUMBER  FND_GLOBAL.login_id
    p_lines_rec.creation_date(i) := sysdate;  -- DATE  sysdate
    p_lines_rec.created_by(i) := PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER;  -- NUMBER  -12 (suggested by iP)
    --p_lines_rec.item_id(i) := NULL;  -- NUMBER  Copy value from interface table
    --p_lines_rec.item_revision(i) := NULL;  -- VARCHAR2(3) Copy value from interface table
    --p_lines_rec.category_id(i) := NULL;  -- NUMBER  Copy value from interface table
    --p_lines_rec.item_description(i) := NULL;  -- VARCHAR2(240) Copy value from interface table
    --p_lines_rec.unit_meas_lookup_code(i) := NULL;  -- VARCHAR2(25)  Copy value from interface table
    --p_lines_rec.quantity_committed(i) := NULL;  -- NUMBER  NULL -- TODO: ONLY PRESENT IN TXN TABLES
    p_lines_rec.committed_amount(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.allow_price_override_flag(i) := 'N';  -- VARCHAR2(1) Default as in PDOI (iP will not provide)
    p_lines_rec.not_to_exceed_price(i) := NULL;  -- NUMBER  NULL
    l_progress := '132';
    --p_lines_rec.list_price_per_unit(i) := NULL;  -- NUMBER  ??? (Same as unit_price?)
    --p_lines_rec.unit_price(i) := NULL;  -- NUMBER  Copy value from interface table
    p_lines_rec.quantity(i) := NULL;  -- NUMBER  NULL
    --p_lines_rec.un_number_id(i) := NULL;  -- NUMBER  Default as in PDOI (iP will not provide)
    --p_lines_rec.hazard_class_id(i) := NULL;  -- NUMBER  Default as in PDOI (iP will not provide)
    p_lines_rec.note_to_vendor(i) := NULL;  -- VARCHAR2(480) NULL
    p_lines_rec.from_header_id(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.from_line_id(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.min_order_quantity(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.max_order_quantity(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.qty_rcv_tolerance(i) := NULL;  -- NUMBER  Default as in PDOI (iP will not provide)
    p_lines_rec.over_tolerance_error_flag(i) := NULL;  -- VARCHAR2(25)  NULL
    l_progress := '133';
    --p_lines_rec.market_price(i) := NULL;  -- NUMBER  Default as in PDOI (iP will not provide)
    --p_lines_rec.unordered_flag(i) := 'N';  -- VARCHAR2(1) N -- TODO: ONLY PRESENT IN TXN TABLES
    --p_lines_rec.closed_flag(i) := 'N';  -- VARCHAR2(1) N -- TODO: ONLY PRESENT IN TXN TABLES
    --p_lines_rec.user_hold_flag(i) := 'N';  -- VARCHAR2(1) N -- TODO: ONLY PRESENT IN TXN TABLES
    --p_lines_rec.cancel_flag(i) := 'N';  -- VARCHAR2(1) N -- TODO: ONLY PRESENT IN TXN TABLES
    --p_lines_rec.cancelled_by(i) := NULL;  -- NUMBER(9) NULL -- TODO: ONLY PRESENT IN TXN TABLES
    --p_lines_rec.cancel_date(i) := NULL;  -- DATE  NULL -- TODO: ONLY PRESENT IN TXN TABLES
    --p_lines_rec.cancel_reason(i) := NULL;  -- VARCHAR2(240) NULL -- TODO: ONLY PRESENT IN TXN TABLES
    --p_lines_rec.firm_status_lookup_code(i) := NULL;  -- VARCHAR2(30)  NULL -- TODO: ONLY PRESENT IN TXN TABLES
    --p_lines_rec.firm_date(i) := NULL;  -- DATE  NULL -- TODO: ONLY PRESENT IN TXN TABLES
    --p_lines_rec.vendor_product_num(i) := NULL;  -- VARCHAR2(25)  Copy value from interface table
    p_lines_rec.contract_num(i) := NULL;  -- VARCHAR2(25)  NULL
    p_lines_rec.type_1099(i) := NULL;  -- VARCHAR2(10)  Default as in PDOI (iP will not provide)
    p_lines_rec.capital_expense_flag(i) := 'N';  -- VARCHAR2(1) N
    --p_lines_rec.negotiated_by_preparer_flag(i) := 'N';  -- VARCHAR2(1) N
    l_progress := '134';
    --p_lines_rec.attribute_category(i) := NULL;  -- VARCHAR2(30)  NULL
    --p_lines_rec.attribute1(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute2(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute3(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute4(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute5(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute6(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute7(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute8(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute9(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute10(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.reference_num(i) := NULL;  -- VARCHAR2(25)  NULL
    --p_lines_rec.attribute11(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute12(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute13(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute14(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.attribute15(i) := NULL;  -- VARCHAR2(150) NULL
    p_lines_rec.min_release_amount(i) := l_hdr_min_release_amounts(i);  -- NUMBER  Copy value from header level
    p_lines_rec.price_type(i) := PO_R12_CAT_UPG_PVT.g_sys.price_lookup_code;  -- VARCHAR2(25) Default as in PDOI (iP will not provide)
    p_lines_rec.closed_code(i) := 'OPEN';  -- VARCHAR2(25)  OPEN
    p_lines_rec.price_break_lookup_code(i) := NULL;  -- VARCHAR2(25)  NULL (For GA's)
    p_lines_rec.ussgl_transaction_code(i) := NULL;  -- VARCHAR2(30)  NULL
    --p_lines_rec.government_context(i) := NULL;  -- VARCHAR2(30)  NULL -- TODO: ONLY PRESENT IN TXN TABLES
    l_progress := '135';
    p_lines_rec.request_id(i) := FND_GLOBAL.conc_request_id;  -- NUMBER iPs conc program request id
    p_lines_rec.program_application_id(i) := FND_GLOBAL.prog_appl_id;  -- NUMBER
    p_lines_rec.program_id(i) := FND_GLOBAL.conc_program_id;  -- NUMBER
    p_lines_rec.program_update_date(i) := sysdate;  -- DATE
    p_lines_rec.closed_date(i) := NULL;  -- DATE  NULL
    p_lines_rec.closed_reason(i) := NULL;  -- VARCHAR2(240) NULL
    p_lines_rec.closed_by(i) := NULL;  -- NUMBER(9) NULL
    p_lines_rec.transaction_reason_code(i) := NULL;  -- VARCHAR2(25)  NULL
    l_progress := '136';
    --p_lines_rec.org_id(i) := NULL;  -- NUMBER  Copy value from header level.
    --p_lines_rec.qc_grade(i) := NULL;  -- VARCHAR2(25)  NULL (Obsolete)
    --p_lines_rec.base_uom(i) := NULL;  -- VARCHAR2(25)  NULL (Obsolete)
    --p_lines_rec.base_qty(i) := NULL;  -- NUMBER  NULL (Obsolete)
    --p_lines_rec.secondary_uom(i) := NULL;  -- VARCHAR2(25)  NULL (Obsolete)
    --p_lines_rec.secondary_qty(i) := NULL;  -- NUMBER  NULL (Obsolete)
    --p_lines_rec.global_attribute_category(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute1(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute2(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute3(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute4(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute5(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute6(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute7(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute8(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute9(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute10(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute11(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute12(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute13(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute14(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute15(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute16(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute17(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute18(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute19(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.global_attribute20(i) := NULL;  -- VARCHAR2(150) NULL
    --p_lines_rec.line_reference_num(i) := NULL;  -- VARCHAR2(25)  NULL
    --p_lines_rec.project_id(i) := NULL;  -- NUMBER  NULL
    --p_lines_rec.task_id(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.expiration_date(i) := NULL;  -- DATE  NULL
    p_lines_rec.oke_contract_header_id(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.oke_contract_version_id(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.secondary_quantity(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.secondary_unit_of_measure(i) := NULL;  -- VARCHAR2(25)  NULL
    p_lines_rec.preferred_grade(i) := NULL;  -- VARCHAR2(150) NULL
    p_lines_rec.auction_header_id(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.auction_display_number(i) := NULL;  -- VARCHAR2(40)  NULL
    p_lines_rec.auction_line_number(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.bid_number(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.bid_line_number(i) := NULL;  -- NUMBER  NULL
    l_progress := '137';
    --p_lines_rec.retroactive_date(i) := NULL;  -- DATE  NULL
    p_lines_rec.supplier_ref_number(i) := NULL;  -- VARCHAR2(150) NULL
    p_lines_rec.contract_id(i) := NULL;  -- NUMBER  NULL
    --p_lines_rec.start_date(i) := NULL;  -- DATE  NULL (contingent worker)
    p_lines_rec.amount(i) := NULL;  -- NUMBER  NULL (services proc)
    p_lines_rec.job_id(i) := NULL;  -- NUMBER  NULL
    p_lines_rec.contractor_first_name(i) := NULL;  -- VARCHAR2(240) NULL
    p_lines_rec.contractor_last_name(i) := NULL;  -- VARCHAR2(240) NULL
    p_lines_rec.from_line_location_id(i) := NULL;  -- NUMBER  NULL
    l_progress := '138';
    --p_lines_rec.order_type_lookup_code(i) := NULL;  -- NOT NULL  VARCHAR2(25)  Default as in PDOI (iP will not provide)QUANTITY
    --p_lines_rec.purchase_basis(i) := NULL;  -- NOT NULL  VARCHAR2(30)  Default as in PDOI (iP will not provide)GOODS (must be GOODS?) (Open issue)
    --p_lines_rec.matching_basis(i) := NULL;  -- NOT NULL  VARCHAR2(30)  Default as in PDOI (iP will not provide)QUANTITY
    --p_lines_rec.svc_amount_notif_sent(i) := NULL;  -- VARCHAR2(1) Not present in 11.5.9. For 11.5.10, default NULL
    --p_lines_rec.svc_completion_notif_sent(i) := NULL;  -- VARCHAR2(1) Not present in 11.5.9. For 11.5.10, default NULL
    --p_lines_rec.base_unit_price(i) := NULL;  -- NUMBER  Not present in 11.5.9. For 11.5.10, default same as unit price? (Open issue)
    --p_lines_rec.manual_price_change_flag(i) := NULL;  -- VARCHAR2(1) NULL
    --p_lines_rec.retainage_rate(i) := NULL;  -- NUMBER  Not present in 11.5.9, 11.5.10
    --p_lines_rec.max_retainage_amount(i) := NULL;  -- NUMBER  Not present in 11.5.9, 11.5.10
    --p_lines_rec.progress_payment_rate(i) := NULL;  -- NUMBER  Not present in 11.5.9, 11.5.10
    --p_lines_rec.recoupment_rate(i) := NULL;  -- NUMBER  Not present in 11.5.9, 11.5.10
    --p_lines_rec.catalog_name(i) := NULL;  -- VARCHAR2(255) Copy value from interface table
    --p_lines_rec.supplier_part_auxid(i) := NULL;  -- VARCHAR2(255) Copy value from interface table
    --p_lines_rec.ip_category_id(i) := NULL;  -- NUMBER  Copy value from interface table
    --p_lines_rec.last_updated_program(i) := 'CATALOG_MIGRATION';  -- VARCHAR2(255) 'CATALOG_MIGRATION' (Open Issue) -- TODO: ONLY PRESENT IN TXN TABLES
    --p_lines_rec.advance_amount(i) := NULL;  -- NUMBER  Not present in 11.5.9, 11.5.10
    ------------------------------------------------------------------------
    p_lines_rec.ship_to_location_id(i) := l_hdr_ship_to_location_ids(i);
    l_progress := '139';
    p_lines_rec.ship_to_organization_id(i) := l_ship_to_org_ids(i);
    ------------------------------------------------------------------------

    l_progress := '140';
    -- Bug 5032164: There is no need to get tax information for Blankets.
    p_lines_rec.taxable_flag(i) := NULL;
    p_lines_rec.tax_name(i) := NULL;
    p_lines_rec.tax_code_id(i) := NULL;
    p_lines_rec.tax_user_override_flag(i) := NULL;

  <<END_OF_LINES_LOOP>>
  l_progress := '160';
  END LOOP;

  l_progress := '170';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_lines;

--------------------------------------------------------------------------------
--Start of Comments
--Name: copy_info_from_hdr
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Copies the header level org_id and po_header_id into the line level.
--Parameters:
--IN:
--p_hdr_org_ids
--  A table of numbers containing the header level org_id's
--IN/OUT:
--x_lines_rec
--  A record of plsql tables containing a batch of lines. The value of
--  org_id will be populated from the header level.
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE copy_info_from_hdr
(
  p_hdr_org_ids   IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  p_po_header_ids IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_lines_rec     IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'copy_info_from_hdr';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '020';
  FOR i IN 1 .. x_lines_rec.interface_line_id.COUNT
  LOOP
    IF (--x_lines_rec.has_errors(i) = 'N' AND
        p_hdr_org_ids.EXISTS(i)) THEN
      x_lines_rec.org_id(i) := p_hdr_org_ids(i);
      x_lines_rec.po_header_id(i) := p_po_header_ids(i);
    END IF;
  END LOOP;

  l_progress := '030';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END copy_info_from_hdr;

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_line_type
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Defaults the line type.
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--p_hdr_org_ids
--  A table of numbers containing the header level org_id's
--IN/OUT:
--x_lines_rec
--  A record of plsql tables containing a batch of lines. The value of
--  line_type_id will be populated.
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_line_type
(
  p_key         IN PO_SESSION_GT.key%TYPE,
  p_hdr_org_ids IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_lines_rec   IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_line_type';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := x_lines_rec.interface_line_id.COUNT;

  l_line_type_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes       PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_index NUMBER;

  i NUMBER;
  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(x_lines_rec.interface_line_id.COUNT);

  l_progress := '030';
  -- SQL What: Get the default line type from PSP. If the purchase_basis for
  --           this one is not GOODS, default line type to GOODS (seeded
  --           value of line_type_id = 1)
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: line_type_id, org_id
  FORALL i IN 1 .. x_lines_rec.interface_line_id.COUNT
    INSERT INTO PO_SESSION_GT(key,
                              num1,
                              num2)
    SELECT p_key,
           l_subscript_array(i),
           DECODE(POLTB.purchase_basis,
                  'GOODS', PSP.line_type_id,
                  1)
    FROM PO_SYSTEM_PARAMETERS_ALL PSP,
         PO_LINE_TYPES_B POLTB
    WHERE PSP.org_id = p_hdr_org_ids(i)
    AND   PSP.line_type_id = POLTB.line_type_id
    --AND   x_lines_rec.has_errors(i) = 'N'
    AND   x_lines_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_line_create;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2
  BULK COLLECT INTO l_indexes, l_line_type_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    x_lines_rec.line_type_id(l_index) := l_line_type_ids(i);
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_line_type;

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_line_type
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- Get default info from line type definition,
-- The attributes we defaulted from line type include:
--     order_type_lookup_code,
--     purchase_basis,
--     matching_basis
-- The following default in PDOI, but in catalog migration iP will
-- provide a value for these and therefore, they are not required
-- to be defaulted.
--     category_id,
--     unit_of_measure,
--     unit_price
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--x_lines_rec
--  A record of plsql tables containing a batch of lines. The value of
--  order_type_lookup_code, purchase_basis and matching_basis will be populated.
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_info_from_line_type
(
  p_key                     IN PO_SESSION_GT.key%TYPE,
  x_lines_rec               IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_info_from_line_type';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := x_lines_rec.interface_line_id.COUNT;

  l_indexes                 PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_order_type_lookup_codes PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR25;
  l_purchase_basis          PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR30;
  l_matching_basis          PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR30;

  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_index NUMBER;
  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(x_lines_rec.line_type_id.COUNT);

  l_progress := '020';
  -- SQL What: Get the line type related info into the session GT table.
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: line_type_id
  FORALL i IN 1 .. x_lines_rec.line_type_id.COUNT
  INSERT INTO po_session_gt(key,
                            num1,
                            char1,
                            char2,
                            char3)
  SELECT p_key,
         l_subscript_array(i),
         order_type_lookup_code,
         purchase_basis,
         matching_basis
  FROM   PO_LINE_TYPES_B
  WHERE  line_type_id = x_lines_rec.line_type_id(i)
   AND   x_lines_rec.line_type_id(i) IS NOT NULL
   --AND   x_lines_rec.has_errors(i) = 'N'
   AND   x_lines_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_line_create;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1, char2, char3
  BULK COLLECT INTO l_indexes, l_order_type_lookup_codes,
                    l_purchase_basis, l_matching_basis;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    x_lines_rec.order_type_lookup_code(l_index) := l_order_type_lookup_codes(i);
    x_lines_rec.purchase_basis(l_index) := l_purchase_basis(i);
    x_lines_rec.matching_basis(l_index) := l_matching_basis(i);
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_info_from_line_type;

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_item
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- Get default information from item definitions
--
--  un_number_id
--  hazard_class_id
--  market_price
--  inspection_required_flag
--
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--x_lines_rec
--  A record of plsql tables containing a batch of lines. The value of
--  above gived fields will be populated.
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_info_from_item
(
  p_key              IN PO_SESSION_GT.key%TYPE,
  x_lines_rec        IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_info_from_item';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := x_lines_rec.interface_line_id.COUNT;

  l_indexes          PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_un_number_ids    PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_hazard_class_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_market_prices    PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_inspection_required_flags PO_R12_CAT_UPG_TYPES.PO_TBL_VARCHAR1;

  l_subscript_array  PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_index NUMBER;
  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(x_lines_rec.line_type_id.COUNT);

  l_progress := '020';
  -- SQL What: Default information from item_id into the session GT table.
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: item_id
  FORALL i IN 1 .. x_lines_rec.line_type_id.COUNT
  INSERT INTO po_session_gt(key,
                            num1,
                            num2,
                            num3,
                            num4,
                            char1)
  SELECT p_key,
         l_subscript_array(i),
         un_number_id,
         hazard_class_id,
         market_price,
         inspection_required_flag
  FROM   MTL_SYSTEM_ITEMS_B
  WHERE  inventory_item_id = x_lines_rec.item_id(i)
   AND   organization_id = PO_R12_CAT_UPG_PVT.g_sys.inv_org_id
   AND   x_lines_rec.item_id(i) IS NOT NULL
   --AND   x_lines_rec.has_errors(i) = 'N'
   AND   x_lines_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_line_create;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2, num3, num4, char1
  BULK COLLECT INTO l_indexes, l_un_number_ids, l_hazard_class_ids,
                    l_market_prices, l_inspection_required_flags;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    x_lines_rec.un_number_id(l_index) := l_un_number_ids(i);
    x_lines_rec.hazard_class_id(l_index) := l_hazard_class_ids(i);
    x_lines_rec.market_price(l_index) := l_market_prices(i);
    x_lines_rec.inspection_required_flag(l_index) := l_inspection_required_flags(i);
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_info_from_item;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_ship_to_org_from_location
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- Gets the Ship-to-org associated with a given location
--
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--p_location_ids
--  A plsql tables containing a set of location_ids
--OUT:
--x_org_ids
--  A plsql tables containing the values of ship-to-org-id's for the
--  corresponding location-id's.
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_ship_to_org_from_location
(
  p_key              IN PO_SESSION_GT.key%TYPE,
  p_location_ids     IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_org_ids          OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'get_ship_to_org_from_location';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_location_ids.COUNT;

  l_indexes PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_org_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_index NUMBER;
  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_location_ids.COUNT);

  IF (p_location_ids.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_location_ids(1)='||p_location_ids(1)); END IF;
  END IF;

  l_progress := '020';
  -- SQL What: Default information from ship_to_location into session GT table.
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: location_id
  FORALL i IN 1 .. p_location_ids.COUNT
  INSERT INTO po_session_gt(key,
                            num1,
                            num2)
  SELECT p_key,
         l_subscript_array(i),
         inventory_organization_id
  FROM   HR_LOCATIONS_V
  WHERE  location_id = p_location_ids(i)
   AND   ship_to_site_flag = 'Y'
   AND   p_location_ids(i) IS NOT NULL;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2
  BULK COLLECT INTO l_indexes, l_org_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  FOR i IN 1 .. p_location_ids.COUNT
  LOOP
    x_org_ids(i) := NULL;
  END LOOP;

  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    x_org_ids(l_index) := l_org_ids(i);
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END get_ship_to_org_from_location;


--------------------------------------------------------------------------------
--Start of Comments
--Name: default_hzd_cls_from_un_num
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- Get default hazard_class_id for a given un_number
--
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--IN/OUT:
--x_lines_rec
--  A record of plsql tables containing a batch of lines. The value of
--  hazard_class_id will be populated.
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_hzd_cls_from_un_num
(
  p_key       IN PO_SESSION_GT.key%TYPE,
  x_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_hzd_cls_from_un_num';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := x_lines_rec.interface_line_id.COUNT;

  l_indexes          PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_hazard_class_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_subscript_array  PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_index NUMBER;
  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(x_lines_rec.ship_to_location_id.COUNT);

  l_progress := '020';
  -- SQL What: Default hazard_class_id into the session GT table.
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: un_number
  FORALL i IN 1 .. x_lines_rec.ship_to_location_id.COUNT
  INSERT INTO po_session_gt(key,
                            num1,
                            num2)
  SELECT p_key,
         l_subscript_array(i),
         hazard_class_id
  FROM   PO_UN_NUMBERS_VAL_V
  WHERE  un_number = x_lines_rec.un_number(i)
   AND   x_lines_rec.un_number(i) IS NOT NULL
   AND   x_lines_rec.hazard_class_id(i) IS NULL
   --AND   x_lines_rec.has_errors(i) = 'N'
   AND   x_lines_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_line_create;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2
  BULK COLLECT INTO l_indexes, l_hazard_class_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';
  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    x_lines_rec.hazard_class_id(l_index) := l_hazard_class_ids(i);
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_hzd_cls_from_un_num;

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_hdr_info
--Pre-reqs:
--  The iP catalog data is populated in input pl/sql tables.
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
-- Get default value of the following header level fields for the
-- respective lines.
--
--    org_id
--    vendor_id
--    vendor_site_id
--    ship_to_location_id
--    min_release_amount
--
--Parameters:
--IN:
--p_key
--  Key used to access records in PO_SESSION_GT table.
--p_lines_rec
--  A record of plsql tables containing a batch of lines.
--OUT:
--x_org_ids
--  A plsql table in which the org_id's will be populated.
--x_vendor_ids
--  A plsql table in which the vendor_id's will be populated.
--x_vendor_site_ids
--  A plsql table in which the vendor_site_id's will be populated.
--x_ship_to_location_ids
--  A plsql table in which the ship_to_location_id's will be populated.
--x_min_release_amounts
--  A plsql table in which the min_release_amount's will be populated.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_hdr_info
(
  p_key                  IN PO_SESSION_GT.key%TYPE,
  p_lines_rec            IN PO_R12_CAT_UPG_PVT.record_of_lines_type,
  x_org_ids              OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_vendor_ids           OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_vendor_site_ids      OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_ship_to_location_ids OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_min_release_amounts  OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  x_po_header_ids        OUT NOCOPY PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'default_hdr_info';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_size NUMBER := p_lines_rec.interface_line_id.COUNT;

  l_subscript_array  PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_indexes          PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_org_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_vendor_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_vendor_site_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_ship_to_location_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_min_release_amounts PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_po_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_index NUMBER;
  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_subscript_array := PO_R12_CAT_UPG_UTL.construct_subscript_array(p_lines_rec.interface_line_id.COUNT);

  l_progress := '020';
  -- SQL What: Default header related info into the session GT table.
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: interface_header_id, po_header_id
  FORALL i IN 1 .. p_lines_rec.interface_line_id.COUNT
  INSERT INTO po_session_gt(key,
                            num1,
                            num2,
                            num3,
                            num4,
                            num5,
                            num6,
                            num7)
  SELECT p_key,
         l_subscript_array(i),
         POH.org_id,
         POH.vendor_id,
         POH.vendor_site_id,
         POH.ship_to_location_id,
         POH.min_release_amount,
         POH.po_header_id
  FROM   PO_HEADERS_ALL POH,
         PO_HEADERS_INTERFACE POHI
  WHERE  POH.po_header_id = POHI.po_header_id
   AND   POHI.interface_header_id = p_lines_rec.interface_header_id(i)
   --AND   p_lines_rec.has_errors(i) = 'N'
   AND   p_lines_rec.action(i) = PO_R12_CAT_UPG_PVT.g_action_line_create;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows insert into GT table='||SQL%rowcount); END IF;

  l_progress := '030';
  -- SQL What: Transfer from session GT table to local arrays
  -- SQL Why : It will be used to populate the OUT parameters.
  -- SQL Join: key
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2, num3, num4, num5, num6, num7
  BULK COLLECT INTO l_indexes, l_org_ids, l_vendor_ids,
                    l_vendor_site_ids, l_ship_to_location_ids,
                    l_min_release_amounts, l_po_header_ids;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows deleted from GT table='||SQL%rowcount); END IF;

  l_progress := '040';

  FOR i IN 1 .. p_lines_rec.interface_line_id.COUNT
  LOOP
    x_org_ids(i) := NULL;
    x_vendor_ids(i) := NULL;
    x_vendor_site_ids(i) := NULL;
    x_ship_to_location_ids(i) := NULL;
    x_min_release_amounts(i) := NULL;
    x_po_header_ids(i) := NULL;
  END LOOP;

  -- transfer from local arrays to OUT parameters
  FOR i IN 1 .. l_indexes.COUNT
  LOOP
    l_index := l_indexes(i);
    x_org_ids(l_index) := l_org_ids(i);
    x_vendor_ids(l_index) := l_vendor_ids(i);
    x_vendor_site_ids(l_index) := l_vendor_site_ids(i);
    x_ship_to_location_ids(l_index) := l_ship_to_location_ids(i);
    x_min_release_amounts(l_index) := l_min_release_amounts(i);
    x_po_header_ids(l_index) := l_po_header_ids(i);
  END LOOP;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END default_hdr_info;

END PO_R12_CAT_UPG_DEF_PVT;

/
