--------------------------------------------------------
--  DDL for Package Body PON_USER_PROFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_USER_PROFILE_PKG" as
/*$Header: PONUSPRB.pls 120.14.12010000.2 2009/06/10 05:15:30 anagoel ship $ */

-- store the profile value for logging in a global constant variable
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- module prefix for logging
g_module_prefix CONSTANT VARCHAR2(50) := 'pon.plsql.PON_USER_PROFILE_PKG.';

procedure update_user_lang(
  p_username        IN VARCHAR2
, p_user_language   IN VARCHAR2
, x_status          OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
)
IS
  l_exception_msg   VARCHAR2(100);

BEGIN

  --store user language in fnd_preferences.
  PON_PROFILE_UTIL_PKG.SET_WF_LANGUAGE(p_username , p_user_language);
  PON_PROFILE_UTIL_PKG.SET_WF_LANGUAGE(UPPER(p_username) , p_user_language);

  X_STATUS      :='S';
  x_exception_msg :=NULL;

  -- commit;

EXCEPTION
    WHEN PON_PROFILE_UTIL_PKG.HZ_FAIL_EXCEPTION THEN
      rollback;
      X_STATUS  :='E';
      raise;
    WHEN OTHERS THEN
      rollback;
      X_STATUS  :='U';
      raise;

END update_user_lang;


--driven by UI page PersonalInfo.jsp
procedure update_user_info(
  p_username                        IN VARCHAR2
, P_USER_NAME_PREFIX                IN VARCHAR2
, P_USER_NAME_F                             IN VARCHAR2
, P_USER_NAME_M                             IN VARCHAR2
, P_USER_NAME_L                             IN VARCHAR2
, P_USER_NAME_SUFFIX                IN VARCHAR2
, P_USER_TITLE                              IN VARCHAR2
, P_USER_EMAIL                              IN VARCHAR2
, P_USER_COUNTRY_CODE               IN VARCHAR2
, P_USER_AREA_CODE                  IN VARCHAR2
, P_USER_PHONE                              IN VARCHAR2
, P_USER_EXTENSION                  IN VARCHAR2
, P_USER_FAX_COUNTRY_CODE   IN VARCHAR2
, P_USER_FAX_AREA_CODE              IN VARCHAR2
, P_USER_FAX                                IN VARCHAR2
, P_USER_FAX_EXTENSION              IN VARCHAR2
, P_USER_TIMEZONE                   IN VARCHAR2
, P_USER_LANGUAGE                   IN VARCHAR2
, P_USER_DATEFORMAT                   IN VARCHAR2
, P_USER_LOCALE        IN VARCHAR2
, P_USER_ENCODINGOPTION 	IN VARCHAR2
, x_status		OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
)
IS
  l_user_party_id    NUMBER;
  l_vendor_party_id    NUMBER;
  l_exception_msg   VARCHAR2(100);
  l_count            NUMBER;
  person_rec                      hz_party_v2pub.person_rec_type;
  profile_id           NUMBER;
  x_return_status        VARCHAR2(1000);
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(32767);
  l_update_date        DATE;
  l_object_version_number number;
BEGIN
  SELECT person_party_id
  INTO   l_user_party_id
  FROM   fnd_user
  WHERE  user_name = p_username;


   SELECT vendor_party_id
   INTO   l_vendor_party_id
   FROM   pos_supplier_users_v
   WHERE  person_party_id = l_user_party_id;

   -- CALL iSP API to update the Supplier Info. They in turn will update the required TCA table.
   -- iSP package : POS_SUPP_CONTACT_PKG

   POS_SUPP_CONTACT_PKG.update_supplier_contact
    (p_contact_party_id =>  l_user_party_id,
     p_vendor_party_id   => l_vendor_party_id,
     p_first_name        => P_USER_NAME_F,
     p_last_name         => P_USER_NAME_L,
     p_middle_name       => P_USER_NAME_M,
     p_contact_title     => P_USER_TITLE,
     p_job_title         => NULL,
     p_phone_area_code   => P_USER_COUNTRY_CODE,
     p_phone_number      => P_USER_PHONE,
     p_phone_extension   => P_USER_EXTENSION,
     p_fax_area_code     => P_USER_FAX_AREA_CODE,
     p_fax_number        => P_USER_FAX,
     p_email_address     => P_USER_EMAIL,
     x_return_status     => x_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data
     );

    IF x_return_status IS NULL OR
      x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE UPDATE_SUPPLIER_CONTACT_E;
    END IF;

  --set email address in fnd_user as well as TCA.
  UPDATE fnd_user
  SET email_address = p_user_email
  WHERE person_party_id = l_user_party_id;

   -- bug 2329157 . Need the user encoding option to be set for the user
   PON_PROFILE_UTIL_PKG.update_or_insert_party_pref(l_user_party_id, 'PON',
      'USER_ENCODING', p_user_encodingoption, 'User Charset Encoding Option', NULL,NULL,NULL,NULL,NULL,
      x_status, x_exception_msg);

  X_STATUS	:='S';
  x_exception_msg :=NULL;

  --commit; -- jazhang 01/08
EXCEPTION
    WHEN UPDATE_SUPPLIER_CONTACT_E THEN
      X_STATUS	:= x_return_status;
      x_exception_msg := x_msg_data;
      raise;
    WHEN PON_PROFILE_UTIL_PKG.HZ_FAIL_EXCEPTION THEN
      --dbms_output.put_line('HZ failure ' || x_exception_msg);
      --rollback; -- jazhang 01/08
      X_STATUS	:='E';
      raise;
    WHEN OTHERS THEN
      --dbms_output.put_line('Other failure -- '||x_exception_msg);
      --rollback; -- jazhang 01/08
      X_STATUS	:='U';
      raise;
END update_user_info;

--retrieve info about a user.  Notice TIMEZONE is pretty rudimentary.
--Don't know how we're storing, what we're doing with it, etc.
procedure retrieve_vendor_user_info(
  p_username                        IN VARCHAR2
, x_user_party_id                   OUT NOCOPY NUMBER
, X_USER_NAME_PREFIX                OUT NOCOPY VARCHAR2
, X_USER_NAME_F                     OUT NOCOPY VARCHAR2
, X_USER_NAME_M                     OUT NOCOPY VARCHAR2
, X_USER_NAME_L                     OUT NOCOPY VARCHAR2
, X_USER_NAME_SUFFIX                OUT NOCOPY VARCHAR2
, X_USER_TITLE                      OUT NOCOPY VARCHAR2
, X_USER_EMAIL                      OUT NOCOPY VARCHAR2
, X_USER_COUNTRY_CODE               OUT NOCOPY VARCHAR2
, X_USER_AREA_CODE                  OUT NOCOPY VARCHAR2
, X_USER_PHONE                      OUT NOCOPY VARCHAR2
, X_USER_EXTENSION                  OUT NOCOPY VARCHAR2
, X_USER_FAX_COUNTRY_CODE           OUT NOCOPY VARCHAR2
, X_USER_FAX_AREA_CODE              OUT NOCOPY VARCHAR2
, X_USER_FAX                        OUT NOCOPY VARCHAR2
, X_USER_FAX_EXTENSION              OUT NOCOPY VARCHAR2
, X_USER_ENCODINGOPTION              OUT NOCOPY VARCHAR2
, x_status              OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
)
IS
  l_user_id                         NUMBER;
  l_exception_msg		VARCHAR2(100);
  l_count                           NUMBER;
  l_attribute                   VARCHAR2(150);
  l_meaning                     VARCHAR2(150);
BEGIN

  x_exception_msg := 'begin:  retrieve_user_info';
-- first, get the user_id and the fk to TCA
  SELECT person_party_id, user_id
  INTO   x_user_party_id
  ,      l_user_id
  FROM   fnd_user
  WHERE  user_name = p_username;

--grab user info from TCA
x_exception_msg:='retrieve_user_info: select person, phone, fax';

--department and user admin not selected.... ?
BEGIN --{
      SELECT  hp1.person_pre_name_adjunct
      ,       hp1.person_first_name
      ,       hp1.person_middle_name
      ,       hp1.person_last_name
      ,       hp1.person_name_suffix
      ,       hp1.person_title
      ,       hc3.email_address
      ,       hc1.phone_country_code
      ,       hc1.phone_area_code
      ,       hc1.phone_number
      ,       hc1.phone_extension
      ,       hc4.phone_country_code
      ,       hc4.phone_area_code
      ,       hc4.phone_number
      ,       hc4.phone_extension
      INTO
         X_USER_NAME_PREFIX
      ,  X_USER_NAME_F
      ,  X_USER_NAME_M
      ,  X_USER_NAME_L
      ,  X_USER_NAME_SUFFIX
      ,  X_USER_TITLE
      ,  X_USER_EMAIL
      ,  X_USER_COUNTRY_CODE
      ,  X_USER_AREA_CODE
      ,  X_USER_PHONE
      ,  X_USER_EXTENSION
      ,  X_USER_FAX_COUNTRY_CODE
      ,  X_USER_FAX_AREA_CODE
      ,  X_USER_FAX
      ,  X_USER_FAX_EXTENSION
      FROM    HZ_PARTIES              hp1  -- Person
      ,       HZ_CONTACT_POINTS       hc1  -- Phone
      ,       HZ_CONTACT_POINTS       hc3  -- Email
      ,       HZ_CONTACT_POINTS       hc4  -- Fax
      ,       POS_SUPPLIER_USERS_V  posv
      WHERE   hp1.party_id               = x_user_party_id
      AND     hp1.party_id = posv.person_party_id
      AND     hp1.status                 = 'A'
      AND     hc1.owner_table_name(+)    = 'HZ_PARTIES'
      AND     hc1.owner_table_id(+)      = posv.rel_party_id
      AND     hc1.contact_point_type(+)  = 'PHONE'
      AND     hc1.phone_line_type(+)     = 'GEN'
      AND     hc1.status(+)              = 'A'
      AND     hc1.primary_flag(+)        = 'Y'
      AND     hc3.owner_table_name(+)    = 'HZ_PARTIES'
      AND     hc3.owner_table_id(+)      = posv.rel_party_id
      AND     hc3.contact_point_type(+)  = 'EMAIL'
      AND     hc3.primary_flag(+)        = 'Y'
      AND     hc3.status(+)              = 'A'
      AND     hc4.owner_table_name(+)    = 'HZ_PARTIES'
      AND     hc4.owner_table_id(+)      = posv.rel_party_id
      AND     hc4.contact_point_type(+)  = 'PHONE'
      AND     hc4.phone_line_type(+)     = 'FAX'
      AND     hc4.status(+)              = 'A'
      AND     hc4.primary_flag(+)        = 'Y'
      AND     nvl(posv.USER_END_DATE,sysdate) >= sysdate;
EXCEPTION --}
WHEN TOO_MANY_ROWS THEN --{
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string( log_level => FND_LOG.level_statement,
                            module    => g_module_prefix || 'retrieve_user_data',
                            message   => '501: Multiple records for person ');
            END IF;
        END IF;
      SELECT  hp1.person_pre_name_adjunct
      ,       hp1.person_first_name
      ,       hp1.person_middle_name
      ,       hp1.person_last_name
      ,       hp1.person_name_suffix
      ,       hp1.person_title
      ,       hc3.email_address
      ,       hc1.phone_country_code
      ,       hc1.phone_area_code
      ,       hc1.phone_number
      ,       hc1.phone_extension
      ,       hc4.phone_country_code
      ,       hc4.phone_area_code
      ,       hc4.phone_number
      ,       hc4.phone_extension
      INTO
      X_USER_NAME_PREFIX
      ,  X_USER_NAME_F
      ,  X_USER_NAME_M
      ,  X_USER_NAME_L
      ,  X_USER_NAME_SUFFIX
      ,  X_USER_TITLE
      ,  X_USER_EMAIL
      ,  X_USER_COUNTRY_CODE
      ,  X_USER_AREA_CODE
      ,  X_USER_PHONE
      ,  X_USER_EXTENSION
      ,  X_USER_FAX_COUNTRY_CODE
      ,  X_USER_FAX_AREA_CODE
      ,  X_USER_FAX
      ,  X_USER_FAX_EXTENSION
      FROM    HZ_PARTIES              hp1  -- Person
      ,       HZ_CONTACT_POINTS       hc1  -- Phone
      ,       HZ_CONTACT_POINTS       hc3  -- Email
      ,       HZ_CONTACT_POINTS       hc4  -- Fax
      ,       POS_SUPPLIER_USERS_V  posv
      WHERE          hp1.party_id               = x_user_party_id
             AND     hp1.party_id = posv.person_party_id
             AND     hp1.status                 = 'A'
             AND     hc1.owner_table_name(+)    = 'HZ_PARTIES'
             AND     hc1.owner_table_id(+)      = posv.rel_party_id
             AND     hc1.contact_point_type(+)  = 'PHONE'
             AND     hc1.phone_line_type(+)     = 'GEN'
             AND     hc1.status(+)              = 'A'
             AND     hc1.primary_flag(+)        = 'Y'
             AND     hc3.owner_table_name(+)    = 'HZ_PARTIES'
             AND     hc3.owner_table_id(+)      = posv.rel_party_id
             AND     hc3.contact_point_type(+)  = 'EMAIL'
             AND     hc3.primary_flag(+)        = 'Y'
             AND     hc3.status(+)              = 'A'
             AND     hc4.owner_table_name(+)    = 'HZ_PARTIES'
             AND     hc4.owner_table_id(+)      = posv.rel_party_id
             AND     hc4.contact_point_type(+)  = 'PHONE'
             AND     hc4.phone_line_type(+)     = 'FAX'
             AND     hc4.status(+)              = 'A'
             AND     hc4.primary_flag(+)        = 'Y'
             AND     nvl(posv.USER_END_DATE,sysdate) >= sysdate
	     AND     rownum                     = 1;
  END; --}

  BEGIN
    PON_PROFILE_UTIL_PKG.retrieve_party_preference(x_user_party_id,'PON',
        'USER_ENCODING',x_user_encodingoption,l_meaning,l_attribute,l_attribute,
         l_attribute, l_attribute,l_attribute, x_status, x_exception_msg);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     x_user_encodingoption := '';
  END;

  x_exception_msg :=NULL;
  X_STATUS        :='S';
EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('Other failure -- '||x_exception_msg);
      X_STATUS  :='U';
      raise;
END retrieve_vendor_user_info;

--Need to change passwords when they expire, or when the user wants to
--Notice we're setting the _encrypted_ user password -- this function
--needs an encrypted password
procedure change_password(
  p_username     IN VARCHAR2
, p_new_password IN VARCHAR2
, x_status		OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
)
IS
BEGIN
--Note:  user must be an Oracle Exchange User
  UPDATE fnd_user
  SET    encrypted_user_password = p_new_password
  ,      password_date = sysdate
  ,      password_accesses_left = 9999999
  ,      last_update_date = sysdate
  ,      last_updated_by = fnd_global.user_id
  WHERE user_name = p_username
  AND   description = 'Oracle Exchange User';

  x_exception_msg :=NULL;
  X_STATUS        :='S';
  --commit;
EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('Other failure -- '||x_exception_msg);
      --rollback; -- jazhang 01/08
      X_STATUS  :='U';
      raise;
END change_password;

--checks to see if we need to force the user to change password
procedure login(
  p_username         IN  VARCHAR2
, p_change_password  OUT NOCOPY VARCHAR2
, x_status		OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
)
IS
  l_user_id   NUMBER;
  l_session_id NUMBER;
BEGIN
--Note:  user must be an Oracle Exchange user
  SELECT user_id
  INTO l_user_id
  FROM fnd_user
  WHERE user_name = p_username
  AND   description = 'Oracle Exchange User';

  FND_SIGNON.new_session(l_user_id,l_session_id,p_change_password);

  x_exception_msg :=NULL;
  X_STATUS        :='S';
EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('Other failure -- '||x_exception_msg);
      X_STATUS  :='U';
      raise;
END login;

--completely removes a user from fnd_user and TCA tables.
--VERY BAD MOJO if you are not sure you want this guy gone.
--Does not commit:  if you want to commit, you must do it explicitly
PROCEDURE delete_user(
  p_username      IN VARCHAR2
, x_status        OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
)
IS
  l_user_party_id NUMBER;
  l_location_id   NUMBER;
  CURSOR party_site_ids IS
    SELECT party_site_id
    FROM hz_party_sites
    WHERE party_id = l_user_party_id;
BEGIN
  SELECT person_party_id
  INTO l_user_party_id
  FROM fnd_user
  WHERE user_name = p_username;

  DELETE FROM fnd_user
  WHERE user_name = p_username;

--get rid of user profile
  DELETE FROM hz_person_profiles
  WHERE party_id = l_user_party_id;

--get rid of hz_parties row
  DELETE FROM hz_parties
  WHERE party_id = l_user_party_id;

--get rid of contact points
  DELETE FROM hz_contact_points
  WHERE owner_table_name = 'HZ_PARTIES'
  AND owner_table_id = l_user_party_id;

  x_status := 'S';
EXCEPTION
  WHEN OTHERS THEN
    x_status := 'E';
    x_exception_msg := 'Failed to delete user, rolling back';
    rollback;
END delete_user;


--To get the password challenge question and response.
procedure retrieve_pwd_challenge (
  p_user_party_id       IN NUMBER
, X_USER_PWD_QUESTION   OUT NOCOPY VARCHAR2
, X_USER_PWD_RESPONSE   OUT NOCOPY VARCHAR2
, x_status              OUT NOCOPY VARCHAR2
, x_exception_msg       OUT NOCOPY VARCHAR2
, x_enc_foundation      OUT NOCOPY VARCHAR2
)
IS
  -- l_pwd_response_encrypted              VARCHAR2(240);
  l_meaning                             VARCHAR2(240);
  l_attribute                           VARCHAR2(150);
BEGIN

  x_exception_msg := 'begin: retrieve_pwd_challenge';

-- retrieve the user's password challenge question and response
  x_exception_msg := 'getting the password challenge question and response';
  pon_profile_util_pkg.retrieve_party_preference(
      p_party_id       => p_user_party_id,
      p_app_short_name => 'PON',
      p_pref_name      => 'PON_USER_PWD_QUESTION',
      x_pref_value     => x_user_pwd_question,
      x_pref_meaning   => l_meaning,
      x_attribute1     => l_attribute,
      x_attribute2     => l_attribute,
      x_attribute3     => l_attribute,
      x_attribute4     => l_attribute,
      x_attribute5     => l_attribute,
      x_status         => x_status,
      x_exception_msg  => x_exception_msg);

  pon_profile_util_pkg.retrieve_party_preference(
      p_party_id       => p_user_party_id,
      p_app_short_name => 'PON',
      p_pref_name      => 'PON_USER_PWD_RESPONSE',
      x_pref_value     => x_user_pwd_response,
      x_pref_meaning   => l_meaning,
      x_attribute1     => x_enc_foundation,
      x_attribute2     => l_attribute,
      x_attribute3     => l_attribute,
      x_attribute4     => l_attribute,
      x_attribute5     => l_attribute,
      x_status         => x_status,
      x_exception_msg  => x_exception_msg);

  -- decrypt the response
  -- PON_UTIL_MGR.get_util_info(l_pwd_response_encrypted, X_USER_PWD_RESPONSE);

  x_status := 'S';
  x_exception_msg := '';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	X_USER_PWD_QUESTION := '';
	X_USER_PWD_RESPONSE := '';
	x_status := 'S';
	x_exception_msg := 'PON_USER_PROFILE.retrieve_pwd_challenge -- The challenge/response for the party_id: ' || p_user_party_id || ' does not exist! ';
    WHEN OTHERS THEN
      --dbms_output.put_line('Other failure -- '||x_exception_msg);
      X_STATUS  :='U';
      raise;
END retrieve_pwd_challenge;

--to update the user's password question and response
procedure update_pwd_challenge (
  p_user_party_id               IN NUMBER
, p_user_pwd_question           IN VARCHAR2
, p_user_pwd_response           IN VARCHAR2
, p_enc_foundation              IN VARCHAR2
, x_status                      OUT NOCOPY VARCHAR2
, x_exception_msg               OUT NOCOPY VARCHAR2
)
IS
  -- l_pwd_response_encrypted              VARCHAR2(240);

BEGIN

  --encrypt the response
  -- PON_UTIL_MGR.pass_util_info(P_USER_PWD_RESPONSE, l_pwd_response_encrypted);

  pon_profile_util_pkg.update_or_insert_party_pref(
      p_party_id       => p_user_party_id,
      p_app_short_name => 'PON',
      p_pref_name      => 'PON_USER_PWD_QUESTION',
      p_pref_value     => p_user_pwd_question,
      p_pref_meaning   => NULL,
      p_attribute1     => NULL,
      p_attribute2     => NULL,
      p_attribute3     => NULL,
      p_attribute4     => NULL,
      p_attribute5     => NULL,
      x_status         => x_status,
      x_exception_msg  => x_exception_msg);

  pon_profile_util_pkg.update_or_insert_party_pref(
      p_party_id       => p_user_party_id,
      p_app_short_name => 'PON',
      p_pref_name      => 'PON_USER_PWD_RESPONSE',
      p_pref_value     => p_user_pwd_response,
      p_pref_meaning   => NULL,
      p_attribute1     => p_enc_foundation,
      p_attribute2     => NULL,
      p_attribute3     => NULL,
      p_attribute4     => NULL,
      p_attribute5     => NULL,
      x_status         => x_status,
      x_exception_msg  => x_exception_msg);

  x_status              := 'S';
  x_exception_msg       := '';

EXCEPTION
    WHEN PON_PROFILE_UTIL_PKG.HZ_FAIL_EXCEPTION THEN
      --dbms_output.put_line('HZ failure ' || x_exception_msg);
        rollback;
        X_STATUS  :='E';
        raise;
    WHEN OTHERS THEN
      --dbms_output.put_line('Other failure -- '||x_exception_msg);
        rollback;
        X_STATUS  :='U';
        raise;

END update_pwd_challenge;

procedure retrieve_user_data(
  p_username                        IN VARCHAR2
, x_user_party_id                   OUT NOCOPY NUMBER
, X_USER_NAME_PREFIX                OUT NOCOPY VARCHAR2
, X_USER_NAME_F                     OUT NOCOPY VARCHAR2
, X_USER_NAME_M                     OUT NOCOPY VARCHAR2
, X_USER_NAME_L                     OUT NOCOPY VARCHAR2
, X_USER_NAME_SUFFIX                OUT NOCOPY VARCHAR2
, X_USER_TITLE                      OUT NOCOPY VARCHAR2
, X_USER_EMAIL                      OUT NOCOPY VARCHAR2
, X_USER_COUNTRY_CODE               OUT NOCOPY VARCHAR2
, X_USER_AREA_CODE                  OUT NOCOPY VARCHAR2
, X_USER_PHONE                      OUT NOCOPY VARCHAR2
, X_USER_EXTENSION                  OUT NOCOPY VARCHAR2
, X_USER_FAX_COUNTRY_CODE           OUT NOCOPY VARCHAR2
, X_USER_FAX_AREA_CODE              OUT NOCOPY VARCHAR2
, X_USER_FAX                        OUT NOCOPY VARCHAR2
, X_USER_FAX_EXTENSION              OUT NOCOPY VARCHAR2
, X_USER_ENCODINGOPTION             OUT NOCOPY VARCHAR2
, X_DUMMY_DATA                      OUT NOCOPY VARCHAR2
, X_EXTRA_INFO                      OUT NOCOPY VARCHAR2
, X_ROW_IN_HR                       OUT NOCOPY VARCHAR2
, X_VENDOR_RELATIONSHIP             OUT NOCOPY VARCHAR2
, X_ENTERPRISE_RELATIONSHIP         OUT NOCOPY VARCHAR2
, x_status              OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
)
IS
  l_user_id                             NUMBER;
  l_vendor_id                           NUMBER;
  l_enterprise_id                       NUMBER;
  l_relationship_id                     NUMBER;
BEGIN

    -- Flags for the data
    x_row_in_hr := 'N';
    x_vendor_relationship := 'N';
    x_enterprise_relationship := 'N';
    x_dummy_data := 'N';
    x_extra_info := 'N';
    x_exception_msg :=NULL;

     BEGIN

        select user_id into
        l_user_id
        from fnd_user
        where user_name = p_username;

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string( log_level => FND_LOG.level_statement,
                            module    => g_module_prefix || 'retrieve_user_data',
                            message   => '10:' || p_username || ':' || l_user_id);
            END IF;
        END IF;


        -- check if a row exists in HR
        l_enterprise_id := pos_party_management_pkg.get_emp_or_ctgt_wrkr_pty_id(l_user_id);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string( log_level => FND_LOG.level_statement,
                            module    => g_module_prefix || 'retrieve_user_data',
                            message   => '20:l_enterprise_id:' || l_enterprise_id);
            END IF;
        END IF;

        IF l_enterprise_id <> -1 THEN
            x_row_in_hr := 'Y';
        END IF;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_row_in_hr := 'N';
     END;

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string( log_level => FND_LOG.level_statement,
                            module    => g_module_prefix || 'retrieve_user_data',
                            message   => 'l_user_id:' || l_user_id || ':l_enterprise_id:' ||
l_enterprise_id || ':x_row_in_hr:' || x_row_in_hr || ':p_username:' || p_username);
            END IF;
        END IF;

    if x_row_in_hr = 'Y' then -- {This implies that the user is a HR user.

        l_enterprise_id := POS_PARTY_MANAGEMENT_PKG.check_for_enterprise_user(p_username);
        IF l_enterprise_id <> -1 THEN
            x_enterprise_relationship := 'Y';
        ELSE
            POS_ENTERPRISE_UTIL_PKG.pos_create_enterprise_user(p_username
                                                               ,'First'
                                                               ,'Last'
                                                               ,'Email'
                                                               ,x_user_party_id
                                                               ,l_relationship_id
                                                               ,x_exception_msg
                                                               , x_status);
            IF (x_status = 'S') THEN
              x_enterprise_relationship := 'Y';
            ELSE
              x_enterprise_relationship := 'N';
            END IF;
        END IF;

        retrieve_enterprise_user_info(
        p_username
        , x_user_party_id
        , X_USER_NAME_PREFIX
        , X_USER_NAME_F
        , X_USER_NAME_M
        , X_USER_NAME_L
        , X_USER_NAME_SUFFIX
        , X_USER_TITLE
        , X_USER_EMAIL
        , X_USER_COUNTRY_CODE
        , X_USER_AREA_CODE
        , X_USER_PHONE
        , X_USER_EXTENSION
        , X_USER_FAX_COUNTRY_CODE
        , X_USER_FAX_AREA_CODE
        , X_USER_FAX
        , X_USER_FAX_EXTENSION
        , X_USER_ENCODINGOPTION
        , x_status
        , x_exception_msg
        );

        -- HR BUG They populate the First Name as a ********** if it is null.
        if x_user_name_f = '***********' then
            x_user_name_f := '';
        end if;

        if x_user_name_l is null then
            x_extra_info := 'Y';
        end if;

    else
        l_vendor_id := POS_PARTY_MANAGEMENT_PKG.check_for_vendor_user(p_username);
        if (l_vendor_id <> -1 and l_vendor_id <> -2) then --{
            x_vendor_relationship := 'Y';

            retrieve_vendor_user_info(
            p_username
            , x_user_party_id
            , X_USER_NAME_PREFIX
            , X_USER_NAME_F
            , X_USER_NAME_M
            , X_USER_NAME_L
            , X_USER_NAME_SUFFIX
            , X_USER_TITLE
            , X_USER_EMAIL
            , X_USER_COUNTRY_CODE
            , X_USER_AREA_CODE
            , X_USER_PHONE
            , X_USER_EXTENSION
            , X_USER_FAX_COUNTRY_CODE
            , X_USER_FAX_AREA_CODE
            , X_USER_FAX
            , X_USER_FAX_EXTENSION
            , X_USER_ENCODINGOPTION
            , x_status
            , x_exception_msg
            );

	    --bug 8326307:removed the condition to check the first name
            IF x_user_name_l is null
             or x_user_email is null then
              x_extra_info := 'Y';
            END IF;

            if x_user_name_l = '__SUPPLIER__' then
               x_dummy_data := 'Y';
            end if;

        ELSIF (l_vendor_id = -2) then
            x_vendor_relationship := 'M';

        end if; --} end if of x_vendor_relationship
    end if; --} x_row_in_hr

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string( log_level => FND_LOG.level_statement,
                            module    => g_module_prefix || 'retrieve_user_data',
                            message   => 'x_status:' || x_status
                                      || 'x_exception_msg:' || x_exception_msg
                                      || 'x_dummy_data:' || x_dummy_data
                                      || 'x_extra_info:' || x_extra_info
                                      || 'x_vendor_relationship:' || x_vendor_relationship
                                      || 'x_enterprise_relationship:' || x_enterprise_relationship
                                      || 'x_row_in_hr:' || x_row_in_hr);
            END IF;
        END IF;

    X_STATUS        :='S';

EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('Other failure -- '||x_exception_msg);
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string( log_level => FND_LOG.level_exception,
                            module    => g_module_prefix || 'retrieve_user_data',
                            message   => 'x_status:' || x_status
                                      || 'x_exception_msg:' || x_exception_msg
                                      || 'x_dummy_data:' || x_dummy_data
                                      || 'x_extra_info:' || x_extra_info
                                      || 'x_vendor_relationship:' || x_vendor_relationship
                                      || 'x_enterprise_relationship:' || x_enterprise_relationship                                      || 'x_row_in_hr:' || x_row_in_hr);
            END IF;
        END IF;
      X_STATUS  :='U';
END retrieve_user_data;

procedure retrieve_user_info(
  p_username                        IN VARCHAR2
, x_user_party_id                   OUT NOCOPY NUMBER
, X_USER_NAME_PREFIX                OUT NOCOPY VARCHAR2
, X_USER_NAME_F                     OUT NOCOPY VARCHAR2
, X_USER_NAME_M                     OUT NOCOPY VARCHAR2
, X_USER_NAME_L                     OUT NOCOPY VARCHAR2
, X_USER_NAME_SUFFIX                OUT NOCOPY VARCHAR2
, X_USER_TITLE                      OUT NOCOPY VARCHAR2
, X_USER_EMAIL                      OUT NOCOPY VARCHAR2
, X_USER_COUNTRY_CODE               OUT NOCOPY VARCHAR2
, X_USER_AREA_CODE                  OUT NOCOPY VARCHAR2
, X_USER_PHONE                      OUT NOCOPY VARCHAR2
, X_USER_EXTENSION                  OUT NOCOPY VARCHAR2
, X_USER_FAX_COUNTRY_CODE           OUT NOCOPY VARCHAR2
, X_USER_FAX_AREA_CODE              OUT NOCOPY VARCHAR2
, X_USER_FAX                        OUT NOCOPY VARCHAR2
, X_USER_FAX_EXTENSION              OUT NOCOPY VARCHAR2
, X_USER_TIMEZONE                   OUT NOCOPY VARCHAR2
, X_USER_DEFAULT_LANGUAGE           OUT NOCOPY VARCHAR2
, X_USER_DEFAULT_DATEFORMAT           OUT NOCOPY VARCHAR2
, X_USER_LOCALE                   OUT NOCOPY VARCHAR2
, X_USER_ENCODINGOPTION              OUT NOCOPY VARCHAR2
, x_status              OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
)
IS
  l_user_id                         NUMBER;
  l_exception_msg		VARCHAR2(100);
  l_count                           NUMBER;
  l_attribute                   VARCHAR2(150);
  l_meaning                     VARCHAR2(150);
BEGIN

  x_exception_msg := 'begin:  retrieve_user_info';
-- first, get the user_id and the fk to TCA
  SELECT person_party_id, user_id
  INTO   x_user_party_id
  ,      l_user_id
  FROM   fnd_user
  WHERE  user_name = p_username;

--grab user info from TCA

x_exception_msg:='retrieve_user_info: select person, phone, fax';

--department and user admin not selected.... ?
SELECT  hp1.person_pre_name_adjunct
,       hp1.person_first_name
,       hp1.person_middle_name
,       hp1.person_last_name
,       hp1.person_name_suffix
,       hp1.person_title
,       hc3.email_address
,       hc1.phone_country_code
,       hc1.phone_area_code
,       hc1.phone_number
,       hc1.phone_extension
,       hc4.phone_country_code
,       hc4.phone_area_code
,       hc4.phone_number
,       hc4.phone_extension
INTO
X_USER_NAME_PREFIX
,  X_USER_NAME_F
,  X_USER_NAME_M
,  X_USER_NAME_L
,  X_USER_NAME_SUFFIX
,  X_USER_TITLE
,  X_USER_EMAIL
,  X_USER_COUNTRY_CODE
,  X_USER_AREA_CODE
,  X_USER_PHONE
,  X_USER_EXTENSION
,  X_USER_FAX_COUNTRY_CODE
,  X_USER_FAX_AREA_CODE
,  X_USER_FAX
,  X_USER_FAX_EXTENSION
FROM    HZ_PARTIES              hp1  -- Person
,       HZ_CONTACT_POINTS       hc1  -- Phone
,       HZ_CONTACT_POINTS       hc3  -- Email
,       HZ_CONTACT_POINTS       hc4  -- Fax
WHERE   hp1.party_id               = x_user_party_id
AND     hc1.owner_table_name(+)    = 'HZ_PARTIES'
AND     hc1.owner_table_id(+)      = hp1.party_id
AND     hc1.contact_point_type(+)  = 'PHONE'
AND     hc1.phone_line_type(+)     = 'GEN'
AND     hc1.status(+)              = 'A'
AND     hc1.primary_flag(+)        = 'Y'
AND     hc3.owner_table_name(+)    = 'HZ_PARTIES'
AND     hc3.owner_table_id(+)      = hp1.party_id
AND     hc3.contact_point_type(+)  = 'EMAIL'
AND     hc3.EMAIL_FORMAT(+)        = 'MAILTEXT'
AND     hc3.status(+)              = 'A'
AND     hc3.primary_flag(+)        = 'Y'
AND     hc4.owner_table_name(+)    = 'HZ_PARTIES'
AND     hc4.owner_table_id(+)      = hp1.party_id
AND     hc4.contact_point_type(+)  = 'PHONE'
AND     hc4.phone_line_type(+)     = 'FAX'
AND     hc4.status(+)              = 'A'
AND     hc4.primary_flag(+)        = 'Y';

-- language, timezone, dateformat information is retrieved from fnd now
-- so we just set dummy values here
x_user_timezone := '4';
x_user_default_language := 'US';
x_user_default_dateformat := '';
x_user_locale := '';

  BEGIN
    PON_PROFILE_UTIL_PKG.retrieve_party_preference(x_user_party_id,'PON',
        'USER_ENCODING',x_user_encodingoption,l_meaning,l_attribute,l_attribute,
         l_attribute, l_attribute,l_attribute, x_status, x_exception_msg);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     x_user_encodingoption := '';
  END;

  x_exception_msg :=NULL;
  X_STATUS        :='S';
EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('Other failure -- '||x_exception_msg);
      X_STATUS  :='U';
      raise;
END retrieve_user_info;

procedure retrieve_enterprise_user_info(
  p_username                        IN VARCHAR2
, x_user_party_id                   OUT NOCOPY NUMBER
, X_USER_NAME_PREFIX                OUT NOCOPY VARCHAR2
, X_USER_NAME_F                     OUT NOCOPY VARCHAR2
, X_USER_NAME_M                     OUT NOCOPY VARCHAR2
, X_USER_NAME_L                     OUT NOCOPY VARCHAR2
, X_USER_NAME_SUFFIX                OUT NOCOPY VARCHAR2
, X_USER_TITLE                      OUT NOCOPY VARCHAR2
, X_USER_EMAIL                      OUT NOCOPY VARCHAR2
, X_USER_COUNTRY_CODE               OUT NOCOPY VARCHAR2
, X_USER_AREA_CODE                  OUT NOCOPY VARCHAR2
, X_USER_PHONE                      OUT NOCOPY VARCHAR2
, X_USER_EXTENSION                  OUT NOCOPY VARCHAR2
, X_USER_FAX_COUNTRY_CODE           OUT NOCOPY VARCHAR2
, X_USER_FAX_AREA_CODE              OUT NOCOPY VARCHAR2
, X_USER_FAX                        OUT NOCOPY VARCHAR2
, X_USER_FAX_EXTENSION              OUT NOCOPY VARCHAR2
, X_USER_ENCODINGOPTION              OUT NOCOPY VARCHAR2
, x_status              OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
)
IS
  l_user_id                         NUMBER;
  l_exception_msg		VARCHAR2(100);
  l_employee_id                     NUMBER;
  l_count                           NUMBER;
  l_attribute                   VARCHAR2(150);
  l_meaning                     VARCHAR2(150);
BEGIN

  x_exception_msg := 'begin:  retrieve_user_info';
-- first, get the user_id and the fk to TCA
  SELECT person_party_id, user_id, employee_id
  INTO   x_user_party_id
  ,      l_user_id
  ,      l_employee_id
  FROM   fnd_user
  WHERE  user_name = p_username;

--grab user info from TCA
    x_exception_msg:='retrieve_user_info: select person, phone, fax';

--department and user admin not selected.... ?
SELECT  hp1.person_pre_name_adjunct
,       hp1.person_first_name
,       hp1.person_middle_name
,       hp1.person_last_name
,       hp1.person_name_suffix
,       hp1.person_title
INTO
X_USER_NAME_PREFIX
,  X_USER_NAME_F
,  X_USER_NAME_M
,  X_USER_NAME_L
,  X_USER_NAME_SUFFIX
,  X_USER_TITLE
FROM    HZ_PARTIES              hp1  -- Person
WHERE   hp1.party_id               = x_user_party_id
        and hp1.status = 'A';

    begin
        select email_address
        into x_user_email
        from per_all_people_f
        where person_id = l_employee_id
        and effective_start_date < sysdate
        and nvl(effective_end_date,sysdate) >= sysdate;
    EXCEPTION
    WHEN OTHERS THEN
        x_user_email := '';

    END;

    begin
        select phone_number
        into x_user_phone
        from per_phones
        where phone_type = 'W1'
        and parent_id = l_employee_id;
    EXCEPTION
    WHEN OTHERS THEN
        x_user_phone := '';
    END;

    begin
        select phone_number
        into x_user_fax
        from per_phones
        where phone_type = 'WF'
        and parent_id = l_employee_id;
    EXCEPTION
    WHEN OTHERS THEN
        x_user_fax := '';
    END;


X_USER_COUNTRY_CODE      := '';
X_USER_AREA_CODE         := '';
X_USER_EXTENSION         := '';
X_USER_FAX_COUNTRY_CODE  := '';
X_USER_FAX_AREA_CODE     := '';
X_USER_FAX_EXTENSION     := '';

  BEGIN
    PON_PROFILE_UTIL_PKG.retrieve_party_preference(x_user_party_id,'PON',
        'USER_ENCODING',x_user_encodingoption,l_meaning,l_attribute,l_attribute,
         l_attribute, l_attribute,l_attribute, x_status, x_exception_msg);
  EXCEPTION
    WHEN OTHERS THEN
     x_user_encodingoption := '';
  END;

  x_exception_msg :=NULL;
  X_STATUS        :='S';
EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('Other failure -- '||x_exception_msg);
      X_STATUS  :='U';
      raise;
END retrieve_enterprise_user_info;


END PON_USER_PROFILE_PKG;

/
