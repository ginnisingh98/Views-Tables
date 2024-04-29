--------------------------------------------------------
--  DDL for Package CSC_RESPONSE_CENTER_PKG_V2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_RESPONSE_CENTER_PKG_V2" AUTHID CURRENT_USER AS
/* $Header: CSCV2RCS.pls 120.0.12010000.2 2009/04/15 09:22:37 rgandhi ship $ */

   FUNCTION G_MISS_NUM RETURN NUMBER;
   FUNCTION G_MISS_CHAR RETURN VARCHAR2;
   FUNCTION G_MISS_DATE RETURN DATE;

   FUNCTION GET_ACCOUNT_REC_TYPE RETURN HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
   FUNCTION GET_CUST_PROFILE_REC_TYPE RETURN HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
   FUNCTION GET_PERSON_REC_TYPE RETURN HZ_PARTY_V2PUB.PERSON_REC_TYPE;
   FUNCTION GET_ORG_REC_TYPE RETURN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
   FUNCTION GET_CUST_ACCT_ROLES_REC_TYPE RETURN HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE;
   FUNCTION GET_ACCT_SITE_REC_TYPE RETURN HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE;
   FUNCTION GET_ACCT_SITE_USES_REC_TYPE RETURN HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;
   FUNCTION GET_CUST_ACCT_RELATE_REC_TYPE RETURN HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE;
   FUNCTION GET_PARTY_REC_TYPE RETURN HZ_PARTY_V2PUB.PARTY_REC_TYPE;
   FUNCTION GET_PHONE_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
   FUNCTION GET_EMAIL_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
   FUNCTION GET_WEB_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;
   FUNCTION GET_EDI_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
   FUNCTION GET_TELEX_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
   FUNCTION GET_CONTACT_POINTS_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
   FUNCTION GET_CONT_POINTS_PREF_REC_TYPE RETURN HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
   FUNCTION GET_PARTY_SITE_REC_TYPE RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
   FUNCTION GET_PARTY_SITE_USE_REC_TYPE RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
   -- hbchung
   FUNCTION GET_ORG_CONTACT_REC_TYPE RETURN HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
   FUNCTION GET_RELATIONSHIP_REC_TYPE RETURN HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
   FUNCTION GET_PER_LANG_REC_TYPE RETURN HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE;
   FUNCTION GET_EDUCATION_REC_TYPE RETURN HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE;
   FUNCTION GET_EMP_HISTORY_REC_TYPE RETURN HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE;
   FUNCTION GET_PER_INTEREST_REC_TYPE RETURN HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE;

   FUNCTION get_csc_application_id RETURN NUMBER;

   TYPE address_rec_type IS RECORD(
	location_id                   NUMBER         := FND_API.G_MISS_NUM,
        country                       VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        address1                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address2                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address3                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address4                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        city                          VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        postal_code                   VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        state                         VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        province                      VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        county                        VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        address_key                   VARCHAR2(500)  := FND_API.G_MISS_CHAR,
	address_style                 VARCHAR2(30)   := FND_API.G_MISS_CHAR,
	address_lines_phonetic        VARCHAR2(560)  := FND_API.G_MISS_CHAR,
        po_box_number                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        house_number                  VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        street_suffix                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        street                        VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        street_number                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        floor                         VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        suite                         VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        postal_plus4_code             VARCHAR2(10)   := FND_API.G_MISS_CHAR,
        position                      VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        location_directions           VARCHAR2(640)  := FND_API.G_MISS_CHAR,
	address_effective_date        DATE           := FND_API.G_MISS_DATE,
	address_expiration_date       DATE           := FND_API.G_MISS_DATE,
        clli_code                     VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        language                      VARCHAR2(4)    := FND_API.G_MISS_CHAR,
        short_description             VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        description                   VARCHAR2(2000) := FND_API.G_MISS_CHAR,
        sales_tax_geocode             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        sales_tax_inside_city_limits  VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        created_by_module             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        application_id                NUMBER         := FND_API.G_MISS_NUM,
        timezone_id                   NUMBER         := FND_API.G_MISS_NUM,
        delivery_point_code           VARCHAR2(50)   := FND_API.G_MISS_CHAR);

   FUNCTION GET_ADDRESS_REC_TYPE RETURN CSC_RESPONSE_CENTER_PKG_V2.ADDRESS_REC_TYPE;

   PROCEDURE Create_Address ( p_address_rec     IN           ADDRESS_REC_TYPE,
                              x_msg_count       OUT  NOCOPY  NUMBER,
                              x_msg_data        OUT  NOCOPY  VARCHAR2,
                              x_return_status   OUT  NOCOPY  VARCHAR2,
                              x_location_id     OUT  NOCOPY  NUMBER,
                              x_addr_val_status OUT  NOCOPY  VARCHAR2,
                              x_addr_warn_msg   OUT  NOCOPY  VARCHAR2);

   PROCEDURE Update_Address ( p_address_rec           IN               ADDRESS_REC_TYPE,
                              x_msg_count             OUT     NOCOPY   NUMBER,
                              x_msg_data              OUT     NOCOPY   VARCHAR2,
                              x_object_version_number IN OUT  NOCOPY   NUMBER,
                              x_return_status         OUT     NOCOPY   VARCHAR2,
                              x_addr_val_status       OUT     NOCOPY  VARCHAR2,
                              x_addr_warn_msg         OUT     NOCOPY  VARCHAR2);


END CSC_RESPONSE_CENTER_PKG_V2;

/
