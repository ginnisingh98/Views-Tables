--------------------------------------------------------
--  DDL for Package Body JTF_UM_PASSWORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_PASSWORD_PVT" as
/* $Header: JTFVUMPB.pls 120.2.12010000.2 2009/09/28 13:51:54 dbowles ship $ */
-- Start of Comments
-- Package name     : JTF_UM_PASSWORD_PVT
-- Purpose          : generate password and send email to user with the password.
-- History          :

-- KCHERVEL  12/03/01  Created
-- NOTE             :
-- End of Comments
/* ------------------------------------------------------------------------
-- Revision history
-- 11/26/2002   kchervel modified calls to jtf_um_util_pvt.get_wf_user as
--                       the signature has changed
-- 05/23/2002   kchervel  set the password date to null when the password is
--                        reset. This forces the user to change password.
-- 04/14/2005	snellepa modified queries for bug 4287135
*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'JTF_UM_PASSWORD_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'JTFVUMPB.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

G_MODULE          VARCHAR2(40) := 'JTF.UM.PLSQL.PASSWORD';
l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(G_MODULE);

ascii_offset          int     := 65;
NEWLINE	VARCHAR2(1) := fnd_global.newline;
TAB	VARCHAR2(1) := fnd_global.tab;

/**
 * Procedure   :  generate_password
 * Type        :  Private
 * Pre_reqs    :
 * Description : Creates a password. The length of the password is obtained from the profile
 *               SIGNON_PASSWORD_LENGTH.
 * Parameters
 * input parameters : None
 * output parameters
 * @return   returns a String that can be used as the password
  * Errors      :
 * Other Comments :
 */
procedure generate_password (p_api_version_number  in number,
                 p_init_msg_list               in varchar2 := FND_API.G_FALSE,
                 p_commit                      in varchar2 := FND_API.G_FALSE,
                 p_validation_level            in number
                                                := FND_API.G_VALID_LEVEL_FULL,
                 x_password                  out NOCOPY varchar2,
                 x_return_status             out NOCOPY varchar2,
                 x_msg_count                 out NOCOPY number,
                 x_msg_data                  out NOCOPY varchar2
                 ) is

  l_password_len   int := 6;
  l_api_version_number  NUMBER := 1.0;
  l_api_name            VARCHAR2(50) := 'generate_password';

begin

    -- Write to debug log
    -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Entering API Generate_Password ...');
    -- JTF_DEBUG_PUB.add_debug_msg('Starting at '||sysdate);

    -- Standard Start of API savepoint
    SAVEPOINT generate_password;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

     -- initialize the random number generator
     dbms_random.initialize(dbms_utility.get_time);

     -- using the profile, determine the length of the random number
     l_password_len := nvl(fnd_profile.value('SIGNON_PASSWORD_LENGTH'),
                                                   l_password_len);

    -- generate a random number to determine where to use an alphabet or a
    -- numeric character for a given position in the password

    for j in 1..l_password_len loop
      if (mod(abs(dbms_random.random),2) = 1) then
        -- generate number
        x_password := x_password || mod(abs(dbms_random.random),10);
      else
        -- generate character
        x_password := x_password || fnd_global.local_chr(mod(abs(dbms_random.random),26)
                 + ascii_offset);
      end if;
    end loop;

    -- terminate the random number generator
    dbms_random.terminate;

    --
    -- End of API body
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

    -- Write to debug log
    -- JTF_DEBUG_PUB.add_debug_msg('Starting at '||sysdate);
    -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Exiting API Generate_Password ...');
    --

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN OTHERS THEN
	  JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => JTF_DEBUG_PUB.G_EXC_OTHERS
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);
end generate_password;

/**
 * Procedure   :  send_password
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure initiates a workflow that sends an email to the user.
 * Parameters  : None
 * input parameters (see workflow parameters for description)
 *     param  requester_user_name     (*)
 *     param  requester_password      (*)
 *     param   requester_last_name
 *     param   requester_first_name
 *     param   usertype_id
 *     param   responsibility_id
 *     param   application_id
 *     param  first_time_user (Possible values  'Y', 'N')
 *     param  send_password   (Possible values  'Y', 'N')
 *     param  confirmation_number
 *
 *  (*) required fields
 * output parameters
 *     param  x_return_status
 *     param  x_msg_data
 *     param  x_msg_count
  * Errors      : Expected Errors
 *               requester_user_name or password is null
 *               user is not a valid user in fnd_user (user_name does not exist or is enddated).
 *               user does not have an email in fnd_user table.
 * Other Comments :
 * DEFAULTING LOGIC
 * For the default workflow (JTAUMPSW) that is called by this API the following are valid:
 * 1. Whether or not approval is needed is determined by the usertype_id.
 *           select 'T' from jtf_um_usertypes_b
 *           where usertype_id = p_usertype_id
 *           and approval_id is not NULL;
 * 2. If last name and first name are not passed then the last name is defaulted
 *    to the user name and this will be used in the messages within the workflow
 * 3. If application_id is NULL and responsibility_id is not NULL then
 *    application_id is determined using responsibility_id. Values for all the
 *    profiles (JTF_UM_APPROVAL_URL, JTA_UM_SUPPORT_CONTACT, JTF_UM_MERCHANT_NAME,
 *    JTA_UM_SENDER) are determined using the application id and responsibility_id.
 *    If both are null then the site level values are returned.
 *
 */



procedure send_password (p_api_version_number  in number,
                 p_init_msg_list               in varchar2 := FND_API.G_FALSE,
                 p_commit                      in varchar2 := FND_API.G_FALSE,
                 p_validation_level            in number   := FND_API.G_VALID_LEVEL_FULL,
                 p_requester_user_name         in varchar2,
                 p_requester_password          in varchar2,
                 p_requester_last_name         in varchar2 := null,
                 p_requester_first_name        in varchar2 := null,
                 p_usertype_id                 in number := null,
                 p_responsibility_id         in number := null,
                 p_application_id            in number := null,
                 p_wf_user_name              in varchar2 := null,
                 p_first_time_user           in varchar2 := 'Y',
                 p_user_verified             in varchar2 := 'N',
                 p_confirmation_number       in varchar2 := null,
                 p_enrollment_only           in varchar2 := 'N',
                 p_enrollment_list           in varchar2 := null,
                 x_return_status             out NOCOPY varchar2,
                 x_msg_count                 out NOCOPY number,
                 x_msg_data                  out NOCOPY varchar2
                 ) is

  l_api_version_number  NUMBER := 1.0;
  l_api_name            VARCHAR2(50) := 'SEND_PASSWORD';
  itemkey             number ;
  itemtype            varchar2 (80);
  processOwner        varchar2 (100);
  processName         varchar2(50) := 'SEND_PASSWORD';

  l_email             varchar2(240);
  l_responsibility_id number := p_responsibility_id;
  l_application_id    number := p_application_id;
  l_requester_user_name varchar2(250) := upper(p_requester_user_name);
  l_requester_email     varchar2(240) := null;
  l_wf_user_name varchar2(250) := p_wf_user_name;

  CURSOR c_item_key IS SELECT JTF_UM_PSW_WF_S.nextval FROM dual;

  CURSOR c_user(l_user_name in varchar2) IS
    select email_address
    from fnd_user
    where user_name = l_user_name
    and (nvl(end_date, sysdate+1) > sysdate OR
         to_char(END_DATE) = to_char(FND_API.G_MISS_DATE));

  CURSOR c_wf_user(l_user_name in varchar2) IS
    select email_address
    from wf_users
    where name = l_user_name ;



begin
    JTF_DEBUG_PUB.log_entering_method(G_MODULE, l_api_name);


    -- Write to debug log
    -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Entering API send_Password ...');
    --

    -- Standard Start of API savepoint
    SAVEPOINT send_password;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    -- Validate required fields for not null values

        if (p_requester_user_name is null) then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTA_UM_REQUIRED_FIELD');
            --FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME, FALSE);
            FND_MESSAGE.Set_Token('API_NAME', 'sending the password', FALSE);
            FND_MESSAGE.Set_Token('FIELD', 'USER_NAME', FALSE);
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        end if;

        -- password can be null when sending only enrollments

        if (p_requester_password is null and p_enrollment_only <> 'Y') then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTA_UM_REQUIRED_FIELD');
            --FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME, FALSE);
            FND_MESSAGE.Set_Token('API_NAME', 'sending the password', FALSE);
            FND_MESSAGE.Set_Token('FIELD', 'PASSWORD', FALSE);
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        end if;

        -- validate user_name
        -- validate end date and email address using user_name
        Open c_user(l_requester_user_name);
        Fetch c_user into l_requester_email;
        If (c_user%NOTFOUND) then
          Close c_user;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTA_UM_INVALID_FIELD');
            --FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME, FALSE);
            FND_MESSAGE.Set_Token('API_NAME', 'sending the password', FALSE);
            FND_MESSAGE.Set_Token('FIELD', 'USER', FALSE);
            FND_MESSAGE.Set_Token('VALUE', p_requester_user_name, FALSE);
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        Close c_user;
       -- get email address to which the password needs to be sent
       if l_wf_user_name is NULL then
          JTF_UM_UTIL_PVT.get_wf_user(p_api_version_number  => 1.0,
                 x_requester_user_name    => l_requester_user_name,
                 x_requester_email        => l_requester_email   ,
                 x_wf_user                => l_wf_user_name,
                 x_return_status          => x_return_Status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_Data );

         if x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
         elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;
        -- if wf_user is NULL then we need to create an adhoc user
        -- create adhoc user
        if l_wf_user_name is NULL then
          l_wf_user_name := 'JTFUM-'|| l_requester_user_name;
          JTF_UM_UTIL_PVT.GetAdHocUser (p_api_version_number => 1.0,
                    p_username           => l_wf_user_name,
                    p_display_name       => l_requester_user_name,
                    p_email_address      => l_requester_email,
                    x_return_status      => x_return_status,
                    x_msg_data           => x_msg_data,
                    x_msg_count          => x_msg_count);
           if x_return_status <> FND_API.G_RET_STS_SUCCESS then
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;
         end if;

       end if;
       --
        If l_requester_email is NULL then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTA_UM_REQUIRED_EMAIL');
            --FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME, FALSE);
            FND_MESSAGE.Set_Token('API_NAME', 'sending the password', FALSE);
            FND_MESSAGE.Set_Token('USER_NAME',p_requester_user_name, FALSE);
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        end if;



       -- default the responsibility and application id if needed
       JTF_UM_UTIL_PVT.getDefaultAppRespId(P_USERNAME => p_requester_user_name,
                                P_RESP_ID   => l_responsibility_id,
                                P_APPL_ID   => l_application_id,
                                X_RESP_ID   => l_responsibility_id,
                                X_APPL_ID   => l_application_id);


        -- setting workflow parameters
        -- the WF process owner should be the merchant sysadmin
        processOwner := nvl (JTF_UM_UTIL_PVT.VALUE_SPECIFIC (
                name              => 'JTA_UM_WORKFLOW_OWNER',
                responsibility_id => l_responsibility_id,
                resp_appl_id      => l_application_id,
                application_id    => l_application_id,
                site_level           => true), 'SYSADMIN');

        itemtype := nvl(JTF_UM_UTIL_PVT.VALUE_SPECIFIC(
                name              => 'JTA_UM_PASSWORD_GEN_WKF',
                responsibility_id => l_responsibility_id,
                resp_appl_id      => l_application_id,
                application_id    => l_application_id,
                site_level           => true), 'JTAUMPSW');

        Open  c_item_key;
        Fetch c_item_key into itemkey;
        Close c_item_key;

        --processName := 'SEND_PASSWORD';
        --
        -- Start Process
        --
        wf_engine.CreateProcess (itemtype,
                                 itemkey,
                                 processName);

        -- Set Workflow Attributes

        -- set user item key
         wf_engine.SetItemUserKey (itemtype => itemtype,
                                  itemkey  => itemkey,
                                  UserKey  => substr(p_requester_user_name|| ' request for password',1,80));

        -- set user name
         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUESTER_USER_NAME',
                                   avalue   =>  l_requester_user_name);

        -- set user name
         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'WF_USER_NAME',
                                   avalue   =>  l_wf_user_name);

        -- set password
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'REQUESTER_PASSWORD',
                                     avalue   => p_requester_password);

        -- set name
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUESTER_LAST_NAME',
                                   avalue   =>  p_requester_last_name);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUESTER_FIRST_NAME',
                                   avalue   =>  p_requester_first_name);
        -- set user type id
        wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'REQUESTER_USERTYPE_ID',
                                     avalue   => p_usertype_id);

        -- set responsibility id
        wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'RESPONSIBILITY_ID',
                                     avalue   => l_responsibility_id);

       -- set application id
        wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'APPLICATION_ID',
                                     avalue   => l_application_id);
      -- set confirmation id
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'CONFIRMATION_NUMBER',
                                     avalue   => p_confirmation_number);

        -- set first time user
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'FIRST_TIME_USER',
                                     avalue   => p_first_time_user);

        -- set user verified
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'USER_VERIFIED',
                                     avalue   => p_user_verified);

       -- set enrollment only
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'ENROLLMENT_ONLY',
                                     avalue   => p_enrollment_only);

      -- set enrollment information
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'ENROLLMENTS',
                                     avalue   => p_enrollment_list);

        --
        -- Launch the send password workflow
        --

        wf_engine.startProcess(itemtype => itemType,
                               itemkey  => itemKey);

    --
    -- End of API body
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

        -- Write to debug log
        -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Exiting API send_Password ...');
        --

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN OTHERS THEN
	  JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => JTF_DEBUG_PUB.G_EXC_OTHERS
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);


end send_password;



/**
 * Procedure   :  set_parameters
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure sets all the parameters needed for the email / notifications.
 * Parameters  :
 * input parameters (see workflow parameters for description)
 *     param  requester_user_name
 *     param   requester_password
 *     param   requester_name
 *     param   usertype_id
 *     param   responsibility_id
 *     param   application_id
 *     param   first_time_user
 *     param   send_password
 *     param  confirmation_id
 * output parameters
 *     param  x_return_status
 *     param  x_msg_data
 *     param  x_msg_count
  * Errors      :
 * Other Comments :
 */
procedure set_parameters (
                 itemtype                      in varchar2,
                 itemkey                       in varchar2,
                 p_requester_user_name         in varchar2,
                 p_usertype_id                 in number,
                 p_responsibility_id           in number ,
                 p_application_id              in number,
                 p_requester_first_name        in varchar2,
                 p_requester_last_name         in varchar2,
                 x_return_status               out NOCOPY varchar2) is

   l_approval_needed varchar2(1) := 'F';
   l_appl_url        varchar2(1000);
   l_sender          varchar2(1000);
   l_support_contact varchar2(1000);
   l_merchant_name   varchar2(1000);
   l_application_id  number;

   cursor approval_needed(user_type_id in number) is
    select 'T' from jtf_um_usertypes_b
    where usertype_id = user_type_id
    and approval_id is not NULL;

  cursor appl_id(p_resp_id in number) is
   select application_id from fnd_responsibility
   where responsibility_id = p_resp_id;

begin
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_application_id := p_application_id;

   -- set approval_required
   -- check if approval is required using the usertype id. If usertype_id
   -- is NULL then approval_needed is defaulted to 'F'

   if p_usertype_id is not NULL then
     open  approval_needed(p_usertype_id);
     fetch approval_needed into l_approval_needed;
     close approval_needed;
   end if;
   --dbms_output.put_line('approval needed '||l_approval_needed);
   wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'APPROVAL_REQUIRED',
                                   avalue   => l_approval_needed);


 /*  -- get application id from responsibility id if needed / possible

   if l_application_id is NULL
     and p_responsibility_id is not NULL then
      open appl_id(p_responsibility_id);
      fetch appl_id into l_application_id;
      close appl_id;
   end if; */

   -- set the URL
   l_appl_url := JTF_UM_UTIL_PVT.value_specific(name => 'JTA_UM_APPL_URL',
                             responsibility_id => p_responsibility_id,
                             resp_appl_id     =>  p_application_id,
                             application_id => p_application_id,
                             site_level => true);

    wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'APPL_URL',
                                   avalue   => l_appl_url);

   -- set support contact
   l_support_contact := JTF_UM_UTIL_PVT.value_specific(
                             name => 'JTA_UM_SUPPORT_CONTACT',
                             responsibility_id => p_responsibility_id,
                             resp_appl_id      => p_application_id,
                             application_id => p_application_id,
                             site_level => true);

   wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'SUPPORT_CONTACT',
                                   avalue   => l_support_contact);

   -- set merchant name
   l_merchant_name := JTF_UM_UTIL_PVT.value_specific(name => 'JTF_UM_MERCHANT_NAME',
                             responsibility_id => p_responsibility_id,
                             resp_appl_id      => p_application_id,
                             application_id => l_application_id,
                             site_level => true);

   wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'MERCHANT_NAME',
                                   avalue   => l_merchant_name);

   -- set sender
   l_sender := JTF_UM_UTIL_PVT.value_specific(name => 'JTA_UM_SENDER',
                             responsibility_id => p_responsibility_id,
                             resp_appl_id      => p_application_id,
                             application_id => l_application_id,
                             site_level => true);

   --l_sender := nvl(l_sender, l_merchant_name);
   wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'SENDER',
                                   avalue   => l_sender);
   -- set name
   if p_requester_first_name is NULL and p_requester_last_name is NULL then
     wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUESTER_LAST_NAME',
                                   avalue   => p_requester_user_name);
/*
    wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'ENROLLMENTS',
                                   avalue   => p_requester_user_name);
*/
   end if;

end set_parameters;


/**
 * Procedure   :  set_parameters
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure sets all the parameters needed for the email / notifications.
 * Parameters  :
 * input parameters
 *   itemtype  - A valid item type from (WF_ITEM_TYPES table).
 *   itemkey   - A string generated from the application object's primary key.
 *   actid     - The function activity(instance id).
 *   funcmode  - Run/Cancel/Timeout
 * output parameters
 *   Resultout    - 'COMPLETE:T' if all parameters are set properly
 *                - 'COMPLETE:F' if parameters could not be set
 *
 * Errors      :
 * Other Comments :
 */

procedure set_parameters ( itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2) is
  l_requester_user_name         varchar2(1000);
  l_usertype_id                 number;
  l_responsibility_id           number;
  l_application_id              number;
  l_confirmation_id             number;
  l_requester_first_name        varchar2(1000);
  l_requester_last_name         varchar2(1000);
  x_return_status               varchar2(10);
begin

    if (funcmode = 'RUN') then
      --
      -- RUN mode - normal process execution
      --
         -- get user name
         l_requester_user_name := wf_engine.GetItemAttrText (
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUESTER_USER_NAME');

        -- get first and last name
        l_requester_first_name := wf_engine.GetItemAttrText (
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUESTER_FIRST_NAME');

        l_requester_last_name := wf_engine.GetItemAttrText (
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUESTER_LAST_NAME');

        -- get user type id
        l_usertype_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'REQUESTER_USERTYPE_ID');

        -- get responsibility id
        l_responsibility_id := wf_engine.GetItemAttrNumber (
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'RESPONSIBILITY_ID');

       -- get application id
       l_application_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'APPLICATION_ID');

       -- set values of other parameters
        set_parameters (
                 itemtype              => itemtype,
                 itemkey               => itemkey,
                 p_requester_user_name => l_requester_user_name,
                 p_usertype_id         => l_usertype_id,
                 p_responsibility_id   => l_responsibility_id,
                 p_application_id      => l_application_id,
                 p_requester_first_name=> l_requester_first_name,
                 p_requester_last_name => l_requester_last_name,
                 x_return_status       => x_return_status);


        --
        -- CANCEL mode
        --
        elsif (funcmode = 'CANCEL') then

          resultout := 'COMPLETE:';
          return;

        end if;
 exception
   when others then
     wf_core.context ('JTF_UM_PASSWORD_PVT', 'set_parameters ');
     raise;

end set_parameters;

/**
 * Procedure   :  is_first_time_user
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure returns 'T' if the user is a first time user
 * Parameters  :
 * input parameters
 *   itemtype  - A valid item type from (WF_ITEM_TYPES table).
 *   itemkey   - A string generated from the application object's primary key.
 *   actid     - The function activity(instance id).
 *   funcmode  - Run/Cancel/Timeout
 * output parameters
 *   Resultout    - 'COMPLETE:T' if the user is a first time user
 *                - 'COMPLETE:F' if the user is not a first time user
 *
 * Errors      :
 * Other Comments :
 */
procedure is_first_time_user (itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2) is
  l_result varchar2(10);
begin
    l_result := wf_engine.GetItemAttrText (
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'FIRST_TIME_USER');
    if l_result = 'N' then
      resultout := 'COMPLETE:F';
    else
      resultout := 'COMPLETE:T';
    end if;

    return;
exception
        when others then
                wf_core.context ('JTF_UM_SEND_PASSWORD_WF', 'is_first_time_user');
                raise;
end;


/**
 * Procedure   :  approval_required
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure returns whether or not an approval is required
 * Parameters  :
 * input parameters
 *   itemtype  - A valid item type from (WF_ITEM_TYPES table).
 *   itemkey   - A string generated from the application object's primary key.
 *   actid     - The function activity(instance id).
 *   funcmode  - Run/Cancel/Timeout
 * output parameters
 *   Resultout    - 'COMPLETE:T' if approval is required
 *                - 'COMPLETE:F' if approval is not required
 *
 * Errors      :
 * Other Comments :
 */
procedure is_approval_required (itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2) is
  l_result varchar2(10);
  l_requester_user_name varchar2(360);
  l_adhoc_role  varchar2(360);
  l_wf_roles  boolean ;


  CURSOR c_wf_adhoc_role(l_display_name in varchar2) IS
    select name
    from wf_roles
    where display_name = upper(l_display_name);
begin




    l_result := wf_engine.GetItemAttrText (
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'APPROVAL_REQUIRED');


    l_requester_user_name := wf_engine.GetItemAttrText (
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUESTER_USER_NAME');


    --bug 7524239  check to see if the user is active in  wf_roles
    l_wf_roles := wf_directory.IsPerformer(l_requester_user_name,
                                           l_requester_user_name);
    if not l_wf_roles  then
      Open c_wf_adhoc_role(l_requester_user_name);
      Fetch c_wf_adhoc_role into l_adhoc_role;
      if (c_wf_adhoc_role%NOTFOUND) then
           Close c_wf_adhoc_role;
      else
           Close c_wf_adhoc_role;
      end if;

      if l_adhoc_role is not null then
        if  l_result = 'T' then
         wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVAL_REQUIRED_USER_NAME',
                                    avalue   =>  l_adhoc_role);
        elsif  l_result = 'F' then
         wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'REQUESTER_USER_NAME',
                                    avalue   =>  l_adhoc_role);
        end if;
      end if;
    elsif  l_result = 'T' then
       wf_engine.SetItemAttrText (itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPROVAL_REQUIRED_USER_NAME',
                                  avalue   =>  l_requester_user_name);

    end if;

    if l_result = 'F' then
      resultout := 'COMPLETE:F';
    else
      resultout := 'COMPLETE:T';
    end if;

    return;
exception
        when others then
                wf_core.context ('JTF_UM_SEND_PASSWORD_WF', 'is_approval_required ');
                raise;
end;


/**
 * Procedure   :  user_verified
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure returns 'T' if a user is verified and a password can be sent to the user
 * Parameters  :
 * input parameters
 *   itemtype  - A valid item type from (WF_ITEM_TYPES table).
 *   itemkey   - A string generated from the application object's primary key.
 *   actid     - The function activity(instance id).
 *   funcmode  - Run/Cancel/Timeout
 * output parameters
 *   Resultout    - 'COMPLETE:T' if user is verified
 *                - 'COMPLETE:F' if user is not verified
 *
 * Errors      :
 * Other Comments :
 */
procedure is_user_verified (itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2) is
  l_result varchar2(10);
begin
    l_result := wf_engine.GetItemAttrText (
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'USER_VERIFIED');
    if l_result = 'Y' then
      resultout := 'COMPLETE:T';
    else
      resultout := 'COMPLETE:F';
    end if;

    return;
exception
        when others then
                wf_core.context ('JTF_UM_SEND_PASSWORD_WF', 'is_user_verified');
                raise;
end;


/**
 * Procedure   :  enrollment_only
 * Type        :  Public
 * Pre_reqs    :
 * Description : this procedure returns 'T' if only enrollment information should be sent to the user.
 * Parameters  :
 * input parameters
 *   itemtype  - A valid item type from (WF_ITEM_TYPES table).
 *   itemkey   - A string generated from the application object's primary key.
 *   actid     - The function activity(instance id).
 *   funcmode  - Run/Cancel/Timeout
 * output parameters
 *   Resultout    - 'COMPLETE:T' if user is verified
 *                - 'COMPLETE:F' if user is not verified
 *
 * Errors      :
 * Other Comments :
 */
procedure enrollment_only (itemtype  in  varchar2,
                          itemkey   in  varchar2,
                          actid     in  number,
                          funcmode  in  varchar2,
                          resultout out NOCOPY varchar2) is
  l_result varchar2(10);
begin
    l_result := wf_engine.GetItemAttrText (
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'ENROLLMENT_ONLY');
    if l_result = 'Y' then
      resultout := 'COMPLETE:T';
    else
      resultout := 'COMPLETE:F';
    end if;

    return;
exception
        when others then
                wf_core.context ('JTF_UM_SEND_PASSWORD_WF', 'enrollment_only');
                raise;

end enrollment_only;


/*
procedure write_debug_log(debug_msg varchar2) is
  PRAGMA AUTONOMOUS_TRANSACTION;
begin
    insert into test_temp
    values
      (debug_msg)
     ;
  COMMIT;
end write_debug_log;
*/

/**
 * Procedure   :  reset_password
 * Type        :  Private
 * Pre_reqs    :
 * Description : this procedure resets the password and sends an email to the user.
 *               Also, it inserts a user into wf_local_user if a valid username
 *               and email combination does not
already exist in wf_user.
 * Parameters  : None
 * input parameters
 *     param  requester_user_name
 *     param  requester_email
 *  (*) required fields
 * output parameters
 *     param  x_return_status
 *     param  x_msg_data
 *     param  x_msg_count
  * Errors      : Expected Errors
 *               requester_user_name and email is null
 *               requester_user_name is not a valid user
 *               requester_email does not correspond to a valid user
 * Other Comments :
 * FND_USER update : The update of fnd_user table is done using fnd_user_pkg
 *                   procedure as recommended by fnd (bug 1713101)
 * DEFAULTING LOGIC
 * If only the user name is passed then the email is defaulted using the following logic
 *  1. Email address from fnd_users where user_name = p_requester_user_name
 *  2. Email from per_all_people_F where person_id = employee_id
 *     (retrieved from fnd_users using the user_name)
 *  3. Email from hz_contact_points where owner_type_id = party_id and
 *     owner_table = 'HZ_PARTIES' and contact_point_type = 'EMAIL'.
 *  Party_id here is obtained from the customer id stored in fnd_user
 *  where user_name = p_requester_user_name.
 *  In all the above cases the user, employee, party etc. have to be valid.
 *
 * If only the email address is specified, the user name is determined using a similar logic
 * 1. User_name from fnd_user where email_address = p_requester_email_Address
 * 2. User_name from fnd_user where employee_id = person_id (retrieved from per_all_people_f
 *    using the email_address)
 * 3. User_name from fnd_user where customer_id = hz_contact_points.owner_type_id and
 *    owner_table = 'HZ_PARTIES' and contact_point_type = 'EMAIL' and
 *    contact_point = p_requester_email_Address
 *
 * If both email and user name are passed, the combination is validated using the above logic.
 */


procedure reset_password(p_api_version_number  in number,
                 p_init_msg_list               in varchar2 := FND_API.G_FALSE,
                 p_commit                      in varchar2 := FND_API.G_FALSE,
                 p_validation_level            in number   := FND_API.G_VALID_LEVEL_FULL,
                 p_requester_user_name         in varchar2 := null,
                 p_requester_email             in varchar2 := null,
                 p_application_id              in number   := null,
                 p_responsibility_id           in number   := null,
                 x_return_status             out NOCOPY varchar2,
                 x_msg_count                 out NOCOPY number,
                 x_msg_data                  out NOCOPY varchar2
                 ) is

  l_api_version_number  NUMBER := 1.0;
  l_api_name            VARCHAR2(50) := 'RESET_PASSWORD';
  l_email               varchar2(240);
  l_requester_user_name varchar2(240) := UPPER(p_requester_user_name);
  l_requester_email     varchar2(240) := p_requester_email;
  l_responsibility_id   number := p_responsibility_id;
  l_application_id      number := p_application_id;
  l_wf_user_name        varchar2(240);
  l_password            varchar2(240);
  l_result varchar2(10);
  v_counter BINARY_INTEGER := 1;

begin

    -- Write to debug log
    if l_is_debug_parameter_on then
    JTF_DEBUG_PUB.log_debug(2, G_MODULE, 'Entering API reset_Password ...');
    end if;
    --

    -- Standard Start of API savepoint
    SAVEPOINT reset_password;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    -- Validate required fields for not null values

        if (p_requester_user_name is null and p_requester_email is null) then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('JTF', 'JTA_UM_USER_OR_EMAIL');
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        end if;

     -- validate / default username/email

      --write_debug_log('before calling get_wf_user');

      JTF_UM_UTIL_PVT.get_wf_user(p_api_version_number  => 1.0,
                 x_requester_user_name    => l_requester_user_name,
                 x_requester_email        => l_requester_email   ,
                 x_wf_user                => l_wf_user_name,
                 x_return_status          => x_return_Status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_Data );

      if x_return_status = FND_API.G_RET_STS_ERROR then
        RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      -- if wf_user is NULL then we need to create an adhoc user
      -- create adhoc user
      if l_wf_user_name is NULL then
        l_wf_user_name := 'JTFUM-'|| l_requester_user_name;
        JTF_UM_UTIL_PVT.GetAdHocUser (p_api_version_number => 1.0,
                    p_username           => l_wf_user_name,
                    p_display_name       => l_requester_user_name,
                    p_email_address      => l_requester_email,
                    x_return_status      => x_return_status,
                    x_msg_data           => x_msg_data,
                    x_msg_count          => x_msg_count);
        if x_return_status <> FND_API.G_RET_STS_SUCCESS then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
      end if;


      -- generate password
      generate_password (p_api_version_number => 1.0,
                 x_password                  => l_password,
                 x_return_status             => x_return_status,
                 x_msg_count                 => x_msg_count,
                 x_msg_data                  => x_msg_data
                 );



      -- loop till password clears the validations
      l_result := FND_WEB_SEC.validate_password( l_requester_user_name, l_password );
      WHILE (( l_result <> 'Y') AND ( v_counter <=100) ) LOOP

        -- incrementing the counter
        v_counter := v_counter + 1;
        -- generate password
        generate_password (p_api_version_number => 1.0,
                   x_password                  => l_password,
                   x_return_status             => x_return_status,
                   x_msg_count                 => x_msg_count,
                   x_msg_data                  => x_msg_data
                   );

        l_result := FND_WEB_SEC.validate_password( l_requester_user_name, l_password );
        IF ( v_counter = 100 ) THEN
           IF ( l_result <> 'Y' ) THEN
              -- Throw exception as even though generated password 100 times, but
              -- cannot pass validation criteria
              raise_application_error (-20000, 'Could not generated password automatically which satisfies validation requirements.');
           END IF;
        END IF;
      END LOOP;
      -- end of code for validating username


      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

       if not fnd_user_pkg.changePassword(username =>  l_requester_user_name,
                                         newpassword => l_password) then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      -- update the password date to null to force user to change psswd upon
      -- first login
      fnd_user_pkg.UpdateUser (
           x_user_name  => l_requester_user_name,
           x_owner      => 'CUST',
           x_unencrypted_password => l_password,
           x_password_date        => null);



     -- update the password date to null. this will force the user to change
     -- password upon first logon
     -- not needed now as FND API allows setting the password date to null
     /*
      --begin
        update fnd_user set
        password_date = null
        where user_name = l_requester_user_name;
     */
     /* exception
        when others
          raise;
      end;*/

     --write_debug_log('before call to send_password');
      -- initiate the workflow to send the password
        send_password(p_api_version_number  => 1.0,
                 p_requester_user_name      => l_requester_user_name,
                 p_requester_password       => l_password,
                 p_responsibility_id        => l_responsibility_id,
                 p_application_id           => l_application_id,
                 p_wf_user_name             => l_wf_user_name,
                 p_first_time_user          => 'N',
                 p_user_verified            => 'Y',
                 x_return_status            => x_return_status,
                 x_msg_count                => x_msg_count,
                 x_msg_data                 => x_msg_data
                 );
      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
    --
    -- End of API body
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);

        -- Write to debug log
         if l_is_debug_parameter_on then
         JTF_DEBUG_PUB.log_debug(2, G_MODULE, 'Exiting API reset_Password ...');
         end if;
        --

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

       WHEN OTHERS THEN
	  JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => JTF_DEBUG_PUB.G_EXC_OTHERS
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);
end reset_password;

Procedure enrollment_info(document_id    in varchar2,
                          display_type   in varchar2,
                          document       in out NOCOPY varchar2,
                          document_type  in out NOCOPY varchar2) is

  Cursor c_enrollment(p_subscr_reg_id in number) is
  select svl.subscription_name||decode(reg.status_code,'PENDING', '(*)') name
  from jtf_um_subscriptions_vl svl, jtf_um_subscription_reg reg
  where svl.subscription_id = reg.subscription_id
  and   reg.subscription_reg_id = p_subscr_reg_id
  and  status_code in ('APPROVED', 'PENDING')
  and NVL(reg.EFFECTIVE_END_DATE, SYSDATE + 1) > SYSDATE;


  l_document_id varchar2(4000) := document_id;
  pos           integer;
  type id_table is table of integer index by binary_integer;
  id            id_table;

  enroll_count  integer := 0;

begin

  -- document id is a list of subscr reg id separated by :
  if l_document_id is not NULL then
      pos := instr(l_document_id,':',1);
      while pos > 0 loop
       id(nvl(id.LAST,0) + 1) := to_number(substr(l_document_id, 1, pos-1));
       l_document_id := substr(l_document_id, pos+1);
       pos := instr(l_document_id,':',1);
      end loop;
      id(nvl(id.LAST,0) + 1) := l_document_id;


 --     document := 'document id is '||document_id ||'display type is ' || display_type|| JTF_DBSTRING_UTILS.getLineFeed;

  document := FND_MESSAGE.get_string('JTF', 'JTA_UM_ENROLL_HEADER')||NEWLINE||NEWLINE;


     for j in 1..id.count loop
       for i in c_enrollment(id(j)) loop
         document := document ||i.name ||NEWLINE;
         enroll_count := enroll_count + 1;
      end loop;
    end loop;

   document := document||NEWLINE||FND_MESSAGE.get_string('JTF', 'JTA_UM_ENROLL_FOOTER');

 -- if there are no approved or pending enrollments then do not have the doc info
  if enroll_count = 0 then
    document := null;
  end if;

  document_type := 'text/plain';
  end if;
end;


End JTF_UM_PASSWORD_PVT;

/
