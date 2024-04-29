--------------------------------------------------------
--  DDL for Package CAC_SYNC_CONTACT_DQM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_CONTACT_DQM_PVT" AUTHID CURRENT_USER as
/* $Header: cacvscqs.pls 120.2 2005/08/09 20:59:21 cijang noship $ */
/*#
 * This package is used to perform DQM check.
 * @rep:scope private
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Contact Synchronization DQM API
 * @rep:compatibility N
 * @rep:category BUSINESS_ENTITY CAC_SYNC_SERVER
 */

/**
 * This procedure is used to find a matching organizaiton through DQM check.
 * @param p_init_msg_list message list initialization flag
 * @param p_organization_name organization name
 * @param p_contact_name contact name
 * @param x_organization_id organization id
 * @param x_return_status return status
 * @param x_msg_count message count
 * @param x_msg_data message data
 * @rep:displayname Find Organization
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE FIND_ORGANIZATION
( p_init_msg_list      IN   VARCHAR2 DEFAULT NULL
, p_organization_name  IN   VARCHAR2
, p_contact_name       IN   VARCHAR2
, x_organization_id    OUT NOCOPY NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

/**
 * This procedure performs DQM check.
 * @param p_init_msg_list initialize message list
 * @param p_org_party_id organization party id
 * @param p_person_full_name person full name
 * @param p_person_first_name person first name
 * @param p_person_last_name person last name
 * @param p_person_middle_name person middle nameIN   VARCHAR2
 * @param p_person_name_suffix person suffix
 * @param p_person_title person title
 * @param p_job_title job title
 * @param p_work_phone_country_code work phone country code
 * @param p_work_phone_area_code work phone area code
 * @param p_work_phone_number work phone number
 * @param p_home_phone_country_code home phone country code
 * @param p_home_phone_area_code home phone area code
 * @param p_home_phone_number home phone number
 * @param p_fax_phone_country_code fax phone country code
 * @param p_fax_phone_area_code fax phone area code
 * @param p_fax_phone_number fax phone number
 * @param p_pager_phone_country_code pager country code
 * @param p_pager_phone_area_code pager phone area code
 * @param p_pager_phone_number pager phone number
 * @param p_cell_phone_country_code  cell phone country code
 * @param p_cell_phone_area_code cell phone area code
 * @param p_cell_phone_number cell phone number
 * @param p_text_email_address email address
 * @param p_html_email_address email address
 * @param x_return_status return status
 * @param x_msg_count message count
 * @param x_msg_data message data
 * @rep:displayname Check Contact
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE CHECK_CONTACT
( p_init_msg_list            IN   VARCHAR2 DEFAULT NULL
, p_org_party_id             IN   NUMBER
, p_organization_name        IN   VARCHAR2
, p_person_full_name         IN   VARCHAR2
, p_person_first_name        IN   VARCHAR2
, p_person_last_name         IN   VARCHAR2
, p_person_middle_name       IN   VARCHAR2
, p_person_name_suffix       IN   VARCHAR2
, p_person_title             IN   VARCHAR2
, p_job_title                IN   VARCHAR2
, p_work_phone_country_code  IN   VARCHAR2
, p_work_phone_area_code     IN   VARCHAR2
, p_work_phone_number        IN   VARCHAR2
, p_home_phone_country_code  IN   VARCHAR2
, p_home_phone_area_code     IN   VARCHAR2
, p_home_phone_number        IN   VARCHAR2
, p_fax_phone_country_code   IN   VARCHAR2
, p_fax_phone_area_code      IN   VARCHAR2
, p_fax_phone_number         IN   VARCHAR2
, p_pager_phone_country_code IN   VARCHAR2
, p_pager_phone_area_code    IN   VARCHAR2
, p_pager_phone_number       IN   VARCHAR2
, p_cell_phone_country_code  IN   VARCHAR2
, p_cell_phone_area_code     IN   VARCHAR2
, p_cell_phone_number        IN   VARCHAR2
, p_text_email_address       IN   VARCHAR2
, p_html_email_address       IN   VARCHAR2
, p_match_type               IN   VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, x_num_of_matches           OUT NOCOPY NUMBER
, x_party_id                 OUT NOCOPY NUMBER
);

END CAC_SYNC_CONTACT_DQM_PVT;

 

/
