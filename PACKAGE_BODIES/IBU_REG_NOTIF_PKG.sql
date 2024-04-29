--------------------------------------------------------
--  DDL for Package Body IBU_REG_NOTIF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_REG_NOTIF_PKG" 
/* $Header: iburgnob.pls 115.9.1158.2 2002/07/25 00:25:50 jamose noship $ */
	as

procedure ibu_send_reg_notification(email_address_in in varchar2,
							 subject in VARCHAR2,
							 user_id in VARCHAR2,
							 reg_greeting in VARCHAR2,
							 reg_thankyou in VARCHAR2,
							 reg_info in VARCHAR2,
							 reg_acctinfo in VARCHAR2,
							 reg_username in VARCHAR2,
							 reg_password in VARCHAR2,
							 reg_contractnum in VARCHAR2,
							 reg_csinum in VARCHAR2,
							 reg_changepwd in VARCHAR2,
							 reg_print in VARCHAR2,
							 reg_logon in VARCHAR2,
							 reg_thanks in VARCHAR2,
							 reg_closing in VARCHAR2,
							 reg_isupport in VARCHAR2)
as
	user_name      varchar2(100):=null;
	user_display_name   varchar2(100):=null;
	language		varchar2(100):='AMERICAN';
	territory		varchar2(100):='America';
	description	varchar2(100):=NULL;
	notification_preference varchar2(100):='MAILTEXT';
	email_address	varchar2(100):=NULL;
	fax			varchar2(100):=NULL;
	status		varchar2(100):='ACTIVE';
	expiration_date varchar2(100):=NULL;
	role_name		varchar2(100):=NULL;
	role_display_name	varchar2(100):=NULL;
	role_description 	varchar2(100):=NULL;
	wf_id		Number;
	msg_type  varchar2(100):='IBU_RG';
	msg_name  varchar2(100):='IBU_REG_MESSAGE';

	due_date date:=NULL;
	callback varchar2(100):=NULL;
    context varchar2(100):=NULL;
    send_comment varchar2(100):=NULL;
    priority  number:=10;

    now               VARCHAR2(60);

duplicate_user_or_role	exception;
PRAGMA	EXCEPTION_INIT (duplicate_user_or_role, -20002);

begin
	/*Create a role for ad hoc user if none exist*/
     --select to_char(sysdate, 'mm-dd-yyyy hh24:mi:ss') into now from dual;
     --select to_char(sysdate, 'mmddyyyyhh24miss') into now from dual;
     --role_name:=user_id || now;
	role_name:= 'IBU_' || substr(user_id, 1, 25);
	role_display_name:=role_name;
	email_address:=email_address_in;

	begin
		WF_Directory.CreateAdHocRole (role_name, role_display_name, language, territory,  role_description, notification_preference, user_name, email_address, fax, status, expiration_date);
	exception
		when duplicate_user_or_role then
		WF_Directory.SetAdHocRoleAttr (role_name, role_display_name, notification_preference, language, territory, email_address, fax);
	end;


	wf_id:=WF_Notification.send (role_name, 'IBU_RG', 'IBU_REG_MESSAGE', due_date, callback, context, send_comment, priority);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_SUBJECT', subject);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_GREETING', reg_greeting);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_THANKYOU', reg_thankyou);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_INFO', reg_info);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_ACCTINFO', reg_acctinfo);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_USERNAME', reg_username);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_PASSWORD', reg_password);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_CONTRACTNUM', reg_contractnum);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_CSINUM', reg_csinum);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_CHANGEPWD', reg_changepwd);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_PRINT', reg_print);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_LOGON', reg_logon);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_THANKS', reg_thanks);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_CLOSING', reg_closing);
	WF_Notification.SetAttrText (wf_id, 'IBU_REG_ISUPPORT', reg_isupport);

	/* commit;  */

end ibu_send_reg_notification;



end ibu_reg_notif_pkg;

/
