--------------------------------------------------------
--  DDL for Package Body AMS_REGISTRANTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_REGISTRANTS_PVT" AS
/* $Header: amsvevrb.pls 120.5 2005/12/07 21:36:50 sikalyan ship $ */
   g_pkg_name   CONSTANT VARCHAR2(30):='AMS_Registrants_PVT';
   G_FILE_NAME     CONSTANT VARCHAR2(15):='amsvevrb.pls';
   g_log_level     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

-----------------------------------------------------------
-- PACKAGE
--   AMS_Registrants_PVT
--
-- PURPOSE
--
-- PROCEDURES
--       find_a_party
--
-- PARAMETERS
--           INPUT
--               p_rec             AMS_ListImport_PVT.party_detail_rec_type%TYPE;
--
--           OUTPUT

-- HISTORY
-- 15-JAN-2002    mukumar      Created.
-- 25-Feb-2002    ptendulk     Added Function Get_Event_Det
-- 07-MAR-2002    dcastlem     Added person_party_echeck
-- 12-MAR-2002    dcastlem     Added support for general Public API
--                             (AMS_Registrants_PUB)
-- 18-MAR-2002    dcastlem     Cleaned up some code in B2B and added
--                             org party id as an out parameter
-- 05-APR-2002    dcastlem     Rewrote party_detail_rec_type to include all fields
-- 11-dec-2002    soagrawa     Modified get_party_id to call List Import's v2 apis for create_customer
-- 31-jan-2003    soagrawa     Get_Event_det : Fixed P1 bug# 2779298 - canot register for CSCH of type events
-- 11-feb-2003    soagrawa     Modified call to create_customer_API , now passing web_rec as well
-- 07-jan-2004    soagrawa     Fixed bug# 2836598 about duplicate error msgs
-- 12-Aug-2004    sikalyan     TCA V2 API update
-- 13-Sep-2005    sikalyan     TCA Mandate  Created_by_module
-- 28-Sep-2005    vmodur       More fixes for Created_By_Module
-- 08-Dec-2005    sikalyan  TCA Obsolete Columns BugFix 4665060
-- -------------------------------------------------------------------------------------------------------
--
--
-- This procedure is used to create party records in ams_party_sources table.
--
--


--
-- This procedure is used for existence checking for party of type person.
--
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


--=============================================================================
-- Start of Comment
--=============================================================================
--API Name
--      Write_log
--Type
--      Public
--Purpose
--      Used to write logs for this API
--Author
--      Dhirendra Singh
--=============================================================================
--
PROCEDURE Write_log  (p_api_name     IN VARCHAR2,
                      p_log_message  IN VARCHAR2)
IS
        l_api_name      VARCHAR(30);
        l_log_msg       VARCHAR(2000);
BEGIN
        l_api_name := p_api_name;
        l_log_msg  := p_log_message;

        IF (AMS_DEBUG_HIGH_ON)
        THEN AMS_Utility_PVT.debug_message(p_log_message);
        END IF;

        AMS_Utility_PVT.debug_message(
                                p_log_level     => g_log_level,
                                p_module_name   => G_FILE_NAME ||'.'||g_pkg_name||'.'||l_api_name||'.',
                                p_text          => p_log_message
                                );

--EXCEPTION
-- currently no exception handled

END Write_log;


PROCEDURE person_party_echeck(  p_party_id             IN OUT NOCOPY  NUMBER
                              , p_per_first_name       IN      VARCHAR2
                              , p_per_last_name        IN      VARCHAR2
                              , p_address1             IN      VARCHAR2
                              , p_country              IN      VARCHAR2
                              , p_email_address        IN      VARCHAR2
                              , p_ph_country_code      IN      VARCHAR2
                              , p_ph_area_code         IN      VARCHAR2
                              , p_ph_number            IN      VARCHAR2
                             );

--
-- This procedure is used for existence checking for party of type organization.
--
PROCEDURE party_echeck(
   --p_impt_list_header_id IN       NUMBER,
   p_party_id              IN OUT NOCOPY   NUMBER,
   p_org_name              IN       VARCHAR2,
   p_per_first_name        IN       VARCHAR2,
   p_per_last_name         IN       VARCHAR2,
   p_address1              IN       VARCHAR2,
   p_country               IN       VARCHAR2
                       );

--
-- This procedure is used for existence checking for contact.
--
--
PROCEDURE contact_echeck(
   --p_impt_list_header_id   IN       NUMBER,
   p_party_id              IN OUT NOCOPY   NUMBER,
   p_org_party_id          IN       NUMBER,
   p_per_first_name        IN       VARCHAR2,
   p_per_last_name         IN       VARCHAR2,
   p_phone_area_code       IN       VARCHAR2,
   p_phone_number          IN       VARCHAR2,
   p_phone_extension       IN       VARCHAR2,
   p_email_address         IN       VARCHAR2
                       );

--
-- This procedure is used for existence checking for address.
--
--
PROCEDURE address_echeck(
   --p_impt_list_header_id   IN       NUMBER,
   p_party_id              IN       NUMBER,
   p_location_id           IN OUT NOCOPY   NUMBER,
   p_address1              IN       VARCHAR2,
   p_city                  IN       VARCHAR2,
   p_pcode                 IN       VARCHAR2,
   p_country               IN       VARCHAR2
                       );

-- ---------------------------------------------------------
-- This concurrent program populates the data to TCA tables
-- from OMO table.
--



/*===========================================================*/
PROCEDURE find_a_party(
   p_api_version         IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_rec           IN  party_detail_rec_type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,
   x_party_id            OUT NOCOPY NUMBER
) IS

   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'find_a_party';

l_ret_status      varchar(1);
l_per_party_id    number;
l_party_key       varchar(1000);
l_cust_exists     varchar(1);
l_email_party_id  number;
l_phone_party_id  number;
l_count           number;
l_max_party_id    number;
l_party_tbl       hz_fuzzy_pub.PARTY_TBL_TYPE;
l_stat            NUMBER := 0;
l_party_id        NUMBER;

NO_EMAIL_FOUND  CONSTANT  NUMBER := 10;


CURSOR PARTY_REL_EXISTS(id_in in NUMBER) IS
SELECT subject_id FROM hz_relationships
WHERE relationship_id = id_in
AND subject_type = 'PERSON';


/*CURSOR LOCATION_EXISTS IS
SELECT party_site_id FROM hz_party_sites
WHERE party_id = x_org_party_id
AND location_id = x_location_id;

CURSOR PER_LOCATION_EXISTS IS
SELECT party_site_id FROM hz_party_sites
WHERE party_id = x_per_party_id
AND location_id = x_location_id;

CURSOR CHECK_PSITE_EXISTS IS
SELECT party_site_id FROM hz_party_sites
WHERE party_id = x_party_rel_party_id
  AND location_id = x_location_id;
*/
CURSOR phone_exists (party_id_in number, phone_number VARCHAR2, country_code in VARCHAR2, area_code in VARCHAR2,
                     extension in VARCHAR2 ) IS
SELECT 'Y' FROM hz_contact_points
WHERE contact_point_type          = 'PHONE'
AND phone_line_type             = 'GEN'
AND owner_table_name            = 'HZ_PARTIES'
AND owner_table_id              = party_id_in
AND phone_number                = phone_number
AND NVL(phone_country_code,'x') = NVL(country_code,'x')
AND NVL(phone_area_code,'x')    = NVL(area_code,'x')
AND NVL(phone_extension,'x')    = NVL(extension,'x');


   CURSOR email_exists (email_address_in VARCHAR2) IS
   SELECT owner_table_id
   FROM hz_contact_points
   WHERE contact_point_type   = 'EMAIL'
     AND owner_table_name     = 'HZ_PARTIES'
     AND upper(email_address) = upper(email_address_in);

cursor c_person_exists(id_in IN NUMBER) is
select 'Y' from hz_parties
where customer_key = l_party_key
and party_type   = 'PERSON'
and party_id = id_in;


l_count         number;
l_max_party_id  number;
l_per_party_tbl     hz_fuzzy_pub.PARTY_TBL_TYPE;

begin
/*
IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message('Start of Get Party Id');
END IF;
*/
Write_log(L_API_NAME, 'Start of Get Party Id');

   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;


   x_return_status := FND_API.g_ret_sts_success;
   if p_rec.last_name is not null and p_rec.first_name is not null then
      l_party_key := hz_fuzzy_pub.Generate_Key (
                        p_key_type => 'PERSON',
                        p_first_name => p_rec.first_name,
                        p_last_name  => p_rec.last_name
                     );
   else
      FND_MESSAGE.set_name('AMS', 'AMS_NO_NAME_PROVIDED');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   end if;

   if p_rec.EMAIL_ADDRESS is not null THEN
      open email_exists(p_rec.EMAIL_ADDRESS);
      fetch email_exists into l_per_party_id;
      if email_exists%NOTFOUND THEN
	/*
         IF (AMS_DEBUG_HIGH_ON) THEN
             AMS_Utility_PVT.Debug_Message('Email Not Found');
         END IF;
	*/
	 Write_log(L_API_NAME, 'Email Not Found');
         l_stat := NO_EMAIL_FOUND;
         close email_exists;
      else
         LOOP
            exit WHEN email_exists%NOTFOUND;
            open PARTY_REL_EXISTS(l_per_party_id);
            fetch PARTY_REL_EXISTS into l_party_id;
            IF PARTY_REL_EXISTS%NOTFOUND THEN
	/*
               IF (AMS_DEBUG_HIGH_ON) THEN
                   AMS_Utility_PVT.Debug_Message('Relation ship does not exist');
               END IF;
	*/
		Write_log(L_API_NAME, 'Relation ship does not exist');

               l_party_id  := l_per_party_id;
            END IF;
            open c_person_exists(l_party_id);
            fetch c_person_exists into l_cust_exists;
            close c_person_exists;
            if l_cust_exists = 'Y'
            then
               x_party_id := l_party_id;
/*
               IF (AMS_DEBUG_HIGH_ON) THEN

                   AMS_Utility_PVT.Debug_Message('Person exist');
               END IF;
*/
	       Write_log(L_API_NAME, 'Person exist');
            else
               x_party_id := null;
/*
               IF (AMS_DEBUG_HIGH_ON) THEN

                   AMS_Utility_PVT.Debug_Message('Person does not exist');
               END IF;
*/
	       Write_log(L_API_NAME, 'Person does not exist');
            end if;
            fetch email_exists into l_per_party_id;
         END LOOP;
         close email_exists;
      end if;
   else
      FND_MESSAGE.set_name('AMS', 'AMS_NO_EMAIL_PROVIDED');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   end if;
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN others THEN
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
  END find_a_party;

/*==========================================================*/

PROCEDURE create_registrant_party(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   p_rec               IN  party_detail_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   x_new_party_id      OUT NOCOPY NUMBER,
   x_new_org_party_id  OUT NOCOPY NUMBER

) IS

x_generate_party_number             VARCHAR2(1);
x_gen_contact_number                VARCHAR2(1);
x_gen_party_site_number             VARCHAR2(1);
x_party_number                      VARCHAR2(30);
x_organization_profile_id           number;
x_person_profile_id                 number;
x_org_party_id                      number;
x_tmp_var                           VARCHAR2(2000);
x_tmp_var1                          VARCHAR2(2000);
x_per_party_id                      number;
x_party_relationship_id             number;
x_contact_number                    VARCHAR2(30);
x_org_contact_id                    number;
x_party_rel_party_id                number;
x_location_id                       number;
x_Party_site_id                     number;
x_Party_site_use_id                 number;
x_party_site_number                 VARCHAR2(30);
x_contact_point_id                  number;
x_email_address                     varchar2(2000);
x_phone_country_code                VARCHAR2(10);
x_phone_area_code                   VARCHAR2(10);
x_phone_number                      VARCHAR2(40);
x_phone_extention                   VARCHAR2(20);
x_party_name                        VARCHAR2(400);
p_party_id                          number;
p_pr_party_id                       number;
l_lp_psite_id                       number;
x_hz_dup_check                      VARCHAR2(60);
l_overlay                           VARCHAR2(1);
l_phone_exists                      VARCHAR2(1);
l_email_exists                      VARCHAR2(1);
l_is_party_mapped                   VARCHAR2(1);

   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'create_registrant_party';


-- Cursor for B2B party type

-- Fixed bug#4654679
-- Replaced HZ_PARTY_RELATIONSHIPS with HZ_RELATIONSHIPS
-- Also, relaced PARTY_RELATIONSHIP_TYPE = 'CONTACT_OF'
-- with RELATIONSHIP_CODE = 'CONTACT_OF'
CURSOR PARTY_REL_EXISTS IS
SELECT party_id FROM hz_relationships
WHERE object_id = x_org_party_id
AND subject_id = x_per_party_id
AND relationship_code = 'CONTACT_OF';

CURSOR LOCATION_EXISTS IS
SELECT party_site_id FROM hz_party_sites
WHERE party_id = x_org_party_id
AND location_id = x_location_id;

CURSOR PER_LOCATION_EXISTS IS
SELECT party_site_id FROM hz_party_sites
WHERE party_id = x_per_party_id
AND location_id = x_location_id;

CURSOR CHECK_PSITE_EXISTS IS
SELECT party_site_id FROM hz_party_sites
WHERE party_id = x_party_rel_party_id
AND location_id = x_location_id;

CURSOR phone_exists (x_hz_party_id number) IS
SELECT 'Y' FROM hz_contact_points
WHERE contact_point_type          = 'PHONE'
AND phone_line_type             = 'GEN'
AND owner_table_name            = 'HZ_PARTIES'
AND owner_table_id              = x_hz_party_id
AND phone_number                = x_phone_number
AND NVL(phone_country_code,'x') = NVL(x_phone_country_code,'x')
AND NVL(phone_area_code,'x')    = NVL(x_phone_area_code,'x')
AND NVL(phone_extension,'x')    = NVL(x_phone_extention,'x');


CURSOR email_exists (x_hz_party_id number) IS
SELECT 'Y' FROM hz_contact_points
WHERE contact_point_type          = 'EMAIL'
AND owner_table_name            = 'HZ_PARTIES'
AND owner_table_id              = x_hz_party_id
AND email_address               = x_email_address;
/*
party_rec       hz_party_pub.party_rec_type;
org_rec         hz_party_pub.organization_rec_type;
person_rec      hz_party_pub.person_rec_type;
location_rec    hz_location_pub.location_rec_type;
psite_rec       hz_party_pub.party_site_rec_type;
psite_use_rec   hz_party_pub.party_site_use_rec_type;
cpoint_rec      hz_contact_point_pub.contact_points_rec_type;
email_rec       hz_contact_point_pub.email_rec_type;
phone_rec       hz_contact_point_pub.phone_rec_type;
ocon_rec        hz_party_pub.org_contact_rec_type;
edi_rec         hz_contact_point_pub.edi_rec_type;
telex_rec       hz_contact_point_pub.telex_rec_type;
web_rec         hz_contact_point_pub.web_rec_type;
*/
-- sikalyan bugFix TCA V2 Uptake

party_rec       hz_party_v2pub.party_rec_type;
org_rec         hz_party_v2pub.organization_rec_type;
person_rec      hz_party_v2pub.person_rec_type;
location_rec    hz_location_v2pub.location_rec_type;
psite_rec       hz_party_site_v2pub.party_site_rec_type;
psite_use_rec   hz_party_site_v2pub.party_site_use_rec_type;
cpoint_rec      hz_contact_point_v2pub.contact_point_rec_type;
email_rec       hz_contact_point_v2pub.email_rec_type;
phone_rec       hz_contact_point_v2pub.phone_rec_type;
ocon_rec        hz_party_contact_v2pub.org_contact_rec_type;
edi_rec         hz_contact_point_v2pub.edi_rec_type;
telex_rec       hz_contact_point_v2pub.telex_rec_type;
web_rec         hz_contact_point_v2pub.web_rec_type;

begin
/*
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.Debug_Message('Start');
   END IF;
*/
   Write_log(L_API_NAME, 'Start');

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

--   RETURN;
   x_return_status := FND_API.g_ret_sts_success;
   x_new_org_party_id := null;
   -- FND_FILE.PUT_LINE(FND_FILE.LOG,'TCA import Concurrent Program(+)');
   x_generate_party_number := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');
   x_gen_contact_number    := fnd_profile.value('HZ_GENERATE_CONTACT_NUMBER');
   x_gen_party_site_number := fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER');
   x_hz_dup_check          := fnd_profile.value('AMS_HZ_DEDUPE_RULE');
   if x_hz_dup_check <> 'Y' then
      x_hz_dup_check := 'N';
   end if;
/*
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.Debug_Message('Party Name: ' || nvl(p_rec.party_name,'Null'));
   END IF;
*/
	Write_log(L_API_NAME, 'Party Name: ' || nvl(p_rec.party_name,'Null'));

	 if p_rec.PARTY_NAME is NOT NULL then
      /*IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('In B2b');
      END IF;*/
      Write_log(L_API_NAME, 'In B2b');
      --org_rec.party_rec.orig_system_reference,
      org_rec.organization_name := p_rec.PARTY_NAME;
      org_rec.created_by_module := 'AMS_EVENT';
      -- created_by_module TCA Mandate

      person_rec.person_first_name := p_rec.first_name;
      person_rec.person_middle_name := p_rec.middle_name;
      person_rec.person_last_name := p_rec.last_name;
      person_rec.person_name_suffix := p_rec.name_suffix;
      person_rec.person_title := p_rec.title;
      -- BEST_TIME_CONTACT_BEGIN is obsolete in TCA V2
      --person_rec.best_time_contact_begin := p_rec.BEST_TIME_CONTACT_BEGIN;
      -- BEST_TIME_CONTACT_END is obsolete in TCA V2
      -- person_rec.best_time_contact_end := p_rec.BEST_TIME_CONTACT_END;
      person_rec.gender := p_rec.gender;
      person_rec.jgzz_fiscal_code := p_rec.jgzz_fiscal_code;
      -- TAX_NAME is obsolete in TCA V2 API
      -- person_rec.tax_name := p_rec.tax_name;
      person_rec.tax_reference := p_rec.tax_reference;
      person_rec.created_by_module := 'AMS_EVENT';
-- created_by_module TCA Mandate
      location_rec.country := p_rec.COUNTRY;
      location_rec.address1 := p_rec.ADDRESS1;
      location_rec.address2 := p_rec.ADDRESS2;
      location_rec.city := p_rec.CITY;
      location_rec.county := p_rec.COUNTRY;
      location_rec.state  := p_rec.STATE;
      location_rec.province := p_rec.PROVINCE;
      location_rec.postal_code := p_rec.POSTAL_CODE;
      -- Starting TCA V2 time_zone ceases to exist, replaced by timezone_id
      location_rec.timezone_id  := p_rec.timezone;
      location_rec.ADDRESS3 := p_rec.ADDRESS3;
      location_rec.ADDRESS4 := p_rec.ADDRESS4;
      location_rec.address_lines_phonetic := p_rec.address_line_phonetic;
      -- The APARTMENT_FLAG field is obsolete in TCA V2 API
      -- location_rec.APARTMENT_FLAG := p_rec.apt_flag;
  --    location_rec.PO_BOX_NUMBER := p_rec.po_box_no;
   --   location_rec.HOUSE_NUMBER := p_rec.HOUSE_NUMBER;
   --   location_rec.STREET_SUFFIX := p_rec.STREET_SUFFIX;
   -- BugFix 4665060
      -- The SECONDARY_SUFFIX_ELEMENT field is obeolste in TCA V2
      --location_rec.SECONDARY_SUFFIX_ELEMENT := p_rec.SECONDARY_SUFFIX_ELEMENT;
      --  location_rec.STREET := p_rec.STREET;
       -- The RURAL_ROUTE_TYPE field is obeolste in TCA V2
      --location_rec.RURAL_ROUTE_TYPE := p_rec.RURAL_ROUTE_TYPE;
      -- The RURAL_ROUTE_NUMBER field is obeolste in TCA V2
      --location_rec.RURAL_ROUTE_NUMBER := p_rec.rural_route_no;
  --    location_rec.STREET_NUMBER := p_rec.STREET_NUMBER;
 --     location_rec.FLOOR := p_rec.FLOOR;
 --     location_rec.SUITE := p_rec.SUITE;
      location_rec.POSTAL_PLUS4_CODE := p_rec.POSTAL_PLUS4_CODE;
      -- The 'OVERSEAS_ADDRESS_FLAG' is obsolete in TCA V2 API
      -- location_rec.OVERSEAS_ADDRESS_FLAG := p_rec.OVERSEAS_ADDRESS_FLAG;
      location_rec.created_by_module := 'AMS_EVENT';

      x_email_address := p_rec.EMAIL_ADDRESS;
      x_phone_country_code := p_rec.PHONE_COUNTRY_CODE;
      x_phone_area_code := p_rec.PHONE_AREA_CODE;
      x_phone_number := p_rec.PHONE_NUMBER;
      x_phone_extention := p_rec.phone_extension;

      ocon_rec.department := p_rec.DEPARTMENT;
      ocon_rec.job_title := p_rec.JOB_TITLE;
      ocon_rec.decision_maker_flag := p_rec.DECISION_MAKER_FLAG;
      ocon_rec.created_by_module := 'AMS_EVENT';


-- Creates Organization

      x_party_name     := org_rec.organization_name;
      x_org_party_id   := null;
      x_return_status  := null;
      x_msg_count       := null;
      x_msg_data       := null;

      if x_hz_dup_check = 'Y' then
         party_echeck(
            --p_impt_list_header_id => p_import_list_header_id,
            p_party_id            => x_org_party_id,
            p_org_name            => x_party_name,
            p_per_first_name      => NULL,
            p_per_last_name       => NULL,
            p_address1            => location_rec.address1,
            p_country             => location_rec.country
         );
      end if;
      /*IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('B2B: After Party_echeck: ' || x_party_name || ', ' || x_org_party_id);
      END IF;*/
      Write_log(L_API_NAME, 'B2B: After Party_echeck: ' || x_party_name || ', ' || x_org_party_id);
      if x_org_party_id is NULL then
         /*IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message('B2B: Organization is NULL');
         END IF;*/
	 Write_log(L_API_NAME, 'B2B: Organization is NULL');
         x_party_number := null;
         if x_generate_party_number = 'N' then
            select hz_party_number_s.nextval into x_party_number from dual;
         end if;
         select hz_parties_s.nextval into x_org_party_id from dual;
         org_rec.party_rec.party_number      := x_party_number;
         org_rec.party_rec.party_id          := x_org_party_id;
         org_rec.ceo_name                    := p_rec.ceo_name;
         org_rec.curr_fy_potential_revenue   := p_rec.current_fy_potential_rev;
         org_rec.next_fy_potential_revenue   := p_rec.next_fy_potential_rev;
         org_rec.duns_number_c               := p_rec.dun_no_c;
         org_rec.employees_total             := p_rec.employee_total;
         org_rec.fiscal_yearend_month        := p_rec.fy_end_month;
         org_rec.gsa_indicator_flag          := p_rec.gsa_indicator_flag;
         org_rec.jgzz_fiscal_code            := p_rec.jgzz_fiscal_code;
         org_rec.legal_status                := p_rec.org_legal_status;
         org_rec.line_of_business            := p_rec.line_of_business;
         org_rec.mission_statement           := p_rec.mission_statement;
         org_rec.organization_name_phonetic  := p_rec.org_name_phonetic;
         org_rec.sic_code                    := p_rec.sic_code;
         org_rec.sic_code_type               := p_rec.sic_code_type;
         -- org_rec.tax_name is obsolete in tca v2
         -- org_rec.tax_name                    := p_rec.tax_name;
         org_rec.tax_reference               := p_rec.tax_reference;
         org_rec.year_established            := p_rec.year_established;
	  org_rec.created_by_module := 'AMS_EVENT';

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

         /*
         if x_msg_count > 1 then
            FOR i IN 1..x_msg_count  LOOP
               x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
               x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
            END LOOP;
            x_msg_data := x_tmp_var1;
         end if;
         */
         if x_return_status <> 'S'
         then
            --errbuf := 'ORG -'||substr(org_rec.organization_name,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
            /*IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('B2B: Errpr creating an organization');
            END IF;*/
	    Write_log(L_API_NAME, 'B2B: Errpr creating an organization');
            AMS_UTILITY_PVT.error_message(  'ORGANIZATION_CREATE_FAILURE'
                                          , 'ROW'
                                          , 'ORG - ' || substr(org_rec.organization_name,1,25) || '- ERROR-' || substr(x_msg_data,1,180)
                                         );
            /*
            FND_MESSAGE.set_name('AMS', 'ORGANIZATION_CREATE_FAILURE');
            FND_MESSAGE.Set_Token('ROW', 'ORG - ' || substr(org_rec.organization_name,1,25) || '- ERROR-' || substr(x_msg_data,1,180));
            FND_MSG_PUB.add;
            */
            if x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            elsif x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            end if;
         end if;
         /*IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message('Created party: ' || x_org_party_id);
         END IF;*/
	 Write_log(L_API_NAME, 'Created party: ' || x_org_party_id);
      end if;    -- x_org_party_id is NULL
      x_new_org_party_id := x_org_party_id;
   -- Creates Person
      x_party_number   := null;
      x_return_status  := null;
      x_msg_count       := null;
      x_msg_data       := null;
      if x_hz_dup_check = 'Y'  then
         contact_echeck(
               --p_impt_list_header_id  => p_import_list_header_id,
               p_party_id             => x_per_party_id,
               p_org_party_id         => x_org_party_id,
               p_per_first_name       => person_rec.person_first_name,
               p_per_last_name        => person_rec.person_last_name,
               p_phone_area_code      => x_phone_area_code,
               p_phone_number         => x_phone_number,
               p_phone_extension      => x_phone_extention,
               p_email_address        => x_email_address );
      end if;
      /*IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message(' B2B: After Person' || x_per_party_id);
      END IF;*/
      Write_log(L_API_NAME, ' B2B: After Person' || x_per_party_id);

      x_new_party_id := x_per_party_id;
      if x_per_party_id is null then
         /*IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message('B2B: Creating Person' || person_rec.person_first_name);
         END IF;*/
	 Write_log(L_API_NAME, 'B2B: Creating Person' || person_rec.person_first_name);
         if person_rec.person_first_name is not null then
            if x_generate_party_number = 'N' then
               select hz_party_number_s.nextval into x_party_number from dual;
            end if;
            select hz_parties_s.nextval into x_per_party_id from dual;
            person_rec.party_rec.party_number := x_party_number;
            person_rec.party_rec.party_id     := x_per_party_id;
            x_return_status         := null;
            x_msg_count             := 0;
            x_msg_data              := null;

	hz_party_v2pub.create_person(
               'F',
               person_rec,
               x_return_status,
               x_msg_count,
               x_msg_data,
               x_per_party_id,
               x_party_number,
               x_person_profile_id
            );
            /*
            if x_msg_count > 1 then
               FOR i IN 1..x_msg_count  LOOP
                  x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
                  END LOOP;
               x_msg_data := x_tmp_var1;
            END IF;
            */

            if x_return_status <> 'S' then
               --errbuf := 'PERSON - '||substr(person_rec.person_first_name,1,20)||substr(person_rec.person_last_name,1,20)||'- ERROR-'||substr(x_msg_data,1,160);
               FND_MESSAGE.set_name('AMS', 'AMS_CREATE_PERSON_FAILED');
               FND_MESSAGE.Set_Token('ROW', 'PERSON - '||substr(person_rec.person_first_name,1,20)||substr(person_rec.person_last_name,1,20)||'- ERROR-'||substr(x_msg_data,1,160));
               FND_MSG_PUB.add;
               IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               end if;
            else
               x_new_party_id := x_per_party_id;

               /*IF (AMS_DEBUG_HIGH_ON) THEN

                   AMS_UTILITY_PVT.debug_message('B2B: Creating Person sucessful' || person_rec.person_first_name);
               END IF;*/
	       Write_log(L_API_NAME, 'B2B: Creating Person sucessful' || person_rec.person_first_name);

            end if;
         end if;
      end if;    -- x_per_party_id is NULL

   -- Creates Org Contact   ,party relationship and party for p rel
      x_party_number := null;
      x_contact_number := null;
      x_return_status  := null;
      x_msg_count       := null;
      x_msg_data       := null;

      if person_rec.person_first_name is not null then
         p_pr_party_id := null;
         open  PARTY_REL_EXISTS;
         fetch PARTY_REL_EXISTS into p_pr_party_id;
         close PARTY_REL_EXISTS;
         if p_pr_party_id is not null then
            x_party_rel_party_id := p_pr_party_id;
         end if;
         if p_pr_party_id is null then
            /*IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('B2B :Creating Org Contact' || p_pr_party_id);
            END IF;*/
	    Write_log(L_API_NAME, 'B2B :Creating Org Contact' || p_pr_party_id);

            Select hz_org_contacts_s.nextval into x_org_contact_id from dual;
            if x_generate_party_number = 'N' then
               select hz_party_number_s.nextval into x_party_number from dual;
            end if;

            ocon_rec.party_rel_rec.subject_id               := x_per_party_id;
            ocon_rec.party_rel_rec.object_id                := x_org_party_id;
            ocon_rec.org_contact_id                         := x_org_contact_id;
            ocon_rec.orig_system_reference                  := x_org_contact_id;
            ocon_rec.party_rel_rec.relationship_type  := 'CONTACT_OF';
            -- directional_flag is obsolete in TCA V2
            --ocon_rec.party_rel_rec.directional_flag         := 'Y';
            ocon_rec.party_rel_rec.start_date               := sysdate;
	   ocon_rec.created_by_module := 'AMS_EVENT';
            IF x_generate_party_number = 'N' THEN
               ocon_rec.party_rel_rec.party_rec.party_number := x_party_number;
            END IF;
            IF x_gen_contact_number = 'N' THEN
               select hz_contact_numbers_s.nextval into x_contact_number from dual;
            end if;
            ocon_rec.contact_number                   := x_contact_number;
            -- Obsolete in TCA V2 ocon_rec.status
            -- ocon_rec.status     := 'A';
            ocon_rec.party_rel_rec.status     := 'A';
            /*IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('B2B: Creating org contact' || person_rec.person_first_name);
            END IF;*/
	    Write_log(L_API_NAME, 'B2B: Creating org contact' || person_rec.person_first_name);


          hz_party_contact_v2pub.create_org_contact(
               'F',
               ocon_rec,
               x_return_status,
               x_msg_count,
               x_msg_data,
               x_org_contact_id,
               x_party_relationship_id,
               x_party_rel_party_id,
               x_party_number);


/*
            if x_msg_count > 1 then
               FOR i IN 1..x_msg_count  LOOP
                  x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
               END LOOP;
               x_msg_data := x_tmp_var1;
            END IF;
*/

            if x_return_status <> 'S' then
               --errbuf := 'ORG CONTACT - '||substr(person_rec.person_first_name,1,20)||substr(person_rec.person_last_name,1,20)||'- ERROR-'||substr(x_msg_data,1,160);
               FND_MESSAGE.set_name('AMS', 'AMS_ORG_CONTACT_FAILURE');
               FND_MESSAGE.Set_Token('ROW', 'ORG CONTACT - '||substr(person_rec.person_first_name,1,20)||substr(person_rec.person_last_name,1,20)||'- ERROR-'||substr(x_msg_data,1,160));
               FND_MSG_PUB.add;
               IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               end if;
            end if;
         end if;     -- if p_pr_party_id is null
      end if;     -- if person_rec.person_first_name is not null

      if x_hz_dup_check = 'Y' then
         address_echeck(
            --p_impt_list_header_id   => p_import_list_header_id,
            p_party_id              => x_org_party_id,
            p_location_id           => x_location_id,
            p_address1              => location_rec.address1,
            p_city                  => location_rec.city,
            p_pcode                 => location_rec.postal_code,
            p_country               => location_rec.country
         );
      end if;
      if x_location_id is null and x_org_party_id is not null then
         if location_rec.address1 is not NULL then
            -- Create Location
            /*IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('B2B:Creating Location' || location_rec.address1);
            END IF;*/
	    Write_log(L_API_NAME, 'B2B:Creating Location' || location_rec.address1);
            x_return_status  := null;
            x_msg_count       := null;
            x_msg_data       := null;
            select hr_locations_s.nextval into x_location_id from dual;
            location_rec.location_id           := X_location_Id;
            location_rec.orig_system_reference := x_location_id ;
	     location_rec.created_by_module := 'AMS_EVENT';


            hz_location_v2pub.create_location(
               'F',
               location_rec,
               x_return_status,
               x_msg_count,
               x_msg_data,
               x_location_id
            );
/*
            if x_msg_count > 1 then
               FOR i IN 1..x_msg_count  LOOP
                  x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
               END LOOP;
               x_msg_data := x_tmp_var1;
            END IF;
*/
            if x_return_status <> 'S' then
               --errbuf := 'LOCATION - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
               FND_MESSAGE.set_name('AMS', 'AMS_LOCATION_CREATE_FAILURE');
               FND_MESSAGE.Set_Token('ROW', 'LOCATION - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
               FND_MSG_PUB.add;
               IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               end if;
            end if;
         end if; -- if location_rec.address1 is not NULL
      end if; -- x_location_id is null;

      l_lp_psite_id := null;
      open LOCATION_EXISTS;
      fetch LOCATION_EXISTS into l_lp_psite_id;
      close LOCATION_EXISTS;
      if l_lp_psite_id is null and x_org_party_id is not null and x_location_id is not null then
         -- Create Party Site
         /*IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message('B2B:Creating Party_site' || l_lp_psite_id);
         END IF;*/
	 Write_log(L_API_NAME, 'B2B:Creating Party_site' || l_lp_psite_id);
         x_return_status  := null;
         x_msg_count      := null;
         x_msg_data       := null;
         x_party_site_number := null;
         select hz_party_sites_s.nextval into x_party_site_id from dual;
         if x_gen_party_site_number = 'N' then
            select hz_party_site_number_s.nextval into x_party_site_number from dual;
         end if;

         psite_rec.party_site_id            := x_party_site_id;
         psite_rec.party_id                 := x_org_party_id;
         psite_rec.location_id              := x_location_id;
         psite_rec.party_site_number        := x_party_site_number;
         psite_rec.orig_system_reference    := x_party_site_id;
         psite_rec.identifying_address_flag := p_rec.identifying_address_flag;
--         psite_rec.site_use_code            := p_rec.site_use_code;
         --  psite_rec.identifying_address_flag := 'Y';
         psite_rec.status                   := 'A';
	 psite_rec.created_by_module := 'AMS_EVENT';


     hz_party_site_v2pub.create_party_site(
               p_init_msg_list => p_init_msg_list,
               p_party_site_rec => psite_rec,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               x_party_site_id => x_party_site_id,
               x_party_site_number => x_party_site_number
               );


/*
         if x_msg_count > 1 then
            FOR i IN 1..x_msg_count  LOOP
               x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
               x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
            END LOOP;
            x_msg_data := x_tmp_var1;
         END IF;
*/
         if x_return_status <> 'S' then
            --errbuf := 'PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
            FND_MESSAGE.set_name('AMS', 'AMS_PART_SITE_CREATION_FAILURE');
            FND_MESSAGE.Set_Token('ROW','PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
            FND_MSG_PUB.add;
            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            end if;
         end if;

         if (p_rec.site_use_code is not null)
         then
            select hz_party_site_uses_s.nextval into x_party_site_use_id from dual;

            psite_use_rec.site_use_type := p_rec.site_use_code;
            psite_use_rec.party_site_id := x_party_site_id;
            psite_use_rec.party_site_use_id := x_party_site_use_id;
	    psite_use_rec.created_by_module := 'AMS_EVENT';


  hz_party_site_v2pub.create_party_site_use(
                  p_init_msg_list => p_init_msg_list,
                  p_party_site_use_rec => psite_use_rec,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  x_party_site_use_id => x_party_site_use_id
                  );

   /*
            if x_msg_count > 1 then
               FOR i IN 1..x_msg_count  LOOP
                  x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
               END LOOP;
               x_msg_data := x_tmp_var1;
            END IF;
   */
            if x_return_status <> 'S' then
               --errbuf := 'PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
               FND_MESSAGE.set_name('AMS', 'AMS_PART_SITE_CREATION_FAILURE');
               FND_MESSAGE.Set_Token('ROW','PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
               FND_MSG_PUB.add;
               IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               end if;
            end if;
         end if;  -- site use code
      end if;         -- if l_lp_psite_id is null then

-- ****************************************************
   -- Creating party_site for Contacts.

      if person_rec.person_first_name is not null and x_party_rel_party_id is not null then
         if location_rec.address1 is not NULL and  x_location_id is not null then
            l_lp_psite_id := null;
            open CHECK_PSITE_EXISTS;
            fetch CHECK_PSITE_EXISTS into l_lp_psite_id;
            close CHECK_PSITE_EXISTS;
            if l_lp_psite_id is null then
               -- Create Party Site

               /*IF (AMS_DEBUG_HIGH_ON) THEN

                   AMS_UTILITY_PVT.debug_message('B2B:Creating Party_site for contact ' || l_lp_psite_id);
               END IF;*/
	       Write_log(L_API_NAME, 'B2B:Creating Party_site for contact ' || l_lp_psite_id);

               x_return_status  := null;
               x_msg_count      := null;
               x_msg_data       := null;
               x_party_site_number := null;
               select hz_party_sites_s.nextval into x_party_site_id from dual;
               if x_gen_party_site_number = 'N' then
                  select hz_party_site_number_s.nextval into x_party_site_number from dual;
               end if;

               psite_rec.party_site_id            := x_party_site_id;
               psite_rec.party_id                 := x_party_rel_party_id;
               psite_rec.location_id              := x_location_id;
               psite_rec.party_site_number        := x_party_site_number;
               psite_rec.orig_system_reference    := x_party_site_id;
               psite_rec.identifying_address_flag := p_rec.identifying_address_flag;
--               psite_rec.site_use_code            := p_rec.site_use_code;
               --     psite_rec.identifying_address_flag := 'Y';
               psite_rec.status                   := 'A';
	       psite_rec.created_by_module := 'AMS_EVENT';

     hz_party_site_v2pub.create_party_site(
               p_init_msg_list => p_init_msg_list,
               p_party_site_rec => psite_rec,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               x_party_site_id => x_party_site_id,
               x_party_site_number => x_party_site_number
               );

/*
               if x_msg_count > 1 then
                  FOR i IN 1..x_msg_count  LOOP
                     x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                     x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
                  END LOOP;
                  x_msg_data := x_tmp_var1;
               END IF;
*/
               if x_return_status <> 'S' then
                  --errbuf := 'CONT PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
                  FND_MESSAGE.set_name('AMS', 'AMS_PSITE_CONTACT_CREATE_FAILURE');
                  FND_MESSAGE.Set_Token('ROW','CONT PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
                  FND_MSG_PUB.add;
                  IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  end if;
               end if;

               if (p_rec.site_use_code is not null)
               then
                  select hz_party_site_uses_s.nextval into x_party_site_use_id from dual;

                  psite_use_rec.site_use_type := p_rec.site_use_code;
                  psite_use_rec.party_site_id := x_party_site_id;
                  psite_use_rec.party_site_use_id := x_party_site_use_id;
		  psite_use_rec.created_by_module := 'AMS_EVENT';


  hz_party_site_v2pub.create_party_site_use(
                  p_init_msg_list => p_init_msg_list,
                  p_party_site_use_rec => psite_use_rec,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  x_party_site_use_id => x_party_site_use_id);

         /*
                  if x_msg_count > 1 then
                     FOR i IN 1..x_msg_count  LOOP
                        x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                        x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
                     END LOOP;
                     x_msg_data := x_tmp_var1;
                  END IF;
         */
                  if x_return_status <> 'S' then
                     --errbuf := 'PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
                     FND_MESSAGE.set_name('AMS', 'AMS_PART_SITE_CREATION_FAILURE');
                     FND_MESSAGE.Set_Token('ROW','PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
                     FND_MSG_PUB.add;
                     IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                     end if;
                  end if;
               end if;  -- site use code

            end if; -- lp_psite_id

         end if;
      end if; --person_rec.person_first_name is not null and x_party_rel_party_id is not null

-- ****************************************************

-- Create contact points  Phone

      if x_phone_number is not NULL and x_party_rel_party_id is not null then
         SELECT  hz_contact_points_s.nextval into x_contact_point_id from dual;
         x_return_status  := null;
         x_msg_count       := null;
         x_msg_data       := null;
         cpoint_rec.contact_point_id       := x_contact_point_id;
         cpoint_rec.contact_point_type     := 'PHONE';
         cpoint_rec.status                 := 'A';
         cpoint_rec.owner_table_name       := 'HZ_PARTIES';
         cpoint_rec.owner_table_id         := x_party_rel_party_id;
         -- cpoint_rec.primary_flag           := 'Y';
         cpoint_rec.orig_system_reference  := x_contact_point_id;
	 cpoint_rec.created_by_module := 'AMS_EVENT';
         phone_rec.phone_line_type         := 'GEN';
         phone_rec.phone_number            := x_phone_number;
         phone_rec.phone_country_code      := x_phone_country_code;
         phone_rec.phone_area_code         := x_phone_area_code;
         phone_rec.phone_extension         := x_phone_extention;

         l_phone_exists := NULL;
         open phone_exists(x_party_rel_party_id);
         fetch phone_exists into l_phone_exists;
         close phone_exists;
         if l_phone_exists is NULL then
            /*IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('B2B:Creating PPhone contact ' || x_party_rel_party_id);
            END IF;*/
	    Write_log(L_API_NAME, 'B2B:Creating PPhone contact ' || x_party_rel_party_id);
            hz_contact_point_v2pub.create_contact_point(
               'F',
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
/*
            if x_msg_count > 1 then
               FOR i IN 1..x_msg_count  LOOP
                  x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
               END LOOP;
               x_msg_data := x_tmp_var1;
            END IF;
*/

            if x_return_status <> 'S' then
               --errbuf := 'PHONE - '||substr(x_phone_number,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
               FND_MESSAGE.set_name('AMS', 'AMS_CONTACT_PHONE_ERROR');
               FND_MESSAGE.Set_Token('ROW','PHONE - '||substr(x_phone_number,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
               FND_MSG_PUB.add;
               IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               end if;
            end if;
         end if; -- l_phone_exists is NULL then
      end if; -- x_phone_number

-- Create contact points Email

      if x_email_address is not NULL  and x_party_rel_party_id is not null  then
         SELECT  hz_contact_points_s.nextval into x_contact_point_id from dual;

         x_return_status  := null;
         x_msg_count       := null;
         x_msg_data       := null;
         cpoint_rec.contact_point_id       := x_contact_point_id;
         cpoint_rec.contact_point_type     := 'EMAIL';
         cpoint_rec.status                 := 'A';
         cpoint_rec.owner_table_name       := 'HZ_PARTIES';
         cpoint_rec.owner_table_id         := x_party_rel_party_id;
            -- cpoint_rec.primary_flag           := 'Y';
          cpoint_rec.orig_system_reference  := x_contact_point_id;
	  cpoint_rec.created_by_module := 'AMS_EVENT';

         email_rec.email_address := x_email_address;
         l_email_exists := NULL;
         open email_exists(x_party_rel_party_id);
         fetch email_exists into l_email_exists;
         close email_exists;
         if l_email_exists is NULL then
            /*IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('B2B:Creating Email contact ' || x_party_rel_party_id);
            END IF;*/
	    Write_log(L_API_NAME, 'B2B:Creating Email contact ' || x_party_rel_party_id);

            hz_contact_point_v2pub.create_contact_point(
                'F',
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
/*
            if x_msg_count > 1 then
               FOR i IN 1..x_msg_count  LOOP
                  x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
                END LOOP;
               x_msg_data := x_tmp_var1;
            END IF;
*/
            if x_return_status <> 'S' then
               --errbuf := 'EMAIL - '||substr(x_email_address,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
               FND_MESSAGE.set_name('AMS', 'AMS_CONTACT_EMAIL_ERROR');
               FND_MESSAGE.Set_Token('ROW','EMAIL - '||substr(x_email_address,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
               FND_MSG_PUB.add;
               IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               end if;
            end if;
         end if; -- l_email_exists is NULL then
      end if; -- x_email_address

   else

      /*IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('In B2c  ');
      END IF;*/
      Write_log(L_API_NAME, 'In B2c  ');

      person_rec.person_first_name := p_rec.first_name;
      person_rec.person_middle_name := p_rec.middle_name;
      person_rec.person_last_name := p_rec.last_name;
      person_rec.person_name_suffix := p_rec.name_suffix;
      person_rec.person_title := p_rec.title;
      -- best_time_contact_begin and best_time_contact_end are obsolete in TCA V2
      --person_rec.best_time_contact_begin := p_rec.BEST_TIME_CONTACT_BEGIN;
      --person_rec.best_time_contact_end := p_rec.BEST_TIME_CONTACT_END;
      person_rec.gender := p_rec.gender;
      person_rec.jgzz_fiscal_code := p_rec.jgzz_fiscal_code;
      -- tax_name is obsolete
      --person_rec.tax_name := p_rec.tax_name;
      person_rec.tax_reference := p_rec.tax_reference;
      person_rec.created_by_module := 'AMS_EVENT';

--      person_rec.pre_name_adjunct := p_rec.PRE_NAME_ADJUNCT ;
--      person_rec.party_rec.SALUTATION := p_rec.SALUTATION;

      location_rec.country := p_rec.COUNTRY;
      location_rec.address1 := p_rec.ADDRESS1;
      location_rec.address2 := p_rec.ADDRESS2;
      location_rec.city := p_rec.CITY;
      location_rec.county := p_rec.COUNTRY;
      location_rec.state  := p_rec.STATE;
      location_rec.province := p_rec.PROVINCE;
      location_rec.postal_code := p_rec.POSTAL_CODE;
      -- time_zone is obsolete in TCA V2, its replaced by timezone_id
      location_rec.timezone_id := p_rec.timezone;
      location_rec.ADDRESS3 := p_rec.ADDRESS3;
      location_rec.ADDRESS4 := p_rec.ADDRESS4;
      location_rec.address_lines_phonetic := p_rec.address_line_phonetic;
      -- APARTMENT_FLAG is obsolete in TCA V2
      -- location_rec.APARTMENT_FLAG := p_rec.apt_flag;
  --    location_rec.PO_BOX_NUMBER := p_rec.po_box_no;
 --     location_rec.HOUSE_NUMBER := p_rec.HOUSE_NUMBER;
--      location_rec.STREET_SUFFIX := p_rec.STREET_SUFFIX;
      -- SECONDARY_SUFFIX_ELEMENT is obsolete in TCA V2
      -- location_rec.SECONDARY_SUFFIX_ELEMENT := p_rec.SECONDARY_SUFFIX_ELEMENT;
   --  location_rec.STREET := p_rec.STREET;
      -- RURAL_ROUTE_TYPE is obsolete in TCA V2
      -- location_rec.RURAL_ROUTE_TYPE := p_rec.RURAL_ROUTE_TYPE;
      -- RURAL_ROUTE_NUMBER is obsolete in TCA V2
      -- location_rec.RURAL_ROUTE_NUMBER := p_rec.rural_route_no;
   --   location_rec.STREET_NUMBER := p_rec.STREET_NUMBER;
--      location_rec.FLOOR := p_rec.FLOOR;
   --   location_rec.SUITE := p_rec.SUITE;
      location_rec.POSTAL_PLUS4_CODE := p_rec.POSTAL_PLUS4_CODE;
      -- OVERSEAS_ADDRESS_FLAG is obsolete in TCA V2
      --location_rec.OVERSEAS_ADDRESS_FLAG := p_rec.OVERSEAS_ADDRESS_FLAG;
      location_rec.created_by_module := 'AMS_EVENT';

      x_email_address := p_rec.EMAIL_ADDRESS;
      x_phone_country_code := p_rec.PHONE_COUNTRY_CODE;
      x_phone_area_code := p_rec.PHONE_AREA_CODE;
      x_phone_number := p_rec.PHONE_NUMBER;
      x_phone_extention := p_rec.phone_extension;

-- Creates Person
      --i_import_source_line_id := person_rec.party_rec.orig_system_reference;
      x_return_status     := null;
      x_msg_count       := null;
      x_msg_data       := null;
      x_party_number := null;

      if (x_hz_dup_check = 'Y')
      then
      /*
         party_echeck(
         --p_impt_list_header_id => p_import_list_header_id,
         p_party_id            => x_per_party_id,
         p_org_name            => NULL,
         p_per_first_name      => person_rec.person_first_name,
         p_per_last_name       => person_rec.person_last_name,
         p_address1            => location_rec.address1,
         p_country             => location_rec.country);
      */
         person_party_echeck(  p_party_id => x_per_party_id
                             , p_per_first_name => person_rec.person_first_name
                             , p_per_last_name => person_rec.person_last_name
                             , p_address1 => location_rec.address1
                             , p_country => location_rec.country
                             , p_email_address => x_email_address
                             , p_ph_country_code => x_phone_country_code
                             , p_ph_area_code => x_phone_area_code
                             , p_ph_number => x_phone_number
                            );

      end if;
      x_new_party_id := x_per_party_id;
      /*IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('B2c:Party_id exists ' || x_per_party_id);
      END IF;*/
      Write_log(L_API_NAME, 'B2c:Party_id exists ' || x_per_party_id);

      if x_per_party_id is null then
         if x_generate_party_number = 'N' then
            select hz_party_number_s.nextval into x_party_number from dual;
         end if;
         select hz_parties_s.nextval into x_per_party_id from dual;

         person_rec.party_rec.party_number := x_party_number;
         person_rec.party_rec.party_id     := x_per_party_id;
         x_return_status := null;
         x_msg_count     := 0;
         x_msg_data      := null;
         /*IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message('B2c:creating Person Party_id  ' || x_per_party_id);
         END IF;*/
	 Write_log(L_API_NAME, 'B2c:creating Person Party_id  ' || x_per_party_id);

         hz_party_v2pub.create_person(
            'F',
            person_rec,
            x_return_status,
            x_msg_count,
            x_msg_data,
            x_per_party_id,
            x_party_number,
            x_person_profile_id);
/*
         if x_msg_count > 1 then
            FOR i IN 1..x_msg_count  LOOP
               x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
               x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
            END LOOP;
            x_msg_data := x_tmp_var1;
         END IF;
*/

         if x_return_status <> 'S' then
            --errbuf := 'PERSON - '||substr(person_rec.person_first_name,1,20)||substr(person_rec.person_last_name,1,20)||'- ERROR-'||substr(x_msg_data,1,160);
            FND_MESSAGE.set_name('AMS', 'AMS_PERSON_ERROR');
            FND_MESSAGE.Set_Token('ROW','PERSON - '||substr(person_rec.person_first_name,1,20)||substr(person_rec.person_last_name,1,20)||'- ERROR-'||substr(x_msg_data,1,160));
            FND_MSG_PUB.add;
            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            end if;
         else
            x_new_party_id := x_per_party_id;
            /*IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('B2B: Creating Person sucessful' || person_rec.person_first_name);
            END IF;*/
	    Write_log(L_API_NAME, 'B2B: Creating Person sucessful' || person_rec.person_first_name);
         end if;
      end if; --  x_per_party_id is null then


      if x_hz_dup_check = 'Y' then
         address_echeck(
            --p_impt_list_header_id   => p_import_list_header_id,
            p_party_id              => x_per_party_id,
            p_location_id           => x_location_id,
            p_address1              => location_rec.address1,
            p_city                  => location_rec.city,
            p_pcode                 => location_rec.postal_code,
            p_country               => location_rec.country
         );
      end if;

      if x_location_id is null and x_per_party_id is not null then
         if location_rec.address1 is not NULL then
            -- Create Location
            x_return_status     := null;
            x_msg_count       := null;
            x_msg_data       := null;
            select hr_locations_s.nextval into x_location_id from dual;
            location_rec.location_id           := X_location_Id;
            location_rec.orig_system_reference := x_location_id ;
            /*IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('B2c:crating Location ' || location_rec.address1);
            END IF;*/
	    Write_log(L_API_NAME, 'B2c:crating Location ' || location_rec.address1);

            hz_location_v2pub.create_location(
               'F',
               location_rec,
               x_return_status,
               x_msg_count,
               x_msg_data,
               x_location_id
            );

/*
            if x_msg_count > 1 then
               FOR i IN 1..x_msg_count  LOOP
                  x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
               END LOOP;
               x_msg_data := x_tmp_var1;
            END IF;
*/

            if x_return_status <> 'S' then
               --errbuf := 'LOCATION - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
               FND_MESSAGE.set_name('AMS', 'AMS_LOCATION_ERROR');
               FND_MESSAGE.Set_Token('ROW','LOCATION - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
               FND_MSG_PUB.add;
               IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               end if;
            end if;

         end if; -- if location_rec.address1 is not NULL
      end if; --  x_location_id is null then

      l_lp_psite_id := null;
      open PER_LOCATION_EXISTS;
      fetch PER_LOCATION_EXISTS into l_lp_psite_id;
      close PER_LOCATION_EXISTS;
      if l_lp_psite_id is null and x_per_party_id is not null and x_location_id is not null then
         -- Create Party Site

         /*IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message('B2c:crating party_site ' || l_lp_psite_id);
         END IF;*/
	 Write_log(L_API_NAME, 'B2c:crating party_site ' || l_lp_psite_id);

         x_return_status  := null;
         x_msg_count      := null;
         x_msg_data       := null;
         x_party_site_number := null;
         select hz_party_sites_s.nextval into x_party_site_id from dual;
         if x_gen_party_site_number = 'N' then
            select hz_party_site_number_s.nextval into x_party_site_number from dual;
         end if;

         psite_rec.party_site_id            := x_party_site_id;
         psite_rec.party_id                 := x_per_party_id;
         psite_rec.location_id              := x_location_id;
         psite_rec.party_site_number        := x_party_site_number;
         psite_rec.orig_system_reference    := x_party_site_id;
         psite_rec.identifying_address_flag := p_rec.identifying_address_flag;
--         psite_rec.site_use_code            := p_rec.site_use_code;
         -- psite_rec.identifying_address_flag := 'Y';
         psite_rec.status                   := 'A';
        psite_rec.created_by_module := 'AMS_EVENT';


/*
         IF (AMS_DEBUG_HIGH_ON) THEN



             AMS_Utility_PVT.Debug_Message('Attempting to create a Party Site');

         END IF;
*/

	 Write_log(L_API_NAME, 'Attempting to create a Party Site');


     hz_party_site_v2pub.create_party_site(
               p_init_msg_list => p_init_msg_list,
               p_party_site_rec => psite_rec,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               x_party_site_id => x_party_site_id,
               x_party_site_number => x_party_site_number
               );

/*
         IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_Utility_PVT.Debug_Message('Party Site return status: ' || x_return_status);
         END IF;
*/
	 Write_log(L_API_NAME, 'Party Site return status: ' || x_return_status);

/*
         if x_msg_count > 1 then
            FOR i IN 1..x_msg_count  LOOP
               x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
               x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
            END LOOP;
            x_msg_data := x_tmp_var1;
         END IF;

        /* IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_Utility_PVT.Debug_Message('Changed Party Site messages');
         END IF;*/

	 Write_log(L_API_NAME, 'Changed Party Site messages');

         if x_return_status <> 'S' then

            /*IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_Utility_PVT.Debug_Message('Error Creating Site');
            END IF;*/

	    Write_log(L_API_NAME, 'Error Creating Site');


            --errbuf := 'PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
            FND_MESSAGE.set_name('AMS', 'AMS_PSITE_ERROR');
            FND_MESSAGE.Set_Token('ROW','PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
            FND_MSG_PUB.add;
            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            end if;
         end if;
         if (p_rec.site_use_code is not null)
         then
            select hz_party_site_uses_s.nextval into x_party_site_use_id from dual;

            psite_use_rec.site_use_type := p_rec.site_use_code;
            psite_use_rec.party_site_id := x_party_site_id;
            psite_use_rec.party_site_use_id := x_party_site_use_id;

            hz_party_site_v2pub.create_party_site_use(
                  p_init_msg_list => p_init_msg_list,
                  p_party_site_use_rec => psite_use_rec,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  x_party_site_use_id => x_party_site_use_id);

   /*
            if x_msg_count > 1 then
               FOR i IN 1..x_msg_count  LOOP
                  x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
               END LOOP;
               x_msg_data := x_tmp_var1;
            END IF;
   */
            if x_return_status <> 'S' then
               --errbuf := 'PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
               FND_MESSAGE.set_name('AMS', 'AMS_PART_SITE_CREATION_FAILURE');
               FND_MESSAGE.Set_Token('ROW','PSITE - '||substr(location_rec.address1,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
               FND_MSG_PUB.add;
               IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               end if;
            end if;
         end if;  -- site use code

      end if;  --  if l_lp_psite_id is null then

-- ***************************************************8
-- Create contact points  Phone

      if x_phone_number is not NULL and x_per_party_id is not null then
         SELECT  hz_contact_points_s.nextval into x_contact_point_id from dual;

         x_return_status     := null;
         x_msg_count       := null;
         x_msg_data       := null;
         cpoint_rec.contact_point_id       := x_contact_point_id;
         cpoint_rec.contact_point_type     := 'PHONE';
         cpoint_rec.status                 := 'A';
         cpoint_rec.owner_table_name       := 'HZ_PARTIES';
         cpoint_rec.owner_table_id         := x_per_party_id;
         -- cpoint_rec.primary_flag           := 'Y';
         cpoint_rec.orig_system_reference  := x_contact_point_id;
	 cpoint_rec.created_by_module := 'AMS_EVENT';
         phone_rec.phone_line_type         := 'GEN';
         phone_rec.phone_number            := x_phone_number;
         phone_rec.phone_country_code      := x_phone_country_code;
         phone_rec.phone_area_code         := x_phone_area_code;
         phone_rec.phone_extension         := x_phone_extention;

         l_phone_exists := NULL;
         open phone_exists(x_per_party_id);
         fetch phone_exists into l_phone_exists;
         close phone_exists;
         if l_phone_exists is NULL then
            /*IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('B2c:crating contact - Phone ' || x_per_party_id);
            END IF;*/
	    Write_log(L_API_NAME, 'B2c:crating contact - Phone ' || x_per_party_id);

            hz_contact_point_v2pub.create_contact_point(
               'F',
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
/*
            if x_msg_count > 1 then
               FOR i IN 1..x_msg_count  LOOP
                  x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
               END LOOP;
               x_msg_data := x_tmp_var1;
            END IF;
*/
            if x_return_status <> 'S' then
               --errbuf := 'PHONE - '||substr(x_phone_number,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
               FND_MESSAGE.set_name('AMS', 'AMS_CONTACT_PHONE_ERROR');
               FND_MESSAGE.Set_Token('ROW','PHONE - '||substr(x_phone_number,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
               FND_MSG_PUB.add;
               IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               end if;
            end if;
         end if; -- l_phone_exists is NULL then
      end if; -- x_phone_number




-- Create contact points Email

      if x_email_address is not NULL  and x_per_party_id is not null then
         SELECT  hz_contact_points_s.nextval into x_contact_point_id from dual;

         x_return_status  := null;
         x_msg_count       := null;
         x_msg_data       := null;
         cpoint_rec.contact_point_id       := x_contact_point_id;
         cpoint_rec.contact_point_type     := 'EMAIL';
         cpoint_rec.status                 := 'A';
         cpoint_rec.owner_table_name       := 'HZ_PARTIES';
         cpoint_rec.owner_table_id         := x_per_party_id;
         -- cpoint_rec.primary_flag           := 'Y';
         cpoint_rec.orig_system_reference  := x_contact_point_id;
	 cpoint_rec.created_by_module := 'AMS_EVENT';

         email_rec.email_address           := x_email_address;
         l_email_exists := NULL;
         open email_exists(x_per_party_id);
         fetch email_exists into l_email_exists;
         close email_exists;
         if l_email_exists is NULL then
            /*IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('B2c:crating contact - Email ' || x_per_party_id);
            END IF;*/
	    Write_log(L_API_NAME,'B2c:crating contact - Email ' || x_per_party_id);
            hz_contact_point_v2pub.create_contact_point(
               'F',
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

/*
            if x_msg_count > 1 then
               FOR i IN 1..x_msg_count  LOOP
                  x_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  x_tmp_var1 := x_tmp_var1 || ' '|| x_tmp_var;
               END LOOP;
               x_msg_data := x_tmp_var1;
            END IF;
*/
            if x_return_status <> 'S' then
               --errbuf := 'EMAIL - '||substr(x_email_address,1,25)||'- ERROR-'||substr(x_msg_data,1,180);
               FND_MESSAGE.set_name('AMS', 'AMS_CONTACT_EMAIL_ERROR');
               FND_MESSAGE.Set_Token('ROW','EMAIL - '||substr(x_email_address,1,25)||'- ERROR-'||substr(x_msg_data,1,180));
               FND_MSG_PUB.add;
               IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               end if;
            end if;
         end if; -- l_email_exists is NULL then
      end if; -- x_email_address
   end if; --  b2c
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


end create_registrant_party;
/*=========================================================================================*/

PROCEDURE person_party_echeck(  p_party_id             IN OUT NOCOPY  NUMBER
                              , p_per_first_name       IN      VARCHAR2
                              , p_per_last_name        IN      VARCHAR2
                              , p_address1             IN      VARCHAR2
                              , p_country              IN      VARCHAR2
                              , p_email_address        IN      VARCHAR2
                              , p_ph_country_code      IN      VARCHAR2
                              , p_ph_area_code         IN      VARCHAR2
                              , p_ph_number            IN      VARCHAR2
                             )

IS

   l_party_key     varchar2(1000);
   L_COUNT         number;
   l_max_party_id  number;
   l_party_tbl     hz_fuzzy_pub.PARTY_TBL_TYPE;
   l_cust_exists   varchar2(1);
   l_ret_status    varchar(1);

   cursor c_email_address is
   select max(p.party_id)
   from hz_contact_points cp,
        hz_parties p
   where p.customer_key = l_party_key
     and p.party_type = 'PERSON'
     and cp.owner_table_id = p.party_id
     and cp.owner_table_name = 'HZ_PARTIES'
     and cp.email_address = p_email_address
     and cp.primary_flag = 'Y';

   cursor c_ph_number is
   select max(p.party_id)
   from hz_contact_points cp,
        hz_parties p
   where p.customer_key = l_party_key
     and p.party_type = 'PERSON'
     and cp.owner_table_id = p.party_id
     and cp.owner_table_name = 'HZ_PARTIES'
     and cp.primary_flag = 'Y'
     and cp.phone_number = p_ph_number
     and nvl(cp.phone_country_code, nvl(p_ph_country_code, 'x')) = nvl(p_ph_country_code, 'x')
     and nvl(cp.phone_area_code, nvl(p_ph_area_code, 'x')) = nvl(p_ph_area_code, 'x');

   cursor c_address_country is
   select max(psite.party_id)
   from hz_party_sites psite,
        hz_locations loc,
        hz_parties party
   where  psite.location_id = loc.location_id
     and  loc.address1      = p_address1
     and  loc.country       = p_country
     and  party.customer_key = l_party_key
     and  psite.party_id      = party.party_id;

   cursor c_person_exists is
   select 'Y'
   from hz_parties
   where customer_key = l_party_key
     and party_type   = 'PERSON';

begin

   -- Generates the customer key for PERSON
   if (    (p_per_last_name is not null)
       and (p_per_first_name is not null)
      )
   then
      l_party_key := hz_fuzzy_pub.Generate_Key (  p_key_type => 'PERSON'
                                                , p_first_name => p_per_first_name
                                                , p_last_name  => p_per_last_name
                                               );
      /*IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message('person_party_echeck - party key: ' || l_party_key);
      END IF;*/
      Write_log('person_party_echeck','person_party_echeck - party key: ' || l_party_key);

      open c_person_exists;
      fetch c_person_exists
      into l_cust_exists;
      close c_person_exists;
   end if; -- first/last name

   -- If customer does not exist then it's a new customer.
   if (l_cust_exists is NULL) then
      return;
   end if;

   -- If email address is provided
   if (p_email_address is not null)
   then
       open c_email_address;
       fetch c_email_address
       into p_party_id;
       close c_email_address;
       if (p_party_id is not null)
       then
            return;
       end if; -- party id
   end if; -- email address

   -- If phone number is provided
   if (p_ph_number is not null)
   then
       open c_ph_number;
       fetch c_ph_number
       into p_party_id;
       close c_ph_number;
       if (p_party_id is not null)
       then
            return;
       end if; -- party id
   end if; -- phone number

   -- When address1 and country is provided
   if (    (p_address1 is not null)
       and (p_country is not null)
      )
   then
       open c_address_country;
       fetch c_address_country
       into p_party_id;
       close c_address_country;
       if (p_party_id is not null)
       then
            return;
       end if; -- party id
   end if; -- address/country

exception

   when others
   then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end person_party_echeck;

PROCEDURE party_echeck(
   --p_impt_list_header_id IN    NUMBER,
   p_party_id           IN OUT NOCOPY   NUMBER,
   p_org_name           IN       VARCHAR2,
   p_per_first_name     IN       VARCHAR2,
   p_per_last_name      IN       VARCHAR2,
   p_address1           IN       VARCHAR2,
   p_country            IN       VARCHAR2
                      )

IS

l_party_key     varchar2(1000);
L_COUNT         number;
l_max_party_id  number;
l_party_tbl     hz_fuzzy_pub.PARTY_TBL_TYPE;
x_org_party_id  number;
l_ps_party_id   number;
l_cust_exists   varchar2(1);
l_ret_status      varchar(1);
x_per_party_id  number;
L_API_NAME      CONSTANT VARCHAR2(30) := ' party_echeck';

cursor c_address_country is
       select max(psite.party_id) from hz_party_sites psite, hz_locations loc,
        hz_parties party
    where  psite.location_id = loc.location_id
           and  loc.address1      = p_address1
     and  loc.country       = p_country
          and  party.customer_key = l_party_key
          and  psite.party_id      = party.party_id;

cursor c_country is
        select max(psite.party_id) from hz_party_sites psite, hz_locations loc,
        hz_parties party
         where  psite.location_id = loc.location_id
          and  loc.country       = p_country
          and  party.customer_key = l_party_key
          and  psite.party_id      = party.party_id;

cursor c_customer_exists is
       select 'Y' from hz_parties
       where customer_key = l_party_key
         and party_type   = 'ORGANIZATION';

cursor c_person_exists is
       select 'Y' from hz_parties
       where customer_key = l_party_key
         and party_type   = 'PERSON';
begin

--
-- Generates the customer key for ORGANIZATION
--
 if p_org_name is not null then
    l_party_key := hz_fuzzy_pub.Generate_Key (
                                p_key_type => 'ORGANIZATION',
                                p_party_name => p_org_name
                               );
    open c_customer_exists;
    fetch c_customer_exists into l_cust_exists;
    close c_customer_exists;
 end if;
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
    fetch c_person_exists into l_cust_exists;
    close c_person_exists;
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
if  l_cust_exists = 'Y' and p_address1 is not null and p_country is not null then
    /*IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.Debug_Message('Customer exists - checking address');
    END IF;*/
    Write_log(L_API_NAME, 'Customer exists - checking address');
    open c_address_country;
    fetch c_address_country into l_ps_party_id;
    close c_address_country;

    -- if party site not found for this address and country then serch for only country
    if l_ps_party_id is NULL then
       /*IF (AMS_DEBUG_HIGH_ON) THEN

           AMS_UTILITY_PVT.Debug_Message('Did not find an address - checking country...');
       END IF;*/
       Write_log(L_API_NAME, 'Did not find an address - checking country...');
       open c_country;
       fetch c_country into l_ps_party_id;
       close c_country;
       return;
    end if;
    if l_ps_party_id is not NULL then
       p_party_id := l_ps_party_id;
       return;
    end if;
end if;


    /*IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.Debug_Message('Moving on from address check...');
    END IF;*/
    Write_log(L_API_NAME, 'Moving on from address check...');

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
       L_COUNT        := 0;
       l_max_party_id := 0;
       hz_fuzzy_pub.FUZZY_SEARCH_PARTY(
       'ORGANIZATION',
       p_org_name,
       null,
       null,
       l_party_tbl,
       L_COUNT);
       if L_COUNT > 0 then
          for i in 1..l_count loop
             if l_party_tbl(i) > l_max_party_id then
                l_max_party_id := l_party_tbl(i);
             end if;
          end loop;
          x_org_party_id := l_max_party_id;
          p_party_id     := x_org_party_id;
       end if;
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

end party_echeck;

-- ---------------------------------------------

PROCEDURE contact_echeck(
   --p_impt_list_header_id   IN       NUMBER,
   p_party_id              IN OUT NOCOPY   NUMBER,
   p_org_party_id          IN       NUMBER,
   p_per_first_name        IN       VARCHAR2,
   p_per_last_name         IN       VARCHAR2,
   p_phone_area_code       IN       VARCHAR2,
   p_phone_number          IN       VARCHAR2,
   p_phone_extension       IN       VARCHAR2,
   p_email_address         IN       VARCHAR2
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


cursor c_customer_exists is
       select 'Y' from hz_parties
       where customer_key = l_party_key
         and party_type   = 'PERSON';

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
         and rel.RELATIONSHIP_CODE  = 'CONTACT_OF'
         and rel.OBJECT_ID          = org.party_id
         and rel.SUBJECT_ID         = per.PARTY_ID
         and per.customer_key       = l_party_key
         and cpoint.owner_table_id  = rel.party_id
         and cpoint.owner_table_name = 'HZ_PARTIES'
         and cpoint.contact_point_type = 'EMAIL'
         and cpoint.email_address    = p_email_address
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
         and rel.RELATIONSHIP_CODE  = 'CONTACT_OF'
         and rel.OBJECT_ID          = org.party_id
         and rel.SUBJECT_ID         = per.PARTY_ID
         and per.customer_key       = l_party_key
         and cpoint.owner_table_id  = rel.party_id
         and cpoint.owner_table_name = 'HZ_PARTIES'
         and cpoint.contact_point_type = 'EMAIL'
         and cpoint.email_address    = p_email_address
         and cpoint.status           = 'A'
         and cpoint1.owner_table_id  = rel.party_id
         and cpoint1.owner_table_name = 'HZ_PARTIES'
         and cpoint1.contact_point_type = 'PHONE'
         and cpoint1.phone_area_code||'-'||cpoint1.phone_number||'-'||cpoint1.phone_extension  =
             p_phone_area_code||'-'||p_phone_number||'-'||p_phone_extension
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
         and rel.RELATIONSHIP_CODE  = 'CONTACT_OF'
         and rel.OBJECT_ID          = org.party_id
         and rel.SUBJECT_ID         = per.PARTY_ID
         and per.customer_key       = l_party_key
         and cpoint.owner_table_id  = rel.party_id
         and cpoint.owner_table_name = 'HZ_PARTIES'
         and cpoint.contact_point_type = 'PHONE'
         and cpoint.phone_area_code||'-'||cpoint.phone_number||'-'||cpoint.phone_extension  =
             p_phone_area_code||'-'||p_phone_number||'-'||p_phone_extension
         and (cpoint.phone_line_type<>'FAX' or cpoint.phone_line_type is null)
         and cpoint.status           = 'A';

begin
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
   fetch c_customer_exists into l_cust_exists;
   close c_customer_exists;
   if l_cust_exists is NULL then
      return;     -- ORG CONTACT DOES NOT EXISTS CHECKED WITH CUSTOMER_KEY.
   end if;

   open c_cont_email_phone;
   fetch c_cont_email_phone into x_per_party_id;
   close c_cont_email_phone;
   if x_per_party_id is not null then
      p_party_id     := x_per_party_id;   -- ORG CONTACT DOES NOT EXISTS WITH EMAIL AND PHONE NUMBER.
      return;
   end if;
--
-- Either email_address and phone number is available.
--
   if l_cust_exists = 'Y' and (p_email_address is not null or p_phone_number is not null) then
      open c_cont_email;
      fetch c_cont_email into l_email_party_id;
      close c_cont_email;
      if l_email_party_id is not null then
         p_party_id     :=  l_email_party_id;
         return;
      end if;

      open c_cont_phone;
      fetch c_cont_phone into l_phone_party_id;
      close c_cont_phone;
      if l_phone_party_id is not null then
         p_party_id := l_phone_party_id;
      end if;
   end if;
end contact_echeck;
--
-- This procedure is used for existence checking for address.
--
--
PROCEDURE address_echeck(
   --p_impt_list_header_id   IN       NUMBER,
   p_party_id              IN       NUMBER,
   p_location_id           IN OUT NOCOPY   NUMBER,
   p_address1              IN       VARCHAR2,
   p_city                  IN       VARCHAR2,
   p_pcode                 IN       VARCHAR2,
   p_country               IN       VARCHAR2
                       ) is

l_address_key       varchar(1000);
l_loc_id            number;
l_ret_status        varchar(1);


cursor c_addr_ps is
       select max(loc.location_id)
       from  hz_party_sites ps, hz_locations loc
       where ps.party_id          = p_party_id
         and ps.location_id       = loc.location_id
         and loc.address_key      = l_address_key
         and loc.country          = p_country
         and nvl(loc.city,p_city) = p_city;

cursor c_addr is
       select max(loc.location_id)
       from   hz_locations loc
       where  loc.address_key     = l_address_key
         and loc.country          = p_country
         and nvl(loc.city,p_city) = p_city;

begin

      l_address_key := hz_fuzzy_pub.Generate_Key (
                                p_key_type => 'ADDRESS',
                                p_address1 =>  p_address1,
                                p_postal_code => p_pcode
                               );

      open c_addr_ps;
      fetch c_addr_ps into l_loc_id;
      close c_addr_ps;
      if l_loc_id is null then
         open c_addr;
         fetch c_addr into l_loc_id;
         close c_addr;
      end if;
      p_location_id := l_loc_id;

end address_echeck;

PROCEDURE get_party_id(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   p_rec               IN  party_detail_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   x_new_party_id      OUT NOCOPY NUMBER,
   x_new_org_party_id  OUT NOCOPY NUMBER
) IS
   l_party_id   NUMBER;
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'get_party_id';
   l_full_name                 CONSTANT VARCHAR2(60)  := G_PKG_NAME || '.' || l_api_name;

    -- all declarations starting here added by soagrawa on 11-dec-2002
    -- to move to v2apis

    party_rec       hz_party_v2pub.party_rec_type;
    org_rec         hz_party_v2pub.organization_rec_type;
    person_rec      hz_party_v2pub.person_rec_type;
    location_rec    hz_location_v2pub.location_rec_type;
    psite_rec       hz_party_site_v2pub.party_site_rec_type;
    cpoint_rec      hz_contact_point_v2pub.contact_point_rec_type;
    email_rec       hz_contact_point_v2pub.email_rec_type;
    phone_rec       hz_contact_point_v2pub.phone_rec_type;
    fax_rec         hz_contact_point_v2pub.phone_rec_type;
    ocon_rec        hz_party_contact_v2pub.org_contact_rec_type;
    edi_rec         hz_contact_point_v2pub.edi_rec_type;
    telex_rec       hz_contact_point_v2pub.telex_rec_type;
    web_rec         hz_contact_point_v2pub.web_rec_type;
    psite_use_rec   hz_party_site_v2pub.party_site_use_rec_type;
    x_new_party        VARCHAR2(1);
    x_component_name   VARCHAR2(60);
    l_b2b_flag         VARCHAR2(1);

    CURSOR  c_relationship_det(p_id NUMBER) IS
    SELECT  object_id, subject_id
      FROM  hz_relationships
     WHERE  party_id = p_id
     -- dbiswas 10 Jun 2003 fix for bug 2949603
      -- AND  directional_flag = 'F';
   AND subject_Type = 'PERSON'
   AND object_Type = 'ORGANIZATION';


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Register_get_party_id_PVT;

    /*IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name || ': start');
    END IF;*/
    Write_log(L_API_NAME, l_full_name || ': start');


   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;
/*
   AMS_Registrants_PVT.find_a_party(
      p_api_version   => 1.0,
      p_init_msg_list => FND_API.g_false,
      p_rec      => p_rec,
      x_return_status => x_return_status,
      x_msg_count    => x_msg_count,
      x_msg_data  => x_msg_data,
      x_party_id   => x_new_party_id
   );
   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   if x_new_party_id is NULL THEN
*/

/*
    IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.Debug_Message('Create Party');
    END IF;
*/
    Write_log(L_API_NAME, 'Create Party');


      -- replaced by soagrawa on 29-oct-2002
      -- now calling list import APIs instead
      /*
      AMS_Registrants_PVT.create_registrant_party(
         p_api_version     => 1.0,
         p_init_msg_list => FND_API.g_false,
         p_commit          => FND_API.g_false,
         p_validation_level  => FND_API.g_valid_level_full,
         p_rec  => p_rec,

         x_return_status => x_return_status,
         x_msg_count  => x_msg_count,
         x_msg_data  => x_msg_data,
         x_new_party_id  => x_new_party_id,
         x_new_org_party_id => x_new_org_party_id
      );
      */

     -- gotta determine if it is B2B or B2C

     IF p_rec.party_name IS NOT NULL
     THEN
          -- it is B2B
          l_b2b_flag := 'Y';
/*
          IF (AMS_DEBUG_HIGH_ON) THEN
             AMS_Utility_PVT.Debug_Message('B2B');
          END IF;
*/
	  Write_log(L_API_NAME, 'B2B');
          org_rec.organization_name               := p_rec.party_name;

          person_rec.person_first_name            := p_rec.first_name;
          person_rec.person_middle_name           := p_rec.middle_name;
          person_rec.person_last_name             := p_rec.last_name;
          person_rec.person_name_suffix           := p_rec.name_suffix;
          person_rec.person_title                 := p_rec.title;
          person_rec.tax_reference                := p_rec.tax_reference;
          person_rec.jgzz_fiscal_code             := p_rec.jgzz_fiscal_code;
          person_rec.gender                       := p_rec.gender;
          person_rec.created_by_module := 'AMS_EVENT';

          location_rec.country                    := p_rec.country;
          location_rec.address1                   := p_rec.address1;
          location_rec.address2                   := p_rec.address2;
          location_rec.address3                   := p_rec.address3;
          location_rec.address4                   := p_rec.address4;
          location_rec.city                       := p_rec.city;
          location_rec.postal_code                := p_rec.postal_code;
          location_rec.state                      := p_rec.state;
          location_rec.province                   := p_rec.province;
          location_rec.county                     := p_rec.county;
          location_rec.address_lines_phonetic     := p_rec.address_line_phonetic;
     --     location_rec.po_box_number              := p_rec.po_box_no;
      --    location_rec.house_number               := p_rec.house_number;
      --    location_rec.street_suffix              := p_rec.street_suffix;
    --      location_rec.street                     := p_rec.street;
     --     location_rec.street_number              := p_rec.street_number;
     --     location_rec.floor                      := p_rec.floor;
     --     location_rec.suite                      := p_rec.suite;
          location_rec.postal_plus4_code          := p_rec.postal_plus4_code;
          location_rec.timezone_id                := p_rec.timezone;
          location_rec.created_by_module          := 'AMS_EVENT';

          phone_rec.phone_area_code               := p_rec.phone_area_code;
          phone_rec.phone_country_code            := p_rec.phone_country_code;
          phone_rec.phone_extension               := p_rec.phone_extension;
          phone_rec.phone_number                  := p_rec.phone_number;

          psite_rec.identifying_address_flag      := p_rec.identifying_address_flag;

          email_rec.email_address                 := p_rec.email_address;

          web_rec.url                             := p_rec.url;

          ocon_rec.department                   := p_rec.department;
          ocon_rec.title                        := p_rec.title;
          ocon_rec.job_title                    := p_rec.job_title;
          ocon_rec.decision_maker_flag          := p_rec.decision_maker_flag;
          ocon_rec.created_by_module            := 'AMS_EVENT';

     ELSE
          -- it is B2C
          l_b2b_flag := 'N';
/*
          IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.Debug_Message('B2C');
          END IF;
*/
	  Write_log(L_API_NAME, 'B2C');

          person_rec.person_first_name            := p_rec.first_name;
          person_rec.person_middle_name           := p_rec.middle_name;
          person_rec.person_last_name             := p_rec.last_name;
          person_rec.person_name_suffix           := p_rec.name_suffix;
          person_rec.person_title                 := p_rec.title;
          person_rec.tax_reference                := p_rec.tax_reference;
          person_rec.jgzz_fiscal_code             := p_rec.jgzz_fiscal_code;
          person_rec.gender                       := p_rec.gender;
          person_rec.created_by_module            := 'AMS_EVENT';

          location_rec.country                    := p_rec.country;
          location_rec.address1                   := p_rec.address1;
          location_rec.address2                   := p_rec.address2;
          location_rec.address3                   := p_rec.address3;
          location_rec.address4                   := p_rec.address4;
          location_rec.city                       := p_rec.city;
          location_rec.postal_code                := p_rec.postal_code;
          location_rec.state                      := p_rec.state;
          location_rec.province                   := p_rec.province;
          location_rec.county                     := p_rec.county;
          location_rec.address_lines_phonetic      := p_rec.address_line_phonetic;
 --         location_rec.po_box_number              := p_rec.po_box_no;
 --         location_rec.house_number               := p_rec.house_number;
     --     location_rec.street_suffix              := p_rec.street_suffix;
      --    location_rec.street                     := p_rec.street;
    --      location_rec.street_number              := p_rec.street_number;
   --       location_rec.floor                      := p_rec.floor;
    --      location_rec.suite                      := p_rec.suite;
          location_rec.postal_plus4_code          := p_rec.postal_plus4_code;
          location_rec.timezone_id                := p_rec.timezone;
          location_rec.created_by_module          := 'AMS_EVENT';

          phone_rec.phone_area_code               := p_rec.phone_area_code;
          phone_rec.phone_country_code            := p_rec.phone_country_code;
          phone_rec.phone_extension               := p_rec.phone_extension;
          phone_rec.phone_number                  := p_rec.phone_number;

          -- soagrawa added web_rec on 11-feb-2003 as create_customer API signature changed
          web_rec.url                             := p_rec.url;

          email_rec.email_address                 := p_rec.email_address;

/*
         IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_Utility_PVT.Debug_Message('Getting email address: '||email_rec.email_address);
         END IF;
*/
	 Write_log(L_API_NAME, 'Getting email address: '||email_rec.email_address);

     END IF;

     AMS_List_Import_PUB.Create_Customer (
     p_api_version              => 1.0,
     p_init_msg_list            => FND_API.g_false,
     p_commit                   => FND_API.g_false,
     x_return_status            => x_return_status,
     x_msg_count                => x_msg_count,
     x_msg_data                 => x_msg_data,
     p_party_id                 => l_party_id,
     p_b2b_flag                 => l_b2b_flag,
     p_import_list_header_id    => NULL,
     p_party_rec                => party_rec,
     p_org_rec                  => org_rec,
     p_person_rec               => person_rec,
     p_location_rec             => location_rec,
     p_psite_rec                => psite_rec,
     p_cpoint_rec               => cpoint_rec,
     p_email_rec                => email_rec,
     p_phone_rec                => phone_rec,
     p_siteuse_rec              => psite_use_rec,
     p_fax_rec                  => fax_rec,
     p_ocon_rec                 => ocon_rec,
     -- soagrawa added web_rec on 11-feb-2003 as create_customer API signature changed
     p_web_rec                 => web_rec,
     x_new_party                => x_new_party,  -- will return Y or N
     p_component_name           => x_component_name); -- component in which error occurred

/*
     IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.Debug_Message('After create_Customer done');
        AMS_Utility_PVT.Debug_Message('Return Status: '||x_return_status);
        --AMS_Utility_PVT.Debug_Message('Return Status: '||x_new_party);
        --AMS_Utility_PVT.Debug_Message('Return Status: '||x_component_name);
      END IF;
*/
      Write_log(L_API_NAME, 'After create_Customer done');
      Write_log(L_API_NAME, 'Return Status: '||x_return_status);

      IF x_return_status = FND_API.g_ret_sts_error THEN

         /*IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.Debug_Message('Error');
         END IF;*/
         Write_log(L_API_NAME, 'Error');
/*
         FOR i IN 1 .. FND_MSG_PUB.count_msg LOOP
          -- AMS_Utility_PVT.Debug_Message(FND_MSG_PUB.get(i, FND_API.g_false));
         END LOOP;
*/
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
/*
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.Debug_Message('Unexp Error');
         END IF;
*/
	 Write_log(L_API_NAME, 'Unexp Error');
         /*FOR i IN 1 .. FND_MSG_PUB.count_msg LOOP
           AMS_Utility_PVT.Debug_Message(FND_MSG_PUB.get(i, FND_API.g_false));
          END LOOP; */
         RAISE FND_API.g_exc_unexpected_error;
      end if;
  /*
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.Debug_Message('After create_Customer error handling');
         AMS_Utility_PVT.Debug_Message('Return party id: '||l_party_id);
      END IF;
 */
      Write_log(L_API_NAME, 'After create_Customer error handling');
      Write_log(L_API_NAME, 'Return party id: '||l_party_id);

     if l_party_id is NULL then
         x_return_status := FND_API.g_ret_sts_error;
         RAISE FND_API.g_exc_error;
      end if;



      -- set return values
      IF l_b2b_flag = 'Y'
      THEN
         OPEN  c_relationship_det(l_party_id);
         FETCH c_relationship_det INTO x_new_org_party_id, x_new_party_id;
         CLOSE c_relationship_det;

         x_new_party_id := l_party_id;
      ELSE  -- b2C
         x_new_party_id      := l_party_id;
         x_new_org_party_id  := l_party_id;
      END IF;

  /* else
      AMS_Utility_PVT.Debug_Message('Party Exist');
   end if;
      ELSE
	Write_log(L_API_NAME, 'Party Exist');
      END IF;*/

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      rollback to Register_get_party_id_PVT;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      rollback to Register_get_party_id_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      rollback to Register_get_party_id_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


END get_party_id;

--=================================================================================
--Function
--   Get_Event_Det
--
--Purpose
--   Function will return the Event id for the source code passed.
--
-- History
--   24-Feb-2002   ptendulk   Created
--   31-jan-2003   soagrawa   Fixed P1 bug# 2779298 - canot register for CSCH of type events
--=================================================================================
FUNCTION Get_Event_Det(p_source_code   IN VARCHAR2)
RETURN NUMBER
IS
   l_event_id   NUMBER ;

   CURSOR c_event_det IS
   SELECT event_offer_id
   FROM   ams_event_offers_all_b
   WHERE  source_code = p_source_code ;

   -- soagrawa  bug# 2779298 31-jan-2003
   CURSOR c_csch_event_det IS
   SELECT related_event_id
   FROM   ams_campaign_schedules_b
   WHERE  source_code = p_source_code ;

BEGIN
/*
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.Debug_Message('Start Get Event Det ');
   END IF;
*/
   Write_log('Get_Event_Det', 'Start Get Event Det ');

   OPEN c_event_det ;
   FETCH c_event_det INTO l_event_id ;
   IF c_event_det%NOTFOUND THEN

      -- soagrawa  bug# 2779298 31-jan-2003
      OPEN c_csch_event_det ;
      FETCH c_csch_event_det INTO l_event_id ;
      IF c_csch_event_det%NOTFOUND THEN
         AMS_Utility_PVT.Error_Message('AMS_INVALID_EVENT');
         CLOSE c_csch_event_det ;
         CLOSE c_event_det ;
         RAISE FND_API.g_exc_error;
      END IF ;
      CLOSE c_csch_event_det ;
   END IF ;
   CLOSE c_event_det;

   RETURN l_event_id ;
END Get_Event_Det ;

END AMS_Registrants_PVT;

/
