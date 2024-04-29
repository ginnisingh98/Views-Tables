--------------------------------------------------------
--  DDL for Package PO_WF_REQ_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_WF_REQ_NOTIFICATION" AUTHID CURRENT_USER AS
/* $Header: POXWPA6S.pls 115.14 2004/02/23 12:24:11 manram ship $ */

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

PROCEDURE get_req_lines_details(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2);

/* Bug #1581410 :kagarwal
** Desc: This procedure is added for the new UI and is called only
** by get_po_req_approve_msg and get_po_req_reject_msg messages for
** the html body. It also creates 'View Requisition Details' and
** 'Edit Requisition' links in the message body.
*/
PROCEDURE get_req_lines_details_link(document_id        in      varchar2,
                                 display_type   in      varchar2,
                                 document       in out NOCOPY  varchar2,
                                 document_type  in out NOCOPY  varchar2);

/* This function is the PL/SQL document function to retrieve the
** action history of the requisition.
*/
PROCEDURE get_action_history(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2);

/* Bug #1581410 :kagarwal
** Desc: This procedure has been added for the new UI. This is
** called by all the messages using the new UI for the html body.
*/

PROCEDURE get_action_history_html(document_id   in      varchar2,
                                 display_type   in      varchar2,
                                 document       in out NOCOPY  varchar2,
                                 document_type  in out NOCOPY  varchar2);

/* This function is the post-notification logic of requisition approval
** notification.
*/
PROCEDURE post_approval_notif(itemtype   in varchar2,
                              itemkey    in varchar2,
                              actid      in number,
                              funcmode   in varchar2,
                              resultout  out NOCOPY varchar2);

/* Bug# 2469882
** Desc: Added new procedure to set notification subject token.
*/
procedure Get_req_approver_msg_attribute(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure Get_req_preparer_msg_attribute(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

/* Procedure to check whether Forward Action is allowed. */

procedure Is_Forward_Action_Allowed(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    );

/* Bug# 2616255: kagarwal
** Desc: Added new procedure to set notification subject token
** for the notifications sent to forward from person
*/
procedure Get_req_fwdfrom_msg_attribute(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

/* Bug# 3419861: manram
** Desc: Added new function which  returns the formatted currency
** for a given currency code and amount.
*/

Function FORMAT_CURRENCY_NO_PRECESION (p_currency_code  IN  varchar2,
				p_amount         IN  number )   return Varchar2;

END PO_WF_REQ_NOTIFICATION;

 

/
