--------------------------------------------------------
--  DDL for Package FND_REGISTRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_REGISTRATION_PKG" AUTHID CURRENT_USER as
/* $Header: AFREGS.pls 120.3 2005/11/04 14:36:10 rsheh noship $ */

/*
    This Ref Cursor is used to move around collections of
    FND_REGISTRATION_DETAILS rows.  This is a Ref Cursor instead of
    a row object to make it accessable from java, which it would not
    be otherwise
*/
TYPE fnd_reg_details_ref_cursor IS REF CURSOR RETURN fnd_registration_details%ROWTYPE;

/*
   Insert row method for FND_REGISTRATIONS
   RETURNS the new registration_id, generated from FND_REGISTRATIONS_S
*/
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
return NUMBER;

/*
   Update method for FND_REGISTRATIONS
   Based on REGISTRATION_ID
*/

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
         p_country                      IN VARCHAR2 default null);

/*
   Delete method for FND_REGISTRATIONS
   Deletes row specified by registration_id
*/
procedure delete_fnd_reg(
         p_registration_id              IN VARCHAR2);

/*
   Insert method for FND_REGISTRATION_DETAILS
*/
procedure insert_fnd_reg_details(
         p_registration_id              IN NUMBER,
         p_application_id               IN NUMBER,
         p_registration_type            IN VARCHAR2,
         p_field_name                   IN VARCHAR2,
         p_field_type                   IN VARCHAR2,
         p_field_format                 IN VARCHAR2 default null,
         p_field_value_string           IN VARCHAR2 default null,
         p_field_value_number           IN NUMBER   default null,
         p_field_value_date             IN DATE     default null);

/*
    Update Method for FND_REGISTRATION_DETAILS
    Updates row specified by REGISTRATION_ID + FIELD_NAME
*/
procedure update_fnd_reg_details(
         p_registration_id              IN NUMBER,
         p_field_name                   IN VARCHAR2,
         p_field_type                   IN VARCHAR2,
         p_field_format                 IN VARCHAR2 default null,
         p_field_value_string           IN VARCHAR2 default null,
         p_field_value_number           IN NUMBER   default null,
         p_field_value_date             IN DATE     default null);

/*
    Delete method for FND_REGISTRATION_DETAILS
    Updates row specified by REGISTRATION_ID + FIELD_NAME
*/
procedure delete_fnd_reg_details(
         p_registration_id              IN NUMBER,
         p_field_name                   IN VARCHAR2);

/*
    Updates registration status field only in FND_REGISTRATIONS
    Given a REGISTRATION_ID
*/
procedure update_reg_status(
         p_registration_id              IN NUMBER,
         p_new_status                   IN VARCHAR2);

/*
    Updates registraiton status field only in FND_REGISTRATIONS
    Given a REGISTRATION_KEY
*/
procedure update_reg_status_by_key(
         p_registration_key             IN VARCHAR2,
         p_new_status                   IN VARCHAR2);

/*
    Updates FND_REGISTRATIONS given a registration_key instead of
    id
*/
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
         p_country                      IN VARCHAR2 default null);

/*
    Deletes a row from FND_REGISTRATIONS given a REGISTRATION_KEY
    rather than a registration_id
*/
procedure delete_fnd_reg_by_key(
         p_registration_key             IN VARCHAR2);

/*
    Inserts a row in FND_REGISTRATIONS and some number of rows in
    FND_REGISTRATION_DETAILS.
    Caller needs to ensure that the cursor of details is not NULL
    (it can be empty).
    Returns the new registration_id generated from FND_REGISTRATIONS_S
*/
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
return NUMBER;

/*
    Updates both FND_REGISTRATIONS and FND_REGISTRATION_DETAILS
    The RefCursor should be not null
*/
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
         p_country                      IN VARCHAR2 default null);

/*
    Updates FND_REGISTRATIONS and FND_REGISTRATION_DETAILS
    using the registration_key as the PK rather than the registration_id
*/
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
         p_country                      IN VARCHAR2 default null);

/*
    Deletes an entire registration, from both FND_REGISTRATIONS
    and FND_REGISTRATION_DETAILS, given a registration_id
*/
procedure delete_reg(
         p_registration_id              IN NUMBER);

/*
    Deletes an entire registration, from both FND_REGISTRATIONS
    and FND_REGISTRATION_DETAILS, given a registration_key
*/
procedure delete_reg_by_key(
         p_registration_key             IN VARCHAR2);

/*
    Retrieves a row from FND_REGISTRATIONS
*/
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
         x_country                      OUT nocopy VARCHAR2);

/*
    Retrieves a row from FND_REGISTRATION_DETAILS
*/
procedure retrieve_fnd_reg_details(
         p_registration_id              IN  NUMBER,
         p_field_name                   IN  VARCHAR2,
         x_field_type                   OUT nocopy VARCHAR2,
         x_field_format                 OUT nocopy VARCHAR2,
         x_field_value_string           OUT nocopy VARCHAR2,
         x_field_value_number           OUT nocopy NUMBER,
         x_field_value_date             OUT nocopy DATE);

/*
    Retrieves the relevant row from FND_REGISTRATIONS;
    Also retrieves a cursor with the related details
*/
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
         x_reg_details                  OUT nocopy fnd_reg_details_ref_cursor);

/*
    Retrieves a registration including data from both
    FND_REGISTRATIONS and FND_REGISTRATION_DETAILS, but
    uses a registration_key instead of a registration_id
*/
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
         x_reg_details                  OUT nocopy fnd_reg_details_ref_cursor);

/*
    Retrieves an active registration (including details) given
    a username, application_id, and registration_type.
    NB: There should be no more that one registration not in status
    'REJECTED' with this triple.
    NB: An active registration is one which is not 'REJECTED'
*/
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
         x_reg_details                  OUT nocopy fnd_reg_details_ref_cursor);

/*
    Similar to retrieve_reg_by_user_name, but using party_id
    instead of user_name.  Once again, there should be no more than
    one active registration with this triple, or an exception will be
    thrown
*/
procedure retrieve_reg_by_party_id(
         p_party_id                     IN  NUMBER,
         p_application_id               IN NUMBER,
         P_registration_type            IN VARCHAR2,
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
         x_reg_details                  OUT nocopy fnd_reg_details_ref_cursor);

/*
    looks up the registration_id for a given registration_key.
    Returns the REGISTRATION_ID for that key; will throw an exception
    if the key is not in use
*/
function get_registration_id_from_key(
         p_registration_key             IN VARCHAR2)
return NUMBER;

/*
    looks up the registration_key for a given registration_id.
    Returns the REGISTRATION_KEY for that id; will throw an exception
    if the id is not in use
*/
function get_registration_key_from_id(
         p_registration_id              IN NUMBER)
return VARCHAR2;

end FND_REGISTRATION_PKG;


 

/
