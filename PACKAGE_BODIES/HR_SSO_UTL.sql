--------------------------------------------------------
--  DDL for Package Body HR_SSO_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SSO_UTL" as
/* $Header: hrssoutl.pkb 120.2 2006/03/08 00:29:34 avarri noship $ */

-- Logging code data
g_module         CONSTANT VARCHAR2(80) :=
                                         'per.pl_sql.hr_sso_utl';

FUNCTION get_sso_schema
        RETURN VARCHAR2 IS

l_procedure VARCHAR2(31) := 'get_sso_schema';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
            'select ' ||
            'wwctx_api.get_sso_schema'
            || ' from dual'
  INTO l_retval;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_retval);

--
END get_sso_schema;
--


FUNCTION get_sso_query_path
        (
  p_url      IN VARCHAR2,
  p_schema   IN VARCHAR2 DEFAULT get_sso_schema
  )
        RETURN VARCHAR2 IS

l_procedure VARCHAR2(31) := 'get_sso_query_path';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
            'select wwctx_api.get_sso_query_path(:p_url,:p_schema) from dual'
  INTO l_retval using p_url,p_schema;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_retval);

--
END get_sso_query_path;
--

FUNCTION encrypt_ps_password
        (
  p_password IN VARCHAR2
  )
        RETURN VARCHAR2 IS

l_procedure VARCHAR2(31) := 'encrypt_ps_password';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
            'select wwsso_utl.encrypt_ps_password(:p_password) from dual'
  INTO l_retval using p_password;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_retval);

--
END encrypt_ps_password;
--

FUNCTION decrypt_ps_password
        (
  p_password IN VARCHAR2
  )
        RETURN VARCHAR2 IS

l_procedure VARCHAR2(31) := 'decrypt_ps_password';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
            'select wwsso_utl.decrypt_ps_password(:p_password) from dual'
  INTO l_retval using p_password;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_retval);

--
END decrypt_ps_password;
--

FUNCTION encrypt_ps_username
        (
  p_username IN VARCHAR2
  )
        RETURN VARCHAR2 IS

l_procedure VARCHAR2(31) := 'encrypt_ps_username';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
            'select wwsso_utl.encrypt_ps_username(:p_username) from dual'
  INTO l_retval using p_username;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_retval);

--
END encrypt_ps_username;
--

FUNCTION decrypt_ps_username
        (
  p_username IN VARCHAR2
  )
        RETURN VARCHAR2 IS

l_procedure VARCHAR2(31) := 'decrypt_ps_username';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
            'select wwsso_utl.decrypt_ps_username(:p_username) from dual'
  INTO l_retval using p_username;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_retval);

--
END decrypt_ps_username;
--

FUNCTION get_user
        RETURN VARCHAR2 IS

l_procedure VARCHAR2(31) := 'get_user';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
            'select ' ||
            'wwctx_api.get_user'
            || ' from dual'
  INTO l_retval;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_retval);

--
END get_user;
--

PROCEDURE pstore_add_application
  (
  P_APPNAME    IN  VARCHAR2,
  P_APPTYPE    IN  VARCHAR2,
  P_APPURL     IN  VARCHAR2,
  P_LOGOUT_URL IN  VARCHAR2,
  P_USERFLD    IN  VARCHAR2,
  P_PWDFLD     IN  VARCHAR2,
  P_AUTHUSED   IN  VARCHAR2,
  P_FNAME1     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL1      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME2     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL2      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME3     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL3      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME4     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL4      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME5     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL5      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME6     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL6      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME7     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL7      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME8     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL8      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME9     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL9      IN  VARCHAR2 DEFAULT NULL,
  P_APPID      OUT NOCOPY VARCHAR2
  ) IS

l_procedure VARCHAR2(31) := 'pstore_add_application';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
  'begin WWSSO_PSTORE_EX.pstore_add_application(' ||
  ':P_APPNAME, :P_APPTYPE, :P_APPURL, :P_LOGOUT_URL, ' ||
  ':P_USERFLD, :P_PWDFLD, :P_AUTHUSED, ' ||
  ':P_FNAME1, :P_FVAL1, :P_FNAME2, :P_FVAL2, ' ||
  ':P_FNAME3, :P_FVAL3, :P_FNAME4, :P_FVAL4, ' ||
  ':P_FNAME5, :P_FVAL5, :P_FNAME6, :P_FVAL6, ' ||
  ':P_FNAME7, :P_FVAL7, :P_FNAME8, :P_FVAL8, ' ||
  ':P_FNAME9, :P_FVAL9, ' ||
  ':P_APPID' ||
  '); end;'
  USING
    IN P_APPNAME, IN P_APPTYPE,
    IN P_APPURL, IN P_LOGOUT_URL,
    IN P_USERFLD, IN P_PWDFLD,
    IN P_AUTHUSED,
    IN P_FNAME1,  IN P_FVAL1,
    IN P_FNAME2,  IN P_FVAL2,
    IN P_FNAME3,  IN P_FVAL3,
    IN P_FNAME4,  IN P_FVAL4,
    IN P_FNAME5,  IN P_FVAL5,
    IN P_FNAME6,  IN P_FVAL6,
    IN P_FNAME7,  IN P_FVAL7,
    IN P_FNAME8,  IN P_FVAL8,
    IN P_FNAME9,  IN P_FVAL9,
    OUT P_APPID;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

--
END pstore_add_application;
--

PROCEDURE pstore_modify_app_info
  (
  P_APPID      IN  VARCHAR2,
  P_APP_NAME   IN  VARCHAR2,
  P_APPTYPE    IN  VARCHAR2,
  P_APPURL     IN  VARCHAR2,
  P_LOGOUT_URL IN  VARCHAR2,
  P_USERFIELD  IN  VARCHAR2,
  P_PWDFIELD   IN  VARCHAR2,
  P_AUTHNEEDED IN  VARCHAR2,
  P_FNAME1     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL1      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME2     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL2      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME3     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL3      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME4     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL4      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME5     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL5      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME6     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL6      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME7     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL7      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME8     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL8      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME9     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL9      IN  VARCHAR2 DEFAULT NULL
  ) IS

l_procedure VARCHAR2(31) := 'pstore_modify_app_info';
l_retval VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
  'begin WWSSO_PSTORE_EX.pstore_modify_app_info(' ||
  ':P_APPID, :P_APP_NAME, :P_APPTYPE, :P_APPURL, :P_LOGOUT_URL, ' ||
  ':P_USERFIELD, :P_PWDFIELD, :P_AUTHNEEDED, ' ||
  ':P_FNAME1, :P_FVAL1, :P_FNAME2, :P_FVAL2, ' ||
  ':P_FNAME3, :P_FVAL3, :P_FNAME4, :P_FVAL4, ' ||
  ':P_FNAME5, :P_FVAL5, :P_FNAME6, :P_FVAL6, ' ||
  ':P_FNAME7, :P_FVAL7, :P_FNAME8, :P_FVAL8, ' ||
  ':P_FNAME9, :P_FVAL9 ' ||
  '); end;'
  USING
    IN P_APPID, IN P_APP_NAME,
    IN P_APPTYPE, IN P_APPURL,
    IN P_LOGOUT_URL, IN P_USERFIELD,
    IN P_PWDFIELD, IN P_AUTHNEEDED,
    IN P_FNAME1,  IN P_FVAL1,
    IN P_FNAME2,  IN P_FVAL2,
    IN P_FNAME3,  IN P_FVAL3,
    IN P_FNAME4,  IN P_FVAL4,
    IN P_FNAME5,  IN P_FVAL5,
    IN P_FNAME6,  IN P_FVAL6,
    IN P_FNAME7,  IN P_FVAL7,
    IN P_FNAME8,  IN P_FVAL8,
    IN P_FNAME9,  IN P_FVAL9;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

--
END pstore_modify_app_info;
--

PROCEDURE pstore_get_app_info
  (
  P_APPID      IN   VARCHAR2,
  P_APP_NAME   OUT NOCOPY VARCHAR2,
  P_APPTYPE    OUT NOCOPY VARCHAR2,
  P_APPURL     OUT NOCOPY VARCHAR2,
  P_LOGOUT_URL OUT NOCOPY VARCHAR2,
  P_USERFIELD  OUT NOCOPY VARCHAR2,
  P_PWDFIELD   OUT NOCOPY VARCHAR2,
  P_AUTHNEEDED OUT NOCOPY VARCHAR2,
  P_FNAME1     OUT NOCOPY VARCHAR2,
  P_FVAL1      OUT NOCOPY VARCHAR2,
  P_FNAME2     OUT NOCOPY VARCHAR2,
  P_FVAL2      OUT NOCOPY VARCHAR2,
  P_FNAME3     OUT NOCOPY VARCHAR2,
  P_FVAL3      OUT NOCOPY VARCHAR2,
  P_FNAME4     OUT NOCOPY VARCHAR2,
  P_FVAL4      OUT NOCOPY VARCHAR2,
  P_FNAME5     OUT NOCOPY VARCHAR2,
  P_FVAL5      OUT NOCOPY VARCHAR2,
  P_FNAME6     OUT NOCOPY VARCHAR2,
  P_FVAL6      OUT NOCOPY VARCHAR2,
  P_FNAME7     OUT NOCOPY VARCHAR2,
  P_FVAL7      OUT NOCOPY VARCHAR2,
  P_FNAME8     OUT NOCOPY VARCHAR2,
  P_FVAL8      OUT NOCOPY VARCHAR2,
  P_FNAME9     OUT NOCOPY VARCHAR2,
  P_FVAL9      OUT NOCOPY VARCHAR2
  ) IS

l_procedure VARCHAR2(31) := 'pstore_get_app_info';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
  'begin WWSSO_PSTORE_EX.pstore_get_app_info(' ||
  ':P_APPID, :P_APP_NAME, :P_APPTYPE, :P_APPURL, :P_LOGOUT_URL, ' ||
  ':P_USERFIELD, :P_PWDFIELD, :P_AUTHNEEDED, ' ||
  ':P_FNAME1, :P_FVAL1, :P_FNAME2, :P_FVAL2, ' ||
  ':P_FNAME3, :P_FVAL3, :P_FNAME4, :P_FVAL4, ' ||
  ':P_FNAME5, :P_FVAL5, :P_FNAME6, :P_FVAL6, ' ||
  ':P_FNAME7, :P_FVAL7, :P_FNAME8, :P_FVAL8, ' ||
  ':P_FNAME9, :P_FVAL9 ' ||
  '); end;'
  USING
    IN P_APPID, OUT P_APP_NAME,
    OUT P_APPTYPE, OUT P_APPURL,
    OUT P_LOGOUT_URL, OUT P_USERFIELD,
    OUT P_PWDFIELD, OUT P_AUTHNEEDED,
    OUT P_FNAME1,  OUT P_FVAL1,
    OUT P_FNAME2,  OUT P_FVAL2,
    OUT P_FNAME3,  OUT P_FVAL3,
    OUT P_FNAME4,  OUT P_FVAL4,
    OUT P_FNAME5,  OUT P_FVAL5,
    OUT P_FNAME6,  OUT P_FVAL6,
    OUT P_FNAME7,  OUT P_FVAL7,
    OUT P_FNAME8,  OUT P_FVAL8,
    OUT P_FNAME9,  OUT P_FVAL9;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

--
END pstore_get_app_info;
--

PROCEDURE pstore_add_userinfo
  (
  P_APP_ID     IN  VARCHAR2,
  P_SSOUSER    IN  VARCHAR2,
  P_APP_USER   IN  VARCHAR2,
  P_APP_PWD    IN  VARCHAR2,
  P_FNAME1     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL1      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME2     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL2      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME3     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL3      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME4     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL4      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME5     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL5      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME6     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL6      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME7     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL7      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME8     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL8      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME9     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL9      IN  VARCHAR2 DEFAULT NULL,
  P_USER_PREFS IN  VARCHAR2
  ) IS

l_procedure VARCHAR2(31) := 'pstore_add_userinfo';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
    'declare l_usertype sso_user_type;'||
    'l_err number;'||
    'begin '||
     'wwsso_ls_private.get_default_user_config(l_usertype);'||
     'l_usertype.ssousername := :1;'||
     'l_usertype.ssorole := :2;'||
     'wwsso_ls_private.ls_create_user(l_usertype, l_err);'||
     ' commit; '||
     ' exception when wwsso_ls_private.dup_username_exception '||
     ' then null; '||
     ' when others then null;'||
    'end;'
    using
    IN P_SSOUSER, IN 'USER';

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                  MODULE    => l_module,
                  MESSAGE   => 'After config done ');
END IF;


EXECUTE IMMEDIATE
  'begin WWSSO_PSTORE_EX.pstore_add_userinfo(' ||
  ':P_APP_ID, :P_SSOUSER, :P_APP_USER, :P_APP_PWD, ' ||
  ':P_FNAME1, :P_FVAL1, :P_FNAME2, :P_FVAL2, ' ||
  ':P_FNAME3, :P_FVAL3, :P_FNAME4, :P_FVAL4, ' ||
  ':P_FNAME5, :P_FVAL5, :P_FNAME6, :P_FVAL6, ' ||
  ':P_FNAME7, :P_FVAL7, :P_FNAME8, :P_FVAL8, ' ||
  ':P_FNAME9, :P_FVAL9, ' ||
  ':P_USER_PREFS' ||
  '); end;'
  USING
    IN P_APP_ID, IN P_SSOUSER,
    IN P_APP_USER, IN P_APP_PWD,
    IN P_FNAME1,  IN P_FVAL1,
    IN P_FNAME2,  IN P_FVAL2,
    IN P_FNAME3,  IN P_FVAL3,
    IN P_FNAME4,  IN P_FVAL4,
    IN P_FNAME5,  IN P_FVAL5,
    IN P_FNAME6,  IN P_FVAL6,
    IN P_FNAME7,  IN P_FVAL7,
    IN P_FNAME8,  IN P_FVAL8,
    IN P_FNAME9,  IN P_FVAL9,
    IN P_USER_PREFS;


IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

--
END pstore_add_userinfo;
--

PROCEDURE pstore_modify_userinfo
  (
  P_APP_ID     IN  VARCHAR2,
  P_SSOUSER    IN  VARCHAR2,
  P_APP_USER   IN  VARCHAR2,
  P_APP_PWD    IN  VARCHAR2,
  P_FNAME1     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL1      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME2     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL2      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME3     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL3      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME4     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL4      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME5     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL5      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME6     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL6      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME7     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL7      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME8     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL8      IN  VARCHAR2 DEFAULT NULL,
  P_FNAME9     IN  VARCHAR2 DEFAULT NULL,
  P_FVAL9      IN  VARCHAR2 DEFAULT NULL,
  P_USER_PREFS IN  VARCHAR2
  ) IS

l_procedure VARCHAR2(31) := 'pstore_modify_userinfo';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;

--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
  'begin WWSSO_PSTORE_EX.pstore_modify_userinfo(' ||
  ':P_APP_ID, :P_SSOUSER, :P_APP_USER, :P_APP_PWD, ' ||
  ':P_FNAME1, :P_FVAL1, :P_FNAME2, :P_FVAL2, ' ||
  ':P_FNAME3, :P_FVAL3, :P_FNAME4, :P_FVAL4, ' ||
  ':P_FNAME5, :P_FVAL5, :P_FNAME6, :P_FVAL6, ' ||
  ':P_FNAME7, :P_FVAL7, :P_FNAME8, :P_FVAL8, ' ||
  ':P_FNAME9, :P_FVAL9, ' ||
  ':P_USER_PREFS' ||
  '); end;'
  USING
    IN P_APP_ID, IN P_SSOUSER,
    IN P_APP_USER, IN P_APP_PWD,
    IN P_FNAME1,  IN P_FVAL1,
    IN P_FNAME2,  IN P_FVAL2,
    IN P_FNAME3,  IN P_FVAL3,
    IN P_FNAME4,  IN P_FVAL4,
    IN P_FNAME5,  IN P_FVAL5,
    IN P_FNAME6,  IN P_FVAL6,
    IN P_FNAME7,  IN P_FVAL7,
    IN P_FNAME8,  IN P_FVAL8,
    IN P_FNAME9,  IN P_FVAL9,
    IN P_USER_PREFS;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

--
END pstore_modify_userinfo;
--

PROCEDURE pstore_get_userinfo
  (
  P_APP_ID     IN  VARCHAR2,
  P_SSOUSER    IN  VARCHAR2,
  P_APP_USER   OUT NOCOPY VARCHAR2,
  P_APP_PWD    OUT NOCOPY VARCHAR2,
  P_FNAME1     OUT NOCOPY VARCHAR2,
  P_FVAL1      OUT NOCOPY VARCHAR2,
  P_FNAME2     OUT NOCOPY VARCHAR2,
  P_FVAL2      OUT NOCOPY VARCHAR2,
  P_FNAME3     OUT NOCOPY VARCHAR2,
  P_FVAL3      OUT NOCOPY VARCHAR2,
  P_FNAME4     OUT NOCOPY VARCHAR2,
  P_FVAL4      OUT NOCOPY VARCHAR2,
  P_FNAME5     OUT NOCOPY VARCHAR2,
  P_FVAL5      OUT NOCOPY VARCHAR2,
  P_FNAME6     OUT NOCOPY VARCHAR2,
  P_FVAL6      OUT NOCOPY VARCHAR2,
  P_FNAME7     OUT NOCOPY VARCHAR2,
  P_FVAL7      OUT NOCOPY VARCHAR2,
  P_FNAME8     OUT NOCOPY VARCHAR2,
  P_FVAL8      OUT NOCOPY VARCHAR2,
  P_FNAME9     OUT NOCOPY VARCHAR2,
  P_FVAL9      OUT NOCOPY VARCHAR2,
  P_USER_PREFS OUT NOCOPY VARCHAR2
   ) IS

l_procedure VARCHAR2(31) := 'pstore_get_userinfo';
l_retval    VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;
--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
  'begin WWSSO_PSTORE_EX.pstore_get_userinfo(' ||
  ':P_APP_ID, :P_SSOUSER, :P_APP_USER, :P_APP_PWD, ' ||
  ':P_FNAME1, :P_FVAL1, :P_FNAME2, :P_FVAL2, ' ||
  ':P_FNAME3, :P_FVAL3, :P_FNAME4, :P_FVAL4, ' ||
  ':P_FNAME5, :P_FVAL5, :P_FNAME6, :P_FVAL6, ' ||
  ':P_FNAME7, :P_FVAL7, :P_FNAME8, :P_FVAL8, ' ||
  ':P_FNAME9, :P_FVAL9, ' ||
  ':P_USER_PREFS' ||
  '); end;'
  USING
    IN P_APP_ID, IN P_SSOUSER,
    OUT P_APP_USER, OUT P_APP_PWD,
    OUT P_FNAME1,  OUT P_FVAL1,
    OUT P_FNAME2,  OUT P_FVAL2,
    OUT P_FNAME3,  OUT P_FVAL3,
    OUT P_FNAME4,  OUT P_FVAL4,
    OUT P_FNAME5,  OUT P_FVAL5,
    OUT P_FNAME6,  OUT P_FVAL6,
    OUT P_FNAME7,  OUT P_FVAL7,
    OUT P_FNAME8,  OUT P_FVAL8,
    OUT P_FNAME9,  OUT P_FVAL9,
    OUT P_USER_PREFS;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;

--
END pstore_get_userinfo;
--

PROCEDURE delete_application(
  p_appid IN  VARCHAR2
, p_error OUT NOCOPY NUMBER
)
IS

l_procedure VARCHAR2(31) := 'delete_application';
l_error     VARCHAR2(2000);
l_module    VARCHAR2(80) := g_module || '.' || l_procedure;

--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Entering ' || l_procedure);
END IF;

EXECUTE IMMEDIATE
  'begin WWSSO_PSTORE_EX.delete_application(' ||
  ':p_appid, :p_error ' ||
  '); end;'
  USING
    IN p_appid,
    OUT p_error;


IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                  MODULE    => l_module,
                  MESSAGE   => 'Exiting ' || l_procedure);
END IF;


--
END delete_application;

END hr_sso_utl;


/
