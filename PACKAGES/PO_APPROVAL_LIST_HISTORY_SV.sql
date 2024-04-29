--------------------------------------------------------
--  DDL for Package PO_APPROVAL_LIST_HISTORY_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_APPROVAL_LIST_HISTORY_SV" AUTHID CURRENT_USER AS
/* $Header: POXWAHIS.pls 115.2 2002/11/26 21:59:07 kagarwal ship $*/

procedure Forward_Action_History(itemtype           in varchar2,
                                itemkey             in varchar2,
                                x_approval_path_id  in number,
				x_req_header_id     in number,
				x_forward_to_id     in number default null);

procedure Update_Action_History(itemtype        in varchar2,
                                itemkey         in varchar2,
				x_action	in varchar2,
				x_req_header_id in number,
				x_last_approver in boolean,
				x_note          in varchar2);

/* Bug# 2684757: kagarwal
** Desc: Added new procedure to insert null action in
** po_action_history for the Requisition if it does not exists.
*/
procedure Reserve_Action_History(x_approval_path_id in number,
                                 x_req_header_id    in number,
                                 x_approver_id      in number);

END PO_APPROVAL_LIST_HISTORY_SV;

 

/
