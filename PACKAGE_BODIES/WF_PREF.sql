--------------------------------------------------------
--  DDL for Package Body WF_PREF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_PREF" as
/* $Header: wfprfb.pls 120.3.12010000.3 2009/09/16 06:50:24 skandepu ship $ */


--
-- Package Globals
--

--
-- Error (PRIVATE)
--   Print a page with an error message.
--   Errors are retrieved from these sources in order:
--     1. wf_core errors
--     2. Oracle errors
--     3. Unspecified INTERNAL error
--
procedure Error
as
begin
    null;
end Error;

/*===========================================================================

Function        get_open_lov_window_html

Purpose         Get the javascript function to open a lov window based on
                a url and a window size.

============================================================================*/
PROCEDURE get_open_lov_window_html IS

BEGIN

   htp.p('<SCRIPT LANGUAGE="JavaScript"> <!-- hide the script''s contents from feeble browsers');

   htp.p(
      'function fnd_open_dm_window(x,y)
       {
          window.focus();
          document.WF_PREF.p_dm_home.value = x + '':''+ y;
       }'
   );

   htp.p('<!-- done hiding from old browsers --> </SCRIPT>');

   htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('wf_pref',
                      'get_open_lov_window_html');
      RAISE;

END get_open_lov_window_html;

-- Javascript function to validate new passwords
-- Bug# 2127392

PROCEDURE validate_password IS

BEGIN

   htp.p('<SCRIPT LANGUAGE="JavaScript"> <!-- hide the script''s contents from feeble browsers');

   htp.p(
      'function form_submit()
       {
          var l_submit = true;
          if ( document.WF_PREF.p_ldap_npwd.value.length > 0 || document.WF_PREF.p_ldap_rpwd.value.length > 0 )
          {
             if ( document.WF_PREF.p_ldap_npwd.value.length < 5 )
             {
                 l_submit = false;
                 window.alert("' || wf_core.translate('WFPREF_LDAP_PASSWORD_LEN') ||'");
                 document.WF_PREF.p_ldap_npwd.focus();
             }
             else if( document.WF_PREF.p_ldap_npwd.value != document.WF_PREF.p_ldap_rpwd.value )
             {
                 l_submit = false;
                 window.alert("' || wf_core.translate('WFPREF_LDAP_PASSWORD_MISMATCH') || '");
                 document.WF_PREF.p_ldap_rpwd.focus();
             }
           }
           if ( l_submit == true)
              document.WF_PREF.submit();
       }'
   );

   htp.p('<!-- done hiding from old browsers --> </SCRIPT>');

   htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('wf_pref',
                      'validate_password');
      RAISE;

END validate_password;


procedure create_reg_button (
when_pressed_url  IN VARCHAR2,
onmouseover       IN VARCHAR2,
icon_top          IN VARCHAR2,
icon_name         IN VARCHAR2,
show_text         IN VARCHAR2)
IS

onmouseover_text varchar2(240) := null;

BEGIN

    wfa_html.create_reg_button (when_pressed_url, onmouseover, icon_top, icon_name, show_text);

exception
  when others then
    rollback;
    wf_core.context('Wf_Pref', 'create_reg_button',when_pressed_url,onmouseover,
                    icon_top,icon_name,show_text);
    wf_pref.Error;

end create_reg_button;

--
-- Edit
--   Edit user preferences
--
procedure edit (edit_defaults in varchar2)
is
begin
  null;
exception
  when others then
    rollback;
    wf_core.context('Wf_Pref', 'Edit', edit_defaults);
    wf_pref.Error;
end edit;

--
-- Edit
--   Edit user preferences
--
procedure edit_form (edit_defaults in varchar2)
is
begin
  null;
exception
  when others then
    rollback;
    wf_core.context('Wf_Pref', 'Edit_Form', edit_defaults);
    wf_pref.Error;
end edit_form;

--
-- Lang_LOV
--   Create the data for the Language List of Values
--
procedure Lang_LOV (p_titles_only   IN VARCHAR2,
                    p_find_criteria IN VARCHAR2)

IS

l_username VARCHAR2(320);
l_code      VARCHAR2(4);
l_language  VARCHAR2(30);
l_territory VARCHAR2(30);
l_row_count NUMBER := 0;

CURSOR c_lang_lov (c_find_criteria IN VARCHAR2) IS
SELECT nls_language, nls_territory, code
FROM   wf_languages
WHERE  nls_language like c_find_criteria
AND    installed_flag = 'Y'
ORDER  BY nls_language;

BEGIN
   -- Authenticate user
   wfa_sec.GetSession(l_username);

   IF (p_titles_only = 'N') THEN

      SELECT COUNT(*)
      INTO   l_row_count
      FROM   wf_languages
      WHERE  nls_language like p_find_criteria||'%'
      AND    installed_flag = 'Y';

   END IF;

   htp.p(wf_core.translate('WFPREF_LANGUAGE_PROMPT'));
   htp.p('3');
   htp.p(TO_CHAR(l_row_count));
   htp.p(wf_core.translate('WFPREF_LANGUAGE_PROMPT'));
   htp.p('50');
   htp.p(wf_core.translate('WFPREF_TERRITORY_PROMPT'));
   htp.p('50');
   htp.p('CODE');
   htp.p('0');

   IF (p_titles_only = 'N') THEN

      OPEN c_lang_lov (p_find_criteria||'%');

      /*
      ** Loop through all the language rows for the given find_criteria
      ** and write them out to the web page
      */
      LOOP

         FETCH c_lang_lov INTO
             l_language, l_territory, l_code;

         EXIT WHEN c_lang_lov%NOTFOUND;

         htp.p (l_language);
         htp.p (l_territory);
         htp.p (l_code);

      END LOOP;

   END IF;

exception
  when others then
    rollback;
    wf_core.context('Wf_Pref', 'lang_lov',p_titles_only, p_find_criteria);
    wf_pref.Error;
END lang_lov;

--
-- Terr_LOV
--   Create the data for the Territories List of Values
--
procedure Terr_LOV (p_titles_only   IN VARCHAR2,
                    p_find_criteria IN VARCHAR2)

IS

l_code      VARCHAR2(4);
l_territory VARCHAR2(30);
l_language  VARCHAR2(30);
l_row_count NUMBER := 0;
l_username  VARCHAR2(320);

CURSOR c_Terr_lov (c_find_criteria IN VARCHAR2) IS
SELECT
 nls_territory,
 nls_language,
 code
FROM   wf_languages
WHERE  nls_territory like c_find_criteria
AND    installed_flag = 'Y'
ORDER  BY nls_language;

BEGIN

   -- Authenticate user
   wfa_sec.GetSession(l_username);

   IF (p_titles_only = 'N') THEN

      SELECT COUNT(*)
      INTO   l_row_count
      FROM   wf_languages
      WHERE  nls_territory like p_find_criteria||'%'
      AND    installed_flag = 'Y';

   END IF;

   htp.p(wf_core.translate('WFPREF_TERRITORY_PROMPT'));
   htp.p('3');
   htp.p(TO_CHAR(l_row_count));
   htp.p(wf_core.translate('WFPREF_TERRITORY_PROMPT'));
   htp.p('50');
   htp.p(wf_core.translate('WFPREF_LANGUAGE_PROMPT'));
   htp.p('50');
   htp.p('Code');
   htp.p('0');

   IF (p_titles_only = 'N') THEN

      OPEN c_Terr_lov (p_find_criteria||'%');

      /*
      ** Loop through all the language rows for the given find_criteria
      ** and write them out to the web page
      */
      LOOP

         FETCH c_Terr_lov INTO
             l_territory, l_language, l_code;

         EXIT WHEN c_Terr_lov%NOTFOUND;

         htp.p (l_territory);
         htp.p (l_language);
         htp.p (l_code);

      END LOOP;

   END IF;

exception
  when others then
    rollback;
    wf_core.context('Wf_Pref', 'Terr_lov',p_titles_only, p_find_criteria);
    wf_pref.Error;
END terr_lov;

--
-- DM_LOV
--   Create the data for the Territories List of Values
--
procedure DM_LOV (p_titles_only   IN VARCHAR2,
                  p_find_criteria IN VARCHAR2)

IS

l_username  VARCHAR2(320);
l_node_id   NUMBER;
l_node_name VARCHAR2(80);
l_node_desc VARCHAR2(240);
l_row_count NUMBER := 0;

CURSOR c_dm_lov (c_find_criteria IN VARCHAR2) IS
SELECT
node_id,
node_name,
node_description
FROM   fnd_dm_nodes
WHERE  node_name like p_find_criteria||'%'
ORDER  BY node_name;

BEGIN

   -- Authenticate user
   wfa_sec.GetSession(l_username);

   IF (p_titles_only = 'N') THEN

      SELECT COUNT(*)
      INTO   l_row_count
      FROM   fnd_dm_nodes
      WHERE  node_name like p_find_criteria||'%';

   END IF;

   htp.p(wf_core.translate('WFPREF_DMHOME_PROMPT'));
   htp.p('3');
   htp.p(TO_CHAR(l_row_count));
   htp.p(wf_core.translate('WFPREF_DMHOME_PROMPT'));
   htp.p('40');
   htp.p(wf_core.translate('DESCRIPTION'));
   htp.p('60');
   htp.p('NODE_ID');
   htp.p('0');

   IF (p_titles_only = 'N') THEN

      OPEN c_dm_lov (p_find_criteria||'%');

      /*
      ** Loop through all the language rows for the given find_criteria
      ** and write them out to the web page
      */
      LOOP

         FETCH c_dm_lov INTO
             l_node_id, l_node_name,l_node_desc;

         EXIT WHEN c_dm_lov%NOTFOUND;

         htp.p (l_node_name);
         htp.p (l_node_desc);
         htp.p (TO_CHAR(l_node_id));

      END LOOP;

   END IF;

exception
  when others then
    rollback;
    wf_core.context('Wf_Pref', 'DM_lov',p_titles_only, p_find_criteria);
    wf_pref.Error;
END DM_LOV;


PROCEDURE update_pref (
p_admin_role            IN VARCHAR2,
p_display_admin_role    IN VARCHAR2,
p_web_agent             IN VARCHAR2,
p_edit_defaults         IN VARCHAR2,
p_language              IN VARCHAR2,
p_territory             IN VARCHAR2,
p_date_format           IN VARCHAR2,
p_dm_node_id            IN VARCHAR2,
p_dm_home               IN VARCHAR2,
p_mailtype              IN VARCHAR2,
p_classid               IN VARCHAR2,
p_plugin_loc            IN VARCHAR2,
p_plugin_ver            IN VARCHAR2,
p_system_guid           IN VARCHAR2,
p_system_name           IN VARCHAR2,
p_system_status         IN VARCHAR2,
p_ldap_host             IN VARCHAR2,
p_ldap_port             IN VARCHAR2,
p_ldap_user             IN VARCHAR2,
p_ldap_opwd             IN VARCHAR2,
p_ldap_npwd             IN VARCHAR2,
p_ldap_rpwd             IN VARCHAR2,
p_ldap_log_base         IN VARCHAR2,
p_ldap_user_base        IN VARCHAR2,
p_text_signon           IN VARCHAR2
) IS

BEGIN
  null;
END update_pref;

--update_pref for OA FWK UI. This is Framework specific API that gives
--validation errors using out parameter p_err_msg. Exceptions are
--wrapped in OAF.

PROCEDURE update_pref_fwk (
p_admin_role            IN VARCHAR2,
p_display_admin_role    IN VARCHAR2,
p_web_agent             IN VARCHAR2,
p_edit_defaults         IN VARCHAR2,
p_language              IN VARCHAR2,
p_territory             IN VARCHAR2,
p_date_format           IN VARCHAR2,
p_dm_node_id            IN VARCHAR2,
p_dm_home               IN VARCHAR2,
p_mailtype              IN VARCHAR2,
p_classid               IN VARCHAR2,
p_plugin_loc            IN VARCHAR2,
p_plugin_ver            IN VARCHAR2,
p_system_guid           IN VARCHAR2,
p_system_name           IN VARCHAR2,
p_system_status         IN VARCHAR2,
p_ldap_host             IN VARCHAR2,
p_ldap_port             IN VARCHAR2,
p_ldap_user             IN VARCHAR2,
p_ldap_opwd             IN VARCHAR2,
p_ldap_npwd             IN VARCHAR2,
p_ldap_rpwd             IN VARCHAR2,
p_ldap_log_base         IN VARCHAR2,
p_ldap_user_base        IN VARCHAR2,
p_text_signon           IN VARCHAR2,
p_num_format            IN VARCHAR2,
p_browser_dll_loc       IN VARCHAR2,
p_err_msg               OUT NOCOPY VARCHAR2
) IS

  l_row_count   number := 0;
  l_combo_count number := 0;
  l_dm_node_id  number;
  l_name        varchar2(320);   -- Username to query
  username      varchar2(320);   -- Username to query
  realname      varchar2(360);  -- Display name of username
  admin_role    varchar2(320);   -- Role for admin mode
  admin_mode    varchar2(1);    -- Does user have admin privledges
  s0            varchar2(2000);
  l_url         varchar2(240);
  l_test_date   varchar2(40);
  l_media       varchar2(240) := wfa_html.image_loc;
  l_icon        varchar2(30) := 'FNDILOV.gif';
  l_text        varchar2(30) := '';
  l_onmouseover varchar2(240)  := wf_core.translate ('WFPREF_LOV');
  l_error_msg   varchar2(2000) := NULL;
  l_sguid       raw(16);
  rowid         varchar2(30);

  /* Bug 2127392 */
  l_ldap_error  varchar2(2000) := NULL;
  l_ldap_pwd    varchar2(30);
  l_ldap_opwd   varchar2(30);
BEGIN
  l_ldap_opwd := p_ldap_opwd;

  -- wfa_sec.GetSession(username) cannot be used from Framework, Use GetFWKUserName instead
  username := wfa_sec.GetFWKUserName;
  username := upper(username);
  wf_directory.GetRoleInfo(username, realname, s0, s0, s0, s0);
  IF (p_edit_defaults = 'Y') THEN
     admin_mode := 'N';
     admin_role := wf_core.translate('WF_ADMIN_ROLE');
     if (admin_role = '*' or
         Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
         username := '-WF_DEFAULT-';
     else
         -- cannot edit defaults unless you're the administrator
         l_error_msg := wf_core.translate('WFPREF_INVALID_ADMIN');

     end if;

  END IF;

  -- Validate the language preference
  IF (p_language IS NOT NULL) THEN

     SELECT count(*)
     INTO   l_row_count
     FROM   wf_languages
     WHERE  nls_language = p_language
     AND    installed_flag = 'Y';

  ELSE

    -- If there is no value then set it to null
    l_row_count := 1;

  END IF;

  -- Validate the combination of language/territory preferences are valid
  IF (p_language IS NOT NULL AND l_row_count <> 0
       AND p_territory IS NOT NULL) THEN

     SELECT count(*)
     INTO   l_combo_count
     FROM   wf_languages
     WHERE  nls_language = p_language
     AND    nls_territory = p_territory
     AND    installed_flag = 'Y';

     IF (l_combo_count = 0) THEN

         l_error_msg := wf_core.translate ('WFPREF_INVALID_COMBO');

     END IF;


  END IF;

  IF (l_row_count > 0) THEN

     IF (l_combo_count > 0) THEN

       -- put the language preference
       fnd_preference.put (username, 'WF', 'LANGUAGE', p_language);

     END IF;

  ELSE

     l_error_msg := wf_core.translate ('WFPREF_INVALID_LANGUAGE');

  END IF;

  -- Validate the territory preference
  IF (p_territory IS NOT NULL) THEN

     SELECT count(*)
     INTO   l_row_count
     FROM   wf_languages
     WHERE  nls_territory = p_territory
     AND    installed_flag = 'Y';

  ELSE

    -- If there is no value then set it to null
    l_row_count := 1;

  END IF;

  IF (l_row_count > 0) THEN

     IF (l_combo_count > 0) THEN

        -- put the territory preference
        fnd_preference.put (username, 'WF', 'TERRITORY', p_territory);

     END IF;

  ELSE

     l_error_msg := wf_core.translate ('WFPREF_INVALID_TERRITORY');

  END IF;

  -- Validate the date format
  BEGIN

     SELECT TO_CHAR(sysdate, RTRIM(p_date_format))
     INTO   l_test_date
     FROM   dual;

     EXCEPTION
     WHEN OTHERS THEN
          l_error_msg :=  wf_core.translate ('WFPREF_INVALID_DATE_FORMAT') ||
                ': ' || p_date_format;

  END;

  IF (l_error_msg IS NULL) THEN

     -- put the date format preference
     -- The rtrim is required if the user adds a blank space at the end
     -- of the format and we concatenate on a time format with a space then
     -- the double space will cause an ora-1830 errror.
     fnd_preference.put (username, 'WF', 'DATEFORMAT', RTRIM(p_date_format));

  END IF;

  -- put the number format preference  - Added new parameter for Global preference OAF page

  IF(p_num_format IS NOT NULL) THEN
       fnd_preference.put (username, 'WF', 'NUMBERFORMAT', p_num_format);
  END IF;

  -- Bug 2589782 Update LDAP info only if Global preference values are
  -- updated by an Admin

  IF (p_edit_defaults = 'Y' AND admin_mode = 'Y') THEN
     -- put the LDAP preferences
     fnd_preference.put('#INTERNAL', 'LDAP_SYNCH', 'HOST',     p_ldap_host);
     fnd_preference.put('#INTERNAL', 'LDAP_SYNCH', 'PORT',     p_ldap_port);
     fnd_preference.put('#INTERNAL', 'LDAP_SYNCH', 'USERNAME', p_ldap_user);

     -- Bug 2127392 Validating LDAP password

     l_ldap_pwd  := fnd_preference.eget('#INTERNAL','LDAP_SYNCH', 'EPWD', 'LDAP_PWD');

     IF (l_ldap_opwd is NULL) THEN
        l_ldap_opwd := 'x';
     END IF;
     IF (l_ldap_pwd is NULL) THEN
        l_ldap_pwd := 'x';
     END IF;

     IF (l_ldap_opwd <> 'x' OR length(p_ldap_rpwd) > 0) THEN
        IF (l_ldap_pwd <> l_ldap_opwd) THEN
           l_ldap_error := wf_core.translate ('WFPREF_INVALID_LDAP_PASSWORD');
        END IF;

        -- New password updated only if the Old password is valid
        IF (l_ldap_error IS NULL) THEN
            fnd_preference.eput('#INTERNAL','LDAP_SYNCH', 'EPWD', p_ldap_rpwd,
                                'LDAP_PWD');
        ELSE
            l_error_msg := l_ldap_error;
        END IF;
     END IF;

     fnd_preference.put('#INTERNAL', 'LDAP_SYNCH', 'CHANGELOG_DIR', p_ldap_log_base);
     fnd_preference.put('#INTERNAL', 'LDAP_SYNCH', 'USER_DIR', p_ldap_user_base);

  END IF;

  -- put the mail preference
  fnd_preference.put (username, 'WF', 'MAILTYPE', p_mailtype);

  -- put the text only mail preference
  fnd_preference.put (username, 'WF', 'WF_SIG_TEXT_ONLY', p_text_signon);

  -- put the browser signing DLL location preference  - Added new parameter for Global preference OAF page
  --IF (p_browser_dll_loc IS NOT NULL) THEN // not required
   fnd_preference.put (username, 'WF', 'WF_SIG_IE_DLL', p_browser_dll_loc);
  --END IF;

  -- put the dm home node preference
  fnd_document_management.set_dm_home (username, l_dm_node_id);


   IF (admin_mode = 'Y') THEN

      -- Check the admin role
      IF (p_display_admin_role <> '*') THEN

         admin_role := p_admin_role;
         -- Get all the username find criteria resolved
         -- rajaagra march-3-2004 bug 4185567
         -- wfa_html.validate_display_name (p_display_admin_role, admin_role);

         BEGIN

            wf_directory.GetRoleInfo(UPPER(admin_role), realname, s0, s0, s0, s0);
            if (realname IS NULL) then

               l_name := NULL;

            else

               l_name := UPPER(admin_role);

            end if;

         END;

      ELSE

         l_name := '*';

      END IF;

      IF (l_name IS NOT NULL) THEN

         -- Update the admin role
         UPDATE wf_resources
         SET    text = UPPER(l_name)
         WHERE  type = 'WFTKN'
         AND    name = 'WF_ADMIN_ROLE';

      ELSE
        l_error_msg := wf_core.translate ('WFPREF_INVALID_ROLE_NAME')||
                 ': ' || UPPER(p_display_admin_role);

      END IF;

      -- Update the web agent
      UPDATE wf_resources
      SET    text = p_web_agent
      WHERE  type = 'WFTKN'
      AND    name = 'WF_WEB_AGENT';

      /*
       ** Bug 2307342
       ** It is no longer possible to update jinitiator info
       ** from the Global Preferences page

      -- Update the jinitiator info
      UPDATE wf_resources
      SET    text = p_classid
      WHERE  type = 'WFTKN'
      AND    name = 'WF_CLASSID';

      UPDATE wf_resources
      SET    text = p_plugin_loc
      WHERE  type = 'WFTKN'
      AND    name = 'WF_PLUGIN_DOWNLOAD';

      UPDATE wf_resources
      SET    text = p_plugin_ver
      WHERE  type = 'WFTKN'
      AND    name = 'WF_PLUGIN_VERSION';

      */

      -- Update/Insert the Local System Info
      -- validate the system name
      if p_system_guid is not null then
        l_sguid := hextoraw(p_system_guid);
        Wf_Event_Html.Validate_System_Name(p_system_name, l_sguid);

        -- update the local system guid
        begin
          Wf_Resources_Pkg.Update_Row(
          x_type=>'WFTKN',
          x_name=>'WF_SYSTEM_GUID',
          x_protect_level=>0,
          x_custom_level=>0,
          x_id=>0,
          x_text=>rawtohex(l_sguid)
          );
        exception
          when NO_DATA_FOUND then
            Wf_Resources_Pkg.Insert_Row(
            x_rowid=>rowid,
            x_type=>'WFTKN',
            x_name=>'WF_SYSTEM_GUID',
            x_protect_level=>0,
            x_custom_level=>0,
            x_id=>0,
            x_text=>rawtohex(l_sguid)
            );
        end;
      end if;

      -- update the local system status
      begin
          Wf_Resources_Pkg.Update_Row(
          x_type=>'WFTKN',
          x_name=>'WF_SYSTEM_STATUS',
          x_protect_level=>0,
          x_custom_level=>0,
          x_id=>0,
          x_text=>p_system_status
        );
      exception
        when NO_DATA_FOUND then
          Wf_Resources_Pkg.Insert_Row(
            x_rowid=>rowid,
            x_type=>'WFTKN',
            x_name=>'WF_SYSTEM_STATUS',
            x_protect_level=>0,
            x_custom_level=>0,
            x_id=>0,
            x_text=>p_system_status
          );
      end;

   END IF;

   IF (l_error_msg IS NULL) THEN

      p_err_msg := NULL;

   ELSE
      -- to be returned back to OAF page
      p_err_msg := l_error_msg;

   END IF;
exception
  when others then
    rollback;
    wf_core.context('Wf_Pref', 'update_pref',
                    p_language ,
                    p_territory   ,
                    p_admin_role,
                    p_display_admin_role   );
   --Since Error procedure cannot be called here, raise the exception so that it can be wrapped in Framework
   raise;
END update_pref_fwk;

-- get_pref2
-- Bug 8823516 - overriden function of get_pref().
-- Returns the default preference 'MAILHTML' when called by the
-- product team and null for WFDS, if both the user and global
-- preference values are null in FND_USER_PREFERENCES table.

FUNCTION get_pref2
(
p_user_name        IN  VARCHAR2,
p_preference_name  IN  VARCHAR2,
p_caller           IN  VARCHAR2

)  RETURN VARCHAR2 IS

l_preference_value    VARCHAR2(240) := NULL;

BEGIN

   -- Check if there is a preference for this user
   SELECT MAX(PREFERENCE_VALUE)
   INTO   l_preference_value
   FROM   FND_USER_PREFERENCES
   WHERE  USER_NAME = p_user_name
   AND    PREFERENCE_NAME = p_preference_name
   AND    MODULE_NAME = 'WF';

   -- If there is no preference for this user then try to
   -- get the default
   IF (l_preference_value IS NULL) THEN

      SELECT MAX(PREFERENCE_VALUE)
      INTO   l_preference_value
      FROM   FND_USER_PREFERENCES
      WHERE  USER_NAME = '-WF_DEFAULT-'
      AND    PREFERENCE_NAME = p_preference_name
      AND    MODULE_NAME = 'WF';

   END IF;

   -- provide a default notification preference value if not set, when
   -- called by the product team
   if(p_caller is null) then
      if l_preference_value is null and p_preference_name = 'MAILTYPE' THEN
         l_preference_value :='MAILHTML';
      end if;
   end if;

   /*
   ** The following hard code is for the mailer.  The wf_roles view
   ** defaults the language to the session value if it doesn't find a
   ** preference.  If the global is not set and one user is set and another
   ** one isn't then it could cause the next user to receive a message in
   ** a random laguage.  At least if it's in american we can detect the bug
   ** and set it to 32.  Yes it's a narrow case but it may prevent a bug
   */

   if (l_preference_value IS NULL AND p_preference_name = 'LANGUAGE') THEN

      l_preference_value := 'AMERICAN';

   elsif (l_preference_value IS NULL AND p_preference_name = 'TERRITORY') THEN

      l_preference_value := 'AMERICA';

   end if;

   return l_preference_value;

END get_pref2;

 -- get_pref
 -- Bug 8823516 - Calls the get_pref2() by adding a
 -- new attribute 'p_caller' to determine the caller.
FUNCTION get_pref
(
p_user_name        IN  VARCHAR2,
p_preference_name  IN  VARCHAR2
)  RETURN VARCHAR2 IS

begin

  return get_pref2(p_user_name, p_preference_name, null);

end get_pref;

end WF_PREF;

/
