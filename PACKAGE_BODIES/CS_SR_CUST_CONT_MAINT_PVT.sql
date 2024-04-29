--------------------------------------------------------
--  DDL for Package Body CS_SR_CUST_CONT_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_CUST_CONT_MAINT_PVT" AS
/* $Header: csxvccmb.pls 120.4.12010000.2 2009/04/30 15:55:05 gasankar ship $ */

--  Constants used as tokens for unexpected error messages.
    G_PVT_NAME	CONSTANT    VARCHAR2(25):=  'CS_SR_CUST_CONT_MAINT_PKG';

   -- Local Function.  Returns the Value of the Constant FND_API.G_MISS_NUM
   FUNCTION G_MISS_NUM RETURN NUMBER IS
   BEGIN
	RETURN FND_API.G_MISS_NUM ;
   END G_MISS_NUM ;

   -- Local Function.  Returns the Value of the Constant FND_API.G_MISS_CHAR to the caller
   FUNCTION G_MISS_CHAR RETURN VARCHAR2 IS
   BEGIN
	RETURN FND_API.G_MISS_CHAR ;
   END G_MISS_CHAR ;

   -- Local Function.  REturns the Value of the Constant FND_API.G_MISS_DATE to the caller
   FUNCTION G_MISS_DATE RETURN DATE IS
   BEGIN
	RETURN FND_API.G_MISS_DATE ;
   END G_MISS_DATE ;

   -- Local Function.  REturns the Value of the Constants
   -- FND_API.G_VALID_LEVEL_NONE , FND_API.G_VALID_LEVEL_FULL to the caller
   FUNCTION G_VALID_LEVEL(p_level varchar2) RETURN NUMBER IS
   BEGIN
   IF p_level = ('NONE') then
	RETURN FND_API.G_VALID_LEVEL_NONE ;
   ELSIF p_level = ('FULL') then
	RETURN FND_API.G_VALID_LEVEL_FULL ;
   ELSE
	--  Unrecognized parameter.
	FND_MSG_PUB.Add_Exc_Msg
    	(   p_pkg_name			=>  G_PVT_NAME			,
    	    p_procedure_name	=>  'G_VALID_LEVEL'		,
    	    p_error_text		=>  'Unrecognized Value : '||p_level
	);
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
   END G_VALID_LEVEL ;

   -- Local Function.  REturns the Value of the Constants
   -- FND_API.G_TRUE , FND_API.G_FALSE To the caller
   FUNCTION G_BOOLEAN(p_FLAG varchar2) RETURN VARCHAR2 IS
   BEGIN
   if p_flag = 'TRUE' then
	return FND_API.G_TRUE ;
   elsif p_flag = 'FALSE' then
	return FND_API.G_FALSE ;
   ELSE
	--  Unrecognized parameter.
	FND_MSG_PUB.Add_Exc_Msg
    	(   p_pkg_name			=>  G_PVT_NAME				,
    	    p_procedure_name	=>  'G_BOOLEAN'		,
    	    p_error_text		=>  'Unrecognized Value : '||p_flag
	);
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END if;
   END G_BOOLEAN;

 FUNCTION GET_ERROR_CONSTANT(err_msg VARCHAR2) RETURN VARCHAR2 IS

 BEGIN
    IF err_msg = 'G_RET_STS_ERROR' THEN
       RETURN FND_API.G_RET_STS_ERROR;
    ELSIF err_msg = 'G_RET_STS_UNEXP_ERROR' THEN
       RETURN FND_API.G_RET_STS_UNEXP_ERROR;
    ELSIF err_msg = 'G_RET_STS_SUCCESS' THEN
       RETURN FND_API.G_RET_STS_SUCCESS;
    END IF;

 END GET_ERROR_CONSTANT;

 FUNCTION GET_PARTY_REC_TYPE RETURN HZ_PARTY_V2PUB.PARTY_REC_TYPE IS
 TMP_PARTY_REC_TYPE HZ_PARTY_V2PUB.PARTY_REC_TYPE;
 BEGIN
  RETURN TMP_PARTY_REC_TYPE;
 END GET_PARTY_REC_TYPE;

 FUNCTION GET_PERSON_REC_TYPE RETURN HZ_PARTY_V2PUB.PERSON_REC_TYPE IS
 TMP_PERSON_REC_TYPE HZ_PARTY_V2PUB.PERSON_REC_TYPE;
 BEGIN
  RETURN TMP_PERSON_REC_TYPE;
 END GET_PERSON_REC_TYPE;

 FUNCTION GET_CONTACT_POINTS_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE IS
 TMP_CONTACT_POINTS_REC_TYPE HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
 BEGIN
  RETURN TMP_CONTACT_POINTS_REC_TYPE;
 END GET_CONTACT_POINTS_REC_TYPE;

 FUNCTION GET_EDI_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE IS
 TMP_EDI_REC_TYPE HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
 BEGIN
  RETURN TMP_EDI_REC_TYPE;
 END GET_EDI_REC_TYPE;

 FUNCTION GET_PHONE_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE IS
 TMP_PHONE_REC_TYPE HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
 BEGIN
  RETURN TMP_PHONE_REC_TYPE;
 END GET_PHONE_REC_TYPE;

 FUNCTION GET_EMAIL_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE IS
 TMP_EMAIL_REC_TYPE HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
 BEGIN
  RETURN TMP_EMAIL_REC_TYPE;
 END GET_EMAIL_REC_TYPE;

 FUNCTION GET_TELEX_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE IS
 TMP_TELEX_REC_TYPE HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
 BEGIN
  RETURN TMP_TELEX_REC_TYPE;
 END GET_TELEX_REC_TYPE;

 FUNCTION GET_WEB_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE IS
 TMP_WEB_REC_TYPE HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;
 BEGIN
  RETURN TMP_WEB_REC_TYPE;
 END GET_WEB_REC_TYPE;

 FUNCTION GET_PARTY_REL_REC_TYPE RETURN HZ_RELATIONSHIP_V2PUB.relationship_rec_type IS
 TMP_PARTY_REL_REC_TYPE HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
 BEGIN
  RETURN TMP_PARTY_REL_REC_TYPE;
 END GET_PARTY_REL_REC_TYPE;

-- FUNCTION GET_LOCATION_REC_TYPE RETURN HZ_LOCATION_PUB.LOCATION_REC_TYPE IS
-- TMP_LOCATION_REC_TYPE HZ_LOCATION_PUB.LOCATION_REC_TYPE;
-- BEGIN
--  RETURN TMP_LOCATION_REC_TYPE;
-- END GET_LOCATION_REC_TYPE;

 FUNCTION GET_ORG_CONTACT_REC_TYPE RETURN HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE IS
 TMP_ORG_CONTACT_REC_TYPE HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
 BEGIN
  RETURN TMP_ORG_CONTACT_REC_TYPE;
 END GET_ORG_CONTACT_REC_TYPE;

-- FUNCTION GET_CONTACT_RESTRICT_REC_TYPE RETURN HZ_CONTACT_POINT_PUB.CONTACT_RESTRICTION_REC_TYPE IS
-- TMP_CONTACT_RESTRICT_REC_TYPE HZ_CONTACT_POINT_PUB.CONTACT_RESTRICTION_REC_TYPE;
-- BEGIN
--  RETURN TMP_CONTACT_RESTRICT_REC_TYPE;
-- END GET_CONTACT_RESTRICT_REC_TYPE;

 FUNCTION GET_ADDRESS_REC_TYPE RETURN CS_SR_CUST_CONT_MAINT_PVT.ADDRESS_REC_TYPE IS
 TMP_ADDRESS_REC_TYPE CS_SR_CUST_CONT_MAINT_PVT.ADDRESS_REC_TYPE;
 BEGIN
  RETURN TMP_ADDRESS_REC_TYPE;
 END GET_ADDRESS_REC_TYPE;

 FUNCTION GET_PARTY_SITE_REC_TYPE RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE IS
 TMP_PARTY_SITE_REC_TYPE HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
 BEGIN
  RETURN TMP_PARTY_SITE_REC_TYPE;
 END GET_PARTY_SITE_REC_TYPE;

 FUNCTION GET_PARTY_SITE_USE_REC_TYPE RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE IS
 TMP_PARTY_SITE_USE_REC_TYPE HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
 BEGIN
  RETURN TMP_PARTY_SITE_USE_REC_TYPE;
 END GET_PARTY_SITE_USE_REC_TYPE;

 PROCEDURE Create_Address (
	p_address_rec         IN            ADDRESS_REC_TYPE,
	p_do_addr_val         IN     VARCHAR2,  -- 12.1.2 Address Validation
	x_msg_count           OUT    NOCOPY NUMBER,
	x_msg_data            OUT    NOCOPY VARCHAR2,
	x_return_status       OUT    NOCOPY VARCHAR2,
	x_addr_val_status     OUT    NOCOPY VARCHAR2, -- 12.1.2 Address Validation
	x_addr_warn_msg       OUT    NOCOPY VARCHAR2, -- 12.1.2 Address Validation
	x_location_id         OUT    NOCOPY NUMBER) Is

   l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(2000);
   l_location_id NUMBER;

   l_addr_val_status VARCHAR2(30);  -- 12.1.2 Address Validation
   l_addr_warn_msg   VARCHAR2(2000); -- 12.1.2 Address Validation

 Begin

/* wh_update_date is addded in the record. This is used as last update date  in
 Update address proc. Fix for bug #1567159 */

   l_location_rec.address1 := p_address_rec.address1;
   l_location_rec.address2 := p_address_rec.address2;
   l_location_rec.address3 := p_address_rec.address3;
   l_location_rec.address4 := p_address_rec.address4;
   l_location_rec.address_lines_phonetic := p_address_rec.address_lines_phonetic;
   l_location_rec.city     := p_address_rec.city;
   l_location_rec.state    := p_address_rec.state;
   l_location_rec.county   := p_address_rec.county;
   l_location_rec.country  := p_address_rec.country;
   l_location_rec.postal_code := p_address_rec.postal_code;
   l_location_rec.province := p_address_rec.province;
   l_location_rec.county   := p_address_rec.county;
   l_location_rec.language := p_address_rec.language;
   l_location_rec.po_box_number := p_address_rec.po_box_number;
   l_location_rec.street   := p_address_rec.street;
   l_location_rec.house_number  := p_address_rec.house_number;
   l_location_rec.position := p_address_rec.position;
   l_location_rec.address_key := p_address_rec.address_key;
   l_location_rec.street_number := p_address_rec.street_number;
   l_location_rec.floor := p_address_rec.floor;
   l_location_rec.suite := p_address_rec.suite;
   l_location_rec.postal_plus4_code := p_address_rec.postal_plus4_code;
   l_location_rec.position := p_address_rec.position;
   l_location_rec.location_directions := p_address_rec.location_directions;
   l_location_rec.clli_code := p_address_rec.clli_code;
   l_location_rec.short_description := p_address_rec.short_description;
   l_location_rec.description := p_address_rec.description;
   l_location_rec.sales_tax_geocode := p_address_rec.sales_tax_geocode;
   l_location_rec.sales_tax_inside_city_limits := p_address_rec.sales_tax_inside_city_limits;
   l_location_rec.timezone_id := p_address_rec.timezone_id;
   l_location_rec.created_by_module := 'SR';

     HZ_LOCATION_V2PUB.create_location (
        p_init_msg_list     => FND_API.G_FALSE,
        p_location_rec      => l_location_rec,
        p_do_addr_val       => p_do_addr_val,  -- 12.1.2 Address Validation
        x_location_id       => l_location_id,
        x_return_status     => l_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data,
	x_addr_val_status   => l_addr_val_status,  -- 12.1.2 Address Validation
	x_addr_warn_msg     => l_addr_warn_msg); -- 12.1.2 Address Validation

        x_return_status     := l_return_status;
	x_msg_count         := l_msg_count;
	x_msg_data          := l_msg_data;
        x_addr_val_status   := l_addr_val_status; -- 12.1.2 Address Validation
	x_addr_warn_msg     := l_addr_warn_msg; -- 12.1.2 Address Validation


	If x_return_status = CSC_CORE_UTILS_PVT.G_RET_STS_SUCCESS Then
		x_location_id	 := l_location_id;
	End If;

 End Create_Address;

 PROCEDURE Update_Address (
   p_address_rec       IN	             ADDRESS_REC_TYPE,
   p_do_addr_val       IN      VARCHAR2,  -- 12.1.2 Address Validation
   x_msg_count         OUT     NOCOPY   NUMBER,
   x_msg_data          OUT     NOCOPY   VARCHAR2,
   x_object_version_number IN OUT NOCOPY NUMBER,
   x_return_status     OUT     NOCOPY   VARCHAR2,
   x_addr_val_status     OUT    NOCOPY VARCHAR2, -- 12.1.2 Address Validation
   x_addr_warn_msg       OUT    NOCOPY VARCHAR2) Is -- 12.1.2 Address Validation

   l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(2000);

   l_addr_val_status VARCHAR2(30);  -- 12.1.2 Address Validation
   l_addr_warn_msg   VARCHAR2(2000); -- 12.1.2 Address Validation


 Begin
   l_location_rec.address1 := p_address_rec.address1;
   l_location_rec.address2 := p_address_rec.address2;
   l_location_rec.address3 := p_address_rec.address3;
   l_location_rec.address4 := p_address_rec.address4;
   l_location_rec.address_lines_phonetic := p_address_rec.address_lines_phonetic;
   l_location_rec.location_id := p_address_rec.location_id;
   l_location_rec.city     := p_address_rec.city;
   l_location_rec.state 	  := p_address_rec.state;
   l_location_rec.county   := p_address_rec.county;
   l_location_rec.country  := p_address_rec.country;
   l_location_rec.postal_code := p_address_rec.postal_code;
   l_location_rec.province := p_address_rec.province;
   l_location_rec.county := p_address_rec.county;
   l_location_rec.language := p_address_rec.language;
   l_location_rec.po_box_number := p_address_rec.po_box_number;
   l_location_rec.street := p_address_rec.street;
   l_location_rec.house_number := p_address_rec.house_number;
   l_location_rec.position := p_address_rec.position;
   l_location_rec.address_key := p_address_rec.address_key;
   l_location_rec.street_suffix := p_address_rec.street_suffix;
   l_location_rec.street_number := p_address_rec.street_number;
   l_location_rec.floor := p_address_rec.floor;
   l_location_rec.suite := p_address_rec.suite;
   l_location_rec.postal_plus4_code := p_address_rec.postal_plus4_code;
   l_location_rec.position := p_address_rec.position;
   l_location_rec.location_directions := p_address_rec.location_directions;
   l_location_rec.clli_code := p_address_rec.clli_code;
   l_location_rec.short_description := p_address_rec.short_description;
   l_location_rec.description := p_address_rec.description;
   l_location_rec.sales_tax_geocode := p_address_rec.sales_tax_geocode;
   l_location_rec.sales_tax_inside_city_limits := p_address_rec.sales_tax_inside_city_limits;
   l_location_rec.timezone_id := p_address_rec.timezone_id;

     HZ_LOCATION_V2PUB.update_location (
        p_init_msg_list          => FND_API.G_FALSE,
        p_location_rec           => l_location_rec,
	p_do_addr_val       => p_do_addr_val,  -- 12.1.2 Address Validation
        p_object_version_number  => x_object_version_number,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,
	x_addr_val_status        => l_addr_val_status,  -- 12.1.2 Address Validation
	x_addr_warn_msg          => l_addr_warn_msg); -- 12.1.2 Address Validation

	x_return_status     := l_return_status;
	x_msg_count         := l_msg_count;
	x_msg_data          := l_msg_data;
	x_addr_val_status   := l_addr_val_status; -- 12.1.2 Address Validation
	x_addr_warn_msg     := l_addr_warn_msg; -- 12.1.2 Address Validation

 End Update_Address;


	-- Wrapper for HZ procedure : phone_format for phone number globalization
/*	FUNCTION phone_format_Wrap(	p_phone_country_code 	in varchar2,
							p_phone_area_code 		in varchar2,
							p_phone_number 		in varchar2)
	RETURN varchar2 is
   		l_return_status VARCHAR2(1);
   		l_msg_count NUMBER;
   		l_msg_data  VARCHAR2(2000);
		l_phone_country_code varchar2(30):= NULL;
		l_phone_area_code varchar2(30);
		l_phone_number varchar2(30);
		l_territory_code varchar2(30):= NULL;
		l_formatted_phone_number varchar2(100);
	Begin

		if p_phone_country_code is null then
			FND_PROFILE.get('CSC_CC_DEFAULT_TERRITORY_CODE',l_territory_code);
		else
			l_phone_country_code := p_phone_country_code;
		end if;

		l_phone_area_code := p_phone_area_code;
		l_phone_number := p_phone_number;

	     HZ_CONTACT_POINT_PUB.phone_format (
									p_api_version				=> 1.0,
									p_init_msg_list    			=> FND_API.G_FALSE,
									p_territory_code 			=> l_territory_code,
									x_formatted_phone_number 	=> l_formatted_phone_number,
									x_phone_country_code 		=> l_phone_country_code,
									x_phone_area_code 			=> l_phone_area_code,
									x_phone_number 			=> l_phone_number,
									x_return_status			=> l_return_status,
									x_msg_count				=> l_msg_count,
									x_msg_data				=> l_msg_data);

		-- If procedure does not return success then pass back null (since will be used in view definition)
		if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
		-- return FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' );
			return null;
		else
			return l_formatted_phone_number;
		end if;
	End phone_format_wrap;
*/

/* New SEARCH window related objects */

  PROCEDURE COMMIT_ROLLBACK( COM_ROLL       IN   VARCHAR2 := 'ROLL')
  IS
  BEGIN
     if ( COM_ROLL = 'COMMIT' ) then
	   commit;
     else
	   rollback;
     end if;
  END COMMIT_ROLLBACK;

  FUNCTION G_RET_STS_SUCCESS RETURN VARCHAR2 IS
  BEGIN
     RETURN FND_API.G_RET_STS_SUCCESS ;
  END G_RET_STS_SUCCESS ;


  FUNCTION G_RET_STS_ERROR RETURN VARCHAR2 IS
  BEGIN
     RETURN FND_API.G_RET_STS_ERROR ;
  END G_RET_STS_ERROR ;


  FUNCTION G_RET_STS_UNEXP_ERROR RETURN VARCHAR2 IS
  BEGIN
     RETURN FND_API.G_RET_STS_UNEXP_ERROR ;
  END G_RET_STS_UNEXP_ERROR ;


  FUNCTION G_VALID_LEVEL_NONE RETURN NUMBER IS
  BEGIN
     RETURN FND_API.G_VALID_LEVEL_NONE ;
  END;


  FUNCTION G_VALID_LEVEL_FULL RETURN NUMBER IS
  BEGIN
     RETURN FND_API.G_VALID_LEVEL_FULL ;
  END;


  FUNCTION G_VALID_LEVEL_INT RETURN NUMBER IS
  BEGIN
     RETURN CS_INTERACTION_PVT.G_VALID_LEVEL_INT ;
  END;


  FUNCTION G_TRUE RETURN VARCHAR2 IS
  BEGIN
     return FND_API.G_TRUE ;
  END;


  FUNCTION G_FALSE RETURN VARCHAR2 IS
  BEGIN
     return FND_API.G_FALSE ;
  END;
END CS_SR_CUST_CONT_MAINT_PVT;

/
