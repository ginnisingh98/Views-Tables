--------------------------------------------------------
--  DDL for Package PO_APPROVE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_APPROVE_SV" AUTHID CURRENT_USER AS
/* $Header: POXAPAPS.pls 115.4 2003/08/07 05:57:22 zxzhang ship $*/

/*===========================================================================
  PROCEDURE NAME: 	get_approval_path

  DESCRIPTION:		This procedure gets the default approval path.

  PARAMETERS:		x_default_approval_path_id   IN 	NUMBER,
			x_forward_from_id	     IN		NUMBER,
			x_object_id	             IN		NUMBER,
			x_document_type_code	     IN		VARCHAR2,
			x_document_subtype	     IN 	VARCHAR2,
			x_approval_path		     OUT	NOCOPY VARCHAR2,
			x_approval_path_id           OUT	NOCOPY NUMBER

  DESIGN REFERENCES:	POXDOAPP.dd

  ALGORITHM:		Gets default approval path as follows:
			- If this is not the first action on this document,
			  use the same approval path as the previous action
			  on this document.
			- If this is the first action on the document, use
       			  the default_approval_path_id only if the forward_from
       			  person belongs to the same path
			- If this is the first action on the document and the
       			  foward_from person does not belong to
			  default_approval_path_id, then do not default
			  in approval path.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/1	created
===========================================================================*/

  PROCEDURE test_get_approval_path (	x_default_approval_path_id   IN NUMBER,
					x_forward_from_id	     IN	NUMBER,
					x_object_id	             IN	NUMBER,
					x_document_type_code	     IN	VARCHAR2,
					x_document_subtype	     IN VARCHAR2);

  PROCEDURE get_approval_path (
	x_default_approval_path_id   IN 	NUMBER,
	x_forward_from_id	     IN		NUMBER,
	x_object_id	             IN		NUMBER,
	x_document_type_code	     IN		VARCHAR2,
	x_document_subtype	     IN 	VARCHAR2,
	x_approval_path		     OUT	NOCOPY VARCHAR2,
	x_approval_path_id           OUT	NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME:	get_document_types

  DESCRIPTION:		This procedure gets values required at startup from
			the table po_document_types.

  PARAMETERS:		x_document_type_code		 IN	VARCHAR2,
			x_document_subtype		 IN	VARCHAR2,
			x_can_change_forward_from_flag	 IN OUT	VARCHAR2,
			x_can_change_forward_to_flag	 IN OUT	VARCHAR2,
			x_can_change_approval_path	 IN OUT	VARCHAR2,
			x_default_approval_path_id	 IN OUT	NUMBER,
			x_can_preparer_approve_flag	 IN OUT	VARCHAR2,
			x_can_approver_modify_flag       IN OUT VARCHAR2

  DESIGN REFERENCES:	POXDOAPP.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/1	created
===========================================================================*/

  PROCEDURE test_get_document_types (x_document_type_code  IN   VARCHAR2,
                                    x_document_subtype    IN    VARCHAR2);

  PROCEDURE get_document_types (
	x_document_type_code		 IN	VARCHAR2,
	x_document_subtype		 IN	VARCHAR2,
	x_can_change_forward_from_flag	 IN OUT	NOCOPY VARCHAR2,
	x_can_change_forward_to_flag	 IN OUT	NOCOPY VARCHAR2,
	x_can_change_approval_path	 IN OUT	NOCOPY VARCHAR2,
	x_default_approval_path_id	 IN OUT	NOCOPY NUMBER,
	x_can_preparer_approve_flag	 IN OUT	NOCOPY VARCHAR2,
	x_can_approver_modify_flag       IN OUT NOCOPY VARCHAR2);

/* RETROACTIVE FPI START*/
/*===========================================================================
  PROCEDURE NAME:       get_document_types

  DESCRIPTION:          This procedure gets values required at startup from
                        the table po_document_types. This procedure is
                        overloaded with all the columns from po_document_types
                        as output parameters.

  PARAMETERS:           p_document_type_code - Document Type (PO/RELEASE ..)
                        p_document_subtype  - Document Subtype - (STANDARD ..)
                        x_can_change_forward_from_flag - Can user change forward
							From flag
                        x_can_change_forward_to_flag - Can user change forward
							To Flag
                        x_can_change_approval_path - Can user change Approval
							Path
                        x_default_approval_path_id - Default Approval Path
                        x_can_preparer_approve_flag - Can owner approve.
                        x_can_approver_modify_flag  - Can approver modify
							document
                        x_forwarding_mode_code  -  Document Forward Method
                        x_wf_approval_itemtype  - Item Type for the document
			x_wf_approval_process - Approval Process defined for
						the document.


  Description: Select the workflow relavent parameters from po_document_types
		for a given document_type and document_subtype.
  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       pparthas    21-oct-2002    created
===========================================================================*/

  PROCEDURE get_document_types (
        p_document_type_code             IN     VARCHAR2,
        p_document_subtype               IN     VARCHAR2,
        x_can_change_forward_from_flag      OUT NOCOPY VARCHAR2,
        x_can_change_forward_to_flag        OUT NOCOPY VARCHAR2,
        x_can_change_approval_path          OUT NOCOPY VARCHAR2,
        x_default_approval_path_id          OUT NOCOPY NUMBER,
        x_can_preparer_approve_flag         OUT NOCOPY VARCHAR2,
        x_can_approver_modify_flag          OUT NOCOPY VARCHAR2,
	x_forwarding_mode_code              OUT NOCOPY VARCHAR2,
	x_wf_approval_itemtype              OUT NOCOPY VARCHAR2,
	x_wf_approval_process               OUT NOCOPY VARCHAR2,
        x_type_name                         OUT NOCOPY VARCHAR2);
/* RETROACTIVE FPI END*/

-- <FPJ Redesign Approval Window START>
PROCEDURE get_change_summary(p_document_type_code	IN	   VARCHAR2,
                             p_document_header_id	IN	   NUMBER,
                             x_change_summary		OUT NOCOPY VARCHAR2);
-- <FPJ Redesign Approval Window END>

END PO_APPROVE_SV;

 

/
