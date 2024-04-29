--------------------------------------------------------
--  DDL for Package AMS_LIST_IMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_IMPORT_PUB" AUTHID CURRENT_USER AS
/* $Header: amspimls.pls 115.13 2003/12/23 18:19:35 usingh ship $ */

-----------------------------------------------------------
-- PACKAGE
--   AMS_List_Import_PUB
--
-- PURPOSE
--   This purpose of this program is to create organization,person
--   ,party relationship, org contacts, locations , party sites,
--   email and phone records for B2B or B2C type customer's
--
--      Call TCA API's to create the records in HZ schema.
--
--
--       For B2B creates the following  using TCA API's
--
--               1.     Create organization
--               2.     Create Person
--               3.     Create Party Relation
--               4.     Create Party for Party Relationship
--               5.     Create Org contact
--               6.     Create Location (if address is available)
--               7.     Create Party Site (if address  is available)
--               8.     Create Contact Points (if contact points are available)
--
--
--
--
--       For B2C creates the following  using TCA API's
--
--              1.      Create Person
--              2.      Create Location (if address is available)
--              3.      Create Party Site (if address  is available)
--              4.      Create Contact Points (if contact points are available)
--
-- PROCEDURE
--    Create_Customer
--
-- PURPOSE
--    Creates a new customer with other entities as mentioned above.
--
-- PARAMETERS
--    p_party_rec 	The New Record for party.
--    p_org_rec		The New Record for organization.
--    p_person_rec	The New Record for person.
--    p_location_rec	The New Record for location.
--    p_psite_rec	The New Record for party site.
--    p_cpoint_rec	The New Record for contact point.
--    p_email_rec	The New Record for email.
--    p_phone_rec	The New Record for phone.
--    p_ocon_rec	The New Record for org contact.
--    x_party_id	The party_id for the record.
--    x_new_party	The tells if the party is new.

PROCEDURE Create_Customer
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2  := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2  := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER    := FND_API.g_valid_level_full,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_party_id                 IN OUT NOCOPY NUMBER,
  p_b2b_flag                 IN     VARCHAR2,
  p_import_list_header_id    IN     NUMBER,
  p_party_rec       	     IN	    hz_party_v2pub.party_rec_type,
  p_org_rec                  IN     hz_party_v2pub.organization_rec_type,
  p_person_rec               IN     hz_party_v2pub.person_rec_type,
  p_location_rec             IN     hz_location_v2pub.location_rec_type,
  p_psite_rec                IN     hz_party_site_v2pub.party_site_rec_type,
  p_cpoint_rec               IN     hz_contact_point_v2pub.contact_point_rec_type,
  p_email_rec                IN     hz_contact_point_v2pub.email_rec_type,
  p_phone_rec                IN     hz_contact_point_v2pub.phone_rec_type,
  p_fax_rec                  IN     hz_contact_point_v2pub.phone_rec_type,
  p_ocon_rec                 IN     hz_party_contact_v2pub.org_contact_rec_type,
  p_siteuse_rec              IN     hz_party_site_v2pub.party_site_use_rec_type,
  p_web_rec                  IN     hz_contact_point_v2pub.web_rec_type,
  x_new_party                OUT NOCOPY    VARCHAR2,
  p_component_name           OUT NOCOPY    VARCHAR2,
  l_import_source_line_id    IN  NUMBER default null,
  p_org_email_rec            IN     hz_contact_point_v2pub.email_rec_type default null,
  p_org_phone_rec            IN     hz_contact_point_v2pub.phone_rec_type default null,
  p_org_location_rec         IN     hz_location_v2pub.location_rec_type   default null,
  p_org_psite_rec            IN     hz_party_site_v2pub.party_site_rec_type default NULL,
  p_language_rec             IN     HZ_PERSON_INFO_V2PUB.person_language_rec_type default NULL,
  p_org_party_site_phone_rec IN     hz_contact_point_v2pub.phone_rec_type default null
);

--
-- This progam updates the party for the rented list
--
PROCEDURE update_rented_list_party (
  p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2  := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2  := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER    := FND_API.g_valid_level_full,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_party_id                 IN     NUMBER
                     );


-- This program captures the erros.
--
procedure error_capture (
  p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2  := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2  := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER    := FND_API.g_valid_level_full,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_import_list_header_id    IN     NUMBER,
  p_import_source_line_id    IN     NUMBER,
  p_imp_xml_element_id       IN     NUMBER,
  p_imp_xml_attribute_id     IN     NUMBER,
  p_component_name           IN     VARCHAR2 default null,
  p_field_name               IN     VARCHAR2,
  p_error_text               IN     VARCHAR2
  );


--
-- for XML updates the success in the element table
--
PROCEDURE process_element_success (
                                 p_import_list_header_id    IN    NUMBER,
                                 p_xml_element_id IN NUMBER);

--
-- for XML updates the duplicate in the element table
--
PROCEDURE process_element_duplicate (
                                 p_import_list_header_id    IN    NUMBER,
                                 p_xml_element_id IN NUMBER);




end AMS_List_Import_PUB;

 

/
