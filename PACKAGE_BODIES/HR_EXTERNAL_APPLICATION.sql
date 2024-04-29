--------------------------------------------------------
--  DDL for Package Body HR_EXTERNAL_APPLICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EXTERNAL_APPLICATION" AS
/* $Header: hrextapp.pkb 120.0 2005/05/31 00:11:58 appldev noship $ */

-- Applications username holds the site level username / password
g_site_user_name CONSTANT VARCHAR2(100) := 'SYSADMIN';

-- Logging code data
g_module         CONSTANT VARCHAR2(80) :=
                                         'per.pl_sql.hr_external_application';

-- named exception for external apps
e_extappexception  EXCEPTION;

-- SSO server related constants

l_sso_extapp_launcher CONSTANT VARCHAR2(80) :=
                                         'wwsso_app_admin.fapp_process_login';


-- displayError
--
--   Displays error text to the user
--
PROCEDURE displayError(p_msg IN VARCHAR2) IS

l_procedure  VARCHAR2(31) := 'display_error';

BEGIN

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => p_msg);
END IF;

-- show error
--htp.p(p_msg);

htp.htmlOpen;
htp.bodyOpen;
htp.p(p_msg);
htp.bodyClose;
htp.htmlClose;


IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

END displayError;

--
-- Returns the URL of the routine responsible for logging into an
-- external application
--
FUNCTION get_extapp_url(p_app_id IN VARCHAR2) RETURN VARCHAR2 IS

l_retval VARCHAR2(255);
l_procedure VARCHAR2(31) := 'get_extapp_url';

BEGIN

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
  END IF;

l_retval := hr_sso_utl.get_sso_query_path(l_sso_extapp_launcher)
             || '?p_app_id='||p_app_id;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'extapp_url is ' || l_retval);
  END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
  END IF;

RETURN (l_retval);

END get_extapp_url;

--
-- Used to determine whether the site level credentials should always
-- be used. For the time being this would entail the user level credentials
-- being overriden so it always returns false.
--
FUNCTION site_override RETURN BOOLEAN IS
BEGIN

RETURN false;

END site_override;

--
-- Name
--   call_extapp
--
-- Parameters
--      p_app_id      app_id of External Application
--      p_new_window  If TRUE opens a new window otherwise
--                     replaces the current one
--
-- Purpose
--   Calls the External Application possibly in a new window.
--
--
-- Notes
--
--   The new window mode could be improved but not by much
--
PROCEDURE call_extapp(p_app_id     IN VARCHAR2,
                      p_new_window IN BOOLEAN DEFAULT false ) IS

l_url VARCHAR2(255);
l_procedure VARCHAR2(31) := 'call_extapp';

BEGIN

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
  END IF;

--
-- A limitation of the external application invocation routine is that
-- it needs to be called via the SSO DAD. This is fixable but probably
-- only at the expense of creating a lot of SSO synonyms in APPS.
--
l_url := get_extapp_url(p_app_id);

IF ( p_new_window ) THEN

  -- Open a new window. Go back to the previous window
  htp.script('window.open("' || l_url || '","newwindow");' ||
             'history.go(-1);',
             'javascript');

ELSE
  --
  -- Possible performance concerns using this function with IE
  -- may be worth switching to using 'location.replace()'
  --
  owa_util.redirect_url(l_url);

END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

END call_extapp;


-- Name
--   check_app_id
-- Purpose
--   Checks whether the given app_id is valid.
--
FUNCTION check_app_id (p_app_id IN VARCHAR2) RETURN BOOLEAN IS

l_retval     BOOLEAN := false;
l_app_name   VARCHAR2(80);
l_apptype    VARCHAR2(80);
l_appurl     VARCHAR2(1000);
l_logout_url VARCHAR2(1000);
l_userfield  VARCHAR2(80);
l_pwdfield   VARCHAR2(80);
l_authneeded VARCHAR2(80);
l_fname1     VARCHAR2(80);
l_fval1      VARCHAR2(80);
l_fname2     VARCHAR2(80);
l_fval2      VARCHAR2(80);
l_fname3     VARCHAR2(80);
l_fval3      VARCHAR2(80);
l_fname4     VARCHAR2(80);
l_fval4      VARCHAR2(80);
l_fname5     VARCHAR2(80);
l_fval5      VARCHAR2(80);
l_fname6     VARCHAR2(80);
l_fval6      VARCHAR2(80);
l_fname7     VARCHAR2(80);
l_fval7      VARCHAR2(80);
l_fname8     VARCHAR2(80);
l_fval8      VARCHAR2(80);
l_fname9     VARCHAR2(80);
l_fval9      VARCHAR2(80);
l_procedure  VARCHAR2(31) := 'check_app_id';

BEGIN

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

  BEGIN

  hr_sso_utl.pstore_get_app_info(
                             p_app_id,
                             l_app_name,  l_apptype,
                             l_appurl,    l_logout_url,
                             l_userfield, l_pwdfield, l_authneeded,
                             l_fname1,    l_fval1 ,
                             l_fname2,    l_fval2 ,
                             l_fname3,    l_fval3 ,
                             l_fname4,    l_fval4,
                             l_fname5,    l_fval5,
                             l_fname6,    l_fval6,
                             l_fname7,    l_fval7,
                             l_fname8,    l_fval8 ,
                             l_fname9,    l_fval9 );

  --
  -- If no exception raised then we assume app_id is valid
  --
  l_retval := true;

  EXCEPTION
  --
  WHEN OTHERS THEN
      l_retval := false;
  END;

IF l_retval THEN
  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'valid app_id');
  END IF;
ELSE
  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'invalid app_id');
  END IF;
END IF;


IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
  END IF;

RETURN(l_retval);

END check_app_id;

--=========================== get_app_id ================================
--
-- Description: Find the app_id of the external application
--
--
--  Input Parameters
--        p_app_code - Short code identifier for External Application
--        (from SSO_EXTERNAL_APPLICATIONS)
--
--
--  Output Parameters
--        l_app_id - app_id of target
--
--
-- ==========================================================================

--
FUNCTION get_app_id(p_app_code IN VARCHAR2) RETURN VARCHAR2 IS
--
l_app_id        VARCHAR2(80) := NULL;
l_procedure     VARCHAR2(31) := 'get_app_id';

cursor csr_get_app_id is
  SELECT external_application_id
  FROM   hr_ki_ext_applications
  WHERE  external_application_name = p_app_code;

BEGIN

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'p_app_code is ' || p_app_code);
END IF;

OPEN csr_get_app_id;
FETCH csr_get_app_id INTO l_app_id;
IF csr_get_app_id%NOTFOUND THEN
  CLOSE csr_get_app_id;
  displayError('INTERNAL ERROR: No data for code ' || p_app_code);
  RAISE e_extappexception;
END IF;
CLOSE csr_get_app_id;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'l_app_id is ' || NVL(l_app_id,'-null-'));
END IF;

IF NOT check_app_id(l_app_id) THEN
  displayError('INTERNAL ERROR (' || p_app_code ||
               ') No external application with id ' || l_app_id);
  RAISE e_extappexception;
END IF;

IF l_app_id IS NOT NULL THEN
  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'app_id is ' || l_app_id);
  END IF;
END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;


RETURN(l_app_id);

END get_app_id;

-- =========================== get_app_auth ================================
--
-- Description: Find the SSO username / pwd for a user
--
--  Input Parameters
--        p_app_id - app_id of target
--        p_user_name - Oracle Apps Username
--
--  Output Parameters
--        p_app_user - ext app username
--        p_app_pwd - ext app password
--
-- ==========================================================================

--
PROCEDURE get_app_auth( p_app_id     IN VARCHAR2,
                        p_user_name  IN VARCHAR2,
                        p_app_user   OUT NOCOPY VARCHAR2,
                        p_app_pwd    OUT NOCOPY VARCHAR2,
                        p_user_prefs OUT NOCOPY VARCHAR2) IS
--
l_fname1     VARCHAR2(80);
l_fval1      VARCHAR2(80);
l_fname2     VARCHAR2(80);
l_fval2      VARCHAR2(80);
l_fname3     VARCHAR2(80);
l_fval3      VARCHAR2(80);
l_fname4     VARCHAR2(80);
l_fval4      VARCHAR2(80);
l_fname5     VARCHAR2(80);
l_fval5      VARCHAR2(80);
l_fname6     VARCHAR2(80);
l_fval6      VARCHAR2(80);
l_fname7     VARCHAR2(80);
l_fval7      VARCHAR2(80);
l_fname8     VARCHAR2(80);
l_fval8      VARCHAR2(80);
l_fname9     VARCHAR2(80);
l_fval9      VARCHAR2(80);
l_user_prefs VARCHAR2(80);
l_procedure  VARCHAR2(31) := 'get_app_auth';

--
BEGIN

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'User Info for ' || p_user_name);
END IF;

BEGIN

  hr_sso_utl.PSTORE_GET_USERINFO(
    p_app_id,
    p_user_name,
    p_app_user,
    p_app_pwd,
    l_fname1, l_fval1,
    l_fname2, l_fval2,
    l_fname3, l_fval3,
    l_fname4, l_fval4,
    l_fname5, l_fval5,
    l_fname6, l_fval6,
    l_fname7, l_fval7,
    l_fname8, l_fval8,
    l_fname9, l_fval9,
    l_user_prefs);

  -- ??? Need an explicit name for this exception
  EXCEPTION
    WHEN OTHERS THEN
      p_app_user := NULL;
      p_app_pwd  := NULL;

END;

IF p_app_pwd IS NULL THEN
  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'No details for ' || p_user_name);
  END IF;
ELSE
  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'apps_user_name is ' || p_app_user);
  END IF;
END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;


END get_app_auth;

-- =========================== launch ================================
--
-- Description: The passed target will be:
--                  1. identify app_id
--                  2. SSO username / pwd for user found
--                     otherwise sysadmin ones used
--                  3. launch ext app
--
--
--  Input Parameters
--        p_app_code - Short code identifying External Application
--
--
--  Output Parameters
--        <none>
--
--
-- ==========================================================================

--
PROCEDURE launch(p_app_code IN VARCHAR2) IS
--

l_app_id     varchar2(80);
l_app_user   VARCHAR2(80) := NULL;
l_app_pwd    VARCHAR2(80);
l_user_name  VARCHAR2(100);
l_user_prefs VARCHAR2(100);
l_procedure  VARCHAR2(31) := 'launch';

--
BEGIN

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;
IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Target is ' || p_app_code);
END IF;

-- find and validate application id for app code
l_app_id := get_app_id(p_app_code);

-- find current Oracle Apps username.
l_user_name := hr_sso_utl.get_user();

-- get the current ext app user/pwd
get_app_auth(
    p_app_id     => l_app_id,
    p_user_name  => l_user_name,
    p_app_user   => l_app_user,
    p_app_pwd    => l_app_pwd,
    p_user_prefs => l_user_prefs);


-- If no credentials registered for user then copy the
-- 'site level' credentials from a fixed username

IF ( ( l_app_user IS NULL ) OR ( site_override ) ) THEN

  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'Using site level details');
  END IF;

  get_app_auth(
      p_app_id     => l_app_id,
      p_user_name  => g_site_user_name,
      p_app_user   => l_app_user,
      p_app_pwd    => l_app_pwd,
      p_user_prefs => l_user_prefs);

  -- We update password store for this user because of a limitation
  -- of fapp_login where the login dialog appears even if credentials
  -- are passed as parameters

  IF l_app_user IS NOT NULL THEN

    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Storing details for ' || l_user_name);
    END IF;

    hr_sso_utl.pstore_add_userinfo(
        p_app_id     => l_app_id,
        p_ssouser    => l_user_name,
        p_app_user   => l_app_user,
        p_app_pwd    => l_app_pwd ,
        p_user_prefs => l_user_prefs);
  ELSE

    -- If we reach this point then no password was held for either
    -- site level (SYSADMIN) or the current user. For now we'll allow
    -- the login to go ahead.

    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'No details found at site level');
    END IF;
  END IF;

END IF;

-- For now we'll 'borrow' the 'Open New Window' profile option to
-- decide whether to open a new browser window. Not clear how
-- useful this is. It looks like the native browser 'open in new window'
-- will work just as well.
--
-- The launch of external applications using Basic Authentication could
-- be made more seamless by opening a new window.
--
call_extapp(l_app_id,
            fnd_profile.value('HR_KPI_OPEN_NEW_WINDOW') = 'Y' );

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

EXCEPTION

  WHEN e_extappexception THEN
    NULL;

  WHEN OTHERS THEN

    displayError('LAUNCH_EXTAPP: ' || sqlerrm);

END launch;
--
-- Purpose
--
--  A PL/SQL function for error handling.
--
--
procedure generic_error(routine in varchar2,
                        errcode in number,
                        errmsg in varchar2) is
l_msg varchar2(2000);
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    fnd_message.raise_error;
end;

-- Purpose
--
--  A PL/SQL function that opens URL returned from servlet
--  in the browser.
--
--

PROCEDURE KI_LAUNCH(p_topic IN VARCHAR2
         ,p_provider in VARCHAR2) IS
--

l_procedure  VARCHAR2(31) := 'KI_LAUNCH';
l_topic     varchar2(30):=NULL;
l_provider   VARCHAR2(30) := NULL;
l_servlet_agent varchar2(200);
l_dbc varchar2(20);
l_hr_ext_servlet varchar2(200);
l_apps_servlet_agent varchar2(200);
l_url varchar2(400);
l_servlet varchar2(100);
l_icx_ki_ids varchar2(100):='&KICustomSessionId=Direct Link REQUEST:';
l_session_id number;
icx_id number;

Cursor C_Sel1 is
select topic_id  from hr_ki_topics where
topic_key=p_topic;

Cursor C_Sel2 is
select integration_id from hr_ki_integrations where
 integration_key =p_provider ;

--
BEGIN

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

Open C_Sel1;
   Fetch C_Sel1 Into l_topic;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The topic key is invalid therefore we must error
        --
        fnd_message.set_name('PER', 'PER_449104_EXT_APP_TPCI_INVL');
        fnd_message.set_token('TOPIC', p_topic);
        displayError(fnd_message.get());
        return;
      End If;
Close C_Sel1;

Open C_Sel2;
   Fetch C_Sel2 Into l_provider;
      If C_Sel2%notfound Then
        Close C_Sel2;
        --
        -- The provider_key is invalid therefore we must error
        --
        fnd_message.set_token('PROVIDER', p_provider);
        fnd_message.set_name('PER', 'PER_449105_EXT_APP_PRV_INVL');
        displayError(fnd_message.get());
        return;
      End If;
Close C_Sel2;

--Get dbc file
select fnd_web_config.database_id into l_dbc from dual;

--First get the value from HR_EXT_AGENT
select fnd_profile.value('HR_KPI_AGENT') into l_hr_ext_servlet
from dual;
select fnd_profile.value('HR_KPI_GENFWK_SERVLET') into l_servlet
from dual;

If l_hr_ext_servlet is null then
select fnd_profile.value('APPS_SERVLET_AGENT') into
l_apps_servlet_agent from dual;
l_hr_ext_servlet :=l_apps_servlet_agent;
end if;

--Add custom seesion id and icx session_id
l_icx_ki_ids := l_icx_ki_ids || to_char(sysdate,'hh:mi:ss')||': ';
select SESSION_ID into l_session_id from icx_sessions where
icx_sessions.login_id = to_number(fnd_profile.value('LOGIN_ID'));

l_icx_ki_ids := l_icx_ki_ids ||'&IcxSessionId='||icx_call.encrypt3(l_session_id);

--Construct the URL
l_url := l_hr_ext_servlet||l_servlet||'?type=INIT'|| '&' || 'uit=FRMFN'||
'&' || 'topic='||l_topic||'&'||'provider='||l_provider||
'&'|| 'dbc='||l_dbc||l_icx_ki_ids;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'l_url' || l_url);
END IF;


IF ( nvl(fnd_profile.value('HR_KPI_OPEN_NEW_WINDOW'), 'Y') = 'Y' ) THEN
  -- Open a new window. Go back to the previous window
  htp.script('window.open("' || l_url || '","newwindow");' ||
             'history.go(-1);',
             'javascript');
ELSE
  -- Possible performance concerns using this function with IE
  -- may be worth switching to using 'location.replace()'
  --
  owa_util.redirect_url(l_url);
END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

EXCEPTION

  WHEN OTHERS THEN

    IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING   (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                   MODULE    => g_module || '.' || l_procedure,
                   MESSAGE   => 'Error whilst launcing URL' ||
                                ' - ' || sqlerrm);
    END IF;

    generic_error( g_module || '.' || l_procedure ,
    sqlerrm,'Error Occured while lauching URL');


end;

--
-- Name
--  register
--
-- Parameters
--   p_app_code       IN   external app code
--   p_apptype        IN   application type
--   p_appurl         IN   URL for external application
--   p_logout_url     IN   URL for external application to logout
--   p_userfld        IN   name of user field
--   p_pwdfld         IN   name of password field
--   p_authused       IN   type of authentication used
--   p_fnameN         IN   additional names  (N=1..9)
--   p_fvalN          IN   additional values (N=1..9)
--
-- Purpose
--
--  A PL/SQL function that registers an external application.
--
--
PROCEDURE register (
            p_app_code       IN VARCHAR2,
            p_apptype        IN VARCHAR2,
            p_appurl         IN VARCHAR2,
            p_logout_url     IN VARCHAR2,
            p_userfld        IN VARCHAR2,
            p_pwdfld         IN VARCHAR2,
            p_authused       IN VARCHAR2,
            p_fname1         IN VARCHAR2 DEFAULT NULL,
            p_fval1          IN VARCHAR2 DEFAULT NULL,
            p_fname2         IN VARCHAR2 DEFAULT NULL,
            p_fval2          IN VARCHAR2 DEFAULT NULL,
            p_fname3         IN VARCHAR2 DEFAULT NULL,
            p_fval3          IN VARCHAR2 DEFAULT NULL,
            p_fname4         IN VARCHAR2 DEFAULT NULL,
            p_fval4          IN VARCHAR2 DEFAULT NULL,
            p_fname5         IN VARCHAR2 DEFAULT NULL,
            p_fval5          IN VARCHAR2 DEFAULT NULL,
            p_fname6         IN VARCHAR2 DEFAULT NULL,
            p_fval6          IN VARCHAR2 DEFAULT NULL,
            p_fname7         IN VARCHAR2 DEFAULT NULL,
            p_fval7          IN VARCHAR2 DEFAULT NULL,
            p_fname8         IN VARCHAR2 DEFAULT NULL,
            p_fval8          IN VARCHAR2 DEFAULT NULL,
            p_fname9         IN VARCHAR2 DEFAULT NULL,
            p_fval9          IN VARCHAR2 DEFAULT NULL) IS

l_app_id  NUMBER(15) := NULL;

l_tst_app_name    VARCHAR2(80);
l_tst_apptype     VARCHAR2(80);
l_tst_appurl      VARCHAR2(1000);
l_tst_logout_url  VARCHAR2(1000);
l_tst_userfield   VARCHAR2(80);
l_tst_pwdfield    VARCHAR2(80);
l_tst_authneeded  VARCHAR2(80);
l_tst_fname1      VARCHAR2(80);
l_tst_fval1       VARCHAR2(1000);
l_tst_fname2      VARCHAR2(80);
l_tst_fval2       VARCHAR2(1000);
l_tst_fname3      VARCHAR2(80);
l_tst_fval3       VARCHAR2(1000);
l_tst_fname4      VARCHAR2(80);
l_tst_fval4       VARCHAR2(1000);
l_tst_fname5      VARCHAR2(80);
l_tst_fval5       VARCHAR2(1000);
l_tst_fname6      VARCHAR2(80);
l_tst_fval6       VARCHAR2(1000);
l_tst_fname7      VARCHAR2(80);
l_tst_fval7       VARCHAR2(1000);
l_tst_fname8      VARCHAR2(80);
l_tst_fval8       VARCHAR2(1000);
l_tst_fname9      VARCHAR2(80);
l_tst_fval9       VARCHAR2(1000);

CURSOR csr_app_id IS
  SELECT external_application_id
  FROM   hr_ki_ext_applications
  WHERE  external_application_name = p_app_code;

BEGIN

-- see if the hr_ki_ext_applications
-- if no app_id, then this is a new external application
-- otherwise we are doing an update

hr_utility.trace('csr_app_id');

OPEN csr_app_id;
FETCH csr_app_id INTO l_app_id;
IF csr_app_id%NOTFOUND THEN
  l_app_id := NULL;
END IF;
CLOSE csr_app_id;

hr_utility.trace('l_app_id = ' || l_app_id);

-- check if l_app_id matches an existing application
-- note that we can only check if the l_app_id matches an
-- existing application id, not on the other details
--
-- if no match, reset l_app_id to null and add the app

IF l_app_id IS NOT NULL THEN

  BEGIN
  hr_sso_utl.PSTORE_GET_APP_INFO (
        P_APPID        => l_app_id,
        P_APP_NAME     => l_tst_app_name,
        P_APPTYPE      => l_tst_apptype,
        P_APPURL       => l_tst_appurl,
        P_LOGOUT_URL   => l_tst_logout_url,
        P_USERFIELD    => l_tst_userfield,
        P_PWDFIELD     => l_tst_pwdfield,
        P_AUTHNEEDED   => l_tst_authneeded,
        P_FNAME1       => l_tst_fname1,
        P_FVAL1        => l_tst_fval1,
        P_FNAME2       => l_tst_fname2,
        P_FVAL2        => l_tst_fval2,
        P_FNAME3       => l_tst_fname3,
        P_FVAL3        => l_tst_fval3,
        P_FNAME4       => l_tst_fname4,
        P_FVAL4        => l_tst_fval4,
        P_FNAME5       => l_tst_fname5,
        P_FVAL5        => l_tst_fval5,
        P_FNAME6       => l_tst_fname6,
        P_FVAL6        => l_tst_fval6,
        P_FNAME7       => l_tst_fname7,
        P_FVAL7        => l_tst_fval7,
        P_FNAME8       => l_tst_fname8,
        P_FVAL8        => l_tst_fval8,
        P_FNAME9       => l_tst_fname9,
        P_FVAL9        => l_tst_fval9);

  -- if exception raised, then invalid l_app_id / app_id
  -- assuming any exception indicates the app is invalid
  EXCEPTION
    WHEN others THEN
      l_app_id := NULL;
  END;
END IF;


IF l_app_id IS NULL THEN
  -- add the application
  hr_sso_utl.PSTORE_ADD_APPLICATION (
        p_appname        => p_app_code,
        p_apptype        => p_apptype,
        p_appurl         => p_appurl,
        p_logout_url     => p_logout_url,
        p_userfld        => p_userfld,
        p_pwdfld         => p_pwdfld,
        p_authused       => p_authused,
        p_fname1         => p_fname1,
        p_fval1          => p_fval1,
        p_fname2         => p_fname2,
        p_fval2          => p_fval2,
        p_fname3         => p_fname3,
        p_fval3          => p_fval3,
        p_fname4         => p_fname4,
        p_fval4          => p_fval4,
        p_fname5         => p_fname5,
        p_fval5          => p_fval5,
        p_fname6         => p_fname6,
        p_fval6          => p_fval6,
        p_fname7         => p_fname7,
        p_fval7          => p_fval7,
        p_fname8         => p_fname8,
        p_fval8          => p_fval8,
        p_fname9         => p_fname9,
        p_fval9          => p_fval9,
        p_appid          => l_app_id);

  -- insert record into hr_ki_ext_applications
  -- after deleting any existing entry
  DELETE FROM hr_ki_ext_applications
  WHERE external_application_name = p_app_code;

  INSERT INTO hr_ki_ext_applications
    (
    ext_application_id,
    external_application_name,
    external_application_id
    )
  SELECT
    hr_ki_ext_applications_s.nextval,
    p_app_code,
    l_app_id
  FROM dual;


ELSE
  -- otherwise update existing
  hr_sso_utl.PSTORE_MODIFY_APP_INFO (
        p_appid          => l_app_id,
        p_app_name       => p_app_code,
        p_apptype        => p_apptype,
        p_appurl         => p_appurl,
        p_logout_url     => p_logout_url,
        p_userfield      => p_userfld,
        p_pwdfield       => p_pwdfld,
        p_authneeded     => p_authused,
        p_fname1         => p_fname1,
        p_fval1          => p_fval1,
        p_fname2         => p_fname2,
        p_fval2          => p_fval2,
        p_fname3         => p_fname3,
        p_fval3          => p_fval3,
        p_fname4         => p_fname4,
        p_fval4          => p_fval4,
        p_fname5         => p_fname5,
        p_fval5          => p_fval5,
        p_fname6         => p_fname6,
        p_fval6          => p_fval6,
        p_fname7         => p_fname7,
        p_fval7          => p_fval7,
        p_fname8         => p_fname8,
        p_fval8          => p_fval8,
        p_fname9         => p_fname9,
        p_fval9          => p_fval9);

  -- update external_application_id in hr_ki_ext_applications
  -- with app_id
  UPDATE hr_ki_ext_applications
    SET external_application_id = l_app_id
    WHERE external_application_name = p_app_code;


END IF;


END register;



END hr_external_application;

/
