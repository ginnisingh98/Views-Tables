--------------------------------------------------------
--  DDL for Package PO_APPROVAL_REMINDER_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_APPROVAL_REMINDER_SV" AUTHID CURRENT_USER AS
/* $Header: POXWARMS.pls 115.4 2003/09/26 01:41:16 tpoon ship $*/

/*===========================================================================
  PACKAGE NAME:		PO_APPROVAL_REMINDER_SV

  DESCRIPTION:          PO Approval Workflow server procedures

  CLIENT/SERVER:	Server

  LIBRARY NAME          PO_APPROVAL_WF_SV

  OWNER:                WLAU

  PROCEDURES/FUNCTIONS:

===========================================================================*/


/*===========================================================================
  PROCEDURE NAME:	Select_Unapprove_docs

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/

 PROCEDURE Select_Unapprove_docs;

 PROCEDURE Process_unapprove_reqs;

 PROCEDURE Process_unapprove_pos;

 PROCEDURE Process_unapprove_releases;

 PROCEDURE Process_po_acceptance;

 PROCEDURE Process_rel_acceptance;

 PROCEDURE Process_rfq_quote;


/*===========================================================================
  PROCEDURE NAME:	Start_Approval_Reminder

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/

  PROCEDURE Start_Approval_Reminder (p_doc_header_id		IN NUMBER,
				     p_doc_number 		IN VARCHAR2,
				     p_doc_type                 IN VARCHAR2,
				     p_doc_subtype              IN VARCHAR2,
				     p_release_num	        IN NUMBER,
	  			     p_agent_id		        IN NUMBER,
				     p_WF_ItemKey		IN VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	Set_Doc_Type

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/
  PROCEDURE Set_Doc_Type       (   itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funmode         in varchar2,
                                   result          out NOCOPY varchar2    );

/*===========================================================================
  PROCEDURE NAME:	Start_Approval_WF

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/

  PROCEDURE Start_Doc_Approval  (  itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funmode         in varchar2,
                                   result          out NOCOPY varchar2 );



/*===========================================================================
  PROCEDURE NAME:	SetUpWorkFlow

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/
PROCEDURE SetUpWorkFlow ( p_ActionOriginatedFrom   IN varchar2,
                          p_DocumentID             IN number,
                          p_DocumentNumber         IN varchar2,
                          p_PreparerID             IN number,
                          p_ResponsibilityID       IN number,
                          p_ApplicationID          IN number,
                          p_DocumentTypeCode       IN varchar2,
                          p_DocumentSubtype        IN varchar2,
                          p_RequestorAction        IN varchar2,
                          p_forwardToID            IN number default NULL,
                          p_forwardFromID          IN number,
                          p_DefaultApprovalPathID  IN number,
                          p_DocumentStatus         IN varchar2,
			  p_Note                   IN varchar2 );



/*===========================================================================
  PROCEDURE NAME:       Is_Forward_To_Valid

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/
PROCEDURE Is_Forward_To_Valid(  itemtype        IN varchar2,
                                itemkey         IN varchar2,
                                actid           IN number,
                                funcmode        IN varchar2,
                                resultout       OUT NOCOPY varchar2    );


/*===========================================================================
  PROCEDURE NAME:	Cancel_Notif

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/
PROCEDURE  Cancel_Notif ( p_DocumentTypeCode       IN varchar2,
                          p_DocumentID             IN number,
                          p_ReleaseFlag            IN varchar2 default null);

/*===========================================================================
  PROCEDURE NAME:      stop_process

  DESCRIPTION:          See the package body

  PARAMETERS:

  RETURN:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/
PROCEDURE Stop_Process ( item_type       IN varchar2,
                         item_key        IN varchar2);

FUNCTION is_active     ( x_item_type       IN varchar2,
                         x_item_key        IN varchar2) RETURN BOOLEAN;



PROCEDURE item_exist  ( p_ItemType 	IN  VARCHAR2,
                        p_ItemKey  	IN  VARCHAR2,
			p_Item_exist 	OUT NOCOPY VARCHAR2,
                        p_Item_end_date OUT NOCOPY DATE);

-- <SVC_NOTIFICATIONS FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: process_po_temp_labor_lines
--Function:
--  Starts the Reminder workflow to send notifications for Temp Labor lines
--  that match the reminder criteria (Amount Billed Exceeds Budget,
--  Contractor Assignment Nearing Completion).
--Notes:
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE process_po_temp_labor_lines;

-------------------------------------------------------------------------------
--Start of Comments
--Name: start_po_line_reminder_wf
--Function:
--  Starts the Reminder workflow for the given PO line and line reminder type.
--Notes:
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE start_po_line_reminder_wf (
  p_po_line_id         IN PO_LINES.po_line_id%TYPE,
  p_line_reminder_type IN VARCHAR2,
  p_requester_id       IN NUMBER,
  p_contractor_or_job  IN VARCHAR2,
  p_expiration_date    IN DATE
);

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_po_line_reminder_type
--Function:
--  Returns the value of the PO Line Reminder Type item attribute.
--Notes:
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_po_line_reminder_type (
  itemtype  IN VARCHAR2,
  itemkey   IN VARCHAR2,
  actid     IN NUMBER,
  funcmode  IN VARCHAR2,
  resultout OUT NOCOPY VARCHAR2
);
-- <SVC_NOTIFICATIONS FPJ END>

END PO_APPROVAL_REMINDER_SV;


 

/
