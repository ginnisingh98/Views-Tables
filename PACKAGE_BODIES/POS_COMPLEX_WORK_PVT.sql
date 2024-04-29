--------------------------------------------------------
--  DDL for Package Body POS_COMPLEX_WORK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_COMPLEX_WORK_PVT" AS
/* $Header: POSVCWOB.pls 120.10 2006/09/12 13:48:07 jbalakri noship $ */


Procedure Get_Po_Amounts (
    	p_api_version     	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
	p_po_header_id		IN	NUMBER,
	x_amt_approved		OUT NOCOPY NUMBER,
	X_amt_billed		OUT NOCOPY NUMBER,
	X_amt_financed		OUT NOCOPY NUMBER,
	X_adv_billed		OUT NOCOPY NUMBER,
	X_progress_pmt		OUT NOCOPY NUMBER,
	X_amt_recouped		OUT NOCOPY NUMBER,
	X_amt_retained		OUT NOCOPY NUMBER,
	X_amt_delivered		OUT NOCOPY NUMBER )
IS

  l_api_name	CONSTANT VARCHAR2(30) := 'GET_PO_AMOUNTS';
  l_api_version	CONSTANT NUMBER := 1.0;

  l_amt_approved NUMBER := 0;
  l_amt_billed NUMBER := 0;
  l_amt_financed NUMBER := 0;
  l_adv_billed NUMBER := 0;
  l_progress_pmt NUMBER := 0;
  l_amt_recouped NUMBER := 0;
  l_amt_retained NUMBER := 0;
  l_amt_delivered NUMBER := 0;

  CURSOR l_amt_approved_csr IS
      select SUM(DECODE(PLL.matching_basis,
               'AMOUNT', NVL(PLL.amount_received, 0),
               'QUANTITY', NVL(PLL.quantity_received, 0)*NVL(PLL.price_override, 0)))
        from PO_LINE_LOCATIONS_ALL PLL
       where PLL.po_header_id = p_po_header_id
         and PLL.payment_type in ('MILESTONE', 'RATE', 'LUMPSUM');


  CURSOR l_amt_billed_csr IS
      select SUM(DECODE(PLL.matching_basis,
               'AMOUNT', NVL(PLL.amount_billed, 0),
               'QUANTITY', NVL(PLL.quantity_billed, 0)*NVL(PLL.price_override, 0)))
        from PO_LINE_LOCATIONS_ALL PLL
       where PLL.po_header_id = p_po_header_id
         and PLL.payment_type <> 'ADVANCE'
         and PLL.shipment_type = 'STANDARD';

  CURSOR l_adv_billed_csr IS
      select sum(NVL(PLL.amount_financed, 0))
        from PO_LINE_LOCATIONS_ALL PLL
       where PLL.po_header_id = p_po_header_id
         and PLL.payment_type = 'ADVANCE'
         and PLL.shipment_type = 'PREPAYMENT';

  CURSOR l_amt_financed_csr IS
  select SUM(DECODE(PLL.matching_basis,
             'AMOUNT', NVL(PLL.amount_financed,0),
             'QUANTITY', NVL(PLL.quantity_financed, 0)*NVL(PLL.price_override, 0)))
    from PO_LINE_LOCATIONS_ALL PLL
   where PLL.po_header_id = p_po_header_id
     and PLL.payment_type in ('MILESTONE', 'RATE', 'LUMPSUM')
     and PLL.shipment_type = 'PREPAYMENT';

  CURSOR l_progress_pmt_csr IS
  select SUM(DECODE(PLL.shipment_type,
          'STANDARD', DECODE(PLL.matching_basis,
             'AMOUNT', NVL(PLL.amount_billed, 0),
             'QUANTITY', NVL(PLL.quantity_billed, 0)*NVL(PLL.price_override, 0)),
          'PREPAYMENT', DECODE(PLL.matching_basis,
             'AMOUNT', NVL(PLL.amount_financed, 0),
             'QUANTITY', NVL(PLL.quantity_financed, 0)*NVL(PLL.price_override, 0))))
    from PO_LINE_LOCATIONS_ALL PLL
   where PLL.po_header_id = p_po_header_id
     and PLL.payment_type in ('MILESTONE', 'RATE', 'LUMPSUM')
     and PLL.shipment_type in('STANDARD', 'PREPAYMENT');   --???

  CURSOR l_amt_recouped_csr IS
  select SUM(DECODE(PLL.matching_basis,
             'AMOUNT', NVL(PLL.amount_recouped, 0),
             'QUANTITY', NVL(PLL.quantity_recouped, 0)*NVL(PLL.price_override, 0)))
    from PO_LINE_LOCATIONS_ALL PLL
   where PLL.po_header_id = p_po_header_id
     and PLL.shipment_type = 'PREPAYMENT';   -- could be advance or financing pp

  CURSOR l_amt_retained_csr IS
  select sum(NVL(PLL.retainage_withheld_amount,0) - NVL(retainage_released_amount,0))
    from PO_LINE_LOCATIONS_ALL PLL
   where PLL.po_header_id = p_po_header_id
     and PLL.payment_type in ('MILESTONE', 'RATE', 'LUMPSUM')
     and PLL.shipment_type = 'STANDARD';


  CURSOR l_amt_delivered_csr IS
  select sum(NVL(RSL.amount, NVL(RSL.quantity_shipped,0)*NVL(PLL.price_override,0)))
    from RCV_SHIPMENT_LINES RSL,
         PO_LINE_LOCATIONS_ALL PLL
   where PLL.po_header_id = p_po_header_id
     and PLL.shipment_type = 'STANDARD'
     and PLL.payment_type = 'DELIVERY'
     and RSL.PO_line_location_id = PLL.line_location_id;
     --and RSL.approval_status in ('APPROVED', 'PROCESSED');

BEGIN
  -- Amount Approved
  OPEN l_amt_approved_csr;
    LOOP
      FETCH l_amt_approved_csr INTO l_amt_approved;
      EXIT WHEN l_amt_approved_csr%NOTFOUND;
    END LOOP;
  CLOSE l_amt_approved_csr;

  X_amt_approved := NVL(l_amt_approved, 0);

  -- Amount Billed
  OPEN l_amt_billed_csr;
    LOOP
      FETCH l_amt_billed_csr INTO l_amt_billed;
      EXIT WHEN l_amt_billed_csr%NOTFOUND;
    END LOOP;
  CLOSE l_amt_billed_csr;

  x_amt_billed := nvl(l_amt_billed, 0);

  -- Advance Billed, matching_basis can only be amount
  OPEN l_adv_billed_csr;
    LOOP
      FETCH l_adv_billed_csr INTO l_adv_billed;
      EXIT WHEN l_adv_billed_csr%NOTFOUND;
    END LOOP;
  CLOSE l_adv_billed_csr;

  x_adv_billed := nvl(l_adv_billed, 0);

  -- Amount Financed: pay item amount financed + advance amount
  OPEN l_amt_financed_csr;
    LOOP
      FETCH l_amt_financed_csr INTO l_amt_financed;
      EXIT WHEN l_amt_financed_csr%NOTFOUND;
    END LOOP;
  CLOSE l_amt_financed_csr;

  X_amt_financed := nvl(l_amt_financed, 0) + x_adv_billed;

  -- Progress Payment : pay item amount billed or financed
  -- Actual pay item PO, Get total pay item amount billed
  OPEN l_progress_pmt_csr;
    LOOP
      FETCH l_progress_pmt_csr INTO l_progress_pmt;
      EXIT WHEN l_progress_pmt_csr%NOTFOUND;
    END LOOP;
  CLOSE l_progress_pmt_csr;

  x_progress_pmt := nvl(l_progress_pmt, 0);

  -- Amount Recouped
  -- From Advances or financing pay items. For Advances, matching basis is AMOUNT
   OPEN l_amt_recouped_csr;
    LOOP
      FETCH l_amt_recouped_csr INTO l_amt_recouped;
      EXIT WHEN l_amt_recouped_csr%NOTFOUND;
    END LOOP;
  CLOSE l_amt_recouped_csr;

  x_amt_recouped := nvl(l_amt_recouped, 0);

  -- Amount Retained, should exclude delivery shipment???
   OPEN l_amt_retained_csr;
    LOOP
      FETCH l_amt_retained_csr INTO l_amt_retained;
      EXIT WHEN l_amt_retained_csr%NOTFOUND;
    END LOOP;
  CLOSE l_amt_retained_csr;

  x_amt_retained := nvl(l_amt_retained, 0);

  -- Amount Delivered: approved amount for actual delivery shipment for financing PO
   OPEN l_amt_delivered_csr;
    LOOP
      FETCH l_amt_delivered_csr INTO l_amt_delivered;
      EXIT WHEN l_amt_delivered_csr%NOTFOUND;
    END LOOP;
  CLOSE l_amt_delivered_csr;

  x_amt_delivered := nvl(l_amt_delivered, 0);

EXCEPTION
  WHEN OTHERS THEN
    	x_amt_approved := 0;
	X_amt_billed := 0;
	X_amt_financed := 0;
	X_adv_billed := 0;
	X_progress_pmt := 0;
	X_amt_recouped := 0;
	X_amt_retained := 0;
	X_amt_delivered	:= 0;

    RAISE;

END Get_Po_Amounts;


Procedure Get_Po_Line_Amounts (
    	p_api_version   IN  NUMBER,
    	p_Init_Msg_List	IN  VARCHAR2,
	p_po_line_id	IN  NUMBER,
	X_amt_delivered	OUT NOCOPY NUMBER,
	X_amt_billed 	OUT NOCOPY NUMBER,
	X_advance_amt 	OUT NOCOPY NUMBER,
	X_adv_billed 	OUT NOCOPY NUMBER,
	X_amt_recouped 	OUT NOCOPY NUMBER )
IS

  l_api_name	CONSTANT VARCHAR2(30) := 'GET_PO_LINE_AMOUNTS';
  l_api_version	CONSTANT NUMBER := 1.0;

  l_amt_delivered 	NUMBER := 0;
  l_amt_billed 		NUMBER := 0;
  l_advance_amt 	NUMBER := 0;
  l_adv_billed 		NUMBER := 0;
  l_amt_recouped 	NUMBER := 0;

  CURSOR l_amt_delivered_csr IS
    select sum(NVL(
                   NVL(RSL.amount,RSL.REQUESTED_AMOUNT),      --5488052
                   NVL(RSL.quantity_shipped,0)*NVL(PLL.price_override,0)
                  )
               )
      from RCV_SHIPMENT_LINES RSL,
           PO_LINE_LOCATIONS_ALL PLL
     where PLL.po_line_id = p_po_line_id
       and PLL.shipment_type = 'STANDARD'
     --5488052  and PLL.payment_type = 'DELIVERY'
       and RSL.PO_line_location_id = PLL.line_location_id
       and RSL.approval_status in ('APPROVED', 'PROCESSED');


  CURSOR l_amt_billed_csr IS
    select SUM(DECODE(PLL.matching_basis,
           'AMOUNT', NVL(PLL.amount_billed, 0),
           'QUANTITY', NVL(PLL.quantity_billed, 0)*NVL(PLL.price_override, 0)))
    from PO_LINE_LOCATIONS_ALL PLL
   where PLL.po_line_id = p_po_line_id
  --5488052   and PLL.payment_type = 'DELIVERY'
     and PLL.shipment_type = 'STANDARD';


  CURSOR l_advance_amt_csr IS
    select PLL.amount
      from PO_LINE_LOCATIONS_ALL PLL
     where PLL.po_line_id = p_po_line_id
       and PLL.payment_type = 'ADVANCE'
       and PLL.shipment_type = 'PREPAYMENT';


  CURSOR l_adv_billed_csr IS
    select PLL.amount_financed
      from PO_LINE_LOCATIONS_ALL PLL
     where PLL.po_line_id = p_po_line_id
       and PLL.payment_type = 'ADVANCE'
       and PLL.shipment_type = 'PREPAYMENT';


  CURSOR l_amt_recouped_csr IS
    select SUM(DECODE(PLL.matching_basis,
             'AMOUNT', NVL(PLL.amount_recouped, 0),
             'QUANTITY', NVL(PLL.quantity_recouped, 0)*NVL(PLL.price_override, 0)))
      from PO_LINE_LOCATIONS_ALL PLL
     where PLL.po_line_id = p_po_line_id
       and PLL.shipment_type = 'PREPAYMENT'; -- could be advance or financ pp


BEGIN

  -- Amount Delivered
   OPEN l_amt_delivered_csr;
    LOOP
      FETCH l_amt_delivered_csr INTO l_amt_delivered;
      EXIT WHEN l_amt_delivered_csr%NOTFOUND;
    END LOOP;
  CLOSE l_amt_delivered_csr;

  x_amt_delivered := nvl(l_amt_delivered, 0);

  -- Amount Billed
  OPEN l_amt_billed_csr;
    LOOP
      FETCH l_amt_billed_csr INTO l_amt_billed;
      EXIT WHEN l_amt_billed_csr%NOTFOUND;
    END LOOP;
  CLOSE l_amt_billed_csr;

  x_amt_billed := nvl(l_amt_billed, 0);


  -- Advance Amount, should have only one
  OPEN l_advance_amt_csr;
    LOOP
      FETCH l_advance_amt_csr INTO l_advance_amt;
      EXIT WHEN l_advance_amt_csr%NOTFOUND;
    END LOOP;
  CLOSE l_advance_amt_csr;

  x_advance_amt := nvl(l_advance_amt, 0);


  -- Advance Billed, matching basis is Amount, only one
  OPEN l_adv_billed_csr;
    LOOP
      FETCH l_adv_billed_csr INTO l_adv_billed;
      EXIT WHEN l_adv_billed_csr%NOTFOUND;
    END LOOP;
  CLOSE l_adv_billed_csr;

  x_adv_billed := nvl(l_adv_billed, 0);


  -- Amount Recouped, from Advances or financing pay items.
  OPEN l_amt_recouped_csr;
    LOOP
      FETCH l_amt_recouped_csr INTO l_amt_recouped;
      EXIT WHEN l_amt_recouped_csr%NOTFOUND;
    END LOOP;
  CLOSE l_amt_recouped_csr;

  x_amt_recouped := nvl(l_amt_recouped, 0);


EXCEPTION
  WHEN OTHERS THEN
    X_amt_delivered := 0;
    X_amt_billed := 0;
    X_advance_amt := 0;
    X_adv_billed := 0;
    X_amt_recouped := 0;

--    RAISE;

END Get_Po_line_Amounts;




Procedure Get_po_ship_amounts (
    	p_api_version     	IN  NUMBER,
    	p_Init_Msg_List		IN  VARCHAR2,
	p_po_line_location_id	IN  NUMBER,
	X_value_percent		OUT NOCOPY NUMBER,
	X_amt_approved		OUT NOCOPY NUMBER )
IS

  l_value_percent	NUMBER := 0;
  l_amt_approved	NUMBER := 0;

  CURSOR l_value_percent_csr IS
    select ROUND(DECODE(PLL.matching_basis,
               'AMOUNT', (NVL(PLL.amount, 0)/POL.amount)*100,
               'QUANTITY', (NVL(PLL.price_override, 0)/POL.unit_price)*100))
      from PO_LINE_LOCATIONS_ARCHIVE_ALL PLL,
           PO_LINES_ARCHIVE_ALL POL
     where PLL.po_line_id = POL.po_line_id
       and PLL.line_location_id = p_po_line_location_id
       and PLL.payment_type = 'MILESTONE'
       and PLL.latest_external_flag ='Y'
       and POL.latest_external_flag ='Y';

  CURSOR l_amt_approved_csr IS
    select DECODE(PLL.matching_basis,
               'AMOUNT', NVL(PLL.amount_received, 0),
               'QUANTITY', NVL(PLL.quantity_received, 0)*NVL(PLL.price_override, 0))
      from PO_LINE_LOCATIONS_ALL PLL
     where PLL.line_location_id = p_po_line_location_id;


BEGIN

  -- Value Percent, only valid for milestone pay items.
  OPEN l_value_percent_csr;
    LOOP
      FETCH l_value_percent_csr INTO l_value_percent;
      EXIT WHEN l_value_percent_csr%NOTFOUND;
    END LOOP;
  CLOSE l_value_percent_csr;

  x_value_percent := nvl(l_value_percent, 0);


  -- Amount Approved
  OPEN l_amt_approved_csr;
    LOOP
      FETCH l_amt_approved_csr INTO l_amt_approved;
      EXIT WHEN l_amt_approved_csr%NOTFOUND;
    END LOOP;
  CLOSE l_amt_approved_csr;

  X_amt_approved := NVL(l_amt_approved, 0);


EXCEPTION
  WHEN OTHERS THEN
    X_value_percent := 0;
    X_amt_approved := 0;

--   RAISE;

END Get_Po_Ship_Amounts;


END POS_COMPLEX_WORK_PVT;

/
