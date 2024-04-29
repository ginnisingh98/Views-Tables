--------------------------------------------------------
--  DDL for Package Body IBE_WFNOTIFICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_WFNOTIFICATION_PVT" AS
/* $Header: IBEVWNTB.pls 115.5 2002/12/10 11:29:56 suchandr ship $ */

	PROCEDURE Notify_User (
	                p_api_version		IN 	NUMBER,
	                p_commit			IN	VARCHAR2 := FND_API.g_false,
	                p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
                     user_name 		IN   VARCHAR2,
                     subject 			IN   VARCHAR2,
	        		 body 			IN   VARCHAR2,
                     return_status      OUT NOCOPY  VARCHAR2,
                	 x_msg_count		OUT NOCOPY	NUMBER,
                	 x_msg_data		OUT NOCOPY VARCHAR2
			)
        IS
                wf_itemkey_seq INTEGER;
			 wf_itemkey VARCHAR2(30);
        BEGIN
                return_status := FND_API.g_ret_sts_success;

--                DBMS_OUTPUT.put_line('user_name: ' || user_name );
--                DBMS_OUTPUT.put_line('subject: ' || subject );
--                DBMS_OUTPUT.put_line('body: ' || body );

        select IBE_WFNOTIFICATION_S1.NEXTVAL into wf_itemkey_seq from dual;
	   wf_itemkey := 'IBE_USER_' || wf_itemkey_seq;

	   wf_engine.CreateProcess (
						   itemtype => 'IBE_USER',
						   itemkey  =>  wf_itemkey,
						   process  => 'IBE_NOTIFY_USER'
						  );
	   wf_engine.SetItemUserKey (
						   itemtype => 'IBE_USER',
						   itemkey  =>  wf_itemkey,
						   userkey  => 'IBE User Notification ' || wf_itemkey_seq
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'IBE_USER',
						   itemkey  =>  wf_itemkey,
						   aname    => 'ROLE_TO_NOTIFY',
						   avalue   =>  user_name
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'IBE_USER',
						   itemkey  =>  wf_itemkey,
						   aname    => 'NOTIFICATION_SUBJECT',
						   avalue   =>  subject
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'IBE_USER',
						   itemkey  =>  wf_itemkey,
						   aname    => 'NOTIFICATION_BODY',
						   avalue   =>  body
						 );
	   wf_engine.SetItemOwner (
						   itemtype => 'IBE_USER',
						   itemkey  =>  wf_itemkey,
						   owner    =>  user_name
						 );
	   wf_engine.StartProcess (
						   itemtype => 'IBE_USER',
						   itemkey  =>  wf_itemkey
						 );

        EXCEPTION
                When others then

                return_status := FND_API.g_ret_sts_error;
                x_msg_count := 0;

			 wf_core.context('IBE_WFNOTIFICATION_PVT',
						  'Notify_User',
		                       user_name,
						   subject,
						   body
						 );
                raise;
     END Notify_User;

	PROCEDURE Send_Email (
	                p_api_version		IN 	NUMBER,
	                p_commit			IN	VARCHAR2 := FND_API.g_false,
	                p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
                     email_list 		IN   VARCHAR2,
                     subject 			IN   VARCHAR2,
	        		 body 			IN   VARCHAR2,
                     return_status      OUT NOCOPY  VARCHAR2,
                	 x_msg_count		OUT NOCOPY	NUMBER,
                	 x_msg_data		OUT NOCOPY	VARCHAR2
			)
        IS
                wf_itemkey_seq INTEGER;
			 wf_itemkey VARCHAR2(30);
			 role_name VARCHAR2(30);
			 role_display_name VARCHAR2(30);
        BEGIN
                return_status := FND_API.g_ret_sts_success;

--                DBMS_OUTPUT.put_line('email_list: ' || email_list );
--                DBMS_OUTPUT.put_line('subject: ' || subject );
--                DBMS_OUTPUT.put_line('body: ' || body );

        select IBE_WFNOTIFICATION_S2.NEXTVAL into wf_itemkey_seq from dual;
	   wf_itemkey := 'IBE_MAIL_' || wf_itemkey_seq;

	   role_name := 'IBE_EMAIL_LIST_' || wf_itemkey_seq ;
	   role_display_name := 'IBE_EMAIL_LIST_' || wf_itemkey_seq ;

        wf_directory.CreateAdHocUser(
						   name => role_name,
						   display_name => role_display_name,
						   notification_preference => 'MAILTEXT',
                                 email_address => email_list,
						   expiration_date => sysdate + 1
						  );

	   wf_engine.CreateProcess (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   process  => 'IBE_SEND_EMAIL'
						  );
	   wf_engine.SetItemUserKey (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   userkey  => 'IBE Email Notification' || wf_itemkey_seq
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'ROLE_TO_NOTIFY',
						   avalue   =>  role_name
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'NOTIFICATION_SUBJECT',
						   avalue   =>  subject
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'NOTIFICATION_BODY',
						   avalue   =>  body
						  );
	   wf_engine.SetItemOwner (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   owner    =>  role_name
						 );
	   wf_engine.StartProcess (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey
						 );

        EXCEPTION
                When others then

                return_status := FND_API.g_ret_sts_error;
                x_msg_count := 0;

			 wf_core.context('IBE_WFNOTIFICATION_PVT',
						  'Send_Email',
		                       email_list,
						   subject,
						   body
						 );
                raise;
     END Send_Email;


	PROCEDURE Send_Html_Email (
	                p_api_version		IN 	NUMBER,
	                p_commit			IN	VARCHAR2 := FND_API.g_false,
	                p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
                     email_list 		IN   VARCHAR2,
                     subject 			IN   VARCHAR2,
	        		 body 			IN   VARCHAR2,
                     return_status      OUT NOCOPY  VARCHAR2,
                	 x_msg_count		OUT NOCOPY	NUMBER,
                	 x_msg_data		OUT NOCOPY	VARCHAR2
			)
        IS
                wf_itemkey_seq INTEGER;
			 wf_itemkey VARCHAR2(30);
			 role_name VARCHAR2(30);
			 role_display_name VARCHAR2(30);
        BEGIN
                return_status := FND_API.g_ret_sts_success;

--                DBMS_OUTPUT.put_line('email_list: ' || email_list );
--                DBMS_OUTPUT.put_line('subject: ' || subject );
--                DBMS_OUTPUT.put_line('body: ' || body );

        select IBE_WFNOTIFICATION_S2.NEXTVAL into wf_itemkey_seq from dual;
	   wf_itemkey := 'IBE_MAIL_' || wf_itemkey_seq;

	   role_name := 'IBE_EMAIL_LIST_' || wf_itemkey_seq ;
	   role_display_name := 'IBE_EMAIL_LIST_' || wf_itemkey_seq ;

        wf_directory.CreateAdHocUser(
						   name => role_name,
						   display_name => role_display_name,
						   notification_preference => 'MAILHTML',
                                 email_address => email_list,
						   expiration_date => sysdate + 1
						  );

	   wf_engine.CreateProcess (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   process  => 'IBE_SEND_EMAIL'
						  );
	   wf_engine.SetItemUserKey (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   userkey  => 'IBE Email Notification' || wf_itemkey_seq
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'ROLE_TO_NOTIFY',
						   avalue   =>  role_name
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'NOTIFICATION_SUBJECT',
						   avalue   =>  subject
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'NOTIFICATION_BODY',
						   avalue   =>  body
						  );
	   wf_engine.SetItemOwner (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey,
						   owner    =>  role_name
						 );
	   wf_engine.StartProcess (
						   itemtype => 'IBE_MAIL',
						   itemkey  =>  wf_itemkey
						 );

        EXCEPTION
                When others then

                return_status := FND_API.g_ret_sts_error;
                x_msg_count := 0;

			 wf_core.context('IBE_WFNOTIFICATION_PVT',
						  'Send_HTML_Email',
		                       email_list,
						   subject,
						   body
						 );
                raise;
     END Send_Html_Email;

END IBE_WFNOTIFICATION_PVT ;

/
