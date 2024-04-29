--------------------------------------------------------
--  DDL for Package PO_APPROVAL_LIST_WF1S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_APPROVAL_LIST_WF1S" AUTHID CURRENT_USER AS
/* $Header: POXWAL1S.pls 120.1 2006/09/22 18:33:10 tolick noship $ */

 /*=======================================================================+
 | FILENAME
 |   POXWAL1S.sql
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  PO_APPROVAL_LIST_WF1S
 |   This package contains procedure to support
 |   requisition approval workflow
 |   extension for Web Requisition 4.0
 |
 | NOTES
 |   Created 10/04/98 ecso
 *=====================================================================*/

-- Does_Approval_list_Exist
-- Check if there exists an approval list
-- for a requisition
--
procedure Does_Approval_List_Exist( itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2);

-- Find_Approval_List
-- 1. search for an approval list created by preparer
--    through web requisition
-- 2. if approval list is found,
--     record the approval list id on workflow attribute and
--     mark approval list with workflow itemtype, itemkey
--     by calling update_approval_list_itemkey API
--
procedure Find_Approval_List      ( itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2);

-- Build_Default_Approval_List
--
procedure Build_Default_Approval_list(itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2);

-- Rebuild_Approval_List
-- An approval list will be rebuilt under the following scenario:
-- (1) Approver forwarded the requisition
-- (2) Approver modified the requisition
-- (3) The current approver is not valid
--

procedure Rebuild_List_Forward(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);
--
procedure Rebuild_List_Doc_Changed(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);
--
procedure Rebuild_List_Invalid_Approver(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);
--
-- Get_Next_Approver
-- get the next approver name from the approval list
-- and update workflow attributes
--
procedure Get_Next_Approver(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);

-- Is_Approval_List_Empty
--
procedure Is_Approval_List_Empty(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

-- Update action history
-- The following procedures record the response
-- from workflow notifications in po_action_history table
--
procedure Insert_Action_History(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Update_Action_History_Approve(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Update_Action_History_Timeout(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Update_Action_History_App_Fwd(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Update_Action_History_Forward(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Update_Action_History_Reject(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

-- Update Approval List Response
-- This procedure record the response
-- from workflow notifications in
-- po_approval_list_headers and po_approval_list_lines tables
--
procedure Update_Approval_List_Response(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);


/* Bug# 1712121: kagarwal
** Desc: Created new workflow API: Update_App_List_Resp_Success.
**
** This is same as Update_Approval_List_Response but the return values
** will be SUCCESS-FAILURE.
*/

procedure Update_App_List_Resp_Success(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Create_Attach_Info_Temp(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Is_Document_Manager_Error_1_2(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

/* Bug# 2684757: kagarwal
** Desc: Added new wf api to insert null action before
** Reserving a Requisition, if the null action does not exists.
** Otherwise the Reserve action is not recorded.
*/
procedure Insert_Res_Action_History(itemtype    in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);
/* FPJ AME integration */
procedure get_approval_response(itemtype        in varchar2,
                       itemkey         in varchar2,
                       responderId out NOCOPY number,
                       response out NOCOPY varchar2,
                       responseEndDate out NOCOPY date,
                       forwardToId out NOCOPY number);

END PO_APPROVAL_LIST_WF1S;

 

/
