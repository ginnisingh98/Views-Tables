--------------------------------------------------------
--  DDL for Package Body CSC_RESPONSE_CENTER_PKG_V2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_RESPONSE_CENTER_PKG_V2" AS
/* $Header: CSCV2RCB.pls 120.1.12010000.4 2009/04/16 14:11:33 rgandhi ship $ */

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

   FUNCTION GET_ORG_REC_TYPE RETURN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE IS
   TMP_ORG_REC_TYPE HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
   BEGIN
    RETURN TMP_ORG_REC_TYPE;
   END GET_ORG_REC_TYPE;

   -- hbchung
   FUNCTION GET_ORG_CONTACT_REC_TYPE RETURN HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE IS
   TMP_ORG_CONTACT_REC_TYPE HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
   BEGIN
    RETURN TMP_ORG_CONTACT_REC_TYPE;
   END GET_ORG_CONTACT_REC_TYPE;
   -- hbchung

   -- hbchung
   FUNCTION GET_RELATIONSHIP_REC_TYPE RETURN HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE IS
   TMP_RELATIONSHIP_REC_TYPE HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
   BEGIN
    RETURN TMP_RELATIONSHIP_REC_TYPE;
   END GET_RELATIONSHIP_REC_TYPE;
   -- hbchung

   -- hbchung
   FUNCTION GET_PER_LANG_REC_TYPE RETURN HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE IS
   TMP_PER_LANG_REC_TYPE HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE;
   BEGIN
    RETURN TMP_PER_LANG_REC_TYPE;
   END GET_PER_LANG_REC_TYPE;
   -- hbchung

   -- hbchung
   FUNCTION GET_EDUCATION_REC_TYPE RETURN HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE IS
   TMP_EDU_REC_TYPE HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE;
   BEGIN
    RETURN TMP_EDU_REC_TYPE;
   END GET_EDUCATION_REC_TYPE;
   -- hbchung

   -- hbchung
   FUNCTION GET_EMP_HISTORY_REC_TYPE RETURN HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE IS
   TMP_EMP_HIST_REC_TYPE  HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE;
   BEGIN
    RETURN TMP_EMP_HIST_REC_TYPE;
   END GET_EMP_HISTORY_REC_TYPE;
   -- hbchung

   -- hbchung
   FUNCTION GET_PER_INTEREST_REC_TYPE RETURN HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE IS
   TMP_PER_INT_REC_TYPE  HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE;
   BEGIN
    RETURN TMP_PER_INT_REC_TYPE;
   END GET_PER_INTEREST_REC_TYPE;
   -- hbchung

   FUNCTION GET_PERSON_REC_TYPE RETURN HZ_PARTY_V2PUB.PERSON_REC_TYPE IS
   TMP_PERSON_REC_TYPE HZ_PARTY_V2PUB.PERSON_REC_TYPE;
   BEGIN
    RETURN TMP_PERSON_REC_TYPE;
   END GET_PERSON_REC_TYPE;


   FUNCTION GET_ACCOUNT_REC_TYPE RETURN HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE IS
   TMP_ACCOUNT_REC_TYPE HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
   BEGIN
    RETURN TMP_ACCOUNT_REC_TYPE;
   END GET_ACCOUNT_REC_TYPE;

   FUNCTION GET_CUST_ACCT_ROLES_REC_TYPE RETURN HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE IS
   TMP_REC HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE;
   BEGIN
    RETURN TMP_REC;
   END GET_CUST_ACCT_ROLES_REC_TYPE;

   FUNCTION GET_ACCT_SITE_REC_TYPE RETURN HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE IS
   TMP_REC HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE;
   BEGIN
    RETURN TMP_REC;
   END GET_ACCT_SITE_REC_TYPE;


   FUNCTION GET_ACCT_SITE_USES_REC_TYPE RETURN HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE IS
   TMP_REC HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;
   BEGIN
    RETURN   TMP_REC;
   END GET_ACCT_SITE_USES_REC_TYPE;


   FUNCTION GET_CUST_ACCT_RELATE_REC_TYPE RETURN HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE IS
   TMP_REC  HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE;
   BEGIN
    RETURN   TMP_REC;
   END GET_CUST_ACCT_RELATE_REC_TYPE;


   FUNCTION GET_CUST_PROFILE_REC_TYPE RETURN HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE IS
   TMP_CUST_PROFILE_REC_TYPE HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
   BEGIN
      RETURN TMP_CUST_PROFILE_REC_TYPE;
   END GET_CUST_PROFILE_REC_TYPE;

   FUNCTION GET_PARTY_REC_TYPE RETURN HZ_PARTY_V2PUB.PARTY_REC_TYPE IS
   TMP_PARTY_REC_TYPE HZ_PARTY_V2PUB.PARTY_REC_TYPE;
   BEGIN
      RETURN TMP_PARTY_REC_TYPE;
   END GET_PARTY_REC_TYPE;

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

   FUNCTION GET_WEB_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE IS
   TMP_WEB_REC_TYPE HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;
   BEGIN
      RETURN TMP_WEB_REC_TYPE;
   END GET_WEB_REC_TYPE;

   FUNCTION GET_EDI_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE IS
   TMP_EDI_REC_TYPE HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
   BEGIN
      RETURN TMP_EDI_REC_TYPE;
   END GET_EDI_REC_TYPE;

   FUNCTION GET_TELEX_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE IS
   TMP_TELEX_REC_TYPE HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
   BEGIN
      RETURN TMP_TELEX_REC_TYPE;
   END GET_TELEX_REC_TYPE;

   FUNCTION GET_CONTACT_POINTS_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE IS
   TMP_CONTACT_POINTS_REC_TYPE HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
   BEGIN
      RETURN TMP_CONTACT_POINTS_REC_TYPE;
   END GET_CONTACT_POINTS_REC_TYPE;

   FUNCTION GET_CONT_POINTS_PREF_REC_TYPE RETURN HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE IS
   TMP_CONTACT_POINTS_REC_TYPE HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
   BEGIN
      RETURN TMP_CONTACT_POINTS_REC_TYPE;
   END GET_CONT_POINTS_PREF_REC_TYPE;

   FUNCTION GET_ADDRESS_REC_TYPE RETURN CSC_RESPONSE_CENTER_PKG_V2.ADDRESS_REC_TYPE IS
   TMP_ADDRESS_REC_TYPE CSC_RESPONSE_CENTER_PKG_V2.ADDRESS_REC_TYPE;
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

  /* Returns CSC application_id passed to TCA V2 APIs */
   FUNCTION get_csc_application_id RETURN NUMBER
   IS
      csc_application_id CONSTANT NUMBER := 511;
   BEGIN
      RETURN csc_application_id;
   END;


   PROCEDURE Create_Address ( p_address_rec     IN           ADDRESS_REC_TYPE,
                              x_msg_count       OUT  NOCOPY  NUMBER,
                              x_msg_data        OUT  NOCOPY  VARCHAR2,
                              x_return_status   OUT  NOCOPY  VARCHAR2,
                              x_location_id     OUT  NOCOPY  NUMBER,
						x_addr_val_status OUT  NOCOPY  VARCHAR2,
						x_addr_warn_msg   OUT  NOCOPY  VARCHAR2)
   IS
      l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
      l_return_status VARCHAR2(1);
      l_msg_count NUMBER;
      l_msg_data  VARCHAR2(2000);
      l_location_id NUMBER;

      /* For NCR July'09 Bug 8435112 */
      l_do_addr_val      VARCHAR2(10);
      l_addr_val_status  VARCHAR2(10);
	 l_addr_warn_msg    VARCHAR2(2000);
      /* End of NCR July'09 Bug 8435112 */
   BEGIN
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
      l_location_rec.street_suffix := p_address_rec.street_suffix;
      l_location_rec.street_number := p_address_rec.street_number;
      l_location_rec.floor := p_address_rec.floor;
      l_location_rec.suite := p_address_rec.suite;
      l_location_rec.postal_plus4_code := p_address_rec.postal_plus4_code;
      l_location_rec.delivery_point_code := p_address_rec.delivery_point_code;
      l_location_rec.location_directions := p_address_rec.location_directions;
      l_location_rec.clli_code := p_address_rec.clli_code;
      l_location_rec.short_description := p_address_rec.short_description;
      l_location_rec.description := p_address_rec.description;
      l_location_rec.sales_tax_geocode := p_address_rec.sales_tax_geocode;
      l_location_rec.sales_tax_inside_city_limits := p_address_rec.sales_tax_inside_city_limits;
      l_location_rec.timezone_id := p_address_rec.timezone_id;
      l_location_rec.created_by_module := p_address_rec.created_by_module;
      l_location_rec.application_id := p_address_rec.application_id;

      /* For NCR Jul'09 Bug 8435112 */

	 IF Fnd_Profile.value('CS_VALIDATE_ADDRESS') = 'Y' then
	   l_do_addr_val := 'Y';
	 ELSE
	   l_do_addr_val := 'N';
	 END IF;

       /* End of NCR Jul'09 Bug 8435112 */

      HZ_LOCATION_V2PUB.create_location ( p_init_msg_list    => FND_API.G_FALSE,
                                          p_location_rec     => l_location_rec,
                                          x_return_status    => l_return_status,
                                          x_msg_count        => l_msg_count,
                                          x_msg_data         => l_msg_data,
                                          x_location_id      => l_location_id,
					  p_do_addr_val      => l_do_addr_val,
					  x_addr_val_status  => l_addr_val_status,
					  x_addr_warn_msg    => l_addr_warn_msg);

      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

      /*For NCR Jul'09 Bug 8435112 */
      x_addr_val_status  := l_addr_val_status;
      x_addr_warn_msg    := l_addr_warn_msg;
      /* End of NCR Jul'09 Bug 8435112 */

      If x_return_status = CSC_CORE_UTILS_PVT.G_RET_STS_SUCCESS Then
         x_location_id := l_location_id;
      End If;

 End Create_Address;

 PROCEDURE Update_Address ( p_address_rec           IN               ADDRESS_REC_TYPE,
                            x_msg_count             OUT     NOCOPY   NUMBER,
                            x_msg_data              OUT     NOCOPY   VARCHAR2,
                            x_object_version_number IN OUT  NOCOPY   NUMBER,
                            x_return_status         OUT     NOCOPY   VARCHAR2,
                            x_addr_val_status       OUT     NOCOPY   VARCHAR2,
                            x_addr_warn_msg         OUT     NOCOPY   VARCHAR2)
 IS
    l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);

    /* For NCR July'09 Bug 8435112 */
      l_do_addr_val      VARCHAR2(10);
      l_addr_val_status  VARCHAR2(10);
      l_addr_warn_msg    VARCHAR2(2000);
    /* End of NCR July'09 Bug 8435112 */

 BEGIN
    l_location_rec.address1 := Nvl(p_address_rec.address1, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.address2 := Nvl(p_address_rec.address2, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.address3 := Nvl(p_address_rec.address3, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.address4 := Nvl(p_address_rec.address4, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.address_lines_phonetic := Nvl(p_address_rec.address_lines_phonetic, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.city     := Nvl(p_address_rec.city, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.state    := Nvl(p_address_rec.state, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.county   := Nvl(p_address_rec.county, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.country  := Nvl(p_address_rec.country, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.postal_code := Nvl(p_address_rec.postal_code, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.province := Nvl(p_address_rec.province, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.county   := Nvl(p_address_rec.county, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.language := Nvl(p_address_rec.language, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.po_box_number := Nvl(p_address_rec.po_box_number, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.street   := Nvl(p_address_rec.street, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.house_number  := Nvl(p_address_rec.house_number, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.position := Nvl(p_address_rec.position, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.address_key := Nvl(p_address_rec.address_key, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.street_suffix := Nvl(p_address_rec.street_suffix, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.street_number := Nvl(p_address_rec.street_number, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.floor := Nvl(p_address_rec.floor, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.suite := Nvl(p_address_rec.suite, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.postal_plus4_code := Nvl(p_address_rec.postal_plus4_code, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.delivery_point_code := Nvl(p_address_rec.delivery_point_code, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.location_directions := Nvl(p_address_rec.location_directions, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.clli_code := Nvl(p_address_rec.clli_code, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.short_description := Nvl(p_address_rec.short_description, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.description := Nvl(p_address_rec.description, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.sales_tax_geocode := Nvl(p_address_rec.sales_tax_geocode, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
    l_location_rec.sales_tax_inside_city_limits := Nvl(p_address_rec.sales_tax_inside_city_limits, CSC_RESPONSE_CENTER_PKG_V2.g_miss_char);
     --Begin Fix for Bug 7033623 by spamujul
   -- l_location_rec.timezone_id := Nvl(p_address_rec.timezone_id, CSC_RESPONSE_CENTER_PKG_V2.g_miss_num);
	if l_location_rec.timezone_id <> CSC_RESPONSE_CENTER_PKG_V2.g_miss_num then
		l_location_rec.timezone_id := p_address_rec.timezone_id;
	else
	      l_location_rec.timezone_id := null;
	end if;
     --End Fix for Bug 7033623 by spamujul
    l_location_rec.location_id := p_address_rec.location_id;

     /* For NCR Jul'09 Bug 8435112 */
      IF Fnd_Profile.value('CS_VALIDATE_ADDRESS') = 'Y' then
        l_do_addr_val := 'Y';
      ELSE
        l_do_addr_val := 'N';
      END IF;
     /* End of NCR Jul'09 Bug 8435112 */


    HZ_LOCATION_V2PUB.update_location ( p_init_msg_list => FND_API.G_FALSE,
                                        p_location_rec => l_location_rec,
                                        p_object_version_number => x_object_version_number,
                                        x_return_status => l_return_status,
                                        x_msg_count => l_msg_count,
                                        x_msg_data => l_msg_data,
				        p_do_addr_val      => l_do_addr_val,
                                        x_addr_val_status  => l_addr_val_status,
                                        x_addr_warn_msg => l_addr_warn_msg);

	x_return_status := l_return_status;
	x_msg_count := l_msg_count;
	x_msg_data := l_msg_data;

     /*For NCR Jul'09 Bug 8435112 */
     x_addr_val_status  := l_addr_val_status;
     x_addr_warn_msg := l_addr_warn_msg;
     /* End of NCR Jul'09 Bug 8435112 */

 End Update_Address;

END CSC_RESPONSE_CENTER_PKG_V2;


/
