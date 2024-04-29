--------------------------------------------------------
--  DDL for Package Body HR_SESSION_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SESSION_UTILITIES" AS
/* $Header: hrsessuw.pkb 120.1 2005/09/23 15:54:57 svittal noship $*/
-- ----------------------------------------------------------------------------
-- |--< VARIABLES >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
g_today 	DATE;
g_today_txt	VARCHAR2 (200);
g_today_set	BOOLEAN;
g_loggedin_user		per_people_f%ROWTYPE;
l_val_person_id	per_people_f.person_id%TYPE;
g_do_process		BOOLEAN;
--2721758
g_debug boolean := hr_utility.debug_enabled;
-- ----------------------------------------------------------------------------
-- |--< Get_LoggedIn_User >---------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_LoggedIn_User
RETURN per_people_f%ROWTYPE
IS
  l_person_id	per_people_f.person_id%TYPE;
--
  l_proc	VARCHAR2 (72) ;
BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  l_proc	:= g_package || ' Get_LoggedIn_User';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

-- note validate session is only used to retrieve data here
-- not actually used to validate the session (done outside of the function)
--
-- changed to eliminate call to validate_session
-- icx_sec called directly
--
  l_person_id := icx_sec.getID(n_param => 9);
  RETURN hr_general_utilities.Get_Person_Record (p_person_id => l_person_id);
EXCEPTION
  WHEN OTHERS THEN
  RAISE ;
END Get_LoggedIn_User;
-- ----------------------------------------------------------------------------
-- |--< insert_session_row >--------------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   insert_session_row
-- description:
--   insert an fnd session row so that selects from date tracked
--   tables is successful.
-- requirement:
--   remember to use remove_session_row
--   when your select is complete.
--
-- updated for bug 1994945
-- ----------------------------------------------------------------------------
PROCEDURE insert_session_row
            (p_effective_date in date)
IS
--
  l_proc	VARCHAR2 (72) := g_package || 'insert_session_row';
BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  --
  dt_fndate.set_effective_date(trunc(p_effective_date));
  --

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_fatal_error;
END insert_session_row;
-- ----------------------------------------------------------------------------
-- |--< insert_session_row >--------------------------------------------------|
-- ----------------------------------------------------------------------------
-- overloaded to accept an encrypted effective date
--
-- this always sets sysdate as the effective date
--
-- updated for bug 1994945
-- ----------------------------------------------------------------------------
PROCEDURE insert_session_row
            (p_effective_date in varchar2)
IS
--
  l_date       date;
--
  l_proc	VARCHAR2 (72) := g_package || 'insert_session_row';
BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  --
  l_date := trunc(SYSDATE);
  --
  dt_fndate.set_effective_date(l_date);
  --

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  --
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_fatal_error;
END insert_session_row;
-- ----------------------------------------------------------------------------
-- |--< remove_session_row >--------------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   remove_session_row
-- description:
--   removes the fnd session row created by insert_session_row
-- ------------------------------------------------------------------------
PROCEDURE remove_session_row
IS
  l_person_id  per_people_f.person_id%type;
--
  l_proc	VARCHAR2 (72) := g_package || ' remove_session_row';
BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  delete from fnd_sessions
  where session_id = userenv('sessionid');

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_fatal_error;
END remove_session_row;
-- ----------------------------------------------------------------------------
-- |--< Get_Installation_Status >---------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Installation_Status (p_application_id IN NUMBER)
RETURN VARCHAR2
IS
  l_hr_installation_status fnd_product_installations.status%TYPE;
-- Cursor to extract the status of the application installation
  CURSOR csr_hr_installation_status(p_application_id number)
  IS
    select fpi.status
    from   fnd_product_installations fpi
    where  fpi.application_id = p_application_id;
--
  l_proc	VARCHAR2 (72) := g_package || ' Get_Installation_Status';
BEGIN

IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  OPEN csr_hr_installation_status(p_application_id => p_application_id);
  FETCH csr_hr_installation_status into l_hr_installation_status;
  CLOSE csr_hr_installation_status;
--
  RETURN l_hr_installation_status;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_fatal_error;
END Get_Installation_Status;
-- ----------------------------------------------------------------------------
-- |--< validate_session >----------------------------------------------------|
-- ----------------------------------------------------------------------------
-- VALIDATE SESSION, REVISED HERE, BUT ELIMINATED FROM PACKAGE HEADER
-- VALIDATE SESSION IN HR_UTIL_MISC_WEB USED INSTEAD
--
-- name:
--   validate_session (one out parameter, four in parameters)
-- description:
--   Calls the internet commerce's security procedure to check for a valid
--   'cookie' for this user.  Also calls their routine to return the person_id
--   based upon their web id.
--
-- 10/15/97
--   The default for calling icx_sec.validateSession is to update the count
--   and timestamp in icx_session table but do NOT commit to database.  The
--   reason being EDA modules are not allowed to have a commit while within
--   a workflow activity.
-- ------------------------------------------------------------------------
PROCEDURE validate_session
   (p_person_id    out nocopy    number
   ,p_check_ota    in     varchar2 default 'N'
   ,p_check_ben    in     varchar2 default 'N'
   ,p_icx_update   in     boolean  default true      -- 10/15/97 Changed
   ,p_icx_commit   in     boolean  default false) IS -- 10/15/97 Changed
--
  l_web_username  varchar2(80) default null;
  l_person_id     per_people_f.person_id%type;
  l_proc	VARCHAR2 (72) ;
BEGIN

IF g_debug THEN
  l_proc	:= g_package || ' validate_session';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

   hr_util_misc_web.validate_session
              (p_person_id    => l_person_id
              ,p_web_username => l_web_username
              ,p_check_ota    => p_check_ota
              ,p_check_ben    => p_check_ben
              ,p_icx_update   => p_icx_update           -- 10/15/97 Changed
              ,p_icx_commit   => p_icx_commit);         -- 10/15/97 Changed
  p_person_id := l_person_id;

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 5);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
-- capture errors as they are in the calling code
END validate_session;
-- ----------------------------------------------------------------------------
-- |--------------------------------< validate_session >----------------------|
-- ----------------------------------------------------------------------------
-- name:
--   validate_session (Two Out Parameters, four in parameters)
-- description:
--   Calls the internet commerce's security procedure to check for a valid
--  'cookie' for this user.  Also calls their routine to return the person_id
--   based upon their web id.
-- ------------------------------------------------------------------------
PROCEDURE validate_session
   (p_person_id    out nocopy    number
   ,p_web_username out nocopy    varchar2
   ,p_check_ota    in     varchar2 default 'N'
   ,p_check_ben    in     varchar2 default 'N'
   ,p_icx_update   in     boolean  default true         -- 10/15/97 Changed
   ,p_icx_commit   in     boolean  default false) IS    -- 10/15/97 Changed
--

  l_web_user_id   number;
  l_web_username  varchar2(80) default null;

  l_cookie        		owa_cookie.cookie;
  l_person_id     		per_people_f.person_id%type;
  l_hr_installation_status 	fnd_product_installations.status%TYPE
				DEFAULT NULL;
--
--
  l_proc	VARCHAR2 (72) ;
BEGIN

IF g_debug THEN
  l_proc	:= g_package || ' validate_session';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

-- validate the session
-- ----------------------------------------------------------------------------
-- 10/15/97
-- The default for calling icx_sec.validateSession is to update the count and
-- timestamp in icx_session table but NOT to commit.  The reason is EDA
-- or any modules invoked by workflow cannot have a commit while the workflow
-- process is not completed.
-- ----------------------------------------------------------------------------
  IF NOT(icx_sec.validateSession(c_update => p_icx_update        --10/15/97 Chg
                                ,c_commit => p_icx_commit)) then --10/15/97 Chg
    RAISE g_fatal_error;
  ELSE

IF g_debug THEN
    hr_utility.set_location(l_proc, 10);
END IF;

    --
    -- ensure HR is fully installed, else raise error
    --
    IF NOT Get_Installation_Status (
		p_application_id => g_per_application_id) = 'I' THEN
      fnd_message.set_name('PER', 'HR_7079_HR_NOT_INSTALLED');
      RAISE g_fatal_error;
    ELSE
      NULL;
    END IF;
-- ----------------------------------------------------------------------------
    IF p_check_ota = 'Y' THEN
      --
      -- ensure OTA is fully installed, else raise error
      --
      IF NOT Get_Installation_Status (p_application_id => 810) = 'I' THEN
        fnd_message.set_name('OTA', 'OTA_13629_WEB_OTA_NOT_INSTALL');
        RAISE g_fatal_error;
      ELSE
        NULL;
      END IF;
    END IF;
--
    IF p_check_ben = 'Y' THEN
      --
      -- ensure BEN is fully installed, else raise error
      --
      IF NOT Get_Installation_Status (p_application_id => 805) = 'I' THEN
        fnd_message.set_name('BEN', 'BEN_CHANGE_ME');
        RAISE g_fatal_error;
      ELSE
        NULL;
      END IF;
    END IF;
-- ----------------------------------------------------------------------------

IF g_debug THEN
    hr_utility.set_location(l_proc, 10);
END IF;

--
      -- getid with a parm of 10 returns the web user id.
      -- we don't need this id in our code, but getid
      -- also returns a -1 into the web user id if we are in
      -- a psuedo session situation:  this we do need to know
      -- so that we can manually get the person information when
      -- there is a psuedo session.
    l_web_user_id := icx_sec.getID(n_param => 10);
	--
    -- determine if the web user is -1 (pseudo session)
    IF l_web_user_id = -1 then

IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
END IF;

      -- as we are in a pseudo session get the cookie record
      -- for the cookie WF_SESSION
      l_cookie := owa_cookie.get('WF_SESSION');
      -- ensure the cookie exists
      IF l_cookie.num_vals > 0 then
        -- as the cookie does exist get the web username from
        -- the workflow system
        l_web_username := wf_notification.accesscheck
                            (l_cookie.vals(l_cookie.num_vals));
        --
        -- getid with a parm of 9 returns the internal-contact-id,
        l_person_id := icx_sec.getID(n_param => 9);
        --
      ELSE

IF g_debug THEN
        hr_utility.set_location(l_proc, 30);
END IF;

        -- the WF_SESSION cookie does not exist. a serious error
        -- has ocurred which must be reported
        --
        fnd_message.set_name('PER','HR_51393_WEB_COOKIE_ERROR');
	RAISE g_fatal_error;
      END IF;
    ELSE

IF g_debug THEN
      hr_utility.set_location(l_proc, 40);
END IF;

	  -- 11/14/96 the person_id is stored in security attribute values
	  -- associated with a web user.
	  --
	  -- 12/26/97 remove calls to getSecureAttributeValues, use getid.
	  -- getid with a parm of 9 returns the internal-contact-id,
	  -- which in our case is the person_id.
      l_person_id := icx_sec.getID(n_param => 9);
	  --
	  -- getid with a parm of 99 returns the web user name.
      l_web_username := icx_sec.getID(n_param => 99);
    END IF;
  END IF;
  p_person_id    := l_person_id;
  p_web_username := l_web_username;
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

EXCEPTION
  -- too many rows will be returned if the csr_iwu returns more than
  -- one person id for the web user.
  WHEN TOO_MANY_ROWS then
    fnd_message.set_name('PER','HR_51776_WEB_TOO_MANY_USERS');
    RAISE;
  WHEN g_fatal_error THEN
    -- messages set, just re-raise
    RAISE;
  WHEN OTHERS THEN
    -- can't find this message name so uses the given value instead
    fnd_message.set_name('PER', sqlerrm|| ' '||sqlcode);
    RAISE;
END validate_session;
-- ----------------------------------------------------------------------------
-- |--< get_language_code >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   get_language_code
-- description:
--   This function returns the language code for the current session.
-- ----------------------------------------------------------------------------
FUNCTION get_language_code
RETURN VARCHAR2
IS
--
--
  l_proc	VARCHAR2 (72) := g_package || ' get_language_code';
BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  RETURN icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_fatal_error;
END get_language_code;
-- ----------------------------------------------------------------------------
-- |--< get_image_directory >-------------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   get_image_directory
-- description:
--   Gets the image directory for the current session language.  Images are
--   stored by language code.
-- ----------------------------------------------------------------------------
FUNCTION get_image_directory
RETURN VARCHAR2
IS
  l_proc	VARCHAR2 (72) := g_package || ' get_image_directory';
BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  RETURN '/' || hr_session_utilities.g_image_dir || '/'
         || get_language_code||'/';
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_fatal_error;
END get_image_directory;
-- ----------------------------------------------------------------------------
-- |--< get_html_directory >--------------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   get_html_directory
-- description:
--   Gets the html directory for the current session language.
-- ----------------------------------------------------------------------------
FUNCTION get_html_directory
RETURN VARCHAR2
IS
--
--
  l_proc	VARCHAR2 (72) := g_package || ' get_html_directory';
BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


  RETURN
    '/' || hr_session_utilities.g_html_dir || '/' || get_language_code||'/';
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_fatal_error;
END get_html_directory;
-- ----------------------------------------------------------------------------
-- |--< get_static_html_directory >-------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   get_static_html_directory
-- description:
--   Gets the static html directory for the current session language.
-- ----------------------------------------------------------------------------
FUNCTION get_static_html_directory
RETURN VARCHAR2
IS
--
--
  l_proc	VARCHAR2 (72) := g_package || ' get_static_html_directory';
BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  RETURN
    '/' ||
    hr_session_utilities.g_static_html_dir ||'/';
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_fatal_error;
END get_static_html_directory;
-- ----------------------------------------------------------------------------
-- |--< get_java_directory >--------------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   get_java_directory
-- description:
--   Gets the java directory for the current session language.
-- ----------------------------------------------------------------------------
FUNCTION get_java_directory
RETURN VARCHAR2
IS
--
--
  l_proc	VARCHAR2 (72) := g_package || ' get_java_directory';
BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  --
  RETURN hr_session_utilities.g_java_dir || get_language_code||'/';
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_fatal_error;
END get_java_directory;
-- ----------------------------------------------------------------------------
-- |--< get_user_date_format >------------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   get_user_date_format
--
-- description:
--   This function retrieves user's preference date format mask from
--   icx.
-- ----------------------------------------------------------------------------
FUNCTION get_user_date_format
RETURN VARCHAR2
IS
BEGIN

  return(hr_util_misc_web.get_user_date_format);

END get_user_date_format;
-- ----------------------------------------------------------------------------
-- |--< Get_Base_HREF >-------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Base_HREF
RETURN VARCHAR2
IS
  l_owa	  	VARCHAR2 (1000);
  l_proc	VARCHAR2 (72) := g_package || ' Get_Base_HREF';
BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

-- Fix for bug 894682
    l_owa := FND_WEB_CONFIG.PLSQL_AGENT;

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN l_owa;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_fatal_error;
END Get_Base_HREF;
-- ----------------------------------------------------------------------------
-- |--< Get_Today >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Today
RETURN DATE
IS
BEGIN

  RETURN g_today;
END Get_Today;
-- ----------------------------------------------------------------------------
-- |--< Get_Today_As_Text >---------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Today_As_Text
RETURN VARCHAR2
IS
BEGIN

--
  RETURN g_today_txt;
END Get_Today_As_Text;
-- ----------------------------------------------------------------------------
-- |--< Get_Print_Action >----------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Print_Action
  ( p_frame_index	 IN NUMBER
  )
RETURN VARCHAR2
IS
  l_return_val	VARCHAR2 (2000);
  l_user_agent VARCHAR2 (2000) := owa_util.get_cgi_env ('HTTP_USER_AGENT');
  l_proc	VARCHAR2 (72) ;
BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  l_proc	:= g_package || ' Get_Print_Action';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  IF INSTR
       ( UPPER
           (l_user_agent
           )
          , 'MSIE'
--        , UPPER(hrhtml.d_printapiavailable_rec)
        ) > 0
  THEN
    -- print api available
    l_return_val := 'MSIE';
--      'window.parent.frames[' || to_char(p_frame_index) || '].print()';
  ELSIF INSTR
       ( UPPER
           (l_user_agent
           )
          , 'MOZILLA/4'
--        , UPPER(hrhtml.d_printapiavailable_rec)
        ) > 0 THEN
    -- print api not available
    l_return_val := 'NN4';
  ELSIF INSTR
       ( UPPER
           (l_user_agent
           )
          , 'MOZILLA/3'
        ) > 0
  THEN
    -- print api not available
    l_return_val := 'NN3';
  END IF;
--
  IF l_return_val = 'NN3' THEN
    IF  INSTR
       ( UPPER
           (l_user_agent
           )
          , '(W'
        ) > 0
    THEN
      l_return_val := l_return_val || 'W';
    ELSIF INSTR
       ( UPPER
           (l_user_agent
           )
          , '(X'
        ) > 0
    THEN
      l_return_val := l_return_val || 'X';
    ELSE
      l_return_val := l_return_val || 'U';
    END IF;
  ELSE
    NULL;
  END IF;


/*
      hrhtml.Use_JS_Click_Event
        ( p_url =>
            'hrhtml2.dp'
        , p_event_action => 'NONMODALINFO'
        );
*/

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

--
  RETURN l_return_val;
END Get_Print_Action;


-- bug 1641590
/*
-- ----------------------------------------------------------------------------
-- |--< PACKAGE INITIALIZATION >----------------------------------------------|
-- ----------------------------------------------------------------------------
BEGIN
--
-- bug 748569 fix: validate_session package initialization code eliminated
-- handled by frame drawing procedures only
--
    g_loggedin_user := hr_session_utilities.get_LoggedIn_User;
*/

END HR_SESSION_UTILITIES;

/
