--------------------------------------------------------
--  DDL for Package Body WFA_SEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WFA_SEC" as
/* $Header: wfsecicb.pls 120.4.12010000.13 2013/09/06 05:28:44 alsosa ship $ */

-- Private global to hold access cookie
wf_session varchar2(320) := '';

-- The default behavior is to use ICX profile options instead
-- But Exchange has a requirement of using fnd_preferences
wf_use_fnd_preferences boolean := null;

-- ICX Session Id cache
g_session_id number := -1;

-- Bug 7828862 cache variables for EBS context synchronization
-- context counter to validate if any FND_GLOBAL initialize API
-- was called. We will default to the standard values used in WF
g_cached       boolean := false;
g_session_ctx  number := 0;
g_user_id      number := 0;
g_resp_id      number := 20420;
g_resp_appl_id number := 1;
g_security_group_id number := 0;
g_server_id    number := -1;

--
-- Use_Fnd_Preferences (PRIVATE)
--   Find out whether we should use FND Preference or not
-- Return
--   True if Token Resource WF_PREFERENCE is set to FND
--   False otherwise or if the above token is not set
--
function Use_Fnd_Preferences
return boolean
is
begin
  if (wf_use_fnd_preferences is null) then
    if (wf_core.translate('WF_PREFERENCE') = 'FND') then
      wf_use_fnd_preferences := true;
    else
      wf_use_fnd_preferences := false;
    end if;
  end if;
  return wf_use_fnd_preferences;
end Use_Fnd_Preferences;

--
-- CreateSession
--
procedure CreateSession(
  c_user_name     in varchar2,
  c_user_password in varchar2)
is
  sid  number;
  user varchar2(320);
  pwd  varchar2(255);
  res  varchar2(255);
begin
  user := c_user_name;
  pwd  := c_user_password;
  sid  := 0;

  -- Validate the user with icx
  begin
    res := ICX_SEC.ValidatePassword(user, pwd, sid);
  exception
    when others then
      wf_core.token('USER', c_user_name);
      wf_core.token('SQLCODE', SQLCODE);
      wf_core.token('SQLERRM', SQLERRM);
      wf_core.raise('WFSEC_CREATE_SESSION');
  end;

  if (res <> '0') then
    wf_core.token('USER', c_user_name);
    wf_core.raise('WFSEC_USER_PASSWORD');
  end if;

  -- Set the private access global
  wf_session := c_user_name;

exception
  when others then
    wf_core.context('Wfa_Sec', 'CreateSession', c_user_name);
    raise;
end CreateSession;

--
-- GetSession
--
procedure GetSession(user_name out NOCOPY varchar2)
is
  l_user_name varchar2(320);   -- used as out parameters cannot be read!!
  res    boolean;
begin
  -- First check if local acccess global has been set
  if (wfa_sec.wf_session is not null) then
    l_user_name := wfa_sec.wf_session;
  else
    -- Otherwise check the ic cookie for a session
    begin

      if (wfa_sec.validate_only = TRUE) then

         /* GK:
         ** Do not update the icx_sessions table.  If you get a long
         ** running worklist or any other workflow api, you'll get a
         ** lock on the sessions table that will lead to db enqueue contention
         ** across the db.
         */
         res := ICX_SEC.ValidateSession( c_validate_only => 'Y',
                                         c_update => FALSE);

      else

         res := ICX_SEC.ValidateSession(c_update => FALSE);

      end if;

    exception
      when others then
        wf_core.token('SQLCODE', SQLCODE);
        wf_core.token('SQLERRM', SQLERRM);
        wf_core.raise('WFSEC_GET_SESSION');
    end;

    if (res = FALSE ) then
      wf_core.raise('WFSEC_NO_SESSION');
    end if;

    l_user_name := ICX_SEC.GetID(99);
  end if;

  user_name := l_user_name;
exception
  when others then
    wf_core.context('Wfa_Sec', 'GetSession');
    raise;
end GetSession;

--
-- Header
--   Print an html page header
-- IN
--   background_only - Only set background with no other header
--   disp_find - When defined, Find button is displayed, and the value
--               is the URL the Find button is pointting to.
--
procedure Header(background_only in boolean,
                 disp_find in varchar2,
                 page_title in varchar2,
                 inc_lov_applet  in boolean,
                 pseudo_login in boolean)
is
begin
  if (background_only) then

    htp.p('<BODY BGCOLOR="#CCCCCC">');

  else
    if (disp_find is not null) then

      htp.p ('<BODY bgcolor="#CCCCCC">');

      if not (pseudo_login) then
        icx_plug_utilities.Toolbar(p_text=>page_title, p_disp_help=>'Y',
             p_disp_find=>Header.disp_find);
      else
        icx_plug_utilities.Toolbar(p_text=>page_title, p_disp_mainmenu=>'N', p_disp_menu=>'N');
      end if;

      htp.p('<BR>');

    else

      htp.p ('<BODY bgcolor="#CCCCCC">');

      if not (pseudo_login) then
        icx_plug_utilities.Toolbar(p_text=>page_title, p_disp_help=>'Y');
      else
        icx_plug_utilities.Toolbar(p_text=>page_title, p_disp_mainmenu=>'N', p_disp_menu=>'N');
      end if;

      htp.p('<BR>');

    end if;
  end if;
exception
    when others then
        wf_core.context('Wfa_Sec', 'Header');
        raise;
end Header;

--
-- Footer
--   Print an html page footer
--
procedure Footer
is
begin
  icx_admin_sig.footer;
exception
    when others then
        wf_core.context('Wfa_Sec', 'Footer');
        raise;
end Footer;

--
-- DetailURL
--   Produce URL for notification detail and response page.
-- IN
--   nid - notification id
-- RETURNS
--   URL of detail and response page for notification.
--
function DetailURL(nid in number) return varchar2
is
begin
  return('wfa_html.detail?nid='||to_char(nid));
exception
  when others then
    Wf_Core.Context('Wfa_Sec', 'DetailURL', to_char(nid));
    raise;
end DetailURL;

--
-- PseudoSession - create ICX psuedo session for the client
--   Creates a temp ICX session for the current user coming into ICX
--   from an email notification with a link to the applications.
--   Session information is typically stored on the web client as an
--   http cookie.  This only applies to ICX so only wfsecicb will
--   have an actual implementation for this function.  The others
--   do nothing.
--
--   Added setting of user preference here, so that a French user
--   when viewing a detached notification will still view this in
--   French instead of English.
procedure PseudoSession(IncludeHeader in BOOLEAN,
                        user_name     in varchar2)
is
  l_session_id    NUMBER := 0;
  l_result        VARCHAR2(5) := '0';
  c_territory     VARCHAR2(80);
  c_language      VARCHAR2(80);
  c_date_format   VARCHAR2(40);
  l_user_id       NUMBER := to_number(null);
  role_info_tbl   wf_directory.wf_local_roles_tbl_type;
begin

  l_result := ICX_SEC.PseudoSession (l_session_id, IncludeHeader);

  if (user_name is not null) then
    Wf_Directory.GetRoleInfo2(user_name,role_info_tbl);

    -- do not brother to find out the user id if we use fnd_preferences
    if (Use_FND_Preferences) then
      l_user_id := to_number(null);
    else
      begin
        -- user_name should be unique, but use rownum just in case
        select USER_ID into l_user_id
          from FND_USER
         where USER_NAME = PseudoSession.user_name
           and rownum < 2;
      exception
        when NO_DATA_FOUND then
          l_user_id := to_number(null);
      end;
    end if;

    -- Get the language preference
    c_language := ''''||role_info_tbl(1).language||'''';

    -- Get the terriory preference
    c_territory := ''''||role_info_tbl(1).territory||'''';

    if (l_user_id is not null) then
      -- get the date format preference
      c_date_format := ''''||NVL(fnd_profile.value_specific(
            'ICX_DATE_FORMAT_MASK',l_user_id, null, null),'DD-MON-RRRR')||'''';
    else
      c_date_format := ''''||NVL(wf_pref.get_pref2(user_name,'DATEFORMAT','WFDS'),
            'DD-MON-RRRR')||'''';
    end if;

    dbms_session.set_nls('NLS_LANGUAGE'   , c_language);
    dbms_session.set_nls('NLS_TERRITORY'  , c_territory);
    dbms_session.set_nls('NLS_DATE_FORMAT', c_date_format);
  end if;
exception
  when others then
    Wf_Core.Context('Wfa_Sec', 'PseudoSession');
    raise;
end PseudoSession;


--
-- Create_Help_Syntax
--   Create the javascript necessary to launch the help function
--   Since this is only required for the apps install case
--   I have covered this function with a wfa_sec function.
--   The other wfsec cases are just a stub.
--
procedure Create_Help_Syntax (
p_target in varchar2,
p_language_code in varchar2) IS

begin
       htp.p('<SCRIPT>');

       icx_admin_sig.help_win_script(p_target, p_language_code, 'FND');

       htp.p('</SCRIPT>');

       htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

exception
  when others then
    Wf_Core.Context('Wfa_Sec', 'Create_Help_Syntax');
    raise;
end Create_Help_Syntax;

--
-- get_role_info
--   Gets role info for the user sources that we know about rather
--   than using the ugly expensive wf_roles view
--

procedure get_role_info(
  role in varchar2,
  name out NOCOPY varchar2,
  display_name out NOCOPY varchar2,
  description out NOCOPY varchar2,
  email_address out NOCOPY varchar2,
  notification_preference out NOCOPY varchar2,
  language out NOCOPY varchar2,
  territory out NOCOPY varchar2,
  orig_system  out NOCOPY varchar2,
  orig_system_id out NOCOPY number
 ) IS
l_status         varchar2(8);
l_fax            varchar2(100);
l_exp_date       date;
begin
  wfa_sec.get_role_info2(role , name ,display_name, description ,email_address,notification_preference,language , territory,orig_system,orig_system_id ,l_fax , l_status,l_exp_date);
exception
 when others then
    Wf_Core.Context('Wfa_Sec', 'Get_Role_Info', role);
    raise;
end get_role_info;
--
-- get_role_info2
--   Gets role info2 for the user sources that we know about rather
--   than using the ugly expensive wf_roles view
--

procedure get_role_info2(
  role in varchar2,
  name out NOCOPY varchar2,
  display_name out NOCOPY varchar2,
  description out NOCOPY varchar2,
  email_address out NOCOPY varchar2,
  notification_preference out NOCOPY varchar2,
  language out NOCOPY varchar2,
  territory out NOCOPY varchar2,
  orig_system  out NOCOPY varchar2,
  orig_system_id out NOCOPY number,
  FAX out NOCOPY VARCHAR2,
  STATUS out NOCOPY VARCHAR2,
  EXPIRATION_DATE out NOCOPY DATE,
  p_CompositeName in BOOLEAN
 ) IS
prefix    VARCHAR2(80);
roleid    VARCHAR2(320);
nlsLang   NUMBER;
nlsTerr   NUMBER;
l_langstatus    PLS_INTEGER;
l_terrstatus    PLS_INTEGER;
l_composite     BOOLEAN;
fndUserID NUMBER;
l_fndUserPref varchar2(20);

begin
  if (p_CompositeName) then
    l_composite := TRUE;
  else
    l_composite := FALSE;
  end if;

  if (l_composite) then
    prefix := SUBSTRB(role, 1,  INSTRB(role, ':') - 1);
    roleid := SUBSTRB(role, INSTRB(role, ':') + 1);

    if (prefix = 'POS') then
      select NAME,
             DISPLAY_NAME,
             DESCRIPTION,
             EMAIL_ADDRESS,
             NOTIFICATION_PREFERENCE,
             LANGUAGE,
             TERRITORY,
             ORIG_SYSTEM,
             ORIG_SYSTEM_ID,
             FAX,
             STATUS,
             EXPIRATION_DATE
      into   name,
             display_name,
             description,
             email_address,
             notification_preference,
             language,
             territory,
             orig_system,
             orig_system_id,
             FAX,
             STATUS,
             EXPIRATION_DATE
      from   WF_ROLES --PARTITION (POS)
      where  ORIG_SYSTEM = prefix
      and    ORIG_SYSTEM_ID = to_number(roleid)
	  and    PARTITION_ID = 4 --POS
      and    nvl(EXPIRATION_DATE, sysdate+1) > sysdate;

    elsif (prefix = 'ENG_LIST') then
      SELECT NAME,
             DISPLAY_NAME,
             DESCRIPTION,
             EMAIL_ADDRESS,
             NOTIFICATION_PREFERENCE,
             LANGUAGE,
             TERRITORY,
             ORIG_SYSTEM,
             ORIG_SYSTEM_ID,
             FAX,
             STATUS,
             EXPIRATION_DATE
      into   name,
             display_name,
             description,
             email_address,
             notification_preference,
             language,
             territory,
             orig_system,
             orig_system_id,
             FAX,
             STATUS,
             EXPIRATION_DATE
      from   WF_ROLES --PARTITION (ENG_LIST)
      where  ORIG_SYSTEM = prefix
      and    ORIG_SYSTEM_ID = to_number(roleid)
	  and    PARTITION_ID = 7 --ENG_LIST
      and    nvl(EXPIRATION_DATE, sysdate+1) > sysdate;

    elsif ((SUBSTRB(prefix, 1, 8) = 'FND_RESP') and
              ((length(prefix) = 8) or --In case we just get 'FND_RESP'
               (substr(prefix, 9, 9) between '0' and '9'))) then
      SELECT  NAME,
              DISPLAY_NAME,
              DESCRIPTION,
              EMAIL_ADDRESS,
              NOTIFICATION_PREFERENCE,
              LANGUAGE,
              TERRITORY,
              ORIG_SYSTEM,
              ORIG_SYSTEM_ID,
              FAX,
              STATUS,
              EXPIRATION_DATE
       into   name,
              display_name,
              description,
              email_address,
              notification_preference,
              language,
              territory,
              orig_system,
              orig_system_id,
              FAX,
              STATUS,
              EXPIRATION_DATE
       from   WF_ROLES --PARTITION (FND_RESP)
       where  ORIG_SYSTEM = prefix
       and    ORIG_SYSTEM_ID = to_number(roleid)
	   and    PARTITION_ID = 2 --FND_RESP
       and    nvl(EXPIRATION_DATE, sysdate+1) > sysdate;
    elsif (prefix = 'AMV_CHN') then
       select NAME,
              DISPLAY_NAME,
              DESCRIPTION,
              EMAIL_ADDRESS,
              NOTIFICATION_PREFERENCE,
              LANGUAGE,
              TERRITORY,
              ORIG_SYSTEM,
              ORIG_SYSTEM_ID,
              FAX,
              STATUS,
              EXPIRATION_DATE
       into   name,
              display_name,
              description,
              email_address,
              notification_preference,
              language,
              territory,
              orig_system,
              orig_system_id,
              FAX,
              STATUS,
              EXPIRATION_DATE
        from  WF_ROLES -- PARTITION (AMV_CHN)
        where ORIG_SYSTEM = prefix
        and   ORIG_SYSTEM_ID = to_number(roleid)
		and   PARTITION_ID = 6
        and   nvl(EXPIRATION_DATE, sysdate+1) > sysdate;

    elsif (prefix = 'HZ_PARTY') then
       select NAME,
              DISPLAY_NAME,
              DESCRIPTION,
              EMAIL_ADDRESS,
              NOTIFICATION_PREFERENCE,
              LANGUAGE,
              TERRITORY,
              ORIG_SYSTEM,
              ORIG_SYSTEM_ID,
              FAX,
              STATUS,
              EXPIRATION_DATE
       into   name,
              display_name,
              description,
              email_address,
              notification_preference,
              language,
              territory,
              orig_system,
              orig_system_id,
              FAX,
              STATUS,
              EXPIRATION_DATE
       from   WF_ROLES -- PARTITION (HZ_PARTY)
       where  ORIG_SYSTEM = prefix
       and    ORIG_SYSTEM_ID = to_number(roleid)
	   and    PARTITION_ID = 9
       and    nvl(EXPIRATION_DATE, sysdate+1) > sysdate;
    else
      l_composite := FALSE;
    end if;
  end if;

    if NOT (l_composite) then
      --Bug 2728955
      --Changed the elseif to else this is for
      --composite names ( eg : ABC:123). This will not fall
      --in any of the above conditions but has prefix non-null also
      --Tuned the query to use the partition_id for the prefix null
      --ORIG_SYSTEM .
      select WLR.NAME,
             WLR.DISPLAY_NAME,
             WLR.DESCRIPTION,
             WLR.EMAIL_ADDRESS,
             WLR.NOTIFICATION_PREFERENCE,
             WLR.LANGUAGE,
             WLR.TERRITORY,
             WLR.ORIG_SYSTEM,
             WLR.ORIG_SYSTEM_ID,
             WLR.FAX,
             WLR.STATUS,
             WLR.EXPIRATION_DATE
      into   name,
             display_name,
             description,
             email_address,
             notification_preference,
             language,
             territory,
             orig_system,
             orig_system_id,
             FAX,
             STATUS,
             EXPIRATION_DATE
      from   (select NAME,
                     DISPLAY_NAME,
                     DESCRIPTION,
                     EMAIL_ADDRESS,
                     NOTIFICATION_PREFERENCE,
                     LANGUAGE,
                     TERRITORY,
                     ORIG_SYSTEM,
                     ORIG_SYSTEM_ID,
                     FAX,
                     STATUS,
                     EXPIRATION_DATE,
                     decode(STATUS, 'ACTIVE', 1, 2) ACTIVE_ORDER,
                     decode(ORIG_SYSTEM, 'PER', 1, 'FND_USR', 2, 3) ORIG_ORDER
              from WF_ROLES
              where NAME = role
                and PARTITION_ID in (1, 0, 5, 10, 13)
                and nvl(EXPIRATION_DATE, sysdate+1) > sysdate
              order by ACTIVE_ORDER, ORIG_ORDER) WLR
      where ROWNUM < 2;                    /* Bug 2728955 */
    end if;

 --<rwunderl:2750876>
   if (orig_system in ('FND_USR', 'PER')) then
     l_fndUserPref := WF_PREF.get_pref2(name,'MAILTYPE','WFDS');
       if(l_fndUserPref is not null) then
          notification_preference := l_fndUserPref;
       end if;
     if (Use_FND_Preferences) then
       language := WF_PREF.get_pref2(name, 'LANGUAGE','WFDS');
       territory := WF_PREF.get_pref2(name, 'TERRITORY','WFDS');

     else
       if (orig_system = 'PER') then
         SELECT USER_ID
         INTO   fndUserID
         FROM   FND_USER
         WHERE  USER_NAME = name;

       else
         fndUserID := orig_system_ID;

       end if;


       -- <7578908> "-1" instead of NULL for ctx parameters other than USER_ID, so that
       -- NOT to use current login ctx when calling fnd_profile.value_specific.
       -- Also, in case of null profile value (user and site), getting the session
       -- values
       language := nvl(fnd_profile.value_specific('ICX_LANGUAGE',fndUserID /*user_id*/
                       , -1 /*resp_id*/, -1 /*app_id*/, -1 /*org_id*/, -1 /*server_id*/)
                    , wf_core.nls_language);
       territory := nvl(fnd_profile.value_specific('ICX_TERRITORY',fndUserID, -1, -1, -1, -1)
                      , wf_core.nls_territory);

     end if;
   end if;

   -- <7578908> this not needed now per above change
  --Need to make sure the nls preferences were not null.
--  if ((language is NULL) or (territory is NULL)) then
--     WF_CACHE.GetNLSParameter('BASELANGUAGE', l_langstatus, nlsLang);
--     --Bug 3188230
--     --Get the base territory aswell
--     WF_CACHE.GetNLSParameter('BASETERRITORY', l_terrstatus, nlsTerr);
--
--     if ((l_langstatus <> WF_CACHE.task_SUCCESS) OR
--          (l_terrstatus <> WF_CACHE.task_SUCCESS)) then
--       --Where there is language there is territory, so we will go after both.
--       WF_CACHE.NLSParameters(nlsLang).PARAMETER := 'BASELANGUAGE';
--       WF_CACHE.NLSParameters(nlsTerr).PARAMETER := 'BASETERRITORY';
--
--       SELECT NLS_LANGUAGE, NLS_TERRITORY
--       INTO   WF_CACHE.NLSParameters(nlsLang).VALUE,
--              WF_CACHE.NLSParameters(nlsTerr).VALUE
--       FROM   FND_LANGUAGES
--       WHERE  INSTALLED_FLAG = 'B';
--
--     end if;
--
--     language := WF_CACHE.NLSParameters(nlsLang).VALUE;
--     territory := WF_CACHE.NLSParameters(nlsTerr).VALUE;
--
--   end if;

exception
  when no_data_found then
    name := '';
    display_name := '';
    description := '';
    notification_preference := '';
    language := '';
    territory := '';
    email_address := '';
    orig_system := '';
    orig_system_id := to_number(null);
    fax := '';
    status := '';
    EXPIRATION_DATE := to_date(null);

  when others then
    Wf_Core.Context('Wfa_Sec', 'Get_Role_Info2', role);
    raise;

 end get_role_info2;

  /* get_role_info3
   *
   * Same as get_role_info2(), but handles rest of parameters for full NLS support
   * (bug 7578908)
   */
  procedure get_role_info3(   p_CompositeName in BOOLEAN,
                              p_role in varchar2,
                              p_name out NOCOPY varchar2,
                              p_display_name out NOCOPY varchar2,
                              p_description out NOCOPY varchar2,
                              p_email_address out NOCOPY varchar2,
                              p_notification_preference out NOCOPY varchar2,
                              p_orig_system  out NOCOPY varchar2,
                              p_orig_system_id out NOCOPY number,
                              p_FAX out NOCOPY VARCHAR2,
                              p_STATUS out NOCOPY VARCHAR2,
                              p_EXPIRATION_DATE out NOCOPY DATE  ,
                              p_nlsLanguage out NOCOPY varchar2,
                              p_nlsTerritory out NOCOPY varchar2
                            , p_nlsDateFormat out NOCOPY varchar2
                            , p_nlsDateLanguage out NOCOPY varchar2
                            , p_nlsCalendar out NOCOPY varchar2
                            , p_nlsNumericCharacters out NOCOPY varchar2
                            , p_nlsSort out NOCOPY varchar2
                            , p_nlsCurrency out NOCOPY varchar2
   )
  is
    l_fndUserID NUMBER;

  begin
    p_nlsCalendar := null; -- <7720908> nls_calendar is never used to set session

    get_role_info2(role => p_role, name => p_name, display_name => p_display_name,
                description => p_description, email_address => p_email_address,
                notification_preference => p_notification_preference,
                language => p_nlsLanguage,
                territory => p_nlsTerritory,
                orig_system =>p_orig_system,
                orig_system_id => p_orig_system_id,
                FAX => p_fax,
                STATUS => p_status,
                EXPIRATION_DATE => p_expiration_date,
                p_CompositeName => p_compositeName
                );

    if (p_orig_system in ('PER', 'FND_USR') ) then
      if (p_orig_system ='PER') then
         SELECT USER_ID
         INTO   l_fndUserID
         FROM   FND_USER
         WHERE  USER_NAME = p_role;
      else
        l_fndUserID := p_orig_system_id;
      end if;

      p_nlsCurrency := nvl(fnd_profile.value_specific('ICX_PREFERRED_CURRENCY', l_fndUserID /*user_id*/
                       , -1 /*resp_id*/, -1 /*app_id*/, -1 /*org_id*/, -1 /*server_id*/)
                       ,  wf_core.nls_currency);
      p_nlsNumericCharacters := nvl(fnd_profile.value_specific('ICX_NUMERIC_CHARACTERS', l_fndUserID, -1, -1, -1, -1),
                        wf_core.nls_numeric_characters);

      p_nlsCalendar := nvl(fnd_profile.value_specific('FND_FORMS_USER_CALENDAR', l_fndUserID, -1, -1, -1, -1)
                          , wf_core.nls_calendar);

      p_nlsDateFormat := nvl(fnd_profile.value_specific('ICX_DATE_FORMAT_MASK', l_fndUserID, -1, -1, -1, -1),
                        wf_core.nls_date_format);

      p_nlsDateLanguage := nvl(
                                nvl(fnd_profile.value_specific('ICX_DATE_LANGUAGE', l_fndUserID, -1, -1, -1, -1) , p_nlsLanguage),
                             wf_core.nls_date_language);

      p_nlsSort := nvl(fnd_profile.value_specific('ICX_NLS_SORT', l_fndUserID, -1, -1, -1, -1),
                        wf_core.nls_sort);

    else -- not an EBS user role, therefore, return PHASE 1 default values

      p_nlsCurrency          :=  wf_core.nls_currency;
      p_nlsNumericCharacters :=  wf_core.nls_numeric_characters;
      p_nlsCalendar          :=  wf_core.nls_calendar;
      p_nlsDateFormat        :=  wf_core.nls_date_format;
      p_nlsSort              :=  wf_core.nls_sort;

      -- for Date language we simply use the role's preference language
      p_nlsDateLanguage      := p_nlsLanguage;

    end if;

  exception
  when NO_DATA_FOUND then
      p_nlsCurrency          := '';
      p_nlsNumericCharacters := '';
      p_nlsCalendar          := '';
      p_nlsDateFormat        := '';
      p_nlsDateLanguage      := '';
      p_nlsSort              := '';
  when others then
     Wf_Core.Context('Wfa_Sec', 'Get_Role_Info3', p_role);
     raise;
  end get_role_info3;

--
-- ResetCookie
--
--  IN: Name of the cookie to be reset to -1.
--

procedure ResetCookie(cookieName in varchar2)
is
BEGIN

owa_cookie.send(name=>cookieName, value=>'-1', expires=>'',
               path=>'/');

end ResetCookie;

--
-- GET_PROFILE_VALUE (PRIVATE)
--
function Get_Profile_Value(name varchar2,
                           user_name varchar2)
return varchar2
is
  l_orig_system  varchar2(30);
  l_orig_system_id number;
  l_user_id      number;
  l_application_id number;

  result varchar2(32000);
begin
  Wf_Directory.GetRoleOrigSysInfo(user_name, l_orig_system, l_orig_system_id);

  if (instr(l_orig_system, 'FND_USR') > 0) then
    result := fnd_profile.value_specific(name=>Get_Profile_Value.name,
                                         user_id=>l_orig_system_id);
  elsif ((SUBSTRB(l_orig_system, 1, 8) = 'FND_RESP') and
         (length(l_orig_system) > 8) and --Make sure we don't just get
                                         --'FND_RESP'
         (substr(l_orig_system, 9, 9) between '0' and '9')) then
    l_application_id := substr(l_orig_system,
                               instr(l_orig_system,'FND_RESP')+8);
    result := fnd_profile.value_specific(name=>Get_Profile_Value.name,
                  responsibility_id=>l_orig_system_id,
                  application_id=>l_application_id);
  elsif (instr(l_orig_system, 'PER') > 0) then
    begin
      --Bug 2358728A
      --Obtain the user_id based on the unique user_name
      SELECT USER_ID
      INTO   l_user_id
      FROM   FND_USER
      WHERE  user_name = Get_Profile_Value.user_name;
    exception
      when NO_DATA_FOUND then
        l_user_id := to_number(null);
    end;
    if (l_user_id is not null) then
      result := fnd_profile.value_specific(name=>Get_Profile_Value.name,
                  user_id=>l_user_id);
    else
      result := null;
    end if;
  else
    result := null;
  end if;

  return result;

exception
  when OTHERS then
    Wf_Core.Context('Wfa_Sec', 'Get_Profile_Value', name, user_name);
    raise;
end Get_Profile_Value;

-- Local_Chr
--   Return specified character in current codeset
-- IN
--   ascii_chr - chr number in US7ASCII
function Local_Chr(
  ascii_chr in number)
return varchar2
is
begin
  if (ascii_chr = 10) then

      if (WF_CORE.LOCAL_CS_NL is null) then
          WF_CORE.LOCAL_CS_NL := Fnd_Global.Local_Chr(ascii_chr);
      end if;

      return WF_CORE.LOCAL_CS_NL;

  elsif (ascii_chr = 9) then

      if (WF_CORE.LOCAL_CS_TB is null) then
          WF_CORE.LOCAL_CS_TB := Fnd_Global.Local_Chr(ascii_chr);
      end if;

      return WF_CORE.LOCAL_CS_TB;

  elsif (ascii_chr = 13) then

      if (WF_CORE.LOCAL_CS_CR is null) then
          WF_CORE.LOCAL_CS_CR := Fnd_Global.Local_Chr(ascii_chr);
      end if;

      return WF_CORE.LOCAL_CS_CR;

  else

      return(Fnd_Global.Local_Chr(ascii_chr));

  end if;

end Local_Chr;

--
-- DirectLogin - Return proper function name for DirectLogin  --Bug: 1566390
-- Also needed to port bug 1838410
--
function DirectLogin (nid in NUMBER) return VARCHAR2
IS
x_mode varchar2(30);
BEGIN
fnd_profile.get('WF_ICX_MODE',x_mode);

return ('OracleApps.DF?i_direct=' || WFA_SEC.DetailURL(nid) || '&i_mode=' ||
        nvl(x_mode,'2'));

exception
  when others then
    Wf_Core.Context('Wfa_Sec', 'DirectLogin', to_char(nid));
    raise;
end DirectLogin;


--
-- GetFWKUserName
--   Return current Framework user name
--
function GetFWKUserName
return varchar2
is
begin
  return FND_GLOBAL.USER_NAME;
exception
  when others then
    Wf_Core.Context('Wfa_Sec', 'GetFWKUserName');
    raise;
end GetFWKUserName;

--
-- Logout
-- This is a dummy procedure, wfa_html.logout should be used
-- unless single signon feature is activated
--
procedure Logout
is
begin
return;
end Logout;


--
-- DS_Count_Local_Role (PRIVATE)
--   Returns count of a role in local directory service table
-- IN
--   role_name - role to be counted
-- RETURN
--   count of provided role in local directory service table
--
function DS_Count_Local_Role(role_name in varchar2)
return number
is
  cnt number;
begin
  select count(1) into cnt
    from WF_LOCAL_ROLES PARTITION (WF_LOCAL_ROLES)
   where NAME = role_name
     and ORIG_SYSTEM in ('WF_LOCAL_ROLES', 'WF_LOCAL_USERS')
     and ORIG_SYSTEM_ID = 0;

  return(cnt);

exception
 when others then
   WF_CORE.Context('WFA_SEC', 'DS_Count_Local_Role', role_name);
   raise;
end DS_Count_Local_Role;

--
-- DS_Update_Local_Role (PRIVATE)
--   Update old name user/role in local directory service tables with new name
-- IN
--   OldName - original name to be replaced
--   NewName - new name to replace
--
procedure DS_Update_Local_Role(
  OldName in varchar2,
  NewName in varchar2
)
is
begin
   update WF_LOCAL_ROLES PARTITION (WF_LOCAL_ROLES)
   set    NAME = NewName
   where  NAME = OldName
   and    ORIG_SYSTEM in ('WF_LOCAL_USERS', 'WF_LOCAL_ROLES')
   and    ORIG_SYSTEM_ID = 0;

   -- Update local user roles
   update WF_LOCAL_USER_ROLES PARTITION (WF_LOCAL_ROLES)
   set    USER_NAME = NewName
   where  USER_NAME = OldName
   and    USER_ORIG_SYSTEM = 'WF_LOCAL_USERS'
   and    USER_ORIG_SYSTEM_ID = 0;

   update WF_LOCAL_USER_ROLES PARTITION (WF_LOCAL_ROLES)
   set    ROLE_NAME = NewName
   where  ROLE_NAME = OldName
   and    ROLE_ORIG_SYSTEM = 'WF_LOCAL_USERS'
   and    ROLE_ORIG_SYSTEM_ID = 0;

   update WF_LOCAL_USER_ROLES PARTITION (WF_LOCAL_ROLES)
   set    ROLE_NAME = NewName
   where  ROLE_NAME = OldName
   and    ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES'
   and    ROLE_ORIG_SYSTEM_ID = 0;



exception
 when others then
   WF_CORE.Context('WFA_SEC', 'DS_Update_Local_Role', OldName, NewName);
   raise;
end DS_Update_Local_Role;

function GetUser
return varchar2
is
username varchar2(320);
begin
 username := wfa_sec.GetFWKUserName;
 return username;
exception
  when others then
  --Incase of exception just return null
  return '';
end;


--
-- user_id
--   Return current user id, in apps, wrapper to  FND_GLOBAL.user_id
--   In standalone, returns -1.
function user_id return number is

begin
  return FND_GLOBAL.user_id;
end;

--
-- login_id
--   Return current login id, in apps, wrapper to  FND_GLOBAL.login_id
--   In standalone, returns -1.
function login_id return number is
begin
  return FND_GLOBAL.login_id;
end;

--
-- security_group_id
--   Return current security_group_id, in apps, wrapper to
--   FND_GLOBAL.security_group_id  In standalone, returns -1.
function security_group_id return number is
begin
  return FND_GLOBAL.security_group_id;
end;

--
-- CheckSession
--   Check the cached ICX session id against the current session id to determine
--   if the session has been changed. This function caches the current session id
--   after the check.
-- RETURN
--   boolean - True if session matches, else False
function CheckSession return boolean
is
begin
  if (wfa_sec.g_session_id = fnd_session_management.g_session_id) then
     -- Session has not changed from the previous one or the WF Code executes in the
     -- background where both are -1.
     return true;
  else
     -- Cache current session id since it has changed
     wfa_sec.g_session_id := fnd_session_management.g_session_id;
     return false;
  end if;
end CheckSession;

-- See spec for description
function Random return varchar2
is
begin
  -- Fnd_crypto.RandomNumber return a number of 16 bytes which has maximum
  -- 39 digits.  This is well within the limit of 80 that this random
  -- function is returning.
  return(to_char(fnd_crypto.RandomNumber));
end Random;

--
-- CacheCtx
--   Caches current session context values such as user_id, resp_id,
--   resp_appl_id and so on from FND_GLOBAL package
--
procedure Cache_Ctx is
  l_msg varchar2(500);
begin
  -- If already cached, don't do it again
  if (g_cached) then
    return;
  end if;

  g_session_ctx := fnd_global.get_session_context;

  -- No context initialized yet, initialize a default context typically
  -- used in workflow background services
  if (g_session_ctx is null or g_session_ctx <= 0) then
    fnd_global.apps_initialize(user_id => g_user_id,
                               resp_id => g_resp_id,
                               resp_appl_id => g_resp_appl_id,
                               security_group_id => g_security_group_id,
                               server_id => g_server_id);
    g_session_ctx := fnd_global.get_session_context;
  end if;

  -- cache
  g_user_id := fnd_global.user_id;
  g_resp_id := fnd_global.resp_id;
  g_resp_appl_id := fnd_global.resp_appl_id;
  g_security_group_id := fnd_global.security_group_id;
  g_server_id := fnd_global.server_id;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    l_msg := 'Cached - '||g_user_id||':'||g_resp_id||':'||g_resp_appl_id||':'
            ||g_security_group_id||':'||g_server_id||'->'||g_session_ctx;
    wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.wfa_sec.cache_ctx.cached', l_msg);
  end if;
  -- cached
  g_cached := true;

exception
  when others then
    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_error,
                      'wf.plsql.wfa_sec.cache_ctx.exception', sqlerrm);
    end if;
end Cache_Ctx;

--
-- SynchCtx
--   Resets current context based on the cached values
--
procedure Restore_Ctx is
  l_msg varchar2(500);
begin

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
   wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.wfa_sec.restore_ctx.restored', 'BEGIN');
  end if;

  -- nothing to restore from
  if (not g_cached) then
    return;
  end if;

  -- if the current context is different from the cached context
  -- it would have been modified after it was cached
  if (not fnd_global.compare_session_context(g_session_ctx)) then

    -- fnd_global.compare_session_context: returns true if the session_context is
    -- the same as context_id, otherwise returns false.
    -- fnd_global.get_session_context is changed whenever fnd_global.apps_initialize
    -- is being called.
    fnd_global.apps_initialize(user_id => g_user_id,
                               resp_id => g_resp_id,
                               resp_appl_id => g_resp_appl_id,
                               security_group_id => g_security_group_id,
                               server_id => g_server_id);

    g_session_ctx := fnd_global.get_session_context;

    -- bug 9747572 :
    --  If next activity is being deferred to WF background in same db-session
    --  for same itemtype and itemkey, let selector function be executed in next iteration .
    --
    wf_engine.setctx_itemtype := null;
    wf_engine.setctx_itemkey := null;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      l_msg := 'Restored to - '||g_user_id||':'||g_resp_id||':'||g_resp_appl_id||':'
             ||g_security_group_id||':'||g_server_id||'->'||g_session_ctx;

      wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.wfa_sec.restore_ctx.restored', l_msg);
    end if;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
   wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.wfa_sec.restore_ctx.restored', 'END');
  end if;

exception
  when others then
    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_error,
                      'wf.plsql.wfa_sec.restore_ctx.exception', sqlerrm);
    end if;
end Restore_Ctx;

end WFA_SEC;

/
