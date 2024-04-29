--------------------------------------------------------
--  DDL for Package Body PO_AP_INVOICE_MATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AP_INVOICE_MATCH_GRP" AS
/* $Header: POXAPINB.pls 120.11.12010000.10 2012/09/10 01:36:34 mazhong ship $*/

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'PO_AP_INVOICE_MATCH_GRP';
D_PACKAGE_BASE CONSTANT VARCHAR2(50) := PO_LOG.get_package_base(G_PKG_NAME);

--<Complex Work R12 START>
-------------------------------------------------------------------------
--Pre-reqs:
--  N/A
--Function:
--  Updates values on the PO line location and distribution due to AP
--  activity (billing, prepayments, recoupment, retainage, etc)
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--IN OUT:
--p_line_loc_changes_rec
--  An object of PO_AP_LINE_LOC_REC_TYPE
--p_dist_changes_rec
--  An object of PO_AP_DIST_REC_TYPE
--OUT:
--x_return_status
--  Apps API param.  Value is VARCHAR2(1)
--  FND_API.G_RET_STS_SUCCESS if update succeeds
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_msg_data
--  Contains the error details in the case of UNEXP_ERROR or ERROR
-------------------------------------------------------------------------
PROCEDURE update_document_ap_values(
  p_api_version			IN		NUMBER
, p_line_loc_changes_rec	IN OUT NOCOPY	PO_AP_LINE_LOC_REC_TYPE
, p_dist_changes_rec		IN OUT NOCOPY	PO_AP_DIST_REC_TYPE
, x_return_status		OUT NOCOPY	VARCHAR2
, x_msg_data			OUT NOCOPY	VARCHAR2
)
IS
  l_api_version CONSTANT NUMBER := 1.0;
  l_api_name CONSTANT VARCHAR2(30) := 'update_document_ap_values';
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_api_name);
  d_position NUMBER := 0;
BEGIN

  -- Standard API Savepoint
  SAVEPOINT update_document_ap_values_SP;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_api_version',p_api_version);
    p_line_loc_changes_rec.dump_to_log;
    p_dist_changes_rec.dump_to_log;
  END IF;

  -- Initialize return status and msg data
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_data := NULL;

  d_position := 10;

  IF (NOT FND_API.compatible_api_call (l_api_version,p_api_version,l_api_name,G_PKG_NAME)) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  d_position := 20;

  -- Invoke methods on the parameter objects that calculate field
  -- values not set by AP when AP created these objects (this also
  -- performs the UOM conversion between AP UOM and PO UOM)
  -- First call the line loc object
  p_line_loc_changes_rec.populate_calculated_fields;

  d_position := 25;

  -- Next call the distribution object
  p_dist_changes_rec.populate_calculated_fields;

  d_position := 30;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Calculated fields populated');
    p_line_loc_changes_rec.dump_to_log;
    p_dist_changes_rec.dump_to_log;
  END IF;

  -- SQL What: Update the AP-related fields on the PO line location
  -- SQL Where: For the line location row represented in p_line_loc_changes_rec
  --            Also, for Scheduled Releases, update the information on the
  --            backing Planned PO line location row as well
  UPDATE po_line_locations_all pll
  SET quantity_billed =
        DECODE(p_line_loc_changes_rec.quantity_billed
               , NULL, quantity_billed
               , nvl(quantity_billed, 0) + p_line_loc_changes_rec.quantity_billed),
      amount_billed =
        DECODE(p_line_loc_changes_rec.amount_billed
               , NULL, amount_billed
               , nvl(amount_billed, 0) + p_line_loc_changes_rec.amount_billed),
      quantity_financed =
        DECODE(p_line_loc_changes_rec.quantity_financed
               , NULL, quantity_financed
               , nvl(quantity_financed, 0) + p_line_loc_changes_rec.quantity_financed),
      amount_financed =
        DECODE(p_line_loc_changes_rec.amount_financed
               , NULL, amount_financed
               , nvl(amount_financed, 0) + p_line_loc_changes_rec.amount_financed),
      quantity_recouped =
        DECODE(p_line_loc_changes_rec.quantity_recouped
               , NULL, quantity_recouped
               , nvl(quantity_recouped, 0) + p_line_loc_changes_rec.quantity_recouped),
      amount_recouped =
        DECODE(p_line_loc_changes_rec.amount_recouped
               , NULL, amount_recouped
               , nvl(amount_recouped, 0) + p_line_loc_changes_rec.amount_recouped),
      retainage_withheld_amount =
        DECODE(p_line_loc_changes_rec.retainage_withheld_amt
               , NULL, retainage_withheld_amount
               , nvl(retainage_withheld_amount, 0) + p_line_loc_changes_rec.retainage_withheld_amt),
      retainage_released_amount =
        DECODE(p_line_loc_changes_rec.retainage_released_amt
               , NULL, retainage_released_amount
               , nvl(retainage_released_amount, 0) + p_line_loc_changes_rec.retainage_released_amt),
      last_update_login = nvl(p_line_loc_changes_rec.last_update_login, last_update_login),
      request_id = nvl(p_line_loc_changes_rec.request_id, request_id),
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.USER_ID
  WHERE pll.line_location_id = p_line_loc_changes_rec.po_line_location_id
     OR (pll.shipment_type = 'PLANNED'
         AND pll.line_location_id =
             (SELECT pll2.source_shipment_id
              FROM   po_line_locations pll2
              WHERE  pll2.shipment_type = 'SCHEDULED'
              AND  pll2.line_location_id = p_line_loc_changes_rec.po_line_location_id)
     )
  ;

  d_position := 40;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Line Locations updated: ' || SQL%ROWCOUNT || '; fnd_global.user_id: ' || fnd_global.user_id);
  END IF;

  -- SQL What: Update the AP-related fields on the PO distribution
  -- SQL Where: For the distribution rows represented in p_dist_changes_rec
  --            Also, for Scheduled Releases, update the information on the
  --            backing Planned PO distribution row as well
  FORALL i IN 1..p_dist_changes_rec.po_distribution_id_tbl.COUNT
  UPDATE po_distributions_all pod
  SET quantity_billed =
        DECODE(p_dist_changes_rec.quantity_billed_tbl(i)
               , NULL, quantity_billed
               , nvl(quantity_billed, 0) + p_dist_changes_rec.quantity_billed_tbl(i)),
      amount_billed =
        DECODE(p_dist_changes_rec.amount_billed_tbl(i)
               , NULL, amount_billed
               , nvl(amount_billed, 0) + p_dist_changes_rec.amount_billed_tbl(i)),
      quantity_financed =
        DECODE(p_dist_changes_rec.quantity_financed_tbl(i)
               , NULL, quantity_financed
               , nvl(quantity_financed, 0) + p_dist_changes_rec.quantity_financed_tbl(i)),
      amount_financed =
        DECODE(p_dist_changes_rec.amount_financed_tbl(i)
               , NULL, amount_financed
               , nvl(amount_financed, 0) + p_dist_changes_rec.amount_financed_tbl(i)),
      quantity_recouped =
        DECODE(p_dist_changes_rec.quantity_recouped_tbl(i)
               , NULL, quantity_recouped
               , nvl(quantity_recouped, 0) + p_dist_changes_rec.quantity_recouped_tbl(i)),
      amount_recouped =
        DECODE(p_dist_changes_rec.amount_recouped_tbl(i)
               , NULL, amount_recouped
               , nvl(amount_recouped, 0) + p_dist_changes_rec.amount_recouped_tbl(i)),
      retainage_withheld_amount =
        DECODE(p_dist_changes_rec.retainage_withheld_amt_tbl(i)
               , NULL, retainage_withheld_amount
               , nvl(retainage_withheld_amount, 0) + p_dist_changes_rec.retainage_withheld_amt_tbl(i)),
      retainage_released_amount =
        DECODE(p_dist_changes_rec.retainage_released_amt_tbl(i)
               , NULL, retainage_released_amount
               , nvl(retainage_released_amount, 0) + p_dist_changes_rec.retainage_released_amt_tbl(i)),
      last_update_login = nvl(p_dist_changes_rec.last_update_login_tbl(i), last_update_login),
      request_id = nvl(p_dist_changes_rec.request_id_tbl(i), request_id),
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.USER_ID
  WHERE pod.po_distribution_id = p_dist_changes_rec.po_distribution_id_tbl(i)
     OR (pod.distribution_type = 'PLANNED'
         AND pod.po_distribution_id =
             (SELECT pod2.source_distribution_id
              FROM   po_distributions pod2
              WHERE pod2.distribution_type = 'SCHEDULED'
              AND   pod2.po_distribution_id = p_dist_changes_rec.po_distribution_id_tbl(i)))
  ;

  d_position := 50;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Distributions updated: ' || SQL%ROWCOUNT || '; fnd_global.user_id: ' || fnd_global.user_id);
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_mod,'x_return_status', x_return_status);
    p_line_loc_changes_rec.dump_to_log;
    p_dist_changes_rec.dump_to_log;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO update_document_ap_values_SP;
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,d_position,SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.set_name('PO', 'PO_ALL_TRACE_ERROR');
    FND_MESSAGE.set_token('FILE', 'POXAPINB.pls');
    FND_MESSAGE.set_token('ERR_NUMBER', SQLERRM(SQLCODE));
    FND_MESSAGE.set_token('SUBROUTINE', l_api_name);
    x_msg_data := FND_MESSAGE.get;

END; --update_document_ap_values


---------------------------------------------------------------------------
--Pre-reqs:
--  All line locations must belong to the same PO document
--Function:
--  Calculate how much to retain against particular line locations, based
--  on the contract terms specified on the PO.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_line_location_id_tbl
--  Table of ids from the set of {existing POLL.line_location}
--  All ids must belong to the same PO document
--p_line_loc_match_amt_tbl
--  Each tbl entry corresponds to 1 entry (w/ same index) in
--  p_line_location_id_tbl.  It passes in the amount being matched against
--  each line location in this trxn
--  The amount must be passed in using the PO currency
--OUT:
--x_return_status
--  Apps API Std param.  Value is VARCHAR2(1)
--  FND_API.G_RET_STS_SUCCESS if calculation succeeds
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_msg_data
--  Contains the error details in the case of UNEXP_ERROR or ERROR
--x_amount_to_retain_tbl
--  Each tbl entry corresponds to 1 entry (with same index) in
--  p_line_location_id_tbl.  It returns the calculated amount to retain
--  against each line location
-------------------------------------------------------------------------
PROCEDURE get_amount_to_retain(
  p_api_version			IN		NUMBER
, p_line_location_id_tbl	IN		po_tbl_number
, p_line_loc_match_amt_tbl	IN		po_tbl_number
, x_return_status		OUT NOCOPY	VARCHAR2
, x_msg_data			OUT NOCOPY	VARCHAR2
, x_amount_to_retain_tbl	OUT NOCOPY	po_tbl_number
)
IS
  l_api_version CONSTANT NUMBER := 1.0;
  l_api_name CONSTANT VARCHAR2(30) := 'get_amount_to_retain';
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,l_api_name);
  d_position NUMBER := 0;
  l_gt_key NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_api_version',p_api_version);
  PO_LOG.proc_begin(d_mod,'p_line_location_id_tbl',p_line_location_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_line_loc_match_amt_tbl',p_line_loc_match_amt_tbl);
END IF;

  -- Initialize out parameters
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_data := NULL;
  x_amount_to_retain_tbl:= po_tbl_number();
  x_amount_to_retain_tbl.extend;

  d_position := 10;

  IF (NOT FND_API.compatible_api_call (l_api_version,p_api_version,l_api_name,G_PKG_NAME)) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  d_position := 20;

  SELECT PO_SESSION_GT_S.nextval
  INTO l_gt_key
  FROM dual;

  d_position := 30;

  -- Calculate the amount to retain against each line location
  -- based on the retainage rate.  Use the GTT to do the calculation
  -- in bulk

  --Bug 5524978: Modified Logic to fcator in that max_retainage_amount can be NULL
  --Bug 5549067: Used NVL around PO_LINES_INT.retained_amount
  -- Bug 13443523 -start
     FORALL i IN 1 .. p_line_location_id_tbl.COUNT
	    INSERT INTO PO_SESSION_GT GTT(
	    key,
	    num1, -- Shipment Id on the current Invoice
	    num2, -- Line Id on the current Invoice
	    num3, -- CurrenT Invoice Amount at Shipment Level
	    num6, -- Retainage Rate for the Line
	    num7  -- Maximum Retainage Amount for the Line
	    )
	    SELECT
	        l_gt_key,
	        p_line_location_id_tbl(i),
	        pl.po_line_id,
	        p_line_loc_match_amt_tbl(i),
	        pl.retainage_rate,
	        pl.max_retainage_amount
	    FROM po_lines_all pl,
	        po_line_locations_all pll
	    where pl.po_line_id = pll.po_line_id
	  and pll.line_location_id = p_line_location_id_tbl(i);

    -- SumAmtInvoiced_Line_Session (SIALS)
	UPDATE PO_SESSION_GT GTO
	SET GTO.NUM4 = (SELECT SUM(GTI.NUM3)
			FROM PO_SESSION_GT GTI
		       WHERE GTI.num2 = GTO.num2);


	-- Sum of Retained Amount at Line(SRAL)
	UPDATE PO_SESSION_GT GTO
	SET GTO.NUM5 = (SELECT SUM(Nvl(pll.retainage_withheld_amount,0))
			   FROM po_line_locations_all PLL
		       WHERE PLL.po_line_id = GTO.num2);

	-- Calculated Retainable Amount for the Current Session (CRAS)
	UPDATE PO_SESSION_GT GTO
	SET GTO.NUM8 = (SELECT GTI.NUM4*GTI.NUM6/100
			FROM PO_SESSION_GT GTI
		       WHERE GTI.num2 = GTO.num2);

   FOR CREC IN (SELECT * FROM PO_SESSION_GT GTT WHERE GTT.key = l_gt_key ORDER BY GTT.num1)
	LOOP

	    --#1: Check if the Max retainage Amount is defined and is less than the total retained amount calculated
	    -- In this case we need to retain only the difference betweem Max. Retained Amount and Already Retained Amount

	    IF CREC.NUM7 IS NOT NULL AND
	    CREC.NUM7 >= 0 AND
	    CREC.NUM8 >= 0 AND
	    CREC.NUM5+CREC.NUM8 > CREC.NUM7 THEN
	    --CREC.NUM9 := CREC.NUM7-CREC.NUM5;
          UPDATE PO_SESSION_GT GTO
	          SET GTO.NUM9 = CREC.NUM7-CREC.NUM5
		      WHERE GTO.num1 = CREC.num1;

	    --#2: If calculated retainage amount is negative and more than sum of the retained amount at line level,
	    -- then we will just release sum of retained amount.

	    ELSIF CREC.NUM8 < 0 AND
	          CREC.NUM5+CREC.NUM8 < 0 THEN
	          -- CREC.NUM9 := -CREC.NUM5;
            UPDATE PO_SESSION_GT GTO
	            SET GTO.NUM9 = -CREC.NUM5
		        WHERE GTO.num1 = CREC.num1  ;
	    --#3: For any other case, calculated retainage amount can be assigned to the Adjustable Retainable Amount.
	    ELSE
	     -- CREC.NUM9 := CREC.NUM8;
       UPDATE PO_SESSION_GT GTO
	          SET GTO.NUM9 = CREC.NUM8
		   WHERE GTO.num1 = CREC.num1;
	    END IF;
	END LOOP;

  --Prorated Retainable Amount per Record (PRAR)
  UPDATE PO_SESSION_GT GTO
  SET GTO.NUM10 = (SELECT (GTI.NUM3/GTI.NUM4)*GTI.NUM9
		                FROM PO_SESSION_GT GTI
		               WHERE GTI.num1 = GTO.num1);

-- Bug 13443523 -End
  d_position := 40;

  -- Retrieve the results from the GT into the plsql table out param
  SELECT GTT.NUM10
  BULK COLLECT INTO x_amount_to_retain_tbl
  FROM PO_SESSION_GT GTT
  WHERE GTT.key = l_gt_key
  ORDER BY GTT.num1  --input and output tbls have same ordering
  ;

  d_position := 50;

  -- Clean up the GT by deleting the data
  DELETE FROM PO_SESSION_GT GTT WHERE GTT.key = l_gt_key;

  d_position := 60;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_return_status',x_return_status);
  PO_LOG.proc_end(d_mod,'x_amount_to_retain_tbl',x_amount_to_retain_tbl);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,d_position,SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.set_name('PO', 'PO_ALL_TRACE_ERROR');
    FND_MESSAGE.set_token('FILE', 'POXAPINB.pls');
    FND_MESSAGE.set_token('ERR_NUMBER', SQLERRM(SQLCODE));
    FND_MESSAGE.set_token('SUBROUTINE', l_api_name);
    x_msg_data := FND_MESSAGE.get;

END; --get_amount_to_retain
--<Complex Work R12 END>



---------------------------------------------------------------------------------------------
--Start of Comments
--Name:         get_po_ship_amounts
--
--Pre-reqs:     None
--
--Modifies:     None
--
--Locks:        None
--
--Function:     This procedure provides AP with ordered and cancelled amounts on the PO
--              shipments for amount matching purposes
--
--
--Parameters:
--IN:
--   p_api_version
--      Specifies the version of the api. Value that needs to be passed inis 1.0
--   p_receive_transaction_id
--      Specifies the receive transaction id for which the amounts need to be retrieved
--      from the corresponding shipments
--OUT:
--   x_ship_amt_ordered
--      The amount on the PO shipment corresponding to the rcv transaction id passed
--   x_ship_amt_cancelled
--      The cancelled amount on the PO shipment corresponding to the rcv transaction
--      id passed
--   x_ret_status
--      (a) FND_API.G_RET_STS_SUCCESS if successful
--      (b) FND_API.G_RET_STS_ERROR if known error occurs
--      (c) FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--   x_msg_count
--      The number of error messages to be returned (1 in this case)
--   x_msg_data
--      The error message if the msg ct > 0 should be retrieved using FND_MSG_PUB.get
--
--Testing:  -
--End of Comments
-------------------------------------------------------------------------------------------------

PROCEDURE get_po_ship_amounts (p_api_version              IN          NUMBER,
                               p_receive_transaction_id   IN          RCV_TRANSACTIONS.transaction_id%TYPE,
                               x_ship_amt_ordered         OUT NOCOPY  PO_LINE_LOCATIONS_ALL.amount%TYPE,
                               x_ship_amt_cancelled       OUT NOCOPY  PO_LINE_LOCATIONS_ALL.amount_cancelled%TYPE,
                               x_ret_status               OUT NOCOPY  VARCHAR2,
                               x_msg_count                OUT NOCOPY  NUMBER,
                               x_msg_data                 OUT NOCOPY  VARCHAR2)  IS

l_api_name              CONSTANT VARCHAR2(30) := 'get_po_ship_amounts';
l_api_version           CONSTANT NUMBER := 1.0;

BEGIN

    -- Initialize return status and msg data
    x_ret_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count  := 0;
    x_msg_data   := NULL;

    IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) ) THEN
        x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    -- SQL What : Gets the amount and amount cancelled on the PO shipments corresponding to the
    --            Receive transaction_id
    -- SQL Why  : These amounts are used for amount based mathing on receipts

       SELECT pll.amount,
              pll.amount_cancelled
       INTO   x_ship_amt_ordered,
              x_ship_amt_cancelled
       FROM   po_line_locations pll,
              rcv_transactions rt
       WHERE  rt.po_line_location_id = pll.line_location_id
       AND    rt.transaction_id = p_receive_transaction_id;

EXCEPTION
   WHEN OTHERS THEN
      x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;


-----------------------------------------------------------------------------------------------
--Start of Comments
--Name:         get_po_dist_amounts
--
--Pre-reqs:     None
--
--Modifies:     None
--
--Locks:        None
--
--Function:     This procedure provides AP with ordered and cancelled amounts on the PO
--              distributions for amount matching purposes
--
--
--Parameters:
--IN:
--   p_api_version
--      Specifies the version of the api. Value that needs to be passed inis 1.0
--   p_po_distribution_id
--      Specifies the distributions id for which the amounts need to be retrieved
--
--OUT:
--   x_dist_amt_ordered
--      The amount ordered on the PO distribution
--   x_dist_amt_cancelled
--      The cancelled amount on the PO distribution
--   x_ret_status
--      (a) FND_API.G_RET_STS_SUCCESS if successful
--      (b) FND_API.G_RET_STS_ERROR if known error occurs
--      (c) FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--   x_msg_count
--      The number of error messages to be returned (1 in this case)
--   x_msg_data
--      The error message if the msg ct > 0 should be retrieved using FND_MSG_PUB.get
--
--
--Testing:  -
--End of Comments
----------------------------------------------------------------------------------------

PROCEDURE get_po_dist_amounts (p_api_version              IN          NUMBER,
                               p_po_distribution_id       IN          PO_DISTRIBUTIONS_ALL.po_distribution_id%TYPE,
                               x_dist_amt_ordered         OUT NOCOPY  PO_DISTRIBUTIONS_ALL.amount_ordered%TYPE,
                               x_dist_amt_cancelled       OUT NOCOPY  PO_DISTRIBUTIONS_ALL.amount_cancelled%TYPE,
                               x_ret_status               OUT NOCOPY  VARCHAR2,
                               x_msg_count                OUT NOCOPY  NUMBER,
                               x_msg_data                 OUT NOCOPY  VARCHAR2)  IS

l_api_name              CONSTANT VARCHAR2(30) := 'get_po_dist_amounts';
l_api_version           CONSTANT NUMBER := 1.0;

BEGIN

   -- Initialize return status and msg data
    x_ret_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count  := 0;
    x_msg_data   := NULL;

    IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) ) THEN
        x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    -- SQL What : Gets the amountordered  and amount cancelled on the PO distributions
    --            corresponding to the distribution id passed
    -- SQL Why  : These amounts are used for amount based matching of invoices

       SELECT pod.amount_ordered,
              pod.amount_cancelled
       INTO   x_dist_amt_ordered,
              x_dist_amt_cancelled
       FROM   po_distributions pod
       WHERE  pod.po_distribution_id = p_po_distribution_id;

EXCEPTION
   WHEN OTHERS THEN
      x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

---------------------------------------------------------------------------------------
--Start of Comments
--Name:         update_po_ship_amounts
--
--Pre-reqs:     None
--
--Modifies:     PO_LINE_LOCATIONS_ALL
--
--Locks:        None
--
--Function:     This procedure updates the amount billed on po shipments during amount matching process
--
--Parameters:
--IN:
--   p_api_version
--      Specifies the version of the api. Value that needs to be passed inis 1.0
--   p_po_line_location_id
--      Specifies the line location id for which the amounts need updated
--
--OUT:
--   x_dist_amt_billed
--      The amount billed to be updated on the PO Shipment
--   x_ret_status
--      (a) FND_API.G_RET_STS_SUCCESS if successful
--      (b) FND_API.G_RET_STS_ERROR if known error occurs
--      (c) FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--   x_msg_count
--      The number of error messages to be returned (1 in this case)
--   x_msg_data
--      The error message if the msg ct > 0 should be retrieved using FND_MSG_PUB.get
--
--
--Testing:  -
--End of Comments
------------------------------------------------------------------------------------------------

PROCEDURE update_po_ship_amounts (p_api_version              IN          NUMBER,
                                  p_po_line_location_id      IN          PO_LINE_LOCATIONS_ALL.line_location_id%TYPE,
                                  p_ship_amt_billed          IN          PO_LINE_LOCATIONS_ALL.amount_billed%TYPE,
                                  x_ret_status               OUT NOCOPY  VARCHAR2,
                                  x_msg_count                OUT NOCOPY  NUMBER,
                                  x_msg_data                 OUT NOCOPY  VARCHAR2)   IS

l_api_name              CONSTANT VARCHAR2(30) := 'update_po_ship_amounts';
l_api_version           CONSTANT NUMBER := 1.0;

BEGIN

    -- Initialize return status and msg data
    x_ret_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count  := 0;
    x_msg_data   := NULL;

    IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) ) THEN
        x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    -- SQL What : Updates the amount billed on the po shipments
    -- SQL Why  : This is the amount that was billed against this shipment

       UPDATE po_line_locations_all
       SET    amount_billed = nvl(amount_billed,0) + nvl(p_ship_amt_billed,0)
       WHERE  line_location_id = p_po_line_location_id;


EXCEPTION
   WHEN OTHERS THEN
      x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

-----------------------------------------------------------------------------------------------------
--Start of Comments
--Name:         update_po_dist_amounts
--
--Pre-reqs:     None
--
--Modifies:     PO_DISTRIBUTIONS_ALL
--
--Locks:        None
--
--Function:     This procedure updates the amount billed on po distributions during amount matching process
--
--
--Parameters:
--IN:
--   p_api_version
--      Specifies the version of the api. Value that needs to be passed inis 1.0
--   p_po_distribution_id
--      Specifies the distributions id for which the amounts need updated
--
--OUT:
--   x_dist_amt_billed
--      The amount billed to be updated on the PO distribution
--   x_ret_status
--      (a) FND_API.G_RET_STS_SUCCESS if successful
--      (b) FND_API.G_RET_STS_ERROR if known error occurs
--      (c) FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--   x_msg_count
--      The number of error messages to be returned (1 in this case)
--   x_msg_data
--      The error message if the msg ct > 0 should be retrieved using FND_MSG_PUB.get
--
--Testing:  -
--End of Comments
-------------------------------------------------------------------------------------------------------

PROCEDURE update_po_dist_amounts (p_api_version              IN          NUMBER,
                                  p_po_distribution_id       IN          PO_DISTRIBUTIONS_ALL.po_distribution_id%TYPE,
                                  p_dist_amt_billed          IN          PO_DISTRIBUTIONS_ALL.amount_billed%TYPE,
                                  x_ret_status               OUT NOCOPY  VARCHAR2,
                                  x_msg_count                OUT NOCOPY  NUMBER,
                                  x_msg_data                 OUT NOCOPY  VARCHAR2)   IS

l_api_name              CONSTANT VARCHAR2(30) := 'update_po_dist_amounts';
l_api_version           CONSTANT NUMBER := 1.0;

BEGIN

    -- Initialize return status and msg data
    x_ret_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count  := 0;
    x_msg_data   := NULL;

    IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) ) THEN
        x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    -- SQL What : Updates the amount billed on the po distribution
    -- SQL Why  : This is the amount that was billed against this distribution

       UPDATE po_distributions_all
       SET    amount_billed = nvl(amount_billed,0) + nvl(p_dist_amt_billed,0)
       WHERE  po_distribution_id = p_po_distribution_id;

EXCEPTION
   WHEN OTHERS THEN
      x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

---------------------------------------------------------------------------------------
--Start of Comments
--Created	02/09/04 Sanjay Chitlapilly
--
--Name:         set_final_match_flag
--
--Pre-reqs:     None
--
--Modifies:     PO_LINE_LOCATIONS_ALL
--
--Locks:        None
--
--Function:     This procedure updates the final_match_flag on po shipments when an invoice is finally matched.

--
--Parameters:
--IN:
--   p_api_version
--                Specifies the version of the api. Value that needs to be passed in is 1.0
--   p_entity_type
--	          Possible values: PO_HEADERS, PO_LINES, PO_LINE_LOCATIONS, PO_DISTRIBUTIONS
--	          PO_LINE_LOCATIONS only supported currently.
--   p_entity_id_tbl
--	          This will have one or more ids that you want to set the final match flag value.
--   p_final_match_flag
--	          Possible Values: Y or N
--   p_init_msg_list (Optional) (Default FALSE)
--		  Allows API callers to request the initialization of the message list.
--   p_commit (Optional) (Default FALSE)
--		  Allows API callers to ask the API to commit on their behalf after performing its function.
--
--OUT:
--   x_ret_status
--      (a) FND_API.G_RET_STS_SUCCESS if successful
--      (b) FND_API.G_RET_STS_ERROR if known error occurs
--      (c) FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--   x_msg_count
--      The number of error messages to be returned (1 in this case)
--   x_msg_data
--      The error message if the msg ct > 0 should be retrieved using FND_MSG_PUB.get
--
--
--End of Comments
------------------------------------------------------------------------------------------------

PROCEDURE set_final_match_flag (p_api_version              IN          	NUMBER					,
                                p_entity_type		   IN          	VARCHAR2				,
                                p_entity_id_tbl            IN          	PO_TBL_NUMBER				,
				p_final_match_flag	   IN          	PO_LINE_LOCATIONS.FINAL_MATCH_FLAG%TYPE	,
				p_init_msg_list		   IN          	VARCHAR2 := FND_API.G_FALSE		,
				p_commit                   IN	       	VARCHAR2 := FND_API.G_FALSE		,
                                x_ret_status               OUT NOCOPY	VARCHAR2				,
                                x_msg_count                OUT NOCOPY  	NUMBER					,
                                x_msg_data                 OUT NOCOPY  	VARCHAR2				) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'set_final_match_flag';
    l_api_version	CONSTANT NUMBER := 1.0;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   set_final_match_flag_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return status and msg data
    x_ret_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count  := 0;
    x_msg_data   := NULL;

    IF (NOT FND_API.compatible_api_call (l_api_version,p_api_version,l_api_name,G_PKG_NAME)) THEN

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF p_entity_type <> 'PO_LINE_LOCATIONS' THEN

	RAISE FND_API.G_EXC_ERROR;

    ELSE
        -- SQL What : Updates the final_match_flag on the po shipments
        -- SQL Why  : This is to indicate the shipment has been finally matched by an invoice.

	FORALL i IN 1 .. p_entity_id_tbl.COUNT

	       UPDATE po_line_locations_all
	       SET    final_match_flag = p_final_match_flag
	       WHERE  line_location_id = p_entity_id_tbl(i);

    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (p_count =>  x_msg_count,
			       p_data  =>  x_msg_data );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	ROLLBACK TO set_final_match_flag_PVT;
	x_ret_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				   p_data  => x_msg_data );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	ROLLBACK TO set_final_match_flag_PVT;
        x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				   p_data  => x_msg_data );

    WHEN OTHERS THEN

	ROLLBACK TO set_final_match_flag_PVT;
	x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				   p_data  => x_msg_data );

END set_final_match_flag;


END PO_AP_INVOICE_MATCH_GRP;

/
