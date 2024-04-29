--------------------------------------------------------
--  DDL for Package Body HR_GENERIC_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GENERIC_INT" as
/* $Header: hrgenint.pkb 120.0 2005/05/31 00:36:13 appldev noship $ */

-- Logging code data
g_module         CONSTANT VARCHAR2(80) :=
                                         'per.pl_sql.hr_generic_int';

FUNCTION get_sso_user
	(
	p_user_id IN NUMBER
  )
	RETURN VARCHAR2 IS

l_procedure VARCHAR2(31) := 'get_sso_user';
l_user	VARCHAR2(60) := NULL;

--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

SELECT user_name
INTO l_user
FROM fnd_user
WHERE user_id = p_user_id;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'sso user is ' || l_user);
END IF;

IF l_user IS NULL THEN
  IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'sso user is not found for user_id ' ||
                              p_user_id);
  END IF;
END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

RETURN(l_user);

EXCEPTION
  WHEN OTHERS THEN
    IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                   MODULE    => g_module || '.' || l_procedure,
                   MESSAGE   => 'Error whilst finding SSO entry' ||
                                ' - ' || sqlerrm);
    END IF;
    RAISE;

--
END get_sso_user;
--


FUNCTION manage_user_entry
	(
	p_ext_app_id IN NUMBER,
        p_user_id    IN NUMBER,
        p_app_user   IN VARCHAR2,
        p_app_pwd    IN VARCHAR2,
        p_FNAME1     IN VARCHAR2,
        p_FVAL1      IN VARCHAR2,
        p_FNAME2     IN VARCHAR2,
        p_FVAL2      IN VARCHAR2,
        p_FNAME3     IN VARCHAR2,
        p_FVAL3      IN VARCHAR2,
        p_FNAME4     IN VARCHAR2,
        p_FVAL4      IN VARCHAR2,
        p_FNAME5     IN VARCHAR2,
        p_FVAL5      IN VARCHAR2,
        p_FNAME6     IN VARCHAR2,
        p_FVAL6      IN VARCHAR2,
        p_FNAME7     IN VARCHAR2,
        p_FVAL7      IN VARCHAR2,
        p_FNAME8     IN VARCHAR2,
        p_FVAL8      IN VARCHAR2,
        p_FNAME9     IN VARCHAR2,
        p_FVAL9      IN VARCHAR2

        )
	RETURN VARCHAR2 IS
--
-- needed as we are accessing via a select
pragma autonomous_transaction;
--
l_procedure  VARCHAR2(31) := 'manage_user_entry';
l_result     VARCHAR2(20) := 'SUCCESS';
l_app_id     varchar2(80) := NULL;
l_APP_USER   varchar2(80);
l_APP_PWD    varchar2(80);
l_sso_user   varchar2(80);
l_FNAME1     varchar2(80) := p_FNAME1;
l_FVAL1      varchar2(80) := p_FVAL1;
l_FNAME2     varchar2(80) := p_FNAME2;
l_FVAL2      varchar2(80) := p_FVAL2;
l_FNAME3     varchar2(80) := p_FNAME3;
l_FVAL3      varchar2(80) := p_FVAL3;
l_FNAME4     varchar2(80) := p_FNAME4;
l_FVAL4      varchar2(80) := p_FVAL4;
l_FNAME5     varchar2(80) := p_FNAME5;
l_FVAL5      varchar2(80) := p_FVAL5;
l_FNAME6     varchar2(80) := p_FNAME6;
l_FVAL6      varchar2(80) := p_FVAL6;
l_FNAME7     varchar2(80) := p_FNAME7;
l_FVAL7      varchar2(80) := p_FVAL7;
l_FNAME8     varchar2(80) := p_FNAME8;
l_FVAL8      varchar2(80) := p_FVAL8;
l_FNAME9     varchar2(80) := p_FNAME9;
l_FVAL9      varchar2(80) := p_FVAL9;

l_USER_PREFS varchar2(80) := 'none';

l_error      varchar2(2000);

--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;


-- get sso user
l_sso_user := get_sso_user(p_user_id);

-- if a problem happened whilst getting the sso user
-- an exception will have been raised
-- so with no exception, we can continue

BEGIN

  -- get the existing (if any) user info for this app

  hr_sso_utl.PSTORE_GET_USERINFO
    (
    p_ext_app_id,
    l_sso_user,
    l_APP_USER,
    l_APP_PWD,
    l_FNAME1, l_FVAL1,
    l_FNAME2, l_FVAL2,
    l_FNAME3, l_FVAL3,
    l_FNAME4, l_FVAL4,
    l_FNAME5, l_FVAL5,
    l_FNAME6, l_FVAL6,
    l_FNAME7, l_FVAL7,
    l_FNAME8, l_FVAL8,
    l_FNAME9, l_FVAL9,
    l_USER_PREFS);

  EXCEPTION
    WHEN OTHERS THEN

      IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                     MODULE    => g_module || '.' || l_procedure,
                     MESSAGE   => 'No user found, using defaults');
      END IF;

END;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'APP_USER is ' || l_APP_USER);
END IF;

-- set SSO details
IF (l_APP_PWD IS NULL) THEN

  -- create user for the first time
  -- can not store a null password in the SSO
  -- so user can not already exist

  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                 MODULE    => g_module || '.' || l_procedure,
                 MESSAGE   => 'creating new user');
  END IF;


--reset the f1 to fn values,they might have been overriden
--while using getUserInfo method
l_FNAME1      := p_FNAME1;
l_FVAL1       := p_FVAL1;
l_FNAME2      := p_FNAME2;
l_FVAL2       := p_FVAL2;
l_FNAME3      := p_FNAME3;
l_FVAL3       := p_FVAL3;
l_FNAME4      := p_FNAME4;
l_FVAL4       := p_FVAL4;
l_FNAME5      := p_FNAME5;
l_FVAL5       := p_FVAL5;
l_FNAME6      := p_FNAME6;
l_FVAL6       := p_FVAL6;
l_FNAME7      := p_FNAME7;
l_FVAL7       := p_FVAL7;
l_FNAME8      := p_FNAME8;
l_FVAL8       := p_FVAL8;
l_FNAME9      := p_FNAME9;
l_FVAL9       := p_FVAL9;

  BEGIN
    hr_sso_utl.pstore_add_userinfo
      (
      p_app_id     => p_ext_app_id,
      p_ssouser    => l_sso_user,
      p_app_user   => p_app_user,
      p_app_pwd    => p_app_pwd,
      p_fname1     => l_FNAME1,
      p_fval1      => l_FVAL1,
      p_fname2     => l_FNAME2,
      p_fval2      => l_FVAL2,
      p_fname3     => l_FNAME3,
      p_fval3      => l_FVAL3,
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
          FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                       MODULE    => g_module || '.' || l_procedure,
                       MESSAGE   => 'new user error (pstore_add_userinfo) - '
                       || ' has the user ever signed in via Portal? - '
                       || sqlerrm);
        END IF;
        RAISE;
  END;

ELSE
  -- updating current user


  BEGIN
    hr_sso_utl.pstore_modify_userinfo
      (
      p_app_id     => p_ext_app_id,
      p_ssouser    => l_sso_user,
      p_app_user   => p_app_user,
      p_app_pwd    => p_app_pwd,
      p_fname1     => l_FNAME1,
      p_fval1      => l_FVAL1,
      p_fname2     => l_FNAME2,
      p_fval2      => l_FVAL2,
      p_fname3     => l_FNAME3,
      p_fval3      => l_FVAL3,
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
          FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                       MODULE    => g_module || '.' || l_procedure,
                       MESSAGE   => 'existing user error - ' || sqlerrm);
        END IF;
        RAISE;
  END;
END IF;

COMMIT;


IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;


RETURN(l_result);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- if we raise no_data_found to a calling
    -- select, it just interprets it as no data
    -- and not as an exception
    IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                   MODULE    => g_module || '.' || l_procedure,
                   MESSAGE   => 'Error whilst managing user entry' ||
                                ' - ' || sqlerrm);
    END IF;
    RAISE program_error;
  WHEN OTHERS THEN
    IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                   MODULE    => g_module || '.' || l_procedure,
                   MESSAGE   => 'Error whilst managing user entry' ||
                                ' - ' || sqlerrm);
    END IF;
    RAISE;
--
END manage_user_entry;
--


END hr_generic_int;

/
