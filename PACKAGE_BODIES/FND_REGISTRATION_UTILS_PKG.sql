--------------------------------------------------------
--  DDL for Package Body FND_REGISTRATION_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_REGISTRATION_UTILS_PKG" as
/* $Header: AFREGUB.pls 115.8 2003/01/09 00:35:26 bfreeman noship $ */

function is_requested_username_unique(
         p_username                    IN VARCHAR2)
return VARCHAR2
IS
    l_duplicates NUMBER;
BEGIN
-- determine if a duplicate username exists
-- trying to do this as quickly as possible, but I find using
-- an explicit cursor to be difficult to read
    SELECT count(*)
    INTO   l_duplicates
    FROM   fnd_user
    WHERE  user_name = UPPER(p_username)
    AND    rownum = 1;

    IF (l_duplicates <> 0)
    THEN RETURN 'N';
    END IF;

    -- determine if there is a non-rejected duplicate requested_user_name
    SELECT count(*)
    INTO   l_duplicates
    FROM   fnd_registrations
    WHERE  requested_user_name = p_username
    AND    registration_status IN('REGISTERED')
    AND    rownum = 1;

    IF (l_duplicates <> 0)
    THEN RETURN 'N';
    END IF;

    RETURN 'Y';

END is_requested_username_unique;



function is_requested_username_unique(
         p_registration_id              IN NUMBER)
return VARCHAR2
IS
    l_username VARCHAR2(100);
    l_duplicates NUMBER;
BEGIN

-- lookup requested_user_name for given registration_id
    SELECT requested_user_name
    INTO   l_username
    FROM   fnd_registrations
    WHERE  registration_id = p_registration_id;

-- determine if a duplicate username exists
-- trying to do this as quickly as possible, but I find using
-- an explicit cursor to be difficult to read
    SELECT count(*)
    INTO   l_duplicates
    FROM   fnd_user
    WHERE  user_name = UPPER(l_username)
    AND    rownum = 1;

    IF (l_duplicates <> 0)
    THEN RETURN 'N';
    END IF;

-- determine if there is a non-rejected duplicate requested_user_name
    SELECT count(*)
    INTO   l_duplicates
    FROM   fnd_registrations
    WHERE  requested_user_name = l_username
    AND    registration_status <> 'REJECTED'
    AND    rownum = 1;

    IF (l_duplicates <> 0)
    THEN RETURN 'N';
    END IF;

    RETURN 'Y';

END is_requested_username_unique;

function is_requested_username_unique(
         p_registration_id              IN NUMBER,
         p_username                     IN VARCHAR2)
return VARCHAR2
IS
    l_duplicates NUMBER;
BEGIN
-- determine if a duplicate username exists
-- trying to do this as quickly as possible, but I find using
-- an explicit cursor to be difficult to read
    SELECT count(*)
    INTO   l_duplicates
    FROM   fnd_user
    WHERE  user_name = UPPER(p_username)
    AND    rownum = 1;

    IF (l_duplicates <> 0)
    THEN RETURN 'N';
    END IF;

    -- determine if there is a non-rejected duplicate requested_user_name
    SELECT count(*)
    INTO   l_duplicates
    FROM   fnd_registrations
    WHERE  requested_user_name = p_username
    AND    registration_status IN('REGISTERED')
    AND    registration_id <> p_registration_id
    AND    rownum = 1;

    IF (l_duplicates <> 0)
    THEN RETURN 'N';
    END IF;

    RETURN 'Y';

END is_requested_username_unique;


function publish_event(
         p_registration_id              IN NUMBER,
         p_event_type                   IN VARCHAR2
         )
return VARCHAR2
IS

l_registration_key  VARCHAR2(255);
l_event_name        VARCHAR2(255);
l_param_list WF_PARAMETER_LIST_T := wf_parameter_list_t();
lv_reg_type FND_REGISTRATIONS.REGISTRATION_TYPE%TYPE;
ln_application_id FND_REGISTRATIONS.APPLICATION_ID%TYPE;

l_error_message     VARCHAR2(4000);

BEGIN

  l_registration_key := get_reg_key_from_id(p_registration_id);

  SELECT application_id, registration_type
  INTO   ln_application_id, lv_reg_type
  FROM   fnd_registrations
  WHERE  registration_id = p_registration_id;

-- populate parameter list for event
  wf_event.AddParameterToList( p_name => 'REGISTRATION_KEY',
                   p_value => l_registration_key,
                   p_parameterlist => l_param_list);

  wf_event.AddParameterToList( p_name => 'REGISTRATION_TYPE',
                               p_value => lv_reg_type,
                               p_parameterlist => l_param_list);

  wf_event.AddParameterToList( p_name => 'APPLICATION_ID',
                               p_value => ln_application_id,
                               p_parameterlist => l_param_list);

  -- event names:
  --   oracle.apps.fnd.umf.reg.user_invited
  --   oracle.apps.fnd.umf.reg.user_registered
  --   oracle.apps.fnd.umf.reg.user_approved
  --   oracle.apps.fnd.umf.reg.user_rejected

    l_event_name := 'oracle.apps.fnd.umf.reg.user_' || p_event_type;
    wf_event.raise( p_event_name => l_event_name,
                    p_event_key => l_registration_key || ':' || to_char(sysdate,'RRDDDSSSSS'),
                    p_parameters => l_param_list);

  l_param_list.DELETE;

--  errors are returned here
  l_error_message := fnd_message.get();
  if (l_error_message is not null) then

      if (l_error_message = FND_REGISTRATION_UTILS_PKG.EVENT_SUCCESS) then
          return 'Y';
      end if;
      fnd_message.set_name(null, l_error_message);
      return 'N';
  else
      RAISE NO_DATA_FOUND;
  end if;

  return 'N';

END publish_event;



function publish_invitation_event(
         p_registration_id              IN NUMBER)
return VARCHAR2
IS
BEGIN
    return publish_event( p_registration_id, 'invited');

END publish_invitation_event;

function publish_registration_event(
         p_registration_id              IN NUMBER)
return VARCHAR2
IS
BEGIN
    return publish_event( p_registration_id, 'registered');

END publish_registration_event;

function publish_approval_event(
         p_registration_id              IN NUMBER)
return VARCHAR2
IS
BEGIN
    return publish_event( p_registration_id, 'approved');

END publish_approval_event;

function publish_rejection_event(
         p_registration_id              IN NUMBER)
return VARCHAR2
IS
BEGIN
    return publish_event( p_registration_id, 'rejected');

END publish_rejection_event;

function get_reg_id_from_key(
         p_registration_key             IN VARCHAR2)
return NUMBER
IS
    l_registration_id NUMBER;
BEGIN
    SELECT registration_id
    INTO   l_registration_id
    FROM   fnd_registrations
    WHERE  registration_key = p_registration_key;

    return l_registration_id;

END get_reg_id_from_key;

function get_reg_key_from_id(
         p_registration_id              IN NUMBER)
return VARCHAR2
IS
    l_registration_key VARCHAR2(255);
BEGIN
    SELECT  registration_key
    INTO    l_registration_key
    FROM    fnd_registrations
    WHERE   registration_id = p_registration_id;
    return  l_registration_key;

END get_reg_key_from_id;

function invite(
         p_application_id               IN NUMBER,
         p_party_id                     IN NUMBER,
         p_registration_type            IN VARCHAR2,
         p_requested_user_name          IN VARCHAR2,
         p_assigned_user_name           IN VARCHAR2,
         p_exists_in_fnd_user_flag      IN VARCHAR2,
         p_user_title                   IN VARCHAR2,
         p_first_name                   IN VARCHAR2,
         p_middle_name                  IN VARCHAR2,
         p_last_name                    IN VARCHAR2,
         p_user_suffix                  IN VARCHAR2,
         p_email_contact_point_id       IN NUMBER,
         p_email                        IN VARCHAR2,
         p_phone_contact_point_id       IN NUMBER,
         p_phone_country_code           IN VARCHAR2,
         p_phone_area_code              IN VARCHAR2,
         p_phone                        IN VARCHAR2,
         p_phone_extension              IN VARCHAR2,
         p_fax_contact_point_id         IN NUMBER,
         p_fax_country_code             IN VARCHAR2,
         p_fax_area_code                IN VARCHAR2,
         p_fax                          IN VARCHAR2,
         p_fax_extension                IN VARCHAR2,
         p_language_code                IN VARCHAR2,
         p_time_zone                    IN VARCHAR2,
         p_territory_code               IN VARCHAR2,
         p_location_id                  IN NUMBER,
         p_address1                     IN VARCHAR2,
         p_address2                     IN VARCHAR2,
         p_city                         IN VARCHAR2,
         p_state                        IN VARCHAR2,
         p_province                     IN VARCHAR2,
         p_zip                          IN VARCHAR2,
         p_postal_code                  IN VARCHAR2,
         p_country                      IN VARCHAR2,
         p_reg_details                  IN fnd_registration_pkg.fnd_reg_details_ref_cursor,
         x_event_result                 OUT NOCOPY VARCHAR2)
return NUMBER
IS
    l_registration_id NUMBER;

BEGIN
    l_registration_id := fnd_registration_pkg.insert_reg(
         p_application_id,
         p_party_id,
         p_registration_type,
         p_requested_user_name,
         p_assigned_user_name,
         'INVITED',
         p_exists_in_fnd_user_flag,
         p_reg_details,
         p_user_title,
         p_first_name,
         p_middle_name,
         p_last_name,
         p_user_suffix,
         p_email_contact_point_id,
         p_email,
         p_phone_contact_point_id,
         p_phone_country_code,
         p_phone_area_code,
         p_phone,
         p_phone_extension,
         p_fax_contact_point_id,
         p_fax_country_code,
         p_fax_area_code,
         p_fax,
         p_fax_extension,
         p_language_code,
         p_time_zone,
         p_territory_code,
         p_location_id,
         p_address1,
         p_address2,
         p_city,
         p_state,
         p_province,
         p_zip,
         p_postal_code,
         p_country);
    x_event_result := publish_invitation_event(l_registration_id);
    return l_registration_id;

END invite;

function register(
         p_registration_key             IN VARCHAR2,
         p_application_id               IN NUMBER,
         p_party_id                     IN NUMBER,
         p_registration_type            IN VARCHAR2,
         p_requested_user_name          IN VARCHAR2,
         p_assigned_user_name           IN VARCHAR2,
         p_registration_status          IN VARCHAR2,
         p_exists_in_fnd_user_flag      IN VARCHAR2,
         p_user_title                   IN VARCHAR2,
         p_first_name                   IN VARCHAR2,
         p_middle_name                  IN VARCHAR2,
         p_last_name                    IN VARCHAR2,
         p_user_suffix                  IN VARCHAR2,
         p_email_contact_point_id       IN NUMBER,
         p_email                        IN VARCHAR2,
         p_phone_contact_point_id       IN NUMBER,
         p_phone_country_code           IN VARCHAR2,
         p_phone_area_code              IN VARCHAR2,
         p_phone                        IN VARCHAR2,
         p_phone_extension              IN VARCHAR2,
         p_fax_contact_point_id         IN NUMBER,
         p_fax_country_code             IN VARCHAR2,
         p_fax_area_code                IN VARCHAR2,
         p_fax                          IN VARCHAR2,
         p_fax_extension                IN VARCHAR2,
         p_language_code                IN VARCHAR2,
         p_time_zone                    IN VARCHAR2,
         p_territory_code               IN VARCHAR2,
         p_location_id                  IN NUMBER,
         p_address1                     IN VARCHAR2,
         p_address2                     IN VARCHAR2,
         p_city                         IN VARCHAR2,
         p_state                        IN VARCHAR2,
         p_province                     IN VARCHAR2,
         p_zip                          IN VARCHAR2,
         p_postal_code                  IN VARCHAR2,
         p_country                      IN VARCHAR2,
         p_reg_details                  IN fnd_registration_pkg.fnd_reg_details_ref_cursor,
         x_event_result                 OUT NOCOPY VARCHAR2)
return NUMBER
IS
    l_registration_id  NUMBER;
    my_val2            NUMBER;
    my_val             VARCHAR2(255);
BEGIN
    IF (p_registration_key = null)
    THEN
        l_registration_id := fnd_registration_pkg.insert_reg(
             p_application_id,
             p_party_id,
             p_registration_type,
             p_requested_user_name,
             p_assigned_user_name,
             'REGISTERED',
             p_exists_in_fnd_user_flag,
             p_reg_details,
             p_user_title,
             p_first_name,
             p_middle_name,
             p_last_name,
             p_user_suffix,
             p_email_contact_point_id,
             p_email,
             p_phone_contact_point_id,
             p_phone_country_code,
             p_phone_area_code,
             p_phone,
             p_phone_extension,
             p_fax_contact_point_id,
             p_fax_country_code,
             p_fax_area_code,
             p_fax,
             p_fax_extension,
             p_language_code,
             p_time_zone,
             p_territory_code,
             p_location_id,
             p_address1,
             p_address2,
             p_city,
             p_state,
             p_province,
             p_zip,
             p_postal_code,
             p_country);
        my_val := publish_registration_event(l_registration_id);
    ELSE
        l_registration_id := get_reg_id_from_key(p_registration_key);
        my_val2 := fnd_registration_pkg.insert_reg(
             p_application_id,
             p_party_id,
             p_registration_type,
             p_requested_user_name,
             p_assigned_user_name,                                                             'REGISTERED',
             p_exists_in_fnd_user_flag,
             p_reg_details,
             p_user_title,
             p_first_name,
             p_middle_name,
             p_last_name,
             p_user_suffix,
             p_email_contact_point_id,
             p_email,
             p_phone_contact_point_id,
             p_phone_country_code,
             p_phone_area_code,
             p_phone,
             p_phone_extension,
             p_fax_contact_point_id,
             p_fax_country_code,
             p_fax_area_code,
             p_fax,
             p_fax_extension,
             p_language_code,                                                                  p_time_zone,
             p_territory_code,
             p_location_id,
             p_address1,
             p_address2,
             p_city,
             p_state,
             p_province,
             p_zip,
             p_postal_code,
             p_country);
        x_event_result := publish_registration_event(l_registration_id);
    END IF;
    return l_registration_id;

END register;

procedure approve(
         p_registration_id              IN NUMBER,
         x_event_result                 OUT NOCOPY VARCHAR2)
IS
BEGIN
    fnd_registration_pkg.update_reg_status(p_registration_id, 'APPROVED');
    x_event_result := publish_approval_event(p_registration_id);

END approve;

procedure reject(
         p_registration_id              IN NUMBER,
         x_event_result                 OUT NOCOPY VARCHAR2)
IS
BEGIN
    fnd_registration_pkg.update_reg_status(p_registration_id, 'REJECTED');
    x_event_result := publish_rejection_event(p_registration_id);

END reject;

END FND_REGISTRATION_UTILS_PKG;


/
