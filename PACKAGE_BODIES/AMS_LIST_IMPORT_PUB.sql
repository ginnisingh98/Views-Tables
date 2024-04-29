--------------------------------------------------------
--  DDL for Package Body AMS_LIST_IMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_IMPORT_PUB" AS
/* $Header: amspimlb.pls 120.7.12010000.4 2010/03/22 08:09:57 amlal ship $ */

-----------------------------------------------------------
-- PACKAGE
--   AMS_List_Import_PUB
--
-- PURPOSE
--   This purpose of this program is to create organization,person
--   ,party relationship, org contacts, locations , party sites,
--   email and phone records for B2B or B2C type customer's
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
-- ------------------------------------------------------------------------
G_ARC_IMPORT_HEADER  CONSTANT VARCHAR2(30) := 'IMPH';
g_pkg_name  CONSTANT VARCHAR2(30):='AMS_LIST_IMPORT_PUB';
G_ERROR_THRESHOLD               NUMBER := 0;
--
-- This procedure is used for existence checking for party.
--
--
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


PROCEDURE party_echeck(
   p_party_id              IN OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2,
   p_org_name              IN       VARCHAR2,
   p_per_first_name        IN       VARCHAR2,
   p_per_last_name         IN       VARCHAR2,
   p_address1              IN       VARCHAR2,
   p_country               IN       VARCHAR2,
-- sranka 1/14/2003
-- added "p_orig_system_reference"  for supporting the population of "orig_system_reference"
-- from CSV file
   p_orig_system_reference IN       VARCHAR2
                       );

--
-- This procedure is used for existence checking for party or person type.
--
--
PROCEDURE person_party_echeck(
   p_party_id           IN OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2,
   p_per_first_name     IN       VARCHAR2,
   p_per_last_name      IN       VARCHAR2,
   p_address1           IN       VARCHAR2,
   p_country            IN       VARCHAR2,
   p_email_address      IN       VARCHAR2,
   p_ph_country_code    IN       VARCHAR2,
   p_ph_area_code       IN       VARCHAR2,
   p_ph_number          IN       VARCHAR2,
   p_orig_system_reference IN       VARCHAR2
                      ) ;

-- SOLIN, bug 4465931
PROCEDURE contact_person_party_echeck(
   p_party_id           IN OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2,
   p_per_first_name     IN       VARCHAR2,
   p_per_last_name      IN       VARCHAR2,
   p_address1           IN       VARCHAR2,
   p_country            IN       VARCHAR2,
   p_email_address      IN       VARCHAR2,
   p_ph_country_code    IN       VARCHAR2,
   p_ph_area_code       IN       VARCHAR2,
   p_ph_number          IN       VARCHAR2,
   p_orig_system_reference IN       VARCHAR2
                      ) ;
-- SOLIN, end bug 4465931

PROCEDURE rented_person_party_echeck(
   p_party_id           IN OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2,
   p_per_first_name     IN       VARCHAR2,
   p_per_last_name      IN       VARCHAR2,
   p_address1           IN       VARCHAR2,
   p_country            IN       VARCHAR2,
   p_email_address      IN       VARCHAR2,
   p_ph_country_code    IN       VARCHAR2,
   p_ph_area_code       IN       VARCHAR2,
   p_ph_number          IN       VARCHAR2
                      ) ;


--
-- This procedure is used for existence checking for contact.
--
--
PROCEDURE contact_echeck(
   p_party_id              IN OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2,
   p_org_party_id          IN       NUMBER,
   p_per_first_name        IN       VARCHAR2,
   p_per_last_name         IN       VARCHAR2,
   p_phone_area_code       IN       VARCHAR2,
   p_phone_number          IN       VARCHAR2,
   p_phone_extension       IN       VARCHAR2,
   p_email_address         IN       VARCHAR2,
-- sranka 1/14/2003
-- added "p_orig_system_reference"  for supporting the population of "orig_system_reference"
-- from CSV file
   p_orig_system_reference IN       VARCHAR2,
-- sranka 3/21/2003
-- made changes for supporting EMPLOYEE_OF" relationship
   p_relationship_code     IN       VARCHAR2,
   p_relationship_type     IN       VARCHAR2

                       );

PROCEDURE rented_contact_echeck(
   p_party_id              IN OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2,
   p_org_party_id          IN       NUMBER,
   p_per_first_name        IN       VARCHAR2,
   p_per_last_name         IN       VARCHAR2,
   p_phone_area_code       IN       VARCHAR2,
   p_phone_number          IN       VARCHAR2,
   p_phone_extension       IN       VARCHAR2,
   p_email_address         IN       VARCHAR2,
-- sranka 3/21/2003
-- made changes for supporting EMPLOYEE_OF" relationship
   p_relationship_code     IN       VARCHAR2,
   p_relationship_type     IN       VARCHAR2
                       );

-- This procedure is used to create party records in ams_party_sources table.
--
--
PROCEDURE create_party_source (
   p_import_list_header_id    IN    NUMBER,
   p_import_source_line_id    IN    NUMBER,
   p_overlay                  IN    VARCHAR2
                              );

-- ------------------------------------------------------------------------
-- PROCEDURE
--    Create_Customer
--
-- PURPOSE
--    Creates a new customer with other entities as mentioned above.
--
-- PARAMETERS
--    p_party_rec       The New Record for party.
--    p_org_rec         The New Record for organization.
--    p_person_rec      The New Record for person.
--    p_location_rec    The New Record for location.
--    p_psite_rec       The New Record for party site.
--    p_cpoint_rec      The New Record for contact point.
--    p_email_rec       The New Record for email.
--    p_phone_rec       The New Record for phone.
--    p_ocon_rec        The New Record for org contact.
--    x_party_id        The party_id for the record.
--    x_new_party       The tells if the party is new.


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
  p_party_rec                IN     hz_party_v2pub.party_rec_type,
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
  p_language_rec             IN     hz_person_info_v2pub.person_language_rec_type DEFAULT null,
  p_org_party_site_phone_rec IN     hz_contact_point_v2pub.phone_rec_type default null
) IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'Create_Customer';
  l_api_version         CONSTANT NUMBER        := 1.0;
  l_return_status       VARCHAR2(1);
  l_ret_status          varchar(1);
  l_rec_update_flag     varchar(1) := 'N';

  party_rec       hz_party_v2pub.party_rec_type := p_party_rec;
  org_rec         hz_party_v2pub.organization_rec_type := p_org_rec;
  org_rec_null    hz_party_v2pub.organization_rec_type := null;
  person_rec      hz_party_v2pub.person_rec_type := p_person_rec;
  location_rec    hz_location_v2pub.location_rec_type := p_location_rec;
  psite_rec       hz_party_site_v2pub.party_site_rec_type := p_psite_rec;
  psiteuse_rec    hz_party_site_v2pub.party_site_use_rec_type := p_siteuse_rec;
  cpoint_rec      hz_contact_point_v2pub.contact_point_rec_type := p_cpoint_rec;
  email_rec       hz_contact_point_v2pub.email_rec_type := p_email_rec;
  phone_rec       hz_contact_point_v2pub.phone_rec_type := p_phone_rec;
  fax_rec         hz_contact_point_v2pub.phone_rec_type := p_fax_rec;
  ocon_rec        hz_party_contact_v2pub.org_contact_rec_type := p_ocon_rec;
  edi_rec         hz_contact_point_v2pub.edi_rec_type;
  telex_rec       hz_contact_point_v2pub.telex_rec_type;
  web_rec         hz_contact_point_v2pub.web_rec_type := p_web_rec;

 org_email_rec       hz_contact_point_v2pub.email_rec_type   := p_org_email_rec;
 org_phone_rec       hz_contact_point_v2pub.phone_rec_type   := p_org_phone_rec;
 org_location_rec    hz_location_v2pub.location_rec_type     := p_org_location_rec;
 org_psite_rec       hz_party_site_v2pub.party_site_rec_type := p_org_psite_rec;
 language_rec        hz_person_info_v2pub.person_language_rec_type := p_language_rec;
 org_party_site_phone_rec hz_contact_point_v2pub.phone_rec_type   := p_org_party_site_phone_rec;

 l_address_key  hz_locations.address_key%TYPE ;
 l_address_key_count NUMBER ;

x_b2b                           varchar(1);
x_rented_list_flag              varchar(1) := 0;
x_generate_party_number         VARCHAR2(1);
x_gen_contact_number            VARCHAR2(1);
x_gen_party_site_number         VARCHAR2(1);
x_party_number                  VARCHAR2(30);
x_organization_profile_id       number;
x_person_profile_id             number;
x_org_party_id                  number;
x_tmp_var                       VARCHAR2(4000);
x_tmp_var1                      VARCHAR2(4000);
x_per_party_id                  number;
x_party_relationship_id         number;
x_contact_number                VARCHAR2(30);
x_org_contact_id                number;
x_party_rel_party_id            number;
x_location_id                   number;
x_Party_site_id                 number;
x_party_site_number             VARCHAR2(30);
x_contact_point_id              number;
x_email_address                 varchar2(2000);
x_phone_country_code            VARCHAR2(10);
x_phone_area_code               VARCHAR2(10);
x_phone_number                  VARCHAR2(40);
x_phone_extention               VARCHAR2(20);
x_party_name                    VARCHAR2(400);
l_return_status                 VARCHAR2(1);
i_import_source_line_id         number;
i_number_of_rows_processed      number := 0;
i_party_id                      number;
p_msg_count                     number;
-- p_party_id                      number;
p_msg_data                      varchar(2000);
P_DUPLICATE                     varchar(1);
L_COUNT          NUMBER := 0;
l_max_party_id   NUMBER := 0;
l_max_location_id   NUMBER := 0;
p_pr_party_id    number;
l_lp_psite_id    number;

x_hz_dup_check  VARCHAR2(60);
l_overlay       VARCHAR2(1);
l_phone_exists  VARCHAR2(1);
l_url_exists  VARCHAR2(1);
l_fax_exists  VARCHAR2(1);
l_email_exists  VARCHAR2(1);
l_is_party_mapped  VARCHAR2(1);
l_b2b_party_id    number;
l_b2c_party_id    number;
l_b2b_party_exists VARCHAR2(1);
l_b2c_party_exists VARCHAR2(1);
l_enabled_flag     VARCHAR2(1);
l_phone_id		number;
l_fax_id		number;
l_xml_element_id	number;
l_object_version1               number;
l_object_version2               number;
l_object_version3               number;
x_pty_site_id                   number;
x_party_site_use_id   number;
x_fax_country_code            VARCHAR2(10);
x_fax_area_code               VARCHAR2(10);
x_fax_number                  VARCHAR2(40);
x_url      	              VARCHAR2(2000);
L_URL_ID			number;
l_party_obj_number   number;
l_con_obj_number   number;
l_pr_obj_number   number;
l_loc_obj_number   number;
l_ps_obj_number   number;
l_cp_obj_number   number;
l_email_id       number;
l_rel_id       number;

src_ORG_PARTY_ID    number;
src_OCONT_PARTY_ID  number;
src_PARTY_LOCATION_ID number;
src_org_LOCATION_ID number;
src_ORG_KEY	     varchar2(240);
src_person_PARTY_ID  number;
l_transposed_phone_no varchar2(60);
x_phone_type           VARCHAR2(30);
-- sranka Modified for COLT enhancememts

x_org_location_id                   number;
X_LANGUAGE_USE_REFERENCE_ID number;
L_LANGUAGE_OBJ_NUMBER number;
L_LANGUAGE_USE_REFERENCE_ID number;
x_org_party_site_id number;
l_org_lp_psite_id    number;
x_org_email_address   varchar2(2000);
l_org_transposed_phone_no varchar2(60);
l_org_ps_transposed_phone_no varchar2(60);



cursor c_rented is
          select rented_list_flag, nvl(RECORD_UPDATE_FLAG,'N') from ams_imp_list_headers_all
          where  import_list_header_id = p_import_list_header_id;


cursor b2bxml is
          select ORG_IMP_XML_ELEMENT_ID from ams_hz_b2b_mapping_v
          where  import_source_line_id = i_import_source_line_id;

cursor b2cxml is
          select PER_IMP_XML_ELEMENT_ID from ams_hz_b2c_mapping_v
          where  import_source_line_id = i_import_source_line_id;

CURSOR PARTY_REL_EXISTS IS
SELECT party_id, relationship_id  FROM hz_relationships
WHERE object_id = x_org_party_id
  AND subject_id = x_per_party_id
  AND subject_table_name = 'HZ_PARTIES'
  AND subject_type = 'PERSON'
  AND  object_type = 'ORGANIZATION'
  AND  object_table_name = 'HZ_PARTIES'
-- sranka 3/4/2003
-- made changes for supporting EMPLOYEE_OF" relationship
--  AND  relationship_code = 'CONTACT_OF';
  AND  relationship_code = NVL(ocon_rec.party_rel_rec.relationship_code,'CONTACT_OF')
  AND  relationship_type = NVL(ocon_rec.party_rel_rec.relationship_type,'CONTACT');

cursor b2bparty is
  SELECT 'Y' FROM hz_parties
  WHERE party_type = 'PARTY_RELATIONSHIP'
    and status = 'A'
    AND party_id   =  l_b2b_party_id;


cursor b2cparty is
  SELECT 'Y' FROM hz_parties
  WHERE party_type = 'PERSON'
    and status = 'A'
    AND party_id   = l_b2c_party_id;

cursor orgpartyid is
 SELECT object_id FROM hz_relationships
 WHERE  subject_type = 'PERSON'
   AND  subject_table_name = 'HZ_PARTIES'
   AND  object_type = 'ORGANIZATION'
   AND  object_table_name = 'HZ_PARTIES'
-- sranka 3/4/2003
-- made changes for supporting EMPLOYEE_OF" relationship
--  AND  relationship_code = 'CONTACT_OF';
  AND  relationship_code = NVL(ocon_rec.party_rel_rec.relationship_code,'CONTACT_OF')
  AND  relationship_type = NVL(ocon_rec.party_rel_rec.relationship_type,'CONTACT')
  AND  party_id = l_b2b_party_id;

CURSOR LOCATION_EXISTS IS
SELECT party_site_id FROM hz_party_sites
WHERE party_id = x_org_party_id
  AND location_id = x_location_id;

-- sranka 7/15/2003 made changes for COLt Enhancements
CURSOR ORG_LOCATION_EXISTS IS
SELECT party_site_id FROM hz_party_sites
WHERE party_id = x_org_party_id
  AND location_id = x_org_location_id;

CURSOR PER_LOCATION_EXISTS IS
SELECT party_site_id FROM hz_party_sites
WHERE party_id = x_per_party_id
  AND location_id = x_location_id;

CURSOR CHECK_PSITE_EXISTS IS
SELECT party_site_id FROM hz_party_sites
WHERE party_id = x_party_rel_party_id
  AND location_id = x_location_id;


CURSOR phone_exists (x_hz_party_id number,x_phone_type varchar) IS
SELECT 'Y' FROM hz_contact_points
WHERE contact_point_type          = 'PHONE'
  AND phone_line_type             = x_phone_type
  AND owner_table_name            = 'HZ_PARTIES'
  AND owner_table_id              = x_hz_party_id
and transposed_phone_number     = l_transposed_phone_no;
 --  AND phone_number                = x_phone_number
 --  AND NVL(phone_country_code,'x') = NVL(x_phone_country_code,'x')
 -- AND NVL(phone_area_code,'x')    = NVL(x_phone_area_code,'x')
 -- AND NVL(phone_extension,'x')    = NVL(x_phone_extention,'x');

-- srank a 7/31/2003 modified for COLT enhancements

CURSOR org_phone_exists (x_hz_party_id number,x_org_phone_type varchar) IS
SELECT 'Y' FROM hz_contact_points
WHERE contact_point_type          = 'PHONE'
AND phone_line_type             = x_org_phone_type
AND owner_table_name            = 'HZ_PARTIES'
AND owner_table_id              = x_hz_party_id
and transposed_phone_number     = l_org_transposed_phone_no;


CURSOR org_party_site_phone_exists (x_hz_party_id number,x_org_ps_phone_type varchar) IS
SELECT 'Y' FROM hz_contact_points
WHERE contact_point_type          = 'PHONE'
AND phone_line_type             = x_org_ps_phone_type
AND owner_table_name            = 'HZ_PARTIES'
AND owner_table_id              = x_hz_party_id
and transposed_phone_number     = l_org_ps_transposed_phone_no;
 --  AND phone_number                = x_phone_number
 --  AND NVL(phone_country_code,'x') = NVL(x_phone_country_code,'x')
 -- AND NVL(phone_area_code,'x')    = NVL(x_phone_area_code,'x')
 -- AND NVL(phone_extension,'x')    = NVL(x_phone_extention,'x');


CURSOR fax_exists (x_hz_party_id number) IS
SELECT 'Y' FROM hz_contact_points
WHERE contact_point_type          = 'PHONE'
  AND phone_line_type             = 'FAX'
  AND owner_table_name            = 'HZ_PARTIES'
  AND owner_table_id              = x_hz_party_id
  AND phone_number                = x_fax_number
  AND NVL(phone_country_code,'x') = NVL(x_fax_country_code,'x')
  AND NVL(phone_area_code,'x')    = NVL(x_fax_area_code,'x');

CURSOR url_exists (x_hz_party_id number) IS
SELECT 'Y' FROM hz_contact_points
WHERE contact_point_type          = 'WEB'
  AND owner_table_name            = 'HZ_PARTIES'
  AND owner_table_id              = x_hz_party_id
  AND url                         = x_url;


CURSOR c_phone_id (x_hz_party_id number,x_phone_type varchar) IS
SELECT contact_point_id FROM hz_contact_points
WHERE contact_point_type          = 'PHONE'
  AND phone_line_type             = x_phone_type
  AND owner_table_name            = 'HZ_PARTIES'
  AND owner_table_id              = x_hz_party_id
  and transposed_phone_number     = l_transposed_phone_no;
/*
  AND phone_number                = x_phone_number
  AND NVL(phone_country_code,'x') = NVL(x_phone_country_code,'x')
  AND NVL(phone_area_code,'x')    = NVL(x_phone_area_code,'x')
  AND NVL(phone_extension,'x')    = NVL(x_phone_extention,'x');
*/

-- sranka modified for colt enhancements 7/23/2003

CURSOR c_org_phone_id (x_hz_party_id number,x_org_phone_type varchar) IS
SELECT contact_point_id FROM hz_contact_points
WHERE contact_point_type          = 'PHONE'
  AND phone_line_type             = x_org_phone_type
  AND owner_table_name            = 'HZ_PARTIES'
  AND owner_table_id              = x_hz_party_id
  and transposed_phone_number     = l_org_transposed_phone_no;

CURSOR c_org_party_site_phone_id (x_hz_party_id number,x_org_ps_phone_type varchar) IS
SELECT contact_point_id FROM hz_contact_points
WHERE contact_point_type          = 'PHONE'
  AND phone_line_type             = x_org_ps_phone_type
  AND owner_table_name            = 'HZ_PARTIES'
  AND owner_table_id              = x_hz_party_id
  and transposed_phone_number     = l_org_ps_transposed_phone_no;



CURSOR c_url_id (x_hz_party_id number) IS
SELECT contact_point_id FROM hz_contact_points
WHERE contact_point_type          = 'WEB'
  AND owner_table_name            = 'HZ_PARTIES'
  AND owner_table_id              = x_hz_party_id
  AND url                         = x_url;

CURSOR c_fax_id (x_hz_party_id number) IS
SELECT contact_point_id FROM hz_contact_points
WHERE contact_point_type          = 'PHONE'
  AND phone_line_type             = 'FAX'
  AND owner_table_name            = 'HZ_PARTIES'
  AND owner_table_id              = x_hz_party_id
  AND phone_number                = x_fax_number
  AND NVL(phone_country_code,'x') = NVL(x_fax_country_code,'x')
  AND NVL(phone_area_code,'x')    = NVL(x_fax_area_code,'x');

CURSOR email_exists (x_hz_party_id number) IS
SELECT 'Y' FROM hz_contact_points
WHERE contact_point_type          = 'EMAIL'
  AND owner_table_name            = 'HZ_PARTIES'
  AND owner_table_id              = x_hz_party_id
  AND upper(email_address)        = upper(x_email_address);


-- srank COLT Enhancements 7/19/2003

CURSOR org_email_exists (x_hz_party_id number) IS
SELECT 'Y' FROM hz_contact_points
WHERE contact_point_type          = 'EMAIL'
  AND owner_table_name            = 'HZ_PARTIES'
  AND owner_table_id              = x_hz_party_id
  AND upper(email_address)        = upper(x_org_email_address);




cursor c_relationship is
          SELECT OBJECT_VERSION_NUMBER FROM hz_relationships
          WHERE RELATIONSHIP_ID  = nvl(x_party_relationship_id,l_rel_id)
             and subject_type = 'PERSON';

cursor c_org_cont_rel is
       SELECT OBJECT_VERSION_NUMBER  FROM hz_org_contacts
       WHERE PARTY_RELATIONSHIP_ID = nvl(x_party_relationship_id,l_rel_id);

cursor c_party_rel is
       SELECT OBJECT_VERSION_NUMBER  FROM hz_parties
       WHERE PARTY_ID = x_party_rel_party_id;

CURSOR c_email_id (x_hz_party_id number) IS
SELECT contact_point_id FROM hz_contact_points
WHERE contact_point_type          = 'EMAIL'
  AND owner_table_name            = 'HZ_PARTIES'
  AND owner_table_id              = x_hz_party_id
  AND email_address               = x_email_address;

cursor c_b2b_source_rec is
       select ORG_PARTY_ID,OCONT_PARTY_ID,PARTY_LOCATION_ID,ORG_KEY,org_location_id
       from ams_hz_b2b_mapping_v
       where import_source_line_id = i_import_source_line_id;

cursor c_b2c_source_rec is
       select person_PARTY_ID,PARTY_LOCATION_ID
       from ams_hz_b2c_mapping_v
       where import_source_line_id = i_import_source_line_id;

cursor c_org_party is
       select party_id from hz_parties
       where customer_key = src_org_key
         and status = 'A'
         and party_type   = 'ORGANIZATION';

cursor c_validate_b2b is
       select 1 from hz_parties
	where party_id = p_party_id
	  and party_type in ('PARTY_RELATIONSHIP','ORGANIZATION')
	  and status = 'A';

cursor c_validate_b2c is
       select 1 from hz_parties
	where party_id = p_party_id -- bug 5100612 mayjain
	  and party_type in ('PERSON')
	  and status = 'A';

l_validate number;

begin

  SAVEPOINT create_customer_pub;
--Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;
 x_generate_party_number := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');
 x_gen_contact_number    := fnd_profile.value('HZ_GENERATE_CONTACT_NUMBER');
 x_gen_party_site_number := fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER');
 x_hz_dup_check          := fnd_profile.value('AMS_HZ_DEDUPE_RULE');
 l_transposed_phone_no := hz_phone_number_pkg.transpose(phone_rec.phone_country_code
                          ||phone_rec.phone_area_code||phone_rec.phone_number);

 x_email_address 	:= email_rec.email_address;

-- sranka COLT Enahancement ##########
 x_org_email_address := org_email_rec.email_address;



 l_org_transposed_phone_no := hz_phone_number_pkg.transpose(org_phone_rec.phone_country_code
                          ||org_phone_rec.phone_area_code||org_phone_rec.phone_number);

 l_org_ps_transposed_phone_no := hz_phone_number_pkg.transpose(org_party_site_phone_rec.phone_country_code
                          ||org_party_site_phone_rec.phone_area_code||org_party_site_phone_rec.phone_number);




 x_phone_country_code   := phone_rec.phone_country_code;
 x_phone_area_code      := phone_rec.phone_area_code;
 x_phone_number         := phone_rec.phone_number;
 x_phone_extention      := phone_rec.phone_extension;
 x_phone_type		:= phone_rec.phone_line_type;

 x_url		 	:= web_rec.url;
 x_fax_country_code     := fax_rec.phone_country_code;
 x_fax_area_code      := fax_rec.phone_area_code;
 x_fax_number         := fax_rec.phone_number;

 email_rec.email_address := null;
 phone_rec.phone_country_code := null;
 phone_rec.phone_area_code := null;
 phone_rec.phone_number := null;
 phone_rec.phone_extension := null;
 phone_rec.phone_line_type := null;

 web_rec.url := null;
 fax_rec.phone_country_code := null;
 fax_rec.phone_area_code := null;
 fax_rec.phone_number := null;




  if x_hz_dup_check <> 'Y' then
    x_hz_dup_check := 'N';
 end if;

        x_b2b :=  p_b2b_flag;
      if p_import_list_header_id is not null then
 -- Checks if party_id is mapped
       l_is_party_mapped := AMS_ListImport_PVT.G_PARTY_MAPPED;
        OPEN c_rented;
        FETCH c_rented into x_rented_list_flag, l_rec_update_flag;
        CLOSE c_rented;
        if x_rented_list_flag is null then
		x_rented_list_flag := 'X';
	end if;
      end if;




if x_b2b = 'Y' then
-- Creates Organization

-- sranka 1/14/2003
--   i_import_source_line_id := org_rec.party_rec.orig_system_reference; // original
   i_import_source_line_id := l_import_source_line_id;

   x_party_name     := org_rec.organization_name;
   x_org_party_id   := null;
   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
   l_b2b_party_id   := p_party_id;

   if l_is_party_mapped is NULL then
    --  The following three are not created if party is mapped.
    --  organization
    --  person
    --  org contact
         if x_hz_dup_check = 'Y' then
           if l_import_source_line_id is NULL then
                l_overlay      := null;
            -- Use unencrypted name to find party in TCA table
                party_echeck(
                p_party_id            => x_org_party_id,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_org_name            => x_party_name,
                p_per_first_name      => NULL,
                p_per_last_name       => NULL,
                p_address1            => location_rec.address1,
                p_country             => location_rec.country,
                p_orig_system_reference => org_rec.party_rec.orig_system_reference
                );
                -- If Unencrypted party name doesn't exist in TCA and search by encrpted party name
            if x_rented_list_flag = 'R' and x_org_party_id is NULL then
               -- Encrypt party name
                   x_party_name := AMS_Import_Security_PVT.Get_DeEncrypt_String (
                     p_input_string => org_rec.organization_name,
                     p_header_id => null,
                     p_encrypt_flag => TRUE);

               -- Search by encrpted party name
                   party_echeck(
                 p_party_id            => x_org_party_id,
                     x_return_status       => x_return_status,
                     x_msg_count           => x_msg_count,
                     x_msg_data            => x_msg_data,
                     p_org_name            => x_party_name,
                     p_per_first_name      => NULL,
                     p_per_last_name       => NULL,
                     p_address1            => location_rec.address1,
                     p_country             => location_rec.country,
                     p_orig_system_reference => org_rec.party_rec.orig_system_reference
                    );
            end if;
           else
            open c_b2b_source_rec;
            fetch c_b2b_source_rec into src_ORG_PARTY_ID,src_OCONT_PARTY_ID,src_PARTY_LOCATION_ID,src_ORG_KEY,
            src_org_LOCATION_ID;
            close c_b2b_source_rec;

	    if p_import_list_header_id is NOT NULL then
                   AMS_Utility_PVT.Create_Log (
                   x_return_status   => x_return_status,
                   p_arc_log_used_by => G_ARC_IMPORT_HEADER,
                   p_log_used_by_id  => p_import_list_header_id,
                   p_msg_data        => 'mayjain src_ORG_PARTY_ID=' || src_ORG_PARTY_ID || ' : src_OCONT_PARTY_ID = ' || src_OCONT_PARTY_ID || ' : src_ORG_KEY = ' || src_ORG_KEY ,
                   p_msg_type        => 'DEBUG');
	        end if;

	    x_org_party_id := src_ORG_PARTY_ID;
            x_per_party_id := src_OCONT_PARTY_ID;
            x_location_id  := src_PARTY_LOCATION_ID;
            x_org_location_id  := src_org_LOCATION_ID;
            if src_ORG_PARTY_ID is null and src_ORG_KEY is not NULL then
                open c_org_party;
                fetch c_org_party into x_org_party_id;
                close c_org_party;
            end if;

            if p_party_id is not null then
              l_validate := null;

              open c_validate_b2b;
              fetch c_validate_b2b into l_validate;
              close c_validate_b2b;

              if l_validate is null then
              --Throw error as party_id that was passed is incorrect
                AMS_List_Import_PUB.error_capture (
                   1,
                  'T',
                  'F',
                   null,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   p_import_list_header_id,
                   i_import_source_line_id,
                   null,
                   null,
                   'CONTACT',
                   null,
                   'PARTY_ID : Party does not exists for the mapped party_id '||to_char(p_party_id));
                   x_return_status := 'E';
                   return;
               end if;
            end if;
          end if;

	if x_return_status <> 'S' then
        p_component_name := 'ORGANIZATION';
      	 RETURN;
  	end if;
    if x_org_party_id is not null then
       l_overlay      := 'Y';
    end if;
   end if; -- if l_is_party_mapped is NULL then


 if x_org_party_id is NULL then
/*
     x_party_number := null;
     if x_generate_party_number = 'N' then
         select hz_party_number_s.nextval into x_party_number from dual;
     end if;
     select hz_parties_s.nextval into x_org_party_id from dual;

                org_rec.party_rec.party_number := x_party_number;
                org_rec.party_rec.party_id     := x_org_party_id;
*/
     if x_rented_list_flag = 'R' then
           org_rec := org_rec_null;
           -- org_rec.party_rec.orig_system_reference := i_import_source_line_id;
           org_rec.organization_name := x_party_name;
           org_rec.party_rec.status := 'I';
		org_rec.CREATED_BY_MODULE := 'AMS_LIST_IMPORT';

     end if;
           --org_rec.CREATED_BY_MODULE := 'Oracle Marketing';
	   --R12 tca mandate: bug 4587049: all who calls create_customer should
	   --populate created_by_module. List import populates in AMS_LISTIMPORT_PVT amsvimlb.pls
/* --caller must populate this
	   IF org_rec.CREATED_BY_MODULE is null THEN
	      org_rec.CREATED_BY_MODULE := 'AMS_LIST_IMPORT';
	   END IF;
*/
           org_rec.application_id    := 530;
        if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and x_org_party_id is NULL)) then
	     x_party_number := null;
     		if x_generate_party_number = 'N' then
         		select hz_party_number_s.nextval into x_party_number from dual;
     		end if;
     		select hz_parties_s.nextval into x_org_party_id from dual;
                org_rec.party_rec.party_number := x_party_number;
                org_rec.party_rec.party_id     := x_org_party_id;
               hz_party_v2pub.create_organization(
                                  'F',
                                  org_rec,
                                  x_return_status,
                                  x_msg_count,
                                  x_msg_data,
                                  x_org_party_id,
                                  x_party_number,
                                  x_organization_profile_id
                                );
        end if;
	  if x_return_status <> 'S' then
       		 p_component_name := 'ORGANIZATION';
      		RETURN;
  	  end if;
  else
        if l_rec_update_flag = 'Y' and x_org_party_id is not NULL then
           select OBJECT_VERSION_NUMBER into l_party_obj_number
           from hz_parties
           where party_id = x_org_party_id;
                org_rec.party_rec.party_id     := x_org_party_id;


                AMS_Utility_PVT.Create_Log (
                   x_return_status   => x_return_status,
                   p_arc_log_used_by => G_ARC_IMPORT_HEADER,
                   p_log_used_by_id  => p_import_list_header_id,
                   p_msg_data        =>  'org_rec.CREATED_BY_MODULE : '||org_rec.CREATED_BY_MODULE,
                   p_msg_type        => 'DEBUG');


		-- Set the CREATED_BY_MODULE as null because it is updating the orgnaizatio details
		org_rec.CREATED_BY_MODULE := null ;

       org_rec.party_rec.orig_system_reference := NULL;
           hz_party_v2pub.update_organization(
                                  'F',
                                  org_rec,
                                  l_party_obj_number,
                                  x_organization_profile_id,
                                  x_return_status,
                                  x_msg_count,
                                  x_msg_data
                                );
        end if;
  	if x_return_status <> 'S' then
      	   RETURN;
  	end if;
 end if;    -- x_org_party_id is NULL

-- Creates Person
   x_party_number   := null;
   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;

 if x_hz_dup_check = 'Y' then
   if x_per_party_id is null and l_import_source_line_id is null then
     -- Use unencrypted first and last name to find party in TCA table
     IF x_rented_list_flag <> 'R' THEN
        contact_echeck(
        p_party_id             => x_per_party_id,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_org_party_id         => x_org_party_id,
        p_per_first_name       => person_rec.person_first_name,
        p_per_last_name        => person_rec.person_last_name,
        p_phone_area_code      => x_phone_area_code, -- phone_rec.phone_area_code,
        p_phone_number         => x_phone_number, -- phone_rec.phone_number,
        p_phone_extension      => x_phone_extention, -- phone_rec.phone_extension,
        p_email_address        => x_email_address, -- email_rec.email_address
        p_orig_system_reference => org_rec.party_rec.orig_system_reference,
        p_relationship_code => ocon_rec.party_rel_rec.relationship_code,
        p_relationship_type => ocon_rec.party_rel_rec.relationship_type

     );
     ELSE
        rented_contact_echeck(
        p_party_id             => x_per_party_id,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_org_party_id         => x_org_party_id,
        p_per_first_name       => person_rec.person_first_name,
        p_per_last_name        => person_rec.person_last_name,
        p_phone_area_code      => x_phone_area_code, -- phone_rec.phone_area_code,
        p_phone_number         => x_phone_number, -- phone_rec.phone_number,
        p_phone_extension      => x_phone_extention, -- phone_rec.phone_extension,
        p_email_address        => x_email_address, -- email_rec.email_address
        p_relationship_code => ocon_rec.party_rel_rec.relationship_code,
        p_relationship_type => ocon_rec.party_rel_rec.relationship_type
     );
     END IF;
   end if;
     -- If Unencrypted party name doesn't exist in TCA and search by encrpted party name
     -- SOLIN, bug 4224506
     -- check first name and last name also
     if x_rented_list_flag = 'R' and x_per_party_id is NULL AND
        person_rec.person_first_name IS NOT NULL AND
        person_rec.person_last_name IS NOT NULL
     THEN
	   -- Encrypt name
           person_rec.person_first_name := AMS_Import_Security_PVT.Get_DeEncrypt_String (
             p_input_string => person_rec.person_first_name,
             p_header_id => null,
             p_encrypt_flag => TRUE);

           person_rec.person_last_name := AMS_Import_Security_PVT.Get_DeEncrypt_String (
             p_input_string => person_rec.person_last_name,
             p_header_id => null,
             p_encrypt_flag => TRUE);

	   -- Search by encrpted name

           rented_contact_echeck(
             p_party_id             => x_per_party_id,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_org_party_id         => x_org_party_id,
             p_per_first_name       => person_rec.person_first_name,
             p_per_last_name        => person_rec.person_last_name,
             p_phone_area_code      => x_phone_area_code, -- phone_rec.phone_area_code,
             p_phone_number         => x_phone_number, -- phone_rec.phone_number,
             p_phone_extension      => x_phone_extention, -- phone_rec.phone_extension,
             p_email_address        => x_email_address, -- email_rec.email_address
-- sranka 3/21/2003
-- made changes for supporting EMPLOYEE_OF" relationship
        p_relationship_code => ocon_rec.party_rel_rec.relationship_code,
        p_relationship_type => ocon_rec.party_rel_rec.relationship_type
     );
     end if;
         -- SOLIN, bug 4465931
         -- If contact is not found, dedupe with existing person parties.

         IF x_per_party_id IS NULL THEN
            contact_person_party_echeck(
                p_party_id            => x_per_party_id,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_per_first_name      => person_rec.person_first_name,
                p_per_last_name       => person_rec.person_last_name,
                p_address1            => location_rec.address1,
                p_country             => location_rec.country,
                p_email_address       => x_email_address, -- email_rec.email_address,
                p_ph_country_code     => x_phone_country_code, -- phone_rec.phone_country_code,
                p_ph_area_code        => x_phone_area_code, -- phone_rec.phone_area_code,
                p_ph_number           => x_phone_number, -- phone_rec.phone_number
                p_orig_system_reference => org_rec.party_rec.orig_system_reference
                );
                -- ndadwal added if cond for bug 4966524
		if p_import_list_header_id is NOT NULL then
                   AMS_Utility_PVT.Create_Log (
                   x_return_status   => x_return_status,
                   p_arc_log_used_by => G_ARC_IMPORT_HEADER,
                   p_log_used_by_id  => p_import_list_header_id,
                   p_msg_data        => 'SOLIN per_p_id=' || x_per_party_id,
                   p_msg_type        => 'DEBUG');
	        end if;

         END IF;
         -- SOLIN, end
 end if;

  if x_return_status <> 'S' then
        p_component_name := 'CONTACT';
      RETURN;
  end if;
   if x_per_party_id is not null then
      x_new_party := 'Y';
   end if;
   if x_per_party_id is null then
     if person_rec.person_first_name is not null then
/*
      if x_generate_party_number = 'N' then
                select hz_party_number_s.nextval into x_party_number from dual;
      end if;
                select hz_parties_s.nextval into x_per_party_id from dual;

                person_rec.party_rec.party_number := x_party_number;
                person_rec.party_rec.party_id     := x_per_party_id;

                -- sranka 1/15/2003
                -- assigning the value for the "orig_system_reference" for proper population of data in TCA while importing
                person_rec.party_rec.orig_system_reference := org_rec.party_rec.orig_system_reference;

                person_rec.CREATED_BY_MODULE := 'Oracle Marketing';
                person_rec.application_id    := 530;
*/
                x_return_status                   := null;
                x_msg_count                       := 0;
                x_msg_data                        := null;

     if x_rented_list_flag = 'R' then
        person_rec.party_rec.status := 'I';
     end if;
        if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and x_per_party_id is NULL)) then
              if x_generate_party_number = 'N' then
                select hz_party_number_s.nextval into x_party_number from dual;
              end if;
                select hz_parties_s.nextval into x_per_party_id from dual;

                person_rec.party_rec.party_number := x_party_number;
                person_rec.party_rec.party_id     := x_per_party_id;

                --person_rec.CREATED_BY_MODULE := 'Oracle Marketing';
	        --R12 tca mandate: bug 4587049: all who calls create_customer should
                --populate created_by_module. List import populates in AMS_LISTIMPORT_PVT amsvimlb.pls
/* --caller must populate this
		IF person_rec.CREATED_BY_MODULE is null THEN
                   person_rec.CREATED_BY_MODULE := 'AMS_LIST_IMPORT';
                END IF;
*/
                person_rec.application_id    := 530;
		person_rec.party_rec.orig_system_reference := org_rec.party_rec.orig_system_reference;
                           hz_party_v2pub.create_person(
                                    'F',
                                     person_rec,
                                     x_per_party_id,
                                     x_party_number,
                                     x_person_profile_id,
                                     x_return_status,
                                     x_msg_count,
                                     x_msg_data
                                    );
          end if;
  	if x_return_status <> 'S' then
       		 p_component_name := 'PERSON';
      		Return;
  	end if;
 else
       if l_rec_update_flag = 'Y' and x_per_party_id is not NULL then
           person_rec.party_rec.party_id     := x_per_party_id;
           select OBJECT_VERSION_NUMBER into l_party_obj_number
           from hz_parties
           where party_id = x_per_party_id;
           person_rec.party_rec.orig_system_reference := null;

	   -- Nullify the created by module
	   person_rec.created_by_module := NULL ;

           hz_party_v2pub.update_person(
                                  'F',
                                  person_rec,
                                  l_party_obj_number,
                                  x_person_profile_id,
                                  x_return_status,
                                  x_msg_count,
                                  x_msg_data
                                );
        end if;
       if x_return_status <> 'S' then
         RETURN;
       end if;
 end if;
 end if;    -- x_per_party_id is NULL

-- Creates Org Contact   ,party relationship and party for p rel
         x_party_number := null;
         x_contact_number := null;
         x_return_status  := null;
         x_msg_count        := null;
         x_msg_data         := null;

    if person_rec.person_first_name is not null then
     p_pr_party_id := null;
     open  PARTY_REL_EXISTS;
     fetch PARTY_REL_EXISTS into p_pr_party_id,l_rel_id;
     close PARTY_REL_EXISTS;
     if p_pr_party_id is not null then
        x_party_rel_party_id := p_pr_party_id;
     end if;
     if p_pr_party_id is null then
      Select hz_org_contacts_s.nextval into x_org_contact_id from dual;
         if x_generate_party_number = 'N' then
                select hz_party_number_s.nextval into x_party_number from dual;
         end if;

          ocon_rec.party_rel_rec.subject_id               := x_per_party_id;
          ocon_rec.party_rel_rec.object_id                := x_org_party_id;
          ocon_rec.org_contact_id                         := x_org_contact_id;
          ocon_rec.orig_system_reference                  := x_org_contact_id;

        -- sranka 3/21/2003
        -- made changes for supporting EMPLOYEE_OF" relationship

        --ocon_rec.party_rel_rec.relationship_type        := 'CONTACT';
        --ocon_rec.party_rel_rec.relationship_code        := 'CONTACT_OF';

          IF ocon_rec.party_rel_rec.relationship_type IS NULL THEN
            ocon_rec.party_rel_rec.relationship_type        := 'CONTACT';
          END IF;
          IF ocon_rec.party_rel_rec.relationship_code IS NULL THEN
            ocon_rec.party_rel_rec.relationship_code        := 'CONTACT_OF';
          END IF;


          -- ocon_rec.party_rel_rec.directional_flag         := 'Y';
          ocon_rec.party_rel_rec.start_date               := sysdate;

           --ocon_rec.CREATED_BY_MODULE := 'Oracle Marketing';
	   --R12 tca mandate: bug 4587049: all who calls create_customer should
	   --populate created_by_module. List import populates in AMS_LISTIMPORT_PVT amsvimlb.pls
/* --caller must populate this
	   IF ocon_rec.CREATED_BY_MODULE is null THEN
	      ocon_rec.CREATED_BY_MODULE := 'AMS_LIST_IMPORT';
	   END IF;
*/
          ocon_rec.application_id    := 530;
          ocon_rec.party_rel_rec.subject_type        := 'PERSON';
          ocon_rec.party_rel_rec.subject_table_name  := 'HZ_PARTIES';
          ocon_rec.party_rel_rec.object_type         := 'ORGANIZATION';
          ocon_rec.party_rel_rec.object_table_name   := 'HZ_PARTIES';


          -- sranka 1/15/2003
          -- assigning the value for the "orig_system_reference" for proper population of data in TCA while importing
          ocon_rec.orig_system_reference := org_rec.party_rec.orig_system_reference;
          ocon_rec.party_rel_rec.party_rec.orig_system_reference := org_rec.party_rec.orig_system_reference;


          IF x_generate_party_number = 'N' THEN
            ocon_rec.party_rel_rec.party_rec.party_number := x_party_number;
          END IF;
          IF x_gen_contact_number = 'N' THEN
             select hz_contact_numbers_s.nextval into x_contact_number from dual;
          end if;
          ocon_rec.contact_number                         := x_contact_number;
--          ocon_rec.status     := 'A';
          if x_rented_list_flag = 'R' then
                    -- ocon_rec.status     := 'I';
                    ocon_rec.party_rel_rec.status     := 'I';
              else
                    -- ocon_rec.status     := 'A';
                    ocon_rec.party_rel_rec.status     := 'A';
          end if;
        if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and p_pr_party_id is NULL)) then
          hz_party_contact_v2pub.create_org_contact(
                    'F',
                    ocon_rec,
                    x_org_contact_id,
                    x_party_relationship_id,
                    x_party_rel_party_id,
                    x_party_number,
                    x_return_status,
                    x_msg_count,
                    x_msg_data);
        end if;
  	if x_return_status <> 'S' then
        	p_component_name := 'CONTACT';
      		Return;
  	end if;
   else
        if l_rec_update_flag = 'Y' and p_pr_party_id is not NULL then
           select ORG_CONTACT_ID into x_org_contact_id from hz_org_contacts
           where PARTY_RELATIONSHIP_ID = l_rel_id ; -- x_party_rel_party_id;

           ocon_rec.org_contact_id    := x_org_contact_id;
           select OBJECT_VERSION_NUMBER into l_party_obj_number
           from hz_parties
           where party_id = x_org_party_id;
           select OBJECT_VERSION_NUMBER into l_pr_obj_number
           from hz_relationships
           where relationship_id = l_rel_id and directional_flag = 'F'; -- x_party_rel_party_id;

           select OBJECT_VERSION_NUMBER into l_con_obj_number
           from hz_org_contacts
           where ORG_CONTACT_ID  = x_org_contact_id;
          ocon_rec.orig_system_reference := NULL;
          ocon_rec.party_rel_rec.party_rec.orig_system_reference := NULL;

           hz_party_contact_v2pub.update_org_contact(
                    'F',
                    ocon_rec,
                    l_con_obj_number,
                    l_pr_obj_number,
                    l_party_obj_number,
                    x_return_status,
                    x_msg_count,
                    x_msg_data);
        end if;
        if x_return_status <> 'S' then
                Return;
        end if;
 end if;     -- if p_pr_party_id is null
 end if;     -- if person_rec.first_name is not null
             --  The above three are not created if party is mapped.
             --  organization
             --  person
             --  org contact
 end if;  -- l_is_party_mapped is NULL then

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++


if language_rec.language_name is NOT null and  x_per_party_id  is not null then
    if language_rec.language_name is not NULL then

    -- Create Language

       x_return_status  := null;
       x_msg_count      := null;
       x_msg_data       := null;
       language_rec.native_language := 'Y';

       --language_rec.CREATED_BY_MODULE := 'Oracle Marketing';
       --R12 tca mandate: bug 4587049: all who calls create_customer should
       --populate created_by_module. List import populates in AMS_LISTIMPORT_PVT amsvimlb.pls
/* --caller must populate this
       IF language_rec.CREATED_BY_MODULE is null THEN
          language_rec.CREATED_BY_MODULE := 'AMS_LIST_IMPORT';
       END IF;
*/
       language_rec.application_id    := 530;
       language_rec.party_id := x_per_party_id;
          if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and x_language_use_reference_id is NULL)) then
                HZ_PERSON_INFO_V2PUB.create_person_language(
                    FND_API.G_FALSE,
                    language_rec,
                    x_language_use_reference_id,
                    x_return_status,
                    x_msg_count,
                    x_msg_data
                );
         end if;
     if x_return_status <> 'S' then
       p_component_name := 'LANGUAGE';
       return;
      end if;
    end if; -- if location_rec.address1 is not NULL
else
    if language_rec.language_name is NOT NULL then
        if l_rec_update_flag = 'Y'  and x_per_party_id is not NULL then
           select   OBJECT_VERSION_NUMBER,language_use_reference_id into l_language_obj_number,l_language_use_reference_id
           from hz_person_language
           where party_id = x_per_party_id
           AND   native_language = 'Y';

        language_rec.language_use_reference_id := l_language_use_reference_id;

        HZ_PERSON_INFO_V2PUB.update_person_language(
            FND_API.G_FALSE,
            language_rec,
            l_language_obj_number,
            x_return_status      ,
            x_msg_count          ,
            x_msg_data
        );
        end if;
        if x_return_status <> 'S' then
          return;
        end if;
    end if;-- inner language_rec.language_name is null;
end if; -- language_rec.language_name is null;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++

 if l_is_party_mapped = 'Y' then
    open b2bparty;
    fetch b2bparty into l_b2b_party_exists;
    close b2bparty;
    if l_b2b_party_exists = 'Y' then
        open orgpartyid;
        fetch orgpartyid into x_org_party_id;
        close orgpartyid;
        x_party_rel_party_id := l_b2b_party_id;
      else
       AMS_List_Import_PUB.error_capture (
        1,
        'T',
        'F',
        null,
        x_return_status,
        x_msg_count,
        x_msg_data,
        p_import_list_header_id,
        i_import_source_line_id,
        null,
        null,
        'CONTACT',
        null,
        'PARTY_ID : Party does not exists for the mapped party_id '||to_char(l_b2b_party_id));
        x_return_status := 'E';
        return;
    end if;
 end if;


if x_rented_list_flag <> 'R' then

 if x_hz_dup_check = 'Y' then
 -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- sranka Modified for COLt Enhancements 7/15/2003
if org_location_rec.address1 is not NULL then
    if x_org_locatiON_Id is null  and l_import_source_line_id is null then
        AMS_ListImport_PVT.address_echeck(
        p_party_id              => x_org_party_id,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_location_id           => x_org_locatiON_Id,
        p_address1              => org_location_rec.address1,
        p_city                  => org_location_rec.city,
        p_pcode                 => org_location_rec.postal_code,
        p_country               => org_location_rec.country
                      );
    end if;
    if x_return_status <> 'S' then
        p_component_name := 'ORG_ADDRESS';
      return;
    end if;

 end if; -- org_location_rec.address1 is not NULL
end if; -- SOLIN, bug 4423075, x_hz_dup_check = 'Y'

if x_org_location_id is null and x_org_party_id is not null then
    if org_location_rec.address1 is not NULL then

    -- Create Location for Organization

    AMS_Utility_PVT.Create_Log (
                   x_return_status   => x_return_status,
                   p_arc_log_used_by => G_ARC_IMPORT_HEADER,
                   p_log_used_by_id  => p_import_list_header_id,
                   p_msg_data        => 'Create Location for Organization : Process starts ' ,
                   p_msg_type        => 'DEBUG');

       x_return_status  := null;
       x_msg_count      := null;
       x_msg_data       := null;
          if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and x_org_location_id is NULL)) then

	     l_address_key :=hz_fuzzy_pub.Generate_Key (
                                p_key_type => 'ADDRESS',
                                p_address1 =>  org_location_rec.address1,
                                p_postal_code => org_location_rec.postal_code);

	     AMS_Utility_PVT.Create_Log (
                   x_return_status   => x_return_status,
                   p_arc_log_used_by => G_ARC_IMPORT_HEADER,
                   p_log_used_by_id  => p_import_list_header_id,
                   p_msg_data        => 'Create Location for Organization : Check existence for key '||l_address_key ,
                   p_msg_type        => 'DEBUG');


	   select count(*) INTO l_address_key_count from hz_locations where address_key=l_address_key;

	     if l_address_key_count =0 then

	      AMS_Utility_PVT.Create_Log (
                   x_return_status   => x_return_status,
                   p_arc_log_used_by => G_ARC_IMPORT_HEADER,
                   p_log_used_by_id  => p_import_list_header_id,
                   p_msg_data        => 'Create Location for Organization : Creating location ',
                   p_msg_type        => 'DEBUG');

		AMS_ListImport_PVT.create_location (
		org_location_rec  ,
		x_return_status ,
		x_msg_count     ,
		x_msg_data      ,
		x_org_location_id   );
             end if;
	 end if;
     if x_return_status <> 'S' then
       p_component_name := 'ORG_ADDRESS';
       return;
      end if;
    end if;
else
    if l_rec_update_flag = 'Y'  and x_org_location_id is not NULL then
       select OBJECT_VERSION_NUMBER into l_loc_obj_number
       from hz_locations
       where location_id = x_org_location_id;
    org_location_rec.location_id := x_org_location_id;
    hz_location_v2pub.update_location(
    'F',
    org_location_rec,
    l_loc_obj_number,
    x_return_status,
    x_msg_count,
    x_msg_data
    );
    end if;
    if x_return_status <> 'S' then
      return;
    end if;
end if; -- x_org_location_id is null;

-- Creates party site for Org address

   l_org_lp_psite_id := null;
   open ORG_LOCATION_EXISTS;
   fetch ORG_LOCATION_EXISTS into l_org_lp_psite_id;
   close ORG_LOCATION_EXISTS;
if l_org_lp_psite_id is null and x_org_party_id is not null and x_org_location_id is not null then
-- Create Party Site
   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
   x_party_site_number := null;

  org_psite_rec.party_id                 := x_org_party_id;
  org_psite_rec.location_id              := x_org_location_id;
  org_psite_rec.status                   := 'A';
  -- x_pty_site_id := null;
     if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_org_lp_psite_id is NULL)) then
       AMS_ListImport_PVT.create_party_site(
                org_psite_rec,
                x_return_status,
                x_msg_count,
                x_msg_data,
                x_org_party_site_id, -- sranka
                x_party_site_number
                );
       if x_return_status <> 'S' then
        p_component_name := 'ORG_ADDRESS';
        return;
       end if;
      end if;
  else
      if l_rec_update_flag = 'Y'  and l_org_lp_psite_id is not NULL then
        org_psite_rec.party_site_id            := l_org_lp_psite_id;
           select OBJECT_VERSION_NUMBER into l_ps_obj_number
           from hz_party_sites
           where party_site_id = l_org_lp_psite_id;
        hz_party_site_v2pub.update_party_site(
                'F',
                org_psite_rec,
                l_ps_obj_number,
                x_return_status,
                x_msg_count,
                x_msg_data
                );
                if x_return_status <> 'S' then
                        return;
                end if;
      end if;
end if;         -- if l_org_lp_psite_id is null then

 -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    if x_locatiON_Id is null  and l_import_source_line_id is null then
        AMS_ListImport_PVT.address_echeck(
        p_party_id              => x_org_party_id,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_location_id           => x_locatiON_Id,
        p_address1              => location_rec.address1,
        p_city                  => location_rec.city,
        p_pcode                 => location_rec.postal_code,
        p_country               => location_rec.country
                      );
    end if;
    if x_return_status <> 'S' then
        p_component_name := 'ADDRESS';
      return;
    end if;


if x_location_id is null and x_org_party_id is not null then
    if location_rec.address1 is not NULL then

    -- Create Location

       x_return_status  := null;
       x_msg_count      := null;
       x_msg_data       := null;
          if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and x_location_id is NULL)) then
            AMS_ListImport_PVT.create_location (
            location_rec  ,
            x_return_status ,
            x_msg_count     ,
            x_msg_data      ,
            x_location_id   );
         end if;
     if x_return_status <> 'S' then
       p_component_name := 'ADDRESS';
       return;
      end if;
    end if; -- if location_rec.address1 is not NULL
else
    if l_rec_update_flag = 'Y'  and x_location_id is not NULL then
       select OBJECT_VERSION_NUMBER into l_loc_obj_number
       from hz_locations
       where location_id = x_location_id;
    location_rec.location_id := x_location_id;
    hz_location_v2pub.update_location(
    'F',
    location_rec,
    l_loc_obj_number,
    x_return_status,
    x_msg_count,
    x_msg_data
    );
    end if;
    if x_return_status <> 'S' then
      return;
    end if;
end if; -- x_location_id is null;


   l_lp_psite_id := null;
   open LOCATION_EXISTS;
   fetch LOCATION_EXISTS into l_lp_psite_id;
   close LOCATION_EXISTS;
if l_lp_psite_id is null and x_org_party_id is not null and x_location_id is not null then
-- Create Party Site
   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
   x_party_site_number := null;

  psite_rec.party_id                 := x_org_party_id;
  psite_rec.location_id              := x_location_id;
  psite_rec.status                   := 'A';
  -- x_pty_site_id := null;
     if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_lp_psite_id is NULL)) then
       AMS_ListImport_PVT.create_party_site(
                psite_rec,
                x_return_status,
                x_msg_count,
                x_msg_data,
                x_party_site_id,
                x_party_site_number
                );
       if x_return_status <> 'S' then
        p_component_name := 'ADDRESS';
        return;
       end if;
      end if;
  else
      if l_rec_update_flag = 'Y'  and l_lp_psite_id is not NULL then
        psite_rec.party_site_id            := l_lp_psite_id;
           select OBJECT_VERSION_NUMBER into l_ps_obj_number
           from hz_party_sites
           where party_site_id = l_lp_psite_id;
        hz_party_site_v2pub.update_party_site(
                'F',
                psite_rec,
                l_ps_obj_number,
                x_return_status,
                x_msg_count,
                x_msg_data
                );
                if x_return_status <> 'S' then
                        return;
                end if;
      end if;
end if;         -- if l_lp_psite_id is null then

if x_party_site_id is not null and psiteuse_rec.site_use_type is not null then
-- Create Party Site use
   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;

  psiteuse_rec.party_site_id	:= x_party_site_id;
  psiteuse_rec.status           := 'A';
  AMS_ListImport_PVT.create_party_site_use(
                psiteuse_rec,
                x_return_status,
                x_msg_count,
                x_msg_data,
                x_party_site_use_id
                );
  if x_return_status <> 'S' then
        p_component_name := 'ADDRESS';
      return;
  end if;
end if;

        -- Updates the org contacts party_site_id
        -- **************************************************

   if (person_rec.person_first_name is not null and x_org_contact_id is not null) and
     (l_lp_psite_id is not null or x_party_site_id is not null) then
        open c_org_cont_rel;
        fetch c_org_cont_rel into l_object_version1;
        close c_org_cont_rel;
        open c_relationship;
        fetch c_relationship into l_object_version2;
        close c_relationship;

        open c_party_rel;
        fetch c_party_rel into l_object_version3;
        close c_party_rel;

        ocon_rec.org_contact_id     := x_org_contact_id;
--        ocon_rec.party_site_id      := x_party_site_id;
          if l_lp_psite_id is not null then
          ocon_rec.party_site_id         := l_lp_psite_id;
          end if;
          if x_party_site_id is not null then
          ocon_rec.party_site_id         := x_party_site_id;
          end if;

        ocon_rec.party_rel_rec.object_id := x_org_party_id;
          ocon_rec.orig_system_reference := NULL;
          ocon_rec.party_rel_rec.party_rec.orig_system_reference := NULL;
       hz_party_contact_v2pub.update_org_contact(
                'F',
                ocon_rec,
                l_object_version1,
                l_object_version2,
                l_object_version3,
                x_return_status,
                x_msg_count,
                x_msg_data);
      if x_msg_count > 1 then
         FOR i IN 1..x_msg_count  LOOP
         x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
         x_tmp_var1 := substrb(x_tmp_var1 || ' '|| x_tmp_var,1,4000);
        END LOOP;
        x_msg_data := x_tmp_var1;
      END IF;

     if x_return_status <> 'S' then
        p_component_name := 'CONTACT';
          x_return_status  :=  x_return_status;
          x_msg_count      :=  x_msg_count;
          x_msg_data       :=  x_msg_data;
        return;
     end if;

   end if;

        -- ************************************************

   -- Creating party_site for Contacts.

   if person_rec.person_first_name is not null and x_party_rel_party_id is not null then
      if location_rec.address1 is not NULL and  x_location_id is not null then
         l_lp_psite_id := null;
         open CHECK_PSITE_EXISTS;
         fetch CHECK_PSITE_EXISTS into l_lp_psite_id;
         close CHECK_PSITE_EXISTS;
         if l_lp_psite_id is null then
            -- Create Party Site
            x_return_status  := null;
            x_msg_count      := null;
            x_msg_data       := null;
            x_party_site_number := null;

            psite_rec.party_id                 := x_party_rel_party_id;
            psite_rec.location_id              := x_location_id;
            psite_rec.status                   := 'A';

            AMS_ListImport_PVT.create_party_site(
                psite_rec,
                x_return_status,
                x_msg_count,
                x_msg_data,
                x_party_site_id,
                x_party_site_number
                );

  		if x_return_status <> 'S' then
        		p_component_name := 'ADDRESS';
      			return;
  		end if;
		if x_party_site_id is not null and psiteuse_rec.site_use_type is not null then
		-- Create Party Site use
   			x_return_status  := null;
   			x_msg_count      := null;
   			x_msg_data       := null;

  			psiteuse_rec.party_site_id    := x_party_site_id;
  			psiteuse_rec.status           := 'A';
  			AMS_ListImport_PVT.create_party_site_use(
                	psiteuse_rec,
                	x_return_status,
                	x_msg_count,
                	x_msg_data,
                	x_party_site_use_id
                	);
  			if x_return_status <> 'S' then
        			p_component_name := 'ADDRESS';
      				return;
  			end if;
		end if;
         end if;
       end if;
      end if;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Create organization's Email

if  org_email_rec.email_address is not NULL and x_org_party_id is not null  then

   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
         cpoint_rec.contact_point_type     := 'EMAIL';
         cpoint_rec.status                 := 'A';
         cpoint_rec.owner_table_name       := 'HZ_PARTIES';
         cpoint_rec.owner_table_id         := x_org_party_id;
         email_rec.email_address	   := org_email_rec.email_address;
        l_email_exists := NULL;
        open org_email_exists(x_org_party_id);
        fetch org_email_exists into l_email_exists;
        close org_email_exists;
        if l_email_exists is NULL then
          if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_email_exists is NULL)) then
             AMS_ListImport_PVT.create_contact_point(
                    cpoint_rec,
                    edi_rec,
                    email_rec,
                    phone_rec,
                    telex_rec,
                    web_rec,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    x_contact_point_id);
         end if;
          if x_return_status <> 'S' then
            p_component_name := 'EMAIL';
            return;
          end if;
       end if; -- l_email_exists is NULL then
end if; -- org_email_rec.email_address
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Create organization  Phone -- sranka

if org_party_site_phone_rec.phone_number is not NULL and x_org_party_site_id is not null  then

   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
  cpoint_rec.contact_point_type     := 'PHONE';
  cpoint_rec.status                 := 'A';
  cpoint_rec.owner_table_name       := 'HZ_PARTIES';
  cpoint_rec.owner_table_id         := x_org_party_site_id;
  org_party_site_phone_rec.phone_line_type         := nvl(x_phone_type,'GEN');
  org_party_site_phone_rec.phone_number            := org_phone_rec.phone_number;
  org_party_site_phone_rec.phone_country_code      := org_phone_rec.phone_country_code;
  org_party_site_phone_rec.phone_area_code         := org_phone_rec.phone_area_code;
  org_party_site_phone_rec.phone_extension         := org_phone_rec.phone_extension;

  l_phone_exists := NULL;
  open org_party_site_phone_exists(x_org_party_site_id,org_party_site_phone_rec.phone_line_type);
  fetch org_party_site_phone_exists into l_phone_exists;
  close org_party_site_phone_exists;
  if l_phone_exists is not null then
        l_phone_id := NULL;
        open c_org_party_site_phone_id(cpoint_rec.owner_table_id,org_party_site_phone_rec.phone_line_type);
        fetch c_org_party_site_phone_id into l_phone_id;
        close c_org_party_site_phone_id;
  end if;
  if l_phone_exists is NULL then
      if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_phone_exists is NULL)) then
            AMS_ListImport_PVT.create_contact_point(
                   cpoint_rec,
                   edi_rec,
                   email_rec,
                   org_party_site_phone_rec,
                   telex_rec,
                   web_rec,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   x_contact_point_id);
             l_phone_id := x_contact_point_id;
       end if;
	if x_return_status <> 'S' then
          p_component_name := 'PHONE';
	  return;
	end if;
      end if; -- l_phone_exists is NULL then

end if; -- org_phone_rec.phone_number
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Create organization  Phone

if org_phone_rec.phone_number is not NULL and x_org_party_id is not null  then

   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
  cpoint_rec.contact_point_type     := 'PHONE';
  cpoint_rec.status                 := 'A';
  cpoint_rec.owner_table_name       := 'HZ_PARTIES';
  cpoint_rec.owner_table_id         := x_org_party_id;
  phone_rec.phone_line_type         := nvl(x_phone_type,'GEN');
  phone_rec.phone_number            := org_phone_rec.phone_number;
  phone_rec.phone_country_code      := org_phone_rec.phone_country_code;
  phone_rec.phone_area_code         := org_phone_rec.phone_area_code;
  phone_rec.phone_extension         := org_phone_rec.phone_extension;

  l_phone_exists := NULL;
  open org_phone_exists(x_org_party_id,phone_rec.phone_line_type);
  fetch org_phone_exists into l_phone_exists;
  close org_phone_exists;
  if l_phone_exists is not null then
        l_phone_id := NULL;
        open c_org_phone_id(cpoint_rec.owner_table_id,phone_rec.phone_line_type);
        fetch c_org_phone_id into l_phone_id;
        close c_org_phone_id;
  end if;
  if l_phone_exists is NULL then
      if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_phone_exists is NULL)) then
            AMS_ListImport_PVT.create_contact_point(
                   cpoint_rec,
                   edi_rec,
                   email_rec,
                   phone_rec,
                   telex_rec,
                   web_rec,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   x_contact_point_id);
             l_phone_id := x_contact_point_id;
       end if;
	if x_return_status <> 'S' then
          p_component_name := 'PHONE';
	  return;
	end if;
      end if; -- l_phone_exists is NULL then

end if; -- org_phone_rec.phone_number
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Create contact points  Phone

if x_phone_number is not NULL and (x_party_rel_party_id is not null or x_org_party_id is not null ) then

   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
  cpoint_rec.contact_point_type     := 'PHONE';
  cpoint_rec.status                 := 'A';
  cpoint_rec.owner_table_name       := 'HZ_PARTIES';
  if x_org_party_id is not null then
     cpoint_rec.owner_table_id         := x_org_party_id;
  end if;
  if x_party_rel_party_id is not null then
     cpoint_rec.owner_table_id         := x_party_rel_party_id;
  end if;
  phone_rec.phone_line_type         := nvl(x_phone_type,'GEN');
  phone_rec.phone_number            := x_phone_number;
  phone_rec.phone_country_code      := x_phone_country_code;
  phone_rec.phone_area_code         := x_phone_area_code;
  phone_rec.phone_extension         := x_phone_extention;

  l_phone_exists := NULL;
  open phone_exists(x_party_rel_party_id,phone_rec.phone_line_type);
  fetch phone_exists into l_phone_exists;
  close phone_exists;
  if l_phone_exists is not null then
        l_phone_id := NULL;
        open c_phone_id(cpoint_rec.owner_table_id,phone_rec.phone_line_type);
        fetch c_phone_id into l_phone_id;
        close c_phone_id;
  end if;
  if l_phone_exists is NULL then
      if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_phone_exists is NULL)) then
            AMS_ListImport_PVT.create_contact_point(
                   cpoint_rec,
                   edi_rec,
                   email_rec,
                   phone_rec,
                   telex_rec,
                   web_rec,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   x_contact_point_id);
             l_phone_id := x_contact_point_id;
       end if;
  if x_return_status <> 'S' then
        p_component_name := 'PHONE';
	return;
  end if;
 end if; -- l_phone_exists is NULL then

end if; -- x_phone_number

-- Create contact points  Fax

if x_fax_number is not NULL and (x_party_rel_party_id is not null or x_org_party_id is not null ) then

   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
  cpoint_rec.contact_point_type     := 'PHONE';
  cpoint_rec.status                 := 'A';
  cpoint_rec.owner_table_name       := 'HZ_PARTIES';
  if x_org_party_id is not null then
     cpoint_rec.owner_table_id         := x_org_party_id;
  end if;
  if x_party_rel_party_id is not null then
     cpoint_rec.owner_table_id         := x_party_rel_party_id;
  end if;
  fax_rec.phone_line_type         := 'FAX';--'GEN';
  fax_rec.phone_number            := x_fax_number;
  fax_rec.phone_country_code      := x_fax_country_code;
  fax_rec.phone_area_code         := x_fax_area_code;

  l_fax_exists := NULL;
  open fax_exists(x_party_rel_party_id);
  fetch fax_exists into l_fax_exists;
  close fax_exists;
  if l_fax_exists is not null then
        l_fax_id := NULL;
        open c_fax_id(cpoint_rec.owner_table_id);
        fetch c_fax_id into l_fax_id;
        close c_fax_id;
  end if;
  if l_fax_exists is NULL then
          if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_fax_exists is NULL)) then
            AMS_ListImport_PVT.create_contact_point(
                   cpoint_rec,
                   edi_rec,
                   email_rec,
                   fax_rec,
                   telex_rec,
                   web_rec,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   x_contact_point_id);
             l_fax_id := x_contact_point_id;
  end if;
  if x_return_status <> 'S' then
        p_component_name := 'FAX';
	return;
  end if;
 end if; -- l_phone_exists is NULL then

end if; -- x_phone_number

-- B2B URL

if x_url is not NULL and length(x_url) > 1 and  x_org_party_id is not null then

   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
  cpoint_rec.contact_point_type     := 'WEB';
  cpoint_rec.status                 := 'A';
  cpoint_rec.owner_table_name       := 'HZ_PARTIES';
  if x_org_party_id is not null then
     cpoint_rec.owner_table_id         := x_org_party_id;
  end if;
  web_rec.url := x_url;
  web_rec.web_type     := 'com';

  l_url_exists := NULL;
  open url_exists(x_org_party_id);
  fetch url_exists into l_url_exists;
  close url_exists;
  if l_url_exists is not null then
        l_url_id := NULL;
        open c_url_id(cpoint_rec.owner_table_id);
        fetch c_url_id into l_url_id;
        close c_url_id;
  end if;
  if l_url_exists is NULL then
          if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_url_exists is NULL)) then
            AMS_ListImport_PVT.create_contact_point(
                   cpoint_rec,
                   edi_rec,
                   email_rec,
                   fax_rec,
                   telex_rec,
                   web_rec,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   x_contact_point_id);
             l_url_id := x_contact_point_id;
  end if;
  if x_return_status <> 'S' then
        p_component_name := 'PHONE';
	return;
  end if;
 end if; -- l_phone_exists is NULL then

end if; -- x_phone_number

-- Create contact points Email

if  x_email_address is not NULL and (x_party_rel_party_id is not null or x_org_party_id is not null ) then

   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
         cpoint_rec.contact_point_type     := 'EMAIL';
         cpoint_rec.status                 := 'A';
         cpoint_rec.owner_table_name       := 'HZ_PARTIES';
         if x_org_party_id is not null then
           cpoint_rec.owner_table_id         := x_org_party_id;
         end if;
         if x_party_rel_party_id is not null then
           cpoint_rec.owner_table_id         := x_party_rel_party_id;
         end if;
         email_rec.email_address := x_email_address;
        l_email_exists := NULL;
        open email_exists(x_party_rel_party_id);
        fetch email_exists into l_email_exists;
        close email_exists;
        if l_email_exists is NULL then
          if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_email_exists is NULL)) then
         AMS_ListImport_PVT.create_contact_point(
                    cpoint_rec,
                    edi_rec,
                    email_rec,
                    phone_rec,
                    telex_rec,
                    web_rec,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    x_contact_point_id);
         end if;
 if x_return_status <> 'S' then
        p_component_name := 'EMAIL';
     return;
  end if;
 end if; -- l_email_exists is NULL then
end if; -- x_email_address
/*
if ((x_phone_number is not NULL OR x_email_address is not NULL ) and l_rec_update_flag = 'Y' and x_party_rel_party_id is not null) then
  phone_rec.phone_line_type         := 'GEN';
  phone_rec.phone_number            := x_phone_number;
  phone_rec.phone_country_code      := x_phone_country_code;
  phone_rec.phone_area_code         := x_phone_area_code;
  phone_rec.phone_extension         := x_phone_extention;

  l_phone_id := NULL;
  open c_phone_id(x_party_rel_party_id,phone_rec.phone_line_type);
  fetch c_phone_id into l_phone_id;
  close c_phone_id;
  if l_phone_id is not null then
     x_contact_point_id := l_phone_id;
  end if;

  email_rec.email_address := x_email_address;
 l_email_id := NULL;
 open c_email_id(x_party_rel_party_id);
 fetch c_email_id into l_email_id;
 close c_email_id;
  if l_email_id is not null then
     x_contact_point_id := l_email_id;
  end if;
  cpoint_rec.contact_point_id       := x_contact_point_id;
           select OBJECT_VERSION_NUMBER into l_cp_obj_number
           from hz_contact_points
           where contact_point_id = x_contact_point_id;

  hz_contact_point_v2pub.update_contact_point(
                   'F',
                   cpoint_rec,
                   edi_rec,
                   email_rec,
                   phone_rec,
                   telex_rec,
                   web_rec,
                   l_cp_obj_number,
                   x_return_status,
                   x_msg_count,
                   x_msg_data);
        if x_return_status <> 'S' then
            return;
        end if;
end if;
*/
end if; -- if x_rented_list_flag <> 'R'

-- Updates the marketing tables with the party_id
    if l_is_party_mapped is NULL  then
       l_enabled_flag := 'Y';
    end if;

    if l_is_party_mapped = 'Y' and l_b2b_party_exists = 'Y' then
       l_overlay := 'Y';
       l_enabled_flag := 'Y';
    end if;

   if l_is_party_mapped = 'Y' and l_b2b_party_exists is NULL then
       l_enabled_flag := 'N';
    end if;

   i_party_id := null;

   if nvl(x_party_rel_party_id,0) > 0  then
      i_party_id := x_party_rel_party_id;
   elsif x_org_party_id is not null and x_per_party_id is not null then
      i_party_id := nvl(p_party_id, x_org_party_id);
   end if;

   if i_party_id is null then
      i_party_id := x_org_party_id;
   end if;

   if i_party_id is not null  then
      p_party_id := i_party_id ;
   end if;
   if i_party_id is not null and p_import_list_header_id is not null then
   UPDATE ams_imp_source_lines
          SET party_id = i_party_id,
              organization_id = x_org_party_id,
              load_status  = 'SUCCESS',
              contact_point_id = l_phone_id,
              location_id  = x_location_id,
              enabled_flag = l_enabled_flag
--   WHERE  import_source_line_id = org_rec.party_rec.orig_system_reference
-- sranka 1/14/2003
     WHERE  import_source_line_id = l_import_source_line_id
     AND  import_list_header_id = p_import_list_header_id;
     x_return_status := 'S';
      open b2bxml;
      fetch b2bxml into l_xml_element_id;
      close b2bxml;
      if l_xml_element_id is not null then
      	process_element_success( p_import_list_header_id, l_xml_element_id) ;
      end if;
   end if;
   if i_party_id is not null and p_import_list_header_id is not null then
   create_party_source (p_import_list_header_id, i_import_source_line_id,l_overlay);
   end if;

end if; -- x_b2b = 'Y'



if x_b2b = 'N' then





-- Creates Person
--      i_import_source_line_id := person_rec.party_rec.orig_system_reference; // original
      i_import_source_line_id := l_import_source_line_id;

      x_return_status     := null;
      x_msg_count           := null;
      x_msg_data            := null;
      x_party_number := null;
      l_b2c_party_id := p_party_id;

 if l_is_party_mapped is NULL then
    --  The following three are not created if party is mapped.
    --  person

 if x_hz_dup_check = 'Y' then
        l_overlay      := null;
        -- Use unencrypted name to find party in TCA table


    if x_per_party_id is null and i_import_source_line_id is null then
      IF x_rented_list_flag <> 'R' THEN




        person_party_echeck(
        p_party_id            => x_per_party_id,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_per_first_name      => person_rec.person_first_name,
        p_per_last_name       => person_rec.person_last_name,
        p_address1            => location_rec.address1,
        p_country             => location_rec.country,
        p_email_address       => x_email_address, -- email_rec.email_address,
        p_ph_country_code     => x_phone_country_code, -- phone_rec.phone_country_code,
        p_ph_area_code        => x_phone_area_code, -- phone_rec.phone_area_code,
        p_ph_number           => x_phone_number, -- phone_rec.phone_number
        p_orig_system_reference => org_rec.party_rec.orig_system_reference

        );


      ELSE
        rented_person_party_echeck(
        p_party_id            => x_per_party_id,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_per_first_name      => person_rec.person_first_name,
        p_per_last_name       => person_rec.person_last_name,
        p_address1            => location_rec.address1,
        p_country             => location_rec.country,
        p_email_address       => x_email_address, -- email_rec.email_address,
        p_ph_country_code     => x_phone_country_code, -- phone_rec.phone_country_code,
        p_ph_area_code        => x_phone_area_code, -- phone_rec.phone_area_code,
        p_ph_number           => x_phone_number -- phone_rec.phone_number
        );
    END IF;
    else
        open c_b2c_source_rec;
	fetch c_b2c_source_rec into src_person_PARTY_ID,src_PARTY_LOCATION_ID;
	close c_b2c_source_rec;
        x_per_party_id := src_person_PARTY_ID;
        x_location_id  := src_PARTY_LOCATION_ID;

     if p_party_id is not null then
      l_validate := null;

      open c_validate_b2c;
      fetch c_validate_b2c into l_validate;
      close c_validate_b2c;

      if l_validate is null then
        --Throw error as party_id that was passed is incorrect
       AMS_List_Import_PUB.error_capture (
         1,
        'T',
        'F',
         null,
         x_return_status,
         x_msg_count,
         x_msg_data,
         p_import_list_header_id,
         i_import_source_line_id,
         null,
         null,
         'PERSON',
         null,
         'PARTY_ID : Party does not exists for the mapped party_id '||to_char(p_party_id));
         x_return_status := 'E';
         return;
      end if;
     end if;
    end if;

        -- Unencrypted party name doesn't exist in TCA and search by encrpted party name
        -- SOLIN, bug 4224506
        -- check first name and last name also
        if x_rented_list_flag = 'R' and x_per_party_id is NULL AND
           person_rec.person_first_name IS NOT NULL AND
           person_rec.person_last_name IS NOT NULL
        THEN
           -- Encrypt first name and last name
	   person_rec.person_first_name := AMS_Import_Security_PVT.Get_DeEncrypt_String (
             p_input_string => person_rec.person_first_name,
             p_header_id => null,
             p_encrypt_flag => TRUE);
           person_rec.person_last_name := AMS_Import_Security_PVT.Get_DeEncrypt_String (
             p_input_string => person_rec.person_last_name,
             p_header_id => null,
             p_encrypt_flag => TRUE);


           rented_person_party_echeck(
             p_party_id            => x_per_party_id,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_per_first_name      => person_rec.person_first_name,
             p_per_last_name       => person_rec.person_last_name,
             p_address1            => location_rec.address1,
             p_country             => location_rec.country,
             p_email_address       => x_email_address, -- email_rec.email_address,
             p_ph_country_code     => x_phone_country_code, -- phone_rec.phone_country_code,
             p_ph_area_code        => x_phone_area_code, -- phone_rec.phone_area_code,
             p_ph_number           => x_phone_number -- phone_rec.phone_number
             );
	end if;



  	if x_return_status <> 'S' then
        p_component_name := 'PERSON';
		return;
  	end if;
        if x_per_party_id is not null then
           l_overlay      := 'Y';
           x_new_party    := 'Y';
        end if;
 end if;





    if x_per_party_id is null then
/*
      if x_generate_party_number = 'N' then
          select hz_party_number_s.nextval into x_party_number from dual;
      end if;
          select hz_parties_s.nextval into x_per_party_id from dual;

          person_rec.party_rec.party_number := x_party_number;
          person_rec.party_rec.party_id     := x_per_party_id;
*/
          x_return_status := null;
          x_msg_count     := 0;
          x_msg_data      := null;

     if x_rented_list_flag = 'R' then
        person_rec.party_rec.status := 'I';
        --person_rec.person_first_name  := 'MKT PARTY FIRST NAME-'||person_rec.party_rec.orig_system_reference;
        --person_rec.person_last_name   := 'MKT PARTY LAST NAME-'||person_rec.party_rec.orig_system_reference;
     end if;

       --person_rec.CREATED_BY_MODULE        := 'Oracle Marketing';
       --R12 tca mandate: bug 4587049: all who calls create_customer should
       --populate created_by_module. List import populates in AMS_LISTIMPORT_PVT amsvimlb.pls
/* --caller must populate this
       IF person_rec.CREATED_BY_MODULE is null THEN
          person_rec.CREATED_BY_MODULE := 'AMS_LIST_IMPORT';
       END IF;
*/
     person_rec.application_id           := 530;
        if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and x_per_party_id is NULL)) then
      		if x_generate_party_number = 'N' then
          		select hz_party_number_s.nextval into x_party_number from dual;
      		end if;
          select hz_parties_s.nextval into x_per_party_id from dual;
          person_rec.party_rec.party_number := x_party_number;
          person_rec.party_rec.party_id     := x_per_party_id;



                  hz_party_v2pub.create_person(
                              'F',
                              person_rec,
                              x_per_party_id,
                              x_party_number,
                              x_person_profile_id,
                              x_return_status,
                              x_msg_count,
                              x_msg_data);


         end if;


  	if x_return_status <> 'S' then
       		 p_component_name := 'PERSON';
		RETURN;
  	end if;
 else
       if l_rec_update_flag = 'Y' and x_per_party_id is not NULL then
           person_rec.party_rec.party_id     := x_per_party_id;
           select OBJECT_VERSION_NUMBER into l_party_obj_number
           from hz_parties
           where party_id = x_per_party_id;
           person_rec.party_rec.orig_system_reference := null;

	   -- Nullify the created by module
	   person_rec.created_by_module := NULL ;
           hz_party_v2pub.update_person(
                                  'F',
                                  person_rec,
                                  l_party_obj_number,
                                  x_person_profile_id,
                                  x_return_status,
                                  x_msg_count,
                                  x_msg_data
                                );
        end if;
       if x_return_status <> 'S' then
         RETURN;
       end if;
 end if; --  x_per_party_id is null then


    --  The above is not created if party is mapped.
    --  person
end if;  --  l_is_party_mapped is NULL then

---++++++++++++++++++++++++++++++++++++++++


if language_rec.language_name is NOT null and x_per_party_id is not null then
    if language_rec.language_name is not NULL then

    -- Create Language

       x_return_status  := null;
       x_msg_count      := null;
       x_msg_data       := null;
       language_rec.native_language := 'Y';

       --language_rec.CREATED_BY_MODULE := 'Oracle Marketing';
       --R12 tca mandate: bug 4587049: all who calls create_customer should
       --populate created_by_module. List import populates in AMS_LISTIMPORT_PVT amsvimlb.pls
/* --caller must populate this
       IF language_rec.CREATED_BY_MODULE is null THEN
          language_rec.CREATED_BY_MODULE := 'AMS_LIST_IMPORT';
       END IF;
*/
       language_rec.application_id    := 530;
              language_rec.party_id := x_per_party_id;
          if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and x_location_id is NULL)) then

                HZ_PERSON_INFO_V2PUB.create_person_language(
                    FND_API.G_FALSE,
                    language_rec,
                    x_language_use_reference_id,
                    x_return_status,
                    x_msg_count,
                    x_msg_data
                );



         end if;
     if x_return_status <> 'S' then
       p_component_name := 'LANGUAGE';
       return;
      end if;
    end if; -- if location_rec.address1 is not NULL
else



    if l_rec_update_flag = 'Y'  and x_per_party_id is not NULL then


        IF person_rec.person_first_name IS NOT NULL AND language_rec.language_name is not NULL then
            select   OBJECT_VERSION_NUMBER,language_use_reference_id into l_language_obj_number,l_language_use_reference_id
            from hz_person_language
            where party_id = x_per_party_id
            AND   native_language = 'Y';

            language_rec.language_use_reference_id := l_language_use_reference_id;

            HZ_PERSON_INFO_V2PUB.update_person_language(
            FND_API.G_FALSE,
            language_rec,
            l_language_obj_number,
            x_return_status      ,
            x_msg_count          ,
            x_msg_data
            );
        END if;
    end if;




    if x_return_status <> 'S' then
      return;
    end if;
end if; -- language_rec.language_name is null;

---++++++++++++++++++++++++++++++++++++++++


 if l_is_party_mapped = 'Y' then
    open b2cparty;
    fetch b2cparty into l_b2c_party_exists;
    close b2cparty;
    if l_b2c_party_exists = 'Y' then
        x_per_party_id := l_b2c_party_id;
      else
       AMS_List_Import_PUB.error_capture (
        1,
        'T',
        'F',
        null,
        x_return_status,
        x_msg_count,
        x_msg_data,
        p_import_list_header_id,
        i_import_source_line_id,
        null,
        null,
	'PERSON',
        null,
        'PARTY_ID : Party does not exists for the mapped party_id '||to_char(l_b2c_party_id));
        x_return_status := 'E';
        return;
    end if;
 end if;

if x_rented_list_flag <> 'R' then
 if x_hz_dup_check = 'Y' then
    if x_location_id is null and i_import_source_line_id is null then
   AMS_ListImport_PVT.address_echeck(
   p_party_id              => x_per_party_id,
   x_return_status       => x_return_status,
   x_msg_count           => x_msg_count,
   x_msg_data            => x_msg_data,
   p_location_id           => x_location_id,
   p_address1              => location_rec.address1,
   p_city                  => location_rec.city,
   p_pcode                 => location_rec.postal_code,
   p_country               => location_rec.country
                  );
   end if;
  	if x_return_status <> 'S' then
        p_component_name := 'ADDRESS';
		return;
  	end if;
 end if;

if x_location_id is null and x_per_party_id is not null then
if location_rec.address1 is not NULL then

-- Create Location

   x_return_status     := null;
   x_msg_count      := null;
   x_msg_data       := null;
    if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and x_location_id is NULL)) then
       AMS_ListImport_PVT.create_location (
        location_rec  ,
        x_return_status ,
        x_msg_count     ,
        x_msg_data      ,
        x_location_id   );
     end if;
  	if x_return_status <> 'S' then
        p_component_name := 'ADDRESS';
		return;
  	end if;
end if; -- if location_rec.address1 is not NULL
else
      if l_rec_update_flag = 'Y'  and x_location_id is not NULL then
           select OBJECT_VERSION_NUMBER into l_loc_obj_number
           from hz_locations
           where location_id = x_location_id;
       location_rec.location_id := x_location_id;
       hz_location_v2pub.update_location(
        'F',
        location_rec,
        l_loc_obj_number,
        x_return_status,
        x_msg_count,
        x_msg_data
        );
        if x_return_status <> 'S' then
          return;
        end if;
      end if;
end if; --  x_location_id is null then

-- Party Site creation
   l_lp_psite_id := null;
   open PER_LOCATION_EXISTS;
   fetch PER_LOCATION_EXISTS into l_lp_psite_id;
   close PER_LOCATION_EXISTS;
  if l_lp_psite_id is null and x_per_party_id is not null and x_location_id is not null then
-- Create Party Site
   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
   x_party_site_number := null;

   psite_rec.party_id                 := x_per_party_id;
   psite_rec.location_id              := x_location_id;
   psite_rec.status                   := 'A';
   if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_lp_psite_id is NULL)) then
   AMS_ListImport_PVT.create_party_site(
                psite_rec,
                x_return_status,
                x_msg_count,
                x_msg_data,
                x_party_site_id,
                x_party_site_number
                );
    end if;
      if x_return_status <> 'S' then
        p_component_name := 'ADDRESS';
	return;
      end if;
  else
      if l_rec_update_flag = 'Y'  and l_lp_psite_id is not NULL then
        psite_rec.party_site_id            := l_lp_psite_id;
           select OBJECT_VERSION_NUMBER into l_ps_obj_number
           from hz_party_sites
           where party_site_id = l_lp_psite_id;
        hz_party_site_v2pub.update_party_site(
                'F',
                psite_rec,
                l_ps_obj_number,
                x_return_status,
                x_msg_count,
                x_msg_data
                );
                if x_return_status <> 'S' then
                        return;
                end if;
      end if;
  end if;  --  if l_lp_psite_id is null then

if x_party_site_id is not null and psiteuse_rec.site_use_type is not null then
-- Create Party Site use
   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;

  psiteuse_rec.party_site_id    := x_party_site_id;
  psiteuse_rec.status           := 'A';
  AMS_ListImport_PVT.create_party_site_use(
                psiteuse_rec,
                x_return_status,
                x_msg_count,
                x_msg_data,
                x_party_site_use_id
                );
  if x_return_status <> 'S' then
        p_component_name := 'ADDRESS';
      return;
  end if;
end if;


-- Create contact points  Phone

if x_phone_number is not NULL and x_per_party_id is not null then

   x_return_status     := null;
   x_msg_count      := null;
   x_msg_data       := null;
  cpoint_rec.contact_point_type     := 'PHONE';
  cpoint_rec.status                 := 'A';
  cpoint_rec.owner_table_name       := 'HZ_PARTIES';
  cpoint_rec.owner_table_id         := x_per_party_id;
  phone_rec.phone_line_type         := nvl(x_phone_type,'GEN');
  phone_rec.phone_number            := x_phone_number;
  phone_rec.phone_country_code      := x_phone_country_code;
  phone_rec.phone_area_code         := x_phone_area_code;
  phone_rec.phone_extension         := x_phone_extention;


  l_phone_exists := NULL;
  open phone_exists(x_per_party_id,phone_rec.phone_line_type);
  fetch phone_exists into l_phone_exists;
  close phone_exists;
  if l_phone_exists is not null then
        l_phone_id := NULL;
        open c_phone_id(x_per_party_id,phone_rec.phone_line_type);
        fetch c_phone_id into l_phone_id;
        close c_phone_id;
  end if;
  if l_phone_exists is NULL then
      if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_phone_exists is NULL)) then
       AMS_ListImport_PVT.create_contact_point(
             cpoint_rec,
             edi_rec,
             email_rec,
             phone_rec,
             telex_rec,
             web_rec,
             x_return_status,
             x_msg_count,
             x_msg_data,
             x_contact_point_id);
           l_phone_id := x_contact_point_id;
       end if;
  	if x_return_status <> 'S' then
        p_component_name := 'PHONE';
		return;
  	end if;
 end if; -- l_phone_exists is NULL then
end if; -- x_phone_number

-- Create contact points  Fax

if x_fax_number is not NULL and x_per_party_id is not null then

   x_return_status     := null;
   x_msg_count      := null;
   x_msg_data       := null;
  cpoint_rec.contact_point_type     := 'PHONE';
  cpoint_rec.status                 := 'A';
  cpoint_rec.owner_table_name       := 'HZ_PARTIES';
  cpoint_rec.owner_table_id         := x_per_party_id;
  fax_rec.phone_line_type         := 'FAX';--'GEN';
  fax_rec.phone_number            := x_fax_number;
  fax_rec.phone_country_code      := x_fax_country_code;
  fax_rec.phone_area_code         := x_fax_area_code;


  l_fax_exists := NULL;
  open fax_exists(x_per_party_id);
  fetch fax_exists into l_fax_exists;
  close fax_exists;
  if l_fax_exists is not null then
        l_fax_id := NULL;
        open c_fax_id(x_per_party_id);
        fetch c_fax_id into l_phone_id;
        close c_fax_id;
  end if;
  if l_fax_exists is NULL then
      if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_fax_exists is NULL)) then
       AMS_ListImport_PVT.create_contact_point(
             cpoint_rec,
             edi_rec,
             email_rec,
             fax_rec,
             telex_rec,
             web_rec,
             x_return_status,
             x_msg_count,
             x_msg_data,
             x_contact_point_id);
           l_fax_id := x_contact_point_id;
        end if;
  	if x_return_status <> 'S' then
        p_component_name := 'PHONE';
		return;
  	end if;
 end if; -- l_phone_exists is NULL then
end if; -- x_phone_number

-- B2C URL

if x_url is not NULL  and length(x_url) > 1 and x_per_party_id is not null then

   x_return_status     := null;
   x_msg_count      := null;
   x_msg_data       := null;
  cpoint_rec.contact_point_type     := 'WEB';
  cpoint_rec.status                 := 'A';
  cpoint_rec.owner_table_name       := 'HZ_PARTIES';
  cpoint_rec.owner_table_id         := x_per_party_id;
  web_rec.url := x_url;
  web_rec.web_type     := 'com';

  l_url_exists := NULL;
  open url_exists(x_per_party_id);
  fetch url_exists into l_url_exists;
  close url_exists;
  if l_url_exists is not null then
        l_url_id := NULL;
        open c_url_id(x_per_party_id);
        fetch c_url_id into l_url_id;
        close c_url_id;
  end if;
  if l_url_exists is NULL then
      if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_url_exists is NULL)) then
       AMS_ListImport_PVT.create_contact_point(
             cpoint_rec,
             edi_rec,
             email_rec,
             fax_rec,
             telex_rec,
             web_rec,
             x_return_status,
             x_msg_count,
             x_msg_data,
             x_contact_point_id);
           l_url_id := x_contact_point_id;
        end if;
  	if x_return_status <> 'S' then
        p_component_name := 'WEB';
		return;
  	end if;
 end if; -- l_phone_exists is NULL then
end if; -- x_phone_number

-- Create contact points Email

if x_email_address is not NULL  and x_per_party_id is not null then
--    SELECT  hz_contact_points_s.nextval into x_contact_point_id from dual;

   x_return_status  := null;
   x_msg_count      := null;
   x_msg_data       := null;
 --     cpoint_rec.contact_point_id       := x_contact_point_id;
      cpoint_rec.contact_point_type     := 'EMAIL';
      cpoint_rec.status                 := 'A';
      cpoint_rec.owner_table_name       := 'HZ_PARTIES';
      cpoint_rec.owner_table_id         := x_per_party_id;
      -- cpoint_rec.orig_system_reference  := x_contact_point_id;
      email_rec.email_address           := x_email_address;
  l_email_exists := NULL;
  open email_exists(x_per_party_id);
  fetch email_exists into l_email_exists;
  close email_exists;
  if l_email_exists is NULL then
      if (l_rec_update_flag = 'N' or (l_rec_update_flag = 'Y' and l_email_exists is NULL)) then
            AMS_ListImport_PVT.create_contact_point(
                   cpoint_rec,
                   edi_rec,
                   email_rec,
                   phone_rec,
                   telex_rec,
                   web_rec,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   x_contact_point_id);
       end if;
  	if x_return_status <> 'S' then
        p_component_name := 'EMAIL';
		return;
  	end if;
 end if; -- l_email_exists is NULL then
end if; -- x_email_address
/*
if ((x_phone_number is not NULL OR x_email_address is not NULL ) and l_rec_update_flag = 'Y' and x_per_party_id is not null) then
  phone_rec.phone_line_type         := nvl(x_phone_type,'GEN');
  phone_rec.phone_number            := x_phone_number;
  phone_rec.phone_country_code      := x_phone_country_code;
  phone_rec.phone_area_code         := x_phone_area_code;
  phone_rec.phone_extension         := x_phone_extention;

  l_phone_id := NULL;
  open c_phone_id(x_per_party_id,phone_rec.phone_line_type);
  fetch c_phone_id into l_phone_id;
  close c_phone_id;
  if l_phone_id is not null then
     x_contact_point_id := l_phone_id;
  end if;

  email_rec.email_address := x_email_address;
 l_email_id := NULL;
 open c_email_id(x_per_party_id);
 fetch c_email_id into l_email_id;
 close c_email_id;
  if l_email_id is not null then
     x_contact_point_id := l_email_id;
  end if;
  cpoint_rec.contact_point_id       := x_contact_point_id;
           select OBJECT_VERSION_NUMBER into l_cp_obj_number
           from hz_contact_points
           where contact_point_id = x_contact_point_id;
  hz_contact_point_v2pub.update_contact_point(
                   'F',
                   cpoint_rec,
                   edi_rec,
                   email_rec,
                   phone_rec,
                   telex_rec,
                   web_rec,
                   l_cp_obj_number,
                   x_return_status,
                   x_msg_count,
                   x_msg_data);
        if x_return_status <> 'S' then
            return;
        end if;
end if;
*/
end if; -- if x_rented_list_flag <> 'R'

-- Updates the marketing tables with the party_id

   if l_is_party_mapped is NULL then
       l_enabled_flag := 'Y';
    end if;

    if l_is_party_mapped = 'Y' and l_b2c_party_exists = 'Y' then
       l_overlay := 'Y';
       l_enabled_flag := 'Y';
    end if;

   if l_is_party_mapped = 'Y' and l_b2c_party_exists is NULL then
       l_enabled_flag := 'N';
    end if;

   if x_per_party_id is not null  then
      p_party_id := x_per_party_id;
   end if;


   if x_per_party_id is not null  and p_import_list_header_id is not null then
   UPDATE ams_imp_source_lines
          SET party_id = x_per_party_id,
              load_status  = 'SUCCESS',
              contact_point_id = l_phone_id,
              location_id  = x_location_id,
              enabled_flag = l_enabled_flag
--  sranka 1/14/2003
--   WHERE  import_source_line_id = person_rec.party_rec.orig_system_reference // original
   WHERE  import_source_line_id = l_import_source_line_id
     AND  import_list_header_id = p_import_list_header_id;
     x_return_status := 'S';
     open b2cxml;
      fetch b2cxml into l_xml_element_id;
      close b2cxml;
      if l_xml_element_id is not null then
        process_element_success( p_import_list_header_id, l_xml_element_id) ;
      end if;
   end if;
   if x_per_party_id is not null  and p_import_list_header_id is not null then
   create_party_source (p_import_list_header_id, i_import_source_line_id,l_overlay);
   end if;


end if; -- x_b2b = 'N'

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_Customer_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      -- ROLLBACK TO Create_Customer_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      -- ROLLBACK TO Create_Customer_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

end Create_Customer;
-- ***************************************************************
--
--
PROCEDURE party_echeck(
   p_party_id           IN OUT NOCOPY   NUMBER,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2,
   p_org_name           IN       VARCHAR2,
   p_per_first_name     IN       VARCHAR2,
   p_per_last_name      IN       VARCHAR2,
   p_address1           IN       VARCHAR2,
   p_country            IN       VARCHAR2,
 -- sranka 1/13/2003 added p_orig_system_reference
   p_orig_system_reference IN       VARCHAR2
                      ) IS



l_party_key     varchar2(1000);
L_COUNT         number;
l_max_party_id  number;
l_party_tbl     hz_fuzzy_pub.PARTY_TBL_TYPE;
x_org_party_id  number;
l_ps_party_id   number;
l_cust_exists   varchar2(1);
l_ret_status      varchar(1);
x_per_party_id  number;
x_party_id  number;

cursor c_address_country is
        select max(psite.party_id) from hz_party_sites psite, hz_locations loc,
        hz_parties party
         where  psite.location_id = loc.location_id
          and  loc.address1      = p_address1
          and  loc.country       = p_country
          and  party.customer_key = l_party_key
	  and  party.party_type   = 'ORGANIZATION'
          and  party.status = 'A'
          and  psite.party_id      = party.party_id;

-- sranka 1/13/2003 created new cursor c_address_country_with_osr for including the orig_system_reference for duplication check

cursor c_address_country_with_osr is
        select max(psite.party_id) from hz_party_sites psite, hz_locations loc,
        hz_parties party
         where  psite.location_id = loc.location_id
          and  loc.address1      = p_address1
          and  loc.country       = p_country
          and  party.customer_key = l_party_key
	  and  party.party_type   = 'ORGANIZATION'
          and  party.status = 'A'
          and  psite.party_id      = party.party_id
          and party.orig_system_reference = p_orig_system_reference;

cursor c_country is
        select max(psite.party_id) from hz_party_sites psite, hz_locations loc,
        hz_parties party
         where  psite.location_id = loc.location_id
          and  loc.country       = p_country
          and  party.customer_key = l_party_key
	  and  party.party_type   = 'ORGANIZATION'
          and  party.status = 'A'
          and  psite.party_id      = party.party_id;

-- sranka 1/13/2003
-- created new cursor  c_country_with_osr for including the orig_system_reference for duplication check

cursor c_country_with_osr is
        select max(psite.party_id) from hz_party_sites psite, hz_locations loc,
        hz_parties party
         where  psite.location_id = loc.location_id
          and  loc.country       = p_country
          and  party.customer_key = l_party_key
	  and  party.party_type   = 'ORGANIZATION'
          and  party.status = 'A'
          and  psite.party_id      = party.party_id
          and party.orig_system_reference = p_orig_system_reference;


cursor c_customer_exists is
       select 'Y' from hz_parties
       where customer_key = l_party_key
          and status = 'A'
         and party_type   = 'ORGANIZATION';

-- sranka 1/13/2003
-- created new cursor  c_customer_exists_with_osr for including the orig_system_reference for duplication check
cursor c_customer_exists_with_osr is
       select 'Y' from hz_parties
       where customer_key = l_party_key
         and party_type   = 'ORGANIZATION'
          and  status = 'A'
         AND orig_system_reference = p_orig_system_reference;


cursor c_max_party is
       select max(party_id) from hz_parties
       where customer_key = l_party_key
          and  status = 'A'
         and party_type   = 'ORGANIZATION';

-- sranka 1/13/2003
-- created new cursor  c_max_party_with_osr for including the orig_system_reference for duplication check
cursor c_max_party_with_osr is
       select max(party_id) from hz_parties
       where customer_key = l_party_key
          and  status = 'A'
       and party_type   = 'ORGANIZATION'
       and orig_system_reference = p_orig_system_reference;


begin

--
-- Generates the customer key for ORGANIZATION
--
 x_return_status := FND_API.g_ret_sts_success;
 if p_org_name is not null then
    l_party_key := hz_fuzzy_pub.Generate_Key (
                                p_key_type => 'ORGANIZATION',
                                p_party_name => p_org_name
                               );
    -- sranka 1/13/2003
    -- Added the condition on based on the value of p_orig_system_reference,
    -- if  p_orig_system_reference is NULL then the duplication will not be done based on the "p_orig_system_reference"
    -- but if p_orig_system_reference is NOT NULL than "orig_system_reference" will be included for the duplication check.

    IF p_orig_system_reference IS NULL then
        open c_customer_exists;
        fetch c_customer_exists into l_cust_exists;
        close c_customer_exists;
    else
        open c_customer_exists_with_osr;
        fetch c_customer_exists_with_osr into l_cust_exists;
        close c_customer_exists_with_osr;
            IF l_cust_exists IS NULL then
                open c_customer_exists;
                fetch c_customer_exists into l_cust_exists;
                close c_customer_exists;
            END if;
    END if;
 end if;
--
-- If customer does not exists then it's a new customer.
--
 if l_cust_exists is NULL then
    return;
 end if;

--
-- When address1 and country is provided
--

    -- sranka 1/13/2003
    -- Added the condition on based on the value of p_orig_system_reference,
    -- if  p_orig_system_reference is NULL then the duplication will not be done based on the "p_orig_system_reference"
    -- but if p_orig_system_reference is NOT NULL than "orig_system_reference" will be included for the duplication check.

if  l_cust_exists = 'Y' and p_address1 is not null and p_country is not null then

    IF p_orig_system_reference IS NULL then
        open c_address_country;
        fetch c_address_country into l_ps_party_id;
        close c_address_country;
    else

-- sranka 1/14/2003
-- here we will check the existance with the "p_orig_system_reference", if the val returned is NULL
-- than we will do the existanve checking with out the "p_orig_system_reference""

        open c_address_country_with_osr;
        fetch c_address_country_with_osr into l_ps_party_id;
        close c_address_country_with_osr;

        IF l_ps_party_id IS NULL then
            open c_address_country;
            fetch c_address_country into l_ps_party_id;
            close c_address_country;
        END IF;
    END IF;

    -- if party site not found for this address and country then serch for only country


    if l_ps_party_id is NULL then

    -- sranka 1/13/2003,
    -- added this check condition for the country duplication check.
    -- if  p_orig_system_reference is NULL then the duplication will not be done based on the "p_orig_system_reference"
    -- but if p_orig_system_reference is NOT NULL than "orig_system_reference" will be included for the duplication check.

      IF p_orig_system_reference IS NULL then
           open c_country;
           fetch c_country into l_ps_party_id;
           close c_country;
      else

        open c_country_with_osr;
        fetch c_country_with_osr into l_ps_party_id;
        close c_country_with_osr;

        IF l_ps_party_id IS NULL then
            open c_address_country;
            fetch c_address_country into l_ps_party_id;
            close c_address_country;
        END IF;

      END IF;
    end if;
    if l_ps_party_id is not NULL then
       p_party_id := l_ps_party_id;
       return;
    end if;
  end if;

--
-- When customer exists and address1 and country is not provided
-- OR party site does not exists
-- then take the max party_id from the available records.
--
if  l_cust_exists = 'Y' and
    (
    (p_address1 is null and p_country is  null)
    or (l_ps_party_id is null)
    ) then
--
-- For ORGANIZATION get the max party_id
--
 if p_org_name is not null then

    -- sranka 1/13/2003,
    -- if  p_orig_system_reference is NULL then the max party will not be done based on the "p_orig_system_reference"
    -- but if p_orig_system_reference is NOT NULL than "orig_system_reference" will be included for the max party check.

      IF p_orig_system_reference IS NULL then
        open c_max_party;
        fetch c_max_party into x_party_id;
        close c_max_party;
      else
        open c_max_party_with_osr;
        fetch c_max_party_with_osr into x_party_id;
        close c_max_party_with_osr;

        IF x_party_id IS NULL THEN
            open c_max_party;
            fetch c_max_party into x_party_id;
            close c_max_party;
        END IF;

      END if;

     p_party_id := x_party_id;
 end if;
end if;

--
-- For PERSON get the max party_id
--
 if p_per_last_name is not null and p_per_first_name is not null then
       L_COUNT        := 0;
       l_max_party_id := 0;
       hz_fuzzy_pub.FUZZY_SEARCH_PARTY(
       'PERSON',
       null,
       p_per_first_name,
       p_per_last_name,
       l_party_tbl,
       L_COUNT);
       if L_COUNT > 0 then
          for i in 1..l_count loop
             if l_party_tbl(i) > l_max_party_id then
                l_max_party_id := l_party_tbl(i);
             end if;
          end loop;
          x_per_party_id := l_max_party_id;
          p_party_id     := x_per_party_id;
       end if;
 end if;

 exception
    when others then
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name,'party_echeck');
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
end party_echeck;

-- ---------------------------------------------
--
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
  p_component_name           IN     VARCHAR2,
  p_field_name               IN     VARCHAR2,
  p_error_text               IN     VARCHAR2
  ) IS

l_error_exist   varchar2(1);
l_imp_type      varchar2(60);
l_file_type     varchar2(60);
l_batch_id      NUMBER;
l_return_status                 VARCHAR2(1);
l_imp_xml_element_id NUMBER;
l_org_imp_xml_element_id NUMBER;
l_per_imp_xml_element_id NUMBER;
l_add_imp_xml_element_id NUMBER;
l_ocont_imp_xml_element_id NUMBER;
l_cp_imp_xml_element_id NUMBER;
l_em_imp_xml_element_id NUMBER;
L_ERROR_THRESHOLD	number;
l_lookup_code		varchar2(60);
l_user_status_id	number;


cursor c_imp_type is
select import_type, batch_id, nvl(ERROR_THRESHOLD,0)
from ams_imp_list_headers_all
where import_list_header_id = p_import_list_header_id;

cursor c_error_exists is
select 'Y'
from ams_list_import_errors
where import_list_header_id = p_import_list_header_id
  and import_source_line_id = p_import_source_line_id
  and batch_id              = l_batch_id;

cursor c_file_type is
 select file_type from ams_imp_documents where import_list_header_id = p_import_list_header_id;

cursor c_b2b is
select  org_imp_xml_element_id, add_imp_xml_element_id, ocont_imp_xml_element_id, cp_imp_xml_element_id,
em_imp_xml_element_id from ams_hz_b2b_mapping_v where import_list_header_id = p_import_list_header_id
and import_source_line_id = p_import_source_line_id;


cursor c_b2c is
select  per_imp_xml_element_id, add_imp_xml_element_id, cp_imp_xml_element_id, em_imp_xml_element_id
from ams_hz_b2c_mapping_v where import_list_header_id = p_import_list_header_id
and import_source_line_id = p_import_source_line_id;


begin

  SAVEPOINT error_capture_pub;
   -- initialize the message list;
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
if nvl(p_component_name,'X') <> 'EVENTSUB' then
 open c_imp_type;
 fetch c_imp_type into l_imp_type, l_batch_id, L_ERROR_THRESHOLD;
 close c_imp_type;
 if p_import_source_line_id is not null then
        update ams_imp_source_lines
        set load_status = 'ERROR' , ENABLED_FLAG = null
        where import_list_header_id = p_import_list_header_id
        and import_source_line_id   = p_import_source_line_id;

 open c_error_exists;
 fetch c_error_exists into l_error_exist;
 close c_error_exists;

 open c_file_type;
 fetch c_file_type into l_file_type;
 close c_file_type;

 if l_error_exist = 'Y' then
        update ams_list_import_errors
        set col1 =  substr(col1||','||p_error_text,1,4000)
        where import_list_header_id = p_import_list_header_id
        and import_source_line_id   = p_import_source_line_id
        and batch_id                = l_batch_id;
 end if;

 if l_error_exist is null then
       INSERT INTO ams_list_import_errors
       (
        LIST_IMPORT_ERROR_ID,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        IMPORT_SOURCE_LINE_ID,
        IMPORT_LIST_HEADER_ID,
        IMPORT_TYPE,
        ERROR_TYPE,
        BATCH_ID,
        col1
        )
       VALUES
       (
        ams_list_import_errors_s.nextval,      -- LIST_IMPORT_ERROR_ID,
        FND_GLOBAL.User_ID,                   -- LAST_UPDATED_BY,
        SYSDATE,                              -- LAST_UPDATE_DATE,
        SYSDATE,                              -- CREATION_DATE,
        FND_GLOBAL.User_ID,                   -- CREATED_BY,
        FND_GLOBAL.Conc_Login_ID,             -- LAST_UPDATE_LOGIN,
        p_import_source_line_id,
        p_import_list_header_id,
        l_imp_type,                                -- IMPORT_TYPE,
        'E',                                  -- ERROR_TYPE,
        l_batch_id,
        substr(p_error_text,1,4000)
        );
 end if;
 end if; -- p_import_source_line_id is not null then

 if l_file_type = 'XML' then
    if p_component_name in ('ORGANIZATION','PERSON','ADDRESS','CONTACT','PHONE','EMAIL') THEN
      if l_imp_type = 'B2B' then
         open c_b2b;
	 fetch c_b2b into l_org_imp_xml_element_id , l_add_imp_xml_element_id , l_ocont_imp_xml_element_id ,
	  l_cp_imp_xml_element_id , l_em_imp_xml_element_id;
         close c_b2b;
        if p_component_name = 'ORGANIZATION' then
         l_imp_xml_element_id := l_org_imp_xml_element_id;
        end if;
        if p_component_name = 'CONTACT' then
         l_imp_xml_element_id := l_ocont_imp_xml_element_id;
        end if;
        if p_component_name = 'ADDRESS' then
         l_imp_xml_element_id := l_add_imp_xml_element_id;
        end if;
        if p_component_name = 'PERSON' then
         l_imp_xml_element_id := l_ocont_imp_xml_element_id;
        end if;
        if p_component_name = 'PHONE' then
         l_imp_xml_element_id := l_cp_imp_xml_element_id;
        end if;
        if p_component_name = 'EMAIL' then
         l_imp_xml_element_id := l_em_imp_xml_element_id;
        end if;
      end if;

      if l_imp_type = 'B2C' then
         open c_b2c;
	 fetch c_b2c into l_per_imp_xml_element_id , l_add_imp_xml_element_id ,
	  l_cp_imp_xml_element_id , l_em_imp_xml_element_id;
         close c_b2c;
        if p_component_name = 'ADDRESS' then
         l_imp_xml_element_id := l_add_imp_xml_element_id;
        end if;
        if p_component_name = 'PERSON' then
         l_imp_xml_element_id := l_per_imp_xml_element_id;
        end if;
        if p_component_name = 'PHONE' then
         l_imp_xml_element_id := l_cp_imp_xml_element_id;
        end if;
        if p_component_name = 'EMAIL' then
         l_imp_xml_element_id := l_em_imp_xml_element_id;
        end if;
      end if;

   end if;
       if p_field_name is null then
                        update AMS_IMP_XML_ELEMENTS
                           set ERROR_TEXT = substr(p_error_text,1,2000),
                               LOAD_STATUS = 'ERROR'
                        where  imp_xml_element_id = l_imp_xml_element_id;
          else
              AMS_ListImport_PVT.update_element_error (
			p_import_list_header_id,l_imp_xml_element_id,
                               p_field_name,upper(p_field_name)||' :'||substr(p_error_text,1,2000));
       end if;
 end if;  -- l_file_type = 'XML'

 if L_ERROR_THRESHOLD > 0 then
   G_ERROR_THRESHOLD := G_ERROR_THRESHOLD + 1;
   if G_ERROR_THRESHOLD >= L_ERROR_THRESHOLD then
   -- ndadwal added if cond for bug 4966524
   if p_import_list_header_id is NOT NULL then
                AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_return_status,
                  p_arc_log_used_by => G_ARC_IMPORT_HEADER,
                  p_log_used_by_id  => p_import_list_header_id,
                  p_msg_data        => 'Import process is stoped because of Error Threshold has been reached .',
                  p_msg_type        => 'DEBUG'
                );
    end if;
                l_lookup_code := 'ERROR';
                l_user_status_id := null;
                SELECT user_status_id into l_user_status_id FROM ams_user_statuses_vl
                WHERE system_status_type = 'AMS_IMPORT_STATUS' AND
                system_status_code = 'ERROR'  and default_flag = 'Y';

                UPDATE ams_imp_list_headers_all
                set status_code       =  l_lookup_code,
                user_status_id    =  l_user_status_id,
                status_date       =  sysdate
                where import_list_header_id = p_import_list_header_id;
                x_return_status  := 'E';
                x_msg_count      := 1;
                x_msg_data       := 'Threshold';
                return;

   end if;
 end if;

end if; -- --if p_component_name <> 'EVENTSUB' then

if p_component_name = 'EVENTSUB' then
 if p_import_source_line_id is not null then
        update ams_imp_source_lines
        set load_status = 'ERROR' , ENABLED_FLAG = null
        where import_list_header_id = p_import_list_header_id
        and import_source_line_id   = p_import_source_line_id;
 end if;
 l_error_exist := NULL;
 open c_error_exists;
 fetch c_error_exists into l_error_exist;
 close c_error_exists;
 if l_error_exist = 'Y' then
        update ams_list_import_errors
        set col350 =  substr(col350||','||p_error_text,1,4000)
        where import_list_header_id = p_import_list_header_id
        and import_source_line_id   = p_import_source_line_id;
 end if;
 if l_error_exist is null then
       INSERT INTO ams_list_import_errors
       (
        LIST_IMPORT_ERROR_ID,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        IMPORT_SOURCE_LINE_ID,
        IMPORT_LIST_HEADER_ID,
        IMPORT_TYPE,
        ERROR_TYPE,
        BATCH_ID,
        col1
        )
       VALUES
       (
        ams_list_import_errors_s.nextval,      -- LIST_IMPORT_ERROR_ID,
        FND_GLOBAL.User_ID,                   -- LAST_UPDATED_BY,
        SYSDATE,                              -- LAST_UPDATE_DATE,
        SYSDATE,                              -- CREATION_DATE,
        FND_GLOBAL.User_ID,                   -- CREATED_BY,
        FND_GLOBAL.Conc_Login_ID,             -- LAST_UPDATE_LOGIN,
        p_import_source_line_id,
        p_import_list_header_id,
        l_imp_type,                                -- IMPORT_TYPE,
        'E',                                  -- ERROR_TYPE,
        l_batch_id,
        substr(p_error_text,1,4000)
        );
 end if;

end if;


   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO error_capture_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO error_capture_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
 --     ROLLBACK TO error_capture_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, 'error_capture');
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

end error_capture;
-- ---------------------------------

PROCEDURE contact_echeck(
   p_party_id              IN OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2,
   p_org_party_id          IN       NUMBER,
   p_per_first_name        IN       VARCHAR2,
   p_per_last_name         IN       VARCHAR2,
   p_phone_area_code       IN       VARCHAR2,
   p_phone_number          IN       VARCHAR2,
   p_phone_extension       IN       VARCHAR2,
   p_email_address         IN       VARCHAR2,
-- sranka 1/14/2003
-- added "p_orig_system_reference"  for supporting the population of "orig_system_reference"
-- from CSV file
   p_orig_system_reference IN       VARCHAR2,
-- sranka 3/21/2003
-- made changes for supporting EMPLOYEE_OF" relationship
   p_relationship_code     IN       VARCHAR2,
   p_relationship_type     IN       VARCHAR2

                       ) IS

l_ret_status      varchar(1);
x_per_party_id    number;
l_party_key       varchar(1000);
l_cust_exists     varchar(1);
l_email_party_id  number;
l_phone_party_id  number;
L_COUNT         number;
l_max_party_id  number;
l_party_tbl     hz_fuzzy_pub.PARTY_TBL_TYPE;
l_transposed_phone_no varchar(60);

cursor c_customer_exists is
       select 'Y' from hz_parties
       where customer_key = l_party_key
          and status = 'A'
         and party_type   = 'PERSON';

-- sranka 1/15/2003
-- created new cursor c_address_country_with_osr for including the orig_system_reference for duplication check

cursor c_customer_exists_with_osr is
       select 'Y' from hz_parties
       where customer_key = l_party_key
       and party_type   = 'PERSON'
          and status = 'A'
       and orig_system_reference = p_orig_system_reference;


cursor c_cont_email is
       select max(per.party_id) from
       hz_parties org,
       hz_parties per,
       hz_relationships rel,
       hz_contact_points cpoint
       where org.party_id           = p_org_party_id
         and org.party_type         = 'ORGANIZATION'
         and rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
         and rel.SUBJECT_TYPE       = 'PERSON'
         and rel.OBJECT_TABLE_NAME  = 'HZ_PARTIES'
--  sranka 3/21/2003
-- made changes for supporting EMPLOYEE_OF" relationship
--         and rel.RELATIONSHIP_CODE  = 'CONTACT_OF'
--         and rel.RELATIONSHIP_CODE  = NVL(ocon_rec.party_rel_rec.relationship_code,'CONTACT_OF')
--         and rel.RELATIONSHIP_TYPE  = NVL(ocon_rec.party_rel_rec.relationship_type,'CONTACT')
         and rel.RELATIONSHIP_CODE  = NVL(p_relationship_code,'CONTACT_OF')
         and rel.RELATIONSHIP_TYPE  = NVL(p_relationship_type,'CONTACT')
         and rel.OBJECT_ID          = org.party_id
         and rel.SUBJECT_ID         = per.PARTY_ID
         and per.customer_key       = l_party_key
          and per.status = 'A'
         and cpoint.owner_table_id  = rel.party_id
         and cpoint.owner_table_name = 'HZ_PARTIES'
         and cpoint.contact_point_type = 'EMAIL'
         and upper(cpoint.email_address)    = upper(p_email_address)
         and cpoint.status           = 'A';

-- sranka 1/15/2003 created new cursor c_cont_email_with_osr for including the orig_system_reference for duplication check

cursor c_cont_email_with_osr is
       select max(per.party_id) from
       hz_parties org,
       hz_parties per,
       hz_relationships rel,
       hz_contact_points cpoint
       where org.party_id           = p_org_party_id
         and org.party_type         = 'ORGANIZATION'
         and org.orig_system_reference = p_orig_system_reference
         and rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
         and rel.SUBJECT_TYPE       = 'PERSON'
         and rel.OBJECT_TABLE_NAME  = 'HZ_PARTIES'
--  sranka 3/21/2003
-- made changes for supporting EMPLOYEE_OF" relationship
--         and rel.RELATIONSHIP_CODE  = 'CONTACT_OF'
         and rel.RELATIONSHIP_CODE  = NVL(p_relationship_code,'CONTACT_OF')
         and rel.RELATIONSHIP_TYPE  = NVL(p_relationship_type,'CONTACT')
         and rel.OBJECT_ID          = org.party_id
         and rel.SUBJECT_ID         = per.PARTY_ID
         and per.customer_key       = l_party_key
          and per.status = 'A'
         and cpoint.owner_table_id  = rel.party_id
         and cpoint.owner_table_name = 'HZ_PARTIES'
         and cpoint.contact_point_type = 'EMAIL'
         and upper(cpoint.email_address)    = upper(p_email_address)
         and cpoint.status           = 'A';


cursor c_cont_email_phone is
       select max(per.party_id) from
       hz_parties org,
       hz_parties per,
       hz_relationships rel,
       hz_contact_points cpoint,
       hz_contact_points cpoint1
       where org.party_id           = p_org_party_id
         and org.party_type         = 'ORGANIZATION'
         and rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
         and rel.SUBJECT_TYPE       = 'PERSON'
         and rel.OBJECT_TABLE_NAME  = 'HZ_PARTIES'
--  sranka 3/21/2003
-- made changes for supporting EMPLOYEE_OF" relationship
--         and rel.RELATIONSHIP_CODE  = 'CONTACT_OF'
         and rel.RELATIONSHIP_CODE  = NVL(p_relationship_code,'CONTACT_OF')
         and rel.RELATIONSHIP_TYPE  = NVL(p_relationship_type,'CONTACT')
         and rel.OBJECT_ID          = org.party_id
         and rel.SUBJECT_ID         = per.PARTY_ID
         and per.customer_key       = l_party_key
          and per.status = 'A'
         and cpoint.owner_table_id  = rel.party_id
         and cpoint.owner_table_name = 'HZ_PARTIES'
         and cpoint.contact_point_type = 'EMAIL'
         and upper(cpoint.email_address)    = upper(p_email_address)
         and cpoint.status           = 'A'
         and cpoint1.owner_table_id  = rel.party_id
         and cpoint1.owner_table_name = 'HZ_PARTIES'
         and cpoint1.contact_point_type = 'PHONE'
         and cpoint1.transposed_phone_number = l_transposed_phone_no
         -- and cpoint1.phone_area_code||'-'||cpoint1.phone_number||'-'||cpoint1.phone_extension  =
         --    p_phone_area_code||'-'||p_phone_number||'-'||p_phone_extension
         and (cpoint1.phone_line_type<>'FAX' or cpoint1.phone_line_type is null)
         and cpoint1.status           = 'A';

-- sranka 1/15/2003 created new cursor c_cont_email_phone_with_osr for including the orig_system_reference for duplication check

cursor c_cont_email_phone_with_osr is
       select max(per.party_id) from
       hz_parties org,
       hz_parties per,
       hz_relationships rel,
       hz_contact_points cpoint,
       hz_contact_points cpoint1
       where org.party_id           = p_org_party_id
         and org.party_type         = 'ORGANIZATION'
         and org.orig_system_reference = p_orig_system_reference
         and rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
         and rel.SUBJECT_TYPE       = 'PERSON'
         and rel.OBJECT_TABLE_NAME  = 'HZ_PARTIES'
--  sranka 3/21/2003
-- made changes for supporting EMPLOYEE_OF" relationship
--         and rel.RELATIONSHIP_CODE  = 'CONTACT_OF'
         and rel.RELATIONSHIP_CODE  = NVL(p_relationship_code,'CONTACT_OF')
         and rel.RELATIONSHIP_TYPE  = NVL(p_relationship_type,'CONTACT')
         and rel.OBJECT_ID          = org.party_id
         and rel.SUBJECT_ID         = per.PARTY_ID
         and per.customer_key       = l_party_key
          and per.status = 'A'
         and cpoint.owner_table_id  = rel.party_id
         and cpoint.owner_table_name = 'HZ_PARTIES'
         and cpoint.contact_point_type = 'EMAIL'
         and upper(cpoint.email_address)    = upper(p_email_address)
         and cpoint.status           = 'A'
         and cpoint1.owner_table_id  = rel.party_id
         and cpoint1.owner_table_name = 'HZ_PARTIES'
         and cpoint1.contact_point_type = 'PHONE'
         and cpoint1.transposed_phone_number = l_transposed_phone_no
         -- and cpoint1.phone_area_code||'-'||cpoint1.phone_number||'-'||cpoint1.phone_extension  =
         --    p_phone_area_code||'-'||p_phone_number||'-'||p_phone_extension
         and (cpoint1.phone_line_type<>'FAX' or cpoint1.phone_line_type is null)
         and cpoint1.status           = 'A';


cursor c_cont_phone is
       select max(per.party_id) from
       hz_parties org,
       hz_parties per,
       hz_relationships rel,
       hz_contact_points cpoint
       where org.party_id           = p_org_party_id
         and org.party_type         = 'ORGANIZATION'
         and rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
         and rel.SUBJECT_TYPE       = 'PERSON'
         and rel.OBJECT_TABLE_NAME  = 'HZ_PARTIES'
--  sranka 3/21/2003
-- made changes for supporting EMPLOYEE_OF" relationship
--         and rel.RELATIONSHIP_CODE  = 'CONTACT_OF'
         and rel.RELATIONSHIP_CODE  = NVL(p_relationship_code,'CONTACT_OF')
         and rel.RELATIONSHIP_TYPE  = NVL(p_relationship_type,'CONTACT')
         and rel.OBJECT_ID          = org.party_id
         and rel.SUBJECT_ID         = per.PARTY_ID
         and per.customer_key       = l_party_key
          and per.status = 'A'
         and cpoint.owner_table_id  = rel.party_id
         and cpoint.owner_table_name = 'HZ_PARTIES'
         and cpoint.contact_point_type = 'PHONE'
         and cpoint.transposed_phone_number = l_transposed_phone_no
         -- and cpoint.phone_area_code||'-'||cpoint.phone_number||'-'||cpoint.phone_extension  =
          --   p_phone_area_code||'-'||p_phone_number||'-'||p_phone_extension
         and (cpoint.phone_line_type<>'FAX' or cpoint.phone_line_type is null)
         and cpoint.status           = 'A';

-- sranka 1/15/2003 created new cursor c_cont_phone_with_osr for including the orig_system_reference for duplication check


cursor c_cont_phone_with_osr is
       select max(per.party_id) from
       hz_parties org,
       hz_parties per,
       hz_relationships rel,
       hz_contact_points cpoint
       where org.party_id           = p_org_party_id
         and org.party_type         = 'ORGANIZATION'
         and org.orig_system_reference = p_orig_system_reference
         and rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
         and rel.SUBJECT_TYPE       = 'PERSON'
         and rel.OBJECT_TABLE_NAME  = 'HZ_PARTIES'
--  sranka 3/21/2003
-- made changes for supporting EMPLOYEE_OF" relationship
--         and rel.RELATIONSHIP_CODE  = 'CONTACT_OF'
         and rel.RELATIONSHIP_CODE  = NVL(p_relationship_code,'CONTACT_OF')
         and rel.RELATIONSHIP_TYPE  = NVL(p_relationship_type,'CONTACT')
         and rel.OBJECT_ID          = org.party_id
         and rel.SUBJECT_ID         = per.PARTY_ID
         and per.customer_key       = l_party_key
          and per.status = 'A'
         and cpoint.owner_table_id  = rel.party_id
         and cpoint.owner_table_name = 'HZ_PARTIES'
         and cpoint.contact_point_type = 'PHONE'
         and cpoint.transposed_phone_number = l_transposed_phone_no
         -- and cpoint.phone_area_code||'-'||cpoint.phone_number||'-'||cpoint.phone_extension  =
           --  p_phone_area_code||'-'||p_phone_number||'-'||p_phone_extension
         and (cpoint.phone_line_type<>'FAX' or cpoint.phone_line_type is null)
         and cpoint.status           = 'A';


begin
x_return_status := FND_API.g_ret_sts_success;
--
-- Generates the customer key for PERSON
--
 if p_per_last_name is not null and p_per_first_name is not null then
   l_party_key := hz_fuzzy_pub.Generate_Key (
                                p_key_type => 'PERSON',
                                p_first_name => p_per_first_name,
                                p_last_name  => p_per_last_name
                               );
l_transposed_phone_no := hz_phone_number_pkg.transpose(p_phone_area_code||p_phone_number);

 end if;
--
-- If customer does not exists then it's a new customer.
--

    -- sranka 1/15/2003,
    -- if  p_orig_system_reference is NULL then the duplication check will not be done based on the "p_orig_system_reference"
    -- but if p_orig_system_reference is NOT NULL than "orig_system_reference" will be included for the max party check.

      IF p_orig_system_reference IS NULL then
         open c_customer_exists;
         fetch c_customer_exists into l_cust_exists;
         close c_customer_exists;
      else
         open c_customer_exists_with_osr;
         fetch c_customer_exists_with_osr into l_cust_exists;
         close c_customer_exists_with_osr;

         IF l_cust_exists IS NULL then
             open c_customer_exists;
             fetch c_customer_exists into l_cust_exists;
             close c_customer_exists;
         END if;

      END if;




 if l_cust_exists is NULL then
    return;     -- ORG CONTACT DOES NOT EXISTS CHECKED WITH CUSTOMER_KEY.
 end if;



    -- sranka 1/15/2003,
    -- if  p_orig_system_reference is NULL then the  the duplication check will not be done based on the "p_orig_system_reference"
    -- but if p_orig_system_reference is NOT NULL than "orig_system_reference" will be included for the max party check.

      IF p_orig_system_reference IS NULL then
         open c_cont_email_phone;
         fetch c_cont_email_phone into x_per_party_id;
         close c_cont_email_phone;
      else
         IF x_per_party_id IS NULL then
             open c_cont_email_phone_with_osr;
             fetch c_cont_email_phone_with_osr into x_per_party_id;
             close c_cont_email_phone_with_osr;
         END if;
      END if;



 if x_per_party_id is not null then
    p_party_id     := x_per_party_id;   -- ORG CONTACT DOES NOT EXISTS WITH EMAIL AND PHONE NUMBER.
    return;
  end if;
--
-- Either email_address and phone number is available.
--
if l_cust_exists = 'Y' and (p_email_address is not null or p_phone_number is not null) then
    -- sranka 1/15/2003,
    -- if  p_orig_system_reference is NULL then the  the duplication check will not be done based on the "p_orig_system_reference"
    -- but if p_orig_system_reference is NOT NULL than "orig_system_reference" will be included for the max party check.
       IF p_orig_system_reference IS NULL then
           open c_cont_email;
           fetch c_cont_email into l_email_party_id;
           close c_cont_email;
       else
           open c_cont_email_with_osr;
           fetch c_cont_email_with_osr into l_email_party_id;
           close c_cont_email_with_osr;
           IF l_email_party_id IS NULL then
               open c_cont_email;
               fetch c_cont_email into l_email_party_id;
               close c_cont_email;
           END if;
       END if;


           if l_email_party_id is not null then
              p_party_id     :=  l_email_party_id;
              return;
           end if;

    -- sranka 1/15/2003,
    -- if  p_orig_system_reference is NULL then the  the duplication check will not be done based on the "p_orig_system_reference"
    -- but if p_orig_system_reference is NOT NULL than "orig_system_reference" will be included for the max party check.

       IF p_orig_system_reference IS NULL then
           open c_cont_phone;
           fetch c_cont_phone into l_phone_party_id;
           close c_cont_phone;
       else
           open c_cont_phone_with_osr;
           fetch c_cont_phone_with_osr into l_phone_party_id;
           close c_cont_phone_with_osr;

           IF l_phone_party_id IS NULL then
               open c_cont_phone;
               fetch c_cont_phone into l_phone_party_id;
               close c_cont_phone;
           END if;

       END if;

           if l_phone_party_id is not null then
              p_party_id := l_phone_party_id;
           end if;
end if;


 exception
   when others then
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name,'contact_echeck');
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

end contact_echeck;
-- ----------------------------------------------
PROCEDURE rented_contact_echeck(
   p_party_id              IN OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2,
   p_org_party_id          IN       NUMBER,
   p_per_first_name        IN       VARCHAR2,
   p_per_last_name         IN       VARCHAR2,
   p_phone_area_code       IN       VARCHAR2,
   p_phone_number          IN       VARCHAR2,
   p_phone_extension       IN       VARCHAR2,
   p_email_address         IN       VARCHAR2,
-- sranka 3/21/2003
-- made changes for supporting EMPLOYEE_OF" relationship
   p_relationship_code     IN       VARCHAR2,
   p_relationship_type     IN       VARCHAR2

                       ) IS

l_ret_status      varchar(1);
x_per_party_id    number;
l_party_key       varchar(1000);
l_cust_exists     varchar(1);
l_email_party_id  number;
l_phone_party_id  number;
L_COUNT         number;
l_max_party_id  number;
l_rel_party_id  number;
l_per_party_id  number;
l_party_tbl     hz_fuzzy_pub.PARTY_TBL_TYPE;


cursor c_customer_exists is
       select MAX(PARTY_ID) from hz_parties
       where customer_key = l_party_key
          and status = 'A'
         and party_type   = 'PERSON';

cursor c_rel_party_id is
       select max(rel.party_id) from
       hz_parties org,
       hz_relationships rel
       where org.party_id           = p_org_party_id
         and org.party_type         = 'ORGANIZATION'
         and rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
         and rel.SUBJECT_TYPE       = 'PERSON'
         and rel.OBJECT_TABLE_NAME  = 'HZ_PARTIES'
         and rel.RELATIONSHIP_CODE  = 'CONTACT_OF'
         and rel.OBJECT_ID          = org.party_id
         and rel.SUBJECT_ID         = l_per_party_id;



cursor c_cont_email is
	SELECT PARTY_ID FROM AMS_PARTY_SOURCES
	  WHERE PARTY_ID = l_rel_party_id
	  and upper(COL26) = upper(p_email_address);


cursor c_cont_email_phone is

	SELECT PARTY_ID FROM AMS_PARTY_SOURCES
	  WHERE PARTY_ID = l_rel_party_id
	  and upper(COL26) = upper(p_email_address)
	  and COL28 = p_phone_area_code
	  and COL29 = p_phone_number
	  and COL30 = p_phone_extension;

cursor c_cont_phone is
        SELECT PARTY_ID FROM AMS_PARTY_SOURCES
	  WHERE PARTY_ID = l_rel_party_id
  	  and COL28 = p_phone_area_code
	  and COL29 = p_phone_number
	  and COL30 = p_phone_extension;

begin
x_return_status := FND_API.g_ret_sts_success;
--
-- Generates the customer key for PERSON
--
 if p_per_last_name is not null and p_per_first_name is not null then
   l_party_key := hz_fuzzy_pub.Generate_Key (
                                p_key_type => 'PERSON',
                                p_first_name => p_per_first_name,
                                p_last_name  => p_per_last_name
                               );
 end if;
--
-- If customer does not exists then it's a new customer.
--
 open c_customer_exists;
 fetch c_customer_exists into l_per_party_id;
 close c_customer_exists;
 if l_per_party_id is NULL then
    return;     -- ORG CONTACT DOES NOT EXISTS CHECKED WITH CUSTOMER_KEY.
 end if;

 -- find the relationship party id
 open c_rel_party_id;
 fetch c_rel_party_id into l_rel_party_id;
 close c_rel_party_id;

 open c_cont_email_phone;
 fetch c_cont_email_phone into l_max_party_id;
 close c_cont_email_phone;

 if l_max_party_id is not null then
    p_party_id     := l_per_party_id;   -- ORG CONTACT DOES NOT EXISTS WITH EMAIL AND PHONE NUMBER.
    return;
  end if;
--
-- Either email_address and phone number is available.
--
if l_max_party_id is not null and (p_email_address is not null or p_phone_number is not null) then
   open c_cont_email;
   fetch c_cont_email into l_email_party_id;
   close c_cont_email;


   if l_email_party_id is not null then
      p_party_id     :=  l_per_party_id;
      return;
   end if;

   open c_cont_phone;
   fetch c_cont_phone into l_phone_party_id;
   close c_cont_phone;


   if l_phone_party_id is not null then
      p_party_id := l_per_party_id;
   end if;
end if;


 exception
   when others then
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name,'contact_echeck');
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

end rented_contact_echeck;
-------------------------------

PROCEDURE create_party_source (
   p_import_list_header_id    IN    NUMBER,
   p_import_source_line_id    IN    NUMBER,
   p_overlay                  IN    VARCHAR2
                              ) IS
l_return_status   varchar2(1);
begin
insert into ams_party_sources
(
  party_sources_id,
  party_id,
  IMPORT_SOURCE_LINE_ID,
  OBJECT_VERSION_NUMBER,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_LOGIN,
  IMPORT_LIST_HEADER_ID,
  LIST_SOURCE_TYPE_ID,
  USED_FLAG,
  OVERLAY_FLAG,
  OVERLAY_DATE,
  COL1,
  COL2,
  COL3,
  COL4,
  COL5,
  COL6,
  COL7,
  COL8,
  COL9,
  COL10,
  COL11,
  COL12,
  COL13,
  COL14,
  COL15,
  COL16,
  COL17,
  COL18,
  COL19,
  COL20,
  COL21,
  COL22,
  COL23,
  COL24,
  COL25,
  COL26,
  COL27,
  COL28,
  COL29,
  COL30,
  COL31,
  COL32,
  COL33,
  COL34,
  COL35,
  COL36,
  COL37,
  COL201,
  COL202,
  COL203,
  COL204,
  COL205,
  COL206,
  COL207,
  COL208,
  COL209,
  COL210,
  COL211,
  COL212,
  COL213,
  COL214,
  COL215,
  COL216,
  COL217,
  COL218,
  COL219,
  COL220,
  COL221,
  COL222,
  COL223,
  COL224,
  COL225,
  COL226,
  COL227,
  COL228,
  COL229,
  COL230,
  COL231,
  COL232,
  COL233,
  COL234,
  COL235,
  COL236,
  COL237,
  COL238,
  COL239,
  COL240,
  COL241,
  COL242,
  COL243,
  COL244,
  COL245,
  COL246,
  COL247,
  COL248,
  COL249,
  COL250
)
select
  ams_party_sources_s.nextval,
  LINE.PARTY_ID,
  LINE.IMPORT_SOURCE_LINE_ID,
  LINE.OBJECT_VERSION_NUMBER,
  LINE.LAST_UPDATE_DATE,
  LINE.LAST_UPDATED_BY,
  LINE.CREATION_DATE,
  LINE.CREATED_BY,
  LINE.LAST_UPDATE_LOGIN,
  LINE.IMPORT_LIST_HEADER_ID,
  header.LIST_SOURCE_TYPE_ID,
  'N',
  nvl(p_overlay,'N'),
  SYSDATE,
  LINE.COL1,
  LINE.COL2,
  LINE.COL3,
  LINE.COL4,
  LINE.COL5,
  LINE.COL6,
  LINE.COL7,
  LINE.COL8,
  LINE.COL9,
  LINE.COL10,
  LINE.COL11,
  LINE.COL12,
  LINE.COL13,
  LINE.COL14,
  LINE.COL15,
  LINE.COL16,
  LINE.COL17,
  LINE.COL18,
  LINE.COL19,
  LINE.COL20,
  LINE.COL21,
  LINE.COL22,
  LINE.COL23,
  LINE.COL24,
  LINE.COL25,
  LINE.COL26,
  LINE.COL27,
  LINE.COL28,
  LINE.COL29,
  LINE.COL30,
  LINE.COL31,
  LINE.COL32,
  LINE.COL33,
  LINE.COL34,
  LINE.COL35,
  LINE.COL36,
  LINE.COL37,
  LINE.COL201,
  LINE.COL202,
  LINE.COL203,
  LINE.COL204,
  LINE.COL205,
  LINE.COL206,
  LINE.COL207,
  LINE.COL208,
  LINE.COL209,
  LINE.COL210,
  LINE.COL211,
  LINE.COL212,
  LINE.COL213,
  LINE.COL214,
  LINE.COL215,
  LINE.COL216,
  LINE.COL217,
  LINE.COL218,
  LINE.COL219,
  LINE.COL220,
  LINE.COL221,
  LINE.COL222,
  LINE.COL223,
  LINE.COL224,
  LINE.COL225,
  LINE.COL226,
  LINE.COL227,
  LINE.COL228,
  LINE.COL229,
  LINE.COL230,
  LINE.COL231,
  LINE.COL232,
  LINE.COL233,
  LINE.COL234,
  LINE.COL235,
  LINE.COL236,
  LINE.COL237,
  LINE.COL238,
  LINE.COL239,
  LINE.COL240,
  LINE.COL241,
  LINE.COL242,
  LINE.COL243,
  LINE.COL244,
  LINE.COL245,
  LINE.COL246,
  LINE.COL247,
  LINE.COL248,
  LINE.COL249,
  LINE.COL250
from ams_imp_source_lines line,
     ams_imp_list_headers_all header
where line.import_source_line_id = p_import_source_line_id
and   line.import_list_header_id = p_import_list_header_id
and   line.import_list_header_id = header.import_list_header_id;

EXCEPTION
       WHEN  others THEN
       -- ndadwal added if cond for bug 4966524
       if p_import_list_header_id is NOT NULL then
        AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => G_ARC_IMPORT_HEADER,
         p_log_used_by_id  => p_import_list_header_id,
         p_msg_data        => sqlerrm ,
         p_msg_type        => 'DEBUG'
        );
	end if;

          raise;
end create_party_source;
-- ------------------------------------------------------------
PROCEDURE person_party_echeck(
   p_party_id           IN OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2,
   p_per_first_name     IN       VARCHAR2,
   p_per_last_name      IN       VARCHAR2,
   p_address1           IN       VARCHAR2,
   p_country            IN       VARCHAR2,
   p_email_address      IN       VARCHAR2,
   p_ph_country_code    IN       VARCHAR2,
   p_ph_area_code       IN       VARCHAR2,
   p_ph_number          IN       VARCHAR2,
 -- sranka 1/13/2003 added p_orig_system_reference
   p_orig_system_reference IN       VARCHAR2

                      ) IS


l_party_key     varchar2(1000);
L_COUNT         number;
l_max_party_id  number;
l_party_tbl     hz_fuzzy_pub.PARTY_TBL_TYPE;
l_cust_exists   varchar2(1);
l_ret_status    varchar(1);
l_transposed_phone_no     varchar2(60);


cursor c_email_address is
        select max(p.party_id) from hz_contact_points cp,
        hz_parties p
        where p.customer_key = l_party_key
          and p.party_type = 'PERSON'
          and p.status = 'A'
          and cp.owner_table_id = p.party_id
          and cp.owner_table_name = 'HZ_PARTIES'
          and upper(cp.email_address) = upper(p_email_address);

cursor c_email_address_with_osr is
        select max(p.party_id) from hz_contact_points cp,
        hz_parties p
        where p.customer_key = l_party_key
          and p.party_type = 'PERSON'
          and p.status = 'A'
          and p.orig_system_reference = p_orig_system_reference
          and cp.owner_table_id = p.party_id
          and cp.owner_table_name = 'HZ_PARTIES'
          and upper(cp.email_address) = upper(p_email_address);


cursor c_ph_number is
        select max(p.party_id) from hz_contact_points cp,
        hz_parties p
        where p.customer_key = l_party_key
          and p.party_type = 'PERSON'
          and p.status = 'A'
          and cp.owner_table_id = p.party_id
          and cp.owner_table_name = 'HZ_PARTIES'
          and cp.transposed_phone_number = l_transposed_phone_no;
/*
          and cp.phone_number = p_ph_number
          and nvl(cp.phone_country_code,nvl(p_ph_country_code,'x')) = nvl(p_ph_country_code,'x')
          and nvl(cp.phone_area_code,nvl(p_ph_area_code,'x')) = nvl(p_ph_area_code,'x');
*/

cursor c_ph_number_with_osr is
        select max(p.party_id) from hz_contact_points cp,
        hz_parties p
        where p.customer_key = l_party_key
          and p.party_type = 'PERSON'
          and p.status = 'A'
          and p.orig_system_reference = p_orig_system_reference
          and cp.owner_table_id = p.party_id
          and cp.owner_table_name = 'HZ_PARTIES'
          and cp.transposed_phone_number = l_transposed_phone_no;
/*
          and cp.phone_number = p_ph_number
          and nvl(cp.phone_country_code,nvl(p_ph_country_code,'x')) = nvl(p_ph_country_code,'x')
          and nvl(cp.phone_area_code,nvl(p_ph_area_code,'x')) = nvl(p_ph_area_code,'x');
*/

cursor c_address_country is
        select max(psite.party_id) from hz_party_sites psite, hz_locations loc,
        hz_parties party
         where  psite.location_id = loc.location_id
          and  loc.address1      = p_address1
          and  loc.country       = p_country
          and  party.customer_key = l_party_key
	  and  party.party_type   = 'PERSON'
          and party.status = 'A'
          and  psite.party_id      = party.party_id;

cursor c_address_country_with_osr is
        select max(psite.party_id) from hz_party_sites psite, hz_locations loc,
        hz_parties party
         where  psite.location_id = loc.location_id
          and  loc.address1      = p_address1
          and  loc.country       = p_country
          and  party.customer_key = l_party_key
	  and  party.party_type   = 'PERSON'
          and party.status = 'A'
          and  party.orig_system_reference = p_orig_system_reference
          and  psite.party_id      = party.party_id;


cursor c_person_exists is
       select 'Y' from hz_parties
       where customer_key = l_party_key
          and status = 'A'
         and party_type   = 'PERSON';

cursor c_person_exists_with_osr is
       select 'Y' from hz_parties
       where customer_key = l_party_key
         and party_type   = 'PERSON'
          and status = 'A'
          and orig_system_reference = p_orig_system_reference;


begin

x_return_status := FND_API.g_ret_sts_success;
--
-- Generates the customer key for PERSON
--
 if p_per_last_name is not null and p_per_first_name is not null then
   l_party_key := hz_fuzzy_pub.Generate_Key (
                                p_key_type => 'PERSON',
                                p_first_name => p_per_first_name,
                                p_last_name  => p_per_last_name
                               );
l_transposed_phone_no := hz_phone_number_pkg.transpose(p_ph_country_code||p_ph_area_code||p_ph_number)
;
    IF p_orig_system_reference IS NULL then
        open c_person_exists;
        fetch c_person_exists into l_cust_exists;
        close c_person_exists;
    else
        open c_person_exists_with_osr;
        fetch c_person_exists_with_osr into l_cust_exists;
        close c_person_exists_with_osr;

        IF l_cust_exists IS NULL then
            open c_person_exists;
            fetch c_person_exists into l_cust_exists;
            close c_person_exists;
        END if;

    END if;

 end if;

--
-- If customer does not exists then it's a new customer.
--
 if l_cust_exists is NULL then
    return;
 end if;

-- IF email address is provided
   if p_email_address is not null then

     IF p_orig_system_reference IS NULL then
       open c_email_address;
       fetch c_email_address into p_party_id;
       close c_email_address;
     else
       open c_email_address_with_osr;
       fetch c_email_address_with_osr into p_party_id;
       close c_email_address_with_osr;

       IF p_party_id IS NULL then
           open c_email_address;
           fetch c_email_address into p_party_id;
           close c_email_address;
       END if;

     END if;
       if p_party_id is not null then
            return;
       end if;
   end if;

-- IF phone number is provided
   if p_ph_number is not null then
       IF p_orig_system_reference IS NULL then
           open c_ph_number;
           fetch c_ph_number into p_party_id;
           close c_ph_number;
       else
           open c_ph_number_with_osr;
           fetch c_ph_number_with_osr into p_party_id;
           close c_ph_number_with_osr;

           IF p_party_id IS NULL THEN
               open c_ph_number;
               fetch c_ph_number into p_party_id;
               close c_ph_number;
           END IF ;

       END IF;
       if p_party_id is not null then
            return;
       end if;
   end if;

--
-- When address1 and country is provided
--
    if p_address1 is not null and p_country is not null then

       IF p_orig_system_reference IS NULL then
           open c_address_country;
           fetch c_address_country into p_party_id;
           close c_address_country;
       else
           open c_address_country_with_osr;
           fetch c_address_country_with_osr into p_party_id;
           close c_address_country_with_osr;

           IF p_party_id IS NULL then
               open c_address_country;
               fetch c_address_country into p_party_id;
               close c_address_country;
           END if;

       END IF;

       if p_party_id is not null then
            return;
       end if;
    end if;
 exception
     when others then
     x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name,'person_party_echeck');
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

end person_party_echeck;
-- ------------------------------------------------------------
-- SOLIN, bug 4465931
PROCEDURE contact_person_party_echeck(
   p_party_id           IN OUT NOCOPY   NUMBER,
   x_return_status      OUT NOCOPY    VARCHAR2,
   x_msg_count          OUT NOCOPY    NUMBER,
   x_msg_data           OUT NOCOPY    VARCHAR2,
   p_per_first_name     IN       VARCHAR2,
   p_per_last_name      IN       VARCHAR2,
   p_address1           IN       VARCHAR2,
   p_country            IN       VARCHAR2,
   p_email_address      IN       VARCHAR2,
   p_ph_country_code    IN       VARCHAR2,
   p_ph_area_code       IN       VARCHAR2,
   p_ph_number          IN       VARCHAR2,
   p_orig_system_reference IN       VARCHAR2

                      ) IS


l_party_key     varchar2(1000);
L_COUNT         number;
l_max_party_id  number;
l_party_tbl     hz_fuzzy_pub.PARTY_TBL_TYPE;
l_cust_exists   varchar2(1);
l_ret_status    varchar(1);
l_transposed_phone_no     varchar2(60);


cursor c_email_address is
        select max(p2.party_id) from hz_contact_points cp,
        hz_parties p1, hz_relationships hr, hz_parties p2
        where p2.customer_key = l_party_key
          and p1.party_type = 'PARTY_RELATIONSHIP'
          and p2.party_type = 'PERSON'
          and p1.status = 'A'
          and p2.status = 'A'
          and cp.owner_table_id = p1.party_id
          and cp.owner_table_name = 'HZ_PARTIES'
          and upper(cp.email_address) = upper(p_email_address)
          and p1.party_id = hr.party_id
          and hr.relationship_code = 'CONTACT_OF'
          and hr.subject_id = p2.party_id;

cursor c_email_address_with_osr is
        select max(p2.party_id) from hz_contact_points cp,
        hz_parties p1, hz_relationships hr, hz_parties p2
        where p2.customer_key = l_party_key
          and p1.party_type = 'PARTY_RELATIONSHIP'
          and p2.party_type = 'PERSON'
          and p1.status = 'A'
          and p2.status = 'A'
          and p1.orig_system_reference = p_orig_system_reference
          and cp.owner_table_id = p1.party_id
          and cp.owner_table_name = 'HZ_PARTIES'
          and upper(cp.email_address) = upper(p_email_address)
          and p1.party_id = hr.party_id
          and hr.relationship_code = 'CONTACT_OF'
          and hr.subject_id = p2.party_id;


cursor c_ph_number is
        select max(p2.party_id) from hz_contact_points cp,
        hz_parties p1, hz_relationships hr, hz_parties p2
        where p2.customer_key = l_party_key
          and p1.party_type = 'PARTY_RELATIONSHIP'
          and p2.party_type = 'PERSON'
          and p1.status = 'A'
          and p2.status = 'A'
          and cp.owner_table_id = p1.party_id
          and cp.owner_table_name = 'HZ_PARTIES'
          and cp.transposed_phone_number = l_transposed_phone_no
          and p1.party_id = hr.party_id
          and hr.relationship_code = 'CONTACT_OF'
          and hr.subject_id = p2.party_id;
/*
          and cp.phone_number = p_ph_number
          and nvl(cp.phone_country_code,nvl(p_ph_country_code,'x')) = nvl(p_ph_country_code,'x')
          and nvl(cp.phone_area_code,nvl(p_ph_area_code,'x')) = nvl(p_ph_area_code,'x');
*/

cursor c_ph_number_with_osr is
        select max(p2.party_id) from hz_contact_points cp,
        hz_parties p1, hz_relationships hr, hz_parties p2
        where p2.customer_key = l_party_key
          and p1.party_type = 'PARTY_RELATIONSHIP'
          and p2.party_type = 'PERSON'
          and p1.status = 'A'
          and p2.status = 'A'
          and p1.orig_system_reference = p_orig_system_reference
          and cp.owner_table_id = p1.party_id
          and cp.owner_table_name = 'HZ_PARTIES'
          and cp.transposed_phone_number = l_transposed_phone_no
          and p1.party_id = hr.party_id
          and hr.relationship_code = 'CONTACT_OF'
          and hr.subject_id = p2.party_id;
/*
          and cp.phone_number = p_ph_number
          and nvl(cp.phone_country_code,nvl(p_ph_country_code,'x')) = nvl(p_ph_country_code,'x')
          and nvl(cp.phone_area_code,nvl(p_ph_area_code,'x')) = nvl(p_ph_area_code,'x');
*/

cursor c_address_country is
        select max(p2.party_id) from hz_party_sites psite, hz_locations loc,
        hz_parties party, hz_relationships hr, hz_parties p2
         where  psite.location_id = loc.location_id
          and  loc.address1      = p_address1
          and  loc.country       = p_country
          and  party.customer_key = l_party_key
          and party.party_type = 'PARTY_RELATIONSHIP'
          and p2.party_type = 'PERSON'
          and party.status = 'A'
          and p2.status = 'A'
          and  psite.party_id      = party.party_id
          and party.party_id = hr.party_id
          and hr.relationship_code = 'CONTACT_OF'
          and hr.subject_id = p2.party_id;

cursor c_address_country_with_osr is
        select max(p2.party_id) from hz_party_sites psite, hz_locations loc,
        hz_parties party, hz_relationships hr, hz_parties p2
         where  psite.location_id = loc.location_id
          and  loc.address1      = p_address1
          and  loc.country       = p_country
          and  party.customer_key = l_party_key
          and party.party_type = 'PARTY_RELATIONSHIP'
          and p2.party_type = 'PERSON'
          and party.status = 'A'
          and p2.status = 'A'
          and  party.orig_system_reference = p_orig_system_reference
          and  psite.party_id      = party.party_id
          and party.party_id = hr.party_id
          and hr.relationship_code = 'CONTACT_OF'
          and hr.subject_id = p2.party_id;


cursor c_person_exists is
       select 'Y' from hz_parties hp1, hz_relationships hr, hz_parties hp2
       where hp2. customer_key = l_party_key
         and hp1.status = 'A'
         and hp2.status = 'A'
         and hp1.party_type   = 'PARTY_RELATIONSHIP'
         and hp1.party_id = hr.party_id
         and hr.relationship_code = 'CONTACT_OF'
         and hr.subject_id = hp2.party_id
         and hp2.party_type = 'PERSON';

cursor c_person_exists_with_osr is
       select 'Y' from hz_parties hp1, hz_relationships hr, hz_parties hp2
       where hp2. customer_key = l_party_key
         and hp1.status = 'A'
         and hp2.status = 'A'
         and hp1.party_type   = 'PARTY_RELATIONSHIP'
         and hp1.party_id = hr.party_id
         and hr.relationship_code = 'CONTACT_OF'
         and hr.subject_id = hp2.party_id
         and hp2.party_type = 'PERSON'
         and hp2.orig_system_reference = p_orig_system_reference;

cursor c_get_party_id(c_rel_party_id NUMBER) IS
       select hr.subject_id
         from hz_relationships hr
        where hr.party_id = c_rel_party_id
          and hr.relationship_code = 'CONTACT_OF';
begin

x_return_status := FND_API.g_ret_sts_success;
--
-- Generates the customer key for PERSON
--
 if p_per_last_name is not null and p_per_first_name is not null then
   l_party_key := hz_fuzzy_pub.Generate_Key (
                                p_key_type => 'PERSON',
                                p_first_name => p_per_first_name,
                                p_last_name  => p_per_last_name
                               );
l_transposed_phone_no := hz_phone_number_pkg.transpose(p_ph_country_code||p_ph_area_code||p_ph_number)
;
    IF p_orig_system_reference IS NULL then
        open c_person_exists;
        fetch c_person_exists into l_cust_exists;
        close c_person_exists;
    else
        open c_person_exists_with_osr;
        fetch c_person_exists_with_osr into l_cust_exists;
        close c_person_exists_with_osr;

        IF l_cust_exists IS NULL then
            open c_person_exists;
            fetch c_person_exists into l_cust_exists;
            close c_person_exists;
        END if;

    END if;

 end if;

--
-- If customer does not exists then it's a new customer.
--
 if l_cust_exists is NULL then
    return;
 end if;

-- IF email address is provided
   if p_email_address is not null then

     IF p_orig_system_reference IS NULL then
       open c_email_address;
       fetch c_email_address into p_party_id;
       close c_email_address;
     else
       open c_email_address_with_osr;
       fetch c_email_address_with_osr into p_party_id;
       close c_email_address_with_osr;

       IF p_party_id IS NULL then
           open c_email_address;
           fetch c_email_address into p_party_id;
           close c_email_address;
       END if;

     END if;
       if p_party_id is not null then
            return;
       end if;
   end if;

-- IF phone number is provided
   if p_ph_number is not null then
       IF p_orig_system_reference IS NULL then
           open c_ph_number;
           fetch c_ph_number into p_party_id;
           close c_ph_number;
       else
           open c_ph_number_with_osr;
           fetch c_ph_number_with_osr into p_party_id;
           close c_ph_number_with_osr;

           IF p_party_id IS NULL THEN
               open c_ph_number;
               fetch c_ph_number into p_party_id;
               close c_ph_number;
           END IF ;

       END IF;
       if p_party_id is not null then
           return;
       end if;
   end if;

--
-- When address1 and country is provided
--
    if p_address1 is not null and p_country is not null then

       IF p_orig_system_reference IS NULL then
           open c_address_country;
           fetch c_address_country into p_party_id;
           close c_address_country;
       else
           open c_address_country_with_osr;
           fetch c_address_country_with_osr into p_party_id;
           close c_address_country_with_osr;

           IF p_party_id IS NULL then
               open c_address_country;
               fetch c_address_country into p_party_id;
               close c_address_country;
           END if;

       END IF;

       if p_party_id is not null then
           return;
       end if;
    end if;
 exception
     when others then
     x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name,'contact_person_party_echeck');
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

end contact_person_party_echeck;
-- SOLIN, end bug 4465931
-----------------------------------------
PROCEDURE rented_person_party_echeck(
   p_party_id           IN OUT NOCOPY   NUMBER,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2,
   p_per_first_name     IN       VARCHAR2,
   p_per_last_name      IN       VARCHAR2,
   p_address1           IN       VARCHAR2,
   p_country            IN       VARCHAR2,
   p_email_address      IN       VARCHAR2,
   p_ph_country_code    IN       VARCHAR2,
   p_ph_area_code       IN       VARCHAR2,
   p_ph_number          IN       VARCHAR2
                      ) IS


l_party_key     varchar2(1000);
L_COUNT         number;
l_max_party_id  number;
l_party_tbl     hz_fuzzy_pub.PARTY_TBL_TYPE;
l_cust_exists   varchar2(1);
l_ret_status    varchar(1);


cursor c_email_address is
	SELECT PARTY_ID FROM AMS_PARTY_SOURCES
	  WHERE PARTY_ID = p_party_id
	  and upper(COL26) = upper(p_email_address);

cursor c_ph_number is
        select party_id from AMS_PARTY_SOURCES
          where  party_id = p_party_id
          and col29 = p_ph_number
          and nvl(col27,nvl(p_ph_country_code,'x')) = nvl(p_ph_country_code,'x')
          and nvl(col28,nvl(p_ph_area_code,'x')) = nvl(p_ph_area_code,'x');

cursor c_address_country is
        select party_id from AMS_PARTY_SOURCES
          where party_id = p_party_id
	  and col18 = p_address1
	  and col17 = p_country;


cursor c_person_exists is
       select MAX(PARTY_ID) from hz_parties
       where customer_key = l_party_key
         and party_type   = 'PERSON';
begin

x_return_status := FND_API.g_ret_sts_success;
--
-- Generates the customer key for PERSON
--
 if p_per_last_name is not null and p_per_first_name is not null then
   l_party_key := hz_fuzzy_pub.Generate_Key (
                                p_key_type => 'PERSON',
                                p_first_name => p_per_first_name,
                                p_last_name  => p_per_last_name
                               );
    open c_person_exists;
    fetch c_person_exists into p_party_id;
    close c_person_exists;
 end if;

--
-- If customer does not exists then it's a new customer.
--
 if l_max_party_id is null then
    return;
 end if;

-- IF email address is provided
   if p_email_address is not null then
       open c_email_address;
       fetch c_email_address into p_party_id;
       close c_email_address;

       if p_party_id is not null then
            return;
       end if;
   end if;

-- IF phone number is provided
   if p_ph_number is not null then
       open c_ph_number;
       fetch c_ph_number into p_party_id;
       close c_ph_number;
       if p_party_id is not null then
            return;
       end if;
   end if;

--
-- When address1 and country is provided
--
    if p_address1 is not null and p_country is not null then
       open c_address_country;
       fetch c_address_country into p_party_id;
       close c_address_country;
       if p_party_id is not null then
            return;
       end if;
    end if;
 exception
     when others then
     x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name,'person_party_echeck');
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

end rented_person_party_echeck;
-- -----------------------------------------------------
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
                     ) IS

BEGIN
   SAVEPOINT update_rented_list_party_pub;
   -- initialize the message list;
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --call private API procedure.
   AMS_ListImport_PVT.update_rented_list_party (
       p_party_id              => p_party_id,
       p_return_status         => x_return_status,
       p_msg_count             => x_msg_count,
       p_msg_data              => x_msg_data);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );
EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_rented_list_party_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_rented_list_party_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_rented_list_party_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, 'update_rented_list_party');
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

end update_rented_list_party;

--
-- for XML updates the success in the element table
--
PROCEDURE process_element_success(
                                 p_import_list_header_id    IN    NUMBER,
                                 p_xml_element_id IN NUMBER) IS

    x_return_status             VARCHAR2(1);
    x_msg_data                  VARCHAR2(2000);
    l_imp_type 			VARCHAR2(30);

    l_per_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;
    l_org_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;
    l_loc_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;
    l_con_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;
    l_pho_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;
    l_eml_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;

cursor c_imp_type is
select import_type from ams_imp_list_headers_all
where import_list_header_id = p_import_list_header_id;

begin
     open c_imp_type;
     fetch c_imp_type into l_imp_type;
     close c_imp_type;

   if l_imp_type = 'B2B' then
     update AMS_IMP_XML_ELEMENTS
        set LOAD_STATUS = 'SUCCESS'
      where imp_xml_element_id = p_xml_element_id;
      AMS_IMPORT_XML_PVT.Get_Children_Nodes (
        p_imp_xml_element_id => p_xml_element_id,
        x_child_set          => l_org_record_in_tbl,
        x_return_status      => x_return_status,
        x_msg_data           => x_msg_data);
       -- FOR ORGANIZATION
       FOR i IN 1..l_org_record_in_tbl.COUNT
        LOOP
         if l_org_record_in_tbl(i).data_type = 'T' then
           update AMS_IMP_XML_ELEMENTS
              set LOAD_STATUS = 'SUCCESS'
            where  imp_xml_element_id = l_org_record_in_tbl(i).imp_xml_element_id;
          -- FOR LOCATION
          AMS_IMPORT_XML_PVT.Get_Children_Nodes (
          p_imp_xml_element_id => l_org_record_in_tbl(i).imp_xml_element_id,
          x_child_set          => l_loc_record_in_tbl,
          x_return_status      => x_return_status,
          x_msg_data           => x_msg_data);
          FOR j IN 1..l_loc_record_in_tbl.COUNT
           LOOP
            if l_loc_record_in_tbl(j).data_type = 'T' then
             update AMS_IMP_XML_ELEMENTS
              set LOAD_STATUS = 'SUCCESS'
             where imp_xml_element_id = l_loc_record_in_tbl(j).imp_xml_element_id;
          -- FOR ORG CONTACT
             AMS_IMPORT_XML_PVT.Get_Children_Nodes (
             p_imp_xml_element_id => l_loc_record_in_tbl(j).imp_xml_element_id,
             x_child_set          => l_con_record_in_tbl,
             x_return_status      => x_return_status,
             x_msg_data           => x_msg_data);
             FOR k IN 1..l_con_record_in_tbl.COUNT
              LOOP
               if l_con_record_in_tbl(k).data_type = 'T' then
                 update AMS_IMP_XML_ELEMENTS
                 set LOAD_STATUS = 'SUCCESS'
                 where imp_xml_element_id = l_con_record_in_tbl(k).imp_xml_element_id;
                 -- FOR PHONE
                 AMS_IMPORT_XML_PVT.Get_Children_Nodes (
                 p_imp_xml_element_id => l_con_record_in_tbl(k).imp_xml_element_id,
                 x_child_set          => l_pho_record_in_tbl,
                 x_return_status      => x_return_status,
                 x_msg_data           => x_msg_data);
                 FOR l IN 1..l_pho_record_in_tbl.COUNT
                  LOOP
                    if l_pho_record_in_tbl(l).data_type = 'T' then
                      update AMS_IMP_XML_ELEMENTS
                      set LOAD_STATUS = 'SUCCESS'
                      where imp_xml_element_id = l_pho_record_in_tbl(l).imp_xml_element_id;
                    end if;
                  END LOOP; -- FOR PHONE
                 -- FOR EMAIL
                 AMS_IMPORT_XML_PVT.Get_Children_Nodes (
                 p_imp_xml_element_id => l_con_record_in_tbl(k).imp_xml_element_id,
                 x_child_set          => l_eml_record_in_tbl,
                 x_return_status      => x_return_status,
                 x_msg_data           => x_msg_data);
                 FOR m IN 1..l_eml_record_in_tbl.COUNT
                  LOOP
                    if l_eml_record_in_tbl(m).data_type = 'T' then
                      update AMS_IMP_XML_ELEMENTS
                      set LOAD_STATUS = 'SUCCESS'
                      where imp_xml_element_id = l_eml_record_in_tbl(m).imp_xml_element_id;
                    end if;
                  END LOOP; -- FOR EMAIL
               end if;
              END LOOP; -- FOR ORG CONTACT
             end if;
           END LOOP; -- FOR LOCATION
        end if;
        END LOOP; -- FOR ORGANIZATION
      end if;


   if l_imp_type = 'B2C' then
     update AMS_IMP_XML_ELEMENTS
        set LOAD_STATUS = 'SUCCESS'
      where imp_xml_element_id = p_xml_element_id;
      AMS_IMPORT_XML_PVT.Get_Children_Nodes (
        p_imp_xml_element_id => p_xml_element_id,
        x_child_set          => l_per_record_in_tbl,
        x_return_status      => x_return_status,
        x_msg_data           => x_msg_data);
       -- FOR PERSON
       FOR i IN 1..l_per_record_in_tbl.COUNT
        LOOP
         if l_per_record_in_tbl(i).data_type = 'T' then
           update AMS_IMP_XML_ELEMENTS
              set LOAD_STATUS = 'SUCCESS'
            where  imp_xml_element_id = l_per_record_in_tbl(i).imp_xml_element_id;
          -- FOR LOCATION
          AMS_IMPORT_XML_PVT.Get_Children_Nodes (
          p_imp_xml_element_id => l_per_record_in_tbl(i).imp_xml_element_id,
          x_child_set          => l_loc_record_in_tbl,
          x_return_status      => x_return_status,
          x_msg_data           => x_msg_data);
          FOR j IN 1..l_loc_record_in_tbl.COUNT
           LOOP
            if l_loc_record_in_tbl(j).data_type = 'T' then
             update AMS_IMP_XML_ELEMENTS
              set LOAD_STATUS = 'SUCCESS'
             where imp_xml_element_id = l_loc_record_in_tbl(j).imp_xml_element_id;
                 -- FOR PHONE
                 AMS_IMPORT_XML_PVT.Get_Children_Nodes (
                 p_imp_xml_element_id => l_loc_record_in_tbl(j).imp_xml_element_id,
                 x_child_set          => l_pho_record_in_tbl,
                 x_return_status      => x_return_status,
                 x_msg_data           => x_msg_data);
                 FOR k IN 1..l_pho_record_in_tbl.COUNT
                  LOOP
                    if l_pho_record_in_tbl(k).data_type = 'T' then
                      update AMS_IMP_XML_ELEMENTS
                      set LOAD_STATUS = 'SUCCESS'
                      where imp_xml_element_id = l_pho_record_in_tbl(k).imp_xml_element_id;
                    end if;
                  END LOOP; -- FOR PHONE
                 -- FOR EMAIL
                 AMS_IMPORT_XML_PVT.Get_Children_Nodes (
                 p_imp_xml_element_id => l_loc_record_in_tbl(j).imp_xml_element_id,
                 x_child_set          => l_eml_record_in_tbl,
                 x_return_status      => x_return_status,
                 x_msg_data           => x_msg_data);
                 FOR l IN 1..l_eml_record_in_tbl.COUNT
                  LOOP
                    if l_eml_record_in_tbl(l).data_type = 'T' then
                      update AMS_IMP_XML_ELEMENTS
                      set LOAD_STATUS = 'SUCCESS'
                      where imp_xml_element_id = l_eml_record_in_tbl(l).imp_xml_element_id;
                    end if;
                  END LOOP; -- FOR EMAIL
               end if;
           END LOOP; -- FOR LOCATION
        end if;
        END LOOP; -- FOR PERSON
      end if;

 exception
 WHEN OTHERS THEN
    FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('ROW','Error in process_element_success :' || SQLERRM||' '||SQLCODE);
    -- ndadwal added if cond for bug 4966524
    if p_import_list_header_id is NOT NULL then
    AMS_Utility_PVT.Create_Log (
      x_return_status   => x_return_status,
      p_arc_log_used_by => G_ARC_IMPORT_HEADER,
      p_log_used_by_id  => p_import_list_header_id,
      p_msg_data        => FND_MESSAGE.get,
      p_msg_type        => 'DEBUG'
   );
   end if;
end process_element_success;


--
-- for XML updates the duplicate in the element table
--
PROCEDURE process_element_duplicate(
                                 p_import_list_header_id    IN    NUMBER,
                                 p_xml_element_id IN NUMBER) IS

    x_return_status             VARCHAR2(1);
    x_msg_data                  VARCHAR2(2000);
    l_imp_type 			VARCHAR2(30);

    l_per_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;
    l_org_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;
    l_loc_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;
    l_con_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;
    l_pho_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;
    l_eml_record_in_tbl  AMS_IMPORT_XML_PVT.xml_element_set_type;

cursor c_imp_type is
select import_type from ams_imp_list_headers_all
where import_list_header_id = p_import_list_header_id;

begin
     open c_imp_type;
     fetch c_imp_type into l_imp_type;
     close c_imp_type;

   if l_imp_type = 'B2B' then
   -- ndadwal added if cond for bug 4966524
    if p_import_list_header_id is NOT NULL then
           AMS_Utility_PVT.Create_Log (
           x_return_status   => x_return_status,
           p_arc_log_used_by => G_ARC_IMPORT_HEADER,
           p_log_used_by_id  => p_import_list_header_id,
           p_msg_data        => 'p_xml_element_id := '||p_xml_element_id,
           p_msg_type        => 'DEBUG');
     end if;
     update AMS_IMP_XML_ELEMENTS
        set LOAD_STATUS = 'DUPLICATE'
      where imp_xml_element_id = p_xml_element_id;
      AMS_IMPORT_XML_PVT.Get_Children_Nodes (
        p_imp_xml_element_id => p_xml_element_id,
        x_child_set          => l_org_record_in_tbl,
        x_return_status      => x_return_status,
        x_msg_data           => x_msg_data);
       -- FOR ORGANIZATION
       FOR i IN 1..l_org_record_in_tbl.COUNT
        LOOP
         if l_org_record_in_tbl(i).data_type = 'T' then
           update AMS_IMP_XML_ELEMENTS
              set LOAD_STATUS = 'DUPLICATE'
            where  imp_xml_element_id = l_org_record_in_tbl(i).imp_xml_element_id;
          -- FOR LOCATION
          AMS_IMPORT_XML_PVT.Get_Children_Nodes (
          p_imp_xml_element_id => l_org_record_in_tbl(i).imp_xml_element_id,
          x_child_set          => l_loc_record_in_tbl,
          x_return_status      => x_return_status,
          x_msg_data           => x_msg_data);
          FOR j IN 1..l_loc_record_in_tbl.COUNT
           LOOP
            if l_loc_record_in_tbl(j).data_type = 'T' then
             update AMS_IMP_XML_ELEMENTS
              set LOAD_STATUS = 'DUPLICATE'
             where imp_xml_element_id = l_loc_record_in_tbl(j).imp_xml_element_id;
          -- FOR ORG CONTACT
             AMS_IMPORT_XML_PVT.Get_Children_Nodes (
             p_imp_xml_element_id => l_loc_record_in_tbl(j).imp_xml_element_id,
             x_child_set          => l_con_record_in_tbl,
             x_return_status      => x_return_status,
             x_msg_data           => x_msg_data);
             FOR k IN 1..l_con_record_in_tbl.COUNT
              LOOP
               if l_con_record_in_tbl(k).data_type = 'T' then
                 update AMS_IMP_XML_ELEMENTS
                 set LOAD_STATUS = 'DUPLICATE'
                 where imp_xml_element_id = l_con_record_in_tbl(k).imp_xml_element_id;
                 -- FOR PHONE
                 AMS_IMPORT_XML_PVT.Get_Children_Nodes (
                 p_imp_xml_element_id => l_con_record_in_tbl(k).imp_xml_element_id,
                 x_child_set          => l_pho_record_in_tbl,
                 x_return_status      => x_return_status,
                 x_msg_data           => x_msg_data);
                 FOR l IN 1..l_pho_record_in_tbl.COUNT
                  LOOP
                    if l_pho_record_in_tbl(l).data_type = 'T' then
                      update AMS_IMP_XML_ELEMENTS
                      set LOAD_STATUS = 'DUPLICATE'
                      where imp_xml_element_id = l_pho_record_in_tbl(l).imp_xml_element_id;
                    end if;
                  END LOOP; -- FOR PHONE
                 -- FOR EMAIL
                 AMS_IMPORT_XML_PVT.Get_Children_Nodes (
                 p_imp_xml_element_id => l_con_record_in_tbl(k).imp_xml_element_id,
                 x_child_set          => l_eml_record_in_tbl,
                 x_return_status      => x_return_status,
                 x_msg_data           => x_msg_data);
                 FOR m IN 1..l_eml_record_in_tbl.COUNT
                  LOOP
                    if l_eml_record_in_tbl(m).data_type = 'T' then
                      update AMS_IMP_XML_ELEMENTS
                      set LOAD_STATUS = 'DUPLICATE'
                      where imp_xml_element_id = l_eml_record_in_tbl(m).imp_xml_element_id;
                    end if;
                  END LOOP; -- FOR EMAIL
               end if;
              END LOOP; -- FOR ORG CONTACT
             end if;
           END LOOP; -- FOR LOCATION
        end if;
        END LOOP; -- FOR ORGANIZATION
      end if;


   if l_imp_type = 'B2C' then
     update AMS_IMP_XML_ELEMENTS
        set LOAD_STATUS = 'DUPLICATE'
      where imp_xml_element_id = p_xml_element_id;
      AMS_IMPORT_XML_PVT.Get_Children_Nodes (
        p_imp_xml_element_id => p_xml_element_id,
        x_child_set          => l_per_record_in_tbl,
        x_return_status      => x_return_status,
        x_msg_data           => x_msg_data);
       -- FOR PERSON
       FOR i IN 1..l_per_record_in_tbl.COUNT
        LOOP
         if l_per_record_in_tbl(i).data_type = 'T' then
           update AMS_IMP_XML_ELEMENTS
              set LOAD_STATUS = 'DUPLICATE'
            where  imp_xml_element_id = l_per_record_in_tbl(i).imp_xml_element_id;
          -- FOR LOCATION
          AMS_IMPORT_XML_PVT.Get_Children_Nodes (
          p_imp_xml_element_id => l_per_record_in_tbl(i).imp_xml_element_id,
          x_child_set          => l_loc_record_in_tbl,
          x_return_status      => x_return_status,
          x_msg_data           => x_msg_data);
          FOR j IN 1..l_loc_record_in_tbl.COUNT
           LOOP
            if l_loc_record_in_tbl(j).data_type = 'T' then
             update AMS_IMP_XML_ELEMENTS
              set LOAD_STATUS = 'DUPLICATE'
             where imp_xml_element_id = l_loc_record_in_tbl(j).imp_xml_element_id;
                 -- FOR PHONE
                 AMS_IMPORT_XML_PVT.Get_Children_Nodes (
                 p_imp_xml_element_id => l_loc_record_in_tbl(j).imp_xml_element_id,
                 x_child_set          => l_pho_record_in_tbl,
                 x_return_status      => x_return_status,
                 x_msg_data           => x_msg_data);
                 FOR k IN 1..l_pho_record_in_tbl.COUNT
                  LOOP
                    if l_pho_record_in_tbl(k).data_type = 'T' then
                      update AMS_IMP_XML_ELEMENTS
                      set LOAD_STATUS = 'DUPLICATE'
                      where imp_xml_element_id = l_pho_record_in_tbl(k).imp_xml_element_id;
                    end if;
                  END LOOP; -- FOR PHONE
                 -- FOR EMAIL
                 AMS_IMPORT_XML_PVT.Get_Children_Nodes (
                 p_imp_xml_element_id => l_loc_record_in_tbl(j).imp_xml_element_id,
                 x_child_set          => l_eml_record_in_tbl,
                 x_return_status      => x_return_status,
                 x_msg_data           => x_msg_data);
                 FOR l IN 1..l_eml_record_in_tbl.COUNT
                  LOOP
                    if l_eml_record_in_tbl(l).data_type = 'T' then
                      update AMS_IMP_XML_ELEMENTS
                      set LOAD_STATUS = 'DUPLICATE'
                      where imp_xml_element_id = l_eml_record_in_tbl(l).imp_xml_element_id;
                    end if;
                  END LOOP; -- FOR EMAIL
               end if;
           END LOOP; -- FOR LOCATION
        end if;
        END LOOP; -- FOR PERSON
      end if;

 exception
 WHEN OTHERS THEN
    FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('ROW','Error in process_element_duplicate :' || SQLERRM||' '||SQLCODE);
    -- ndadwal added if cond for bug 4966524
    if p_import_list_header_id is NOT NULL then
    AMS_Utility_PVT.Create_Log (
      x_return_status   => x_return_status,
      p_arc_log_used_by => G_ARC_IMPORT_HEADER,
      p_log_used_by_id  => p_import_list_header_id,
      p_msg_data        => FND_MESSAGE.get,
      p_msg_type        => 'DEBUG'
   );
   end if;
end process_element_duplicate;



end AMS_List_Import_PUB;

/
