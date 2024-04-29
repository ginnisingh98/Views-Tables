--------------------------------------------------------
--  DDL for Package Body UMX_PROXY_NTF_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_PROXY_NTF_WF" as
/*$Header: UMXVPNTB.pls 120.0.12010000.4 2017/11/10 03:58:47 avelu ship $*/

  /**
   *  Please look at the Specifications for the details
   */
  PROCEDURE LAUNCH_WORKFLOW (p_proxy_username  in varchar2,
                             p_start_date      in date,
                             p_end_date        in date default null,
                             p_notes	       in varchar2 default null) is


  cursor get_delegator_name is
    select nvl(hz_format_pub.format_name(person_party_id),user_name), UMX_PROXY_NOTIFICATIONS_S.NEXTVAL from fnd_user where user_id = FND_GLOBAL.USER_ID;

  l_itemtype VARCHAR2 (8) := 'UMXPXYNF';
  l_itemkey  NUMBER;
  l_delegator_name varchar2(500);

  BEGIN

    OPEN get_delegator_name;
    FETCH get_delegator_name INTO l_delegator_name, l_itemkey;
    CLOSE get_delegator_name;

    -- Call the Workflow API to send the notification.
    WF_ENGINE.CREATEPROCESS (itemtype   => l_itemtype,
                             itemkey    => l_itemkey,
                             process    => 'PROXYNOTIFY',
                             owner_role => FND_GLOBAL.USER_NAME);

    -- Set Workflow Item Attributes.
    WF_ENGINE.SETITEMATTRTEXT (l_itemtype, l_itemkey, 'DELEGATOR_NAME', l_delegator_name);
    WF_ENGINE.SETITEMATTRTEXT (l_itemtype, l_itemkey, 'PROXY_USERNAME', p_proxy_username);
     WF_ENGINE.SETITEMATTRDATE (l_itemtype, l_itemkey, 'START_DATE', p_start_date);
     WF_ENGINE.SETITEMATTRDATE (l_itemtype, l_itemkey, 'END_DATE', p_end_date);
	WF_ENGINE.SETITEMATTRTEXT (l_itemtype, l_itemkey, 'NOTES', p_notes);



    WF_ENGINE.STARTPROCESS (l_itemtype, l_itemkey);
  END LAUNCH_WORKFLOW;


end UMX_PROXY_NTF_WF;

/
