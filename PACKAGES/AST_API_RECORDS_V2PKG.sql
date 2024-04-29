--------------------------------------------------------
--  DDL for Package AST_API_RECORDS_V2PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_API_RECORDS_V2PKG" AUTHID CURRENT_USER AS
 /* $Header: astcuirs.pls 115.10 2003/08/27 08:03:46 sssomesw ship $ */

  -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_PARTY_SITE_REC
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_PARTY_SITE_REC
  -- Parameters : None
  -- Returns    : HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_PARTY_SITE_REC RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;

  -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_PARTY_SITE_USE_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_PARTY_SITE_USE_REC
  -- Parameters : None
  -- Returns    : HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_PARTY_SITE_USE_REC_V2 RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;

  -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_LOCATION_REC
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_LOCATION_REC
  -- Parameters : None
  -- Returns    : HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments


  FUNCTION INIT_HZ_LOCATION_REC RETURN HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;

     TYPE address_rec_type IS RECORD(
        location_id             NUMBER       := FND_API.G_MISS_NUM,
        address1                VARCHAR2(240):= FND_API.G_MISS_CHAR,
        address2                VARCHAR2(240):= FND_API.G_MISS_CHAR,
        address3                VARCHAR2(240):= FND_API.G_MISS_CHAR,
        address4                VARCHAR2(240):= FND_API.G_MISS_CHAR,
        city                    VARCHAR2(60) := FND_API.G_MISS_CHAR,
        state                   VARCHAR2(60) := FND_API.G_MISS_CHAR,
        postal_code             VARCHAR2(60) := FND_API.G_MISS_CHAR,
        province                VARCHAR2(60) := FND_API.G_MISS_CHAR,
        county                  VARCHAR2(60) := FND_API.G_MISS_CHAR,
        country                 VARCHAR2(60) := FND_API.G_MISS_CHAR,
        ADDRESS_STYLE          VARCHAR2(30) := FND_API.G_MISS_CHAR,
        VALIDATED_FLAG                           VARCHAR2(1) := FND_API.G_MISS_CHAR,
        ADDRESS_LINES_PHONETIC                   VARCHAR2(560) := FND_API.G_MISS_CHAR,
        PO_BOX_NUMBER                            VARCHAR2(50) := FND_API.G_MISS_CHAR,
        HOUSE_NUMBER                             VARCHAR2(50) := FND_API.G_MISS_CHAR,
        STREET_SUFFIX                            VARCHAR2(50) := FND_API.G_MISS_CHAR,
        STREET                                   VARCHAR2(50) := FND_API.G_MISS_CHAR,
        STREET_NUMBER                            VARCHAR2(50) := FND_API.G_MISS_CHAR,
        FLOOR                                    VARCHAR2(50) := FND_API.G_MISS_CHAR,
        SUITE                                    VARCHAR2(50) := FND_API.G_MISS_CHAR,
        POSTAL_PLUS4_CODE                        VARCHAR2(10) := FND_API.G_MISS_CHAR,
        TIMEZONE_ID                              NUMBER       := FND_API.G_MISS_NUM,
        address_effective_date  DATE         := FND_API.G_MISS_DATE,
        address_expiration_date DATE         := FND_API.G_MISS_DATE,
        attribute_category  VARCHAR2(30)  := FND_API.G_MISS_CHAR,
        attribute1          VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute2          VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute3          VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute4          VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute5          VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute6          VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute7          VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute8          VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute9          VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute10         VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute11         VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute12         VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute13         VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute14         VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute15         VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute16         VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute17         VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute18         VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute19         VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute20         VARCHAR2(150) := FND_API.G_MISS_CHAR,
        created_by_module   VARCHAR2(150) := FND_API.G_MISS_CHAR,
	   application_id      NUMBER        := FND_API.G_MISS_NUM
     );

   FUNCTION INIT_HZ_ADDRESS_REC RETURN AST_API_RECORDS_V2PKG.ADDRESS_REC_TYPE;

  -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_PERSON_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_PERSON_REC
  -- Parameters : None
  -- Returns    : HZ_PARTY_V2PUB.PERSON_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_PERSON_REC_V2 RETURN HZ_PARTY_V2PUB.PERSON_REC_TYPE;

  -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_ORG_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_ORG_REC
  -- Parameters : None
  -- Returns    : HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_ORG_REC_V2 RETURN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;

  -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_PARTY_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_PARTY_REC
  -- Parameters : None
  -- Returns    : HZ_PARTY_V2PUB.PARTY_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_PARTY_REC_V2 RETURN HZ_PARTY_V2PUB.PARTY_REC_TYPE;

  -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_CONTACT_POINTS_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_CONTACT_POINTS_REC
  -- Parameters : None
  -- Returns    : HZ_CONTACT_POINT_V2PUB.CONTACT_POINTS_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_CONTACT_POINTS_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;

 -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_EDI_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_EDI_REC
  -- Parameters : None
  -- Returns    : HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_EDI_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;

 -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_PHONE_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_PHONE_REC
  -- Parameters : None
  -- Returns    : HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_PHONE_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;

    -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_EMAIL_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_EMAIL_REC
  -- Parameters : None
  -- Returns    : HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_EMAIL_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;

   -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_TELEX_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_TELEX_REC
  -- Parameters : None
  -- Returns    : HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_TELEX_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;

    -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_WEB_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_WEB_REC
  -- Parameters : None
  -- Returns    : HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comment

  FUNCTION INIT_HZ_WEB_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;

       -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_ORG_CONTACT_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_ORG_CONTACT_REC
  -- Parameters : None
  -- Returns    : HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

 FUNCTION INIT_HZ_ORG_CONTACT_REC_V2 RETURN HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;


   -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_ORG_CONTACT_ROLE_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_ORG_CONTACT_ROLE_REC
  -- Parameters : None
  -- Returns    : HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_ORG_CONT_ROLE_REC_V2 RETURN HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE;


    -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the customer, contact modules in response center
  -- API name   : INIT_HZ_PARTY_REL_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for RELATIONSHIP_REC_TYPE
  -- Parameters : None
  -- Returns    : HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_PARTY_REL_REC_TYPE_V2 RETURN HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;

-- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Account Modules in eBusiness center
  -- API name   :  INIT_CUST_ACCT_ROLE_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_CUST_ACCOUNT_ROLE_REC
  -- Parameters : None
  -- Returns    : HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_CUST_ACCT_ROLE_REC_V2 RETURN HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE;

-- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Account Modules in eBusiness center
  -- API name   :  INIT_CUST_ACCT_SITE_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for HZ_CUST_ACCT_SITE_REC
  -- Parameters : None
  -- Returns    : HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCOUNT_SITE_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

FUNCTION INIT_CUST_ACCT_SITE_REC_V2 RETURN HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE;

 -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Account Modules in eBusiness center
  -- API name   :  INIT_CUST_PROFILE_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for CUSTOMER_PROFILE_REC_TYPE
  -- Parameters : None
  -- Returns    : HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_CUST_PROFILE_REC_V2 RETURN HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;

-- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Account Modules in eBusiness center
  -- API name   :  INIT_CUST_ACCT_RELATE_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for CUST_ACCT_REC_TYPE
  -- Parameters : None
  -- Returns    : HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_CUST_ACCT_RELATE_REC_V2 RETURN HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE;

 -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Account Modules in eBusiness center
  -- API name   :  INIT_CUST_ACCOUNT_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for CUST_ACCOUNT_REC_TYPE
  -- Parameters : None
  -- Returns    : HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_CUST_ACCOUNT_REC_V2 RETURN HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;

 -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Account Modules in eBusiness center
  -- API name   :  INIT_HZ_LANGUAGE_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for CUST_ACCOUNT_REC_TYPE
  -- Parameters : None
  -- Returns    : HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_LANGUAGE_REC_V2 RETURN HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE;

 -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Party Classification and Interest Modules in eBusiness center
  -- API name   : INIT_HZ_CODE_ASSIGNMENT_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for CODE_ASSIGNMENT_REC_TYPE
  -- Parameters : None
  -- Returns    : HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_CODE_ASSIGNMENT_REC_V2 RETURN HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE;

 -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Party Classification and Interest Modules in eBusiness center
  -- API name   : INIT_CUST_ACCT_SITE_USE_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for CUST_SITE_USE_REC_TYPE
  -- Parameters : None
  -- Returns    : HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_CUST_ACCT_SITE_USE_REC_V2 RETURN HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;

 -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Party Classification and Interest Modules in eBusiness center
  -- API name   : INIT_HZ_CONTACT_PREFERENCE_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for CONTACT_PREFERENCE_REC_TYPE
  -- Parameters : None
  -- Returns    : HZ_CPNTACT_PREFERENCE_REC_V2.CONTACT_PREFERENCE_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_CONTACT_PREFER_REC_V2 RETURN
                  HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;

-- Added for 11.5.10 HZ.K V2 API Changes --

 -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Person Details in eBusiness Center
  -- API name   : INIT_HZ_EMP_HISTORY_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for Employment History
  -- Parameters : None
  -- Returns    : HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_EMP_HISTORY_REC_V2 RETURN  HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE;


 -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Person Details in eBusiness Center
  -- API name   : INIT_HZ_INTEREST_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for Interest
  -- Parameters : None
  -- Returns    : HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_INTEREST_REC_V2 RETURN HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE;


 -- Start of comments
  -- Start of initialization functions to initialize HZ related record types
  -- Used by the Person Details in eBusiness Center
  -- API name   : INIT_HZ_EDUCATION_REC_V2
  -- Type       : Private
  -- Pre-reqs   : None.
  -- Function   : Initializes and returns  the record type for Education
  -- Parameters : None
  -- Returns    : HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE
  -- Version    : Current version 1.0
  --              Initial version 1.0
  -- End of comments

  FUNCTION INIT_HZ_EDUCATION_REC_V2 RETURN HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE;

END AST_API_RECORDS_V2PKG;

 

/
