--------------------------------------------------------
--  DDL for Package Body HR_AUTH_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AUTH_INT" as
/* $Header: hrathint.pkb 120.0 2005/05/30 22:53:58 appldev noship $ */


-- Logging code data
g_module         CONSTANT VARCHAR2(80) :=
                                         'per.pl_sql.hr_auth_int';

FUNCTION get_sso_user
	(
	p_user_id IN NUMBER
  )
	RETURN VARCHAR2 IS

l_procedure VARCHAR2(31) := 'get_sso_user';
l_user	VARCHAR2(60) := NULL;

CURSOR csr_user IS
SELECT user_name
FROM fnd_user
WHERE user_id = p_user_id;

--
BEGIN
--
IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;


OPEN csr_user;
FETCH csr_user INTO l_user;
CLOSE csr_user;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'sso user is ' || l_user);
END IF;

IF l_user IS NULL THEN
  IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_ERROR,
		         MODULE    => g_module || '.' || l_procedure,
			 MESSAGE   => 'sso user is not found for user_id ' ||
                              p_user_id);
  END IF;
END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;
RETURN(l_user);

--
END get_sso_user;
--



FUNCTION get_country
	(
	p_person_id IN NUMBER
  )
	RETURN VARCHAR2 IS

CURSOR csr_country IS
SELECT bg.legislation_code
FROM per_all_people_f ppl,
     per_business_groups bg
WHERE ppl.person_id = p_person_id
  AND SYSDATE BETWEEN ppl.effective_start_date
                  AND ppl.effective_end_date
  AND ppl.business_group_id = bg.business_group_id;

l_procedure VARCHAR2(31) := 'get_country';
l_country	VARCHAR2(60) := NULL;

--
BEGIN
--
IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

OPEN csr_country;
FETCH csr_country INTO l_country;
CLOSE csr_country;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'country is ' || l_country);
END IF;

IF l_country IS NULL THEN
  IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'No country associated with person_id ' ||
                               p_person_id);
  END IF;
END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_country);

--
END get_country;
--


FUNCTION get_url_from_profile
	(
	p_country IN VARCHAR2
  )
	RETURN VARCHAR2 IS

l_procedure VARCHAR2(31) := 'get_url_from_profile';
l_url VARCHAR2(2000);

--
BEGIN
--
IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

l_url := fnd_profile.value('HR_AUTHORIA_URL_' || p_country);

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'url is ' || l_url);
END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_url);

--
END get_url_from_profile;
--

PROCEDURE update_sso_url
	(
	p_url IN VARCHAR2,
	p_app_id IN VARCHAR2
  ) IS

l_procedure VARCHAR2(31) := 'update_sso_url';
l_url VARCHAR2(2000);
l_APP_NAME   varchar2(80);
l_APPTYPE    varchar2(80);
l_APPURL     varchar2(80);
l_LOGOUT_URL varchar2(80);
l_USERFIELD  varchar2(80);
l_PWDFIELD   varchar2(80);
l_AUTHNEEDED varchar2(80);
l_APP_USER   varchar2(80);
l_APP_PWD    varchar2(80);
l_FNAME1     varchar2(80) := NULL;
l_FVAL1      varchar2(80) := NULL;
l_FNAME2     varchar2(80) := NULL;
l_FVAL2      varchar2(80) := NULL;
l_FNAME3     varchar2(80) := NULL;
l_FVAL3      varchar2(80) := NULL;
l_FNAME4     varchar2(80) := NULL;
l_FVAL4      varchar2(80) := NULL;
l_FNAME5     varchar2(80) := NULL;
l_FVAL5      varchar2(80) := NULL;
l_FNAME6     varchar2(80) := NULL;
l_FVAL6      varchar2(80) := NULL;
l_FNAME7     varchar2(80) := NULL;
l_FVAL7      varchar2(80) := NULL;
l_FNAME8     varchar2(80) := NULL;
l_FVAL8      varchar2(80) := NULL;
l_FNAME9     varchar2(80) := NULL;
l_FVAL9      varchar2(80) := NULL;

--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

-- get existing details

hr_sso_utl.PSTORE_GET_APP_INFO(
	p_APP_ID,
	l_APP_NAME,
	l_APPTYPE,
	l_APPURL,
	l_LOGOUT_URL,
	l_USERFIELD,
	l_PWDFIELD,
	l_AUTHNEEDED,
	l_FNAME1,	l_FVAL1,
	l_FNAME2,	l_FVAL2,
	l_FNAME3,	l_FVAL3,
	l_FNAME4,	l_FVAL4,
	l_FNAME5,	l_FVAL5,
	l_FNAME6,	l_FVAL6,
	l_FNAME7,	l_FVAL7,
	l_FNAME8,	l_FVAL8,
	l_FNAME9,	l_FVAL9);

-- update with new info

hr_sso_utl.PSTORE_MODIFY_APP_INFO(
	p_APP_ID,
	l_APP_NAME,
	l_APPTYPE,
	p_url,
	l_LOGOUT_URL,
	l_USERFIELD,
	l_PWDFIELD,
	l_AUTHNEEDED,
	l_FNAME1,	l_FVAL1,
	l_FNAME2,	l_FVAL2,
	l_FNAME3,	l_FVAL3,
	l_FNAME4,	l_FVAL4,
	l_FNAME5,	l_FVAL5,
	l_FNAME6,	l_FVAL6,
	l_FNAME7,	l_FVAL7,
	l_FNAME8,	l_FVAL8,
	l_FNAME9,	l_FVAL9);

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

--
END update_sso_url;
--



FUNCTION get_redirect_url
	(
	p_sso_user IN VARCHAR2,
	p_person_id IN NUMBER,
	p_page IN VARCHAR2,
  p_primary_obj IN VARCHAR2
	)
	RETURN VARCHAR2 IS
--
l_procedure VARCHAR2(31) := 'get_redirect_url';
l_url        VARCHAR2(2000);
l_app_id     varchar2(80) := NULL;
l_APP_USER   varchar2(80);
l_APP_PWD    varchar2(80);
l_FNAME1     varchar2(80) := NULL;
l_FVAL1      varchar2(80) := NULL;
l_FNAME2     varchar2(80) := NULL;
l_FVAL2      varchar2(80) := NULL;
l_FNAME3     varchar2(80) := NULL;
l_FVAL3      varchar2(80) := NULL;
l_FNAME4     varchar2(80) := NULL;
l_FVAL4      varchar2(80) := NULL;
l_FNAME5     varchar2(80) := NULL;
l_FVAL5      varchar2(80) := NULL;
l_FNAME6     varchar2(80) := NULL;
l_FVAL6      varchar2(80) := NULL;
l_FNAME7     varchar2(80) := NULL;
l_FVAL7      varchar2(80) := NULL;
l_FNAME8     varchar2(80) := NULL;
l_FVAL8      varchar2(80) := NULL;
l_FNAME9     varchar2(80) := NULL;
l_FVAL9      varchar2(80) := NULL;
l_USER_PREFS varchar2(80) := NULL;
l_password   varchar2(80) := NULL;
l_country    varchar2(30);
l_error      varchar2(2000);

--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

-- find the external app_id
l_country := get_country(p_person_id);
IF l_country IS NULL THEN
  -- qqq
  -- really should be a message
  l_error := 'Unable to identify a country associated with the person.';
END IF;

IF l_error IS NULL THEN

  BEGIN
    l_app_id := hr_external_application.get_app_id('Authoria-' ||
                  l_country);

    EXCEPTION
      WHEN OTHERS THEN
	IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                       MODULE    => g_module || '.' || l_procedure,
                       MESSAGE   => 'Unable to determine SSO external ' ||
                                    'application - ' || sqlerrm);
	END IF;
  END;

  IF l_app_id IS NULL THEN
    -- qqq
    -- really should be a message
    l_error := 'Unable to determine the external application details ' ||
               'via SSO for the country ' || NVL(l_country, 'null') || '.';
  END IF;
END IF;


IF l_error IS NULL THEN

  -- set up the URL for the country
  update_sso_url(get_url_from_profile(l_country),
                 l_app_id );

  BEGIN

    -- get the existing (if any) user info for this app

    hr_sso_utl.PSTORE_GET_USERINFO(
    	l_APP_ID,
	    p_sso_user,
	    l_APP_USER,
	    l_APP_PWD,
	    l_FNAME1,	l_FVAL1,
	    l_FNAME2,	l_FVAL2,
	    l_FNAME3,	l_FVAL3,
	    l_FNAME4,	l_FVAL4,
	    l_FNAME5,	l_FVAL5,
	    l_FNAME6,	l_FVAL6,
	    l_FNAME7,	l_FVAL7,
    	l_FNAME8,	l_FVAL8,
	    l_FNAME9,	l_FVAL9,
	    l_USER_PREFS);

    EXCEPTION
      WHEN OTHERS THEN
	IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                       MODULE    => g_module || '.' || l_procedure,
                       MESSAGE   => 'No user found, using defaults');
	END IF;
  END;

  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'APP_USER is ' || l_APP_USER);
  END IF;

  -- set SSO details
  IF (l_APP_PWD IS NULL) THEN

    -- create user for the first time
    -- can not store a null password in the SSO
    -- so user can not already exist
    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                   MODULE    => g_module || '.' || l_procedure,
                   MESSAGE   => 'creating new user');
    END IF;

    -- generate a password according to the current method
    l_password := get_password(p_person_id);

    BEGIN
      hr_sso_utl.pstore_add_userinfo(
	      p_app_id     => l_APP_ID,
        p_ssouser    => p_SSO_USER,
        p_app_user   => p_person_id,
        p_app_pwd    => l_password,
        p_fname1     => 'command',
        p_fval1      => 'showpage',
        p_fname2     => 'page',
        p_fval2      => p_page,
        p_fname3     => 'primary_obj',
        p_fval3      => p_primary_obj,
        p_fname4     => l_FNAME4,
        p_fval4      => l_FVAL4,
        p_fname5     => l_FNAME5,
        p_fval5      => l_FVAL5,
        p_fname6     => l_FNAME6,
        p_fval6      => l_FVAL6,
        p_fname7     => l_FNAME7,
        p_fval7      => l_FVAL7,
        p_fname8     => l_FNAME8,
        p_fval8      => l_FVAL8,
        p_fname9     => l_FNAME9,
        p_fval9      => l_FVAL9,
        p_user_prefs => l_USER_PREFS);

      EXCEPTION
        WHEN OTHERS THEN
          IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                         MODULE    => g_module || '.' || l_procedure,
                         MESSAGE   => 'new user error - ' || sqlerrm);
	  END IF;
          l_error := 'Error creating new user record in SSO - ' ||
                     sqlerrm;
    END;
  ELSE
    -- updating current user

    -- generate a password according to the current method
    l_password := get_password(p_person_id);

    BEGIN
      hr_sso_utl.pstore_modify_userinfo(
	      p_app_id     => l_APP_ID,
        p_ssouser    => p_SSO_USER,
        p_app_user   => p_person_id,
        p_app_pwd    => l_password,
        p_fname1     => 'command',
        p_fval1      => 'showpage',
        p_fname2     => 'page',
        p_fval2      => p_page,
        p_fname3     => 'primary_obj',
        p_fval3      => p_primary_obj,
        p_fname4     => l_FNAME4,
        p_fval4      => l_FVAL4,
        p_fname5     => l_FNAME5,
        p_fval5      => l_FVAL5,
        p_fname6     => l_FNAME6,
        p_fval6      => l_FVAL6,
        p_fname7     => l_FNAME7,
        p_fval7      => l_FVAL7,
        p_fname8     => l_FNAME8,
        p_fval8      => l_FVAL8,
        p_fname9     => l_FNAME9,
        p_fval9      => l_FVAL9,
        p_user_prefs => l_USER_PREFS);
      EXCEPTION
        WHEN OTHERS THEN
	  IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                         MODULE    => g_module || '.' || l_procedure,
                         MESSAGE   => 'existing user error - ' || sqlerrm);
	  END IF;
          l_error := 'Error modifying existing user record in SSO - ' ||
                     sqlerrm;
    END;
  END IF;

  COMMIT;

  -- build url
  l_url :=
hr_sso_utl.get_sso_query_path('wwsso_app_admin.fapp_process_login')
               || '?p_app_id=' || l_app_id;

END IF;

-- display errors
IF l_error IS NOT NULL THEN
  l_url := 'ERROR: ' || l_error;
END IF;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'url is ' || l_url);
END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;


RETURN(l_url);

EXCEPTION
  WHEN OTHERS THEN
    IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                   MODULE    => g_module || '.' || l_procedure,
                   MESSAGE   => 'Error whilst determining redirection URL' ||
                                ' - ' || sqlerrm);
    END IF;


--
END get_redirect_url;
--

FUNCTION get_url
	(
	p_provider IN VARCHAR2,
	p_user_id IN NUMBER,
	p_person_id IN NUMBER,
	p_page IN VARCHAR2,
  p_primary_obj IN VARCHAR2
  )
	RETURN VARCHAR2 IS
--
pragma autonomous_transaction;
--

l_procedure VARCHAR2(31) := 'get_url';
l_sso_user	VARCHAR2(60) := NULL;
l_url       VARCHAR2(2000);
l_error     VARCHAR2(2000) := NULL;

--
BEGIN
--
IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'provider is ' || p_provider);
END IF;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'page is ' || p_page);
END IF;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'user_id is ' || p_user_id);
END IF;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'page is ' || p_page);
END IF;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'primary_obj is ' || p_primary_obj);
END IF;


-- get sso user
l_sso_user := get_sso_user(p_user_id);
IF l_sso_user IS NULL THEN
  l_error := 'Unable to determine the SSO user for the current user.';
END IF;

IF l_error IS NULL THEN
  -- get redirection URL (or error text)
  -- after adding 'set,,' to primary obj string
  l_url := get_redirect_url(l_sso_user,
                            p_person_id,
                            p_page,
                            'set,,' || p_primary_obj);

  IF SUBSTR(l_url,5) = 'ERROR' THEN
    l_error := l_url;
  END IF;

END IF;

IF l_error IS NOT NULL THEN
  l_url := 'ERROR : APPS-47368 : ' || l_error ||
           ' Examine FND logging information for more details.';
END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_url);

--
END get_url;
--

FUNCTION get_url
	(
	p_provider IN VARCHAR2,
	p_user_id IN VARCHAR2,
	p_person_id IN VARCHAR2,
	p_page IN VARCHAR2,
  p_primary_obj IN VARCHAR2
  )
	RETURN VARCHAR2 IS
--
pragma autonomous_transaction;
--

l_procedure VARCHAR2(31) := 'get_url';
l_url       VARCHAR2(2000);
l_person_id NUMBER(15);
l_user_id NUMBER(15);

--
BEGIN
--
IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

-- need to decrypt encrypted person_id
l_person_id := hr_sso_utl.decrypt_ps_username(p_person_id);

-- need to decrypt encrypted user_id
l_user_id := hr_sso_utl.decrypt_ps_username(p_user_id);

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'decrypted person_id is ' || l_person_id);
END IF;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'decrypted user_id is ' || l_user_id);
END IF;

-- now call main code

l_url := get_url(p_provider,
                 l_user_id,
                 l_person_id,
                 p_page,
                 p_primary_obj);

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_url);

--
END get_url;
--


FUNCTION get_password
	(
	p_person_id IN NUMBER
  )
	RETURN VARCHAR2 IS

l_procedure VARCHAR2(31) := 'get_password';
l_password	VARCHAR2(60);


--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

-- generate the password from the person_id passed
-- encrypted as a password
-- using the first 8 characters only - SSO limitation

l_password := substrb(icx_call.encrypt3(p_person_id),1,8);

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_password);

--
END get_password;
--


FUNCTION get_page
  (
  p_plip_id IN NUMBER,
  p_pl_id IN NUMBER,
  p_ler_id IN NUMBER
  )
  RETURN VARCHAR2 IS

--

l_procedure     VARCHAR2(31) := 'get_page';
l_target_page   VARCHAR2(2000) := NULL;
l_open_flag     VARCHAR2(1) := 'N';

CURSOR csr_ler IS
SELECT 'Y'
FROM ben_ler_f
WHERE sysdate BETWEEN effective_start_date
          AND effective_end_date
  AND ler_id = p_ler_id
  AND typ_cd = 'SCHEDDO';

CURSOR csr_page IS
SELECT target_page
FROM hr_authoria_mappings
WHERE pl_id = p_pl_id
  AND NVL(plip_id,-924926578) = NVL(p_plip_id,-924926578)
  AND open_enrollment_flag = l_open_flag;

--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

-- Find the Life event type
OPEN csr_ler;
FETCH csr_ler INTO l_open_flag;
IF csr_ler%NOTFOUND THEN
  l_open_flag := 'N';
END IF;
CLOSE csr_ler;

-- now see if we have a match
OPEN csr_page;
FETCH csr_page INTO l_target_page;
CLOSE csr_page;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'target page is ' || l_target_page);
END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_target_page);

--
END get_page;
--

FUNCTION get_anchor_tag_ss
  (
  p_pl_id in number,
  p_person_id in number,
  p_plan_name in varchar2,
  p_ler_id in number,
  p_plip_id in number default null,
  p_plan_url in varchar2 default null,
  p_primary_obj_context in varchar2 default null
  )
  RETURN varchar2 IS

--

l_procedure  VARCHAR2(31) := 'get_anchor_tag_ss';
l_url        VARCHAR2(2000);
l_anchor_tag VARCHAR2(2500);

--
BEGIN
--
IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'Entering ' || l_procedure);
END IF;

  l_url := get_url_ss(p_pl_id               => p_pl_id,
                      p_person_id           => p_person_id,
                      p_plan_name           => p_plan_name,
                      p_ler_id              => p_ler_id,
                      p_plip_id             => p_plip_id,
                      p_plan_url            => p_plan_url,
                      p_primary_obj_context => p_primary_obj_context);

  IF l_url is not null THEN
    l_anchor_tag := '<a href="'||l_url||'" target="_blank">'||p_plan_name||'</a>';
  ELSE
    l_anchor_tag := p_plan_name;
  END IF;

  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'anchor tag is ' || l_anchor_tag);
  END IF;

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'Exiting ' || l_procedure);
  END IF;

  RETURN(l_anchor_tag);

--
EXCEPTION
--
  WHEN others THEN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                   MODULE    => g_module || '.' || l_procedure,
                   MESSAGE   => 'Exiting with Exception' || l_procedure);
    END IF;
    RETURN p_plan_name;
--
END get_anchor_tag_ss;
--

FUNCTION get_url_ss
  (
  p_pl_id in number,
  p_person_id in number,
  p_plan_name in varchar2,
  p_ler_id in number,
  p_plip_id in number default null,
  p_plan_url in varchar2 default null,
  p_primary_obj_context in varchar2 default null
  )
  RETURN varchar2 IS

--

  l_procedure  VARCHAR2(31) := 'get_url_ss';

  l_hr_authoria_enabled fnd_profile_option_values.profile_option_value%type;
  l_hr_kpi_agent fnd_profile_option_values.profile_option_value%type;
  l_apps_servlet_agent fnd_profile_option_values.profile_option_value%type;
  l_hr_kpi_servlet fnd_profile_option_values.profile_option_value%type;
  l_dbc_filename   varchar2(255);

  l_provider varchar2(50) := 'Authoria';
  l_request varchar2(50) := '?request=GETREDIRECT:';

  l_encrypted_person_id varchar2(100);
  l_page_name varchar2(200);

  l_url varchar2(2000);

  l_separator varchar2(2) := '::';

  l_ret_val VARCHAR2(2000);

  l_user_id fnd_user.user_id%type;
  l_encrypted_user_id varchar2(100);

  l_primary_obj varchar2(100);

--
BEGIN
--
  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'Entering ' || l_procedure);
  END IF;

  -- If a Plan URL has been set up for the Plan then Return that URL
  -- Else If Authoria integration has been enabled, the Required Profile
  -- values have been set and a Page exists in Authoria for the Plan,
  -- Then Return Authoria URL
  -- Else Return Null (Plan will be displayed without any link)

  -- Profile values required for displaying Authoria link
  -- HR_AUTHORIA_ENABLED = 'Y'
  -- HR_KPI_AGENT or APPS_SERVLET_AGENT
  -- HR_KPI_SERVLET


  IF p_plan_url IS NULL THEN

    l_hr_authoria_enabled := fnd_profile.value('HR_AUTHORIA_ENABLED');

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                   MODULE    => g_module || '.' || l_procedure,
                   MESSAGE   => 'profile HR_AUTHORIA_ENABLED is ' ||
                                l_hr_authoria_enabled);
    END IF;

    IF UPPER(l_hr_authoria_enabled) = 'Y' then
      l_hr_kpi_agent := fnd_profile.value('HR_KPI_AGENT');

      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                     MODULE    => g_module || '.' || l_procedure,
                     MESSAGE   => 'profile HR_KPI_AGENT is ' ||l_hr_kpi_agent);
      END IF;

      IF l_hr_kpi_agent is null then
        l_apps_servlet_agent :=  fnd_profile.value('APPS_SERVLET_AGENT');

	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                       MODULE    => g_module || '.' || l_procedure,
                       MESSAGE   => 'profile APPS_SERVLET_AGENT is ' ||
                                    l_apps_servlet_agent);
	END IF;
      END IF;

      l_hr_kpi_servlet := fnd_profile.value('HR_KPI_SERVLET');
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                     MODULE    => g_module || '.' || l_procedure,
                     MESSAGE   => 'profile HR_KPI_SERVLET is ' ||
                                  l_hr_kpi_servlet);
      END IF;

      l_dbc_filename := fnd_web_config.database_id;

      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                     MODULE    => g_module || '.' || l_procedure,
                     MESSAGE   => 'dbc file name is ' || l_dbc_filename);
      END IF;

      l_user_id := ICX_SEC.G_USER_ID;
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                     MODULE    => g_module || '.' || l_procedure,
                     MESSAGE   => 'user id is ' || l_user_id);
      END IF;

      l_encrypted_user_id := hr_sso_utl.encrypt_ps_username(l_user_id);
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                     MODULE    => g_module || '.' || l_procedure,
                     MESSAGE   => 'encryted user id is ' ||
                                  l_encrypted_user_id);
      END IF;

      l_encrypted_person_id := hr_sso_utl.encrypt_ps_username(p_person_id);
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                     MODULE    => g_module || '.' || l_procedure,
                     MESSAGE   => 'encryted person id is ' ||
                                  l_encrypted_person_id);
      END IF;

      l_page_name := hr_auth_int.get_page(p_plip_id,p_pl_id,p_ler_id);
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                     MODULE    => g_module || '.' || l_procedure,
                     MESSAGE   => 'authoria page name is ' || l_page_name);
      END IF;

      l_primary_obj := to_char(p_pl_id)||'A'||to_char(p_plip_id)||','||
                       p_primary_obj_context;
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                     MODULE    => g_module || '.' || l_procedure,
                     MESSAGE   => 'primary object is ' || l_primary_obj);
      END IF;


      IF l_page_name IS NOT NULL
         and NVL(l_hr_kpi_agent, l_apps_servlet_agent) IS NOT NULL
         and l_hr_kpi_servlet IS NOT NULL
         and l_encrypted_person_id IS NOT NULL
         and l_dbc_filename IS NOT NULL
      THEN

        l_url := nvl(l_hr_kpi_agent,l_apps_servlet_agent)|| l_hr_kpi_servlet ||
                 l_request || l_dbc_filename || l_separator || l_provider ||
                 l_separator || l_encrypted_user_id || l_separator ||
                 l_encrypted_person_id ||l_separator ||
                 l_page_name || l_separator || l_primary_obj;

        l_ret_val := l_url;
      END IF;
    END IF;
  END IF;

  IF l_ret_val IS NULL THEN
    l_ret_val := p_plan_url;
  END IF;

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'return url is ' || l_ret_val);
  END IF;

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'Exiting ' || l_procedure);
  END IF;

  return(l_ret_val);
--
EXCEPTION
--
  WHEN others THEN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                   MODULE    => g_module || '.' || l_procedure,
                   MESSAGE   => 'Exiting with Exception' || l_procedure);
    END IF;
    return p_plan_url;
--
END get_url_ss;
--

END hr_auth_int;

/
