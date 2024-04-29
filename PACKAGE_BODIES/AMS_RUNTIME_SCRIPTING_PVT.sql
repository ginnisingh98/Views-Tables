--------------------------------------------------------
--  DDL for Package Body AMS_RUNTIME_SCRIPTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_RUNTIME_SCRIPTING_PVT" as
/* $Header: amsvsceb.pls 115.2 2002/12/11 14:32:33 sanshuma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_RUNTIME_SCRIPTING_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_RUNTIME_SCRIPTING_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvsceb.pls';

g_ItemType    Varchar2(10) := 'AMSRSPWD';
g_processName Varchar2(30) := 'SENDPWD';

-----------------------------------------------------------------------
-- PROCEDURE
--    notifyForgetLogin
--
-- PURPOSE
--    Sends email to user with given email address
--
-- NOTES
--
-----------------------------------------------------------------------
PROCEDURE notifyForgetLogin(
      p_api_version           IN      NUMBER,
      p_init_msg_list         IN      VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                IN      VARCHAR2 DEFAULT fnd_api.g_false,
      p_user_name             IN      VARCHAR2,
      p_password              IN      VARCHAR2,
      p_email_address         IN      VARCHAR2,
      p_subject               IN      VARCHAR2,
      p_uname_label           IN      VARCHAR2,
      p_pwd_label             IN      VARCHAR2,
      x_return_status         OUT     NOCOPY VARCHAR2,
      x_msg_count             OUT     NOCOPY NUMBER,
      x_msg_data              OUT     NOCOPY VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)   := 'notifyForgetLogin';
   l_api_version   CONSTANT NUMBER         := 1.0;

   l_adhoc_user        WF_USERS.NAME%TYPE;
   l_item_key          WF_ITEMS.ITEM_KEY%TYPE;
   l_item_owner        WF_USERS.NAME%TYPE := 'SYSADMIN';

   l_partyId           Number;

   l_user_name         Varchar2(30) := NULL;
   l_disp_name         Varchar2(50) := NULL;
   l_role_name         Varchar2(30) := NULL;
   l_role_disp_name    Varchar2(50) := NULL;

   l_UserType          Varchar2(30) := 'ALL';
    l_messageName       WF_MESSAGES.NAME%TYPE;
   l_msgEnabled        VARCHAR2(3) :='Y';

   CURSOR c_login_user(c_login_name VARCHAR2) IS
   SELECT USR.CUSTOMER_ID Name
   FROM   FND_USER USR
   WHERE  USR.EMPLOYEE_ID  IS NULL
   AND    user_name = c_login_name;

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   AMS_UTILITY_PVT.debug_message('notifyForgetLogin starts');

   l_adhoc_user := upper(p_user_name);

   FOR c_rec IN c_login_user(l_adhoc_user) LOOP
     l_adhoc_user := 'HZ_PARTY:'||c_rec.Name;
     l_partyId    := c_rec.Name;
   END LOOP;

   AMS_UTILITY_PVT.debug_message('adhoc user : '||l_adhoc_user);
   AMS_UTILITY_PVT.debug_message('party id : '||l_partyId);

   IF(l_partyId IS NULL) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   wf_directory.createadhocuser(name => l_user_name,
        display_name => l_disp_name,
	  notification_preference => 'MAILTEXT',
        email_address => p_email_address
   );

   AMS_UTILITY_PVT.debug_message('ad hoc user name '||l_user_name||' display name '||l_disp_name);

   l_item_key := '-'||to_char(sysdate,'MMDDYYHH24MISS')||
                   '-'||l_adhoc_user;

   AMS_UTILITY_PVT.debug_message('Create and Start Process with Item Key: '||l_item_key);

   wf_engine.CreateProcess(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           process   => g_processName);

    wf_engine.SetItemUserKey(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           userkey   => l_item_key);

    -- user name label
    wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'AMS_USERNAME_LABEL',
           avalue    =>  p_uname_label);

    -- password label
    wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'AMS_PWD_LABEL',
           avalue    =>  p_pwd_label);

    -- user name
    wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'AMS_USERNAME',
           avalue    =>  p_user_name);

    -- password
    wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'AMS_PWD',
           avalue    =>  p_password);

    -- performer
    wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'AMS_PERF',
           avalue    =>  l_user_name);

    -- email address
    wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'AMS_EMAIL_ADDRESS',
           avalue    =>  p_email_address);

    -- subject
    wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'AMS_SUBJECT',
           avalue    =>  p_subject);

    wf_engine.SetItemOwner(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           owner     => l_item_owner);

    wf_engine.StartProcess(
           itemtype  => g_ItemType,
           itemkey   => l_item_key);

   AMS_UTILITY_PVT.debug_message('Process Started');

   AMS_UTILITY_PVT.debug_message('notifyForgetLogin ends');

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
     raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
     raise;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
     raise;

END notifyForgetLogin;


END AMS_RUNTIME_SCRIPTING_PVT;

/
