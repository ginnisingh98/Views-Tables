--------------------------------------------------------
--  DDL for Package PO_WF_REQ_NOTIFICATION_R11
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_WF_REQ_NOTIFICATION_R11" AUTHID CURRENT_USER AS
/* $Header: POXWPA8S.pls 115.2 2002/11/22 22:09:40 sbull noship $ */

/* This function is the PL/SQL document function to retrieve the
** approval notification message header of the requisition.
*/
PROCEDURE get_po_req_approve_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2);

/* This function is the PL/SQL document function to retrieve the
** approved notification message header of the requisition.
*/
PROCEDURE get_po_req_approved_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2);

/* This function is the PL/SQL document function to retrieve the
** no approver notification message header of the requisition.
*/
PROCEDURE get_po_req_no_approver_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2);

/* This function is the PL/SQL document function to retrieve the
** rejected notification message header of the requisition.
*/
PROCEDURE get_po_req_reject_msg(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2);

/* This function is the PL/SQL document function to retrieve the
** line details of the requisition.
*/
PROCEDURE get_req_lines_details(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2);

PROCEDURE get_req_lines_details_link(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2);


/* This function is the PL/SQL document function to retrieve the
** action history of the requisition.
*/
PROCEDURE get_action_history(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2);

/* This function is the post-notification logic of requisition approval
** notification.
*/
PROCEDURE post_approval_notif(itemtype   in varchar2,
                              itemkey    in varchar2,
                              actid      in number,
                              funcmode   in varchar2,
                              resultout  in out NOCOPY varchar2);

--
-- Newline
--   Return newline character in current codeset
--
function Newline
return varchar2;
pragma restrict_references (NEWLINE, WNDS, WNPS, RNPS);

END PO_WF_REQ_NOTIFICATION_R11;

 

/
