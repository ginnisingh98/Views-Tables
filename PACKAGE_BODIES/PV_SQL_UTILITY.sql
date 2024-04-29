--------------------------------------------------------
--  DDL for Package Body PV_SQL_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_SQL_UTILITY" as
/* $Header: pvsqlutb.pls 120.3 2005/12/19 16:19:51 pklin ship $*/

--=============================================================================+
--| Public Procedure                                                           |
--|    pv_lookup                                                               |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION pv_lookup (
   p_lookup_code IN  VARCHAR2,
   p_lookup_type IN  VARCHAR2
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(80);

BEGIN
   FOR x IN (SELECT meaning
             FROM   pv_lookups
             WHERE  lookup_code = p_lookup_code AND
                    lookup_type = p_lookup_type)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END pv_lookup;


--=============================================================================+
--| Public Procedure                                                           |
--|    as_lookup                                                               |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION as_lookup (
   p_lookup_code IN  VARCHAR2,
   p_lookup_type IN  VARCHAR2
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(80);

BEGIN
   FOR x IN (SELECT meaning
             FROM   as_lookups
             WHERE  lookup_code = p_lookup_code AND
                    lookup_type = p_lookup_type)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END as_lookup;


--=============================================================================+
--| Public Procedure                                                           |
--|    ar_lookup                                                               |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION ar_lookup (
   p_lookup_code IN  VARCHAR2,
   p_lookup_type IN  VARCHAR2
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(80);

BEGIN
   FOR x IN (SELECT meaning
             FROM   ar_lookups
             WHERE  lookup_code = p_lookup_code AND
                    lookup_type = p_lookup_type)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END ar_lookup;


--=============================================================================+
--| Public Procedure                                                           |
--|    fnd_lookup_values                                                       |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION fnd_lookup_values (
   p_lookup_code IN  VARCHAR2,
   p_lookup_type IN  VARCHAR2
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(80);

BEGIN
   FOR x IN (SELECT meaning
             FROM   fnd_lookup_values
             WHERE  lookup_code = p_lookup_code AND
                    lookup_type = p_lookup_type AND
                    LANGUAGE(+) = USERENV('LANG'))
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END fnd_lookup_values;


--=============================================================================+
--| Public Procedure                                                           |
--|    as_status                                                               |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION as_status (
   p_status_code IN  VARCHAR2
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(240);

BEGIN
   IF (p_status_code IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT meaning
             FROM   as_statuses_tl
             WHERE  status_code = p_status_code AND
                    language = USERENV('LANG'))
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END as_status;


--=============================================================================+
--| Public Procedure                                                           |
--|    aso_i_sales_channels                                                    |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION aso_i_sales_channels (
   p_sales_channel_code IN  VARCHAR2
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(80);

BEGIN
   IF (p_sales_channel_code IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT sales_channel meaning
             FROM   aso_i_sales_channels_v
             WHERE  sales_channel_code = p_sales_channel_code)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END aso_i_sales_channels;


--=============================================================================+
--| Public Procedure                                                           |
--|    as_sales_methodology                                                    |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION as_sales_methodology (
   p_sales_methodology_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(80);

BEGIN
   IF (p_sales_methodology_id IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT name meaning
             FROM   as_sales_methodology_vl
             WHERE  sales_methodology_id = p_sales_methodology_id)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END as_sales_methodology;


--=============================================================================+
--| Public Procedure                                                           |
--|    as_sales_stages_all                                                    |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION as_sales_stages_all (
   p_sales_stage_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(80);

BEGIN
   IF (p_sales_stage_id IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT name meaning
             FROM   as_sales_stages_all_vl
             WHERE  sales_stage_id = p_sales_stage_id)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END as_sales_stages_all;


--=============================================================================+
--| Public Procedure                                                           |
--|    as_sales_lead_ranks                                                     |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION as_sales_lead_ranks (
   p_rank_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(240);

BEGIN
   IF (p_rank_id IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT meaning
             FROM   as_sales_lead_ranks_vl
             WHERE  rank_id = p_rank_id)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END as_sales_lead_ranks;


--=============================================================================+
--| Public Procedure                                                           |
--|    fnd_territories                                                         |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION fnd_territories (
   p_territory_code IN  VARCHAR2
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(80);

BEGIN
   IF (p_territory_code IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT territory_short_name meaning
             FROM   fnd_territories_tl
             WHERE  territory_code = p_territory_code AND
                    language = USERENV('LANG'))
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END fnd_territories;



--=============================================================================+
--| Public Procedure                                                           |
--|    hz_location_country                                                     |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION hz_location_country (
   p_party_site_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(60);

BEGIN
   IF (p_party_site_id IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT country meaning
             FROM   hz_locations   a,
                    hz_party_sites b
             WHERE  b.party_site_id = p_party_site_id AND
                    a.location_id   = b.location_id)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END hz_location_country;


--=============================================================================+
--| Public Procedure                                                           |
--|    customer_contact_name                                                   |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION customer_contact_name (
   p_party_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(302);

BEGIN
   IF (p_party_id IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT PERSON_LAST_NAME || ' ' || PERSON_FIRST_NAME meaning
             FROM   hz_relationships a,
                    hz_parties       b
             WHERE  a.party_id     = p_party_id AND
                    a.subject_type = 'PERSON' AND
                    a.subject_id   = b.party_id)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END customer_contact_name;

--=============================================================================+
--| Public Procedure                                                           |
--|    customer_contact_email                                                  |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION customer_contact_email (
   p_party_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(2000);

BEGIN
   IF (p_party_id IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT email_address meaning
             FROM   hz_relationships a,
                    hz_parties       b
             WHERE  a.party_id     = p_party_id AND
                    a.subject_type = 'PERSON' AND
                    a.subject_id   = b.party_id)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END customer_contact_email;


--=============================================================================+
--| Public Procedure                                                           |
--|    customer_contact_phone                                                  |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION customer_contact_phone (
   p_party_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(80);

BEGIN
   IF (p_party_id IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT PHONE_COUNTRY_CODE || PHONE_AREA_CODE || PHONE_NUMBER ||
                    PHONE_EXTENSION  meaning
             FROM   hz_contact_points
             WHERE  owner_table_name   = 'HZ_PARTIES' AND
                    owner_table_id     = p_party_id AND
                    contact_point_type = 'PHONE' AND
                    primary_flag       = 'Y' AND
                    status             = 'A')
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END customer_contact_phone;


--=============================================================================+
--| Public Procedure                                                           |
--|    customer_contact_name2                                                  |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION customer_contact_name2 (
   p_lead_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(302);

BEGIN

   IF (p_lead_id IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT PERSON_LAST_NAME || ' ' || PERSON_FIRST_NAME meaning
             FROM   hz_relationships a,
                    hz_parties       b,
                    as_lead_contacts_all aslc
             WHERE  aslc.lead_id              = p_lead_id AND
                    aslc.primary_contact_flag = 'Y' AND
                    a.party_id                = aslc.contact_party_id AND
                    a.subject_type            = 'PERSON' AND
                    a.subject_id              = b.party_id)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END customer_contact_name2;


--=============================================================================+
--| Public Procedure                                                           |
--|    customer_contact_email2                                                 |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION customer_contact_email2 (
   p_lead_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(2000);

BEGIN
   IF (p_lead_id IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT email_address meaning
             FROM   hz_relationships a,
                    hz_parties       b,
                    as_lead_contacts_all aslc
             WHERE  aslc.lead_id              = p_lead_id AND
                    aslc.primary_contact_flag = 'Y' AND
                    a.party_id                = aslc.contact_party_id AND
                    a.subject_type            = 'PERSON' AND
                    a.subject_id              = b.party_id)
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END customer_contact_email2;


--=============================================================================+
--| Public Procedure                                                           |
--|    customer_contact_phone2                                                 |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION customer_contact_phone2 (
   p_lead_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_meaning VARCHAR2(80);

BEGIN
   IF (p_lead_id IS NULL) THEN
      RETURN NULL;
   END IF;

   FOR x IN (SELECT PHONE_COUNTRY_CODE || PHONE_AREA_CODE || PHONE_NUMBER ||
                    PHONE_EXTENSION  meaning
             FROM   hz_contact_points,
                    as_lead_contacts_all aslc
             WHERE  aslc.lead_id              = p_lead_id AND
                    aslc.primary_contact_flag = 'Y' AND
                    owner_table_name          = 'HZ_PARTIES' AND
                    owner_table_id            = aslc.contact_party_id AND
                    contact_point_type        = 'PHONE')
   LOOP
      l_meaning := x.meaning;
   END LOOP;

   RETURN l_meaning;

END customer_contact_phone2;


--=============================================================================+
--| Public Procedure                                                           |
--|    referral_customer_address                                               |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION referral_customer_address (
   p_referral_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_formatted_address VARCHAR2(32000);

BEGIN
   FOR x IN (SELECT ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS_LABEL(
                       Null,
                       CUSTOMER_ADDRESS1,
                       CUSTOMER_ADDRESS2,
                       CUSTOMER_ADDRESS3,
                       CUSTOMER_ADDRESS4,
                       CUSTOMER_CITY,
                       CUSTOMER_COUNTY,
                       CUSTOMER_STATE,
                       CUSTOMER_PROVINCE,
                       CUSTOMER_POSTAL_CODE,
                       null,
                       CUSTOMER_COUNTRY,
                       Null,
                       Null,
                       Null,
                       Null,
                       Null,
                       NULL,
                       NULL,
                       NULL,
                       2000,
                       1,
                       1) ADDRESS
             FROM   pv_referrals_b
             WHERE  referral_id = p_referral_id)
   LOOP
      l_formatted_address := x.address;
   END LOOP;

   RETURN l_formatted_address;

END referral_customer_address;


--=============================================================================+
--| Public Procedure                                                           |
--|    party_address                                                           |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION party_address (
   p_party_site_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_formatted_address VARCHAR2(32000);

BEGIN
   FOR x IN (SELECT ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS_LABEL(
                       Null,
                       a.ADDRESS1,
                       a.ADDRESS2,
                       a.ADDRESS3,
                       a.ADDRESS4,
                       a.CITY,
                       a.COUNTY,
                       a.STATE,
                       a.PROVINCE,
                       a.POSTAL_CODE,
                       null,
                       a.COUNTRY,
                       Null,
                       Null,
                       Null,
                       Null,
                       Null,
                       NULL,
                       NULL,
                       NULL,
                       2000,
                       1,
                       1) ADDRESS
             FROM   hz_locations   a,
	            hz_party_sites b
             WHERE  b.party_site_id = p_party_site_id AND
	            a.location_id   = b.location_id AND
		    b.status        = 'A')
   LOOP
      l_formatted_address := x.address;
   END LOOP;

   RETURN l_formatted_address;

END party_address;


--=============================================================================+
--| Public Procedure                                                           |
--|    party_address2                                                          |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION party_address2 (
   p_location_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_formatted_address VARCHAR2(32000);

BEGIN
   FOR x IN (SELECT ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS_LABEL(
                       Null,
                       ADDRESS1,
                       ADDRESS2,
                       ADDRESS3,
                       ADDRESS4,
                       CITY,
                       COUNTY,
                       STATE,
                       PROVINCE,
                       POSTAL_CODE,
                       null,
                       COUNTRY,
                       Null,
                       Null,
                       Null,
                       Null,
                       Null,
                       NULL,
                       NULL,
                       NULL,
                       2000,
                       1,
                       1) ADDRESS
             FROM   hz_locations
             WHERE  location_id = p_location_id)
   LOOP
      l_formatted_address := x.address;
   END LOOP;

   RETURN l_formatted_address;

END party_address2;


--=============================================================================+
--| Public Procedure                                                           |
--|    jtf_resource                                                            |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION jtf_resource (
   p_resource_id IN  NUMBER
)
RETURN VARCHAR2
IS
   l_source_name VARCHAR2(360);

BEGIN
   FOR x IN (SELECT source_name
             FROM   jtf_rs_resource_extns
             WHERE  resource_id = p_resource_id)
   LOOP
      l_source_name := x.source_name;
   END LOOP;

   RETURN l_source_name;

END jtf_resource;


--=============================================================================+
--| Public Procedure                                                           |
--|    user_has_permission                                                     |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
function user_has_permission(p_contact_rel_party_id number, p_permission varchar2)
return number is
l_exists_flag number := 0;
begin
   for x in ( select  1 exist_flag
             from  jtf_auth_principal_maps jtfpm,
             jtf_auth_principals_b jtfp1,
             jtf_auth_domains_b jtfd,
             jtf_auth_principals_b jtfp2,
             jtf_auth_role_perms jtfrp,
             jtf_auth_permissions_b jtfperm,
             fnd_user FU
             where jtfp1.principal_name = FU.USER_NAME  and
             FU.CUSTOMER_ID = p_contact_rel_party_id and
             jtfp1.is_user_flag=1
             and jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
             and jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
             and jtfp2.is_user_flag=0
             and jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
             and jtfrp.positive_flag = 1
             and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
             and jtfperm.permission_name = p_permission
             and jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
             and jtfd.domain_name='CRM_DOMAIN')
   loop
      l_exists_flag := x.exist_flag;
   end loop;
   return l_exists_flag;
end user_has_permission;

END PV_SQL_UTILITY;

/
