--------------------------------------------------------
--  DDL for Package Body POS_WC_CREATE_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_WC_CREATE_UPDATE_PVT" AS
/* $Header: POSVWCCB.pls 120.4.12010000.10 2014/03/26 04:55:18 nchundur ship $*/
l_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE LOG
(
	p_level		IN NUMBER,
	p_api_name	IN VARCHAR2,
	p_msg		IN VARCHAR2
);

PROCEDURE	GET_PO_ORDERED
(
  p_po_header_id      IN		NUMBER,
  x_po_ordered        OUT nocopy	NUMBER,
  x_return_status     OUT nocopy	VARCHAR2,
  x_return_msg        OUT nocopy	VARCHAR2
);


PROCEDURE	GET_PO_APPROVED
(
  p_po_header_id	IN		NUMBER,
  x_po_approved       OUT nocopy	NUMBER,
  x_return_status     OUT nocopy	VARCHAR2,
  x_return_msg        OUT nocopy	VARCHAR2
);

--Private procedure for logging
PROCEDURE LOG
(
	p_level		IN NUMBER,
	p_api_name	IN VARCHAR2,
	p_msg		IN VARCHAR2
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
      l_module := 'pos.plsql.pos_wc_create_update_pvt.'||p_api_name;
      FND_LOG.string( LOG_LEVEL => p_level,
                      MODULE    => l_module,
                      MESSAGE   => p_msg);
    END IF;
  END IF;

END LOG;



-----------------------------------------------------------------------------
--API name	:		DRAFT_EXISTS_FOR_PO
-----------------------------------------------------------------------------
FUNCTION DRAFT_EXISTS_FOR_PO ( p_po_header_id			IN	NUMBER)
RETURN VARCHAR2

IS

l_draft_exists VARCHAR2(1);

BEGIN

		l_draft_exists := 'N';

    SELECT  'Y' INTO l_draft_exists
    FROM    RCV_HEADERS_INTERFACE RHI,
			RCV_TRANSACTIONS_INTERFACE RTI
    WHERE   RHI.HEADER_INTERFACE_ID = RTI.HEADER_INTERFACE_ID AND
			RTI.PO_HEADER_ID = p_po_header_id AND
			RHI.processing_status_code = 'DRAFT' AND
			RHI.transaction_type = 'DRAFT' AND
			ROWNUM = 1;

		return l_draft_exists;

EXCEPTION

		WHEN NO_DATA_FOUND THEN

			return 'N';

		WHEN OTHERS THEN
			LOG(FND_LOG.LEVEL_UNEXPECTED,'draft_exists_for_po',
        'Unexpected Error');

END DRAFT_EXISTS_FOR_PO;


-----------------------------------------------------------------------------
--API name	:		GET_PO_INFO
--TYPE			:		PUBLIC
--Function	:		Retrieve information related to a PO such as ordered amount
-- 					    and approved amount
--Parameter	:
--IN				:			p_po_header_id				IN	NUMBER		Required
--											corresponds to the columne PO_HEADER_ID in the table
--											PO_HEADERS_ALL, and identifies the PO for which the
--											information should be retrieved.
--
--OUT				:			x_ordered							OUT	NUMBER
--											total ordered amount for the PO
--								x_approved						OUT	NUMBER
--											total approved amount for the PO
--								x_return_status				OUT	VARCHAR2
--											return status of the procedure
--								x_return_msg					OUT	VARCHAR2
--											return message of the procedure
-----------------------------------------------------------------------------
PROCEDURE GET_PO_INFO
(
	p_po_header_id			IN  NUMBER,
	x_ordered						OUT nocopy NUMBER,
	x_approved					OUT nocopy NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
)

IS

l_progress						NUMBER;
l_api_return_status		VARCHAR2(1);
l_api_return_msg			VARCHAR2(1000);

BEGIN

	l_progress := 0;

	--We are writing these APIs for now. We might be
	--able to use APIs provided by the Complex Work PO Project later
	GET_PO_ORDERED
	(
		p_po_header_id			=> p_po_header_id,
		x_po_ordered        => x_ordered,
		x_return_status     => l_api_return_status,
		x_return_msg				=> l_api_return_msg
	);

	IF(l_api_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_progress := 1;

	GET_PO_APPROVED
	(
		p_po_header_id			=> p_po_header_id,
		x_po_approved       => x_approved,
		x_return_status     => l_api_return_status,
		x_return_msg        => l_api_return_msg
	);

	IF(l_api_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_msg := l_api_return_msg;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_po_info',
				'Expected error at stage: '|| l_progress);
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_po_ccinfo',
				'Error: '|| l_api_return_msg);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := 'Unexpected error at stage: '|| l_progress;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_po_info',
				'Unexpected error at stage: '|| l_progress);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := 'Unexpected error at stage: '|| l_progress;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'get_po_info',
				'Unexpected error at stage: '|| l_progress);

	x_return_status := FND_API.G_RET_STS_SUCCESS;

END;

-----------------------------------------------------------------------------
--API name	:		GET_PO_APPROVED
--TYPE			:		PRIVATE
--Function	:		Retrieve approved amount of a PO
--Parameter	:
--IN				:			p_po_header_id				IN	NUMBER		Required
--											corresponds to the columne PO_HEADER_ID in the table
--											PO_HEADERS_ALL, and identifies the PO for which the
--											information should be retrieved.
--
--OUT				:			x_approved						OUT	NUMBER
--											total approved amount for the PO
--								x_return_status				OUT	VARCHAR2
--											return status of the procedure
--								x_return_msg					OUT	VARCHAR2
--											return message of the procedure
-----------------------------------------------------------------------------
PROCEDURE	GET_PO_APPROVED
(
  p_po_header_id			IN	NUMBER,
  x_po_approved       OUT nocopy NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
)

IS

BEGIN

	SELECT
		SUM(NVL(RSL.AMOUNT, RSL.QUANTITY_SHIPPED*POLL.PRICE_OVERRIDE))
	INTO x_po_approved
	FROM RCV_SHIPMENT_HEADERS RSH,
			 RCV_SHIPMENT_LINES RSL,
	     PO_LINE_LOCATIONS_ALL POLL
	WHERE RSL.po_header_id = p_po_header_id
		AND RSL.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
		AND	RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID
		AND RSH.APPROVAL_STATUS = 'APPROVED'
		AND RSL.APPROVAL_STATUS in ('APPROVED');

	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    LOG(FND_LOG.LEVEL_UNEXPECTED,'get_po_approved',
      'Unexpected error occurred');
END;


-----------------------------------------------------------------------------
--API name	:		GET_PO_ORDERED
--TYPE			:		PRIVATE
--Function	:		Retrieve approved amount of a PO
--Parameter	:
--IN				:			p_po_header_id				IN	NUMBER		Required
--											corresponds to the columne PO_HEADER_ID in the table
--											PO_HEADERS_ALL, and identifies the PO for which the
--											information should be retrieved.
--
--OUT				:			x_ordered						OUT	NUMBER
--											total ordered amount for the PO
--								x_return_status				OUT	VARCHAR2
--											return status of the procedure
--								x_return_msg					OUT	VARCHAR2
--											return message of the procedure
-----------------------------------------------------------------------------
PROCEDURE	GET_PO_ORDERED
(
  p_po_header_id			IN	NUMBER,
  x_po_ordered        OUT nocopy NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
)

IS

l_po_ordered			NUMBER;

BEGIN

  --This should be the logic???
	SELECT	SUM(
						NVL((POLL.QUANTITY - NVL(POLL.QUANTITY_CANCELLED,0))
                *POLL.PRICE_OVERRIDE,
						(POLL.AMOUNT - NVL(POLL.AMOUNT_CANCELLED,0))))
	INTO l_po_ordered
	FROM PO_LINE_LOCATIONS_ALL POLL
	WHERE POLL.PO_HEADER_ID = p_po_header_id;

  x_po_ordered := l_po_ordered;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    LOG(FND_LOG.LEVEL_UNEXPECTED,'get_po_ordered',
      'Unexpected error occurred');

END GET_PO_ORDERED;


FUNCTION GET_WC_TOTAL_REQUESTED (p_wc_id       IN NUMBER,
																 p_wc_stage		 IN VARCHAR2)
RETURN NUMBER
IS

l_intf_request		NUMBER;
l_ship_request		NUMBER;

BEGIN

	IF(p_wc_stage = 'INTERFACE') THEN

		SELECT SUM(NVL(RTI.AMOUNT, Round(RTI.QUANTITY*POLL.PRICE_OVERRIDE,POS_WC_VIEW_CANCEL_PVT.get_currency_precision(poll.po_header_id))))
		INTO l_intf_request
		FROM	RCV_TRANSACTIONS_INTERFACE RTI,
					RCV_HEADERS_INTERFACE RHI,
					PO_LINE_LOCATIONS_ALL POLL
		WHERE RHI.HEADER_INTERFACE_ID = RTI.HEADER_INTERFACE_ID and
					RTI.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
					RHI.HEADER_INTERFACE_ID = p_wc_id;

  ELSIF(p_wc_stage = 'SHIPMENT') THEN

		SELECT SUM(NVL(RSL.AMOUNT_SHIPPED, Round(RSL.QUANTITY_SHIPPED*POLL.PRICE_OVERRIDE,POS_WC_VIEW_CANCEL_PVT.get_currency_precision(poll.po_header_id))))
		INTO l_ship_request
		FROM	RCV_SHIPMENT_LINES RSL,
					RCV_SHIPMENT_HEADERS RSH,
					PO_LINE_LOCATIONS_ALL POLL
		WHERE RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID AND
					RSL.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
					RSH.SHIPMENT_HEADER_ID = p_wc_id;
	END IF;

  IF(l_intf_request is null) THEN
    l_intf_request := 0;
  END IF;

  IF(l_ship_request is null) THEN
    l_ship_request := 0;
  END IF;

	return l_intf_request + l_ship_request;


EXCEPTION

  WHEN OTHERS THEN
    LOG(FND_LOG.LEVEL_UNEXPECTED,'get_wc_total_requested',
      'Unexpected error occurred');

END GET_WC_TOTAL_REQUESTED;

-----------------------------------------------------------------------------
--API name  :   GET_PAY_ITEM_PROGRESS
--TYPE      :   PUBLIC
--Function  :   Retrieve the progress on a pay item
--Parameter :
--IN        :     p_wc_pay_item_id        IN  NUMBER    Required
--                      corresponds to the column TRANSACTION_INTERFACE_ID or
--											SHIPMENT_LINE_ID in the table RCV_TRANSACTIONS_INTERFACE--											or RCV_SHIPMENT_LINES respectively, depending on the
--											p_wc_stage variable. The API is only implemented for
--											pay items in 'SHIPMENT' stage at the moment.
--								p_wc_stage							IN	VARCHAR2	Required
--											'INTERFACE' or 'SHIPMENT. Indicates the pay item stage
--
--OUT       :     x_progress             OUT NUMBER
--											calculated progress on pay item
--                x_return_status       OUT VARCHAR2
--                      return status of the procedure
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure
-----------------------------------------------------------------------------

PROCEDURE GET_PAY_ITEM_PROGRESS(
  p_wc_pay_item_id    IN  NUMBER,
  p_wc_stage          IN  VARCHAR2,
  x_progress          OUT NOCOPY NUMBER,
	x_return_status			OUT	NOCOPY VARCHAR2,
	x_return_msg				OUT NOCOPY VARCHAR2)
IS

USE_CASE_NOT_SUPPORTED   EXCEPTION;

l_amount_shipped      NUMBER;
l_quantity_shipped    NUMBER;
l_amount_ordered      NUMBER;
l_quantity_ordered    NUMBER;
l_matching_basis      VARCHAR2(20);
l_line_location_id    NUMBER;
l_prev_submitted      NUMBER;



BEGIN


	BEGIN
		if(p_wc_stage = 'SHIPMENT') then

			SELECT RSL.amount,
				     RSL.quantity_shipped,
					   POLL.amount,
						 POLL.quantity,
						POLL.matching_basis,
						POLL.line_location_id
			INTO  l_amount_shipped,
				    l_quantity_shipped,
						l_amount_ordered,
						l_quantity_ordered,
						l_matching_basis,
						l_line_location_id
			FROM  RCV_SHIPMENT_LINES RSL,
						PO_LINE_LOCATIONS_ALL POLL
			WHERE RSL.shipment_line_id = p_wc_pay_item_id and
						POLL.line_location_id = RSL.po_line_location_id;

		else  --currently not supporting 'INTERFACE' stage

			RAISE USE_CASE_NOT_SUPPORTED;

    end if;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      LOG(FND_LOG.LEVEL_UNEXPECTED,'get_pay_item_progress',
        'No such pay item found with pay_item_id: '||p_wc_pay_item_id);
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  BEGIN
		GET_PAY_ITEM_PREV_SUBMITTED(
        p_wc_pay_item_id   => p_wc_pay_item_id,
        p_po_pay_item_id   => l_line_location_id,
        p_wc_stage         => p_wc_stage,
        x_prev_submitted   => l_prev_submitted);

	EXCEPTION
		WHEN others THEN
      LOG(FND_LOG.LEVEL_UNEXPECTED,'get_pay_item_progress',
        'API GET_PAY_ITEM_PREV_SUBMITTED returns error');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

  if(l_matching_basis = 'QUANTITY') then
    x_progress := (l_prev_submitted+l_quantity_shipped)/l_quantity_ordered*100;
  elsif (l_matching_basis = 'AMOUNT') then
    x_progress := (l_prev_submitted+l_amount_shipped)/l_amount_ordered*100;
	end if;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

	WHEN USE_CASE_NOT_SUPPORTED THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_return_msg := 'Shipment Stage: '|| p_wc_stage || ' not supported.';

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END GET_PAY_ITEM_PROGRESS;

PROCEDURE GET_PAY_ITEM_PREV_SUBMITTED(
        p_wc_pay_item_id        IN  NUMBER,
        p_po_pay_item_id        IN  NUMBER,
        p_wc_stage              IN  VARCHAR2,
        x_prev_submitted        OUT NOCOPY NUMBER)

IS

l_request_date							DATE;
l_wc_prev_submitted_intf		NUMBER := 0;
l_wc_prev_submitted_ship		NUMBER := 0;
l_wc_status				VARCHAR2(10);
l_header_processing_status     		VARCHAR2(10);
l_header_transaction_type               VARCHAR2(10);
BEGIN

	--Need to retrieve a date as time reference.
	--INTERFACE: pay items in the interface table
	--SHIPMENT:  pay items in the shipment table
	--PO:	       pay items in the PO table
        l_wc_status := '-1';
	IF (p_wc_stage = 'INTERFACE') THEN

		SELECT RHI.request_date, RHI.processing_status_code, RHI.transaction_type
		INTO l_request_date, l_header_processing_status, l_header_transaction_type
		FROM   RCV_HEADERS_INTERFACE RHI,
					 RCV_TRANSACTIONS_INTERFACE RTI
		WHERE  RHI.HEADER_INTERFACE_ID = RTI.HEADER_INTERFACE_ID AND
					 RTI.INTERFACE_TRANSACTION_ID = p_wc_pay_item_id;

          IF(l_header_processing_status = 'DRAFT' and
                         l_header_transaction_type = 'DRAFT') THEN

                        l_wc_status := 'DRAFT';
	  END IF;


	ELSIF(p_wc_stage = 'SHIPMENT') THEN

		SELECT RSH.request_date INTO l_request_date
		FROM   RCV_SHIPMENT_HEADERS RSH,
	         RCV_SHIPMENT_LINES RSL
		WHERE  RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID AND
					 RSL.SHIPMENT_LINE_ID = p_wc_pay_item_id;

	ELSIF(p_wc_stage = 'PO') THEN

		SELECT sysdate INTO l_request_date FROM DUAL;

	END IF;
	if(l_wc_status = 'DRAFT') THEN
		l_request_date := sysdate ;
	END IF;
	--Use l_request_date as the time reference to search for all pay_items
	--that have been previously submitted.


	--First dig through the Interface table (PROCESSING)
  BEGIN
		SELECT sum(NVL(RTI.AMOUNT,RTI.QUANTITY))
		INTO	l_wc_prev_submitted_intf
		FROM	PO_LINE_LOCATIONS_ALL POLL,
					RCV_TRANSACTIONS_INTERFACE RTI,
					RCV_HEADERS_INTERFACE RHI
		WHERE RHI.HEADER_INTERFACE_ID = RTI.HEADER_INTERFACE_ID AND
			    RTI.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
				  RTI.PROCESSING_STATUS_CODE = 'PENDING' AND
					RTI.TRANSACTION_STATUS_CODE = 'PENDING' AND
					RTI.PO_LINE_LOCATION_ID = p_po_pay_item_id AND
					RHI.REQUEST_DATE < l_request_date;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN l_wc_prev_submitted_intf := 0;
  END;


  IF(l_wc_prev_submitted_intf is NULL) THEN
		l_wc_prev_submitted_intf := 0;
  END IF;

	--Then dig through the Shipment table
	--(PENDING_APPROVAL, APPROVED, REJECTED, PROCESSED)
  --NOTE: PROCESSED IS TRACK in RT?????
	BEGIN

		SELECT	sum(NVL(RSL.AMOUNT_SHIPPED, RSL.QUANTITY_SHIPPED))
		INTO	l_wc_prev_submitted_ship
		FROM 	PO_LINE_LOCATIONS_ALL POLL,
					RCV_SHIPMENT_HEADERS RSH,
					RCV_SHIPMENT_LINES RSL
		WHERE RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID AND
				  RSL.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
						(RSL.APPROVAL_STATUS is NULL OR
						 RSL.APPROVAL_STATUS in ('APPROVED', 'REJECTED', 'PROCESSED')) AND
          RSL.SHIPMENT_LINE_STATUS_CODE <> 'CANCELLED' AND
					RSL.PO_LINE_LOCATION_ID = p_po_pay_item_id AND
					RSH.REQUEST_DATE < l_request_date;
	EXCEPTION

		WHEN NO_DATA_FOUND THEN l_wc_prev_submitted_ship := 0;

	END;

  IF(l_wc_prev_submitted_ship is NULL) THEN
		l_wc_prev_submitted_ship := 0;
  END IF;


	x_prev_submitted := l_wc_prev_submitted_intf+l_wc_prev_submitted_ship;

EXCEPTION

    WHEN OTHERS THEN
			LOG(FND_LOG.LEVEL_UNEXPECTED,'get_pay_item_prev_submitted',
				'Unexpected error occurred');


END GET_PAY_ITEM_PREV_SUBMITTED;

-----------------------------------------------------------------------------
--API name  :   COMPLETE_WC_APPROVAL_WF_BLOCK
--TYPE      :   PUBLIC
--Function  :   complete the WC approval block of the WCAPPRV workflow
--Parameter :
--IN        :     p_wc_header_id               IN  NUMBER    Required
--                      corresponds to the column SHIPMENT_HEADER_ID in
--                      the table RCV_SHIPMENT_HEADERS.
--OUT       :     x_return_status       OUT VARCHAR2
--                      return status of the procedure.
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure.
-----------------------------------------------------------------------------


PROCEDURE COMPLETE_WC_APPROVAL_WF_BLOCK
(
  p_wc_header_id      IN          NUMBER,
  x_return_status     OUT nocopy  VARCHAR2,
  x_return_msg        OUT nocopy  VARCHAR2
)

IS

l_wf_item_type  VARCHAR2(8);
l_wf_item_key   VARCHAR2(280);

BEGIN

  SELECT WF_ITEM_KEY, WF_ITEM_TYPE
  INTO l_wf_item_key,l_wf_item_type
  FROM RCV_SHIPMENT_HEADERS
  WHERE SHIPMENT_HEADER_ID = p_wc_header_id;

  WF_ENGINE.CompleteActivity(l_wf_item_type,
                              l_wf_item_key,
                              'NOTIFY_WC_APPROVER_BLOCK',
                              'NULL');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  LOG(FND_LOG.LEVEL_UNEXPECTED,'complete_wc_approval_wf_block',
      'Unexpected error occurred');

END COMPLETE_WC_APPROVAL_WF_BLOCK;


-----------------------------------------------------------------------------
--API name  :   START_APPROVAL_WORKFLOW
--TYPE      :   PUBLIC
--Function  :   Start the approval workflow again after updating a
--          :   rejected WC
--Parameter :
--IN        :     p_wc_header_id               IN  NUMBER    Required
--                      corresponds to the column SHIPMENT_HEADER_ID in
--                      the table RCV_SHIPMENT_HEADERS.
--OUT       :     x_return_status       OUT VARCHAR2
--                      return status of the procedure.
--                x_return_msg          OUT VARCHAR2
--                      return message of the procedure.
-----------------------------------------------------------------------------


PROCEDURE START_APPROVAL_WORKFLOW
(
	p_wc_header_id			IN	NUMBER,
  x_return_status     OUT nocopy VARCHAR2,
  x_return_msg        OUT nocopy VARCHAR2
)

IS

WC_APPROVAL_WF_API_FAIL   EXCEPTION;
l_return_status VARCHAR2(1);
l_itemkey varchar2(60);
l_seq_for_item_key varchar2(6);

BEGIN

	/*
			All the updateable fields should have been updated at this point.
  */

  --1)Reset the Approval Status and Comment columns of the Header and the Lines

	UPDATE RCV_SHIPMENT_HEADERS
	SET APPROVAL_STATUS = null, COMMENTS = null
  WHERE SHIPMENT_HEADER_ID = p_wc_header_id;

	UPDATE RCV_SHIPMENT_LINES
	SET APPROVAL_STATUS = null, COMMENTS = null
  WHERE SHIPMENT_HEADER_ID = p_wc_header_id;


	--2)Kick off the workflow again

	select to_char(PO_WF_ITEMKEY_S.NEXTVAL)
  into l_seq_for_item_key
  from sys.dual;

  l_itemkey := to_char(p_wc_header_id) || '-' ||
               l_seq_for_item_key;


  POS_WCAPPROVE_PVT.START_WF_PROCESS(
    p_itemtype => 'WCAPPRV',
    p_itemkey => l_itemkey,
    p_workflow_process => 'MAIN_WCAPPRV_PROCESS',
    p_work_confirmation_id => p_wc_header_id,
    x_return_status => l_return_status);

	IF(x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
		RAISE WC_APPROVAL_WF_API_FAIL;
	END IF;

EXCEPTION

	WHEN WC_APPROVAL_WF_API_FAIL THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'start_approval_workflow',
			'pos_wcapprove_pvt.start_wf_process'|| 'returns unexpected error');
		LOG(FND_LOG.LEVEL_UNEXPECTED,'start_approval_workflow',
			'WC header Id:'||p_wc_header_id);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		LOG(FND_LOG.LEVEL_UNEXPECTED,'start_approval_workflow',
      'Unexpected error occurred');

END START_APPROVAL_WORKFLOW;

-- code added for work confirmation correction ER - 9414650

PROCEDURE insert_corrections_into_rti
(
  p_shipment_header_id IN NUMBER,
  p_line_location_id IN NUMBER,
  p_group_id IN NUMBER,
  p_amount_correction IN NUMBER,
  p_quantity_correction IN NUMBER,
  p_requested_amount_correction IN NUMBER,
  p_material_stored_correction IN NUMBER,
  p_comments IN varchar2)
  --x_return_status OUT nocopy VARCHAR2,
  --x_return_msg OUT nocopy VARCHAR2

IS

Cursor get_wcr_info(l_shipment_header_id NUMBER, l_line_location_id NUMBER) is
SELECT rsl.po_line_location_id,
pll.unit_meas_lookup_code,
rsl.unit_of_measure unit_of_measure,
rsl.unit_of_measure primary_unit_of_measure,
rsl.unit_of_measure source_doc_unit_of_measure,
NVL(pll.promised_date, pll.need_by_date) promised_date,
rsl.to_organization_id ship_to_organization_id,
null quantity_ordered,
null amount_ordered,
NVL(pll.price_override, pl.unit_price) po_unit_price,
pll.match_option,
rsl.category_id,
rsl.item_description,
pl.po_line_id,
ph.currency_code,
ph.rate_type currency_conversion_type,
ph.segment1 document_num,
null po_distribution_id, --pod.po_distribution_id,
rsl.req_distribution_id,
rsl.requisition_line_id,
rsl.deliver_to_location_id deliver_to_location_id,
rsl.deliver_to_location_id location_id,
rsl.deliver_to_person_id,
null currency_conversion_date, --pod.rate_date currency_conversion_date,
null currency_conversion_rate, --pod.rate currency_conversion_rate,
rsl.destination_type_code destination_type_code,
rsl.destination_type_code destination_context,
null charge_account_id, --pod.code_combination_id ,
null destination_organization_id, --pod.destination_organization_id,
null subinventory, --pod.destination_subinventory ,
rsl.ship_to_location_id,
rsl.comments,
rsl.attribute_category attribute_category,
rsl.attribute1 attribute1,
rsl.attribute2 attribute2,
rsl.attribute3 attribute3,
rsl.attribute4 attribute4,
rsl.attribute5 attribute5,
rsl.attribute6 attribute6,
rsl.attribute7 attribute7,
rsl.attribute8 attribute8,
rsl.attribute9 attribute9,
rsl.attribute10 attribute10,
rsl.attribute11 attribute11,
rsl.attribute12 attribute12,
rsl.attribute13 attribute13,
rsl.attribute14 attribute14,
rsl.attribute15 attribute15,
NVL(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code,
rsl.shipment_line_id,
rsl.item_id,
rsl.item_revision,
rsh.vendor_id,
rsh.shipment_num,
rsh.freight_carrier_code,
rsh.bill_of_lading,
rsh.packing_slip,
rsh.shipped_date,
rsh.expected_receipt_date,
rsh.waybill_airbill_num ,
rsh.vendor_site_id,
rsl.to_organization_id,
rsl.routing_header_id,
rsl.vendor_item_num,
rsl.vendor_lot_num,
rsl.ussgl_transaction_code,
rsl.government_context,
pll.po_header_id,
ph.revision_num po_revision_num,
pl.line_num document_line_num,
pll.shipment_num document_shipment_line_num,
null document_distribution_num , --pod.distribution_num
pll.po_release_id,
pl.job_id,
ph.org_id,
rsl.amount_shipped amount,
rsl.quantity_shipped  quantity,
rsl.quantity_shipped  source_doc_quantity,
rsl.quantity_shipped  primary_quantity,
rsl.quantity_shipped  quantity_shipped,
rsl.amount_shipped amount_shipped,
rsl.requested_amount requested_amount,
rsl.material_stored_amount material_stored_amount,
pll.matching_basis,
NULL project_id,
NULL task_id
FROM
--po_distributions_all pod,
po_line_locations_all pll,
po_lines_all pl,
po_headers_all ph,
rcv_shipment_lines rsl,
rcv_shipment_headers rsh
WHERE
rsh.shipment_header_id = l_shipment_header_id
AND rsl.po_line_location_id = l_line_location_id
and rsl.shipment_header_id =  rsh.shipment_header_id
and rsl.po_header_id =  ph.po_header_id
--and pod.po_header_id = ph.po_header_id
--and pod.line_location_id = pll.line_location_id
and rsl.po_line_id =  pl.po_line_id
and rsl.po_line_location_id =  pll.line_location_id
and rsh.receipt_source_code = 'VENDOR'
and pll.po_line_id = pl.po_line_id
AND NVL(pll.approved_flag, 'N') = 'Y'
AND NVL(pll.cancel_flag, 'N') = 'N'
AND pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED','PREPAYMENT');

wcr_line_info get_wcr_info%rowtype;

cursor get_dist_info(l_line_location_id NUMBER) is
select pod.po_distribution_id,
pod.rate_date currency_conversion_date,
pod.rate currency_conversion_rate,
pod.code_combination_id charge_account_id,
pod.destination_organization_id,
pod.destination_subinventory subinventory,
pod.distribution_num document_distribution_num,
pod.quantity_ordered,
pod.amount_ordered,
pod.destination_type_code destination_type_code,
pod.destination_type_code destination_context,
pod.project_id,
pod.task_id
from po_distributions_all pod
where pod.line_location_id = l_line_location_id;

l_shipment_header_id NUMBER;
l_line_location_id NUMBER;
l_progress VARCHAR2(240);

l_uom_code mtl_units_of_measure.uom_code%type;
l_row_id varchar2(40);
l_interface_id number;
l_group_id number;
l_vendor_id number;
l_vendor_site_id number;
l_ship_to_org_id number;
l_ship_to_location_id number;
l_header_interface_id number;
l_expected_receipt_date date;
l_shipment_num varchar2(50);
l_receipt_num varchar2(50);
l_matching_basis varchar2(35);
l_transacted_amount number;
l_interface_amount number;
l_transacted_quantity number;
l_interface_quantity number;
l_insert_into_rti boolean := TRUE;
l_max_dist NUMBER;
l_dist_count NUMBER;

L_REMAINING_AMOUNT_CORRECTION NUMBER;
L_REMAINING_REQ_AMOUNT_CORRECT NUMBER;
L_REMAINING_MAT_STORED_CORRECT NUMBER;
L_REMAINING_QUANTITY_CORRECT NUMBER;

l_available_correct_amount NUMBER;
l_carry_over_correction_amount NUMBER;
l_available_correct_quantity NUMBER;
l_carry_over_correct_quantity NUMBER;

l_transaction_type VARCHAR2(10);
l_parent_transaction_id NUMBER;

l_comments VARCHAR2(100);

l_req_amount_inserted BOOLEAN := FALSE;
l_mat_stored_inserted BOOLEAN := FALSE;

l_primary_quantity_in NUMBER;

BEGIN

  l_shipment_header_id := p_shipment_header_id;
  l_line_location_id := p_line_location_id;
  l_group_id := p_group_id;
  l_comments := p_comments;

  l_progress := 'BEFORE opening the cursor';
  -- opening the work confirmation cursor at specific pay item level
	open get_wcr_info(l_shipment_header_id, l_line_location_id);

  l_progress := 'after opening the cursor';

  -- looping through the pay items associated with the current work confirmation
  -- since we are passing line location id as well, we would be ideally getting only one record.
  loop --{

  	l_progress := 'inside the loop';

    	l_progress := 'POS_WC_CREATE_UPDATE_PVT.insert_corrections_into_rti:01.';


	fetch get_wcr_info into wcr_line_info;
	exit when get_wcr_info%notfound;


	If (wcr_line_info.unit_of_measure is not null) then
			select  muom.uom_code
			into l_uom_code
			from mtl_units_of_measure muom
			WHERE  muom.unit_of_measure = wcr_line_info.unit_of_measure;

	end if;

	l_matching_basis:= wcr_line_info.matching_basis;


	If (l_matching_basis = 'AMOUNT') then

      		l_remaining_amount_correction := p_amount_correction;
      		l_remaining_req_amount_correct := p_requested_amount_correction;
      		l_remaining_mat_stored_correct := p_material_stored_correction;


  	end if;

	If (l_matching_basis = 'QUANTITY') then

		l_remaining_quantity_correct := p_quantity_correction;
	end if;

	-- getting the number of distributions associated at the current pay item level
	SELECT Count(*)
    	INTO l_max_dist
    	FROM po_distributions_all pod
    	where pod.line_location_id = wcr_line_info.po_line_location_id;

    	-- the following two attributes take care that the requested amount and material stored values get updated only for the
    	-- first distribution, and for the subsequent distributions they are entered as 0.

    	l_req_amount_inserted := FALSE;
    	l_mat_stored_inserted := FALSE;

    	l_dist_count := 0;

    	-- opening the cursor for fetching distribution level information into the wcr record to be inserted into RTI
		open get_dist_info(wcr_line_info.po_line_location_id);

	-- looping through the distributions cursor to insert data in RTI
    	loop --{

		l_progress := 'POS_WC_CREATE_UPDATE_PVT.insert_corrections_into_rti:02.';
        	l_progress := 'entered the dist loop';

		fetch get_dist_info into
				wcr_line_info.po_distribution_id,
				wcr_line_info.currency_conversion_date,
				wcr_line_info.currency_conversion_rate,
				wcr_line_info.charge_account_id,
				wcr_line_info.destination_organization_id,
				wcr_line_info.subinventory,
				wcr_line_info.document_distribution_num,
				wcr_line_info.quantity_ordered,
				wcr_line_info.amount_ordered,
        			wcr_line_info.destination_type_code,
        			wcr_line_info.destination_context,
					wcr_line_info.project_id,
					wcr_line_info.task_id;

        	exit when get_dist_info%notfound or
			(l_matching_basis = 'AMOUNT' and l_remaining_amount_correction >= 0)
			or
			(l_matching_basis = 'QUANTITY' and l_remaining_quantity_correct >= 0);

        	l_dist_count := l_dist_count + 1;


		-- set the work confirmation variables for service based lines
		If (l_matching_basis = 'AMOUNT') then--{

			/* l_transacted_amount = amount which was transacted earlier than the submission of
			current work confirmation for this payitem / distribution */
			select nvl(sum(amount),0)
			into l_transacted_amount
			from rcv_transactions
			where po_distribution_id= wcr_line_info.po_distribution_id
			and destination_type_code = 'RECEIVING';

			/* l_interface_amount = amount which is in the interface tables /pending to be approved / rejected before the submission of
			current work confirmation for this payitem / distribution */
			select nvl(sum(amount),0)
			into l_interface_amount
			from rcv_transactions_interface
			where po_distribution_id= wcr_line_info.po_distribution_id
			and processing_status_code='PENDING'
			and transaction_status_code = 'PENDING'
			and transaction_type = 'RECEIVE';

			-- l_available_correct_amount = total amount received against this distribution id
          		l_available_correct_amount := l_transacted_amount + l_interface_amount;


          		-- l_carry_over_correction_amount = correction amount left to be entered after doing correction for this
          		-- distribution id, to be carried over to next distribution
          		l_carry_over_correction_amount := l_remaining_amount_correction + l_available_correct_amount;

          		-- check if this is the last distribution for the pay item
			IF (l_dist_count >= l_max_dist) THEN

				-- last distribution for pay item, insert the l_remaining_amount_correction completely
				wcr_line_info.amount := l_remaining_amount_correction;

				l_remaining_amount_correction := 0;

              			IF(l_req_amount_inserted) THEN
                			wcr_line_info.requested_amount := null;
              			ELSE
                			wcr_line_info.requested_amount := l_remaining_req_amount_correct;
              			END IF;

              			IF(l_mat_stored_inserted) THEN
                			wcr_line_info.material_stored_amount := null;
              			ELSE
                			wcr_line_info.material_stored_amount := l_remaining_mat_stored_correct;
              			END IF;

              			l_req_amount_inserted := TRUE;
              			l_mat_stored_inserted := TRUE;

				l_insert_into_rti := TRUE;

			ELSE
				-- not the last distribution for the pay item, check if we need to insert or not

				IF(l_available_correct_amount > 0) THEN
				-- this distribution is not yet completely emptied,
				-- so we "need to insert" the correction depending on l_remaining_amount_correction and l_available_correct_amount

					IF(l_carry_over_correction_amount > 0) THEN

						-- this means that the entire correction amount can be inserted for this distribution
						wcr_line_info.amount := l_remaining_amount_correction;

						l_remaining_amount_correction := 0;

					ELSE

				    		-- this means that the entire correction can not be inserted for this distribution alone
                				-- need to carry over the remaining correction to the next distribution
                				-- for this distribution, insert only the "l_available_correct_amount" as permitted

						wcr_line_info.amount := 0 - l_available_correct_amount;

                				-- modify the l_remaining_amount_correction value after insertion

						l_remaining_amount_correction := l_remaining_amount_correction + l_available_correct_amount;

					END IF;

                			IF(l_req_amount_inserted) THEN
                  				wcr_line_info.requested_amount := null;
                			ELSE
                  				wcr_line_info.requested_amount := l_remaining_req_amount_correct;
                			END IF;

                			IF(l_mat_stored_inserted) THEN
                  				wcr_line_info.material_stored_amount := null;
                			ELSE
                  				wcr_line_info.material_stored_amount := l_remaining_mat_stored_correct;
                			END IF;

                			l_req_amount_inserted := TRUE;
                			l_mat_stored_inserted := TRUE;

				    	l_insert_into_rti := TRUE;

            			ELSE

					-- l_available_amount < 0, so "no need to insert"
            				l_insert_into_rti := FALSE;

				END IF;

			END IF;

		-- set the work confirmation variables for quantity based lines
		elsif (l_matching_basis = 'QUANTITY') then --}{

			/* l_transacted_quantity = quantity which was transacted earlier than the submission of
			current work confirmation for this payitem / distribution */
			select nvl(sum(quantity),0)
			into l_transacted_quantity
			from rcv_transactions
			where po_distribution_id= wcr_line_info.po_distribution_id
			and destination_type_code = 'RECEIVING';

			/* l_interface_quantity = quantity which is in the interface tables /pending to be approved / rejected before the submission of
			current work confirmation for this payitem / distribution */
			select nvl(sum(quantity),0)
			into l_interface_quantity
			from rcv_transactions_interface
			where po_distribution_id= wcr_line_info.po_distribution_id
			and processing_status_code='PENDING'
			and transaction_status_code = 'PENDING'
			and transaction_type = 'RECEIVE';


          		-- l_available_correct_quantity = total quantity received against this distribution id
         	 	l_available_correct_quantity := l_transacted_quantity + l_interface_quantity;

          		-- l_carry_over_correction_quantity = correction quantity left to be entered after doing correction for this
          		-- distribution id, to be carried over to next distribution
          		l_carry_over_correct_quantity := l_remaining_quantity_correct + l_available_correct_quantity;

        		-- check if this is the last distribution for the pay item
          		IF (l_dist_count >= l_max_dist) THEN

				-- last distribution for pay item, insert the l_remaining_quantity_correct completely
          			wcr_line_info.quantity := l_remaining_quantity_correct;
          			l_remaining_quantity_correct := 0;
          			l_insert_into_rti := TRUE;

        	  	ELSE

				-- not the last distribution for the pay item, check if we need to insert or not
				IF(l_available_correct_quantity > 0) THEN

					-- this distribution is not yet completely emptied,
					-- so we "need to insert" the correction depending on l_remaining_quantity_correct and l_available_correct_quantity
					IF(l_carry_over_correct_quantity > 0) THEN

						-- this means that the entire correction amount can be inserted for this distribution
						wcr_line_info.quantity := l_remaining_quantity_correct;
						l_remaining_quantity_correct := 0;

					ELSE

					      	-- this means that the entire correction can not be inserted for this distribution alone
		                  		-- need to carry over the remaining correction to the next distribution
                  				-- for this distribution, insert only the l_available_correct_quantity as permitted

						wcr_line_info.quantity := 0 - l_available_correct_quantity;

                  				-- modify the l_remaining_quantity_correct value after insertion
                  				l_remaining_quantity_correct := l_remaining_quantity_correct + l_available_correct_quantity;
					END IF;

					l_insert_into_rti := TRUE;

              			ELSE

					-- l_available_amount < 0, so "no need to insert"
              				l_insert_into_rti := FALSE;

				END IF;

			END IF;

		end if;	--}


		If (l_insert_into_rti) then --{

          		FOR i IN 1..2 LOOP

            			select rcv_transactions_interface_s.nextval
				    into l_interface_id
				    from dual;

            			IF (i = 1) THEN

              				l_transaction_type := 'DELIVER';

            			ELSIF (i = 2) THEN

              				l_transaction_type := 'RECEIVE';
              				wcr_line_info.destination_type_code := 'RECEIVING';
              				wcr_line_info.destination_context := 'RECEIVING';

            			END IF;

            			select transaction_id
            			INTO l_parent_transaction_id
            			from rcv_transactions
            			where shipment_header_id = l_shipment_header_id
            			AND po_line_location_id = l_line_location_id
            			AND transaction_type = l_transaction_type
            			AND po_distribution_id = wcr_line_info.po_distribution_id;

            			IF(wcr_line_info.matching_basis = 'QUANTITY') THEN

              				po_uom_s.uom_convert(from_quantity => wcr_line_info.quantity,
                                 	from_uom      => wcr_line_info.unit_of_measure,
                                  	item_id       => wcr_line_info.item_id,
                                  	to_uom        => wcr_line_info.primary_unit_of_measure,
                                  	to_quantity   => l_primary_quantity_in);

              			wcr_line_info.primary_quantity := l_primary_quantity_in;

            			END IF;

            			l_progress := 'before the actual insert';

           			 rcv_asn_interface_trx_ins_pkg.insert_row
			      (l_row_id,
			      l_interface_id,--interface_id
			      l_group_id, --group_id
			      sysdate, --last_updated_date
			      fnd_global.user_id, --last_updated_by,
			      sysdate, --creation_date,
			      fnd_global.login_id, --created_by,
			      fnd_global.login_id, -- last_update_login,
			      NULL, --request_id,
			      null, --program_application_id,
			      null, --program_id,
			      null, --program_update_date,
			      'CORRECT', --transaction_type,
			      sysdate, --transaction_date,
			      'PENDING', --processing_status_code,
			      'IMMEDIATE', --processing_mode_code,
			      null, --processing_request_id,
			      'PENDING', --.transaction_status_code,
			      wcr_line_info.category_id,
			      wcr_line_info.quantity, --quantity
			      wcr_line_info.unit_of_measure,
			      'ISP', --.interface_source_code,
			      NULL, --.interface_source_line_id,
			      NULL, --.inv_transaction_id,
			      wcr_line_info.item_id,
			      wcr_line_info.item_description,
			      wcr_line_info.item_revision,
			      l_uom_code, --uom_code,
			      NULL, --employee_id,
			      NULL, --auto_transact_code,
			      l_shipment_header_id, --l_shipment_header_id
			      wcr_line_info.shipment_line_id,
			      wcr_line_info.ship_to_location_id,
			      wcr_line_info.primary_quantity,
			      wcr_line_info.primary_unit_of_measure,
			      'VENDOR', --.receipt_source_code,
			      wcr_line_info.vendor_id,
			      wcr_line_info.vendor_site_id,
			      NULL, --from_organization_id,
			      NULL, --from_subinventory,
			      wcr_line_info.to_organization_id,
			      NULL, --.intransit_owning_org_id,
			      wcr_line_info.routing_header_id,
			      NULL, --.routing_step_id,
			      'PO', --source_document_code,
			      l_parent_transaction_id, --.parent_transaction_id (for correction purpose),
			      wcr_line_info.po_header_id,
			      wcr_line_info.po_revision_num,
			      wcr_line_info.po_release_id,
			      wcr_line_info.po_line_id,
			      wcr_line_info.po_line_location_id,
			      wcr_line_info.po_unit_price,
			      wcr_line_info.currency_code,
			      wcr_line_info.currency_conversion_type,
			      wcr_line_info.currency_conversion_rate,
			      wcr_line_info.currency_conversion_date,
			      wcr_line_info.po_distribution_id,
			      wcr_line_info.requisition_line_id,
			      wcr_line_info.req_distribution_id,
			      wcr_line_info.charge_account_id,
			      NULL, --.substitute_unordered_code,
			      NULL, --.receipt_exception_flag,
			      NULL, --.accrual_status_code,
			      'NOT INSPECTED' ,--.inspection_status_code,
			      NULL, --.inspection_quality_code,
			      wcr_line_info.destination_type_code,
			      wcr_line_info.deliver_to_person_id,
			      wcr_line_info.location_id,
			      wcr_line_info.deliver_to_location_id,
			      NULL, --.subinventory,
			      NULL, --.locator_id,
			      NULL, --.wip_entity_id,
			      NULL, --.wip_line_id,
			      NULL, --.department_code,
			      NULL, --.wip_repetitive_schedule_id,
			      NULL, --.wip_operation_seq_num,
			      NULL, --.wip_resource_seq_num,
			      NULL, --.bom_resource_id,
			      wcr_line_info.shipment_num,
			      wcr_line_info.freight_carrier_code,
			      wcr_line_info.bill_of_lading,
			      wcr_line_info.packing_slip,
			      wcr_line_info.shipped_date,
			      wcr_line_info.expected_receipt_date,
			      NULL, --.actual_cost,
			      NULL, --.transfer_cost,
			      NULL, --.transportation_cost,
			      NULL, --.transportation_account_id,
			      NULL, --.num_of_containers,
			      wcr_line_info.waybill_airbill_num,
			      wcr_line_info.vendor_item_num,
			      wcr_line_info.vendor_lot_num,
			      NULL,--.rma_reference,
			      l_comments,
			      wcr_line_info.attribute_category,
			      wcr_line_info.attribute1,
			      wcr_line_info.attribute2,
			      wcr_line_info.attribute3,
			      wcr_line_info.attribute4,
			      wcr_line_info.attribute5,
			      wcr_line_info.attribute6,
			      wcr_line_info.attribute7,
			      wcr_line_info.attribute8,
			      wcr_line_info.attribute9,
			      wcr_line_info.attribute10,
			      wcr_line_info.attribute11,
			      wcr_line_info.attribute12,
			      wcr_line_info.attribute13,
			      wcr_line_info.attribute14,
			      wcr_line_info.attribute15,
			      NULL, --.ship_head_attribute_category,
			      NULL, --.ship_head_attribute1,
			      NULL, --.ship_head_attribute2,
			      NULL, --.ship_head_attribute3,
			      NULL, --.ship_head_attribute4,
			      NULL, --.ship_head_attribute5,
			      NULL, --.ship_head_attribute6,
			      NULL, --.ship_head_attribute7,
			      NULL, --.ship_head_attribute8,
			      NULL, --.ship_head_attribute9,
			      NULL, --.ship_head_attribute10,
			      NULL, --.ship_head_attribute11,
			      NULL, --.ship_head_attribute12,
			      NULL, --.ship_head_attribute13,
			      NULL, --.ship_head_attribute14,
			      NULL, --.ship_head_attribute15,
			      NULL, --.ship_line_attribute_category,
			      NULL, --.ship_line_attribute1,
			      NULL, --.ship_line_attribute2,
			      NULL, --.ship_line_attribute3,
			      NULL, --.ship_line_attribute4,
			      NULL, --.ship_line_attribute5,
			      NULL, --.ship_line_attribute6,
			      NULL, --.ship_line_attribute7,
			      NULL, --.ship_line_attribute8,
			      NULL, --.ship_line_attribute9,
			      NULL, --.ship_line_attribute10,
			      NULL, --.ship_line_attribute11,
			      NULL, --.ship_line_attribute12,
			      NULL, --.ship_line_attribute13,
			      NULL, --.ship_line_attribute14,
			      NULL, --.ship_line_attribute15,
			      wcr_line_info.ussgl_transaction_code,
			      wcr_line_info.government_context,
			      NULL, --.reason_id,
			      wcr_line_info.destination_context,
			      wcr_line_info.source_doc_quantity,
			      wcr_line_info.source_doc_unit_of_measure,
			      NULL, --.movement_id,
			      NULL, --l_header_interface_id, --.header_interface_id,
			      NULL, --.vendor_cum_shipped_qty,
			      NULL, --.item_num,
			      wcr_line_info.document_num,
			      wcr_line_info.document_line_num,
			      NULL, --.truck_num,
			      NULL, --.ship_to_location_code,
			      NULL, --.container_num,
			      NULL, --.substitute_item_num,
			      NULL, --.notice_unit_price,
			      NULL, --.item_category,
			      NULL, --.location_code,
			      NULL, --.vendor_name,
			      NULL, --.vendor_num,
			      NULL, --.vendor_site_code,
			      NULL, --.from_organization_code,
			      NULL, --.to_organization_code,
			      NULL, --.intransit_owning_org_code,
			      NULL, --.routing_code,
			      NULL, --.routing_step,
			      NULL, --.release_num,
			      wcr_line_info.document_shipment_line_num,
			      wcr_line_info.document_distribution_num,
			      NULL, --.deliver_to_person_name,
			      NULL, --.deliver_to_location_code,
			      NULL, --.use_mtl_lot,
			      NULL, --.use_mtl_serial,
			      NULL, --.LOCATOR,
			      NULL, --.reason_name,
			      NULL, --.validation_flag,
			      NULL, --.substitute_item_id,
			      NULL, --.quantity_shipped,
			      NULL, --.quantity_invoiced,
			      NULL, --.tax_name,
			      NULL, --.tax_amount,
			      NULL, --.req_num,
			      NULL, --.req_line_num,
			      NULL, --.req_distribution_num,
			      NULL, --.wip_entity_name,
			      NULL, --.wip_line_code,
			      NULL, --.resource_code,
			      NULL, --.shipment_line_status_code,
			      NULL, --.barcode_label,
			      NULL, --.country_of_origin_code,
			      NULL, --.from_locator_id, --WMS Change
			      NULL, --.qa_collection_id,
			      NULL, --.oe_order_header_id,
			      NULL, --.oe_order_line_id,
			      NULL, --.customer_id,
			      NULL, --.customer_site_id,
			      NULL, --.customer_item_num,
			      NULL, --.create_debit_memo_flag,
			      NULL, --.put_away_rule_id,
			      NULL, --.put_away_strategy_id,
			      NULL, --.lpn_id,
			      NULL, --.transfer_lpn_id,
			      NULL, --.cost_group_id,
			      NULL, --.mobile_txn,
			      NULL, --.mmtt_temp_id,
			      NULL, --.transfer_cost_group_id,
			      NULL, --.secondary_quantity,
			      NULL, --.secondary_unit_of_measure,
			      NULL, --.secondary_uom_code,
			      NULL, --.qc_grade,
			      NULL, --.oe_order_num,
			      NULL, --.oe_order_line_num,
			      NULL, --.customer_account_number,
			      NULL, --.customer_party_name,
			      NULL, --.source_transaction_num,
			      NULL, --.parent_source_transaction_num,
			      NULL, --.parent_interface_txn_id,
			      NULL, --.customer_item_id,
			      NULL, --.interface_available_qty,
			      NULL, --.interface_transaction_qty,
			      NULL, --.from_locator,
			      NULL, --.lpn_group_id,
			      NULL, --.order_transaction_id,
			      NULL, --.license_plate_number,
			      NULL, --.transfer_license_plate_number,
			      wcr_line_info.amount,
			      wcr_line_info.job_id,
			      wcr_line_info.project_id, --.project_id,
			      wcr_line_info.task_id, --.task_id,
			      NULL, --.asn_attach_id,
			      NULL, --.timecard_id,
			      NULL, --.timecard_ovn,
			      NULL, --.interface_available_amt,
			      NULL, --.interface_transaction_amt
			      wcr_line_info.org_id,  --<R12 MOAC>
			      wcr_line_info.matching_basis,
			      NULL, --wcr_line_info.amount_shipped, --amount_shipped
			      wcr_line_info.requested_amount,
			      wcr_line_info.material_stored_amount);

            			l_progress := 'record inserted';


          		END LOOP;


		  END IF; --}

	end loop; --}

	If get_dist_info%isopen then
			Close get_dist_info;
		end if;


end loop; --}

If get_wcr_info%isopen then
		Close get_wcr_info;
end if;


EXCEPTION

  WHEN OTHERS THEN
		LOG(FND_LOG.LEVEL_UNEXPECTED,'INSERT CORRECTION DATA IN RTI',
				'Unexpected error at stage: '|| l_progress);

END insert_corrections_into_rti;

procedure Launch_RTP_Immediate
			   (p_group_id IN NUMBER)  IS

l_group_id number;
l_result_id NUMBER;
begin

	l_group_id := p_group_id;

    	l_result_id :=
                fnd_request.submit_request('PO',
                'RVCTP',
                null,
                null,
                false,
                'IMMEDIATE',
		--'BATCH',
		l_group_id,
                --fnd_char.local_chr(0),
		NULL, -- Modified as part of P1 Bug #: 16208460
                NULL,
                NULL,
                NULL,
                NULL,
                NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,

                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,

                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);


     	COMMIT;

exception
        when others then
        raise;

END Launch_RTP_Immediate;

PROCEDURE get_wc_history(p_shipment_header_id IN NUMBER,
                         p_correction_history_tab IN OUT NOCOPY correction_history_tab )
IS

  l_shipment_header_id NUMBER := p_shipment_header_id;
  TYPE group_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE line_location_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE quantity_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE  total_amt_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE  requested_amt_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE  matstored_amt_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_groups group_type;
  l_line_locations  line_location_type;

  l_old_quantity quantity_type;
  l_old_total_amount total_amt_type;
  l_old_requested_amount requested_amt_type;
  l_old_matstoredAmount  matstored_amt_type;

  l_new_quantity quantity_type;
  l_new_total_amount total_amt_type;
  l_new_requested_amount requested_amt_type;
  l_new_matstoredAmount  matstored_amt_type;
  l_old_quantity1 NUMBER;
  l_old_total_amount1 NUMBER;
  l_old_requestedAmount1 NUMBER;
  l_old_matstoredamount1 NUMBER;
  i NUMBER := 0;
  j NUMBER := 0;
  k NUMBER := 0;

  l_old_quantity2 NUMBER;
  l_old_total_amount2 NUMBER;
  l_old_requestedAmount2 NUMBER;
  l_old_matstoredamount2 NUMBER;
  l_corrected_quantity NUMBER;
  l_corrected_total_amount  NUMBER;
  l_corrected_requested_amount NUMBER;
  l_corrected_matstoredAmount NUMBER;
  l_po_header_id NUMBER;
  l_po_line_location_id NUMBER;
  l_line_location_id NUMBER;
  l_group_id NUMBER;

  l_last_updated_by NUMBER;
  l_creation_date DATE;
  l_created_by NUMBER;
  l_transaction_type VARCHAR2(10);
  l_transaction_date DATE;
  l_po_line_id NUMBER;
  --l_comments VARCHAR2(100);
  l_comments rcv_transactions.comments%TYPE;
  l_ordered_quantity NUMBER;
  l_ordered_amount NUMBER;
  l_price NUMBER;
  l_line_num NUMBER;
  --l_description VARCHAR2(100);
  l_description po_line_locations_all.description%TYPE;
  l_matching_basis VARCHAR2(10);
  l_shipment_num NUMBER;

  l_employee_id NUMBER;
  l_full_name VARCHAR2(100);
  l_old_progress NUMBER;
  l_new_progress NUMBER;

  l_correction_num NUMBER;

  l_correction_history_rec wc_correction_history_rec;
  l_correction_history_tab correction_history_tab := correction_history_tab();

  CURSOR c1 IS
    SELECT DISTINCT po_line_location_id
    FROM rcv_transactions rt
    WHERE shipment_header_id = l_shipment_header_id
    AND transaction_type = 'CORRECT'
    ORDER BY po_line_location_id;

  CURSOR c2(l_line_location_id NUMBER) IS
    SELECT distinct group_id
    FROM rcv_transactions rt
    WHERE shipment_header_id = l_shipment_header_id
    AND transaction_type = 'CORRECT'
        AND EXISTS (SELECT '1'
                   FROM rcv_transactions rt2
                   WHERE rt2.transaction_type = 'DELIVER'
                   AND rt2.transaction_id = rt.parent_transaction_id)
    AND po_line_location_id = l_line_location_id
    ORDER BY group_id ASC;

BEGIN

  OPEN c1;

    LOOP

      i := i + 1;

      FETCH c1 INTO l_line_locations(i);
      EXIT WHEN c1%NOTFOUND;

    END LOOP;

  CLOSE c1;

  FOR i IN 1 .. l_line_locations.count LOOP
    k := 1;
    l_line_location_id := l_line_locations(i);

    SELECT  Sum(rt.quantity),
      Sum(rt.amount),
      Sum(rt.requested_amount) ,
      Sum(rt.material_stored_amount),
      po_header_id,
      po_line_location_id
    INTO l_old_quantity1,
      l_old_total_amount1,
      l_old_requestedAmount1,
      l_old_matstoredamount1,
      l_po_header_id,
      l_po_line_location_id
    FROM rcv_transactions rt
    WHERE shipment_header_id = l_shipment_header_id
      AND po_line_location_id = l_line_location_id
      AND transaction_type = 'DELIVER'
    GROUP BY po_header_id,
      po_line_location_id;

    l_correction_num := 1;
    OPEN c2(l_line_location_id);

    LOOP

      FETCH c2 INTO l_groups(l_correction_num);
      EXIT WHEN c2%NOTFOUND;
      l_correction_num := l_correction_num + 1;

    END LOOP;
    l_correction_num := l_correction_num - 1;

    CLOSE c2;

    FOR j IN 1 .. l_correction_num LOOP

      SELECT Sum(Nvl(rt.quantity, 0)),
        Sum(Nvl(rt.amount, 0)),
        Sum(Nvl(rt.requested_amount, 0)) ,
        Sum(Nvl(rt.material_stored_amount, 0)),
        Min(rt.last_updated_by),
        Min(Nvl(rt.employee_id, -1)),
        Min(rt.creation_date),
        --Min(rt.created_by),
        Min(rt.transaction_type),
        Min(rt.transaction_date),
        rt.po_header_id,
        rt.po_line_id,
        Min(rt.comments),
        Min(pll.quantity),
        Min(pll.amount),
        DECODE( pll.matching_basis, 'AMOUNT' , Min(pll.AMOUNT), Min(pll.PRICE_OVERRIDE)),
        pl.line_num ,
        pll.description ,
        pll.matching_basis ,
        pll.shipment_num
      INTO l_corrected_quantity,
        l_corrected_total_amount,
        l_corrected_requested_amount,
        l_corrected_matstoredAmount,
        l_last_updated_by,
        l_employee_id,
        l_creation_date,
        --l_created_by,
        l_transaction_type,
        l_transaction_date,
        l_po_header_id,
        l_po_line_id,
        l_comments,
        l_ordered_quantity,
        l_ordered_amount,
        l_price,
        l_line_num,
        l_description,
        l_matching_basis,
        l_shipment_num
      FROM rcv_transactions rt,
        po_lines_all pl,
        po_line_locations_all pll
      WHERE rt.shipment_header_id = l_shipment_header_id
        AND rt.transaction_type = 'CORRECT'
        AND EXISTS (SELECT '1'
                    FROM rcv_transactions rt2
                    WHERE rt2.transaction_type = 'DELIVER'
                    AND rt2.transaction_id = rt.parent_transaction_id
					)
                    AND rt.po_line_location_id = l_line_location_id
                    AND rt.group_id = l_groups(j)
        AND pll.line_location_id = rt.po_line_location_id
        AND pl.po_line_id = rt.po_line_id
        AND pl.po_line_id = pll.po_line_id
        GROUP BY rt.group_id,
                rt.po_header_id,
                rt.po_line_id,
                rt.po_line_location_id,
                pl.line_num,
                pll.description,
                pll.matching_basis,
                pll.shipment_num;

      IF (j > 1) THEN

        l_old_quantity(k) := l_old_quantity2;
        l_old_total_amount(k) :=  l_old_total_amount2;
        l_old_requested_amount(k) :=l_old_requestedAmount2;
        l_old_matstoredAmount(k) := l_old_matstoredamount2;

      ELSE

        l_old_quantity(k) := l_old_quantity1;
        l_old_total_amount(k) :=  l_old_total_amount1;
        l_old_requested_amount(k) := l_old_requestedAmount1;
        l_old_matstoredAmount(k) := l_old_matstoredamount1;

        l_old_quantity2 := l_old_quantity1;
        l_old_total_amount2 := l_old_total_amount1;
        l_old_requestedAmount2 := l_old_requestedAmount1;
        l_old_matstoredamount2 := l_old_matstoredamount1;

      END IF;

      l_new_quantity(k) := l_old_quantity2 + l_corrected_quantity;
      l_new_total_amount(k) := l_old_total_amount2 + l_corrected_total_amount;
      l_new_requested_amount(k) := l_old_requestedamount2 + l_corrected_requested_amount;
      l_new_matstoredAmount(k) := l_old_matstoredamount2 + l_corrected_matstoredAmount;

      l_old_quantity2 := l_new_quantity(k);
      l_old_total_amount2  := l_new_total_amount(k);
      l_old_requestedAmount2 := l_new_requested_amount(k);
      l_old_matstoredamount2 := l_new_matstoredAmount(k);

      l_correction_history_rec.old_quantity := l_old_quantity(k);
      l_correction_history_rec.new_quantity := l_new_quantity(k);
      l_correction_history_rec.old_total_amount  := l_old_total_amount(k);
      l_correction_history_rec.old_req_amount := l_old_requested_amount(k);
      l_correction_history_rec.old_mat_stored := l_old_matstoredAmount(k);
      l_correction_history_rec.new_total_amount :=  l_new_total_amount(k) ;
      l_correction_history_rec.new_req_amount := l_new_requested_amount(k);
      l_correction_history_rec.new_mat_stored := l_new_matstoredAmount(k);

      l_correction_history_rec.correction_date := l_creation_date;


      IF(l_last_updated_by >0) THEN

        -- bug - 9692573 - fetching the data only for the active employee record
	SELECT Nvl(full_name, ' ')
        INTO l_full_name
        FROM per_employees_current_x
        WHERE employee_id = (SELECT employee_id FROM fnd_user WHERE user_id = l_last_updated_by);

      ELSE

        l_full_name := ' ';

      END IF;


      l_correction_history_rec.corrected_by := l_full_name;
      l_correction_history_rec.shipment_header_id := l_shipment_header_id;
      l_correction_history_rec.po_header_id := l_po_header_id;
      l_correction_history_rec.po_line_id := l_po_line_id;
      l_correction_history_rec.po_line_location_id := l_line_location_id;
      l_correction_history_rec.comments := l_comments;
      l_correction_history_rec.quantity_ordered := l_ordered_quantity;
      l_correction_history_rec.amount_ordered := l_ordered_amount;
      l_correction_history_rec.price := l_price;
      l_correction_history_rec.group_id := l_groups(j);
      l_correction_history_rec.document_line_num :=  l_line_num;
      l_correction_history_rec.pay_item_num := l_shipment_num;
      l_correction_history_rec.description := l_description;
      l_correction_history_rec.matching_basis := l_matching_basis;


      IF(l_matching_basis = 'QUANTITY') THEN

        l_old_progress := ( l_old_quantity(k) / l_ordered_quantity )* 100;
        l_new_progress := ( l_new_quantity(k) / l_ordered_quantity ) * 100;

        l_correction_history_rec.old_req_deliver := l_old_quantity(k);
        l_correction_history_rec.new_req_deliver := l_new_quantity(k);

        l_correction_history_rec.old_total_amount := l_old_quantity(k) * l_price;
        l_correction_history_rec.new_total_amount := l_new_quantity(k) * l_price;

      ELSIF (l_matching_basis = 'AMOUNT') THEN

        l_old_progress := ( l_old_total_amount(k) / l_ordered_amount )* 100;
        l_new_progress := ( l_new_total_amount(k) / l_ordered_amount ) * 100;

        l_correction_history_rec.old_req_deliver := l_old_requested_amount(k);
        l_correction_history_rec.new_req_deliver := l_new_requested_amount(k);

      END IF;

      l_correction_history_rec.old_progress := Round(l_old_progress, 2);
      l_correction_history_rec.new_progress := Round(l_new_progress, 2);

      l_correction_history_tab.EXTEND;
      l_correction_history_tab(l_correction_history_tab.COUNT) := l_correction_history_rec;



      k := k+1;

    END LOOP;

  END LOOP;

  p_correction_history_tab := l_correction_history_tab;

EXCEPTION

  WHEN OTHERS THEN RAISE;

END get_wc_history;

FUNCTION get_wc_correction_history(p_shipment_header_id IN NUMBER)
RETURN correction_history_tab PIPELINED  IS

  l_shipment_header_id NUMBER := p_shipment_header_id;
  l_correction_history_tab correction_history_tab := correction_history_tab();

BEGIN

  get_wc_history(l_shipment_header_id, l_correction_history_tab);

  FOR i IN l_correction_history_tab.FIRST..l_correction_history_tab.LAST LOOP

    PIPE ROW(l_correction_history_tab(i));

  END LOOP;

  RETURN;

END;

-- end of code added for work confirmation correction ER - 9414650

END POS_WC_CREATE_UPDATE_PVT;

/
