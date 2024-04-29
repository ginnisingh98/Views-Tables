--------------------------------------------------------
--  DDL for Package AR_NOTIFICATION_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_NOTIFICATION_STANDARD" AUTHID CURRENT_USER as
/*$Header: ARNOTSTS.pls 120.2 2005/07/22 12:53:52 naneja noship $ */

/*Bug 44509019 Removed GSCC warning file.sql.39 used NOCOPY hint for OUT and IN OUT parameter type*/
function createUrl(p_function in varchar2) return varchar2;

procedure build_error_message(document_id	in	varchar2,
			      display_type	in	varchar2,
			      document		in out NOCOPY	varchar2,
			      document_type	in out NOCOPY	varchar2);
/*
procedure build_error_message_clob(document_id		in	varchar2,
			           display_type		in	varchar2,
			           document		in out	CLOB,
			           document_type	in out	varchar2);
*/

procedure notify(p_subject in varchar2,
                 p_sqlerrm in varchar2,
                 p_role_name in varchar2,
                 p_url in varchar2 default null);

procedure notifyToSysadmin(p_subject in varchar2,
                           p_sqlerrm in varchar2,
                           p_url     in varchar2 default null);

procedure parseDocumentId(p_document_id in varchar2,
                          p_item_type   out NOCOPY varchar2,
                          p_item_key    out NOCOPY varchar2);

procedure isURLEmpty(ITEMTYPE  IN      VARCHAR2,
                     ITEMKEY   IN      VARCHAR2,
                     ACTID     IN      NUMBER,
                     FUNCMODE  IN      VARCHAR2,
                     RESULTOUT IN OUT NOCOPY  VARCHAR2);

procedure isMessageEmpty(ITEMTYPE  IN      VARCHAR2,
                         ITEMKEY   IN      VARCHAR2,
                         ACTID     IN      NUMBER,
                         FUNCMODE  IN      VARCHAR2,
                         RESULTOUT IN OUT NOCOPY  VARCHAR2);

procedure compileMessage(ITEMTYPE  IN      VARCHAR2,
                         ITEMKEY   IN      VARCHAR2,
                         ACTID     IN      NUMBER,
                         FUNCMODE  IN      VARCHAR2,
                         RESULTOUT IN OUT NOCOPY  VARCHAR2);

procedure raiseNotificationEvent(p_event_name     in VARCHAR2,
                                 p_subject        in VARCHAR2,
                                 p_doc_pkg        in VARCHAR2,
                                 p_doc_proc       in VARCHAR2,
                                 p_role_name      in VARCHAR2,
                                 p_url            in VARCHAR2 default NULL,
                                 p_user_area1     in VARCHAR2 default NULL,
                                 p_user_area2     in VARCHAR2 default NULL,
                                 p_user_area3     in VARCHAR2 default NULL,
                                 p_user_area4     in VARCHAR2 default NULL,
                                 p_user_area5     in VARCHAR2 default NULL);
end;

 

/
