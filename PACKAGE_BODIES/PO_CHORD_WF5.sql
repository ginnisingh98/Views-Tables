--------------------------------------------------------
--  DDL for Package Body PO_CHORD_WF5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHORD_WF5" AS
/* $Header: POXWCO5B.pls 115.4 2002/11/25 22:36:01 sbull ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

PROCEDURE chord_release(itemtype IN VARCHAR2,
			   itemkey  IN VARCHAR2,
			   actid    IN NUMBER,
			   FUNCMODE IN VARCHAR2,
			   RESULT   OUT NOCOPY VARCHAR2)

IS
	x_release_control	t_release_control_type;
	x_release_parameters	t_release_parameters_type;
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.insert_debug(ITEMTYPE, ITEMKEY,
   		'*** In Procedure: chord_release ***' );
	END IF;

	If funcmode <> 'RUN' THEN
		result := 'COMPLETE';
		return;
	END IF;

	get_wf_release_parameters(itemtype, itemkey, x_release_parameters);

	check_release_change(itemtype, itemkey, x_release_parameters, x_release_control);

	set_wf_release_control(itemtype, itemkey, x_release_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish: chord_release ***' );
	END IF;

	result := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
	return;

EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_chord_wf5.chord_release', 'others');
  RAISE;

END;

PROCEDURE check_release_change(
		itemtype IN VARCHAR2,
		itemkey  IN VARCHAR2,
		x_release_parameters IN t_release_parameters_type,
		x_release_control IN OUT NOCOPY t_release_control_type)
IS
	x_po_release_id			NUMBER;
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In Procedure check_release_change ***');
	END IF;

	x_release_control.agent_id			:='N';
	x_release_control.acceptance_required_flag	:='N';
	x_release_control.acceptance_due_date		:='N';
	x_release_control.release_num			:='N';
	x_release_control.release_date			:='N';

	x_po_release_id	:= x_release_parameters.po_release_id;

   BEGIN
               SELECT DISTINCT 'Y'
               INTO   x_release_control.agent_id
               FROM   PO_RELEASES_all POR,
                      PO_RELEASES_ARCHIVE_all PORA
               WHERE  POR.po_release_id = x_po_release_id
               AND    POR.po_release_id = PORA.po_release_id
               AND    PORA.latest_external_flag (+) = 'Y'
               AND    (
                   (PORA.po_release_id IS NULL)
                OR (POR.agent_id <> PORA.agent_id)
                OR (POR.agent_id IS NULL
			AND  PORA.agent_id IS NOT NULL)
                OR (POR.agent_id IS NOT NULL
			AND PORA.agent_id IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_release_control.agent_id :='N';
   END;


   BEGIN
               SELECT DISTINCT 'Y'
               INTO   x_release_control.acceptance_required_flag
               FROM   PO_RELEASES_all POR,
                      PO_RELEASES_ARCHIVE_all PORA
               WHERE  POR.po_release_id = x_po_release_id
               AND    POR.po_release_id = PORA.po_release_id
               AND    PORA.latest_external_flag (+) = 'Y'
               AND    (
                   (PORA.po_release_id IS NULL)
                OR (POR.acceptance_required_flag <> PORA.acceptance_required_flag)
                OR (POR.acceptance_required_flag IS NULL
			AND  PORA.acceptance_required_flag IS NOT NULL)
                OR (POR.acceptance_required_flag IS NOT NULL
			AND PORA.acceptance_required_flag IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_release_control.acceptance_required_flag :='N';
   END;


   BEGIN
               SELECT DISTINCT 'Y'
               INTO   x_release_control.acceptance_due_date
               FROM   PO_RELEASES_all POR,
                      PO_RELEASES_ARCHIVE_all PORA
               WHERE  POR.po_release_id = x_po_release_id
               AND    POR.po_release_id = PORA.po_release_id
               AND    PORA.latest_external_flag (+) = 'Y'
               AND    (
                   (PORA.po_release_id IS NULL)
                OR (POR.acceptance_due_date <> PORA.acceptance_due_date)
                OR (POR.acceptance_due_date IS NULL
			AND  PORA.acceptance_due_date IS NOT NULL)
                OR (POR.acceptance_due_date IS NOT NULL
			AND PORA.acceptance_due_date IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_release_control.acceptance_due_date :='N';
   END;


   BEGIN
               SELECT DISTINCT 'Y'
               INTO   x_release_control.release_num
               FROM   PO_RELEASES_all POR,
                      PO_RELEASES_ARCHIVE_all PORA
               WHERE  POR.po_release_id = x_po_release_id
               AND    POR.po_release_id = PORA.po_release_id
               AND    PORA.latest_external_flag (+) = 'Y'
               AND    (
                   (PORA.po_release_id IS NULL)
                OR (POR.release_num <> PORA.release_num)
                OR (POR.release_num IS NULL
			AND  PORA.release_num IS NOT NULL)
                OR (POR.release_num IS NOT NULL
			AND PORA.release_num IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_release_control.release_num :='N';
   END;


   BEGIN
               SELECT DISTINCT 'Y'
               INTO   x_release_control.release_date
               FROM   PO_RELEASES_all POR,
                      PO_RELEASES_ARCHIVE_all PORA
               WHERE  POR.po_release_id = x_po_release_id
               AND    POR.po_release_id = PORA.po_release_id
               AND    PORA.latest_external_flag (+) = 'Y'
               AND    (
                   (PORA.po_release_id IS NULL)
                OR (POR.release_date <> PORA.release_date)
                OR (POR.release_date IS NULL
			AND  PORA.release_date IS NOT NULL)
                OR (POR.release_date IS NOT NULL
			AND PORA.release_date IS NULL)
		);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_release_control.release_date :='N';
   END;


   x_release_control.release_total_change:=release_total_change(x_po_release_id);


	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish check_release_change ***');
	END IF;
EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_chord_wf5.chord_release', 'others');
  RAISE;

END;

FUNCTION release_total_change(x_po_release_id IN NUMBER) return NUMBER
IS
	x_po_header_id			NUMBER;
	x_release_total			NUMBER;
	x_release_total_archive		NUMBER;
	x_base_currency  		VARCHAR2(16);
	x_po_currency    		VARCHAR2(16);
	x_min_unit       		NUMBER;
	x_base_min_unit  		NUMBER;
	x_precision      		INTEGER;
	x_base_precision 		INTEGER;
	x_total_change			NUMBER;
BEGIN

  SELECT po_header_id
  into 	 x_po_header_id
  FROM 	 po_releases_all  PR
  WHERE  PR.po_release_id = x_po_release_id;

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


    Begin
            SELECT nvl(round( round(sum((nvl(POD.quantity_ordered, 0) -
                                         nvl(POD.quantity_cancelled, 0)) *
                   nvl(POLL.price_override, 0) * nvl(POD.rate,1) /
                   nvl(X_min_unit,1))) * nvl(X_min_unit,1)  /
		   nvl(X_base_min_unit,1))
                   * nvl(X_base_min_unit,1) , 0)
            INTO   x_release_total
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL POLL
	    WHERE  POLL.po_release_id = x_po_release_id
            AND    POLL.shipment_type in ('SCHEDULED','BLANKET')
            AND    POLL.line_location_id = POD.line_location_id;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_release_total := 0;

    End;
    /* Bug: 1851833
    ** Desc: Modified the where claues of SQL below to
    **       avoid Full Table Scan and use po_header_id index
    */

    Begin
            SELECT nvl(round( round(sum((nvl(PODA.quantity_ordered, 0) -
                                         nvl(PODA.quantity_cancelled, 0)) *
                   nvl(POLLA.price_override, 0) * nvl(PODA.rate,1) /
                   nvl(X_min_unit,1))) * nvl(X_min_unit,1)  /
		   nvl(X_base_min_unit,1))
                   * nvl(X_base_min_unit,1) , 0)
            INTO   x_release_total_archive
	    FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA,
     		   PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
            WHERE  PODA.po_header_id = (SELECT po_header_id
                                        FROM po_releases
                                        WHERE po_release_id = x_po_release_id)
            AND    POLLA.po_header_id = PODA.po_header_id
            AND    POLLA.po_release_id = x_po_release_id
            AND    POLLA.latest_external_flag (+) = 'Y'
            AND    PODA.latest_external_flag (+) = 'Y'
            AND    POLLA.shipment_type in ('SCHEDULED','BLANKET')
            AND    POLLA.line_location_id = PODA.line_location_id;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_release_total_archive :=0;

    End;

  ELSE 	/* base currency = po_currrency */

   Begin
            SELECT sum(
		   (nvl(POD.quantity_ordered, 0) -
                    nvl(POD.quantity_cancelled, 0)) *
                   nvl(POLL.price_override, 0))
            INTO   x_release_total
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL POLL
            WHERE  POLL.po_release_id = x_po_release_id
            AND    POLL.shipment_type in ('SCHEDULED','BLANKET')
            AND    POLL.line_location_id = POD.line_location_id;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_release_total :=0;

    End;

    Begin
            SELECT sum(
		   (nvl(PODA.quantity_ordered, 0) -
                    nvl(PODA.quantity_cancelled, 0)) *
                   nvl(POLLA.price_override, 0))
            INTO   x_release_total_archive
	    FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL POLLA,
     		   PO_DISTRIBUTIONS_ARCHIVE_ALL PODA
            WHERE  PODA.po_header_id = (SELECT po_header_id
                                        FROM po_releases
                                        WHERE po_release_id = x_po_release_id)
            AND    POLLA.po_header_id = PODA.po_header_id
            AND    POLLA.po_release_id = x_po_release_id
            AND    POLLA.latest_external_flag (+) = 'Y'
            AND    PODA.latest_external_flag (+) = 'Y'
            AND    POLLA.shipment_type in ('SCHEDULED','BLANKET')
            AND    POLLA.line_location_id = PODA.line_location_id;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_release_total_archive :=0;

   End;

  END IF;

  x_total_change := PO_CHORD_WF0.percentage_change(x_release_total_archive,
						    x_release_total);

  return(round(x_total_change,2));

EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_total_change', 'others');

END;




PROCEDURE set_wf_release_control(itemtype		IN VARCHAR2,
				itemkey			IN VARCHAR2,
				x_release_control 	IN t_release_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, '*** In procedure set_wf_release_control ***');
	END IF;

	 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_R_AGENT',
			   x_release_control.agent_id);

	 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_R_ACCEPTANCE_REQUIRED',
			   x_release_control.acceptance_required_flag);

	 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_R_ACCEPTANCE_DUE_DATE',
			   x_release_control.acceptance_due_date);

	 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_R_RELEASE_NUM',
			   x_release_control.release_num);

	 wf_engine.SetItemAttrText(itemtype,
			   itemkey,
			   'CO_R_RELEASE_DATE',
			   x_release_control.release_date);

 	 wf_engine.SetItemAttrNumber(itemtype,
			   itemkey,
			   'CO_R_TOTAL_CHANGE',
			   x_release_control.release_total_change);

	debug_release_control(itemtype, itemkey, x_release_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finish set_wf_release_control ***');
	END IF;


EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_chord_wf5.set_wf_release_control', 'others');
  RAISE;
END;

PROCEDURE get_wf_release_control(itemtype	 IN VARCHAR2,
				itemkey 	 IN VARCHAR2,
			 	x_release_control IN OUT NOCOPY t_release_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure get_wf_release_control ***');
	END IF;

	x_release_control.agent_id :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_R_AGENT');

	x_release_control.acceptance_required_flag :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_R_ACCEPTANCE_REQUIRED');

	x_release_control.acceptance_due_date :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_R_ACCEPTANCE_DUE_DATE');

	x_release_control.release_num :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_R_RELEASE_NUM');

	x_release_control.release_date :=
		wf_engine.GetItemAttrText(itemtype,
		itemkey,
		'CO_R_RELEASE_DATE');

	x_release_control.release_total_change :=
	 	wf_engine.GetItemAttrNumber(itemtype,
		itemkey,
		'CO_R_TOTAL_CHANGE');



	debug_release_control(itemtype, itemkey, x_release_control);

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** FINISH: get_wf_release_control ***');
	END IF;
EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_chord_wf5.get_wf_release_control', 'others');
  RAISE;
END;


PROCEDURE debug_release_control(
		itemtype IN VARCHAR2,
		itemkey  IN VARCHAR2,
		x_release_control IN t_release_control_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure: debug_release_control ***');
	END IF;

 IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'agent_id       		: ' ||x_release_control.agent_id);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'acceptance_required_flag 	: ' ||x_release_control.acceptance_required_flag);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'acceptance_due_date      	: ' ||x_release_control.acceptance_due_date);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'release_num       		: ' ||x_release_control.release_num);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
   	'release_date      		: ' ||x_release_control.release_date);
 END IF;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finished: debug_release_control ***');
	END IF;
EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_chord_wf5.get_wf_release_control', 'others');
  RAISE;
END;

PROCEDURE get_wf_release_parameters(itemtype	 IN VARCHAR2,
				itemkey 	 IN VARCHAR2,
			 	x_release_parameters IN OUT NOCOPY t_release_parameters_type)
IS
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In procedure get_wf_release_parameters ***');
	END IF;

	x_release_parameters.po_release_id :=
		wf_engine.GetItemAttrNumber(itemtype,
					    itemkey,
				    	    'DOCUMENT_ID');

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'po_release_id = '|| to_char(x_release_parameters.po_release_id));
	END IF;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** FINISH: get_wf_release_parameters ***');
	END IF;

EXCEPTION

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'po_chord_wf5.chord_release', 'others');
  RAISE;
END;

END PO_CHORD_WF5;

/
