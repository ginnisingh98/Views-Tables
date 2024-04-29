--------------------------------------------------------
--  DDL for Package Body FND_REGISTRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_REGISTRATION_PKG" as
/* $Header: AFREGB.pls 120.2 2005/11/04 12:40:39 rsheh noship $ */

function insert_fnd_reg(
         p_application_id               IN NUMBER,
         p_party_id                     IN NUMBER,
         p_registration_type            IN VARCHAR2,
         p_requested_user_name          IN VARCHAR2,
         p_assigned_user_name           IN VARCHAR2,
         p_registration_status          IN VARCHAR2,
         p_exists_in_fnd_user_flag      IN VARCHAR2,
         p_user_title                   IN VARCHAR2 default null,
         p_first_name                   IN VARCHAR2 default null,
         p_middle_name                  IN VARCHAR2 default null,
         p_last_name                    IN VARCHAR2 default null,
         p_user_suffix                  IN VARCHAR2 default null,
         p_email_contact_point_id       IN NUMBER   default null,
         p_email                        IN VARCHAR2 default null,
         p_phone_contact_point_id       IN NUMBER   default null,
         p_phone_country_code           IN VARCHAR2 default null,
         p_phone_area_code              IN VARCHAR2 default null,
         p_phone                        IN VARCHAR2 default null,
         p_phone_extension              IN VARCHAR2 default null,
         p_fax_contact_point_id         IN NUMBER   default null,
         p_fax_country_code             IN VARCHAR2 default null,
         p_fax_area_code                IN VARCHAR2 default null,
         p_fax                          IN VARCHAR2 default null,
         p_fax_extension                IN VARCHAR2 default null,
         p_language_code                IN VARCHAR2 default null,
         p_time_zone                    IN VARCHAR2 default null,
         p_territory_code               IN VARCHAR2 default null,
         p_location_id                  IN NUMBER   default null,
         p_address1                     IN VARCHAR2 default null,
         p_address2                     IN VARCHAR2 default null,
         p_city                         IN VARCHAR2 default null,
         p_state                        IN VARCHAR2 default null,
         p_province                     IN VARCHAR2 default null,
         p_zip                          IN VARCHAR2 default null,
         p_postal_code                  IN VARCHAR2 default null,
         p_country                      IN VARCHAR2 default null)
return NUMBER
IS
    l_registration_id   NUMBER;

BEGIN

    select fnd_registrations_s.nextval
    into l_registration_id
    from dual;

-- Note that this does not set the registration_key field.
-- For now this can only be set in the middle tier.

    INSERT INTO fnd_registrations(
        registration_id,
        registration_key,
        application_id,
        party_id,
        registration_type,
        requested_user_name,
        assigned_user_name,
        registration_status,
        exists_in_fnd_user_flag,
        user_title,
        first_name,
        middle_name,
        last_name,
        user_suffix,
        email_contact_point_id,
        email,
        phone_contact_point_id,
        phone_country_code,
        phone_area_code,
        phone,
        phone_extension,
        fax_contact_point_id,
        fax_country_code,
        fax_area_code,
        fax,
        fax_extension,
        language_code,
        time_zone,
        territory_code,
        location_id,
        address1,
        address2,
        city,
        state,
        province,
        zip,
        postal_code,
        country,
        date_requested,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        last_update_login
    )VALUES(
        l_registration_id,
        l_registration_id,
        p_application_id,
        p_party_id,
        p_registration_type,
        p_requested_user_name,
        p_assigned_user_name,
        p_registration_status,
        p_exists_in_fnd_user_flag,
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
        p_country,
        sysdate,
        sysdate,
        fnd_global.user_id,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id
    );
    return l_registration_id;

END insert_fnd_reg;



procedure update_fnd_reg(
         p_registration_id              IN NUMBER,
         p_application_id               IN NUMBER,
         p_party_id                     IN NUMBER,
         p_registration_type            IN VARCHAR2,
         p_requested_user_name          IN VARCHAR2,
         p_assigned_user_name           IN VARCHAR2,
         p_registration_status          IN VARCHAR2,
         p_exists_in_fnd_user_flag      IN VARCHAR2,
         p_user_title                   IN VARCHAR2 default null,
         p_first_name                   IN VARCHAR2 default null,
         p_middle_name                  IN VARCHAR2 default null,
         p_last_name                    IN VARCHAR2 default null,
         p_user_suffix                  IN VARCHAR2 default null,
         p_email_contact_point_id       IN NUMBER   default null,
         p_email                        IN VARCHAR2 default null,
         p_phone_contact_point_id       IN NUMBER   default null,
         p_phone_country_code           IN VARCHAR2 default null,
         p_phone_area_code              IN VARCHAR2 default null,
         p_phone                        IN VARCHAR2 default null,
         p_phone_extension              IN VARCHAR2 default null,
         p_fax_contact_point_id         IN NUMBER   default null,
         p_fax_country_code             IN VARCHAR2 default null,
         p_fax_area_code                IN VARCHAR2 default null,
         p_fax                          IN VARCHAR2 default null,
         p_fax_extension                IN VARCHAR2 default null,
         p_language_code                IN VARCHAR2 default null,
         p_time_zone                    IN VARCHAR2 default null,
         p_territory_code               IN VARCHAR2 default null,
         p_location_id                  IN NUMBER   default null,
         p_address1                     IN VARCHAR2 default null,
         p_address2                     IN VARCHAR2 default null,
         p_city                         IN VARCHAR2 default null,
         p_state                        IN VARCHAR2 default null,
         p_province                     IN VARCHAR2 default null,
         p_zip                          IN VARCHAR2 default null,
         p_postal_code                  IN VARCHAR2 default null,
         p_country                      IN VARCHAR2 default null)
IS
BEGIN
    UPDATE fnd_registrations
    SET  application_id = p_application_id,
         party_id = p_party_id,
         registration_type = p_registration_type,
         requested_user_name = p_requested_user_name,
         assigned_user_name = p_assigned_user_name,
         registration_status = p_registration_status,
         exists_in_fnd_user_flag = p_exists_in_fnd_user_flag,
         user_title = p_user_title,
         first_name = p_first_name,
         middle_name = p_middle_name,
         last_name = p_last_name,
         user_suffix = p_user_suffix,
         email_contact_point_id = p_email_contact_point_id,
         email = p_email,
         phone_contact_point_id = p_phone_contact_point_id,
         phone_country_code = p_phone_country_code,
         phone_area_code = p_phone_area_code,
         phone = p_phone,
         phone_extension = p_phone_extension,
         fax_contact_point_id = p_fax_contact_point_id,
         fax_country_code = p_fax_country_code,
         fax_area_code = p_fax_area_code,
         fax = p_fax,
         fax_extension = p_fax_extension,
         language_code = p_language_code,
         time_zone = p_time_zone,
         territory_code = p_territory_code,
         location_id = p_location_id,
         address1 = p_address1,
         address2 = p_address2,
         city = p_city,
         state = p_state,
         province = p_province,
         zip = p_zip,
         postal_code = p_postal_code,
         country = p_country,
         last_update_date = sysdate,
         last_updated_by = fnd_global.user_id
    WHERE
         registration_id = p_registration_id;

END update_fnd_reg;


procedure delete_fnd_reg(
         p_registration_id              IN VARCHAR2)
IS
BEGIN
    DELETE from fnd_registrations
    WHERE registration_id = p_registration_id;

END delete_fnd_reg;

procedure insert_fnd_reg_details(
         p_registration_id              IN NUMBER,
         p_application_id               IN NUMBER,
         p_registration_type            IN VARCHAR2,
         p_field_name                   IN VARCHAR2,
         p_field_type                   IN VARCHAR2,
         p_field_format                 IN VARCHAR2 default null,
         p_field_value_string           IN VARCHAR2 default null,
         p_field_value_number           IN NUMBER   default null,
         p_field_value_date             IN DATE     default null)
IS
BEGIN
    INSERT INTO fnd_registration_details(
        registration_id,
        application_id,
        registration_type,
        field_name,
        field_type,
        field_format,
        field_value_string,
        field_value_number,
        field_value_date,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        last_update_login
    )VALUES(
        p_registration_id,
        p_application_id,
        p_registration_type,
        p_field_name,
        p_field_type,
        p_field_format,
        p_field_value_string,
        p_field_value_number,
        p_field_value_date,
        sysdate,
        fnd_global.user_id,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id
    );
END insert_fnd_reg_details;

procedure update_fnd_reg_details(
         p_registration_id              IN NUMBER,
         p_field_name                   IN VARCHAR2,
         p_field_type                   IN VARCHAR2,
         p_field_format                 IN VARCHAR2 default null,
         p_field_value_string           IN VARCHAR2 default null,
         p_field_value_number           IN NUMBER   default null,
         p_field_value_date             IN DATE     default null)
IS
BEGIN
    UPDATE fnd_registration_details
    SET  field_type = p_field_type,
         field_format = p_field_format,
         field_value_string = p_field_value_string,
         field_value_number = p_field_value_number,
         field_value_date   = p_field_value_date,
         last_update_date = sysdate,
         last_updated_by = fnd_global.user_id
    WHERE registration_id = p_registration_id
    AND  field_name = p_field_name;

END update_fnd_reg_details;

procedure delete_fnd_reg_details(
         p_registration_id              IN NUMBER,
         p_field_name                   IN VARCHAR2)
IS
BEGIN
    DELETE FROM fnd_registration_details
    WHERE registration_id = p_registration_id
    AND field_name = p_field_name;

END delete_fnd_reg_details;


procedure update_reg_status(
         p_registration_id              IN NUMBER,
         p_new_status                   IN VARCHAR2)
IS
BEGIN
    UPDATE fnd_registrations
    SET registration_status = p_new_status,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id
    WHERE registration_id = p_registration_id;

END update_reg_status;

procedure update_reg_status_by_key(
         p_registration_key             IN VARCHAR2,
         p_new_status                   IN VARCHAR2)
IS
    l_registration_id NUMBER;
BEGIN
    l_registration_id := get_registration_id_from_key(p_registration_key);
    update_reg_status(l_registration_id, p_new_status);

END update_reg_status_by_key;

procedure update_fnd_reg_by_key(
         p_registration_key             IN VARCHAR2,
         p_application_id               IN NUMBER,
         p_party_id                     IN NUMBER,
         p_registration_type            IN VARCHAR2,
         p_requested_user_name          IN VARCHAR2,
         p_assigned_user_name           IN VARCHAR2,
         p_registration_status          IN VARCHAR2,
         p_exists_in_fnd_user_flag      IN VARCHAR2,
         p_user_title                   IN VARCHAR2 default null,
         p_first_name                   IN VARCHAR2 default null,
         p_middle_name                  IN VARCHAR2 default null,
         p_last_name                    IN VARCHAR2 default null,
         p_user_suffix                  IN VARCHAR2 default null,
         p_email_contact_point_id       IN NUMBER   default null,
         p_email                        IN VARCHAR2 default null,
         p_phone_contact_point_id       IN NUMBER   default null,
         p_phone_country_code           IN VARCHAR2 default null,
         p_phone_area_code              IN VARCHAR2 default null,
         p_phone                        IN VARCHAR2 default null,
         p_phone_extension              IN VARCHAR2 default null,
         p_fax_contact_point_id         IN NUMBER   default null,
         p_fax_country_code             IN VARCHAR2 default null,
         p_fax_area_code                IN VARCHAR2 default null,
         p_fax                          IN VARCHAR2 default null,
         p_fax_extension                IN VARCHAR2 default null,
         p_language_code                IN VARCHAR2 default null,
         p_time_zone                    IN VARCHAR2 default null,
         p_territory_code               IN VARCHAR2 default null,
         p_location_id                  IN NUMBER   default null,
         p_address1                     IN VARCHAR2 default null,
         p_address2                     IN VARCHAR2 default null,
         p_city                         IN VARCHAR2 default null,
         p_state                        IN VARCHAR2 default null,
         p_province                     IN VARCHAR2 default null,
         p_zip                          IN VARCHAR2 default null,
         p_postal_code                  IN VARCHAR2 default null,
         p_country                      IN VARCHAR2 default null)
IS
    l_registration_id NUMBER;
BEGIN
    l_registration_id := get_registration_id_from_key(p_registration_key);
    update_fnd_reg(
         l_registration_id,
         p_application_id,
         p_party_id,
         p_registration_type,
         p_requested_user_name,
         p_assigned_user_name,
         p_registration_status,
         p_exists_in_fnd_user_flag,
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
END update_fnd_reg_by_key;



procedure delete_fnd_reg_by_key(
         p_registration_key             IN VARCHAR2)
IS
    l_registration_id NUMBER;
BEGIN
    l_registration_id :=  get_registration_id_from_key(p_registration_key);
    delete_fnd_reg(l_registration_id);

END delete_fnd_reg_by_key;


function insert_reg(
         p_application_id               IN NUMBER,
         p_party_id                     IN NUMBER,
         p_registration_type            IN VARCHAR2,
         p_requested_user_name          IN VARCHAR2,
         p_assigned_user_name           IN VARCHAR2,
         p_registration_status          IN VARCHAR2,
         p_exists_in_fnd_user_flag      IN VARCHAR2,
         p_reg_details                  IN fnd_reg_details_ref_cursor,
         p_user_title                   IN VARCHAR2 default null,
         p_first_name                   IN VARCHAR2 default null,
         p_middle_name                  IN VARCHAR2 default null,
         p_last_name                    IN VARCHAR2 default null,
         p_user_suffix                  IN VARCHAR2 default null,
         p_email_contact_point_id       IN NUMBER   default null,
         p_email                        IN VARCHAR2 default null,
         p_phone_contact_point_id       IN NUMBER   default null,
         p_phone_country_code           IN VARCHAR2 default null,
         p_phone_area_code              IN VARCHAR2 default null,
         p_phone                        IN VARCHAR2 default null,
         p_phone_extension              IN VARCHAR2 default null,
         p_fax_contact_point_id         IN NUMBER   default null,
         p_fax_country_code             IN VARCHAR2 default null,
         p_fax_area_code                IN VARCHAR2 default null,
         p_fax                          IN VARCHAR2 default null,
         p_fax_extension                IN VARCHAR2 default null,
         p_language_code                IN VARCHAR2 default null,
         p_time_zone                    IN VARCHAR2 default null,
         p_territory_code               IN VARCHAR2 default null,
         p_location_id                  IN NUMBER   default null,
         p_address1                     IN VARCHAR2 default null,
         p_address2                     IN VARCHAR2 default null,
         p_city                         IN VARCHAR2 default null,
         p_state                        IN VARCHAR2 default null,
         p_province                     IN VARCHAR2 default null,
         p_zip                          IN VARCHAR2 default null,
         p_postal_code                  IN VARCHAR2 default null,
         p_country                      IN VARCHAR2 default null)
return NUMBER
IS
    l_registration_id   NUMBER;

    l_ri_cur            NUMBER;
    l_ai_cur            NUMBER;
    l_rt_cur            VARCHAR2(255);
    l_lud_cur           DATE;
    l_lub_cur           NUMBER;
    l_cb_cur            NUMBER;
    l_cd_cur            DATE;
    l_lul_cur           NUMBER;

    l_field_name        VARCHAR2(255);
    l_field_type        VARCHAR2(255);
    l_field_format      VARCHAR2(255);
    l_field_value_string    VARCHAR2(4000);
    l_field_value_number    NUMBER;
    l_field_value_date      DATE;
BEGIN

-- For fnd_registrations
-- Remember registration_key is not set this way

    l_registration_id := insert_fnd_reg(
         p_application_id,
         p_party_id,
         p_registration_type,
         p_requested_user_name,
         p_assigned_user_name,
         p_registration_status,
         p_exists_in_fnd_user_flag,
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

-- for fnd_registration_details
-- loops through the ref_cursor
-- Note this is primarily a REF Cursor because
-- Java cannot support records and tables

    --OPEN p_reg_details;
    LOOP
        FETCH p_reg_details
        INTO l_ri_cur,
             l_ai_cur,
             l_rt_cur,
             l_field_name,
             l_field_type,
             l_field_format,
             l_field_value_string,
             l_field_value_number,
             l_field_value_date,
             l_lud_cur,
             l_lub_cur,
             l_cb_cur,
             l_cd_cur,
             l_lul_cur;
        insert_fnd_reg_details(
             l_registration_id,
             p_application_id,
             p_registration_type,
             l_field_name,
             l_field_type,
             l_field_format,
             l_field_value_string,
             l_field_value_number,
             l_field_value_date
        );
        EXIT WHEN p_reg_details%NOTFOUND;
    END LOOP;
    --CLOSE p_reg_details;

END insert_reg;

procedure update_reg(
         p_registration_id              IN VARCHAR2,
         p_application_id               IN NUMBER,
         p_party_id                     IN NUMBER,
         p_registration_type            IN VARCHAR2,
         p_requested_user_name          IN VARCHAR2,
         p_assigned_user_name           IN VARCHAR2,
         p_registration_status          IN VARCHAR2,
         p_exists_in_fnd_user_flag      IN VARCHAR2,
         p_reg_details                  IN fnd_reg_details_ref_cursor,
         p_user_title                   IN VARCHAR2 default null,
         p_first_name                   IN VARCHAR2 default null,
         p_middle_name                  IN VARCHAR2 default null,
         p_last_name                    IN VARCHAR2 default null,
         p_user_suffix                  IN VARCHAR2 default null,
         p_email_contact_point_id       IN NUMBER   default null,
         p_email                        IN VARCHAR2 default null,
         p_phone_contact_point_id       IN NUMBER   default null,
         p_phone_country_code           IN VARCHAR2 default null,
         p_phone_area_code              IN VARCHAR2 default null,
         p_phone                        IN VARCHAR2 default null,
         p_phone_extension              IN VARCHAR2 default null,
         p_fax_contact_point_id         IN NUMBER   default null,
         p_fax_country_code             IN VARCHAR2 default null,
         p_fax_area_code                IN VARCHAR2 default null,
         p_fax                          IN VARCHAR2 default null,
         p_fax_extension                IN VARCHAR2 default null,
         p_language_code                IN VARCHAR2 default null,
         p_time_zone                    IN VARCHAR2 default null,
         p_territory_code               IN VARCHAR2 default null,
         p_location_id                  IN NUMBER   default null,
         p_address1                     IN VARCHAR2 default null,
         p_address2                     IN VARCHAR2 default null,
         p_city                         IN VARCHAR2 default null,
         p_state                        IN VARCHAR2 default null,
         p_province                     IN VARCHAR2 default null,
         p_zip                          IN VARCHAR2 default null,
         p_postal_code                  IN VARCHAR2 default null,
         p_country                      IN VARCHAR2 default null)
IS
    l_registration_id   NUMBER;

    l_ri_cur            NUMBER;
    l_ai_cur            NUMBER;
    l_rt_cur            VARCHAR2(255);
    l_lud_cur           DATE;
    l_lub_cur           NUMBER;
    l_cb_cur            NUMBER;
    l_cd_cur            DATE;
    l_lul_cur           NUMBER;

    l_field_name        VARCHAR2(255);
    l_field_type        VARCHAR2(255);
    l_field_format      VARCHAR2(255);
    l_field_value_string    VARCHAR2(4000);
    l_field_value_number    NUMBER;
    l_field_value_date      DATE;
BEGIN

-- Do update_fnd_registrations first

    update_fnd_reg(
         p_registration_id,
         p_application_id,
         p_party_id,
         p_registration_type,
         p_requested_user_name,
         p_assigned_user_name,
         p_registration_status,
         p_exists_in_fnd_user_flag,
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

-- Now do update fnd_registration_details

    LOOP
        FETCH p_reg_details
        INTO l_ri_cur,
             l_ai_cur,
             l_rt_cur,
             l_field_name,
             l_field_type,
             l_field_format,
             l_field_value_string,
             l_field_value_number,
             l_field_value_date,
             l_lud_cur,
             l_lub_cur,
             l_cb_cur,
             l_cd_cur,
             l_lul_cur;
        insert_fnd_reg_details(
             l_registration_id,
             p_application_id,
             p_registration_type,
             l_field_name,
             l_field_type,
             l_field_format,
             l_field_value_string,
             l_field_value_number,
             l_field_value_date
        );
        EXIT WHEN p_reg_details%NOTFOUND;
    END LOOP;

END update_reg;

procedure update_reg_by_key(
         p_registration_key             IN VARCHAR2,
         p_application_id               IN NUMBER,
         p_party_id                     IN NUMBER,
         p_registration_type            IN VARCHAR2,
         p_requested_user_name          IN VARCHAR2,
         p_assigned_user_name           IN VARCHAR2,
         p_registration_status          IN VARCHAR2,
         p_exists_in_fnd_user_flag      IN VARCHAR2,
         p_reg_details                  IN fnd_reg_details_ref_cursor,
         p_user_title                   IN VARCHAR2 default null,
         p_first_name                   IN VARCHAR2 default null,
         p_middle_name                  IN VARCHAR2 default null,
         p_last_name                    IN VARCHAR2 default null,
         p_user_suffix                  IN VARCHAR2 default null,
         p_email_contact_point_id       IN NUMBER   default null,
         p_email                        IN VARCHAR2 default null,
         p_phone_contact_point_id       IN NUMBER   default null,
         p_phone_country_code           IN VARCHAR2 default null,
         p_phone_area_code              IN VARCHAR2 default null,
         p_phone                        IN VARCHAR2 default null,
         p_phone_extension              IN VARCHAR2 default null,
         p_fax_contact_point_id         IN NUMBER   default null,
         p_fax_country_code             IN VARCHAR2 default null,
         p_fax_area_code                IN VARCHAR2 default null,
         p_fax                          IN VARCHAR2 default null,
         p_fax_extension                IN VARCHAR2 default null,
         p_language_code                IN VARCHAR2 default null,
         p_time_zone                    IN VARCHAR2 default null,
         p_territory_code               IN VARCHAR2 default null,
         p_location_id                  IN NUMBER   default null,
         p_address1                     IN VARCHAR2 default null,
         p_address2                     IN VARCHAR2 default null,
         p_city                         IN VARCHAR2 default null,
         p_state                        IN VARCHAR2 default null,
         p_province                     IN VARCHAR2 default null,
         p_zip                          IN VARCHAR2 default null,
         p_postal_code                  IN VARCHAR2 default null,
         p_country                      IN VARCHAR2 default null)
IS
    l_registration_id NUMBER;
BEGIN
    l_registration_id := get_registration_id_from_key(p_registration_key);

    update_reg(
         l_registration_id,
         p_application_id,
         p_party_id,
         p_registration_type,
         p_requested_user_name,
         p_assigned_user_name,
         p_registration_status,
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

END update_reg_by_key;


procedure delete_reg(
         p_registration_id              IN NUMBER)
IS
BEGIN
    DELETE FROM fnd_registration_details
    WHERE registration_id = p_registration_id;

    DELETE FROM fnd_registrations
    WHERE registration_id = p_registration_id;
END;

procedure delete_reg_by_key(
         p_registration_key             IN VARCHAR2)
IS
    l_registration_id NUMBER;
BEGIN
    l_registration_id := get_registration_id_from_key(p_registration_key);
    delete_reg(l_registration_id);
END delete_reg_by_key;

procedure retrieve_fnd_reg(
         p_registration_id              IN  NUMBER,
         x_application_id               OUT nocopy NUMBER,
         x_party_id                     OUT nocopy NUMBER,
         x_registration_type            OUT nocopy VARCHAR2,
         x_requested_user_name          OUT nocopy VARCHAR2,
         x_assigned_user_name           OUT nocopy VARCHAR2,
         x_registration_status          OUT nocopy VARCHAR2,
         x_exists_in_fnd_user_flag      OUT nocopy VARCHAR2,
         x_user_title                   OUT nocopy VARCHAR2,
         x_first_name                   OUT nocopy VARCHAR2,
         x_middle_name                  OUT nocopy VARCHAR2,
         x_last_name                    OUT nocopy VARCHAR2,
         x_user_suffix                  OUT nocopy VARCHAR2,
         x_email_contact_point_id       OUT nocopy NUMBER,
         x_email                        OUT nocopy VARCHAR2,
         x_phone_contact_point_id       OUT nocopy NUMBER,
         x_phone_country_code           OUT nocopy VARCHAR2,
         x_phone_area_code              OUT nocopy VARCHAR2,
         x_phone                        OUT nocopy VARCHAR2,
         x_phone_extension              OUT nocopy VARCHAR2,
         x_fax_contact_point_id         OUT nocopy NUMBER,
         x_fax_country_code             OUT nocopy VARCHAR2,
         x_fax_area_code                OUT nocopy VARCHAR2,
         x_fax                          OUT nocopy VARCHAR2,
         x_fax_extension                OUT nocopy VARCHAR2,
         x_language_code                OUT nocopy VARCHAR2,
         x_time_zone                    OUT nocopy VARCHAR2,
         x_territory_code               OUT nocopy VARCHAR2,
         x_location_id                  OUT nocopy NUMBER,
         x_address1                     OUT nocopy VARCHAR2,
         x_address2                     OUT nocopy VARCHAR2,
         x_city                         OUT nocopy VARCHAR2,
         x_state                        OUT nocopy VARCHAR2,
         x_province                     OUT nocopy VARCHAR2,
         x_zip                          OUT nocopy VARCHAR2,
         x_postal_code                  OUT nocopy VARCHAR2,
         x_country                      OUT nocopy VARCHAR2)
IS
BEGIN
    SELECT application_id,
           party_id,
           registration_type,
           requested_user_name,
           assigned_user_name,
           registration_status,
           exists_in_fnd_user_flag,
           user_title,
           first_name,
           middle_name,
           last_name,
           user_suffix,
           email_contact_point_id,
           email,
           phone_contact_point_id,
           phone_country_code,
           phone_area_code,
           phone,
           phone_extension,
           fax_contact_point_id,
           fax_country_code,
           fax_area_code,
           fax,
           fax_extension,
           language_code,
           time_zone,
           territory_code,
           location_id,
           address1,
           address2,
           city,
           state,
           province,
           zip,
           postal_code,
           country
    INTO   x_application_id,
           x_party_id,
           x_registration_type,
           x_requested_user_name,
           x_assigned_user_name,
           x_registration_status,
           x_exists_in_fnd_user_flag,
           x_user_title,
           x_first_name,
           x_middle_name,
           x_last_name,
           x_user_suffix,
           x_email_contact_point_id,
           x_email,
           x_phone_contact_point_id,
           x_phone_country_code,
           x_phone_area_code,
           x_phone,
           x_phone_extension,
           x_fax_contact_point_id,
           x_fax_country_code,
           x_fax_area_code,
           x_fax,
           x_fax_extension,
           x_language_code,
           x_time_zone,
           x_territory_code,
           x_location_id,
           x_address1,
           x_address2,
           x_city,
           x_state,
           x_province,
           x_zip,
           x_postal_code,
           x_country
    FROM fnd_registrations
    WHERE registration_id = p_registration_id;

END retrieve_fnd_reg;

procedure retrieve_fnd_reg_details(
         p_registration_id              IN  NUMBER,
         p_field_name                   IN  VARCHAR2,
         x_field_type                   OUT nocopy VARCHAR2,
         x_field_format                 OUT nocopy VARCHAR2,
         x_field_value_string           OUT nocopy VARCHAR2,
         x_field_value_number           OUT nocopy NUMBER,
         x_field_value_date             OUT nocopy DATE)
IS
BEGIN
    SELECT field_type,
           field_format,
           field_value_string,
           field_value_number,
           field_value_date
    INTO x_field_type,
         x_field_format,
         x_field_value_string,
         x_field_value_number,
         x_field_value_date
    FROM  fnd_registration_details
    WHERE registration_id = p_registration_id
    AND   field_name = p_field_name;
END retrieve_fnd_reg_details;

procedure retrieve_reg(
         p_registration_id              IN  NUMBER,
         x_application_id               OUT nocopy NUMBER,
         x_party_id                     OUT nocopy NUMBER,
         x_registration_type            OUT nocopy VARCHAR2,
         x_requested_user_name          OUT nocopy VARCHAR2,
         x_assigned_user_name           OUT nocopy VARCHAR2,
         x_registration_status          OUT nocopy VARCHAR2,
         x_exists_in_fnd_user_flag      OUT nocopy VARCHAR2,
         x_user_title                   OUT nocopy VARCHAR2,
         x_first_name                   OUT nocopy VARCHAR2,
         x_middle_name                  OUT nocopy VARCHAR2,
         x_last_name                    OUT nocopy VARCHAR2,
         x_user_suffix                  OUT nocopy VARCHAR2,
         x_email_contact_point_id       OUT nocopy NUMBER,
         x_email                        OUT nocopy VARCHAR2,
         x_phone_contact_point_id       OUT nocopy NUMBER,
         x_phone_country_code           OUT nocopy VARCHAR2,
         x_phone_area_code              OUT nocopy VARCHAR2,
         x_phone                        OUT nocopy VARCHAR2,
         x_phone_extension              OUT nocopy VARCHAR2,
         x_fax_contact_point_id         OUT nocopy NUMBER,
         x_fax_country_code             OUT nocopy VARCHAR2,
         x_fax_area_code                OUT nocopy VARCHAR2,
         x_fax                          OUT nocopy VARCHAR2,
         x_fax_extension                OUT nocopy VARCHAR2,
         x_language_code                OUT nocopy VARCHAR2,
         x_time_zone                    OUT nocopy VARCHAR2,
         x_territory_code               OUT nocopy VARCHAR2,
         x_location_id                  OUT nocopy NUMBER,
         x_address1                     OUT nocopy VARCHAR2,
         x_address2                     OUT nocopy VARCHAR2,
         x_city                         OUT nocopy VARCHAR2,
         x_state                        OUT nocopy VARCHAR2,
         x_province                     OUT nocopy VARCHAR2,
         x_zip                          OUT nocopy VARCHAR2,
         x_postal_code                  OUT nocopy VARCHAR2,
         x_country                      OUT nocopy VARCHAR2,
         x_reg_details                  OUT nocopy fnd_reg_details_ref_cursor)
IS
BEGIN

-- populate from fnd_registrations first

   retrieve_fnd_reg(
           p_registration_id,
           x_application_id,
           x_party_id,
           x_registration_type,
           x_requested_user_name,
           x_assigned_user_name,
           x_registration_status,
           x_exists_in_fnd_user_flag,
           x_user_title,
           x_first_name,
           x_middle_name,
           x_last_name,
           x_user_suffix,
           x_email_contact_point_id,
           x_email,
           x_phone_contact_point_id,
           x_phone_country_code,
           x_phone_area_code,
           x_phone,
           x_phone_extension,
           x_fax_contact_point_id,
           x_fax_country_code,
           x_fax_area_code,
           x_fax,
           x_fax_extension,
           x_language_code,
           x_time_zone,
           x_territory_code,
           x_location_id,
           x_address1,
           x_address2,
           x_city,
           x_state,
           x_province,
           x_zip,
           x_postal_code,
           x_country);

-- Now do registration details.

    OPEN x_reg_details FOR
    SELECT  registration_id,
            application_id,
            registration_type,
            field_name,
            field_type,
            field_format,
            field_value_string,
            field_value_number,
            field_value_date,
            last_update_date,
            last_updated_by,
            created_by,
            creation_date,
            last_update_login
    FROM fnd_registration_details
    WHERE registration_id = p_registration_id;

END retrieve_reg;

procedure retrieve_invited_reg(
         p_registration_key             IN  VARCHAR2,
         x_application_id               OUT nocopy NUMBER,
         x_party_id                     OUT nocopy NUMBER,
         x_registration_type            OUT nocopy VARCHAR2,
         x_requested_user_name          OUT nocopy VARCHAR2,
         x_assigned_user_name           OUT nocopy VARCHAR2,
         x_registration_status          OUT nocopy VARCHAR2,
         x_exists_in_fnd_user_flag      OUT nocopy VARCHAR2,
         x_user_title                   OUT nocopy VARCHAR2,
         x_first_name                   OUT nocopy VARCHAR2,
         x_middle_name                  OUT nocopy VARCHAR2,
         x_last_name                    OUT nocopy VARCHAR2,
         x_user_suffix                  OUT nocopy VARCHAR2,
         x_email_contact_point_id       OUT nocopy NUMBER,
         x_email                        OUT nocopy VARCHAR2,
         x_phone_contact_point_id       OUT nocopy NUMBER,
         x_phone_country_code           OUT nocopy VARCHAR2,
         x_phone_area_code              OUT nocopy VARCHAR2,
         x_phone                        OUT nocopy VARCHAR2,
         x_phone_extension              OUT nocopy VARCHAR2,
         x_fax_contact_point_id         OUT nocopy NUMBER,
         x_fax_country_code             OUT nocopy VARCHAR2,
         x_fax_area_code                OUT nocopy VARCHAR2,
         x_fax                          OUT nocopy VARCHAR2,
         x_fax_extension                OUT nocopy VARCHAR2,
         x_language_code                OUT nocopy VARCHAR2,
         x_time_zone                    OUT nocopy VARCHAR2,
         x_territory_code               OUT nocopy VARCHAR2,
         x_location_id                  OUT nocopy NUMBER,
         x_address1                     OUT nocopy VARCHAR2,
         x_address2                     OUT nocopy VARCHAR2,
         x_city                         OUT nocopy VARCHAR2,
         x_state                        OUT nocopy VARCHAR2,
         x_province                     OUT nocopy VARCHAR2,
         x_zip                          OUT nocopy VARCHAR2,
         x_postal_code                  OUT nocopy VARCHAR2,
         x_country                      OUT nocopy VARCHAR2,
         x_reg_details                  OUT nocopy fnd_reg_details_ref_cursor)
IS
    l_registration_id NUMBER;
BEGIN
    l_registration_id := get_registration_id_from_key(p_registration_key);
    retrieve_reg(
         l_registration_id,
         x_application_id,
         x_party_id,
         x_registration_type,
         x_requested_user_name,
         x_assigned_user_name,
         x_registration_status,
         x_exists_in_fnd_user_flag,
         x_user_title,
         x_first_name,
         x_middle_name,
         x_last_name,
         x_user_suffix,
         x_email_contact_point_id,
         x_email,
         x_phone_contact_point_id,
         x_phone_country_code,
         x_phone_area_code,
         x_phone,
         x_phone_extension,
         x_fax_contact_point_id,
         x_fax_country_code,
         x_fax_area_code,
         x_fax,
         x_fax_extension,
         x_language_code,
         x_time_zone,
         x_territory_code,
         x_location_id,
         x_address1,
         x_address2,
         x_city,
         x_state,
         x_province,
         x_zip,
         x_postal_code,
         x_country,
         x_reg_details);

END retrieve_invited_reg;

procedure retrieve_reg_by_username(
         p_assigned_user_name           IN  VARCHAR2,
         p_application_id               IN  NUMBER,
         p_registration_type            IN  VARCHAR2,
         x_party_id                     OUT nocopy NUMBER,
         x_registration_status          OUT nocopy VARCHAR2,
         x_exists_in_fnd_user_flag      OUT nocopy VARCHAR2,
         x_user_title                   OUT nocopy VARCHAR2,
         x_first_name                   OUT nocopy VARCHAR2,
         x_middle_name                  OUT nocopy VARCHAR2,
         x_last_name                    OUT nocopy VARCHAR2,
         x_user_suffix                  OUT nocopy VARCHAR2,
         x_email_contact_point_id       OUT nocopy NUMBER,
         x_email                        OUT nocopy VARCHAR2,
         x_phone_contact_point_id       OUT nocopy NUMBER,
         x_phone_country_code           OUT nocopy VARCHAR2,
         x_phone_area_code              OUT nocopy VARCHAR2,
         x_phone                        OUT nocopy VARCHAR2,
         x_phone_extension              OUT nocopy VARCHAR2,
         x_fax_contact_point_id         OUT nocopy NUMBER,
         x_fax_country_code             OUT nocopy VARCHAR2,
         x_fax_area_code                OUT nocopy VARCHAR2,
         x_fax                          OUT nocopy VARCHAR2,
         x_fax_extension                OUT nocopy VARCHAR2,
         x_language_code                OUT nocopy VARCHAR2,
         x_time_zone                    OUT nocopy VARCHAR2,
         x_territory_code               OUT nocopy VARCHAR2,
         x_location_id                  OUT nocopy NUMBER,
         x_address1                     OUT nocopy VARCHAR2,
         x_address2                     OUT nocopy VARCHAR2,
         x_city                         OUT nocopy VARCHAR2,
         x_state                        OUT nocopy VARCHAR2,
         x_province                     OUT nocopy VARCHAR2,
         x_zip                          OUT nocopy VARCHAR2,
         x_postal_code                  OUT nocopy VARCHAR2,
         x_country                      OUT nocopy VARCHAR2,
         x_reg_details                  OUT nocopy fnd_reg_details_ref_cursor)
IS
    l_registration_id NUMBER;
    l_application_id  NUMBER;
    l_registration_type VARCHAR2(255);
    l_requested_user_name VARCHAR2(100);
    l_assigned_user_name VARCHAR2(100);
BEGIN
    SELECT registration_id
    INTO l_registration_id
    FROM fnd_registrations
    WHERE assigned_user_name = p_assigned_user_name
    AND   application_id = p_application_id
    AND   registration_type = p_registration_type;

    retrieve_reg(
         l_registration_id,
         l_application_id,
         x_party_id,
         l_registration_type,
         l_requested_user_name,
         l_assigned_user_name,
         x_registration_status,
         x_exists_in_fnd_user_flag,
         x_user_title,
         x_first_name,
         x_middle_name,
         x_last_name,
         x_user_suffix,
         x_email_contact_point_id,
         x_email,
         x_phone_contact_point_id,
         x_phone_country_code,
         x_phone_area_code,
         x_phone,
         x_phone_extension,
         x_fax_contact_point_id,
         x_fax_country_code,
         x_fax_area_code,
         x_fax,
         x_fax_extension,
         x_language_code,
         x_time_zone,
         x_territory_code,
         x_location_id,
         x_address1,
         x_address2,
         x_city,
         x_state,
         x_province,
         x_zip,
         x_postal_code,
         x_country,
         x_reg_details);

END retrieve_reg_by_username;


procedure retrieve_reg_by_party_id(
         p_party_id                     IN  NUMBER,
         p_application_id               IN  NUMBER,
         p_registration_type            IN  VARCHAR2,
         x_requested_user_name          OUT nocopy VARCHAR2,
         x_assigned_user_name           OUT nocopy VARCHAR2,
         x_registration_status          OUT nocopy VARCHAR2,
         x_exists_in_fnd_user_flag      OUT nocopy VARCHAR2,
         x_user_title                   OUT nocopy VARCHAR2,
         x_first_name                   OUT nocopy VARCHAR2,
         x_middle_name                  OUT nocopy VARCHAR2,
         x_last_name                    OUT nocopy VARCHAR2,
         x_user_suffix                  OUT nocopy VARCHAR2,
         x_email_contact_point_id       OUT nocopy NUMBER,
         x_email                        OUT nocopy VARCHAR2,
         x_phone_contact_point_id       OUT nocopy NUMBER,
         x_phone_country_code           OUT nocopy VARCHAR2,
         x_phone_area_code              OUT nocopy VARCHAR2,
         x_phone                        OUT nocopy VARCHAR2,
         x_phone_extension              OUT nocopy VARCHAR2,
         x_fax_contact_point_id         OUT nocopy NUMBER,
         x_fax_country_code             OUT nocopy VARCHAR2,
         x_fax_area_code                OUT nocopy VARCHAR2,
         x_fax                          OUT nocopy VARCHAR2,
         x_fax_extension                OUT nocopy VARCHAR2,
         x_language_code                OUT nocopy VARCHAR2,
         x_time_zone                    OUT nocopy VARCHAR2,
         x_territory_code               OUT nocopy VARCHAR2,
         x_location_id                  OUT nocopy NUMBER,
         x_address1                     OUT nocopy VARCHAR2,
         x_address2                     OUT nocopy VARCHAR2,
         x_city                         OUT nocopy VARCHAR2,
         x_state                        OUT nocopy VARCHAR2,
         x_province                     OUT nocopy VARCHAR2,
         x_zip                          OUT nocopy VARCHAR2,
         x_postal_code                  OUT nocopy VARCHAR2,
         x_country                      OUT nocopy VARCHAR2,
         x_reg_details                  OUT nocopy fnd_reg_details_ref_cursor)
IS
    l_registration_id  NUMBER;
    l_application_id   NUMBER;
    l_party_id         NUMBER;
    l_registration_type VARCHAR2(255);
BEGIN
    SELECT registration_id
    INTO l_registration_id
    FROM fnd_registrations
    WHERE registration_type = p_registration_type
    AND application_id = p_application_id
    AND party_id = p_party_id;

    retrieve_reg(
         l_registration_id,
         l_application_id,
         l_party_id,
         l_registration_type,
         x_requested_user_name,
         x_assigned_user_name,
         x_registration_status,
         x_exists_in_fnd_user_flag,
         x_user_title,
         x_first_name,
         x_middle_name,
         x_last_name,
         x_user_suffix,
         x_email_contact_point_id,
         x_email,
         x_phone_contact_point_id,
         x_phone_country_code,
         x_phone_area_code,
         x_phone,
         x_phone_extension,
         x_fax_contact_point_id,
         x_fax_country_code,
         x_fax_area_code,
         x_fax,
         x_fax_extension,
         x_language_code,
         x_time_zone,
         x_territory_code,
         x_location_id,
         x_address1,
         x_address2,
         x_city,
         x_state,
         x_province,
         x_zip,
         x_postal_code,
         x_country,
         x_reg_details);

END retrieve_reg_by_party_id;

function get_registration_id_from_key(
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

END get_registration_id_from_key;

function get_registration_key_from_id(
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

END get_registration_key_from_id;


end FND_REGISTRATION_PKG;


/
