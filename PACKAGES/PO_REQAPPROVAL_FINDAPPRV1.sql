--------------------------------------------------------
--  DDL for Package PO_REQAPPROVAL_FINDAPPRV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQAPPROVAL_FINDAPPRV1" AUTHID CURRENT_USER AS
/* $Header: POXWPA3S.pls 120.0.12010000.2 2012/06/20 09:26:42 yuandli ship $ */

 /*=======================================================================+
 | FILENAME
 |  POXWPAS3.sql
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  PO_REQAPPROVAL_FINDAPPRV1
 |
 | NOTES
 | MODIFIED    Ben Chihaoui (06/15/97)
 *=====================================================================*/


/*
-- Record variable ReqHdr_rec
--   Public record variable used to hold the Requisition_header columns

   TYPE ReqHdrRecord IS RECORD(
                               REQUISITION_HEADER_ID NUMBER,

   ReqHdr_rec ReqHdrRecord;

-- Record variable ReqLine_rec
--   Public record variable used to hold the Requisition_line columns.

   TYPE ReqLineRecord IS RECORD(
                               REQUESTOR_FULL_NAME    VARCHAR2(240));

   ReqLine_rec ReqLineRecord;

-- Cursor GetRecHdr_csr
--   Public cursor used to get the Requisition_header columns.

   CURSOR GetRecHdr_csr(p_requisition_header_id NUMBER) RETURN ReqHdrRecord;

-- Cursor GetRecLines_csr
--   Public cursor used to get the Requisition Lines columns.

   CURSOR GetRecLines_csr(p_requisition_header_id NUMBER) RETURN ReqLineRecord;

*/

-- Set_Forward_To_From_App_fwd
--  Reset the Forward-to and forward-from
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - None
--
procedure Set_Forward_To_From_App_fwd(       itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--

-- Set_Forward_To_From_App_fwd
--  Reset the Forward-to and forward-from
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - None
--
procedure Set_Fwd_To_From_App_timeout(       itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--

-- Is_Forward_To_Valid
--  Is Forward-To userame entered in the Forward-To field in response to the
--  the approval notification, a valid username. If not resend the
--  notification back to the user.
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - Y/N
--
procedure Is_Forward_To_Valid(  itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--


-- Is_forward_to_provided
--   Did the submitter or the approver provide a forward to username.
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - Y/N Performed   - Activity was completed without any errors.
--
procedure Is_forward_to_provided(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);


-- Is_Forward_To_User_Name_Valid
--   Is the user_name valid for the next approver?
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - Y/N
procedure Is_Forward_To_User_Name_Valid(itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					resultout	out NOCOPY varchar2	);


--
-- Get_approval_path_id
-- If the submitter of the document did not provide a specific hierarchy, the
-- Get the default Approval Hierarchy from the setup.
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Get_approval_path_id(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

-- Get_Forward_mode
--   Is the forwarding mode DIRECT or HIERARCHY
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Get_Forward_mode(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

--
-- Use_Position_flag
-- Determine if customer is using Positions in approvals.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Use_Position_flag(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- GetMgr_hr_hier
--   Get the manager of the current employee in the HR hierarchy
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y - Found a manager for this employee in the HR Hierarchy
--     N - Did not Find a manager for this employee in the HR Hierarchy
--
procedure GetMgr_hr_hier(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--

-- GetMgr_po_hier
--   Get the manager of the current employee in the HR hierarchy
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y - Found a manager for this employee in the PO Hierarchy
--     N - Did not Find a manager for this employee in the PO Hierarchy
--
procedure GetMgr_po_hier(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--
--
FUNCTION CheckForwardTo( p_username varchar2,  x_user_id IN OUT NOCOPY number) RETURN VARCHAR2;

--<bug 14105414>: moved the declaration from BODY to SPEC.
PROCEDURE CheckOwnerCanApprove (itemtype in VARCHAR2, itemkey in VARCHAR2,
  CanOwnerApprove out NOCOPY VARCHAR2);

end PO_REQAPPROVAL_FINDAPPRV1;

/
