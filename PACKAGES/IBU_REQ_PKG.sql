--------------------------------------------------------
--  DDL for Package IBU_REQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_REQ_PKG" AUTHID CURRENT_USER as
/* $Header: ibursrs.pls 120.4.12010000.2 2009/04/08 07:25:13 mkundali ship $ */
/*======================================================================+
 |                Copyright (c) 1999 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 | FILENAME: ibursrs.pls                                                |
 |                                                                      |
 | PURPOSE                                                              |
 |   Creates the package specification                                  |
 | ARGUMENTS                                                            |
 |                                                                      |
 | NOTES                                                                |
 |   Usage: start                                                       |
 | HISTORY                                                              |
 |   12.20.99    Alex Lau Created                                       |
 |   6-APR-2001  Alan Lau                                               |
 |               Add major enhancement for 11.5.4.F                     |
 |               Commented out UpdateStatus, UpdateUrgency, CreateTask, |
 |               and GetContract.                                       |
 |   01-MAR-2002 klou                                                   |
 |               Add p_error_code to create_service_request procedure.  |
 |   15-MAR-2002 klou                                                   |
 |               Add p_serial_number to create_service_request.         |
 |   31-MAR-2002 klou (UCONTACT)                                        |
 |               Add new parameters to UpdateServiceRequest to hanlde   |
 |               update contacts in SR detail.                          |
 |   15-APR-2002 klou                                                   |
 |               1. Replace p_attr6 with p_cust_pref_lang_code in       |
 |                  create_service_request                              |
 |   25-MAY-2002 WMA                                                    |
 |               1. Add the SR location address information             |
 |   17-OCT-2002 WMA                                                    |
 |               1. modified the create API according to CS change      |
 |               2. add five more parameters for bill to and ship to    |
 |   06-NOV-2002 SPOLAMRE                                               |
 |               Added code to handle DFF                               |
 |   13-NOV-2002 WMA                                                    |
 |               set the default values for the bill to and ship to     |
 |               parameters                                             |
 |  115.50  03-DEC-2002 WZLI changed OUT and IN OUT calls to use NOCOPY |
 |                           hint to enable pass by reference.          |
 |  115.51  06-dec-2002 wzli added two parameters: p_bill_to_party_id   |
 |                           and p_ship_to_party_id in the create       |
 |                           service request procedure.                 |
 |  115.52  02-Jan-2002 wma  add the API                                |
 |                           get_default_status()                       |
 |  115.53  31-Jan-2003 SPOLAMRE                                        |
 |                           Changed the PROCEDURE AddAttachment to take|
 |                           file name as parameter                     |
 |  115.54  09-OCT-2003 WZLI added procedure decodeErrorMsg             |
 |  115.55  20-OCT-2003 wzli added two parameterss: p_street_number and |
 |                           p_timezone_id in the create SR procedure.  |
 |  115.56  10-MAR-2004 WZLI added parameter: p_note_status.            |
 |  115.57  28-NOV-2004 WMA  modify the send Email API, add new API     |
 |                      StartEmailProcess().                            |
 |  120.1   9-SEP-2005  WMA add logic to handle the mulitbytes issues.  |
 |  120.2   28-NOV-2005 wzli added two parameters: p_ref_object_code and|
 |                           p_ref_object_id in the create SR procedure |
 |  12.3   10-DEC-2005 WMA add procedure validate_http_service_ticket   |
 |  120.5  12-FEB-2009 mkundali added for 12.1.2 enhancement bug8245975 |
 +======================================================================*/


/**
 *  Update Service Requests
 */
PROCEDURE UpdateServiceRequest(
  p_request_id                  IN NUMBER,
  p_status_id                   IN NUMBER,
  p_urgency_id                  IN NUMBER,
  p_problem_description         IN VARCHAR2,
  p_problem_detail              IN VARCHAR2,
  p_note_type                   IN VARCHAR2,
  p_last_updated_by             IN NUMBER,
  p_language                    IN VARCHAR2,
  --UCONTACT
  p_contact_party_id            IN JTF_NUMBER_TABLE       := null,
  p_contact_type                IN JTF_VARCHAR2_TABLE_100 := null,
  p_contact_point_id            IN JTF_NUMBER_TABLE       := null,
  p_contact_point_type          IN JTF_VARCHAR2_TABLE_100 := null,
  p_contact_primary             IN JTF_VARCHAR2_TABLE_100 := null,
  p_sr_contact_point_id         IN  JTF_NUMBER_TABLE      := null,
  -- done
  x_return_status               OUT NOCOPY VARCHAR2,
  x_msg_count                   OUT NOCOPY NUMBER,
  x_msg_data                    OUT NOCOPY VARCHAR2
);

/**
 * Add Attachment to certain service request
 */
procedure AddAttachment(
  p_request_id    IN NUMBER,
  p_user_id       IN VARCHAR2,
  p_media_id      IN NUMBER,
  p_name          IN VARCHAR2,
  p_desc          IN VARCHAR2);

/**
 * CREATE_SERVICE_REQUEST
 * Thin PL/SQL wrapper for callling TeleService API.
 */
procedure create_service_request(
  p_request_number                      IN OUT NOCOPY VARCHAR2,
  p_type_id                             IN NUMBER,
  p_account_id                          IN NUMBER,
  p_product                             IN NUMBER,
  p_inventory_item                      IN NUMBER,
  p_problem_code_id                     IN VARCHAR2,
  p_caller_type                         IN VARCHAR2,
  p_language                            IN VARCHAR2,
  p_urgency_id                          IN NUMBER,
  p_summary                             IN VARCHAR2,
  p_problem_description                 IN jtf_varchar2_table_32767,
  p_problem_detail                      IN jtf_varchar2_table_32767,
  p_note_status                         in jtf_varchar2_table_100,
  p_contact_party_id                    in jtf_number_table,
  p_contact_type                        in jtf_varchar2_table_100,
  p_contact_point_id                    IN jtf_number_table,
  p_contact_point_type                  in jtf_varchar2_table_100,
  p_contact_primary                     in jtf_varchar2_table_100,

  p_status_id                           IN NUMBER,
  p_severity_id                         IN NUMBER,
--  p_owner_id                            IN NUMBER,
  p_user_id                             IN NUMBER,
  p_customer_id                         IN NUMBER,
  p_platform_id                         IN NUMBER,
  p_cp_revision_id                      IN NUMBER,
  p_inv_item_revision                   IN VARCHAR2,
  p_helpdesk_no                         IN VARCHAR2,
  p_party_id                            IN NUMBER,
  p_solved                              IN VARCHAR2,
  p_employee_id                         IN NUMBER,
  p_note_type                           IN jtf_varchar2_table_100,
  p_contract_id                         in varchar2,
  p_project_num                         in varchar2,
  p_short_code                          in varchar2,
  p_os_version                          in varchar2,
  p_db_version                          in varchar2,
  p_product_revision                    in varchar2,
 -- p_attr_6                              in varchar2,
  p_cust_pref_lang_code                 in varchar2 := NULL,
  p_pref_contact_method                 in varchar2,
  p_rollout                             in varchar2,
  p_error_code                          in varchar2 := NULL,
  p_serial_number                       in varchar2 := NULL,
  p_inv_category_id                     in NUMBER,
  p_time_zone_id                        in NUMBER,
--for the SR location information
  p_location_id                         in NUMBER,
  p_address                             in varchar2 := NULL,
  p_city                                in varchar2 := NULL,
  p_state                               in varchar2 := NULL,
  p_country                             in varchar2 := NULL,
  p_province                            in varchar2 := NULL,
  p_postal_code                         in varchar2 := NULL,
  p_county                              in varchar2 := NULL,
-- add the following for 11.5.10
  p_addrLine2                            in varchar2 := NULL,
  p_addrLine3                            in varchar2 := NULL,
  p_addrLine4                            in varchar2 := NULL,
  p_poboxNumber                          in varchar2 := NULL,
  p_houseNumber                          in varchar2 := NULL,
  p_streetSuffix                         in varchar2 := NULL,
  p_street                               in varchar2 := NULL,
  p_street_number                        in varchar2 := NULL,
  p_floor                                in varchar2 := NULL,
  p_suite                                in varchar2 := NULL,
  p_postalPlus4Code                      in varchar2 := NULL,
  p_position                             in varchar2 := NULL,
  p_locationDirections                   in varchar2 := NULL,
  p_description                          in varchar2 := NULL,
  p_pointOfInterest                      in varchar2 := NULL,
  p_crossStreet                          in varchar2 := NULL,
  p_directionQualifier                   in varchar2 := NULL,
  p_distanceQualifier                    in varchar2 := NULL,
  p_distanceQualUom                      in varchar2 := NULL,
--for the bill to and ship to
  p_bill_to_site_id                     in NUMBER := NULL,
  p_bill_to_contact_id                  in NUMBER := NULL,
  p_ship_to_site_id                     in NUMBER := NULL,
  p_ship_to_contact_id                  in NUMBER := NULL,
  p_install_site_use_id                 in NUMBER := NULL,
  p_bill_to_party_id                    in NUMBER := NULL,
  p_ship_to_party_id                    in NUMBER := NULL,
 -- added for 11.5.10
  p_bill_to_account_id                  in NUMBER,
  p_ship_to_account_id                  in NUMBER,
 -- added for link object enhancement
  p_ref_object_code                     in varchar2,
  p_ref_object_id                       in number,
 -- added for eam enhancement
  p_asset_id                            in number,
  p_maint_org_id                        in number,
  p_owning_dept_id                      in number,
  p_eam_type                            in varchar2,
--for DFF
  p_external_attribute_1                IN varchar2 := NULL,
  p_external_attribute_2                IN varchar2 := NULL,
  p_external_attribute_3                IN varchar2 := NULL,
  p_external_attribute_4                IN varchar2 := NULL,
  p_external_attribute_5                IN varchar2 := NULL,
  p_external_attribute_6                IN varchar2 := NULL,
  p_external_attribute_7                IN varchar2 := NULL,
  p_external_attribute_8                IN varchar2 := NULL,
  p_external_attribute_9                IN varchar2 := NULL,
  p_external_attribute_10               IN varchar2 := NULL,
  p_external_attribute_11               IN varchar2 := NULL,
  p_external_attribute_12               IN varchar2 := NULL,
  p_external_attribute_13               IN varchar2 := NULL,
  p_external_attribute_14               IN varchar2 := NULL,
  p_external_attribute_15               IN varchar2 := NULL,
  p_external_context                    IN varchar2 := NULL,

  x_return_status                       OUT NOCOPY VARCHAR2,
  x_msg_count                           OUT NOCOPY NUMBER,
  x_msg_data                            OUT NOCOPY VARCHAR2,
  x_request_id                          OUT NOCOPY NUMBER,
  p_site_name                           in varchar2 := NULL,
  p_site_number                         in varchar2 := NULL,
  p_addressee                           in varchar2 := NULL
);

/**
 * Send email notification for user
 */
procedure send_email(
  email_address_in in varchar2,
  user_id          in varchar2,
  subject          in varchar2,
  msg_body         in varchar2,
  srID             in number,
  emailStyleSheet  in varchar2,
  emailbranding    in varchar2,
  emaillinkURL     in varchar2,
  notification_pref in varchar2,
  contactType       in varchar2,
  contactID         in number
);
/**
 * Get the default status Id for SR creation
 */

procedure get_default_status(
   p_type_id         in number,
   x_status_id       out nocopy number,
   x_return_status out NOCOPY VARCHAR2
);

/**
 * This API is used to handle the mulitbytes issues.
 */
procedure check_string_length_bites(
   p_string         in varchar2,
   p_targetlen      number,
   x_returnLen      out NOCOPY number,
   x_truncateCharNum out NOCOPY number
);
/**
 * Decode the error messages:
 *   CS_SR_CANNOT_CLOSE_SR
 *   CS_SR_OPEN_TASKS_EXISTS
 *   CS_SR_OPEN_CHARGES_EXISTS
 *   CS_SR_SCHEDULED_TASKS_EXISTS
 *   CS_SR_TASK_DEBRIEF_INCOMPLETE
 * TO
 * "This service request cannot be closed at this time.
 *  Please call customer support for assistance."
 */
 procedure decodeErrorMsg;

/**
 * Start the Email work flow process.
 */

procedure StartEmailProcess (
   roleName in varchar2,
   srID     in number,
   subject in varchar2,
   content   Wf_Engine.TextTabTyp,
   ProcessOwner in varchar2,
   Workflowprocess in varchar2 default null,
   item_type in varchar2 default null,
   emailStyleSheet  in varchar2,
   emailbranding    in varchar2,
   emaillinkURL     in varchar2);

/**
 * get the object info from jtf_object
 */
procedure getObjectInfo(
   p_ref_object_code in varchar2,
   x_select_id out NOCOPY varchar2,
   x_from_table out NOCOPY varchar2,
   x_where_clause out NOCOPY varchar2,
   x_object_count out NOCOPY number
   );

procedure checkObjectID(
   p_ref_object_id in number,
   p_select_id in varchar2,
   p_from_table in varchar2,
   p_where_clause in varchar2,
   x_object_count out NOCOPY number
   );

procedure validate_http_service_ticket(
   p_ticket_string   in varchar2,
   x_return_status   out NOCOPY VARCHAR2
);

END IBU_REQ_PKG;

/
