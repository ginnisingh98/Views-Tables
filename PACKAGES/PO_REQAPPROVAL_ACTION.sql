--------------------------------------------------------
--  DDL for Package PO_REQAPPROVAL_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQAPPROVAL_ACTION" AUTHID CURRENT_USER AS
/* $Header: POXWPA4S.pls 120.0.12010000.2 2013/01/07 10:28:39 venuthot ship $ */


 /*=======================================================================+
 | FILENAME
 |  POXWPA4S.sql
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  PO_REQAPPROVAL_ACTION
 |
 | NOTES
 | CREATE      Ben Chihaoui 6/19/97
 | MODIFIED
 *=====================================================================*/


-- State_Check_approve
--  Is the state of the document compatible with the reject action.
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--

doc_mgr_err_num number; --global variable used to set doc mgr error.
/*1942091*/
sysadmin_err_msg varchar2(2000); --global variable used to set sysadmin mesg.

--Added as part of bug 16021525 fix
application_id number;
responsibility_id number;
user_id number;

procedure State_Check_approve(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);

-- State_Check_reject
--  Is the state of the document compatible with the reject action.
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure State_Check_reject(  itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

-- Doc_complete_check
--  Is the doc complete (all quantities match, at least one line and one distribution ...)
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Doc_complete_check(  itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

--
-- Approve_doc
-- Approve the document
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Approve_doc(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

-- Approve_and_forward_doc
--   Approve and forward the doc (i.e. set it status to PRE-APPROVED)
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Approve_and_forward_doc(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

--
-- Forward_doc_inprocess
-- If document status is INCOMPLETE, then call cover routine to set the
-- status to INPROCESS and forward to the approver.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Forward_doc_inprocess(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- Forward_doc_preapproved
--   If document status is PRE-APPROVED then call cover routine to
--   forward the document to the next approver (doc status stays PRE-APPROVED).
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--
--
procedure Forward_doc_preapproved(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--

-- Reject_doc
--   Get the manager of the current employee in the HR hierarchy
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--
--
procedure Reject_doc(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--

-- Verify_authority
--   Verify the approval authority against the PO setup control rules.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y - The approver has the authority to approve.
--     N - The approver does not have the authority to approve.
--
procedure Verify_authority(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--

-- Open_Doc_State
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y -
--     N -
--
procedure Open_Doc_State(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--
-- Reserve_doc
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y -
--     N -
--
procedure Reserve_doc(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

--

/* Bug# 2234341: kagarwal */

-- Reserve_doc_Override
--
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y -
--     N -
--
procedure Reserve_doc_Override( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

--

end PO_REQAPPROVAL_ACTION;

/
