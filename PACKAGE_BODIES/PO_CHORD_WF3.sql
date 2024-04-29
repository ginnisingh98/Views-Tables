--------------------------------------------------------
--  DDL for Package Body PO_CHORD_WF3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHORD_WF3" AS
/* $Header: POXWCO3B.pls 120.9.12010000.4 2012/09/10 12:35:15 inagdeo ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

PROCEDURE chord_shipments(itemtype IN VARCHAR2,
		      itemkey  IN VARCHAR2,
		      actid    IN NUMBER,
		      funcmode IN VARCHAR2,
		      result   OUT NOCOPY VARCHAR2)
IS
	x_shipments_control		t_shipments_control_type;
	x_shipments_parameters		t_shipments_parameters_type;
BEGIN

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In Procedure: chord_shipments ***' );
	END IF;

	IF funcmode <> 'RUN' THEN
		result := 'COMPLETE';
		return;
	END IF;

	get_wf_shipments_parameters(itemtype, itemkey, x_shipments_parameters);

	check_shipments_change(itemtype, itemkey, x_shipments_parameters, x_shipments_control);

	set_wf_shipments_control(itemtype, itemkey, x_shipments_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish: chord_shipments ***' );
	END IF;

	result := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
	return;

EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_chord_wf3.chord_shipments', 'others');
  RAISE;

END;

PROCEDURE check_shipments_change(
			itemtype IN VARCHAR2,
			itemkey  IN VARCHAR2,
			x_shipments_parameters IN t_shipments_parameters_type,
			x_shipments_control OUT NOCOPY t_shipments_control_type)
IS
  x_po_header_id			NUMBER:=NULL;
  x_po_release_id			NUMBER:=NULL;
  e_invalid_setup			EXCEPTION;
  l_currency_code   VARCHAR2(15);
  l_min_acct_unit   VARCHAR2(15);
  l_precision       VARCHAR2(15);

BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: check_shipments_change ***' );
	END IF;

		/* To use change order,
		 * System should have Archive on Approval set
		 */

	x_shipments_control.shipment_num		:='N';
	x_shipments_control.ship_to_organization_id	:='N';
	x_shipments_control.ship_to_location_id		:='N';
	x_shipments_control.promised_date		:='N';
	x_shipments_control.need_by_date		:='N';
	x_shipments_control.last_accept_date		:='N';
	x_shipments_control.taxable_flag		:='N';
	x_shipments_control.price_discount		:='N';
	x_shipments_control.cancel_flag			:='N';
	x_shipments_control.closed_code			:='N';
        x_shipments_control.start_date                  :='N';   /* <TIMEPHASED FPI> */
        x_shipments_control.end_date                    :='N';   /* <TIMEPHASED FPI> */
        x_shipments_control.price_override              :='N';   /* Bug 2808011 */
        x_shipments_control.days_late_rcpt_allowed      :='N';   -- ECO 5080252

        -- <Complex Work R12 Start>
        x_shipments_control.payment_type := 'N';
        x_shipments_control.work_approver_id := 'N';
        x_shipments_control.description := 'N';
        -- <Complex Work R12 End>

	x_shipments_control.quantity_change		:=0;
	x_shipments_control.price_override_change	:=0;

        --<R12 Requester Driven Procurement Start>

	x_shipments_control.amount_change		:=0;
	x_shipments_control.start_date_change		:=0;
	x_shipments_control.end_date_change		:=0;
	x_shipments_control.need_by_date_change		:=0;
	x_shipments_control.promised_date_change	:=0;

	--<R12 Requester Driven Procurement End>

	/* This package is shared by PO and Release
	 * Pre-condition: Either po_header_id or po_release_id is NULL
	 */

	x_po_header_id	  := x_shipments_parameters.po_header_id;
	x_po_release_id	  := x_shipments_parameters.po_release_id;

	IF ((x_po_header_id IS NOT NULL AND x_po_release_id IS NOT NULL) OR
	    (x_po_header_id IS NULL AND x_po_release_id IS NULL)) THEN
		raise e_invalid_setup;
	END IF;

/* bug# 880416: brought forward the following changes from 110.5.
   csheu bug #875995: split the old SQLs based on x_po_header_id */

        -- SQL What: Select 'Y' if Shipment number is changed
        -- SQL Why: Need the value for routing to reapproval
        --          if there is a change
        -- SQL Join: line_location_id, shipment_num
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.shipment_num
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
	             POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.shipment_num <> POLLA.shipment_num)
               OR (POLL.shipment_num IS NULL AND POLLA.shipment_num IS NOT NULL)
               OR (POLL.shipment_num IS NOT NULL AND POLLA.shipment_num IS NULL)
	       )
	       AND poll.po_release_id is NULL; -- Bug 4016493 : Ignore release shipments

          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.shipment_num := 'N';
          END;
        ELSE
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.shipment_num
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
                     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.shipment_num <> POLLA.shipment_num)
               OR (POLL.shipment_num IS NULL AND POLLA.shipment_num IS NOT NULL)
               OR (POLL.shipment_num IS NOT NULL AND POLLA.shipment_num IS NULL)
	       );
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.shipment_num := 'N';
          END;
        END IF;

        -- SQL What: Select 'Y' if Ship to is changed
        -- SQL Why: Need the value for routing to reapproval
        --          if there is a change
        -- SQL Join: line_location_id, ship_to_organization_id
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.ship_to_organization_id
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.ship_to_organization_id <> POLLA.ship_to_organization_id)
               OR (POLL.ship_to_organization_id IS NULL
		   AND POLLA.ship_to_organization_id IS NOT NULL)
               OR (POLL.ship_to_organization_id IS NOT NULL
		   AND POLLA.ship_to_organization_id IS NULL)
	       )
             AND poll.po_release_id is NULL;  -- Bug 4016493 : Ignore release shipments

          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.ship_to_organization_id := 'N';
          END;
        ELSE
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.ship_to_organization_id
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.ship_to_organization_id <> POLLA.ship_to_organization_id)
               OR (POLL.ship_to_organization_id IS NULL
		   AND POLLA.ship_to_organization_id IS NOT NULL)
               OR (POLL.ship_to_organization_id IS NOT NULL
		   AND POLLA.ship_to_organization_id IS NULL)
	       );
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.ship_to_organization_id := 'N';
          END;
        END IF;

        -- SQL What: Select 'Y' if Ship to is changed
        -- SQL Why: Need the value for routing to reapproval
        --          if there is a change
        -- SQL Join: line_location_id, ship_to_location_id
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.ship_to_location_id
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.ship_to_location_id <> POLLA.ship_to_location_id)
               OR (POLL.ship_to_location_id IS NULL
		   AND POLLA.ship_to_location_id IS NOT NULL)
               OR (POLL.ship_to_location_id IS NOT NULL
		   AND POLLA.ship_to_location_id IS NULL)
	       )
             AND poll.po_release_id is NULL; -- Bug 4016493 : Ignore release shipments
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.ship_to_location_id := 'N';
          END;
        ELSE
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.ship_to_location_id
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.ship_to_location_id <> POLLA.ship_to_location_id)
               OR (POLL.ship_to_location_id IS NULL
		   AND POLLA.ship_to_location_id IS NOT NULL)
               OR (POLL.ship_to_location_id IS NOT NULL
		   AND POLLA.ship_to_location_id IS NULL)
	       );
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.ship_to_location_id := 'N';
          END;
        END IF;

	--<R12 Requester Driven Procurement Start>

	-- query to retrieve the change in promised date
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               -- Bug 5123672 Added query to check if date changed
               -- Sql What : determine if promised date changed
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.promised_date
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.promised_date <> POLLA.promised_date)
               OR (POLL.promised_date IS NULL
		   AND POLLA.promised_date IS NOT NULL)
               OR (POLL.promised_date IS NOT NULL
		   AND POLLA.promised_date IS NULL)
	       )
               AND poll.po_release_id is NULL;

               -- Sql What : retrieve the change in promised date
               SELECT max(trunc(POLL.promised_date-POLLA.promised_date))
               INTO  x_shipments_control.promised_date_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
	       AND   poll.po_release_id is NULL
               AND   ( (POLL.promised_date <> POLLA.promised_date) -- Bug 14584350
	       OR (POLL.promised_date IS NOT NULL AND POLLA.promised_date IS NULL)
	       OR (POLLA.promised_date IS NOT NULL AND POLL.promised_date IS NULL)); -- bug 14160952, modified the query to include both the conditions.
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	        x_shipments_control.promised_date_change := 0;
          END;
        ELSE
          BEGIN
               -- Bug 5123672 Added query to check if date changed
               -- Sql What : determine if promised date changed
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.promised_date
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.promised_date <> POLLA.promised_date)
               OR (POLL.promised_date IS NULL
		   AND POLLA.promised_date IS NOT NULL)
               OR (POLL.promised_date IS NOT NULL
		   AND POLLA.promised_date IS NULL)
	       );

               -- Sql What : retrieve the change in promised date
               SELECT max(trunc(POLL.promised_date-POLLA.promised_date))
               INTO  x_shipments_control.promised_date_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   ( (POLL.promised_date <> POLLA.promised_date) -- Bug 14584350
	       OR (POLL.promised_date IS NOT NULL AND POLLA.promised_date IS NULL)
	       OR (POLLA.promised_date IS NOT NULL AND POLL.promised_date IS NULL)); -- bug 14160952, modified the query to include both the conditions.
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	        x_shipments_control.promised_date_change := 0;
          END;
        END IF;

	-- query to retrieve the change in need by date
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               -- Bug 5123672 Added query to check if date changed
               -- Sql What : determine if need by date changed
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.need_by_date
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.need_by_date <> POLLA.need_by_date)
               OR (POLL.need_by_date IS NULL
		   AND POLLA.need_by_date IS NOT NULL)
               OR (POLL.need_by_date IS NOT NULL
		   AND POLLA.need_by_date IS NULL)
	       )
               AND poll.po_release_id is NULL;

               -- Sql What : retrieve the change in need by  date
               SELECT max(trunc(POLL.need_by_date-POLLA.need_by_date))
               INTO  x_shipments_control.need_by_date_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
	       AND   poll.po_release_id is NULL -- Bug 4016493 : Ignore release shipments
               AND   ( (POLL.need_by_date <> POLLA.need_by_date)  --Bug 14584350
	       OR (POLL.need_by_date IS NOT NULL AND POLLA.need_by_date IS NULL)
	       OR (POLLA.need_by_date IS NOT NULL AND POLL.need_by_date IS NULL)); -- bug 14160952, modified the query to include both the conditions.
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	        x_shipments_control.need_by_date_change := 0;
          END;
        ELSE
          BEGIN
               -- Bug 5123672 Added query to check if date changed
               -- Sql What : determine if need by date changed
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.need_by_date
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.need_by_date <> POLLA.need_by_date)
               OR (POLL.need_by_date IS NULL
		   AND POLLA.need_by_date IS NOT NULL)
               OR (POLL.need_by_date IS NOT NULL
		   AND POLLA.need_by_date IS NULL)
	       );

               -- Sql What : retrieve the change in need by  date
               SELECT max(trunc(POLL.need_by_date-POLLA.need_by_date))
               INTO  x_shipments_control.need_by_date_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   ((POLL.need_by_date <> POLLA.need_by_date)  --Bug 14584350
	       OR (POLL.need_by_date IS NOT NULL AND POLLA.need_by_date IS NULL)
	       OR (POLLA.need_by_date IS NOT NULL AND POLL.need_by_date IS NULL)); -- bug 14160952, modified the query to include both the conditions.
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	        x_shipments_control.need_by_date_change := 0;
          END;
        END IF;

	--<R12 Requester Driven Procurement End>

        -- SQL What: Select 'Y' if last accepted date is changed
        -- SQL Why: Need the value for routing to reapproval
        --          if there is a change
        -- SQL Join: line_location_id, last_accept_date
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.last_accept_date
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.last_accept_date <> POLLA.last_accept_date)
               OR (POLL.last_accept_date IS NULL AND POLLA.last_accept_date IS NOT NULL)
               OR (POLL.last_accept_date IS NOT NULL AND POLLA.last_accept_date IS NULL)
	       )
             AND poll.po_release_id is NULL; -- Bug 4016493 : Ignore release shipments

          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.last_accept_date := 'N';
          END;
        ELSE
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.last_accept_date
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.last_accept_date <> POLLA.last_accept_date)
               OR (POLL.last_accept_date IS NULL AND POLLA.last_accept_date IS NOT NULL)
               OR (POLL.last_accept_date IS NOT NULL AND POLLA.last_accept_date IS NULL)
	       );

          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.last_accept_date := 'N';
          END;
        END IF;

        -- SQL What: Select 'Y' if taxable flag is changed
        -- SQL Why: Need the value for routing to reapproval
        --          if there is a change
        -- SQL Join: line_location_id, taxable_flag
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.taxable_flag
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.taxable_flag <> POLLA.taxable_flag)
               OR (POLL.taxable_flag IS NULL AND POLLA.taxable_flag IS NOT NULL)
               OR (POLL.taxable_flag IS NOT NULL AND POLLA.taxable_flag IS NULL)
	       )
	       AND poll.po_release_id is NULL; -- Bug 4016493 : Ignore release shipments
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.taxable_flag := 'N';
          END;
        ELSE
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.taxable_flag
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.taxable_flag <> POLLA.taxable_flag)
               OR (POLL.taxable_flag IS NULL AND POLLA.taxable_flag IS NOT NULL)
               OR (POLL.taxable_flag IS NOT NULL AND POLLA.taxable_flag IS NULL)
	       );
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.taxable_flag := 'N';
          END;
        END IF;

        -- SQL What: Select 'Y' if cancel flag is changed
        -- SQL Why: Need the value for routing to reapproval
        --          if there is a change
        -- SQL Join: line_location_id, cancel_flag
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.cancel_flag
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.cancel_flag <> POLLA.cancel_flag)
               OR (POLL.cancel_flag IS NULL AND POLLA.cancel_flag IS NOT NULL)
               OR (POLL.cancel_flag IS NOT NULL AND POLLA.cancel_flag IS NULL)
	       )
	       AND poll.po_release_id is NULL; -- Bug 4016493 : Ignore release shipments
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.cancel_flag := 'N';
          END;
        ELSE
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.cancel_flag
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.cancel_flag <> POLLA.cancel_flag)
               OR (POLL.cancel_flag IS NULL AND POLLA.cancel_flag IS NOT NULL)
               OR (POLL.cancel_flag IS NOT NULL AND POLLA.cancel_flag IS NULL)
	       );
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.cancel_flag := 'N';
          END;
        END IF;

        -- SQL What: Select 'Y' if closed code is changed
        -- SQL Why: Need the value for routing to reapproval
        --          if there is a change
        -- SQL Join: line_location_id, closed_code
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.closed_code
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.closed_code <> POLLA.closed_code)
               OR (POLL.closed_code IS NULL AND POLLA.closed_code IS NOT NULL)
               OR (POLL.closed_code IS NOT NULL AND POLLA.closed_code IS NULL)
	       )
             AND poll.po_release_id is NULL; -- Bug 4016493 : Ignore release shipments

          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.closed_code := 'N';
          END;
        ELSE
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.closed_code
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.closed_code <> POLLA.closed_code)
               OR (POLL.closed_code IS NULL AND POLLA.closed_code IS NOT NULL)
               OR (POLL.closed_code IS NOT NULL AND POLLA.closed_code IS NULL)
	       );
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.closed_code := 'N';
          END;
        END IF;

        /* <TIMEPHASED FPI START> */
	--<R12 Requester Driven Procurement Start>
	-- SQL What: Retrieving the percentage change in start date
        -- SQL Why: Need the value in tolerance check (i.e reapproval
        --          rule validations)
        -- SQL Join: line_location_id
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               SELECT max(trunc(POLL.start_date-POLLA.start_date))
               INTO  x_shipments_control.start_date_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
	       AND poll.po_release_id is NULL; -- Bug 4016493 : Ignore release shipments
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	        x_shipments_control.start_date_change := 0;
          END;
        ELSE
          BEGIN
               SELECT max(trunc(POLL.start_date-POLLA.start_date))
               INTO  x_shipments_control.start_date_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y';
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	        x_shipments_control.start_date_change := 0;
          END;
        END IF;

	IF (x_shipments_control.start_date_change > 0) THEN
	  x_shipments_control.start_date := 'Y';
	ELSE
	  x_shipments_control.start_date := 'N';
	END IF;

	-- SQL What: Retrieving the percentage change in end date
        -- SQL Why: Need the value in tolerance check (i.e reapproval
        --          rule validations)
        -- SQL Join: line_location_id
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               SELECT max(trunc(POLL.end_date-POLLA.end_date))
               INTO  x_shipments_control.end_date_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
	       AND poll.po_release_id is NULL; -- Bug 4016493 : Ignore release shipments
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	        x_shipments_control.end_date_change := 0;
          END;
        ELSE
          BEGIN
               SELECT max(trunc(POLL.end_date-POLLA.end_date))
               INTO  x_shipments_control.end_date_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y';
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	        x_shipments_control.end_date_change := 0;
          END;
        END IF;

        if (x_shipments_control.end_date_change > 0) then
	  x_shipments_control.end_date := 'Y';
	else
	  x_shipments_control.end_date := 'N';
	end if;


  -- <Complex Work R12 Start>

  IF (x_po_header_id IS NOT NULL) THEN

    BEGIN

      SELECT DISTINCT 'Y'
      INTO  x_shipments_control.payment_type
      FROM  PO_LINE_LOCATIONS_ALL POLL,
            PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
      WHERE POLL.po_header_id = x_po_header_id
        AND NVL(POLL.payment_type, 'NONE') NOT IN ('DELIVERY', 'ADVANCE')
        AND POLL.line_location_id = POLLA.line_location_id (+)
        AND POLLA.latest_external_flag (+) = 'Y'
        AND (
                      (POLLA.line_location_id is NULL)
                   OR (POLL.payment_type <> POLLA.payment_type)
                   OR (POLL.payment_type IS NULL AND POLLA.payment_type IS NOT NULL)
                   OR (POLL.payment_type IS NOT NULL AND POLLA.payment_type IS NULL)
	          )
        AND poll.po_release_id is NULL;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_shipments_control.payment_type := 'N';
    END;

    BEGIN

      SELECT DISTINCT 'Y'
      INTO  x_shipments_control.description
      FROM  PO_LINE_LOCATIONS_ALL POLL,
            PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
      WHERE POLL.po_header_id = x_po_header_id
        AND NVL(POLL.payment_type, 'NONE') NOT IN ('DELIVERY', 'ADVANCE')
        AND POLL.line_location_id = POLLA.line_location_id (+)
        AND POLLA.latest_external_flag (+) = 'Y'
        AND (
                      (POLLA.line_location_id is NULL)
                   OR (POLL.description <> POLLA.description)
                   OR (POLL.description IS NULL AND POLLA.description IS NOT NULL)
                   OR (POLL.description IS NOT NULL AND POLLA.description IS NULL)
	          )
        AND poll.po_release_id is NULL;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_shipments_control.description := 'N';
    END;

    BEGIN

      SELECT DISTINCT 'Y'
      INTO  x_shipments_control.work_approver_id
      FROM  PO_LINE_LOCATIONS_ALL POLL,
            PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
      WHERE POLL.po_header_id = x_po_header_id
        AND NVL(POLL.payment_type, 'NONE') NOT IN ('DELIVERY', 'ADVANCE')
        AND POLL.line_location_id = POLLA.line_location_id (+)
        AND POLLA.latest_external_flag (+) = 'Y'
        AND (
                      (POLLA.line_location_id is NULL)
                   OR (POLL.work_approver_id <> POLLA.work_approver_id)
                   OR (POLL.work_approver_id IS NULL AND POLLA.work_approver_id IS NOT NULL)
                   OR (POLL.work_approver_id IS NOT NULL AND POLLA.work_approver_id IS NULL)
	          )
        AND poll.po_release_id is NULL;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_shipments_control.work_approver_id := 'N';
    END;

  END IF;  -- x_po_header_id IS NOT NULL (complex work fields)

  -- <Complex Work R12 End>


	--<R12 Requester Driven Procurement End>

	/* <TIMEPHASED FPI END> */

        /* Bug 2808011 START */
        -- SQL What: Select 'Y' if price override is changed
        -- SQL Why: Need the value for routing to reapproval
        --          if there is a change
        -- SQL Join: line_location_id, price_override
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.price_override
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
                     POLL.po_header_id = x_po_header_id
               AND NVL(POLL.payment_type, 'NONE') <> 'DELIVERY'  -- <Complex Work R12>
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.price_override <> POLLA.price_override)
               OR (POLL.price_override IS NULL AND POLLA.price_override IS NOT NULL)
               OR (POLL.price_override IS NOT NULL AND POLLA.price_override IS NULL)
               )
             AND poll.po_release_id is NULL; -- Bug 4016493 : Ignore release shipments

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
                x_shipments_control.price_override := 'N';
          END;
        ELSE
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.price_override
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
                     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.price_override <> POLLA.price_override)
               OR (POLL.price_override IS NULL AND POLLA.price_override IS NOT NULL)
               OR (POLL.price_override IS NOT NULL AND POLLA.price_override IS NULL)
               );
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
                x_shipments_control.price_override := 'N';
          END;
        END IF;
        /* Bug 2808011 END */

	-- SQL What: Retrieving the percentage change in quantity
        -- SQL Why: Need the value in tolerance check (i.e reapproval
        --          rule validations)
        -- SQL Join: line_location_id
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
	       SELECT max(po_chord_wf0.percentage_change(
			 POLLA.quantity, POLL.quantity))
               INTO  x_shipments_control.quantity_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_header_id = x_po_header_id
               AND NVL(POLL.payment_type, 'NONE') <> 'DELIVERY'  -- <Complex Work R12>
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
             AND poll.po_release_id is NULL; -- Bug 4016493 : Ignore release shipments
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.quantity_change := 0;
          END;
        ELSE
          BEGIN
	       SELECT max(po_chord_wf0.percentage_change(
			 POLLA.quantity, POLL.quantity))
               INTO  x_shipments_control.quantity_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y';
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.quantity_change := 0;
          END;
        END IF;

	-- SQL What: Retrieving the percentage change in price override
        -- SQL Why: Need the value in tolerance check (i.e reapproval
        --          rule validations)
        -- SQL Join: line_location_id
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
	       SELECT max(po_chord_wf0.percentage_change(
			POLLA.price_override, POLL.price_override))
               INTO  x_shipments_control.price_override_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_header_id = x_po_header_id
               AND NVL(POLL.payment_type, 'NONE') <> 'DELIVERY'  -- <Complex Work R12>
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
             AND poll.po_release_id is NULL;  -- Bug 4016493 : Ignore release shipments
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.price_override_change := 0;
          END;
        ELSE
          BEGIN
	       SELECT max(po_chord_wf0.percentage_change(
			POLLA.price_override, POLL.price_override))
               INTO  x_shipments_control.price_override_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y';
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.price_override_change := 0;
          END;
        END IF;

	--<R12 Requester Driven Procurement Start>
	-- SQL What: Retrieving the percentage change in amount
        -- SQL Why: Need the value in tolerance check (i.e reapproval
        --          rule validations)
        -- SQL Join: line_location_id
        -- Bug 5071741: Amount change is calculated using price and qty for
        -- qty based lines and amount for services lines and rounded accordingly
        IF (x_po_header_id IS NOT NULL) THEN

          -- Get the currency code and precision
          SELECT poh.currency_code
          INTO   l_currency_code
          FROM   po_headers_all poh
          WHERE  poh.po_header_id = x_po_header_id;

          PO_CORE_S2.get_currency_info(
            x_currency_code => l_currency_code
          , x_min_unit      => l_min_acct_unit
          , x_precision     => l_precision);

          BEGIN
            IF l_min_acct_unit is not null AND
               l_min_acct_unit <> 0 THEN

	       SELECT max(po_chord_wf0.percentage_change(
                round(
		 decode(POLLA.value_basis, 'RATE',POLLA.amount,'FIXED PRICE', POLLA.amount,
                       (POLLA.quantity*POLLA.price_override)) / l_min_acct_unit )* l_min_acct_unit ,
                round(
                 decode(POLL.value_basis, 'RATE',POLL.amount,'FIXED PRICE', POLL.amount,
                       (POLL.quantity*POLL.price_override))  / l_min_acct_unit )* l_min_acct_unit
                ))
               INTO  x_shipments_control.amount_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_header_id = x_po_header_id
               -- <Complex Work R12>: "line level" info should be ignored.
               AND NVL(POLL.payment_type, 'NONE') NOT IN ('DELIVERY', 'ADVANCE')
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND poll.po_release_id is NULL;  -- Bug 4016493 : Ignore release shipments

            ELSE

                SELECT max(po_chord_wf0.percentage_change(
                round(
		 decode(POLLA.value_basis, 'RATE',POLLA.amount,'FIXED PRICE', POLLA.amount,
                       (POLLA.quantity*POLLA.price_override)) ,l_precision ) ,
                round(
                 decode(POLL.value_basis, 'RATE',POLL.amount,'FIXED PRICE', POLL.amount,
                       (POLL.quantity*POLL.price_override) ),l_precision )
                ))
               INTO  x_shipments_control.amount_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_header_id = x_po_header_id
               AND NVL(POLL.payment_type, 'NONE') NOT IN ('DELIVERY', 'ADVANCE')
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND poll.po_release_id is NULL;

             END IF;

          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.amount_change := 0;
          END;

        ELSE -- po_header_id null : release

          -- Get the currency code and precision
          SELECT poh.currency_code
          INTO   l_currency_code
          FROM   po_releases_all por,
                 po_headers_all poh
          WHERE  por.po_release_id = x_po_release_id
          AND    poh.po_header_id = por.po_header_id;

          PO_CORE_S2.get_currency_info(
            x_currency_code => l_currency_code
          , x_min_unit      => l_min_acct_unit
          , x_precision     => l_precision);

          BEGIN
            IF l_min_acct_unit is not null AND
               l_min_acct_unit <> 0 THEN

               SELECT max(po_chord_wf0.percentage_change(
                round(
		 decode(POLLA.value_basis,'FIXED PRICE', POLLA.amount,
                       (POLLA.quantity*POLLA.price_override)) / l_min_acct_unit )* l_min_acct_unit ,
                round(
                 decode(POLL.value_basis, 'FIXED PRICE', POLL.amount,
                       (POLL.quantity*POLL.price_override) ) / l_min_acct_unit )* l_min_acct_unit
                 ))
               INTO  x_shipments_control.amount_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y';

            ELSE

	       SELECT max(po_chord_wf0.percentage_change(
                round(
		 decode(POLLA.value_basis,'FIXED PRICE', POLLA.amount,
                       (POLLA.quantity*POLLA.price_override)) ,l_precision ) ,
                round(
                 decode(POLL.value_basis, 'FIXED PRICE', POLL.amount,
                       (POLL.quantity*POLL.price_override) ),l_precision )
                 ))
               INTO  x_shipments_control.amount_change
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y';
            END IF;

          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.amount_change := 0;
          END;

        END IF; -- po_header_id not null
	--<R12 Requester Driven Procurement End>

        -- ECO 5080252 Start
        -- SQL What: Select 'Y' if days late receipt allowed flag is changed
        -- SQL Why: Need the value for routing to reapproval if there is a change
        -- SQL Join: line_location_id, days late receipt allowed
        IF (x_po_header_id IS NOT NULL) THEN
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.days_late_rcpt_allowed
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_header_id = x_po_header_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.days_late_receipt_allowed <> POLLA.days_late_receipt_allowed)
               OR (POLL.days_late_receipt_allowed IS NULL
		   AND POLLA.days_late_receipt_allowed IS NOT NULL)
               OR (POLL.days_late_receipt_allowed IS NOT NULL
		   AND POLLA.days_late_receipt_allowed IS NULL)
	       )
             AND poll.po_release_id is NULL;
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.days_late_rcpt_allowed := 'N';
          END;
        ELSE
          BEGIN
               SELECT DISTINCT 'Y'
               INTO  x_shipments_control.days_late_rcpt_allowed
               FROM  PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA
               WHERE
		     POLL.po_release_id = x_po_release_id
               AND   POLL.line_location_id = POLLA.line_location_id (+)
               AND   POLLA.latest_external_flag (+) = 'Y'
               AND   (
                   (POLLA.line_location_id is NULL)
               OR (POLL.days_late_receipt_allowed <> POLLA.days_late_receipt_allowed)
               OR (POLL.days_late_receipt_allowed IS NULL
		   AND POLLA.days_late_receipt_allowed IS NOT NULL)
               OR (POLL.days_late_receipt_allowed IS NOT NULL
		   AND POLLA.days_late_receipt_allowed IS NULL)
	       );
          EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		x_shipments_control.days_late_rcpt_allowed := 'N';
          END;
        END IF;
        -- ECO 5080252 End

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish: check_shipments_change ***' );
	END IF;

EXCEPTION
	WHEN e_invalid_setup THEN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: set_wf_shipments_control ***');
	END IF;
	wf_core.context('POAPPRV', 'set_wf_shipments_control', 'e_invalid_setup');
	raise;

	WHEN others THEN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: set_wf_shipments_control ***');
	END IF;
	wf_core.context('POAPPRV', 'set_wf_shipments_control', 'others');
	raise;

END;

PROCEDURE set_wf_shipments_control( itemtype	IN VARCHAR2,
				    itemkey 	IN VARCHAR2,
			 	    x_shipments_control IN t_shipments_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: set_wf_shipments_control ***');
	END IF;

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_SHIPMENT_NUMBER',
			   x_shipments_control.shipment_num);


 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_SHIP_TO_ORGANIZATION',
			   x_shipments_control.ship_to_organization_id);


 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_SHIP_TO_LOCATION',
			   x_shipments_control.ship_to_location_id);

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_PROMISED_DATE',
			   x_shipments_control.promised_date);


 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_NEED_BY_DATE',
			   x_shipments_control.need_by_date);


 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_LAST_ACCEPT_DATE',
			   x_shipments_control.last_accept_date);

 -- ECO 5080252
 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_DAYS_LATE_RCPT_ALLOWED',
			   x_shipments_control.days_late_rcpt_allowed);

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_TAXABLE_FLAG',
			   x_shipments_control.taxable_flag);


 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_PRICE_DISCOUNT',
			   x_shipments_control.price_discount);


 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_CANCEL_FLAG',
			   x_shipments_control.cancel_flag);


 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_CLOSED_CODE',
			   x_shipments_control.closed_code);


 -- <Complex Work R12 Start>

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_PAYMENT_TYPE',
			   x_shipments_control.payment_type);

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_WORK_APPROVER_ID',
			   x_shipments_control.work_approver_id);

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_DESCRIPTION',
			   x_shipments_control.description);

 -- <Complex Work R12 End>

 PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_S_QUANTITY_CHANGE',
			     x_shipments_control.quantity_change);

 PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_S_PRICE_OVERRIDE_CHANGE',
			     x_shipments_control.price_override_change);

 /* <TIMEPHASED FPI START> */
 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_S_START_DATE',
                           x_shipments_control.start_date);

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_S_END_DATE',
                           x_shipments_control.end_date);
 /* <TIMEPHASED FPI END> */

/* Bug 2808011 START */
 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_S_PRICE_OVERRIDE',
                           x_shipments_control.price_override);
/* Bug 2808011 END */

--<R12 Requester Driven Procurement Start>

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_S_AMOUNT_CHANGE',
                           x_shipments_control.amount_change);

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_S_START_DATE_CHANGE',
                           x_shipments_control.start_date_change);

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_S_END_DATE_CHANGE',
                           x_shipments_control.end_date_change);

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_S_NEED_BY_DATE_DATE_CHANGE',
                           x_shipments_control.need_by_date_change);

 PO_WF_UTIL_PKG.SetItemAttrText(itemtype,
                           itemkey,
                           'CO_S_PROMISED_DATE_DATE_CHANGE',
                           x_shipments_control.promised_date_change);

--<R12 Requester Driven Procurement End>

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish: set_wf_shipments_control ***');
	END IF;

END;


PROCEDURE get_wf_shipments_control( itemtype	IN VARCHAR2,
				    itemkey 	IN VARCHAR2,
			 	    x_shipments_control IN OUT NOCOPY t_shipments_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: get_wf_shipments_control ***');
	END IF;

 x_shipments_control.shipment_num :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_SHIPMENT_NUMBER');

 x_shipments_control.ship_to_organization_id :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_SHIP_TO_ORGANIZATION');

 x_shipments_control.ship_to_location_id :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_SHIP_TO_LOCATION');

 x_shipments_control.promised_date :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_PROMISED_DATE');

 x_shipments_control.need_by_date :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_NEED_BY_DATE');

 x_shipments_control.last_accept_date:=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_LAST_ACCEPT_DATE');

 -- ECO 5080252
 x_shipments_control.days_late_rcpt_allowed :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_DAYS_LATE_RCPT_ALLOWED');

 x_shipments_control.taxable_flag :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_TAXABLE_FLAG');

 x_shipments_control.price_discount :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_PRICE_DISCOUNT');

 x_shipments_control.cancel_flag :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_CANCEL_FLAG');

 x_shipments_control.closed_code :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
			   itemkey,
			   'CO_S_CLOSED_CODE');

 x_shipments_control.quantity_change :=
 PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_S_QUANTITY_CHANGE');

 x_shipments_control.price_override_change :=
 PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_S_PRICE_OVERRIDE_CHANGE');

 /* <TIMEPHASED FPI START> */
 x_shipments_control.start_date :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_S_START_DATE');

 x_shipments_control.end_date :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_S_END_DATE');
 /* <TIMEPHASED FPI END> */

/* Bug 2808011 START */
 x_shipments_control.price_override :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_S_PRICE_OVERRIDE');
/* Bug 2808011 END */


 -- <Complex Work R12 Start>

 x_shipments_control.payment_type :=
  PO_WF_UTIL_PKG.GetItemAttrText(itemtype, itemkey, 'CO_S_PAYMENT_TYPE');

 x_shipments_control.work_approver_id :=
  PO_WF_UTIL_PKG.GetItemAttrText(itemtype, itemkey, 'CO_S_WORK_APPROVER_ID');

 x_shipments_control.description :=
  PO_WF_UTIL_PKG.GetItemAttrText(itemtype, itemkey, 'CO_S_DESCRIPTION');

 -- <Complex Work R12 End>


--<R12 Requester Driven Procurement Start>

 x_shipments_control.amount_change :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_S_AMOUNT_CHANGE');

 x_shipments_control.start_date_change :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_S_START_DATE_CHANGE');

 x_shipments_control.end_date_change :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_S_END_DATE_CHANGE');

 x_shipments_control.need_by_date_change :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_S_NEED_BY_DATE_DATE_CHANGE');

 x_shipments_control.promised_date_change :=
 PO_WF_UTIL_PKG.GetItemAttrText(itemtype,
                                itemkey,
                                'CO_S_PROMISED_DATE_DATE_CHANGE');

--<R12 Requester Driven Procurement End>

 debug_shipments_control(itemtype, itemkey, x_shipments_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish: get_wf_shipments_control ***');
	END IF;

END;

PROCEDURE get_wf_shipments_parameters(itemtype	 IN VARCHAR2,
				      itemkey 	 IN VARCHAR2,
			 	      x_shipments_parameters IN OUT NOCOPY t_shipments_parameters_type)
IS
	e_invalid_doc_type	EXCEPTION;
	x_doc_type		VARCHAR2(25);
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure get_wf_shipments_parameters ***');
	END IF;

  	x_doc_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype,
                                                 itemkey,
                                         	 'DOCUMENT_TYPE');

	IF x_doc_type IN ('PO', 'PA') THEN

 		x_shipments_parameters.po_header_id :=
		PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype,
					    itemkey,
				    	    'DOCUMENT_ID');

		x_shipments_parameters.po_release_id:=NULL;

        ELSIF x_doc_type = 'RELEASE' THEN

 		x_shipments_parameters.po_release_id :=
		PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype,
					    itemkey,
				    	    'DOCUMENT_ID');

		x_shipments_parameters.po_header_id:=NULL;

	ELSE
		raise e_invalid_doc_type;

	END IF;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'po_header_id =  ' || to_char(x_shipments_parameters.po_header_id));
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'po_release_id =  '|| to_char(x_shipments_parameters.po_release_id));
	END IF;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   	'*** FINISH: get_wf_shipments_parameters ***');
	END IF;

EXCEPTION
 WHEN e_invalid_doc_type THEN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'***set_wf_shipments_control exception e_invalid_setup *** ');
	END IF;
	wf_core.context('POAPPRV', 'set_wf_shipments_control', 'e_invalid_setup');
	raise;

 WHEN OTHERS THEN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** set_wf_shipments_control exception others ***');
	END IF;
	wf_core.context('POAPPRV', 'set_wf_shipments_control', 'others');
	raise;

END;


PROCEDURE debug_shipments_control(
		itemtype IN VARCHAR2,
		itemkey	 IN VARCHAR2,
		x_shipments_control IN t_shipments_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: debug_shipments_control ***');
	END IF;

 IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'shipment_num            : '||x_shipments_control.shipment_num);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'ship_to_organization_id : '||x_shipments_control.ship_to_organization_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'ship_to_location_id     : '||x_shipments_control.ship_to_location_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'promised_date           : '||x_shipments_control.promised_date);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'need_by_date            : '||x_shipments_control.need_by_date);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'last_accept_date        : '||x_shipments_control.last_accept_date);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'taxable_flag            : '||x_shipments_control.taxable_flag);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'price_discount          : '||x_shipments_control.price_discount);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'cancel_flag             : '||x_shipments_control.cancel_flag	);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'closed_code             : '||x_shipments_control.closed_code	);
    -- <Complex Work R12 Start>
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'payment_type            : '||x_shipments_control.payment_type	);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'work_approver_id        : '||x_shipments_control.work_approver_id	);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'description             : '||x_shipments_control.description	);
    -- <Complex Work R12 End>
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'quantity_change         : '||to_char(x_shipments_control.quantity_change));
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'price_override_change   : '||to_char(x_shipments_control.price_override_change));
 END IF;

 /* <TIMEPHASED FPI START> */
 IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'start_date              : '||x_shipments_control.start_date   );
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'end_date                : '||x_shipments_control.end_date   );
    /* Bug 2808011 */
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'price_override          : '||x_shipments_control.price_override);
 END IF;
 /* <TIMEPHASED FPI END> */


 --<R12 Requester Driven Procurement Start>
 IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'amount_change                : '||x_shipments_control.amount_change   );
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'start_date_change            : '||x_shipments_control.start_date_change   );
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'end_date_change              : '||x_shipments_control.end_date_change   );
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'need_by_date_change          : '||x_shipments_control.need_by_date_change   );
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'promised_date_change         : '||x_shipments_control.promised_date_change   );

 END IF;
 --<R12 Requester Driven Procurement End>

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finished: debug_shipments_control ***');
	END IF;
END;

END PO_CHORD_WF3;

/
