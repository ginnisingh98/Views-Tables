--------------------------------------------------------
--  DDL for Package Body POA_EDW_SUPPERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_SUPPERF" AS
  /* $Header: poaspwhb.pls 115.11 2003/12/09 10:56:20 bthammin ship $ */

  ZERO_TOLERANCE		CONSTANT REAL := 0.000001;
  NULL_VALUE                    CONSTANT INTEGER := -23453;
  MAGIC_STRING                  CONSTANT VARCHAR2(10) := '734jkhJK24';
  NO_PRICE			CONSTANT INTEGER := -1;
  l_qty_rec_line_id             NUMBER := -99999;
  l_qty_rec_cnt_all             NUMBER := -99999;
  l_qty_rec_cnt_early           NUMBER := -99999;
  l_qty_rec_cnt_late            NUMBER := -99999;
  l_qty_rec_cnt_early_window    NUMBER := -99999;
  l_qty_rec_cnt_late_window     NUMBER := -99999;
  l_qty_rec_cnt_ondate          NUMBER := -99999;
  l_qty_rec_cnt_substitute      NUMBER := -99999;
  l_qty_rec_num_all             NUMBER := -99999;
  l_qty_rec_num_early           NUMBER := -99999;
  l_qty_rec_num_late            NUMBER := -99999;
  l_qty_rec_num_early_window    NUMBER := -99999;
  l_qty_rec_num_late_window     NUMBER := -99999;
  l_qty_rec_num_ondate          NUMBER := -99999;
  l_qty_rec_num_substitute      NUMBER := -99999;


  l_qty_rec_cnt_cor_line_id         NUMBER := -99999;
  l_qty_rec_cnt_cor_all             NUMBER := -99999;
  l_qty_rec_cnt_cor_early           NUMBER := -99999;
  l_qty_rec_cnt_cor_late            NUMBER := -99999;
  l_qty_rec_cnt_cor_early_window    NUMBER := -99999;
  l_qty_rec_cnt_cor_late_window     NUMBER := -99999;
  l_qty_rec_cnt_cor_ondate          NUMBER := -99999;
  l_qty_rec_cnt_cor_substitute      NUMBER := -99999;
  l_qty_rec_num_cor_line_id         NUMBER := -99999;
  l_qty_rec_num_cor_all             NUMBER := -99999;
  l_qty_rec_num_cor_early           NUMBER := -99999;
  l_qty_rec_num_cor_late            NUMBER := -99999;
  l_qty_rec_num_cor_early_window    NUMBER := -99999;
  l_qty_rec_num_cor_late_window     NUMBER := -99999;
  l_qty_rec_num_cor_ondate          NUMBER := -99999;
  l_qty_rec_num_cor_substitute      NUMBER := -99999;



-- ========================================================================
--  get_invoice_date
--
--  Returns the minimum invoice date for all distributions for a line
--     location.
-- ========================================================================

FUNCTION get_invoice_date(p_line_location_id  	NUMBER)
  RETURN DATE
IS
	invoice_date	DATE := NULL;
BEGIN

select  MIN(aid.accounting_date)
into 	invoice_date
from 	po_distributions_all		pod,
	ap_invoice_distributions_all	aid
where 	p_line_location_id	    = pod.line_location_id
AND	aid.po_distribution_id      = pod.po_distribution_id
AND     nvl(pod.distribution_type,'-99') <> 'AGREEMENT';

RETURN(invoice_date);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(invoice_date);
  WHEN OTHERS THEN
    RAISE;

END get_invoice_date;

-- ========================================================================
--  get_days_to_invoice
--
--  Returns the average number of days to invoice for all distributions
--     for a line location.
-- ========================================================================

FUNCTION get_days_to_invoice(p_line_location_id		NUMBER)
  RETURN NUMBER
IS
  v_days 	NUMBER := 0;
BEGIN

select  MIN(aid.accounting_date - pod.creation_date)
into    v_days
from 	po_distributions_all		pod,
	ap_invoice_distributions_all	aid
where 	p_line_location_id	    = pod.line_location_id
AND	aid.po_distribution_id      = pod.po_distribution_id
AND     nvl(pod.distribution_type,'-99')  <> 'AGREEMENT';

RETURN(v_days);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(v_days);
  WHEN OTHERS THEN
    RAISE;

END get_days_to_invoice;


-- ========================================================================
--  get_ipv
--
--  Returns the sum ipv for all distributions
--     for a line location.
-- ========================================================================

FUNCTION get_ipv(p_line_location_id		NUMBER)
  RETURN NUMBER
IS
  v_ipv 	NUMBER := 0;
BEGIN

select  SUM(aid.base_invoice_price_variance / nvl(pod.rate,nvl(poh.rate,1)))
into    v_ipv
from 	po_distributions_all		pod,
	ap_invoice_distributions_all	aid,
	po_headers_all			poh
where 	p_line_location_id	    = pod.line_location_id
AND	aid.po_distribution_id      = pod.po_distribution_id
AND     poh.po_header_id            = pod.po_header_id
AND     nvl(pod.distribution_type,'-99')  <> 'AGREEMENT';

RETURN(v_ipv);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(0);
  WHEN OTHERS THEN
    RAISE;

END get_ipv;



-- ========================================================================
--  get_first_receipt_date
--
--  Returns the first/earliest receipt date for a particular shipment.
-- ========================================================================

FUNCTION get_first_receipt_date(p_line_location_id	NUMBER)
  RETURN DATE
IS
  v_receipt_date 	DATE := NULL;
BEGIN

  SELECT MIN(transaction_date)
  INTO   v_receipt_date
  FROM   rcv_transactions
  WHERE  po_line_location_id = p_line_location_id
  AND    transaction_type    = 'RECEIVE';

  RETURN(v_receipt_date);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(v_receipt_date);
  WHEN OTHERS THEN
    RAISE;

END get_first_receipt_date;



-- ========================================================================
--  get_last_rcv_trx_date
--
--  Returns the last transaction date for a particular shipment.
--  The dates considered are for:
--	- rcv_transactions 	- last_update_date for any transaction type
--	- rcv_shipment_lines 	- last_update_date
--  We should look at last_update_date instead of transaction_date for
--  rcv_transactions because the transaction_date can be in the past, but
--  the data would not be collected yet since it didn't exist then.
--
--  If any of these dates changed the data from the Supplier Performance
--  source view need to be re-collected.
-- ========================================================================

FUNCTION get_last_rcv_trx_date(p_line_location_id	NUMBER)
  RETURN DATE
IS
  v_max_rcv_trx_date 	DATE := NULL;
  v_max_shp_line_date 	DATE := NULL;
  v_line_loc_date	DATE := NULL;
BEGIN

  --
  -- Get max date from rcv_transactions, including corrections
  --
  BEGIN
    SELECT MAX(last_update_date)
    INTO   v_max_rcv_trx_date
    FROM   rcv_transactions
    WHERE  po_line_location_id = p_line_location_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_max_rcv_trx_date := NULL;
  END;

  --
  -- Get max date from rcv_shipment_lines
  --
  BEGIN
    SELECT MAX(last_update_date)
    INTO   v_max_shp_line_date
    FROM   rcv_shipment_lines
    WHERE  po_line_location_id = p_line_location_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_max_shp_line_date := NULL;
  END;

  --
  -- If there are no receipts, both dates will be NULL,
  -- fall back on PO shipment last_update_date.
  -- Returning NULL date here will cause NULL last_update_date
  -- in the calling view.
  --
  BEGIN
    SELECT last_update_date
    INTO   v_line_loc_date
    FROM   po_line_locations_all
    WHERE  line_location_id = p_line_location_id;
  END;

  RETURN(GREATEST(NVL(v_max_rcv_trx_date, v_line_loc_date),
		  NVL(v_max_shp_line_date, v_line_loc_date)));

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END get_last_rcv_trx_date;



-- ========================================================================
--  get_qty_shipped
--
--  Returns the quantity shipped for a particular shipment.
--  The quantity is expressed in the shipment transaction UOM.
-- ========================================================================

FUNCTION get_qty_shipped(p_line_location_id	NUMBER,
			 p_shipment_uom		VARCHAR2)
  RETURN NUMBER
IS
  v_qty_shipped 	NUMBER := 0;
BEGIN

  SELECT SUM(rsl.quantity_shipped *
	     poa_edw_util.get_uom_rate(rsl.item_id,
				       NULL,		    -- precision
				       NULL,		    -- from qty
				       '',		    -- from UOM code
				       '',		    -- to UOM code
				       rsl.unit_of_measure, -- from UOM name
				       p_shipment_uom))     -- to UOM name
  INTO   v_qty_shipped
  FROM   rcv_shipment_lines	rsl
  WHERE  rsl.po_line_location_id = p_line_location_id;

  RETURN(NVL(v_qty_shipped, 0));

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(NVL(v_qty_shipped, 0));
  WHEN OTHERS THEN
    RAISE;

END get_qty_shipped;



-- ========================================================================
--  get_qty_delivered
--
--  Returns the quantity delivered to the requestors for a particular shipment.
--  The quantity is expressed in the shipment transaction UOM.
-- ========================================================================

FUNCTION get_qty_delivered(p_line_location_id	NUMBER)
  RETURN NUMBER
IS
  v_qty_delivered 	NUMBER := 0;
BEGIN

  --
  -- Get quantity delivered
  --
  SELECT SUM(pod.quantity_delivered)
  INTO   v_qty_delivered
  FROM   po_distributions_all 	pod
  WHERE  pod.line_location_id = p_line_location_id
  AND    nvl(pod.distribution_type,'-99') <> 'AGREEMENT';

  RETURN(v_qty_delivered);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(v_qty_delivered);
  WHEN OTHERS THEN
    RAISE;

END get_qty_delivered;



-- ========================================================================
--  get_qty_received
--
--  Returns the quantity received for a particular shipment based on the
--  the type: ALL	  - all receipts
--	      EARLY	  - receipts received before
--				expected date - days early allowed
--	      LATE	  - receipts received after
--				expected date + days late allowed
--	      EARLYWINDOW - receipts received within tolerance but before
--				the expected date
--	      LATEWINDOW  - receipts received within tolerance but after
--				the expected date
--	      ONDATE      - receipts received within tolerance and on the
--              expected date
--	      SUBSTITUTE  - receipts w/ substitute item
--  The quantity is expressed in the shipment transaction UOM.
-- ========================================================================

FUNCTION get_qty_received(p_type		VARCHAR2,
			  p_line_location_id	NUMBER,
			  p_expected_date	DATE,
			  p_days_early_allowed	NUMBER,
			  p_days_late_allowed	NUMBER)
  RETURN NUMBER
IS
  v_transaction_qty	NUMBER := 0;
  v_correction_qty	NUMBER := 0;
  v_qty_received 	NUMBER := 0;
  v_type		VARCHAR2(20) := p_type;
  invalid_type		EXCEPTION;
BEGIN

  IF v_type NOT IN ('ALL', 'EARLY', 'LATE', 'EARLYWINDOW',
		    'LATEWINDOW', 'ONDATE', 'SUBSTITUTE') THEN
    RAISE invalid_type;
  END IF;

  --
  -- For early, late, earlywindow, and latewindow calculation, if there's
  -- no expected date the receipts are considered on time
  --
  IF v_type IN ('EARLY', 'LATE', 'EARLYWINDOW', 'LATEWINDOW') AND
     p_expected_date IS NULL THEN
    RETURN(v_qty_received);
  END IF;

  --
  -- If there's no expected date, consider the receipts to be
  -- on time on the expected date, which is equivalent to 'ALL'
  --

  IF v_type = 'ONDATE' AND p_expected_date IS NULL THEN
    v_type := 'ALL';
  END IF;

    --
    -- Get quantity received
    -- Get correction to the receipt transactions

   IF p_line_location_id <> l_qty_rec_line_id THEN

    l_qty_rec_line_id := p_line_location_id;

    SELECT
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))), -1, rct.source_doc_quantity, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))), 1, rct.source_doc_quantity, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))),-1,0,decode(sign(rct.transaction_date - trunc(p_expected_date)),-1,rct.source_doc_quantity,0))),
       sum(decode(sign(rct.transaction_date - (trunc(p_expected_date)+1)),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,rct.source_doc_quantity))),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,decode(sign(trunc(rct.transaction_date)
            - trunc(p_expected_date)),0,rct.source_doc_quantity,0)))),
       sum(decode(rct.substitute_unordered_code, 'SUBSTITUTE', rct.source_doc_quantity, 0)),
       sum(rct.source_doc_quantity),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))), -1, 1, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))), 1, 1, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))),-1,0,decode(sign(rct.transaction_date - trunc(p_expected_date)),-1,1,0))),
       sum(decode(sign(rct.transaction_date - (trunc(p_expected_date)+1)),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,1))),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,decode(sign(trunc(rct.transaction_date)
            - trunc(p_expected_date)),0,1,0)))),
       sum(decode(rct.substitute_unordered_code, 'SUBSTITUTE', 1, 0)),
       sum(1)
    INTO
    l_qty_rec_cnt_early, l_qty_rec_cnt_late, l_qty_rec_cnt_early_window, l_qty_rec_cnt_late_window, l_qty_rec_cnt_ondate, l_qty_rec_cnt_substitute,
    l_qty_rec_cnt_all, l_qty_rec_num_early, l_qty_rec_num_late, l_qty_rec_num_early_window, l_qty_rec_num_late_window, l_qty_rec_num_ondate, l_qty_rec_num_substitute, l_qty_rec_num_all
    FROM   rcv_transactions     rct
    WHERE  rct.po_line_location_id = p_line_location_id
    AND    rct.transaction_type    = 'RECEIVE';

   END IF;

   IF p_line_location_id <> l_qty_rec_cnt_cor_line_id THEN

    l_qty_rec_cnt_cor_line_id:= p_line_location_id;

    SELECT
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))), -1, rcor.source_doc_quantity, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))), 1, rcor.source_doc_quantity, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))),-1,0,decode(sign(rct.transaction_date - p_expected_date),-1,rcor.source_doc_quantity,0))),
       sum(decode(sign(rct.transaction_date - (trunc(p_expected_date)+1)),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,rcor.source_doc_quantity))),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,decode(sign(trunc(rct.transaction_date)
            - trunc(p_expected_date)),0,rct.source_doc_quantity,0)))),
       sum(decode(rct.substitute_unordered_code, 'SUBSTITUTE', rcor.source_doc_quantity, 0)),
       sum(rcor.source_doc_quantity)
    INTO
      l_qty_rec_cnt_cor_early, l_qty_rec_cnt_cor_late, l_qty_rec_cnt_cor_early_window, l_qty_rec_cnt_cor_late_window, l_qty_rec_cnt_cor_ondate, l_qty_rec_cnt_cor_substitute, l_qty_rec_cnt_cor_all
    FROM   rcv_transactions rcor,
           rcv_transactions rct
    WHERE  rcor.po_line_location_id = p_line_location_id
    AND    rcor.transaction_type    = 'CORRECT'
    AND    rct.transaction_id       = rcor.parent_transaction_id
    AND    rct.transaction_type     = 'RECEIVE';

   END IF;

   IF v_type = 'ALL' THEN
      v_transaction_qty := l_qty_rec_cnt_all;
      v_correction_qty := l_qty_rec_cnt_cor_all;
   END IF;

   IF v_type = 'EARLY' THEN
      v_transaction_qty := l_qty_rec_cnt_early;
      v_correction_qty := l_qty_rec_cnt_cor_early;
   END IF;

   IF v_type = 'LATE' THEN
      v_transaction_qty := l_qty_rec_cnt_late;
      v_correction_qty := l_qty_rec_cnt_cor_late;
   END IF;

   IF v_type = 'EARLYWINDOW' THEN
      v_transaction_qty := l_qty_rec_cnt_early_window;
      v_correction_qty := l_qty_rec_cnt_cor_early_window;
   END IF;

   IF v_type = 'LATEWINDOW' THEN
      v_transaction_qty := l_qty_rec_cnt_late_window;
      v_correction_qty := l_qty_rec_cnt_cor_late_window;
   END IF;

   IF v_type = 'ONDATE' THEN
      v_transaction_qty := l_qty_rec_cnt_ondate;
      v_correction_qty := l_qty_rec_cnt_cor_ondate;
   END IF;

   IF v_type = 'SUBSTITUTE' THEN
      v_transaction_qty := l_qty_rec_cnt_substitute;
      v_correction_qty := l_qty_rec_cnt_cor_substitute;
   END IF;

  v_qty_received := NVL(v_transaction_qty, 0) + NVL(v_correction_qty, 0);

  RETURN(v_qty_received);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(v_qty_received);
  WHEN invalid_type THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE;

END get_qty_received;



-- ========================================================================
--  get_qty_pastdue
--
--  Returns the quantity past-due for a particular shipment.
--
--  A shipment has past-due quantity if today is past the expected date
--     	plus the late days allowed and there are still quantity not received.
--  If there is no expected date the shipment will never be past due.
--
--  The quantity is expressed in the shipment transaction UOM.
-- ========================================================================

FUNCTION get_qty_pastdue(p_line_location_id	NUMBER,
			 p_expected_date	DATE,
		  	 p_days_late_allowed	NUMBER)
  RETURN NUMBER
IS
  v_qty_pastdue 	NUMBER := 0;

BEGIN

  --
  -- If there's no expected date the shipment will never be past due.
  --
  IF p_expected_date IS NULL THEN
    RETURN(v_qty_pastdue);
  END IF;

  --
  -- Calculate past-due quantity
  --

  IF sysdate > (p_expected_date + p_days_late_allowed) THEN

    SELECT pll.quantity - pll.quantity_cancelled - pll.quantity_received
    INTO   v_qty_pastdue
    FROM   po_line_locations_all	pll
    WHERE  pll.line_location_id 	= p_line_location_id
    AND    pll.quantity - pll.quantity_cancelled - pll.quantity_received >= 0;

  ELSE

    v_qty_pastdue := 0;

  END IF;

  RETURN(v_qty_pastdue);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END get_qty_pastdue;



-- ========================================================================
--  get_num_receipts
--
--  Returns the number of receipts for a particular shipment based on the
--  the type: ALL	  - all receipts
--	      EARLY	  - receipts received before
--				expected date - days early allowed
--	      LATE	  - receipts received after
--				expected date + days late allowed
--	      EARLYWINDOW - receipts received within tolerance but before
--				the expected date
--	      LATEWINDOW  - receipts received within tolerance but after
--				the expected date
--	      ONDATE      - receipts received within tolerance and on the
--              expected date
--	      SUBSTITUTE  - receipts w/ substitute item
-- ========================================================================

FUNCTION get_num_receipts(p_type		VARCHAR2,
			  p_line_location_id	NUMBER,
			  p_expected_date	DATE,
			  p_days_early_allowed	NUMBER,
			  p_days_late_allowed	NUMBER)
  RETURN NUMBER
IS
  v_transaction_num	NUMBER := 0;
  v_correction_num	NUMBER := 0;
  v_num_receipts 	NUMBER := 0;
  v_type		VARCHAR2(20) := p_type;
  invalid_type		EXCEPTION;
BEGIN

  IF v_type NOT IN ('ALL', 'EARLY', 'LATE', 'EARLYWINDOW', 'LATEWINDOW',
		    'ONDATE', 'SUBSTITUTE') THEN
    RAISE invalid_type;
  END IF;

  --
  -- For early, late, earlywindow, and latewindow calculation, if there's
  -- no expected date the receipts are considered on time
  --
  IF v_type IN ('EARLY', 'LATE', 'EARLYWINDOW', 'LATEWINDOW') AND
     p_expected_date IS NULL THEN
    RETURN(v_num_receipts);
  END IF;

  IF v_type = 'ONDATE' AND p_expected_date IS NULL THEN
    v_type := 'ALL';
  END IF;

  --
  -- Get number of receipts
  --
  IF p_line_location_id <> l_qty_rec_line_id THEN

    l_qty_rec_line_id := p_line_location_id;

    SELECT
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))), -1, rct.source_doc_quantity, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))), 1, rct.source_doc_quantity, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))),-1,0,decode(sign(rct.transaction_date - trunc(p_expected_date)),-1,rct.source_doc_quantity,0))),
       sum(decode(sign(rct.transaction_date - (trunc(p_expected_date)+1)),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,rct.source_doc_quantity))),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,decode(sign(trunc(rct.transaction_date)
            - trunc(p_expected_date)),0,rct.source_doc_quantity,0)))),
       sum(decode(rct.substitute_unordered_code, 'SUBSTITUTE', rct.source_doc_quantity, 0)),
       sum(rct.source_doc_quantity),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))), -1, 1, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))), 1, 1, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))),-1,0,decode(sign(rct.transaction_date - trunc(p_expected_date)),-1,1,0))),
       sum(decode(sign(rct.transaction_date - (trunc(p_expected_date)+1)),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,1))),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,decode(sign(trunc(rct.transaction_date)
            - trunc(p_expected_date)),0,1,0)))),
       sum(decode(rct.substitute_unordered_code, 'SUBSTITUTE', 1, 0)),
       sum(1)
    INTO
    l_qty_rec_cnt_early, l_qty_rec_cnt_late, l_qty_rec_cnt_early_window, l_qty_rec_cnt_late_window, l_qty_rec_cnt_ondate, l_qty_rec_cnt_substitute,
    l_qty_rec_cnt_all, l_qty_rec_num_early, l_qty_rec_num_late, l_qty_rec_num_early_window, l_qty_rec_num_late_window, l_qty_rec_num_ondate, l_qty_rec_num_substitute, l_qty_rec_num_all
    FROM   rcv_transactions     rct
    WHERE  rct.po_line_location_id = p_line_location_id
    AND    rct.transaction_type    = 'RECEIVE';

  END IF;

  IF v_type = 'ALL' THEN v_transaction_num := l_qty_rec_num_all; END IF;
  IF v_type = 'EARLY' THEN v_transaction_num := l_qty_rec_num_early; END IF;
  IF v_type = 'LATE' THEN v_transaction_num := l_qty_rec_num_late; END IF;
  IF v_type = 'EARLYWINDOW' THEN v_transaction_num := l_qty_rec_num_early_window; END IF;
  IF v_type = 'LATEWINDOW' THEN v_transaction_num := l_qty_rec_num_late_window; END IF;
  IF v_type = 'ONDATE' THEN v_transaction_num := l_qty_rec_num_ondate; END IF;
  IF v_type = 'SUBSTITUTE' THEN v_transaction_num := l_qty_rec_num_substitute; END IF;

  --
  -- Get correction to the receipt transactions.
  --
  -- Since we're counting just the number of receipts, a correction is
  -- counted only when the quantity in the correction transaction matches
  -- (the negative of) the quantity in the original receipt transactions.
  -- In this case the transaction is considered as VOID.
  --

  IF p_line_location_id <> l_qty_rec_num_cor_line_id THEN

    l_qty_rec_num_cor_line_id := p_line_location_id;

    SELECT
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))), -1, 1, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))), 1, 1, 0)),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))), -1, 0, decode(sign(rct.transaction_date - p_expected_date), -1, 1, 0))),
       sum(decode(sign(rct.transaction_date - (trunc(p_expected_date)+1)),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,1))),
       sum(decode(sign(rct.transaction_date - (p_expected_date - nvl(p_days_early_allowed,0))),-1,0,decode(sign(rct.transaction_date - (p_expected_date + nvl(p_days_late_allowed,0))),1,0,decode(sign(trunc(rct.transaction_date)
            - trunc(p_expected_date)),0,1,0)))),
       sum(decode(rct.substitute_unordered_code, 'SUBSTITUTE', 1, 0)),
       sum(1)
    INTO
      l_qty_rec_num_cor_early, l_qty_rec_num_cor_late, l_qty_rec_num_cor_early_window, l_qty_rec_num_cor_late_window, l_qty_rec_num_cor_ondate, l_qty_rec_num_cor_substitute, l_qty_rec_num_cor_all
    FROM   rcv_transactions rcor,
           rcv_transactions rct
    WHERE  rcor.po_line_location_id = p_line_location_id
    AND    rcor.transaction_type    = 'CORRECT'
    AND    rct.transaction_id       = rcor.parent_transaction_id
    AND    rct.transaction_type     = 'RECEIVE'
    AND    rcor.source_doc_quantity + rct.source_doc_quantity
                   < ZERO_TOLERANCE;

  END IF;

   IF v_type = 'ALL' THEN v_correction_num := l_qty_rec_num_cor_all; END IF;
   IF v_type = 'EARLY' THEN v_correction_num := l_qty_rec_num_cor_early; END IF;
   IF v_type = 'LATE' THEN v_correction_num := l_qty_rec_num_cor_late; END IF;
   IF v_type = 'EARLYWINDOW' THEN v_correction_num := l_qty_rec_num_cor_early_window; END IF;
   IF v_type = 'LATEWINDOW' THEN v_correction_num := l_qty_rec_num_cor_late_window; END IF;
   IF v_type = 'ONDATE' THEN v_correction_num := l_qty_rec_num_cor_ondate; END IF;
   IF v_type = 'SUBSTITUTE' THEN v_correction_num := l_qty_rec_num_cor_substitute; END IF;

  v_num_receipts := NVL(v_transaction_num, 0) - NVL(v_correction_num, 0);

  RETURN(v_num_receipts);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(v_num_receipts);
  WHEN invalid_type THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE;

END get_num_receipts;



-- ========================================================================
--  find_best_price
--
--  Returns the best price possible for the shipment line.
--  The price is expressed in the shipment transaction currency code.
--
--  The following documents are checked to find the best possible price:
--	- Blanket POs			(no consideration for CUMULATIVE/
--					 NON CUMULATIVE price break)
--	- Standard POs
--   	- Planned POs
--
--	Date check is against approved_date on the shipment level
--	Standard/Planned use a 6 month +/- spread for date check.
--	Only Approved POs are considered
--	Price = 0 is ignored
--
--  These documents are matched by:
--	- Item
--	- UOM
--	- Currency
--
--  If no matching document are found, the best price returned will be
--  the actual price of the shipment.
-- ========================================================================

FUNCTION find_best_price(p_line_location_id	NUMBER)
  RETURN NUMBER
IS
  v_best_price 		  NUMBER := NULL;
  v_price		  NUMBER := NULL;
  v_item_id               NUMBER := NULL;
  v_unit_meas_lookup_code VARCHAR2(25) := NULL;
  v_currency_code         VARCHAR2(15) := NULL;
  v_approved_date         DATE := NULL;
  v_quantity              NUMBER := NULL;
  v_need_by_date          DATE := NULL;
  v_creation_date         DATE := NULL;

  x_progress		  VARCHAR2(3) := NULL;

  BEGIN

 --
 -- Find the item_id, unit_measure, currency, quantity, approved date
 -- for this p_line_location_id then pass the above values to each cursor to
 -- get the best price (so there is one level less join in the cursor)
 --

       SELECT   pol.item_id, pol.unit_meas_lookup_code, poh.currency_code,
                pll.approved_date, pll.quantity, pll.need_by_date, pll.creation_date  INTO
                v_item_id, v_unit_meas_lookup_code, v_currency_code,
                v_approved_date, v_quantity, v_need_by_date, v_creation_date
        FROM   po_headers_all           poh,
               po_lines_all             pol,
               po_line_locations_all    pll
        WHERE  pll.line_location_id      = p_line_location_id
        AND    pll.po_line_id            = pol.po_line_id
        AND    pol.po_header_id          = poh.po_header_id;

 -- Find the best price

  SELECT min(lowest_price) into v_best_price from
        (SELECT
	DECODE(	poh.currency_code,
		v_currency_code,
		DECODE(pll.shipment_type, 'PRICE BREAK', pll.price_override, 'PLANNED', pll.price_override, pol.unit_price),
		DECODE(	poh.rate_type,
			'User',
                        DECODE(gsob.currency_code,
                               v_currency_code,
                               poh.rate * DECODE(pll.shipment_type, 'PRICE BREAK', pll.price_override, 'PLANNED', pll.price_override, pol.unit_price),
           		       gl_currency_api.convert_amount_sql(
             		        	gsob.currency_code,
             		        	v_currency_code,
             		        	NVL(poh.rate_date, pll.creation_date),
             		        	NULL,
             		        	poh.rate * DECODE(pll.shipment_type, 'PRICE BREAK', pll.price_override, 'PLANNED', pll.price_override, pol.unit_price))),
           		gl_currency_api.convert_amount_sql(
             		       	poh.currency_code,
	     		       	v_currency_code,
             		       	NVL(poh.rate_date, pll.creation_date),
             		       	poh.rate_type,
	     		       	DECODE(pll.shipment_type, 'PRICE BREAK', pll.price_override, 'PLANNED', pll.price_override, pol.unit_price))))
								lowest_price
        FROM   gl_sets_of_books			gsob,
	       financials_system_params_all	fsp,
               po_headers_all			poh,
	       po_lines_all 			pol,
	       po_line_locations_all		pll
        WHERE  pol.item_id               = v_item_id
        AND    pol.unit_meas_lookup_code = v_unit_meas_lookup_code
        AND   ((Nvl(pll.shipment_type,'PRICE BREAK')  = 'PRICE BREAK'
                 AND    v_approved_date    BETWEEN NVL(poh.start_date, Nvl(pll.approved_date,poh.approved_date)) AND NVL(poh.end_date, v_approved_date)
                 AND    pll.po_release_id         IS NULL
                 AND    Nvl(pll.quantity,0)              <= v_quantity
		 AND    Trunc(Nvl(v_need_by_date, v_creation_date))
		        BETWEEN Trunc(Nvl(pll.start_date, Nvl(v_need_by_date, v_creation_date))) AND Nvl(pll.end_date, Nvl(v_need_by_date, v_creation_date))
		 AND    Trunc(v_creation_date) <= Nvl(pol.expiration_date,v_creation_date))
               OR(pll.shipment_type         = 'BLANKET'
                  AND v_approved_date BETWEEN NVL(poh.start_date, pll.approved_date) AND NVL(poh.end_date, v_approved_date)
                  AND pol.unit_price            > 0)
               OR(pll.shipment_type         = 'STANDARD'
                  AND v_approved_date BETWEEN (pll.approved_date - 180)  AND (pll.approved_date + 180)
                  AND pol.unit_price            > 0)
               OR(pll.shipment_type         = 'PLANNED'
                  AND v_approved_date BETWEEN (pll.approved_date - 180) AND (pll.approved_date + 180)
                  AND pol.unit_price            > 0))
	AND    pll.approved_flag(+) 	 = 'Y'
        AND    pll.po_line_id(+)            = pol.po_line_id
        AND    pol.po_header_id          = poh.po_header_id
     	AND    NVL(pll.org_id, fsp.org_id)     = fsp.org_id
	AND    gsob.set_of_books_id	 = fsp.set_of_books_id)
    WHERE lowest_price > 0;

  -- No best price found, set it to the shipment's transaction price

  IF (v_best_price IS NULL) THEN

    x_progress := '005';

    SELECT pll.price_override
    INTO   v_best_price
    FROM   po_line_locations_all   pll
    WHERE  line_location_id      = p_line_location_id;

  END IF;

  RETURN(v_best_price);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END find_best_price;



-- ========================================================================
--  get_rcv_txn_qty
--
--  Returns the quantity received, accepted, or rejected from a shipment line.
--  The quantity is expressed in the shipment transaction UOM.
-- ========================================================================

FUNCTION get_rcv_txn_qty(p_line_location_id  	NUMBER,
                         p_txn_type		VARCHAR2)
  RETURN NUMBER
IS
  v_quantity        	NUMBER := 0;
  v_txn_qty		NUMBER := 0;
  v_correction_qty	NUMBER := 0;
  x_progress		VARCHAR2(3);
  invalid_type		EXCEPTION;
BEGIN

  x_progress := '001';

  IF p_txn_type NOT IN ('RECEIVE', 'ACCEPT', 'REJECT') THEN
    RAISE invalid_type;
  END IF;

  x_progress := '002';

  SELECT SUM(source_doc_quantity)
  INTO   v_txn_qty
  FROM   rcv_transactions
  WHERE  po_line_location_id = p_line_location_id
  AND    transaction_type    = p_txn_type;

  x_progress := '003';

  SELECT SUM(rcor.source_doc_quantity)
  INTO   v_correction_qty
  FROM   rcv_transactions    rcor,
         rcv_transactions    rct
  WHERE  rcor.po_line_location_id = p_line_location_id
  AND    rcor.transaction_type    = 'CORRECT'
  AND    rct.transaction_id	  = rcor.parent_transaction_id
  AND    rct.transaction_type     = p_txn_type;

  v_quantity := NVL(v_txn_qty, 0) +  NVL(v_correction_qty, 0);

  RETURN(v_quantity);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(v_quantity);
  WHEN invalid_type THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE;

END get_rcv_txn_qty;

END poa_edw_supperf;

/
