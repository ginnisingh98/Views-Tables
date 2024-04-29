--------------------------------------------------------
--  DDL for Package Body HR_USER_ACCT_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_USER_ACCT_INTERNAL" as
/* $Header: hrusrbsi.pkb 120.4.12010000.3 2009/07/02 06:22:14 pthoonig ship $ */
--
-- Private Global Variables
--
g_package                    varchar2(33) := 'hr_user_acct_internal.';
g_max_user_name_length       constant number := 100;
g_max_email_address_length   constant number := 240;
g_max_fax_length             constant number := 80;
g_api_vers                   constant number := 1.0;
g_empty_fnd_user_rec         hr_user_acct_utility.fnd_user_rec;
g_emtpy_fnd_resp_tbl         hr_user_acct_utility.fnd_responsibility_tbl;
g_emtpy_fnd_prof_opt_val_tbl hr_user_acct_utility.fnd_profile_opt_val_tbl;
--
-- ----------------------------------------------------------------------------
-- |--------------------------- < generate_string > ---------------------------|
-- ----------------------------------------------------------------------------
FUNCTION generate_string (p_user_name in varchar2
                          ,p_id     in number)
RETURN varchar2 IS
--
--
  j                      number default 0;
  k                      number default null;
  l_str                  varchar2(30) default null;
  l_result               varchar2(30) default null;
  l_proc                 varchar2(72) := g_package||'generate_string';
--
BEGIN
  --
  hr_utility.set_location('Entering:' || l_proc, 10);

  IF p_id is null
  THEN
     return null;
  END IF;
  while true loop
    l_str := to_char(sysdate, 'SSSSMIHH');
    j := 0;
    k := null;
    l_result := null;
  --
    FOR i in 1..least(length(l_str), 8)
    LOOP
      j := mod(j + ascii(substr(l_str, i, 1)), 256);
      k := mod(bitand(j,ascii(substr(l_str, i, 1))), 74)+48;
    --
      IF k between 58 and 64
      THEN
         k := k + 7;
      ELSIF k between 91 and 96
      THEN
         k := k + 6;
      END IF;
    --
      l_result := l_result || fnd_global.local_chr(k);
    END LOOP;
  --
    if fnd_web_sec.validate_password(username  => p_user_name
                                     ,password => l_result
                                     ) = 'Y' then
      return l_result;
    end if;
  end loop;
  RETURN l_result;
  --
  hr_utility.set_location('Leaving:' || l_proc, 50);
--
EXCEPTION
  WHEN others THEN
       hr_utility.set_message(800, 'HR_GENERATE_PASSWORD_ERR');
       hr_utility.raise_error;
       return null;

END generate_string;
--
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------- < create_fnd_user > ---------------------------|
-- | NOTE: The fnd api fnd_user_pkg.create_user that this api will be calling |
-- |       does not have code to handle AK securing attributes.  Thus, this   |
-- |       api will not do any inserts into ak_web_user_sec_attr_values table.|
-- |       So, this api does not do everything that the FND Create User form  |
-- |       does.                                                              |
-- |       No savepoint will be issued here because business support internal |
--         process is not supposed to issue any savepoint or rollback.        |
-- ----------------------------------------------------------------------------
--
-- Fix 2288014. Modified procedure create_fnd_user adding parameter
-- p_password_date that could be passed to fnd_user_pkg.CreateUserId
PROCEDURE create_fnd_user
  (p_hire_date                     in     date     default null
  ,p_user_name                     in     varchar2
  ,p_password                      in out nocopy varchar2
  ,p_user_start_date               in     date     default null
  ,p_user_end_date                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_fax                           in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_password_date                 in     date default null -- Fix 2288014
  ,p_language                      in     varchar2 default 'AMERICAN'
  ,p_host_port                     in     varchar2 default null
  ,p_employee_id                   in     varchar2 default null
  ,p_customer_id                   in     varchar2 default null
  ,p_supplier_id                   in     varchar2 default null
  ,p_user_id                       out nocopy    number
  ) IS

CURSOR lc_get_user_name IS
SELECT user_name, user_id
FROM   fnd_user
WHERE  user_name = upper(p_user_name);

l_proc                             varchar2(72) := g_package||'create_fnd_user';
l_fnd_user_start_date              date default null;
l_fnd_user_end_date                date default null;
l_host_port_name                   varchar2(2000) default null;
l_pos                              number default 0;
l_count                            number default 0;
l_password                         varchar2(30) default null;
l_return_status                    varchar2(32000) default null;
l_msg_count                        number default 0;
l_msg_data                         varchar2(32000) default null;
l_fnd_user_id                      number default null;
l_last_updated_by                  number default null;
l_last_update_login                number default null;
l_app_short_name                   varchar2(200) default null;
l_msg_name                         fnd_new_messages.message_name%type
                                   default null;
l_host_name                        varchar2(2000) default null;
l_port_name                        varchar2(2000) default null;
l_plsql_agent                      varchar2(2000) default null;
l_user_name                        fnd_user.user_name%type default null;
l_user_id                          fnd_user.user_id%type default null;

e_create_fnd_user           EXCEPTION; -- Fix 2288014
--
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validate input parameters first
  -- Validate p_user_start_date
  IF p_user_start_date IS NULL
  THEN
     IF p_hire_date IS NULL
     THEN
        hr_utility.set_message(800, 'HR_NO_HIRE_DATE');
        hr_utility.raise_error;
     ELSE
        l_fnd_user_start_date := p_hire_date;
     END IF;
  ELSE
     l_fnd_user_start_date := p_user_start_date;
  END IF;


  -- Validate p_user_end_date.  If entered, it must be larger than start_date
  IF p_user_end_date IS NULL
  THEN
     l_fnd_user_end_date := null;
  ELSE
     IF p_user_end_date >= l_fnd_user_start_date
     THEN
        l_fnd_user_end_date := p_user_end_date;
     ELSE
        hr_utility.set_message(800, 'HR_51070_CAU_START_END');
        hr_utility.raise_error;
     END IF;
  END IF;
  --
  --
  -- Validate email address length
  IF length(p_email_address) > g_max_email_address_length
  THEN
     hr_utility.set_message(800, 'HR_INVALID_EMAIL_ADDR_LENGTH');
     hr_utility.raise_error;
  END IF;
  --
  -- Validate fax length
  IF length(p_fax) > g_max_fax_length
  THEN
     hr_utility.set_message(800, 'HR_INVALID_FAX_LENGTH');
     hr_utility.raise_error;
  END IF;
  --
  -- Validate user name
  IF p_user_name IS NOT NULL
  THEN
     l_pos := length(p_user_name);
     IF l_pos IS NULL
     THEN
        hr_utility.set_message(800, 'HR_USER_NAME_NOT_SUPPLIED');
        hr_utility.raise_error;
     ELSIF l_pos > g_max_user_name_length
     THEN
        hr_utility.set_message(800, 'HR_USER_NAME_LENGTH_EXCEEDED');
        hr_utility.raise_error;
     END IF;
  ELSE
     hr_utility.set_message(800, 'HR_USER_NAME_MISSING');
     hr_utility.raise_error;
  END IF;
  --
  -- Check for uniqueness of the user name
  OPEN lc_get_user_name;
  FETCH lc_get_user_name into l_user_name, l_user_id;
  IF lc_get_user_name%NOTFOUND
  THEN
     CLOSE lc_get_user_name;
  ELSE
     -- Issue an error if user_name already exists
     CLOSE lc_get_user_name;
     fnd_message.set_name('PER', 'HR_USER_NAME_ALREADY_EXISTS');
     fnd_message.set_token('USER_NAME', p_user_name);
     hr_utility.raise_error;
  END IF;

  --
  -- Check for employee id if it exists
  IF p_employee_id IS NOT NULL
  THEN
     SELECT  count(1)
     INTO    l_count
     FROM    per_all_people_f
     WHERE   person_id = p_employee_id;

     IF l_count <= 0
     THEN
        hr_utility.set_message(800, 'HR_INVALID_EMP_ID');
        hr_utility.raise_error;
     END IF;
  ELSE
     NULL;
  END IF;
  --
  -- The following is mimicking FNDSCAUS.fmb program unit fnd_encrypt_pwd.
  -- Check password length.  The minimum password length can be set via a
  -- profile option.  If that profile option is null, the default is 5.
  --
  l_count := 0;
  l_count := to_number(
             nvl(fnd_profile.value('SIGNON_PASSWORD_LENGTH'), '5')
                      );

  IF l_count > 8 AND p_password IS NULL
  THEN
     -- The random password generator can produce 8-byte alphanumeric string.
     --  So any length more than 8 must be supplied by customers.
     hr_utility.set_message(800, 'HR_USER_PASSWORD_LENGTH_INV');
     hr_utility.raise_error;
  END IF;
  --
  -- Customers can supply a password.  If no password is supplied, we randomly
  -- generate an 8-byte alphanumeric characters.
  IF p_password IS NULL
  THEN
     --
     l_password := generate_string (p_user_name => p_user_name
                                    ,p_id  => fnd_crypto.smallrandomnumber);
     --
     IF l_password IS NULL
     THEN
        hr_utility.set_message(800, 'HR_PASSWORD_NULL');
        hr_utility.raise_error;
     END IF;
     --
  ELSIF (length(p_password) < l_count)
  THEN
     fnd_message.set_name('FND', 'PASSWORD-LONGER');
     fnd_message.set_token('LENGTH', to_char(l_count));
     hr_utility.raise_error;
  ELSIF (length(p_password) > 30)
  THEN
     hr_utility.set_message(800, 'HR_USER_PASSWORD_TOO_LONG');
     hr_utility.raise_error;
  ELSE
     l_password := p_password;
  END IF;
  --
  -----------------------------------------------------------------------------
  -- Set fnd last_updated_by and last_update_login columns
  -----------------------------------------------------------------------------
  l_last_updated_by := fnd_global.user_id;
  IF l_last_updated_by IS NULL
  THEN
     l_last_updated_by := -1;
  END IF;
  --
  l_last_update_login := fnd_global.login_id;
  IF l_last_update_login IS NULL
  THEN
     l_last_update_login := -1;
  END IF;
  --
  -- Now, we're ready to call fnd api to create a user name.
  --
  hr_utility.set_location (l_proc || ' before fnd_user_pkg.CreateUser', 30);
  --
  -- Fix  2288014 Start

  BEGIN
  -- Using fnd_user_pkg.CreateUserId is useful as we do not have to write another select
  --  query to retrieve user_id based on user_name.

  p_user_id := fnd_user_pkg.CreateUserId (
              x_user_name             => p_user_name,
              x_owner                 => '',
              x_unencrypted_password  => l_password,
              x_start_date            => l_fnd_user_start_date,
              x_end_date              => l_fnd_user_end_date,
--	      x_last_logon_date       => sysdate, -- For BUG 7116804
              x_description           => p_description,
              x_password_date         => p_password_date, -- Fix 2288014
              x_employee_id           => p_employee_id,
              x_email_address         => p_email_address,
              x_fax		      => p_fax,
              x_customer_id           => p_customer_id,
              x_supplier_id           => p_supplier_id);

    EXCEPTION
          WHEN OTHERS THEN
              raise e_create_fnd_user;
    END;

  --  Set out parameters

     p_password := l_password;


  --
  hr_utility.set_location('Leaving:' || l_proc, 70);
  --

EXCEPTION
WHEN OTHERS THEN

  hr_utility.raise_error;

-- Fix  2288014 End


END create_fnd_user;
--
-- ----------------------------------------------------------------------------
-- |---------------------- < create_fnd_responsibility > ----------------------|
-- |                                                                           |
-- |NOTE:  No savepoint will be issued here because business support internal  |
-- |       process is not supposed to issue any savepoint or rollback.         |
-- ----------------------------------------------------------------------------
--
PROCEDURE create_fnd_responsibility
  (p_resp_key              in fnd_responsibility.responsibility_key%type
  ,p_resp_name             in fnd_responsibility_tl.responsibility_name%type
  ,p_resp_app_id           in fnd_responsibility.application_id%type
  ,p_resp_description      in fnd_responsibility_tl.description%type
                                default null
  ,p_start_date            in fnd_responsibility.start_date%type
  ,p_end_date              in fnd_responsibility.end_date%type default null
  ,p_data_group_name       in fnd_data_groups_standard_view.data_group_name%type
  ,p_data_group_app_id     in fnd_responsibility.data_group_application_id%type
  ,p_menu_name             in fnd_menus.menu_name%type
  ,p_request_group_name    in fnd_request_groups.request_group_name%type
                                default null
  ,p_request_group_app_id  in fnd_responsibility.group_application_id%type
                                default null
  ,p_version               in fnd_responsibility.version%type default '4'
  ,p_web_host_name         in fnd_responsibility.web_host_name%type default null
  ,p_web_agent_name        in fnd_responsibility.web_agent_name%type
                                default null
  ,p_responsibility_id     out nocopy number
  ) IS
--
CURSOR lc_get_app_short_name (c_app_id in number) IS
SELECT application_short_name
FROM   fnd_application
WHERE  application_id = c_app_id;
--
-- The following check unique resp key sql is copied from FNDSCRSP.fmb,
-- program unit FND_UNIQUE_RESP_KEY.
--
CURSOR lc_unique_resp_key IS
SELECT 1
FROM   sys.dual
WHERE  NOT EXISTS
       (SELECT  1
        FROM    fnd_responsibility
        WHERE   responsibility_key = p_resp_key
        AND     application_id = p_resp_app_id);
--
-- The following check unique resp name sql is copied from FNDSCRSP.fmb,
-- program unit FND_UNIQUE_RESP_NAME.
--
CURSOR lc_unique_resp_name IS
SELECT 1
FROM   sys.dual
WHERE  NOT EXISTS
       (SELECT  1
        FROM    fnd_responsibility_vl
        WHERE   responsibility_name = p_resp_name
        AND     application_id = p_resp_app_id);
--
CURSOR lc_get_data_group_id IS
SELECT data_group_id
FROM   fnd_data_groups_standard_view
WHERE  data_group_name = p_data_group_name;
--
CURSOR lc_get_menu_id IS
SELECT menu_id
FROM   fnd_menus
WHERE  menu_name = p_menu_name;
--
CURSOR lc_get_req_group_id IS
SELECT request_group_id
FROM   fnd_request_groups
WHERE  request_group_name = p_request_group_name
AND    application_id = p_request_group_app_id;
--
CURSOR lc_generate_resp_id IS
SELECT fnd_responsibility_s.nextval
FROM   sys.dual;


l_proc                varchar2(72) := g_package||'create_fnd_responsibility';
l_resp_app_short_name fnd_application.application_short_name%type := null;
l_data_grp_app_short_name fnd_application.application_short_name%type := null;
l_req_grp_app_short_name fnd_application.application_short_name%type := null;
l_dummy               number default null;
l_request_group_app_id   fnd_responsibility.group_application_id%type
                             default null;
l_responsibility_id   fnd_responsibility.responsibility_id%type default null;
l_data_grp_id            fnd_data_groups.data_group_id%type default null;
l_req_grp_app_id         fnd_request_groups.application_id%type default null;
--
BEGIN
  hr_utility.set_location('Entering:' || l_proc, 10);
  --
  -- Validate input parameters first
  -- Validate responsibility application id exists
  --
    OPEN lc_get_app_short_name (c_app_id => p_resp_app_id);
    FETCH lc_get_app_short_name into l_resp_app_short_name;
    IF lc_get_app_short_name%NOTFOUND
    THEN
       CLOSE lc_get_app_short_name;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_APPLICATION');
       fnd_message.set_token('COLUMN', 'APPLICATION_ID');
       fnd_message.set_token('VALUE', to_char(p_resp_app_id));
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_app_short_name;
    END IF;

  -- Get the Data Group Application Short Name because fnd api uses the
  -- short name as input parameter instead of the id.
    OPEN lc_get_app_short_name (c_app_id => p_data_group_app_id);
    FETCH lc_get_app_short_name into l_data_grp_app_short_name;
    IF lc_get_app_short_name%NOTFOUND
    THEN
       CLOSE lc_get_app_short_name;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_APPLICATION');
       fnd_message.set_token('COLUMN', 'APPLICATION_ID');
       fnd_message.set_token('VALUE', to_char(p_data_group_app_id));
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_app_short_name;
    END IF;

  -- Get the Request Group Application Short Name because fnd api uses the
  -- short name as input parameter instead of the id.
  -- Only get the short name when the p_request_group_app_id is not null.

  IF p_request_group_app_id IS NOT NULL
  THEN
     OPEN lc_get_app_short_name (c_app_id => p_request_group_app_id);
     FETCH lc_get_app_short_name into l_req_grp_app_short_name;
     IF lc_get_app_short_name%NOTFOUND
     THEN
        CLOSE lc_get_app_short_name;
        fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
        fnd_message.set_token('TABLE', 'FND_APPLICATION');
        fnd_message.set_token('COLUMN', 'APPLICATION_ID');
        fnd_message.set_token('VALUE', to_char(p_request_group_app_id));
        hr_utility.raise_error;
     ELSE
        CLOSE lc_get_app_short_name;
     END IF;
  END IF;
  --
  -- Validate Data Group Application ID
  --
    OPEN lc_get_data_group_id;
    FETCH lc_get_data_group_id into l_data_grp_id;
    IF lc_get_data_group_id%NOTFOUND
    THEN
       CLOSE lc_get_data_group_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_DATA_GROUPS_STANDARD_VIEW');
       fnd_message.set_token('COLUMN', 'DATA_GROUP_NAME');
       fnd_message.set_token('VALUE', p_data_group_name);
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_data_group_id;
    END IF;
  --
  --
  -- Validate unique responsibility key
  --
    OPEN lc_unique_resp_key;
    FETCH lc_unique_resp_key into l_dummy;
    IF lc_unique_resp_key%NOTFOUND
    THEN
       CLOSE lc_unique_resp_key;
       fnd_message.set_name('FND', 'SECURITY-DUPLICATE RESP NAME');
       hr_utility.raise_error;
    ELSE
       CLOSE lc_unique_resp_key;
    END IF;

  --
  -- Validate unique responsibility name
  --
    l_dummy := null;
    OPEN lc_unique_resp_name;
    FETCH lc_unique_resp_name into l_dummy;
    IF lc_unique_resp_name%NOTFOUND
    THEN
       CLOSE lc_unique_resp_name;
       fnd_message.set_name('FND', 'SECURITY-DUPLICATE RESP NAME');
       hr_utility.raise_error;
    ELSE
       CLOSE lc_unique_resp_name;
    END IF;

  --
  -- Validate Version
  IF p_version = '4' OR
     p_version = 'W'
  THEN
     null;
  ELSE
     hr_utility.set_message(800, 'HR_INVALID_RESP_VERSION');
     hr_utility.raise_error;
  END IF;
  --
  -- Validate End Date must be >= Start Date
  IF p_end_date IS NOT NULL
  THEN
     IF p_end_date < nvl(p_start_date, p_end_date + 1)
     THEN
        hr_utility.set_message(800, 'HR_51070_CAU_START_END');
        hr_utility.raise_error;
     END IF;
  END IF;
  --
  -- Validate data_group_name
  --
    l_dummy := null;
    OPEN lc_get_data_group_id;
    FETCH lc_get_data_group_id into l_dummy;
    IF lc_get_data_group_id%NOTFOUND
    THEN
       CLOSE lc_get_data_group_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_DATA_GROUPS_STANDARD_VIEW');
       fnd_message.set_token('COLUMN', 'DATA_GROUP_NAME');
       fnd_message.set_token('VALUE', p_data_group_name);
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_data_group_id;
    END IF;

  --
  -- Validate menu name
  --
    l_dummy := null;
    OPEN lc_get_menu_id;
    FETCH lc_get_menu_id into l_dummy;
    IF lc_get_menu_id%NOTFOUND
    THEN
       CLOSE lc_get_menu_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_MENUS_VL');
       fnd_message.set_token('COLUMN', 'MENU_NAME');
       fnd_message.set_token('VALUE', p_menu_name);
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_menu_id;
    END IF;

  --
  -- Validate request_group_name and request_group_app_id only if both
  -- parameters are not null.
  --
    l_dummy := null;

    IF p_request_group_name IS NOT NULL AND
       p_request_group_app_id IS NOT NULL
    THEN
       OPEN lc_get_req_group_id;
       FETCH lc_get_req_group_id into l_dummy;
       IF lc_get_req_group_id%NOTFOUND
       THEN
          CLOSE lc_get_req_group_id;
          fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
          fnd_message.set_token('TABLE', 'FND_REQUEST_GROUPS');
          fnd_message.set_token('COLUMN',
               '(REQUEST_GROUP_NAME, REQUEST_GROUP_APP_ID)');
          fnd_message.set_token('VALUE', p_request_group_name || ', ' ||
                                 to_char(p_request_group_app_id));
          hr_utility.raise_error;
       ELSE
          CLOSE lc_get_req_group_id;
       END IF;
    END IF;
  --
  -- The following is mimicking FNDSCRSP.fmb program unit
  -- FND_CLEAR_REQUEST_GROUP code.
  -- Clear request group
  IF p_request_group_name is null
  THEN
     l_request_group_app_id := null;
  ELSE
     l_request_group_app_id := p_request_group_app_id;
  END IF;
  --
  -- Generate responsibility id
  --
    l_responsibility_id := null;
    OPEN lc_generate_resp_id;
    FETCH lc_generate_resp_id into l_responsibility_id;
    IF lc_generate_resp_id%NOTFOUND
    THEN
       CLOSE lc_generate_resp_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('SEQUENCE', 'FND_RESPONSIBILITY_S');
       fnd_message.set_token('COLUMN', 'RESPONSIBILITY_ID');
       fnd_message.set_token('VALUE', 'NULL');
       hr_utility.raise_error;
    ELSE
       CLOSE lc_generate_resp_id;
    END IF;

  --
  -- Now call the fnd create responsibility api which needs the app short name.
  --
  hr_utility.set_location(l_proc ||
                         ' before fnd_function_security.responsibility', 30);
  --
  fnd_function_security.responsibility
    (responsibility_id          => l_responsibility_id
    ,responsibility_key         => p_resp_key
    ,responsibility_name        => p_resp_name
    ,application                => l_resp_app_short_name
    ,description                => p_resp_description
    ,start_date                 => p_start_date
    ,end_date                   => p_end_date
    ,data_group_name            => p_data_group_name
    ,data_group_application     => l_data_grp_app_short_name
    ,menu_name                  => p_menu_name
    ,request_group_name         => p_request_group_name
    ,request_group_application  => l_req_grp_app_short_name
    ,version                    => p_version
    ,web_host_name              => p_web_host_name
    ,web_agent_name             => p_web_agent_name
   );
--
  p_responsibility_id := l_responsibility_id;

  hr_utility.set_location('Leaving:'||l_proc, 50);

END create_fnd_responsibility;
--
-- ----------------------------------------------------------------------------
-- |-------------------- < create_fnd_user_resp_groups > ----------------------|
-- |NOTE:  No savepoint will be issued here because business support internal  |
-- |       process is not supposed to issue any savepoint or rollback.         |
-- ----------------------------------------------------------------------------
--
PROCEDURE create_fnd_user_resp_groups
  (p_user_id               in fnd_user.user_id%type
  ,p_responsibility_id     in fnd_responsibility.responsibility_id%type
  ,p_application_id        in
                      fnd_user_resp_groups.responsibility_application_id%type
  ,p_sec_group_id          in fnd_user_resp_groups.security_group_id%type
  ,p_start_date            in fnd_user_resp_groups.start_date%type
  ,p_end_date              in fnd_user_resp_groups.end_date%type
                              default null
  ,p_description           in fnd_user_resp_groups.description%type
                              default null
  ) IS
--
CURSOR   lc_get_user_id IS
SELECT   user_id
FROM     fnd_user
WHERE    user_id = p_user_id;
--
CURSOR   lc_get_resp_id IS
SELECT   responsibility_id
FROM     fnd_responsibility
WHERE    responsibility_id = p_responsibility_id;
--
CURSOR   lc_get_app_id IS
SELECT   application_id
FROM     fnd_application
WHERE    application_id = p_application_id;
--
--
CURSOR   lc_unique_user_resp_groups IS
SELECT   user_id
FROM     fnd_user_resp_groups
WHERE    user_id = p_user_id
AND      responsibility_application_id = p_application_id
AND      responsibility_id = p_responsibility_id
AND      security_group_id = p_sec_group_id;

l_proc             varchar2(72) := g_package || 'create_fnd_user_resp_groups';
l_dummy            number default null;
--
BEGIN
  hr_utility.set_location('Entering:' || l_proc, 10);
  --
  -- Validate input parameters first.  We need to validate input parameter
  -- again here because users can just invoke this procedure without calling
  -- create_fnd_user_api first.
  --
  -- Validate user_id
  --
    l_dummy := null;

    OPEN lc_get_user_id;
    FETCH lc_get_user_id into l_dummy;
    IF lc_get_user_id%NOTFOUND
    THEN
       CLOSE lc_get_user_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_USER');
       fnd_message.set_token('COLUMN', 'USER_ID');
       fnd_message.set_token('VALUE', to_char(p_user_id));
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_user_id;
    END IF;
  --
  -- Validate responsibility_id
  --
    l_dummy := null;

    OPEN lc_get_resp_id;
    FETCH lc_get_resp_id into l_dummy;
    IF lc_get_resp_id%NOTFOUND
    THEN
       CLOSE lc_get_resp_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_RESPONSIBILITY');
       fnd_message.set_token('COLUMN', 'RESPONSIBILITY_ID');
       fnd_message.set_token('VALUE', to_char(p_responsibility_id));
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_resp_id;
    END IF;
  --
  -- Validate application_id
  --
    l_dummy := null;

    OPEN lc_get_app_id;
    FETCH lc_get_app_id into l_dummy;
    IF lc_get_app_id%NOTFOUND
    THEN
       CLOSE lc_get_app_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_APPLICATION');
       fnd_message.set_token('COLUMN', 'APPLICATION_ID');
       fnd_message.set_token('VALUE', to_char(p_application_id));
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_app_id;
    END IF;
  --
  -- Validate unique user_resp_groups

  l_dummy := null;

  BEGIN
    OPEN lc_unique_user_resp_groups;
    FETCH lc_unique_user_resp_groups into l_dummy;
    CLOSE lc_unique_user_resp_groups;
    --
    IF l_dummy IS NOT NULL
    THEN
       fnd_message.set_name('FND', 'SECURITY-DUPLICATE USER RESP');
       hr_utility.raise_error;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- It's ok. That means there is no duplicate.
      CLOSE lc_unique_user_resp_groups;
  END;
  --
  -- Validate Start Date cannot be null
  IF p_start_date IS NULL
  THEN
     hr_utility.set_message(800, 'HR_50374_SSL_MAND_START_DATE');
     hr_utility.raise_error;
  END IF;


  -- Validate End Date must be >= Start Date
  IF p_end_date IS NOT NULL
  THEN
     IF p_end_date < nvl(p_start_date, p_end_date + 1)
     THEN
        hr_utility.set_message(800, 'HR_51070_CAU_START_END');
        hr_utility.raise_error;
     END IF;
  END IF;
  --
  -- Now call the fnd_user_resp_groups_api
  --
  hr_utility.set_location(l_proc ||
                  ' before fnd_user_resp_groups_api.insert_assignment', 30);
  --
  fnd_user_resp_groups_api.insert_assignment
    (user_id                        => p_user_id
    ,responsibility_id              => p_responsibility_id
    ,responsibility_application_id  => p_application_id
    ,security_group_id              => p_sec_group_id
    ,start_date                     => p_start_date
    ,end_date                       => p_end_date
    ,description                    => p_description
   );

--
  hr_utility.set_location('Leaving:'||l_proc, 50);

END create_fnd_user_resp_groups;
--
-- ----------------------------------------------------------------------------
-- |---------------------- < create_sec_profile_asg > ------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_sec_profile_asg
  (p_user_id               in fnd_user.user_id%type
  ,p_sec_group_id          in fnd_security_groups.security_group_id%type
  ,p_sec_profile_id        in per_security_profiles.security_profile_id%type
  ,p_resp_key              in fnd_responsibility.responsibility_key%type
  ,p_resp_app_id           in
	per_sec_profile_assignments.responsibility_application_id%type
  ,p_start_date            in per_sec_profile_assignments.start_date%type
  ,p_end_date              in per_sec_profile_assignments.end_date%type
                              default null
  ,p_business_group_id     in per_sec_profile_assignments.business_group_id%type
                              default null
  ) IS
--
--

  CURSOR lc_get_user_id IS
  SELECT user_id
  FROM   fnd_user
  WHERE  user_id = p_user_id;
--
  CURSOR lc_get_sec_group_id IS
  SELECT security_group_id
  FROM   fnd_security_groups
  WHERE  security_group_id = p_sec_group_id;
--
  CURSOR lc_get_sec_profile IS
  SELECT security_profile_id
        ,business_group_id
  FROM   per_security_profiles
  WHERE  security_profile_id = p_sec_profile_id;
--
  CURSOR lc_get_resp_id IS
  SELECT responsibility_id
  FROM   fnd_responsibility
  WHERE  responsibility_key = p_resp_key
  AND    application_id = p_resp_app_id;

  l_bg_id               per_security_profiles.business_group_id%type := null;
  l_resp_id             fnd_responsibility.responsibility_id%type := null;
  l_dummy               number default null;
  l_sec_prof_asg_id
        per_sec_profile_assignments.sec_profile_assignment_id%type := null;
  l_obj_vers_num
        per_sec_profile_assignments.object_version_number%type := null;
  l_proc                varchar2(72) := g_package|| 'create_sec_profile_asg';

BEGIN
  hr_utility.set_location('Entering:' || l_proc, 10);

  -- Validate input parameters first.  We need to validate input parameter
  -- again here because users can just invoke this procedure without calling
  -- fnd_user_acct_api first.
  --
  -- Validate user_id
  --
  l_dummy := null;

    OPEN lc_get_user_id;
    FETCH lc_get_user_id into l_dummy;
    IF lc_get_user_id%NOTFOUND
    THEN
       CLOSE lc_get_user_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_USER');
       fnd_message.set_token('COLUMN', 'USER_ID');
       fnd_message.set_token('VALUE', to_char(p_user_id));
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_user_id;
    END IF;
  --
  -- Validate responsibility_id
  --
    OPEN lc_get_resp_id;
    FETCH lc_get_resp_id into l_resp_id;
    IF lc_get_resp_id%NOTFOUND
    THEN
       CLOSE lc_get_resp_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_RESPONSIBILITY');
       fnd_message.set_token('COLUMN', 'RESPONSIBILITY_KEY');
       fnd_message.set_token('VALUE', p_resp_key);
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_resp_id;
    END IF;
  --
  -- Validate security_group_id
  --
    l_dummy := null;

    OPEN lc_get_sec_group_id;
    FETCH lc_get_sec_group_id into l_dummy;
    IF lc_get_sec_group_id%NOTFOUND
    THEN
       CLOSE lc_get_sec_group_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_SECURITY_GROUPS');
       fnd_message.set_token('COLUMN', 'SECURITY_GROUP_ID');
       fnd_message.set_token('VALUE', to_char(p_sec_group_id));
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_sec_group_id;
    END IF;
  --
  -- Validate security_profile_id
  l_dummy := null;

    OPEN lc_get_sec_profile;
    FETCH lc_get_sec_profile into l_dummy, l_bg_id;
    --
    IF lc_get_sec_profile%NOTFOUND
    THEN
       CLOSE lc_get_sec_profile;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'PER_SECURITY_PROFILES');
       fnd_message.set_token('COLUMN', 'SECURITY_PROFILE_ID');
       fnd_message.set_token('VALUE', to_char(p_sec_profile_id));
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_sec_profile;
    END IF;
  --
  -- Validate Start Date cannot be null
  IF p_start_date IS NULL
  THEN
     hr_utility.set_message(800, 'HR_50374_SSL_MAND_START_DATE');
     hr_utility.raise_error;
  END IF;
  --
  -- Validate End Date must be >= Start Date
  IF p_end_date IS NOT NULL
  THEN
     IF p_end_date < nvl(p_start_date, p_end_date + 1)
     THEN
        hr_utility.set_message(800, 'HR_51070_CAU_START_END');
        hr_utility.raise_error;
     END IF;
  END IF;
  --
  -- Now call the per_asp_ins.ins which will insert a row into
  -- per_sec_profile_assignments as well as fnd_user_resp_groups.
  per_asp_ins.ins
    (p_user_id                      => p_user_id
    ,p_security_group_id            => p_sec_group_id
    ,p_business_group_id            => l_bg_id
    ,p_security_profile_id          => p_sec_profile_id
    ,p_responsibility_id            => l_resp_id
    ,p_responsibility_application_i => p_resp_app_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_sec_profile_assignment_id    => l_sec_prof_asg_id
    ,p_object_version_number        => l_obj_vers_num
    );

--
  hr_utility.set_location('Leaving:'||l_proc, 50);


END create_sec_profile_asg;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------- < create_fnd_profile_values > ----------------------|
-- |NOTE:  No savepoint will be issued here because business support internal  |
-- |       process is not supposed to issue any savepoint or rollback.         |
-- ----------------------------------------------------------------------------
--
PROCEDURE create_fnd_profile_values
   (p_profile_opt_name in fnd_profile_options.profile_option_name%type
   ,p_profile_opt_value in fnd_profile_option_values.profile_option_value%type
   ,p_profile_level_name  in varchar2
   ,p_profile_level_value in fnd_profile_option_values.level_value%type
   ,p_profile_lvl_val_app_id in
       fnd_profile_option_values.level_value_application_id%type  default null
   ,p_profile_value_saved    out nocopy boolean
   )  IS
   --
   --
   CURSOR  lc_get_update_flag
   IS
   SELECT  resp_update_allowed_flag
          ,user_update_allowed_flag
          ,sql_validation
   FROM    fnd_profile_options
   WHERE   profile_option_name = p_profile_opt_name;
   --
   l_resp_update_allowed_flag  fnd_profile_options.resp_update_allowed_flag%type
                               default null;
   l_user_update_allowed_flag  fnd_profile_options.user_update_allowed_flag%type
                               default null;
   l_profile_val_saved         boolean default null;
   l_sql_validation            varchar2(2000) default null;
   l_num_data                  number default null;
   l_varchar2_data             varchar2(2000) default null;
   l_profile_opt_value_valid   boolean default null;
   l_proc                varchar2(72) := g_package||'create_fnd_profile_values';

BEGIN
  hr_utility.set_location('Entering:' || l_proc, 10);
  --
  -- Validate input parameters first.  We need to validate input parameter
  -- again here because users can just invoke this procedure without calling
  -- fnd_user_resp_wrapper first.
  --
  -- Validate profile options to determine if it is updateable
  OPEN lc_get_update_flag;
  FETCH lc_get_update_flag INTO l_resp_update_allowed_flag
                               ,l_user_update_allowed_flag
                               ,l_sql_validation;
  IF lc_get_update_flag%NOTFOUND THEN
     CLOSE lc_get_update_flag;
     fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
     fnd_message.set_token('TABLE', 'FND_PROFILE_OPTIONS');
     fnd_message.set_token('COLUMN', 'PROFILE_OPTION_NAME');
     fnd_message.set_token('VALUE', p_profile_opt_name);
     hr_utility.raise_error;
  END IF;
  --
  CLOSE lc_get_update_flag;

  -- For responsibility level (profile_level_id = 10003), the
  -- resp_update_allowed_flag must be 'Y'.  If not, raise an error.

  IF upper(p_profile_level_name) = 'RESP' AND
     l_resp_update_allowed_flag <> 'Y'
  THEN
     fnd_message.set_name('FND', 'PROFILES- CANT UPDATE');
     hr_utility.raise_error;
  ELSIF upper(p_profile_level_name) = 'USER' AND
     l_user_update_allowed_flag <> 'Y'
  THEN
     fnd_message.set_name('FND', 'PROFILES- CANT UPDATE');
     hr_utility.raise_error;
  END IF;
  --
  IF l_sql_validation IS NOT NULL
  THEN
     l_profile_opt_value_valid := null;
     l_num_data := null;
     l_varchar2_data := null;
     hr_user_acct_internal.validate_profile_opt_value
          (p_profile_opt_name         => p_profile_opt_name
          ,p_profile_opt_value        => p_profile_opt_value
          ,p_profile_level_value      => p_profile_level_value
          ,p_profile_level_name       => p_profile_level_name
          ,p_sql_validation           => l_sql_validation
          ,p_profile_opt_value_valid  => l_profile_opt_value_valid
          ,p_num_data                 => l_num_data
          ,p_varchar2_data            => l_varchar2_data);
  END IF;


  hr_utility.set_location(l_proc || ' before fnd_profile.save', 30);
  --
  IF l_profile_opt_value_valid THEN
     l_profile_val_saved := fnd_profile.save
                         (x_name               => p_profile_opt_name
                         ,x_value              => p_profile_opt_value
                         ,x_level_name         => p_profile_level_name
                         ,x_level_value        => p_profile_level_value
                         ,x_level_value_app_id =>
                                    to_char(p_profile_lvl_val_app_id)
                         );

  ELSE
     IF upper(p_profile_level_name) = 'RESP'
     THEN
        fnd_message.set_name('PER', 'HR_PROFILE_VAL_NOT_ADDED');
        fnd_message.set_token('RESP_ID', p_profile_level_value);
     ELSIF upper(p_profile_level_name) = 'USER'
     THEN
        fnd_message.set_name('PER', 'HR_PROFILE_USER_VAL_NOT_ADDED');
     END IF;

     fnd_message.set_token('PROFILE_OPTION_NAME', p_profile_opt_name);
     fnd_message.set_token('PROFILE_OPTION_VALUE', p_profile_opt_value);

     hr_utility.raise_error;
  END IF;

/*
  --
  -- In R11.5, not sure if the PER_BUSINESS_GROUP_ID is set to be not
  -- updateable in both RESP and USER Level.  It looks like it is updateable in
  -- the seed 11.5 database. The following code to derive the profile option
  -- value from PER_SECURITY_PROFILE_ID is commented out.
  IF l_profile_val_saved
  AND p_profile_opt_name = 'PER_SECURITY_PROFILE_ID'
  THEN
     -- Use the Business Group Id derived from the security profile to set
     -- the PER_BUSINESS_GROUP_ID profile option.
     l_profile_val_saved := null;
     l_profile_val_saved := fnd_profile.save
                         (x_name               => 'PER_BUSINESS_GROUP_ID'
                         ,x_value              => to_char(l_num_data)
                         ,x_level_name         => p_profile_level_name
                         ,x_level_value        => p_profile_level_value
                         ,x_level_value_app_id =>
                                    to_char(p_profile_lvl_val_app_id)
                         );
  END IF;

*/

  p_profile_value_saved := l_profile_val_saved;

  hr_utility.set_location('Leaving:'||l_proc, 50);


END create_fnd_profile_values;

-- ----------------------------------------------------------------------------
-- |--------------------- < validate_profile_opt_value > ----------------------|
-- | Validate profile options which use SQL validation.  The SQL validation    |
-- | will be hard coded here for a given profile option name because there is  |
-- | no pl/sql parser to parse the SQL statement.                              |
-- |                                                                           |
-- | OUTPUT:                                                                   |
-- |   p_profile_opt_value_valid - boolean, indicating whether the value is    |
-- |                               valid or not after validation.              |
-- |   p_num_data - number, not always has a value in this output. This is to  |
-- |                save another database call if certain values can be        |
-- |                retrieved while validating the profile option value. For   |
-- |                example, PER_SECURITY_PROFILE_ID, the business group id can|
-- |                be derived while running the sql to validate the security  |
-- |                profile id.                                                |
-- |   p_varchar2_data - varchar2, not always has a value in this output. This |
-- |                is to save another database call if certain values can be  |
-- |                retrieved while validating the profile option value. See   |
-- |                p_num_data above.                                          |
-- ----------------------------------------------------------------------------
--  There are only 21 profile options (application_id between 800 and 899)
--  which use SQL validation at the time of coding (May 2000) in R11.5 and the
--  options are updateable at either Responsibility or User level.
--  Profile Option Name                 Validation Table
--  ---------------------------------   ----------------------------------------
--  DATETRACK:DATE_SECURITY             FND_COMMON_LOOKUPS where lookup_type =
--                                       'DATETRACK:DATE_SECURITY'
--
--  DATETRACK:SESSION_DATE_WARNING      FND_COMMON_LOOKUPS where lookup_type =
--                                       'DATETRACK:SESSION_DATE_WARNING'
--
--  HR:EXECUTE_LEG_FORMULA              fnd_lookups where lookup_type ='YES_NO'
--
--  HR_DISPLAY_PERSON_SEARCH            fnd_lookups where lookup_type ='YES_NO'
--
--  HR_DISPLAY_SKILLS                   FND_COMMON_LOOKUPS where lookup_type =
--                                       'YES_NO'
--
--  HR_ELE_ENTRY_PURGE_CONTROL          hr_lookups where lookup_type =
--                                        'HR_ELE_ENTRY_PURGE_CONTROL'
--
--  HR_OTF_UPDATE_METHOD                hr_lookups where lookup_type =
--                                        'PAY_US_OTF_UPDATE_METHODS'
--
--  HR_TIPS_TEST_MODE                   FND_COMMON_LOOKUPS where lookup_type =
--                                       'YES_NO'
--
--  HR_USER_TYPE                        FND_COMMON_LOOKUPS where lookup_type =
--                                       'HR_USER_TYPE'
--
--  OTA_AUTO_WAITLIST_BOOKING_STATUS    ota_booking_status and
--                                      hr_all_organization_units
--
--  OTA_PA_INTEGRATION                  fnd_lookups where lookup_type ='YES_NO'
--
--  PER_ABSENCE_DURATION_AUTO_OVERWRITE FND_COMMON_LOOKUPS where lookup_type =
--                                       'YES_NO'
--
--  PER_ATTACHMENT_USAGE                fnd_lookups where lookup_type ='YES_NO'
--
--  PER_BUSINESS_GROUP_ID               per_business_groups
--
--  PER_DEFAULT_CORRESPONDENCE_LANGUAGE fnd_languages
--
--  PER_DEFAULT_NATIONALITY             FND_COMMON_LOOKUPS where lookup_type =
--                                       'NATIONALITY'
--
--  PER_NI_UNIQUE_ERROR_WARNING         fnd_common_lookups where lookup_type =
--                                       NI_UNIQUE_ERROR_WARNING'
--
--  PER_OAB_NEW_BENEFITS_MODEL          fnd_lookups where lookup_type ='YES_NO'
--
--  PER_QUERY_ONLY_MODE                 fnd_lookups where lookup_type ='YES_NO'
--
--  PER_SECURITY_PROFILE_ID             PER_SECURITY_PROFILES and
--                                      HR_ALL_ORGANIZATION_UNITS
--
--  VIEW_UNPUBLISHED_360_SELF_APPR      FND_COMMON_LOOKUPS where lookup_type =
--                                       'YES_NO'
--
--  *** The following options are not updateable in Responsibility or User
--      level in Seed11.5 db as of May 2000 ***
--  DATETRACK: DELETE_MODE
--  DATETRACK: ENABLED
--  DATETRACK: OVERRIDE_MODE
--  DATETRACK: UPDATE_MODE
--  HR_CROSS_BUSINESS_GROUP
--  HR_DM_BG_LOCKOUT
--  HR_PAYROLL_CONTACT_SOURCE
--  OTA_AUTO_WAITLIST_ACTIVE
--  OTA_WAITLIST_SORT_CRITERIA
--  PAY_USER_FF_PTO
--
--  *** The following options are not found in Seed11.5 db as of May 2000 ***
--  HR_PAYROLL_CURRENCY_RATES           pay_payrolls_f and per_business_groups
--  HR:EXECUTE_LEG_FORMULA              fnd_lookups where lookup_type ='YES_NO'
--  HR:COST_MAND_SEG_CHECK              fnd_lookups where lookup_type ='YES_NO'
--  HR_BG_LOCATIONS                     FND_COMMON_LOOKUPS where lookup_type =
--                                       'YES_NO'
--  HR_BIS_REPORTING_HIERARCHY          PER_ORGANIZATION_STRUCTURES_V
--
-- --------------------------------------------------------------------------
--  Update for Fix 2288014 Start.
--  Following are new profile options (application_id between 800 and 899)
--  which use SQL validation at the time of coding (May 2002) in R11.5 and the
--  options are updateable at either Responsibility or User level.
--  This list is obtained from SEED115.
--  Non-HR profile options are not used for validation.
--
--  Profile Option Name                   Validation Table
--  ---------------------------------     -----------------------------
-- OM_DEFAULT_ENROLLMENT_CANCELLED_STATUS OTA_BOOKING_STATUS_TYPES
-- PER_NATIONAL_IDENTIFIER_VALIDATION     HR_LOOKUPS
-- OM_DEFAULT_EVENT_CENTER		  HR_LOOKUPS
-- OM_DEFAULT_EVENT_SYSTEM_STATUS         HR_LOOKUPS
-- OM_DEFAULT_EVENT_USER_STATUS           HR_LOOKUPS
-- HR_TAX_LOCATION_CHANGE                 FND_LOOKUPS
-- OTA_SSHR_AUTO_GL_TRANSFER              FND_LOOKUPS
-- BEN_NEW_USER_RESP_PROFILE              FND_RESPONSIBILITY_TL,
--                                         FND_RESPONSIBILITY
-- BEN_USER_TO_ORG_LINK                   HR_ALL_ORGANIZATION_UNITS,
--                                         HR_ALL_ORGANIZATION_UNITS_TL
-- OTA_HR_GLOBAL_BUSINESS_GROUP_ID       PER_BUSINESS_GROUPS
-- HR_DISPLAY_ALL_OFFERS                 FND_LOOKUPS
-- HR_MONITOR_BALANCE_RETRIEVAL		 FND_LOOKUPS
-- HR_CANCEL_APPLICATION		 FND_LOOKUPS
-- HR_BLANK_EFFECTIVE_DATE		 FND_LOOKUPS
-- HR_SSHR_LOCALIZATION			 FND_LOOKUPS
-- HR_USE_GRADE_DEFAULTS		 FND_LOOKUPS
-- HR_OVERRIDE_GRADE_DEFAULTS		 FND_LOOKUPS
-- NL_DISPLAY_MESSAGE			 FND_LOOKUPS
-- PAY_PPM_MULTI_ASSIGNMENT_ENABLE	 FND_LOOKUPS
-- HR_ACTIONS_VALIDATION		 FND_COMMON_LOOKUPS
-- OTA_DEFAULT_EVENT_OWNER		 PER_ALL_PEOPLE_F,
--                                        HR_ALL_ORGANIZATION_UNITS,
--                                        HR_ALL_ORGANIZATION_UNITS,
--                                        PER_ALL_ASSIGNMENTS_F
-- HR_USE_HIRE_MGR_APPR_CHAIN		 FND_LOOKUPS
-- OTA_DEFAULT_EVENT_CENTER		 HR_ALL_ORGANIZATION_UNITS,
--                                        HR_ORGANIZATION_INFORMATION,
--                                        HR_ALL_ORGANIZATION_UNITS
-- HR_NL_JOB_LEVEL_PROFILE		 FND_LOOKUP_VALUES
-- BEN_USER_TO_PAYROLL_LINK		 PAY_ALL_PAYROLLS_F
-- HR_BIS_REPORTING_HIERARCHY		 PER_ORGANIZATION_STRUCTURES_V,
--                                        PER_BUSINESS_GROUPS
-- HR_PERINFO_CHECK_PENDING		 FND_LOOKUPS
-- HR_SELF_SERV_SAVEFORLATER		 FND_COMMON_LOOKUPS
-- PAY_FR_CHECK_MANDATORY_ASG_ATTRIBUTES FND_LOOKUPS
-- HR:COST_MAND_SEG_CHECK		 FND_LOOKUPS
-- HR_MANAGER_ACTIONS_MENU		 FND_MENUS_VL
-- HR_PERSONAL_ACTIONS_MENU		 FND_MENUS_VL
-- PER_AUTO_EVAL_ENTITLEMENTS		 FND_LOOKUPS
-- PER_CHECK_ENTITLEMENT_CACHE		 FND_LOOKUPS
-- PER_AUTO_APPLY_ENTITLEMENTS		 FND_LOOKUPS
-- PER_CAGR_LOG_DETAIL			 FND_COMMON_LOOKUPS
-- HR_NL_ETHNICITY_PROFILE		 FND_LOOKUP_VALUES
-- BEN_CWB_PREFERRED_CURRENCY		 FND_CURRENCIES_VL
-- OTA_ILEARNING_DEFAULT_ACTIVITY	 OTA_ACTIVITY_DEFINITIONS,
--                                        HR_ALL_ORGANIZATION_UNITS
-- BEN_DSG_NO_CHG			 FND_LOOKUPS
-- HR_RESTRICT_X_BUSINESS_TRAN		 FND_LOOKUPS
-- HR_ALLOW_MULTIPLE_ASSIGNMENTS	 FND_LOOKUPS
-- HR_NL_FULL_NAME_PROFILE		 FND_LOOKUP_VALUES
-- OTA_ILEARNING_DEFAULT_ATTENDED	 OTA_BOOKING_STATUS_TYPES,
--                                        HR_ALL_ORGANIZATION_UNITS
-- HR_APPRAISAL_TEMPLATE_LOV		 FND_LOOKUPS
-- OTA_OM_RESTRICT_ENR_BY_COUNTRY	 FND_LOOKUPS
-- HR_AUTHORIA_ENABLED			 FND_LOOKUPS
-- HXC_TIMEKEEPER_OVERRIDE		 HR_LOOKUPS
-- IMC_VIS_SOL_TYPE			 FND_LOOKUP_VALUES_VL
-- IRC_DEFAULT_COUNTRY			 FND_TERRITORIES_VL
--  Update for Fix 2288014 End.
-- Bug 2825757 : Added validation for ICX_LANGUAGE
-- ----------------------------------------------------------------------------
--
PROCEDURE validate_profile_opt_value
   (p_profile_opt_name         in fnd_profile_options.profile_option_name%type
   ,p_profile_opt_value        in
                           fnd_profile_option_values.profile_option_value%type
   ,p_profile_level_name       in varchar2
   ,p_profile_level_value      in fnd_profile_option_values.level_value%type
   ,p_sql_validation           in fnd_profile_options.sql_validation%type
   ,p_profile_opt_value_valid  out nocopy boolean
   ,p_num_data                 out nocopy number
   ,p_varchar2_data            out nocopy varchar2
   ) IS
 --
 --
 -- FND_COMMON_LOOKUPS
 -- NOTE: Since the lookup_type is a unique key and is mandatory, we don't
 --       need to compare the application id.  This will make the cursor more
 --       generic.
 --
 CURSOR  lc_get_fnd_cmn_lkups (p_lookup_type   in varchar2) IS
 SELECT  lookup_code
        ,meaning
 FROM    fnd_common_lookups
 WHERE   lookup_type = p_lookup_type;

 -- FND_LOOKUPS
 -- NOTE: Since the lookup_type is a unique key and is mandatory, we don't
 --       need to compare the application id.  This will make the cursor more
 --       generic.
 --
 CURSOR  lc_get_fnd_lkups (p_lookup_type   in varchar2) IS
 SELECT  lookup_code
        ,meaning
 FROM    fnd_lookups
 WHERE   lookup_type = p_lookup_type;

 -- HR_LOOKUPS
 -- NOTE: Since the lookup_type is a unique key and is mandatory, we don't
 --       need to compare the application id.  This will make the cursor more
 --       generic.
 --
 CURSOR  lc_get_hr_lkups (p_lookup_type   in varchar2) IS
 SELECT  lookup_code
        ,meaning
 FROM    hr_lookups
 WHERE   lookup_type = p_lookup_type;

 -- FND_LOOKUP_VALUES
 -- NOTE: Since the lookup_type is a unique key and is mandatory, we don't
 --       need to compare the application id.  This will make the cursor more
 --       generic.
 --
 CURSOR  lc_get_fnd_lkup_val (p_lookup_type   in varchar2) IS
 SELECT  lookup_code
        ,meaning
 FROM    fnd_lookup_values
 WHERE   lookup_type = p_lookup_type;

 -- OTA_AUTO_WAITLIST_BOOKING_STATUS
 CURSOR lc_get_bkg_status IS
 SELECT bst.name                    booking_status
       ,bst.booking_status_type_id
       ,org.name                    org_name
 FROM   ota_booking_status_types  bst
       ,hr_organization_units  org
 WHERE  bst.business_group_id = org.organization_id
 AND    bst.type in ('A', 'P')
 ORDER BY org.name;

 -- PER_BUSINESS_GROUP_ID
 CURSOR lc_get_bg_id  IS
 SELECT name
       ,business_group_id
 FROM   per_business_groups;

 -- PER_DEFAULT_CORRESPONDENCE_LANGUAGE
 CURSOR lc_get_def_lang IS
 SELECT initcap(NLS_LANGUAGE)
       ,language_code
 FROM   fnd_languages
 ORDER BY        1;


 -- Since customers must need to supply the internal id instead of the name
 -- for profile option value, the ORDER BY clause will be ordered by id instead
 -- of name.
 -- PER_SECURITY_PROFILE_ID
 CURSOR  lc_get_security_profile  IS
 SELECT  s.security_profile_name
        ,s.security_profile_id
        ,s.business_group_id
        ,o.name
 FROM    per_security_profiles      s
        ,hr_all_organization_units  o
 WHERE   o.business_group_id = s.business_group_id
 AND     o.organization_id = o.business_group_id
 ORDER BY s.security_profile_id;

 -- HR_PAYROLL_CURRENCY_RATES
 CURSOR  lc_get_pay_curr_rates IS
 SELECT  pay.payroll_name
        ,pay.payroll_id
        ,per.name
 FROM    pay_payrolls_f   pay
        ,per_business_groups per
 WHERE   pay.business_group_id = per.business_group_id
 AND     sysdate between effective_start_date and effective_end_date
 ORDER BY pay.payroll_id;

 -- Fix 2288014 start
 -- Generic cursors are already defined for validations using
 -- fnd_lookups , hr_lookups, fnd_lookup_values and fnd_common_lookups.
 -- Define cursors for profile option validations

-- OM_DEFAULT_ENROLLMENT_CANCELLED_STATUS

 CURSOR lc_get_enroll_cancel_sts IS
  SELECT BST.NAME visible_option_value , BST.BOOKING_STATUS_TYPE_ID profile_option_value
  from ota_booking_status_types bst,
  hr_all_organization_units org
  where bst.business_group_id = org.organization_id
  and bst.type = 'C' order by org.name, bst.name;


 -- BEN_NEW_USER_RESP_PROFILE
 CURSOR lc_get_new_usr_resp_profl IS
 SELECT L.RESPONSIBILITY_NAME visible_option_value ,TO_CHAR(L.RESPONSIBILITY_ID)|| TO_CHAR(L.APPLICATION_ID) profile_option_value
 FROM FND_RESPONSIBILITY_TL L,
 FND_RESPONSIBILITY R
 WHERE R.RESPONSIBILITY_ID = L.RESPONSIBILITY_ID
 AND R.APPLICATION_ID = L.APPLICATION_ID
 AND L.LANGUAGE = USERENV('LANG')
 AND R.APPLICATION_ID = 805;


 -- BEN_USER_TO_ORG_LINK
 CURSOR lc_get_usr_org_lnk IS
 SELECT HAO.NAME visible_option_value,HAO.ORGANIZATION_ID profile_option_value
 FROM HR_ALL_ORGANIZATION_UNITS HAO,
 HR_ALL_ORGANIZATION_UNITS_TL HAOTL
 WHERE HAO.ORGANIZATION_ID = HAOTL.ORGANIZATION_ID
 AND HAOTL.LANGUAGE = USERENV('LANG')
 AND SYSDATE BETWEEN HAO.DATE_FROM
 AND NVL(HAO.DATE_TO,SYSDATE)
 ORDER BY HAO.NAME;


 --OTA_HR_GLOBAL_BUSINESS_GROUP_ID
 CURSOR lc_get_glbl_bd_id IS
 SELECT NAME visible_option_value, BUSINESS_GROUP_ID profile_option_value
 FROM   PER_BUSINESS_GROUPS;


 -- OTA_DEFAULT_EVENT_OWNER
 CURSOR lc_get_def_envt_ownr IS
 SELECT P.FULL_NAME visible_option_value,P.PERSON_ID profile_option_value
 FROM PER_ALL_PEOPLE_F P,HR_ALL_ORGANIZATION_UNITS O,HR_ALL_ORGANIZATION_UNITS BG,
 PER_ALL_ASSIGNMENTS_F A
 WHERE P.PERSON_ID = A.PERSON_ID AND
 O.ORGANIZATION_ID = A.ORGANIZATION_ID AND
 O.BUSINESS_GROUP_ID = BG.ORGANIZATION_ID AND
 A.PRIMARY_FLAG = 'Y' AND
 (TRUNC(SYSDATE) BETWEEN
 P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE) AND
 (TRUNC(SYSDATE) BETWEEN
 A.EFFECTIVE_START_DATE AND A.EFFECTIVE_END_DATE);



 -- OTA_DEFAULT_EVENT_CENTER
 CURSOR lc_get_def_evnt_cntr IS
 SELECT ORG.NAME visible_option_value, ORG.ORGANIZATION_ID profile_option_value
 FROM HR_ALL_ORGANIZATION_UNITS ORG,HR_ORGANIZATION_INFORMATION ORI,HR_ALL_ORGANIZATION_UNITS BG
 WHERE ORG.ORGANIZATION_ID = ORI.ORGANIZATION_ID
 AND   ORG.BUSINESS_GROUP_ID = BG.ORGANIZATION_ID
 AND ORI.ORG_INFORMATION_CONTEXT = 'CLASS'
 AND ORI.ORG_INFORMATION1 ='OTA_TC'
 AND ORI.ORG_INFORMATION2= 'Y';


 -- BEN_USER_TO_PAYROLL_LINK
 CURSOR lc_get_usr_payroll_lnk IS
 SELECT PPF.PAYROLL_NAME visible_option_value ,PPF.PAYROLL_ID profile_option_value
 FROM PAY_PAYROLLS_F PPF
 WHERE SYSDATE BETWEEN PPF.EFFECTIVE_START_DATE
 AND PPF.EFFECTIVE_END_DATE
 AND NVL( PPF.PAYROLL_TYPE, 'PAYROLL' ) <> 'BENEFIT'
 ORDER BY PPF.PAYROLL_NAME;


 --HR_BIS_REPORTING_HIERARCHY
 CURSOR lc_get_bis_rep_hierarchy IS
 SELECT OST.NAME visible_option_value,
 	    OST.ORGANIZATION_STRUCTURE_ID profile_option_value
      FROM   PER_ORGANIZATION_STRUCTURES_V OST,
 	    PER_BUSINESS_GROUPS ORG
      WHERE  OST.BUSINESS_GROUP_ID = ORG.BUSINESS_GROUP_ID
      ORDER  BY OST.NAME;



 -- HR_MANAGER_ACTIONS_MENU
 CURSOR lc_get_mgr_actns_menu IS
 SELECT user_menu_name visible_option_value , menu_name profile_option_value
 FROM fnd_menus_vl
 ORDER BY user_menu_name;


 -- HR_PERSONAL_ACTIONS_MENU
 CURSOR lc_get_pers_actns_menu IS
 SELECT user_menu_name visible_option_value , menu_name profile_option_value
 FROM fnd_menus_vl
 ORDER BY user_menu_name;


 -- BEN_CWB_PREFERRED_CURRENCY
 CURSOR lc_get_pref_cur IS
 Select name , currency_code  profile_option_value
 FROM fnd_currencies_vl WHERE enabled_flag='Y';

 -- OTA_ILEARNING_DEFAULT_ACTIVITY
 CURSOR lc_get_ilearn_def_act IS
 SELECT
/*+ INDEX(tad OTA_ACTIVITY_DEFINITIONS_FK1) */
 TAD.NAME visible_option_value ,TAD.ACTIVITY_ID profile_option_value
 from ota_activity_definitions tad,
 hr_all_organization_units org
 where tad.business_group_id = org.organization_id
 order by org.name,tad.name;


 -- OTA_ILEARNING_DEFAULT_ATTENDED
 CURSOR lc_get_ilearn_def_atnd IS
 SELECT BST.NAME visible_option_value ,BST.BOOKING_STATUS_TYPE_ID profile_option_value
 from ota_booking_status_types bst,
 hr_all_organization_units org
 where bst.business_group_id = org.organization_id
 and bst.type in ('A') order by org.name,bst.name;


  -- IRC_DEFAULT_COUNTRY
 CURSOR lc_get_irc_def_cntry IS
 SELECT TERRITORY_SHORT_NAME visible_option_value, TERRITORY_CODE profile_option_value
 FROM FND_TERRITORIES_VL
 ORDER BY TERRITORY_SHORT_NAME;

 -- Bug 2825757 : Added validation for ICX_LANGUAGE

 CURSOR lc_get_icx_lang IS
 SELECT DESCRIPTION visible_option_value, NLS_LANGUAGE profile_option_value
 FROM FND_LANGUAGES_VL WHERE INSTALLED_FLAG IN ('B','I')
 ORDER BY DESCRIPTION;

-- Fix 2288014 End

 --

 l_sql_validation    fnd_profile_options.sql_validation%type default null;
 l_num_data          number default null;
 l_varchar2_data     varchar2(2000) default null;
 l_lookup_type       varchar2(2000) default null;
 l_opt_value_valid   boolean default null;
 l_lookup_type_start number default null;
 l_lookup_type_end   number default null;
 l_proc              varchar2(30) default 'validate_profile_opt_value';

BEGIN
  hr_utility.set_location('Entering:' || l_proc, 10);

  -- For those sql validations against FND_COMMON_LOOKUPS, or FND_LOOKUPS
  -- the validation is always against the lookup_code.  So, we don't need to
  -- hard code the validation.  But we need to first find out if the validation
  -- uses lookup table or not.
  --
  l_opt_value_valid := null;
  l_sql_validation := upper(p_sql_validation);
  l_num_data := null;
  l_varchar2_data := null;
  --
  IF instr(l_sql_validation, 'FND_COMMON_LOOKUPS') > 0
     OR instr(l_sql_validation, 'FND_LOOKUPS') > 0
     OR instr(l_sql_validation, 'HR_LOOKUPS') > 0
     OR instr(l_sql_validation, 'FND_LOOKUP_VALUES') > 0
  THEN
     -- Extract the string starting from the where clause to the end of the
     -- statement
     -- E.g. "where l.lookup_type = 'HR_USER_TYPE' and ...."
     l_lookup_type := substr(l_sql_validation
                            ,instr(l_sql_validation,'WHERE'));

     -- Now extract the string starting from the word lookup_type.
     -- E.g. "lookup_type = 'HR_USER_TYPE' and ...."
     l_lookup_type := substr(l_lookup_type
                            ,instr(l_lookup_type, 'LOOKUP_TYPE'));

     -- Now extract the lookup type.
     l_lookup_type_start := instr(l_lookup_type, '''', 1) + 1;
     l_lookup_type_end := instr(l_lookup_type, '''', 1, 2);

     l_lookup_type := substr(l_lookup_type
                            ,l_lookup_type_start
                            ,l_lookup_type_end - l_lookup_type_start);



     -- Now we can call the cursor
     IF instr(l_sql_validation, 'FND_COMMON_LOOKUPS') > 0
     THEN
        FOR get_lkup_code IN lc_get_fnd_cmn_lkups(p_lookup_type =>l_lookup_type)
        LOOP
            IF get_lkup_code.lookup_code = p_profile_opt_value
            THEN
               l_opt_value_valid := true;
            END IF;
        END LOOP;
     --
     ELSIF instr(l_sql_validation, 'FND_LOOKUPS') > 0
     THEN
        FOR get_lkup_code IN lc_get_fnd_lkups(p_lookup_type =>l_lookup_type)
        LOOP
            IF get_lkup_code.lookup_code = p_profile_opt_value
            THEN
               l_opt_value_valid := true;
            END IF;
        END LOOP;
     --
     ELSIF instr(l_sql_validation, 'FND_LOOKUP_VALUES') > 0
     THEN
        FOR get_lkup_code IN lc_get_fnd_lkup_val (p_lookup_type =>l_lookup_type)
        LOOP
            IF get_lkup_code.lookup_code = p_profile_opt_value
            THEN
               l_opt_value_valid := true;
            END IF;
        END LOOP;
     --
     ELSIF instr(l_sql_validation, 'HR_LOOKUPS') > 0
     THEN
        FOR get_lkup_code IN lc_get_hr_lkups(p_lookup_type =>l_lookup_type)
        LOOP
            IF get_lkup_code.lookup_code = p_profile_opt_value
            THEN
               l_opt_value_valid := true;
            END IF;
        END LOOP;
     END IF;
     --
  ELSE
     null;
  END IF;  -- end if statment for checking lookups

--
--
  IF upper(p_profile_opt_name) = 'PER_SECURITY_PROFILE_ID'
  THEN
     FOR get_sec_profile in lc_get_security_profile
     LOOP
       IF get_sec_profile.security_profile_id = to_number(p_profile_opt_value)
       THEN
          l_opt_value_valid := true;
          l_num_data := get_sec_profile.business_group_id;


       END IF;
     END LOOP;
  ELSIF upper(p_profile_opt_name) = 'HR_PAYROLL_CURRENCY_RATES'
  THEN
     FOR get_curr_rates in lc_get_pay_curr_rates
     LOOP
       IF get_curr_rates.payroll_id = to_number(p_profile_opt_value)
       THEN
          l_opt_value_valid := true;
       END IF;
     END LOOP;
  ELSIF upper(p_profile_opt_name) = 'OTA_AUTO_WAITLIST_BOOKING_STATUS'
  THEN
     FOR get_booking_status in lc_get_bkg_status
     LOOP
       IF get_booking_status.booking_status_type_id =
          to_number(p_profile_opt_value)
       THEN
          l_opt_value_valid := true;
       END IF;
     END LOOP;
  ELSIF upper(p_profile_opt_name) = 'PER_BUSINESS_GROUP_ID'
  THEN
     For get_bg_id in lc_get_bg_id
     LOOP
       IF get_bg_id.business_group_id = to_number(p_profile_opt_value)
       THEN
          l_opt_value_valid := true;
       END IF;
     END LOOP;
  ELSIF upper(p_profile_opt_name) = 'PER_DEFAULT_CORRESPONDENCE_LANGUAGE'
  THEN
     For get_language_code in lc_get_def_lang
     LOOP
       IF get_language_code.language_code = p_profile_opt_value
       THEN
          l_opt_value_valid := true;
       END IF;
     END LOOP;
 -- 2288014 start.
  ELSIF upper(p_profile_opt_name) = 'OM_DEFAULT_ENROLLMENT_CANCELLED_STATUS' THEN
    FOR get_enroll_cancel_sts in lc_get_enroll_cancel_sts
     LOOP
       IF get_enroll_cancel_sts.profile_option_value = p_profile_opt_value
          THEN
             l_opt_value_valid := true;
          END IF;
     END LOOP;
   ELSIF upper(p_profile_opt_name) = 'BEN_NEW_USER_RESP_PROFILE' THEN
    FOR get_new_usr_resp_profl IN lc_get_new_usr_resp_profl
     LOOP
               IF get_new_usr_resp_profl.profile_option_value =  p_profile_opt_value
                   THEN
                      l_opt_value_valid := true;
                   END IF;
    END LOOP;
   ELSIF upper(p_profile_opt_name) = 'BEN_USER_TO_ORG_LINK' THEN
    FOR get_usr_org_lnk IN lc_get_usr_org_lnk
     LOOP
            IF get_usr_org_lnk.profile_option_value =  p_profile_opt_value
            THEN
              l_opt_value_valid := true;
            END IF;
    END LOOP;


   ELSIF upper(p_profile_opt_name) = 'OTA_HR_GLOBAL_BUSINESS_GROUP_ID' THEN
    FOR get_glbl_bd_id IN lc_get_glbl_bd_id
     LOOP
              IF get_glbl_bd_id.profile_option_value =  p_profile_opt_value
              THEN
                l_opt_value_valid := true;
              END IF;
    END LOOP;
   ELSIF upper(p_profile_opt_name) = 'OTA_DEFAULT_EVENT_OWNER' THEN
    FOR get_def_envt_ownr IN lc_get_def_envt_ownr
       LOOP
               IF get_def_envt_ownr.profile_option_value =  p_profile_opt_value
               THEN
                 l_opt_value_valid := true;
               END IF;
    END LOOP;
   ELSIF upper(p_profile_opt_name) = 'OTA_DEFAULT_EVENT_CENTER' THEN
    FOR get_def_evnt_cntr IN lc_get_def_evnt_cntr
       LOOP
               IF get_def_evnt_cntr.profile_option_value =  p_profile_opt_value
               THEN
                 l_opt_value_valid := true;
               END IF;
    END LOOP;
   ELSIF upper(p_profile_opt_name) = 'BEN_USER_TO_PAYROLL_LINK' THEN
    FOR get_usr_payroll_lnk IN lc_get_usr_payroll_lnk
       LOOP
               IF get_usr_payroll_lnk.profile_option_value =  p_profile_opt_value
               THEN
                 l_opt_value_valid := true;
               END IF;
    END LOOP;

   ELSIF upper(p_profile_opt_name) = 'HR_BIS_REPORTING_HIERARCHY' THEN
    FOR get_bis_rep_hierarchy IN lc_get_bis_rep_hierarchy
       LOOP
               IF get_bis_rep_hierarchy.profile_option_value =  p_profile_opt_value
               THEN
                 l_opt_value_valid := true;
               END IF;
    END LOOP;
   ELSIF upper(p_profile_opt_name) = 'HR_MANAGER_ACTIONS_MENU' THEN
    FOR get_mgr_actns_menu IN lc_get_mgr_actns_menu
       LOOP
               IF get_mgr_actns_menu.profile_option_value =  p_profile_opt_value
               THEN
                 l_opt_value_valid := true;
               END IF;
    END LOOP;
   ELSIF upper(p_profile_opt_name) = 'HR_PERSONAL_ACTIONS_MENU' THEN
    FOR get_pers_actns_menu IN lc_get_pers_actns_menu
       LOOP
               IF get_pers_actns_menu.profile_option_value =  p_profile_opt_value
               THEN
                 l_opt_value_valid := true;
               END IF;
    END LOOP;
   ELSIF upper(p_profile_opt_name) = 'BEN_CWB_PREFERRED_CURRENCY' THEN
    FOR get_pref_cur IN lc_get_pref_cur
       LOOP
               IF get_pref_cur.profile_option_value =  p_profile_opt_value
               THEN
                 l_opt_value_valid := true;
               END IF;
    END LOOP;
   ELSIF upper(p_profile_opt_name) = 'OTA_ILEARNING_DEFAULT_ACTIVITY' THEN
    FOR get_ilearn_def_act IN lc_get_ilearn_def_act
       LOOP
               IF get_ilearn_def_act.profile_option_value =  p_profile_opt_value
               THEN
                 l_opt_value_valid := true;
               END IF;
    END LOOP;
   ELSIF upper(p_profile_opt_name) = 'OTA_ILEARNING_DEFAULT_ATTENDED' THEN
    FOR get_ilearn_def_atnd IN lc_get_ilearn_def_atnd
       LOOP
               IF get_ilearn_def_atnd.profile_option_value =  p_profile_opt_value
               THEN
                 l_opt_value_valid := true;
               END IF;
    END LOOP;
   ELSIF upper(p_profile_opt_name) = 'IRC_DEFAULT_COUNTRY' THEN
    FOR get_irc_def_cntry IN lc_get_irc_def_cntry
       LOOP
               IF get_irc_def_cntry.profile_option_value =  p_profile_opt_value
               THEN
                 l_opt_value_valid := true;
               END IF;

    END LOOP;
    -- Fix 2288014 End.
   ELSIF upper(p_profile_opt_name) = 'ICX_LANGUAGE' THEN
        FOR get_icx_lang IN lc_get_icx_lang
            LOOP
                    IF get_icx_lang.profile_option_value =  p_profile_opt_value
                    THEN
                      l_opt_value_valid := true;
                    END IF;
     END LOOP; -- Bug 2825757 : Added validation for ICX_LANGUAGE
 --
  ELSE
     null;
  END IF;

--

  IF l_opt_value_valid
  THEN
     p_profile_opt_value_valid := l_opt_value_valid;
     hr_utility.set_location('profile opt value is valid', 19);
  ELSE
     p_profile_opt_value_valid := false;
     hr_utility.set_location('profile opt value is invalid', 19);
  END IF;

  p_num_data := l_num_data;
  p_varchar2_data := l_varchar2_data;

  hr_utility.set_location('Leaving:' || l_proc, 50);

EXCEPTION
  WHEN OTHERS THEN
     IF upper(p_profile_level_name) = 'RESP'
     THEN
        fnd_message.set_name('PER', 'HR_PROFILE_VAL_NOT_ADDED');
        fnd_message.set_token('RESP_ID', p_profile_level_value);
     ELSIF upper(p_profile_level_name) = 'USER'
     THEN
        fnd_message.set_name('PER', 'HR_PROFILE_USER_VAL_NOT_ADDED');
     END IF;

     fnd_message.set_token('PROFILE_OPTION_NAME', p_profile_opt_name);
     fnd_message.set_token('PROFILE_OPTION_VALUE', p_profile_opt_value);
     hr_utility.raise_error;


END validate_profile_opt_value;
--
-- ----------------------------------------------------------------------------
-- |----------------------- < build_resp_profile_val > -----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE build_resp_profile_val
          (p_template_resp_id      in fnd_responsibility.responsibility_id%type
                                      default null
          ,p_template_resp_app_id  in fnd_responsibility.application_id%type
                                      default null
          ,p_new_resp_key          in fnd_responsibility.responsibility_key%type
          ,p_new_resp_app_id       in fnd_responsibility.application_id%type
          ,p_fnd_profile_opt_val_tbl in
                    hr_user_acct_utility.fnd_profile_opt_val_tbl
          ,p_out_profile_opt_val_tbl out
                    hr_user_acct_utility.fnd_profile_opt_val_tbl
          )  IS
--
--
-- Derive profile option values from the template responsibility id
  CURSOR  lc_get_resp_lvl_profile_val IS
  SELECT  fpv.profile_option_id
         ,fpv.profile_option_value
         ,fp.profile_option_name
  FROM    fnd_profile_options        fp
         ,fnd_profile_option_values  fpv
  WHERE   fpv.profile_option_id = fp.profile_option_id
  AND     fpv.level_id = 10003
  AND     fpv.level_value = p_template_resp_id
  AND     fpv.level_value_application_id = p_template_resp_app_id;


  l_prof_opt_val_tbl     hr_user_acct_utility.fnd_profile_opt_val_tbl;
  l_found_sw             boolean default false;
  l_index                binary_integer := 0;
  l_count                number default 0;
  l_proc                 varchar2(72) := g_package||'build_resp_profile_val';
--
BEGIN
  --
  hr_utility.set_location('Entering:' || l_proc, 10);
  --
  -- Now copy the p_fnd_profile_opt_val_tbl to the local table for output
  -- Only copy the profile option values for the passed in responsibility.
  FOR i in 1..p_fnd_profile_opt_val_tbl.count
  LOOP
      IF p_fnd_profile_opt_val_tbl(i).profile_level_name = 'RESP'
         AND
         p_fnd_profile_opt_val_tbl(i).profile_level_value = p_new_resp_key
         AND
         p_fnd_profile_opt_val_tbl(i).profile_level_value_app_id =
         p_new_resp_app_id
      THEN
         l_index := l_index + 1;
         l_prof_opt_val_tbl(l_index).profile_option_name :=
             p_fnd_profile_opt_val_tbl(i).profile_option_name;
         l_prof_opt_val_tbl(l_index).profile_option_value :=
             p_fnd_profile_opt_val_tbl(i).profile_option_value;
         l_prof_opt_val_tbl(l_index).profile_level_name :=
             p_fnd_profile_opt_val_tbl(i).profile_level_name;
         l_prof_opt_val_tbl(l_index).profile_level_value :=
             p_fnd_profile_opt_val_tbl(i).profile_level_value;
         l_prof_opt_val_tbl(l_index).profile_level_value_app_id :=
             p_fnd_profile_opt_val_tbl(i).profile_level_value_app_id;
      END IF;
  END LOOP;


  IF p_template_resp_id IS NOT NULL AND p_template_resp_app_id IS NOT NULL
  THEN
     -- get the profile opt values for the passed in template resp id
     -- and only copy into the l_prof_opt_val_tbl if it does not exist already
     FOR get_prof_values in lc_get_resp_lvl_profile_val
     LOOP
         l_found_sw := false;
         l_count := l_prof_opt_val_tbl.count;
         FOR i in 1..l_count
         LOOP
            IF l_prof_opt_val_tbl(i).profile_option_name =
               get_prof_values.profile_option_name
               AND
               l_prof_opt_val_tbl(i).profile_level_name = 'RESP'
            THEN
               l_found_sw := true;
            END IF;
         END LOOP;
         --
         IF l_found_sw
         THEN
            -- there is already an overwrite, don't move to the new table
            null;
         ELSE
            -- Add this profile opt value to the resp level
            l_prof_opt_val_tbl(l_count + 1).profile_option_name :=
              get_prof_values.profile_option_name ;
            l_prof_opt_val_tbl(l_count + 1).profile_option_value :=
              get_prof_values.profile_option_value;
            l_prof_opt_val_tbl(l_count + 1).profile_level_name := 'RESP';
            l_prof_opt_val_tbl(l_count + 1).profile_level_value :=
              p_new_resp_key;
            l_prof_opt_val_tbl(l_count + 1).profile_level_value_app_id :=
              p_new_resp_app_id;
         END IF;
     END LOOP;
     --
  END IF;

  p_out_profile_opt_val_tbl := l_prof_opt_val_tbl;

  hr_utility.set_location('Leaving:' || l_proc, 50);
--
EXCEPTION
  WHEN others THEN
       hr_utility.set_message(800, 'HR_BUILD_PROFILE_VAL_ERR');
       hr_utility.raise_error;

END build_resp_profile_val;
--
-- ----------------------------------------------------------------------------
-- |-------------------- < build_func_sec_exclusion_rules > -------------------|
-- ----------------------------------------------------------------------------
PROCEDURE build_func_sec_exclusion_rules
   (p_func_sec_excl_tbl   in hr_user_acct_utility.fnd_resp_functions_tbl
   ,p_out_func_sec_excl_tbl out nocopy hr_user_acct_utility.func_sec_excl_tbl)
  IS
--
  CURSOR lc_get_resp_id (p_resp_key in
                         fnd_responsibility.responsibility_key%TYPE)
  IS
  SELECT   application_id, responsibility_id
  FROM     fnd_responsibility
  WHERE    responsibility_key = p_resp_key;
--
  CURSOR lc_get_resp_func (p_resp_id in
                              fnd_responsibility.responsibility_id%TYPE
                          ,p_app_id  in
                              fnd_responsibility.application_id%TYPE)
  IS
  SELECT   action_id, rule_type
  FROM     fnd_resp_functions
  WHERE    application_id = p_app_id
  AND      responsibility_id = p_resp_id;
--

  CURSOR lc_get_function_name (p_func_id in fnd_form_functions.function_id%TYPE)
  IS
  SELECT   function_name
  FROM     fnd_form_functions
  WHERE    function_id = p_func_id;
--
  CURSOR lc_get_menu_name (p_menu_id in fnd_menus.menu_id%TYPE)
  IS
  SELECT   menu_name
  FROM     fnd_menus
  WHERE    menu_id = p_menu_id;
--
--
  l_proc                      varchar2(72) := g_package ||
                                              'build_func_sec_exclusion_rules';
  l_resp_rec                  lc_get_resp_id%rowtype;
  l_resp_func_rec             lc_get_resp_func%rowtype;
  l_index                     binary_integer default 0;
  l_func_sec_excl_tbl_count   integer default 0;
  l_out_func_sec_excl_tbl     hr_user_acct_utility.func_sec_excl_tbl;
  l_rule_name                 fnd_menus.menu_name%type;
  l_func_sec_excl_err         exception;
--
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 11);

  l_func_sec_excl_tbl_count := p_func_sec_excl_tbl.count;
  --
  FOR i in 1..l_func_sec_excl_tbl_count
  LOOP
     IF p_func_sec_excl_tbl(i).existing_resp_key IS NOT NULL AND
        p_func_sec_excl_tbl(i).new_resp_key IS NOT NULL
     THEN
        -- read the existing responsibility
        -- First check that the application_id and responsibility_id have
        -- already been read in the previous entry of the table.
        IF i > 1 AND
           (p_func_sec_excl_tbl(i).existing_resp_key =
            p_func_sec_excl_tbl(i - 1).existing_resp_key  AND
            p_func_sec_excl_tbl(i).new_resp_key =
            p_func_sec_excl_tbl(i - 1).new_resp_key)
        THEN
           -- no need to read the responsibility record because it's already
           -- been read in the previous entry.
           null;
        ELSE
           FOR get_resp_rec in lc_get_resp_id
               (p_resp_key => p_func_sec_excl_tbl(i).existing_resp_key)
           LOOP
              l_resp_rec.application_id := get_resp_rec.application_id;
              l_resp_rec.responsibility_id := get_resp_rec.responsibility_id;
           END LOOP;
        END IF;
        --
        -- load the output table with the template responsibility's function
        -- security exclusion rules.
        FOR get_resp_func_rec in lc_get_resp_func
            (p_resp_id => l_resp_rec.responsibility_id
            ,p_app_id  => l_resp_rec.application_id)
        LOOP
           l_resp_func_rec.action_id := get_resp_func_rec.action_id;
           l_resp_func_rec.rule_type := get_resp_func_rec.rule_type;
           --
           IF l_resp_func_rec.rule_type = 'F'
           THEN
              -- derive the function_name from fnd_form_functions
              OPEN lc_get_function_name
                   (p_func_id => l_resp_func_rec.action_id);
              FETCH lc_get_function_name into l_rule_name;
              IF lc_get_function_name%NOTFOUND
              THEN
                 -- raise an error
                 CLOSE lc_get_function_name;
                 raise l_func_sec_excl_err;
              ELSE
                 CLOSE lc_get_function_name;
              END IF;
           ELSE
              -- derive the menu_name from fnd_menus
              OPEN lc_get_menu_name
                   (p_menu_id => l_resp_func_rec.action_id);
              FETCH lc_get_menu_name into l_rule_name;
              IF lc_get_menu_name%NOTFOUND
              THEN
                 -- raise an error
                 CLOSE lc_get_menu_name;
                 raise l_func_sec_excl_err;
              ELSE
                 CLOSE lc_get_menu_name;
              END IF;
           END IF;
           --
           l_index := l_index + 1;
           l_out_func_sec_excl_tbl(l_index).resp_key :=
              p_func_sec_excl_tbl(i).new_resp_key;
           l_out_func_sec_excl_tbl(l_index).rule_type :=
              l_resp_func_rec.rule_type;
           l_out_func_sec_excl_tbl(l_index).rule_name := l_rule_name;
           l_out_func_sec_excl_tbl(l_index).delete_flag := 'N';
        END LOOP;  -- end loop of lc_get_resp_func
        --
     ELSIF p_func_sec_excl_tbl(i).new_resp_key IS NOT NULL
     THEN
        -- it's a new func security exclusion rule, use as is
        l_index := l_index + 1;
        l_out_func_sec_excl_tbl(l_index).resp_key :=
              p_func_sec_excl_tbl(i).new_resp_key;
        l_out_func_sec_excl_tbl(l_index).rule_type :=
              p_func_sec_excl_tbl(i).rule_type;
        l_out_func_sec_excl_tbl(l_index).rule_name :=
              p_func_sec_excl_tbl(i).rule_name;
        l_out_func_sec_excl_tbl(l_index).delete_flag := 'N';
     ELSE
        null;
     END IF;
     --
  END LOOP;
--
  p_out_func_sec_excl_tbl := l_out_func_sec_excl_tbl;
--
  hr_utility.set_location('Leaving:'|| l_proc, 15);
--
--
EXCEPTION
    WHEN l_func_sec_excl_err THEN
       hr_utility.set_message(800, 'HR_BUILD_FUNC_EXCL_RULE_ERR');
       hr_utility.raise_error;
--
--
    WHEN others THEN
       hr_utility.set_message(800, 'HR_BUILD_FUNC_EXCL_RULE_ERR');
       hr_utility.raise_error;
--
END build_func_sec_exclusion_rules;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------- < create_fnd_resp_functions > -----------------------|
-- |NOTE:  No savepoint will be issued here because business support internal  |
-- |       process is not supposed to issue any savepoint or rollback.         |
-- ----------------------------------------------------------------------------
--
PROCEDURE create_fnd_resp_functions
            (p_resp_key           in fnd_responsibility.responsibility_key%type
            ,p_rule_type          in fnd_resp_functions.rule_type%type
            ,p_rule_name          in varchar2
            ,p_delete_flag        in varchar2 default 'N')
   IS
--
  CURSOR lc_get_resp_id
  IS
  SELECT   responsibility_id
  FROM     fnd_responsibility
  WHERE    responsibility_key = p_resp_key;
--
  CURSOR lc_get_function_id
  IS
  SELECT   function_id
  FROM     fnd_form_functions
  WHERE    function_name = p_rule_name;
--
  CURSOR lc_get_menu_id
  IS
  SELECT   menu_id
  FROM     fnd_menus
  WHERE    menu_name = p_rule_name;
--
  l_proc                      varchar2(72) := g_package ||
                                              'create_fnd_resp_functions';

  l_temp_id         number default null;
--
--
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- FND API does not validate or throw an exception.  So, do validations here
-- instead of build_func_sec_exclusion_rules because users might call this
-- procedure directly and thus bypass the build_func_sec_exclusion_rules
-- procedure.
--
-- Validate that p_resp_key exists
   OPEN lc_get_resp_id;
   FETCH lc_get_resp_id into l_temp_id;
   IF lc_get_resp_id%NOTFOUND
   THEN
      CLOSE lc_get_resp_id;
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_RESPONSIBILITY');
      fnd_message.set_token('COLUMN', 'RESPONSIBILITY_KEY');
      fnd_message.set_token('VALUE', p_resp_key);

      hr_utility.set_message(800, 'HR_INVALID_RESP_KEY');
      hr_utility.raise_error;
   ELSE
      CLOSE lc_get_resp_id;
   END IF;
--
-- Validate that rule_type can have the values of 'F' or 'M' only.
   IF p_rule_type = 'F' OR p_rule_type = 'M'
   THEN
      NULL;
   ELSE
      hr_utility.set_message(800, 'HR_INVALID_SEC_EXCL_RULE_TYPE');
      hr_utility.raise_error;
   END IF;
--
-- Validate rule_name
   IF p_rule_type = 'F'
   THEN
      OPEN lc_get_function_id;
      FETCH lc_get_function_id into l_temp_id;
      IF lc_get_function_id%NOTFOUND
      THEN
         CLOSE lc_get_function_id;
         hr_utility.set_message(800, 'HR_INVALID_SEC_EXCL_FUNC_NAME');
         hr_utility.raise_error;
      ELSE
         CLOSE lc_get_function_id;
      END IF;
   ELSIF p_rule_type = 'M'
   THEN
      OPEN lc_get_menu_id;
      FETCH lc_get_menu_id into l_temp_id;
      IF lc_get_menu_id%NOTFOUND
      THEN
         CLOSE lc_get_menu_id;
         hr_utility.set_message(800, 'HR_INVALID_SEC_EXCL_MENU_NAME');
         hr_utility.raise_error;
      ELSE
         CLOSE lc_get_menu_id;
      END IF;
   ELSE
      hr_utility.set_message(800, 'HR_INVALID_SEC_EXCL_RULE_NAME');
      hr_utility.raise_error;
   END IF;
--
   fnd_function_security.security_rule
      (responsibility_key  => p_resp_key
      ,rule_type           => p_rule_type
      ,rule_name           => p_rule_name
      ,delete_flag         => p_delete_flag);
--
--
  hr_utility.set_location('Leaving:'|| l_proc, 50);
--
--
END create_fnd_resp_functions;
--
-- ----------------------------------------------------------------------------
-- |-------------------------- < update_fnd_user > ----------------------------|
-- |NOTE:  No savepoint will be issued here because business support internal  |
-- |       process is not supposed to issue any savepoint or rollback.         |
-- ----------------------------------------------------------------------------
--
PROCEDURE update_fnd_user
  (p_user_id               in number
  ,p_old_password          in varchar2 default hr_api.g_varchar2
  ,p_new_password          in varchar2 default hr_api.g_varchar2
  ,p_end_date              in date default hr_api.g_date
  ,p_email_address         in varchar2 default hr_api.g_varchar2
  ,p_fax                   in varchar2 default hr_api.g_varchar2
  ,p_known_as              in varchar2 default hr_api.g_varchar2
  ,p_language              in varchar2 default hr_api.g_varchar2
  ,p_host_port             in varchar2 default hr_api.g_varchar2
  ,p_employee_id           in number default hr_api.g_number
  ,p_customer_id           in number default hr_api.g_number
  ,p_supplier_id           in number default hr_api.g_number
  ) IS

  --
  CURSOR  lc_get_user_data
  IS
  SELECT  *
  FROM    fnd_user
  WHERE   user_id = p_user_Id;
  --
  l_proc                     varchar2(72) := g_package||'update_fnd_user';
  l_user_data                fnd_user%rowtype;
  l_old_password             fnd_user.encrypted_user_password%type
                           default null;
  -- The new un-encrypted password cannot exceed a length of 30, which
  -- is what is allowed in forms.
  l_new_password             varchar2(30) default null;
  l_end_date                 date default null;
  l_host_port                varchar2(32000) default null;
  l_pos                      number default 0;
  l_count                    number default 0;
  l_email_address            fnd_user.email_address%type default null;
  l_fax                      fnd_user.fax%type default null;
  l_description              fnd_user.description%type default null;
  l_language                 varchar2(32000) default null;
  l_employee_id              number default null ; -- Fix 2951145
  l_customer_id              number default null ; -- Fix 2951145
  l_supplier_id              number default null ; -- Fix 2951145
  l_return_status            varchar2(32000) default null;
  l_msg_count                number default 0;
  l_msg_data                 varchar2(32000) default null;
  l_last_updated_by          number default null;
  l_last_update_login        number default null;
  l_app_short_name           varchar2(200) default null;
  l_msg_name                 fnd_new_messages.message_name%type  default null;
  --
  l_user_name             VARCHAR2(80);    -- Fix  2288014
  --

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validate input parameters first, need to convert hr_api default
  -- value to fnd's api default value.
  IF p_old_password = hr_api.g_varchar2
  THEN
     l_old_password := null ; -- Fix 2951145
  ELSE
     l_old_password := p_old_password;
  END IF;
  --
  OPEN lc_get_user_data;
  FETCH lc_get_user_data INTO l_user_data;
  IF lc_get_user_data%NOTFOUND
  THEN

     CLOSE lc_get_user_data;
     fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
     fnd_message.set_token('TABLE', 'FND_USER');
     fnd_message.set_token('COLUMN', 'USER_ID');
     fnd_message.set_token('VALUE', p_user_id);
     hr_utility.raise_error;
  ELSE
     CLOSE lc_get_user_data;
  END IF;
  --
  -- Validate p_user_end_date.  If entered, it must be larger than start_date
  IF p_end_date = hr_api.g_date
  THEN
     l_end_date := null ; -- Fix 2951145
  ELSE
     IF nvl(p_end_date, hr_api.g_eot) >= l_user_data.start_date
     THEN
        l_end_date := p_end_date;
     ELSE
        hr_utility.set_message(800, 'HR_51070_CAU_START_END');
        hr_utility.raise_error;
     END IF;
  END IF;
  --
  -- Validate host_port
  IF p_host_port = hr_api.g_varchar2
  THEN
     l_host_port := null ; -- Fix 2951145
  ELSE
     l_host_port := p_host_port;
  END IF;
  --
  -- Validate email address length
  IF p_email_address = hr_api.g_varchar2
  THEN
     l_email_address := null ; -- Fix 2951145
  ELSE
     IF length(p_email_address) > g_max_email_address_length
     THEN
        hr_utility.set_message(800, 'HR_INVALID_EMAIL_ADDR_LENGTH');
        hr_utility.raise_error;
     ELSE
        l_email_address := p_email_address;
     END IF;
  END IF;
  --
  -- Validate fax length
  IF p_fax = hr_api.g_varchar2
  THEN
     l_fax := null ; -- Fix 2951145
  ELSE
     IF length(p_fax) > g_max_fax_length
     THEN
        hr_utility.set_message(800, 'HR_INVALID_FAX_LENGTH');
        hr_utility.raise_error;
     ELSE
        l_fax := p_fax;
     END IF;
  END IF;
  --
  IF p_language = hr_api.g_varchar2
  THEN
     l_language := null ; -- Fix 2951145
  ELSE
     l_language := p_language;
  END IF;
  --
  IF p_employee_id = hr_api.g_number
  THEN
     l_employee_id := null ; -- Fix 2951145
  ELSE
     -- Check for employee id if it exists
     SELECT  count(1)
     INTO    l_count
     FROM    per_all_people_f
     WHERE   person_id = p_employee_id;

     IF l_count <= 0
     THEN
        hr_utility.set_message(800, 'HR_INVALLID_EMP_ID');
        hr_utility.raise_error;
     ELSE
        l_employee_id := p_employee_id;
     END IF;
  END IF;
  --
  -- We won't do validation of Customer Id and Supplier Id because we don't
  -- know what we are supposed to validate.

  -- The following is mimicking FNDSCAUS.fmb program unit fnd_encrypt_pwd.
  -- Check password length.  The minimum password length can be set via a
  -- profile option.  If that profile option is null, the default is 5.
  --
  l_count := 0;
  l_count := to_number(
             nvl(fnd_profile.value('SIGNON_PASSWORD_LENGTH'), '5')
                      );

  IF p_new_password = hr_api.g_varchar2
  THEN
     l_new_password := null ; -- Fix 2951145
  ELSIF (length(p_new_password) < l_count)
  THEN
     fnd_message.set_name('FND', 'PASSWORD-LONGER');
     fnd_message.set_token('LENGTH', to_char(l_count));
     hr_utility.raise_error;
  ELSIF (length(p_new_password) > 30)
  THEN
     hr_utility.set_message(800, 'HR_USER_PASSWORD_TOO_LONG');
     hr_utility.raise_error;
  ELSE
     l_new_password := p_new_password;
  END IF;
  --
  --
  -----------------------------------------------------------------------------
  -- Set fnd last_updated_by and last_update_login columns
  -----------------------------------------------------------------------------
  l_last_updated_by := fnd_global.user_id;
  IF l_last_updated_by IS NULL
  THEN
     l_last_updated_by := -1;
  END IF;
  --
  l_last_update_login := fnd_global.login_id;
  IF l_last_update_login IS NULL
  THEN
     l_last_update_login := -1;
  END IF;
  --
  -- Now, we're ready to call fnd api to update a user account.
  --
  hr_utility.set_location (l_proc || ' before fnd_user_pkg.UpdateUser', 30);
  --
 -- Fix  2288014 Start

   select user_name into l_user_name from fnd_user
   where user_id = p_user_id;


   fnd_user_pkg.UpdateUser (
       x_user_name =>           l_user_name,
       x_owner =>               '',
       x_unencrypted_password =>l_new_password,
       x_description =>         l_description,
--       x_last_logon_date =>     sysdate, -- for BUG 7116804
       x_end_date =>            l_end_date,
       x_employee_id =>         l_employee_id,
       x_email_address =>       l_email_address,
       x_fax	       =>	l_fax,
       x_customer_id =>         l_customer_id,
       x_supplier_id =>         l_supplier_id
       );

  --
  hr_utility.set_location('Leaving:' || l_proc, 70);
  --

EXCEPTION
WHEN OTHERS THEN
  hr_utility.raise_error;

  -- Fix  2288014 End

END update_fnd_user;
--
-- ----------------------------------------------------------------------------
-- |-------------------- < update_fnd_user_resp_groups > ----------------------|
-- |NOTE:  No savepoint will be issued here because business support internal  |
-- |       process is not supposed to issue any savepoint or rollback.         |
-- ----------------------------------------------------------------------------
--
PROCEDURE update_fnd_user_resp_groups
  (p_user_id               in number
  ,p_responsibility_id     in number
  ,p_resp_application_id   in number
  ,p_security_group_id     in fnd_user_resp_groups.security_group_id%type
  ,p_start_date            in date default hr_api.g_date
  ,p_end_date              in date default hr_api.g_date
  ,p_description           in varchar2 default hr_api.g_varchar2
  ) IS
--
CURSOR   lc_get_user_id IS
SELECT   user_id
FROM     fnd_user
WHERE    user_id = p_user_id;
--
CURSOR   lc_get_resp_id_n_key IS
SELECT   responsibility_id
        ,responsibility_key
FROM     fnd_responsibility
WHERE    responsibility_id = p_responsibility_id;
--
CURSOR   lc_get_app_id IS
SELECT   application_id
FROM     fnd_application
WHERE    application_id = p_resp_application_id;
--
-- When ENABLED_SECURITY_GROUPS profile option = 'N', then the
-- fnd_user_resp_groups should function like R11 fnd_user_responsibility, the
-- security_group_id is 0 and there should not be more than 1 row for the
-- combination of user_id, responsibility_id, application_id and
-- security_group_id.

CURSOR   lc_unique_user_resp IS
SELECT   count(*)
FROM     fnd_user_resp_groups
WHERE    user_id = p_user_id
AND      responsibility_id = p_responsibility_id
AND      responsibility_application_id = p_resp_application_id
AND      security_group_id = p_security_group_id;

CURSOR   lc_user_resp_row IS
SELECT   responsibility_application_id
        ,responsibility_id
        ,start_date
        ,end_date
        ,description
FROM     fnd_user_resp_groups
WHERE    user_id = p_user_id
AND      responsibility_id = p_responsibility_id
AND      responsibility_application_id = p_resp_application_id
AND      security_group_id = p_security_group_id;

CURSOR   lc_user_resp_direct_row IS
SELECT   responsibility_application_id
        ,responsibility_id
        ,start_date
        ,end_date
        ,description
FROM     fnd_user_resp_groups_direct
WHERE    user_id = p_user_id
AND      responsibility_id = p_responsibility_id
AND      responsibility_application_id = p_resp_application_id
AND      security_group_id = p_security_group_id;

l_proc             varchar2(72) := g_package||'update_fnd_user_resp_groups';
l_count            number default null;
l_dummy            number default null;
l_start_date       date default null;
l_end_date         date default null;
l_description      fnd_user_resp_groups.description%type default null;
l_resp_key         fnd_responsibility.responsibility_key%type default null;
l_fnd_user_resp_data  lc_user_resp_row%rowtype;
--
BEGIN
  hr_utility.set_location('Entering:' || l_proc, 10);
  --
  -- Validate input parameters first.  We need to validate input parameter
  -- again here because users can just invoke this procedure without calling
  -- fnd_user_acct_api first.
  --
  -- Validate user_id
  --
    l_dummy := null;

    OPEN lc_get_user_id;
    FETCH lc_get_user_id into l_dummy;
    IF lc_get_user_id%NOTFOUND
    THEN
       CLOSE lc_get_user_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_USER');
       fnd_message.set_token('COLUMN', 'USER_ID');
       fnd_message.set_token('VALUE', to_char(p_user_id));
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_user_id;
    END IF;

  --
  -- Validate responsibility_id
  --
    l_dummy := null;

    OPEN lc_get_resp_id_n_key;
    FETCH lc_get_resp_id_n_key into l_dummy, l_resp_key;
    IF lc_get_resp_id_n_key%NOTFOUND
    THEN
       CLOSE lc_get_resp_id_n_key;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_RESPONSIBILITY');
       fnd_message.set_token('COLUMN', 'RESPONSIBILITY_ID');
       fnd_message.set_token('VALUE', to_char(p_responsibility_id));
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_resp_id_n_key;
    END IF;

  --
  -- Validate application_id
  --
    l_dummy := null;

    OPEN lc_get_app_id;
    FETCH lc_get_app_id into l_dummy;
    IF lc_get_app_id%NOTFOUND
    THEN
       CLOSE lc_get_app_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_APPLICATION');
       fnd_message.set_token('COLUMN', 'APPLICATION_ID');
       fnd_message.set_token('VALUE', to_char(p_resp_application_id));
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_app_id;
    END IF;
  --
  -- Validate unique user_resp_groups
  -- The following code is copied from FNDSCAUS.fmb program unit
  -- FND_UNIQUE_USER_RESP.
  --
    l_dummy := null;

  BEGIN
    OPEN lc_unique_user_resp;
    FETCH lc_unique_user_resp into l_dummy;
    CLOSE lc_unique_user_resp;
    --
    IF l_dummy > 1
    THEN
       fnd_message.set_name('FND', 'SECURITY-DUPLICATE USER RESP');
       hr_utility.raise_error;
    ELSIF l_dummy = 0 OR l_dummy IS NULL
    THEN
	/*
		Bug fix 8582264
		When 2 responsibilities have same responsibility_id , but different
		application_ids and one of those responsibility is end dated, l_dummy
		will be 0
	*/
       NULL;
/*
       CLOSE lc_unique_user_resp;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_USER_RESP_GROUPS');
       fnd_message.set_token('COLUMN', 'USER_ID');
       fnd_message.set_token('VALUE', to_char(p_user_id));
       hr_utility.raise_error;
*/
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- It's an error, the user responsibility record must exist before
      -- this program is invoked.
--      CLOSE lc_unique_user_resp;
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_USER_RESP_GROUPS');
      fnd_message.set_token('COLUMN', 'USER_ID');
      fnd_message.set_token('VALUE', to_char(p_user_id));
      hr_utility.raise_error;
  END;
  --
  -- Bug #1341128 Fix
  -- Get existing fnd_user_resp_groups data
	/*
		Bug fix 8582264
		When 2 responsibilities have same responsibility_id , but different
		application_ids and one of those responsibility is end dated, l_dummy
		will be 0. In this case, we will fetch the data from
		FND_USER_RESP_GROUPS_DIRECT instead of FND_USER_RESP_GROUPS
	*/

	IF l_dummy = 0 OR l_dummy IS NULL THEN
	  OPEN lc_user_resp_direct_row;
	  FETCH lc_user_resp_direct_row into l_fnd_user_resp_data;
	  CLOSE lc_user_resp_direct_row;
	ELSE
	  OPEN lc_user_resp_row;
	  FETCH lc_user_resp_row into l_fnd_user_resp_data;
	  CLOSE lc_user_resp_row;
	END IF;

  -- Convert hr_api default values to null values
  IF p_start_date = hr_api.g_date
  THEN
     l_start_date := l_fnd_user_resp_data.start_date;
  ELSE
     l_start_date := p_start_date;
  END IF;

  -- Validate End Date must be >= Start Date
  IF p_end_date = hr_api.g_date
  THEN
     l_end_date := l_fnd_user_resp_data.end_date;
  ELSIF p_end_date IS NULL
  THEN
     l_end_date := p_end_date;
  ELSE
     -- End Date is not null
     l_end_date := p_end_date;
     --
     -- IF Start Date is null, then it's an error
     IF l_end_date  < nvl(l_start_date, l_end_date + 1)
     THEN
        fnd_message.set_name('PER', 'HR_RESP_START_END_DATE');
        fnd_message.set_token('RESP_ID', to_char(p_responsibility_id));
        fnd_message.set_token('USER_ID', to_char(p_user_id));
        hr_utility.raise_error;
     END IF;
  END IF;
  --
  IF p_description = hr_api.g_varchar2
  THEN
     l_description := l_fnd_user_resp_data.description;
  ELSE
     l_description := p_description;
  END IF;
  --
  --
  -- Now call the fnd_user_resp_groups_api
  --
  hr_utility.set_location(l_proc ||
                    ' before fnd_user_resp_groups_api.update_assignment', 30);
hr_utility.set_location(l_proc || ' Passing p_user_id=' || p_user_id , 31);
  hr_utility.set_location(l_proc || ' Security_group_id=' || p_security_group_id ,32);
  --
  fnd_user_resp_groups_api.update_assignment
    (user_id                  => p_user_id
    ,responsibility_id        => p_responsibility_id
    ,responsibility_application_id  => p_resp_application_id
    ,security_group_id        =>p_security_group_id -- Fix 2978610
    ,start_date               => l_start_date
    ,end_date                 => l_end_date
    ,description              => l_description
   );
--
--
hr_utility.set_location('Leaving:'||l_proc, 50);

END update_fnd_user_resp_groups;
--
-- ----------------------------------------------------------------------------
-- |---------------------- < update_sec_profile_asg > ------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_sec_profile_asg
  (p_sec_profile_asg_id    in
      per_sec_profile_assignments.sec_profile_assignment_id%type default null
  ,p_user_id               in fnd_user.user_id%type default null
  ,p_responsibility_id     in per_sec_profile_assignments.responsibility_id%type
                              default null
  ,p_resp_app_id           in
    per_sec_profile_assignments.responsibility_application_id%type default null
  ,p_security_group_id     in fnd_user_resp_groups.security_group_id%type
                              default null
  ,p_start_date            in per_sec_profile_assignments.start_date%type
                              default null
  ,p_end_date              in per_sec_profile_assignments.end_date%type
                              default null
  ,p_object_version_number in
      per_sec_profile_assignments.object_version_number%type   default null
  )  IS
--
--

  CURSOR lc_get_user_id IS
  SELECT user_id
  FROM   fnd_user
  WHERE  user_id = p_user_id;
--
--
  CURSOR lc_get_sec_profile_asg_id IS
  SELECT sec_profile_assignment_id
	   ,security_group_id
        ,business_group_id
  FROM   per_sec_profile_assignments
  WHERE  user_id = p_user_id
  AND    responsibility_id = p_responsibility_id
  AND    responsibility_application_id = p_resp_app_id
  AND    security_group_id = p_security_group_id;
--
  CURSOR lc_get_resp_id IS
  SELECT responsibility_key
  FROM   fnd_responsibility
  WHERE  responsibility_id = p_responsibility_id
  AND    application_id = p_resp_app_id;

  l_dummy               number default null;
  l_resp_key            fnd_responsibility.responsibility_key%type default null;
  l_sec_prof_asg_id
        per_sec_profile_assignments.sec_profile_assignment_id%type := null;
  l_security_group_id   per_sec_profile_assignments.security_group_id%type
				    default null;
  l_bg_id               per_sec_profile_assignments.business_group_id%type
				    default null;
  l_obj_vers_num
        per_sec_profile_assignments.object_version_number%type := null;
  l_proc                varchar2(72) := g_package|| 'update_sec_profile_asg';

BEGIN
  hr_utility.set_location('Entering:' || l_proc, 10);
  --
  IF p_sec_profile_asg_id IS NOT NULL
  THEN
     l_sec_prof_asg_id := p_sec_profile_asg_id;
     l_obj_vers_num := p_object_version_number;
  END IF;

  -- Validate input parameters first.  We need to validate input parameter
  -- again here because users can just invoke this procedure without calling
  -- fnd_user_acct_api first.
  --
  -- Validate user_id
  --
  l_dummy := null;

  IF p_user_id IS NOT NULL
  THEN
     OPEN lc_get_user_id;
     FETCH lc_get_user_id into l_dummy;
     IF lc_get_user_id%NOTFOUND
     THEN
       CLOSE lc_get_user_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_USER');
       fnd_message.set_token('COLUMN', 'USER_ID');
       fnd_message.set_token('VALUE', to_char(p_user_id));
       hr_utility.raise_error;
     ELSE
       CLOSE lc_get_user_id;
     END IF;
  END IF;
  --
  -- Validate responsibility_id
  --
  IF p_responsibility_id IS NOT NULL
  THEN
     OPEN lc_get_resp_id;
     FETCH lc_get_resp_id into l_resp_key;
     IF lc_get_resp_id%NOTFOUND
     THEN
        CLOSE lc_get_resp_id;
        fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
        fnd_message.set_token('TABLE', 'FND_RESPONSIBILITY');
        fnd_message.set_token('COLUMN', 'RESPONSIBILITY_ID');
        fnd_message.set_token('VALUE', p_responsibility_id);
        hr_utility.raise_error;
     ELSE
       CLOSE lc_get_resp_id;
    END IF;
  END IF;
  --
  -- Get sec_profile_assignment_id for a given user and responsibility
  --

  IF p_user_id IS NOT NULL AND
     p_responsibility_id IS NOT NULL
  THEN
    OPEN lc_get_sec_profile_asg_id;
    FETCH lc_get_sec_profile_asg_id into l_sec_prof_asg_id
	 ,l_security_group_id
	 ,l_bg_id;
    IF lc_get_sec_profile_asg_id%NOTFOUND
    THEN
       CLOSE lc_get_sec_profile_asg_id;
       hr_utility.set_message(800, 'PER_52524_ASP_ASN_NOT_EXISTS');
       hr_utility.raise_error;
    ELSE
       CLOSE lc_get_sec_profile_asg_id;
    END IF;
  END IF;
  --
  -- Validate Start Date cannot be null
  IF p_start_date IS NULL AND p_sec_profile_asg_id IS NULL
     -- IF p_sec_profile_asg_id is not supplied, then caller must supply
     -- all the parameters, including p_start_date.
  THEN
     hr_utility.set_message(800, 'HR_50374_SSL_MAND_START_DATE');
     hr_utility.raise_error;
  END IF;
  --
  -- Validate End Date must be >= Start Date
  IF p_end_date IS NOT NULL
  THEN
       IF p_end_date < nvl(p_start_date, p_end_date + 1)
       THEN
          fnd_message.set_name('PER', 'HR_RESP_START_END_DATE');
          fnd_message.set_token('RESP_ID', to_char(p_responsibility_id));
          fnd_message.set_token('USER_ID', to_char(p_user_id));
          hr_utility.raise_error;
       END IF;
  END IF;
  --
  --
  -- Now call the per_asp_upd.upd which will update a row in
  -- per_sec_profile_assignments as well as fnd_user_resp_groups.
  --
  per_asp_upd.upd
    (p_sec_profile_assignment_id    => l_sec_prof_asg_id
    ,p_object_version_number        => l_obj_vers_num
    ,p_start_date => p_start_date
    ,p_end_date => p_end_date -- Fix 2978610. Passing start date and end date.

    );

--
  hr_utility.set_location('Leaving:'||l_proc, 50);


END update_sec_profile_asg;
--

END hr_user_acct_internal;

/
