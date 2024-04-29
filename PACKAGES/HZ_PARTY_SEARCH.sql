--------------------------------------------------------
--  DDL for Package HZ_PARTY_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_SEARCH" AUTHID CURRENT_USER AS
/*$Header: ARHDQPSS.pls 120.12 2006/10/05 18:58:50 nsinghai noship $ */
/*#
 * Contains the Data Quality Management search and duplicate identification APIs.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname DQM Search and Duplicate Identification
 * @rep:category BUSINESS_ENTITY HZ_PARTY
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:category BUSINESS_ENTITY HZ_CONTACT
 * @rep:category BUSINESS_ENTITY HZ_CONTACT_POINT
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */

TYPE party_search_rec_type IS RECORD (
   ALL_ACCOUNT_NAMES		VARCHAR2(4000)  -- CUSTOM
  ,ALL_ACCOUNT_NUMBERS		VARCHAR2(4000)  -- CUSTOM
  ,DOMAIN_NAME		        VARCHAR2(4000)  -- CUSTOM
  ,PARTY_SOURCE_SYSTEM_REF	VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE1            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE10           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE11           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE12           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE13           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE14           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE15           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE16           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE17           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE18           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE19           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE2            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE20           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE21           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE22           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE23           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE24           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE25           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE26           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE27           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE28           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE29           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE3            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE30           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE4            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE5            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE6            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE7            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE8            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE9            VARCHAR2(4000)  -- CUSTOM
  ,ANALYSIS_FY                  VARCHAR2(5)     -- HZ_ORGANIZATION_PROFILES
  ,AVG_HIGH_CREDIT              NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,BEST_TIME_CONTACT_BEGIN      DATE    	-- HZ_ORGANIZATION_PROFILES
  ,BEST_TIME_CONTACT_END        DATE    	-- HZ_ORGANIZATION_PROFILES
  ,BRANCH_FLAG                  VARCHAR2(1)     -- HZ_ORGANIZATION_PROFILES
  ,BUSINESS_SCOPE               VARCHAR2(20)    -- HZ_ORGANIZATION_PROFILES
  ,CEO_NAME                     VARCHAR2(240)   -- HZ_ORGANIZATION_PROFILES
  ,CEO_TITLE                    VARCHAR2(240)   -- HZ_ORGANIZATION_PROFILES
  ,CONG_DIST_CODE               VARCHAR2(2)     -- HZ_ORGANIZATION_PROFILES
  ,CONTENT_SOURCE_NUMBER        VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CONTENT_SOURCE_TYPE          VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CONTROL_YR                   NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,CORPORATION_CLASS            VARCHAR2(60)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE                 VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_AGE             NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_CLASS           NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_COMMENTARY      VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_COMMENTARY10    VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_COMMENTARY2     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_COMMENTARY3     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_COMMENTARY4     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_COMMENTARY5     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_COMMENTARY6     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_COMMENTARY7     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_COMMENTARY8     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_COMMENTARY9     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_DATE            DATE    	-- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_INCD_DEFAULT    NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,CREDIT_SCORE_NATL_PERCENTILE NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,CURR_FY_POTENTIAL_REVENUE    NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,DB_RATING                    VARCHAR2(5)     -- HZ_ORGANIZATION_PROFILES
  ,DEBARMENTS_COUNT             NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,DEBARMENTS_DATE              DATE    	-- HZ_ORGANIZATION_PROFILES
  ,DEBARMENT_IND                VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,DISADV_8A_IND                VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,DUNS_NUMBER_C                VARCHAR2(30)  	-- HZ_ORGANIZATION_PROFILES
  ,EMPLOYEES_TOTAL              NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,EMP_AT_PRIMARY_ADR           VARCHAR2(10)    -- HZ_ORGANIZATION_PROFILES
  ,EMP_AT_PRIMARY_ADR_EST_IND   VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,EMP_AT_PRIMARY_ADR_MIN_IND   VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,EMP_AT_PRIMARY_ADR_TEXT      VARCHAR2(12)    -- HZ_ORGANIZATION_PROFILES
  ,ENQUIRY_DUNS                 VARCHAR2(15)    -- HZ_ORGANIZATION_PROFILES
  ,EXPORT_IND                   VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE                VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_AGE            NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_CLASS          NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_COMMENTARY     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_COMMENTARY10   VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_COMMENTARY2    VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_COMMENTARY3    VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_COMMENTARY4    VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_COMMENTARY5    VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_COMMENTARY6    VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_COMMENTARY7    VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_COMMENTARY8    VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_COMMENTARY9    VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_DATE           DATE    	-- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_INCD_DEFAULT   NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,FAILURE_SCORE_OVERRIDE_CODE  VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,FISCAL_YEAREND_MONTH         VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,GLOBAL_FAILURE_SCORE         VARCHAR2(5)     -- HZ_ORGANIZATION_PROFILES
  ,GSA_INDICATOR_FLAG           VARCHAR2(1)     -- HZ_ORGANIZATION_PROFILES
  ,HIGH_CREDIT                  NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,HQ_BRANCH_IND                VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,IMPORT_IND                   VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,INCORP_YEAR                  NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,INTERNAL_FLAG                VARCHAR2(1)     -- HZ_ORGANIZATION_PROFILES
  ,JGZZ_FISCAL_CODE             VARCHAR2(20)    -- HZ_ORGANIZATION_PROFILES
  ,PARTY_ALL_NAMES              VARCHAR2(2000)  -- HZ_ORGANIZATION_PROFILES
  ,KNOWN_AS	                VARCHAR2(240)   -- HZ_ORGANIZATION_PROFILES
  ,KNOWN_AS2	                VARCHAR2(240)   -- HZ_ORGANIZATION_PROFILES
  ,KNOWN_AS3	                VARCHAR2(240)   -- HZ_ORGANIZATION_PROFILES
  ,KNOWN_AS4	                VARCHAR2(240)   -- HZ_ORGANIZATION_PROFILES
  ,KNOWN_AS5	                VARCHAR2(240)   -- HZ_ORGANIZATION_PROFILES
  ,LABOR_SURPLUS_IND            VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,LEGAL_STATUS                 VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,LINE_OF_BUSINESS             VARCHAR2(240)   -- HZ_ORGANIZATION_PROFILES
  ,LOCAL_ACTIVITY_CODE          VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,LOCAL_ACTIVITY_CODE_TYPE     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,LOCAL_BUS_IDENTIFIER         VARCHAR2(60)    -- HZ_ORGANIZATION_PROFILES
  ,LOCAL_BUS_IDEN_TYPE          VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,MAXIMUM_CREDIT_CURRENCY_CODE VARCHAR2(240)   -- HZ_ORGANIZATION_PROFILES
  ,MAXIMUM_CREDIT_RECOMMENDATION NUMBER   	-- HZ_ORGANIZATION_PROFILES
  ,MINORITY_OWNED_IND           VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,MINORITY_OWNED_TYPE          VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,NEXT_FY_POTENTIAL_REVENUE    NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,OOB_IND                      VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,ORGANIZATION_NAME            VARCHAR2(360)   -- HZ_ORGANIZATION_PROFILES
  ,ORGANIZATION_NAME_PHONETIC   VARCHAR2(320)   -- HZ_ORGANIZATION_PROFILES
  ,ORGANIZATION_TYPE            VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,PARENT_SUB_IND               VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,PAYDEX_NORM                  VARCHAR2(3)     -- HZ_ORGANIZATION_PROFILES
  ,PAYDEX_SCORE                 VARCHAR2(3)     -- HZ_ORGANIZATION_PROFILES
  ,PAYDEX_THREE_MONTHS_AGO      VARCHAR2(3)     -- HZ_ORGANIZATION_PROFILES
  ,PREF_FUNCTIONAL_CURRENCY     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,PRINCIPAL_NAME               VARCHAR2(240)   -- HZ_ORGANIZATION_PROFILES
  ,PRINCIPAL_TITLE              VARCHAR2(240)   -- HZ_ORGANIZATION_PROFILES
  ,PUBLIC_PRIVATE_OWNERSHIP_FLAG VARCHAR2(1)    -- HZ_ORGANIZATION_PROFILES
  ,REGISTRATION_TYPE            VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,RENT_OWN_IND                 VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,SIC_CODE                     VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,SIC_CODE_TYPE                VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,SMALL_BUS_IND                VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,TAX_NAME                     VARCHAR2(60)    -- HZ_ORGANIZATION_PROFILES
  ,TAX_REFERENCE                VARCHAR2(50)    -- HZ_ORGANIZATION_PROFILES
  ,TOTAL_EMPLOYEES_TEXT         VARCHAR2(60)    -- HZ_ORGANIZATION_PROFILES
  ,TOTAL_EMP_EST_IND            VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,TOTAL_EMP_MIN_IND            VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,TOTAL_EMPLOYEES_IND          VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,TOTAL_PAYMENTS               NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,WOMAN_OWNED_IND              VARCHAR2(30)    -- HZ_ORGANIZATION_PROFILES
  ,YEAR_ESTABLISHED             NUMBER  	-- HZ_ORGANIZATION_PROFILES
  ,CATEGORY_CODE                VARCHAR2(30)    -- HZ_PARTIES
  ,COMPETITOR_FLAG              VARCHAR2(1)     -- HZ_PARTIES
  ,DO_NOT_MAIL_FLAG             VARCHAR2(1)     -- HZ_PARTIES
  ,GROUP_TYPE                   VARCHAR2(30)    -- HZ_PARTIES
  ,LANGUAGE_NAME                VARCHAR2(4)     -- HZ_PARTIES
  ,PARTY_NAME                   VARCHAR2(360)   -- HZ_PARTIES
  ,PARTY_NUMBER                 VARCHAR2(30)    -- HZ_PARTIES
  ,PARTY_TYPE                   VARCHAR2(30)    -- HZ_PARTIES
  ,REFERENCE_USE_FLAG           VARCHAR2(1)     -- HZ_PARTIES
  ,SALUTATION                   VARCHAR2(60)    -- HZ_PARTIES
  ,STATUS                       VARCHAR2(1)     -- HZ_PARTIES
  ,THIRD_PARTY_FLAG             VARCHAR2(1)     -- HZ_PARTIES
  ,VALIDATED_FLAG               VARCHAR2(1)     -- HZ_PARTIES
  ,DATE_OF_BIRTH                DATE    	-- HZ_PERSON_PROFILES
  ,DATE_OF_DEATH                DATE    	-- HZ_PERSON_PROFILES
  ,EFFECTIVE_START_DATE         DATE    	-- HZ_PERSON_PROFILES
  ,EFFECTIVE_END_DATE           DATE    	-- HZ_PERSON_PROFILES
  ,DECLARED_ETHNICITY           VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,GENDER                       VARCHAR2(30)    -- HZ_PERSON_PROFILES
  ,HEAD_OF_HOUSEHOLD_FLAG       VARCHAR2(1)     -- HZ_PERSON_PROFILES
  ,HOUSEHOLD_INCOME             NUMBER  	-- HZ_PERSON_PROFILES
  ,HOUSEHOLD_SIZE               NUMBER  	-- HZ_PERSON_PROFILES
  ,LAST_KNOWN_GPS               VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,MARITAL_STATUS               VARCHAR2(30)    -- HZ_PERSON_PROFILES
  ,MARITAL_STATUS_EFFECTIVE_DATE DATE    	-- HZ_PERSON_PROFILES
  ,MIDDLE_NAME_PHONETIC         VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,PERSONAL_INCOME              NUMBER  	-- HZ_PERSON_PROFILES
  ,PERSON_ACADEMIC_TITLE        VARCHAR2(30)    -- HZ_PERSON_PROFILES
  ,PERSON_FIRST_NAME            VARCHAR2(150)   -- HZ_PERSON_PROFILES
  ,PERSON_FIRST_NAME_PHONETIC   VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,PERSON_IDENTIFIER            VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,PERSON_IDEN_TYPE             VARCHAR2(30)    -- HZ_PERSON_PROFILES
  ,PERSON_INITIALS              VARCHAR2(6)     -- HZ_PERSON_PROFILES
  ,PERSON_LAST_NAME             VARCHAR2(150)   -- HZ_PERSON_PROFILES
  ,PERSON_LAST_NAME_PHONETIC    VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,PERSON_MIDDLE_NAME           VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,PERSON_NAME                  VARCHAR2(450)   -- HZ_PERSON_PROFILES
  ,PERSON_NAME_PHONETIC         VARCHAR2(320)   -- HZ_PERSON_PROFILES
  ,PERSON_NAME_SUFFIX           VARCHAR2(30)    -- HZ_PERSON_PROFILES
  ,PERSON_PREVIOUS_LAST_NAME    VARCHAR2(150)   -- HZ_PERSON_PROFILES
  ,PERSON_PRE_NAME_ADJUNCT      VARCHAR2(30)    -- HZ_PERSON_PROFILES
  ,PERSON_TITLE                 VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,PLACE_OF_BIRTH               VARCHAR2(60)    -- HZ_PERSON_PROFILES
);


TYPE party_site_search_rec_type IS RECORD (
   ADDRESS			VARCHAR2(4000)  -- CUSTOM
  ,ADDR_SOURCE_SYSTEM_REF	VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE1            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE10           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE11           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE12           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE13           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE14           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE15           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE16           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE17           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE18           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE19           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE2            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE20           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE21           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE22           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE23           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE24           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE25           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE26           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE27           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE28           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE29           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE3            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE30           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE4            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE5            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE6            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE7            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE8            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE9            VARCHAR2(4000)  -- CUSTOM
  ,ADDRESS1                     VARCHAR2(240)   -- HZ_LOCATIONS
  ,ADDRESS2                     VARCHAR2(240)   -- HZ_LOCATIONS
  ,ADDRESS3                     VARCHAR2(240)   -- HZ_LOCATIONS
  ,ADDRESS4                     VARCHAR2(240)   -- HZ_LOCATIONS
  ,ADDRESS_EFFECTIVE_DATE       DATE    	-- HZ_LOCATIONS
  ,ADDRESS_EXPIRATION_DATE      DATE    	-- HZ_LOCATIONS
  ,ADDRESS_LINES_PHONETIC       VARCHAR2(560)   -- HZ_LOCATIONS
  ,CITY                 	VARCHAR2(60)    -- HZ_LOCATIONS
  ,CLLI_CODE                    VARCHAR2(60)    -- HZ_LOCATIONS
  ,CONTENT_SOURCE_TYPE          VARCHAR2(30)    -- HZ_LOCATIONS
  ,COUNTRY                      VARCHAR2(60)    -- HZ_LOCATIONS
  ,COUNTY                       VARCHAR2(60)    -- HZ_LOCATIONS
  ,FLOOR                        VARCHAR2(50)    -- HZ_LOCATIONS
  ,HOUSE_NUMBER                 VARCHAR2(50)    -- HZ_LOCATIONS
  ,LANGUAGE                     VARCHAR2(4)     -- HZ_LOCATIONS
  ,POSITION                     VARCHAR2(50)    -- HZ_LOCATIONS
  ,POSTAL_CODE                  VARCHAR2(60)    -- HZ_LOCATIONS
  ,POSTAL_PLUS4_CODE            VARCHAR2(10)    -- HZ_LOCATIONS
  ,PO_BOX_NUMBER                VARCHAR2(50)    -- HZ_LOCATIONS
  ,PROVINCE                     VARCHAR2(60)    -- HZ_LOCATIONS
  ,SALES_TAX_GEOCODE            VARCHAR2(30)    -- HZ_LOCATIONS
  ,SALES_TAX_INSIDE_CITY_LIMITS VARCHAR2(30)    -- HZ_LOCATIONS
  ,STATE                        VARCHAR2(60)    -- HZ_LOCATIONS
  ,STREET                       VARCHAR2(50)    -- HZ_LOCATIONS
  ,STREET_NUMBER                VARCHAR2(50)    -- HZ_LOCATIONS
  ,STREET_SUFFIX                VARCHAR2(50)    -- HZ_LOCATIONS
  ,SUITE                        VARCHAR2(50)    -- HZ_LOCATIONS
  ,TRAILING_DIRECTORY_CODE      VARCHAR2(60)    -- HZ_LOCATIONS
  ,VALIDATED_FLAG               VARCHAR2(1)     -- HZ_LOCATIONS
  ,IDENTIFYING_ADDRESS_FLAG     VARCHAR2(1)     -- HZ_PARTY_SITES
  ,MAILSTOP                     VARCHAR2(60)    -- HZ_PARTY_SITES
  ,PARTY_SITE_NAME              VARCHAR2(240)   -- HZ_PARTY_SITES
  ,PARTY_SITE_NUMBER            VARCHAR2(30)    -- HZ_PARTY_SITES
  ,STATUS                       VARCHAR2(1)     -- HZ_PARTY_SITES
);


TYPE contact_search_rec_type IS RECORD (
  CONTACT_SOURCE_SYSTEM_REF	VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE1             VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE10           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE11           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE12           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE13           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE14           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE15           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE16           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE17           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE18           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE19           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE2            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE20           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE21           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE22           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE23           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE24           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE25           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE26           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE27           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE28           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE29           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE3            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE30           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE4            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE5            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE6            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE7            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE8            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE9            VARCHAR2(4000)  -- CUSTOM
  ,CONTACT_NUMBER               VARCHAR2(30)    -- HZ_ORG_CONTACTS
  ,CONTACT_NAME                 VARCHAR2(4000)    -- HZ_ORG_CONTACTS
  ,DECISION_MAKER_FLAG          VARCHAR2(1)     -- HZ_ORG_CONTACTS
  ,JOB_TITLE                    VARCHAR2(100)   -- HZ_ORG_CONTACTS
  ,JOB_TITLE_CODE               VARCHAR2(30)    -- HZ_ORG_CONTACTS
  ,MAIL_STOP                    VARCHAR2(60)    -- HZ_ORG_CONTACTS
  ,NATIVE_LANGUAGE              VARCHAR2(30)    -- HZ_ORG_CONTACTS
  ,OTHER_LANGUAGE_1             VARCHAR2(30)    -- HZ_ORG_CONTACTS
  ,OTHER_LANGUAGE_2             VARCHAR2(30)    -- HZ_ORG_CONTACTS
  ,RANK                 	VARCHAR2(30)    -- HZ_ORG_CONTACTS
  ,REFERENCE_USE_FLAG           VARCHAR2(1)     -- HZ_ORG_CONTACTS
  ,TITLE                        VARCHAR2(30)    -- HZ_ORG_CONTACTS
  ,RELATIONSHIP_TYPE      	VARCHAR2(30)    -- HZ_PARTY_RELATIONSHIPS
  ,BEST_TIME_CONTACT_BEGIN      DATE    	-- HZ_PERSON_PROFILES
  ,BEST_TIME_CONTACT_END        DATE    	-- HZ_PERSON_PROFILES
  ,DATE_OF_BIRTH                DATE    	-- HZ_PERSON_PROFILES
  ,DATE_OF_DEATH                DATE    	-- HZ_PERSON_PROFILES
  ,JGZZ_FISCAL_CODE             VARCHAR2(20)    -- HZ_PERSON_PROFILES
  ,KNOWN_AS                     VARCHAR2(240)   -- HZ_PERSON_PROFILES
  ,PERSON_ACADEMIC_TITLE        VARCHAR2(30)    -- HZ_PERSON_PROFILES
  ,PERSON_FIRST_NAME            VARCHAR2(150)   -- HZ_PERSON_PROFILES
  ,PERSON_FIRST_NAME_PHONETIC   VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,PERSON_IDENTIFIER            VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,PERSON_IDEN_TYPE             VARCHAR2(30)    -- HZ_PERSON_PROFILES
  ,PERSON_INITIALS              VARCHAR2(6)     -- HZ_PERSON_PROFILES
  ,PERSON_LAST_NAME             VARCHAR2(150)   -- HZ_PERSON_PROFILES
  ,PERSON_LAST_NAME_PHONETIC    VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,PERSON_MIDDLE_NAME           VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,PERSON_NAME                  VARCHAR2(450)   -- HZ_PERSON_PROFILES
  ,PERSON_NAME_PHONETIC         VARCHAR2(320)   -- HZ_PERSON_PROFILES
  ,PERSON_NAME_SUFFIX           VARCHAR2(30)    -- HZ_PERSON_PROFILES
  ,PERSON_PREVIOUS_LAST_NAME    VARCHAR2(150)   -- HZ_PERSON_PROFILES
  ,PERSON_TITLE                 VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,PLACE_OF_BIRTH               VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,TAX_NAME                     VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,TAX_REFERENCE                VARCHAR2(60)    -- HZ_PERSON_PROFILES
  ,CONTENT_SOURCE_TYPE          VARCHAR2(30)    -- HZ_RELATIONSHIPS
  ,DIRECTIONAL_FLAG             VARCHAR2(1)     -- HZ_RELATIONSHIPS
);


TYPE contact_point_search_rec_type IS RECORD (
   CONTACT_POINT_TYPE     	VARCHAR2(30)    -- HZ_CONTACT_POINTS
  ,CPT_SOURCE_SYSTEM_REF	VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE1            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE10           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE11           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE12           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE13           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE14           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE15           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE16           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE17           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE18           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE19           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE2            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE20           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE21           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE22           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE23           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE24           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE25           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE26           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE27           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE28           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE29           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE3            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE30           VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE4            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE5            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE6            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE7            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE8            VARCHAR2(4000)  -- CUSTOM
  ,CUSTOM_ATTRIBUTE9            VARCHAR2(4000)  -- CUSTOM
  ,CONTENT_SOURCE_TYPE          VARCHAR2(30)    -- HZ_CONTACT_POINTS
  ,EDI_ECE_TP_LOCATION_CODE     VARCHAR2(40)    -- HZ_CONTACT_POINTS
  ,EDI_ID_NUMBER                VARCHAR2(30)    -- HZ_CONTACT_POINTS
  ,EDI_PAYMENT_FORMAT           VARCHAR2(30)    -- HZ_CONTACT_POINTS
  ,EDI_PAYMENT_METHOD           VARCHAR2(30)    -- HZ_CONTACT_POINTS
  ,EDI_REMITTANCE_INSTRUCTION   VARCHAR2(30)    -- HZ_CONTACT_POINTS
  ,EDI_REMITTANCE_METHOD        VARCHAR2(30)    -- HZ_CONTACT_POINTS
  ,EDI_TP_HEADER_ID             NUMBER  	-- HZ_CONTACT_POINTS
  ,EDI_TRANSACTION_HANDLING     VARCHAR2(25)    -- HZ_CONTACT_POINTS
  ,EMAIL_ADDRESS                VARCHAR2(2000)  -- HZ_CONTACT_POINTS
  ,EMAIL_FORMAT                 VARCHAR2(30)    -- HZ_CONTACT_POINTS
  ,FLEX_FORMAT_PHONE_NUMBER     VARCHAR2(4000)  -- CUSTOM
  ,LAST_CONTACT_DT_TIME         DATE    	-- HZ_CONTACT_POINTS
  ,PHONE_AREA_CODE              VARCHAR2(10)    -- HZ_CONTACT_POINTS
  ,PHONE_CALLING_CALENDAR       VARCHAR2(30)    -- HZ_CONTACT_POINTS
  ,PHONE_COUNTRY_CODE           VARCHAR2(10)    -- HZ_CONTACT_POINTS
  ,PHONE_EXTENSION              VARCHAR2(20)    -- HZ_CONTACT_POINTS
  ,PHONE_LINE_TYPE              VARCHAR2(30)    -- HZ_CONTACT_POINTS
  ,PHONE_NUMBER                 VARCHAR2(40)    -- HZ_CONTACT_POINTS
  ,PRIMARY_FLAG                 VARCHAR2(1)     -- HZ_CONTACT_POINTS
  ,RAW_PHONE_NUMBER             VARCHAR2(2000)  -- HZ_CONTACT_POINTS
  ,TELEPHONE_TYPE               VARCHAR2(30)    -- HZ_CONTACT_POINTS
  ,TELEX_NUMBER                 VARCHAR2(50)    -- HZ_CONTACT_POINTS
  ,TIME_ZONE                    NUMBER  	-- HZ_CONTACT_POINTS
  ,URL                  	VARCHAR2(2000)  -- HZ_CONTACT_POINTS
  ,WEB_TYPE                     VARCHAR2(60)    -- HZ_CONTACT_POINTS
  ,STATUS                       VARCHAR2(1)     -- HZ_CONTACT_POINTS
  ,CONTACT_POINT_PURPOSE        VARCHAR2(30)    -- HZ_CONTACT_POINTS
);

TYPE party_scores IS RECORD (
  SCORE1			NUMBER := 0,
  SCORE2			NUMBER := 0,
  SCORE3			NUMBER := 0,
  SCORE4			NUMBER := 0,
  SCORE5			NUMBER := 0,
  SCORE6			NUMBER := 0,
  SCORE7			NUMBER := 0,
  SCORE8			NUMBER := 0,
  SCORE9			NUMBER := 0,
  SCORE10			NUMBER := 0,
  SCORE11			NUMBER := 0,
  SCORE12			NUMBER := 0,
  SCORE13			NUMBER := 0,
  SCORE14			NUMBER := 0,
  SCORE15			NUMBER := 0,
  SCORE16			NUMBER := 0,
  SCORE17			NUMBER := 0,
  SCORE18			NUMBER := 0,
  SCORE19			NUMBER := 0,
  SCORE20			NUMBER := 0,
  SCORE21			NUMBER := 0,
  SCORE22			NUMBER := 0,
  SCORE23			NUMBER := 0,
  SCORE24			NUMBER := 0,
  SCORE25			NUMBER := 0,
  SCORE26			NUMBER := 0,
  SCORE27			NUMBER := 0,
  SCORE28			NUMBER := 0,
  SCORE29			NUMBER := 0,
  SCORE30			NUMBER := 0,
  SCORE31			NUMBER := 0,
  SCORE32			NUMBER := 0,
  SCORE33			NUMBER := 0,
  SCORE34			NUMBER := 0,
  SCORE35			NUMBER := 0,
  SCORE36			NUMBER := 0,
  SCORE37			NUMBER := 0,
  SCORE38			NUMBER := 0,
  SCORE39			NUMBER := 0,
  SCORE40			NUMBER := 0,
  SCORE41			NUMBER := 0,
  SCORE42			NUMBER := 0,
  SCORE43			NUMBER := 0,
  SCORE44			NUMBER := 0,
  SCORE45			NUMBER := 0,
  SCORE46			NUMBER := 0,
  SCORE47			NUMBER := 0,
  SCORE48			NUMBER := 0,
  SCORE49			NUMBER := 0,
  SCORE50			NUMBER := 0
);

TYPE ScoreList IS TABLE of party_scores
     INDEX BY BINARY_INTEGER;

TYPE IDList is TABLE of NUMBER
     INDEX BY BINARY_INTEGER;

TYPE TXList is TABLE of VARCHAR2(2000)
     INDEX BY BINARY_INTEGER;

TYPE party_site_list IS TABLE OF party_site_search_rec_type
     INDEX BY BINARY_INTEGER;
TYPE contact_list IS TABLE OF contact_search_rec_type
     INDEX BY BINARY_INTEGER;
TYPE contact_point_list IS TABLE OF contact_point_search_rec_type
     INDEX BY BINARY_INTEGER;

TYPE cpt_type_array IS  TABLE OF NUMBER(15) INDEX BY VARCHAR2(30) ;

TYPE score_rec IS RECORD (
  total_score	NUMBER,
  party_score NUMBER,
  party_site_score NUMBER,
  contact_score NUMBER,
  contact_point_score NUMBER,
  party_id NUMBER,
  party_site_id NUMBER,
  org_contact_id NUMBER,
  contact_point_id NUMBER,
  cpt_type_match cpt_type_array);

TYPE score_list IS TABLE OF score_rec index by BINARY_INTEGER;

TYPE search_rec_type IS RECORD (
  party_search_rec 		party_search_rec_type,
  party_site_search_rec 	party_site_search_rec_type,
  contact_search_rec 		contact_search_rec_type,
  contact_point_search_rec 	contact_point_search_rec_type
);

G_MISS_PARTY_SEARCH_REC party_search_rec_type;
G_MISS_PARTY_SITE_LIST party_site_list;
G_MISS_CONTACT_LIST contact_list;
G_MISS_CONTACT_POINT_LIST contact_point_list;
G_MISS_ID_LIST IDList;

/*===========================================================================+
 | PROCEDURE
 |              find_parties
 |
 | DESCRIPTION
 |              Find a set of parties given the search criteria.
 |              Results are stored in the temporary table, HZ_MATCHED_PARTIES_GT
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_rule_id
 |                    p_search_cond
 |                    p_primary_and_flag
 |
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Srinivasa Rangan   27-APR-01  Created
 |
 +===========================================================================*/
/*#
 * Finds parties based on the passed search criteria. The API finds parties that match party level
 * search criteria, and/or have addresses, contacts, and/or contact points that match corresponding
 * address, contact, or contact point criteria. When the matching is based on address and contact point
 * search criteria, the API finds parties of type Organization, looking at the organization end of relationships.
 * The API returns the set of matches to the HZ_MATCHED_PARTIES_GT table, which holds the PARTY_ID and
 * score of all matches. Use the x_search_ctx_id value that the API returns to filter results from this table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Find Parties
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE find_parties (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN	NUMBER,
        p_party_search_rec	IN	party_search_rec_type,
        p_party_site_list	IN	party_site_list,
	p_contact_list		IN	contact_list,
	p_contact_point_list	IN	contact_point_list,
        p_restrict_sql          IN      VARCHAR2,
        p_match_type          	IN      VARCHAR2,
        p_search_merged         IN      VARCHAR2,
        x_search_ctx_id         OUT  	NOCOPY NUMBER,
        x_num_matches           OUT  	NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

-- Old signature. Retained for backward compatibility
PROCEDURE find_parties (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        x_rule_id               IN OUT  NOCOPY NUMBER,
        p_party_search_rec	IN	party_search_rec_type,
        p_party_site_list	IN	party_site_list,
	p_contact_list		IN	contact_list,
	p_contact_point_list	IN	contact_point_list,
        p_restrict_sql          IN      VARCHAR2,
        p_search_merged         IN      VARCHAR2,
        x_search_ctx_id         IN OUT  NOCOPY NUMBER,
        x_num_matches           IN OUT  NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*#
 * Finds persons based on the passed search criteria. The API finds persons that match party level
 * search criteria, and/or have addresses, contacts, and/or contact points that match corresponding
 * address, contact, or contact point criteria. The API always returns parties of type Person, even if
 * the matching is based on address or contact point search criteria, by looking at the person end of
 * relationships. The API returns the set of matches to the HZ_MATCHED_PARTIES_GT table, which holds the
 * PARTY_ID and score of all matches. Use the x_search_ctx_id value that the API returns to filter results
 * from this table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Find Persons
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE find_persons (
      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
      p_rule_id               IN      NUMBER,
      p_party_search_rec      IN      party_search_rec_type,
      p_party_site_list       IN      party_site_list,
      p_contact_list          IN      contact_list,
      p_contact_point_list    IN      contact_point_list,
      p_restrict_sql          IN      VARCHAR2,
      p_match_type            IN      VARCHAR2,
      x_search_ctx_id         OUT     NOCOPY NUMBER,
      x_num_matches           OUT     NOCOPY NUMBER,
      x_return_status         OUT     NOCOPY VARCHAR2,
      x_msg_count             OUT     NOCOPY NUMBER,
      x_msg_data              OUT     NOCOPY VARCHAR2
);


/*===========================================================================+
 | PROCEDURE
 |
 |              get_matching_party_sites
 |
 | DESCRIPTION
 |              Find a set of parties given the search criteria.
 |              Results are stored in the temporary table,
 |              HZ_MATCHED_PARTY_SITES_GT
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_rule_id
 |                    p_party_id
 |                    p_ps_search_cond
 |
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Srinivasa Rangan   27-APR-01  Created
 |
 +===========================================================================*/

/*#
 * Finds party sites based on the passed search criteria. The API finds all party sites that
 * match the address search criteria passed into the p_party_site_list parameter, and/or have
 * contact points, defined for party sites, that match contact point criteria passed into the
 * p_contact_point_list parameter. The API returns the set of matches to the HZ_MATCHED_PARTY_SITES_GT
 * table, which holds the PARTY_SITE_ID, PARTY_ID, and score of all matches. Use the x_search_ctx_id value
 * that the API returns to filter results from this table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Find Party Sites
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_matching_party_sites (
	p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
	p_rule_id		IN	NUMBER,
	p_party_id		IN	NUMBER,
	p_party_site_list	IN	PARTY_SITE_LIST,
	p_contact_point_list	IN	CONTACT_POINT_LIST,
        p_restrict_sql		IN	VARCHAR2,
	p_match_type		IN	VARCHAR2,
        x_search_ctx_id         OUT  	NOCOPY NUMBER,
        x_num_matches         	OUT  	NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);


PROCEDURE get_matching_party_sites (
	p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
	p_rule_id		IN	NUMBER,
	p_party_id		IN	NUMBER,
	p_party_site_list	IN	PARTY_SITE_LIST,
	p_contact_point_list	IN	CONTACT_POINT_LIST,
        x_search_ctx_id         OUT  	NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*===========================================================================+
 | PROCEDURE
 |              get_matching_contacts
 |
 | DESCRIPTION
 |              Find a set of parties given the search criteria.
 |              Results are stored in the temporary table,
 |              HZ_MATCHED_CONTACTS_GT
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_rule_id
 |                    p_party_id
 |                    p_contact_search_cond
 |
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Srinivasa Rangan   27-APR-01  Created
 |
 +===========================================================================*/

/*#
 * Finds contacts based on the passed search criteria. The API finds all contacts that match
 * the contact search criteria passed into the p_contact_list parameter, and/or have contact points,
 * defined for contacts, that match contact point criteria passed into the p_contact_point_list parameter.
 * The API returns the set of matches to the HZ_MATCHED_CONTACTS_GT table, which holds the ORG_CONTACT_ID,
 * PARTY_ID, and score of all matches. Use the x_search_ctx_id value that the API returns to filter results
 * from this table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Find Contacts
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_matching_contacts (
	p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
	p_rule_id		IN	NUMBER,
	p_party_id		IN	NUMBER,
	p_contact_list		IN	CONTACT_LIST,
	p_contact_point_list	IN	CONTACT_POINT_LIST,
        p_restrict_sql		IN	VARCHAR2,
	p_match_type		IN	VARCHAR2,
        x_search_ctx_id         OUT  	NOCOPY NUMBER,
        x_num_matches         	OUT  	NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);


PROCEDURE get_matching_contacts (
	p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
	p_rule_id		IN	NUMBER,
	p_party_id		IN	NUMBER,
	p_contact_list		IN	CONTACT_LIST,
	p_contact_point_list	IN	CONTACT_POINT_LIST,
        x_search_ctx_id         OUT  	NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*===========================================================================+
 | PROCEDURE
 |              get_matching_contact_points
 |
 | DESCRIPTION
 |              Find a set of contact points given the search criteria.
 |              Results are stored in the temporary table,
 |              HZ_MATCHED_CONTACT_PTS_GT
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_rule_id
 |                    p_party_id
 |                    p_cont_pt_search_cond
 |
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Srinivasa Rangan   27-APR-01  Created
 |
 +===========================================================================*/

/*#
 * Finds contact points based on the passed search criteria. The API finds all contact points that
 * match the contact point search criteria passed into the p_contact_point_list parameter. The API
 * returns the set of matches to the HZ_MATCHED_CPTS_GT table, which holds the CONTACT_POINT_ID,
 * PARTY_ID, and score of all matches. Use the x_search_ctx_id value that the API returns to filter results
 * from this table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Find Contact Points
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_matching_contact_points (
	p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
	p_rule_id		IN	NUMBER,
	p_party_id		IN	NUMBER,
	p_contact_point_list	IN	CONTACT_POINT_LIST,
        p_restrict_sql		IN	VARCHAR2,
	p_match_type		IN	VARCHAR2,
        x_search_ctx_id         OUT  	NOCOPY NUMBER,
        x_num_matches         	OUT  	NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);


PROCEDURE get_matching_contact_points (
	p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
	p_rule_id		IN	NUMBER,
	p_party_id		IN	NUMBER,
	p_contact_point_list	IN	CONTACT_POINT_LIST,
        x_search_ctx_id         OUT  	NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*===========================================================================+
 | PROCEDURE
 |		get_party_score_details
 | DESCRIPTION
 |              Find a set of parties given the search criteria.
 |              Results are stored in the temporary table,
 |              HZ_PARTY_SCORE_DTLS_GT
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_rule_id
 |                    p_party_id
 |                    p_search_cond
 |
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Srinivasa Rangan   27-APR-01  Created
 |
 +===========================================================================*/

PROCEDURE get_party_score_details (
	p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
	p_rule_id		IN	NUMBER,
	p_party_id		IN	NUMBER,
        p_search_ctx_id         IN      NUMBER,
        p_party_search_rec      IN      party_search_rec_type,
        p_party_site_list       IN      party_site_list,
        p_contact_list          IN      contact_list,
        p_contact_point_list    IN      contact_point_list,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*#
 * Gets details about how a party matches the input search criteria. Though not required, the API is
 * usually called after calls to the find_parties API, to display how a match is determined. The API
 * compares the input search criteria against the party passed into the p_party_id paramter, and inserts
 * all matching attributes into the HZ_PARTY_SCORE_DTLS_GT table. The columns in this table include: ATTRIBUTE,
 * the matching attribute; ENTERED_VALUE, the attribute value entered for the search criterion; MATCHED_VALUE,
 * the attribute value for the p_party_id party, and ASSIGNED_SCORE, the score assigned to the match.
 * The x_search_ctx_id is used as an IN/OUT parameter. If this API is called right after a call to find_parties,
 * then this API can use the same search_context_id and would retain x_search_context_id as is. If the
 * search_context_id is not passed in, then this API generates and populates a search_context_id in the
 * x_search_context_id variable. In either case, use the x_search_context_id value that the API returns to
 * filter results from the HZ_PARTY_SCORE_DTLS_GT table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Score Details
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_score_details (
	p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
	p_rule_id		IN	NUMBER,
	p_party_id		IN	NUMBER,
        p_party_search_rec      IN      party_search_rec_type,
        p_party_site_list       IN      party_site_list,
        p_contact_list          IN      contact_list,
        p_contact_point_list    IN      contact_point_list,
        x_search_ctx_id         IN OUT  NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*** New API ****/

/*#
 * Finds parties and party details based on search criteria. This API performs the same matching as
 * the find_parties API, but returns more details regarding which party sites, contacts, and contact
 * points matched. This API returns the set of matches to the HZ_MATCHED_PARTIES_GT table, which holds
 * the PARTY_ID and score of all matches. The API also inserts matching party sites into
 * HZ_MATCHED_PARTY_SITES_GT, matching contacts into HZ_MATCHED_CONTACTS_GT, and matching contact points
 * into HZ_MATCHED_CPTS_GT. Use the x_search_ctx_id value that this API returns to filter results from all
 * above tables. Use this API for UIs that provide access to the above details after displaying matched parties.
 * If only matched parties need to be displayed, then use find_parties for better performance.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Find Parties and Details
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE find_party_details (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN 	NUMBER,
        p_party_search_rec      IN      party_search_rec_type,
        p_party_site_list       IN      party_site_list,
        p_contact_list          IN      contact_list,
        p_contact_point_list    IN      contact_point_list,
        p_restrict_sql          IN      VARCHAR2,
        p_match_type            IN      VARCHAR2,
        p_search_merged         IN      VARCHAR2,
        x_search_ctx_id         OUT  	NOCOPY NUMBER,
        x_num_matches           OUT     NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*#
 * Identifies duplicates of a specific party. The API finds duplicates within a subset or across the
 * entire TCA Registry, depending on what is passed into the p_restrict_sql parameter. The API inserts
 * duplicates into the HZ_MATCHED_PARTIES_GT table if the p_dup_batch_id parameter is null. If this
 * parameter is not null, then the API creates a duplicate set with the list of duplicates in the HZ_DUP_SET
 * and HZ_DUP_SET_PARTIES tables. Use the x_search_ctx_id value that the API returns to filter results from
 * the HZ_MATCHED_PARTIES_GT table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Identify Duplicate Parties
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE find_duplicate_parties (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN 	NUMBER,
        p_party_id              IN 	NUMBER,
        p_restrict_sql          IN      VARCHAR2,
        p_match_type            IN      VARCHAR2,
        p_dup_batch_id          IN 	NUMBER,
        p_search_merged         IN      VARCHAR2,
        x_dup_set_id            OUT     NOCOPY NUMBER,
        x_search_ctx_id         OUT     NOCOPY NUMBER,
        x_num_matches           OUT     NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

PROCEDURE find_parties_dynamic (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN 	NUMBER,
	p_attrib_id1		IN	NUMBER,
	p_attrib_id2		IN	NUMBER,
	p_attrib_id3		IN	NUMBER,
	p_attrib_id4		IN	NUMBER,
	p_attrib_id5		IN	NUMBER,
	p_attrib_id6		IN	NUMBER,
	p_attrib_id7		IN	NUMBER,
	p_attrib_id8		IN	NUMBER,
	p_attrib_id9		IN	NUMBER,
	p_attrib_id10		IN	NUMBER,
	p_attrib_id11		IN	NUMBER,
	p_attrib_id12		IN	NUMBER,
	p_attrib_id13		IN	NUMBER,
	p_attrib_id14		IN	NUMBER,
	p_attrib_id15		IN	NUMBER,
	p_attrib_id16		IN	NUMBER,
	p_attrib_id17		IN	NUMBER,
	p_attrib_id18		IN	NUMBER,
	p_attrib_id19		IN	NUMBER,
	p_attrib_id20		IN	NUMBER,
	p_attrib_val1		IN	VARCHAR2,
	p_attrib_val2		IN	VARCHAR2,
	p_attrib_val3		IN	VARCHAR2,
	p_attrib_val4		IN	VARCHAR2,
	p_attrib_val5		IN	VARCHAR2,
	p_attrib_val6		IN	VARCHAR2,
	p_attrib_val7		IN	VARCHAR2,
	p_attrib_val8		IN	VARCHAR2,
	p_attrib_val9		IN	VARCHAR2,
	p_attrib_val10		IN	VARCHAR2,
	p_attrib_val11		IN	VARCHAR2,
	p_attrib_val12		IN	VARCHAR2,
	p_attrib_val13		IN	VARCHAR2,
	p_attrib_val14		IN	VARCHAR2,
	p_attrib_val15		IN	VARCHAR2,
	p_attrib_val16		IN	VARCHAR2,
	p_attrib_val17		IN	VARCHAR2,
	p_attrib_val18		IN	VARCHAR2,
	p_attrib_val19		IN	VARCHAR2,
	p_attrib_val20		IN	VARCHAR2,
        p_restrict_sql          IN      VARCHAR2,
        p_match_type            IN      VARCHAR2,
        p_search_merged         IN      VARCHAR2,
        x_search_ctx_id         OUT     NOCOPY NUMBER,
        x_num_matches           OUT     NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*#
 * Calls the appropriate API based on attribute ID values. The API accepts up to 20 attribute ID
 * value pairs as search criteria and dispatches a call to the corresponding search API that is
 * passed into the p_api_name parameter. Use the x_search_ctx_id value that the API returns to
 * filter results from the appropriate table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Call API Dynamic IDs
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE call_api_dynamic (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN 	NUMBER,
	p_attrib_id1		IN	NUMBER,
	p_attrib_id2		IN	NUMBER,
	p_attrib_id3		IN	NUMBER,
	p_attrib_id4		IN	NUMBER,
	p_attrib_id5		IN	NUMBER,
	p_attrib_id6		IN	NUMBER,
	p_attrib_id7		IN	NUMBER,
	p_attrib_id8		IN	NUMBER,
	p_attrib_id9		IN	NUMBER,
	p_attrib_id10		IN	NUMBER,
	p_attrib_id11		IN	NUMBER,
	p_attrib_id12		IN	NUMBER,
	p_attrib_id13		IN	NUMBER,
	p_attrib_id14		IN	NUMBER,
	p_attrib_id15		IN	NUMBER,
	p_attrib_id16		IN	NUMBER,
	p_attrib_id17		IN	NUMBER,
	p_attrib_id18		IN	NUMBER,
	p_attrib_id19		IN	NUMBER,
	p_attrib_id20		IN	NUMBER,
	p_attrib_val1		IN	VARCHAR2,
	p_attrib_val2		IN	VARCHAR2,
	p_attrib_val3		IN	VARCHAR2,
	p_attrib_val4		IN	VARCHAR2,
	p_attrib_val5		IN	VARCHAR2,
	p_attrib_val6		IN	VARCHAR2,
	p_attrib_val7		IN	VARCHAR2,
	p_attrib_val8		IN	VARCHAR2,
	p_attrib_val9		IN	VARCHAR2,
	p_attrib_val10		IN	VARCHAR2,
	p_attrib_val11		IN	VARCHAR2,
	p_attrib_val12		IN	VARCHAR2,
	p_attrib_val13		IN	VARCHAR2,
	p_attrib_val14		IN	VARCHAR2,
	p_attrib_val15		IN	VARCHAR2,
	p_attrib_val16		IN	VARCHAR2,
	p_attrib_val17		IN	VARCHAR2,
	p_attrib_val18		IN	VARCHAR2,
	p_attrib_val19		IN	VARCHAR2,
	p_attrib_val20		IN	VARCHAR2,
        p_restrict_sql          IN      VARCHAR2,
        p_api_name              IN      VARCHAR2,
        p_match_type            IN      VARCHAR2,
        p_party_id              IN      NUMBER,
        p_search_merged         IN      VARCHAR2,
        x_search_ctx_id         OUT     NOCOPY NUMBER,
        x_num_matches           OUT     NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*#
 * Identifies duplicates of a specific party site. The API finds duplicates within a subset
 * defined by what is passed into the p_restrict_sql parameter, within the party passed into
 * the p_party_id parameter, or across the entire TCA Registry. The API inserts duplicates
 * into the HZ_MATCHED_PARTY_SITES_GT table. Use the x_search_ctx_id value that the API returns
 * to filter results from this table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Identify Duplicate Party Sites
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE find_duplicate_party_sites (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN 	NUMBER,
        p_party_site_id         IN 	NUMBER,
        p_party_id              IN 	NUMBER,
        p_restrict_sql          IN      VARCHAR2,
        p_match_type            IN      VARCHAR2,
        x_search_ctx_id         OUT     NOCOPY NUMBER,
        x_num_matches           OUT     NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*#
 * Identifies duplicates of a specific contact. The API finds duplicates within a subset defined
 * by what is passed into the p_restrict_sql parameter, within the party passed into the p_party_id
 * parameter, or across the entire TCA Registry. The API inserts duplicates into the HZ_MATCHED_CONTACTS_GT
 * table. Use the x_search_ctx_id value that the API returns to filter results from this table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Identify Duplicate Contacts
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE find_duplicate_contacts (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN 	NUMBER,
        p_org_contact_id	IN 	NUMBER,
        p_party_id              IN 	NUMBER,
        p_restrict_sql          IN      VARCHAR2,
        p_match_type            IN      VARCHAR2,
        x_search_ctx_id         OUT  	NOCOPY NUMBER,
        x_num_matches           OUT  	NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*#
 * Identifies duplicates of a specific contact point. The API finds duplicates within a subset defined
 * by what is passed into the p_restrict_sql parameter, within the party passed into the p_party_id parameter,
 * or across the entire TCA Registry. The API inserts duplicates into the HZ_MATCHED_CPTS_GT table. Use the
 * x_search_ctx_id value that the API returns to filter results from this table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Identify Duplicate Contact Points
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE find_duplicate_contact_points (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN      NUMBER,
        p_contact_point_id	IN      NUMBER,
        p_party_id              IN      NUMBER,
        p_restrict_sql          IN      VARCHAR2,
        p_match_type            IN      VARCHAR2,
        x_search_ctx_id         OUT  	NOCOPY NUMBER,
        x_num_matches           OUT  	NOCOPY NUMBER,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*===========================================================================+
 | PROCEDURE
 |              get_party_for_search
 | DESCRIPTION
 |              Queries the party, party site, contact and contact point
 |              search criteria into the search record structures
 |              for the given party.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_rule_id
 |                    p_party_id
 |
 |              OUT:
 |		      x_party_search_rec
 |		      x_party_site_list
 |		      x_contact_list
 |		      x_contact_point_list
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Srinivasa Rangan   27-APR-01  Created
 |
 +===========================================================================*/

PROCEDURE get_party_for_search (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN      NUMBER,
        p_party_id              IN      NUMBER,
        x_party_search_rec      OUT NOCOPY party_search_rec_type,
        x_party_site_list       OUT NOCOPY party_site_list,
        x_contact_list          OUT NOCOPY contact_list,
        x_contact_point_list    OUT NOCOPY contact_point_list,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);


PROCEDURE get_search_criteria (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN      NUMBER,
        p_party_id              IN      NUMBER,
        p_party_site_ids        IN      IDList,
        p_contact_ids           IN      IDList,
        p_contact_pt_ids        IN      IDList,
        x_party_search_rec      OUT NOCOPY party_search_rec_type,
        x_party_site_list       OUT NOCOPY party_site_list,
        x_contact_list          OUT NOCOPY contact_list,
        x_contact_point_list    OUT NOCOPY contact_point_list,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);

/*#
 * Calls the appropriate API based on attribute name values. The API accepts up to 20 attribute name
 * value pairs as search criteria and dispatches a call to the corresponding search API that is passed
 * into the p_api_name parameter. Use the x_search_ctx_id value that the API returns to filter results
 * from the appropriate table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Call API Dynamic Names
 * @rep:doccd 120hztig.pdf Data Quality Management Search and Duplicate Identification APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE call_api_dynamic_names (
      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
      p_rule_id               IN      NUMBER,
      p_attrib_name1            IN      VARCHAR2,
      p_attrib_name2            IN      VARCHAR2,
      p_attrib_name3            IN      VARCHAR2,
      p_attrib_name4            IN      VARCHAR2,
      p_attrib_name5            IN      VARCHAR2,
      p_attrib_name6            IN      VARCHAR2,
      p_attrib_name7            IN      VARCHAR2,
      p_attrib_name8            IN      VARCHAR2,
      p_attrib_name9            IN      VARCHAR2,
      p_attrib_name10           IN      VARCHAR2,
      p_attrib_name11           IN      VARCHAR2,
      p_attrib_name12           IN      VARCHAR2,
      p_attrib_name13           IN      VARCHAR2,
      p_attrib_name14           IN      VARCHAR2,
      p_attrib_name15           IN      VARCHAR2,
      p_attrib_name16           IN      VARCHAR2,
      p_attrib_name17           IN      VARCHAR2,
      p_attrib_name18           IN      VARCHAR2,
      p_attrib_name19           IN      VARCHAR2,
      p_attrib_name20           IN      VARCHAR2,
      p_attrib_val1           IN      VARCHAR2,
      p_attrib_val2           IN      VARCHAR2,
      p_attrib_val3           IN      VARCHAR2,
      p_attrib_val4           IN      VARCHAR2,
      p_attrib_val5           IN      VARCHAR2,
      p_attrib_val6           IN      VARCHAR2,
      p_attrib_val7           IN      VARCHAR2,
      p_attrib_val8           IN      VARCHAR2,
      p_attrib_val9           IN      VARCHAR2,
      p_attrib_val10          IN      VARCHAR2,
      p_attrib_val11          IN      VARCHAR2,
      p_attrib_val12          IN      VARCHAR2,
      p_attrib_val13          IN      VARCHAR2,
      p_attrib_val14          IN      VARCHAR2,
      p_attrib_val15          IN      VARCHAR2,
      p_attrib_val16          IN      VARCHAR2,
      p_attrib_val17          IN      VARCHAR2,
      p_attrib_val18          IN      VARCHAR2,
      p_attrib_val19          IN      VARCHAR2,
      p_attrib_val20          IN      VARCHAR2,
      p_restrict_sql          IN      VARCHAR2,
      p_api_name              IN      VARCHAR2,
      p_match_type            IN      VARCHAR2,
      p_party_id              IN      NUMBER,
      p_search_merged         IN      VARCHAR2,
      x_search_ctx_id         OUT     NOCOPY NUMBER,
      x_num_matches           OUT     NOCOPY NUMBER,
      x_return_status         OUT     NOCOPY VARCHAR2,
      x_msg_count             OUT     NOCOPY NUMBER,
      x_msg_data              OUT     NOCOPY VARCHAR2
);

END HZ_PARTY_SEARCH;

 

/
