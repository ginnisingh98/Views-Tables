--------------------------------------------------------
--  DDL for Package Body UMX_LOGIN_HELP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_LOGIN_HELP_PVT" AS
/* $Header: UMXLHLPB.pls 120.6.12010000.14 2016/01/11 04:59:23 avelu ship $ */
  procedure decrementAttemptCounter(
                                p_itemkey               in varchar2,
                                x_no_attempts           out NOCOPY varchar2);

/*
Things to do
1) Check if fnd_sso_manager.get_login_url needs to accept parameters such as lang-code

*/
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

  g_itemtype wf_item_types.name%type := 'UMXLHELP';

  g_def_no_max_request pls_integer := 5;


function GetDisplayName(username in varchar2) return varchar2 is
  cursor C_party_id is
   SELECT person_party_id
   FROM fnd_user
   where user_name = username;

  x_return_status           varchar2(40);
  x_msg_count			    NUMBER;
  x_msg_data	            VARCHAR2(4000);
  x_formatted_name		    VARCHAR2(4000);
  x_formatted_lines_cnt	    NUMBER;
  x_formatted_name_tbl      hz_format_pub.string_tbl_type;
  l_party_id number;
begin
  for i in C_party_id loop
    l_party_id := i.person_party_id;
  end loop;

  if l_party_id is null then
    return username;
  else
   Hz_format_pub.format_name (
  p_party_id	=> l_party_id,
  x_return_status	=>  x_return_status,
  x_msg_count	=> x_msg_count,
  x_msg_data	=> x_msg_data,
  x_formatted_name => x_formatted_name,
  x_formatted_lines_cnt	=> x_formatted_lines_cnt,
  x_formatted_name_tbl	=> x_formatted_name_tbl	);

      return x_formatted_name;
  end if;
end getDisplayName;


  -------------------------------------------------------------------
  -- Name:        CreateRole
  -- Description: Creates an adhoc role with notification preference always set
  --              to 'MAIL'. This would ensure that the user would get an email
  --              for all password related notifications. The name of the role
  --              is set to FND-username
  -------------------------------------------------------------------
  Procedure CreateRole(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout in out NOCOPY varchar2) is

    l_role_name                wf_local_roles.name%type;
    l_notification_preference  wf_local_roles.notification_preference%type;
    l_username  fnd_user.user_name%type;
    l_display_name varchar2(4000);
  begin

    if (funcmode = 'RUN') then

      l_role_name := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'X_USER_ROLE');

      l_notification_preference := WF_ENGINE.GetItemAttrText (itemtype, itemkey, 'NOTIFICATION_PREFERENCE');

      if (l_role_name is NULL) or (l_notification_preference not like 'MAIL%') then
        -- No role with the user_name, create an ad hoc role.
        l_username := upper(WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'USER_NAME'));

        l_role_name := 'FNDPWD_' || itemkey || '_' || l_username;
        l_display_name := getDisplayName(l_username);

        WF_DIRECTORY.CreateAdHocRole (
            role_name         => l_role_name,
            role_display_name => l_display_name,
            email_address     => WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'EMAIL_ADDRESS'));

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'X_USER_ROLE',
                                   avalue   => l_role_name);

      end if;

    end if;

    resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;

  exception
    when others then
      Wf_Core.Context('UMX_LOGIN_HELP_PVT', 'CreateRole', itemtype, itemkey,
                      actid);
      raise;
  end CreateRole;

  Function getCurrNoActiveReqs( username IN varchar2 ) return pls_integer is
    l_no                pls_integer := 0;
    l_item_key          wf_items.item_key%type;
    l_user_name         fnd_user.user_name%type := username;
  Begin
    select count(*) into l_no from
    (
       SELECT WorkflowItemEO.ITEM_TYPE,
            WorkflowItemEO.ITEM_KEY,
            wf_fwkmon.getitemstatus(WorkflowItemEO.ITEM_TYPE, WorkflowItemEO.ITEM_KEY, WorkflowItemEO.END_DATE,
            WorkflowItemEO.ROOT_ACTIVITY, WorkflowItemEO.ROOT_ACTIVITY_VERSION)  STATUS_CODE
        FROM    WF_ITEMS WorkflowItemEO,
            WF_ITEM_TYPES_VL WorkflowItemTypeEO,
            WF_ACTIVITIES_VL ActivityEO,
            WF_ITEM_ATTRIBUTE_VALUES attrib
        WHERE WorkflowItemEO.ITEM_TYPE = WorkflowItemTypeEO.NAME
            AND  ActivityEO.ITEM_TYPE = WorkflowItemEO.ITEM_TYPE
            AND  ActivityEO.NAME = WorkflowItemEO.ROOT_ACTIVITY
            AND  ActivityEO.VERSION = WorkflowItemEO.ROOT_ACTIVITY_VERSION
            AND attrib.item_type = WorkflowItemEO.ITEM_TYPE
            AND attrib.item_key =  WorkflowItemEO.ITEM_KEY
            AND attrib.name = 'USER_NAME'
            AND attrib.text_value = l_user_name
    ) QRSLT
    where
        item_type = 'UMXLHELP'
        AND status_code = 'ACTIVE';

    return l_no;
  END getCurrNoActiveReqs;


  Function getMaxNoActiveReqs return pls_integer is
    l_no                pls_integer := 0;
    l_max_no            varchar2(4000) := null;
    cursor MaxNoRequest is SELECT attr.text_value into l_max_no
    From WF_ITEMS item, WF_ITEM_ATTRIBUTE_VALUES attr
    Where
        item.item_type = attr.item_type
        And
        item.item_key = attr.item_key
        And
        item.item_type = g_itemtype
        And
        attr.name = 'MAX_NO_PERSISTENT_REQ'
        AND
        rownum <= 1;
  Begin

    open MaxNoRequest;
    fetch MaxNoRequest into l_max_no;
    if (MaxNoRequest%NOTFOUND) then
      l_no := g_def_no_max_request;
    end if;
    close MaxNoRequest;

    if ( l_max_no is not null and length(l_max_no) > 0 ) then
        l_no := to_number( l_max_no );
    else
        l_no := g_def_no_max_request;
    end if;

    return l_no;

  exception
    when others then
        l_no := g_def_no_max_request;
        return l_no;
  END getMaxNoActiveReqs;



  -- Private function to get the email address of the active user from
  -- 1) WF local roles
  -- 2) FND User
  -- 3) The first TCA party
  procedure Get_email_address (p_user_name               in fnd_user.user_name%type,
                               x_role_name               out nocopy varchar2,
                               x_email_address           out nocopy varchar2,
                               x_notification_preference out nocopy varchar2,
                               x_message_name            out nocopy varchar2) is

    -- TCA Party declares email address as varchar2 2000, largest amount the
    -- three schema.
    l_role_display_name        wf_local_roles.display_name%type;
    l_language                 wf_local_roles.language%type;
    l_territory                wf_local_roles.territory%type;

    cursor get_fnd_email (p_user_name in fnd_user.user_name%type) is
      SELECT email_address
      FROM fnd_user
      WHERE user_name = p_user_name
      AND start_date <= sysdate
      AND nvl(end_date, sysdate + 1) > sysdate;

    cursor get_tca_email (p_user_name in fnd_user.user_name%type) is
      SELECT hzp.email_address
      FROM hz_parties hzp, fnd_user fu
      WHERE hzp.party_id = fu.person_party_id
      AND fu.user_name = p_user_name;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.get_email_address.begin',
                      'p_user_name: ' || p_user_name);
    end if;

    -- First get the email from wf directory
    WF_DIRECTORY.GetRoleInfo (p_user_name, l_role_display_name, x_email_address,
                              x_notification_preference, l_language, l_territory);

    if x_email_address is not null then
      x_role_name := p_user_name;
    else
      -- Try to get the email from fnd_user
      open get_fnd_email (p_user_name);
      fetch get_fnd_email into x_email_address;
      if (get_fnd_email%NOTFOUND) then
        x_message_name := 'UMX_LOGIN_HELP_PWD_MSG';
		if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
                  FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                  'fnd.plsql.UMXVUPWB.get_email_address',
                  'UMX_LOGIN_HELP_INVALID_ACCT');
        end if;
        --fnd_message.set_name('FND', x_message_name);
        --x_message_data := fnd_message.get;
      else
        if x_email_address is null then
          -- if email is still null then get it from tca
          -- check if there is a valid party email
          for party in get_tca_email (p_user_name) loop
            x_email_address := party.email_address;
            exit when x_email_address is not null;
          end loop;
        end if;
      end if;
      close get_fnd_email;
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.get_email_address.end',
                      'x_role_name: ' || x_role_name ||
                      ' | x_email_address: ' || x_email_address ||
                      ' | x_message_name: ' || x_message_name);
    end if;

  end get_email_address;


  procedure Find_user_w_email (p_email                   in fnd_user.email_address%type,
                               x_role_name               out nocopy varchar2,
                               x_user_name               out nocopy varchar2,
                               x_notification_preference out nocopy varchar2,
                               x_message_name            out nocopy varchar2) is

    -- TCA Party declares email address as varchar2 2000, largest amount the
    -- three schema.
    l_role_display_name        wf_local_roles.display_name%type;
    l_language                 wf_local_roles.language%type;
    l_territory                wf_local_roles.territory%type;
    l_email_address            fnd_user.email_address%type;

    cursor get_user_fnd(p_email_address in fnd_user.email_address%type) is
        SELECT user_name FROM fnd_user
        WHERE email_address = p_email_address
        AND start_date <= sysdate AND nvl(end_date, sysdate + 1) > sysdate;


    cursor get_user_hz (p_email_address in fnd_user.user_name%type) is
        SELECT fu.user_name
        FROM hz_parties p, fnd_user fu
        WHERE p.party_id = fu.person_party_id
        AND p.email_address = p_email_address
      	AND fu.start_date <= sysdate AND nvl(fu.end_date, sysdate + 1) > sysdate;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.find_user_w_email.begin',
                      'p_email: ' || p_email);
    end if;

    -- First get the email from wf directory
    /*
    WF_DIRECTORY.GetRoleInfo (p_user_name, l_role_display_name, x_email_address,
                              x_notification_preference, l_language, l_territory);
    */

      -- Try to get the email from fnd_user
      open get_user_fnd (p_email);
      fetch get_user_fnd into x_user_name;
      if (get_user_fnd%NOTFOUND) then
        --x_message_name := 'UMX_FORGOT_PWD_INVALID_ACCT';
        --fnd_message.set_name('FND', x_message_name);
        --x_message_data := fnd_message.get;
      --else
        --if x_user_name is null then
          -- if email is still null then get it from tca
          -- check if there is a valid party email
          for party in get_user_hz(p_email) loop
            x_user_name := party.user_name;
            exit when x_user_name is not null;
          end loop;
        --end if;
      end if;
      close get_user_fnd;

    if (x_user_name is not null ) then
        WF_DIRECTORY.GetRoleInfo (x_user_name, l_role_display_name, l_email_address,
                              x_notification_preference, l_language, l_territory);
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.find_user_w_email.end',
                      'x_role_name: ' || x_role_name ||
                      ' | x_user_name: ' || x_user_name ||
                      ' | x_message_name: ' || x_message_name);
    end if;

  end find_user_w_email;

  procedure Find_users_w_email( p_email                   in fnd_user.email_address%type,
                                x_users                   out NOCOPY UsersWEmail ) is

    -- TCA Party declares email address as varchar2 2000, largest amount the
    -- three schema.
    l_role_display_name        wf_local_roles.display_name%type;
    l_language                 wf_local_roles.language%type;
    l_territory                wf_local_roles.territory%type;
    l_email_address            fnd_user.email_address%type;
    l_user_name                fnd_user.user_name%type;
    l_notification_preference  wf_local_roles.notification_preference%type;
    i                          pls_integer := 0;

    cursor get_user_fnd(p_email_address in fnd_user.email_address%type) is
        SELECT user_name FROM fnd_user
        WHERE UPPER(email_address) = UPPER(p_email_address)
        AND start_date <= sysdate AND nvl(end_date, sysdate + 1) > sysdate;


    cursor get_user_hz (p_email_address in fnd_user.user_name%type) is
        SELECT fu.user_name
        FROM hz_parties p, fnd_user fu
        WHERE p.party_id = fu.person_party_id
        AND UPPER(p.email_address) = UPPER(p_email_address)
        AND fu.start_date <= sysdate AND nvl(fu.end_date, sysdate + 1) > sysdate;


  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.find_users_w_email.begin',
                      'p_email: ' || p_email);
    end if;

    -- Try to get the email from fnd_user
    --open get_user_fnd (p_email);
    --fetch get_user_fnd into l_user_name;
    for aUser in get_user_fnd(p_email) loop
        WF_DIRECTORY.GetRoleInfo ( aUser.user_name, l_role_display_name, l_email_address,
                                   l_notification_preference, l_language, l_territory);
        x_users(i).user_name := aUser.user_name;
        x_users(i).notification_preference := l_notification_preference;
        i := i + 1;
    end loop;

    if ( i = 0 ) then
        for party in get_user_hz(p_email) loop
            l_user_name := party.user_name;
            WF_DIRECTORY.GetRoleInfo (l_user_name, l_role_display_name, l_email_address,
                                  l_notification_preference, l_language, l_territory);
            x_users(i).user_name := party.user_name;
            x_users(i).notification_preference := l_notification_preference;
            i := i + 1;
        end loop;
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.find_users_w_email.end',
                      ' | l_user_name: ' || l_user_name );
    end if;

  end find_users_w_email;




  procedure Start_workflow( p_request_type            in varchar2,
                            p_user_name               in varchar2,
                            p_email_address           in varchar2,
							p_parent_item_key	      in varchar2,
                            p_role_name               in varchar2,
							p_orig_page               in varchar2,
                            p_notification_preference in varchar2,
                            x_itemkey                 out nocopy varchar2) is
	timeout varchar2(50);
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.start_workflow.begin',
                      'p_user_name: ' || p_user_name ||
                      ' | p_email_address: ' || p_email_address ||
                      ' | p_role_name: ' || p_role_name );
    end if;

    select to_char (UMX_LOGIN_HELP_WF_S.Nextval) into x_itemkey from dual;

    -- start the workflow that will send the notification and reset
    -- the password

    wf_engine.CreateProcess(itemtype => g_itemtype,
                            itemkey  => x_itemkey,
                            process  => 'LOGIN_HELP');

    wf_engine.SetItemAttrText(itemtype => g_itemtype,
                              itemkey  => x_itemkey,
                              aname    => 'REQUEST_TYPE',
                              avalue   => p_request_type);

    if ( p_user_name is not null ) then
        wf_engine.SetItemAttrText(itemtype => g_itemtype,
                              itemkey  => x_itemkey,
                              aname    => 'USER_NAME',
                              avalue   => p_user_name);
    end if;

    if p_email_address is not null then
        wf_engine.SetItemAttrText (itemtype => g_itemtype,
                                 itemkey  => x_itemkey,
                                 aname    => 'EMAIL_ADDRESS',
                                 avalue   => p_email_address);
    end if;

    if p_role_name is not null then
      wf_engine.SetItemAttrText (itemtype => g_itemtype,
                                 itemkey  => x_itemkey,
                                 aname    => 'X_USER_ROLE',
                                 avalue   => p_role_name);
    end if;

	if p_orig_page is not null then
      wf_engine.SetItemAttrText (itemtype => g_itemtype,
                                 itemkey  => x_itemkey,


                                 aname    => 'ORIG_PAGE',
                                 avalue   => p_orig_page);
    end if;

    if p_notification_preference is not null then
      wf_engine.SetItemAttrText (itemtype => g_itemtype,
                                 itemkey  => x_itemkey,
                                 aname    => 'NOTIFICATION_PREFERENCE',
                                 avalue   => p_notification_preference);
    end if;

    if p_parent_item_key is not null then
      wf_engine.SetItemAttrText (itemtype => g_itemtype,
                                 itemkey  => x_itemkey,
                                 aname    => 'PARENT_ITEM_KEY',
                                 avalue   => p_parent_item_key);
    end if;

		timeout :=	fnd_profile.value('UMX_PWD_RESET_TIMEOUT');

   if timeout is not null then
      wf_engine.SetItemAttrText (itemtype => g_itemtype,
                                 itemkey  => x_itemkey,
                                 aname    => 'TIMEOUT',
                                 avalue   => timeout);
    end if;


    wf_engine.StartProcess(itemtype => g_itemtype,
                           itemkey  => x_itemkey);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.start_workflow.end',
                      'x_itemkey: ' || x_itemkey);
    end if;

  end start_workflow;


  procedure ForgottenPwdPvt
                        (p_username              in fnd_user.user_name%type,
						 p_parent_item_key       in varchar2,
						 p_orig_page             in varchar2,
                         x_return_status         out NOCOPY varchar2,
                         x_message_name          out NOCOPY varchar2) is

    l_user_name                fnd_user.user_name%type := upper(p_username);
    l_email_address            varchar2(2000);
    l_role_name                wf_local_roles.name%type;
    l_password                 varchar2(40);
    l_notification_preference  wf_local_roles.notification_preference%type;
    l_result                   wf_item_activity_statuses.activity_result_code%type;
    l_status                   wf_item_activity_statuses.activity_status%type;
    l_itemkey                  wf_items.item_key%type;
    l_pwdChangeable            boolean := null;
    l_nonExistentUser          boolean := false;
    l_max_req                  pls_integer := getMaxNoActiveReqs();
    l_too_many_prev_reqs       boolean := false;


  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ForgottenPwdPvt.begin',
                      'p_username: ' || p_username );
    end if;

    -- initialize the return status
    x_return_status := FND_API.G_RET_STS_ERROR;


    if ( getCurrNoActiveReqs(l_user_name) >= l_max_req ) then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_message_name := 'UMX_LOGIN_HELP_2_MANY_REQS';
        return;
    end if;
    -- validate required fields
    -- validate user name
    if FND_SSO_Manager.isPasswordChangeable (l_user_name) THEN
        get_email_address (l_user_name, l_role_name, l_email_address,
                           l_notification_preference, x_message_name);
        if (x_message_name is null) then
          if (l_email_address is not null) then
            -- Start Workflow to reset user's password.
            start_workflow ( 'P', l_user_name, l_email_address, p_parent_item_key, l_role_name,p_orig_page,
                            l_notification_preference, l_itemkey);
            -- Check if the workflow is in error status
            wf_engine.itemstatus (g_itemtype, l_itemkey, l_status, l_result);
            if (l_status = 'ERROR') then
              -- Error status
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_message_name := 'UMX_LOGIN_HELP_UNEXP_ERROR';
            else
              -- Not error, return notified message.
              x_return_status := FND_API.G_RET_STS_SUCCESS;
              x_message_name  := 'UMX_LOGIN_HELP_PWD_MSG';
            end if;
          else -- email address is null
              if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
                FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ResetPwdPvt', 'UMX_LOGIN_HELP_NULL_EMAIL');
              end if;
              x_message_name := 'UMX_LOGIN_HELP_PWD_MSG';
          end if;
        end if;
    else -- cannot change password for this user
	    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
                FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ResetPwdPvt', 'UMX_LOGIN_HELP_PWD_EXTERNAL');
		end if;
        x_message_name := 'UMX_LOGIN_HELP_PWD_MSG';
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ResetPwdPvt.end',
                      'x_return_status: ' || x_return_status ||
                      ' | x_message_name: ' || x_message_name);
    end if;
  EXCEPTION
      when FND_SSO_MANAGER.userNotFound then
        --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --x_message_name := 'UMX_FORGOT_PWD_UNEXP_ERR_MSG';
		if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
                FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ResetPwdPvt', 'UMX_LOGIN_HELP_INVALID_ACCT');
		end if;
        x_message_name := 'UMX_LOGIN_HELP_PWD_MSG';

  END ForgottenPwdPvt;


  procedure ForgottenPwd(p_username        in fnd_user.user_name%type,
											p_parent_item_key    in varchar2,
					  p_orig_page					 in varchar2,
                      x_return_status      out NOCOPY varchar2,
                      x_message_name       out NOCOPY varchar2) is
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ForgottenPwdPvt.begin',
                      'p_username: ' || p_username
                      );
    end if;

    ForgottenPwdPvt
                (p_username              => p_username,
								 p_parent_item_key       => p_parent_item_key,
				 p_orig_page						 => p_orig_page,
                 x_return_status         => x_return_status,
                 x_message_name          => x_message_name);


    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ForgottenPwdPvt.end',
                      'x_return_status: ' || x_return_status ||
                      ' | x_message_name: ' || x_message_name);
    end if;

  end ForgottenPwd;





  procedure ForgottenUnamePvt
                        (p_email                 in fnd_user.email_address%type,
						 p_orig_page						in varchar2,
                         x_return_status         out NOCOPY varchar2,
                         x_message_name          out NOCOPY varchar2) is

    l_email_address            varchar2(2000) := p_email;
    l_role_name                wf_local_roles.name%type;
    l_notification_preference  wf_local_roles.notification_preference%type;
    l_result                   wf_item_activity_statuses.activity_result_code%type;
    l_status                   wf_item_activity_statuses.activity_status%type;
    l_itemkey                  wf_items.item_key%type;
    l_user_name                fnd_user.user_name%type;
    l_user_list                UsersWEmail;
    i                          pls_integer;
    l_first                    pls_integer;
    e                          pls_integer := 0;
    l_max_req                  pls_integer := g_def_no_max_request;
    l_too_many_prev_reqs       boolean := false;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ForgottenUnamePvt.begin',
                      'p_email: ' || p_email );
    end if;

    -- initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_message_name  := 'UMX_LOGIN_HELP_UNAME_MSG';

    find_users_w_email( l_email_address, l_user_list );

    i := l_user_list.first();
    l_first := i;
    if ( i is null ) then
        x_return_status := FND_API.G_RET_STS_ERROR;
		if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
                 FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ForgottenUnamePvt.begin',
                      'UMX_LOGIN_HELP_NO_USER_FOUND' );
        end if;
        x_message_name := 'UMX_LOGIN_HELP_UNAME_MSG';
    else
      WHILE ( i is not null and x_return_status = FND_API.G_RET_STS_SUCCESS ) LOOP
        l_user_name := l_user_list(i).user_name;
        l_notification_preference := l_user_list(i).notification_preference;
        -- Bug13583453 To avoid creating new Ad-Hoc role
        l_role_name := l_user_name;

        if ( i = l_first ) then
            l_max_req := getMaxNoActiveReqs();
            if ( getCurrNoActiveReqs(l_user_name) < l_max_req ) then
                l_too_many_prev_reqs := false;
            else
                l_too_many_prev_reqs := true;
            end if;
        end if;

        if ( not l_too_many_prev_reqs ) then
            -- Start Workflow to reset user's password.
            start_workflow ( 'U', l_user_name, l_email_address, null, l_role_name,p_orig_page,
                            l_notification_preference, l_itemkey);
            -- Check if the workflow is in error status

            wf_engine.itemstatus (g_itemtype, l_itemkey, l_status, l_result);
            if (l_status = 'ERROR') then
              -- Error status
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_message_name := 'UMX_RESET_PWD2_UNEXP_ERROR';
                return;
            end if;
        else
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_message_name := 'UMX_LOGIN_HELP_2_MANY_REQS';
            return;
        end if;

        i := l_user_list.NEXT( i );
      END LOOP; --End of UserList Loop
    END IF;


    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXLHLPB.ForgottenUnamePvt.end',
                      'x_return_status: ' || x_return_status ||
                      ' | x_message_name: ' || x_message_name);
    end if;
  EXCEPTION
      when others then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_message_name := 'UMX_RESET_PWD2_UNEXP_ERROR';

  END ForgottenUnamePvt;


  procedure ForgottenUname
                     (p_email              in fnd_user.email_address%type,
					  p_orig_page					 in varchar2,
                      x_return_status      out NOCOPY varchar2,
                      x_message_name       out NOCOPY varchar2) is
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ForgottenUname.begin',
                      'p_email: ' || p_email
                      );
    end if;

    ForgottenUnamePvt
                (p_email                 => p_email,
				 p_orig_page				     => p_orig_page,
                 x_return_status         => x_return_status,
                 x_message_name          => x_message_name);


    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ForgottenPwdPvt.end',
                      'x_return_status: ' || x_return_status ||
                      ' | x_message_name: ' || x_message_name);
    end if;

  end ForgottenUname;


  function GenerateAuthKey return varchar2 is

    l_password_len int := 20;
    x_auth_key     varchar2(400);
    ascii_offset   int := 65;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.GenerateAuthKey.begin', '');
    end if;


    for j in 1..l_password_len loop
      if (mod(abs(dbms_random.random),2) = 1) then
        -- generate number
        x_auth_key := x_auth_key || mod(abs(FND_CRYPTO.SmallRandomNumber),10);
      else
        -- generate character
        x_auth_key := x_auth_key || fnd_global.local_chr(mod(abs(FND_CRYPTO.SmallRandomNumber),26)
            + ascii_offset);
      end if;
    end loop;

    -- terminate the random number generator
    --dbms_random.terminate;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.GenerateAuthKey.end',
                      'x_auth_key: ' || x_auth_key);
    end if;

    return x_auth_key;

  end GenerateAuthKey;


  Procedure GenAuthKey(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2) is

    l_auth_key varchar2(400);
    l_user_name fnd_user.user_name%type;

  begin
    if (funcmode = 'RUN') then
      -- Check if the password is already set.
      /*
      l_auth_key := WF_ENGINE.GetActivityAttrText (
          itemtype => itemtype,
          itemkey  => itemkey,
          actid    => actid,
          aname    => 'AUTH_KEY');
      */

      l_auth_key := GenerateAuthKey();
      if (l_auth_key is not null) then
        -- code for validating the generated username
        -- get the username
        /*
            l_user_name := WF_ENGINE.GetActivityAttrText(
            itemtype => itemtype,
            itemkey  => itemkey,
            actid    => actid,
            aname    => 'USER_NAME');
        */

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AUTH_KEY',
                                   avalue   => l_auth_key);

      end if;
    end if;

    resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;

  exception
    when others then
      Wf_Core.Context('UMX_LOGIN_HELP_PVT', 'GenAuthKey', itemtype, itemkey, actid);
      raise;
  end;


  Procedure GenUrl2ResetPwdPg(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2) is
    l_auth_key  varchar2(400);
    l_param     varchar2(32000);
    l_url       varchar2(32000) := 'http://yahoo.com';
    l_user_name fnd_user.user_name%type;
	l_orig_page varchar2(32000);

    l_link_name varchar2(400) := 'Click here';


  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.GenUrl2ResetPwdPg.begin', '');
    end if;

    if (funcmode = 'RUN') then
      -- Check if the password is already set.


        l_auth_key := WF_ENGINE.GetItemAttrText (
          itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'AUTH_KEY');


        l_user_name := WF_ENGINE.GetItemAttrText(
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'USER_NAME');

		l_orig_page := WF_ENGINE.GetItemAttrText(
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'ORIG_PAGE');
        l_param := '&AUTH_KEY=' || l_auth_key || '&ITEM_KEY=' || itemkey;

		if l_orig_page is not null then
		   		l_param := l_param || '&UmxOriginatingPage=' || l_orig_page;
		end if;
        /*
            function get_run_function_url ( p_function_name in varchar2,
                                p_resp_appl in varchar2,
                                p_resp_key in varchar2,
                                p_security_group_key in varchar2,
                                p_parameters in varchar2 default null,
                                p_override_agent in varchar2 default null )
        */
        l_url := FND_RUN_FUNCTION.get_run_function_url(
                p_function_name => 'UMX_SELF_RESET_PWD',
                p_resp_appl => null,
                p_resp_key => null,
                p_security_group_key => null,
                p_parameters => l_param);


        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'RESETURL',
                                   avalue   => l_url);

    end if;

    resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.GenUrl2ResetPwdPg.end',
                      'l_url: ' || l_url);
    end if;

  exception
    when others then
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DEBUG_INFO',
                                   avalue   => to_char(actid));
      Wf_Core.Context('UMX_LOGIN_HELP_PVT', 'GenUrl2ResetPwdPg', itemtype, itemkey, actid);
      raise;
  end GenUrl2ResetPwdPg;

  Procedure GenUrl2LoginPg(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2) is
    l_url  varchar2(32000);
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.GenUrl2LoginPg.begin', '');
    end if;

    if (funcmode = 'RUN') then

	   l_url := FND_SSO_MANAGER.getloginurl;

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'LOGINURL',
                                   avalue   => l_url);
    end if;

    resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;


    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.GenUrl2LoginPg.end',
                      'l_url: ' || l_url);
    end if;

  end GenUrl2LoginPg;


  Procedure DisableAccount(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2) is
    l_user_name  fnd_user.user_name%type;
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.DisableAccount.begin', '');
    end if;

    if (funcmode = 'RUN') then
        l_user_name := WF_ENGINE.GetItemAttrText (
          itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'USER_NAME');

        if ( l_user_name is not null ) then
          fnd_user_pkg.disableuser( username => l_user_name );
        end if;
    end if;

    resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;


    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.DisableAccount.end',
                      'l_user_name: ' || l_user_name);
    end if;

  end DisableAccount;
  PROCEDURE ValidateAuthKey( p_authkey            in varchar2,
                                 p_itemkey            in varchar2,
                                 x_no_attempts        out NOCOPY varchar2,
                                 x_return_status      out NOCOPY varchar2,
                                 x_message_name       out NOCOPY varchar2)
  IS
    l_user_name fnd_user.user_name%type;
    l_authkey  varchar2(400);
    l_notification_preference  wf_local_roles.notification_preference%type;
    l_email_address            varchar2(2000);
    l_pwd_changeable           boolean := true;
    l_role_name                wf_local_roles.name%type;
    l_item_status              varchar2(8);
    l_item_result              varchar2(30);

  BEGIN
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ValidateResetPwdReq.begin',
                      ' | p_authkey: ' || p_authkey ||
                      ' | p_itemkey: ' || p_itemkey );
    end if;


    WF_ENGINE.itemstatus( g_itemtype, p_itemkey, l_item_status, l_item_result );

    if ( l_item_status <> 'ACTIVE' ) then
        x_return_status := 'E';
        x_message_name := 'UMX_RESET_PWD2_VALID_FAILED';
        return;
    end if;
    x_no_attempts := WF_ENGINE.GetItemAttrText(g_itemtype, p_itemkey, 'MAX_NO_ATTEMPT');
    if ( to_number( x_no_attempts ) <= 0 ) then
        x_return_status := 'E';
        x_message_name := 'UMX_RESET_PWD2_VALID_FAILED';
        return;
    end if;


    l_authkey := WF_ENGINE.GetItemAttrText(g_itemtype, p_itemkey, 'AUTH_KEY');

    if ( l_authkey = p_authkey ) then
        x_return_status := 'S';
        return;
    else
        x_return_status := 'E';
        x_message_name := 'UMX_RESET_PWD2_UNEXP_ERROR';
        decrementAttemptCounter( p_itemkey, x_no_attempts);
        return;
    end if;


    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
          FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ValidateResetPwdReq.end',
                      'x_return_status: ' || x_return_status ||
                      'x_message_name: ' || x_message_name );
    end if;

  exception
        when others then
            x_return_status := 'E';

            if ( x_message_name is null ) then
                x_message_name := 'UMX_RESET_PWD2_VALID_FAILED';
            end if;

            if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) then
              FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                      'Exception in fnd.plsql.UMX_LOGIN_HELP_PVT.ValidatePwdResetReq.end',
                      'x_return_status: ' || x_return_status ||
                      'x_message_name: ' || x_message_name ||
                      fnd_message.get );
            end if;

  end ValidateAuthKey;



  PROCEDURE ValidateResetPwdReq (p_username           in fnd_user.user_name%type,
                                 p_authkey            in varchar2,
                                 p_itemkey            in varchar2,
                                 x_no_attempts        out NOCOPY varchar2,
                                 x_return_status      out NOCOPY varchar2,
                                 x_message_name       out NOCOPY varchar2)
  IS
    l_user_name fnd_user.user_name%type;
    l_authkey  varchar2(400);
    l_notification_preference  wf_local_roles.notification_preference%type;
    l_email_address            varchar2(2000);
    l_pwd_changeable           boolean := true;
    l_role_name                wf_local_roles.name%type;
    l_item_status              varchar2(8);
    l_item_result              varchar2(30);

  BEGIN
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ValidateResetPwdReq.begin',
                      'p_username: ' || p_username ||
                      ' | p_authkey: ' || p_authkey ||
                      ' | p_itemkey: ' || p_itemkey );
    end if;

    WF_ENGINE.itemstatus( g_itemtype, p_itemkey, l_item_status, l_item_result );

    if ( l_item_status <> 'ACTIVE' ) then
        x_return_status := 'E';
        x_message_name := 'UMX_RESET_PWD2_VALID_FAILED';
        return;
    end if;

    x_no_attempts := WF_ENGINE.GetItemAttrText(g_itemtype, p_itemkey, 'MAX_NO_ATTEMPT');

    if ( to_number( x_no_attempts ) <= 0 ) then
        x_return_status := 'E';
        x_message_name := 'UMX_RESET_PWD2_VALID_FAILED';
        return;
    end if;

    l_user_name := WF_ENGINE.GetItemAttrText(g_itemtype, p_itemkey, 'USER_NAME');
    l_authkey := WF_ENGINE.GetItemAttrText(g_itemtype, p_itemkey, 'AUTH_KEY');

    if ( l_authkey = p_authkey ) then
        x_return_status := 'S';
    else
        x_return_status := 'E';
        x_message_name := 'UMX_RESET_PWD2_UNEXP_ERROR';
        decrementAttemptCounter( p_itemkey, x_no_attempts);
        return;
    end if;

    if ( l_user_name <> p_username ) then
        x_return_status := 'E';
        x_message_name := 'UMX_RESET_PWD2_INVALID_UNAME';
        if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) then
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ResetPwdPvt.ValidateResetPwdReq',
                      'failed');
        end if;
        decrementAttemptCounter( p_itemkey => p_itemKey,
                                 x_no_attempts => x_no_attempts);
        return;
    end if;

    if not FND_SSO_Manager.isPasswordChangeable(p_username) then
        x_return_status := 'E';
        x_message_name := 'UMX_LOGIN_HELP_PWD_EXTERNAL';
        return;
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
          FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ValidateResetPwdReq.end',
                      'x_return_status: ' || x_return_status ||
                      'x_message_name: ' || x_message_name );
    end if;

  exception
        when others then
            x_return_status := 'E';

            if ( x_message_name is null ) then
                x_message_name := 'UMX_RESET_PWD2_VALID_FAILED';
            end if;

            if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) then
              FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                      'Exception in fnd.plsql.UMX_LOGIN_HELP_PVT.ValidatePwdResetReq.end',
                      'x_return_status: ' || x_return_status ||
                      'x_message_name: ' || x_message_name ||
                      fnd_message.get );
            end if;

  end ValidateResetPwdReq;


  PROCEDURE ValidatePassword( p_username in fnd_user.user_name%type,
                             x_password in out NOCOPY varchar2,
                             x_return_status out NOCOPY varchar2,
                             x_message_name out NOCOPY varchar2,
                             x_message_data out NOCOPY varchar2 )
  IS
    l_result varchar2(10);
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ValidatePassword.begin',
                      'p_username: ' || p_username);
    end if;


      l_result := FND_WEB_SEC.validate_password (p_username, x_password);

      IF ( l_result <> 'Y' ) THEN
        -- Throw exception as even though generated password 100 times, but
        -- cannot pass validation criteria
        if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) then
          FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                          'fnd.plsql.UMX_LOGIN_HELP_PVT.ValidatePassword',
                          'Validate Password failed.');
        end if;
        x_return_status := 'E';
        x_message_name := 'UMX_RESET_PWD2_VALID_FAIL';
        x_message_data := fnd_message.get;
      ELSE
        if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) then
          FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                          'fnd.plsql.UMX_LOGIN_HELP_PVT.ValidatePassword',
                          'Validate Password success.');
        end if;
        x_return_status := 'S';
        x_message_name := 'UMX_RESET_PWD2_CONFIRM_MSG';
      END IF;
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ValidatePassword.end',
                      'password validated' );
    end if;

  end;
  procedure decrementAttemptCounter(
                                p_itemkey               in varchar2,
                                x_no_attempts           out NOCOPY varchar2) IS
    l_no_attempt    pls_integer := 0;
  begin
    -- retrieve no of attempts from wf
    l_no_attempt := wf_engine.getitemattrnumber(
                                itemtype => g_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'MAX_NO_ATTEMPT');
    l_no_attempt := l_no_attempt - 1;

    wf_engine.SetItemAttrNumber (itemtype => g_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'MAX_NO_ATTEMPT',
                                   avalue   => l_no_attempt );
    x_no_attempts := to_char( l_no_attempt );

  end decrementAttemptCounter;


  -- Private Method
  procedure ResetPwdPvt (p_username              in fnd_user.user_name%type,
                         --p_usernameurl           in fnd_user.user_name%type,
                         p_password              in varchar2 default null,
                         p_itemkey               in varchar2,
                         p_authkey               in varchar2,
                         x_no_attempts           out NOCOPY varchar2,
                         x_return_status         out NOCOPY varchar2,
                         x_message_name          out NOCOPY varchar2,
                         x_message_data          out NOCOPY varchar2) IS

    l_user_name                fnd_user.user_name%type := upper(p_username);
--    l_email_address            varchar2(2000);
--    l_role_name                wf_local_roles.name%type;
    l_password                 varchar2(40) := p_password;
--    l_notification_preference  wf_local_roles.notification_preference%type;
    l_result                   wf_item_activity_statuses.activity_result_code%type;
--    l_status                   wf_item_activity_statuses.activity_status%type;
--    l_itemkey                  wf_items.item_key%type;
    l_pwdChangeable            boolean := null;
    l_updatePwdFailedException exception;

    l_item_status              varchar2(8);
    l_item_result              varchar2(30);

  begin
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ResetPwdPvt.begin',
                      'p_username: ' || p_username);
    end if;


    x_return_status := FND_API.G_RET_STS_ERROR;

    ValidateResetPwdReq( p_username => p_username,
                         p_authkey => p_authkey,
                         p_itemkey => p_itemkey,
                         x_no_attempts => x_no_attempts,
                         x_return_status => x_return_status,
                         x_message_name  => x_message_name );

    if ( x_return_status <> 'S' ) then
        if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) then
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ResetPwdPvt.ValidateResetPwdReq',
                      'failed');
        end if;
        return;
    end if;


    -- validate the user's new password for system-enforcement
    ValidatePassword( p_username  => l_user_name,
                      x_password  => l_password,
                      x_return_status => x_return_status,
                      x_message_name => x_message_name,
                      x_message_data => x_message_data );

    if ( x_return_status = 'S' ) then
        BEGIN

            FND_USER_PKG.UpdateUserParty (
                  x_user_name            => l_user_name,
                  x_owner                => l_user_name,
                  x_unencrypted_password => l_password,
                  x_password_date        => sysdate);
        EXCEPTION
            when others then
                x_return_status := 'E';
                x_message_name := 'UMX_RESET_PWD2_UNEXP_ERROR';
                if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) then
                  FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                          'fnd.plsql.UMX_LOGIN_HELP_PVT.ResetPwdPvt.FND_USER_PKG.UpdateUserParty',
                          'x_no_attempts: ' || x_no_attempts ||
                          'x_return_status: ' || x_return_status ||
                          ' | x_message_name: ' || x_message_name );
                end if;
        END;
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ResetPwdPvt.end',
                      'x_return_status: ' || x_return_status ||
                      ' | x_message_name: ' || x_message_name );
    end if;
  EXCEPTION
      when others then
        x_message_name := 'UMX_RESET_PWD2_UNEXP_ERROR';
        x_message_data := fnd_message.get;

  END ResetPwdPvt;


  procedure ResetPassword(  p_username           in fnd_user.user_name%type,
                            --p_usernameurl        in fnd_user.user_name%type,
                            p_password           in varchar2 default null,
                            p_itemkey            in varchar2,
                            p_authkey            in varchar2,
                            x_no_attempts        out NOCOPY varchar2,
                            x_return_status      out NOCOPY varchar2,
                            x_message_name       out NOCOPY varchar2,
                            x_message_data       out NOCOPY varchar2) is

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ResetPassword.begin',
                      'p_username: ' || p_username);
    end if;

    /*
    x_return_status := 'S';
    x_message_name := 'UMX_RESET_PWD2_CONFIRM_MSG';
    x_message_data := 'TEST';
    */
    ResetPwdPvt (p_username             => p_username,
                 --p_usernameurl          => p_usernameurl,
                 p_password             => p_password,
                 p_itemkey              => p_itemkey,
                 p_authkey              => p_authkey,
                 x_no_attempts          => x_no_attempts,
                 x_return_status        => x_return_status,
                 x_message_name         => x_message_name,
                 x_message_data         => x_message_data);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.ResetPassword.end',
                      'x_return_status: ' || x_return_status ||
                      ' | x_message_name: ' || x_message_name);
    end if;

  end ResetPassword;

  procedure CompleteActivity( p_itemKey          in varchar2,
                            x_return_status      out NOCOPY varchar2,
                            x_message_name       out NOCOPY varchar2) is
    l_item_status       varchar2(8);
    l_item_result       varchar2(30);
    l_role_name         varchar2(200);
		l_parent_item_key varchar2(50);
-- changes to figure out if role is a ad hoc role,7445188
    l_orig_system wf_local_roles.orig_system%TYPE;
    l_orig_system_id wf_local_roles.orig_system_id%type;
  begin

    x_return_status := 'S';
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.CompleteActivity.begin',
                      ' p_itemkey: ' || p_itemKey );
    end if;

    l_role_name := WF_ENGINE.GetItemAttrText (
          itemtype => g_itemtype,
          itemkey  => p_itemKey,
          aname    => 'X_USER_ROLE');
-- get orig system info and check if this is an ad-hoc role ,7445188
 wf_directory.getroleOrigsysinfo(l_role_name,l_orig_system,l_orig_system_id);
   if l_orig_system ='WF_LOCAL_ROLES' then
	wf_directory.setAdHocRoleExpiration(l_role_name);
  end if;

    wf_engine.abortprocess(
        itemtype => g_itemtype,
        itemkey => p_itemKey,
        process => null,
        result => null,
        verify_lock => false,
        cascade => true);

      l_parent_item_key := wf_engine.getItemattrtext (itemtype => g_itemtype,
                                            itemkey => p_itemKey,
                                            aname => 'PARENT_ITEM_KEY',
																						ignore_notfound => true);

			-- Restart the parent workflow if any
			if l_parent_item_key is not null then
          wf_event.raise (p_event_name => 'oracle.apps.fnd.umx.resetpwddone',
                      p_event_key  => l_parent_item_key,
                      p_parameters => null);
      end if;


    x_return_status := 'S';

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMX_LOGIN_HELP_PVT.CompleteActivity.end',
                      'x_return_status: ' || x_return_status ||
                      ' | x_message_name: ' || x_message_name);
    end if;
  EXCEPTION
      when others then
        x_return_status := 'E';
        x_message_name := 'UMX_RESET_PWD2_UNEXP_ERROR';

  end CompleteActivity;


  procedure complete_workflow(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2) is
	 l_parent_item_key varchar2(50);
  begin

      l_parent_item_key := wf_engine.getItemattrtext (itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PARENT_ITEM_KEY',
																						ignore_notfound => true);

			-- Restart the parent workflow if any
			if l_parent_item_key is not null then
          wf_event.raise (p_event_name => 'oracle.apps.fnd.umx.resetpwddone',
                      p_event_key  => l_parent_item_key,
                      p_parameters => null);
      end if;

   resultout := 'COMPLETE';
  end;


END UMX_LOGIN_HELP_PVT;

/
