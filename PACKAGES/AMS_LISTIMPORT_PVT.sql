--------------------------------------------------------
--  DDL for Package AMS_LISTIMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTIMPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvimls.pls 115.35 2003/12/23 18:22:23 usingh ship $ */

-----------------------------------------------------------
G_PARTY_MAPPED        VARCHAR2(1);

-- PACKAGE
--   AMS_ListImport_PVT
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
-- PROCEDURES
--       list_import_to_hz
--
-- PARAMETERS
--           INPUT
--               p_import_list_header_id NUMBER.
--
--           OUTPUT
--              Errbuf                  VARCHAR2 -- Conc Pgm Error mesgs.
--              RetCode                 VARCHAR2 -- Conc Pgm Error Code.
--                                      0 - Success, 2 - Failure.
--
-- HISTORY
-- 19-Mar-2001 usingh      Created.
-- ---------------------------------------------------------
TYPE colNmValue IS TABLE of AMS_IMP_XML_ELEMENTS%ROWTYPE INDEX BY BINARY_INTEGER;

TYPE data_in_rec_type is RECORD (
     cust_data_id                       NUMBER        := FND_API.G_MISS_NUM,
     org_imp_xml_element_id             NUMBER        := FND_API.G_MISS_NUM,
     PARTY_NAME                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     FISCAL_YEAREND_MONTH               VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     DUNS_NUMBER                        VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     EMPLOYEES_TOTAL                    VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     LINE_OF_BUSINESS                   VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     YEAR_ESTABLISHED                   VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     TAX_REFERENCE                      VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     ORIG_SYSTEM_REFERENCE              VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     CEO_NAME                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     SIC_CODE                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     SIC_CODE_TYPE                      VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     ANALYSIS_FY                        VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     CURR_FY_POTENTIAL_REVENUE          VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     NEXT_FY_POTENTIAL_REVENUE          VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     GSA_INDICATOR_FLAG                 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     MISSION_STATEMENT                  VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     ORGANIZATION_NAME_PHONETIC         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     CATEGORY_CODE                      VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     JGZZ_FISCAL_CODE                   VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     PARTY_ID                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
BRANCH_FLAG                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
BUSINESS_LINE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
BUSINESS_SCOPE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
CHIEF_EXECUTIVE_TITLE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
CONGRESSIONAL_DISTRICT_CODE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
CONTROL_YEAR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
CORPORATION_CLASS                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
CREDIT_SCORE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
CREDIT_SCORE_COMMENTARY                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
CUSTOMER_CATEGORY                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DB_RATING                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DEBARMENTS_COUNT                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DEBARTMENTS_DATE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DEPARTMENT_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DISADVANTAGED_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ENQUIRY_DUNS                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
EXPORT_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
FAILURE_SCORE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
FAILURE_SCORE_COMMENTARY                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
FAILURE_SCORE_NATL_PERCENTILE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
FAILURE_SCORE_OVERRIDE_CODE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
GLOBAL_FAILURE_SCORE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
HEADQUARTER_BRANCH_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
IMPORT_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_KNOWN_AS                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_KNOWN_AS2                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_KNOWN_AS3                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_KNOWN_AS4                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_KNOWN_AS5                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
LABOR_SURPLUS_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
LOCAL_ACTIVITY_CODE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
LOCAL_ACTIVITY_CODE_TYPE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
MINORITY_OWNED_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
MINORITY_OWNED_TYPE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_TYPE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_URL                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
OUT_OF_BUSINESS_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PRINCIPAL_NAME                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PRINCIPAL_TITLE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PUBLIC_PRIVATE_OWNERSHIP_FLAG                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
RENT_OWNED_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
RENT_OWNER_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
SMALL_BUSINESS_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
WOMAN_OWNED_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_ATTRIBUTE_CATEGORY                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE1                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE2                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE3                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE4                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE5                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE6                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE7                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE8                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE9                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE10                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE11                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE12                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE13                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE14                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORGANIZATION_ATTRIBUTE15                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
VEHICLE_RESPONSE_CODE				 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
SALES_AGENT_EMAIL_ID				 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
NOTES						 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     add_imp_xml_element_id             NUMBER        := FND_API.G_MISS_NUM,
     address1                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     address2                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     address3                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     address4                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     city                               VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     county                             VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     province                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     state                              VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     postal_code                        VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     country                            VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     address_lines_phonetic             VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     po_box_number                      VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     house_number                       VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     street_suffix                      VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     street                             VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     street_number                      VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     floor                              VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     suite                              VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     postal_plus4_code                  VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     identifying_address_flag           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE1                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE2                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE3                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE4                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE5                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE6                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE7                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE8                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE9                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE10                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE11                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE12                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE13                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE14                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE15                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DESCRIPTION                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE_CATEGORY                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PARTY_SITE_USE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
LOCATION_DIRECTIONS                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
SHORT_DESCRIPTION                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_EFFECTIVE_DATE			VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_EXPIRATION_DATE			VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     ocont_imp_xml_element_id           NUMBER        := FND_API.G_MISS_NUM,
     person_first_name                  VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     person_middle_name                 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     person_name_suffix                 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     person_last_name                   VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     person_name_prefix                       VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     department                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     job_title                          VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     decision_maker_flag                VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSONAL_INCOME                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ACADEMIC_TITLE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_FIRST_NAME_PHONETIC                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_LAST_NAME_PHONETIC                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
MIDDLE_NAME_PHONETIC                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_NAME_PHONETIC                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_PREVIOUS_TITLE_NAME                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PLACE_OF_BIRTH                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
HEAD_OF_HOUSEHOLD_FLAG                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
HOUSEHOLD_SIZE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
TAX_ID                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE_CATEGORY                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_KNOWN_AS                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_KNOWN_AS2                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_KNOWN_AS3                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_KNOWN_AS4                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_KNOWN_AS5                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DATE_OF_BIRTH                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DATE_OF_DEATH                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DECLARED_ETHNICITY                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
MARITAL_STATUS                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
MARITAL_STATUS_EFFECTIVE_DATE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE1                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE2                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE3                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE4                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE5                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE6                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE7                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE8                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE9                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE10                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE11                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE12                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE13                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE14                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORG_CONTACT_ATTRIBUTE15                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     cp_imp_xml_element_id              NUMBER        := FND_API.G_MISS_NUM,
     phone_country_code                 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     phone_area_code                    VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     phone_number                       VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     phone_extension                    VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     em_imp_xml_element_id              NUMBER        := FND_API.G_MISS_NUM,
     email_address                      VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     fx_imp_xml_element_id              NUMBER        := FND_API.G_MISS_NUM,
     fax_country_code                 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     fax_area_code                    VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     fax_number                       VARCHAR2(2000):= FND_API.G_MISS_CHAR);



TYPE data_in_rec_b2c_type is RECORD (
     cust_data_id                       NUMBER        := FND_API.G_MISS_NUM,
     per_imp_xml_element_id             NUMBER        := FND_API.G_MISS_NUM,
     person_first_name                  VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     person_middle_name                 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     person_name_suffix                 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     person_last_name                   VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     person_name_prefix                       VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     SALUTATION				VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     PARTY_ID                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
URL                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
SECOND_TITLE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DATE_OF_BIRTH                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ACADEMIC_TITLE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_PREVIOUS_TITLE_NAME                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_KNOWN_AS                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_KNOWN_AS2                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_KNOWN_AS3                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_KNOWN_AS4                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_KNOWN_AS5                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_NAME_PHONETIC                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
MIDDLE_NAME_PHONETIC                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_FIRST_NAME_PHONETIC                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_LAST_NAME_PHONETIC                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
FISCAL_CODE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PLACE_OF_BIRTH                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DATE_OF_DEATH                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DECLARED_ETHNICITY                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
MARITAL_STATUS                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSONAL_INCOME                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
MARITAL_STATUS_EFFECTIVE_DATE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
HEAD_OF_HOUSEHOLD_FLAG                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
HOUSEHOLD_SIZE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
TAX_REFERENCE                          VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ORIG_SYSTEM_REFERENCE              VARCHAR2(2000):= FND_API.G_MISS_CHAR,
RENT_OWNED_INDICATOR                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE1                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE2                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE3                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE4                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE5                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE6                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE7                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE8                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE9                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE10                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE11                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE12                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE13                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE14                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE15                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PERSON_ATTRIBUTE_CATEGORY                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
VEHICLE_RESPONSE_CODE				 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
SALES_AGENT_EMAIL_ID				 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
NOTES						 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     add_imp_xml_element_id             NUMBER        := FND_API.G_MISS_NUM,
     address1                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     address2                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     address3                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     address4                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     city                               VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     county                             VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     province                           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     state                              VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     postal_code                        VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     country                            VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     address_lines_phonetic             VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     po_box_number                      VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     house_number                       VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     street_suffix                      VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     street                             VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     street_number                      VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     floor                              VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     suite                              VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     postal_plus4_code                  VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     identifying_address_flag           VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE1                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE2                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE3                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE4                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE5                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE6                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE7                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE8                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE9                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE10                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE11                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE12                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE13                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE14                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE15                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
DESCRIPTION                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_ATTRIBUTE_CATEGORY                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
PARTY_SITE_USE                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
LOCATION_DIRECTIONS                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
SHORT_DESCRIPTION                         VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_EFFECTIVE_DATE			VARCHAR2(2000):= FND_API.G_MISS_CHAR,
ADDRESS_EXPIRATION_DATE			VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     cp_imp_xml_element_id              NUMBER        := FND_API.G_MISS_NUM,
     phone_country_code                 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     phone_area_code                    VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     phone_number                       VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     phone_extension                    VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     em_imp_xml_element_id              NUMBER        := FND_API.G_MISS_NUM,
     email_address                      VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     fx_imp_xml_element_id              NUMBER        := FND_API.G_MISS_NUM,
     fax_country_code                 VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     fax_area_code                    VARCHAR2(2000):= FND_API.G_MISS_CHAR,
     fax_number                       VARCHAR2(2000):= FND_API.G_MISS_CHAR);



  TYPE  cust_data_in_tbl  IS TABLE OF data_in_rec_type
           INDEX BY BINARY_INTEGER;


  TYPE  cust_b2c_data_in_tbl  IS TABLE OF data_in_rec_b2c_type
           INDEX BY BINARY_INTEGER;


-- This program loads the customer data from OM to TCA.

PROCEDURE list_import_to_hz (
			    Errbuf          OUT NOCOPY     VARCHAR2,
			    Retcode         OUT NOCOPY     VARCHAR2,
			    p_import_list_header_id NUMBER,
                            p_number_of_processes NUMBER DEFAULT 1
			    );


-- This program loads the data to OM table from the flat file

PROCEDURE load_to_ams(
		    Errbuf          	       OUT NOCOPY   VARCHAR2,
		    Retcode         	       OUT NOCOPY   VARCHAR2,
   		    p_import_list_header_id    IN    NUMBER,     -- To be used as part of executable name.
   		    p_control_file             IN    VARCHAR2,   -- Name of file to be used by the SQL*Loader process.
                    p_staged_only              IN    VARCHAR2 default 'N', -- Used for staged table import.
                    p_owner_user_id            IN    NUMBER,     -- Used for list generation (resource_id)
                    p_generate_list            IN    VARCHAR2 default 'N',
                    p_list_name                IN    VARCHAR2   -- For list generation name.
		     );


-- This progam invokes the required concurrent program based on the
-- import type.

PROCEDURE list_loader (
                      p_import_list_header_id NUMBER,
		      x_request_id   OUT NOCOPY  NUMBER
                     );


-- This is the main program which starts the import process

PROCEDURE Import_process (
   			p_import_list_header_id    IN    NUMBER,
   			p_start_time               IN    DATE,
   			p_control_file             IN    VARCHAR2,   -- Name of file to be used by the SQL*Loader process.
                        p_staged_only              IN    VARCHAR2 default 'N', -- Used for staged table import.
                        p_owner_user_id            IN    NUMBER,     -- Used for list generation (resource_id)
                        p_generate_list            IN    VARCHAR2 default 'N', -- Used for staged table import.
                        p_list_name                IN    VARCHAR2,   -- For list generation name.
   			x_request_id               OUT NOCOPY   NUMBER      -- Used for concurrent program monitoring.
			);

-- This progam is for client side loading.

PROCEDURE client_load(
                      p_import_list_header_id IN    NUMBER,
                      p_owner_user_id         IN    NUMBER,
                      p_generate_list         IN    VARCHAR2 default 'N', -- Used for staged table import.
                      p_list_name             IN    VARCHAR2   -- For list generation name.
                     );


-- This progam checkes the de-duplication rules
--
PROCEDURE dedup_check(
                      p_import_list_header_id NUMBER
                     );


-- This program executes the OSO leads concurrent program.

PROCEDURE execute_lead_import (
                --            Errbuf          OUT NOCOPY     VARCHAR2,
                --            Retcode         OUT NOCOPY     VARCHAR2,
                            p_import_list_header_id NUMBER
                            );

-- This progam updates the party for the rented list
--
PROCEDURE update_rented_list_party (
       p_party_id                  IN       NUMBER,
       p_return_status             OUT NOCOPY     VARCHAR2,
       p_msg_count                 OUT NOCOPY     NUMBER,
       p_msg_data                  OUT NOCOPY     VARCHAR2
                     );


-- This program performs error checks in ams_import_interface table.

PROCEDURE execute_lead_data_validation (
                            p_import_list_header_id NUMBER,
                            p_return_status OUT NOCOPY     VARCHAR2
                            );

-- This program performs error checks in customer data.

PROCEDURE execute_cust_data_validation (
                            p_import_list_header_id NUMBER,
       			    p_return_status OUT NOCOPY     VARCHAR2
                            );

-- This program performs error checks in xml customer data.

PROCEDURE exe_custxml_data_validation (
                            p_import_list_header_id NUMBER,
                            p_return_status OUT NOCOPY     VARCHAR2
                            );


-- This program performs error checks error for product import.

PROCEDURE execute_event_data_validation (
                            p_import_list_header_id NUMBER,
                            p_return_status OUT NOCOPY     VARCHAR2
                            );


--
-- This procedure is used for existence checking for address.
--
--
PROCEDURE address_echeck(
   p_party_id              IN       NUMBER,
   x_return_status            OUT NOCOPY    VARCHAR2,
   x_msg_count                OUT NOCOPY    NUMBER,
   x_msg_data                 OUT NOCOPY    VARCHAR2,
   p_location_id           IN OUT NOCOPY   NUMBER,
   p_address1              IN       VARCHAR2,
   p_city                  IN       VARCHAR2,
   p_pcode                 IN       VARCHAR2,
   p_country               IN       VARCHAR2
                       );

--
-- This procedure is used to create Location.
--

procedure create_location (
        p_location_rec          IN      HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2,
        x_location_id           OUT NOCOPY     NUMBER
);


--
-- This procedure is used to create party site
--

procedure create_party_site (
        p_psite_rec             IN      hz_party_site_v2pub.party_site_rec_type,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2,
        x_party_site_id         OUT NOCOPY     NUMBER,
        x_party_site_number     OUT NOCOPY     VARCHAR2
);


--
-- This procedure is used to create party site use
--

procedure create_party_site_use (
        p_psiteuse_rec 		IN      hz_party_site_v2pub.party_site_use_rec_type,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2,
        x_party_site_use_id     OUT NOCOPY     NUMBER
);

--
-- This procedure is used to create contact points
--
procedure create_contact_point(
        p_cpoint_rec              IN      hz_contact_point_v2pub.contact_point_rec_type,
        p_edi_rec                 IN      hz_contact_point_v2pub.edi_rec_type,
        p_email_rec               IN      hz_contact_point_v2pub.email_rec_type,
        p_phone_rec               IN      hz_contact_point_v2pub.phone_rec_type,
        p_telex_rec               IN      hz_contact_point_v2pub.telex_rec_type,
        p_web_rec                 IN      hz_contact_point_v2pub.web_rec_type,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2,
        x_contact_point_id      OUT NOCOPY     NUMBER
);


-- This progam is for client side loading.

PROCEDURE client_load_direct (
                      p_import_list_header_id IN    NUMBER,
                      p_owner_user_id         IN    NUMBER,
                      p_generate_list         IN    VARCHAR2 default 'N', -- Used for staged table import.
                      p_list_name             IN    VARCHAR2   -- For list generation name.
                     );


-- This progam is for client side loading.

PROCEDURE client_load_cm (
                      Errbuf          OUT NOCOPY     VARCHAR2,
                      Retcode         OUT NOCOPY     VARCHAR2,
                      p_import_list_header_id IN    NUMBER,
                      p_owner_user_id         IN    NUMBER,
                      p_generate_list         IN    VARCHAR2 default 'N', -- Used for staged table import.
                      p_list_name             IN    VARCHAR2   -- For list generation name.
                     );



-- This program is for customer import for XML data.

PROCEDURE Process_customers_xml (
    p_api_version_number        IN    NUMBER,
    p_init_msg_list             IN    VARCHAR2   := FND_API.G_FALSE,
    p_commit                    IN    VARCHAR2   := FND_API.G_FALSE,
    p_validation_level          IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY   VARCHAR2,
    x_msg_count                 OUT NOCOPY   NUMBER,
    x_msg_data                  OUT NOCOPY   VARCHAR2,
    p_import_list_header_id     IN    NUMBER,
    p_update_flag               IN    VARCHAR2  DEFAULT  NULL
);


--
-- for XML updates the error in the element table
--
PROCEDURE update_element_error (
                                 p_import_list_header_id    IN    NUMBER,
                                 p_xml_element_id IN NUMBER,
                                 p_colName        IN varchar2,
                                 p_error_text     IN varchar2);


-- This Program performs validation of the RELATIONSHIP_TYPE and RELATIONSHIP_CODE
PROCEDURE execute_reltnship_validation (
                            p_import_list_header_id NUMBER,
                            p_return_status OUT NOCOPY     VARCHAR2
                            );

-- This Program will raise pre business event from list import
PROCEDURE Raise_Business_event(
                            p_import_list_header_id NUMBER,
			    p_event                 VARCHAR2
                            );
FUNCTION TEST_Pre_sub
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;


FUNCTION TEST_Post_sub
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

end AMS_ListImport_PVT;

 

/
