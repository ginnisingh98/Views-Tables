--------------------------------------------------------
--  DDL for Package Body POS_WC_VIEW_CANCEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_WC_VIEW_CANCEL_PVT" AS
/* $Header: POSVWCVB.pls 120.11.12010000.4 2012/10/25 11:35:21 pneralla ship $*/
l_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


FUNCTION GET_WC_CANCELLATION_STATUS ( p_wc_id    NUMBER)
RETURN VARCHAR2;

PROCEDURE GET_PO_SUMMARY_INFO
(
  p_wc_header_id      IN  NUMBER,
	p_wc_stage					IN  VARCHAR2,
  x_po_header_id      OUT nocopy  NUMBER,
  x_po_num            OUT nocopy VARCHAR2,
  x_po_currency_code  OUT nocopy VARCHAR2,
  x_po_ordered        OUT nocopy NUMBER,
  x_po_lines_ordered  OUT nocopy NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
);

PROCEDURE GET_PO_INFO
(
  p_po_header_id      IN  NUMBER,
  x_po_ordered        OUT nocopy NUMBER,
  x_po_approved       OUT nocopy NUMBER
);


PROCEDURE GET_WC_PREV_SUBMITTED
(
  p_po_header_id      IN  VARCHAR2,
  p_wc_request_date   IN  DATE,
  x_wc_prev_submitted OUT nocopy NUMBER,
  x_wc_prev_delivered OUT nocopy NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
);

PROCEDURE GET_WC_REQUESTED_AND_MATERIAL
(
  p_wc_id								IN  NUMBER,
  p_wc_stage						IN  VARCHAR2,
  x_wc_requested				OUT nocopy NUMBER,
	x_wc_material					OUT nocopy NUMBER,
	x_wc_delivery					OUT nocopy NUMBER,
  x_return_status				OUT nocopy VARCHAR2,
  x_return_msg					OUT nocopy VARCHAR2
);

PROCEDURE CANCEL_WC_PAY_ITEM
(
  p_shipment_line_id  IN    NUMBER,
  x_return_status     OUT   nocopy VARCHAR2,
  x_return_msg        OUT   nocopy VARCHAR2
);


procedure LOG
(
	p_level			in NUMBER,
	p_api_name	in VARCHAR2,
	p_msg				in VARCHAR2
);

procedure LOG
(
	p_level			in NUMBER,
	p_api_name	in VARCHAR2,
	p_msg				in VARCHAR2
)
IS
l_module varchar2(2000);
BEGIN
/* Taken from Package FND_LOG
   LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
   LEVEL_ERROR      CONSTANT NUMBER  := 5;
   LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
   LEVEL_EVENT      CONSTANT NUMBER  := 3;
   LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
   LEVEL_STATEMENT  CONSTANT NUMBER  := 1;
*/
	IF( p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		IF(l_fnd_debug = 'Y')THEN
			l_module := 'pos.plsql.pos_wc_view_cancel_pvt.'||p_api_name;
    	FND_LOG.string(	LOG_LEVEL => p_level,
											MODULE		=> l_module,
											MESSAGE		=> p_msg);
    END IF;
	END IF;
END log;

-----------------------------------------------------------------------------
--API name  :   GET_PO_HEADER_INFO
--TYPE      :   PUBLIC
--Function  :   Retrieve information related to a PO such as ordered amount
--              and approved amount
--Parameter :
--IN        :     p_po_header_id        IN  NUMBER    Required
--                      corresponds to the columne PO_HEADER_ID in the table
--                      PO_HEADERS_ALL, and identifies the PO for which the
--                      information should be retrieved.
--
--OUT       :     x_ordered             OUT NUMBER
--                      total ordered amount for the PO
--                x_approved            OUT NUMBER
--                      total approved amount for the PO
--                x_return_status       OUT VARCHAR2
--                      return status of the procedure
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure
-----------------------------------------------------------------------------
PROCEDURE GET_PO_HEADER_INFO
(
  p_po_header_id      IN  NUMBER,
  x_ordered           OUT nocopy NUMBER,
  x_approved          OUT nocopy NUMBER,
  x_pay_item_total    OUT nocopy NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
)

IS

BEGIN

    GET_PO_INFO(
      p_po_header_id => p_po_header_id,
      x_po_ordered => x_ordered,
      x_po_approved => x_approved);

		--Sums up all pay items (excluding delivery pay items)
		--This information should also be obtained from the PO API in the future
		SELECT  SUM(round(
                      NVL((POLL.QUANTITY - NVL(POLL.QUANTITY_CANCELLED,0))
                           *POLL.PRICE_OVERRIDE,(POLL.AMOUNT - NVL(POLL.AMOUNT_CANCELLED,0)))
				    ,get_currency_precision(p_po_header_id)))
		INTO x_pay_item_total
		FROM PO_LINE_LOCATIONS_ALL POLL
		WHERE POLL.PO_HEADER_ID = p_po_header_id AND
        POLL.PAYMENT_TYPE in ('MILESTONE', 'RATE', 'LUMPSUM');

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    LOG(FND_LOG.LEVEL_UNEXPECTED,'get_po_header_info',
        'Unexpected error when calling PO API');


END GET_PO_HEADER_INFO;

-----------------------------------------------------------------------------
--API name  :   GET_WC_INFO
--TYPE      :   PUBLIC
--Function  :   Retrieve all calculated WC information
--Parameter :
--IN        :     p_wc_id								IN	NUMBER		Required
--											corresponds to the column HEADER_INTERFACE_ID for
--											table RCV_HEADERS_INTERFACE; or SHIPMENT_HEADER_ID
--											for table RCV_SHIPMENT_HEADERS. It identifies the
--											WC for which the information should be retrieved.
--								p_wc_stage						IN	VARCHAR2	Required
--											specifies the stage of the WC (INTERFACE or SHIPMENT)
--								p_po_header_id        IN  NUMBER    Required
--                      corresponds to the columne PO_HEADER_ID in the table
--                      PO_HEADERS_ALL, and identifies the PO for which the
--                      information should be retrieved.
--								p_wc_request_date			IN	DATE			Required
--											provides date information for time-sensitive info
--								p_vendor_id						IN	NUMBER		Required
--											vendor id
--								p_vendor_site_id						IN	NUMBER		Required
--											corresponds to vendor site id
--OUT       :     x_ordered            OUT NUMBER
--                      total ordered amount for the WC
--								x_approved            OUT NUMBER
--                      total approved amount for the WC
--								x_prev_submitted            OUT NUMBER
--                      all previously submitted amount/quantity for the WC
--								x_requested            OUT NUMBER
--                      requested amount for the WC
--								x_material_stored            OUT NUMBER
--                      total material stored amount for the WC
--								x_total_requested            OUT NUMBER
--                      total requested amount for the WC
--								x_wc_status				           OUT VARCHAR2
--                      WC internal status
--								x_wc_display_status          OUT VARCHAR2
--                      WC display status
--                x_po_lines_ordered    OUT NUMBER
--                      total amount of MILESTONE, LUMPSUM, RATE pay items
--                      excluding DELIVERY pay item
--                x_prev_delivered      OUT NUMBER
--                      previously submitted amount/qty of a WC for DELIVERY
--                      pay items.
--                x_wc_delivered        OUT NUMBER
--                      the amount/qty requested of DELIVERY pay items of a WC
--                x_return_status       OUT VARCHAR2
--                      return status of the procedure
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure
-----------------------------------------------------------------------------
PROCEDURE GET_WC_INFO
(
  p_wc_id             IN  NUMBER,
  p_wc_stage          IN  VARCHAR2,
  p_wc_request_date   IN  DATE,
  p_vendor_id         IN  NUMBER,
  p_vendor_site_id    IN  NUMBER,
	x_po_header_id			OUT nocopy NUMBER,
	x_po_num						OUT nocopy VARCHAR2,
	x_po_currency_code	OUT	nocopy VARCHAR2,
  x_ordered           OUT nocopy NUMBER,
  x_approved          OUT nocopy NUMBER,
  x_prev_submitted    OUT nocopy NUMBER,
  x_requested					OUT nocopy NUMBER,
  x_material_stored		OUT nocopy NUMBER,
  x_total_requested   OUT nocopy NUMBER,
  x_wc_status					OUT	nocopy VARCHAR2,
  x_wc_display_status	OUT	nocopy VARCHAR2,
	x_po_lines_ordered	OUT nocopy NUMBER,
	x_prev_delivered		OUT nocopy NUMBER,
	x_delivery					OUT nocopy NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
)

IS

l_progress						NUMBER;
l_api_return_status		VARCHAR2(1);
l_api_return_msg			VARCHAR2(1000);

BEGIN

	l_progress := 0;

	GET_WC_STATUS(
		p_wc_id             => p_wc_id,
		p_wc_stage					=> p_wc_stage,
		x_wc_status         => x_wc_status,
		x_wc_display_status => x_wc_display_status,
		x_return_status     => l_api_return_status,
		x_return_msg        => l_api_return_msg);

	IF(l_api_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_progress := 1;

	GET_PO_SUMMARY_INFO(
		p_wc_header_id      => p_wc_id,
		p_wc_stage					=> p_wc_stage,
		x_po_header_id      => x_po_header_id,
		x_po_num						=> x_po_num,
		x_po_currency_code	=> x_po_currency_code,
		x_po_ordered        => x_ordered,
		x_po_lines_ordered	=> x_po_lines_ordered,
		x_return_status     => l_api_return_status,
		x_return_msg        => l_api_return_msg);

	IF(l_api_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_progress := 2;

	GET_WC_PREV_SUBMITTED (
		p_po_header_id      => x_po_header_id,
		p_wc_request_date   => p_wc_request_date,
		x_wc_prev_submitted => x_prev_submitted,
		x_wc_prev_delivered => x_prev_delivered,
		x_return_status     => l_api_return_status,
		x_return_msg        => l_api_return_msg);

	IF(l_api_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_progress := 3;

	GET_WC_REQUESTED_AND_MATERIAL(
		p_wc_id             => p_wc_id,
		p_wc_stage          => p_wc_stage,
		x_wc_requested			=> x_requested,
		x_wc_material				=> x_material_stored,
		x_wc_delivery				=> x_delivery,
		x_return_status     => l_api_return_status,
		x_return_msg        => l_api_return_msg);

	IF(l_api_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_progress := 4;

	x_total_requested := x_requested +x_material_stored;

	IF(x_wc_status = 'APPROVED' or x_wc_status='PROCESSED' OR x_wc_status = 'CORRECTED') THEN
		x_approved := x_total_requested;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_msg := l_api_return_msg;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_wc_info',
				'Expected error at stage: '|| l_progress);
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_wc_info',
				'Error: '|| l_api_return_msg);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := 'Unexpected error at stage: '||l_progress||
			' '||l_api_return_msg;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_wc_info',
				'Unexpected error at stage: '|| l_progress);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := 'Unexpected error in get_wc_info at stage: '|| l_progress;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_wc_info',
				'Unexpected error at stage: '|| l_progress);

END GET_WC_INFO;

-----------------------------------------------------------------------------
--API name  :   GET_PO_SUMMARY_INFO
--TYPE      :   PRIVATE
--Function  :   Retrieve PO related info of a WC
--Parameter :
--IN        :     p_po_header_id        IN  NUMBER    Required
--                      corresponds to the columne PO_HEADER_ID in the table
--                      PO_HEADERS_ALL, and identifies the PO for which the
--                      information should be retrieved.
--OUT       :     x_po_ordered					OUT	NUMBER
--											PO total of MILESTONE, LUMPSUM, RATE and DELIVERY
--											pay items
--								x_po_lines_ordered		OUT NUMBER
--											total of MILESTONE, LUMPSUM, RATE pay items
--											excluding DELIVERY pay item
--                x_po_num							OUT VARCHAR2
--                      returns POH.segment1
--                x_po_currency_code		OUT VARCHAR2
--                      returns POH.currency_code
--                x_return_status       OUT VARCHAR2
--                      return status of the procedure
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure
-----------------------------------------------------------------------------


PROCEDURE	GET_PO_SUMMARY_INFO
(
  p_wc_header_id			IN	NUMBER,
	p_wc_stage					IN  VARCHAR2,
  x_po_header_id		  OUT	nocopy NUMBER,
  x_po_num            OUT nocopy VARCHAR2,
  x_po_currency_code  OUT nocopy VARCHAR2,
  x_po_ordered        OUT nocopy NUMBER,
  x_po_lines_ordered  OUT nocopy NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
)

IS


NO_PO_ID							EXCEPTION;
l_progress						NUMBER;
l_po_header_id				NUMBER;

l_po_approved					NUMBER;

BEGIN

	l_progress := 0;

	--Retrieves the PO number and currency
	IF(p_wc_stage = 'INTERFACE') THEN

    SELECT DISTINCT
      POH.PO_HEADER_ID,
      POH.SEGMENT1,
      POH.CURRENCY_CODE
    INTO
      l_po_header_id, x_po_num, x_po_currency_code
    FROM
      RCV_TRANSACTIONS_INTERFACE RTI,
      PO_HEADERS_ALL  POH
    WHERE
      POH.PO_HEADER_ID = RTI.PO_HEADER_ID AND
      RTI.HEADER_INTERFACE_ID = p_wc_header_id;

	ELSIF (p_wc_stage = 'SHIPMENT') THEN

		SELECT DISTINCT
			POH.PO_HEADER_ID,
			POH.SEGMENT1,
			POH.CURRENCY_CODE
		INTO
			l_po_header_id, x_po_num, x_po_currency_code
		FROM
			RCV_SHIPMENT_LINES RSL,
			PO_HEADERS_ALL  POH
		WHERE
			POH.PO_HEADER_ID = RSL.PO_HEADER_ID AND
			RSL.SHIPMENT_HEADER_ID = p_wc_header_id;

	END IF;


	IF(l_po_header_id is NULL) THEN
		RAISE NO_PO_ID;
	END IF;

	l_progress := 1;

	--Calls PO API to retrieve ordered amount information
	GET_PO_INFO(
		p_po_header_id => l_po_header_id,
		x_po_ordered => x_po_ordered,
		x_po_approved => l_po_approved);

	l_progress := 2;

  --Sums up all pay items (excluding delivery pay items)
  --This information should also be obtained from the PO API in the future
	SELECT	SUM(
						NVL((POLL.QUANTITY - NVL(POLL.QUANTITY_CANCELLED,0))
                *POLL.PRICE_OVERRIDE,
						(POLL.AMOUNT - NVL(POLL.AMOUNT_CANCELLED,0))))
	INTO x_po_lines_ordered
	FROM PO_LINE_LOCATIONS_ALL POLL
	WHERE POLL.PO_HEADER_ID = l_po_header_id AND
				POLL.PAYMENT_TYPE in ('MILESTONE', 'RATE', 'LUMPSUM');

	x_po_header_id := l_po_header_id;

	IF (x_po_ordered is null) THEN x_po_ordered := 0; END IF;
	IF (x_po_lines_ordered is null) THEN x_po_lines_ordered := 0; END IF;

  LOG(FND_LOG.LEVEL_PROCEDURE,'get_po_summary_info',
        'x_po_ordered: '|| x_po_ordered);
  LOG(FND_LOG.LEVEL_PROCEDURE,'get_po_summary_info',
        'x_po_lines_ordered: '|| x_po_lines_ordered);

	x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

	WHEN NO_PO_ID THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_msg := 'Error in get_po_summary_info: No po_header_id';

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    LOG(FND_LOG.LEVEL_UNEXPECTED,'get_wc_prev_submitted',
        'Unexpected error occurred');

END GET_PO_SUMMARY_INFO;

-----------------------------------------------------------------------------
--API name  :   GET_PO_INFO
--TYPE      :   PRIVATE
--Function  :   A Wrapper to PO API to retrieve PO numerical information
--Parameter :
--IN        :     p_po_header_id        IN  NUMBER    Required
--                      corresponds to the column PO_HEADER_ID in the table
--                      PO_HEADERS_ALL, and identifies the PO for which the
--                      information should be retrieved.
--
--OUT       :     x_po_ordered             OUT NUMBER
--                      total ordered amount for the PO
--                x_po_approved            OUT NUMBER
--                      total approved amount for the PO
-----------------------------------------------------------------------------

PROCEDURE GET_PO_INFO
(
  p_po_header_id      IN  NUMBER,
  x_po_ordered        OUT nocopy NUMBER,
	x_po_approved				OUT nocopy NUMBER
)

IS

  l_quantity_total               NUMBER;
  l_amount_total                 NUMBER;
  l_quantity_delivered           NUMBER;
  l_amount_delivered             NUMBER;
  l_quantity_received            NUMBER;
  l_amount_received              NUMBER;
  l_quantity_shipped             NUMBER;
  l_amount_shipped               NUMBER;
  l_quantity_billed              NUMBER;
  l_amount_billed                NUMBER;
  l_quantity_financed            NUMBER;
  l_amount_financed              NUMBER;
  l_quantity_recouped            NUMBER;
  l_amount_recouped              NUMBER;
  l_retainage_withheld_amount    NUMBER;
  l_retainage_released_amount    NUMBER;
  l_amt_approved                 NUMBER := 0;
	l_org_id											 NUMBER;

  CURSOR l_amt_approved_csr IS
      select SUM(DECODE(PLL.matching_basis,
      'AMOUNT', NVL(PLL.amount_received, 0),
      'QUANTITY', round(NVL(PLL.quantity_received, 0)*NVL(PLL.price_override, 0),get_currency_precision(p_po_header_id))))
      from PO_LINE_LOCATIONS_ALL PLL
      where PLL.po_header_id = p_po_header_id
      and PLL.payment_type in ('MILESTONE', 'RATE', 'LUMPSUM');

BEGIN

	SELECT org_id
  INTO l_org_id
	FROM po_headers_all
  WHERE po_header_id = p_po_header_id;

	po_moac_utils_pvt.set_org_context(l_org_id);

	--Obviously this API is capable of retrieving other information. But we
  --we are only concerned with the ordered and approved amount for now.

  PO_DOCUMENT_TOTALS_PVT.get_order_totals(
    p_doc_type                => PO_DOCUMENT_TOTALS_PVT.g_doc_type_PO,
    p_doc_subtype             => PO_DOCUMENT_TOTALS_PVT.g_doc_subtype_STANDARD,
    p_doc_level               => PO_DOCUMENT_TOTALS_PVT.g_doc_level_HEADER,
    p_doc_level_id                 => p_po_header_id,
    x_quantity_total               => l_quantity_total,
    x_amount_total                 => l_amount_total,
    x_quantity_delivered           => l_quantity_delivered,
    x_amount_delivered             => l_amount_delivered,
    x_quantity_received            => l_quantity_received,
    x_amount_received              => l_amount_received,
    x_quantity_shipped             => l_quantity_shipped,
    x_amount_shipped               => l_amount_shipped,
    x_quantity_billed              => l_quantity_billed,
    x_amount_billed                => l_amount_billed,
    x_quantity_financed            => l_quantity_financed,
    x_amount_financed              => l_amount_financed,
    x_quantity_recouped            => l_quantity_recouped,
    x_amount_recouped              => l_amount_recouped,
    x_retainage_withheld_amount    => l_retainage_withheld_amount,
    x_retainage_released_amount    => l_retainage_released_amount);

	x_po_ordered := l_amount_total;

  --x_po_approved := l_amount_received;
  OPEN l_amt_approved_csr;
    LOOP
      FETCH l_amt_approved_csr INTO l_amt_approved;
      EXIT WHEN l_amt_approved_csr%NOTFOUND;
    END LOOP;
  CLOSE l_amt_approved_csr;

  x_po_approved := NVL(l_amt_approved, 0);

  LOG(FND_LOG.LEVEL_PROCEDURE,'get_po_info',
        'x_po_ordered: '|| l_amount_total);
  LOG(FND_LOG.LEVEL_PROCEDURE,'get_po_info',
        'x_po_approved: '|| l_amount_received);


EXCEPTION

WHEN OTHERS THEN NULL;
  LOG(FND_LOG.LEVEL_PROCEDURE,'get_po_summary_info',
        'Call to PO_DOCUMENT_TOTALS_PVT.get_order_totals not successful');
    --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END GET_PO_INFO;

-----------------------------------------------------------------------------
--API name  :   GET_WC_PREV_SUBMITTED
--TYPE      :   PRIVATE
--Function  :   Retrieve Previously submitted amount/qty for a WC
--Parameter :
--IN        :     p_po_header_id        IN  NUMBER    Required
--                      corresponds to the column PO_HEADER_ID in the table
--                      PO_HEADERS_ALL, and identifies the PO for which the
--                      information should be retrieved.
--								p_wc_request_date			IN	DATE			Required
--											uses to establish a time of reference for the
--											the defintion of Previously Submitted.
--OUT       :     x_prev_submitted      OUT NUMBER
--                      previously submitted amount of a WC for pay items:
--											MILESTONE, LUMPSUM, RATE
--								x_prev_delivered      OUT NUMBER
--                      previously submitted amount/qty of a WC for DELIVERY
--											pay items.
--                x_return_status       OUT VARCHAR2
--                      return status of the procedure
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure
-----------------------------------------------------------------------------

PROCEDURE	GET_WC_PREV_SUBMITTED
(
  p_po_header_id			IN	VARCHAR2,
  p_wc_request_date		IN	DATE,
  x_wc_prev_submitted OUT nocopy NUMBER,
	x_wc_prev_delivered  OUT nocopy NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
)

IS

l_wc_intf_prev_submitted	NUMBER;
l_wc_ship_prev_submitted	NUMBER;
l_wc_intf_prev_delivered  NUMBER;
l_wc_ship_prev_delivered  NUMBER;

BEGIN

	l_wc_intf_prev_submitted := 0;
	l_wc_ship_prev_submitted := 0;
	l_wc_intf_prev_delivered := 0;
	l_wc_ship_prev_delivered := 0;

	--Previously Submitted
	--Processing, Pending Approval, Approved, Processed and Rejected
	--Roll up all requested amount/quantity*price of all WCs against the same PO


	-------------
	--Interface
	-------------

  /*
		Rolls up all previously submitted pay items that are in INTF tables
		(excluding delivery pay items)
	*/
	SELECT SUM(	NVL(RTI.AMOUNT, RTI.QUANTITY*POLL.PRICE_OVERRIDE))
	INTO	l_wc_intf_prev_submitted
	FROM
				PO_LINE_LOCATIONS_ALL POLL,
				RCV_TRANSACTIONS_INTERFACE RTI,
				RCV_HEADERS_INTERFACE RHI
	WHERE
				RHI.HEADER_INTERFACE_ID = RTI.HEADER_INTERFACE_ID AND
			  RTI.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
				RTI.PROCESSING_STATUS_CODE = 'PENDING' AND
				RTI.TRANSACTION_STATUS_CODE = 'PENDING' AND
				POLL.PAYMENT_TYPE in ('MILESTONE', 'RATE', 'LUMPSUM') AND
				RTI.PO_HEADER_ID = p_po_header_id AND
				RHI.REQUEST_DATE < p_wc_request_date;

  IF(l_wc_intf_prev_submitted is NULL) THEN
		l_wc_intf_prev_submitted := 0;
  END IF;

  LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_prev_submitted',
        'l_wc_intf_prev_submitted: '|| l_wc_intf_prev_submitted);

  /*
		Rolls up all previously submitted delivery pay items
		that are in INTF tables
  */
  SELECT SUM( NVL(RTI.AMOUNT, RTI.QUANTITY*POLL.PRICE_OVERRIDE))
  INTO  l_wc_intf_prev_delivered
  FROM
        PO_LINE_LOCATIONS_ALL POLL,
        RCV_TRANSACTIONS_INTERFACE RTI,
        RCV_HEADERS_INTERFACE RHI
  WHERE
        RHI.HEADER_INTERFACE_ID = RTI.HEADER_INTERFACE_ID AND
        RTI.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
        RTI.PROCESSING_STATUS_CODE = 'PENDING' AND
        RTI.TRANSACTION_STATUS_CODE = 'PENDING' AND
        POLL.PAYMENT_TYPE = 'DELIVERY' AND
        RTI.PO_HEADER_ID = p_po_header_id AND
        RHI.REQUEST_DATE < p_wc_request_date;

  IF(l_wc_intf_prev_delivered is NULL) THEN
    l_wc_intf_prev_delivered := 0;
	END IF;

  LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_prev_submitted',
        'l_wc_intf_prev_delivered: '|| l_wc_intf_prev_delivered);

	-------------
	--Shipment
	-------------

  /*
		Rolls up all previously submitted pay items that are in SHIPMENT tables
	  (excluding delivery pay items)
	*/
	SELECT	SUM(NVL(RSL.AMOUNT_SHIPPED,RSL.QUANTITY_SHIPPED*POLL.PRICE_OVERRIDE))
	INTO		l_wc_ship_prev_submitted
	FROM
					PO_LINE_LOCATIONS_ALL POLL,
					RCV_SHIPMENT_HEADERS RSH,
					RCV_SHIPMENT_LINES RSL
	WHERE
					RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID AND
					RSL.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
						(RSL.APPROVAL_STATUS is NULL OR
						 RSL.APPROVAL_STATUS in ('APPROVED', 'REJECTED')) AND
					RSL.SHIPMENT_LINE_STATUS_CODE <> 'CANCELLED' AND
					POLL.PAYMENT_TYPE in ('MILESTONE', 'RATE', 'LUMPSUM') AND
					RSL.PO_HEADER_ID = p_po_header_id AND
					RSH.REQUEST_DATE < p_wc_request_date;

  IF(l_wc_ship_prev_submitted is NULL) THEN
		l_wc_ship_prev_submitted := 0;
  END IF;

  LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_prev_submitted',
        'l_wc_ship_prev_submitted: '|| l_wc_ship_prev_submitted);

  /*Rolls up all previously submitted delivery pay items
		that are in SHIPMENT tables
  */
  SELECT  SUM(NVL(RSL.AMOUNT_SHIPPED,RSL.QUANTITY_SHIPPED*POLL.PRICE_OVERRIDE))
  INTO    l_wc_ship_prev_delivered
  FROM
          PO_LINE_LOCATIONS_ALL POLL,
          RCV_SHIPMENT_HEADERS RSH,
          RCV_SHIPMENT_LINES RSL
  WHERE
          RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID AND
          RSL.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
            (RSL.APPROVAL_STATUS is NULL OR
             RSL.APPROVAL_STATUS in ('APPROVED', 'REJECTED')) AND
          RSL.SHIPMENT_LINE_STATUS_CODE <> 'CANCELLED' AND
          POLL.PAYMENT_TYPE = 'DELIVERY' AND
          RSL.PO_HEADER_ID = p_po_header_id AND
          RSH.REQUEST_DATE < p_wc_request_date;

  IF(l_wc_ship_prev_delivered is NULL) THEN
    l_wc_ship_prev_delivered := 0;
  END IF;

	x_wc_prev_submitted := l_wc_intf_prev_submitted + l_wc_ship_prev_submitted;
  x_wc_prev_delivered := l_wc_intf_prev_delivered + l_wc_ship_prev_delivered;

  LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_prev_submitted',
    'x_wc_prev_submitted: '|| x_wc_prev_submitted);
  LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_prev_submitted',
    'x_wc_prev_delivered: '|| x_wc_prev_delivered);

	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_wc_prev_submitted',
				'Unexpected error occurred');

END GET_WC_PREV_SUBMITTED;


-----------------------------------------------------------------------------
--API name  :   GET_WC_REQUESTED_AND_MATERIAL
--TYPE      :   PRIVATE
--Function  :   Retrieve requested amount/qty and material stored amount of a WC
--Parameter :
--IN        :     p_wc_id               IN  NUMBER    Required
--                      corresponds to the column HEADER_INTERFACE_ID in
--                      the table RCV_HEADERS_INTERFACE
--                p_wc_stage						IN  VARCHAR2    Required
--										  indicates if the information in the INTERFACE tables
--											or the SHIPMENT tables
--OUT				:     x_wc_requested				OUT  NUMBER
--											the amount/qty requested of
--											LUMPSUM, MILESTONE, RATE pay items of a WC
--								x_wc_delivered				OUT NUMBER
--											the amount/qty requested of DELIVERY pay items of a WC
--								x_wc_material					OUT NUMBER
--                      corresponds to the material stored of a WC
--                x_return_status       OUT VARCHAR2
--                      return status of the procedure
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure
-----------------------------------------------------------------------------

PROCEDURE GET_WC_REQUESTED_AND_MATERIAL
(
  p_wc_id								IN  NUMBER,
  p_wc_stage						IN  VARCHAR2,
  x_wc_requested				OUT nocopy NUMBER,
	x_wc_material					OUT nocopy NUMBER,
	x_wc_delivery					OUT nocopy NUMBER,
  x_return_status				OUT nocopy VARCHAR2,
  x_return_msg					OUT nocopy VARCHAR2
)

IS

l_requested			NUMBER;
l_material			NUMBER;
l_delivery			NUMBER;

BEGIN

	IF(p_wc_stage = 'INTERFACE') THEN

		SELECT	SUM(NVL(RTI.REQUESTED_AMOUNT, Round(RTI.QUANTITY*POLL.PRICE_OVERRIDE,get_currency_precision(poll.po_header_id)))),
						SUM(NVL(RTI.MATERIAL_STORED_AMOUNT,0))
		INTO l_requested, l_material
		FROM	RCV_TRANSACTIONS_INTERFACE RTI,
					RCV_HEADERS_INTERFACE RHI,
					PO_LINE_LOCATIONS_ALL POLL
		WHERE RHI.HEADER_INTERFACE_ID = RTI.HEADER_INTERFACE_ID AND
					RTI.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
					POLL.PAYMENT_TYPE in ('MILESTONE', 'LUMPSUM', 'RATE') AND
					RHI.HEADER_INTERFACE_ID = p_wc_id;

    SELECT  SUM(NVL(RTI.AMOUNT, RTI.QUANTITY*POLL.PRICE_OVERRIDE))
    INTO l_delivery
    FROM  RCV_TRANSACTIONS_INTERFACE RTI,
          RCV_HEADERS_INTERFACE RHI,
          PO_LINE_LOCATIONS_ALL POLL
    WHERE RHI.HEADER_INTERFACE_ID = RTI.HEADER_INTERFACE_ID AND
          RTI.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
					POLL.PAYMENT_TYPE = 'DELIVERY' AND
          RHI.HEADER_INTERFACE_ID = p_wc_id;

  ELSIF(p_wc_stage = 'SHIPMENT') THEN

		SELECT  SUM(NVL(RSL.REQUESTED_AMOUNT,Round(RSL.QUANTITY_SHIPPED*POLL.PRICE_OVERRIDE,get_currency_precision(poll.po_header_id)))),
						SUM(NVL(RSL.MATERIAL_STORED_AMOUNT,0))
		INTO l_requested, l_material
		FROM	RCV_SHIPMENT_LINES RSL,
					RCV_SHIPMENT_HEADERS RSH,
					PO_LINE_LOCATIONS_ALL POLL
		WHERE RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID AND
			    RSL.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
					POLL.PAYMENT_TYPE in ('MILESTONE', 'LUMPSUM', 'RATE') AND
				  RSH.SHIPMENT_HEADER_ID = p_wc_id;

		SELECT  SUM(NVL(RSL.AMOUNT_SHIPPED,RSL.QUANTITY_SHIPPED*POLL.PRICE_OVERRIDE))
    INTO l_delivery
    FROM  RCV_SHIPMENT_LINES RSL,
          RCV_SHIPMENT_HEADERS RSH,
          PO_LINE_LOCATIONS_ALL POLL
    WHERE RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID AND
          RSL.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
          POLL.PAYMENT_TYPE = 'DELIVERY'  AND
          RSH.SHIPMENT_HEADER_ID = p_wc_id;

	END IF;

	IF(l_requested is NULL) THEN l_requested := 0; END IF;
	IF(l_material is NULL) THEN l_material := 0; END IF;
	IF(l_delivery is NULL) THEN l_delivery := 0; END IF;

	x_wc_requested	:= l_requested;
	x_wc_material		:= l_material;
	x_wc_delivery		:= l_delivery;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_wc_requested_and_material',
				'Unexpected error occurred');

END GET_WC_REQUESTED_AND_MATERIAL;

-----------------------------------------------------------------------------
--API name  :   GET_WC_STATUS
--TYPE      :   PRIVATE
--Function  :   Retrieve the status of a  WC
--Parameter :
--IN        :     p_wc_id               IN  NUMBER    Required
--                      corresponds to the column HEADER_INTERFACE_ID in
--                      the table RCV_HEADERS_INTERFACE.
--                p_wc_stage            IN  VARCHAR2    Required
--                      indicates if the information in the INTERFACE tables.
--                      or the SHIPMENT tables
--OUT       :     x_wc_status						OUT VARCHAR2
--                      corresponds to internal status of a WC.
--                x_wc_display_status   OUT VARCHAR2
--                      corresponds to the status of a WC on the UI.
--                x_return_status       OUT VARCHAR2
--                      return status of the procedure.
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure.
-----------------------------------------------------------------------------

PROCEDURE GET_WC_STATUS
(
	p_wc_id             IN  NUMBER,
  p_wc_stage					IN	VARCHAR2,
  x_wc_status					OUT nocopy VARCHAR2,
  x_wc_display_status	OUT nocopy VARCHAR2,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
)

IS

l_rti_line_count						NUMBER	:=	1;
l_wc_total_lines						NUMBER;
l_wc_lines_processed				NUMBER;
l_wc_lines_errored					NUMBER;
l_header_processing_status	VARCHAR2(10);
l_header_transaction_type		VARCHAR2(10);
l_header_approval_status		VARCHAR2(20);
l_line_approval_status			VARCHAR2(20);
l_cancellation_status       VARCHAR2(20);
l_is_wc_processed						VARCHAR2(1);
l_wc_lines_corrected        NUMBER;

BEGIN

	--Possible statuses in Interface stage:
	--DRAFT, PROCESSING, ERROR, CANCEL


	--WC in the Interface Tables
	IF (p_wc_stage = 'INTERFACE') then

		SELECT  processing_status_code, transaction_type
		INTO		l_header_processing_status, l_header_transaction_type
		FROM    RCV_HEADERS_INTERFACE
		WHERE   HEADER_INTERFACE_ID = p_wc_id;

	  IF(l_header_processing_status = 'DRAFT' and
			 l_header_transaction_type = 'DRAFT') THEN

			x_wc_status := 'DRAFT';
	    x_wc_display_status :=
				fnd_message_cache.get_string('POS', 'POS_WC_STATUS_DRAFT');

	  ELSIF(l_header_processing_status = 'PENDING' and
					l_header_transaction_type = 'NEW') THEN

			x_wc_status := 'PROCESSING';
      x_wc_display_status :=
				fnd_message_cache.get_string('POS', 'POS_WC_STATUS_PROCESSING');

	  ELSIF(l_header_processing_status = 'RUNNING' and
					l_header_transaction_type = 'NEW') THEN

			x_wc_status := 'RUNNING';
      x_wc_display_status :=
				fnd_message_cache.get_string('POS', 'POS_WC_STATUS_RUNNING');

	  ELSIF(l_header_processing_status = 'SUCCESS' and
					l_header_transaction_type = 'NEW') THEN

			x_wc_status := 'SUCCESS';


	  ELSIF(l_header_processing_status = 'ERROR' and
					l_header_transaction_type = 'NEW') THEN

			x_wc_status := 'ERROR';
      x_wc_display_status :=
				fnd_message_cache.get_string('POS', 'POS_WC_STATUS_ERROR');

	  ELSIF(l_header_processing_status = 'CANCELLED') THEN

			x_wc_status := 'INTERFACE CANCELED';
      x_wc_display_status :=  fnd_message_cache.get_string('POS', 'POS_WC_STATUS_CANCELED');

    -- Not handling ERROR and CANCEL yet

    END IF;
  END IF;

	IF (p_wc_stage = 'SHIPMENT') THEN


		l_cancellation_status := GET_WC_CANCELLATION_STATUS(p_wc_id);

    IF (l_cancellation_status = 'NO_CANCELLATION') THEN

			SELECT RSH.APPROVAL_STATUS
			INTO	l_header_approval_status
			FROM	RCV_SHIPMENT_HEADERS RSH
			WHERE	RSH.SHIPMENT_HEADER_ID = p_wc_id;

			IF(l_header_approval_status is null) THEN

				x_wc_status := 'PENDING APPROVAL';
				x_wc_display_status :=
					fnd_message_cache.get_string('POS', 'POS_WC_STATUS_PENDING_APPROVAL');

			ELSIF(l_header_approval_status = 'APPROVED') THEN

			  --Get number of shipment lines
				SELECT count(*) into l_wc_total_lines
				FROM RCV_SHIPMENT_LINES
				WHERE SHIPMENT_HEADER_ID = p_wc_id;

				--Get number of the shipment lines that have been processed
				SELECT count(*) into l_wc_lines_processed
				FROM RCV_TRANSACTIONS
				WHERE TRANSACTION_TYPE = 'DELIVER' AND
							SHIPMENT_HEADER_ID = p_wc_id;

				--Get number of the shipment lines that have been errored out
				SELECT count(*) into l_wc_lines_errored
				FROM	RCV_TRANSACTIONS_INTERFACE RTI,
							RCV_SHIPMENT_HEADERS RSH,
							RCV_SHIPMENT_LINES RSL
				WHERE RTI.SHIPMENT_LINE_ID = RSL.SHIPMENT_LINE_ID AND
							RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID AND
							RTI.PROCESSING_STATUS_CODE in ('ERROR','COMPLETED') AND
							RTI.TRANSACTION_STATUS_CODE = 'ERROR' AND
							RSH.SHIPMENT_HEADER_ID = p_wc_id;

        -- adding code for bug 9414650 - work confirmation correction ER
        -- check for correction on the given work confirmation
        SELECT Count(*) INTO l_wc_lines_corrected
        FROM rcv_transactions
        WHERE transaction_type = 'CORRECT' AND
              shipment_header_id = p_wc_id;


        LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_status',
					'Number of correction transactions: '||l_wc_lines_corrected);

        -- end of coded added for wc correction ER
				LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_status',
					'Number of Shipment lines: '||l_wc_total_lines);
				LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_status',
					'Number of processed Shipment Lines: '||l_wc_lines_processed);
				LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_status',
					'Number of errored Shipment Lines: '||l_wc_lines_errored);

        IF(l_wc_lines_processed = 0 and l_wc_lines_errored = 0) THEN

          IF(l_wc_lines_corrected > 0) THEN
            x_wc_status := 'CORRECTED';
            x_wc_display_status :=
                fnd_message_cache.get_string('POS', 'POS_WC_STATUS_CORRECTED');
          ELSE
            x_wc_status := 'APPROVED';
            x_wc_display_status :=
                fnd_message_cache.get_string('POS', 'POS_WC_STATUS_APPROVED');
          END IF;
/*
-- moving this code block into the ELSE condition - bug 5452504
-- l_wc_lines_processed is equal to the number of distributions,
-- l_wc_total_lines is same as number of shipments, and need not be equal when multiple distributions
        ELSIF(l_wc_total_lines = l_wc_lines_processed) THEN
          x_wc_status := 'PROCESSED';
          x_wc_display_status :=
            fnd_message_cache.get_string('POS', 'POS_WC_STATUS_PROCESSED');
*/
        ELSIF(l_wc_lines_errored > 0) THEN
          x_wc_status := 'PROCESSING_ERROR';
          x_wc_display_status :=
            fnd_message_cache.get_string('POS', 'POS_WC_STATUS_PROCESS_ERROR');
        ELSE

          IF(l_wc_lines_corrected > 0) THEN
            x_wc_status := 'CORRECTED';
            x_wc_display_status :=
                fnd_message_cache.get_string('POS', 'POS_WC_STATUS_CORRECTED');
          ELSE
            x_wc_status := 'PROCESSED';
            x_wc_display_status :=
                fnd_message_cache.get_string('POS', 'POS_WC_STATUS_PROCESSED');
          END IF;

        END IF;


			ELSIF(l_header_approval_status = 'REJECTED') THEN

				x_wc_status := 'REJECTED';
				x_wc_display_status :=
				fnd_message_cache.get_string('POS', 'POS_WC_STATUS_REJECTED');

			END IF;

		ELSE

			IF(l_cancellation_status = 'CANCELED') THEN

				x_wc_status := 'SHIPMENT CANCELED';
				x_wc_display_status :=
					fnd_message_cache.get_string('POS', 'POS_WC_STATUS_CANCELED');

			ELSIF(l_cancellation_status = 'PENDING CANCEL') THEN

				x_wc_status := 'PENDING CANCEL';
				x_wc_display_status :=
					fnd_message_cache.get_string('POS', 'POS_WC_STATUS_PENDING_CANCEL');

			ELSIF(l_cancellation_status = 'PARTIALLY CANCELED') THEN

				x_wc_status := 'PARTIALLY CANCELED';
				x_wc_display_status :=
					fnd_message_cache.get_string('POS', 'POS_WC_STATUS_PARTIALLY_CANCEL');
			END IF;

		END IF;

	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_wc_status',
				'Unexpected error occurred');

END GET_WC_STATUS;


-----------------------------------------------------------------------------
--API name  :   GET_WC_CANCELLATION_STATUS
--TYPE      :   PRIVATE
--Function  :   To retrieve the cancellation status of a WC
--Parameter :
--IN        :     p_wc_id              IN  VARCHAR2  Required
--                      corresponds to the column SHIPMENT_NUM in
--                      the table RCV_HEADERS_INTERFACE.
--OUT       :						 							 OUT VARCHAR2    Required
--                      returns the cancellation status of the WC
-----------------------------------------------------------------------------

FUNCTION GET_WC_CANCELLATION_STATUS ( p_wc_id  NUMBER)
RETURN VARCHAR2 IS

   x_total_lines  NUMBER := 0;
   x_cancelled_lines  NUMBER := 0;
   x_pending_cancel NUMBER := 0;

BEGIN

   /* Get total number of lines */
   select count(*)
     into x_total_lines
     from RCV_SHIPMENT_LINES rsl,
          RCV_SHIPMENT_HEADERS rsh
    where rsh.shipment_header_id= p_wc_id
      and rsh.shipment_header_id = rsl.shipment_header_id;

   if (x_total_lines = 0) then
      return '';
   end if;

   /* Get total number of cancelled lines */
   select count(*)
     into x_cancelled_lines
     from RCV_SHIPMENT_LINES rsl,
          RCV_SHIPMENT_HEADERS rsh
    where rsh.shipment_header_id = p_wc_id
      and rsh.shipment_header_id = rsl.shipment_header_id
      and rsl.shipment_line_status_code = 'CANCELLED';

   /* Get total number of lines pending cancellation */
   select count(*)
     into x_pending_cancel
     from RCV_TRANSACTIONS_INTERFACE rti,
          RCV_SHIPMENT_HEADERS rsh
    where rti.transaction_type = 'CANCEL'
      and rti.shipment_header_id = rsh.shipment_header_id
      and rsh.shipment_header_id = p_wc_id;

   LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_cancellation_status',
			 'Total Number of lines: '||x_total_lines);
   LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_cancellation_status',
			'Total Number of canceled lines: '||x_cancelled_lines);
   LOG(FND_LOG.LEVEL_PROCEDURE,'get_wc_cancellation_status',
			'Total Number of lines pending cancelation: '||x_pending_cancel);

   if (x_total_lines = x_cancelled_lines) then
      return 'CANCELED';
   elsif (x_total_lines = x_cancelled_lines + x_pending_cancel) then
      return 'PENDING CANCEL';
   elsif ((x_total_lines > x_cancelled_lines + x_pending_cancel)
          and (x_cancelled_lines + x_pending_cancel > 0)) then
      return 'PARTIALLY CANCELED';
   else
      return 'NO_CANCELLATION';
   end if;

   EXCEPTION
     WHEN OTHERS THEN
       LOG(FND_LOG.LEVEL_UNEXPECTED,'GET_WC_CANCELLATION_STATUS',
        'Unexpected error occurred');

END GET_WC_CANCELLATION_STATUS;


-----------------------------------------------------------------------------
--API name  :   CANCEL_WC
--TYPE      :   PUBLIC
--Function  :   Cancel a WC
--Parameter :
--IN				:			p_wc_num							IN	VARCHAR2	Required
--											corresponds to the column SHIPMENT_NUM in
--											the table RCV_HEADERS_INTERFACE.
--IN        :     p_wc_id               IN  NUMBER    Required
--                      corresponds to the column HEADER_INTERFACE_ID in
--                      the table RCV_HEADERS_INTERFACE.
--                p_wc_stage            IN  VARCHAR2    Required
--                      indicates if the information in the INTERFACE tables.
--                      or the SHIPMENT tables
--                p_po_header_id        IN  NUMBER    Required
--                      corresponds to the column PO_HEADER_ID in
--                      the table PO_HEADERS_ALL.
--OUT       :     x_return_status       OUT VARCHAR2
--                      return status of the procedure.
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure.
-----------------------------------------------------------------------------

PROCEDURE CANCEL_WC
(
	p_wc_num						IN					VARCHAR2,
  p_wc_id             IN          NUMBER,
  p_wc_status         IN          VARCHAR2,
  p_po_header_id      IN          NUMBER,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_return_msg        OUT NOCOPY  VARCHAR2
)

IS

	l_api_return_status		VARCHAR2(1);
	l_api_return_msg			VARCHAR2(1000);
	l_buyer_id						NUMBER;
	l_shipment_line_id		NUMBER;
	NOTIF_ERROR						EXCEPTION;
	CANCEL_PAY_ITEM_ERROR	EXCEPTION;

        l_wf_itemtype varchar2(8);
        l_wf_itemkey  Varchar2(280);

  cursor ship_header_cursor(p_header_id number) is
        select wf_item_type, wf_item_key
        from rcv_shipment_headers
        where shipment_header_id = p_header_id;

  CURSOR l_wc_pay_item_csr IS
     SELECT  rsl.shipment_line_id
       FROM  RCV_SHIPMENT_LINES rsl,
             RCV_SHIPMENT_HEADERS rsh
      WHERE  rsh.SHIPMENT_HEADER_ID = p_wc_id
        AND  rsh.shipment_header_id = rsl.shipment_header_id;

BEGIN


--		Business rule dictates that only the following WC statuses can
--		be cancelled:
--
--		1)Processing				(interface)
--		2)Rejected					(shipment)
--		3)Pending Approval	(shipment)


--		For 'Processing' WC, RHI.PROCESSING_STATUS_CODE and
--		RTI.PROCESSING_STATUS_CODE will be populated with 'CANCELLED'

--		Should put business logic here to make sure we can cancel the WC

	IF(p_wc_status = 'PROCESSING') THEN

		UPDATE RCV_TRANSACTIONS_INTERFACE
		SET		 PROCESSING_STATUS_CODE = 'CANCELLED'
		WHERE	 HEADER_INTERFACE_ID = p_wc_id;


		UPDATE RCV_HEADERS_INTERFACE
		SET		 PROCESSING_STATUS_CODE = 'CANCELLED'
		WHERE	 HEADER_INTERFACE_ID = p_wc_id;



	END IF;


--		For 'Pending Approval' and 'Rejected' WC, a new RTI will be created
--    for every RSL line to be cancelled. The status of the WC will be
--    shown as 'PENDING CANCEL' until the WC is processed by the RTP.
--		At the point, the WC will be shown as 'CANCELLED'

  IF(p_wc_status = 'REJECTED' OR  p_wc_status = 'PENDING APPROVAL') THEN

		OPEN l_wc_pay_item_csr;
		LOOP
			FETCH l_wc_pay_item_csr INTO l_shipment_line_id;
			EXIT WHEN l_wc_pay_item_csr%NOTFOUND;
				CANCEL_WC_PAY_ITEM(l_shipment_line_id,
													 l_api_return_status,
													 l_api_return_msg);
				IF(l_api_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
					RAISE CANCEL_PAY_ITEM_ERROR;
				END IF;
		END LOOP;
		CLOSE l_wc_pay_item_csr;

		--Cancellation Notification to the Buyer

		--First get buyer id from PO Header
		SELECT	POH.AGENT_ID
		INTO		l_buyer_id
		FROM		PO_HEADERS_ALL POH
		WHERE		POH.PO_HEADER_ID = p_po_header_id;

		--Debug Information
		LOG(FND_LOG.LEVEL_PROCEDURE,'cancel_wc','Cancellation Notif parameters:');
		LOG(FND_LOG.LEVEL_PROCEDURE,'cancel_wc','WC Num:'||p_wc_num);
		LOG(FND_LOG.LEVEL_PROCEDURE,'cancel_wc','WC ID:'||p_wc_id);
		LOG(FND_LOG.LEVEL_PROCEDURE,'cancel_wc','WC Status:'||p_wc_status);
		LOG(FND_LOG.LEVEL_PROCEDURE,'cancel_wc','PO Header ID:'||p_po_header_id);
		LOG(FND_LOG.LEVEL_PROCEDURE,'cancel_wc','Buyer ID:'||l_buyer_id);
		LOG(FND_LOG.LEVEL_PROCEDURE,'cancel_wc','User ID:'||fnd_global.user_id);

                --Close previous 'requires approval' notif sent to buyer
	        open ship_header_cursor(p_wc_id);
	        fetch ship_header_cursor into l_wf_itemtype, l_wf_itemkey;
	        close ship_header_cursor;

                /* Bug 7668094  - Start
		Complete Activity Throws Exception if the process is not open.
		Hence catched the exception to complete the normal flow.
                */
                LOG(FND_LOG.LEVEL_PROCEDURE,'cancel_wc','l_wf_itemtype:'||l_wf_itemtype);
                LOG(FND_LOG.LEVEL_PROCEDURE,'cancel_wc','l_wf_itemkey:'||l_wf_itemkey);
                BEGIN
                  WF_ENGINE.CompleteActivity(l_wf_itemtype, l_wf_itemkey,'WC_APPROVE', 'Cancel');
                EXCEPTION WHEN OTHERS THEN
                  LOG(FND_LOG.LEVEL_UNEXPECTED,'cancel_wc','Could Not Completing activity');
                END;
                -- Bug 7668094  - Start

		POS_ASN_NOTIF.GENERATE_WC_NOTIF
		(
			p_wc_num				  =>	p_wc_num,
			p_wc_id					  =>	p_wc_id,
			p_wc_status				=>  p_wc_status,
			p_po_header_id	  =>  p_po_header_id,
			p_buyer_id       	=>	l_buyer_id,
			p_user_id         =>	fnd_global.user_id,
			x_return_status		=>	l_api_return_status,
			x_return_msg			=>	l_api_return_msg
		);

		IF(l_api_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			RAISE NOTIF_ERROR;
		END IF;

	END IF;

	COMMIT;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

	WHEN CANCEL_PAY_ITEM_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'cancel_wc',
				'Unexpected error occurred when cancelling pay item');
	WHEN NOTIF_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'cancel_wc',
				'Unexpected error occurred when sending buyer a cancellation notification');
		LOG(FND_LOG.LEVEL_UNEXPECTED,'cancel_wc',
				'Error Message: '||l_api_return_msg);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'cancel_wc',
				'Unexpected error occurred');


END CANCEL_WC;


-----------------------------------------------------------------------------
--API name  :   CANCEL_WC_PAY_ITEM
--TYPE      :   PUBLIC
--Function  :   Cancel a WC Pay Item
--Parameter :
--IN        :     p_shipment_line_id    IN  NUMBER    Required
--                      corresponds to the column SHIPMENT_LINE_ID in
--                      the table RCV_SHIPMENT_LINES.
--OUT       :     x_return_status       OUT VARCHAR2
--                      return status of the procedure.
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure.
-----------------------------------------------------------------------------

PROCEDURE CANCEL_WC_PAY_ITEM
(
	p_shipment_line_id	IN		NUMBER,
	x_return_status			OUT		nocopy VARCHAR2,
	x_return_msg				OUT		nocopy VARCHAR2
)

IS

	l_group_id									NUMBER;
	l_row_id										VARCHAR2(200);
	l_interface_transaction_id	NUMBER;

	l_po_header_id						NUMBER;
	l_po_release_id						NUMBER;
	l_po_line_id							NUMBER;
	l_shipment_header_id			NUMBER;
	l_po_line_location_id			NUMBER;
	l_deliver_to_location_id	NUMBER;
	l_to_organization_id			NUMBER;
	l_item_id									NUMBER;
	l_quantity_shipped				NUMBER;
	l_source_document_code		VARCHAR2(25);
	l_category_id							NUMBER;
	l_unit_of_measure					VARCHAR2(25);
	l_item_description				VARCHAR2(240);
	l_employee_id							NUMBER;
	l_destination_type_code   VARCHAR2(25);
	l_destination_context     VARCHAR2(30);
	l_subinventory            VARCHAR2(10);
	l_routing_header_id       NUMBER;
	l_primary_unit_of_measure VARCHAR2(25);
	l_ship_to_location_id     NUMBER;
	l_vendor_id								NUMBER;
	l_org_id									NUMBER;  --for MOAC

	--WC parameters
	l_matching_basis					VARCHAR2(20);
	l_amount_shipped					NUMBER;
	l_requested_amount				NUMBER;
	l_material_stored_amount	NUMBER;

BEGIN

  SELECT rcv_interface_groups_s.nextval
  INTO   l_group_id
  FROM   dual;


	BEGIN
		SELECT
			RSL.PO_HEADER_ID,
			RSL.PO_RELEASE_ID,
			RSL.PO_LINE_ID,
			RSL.SHIPMENT_HEADER_ID,
			RSL.PO_LINE_LOCATION_ID,
			RSL.DELIVER_TO_LOCATION_ID,
			RSL.TO_ORGANIZATION_ID,
			RSL.ITEM_ID,
			RSL.QUANTITY_SHIPPED,
			RSL.SOURCE_DOCUMENT_CODE,
			RSL.CATEGORY_ID,
			RSL.UNIT_OF_MEASURE,
			RSL.ITEM_DESCRIPTION,
			RSL.EMPLOYEE_ID,
			RSL.DESTINATION_TYPE_CODE,
			RSL.DESTINATION_CONTEXT,
			RSL.TO_SUBINVENTORY,
			RSL.ROUTING_HEADER_ID,
			RSL.PRIMARY_UNIT_OF_MEASURE,
			RSL.SHIP_TO_LOCATION_ID,

			RSL.AMOUNT_SHIPPED,
			RSL.REQUESTED_AMOUNT,
			RSL.MATERIAL_STORED_AMOUNT,
			POLL.MATCHING_BASIS,
			POLL.ORG_ID
		INTO
			l_po_header_id,
			l_po_release_id,
			l_po_line_id,
			l_shipment_header_id,
			l_po_line_location_id,
			l_deliver_to_location_id,
			l_to_organization_id,
			l_item_id,
			l_quantity_shipped,
			l_source_document_code,
			l_category_id,
			l_unit_of_measure,
			l_item_description,
			l_employee_id,
			l_destination_type_code,
			l_destination_context,
			l_subinventory,
			l_routing_header_id,
			l_primary_unit_of_measure,
			l_ship_to_location_id,
			l_amount_shipped,
			l_requested_amount,
			l_material_stored_amount,
			l_matching_basis,
			l_org_id
		FROM
			RCV_SHIPMENT_LINES RSL,
			PO_LINE_LOCATIONS_ALL POLL
		WHERE
			RSL.shipment_line_id = p_shipment_line_id AND
			RSL.po_line_location_id = POLL.line_location_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
      x_return_msg		:= 'NO_DATA_FOUND error in CANCEL_WC_PAY_ITEM query,'||
												 'shipment_line_id =' || p_shipment_line_id;
			RAISE;
	END;

	RCV_ASN_INTERFACE_TRX_INS_PKG.INSERT_ROW(
			x_group_id => l_group_id,
		x_transaction_type => 'CANCEL',
		x_transaction_date => sysdate,
		x_processing_status_code => 'PENDING',
		x_processing_mode_code => 'BATCH',
		x_transaction_status_code => 'PENDING',
		x_last_update_date => SYSDATE,
		x_last_updated_by => 1,
		x_last_update_login => 1,
		x_interface_source_code =>'RCV',
		x_creation_date => SYSDATE,
		x_created_by => 1,
		x_auto_transact_code => 'CANCEL',
		x_receipt_source_code => 'VENDOR',

		-- Parameters whose values should be retrieved from the shipment table
		X_po_header_id           => l_po_header_id,
		X_po_release_id          => l_po_release_id,
		X_po_line_id             => l_po_line_id,
		X_shipment_line_id       => p_shipment_line_id,
		X_shipment_header_id     => l_shipment_header_id,
		X_po_line_location_id    => l_po_line_location_id,
		X_deliver_to_location_id => l_deliver_to_location_id,
		X_to_organization_id     => l_to_organization_id,
		X_item_id                => null, -- l_item_id,
		X_quantity_shipped       => l_quantity_shipped,
		X_source_document_code   => l_source_document_code,
		X_category_id            => l_category_id,
		X_unit_of_measure        => l_unit_of_measure,
		X_item_description       => l_item_description,
		X_employee_id            => l_employee_id,
		X_destination_type_code  => l_destination_type_code,
		X_destination_context    => l_destination_context,
		X_subinventory           => l_subinventory,
		X_routing_header_id      => l_routing_header_id,
		X_primary_unit_of_measure=> l_primary_unit_of_measure,
		X_ship_to_location_id    => l_ship_to_location_id,
		X_vendor_id              => l_vendor_id,

		-- Added the following new columns for complex work
		P_MATCHING_BASIS      => l_matching_basis,
		P_AMOUNT_SHIPPED      => l_amount_shipped,
		P_REQUESTED_AMOUNT    => l_requested_amount,
		P_MATERIAL_STORED_AMOUNT   => l_material_stored_amount,
		P_ORG_ID							=> l_org_id,

		-- Rest of the required parameters from API. Pass in null for all of them
		X_ROWID                           => l_row_id,
		X_INTERFACE_TRANSACTION_ID        => l_interface_transaction_id,
		X_REQUEST_ID                      => null,
		X_PROGRAM_APPLICATION_ID          => null,
		X_PROGRAM_ID                      => null,
		X_PROGRAM_UPDATE_DATE             => null,
		X_PROCESSING_REQUEST_ID           => null,
		X_QUANTITY                        => null,
		X_INTERFACE_SOURCE_LINE_ID        => null,
		X_INV_TRANSACTION_ID              => null,
		X_ITEM_REVISION                   => null,
		X_UOM_CODE                        => null,
		X_PRIMARY_QUANTITY                => null,
		X_VENDOR_SITE_ID                  => null,
		X_FROM_ORGANIZATION_ID            => null,
		X_FROM_SUBINVENTORY               => null,
		X_INTRANSIT_OWNING_ORG_ID         => null,
		X_ROUTING_STEP_ID                 => null,
		X_PARENT_TRANSACTION_ID           => null,
		X_PO_REVISION_NUM                 => null,
		X_PO_UNIT_PRICE                   => null,
		X_CURRENCY_CODE                   => null,
		X_CURRENCY_CONVERSION_TYPE        => null,
		X_CURRENCY_CONVERSION_RATE        => null,
		X_CURRENCY_CONVERSION_DATE        => null,
		X_PO_DISTRIBUTION_ID              => null,
		X_REQUISITION_LINE_ID             => null,
		X_REQ_DISTRIBUTION_ID             => null,
		X_CHARGE_ACCOUNT_ID               => null,
		X_SUBSTITUTE_UNORDERED_CODE       => null,
		X_RECEIPT_EXCEPTION_FLAG          => null,
		X_ACCRUAL_STATUS_CODE             => null,
		X_INSPECTION_STATUS_CODE          => null,
		X_INSPECTION_QUALITY_CODE         => null,
		X_DELIVER_TO_PERSON_ID            => null,
		X_LOCATION_ID                     => null,
		X_LOCATOR_ID                      => null,
		X_WIP_ENTITY_ID                   => null,
		X_WIP_LINE_ID                     => null,
		X_DEPARTMENT_CODE                 => null,
		X_WIP_REPETITIVE_SCHEDULE_ID      => null,
		X_WIP_OPERATION_SEQ_NUM           => null,
		X_WIP_RESOURCE_SEQ_NUM            => null,
		X_BOM_RESOURCE_ID                 => null,
		X_SHIPMENT_NUM                    => null,
		X_FREIGHT_CARRIER_CODE            => null,
		X_BILL_OF_LADING                  => null,
		X_PACKING_SLIP                    => null,
		X_SHIPPED_DATE                    => null,
		X_EXPECTED_RECEIPT_DATE           => null,
		X_ACTUAL_COST                     => null,
		X_TRANSFER_COST                   => null,
		X_TRANSPORTATION_COST             => null,
		X_TRANSPORTATION_ACCOUNT_ID       => null,
		X_NUM_OF_CONTAINERS               => null,
		X_WAYBILL_AIRBILL_NUM             => null,
		X_VENDOR_ITEM_NUM                 => null,
		X_VENDOR_LOT_NUM                  => null,
		X_RMA_REFERENCE                   => null,
		X_COMMENTS                        => null,
		X_ATTRIBUTE_CATEGORY              => null,
		X_ATTRIBUTE1                      => null,
		X_ATTRIBUTE2                      => null,
		X_ATTRIBUTE3                      => null,
		X_ATTRIBUTE4                      => null,
		X_ATTRIBUTE5                      => null,
		X_ATTRIBUTE6                      => null,
		X_ATTRIBUTE7                      => null,
		X_ATTRIBUTE8                      => null,
		X_ATTRIBUTE9                      => null,
		X_ATTRIBUTE10                     => null,
		X_ATTRIBUTE11                     => null,
		X_ATTRIBUTE12                     => null,
		X_ATTRIBUTE13                     => null,
		X_ATTRIBUTE14                     => null,
		X_ATTRIBUTE15                     => null,
		X_SHIP_HEAD_ATTRIBUTE_CATEGORY    => null,
		X_SHIP_HEAD_ATTRIBUTE1            => null,
		X_SHIP_HEAD_ATTRIBUTE2            => null,
		X_SHIP_HEAD_ATTRIBUTE3            => null,
		X_SHIP_HEAD_ATTRIBUTE4            => null,
		X_SHIP_HEAD_ATTRIBUTE5            => null,
		X_SHIP_HEAD_ATTRIBUTE6            => null,
		X_SHIP_HEAD_ATTRIBUTE7            => null,
		X_SHIP_HEAD_ATTRIBUTE8            => null,
		X_SHIP_HEAD_ATTRIBUTE9            => null,
		X_SHIP_HEAD_ATTRIBUTE10           => null,
		X_SHIP_HEAD_ATTRIBUTE11           => null,
		X_SHIP_HEAD_ATTRIBUTE12           => null,
		X_SHIP_HEAD_ATTRIBUTE13           => null,
		X_SHIP_HEAD_ATTRIBUTE14           => null,
		X_SHIP_HEAD_ATTRIBUTE15           => null,
		X_SHIP_LINE_ATTRIBUTE_CATEGORY    => null,
		X_SHIP_LINE_ATTRIBUTE1            => null,
		X_SHIP_LINE_ATTRIBUTE2            => null,
		X_SHIP_LINE_ATTRIBUTE3            => null,
		X_SHIP_LINE_ATTRIBUTE4            => null,
		X_SHIP_LINE_ATTRIBUTE5            => null,
		X_SHIP_LINE_ATTRIBUTE6            => null,
		X_SHIP_LINE_ATTRIBUTE7            => null,
	 X_SHIP_LINE_ATTRIBUTE8            => null,
	 X_SHIP_LINE_ATTRIBUTE9            => null,
	 X_SHIP_LINE_ATTRIBUTE10           => null,
	 X_SHIP_LINE_ATTRIBUTE11           => null,
	 X_SHIP_LINE_ATTRIBUTE12           => null,
	 X_SHIP_LINE_ATTRIBUTE13           => null,
	 X_SHIP_LINE_ATTRIBUTE14           => null,
	 X_SHIP_LINE_ATTRIBUTE15           => null,
	 X_USSGL_TRANSACTION_CODE          => null,
	 X_GOVERNMENT_CONTEXT              => null,
	 X_REASON_ID                       => null,
	 X_SOURCE_DOC_QUANTITY             => null,
	 X_SOURCE_DOC_UNIT_OF_MEASURE      => null,
	 X_MOVEMENT_ID                     => null,
	 X_HEADER_INTERFACE_ID             => null,
	 X_VENDOR_CUM_SHIPPED_QTY          => null,
	 X_ITEM_NUM                        => null,
	 X_DOCUMENT_NUM                    => null,
	 X_DOCUMENT_LINE_NUM               => null,
	 X_TRUCK_NUM                       => null,
	 X_SHIP_TO_LOCATION_CODE           => null,
	 X_CONTAINER_NUM                   => null,
	 X_SUBSTITUTE_ITEM_NUM             => null,
	 X_NOTICE_UNIT_PRICE               => null,
	 X_ITEM_CATEGORY                   => null,
	 X_LOCATION_CODE                   => null,
	 X_VENDOR_NAME                     => null,
	 X_VENDOR_NUM                      => null,
	 X_VENDOR_SITE_CODE                => null,
	 X_FROM_ORGANIZATION_CODE          => null,
	 X_TO_ORGANIZATION_CODE            => null,
	 X_INTRANSIT_OWNING_ORG_CODE       => null,
	 X_ROUTING_CODE                    => null,
	 X_ROUTING_STEP                    => null,
	 X_RELEASE_NUM                     => null,
	 X_DOCUMENT_SHIPMENT_LINE_NUM      => null,
	 X_DOCUMENT_DISTRIBUTION_NUM       => null,
	 X_DELIVER_TO_PERSON_NAME          => null,
	 X_DELIVER_TO_LOCATION_CODE        => null,
	 X_USE_MTL_LOT                     => null,
	 X_USE_MTL_SERIAL                  => null,
	 X_LOCATOR                         => null,
	 X_REASON_NAME                     => null,
	 X_VALIDATION_FLAG                 => null,
	 X_SUBSTITUTE_ITEM_ID              => null,
	 X_QUANTITY_INVOICED               => null,
	 X_TAX_NAME                        => null,
	 X_TAX_AMOUNT                      => null,
	 X_REQ_NUM                         => null,
	 X_REQ_LINE_NUM                    => null,
	 X_REQ_DISTRIBUTION_NUM            => null,
	 X_WIP_ENTITY_NAME                 => null,
	 X_WIP_LINE_CODE                   => null,
	 X_RESOURCE_CODE                   => null,
	 X_SHIPMENT_LINE_STATUS_CODE       => null,
	 X_BARCODE_LABEL                   => null,
	 X_COUNTRY_OF_ORIGIN_CODE          => null,
	 X_FROM_LOCATOR_ID                 => null,
	 X_QA_COLLECTION_ID                => null,
	 X_OE_ORDER_HEADER_ID              => null,
	 X_OE_ORDER_LINE_ID                => null,
	 X_CUSTOMER_ID                     => null,
	 X_CUSTOMER_SITE_ID                => null,
	 X_CUSTOMER_ITEM_NUM               => null,
	 X_CREATE_DEBIT_MEMO_FLAG          => null,
	 X_PUT_AWAY_RULE_ID                => null,
	 X_PUT_AWAY_STRATEGY_ID            => null,
	 X_LPN_ID                          => null,
	 X_TRANSFER_LPN_ID                 => null,
	 X_COST_GROUP_ID                   => null,
	 X_MOBILE_TXN                      => null,
	 X_MMTT_TEMP_ID                    => null,
	 X_TRANSFER_COST_GROUP_ID          => null,
	 X_SECONDARY_QUANTITY              => null,
	 X_SECONDARY_UNIT_OF_MEASURE       => null,
	 X_SECONDARY_UOM_CODE              => null,
	 X_QC_GRADE                        => null,
	 X_OE_ORDER_NUM                    => null,
	 X_OE_ORDER_LINE_NUM               => null,
	 X_CUSTOMER_ACCOUNT_NUMBER         => null,
	 X_CUSTOMER_PARTY_NAME             => null,
	 X_SOURCE_TRANSACTION_NUM          => null,
	 X_PARENT_SOURCE_TXN_NUM           => null,
	 X_PARENT_INTERFACE_TXN_ID         => null,
	 X_CUSTOMER_ITEM_ID                => null,
	 X_INTERFACE_AVAIL_QTY             => null,
	 X_INTERFACE_TRANS_QTY             => null,
	 X_FROM_LOCATOR                    => null,
	 X_LPN_GROUP_ID                    => null,
	 X_ORDER_TRANSACTION_ID						 => null,
	 X_LICENSE_PLATE_NUMBER            => null,
	 X_TFR_LICENSE_PLATE_NUMBER				 => null,
	 X_AMOUNT													 => null,
	 X_JOB_ID													 => null,
	 X_PROJECT_ID											 => null,
	 X_TASK_ID												 => null,
	 X_ASN_ATTACH_ID									 => null,
	 X_TIMECARD_ID										 => null,
	 X_TIMECARD_OVN										 => null,
	 X_INTERFACE_AVAIL_AMT						 => null,
	 X_INTERFACE_TRANS_AMT						 => null);

	 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	WHEN OTHERS then null;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

-----------------------------------------------------------------------------
--API name  :   DELETE_WC
--TYPE      :   PUBLIC
--Function  :   Delete a WC
--Parameter :
--IN        :     p_wc_id               IN  NUMBER    Required
--                      corresponds to the column HEADER_INTERFACE_ID in
--                      the table RCV_HEADERS_INTERFACE.
--OUT       :     x_return_status       OUT VARCHAR2
--                      return status of the procedure.
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure.
-----------------------------------------------------------------------------

PROCEDURE	DELETE_WC
(
p_wc_id						IN			NUMBER,
x_return_status		OUT			nocopy VARCHAR2,
x_return_msg			OUT			nocopy VARCHAR2
)

IS

l_header_interface_id       NUMBER;
l_wc_attach_id              NUMBER;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2400);

CURSOR l_header_interface_csr
IS
SELECT HEADER_INTERFACE_ID
FROM RCV_HEADERS_INTERFACE
WHERE HEADER_INTERFACE_ID =  p_wc_id;


--Before removing the WC from the interface tables,
--the associated attachments will be first removed.

CURSOR l_wc_attach_csr (l_header_intf_id NUMBER)
IS
SELECT DISTINCT RTI.ASN_ATTACH_ID
FROM RCV_TRANSACTIONS_INTERFACE RTI,
		 FND_ATTACHED_DOCUMENTS FAD
WHERE RTI.HEADER_INTERFACE_ID = L_HEADER_INTF_ID
			AND RTI.ASN_ATTACH_ID IS NOT NULL
			AND TO_CHAR(RTI.ASN_ATTACH_ID) = FAD.PK1_VALUE
			AND FAD.ENTITY_NAME = 'ASN_ATTACH';

BEGIN

OPEN l_header_interface_csr;
	LOOP
		FETCH l_header_interface_csr INTO l_header_interface_id;
		EXIT WHEN l_header_interface_csr%NOTFOUND;

		IF(l_header_interface_id is not null) THEN

			/* Delete WC attachment if exists. */
			OPEN l_wc_attach_csr (l_header_interface_id);
			LOOP
				FETCH l_wc_attach_csr INTO l_wc_attach_id;
				EXIT WHEN l_wc_attach_csr%NOTFOUND;

				IF (l_wc_attach_id IS NOT NULL) THEN

					RCV_ASN_ATTACHMENT_PKG.DELETE_LINE_ATTACHMENT
					(
							p_api_version   => 1.0,
							p_init_msg_list => 'F',
							x_return_status => l_return_status,
							x_msg_count     => l_msg_count,
							x_msg_data      => l_msg_data,
							p_asn_attach_id => l_wc_attach_id
					);

				END IF;

			END LOOP;
			CLOSE l_wc_attach_csr;

			/* Delete WC line from interface table. */
			DELETE FROM RCV_TRANSACTIONS_INTERFACE
			WHERE header_interface_id = l_header_interface_id;

		END IF;

	END LOOP;
CLOSE l_header_interface_csr;

-- Delete records in header interface table.
DELETE  FROM RCV_HEADERS_INTERFACE
WHERE header_interface_id = l_header_interface_id;

COMMIT;
x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

WHEN OTHERS THEN
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
LOG(FND_LOG.LEVEL_UNEXPECTED,'delete_wc',
		'Unexpected error occurred');

END DELETE_WC;


-----------------------------------------------------------------------------
--API name  :   DELETE_WC
--TYPE      :   PUBLIC
--Function  :   To retrieve future approvers that have not taken action on
--              a WC yet.
--Parameter :
--IN        :     p_wc_id               IN  NUMBER    Required
--                      corresponds to the column HEADER_INTERFACE_ID in
--                      the table RCV_HEADERS_INTERFACE.
--OUT       :     x_approvers           OUT PO_TBL_VARCHAR2000
--											return all "future" approvers
--								x_return_status       OUT VARCHAR2
--                      return status of the procedure.
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure.
-----------------------------------------------------------------------------


PROCEDURE GET_WC_APPROVERS
(
  p_wc_id             IN  NUMBER,
  x_approvers         OUT nocopy PO_TBL_VARCHAR2000,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
)

IS

l_approvers           ame_util.approversTable2;
l_completeYNO         varchar2(100);
l_num_approvers       number;

BEGIN

	x_approvers := PO_TBL_VARCHAR2000();


	ame_api2.getAllApprovers7(
    applicationIdIn => 201,
    transactionTypeIn => 'WCAPPRV',
    transactionIdIn => p_wc_id,
    approvalProcessCompleteYNOut => l_completeYNO,
    approversOut => l_approvers);

	l_num_approvers := l_approvers.count;

	--Only retrieves the "future" approvers
	IF (l_completeYNO <> 'Y') THEN
    FOR l_count IN 1 .. l_num_approvers LOOP

      IF(l_approvers(l_count).approval_status is null) THEN

        x_approvers.extend;
        x_approvers(x_approvers.count) := l_approvers(l_count).display_name;

      END IF;

    END LOOP;
  END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_wc_approvers',
			'Unexpected error occurred');

END GET_WC_APPROVERS;

FUNCTION GET_CURRENCY_PRECISION(p_po_header_id IN NUMBER)
RETURN NUMBER
IS
p_precision NUMBER;
BEGIN
SELECT fc.precision
INTO p_precision
FROM FND_CURRENCIES fc,
PO_HEADERS_ALL poh
WHERE poh.po_header_id=p_po_header_id
AND poh.currency_code= fc.currency_code;
RETURN p_precision;
EXCEPTION
WHEN OTHERS
THEN
p_precision:=0;
RETURN p_precision;
END GET_CURRENCY_PRECISION;

END POS_WC_VIEW_CANCEL_PVT;

/
