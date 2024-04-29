--------------------------------------------------------
--  DDL for Package Body PO_PRICE_BREAK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PRICE_BREAK_GRP" as   /* <TIMEPHASED FPI> */
/* $Header: POXPRBKB.pls 120.5.12010000.3 2011/11/10 22:30:17 lswamy ship $ */

/*===========================================================================*/
/*======================= SPECIFICATIONS (PRIVATE) ==========================*/
/*===========================================================================*/

G_PKG_NAME	CONSTANT varchar2(30) := 'PO_PRICE_BREAK_GRP';
g_log_head	CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- <FPJ Custom Price START>
-- Debugging
g_debug_stmt BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp BOOLEAN := PO_DEBUG.is_debug_unexp_on;
-- <FPJ Custom Price END>

/*
Bug 13061889 : We have defined this function in the Specs so other packages can access it, so this becomes redundant.
FUNCTION get_conversion_rate                  -- <2694908>
(    p_po_header_id    IN   PO_HEADERS_ALL.po_header_id%TYPE
) RETURN PO_HEADERS_ALL.rate%TYPE;
*/

FUNCTION get_line_price                       -- <2694908>
(    p_po_header_id    IN   PO_HEADERS_ALL.po_header_id%TYPE ,
     p_po_line_num     IN   PO_LINES_ALL.line_num%TYPE
) RETURN PO_LINES_ALL.unit_price%TYPE;

/*===========================================================================*/
/*============================ BODY (Overloaded) ============================*/
/*===========================================================================*/

Procedure Get_Price_Break (
	source_document_header_id	IN NUMBER,
        source_document_line_num	IN NUMBER,
	in_quantity			IN NUMBER,
	unit_of_measure			IN VARCHAR2,
        deliver_to_location_id		IN NUMBER,
	required_currency		IN VARCHAR2,
	required_rate_type		IN VARCHAR2,
	p_need_by_date			IN DATE,          --  <TIMEPHASED FPI>
	p_destination_org_id		IN NUMBER,        --  <TIMEPHASED FPI>
	base_price			OUT NOCOPY NUMBER,
	currency_price			OUT NOCOPY NUMBER,
	discount			OUT NOCOPY NUMBER,
	currency_code			OUT NOCOPY VARCHAR2,
	rate_type			OUT NOCOPY VARCHAR2,
	rate_date			OUT NOCOPY DATE,
	rate				OUT NOCOPY NUMBER
) is

l_price_break_id  number;
Begin

    get_price_break
    (  p_source_document_header_id	=> source_document_header_id
    ,  p_source_document_line_num	=> source_document_line_num
    ,  p_in_quantity			=> in_quantity
    ,  p_unit_of_measure		=> unit_of_measure
    ,  p_deliver_to_location_id		=> deliver_to_location_id
    ,  p_required_currency		=> required_currency
    ,  p_required_rate_type		=> required_rate_type
    ,  p_need_by_date			=> p_need_by_date		--  <TIMEPHASED FPI>
    ,  p_destination_org_id		=> p_destination_org_id		--  <TIMEPHASED FPI>
    ,  x_base_price			=> base_price
    ,  x_currency_price			=> currency_price
    ,  x_discount			=> discount
    ,  x_currency_code			=> currency_code
    ,  x_rate_type                 	=> rate_type
    ,  x_rate_date                 	=> rate_date
    ,  x_rate                      	=> rate
    ,  x_price_break_id            	=> l_price_break_id
    );

End;


Procedure Get_Price_Break (
	p_source_document_header_id	IN NUMBER,
        p_source_document_line_num	IN NUMBER,
	p_in_quantity			IN NUMBER,
	p_unit_of_measure		IN VARCHAR2,
        p_deliver_to_location_id	IN NUMBER,
	p_required_currency		IN VARCHAR2,
	p_required_rate_type		IN VARCHAR2,
	p_need_by_date			IN DATE,          --  <TIMEPHASED FPI>
	p_destination_org_id		IN NUMBER,        --  <TIMEPHASED FPI>
	x_base_price			OUT NOCOPY NUMBER,
	x_currency_price		OUT NOCOPY NUMBER,
	x_discount			OUT NOCOPY NUMBER,
	x_currency_code			OUT NOCOPY VARCHAR2,
	x_rate_type                 	OUT NOCOPY VARCHAR2,
	x_rate_date                 	OUT NOCOPY DATE,
	x_rate                      	OUT NOCOPY NUMBER,
        x_price_break_id            	OUT NOCOPY NUMBER    -- <SERVICES FPJ>
) is
  -- <FPJ Advanced Price START>
  l_base_unit_price		PO_REQUISITION_LINES.base_unit_price%TYPE;
  -- <FPJ Advanced Price END>
Begin

    get_price_break
    (  p_source_document_header_id	=> p_source_document_header_id
    ,  p_source_document_line_num	=> p_source_document_line_num
    ,  p_in_quantity			=> p_in_quantity
    ,  p_unit_of_measure		=> p_unit_of_measure
    ,  p_deliver_to_location_id		=> p_deliver_to_location_id
    ,  p_required_currency		=> p_required_currency
    ,  p_required_rate_type		=> p_required_rate_type
    ,  p_need_by_date			=> p_need_by_date		--  <TIMEPHASED FPI>
    ,  p_destination_org_id		=> p_destination_org_id		--  <TIMEPHASED FPI>
       -- <FPJ Advanced Price START>
    ,  p_org_id				=> NULL
    ,  p_supplier_id			=> NULL
    ,  p_supplier_site_id		=> NULL
    ,  p_creation_date			=> NULL
    ,  p_order_header_id		=> NULL
    ,  p_order_line_id			=> NULL
    ,  p_line_type_id			=> NULL
    ,  p_item_revision			=> NULL
    ,  p_item_id			=> NULL
    ,  p_category_id			=> NULL
    ,  p_supplier_item_num		=> NULL
    ,  p_in_price			=> NULL
    ,  x_base_unit_price		=> l_base_unit_price
       -- <FPJ Advanced Price END>
    ,  x_base_price			=> x_base_price
    ,  x_currency_price			=> x_currency_price
    ,  x_discount			=> x_discount
    ,  x_currency_code			=> x_currency_code
    ,  x_rate_type                 	=> x_rate_type
    ,  x_rate_date                 	=> x_rate_date
    ,  x_rate                      	=> x_rate
    ,  x_price_break_id            	=> x_price_break_id
    );

End;


/*===========================================================================*/
/*============================ BODY (PUBLIC) ================================*/
/*===========================================================================*/

Procedure Get_Price_Break (
	p_source_document_header_id	IN NUMBER,
        p_source_document_line_num	IN NUMBER,
	p_in_quantity			IN NUMBER,
	p_unit_of_measure		IN VARCHAR2,
        p_deliver_to_location_id	IN NUMBER,
	p_required_currency		IN VARCHAR2,
	p_required_rate_type		IN VARCHAR2,
	p_need_by_date			IN DATE,          --  <TIMEPHASED FPI>
	p_destination_org_id		IN NUMBER,        --  <TIMEPHASED FPI>
	-- <FPJ Advanced Price START>
        p_org_id			IN  NUMBER,
	p_supplier_id			IN  NUMBER,
	p_supplier_site_id		IN  NUMBER,
	p_creation_date			IN  DATE,
	p_order_header_id		IN  NUMBER,
	p_order_line_id			IN  NUMBER,
	p_line_type_id			IN  NUMBER,
	p_item_revision			IN  VARCHAR2,
	p_item_id			IN  NUMBER,
	p_category_id			IN  NUMBER,
	p_supplier_item_num		IN  VARCHAR2,
	p_in_price			IN  NUMBER,
	x_base_unit_price		OUT NOCOPY NUMBER,
	-- <FPJ Advanced Price END>
	x_base_price			OUT NOCOPY NUMBER,
	x_currency_price		OUT NOCOPY NUMBER,
	x_discount			OUT NOCOPY NUMBER,
	x_currency_code			OUT NOCOPY VARCHAR2,
	x_rate_type                 	OUT NOCOPY VARCHAR2,
	x_rate_date                 	OUT NOCOPY DATE,
	x_rate                      	OUT NOCOPY NUMBER,
        x_price_break_id            	OUT NOCOPY NUMBER    -- <SERVICES FPJ>
) is

v_ship_to_location_id    number;
v_temp                   number;
v_return_unit_of_measure varchar2(26);

v_req_sob_id       number;                                 -- FPI GA
v_req_rate_type    po_headers_all.rate_type%TYPE;          -- FPI GA
v_ga_flag          varchar2(1);                            -- FPI GA
v_ga_currency      po_headers_all.currency_code%TYPE;      -- FPI GA
v_conversion_rate  po_headers_all.rate%TYPE;               -- FPI GA
v_po_rate          po_headers_all.rate%TYPE;               -- FPI GA

l_ship_to_org_id   po_line_locations_all.ship_to_organization_id%TYPE;   /* <TIMEPHASED FPI> */

l_dummy_var        BOOLEAN;                                -- <2694908>

l_progress         varchar2(4);

/* Bug2842675 */
l_base_curr_ext_precision  number;

-- <FPJ Custom Price START>
l_source_document_type	PO_HEADERS.type_lookup_code%TYPE;
l_source_document_line_id PO_LINES.po_line_id%TYPE;
l_pricing_date		PO_LINE_LOCATIONS.need_by_date%TYPE;
l_new_currency_price	PO_LINES.unit_price%TYPE;
l_return_status    	varchar2(1);
l_api_name		CONSTANT varchar2(30) := 'GET_PRICE_BREAK';
l_log_head		CONSTANT varchar2(100) := g_log_head || l_api_name;
-- <FPJ Custom Price END>

-- Bug 3343892
l_base_unit_price	PO_LINES.base_unit_price%TYPE;

-- Bug 3373445
l_currency_unit_price	NUMBER	:= null;
l_precision             NUMBER  := null;
l_ext_precision         NUMBER  := null;
l_min_acct_unit         NUMBER  := null;
l_qp_license 			VARCHAR2(30) := NULL;
--------------------------------------------------------------
-- Bug 2401468 (anhuang)				6/6/02
--------------------------------------------------------------
-- The following fixes were taken from the original USER_EXIT:
-- 1) Truncated all sysdates. (Bug 1655381)
-- 2) Added decode statement for QUOTATIONs in unit_price cursor
--    so it is equivalent to PRICE BREAK case. (Bug 1934869)

/*
   Bug 2800681.
   Change the defaulting of null quantity to 0 instead of -1 in the
   ORDER BY clause
   Bug 2842675 Rounded the price to the extended precision of the base
   currency
*/

-- bug4043100
-- Removed outer join to poll since it already handles null price case
CURSOR loc_unit_price  IS
        SELECT  poll.price_override
        ,       round(poll.price_override * v_conversion_rate, l_base_curr_ext_precision )
        ,       poh.rate_date
        ,       poh.rate
        ,       poh.currency_code
        ,       poh.rate_type
        ,       poll.price_discount
        ,       poll.price_override
        ,       decode(	poll.line_location_id,
			null, pol.unit_meas_lookup_code,
                       	poll.unit_meas_lookup_code)
        ,       poll.line_location_id           -- SERVICES FPJ
        FROM    po_headers_all poh              -- FPI GA
        ,       po_lines_all pol                -- FPI GA
        ,       po_line_locations_all poll      -- FPI GA
        WHERE   poh.po_header_id = p_source_document_header_id
        and     poh.po_header_id = pol.po_header_id
        and     pol.line_num = p_source_document_line_num
        and     pol.po_line_id = poll.po_line_id  -- bug4043100
        and     (   p_required_currency is null
                 or poh.currency_code = p_required_currency )
        and     (   p_required_rate_type is null
                 or poh.rate_type = p_required_rate_type )
        and     nvl(poll.unit_meas_lookup_code, nvl(p_unit_of_measure,
                                                pol.unit_meas_lookup_code))
                = nvl(p_unit_of_measure, pol.unit_meas_lookup_code)

        /* <TIMEPHASED FPI START> */
                /*
                   Change sysdate to l_pricing_date in order to use the Need By Date
                   to determine the price.
                */
        and   (trunc(nvl(l_pricing_date, trunc(sysdate))) >= trunc(poll.start_date) -- FPJ Custom Price
               OR
               poll.start_date is null)
        and   (trunc(nvl(l_pricing_date, trunc(sysdate))) <= trunc(poll.end_date) -- FPJ Custom Price
               OR
               poll.end_date is null)
        /* <TIMEPHASED FPI END> */
	   --Bug #2693408: added nvl clause to quantity check
        and     nvl(poll.quantity, 0) <= nvl(p_in_quantity, 0)


        /* <TIMEPHASED FPI START> */
                /*
                   Determining the price based on ship-to-location and destination organization
                */
        and     ((poll.ship_to_location_id = v_ship_to_location_id OR poll.ship_to_location_id is null)
                AND
                (poll.ship_to_organization_id = p_destination_org_id OR poll.ship_to_organization_id is null))

        /* <TIMEPHASED FPI END> */

        and     poll.shipment_type in ('PRICE BREAK', 'QUOTATION')

        -- <2721775 START>: Make sure Quotation Price Breaks are Approved.
        --
        -- bug4043100 - remove poll.shipment_type is null check
        AND     (    ( poll.shipment_type = 'PRICE BREAK' )
                OR   (   ( poll.shipment_type = 'QUOTATION' )
                     AND (   ( poh.approval_required_flag <> 'Y' )
                         OR  ( EXISTS ( SELECT ('Price Break is Approved')
                                        FROM   po_quotation_approvals pqa
					                    WHERE  pqa.line_location_id = poll.line_location_id
                                        AND    pqa.approval_type IN ('ALL ORDERS', 'REQUISITIONS')
                                        AND    (start_date_active is null
                                               OR trunc(nvl(l_pricing_date, sysdate)) >= start_date_active)
                                        AND    (end_date_active is null
                                               OR trunc(nvl(l_pricing_date, sysdate)) <= end_date_active)
                                       )))))
        -- <2721775 END>
        order by poll.ship_to_organization_id ASC, poll.ship_to_location_id ASC,
                 NVL(poll.quantity, 0) DESC,
                 trunc(poll.creation_date) DESC, poll.price_override ASC;   /* <TIMEPHASED FPI> */


BEGIN

  -- <FPJ Advanced Price START>
  -- Initialize OUT parameters
  x_base_unit_price	:= p_in_price;
  x_base_price		:= p_in_price;
  x_currency_price	:= p_in_price;
  x_discount	  	:= NULL;
  x_currency_code 	:= NULL;
  x_rate_type     	:= NULL;
  x_rate_date     	:= NULL;
  x_rate          	:= NULL;
  x_price_break_id	:= NULL;

  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_org_id',p_org_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_source_document_header_id',p_source_document_header_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_source_document_line_num',p_source_document_line_num);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_in_quantity',p_in_quantity);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_unit_of_measure',p_unit_of_measure);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_deliver_to_location_id',p_deliver_to_location_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_required_currency',p_required_currency);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_required_rate_type',p_required_rate_type);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_need_by_date',p_need_by_date);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_destination_org_id',p_destination_org_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_supplier_id',p_supplier_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_supplier_site_id',p_supplier_site_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_creation_date',p_creation_date);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_order_header_id',p_order_header_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_order_line_id',p_order_line_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_line_type_id',p_line_type_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_item_revision',p_item_revision);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_item_id',p_item_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_category_id',p_category_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_supplier_item_num',p_supplier_item_num);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_in_price',p_in_price);
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'get_ship_to_location');
  END IF;
  -- <FPJ Advanced Price END>

  -- <2694908 START>

  -- Initialize Variables Used in Cursors ===================================
  --
  -- (v_ship_to_location_id)
  l_dummy_var :=
  PO_LOCATIONS_S.get_ship_to_location( p_deliver_to_location_id,    -- IN
                                       v_ship_to_location_id );     -- IN/OUT

  l_progress := '020';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'v_ship_to_location_id',v_ship_to_location_id);
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'get_conversion_rate');
  END IF;

  -- (v_conversion_rate): Gets the correct rate for GAs and Local Blankets.
  v_conversion_rate := get_conversion_rate( p_source_document_header_id );

  l_progress := '040';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'v_conversion_rate',v_conversion_rate);
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'Get the base currency extended precision');
  END IF;

  -- Fetch Price from Cursors ===============================================
  --
   /* Bug 2842675 Get the base currency extended precision */
  SELECT nvl(FND.extended_precision,5)
  INTO   l_base_curr_ext_precision
  FROM   FND_CURRENCIES FND,
         FINANCIALS_SYSTEM_PARAMETERS FSP,
         GL_SETS_OF_BOOKS GSB
  WHERE  FSP.set_of_books_id = GSB.set_of_books_id AND
         FND.currency_code = GSB.currency_code;

  l_progress := '060';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_base_curr_ext_precision',l_base_curr_ext_precision);
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'Check source document type');
  END IF;

  -- <FPJ Custom Price START>

  -- SQL What: Find out the source document line id, and source doument type
  -- SQL Why : Get source document line id to call GET_CUSTOM_PRICE_DATE,
  --           Get source document type since we only allow custom pricing for
  --           Blanket and Quotation.
  SELECT ph.type_lookup_code,
         pl.po_line_id
  INTO   l_source_document_type,
         l_source_document_line_id
  FROM   po_headers_all ph,
         po_lines_all pl
  WHERE  ph.po_header_id = p_source_document_header_id
  AND    pl.po_header_id(+) = ph.po_header_id
  AND    pl.line_num(+) = p_source_document_line_num;

  l_progress := '080';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'Call get_custom_price_date');
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_source_document_header_id',p_source_document_header_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_source_document_line_id',l_source_document_line_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_quantity',p_in_quantity);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_ship_to_location_id',v_ship_to_location_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_ship_to_organization_id',p_destination_org_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_need_by_date',p_need_by_date);
  END IF; /* IF g_debug_stmt */
  /*Bug5598011 Passing the order_type as REQUISITION */
  /* call the Custom Price Date API    */
  PO_CUSTOM_PRICE_PUB.GET_CUSTOM_PRICE_DATE
    (p_api_version		=> 1.0,
     p_source_document_header_id=> p_source_document_header_id,	-- <FPJ Advanced Price>
     p_source_document_line_id	=> l_source_document_line_id,
     p_order_line_id		=> p_order_line_id,  -- <Bug 3754828>
     p_quantity			=> p_in_quantity,
     p_ship_to_location_id	=> v_ship_to_location_id,
     p_ship_to_organization_id	=> p_destination_org_id,
     p_need_by_date		=> p_need_by_date,
     x_pricing_date		=> l_pricing_date,
     x_return_status		=> l_return_status,
     p_order_type               => 'REQUISITION');

  l_progress := '100';

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    app_exception.raise_exception;
  END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

  IF (l_pricing_date IS NULL) THEN
    l_pricing_date := trunc(NVL(p_need_by_date, SYSDATE));
  END IF; /* IF (l_pricing_date IS NULL) */

  IF g_debug_stmt THEN
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'After Calling get_custom_price_date');
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_pricing_date',l_pricing_date);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status',l_return_status);
  END IF; /* IF g_debug_stmt */

  -- <FPJ Custom Price END>

  IF l_source_document_type IN ('BLANKET', 'QUOTATION') THEN
    l_progress := '120';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Open Cursor loc_unit_price');
    END IF; /* IF g_debug_stmt */

    OPEN loc_unit_price;

    l_progress := '140';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Fetch Cursor loc_unit_price');
    END IF; /* IF g_debug_stmt */

    FETCH loc_unit_price INTO
          v_temp
        , x_base_price
        , x_rate_date
        , x_rate
        , x_currency_code
        , x_rate_type
        , x_discount
        , x_currency_price
        , v_return_unit_of_measure
        , x_price_break_id;        -- SERVICES FPJ

    -- If 'loc_unit_price' returned no rows, get line price.
    --
    /*
       Bug 2803841.
       Removed the call to use cursor unit_price as this cursor
       is removed.
    */
    IF (loc_unit_price%ROWCOUNT = 0) THEN

      l_progress := '160';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Cursor loc_unit_price returned no rows');
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'get line price');
      END IF; /* IF g_debug_stmt */

      x_currency_price := get_line_price ( p_source_document_header_id ,
                                           p_source_document_line_num  );
      l_progress := '180';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_currency_price',x_currency_price);
      END IF; /* IF g_debug_stmt */

      /* Bug 2842675 Should be rounded off to the ext precision of the
         base currency */
      x_base_price     := round(x_currency_price * v_conversion_rate, l_base_curr_ext_precision);
      l_progress := '200';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_base_price',x_base_price);
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'get currency info');
      END IF; /* IF g_debug_stmt */

      x_discount       := 0;       -- line price does not have a discount
      x_price_break_id := NULL;    -- SERVICES FPJ

      PO_HEADERS_SV3.get_currency_info ( p_source_document_header_id ,
                                         x_currency_code             ,
                                         x_rate_type                 ,
                                         x_rate_date                 ,
                                         x_rate                      );
      l_progress := '220';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_currency_code',x_currency_code);
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate_type',x_rate_type);
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate_date',x_rate_date);
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate',x_rate);
      END IF; /* IF g_debug_stmt */
    ELSE
      l_progress := '240';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Cursor loc_unit_price returned rows');
        PO_DEBUG.debug_var(l_log_head,l_progress,'v_temp',v_temp);
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_base_price',x_base_price);
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate_date',x_rate_date);
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate',x_rate);
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_currency_code',x_currency_code);
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate_type',x_rate_type);
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_discount',x_discount);
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_currency_price',x_currency_price);
        PO_DEBUG.debug_var(l_log_head,l_progress,'v_return_unit_of_measure',v_return_unit_of_measure);
        PO_DEBUG.debug_var(l_log_head,l_progress,'x_price_break_id',x_price_break_id);
      END IF; /* IF g_debug_stmt */

    END IF; /*IF (loc_unit_price%ROWCOUNT = 0)*/

    l_progress := '260';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Close Cursor loc_unit_price');
    END IF; /* IF g_debug_stmt */

    -- <FPJ Advanced START>
    -- Bug 3417479, don't populate base_unit_price if source document is not CONTRACT
    -- x_base_unit_price := x_base_price;
    -- <FPJ Advanced END>

    CLOSE loc_unit_price;

    -- Unit of Measure ========================================================

    IF ( v_return_unit_of_measure <> p_unit_of_measure)
    THEN
        x_rate := 0;
        v_conversion_rate := 0;
        x_discount := 0;
    END IF;

    -- <2694908 END>

  --<FPJ Advanced Price START>
  ELSIF l_source_document_type = 'CONTRACT' THEN
    l_progress := '280';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Get Currency Info');
    END IF; /* IF g_debug_stmt */

    PO_HEADERS_SV3.get_currency_info ( p_source_document_header_id ,
                                       x_currency_code             ,
                                       x_rate_type                 ,
                                       x_rate_date                 ,
                                       x_rate                      );
    l_progress := '300';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_currency_code',x_currency_code);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate_type',x_rate_type);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate_date',x_rate_date);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate',x_rate);
    END IF; /* IF g_debug_stmt */
  END IF; /* l_source_document_type IN ('BLANKET', 'QUOTATION') */
  --<FPJ Advanced Price END>

  -- Global Agreements: Correct Currency/Rate info ==========================

  -- <GA FPI START>: Need to return GA rate info instead of from the PO.
  --
  IF ( PO_GA_PVT.is_global_agreement( p_source_document_header_id ) ) THEN

      PO_GA_PVT.get_currency_info( p_source_document_header_id ,
                                   x_currency_code             ,
                                   x_rate_type                 ,
                                   x_rate_date                 ,
                                   x_rate                      );
  END IF;
  -- <GA FPI END>

  -- <FPJ Custom Price START>

  /* call the Custom Pricing API    */
  -- Only allow custom pricing for Blanket and Quotation
  IF l_source_document_type IN ('BLANKET', 'QUOTATION') THEN

       --<R12 GBPA Adv Pricing Support Start>
       -- Call Advanced Pricing for global Blanket purchase agreements
       -- Do not call Advanced Pricing for Blanket Purchase agreements and quotations

     IF (l_source_document_type  = 'BLANKET'
        AND  PO_GA_PVT.is_global_agreement(p_source_document_header_id)) THEN

      IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id)) THEN

        l_progress := '305';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'x_currency_price: ' || x_currency_price);
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'Call Advanced Pricing API(GBPA)');
        END IF;

        PO_ADVANCED_PRICE_PVT.get_advanced_price
        (	p_org_id		=> p_org_id
        ,	p_supplier_id		=> p_supplier_id
        ,	p_supplier_site_id	=> p_supplier_site_id
        ,	p_creation_date    	=> p_creation_date
        ,	p_order_type		=> 'REQUISITION'
        ,	p_ship_to_location_id 	=> v_ship_to_location_id
        ,	p_ship_to_org_id 	=> p_destination_org_id
        ,       p_order_header_id	=> p_order_header_id
        ,       p_order_line_id  	=> p_order_line_id
        ,	p_item_revision 	=> p_item_revision
        ,	p_item_id		=> p_item_id
        ,	p_category_id		=> p_category_id
        ,	p_supplier_item_num	=> p_supplier_item_num
        ,       p_agreement_type	=> l_source_document_type
        ,	p_agreement_id  	=> p_source_document_header_id
        ,       p_agreement_line_id    =>  l_source_document_line_id
        ,	p_rate			=> x_rate
        ,	p_rate_type		=> x_rate_type
        ,	p_currency_code 	=> x_currency_code
        ,	p_need_by_date		=> l_pricing_date
        ,	p_quantity		=> p_in_quantity
        ,	p_uom			=> p_unit_of_measure
        ,	p_unit_price	 	=> x_currency_price
        ,       x_base_unit_price	=> l_base_unit_price
        ,       x_unit_price		=> l_new_currency_price
        ,       x_return_status	=> l_return_status );

        l_progress := '310';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'After Call Advanced Pricing API(GBPA)');
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          app_exception.raise_exception;
        END IF;

        x_base_price := round(l_new_currency_price * v_conversion_rate,
                              l_base_curr_ext_precision);
        x_currency_price := l_new_currency_price;

      ELSE /* Invalid Line type*/

        l_progress := '315';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head, l_progress,
             'Not a valid price type to call Advanced Pricing API(GBPA)');
        END IF;
      END IF; /*IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id))*/


    END IF; /* (l_source_document_type  IN ('BLANKET')*/

    --<R12 GBPA Adv Pricing Support End>
    --Pass the Price passed from Advance Pricing to Custom Price Hook

    l_progress := '320';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Call get_custom_req_price');
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_source_document_header_id',p_source_document_header_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_source_document_line_num',p_source_document_line_num);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_quantity',p_in_quantity);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_unit_of_measure',p_unit_of_measure);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_deliver_to_location_id',p_deliver_to_location_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_required_currency',p_required_currency);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_required_rate_type',p_required_rate_type);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_need_by_date',p_need_by_date);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_pricing_date',l_pricing_date);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_destination_org_id',p_destination_org_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_currency_price',x_currency_price);
    END IF; /* IF g_debug_stmt */

    PO_CUSTOM_PRICE_PUB.GET_CUSTOM_REQ_PRICE
      (p_api_version		=> 1.0,
       p_source_document_header_id=> p_source_document_header_id,
       p_source_document_line_num=> p_source_document_line_num,
       p_order_line_id		=> p_order_line_id,  -- <Bug 3754828>
       p_quantity		=> p_in_quantity,
       p_unit_of_measure	=> p_unit_of_measure,
       p_deliver_to_location_id	=> p_deliver_to_location_id,
       p_required_currency	=> p_required_currency,
       p_required_rate_type	=> p_required_rate_type,
       p_need_by_date		=> p_need_by_date,
       p_pricing_date		=> l_pricing_date,
       p_destination_org_id	=> p_destination_org_id,
       p_currency_price		=> x_currency_price,
       x_new_currency_price	=> l_new_currency_price,
       x_return_status		=> l_return_status);

    l_progress := '340';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'After Calling get_custom_req_price');
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_new_currency_price',l_new_currency_price);
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status',l_return_status);
    END IF; /* IF g_debug_stmt */

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      app_exception.raise_exception;
    END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

    IF (l_new_currency_price IS NOT NULL) THEN -- The custom API returned back a price.
      IF (l_new_currency_price < 0) THEN -- Price has to be greater than or equal to zero
        po_message_s.app_error('PO_CUSTOM_PRICE_LESS_0',
                               'ROUTINE', l_api_name,
                               'ERR_NUMBER', l_progress,
                               'CUSTOM_PRICING_API', 'GET_CUSTOM_REQ_PRICE');
        app_exception.raise_exception;
      END IF; /* IF (l_new_currency_price <0) */
      x_base_price := round(l_new_currency_price * v_conversion_rate,
                            l_base_curr_ext_precision);
      -- Bug 3417479, don't populate base_unit_price if source document is not CONTRACT
      -- x_base_unit_price := x_base_price;
      x_currency_price := l_new_currency_price;
    END IF; /* IF (l_new_price is not NULL) */

  -- <FPJ Advanced Price START>
  ELSIF (l_source_document_type = 'CONTRACT') THEN

     -- Bug 5516257: Get the profile value to check if Adv Pricing is installed
    FND_PROFILE.get('QP_LICENSED_FOR_PRODUCT',l_qp_license);
    l_progress := '345';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_qp_license',l_qp_license);
    END IF;

    --Bug 5516257: Added the logic to nullify the output unitprice if the Adv Pricing API
    --is not installed or licensed to PO;
    IF (l_qp_license IS NULL OR l_qp_license <> 'PO') THEN
      x_currency_price := null;

      l_progress := '350';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Advanced Pricing is not installed, nullify the new price');
      END IF;
    ELSE --Bug 5516257: Call Adv Pricing API if it's installed

     IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id)) THEN

      -- Bug 3373445 START
      -- p_in_price is in base currency, convert it to transaction currency
      l_progress := '350';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,
                             'Get currency extended precision for ' || x_currency_code);
      END IF;
      fnd_currency.get_info(x_currency_code, l_precision,
                            l_ext_precision, l_min_acct_unit);
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'p_in_price: ' || p_in_price);
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'v_conversion_rate: ' || v_conversion_rate);
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'l_ext_precision: ' || l_ext_precision);
      END IF;

      l_currency_unit_price := round(p_in_price/v_conversion_rate, l_ext_precision);
      -- Bug 3373445 END

      l_progress := '360';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'l_currency_unit_price: ' || l_currency_unit_price);
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'Call Advanced Pricing API(CPA)');
      END IF;


      PO_ADVANCED_PRICE_PVT.get_advanced_price
      (	p_org_id		=> p_org_id
      ,	p_supplier_id		=> p_supplier_id
      ,	p_supplier_site_id	=> p_supplier_site_id
      ,	p_creation_date		=> p_creation_date
      ,	p_order_type		=> 'REQUISITION'
      ,	p_ship_to_location_id 	=> v_ship_to_location_id
      ,	p_ship_to_org_id 	=> p_destination_org_id
      , p_order_header_id	=> p_order_header_id
      , p_order_line_id		=> p_order_line_id
      ,	p_item_revision		=> p_item_revision
      ,	p_item_id		=> p_item_id
      ,	p_category_id		=> p_category_id
      ,	p_supplier_item_num	=> p_supplier_item_num
      ,	p_agreement_type	=> 'CONTRACT'
      ,	p_agreement_id		=> p_source_document_header_id
      ,	p_rate			=> x_rate
      ,	p_rate_type		=> x_rate_type
      ,	p_currency_code		=> x_currency_code
      ,	p_need_by_date		=> l_pricing_date
      ,	p_quantity		=> p_in_quantity
      ,	p_uom			=> p_unit_of_measure
      -- Bug 3373445
      ,	p_unit_price	 	=> l_currency_unit_price
      -- Bug 3343892, Don't pass back Advanced Price List price
      -- , x_base_unit_price	=> x_base_unit_price
      , x_base_unit_price	=> l_base_unit_price
      , x_unit_price		=> l_new_currency_price
      , x_return_status		=> l_return_status );


      l_progress := '380';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'After Call Advanced Pricing API(CPA)');
      END IF;

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        app_exception.raise_exception;
      END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

      -- Bug 3373445
      x_base_price := round(l_new_currency_price * v_conversion_rate,
                            l_base_curr_ext_precision);
      x_currency_price := l_new_currency_price;
    ELSE
      l_progress := '400';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head, l_progress,
           'Not a valid price type to call Advanced Pricing API(CPA)');
      END IF;
    END IF; /*IF (PO_ADVANCED_PRICE_PVT.is_valid_qp_line_type(p_line_type_id))*/

  -- <FPJ Advanced Price END>

   END IF; -- if QP is not installed , license is <> PO

  END IF; /* IF l_source_document_type IN ('BLANKET', 'QUOTATION') */

  -- <FPJ Custom Price END>


  l_progress := '500';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_base_unit_price',x_base_unit_price);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_base_price',x_base_price);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_currency_price',x_currency_price);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_discount',x_discount);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_currency_code',x_currency_code);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate_type',x_rate_type);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate_date',x_rate_date);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate',x_rate);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_price_break_id',x_price_break_id);
  END IF; /* IF g_debug_stmt */

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
    END IF;

    -- bug4043100
    -- Close th e cursor if it's still open
    IF (loc_unit_price%ISOPEN) THEN
      CLOSE loc_unit_price;
    END IF;

    x_base_unit_price := NULL;
    x_base_price := NULL;
    x_currency_price := NULL;
    x_discount := NULL;
    x_currency_code := NULL;
    x_rate_type := NULL;
    x_rate_date := NULL;
    x_rate := NULL;
    x_price_break_id := NULL;
    po_message_s.sql_error('get_price_break', l_progress, sqlcode);
    raise;

END get_price_break;


--<TIMEPHASED FPI START>
/* This procedure is a wrapper for get_price_break */
/* It is called by the ReqImport code */
Procedure Reqimport_Set_Break_Price(
	p_request_id	IN	po_requisitions_interface.request_id%TYPE
) IS
  l_rowid			VARCHAR2(250) := '';
  l_src_blanket_header_id 	po_requisition_lines.blanket_po_header_id%TYPE;
  l_src_blanket_line_num	po_requisition_lines.blanket_po_line_num%TYPE;
  l_quantity			po_requisition_lines.quantity%TYPE;
  l_deliver_to_location		po_requisition_lines.deliver_to_location_id%TYPE;
  l_currency_code		po_requisition_lines.currency_code%TYPE;
  l_rate_type			po_requisition_lines.rate_type%TYPE;
  l_need_by_date		po_requisition_lines.need_by_date%TYPE;
  l_destination_org		po_requisition_lines.destination_organization_id%TYPE;
  l_base_price_out		po_requisition_lines.unit_price%TYPE;
  l_currency_price_out		po_requisition_lines.currency_unit_price%TYPE;
  l_discount_out		NUMBER;
  l_currency_code_out		po_requisition_lines.currency_code%TYPE;
  l_rate_type_out		po_requisition_lines.rate_type%TYPE;
  l_rate_date_out		po_requisition_lines.rate_date%TYPE;
  l_rate_out			po_requisition_lines.rate%TYPE;
  l_uom				po_requisitions_interface.unit_of_measure%TYPE;
  l_price_break_id              po_line_locations_all.line_location_id%TYPE;  -- <SERVICES FPJ>
  l_progress			VARCHAR2(3) := NULL;

  -- <FPJ Advanced Price START>
  l_org_id 			po_requisitions_interface.org_id%TYPE;
  l_requisition_header_id 	po_requisition_lines.requisition_header_id%TYPE;
  l_requisition_line_id 	po_requisition_lines.requisition_line_id%TYPE;
  l_creation_date		po_requisitions_interface.creation_date%TYPE;
  l_item_id 			po_requisitions_interface.item_id%TYPE;
  l_item_revision 		po_requisitions_interface.item_revision%TYPE;
  l_category_id 		po_requisitions_interface.category_id%TYPE;
  l_line_type_id 		po_requisitions_interface.line_type_id%TYPE;
  l_suggested_vendor_item_num 	po_requisitions_interface.suggested_vendor_item_num%TYPE;
  l_suggested_vendor_id 	po_requisitions_interface.suggested_vendor_id%TYPE;
  l_suggested_vendor_site_id 	po_requisitions_interface.suggested_vendor_site_id%TYPE;
  -- Bug 3343892
  l_base_unit_price 		po_requisitions_interface.base_unit_price%TYPE;
  l_base_unit_price_out		po_requisition_lines.base_unit_price%TYPE;
  -- <FPJ Advanced Price END>

  CURSOR req_lines IS
  	SELECT pri.rowid, pri.autosource_doc_header_id, pri.autosource_doc_line_num,
		pri.quantity, pri.deliver_to_location_id, pri.currency_code,
		pri.rate_type, pri.need_by_date, pri.destination_organization_id,
		pri.unit_of_measure,
		-- <FPJ Advanced Price START>
	  	pri.org_id,
	  	NULL requisition_header_id,
	  	NULL requisition_line_id,
	  	pri.creation_date,
	  	pri.item_id,
	  	pri.item_revision,
	  	pri.category_id,
	  	pri.line_type_id,
	  	pri.suggested_vendor_item_num,
	  	pri.suggested_vendor_id,
	  	pri.suggested_vendor_site_id,
	  	-- Bug 3343892
                pri.base_unit_price
		-- <FPJ Advanced Price END>
	FROM   po_requisitions_interface pri
	WHERE  pri.autosource_flag in ('Y', 'P')
               AND pri.item_id is not NULL
               AND pri.source_type_code = 'VENDOR'
               AND pri.autosource_doc_header_id is not NULL
               -- Bug 3417479
               -- AND pri.autosource_doc_line_num is not NULL
               AND pri.request_id = p_request_id;

BEGIN

   l_progress :='010';

   OPEN req_lines;
   LOOP
     FETCH req_lines into
	l_rowid, l_src_blanket_header_id, l_src_blanket_line_num,
	l_quantity, l_deliver_to_location, l_currency_code,
	l_rate_type, l_need_by_date, l_destination_org, l_uom,
	-- <FPJ Advanced Price START>
	l_org_id,
	l_requisition_header_id,
	l_requisition_line_id,
	l_creation_date,
	l_item_id,
	l_item_revision,
	l_category_id,
	l_line_type_id,
	l_suggested_vendor_item_num,
	l_suggested_vendor_id,
	l_suggested_vendor_site_id,
	-- Bug 3343892
	l_base_unit_price;
	-- <FPJ Advanced Price END>
     EXIT WHEN req_lines%NOTFOUND or req_lines%NOTFOUND IS NULL;

   l_progress :='020';
    get_price_break
    (  p_source_document_header_id	=> l_src_blanket_header_id
    ,  p_source_document_line_num	=> l_src_blanket_line_num
    ,  p_in_quantity			=> l_quantity
    ,  p_unit_of_measure		=> l_uom
    ,  p_deliver_to_location_id		=> l_deliver_to_location
    ,  p_required_currency		=> l_currency_code
    ,  p_required_rate_type		=> l_rate_type
    ,  p_need_by_date			=> l_need_by_date		--  <TIMEPHASED FPI>
    ,  p_destination_org_id		=> l_destination_org		--  <TIMEPHASED FPI>
       -- <FPJ Advanced Price START>
    ,  p_org_id				=> l_org_id
    ,  p_supplier_id			=> l_suggested_vendor_id
    ,  p_supplier_site_id		=> l_suggested_vendor_site_id
    ,  p_creation_date			=> l_creation_date
    ,  p_order_header_id		=> l_requisition_header_id
    ,  p_order_line_id			=> l_requisition_line_id
    ,  p_line_type_id			=> l_line_type_id
    ,  p_item_revision			=> l_item_revision
    ,  p_item_id			=> l_item_id
    ,  p_category_id			=> l_category_id
    ,  p_supplier_item_num		=> l_suggested_vendor_item_num
    -- Bug 3343892
    ,  p_in_price			=> l_base_unit_price
    ,  x_base_unit_price		=> l_base_unit_price_out
       -- <FPJ Advanced Price END>
    ,  x_base_price			=> l_base_price_out
    ,  x_currency_price			=> l_currency_price_out
    ,  x_discount			=> l_discount_out
    ,  x_currency_code			=> l_currency_code_out
    ,  x_rate_type                 	=> l_rate_type_out
    ,  x_rate_date                 	=> l_rate_date_out
    ,  x_rate                      	=> l_rate_out
    ,  x_price_break_id            	=> l_price_break_id 		-- <SERVICES FPJ>
    );

   l_progress := '030';

     UPDATE po_requisitions_interface pri
	SET -- Bug 3417479, only set NOT NULL price
	    -- pri.unit_price = l_base_price_out,
            -- pri.base_unit_price =  l_base_unit_price_out, -- <FPJ Advanced Price>
	    -- pri.currency_unit_price = l_currency_price_out,
	    pri.unit_price = NVL(l_base_price_out, pri.unit_price),
            pri.base_unit_price =  NVL(l_base_unit_price_out, pri.base_unit_price),
	    pri.currency_unit_price = NVL(l_currency_price_out, pri.currency_unit_price),
	    pri.currency_code = l_currency_code_out,
	    pri.rate_type = l_rate_type_out,
	    pri.rate_date = l_rate_date_out,
	    pri.rate = l_rate_out
	WHERE pri.rowid = l_rowid;

   l_progress :='040';
   END LOOP;
   CLOSE req_lines;

   EXCEPTION
	WHEN OTHERS THEN
	po_message_s.sql_error('set_break_price', l_progress, sqlcode);
	RAISE;
END Reqimport_Set_Break_Price;
--<TIMEPHASED FPI END>

/*===========================================================================*/
/*=========================== BODY (PRIVATE) ================================*/
/*===========================================================================*/

/*=============================================================================

    FUNCTION:     get_conversion_rate                      <2694908>

    DESCRIPTION:  Gets the rate for the given po_header_id.
                  If the document is a local Blanket, gets the rate defined
                  on the document headers. If it is a Global Agreement, gets
                  the rate defined in the Set of Books for the functional
                  currency and the GA's currency.

=============================================================================*/
FUNCTION get_conversion_rate
(
    p_po_header_id    IN   PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN PO_HEADERS_ALL.rate%TYPE
IS
    l_currency_code        PO_HEADERS_ALL.currency_code%TYPE;
    l_ga_flag              PO_HEADERS_ALL.global_agreement_flag%TYPE;
    l_po_rate              PO_HEADERS_ALL.rate%TYPE;

    l_sob_id               FINANCIALS_SYSTEM_PARAMETERS.set_of_books_id%TYPE;
    l_rate_type            PO_SYSTEM_PARAMETERS.default_rate_type%TYPE;

    x_rate                 PO_HEADERS_ALL.rate%TYPE;

BEGIN

    SELECT currency_code         ,
           nvl(global_agreement_flag, 'N') ,
           nvl(rate, 1)                 -- <TIMEPHASED FPI>
    INTO   l_currency_code ,
           l_ga_flag       ,
           l_po_rate
    FROM   po_headers_all
    WHERE  po_header_id = p_po_header_id;

    -- If document is local Blanket, get rate from document header
    --
    IF ( l_ga_flag = 'N' ) THEN

        x_rate := l_po_rate;

    -- Else, document is Global Agreement.
    -- Get rate between GA_currency and functional_currency.
    --
    ELSE

        SELECT set_of_books_id
        INTO   l_sob_id
        FROM   financials_system_parameters;

        SELECT default_rate_type
        INTO   l_rate_type
        FROM   po_system_parameters;

        x_rate := PO_CORE_S.get_conversion_rate( l_sob_id        ,
                                                 l_currency_code ,
                                                 sysdate         ,
                                                 l_rate_type     );
    END IF;

    return (x_rate);

EXCEPTION

    WHEN OTHERS THEN
        return (NULL);

END get_conversion_rate;


/*=============================================================================

    FUNCTION:      get_line_price                        <2694908>

    DESCRIPTION:   Gets the line price for the given document and line number
                   (in the document's currency).

=============================================================================*/
FUNCTION get_line_price
(
     p_po_header_id    IN   PO_HEADERS_ALL.po_header_id%TYPE ,
     p_po_line_num     IN   PO_LINES_ALL.line_num%TYPE
)
RETURN PO_LINES_ALL.unit_price%TYPE
IS
    x_unit_price       PO_LINES_ALL.unit_price%TYPE;

BEGIN

    SELECT unit_price
    INTO   x_unit_price
    FROM   po_lines_all
    WHERE  po_header_id = p_po_header_id
    AND    line_num = p_po_line_num;

    return (x_unit_price);

EXCEPTION

    WHEN OTHERS THEN
        return (NULL);

END get_line_price;


END po_price_break_grp;

/
