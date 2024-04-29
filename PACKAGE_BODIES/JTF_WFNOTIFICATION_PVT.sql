--------------------------------------------------------
--  DDL for Package Body JTF_WFNOTIFICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_WFNOTIFICATION_PVT" AS
/* $Header: JTFVWNTB.pls 120.2 2005/10/25 05:08:00 psanyal ship $ */

	PROCEDURE Send_Email (
	                p_api_version		IN 	NUMBER,
	                p_commit		IN	VARCHAR2 := FND_API.g_false,
	                p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
                     	email_list 		IN   	VARCHAR2,
                     	subject 		IN   	VARCHAR2,
	        	body 			IN   	VARCHAR2,
                     	return_status       OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
                	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
                	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
			)
        IS
                wf_itemkey_seq INTEGER;
			 wf_itemkey VARCHAR2(30);
			 role_name VARCHAR2(30);
			 role_display_name VARCHAR2(30);
        BEGIN
                return_status := FND_API.g_ret_sts_success;

--               DBMS_OUTPUT.put_line('email_list: ' || email_list );
--               DBMS_OUTPUT.put_line('subject: ' || subject );
--               DBMS_OUTPUT.put_line('body: ' || body );

        select JTF_WFNOTIFICATION_S2.NEXTVAL into wf_itemkey_seq from dual;
	   wf_itemkey := 'JTF_MAIL_' || wf_itemkey_seq;

	   role_name := 'JTF_EMAIL_LIST_' || wf_itemkey_seq ;
	   role_display_name := 'JTF_EMAIL_LIST_' || wf_itemkey_seq ;

        wf_directory.CreateAdHocUser(
						   name => role_name,
						   display_name => role_display_name,
						   notification_preference => 'MAILTEXT',
                                 		   email_address => email_list,
						   expiration_date => sysdate + 1
						  );

	   wf_engine.CreateProcess (
						   itemtype => 'JTF_MAIL',
						   itemkey  =>  wf_itemkey,
						   process  => 'JTF_SEND_MAIL'
						  );
	   wf_engine.SetItemUserKey (
						   itemtype => 'JTF_MAIL',
						   itemkey  =>  wf_itemkey,
						   userkey  => 'JTF Email Notification' || wf_itemkey_seq
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'JTF_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'ROLE_TO_NOTIFY',
						   avalue   =>  role_name
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'JTF_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'NOTIFICATION_SUBJECT',
						   avalue   =>  subject
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'JTF_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'NOTIFICATION_BODY',
						   avalue   =>  body
						  );
	   wf_engine.SetItemOwner (
						   itemtype => 'JTF_MAIL',
						   itemkey  =>  wf_itemkey,
						   owner    =>  role_name
						 );
	   wf_engine.StartProcess (
						   itemtype => 'JTF_MAIL',
						   itemkey  =>  wf_itemkey
						 );

        EXCEPTION
                When others then

                return_status := FND_API.g_ret_sts_error;
                x_msg_count := 0;

			 wf_core.context('JTF_WFNOTIFICATION_PVT',
						  'Send_Email',
		                       		   email_list,
						   subject,
						   body
						 );
                raise;
     END Send_Email;

END JTF_WFNOTIFICATION_PVT ;

/
