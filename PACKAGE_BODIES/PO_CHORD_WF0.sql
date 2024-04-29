--------------------------------------------------------
--  DDL for Package Body PO_CHORD_WF0
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHORD_WF0" AS
/* $Header: POXWCOXB.pls 120.0 2005/06/01 19:27:09 appldev noship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

PROCEDURE chord_setup(itemtype IN VARCHAR2,
		   itemkey  IN VARCHAR2,
		   actid    IN NUMBER,
		   funcmode IN VARCHAR2,
		   result   OUT NOCOPY VARCHAR2)
IS
	x_po_header_id		NUMBER:=NULL;
	x_po_release_id		NUMBER:=NULL;
	x_auth_status		VARCHAR2(25):=NULL;
	x_doc_type		VARCHAR2(25):=NULL;
	x_doc_subtype		VARCHAR2(25):=NULL;
	e_invalid_doc_type	EXCEPTION;
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, '*** In procedure chord_setup ***');
	END IF;

  	x_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  	x_doc_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, 'Document Type '|| x_doc_type);
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, 'Document Subtype '|| x_doc_subtype);
	END IF;

     	IF x_doc_type = 'REQUISITION' THEN
	  --Change order does not apply to Req
	  raise e_invalid_doc_type;

     	ELSIF x_doc_type IN ('PO', 'PA') THEN

	  x_po_header_id :=
		wf_engine.GetItemAttrNumber(itemtype,
					    itemkey,
				    	    'DOCUMENT_ID');
	  BEGIN

	  	select authorization_status
		into 	x_auth_status
	  	from po_headers_all
	  	where po_header_id=x_po_header_id;

	  END;

     	ELSIF x_doc_type = 'RELEASE' THEN

	  x_po_release_id :=
		wf_engine.GetItemAttrNumber(itemtype,
					    itemkey,
				    	    'DOCUMENT_ID');

	  BEGIN

	  	select authorization_status
		into 	x_auth_status
	  	from po_releases_all
	  	where po_release_id=x_po_release_id;

	  END;


	ELSE
	  raise e_invalid_doc_type;

     	END IF;

        wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'AUTHORIZATION_STATUS',
                                        avalue     => x_auth_status );

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, '*** FINISH: chord_setup ***');
	END IF;

	result := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
	return;


EXCEPTION
 WHEN e_invalid_doc_type THEN
  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, '*** exception chord_doc_type ***');
  END IF;
  wf_core.context('POAPPRV', 'chord_doc_type', 'e_invalid_doc_type');
  RAISE;

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'chord_doc_type', 'others');
  RAISE;

END;

PROCEDURE chord_doc_type(itemtype IN VARCHAR2,
		   itemkey  IN VARCHAR2,
		   actid    IN NUMBER,
		   funcmode IN VARCHAR2,
		   result   OUT NOCOPY VARCHAR2)
IS
	x_doc_type	VARCHAR2(25);
	x_doc_subtype	VARCHAR2(25);
	e_invalid_doc_type	EXCEPTION;
BEGIN
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, '*** In procedure chord_doc_type ***');
	END IF;


  	x_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  	x_doc_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, 'doc_type '|| x_doc_type);
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, 'doc_subtype '|| x_doc_subtype);
	END IF;


     	IF x_doc_type = 'REQUISITION' THEN
	  --Change order does not apply to Req
	  raise e_invalid_doc_type;

     	ELSIF x_doc_type IN ('PO', 'PA') THEN

	  IF x_doc_subtype = 'STANDARD' THEN
		RESULT:='PO_STANDARD';
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, 'CO TYPE: po_standard');
	END IF;

	  ELSIF x_doc_subtype = 'CONTRACT' THEN
		RESULT:='PO_CONTRACT';
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, 'CO TYPE: po_contract');
	END IF;

	  ELSIF x_doc_subtype = 'BLANKET' THEN
		RESULT:='PO_BLANKET';
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, 'CO TYPE: po_blanket');
	END IF;

	  ELSIF x_doc_subtype = 'PLANNED' THEN
		RESULT:='PO_PLANNED';
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, 'CO TYPE: po_planned');
	END IF;

	  END IF;

     	ELSIF x_doc_type = 'RELEASE' THEN
	  IF x_doc_subtype = 'BLANKET' THEN
		RESULT:='BLANKET_RELEASE';
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, 'CO TYPE: blanket_release');
	END IF;
	  ELSE
		RESULT:='SCHEDULED_RELEASE';
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, 'CO TYPE: scheduled_release');
	END IF;
	  END IF;
	ELSE
	  raise e_invalid_doc_type;

     	END IF;

	return;

	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, '*** Finish: chord_doc_type ***');
	END IF;


EXCEPTION
 WHEN e_invalid_doc_type THEN
  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY, '*** exception chord_doc_type ***');
  END IF;
  wf_core.context('POAPPRV', 'chord_doc_type', 'e_invalid_doc_type');
  RAISE;

 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'chord_doc_type', 'others');
  RAISE;

END;

/*
 * This procedure needs to be called with an itemkey
 */
PROCEDURE Start_WF_Process ( ItemType          VARCHAR2,
                             ItemKey                VARCHAR2,
                             WorkflowProcess        VARCHAR2,
                             ActionOriginatedFrom   VARCHAR2,
                             DocumentID             NUMBER,
                             DocumentNumber         VARCHAR2,
                             PreparerID             NUMBER,
                             DocumentTypeCode       VARCHAR2,
                             DocumentSubtype        VARCHAR2,
                             SubmitterAction        VARCHAR2,
                             forwardToID            NUMBER,
                             forwardFromID          NUMBER,
                             DefaultApprovalPathID  NUMBER)
is

BEGIN

--  DBMS_OUTPUT.enable(100000); Commenting out as problems may be caused.

  IF  ( ItemType is NOT NULL )   AND
      ( ItemKey is NOT NULL)     AND
      ( DocumentID is NOT NULL ) THEN

        wf_engine.CreateProcess( ItemType => ItemType,
                                 ItemKey  => ItemKey,
                                 process  => WorkflowProcess );
        --
        -- Initialize workflow item attributes
        --

        wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'INTERFACE_SOURCE_CODE',
                                        avalue     =>  ActionOriginatedFrom);
        --

        wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'DOCUMENT_NUMBER',
                                        avalue     =>  DocumentNumber);
        --
        wf_engine.SetItemAttrNumber (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'DOCUMENT_ID',
                                        avalue     => DocumentID);
        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'DOCUMENT_TYPE',
                                        avalue          =>  DocumentTypeCode);
        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'DOCUMENT_SUBTYPE',
                                        avalue          =>  DocumentSubtype);
        --
        wf_engine.SetItemAttrNumber (   itemtype        => itemType,
                                        itemkey         => itemkey,
                                        aname           => 'PREPARER_ID',
                                        avalue          => PreparerID);
        --
        wf_engine.SetItemAttrNumber (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_TO_ID',
                                        avalue          =>  ForwardToID);
        --
        wf_engine.SetItemAttrNumber (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_FROM_ID',
                                        avalue          =>  ForwardToID);
        --
        wf_engine.SetItemAttrNumber (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'APPROVAL_PATH_ID',
                                        avalue          =>  DefaultApprovalPathID);


        --
        wf_engine.StartProcess(         itemtype        => itemtype,
                                        itemkey         => itemkey );

    END IF;

EXCEPTION
 WHEN OTHERS THEN
  wf_core.context('POAPPRV', 'start_wf_process', 'others');
  RAISE;

END Start_WF_Process;


FUNCTION percentage_change(old_value	IN NUMBER,
			   new_value	IN NUMBER) return NUMBER
IS
	x_percent NUMBER;
BEGIN
	IF (old_value = 0) THEN

	  IF new_value = 0 Then
		x_percent := 0;
	  ELSE
		/* This is actually infinity */
		x_percent := 100;
	  END IF;

	ELSIF old_value IS NULL THEN
		x_percent := nvl(new_value,0) * 100;
	ELSE
		x_percent := (nvl(new_value,0) - old_value)/old_value * 100;
	END IF;

	return(x_percent);

END;


/**************************************************************************
 *  PROCEDURE: 		archive_on_approval_set
 *  DESCRIPTION:	This procedure check for archive revision flag
 *			set in the PO Document Types form.
 *                      It returns 'Y' if it is set to 'APPROVAL';
 *			Otherwise 'N'.
 * 			This check is mainly used by Change Order.
 *			Change Order should only executed if archive on
 *			approval is set.
 *************************************************************************/

PROCEDURE archive_on_approval_set(itemtype IN VARCHAR2,
				      itemkey  IN VARCHAR2,
				      actid    IN NUMBER,
				      FUNCMODE IN VARCHAR2,
				      RESULT   OUT NOCOPY VARCHAR2)
IS
	x_archive_code	VARCHAR2(25):='';
	x_org_id	NUMBER:='';
	x_doc_type 	VARCHAR2(25):='';
	x_doc_subtype	VARCHAR2(25):='';
	x_result	VARCHAR2(1):='N';
BEGIN

 IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** In Procedure: archive_on_approval ***');
 END IF;

 x_org_id:=  wf_engine.GetItemAttrNumber (itemtype	=> itemType,
                                          itemkey       => itemkey,
                                          aname         => 'ORG_ID');

 x_doc_type := wf_engine.GetItemAttrText (itemtype 	=> itemtype,
                                         itemkey  	=> itemkey,
                                         aname    	=> 'DOCUMENT_TYPE');

 x_doc_subtype := wf_engine.GetItemAttrText (itemtype 	=> itemtype,
                                         itemkey  	=> itemkey,
                                         aname    	=> 'DOCUMENT_SUBTYPE');

/* BUG# 1180957: draising
** Forward fix of Bug#  1180198
** Desc : We need to set the org_id  and use stripped tables
** to get the ARCHIVE_EXTERNAL_REVISION_CODE. The previous
** code to get data from the PO_DOCUMENT_TYPES_ALL table
** an org_id would fail for non- multi-org environment.
*/

  IF x_org_id is NOT NULL THEN

     PO_MOAC_UTILS_PVT.set_org_context(x_org_id) ;         -- <R12 MOAC>

  END IF;
  IF x_doc_type IS NOT NULL AND
     x_doc_subtype IS NOT NULL THEN
     Begin

       SELECT ARCHIVE_EXTERNAL_REVISION_CODE
       INTO x_archive_code
       FROM PO_DOCUMENT_TYPES podta
       WHERE podta.DOCUMENT_TYPE_CODE = x_doc_type
       AND podta.DOCUMENT_SUBTYPE = x_doc_subtype;

      Exception
       WHEN NO_DATA_FOUND THEN
          null;
       WHEN OTHERS THEN
          null;
     End;

  END IF;

  IF nvl(x_archive_code, 'UNDEFINED') = 'APPROVE' THEN
	x_result:='Y';
  ELSE
	x_result:='N';
  END IF;

 IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** Finished: archive_on_approval ***');
 END IF;

 result := wf_engine.eng_completed || ':' ||  x_result;
 return;

EXCEPTION

 WHEN OTHERS THEN
  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
   		'*** execption archive_on_approval_set *** '||x_result);
  END IF;
  wf_core.context('POAPPRV', 'po_chord_wf0.archive_on_approval_set', 'result '||x_result);
  RAISE;

END;


END PO_CHORD_WF0;

/
