--------------------------------------------------------
--  DDL for Package Body ICX_SEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_SEC" as
/* $Header: ICXSESEB.pls 120.2.12010000.10 2016/04/28 17:04:52 stadepal ship $ */

--  ***********************************************
--      function NewSessionId
--  ***********************************************

function NewSessionId(dummy in number)
                     return number is

l_session_id            number;
l_new_session_id        number;
x_session_id            varchar2(1);

begin

    l_session_id := abs(dbms_random.random);

loop

    select 'Y' into x_session_id from icx_sessions
    where session_id =  l_session_id;

     if x_session_id = 'Y'
     then
     l_session_id := abs(dbms_random.random);
     end if;
end loop;

    EXCEPTION
    WHEN no_data_found  THEN
    l_session_id := l_session_id;

    l_new_session_id := l_session_id;

-- Moved terminare above return

    dbms_random.terminate;

    return(l_new_session_id);


end;

--  ***********************************************
--      function NewSessionId
--  ***********************************************

--function NewSessionId(dummy in number)
--                     return number is

--l_session_id            number;
--l_new_session_id        number;

--begin

--select icx_sessions_s.nextval
--  into l_session_id
--  from sys.dual;

--     l_random_num := Random1('X');
--     l_session_id := l_session_id||l_random_num;
--     l_new_session_id := l_session_id;

--return(l_new_session_id);
--end;

--  ***********************************************
--      function validatePassword
--  ***********************************************

function validatePassword(c_user_name     in varchar2,
                          c_user_password in varchar2,
                          n_session_id    out NOCOPY number,
                          c_validate_only in varchar2,
                          c_mode_code     in varchar2,
                          c_url           in varchar2)
                          return varchar2 is

        u                       fnd_user%rowtype;
        c_server_name           varchar2(240);
        c_server_port           varchar2(80);
        l_server                varchar2(240);
        c_script_name           varchar2(80);
        l_host_instance         varchar2(240);
        l_url                   varchar2(2000);
        l_result                varchar2(30);
        l_app                   varchar2(30);
        l_msg_code              varchar2(30);
        l_valid2                varchar2(240);
        v_user_id               number;
        v_user_name             varchar2(80);
        v_password              varchar2(80);
        v_encrypted_psswd       varchar2(1000);
        v_encrypted_upper_psswd varchar2(1000);
        c_error_msg             varchar2(2000);
        c_login_msg             varchar2(2000);
        e_signin_invalid        exception;
        e_account_expired       exception;
        e_invalid_password      exception;
        e_java_password         exception;
        l_enc_fnd_pwd           varchar2(100);
        l_enc_user_pwd          varchar2(100);
        l_expired               varchar2(30);
        return_to_url           varchar2(2000);
        l_agent                 varchar2(240);
        t_user_id               NUMBER; -- added for bug 1916792
        t_language              VARCHAR2(240); -- added for bug 1916792
        c_nls_language          VARCHAR2(240); -- added for bug 1916792
        l_profile_defined            boolean; -- added for bug 1916792
        b_hosted BOOLEAN DEFAULT FALSE;
        l_hosted_profile VARCHAR2(50);
        l_remote_addr           varchar2(80);
        c_error_msg1            varchar2(240);
        p_loginfrom             varchar2(30);


BEGIN
    --htp.p('VP');--mputman debug
   -- start additions for 1916792
     --  icx_sec.g_security_group_id:=c_sec_grp_id;  --mputman hosted update
     --SECURITY_GROUP_KEY in the FND_SECURITY_GROUPS
   fnd_profile.get(name    => 'ENABLE_SECURITY_GROUPS',
                   val     => l_hosted_profile);

   IF (upper(l_hosted_profile)='HOSTED') THEN
      b_hosted:=TRUE;
             fnd_global.apps_initialize(user_id => -1,
                                  resp_id => -1,
                                  resp_appl_id => -1,
                                  security_group_id => icx_sec.g_security_group_id);--mputman hosted update

   END IF;


   -- start additions for 1916792
   BEGIN
      SELECT user_id
         INTO t_user_id
          FROM  fnd_user
         WHERE user_name=upper(c_user_name);
   EXCEPTION
      WHEN no_data_found  THEN
         t_user_id := NULL;
   END;

   IF t_user_id IS NOT NULL THEN
      fnd_profile.get_specific(name_z       => 'ICX_LANGUAGE',
                user_id_z         => t_user_id,
                val_z        => t_language,
                               defined_z    => l_profile_defined);
   ELSE
      t_language := fnd_profile.value('ICX_LANGUAGE');

--start bug 3100151

      l_remote_addr := owa_util.get_cgi_env('REMOTE_ADDR');

     insert into icx_failures
     (user_name,password,failure_code,failure_date,
      created_by, creation_date, last_updated_by,
     last_update_date, last_update_login)
  values
     (l_remote_addr,-1,
      'ICX_ACCT_EXPIRED',sysdate,
      nvl(u.user_id,-1), sysdate, nvl(u.user_id,-1),
      sysdate, u.user_id);
      commit;

--end bug 3100151

   END IF;
   if  t_language is not null
    and nvl(g_language_c,'XXXXX') <> t_language
    then
    FND_GLOBAL.set_nls_context(p_nls_language => t_language);--mputman changed for performance and consist.
       --c_nls_language := ''''||t_language||'''';
       --dbms_session.set_nls('NLS_LANGUAGE'   , c_nls_language);
       g_language_c := t_language;
       end if;

   -- end additions for 1916792

    if (c_user_name is NULL or c_user_password is NULL)
    then
        raise e_signin_invalid;
    end if;

--bug 3238722
        p_loginfrom := 'ICX';
    l_result := fnd_web_sec.validate_login(upper(c_user_name), c_user_password,
                g_p_loginID, g_p_expired, p_loginfrom);

-- Begin Bug 1961641
    if l_result = 'N'
    then
  select *
  into   u
  from   fnd_user
  where  user_name = UPPER(c_user_name);

   if u.user_id = 6
    then
         c_error_msg := fnd_message.get;
         fnd_message.set_name('ICX','ICX_SIGNIN_INVALID');
         c_login_msg := fnd_message.get;
         OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
end if;


  if u.end_date <= sysdate
  then
raise e_java_password;
end if;
end if;
-- End Bug 1961641

    if l_result = 'Y'
    then
    IF b_hosted THEN  --mputman hosted update

       fnd_global.apps_initialize(user_id => t_user_id,
                                  resp_id => -1,
                                  resp_appl_id => -1,
                                  security_group_id => icx_sec.g_security_group_id);--mputman added 2092330
       ELSE
       fnd_global.apps_initialize(user_id => t_user_id,
                                  resp_id => -1,
                                  resp_appl_id => -1,
                                  security_group_id => -1);--mputman added 2092330

       END IF;

      -- if c_url is null then we don't know where to return the user
      -- in the situation where the user updates expired password.
      -- assign a default url.
      if (c_url is null) then
         --l_agent := icx_plug_utilities.getPLSQLagent; -- mputman removed 1574527
         --return_to_url :=  l_agent || 'OracleMyPage.Home?validate_flag=Y';
           return_to_url := 'OracleMyPage.Home?validate_flag=Y'; -- removed agent to work in stateful envs mputman 1574527
      else
         return_to_url := c_url;
      end if;

      begin
         select 'Y'
           into  l_expired
           from  FND_USER
          where  USER_NAME = UPPER(c_user_name)
            and    (PASSWORD_DATE is NULL or
                   (PASSWORD_LIFESPAN_ACCESSES is not NULL and
                     nvl(PASSWORD_ACCESSES_LEFT, 0) < 1) or
                   (PASSWORD_LIFESPAN_DAYS is not NULL and
                   SYSDATE >= PASSWORD_DATE + PASSWORD_LIFESPAN_DAYS));
      exception
             when no_data_found then
                l_expired := 'N';
      end;

      if (l_expired = 'Y') then
         OracleApps.displayNewPassword(c_user_name, return_to_url, c_mode_code);
         return -1;

      else

         select *
         into   u
         from   fnd_user
         where  user_name = UPPER(c_user_name);

         if u.end_date is null or u.end_date > sysdate
         then

           return NewSession(      user_info       => u,
                                   c_user_name     => c_user_name,
                                   c_password      => c_user_password,
                                   n_session_id    => n_session_id,
                                   c_validate_only => c_validate_only,
                                   c_mode_code     => c_mode_code);

         else
             raise e_account_expired;
         end if; -- u.end_date is null or u.end_date > sysdate
      end if;  -- l_expired

    else
--      l_msg_code := fnd_message.get; 2697634
      fnd_message.parse_encoded(fnd_message.get_encoded,l_app,l_msg_code);
      if l_msg_code = 'SECURITY_APPL_LOGIN_FAILED'
      then

        begin
          select *
          into   u
          from   fnd_user
          where  user_name = UPPER(c_user_name)
          and    WEB_PASSWORD is not null;
        exception
          when others then
            raise e_java_password;
        end;

        v_encrypted_upper_psswd := to_char(icx_call.crchash( UPPER(c_user_name), UPPER(c_user_password)));

        v_encrypted_psswd := to_char(icx_call.crchash( UPPER(c_user_name),c_user_password));

        if u.WEB_PASSWORD = v_encrypted_upper_psswd or u.WEB_PASSWORD = v_encrypted_psswd
        then
            OracleApps.displayNewPassword(i_1 => c_user_name);
            return '-1';
        else
              raise e_java_password;
        end if;
      else

--bug 2505470 - change exception below
--          raise e_java_password;
            raise e_signin_invalid;
      end if;
    end if; -- l_valid = '0';

exception
   when e_java_password
   then

      if c_validate_only = 'N'
      then
         fnd_message.set_name('ICX','ICX_ACCT_EXPIRED');
         c_error_msg := fnd_message.get;
         fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
         c_login_msg := fnd_message.get;

         OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
      end if;

      insert into icx_failures
         (user_name,password,failure_code,failure_date,
          created_by, creation_date, last_updated_by,
         last_update_date, last_update_login)
      values
         (c_user_name,-1,
          'ICX_ACCT_EXPIRED',sysdate,
          nvl(u.user_id,-1), sysdate, nvl(u.user_id,-1),
          sysdate, u.user_id);

      return '-1';

   when e_signin_invalid OR e_invalid_password
   then
      if c_validate_only = 'N'
      then

         fnd_message.set_name('ICX','ICX_SIGNIN_INVALID');
         c_error_msg := fnd_message.get;
         fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
         c_login_msg := fnd_message.get;


         OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');

      end if;

      v_encrypted_psswd := icx_call.encrypt(c_user_password);

      insert into icx_failures
         (user_name,password,failure_code,failure_date,
          created_by, creation_date, last_updated_by,
         last_update_date, last_update_login)
      values
         (c_user_name,v_encrypted_psswd,'ICX_SIGNIN_INVALID',sysdate,
          '-1', sysdate, '-1', sysdate, '-1');
      return '-1';

   when others
   then
      if c_validate_only = 'N'
      then

--Start Bug 3161306
         select fnd_message.get into c_error_msg1 from dual;
            if c_error_msg1 like 'Oracle error%'
            then
            htp.p(c_error_msg1);
            htp.nl;
            htp.line;
            end if;
--End Bug 3161306

         fnd_message.set_name('ICX','ICX_SIGNIN_INVALID');
         c_error_msg := fnd_message.get;
         fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
         c_login_msg := fnd_message.get;

 OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
end if;

/*
    when others then
        htp.p(SQLERRM);
*/
      return '-1';
end;

--  ***********************************************
--      Function createSlaveSession
--  ***********************************************

procedure SS(S  in varchar2) is

l_parameters            icx_on_utilities.v80_table;
l_user_id               number;
l_responsibility_id     number;
l_function_id           number;
l_user                  fnd_user%rowtype;
l_session_id            number;
        c_server_name           varchar2(240);
        c_domain                varchar2(240);
l_date_format_mask      varchar2(240);
l_error_msg             varchar2(2000);
l_login_msg             varchar2(2000);
l_ip_address            varchar2(50);
l_url                   varchar2(2000);

begin

icx_on_utilities.unpack_parameters(icx_call.decrypt2(S),l_parameters);

l_user_id := l_parameters(1);
l_responsibility_id := l_parameters(2);
l_function_id := l_parameters(3);

l_ip_address := owa_util.get_cgi_env('REMOTE_ADDR');

l_session_id := 1234;

owa_util.mime_header('text/html', FALSE);

sendsessioncookie(l_session_id);

owa_util.http_header_close;

l_url := 'OracleApps.RF?F='||icx_call.encrypt2(l_responsibility_id||'*'||l_function_id||'**]');

htp.htmlOpen;
-- htp.p('<body onload="open('''||l_url||''', ''_top'')">');

htp.p('Run Function would called here');

-- htp.p('</body>');
htp.htmlClose;

exception
   when others then
      fnd_message.set_name('ICX','ICX_DATA_INCORRECT');
      l_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
      l_login_msg := fnd_message.get;

      OracleApps.displayLogin(l_error_msg||' '||l_login_msg,'IC','Y');

      insert into icx_failures
         (user_name,password,failure_code,failure_date,
          created_by, creation_date, last_updated_by,
          last_update_date, last_update_login)
      values
         ('-1','-1','ICX_NAVIGATOR',sysdate,
          '-1', sysdate, '-1', sysdate, '-1');
end;

--  ***********************************************
--      Procedure createSessionCookie
--  ***********************************************

procedure createSessionCookie(p_session_id in number) is

l_ip_address            varchar2(80);
l_server_name           varchar2(240);
l_domain                varchar2(240);
l_session_id            varchar2(150);

begin
        sendsessioncookie(p_session_id);
end;


--  ***********************************************
--      Function createSessionPrivate
--  ***********************************************
function createSessionPrivate(p_user_id     in number,
                              p_session_id  in number,
                              p_pseudo_flag in varchar2,
                              c_mode_code   in varchar2,
                              p_server_id   in varchar2 default NULL)
          return varchar2  is

l_language              varchar2(80);
l_language_code         varchar2(30);
l_date_format           varchar2(150);
l_date_language         varchar2(30);
l_numeric_characters    varchar2(30);
l_nls_sort              varchar2(30);
l_nls_territory         varchar2(30);
l_limit_time            number;
l_limit_connects        number;
l_multi_org_flag        varchar2(1);
l_org_id                varchar2(50);
l_profile_defined       boolean;
db_lang                 varchar2(512);
lang                    varchar2(255);

c_language              varchar2(30);
l_login_id              NUMBER;
l_count_resp_f          NUMBER;
l_count_resp_o          NUMBER;
l_server_host           varchar2(256);
l_node_id               number;
l_server_id             varchar2(80);
l_expired               VARCHAR2(5);

l_XSID                  varchar2(32);

l_timeout               number;
l_guest                 varchar2(30);
l_dist                  varchar2(30);
l_guest_username        varchar2(240);
l_guest_user_id         number;


cursor c1 (lang in varchar2) is
  select UTF8_DATE_LANGUAGE
    from FND_LANGUAGES
   where NLS_LANGUAGE = lang;

cursor c2 (lang in varchar2) is
  select LOCAL_DATE_LANGUAGE
    from FND_LANGUAGES
   where NLS_LANGUAGE = lang;

begin


begin

    l_server_id := p_server_id;

   if l_server_id is null
    then
    l_server_host := owa_util.get_cgi_env('SERVER_NAME');

-- Bug 3361985
--    where lower(node_name) = l_server_host;

    select node_id into l_node_id from fnd_nodes
    where lower(webhost) = l_server_host;

    else if l_server_host is NULL
     then

    select node_id into l_node_id from fnd_nodes
    where lower(node_name) = l_server_host;

     else

    select node_id into l_node_id from fnd_nodes
    where server_id = l_server_id;
    end if;
end if;

exception
    when no_data_found THEN
    l_node_id := 9999;
end;


    setUserNLS(p_user_id,
                l_language,
                l_language_code,
                l_date_format,
                l_date_language,
                l_numeric_characters,
                l_nls_sort,
                l_nls_territory,
                l_limit_time,
                l_limit_connects,
                l_org_id,
                l_timeout);



   --audit the login session
-- bug 2538912
-- If the user has only one forms resp do not audit the user
-- the forms session will do the auditing.

-- Bug 3238722 fnd_web_sec will now return the login_id
/*

                select count(*) into l_count_resp_f
                from    FND_SECURITY_GROUPS_VL fsg,
                        fnd_responsibility_vl a,
                        FND_USER_RESP_GROUPS b,
                        FND_APPLICATION fa
         where  b.user_id = p_user_id
         and    b.start_date <= sysdate
         and    (b.end_date is null or b.end_date > sysdate)
         and    b.RESPONSIBILITY_id = a.responsibility_id
         and    b.RESPONSIBILITY_application_id = a.application_id
         and    a.application_id = fa.application_id
         and    a.version in ('4')
         and    a.start_date <= sysdate
         and    (a.end_date is null or a.end_date > sysdate)
         and    b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID;

 select count(*) into l_count_resp_o
 from    FND_SECURITY_GROUPS_VL fsg,
         fnd_responsibility_vl a,
         FND_USER_RESP_GROUPS b,
         FND_APPLICATION fa
 where  b.user_id = p_user_id
 and    b.start_date <= sysdate
 and    (b.end_date is null or b.end_date > sysdate)
 and    b.RESPONSIBILITY_id = a.responsibility_id
 and    b.RESPONSIBILITY_application_id = a.application_id
 and    a.application_id = fa.application_id
 and    a.version in ('W')
 and    a.start_date <= sysdate
 and    (a.end_date is null or a.end_date > sysdate)
 and    b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID;

   if ((l_count_resp_f = 1 and l_count_resp_o = 0) = false) then

   fnd_signon.new_icx_session(p_user_id,
                               l_login_id,
                               l_expired);

   -- Bug 2833286 (so login_id will not be null for only one forms resp)
   else
   l_login_id := newLoginId;
   end if;

*/
-- Bug 3368816
 begin

    if g_p_loginID is null
    then
    fnd_signon.new_icx_session(p_user_id,
                               l_login_id,
                               l_expired);

    g_p_loginID := l_login_id;
    end if;

  end;

  -- l_XSID := FND_SESSION_MANAGEMENT.NewXSID;
   l_XSID := icx_call.encrypt3(p_session_id);

     -- Is user GUEST
    -- fnd_profile.get_specific
               -- (name_z    => 'GUEST_USER_PWD',
                -- val_z     => l_guest_username ,
                -- defined_z => l_profile_defined);
     -- Using new api to retrieve GUEST credentials.
     l_guest_username := fnd_web_sec.get_guest_username_pwd;

 l_guest_username := SUBSTR(l_guest_username,1,INSTR(l_guest_username,'/') -1);

    BEGIN
     SELECT user_id
       INTO l_guest_user_id
       FROM fnd_user
       WHERE user_name = l_guest_username;
     EXCEPTION
       WHEN no_data_found THEN
         l_guest_username := -999;
    END;

    if l_guest_user_id = p_user_id
    then
      l_guest := 'Y';
    else
      l_guest := 'N';
    end if;

     fnd_profile.get_specific
               (name_z    => 'DISTRIBUTED_ENVIRONMENT',
                val_z     => l_dist,
                defined_z => l_profile_defined);



   insert into icx_sessions (
                session_id,
                user_id,
                org_id,
                security_group_id,
                mode_code,
                nls_language,
                language_code,
                pseudo_flag,
                limit_time,
                limit_connects,
                counter,
                first_connect,
                last_connect,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                date_format_mask,
                nls_numeric_characters,
                nls_date_language,
                nls_sort,
                nls_territory,
                disabled_flag,
                node_id,
                login_id,
                MAC_KEY,
                ENC_KEY,
                XSID,
                TIME_OUT,
                GUEST,
                DISTRIBUTED)
       values (
                p_session_id,
                p_user_id,
                l_org_id,
                icx_sec.g_security_group_id,
                c_mode_code,
                l_language,
                l_language_code,
                p_pseudo_flag,
                l_limit_time,
                l_limit_connects,
                0,
                sysdate,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                l_date_format,
                l_numeric_characters,
                l_date_language,
                l_nls_sort,
                l_nls_territory,
                'N',
                l_node_id,
                g_p_loginID,
                fnd_crypto.RandomBytes(20),
                fnd_crypto.RandomBytes(32),
                l_XSID,
                l_timeout,
                l_guest,
                l_dist);


       commit;
--                l_login_id);   --mputman added login_id per 2020952


       return '0';
exception
     when dup_val_on_index then     --bug 1388903
     return -1;

  when others then
--       htp.p(SQLERRM);
         htp.p(dbms_utility.format_error_stack);
       return -1;
end;


--  ***********************************************
--      Function createSession
--  ***********************************************
-- added p_server_id  bug 2884059
function createSession(p_user_id   in number,
                       c_mode_code in varchar2,
                       c_sec_grp_id in NUMBER,
                       p_server_id in varchar2 DEFAULT NULL)
           return number is

l_session_id            number;
l_message               varchar2(80);
l_new_session_id        number;
l_server_id             varchar2(64);
l_secured_mode varchar2(1);


begin

begin
     select server_id into l_server_id from fnd_nodes
     where server_id = p_server_id;
     EXCEPTION
     WHEN no_data_found THEN
     l_server_id := '-1';
end;

  fnd_profile.get(name         => 'APPS_SECURITY_CONFIG_MAINTENANCE_MODE',
                  val          => l_secured_mode);

  if (l_secured_mode = 'Y' and p_user_id <> 6) then
    -- Don't allow creation of session from anywhere
    return -1;
  end if;

     icx_sec.g_security_group_id := c_sec_grp_id;   --mputman hosted update

    l_session_id := NewSessionId(l_new_session_id);
    l_message :=  createSessionPrivate( p_user_id     => p_user_id,
                                        p_server_id   => l_server_id,
                                        p_session_id  => l_session_id,
                                        p_pseudo_flag => 'N',
                                        c_mode_code   => nvl(c_mode_code,'115P')) ;
    if l_message = '0' then

       newSessionRaiseEvent(p_user_id,l_session_id);
       return l_session_id;
    else
       return -1;
    end if;

exception
  when others then
--      htp.p(SQLERRM);
        htp.p(dbms_utility.format_error_stack);
       return -1;
end;

--  ***********************************************
--      Function createTransaction
--  ***********************************************

function createTransaction(p_session_id in number,
                           p_resp_appl_id in number,
                           p_responsibility_id in number,
                           p_security_group_id in number,
                           p_menu_id in number,
                           p_function_id in number,
                           p_function_type in varchar2,
                           p_page_id in number)
                           return number is

l_transaction_id           number;

begin
--  select icx_transactions_s.nextval
--    into l_transaction_id
--    from sys.dual;
 -- icx_transactions_s.nextval moved directly into insert statment for performance bug# 2494109 --mputman

  insert into icx_transactions (
    TRANSACTION_ID,
    SESSION_ID,
    RESPONSIBILITY_APPLICATION_ID,
    RESPONSIBILITY_ID,
    SECURITY_GROUP_ID,
    MENU_ID,
    FUNCTION_ID,
    FUNCTION_TYPE,
    PAGE_ID,
    LAST_CONNECT,
    DISABLED_FLAG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE)
  values (
    icx_transactions_s.nextval,
    p_session_id,
    p_resp_appl_id,
    p_responsibility_id,
    p_security_group_id,
    p_menu_id,
    p_function_id,
    p_function_type,
    p_page_id,
    sysdate,
    'N',
    icx_sec.g_user_id,
    sysdate,
    icx_sec.g_user_id,
    sysdate)
    returning transaction_id into l_transaction_id;

  return l_transaction_id;

exception
  when others then
--       htp.p(SQLERRM);
         htp.p(dbms_utility.format_error_stack);
       return -1;
end;
--  ***********************************************
--      Procedure SeverLevel
--  ***********************************************
procedure ServerLevel (p_server_id   in varchar2 default NULL) is

l_node_id               number;
l_server_id             varchar2(240);
l_server_host           varchar2(256);
l_result                boolean;
x_prof                  varchar2(240);

l_user_id     number;
l_agent       varchar2(240);
l_profile_defined  varchar2(240);

 begin
begin

--    l_result := icx_sec.validateSession;

    l_server_id := p_server_id;

    if l_server_id is null
    then
    l_server_host := owa_util.get_cgi_env('SERVER_NAME');

-- Bug 3361985
-- where lower(node_name) = (l_server_host);

    select node_id into l_node_id from fnd_nodes
    where lower(webhost) = l_server_host;

    else if l_server_host is NULL
    then

    select node_id into l_node_id from fnd_nodes
    where lower(node_name) = (l_server_host);


    else

    select node_id into l_node_id from fnd_nodes
    where server_id = l_server_id;
    end if;
end if;

exception
    when no_data_found THEN
    l_node_id := 9999;
end;
          FND_GLOBAL.APPS_INITIALIZE(user_id => icx_sec.g_user_id,
                           resp_id => icx_sec.g_responsibility_id,
                           resp_appl_id => icx_sec.g_resp_appl_id,
                           server_id => l_node_id);


end;

--  ***********************************************
--      Procedure removeTransaction
--  ***********************************************

procedure removeTransaction(p_transaction_id in number) is

begin

  update ICX_TRANSACTIONS
  set    DISABLED_FLAG = 'Y'
  where  TRANSACTION_ID = p_transaction_id;

exception
  when others then
--       htp.p(SQLERRM);
         htp.p(dbms_utility.format_error_stack);
end;

--  ***********************************************
--      Function NewSession
--  ***********************************************

function NewSession( user_info  in fnd_user%rowtype,
                     c_user_name        in varchar2,
                     c_password         in varchar2,
                     n_session_id       out NOCOPY number,
                     c_validate_only    in varchar2,
                     c_mode_code        in varchar2)
                        return varchar2 is

l_session_id            number;
l_message               varchar2(80);
l_new_session_id        number;
l_server_id             varchar2(64);
v_cookie                owa_cookie.cookie;

begin

   l_session_id := NewSessionId(l_new_session_id);

    n_session_id := l_session_id;

--start bug 3154705
-- Only expire the cookie if it already exists

    v_cookie := owa_cookie.get('WF_WORKLIST_MODE');
    owa_util.mime_header('text/html', FALSE);

    IF (v_cookie.num_vals > 0) THEN

    owa_cookie.send(name=>'WF_WORKLIST_MODE', value=>'-1', expires=>'', path=>'/');-- mputman added for 1903545
  end if;

--end bug 3154705

    sendsessioncookie(l_session_id);  -- mputman reordered, ICX cookie must be last for FWK

    owa_util.http_header_close;

    l_message :=  createSessionPrivate( p_user_id     => user_info.user_id,
                                        p_server_id   => l_server_id,
                                        p_session_id  => l_session_id,
                                        p_pseudo_flag => 'N',
                                        c_mode_code   => c_mode_code) ;

    if l_message = '0' then
    --htp.p('####NSRE####');--debug mputman
       newSessionRaiseEvent(user_info.user_id,l_session_id);--mputman 1513025
    --   htp.p(' ####post NSRE####');--debug mputman
       return l_session_id;
    else
       return -1;
    end if;

exception
   when others then
--       htp.p(SQLERRM);
         htp.p(dbms_utility.format_error_stack);
       return -1;
end;

--  ***********************************************
--      function PseudoSession
--  ***********************************************

function PseudoSession (n_session_id  out NOCOPY number,
                        IncludeHeader in boolean) return varchar2
is

l_session_id            number;
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);
c_date_format           varchar2(50);
l_language              varchar2(80);
l_language_code         varchar2(30);
l_new_session_id        number;
l_server_id             varchar2(64);

begin

    l_session_id := NewSessionId(l_new_session_id);

    n_session_id := l_session_id;

if (IncludeHeader) then
    owa_util.mime_header('text/html', FALSE);
end if;

    sendsessioncookie(l_session_id);

if (IncludeHeader) then
    owa_util.http_header_close;
end if;

    return createSessionPrivate(p_user_id     => -1,
                                p_server_id   => l_server_id,
                                p_session_id  => l_session_id,
                                p_pseudo_flag => 'Y',
                                c_mode_code   => 'SLAVE') ;

exception
   when others then
      fnd_message.set_name('ICX','ICX_DATA_INCORRECT');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
      c_login_msg := fnd_message.get;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');

      insert into icx_failures
         (user_name,password,failure_code,failure_date,
          created_by, creation_date, last_updated_by,
          last_update_date, last_update_login)
      values
         ('-1','-1','ICX_DATA_INCORRECT',sysdate,
          '-1', sysdate, '-1', sysdate, '-1');
      return '-1';
end;


--  ***********************************************
--      function PseudoSession
--  ***********************************************

function validatePlugSession(p_plug_id        in number,
                             p_session_id     in number,
                             p_update_context in varchar2)
                            return BOOLEAN is

l_session_id        number;
l_resp_appl_id      number;
l_security_group_id number;
l_responsibility_id number;
l_menu_id           number;
l_entry_sequence    number;
l_function_id       number;
l_org_id            number;
l_multi_org_flag    varchar2(1);
l_profile_defined   boolean;
l_validate          boolean;
l_wf_cookie         owa_cookie.cookie;

begin

    if p_session_id is null
    then
        l_session_id := getsessioncookie;
    else
        l_session_id := p_session_id;
IF icx_sec.g_query_set = -1 THEN
select HOME_URL,
       WEBMASTER_EMAIL,
       QUERY_SET,
       MAX_ROWS,
       SESSION_COOKIE_DOMAIN,       --mputman added 1574527
       SESSION_COOKIE_NAME,          --mputman added 1574527
       WINDOW_COOKIE_NAME

into   icx_sec.g_home_url,
       icx_sec.g_webmaster_email,
       icx_sec.g_query_set,
       icx_sec.g_max_rows,
       icx_sec.g_session_cookie_domain,  --mputman added 1574527
       icx_sec.g_session_cookie_name,     --mputman added 1574527
       icx_sec.g_window_cookie_name
from   ICX_PARAMETERS;
END IF; --mputman added 1574527

        if (icx_sec.g_session_cookie_name is null) then
           icx_sec.g_session_cookie_name := FND_WEB_CONFIG.DATABASE_ID;
        end if;

    end if;

    select RESPONSIBILITY_ID, MENU_ID, ENTRY_SEQUENCE
    into   l_responsibility_id, l_menu_id, l_entry_sequence
    from   ICX_PAGE_PLUGS
    where  PLUG_ID = p_plug_id;

    if l_responsibility_id = -1
    then
        select FUNCTION_ID
        into   l_function_id
        from   FND_FORM_FUNCTIONS
        where  FUNCTION_ID = l_entry_sequence
        and    FUNCTION_NAME = 'ICX_NAVIGATE_PLUG';

        l_responsibility_id := '';
        l_function_id := '';
    else
        select ipe.RESPONSIBILITY_APPLICATION_ID,
               ipe.SECURITY_GROUP_ID,
               ipe.RESPONSIBILITY_ID,
               fff.FUNCTION_ID
        into   l_resp_appl_id,
               l_security_group_id,
               l_responsibility_id,
               l_function_id
        from   FND_FORM_FUNCTIONS fff,
               FND_MENU_ENTRIES fme,
               ICX_PAGE_PLUGS ipe
        where  ipe.PLUG_ID = p_plug_id
        and    fme.MENU_ID = ipe.MENU_ID
        and    fme.ENTRY_SEQUENCE = ipe.ENTRY_SEQUENCE
        and    fme.function_id = fff.function_id;
    end if;

    l_validate := validateSessionPrivate(c_session_id => l_session_id,
                           c_resp_appl_id => l_resp_appl_id,
                           c_security_group_id => l_security_group_id,
                           c_responsibility_id => l_responsibility_id,
                           c_function_id => l_function_id,
                           c_update => FALSE);

    if l_validate and p_update_context = 'Y'
    then
        l_org_id := '';

        select multi_org_flag
        into   l_multi_org_flag
        from   fnd_product_groups
        where  rownum < 2;

        if l_multi_org_flag = 'Y'
        then
           fnd_profile.get_specific(
                name_z                  => 'ORG_ID',
                responsibility_id_z     => l_responsibility_id,
                application_id_z        => l_resp_appl_id,
                val_z                   => l_org_id,
                defined_z               => l_profile_defined);
        end if;

        update  ICX_SESSIONS
        set     RESPONSIBILITY_APPLICATION_ID = l_resp_appl_id,
                RESPONSIBILITY_ID = l_responsibility_id,
                SECURITY_GROUP_ID = l_security_group_id,
                ORG_ID = l_org_id,
                FUNCTION_ID = l_function_id,
                LAST_CONNECT = sysdate,
                COUNTER = COUNTER +1
        where   SESSION_ID = l_session_id;

        commit;
    end if; -- p_update_context = 'Y'

    return l_validate;
end;


--  ***********************************************
--      function setSessionPublic
--  ***********************************************


function setSessionPublic(p_ticket in varchar2) return BOOLEAN is

l_success boolean := FALSE;

begin

  icx_sec.g_session_id := to_number(icx_call.decrypt3(p_ticket));

  setSessionPrivate(p_session_id => icx_sec.g_session_id,
                       p_success => l_success);

  if (l_success)
  then
      return TRUE;
  else
      return FALSE;
  end if;

exception
        when others then
--                htp.p(SQLERRM);
                  htp.p(dbms_utility.format_error_stack);
                return FALSE;
end;

--  ***********************************************
--      procedure setSessionPrivate
--  ***********************************************

procedure setSessionPrivate( p_session_id   in  number,
                             p_success      out NOCOPY boolean )
is

begin

  select NLS_LANGUAGE,
         LANGUAGE_CODE, DATE_FORMAT_MASK,
         NLS_NUMERIC_CHARACTERS, NLS_DATE_LANGUAGE,
         NLS_SORT, NLS_TERRITORY,
         USER_ID,
         RESPONSIBILITY_APPLICATION_ID,
         SECURITY_GROUP_ID,
         RESPONSIBILITY_ID
         into
         icx_sec.g_language,
         icx_sec.g_language_code, icx_sec.g_date_format,
         icx_sec.g_numeric_characters, icx_sec.g_date_language,
         icx_sec.g_nls_sort, icx_sec.g_nls_territory,
         icx_sec.g_user_id,
         icx_sec.g_resp_appl_id,
         icx_sec.g_security_group_id,
         icx_sec.g_responsibility_id
   from  ICX_SESSIONS
  where SESSION_ID = p_session_id;

  setSessionPrivate(icx_sec.g_user_id,
                    icx_sec.g_responsibility_id,
                    icx_sec.g_resp_appl_id,
                    icx_sec.g_security_group_id,
                    icx_sec.g_date_format,
                    icx_sec.g_language,
                    icx_sec.g_date_language,
                    icx_sec.g_numeric_characters,
                    icx_sec.g_nls_sort,
                    icx_sec.g_nls_territory);
exception
        when others
        then
--           htp.p(SQLERRM);
             htp.p(dbms_utility.format_error_stack);
           p_success := FALSE;
end;


procedure setSessionPrivate( p_user_id           in number,
                            p_responsibility_id  in number,
                            p_resp_appl_id       in number,
                            p_security_group_id  in number,
                            p_date_format        in varchar2,
                            p_language           in varchar2,
                            p_date_language      in varchar2,
                            p_numeric_characters in varchar2,
                            p_nls_sort           in varchar2,
                            p_nls_territory      in varchar2) is

  c_date_format           varchar2(240);
  c_nls_language          varchar2(240);
  c_date_language       varchar2(240);
  c_numeric_characters  varchar2(240);
  c_nls_sort              varchar2(240);
  c_nls_territory         varchar2(240);
  x_session               NUMBER;
  c_node_id               number;

  /*
  cursor nls is
    select parameter, value
    from   v$nls_parameters
    where  parameter in ('NLS_LANGUAGE','NLS_DATE_LANGUAGE','NLS_SORT',
                         'NLS_TERRITORY','NLS_DATE_FORMAT',
                         'NLS_NUMERIC_CHARACTERS')
    order by parameter;
    */

begin

        select node_id into c_node_id from icx_sessions
        where  user_id = p_user_id and session_id = g_session_id;

       -- changed call to fnd_global.initialize to pass login_id 2020952
       -- Bug 2864081
       -- changed call to fnd_global.initialize to pass server_id
       fnd_global.INITIALIZE(session_id => x_session,
                      user_id => p_user_id,
                      resp_id => p_responsibility_id,
                      resp_appl_id => p_resp_appl_id,
                      security_group_id => p_security_group_id,
                      site_id => -1,
                      login_id => icx_sec.g_login_id,
                      conc_login_id => -1,
                      prog_appl_id => icx_sec.g_prog_appl_id,
                      conc_program_id => -1,
                      conc_request_id => -1,
                      server_id => c_node_id,
                      conc_priority_request => -1);
           --g_prog_appl_id defaults to -1... if -999 fnd_global will verify user_id - resp_id relationship



  /*
  fnd_global.apps_initialize(user_id => p_user_id,
                             resp_id => p_responsibility_id,
                             resp_appl_id => p_resp_appl_id,
                             security_group_id => p_security_group_id);
  */

  --  *******************************************
  --  Here, we need to alter the DATABASE session
  --  We want the database to return data in the
  --  appropriate language for the user
  --  *******************************************
 /*  removed by mputman for 1574527
  c_date_format  := ''''||p_date_format||'''';
  c_date_language := ''''||p_date_language||'''';
  c_numeric_characters := ''''||p_numeric_characters||'''';
  c_nls_sort := ''''||p_nls_sort||'''';
  c_nls_territory := ''''||p_nls_territory||'''';
*/
--  for n in nls loop    -- mputman removed 1574527

    if  p_language is not null
    and nvl(g_language_c,'XXXXX') <> p_language
    then
       c_nls_language := p_language;
       --c_nls_language := ''''||p_language||'''';
       --dbms_session.set_nls('NLS_LANGUAGE'   , c_nls_language);
       g_language_c:=p_language;

    end if;

    if p_date_language is not null
    and nvl(g_date_language_c,'XXXXX') <> p_date_language
    then
       c_date_language := p_date_language;
       --c_date_language := ''''||p_date_language||'''';
       --dbms_session.set_nls('NLS_DATE_LANGUAGE', c_date_language);
       g_date_language_c:= p_date_language;

    end if;

    if p_nls_sort is not null
    and nvl(g_nls_sort_c,'XXXXX') <> p_nls_sort
    then
       c_nls_sort := p_nls_sort;
       --c_nls_sort := ''''||p_nls_sort||'''';
      --dbms_session.set_nls('NLS_SORT', c_nls_sort);
      g_nls_sort_c:= p_nls_sort;


    end if;

    if p_nls_territory is not null
    and nvl(g_nls_territory_c,'XXXXX') <> p_nls_territory
    then
       c_nls_territory := p_nls_territory;
       --c_nls_territory := ''''||p_nls_territory||'''';
       --dbms_session.set_nls('NLS_TERRITORY'  , c_nls_territory);
       g_nls_territory_c := p_nls_territory;


    end if;


    if p_date_format is not null
    and nvl(g_date_format_c,'XXXXX') <> p_date_format
    then
       c_date_format  := p_date_format;
       --c_date_format  := ''''||p_date_format||'''';
       --dbms_session.set_nls('NLS_DATE_FORMAT', c_date_format);
       g_date_format_c := p_date_format;


    end if;

    if p_numeric_characters IS NOT NULL
    and nvl(g_numeric_characters_c,'XXXXX') <> p_numeric_characters
    then
      --c_numeric_characters := p_numeric_characters;
      c_numeric_characters :='.,';
      --dbms_session.set_nls('NLS_NUMERIC_CHARACTERS', '''.,''');
      g_numeric_characters_c := p_numeric_characters;

    end if;

    FND_GLOBAL.set_nls_context(
         p_nls_language => c_nls_language,
         p_nls_date_format => c_date_format,
         p_nls_date_language => c_date_language,
         p_nls_numeric_characters => c_numeric_characters,
         p_nls_sort => c_nls_sort,
         p_nls_territory =>c_nls_territory); -- mputman changed to use FND API for performance and consist.


    /* commented out because javascript cannot handle multiradix
    if n.parameter = 'NLS_NUMERIC_CHARACTERS'
    and p_numeric_characters is not null
    and n.value <> p_numeric_characters
    then
      dbms_session.set_nls('NLS_NUMERIC_CHARACTERS', c_numeric_characters);
    end if;
    */

 -- end loop;  -- mputman removed for 1574527


exception
        when others
        then
--           htp.p(SQLERRM);
             htp.p(dbms_utility.format_error_stack);

end setSessionPrivate;

-- **************************************************
--  function validateSessionPrivate
-- **************************************************
function validateSessionPrivate( c_session_id         in number,
                                 c_function_code      in varchar2,
                                 c_validate_only      in varchar2,
                                 c_commit             in boolean,
                                 c_update             in boolean,
                                 c_responsibility_id  in number,
                                 c_function_id        in number,
                                 c_resp_appl_id       in number,
                                 c_security_group_id  in number,
                                 c_validate_mode_on   in varchar2,
                                 c_transaction_id    in number)
                                return BOOLEAN
is
        c_user_name
                varchar2(30);
        c_user_password         varchar2(30);
        c_func_name             varchar2(30);
        e_exceed_limit          exception;
        e_no_function_id        exception;
        e_session_invalid       exception;
        n_limit_connects        number;
        n_limit_time            number;
        n_counter               number;
        c_disabled_flag         varchar2(1);
        c_pseudo_session        varchar2(1);
        c_text                  varchar2(80);
        c_display_error         varchar2(240);
        c_error_msg             varchar2(2000);
        c_login_msg             varchar2(2000);
        n_error_num             number;
        l_string                varchar2(100);
        d_first_connect_time    date;
        c_org_id                number;
        l_multi_org_flag        varchar2(30);
        l_profile_defined       boolean;
        l_session_mode          varchar2(30);
        c_date_format           varchar2(240);
        c_nls_language          varchar2(240);
        l_prefix                varchar2(30);
        l_OA_HTML               varchar2(80);
        l_OA_MEDIA              varchar2(80);
        l_style_sheet           varchar2(80);
        l_last_connect          DATE;--mputman added 1755317
        l_session_timeout       NUMBER;--mputman added 1755317
        l_recreate_code          VARCHAR2(600);--mputman added timeout
        l_url                    VARCHAR2(600); --mputman added for timeout
        new_flag                 VARCHAR2(1);--mputman added for timeout
        attempt_limit            NUMBER;--mputman added for timeout
        l_url2                    VARCHAR2(600); --mputman added for timeout
        l_portal_url              VARCHAR2(600); --mputman added for timeout 2
        l_home_url                VARCHAR2(600);
        numeric_disabled_flag    NUMBER;
        l_server_name VARCHAR2(200); --MPUTMAN added for 2214199
        l_domain_count NUMBER;  --MPUTMAN added for 2214199
        l_browser VARCHAR2(400);  --MPUTMAN added for 2214199
        l_browser_is_IE BOOLEAN;  --MPUTMAN added for 2214199
        l_user_id                NUMBER;
        l_anon_name              VARCHAR2(400);


begin
  if c_session_id is null -- don't use nvl jsp doesn't like it
  then
      icx_sec.g_session_id := getsessioncookie;
  else
      icx_sec.g_session_id := c_session_id;
  end if;

  icx_sec.g_transaction_id := c_transaction_id;
  -- added last_connect into the select for 1755317 mputman
  select NLS_LANGUAGE, LANGUAGE_CODE, DATE_FORMAT_MASK,
         NLS_NUMERIC_CHARACTERS, NLS_DATE_LANGUAGE,
         NLS_SORT, NLS_TERRITORY,
         LIMIT_CONNECTS, LIMIT_TIME,
         FIRST_CONNECT, COUNTER,
         nvl(DISABLED_FLAG,'N'), nvl(PSEUDO_FLAG,'N'),
         USER_ID,
         nvl(c_resp_appl_id,RESPONSIBILITY_APPLICATION_ID),
         nvl(c_security_group_id,SECURITY_GROUP_ID),
         nvl(c_responsibility_id,RESPONSIBILITY_ID),
         nvl(c_function_id,FUNCTION_ID),
         FUNCTION_TYPE,
         MENU_ID,
         PAGE_ID,
         ORG_ID, MODE_CODE, LAST_CONNECT,
         login_id  --mputman added 2020952
  into   icx_sec.g_language, icx_sec.g_language_code, icx_sec.g_date_format,
         icx_sec.g_numeric_characters, icx_sec.g_date_language,
         icx_sec.g_nls_sort,icx_sec.g_nls_territory,
         n_limit_connects, n_limit_time,
         d_first_connect_time,n_counter,
         c_disabled_flag, c_pseudo_session,
         icx_sec.g_user_id,
         icx_sec.g_resp_appl_id,
         icx_sec.g_security_group_id,
         icx_sec.g_responsibility_id,
         icx_sec.g_function_id,
         icx_sec.g_function_type,
         icx_sec.g_menu_id,
         icx_sec.g_page_id,
         c_org_id, icx_sec.g_mode_code,
         l_last_connect,
         icx_sec.g_login_id  --mputman added 2020952

  from  ICX_SESSIONS
  where SESSION_ID = icx_sec.g_session_id;

  if c_transaction_id is not null
  then

    select TRANSACTION_ID,
           nvl(c_resp_appl_id,RESPONSIBILITY_APPLICATION_ID),
           nvl(c_responsibility_id,RESPONSIBILITY_ID),
           nvl(c_security_group_id,SECURITY_GROUP_ID),
           MENU_ID,
           nvl(c_function_id,FUNCTION_ID),
           FUNCTION_TYPE,
           PAGE_ID
    into   icx_sec.g_transaction_id,
           icx_sec.g_resp_appl_id,
           icx_sec.g_responsibility_id,
           icx_sec.g_security_group_id,
           icx_sec.g_menu_id,
           icx_sec.g_function_id,
           icx_sec.g_function_type,
           icx_sec.g_page_id
    from   ICX_TRANSACTIONS
    where  TRANSACTION_ID = c_transaction_id
    and    SESSION_ID = icx_sec.g_session_id
    and    DISABLED_FLAG <> 'Y'; --reordered select for bug #2389169 mputman

  end if;

  if icx_sec.g_language_code is null
  then
     select  language_code
     into    icx_sec.g_language_code
     from    fnd_languages
     where   nls_language = icx_sec.g_language;
  end if;

         -- **************************************************
         -- This section handles the multi-org implemenation
         -- **************************************************

-- htp.p('DEBUG session_id='||icx_sec.g_session_id||' user_id='||icx_sec.g_user_id||' responsibility_id='||icx_sec.g_responsibility_id||' resp_appl_id='||icx_sec.g_resp_appl_id||' security_group_id='||icx_sec.g_security_group_id);

-- htp.p('DEBUG function_id='||icx_sec.g_function_id);

  -- Allow easier performance tuning
/* Request to remove aalomari 16-NOV-1999
  DBMS_APPLICATION_INFO.SET_MODULE(
       module_name => icx_sec.g_function_id,
       action_name => 'Self Service');
*/

  --  *******************************************
  --  Here, we need to alter the DATABASE session
  --  We want the database to return data in the
  --  appropriate language for the user
  --  *******************************************

setSessionPrivate(icx_sec.g_user_id,
                    icx_sec.g_responsibility_id,
                              icx_sec.g_resp_appl_id,
                    icx_sec.g_security_group_id,
                              icx_sec.g_date_format,
                    icx_sec.g_language,
                              icx_sec.g_date_language,
                    icx_sec.g_numeric_characters,
                    icx_sec.g_nls_sort,
                    icx_sec.g_nls_territory);

/* nlbarlow 1574527
  fnd_profile.get(name => 'ICX_OA_HTML',
                   val => l_OA_HTML);

  if l_OA_HTML is not null
  then
    icx_sec.g_OA_HTML := l_OA_HTML;
  end if;

  fnd_profile.get(name => 'ICX_OA_MEDIA',
                   val => l_OA_MEDIA);

  if l_OA_MEDIA is not null
  then
    icx_sec.g_OA_MEDIA := l_OA_MEDIA;
  end if;

  fnd_profile.get(name => 'ICX_STYLE_SHEET',
                   val => l_style_sheet);

  if l_style_sheet is not null
  then
    icx_sec.g_style_sheet := l_style_sheet;
  end if;
*/

  fnd_profile.get(name => 'ICX_PREFIX',
                   val => l_prefix);

  -- GK: Bug 1622218
  -- There is an extra slash before OA_HTML when l_prefix is null
  -- which causes jsps to fail.
  -- ie: http://ap814sun.us.oracle.com:7732//OA_HTML/....
  if (l_prefix IS NOT NULL) then

     icx_sec.g_OA_HTML := l_prefix||'/OA_HTML';
     icx_sec.g_OA_MEDIA := l_prefix||'/OA_MEDIA';

  else

     icx_sec.g_OA_HTML := 'OA_HTML';
     icx_sec.g_OA_MEDIA := 'OA_MEDIA';

  end if;


  if icx_sec.g_mode_code in ( '115J', '115P', '115X', 'SLAVE')
  then
     icx_cabo.g_base_href := FND_WEB_CONFIG.WEB_SERVER;
     icx_cabo.g_plsql_agent := icx_plug_utilities.getPLSQLagent;
  else
     icx_cabo.g_base_href := '';
     icx_cabo.g_plsql_agent := '';
  end if;

  if icx_sec.g_menu_id is null then
     icx_cabo.g_display_menu_icon := FALSE;
  else
     icx_cabo.g_display_menu_icon := TRUE;
  end if;

  if c_org_id is not null
  then
    icx_sec.g_org_id := c_org_id;
    fnd_client_info.set_org_context(c_org_id);
  else
    select multi_org_flag
    into   l_multi_org_flag
    from   fnd_product_groups
    where  rownum < 2;

    if l_multi_org_flag = 'Y'
    then
      /* 3219471 nlbarlow replaced get_specific
      fnd_profile.get_specific(
          name_z                  => 'ORG_ID',
          responsibility_id_z     => icx_sec.g_responsibility_id,
          application_id_z        => icx_sec.g_resp_appl_id,
          val_z                   => icx_sec.g_org_id,
          defined_z               => l_profile_defined);
      */
      fnd_profile.get(name => 'ORG_ID',
                      val  => icx_sec.g_org_id);
    end if;
  end if;

  if icx_sec.g_mode_code in ( 'WEBAPPS', '115J', '115P', '115X')
  then

    if (c_disabled_flag = 'Y') then
      raise e_session_invalid;
    end if;

  if c_validate_mode_on = 'Y'
  then

    if (n_counter + 1) > n_limit_connects
    then
      raise e_exceed_limit;
    end if;

    -- begin additions for 1755317 mputman

    /* 3219471 nlbarlow replaced get_specific
    fnd_profile.get_specific(name_z       => 'ICX_SESSION_TIMEOUT',
                             application_id_z => g_resp_appl_id,
                             responsibility_id_z => icx_sec.g_responsibility_id,                             user_id_z    => icx_sec.g_user_id,
                             val_z        => l_session_timeout ,
                             defined_z    => l_profile_defined);
    */
    fnd_profile.get(name => 'ICX_SESSION_TIMEOUT',
                    val  => l_session_timeout);

    IF (l_session_timeout ) IS NOT NULL AND (l_session_timeout > 0) THEN
      IF (((SYSDATE-l_last_connect)*24*60)> l_session_timeout ) THEN
         RAISE e_exceed_limit;
      END IF;  --end additions for 1755317 mputman
    END IF;
    IF ( d_first_connect_time + n_limit_time/24 < sysdate) THEN
       raise e_exceed_limit;
    END IF;

  end if; -- c_validate_mode_on = 'Y'

  end if; -- icx_sec.g_mode_code = 'WEBAPPS'

        if (c_pseudo_session = 'N')
        then
     if c_function_code is not null
           then
                if (not FND_FUNCTION.TEST(c_function_code))
                then

                  --IF (NOT anonFunctionTest(c_function_id)) THEN

                    raise e_no_function_id;
                  --END IF;
                end if;
           elsif icx_sec.g_function_id is not null
           then
                          if (not FND_FUNCTION.TEST_ID(icx_sec.g_function_id))
                          then

                  --IF (NOT anonFunctionTest(icx_sec.g_function_id)) THEN
                    --SKAUSHIK
                    --NULL;
                    raise e_no_function_id;
                 -- END IF;
                end if;
     end if;

        end if;

        if c_update
        then
            update icx_sessions
            set    last_connect  = sysdate,
                   counter = counter + 1
            where  session_id = icx_sec.g_session_id;

            if c_commit
            then
                commit;
            end if;
        end if;

        return TRUE;

exception
        when e_session_invalid
        then
           if c_validate_only = 'N'
           then
--              fnd_message.set_name('ICX','ICX_SESSION_FAILED');
--              c_error_msg := fnd_message.get;
--              fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
--              c_login_msg := fnd_message.get;

                fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
                c_login_msg := fnd_message.get;
                c_error_msg := dbms_utility.format_error_stack;

              if g_session_id is not null
              then
                 update icx_sessions
                    set disabled_flag = 'Y'
                  where session_id = g_session_id;
                 COMMIT; -- mputman added 1574527
              end if;

              OracleApps.displayLogin(c_login_msg||' '||c_error_msg,'IC','Y');
              return FALSE;
           else
              fnd_message.set_name('ICX','ICX_SESSION_FAILED');
              c_error_msg := fnd_message.get;
              g_validation_error := substr(c_error_msg,1,240);
              return FALSE;
           end if;

        when e_exceed_limit
        then
           if c_validate_only = 'N'
           then
              fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
              c_error_msg := fnd_message.get;
              fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
              c_login_msg := fnd_message.get;
              IF g_user_id IS NOT NULL THEN
                 SELECT user_name
                    INTO c_user_name
                     FROM fnd_user
                    WHERE user_id=g_user_id;

              END IF;

              --removed portal support and moved it to oracleapps.displaylogin mputman 2053850
              IF (c_user_name IS NOT NULL) AND (g_session_id IS NOT NULL) THEN
                 l_recreate_code:=icx_call.encrypt(g_session_id||'*'||c_user_name||'**]');

                 l_url := FND_WEB_CONFIG.TRAIL_SLASH(fnd_profile.value('APPS_WEB_AGENT'));
                 l_url := l_url||'OracleApps.displayLogin?recreate='||l_recreate_code;
                  -- this fix isnt adequately tested. Will implement in later patch after testing
                 --begin fix for 2214199
                 /*
                 l_browser := owa_util.get_cgi_env('HTTP_USER_AGENT');
                 IF (instrb(l_browser,'MSIE')>0) THEN
                    l_browser_is_IE := TRUE;
                 ELSE
                    l_browser_is_IE := FALSE;
                 END IF;
                 IF l_browser_is_IE THEN
                   l_server_name := owa_util.get_cgi_env('SERVER_NAME');
                   l_domain_count := instr(l_server_name,'.',-1,2);
                   if l_domain_count > 0
                       then
                       l_domain_count := instr(l_server_name,'.',1,1);
                       l_server_name := substr(l_server_name,l_domain_count,length(l_server_name));
                       l_domain_count := instr(l_server_name,'.',-1,3);
                       IF  l_domain_count > 0 THEN
                          l_server_name := substr(l_server_name,l_domain_count,length(l_server_name));
                          END IF;--SECOND domain count
                          end if;--FIRST domain count
                          --l_server_name now holds the domain value.
                          END IF;--l_browser_is_IE
                       IF ((instr(l_server_name,'.',1,1))=1) THEN
                         l_server_name:=substr(l_server_name,2);
                       END IF;

                 --end fix for 2214199
                  */-- mputman

                 owa_util.mime_header('text/html', TRUE); -- added to prevent login loop 2065270 mputman
                 htp.p('<meta http-equiv="Expires" content="-1">');-- added to prevent login loop 2065270 mputman
                 htp.htmlOpen;
                   --part of 2214199 .. not ready to be released.
                   /*
                 IF l_browser_is_IE THEN
                    htp.p('<script>
                           document.domain="'||l_server_name||'"
                           </script>');
                 END IF;
                  */-- mputman
                 htp.p('<script>
                       var login_window = new Object();
                       login_window.open = false;
                       function icx_login_window(mode, url, name){
                       if (mode == "WWK") {
                       attributes = "status=yes,resizable=yes,scrollbars=yes,menubar=no,toolbar=no";
                       login_window.win = window.open(url, "login_window", attributes);
                       if (login_window.win != null){
                       if (login_window.win.opener == null)
                       login_window.win.opener = self;
                       login_window.win.focus();
                       }
                       }
                       else {
                       top.location = url;
                       };
                       };');


   fnd_profile.get_specific(name_z       => 'APPS_SSO',
             user_id_z    => icx_sec.g_user_id,
             val_z        => l_portal_url,
             defined_z    => l_profile_defined);
                 IF (nvl(l_portal_url,'SSWA') = 'PORTAL') OR
                    (nvl(l_portal_url,'SSWA') = 'SSO_SDK')   THEN
                    htp.p('icx_login_window("WWW","'||l_url||'","_Login_");
                          </script>');

                 ELSE --profile option is null

--Bug 3816417 changed below WWK to WWW

                    htp.p('icx_login_window("WWW","'||l_url||'","_Login_");
                             </script>');
                 END IF;

                 htp.htmlClose;
              ELSE
                 OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
              END IF; --recreate

              return FALSE;
           else
              fnd_message.set_name('ICX','ICX_SESSION_FAILED');
              c_error_msg := fnd_message.get;
              g_validation_error := substr(c_error_msg,1,240);
              return FALSE;
           end if;

        when e_no_function_id
        then
      if c_validate_only = 'N' then
         fnd_profile.get(name    => 'APPS_PORTAL',
                        val     =>l_portal_url);
         IF l_portal_url IS NOT NULL THEN
         --portal instance.. direct through SSO
           -- fnd_profile.get(name    => 'GUEST_USER_PWD',
                           -- val     => l_anon_name);
           -- Using new api to retrieve GUEST credentials.
           l_anon_name := fnd_web_sec.get_guest_username_pwd;
           l_anon_name  := SUBSTR(l_anon_name, 1, INSTR(l_anon_name, '/') -1);
           BEGIN
           SELECT user_id
              INTO l_user_id
              FROM fnd_user
              WHERE user_name = l_anon_name;
              EXCEPTION
              WHEN no_data_found THEN
                l_user_id := -999;
           END;

           IF (l_user_id = icx_sec.g_user_id) THEN
              --this session needs conversion to authenticated
             OracleSSWA.convertSession;

             RETURN FALSE;
           END IF; -- an anonymous user
         ELSE -- not portal
           -- fnd_profile.get(name    => 'GUEST_USER_PWD',
                           -- val     => l_anon_name);
           -- Using new api to retrieve GUEST credentials.
           l_anon_name := fnd_web_sec.get_guest_username_pwd;

l_anon_name  := SUBSTR(l_anon_name, 1, INSTR(l_anon_name, '/') -1);

           BEGIN
           SELECT user_id
              INTO l_user_id
              FROM fnd_user
              WHERE user_name = l_anon_name;
              EXCEPTION
              WHEN no_data_found THEN
                l_user_id := -999;
           END;


           IF (l_user_id = icx_sec.g_user_id) THEN
              --this session needs conversion to authenticated
             OracleApps.convertSession(icx_call.encrypt(icx_sec.g_session_id||'*'||
                                                        icx_sec.g_resp_appl_id||'*'||
                                                        icx_sec.g_responsibility_id||'*'||
                                                        icx_sec.g_security_group_id||'*'||
                                                        icx_sec.g_function_id||'**]'));

             RETURN FALSE;
           END IF; -- an anonymous user

         END IF; -- portal profile defined
         --let normal failure occur.
              n_error_num := SQLCODE;
              c_error_msg := SQLERRM;
              select substr(c_error_msg,12,512) into c_display_error from dual;
              icx_util.add_error(c_display_error);
              icx_admin_sig.error_screen(c_display_error);

--           fnd_message.set_name('ICX','ICX_DATA_INCORRECT');
--              fnd_message.set_name('ICX','ICX_INVALID_FUNCTION');
--              c_error_msg := fnd_message.get;
--              fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
--              c_login_msg := fnd_message.get;

              if g_session_id is not null
              then
                 update icx_sessions
                    set disabled_flag = 'Y'
                  where session_id = g_session_id;
                 COMMIT; -- mputman added 1574527
              end if;
              OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');

              return FALSE;
           else
              fnd_message.set_name('ICX','ICX_SESSION_FAILED');
              c_error_msg := fnd_message.get;
              g_validation_error := substr(c_error_msg,1,240);
              return FALSE;
           end if;

        when others
        then
           if c_validate_only = 'N'
           then
              fnd_message.set_name('ICX','ICX_SESSION_FAILED');
              c_error_msg := fnd_message.get;
              fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
              c_login_msg := fnd_message.get;

              if g_session_id is not null
              then
                 update icx_sessions
                    set disabled_flag = 'Y'
                  where session_id = g_session_id;
                 COMMIT; -- mputman added 1574527
              end if;
             OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
              return FALSE;
           else
              g_validation_error := substr(SQLERRM,1,240);
              return FALSE;
           end if;
end;

function validateSessionPrivate( c_encrypted_session_id in varchar2,
                                 c_function_code     in varchar2,
                                 c_validate_only     in varchar2,
                                 c_commit            in boolean,
                                 c_update            in boolean,
                                 c_responsibility_id in number,
                                 c_function_id       in number,
                                 c_resp_appl_id      in number,
                                 c_security_group_id in number,
                                 c_validate_mode_on  in varchar2,
                                 c_encrypted_transaction_id in varchar2,
                                 session_id             out NOCOPY number,
                                 transaction_id         out NOCOPY number,
                                 user_id                out NOCOPY number,
                                 responsibility_id      out NOCOPY number,
                                 resp_appl_id           out NOCOPY number,
                                 security_group_id      out NOCOPY number,
                                 language_code          out NOCOPY varchar2,
                                 nls_language           out NOCOPY varchar2,
                                 date_format_mask       out NOCOPY varchar2,
                                 nls_date_language      out NOCOPY varchar2,
                                 nls_numeric_characters out NOCOPY varchar2,
                                 nls_sort               out NOCOPY varchar2,
                                 nls_territory          out NOCOPY varchar2)
                                return BOOLEAN is

l_result         boolean;
l_session_id     number;
l_transaction_id number;

begin

 BEGIN  --2301884
 l_session_id     := icx_call.decrypt3(c_encrypted_session_id);
 EXCEPTION
    WHEN OTHERS THEN
    RETURN FALSE;
 END; --2301884

 if c_encrypted_transaction_id is not null
 then
   l_transaction_id := icx_call.decrypt3(c_encrypted_transaction_id);
 else
   l_transaction_id := '';
 end if;

 l_result := validateSessionPrivate(
               c_session_id => l_session_id,
               c_function_code => c_function_code,
               c_validate_only => c_validate_only,
               c_commit => c_commit,
               c_update => c_update,
               c_responsibility_id => c_responsibility_id,
               c_function_id => c_function_id,
               c_resp_appl_id => c_resp_appl_id,
               c_security_group_id => c_security_group_id,
               c_validate_mode_on => c_validate_mode_on,
               c_transaction_id => l_transaction_id);

  session_id     := l_session_id;
  transaction_id := l_transaction_id;

  if l_result
  then
    user_id                := icx_sec.g_user_id;
    responsibility_id      := icx_sec.g_responsibility_id;
    resp_appl_id           := icx_sec.g_resp_appl_id;
    security_group_id      := icx_sec.g_security_group_id;
    language_code          := icx_sec.g_language_code;
    nls_language           := icx_sec.g_language;
    date_format_mask       := icx_sec.g_date_format;
    nls_date_language      := icx_sec.g_date_language;
    nls_numeric_characters := icx_sec.g_numeric_characters;
    nls_sort               := icx_sec.g_nls_sort;
    nls_territory          := icx_sec.g_nls_territory;
  else
    user_id                := '';
    responsibility_id      := '';
    resp_appl_id           := '';
    security_group_id      := '';
    language_code          := '';
    nls_language           := '';
    date_format_mask       := '';
    nls_date_language      := '';
    nls_numeric_characters := '';
    nls_sort               := '';
    nls_territory          := '';
  end if;

  return l_result;

end;

PROCEDURE Session_tickle_PVT(p_session_id IN NUMBER)
is
PRAGMA AUTONOMOUS_TRANSACTION;  -- mputman added for 2233089

begin

   update icx_sessions
      set    last_connect  = sysdate
      where  session_id = p_session_id;
   commit;

end;--Check Session PVT

PROCEDURE Session_tickle2_PVT(p_session_id IN NUMBER)
is

begin

   update icx_sessions
      set    last_connect  = sysdate
      where  session_id = p_session_id;
   commit;

end;--Check Session2 PVT

FUNCTION CHECK_SESSION(p_session_id IN NUMBER,
                       p_resp_id IN NUMBER,
                       p_app_resp_id IN NUMBER)  RETURN VARCHAR2
is

        e_exceed_limit          exception;
        e_session_invalid       exception;
        n_limit_connects        number;
        n_limit_time            number;
        n_counter               number;
        c_disabled_flag         varchar2(1);
        c_text                  varchar2(80);
        c_display_error         varchar2(240);
        c_error_msg             varchar2(2000);
        c_login_msg             varchar2(2000);
        n_error_num             number;
        l_string                varchar2(100);
        d_first_connect_time    date;
   l_profile_defined       boolean;
        l_session_mode          varchar2(30);
   l_last_connect          DATE;--mputman added 1755317
   l_session_timeout       NUMBER;--mputman added 1755317
   l_dist                  varchar2(30);
   l_user_id               NUMBER;
   l_app_resp_id           NUMBER;
   l_resp_id               NUMBER;

begin


  -- added last_connect into the select for 1755317 mputman

   select LIMIT_CONNECTS, LIMIT_TIME,
         FIRST_CONNECT, COUNTER,
         nvl(DISABLED_FLAG,'N'),
         LAST_CONNECT, user_id,
         nvl(p_resp_id,RESPONSIBILITY_ID),
         nvl(p_app_resp_id,RESPONSIBILITY_APPLICATION_ID)
  into   n_limit_connects, n_limit_time,
         d_first_connect_time,n_counter,
         c_disabled_flag,
         l_last_connect, l_user_id,
         l_resp_id, l_app_resp_id
  from  ICX_SESSIONS
  where SESSION_ID = p_session_id;

  if ((n_counter + 1) > n_limit_connects) or
           (( d_first_connect_time + n_limit_time/24 < sysdate))
        then
           raise e_exceed_limit;
        end if;

        if (c_disabled_flag = 'Y')  then
           raise e_session_invalid;
        end if;
   fnd_profile.get_specific
               (name_z              => 'ICX_SESSION_TIMEOUT',
                application_id_z    => l_app_resp_id,
                user_id_z           => l_user_id,
                responsibility_id_z => l_resp_id,
                val_z               => l_session_timeout ,
                defined_z           => l_profile_defined);
   IF (l_session_timeout ) IS NOT NULL AND (l_session_timeout > 0) THEN

      IF (((SYSDATE-l_last_connect)*24*60)> l_session_timeout ) THEN
         RAISE e_exceed_limit;
      ELSE
         -- nlbarlow 2847057
         fnd_profile.get_specific
                     (name_z              => 'DISTRIBUTED_ENVIRONMENT',
                      application_id_z    => l_app_resp_id,
                      user_id_z           => l_user_id,
                      responsibility_id_z => l_resp_id,
                      val_z               => l_dist,
                      defined_z           => l_profile_defined);
         if l_dist = 'Y'
         then
           Session_tickle2_PVT(p_session_id);
         else
           Session_tickle_PVT(p_session_id);--moved to after idle check.
         end if;
      END IF;
   END IF;

   return ('VALID');

exception
        when e_session_invalid
        then
             -- fnd_message.set_name('ICX','ICX_SESSION_FAILED');
              return ('INVALID');
   when e_exceed_limit
   then
           -- fnd_message.set_name('ICX','ICX_LIMIT_EXCEEDED');
         return ('EXPIRED');
   when others
   then
              -- fnd_message.set_name('ICX','ICX_SESSION_FAILED');
         return ('INVALID');
end;--Check Session PVT

--  ***********************************************
--      function validateSession
--  ***********************************************

function validateSession( c_function_code      in varchar2,
                          c_validate_only      in varchar2,
                          c_commit             in boolean,
                          c_update             in boolean,
                          c_validate_mode_on   in varchar2)
                         return BOOLEAN is

v_cookie_session        owa_cookie.cookie;
e_session_invalid       exception;
c_text                  varchar2(80);
n_session_id            number;
c_ip_address            varchar2(50);
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);

begin
  icx_util.error_page_setup; --clean out artifact errors -- mputman 1574527
  -- nlbarlow 1574527
  if icx_sec.g_validateSession_flag
  then

   --*** Get the cookie for this session.
   n_session_id := getsessioncookie;

   --* if ICX cookie exists, get session id *--
   if (n_session_id <= 0)
   then

      --* if WF cookie exists, create pseudo session *--
      v_cookie_session := owa_cookie.get('WF_SESSION');
      if (v_cookie_session.num_vals <= 0)
      then
         raise e_session_invalid;
      else
         if wf_notification.accessCheck(v_cookie_session.vals(v_cookie_session.num_vals)) is not null
         then
            c_text := PseudoSession(n_session_id);
         else
            n_session_id := -1;
         end if;
      end if;
   end if;

   return (validateSessionPrivate(
                c_session_id => n_session_id,
                c_function_code => c_function_code,
                c_validate_only => c_validate_only,
                c_commit => c_commit,
                c_update => c_update,
                c_validate_mode_on => c_validate_mode_on));

  else
   return true;
  end if;

exception
        when e_session_invalid
        then
           if c_validate_only = 'N'
           then
              fnd_message.set_name('ICX','ICX_SESSION_FAILED');
              c_error_msg := fnd_message.get;
              fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
              c_login_msg := fnd_message.get;

              if n_session_id is not null
              then
                 update icx_sessions
                    set disabled_flag = 'Y'
                  where session_id = n_session_id;
                 COMMIT; -- mputman added 1574527
              end if;
              OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
              return FALSE;
           else
              return FALSE;
           end if;

        when others
        then
           if c_validate_only = 'N'
           then
              fnd_message.set_name('ICX','ICX_SESSION_FAILED');
              c_error_msg := fnd_message.get;
              fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
              c_login_msg := fnd_message.get;

              if n_session_id is not null
              then
                 update icx_sessions
                    set disabled_flag = 'Y'
                  where session_id = n_session_id;
                 COMMIT; -- mputman added 1574527
              end if;
--Bug 3957805
              fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
              c_login_msg := fnd_message.get;
              c_error_msg := dbms_utility.format_error_stack;

              OracleApps.displayLogin(c_login_msg||' '||c_error_msg,'IC','Y');
              return FALSE;
           else
              return FALSE;
           end if;
end;

function disableUserSession(c_session_id in number,
                            c_user_id in number) return BOOLEAN
is

l_session_id    number;
l_user_id       number;

begin

   if c_session_id is null then
      l_session_id := getsessioncookie;
   else
      l_session_id := c_session_id;
   end if;

   if c_user_id is null then
      update icx_sessions
         set disabled_flag = 'Y'
       where session_id = l_session_id;
      COMMIT; -- mputman added 1574527
   elsif c_user_id is not null then
      update icx_sessions
         set disabled_flag = 'Y'
       where session_id = l_session_id
         and user_id = c_user_id;
      COMMIT; -- mputman added 1574527
   end if;

   return true;
exception
        when others then
--                htp.p(SQLERRM);
                  htp.p(dbms_utility.format_error_stack);
                return false;
end;

--  ***********************************************
--      procedure RemoveCookie
--  ***********************************************

procedure RemoveCookie is

n_session_id    number;

begin

   -- when we have corrected how WebServer.RemoveCookie works,
   -- we can remove the check for -1 here

   n_session_id := getsessioncookie;

   if (n_session_id > 0)
   then
       if n_session_id is not null
       then
           update icx_sessions
              set disabled_flag = 'Y'
            where session_id = n_session_id;
           COMMIT; -- mputman added 1574527
       end if;

      --*********************************************--
      -- Disable the cookie
      -- Cookie is to be set within html header
      --*********************************************--

      -- The correct way to remove the cookie is to
      -- set it to expire immediately.
      --  However, because of a WebServer bug,
      -- We are resetting it to -1 for now.

      owa_util.mime_header('text/html', FALSE);

      sendsessioncookie(-1);

      owa_util.http_header_close;
   end if;

end;

--  ***********************************************
--      procedure writeAudit
--  ***********************************************

procedure writeAudit is
        c_audit_id      number(15);
        c_server_name   varchar2(80);
        c_server_port   varchar2(80);
        c_script_name   varchar2(80);
        c_path_info     varchar2(80);
        c_message       varchar2(80);
        n_session_id            number;
begin
NULL;
/*
        select icx_audit_s.nextval
        into c_audit_id
        from sys.dual;

        n_session_id := getsessioncookie;
        c_message := icx_sec.validateSession(n_session_id,c_web_user_id,c_language);

*/
/*
        for i in 1..14 loop

        if owa.cgi_var_name(i) = 'SERVER_NAME'
        then c_server_name := owa.cgi_var_val(i);
        end if;

        if owa.cgi_var_name(i) = 'SERVER_PORT'
        then c_server_port := owa.cgi_var_val(i);
        end if;

        if owa.cgi_var_name(i) = 'SCRIPT_NAME'
        then c_script_name := owa.cgi_var_val(i);
        End if;

        if owa.cgi_var_name(i) = 'PATH_INFO'
        then c_path_info := owa.cgi_var_val(i);
        end if;

        end loop;

        Insert into icx_audit
        (audit_id,session_id,
         SERVER_NAME,SERVER_PORT,SCRIPT_NAME,
        PATH_INFO,connect_date,
         created_by, creation_date, last_updated_by, last_update_date)
        values
        (c_audit_id,c_session_id,c_server_name,c_server_port,c_script_name,
        c_path_info, sysdate,
        1, sysdate, 1, sysdate);

Make sure fill out standard WHO columns.


*/
end;

--  ***********************************************
--      procedure getSecureAttributeValues
--  ***********************************************

procedure getSecureAttributeValues(p_return_status  out NOCOPY varchar2,
                                   p_attri_code      in varchar2,
                                   p_char_tbl       out NOCOPY g_char_tbl_type,
                                   p_session_id      in number)
is

n_session_id            number;
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);
e_exceeded_limit        exception;
l_count                 number default 0;
l_user_id               number;


cursor c_attri is
   select varchar2_value
     from ak_web_user_sec_attr_values
    where attribute_code = upper(p_attri_code)
      and web_user_id    = l_user_id;

begin

   p_return_status := 0;

   -- **********************************************
   --
   --   Get the cookie for this session.
   --   and find out other information from the db
   --
   -- **********************************************

   if p_session_id = -1
   then
      n_session_id := getsessioncookie;

      if (n_session_id <= 0)
      then
         raise e_exceeded_limit;
      end if;
   else
      n_session_id := p_session_id;
   end if;

      select a.user_id
        into l_user_id
        from icx_sessions a
       where session_id = n_session_id;

      for cur_att in c_attri
      loop
         l_count := l_count + 1;
         p_char_tbl(l_count) := cur_att.varchar2_value;
      end loop;

exception
   when e_exceeded_limit
   then
      fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;
      p_return_status := '-1';

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');

   when others then
      fnd_message.set_name('ICX','ICX_DATA_INCORRECT');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;
      p_return_status := '-1';

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
end;


--  ***********************************************
--      procedure getSecureAttributeValues
--  ***********************************************

procedure getSecureAttributeValues(p_return_status  out NOCOPY varchar2,
                                   p_attri_code      in varchar2,
                                   p_date_tbl       out NOCOPY g_date_tbl_type,
                                   p_session_id      in number)
is

n_session_id            number;
v_date_format           varchar2(100);
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);
e_exceeded_limit        exception;
l_count                 number default 0;
l_user_id               number;


cursor c_attri is
   select date_value
     from ak_web_user_sec_attr_values
    where attribute_code = upper(p_attri_code)
      and web_user_id    = l_user_id;

begin

   p_return_status := 0;

   -- **********************************************
   --
   --   Get the cookie for this session.
   --   and find out other information from the db
   --
   -- **********************************************

   if p_session_id = -1
   then

      n_session_id := getsessioncookie;

      if (n_session_id <= 0)
      then
         raise e_exceeded_limit;
      end if;

   else
      n_session_id := p_session_id;
   end if;

      select a.user_id
        into l_user_id
        from icx_sessions a
       where session_id = n_session_id;

      for cur_att in c_attri
      loop
         l_count := l_count + 1;
         select date_format_mask
           into v_date_format
           from icx_sessions
          where session_id = n_session_id;

         p_date_tbl(l_count) := to_char(cur_att.date_value, v_date_format);

      end loop;

exception
   when e_exceeded_limit
   then
      fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;
      p_return_status := '-1';

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');

   when others then
      fnd_message.set_name('ICX','ICX_DATA_INCORRECT');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;
      p_return_status := '-1';

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
end;


--  ***********************************************
--      procedure getSecurAttribValues
--  ***********************************************

procedure getSecureAttributeValues(p_return_status  out NOCOPY varchar2,
                                   p_attri_code      in varchar2,
                                   p_num_tbl        out NOCOPY g_num_tbl_type,
                                   p_session_id      in number)
is

c_ip_address            varchar2(50);
n_session_id            number;
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);
e_exceeded_limit        exception;
l_count                 number default 0;
l_user_id               number;


cursor c_attri is
   select number_value
     from ak_web_user_sec_attr_values
    where attribute_code = upper(p_attri_code)
      and web_user_id    = l_user_id;

begin

   p_return_status := 0;

   -- **********************************************
   --
   --   Get the cookie for this session.
   --   and find out other information from the db
   --
   -- **********************************************

   if p_session_id = -1
   then

      n_session_id := getsessioncookie;

      if (n_session_id <= 0)
      then
         raise e_exceeded_limit;
      end if;

   else
      n_session_id := p_session_id;
   end if;

      select a.user_id
        into l_user_id
        from icx_sessions a
       where session_id = n_session_id;

      for cur_att in c_attri
      loop
         l_count := l_count + 1;
         p_num_tbl(l_count) := to_char(cur_att.number_value);

      end loop;

exception
   when e_exceeded_limit
   then
      fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;
      p_return_status := '-1';

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');

   when others then
      fnd_message.set_name('ICX','ICX_DATA_INCORRECT');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;
      p_return_status := '-1';

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
end;


--  ***********************************************
--      procedure getOrgInfo
--  ***********************************************
procedure getOrgInfo(n_param      in number,
                     n_session_id in number,
                     n_id         out NOCOPY varchar2)
is

n_user_id               number;
n_customer_contact_id   number;
n_vendor_contact_id     number;
n_internal_contact_id   number;
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);

begin

   select a.user_id
     into n_user_id
     from icx_sessions a
    where  a.session_id = n_session_id;

   if n_user_id <> 1 and n_user_id <> -1 -- ** 1 is sysadmin **
   then

      select  CUSTOMER_ID, SUPPLIER_ID, EMPLOYEE_ID
        into    n_customer_contact_id, n_vendor_contact_id, n_internal_contact_id
        from    fnd_user
       where    user_id = n_user_id;

        if n_param = PV_CUST_CONTACT_ID         --** CUSTOMER_CONTACT_ID (7)
        then
           n_id := n_customer_contact_id;

        elsif n_param = PV_VEND_CONTACT_ID      --** VENDOR_CONTACT_ID (8)
        then
           n_id := n_vendor_contact_id;

        elsif n_param = PV_INT_CONTACT_ID       --** INTERNAL_CONTACT_ID (9)
        then
           n_id := n_internal_contact_id;

        end if;

   end if;

exception
   when others then
      fnd_message.set_name('ICX','ICX_DATA_INCORRECT');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
end;

--  ***********************************************
--      procedure set_org_context
--  ***********************************************
procedure set_org_context(
                     n_session_id in number,
                     n_org_id     in number)
is

n_user_id               number;
n_customer_contact_id   number;
n_vendor_contact_id     number;
n_internal_contact_id   number;
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);

begin

   if n_session_id is not null and n_org_id is not null
   then
      update icx_sessions
         set org_id = n_org_id
       where session_id = n_session_id;

      fnd_client_info.set_org_context(to_char(n_org_id));
   end if;

exception
   when others then
      fnd_message.set_name('ICX','ICX_DATA_INCORRECT');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
end;

--  ***********************************************
--      function getID
--
--  This function get the session information
--  from the cookie.
--  If cookie is NOT exist, the function
--  returns default language_code and date_format_mask
--  everything else will return NULLs.
--  ***********************************************

function getID(n_param in number,
                c_logo in varchar2,
                p_session_id in number)
                return varchar2 is

n_user_id               number;
n_id                    varchar2(80) default NULL;
n_customer_contact_id   number;
n_vendor_contact_id     number;
n_internal_contact_id   number;
n_responsibility_id     number;
n_org_id                number;
n_user_name             varchar2(80);
n_session_id            number;
l_session_id            number;                 -- this is a dummy variable
v_cookie_session        owa_cookie.cookie;
v_language_code         varchar2(10);
v_date_format           varchar2(100);
l_session_mode          varchar2(30);
l_profile_defined       boolean;
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);
e_exceeded_limit        exception;

begin

   -- If session id supplied do not look at cookie
   if p_session_id is not null
   then
        n_session_id := p_session_id;
   else
        n_session_id := getsessioncookie;
   end if;

/* nlbarlow 1574527
   if (n_session_id > 0)
   then
     begin -- bug 643163, check session exists
       select session_id
       into l_session_id
       from icx_sessions
       where session_id = n_session_id;
     exception
       when others then
         n_session_id := -1;
     end;
   else
     n_session_id := -1;
   end if;
*/

   if (n_session_id > 0)
   then
      -- *** Find out the IP address of the client ***

      if n_param = PV_LANGUAGE_CODE             --** LANGUAGE CODE (21) **
      then
         n_id := icx_sec.g_language_code; -- add to Java login.

      elsif n_param = PV_CUST_CONTACT_ID or
            n_param = PV_VEND_CONTACT_ID or
            n_param = PV_INT_CONTACT_ID
      then
            getOrgInfo(n_param, n_session_id, n_id);


      elsif n_param = PV_RESPONSIBILITY_ID      --** RESPONSIBILITY ID (25) **
      then
         n_id := icx_sec.g_responsibility_id;

      elsif n_param = PV_FUNCTION_ID      --** FUNCTION ID (31) **
      then
         n_id := icx_sec.g_function_id;

      elsif n_param = PV_FUNCTION_TYPE          --** FUNCTION TYPE (32) **
      then
         n_id := icx_sec.g_function_type;

      elsif n_param = PV_USER_NAME               --** USERNAME (99) **
      then
         select  b.USER_NAME
           into  n_id
           from  icx_sessions a,
                 fnd_user b
          where  b.user_id = a.user_id
            and  a.session_id  = n_session_id;

      elsif n_param = PV_USER_ID                --** WEB USER ID (10) **
      then
         n_id := icx_sec.g_user_id;

      elsif n_param = PV_DATE_FORMAT            --** DATE FORMAT MASK (22) **
      then
         n_id := icx_sec.g_date_format;

      elsif n_param = PV_SESSION_ID             -- ** SESSION_ID (23) **
      then
         n_id := n_session_id;

      elsif n_param = PV_ORG_ID                 -- ** ORG_ID (29) **
      then
         n_id := icx_sec.g_org_id;

      elsif n_param = PV_USER_REQ_TEMPLATE      -- ** REQ DEFAULT TEMPLATE (25)
      then

        fnd_profile.get_specific(
                name_z                  => 'ICX_REQ_DEFAULT_TEMPLATE',
                application_id_z        => icx_sec.g_resp_appl_id,
                user_id_z               => icx_sec.g_user_id,
                responsibility_id_z     => icx_sec.g_responsibility_id,
                val_z                   => n_id,
                defined_z               => l_profile_defined);


      elsif n_param = PV_USER_REQ_OVERRIDE_REQUESTOR    -- ** PV_USER_REQ_OVERRIDE_REQUESTOR (26)
      then

        fnd_profile.get_specific(
                name_z                  => 'ICX_REQ_OVERRIDE_REQUESTOR_CODE',
                application_id_z        => icx_sec.g_resp_appl_id,
                user_id_z               => icx_sec.g_user_id,
                responsibility_id_z     => icx_sec.g_responsibility_id,
                val_z                   => n_id,
                defined_z               => l_profile_defined);

      elsif n_param = PV_USER_REQ_OVERRIDE_LOC_FLAG     -- ** PV_USER_REQ_OVERRIDE_LOC_FLAG (27)
      then

        fnd_profile.get_specific(
                name_z                  => 'ICX_REQ_OVERRIDE_LOCATION_FLAG',
                application_id_z        => icx_sec.g_resp_appl_id,
                user_id_z               => icx_sec.g_user_id,
                responsibility_id_z     => icx_sec.g_responsibility_id,
                val_z                   => n_id,
                defined_z               => l_profile_defined);

      elsif n_param = PV_USER_REQ_DAYS_NEEDED_BY        -- ** PV_USER_REQ_DAYS_NEEDED_BY (28)
      then

        fnd_profile.get_specific(
                name_z                  => 'ICX_DAYS_NEEDED_BY',
                application_id_z        => icx_sec.g_resp_appl_id,
                user_id_z               => icx_sec.g_user_id,
                responsibility_id_z     => icx_sec.g_responsibility_id,
                val_z                   => n_id,
                defined_z               => l_profile_defined);


      elsif n_param = PV_SESSION_MODE      --** PV_SESSION_MODE (30) **
      then
         select  mode_code
           into  n_id
           from  icx_sessions
          where  session_id = n_session_id;

      elsif n_param = 0
      then
         return(n_id);                          --** return NULL **
      end if;
   else
      -- *********************************
      --  if cookie does not exist.
      --  returns default values for only two codes.
      --  returns NULLs for everything else.
      -- *********************************

      if n_param = PV_LANGUAGE_CODE             --** LANGUAGE CODE (21) **
      then
          select        LANGUAGE_CODE
          into          n_id
          from          FND_LANGUAGES
          where         INSTALLED_FLAG = 'B';
      elsif n_param = PV_DATE_FORMAT            --** DATE FORMAT MASK (22) **
      then
         /*
        select value
          into n_id
          from v$nls_parameters
         where parameter = 'NLS_DATE_FORMAT';
    */

   n_id:=getNLS_PARAMETER('NLS_DATE_FORMAT'); -- replaces above select mputman 1574527



      else
        n_id := NULL;
         -- *************************************************
         -- * if WF cookie exists, returns '-1' - HR requested this implementation
         -- *************************************************
         v_cookie_session := owa_cookie.get('WF_SESSION');
         if (v_cookie_session.num_vals <= 0)
         then
            n_id := NULL;
         else
            if wf_notification.accessCheck(v_cookie_session.vals(v_cookie_session.num_vals)) is not null
            then
               n_id := -1;
            end if;
         end if;
      end if;

  end if;

return(n_id);
exception
   when e_exceeded_limit
   then
      fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
      return '-1';

   when others then
       if n_param = PV_DATE_FORMAT
       then
       return getNLS_PARAMETER('NLS_DATE_FORMAT');
       else

      fnd_message.set_name('ICX','ICX_DATA_INCORRECT');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;
      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');

      return '-1';
end if;
end;


procedure getResponsibilityList(c_user_id        in number,
                                c_application_id in number,
                                c_responsibility_list out NOCOPY g_responsibility_list) is

l_index number;

cursor responsibility is
   select  a.responsibility_name
     from
           --FND_SECURITY_GROUPS_VL fsg, -- mputman per 2018060
           fnd_responsibility_vl a,
           FND_USER_RESP_GROUPS b
    where  b.user_id = c_user_id
    and    b.start_date <= sysdate
    and    (b.end_date is null or b.end_date > sysdate)
    and    b.RESPONSIBILITY_id = a.responsibility_id
    and    b.RESPONSIBILITY_application_id = a.application_id
    and    a.application_id = NVL(c_application_id, a.application_id)
    and    a.version in ('W','4')
    and    a.start_date <= sysdate
    and    (a.end_date is null or a.end_date > sysdate)
    --and    b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID  -- mputman per 2018060
 order by responsibility_name;

begin

   l_index := 1;
   for r in responsibility loop
       c_responsibility_list(l_index) := r.responsibility_name;
       l_index := l_index + 1;
   end loop;

end;



procedure putSessionAttributeValue(p_name in varchar2,
                                   p_value in varchar2,
                                   p_session_id in number) is
l_session_id number;
l_name varchar2(80);
l_len number;

begin

-- 2833640    l_session_id := nvl(p_session_id,getsessioncookie);
    if p_session_id is null
    then
      l_session_id := getsessioncookie;
    else
      l_session_id := p_session_id;
    end if;

-- substr added for bug3282584 - MSkees
-- we truncate from the right as requested by OA FWK - GKellner
	l_len := LENGTH( p_name );
	if ( l_len > 30 ) then
		-- substr() hass a base 1 index so use 29 to get new start
	    l_name := substr( upper(p_name), (l_len - 29), l_len);
    else
    	-- bug 3296747 forgot the else ...
    	l_name := upper(p_name);
    end if;

    delete ICX_SESSION_ATTRIBUTES
    where  SESSION_ID = l_session_id
    and    NAME = l_name;

    insert into ICX_SESSION_ATTRIBUTES
    (SESSION_ID,NAME,VALUE)
    values
    (l_session_id,l_name,p_value);

end;

function getSessionAttributeValue(p_name in varchar2,
                                  p_session_id in number)
                                  return varchar2 is
l_session_id number;
l_name varchar2(80);
l_value varchar2(4000);
l_len number;

begin

-- 2833640    l_session_id := nvl(p_session_id,getsessioncookie);
    if p_session_id is null
    then
      l_session_id := getsessioncookie;
    else
      l_session_id := p_session_id;
    end if;

-- substr added for bug3282584 - MSkees
-- we truncate from the right as requested by OA FWK - GKellner
	l_len := LENGTH( p_name );
	if ( l_len > 30 ) then
		-- substr() hass a base 1 index so use 29 to get new start
	    l_name := substr( upper(p_name), (l_len - 29), l_len);
    else
    	-- bug 3296747 forgot the else ...
    	l_name := upper(p_name);
    end if;

    select VALUE
    into   l_value
    from   ICX_SESSION_ATTRIBUTES
    where  SESSION_ID = l_session_id
    and    NAME = l_name;

    return l_value;

exception
    when others then
        return NULL;
end;

procedure clearSessionAttributeValue(p_name in varchar2,
                                     p_session_id in number) is
l_session_id number;
l_name varchar2(80);
l_len number;

begin

-- 2833640    l_session_id := nvl(p_session_id,getsessioncookie);
    if p_session_id is null
    then
      l_session_id := getsessioncookie;
    else
      l_session_id := p_session_id;
    end if;

-- substr added for bug3282584 - MSkees
-- we truncate from the right as requested by OA FWK - GKellner
	l_len := LENGTH( p_name );
	if ( l_len > 30 ) then
		-- substr() hass a base 1 index so use 29 to get new start
	    l_name := substr( upper(p_name), (l_len - 29), l_len);
    else
    	-- bug 3296747 forgot the else ...
    	l_name := upper(p_name);
    end if;

    delete ICX_SESSION_ATTRIBUTES
    where  SESSION_ID = l_session_id
    and    NAME = l_name;

end;

procedure sendsessioncookie (p_session_id in number) is

l_encrypted_session_id  varchar2(240);
l_server_name   varchar2(240);
l_domain_count  number;
l_domain        varchar2(240);
l_secure        varchar2(30);
c_browser       varchar2(240);

begin

if p_session_id > 0
then
    l_encrypted_session_id := icx_call.encrypt3(p_session_id);
else
    l_encrypted_session_id := '-1';
end if;

IF icx_sec.g_query_set = -1 THEN

select HOME_URL,
       WEBMASTER_EMAIL,
       QUERY_SET,
       MAX_ROWS,
       SESSION_COOKIE_DOMAIN,       --mputman added 1574527
       SESSION_COOKIE_NAME,          --mputman added 1574527
       WINDOW_COOKIE_NAME

into   icx_sec.g_home_url,
       icx_sec.g_webmaster_email,
       icx_sec.g_query_set,
       icx_sec.g_max_rows,
       icx_sec.g_session_cookie_domain,  --mputman added 1574527
       icx_sec.g_session_cookie_name,     --mputman added 1574527
       icx_sec.g_window_cookie_name
from   ICX_PARAMETERS;
END IF; --mputman added 1574527

--mputman added 1574527
-- icx_sec.g_session_cookie_name := icx_sec.getsessioncookiename;

if (icx_sec.g_session_cookie_name is null) then
   icx_sec.g_session_cookie_name := FND_WEB_CONFIG.DATABASE_ID;

end if;

-- mputman added 1574527
   --the below line was commented for performance reasons.
   --bcos getsessioncookiedomain also hits DB for finding icx_parameters.session_cookie_domain.
   --uncommenting again.
   icx_sec.g_session_cookie_domain := icx_sec.getsessioncookiedomain;

--mputman modified to change default domain setting 1755300
-- will remove first segment of CGI env for server
-- then will test to see how many remaining segments
-- if there are more than 3 remaining segment, it will substring to only 3


--if FND_WEB_CONFIG.PROTOCOL = 'https:'
--then
--    l_secure := 'secure';
--else
--    l_secure := '';
--end if;

-- bug 1688982
c_browser := owa_util.get_cgi_env('HTTP_USER_AGENT');

if FND_WEB_CONFIG.PROTOCOL = 'https:'
then
--if (instr(c_browser, 'Mac_PowerPC') = 36 )
-- Bug 2618058
if (instr(c_browser, 'Mac_PowerPC') > 0)
then
    l_secure := '';
else
if FND_WEB_CONFIG.PROTOCOL = 'https:'
then
   l_secure := 'secure';
else
   l_secure := '';
        end if;
     end if;
end if;
-- end of bug 1688982

if (icx_sec.g_session_cookie_domain = 'NODOMAIN')
then
  owa_cookie.send(name => icx_sec.g_session_cookie_name,
                  value => l_encrypted_session_id,
                  expires => '',
                  path => '/',
                  secure => l_secure);
else
  owa_cookie.send(name => icx_sec.g_session_cookie_name,
                  value => l_encrypted_session_id,
                  expires => '',
                  path => '/',
                  domain => icx_sec.g_session_cookie_domain,
                  secure => l_secure);
end if;

exception
        when others then
--                htp.p(SQLERRM);
                  htp.p(dbms_utility.format_error_stack);
end;

function getsessioncookie(p_ticket in varchar2) return number is

l_cookie_session        owa_cookie.cookie;
l_session_id            number;

begin

IF icx_sec.g_query_set = -1 THEN
select HOME_URL,
       WEBMASTER_EMAIL,
       QUERY_SET,
       MAX_ROWS,
       SESSION_COOKIE_DOMAIN,       --mputman added 1574527
       SESSION_COOKIE_NAME,          --mputman added 1574527
       WINDOW_COOKIE_NAME

into   icx_sec.g_home_url,
       icx_sec.g_webmaster_email,
       icx_sec.g_query_set,
       icx_sec.g_max_rows,
       icx_sec.g_session_cookie_domain,  --mputman added 1574527
       icx_sec.g_session_cookie_name,     --mputman added 1574527
       icx_sec.g_window_cookie_name
from   ICX_PARAMETERS;
END IF; --mputman added 1574527

-- Bug 1491332: Moved the below 2 lines to the else section below
-- icx_sec.g_session_cookie_name := icx_sec.getsessioncookiename;
-- icx_sec.g_session_cookie_domain := icx_sec.getsessioncookiedomain;

if p_ticket is not null
then
  l_session_id := to_number(icx_call.decrypt3(p_ticket));
else

  -- mputman added 1574527
  -- icx_sec.g_session_cookie_name := icx_sec.getsessioncookiename;

  if (icx_sec.g_session_cookie_name is null) then
     icx_sec.g_session_cookie_name := FND_WEB_CONFIG.DATABASE_ID;
  end if;

  -- mputman added 1574527, don't need domain
  -- icx_sec.g_session_cookie_domain := icx_sec.getsessioncookiedomain;

  l_cookie_session := owa_cookie.get(icx_sec.g_session_cookie_name);

  if (l_cookie_session.num_vals > 0) and (l_cookie_session.vals(l_cookie_session.num_vals) <> '-1')
  then
      l_session_id := to_number(icx_call.decrypt3(l_cookie_session.vals(l_cookie_session.num_vals)));
  else
      l_session_id := -1;
  end if;
end if;

return l_session_id;

exception
        when others then
--                htp.p(SQLERRM);
                  htp.p(dbms_utility.format_error_stack);
                return -1;
end;

--  ***********************************************
--      function getsessioncookiename
--  ***********************************************

function getsessioncookiename return varchar2 is

l_session_cookie_name   varchar2(81);

begin

   IF  icx_sec.g_session_cookie_name IS NULL THEN

      select SESSION_COOKIE_NAME
      into   l_session_cookie_name
      from   ICX_PARAMETERS;
   ELSE
      l_session_cookie_name:=icx_sec.g_session_cookie_name;
   END IF;   -- added mputman 1574527

if (l_session_cookie_name is null) then
   l_session_cookie_name := FND_WEB_CONFIG.DATABASE_ID;
end if;

return l_session_cookie_name;

exception
        when others then
                htp.p(SQLERRM);
                return -1;
end;

--  ***********************************************
--      function getsessioncookiedomain
--  ***********************************************

function getsessioncookiedomain return varchar2 is

l_session_cookie_domain   varchar2(30);
l_server_name   varchar2(240);
l_domain_count  number;
/*
Modified logic for default domain naming to drop the first segment
of the server CGI value then substr if needed to limit domain name
size to no more than 3 segments.
1755300
*/
--Modified above logic remove the above restriction.
--now session cookie domain can have any number of elements.

begin
   l_session_cookie_domain := trim(fnd_profile.value('ICX_SESSION_COOKIE_DOMAIN'));
   IF  l_session_cookie_domain IS NULL THEN

      select SESSION_COOKIE_DOMAIN
      into   l_session_cookie_domain
      from   ICX_PARAMETERS;
   END IF;

if (l_session_cookie_domain is null OR upper(l_session_cookie_domain) = 'DOMAIN') then
  l_server_name := owa_util.get_cgi_env('SERVER_NAME'); -- should APPS_WEB_AGENT PROFILE BE USED?
  l_domain_count := instr(l_server_name,'.',-1,2);
  if l_domain_count > 0
  then
    l_domain_count := instr(l_server_name,'.',1,1);
    --Bug 15922926 - don't limit the elements in cookie domain to 3.
    l_server_name := substr(l_server_name,l_domain_count,length(l_server_name));
    l_session_cookie_domain := l_server_name;
  else
    l_session_cookie_domain := '';
  end if;
elsif l_session_cookie_domain = 'NULL'
then
  l_session_cookie_domain := '';
elsif upper(l_session_cookie_domain) = 'HOST'
then
  l_session_cookie_domain := '';
elsif (
       (l_session_cookie_domain <> 'NODOMAIN') AND   -- mputman 22-FEB-02
       (l_session_cookie_domain <>''))              -- mputman 22-FEB-02
then
  --user has provided some value for the profile option icx_session_cookie_domain.
  --append a '.' if not present.
  if(substr(l_session_cookie_domain,1,1) <> '.')
  then
    l_session_cookie_domain := '.'|| l_session_cookie_domain;  -- bug 1612338
  end if;

  --don't allow something like .com OR .org
  l_domain_count := instr(l_session_cookie_domain, '.',-1,2);
  if l_domain_count > 0
  then
    --check the security.
    l_server_name := owa_util.get_cgi_env('SERVER_NAME');
    if(instr(l_server_name, l_session_cookie_domain) = 0)
    then
        l_session_cookie_domain := '';
    end if;
  else
    l_session_cookie_domain := '';
  end if;
end if;
return l_session_cookie_domain;

exception
        when others then
--                htp.p(SQLERRM);
                  htp.p(dbms_utility.format_error_stack);
                return -1;


                end;

--  ***********************************************
--     function createRFURL (AOL/J)
--  ***********************************************
function createRFURL( p_function_name          varchar2,
                      p_function_id            number,
                      p_application_id         number,
                      p_responsibility_id      number,
                      p_security_group_id      number,
                      p_session_id             number,
                      p_parameters             varchar2)
         return varchar2 is

PRAGMA AUTONOMOUS_TRANSACTION;

l_RFURL       varchar2(2000) := null;
-- l_session_id   number;
l_function_id  number;

begin

--   l_session_id := nvl(p_session_id, icx_sec.getID(icx_sec.pv_session_id));

   if p_function_id is null
   then
     select FUNCTION_ID
     into   l_function_id
     from   FND_FORM_FUNCTIONS
     where  FUNCTION_NAME = p_function_name;
   else
     l_function_id := p_function_id;
   end if;

/*
  l_RFURL := FND_WEB_CONFIG.PLSQL_AGENT||'OracleSSWA.Execute?E='||
                                  wfa_html.conv_special_url_chars(
                                  icx_call.encrypt(p_application_id||'*'||
                                                    p_responsibility_id||'*'||
                                                    p_security_group_id||'*'||
                                                    l_function_id||'**] '));


--mputman convert to execute effort
--    l_RFURL := FND_WEB_CONFIG.PLSQL_AGENT||'OracleApps.RF?F='||
--                              icx_call.encrypt2(p_application_id||'*'||
--                                                p_responsibility_id||'*'||
--                                                p_security_group_id||'*'||
--                                                l_function_id||'**] ',
--                                                l_session_id);

   if p_parameters is not null
   then
   --mputman convert to execute effort
 --l_RFURL := l_RFURL||'&'||'P='||icx_call.encrypt2(p_parameters,l_session_id);
     l_RFURL := l_RFURL||'&'||'P='||icx_call.encrypt(p_parameters);
   end if;
*/

 -- 2758891 nlbarlow
 l_RFURL := icx_portlet.createExecLink(p_application_id => p_application_id,
                      p_responsibility_id => p_responsibility_id,
                      p_security_group_id => p_security_group_id,
                      p_function_id => l_function_id,
                      p_parameters => p_parameters,
                      p_url_only => 'Y');


   commit; -- bug 1324906

   return l_RFURL;

end createRFURL;

--  ***********************************************
--     function createRFLink
--  ***********************************************
function createRFLink( p_text                   varchar2,
                       p_application_id         number,
                       p_responsibility_id      number,
                       p_security_group_id      number,
                       p_function_id            number,
                       p_target                 varchar2,
                       p_session_id             number)
         return varchar2 is

PRAGMA AUTONOMOUS_TRANSACTION;

l_RFLink       varchar2(2000) := null;
l_session_id   number;

begin

     -- 2758891 nlbarlow

    l_RFLink := icx_portlet.createExecLink(p_application_id => p_application_id,
                      p_responsibility_id => p_responsibility_id,
                      p_security_group_id => p_security_group_id,
                      p_function_id => p_function_id,
                      p_parameters => '',
                      p_target => p_target,
                      p_link_name => p_text,
                      p_url_only => 'N');

/*   --mputman convert to execute effort
   --l_session_id := icx_sec.getID(n_param => icx_sec.pv_session_id,
   --                              p_session_id => p_session_id);

    l_RFLink := '<A HREF=OracleSSWA.Execute?E='||wfa_html.conv_special_url_chars(
                         icx_call.encrypt(p_application_id||'*'||
                                           p_responsibility_id||'*'||
                                           p_security_group_id||'*'||
                                           p_function_id||'**]'))||
                ' TARGET='''||p_target||'''>'||p_text||'</A>';

--mputman convert to execute effort
--    l_RFLink := '<A HREF=OracleApps.RF?F='||
--                         icx_call.encrypt2(p_application_id||'*'||
--                                           p_responsibility_id||'*'||
--                                           p_security_group_id||'*'||
--                                           p_function_id||'**]',
--                                           l_session_id)||
--                ' TARGET='''||p_target||'''>'||p_text||'</A>';
*/
   commit; -- bug 1324906

   return l_RFlink;

end createRFLink;

--  ***********************************************
--     procedure updateSessionContext (AOL/J)
--  ***********************************************
procedure updateSessionContext( p_function_name          varchar2,
                                p_function_id            number,
                                p_application_id         number,
                                p_responsibility_id      number,
                                p_security_group_id      number,
                                p_session_id             number,
                                p_transaction_id         number)
          is

l_session_id            number;
l_function_id           number;
l_function_type         varchar2(30);
l_multi_org_flag        varchar2(30);
l_org_id                number;
l_profile_defined       boolean;

begin

  IF p_session_id IS NOT NULL THEN
    l_session_id := p_session_id;
  ELSE
    l_session_id := icx_sec.getID(icx_sec.pv_session_id);
  END IF; --2482554
  --l_session_id := nvl(p_session_id, icx_sec.getID(icx_sec.pv_session_id));

  if p_function_id is null and p_function_name is not null
  then
    select FUNCTION_ID, TYPE
    into   l_function_id, l_function_type
    from   FND_FORM_FUNCTIONS
    where  FUNCTION_NAME = p_function_name;
  elsif p_function_name is null and p_function_id is not null
  then
    select FUNCTION_ID, TYPE
    into   l_function_id, l_function_type
    from   FND_FORM_FUNCTIONS
    where  FUNCTION_ID = p_function_id;
  else
    l_function_id := '';
    l_function_type := '';
  end if;

  select multi_org_flag
  into   l_multi_org_flag
  from   fnd_product_groups
  where  rownum < 2;

  if l_multi_org_flag = 'Y'
  then
      fnd_profile.get_specific(
          name_z                  => 'ORG_ID',
          responsibility_id_z     => p_responsibility_id,
          application_id_z        => p_application_id,
          val_z                   => l_org_id,
          defined_z               => l_profile_defined);
  end if;

  update ICX_SESSIONS
  set    RESPONSIBILITY_APPLICATION_ID = p_application_id,
         RESPONSIBILITY_ID = p_responsibility_id,
         SECURITY_GROUP_ID = p_security_group_id,
         ORG_ID = l_org_id,
         FUNCTION_ID = l_function_id,
         FUNCTION_TYPE = l_function_type
  where SESSION_ID = l_session_id;

  if p_transaction_id is not null
  then

    update ICX_TRANSACTIONS
    set  RESPONSIBILITY_APPLICATION_ID = p_application_id,
         RESPONSIBILITY_ID = p_responsibility_id,
         SECURITY_GROUP_ID = p_security_group_id,
         FUNCTION_ID = l_function_id,
         FUNCTION_TYPE = l_function_type
    where SESSION_ID = l_session_id
    and   TRANSACTION_ID = p_transaction_id;
-- 3201309 nlbarlow reordered where
  end if;

  commit;

end updateSessionContext;

--  ***********************************************
--      function jumpIntoFlow
--  ***********************************************
function jumpIntoFlow(  c_person_id     in number,
                        c_application_id        in number,
                        c_flow_code     in varchar2,
                        c_sequence      in number,
                        c_key1          in varchar2,
                        c_key2          in varchar2,
                        c_key3          in varchar2,
                        c_key4          in varchar2,
                        c_key5          in varchar2,
                        c_key6          in varchar2,
                        c_key7          in varchar2,
                        c_key8          in varchar2,
                        c_key9          in varchar2,
                        c_key10         in varchar2)
                        return varchar2 is

        c_url                   varchar2(2000);
        n_session_id            number default 911;
        vHost_name              varchar2(80);
        vAgent_name             varchar2(80);
        c_param                 varchar2(1000);

begin

        c_url := 'POREQWF.OPENREQ?a1=' || icx_call.encrypt(c_key1);

--      c_param := 'POREQWF.OPENREQ?pFlowCode=' || c_flow_code
--              || '&' || 'pKey=' || c_key1;
--      c_url := c_url || c_param;

        return c_url;
end;

--  ***********************************************
--      function jumpIntoFunction
--  ***********************************************
function jumpIntoFunction(p_application_id      in number,
                          p_function_code       in varchar2,
                          p_parameter1          in varchar2,
                          p_parameter2          in varchar2,
                          p_parameter3          in varchar2,
                          p_parameter4          in varchar2,
                          p_parameter5          in varchar2,
                          p_parameter6          in varchar2,
                          p_parameter7          in varchar2,
                          p_parameter8          in varchar2,
                          p_parameter9          in varchar2,
                          p_parameter10         in varchar2,
                          p_parameter11         in varchar2)
                          return varchar2 is

l_url                   varchar2(2000);
l_web_host_name              varchar2(80);
l_web_agent_name                varchar2(80);
l_web_html_call             varchar2(80);
l_web_encrypt_parameters        varchar2(1);

begin

select  web_host_name,web_agent_name,web_html_call,web_encrypt_parameters
into    l_web_host_name,l_web_agent_name,l_web_html_call,l_web_encrypt_parameters
from    fnd_form_functions
where   FUNCTION_NAME = p_function_code
and     WEB_SECURED = 'Y';

l_url :=  '';

if l_web_host_name is not null
then
        l_url := FND_WEB_CONFIG.PROTOCOL||'//'||l_web_host_name||'/';
end if;

if l_web_agent_name is not null
then
        l_url := l_url||l_web_agent_name||'/';
end if;

if l_url is null
then
    l_url := FND_WEB_CONFIG.TRAIL_SLASH(fnd_profile.value('APPS_WEB_AGENT'));
end if;

l_url := l_url||l_web_html_call;

if p_parameter1 is not null
then
    if l_web_encrypt_parameters = 'Y'
    then
        l_url := l_url||'?p1='||icx_call.encrypt(p_parameter1);
    else
        l_url := l_url||'?p1='||p_parameter1;
    end if;
end if;

if p_parameter2 is not null
then
    if l_web_encrypt_parameters = 'Y'
    then
        l_url := l_url||'&'||'p2='||icx_call.encrypt(p_parameter2);
    else
        l_url := l_url||'&'||'p2='||p_parameter2;
    end if;
end if;

if p_parameter3 is not null
then
    if l_web_encrypt_parameters = 'Y'
    then
        l_url := l_url||'&'||'p3='||icx_call.encrypt(p_parameter3);
    else
        l_url := l_url||'&'||'p3='||p_parameter3;
    end if;
end if;

if p_parameter4 is not null
then
    if l_web_encrypt_parameters = 'Y'
    then
        l_url := l_url||'&'||'p4='||icx_call.encrypt(p_parameter4);
    else
        l_url := l_url||'&'||'p4='||p_parameter4;
    end if;
end if;

if p_parameter5 is not null
then
    if l_web_encrypt_parameters = 'Y'
    then
        l_url := l_url||'&'||'p5='||icx_call.encrypt(p_parameter5);
    else
        l_url := l_url||'&'||'p5='||p_parameter5;
    end if;
end if;

if p_parameter6 is not null
then
    if l_web_encrypt_parameters = 'Y'
    then
        l_url := l_url||'&'||'p6='||icx_call.encrypt(p_parameter6);
    else
        l_url := l_url||'&'||'p6='||p_parameter6;
    end if;
end if;

if p_parameter7 is not null
then
    if l_web_encrypt_parameters = 'Y'
    then
        l_url := l_url||'&'||'p7='||icx_call.encrypt(p_parameter7);
    else
        l_url := l_url||'&'||'p7='||p_parameter7;
    end if;
end if;

if p_parameter8 is not null
then
    if l_web_encrypt_parameters = 'Y'
    then
        l_url := l_url||'&'||'p8='||icx_call.encrypt(p_parameter8);
    else
        l_url := l_url||'&'||'p8='||p_parameter8;
    end if;
end if;

if p_parameter9 is not null
then
    if l_web_encrypt_parameters = 'Y'
    then
        l_url := l_url||'&'||'p9='||icx_call.encrypt(p_parameter9);
    else
        l_url := l_url||'&'||'p9='||p_parameter9;
    end if;
end if;

if p_parameter10 is not null
then
    if l_web_encrypt_parameters = 'Y'
    then
        l_url := l_url||'&'||'p10='||icx_call.encrypt(p_parameter10);
    else
        l_url := l_url||'&'||'p10='||p_parameter10;
    end if;
end if;

if p_parameter11 is not null
then
    if l_web_encrypt_parameters = 'Y'
    then
        l_url := l_url||'&'||'p11='||icx_call.encrypt(p_parameter11);
    else
        l_url := l_url||'&'||'p11='||p_parameter11;
    end if;
end if;

return l_url;

exception
    when others then
--        return SQLERRM;
          htp.p(dbms_utility.format_error_stack);

end;

-- added for 1574527 mputman
function getNLS_PARAMETER(p_param in VARCHAR2)
                return varchar2 is
requested_val VARCHAR2(255);
BEGIN

        select upper(value)
          into requested_val
          from v$nls_parameters
         where parameter = p_param;

   RETURN requested_val;


   END;

   --added by mputman for use by AOLJ/CRM
   PROCEDURE set_session_nls (p_session_id IN NUMBER,
                              p_language IN VARCHAR2,
                              p_date_format_mask IN VARCHAR2,
                              p_language_code IN VARCHAR2,
                              p_date_language IN VARCHAR2,
                              p_numeric_characters IN VARCHAR2,
                              p_sort IN VARCHAR2,
                              p_territory IN VARCHAR2)
      IS


      BEGIN

      UPDATE icx_sessions
         SET

          NLS_LANGUAGE=p_language,
          DATE_FORMAT_MASK=p_date_format_mask,
          LANGUAGE_CODE=p_language_code,
          NLS_DATE_LANGUAGE=p_date_language,
          NLS_NUMERIC_CHARACTERS=p_numeric_characters,
          NLS_SORT=p_sort,
          NLS_TERRITORY=p_territory
         WHERE session_id=p_session_id;
      COMMIT;

      EXCEPTION
         WHEN OTHERS THEN
--            htp.p(SQLERRM);
              htp.p(dbms_utility.format_error_stack);

            END;



FUNCTION recreate_session(i_1 IN VARCHAR2,
                          i_2 IN VARCHAR2,
                          p_enc_session IN VARCHAR2,
                          p_mode IN VARCHAR2)
               RETURN VARCHAR2
            IS

            u                   fnd_user%rowtype;
            c_server_name       varchar2(240);
            c_server_port       varchar2(80);
            l_server                varchar2(240);
            c_script_name       varchar2(80);
            l_host_instance             varchar2(240);
            l_url                   varchar2(2000);
            l_result                varchar2(30);
            l_app                   varchar2(30);
            l_msg_code              varchar2(30);
            l_valid2                varchar2(240);
            v_user_id           number;
            v_user_name         varchar2(80);
            v_password          varchar2(80);
            v_encrypted_psswd   varchar2(1000);
            v_encrypted_upper_psswd varchar2(1000);
            c_error_msg         varchar2(2000);
            c_login_msg         varchar2(2000);
            e_signin_invalid    exception;
            e_account_expired   exception;
            e_invalid_password  exception;
            e_java_password             exception;
            l_enc_fnd_pwd           varchar2(100);
            l_enc_user_pwd          varchar2(100);
            l_expired               varchar2(30);
            return_to_url           varchar2(2000);
            l_agent                 varchar2(240);
            c_validate_only         VARCHAR2(10);
            l_session_id            NUMBER;
            l_new_xsid              varchar2(32);
            begin
                if (i_1 is NULL or i_2 is NULL)
                then
                    raise e_signin_invalid;
                end if;

                l_result := fnd_web_sec.validate_login(upper(i_1), i_2);
                c_validate_only:='N';

                if l_result = 'Y'
                then

                   begin
                     select 'Y'
                       into  l_expired
                       from  FND_USER
                      where  USER_NAME = UPPER(i_1)
                        and    (PASSWORD_DATE is NULL or
                               (PASSWORD_LIFESPAN_ACCESSES is not NULL and
                                 nvl(PASSWORD_ACCESSES_LEFT, 0) < 1) or
                               (PASSWORD_LIFESPAN_DAYS is not NULL and
                               SYSDATE >= PASSWORD_DATE + PASSWORD_LIFESPAN_DAYS));
                  exception
                         when no_data_found then
                            l_expired := 'N';
                  end;

                  if (l_expired = 'Y') then
                     return_to_url:='';
                     OracleApps.displayNewPassword(i_1, return_to_url, p_mode);
                     return -1;

                  else

                select *
                into   u
                from   fnd_user
                where  user_name = UPPER(i_1);

                if u.end_date is null or u.end_date > sysdate
                then
                   --return the session_id after sendsession cookie
                   l_session_id:=icx_call.decrypt3(p_enc_session);

                   -- Bug 13487530 get the current xsid
                   select xsid into l_new_xsid from icx_sessions
                   where session_id=l_session_id;

                   -- Bug 13487530 - If session hijacking functionality is
                   -- supported, then recreate XSID whenver the session is
                   -- recreated.
                   if (fnd_session_management.is_hijack_session) then
                     l_new_xsid := fnd_session_management.NewXSID;
                   end if;

                   BEGIN
                      UPDATE icx_sessions
                         SET
                         disabled_flag='N',
                         last_connect=SYSDATE,
                         counter=0,
                         first_connect=SYSDATE,
                         xsid=l_new_xsid
                         WHERE
                         session_id=l_session_id;
                   exception
                       when OTHERS then
                       RETURN -1;
                   END;

                   owa_util.mime_header('text/html', FALSE);
                   sendsessioncookie(l_session_id);
                   owa_util.http_header_close;
                   --htp.p('testing????');
                   RETURN 1;

                else
                    raise e_account_expired;
                end if; -- u.end_date is null or u.end_date > sysdate
                  end if;  -- l_expired
                end if; -- l_valid = '0';
                RAISE e_invalid_password;
            exception
               when e_java_password
               then

                  if c_validate_only = 'N'
                  then
                     fnd_message.set_name('ICX','ICX_ACCT_EXPIRED');
                     c_error_msg := fnd_message.get;
                     fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
                     c_login_msg := fnd_message.get;

                     OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
                  end if;

                  insert into icx_failures
                     (user_name,password,failure_code,failure_date,
                      created_by, creation_date, last_updated_by,
                     last_update_date, last_update_login)
                  values
                     (i_1,-1,
                 'ICX_ACCT_EXPIRED',sysdate,
                      nvl(u.user_id,-1), sysdate, nvl(u.user_id,-1),
                      sysdate, u.user_id);

                  return '-1';

               when e_signin_invalid OR e_invalid_password
               then
                  if c_validate_only = 'N'
                  then
                     fnd_message.set_name('ICX','ICX_SIGNIN_INVALID');
                     c_error_msg := fnd_message.get;
                     fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
                     c_login_msg := fnd_message.get;

                     OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
                  end if;

                  v_encrypted_psswd := icx_call.encrypt(i_2);

                  insert into icx_failures
                     (user_name,password,failure_code,failure_date,
                      created_by, creation_date, last_updated_by,
                     last_update_date, last_update_login)
                  values
                     (i_1,v_encrypted_psswd,'ICX_SIGNIN_INVALID',sysdate,
                      '-1', sysdate, '-1', sysdate, '-1');
                  return '-1';

               when others
               then
                  if c_validate_only = 'N'
                  then
                     fnd_message.set_name('ICX','ICX_SIGNIN_INVALID');
                     c_error_msg := fnd_message.get;
                     fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
                     c_login_msg := fnd_message.get;

                     OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
                  end if;
            /*
                when others then
               htp.p(SQLERRM);
            */
                  return '-1';
            END;


--  ***********************************************
--      function recreateURL
--  ***********************************************

function recreateURL(p_session_id IN NUMBER,
                     p_user_name  in varchar2)
                 return VARCHAR2 is
   l_url VARCHAR2(600);
   l_url2 VARCHAR2(600);
   l_url3 VARCHAR2(600);

   l_mode VARCHAR2(20);
   l_errm VARCHAR2(2000);

BEGIN

   -- commented out all portal redirect code from here and let it be handled in displayLogin

   --get mode_code to see if a portal session
--   SELECT mode_code
--      INTO l_mode
--      FROM icx_sessions
--      WHERE session_id=p_session_id;
   --get home_url so we know where to send after portal logout
--   SELECT home_url
--      INTO l_url3
--      FROM icx_parameters;

--   l_url3:= wfa_html.conv_special_url_chars(l_url3);

   --if portal
--   IF l_mode='115X'  THEN

--      fnd_profile.get(name    => 'APPS_PORTAL',
--                              val     => l_url);

--      l_url2 := wfa_html.conv_special_url_chars(l_url);
--      l_url := replace(l_url,'home','wwsec_app_priv.logout ?p_done_url='||(nvl(l_url3,l_url2)));

      --else PHP
--      ELSE
         l_url:=FND_WEB_CONFIG.TRAIL_SLASH(fnd_profile.value('APPS_WEB_AGENT'))||'OracleApps.displayLogin?recreate='||icx_call.encrypt(p_session_id||'*'||p_user_name||'**]');

--   END IF;
   return (l_url);


EXCEPTION
   WHEN OTHERS THEN
      l_errm:=SQLERRM;
      RETURN ('ERROR - '||l_errm);
end;

--newSessionRaiseEvent will raise the WF Business Event oracle.apps.icx.security.session.created
--mputman 1513025
procedure newSessionRaiseEvent (p_user_id     in varchar2,
                               p_session_id  in varchar2) is

l_parameterList      WF_PARAMETER_LIST_T;

begin

  --Initialize the parameter list.

  l_parameterList := WF_PARAMETER_LIST_T(null);

  --Populate the first subscript with param1, then extend the varray.

  l_parameterList(1) := wf_parameter_t('p_user_id', p_user_id);

  l_parameterList.EXTEND;

  --Populate the second, but do not extend (will get an ORA-30625 if you do.)

  l_parameterList(2) := wf_parameter_t('p_session_id', p_session_id);

  --Raise the event
    --htp.p('####NSRE-5####');--debug mputman

  WF_EVENT.Raise(p_event_name=>'oracle.apps.icx.security.session.created',
                 p_event_key=>to_char(sysdate, 'HH:MI:SS'),
                 p_parameters=>l_parameterList);
    --htp.p('####NSRE-6####');--debug mputman

end;

--doNewSessionEvent is a function that can be called via an event subscription to
--disable all other sessions for the user_id except the session_id
--(user_id and session_id are retrieved from the p_evtMsg type).
--mputman 1513025
function  doNewSessionEvent  (p_guid       in raw,
                     p_evtMsg     in out NOCOPY wf_event_t) return varchar2 is
   l_user_id VARCHAR2(80);
   l_user_name VARCHAR2(240);
   l_session_id VARCHAR2(80);
   l_except_ids VARCHAR2(4000);

begin

   --Access p_user_id
   l_user_id := p_evtMsg.GetValueForParameter('p_user_id');
   --Access p_session_id
   l_session_id := p_evtMsg.GetValueForParameter('p_session_id');

   BEGIN
      SELECT user_name
         INTO l_user_name
         FROM fnd_user
         WHERE user_id=l_user_id;
   EXCEPTION
      WHEN OTHERS THEN
         WF_CORE.CONTEXT('icx_sec', 'doNewSessionEvent',p_evtMsg.getEventName( ), p_guid);
         WF_EVENT.setErrorInfo(p_evtMsg, 'ERROR');
         return 'ERROR';
   END;

BEGIN

   SELECT substrb(parameters,(instrb(parameters,'=',1)+1))
         INTO l_except_ids
         FROM wf_event_subscriptions
         WHERE guid=p_guid;



EXCEPTION
   WHEN no_data_found THEN
      WF_CORE.CONTEXT('icx_sec', 'doNewSessionEvent',p_evtMsg.getEventName( ), p_guid);
      WF_EVENT.setErrorInfo(p_evtMsg, 'ERROR');
return 'ERROR';

END;

IF (instrb((nvl(l_except_ids,' ')),l_user_name) = 0) THEN


   BEGIN
   UPDATE icx_sessions
      SET disabled_flag='Y'
      WHERE user_id = l_user_id
      AND session_id <> l_session_id
      AND mode_code = '115P';
      COMMIT;

   EXCEPTION
      WHEN OTHERS THEN
         WF_CORE.CONTEXT('icx_sec', 'doNewSessionEvent',p_evtMsg.getEventName( ), p_guid);
         WF_EVENT.setErrorInfo(p_evtMsg, 'ERROR');

         return 'ERROR';
   END;
   NULL;
   END IF;


   return 'SUCCESS';

end;

/*
--  ***********************************************
--      function newLoginId
--  ***********************************************

function newLoginId
                     return number is

l_login_id            number;

begin

select fnd_logins_s.nextval
  into l_login_id
  from sys.dual;


return(l_login_id);
end;

*/


--disableSession is to be used with high availability to
--disable all sessions that are older than the threshold value (mins)
-- added for 2124463
PROCEDURE disableSessions (threshold IN NUMBER)
   IS

BEGIN

   UPDATE icx_sessions
      SET disabled_flag='Y'
      WHERE
      (((SYSDATE-first_connect)*24*60)> threshold);

   COMMIT;
END;

FUNCTION anonFunctionTest(p_func_id IN VARCHAR2,
                          p_user_id IN NUMBER)

                          RETURN BOOLEAN IS

--b_allowed BOOLEAN DEFAULT FALSE;
n_hits    NUMBER DEFAULT 0;
l_anon_name VARCHAR2(400);
l_anon_user_id NUMBER;
x VARCHAR2(400);


BEGIN
IF p_user_id IS NULL THEN

  -- fnd_profile.get(name    => 'GUEST_USER_PWD',
                  -- val     => l_anon_name);
  -- Using new api to retrieve GUEST credentials.
  l_anon_name := fnd_web_sec.get_guest_username_pwd;
  l_anon_name  := SUBSTR(l_anon_name, 1, INSTR(l_anon_name, '/') -1);
  BEGIN
    SELECT user_id
      INTO l_anon_user_id
      FROM fnd_user
      WHERE user_name = l_anon_name;
    EXCEPTION
      WHEN no_data_found THEN
        l_anon_user_id := -999;
  END;
  ELSE
  l_anon_user_id := p_user_id;

END IF;
  select count(*)
  INTO n_hits
  from FND_FORM_FUNCTIONS a,
  fnd_menu_entries_vl b,
  fnd_responsibility_vl c,
  fnd_user_resp_groups d,
  fnd_security_groups_vl e
  where d.user_id = l_anon_user_id
  AND a.function_id = p_func_id
  and b.function_id = a.function_id
  and d.responsibility_application_id = c.application_id
  and b.MENU_ID = c.MENU_ID
  and c.responsibility_id = d.responsibility_id
  and type in ('WWW','WWK','JSP','SERVLET', 'INTEROPJSP')
  and d.start_date <= sysdate
  and (d.end_date is null or d.end_date > sysdate)
  and d.SECURITY_GROUP_ID = e.SECURITY_GROUP_ID
  and prompt is not null
  and nvl(a.function_id,-1) not IN
         (select ACTION_ID
          from   FND_RESP_FUNCTIONS
          where  RESPONSIBILITY_ID = c.responsibility_id
          and    APPLICATION_ID    = d.responsibility_application_id)
  and nvl(SUB_MENU_ID,-1) not IN -- submenu exclusions 2029055
         (select ACTION_ID
          from   FND_RESP_FUNCTIONS
          where  RESPONSIBILITY_ID = c.responsibility_id
          and    APPLICATION_ID    = d.responsibility_application_id);
          IF (n_hits >0) THEN
             RETURN TRUE;
             ELSE
             RETURN FALSE;
          END IF;

EXCEPTION
   WHEN OTHERS THEN
   x := SQLERRM;

     RETURN FALSE;
END; -- anonFucntionTest

PROCEDURE setUserNLS  (p_user_id             IN NUMBER,
                        l_language                OUT NOCOPY  varchar2,
                        l_language_code        OUT NOCOPY  varchar2,
                        l_date_format          OUT NOCOPY  varchar2,
                        l_date_language        OUT NOCOPY  varchar2,
                        l_numeric_characters     OUT NOCOPY varchar2,
                        l_nls_sort          OUT NOCOPY varchar2,
                        l_nls_territory          OUT NOCOPY varchar2,
                        l_limit_time                   OUT NOCOPY NUMBER,
                        l_limit_connects    OUT NOCOPY NUMBER,
                        l_org_id              OUT NOCOPY varchar2)

 IS


 l_timeout               number;


 begin

 setUserNLS(p_user_id,
             l_language,
             l_language_code,
             l_date_format,
             l_date_language,
             l_numeric_characters,
             l_nls_sort,
             l_nls_territory,
             l_limit_time,
             l_limit_connects,
             l_org_id,
             l_timeout);


END;--setUserNLS



PROCEDURE setUserNLS  (p_user_id             IN NUMBER,
                        l_language                OUT NOCOPY  varchar2,
                        l_language_code        OUT NOCOPY  varchar2,
                        l_date_format          OUT NOCOPY  varchar2,
                        l_date_language        OUT NOCOPY  varchar2,
                        l_numeric_characters     OUT NOCOPY varchar2,
                        l_nls_sort          OUT NOCOPY varchar2,
                        l_nls_territory          OUT NOCOPY varchar2,
                        l_limit_time                   OUT NOCOPY NUMBER,
                        l_limit_connects    OUT NOCOPY NUMBER,
                        l_org_id              OUT NOCOPY varchar2,
                        l_timeout             OUT NOCOPY NUMBER)

 IS
 -- l_language     varchar2(80);
 -- l_language_code      varchar2(30);
 -- l_date_format     varchar2(150);
 -- l_date_language      varchar2(30);
 -- l_numeric_characters varchar2(30);
 -- l_nls_sort        varchar2(30);
 -- l_nls_territory         varchar2(30);
 -- l_limit_time      number;
 -- l_limit_connects  number;
 -- l_multi_org_flag        varchar2(1);
 -- l_org_id                varchar2(50);
 l_multi_org_flag        varchar2(1);
 l_profile_defined       boolean;
 db_lang                 varchar2(512);
 lang                    varchar2(255);
 l_nls_characterset      varchar2(50);

 c_language              varchar2(30);
 l_login_id              NUMBER;
 l_expired               VARCHAR2(5);

 cursor c1 (lang in varchar2) is
   select UTF8_DATE_LANGUAGE
     from FND_LANGUAGES
    where NLS_LANGUAGE = lang;

 cursor c2 (lang in varchar2) is
   select LOCAL_DATE_LANGUAGE
     from FND_LANGUAGES
    where NLS_LANGUAGE = lang;

 begin

     -- The following Profiles should be set

     fnd_profile.get_specific(name_z       => 'ICX_LANGUAGE',
                              user_id_z    => p_user_id,
                              val_z        => l_language,
                              defined_z    => l_profile_defined);

     if l_language is null then

        /*
         select upper(value)
           into l_language
           from v$nls_parameters
          where parameter = 'NLS_LANGUAGE';
     */ -- removed select 1574527 mputman

        l_language:=getNLS_PARAMETER('NLS_LANGUAGE'); -- replaces above select mputman 1574527

     end if;

     select language_code
       into l_language_code
       from fnd_languages
      where nls_language = l_language;

     fnd_profile.get_specific(name_z     => 'ICX_NLS_SORT',
                              user_id_z  => p_user_id,
                              val_z      => l_nls_sort,
                              defined_z  => l_profile_defined);

     if l_nls_sort is null then
        /*
         select  upper(value)
           into  l_nls_sort
           from  v$nls_parameters
          where  parameter = 'NLS_SORT';
               */
    l_nls_sort:=getNLS_PARAMETER('NLS_SORT'); -- replaces above select mputman 1574527


     end if;

     fnd_profile.get_specific(name_z       => 'ICX_DATE_FORMAT_MASK',
                              user_id_z    => p_user_id,
                              val_z        => l_date_format,
                              defined_z    => l_profile_defined);

     if l_date_format is null  then
        /*
         select  upper(value)
           into  l_date_format
           from  v$nls_parameters
          where  parameter = 'NLS_DATE_FORMAT';
          */
       l_date_format:=getNLS_PARAMETER('NLS_DATE_FORMAT'); -- replaces above select mputman 1574527

     end if;

     l_date_format := replace(upper(l_date_format), 'YYYY', 'RRRR');
     l_date_format := replace(l_date_format, 'YY', 'RRRR');
     if (instr(l_date_format, 'RR') > 0) then
         if (instr(l_date_format, 'RRRR')  = 0) then
             l_date_format := replace(l_date_format, 'RR', 'RRRR');
         end if;
     end if;

     /* set the NLS date language.  Get it from the FND_LANGUAGES table,
        choosing which column based on whether the codeset is UTF8
        or AL32UTF8. But the profile ICX_DATE_LANGUAGE overrides
        all that if it is set.
     */

     fnd_profile.get_specific(name_z     => 'ICX_DATE_LANGUAGE',
                              user_id_z  => p_user_id,
                              val_z      => l_date_language,
                              defined_z  => l_profile_defined);

     if l_date_language is null then
        l_nls_characterset := getNLS_PARAMETER('NLS_CHARACTERSET');
        if (l_nls_characterset in ('UTF8', 'AL32UTF8')) then
           open c1(l_language);
           fetch c1 into l_date_language;
           close c1;
        else
           open c2(l_language);
           fetch c2 into l_date_language;
           close c2;
        end if;

     end if;

     fnd_profile.get_specific(name_z     => 'ICX_NUMERIC_CHARACTERS',
                              user_id_z  => p_user_id,
                              val_z      => l_numeric_characters,
                              defined_z  => l_profile_defined);

     if l_numeric_characters is null then
        /*
         select upper(value)
           into l_numeric_characters
           from v$nls_parameters
          where parameter = 'NLS_NUMERIC_CHARACTERS';
          */
       l_numeric_characters:=getNLS_PARAMETER('NLS_NUMERIC_CHARACTERS'); -- replaces above select mputman 1574527

     end if;

     fnd_profile.get_specific(name_z     => 'ICX_TERRITORY',
                              user_id_z  => p_user_id,
                              val_z      => l_nls_territory,
                              defined_z  => l_profile_defined);

     if l_nls_territory is null then
        /*
         select upper(value)
           into l_nls_territory
           from v$nls_parameters
          where parameter = 'NLS_TERRITORY';
          */
    l_nls_territory:=getNLS_PARAMETER('NLS_TERRITORY'); -- replaces above select mputman 1574527


     end if;

     fnd_profile.get_specific(name_z    => 'ICX_LIMIT_TIME',
                              user_id_z => p_user_id,
                              val_z     => l_limit_time,
                              defined_z => l_profile_defined);

     if l_limit_time is null then
         l_limit_time := 4;
     end if;

     fnd_profile.get_specific(name_z    => 'ICX_LIMIT_CONNECT',
                              user_id_z => p_user_id,
                              val_z     => l_limit_connects,
                              defined_z => l_profile_defined);

     if l_limit_connects is null
     then
         l_limit_connects := 1000;
     end if;

    fnd_profile.get_specific(name_z    => 'ICX_SESSION_TIMEOUT',
                             user_id_z => p_user_id,
                             val_z     => l_timeout,
                             defined_z => l_profile_defined);


    select multi_org_flag
      into l_multi_org_flag
      from fnd_product_groups
     where rownum < 2;

    if l_multi_org_flag = 'Y' then
      fnd_profile.get_specific(name_z    => 'ORG_ID',
                               val_z     => l_org_id,
                               defined_z => l_profile_defined);
    end if;

 END;--setUserNLS



end icx_sec;

/
