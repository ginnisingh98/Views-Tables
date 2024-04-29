--------------------------------------------------------
--  DDL for Package CS_SR_CUST_CONT_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_CUST_CONT_MAINT_PVT" AUTHID CURRENT_USER AS
/* $Header: csxvccms.pls 120.4.12010000.2 2009/04/30 15:54:53 gasankar ship $ */

   FUNCTION G_MISS_NUM RETURN NUMBER;
   FUNCTION G_MISS_CHAR RETURN VARCHAR2;
   FUNCTION G_MISS_DATE RETURN DATE;
   FUNCTION G_VALID_LEVEL(p_level varchar2) RETURN NUMBER;
   FUNCTION G_BOOLEAN(p_flag varchar2) RETURN VARCHAR2;
   FUNCTION GET_ERROR_CONSTANT(err_msg VARCHAR2) RETURN VARCHAR2;
   FUNCTION G_RET_STS_SUCCESS RETURN VARCHAR2 ;
   FUNCTION G_RET_STS_ERROR RETURN VARCHAR2 ;
   FUNCTION G_RET_STS_UNEXP_ERROR RETURN VARCHAR2 ;
   FUNCTION G_VALID_LEVEL_NONE RETURN NUMBER;
   FUNCTION G_VALID_LEVEL_FULL RETURN NUMBER;
   FUNCTION G_VALID_LEVEL_INT RETURN NUMBER;
   FUNCTION G_TRUE RETURN Varchar2;
   FUNCTION G_FALSE RETURN Varchar2;

   -- HZ Wrappers
   FUNCTION GET_PARTY_REC_TYPE RETURN HZ_PARTY_V2PUB.PARTY_REC_TYPE;
   FUNCTION GET_PERSON_REC_TYPE RETURN HZ_PARTY_V2PUB.PERSON_REC_TYPE;
   FUNCTION GET_CONTACT_POINTS_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
   FUNCTION GET_EDI_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
   FUNCTION GET_PHONE_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
   FUNCTION GET_EMAIL_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
   FUNCTION GET_TELEX_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
   FUNCTION GET_WEB_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;
   FUNCTION GET_PARTY_REL_REC_TYPE RETURN HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
   FUNCTION GET_ORG_CONTACT_REC_TYPE RETURN HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
 --  FUNCTION GET_CONTACT_RESTRICT_REC_TYPE RETURN HZ_CONTACT_POINT_PUB.CONTACT_RESTRICTION_REC_TYPE;
   FUNCTION GET_PARTY_SITE_REC_TYPE RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
   FUNCTION GET_PARTY_SITE_USE_REC_TYPE RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;

   -- wh_update_date is addded in the record. This is used as last update date in
   -- Update address proc. Fix for bug #1567159

   TYPE address_rec_type IS RECORD(
	location_id                   NUMBER         := FND_API.G_MISS_NUM,
        address1                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address2                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address3                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        address4                      VARCHAR2(240)  := FND_API.G_MISS_CHAR,
	address_lines_phonetic        VARCHAR2(560)  := FND_API.G_MISS_CHAR,
        city                          VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        state                         VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        postal_code                   VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        province                      VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        county                        VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        country                       VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        language                      VARCHAR2(4)    := FND_API.G_MISS_CHAR,
        street                        VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        house_number                  VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        position                      VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        po_box_number                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        address_key                   VARCHAR2(500)  := FND_API.G_MISS_CHAR,
        street_suffix                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        street_number                 VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        floor                         VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        suite                         VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        postal_plus4_code             VARCHAR2(10)   := FND_API.G_MISS_CHAR,
        time_zone                     VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        location_directions           VARCHAR2(640)  := FND_API.G_MISS_CHAR,
        clli_code                     VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        short_description             VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        description                   VARCHAR2(2000) := FND_API.G_MISS_CHAR,
        sales_tax_geocode             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        sales_tax_inside_city_limits  VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        timezone_id                   NUMBER         := FND_API.G_MISS_NUM,
	address_effective_date        DATE           := FND_API.G_MISS_DATE,
	address_expiration_date       DATE           := FND_API.G_MISS_DATE,
	address_style                 VARCHAR2(30)   := FND_API.G_MISS_CHAR,
	created_by_module               VARCHAR2(30)   := 'SR');

   FUNCTION GET_ADDRESS_REC_TYPE RETURN CS_SR_CUST_CONT_MAINT_PVT.ADDRESS_REC_TYPE;

   PROCEDURE Create_Address (
      p_address_rec     IN           ADDRESS_REC_TYPE,
      p_do_addr_val         IN     VARCHAR2, -- 12.1.2 Address Validation
      x_msg_count       OUT  NOCOPY  NUMBER,
      x_msg_data        OUT  NOCOPY  VARCHAR2,
      x_return_status   OUT  NOCOPY  VARCHAR2,
      x_addr_val_status     OUT    NOCOPY VARCHAR2, -- 12.1.2 Address Validation
      x_addr_warn_msg       OUT    NOCOPY VARCHAR2, -- 12.1.2 Address Validation
      x_location_id     OUT  NOCOPY  NUMBER);

   PROCEDURE Update_Address (
      p_address_rec     IN               ADDRESS_REC_TYPE,
      p_do_addr_val       IN      VARCHAR2,  -- 12.1.2 Address Validation
      x_msg_count       OUT     NOCOPY   NUMBER,
      x_msg_data        OUT     NOCOPY   VARCHAR2,
      x_object_version_number IN OUT NOCOPY NUMBER,
      x_return_status   OUT     NOCOPY   VARCHAR2,
      x_addr_val_status     OUT    NOCOPY VARCHAR2, -- 12.1.2 Address Validation
      x_addr_warn_msg       OUT    NOCOPY VARCHAR2); -- 12.1.2 Address Validation


   -- Wrapper for HZ procedure : phone_format for phone number globalization
/*   FUNCTION phone_format_Wrap(	p_phone_country_code IN VARCHAR2,
                                p_phone_area_code    IN VARCHAR2,
                                p_phone_number       IN VARCHAR2)
   RETURN varchar2;
*/
   PROCEDURE COMMIT_ROLLBACK( COM_ROLL       IN   VARCHAR2 := 'ROLL') ;

END CS_SR_CUST_CONT_MAINT_PVT;

/
