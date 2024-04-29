--------------------------------------------------------
--  DDL for Package PO_CHORD_WF0
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHORD_WF0" AUTHID CURRENT_USER as
/* $Header: POXWCOXS.pls 115.3 2002/11/26 19:46:53 sbull ship $ */

	PROCEDURE chord_setup(itemtype IN VARCHAR2,
			      itemkey  IN VARCHAR2,
			      actid    IN NUMBER,
			      FUNCMODE IN VARCHAR2,
			      RESULT   OUT NOCOPY VARCHAR2);

	PROCEDURE chord_doc_type(itemtype IN VARCHAR2,
			      itemkey  IN VARCHAR2,
			      actid    IN NUMBER,
			      FUNCMODE IN VARCHAR2,
			      RESULT   OUT NOCOPY VARCHAR2);

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
	                             DefaultApprovalPathID  NUMBER);

	FUNCTION percentage_change(old_value	IN NUMBER,
				   new_value	IN NUMBER) return NUMBER;
--	PRAGMA RESTRICT_REFERENCES(percentage_change, WNDS, WNPS, RNDS);

	PROCEDURE archive_on_approval_set(itemtype IN VARCHAR2,
				      itemkey  IN VARCHAR2,
				      actid    IN NUMBER,
				      FUNCMODE IN VARCHAR2,
				      RESULT   OUT NOCOPY VARCHAR2);

END PO_CHORD_WF0;

 

/
