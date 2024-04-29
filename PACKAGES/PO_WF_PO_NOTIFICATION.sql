--------------------------------------------------------
--  DDL for Package PO_WF_PO_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_WF_PO_NOTIFICATION" AUTHID CURRENT_USER AS
/* $Header: POXWPA7S.pls 120.0.12010000.2 2008/08/04 08:36:22 rramasam ship $ */

PROCEDURE get_po_approve_msg (	 document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2);

PROCEDURE get_po_lines_details ( document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY CLOB, -- <BUG 7006113>
                                 document_type	in out	NOCOPY varchar2);

PROCEDURE get_action_history (	 document_id	in	varchar2,
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

/* Bug# 2616433: kagarwal
** Desc: Added new procedure to set notification subject token.
*/
procedure Get_po_user_msg_attribute(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

procedure GetDisplayValue(itemtype in varchar2,
                          itemkey  in varchar2,
                          username in varchar2 default NULL,
                          doctype  in varchar2 default NULL,
                          docsubtype in varchar2 default NULL);

-- This function was written for bug 3607009, but
-- modified for bug 3668188
FUNCTION is_open_document_allowed
(
    p_itemtype            IN   VARCHAR2
,   p_itemkey             IN   VARCHAR2
,   p_notification_type   IN   VARCHAR2   --bug 3668188
)
RETURN BOOLEAN;


END PO_WF_PO_NOTIFICATION;

/
