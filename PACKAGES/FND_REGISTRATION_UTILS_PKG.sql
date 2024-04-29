--------------------------------------------------------
--  DDL for Package FND_REGISTRATION_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_REGISTRATION_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: AFREGUS.pls 115.6 2003/01/09 00:35:35 bfreeman noship $ */

/*
    returns 'Y' if the requested username field is unique against
    FND_USER.USER_NAME and REQUESTED_USER_NAME
    where status <> 'REJECTED' in FND_REGISTRATIONS

    Arguement is registration_id for row with requested username to be
    tested.  Will throw exception if registration_id is invalid.
*/
  EVENT_SUCCESS CONSTANT VARCHAR2(7) := 'SUCCESS';
  APPROVAL_WF_ITEM_TYPE CONSTANT FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE := 'APPR_WF_ITEM_TYPE';
  APPROVAL_WF_ITEM_KEY  CONSTANT FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE := 'APPR_WF_ITEM_KEY';
  INVITATION_WF_ITEM_TYPE CONSTANT FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE := 'INV_WF_ITEM_TYPE';
  INVITATION_WF_ITEM_KEY CONSTANT FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE := 'INV_WF_ITEM_';
  REGISTRATION_WF_ITEM_TYPE CONSTANT FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE := 'REG_WF_ITEM_TYPE';
  REGISTRATION_WF_ITEM_KEY CONSTANT FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE := 'REG_WF_ITEM_KEY';
  REJECTION_WF_ITEM_TYPE CONSTANT FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE := 'REJ_WF_ITEM_TYPE';
  REJECTION_WF_ITEM_KEY CONSTANT FND_REGISTRATION_DETAILS.FIELD_VALUE_STRING%TYPE := 'REJ_WF_ITEM_KEY';

function is_requested_username_unique(
         p_username                     IN VARCHAR2)
return VARCHAR2;

function is_requested_username_unique(
         p_registration_id              IN NUMBER)
return VARCHAR2;

function is_requested_username_unique(
         p_registration_id              IN NUMBER,
         p_username                     IN VARCHAR2)
return VARCHAR2;

/*
    publishes event for registration_id indicating
    an invitation has occurred, using BES
    'N' indicates a failure
*/
function publish_invitation_event(
         p_registration_id              IN NUMBER)
return VARCHAR2;

/*
    publishes event for registration_id indicating
    a registration has occurred, using BES
    'N' indicates a failure
*/
function publish_registration_event(
         p_registration_id              IN NUMBER)
return VARCHAR2;

/*
    publishes event for registration_id indicating
    an approval has occurred, using BES
    'N' indicates a failure
*/
function publish_approval_event(
         p_registration_id              IN NUMBER)
return VARCHAR2;

/*
    publishes event for registration_id indicating
    an approval has occurred, using BES
    'N' indicates a failure
*/
function publish_rejection_event(
         p_registration_id              IN NUMBER)
return VARCHAR2;

/*
    returns a REGISTRATION_ID given a valid registration_key
    registration_key must be valid or exception occurs
*/
function get_reg_id_from_key(
         p_registration_key             IN VARCHAR2)
return NUMBER;

/*
    returns a REGISTRATION_KEY given a valid registration_id
    registration_id must be valid or exception occurs
*/
function get_reg_key_from_id(
         p_registration_id              IN NUMBER)
return VARCHAR2;

/*
    runs insert_reg (from FND_REGISTRATION_PKG),
    providing 'INVITE' as the status also calls publish event
    returns new registration_id
*/
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
return NUMBER;

/*
    runs insert_reg (from FND_REGISTSTRATION_PKG),
    providing 'REGISTER' as the status also calls publish event
    returns new registration_id
*/
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
return NUMBER;

/*
    Updates registration status to 'APPROVED' and publishes
    approval event using BES
*/
procedure approve(
         p_registration_id              IN NUMBER,
         x_event_result                 OUT NOCOPY VARCHAR2);

/*
    Updates registration status to 'REJECTED' and publishes
    rejection event using BES
*/
procedure reject(
         p_registration_id              IN NUMBER,
         x_event_result                 OUT NOCOPY VARCHAR2);

end FND_REGISTRATION_UTILS_PKG;


 

/
