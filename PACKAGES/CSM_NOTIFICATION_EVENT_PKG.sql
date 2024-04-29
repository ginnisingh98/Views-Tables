--------------------------------------------------------
--  DDL for Package CSM_NOTIFICATION_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_NOTIFICATION_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmentfs.pls 120.2.12010000.4 2010/03/03 09:37:21 saradhak ship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- Ravi Eanjan   27/06/02     1. For sender name will be taken from
--                               jtf_rs_resource_extns.source_name istead of fnd_user.user_name
--                            2. Notification_id is Item Key in Processes
--                               NOTIFICATION_INS_USERLOOP and NOTIFICATION_DEL_USERLOOP
-- ---------      ------        ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE INSERT_NOTIFICATIONS_ACC (p_notification_id wf_notifications.notification_id%TYPE,
                                    p_user_id	fnd_user.user_id%TYPE);

PROCEDURE NOTIFICATIONS_ACC_PROCESSOR(p_user_id IN NUMBER);

FUNCTION NOTIFICATION_ATTR_WF_EVENT_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2;

FUNCTION NOTIFICATION_DEL_WF_EVENT_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2;

PROCEDURE PURGE_NOTIFICATION_CONC(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2);

--Bug 5337816
PROCEDURE DOWNLOAD_NOTIFICATION(p_notification_id IN NUMBER ,x_return_status OUT NOCOPY VARCHAR2);

--Support for email triggered Sync
FUNCTION createMobileWFUser(b_user_name IN VARCHAR2) RETURN BOOLEAN;
FUNCTION send_email(b_user_name VARCHAR2, subject VARCHAR2, message_body VARCHAR2) return NUMBER;

PROCEDURE NOTIFY_USER(entity varchar2, pk_value varchar2,p_mode varchar2) ;

PROCEDURE NOTIFY_USER(p_wf_param wf_event_t) ;

--Bug 9435049
PROCEDURE NOTIFY_RESPONSE(item_type in varchar2, p_item_key 	in varchar2,
activity_id in number, command in varchar2, resultout 	in out NOCOPY varchar2);

FUNCTION NOTIFICATION_TIMER_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2;

PROCEDURE notify_deferred(p_user_name IN VARCHAR2,
                      p_tranid   IN NUMBER,
                      p_pubitem  IN VARCHAR2,
                      p_sequence  IN NUMBER,
					  p_dml_type  IN VARCHAR2,
					  p_pk IN VARCHAR2,
                      p_error_msg IN VARCHAR2);

FUNCTION EMAIL_SYNC_ERROR_ADMIN_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2;

PROCEDURE PURGE_USER(p_user_id IN NUMBER);

PROCEDURE EMAIL_SYNC_ERRORS_CONC(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2);

END CSM_NOTIFICATION_EVENT_PKG; -- Package spec



/
