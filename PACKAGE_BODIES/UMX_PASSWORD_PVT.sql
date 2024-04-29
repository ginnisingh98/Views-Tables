--------------------------------------------------------
--  DDL for Package Body UMX_PASSWORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_PASSWORD_PVT" AS
  /* $Header: UMXVUPWB.pls 120.5.12010000.10 2017/12/08 05:31:57 avelu ship $ */

  g_itemtype wf_item_types.name%type := 'UMXUPWD';
  -- Private function to get the email address of the active user from
  -- 1) WF local roles
  -- 2) FND User
  -- 3) The first TCA party
  procedure get_email_address (p_user_name               in fnd_user.user_name%type,
                               x_role_name               out nocopy varchar2,
                               x_email_address           out nocopy varchar2,
                               x_notification_preference out nocopy varchar2,
                               x_message_name            out nocopy varchar2,
                               x_message_data            out nocopy varchar2) is

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
        x_message_name := 'UMX_FORGOT_PWD_INVALID_ACCT';
        fnd_message.set_name('FND', x_message_name);
        x_message_data := fnd_message.get;
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
                      ' | x_message_name: ' || x_message_name ||
                      ' | x_message_data: ' || x_message_data);
    end if;

  end get_email_address;

  function get_username_from_userid (p_user_id  in fnd_user.user_id%type) return fnd_user.user_name%type is

    cursor get_username_from_userid is
      select user_name
      from   fnd_user
      where  user_id = p_user_id;

    l_user_name fnd_user.user_name%type;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.get_username_from_userid.begin',
                      'p_user_id: ' || p_user_id);
    end if;

    open get_username_from_userid;
    fetch get_username_from_userid into l_user_name;
    if (get_username_from_userid%notfound) then
      close get_username_from_userid;
      if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) then
        FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                        'fnd.plsql.UMXVUPWB.ForgotPwd',
                        'Username cannot be found with userid (' || p_user_id || ')');
      end if;
      fnd_message.set_name ('FND', 'UMX_COMMON_UNEXPECTED_ERR_MSG');
      raise_application_error ('-20000', fnd_message.get);
    end if;
    close get_username_from_userid;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.get_username_from_userid.end',
                      'l_user_name: ' || l_user_name);
    end if;

    return l_user_name;

  end;

  -- Procedure  : validate_password
  -- Type       : Private
  -- Pre_reqs   :
  -- Description: This API will validate the user's password.
  -- Parameters
  -- input parameters :
  --    p_username - username of the password's owner
  --    p_password - password to validate
  -- output parameters:
  --    x_return_status - Returns FND_API.G_RET_STS_SUCCESS if success
  --                    - Returns FND_API.G_RET_STS_ERROR if failed
  --    x_message_data  - Reason why it is failed.
  -- Errors      :
  -- Other Comments :
  Procedure validate_password (p_username      in fnd_user.user_name%type,
                               p_password      in varchar2,
                               x_return_status out NOCOPY varchar2,
                               x_message_data  out NOCOPY varchar2) is

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.validate_password.begin',
                      'p_username: ' || p_username);
    end if;

    -- Get username from user id if username is null
    if (fnd_web_sec.validate_password (p_username, p_password) = 'N') then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_message_data := fnd_message.get ();
    else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.validate_password.end',
                      'x_return_status: ' || x_return_status ||
                      ' | x_message_data: ' || x_message_data);
    end if;

  END;

  /**
   * Function    :  generate_password
   * Type        :  Private
   * Pre_reqs    :
   * Description : Creates a password. The length of the password is obtained
   *               from the profile SIGNON_PASSWORD_LENGTH.
   * Parameters
   * input parameters : None
   * output parameters
   * @return   returns a String that can be used as the password
   * Errors      :
   * Other Comments :
   */

  function generate_password(p_username in fnd_user.user_name%type) return varchar2 is

    l_password_len int := 6;
    x_password     varchar2(40);
    ascii_offset   int := 65;
    user_id number;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.generate_password.begin', '');
    end if;

    -- initialize the random number generator
    --dbms_random.initialize(dbms_utility.get_time);

    -- using the profile, determine the length of the random number
      begin
        select USER_ID into USER_ID from FND_USER  where  USER_NAME= P_USERNAME;
      EXCEPTION
         when NO_DATA_FOUND then
            USER_ID := -1;
     end;
     l_password_len := greatest(nvl(to_number(fnd_profile.VALUE_SPECIFIC('SIGNON_PASSWORD_LENGTH',user_id)), l_password_len), l_password_len);

    -- generate a random number to determine where to use an alphabet or a
    -- numeric character for a given position in the password

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) then
      FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                      'fnd.plsql.UMXVUPWB.generate_password',
                      'l_password_len: ' || l_password_len);
    end if;

    for j in 1..l_password_len loop
      if (mod(abs(dbms_random.random),2) = 1) then
        -- generate number
        x_password := x_password || mod(abs(FND_CRYPTO.SmallRandomNumber),10);
      else
        -- generate character
        x_password := x_password || fnd_global.local_chr(mod(abs(FND_CRYPTO.SmallRandomNumber),26)
            + ascii_offset);
      end if;
    end loop;

    -- terminate the random number generator
    --dbms_random.terminate;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.generate_password.end',
                      'password generated');
    end if;

    return x_password;

  end generate_password;

  Procedure SetPassword (p_username in fnd_user.user_name%type,
                         x_password in out NOCOPY varchar2) is

    l_result varchar2(10);
    v_counter BINARY_INTEGER := 1;

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.SetPassword.begin',
                      'p_username: ' || p_username ||
                      ' password is set');
    end if;

    if (x_password is null) then
      x_password := generate_password(p_username);

      -- code for validating the generated username

      -- loop till password clears the validations
      l_result := FND_WEB_SEC.validate_password (p_username, x_password);
      WHILE ((l_result <> 'Y') AND (v_counter <= 100)) LOOP
        v_counter := v_counter + 1;
        x_password := generate_password(p_username);
        l_result := FND_WEB_SEC.validate_password (p_username, x_password);
      END LOOP;

      IF (( v_counter > 100 ) and ( l_result <> 'Y' )) THEN
        -- Throw exception as even though generated password 100 times, but
        -- cannot pass validation criteria
        if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) then
          FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                          'fnd.plsql.UMXVUPWB.ForgotPwd',
                          'Could not generated password automatically which satisfies validation requirements.');
        end if;
        fnd_message.set_name ('FND', 'UMX_COMMON_UNEXPECTED_ERR_MSG');
        raise_application_error ('-20000', fnd_message.get);
      END IF;

      -- end of code for validating username

    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.SetPassword.end',
                      'password set');
    end if;

  end;

  Procedure SetPassword_WF(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2) is

    l_password varchar2(40);
    l_user_name fnd_user.user_name%type;

  begin
    if (funcmode = 'RUN') then
      -- Check if the password is already set.
      l_password := WF_ENGINE.GetActivityAttrText (
          itemtype => itemtype,
          itemkey  => itemkey,
          actid    => actid,
          aname    => 'PASSWORD');

      if (l_password is null) then
        -- code for validating the generated username
        -- get the username
        l_user_name := WF_ENGINE.GetActivityAttrText(
            itemtype => itemtype,
            itemkey  => itemkey,
            actid    => actid,
            aname    => 'USER_NAME');

        SetPassword (p_username => l_user_name,
                     x_password  => l_password);

        l_password := icx_call.encrypt(l_password);
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PASSWORD',
                                   avalue   => l_password);

      end if;
    end if;

    resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;

  exception
    when others then
      Wf_Core.Context('UMX_PASSWORD_PVT', 'SetPassword_WF', itemtype, itemkey, actid);
      raise;
  end;

  -------------------------------------------------------------------
  -- Name:        UpdatePassword_WF
  -- Description: Calls FND_USER_PKG.UpdateUserParty
  -------------------------------------------------------------------
  Procedure UpdatePassword_WF(itemtype  in varchar2,
                              itemkey   in varchar2,
                              actid     in number,
                              funcmode  in varchar2,
                              resultout in out NOCOPY varchar2) is

  begin

    if (funcmode = 'RUN') then

      FND_USER_PKG.UpdateUserParty (
          x_user_name                  =>
              WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid,
                                            'USER_NAME', TRUE),
          x_owner                      => null,
          x_unencrypted_password       =>
              icx_call.decrypt(WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid,
                                            'PASSWORD', TRUE)),
          x_password_date              => fnd_user_pkg.null_date);

    end if;

    resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;

  exception
    when others then
      Wf_Core.Context('UMX_PASSWORD_PVT', 'UpdatePassword_WF', itemtype, itemkey,
                      actid);
      raise;
  end;



/* this method returns a formatted name to be used for display name*/
function getDisplayName(username in varchar2) return varchar2 is
  cursor C_party_id is
   SELECT person_party_id
   FROM fnd_user
   where user_name = username;

  x_return_status		varchar2(40);
  x_msg_count			NUMBER;
  x_msg_data			VARCHAR2(4000);
  x_formatted_name		VARCHAR2(4000);
  x_formatted_lines_cnt		NUMBER;
  x_formatted_name_tbl		hz_format_pub.string_tbl_type;
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
      Wf_Core.Context('UMX_PASSWORD_PVT', 'CreateRole', itemtype, itemkey,
                      actid);
      raise;
  end CreateRole;

  -- Private Method to start Workflow
  procedure start_workflow (p_user_name               in varchar2,
                            p_password                in varchar2,
                            p_email_address           in varchar2,
                            p_role_name               in varchar2,
                            p_notification_preference in varchar2,
                            p_user_appr_msg_name      in varchar2,
                            p_pwd_reset_msg_name      in varchar2,
                            p_check_identity          in varchar2,
                            p_htmlagent               in varchar2,
                            x_itemkey                 out nocopy varchar2) is
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.start_workflow.begin',
                      'p_user_name: ' || p_user_name ||
                      ' | p_email_address: ' || p_email_address ||
                      ' | p_role_name: ' || p_role_name ||
                      ' | p_user_appr_msg_name: ' || p_user_appr_msg_name ||
                      ' | p_pwd_reset_msg_name: ' || p_pwd_reset_msg_name ||
                      ' | p_check_identity: ' || p_check_identity ||
                      ' | p_htmlagent: ' || p_htmlagent);
    end if;

    select to_char (UMX_PASSWORD_WF_S.Nextval) into x_itemkey from dual;

    -- start the workflow that will send the notification and reset
    -- the password

    wf_engine.CreateProcess(itemtype => g_itemtype,
                            itemkey  => x_itemkey,
                            process  => 'RESETPASSWD');

    wf_engine.SetItemAttrText(itemtype => g_itemtype,
                              itemkey  => x_itemkey,
                              aname    => 'USER_NAME',
                              avalue   => p_user_name);

    wf_engine.SetItemAttrText(itemtype => g_itemtype,
                              itemkey  => x_itemkey,
                              aname    => 'PASSWORD',
                              avalue   => icx_call.encrypt(p_password));

    if p_htmlagent is not null then
      wf_engine.SetItemAttrText (itemtype => g_itemtype,
                                 itemkey  => x_itemkey,
                                 aname    => 'HTMLAGENT',
                                 avalue   => p_htmlagent);
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

    if p_notification_preference is not null then
      wf_engine.SetItemAttrText (itemtype => g_itemtype,
                                 itemkey  => x_itemkey,
                                 aname    => 'NOTIFICATION_PREFERENCE',
                                 avalue   => p_notification_preference);
    end if;

    if p_user_appr_msg_name is not null then
      wf_engine.SetItemAttrText(itemtype => g_itemtype,
                                itemkey  => x_itemkey,
                                aname    => 'APPR_MESSAGE',
                                avalue   => p_user_appr_msg_name);
    end if;

    if p_pwd_reset_msg_name is not null then
      wf_engine.SetItemAttrText(itemtype => g_itemtype,
                                itemkey  => x_itemkey,
                                aname    => 'CONFIRM_MSG',
                                avalue   => p_pwd_reset_msg_name);
    end if;

    -- Only update if the Notify User Flag is 'Y' or 'N'
    if  (p_check_identity = 'Y') or (p_check_identity = 'N') then
      wf_engine.SetItemAttrText (itemtype => g_itemtype,
                                 itemkey  => x_itemkey,
                                 aname    => 'L_CHECK_IDENTITY_FLAG',
                                 avalue   => p_check_identity);
    end if;

    wf_engine.StartProcess(itemtype => g_itemtype,
                           itemkey  => x_itemkey);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.start_workflow.end',
                      'x_itemkey: ' || x_itemkey);
    end if;
  end start_workflow;

  -- Private Method
  procedure ResetPwdPvt (p_username              in fnd_user.user_name%type,
                         p_password              in varchar2 default null,
                         p_user_appr_msg_name    in varchar2 default null,
                         p_pwd_reset_msg_name    in varchar2 default null,
                         p_check_identity        in varchar2 default 'Y',
                         p_report_no_email_error in varchar2 default 'N',
                         p_htmlagent 	           in varchar2 default null,
                         x_return_status         out NOCOPY varchar2,
                         x_message_name          out NOCOPY varchar2,
                         x_message_data          out NOCOPY varchar2) is

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

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ResetPwdPvt.begin',
                      'p_username: ' || p_username ||
                      ' | p_htmlagent: ' || p_htmlagent ||
                      ' | password reset ' ||
                      ' | p_user_appr_msg_name: ' || p_user_appr_msg_name ||
                      ' | p_pwd_reset_msg_name: ' || p_pwd_reset_msg_name ||
                      ' | p_check_identity: ' || p_check_identity);
    end if;

    -- initialize the return status
    x_return_status := FND_API.G_RET_STS_ERROR;

    -- validate required fields
    -- validate user name
    if l_user_name is NULL then
      x_message_name := 'UMX_FORGOT_PWD_NULL_USER';
      fnd_message.set_name('FND', x_message_name);
      x_message_data := fnd_message.get;
    else
      if FND_SSO_Manager.isPasswordChangeable (l_user_name) THEN
        get_email_address (l_user_name, l_role_name, l_email_address,
                           l_notification_preference, x_message_name,
                           x_message_data);
        if (x_message_name is null) then
          if (l_email_address is not null) then
            -- Start Workflow to reset user's password.
            start_workflow (l_user_name, p_password, l_email_address, l_role_name,
                            l_notification_preference, p_user_appr_msg_name,
                            p_pwd_reset_msg_name, p_check_identity, p_htmlagent, l_itemkey);
            -- Check if the workflow is in error status
            wf_engine.itemstatus (g_itemtype, l_itemkey, l_status, l_result);
            if (l_status = 'ERROR') then
              -- Error status
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_message_name := 'UMX_FORGOT_PWD_UNEXP_ERR_MSG';
            else
              -- Not error, return notified message.
              x_return_status := FND_API.G_RET_STS_SUCCESS;
              x_message_name  := 'UMX_FORGOT_PWD_NOTIFY';
            end if;
            fnd_message.set_name('FND', x_message_name);
            x_message_data := fnd_message.get;
          else -- email address is null
            if (p_report_no_email_error = 'Y') then
              -- At the moment, only forgot password will require to raise
              -- error message if email address is missing.
              x_message_name := 'UMX_FORGOT_PWD_NULL_EMAIL';
              fnd_message.set_name ('FND', x_message_name);
              x_message_data := fnd_message.get;
            else
              -- Reset the password without starting a workflow
              l_password := p_password;
              SetPassword (p_username  => l_user_name,
                           x_password  => l_password);
              FND_USER_PKG.UpdateUserParty (
                  x_user_name            => l_user_name,
                  x_owner                => null,
                  x_unencrypted_password => l_password,
                  x_password_date        => fnd_user_pkg.null_date);
              x_return_status := FND_API.G_RET_STS_SUCCESS;
            end if;
          end if;
        end if;
      else -- cannot change password for this user

        /*
        -- Second phase will allow re-direct to different site to change password
        -- else if l_auth_mode = 'EXTERNAL'
        -- then
        -- get the value of the profile option FND_PASSWORD_EXTERNAL_SITE
        -- create the link woth this url (redirection to the whatever the
        -- profile options says. If null give them the standard error message below
        -- owa_util.redirect_url(l_external_password_site);th_mode = 'EXTERNAL' then
        */

        x_message_name := 'UMX_FORGOT_PWD_EXTERNAL';
        fnd_message.set_name('FND', x_message_name);
        x_message_data := fnd_message.get;

      end if;
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ResetPwdPvt.end',
                      'x_return_status: ' || x_return_status ||
                      ' | x_message_name: ' || x_message_name ||
                      ' | x_message_data: ' || x_message_data);
    end if;
  EXCEPTION
      when FND_SSO_MANAGER.userNotFound then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --x_message_name := 'UMX_FORGOT_PWD_UNEXP_ERR_MSG';
        x_message_name := 'UMX_FORGOT_PWD_INVALID_ACCT';
        fnd_message.set_name('FND', x_message_name);
        x_message_data := fnd_message.get;

  END ResetPwdPvt;


  procedure ResetPwd (p_username           in fnd_user.user_name%type,
                      p_password           in varchar2 default null,
                      p_user_appr_msg_name in varchar2 default null,
                      p_pwd_reset_msg_name in varchar2 default null,
                      p_check_identity     in varchar2 default 'Y',
                      p_htmlagent          in varchar2 default null,
                      x_return_status      out NOCOPY varchar2,
                      x_message_data       out NOCOPY varchar2) is

  x_message_name varchar2(80);

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ResetPwd.begin',
                      'p_username: ' || p_username ||
                      ' | p_htmlagent: ' || p_htmlagent ||
                      ' | p_user_appr_msg_name: ' || p_user_appr_msg_name ||
                      ' | p_pwd_reset_msg_name: ' || p_pwd_reset_msg_name ||
                      ' | p_check_identity: ' || p_check_identity);
    end if;

    ResetPwdPvt (p_username             => p_username,
                 p_password             => p_password,
                 p_user_appr_msg_name   => p_user_appr_msg_name,
                 p_pwd_reset_msg_name   => p_pwd_reset_msg_name,
                 p_check_identity       => p_check_identity,
                 p_htmlagent            => p_htmlagent,
                 x_return_status        => x_return_status,
                 x_message_name         => x_message_name,
                 x_message_data         => x_message_data);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ResetPwd.end',
                      'x_return_status: ' || x_return_status ||
                      ' | x_message_data: ' || x_message_data);
    end if;

  end ResetPwd;

  procedure ForgotPwd(p_username           in fnd_user.user_name%type,
                      p_user_appr_msg_name in varchar2 default null,
                      p_pwd_reset_msg_name in varchar2 default null,
                      p_check_identity     in varchar2 default 'Y',
                      p_htmlagent 	       in varchar2 default null,
                      x_return_status      out NOCOPY varchar2,
                      x_message_name       out NOCOPY varchar2,
                      x_message_data       out NOCOPY varchar2) is
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ForgotPwd.begin',
                      'p_username: ' || p_username ||
                      ' | p_htmlagent: ' || p_htmlagent ||
                      ' | p_user_appr_msg_name: ' || p_user_appr_msg_name ||
                      ' | p_pwd_reset_msg_name: ' || p_pwd_reset_msg_name ||
                      ' | p_check_identity: ' || p_check_identity);
    end if;

    ResetPwdPvt (p_username              => p_username,
                 p_user_appr_msg_name    => p_user_appr_msg_name,
                 p_pwd_reset_msg_name    => p_pwd_reset_msg_name,
                 p_check_identity        => p_check_identity,
                 p_report_no_email_error => 'Y',
                 p_htmlagent		         => p_htmlagent,
                 x_return_status         => x_return_status,
                 x_message_name          => x_message_name,
                 x_message_data          => x_message_data);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXVUPWB.ForgotPwd.end',
                      'x_return_status: ' || x_return_status ||
                      ' | x_message_name: ' || x_message_name ||
                      ' | x_message_data: ' || x_message_data);
    end if;

  end ForgotPwd;

  -------------------------------------------------------------------
  -- Name:        clean_up_ad_hoc_role
  -- Description: This API set the status to inactive and expiration
  --              date to sysdate of the ad hoc role created by the password
  --              workflow.
  -------------------------------------------------------------------
  Procedure clean_up_ad_hoc_role (itemtype  in varchar2,
                                  itemkey   in varchar2,
                                  actid     in number,
                                  funcmode  in varchar2,
                                  resultout in out NOCOPY varchar2) is

    l_role_name                wf_local_roles.name%type;

  begin

    if (funcmode = 'RUN') then
      l_role_name := WF_ENGINE.GetItemAttrText (itemtype, itemkey, 'X_USER_ROLE');

      -- First check Ad Hoc Role is being used.
      if (l_role_name = 'FNDPWD_' || itemkey || '_' || upper(WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'USER_NAME'))) then

        -- Make Ad Hoc Role to expire.
        -- The expiration_date is set to +30 based on the recommandation from WF.
        wf_directory.SetAdHocRoleExpiration (role_name       => l_role_name,
                                             expiration_date => sysdate + 30);

        -- Set Ad Hoc Role to inactive
        wf_directory.SetAdHocRoleStatus (role_name => l_role_name,
                                         status    => 'INACTIVE');
      end if;
    end if;

    resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;

  exception
    when others then
      Wf_Core.Context('UMX_PASSWORD_PVT', 'clean_up_ad_hoc_role', itemtype, itemkey,
                      actid);
      raise;
  end;

END UMX_PASSWORD_PVT;

/
