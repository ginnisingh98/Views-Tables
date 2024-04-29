--------------------------------------------------------
--  DDL for Package Body PO_CHORD_WF1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHORD_WF1" AS
/* $Header: POXWCO1B.pls 120.6 2008/02/21 22:03:00 jburugul ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

PROCEDURE chord_hd(itemtype IN VARCHAR2,
		   itemkey  IN VARCHAR2,
		   actid    IN NUMBER,
		   funcmode IN VARCHAR2,
		   result   OUT NOCOPY VARCHAR2)
IS
	x_header_control	t_header_control_type;
	x_header_parameters	t_header_parameters_type;
        l_org_id                PO_HEADERS_ALL.org_id%TYPE; --<BUG 3254056>

BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In Procedure: chord_hd ***' );
	END IF;

	IF funcmode <> 'RUN' THEN
		result := 'COMPLETE';
		return;
	END IF;

        /* Bug# 2353153
        ** Setting application context
        */

        -- Context Setting revamp
        -- PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);

        --<BUG 3254056 START>
        l_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'ORG_ID');

        IF l_org_id IS NOT NULL THEN
           PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>
        END IF;
        --<BUG 3254056 END>

	get_wf_header_parameters(itemtype, itemkey, x_header_parameters);

	check_header_change(itemtype, itemkey, x_header_parameters, x_header_control);

	set_wf_header_control(itemtype, itemkey, x_header_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish: chord_hd ***' );
	END IF;

	result := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
	return;

EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_chord_wf1.chord_hd', 'others');
  RAISE;

END;

PROCEDURE check_header_change(itemtype	IN 	VARCHAR2,
			      itemkey	IN	VARCHAR2,
			      x_header_parameters IN t_header_parameters_type,
			      x_header_control IN OUT NOCOPY t_header_control_type)
IS
	x_po_header_id			NUMBER;
        l_document_type 		PO_DOCUMENT_TYPES_ALL.DOCUMENT_TYPE_CODE%TYPE;
        l_document_subtype 		PO_DOCUMENT_TYPES_ALL.DOCUMENT_SUBTYPE%TYPE;

BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In Procedure check_header_change ***');
	END IF;

		/* To use change order,
		 * System should have Archive on Approval set
		 */

		/* initialize */

		x_header_control.agent_id       		:= 'N';
		x_header_control.vendor_site_id			:= 'N';
		x_header_control.ship_to_location_id     	:= 'N';
		x_header_control.bill_to_location_id     	:= 'N';
		x_header_control.terms_id       		:= 'N';
		x_header_control.ship_via_lookup_code    	:= 'N';
		x_header_control.fob_lookup_code       		:= 'N';
		x_header_control.freight_terms_lookup_code	:= 'N';
		x_header_control.note_to_vendor      		:= 'N';
		x_header_control.confirming_order_flag	      	:= 'N';
		x_header_control.acceptance_required_flag       := 'N';
		x_header_control.acceptance_due_date        	:= 'N';
		x_header_control.start_date		       	:= 'N';
		x_header_control.end_date		       	:= 'N';
		x_header_control.cancel_flag		       	:= 'N';

	        /* Percentage Change */
		x_header_control.blanket_total_change		:=0;
		x_header_control.amount_limit_change		:=0;
		x_header_control.po_total_change		:=0;

		/* po_acceptance Table */
		x_header_control.po_acknowledged	:='N';
		x_header_control.po_accepted		:='N';

/* Added following for Bug 6616522 */
                x_header_control.amount_limit      := 'N';

		x_po_header_id	  := x_header_parameters.po_header_id;

   /* Each of the following select statement maps to one attribute.
    * It is written like this for clarity.  Since each statemet consists
    * of one index access and one range scan, performance should not
    * suffer too much.
    * However, they can be combined into one sql statement
    * for slight performance gain.
    */

   BEGIN
                -- SQL What: Select 'Y' if agent id is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, agent_id
                SELECT DISTINCT 'Y'
                INTO  x_header_control.agent_id
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.agent_id <> POHA.agent_id));
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.agent_id :='N';
   END;

   BEGIN
                -- SQL What: Select 'Y' if vendor site id is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, vendor_site_id
                SELECT DISTINCT 'Y'
                INTO  x_header_control.vendor_site_id
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.vendor_site_id <> POHA.vendor_site_id)
                OR (POH.vendor_site_id IS NULL
                         AND POHA.vendor_site_id IS NOT NULL)
                OR (POH.vendor_site_id IS NOT NULL
                         AND POHA.vendor_site_id IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.vendor_site_id :='N';
   END;

   BEGIN
                -- SQL What: Select 'Y' if vendor contact id is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, vendor_contact_id
                SELECT DISTINCT 'Y'
                INTO  x_header_control.vendor_contact_id
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.vendor_contact_id <> POHA.vendor_contact_id)
                OR (POH.vendor_contact_id IS NULL
                         AND POHA.vendor_contact_id IS NOT NULL)
                OR (POH.vendor_contact_id IS NOT NULL
                         AND POHA.vendor_contact_id IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.vendor_contact_id :='N';
   END;

   BEGIN
                -- SQL What: Select 'Y' if Ship to location is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, ship_to_location_id
                SELECT DISTINCT 'Y'
                INTO  x_header_control.ship_to_location_id
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.ship_to_location_id <> POHA.ship_to_location_id)
                OR (POH.ship_to_location_id IS NULL
                         AND POHA.ship_to_location_id IS NOT NULL)
                OR (POH.ship_to_location_id IS NOT NULL
                         AND POHA.ship_to_location_id IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.ship_to_location_id :='N';
   END;

   BEGIN
                -- SQL What: Select 'Y' if bill to location is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, bill_to_location_id
                SELECT DISTINCT 'Y'
                INTO  x_header_control.bill_to_location_id
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.bill_to_location_id <> POHA.bill_to_location_id)
                OR (POH.bill_to_location_id IS NULL
                         AND POHA.bill_to_location_id IS NOT NULL)
                OR (POH.bill_to_location_id IS NOT NULL
                         AND POHA.bill_to_location_id IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.bill_to_location_id :='N';
   END;


   BEGIN
               -- SQL What: Select 'Y' if terms id is changed
               -- SQL Why: Need the value for routing to reapproval
               --          if there is a change
               -- SQL Join: po_header_id, terms_id
               SELECT DISTINCT 'Y'
                INTO  x_header_control.terms_id
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.terms_id <> POHA.terms_id)
                OR (POH.terms_id IS NULL
                         AND POHA.terms_id IS NOT NULL)
                OR (POH.terms_id IS NOT NULL
                         AND POHA.terms_id IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.terms_id :='N';
   END;


   BEGIN
                -- SQL What: Select 'Y' if ship lookup code is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, ship_via_lookup_code
                SELECT DISTINCT 'Y'
                INTO  x_header_control.ship_via_lookup_code
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.ship_via_lookup_code <> POHA.ship_via_lookup_code)
                OR (POH.ship_via_lookup_code IS NULL
                         AND POHA.ship_via_lookup_code IS NOT NULL)
                OR (POH.ship_via_lookup_code IS NOT NULL
                         AND POHA.ship_via_lookup_code IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.ship_via_lookup_code :='N';
   END;


   BEGIN
                -- SQL What: Select 'Y' if fob is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, fob_lookup_code
                SELECT DISTINCT 'Y'
                INTO  x_header_control.fob_lookup_code
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.fob_lookup_code <> POHA.fob_lookup_code)
                OR (POH.fob_lookup_code IS NULL
                         AND POHA.fob_lookup_code IS NOT NULL)
                OR (POH.fob_lookup_code IS NOT NULL
                         AND POHA.fob_lookup_code IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.fob_lookup_code :='N';
   END;

   BEGIN
                -- SQL What: Select 'Y' if frieght terms is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, freight_terms_lookup_code
                SELECT DISTINCT 'Y'
                INTO  x_header_control.freight_terms_lookup_code
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.freight_terms_lookup_code <> POHA.freight_terms_lookup_code)
                OR (POH.freight_terms_lookup_code IS NULL
                         AND POHA.freight_terms_lookup_code IS NOT NULL)
                OR (POH.freight_terms_lookup_code IS NOT NULL
                         AND POHA.freight_terms_lookup_code IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.freight_terms_lookup_code :='N';
   END;


   BEGIN
                -- SQL What: Select 'Y' if note to vendor is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, note_to_vendor
                SELECT DISTINCT 'Y'
                INTO  x_header_control.note_to_vendor
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.note_to_vendor <> POHA.note_to_vendor)
                OR (POH.note_to_vendor IS NULL
                         AND POHA.note_to_vendor IS NOT NULL)
                OR (POH.note_to_vendor IS NOT NULL
                         AND POHA.note_to_vendor IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.note_to_vendor :='N';
   END;


   BEGIN
                -- SQL What: Select 'Y' if confrim order flag is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, confirming_order_flag
                SELECT DISTINCT 'Y'
                INTO  x_header_control.confirming_order_flag
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.confirming_order_flag <> POHA.confirming_order_flag)
                OR (POH.confirming_order_flag IS NULL
                         AND POHA.confirming_order_flag IS NOT NULL)
                OR (POH.confirming_order_flag IS NOT NULL
                         AND POHA.confirming_order_flag IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.confirming_order_flag :='N';
   END;

   BEGIN
                -- SQL What: Select 'Y' if acceptance req flag is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, acceptance_required_flag
                SELECT DISTINCT 'Y'
                INTO  x_header_control.acceptance_required_flag
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.acceptance_required_flag <> POHA.acceptance_required_flag)
                OR (POH.acceptance_required_flag IS NULL
                         AND POHA.acceptance_required_flag IS NOT NULL)
                OR (POH.acceptance_required_flag IS NOT NULL
                         AND POHA.acceptance_required_flag IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.acceptance_required_flag :='N';
   END;

   BEGIN
                -- SQL What: Select 'Y' if acceptance due date is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, acceptance_due_date
                SELECT DISTINCT 'Y'
                INTO  x_header_control.acceptance_due_date
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.acceptance_due_date <> POHA.acceptance_due_date)
                OR (POH.acceptance_due_date IS NULL
                         AND POHA.acceptance_due_date IS NOT NULL)
                OR (POH.acceptance_due_date IS NOT NULL
                         AND POHA.acceptance_due_date IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.acceptance_due_date :='N';
   END;

   BEGIN
        -- SQL What: Select Y if start date changed
        -- SQL Why: Need the value in tolerance check (i.e reapproval
        --          rule validations)
        -- SQL Join: po_header_id
	SELECT DISTINCT 'Y'
	INTO  x_header_control.start_date
	FROM   PO_HEADERS_all POH,
		PO_HEADERS_ARCHIVE_all POHA
	WHERE  POH.po_header_id = x_po_header_id
	AND    POH.po_header_id = POHA.po_header_id (+)
	AND    POHA.latest_external_flag (+) = 'Y'
        AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.start_date <> POHA.start_date)
                OR (POH.start_date IS NULL
                         AND POHA.start_date IS NOT NULL)
                OR (POH.start_date IS NOT NULL
                         AND POHA.start_date IS NULL)
		);

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	x_header_control.start_date :='N';
   END;

   BEGIN
        -- SQL What: Select Y if start date changed
        -- SQL Why: Need the value in tolerance check (i.e reapproval
        --          rule validations)
        -- SQL Join: po_header_id
	SELECT DISTINCT 'Y'
	INTO  x_header_control.end_date
	FROM   PO_HEADERS_all POH,
	       PO_HEADERS_ARCHIVE_all POHA
	WHERE  POH.po_header_id = x_po_header_id
	AND    POH.po_header_id = POHA.po_header_id (+)
	AND    POHA.latest_external_flag (+) = 'Y'
        AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.end_date <> POHA.end_date)
                OR (POH.end_date IS NULL
                         AND POHA.end_date IS NOT NULL)
                OR (POH.end_date IS NOT NULL
                         AND POHA.end_date IS NULL)
		);

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	x_header_control.end_date :='N';
   END;

   BEGIN
                -- SQL What: Select 'Y' if cancel flag is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
                -- SQL Join: po_header_id, cancel_flag
                SELECT DISTINCT 'Y'
                INTO  x_header_control.cancel_flag
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   (
                      ( POHA.po_header_id IS NULL)
                OR (POH.cancel_flag <> POHA.cancel_flag)
                OR (POH.cancel_flag IS NULL
                         AND POHA.cancel_flag IS NOT NULL)
                OR (POH.cancel_flag IS NOT NULL
                         AND POHA.cancel_flag IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.cancel_flag :='N';
   END;

   BEGIN
/* Bug# 1151387: frkhan
** Desc: The SQL was resulting in division by zero when the value
**       of POHA.blanket_total_amount was 0.
** Modified the divisor in the select statement
** from:        nvl(POHA.blanket_total_amount,1)
** to:          decode(nvl(POHA.blanket_total_amount,0),0,1,
**                     POHA.blanket_total_amount)
*/
                 -- SQL What: Retrieving the percentage change in
                 --           blanket total amount
                 -- SQL Why: Need the value in tolerance check (i.e reapproval
                 --          rule validations)
                 -- SQL Join: po_header_id
                SELECT max((nvl(POH.blanket_total_amount,0)
			    -nvl(POHA.blanket_total_amount,0))
			   / decode(nvl(POHA.blanket_total_amount,0),0,1,
                                    POHA.blanket_total_amount)*100)
                INTO  x_header_control.blanket_total_change
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y';
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.blanket_total_change := 0;
   END;


/* Bug# 6616522: jburugul
 *  * ** Desc: Added following SQL to capture changes when amount limit
 *   * ** is made null
 *    * */

BEGIN
                SELECT DISTINCT 'Y'
                INTO  x_header_control.amount_limit
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y'
                AND   ((POH.amount_limit IS NULL AND
                       POHA.amount_limit IS NOT NULL)
                );
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
                x_header_control.amount_limit :='N';
   END;

/* end of Bug 6616522 */



   BEGIN
/* Bug# 1151387: frkhan
** Desc: The SQL was resulting in division by zero when the value
**       of POHA.amount_limit was 0.
** Modified the divisor in the select statement
** from:	nvl(POHA.amount_limit,1)
** to:		decode(nvl(POHA.amount_limit,0),0,1,POHA.amount_limit)
*/
                 -- SQL What: Retrieving the percentage change in
                 --           amount limit
                 -- SQL Why: Need the value in tolerance check (i.e reapproval
                 --          rule validations)
                 -- SQL Join: po_header_id
                SELECT max((nvl(POH.amount_limit,0)
			    -nvl(POHA.amount_limit,0))
		   / decode(nvl(POHA.amount_limit,0),0,1,POHA.amount_limit)
			   *100)
                INTO  x_header_control.amount_limit_change
                FROM   PO_HEADERS_all POH,
                PO_HEADERS_ARCHIVE_all POHA
                WHERE  POH.po_header_id = x_po_header_id
                AND    POH.po_header_id = POHA.po_header_id (+)
                AND    POHA.latest_external_flag (+) = 'Y';
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.amount_limit_change := 0;
   END;

   BEGIN
                -- SQL What: Select 'Y' if po_acknowledged is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
	        SELECT DISTINCT 'Y'
		INTO   x_header_control.po_acknowledged
                FROM   PO_ACCEPTANCES PA
                WHERE  PA.po_header_id = x_po_header_id;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.po_acknowledged:='N';
   END;

   BEGIN
                -- SQL What: Select 'Y' if po_accepted is changed
                -- SQL Why: Need the value for routing to reapproval
                --          if there is a change
	        SELECT DISTINCT 'Y'
		INTO   x_header_control.po_accepted
                FROM   PO_ACCEPTANCES PA
                WHERE  PA.po_header_id = x_po_header_id
		AND    PA.accepted_flag = 'Y';
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_header_control.po_accepted:='N';
   END;

/* Bug# 2427993: kagarwal
** Desc: For Blanket Agreements (Blanket Purchase Orders), the shipments
** and distributions do not exist hence there is no need to calculate the
** po total change. Morever this is not even considered in blanket_po_reapproval.
*/

   l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'DOCUMENT_TYPE');

   l_document_subtype := wf_engine.GetItemAttrText (itemtype =>itemtype,
                                                itemkey => itemkey,
                                                aname => 'DOCUMENT_SUBTYPE');

   if ((l_document_type = 'PA') and (l_document_subtype = 'BLANKET')) then
        x_header_control.po_total_change := 0;
   else
        x_header_control.po_total_change := po_total_change(x_po_header_id);
   end if;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish check_header_change ***');
	END IF;

EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'check_header_change', 'others');
  RAISE;

END;

FUNCTION po_total_change(x_po_header_id IN NUMBER) return NUMBER
IS
	x_po_total			NUMBER;
	x_po_total_archive		NUMBER;
	x_base_currency  		VARCHAR2(16);
	x_po_currency    		VARCHAR2(16);
	x_min_unit       		NUMBER;
	x_base_min_unit  		NUMBER;
	x_precision      		INTEGER;
	x_base_precision 		INTEGER;
	x_total_change			NUMBER;
BEGIN

   /* Find the percentage change for po_total */

  po_core_s2.get_po_currency (x_po_header_id,
	                      x_base_currency,
                              x_po_currency );

  IF x_base_currency <> x_po_currency THEN

        po_core_s2.get_currency_info (x_po_currency,
                           x_precision,
                           x_min_unit );

        po_core_s2.get_currency_info (x_base_currency,
                           x_base_precision,
                           x_base_min_unit );

/* Bug #: 1415223 draising
   Forward fix of Bug # 1377624
   Modified the SQL statements to take header_id from PO_DISTRIBUTIONS_ALL
   table (for example : POLLA.po_header_id = x_po_header_id is changed to
   PODA.po_header_id = x_po_header_id) to improve the performance
   of sql statements.
*/
/*
   Bug # 5172716
   Modified the statements to calculate amount information from amount_ordered and
   amount_cancelled fields when the matching basis is AMOUNT.
*/

    Begin
            SELECT
                 nvl(round(round(sum(
                                      DECODE(POLL.matching_basis
                                      , 'AMOUNT',
                                      (nvl(POD.amount_ordered, 0) -
                                       nvl(POD.amount_cancelled, 0)) *
                                       nvl(POD.rate,1) /
                                       nvl(X_min_unit,1)
                                      , --QUANTITY
                                      (nvl(POD.quantity_ordered, 0) -
                                       nvl(POD.quantity_cancelled, 0)) *
                                       nvl(POLL.price_override, 0) *
                                       nvl(POD.rate,1) /
                                       nvl(X_min_unit,1))
                                      )
                                  * nvl(X_min_unit,1)/ nvl(X_base_min_unit,1)
                                 )
                               * nvl(X_base_min_unit,1)) , 0)
            INTO   x_po_total
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL POLL
            WHERE  POD.po_header_id = x_po_header_id
            AND    POLL.shipment_type in ('STANDARD','PLANNED','BLANKET')
            AND    POLL.line_location_id = POD.line_location_id;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_po_total := 0;

    End;

    Begin
            SELECT
                 nvl(round(round(sum(
                                      DECODE(POLLA.matching_basis
                                      , 'AMOUNT',
                                      (nvl(PODA.amount_ordered, 0) -
                                       nvl(PODA.amount_cancelled, 0)) *
                                       nvl(PODA.rate,1) /
                                       nvl(X_min_unit,1)
                                      , --QUANTITY
                                      (nvl(PODA.quantity_ordered, 0) -
                                       nvl(PODA.quantity_cancelled, 0)) *
                                       nvl(POLLA.price_override, 0) *
                                       nvl(PODA.rate,1) /
                                       nvl(X_min_unit,1))
                                      )
                                  * nvl(X_min_unit,1)/ nvl(X_base_min_unit,1)
                                 )
                               * nvl(X_base_min_unit,1)) , 0)
            INTO   x_po_total_archive
	          FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA,
     		   PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
            WHERE  PODA.po_header_id = x_po_header_id
            AND    POLLA.latest_external_flag (+) = 'Y'
            AND    PODA.latest_external_flag (+) = 'Y'
            AND    POLLA.shipment_type in ('STANDARD','PLANNED','BLANKET')
            AND    POLLA.line_location_id = PODA.line_location_id;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_po_total_archive :=0;

    End;

  ELSE 	/* base currency = po_currrency */

   Begin
            SELECT sum(
                        DECODE(POLL.matching_basis
                                  , 'AMOUNT',
                                 (nvl(POD.amount_ordered, 0) -
                                  nvl(POD.amount_cancelled, 0))
                                  , --QUANTITY
                                 (nvl(POD.quantity_ordered, 0) -
                                  nvl(POD.quantity_cancelled, 0)) *
                                  nvl(POLL.price_override, 0)))
            INTO   x_po_total
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL POLL
            WHERE  POD.po_header_id = x_po_header_id
            AND    POLL.shipment_type in ('STANDARD','PLANNED','BLANKET')
            AND    POLL.line_location_id = POD.line_location_id;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_po_total :=0;

    End;

 /* bug# 880416 : brought forward the changes form release 11 fixed by
    csheu (bug# 875997). added the line POLLA.po_header_id = PODA.po_header_id.    to improve performance.
 */

    Begin
            SELECT sum(
                        DECODE(POLLA.matching_basis
                                  , 'AMOUNT',
                                 (nvl(PODA.amount_ordered, 0) -
                                  nvl(PODA.amount_cancelled, 0))
                                  , --QUANTITY
                                 (nvl(PODA.quantity_ordered, 0) -
                                  nvl(PODA.quantity_cancelled, 0)) *
                                  nvl(POLLA.price_override, 0)))
            INTO   x_po_total_archive
            FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA,
                   PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
            WHERE  PODA.po_header_id = x_po_header_id
            AND    POLLA.latest_external_flag (+) = 'Y'
            AND    PODA.latest_external_flag (+) = 'Y'
            AND    POLLA.shipment_type in ('STANDARD','PLANNED','BLANKET')
            AND    POLLA.line_location_id = PODA.line_location_id
            AND    PODA.po_header_id = POLLA.po_header_id;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_po_total_archive :=0;

   End;

  END IF;

  x_total_change := PO_CHORD_WF0.percentage_change(x_po_total_archive,
						    x_po_total);

  return(round(x_total_change,2));

EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_total_change', 'others');

END;


PROCEDURE set_wf_header_control(itemtype		IN VARCHAR2,
				itemkey			IN VARCHAR2,
				x_header_control 	IN t_header_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure set_wf_header_control ***');
	END IF;

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_AGENT_MODIFIED',
			   x_header_control.agent_id);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_VENDOR_SITE_MODIFIED',
			   x_header_control.vendor_site_id);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_VENDOR_CONTACT_MODIFIED',
			   x_header_control.vendor_contact_id);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_SHIP_TO_MODIFIED',
			   x_header_control.ship_to_location_id);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_BILL_TO_MODIFIED',
			   x_header_control.bill_to_location_id);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_TERMS_MODIFIED',
			   x_header_control.terms_id);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_SHIP_VIA_MODIFIED',
			   x_header_control.ship_via_lookup_code);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_FOB_MODIFIED',
			   x_header_control.fob_lookup_code);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_FREIGHT_MODIFIED',
			   x_header_control.freight_terms_lookup_code);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_NOTE_TO_VENDOR_MODIFIED',
			   x_header_control.note_to_vendor);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_CONFIRMING_ORDER_MODIFIED',
			   x_header_control.confirming_order_flag);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_ACCEPT_REQUIRED_MODIFIED',
			   x_header_control.acceptance_required_flag);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_ACCEPT_DUE_MODIFIED',
			   x_header_control.acceptance_due_date);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_START_DATE_MODIFIED',
			   x_header_control.start_date);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_END_DATE_MODIFIED',
			   x_header_control.end_date);


 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_CANCEL_FLAG',
			   x_header_control.cancel_flag);

 wf_engine.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_H_BLANKET_TOTAL_CHANGE',
			     x_header_control.blanket_total_change);

 wf_engine.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_H_AMOUNT_LIMIT_CHANGE',
			     x_header_control.amount_limit_change);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_PO_ACKNOWLEDGED',
			   x_header_control.po_acknowledged);

 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_H_PO_ACCEPTED',
			   x_header_control.po_accepted);

 wf_engine.SetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_H_PO_TOTAL_CHANGE',
			     x_header_control.po_total_change);

/* Added following for Bug 6616522  */

 wf_engine.SetItemAttrText(itemtype,
                             itemkey,
                             'CO_H_AMOUNT_LIMIT_MODIFIED',
                             x_header_control.amount_limit);

	--debug_header_control(itemtype, itemkey, x_header_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish set_wf_header_control ***');
	END IF;

END;

PROCEDURE get_wf_header_control(itemtype	 IN VARCHAR2,
				itemkey 	 IN VARCHAR2,
			 	x_header_control IN OUT NOCOPY t_header_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure get_wf_header_control ***');
	END IF;

	x_header_control.agent_id :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_AGENT_MODIFIED');

	x_header_control.vendor_site_id :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_VENDOR_SITE_MODIFIED');

	x_header_control.vendor_contact_id :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_VENDOR_CONTACT_MODIFIED');

	x_header_control.ship_to_location_id :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_SHIP_TO_MODIFIED');

	x_header_control.bill_to_location_id  :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_BILL_TO_MODIFIED');

	x_header_control.terms_id :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_TERMS_MODIFIED');

	x_header_control.ship_via_lookup_code :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_SHIP_VIA_MODIFIED');

	x_header_control.fob_lookup_code :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_FOB_MODIFIED');

	x_header_control.freight_terms_lookup_code :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_FREIGHT_MODIFIED');

	x_header_control.note_to_vendor :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_NOTE_TO_VENDOR_MODIFIED');

	x_header_control.confirming_order_flag :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_CONFIRMING_ORDER_MODIFIED');

	x_header_control.acceptance_required_flag :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_ACCEPT_REQUIRED_MODIFIED');

	x_header_control.acceptance_due_date :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_ACCEPT_DUE_MODIFIED');

	x_header_control.start_date :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_START_DATE_MODIFIED');

	x_header_control.end_date :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_END_DATE_MODIFIED');

	x_header_control.cancel_flag :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_H_CANCEL_FLAG');

	x_header_control.blanket_total_change :=
		wf_engine.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_H_BLANKET_TOTAL_CHANGE');

	x_header_control.amount_limit_change :=
	 	wf_engine.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_H_AMOUNT_LIMIT_CHANGE');

	x_header_control.po_acknowledged:=
		 wf_engine.GetItemAttrText(itemtype,
			itemkey,
			'CO_H_PO_ACKNOWLEDGED');

	x_header_control.po_accepted:=
		 wf_engine.GetItemAttrText(itemtype,
			itemkey,
			'CO_H_PO_ACCEPTED');

	x_header_control.po_total_change:=
		 wf_engine.GetItemAttrNumber(itemtype,
			     itemkey,
			     'CO_H_PO_TOTAL_CHANGE');

 /* Added following for Bug 6616522 */
        x_header_control.amount_limit:=
           wf_engine.GetItemAttrText(itemtype,
                         itemkey,
                         'CO_H_AMOUNT_LIMIT_MODIFIED');

	debug_header_control(itemtype, itemkey, x_header_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** FINISH: get_wf_header_control ***');
	END IF;
END;

PROCEDURE get_wf_header_parameters(itemtype	 IN VARCHAR2,
				itemkey 	 IN VARCHAR2,
			 	x_header_parameters IN OUT NOCOPY t_header_parameters_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure get_wf_header_parameters ***');
	END IF;

	x_header_parameters.po_header_id :=
		wf_engine.GetItemAttrNumber(itemtype,
					    itemkey,
				    	    'DOCUMENT_ID');

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'po_header_id = '|| to_char(x_header_parameters.po_header_id));
	END IF;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** FINISH: get_wf_header_parameters ***');
	END IF;

EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'get_wf_headers_paramters', 'others');
  RAISE;

END;

PROCEDURE debug_header_control(itemtype	IN VARCHAR2,
			       itemkey	IN VARCHAR2,
			       x_header_control IN t_header_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: debug_header_control ***');
	END IF;

 IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'agent_id                 : ' ||x_header_control.agent_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'vendor_site_id           : ' ||x_header_control.vendor_site_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'vendor_contact_id 	  : ' ||x_header_control.vendor_contact_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'ship_to_location_id 	  : ' ||x_header_control.ship_to_location_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'bill_to_location_id 	  : ' ||x_header_control.bill_to_location_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'terms_id 		  : ' ||x_header_control.terms_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'ship_via_lookup_code 	  : ' ||x_header_control.ship_via_lookup_code);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'fob_lookup_code          : ' ||x_header_control.fob_lookup_code);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'freight_terms_lookup_code: ' ||x_header_control.freight_terms_lookup_code);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'note_to_vendor           : ' ||x_header_control.note_to_vendor);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'confirming_order_flag    : ' ||x_header_control.confirming_order_flag);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'acceptance_required_flag : ' ||x_header_control.acceptance_required_flag);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'acceptance_due_date      : ' ||x_header_control.acceptance_due_date);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'start_date               : ' ||x_header_control.start_date);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'end_date                 : ' ||x_header_control.end_date);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'cancel_flag              : ' ||x_header_control.cancel_flag);
 END IF;

 IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'blanket_total_change     : ' ||to_char(x_header_control.blanket_total_change));
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'amount_limit_change      : ' ||to_char(x_header_control.amount_limit_change));
 END IF;

 IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'po_acknowledged          : ' ||x_header_control.po_acknowledged);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'po_accepted              : ' ||x_header_control.po_accepted);
 END IF;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finished: debug_header_control ***');
	END IF;
END;

END PO_CHORD_WF1;

/
