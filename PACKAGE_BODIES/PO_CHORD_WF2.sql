--------------------------------------------------------
--  DDL for Package Body PO_CHORD_WF2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHORD_WF2" AS
/* $Header: POXWCO2B.pls 120.4 2006/03/30 15:44:43 dreddy noship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

PROCEDURE chord_lines(itemtype IN VARCHAR2,
		      itemkey  IN VARCHAR2,
		      actid    IN NUMBER,
		      funcmode IN VARCHAR2,
		      result   OUT NOCOPY VARCHAR2)
IS
	x_lines_control		t_lines_control_type;
	x_lines_parameters	t_lines_parameters_type;
BEGIN

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In Procedure: chord_lines ***' );
	END IF;

	IF funcmode <> 'RUN' THEN
		result := 'COMPLETE';
		return;
	END IF;

	get_wf_lines_parameters(itemtype, itemkey, x_lines_parameters);

	check_lines_change(itemtype, itemkey, x_lines_parameters, x_lines_control);

	set_wf_lines_control(itemtype, itemkey, x_lines_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish: chord_lines ***' );
	END IF;

	result := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
	return;

EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_chord_wf2.chord_lines', 'others');
  RAISE;

END;

PROCEDURE check_lines_change(itemtype	IN VARCHAR2,
			     itemkey    IN VARCHAR2,
			     x_lines_parameters IN  t_lines_parameters_type,
			     x_lines_control IN OUT NOCOPY t_lines_control_type)
IS
  x_po_header_id			NUMBER;
  l_currency_code   VARCHAR2(15);
  l_min_acct_unit   VARCHAR2(15);
  l_precision       VARCHAR2(15);

BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In Procedure: check_lines_change ***' );
	END IF;

		/* To use change order,
		 * System should have Archive on Approval set
		 */

		/* initialize */
		x_lines_control.line_num		:='N';
		x_lines_control.item_id			:='N';
		x_lines_control.item_revision		:='N';
		x_lines_control.category_id		:='N';
		x_lines_control.item_description	:='N';
		x_lines_control.unit_meas_lookup_code	:='N';
		x_lines_control.un_number_id		:='N';
		x_lines_control.hazard_class_id		:='N';
		x_lines_control.note_to_vendor		:='N';
		x_lines_control.from_header_id		:='N';
		x_lines_control.from_line_id		:='N';
		x_lines_control.closed_code		:='N';
		x_lines_control.vendor_product_num	:='N';
		x_lines_control.contract_num		:='N';
		x_lines_control.price_type_lookup_code	:='N';
		x_lines_control.cancel_flag		:='N';
                x_lines_control.end_date		:='N';


    -- <Complex Work R12 Start>
    x_lines_control.retainage_rate := 'N';
    x_lines_control.max_retainage_amount := 'N';
    x_lines_control.progress_payment_rate := 'N';
    x_lines_control.recoupment_rate := 'N';
    x_lines_control.advance_amount := 'N';
    -- <Complex Work R12 End>

	        x_lines_control.quantity_change		  :=0;
	        x_lines_control.unit_price_change	  :=0;
		x_lines_control.quantity_committed_change :=0;
		x_lines_control.committed_amount_change	  :=0;
		x_lines_control.not_to_exceed_price_change:=0;
                x_lines_control.amount_change		  :=0; --<R12 Requester Driven Procurement>
                x_lines_control.start_date_change         :=0; --<R12 Requester Driven Procurement>
                x_lines_control.end_date_change		  :=0; --<R12 Requester Driven Procurement>

		x_po_header_id	  := x_lines_parameters.po_header_id;

   BEGIN
                 -- SQL What: Select 'Y' if line number is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, line_num
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.line_num
                 FROM  PO_LINES POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.line_num <> POLA.line_num)
                 OR (POL.line_num IS NULL AND POLA.line_num IS NOT NULL)
                 OR (POL.line_num IS NOT NULL AND POLA.line_num IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.line_num :='N';
   END;


   BEGIN
                 -- SQL What: Select 'Y' if item id is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, item_id
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.item_id
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.item_id <> POLA.item_id)
                 OR (POL.item_id IS NULL AND POLA.item_id IS NOT NULL)
                 OR (POL.item_id IS NOT NULL AND POLA.item_id IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.item_id :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if item revision is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, item_revision
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.item_revision
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.item_revision <> POLA.item_revision)
                 OR (POL.item_revision IS NULL AND POLA.item_revision IS NOT NULL)
                 OR (POL.item_revision IS NOT NULL AND POLA.item_revision IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.item_revision :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if category is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, category_id
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.category_id
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.category_id <> POLA.category_id)
                 OR (POL.category_id IS NULL AND POLA.category_id IS NOT NULL)
                 OR (POL.category_id IS NOT NULL AND POLA.category_id IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.category_id :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if item description is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, item_description
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.item_description
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.item_description <> POLA.item_description)
                 OR (POL.item_description IS NULL AND POLA.item_description IS NOT NULL)
                 OR (POL.item_description IS NOT NULL AND POLA.item_description IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.item_description :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if UOM is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, unit_meas_lookup_code
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.unit_meas_lookup_code
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.unit_meas_lookup_code <> POLA.unit_meas_lookup_code)
                 OR (POL.unit_meas_lookup_code IS NULL AND POLA.unit_meas_lookup_code IS NOT NULL)
                 OR (POL.unit_meas_lookup_code IS NOT NULL AND POLA.unit_meas_lookup_code IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.unit_meas_lookup_code :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if UN Number is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, un_number_id
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.un_number_id
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.un_number_id <> POLA.un_number_id)
                 OR (POL.un_number_id IS NULL AND POLA.un_number_id IS NOT NULL)
                 OR (POL.un_number_id IS NOT NULL AND POLA.un_number_id IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.un_number_id :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if hazard class is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, hazard_class_id
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.hazard_class_id
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.hazard_class_id <> POLA.hazard_class_id)
                 OR (POL.hazard_class_id IS NULL AND POLA.hazard_class_id IS NOT NULL)
                 OR (POL.hazard_class_id IS NOT NULL AND POLA.hazard_class_id IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.hazard_class_id :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if note to vendor is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, note_to_vendor
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.note_to_vendor
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.note_to_vendor <> POLA.note_to_vendor)
                 OR (POL.note_to_vendor IS NULL AND POLA.note_to_vendor IS NOT NULL)
                 OR (POL.note_to_vendor IS NOT NULL AND POLA.note_to_vendor IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.note_to_vendor :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if source document id is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, from_header_id
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.from_header_id
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.from_header_id <> POLA.from_header_id)
                 OR (POL.from_header_id IS NULL AND POLA.from_header_id IS NOT NULL)
                 OR (POL.from_header_id IS NOT NULL AND POLA.from_header_id IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.from_header_id :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if from line id is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, from_line_id
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.from_line_id
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.from_line_id <> POLA.from_line_id)
                 OR (POL.from_line_id IS NULL AND POLA.from_line_id IS NOT NULL)
                 OR (POL.from_line_id IS NOT NULL AND POLA.from_line_id IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.from_line_id :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if closed code is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, closed_code
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.closed_code
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.closed_code <> POLA.closed_code)
                 OR (POL.closed_code IS NULL AND POLA.closed_code IS NOT NULL)
                 OR (POL.closed_code IS NOT NULL AND POLA.closed_code IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.closed_code :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if vendor product number is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, vendor_product_num
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.vendor_product_num
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.vendor_product_num <> POLA.vendor_product_num)
                 OR (POL.vendor_product_num IS NULL AND POLA.vendor_product_num IS NOT NULL)
                 OR (POL.vendor_product_num IS NOT NULL AND POLA.vendor_product_num IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.vendor_product_num :='N';
   END;

   BEGIN
                 -- <GC FPJ>
                 -- SQL What: Select 'Y' if contract number is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, contract_id
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.contract_num
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.contract_id <> POLA.contract_id)
                 OR (POL.contract_id IS NULL
                     AND POLA.contract_id IS NOT NULL)
                 OR (POL.contract_id IS NOT NULL
                     AND POLA.contract_id IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.contract_num :='N';
   END;


   BEGIN
                 -- SQL What: Select 'Y' if Price lookup code is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, price_type_lookup_code
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.price_type_lookup_code
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.price_type_lookup_code <> POLA.price_type_lookup_code)
                 OR (POL.price_type_lookup_code IS NULL AND POLA.price_type_lookup_code IS NOT NULL)
                 OR (POL.price_type_lookup_code IS NOT NULL AND POLA.price_type_lookup_code IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.price_type_lookup_code :='N';
   END;

   BEGIN
                 -- SQL What: Select 'Y' if cancel flag is changed
                 -- SQL Why: Need the value for routing to reapproval
                 --          if there is a change
                 -- SQL Join: po_line_id, cancel_flag
                 SELECT DISTINCT 'Y'
                 INTO  x_lines_control.cancel_flag
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y'
                 AND (
                     (POLA.po_line_id is NULL)
                 OR (POL.cancel_flag <> POLA.cancel_flag)
                 OR (POL.cancel_flag IS NULL AND POLA.cancel_flag IS NOT NULL)
                 OR (POL.cancel_flag IS NOT NULL AND POLA.cancel_flag IS NULL)
		 );
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.cancel_flag :='N';
   END;

   -- <Complex Work R12 Start>

   BEGIN

     -- SQL What: Select 'Y' if line's retainage rate has changed
     -- SQL Why: Need the value for routing to reapproval if there is a change
     -- SQL Join: po_line_id

     SELECT DISTINCT 'Y'
     INTO x_lines_control.retainage_rate
     FROM po_lines_all pol,
          po_lines_archive_all pola
     WHERE pol.po_header_id = x_po_header_id
       AND pol.po_line_id = pola.po_line_id (+)
       AND pola.latest_external_flag (+) = 'Y'
       AND (
               (pola.po_line_id IS NULL)
            OR (pol.retainage_rate <> pola.retainage_rate)
            OR (pol.retainage_rate IS NULL AND pola.retainage_rate IS NOT NULL)
            OR (pol.retainage_rate IS NOT NULL AND pola.retainage_rate IS NULL)
           );
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_lines_control.retainage_rate :='N';
   END;

   BEGIN

     -- SQL What: Select 'Y' if line's max retainage amount has changed
     -- SQL Why: Need the value for routing to reapproval if there is a change
     -- SQL Join: po_line_id

     SELECT DISTINCT 'Y'
     INTO x_lines_control.max_retainage_amount
     FROM po_lines_all pol,
          po_lines_archive_all pola
     WHERE pol.po_header_id = x_po_header_id
       AND pol.po_line_id = pola.po_line_id (+)
       AND pola.latest_external_flag (+) = 'Y'
       AND (
               (pola.po_line_id IS NULL)
            OR (pol.max_retainage_amount <> pola.max_retainage_amount)
            OR (pol.max_retainage_amount IS NULL AND pola.max_retainage_amount IS NOT NULL)
            OR (pol.max_retainage_amount IS NOT NULL AND pola.max_retainage_amount IS NULL)
           );
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_lines_control.max_retainage_amount :='N';
   END;

   BEGIN

     -- SQL What: Select 'Y' if line's progress payment rate has changed
     -- SQL Why: Need the value for routing to reapproval if there is a change
     -- SQL Join: po_line_id

     SELECT DISTINCT 'Y'
     INTO x_lines_control.progress_payment_rate
     FROM po_lines_all pol,
          po_lines_archive_all pola
     WHERE pol.po_header_id = x_po_header_id
       AND pol.po_line_id = pola.po_line_id (+)
       AND pola.latest_external_flag (+) = 'Y'
       AND (
               (pola.po_line_id IS NULL)
            OR (pol.progress_payment_rate <> pola.progress_payment_rate)
            OR (pol.progress_payment_rate IS NULL AND
                                             pola.progress_payment_rate IS NOT NULL)
            OR (pol.progress_payment_rate IS NOT NULL AND
                                             pola.progress_payment_rate IS NULL)
           );
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_lines_control.progress_payment_rate :='N';
   END;

   BEGIN

     -- SQL What: Select 'Y' if line's recoupment rate has changed
     -- SQL Why: Need the value for routing to reapproval if there is a change
     -- SQL Join: po_line_id

     SELECT DISTINCT 'Y'
     INTO x_lines_control.recoupment_rate
     FROM po_lines_all pol,
          po_lines_archive_all pola
     WHERE pol.po_header_id = x_po_header_id
       AND pol.po_line_id = pola.po_line_id (+)
       AND pola.latest_external_flag (+) = 'Y'
       AND (
               (pola.po_line_id IS NULL)
            OR (pol.recoupment_rate <> pola.recoupment_rate)
            OR (pol.recoupment_rate IS NULL AND pola.recoupment_rate IS NOT NULL)
            OR (pol.recoupment_rate IS NOT NULL AND pola.recoupment_rate IS NULL)
           );
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_lines_control.recoupment_rate :='N';
   END;

   BEGIN

     -- SQL What: Select 'Y' if a line's advance amount has changed.
     -- Since advance is stored at line location level, hit that table.
     -- SQL Why: Need the value for routing to reapproval if there is a change
     -- SQL Join: line_location_id

     SELECT DISTINCT 'Y'
     INTO x_lines_control.advance_amount
     FROM po_line_locations_all poll,
          po_line_locations_archive_all polla
     WHERE poll.po_header_id = x_po_header_id
       AND poll.payment_type = 'ADVANCE'
       AND poll.line_location_id = polla.line_location_id (+)
       AND polla.latest_external_flag (+) = 'Y'
       AND (
               (polla.line_location_id IS NULL)
            OR (poll.amount <> polla.amount)
            OR (poll.amount IS NULL AND polla.amount IS NOT NULL)
            OR (poll.amount IS NOT NULL AND polla.amount IS NULL)
           );
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_lines_control.advance_amount :='N';
   END;

   -- <Complex Work R12 End>


   BEGIN
                 -- SQL What: Retrieving the percentage change in
                 --           line quantity
                 -- SQL Why: Need the value in tolerance check (i.e reapproval
                 --          rule validations)
                 -- SQL Join: po_line_id
		 SELECT max(po_chord_wf0.percentage_change(
			 POLA.quantity, POL.quantity))
                 INTO  x_lines_control.quantity_change
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y';

   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.quantity_change :=0;
   END;

   BEGIN
                 -- SQL What: Retrieving the percentage change in
                 --           unit price
                 -- SQL Why: Need the value in tolerance check (i.e reapproval
                 --          rule validations)
                 -- SQL Join: po_line_id
		 SELECT max(po_chord_wf0.percentage_change(
			POLA.unit_price, POL.unit_price))
                 INTO  x_lines_control.unit_price_change
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y';

   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.unit_price_change :=0;
   END;

   BEGIN
                 -- SQL What: Retrieving the percentage change in
                 --           exceed price tolerance
                 -- SQL Why: Need the value in tolerance check (i.e reapproval
                 --          rule validations)
                 -- SQL Join: po_line_id
		 SELECT max(po_chord_wf0.percentage_change(
			POLA.not_to_exceed_price, POL.not_to_exceed_price))
                 INTO  x_lines_control.not_to_exceed_price_change
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y';

   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.not_to_exceed_price_change :=0;
   END;

   BEGIN
                 -- SQL What: Retrieving the percentage change in
                 --           commited quantity
                 -- SQL Why: Need the value in tolerance check (i.e reapproval
                 --          rule validations)
                 -- SQL Join: po_line_id
		 SELECT max(po_chord_wf0.percentage_change(
			POLA.quantity_committed, POL.quantity_committed))
                 INTO  x_lines_control.quantity_committed_change
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y';

   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.quantity_committed_change :=0;
   END;

   BEGIN
                 -- SQL What: Retrieving the percentage change in
                 --           commited amount
                 -- SQL Why: Need the value in tolerance check (i.e reapproval
                 --          rule validations)
                 -- SQL Join: po_line_id
		 SELECT max(po_chord_wf0.percentage_change(
			POLA.committed_amount, POL.committed_amount))
                 INTO  x_lines_control.committed_amount_change
                 FROM  PO_LINES_ALL POL,
                       PO_LINES_ARCHIVE_ALL POLA
                 WHERE POL.po_header_id = x_po_header_id
                 AND   POL.po_line_id = POLA.po_line_id (+)
                 AND   POLA.latest_external_flag (+) = 'Y';

   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_lines_control.committed_amount_change :=0;
   END;


    -- Get the currency code and precision
    SELECT poh.currency_code
    INTO   l_currency_code
    FROM   po_headers_all poh
    WHERE  poh.po_header_id = x_po_header_id;

    PO_CORE_S2.get_currency_info(
      x_currency_code => l_currency_code
    , x_min_unit      => l_min_acct_unit
    , x_precision     => l_precision);

   --<R12 Requester Driven Procurement Start>
   -- SQL What: Retrieving the percentage change in line amount
   -- SQL Why: Need the value in tolerance check (i.e reapproval
   --          rule validations)
   -- SQL Join: po_line_id
   -- Bug 5071741: Amount change is calculated using price and qty for
   -- qty based lines and amount for services lines and rounded accordingly
   BEGIN

        IF l_min_acct_unit is not null AND
           l_min_acct_unit <> 0 THEN

	  SELECT max(po_chord_wf0.percentage_change(
                  round(
	   	   decode(POLA.order_type_lookup_code, 'RATE',POLA.amount,'FIXED PRICE', POLA.amount,
                       (POLA.quantity*POLA.unit_price)) / l_min_acct_unit )* l_min_acct_unit ,
                  round(
                   decode(POL.order_type_lookup_code, 'RATE',POL.amount,'FIXED PRICE', POL.amount,
                       (POL.quantity*POL.unit_price)) / l_min_acct_unit )* l_min_acct_unit
                 ) )
	  INTO  x_lines_control.amount_change
	  FROM  PO_LINES_ALL POL,
	        PO_LINES_ARCHIVE_ALL POLA
	  WHERE POL.po_header_id = x_po_header_id
	  AND   POL.po_line_id = POLA.po_line_id (+)
	  AND   POLA.latest_external_flag (+) = 'Y';

        ELSE
         SELECT max(po_chord_wf0.percentage_change(
                  round(
	   	   decode(POLA.order_type_lookup_code, 'RATE',POLA.amount,'FIXED PRICE', POLA.amount,
                       (POLA.quantity*POLA.unit_price ))  , l_precision) ,
                   round(
                   decode(POL.order_type_lookup_code, 'RATE',POL.amount,'FIXED PRICE', POL.amount,
                       (POL.quantity*POL.unit_price )) , l_precision)
                ) )
	  INTO  x_lines_control.amount_change
	  FROM  PO_LINES_ALL POL,
	        PO_LINES_ARCHIVE_ALL POLA
	  WHERE POL.po_header_id = x_po_header_id
	  AND   POL.po_line_id = POLA.po_line_id (+)
	  AND   POLA.latest_external_flag (+) = 'Y';
        END IF;

   EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_lines_control.amount_change :=0;
   END;

   -- Bug 5083205: Added start and end date change checks
   -- SQL What: Retrieving the percentage change in start date
   -- SQL Why: Need the value in tolerance check (i.e reapproval
   --          rule validations)
   -- SQL Join: line_id
   BEGIN
      SELECT max(trunc(POL.start_date-POLA.start_date))
      INTO  x_lines_control.start_date_change
      FROM  PO_LINES_ALL POL,
            PO_LINES_ARCHIVE_ALL POLA
      WHERE POL.po_header_id = x_po_header_id
      AND   POL.po_line_id = POLA.po_line_id (+)
      AND   POLA.latest_external_flag (+) = 'Y';

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_lines_control.start_date_change := 0;
   END;

   BEGIN
       -- Bug 5123672 Added query to check if date changed
       -- SQL What: Select 'Y' if end date is changed
       -- SQL Why: Need the value for routing to reapproval
       --          if there is a change
       -- SQL Join: po_line_id, line_num
       SELECT DISTINCT 'Y'
       INTO  x_lines_control.end_date
       FROM  PO_LINES POL,
             PO_LINES_ARCHIVE_ALL POLA
       WHERE POL.po_header_id = x_po_header_id
       AND   POL.po_line_id = POLA.po_line_id (+)
       AND   POLA.latest_external_flag (+) = 'Y'
       AND (
             (POLA.po_line_id is NULL)
              OR (POL.expiration_date <> POLA.expiration_date)
              OR (POL.expiration_date IS NULL AND POLA.expiration_date IS NOT NULL)
              OR (POL.expiration_date IS NOT NULL AND POLA.expiration_date IS NULL)
           );

      -- SQL What: Retrieving the change in end date
      -- SQL Why: Need the value in tolerance check (i.e reapproval
      --          rule validations)
      -- SQL Join: line_id

      SELECT max(trunc(POL.expiration_date-POLA.expiration_date))
      INTO  x_lines_control.end_date_change
      FROM  PO_LINES_ALL POL,
            PO_LINES_ARCHIVE_ALL POLA
      WHERE POL.po_header_id = x_po_header_id
      AND   POL.po_line_id = POLA.po_line_id (+)
      AND   POLA.latest_external_flag (+) = 'Y'
      AND   (POL.expiration_date IS NOT NULL OR POLA.expiration_date IS NOT NULL);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_lines_control.end_date_change := 0;
   END;

   --<R12 Requester Driven Procurement End>

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish: check_lines_change ***' );
	END IF;

EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'check_lines_change', 'others');
  RAISE;

END check_lines_change;

PROCEDURE set_wf_lines_control(itemtype	 IN VARCHAR2,
			       itemkey 	 IN VARCHAR2,
			       x_lines_control IN t_lines_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: set_wf_lines_control ***');
	END IF;

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_LINE_NUM',
			   x_lines_control.line_num);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_ITEM',
			   x_lines_control.item_id);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_ITEM_REVISION',
			   x_lines_control.item_revision);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_CATEGORY',
			   x_lines_control.category_id);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_ITEM_DESCRIPTION',
			   x_lines_control.item_description);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_UOM',
			   x_lines_control.unit_meas_lookup_code);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_UN_NUMBER',
			   x_lines_control.un_number_id);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_HAZARD_CLASS',
			   x_lines_control.hazard_class_id);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_NOTE_TO_VENDOR',
			   x_lines_control.note_to_vendor);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_FROM_HEADER_ID',
			   x_lines_control.from_header_id);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_FROM_LINE_ID',
			   x_lines_control.from_line_id);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_CLOSED_CODE',
			   x_lines_control.closed_code);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_VENDOR_PRODUCT_NUM',
			   x_lines_control.vendor_product_num);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_CONTRACT_NUM',
			   x_lines_control.contract_num);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_PRICE_TYPE',
			   x_lines_control.price_type_lookup_code);

 wf_engine.SetItemAttrText(itemtype,
         itemkey,
         'CO_L_CANCEL_FLAG',
         x_lines_control.cancel_flag);

 -- <Complex Work R12 Start>

 wf_engine.SetItemAttrText(itemtype,
         itemkey,
         'CO_L_RETAINAGE_RATE',
         x_lines_control.retainage_rate);

 wf_engine.SetItemAttrText(itemtype,
         itemkey,
         'CO_L_MAX_RETAINAGE_AMOUNT',
         x_lines_control.max_retainage_amount);

 wf_engine.SetItemAttrText(itemtype,
         itemkey,
         'CO_L_PROGRESS_PAYMENT_RATE',
         x_lines_control.progress_payment_rate);

 wf_engine.SetItemAttrText(itemtype,
         itemkey,
         'CO_L_RECOUPMENT_RATE',
         x_lines_control.recoupment_rate);

 wf_engine.SetItemAttrText(itemtype,
         itemkey,
         'CO_L_ADVANCE_AMOUNT',
         x_lines_control.advance_amount);

 -- <Complex Work R12 End>


  PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_L_END_DATE',
                           x_lines_control.end_date);

 wf_engine.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_L_QUANTITY_CHANGE',
			     x_lines_control.quantity_change);

 wf_engine.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_L_UNIT_PRICE_CHANGE',
			     x_lines_control.unit_price_change);

 wf_engine.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_L_NOT_TO_EXCEED_PRICE',
			     x_lines_control.not_to_exceed_price_change);

 wf_engine.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_L_QTY_COMMITTED_CHANGE',
			     x_lines_control.quantity_committed_change);

 wf_engine.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_L_COMMITTED_AMT_CHANGE',
			     x_lines_control.committed_amount_change);

 PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype, itemkey,
	     'CO_L_AMOUNT_CHANGE', x_lines_control.amount_change); --<R12 Requester Driven Procurement>

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_L_START_DATE_CHANGE',
                           x_lines_control.start_date_change);

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_L_END_DATE_CHANGE',
                           x_lines_control.end_date_change);

 -- debug_lines_control(itemtype, itemkey, x_lines_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finished: set_wf_lines_control ***');
	END IF;

END;


PROCEDURE get_wf_lines_control(itemtype	IN VARCHAR2,
			       itemkey 	IN VARCHAR2,
			       x_lines_control IN OUT NOCOPY t_lines_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: get_wf_lines_control ***');
	END IF;

 x_lines_control.line_num :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_LINE_NUM');

 x_lines_control.item_id  :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_ITEM');

 x_lines_control.item_revision :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_ITEM_REVISION');


 x_lines_control.category_id :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_CATEGORY');

 x_lines_control.item_description :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_ITEM_DESCRIPTION');


 x_lines_control.unit_meas_lookup_code :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_UOM');

 x_lines_control.un_number_id :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_UN_NUMBER');

 x_lines_control.hazard_class_id :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_HAZARD_CLASS');

 x_lines_control.note_to_vendor :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_NOTE_TO_VENDOR');


 x_lines_control.from_header_id :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_FROM_HEADER_ID');


 x_lines_control.from_line_id :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_FROM_LINE_ID');

 x_lines_control.closed_code :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_CLOSED_CODE');

 x_lines_control.vendor_product_num :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_VENDOR_PRODUCT_NUM');

 x_lines_control.contract_num :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_CONTRACT_NUM');

 x_lines_control.price_type_lookup_code :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_PRICE_TYPE');

 x_lines_control.cancel_flag :=
 wf_engine.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_L_CANCEL_FLAG');

 -- <Complex Work R12 Start>

 x_lines_control.retainage_rate:=
  PO_WF_UTIL_PKG.GetItemAttrText(itemtype, itemkey, 'CO_L_RETAINAGE_RATE');

 x_lines_control.max_retainage_amount:=
  PO_WF_UTIL_PKG.GetItemAttrText(itemtype, itemkey, 'CO_L_MAX_RETAINAGE_AMOUNT');

 x_lines_control.progress_payment_rate:=
  PO_WF_UTIL_PKG.GetItemAttrText(itemtype, itemkey, 'CO_L_PROGRESS_PAYMENT_RATE');

 x_lines_control.recoupment_rate:=
  PO_WF_UTIL_PKG.GetItemAttrText(itemtype, itemkey, 'CO_L_RECOUPMENT_RATE');

 x_lines_control.advance_amount:=
  PO_WF_UTIL_PKG.GetItemAttrText(itemtype, itemkey, 'CO_L_ADVANCE_AMOUNT');

 -- <Complex Work R12 End>

 x_lines_control.end_date :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_L_END_DATE');

 x_lines_control.quantity_change:=
 wf_engine.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_L_QUANTITY_CHANGE');

 x_lines_control.unit_price_change:=
 wf_engine.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_L_UNIT_PRICE_CHANGE');

 x_lines_control.not_to_exceed_price_change:=
 wf_engine.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_L_NOT_TO_EXCEED_PRICE');

 x_lines_control.quantity_committed_change:=
 wf_engine.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_L_QTY_COMMITTED_CHANGE');

 x_lines_control.committed_amount_change:=
 wf_engine.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_L_COMMITTED_AMT_CHANGE');

 x_lines_control.amount_change:=
  PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype,
   				   itemkey,
				   'CO_L_AMOUNT_CHANGE'); --<R12 Requester Driven Procurement>

 x_lines_control.start_date_change :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_L_START_DATE_CHANGE');

 x_lines_control.end_date_change :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_L_END_DATE_CHANGE');

 debug_lines_control(itemtype, itemkey, x_lines_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finished: get_wf_lines_control ***');
	END IF;

END;

PROCEDURE get_wf_lines_parameters(itemtype	 IN VARCHAR2,
				  itemkey 	 IN VARCHAR2,
				  x_lines_parameters IN OUT NOCOPY t_lines_parameters_type)
IS
BEGIN

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure get_wf_lines_parameters ***');
	END IF;

	x_lines_parameters.po_header_id :=
		wf_engine.GetItemAttrNumber(itemtype,
					    itemkey,
				    	    'DOCUMENT_ID');

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'po_header_id =  '|| to_char(x_lines_parameters.po_header_id));
	END IF;


	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** FINISH: get_wf_lines_parameters ***');
	END IF;
END;


PROCEDURE debug_lines_control(itemtype IN VARCHAR2,
			      itemkey  IN VARCHAR2,
			      x_lines_control IN t_lines_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: debug_lines_control ***');
	END IF;

 IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'line_num                : ' || x_lines_control.line_num);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'item_id                 : ' || x_lines_control.item_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'item_revision           : ' || x_lines_control.item_revision);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'category_id             : ' || x_lines_control.category_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'item_description        : ' || x_lines_control.item_description);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'unit_meas_lookup_code   : ' || x_lines_control.unit_meas_lookup_code);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'un_number_id            : ' || x_lines_control.un_number_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'hazard_class_id         : ' || x_lines_control.hazard_class_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'note_to_vendor          : ' || x_lines_control.note_to_vendor);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'from_header_id          : ' || x_lines_control.from_header_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'closed_code             : ' || x_lines_control.closed_code);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'vendor_product_num      : ' || x_lines_control.vendor_product_num);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'contract_num            : ' || x_lines_control.contract_num);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'price_type_lookup_code  : ' || x_lines_control.price_type_lookup_code);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'cancel_flag             : ' || x_lines_control.cancel_flag);
    -- <Complex Work R12 Start>
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'retainage_rate          : ' || x_lines_control.retainage_rate);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'max_retainage_amount    : ' || x_lines_control.max_retainage_amount);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'progress_payment_rate   : ' || x_lines_control.progress_payment_rate);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'recoupment_rate         : ' || x_lines_control.recoupment_rate);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'advance_amount          : ' || x_lines_control.advance_amount);
    -- <Complex Work R12 End>
 END IF;

 IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'quantity_change            : ' || to_char(x_lines_control.quantity_change));
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'unit_price_change          : ' || to_char(x_lines_control.unit_price_change));
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'not_to_exceed_price_change : ' || to_char(x_lines_control.not_to_exceed_price_change));
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'quantity_committed_change  : ' || to_char(x_lines_control.quantity_committed_change));
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'committed_amount_change    : ' || to_char(x_lines_control.committed_amount_change));
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
        'amount_change : ' || to_char(x_lines_control.amount_change)); --<R12 Requester Driven Procurement>
 END IF;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finished: debug_lines_control ***');
	END IF;
END;

END PO_CHORD_WF2;

/
