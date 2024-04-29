--------------------------------------------------------
--  DDL for Package PO_DIFF_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DIFF_SUMMARY_PKG" AUTHID CURRENT_USER AS
  -- $Header: PO_DIFF_SUMMARY_PKG.pls 120.3.12010000.3 2011/12/06 09:55:20 inagdeo ship $


--==========================================================================
-- Workflow related procedures
--==========================================================================
FUNCTION accept_lines_within_tolerance
( p_draft_id IN NUMBER
) RETURN VARCHAR2;

PROCEDURE start_workflow
( p_po_header_id IN NUMBER
);

PROCEDURE selector
( item_type   IN VARCHAR2,
  item_key    IN VARCHAR2,
  activity_id IN NUMBER,
  command     IN VARCHAR2,
  resultout   IN OUT NOCOPY VARCHAR2
);

PROCEDURE start_buyer_acceptance_process
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);

PROCEDURE mark_autoaccept_lines
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);

PROCEDURE buyer_acceptance_required
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);

PROCEDURE transfer_if_all_autoaccepted
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);

/* TODO: Don't need this
  PROCEDURE send_reject_all_notification(p_po_header_id IN NUMBER,
                                         p_user IN VARCHAR2);
*/

PROCEDURE get_buyers_manager
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);

PROCEDURE buyer_accept_changes
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);

PROCEDURE buyer_reject_changes
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);

PROCEDURE any_lines_get_rejected
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);

PROCEDURE transfer_draft_to_txn
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);

PROCEDURE launch_po_approval_wf
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);

--==========================================================================
-- Regular procedures
--==========================================================================

FUNCTION get_new_itemkey
( p_draft_id IN NUMBER
) RETURN VARCHAR2;

FUNCTION find_itemkey
( p_draft_id IN NUMBER
) RETURN VARCHAR2;

PROCEDURE record_disposition
( p_draft_id IN NUMBER,
  p_reject_line_id_list IN PO_TBL_NUMBER,
  x_invalid_line_id_list OUT NOCOPY PO_TBL_NUMBER, -- bug5187544
  x_invalid_line_num_list OUT NOCOPY PO_TBL_NUMBER, -- bug5187544
  x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE complete_resp_to_changes
( p_draft_id IN NUMBER,
  p_action   IN VARCHAR2,
  p_initiate_approval IN VARCHAR2,  --Bug 13356264
  p_note_to_approver IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
);

-- Bug 12964696
PROCEDURE post_buyer_acceptance
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);

-- Bug 13356264
PROCEDURE should_approval_be_launched
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
);



END PO_DIFF_SUMMARY_PKG;

/
