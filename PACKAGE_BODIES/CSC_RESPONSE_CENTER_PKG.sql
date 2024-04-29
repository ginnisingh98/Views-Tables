--------------------------------------------------------
--  DDL for Package Body CSC_RESPONSE_CENTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_RESPONSE_CENTER_PKG" AS
/* $Header: CSCCCRCB.pls 120.4.12010000.3 2010/03/15 10:38:52 spamujul ship $ */

--  Constants used as tokens for unexpected error messages.
    G_PKG_NAME	CONSTANT    VARCHAR2(25):=  'CSC_RESPONSE_CENTER_PKG';

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
    	(   p_pkg_name			=>  G_PKG_NAME			,
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
    	(   p_pkg_name			=>  G_PKG_NAME				,
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



 FUNCTION INIT_CC_SR_INT RETURN CC_SR_INT IS
 TMP_CC_SR_INT CC_SR_INT;
 BEGIN
  RETURN TMP_CC_SR_INT;
 END INIT_CC_SR_INT;

 FUNCTION GET_ADDRESS_REC_TYPE RETURN CSC_RESPONSE_CENTER_PKG.ADDRESS_REC_TYPE IS
 TMP_ADDRESS_REC_TYPE CSC_RESPONSE_CENTER_PKG.ADDRESS_REC_TYPE;
 BEGIN
  RETURN TMP_ADDRESS_REC_TYPE;
 END GET_ADDRESS_REC_TYPE;

--
--    28AUG00  Bug 1379490 - create account
--

 Procedure Put_in_CC_SR_Buffer (
 p_cc_sr_int_rec	IN CC_SR_INT) Is
 Begin
   CC_SR_BUFFER := p_cc_sr_int_rec;
 End Put_in_CC_SR_Buffer;

 Procedure Get_From_CC_SR_Buffer (
 x_cc_sr_int_rec	OUT NOCOPY  CC_SR_INT) Is
 Begin
   x_cc_sr_int_rec := CC_SR_BUFFER;
 End Get_From_CC_SR_Buffer;

 Procedure Init_CC_SR_Buffer
 Is
 Begin
   CC_SR_BUFFER := G_MISS_CC_SR_INT;
 End Init_CC_SR_Buffer;

	-- Wrapper for HZ procedure : phone_format for phone number globalization
	FUNCTION phone_format_Wrap(	p_phone_country_code 	in varchar2,
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
                l_raw_phone_number varchar2(10);
	Begin

		if p_phone_country_code is null then
			FND_PROFILE.get('CSC_CC_DEFAULT_TERRITORY_CODE',l_territory_code);
		else
			l_phone_country_code := p_phone_country_code;
		end if;

		l_phone_area_code := p_phone_area_code;
		l_phone_number := p_phone_number;

	    /* HZ_CONTACT_POINT_PUB.phone_format (
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
*/
             HZ_CONTACT_POINT_V2PUB.phone_format (
                                                      p_init_msg_list                 => FND_API.G_FALSE,
                                                      p_raw_phone_number              => l_raw_phone_number,
                                                      x_formatted_phone_number        => l_formatted_phone_number,
                                                      p_territory_code                => l_territory_code,
                                                      x_phone_country_code            => l_phone_country_code,
                                                      x_phone_area_code               => l_phone_area_code,
                                                      x_phone_number                  => l_phone_number,
                                                      x_return_status                 => l_return_status,
                                                      x_msg_count                     => l_msg_count,
                                                      x_msg_data                      => l_msg_data);

		-- If procedure does not return success then pass back null (since will be used in view definition)
		if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
		-- return FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' );
			return null;
		else
			return l_formatted_phone_number;
		end if;
	End phone_format_wrap;

/* New SEARCH window related objects */
PROCEDURE get_account_details(x_account_rec IN OUT  NOCOPY AccountRecTabType)
IS
  row_count               NUMBER;
  l_Account_Name          VARCHAR2(240);
  l_Account_Number        VARCHAR2(30);
  l_Cust_Account_Id       NUMBER;
  l_Acct_object_version_number NUMBER;
  l_account_status        VARCHAR2(1);
  l_multi_accounts        VARCHAR2(1);

 --
 CURSOR Get_Oldest_Acct(p_party_id NUMBER) IS
    SELECT account_name, account_number,cust_account_id, object_version_number
    FROM hz_cust_accounts
    WHERE party_id=p_party_id
    AND ((status = 'A' AND l_account_status = 'Y') OR (l_account_status = 'N'))
    AND status not in ('M', 'D')
    ORDER BY creation_date ASC;

 CURSOR Get_Latest_Acct(p_party_id NUMBER) IS
    SELECT account_name, account_number,cust_account_id, object_version_number
    FROM hz_cust_accounts
    WHERE party_id=p_party_id
    AND ((status = 'A' AND l_account_status = 'Y') OR (l_account_status = 'N'))
    AND status not in ('M', 'D')
    ORDER BY creation_date DESC;
BEGIN
    Fnd_Profile.Get('CSC_CONTACT_CENTER_SHOW_ACTIVE_ACCOUNTS',l_account_status);
    Fnd_Profile.Get('CSC_CC_DEFAULT_ACCT',l_multi_accounts);
    l_account_status := nvl(l_account_status, 'N');
    row_count := x_account_rec.COUNT;
    FOR i IN 1..row_count LOOP
        l_Account_name := NULL;
        l_Account_number := NULL;
        l_Cust_Account_Id := NULL;
        l_Acct_object_version_number := NULL;
        IF NVL(l_multi_accounts, 'N')  = 'Y' THEN
           OPEN Get_Oldest_Acct(x_Account_Rec(i).party_id);
           FETCH Get_Oldest_Acct INTO   l_Account_name, l_Account_number, l_Cust_Account_Id, l_Acct_object_version_number;
           CLOSE Get_Oldest_Acct;

           x_Account_Rec(i).Account_Name := l_Account_Name;
           x_Account_Rec(i).Account_Number := l_Account_Number;
           x_Account_Rec(i).Cust_Account_id := l_Cust_Account_Id;
           x_Account_Rec(i).object_version_number := l_Acct_object_version_number;

        ELSIF NVL(l_multi_accounts, 'N')  = 'L' THEN
          OPEN Get_Latest_Acct(x_Account_Rec(i).party_id);
          FETCH Get_Latest_Acct INTO   l_Account_name, l_Account_number, l_Cust_Account_Id, l_Acct_object_version_number;
          CLOSE Get_Latest_Acct;

          x_Account_Rec(i).Account_Name := l_Account_Name;
          x_Account_Rec(i).Account_Number := l_Account_Number;
          x_Account_Rec(i).Cust_Account_id := l_Cust_Account_Id;
          x_Account_Rec(i).object_version_number := l_Acct_object_version_number;
       ELSE
          OPEN Get_Oldest_Acct(x_Account_Rec(i).party_id);
          LOOP
          FETCH Get_Oldest_Acct INTO   l_Account_name, l_Account_number, l_Cust_Account_Id, l_Acct_object_version_number;
            IF Get_Oldest_Acct%ROWCOUNT = 2 THEN
               l_Account_name := NULL;
               l_Account_number := NULL;
               l_Cust_Account_Id := NULL;
               l_Acct_object_version_number := NULL;
               EXIT;
            END IF;
            IF Get_Oldest_Acct%NOTFOUND THEN
               EXIT;
            END IF;
          END LOOP;
          CLOSE Get_Oldest_Acct;

          x_Account_Rec(i).Account_Name := l_Account_Name;
          x_Account_Rec(i).Account_Number := l_Account_Number;
          x_Account_Rec(i).Cust_Account_id := l_Cust_Account_Id;
          x_Account_Rec(i).object_version_number := l_Acct_object_version_number;

       END IF;
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
NULL;
END get_account_details;

PROCEDURE get_phone_details(x_phone_rec IN OUT  NOCOPY PhoneRecTabType)
IS
  row_count                NUMBER;
  l_Phone_Country_Code	   VARCHAR2(10);
  l_Phone_Area_Code	   VARCHAR2(10);
  l_Phone_Number           VARCHAR2(40);
  l_Phone_Line_Type        VARCHAR2(80);
  l_phone_Line_Code        VARCHAR2(30);
  l_Phone_Id               NUMBER;
  l_Phone_object_version_number NUMBER;
  l_Phone_extension 	   VARCHAR2(20);
  l_Full_Phone		   VARCHAR2(60);
BEGIN

   row_count := x_phone_rec.COUNT;
   FOR i IN 1..row_count LOOP
     BEGIN
       SELECT ph.phone_country_code, ph.phone_area_code, ph.phone_number,
	      lkup.meaning, ph.phone_line_type,
              ph.contact_point_id, ph.object_version_number, phone_extension,
	      ph.phone_country_code||ph.phone_area_code||ph.phone_number
       INTO   l_phone_country_code, l_phone_area_code, l_phone_number,
              l_phone_line_type, l_phone_line_code,
	      l_phone_id, l_phone_object_version_number, l_phone_extension,
              l_full_phone
       FROM   hz_contact_points ph, ar_lookups lkup
       WHERE  ph.phone_line_type = lkup.lookup_code
       AND lkup.lookup_type = 'PHONE_LINE_TYPE'
       AND lkup.enabled_flag = 'Y'
       AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(lkup.start_date_active, SYSDATE))
       AND TRUNC(NVL(lkup.end_date_active,SYSDATE))
       AND ph.owner_table_id = x_Phone_Rec(i).party_id
       AND ph.owner_table_name = 'HZ_PARTIES'
       AND ph.contact_point_type = 'PHONE'
       AND ph.primary_flag = 'Y';

       x_Phone_Rec(i).Phone_Country_Code := l_Phone_Country_Code;
       x_Phone_Rec(i).Phone_Area_Code := l_Phone_Area_Code;
       x_Phone_Rec(i).Phone_Number := l_Phone_Number;
       x_Phone_Rec(i).Phone_Line_Type := l_Phone_Line_Type;
       x_Phone_Rec(i).Phone_Line_Code := l_Phone_Line_Code;
       x_Phone_Rec(i).Phone_Id := l_Phone_Id;
       x_Phone_Rec(i).object_version_number := l_Phone_object_version_number;
       x_Phone_Rec(i).Phone_Extension := l_phone_extension;
       x_phone_rec(i).Full_Phone := l_full_phone;
     EXCEPTION
     WHEN OTHERS THEN
        NULL;
     END;

  END LOOP;
EXCEPTION
WHEN OTHERS THEN
NULL;
END get_phone_details;

--
-- Name: Get_Sitephone_Details
-- Created for ER# 8606060 by mpathani
-- This procedure return the Site_Phone details
---
PROCEDURE get_sitephone_details(p_site_id   IN SiteIDRecTabType,
                                x_phone_rec IN OUT NOCOPY PhoneRecTabType)
IS
        row_count                     NUMBER;
        l_Phone_Country_Code          VARCHAR2(10);
        l_Phone_Area_Code             VARCHAR2(10);
        l_Phone_Number                VARCHAR2(40);
        l_Phone_Line_Type             VARCHAR2(80);
        l_phone_Line_Code             VARCHAR2(30);
        l_Phone_Id                    NUMBER;
        l_Phone_object_version_number NUMBER;
        l_Phone_extension             VARCHAR2(20);
        l_Full_Phone                  VARCHAR2(60);
BEGIN
        row_count := x_phone_rec.COUNT;
        FOR i IN 1..row_count
        LOOP
                BEGIN
                        SELECT ph.phone_country_code   ,
                               ph.phone_area_code      ,
                               ph.phone_number         ,
                               lkup.meaning            ,
                               ph.phone_line_type      ,
                               ph.contact_point_id     ,
                               ph.object_version_number,
                               phone_extension         ,
                               ph.phone_country_code||ph.phone_area_code||ph.phone_number
                        INTO   l_phone_country_code         ,
                               l_phone_area_code            ,
                               l_phone_number               ,
                               l_phone_line_type            ,
                               l_phone_line_code            ,
                               l_phone_id                   ,
                               l_phone_object_version_number,
                               l_phone_extension            ,
                               l_full_phone
                        FROM   hz_contact_points ph,
                               ar_lookups lkup     ,
                               hz_party_sites ps
                        WHERE  ph.phone_line_type          = lkup.lookup_code
                           AND lkup.lookup_type            = 'PHONE_LINE_TYPE'
                           AND lkup.enabled_flag           = 'Y'
                           AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(lkup.start_date_active, SYSDATE)) AND TRUNC(NVL(lkup.end_date_active,SYSDATE))
                           AND ph.owner_table_id           = p_site_id(i)
			   AND ps.party_site_id            = ph.owner_table_id
                           AND ps.party_id                 = x_Phone_Rec(i).party_id
                           AND ph.owner_table_name         = 'HZ_PARTY_SITES'
                           AND ph.contact_point_type       = 'PHONE';

                        x_Phone_Rec(i).Phone_Country_Code    := l_Phone_Country_Code;
                        x_Phone_Rec(i).Phone_Area_Code       := l_Phone_Area_Code;
                        x_Phone_Rec(i).Phone_Number          := l_Phone_Number;
                        x_Phone_Rec(i).Phone_Line_Type       := l_Phone_Line_Type;
                        x_Phone_Rec(i).Phone_Line_Code       := l_Phone_Line_Code;
                        x_Phone_Rec(i).Phone_Id              := l_Phone_Id;
                        x_Phone_Rec(i).object_version_number := l_Phone_object_version_number;
                        x_Phone_Rec(i).Phone_Extension       := l_phone_extension;
                        x_phone_rec(i).Full_Phone            := l_full_phone;
                EXCEPTION
                WHEN OTHERS THEN
                        NULL;
                END;
        END LOOP;
EXCEPTION
WHEN OTHERS THEN
        NULL;
END get_sitephone_details;

--This procedure calls the Open_MediaItem API to log a media item.
--This procedure has been moved to the server side because JTF_IH_PUB.media_rec_type
--references FND_API package (G_MISS_NUM) which cannot be accessed directly from libraries
PROCEDURE start_media_item( p_resp_appl_id in number,
                            p_resp_id      in number,
                            p_user_id      in number,
                            p_login_id     in number,
                            x_return_status out nocopy  varchar2,
                            x_msg_count     out nocopy  number,
                            x_msg_data      out nocopy  varchar2,
                            x_media_id      out nocopy  number
			    ,x_outbound_dnis in varchar2 DEFAULT NULL -- added by spamujul for 9370084
			    ,x_outbound_ani in varchar2 DEFAULT NULL -- added by spamujul for 9370084
			    ) IS


   v_true             VARCHAR2(5)  := CSC_CORE_UTILS_PVT.G_TRUE;
   v_false            VARCHAR2(5)  := CSC_CORE_UTILS_PVT.G_FALSE;
   v_ret_sts_failure  VARCHAR2(1)  := 'E';
   p_media_rec        JTF_IH_PUB.media_rec_type;

BEGIN

   p_media_rec.media_id := NULL;
   p_media_rec.media_item_type := 'TELEPHONE';
   p_media_rec.start_date_time := sysdate;
   p_media_rec.direction := 'OUTBOUND';
    -- Begin fix by spamujul for 9370084
	p_media_rec.ani  := x_outbound_ani ;
	p_media_rec.dnis := x_outbound_dnis;
   -- End fix by spamujul for 9370084

   jtf_ih_pub.open_mediaitem( p_api_version     => 1.0,
                              p_init_msg_list   => v_true,
                              p_commit          => v_true,
                              p_resp_appl_id    => p_resp_appl_id,
                              p_resp_id         => p_resp_id,
                              p_user_id         => p_user_id,
                              p_login_id        => p_login_id,
                              x_return_status   => x_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              p_media_rec       => p_media_rec,
                              x_media_id        => x_media_id);

   if x_media_id is null then
      x_return_status := v_ret_sts_failure;
   end if;

END start_media_item;


/* End of SEARCH window related objects */

END CSC_RESPONSE_CENTER_PKG;

/
