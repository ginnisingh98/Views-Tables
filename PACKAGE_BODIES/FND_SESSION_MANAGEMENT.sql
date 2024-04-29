--------------------------------------------------------
--  DDL for Package Body FND_SESSION_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SESSION_MANAGEMENT" as
/* $Header: AFICXSMB.pls 120.26.12010000.19 2016/04/28 17:02:42 stadepal ship $ */

-- CONSTANTS for Language Calculation configuration
--
LC_PREF_USER CONSTANT VARCHAR2(20):= '#INTERNAL';
LC_PREF_MODULE CONSTANT VARCHAR2(20):= 'LANGUAGE_CALC';
LC_SAMEFORALL CONSTANT VARCHAR2(20) := '*SAME*FOR*ALL*';


--  ***********************************************
--      function NewSessionId
--  ***********************************************



function NewSessionId return number is

l_session_id number;
x_session_id varchar2(1) := 'N';

begin

  l_session_id := fnd_crypto.SmallRandomNumber;

  loop

    select 'Y' into x_session_id from icx_sessions
    where session_id =  l_session_id;

    if x_session_id = 'Y'
    then
      l_session_id := fnd_crypto.SmallRandomNumber;
    else
      return(l_session_id);
    end if;

  end loop;

exception
  when no_data_found
  then
    return(l_session_id);
end NewSessionId;

function NewXSID return varchar2 is

l_XSID varchar2(32);
x_XSID varchar2(1) := 'N';

begin

  -- l_XSID := fnd_crypto.encode(fnd_crypto.RandomBytes(18),fnd_crypto.ENCODE_URL);
  -- Bug#4192742. XSID which is stored as cookie value can't contain illegal
  -- characters. Hence using fnd_crypto.RandomString to generate alpha numeric
  -- string as XSID.
  l_XSID := fnd_crypto.RandomString(len=>26,
                                msk=> FND_CRYPTO_CONSTANTS.ALPHANUMERIC_MASK);

  loop

    select 'Y' into x_XSID from icx_sessions
    where XSID =  l_XSID;

    if x_XSID = 'Y'
    then
      -- l_XSID := fnd_crypto.encode(fnd_crypto.RandomBytes(18),fnd_crypto.ENCODE_URL);
      -- Bug#4192742. XSID which is stored as cookie value can't contain illegal
      -- characters. Hence using fnd_crypto.RandomString to generate
      -- alpha numeric string as XSID.
      l_XSID := fnd_crypto.RandomString(len=>26,
                                msk=> FND_CRYPTO_CONSTANTS.ALPHANUMERIC_MASK);
    else
      -- return(l_XSID||':S');
      return(l_XSID);
    end if;

  end loop;

exception
  when no_data_found
  then
    -- return(l_XSID||':S');
    return(l_XSID);
end NewXSID;

function NewTransactionId return number is

 l_transaction_id number;
 x_transaction_id varchar2(1) := 'N';

 begin

   l_transaction_id := fnd_crypto.SmallRandomNumber;

   loop

     select 'Y' into x_transaction_id from icx_transactions
     where transaction_id =  l_transaction_id;

     if x_transaction_id = 'Y'
     then
       l_transaction_id := fnd_crypto.SmallRandomNumber;
     else
       return(l_transaction_id);
     end if;

   end loop;

 exception
   when no_data_found
   then
     return(l_transaction_id);
 end NewTransactionId;


function NewTransactionId(p_session_id in number)
 return number is

l_transaction_id number;
x_transaction_id varchar2(1) := 'N';

begin

  l_transaction_id := fnd_crypto.SmallRandomNumber;

  loop

    select 'Y' into x_transaction_id from icx_transactions
    where transaction_id =  l_transaction_id
    and SESSION_ID = p_session_id
    and DISABLED_FLAG <> 'Y';

    if x_transaction_id = 'Y'
    then
      l_transaction_id := fnd_crypto.SmallRandomNumber;
    else
      return(l_transaction_id);
    end if;

  end loop;

exception
  when no_data_found
  then
    return(l_transaction_id);
end NewTransactionId;

function NewXTID return varchar2 is

l_XTID varchar2(32);
x_XTID varchar2(1);

begin

  l_XTID := fnd_crypto.encode(fnd_crypto.RandomBytes(18),fnd_crypto.ENCODE_URL);

  loop

    select 'Y' into x_XTID from icx_transactions
    where XTID =  l_XTID;

    if x_XTID = 'Y'
    then
      l_XTID := fnd_crypto.encode(fnd_crypto.RandomBytes(18),fnd_crypto.ENCODE_URL);
    else
      return(l_XTID||':T');
    end if;

  end loop;

exception
  when no_data_found
  then
    return(l_XTID||':T');
end NewXTID;


--newSessionRaiseEvent will raise the WF Business Event oracle.apps.icx.security.session.created
--mputman 1513025
procedure newSessionRaiseEvent(p_user_id     in varchar2,
                               p_session_id  in varchar2) is

l_parameterList      WF_PARAMETER_LIST_T;

begin

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
                          , 'fnd.plsql.FND_SESSION_MANAGEMENT.newSessionRaiseEvent','BEGIN');
    end if;
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                          , 'fnd.plsql.FND_SESSION_MANAGEMENT.newSessionRaiseEvent',
                    'userid='||NVL(p_user_id,'**NULL**')
		||' sessionId='||NVL(p_session_id,'**NULL*')
                );
    end if;
  --Initialize the parameter list.

  l_parameterList := WF_PARAMETER_LIST_T(null);

  --Populate the first subscript with param1, then extend the varray.

  l_parameterList(1) := wf_parameter_t('p_user_id', p_user_id);

  l_parameterList.EXTEND;

  --Populate the second, but do not extend (will get an ORA-30625 if you do.)

  l_parameterList(2) := wf_parameter_t('p_session_id', p_session_id);

  --Raise the event

  begin
    WF_EVENT.Raise(p_event_name=>'oracle.apps.icx.security.session.created',
                   p_event_key=>to_char(sysdate, 'HH:MI:SS'),
                   p_parameters=>l_parameterList);
    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
                          , 'fnd.plsql.FND_SESSION_MANAGEMENT.newSessionRaiseEvent','END');
    end if;
  exception
    when others then
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED
                          , 'fnd.plsql.FND_SESSION_MANAGEMENT.newSessionRaiseEvent','END with errors '||sqlerrm);
    end if;
      null; -- allows login to continue if WF process not installed.
  end;

end newSessionRaiseEvent;

--doNewSessionEvent is a function that can be called via an event subscription to
--disable all other sessions for the user_id except the session_id
--(user_id and session_id are retrieved from the p_evtMsg type).
--mputman 1513025
function  doNewSessionEvent(p_guid       in raw,
                            p_evtMsg     in out NOCOPY wf_event_t)
          return varchar2 is

   l_user_id VARCHAR2(80);
   l_user_name VARCHAR2(240);
   l_session_id VARCHAR2(80);
   l_except_ids VARCHAR2(4000);
   -- bug:7715927
   l_login_id NUMBER;
   l_audit_level VARCHAR2(1);

   cursor  c_end_date_fndlogins  is
    SELECT  login_id
    from  ICX_SESSIONS
    where  user_id = l_user_id
    and session_id <> l_session_id
    and disabled_flag = 'N'
    and mode_code = '115P'
    and user_id <> 6;
-- Added the  last 2 lines in above cursor for CTILLY for bug#8964712


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
   WF_CORE.CONTEXT('fnd_session_management', 'doNewSessionEvent',p_evtMsg.getEventName( ), p_guid);
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
   WF_CORE.CONTEXT('fnd_session_management', 'doNewSessionEvent',p_evtMsg.getEventName( ), p_guid);
   WF_EVENT.setErrorInfo(p_evtMsg, 'ERROR');
  return 'ERROR';
 END;

 IF (instrb((nvl(l_except_ids,' ')),l_user_name) = 0)
 THEN
  BEGIN

   -- bug:7715927
   l_audit_level:=fnd_profile.value('SIGNONAUDIT:LEVEL');

   IF (l_audit_level is not null) THEN
      FOR end_date_rec in c_end_date_fndlogins LOOP
         fnd_signon.audit_end(l_login_id);  -- end date FND_LOGINS
      END LOOP;
   END IF;


   UPDATE icx_sessions
   SET disabled_flag='Y'
   WHERE user_id = l_user_id
   AND session_id <> l_session_id
   AND mode_code = '115P';

   COMMIT;

  EXCEPTION
   WHEN OTHERS THEN
    WF_CORE.CONTEXT('fnd_session_management', 'doNewSessionEvent',p_evtMsg.getEventName( ), p_guid);
    WF_EVENT.setErrorInfo(p_evtMsg, 'ERROR');
    return 'ERROR';
  END;
  NULL;
 END IF;

 return 'SUCCESS';

end;


/*
 * Fetches the values of the FND_FIXED_KEY_ENABLED and FND_FIXED_SEC_KEY
 * profiles to use as the mac and encryption key for the session.  If not
 * specified, just returns nulls.  Raises an exception
 * if the values are set but improperly defined.
 */
procedure get_fixed_sec_keys(p_user_id in number,
                             p_mac_key out nocopy raw,
                             p_enc_key out nocopy raw) is
 e_invalid_fixed_key     exception;
 lf_key                  varchar2(64);
 lm_key                  varchar2(40);
 l_fixed_key             varchar2(10);
 l_profile_defined       boolean;
begin
 fnd_profile.get_specific(name_z    => 'FND_FIXED_KEY_ENABLED',
                          user_id_z => p_user_id,
                          val_z     => l_fixed_key,
                          defined_z => l_profile_defined);
 if(l_fixed_key = 'Y') then
   fnd_profile.get_specific(name_z    => 'FND_FIXED_SEC_KEY',
                            user_id_z => p_user_id,
                            val_z     => lf_key,
                            defined_z => l_profile_defined);

   if(length(lf_key) <> 64) then
     raise e_invalid_fixed_key;
   end if;
   p_enc_key := hextoraw(lf_key);
   lm_key := substr(lf_key, 0, 40);
   p_mac_key := hextoraw(lm_key);
 else
   p_enc_key := null;
   p_mac_key := null;
 end if;
exception
 when others then
   app_exception.raise_exception(exception_text=>
      'Invalid Key defined in the profile FND_FIXED_SEC_KEY.' ||
      ' The key should be a Hexadecimal string of length 64');
   app_exception.raise_exception;
end get_fixed_sec_keys;


function createSessionPrivate(p_user_id     in number,
                              p_session_id  in number,
                              p_pseudo_flag in varchar2,
                              c_mode_code   in varchar2,
                              p_server_id   in varchar2,
                              p_home_url    in varchar2,
                              p_language_code in varchar2,
                              p_proxy_user  in number)
          return varchar2  is

PRAGMA AUTONOMOUS_TRANSACTION; --(gjimenez -> bug#4163368)

l_language		varchar2(80);
l_language_code		varchar2(30);
l_date_format		varchar2(150);
l_date_language		varchar2(30);
l_numeric_characters	varchar2(30);
l_nls_sort      	varchar2(30);
l_nls_territory      	varchar2(30);
l_limit_time		number;
l_limit_connects	number;
l_org_id                varchar2(50);
l_timeout               number;

l_login_id              NUMBER;
l_node_id               number;
l_XSID                  varchar2(32);
l_guest                 varchar2(30);
l_guest_username        varchar2(240);
l_guest_user_id         number;
l_profile_defined       boolean;
l_dist                  varchar2(30);
l_enc_key               raw(32);
l_mac_key               raw(20);
e_invalid_fixed_key     exception;
lf_key                  varchar2(64);
lm_key                  varchar2(40);
l_fixed_key             varchar2(10);
l_module varchar2(100) := 'fnd.plsql.FND_SESSION_MANAGEMENT.createSessionPrivate';
begin
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,  l_module, 'BEGIN');
  end if;

  begin
    select node_id into l_node_id from fnd_nodes
    where server_id = p_server_id;
  exception
    when no_data_found THEN
    l_node_id := 9999;
  end;

  -- BUG 5354477 amgonzal
  -- Finding the corresponding ICX_SESSION_TIMEOUT for the new session to be created.
  --

  -- There are not responsibility_id and app_resp_id defined.
  l_profile_defined := false;
  fnd_profile.get_specific  (name_z => 'ICX_SESSION_TIMEOUT',
                            user_id_z => p_user_id,
                            val_z => l_timeout,
                            defined_z => l_profile_defined);
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,  l_module||'.timeout',
                      'timeout : ' || to_char(l_timeout) || ' User Id : ' || to_char (p_user_id));
  end if;
  -- end BUG 5354477

  -- Bug 19694125 : Checking for proxy user and if yes then setting
  -- proxy user_id so that NLS preference of proxy user is used

    if (p_proxy_user is not null) then
       fnd_session_management.g_proxy_user_id := p_proxy_user;
    end if;

    setUserNLS(p_user_id,
               p_language_code,
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

   -- bug 3375261, switched to new version of new_icx_session to
   -- not perform password related operations when creating a session
   -- fnd_signon.new_icx_session(p_user_id,
   --                            l_login_id);
   -- Call new api new_proxy_icx_session(new version of new_icx_session) which
   -- has an extra param to indicate whether it's creation of proxy session
   -- (or) normal session
   fnd_signon.new_proxy_icx_session(UID => p_user_id,
                                    proxy_user => p_proxy_user,
                                    login_id => l_login_id);


   l_XSID := NewXSID;

   -- Is user GUEST
   -- fnd_profile.get_specific
              -- (name_z    => 'GUEST_USER_PWD',
               -- val_z     => l_guest_username ,
               -- defined_z => l_profile_defined);
     -- Using new api to retrieve GUEST credentials.
     l_guest_username := fnd_web_sec.get_guest_username_pwd;

   l_guest_username := UPPER(SUBSTR(l_guest_username,1,INSTR(l_guest_username,'/') -1));
   BEGIN
    SELECT user_id
      INTO l_guest_user_id
      FROM fnd_user
      WHERE user_name = l_guest_username;
    EXCEPTION
      WHEN no_data_found THEN
        l_guest_user_id := -999;
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

   -- fetch values for the encryption keys
   get_fixed_sec_keys(p_user_id, l_mac_key, l_enc_key);
   if ( l_mac_key is null or l_enc_key is null ) then
     l_enc_key := fnd_crypto.RandomBytes(32);
     l_mac_key := fnd_crypto.RandomBytes(20);
   end if;

   insert into icx_sessions (
		session_id,
		user_id,
                org_id,
		security_group_id,
		mode_code,
                home_url,
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
                DISTRIBUTED,
                proxy_user_id)
       values (
	        p_session_id,
		p_user_id,
                l_org_id,
		fnd_session_management.g_security_group_id,
		c_mode_code,
                p_home_url,
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
                l_login_id, -- mputman added login_id per 2020952
                l_mac_key,
                l_enc_key,
                l_XSID,
                l_timeout,
                l_guest,
                l_dist,
                p_proxy_user);

   commit;

  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,  l_module, 'END');
  end if;
       return '0';
  EXCEPTION WHEN OTHERS THEN
	  if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED ,  l_module, 'Exception:'||sqlcode||' '||sqlerrm);
	  end if;
        RAISE;
-- exception
--  when others then
--       return -1;
end;

-- p_language_code added for enh. 4082741.
-- if a non-null language code is passed in and is one
-- of the installed languages, the language code
-- and nls language settings for the session to be created
-- will overwrite what's specified in the nls profiles.
-- The other nls settings will still get their values from
-- the profiles.
function createSession(p_user_id   in number,
                       c_mode_code in varchar2,
                       c_sec_grp_id in NUMBER,
                       p_server_id in varchar2,
                       p_home_url in varchar2,
                       p_language_code in varchar2,
                       p_proxy_user in number)
           return number is

l_session_id            number;
l_message               varchar2(80);
l_module varchar2(200):= 'fnd.plsql.FND_SESSION_MANAGEMENT.createSession';
l_secured_mode varchar2(1);

begin

  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,  l_module, 'BEGIN');
  end if;

  fnd_profile.get(name         => 'APPS_SECURITY_CONFIG_MAINTENANCE_MODE',
                  val          => l_secured_mode);

  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,  l_module, 'Security Config Mode is -> '||l_secured_mode);
  end if;

  if (l_secured_mode = 'Y' and p_user_id <> 6) then
    -- Don't allow creation of session from anywhere
    return -1;
  end if;

     fnd_session_management.g_security_group_id := c_sec_grp_id;


    l_session_id := NewSessionId;
    l_message :=  createSessionPrivate(	p_user_id     => p_user_id,
                                        p_server_id   => p_server_id,
					p_session_id  => l_session_id,
					p_pseudo_flag => 'N',
					c_mode_code   => nvl(c_mode_code,'115P'),
                                        p_home_url => p_home_url,
                                        p_language_code => p_language_code,
                                        p_proxy_user => p_proxy_user);
    if l_message = '0'
    then
       newSessionRaiseEvent(p_user_id,l_session_id);
       newSSOSession(p_user_id,l_session_id);

       if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,  l_module, 'END->'||l_session_id);
       end if;
       return l_session_id;
    else
       if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,  l_module, 'END->-1(l_message=0)');
       end if;
       return -1;
    end if;

  EXCEPTION WHEN OTHERS THEN
	  if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED ,  l_module, 'Exception:'||sqlcode||' '||sqlerrm);
	  end if;
        RAISE;
-- exception
--  when others then
--       return -1;
end;

function convertGuestSession(p_user_id in number,
			     p_server_id in varchar2,
			     p_session_id in varchar2,
                             p_language_code in varchar2,
                             c_sec_grp_id    in number,
                             p_home_url in varchar2,
                             p_mode_code in varchar2)
        return varchar2 is
pragma AUTONOMOUS_TRANSACTION;
l_mode_code             varchar2(30);
l_language		varchar2(80);
l_language_code		varchar2(30);
l_date_format		varchar2(150);
l_date_language		varchar2(30);
l_numeric_characters	varchar2(30);
l_nls_sort      	varchar2(30);
l_nls_territory      	varchar2(30);
l_limit_time		number;
l_limit_connects	number;
l_org_id                varchar2(50);
l_timeout               number;
l_session_id               number;

l_login_id              NUMBER;
l_node_id               number;
l_XSID                  varchar2(32);
l_guest                 varchar2(30);
l_guest_username        varchar2(240);
l_guest_user_id         number;
l_profile_defined       boolean;
l_dist                  varchar2(30);
l_user_id               number;
l_enc_key               raw(32);
l_mac_key               raw(20);

l_resp_id         number;
l_resp_app_id     number;
l_curr_timeout    number;
l_profile_timeout number;

l_audit_level     varchar2(1) := null;
l_from_login_id         NUMBER;
l_module varchar2(200):= 'fnd.plsql.FND_SESSION_MANAGEMENT.convertGuestSession';

begin
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,  l_module, 'BEGIN');
  end if;
 -- check if user exists
 begin
  select user_id into l_user_id from fnd_user
  where user_id = p_user_id and
        (start_date <= sysdate) and
        (end_date is null or end_date>sysdate);
  exception
    when no_data_found then
      rollback;
       if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,  l_module, 'END-> user not found');
       end if;
      return 'N';
 end;
  -- check if it is guest session
  begin
    select session_id,guest, mode_code, time_out, responsibility_application_id, responsibility_id, login_id
      into l_session_id,l_guest, l_mode_code, l_curr_timeout, l_resp_app_id, l_resp_id, l_from_login_id
      from icx_sessions
     where xsid = p_session_id;
  exception
    when no_data_found then
       if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,  l_module, 'END-> session not found');
       end if;
    rollback;
    return 'N';
  end;
  if (l_guest <> 'Y') then
    rollback;
       if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,  l_module, 'END-> no guest session ');
       end if;
    return 'N';
  end if;

   -- check if switched-to user is GUEST
   -- fnd_profile.get_specific
              -- (name_z    => 'GUEST_USER_PWD',
               -- val_z     => l_guest_username ,
               -- defined_z => l_profile_defined);
     -- Using new api to retrieve GUEST credentials.
     l_guest_username := fnd_web_sec.get_guest_username_pwd;

   l_guest_username := UPPER(SUBSTR(l_guest_username,1,INSTR(l_guest_username,'/') -1));
   BEGIN
    SELECT user_id
      INTO l_guest_user_id
      FROM fnd_user
      WHERE user_name = l_guest_username;
    EXCEPTION
      WHEN no_data_found THEN
        l_guest_user_id := -999;
   END;

   if l_guest_user_id = p_user_id
   then
     rollback;
       if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,  l_module, 'END-> guest target user ');
       end if;
     return 'N';
   end if;


  fnd_session_management.g_security_group_id := c_sec_grp_id;

  begin
    select node_id into l_node_id from fnd_nodes
    where server_id = p_server_id;
  exception
    when no_data_found THEN
    l_node_id := 9999;
  end;

    -- Bug 5354477 amgonzal
    -- Finding the ICX_SESSION_TIMEOUT for the user session being converted
    --
    l_profile_defined := false;
    fnd_profile.get_specific (name_z                     => 'ICX_SESSION_TIMEOUT',
                            user_id_z                  => p_user_id,
                            responsibility_id_z        => l_resp_id,
                            application_id_z           => l_resp_app_id,
                            val_z                      => l_profile_timeout,
                            defined_z                  => l_profile_defined);
    if l_profile_defined then
      l_timeout := l_profile_timeout;
    else
      l_timeout := l_curr_timeout;
    end if;
    l_profile_defined := false;


  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                     ,  'fnd.plsql.FND_SESSION_MANAGEMENT.convertGuestSession.timeout'
                     , 'timeout : ' || to_char(l_timeout) || ' User Id : ' || to_char (p_user_id)
                       || ' Resp ID: ' || to_char(l_resp_id)
                       || ' Resp app ID : ' || to_char(l_resp_app_id));
  end if;
    -- end BUG 5354477


    setUserNLS(p_user_id,
               p_language_code,
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

   -- Bug 6010245 Guest Login is not being end dated in FND_LOGINS.
   -- AMGONZAL.

  l_audit_level:=fnd_profile.value('SIGNONAUDIT:LEVEL');
  if (l_audit_level is not null) and ( l_from_login_id is not null) then
     fnd_signon.audit_end(l_from_login_id); -- end guest audit session and resps.
  end if;

   fnd_signon.new_icx_session(p_user_id,
                              l_login_id);

   get_fixed_sec_keys(p_user_id, l_mac_key, l_enc_key);

   -- Session Hijacking fix

   -- Bug 13487530
   --   If R12.1 or higher, use the new xsid.
   --   Otherwise use the xsid passed in through the parameter.
   if (is_hijack_session) then
      l_XSID := NewXSID;
   else
      l_XSID := p_session_id;
   end if;

   update icx_sessions set (
		user_id,
                mode_code,
                org_id,
		security_group_id,
                function_id,
                home_url,
		nls_language,
		language_code,
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
                mac_key,
                enc_key,
                TIME_OUT,
                GUEST,
                xsid)
       =     ( select
		p_user_id,
                nvl(p_mode_code,l_mode_code),
                l_org_id,
		fnd_session_management.g_security_group_id,
		NULL,
                p_home_url,
		l_language,
		l_language_code,
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
                l_login_id,
                NVL(l_mac_key, mac_key),
                NVL(l_enc_key, enc_key),
                l_timeout,
                'N',
                l_XSID from dual) -- Updating XSID when GUEST session is upgraded to user session
      where xsid = p_session_id;

      --Bug 7174340 newSessionRaiseEvent(p_user_id,p_session_id);
      newSessionRaiseEvent(p_user_id,l_session_id);
      newSSOSession(p_user_id,l_session_id);

       commit;
       return 'Y';
end;

function createTransaction(p_session_id in number,
                           p_resp_appl_id in number,
                           p_responsibility_id in number,
                           p_security_group_id in number,
                           p_menu_id in number,
                           p_function_id in number,
                           p_function_type in varchar2,
                           p_page_id in number)
                           return number is

l_transaction_id number;
l_XTID           varchar2(32);
l_module varchar2(200) := 'fnd_session_management.createTransaction';

begin

  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'BEGIN');
  end if;

  -- bug 21494664: add loop to resolve transaction_id collisions before insert
  for i in 1..10 loop

    begin
      l_transaction_id := NewTransactionId(p_session_id);
      l_XTID := NewXTID;

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_module, 'Transaction id is: ' || to_char(l_transaction_id) || ' Session id is: '|| to_char(p_session_id));
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_module, 'Encrypted transaction id is: ' ||l_XTID);
      end if;

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
        LAST_UPDATE_DATE,
        XTID)
      values (
        l_transaction_id,
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
        fnd_session_management.g_user_id,
        sysdate,
        fnd_session_management.g_user_id,
        sysdate,
        l_XTID);

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_module, 'Transaction id inserted successfully');
      end if;

      return l_transaction_id;

      exception
       when dup_val_on_index then
         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_module, 'Transaction id exists try again');
         end if;
         null;
      end;
    end loop;
    -- More than 10 duplicate entries - return -1

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_module, 'Unsuccessful getting a valid transaction_id - return -1');
    end if;

    return -1;

    exception
     when others then
       if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,l_module, 'Exception when others - return -1');
       end if;

       return -1;

end createTransaction;

procedure removeTransaction(p_transaction_id in number) is

begin

  update ICX_TRANSACTIONS
  set    DISABLED_FLAG = 'Y'
  where  TRANSACTION_ID = p_transaction_id;

end removeTransaction;

procedure setSessionPrivate(p_user_id		 in number,
			    p_responsibility_id  in number,
			    p_resp_appl_id       in number,
			    p_security_group_id  in number,
			    p_date_format	 in varchar2,
			    p_language		 in varchar2,
			    p_date_language	 in varchar2,
			    p_numeric_characters in varchar2,
                            p_nls_sort           in varchar2,
                            p_nls_territory      in varchar2,
                            p_node_id            in number) is

  x_session               NUMBER;
  c_node_id               number;

begin

    if p_node_id is null
    then
      select node_id into c_node_id from icx_sessions
      where  session_id = g_session_id;
    else
      c_node_id := p_node_id;
    end if;

    fnd_global.bless_next_init('FND_PERMIT_0001');
    fnd_global.INITIALIZE(session_id => x_session,
                      user_id => p_user_id,
                      resp_id => p_responsibility_id,
                      resp_appl_id => p_resp_appl_id,
                      security_group_id => p_security_group_id,
                      site_id => -1,
                      login_id => fnd_session_management.g_login_id,
                      conc_login_id => -1,
                      prog_appl_id => fnd_session_management.g_prog_appl_id,
                      conc_program_id => -1,
                      conc_request_id => -1,
                      server_id => c_node_id,
                      conc_priority_request => -1);
    --g_prog_appl_id defaults to -1... if -999 fnd_global will verify user_id - resp_id relationship

/* 3152313, remove NLS caching in icx layer
    if  p_language is not null
    and nvl(g_language_c,'XXXXX') <> p_language
    then
       c_nls_language := p_language;
       g_language_c:=p_language;
    end if;

    if p_date_language is not null
    and nvl(g_date_language_c,'XXXXX') <> p_date_language
    then
       c_date_language := p_date_language;
       g_date_language_c:= p_date_language;
    end if;

    if p_nls_sort is not null
    and nvl(g_nls_sort_c,'XXXXX') <> p_nls_sort
    then
      c_nls_sort := p_nls_sort;
      g_nls_sort_c:= p_nls_sort;
    end if;

    if p_nls_territory is not null
    and nvl(g_nls_territory_c,'XXXXX') <> p_nls_territory
    then
       c_nls_territory := p_nls_territory;
       g_nls_territory_c := p_nls_territory;
    end if;

    if p_date_format is not null
    and nvl(g_date_format_c,'XXXXX') <> p_date_format
    then
       c_date_format  := p_date_format;
       g_date_format_c := p_date_format;
    end if;

    if p_numeric_characters IS NOT NULL
    and nvl(g_numeric_characters_c,'XXXXX') <> p_numeric_characters
    then
      c_numeric_characters := p_numeric_characters;
      g_numeric_characters_c := p_numeric_characters;
    end if;
*/

    FND_GLOBAL.set_nls_context(
         p_nls_language => p_language,
         p_nls_date_format => p_date_format,
         p_nls_date_language => p_date_language,
         p_nls_numeric_characters => p_numeric_characters,
         p_nls_sort => p_nls_sort,
         p_nls_territory => p_nls_territory);

end setSessionPrivate;


procedure initializeSSWAGlobals(p_session_id        in number,
                                p_transaction_id    in number,
                                p_resp_appl_id      in number,
                                p_responsibility_id in number,
                                p_security_group_id in number,
                                p_function_id       in number) is

l_multi_org_flag  varchar2(30);
l_profile_defined boolean;
l_prefix          varchar2(30);


begin

  select SESSION_ID,
         MODE_CODE,
         NLS_LANGUAGE,
         LANGUAGE_CODE,
         DATE_FORMAT_MASK,
         NLS_NUMERIC_CHARACTERS,
         NLS_DATE_LANGUAGE,
         NLS_SORT,
         NLS_TERRITORY,
         USER_ID,
         nvl(p_resp_appl_id,RESPONSIBILITY_APPLICATION_ID),
         nvl(p_security_group_id,SECURITY_GROUP_ID),
         nvl(p_responsibility_id,RESPONSIBILITY_ID),
         nvl(p_function_id,FUNCTION_ID),
         FUNCTION_TYPE,
         MENU_ID,
         PAGE_ID,
         MODE_CODE,
         LOGIN_ID,
         NODE_ID,
         MAC_KEY,
         ENC_KEY,
         nvl(PROXY_USER_ID, -1)
  into   fnd_session_management.g_session_id,
         fnd_session_management.g_session_mode,
         fnd_session_management.g_language,
         fnd_session_management.g_language_code,
         fnd_session_management.g_date_format,
         fnd_session_management.g_numeric_characters,
         fnd_session_management.g_date_language,
         fnd_session_management.g_nls_sort,
         fnd_session_management.g_nls_territory,
         fnd_session_management.g_user_id,
         fnd_session_management.g_resp_appl_id,
         fnd_session_management.g_security_group_id,
         fnd_session_management.g_responsibility_id,
         fnd_session_management.g_function_id,
         fnd_session_management.g_function_type,
         fnd_session_management.g_menu_id,
         fnd_session_management.g_page_id,
         fnd_session_management.g_mode_code,
         fnd_session_management.g_login_id,
         fnd_session_management.g_node_id,
         fnd_session_management.g_mac_key,
         fnd_session_management.g_enc_key,
         fnd_session_management.g_proxy_user_id
  from  ICX_SESSIONS
  where SESSION_ID = p_session_id;

  if fnd_session_management.g_language_code is null
  then
     select  language_code
     into    fnd_session_management.g_language_code
     from    fnd_languages
     where   nls_language = fnd_session_management.g_language;
  end if;

  if p_transaction_id is not null
  then

    select TRANSACTION_ID,
           nvl(p_resp_appl_id,RESPONSIBILITY_APPLICATION_ID),
           nvl(p_responsibility_id,RESPONSIBILITY_ID),
           nvl(p_security_group_id,SECURITY_GROUP_ID),
           MENU_ID,
           nvl(p_function_id,FUNCTION_ID),
           FUNCTION_TYPE,
           PAGE_ID
    into   fnd_session_management.g_transaction_id,
           fnd_session_management.g_resp_appl_id,
           fnd_session_management.g_responsibility_id,
           fnd_session_management.g_security_group_id,
           fnd_session_management.g_menu_id,
           fnd_session_management.g_function_id,
           fnd_session_management.g_function_type,
           fnd_session_management.g_page_id
    from   ICX_TRANSACTIONS
    where  TRANSACTION_ID = p_transaction_id
    and    SESSION_ID = p_session_id
    and    DISABLED_FLAG <> 'Y';

  end if;

--Bug 3495818
/*
  select multi_org_flag
  into   l_multi_org_flag
  from   fnd_product_groups
  where  rownum < 2;
*/
   l_multi_org_flag := MO_UTILS.Get_Multi_Org_Flag;

  if l_multi_org_flag = 'Y'
  then
   fnd_profile.get_specific
   (name_z                  => 'ORG_ID',
    responsibility_id_z     => fnd_session_management.g_responsibility_id,
    application_id_z        => fnd_session_management.g_resp_appl_id,
    val_z                   => fnd_session_management.g_org_id,
    defined_z               => l_profile_defined);
  end if;

  fnd_profile.get(name => 'ICX_PREFIX',
                   val => l_prefix);

  if (l_prefix IS NOT NULL)
  then
   fnd_session_management.g_OA_HTML := fnd_web_config.trail_slash(l_prefix)||'OA_HTML';
   fnd_session_management.g_OA_MEDIA := fnd_web_config.trail_slash(l_prefix)||'OA_MEDIA';
  else
   fnd_session_management.g_OA_HTML := 'OA_HTML';
   fnd_session_management.g_OA_MEDIA := 'OA_MEDIA';
  end if;

  icx_sec.g_session_id := fnd_session_management.g_session_id;
  icx_sec.g_language := fnd_session_management.g_language;
  icx_sec.g_language_code := fnd_session_management.g_language_code;
  icx_sec.g_date_format := fnd_session_management.g_date_format;
  icx_sec.g_numeric_characters := fnd_session_management.g_numeric_characters;
  icx_sec.g_date_language := fnd_session_management.g_date_language;
  icx_sec.g_nls_sort := fnd_session_management.g_nls_sort;
  icx_sec.g_nls_territory := fnd_session_management.g_nls_territory;
  icx_sec.g_user_id := fnd_session_management.g_user_id;
  icx_sec.g_resp_appl_id := fnd_session_management.g_resp_appl_id;
  icx_sec.g_security_group_id := fnd_session_management.g_security_group_id;
  icx_sec.g_responsibility_id := fnd_session_management.g_responsibility_id;
  icx_sec.g_function_id := fnd_session_management.g_function_id;
  icx_sec.g_function_type := fnd_session_management.g_function_type;
  icx_sec.g_menu_id := fnd_session_management.g_menu_id;
  icx_sec.g_page_id := fnd_session_management.g_page_id;
  icx_sec.g_mode_code := fnd_session_management.g_mode_code;
  icx_sec.g_login_id := fnd_session_management.g_login_id;
  icx_sec.g_org_id := fnd_session_management.g_org_id;
  icx_sec.g_OA_HTML := fnd_session_management.g_OA_HTML;
  icx_sec.g_OA_MEDIA := fnd_session_management.g_OA_MEDIA;

 -- Bug 3665024
  icx_sec.g_transaction_id := fnd_session_management.g_transaction_id;

end initializeSSWAGlobals;


function validateSessionPrivate( c_XSID              in varchar2,
                                 c_function_code     in varchar2,
                                 c_commit            in boolean,
                                 c_update            in boolean,
                                 c_responsibility_id in number,
                                 c_function_id       in number,
                                 c_resp_appl_id      in number,
                                 c_security_group_id in number,
                                 c_validate_mode_on  in varchar2,
                                 c_XTID              in varchar2,
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
                                return varchar2 is

l_result         varchar2(30);
l_session_id     number;
l_transaction_id number;

p_session_id     number;
l_module varchar2(200):=
'fnd.plsql.FND_SESSION_MANAGEMENT.validateSessionPrivate';


begin

 -- Allow easier performance tuning
 /* Request to remove aalomari 16-NOV-1999
 DBMS_APPLICATION_INFO.SET_MODULE(
      module_name => fnd_session_management.g_function_id,
      action_name => 'Self Service');
 */



BEGIN
 if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: in
validateSessionPrivate');
 end if;


 l_session_id := fnd_session_utilities.XSID_to_SessionID(c_XSID);

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'fnd.plsql.FND_SESSION_MANAGEMENT.validateSessionPrivate', 'BEGIN ');
  end if;
 exception
  when others
   then
 return ('INVALID');
end;


 if c_XTID is not null
 then
   l_transaction_id := fnd_session_utilities.XTID_to_TransactionID(c_XTID);
 end if;

 if c_validate_mode_on = 'Y'
 then
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: call
check_session');
  end if;

  l_result := fnd_session_management.check_session
             (p_session_id => l_session_id,
              p_resp_id => c_responsibility_id,
              p_app_resp_id => c_resp_appl_id,
              p_tickle => 'N');
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: after
check_session - result:'||l_result);
  end if;
 else
  l_result := 'VALID';
 end if;

 if l_result = 'VALID' or l_result = 'EXPIRED'
 then

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log:
initializeglobals...');
  end if;

  fnd_session_management.initializeSSWAGlobals
  (p_session_id => l_session_id,
   p_transaction_id => l_transaction_id,
   p_resp_appl_id => c_resp_appl_id,
   p_responsibility_id => c_responsibility_id,
   p_security_group_id => c_security_group_id,
   p_function_id => c_function_id);

  fnd_session_management.setSessionPrivate
  (fnd_session_management.g_user_id,
   fnd_session_management.g_responsibility_id,
   fnd_session_management.g_resp_appl_id,
   fnd_session_management.g_security_group_id,
   fnd_session_management.g_date_format,
   fnd_session_management.g_language,
   fnd_session_management.g_date_language,
   fnd_session_management.g_numeric_characters,
   fnd_session_management.g_nls_sort,
   fnd_session_management.g_nls_territory,
   fnd_session_management.g_node_id);

  session_id             := fnd_session_management.g_session_id;
  transaction_id         := fnd_session_management.g_transaction_id;
  user_id                := fnd_session_management.g_user_id;
  responsibility_id      := fnd_session_management.g_responsibility_id;
  resp_appl_id           := fnd_session_management.g_resp_appl_id;
  security_group_id      := fnd_session_management.g_security_group_id;
  language_code          := fnd_session_management.g_language_code;
  nls_language           := fnd_session_management.g_language;
  date_format_mask       := fnd_session_management.g_date_format;
  nls_date_language      := fnd_session_management.g_date_language;
  nls_numeric_characters := fnd_session_management.g_numeric_characters;
  nls_sort               := fnd_session_management.g_nls_sort;
  nls_territory          := fnd_session_management.g_nls_territory;


  p_session_id           := fnd_session_management.g_session_id;

  if l_result = 'VALID'
  then
   if (c_update) or (c_commit)
   then

    validateSession_pragma(p_session_id);

   end if;


/*   Bug 3634632 removed commit - call validateSession_pragma now.

    update icx_sessions
    set    last_connect  = sysdate,
           counter = counter + 1
    where  session_id = fnd_session_management.g_session_id;

    if c_commit
    then
     commit;
    end if;
   end if;
*/


   if c_function_code is not null
   then
    if (not FND_FUNCTION.TEST(c_function_code))
    then
     l_result := 'INVALID';
    end if;
-- bug 3422198
   elsif (fnd_session_management.g_function_id is not null) and
      (fnd_session_management.g_function_id <> -1)
   then
    if (not FND_FUNCTION.TEST_ID(fnd_session_management.g_function_id))
    then
     l_result := 'INVALID';
    end if;
   end if;
  end if; -- 'VALID'

 else -- l_result not valid
  session_id             := -1;
  transaction_id         := -1;
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
 end if; -- l_result = 'VALID'

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'fnd.plsql.FND_SESSION_MANAGEMENT.validateSessionPrivate', 'result:  '||l_result);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'fnd.plsql.FND_SESSION_MANAGEMENT.validateSessionPrivate', 'END');
  end if;

 return l_result;

end validateSessionPrivate;


PROCEDURE Session_tickle_PVT(p_session_id IN NUMBER)
is
PRAGMA AUTONOMOUS_TRANSACTION;  -- mputman added for 2233089

begin

   update icx_sessions
      set    last_connect  = sysdate
      where  session_id = p_session_id;
   commit;

end Session_tickle_PVT;


PROCEDURE Session_tickle2_PVT(p_session_id IN NUMBER)
is

begin

   update icx_sessions
      set    last_connect  = sysdate
      where  session_id = p_session_id;
   commit;

end Session_tickle2_PVT;


PROCEDURE validateSession_pragma(p_session_id IN NUMBER)
 is
 PRAGMA AUTONOMOUS_TRANSACTION;
 begin

    update icx_sessions
       set    last_connect  = sysdate,
              counter = counter + 1
       where  session_id = p_session_id;
    commit;


end validateSession_pragma;


--
--     procedure added for bug#3951647
--
procedure Session_update_timeout_pvt(p_session_id number, l_timeout number) is
pragma autonomous_transaction;

begin

     update icx_sessions set time_out = l_timeout where session_id = p_session_id;
     commit;

end Session_update_timeout_pvt;



FUNCTION CHECK_SESSION(p_session_id IN NUMBER,
                       p_resp_id IN NUMBER,
                       p_app_resp_id IN NUMBER,
                       p_tickle IN VARCHAR2)
               RETURN VARCHAR2 is

	e_exceed_limit		exception;
	e_session_invalid	exception;
	n_limit_connects	number;
	n_limit_time		number;
	n_counter		number;
	c_disabled_flag		varchar2(1);
	c_text			varchar2(80);
	c_display_error		varchar2(240);
	c_error_msg		varchar2(2000);
	c_login_msg		varchar2(2000);
	n_error_num		number;
	l_string		varchar2(100);
	d_first_connect_time	date;
	l_profile_defined       boolean;
	l_session_mode          varchar2(30);
	l_last_connect          DATE;--mputman added 1755317
	l_session_timeout       NUMBER;--mputman added 1755317
	l_dist                  varchar2(30);
	l_user_id               NUMBER;
	l_app_resp_id           NUMBER;
	l_resp_id               NUMBER;
	l_guest                 varchar2(30);
	l_timeout               number; --gjimenez added 3951647
        l_login_id              number; -- bug 20562998

begin

  begin

   select LIMIT_CONNECTS, LIMIT_TIME,
         FIRST_CONNECT, COUNTER,
         nvl(DISABLED_FLAG,'N'),
         LAST_CONNECT, user_id,
         nvl(p_resp_id,RESPONSIBILITY_ID),
         nvl(p_app_resp_id,RESPONSIBILITY_APPLICATION_ID),
         TIME_OUT, GUEST, DISTRIBUTED, LOGIN_ID
  into   n_limit_connects, n_limit_time,
         d_first_connect_time,n_counter,
         c_disabled_flag,
         l_last_connect, l_user_id,
         l_resp_id, l_app_resp_id,
         l_session_timeout, l_guest, l_dist, l_login_id
  from  ICX_SESSIONS
  where SESSION_ID = p_session_id;

  exception
   when no_data_found
   then

   return ('INVALID');
  end;

  if (c_disabled_flag = 'Y')  then
    raise e_session_invalid;
  end if;

  if l_guest = 'N'
  then
    if ((n_counter + 1) > n_limit_connects)
    or (( d_first_connect_time + n_limit_time/24 < sysdate))
    then
      raise e_exceed_limit;
    end if;

    IF (l_session_timeout ) IS NOT NULL AND (l_session_timeout > 0) THEN
      IF (((SYSDATE-l_last_connect)*24*60)> l_session_timeout ) THEN
         RAISE e_exceed_limit;
      END IF;
    END IF;
  end if;

  if p_tickle = 'Y' then
    -- nlbarlow 2847057
    if l_dist = 'Y'
    then
      Session_tickle2_PVT(p_session_id);
    else
      Session_tickle_PVT(p_session_id);--moved to after idle check.
    end if;
  end if;

 -- Bug 5354477 amgonzal
 -- Finding first new possible ICX_SESSION_TIMEOUT value
/*
  -- added changes for bug#3951647

        fnd_profile.get(name => 'ICX_SESSION_TIMEOUT',
                     val  => l_timeout);
        Session_update_timeout_pvt(p_session_id, l_timeout);

  -- end changes for bug #3951647
*/

  -- Bug 6032403
  -- Most of the times fnd_session_management.check_session is called with no
  -- values for p_resp_id and p_app_resp_id
  -- Then, if passed p_resp_id and p_app_resp_id the ICX_SESSION_TIMEOUT
  -- value returned will the one defined for the USER or for the SITE
  -- Calling fnd_profile.get_specific with the resp_id and app_resp_id
  -- taken from ICX_SESSIONS given the session_id.
  -- AMGONZAL
  l_profile_defined := false;
  fnd_profile.get_specific(
           name_z                  => 'ICX_SESSION_TIMEOUT',
           user_id_z               => l_user_id,
           responsibility_id_z     => l_resp_id,
           application_id_z        => l_app_resp_id,
           val_z                   => l_timeout,
           defined_z               => l_profile_defined);
  if ( l_user_id = 6) then  -- Guest user has special rules for timeout.
       l_timeout := l_session_timeout;
  end if;
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                     ,  'fnd.plsql.FND_SESSION_MANAGEMENT.check_session.timeout'
                     , 'timeout : ' || to_char(l_timeout) || ' User Id : ' || to_char (l_user_id)
                       || ' Resp ID: ' || to_char(l_resp_id)
                       || ' Resp app ID : ' || to_char(l_app_resp_id));
  end if;
  Session_update_timeout_pvt(p_session_id, l_timeout);

  return ('VALID');

exception
  when e_session_invalid
  then
    return ('INVALID');
  when e_exceed_limit
  then

   if (l_login_id is not null) then
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         fnd_log.string(fnd_log.level_statement,'fnd.plsql.FND_SESSION_MANAGEMENT.check_session.expired',
                'Call audit end for expired session: '||p_session_id);
      end if;
      fnd_signon.audit_user_end(l_login_id,nvl(l_last_connect,sysdate)+l_session_timeout/(24*60));
   end if;

    return ('EXPIRED');

--  when others
--  then
--    return ('ERROR');
end CHECK_SESSION;


function getID(n_param in number,
               p_session_id in number)
               return varchar2 is

n_id			varchar2(80) default NULL;
n_user_name		varchar2(80);

begin

      if n_param = PV_LANGUAGE_CODE		--** LANGUAGE CODE (21) **
      then
         n_id := fnd_session_management.g_language_code; -- add to Java login.

      elsif n_param = PV_RESPONSIBILITY_ID	--** RESPONSIBILITY ID (25) **
      then
         n_id := fnd_session_management.g_responsibility_id;

      elsif n_param = PV_FUNCTION_ID      --** FUNCTION ID (31) **
      then
         n_id := fnd_session_management.g_function_id;

      elsif n_param = PV_FUNCTION_TYPE          --** FUNCTION TYPE (32) **
      then
         n_id := fnd_session_management.g_function_type;

      elsif n_param = PV_USER_NAME               --** USERNAME (99) **
      then
         select  b.USER_NAME
           into  n_id
           from  icx_sessions a,
                 fnd_user b
          where  b.user_id = a.user_id
            and  a.session_id  = p_session_id;

      elsif n_param = PV_USER_ID		--** WEB USER ID (10) **
      then
         n_id := fnd_session_management.g_user_id;

      elsif n_param = PV_DATE_FORMAT		--** DATE FORMAT MASK (22) **
      then
         n_id := fnd_session_management.g_date_format;

      elsif n_param = PV_SESSION_ID		-- ** SESSION_ID (23) **
      then
	 n_id := p_session_id;

      elsif n_param = PV_ORG_ID			-- ** ORG_ID (29) **
      then
         n_id := fnd_session_management.g_org_id;

      elsif n_param = PV_SESSION_MODE      --** PV_SESSION_MODE (30) **
      then
         n_id := fnd_session_management.g_session_mode;

      end if;

  return(n_id);

exception
   when others then
      return '-1';
end;


procedure putSessionAttributeValue(p_name in varchar2,
                                   p_value in varchar2,
                                   p_session_id in number) is
pragma AUTONOMOUS_TRANSACTION;
l_name varchar2(80);
l_len  number;

begin

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
    where  SESSION_ID = p_session_id
    and    NAME = l_name;

    insert into ICX_SESSION_ATTRIBUTES
    (SESSION_ID,NAME,VALUE)
    values
    (p_session_id,l_name,p_value);
    commit;

end putSessionAttributeValue;

function getSessionAttributeValue(p_name in varchar2,
                                  p_session_id in number)
                                  return varchar2 is
l_name   varchar2(80);
l_value  varchar2(4000);
l_len  number;

begin

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
    where  SESSION_ID = p_session_id
    and    NAME = l_name;

    return l_value;

exception
    when others then
        return NULL;
end getSessionAttributeValue;

procedure clearSessionAttributeValue(p_name in varchar2,
                                     p_session_id in number) is

PRAGMA AUTONOMOUS_TRANSACTION; --(gjimenez -> bug#4671867)

l_name varchar2(80);
l_len  number;

begin

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
    where  SESSION_ID = p_session_id
    and    NAME = l_name;

-- Fix for bug#5326396 -- Added a commit and exception handling to the code.
    commit;

exception
	when others then
		rollback;


end clearSessionAttributeValue;


function getsessioncookiename return varchar2 is

l_session_cookie_name   varchar2(81);

begin

   IF  fnd_session_management.g_session_cookie_name IS NULL THEN

      select SESSION_COOKIE_NAME
      into   l_session_cookie_name
      from   ICX_PARAMETERS;
   ELSE
      l_session_cookie_name:=fnd_session_management.g_session_cookie_name;
   END IF;   -- added mputman 1574527

if (l_session_cookie_name is null) then
   l_session_cookie_name := FND_WEB_CONFIG.DATABASE_ID;
end if;

return l_session_cookie_name;

exception
        when others then
                return -1;
end getsessioncookiename;


procedure updateSessionContext( p_function_name          varchar2,
                                p_function_id            number,
                                p_application_id         number,
                                p_responsibility_id      number,
                                p_security_group_id      number,
                                p_session_id             number,
                                p_transaction_id         number)
          is
PRAGMA AUTONOMOUS_TRANSACTION; --bug#5030523

l_function_id           number;
l_function_type         varchar2(30);
l_multi_org_flag        varchar2(30);
l_org_id                number;
l_profile_defined       boolean;

l_user_id               number;
l_new_timeout           number;
l_prev_timeout          number;
l_timeout               number;

begin

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

--Bug 3495818
/*
  select multi_org_flag
  into   l_multi_org_flag
  from   fnd_product_groups
  where  rownum < 2;
*/
   l_multi_org_flag := MO_UTILS.Get_Multi_Org_Flag;

  if l_multi_org_flag = 'Y'
  then
      fnd_profile.get_specific(
          name_z                  => 'ORG_ID',
          responsibility_id_z     => p_responsibility_id,
          application_id_z        => p_application_id,
          val_z                   => l_org_id,
          defined_z               => l_profile_defined);
  end if;

--
-- Bug 5354477 amgonzal
-- Finding the possible new value for ICX_SESSION_TIMEOUT profile option
--
--
  Begin
        Select user_id, time_out
        into   l_user_id, l_prev_timeout
        from   icx_sessions
        where  session_id = p_session_id;


        fnd_profile.get_specific(
          name_z                  => 'ICX_SESSION_TIMEOUT',
          user_id_z                         => l_user_id,
          responsibility_id_z     => p_responsibility_id,
          application_id_z        => p_application_id,
          val_z                   => l_new_timeout,
          defined_z               => l_profile_defined);

       if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                          ,  'fnd.plsql.FND_SESSION_MANAGEMENT.updateSessionContext.timeout'
                           , 'Previous timeout : ' || to_char(l_prev_timeout)
                             || 'New Timeout ' || to_char (l_new_timeout)
                             || ' Resp : ' || to_char(p_responsibility_id)
                             || ' Apps id: ' || to_char (p_application_id));
        end if;



        if l_user_id <> 6 then
           l_timeout := l_new_timeout;
        else
           l_timeout := l_prev_timeout;
        end if;
  End;

  update ICX_SESSIONS
  set    RESPONSIBILITY_APPLICATION_ID = p_application_id,
         RESPONSIBILITY_ID = p_responsibility_id,
         SECURITY_GROUP_ID = p_security_group_id,
         ORG_ID = l_org_id,
         FUNCTION_ID = l_function_id,
         FUNCTION_TYPE = l_function_type,
         time_out = l_timeout
  where  SESSION_ID = p_session_id;

  -- Bug 6032403 : In case next SQL stmt gaves error a
  --               rollback will undo icx_sessions update
  commit;

  if p_transaction_id is not null
  then

    update ICX_TRANSACTIONS
    set    RESPONSIBILITY_APPLICATION_ID = p_application_id,
           RESPONSIBILITY_ID = p_responsibility_id,
           SECURITY_GROUP_ID = p_security_group_id,
           FUNCTION_ID = l_function_id,
           FUNCTION_TYPE = l_function_type
    where  TRANSACTION_ID = p_transaction_id
    and    SESSION_ID = p_session_id;

  end if;

  commit;

exception

	when others then
		rollback;

end updateSessionContext;


function getNLS_PARAMETER(p_param in VARCHAR2)
		return varchar2 is

requested_val VARCHAR2(255);

BEGIN

  select upper(value)
  into requested_val
  from v$nls_parameters
  where parameter = p_param;

  RETURN requested_val;

END getNLS_PARAMETER;


PROCEDURE set_session_nls (p_session_id IN NUMBER,
                           p_language IN VARCHAR2,
                           p_date_format_mask IN VARCHAR2,
                           p_language_code IN VARCHAR2,
                           p_date_language IN VARCHAR2,
                           p_numeric_characters IN VARCHAR2,
                           p_sort IN VARCHAR2,
                           p_territory IN VARCHAR2) IS

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
WHERE session_id = p_session_id;

COMMIT;

END set_session_nls;

procedure reset_session(p_session_id in number) is
l_XSID varchar2(32);
begin

  -- Session Hijacking fix.

  -- Bug 13487530
  --   If R12.1 or higher, use the new xsid.
  --   Otherwise use the xsid in the icx_sessions table.
  if (is_hijack_session) then
     l_XSID := NewXSID;
  else
     select XSID into l_XSID from icx_sessions
     where session_id = p_session_id;
  end if;

  UPDATE icx_sessions
  SET    disabled_flag='N',
         last_connect=SYSDATE,
         counter=0,
         first_connect=SYSDATE,
         xsid=l_XSID -- Update XSID whenever session is re-established(Session Hijacking)
  WHERE  session_id = p_session_id;

end;

/*
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

function disableUserSession(c_session_id in number,
                            c_user_id in number) return BOOLEAN
is

--added for 4230606
    l_login_id number;
    l_audit_level      VARCHAR2(1);
--end modification

begin

        --added for 4230606
         select login_id into l_login_id
         from  ICX_SESSIONS
         where  SESSION_ID = c_session_id;

         l_audit_level:=fnd_profile.value('SIGNONAUDIT:LEVEL');
         if (l_audit_level is not null) and ( l_login_id is not null)
         then
              fnd_signon.audit_end(l_login_id); -- end audit session and resps.
         end if;
        --end changes for 4230606

   if c_user_id is null then
      update icx_sessions
         set disabled_flag = 'Y'
       where session_id = c_session_id;
   elsif c_user_id is not null then
      update icx_sessions
         set disabled_flag = 'Y'
       where session_id = c_session_id
         and user_id = c_user_id;
   end if;
   COMMIT;

   return true;
exception
        when others then
                return false;
end;


PROCEDURE setUserNLS  (p_user_id             IN NUMBER,
                       p_language_code       IN varchar2,
                       l_language	         OUT NOCOPY  varchar2,
                       l_language_code	      OUT NOCOPY  varchar2,
                       l_date_format	      OUT NOCOPY  varchar2,
                       l_date_language	      OUT NOCOPY  varchar2,
                       l_numeric_characters	OUT NOCOPY varchar2,
                       l_nls_sort      	   OUT NOCOPY varchar2,
                       l_nls_territory      	OUT NOCOPY varchar2,
                       l_limit_time		      OUT NOCOPY NUMBER,
                       l_limit_connects	   OUT NOCOPY NUMBER,
                       l_org_id              OUT NOCOPY varchar2,
                       l_timeout              OUT NOCOPY NUMBER)

IS
l_multi_org_flag        varchar2(1);
l_profile_defined	boolean;
db_lang                 varchar2(512);
lang                    varchar2(255);

l_login_id              NUMBER;
l_expired               VARCHAR2(5);

l_user_id              NUMBER;

begin

    if (fnd_session_management.g_proxy_user_id = -1) then
      /* For normal session get the NLS settings for the passed in user */
      l_user_id := p_user_id;
    else
      /* For Proxy session carry over the NLS settings from the original user's
         session */
      l_user_id := fnd_session_management.g_proxy_user_id;
    end if;

    l_language := null;
    if p_language_code is not null
    then
      begin
        select language_code, nls_language
          into l_language_code, l_language
          from fnd_languages
        where installed_flag in ('I', 'B') and
              language_code = p_language_code;
      exception
        when no_data_found
        then
          l_language := null;
      end;
    end if;
    if l_language is null then
      fnd_profile.get_specific(name_z       => 'ICX_LANGUAGE',
		 	     user_id_z	  => l_user_id,
			     val_z        => l_language,
			     defined_z    => l_profile_defined);

      if l_language is null
      then
        l_language:=getNLS_PARAMETER('NLS_LANGUAGE');
      end if;

      select language_code
        into l_language_code
        from fnd_languages
       where nls_language = l_language;
    end if;

    -- The following Profiles should be set

    fnd_profile.get_specific(name_z 	=> 'ICX_NLS_SORT',
			     user_id_z 	=> l_user_id,
			     val_z	=> l_nls_sort,
			     defined_z	=> l_profile_defined);

    if l_nls_sort is null
    then
      l_nls_sort:=getNLS_PARAMETER('NLS_SORT');
    end if;

    fnd_profile.get_specific(name_z       => 'ICX_DATE_FORMAT_MASK',
			     user_id_z    => l_user_id,
			     val_z        => l_date_format,
			     defined_z    => l_profile_defined);

    if l_date_format is null
    then
      l_date_format:=getNLS_PARAMETER('NLS_DATE_FORMAT');
    end if;

    l_date_format := replace(upper(l_date_format), 'YYYY', 'RRRR');
    l_date_format := replace(l_date_format, 'YY', 'RRRR');
    if (instr(l_date_format, 'RR') > 0) then
	if (instr(l_date_format, 'RRRR')  = 0) then
	    l_date_format := replace(l_date_format, 'RR', 'RRRR');
	end if;
    end if;

    -- Bug 5032374: Using unified function in ATG to get the NLS_DATE_LANGUAGE
    --  FND_GLOBAL.nls_date_language
    -- Changing :
    --    l_date_language := getDateLanguage(l_language);
    -- By:
    l_date_language := FND_GLOBAL.nls_date_language;

    if l_date_language is null
    then
      l_date_language:=getNLS_PARAMETER('NLS_DATE_LANGUAGE');
    end if;

    fnd_profile.get_specific(name_z	=> 'ICX_NUMERIC_CHARACTERS',
			     user_id_z	=> l_user_id,
			     val_z	=> l_numeric_characters,
			     defined_z	=> l_profile_defined);

    if l_numeric_characters is null
    then
      l_numeric_characters:=getNLS_PARAMETER('NLS_NUMERIC_CHARACTERS');
    end if;

    fnd_profile.get_specific(name_z     => 'ICX_TERRITORY',
			     user_id_z  => l_user_id,
			     val_z      => l_nls_territory,
			     defined_z  => l_profile_defined);

    if l_nls_territory is null
    then
      l_nls_territory:=getNLS_PARAMETER('NLS_TERRITORY');
    end if;

    fnd_profile.get_specific(name_z    => 'ICX_LIMIT_TIME',
			     user_id_z => l_user_id,
			     val_z     => l_limit_time,
			     defined_z => l_profile_defined);

    if l_limit_time is null
    then
      l_limit_time := 4;
    end if;

    fnd_profile.get_specific(name_z    => 'ICX_LIMIT_CONNECT',
			     user_id_z => l_user_id,
			     val_z     => l_limit_connects,
			     defined_z => l_profile_defined);

    if l_limit_connects is null
    then
      l_limit_connects := 1000;
    end if;
    -- Bug 5354477 : Now ICX_SESSION_TIMEOUT is populated on
    --                  convertGuestSession
    --                  updateSessionContext
    --                  check_session
    --
/*
    fnd_profile.get_specific(name_z    => 'ICX_SESSION_TIMEOUT',
                             user_id_z => p_user_id,
                             val_z     => l_timeout,
                             defined_z => l_profile_defined);
    fnd_profile.get(name => 'ICX_SESSION_TIMEOUT',
                    val  => l_timeout);
*/

/*
   select multi_org_flag
     into l_multi_org_flag
     from fnd_product_groups
    where rownum < 2;
*/
     l_multi_org_flag := MO_UTILS.Get_Multi_Org_Flag;

   if l_multi_org_flag = 'Y' then
     fnd_profile.get_specific(name_z    => 'ORG_ID',
			      val_z     => l_org_id,
			      defined_z => l_profile_defined);
   end if;

END;--setUserNLS


function GET_CACHING_KEY(p_reference_path VARCHAR2) return varchar2
is
  cachingKey varchar2(55);
begin

  select caching_key into cachingKey
  from icx_portlet_customizations
  where reference_path = p_reference_path;

  return cachingKey;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end GET_CACHING_KEY;

function isProxySession(p_session_id in number)
                        return number is
user_id number;
begin
  if (p_session_id is null)
  then
    if (fnd_session_management.g_proxy_user_id = -1) then
      return NULL;
    else
      return fnd_session_management.g_proxy_user_id;
    end if;
  end if;
  select proxy_user_id into user_id from icx_sessions where
       session_id = p_session_id;
  return user_id;
exception
  when no_data_found then
   app_exception.raise_exception(exception_text=>
      'Invalid Session Id ');
   app_exception.raise_exception;
  when others then
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', 'FND_SESSION_MANAGEMENT.isProxySession');
    fnd_message.set_token('ERRNO', SQLCODE);
    fnd_message.set_token('REASON', SQLERRM);
    app_exception.raise_exception;
end isProxySession;

--  *** INTERNAL API to be used by AOL only ***
--      The newSSOSession API is to be used to invalidate/timeout SSO sessions
--      when limiting SSO users to one session in an EBS instance
--      It is similar to the doNewSession API which limits the local ICX
--      sessions.

PROCEDURE newSSOSession (p_user_id IN NUMBER, p_session_id IN NUMBER)
   IS
   l_module_source varchar2(256) :=  'fnd_session_management.newSSOSession';
   l_user_id number;
   l_session_timeout number :=0;
   l_limit_sessions VARCHAR2(1) := 'N';
   l_profile_defined boolean;
   l_user_guid raw(256);

BEGIN

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  if (p_user_id is null) then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
         fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'Userid not passed - get from session: '||to_char(p_session_id));
       end if;

       select user_id, time_out
       into l_user_id, l_session_timeout
       from icx_sessions
       where session_id = p_session_id;

       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Userid from session is: '||to_char(l_user_id));
       end if;
  else
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User id passed: '||to_char(p_user_id));
       end if;

       l_user_id := p_user_id;
  end if;

if (l_user_id is not null) then
     select user_guid into l_user_guid from fnd_user where user_id = l_user_id;

    if (l_user_guid is not null) then
     -- Could have an SSO session - if so disable if profile is set to limit
      fnd_profile.get_specific(name_z    => 'APPS_SSO_LIMIT_SESSIONS',
                          user_id_z => l_user_id,
                          val_z     => l_limit_sessions,
                          defined_z => l_profile_defined);

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'APPS_SSO_LIMIT_SESSIONS profile is '||l_limit_sessions);
      end if;

   -- Handle disabling of local session on reauth of SSO user.  If event is enabled local sessions should be limited
   newSessionRaiseEvent(l_user_id,p_session_id);

   if (l_limit_sessions = 'Y') then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Limiting SSO user session.  Disable all but session id '||to_char(p_session_id));
      end if;

      UPDATE icx_sessions
         SET  last_connect=sysdate-2 -- May need to adjust this value
         WHERE mode_code = '115J'
         AND  session_id <> p_session_id
         AND  user_id = l_user_id
         AND  disabled_flag = 'N';

         COMMIT;
   else
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Not limiting SSO user session - do nothing');
      end if;
   end if;

  else
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Not an SSO user - do nothing');
      end if;
   end if;

 else
    -- Should never get here...
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'No user id found');
    end if;

 end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
     fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END');
  end if;

  EXCEPTION WHEN OTHERS THEN
    if( fnd_log.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_UNEXPECTED , l_module_source, 'Exception:'||sqlcode||' '||sqlerrm);
    end if;
    raise;
END;

-- Bug 13487530
-- This api checks the major and minor release and returns true if it is 12.1 or
-- higher.
-- This api is used to determine if session hijacking functionality is
-- available.
-- Session hijacking is available in releases 12.1.3 and higher only.
-- However, this api will return true even for 12.1.1 and 12.1.2 where
-- session hijacking is not available.  We cannot rely on checking the point
-- release at this time because it is unreliable, i.e. 12.1.3 returns 12.1.1
-- instead of 12.1.3.  So, 12.1.3 is an FND.B dependency and any backport to
-- the files impacted by session hijacking to 12.1.1 or 12.1.2 will
-- require a branch on branch.
function is_hijack_session return boolean IS
   l_module_source varchar2(256) :=
'fnd_session_management.is_hijack_session';
   l_hj boolean := false; -- default
begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
   end if;

   if (fnd_release.major_version >= 12 and fnd_release.minor_version >= 1) then
      l_hj := true;

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Hijacking is
available');
      end if;
   else
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Hijacking is
not available');
      end if;
   end if;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
   end if;

   return l_hj;

   exception when others then
      if ( fnd_log.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         fnd_log.string(FND_LOG.LEVEL_ERROR , l_module_source, sqlerrm);
      end if;
      return l_hj;
end is_hijack_session;



--- LANGUAGE CALCUALTION
--             Configuration API
--
-- NOTE: this implementation uses FND_USER_PREFERENCES
--      THis planned to change in the next version, so all code
--      must use the API and not access prefereces directly.
--
PROCEDURE setLanguageRule(
      rule  in varchar2 default 'SESSION,DISPLAY,BROWSER,PROFILE,BASE', -- use null for remove the rule
      level in varchar2  default 'SITE', -- or SERVER or USER
      level_value_name    in varchar2 default null   --  FND_NODES.SERVER_NAME or FND_USER.USER_NAME
    )
    is
       PRAGMA AUTONOMOUS_TRANSACTION; -- it may modify some preferences
       p_id pls_integer;
       p_level varchar2(200) := upper(level);
       p_name varchar2(100):='SITE';
      INVALID_LANG_RULE_LEVEL EXCEPTION;
BEGIN
   -- construct the preference name according to the level
   IF  p_level='SERVER' THEN
       select 'SERVER_'||node_id into p_name from fnd_nodes  where node_name=level_value_name;
   ELSIF p_level='USER' then
       select 'USER_'||user_id into p_name from fnd_user where user_name=level_value_name;
   ELSIF p_level<>'SITE' then
      raise INVALID_LANG_RULE_LEVEL;
   END IF;
   -- delete it if the preference already exists
  IF FND_PREFERENCE.exists(LC_PREF_USER,LC_PREF_MODULE,p_name) THEN
       FND_PREFERENCE.remove(LC_PREF_USER,LC_PREF_MODULE,p_name) ;
  END IF;

  -- if a rule was given store as a preference
  if rule is not null then
      FND_PREFERENCE.put(LC_PREF_USER,LC_PREF_MODULE,p_name,rule) ;
  end if;
  commit;
END setLanguageRule;


--
-- getLanguageRule
--     level: SITE, SERVER or USER
--     id : for SERVER the NODE_NAME from FND_NODES
--          for USER the USER_NAME from FND_USER
--          if user or server is null will use the corresponding context from FND_GLOBAL
--- will rise DATA_NOT_FOUND if the id is not found.
---
FUNCTION getLanguageRule(
      level in varchar2  default 'SITE', -- or SERVER or USER
      level_value_name    in varchar2 default null   --  FND_NODES.SERVER_NAME or FND_USER.USER_NAME
    ) return VARCHAR2
    is
       p_id pls_integer;
       p_level varchar2(200) := upper(level);
       p_name varchar2(100):='SITE';
      INVALID_LANG_RULE_LEVEL EXCEPTION;
BEGIN
   -- never return USER level unless sameLanguageRuleForAll is disabled
   IF p_LEVEL='USER' AND sameLanguageRuleForAll='YES' THEN
      return getLanguageRule('SERVER');
   END IF;

   IF  p_level='SERVER' THEN
       if level_value_name is null then -- use context
          if FND_GLOBAL.SERVER_ID=-1 then -- no context return SITE
             p_level := 'SITE';
         else
            p_name := 'SERVER_'||FND_GLOBAL.SERVER_ID;
        end if;
       ELSE
              select 'SERVER_'||node_id into p_name from fnd_nodes where node_name=level_value_name; -- use parameter : my raise DATA_NOT_FOUND
       end if;
       if not FND_PREFERENCE.exists(LC_PREF_USER,LC_PREF_MODULE,p_name) then -- if SERVER is not set fallback to SITE
                 return getLanguageRule('SITE');
       end if;
   ELSIF p_level='USER' then
       if level_value_name is null then -- try to use context
           if FND_GLOBAL.USER_ID=-1 then -- no user on context, return SERVER (recursion)
                 return getLanguageRule('SERVER');
           else
               p_name := 'USER_'||FND_GLOBAL.USER_ID; -- use context
           end if;
       else
          select 'USER_'|| user_id into p_name from fnd_user where user_name=level_value_name; -- use parameter : my raise DATA_NOT_FOUND
       end if;
       if not FND_PREFERENCE.exists(LC_PREF_USER,LC_PREF_MODULE,p_name) then
                 return getLanguageRule('SERVER');
       end if;
   ELSIF p_level<>'SITE' then -- invalid LEVEL requested
      raise INVALID_LANG_RULE_LEVEL;
   END IF;
   -- if SITE preference is not set , store the dafault
   if p_level='SITE' and NOT FND_Preference.exists(LC_PREF_USER,LC_PREF_MODULE,p_name) then
       setLanguageRule;
   end if;
   return FND_PREFERENCE.get(LC_PREF_USER,LC_PREF_MODULE,p_name) ;

END getLanguageRule;


--
-- Return YES or NO
--     optionVal:    NULL :=> return current setting
--                   TRUE : enable sameForAll (default)
--                   FALSE: disable sameForAll, now USER language rule can be used
--
--

FUNCTION sameLanguageRuleForAll( optionVal IN BOOLEAN DEFAULT NULL)
  RETURN VARCHAR2
   IS
       PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  -- set default the first time is called
  IF NOT FND_PREFERENCE.exists(LC_PREF_USER,LC_PREF_MODULE,LC_SAMEFORALL) THEN
      FND_PREFERENCE.put(LC_PREF_USER,LC_PREF_MODULE,LC_SAMEFORALL,'YES') ;
      COMMIT;
  ELSIF optionVal is not NULL THEN
      FND_PREFERENCE.remove(LC_PREF_USER,LC_PREF_MODULE,LC_SAMEFORALL) ;
  END IF;

  IF optionVal IS NOT NULL THEN
    IF optionVal THEN
      FND_PREFERENCE.put(LC_PREF_USER,LC_PREF_MODULE,LC_SAMEFORALL,'YES') ;
    ELSE
      FND_PREFERENCE.put(LC_PREF_USER,LC_PREF_MODULE,LC_SAMEFORALL,'NO') ;
    END IF;
    COMMIT;
  END IF;

  RETURN FND_PREFERENCE.get(LC_PREF_USER,LC_PREF_MODULE,LC_SAMEFORALL) ;
END sameLanguageRuleForAll;


end FND_SESSION_MANAGEMENT;

/
