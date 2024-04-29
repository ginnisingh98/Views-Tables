--------------------------------------------------------
--  DDL for Package PO_POAPPROVAL_INIT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POAPPROVAL_INIT1" AUTHID CURRENT_USER AS
/* $Header: POXWPA2S.pls 120.0.12010000.2 2010/09/27 11:44:02 inagdeo ship $ */


 /*=======================================================================+
 | FILENAME
 |   POXWPA2S.pls
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  PO_POAPPROVAL_INIT1
 |
 | NOTES
 | MODIFIED    Ben Chihaoui (06/10/97)
 *=====================================================================*/


-- Record variable POHdr_rec
--   Public record variable used to hold the PO_HEADER columns

   TYPE POHdrRecord IS RECORD(
                               PO_HEADER_ID NUMBER,
		       	       COMMENTS  VARCHAR2(240),
                               AUTHORIZATION_STATUS  VARCHAR2(25),
                               TYPE_LOOKUP_CODE      VARCHAR2(25),
                               PREPARER_ID           NUMBER,
                               SEGMENT1              VARCHAR2(20),
                               CLOSED_CODE           VARCHAR2(25),
                               CURRENCY_CODE         VARCHAR2(15));

   POHdr_rec POHdrRecord;

-- Record variable POLine_rec
--   Public record variable used to hold the PO_LINES columns.

   TYPE POLineRecord IS RECORD(
                               LINE_NUM               NUMBER,
                               ITEM_DESCRIPTION       VARCHAR2(240),
                               UNIT_MEAS_LOOKUP_CODE  VARCHAR2(25),
                               UNIT_PRICE             NUMBER,
                               QUANTITY               NUMBER);

   POLine_rec POLineRecord;

-- Record variable RelHdr_rec
--   Public record variable used to hold the PO_RELEASES columns

   TYPE RelHdrRecord IS RECORD(
                               PO_RELEASE_ID         NUMBER,
                               PO_HEADER_ID          NUMBER,
                               AUTHORIZATION_STATUS  VARCHAR2(25),
                               RELEASE_TYPE          VARCHAR2(25),
                               PREPARER_ID           NUMBER,
                               RELEASE_NUM           NUMBER,
                               CLOSED_CODE           VARCHAR2(25),
                               PO_NUMBER             VARCHAR2(20),
                               CURRENCY_CODE         VARCHAR2(15),
                               COMMENTS  VARCHAR2(240));
                              --Bug 10140786 Added comments to set PO_DESCRIPTION in release workflow.
   RelHdr_rec RelHdrRecord;

-- Record variable POLine_loc_rec
--   Public record variable used to hold the PO_LINES and PO_LINE_LOCATIONS columns
--   for and Releases.

   TYPE RelLineLocRecord IS RECORD(
                               PO_LINE_ID             NUMBER,
                               ITEM_DESCRIPTION       VARCHAR2(240),
                               UNIT_MEAS_LOOKUP_CODE  VARCHAR2(25),
                               UNIT_PRICE             NUMBER,
                               SHIPMENT_NUM           NUMBER,
                               QUANTITY               NUMBER,
                               SHIP_TO_LOCATION       VARCHAR2(80),

/** <UTF8 FPI> **/
/** tpoon 9/27/2002 Expanded SHIP_TO_ORG from 60 to 240 **/
--<UTF-8 FPI START>
--                               SHIP_TO_ORG            VARCHAR2(240),
                                 SHIP_TO_ORG          HR_ALL_ORGANIZATION_UNITS.NAME%TYPE,
--<UTF-8 FPI END>

                               NEED_BY_DATE           DATE,
                               PROMISED_DATE          DATE,
                               SHIPMENT_TYPE          VARCHAR2(25));

   RelLineLoc_rec RelLineLocRecord;

-- Cursor GetPOHdr_csr
--   Public cursor used to get the PO_HEADER columns.

   CURSOR GetPOHdr_csr(p_po_header_id NUMBER) RETURN POHdrRecord;

-- Cursor GetRelHdr_csr
--   Public cursor used to get the PO_RELEASES columns.

   CURSOR GetRelHdr_csr(p_rel_header_id NUMBER) RETURN RelHdrRecord;

--
-- Get_PO_Attributes
--   Get the PO attributes. We get the header info and up to 5
--   PO lines.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Get_PO_Attributes(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);

-- Is_this_new_doc
--   Is this a new document or a change order.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--

procedure Is_this_new_doc(      itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

--

function Reserve_Unreserve_Check (   action          in  VARCHAR2,
				     doc_header_id   in  NUMBER,
				     doc_type_code   in  VARCHAR2,
				     doc_status      in  VARCHAR2,
				     doc_cancel_flag in  VARCHAR2)
return BOOLEAN;

-- Is_Acceptance_Required
--   Is Acceptance required on this Document
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--

procedure Is_Acceptance_Required(      itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

-- <SVC_NOTIFICATIONS FPJ START>

-------------------------------------------------------------------------------
--Start of Comments
--Name: Get_Formatted_Address
--Function:
--  Given a location ID, concatenates fields from hr_locations into an address.
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Get_Formatted_Address(p_location_id in NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Get_Formatted_Full_Name
--Function:
--  Given a first and last name, returns a concatenated full name.
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Get_Formatted_Full_Name(p_first_name in VARCHAR2,
                                 p_last_name in VARCHAR2)
RETURN VARCHAR2;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_temp_labor_requester
--Function:
--  Returns the employee_id of the requester for the given Temp Labor PO line,
--  based on a series of rules.
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_temp_labor_requester (
  p_po_line_id         IN PO_LINES_ALL.po_line_id%TYPE,
  x_requester_id       OUT NOCOPY PO_REQUISITION_LINES.to_person_id%TYPE
);

-------------------------------------------------------------------------------
--Start of Comments
--Name: launch_notify_tl_requesters
--Function:
--  For each new Temp Labor line (i.e. line that has not been approved before)
--  on a standard PO, starts the Notify Temp Labor Requester process to send
--  a PO Approval notification to the requester.
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE launch_notify_tl_requesters (
  itemtype  IN VARCHAR2,
  itemkey   IN VARCHAR2,
  actid     IN NUMBER,
  funcmode  IN VARCHAR2,
  resultout OUT NOCOPY VARCHAR2
);

-------------------------------------------------------------------------------
--Start of Comments
--Name: start_po_line_wf_process
--Function:
--  Starts a child workflow process for the given PO line.
--  See the package body for details.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE start_po_line_wf_process (
  p_item_type           IN VARCHAR2,
  p_item_key            IN VARCHAR2,
  p_process             IN VARCHAR2,
  p_parent_item_type    IN VARCHAR2,
  p_parent_item_key     IN VARCHAR2,
  p_po_line_id          IN NUMBER,
  p_requester_id        IN NUMBER,
  p_contractor_or_job   IN VARCHAR2,
  p_approver_user_name  IN VARCHAR2
);
-- <SVC_NOTIFICATIONS FPJ END>

--< Bug 3554754 Start >
PROCEDURE get_approved_date
    ( p_doc_type      IN  VARCHAR2
    , p_doc_id        IN  VARCHAR2
    , x_return_status OUT NOCOPY VARCHAR2
    , x_approved_date OUT NOCOPY DATE
    );
--< Bug 3554754 End >

--
end PO_POAPPROVAL_INIT1;

/
