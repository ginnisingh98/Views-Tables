--------------------------------------------------------
--  DDL for Package Body PO_ADVANCED_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ADVANCED_PRICE_PVT" AS
/* $Header: POXQPRVB.pls 120.8.12010000.9 2014/06/06 09:52:27 inagdeo ship $ */


-- Private package constants
  g_pkg_name CONSTANT VARCHAR2(30) := 'PO_ADVANCED_PRICE_PVT';
  g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

-- Debugging
  g_debug_stmt BOOLEAN := PO_DEBUG.is_debug_stmt_on;
  g_debug_unexp BOOLEAN := PO_DEBUG.is_debug_unexp_on;

--------------------------------------------------------------------------------
-- Forward procedure declarations
--------------------------------------------------------------------------------

  PROCEDURE populate_header_record
  (p_org_id IN NUMBER
   , p_order_header_id IN NUMBER
   , p_supplier_id IN NUMBER
   , p_supplier_site_id IN NUMBER
   , p_creation_date IN DATE
   , p_order_type IN VARCHAR2
   , p_ship_to_location_id IN NUMBER
   , p_ship_to_org_id IN NUMBER
-- <FSC R12 START>
-- New Attributes for R12: Receving FSC support
   , p_shipment_header_id IN NUMBER DEFAULT NULL
   , p_hazard_class IN VARCHAR2 DEFAULT NULL
   , p_hazard_code IN VARCHAR2 DEFAULT NULL
   , p_shipped_date IN DATE DEFAULT NULL
   , p_shipment_num IN VARCHAR2 DEFAULT NULL
   , p_carrier_method IN VARCHAR2 DEFAULT NULL
   , p_packaging_code IN VARCHAR2 DEFAULT NULL
   , p_freight_carrier_code IN VARCHAR2 DEFAULT NULL
   , p_freight_terms IN VARCHAR2 DEFAULT NULL
   , p_currency_code IN VARCHAR2 DEFAULT NULL
   , p_rate IN NUMBER DEFAULT NULL
   , p_rate_type IN VARCHAR2 DEFAULT NULL
   , p_source_org_id IN NUMBER DEFAULT NULL
   , p_expected_receipt_date IN DATE DEFAULT NULL
-- <FSC R12 END>
   );

  PROCEDURE populate_line_record
  (p_order_line_id IN NUMBER
   , p_order_type IN VARCHAR2 DEFAULT NULL--Enhanced Pricing
   , p_item_revision IN VARCHAR2 -- Bug 3330884
   , p_item_id IN NUMBER
   , p_category_id IN NUMBER
   , p_supplier_item_num IN VARCHAR2
   , p_agreement_type IN VARCHAR2
   , p_agreement_id IN NUMBER
   , p_agreement_line_id IN NUMBER DEFAULT NULL --<R12 GBPA Adv Pricing>
   , p_supplier_id IN NUMBER
   , p_supplier_site_id IN NUMBER
   , p_ship_to_location_id IN NUMBER
   , p_ship_to_org_id IN NUMBER
   , p_rate IN NUMBER
   , p_rate_type IN VARCHAR2
   , p_currency_code IN VARCHAR2
   , p_need_by_date IN DATE
-- <FSC R12 START>
-- New Attributes for R12: Receving FSC support
   , p_shipment_line_id IN NUMBER DEFAULT NULL
   , p_primary_unit_of_measure IN VARCHAR2 DEFAULT NULL
   , p_to_organization_id IN NUMBER DEFAULT NULL
   , p_unit_of_measure IN VARCHAR2 DEFAULT NULL
   , p_source_document_code IN VARCHAR2 DEFAULT NULL
   , p_unit_price IN NUMBER DEFAULT NULL -- will not be mapped to any QP attribute
   , p_quantity IN NUMBER DEFAULT NULL -- will not be mapped to any QP attribute
-- <FSC R12 END>
   );
--------------------------------------------------------------------------------
-- Procedure definitions
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--Start of Comments
--Name: populate_header_record
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure populates global variable G_HDR.
--Parameters:
--IN:
--p_org_id
--  Org ID.
--p_order_id
--  Order ID: REQUISITION Header ID or PO Header ID.
--p_supplier_id
--  Supplier ID.
--p_supplier_site_id
--  Supplier Site ID.
--p_creation_date
--  Creation date.
--p_order_type
--  Order type: REQUISITION or PO.
--p_ship_to_location_id
--  Ship to Location ID.
--p_ship_to_org_id
--  Ship to Org ID.
--p_shipment_header_id
-- shipment header id
--p_hazard_class
--  hazard class
--p_hazard_code
--  hazard code
--p_shipped_date
--  shipped date for goods
--p_shipment_num
--  shipment number
--p_carrier_method
--  carrier method
--p_packaging_code
--  packaging code
--p_freight_carrier_code
--  greight carrier code
--p_freight_terms
--  freight terms
--p_currency_code
--  currency code
--p_rate
--  currency conversion rate
--p_rate_type
--  rate type
--p_expected_receipt_date
--  expected receipt date
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE populate_header_record
  (  p_org_id IN NUMBER
   , p_order_header_id IN NUMBER
   , p_supplier_id IN NUMBER
   , p_supplier_site_id IN NUMBER
   , p_creation_date IN DATE
   , p_order_type IN VARCHAR2
   , p_ship_to_location_id IN NUMBER
   , p_ship_to_org_id IN NUMBER
   -- <FSC R12 START>
   -- New Attributes for R12: Receving FSC support
   , p_shipment_header_id IN NUMBER DEFAULT NULL
   , p_hazard_class IN VARCHAR2 DEFAULT NULL
   , p_hazard_code IN VARCHAR2 DEFAULT NULL
   , p_shipped_date IN DATE DEFAULT NULL
   , p_shipment_num IN VARCHAR2 DEFAULT NULL
   , p_carrier_method IN VARCHAR2 DEFAULT NULL
   , p_packaging_code IN VARCHAR2 DEFAULT NULL
   , p_freight_carrier_code IN VARCHAR2 DEFAULT NULL
   , p_freight_terms IN VARCHAR2 DEFAULT NULL
   , p_currency_code IN VARCHAR2 DEFAULT NULL
   , p_rate IN NUMBER DEFAULT NULL
   , p_rate_type IN VARCHAR2 DEFAULT NULL
   , p_source_org_id IN NUMBER DEFAULT NULL
   , p_expected_receipt_date IN DATE DEFAULT NULL
-- <FSC R12 END>
   )
  IS
  BEGIN
    g_hdr.org_id := p_org_id;
    g_hdr.p_order_header_id := p_order_header_id;
    g_hdr.supplier_id := p_supplier_id;
    g_hdr.supplier_site_id := p_supplier_site_id;
    g_hdr.creation_date := p_creation_date;
    g_hdr.order_type := p_order_type;
    g_hdr.ship_to_location_id := p_ship_to_location_id;
    g_hdr.ship_to_org_id := p_ship_to_org_id;
  -- <FSC R12 START>
    g_hdr.shipment_header_id := p_shipment_header_id;
    g_hdr.hazard_class := p_hazard_class;
    g_hdr.hazard_code := p_hazard_code;
    g_hdr.shipped_date := p_shipped_date;
    g_hdr.shipment_num := p_shipment_num;
    g_hdr.carrier_method := p_carrier_method;
    g_hdr.packaging_code := p_packaging_code;
    g_hdr.freight_carrier_code := p_freight_carrier_code;
    g_hdr.freight_terms := p_freight_terms;
    g_hdr.currency_code := p_currency_code;
    g_hdr.rate := p_rate;
    g_hdr.rate_type := p_rate_type;
    g_hdr.source_org_id := p_source_org_id;
    g_hdr.expected_receipt_date := p_expected_receipt_date;
  -- <FSC R12 END>
  END populate_header_record;

--------------------------------------------------------------------------------
--Start of Comments
--Name: populate_line_record
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure populates global variable G_LINE.
--Parameters:
--IN:
--p_order_line_id
--  Order Line ID: REQUISITION Line ID or PO Line ID.
--p_item_revision
--  Item Revision.
--p_item_id
--  Inventory Item ID.
--p_category_id
--  Category ID.
--p_agreement_type
--  The type of the source agreement. In 11.5.10, should only be CONTRACT.
--p_agreement_id
--  The header ID of the source agreement.
--p_supplier_id
--  Supplier ID.
--p_supplier_site_id
--  Supplier Site ID.
--p_ship_to_location_id
--  Ship to Location ID.
--p_ship_to_org_id
--  Ship to Org ID.
--p_rate
--  Conversion rate.
--p_rate_type
--  Conversion rate type.
--p_currency_code
--  Currency code.
--p_need_by_date
--  Need by date.
--p_shipment_line_id
--  Shipment line id
--p_primary_unit_of_measure
--  primary unit of measure
--p_to_organization_id
--  destination org id
--p_unit_of_measure
--  unit of measure
--p_source_document_code
--  source doc code
--p_unit_price
--  unit price
--p_quantity
--  quantity
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE populate_line_record
  (p_order_line_id IN NUMBER
   , p_order_type IN VARCHAR2 DEFAULT NULL --Enhanced Pricing added to include order type condition at line level
   , p_item_revision IN VARCHAR2 -- Bug 3330884
   , p_item_id IN NUMBER
   , p_category_id IN NUMBER
   , p_supplier_item_num IN VARCHAR2
   , p_agreement_type IN VARCHAR2
   , p_agreement_id IN NUMBER
   , p_agreement_line_id IN NUMBER DEFAULT NULL --<R12 GBPA Adv Pricing>
   , p_supplier_id IN NUMBER
   , p_supplier_site_id IN NUMBER
   , p_ship_to_location_id IN NUMBER
   , p_ship_to_org_id IN NUMBER
   , p_rate IN NUMBER
   , p_rate_type IN VARCHAR2
   , p_currency_code IN VARCHAR2
   , p_need_by_date IN DATE
--<FSC Start R12>
   , p_shipment_line_id IN NUMBER DEFAULT NULL
   , p_primary_unit_of_measure IN VARCHAR2 DEFAULT NULL
   , p_to_organization_id IN NUMBER DEFAULT NULL
   , p_unit_of_measure IN VARCHAR2 DEFAULT NULL
   , p_source_document_code IN VARCHAR2 DEFAULT NULL
   , p_unit_price IN NUMBER DEFAULT NULL -- will not be mapped to any QP attribute
   , p_quantity IN NUMBER DEFAULT NULL -- will not be mapped to any QP attribute
--<FSC End R12>
   )
  IS
  BEGIN
    g_line.order_line_id := p_order_line_id;
    g_line.order_type := p_order_type; --Enhanced Pricing
    g_line.item_revision := p_item_revision;
    g_line.item_id := p_item_id;
    g_line.category_id := p_category_id;
    g_line.supplier_item_num := p_supplier_item_num;
    g_line.agreement_type := p_agreement_type;
    g_line.agreement_id := p_agreement_id;
    g_line.agreement_line_id := p_agreement_line_id; --<R12 GBPA Adv Pricing>
    g_line.supplier_id := p_supplier_id;
    g_line.supplier_site_id := p_supplier_site_id;
    g_line.ship_to_location_id := p_ship_to_location_id;
    g_line.ship_to_org_id := p_ship_to_org_id;
    g_line.rate := p_rate;
    g_line.rate_type := p_rate_type;
    g_line.currency_code := p_currency_code;
    g_line.need_by_date := p_need_by_date;
  -- <FSC R12 START>
    g_line.shipment_line_id := p_shipment_line_id;
    g_line.primary_unit_of_measure := p_primary_unit_of_measure;
    g_line.to_organization_id := p_to_organization_id;
    g_line.unit_of_measure := p_unit_of_measure;
    g_line.source_document_code := p_source_document_code;
    g_line.unit_price := p_unit_price;
    g_line.quantity := p_quantity;
  -- <FSC R12 END>

  END populate_line_record;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_advanced_price
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure calls Advanced prcing API to get list price and adjustment.
--Parameters:
--IN:
--p_org_id
--  Org ID.
--p_supplier_id
--  Supplier ID.
--p_supplier_site_id
--  Supplier Site ID.
--p_rate
--  Conversion rate.
--p_rate_type
--  Conversion rate type.
--p_currency_code
--  Currency code.
--p_creation_date
--  Creation date.
--p_order_type
--  Order type: REQUISITION or PO.
--p_ship_to_location_id
--  Ship to Location ID.
--p_ship_to_org_id
--  Ship to Org ID.
--p_order_id
--  Order ID: REQUISITION Header ID or PO Header ID.
--p_order_line_id
--  Order Line ID: REQUISITION Line ID or PO Line ID.
--p_item_revision
--  Item Revision.
--p_item_id
--  Inventory Item ID.
--p_category_id
--  Category ID.
--p_supplier_item_num
--  Supplier Item Number
--p_agreement_type
--  The type of the source agreement. In 11.5.10, should only be CONTRACT.
--p_agreement_id
--  The header ID of the source agreement.
--p_price_date
--  Price date.
--p_quantity
--  Quantity.
--p_uom
--  Unit of Measure.
--p_unit_price
--  Unit Price.
--OUT:
--x_base_unit_price
--  Base Unit Price.
--x_unit_price
--  Adjusted Unit Price.
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if API succeeds
--  FND_API.G_RET_STS_ERROR if API fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE get_advanced_price
  (  p_org_id IN NUMBER
   , p_supplier_id IN NUMBER
   , p_supplier_site_id IN NUMBER
   , p_creation_date IN DATE
   , p_order_type IN VARCHAR2
   , p_ship_to_location_id IN NUMBER
   , p_ship_to_org_id IN NUMBER
   , p_order_header_id IN NUMBER
   , p_order_line_id IN NUMBER
   , p_item_revision IN VARCHAR2 -- Bug 3330884
   , p_item_id IN NUMBER
   , p_category_id IN NUMBER
   , p_supplier_item_num IN VARCHAR2
   , p_agreement_type IN VARCHAR2
   , p_agreement_id IN NUMBER
   , p_agreement_line_id IN NUMBER DEFAULT NULL --<R12 GBPA Adv Pricing>
   , p_rate IN NUMBER
   , p_rate_type IN VARCHAR2
   , p_currency_code IN VARCHAR2
   , p_need_by_date IN DATE
   , p_quantity IN NUMBER
   , p_uom IN VARCHAR2
   , p_unit_price IN NUMBER
   --<Enhanced Pricing Start>
   , p_draft_id IN NUMBER DEFAULT NULL
   --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
   , p_pricing_call_src IN VARCHAR2 DEFAULT NULL --parameter to identify calls from retro and auto creation
   --<Enhanced Pricing End>
   , x_base_unit_price OUT NOCOPY NUMBER
   , x_unit_price OUT NOCOPY NUMBER
   , x_return_status OUT NOCOPY VARCHAR2
   )
  IS
  l_api_name CONSTANT VARCHAR2(30) := 'GET_ADVANCED_PRICE';
  l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress VARCHAR2(3) := '000';
  l_exception_msg FND_NEW_MESSAGES.message_text%TYPE;
  l_qp_license VARCHAR2(30) := NULL;
  l_qp_license_product VARCHAR2(30) := NULL; /*Added for bug 8762015*/
  l_uom_code MTL_UNITS_OF_MEASURE.uom_code%TYPE;

  --Enhanced Pricing Start:
  l_order_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_quantity_tbl      QP_PREQ_GRP.NUMBER_TYPE;
  l_pricing_events    VARCHAR2(30) := 'PO_BATCH';
  l_draft_id          NUMBER;
  l_retro_pricing     VARCHAR2(1);
  l_allow_price_override_flag PO_LINES_ALL.allow_price_override_flag%TYPE;
  --Enhanced Pricing End:

  l_line_id NUMBER := nvl(p_order_line_id, 1);
  l_return_status_text VARCHAR2(2000);
  l_control_rec QP_PREQ_GRP.control_record_type;
  l_pass_line VARCHAR2(1);

  l_line_index_tbl QP_PREQ_GRP.pls_integer_type;
  l_line_type_code_tbl QP_PREQ_GRP.varchar_type;
  l_pricinl_effective_date_tbl QP_PREQ_GRP.date_type ;
  l_active_date_first_tbl QP_PREQ_GRP.date_type ;
  l_active_date_first_type_tbl QP_PREQ_GRP.varchar_type;
  l_active_date_second_tbl QP_PREQ_GRP.date_type ;
  l_active_date_second_type_tbl QP_PREQ_GRP.varchar_type ;
  l_line_unit_price_tbl QP_PREQ_GRP.number_type ;
  l_line_quantity_tbl QP_PREQ_GRP.number_type ;
  l_line_uom_code_tbl QP_PREQ_GRP.varchar_type;
  l_request_type_code_tbl QP_PREQ_GRP.varchar_type;
  l_priced_quantity_tbl QP_PREQ_GRP.number_type;
  l_uom_quantity_tbl QP_PREQ_GRP.number_type;
  l_priced_uom_code_tbl QP_PREQ_GRP.varchar_type;
  l_currency_code_tbl QP_PREQ_GRP.varchar_type;
  l_unit_price_tbl QP_PREQ_GRP.number_type;
  l_percent_price_tbl QP_PREQ_GRP.number_type;
  l_adjusted_unit_price_tbl QP_PREQ_GRP.number_type;
  l_upd_adjusted_unit_price_tbl QP_PREQ_GRP.number_type;
  l_processed_flag_tbl QP_PREQ_GRP.varchar_type;
  l_price_flag_tbl QP_PREQ_GRP.varchar_type;
  l_line_id_tbl QP_PREQ_GRP.number_type;
  l_processing_order_tbl QP_PREQ_GRP.pls_integer_type;
  l_rounding_factor_tbl QP_PREQ_GRP.pls_integer_type;
  l_rounding_flag_tbl QP_PREQ_GRP.flag_type;
  l_qualifiers_exist_flag_tbl QP_PREQ_GRP.varchar_type;
  l_pricing_attrs_exist_flag_tbl QP_PREQ_GRP.varchar_type;
  l_price_list_id_tbl QP_PREQ_GRP.number_type;
  l_pl_validated_flag_tbl QP_PREQ_GRP.varchar_type;
  l_price_request_code_tbl QP_PREQ_GRP.varchar_type;
  l_usage_pricing_type_tbl QP_PREQ_GRP.varchar_type;
  l_line_category_tbl QP_PREQ_GRP.varchar_type;
  l_pricing_status_code_tbl QP_PREQ_GRP.varchar_type;
  l_pricing_status_text_tbl QP_PREQ_GRP.varchar_type;
  l_list_price_overide_flag_tbl QP_PREQ_GRP.varchar_type;

  l_price_status_code QP_PREQ_LINES_TMP.pricing_status_code%TYPE;
  l_price_status_text QP_PREQ_LINES_TMP.pricing_status_text%TYPE;

  -- <Bug 3794940 START>
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  -- <Bug 3794940 END>

  BEGIN

  -- Initialize OUT parameters
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_base_unit_price := p_unit_price;
    x_unit_price := p_unit_price;
    l_draft_id := p_draft_id; --Enhanced Pricing

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_org_id', p_org_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_supplier_id', p_supplier_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_supplier_site_id', p_supplier_site_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_creation_date', p_creation_date);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_order_type', p_order_type);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_ship_to_location_id', p_ship_to_location_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_ship_to_org_id', p_ship_to_org_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_order_header_id', p_order_header_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_order_line_id', p_order_line_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_item_revision', p_item_revision);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_item_id', p_item_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_category_id', p_category_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_supplier_item_num', p_supplier_item_num);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_agreement_type', p_agreement_type);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_agreement_id', p_agreement_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_agreement_line_id', p_agreement_line_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_rate', p_rate);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_rate_type', p_rate_type);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_currency_code', p_currency_code);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_need_by_date', p_need_by_date);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_quantity', p_quantity);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_uom', p_uom);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_unit_price', p_unit_price);
      --<Enhanced Pricing Start>
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_draft_id', p_draft_id);
	  --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_pricing_call_src', p_pricing_call_src);
      --<Enhanced Pricing End>
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Check Advanced Pricing License');
    END IF;

    FND_PROFILE.get('QP_LICENSED_FOR_PRODUCT', l_qp_license);
    l_qp_license_product := FND_PROFILE.VALUE_SPECIFIC(NAME => 'QP_LICENSED_FOR_PRODUCT',application_id => 201); /*Added for bug 8762015*/
    l_progress := '020';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_qp_license', l_qp_license);
    END IF;

  --Bug 5555953: Remove the logic to nullify the output unitprice if the Adv Pricing API
  --is not installed or licensed to PO;
  --IF (l_qp_license IS NULL OR l_qp_license <> 'PO') THEN
  /*****Modified the code for bug 8762015******/
    IF NOT ( ( Nvl(l_qp_license,'X') = 'PO') OR
             ( Nvl (l_qp_license_product,'X') = 'PO' )
           )
    THEN
      RETURN;
    END IF;

    l_progress := '040';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Set Price Request ID');
    END IF;

    QP_PRICE_REQUEST_CONTEXT.set_request_id;

    l_progress := '060';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Populate Global Header Structure');
    END IF;

    populate_header_record(
                           p_org_id => p_org_id,
                           p_order_header_id => p_order_header_id,
                           p_supplier_id => p_supplier_id,
                           p_supplier_site_id => p_supplier_site_id,
                           p_creation_date => p_creation_date,
                           p_order_type => p_order_type,
                           p_ship_to_location_id => p_ship_to_location_id,
                           p_ship_to_org_id => p_ship_to_org_id);

    l_progress := '080';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Populate Global Line Structure');
    END IF;

    populate_line_record(
                         p_order_line_id => p_order_line_id,
                         p_order_type => p_order_type, --Enhanced Pricing
                         p_item_revision => p_item_revision,
                         p_item_id => p_item_id,
                         p_category_id => p_category_id,
                         p_supplier_item_num => p_supplier_item_num,
                         p_agreement_type => p_agreement_type,
                         p_agreement_id => p_agreement_id,
                         p_agreement_line_id => p_agreement_line_id, --<R12 GBPA Adv Pricing>
                         p_supplier_id => p_supplier_id,
                         p_supplier_site_id => p_supplier_site_id,
                         p_ship_to_location_id => p_ship_to_location_id,
                         p_ship_to_org_id => p_ship_to_org_id,
                         p_rate => p_rate,
                         p_rate_type => p_rate_type,
                         p_currency_code => p_currency_code,
                         p_need_by_date => p_need_by_date);


    l_progress := '090';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Set OE Debug');
      OE_DEBUG_PUB.SetDebugLevel(10);
      PO_DEBUG.debug_stmt(l_log_head, l_progress, 'Debug File Location:'||
                          OE_DEBUG_PUB.Set_Debug_Mode('FILE'));
      OE_DEBUG_PUB.Initialize;
      OE_DEBUG_PUB.Debug_On;
    END IF;

    l_progress := '100';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Build Attributes Mapping Contexts');
    END IF;

    QP_Attr_Mapping_PUB.Build_Contexts(
                                       p_request_type_code => 'PO',
                                       p_line_index => 1,
                                       p_pricing_type_code => 'L',
                                       p_check_line_flag => 'N',
                                       p_pricing_event => 'PO_BATCH',
                                       x_pass_line => l_pass_line);

    l_progress := '110';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Get UOM Code');
    END IF;

    BEGIN
    -- Make sure we pass uom_code instead of unit_of_measure.
      SELECT mum.uom_code
      INTO l_uom_code
      FROM mtl_units_of_measure mum
      WHERE mum.unit_of_measure = p_uom;
    EXCEPTION
      WHEN OTHERS THEN
        l_uom_code := p_uom;
    END;

    l_progress := '120';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_uom_code', l_uom_code);
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Directly Insert into Temp table');
    END IF;

    l_request_type_code_tbl(1) := 'PO';
    l_line_id_tbl(1) := l_line_id; -- order line id
    l_line_index_tbl(1) := 1; -- Request Line Index
    l_line_type_code_tbl(1) := 'LINE'; -- LINE or ORDER(Summary Line)
    l_pricinl_effective_date_tbl(1) := p_need_by_date;-- Pricing as of effective date
    l_active_date_first_tbl(1) := NULL; -- Can be Ordered Date or Ship Date
    l_active_date_second_tbl(1) := NULL; -- Can be Ordered Date or Ship Date
    l_active_date_first_type_tbl(1) := NULL; -- ORD/SHIP
    l_active_date_second_type_tbl(1) := NULL; -- ORD/SHIP
    l_line_unit_price_tbl(1) := p_unit_price;-- Unit Price
  -- Bug 3315550, should pass 1 instead of NULL
    l_line_quantity_tbl(1) := NVL(p_quantity, 1);-- Ordered Quantity
  -- Bug 3564136, don't pass 0, pass 1 instead
    IF (l_line_quantity_tbl(1) = 0) THEN
      l_line_quantity_tbl(1) := 1;
    END IF; /*IF (l_line_quantity_tbl(1) = 0)*/

    l_line_uom_code_tbl(1) := l_uom_code; -- Ordered UOM Code
    l_currency_code_tbl(1) := p_currency_code;-- Currency Code
    l_price_flag_tbl(1) := 'Y'; -- Price Flag can have 'Y',
                                               		-- 'N'(No pricing),
                                               		-- 'P'(Phase)
    l_usage_pricing_type_tbl(1) := QP_PREQ_GRP.g_regular_usage_type;
  -- Bug 3564136, don't pass 0, pass 1 instead
  -- Bug 3315550, should pass 1 instead of NULL
    l_priced_quantity_tbl(1) := NVL(p_quantity, 1);
  -- Bug 3564136, don't pass 0, pass 1 instead
    IF (l_priced_quantity_tbl(1) = 0) THEN
      l_priced_quantity_tbl(1) := 1;
    END IF; /*IF (l_line_quantity_tbl(1) = 0)*/
    l_priced_uom_code_tbl(1) := l_uom_code;
    l_unit_price_tbl(1) := p_unit_price;
    l_percent_price_tbl(1) := null;
    l_uom_quantity_tbl(1) := null;
    l_adjusted_unit_price_tbl(1) := null;
    l_upd_adjusted_unit_price_tbl(1) := null;
    l_processed_flag_tbl(1) := null;
    l_processing_order_tbl(1) := null;
    l_pricing_status_code_tbl(1) := QP_PREQ_GRP.g_status_unchanged;
    l_pricing_status_text_tbl(1) := null;
    l_rounding_flag_tbl(1) := null;
    l_rounding_factor_tbl(1) := null;
    l_qualifiers_exist_flag_tbl(1) := 'N';
    l_pricing_attrs_exist_flag_tbl(1) := 'N';
    l_price_list_id_tbl(1) :=  - 9999;
    l_pl_validated_flag_tbl(1) := 'N';
    l_price_request_code_tbl(1) := null;
    l_line_category_tbl(1) := null;
    l_list_price_overide_flag_tbl(1) := 'O'; -- Override price

    l_progress := '140';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Call INSERT_LINES2');
    END IF;

    QP_PREQ_GRP.INSERT_LINES2
    (p_line_index => l_line_index_tbl,
     p_line_type_code => l_line_type_code_tbl,
     p_pricing_effective_date => l_pricinl_effective_date_tbl,
     p_active_date_first => l_active_date_first_tbl,
     p_active_date_first_type => l_active_date_first_type_tbl,
     p_active_date_second => l_active_date_second_tbl,
     p_active_date_second_type => l_active_date_second_type_tbl,
     p_line_quantity => l_line_quantity_tbl,
     p_line_uom_code => l_line_uom_code_tbl,
     p_request_type_code => l_request_type_code_tbl,
     p_priced_quantity => l_priced_quantity_tbl,
     p_priced_uom_code => l_priced_uom_code_tbl,
     p_currency_code => l_currency_code_tbl,
     p_unit_price => l_unit_price_tbl,
     p_percent_price => l_percent_price_tbl,
     p_uom_quantity => l_uom_quantity_tbl,
     p_adjusted_unit_price => l_adjusted_unit_price_tbl,
     p_upd_adjusted_unit_price => l_upd_adjusted_unit_price_tbl,
     p_processed_flag => l_processed_flag_tbl,
     p_price_flag => l_price_flag_tbl,
     p_line_id => l_line_id_tbl,
     p_processing_order => l_processing_order_tbl,
     p_pricing_status_code => l_pricing_status_code_tbl,
     p_pricing_status_text => l_pricing_status_text_tbl,
     p_rounding_flag => l_rounding_flag_tbl,
     p_rounding_factor => l_rounding_factor_tbl,
     p_qualifiers_exist_flag => l_qualifiers_exist_flag_tbl,
     p_pricing_attrs_exist_flag => l_pricing_attrs_exist_flag_tbl,
     p_price_list_id => l_price_list_id_tbl,
     p_validated_flag => l_pl_validated_flag_tbl,
     p_price_request_code => l_price_request_code_tbl,
     p_usage_pricing_type => l_usage_pricing_type_tbl,
     p_line_category => l_line_category_tbl,
     p_line_unit_price => l_line_unit_price_tbl,
     p_list_price_override_flag => l_list_price_overide_flag_tbl,
     x_status_code => x_return_status,
     x_status_text => l_return_status_text);

    l_progress := '160';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'After Calling INSERT_LINES2');
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_return_status', x_return_status);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_return_status_text', l_return_status_text);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  -- Don't call QP_PREQ_GRP.INSERT_LINE_ATTRS2 since PO has no
  -- ASK_FOR attributes

    --Enhanced Pricing Start: Call to populate manual and overridden modifiers in QP temp tables
    --Check if the agreement allows price override
    IF p_agreement_type = 'BLANKET' AND
       p_agreement_id IS NOT NULL AND
       p_agreement_line_id IS NOT NULL  THEN
      SELECT POL.allow_price_override_flag
      INTO l_allow_price_override_flag
      FROM po_lines_all POL
      WHERE POL.po_header_id = p_agreement_id
      AND   POL.po_line_id = p_agreement_line_id;
    ELSE
      l_allow_price_override_flag := 'Y';
    END IF;

    --Initialize In Parameters
    l_order_line_id_tbl(1) := p_order_line_id;
    l_quantity_tbl(1) := NVL(p_quantity, 1);
    --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
    IF NVL(l_allow_price_override_flag, 'Y') = 'Y' AND
       (p_pricing_call_src IS NULL OR p_pricing_call_src <> 'RETRO') AND
	   (l_draft_id IS NOT NULL OR p_pricing_call_src = 'AUTO') THEN
      PO_PRICE_ADJUSTMENTS_PKG.popl_manual_overridden_adj
        (p_draft_id          => l_draft_id
        ,p_order_header_id   => p_order_header_id
        ,p_order_line_id_tbl => l_order_line_id_tbl
        ,p_quantity_tbl      => l_quantity_tbl
        ,x_return_status     => x_return_status
        );
    END IF;
    --Enhanced Pricing End

    l_progress := '180';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,
                          'Populate Control Record for Pricing Request Call');
    END IF;

    l_control_rec.calculate_flag := 'Y';
    l_control_rec.simulation_flag := 'N';
    l_control_rec.pricing_event := 'PO_BATCH';
    l_control_rec.temp_table_insert_flag := 'N';
    l_control_rec.check_cust_view_flag := 'N';
    l_control_rec.request_type_code := 'PO';
  --now pricing take care of all the roundings.
    l_control_rec.rounding_flag := 'Q';
  --For multi_currency price list
    l_control_rec.use_multi_currency := 'Y';
    l_control_rec.user_conversion_rate := PO_ADVANCED_PRICE_PVT.g_line.rate;
    l_control_rec.user_conversion_type := PO_ADVANCED_PRICE_PVT.g_line.rate_type;

 -- bug 16339194 start
 -- Passing set of books currency code as functional currency instead of line currency

   BEGIN

    select gl.currency_code
    into l_control_rec.function_currency
    FROM FINANCIALS_SYSTEM_PARAMETERS fsp,gl_sets_of_books gl
    WHERE fsp.SET_OF_BOOKS_ID = gl.SET_OF_BOOKS_ID;

   EXCEPTION

   WHEN OTHERS THEN

   l_control_rec.function_currency := PO_ADVANCED_PRICE_PVT.g_line.currency_code;

   END;

   -- l_control_rec.function_currency := PO_ADVANCED_PRICE_PVT.g_line.currency_code;

 -- bug 16339194 end

    l_control_rec.get_freight_flag := 'N';

    l_progress := '200';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Call PRICE_REQUEST');
    END IF;

    QP_PREQ_PUB.PRICE_REQUEST(
                              p_control_rec => l_control_rec,
                              x_return_status => x_return_status,
                              x_return_status_Text => l_return_status_Text);

    l_progress := '220';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_return_status', x_return_status);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_return_status_text', l_return_status_text);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Enhanced Pricing Start:
    --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
    IF p_pricing_call_src IS NOT NULL AND (p_pricing_call_src = 'RETRO' OR p_pricing_call_src = 'AUTO') THEN
      IF (l_draft_id IS NULL) THEN
        l_draft_id := 1; --default the draft id, used when merging the changes
      END IF;
    END IF;

    IF (l_draft_id IS NOT NULL OR p_pricing_call_src IS NOT NULL) THEN
      PO_PRICE_ADJUSTMENTS_PKG.extract_price_adjustments
        (p_draft_id          => l_draft_id
        ,p_order_header_id   => p_order_header_id
        ,p_order_line_id_tbl => l_order_line_id_tbl
        ,p_pricing_events    => l_pricing_events
        ,p_calculate_flag    => l_control_rec.calculate_flag
        ,p_doc_sub_type      => 'PO'
        ,p_pricing_call_src     => p_pricing_call_src
        ,p_allow_price_override_tbl => PO_TBL_VARCHAR1(l_allow_price_override_flag)
        ,x_return_status     => x_return_status
        );
     END IF;
    --Exceptions raised by this procedure is handled in the exception section
    --Enhanced Pricing End:

  -- <Bug 3794940 START>
    PO_CUSTOM_PRICE_PUB.audit_qp_price_adjustment(
                                                  p_api_version => 1.0
                                                  , p_order_type => p_order_type
                                                  , p_order_line_id => l_line_id
                                                  , p_line_index => 1
                                                  , x_return_status => l_return_status
                                                  , x_msg_count => l_msg_count
                                                  , x_msg_data => l_msg_data
                                                  );

    l_progress := '230';
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_return_status', l_return_status);
      PO_DEBUG.debug_unexp(l_log_head, l_progress,'audit_qp_price_adjustment errors out');
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_msg_data);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  -- <Bug 3794940 END>

    l_progress := '240';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Fetch QP pricing');
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_line_id', l_line_id);
      PO_DEBUG.debug_table(l_log_head, l_progress, 'QP_PREQ_LINES_TMP_T', PO_DEBUG.g_all_rows, NULL, 'QP');
    END IF;

  /* Use API insted
  -- SQL What: Fetch Price from Pricing Temp table
  -- SQL Why:  Return Advanced Pricing
  SELECT line_unit_price,
         adjusted_unit_price,
         pricing_status_code,
         pricing_status_text
  INTO   x_base_unit_price,
         x_unit_price,
         l_price_status_code,
         l_price_status_text
  FROM   QP_PREQ_LINES_TMP
  WHERE  line_id = l_line_id
  AND    (processed_code IS NULL OR processed_code <> 'INVALID');
  */

    QP_PREQ_PUB.get_price_for_line(
                                   p_line_index => 1
                                   , p_line_id => l_line_id
                                   , x_line_unit_price => x_base_unit_price
                                   , x_adjusted_unit_price => x_unit_price
                                   , x_return_status => x_return_status
                                   , x_pricing_status_code => l_price_status_code
                                   , x_pricing_status_text => l_price_status_text
                                   );

    l_progress := '260';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_return_status', x_return_status);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_base_unit_price', x_base_unit_price);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_unit_price', x_unit_price);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_price_status_code', l_price_status_code);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_price_status_text', l_price_status_text);
    END IF;

    x_unit_price := NVL(x_unit_price, x_base_unit_price);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_price_status_text);
      x_return_status := FND_API.g_ret_sts_error;
    END IF;

    l_progress := '300';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(l_log_head);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_return_status',
                         x_return_status);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_base_unit_price',
                         x_base_unit_price);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_unit_price',
                         x_unit_price);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    --raised expected error: assume raiser already pushed onto the stack
      l_exception_msg := FND_MSG_PUB.get(
                                         p_msg_index => FND_MSG_PUB.G_LAST
                                         , p_encoded => 'F'
                                         );
      IF g_debug_unexp THEN
        PO_DEBUG.debug_var(l_log_head, l_progress, 'l_exception_msg',
                           l_exception_msg);
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
    -- Push the po_return_msg onto msg list and message stack
      FND_MESSAGE.set_name('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_exception_msg);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --raised unexpected error: assume raiser already pushed onto the stack
      l_exception_msg := FND_MSG_PUB.get(
                                         p_msg_index => FND_MSG_PUB.G_LAST
                                         , p_encoded => 'F'
                                         );
      IF g_debug_unexp THEN
        PO_DEBUG.debug_var(l_log_head, l_progress, 'l_exception_msg',
                           l_exception_msg);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
    -- Push the po_return_msg onto msg list and message stack
      FND_MESSAGE.set_name('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_exception_msg);

    WHEN OTHERS THEN
      IF g_debug_unexp THEN
        PO_DEBUG.debug_exc(l_log_head, l_progress);
      END IF;
    --unexpected error from this procedure: get SQLERRM
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      l_exception_msg := FND_MESSAGE.get;
      IF g_debug_unexp THEN
        PO_DEBUG.debug_var(l_log_head, l_progress, 'l_exception_msg',
                           l_exception_msg);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
    -- Push the po_return_msg onto msg list and message stack
      FND_MESSAGE.set_name('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_exception_msg);
  END get_advanced_price;


--------------------------------------------------------------------------------
--Start of Comments
--Name: is_valid_qp_line_type
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure checks valid line type for advanced pricing call.
--  Any Line type with combination of Value Basis (Amount/Rate/Fixed Price)
--  and Purchase Basis (Temp Labor/Services) is invalid.
--Parameters:
--IN:
--p_line_type_id
--  Line Type ID.
--RETURN:
--  FALSE: Invalid Line type to call Advanced Pricing API
--  TRUE: Valid Line type to call Advanced Pricing API
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
  FUNCTION is_valid_qp_line_type
  (p_line_type_id IN NUMBER
   ) RETURN BOOLEAN
  IS
  l_api_name CONSTANT VARCHAR2(30) := 'IS_VALID_QP_LINE_TYPE';
  l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress VARCHAR2(3) := '000';
  l_purchase_basis PO_LINE_TYPES.purchase_basis%TYPE;
  -- Bug 3343261: should use value_basis instead of matching_basis
  -- l_matching_basis	PO_LINE_TYPES.matching_basis%TYPE;
  l_value_basis PO_LINE_TYPES.order_type_lookup_code%TYPE;
  BEGIN
    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_line_type_id', p_line_type_id);
    END IF;

    IF (p_line_type_id IS NULL) THEN
      RETURN TRUE;
    END IF;

    l_progress := '010';
    SELECT purchase_basis,
         -- Bug 3343261: should use value_basis instead of matching_basis
         -- matching_basis,
           order_type_lookup_code
    INTO l_purchase_basis,
         -- Bug 3343261: should use value_basis instead of matching_basis
         -- l_matching_basis,
           l_value_basis
    FROM PO_LINE_TYPES
    WHERE line_type_id = p_line_type_id;

    l_progress := '020';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Retrieved line type');
    END IF;

    IF (l_purchase_basis IN ('TEMP LABOR', 'SERVICES') AND
  -- Bug 3343261: should use value_basis instead of matching_basis
        l_value_basis IN ('AMOUNT', 'RATE', 'FIXED PRICE')) THEN
      RETURN FALSE;
    END IF;

    l_progress := '030';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(l_log_head);
    END IF;

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END is_valid_qp_line_type;

-- <FSC R12 START>
--------------------------------------------------------------------------------
--Start of Comments
--Name: get_advanced_price
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Procedure:
--  This procedure calls out to QP for getting the adjusted price and
--  freight and speacial charges. This takes in a document in the form of
--  header record and a table of line records
--Parameters:
--IN:
--  p_header_rec  Header_Rec_Type  This will keep the document header information
--  p_line_rec_tbl Line_tbl_type   This willl keep the table of the lines for the
--  p_request_type                 Request type to be passed to QP.
--  p_pricing_event                pricing event set up in QP for the processing
--  p_has_header_pricing           True, when header line is also included in pricing
--  p_return_price_flag            True, when the caller wants the adjusted rice info
--                                 also in the returned record
--  p_return_freight_flag          True, when the caller wants the API to return
--                                 freight charge related info.
--
--OUT:
--  x_return_status                Return status for the QP call.
--  x_price_tbl                    Table of resulted info from QP for each line
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE get_advanced_price(p_header_rec Header_rec_type,
                               p_line_rec_tbl Line_Tbl_Type,
                               p_request_type IN VARCHAR2,
                               p_pricing_event IN VARCHAR2,
                               p_has_header_pricing IN BOOLEAN,
                               p_return_price_flag IN BOOLEAN,
                               p_return_freight_flag IN BOOLEAN,
                               p_price_adjustment_flag IN BOOLEAN DEFAULT NULL, -- <PDOI Enhancement Bug#17063664>
                               p_draft_id  IN NUMBER DEFAULT NULL, -- <PDOI Enhancement Bug#17063664>
                               x_price_tbl OUT NOCOPY Qp_Price_Result_Rec_Tbl_Type,
                               x_return_status OUT NOCOPY VARCHAR2) IS
  l_api_name CONSTANT VARCHAR2(30) := 'GET_ADVANCED_PRICE';
  l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  d_pos NUMBER;
  l_exception_msg FND_NEW_MESSAGES.message_text%TYPE;
  l_qp_license VARCHAR2(30) := NULL;
  l_uom_code MTL_UNITS_OF_MEASURE.uom_code%TYPE;
  l_return_status_text VARCHAR2(2000);
  l_control_rec QP_PREQ_GRP.control_record_type;
  l_pass_line VARCHAR2(1);
  l_line_index_tbl QP_PREQ_GRP.pls_integer_type;
  l_line_type_code_tbl QP_PREQ_GRP.varchar_type;
  l_pricinl_effective_date_tbl QP_PREQ_GRP.date_type ;
  l_active_date_first_tbl QP_PREQ_GRP.date_type ;
  l_active_date_first_type_tbl QP_PREQ_GRP.varchar_type;
  l_active_date_second_tbl QP_PREQ_GRP.date_type ;
  l_active_date_second_type_tbl QP_PREQ_GRP.varchar_type ;
  l_line_unit_price_tbl QP_PREQ_GRP.number_type ;
  l_line_quantity_tbl QP_PREQ_GRP.number_type ;
  l_line_uom_code_tbl QP_PREQ_GRP.varchar_type;
  l_request_type_code_tbl QP_PREQ_GRP.varchar_type;
  l_priced_quantity_tbl QP_PREQ_GRP.number_type;
  l_uom_quantity_tbl QP_PREQ_GRP.number_type;
  l_priced_uom_code_tbl QP_PREQ_GRP.varchar_type;
  l_currency_code_tbl QP_PREQ_GRP.varchar_type;
  l_unit_price_tbl QP_PREQ_GRP.number_type;
  l_percent_price_tbl QP_PREQ_GRP.number_type;
  l_adjusted_unit_price_tbl QP_PREQ_GRP.number_type;
  l_upd_adjusted_unit_price_tbl QP_PREQ_GRP.number_type;
  l_processed_flag_tbl QP_PREQ_GRP.varchar_type;
  l_price_flag_tbl QP_PREQ_GRP.varchar_type;
  l_line_id_tbl QP_PREQ_GRP.number_type;
  l_processing_order_tbl QP_PREQ_GRP.pls_integer_type;
  l_rounding_factor_tbl QP_PREQ_GRP.pls_integer_type;
  l_rounding_flag_tbl QP_PREQ_GRP.flag_type;
  l_qualifiers_exist_flag_tbl QP_PREQ_GRP.varchar_type;
  l_pricing_attrs_exist_flag_tbl QP_PREQ_GRP.varchar_type;
  l_price_list_id_tbl QP_PREQ_GRP.number_type;
  l_pl_validated_flag_tbl QP_PREQ_GRP.varchar_type;
  l_price_request_code_tbl QP_PREQ_GRP.varchar_type;
  l_usage_pricing_type_tbl QP_PREQ_GRP.varchar_type;
  l_line_category_tbl QP_PREQ_GRP.varchar_type;
  l_pricing_status_code_tbl QP_PREQ_GRP.varchar_type;
  l_pricing_status_text_tbl QP_PREQ_GRP.varchar_type;
  l_list_price_overide_flag_tbl QP_PREQ_GRP.varchar_type;
  i PLS_INTEGER := 1;
  j PLS_INTEGER := 1;
  k PLS_INTEGER := 1;
  l_freight_charge_rec_tbl Freight_Charges_Rec_Tbl_Type;

  --<PDOI Enhancement Bug#17063664>
  l_order_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
  l_quantity_tbl      QP_PREQ_GRP.NUMBER_TYPE;
  l_allow_price_override_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
  l_line_count PLS_INTEGER := 1;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  BEGIN

  -- Initialize OUT parameters
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF g_debug_stmt THEN
      PO_LOG.proc_begin(l_log_head);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.org_id', p_header_rec.org_id);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.p_order_header_id', p_header_rec.p_order_header_id);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.supplier_id', p_header_rec.supplier_id);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.supplier_site_id', p_header_rec.supplier_site_id);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.creation_date', p_header_rec.creation_date);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.order_type', p_header_rec.order_type);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.ship_to_location_id', p_header_rec.ship_to_location_id);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.ship_to_org_id', p_header_rec.ship_to_org_id);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.shipment_header_id', p_header_rec.shipment_header_id);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.hazard_class', p_header_rec.hazard_class);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.hazard_code', p_header_rec.hazard_code);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.shipped_date', p_header_rec.shipped_date);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.shipment_num', p_header_rec.shipment_num);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.carrier_method', p_header_rec.carrier_method);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.packaging_code', p_header_rec.packaging_code);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.freight_carrier_code', p_header_rec.freight_carrier_code);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.freight_terms', p_header_rec.freight_terms);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.currency_code', p_header_rec.currency_code);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.rate', p_header_rec.rate);
      PO_LOG.proc_begin(l_log_head, 'p_header_rec.rate_type', p_header_rec.rate_type);


      FOR i IN 1..p_line_rec_tbl.COUNT LOOP
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').order_line_id', p_line_rec_tbl(i).order_line_id);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').order_type', p_line_rec_tbl(i).order_type); --Enhanced Pricing
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').agreement_type', p_line_rec_tbl(i).agreement_type);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').agreement_id', p_line_rec_tbl(i).agreement_id);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').agreement_line_id', p_line_rec_tbl(i).agreement_line_id);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').supplier_id', p_line_rec_tbl(i).supplier_id);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').supplier_site_id', p_line_rec_tbl(i).supplier_site_id);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').ship_to_location_id', p_line_rec_tbl(i). ship_to_location_id);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').ship_to_org_id', p_line_rec_tbl(i).ship_to_org_id);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').supplier_item_num', p_line_rec_tbl(i).supplier_item_num);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').item_revision', p_line_rec_tbl(i).item_revision);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').item_id', p_line_rec_tbl(i).item_id);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').category_id', p_line_rec_tbl(i).category_id);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').rate', p_line_rec_tbl(i).rate);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').rate_type', p_line_rec_tbl(i).rate_type);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').currency_code', p_line_rec_tbl(i).currency_code);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').need_by_date', p_line_rec_tbl(i).need_by_date);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').shipment_line_id', p_line_rec_tbl(i).shipment_line_id);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').primary_unit_of_measure', p_line_rec_tbl(i).primary_unit_of_measure);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').to_organization_id', p_line_rec_tbl(i).to_organization_id);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').unit_of_measure', p_line_rec_tbl(i).unit_of_measure);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').source_document_code', p_line_rec_tbl(i).source_document_code);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').unit_price', p_line_rec_tbl(i).unit_price);
        PO_LOG.proc_begin(l_log_head, 'p_line_rec_tbl(' || i || ').quantity', p_line_rec_tbl(i).quantity);
      END LOOP;

      PO_LOG.proc_begin(l_log_head, 'p_request_type', p_request_type);
      PO_LOG.proc_begin(l_log_head, 'p_pricing_event', p_pricing_event);
      PO_LOG.proc_begin(l_log_head, 'p_has_header_pricing', p_has_header_pricing);
      PO_LOG.proc_begin(l_log_head, 'p_return_price_flag', p_return_price_flag);
      PO_LOG.proc_begin(l_log_head, 'p_return_freight_flag', p_return_freight_flag);
    END IF;

    x_price_tbl := Qp_Price_Result_Rec_Tbl_Type();
    PO_LOG.stmt(l_log_head, d_pos,'Check Advanced Pricing License');
    FND_PROFILE.get('QP_LICENSED_FOR_PRODUCT', l_qp_license);
    d_pos := 20;
    IF g_debug_stmt THEN
      PO_LOG.stmt(l_log_head, d_pos, 'l_qp_license', l_qp_license);
    END IF;

    IF (l_qp_license IS NULL OR l_qp_license <> 'PO') THEN
      RETURN;
    END IF;

    d_pos := 40;
    IF g_debug_stmt THEN
      PO_LOG.stmt(l_log_head, d_pos,'Set Price Request ID');
    END IF;

    QP_PRICE_REQUEST_CONTEXT.set_request_id;

    d_pos := 60;
    IF g_debug_stmt THEN
      PO_LOG.stmt(l_log_head, d_pos,'Populate Global Header Structure');
    END IF;

    populate_header_record(
                           p_org_id => p_header_rec.org_id,
                           p_order_header_id => p_header_rec.p_order_header_id,
                           p_supplier_id => p_header_rec.supplier_id,
                           p_supplier_site_id => p_header_rec.supplier_site_id,
                           p_creation_date => p_header_rec.creation_date,
                           p_order_type => p_header_rec.order_type,
                           p_ship_to_location_id => p_header_rec.ship_to_location_id,
                           p_ship_to_org_id => p_header_rec.ship_to_org_id,
       -- New Attributes for R12: Receving FSC support
                           p_shipment_header_id => p_header_rec.shipment_header_id,
                           p_hazard_class => p_header_rec.hazard_class,
                           p_hazard_code => p_header_rec.hazard_code,
                           p_shipped_date => p_header_rec.shipped_date,
                           p_shipment_num => p_header_rec.shipment_num,
                           p_carrier_method => p_header_rec.carrier_method,
                           p_packaging_code => p_header_rec.packaging_code,
                           p_freight_carrier_code => p_header_rec.freight_carrier_code,
                           p_freight_terms => p_header_rec.freight_terms,
                           p_currency_code => p_header_rec.currency_code,
                           p_rate => p_header_rec.rate,
                           p_rate_type => p_header_rec.rate_type,
                           p_source_org_id => p_header_rec.source_org_id,
                           p_expected_receipt_date => p_header_rec.expected_receipt_date);

    d_pos := 80;
    IF g_debug_stmt THEN
      PO_LOG.stmt(l_log_head, d_pos ,'Populate Global Line Structure');
    END IF;

    i := 1;

    d_pos := 90;
    IF g_debug_stmt THEN
      PO_LOG.stmt(l_log_head, d_pos,'Set OE Debug');
      OE_DEBUG_PUB.SetDebugLevel(10);
      PO_LOG.stmt(l_log_head, d_pos, 'Debug File Location: '|| OE_DEBUG_PUB.Set_Debug_Mode('FILE'));
      OE_DEBUG_PUB.Initialize;
      OE_DEBUG_PUB.Debug_On;
    END IF;

    d_pos := 100;

    IF(p_has_header_pricing) THEN
      d_pos := 110;
      IF g_debug_stmt THEN
        PO_LOG.stmt(l_log_head, d_pos,'Build Attributes Mapping Contexts for header');
      END IF;
      QP_Attr_Mapping_PUB.Build_Contexts(p_request_type_code => p_request_type,
                                         p_line_index => i,
                                         p_pricing_type_code => 'H',
                                         p_check_line_flag => 'N',
                                         p_pricing_event => p_pricing_event,
                                         x_pass_line => l_pass_line);
      d_pos := 120;

      l_request_type_code_tbl(i) := p_request_type;
      l_line_id_tbl(i) := nvl(p_header_rec.p_order_header_id, p_header_rec.shipment_header_id);-- header id
      l_line_index_tbl(i) := i; -- Request Line Index
      l_line_type_code_tbl(i) := 'ORDER'; -- LINE or ORDER(Summary Line)
      l_pricinl_effective_date_tbl(i) := SYSDATE;-- Pricing as of effective date
      l_active_date_first_tbl(i) := null; -- Can be Ordered Date or Ship Date
      l_active_date_second_tbl(i) := null; -- Can be Ordered Date or Ship Date
      l_active_date_first_type_tbl(i) := null; -- ORD/SHIP
      l_active_date_second_type_tbl(i) := null; -- ORD/SHIP
      l_line_unit_price_tbl(i) := null;-- Unit Price
      l_line_quantity_tbl(i) := null;-- Ordered Quantity
      l_line_uom_code_tbl(i) := null;-- Ordered UOM Code
      l_currency_code_tbl(i) := p_header_rec.currency_code;-- Currency Code
      l_price_flag_tbl(i) := 'Y'; -- Price Flag can have 'Y',
                                                -- 'N'(No pricing),
                                               	-- 'P'(Phase)
      l_usage_pricing_type_tbl(i) := QP_PREQ_GRP.g_regular_usage_type;
      l_priced_quantity_tbl(i) := null;
      l_priced_uom_code_tbl(i) := null;
      l_unit_price_tbl(i) := null;
      l_percent_price_tbl(i) := null;
      l_uom_quantity_tbl(i) := null;
      l_adjusted_unit_price_tbl(i) := null;
      l_upd_adjusted_unit_price_tbl(i) := null;
      l_processed_flag_tbl(i) := null;
      l_processing_order_tbl(i) := null;
      l_pricing_status_code_tbl(i) := QP_PREQ_GRP.g_status_unchanged;
      l_pricing_status_text_tbl(i) := null;
      l_rounding_flag_tbl(i) := null;
      l_rounding_factor_tbl(i) := null;
      l_qualifiers_exist_flag_tbl(i) := 'N';
      l_pricing_attrs_exist_flag_tbl(i) := 'N';
      l_price_list_id_tbl(i) :=  - 9999;
      l_pl_validated_flag_tbl(i) := 'N';
      l_price_request_code_tbl(i) := null;
      l_line_category_tbl(i) := null;
      l_list_price_overide_flag_tbl(i) := 'O'; -- Override price

      i := i + 1;
      d_pos := 130;
    END IF;


    FOR j IN 1..p_line_rec_tbl.COUNT LOOP
      populate_line_record(
                           p_order_line_id => p_line_rec_tbl(j).order_line_id,
                           p_order_type => p_line_rec_tbl(j).order_type, --Enhanced Pricing
                           p_item_revision => p_line_rec_tbl(j).item_revision,
                           p_item_id => p_line_rec_tbl(j).item_id,
                           p_category_id => p_line_rec_tbl(j).category_id,
                           p_supplier_item_num => p_line_rec_tbl(j).supplier_item_num,
                           p_agreement_type => p_line_rec_tbl(j).agreement_type,
                           p_agreement_id => p_line_rec_tbl(j).agreement_id,
                           p_agreement_line_id => p_line_rec_tbl(j).agreement_line_id, --<R12 GBPA Adv Pricing>
                           p_supplier_id => p_line_rec_tbl(j).supplier_id,
                           p_supplier_site_id => p_line_rec_tbl(j).supplier_site_id,
                           p_ship_to_location_id => p_line_rec_tbl(j).ship_to_location_id,
                           p_ship_to_org_id => p_line_rec_tbl(j).ship_to_org_id,
                           p_rate => p_line_rec_tbl(j).rate,
                           p_rate_type => p_line_rec_tbl(j).rate_type,
                           p_currency_code => p_line_rec_tbl(j).currency_code,
                           p_need_by_date => p_line_rec_tbl(j).need_by_date,
      -- New Attributes for R12: Receving FSC support
                           p_shipment_line_id => p_line_rec_tbl(j).shipment_line_id,
                           p_primary_unit_of_measure => p_line_rec_tbl(j).primary_unit_of_measure,
                           p_to_organization_id => p_line_rec_tbl(j).to_organization_id,
                           p_unit_of_measure => p_line_rec_tbl(j).unit_of_measure,
                           p_source_document_code => p_line_rec_tbl(j).source_document_code,
                           p_quantity => p_line_rec_tbl(j).quantity);

      d_pos := 140;

      IF g_debug_stmt THEN
        --make the pricing debug ON
        PO_DEBUG.debug_stmt(l_log_head, d_pos,'Set OE Debug');
        OE_DEBUG_PUB.SetDebugLevel(10);
        PO_DEBUG.debug_stmt(l_log_head, d_pos, 'Debug File Location: '||
                            OE_DEBUG_PUB.Set_Debug_Mode('FILE'));
        OE_DEBUG_PUB.Initialize;
        OE_DEBUG_PUB.Debug_On;
      END IF;

      d_pos := 150;
      IF g_debug_stmt THEN
        PO_LOG.stmt(l_log_head, d_pos,'Build Attributes Mapping Contexts for Line('|| j || ')');
      END IF;

      QP_Attr_Mapping_PUB.Build_Contexts(
                                         p_request_type_code => p_request_type,
                                         p_line_index => i,
                                         p_pricing_type_code => 'L',
                                         p_check_line_flag => 'N',
                                         p_pricing_event => p_pricing_event,
                                         x_pass_line => l_pass_line);

      d_pos := 160;
      IF g_debug_stmt THEN
        PO_LOG.stmt(l_log_head, d_pos,'Get UOM Code');
      END IF;

      BEGIN
        -- Make sure we pass uom_code instead of unit_of_measure.
        SELECT mum.uom_code
        INTO l_uom_code
        FROM mtl_units_of_measure mum
        WHERE mum.unit_of_measure = p_line_rec_tbl(j).unit_of_measure;
      EXCEPTION
        WHEN OTHERS THEN
          l_uom_code := p_line_rec_tbl(j).unit_of_measure;
      END;

      d_pos := 170;
      IF g_debug_stmt THEN
        PO_LOG.stmt(l_log_head, d_pos, 'l_uom_code', l_uom_code);
        PO_LOG.stmt(l_log_head, d_pos,'Directly Insert into Temp table');
      END IF;

      l_request_type_code_tbl(i) := p_request_type;
      l_line_id_tbl(i) := nvl(p_line_rec_tbl(j).order_line_id, p_line_rec_tbl(j).shipment_line_id); -- order line id
      l_line_index_tbl(i) := i; -- Request Line Index
      l_line_type_code_tbl(i) := 'LINE'; -- LINE or ORDER(Summary Line)
      l_pricinl_effective_date_tbl(i) := p_line_rec_tbl(j).need_by_date;-- Pricing as of effective date
      l_active_date_first_tbl(i) := NULL; -- Can be Ordered Date or Ship Date
      l_active_date_second_tbl(i) := NULL; -- Can be Ordered Date or Ship Date
      l_active_date_first_type_tbl(i) := NULL; -- ORD/SHIP
      l_active_date_second_type_tbl(i) := NULL; -- ORD/SHIP
      l_line_unit_price_tbl(i) := p_line_rec_tbl(j).unit_price;-- Unit Price
      l_line_quantity_tbl(i) := NVL(p_line_rec_tbl(j).quantity, 1);-- Ordered Quantity

      IF (l_line_quantity_tbl(i) = 0) THEN
        l_line_quantity_tbl(i) := 1;
      END IF;

      l_line_uom_code_tbl(i) := l_uom_code; -- Ordered UOM Code
      l_currency_code_tbl(i) := p_line_rec_tbl(j).currency_code;-- Currency Code
      l_price_flag_tbl(i) := 'Y'; -- Price Flag can have 'Y',
                                               		-- 'N'(No pricing),
                                               		-- 'P'(Phase)
      l_usage_pricing_type_tbl(i) := QP_PREQ_GRP.g_regular_usage_type;
      l_priced_quantity_tbl(i) := NVL(p_line_rec_tbl(j).quantity, 1);
      IF (l_priced_quantity_tbl(i) = 0) THEN
        l_priced_quantity_tbl(i) := 1;
      END IF;
      l_priced_uom_code_tbl(i) := l_uom_code;
      l_unit_price_tbl(i) := p_line_rec_tbl(j).unit_price;
      l_percent_price_tbl(i) := null;
      l_uom_quantity_tbl(i) := null;
      l_adjusted_unit_price_tbl(i) := null;
      l_upd_adjusted_unit_price_tbl(i) := null;
      l_processed_flag_tbl(i) := null;
      l_processing_order_tbl(i) := null;
      l_pricing_status_code_tbl(i) := QP_PREQ_GRP.g_status_unchanged;
      l_pricing_status_text_tbl(i) := null;
      l_rounding_flag_tbl(i) := null;
      l_rounding_factor_tbl(i) := null;
      l_qualifiers_exist_flag_tbl(i) := 'N';
      l_pricing_attrs_exist_flag_tbl(i) := 'N';
      l_price_list_id_tbl(i) :=  - 9999;
      l_pl_validated_flag_tbl(i) := 'N';
      l_price_request_code_tbl(i) := null;
      l_line_category_tbl(i) := null;
      l_list_price_overide_flag_tbl(i) := 'O'; -- Override price

      i := i + 1;

    END LOOP;

    d_pos := 180;
    IF g_debug_stmt THEN
      PO_LOG.stmt(l_log_head, d_pos,'Call INSERT_LINES2');
    END IF;

    QP_PREQ_GRP.INSERT_LINES2
    (p_line_index => l_line_index_tbl,
     p_line_type_code => l_line_type_code_tbl,
     p_pricing_effective_date => l_pricinl_effective_date_tbl,
     p_active_date_first => l_active_date_first_tbl,
     p_active_date_first_type => l_active_date_first_type_tbl,
     p_active_date_second => l_active_date_second_tbl,
     p_active_date_second_type => l_active_date_second_type_tbl,
     p_line_quantity => l_line_quantity_tbl,
     p_line_uom_code => l_line_uom_code_tbl,
     p_request_type_code => l_request_type_code_tbl,
     p_priced_quantity => l_priced_quantity_tbl,
     p_priced_uom_code => l_priced_uom_code_tbl,
     p_currency_code => l_currency_code_tbl,
     p_unit_price => l_unit_price_tbl,
     p_percent_price => l_percent_price_tbl,
     p_uom_quantity => l_uom_quantity_tbl,
     p_adjusted_unit_price => l_adjusted_unit_price_tbl,
     p_upd_adjusted_unit_price => l_upd_adjusted_unit_price_tbl,
     p_processed_flag => l_processed_flag_tbl,
     p_price_flag => l_price_flag_tbl,
     p_line_id => l_line_id_tbl,
     p_processing_order => l_processing_order_tbl,
     p_pricing_status_code => l_pricing_status_code_tbl,
     p_pricing_status_text => l_pricing_status_text_tbl,
     p_rounding_flag => l_rounding_flag_tbl,
     p_rounding_factor => l_rounding_factor_tbl,
     p_qualifiers_exist_flag => l_qualifiers_exist_flag_tbl,
     p_pricing_attrs_exist_flag => l_pricing_attrs_exist_flag_tbl,
     p_price_list_id => l_price_list_id_tbl,
     p_validated_flag => l_pl_validated_flag_tbl,
     p_price_request_code => l_price_request_code_tbl,
     p_usage_pricing_type => l_usage_pricing_type_tbl,
     p_line_category => l_line_category_tbl,
     p_line_unit_price => l_line_unit_price_tbl,
     p_list_price_override_flag => l_list_price_overide_flag_tbl,
     x_status_code => x_return_status,
     x_status_text => l_return_status_text);

    d_pos := 190;
    IF g_debug_stmt THEN
      PO_LOG.stmt(l_log_head, d_pos,'After Calling INSERT_LINES2');
      PO_LOG.stmt(l_log_head, d_pos, 'x_return_status', x_return_status);
      PO_LOG.stmt(l_log_head, d_pos, 'l_return_status_text', l_return_status_text);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  -- Don't call QP_PREQ_GRP.INSERT_LINE_ATTRS2 since PO has no
  -- ASK_FOR attributes

    -- <PDOI Enhancement Bug#17063664 Start>
    -- Calling popl_manual_overridden_adj for existing lines
    -- if p_price_adjustment_flag is TRUE.
    IF p_price_adjustment_flag THEN
       FOR j IN 1..p_line_rec_tbl.COUNT LOOP

        l_line_count := 1;
        IF NVL(p_line_rec_tbl(j).allow_price_override_flag, 'Y') = 'Y' THEN

          l_allow_price_override_tbl.extend;

          l_order_line_id_tbl(l_line_count) := p_line_rec_tbl(j).order_line_id;
          l_quantity_tbl(l_line_count) := NVL(p_line_rec_tbl(j).quantity, 1);
          l_allow_price_override_tbl(l_line_count) := p_line_rec_tbl(j).allow_price_override_flag;

          l_line_count := l_line_count +1;
         END IF;

       END LOOP;

        IF l_order_line_id_tbl.COUNT > 0 THEN
        PO_PRICE_ADJUSTMENTS_PKG.popl_manual_overridden_adj
             (p_draft_id          => p_draft_id
             ,p_order_header_id   => p_header_rec.p_order_header_id
             ,p_order_line_id_tbl => l_order_line_id_tbl
             ,p_quantity_tbl      => l_quantity_tbl
             ,x_return_status     => x_return_status
             );
        END IF;

    END IF;
    --<PDOI Enhancement Bug#17063664 End>

    d_pos := 200;
    IF g_debug_stmt THEN
      PO_LOG.stmt(l_log_head, d_pos,'Populate Control Record for Pricing Request Call');
    END IF;

    l_control_rec.calculate_flag := 'Y';
    l_control_rec.simulation_flag := 'N';
    l_control_rec.pricing_event := p_pricing_event;
    l_control_rec.temp_table_insert_flag := 'N';
    l_control_rec.check_cust_view_flag := 'N';
    l_control_rec.request_type_code := p_request_type;
  --now pricing take care of all the roundings.
    l_control_rec.rounding_flag := 'Q';
  --For multi_currency price list
    l_control_rec.use_multi_currency := 'Y';
    l_control_rec.user_conversion_rate := p_header_rec.rate;
    l_control_rec.user_conversion_type := p_header_rec.rate_type;
    l_control_rec.function_currency := p_header_rec.currency_code;
    l_control_rec.get_freight_flag := 'N';

    d_pos := 200;
    IF g_debug_stmt THEN
      PO_LOG.stmt(l_log_head, d_pos,'Call PRICE_REQUEST');
    END IF;

    QP_PREQ_PUB.PRICE_REQUEST(
                              p_control_rec => l_control_rec,
                              x_return_status => x_return_status,
                              x_return_status_Text => l_return_status_Text);

    d_pos := 220;
    IF g_debug_stmt THEN
      PO_LOG.stmt(l_log_head, d_pos, 'x_return_status', x_return_status);
      PO_LOG.stmt(l_log_head, d_pos, 'l_return_status_text', l_return_status_text);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- <PDOI Enhancement Bug#17063664 Start>
    -- Calling extract_price_adjustments and CUSTOM hook
    -- if p_price_adjustment_flag is TRUE.
    IF p_price_adjustment_flag
         AND l_order_line_id_tbl.COUNT > 0  THEN

        PO_PRICE_ADJUSTMENTS_PKG.extract_price_adjustments
        (p_draft_id          => p_draft_id
        ,p_order_header_id   => p_header_rec.p_order_header_id
        ,p_order_line_id_tbl => l_order_line_id_tbl
        ,p_pricing_events    => 'PO_BATCH'
        ,p_calculate_flag    => l_control_rec.calculate_flag
        ,p_doc_sub_type      => 'PO'
        ,p_pricing_call_src     => NULL
        ,p_allow_price_override_tbl => l_allow_price_override_tbl
        ,x_return_status     => x_return_status
        );

        FOR i in 1..l_order_line_id_tbl.COUNT
        LOOP
          PO_CUSTOM_PRICE_PUB.audit_qp_price_adjustment(
                                                    p_api_version => 1.0
                                                    , p_order_type => p_header_rec.order_type
                                                    , p_order_line_id => l_order_line_id_tbl(i)
                                                    , p_line_index => i
                                                    , x_return_status => l_return_status
                                                    , x_msg_count => l_msg_count
                                                    , x_msg_data => l_msg_data
                                                    );

          d_pos := 230;
          IF g_debug_stmt THEN
            PO_LOG.stmt(l_log_head, d_pos, 'x_return_status', l_return_status);
            PO_LOG.stmt(l_log_head, d_pos, 'l_msg_data', l_msg_data);
          END IF;
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
            FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_msg_data);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END LOOP;

    END IF;
    -- <PDOI Enhancement Bug#17063664 End>

  /** No custom price hook for receiving.. need to
      incorporate it. whenever we are planning to use
      FSC for PO document
  PO_CUSTOM_PRICE_PUB.audit_qp_price_adjustment(
        p_api_version           => 1.0
  ,     p_order_type            => p_order_type
  ,     p_order_line_id         => l_line_id
  ,     p_line_index            => 1
  ,     x_return_status         => l_return_status
  ,     x_msg_count             => l_msg_count
  ,     x_msg_data	        => l_msg_data
  );

  l_progress := '230';
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status',l_return_status);
    PO_DEBUG.debug_unexp(l_log_head,l_progress,'audit_qp_price_adjustment errors out');
    FND_MESSAGE.SET_NAME('PO','PO_QP_PRICE_API_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_msg_data);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  */

    d_pos := 240;
    IF g_debug_stmt THEN
      PO_LOG.stmt(l_log_head, d_pos,'Fetch QP pricing');
      PO_LOG.stmt(l_log_head, d_pos, 'p_header_rec.p_order_header_id', p_header_rec.p_order_header_id);
      PO_LOG.stmt(l_log_head, d_pos, 'p_header_rec.shipment_header_id', p_header_rec.shipment_header_id);
      PO_LOG.stmt(l_log_head, d_pos, 'QP_PREQ_LINES_TMP_T', PO_LOG.c_all_rows);
    END IF;

    IF p_return_price_flag THEN
    --Access the QP views to retrieve the values for price
      d_pos := 250;

      FOR j IN 1..i - 1 LOOP
        x_price_tbl.extend();

        SELECT line_index,
               line_id,
               line_unit_price base_unit_price, -- base price
               order_uom_selling_price adjusted_price, -- adjusted_price
               pricing_status_code, --pricing status code
               pricing_status_text -- pricing status text
               INTO
               x_price_tbl(j).line_index,
               x_price_tbl(j).line_id,
               x_price_tbl(j).base_unit_price,
               x_price_tbl(j).adjusted_price,
               x_price_tbl(j).pricing_status_code,
               x_price_tbl(j).pricing_status_text
        FROM qp_preq_lines_tmp
        WHERE line_index = j;

        d_pos := 260;

      END LOOP;
    END IF;

    IF p_return_freight_flag THEN
      d_pos := 270;

      FOR j IN 1..i - 1 LOOP
      -- query to qp_ldets_v to retrieve the freight charge info.
        SELECT charge_type_code,
               order_qty_adj_amt freight_charge,
               pricing_status_code,
               pricing_status_text BULK COLLECT INTO l_freight_charge_rec_tbl
        FROM qp_ldets_v
        WHERE line_index = j
        AND list_line_type_code = 'FREIGHT_CHARGE'
        AND applied_flag = 'Y';

        IF NOT p_return_price_flag THEN
          x_price_tbl.extend();
        END IF;

        d_pos := 280;

        x_price_tbl(j).line_index := l_line_index_tbl(j);
        x_price_tbl(j).base_unit_price := l_unit_price_tbl(j);
        x_price_tbl(j).freight_charge_rec_tbl := l_freight_charge_rec_tbl;
        x_price_tbl(j).line_id := l_line_id_tbl(j);

        SELECT pricing_status_code, pricing_status_text INTO
               x_price_tbl(j).pricing_status_code,
               x_price_tbl(j).pricing_status_text
        FROM
        qp_preq_lines_tmp WHERE line_index = j;
        d_pos := 290;
      END LOOP;
    END IF;


    d_pos := 300;
    IF g_debug_stmt THEN
      PO_LOG.proc_end(l_log_head);
      PO_LOG.proc_end(l_log_head, 'x_return_status', x_return_status);
      FOR j IN 1..x_price_tbl.COUNT LOOP
        PO_LOG.proc_end(l_log_head, 'x_price_tbl(' || j || ').line_index', x_price_tbl(j).line_index);
        PO_LOG.proc_end(l_log_head, 'x_price_tbl(' || j || ').line_id', x_price_tbl(j).line_id);
        PO_LOG.proc_end(l_log_head, 'x_price_tbl(' || j || ').base_unit_price', x_price_tbl(j).base_unit_price);
        PO_LOG.proc_end(l_log_head, 'x_price_tbl(' || j || ').adjusted_price', x_price_tbl(j).adjusted_price);
        --<PDOI Enhancement Bug#17063664>
        -- Adding the if contion
        IF p_return_freight_flag THEN
              FOR k IN 1..x_price_tbl(j).freight_charge_rec_tbl.COUNT LOOP
                PO_LOG.proc_end(l_log_head, 'x_price_tbl(' || j || ').freight_charge_rec_tbl(' || k || ').charge_type_code'
                                , x_price_tbl(j).freight_charge_rec_tbl(k).charge_type_code);
                PO_LOG.proc_end(l_log_head, 'x_price_tbl(' || j || ').freight_charge_rec_tbl(' || k || ').freight_charge'
                                , x_price_tbl(j).freight_charge_rec_tbl(k).freight_charge);
                PO_LOG.proc_end(l_log_head, 'x_price_tbl(' || j || ').freight_charge_rec_tbl(' || k || ').pricing_status_code'
                                , x_price_tbl(j).freight_charge_rec_tbl(k).pricing_status_code);
                PO_LOG.proc_end(l_log_head, 'x_price_tbl(' || j || ').freight_charge_rec_tbl(' || k || ').pricing_status_text'
                                , x_price_tbl(j).freight_charge_rec_tbl(k).pricing_status_text);
              END LOOP;
        END IF;
        PO_LOG.proc_end(l_log_head, 'x_price_tbl(' || j || ').pricing_status_code', x_price_tbl(j).pricing_status_code);
        PO_LOG.proc_end(l_log_head, 'x_price_tbl(' || j || ').pricing_status_text', x_price_tbl(j).pricing_status_text);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    --raised expected error: assume raiser already pushed onto the stack
      l_exception_msg := FND_MSG_PUB.get(
                                         p_msg_index => FND_MSG_PUB.G_LAST
                                         , p_encoded => 'F'
                                         );
      IF g_debug_unexp THEN
        PO_LOG.exc(l_log_head, d_pos, l_exception_msg);
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
    -- Push the po_return_msg onto msg list and message stack
      FND_MESSAGE.set_name('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_exception_msg);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --raised unexpected error: assume raiser already pushed onto the stack
      l_exception_msg := FND_MSG_PUB.get(
                                         p_msg_index => FND_MSG_PUB.G_LAST
                                         , p_encoded => 'F'
                                         );
      IF g_debug_unexp THEN
        PO_LOG.exc(l_log_head, d_pos, l_exception_msg);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
    -- Push the po_return_msg onto msg list and message stack
      FND_MESSAGE.set_name('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_exception_msg);

    WHEN OTHERS THEN
      IF g_debug_unexp THEN
        PO_LOG.exc(l_log_head, d_pos);
      END IF;
    --unexpected error from this procedure: get SQLERRM
      po_message_s.sql_error(g_pkg_name, l_api_name, d_pos, SQLCODE, SQLERRM);
      l_exception_msg := FND_MESSAGE.get;
      IF g_debug_unexp THEN
        PO_LOG.exc(l_log_head, d_pos, l_exception_msg);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
    -- Push the po_return_msg onto msg list and message stack
      FND_MESSAGE.set_name('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_exception_msg);
  END get_advanced_price;
-- <FSC R12 END>

-- <Enhanced Pricing Start:>
--------------------------------------------------------------------------------
--Start of Comments
--Name: call_pricing_manual_modifier
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure calls Advanced prcing API to get the manual modifiers (adjustments)
--Parameters:
--IN:
--p_org_id
--  Org ID.
--p_supplier_id
--  Supplier ID.
--p_supplier_site_id
--  Supplier Site ID.
--p_rate
--  Conversion rate.
--p_rate_type
--  Conversion rate type.
--p_currency_code
--  Currency code.
--p_creation_date
--  Creation date.
--p_order_type
--  Order type: REQUISITION or PO.
--p_ship_to_location_id
--  Ship to Location ID.
--p_ship_to_org_id
--  Ship to Org ID.
--p_order_id
--  Order ID: REQUISITION Header ID or PO Header ID.
--p_order_line_id
--  Order Line ID: REQUISITION Line ID or PO Line ID.
--p_item_revision
--  Item Revision.
--p_item_id
--  Inventory Item ID.
--p_category_id
--  Category ID.
--p_supplier_item_num
--  Supplier Item Number
--p_agreement_type
--  The type of the source agreement. In 11.5.10, should only be CONTRACT.
--p_agreement_id
--  The header ID of the source agreement.
--p_price_date
--  Price date.
--p_quantity
--  Quantity.
--p_uom
--  Unit of Measure.
--p_unit_price
--  Unit Price.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if API succeeds
--  FND_API.G_RET_STS_ERROR if API fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
  PROCEDURE call_pricing_manual_modifier
  (  p_org_id IN NUMBER
   , p_supplier_id IN NUMBER
   , p_supplier_site_id IN NUMBER
   , p_creation_date IN DATE
   , p_order_type IN VARCHAR2
   , p_ship_to_location_id IN NUMBER
   , p_ship_to_org_id IN NUMBER
   , p_order_header_id IN NUMBER
   , p_order_line_id IN NUMBER
   , p_item_revision IN VARCHAR2
   , p_item_id IN NUMBER
   , p_category_id IN NUMBER
   , p_supplier_item_num IN VARCHAR2
   , p_agreement_type IN VARCHAR2
   , p_agreement_id IN NUMBER
   , p_agreement_line_id IN NUMBER DEFAULT NULL --<R12 GBPA Adv Pricing>
   , p_rate IN NUMBER
   , p_rate_type IN VARCHAR2
   , p_currency_code IN VARCHAR2
   , p_need_by_date IN DATE
   , p_quantity IN NUMBER
   , p_uom IN VARCHAR2
   , p_unit_price IN NUMBER
   , x_return_status OUT NOCOPY VARCHAR2
   )
  IS
  l_api_name CONSTANT VARCHAR2(30) := 'CALL_PRICING_MANUAL_MODIFIER';
  l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress VARCHAR2(3) := '000';
  l_exception_msg FND_NEW_MESSAGES.message_text%TYPE;
  l_qp_license VARCHAR2(30) := NULL;
  l_uom_code MTL_UNITS_OF_MEASURE.uom_code%TYPE;


  l_line_id NUMBER := nvl(p_order_line_id, 1);
  l_return_status_text VARCHAR2(2000);
  l_control_rec QP_PREQ_GRP.control_record_type;
  l_pass_line VARCHAR2(1);

  l_line_index_tbl QP_PREQ_GRP.pls_integer_type;
  l_line_type_code_tbl QP_PREQ_GRP.varchar_type;
  l_pricing_effective_date_tbl QP_PREQ_GRP.date_type ;
  l_active_date_first_tbl QP_PREQ_GRP.date_type ;
  l_active_date_first_type_tbl QP_PREQ_GRP.varchar_type;
  l_active_date_second_tbl QP_PREQ_GRP.date_type ;
  l_active_date_second_type_tbl QP_PREQ_GRP.varchar_type ;
  l_line_unit_price_tbl QP_PREQ_GRP.number_type ;
  l_line_quantity_tbl QP_PREQ_GRP.number_type ;
  l_line_uom_code_tbl QP_PREQ_GRP.varchar_type;
  l_request_type_code_tbl QP_PREQ_GRP.varchar_type;
  l_priced_quantity_tbl QP_PREQ_GRP.number_type;
  l_uom_quantity_tbl QP_PREQ_GRP.number_type;
  l_priced_uom_code_tbl QP_PREQ_GRP.varchar_type;
  l_currency_code_tbl QP_PREQ_GRP.varchar_type;
  l_unit_price_tbl QP_PREQ_GRP.number_type;
  l_percent_price_tbl QP_PREQ_GRP.number_type;
  l_adjusted_unit_price_tbl QP_PREQ_GRP.number_type;
  l_upd_adjusted_unit_price_tbl QP_PREQ_GRP.number_type;
  l_processed_flag_tbl QP_PREQ_GRP.varchar_type;
  l_price_flag_tbl QP_PREQ_GRP.varchar_type;
  l_line_id_tbl QP_PREQ_GRP.number_type;
  l_processing_order_tbl QP_PREQ_GRP.pls_integer_type;
  l_rounding_factor_tbl QP_PREQ_GRP.pls_integer_type;
  l_rounding_flag_tbl QP_PREQ_GRP.flag_type;
  l_qualifiers_exist_flag_tbl QP_PREQ_GRP.varchar_type;
  l_pricing_attrs_exist_flag_tbl QP_PREQ_GRP.varchar_type;
  l_price_list_id_tbl QP_PREQ_GRP.number_type;
  l_pl_validated_flag_tbl QP_PREQ_GRP.varchar_type;
  l_price_request_code_tbl QP_PREQ_GRP.varchar_type;
  l_usage_pricing_type_tbl QP_PREQ_GRP.varchar_type;
  l_line_category_tbl QP_PREQ_GRP.varchar_type;
  l_pricing_status_code_tbl QP_PREQ_GRP.varchar_type;
  l_pricing_status_text_tbl QP_PREQ_GRP.varchar_type;
  l_list_price_overide_flag_tbl QP_PREQ_GRP.varchar_type;

  l_price_status_code QP_PREQ_LINES_TMP.pricing_status_code%TYPE;
  l_price_status_text QP_PREQ_LINES_TMP.pricing_status_text%TYPE;

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  BEGIN

    --Initialize OUT parameters
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_org_id', p_org_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_supplier_id', p_supplier_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_supplier_site_id', p_supplier_site_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_creation_date', p_creation_date);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_order_type', p_order_type);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_ship_to_location_id', p_ship_to_location_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_ship_to_org_id', p_ship_to_org_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_order_header_id', p_order_header_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_order_line_id', p_order_line_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_item_revision', p_item_revision);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_item_id', p_item_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_category_id', p_category_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_supplier_item_num', p_supplier_item_num);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_agreement_type', p_agreement_type);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_agreement_id', p_agreement_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_agreement_line_id', p_agreement_line_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_rate', p_rate);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_rate_type', p_rate_type);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_currency_code', p_currency_code);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_need_by_date', p_need_by_date);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_quantity', p_quantity);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_uom', p_uom);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_unit_price', p_unit_price);
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Check Advanced Pricing License');
    END IF;

    FND_PROFILE.get('QP_LICENSED_FOR_PRODUCT', l_qp_license);
    l_progress := '020';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_qp_license', l_qp_license);
    END IF;

    IF (l_qp_license IS NULL OR l_qp_license <> 'PO') THEN
      RETURN;
    END IF;

    l_progress := '040';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Set Price Request ID');
    END IF;

    QP_PRICE_REQUEST_CONTEXT.set_request_id;

    l_progress := '060';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Populate Global Header Structure');
    END IF;

    populate_header_record(
                           p_org_id => p_org_id,
                           p_order_header_id => p_order_header_id,
                           p_supplier_id => p_supplier_id,
                           p_supplier_site_id => p_supplier_site_id,
                           p_creation_date => p_creation_date,
                           p_order_type => p_order_type,
                           p_ship_to_location_id => p_ship_to_location_id,
                           p_ship_to_org_id => p_ship_to_org_id);

    l_progress := '080';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Populate Global Line Structure');
    END IF;

    populate_line_record(
                         p_order_line_id => p_order_line_id,
                         p_order_type => p_order_type, --Enhanced Pricing
                         p_item_revision => p_item_revision,
                         p_item_id => p_item_id,
                         p_category_id => p_category_id,
                         p_supplier_item_num => p_supplier_item_num,
                         p_agreement_type => p_agreement_type,
                         p_agreement_id => p_agreement_id,
                         p_agreement_line_id => p_agreement_line_id, --<R12 GBPA Adv Pricing>
                         p_supplier_id => p_supplier_id,
                         p_supplier_site_id => p_supplier_site_id,
                         p_ship_to_location_id => p_ship_to_location_id,
                         p_ship_to_org_id => p_ship_to_org_id,
                         p_rate => p_rate,
                         p_rate_type => p_rate_type,
                         p_currency_code => p_currency_code,
                         p_need_by_date => p_need_by_date);


    l_progress := '090';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Set OE Debug');
      OE_DEBUG_PUB.SetDebugLevel(10);
      PO_DEBUG.debug_stmt(l_log_head, l_progress, 'Debug File Location:'||
                          OE_DEBUG_PUB.Set_Debug_Mode('FILE'));
      OE_DEBUG_PUB.Initialize;
      OE_DEBUG_PUB.Debug_On;
    END IF;

    l_progress := '100';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Build Attributes Mapping Contexts');
    END IF;

    QP_Attr_Mapping_PUB.Build_Contexts(
                                       p_request_type_code => 'PO',
                                       p_line_index => 1,
                                       p_pricing_type_code => 'L',
                                       p_check_line_flag => 'N',
                                       p_pricing_event => 'PO_BATCH',
                                       x_pass_line => l_pass_line);

    l_progress := '110';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Get UOM Code');
    END IF;

    BEGIN
    -- Make sure we pass uom_code instead of unit_of_measure.
      SELECT mum.uom_code
      INTO l_uom_code
      FROM mtl_units_of_measure mum
      WHERE mum.unit_of_measure = p_uom;
    EXCEPTION
      WHEN OTHERS THEN
        l_uom_code := p_uom;
    END;

    l_progress := '120';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_uom_code', l_uom_code);
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Directly Insert into Temp table');
    END IF;

    l_request_type_code_tbl(1) := 'PO';
    l_line_id_tbl(1) := l_line_id; -- order line id
    l_line_index_tbl(1) := 1; -- Request Line Index
    l_line_type_code_tbl(1) := 'LINE'; -- LINE or ORDER(Summary Line)
    l_pricing_effective_date_tbl(1) := p_need_by_date;-- Pricing as of effective date
    l_active_date_first_tbl(1) := NULL; -- Can be Ordered Date or Ship Date
    l_active_date_second_tbl(1) := NULL; -- Can be Ordered Date or Ship Date
    l_active_date_first_type_tbl(1) := NULL; -- ORD/SHIP
    l_active_date_second_type_tbl(1) := NULL; -- ORD/SHIP
    l_line_unit_price_tbl(1) := p_unit_price;-- Unit Price

    -- should pass 1 instead of NULL
    l_line_quantity_tbl(1) := NVL(p_quantity, 1);-- Ordered Quantity
    -- don't pass 0, pass 1 instead
    IF (l_line_quantity_tbl(1) = 0) THEN
      l_line_quantity_tbl(1) := 1;
    END IF;

    l_line_uom_code_tbl(1) := l_uom_code; -- Ordered UOM Code
    l_currency_code_tbl(1) := p_currency_code;-- Currency Code
    l_price_flag_tbl(1) := 'Y'; -- Price Flag can have 'Y', 'N'(No pricing), 'P'(Phase)
    l_usage_pricing_type_tbl(1) := QP_PREQ_GRP.g_regular_usage_type;

    -- should pass 1 instead of NULL
    l_priced_quantity_tbl(1) := NVL(p_quantity, 1);
    -- don't pass 0, pass 1 instead
    IF (l_priced_quantity_tbl(1) = 0) THEN
      l_priced_quantity_tbl(1) := 1;
    END IF;

    l_priced_uom_code_tbl(1) := l_uom_code;
    l_unit_price_tbl(1) := p_unit_price;
    l_percent_price_tbl(1) := NULL;
    l_uom_quantity_tbl(1) := NULL;
    l_adjusted_unit_price_tbl(1) := NULL;
    l_upd_adjusted_unit_price_tbl(1) := NULL;
    l_processed_flag_tbl(1) := NULL;
    l_processing_order_tbl(1) := NULL;
    l_pricing_status_code_tbl(1) := QP_PREQ_GRP.g_status_unchanged;
    l_pricing_status_text_tbl(1) := NULL;
    l_rounding_flag_tbl(1) := NULL;
    l_rounding_factor_tbl(1) := NULL;
    l_qualifiers_exist_flag_tbl(1) := 'N';
    l_pricing_attrs_exist_flag_tbl(1) := 'N';
    l_price_list_id_tbl(1) :=  - 9999;
    l_pl_validated_flag_tbl(1) := 'N';
    l_price_request_code_tbl(1) := NULL;
    l_line_category_tbl(1) := NULL;
    l_list_price_overide_flag_tbl(1) := 'O'; -- Override price

    l_progress := '140';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Call INSERT_LINES2');
    END IF;

    QP_PREQ_GRP.INSERT_LINES2
    (p_line_index => l_line_index_tbl,
     p_line_type_code => l_line_type_code_tbl,
     p_pricing_effective_date => l_pricing_effective_date_tbl,
     p_active_date_first => l_active_date_first_tbl,
     p_active_date_first_type => l_active_date_first_type_tbl,
     p_active_date_second => l_active_date_second_tbl,
     p_active_date_second_type => l_active_date_second_type_tbl,
     p_line_quantity => l_line_quantity_tbl,
     p_line_uom_code => l_line_uom_code_tbl,
     p_request_type_code => l_request_type_code_tbl,
     p_priced_quantity => l_priced_quantity_tbl,
     p_priced_uom_code => l_priced_uom_code_tbl,
     p_currency_code => l_currency_code_tbl,
     p_unit_price => l_unit_price_tbl,
     p_percent_price => l_percent_price_tbl,
     p_uom_quantity => l_uom_quantity_tbl,
     p_adjusted_unit_price => l_adjusted_unit_price_tbl,
     p_upd_adjusted_unit_price => l_upd_adjusted_unit_price_tbl,
     p_processed_flag => l_processed_flag_tbl,
     p_price_flag => l_price_flag_tbl,
     p_line_id => l_line_id_tbl,
     p_processing_order => l_processing_order_tbl,
     p_pricing_status_code => l_pricing_status_code_tbl,
     p_pricing_status_text => l_pricing_status_text_tbl,
     p_rounding_flag => l_rounding_flag_tbl,
     p_rounding_factor => l_rounding_factor_tbl,
     p_qualifiers_exist_flag => l_qualifiers_exist_flag_tbl,
     p_pricing_attrs_exist_flag => l_pricing_attrs_exist_flag_tbl,
     p_price_list_id => l_price_list_id_tbl,
     p_validated_flag => l_pl_validated_flag_tbl,
     p_price_request_code => l_price_request_code_tbl,
     p_usage_pricing_type => l_usage_pricing_type_tbl,
     p_line_category => l_line_category_tbl,
     p_line_unit_price => l_line_unit_price_tbl,
     p_list_price_override_flag => l_list_price_overide_flag_tbl,
     x_status_code => x_return_status,
     x_status_text => l_return_status_text);

    l_progress := '160';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'After Calling INSERT_LINES2');
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_return_status', x_return_status);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_return_status_text', l_return_status_text);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Don't call QP_PREQ_GRP.INSERT_LINE_ATTRS2 since PO has no
    -- ASK_FOR attributes

    l_progress := '180';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,
                          'Populate Control Record for Pricing Request Call to fetch the manual modifiers');
    END IF;

    l_control_rec.manual_adjustments_call_flag := qp_preq_grp.G_YES;
    l_control_rec.calculate_flag := 'Y';
    l_control_rec.simulation_flag := 'N';
    l_control_rec.pricing_event := 'PO_BATCH';
    l_control_rec.temp_table_insert_flag := 'N';
    l_control_rec.check_cust_view_flag := 'N';
    l_control_rec.request_type_code := 'PO';
  --now pricing take care of all the roundings.
    l_control_rec.rounding_flag := 'Q';
  --For multi_currency price list
    l_control_rec.use_multi_currency := 'Y';
    l_control_rec.user_conversion_rate := PO_ADVANCED_PRICE_PVT.g_line.rate;
    l_control_rec.user_conversion_type := PO_ADVANCED_PRICE_PVT.g_line.rate_type;
    l_control_rec.function_currency := PO_ADVANCED_PRICE_PVT.g_line.currency_code;
    l_control_rec.get_freight_flag := 'N';

    l_progress := '200';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Call PRICE_REQUEST');
    END IF;

    QP_PREQ_PUB.PRICE_REQUEST(
                              p_control_rec => l_control_rec,
                              x_return_status => x_return_status,
                              x_return_status_Text => l_return_status_Text);

    l_progress := '220';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_return_status', x_return_status);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_return_status_text', l_return_status_text);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      FND_MESSAGE.SET_NAME('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_return_status_text);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_progress := '240';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'The QP call is made successfully. The Manual modifiers can be fetched from QP temp tables');
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_line_id', l_line_id);
      PO_DEBUG.debug_table(l_log_head, l_progress, 'QP_PREQ_LINES_TMP_T', PO_DEBUG.g_all_rows, NULL, 'QP');
    END IF;

    l_progress := '300';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(l_log_head);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_return_status', x_return_status);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    --raised expected error: assume raiser already pushed onto the stack
      l_exception_msg := FND_MSG_PUB.get(
                                         p_msg_index => FND_MSG_PUB.G_LAST
                                         , p_encoded => 'F'
                                         );
      IF g_debug_unexp THEN
        PO_DEBUG.debug_var(l_log_head, l_progress, 'l_exception_msg',
                           l_exception_msg);
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
    -- Push the po_return_msg onto msg list and message stack
      FND_MESSAGE.set_name('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_exception_msg);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --raised unexpected error: assume raiser already pushed onto the stack
      l_exception_msg := FND_MSG_PUB.get(
                                         p_msg_index => FND_MSG_PUB.G_LAST
                                         , p_encoded => 'F'
                                         );
      IF g_debug_unexp THEN
        PO_DEBUG.debug_var(l_log_head, l_progress, 'l_exception_msg',
                           l_exception_msg);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
    -- Push the po_return_msg onto msg list and message stack
      FND_MESSAGE.set_name('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_exception_msg);

    WHEN OTHERS THEN
      IF g_debug_unexp THEN
        PO_DEBUG.debug_exc(l_log_head, l_progress);
      END IF;
    --unexpected error from this procedure: get SQLERRM
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      l_exception_msg := FND_MESSAGE.get;
      IF g_debug_unexp THEN
        PO_DEBUG.debug_var(l_log_head, l_progress, 'l_exception_msg',
                           l_exception_msg);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
    -- Push the po_return_msg onto msg list and message stack
      FND_MESSAGE.set_name('PO', 'PO_QP_PRICE_API_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT', l_exception_msg);
  END call_pricing_manual_modifier;
-- <Enhanced Pricing End>

--<PDOI Enhancement Bug#17063664 Start>
-----------------------------------------------------------------------
--Start of Comments
--Name: get_line_price
--Function:
--<PDOI Enhancement Bug#17063664>
--  The procedure is used to get price from QP.
--End of Comments
------------------------------------------------------------------------
  PROCEDURE get_advanced_price
  (  p_api_version            IN         NUMBER
   , x_pricing_attributes_rec IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type
   , x_return_status          OUT NOCOPY VARCHAR2
   )
   IS
     l_api_name       CONSTANT VARCHAR2(30) := 'GET_ADVANCED_PRICE';
     l_log_head       CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
     d_pos            NUMBER;
     p_header_rec     Header_rec_type;
     p_line_rec_tbl   Line_Tbl_Type;
     l_line_count     PLS_INTEGER;
     l_return_status  VARCHAR2(1);
     l_return_message VARCHAR2(30);
     l_price_tbl      PO_ADVANCED_PRICE_PVT.Qp_Price_Result_Rec_Tbl_Type;
     l_line_index_tbl dbms_sql.number_table;
     l_index          NUMBER;
     l_api_version    NUMBER := 1.0;

     l_po_line_id NUMBER;
     l_from_advanced_pricing VARCHAR2(1);
   BEGIN

   d_pos := 000;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF g_debug_stmt THEN
      PO_LOG.proc_begin(l_log_head);
    END IF;

    IF (NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) ) THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;

     -- Algorithm
     -- Loop through all lines to find lines
     -- belonging to a single header.
     -- Send these in existing API get_advanced_price.
     -- Update unit_price and base_unit_price in input record.

     FOR i in 1..x_pricing_attributes_rec.po_line_id_tbl.COUNT
     LOOP
        d_pos := 010;


        IF x_pricing_attributes_rec.processed_flag_tbl(i) = 'N' THEN
          d_pos := 020;
          IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(l_log_head, d_pos,' Calling QP for header id -  ' || x_pricing_attributes_rec.po_header_id_tbl(i));
          END IF;

          p_header_rec.p_order_header_id := x_pricing_attributes_rec.po_header_id_tbl(i);
          p_header_rec.org_id := x_pricing_attributes_rec.org_id_tbl(i);
          p_header_rec.supplier_id := x_pricing_attributes_rec.po_vendor_id_tbl(i);
          p_header_rec.supplier_site_id := x_pricing_attributes_rec.po_vendor_site_id_tbl(i);
          p_header_rec.creation_date := x_pricing_attributes_rec.creation_date_tbl(i);
          p_header_rec.order_type := x_pricing_attributes_rec.order_type_tbl(i);
          p_header_rec.ship_to_location_id := x_pricing_attributes_rec.ship_to_loc_tbl(i);
          p_header_rec.ship_to_org_id := x_pricing_attributes_rec.ship_to_org_tbl(i);

          p_line_rec_tbl := Line_Tbl_Type();
          l_line_count := 1;

          FOR j in i..x_pricing_attributes_rec.po_line_id_tbl.COUNT
          LOOP
            d_pos := 030;
            IF x_pricing_attributes_rec.processed_flag_tbl(j) = 'N'
               AND x_pricing_attributes_rec.po_header_id_tbl(j) = x_pricing_attributes_rec.po_header_id_tbl(i) THEN

              d_pos := 040;

              IF g_debug_stmt THEN
                  PO_DEBUG.debug_stmt(l_log_head, d_pos,' Calling QP for line id -  ' || x_pricing_attributes_rec.po_line_id_tbl(j));
              END IF;
              x_pricing_attributes_rec.processed_flag_tbl(j) := 'Y';
              l_line_index_tbl(x_pricing_attributes_rec.po_line_id_tbl(j)) := j;

              p_line_rec_tbl.extend;
              p_line_rec_tbl(l_line_count).order_line_id := x_pricing_attributes_rec.po_line_id_tbl(j);
              p_line_rec_tbl(l_line_count).order_type := x_pricing_attributes_rec.order_type_tbl(j);
              p_line_rec_tbl(l_line_count).item_revision := x_pricing_attributes_rec.item_revision_tbl(j);
              p_line_rec_tbl(l_line_count).item_id := x_pricing_attributes_rec.item_id_tbl(j);
              p_line_rec_tbl(l_line_count).category_id := x_pricing_attributes_rec.category_id_tbl(j);
              p_line_rec_tbl(l_line_count).supplier_item_num := x_pricing_attributes_rec.supplier_item_num_tbl(j);
              p_line_rec_tbl(l_line_count).agreement_type := x_pricing_attributes_rec.source_document_type_tbl(j);
              p_line_rec_tbl(l_line_count).agreement_id := x_pricing_attributes_rec.source_doc_hdr_id_tbl(j);
              p_line_rec_tbl(l_line_count).agreement_line_id := x_pricing_attributes_rec.source_doc_line_id_tbl(j);
              p_line_rec_tbl(l_line_count).supplier_id := x_pricing_attributes_rec.po_vendor_id_tbl(j);
              p_line_rec_tbl(l_line_count).supplier_site_id := x_pricing_attributes_rec.po_vendor_site_id_tbl(j);
              p_line_rec_tbl(l_line_count).ship_to_location_id := x_pricing_attributes_rec.ship_to_loc_tbl(j);
              p_line_rec_tbl(l_line_count).ship_to_org_id := x_pricing_attributes_rec.ship_to_org_tbl(j);
              p_line_rec_tbl(l_line_count).unit_price := NVL(x_pricing_attributes_rec.unit_price_tbl(j), x_pricing_attributes_rec.base_unit_price_tbl(j));
              p_line_rec_tbl(l_line_count).rate := NULL;
              p_line_rec_tbl(l_line_count).rate_type := NULL;
              p_line_rec_tbl(l_line_count).currency_code := x_pricing_attributes_rec.currency_code_tbl(j);
              p_line_rec_tbl(l_line_count).need_by_date := x_pricing_attributes_rec.pricing_date_tbl(j);
              p_line_rec_tbl(l_line_count).existing_line_flag := x_pricing_attributes_rec.existing_line_flag_tbl(j);
              p_line_rec_tbl(l_line_count).allow_price_override_flag := x_pricing_attributes_rec.allow_price_override_flag_tbl(j);
              p_line_rec_tbl(l_line_count).unit_of_measure := x_pricing_attributes_rec.uom_tbl(j);

              l_line_count := l_line_count +1;

            END IF;
          END LOOP;

          d_pos := 050;
          l_return_status := NULL;
          l_return_message := NULL;
          get_advanced_price(p_header_rec => p_header_rec,
                               p_line_rec_tbl => p_line_rec_tbl,
                               p_request_type => 'PO',
                               p_pricing_event => 'PO_BATCH',
                               p_has_header_pricing => FALSE ,
                               p_return_price_flag => TRUE,
                               p_return_freight_flag => FALSE,
                               p_price_adjustment_flag => TRUE,
                               p_draft_id =>  x_pricing_attributes_rec.draft_id_tbl(i),
                               x_price_tbl => l_price_tbl,
                               x_return_status => l_return_status);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              d_pos := 060;
              l_return_message := FND_MESSAGE.get;
              IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head, d_pos,' l_return_status ' || l_return_status);
                 PO_DEBUG.debug_stmt(l_log_head, d_pos,' l_message ' || l_return_message);
              END IF;

              FOR j IN 1..p_line_rec_tbl.COUNT
              LOOP
                 d_pos := 070;
                 l_index := p_line_rec_tbl(j).order_line_id;
                  IF l_line_index_tbl.exists(l_index) THEN
                     d_pos := 080;
                      IF g_debug_stmt THEN
                          PO_DEBUG.debug_stmt(l_log_head, d_pos,'Line ID ' || x_pricing_attributes_rec.po_line_id_tbl(l_line_index_tbl(l_index)));
                      END IF;
                      x_pricing_attributes_rec.return_status_tbl(l_line_index_tbl(l_index)) := l_return_status;
                      x_pricing_attributes_rec.return_mssg_tbl(l_line_index_tbl(l_index)) := l_return_message;
                  END IF;
              END LOOP;

          ELSE
             d_pos := 090;
              FOR j IN 1..l_price_tbl.count
              LOOP
                 d_pos := 100;
                 l_index := l_price_tbl(j).line_id;
                 IF l_line_index_tbl.exists(l_index) THEN
                     d_pos := 110;

		     l_po_line_id := x_pricing_attributes_rec.po_line_id_tbl(l_line_index_tbl(l_index));
                     IF g_debug_stmt THEN
                           PO_DEBUG.debug_stmt(l_log_head, d_pos,'Line ID ' || l_po_line_id);
                     END IF;

		     -- Bug 18891225 Set the Price source to QP only when record exists in QP Temp tables.
		     BEGIN

			SELECT 'Y'
			INTO l_from_advanced_pricing
			FROM QP_LDETS_v LDETS, QP_PREQ_LINES_TMP QLINE
			WHERE LDETS.line_index = QLINE.line_index
			AND QLINE.line_id = l_po_line_id;

		     EXCEPTION
		       WHEN OTHERS THEN
		         l_from_advanced_pricing := 'N';
		     END;


		      IF l_from_advanced_pricing = 'Y' THEN
		        x_pricing_attributes_rec.pricing_src_tbl(l_line_index_tbl(l_index)) := 'QP';
                           IF l_price_tbl(j).base_unit_price IS NOT NULL THEN
                                x_pricing_attributes_rec.base_unit_price_tbl(l_line_index_tbl(l_index)) := l_price_tbl(j).base_unit_price;
                                IF g_debug_stmt THEN
                                   PO_DEBUG.debug_stmt(l_log_head, d_pos,' base unit price ' || x_pricing_attributes_rec.base_unit_price_tbl(l_line_index_tbl(l_index)));
                                END IF;
                           END IF;

                           IF l_price_tbl(j).adjusted_price IS NOT NULL THEN
                              x_pricing_attributes_rec.unit_price_tbl(l_line_index_tbl(l_index)) := l_price_tbl(j).adjusted_price;
                              IF g_debug_stmt THEN
                                   PO_DEBUG.debug_stmt(l_log_head, d_pos,' unit price ' || x_pricing_attributes_rec.unit_price_tbl(l_line_index_tbl(l_index)));
                              END IF;
                           END IF;
		      END IF;

		      IF g_debug_stmt THEN
                           PO_DEBUG.debug_stmt(l_log_head, d_pos,'l_price_source ' || x_pricing_attributes_rec.pricing_src_tbl(l_line_index_tbl(l_index)));
                     END IF;


                 END IF;
              END LOOP;

          END IF; --<end if l_return_status <> FND_API.G_RET_STS_SUCCESS>

          l_line_index_tbl.delete;

        END IF; --<end if x_pricing_attributes_rec.processed_flag_tbl(i) = 'N'>

     END LOOP;

     d_pos := 090;

    IF g_debug_stmt THEN
      PO_LOG.proc_end(l_log_head);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       PO_MESSAGE_S.add_exc_msg ( p_pkg_name => g_pkg_name, p_procedure_name => l_api_name || '.' || d_pos );
       RAISE;

   END get_advanced_price;
--<PDOI Enhancement Bug#17063664 End>

END PO_ADVANCED_PRICE_PVT;

/
