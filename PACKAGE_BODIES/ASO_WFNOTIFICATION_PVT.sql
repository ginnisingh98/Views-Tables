--------------------------------------------------------
--  DDL for Package Body ASO_WFNOTIFICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_WFNOTIFICATION_PVT" AS
/* $Header: asovwntb.pls 120.1 2005/06/29 12:46:20 appldev ship $ */

/* For notifying a user/role */

PROCEDURE Notify_User (
                p_api_version		IN 	NUMBER,
                p_commit		IN	VARCHAR2 := FND_API.g_false,
                p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
                p_user_name 		IN   	VARCHAR2,
                p_subject 		IN   	VARCHAR2,
      		p_body 			IN   	VARCHAR2,
                x_return_status       OUT NOCOPY /* file.sql.39 change */  	 VARCHAR2,
                x_msg_count	 OUT NOCOPY /* file.sql.39 change */  NUMBER,
                x_msg_data	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
			)
IS

wf_itemkey_seq INTEGER;
wf_itemkey VARCHAR2(30);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('user_name: ' || p_user_name , 1, 'N' );
    aso_debug_pub.add('subject: ' || p_subject , 1, 'N' );
    aso_debug_pub.add('object: ' || p_body , 1, 'N' );
  END IF;

  select ASO_WFNOTIFICATION_S1.NEXTVAL into wf_itemkey_seq from dual;
		  wf_itemkey := 'ASO_USER_' || wf_itemkey_seq;

   wf_engine.CreateProcess   ( itemtype => 'ASO_USER',
			       itemkey  =>  wf_itemkey,
			       process  => 'ASO_NOTIFY_USER' );

   wf_engine.SetItemUserKey  ( itemtype => 'ASO_USER',
			       itemkey  =>  wf_itemkey,
			       userkey  => 'ASO User Notification ' || wf_itemkey_seq );

   wf_engine.SetItemAttrText ( itemtype => 'ASO_USER',
			       itemkey  =>  wf_itemkey,
			       aname    => 'ROLE_TO_NOTIFY',
			       avalue   =>  p_user_name );

   wf_engine.SetItemAttrText ( itemtype => 'ASO_USER',
			       itemkey  =>  wf_itemkey,
			       aname    => 'NOTIFICATION_SUBJECT',
			       avalue   =>  p_subject );

   wf_engine.SetItemAttrText ( itemtype => 'ASO_USER',
			       itemkey  =>  wf_itemkey,
			       aname    => 'NOTIFICATION_BODY',
			       avalue   =>  p_body );

   wf_engine.SetItemOwner    ( itemtype => 'ASO_USER',
     			       itemkey  =>  wf_itemkey,
			       owner    =>  p_user_name );

   wf_engine.StartProcess    ( itemtype => 'ASO_USER',
			       itemkey  =>  wf_itemkey );


  EXCEPTION
      When others then
        x_return_status := FND_API.g_ret_sts_error;
        x_msg_count := 0;
	wf_core.context('ASO_WFNOTIFICATION_PVT', 'Notify_User', p_user_name, p_subject, p_body);
        raise;

END Notify_User;

/* For sending email to one or more email addresses */

PROCEDURE Send_Email ( p_api_version		IN 	NUMBER,
	               p_commit			IN	VARCHAR2 := FND_API.g_false,
	               p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
                       p_email_list 		IN   	VARCHAR2,
                       p_subject 		IN   	VARCHAR2,
	               p_body 			IN   	VARCHAR2,
                       x_return_status       OUT NOCOPY /* file.sql.39 change */  	 VARCHAR2,
                       x_msg_count	 OUT NOCOPY /* file.sql.39 change */  NUMBER,
                       x_msg_data	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
			)
IS

wf_itemkey_seq INTEGER;
wf_itemkey VARCHAR2(30);
role_name VARCHAR2(30);
role_display_name VARCHAR2(30);

BEGIN

  x_return_status := FND_API.g_ret_sts_success;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('email_list: ' || p_email_list , 1, 'N' );
    aso_debug_pub.add('subject: ' || p_subject , 1, 'N' );
    aso_debug_pub.add('object: ' || p_body , 1, 'N' );
  END IF;

  select ASO_WFNOTIFICATION_S2.NEXTVAL into wf_itemkey_seq from dual;
		  wf_itemkey := 'ASO_MAIL_' || wf_itemkey_seq;


  role_name := 'ASO_EMAIL_LIST_' || wf_itemkey_seq ;
  role_display_name := 'ASO_EMAIL_LIST_' || wf_itemkey_seq ;

  wf_directory.CreateAdHocUser ( name => role_name,
				 display_name => role_display_name,
				 notification_preference => 'MAILTEXT',
                                 email_address => p_email_list,
				 expiration_date => sysdate + 1 );

   wf_engine.CreateProcess     ( itemtype => 'ASO_MAIL',
				 itemkey  =>  wf_itemkey,
				 process  => 'ASO_SEND_EMAIL' );

   wf_engine.SetItemUserKey    ( itemtype => 'ASO_MAIL',
				 itemkey  =>  wf_itemkey,
				 userkey  => 'ASO Email Notification' || wf_itemkey_seq );

   wf_engine.SetItemAttrText   ( itemtype => 'ASO_MAIL',
				 itemkey  =>  wf_itemkey,
				 aname    => 'ROLE_TO_NOTIFY',
				 avalue   =>  role_name );

   wf_engine.SetItemAttrText   ( itemtype => 'ASO_MAIL',
				 itemkey  =>  wf_itemkey,
				 aname    => 'NOTIFICATION_SUBJECT',
				 avalue   =>  p_subject );

   wf_engine.SetItemAttrText   ( itemtype => 'ASO_MAIL',
				 itemkey  =>  wf_itemkey,
				 aname    => 'NOTIFICATION_BODY',
				 avalue   =>  p_body );

   wf_engine.SetItemOwner      ( itemtype => 'ASO_MAIL',
			         itemkey  =>  wf_itemkey,
        			 owner    =>  role_name );

   wf_engine.StartProcess      ( itemtype => 'ASO_MAIL',
				 itemkey  =>  wf_itemkey );

EXCEPTION

    When others then
      x_return_status := FND_API.g_ret_sts_error;
      x_msg_count := 0;
      wf_core.context('ASO_WFNOTIFICATION_PVT', 'Send_Email', p_email_list, p_subject, p_body );
      raise;

END Send_Email;

END ASO_WFNOTIFICATION_PVT ;

/
