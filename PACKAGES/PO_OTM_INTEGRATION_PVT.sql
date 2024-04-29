--------------------------------------------------------
--  DDL for Package PO_OTM_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_OTM_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVOTMS.pls 120.0.12010000.2 2010/03/05 21:37:01 yawang ship $ */

-------------------------------------------------------------------------------
--Start of Comments
--Name:
--  is_otm_installed
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns true if Oracle OTM is installed.
--Parameters:
-- None
--Retrurns
-- TRUE if OTM is installed, FALSE if it is not.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_otm_installed RETURN BOOLEAN;

-------------------------------------------------------------------------------
--Start of Comments
--Name:
--  is_inbound_logistics_enabled
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns true if either Oracle OTM or FTE integration is enabled for PO.
--Parameters:
-- None
--Retrurns
-- TRUE if OTM is installed, FALSE if it is not.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_inbound_logistics_enabled RETURN BOOLEAN;


-------------------------------------------------------------------------------
--Start of Comments
--Name:
--  handle_doc_update
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Called when OTM is installed and a document control action has been
--  performed. If the action is one tracked by Oracle OTM, raises
--  oracle.apps.po.event.document_action_event, which will trigger
--  the OTM integration BPEL process.
--Parameters:
--IN:
--p_doc_type
--  The PO Document Type (PO or RELEASE)
--p_doc_id
--  The document's ID (po_header_id for POs, po_release_id for Releases).
--p_action
--  The action performend on the document, as passed from Document Control or
--  Document Manager.
--p_line_id
--  In the case of an action that was performed just on a PO line, such as close
--  or cancel, the ID of the line on which the action was performed.
--p_line_loc_id
--  In the case of an action that was performed on just a PO line location,
--  the ID of the line location on which the action was performed.
--OUT:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE handle_doc_update (
  p_doc_type         IN            VARCHAR2
, p_doc_id           IN            NUMBER
, p_action           IN            VARCHAR2
, p_line_id          IN            NUMBER
, p_line_loc_id      IN            NUMBER
);

-------------------------------------------------------------------------------
--Start of Comments
--Name:
--  get_otm_document
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Called by the OTM integration BPEL process to extract information about
--  a PO document. Information returned depends upon the action performed.
--Parameters:
--IN:
--p_doc_type
--  The PO Document Type (PO or RELEASE)
--p_doc_id
--  The document's ID (po_header_id for POs, po_release_id for Releases).
--p_doc_revision
--  The revision of the document on which the action was performed.
--p_blanket_revision
--  When the document is a Release, the revision number of the BPA against
--  which the release was created.
--p_action
--  The action performend on the document, as passed from Document Control or
--  Document Manager.
--p_line_id
--  In the case of an action that was performed just on a PO line, such as close
--  or cancel, the ID of the line on which the action was performed.
--p_line_loc_id
--  In the case of an action that was performed on just a PO line location,
--  the ID of the line location on which the action was performed.
--OUT:
--x_otm_doc
--  PO_OTM_ORDER_TYPE containing the appropriate document information. In the
--  case of a PO approval, should contain full document info. In the case of
--  hold, cancel, or close, will only contain ID info.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_otm_document (
  p_doc_type         IN            VARCHAR2
, p_doc_id           IN            NUMBER
, p_doc_revision     IN            NUMBER
, p_blanket_revision IN            NUMBER DEFAULT NULL
, p_action           IN            VARCHAR2
, p_line_id          IN            NUMBER DEFAULT NULL
, p_line_loc_id      IN            NUMBER DEFAULT NULL
, x_otm_doc          OUT NOCOPY    PO_OTM_ORDER_TYPE
);

-- OTM Recovery START
PROCEDURE recover_failed_docs
( errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2
);

PROCEDURE update_order_otm_status
( p_doc_id IN NUMBER,
  p_doc_type IN VARCHAR2,
  p_order_otm_status IN VARCHAR2,
  p_otm_recovery_flag IN VARCHAR2
);
-- OTM Recovery END

END;

/
