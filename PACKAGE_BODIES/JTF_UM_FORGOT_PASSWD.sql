--------------------------------------------------------
--  DDL for Package Body JTF_UM_FORGOT_PASSWD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_FORGOT_PASSWD" as
/* $Header: JTFVUPWB.pls 115.17 2004/05/12 20:10:10 kchervel ship $ */


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

function generate_password return varchar2 is

  l_password_len   int := 6;
  x_password   varchar2(50);
  ascii_offset     int     := 65;

begin

     -- initialize the random number generator
     dbms_random.initialize(dbms_utility.get_time);

     -- using the profile, determine the length of the random number
     l_password_len := greatest(nvl(fnd_profile.value('SIGNON_PASSWORD_LENGTH'), l_password_len), l_password_len);

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

    return x_password;

end generate_password;


Procedure SetPassword_WF(itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout in out  NOCOPY varchar2) is
   l_password varchar2(40);
   l_user_name varchar2(360);
   l_result varchar2(10);
   v_counter BINARY_INTEGER := 1;

begin
   if (funcmode = 'RUN') then
      l_password := generate_password;


      -- code for validating the generated username
      -- get the username
      l_user_name := WF_ENGINE.GetItemAttrText(itemtype, itemkey,
                                           'X_USER_NAME');

      -- loop till password clears the validations
      l_result := FND_WEB_SEC.validate_password( l_user_name, l_password );
      WHILE (( l_result <> 'Y') AND ( v_counter <=100) ) LOOP
        v_counter := v_counter + 1;
        l_password := generate_password;
        l_result := FND_WEB_SEC.validate_password( l_user_name, l_password );
        IF ( v_counter = 100 ) THEN
           IF ( l_result <> 'Y' ) THEN
              -- Throw exception as even though generated password 100 times, but
              -- cannot pass validation criteria
              raise_application_error (-20000, 'Could not generated password automatically which satisfies validation requirements.');
           END IF;
        END IF;
      END LOOP;
      -- end of code for validating username

     wf_engine.SetItemAttrText
    (itemtype => itemtype,
     itemkey  => itemkey,
     aname   => 'X_UNENCRYPTED_PASSWORD',
     avalue => l_password);

    end if;
    resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;

    exception
    when others then
      Wf_Core.Context('FND_WF_STANDARD', 'SetPassword', itemtype, itemkey,
                      actid);
      raise;
end;

--  *******************************************
--     Procedure ForgotPwd
--  *******************************************
/*
procedure ForgotPwd (c_user_name in varchar2) is

c_error_msg              VARCHAR2(2000);
c_login_msg              VARCHAR2(2000);
email_address            VARCHAR2(240);
seq                      NUMBER;
p_name varchar2(360)     := c_user_name;
--p_password               VARCHAR2(30);
p_expire_days number     := 1;
rno                      VARCHAR2(30);
l_auth_mode              VARCHAR2(100);
l_user_id                NUMBER;
e_parameters             WF_PARAMETER_LIST_T;
display_name             varchar2(240);
notification_preference  varchar2(240);
language                 varchar2(30);
territory                varchar2(80);


BEGIN
       SELECT user_id
       into l_user_id
       from fnd_user
       where user_name = upper(c_user_name);

BEGIN
      SELECT 'LDAP'
      INTO l_auth_mode
      FROM fnd_user
      WHERE l_user_id = icx_sec.g_user_id
      AND upper(encrypted_user_password)='EXTERNAL';

      EXCEPTION
      WHEN no_data_found THEN
      l_auth_mode := 'FND';
END;

      IF l_auth_mode <> 'LDAP' THEN
     WF_DIRECTORY.GetRoleInfo(upper(c_user_name), display_name, email_address, notification_preference, language, territory);


--          DBMS_RANDOM.initialize(12345);
--      p_password := to_char(dbms_random.random);
--      rno := to_number(DBMS_RANDOM.random);
--      p_password := 'P'||rno||'W';


--      p_password := generate_password;

      htp.img(curl => '/OA_MEDIA/FNDLOGOS.gif',
              cattributes => 'BORDER=0');
      htp.tableRowClose;
      htp.tableClose;
      htp.line;


  --Raise the event

 -- WF_LOG_PKG.wf_debug_flag := TRUE;

  select ICX_TEXT_S.Nextval into seq from dual;

  WF_EVENT.AddParameterToList('X_USER_NAME', upper(p_name), e_parameters);
--  WF_EVENT.AddParameterToList('X_UNENCRYPTED_PASSWORD', p_password,e_parameters);
--  WF_EVENT.AddParameterToList('X_PASSWORD_LIFESPAN_DAYS', p_expire_days,e_parameters);

  WF_EVENT.Raise(p_event_name=>'oracle.apps.fnd.user.password.reset_requested',
                 p_event_key=>seq, p_parameters=>e_parameters);

--  DBMS_RANDOM.terminate;

  fnd_message.set_name('ICX','ICX_FORGOT_PASSWORD_NOTIFY');
  c_error_msg := fnd_message.get;

  if email_address is null
  then

  -- fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
  -- c_login_msg := fnd_message.get;
   fnd_message.set_name('ICX','ICX_EMAIL_ADDRESS_NULL_PWD');
   c_error_msg := fnd_message.get;
   htp.p(c_error_msg);

  else
  htp.p(c_error_msg);

  end if;

-- Second phase will allow re-direct to different site to change password
-- else if l_auth_mode = 'EXTERNAL'
-- then
-- get the value of the profile option FND_PASSWORD_EXTERNAL_SITE
-- create the link woth this url (redirection to the whatever the
-- profile options says. If null give them the standard error message below
-- owa_util.redirect_url(l_external_password_site);

 elsif l_auth_mode = 'EXTERNAL' then

 fnd_message.set_name('FND','PASSWORD-NOT ORACLE-MANAGED');
 c_error_msg := fnd_message.get;
 htp.p(c_error_msg);

 end if;

   EXCEPTION
        when no_data_found then
        fnd_message.set_name('ICX','ICX_ACCT_EXPIRED');
        c_error_msg := fnd_message.get;
        fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
        c_login_msg := fnd_message.get;
        htp.img(curl => '/OA_MEDIA/FNDLOGOS.gif',
        cattributes => 'BORDER=0');
        htp.tableRowClose;
        htp.tableClose;
        htp.line;
        htp.p(c_error_msg);
        htp.p(c_login_msg);

 END;
*/

-------------------------------------------------------------------
-- Name:        UpdatePassword_WF
-- Description: Calls FND_USER_PKG.UpdateUser
-------------------------------------------------------------------


 Procedure UpdatePassword_WF(itemtype  in varchar2,
                             itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout in out  NOCOPY varchar2) is

  l_user_name varchar2(360);
  begin

    if (funcmode = 'RUN') then

      l_user_name := WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid,
                                           'X_USER_NAME');
      FND_USER_PKG.UpdateUser(
           x_user_name=> l_user_name,
           x_owner=>'CUST',
           x_unencrypted_password=>
             WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid,
                                                'X_UNENCRYPTED_PASSWORD',
                                                TRUE),
           -- setting password date to null for force passwd change for user
           x_password_date=> fnd_user_pkg.null_date,
           /*
           x_password_date=>
             WF_ENGINE.GetActivityAttrDate(itemtype, itemkey, actid,
                                                'X_PASSWORD_DATE', TRUE),
           */
           x_password_accesses_left=>
             WF_ENGINE.GetActivityAttrNumber(itemtype, itemkey, actid,
                                                'X_PASSWORD_ACCESSES_LEFT',
                                                TRUE),
         x_password_lifespan_accesses=>
            WF_ENGINE.GetActivityAttrNumber(itemtype, itemkey, actid,
                                                'X_PASSWORD_LIFESPAN_ACCESSES',
                                                TRUE),
           x_password_lifespan_days=>
             WF_ENGINE.GetActivityAttrNumber(itemtype, itemkey, actid,
                                                'X_PASSWORD_LIFESPAN_DAYS',
                                                TRUE));


     -- update the password date to null. this will force the user to change
     -- password upon first logon. refer to bug 2679640

     -- removing direct update as bug 2679640 has been fixed
     /*
        update fnd_user set
        password_date = null
        where user_name = l_user_name;
     */

      resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;

    else
      resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;

    end if;

  exception
    when others then
      Wf_Core.Context('FND_WF_STANDARD', 'UpdatePassword', itemtype, itemkey,
                      actid);
      raise;
end;

----------------------------------------------------------------------------

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

l_user_name              varchar2(360);
display_name             varchar2(240);
notification_preference  varchar2(240);
language                 varchar2(30);
territory                varchar2(80);
email_address            VARCHAR2(240);
l_user_role              varchar2(400);

cursor c_fnd_email is
select email_address
from fnd_user
where user_name = l_user_name;

cursor c_party_email is
select hzp.email_address
from hz_parties hzp, fnd_user fu
where hzp.party_id = fu.customer_id
and fu.user_name = l_user_name;

begin

  if (funcmode = 'RUN') then
   l_user_name := upper(WF_ENGINE.GetItemAttrText(itemtype, itemkey,
                                           'X_USER_NAME'));
   l_user_role := 'FNDPWD_'||itemkey||l_user_name;

   -- check to see if the user has notification pref set to mail. if not
  -- create the role.

       WF_DIRECTORY.GetRoleInfo(l_user_name,
                                display_name,
                                email_address,
                                notification_preference,
                                language, territory);
      if (notification_preference like 'MAIL%'
            and email_address is not NULL) then
             l_user_role := l_user_name;
      else
         -- if email address is null get it from fnd
         if email_address is NULL then
            for k in c_fnd_email loop
              email_address := k.email_address;
            end loop;
         end if;

         -- if email address is null get it from party
         if email_address is NULL then
            for k in c_party_email loop
              email_address := k.email_address;
            end loop;
         end if;

         WF_DIRECTORY.CreateAdHocRole  (role_name => l_user_role,
            role_display_name =>  l_user_role,
            language          => language,
            territory => territory,
            role_users => null,
            email_address => email_address);
      end if;




   -- set the role in fnd_user workflow to the new role

   wf_engine.SetItemAttrText
    (itemtype => itemtype,
     itemkey  => itemkey,
     aname   => 'X_USER_ROLE',
     avalue => l_user_role);

  end if;
  resultout := WF_ENGINE.eng_completed || ':' || WF_ENGINE.eng_null;
  exception
    when others then
      Wf_Core.Context('FND_WF_STANDARD', 'CreateRole', itemtype, itemkey,
                      actid);
      raise;
end CreateRole;

procedure ForgotPwd (p_user_name in varchar2,
                     x_return_status out  NOCOPY varchar2,
                     x_message_data  out  NOCOPY varchar2) is
l_message_name varchar2(2000);
begin
   /* Commented out by pseo to support passing back the message-name
     forgotPwd(p_user_name => p_user_name,
             p_user_appr_msg_name => null,
             p_pwd_reset_msg_name => null,
             x_return_Status => x_return_status,
             x_message_Data  => x_message_Data);
   */
   forgotPwd(p_user_name => p_user_name,
             p_user_appr_msg_name => null,
             p_pwd_reset_msg_name => null,
             x_return_Status => x_return_status,
             x_message_name => l_message_name,
             x_message_data  => x_message_data);
end;

procedure ForgotPwd (p_user_name in varchar2,
                     x_return_status out  NOCOPY varchar2,
                     x_message_name  out  NOCOPY varchar2,
                     x_message_data  out  NOCOPY varchar2) is
begin
   forgotPwd(p_user_name => p_user_name,
             p_user_appr_msg_name => null,
             p_pwd_reset_msg_name => null,
             x_return_Status => x_return_status,
             x_message_name => x_message_name,
             x_message_data  => x_message_data);
end;

procedure ForgotPwd (p_user_name in varchar2,
                     p_user_appr_msg_name in varchar2,
                     p_pwd_reset_msg_name in varchar2,
                     x_return_status out  NOCOPY varchar2,
                     x_message_data  out  NOCOPY varchar2) is
l_message_name varchar2(2000);
begin
   forgotPwd(p_user_name => p_user_name,
             p_user_appr_msg_name => null,
             p_pwd_reset_msg_name => null,
             x_return_Status => x_return_status,
             x_message_name => l_message_name,
             x_message_data  => x_message_data);
end;

procedure ForgotPwd (p_user_name in varchar2,
                     p_user_appr_msg_name in varchar2,
                     p_pwd_reset_msg_name in varchar2,
                     x_return_status out  NOCOPY varchar2,
                     x_message_name out  NOCOPY varchar2,
                     x_message_data  out  NOCOPY varchar2) is


email_address            VARCHAR2(240);
seq                      NUMBER;
l_auth_mode              VARCHAR2(100);
l_user_id                NUMBER;
display_name             varchar2(240);
notification_preference  varchar2(240);
language                 varchar2(30);
territory                varchar2(80);
p_name                   varchar2(300) := upper(p_user_name);
l_fnd_email_address      varchar2(240);

cursor C_active_wf_exists is
select 'X'
from wf_items wfi, wf_item_attribute_values wfa
where wfi.item_type = wfa.item_type
and wfi.item_key = wfa.item_key
and wfi.item_type = 'JTFFPWD'
and wfi.end_date is NULL
and wfa.name = 'X_USER_NAME'
and wfa.text_value = p_name;

cursor c_party_email is
select hzp.email_address
from hz_parties hzp, fnd_user fu
where hzp.party_id = fu.customer_id
and fu.user_name = p_name;

begin
  -- initialize the return status
  x_return_status := FND_API.G_RET_STS_ERROR;

 -- validate user name
  if p_user_name is NULL then
     fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_NULL_USER');
	 x_message_name := 'JTA_UM_FORGOT_PWD_NULL_USER';
     x_message_data := fnd_message.get;
     return;
  end if;
/*
 -- validate active wf
  for j in C_active_wf_exists loop
     fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_WF_EXISTS');
     x_message_data := fnd_message.get;
     return;
  end loop;
*/

  SELECT user_id,
         decode(upper(encrypted_user_password),'EXTERNAL','EXTERNAL','FND'),
         email_address
  into l_user_id, l_auth_mode, l_fnd_email_address
  from fnd_user
  where user_name = p_name
  and start_date <= sysdate
  and nvl(end_date, sysdate + 1) > sysdate;

  -- validate required fields
  /*
	if l_user_id = 1004139 then
       fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_EXTERNAL');
	   --x_message_data := fnd_message.get_number( 690, 'JTA_UM_FORGOT_PWD_NULL_EMAIL' );
	   x_message_name := 'JTA_UM_FORGOT_PWD_EXTERNAL';
       x_message_data := fnd_message.get;
	   return;
    end if;
  */
  IF FND_SSO_Manager.isPasswordChangeable( p_name ) THEN
     WF_DIRECTORY.GetRoleInfo(p_name, display_name,
                 email_address, notification_preference, language, territory);


     if email_address is null then
       -- get the email from fnd_user in case hr email is null
       email_address := l_fnd_email_address;

       if email_address is null then
       -- if email is still null then get it from tca
       -- check if there is a valid party email
         for k in c_party_email loop
           email_address := k.email_address;
         end loop;
       end if;
     end if;

     if email_address is not null then
       select JTF_UM_PSW_WF_S.Nextval into seq from dual;

      -- start the workflow that will send the notification and reset
      -- the password

        wf_engine.CreateProcess(itemtype => 'JTFFPWD',
         itemkey => seq,
         process => 'RESETPASSWD');
        wf_engine.SetItemAttrText(itemtype => 'JTFFPWD',
         itemkey => seq,
         aname => 'X_USER_NAME',
         avalue => p_name);

         if p_user_appr_msg_name is not null then
            wf_engine.SetItemAttrText(itemtype => 'JTFFPWD',
            itemkey => seq,
            aname => 'APPR_MESSAGE',
            avalue => p_user_appr_msg_name);
         end if;

          if p_pwd_reset_msg_name is not null then
            wf_engine.SetItemAttrText(itemtype => 'JTFFPWD',
            itemkey => seq,
            aname => 'CONFIRM_MSG',
            avalue => p_pwd_reset_msg_name);
         end if;

        wf_engine.StartProcess(itemtype => 'JTFFPWD',
         itemkey => seq);


       fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_NOTIFY');
	   x_message_name := 'JTA_UM_FORGOT_PWD_NOTIFY';
       x_message_data := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_SUCCESS;

    else --email address is null

       fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_NULL_EMAIL');
	   --x_message_data := fnd_message.get_number( 690, 'JTA_UM_FORGOT_PWD_NULL_EMAIL' );
	   x_message_name := 'JTA_UM_FORGOT_PWD_NULL_EMAIL';
       x_message_data := fnd_message.get;

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


   fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_EXTERNAL');
   x_message_name := 'JTA_UM_FORGOT_PWD_EXTERNAL';
   x_message_data := fnd_message.get;

 end if;


   EXCEPTION
        when no_data_found then
        fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_INVALID_ACCT');
		x_message_name := 'JTA_UM_FORGOT_PWD_INVALID_ACCT';
        x_message_data := fnd_message.get;

 END;

/*
-- Commented out by pseo to support passing back the message-name
procedure ForgotPwd (p_user_name in varchar2,
                     p_user_appr_msg_name in varchar2,
                     p_pwd_reset_msg_name in varchar2,
                     x_return_status out  NOCOPY varchar2,
                     x_message_data  out  NOCOPY varchar2) is


email_address            VARCHAR2(240);
seq                      NUMBER;
l_auth_mode              VARCHAR2(100);
l_user_id                NUMBER;
display_name             varchar2(240);
notification_preference  varchar2(240);
language                 varchar2(30);
territory                varchar2(80);
p_name                   varchar2(300) := upper(p_user_name);
l_fnd_email_address      varchar2(240);

cursor C_active_wf_exists is
select 'X'
from wf_items wfi, wf_item_attribute_values wfa
where wfi.item_type = wfa.item_type
and wfi.item_key = wfa.item_key
and wfi.item_type = 'JTFFPWD'
and wfi.end_date is NULL
and wfa.name = 'X_USER_NAME'
and wfa.text_value = p_name;

cursor c_party_email is
select hzp.email_address
from hz_parties hzp, fnd_user fu
where hzp.party_id = fu.customer_id
and fu.user_name = p_name;

begin
  -- initialize the return status
  x_return_status := FND_API.G_RET_STS_ERROR;

  -- validate required fields

 -- validate user name
  if p_user_name is NULL then
     fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_NULL_USER');
     x_message_data := fnd_message.get;
     return;
  end if;

  SELECT user_id,
         decode(upper(encrypted_user_password),'EXTERNAL','EXTERNAL','FND'),
         email_address
  into l_user_id, l_auth_mode, l_fnd_email_address
  from fnd_user
  where user_name = p_name
  and start_date <= sysdate
  and nvl(end_date, sysdate + 1) > sysdate;

  IF FND_SSO_Manager.isPasswordChangeable( p_name ) THEN
     WF_DIRECTORY.GetRoleInfo(p_name, display_name,
                 email_address, notification_preference, language, territory);

     if email_address is null then
       -- get the email from fnd_user in case hr email is null
       email_address := l_fnd_email_address;

       if email_address is null then
       -- if email is still null then get it from tca
       -- check if there is a valid party email
         for k in c_party_email loop
           email_address := k.email_address;
         end loop;
       end if;
     end if;

     if email_address is not null then
       select JTF_UM_PSW_WF_S.Nextval into seq from dual;

      -- start the workflow that will send the notification and reset
      -- the password

        wf_engine.CreateProcess(itemtype => 'JTFFPWD',
         itemkey => seq,
         process => 'RESETPASSWD');
        wf_engine.SetItemAttrText(itemtype => 'JTFFPWD',
         itemkey => seq,
         aname => 'X_USER_NAME',
         avalue => p_name);

         if p_user_appr_msg_name is not null then
            wf_engine.SetItemAttrText(itemtype => 'JTFFPWD',
            itemkey => seq,
            aname => 'APPR_MESSAGE',
            avalue => p_user_appr_msg_name);
         end if;

          if p_pwd_reset_msg_name is not null then
            wf_engine.SetItemAttrText(itemtype => 'JTFFPWD',
            itemkey => seq,
            aname => 'CONFIRM_MSG',
            avalue => p_pwd_reset_msg_name);
         end if;

        wf_engine.StartProcess(itemtype => 'JTFFPWD',
         itemkey => seq);


       fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_NOTIFY');
       x_message_data := fnd_message.get;
       x_return_status := FND_API.G_RET_STS_SUCCESS;


    else --email address is null

       fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_NULL_EMAIL');
        x_message_data := fnd_message.get;

    end if;

 else -- cannot change password for this user

   fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_EXTERNAL');
   x_message_data := fnd_message.get;

 end if;


   EXCEPTION
        when no_data_found then
        fnd_message.set_name('JTF','JTA_UM_FORGOT_PWD_INVALID_ACCT');
        x_message_data := fnd_message.get;

 END;

*/

end JTF_UM_FORGOT_PASSWD;

/
