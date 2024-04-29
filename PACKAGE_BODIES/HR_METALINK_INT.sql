--------------------------------------------------------
--  DDL for Package Body HR_METALINK_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_METALINK_INT" as
/* $Header: hrmtlint.pkb 120.0 2005/05/31 01:28:06 appldev noship $ */


-- Logging code data
g_module         CONSTANT VARCHAR2(80) :=
                                         'per.pl_sql.hr_metalink_int';



FUNCTION get_redirect_url
	(
	p_note_id IN VARCHAR2
	)
	RETURN VARCHAR2 IS
--
l_APP_NAME   varchar2(80);
l_APPTYPE    varchar2(80);
l_APPURL     varchar2(2000);
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
l_procedure  VARCHAR2(31) := 'get_redirect_url';
l_url        VARCHAR2(2000) :=
  'http://metalink.oracle.com/' ||
  'metalink/plsql/ml2_documents.showDocument' ||
  '?p_database_id=NOT' ||
  '&' || 'p_id=';
l_app_id     varchar2(80) := NULL;
l_error      varchar2(2000);
l_pos varchar2(30);

--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;
BEGIN
  l_app_id := hr_external_application.get_app_id('MetaLink');

  EXCEPTION
    WHEN OTHERS THEN
      IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                     MODULE    => g_module || '.' || l_procedure,
                     MESSAGE   => 'Unable to determine SSO external ' ||
                                  'application - ' || sqlerrm);
      END IF;
END;

IF l_app_id IS NULL THEN
  -- qqq
  -- really should be a message
  l_error := 'Unable to determine the external application details ' ||
               'via SSO for Metalink.';
END IF;


IF l_error IS NULL THEN

  BEGIN
    l_pos := 'GET' || l_app_id;
    -- get existing details
    hr_sso_utl.PSTORE_GET_APP_INFO(
	l_app_id,
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

    -- work out new url
    l_url := l_url || p_note_id;

    -- update with new info, if required
    l_pos := 'modify';
    IF l_APPURL <> l_url THEN
      hr_sso_utl.PSTORE_MODIFY_APP_INFO(
	l_app_id,
	l_APP_NAME,
	l_APPTYPE,
	l_url,
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
     END IF;

     EXCEPTION
      WHEN OTHERS THEN
        IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                       MODULE    => g_module || '.' || l_procedure,
                       MESSAGE   => 'Unable to modify SSO external ' ||
                                    'application - ' || sqlerrm);
        END IF;
        l_error := 'Unable to modify SSO external ' ||
                   'application - ' || l_pos || ' - ' || sqlerrm || '.';
    END;

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
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'url is ' || l_url);
END IF;

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;


RETURN(l_url);

EXCEPTION
  WHEN OTHERS THEN
    IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_ERROR,
                   MODULE    => g_module || '.' || l_procedure,
                   MESSAGE   => 'Error whilst determining redirection URL' ||
                                ' - ' || sqlerrm);
    END IF;


--
END get_redirect_url;
--




FUNCTION get_url (p_note_id IN VARCHAR2)
  RETURN VARCHAR2 IS
--
pragma autonomous_transaction;
--

l_procedure VARCHAR2(31) := 'get_url';
l_url       VARCHAR2(2000);

--
BEGIN
--

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Entering ' || l_procedure);
END IF;

IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'p_note_id = ' || p_note_id);
END IF;


-- get redirection URL (or error text)
-- after adding 'set,,' to primary obj string
l_url := get_redirect_url(p_note_id);

IF SUBSTR(l_url,5) = 'ERROR' THEN
  l_url := 'ERROR : APPS-47368 : ' || l_url ||
           ' Examine FND logging information for more details.';
END IF;


IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'URL is ' || l_url);
END IF;


IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_LOG.STRING (LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
               MODULE    => g_module || '.' || l_procedure,
               MESSAGE   => 'Exiting ' || l_procedure);
END IF;

COMMIT;

RETURN(l_url);

--
END get_url;
--



END hr_metalink_int;

/
