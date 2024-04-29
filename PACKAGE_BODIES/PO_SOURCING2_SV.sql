--------------------------------------------------------
--  DDL for Package Body PO_SOURCING2_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SOURCING2_SV" AS
/* $Header: POXSCS2B.pls 120.5.12010000.15 2014/09/01 15:38:54 ptulzapu ship $ */

/*=============================  PO_SOURCING2_SV  ===========================*/

/**==========================================================================
*
*  FUNCTION NAME:       get_break_price()
*
*  Change History
*  ==============
*  Modified By  Date        Descriptions
*   Dreddy                   Overloaded the price break API
*===========================================================================*/

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'PO_SOURCING2_SV';
  g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.' || G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
  g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

-- <FPJ Custom Price START>
-- Debugging
  g_debug_stmt BOOLEAN := PO_DEBUG.is_debug_stmt_on;
  g_debug_unexp BOOLEAN := PO_DEBUG.is_debug_unexp_on;
-- <FPJ Custom Price END>

  --<Enhanced Pricing Start>
  PROCEDURE get_break_price(p_order_quantity IN NUMBER,
                            p_ship_to_org IN NUMBER,
                            p_ship_to_loc IN NUMBER,
                            p_po_line_id IN NUMBER,
                            p_cum_flag IN BOOLEAN,
                            p_need_by_date IN DATE,
                            p_line_location_id IN NUMBER,
                            --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
                            p_pricing_call_src IN VARCHAR2 DEFAULT NULL,
                            x_price OUT NOCOPY NUMBER,
                            x_base_unit_price OUT NOCOPY NUMBER
                           )
  IS
    l_price_break_id NUMBER := NULL;
    l_return_status VARCHAR2(1);
  BEGIN
    get_break_price
    (p_api_version => 1.0
     , p_order_quantity => p_order_quantity
     , p_ship_to_org => p_ship_to_org
     , p_ship_to_loc => p_ship_to_loc
     , p_po_line_id => p_po_line_id
     , p_cum_flag => p_cum_flag
     , p_need_by_date => p_need_by_date
     , p_line_location_id => p_line_location_id
     , p_contract_id => NULL
     , p_org_id => NULL
     , p_supplier_id => NULL
     , p_supplier_site_id => NULL
     , p_creation_date => NULL
     , p_order_header_id => NULL
     , p_order_line_id => NULL
     , p_line_type_id => NULL
     , p_item_revision => NULL
     , p_item_id => NULL
     , p_category_id => NULL
     , p_supplier_item_num => NULL
     , p_uom => NULL
     , p_in_price => NULL
     , p_currency_code => NULL -- Bug 3564863
     --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
     , p_pricing_call_src => p_pricing_call_src --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
     , x_base_unit_price => x_base_unit_price
     , x_price_break_id => l_price_break_id
     , x_price => x_price
     , x_return_status => l_return_status
     );
  END;
  --<Enhanced Pricing End>

  FUNCTION get_break_price(x_order_quantity IN NUMBER,
                           x_ship_to_org IN NUMBER,
                           x_ship_to_loc IN NUMBER,
                           x_po_line_id IN NUMBER,
                           x_cum_flag IN BOOLEAN,
                           p_need_by_date IN DATE,
                           x_line_location_id IN NUMBER,
                           p_req_line_price IN NUMBER DEFAULT NULL,--bug 8845486
                           --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
                           p_pricing_call_src IN VARCHAR2 DEFAULT NULL --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
                          )
  RETURN NUMBER IS

  x_price NUMBER := null;
  x_price_break_id NUMBER := null;

  x_return_status VARCHAR2(1);

  BEGIN
    get_break_price
    (p_api_version => 1.0
     , p_order_quantity => x_order_quantity
     , p_ship_to_org => x_ship_to_org
     , p_ship_to_loc => x_ship_to_loc
     , p_po_line_id => x_po_line_id
     , p_cum_flag => x_cum_flag
     , p_need_by_date => p_need_by_date
     , p_line_location_id => x_line_location_id
     , p_req_line_price => p_req_line_price  --bug 8845486
     --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
     , p_pricing_call_src => p_pricing_call_src --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
     , x_price_break_id => x_price_break_id
     , x_price => x_price
     , x_return_status => x_return_status
     );

    RETURN(x_price);

  END;

-- <FPJ Advanced Price START>
  PROCEDURE get_break_price(p_api_version IN NUMBER,
                            p_order_quantity IN NUMBER,
                            p_ship_to_org IN NUMBER,
                            p_ship_to_loc IN NUMBER,
                            p_po_line_id IN NUMBER,
                            p_cum_flag IN BOOLEAN,
                            p_need_by_date IN DATE,
                            p_line_location_id IN NUMBER,
                            p_req_line_price IN NUMBER DEFAULT NULL,--bug 8845486
                            --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
                            p_pricing_call_src IN VARCHAR2 DEFAULT NULL, --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
                            x_price_break_id OUT NOCOPY NUMBER,
                            x_price OUT NOCOPY NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2 )
  IS
  l_base_unit_price NUMBER;
  BEGIN

    get_break_price
    (p_api_version => 1.0
     , p_order_quantity => p_order_quantity
     , p_ship_to_org => p_ship_to_org
     , p_ship_to_loc => p_ship_to_loc
     , p_po_line_id => p_po_line_id
     , p_cum_flag => p_cum_flag
     , p_need_by_date => p_need_by_date
     , p_line_location_id => p_line_location_id
     , p_contract_id => NULL
     , p_org_id => NULL
     , p_supplier_id => NULL
     , p_supplier_site_id => NULL
     , p_creation_date => NULL
     , p_order_header_id => NULL
     , p_order_line_id => NULL
     , p_line_type_id => NULL
     , p_item_revision => NULL
     , p_item_id => NULL
     , p_category_id => NULL
     , p_supplier_item_num => NULL
     , p_uom => NULL
     , p_in_price => NULL
     , p_currency_code => NULL -- Bug 3564863
     --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
     , p_pricing_call_src => p_pricing_call_src --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
     , x_base_unit_price => l_base_unit_price
     , x_price_break_id => x_price_break_id
     , x_price => x_price
     , x_return_status => x_return_status
     , p_req_line_price => p_req_line_price  --bug 8845486

     );

  END;
-- <FPJ Advanced Price END>


  PROCEDURE get_break_price(p_api_version IN NUMBER,
                            p_order_quantity IN NUMBER,
                            p_ship_to_org IN NUMBER,
                            p_ship_to_loc IN NUMBER,
                            p_po_line_id IN NUMBER,
                            p_cum_flag IN BOOLEAN,
                            p_need_by_date IN DATE,
                            p_line_location_id IN NUMBER, -- TIMEPHASED FPI
                          -- <FPJ Advanced Price START>
                            p_contract_id IN NUMBER,
                            p_org_id IN NUMBER,
                            p_supplier_id IN NUMBER,
                            p_supplier_site_id IN NUMBER,
                            p_creation_date IN DATE,
                            p_order_header_id IN NUMBER,
                            p_order_line_id IN NUMBER,
                            p_line_type_id IN NUMBER,
                            p_item_revision IN VARCHAR2,
                            p_item_id IN NUMBER,
                            p_category_id IN NUMBER,
                            p_supplier_item_num IN VARCHAR2,
                            p_uom IN VARCHAR2,
                            p_in_price IN NUMBER,
                            p_currency_code IN VARCHAR2, -- Bug 3564863
                            --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
                            p_pricing_call_src IN VARCHAR2 DEFAULT NULL, --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
                            x_base_unit_price OUT NOCOPY NUMBER,
                          -- <FPJ Advanced Price END>
                            x_price_break_id OUT NOCOPY NUMBER, -- SERVICES FPJ
                            x_price OUT NOCOPY NUMBER, -- SERVICES FPJ
                            x_return_status OUT NOCOPY VARCHAR2,
                            p_req_line_price IN NUMBER )  --  Bug 7154646

  IS
  l_from_advanced_pricing VARCHAR2(1);
  BEGIN

    get_break_price
    (p_api_version => 1.0
     , p_order_quantity => p_order_quantity
     , p_ship_to_org => p_ship_to_org
     , p_ship_to_loc => p_ship_to_loc
     , p_po_line_id => p_po_line_id
     , p_cum_flag => p_cum_flag
     , p_need_by_date => p_need_by_date
     , p_line_location_id => p_line_location_id
     , p_contract_id => p_contract_id
     , p_org_id => p_org_id
     , p_supplier_id => p_supplier_id
     , p_supplier_site_id => p_supplier_site_id
     , p_creation_date => p_creation_date
     , p_order_header_id => p_order_header_id
     , p_order_line_id => p_order_line_id
     , p_line_type_id => p_line_type_id
     , p_item_revision => p_item_revision
     , p_item_id => p_item_id
     , p_category_id => p_category_id
     , p_supplier_item_num => p_supplier_item_num
     , p_uom => p_uom
     , p_in_price => p_in_price
     , p_currency_code => p_currency_code
     --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
     , p_pricing_call_src => p_pricing_call_src --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
     , x_base_unit_price => x_base_unit_price
     , x_price_break_id => x_price_break_id
     , x_price => x_price
     , x_from_advanced_pricing => l_from_advanced_pricing
     , x_return_status => x_return_status
     , p_req_line_price => p_req_line_price
     );

  END;

/**==========================================================================
*
*  FUNCTION NAME:       get_break_price()
*
*  Change History
*  ==============
*  Modified By  Date        Descriptions
*
*  davidng      09/26/2002  FPI Timephased Pricing Project.
*                           Commented out the existing code that retrieves the
*                           price from the database. Replaced that with a new
*                           cursor called unit_price.
*  davidng      11/20/2002  FPI Timephased Pricing Project.
*                           Change the Order By statement in get_break_price()
*                           to obtain the best exact match order by creation
*                           date and price.
*===========================================================================*/
  PROCEDURE get_break_price(p_api_version IN NUMBER,
                            p_order_quantity IN NUMBER,
                            p_ship_to_org IN NUMBER,
                            p_ship_to_loc IN NUMBER,
                            p_po_line_id IN NUMBER,
                            p_cum_flag IN BOOLEAN,
                            p_need_by_date IN DATE,
                            p_line_location_id IN NUMBER, -- TIMEPHASED FPI
                            -- <FPJ Advanced Price START>
                            p_contract_id IN NUMBER,
                            p_org_id IN NUMBER,
                            p_supplier_id IN NUMBER,
                            p_supplier_site_id IN NUMBER,
                            p_creation_date IN DATE,
                            p_order_header_id IN NUMBER,
                            p_order_line_id IN NUMBER,
                            p_line_type_id IN NUMBER,
                            p_item_revision IN VARCHAR2,
                            p_item_id IN NUMBER,
                            p_category_id IN NUMBER,
                            p_supplier_item_num IN VARCHAR2,
                            p_uom IN VARCHAR2,
                            p_in_price IN NUMBER,
                            p_currency_code IN VARCHAR2, -- Bug 3564863
                            --<Enhanced Pricing Start>
                            p_draft_id IN NUMBER DEFAULT NULL,
                            p_src_flag IN VARCHAR2 DEFAULT NULL,
                            p_doc_sub_type IN VARCHAR2 DEFAULT NULL,
                            --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
                            p_pricing_call_src IN VARCHAR2 DEFAULT NULL, --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
                            --<Enhanced Pricing End>
                            x_base_unit_price OUT NOCOPY NUMBER,
                            -- <FPJ Advanced Price END>
                            x_price_break_id OUT NOCOPY NUMBER, -- SERVICES FPJ
                            x_price OUT NOCOPY NUMBER, -- SERVICES FPJ
                            x_from_advanced_pricing OUT NOCOPY VARCHAR2, -- Bug# 4148430: Adding this flag
                            x_return_status OUT NOCOPY VARCHAR2,
                            p_req_line_price IN NUMBER ) --Bug 7154646: Adding this Parameter

  IS

  release_to_date NUMBER := 0;
  l_price NUMBER := NULL; /* <TIMEPHASED FPI> Changed price to l_price */
  test_quantity NUMBER := p_order_quantity;
  match_type VARCHAR2(4) := NULL;
  l_progress VARCHAR2(3) := '000';
  -- Bug 670873, lpo, 05/28/98
  old_quantity NUMBER := 0;

  -- <FPJ Custom Price START>
  l_source_document_type PO_HEADERS.type_lookup_code%TYPE;
  l_source_document_header_id PO_LINES.po_header_id%TYPE;
  l_pricing_date PO_LINE_LOCATIONS.need_by_date%TYPE;
  l_new_price PO_LINES.unit_price%TYPE;
  l_return_status VARCHAR2(1);
  l_api_name CONSTANT VARCHAR2(30) := 'GET_BREAK_PRICE';
  l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  -- <FPJ Custom Price END>

  --Enhanced Pricing
  l_doc_sub_type VARCHAR2(30);
  l_src_flag VARCHAR2(1);

   /* <TIMEPHASED FPI START> */
   /* Declaration of a cursor used to derive the unit price */
   /*
      Bug 2800681.
      Change the defaulting of null quantity to 0 instead of -1 in the
      ORDER BY clause
   */
  CURSOR unit_price IS
    SELECT pll.price_override,
           pll.line_location_id -- SERVICES FPJ
    FROM po_line_locations_all pll, -- GA FPI
           po_headers_all poh -- 5684820
             /*
                Bug fix for 2687718.
                Added QUOTATION in the WHERE clause to ensure that pricing works when
                a Standard PO is sourced to a Quotation through the Supplier Catalog.
             */
    WHERE pll.shipment_type IN ('PRICE BREAK', 'QUOTATION')
    AND pll.po_line_id = p_po_line_id
    AND pll.po_header_id = poh.po_header_id -- 5684820
                --bug #2696731 arusingh
    AND nvl(pll.quantity, 0) <= nvl(test_quantity, 0)
      -- bug #2696731: modified org/loc checks to remove match_type
    AND ((p_ship_to_org = pll.ship_to_organization_id) OR
           (pll.ship_to_organization_id IS NULL))
    AND ((p_ship_to_loc = pll.ship_to_location_id) OR
           (pll.ship_to_location_id IS NULL))
    AND (nvl(trunc(l_pricing_date), trunc(SYSDATE)) >= trunc(pll.start_date) -- FPJ Custom Price
           OR
           pll.start_date IS NULL)
    AND (nvl(trunc(l_pricing_date), trunc(SYSDATE)) <= trunc(pll.end_date) -- FPJ Custom Price
           OR
           pll.end_date IS NULL)
      -- Begin 5684820
    AND ((pll.shipment_type = 'QUOTATION' AND
           (EXISTS (SELECT 1
                      FROM po_quotation_approvals_all
                     WHERE line_location_id = pll.line_location_id
                       AND SYSDATE BETWEEN nvl(start_date_active, SYSDATE - 1)
                                       AND nvl(end_date_active, SYSDATE + 1)
                   )
            AND nvl(poh.APPROVAL_REQUIRED_FLAG, 'N') = 'Y'
          )
          OR
          nvl(poh.APPROVAL_REQUIRED_FLAG, 'N') = 'N'
         )
        OR pll.shipment_type ='PRICE BREAK')
       -- End 5684820
    ORDER BY pll.ship_to_organization_id ASC, pll.ship_to_location_id ASC,
             NVL(pll.quantity, 0) DESC, -- to obtain the best exact matches
             trunc(pll.creation_date) DESC, pll.price_override ASC; -- to sort the matches by creation date and then by price
   /* <TIMEPHASED FPI END> */

  l_api_version NUMBER := 1.0;

  -- <FPJ Advanced Price START>
  l_rate PO_HEADERS.rate%TYPE;
  l_rate_type PO_HEADERS.rate_type%TYPE;
  l_currency_code PO_HEADERS.currency_code%TYPE;
  -- <FPJ Advanced Price END>

  -- Bug 3343892
  l_base_unit_price PO_LINES.base_unit_price%TYPE;

  l_adv_price NUMBER; --<R12 GBPA Adv Pricing >
  l_contract_id PO_LINES.contract_id%TYPE; --<R12 GBPA Adv Pricing >


  BEGIN

  -- <FPJ Advanced Price START>
  -- Initialize OUT parameters
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_base_unit_price := p_in_price;
    x_price := p_in_price;
    x_price_break_id := NULL;

  --<Enhanced Pricing Start>
  --Initialize Document Sub Type
    IF (p_doc_sub_type IS NOT NULL) THEN
      l_doc_sub_type := p_doc_sub_type;
    ELSE
      l_doc_sub_type := 'PO';
    END IF;

  --Initialize document source flag
    l_src_flag := p_src_flag;
    IF (l_src_flag IS NULL AND (p_pricing_call_src = 'RETRO' OR p_pricing_call_src = 'AUTO')) THEN
      IF (p_po_line_id IS NOT NULL OR p_contract_id IS NOT NULL) THEN
        l_src_flag := 'Y';
      ELSE
        l_src_flag := 'N';
      END IF;
    END IF;
  --<Enhanced Pricing End>

  -- Bug 3422411: Moved the initialization inside ELSIF p_contract_id IS NOT NULL clause
  -- Bug 3340552, initialize with passed in price
  -- l_price            := p_in_price;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_order_quantity', p_order_quantity);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_ship_to_org', p_ship_to_org);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_ship_to_loc', p_ship_to_loc);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_po_line_id', p_po_line_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_cum_flag', p_cum_flag);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_need_by_date', p_need_by_date);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_line_location_id', p_line_location_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_contract_id', p_contract_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_org_id', p_org_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_supplier_id', p_supplier_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_supplier_site_id', p_supplier_site_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_creation_date', p_creation_date);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_order_header_id', p_order_header_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_order_line_id', p_order_line_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_line_type_id', p_line_type_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_item_revision', p_item_revision);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_item_id', p_item_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_category_id', p_category_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_supplier_item_num', p_supplier_item_num);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_uom', p_uom);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_in_price', p_in_price);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_currency_code', p_currency_code);
    --<Enhanced Pricing Start>
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_draft_id', p_draft_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_src_flag', p_src_flag);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_doc_sub_type', p_doc_sub_type);
    --<Enhanced Pricing End>
    END IF;
  -- <FPJ Advanced Price END>

  -- Check for the API version
    IF (NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) ) THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;

  -- <FPJ Custom Price START>
  -- SQL What: Find out the source document header id, and source doument type
  -- SQL Why : Get source document line id to call GET_CUSTOM_PRICE_DATE,
  --           Get source document type since we only allow custom pricing for
  --           Blanket and Quotation.
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Get source document header id and type');
    END IF;

    IF (p_po_line_id IS NOT NULL) THEN
      SELECT ph.type_lookup_code,
             pl.po_header_id
      INTO   l_source_document_type,
             l_source_document_header_id
      FROM po_headers_all ph,
             po_lines_all pl
      WHERE ph.po_header_id = pl.po_header_id
      AND pl.po_line_id = p_po_line_id;
    ELSE
      --<Enhanced Pricing: added check to avoid no data found exception from the below select statement>
      IF (l_src_flag = 'Y') THEN
        SELECT ph.type_lookup_code,
               ph.po_header_id
        INTO   l_source_document_type,
               l_source_document_header_id
        FROM po_headers_all ph
        WHERE ph.po_header_id = p_contract_id;
      ELSE
        l_source_document_type := NULL;
        l_source_document_header_id := NULL;
      END IF;
    END IF; /*IF (p_po_line_id IS NOT NULL)*/


  /* call the Custom Pricing Date API    */
    l_progress := '010';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'Call get_custom_price_date');
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_source_document_header_id', l_source_document_header_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_source_document_line_id', p_po_line_id);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_quantity', p_order_quantity);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_ship_to_location_id', p_ship_to_loc);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_ship_to_organization_id', p_ship_to_org);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'p_need_by_date', p_need_by_date);
    END IF; /* IF g_debug_stmt */

/*Bug5598011 Pass the order_type as PO */
    PO_CUSTOM_PRICE_PUB.GET_CUSTOM_PRICE_DATE
    (p_api_version => 1.0,
     p_source_document_header_id => l_source_document_header_id,
     p_source_document_line_id => p_po_line_id,
     p_order_line_id => p_order_line_id, -- <Bug 3754828>
     p_quantity => p_order_quantity,
     p_ship_to_location_id => p_ship_to_loc,
     p_ship_to_organization_id => p_ship_to_org,
     p_need_by_date => p_need_by_date,
     x_pricing_date => l_pricing_date,
     x_return_status => l_return_status,
     p_order_type => 'PO');


    l_progress := '020';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head, l_progress,'After Calling get_custom_price_date');
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_pricing_date', l_pricing_date);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'l_return_status', l_return_status);
    END IF; /* IF g_debug_stmt */

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      app_exception.raise_exception;
    END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

    IF (l_pricing_date IS NULL) THEN
      l_pricing_date := NVL(p_need_by_date, SYSDATE);
    END IF; /* IF (l_pricing_date IS NULL) */

  -- <FPJ Custom Price END>

  -- <FPJ Advanced Price START>
  -- Only allow custom pricing for Blanket and Quotation
    IF p_po_line_id IS NOT NULL THEN
  -- <FPJ Advanced Price END>

      IF (p_cum_flag = TRUE) THEN
      -- <Manual Price Override FPJ START>
      -- To improve performance, moved this so that we only call
      -- get_release_quantity if pricing is cumulative.
        l_progress := '040';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head, l_progress,'Get Release Quantity');
        END IF;

      /* Call get_release_quantity to a) determine how to select
      ** the correct break price and b) the quantity released against
      ** the corresponding shipment/organization combination.
      */
        release_to_date := PO_SOURCING2_SV.get_release_quantity(p_ship_to_org,
                                                                p_ship_to_loc,
                                                                p_po_line_id,
                                                                match_type);

        l_progress := '060';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head, l_progress,'Get Release Quantity');
        END IF;
      -- <Manual Price Override FPJ END>

      -- Bug 670873, lpo, 05/28/98
      -- Take into account the old quantity saved on database

        IF (p_line_location_id IS NOT NULL) THEN
        -- Get the old quantity saved on the database
          BEGIN
            SELECT nvl(quantity, 0)
            INTO old_quantity
            FROM po_line_locations
            WHERE line_location_id = p_line_location_id;
          EXCEPTION
            WHEN OTHERS THEN old_quantity := 0;
          END;
        ELSE
          old_quantity := 0; -- Shouldn't be necessary, just in case ...
        END IF;

        test_quantity := p_order_quantity + release_to_date - old_quantity;

      END IF;

    /* Select the next applicable price break for the designated
    ** quantity if we know there is a matching price break.
    */

      IF (NVL(p_cum_flag, FALSE) = FALSE) -- <Manual Price Override FPJ>
        OR (match_type <> 'NONE') THEN

        l_progress := '100';

      /* <TIMEPHASED FPI START> */

      /* Open the cursor */
        OPEN unit_price;

      /* Get the price from the cursor */
        FETCH unit_price INTO l_price , x_price_break_id; -- SERVICES FPJ

      /* Close the cursor */
        CLOSE unit_price;

      /* <TIMEPHASED FPI END> */

      END IF;

    /* If the order quantity was too small to yield a price break,
    ** or if no price breaks exist/match the release org/location then
    ** get the blanket line price as a default.
    */

      l_progress := '120';

      IF (l_price IS NULL) THEN /* <TIMEPHASED FPI> */
        SELECT pl.unit_price
        INTO l_price /* <TIMEPHASED FPI> */
        FROM po_lines_all pl -- GA FPI
        WHERE pl.po_line_id = p_po_line_id;

        x_price_break_id := NULL; -- SERVICES FPJ
      END IF;

     --<R12 GBPA Adv Pricing Support Start>

     -- Pass the Price break price into Advance pricing
      l_adv_price := l_price ;

     -- Call Advanced Pricing for global Blanket purchase agreements
     -- Do not call Advanced Pricing for Blanket Purchase agreements and quotations


      IF (l_source_document_type = 'BLANKET'
          AND PO_GA_PVT.is_global_agreement(l_source_document_header_id))THEN


        IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id)) THEN

         -- bug5339880
         -- Use PO Currency directly, if provided. No need to pass in
         -- rate information anymore

          IF (p_currency_code IS NULL) THEN
            l_currency_code :=
            PO_HEADERS_SV3.get_currency_code(l_source_document_header_id);
          ELSE
            l_currency_code := p_currency_code;
          END IF;

          l_rate_type := NULL;
          l_rate := NULL;

          l_progress := '125';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(l_log_head, l_progress, 'l_currency_code', l_currency_code);
            PO_DEBUG.debug_var(l_log_head, l_progress, 'l_adv_price', l_adv_price);
            PO_DEBUG.debug_stmt(l_log_head, l_progress,'Call Advanced Pricing API(GBPA)');
          END IF; /* IF g_debug_stmt */


          PO_ADVANCED_PRICE_PVT.get_advanced_price
          (p_org_id => p_org_id
           , p_supplier_id => p_supplier_id
           , p_supplier_site_id => p_supplier_site_id
           , p_creation_date => p_creation_date
           , p_order_type => l_doc_sub_type --<Enhanced Pricing: Changed from 'PO' to identify calls from both GBPA and PO>
           , p_ship_to_location_id => p_ship_to_loc
           , p_ship_to_org_id => p_ship_to_org
           , p_order_header_id => p_order_header_id
           , p_order_line_id => p_order_line_id
           , p_item_revision => p_item_revision
           , p_item_id => p_item_id
           , p_category_id => p_category_id
           , p_supplier_item_num => p_supplier_item_num
           , p_agreement_type => l_source_document_type
           , p_agreement_id => l_source_document_header_id
           , p_agreement_line_id => p_po_line_id
           , p_rate => l_rate
           , p_rate_type => l_rate_type
           , p_currency_code => l_currency_code
           , p_need_by_date => l_pricing_date
           , p_quantity => p_order_quantity
           , p_uom => p_uom
           , p_unit_price => l_adv_price
           --<Enhanced Pricing Start>
           , p_draft_id => p_draft_id
           --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
           , p_pricing_call_src => p_pricing_call_src --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
           --<Enhanced Pricing End>
           , x_base_unit_price => l_base_unit_price
           , x_unit_price => l_price
           , x_return_status => l_return_status );

          l_progress := '130';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head, l_progress,'After Call Advanced Pricing API(GBPA)');
          END IF;

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            app_exception.raise_exception;
          END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

          l_progress := '135';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(l_log_head, l_progress, 'x_return_status', l_return_status);
            PO_DEBUG.debug_var(l_log_head, l_progress, 'x_base_unit_price', l_base_unit_price);
            PO_DEBUG.debug_var(l_log_head, l_progress, 'x_price', l_price);
          END IF;

        ELSE /* Invalid Line type*/

          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head, l_progress,
                                'Not a valid price type to call Advanced Pricing API(GBPA)');
          END IF;

        END IF; /*IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id))*/

      END IF; /* IF l_source_document_type  IN ('BLANKET')* and global */

      --<R12 GBPA Adv Pricing Support End>

      -- Bug 9974484
      -- Call to procedure PO_CUSTOM_PRICE_PUB.GET_CUSTOM_PO_PRICE was removed from here
      -- and put outside the if condition, so that it will be executed in case of PO is referenced by
      -- contract or there is no sourcing rule applied to PO.
      -- Get_custom_Po_Price should get priority over other settings as it is edited by
      -- customers for their customized pricing.


  -- <FPJ Advanced Price START>
    ELSIF (p_contract_id IS NOT NULL) THEN

    -- Bug 3422411: Moved the initialization here to avoid regressing the behavior
    -- when the referenced document is not contract. When a contract is referenced
    -- and Advanced Pricing API does not return any new price,the value of p_in_price
    -- will be passed back
      l_price := p_in_price;

      IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id)) THEN
        l_progress := '180';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head, l_progress,'Call Advanced Pricing API(CPA)');
        END IF;

        l_progress := '200';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head, l_progress,'Get Currency Info');
        END IF; /* IF g_debug_stmt */


      -- bug5339880
      -- Use the currency code from the PO always. No need to pass in
      -- rate information anymore

        IF (p_currency_code IS NULL) THEN
          l_currency_code := PO_HEADERS_SV3.get_currency_code(p_contract_id);
        ELSE
          l_currency_code := p_currency_code;
        END IF;

        l_rate_type := NULL;
        l_rate := NULL;

        l_progress := '220';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(l_log_head, l_progress, 'l_currency_code', l_currency_code);
          PO_DEBUG.debug_stmt(l_log_head, l_progress,'Call Advanced Pricing API(CPA)');
        END IF; /* IF g_debug_stmt */

        PO_ADVANCED_PRICE_PVT.get_advanced_price
        (p_org_id => p_org_id
         , p_supplier_id => p_supplier_id
         , p_supplier_site_id => p_supplier_site_id
         , p_creation_date => p_creation_date
         , p_order_type => l_doc_sub_type --<Enhanced Pricing: Changed from 'PO' to identify calls from both GBPA and PO>
         , p_ship_to_location_id => p_ship_to_loc
         , p_ship_to_org_id => p_ship_to_org
         , p_order_header_id => p_order_header_id
         , p_order_line_id => p_order_line_id
         , p_item_revision => p_item_revision
         , p_item_id => p_item_id
         , p_category_id => p_category_id
         , p_supplier_item_num => p_supplier_item_num
         , p_agreement_type => 'CONTRACT'
         , p_agreement_id => p_contract_id
         , p_rate => l_rate
         , p_rate_type => l_rate_type
         , p_currency_code => l_currency_code
         , p_need_by_date => l_pricing_date
         , p_quantity => p_order_quantity
         , p_uom => p_uom
         , p_unit_price => p_in_price
         --<Enhanced Pricing Start>
         , p_draft_id => p_draft_id --parameter to identify the draft record
         --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
         , p_pricing_call_src => p_pricing_call_src --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
         --<Enhanced Pricing End>
      -- Bug 3343892, Don't pass back Advanced Price list price
      -- , x_base_unit_price    => x_base_unit_price
         , x_base_unit_price => l_base_unit_price
         , x_unit_price => l_price
         , x_return_status => l_return_status );

        l_progress := '380';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head, l_progress,'After Call Advanced Pricing API(CPA)');
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          app_exception.raise_exception;
        END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

        --Enhanced Pricing
        x_base_unit_price := l_base_unit_price;
      ELSE
        l_progress := '400';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head, l_progress,
                              'Not a valid price type to call Advanced Pricing API(CPA)');
        END IF;
      END IF; /*IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id))*/

    --<Enhanced Pricing Start: No Source Document id is passed>
    ELSIF (l_src_flag = 'N') THEN
      l_price := p_in_price;

      IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id)) THEN
        l_progress := '420';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head, l_progress,'Call Advanced Pricing API(NSD - No Source Document)');
        END IF;

        l_progress := '440';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head, l_progress,'Get Currency Info');
        END IF;

        -- Use the currency code passed as parameter.
        l_currency_code := p_currency_code;

        l_rate_type := NULL;
        l_rate := NULL;

        l_progress := '460';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(l_log_head, l_progress, 'l_currency_code', l_currency_code);
          PO_DEBUG.debug_stmt(l_log_head, l_progress,'Call Advanced Pricing API(NSD - No Source Document)');
        END IF;

        PO_ADVANCED_PRICE_PVT.get_advanced_price
        (p_org_id => p_org_id
         , p_supplier_id => p_supplier_id
         , p_supplier_site_id => p_supplier_site_id
         , p_creation_date => p_creation_date
         , p_order_type => l_doc_sub_type --<Enhanced Pricing: Changed from 'PO' to identify calls from both GBPA and PO>
         , p_ship_to_location_id => p_ship_to_loc
         , p_ship_to_org_id => p_ship_to_org
         , p_order_header_id => p_order_header_id
         , p_order_line_id => p_order_line_id
         , p_item_revision => p_item_revision
         , p_item_id => p_item_id
         , p_category_id => p_category_id
         , p_supplier_item_num => p_supplier_item_num
         , p_agreement_type => NULL --No source document type
         , p_agreement_id => NULL --No source document id
         , p_rate => l_rate
         , p_rate_type => l_rate_type
         , p_currency_code => l_currency_code
         , p_need_by_date => l_pricing_date
         , p_quantity => p_order_quantity
         , p_uom => p_uom
         , p_unit_price => p_in_price
         , p_draft_id => p_draft_id --<Enhanced Pricing: parameter to identify>
         --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
         , p_pricing_call_src => p_pricing_call_src --<Enhanced Pricing: parameter to identify calls from retro/auto creation>
         , x_base_unit_price => l_base_unit_price
         , x_unit_price => l_price
         , x_return_status => l_return_status );

        l_progress := '480';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head, l_progress,'After Call Advanced Pricing API(NSD - No Source Document)');
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          app_exception.raise_exception;
        END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

        x_base_unit_price := l_base_unit_price;
      ELSE
        l_progress := '500';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head, l_progress,
                              'Not a valid price type to call Advanced Pricing API(NSD - No Source Document)');
        END IF;
      END IF; /*IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id))*/
    --<Enhanced Pricing End: >
    END IF; /* IF p_po_line_id IS NOT NULL */

    -- Bug 9974484
    -- Pasted call to PO_CUSTOM_PRICE_PUB.GET_CUSTOM_PO_PRICE here, so that it
    -- gets called in all cases. This method has customized code so has to have
    -- precedence over other code.

    --Pass the Price passed from Advance Pricing to Custom Price Hook

    -- <FPJ Custom Price START>
      l_progress := '140';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head, l_progress, 'Call get_custom_po_price');
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_order_quantity', p_order_quantity);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_ship_to_org', p_ship_to_org);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_ship_to_loc', p_ship_to_loc);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_source_document_line_id', p_po_line_id);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_need_by_date', p_need_by_date);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_pricing_date', l_pricing_date);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_line_location_id', p_line_location_id);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_price', l_price);
		PO_DEBUG.debug_var(l_log_head, l_progress, 'p_order_line_id', p_order_line_id); -- <Bug 15871591>
      END IF; /* IF g_debug_stmt */

    PO_CUSTOM_PRICE_PUB.GET_CUSTOM_PO_PRICE(p_api_version => 1.0,
                                            p_order_quantity => p_order_quantity,
                                            p_ship_to_org => p_ship_to_org,
                                            p_ship_to_loc => p_ship_to_loc,
                                            p_po_line_id => p_po_line_id,
                                            p_cum_flag => p_cum_flag,
                                            p_need_by_date => p_need_by_date,
                                            p_pricing_date => l_pricing_date,
                                            p_line_location_id => p_line_location_id,
                                            p_price => l_price,
                                            x_new_price => l_new_price,
                                            x_return_status => l_return_status,
                                            p_req_line_price => p_req_line_price,
                                            p_order_line_id => p_order_line_id); -- <Bug 15871591>

  -- <FPJ Advanced Price END>

        l_progress := '520';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head, l_progress, 'After Call get_custom_po_price');
        PO_DEBUG.debug_var(l_log_head, l_progress, 'x_new_price', l_new_price);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'x_return_status', x_return_status);
      END IF; /* IF g_debug_stmt */

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        app_exception.raise_exception;
      END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

      IF (l_new_price IS NOT NULL) THEN -- The custom API returned back a price.
        IF (l_new_price < 0) THEN -- Price has to be greater than or equal to zero
          po_message_s.app_error('PO_CUSTOM_PRICE_LESS_0',
                                 'ROUTINE', l_api_name,
                                 'ERR_NUMBER', l_progress,
                                 'CUSTOM_PRICING_API', 'GET_CUSTOM_PO_PRICE');
          app_exception.raise_exception;
        END IF; /* IF (l_new_price <0) */
        l_price := l_new_price;
      END IF; /* IF (l_new_price is not NULL) */

      --Enhanced Pricing: changed from l_price to l_base_unit_price
      x_base_unit_price := l_base_unit_price; -- <FPJ Advanced Price>
    -- <FPJ Custom Price END>

    x_price := l_price;

  -- Bug 9974484 end

  -- Bug# 4148430: Calculating x_from_advanced_pricing.
  -- WORKAROUND: Until QP fixes their API
    x_from_advanced_pricing := 'N';
    BEGIN
      SELECT 'Y' INTO x_from_advanced_pricing
      FROM qp_ldets_v
      WHERE line_index = 1
      AND LIST_LINE_TYPE_CODE = 'PLL';
    EXCEPTION WHEN OTHERS THEN
        NULL; -- if no_data_found then value remains unchanged. If other error no need to raise it
    END;

    l_progress := '520';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(l_log_head);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_return_status', x_return_status);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_base_unit_price', x_base_unit_price);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_price', x_price);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_price_break_id', x_price_break_id);
    END IF; /* IF g_debug_stmt */

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      po_message_s.sql_error('get_break_price', l_progress, SQLCODE);
      RAISE;

  END get_break_price;

/*===========================================================================

  FUNCTION NAME:        get_release_quantity()

===========================================================================*/
  FUNCTION get_release_quantity(x_ship_to_org IN NUMBER,
                                x_ship_to_loc IN NUMBER,
                                x_po_line_id IN NUMBER,
                                x_match_type IN OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  price_break_org NUMBER := NULL;
  price_break_loc NUMBER := NULL;
  release_quantity NUMBER := 0;
  temp_quantity NUMBER := 0;
  all_rls_quantity NUMBER := 0;
  exclude_quantity NUMBER := 0;
  subtract_quantity NUMBER := 0;
  candidate_quantity NUMBER := 0;
  progress VARCHAR2(3) := NULL;

  /* Define a cursor to select the distinct ship-to
  ** organization and location combinations in the
  ** price breaks for the designated agreement
  ** line.
  */

  CURSOR C1 IS
    SELECT DISTINCT nvl(pll.ship_to_organization_id,  - 1),
                    nvl(pll.ship_to_location_id,  - 1)
    FROM po_line_locations_all pll -- GA FPI
           /*
              Bug fix for 2687718.
              Added QUOTATION in the WHERE clause to ensure that pricing works when
              a Standard PO is sourced to a Quotation through the Supplier Catalog.
           */
    WHERE pll.shipment_type IN ('PRICE BREAK', 'QUOTATION')
    AND pll.po_line_id = x_po_line_id;

  BEGIN

    x_match_type := NULL;

    OPEN C1;
    LOOP

      FETCH C1
      INTO price_break_org, price_break_loc;

      EXIT WHEN C1%notfound;

      SELECT SUM(pll.quantity - nvl(pll.quantity_cancelled, 0))
      INTO temp_quantity
      FROM po_line_locations pll
      WHERE decode(price_break_org,  -1, pll.ship_to_organization_id,
                    price_break_org) = pll.ship_to_organization_id
      AND decode(price_break_loc,  -1, pll.ship_to_location_id,
                    price_break_loc) = pll.ship_to_location_id
      AND pll.shipment_type <> 'PRICE BREAK'
      AND pll.po_line_id = x_po_line_id;

      /* If no quantity is returned, then temp_quantity will be null.
      ** Set to 0 for subsequent math using this variable.
      */

      IF (temp_quantity IS NULL) THEN
        temp_quantity := 0;
      END IF;

      /* See package specification for details on how this algorithm
      ** works.  It is easier to read if not laced with comments.
      */

      IF (price_break_org = x_ship_to_org) THEN
        IF (price_break_loc = x_ship_to_loc) THEN
          x_match_type := 'ALL';
          release_quantity := temp_quantity;
          EXIT;
        ELSIF (price_break_loc =  - 1) THEN
          x_match_type := 'ORG';
          candidate_quantity := temp_quantity;
        ELSIF (price_break_loc <> x_ship_to_loc) THEN
          subtract_quantity := subtract_quantity + temp_quantity;
        END IF;
      ELSIF (price_break_org =  - 1) THEN
        IF (x_match_type IS NULL) THEN
          x_match_type := 'NULL';
        END IF;
        all_rls_quantity := temp_quantity;
      ELSE
        exclude_quantity := exclude_quantity + temp_quantity;
      END IF;
    END LOOP;

  /* Use greatest function to return 0 if the result can be
  ** a negative number.
  */

    IF (x_match_type = 'ALL') THEN
      RETURN(release_quantity);

    ELSIF (x_match_type = 'ORG') THEN
      RETURN(greatest(candidate_quantity - subtract_quantity, 0));

    ELSIF (x_match_type = 'NULL') THEN
      RETURN(greatest(all_rls_quantity - candidate_quantity
                      - subtract_quantity
                      - exclude_quantity, 0));
    ELSE
      x_match_type := 'NONE';
      RETURN(0);
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      po_message_s.sql_error('get_release_quantity', progress, SQLCODE);
      RAISE;

  END get_release_quantity;

/*===========================================================================

  FUNCTION NAME:        get_item_detail()

===========================================================================*/
  FUNCTION get_item_detail(X_item_id IN NUMBER,
                           X_org_id IN NUMBER,
                           X_planned_item_flag IN OUT NOCOPY VARCHAR2,
                           X_list_price IN OUT NOCOPY NUMBER,
                           X_primary_uom IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

  X_progress VARCHAR2(3) := NULL;

  BEGIN

    X_progress := '010';
/*Bug 979118
  If the item's MRP Planning codes are (MRP/DRP-7
                                        MPS/DRP-8
                                        DRP    -9) then the item should be
  considered as a planned item.Prior to the fix items with planning codes
  MRP(3) and MPS(4) only were considered as a planned item.
*/

    SELECT decode(msi.mrp_planning_code, 3, 'Y', 4, 'Y', 7, 'Y', 8, 'Y', 9, 'Y',
            decode(msi.inventory_planning_code, 1, 'Y', 2, 'Y', 'N'))
          , msi.list_price_per_unit
          , msi.primary_unit_of_measure
    INTO X_planned_item_flag
          , X_list_price
          , X_primary_uom
    FROM mtl_system_items msi
    WHERE msi.inventory_item_id = X_item_id
    AND msi.organization_id = X_org_id;

    RETURN (TRUE);

  EXCEPTION

    WHEN no_data_found THEN
      RETURN (FALSE);

    WHEN OTHERS THEN
      po_message_s.sql_error('get_item_detail', X_progress, SQLCODE);
      RAISE;

  END get_item_detail;

/*===========================================================================

  FUNCTION NAME:        get_display_find_option()

===========================================================================*/
  FUNCTION get_display_find_option RETURN VARCHAR2 IS

  X_progress VARCHAR2(3) := NULL;
  X_option_value VARCHAR2(1) := NULL;

  BEGIN

    X_progress := '010';

    fnd_profile.get('PO_SIC_DISPLAY_FIND', X_option_value);
    RETURN (X_option_value);

  EXCEPTION

    WHEN OTHERS THEN
      po_message_s.sql_error('get_display_find_option', X_progress, SQLCODE);
      RAISE;

  END get_display_find_option;

/*===========================================================================

  FUNCTION NAME:        get_default_results_option()

===========================================================================*/
  FUNCTION get_default_results_option RETURN VARCHAR2 IS

  X_progress VARCHAR2(3) := NULL;
  X_option_value VARCHAR2(30) := NULL;

  BEGIN

    X_progress := '010';

    fnd_profile.get('PO_SIC_DEFAULT_OPTION', X_option_value);
    RETURN (X_option_value);

  EXCEPTION

    WHEN OTHERS THEN
      po_message_s.sql_error('get_display_find_option', X_progress, SQLCODE);
      RAISE;

  END get_default_results_option;


/*===========================================================================

  PROCEDURE NAME:        update_line_price()

  This procedure updates the line price of a document.
===========================================================================*/
-- <FPJ Advanced Price START>
  PROCEDURE update_line_price
  (
     p_po_line_id IN NUMBER
   , p_price IN NUMBER
   , p_from_line_location_id IN NUMBER -- <SERVICES FPJ>
  )
  IS
  BEGIN

    update_line_price
    (p_po_line_id => p_po_line_id
     , p_price => p_price
     , p_base_unit_price => p_price
     , p_from_line_location_id => p_from_line_location_id
     );
  END update_line_price;
-- <FPJ Advanced Price END>


  PROCEDURE update_line_price
  (
   p_po_line_id IN NUMBER
   , p_price IN NUMBER
   , p_base_unit_price IN NUMBER -- <FPJ Advanced Price>
   , p_from_line_location_id IN NUMBER -- <SERVICES FPJ>
   )
  IS

  g_user_id NUMBER := fnd_global.user_id;

  BEGIN

    UPDATE po_lines_all
    SET unit_price = p_price,
           base_unit_price = p_base_unit_price, -- <FPJ Advanced Price>
           from_line_location_id = p_from_line_location_id, -- <SERVICES FPJ>
           last_update_date = SYSDATE,
           last_updated_by = g_user_id
    WHERE po_line_id = p_po_line_id;

  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('update_line_price', '', SQLCODE);
      RAISE;

  END update_line_price;


/*===========================================================================

  PROCEDURE NAME:        update_shipment_price()

  This procedure updates the shipment price of a document.
===========================================================================*/
  PROCEDURE update_shipment_price(p_price IN NUMBER,
                                  p_line_location_id IN NUMBER) IS
  g_user_id NUMBER := fnd_global.user_id;

  BEGIN

    UPDATE po_line_locations
    SET price_override = p_price,
           last_update_date = SYSDATE,
           last_updated_by = g_user_id
    WHERE line_location_id = p_line_location_id;

  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('update_shipment_price', '', SQLCODE);
      RAISE;

  END update_shipment_price;


/*===========================================================================

  PROCEDURE NAME:        get_min_shipment_num()

  This procedure gets the minimum shipment number of a Standard PO line
===========================================================================*/
  PROCEDURE get_min_shipment_num(p_po_line_id IN NUMBER,
                                 x_min_shipment_num OUT NOCOPY NUMBER) IS
  BEGIN
    SELECT MIN(shipment_num)
    INTO x_min_shipment_num
    FROM po_line_locations_all
    WHERE po_line_id = p_po_line_id
    AND nvl(cancel_flag, 'N') = 'N'
    AND nvl(closed_code, 'OPEN') <> 'FINALLY CLOSED';
  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('get_min_shipment_num', '', SQLCODE);
      RAISE;
  END;


/*===========================================================================

  PROCEDURE NAME:        get_shipment_price()

  This procedure prices a Standard PO based on its source document reference.
===========================================================================*/

-- <FPJ Advanced Price START>
  PROCEDURE get_shipment_price
  (p_po_line_id IN NUMBER,
   p_from_line_id IN NUMBER,
   p_min_shipment_num IN NUMBER,
   p_quantity IN NUMBER,
   x_price OUT NOCOPY NUMBER,
   x_from_line_location_id OUT NOCOPY NUMBER -- <SERVICES FPJ>
   )
  IS
  l_base_unit_price PO_LINES.base_unit_price%TYPE;
  BEGIN
    get_shipment_price
    (p_po_line_id => p_po_line_id
     , p_from_line_id => p_from_line_id
     , p_min_shipment_num => p_min_shipment_num
     , p_quantity => p_quantity
     , p_contract_id => NULL
     , p_org_id => NULL
     , p_supplier_id => NULL
     , p_supplier_site_id => NULL
     , p_creation_date => NULL
     , p_order_header_id => NULL
     , p_order_line_id => NULL
     , p_line_type_id => NULL
     , p_item_revision => NULL
     , p_item_id => NULL
     , p_category_id => NULL
     , p_supplier_item_num => NULL
     , p_uom => NULL
     , p_currency_code => NULL -- Bug 3564863
     , p_in_price => NULL
     , x_base_unit_price => l_base_unit_price
     , x_price => x_price
     , x_from_line_location_id => x_from_line_location_id
     );

  END get_shipment_price;
-- <FPJ Advanced Price END>

  PROCEDURE get_shipment_price
  (p_po_line_id IN NUMBER,
   p_from_line_id IN NUMBER,
   p_min_shipment_num IN NUMBER,
   p_quantity IN NUMBER,
    -- <FPJ Advanced Price START>
   p_contract_id IN NUMBER,
   p_org_id IN NUMBER,
   p_supplier_id IN NUMBER,
   p_supplier_site_id IN NUMBER,
   p_creation_date IN DATE,
   p_order_header_id IN NUMBER,
   p_order_line_id IN NUMBER,
   p_line_type_id IN NUMBER,
   p_item_revision IN VARCHAR2,
   p_item_id IN NUMBER,
   p_category_id IN NUMBER,
   p_supplier_item_num IN VARCHAR2,
   p_uom IN VARCHAR2,
   p_currency_code IN VARCHAR2, -- Bug 3564863
   p_in_price IN NUMBER,
   x_base_unit_price OUT NOCOPY NUMBER,
    -- <FPJ Advanced Price END>
   x_price OUT NOCOPY NUMBER,
   x_from_line_location_id OUT NOCOPY NUMBER -- <SERVICES FPJ>
   ) IS

  l_progress VARCHAR2(3) := NULL;
  l_ship_to_location_id NUMBER := NULL;
  l_ship_to_organization_id NUMBER := NULL;
  l_need_by_date DATE := NULL;
  l_line_location_id NUMBER := NULL;
  l_return_status VARCHAR2(1); -- <SERVICES FPJ>

  BEGIN
    l_progress := '001';
    BEGIN
      SELECT poll.ship_to_location_id, poll.ship_to_organization_id, poll.need_by_date, poll.line_location_id
      INTO l_ship_to_location_id, l_ship_to_organization_id, l_need_by_date, l_line_location_id
      FROM po_line_locations_all poll
      WHERE poll.po_line_id = p_po_line_id
      AND poll.shipment_num = p_min_shipment_num;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    l_progress := '002';

    -- <SERVICES FPJ>
    --
    PO_SOURCING2_SV.get_break_price
    (p_api_version => 1.0
     , p_order_quantity => p_quantity
     , p_ship_to_org => l_ship_to_organization_id
     , p_ship_to_loc => l_ship_to_location_id
     , p_po_line_id => p_from_line_id
     , p_cum_flag => FALSE
     , p_need_by_date => l_need_by_date
     , p_line_location_id => l_line_location_id
    -- <FPJ Advanced Price START>
     , p_contract_id => p_contract_id
     , p_org_id => p_org_id
     , p_supplier_id => p_supplier_id
     , p_supplier_site_id => p_supplier_site_id
     , p_creation_date => p_creation_date
     , p_order_header_id => p_order_header_id
     , p_order_line_id => p_order_line_id
     , p_line_type_id => p_line_type_id
     , p_item_revision => p_item_revision
     , p_item_id => p_item_id
     , p_category_id => p_category_id
     , p_supplier_item_num => p_supplier_item_num
     , p_in_price => p_in_price
     , p_uom => p_uom
     , p_currency_code => p_currency_code -- Bug 3564863
     , x_base_unit_price => x_base_unit_price
    -- <FPJ Advanced Price END>
     , x_price_break_id => x_from_line_location_id
     , x_price => x_price
     , x_return_status => l_return_status
     );
    -- <SERVICES FPJ END>

  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('get_shipment_price', l_progress, SQLCODE);
      RAISE;
  END get_shipment_price;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_break_price
--Function:
--<PDOI Enhancement Bug#17063664>
-- The procedure is used to get price from source document based on
-- Price Break.
--Parameters:
--IN:
-- x_pricing_attributes_rec
--  Record of x_pricing_attributes_rec_type. Contains all attributes needed for pricing.
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_break_price(
    p_api_version                   IN            NUMBER,
    x_pricing_attributes_rec        IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type,
    x_return_status                 OUT NOCOPY    VARCHAR2 )
IS
  l_key po_session_gt.key%TYPE;

  l_api_name CONSTANT VARCHAR2(30) := 'GET_BREAK_PRICE';
  l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_position NUMBER := 000;
  l_api_version NUMBER := 1.0;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(l_log_head, 'po_line_id_tbl', x_pricing_attributes_rec.po_line_id_tbl);
    PO_LOG.proc_begin(l_log_head, 'source_doc_hdr_id_tbl', x_pricing_attributes_rec.source_doc_hdr_id_tbl);
    PO_LOG.proc_begin(l_log_head, 'source_doc_line_id_tbl', x_pricing_attributes_rec.source_doc_line_id_tbl);
    PO_LOG.proc_begin(l_log_head, 'quantity_tbl', x_pricing_attributes_rec.quantity_tbl);
    PO_LOG.proc_begin(l_log_head, 'pricing_date_tbl', x_pricing_attributes_rec.pricing_date_tbl);
    PO_LOG.proc_begin(l_log_head, 'ship_to_loc_tbl', x_pricing_attributes_rec.ship_to_loc_tbl);
    PO_LOG.proc_begin(l_log_head, 'ship_to_org_tbl', x_pricing_attributes_rec.ship_to_org_tbl);
    PO_LOG.proc_begin(l_log_head, 'base_unit_price_tbl', x_pricing_attributes_rec.base_unit_price_tbl);
    PO_LOG.proc_begin(l_log_head, 'price_break_id_tbl', x_pricing_attributes_rec.price_break_id_tbl);
  END IF;

  l_position := 010;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) ) THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  l_key := PO_CORE_S.get_session_gt_nextval;
  FORALL i IN 1..x_pricing_attributes_rec.po_line_id_tbl.COUNT
  INSERT
  INTO po_session_gt
    (
      KEY,
      num1, -- po_line_id
      num2, -- from_header_id
      num3, -- from_line_id
      num4, -- quantity
      date1,-- pricing_date
      num5, -- ship_to_location
      num6, -- ship_to_org
      num7, -- base_unit_price
      num8  -- price_break_id
    )
    VALUES
    (
      l_key,
      x_pricing_attributes_rec.po_line_id_tbl(i),
      x_pricing_attributes_rec.source_doc_hdr_id_tbl(i),
      x_pricing_attributes_rec.source_doc_line_id_tbl(i),
      x_pricing_attributes_rec.quantity_tbl(i),
      x_pricing_attributes_rec.pricing_date_tbl(i),
      x_pricing_attributes_rec.ship_to_loc_tbl(i),
      x_pricing_attributes_rec.ship_to_org_tbl(i),
      x_pricing_attributes_rec.base_unit_price_tbl(i),
      x_pricing_attributes_rec.price_break_id_tbl(i)
    );

  l_position := 20;

  x_pricing_attributes_rec.po_line_id_tbl.delete;
  x_pricing_attributes_rec.base_unit_price_tbl.delete;
  x_pricing_attributes_rec.price_break_id_tbl.delete;

  -- Bug 17871061
  -- Selecting line_id in the inner query as
  -- the same source doc line can be reffered in multiple lines
  -- SO should filter using the line_id

  SELECT gt1.num1,-- po_line_id
         Nvl(price_break.price_override, pla.unit_price),-- base_unit_price
         price_break.line_location_id -- price_break_id
  BULK   COLLECT INTO x_pricing_attributes_rec.po_line_id_tbl, x_pricing_attributes_rec.base_unit_price_tbl,
                      x_pricing_attributes_rec.price_break_id_tbl
  FROM   po_lines_all pla,
         po_session_gt gt1,
         (SELECT line_id,
	         po_line_id,
                 price_override,
                 line_location_id
          FROM   (SELECT line_id,
	                 po_line_id,
                         price_override,
                         line_location_id,
                         Rank()
                           over(
                             PARTITION BY line_id,po_line_id	--BUG 19506266
                             ORDER BY ship_to_organization_id ASC,
                                       ship_to_location_id ASC,
                                       Nvl(quantity, 0) DESC,
                                       Trunc(creation_date) DESC,
                                       price_override ASC,
                                       shipment_num ASC)
                                 rank
                  FROM   (SELECT gt.num1 line_id,
		                 gt.num3 po_line_id,
                                 pll.price_override,
                                 pll.line_location_id,
                                 pll.ship_to_organization_id,
                                 pll.ship_to_location_id,
                                 pll.quantity,
                                 pll.creation_date,
                                 pll.shipment_num
                          FROM   po_line_locations_all pll,
                                 po_headers_all poh,
                                 po_session_gt gt
                          WHERE  gt.KEY = l_key
                                 AND pll.shipment_type = 'PRICE BREAK'
                                 AND pll.po_line_id = gt.num3
                                 AND pll.po_header_id = gt.num2
                                 AND pll.po_header_id = poh.po_header_id
                                 AND Nvl(pll.quantity, 0) <= Nvl(gt.num4, 0)
                                 AND ( ( gt.num6 = pll.ship_to_organization_id )
                                        OR ( pll.ship_to_organization_id IS NULL )
                                     )
                                 AND ( ( gt.num5 = pll.ship_to_location_id )
                                        OR ( pll.ship_to_location_id IS NULL ) )
                                 AND ( Nvl(Trunc(gt.date1), Trunc(SYSDATE)) >=
                                       Trunc(pll.start_date)
                                        OR pll.start_date IS NULL )
                                 AND ( Nvl(Trunc(gt.date1), Trunc(SYSDATE)) <=
                                       Trunc(pll.end_date)
                                        OR pll.end_date IS NULL )
                                 AND pll.shipment_type = 'PRICE BREAK' ))
          WHERE  rank = 1) price_break
  WHERE  gt1.num1 = price_break.line_id (+) -- Bug 18891225
         AND gt1.num3 = price_break.po_line_id (+)
         AND gt1.num3 = pla.po_line_id
         AND gt1.key = l_key;

  l_position := 30;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(l_log_head, l_position, 'After price break sql po_line_id_tbl - ', x_pricing_attributes_rec.po_line_id_tbl);
      PO_LOG.stmt(l_log_head, l_position, 'base_unit_price_tbl - ', x_pricing_attributes_rec.base_unit_price_tbl);
      PO_LOG.stmt(l_log_head, l_position, 'price_break_id_tbl - ', x_pricing_attributes_rec.price_break_id_tbl);
    END IF;

  DELETE FROM po_session_gt
        WHERE  key = l_key;

  l_position := 40;
  IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(l_log_head);
  END IF;

EXCEPTION

    WHEN OTHERS THEN
       PO_MESSAGE_S.add_exc_msg ( p_pkg_name => G_PKG_NAME, p_procedure_name => l_api_name || '.' || l_position );
       RAISE;

END get_break_price;

END PO_SOURCING2_SV;

/
