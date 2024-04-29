--------------------------------------------------------
--  DDL for Package Body IBE_EMAIL_STYLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_EMAIL_STYLE" AS
/* $Header: IBEVESB.pls 120.0.12010000.3 2016/10/13 11:56:23 kdosapat noship $ */

-- Start of comments
--    API name   : Email_Style
--    Type       : Public.
--    Function   : Retrieves email_format for the input parameters as per the below processing steps :
--                 1. Both fnd_user_id and email_address passed :
--                   a. Find matching active record with primary flag=Y.
--                   b. If no records in step a., find matching active latest record.
--                   c. If no records in step b., Return default IBE profile value.
--
--                 2. Only email_address : Return default IBE profile value.
--
--                 3. Only fnd_user_id   :
--                   a. Find active record with primary flag=Y.
--                   b. If no records in step a, Return default IBE profile value.
--
--                 4. Both fnd_user_id and email_address null : Return default IBE profile value
--
--    Pre-reqs   : None.
--    Parameters :
--    IN         : FND_USER_ID            IN  VARCHAR2 Optional
--                 FND_USER_ID_MAIL_ADDR  IN  VARCHAR2 Optional (email_address)
--
--    OUT        : X_EMAIL_STYLE_CODE     OUT VARCHAR2 Required (email_format)
--
--
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments

Procedure Email_Style
  (
  FND_USER_ID IN  VARCHAR2,
  FND_USER_ID_MAIL_ADDR IN  VARCHAR2,
  X_EMAIL_STYLE_CODE OUT NOCOPY VARCHAR2
  )
  IS
  l_api_name			CONSTANT VARCHAR2(30) 	:= 'Email_Style';
     l_api_version		CONSTANT NUMBER		:= 1.0;

     l_fnd_user_id VARCHAR2(30);
     l_mail_addr VARCHAR2(30);
     l_email_style_code VARCHAR2(30);

   CURSOR  c_case2_cursor(c_fnd_user_id  VARCHAR2, c_fnd_user_mail_addr VARCHAR2) IS
   select email_format
from hz_contact_points
where contact_point_type = 'EMAIL'
and NVL(status, 'A') = 'A'
and owner_table_name = 'HZ_PARTIES'
and owner_table_id = (select customer_id from fnd_user where user_id = c_fnd_user_id )
and email_address like c_fnd_user_mail_addr
order by last_update_date desc;

   CURSOR  c_case3_cursor(c_fnd_user_id  VARCHAR2) IS
   select email_format
from hz_contact_points
where contact_point_type = 'EMAIL'
and NVL(status, 'A') = 'A'
and owner_table_name = 'HZ_PARTIES'
and owner_table_id = (select customer_id from fnd_user where user_id = c_fnd_user_id )
and primary_flag = 'Y' ;

 CURSOR  c_case1_cursor(c_fnd_user_id  VARCHAR2, c_fnd_user_mail_addr VARCHAR2) IS
   select email_format
from hz_contact_points
where contact_point_type = 'EMAIL'
and NVL(status, 'A') = 'A'
and owner_table_name = 'HZ_PARTIES'
and owner_table_id = (select customer_id from fnd_user where user_id = c_fnd_user_id )
and email_address like c_fnd_user_mail_addr
and primary_flag = 'Y' ;

  BEGIN

   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':BEGIN');
        END IF;

        l_fnd_user_id := FND_USER_ID;
        l_mail_addr := FND_USER_ID_MAIL_ADDR;

          IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
          IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||'5917800 : Input parameters=');
          IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':FND_USER_ID=' || l_fnd_user_id);
          IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':FND_USER_ID_MAIL_ADDR=' || l_mail_addr);
        END IF;

-- Case1 : Both email and userid passed
        IF (l_fnd_user_id is not null and l_mail_addr is not null) THEN

         IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':CASE 1 - Finding matching active record with primary flag=Y');
        END IF;

        OPEN c_case1_cursor(l_fnd_user_id, l_mail_addr);
        FETCH c_case1_cursor into l_email_style_code;
        CLOSE c_case1_cursor;

         IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||'CASE 1 : X_EMAIL_STYLE_CODE= ' ||l_email_style_code);
        END IF;

      -- checking result
      IF (l_email_style_code is null) THEN

       IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':CASE 1 - latest matching active record ');
        END IF;

        OPEN c_case2_cursor(l_fnd_user_id, l_mail_addr);
        FETCH c_case2_cursor into l_email_style_code;
        CLOSE c_case2_cursor;

       IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||'CASE 1 : X_EMAIL_STYLE_CODE= ' ||l_email_style_code);
        END IF;

        -- checking result
        IF (l_email_style_code is null) THEN

         IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':CASE 1 - Reading from profile');
        END IF;

     l_email_style_code := NVL(FND_PROFILE.VALUE('IBE_DEFAULT_USER_EMAIL_STYLE'), 'MAILTEXT');

     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||'CASE 1 : X_EMAIL_STYLE_CODE= ' ||l_email_style_code);
        END IF;

        END IF;

         END IF;
        END IF;
      --  END IF;

    -- CASE 2 : Only email id passed
         IF(l_fnd_user_id is null and l_mail_addr is not null) THEN

          IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':CASE 2 - fnd_user_id is null');
          IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':CASE 2 - Reading from profile');
        END IF;

        l_email_style_code := NVL(FND_PROFILE.VALUE('IBE_DEFAULT_USER_EMAIL_STYLE'), 'MAILTEXT');

     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||'CASE 2 : X_EMAIL_STYLE_CODE= ' ||l_email_style_code);
        END IF;

        END IF;


  -- CASE 3 : Only fnd_user_id passed

         IF(l_fnd_user_id is not null and l_mail_addr is null) THEN

          IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':CASE 3 - l_mail_addr is null and fnd_user_id is not null');
          IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':CASE 3 - Querying with primary flag');
        END IF;

       OPEN c_case3_cursor(l_fnd_user_id);
        FETCH c_case3_cursor into l_email_style_code;
        CLOSE c_case3_cursor;

     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||'CASE 3 : X_EMAIL_STYLE_CODE= ' ||l_email_style_code);
        END IF;

        IF (l_email_style_code is null) THEN

         IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
          IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':CASE 3 - l_email_style_code is null');
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':CASE 3 - Reading from profile');
        END IF;

     l_email_style_code := NVL(FND_PROFILE.VALUE('IBE_DEFAULT_USER_EMAIL_STYLE'), 'MAILTEXT');

     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||'CASE 3 : X_EMAIL_STYLE_CODE= ' ||l_email_style_code);
        END IF;

        END IF;

        END IF;

        --CASE 4 : Both email and userid null

         IF(l_fnd_user_id is null and l_mail_addr is null) THEN

          IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':CASE 4 - Input parameters are null');
          IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':CASE 4 - Reading from profile');
        END IF;

        l_email_style_code := NVL(FND_PROFILE.VALUE('IBE_DEFAULT_USER_EMAIL_STYLE'), 'MAILTEXT');

     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||'CASE 4 : X_EMAIL_STYLE_CODE= ' ||l_email_style_code);
        END IF;

        END IF;



X_EMAIL_STYLE_CODE := l_email_style_code;

 EXCEPTION
    WHEN OTHERS THEN
    X_EMAIL_STYLE_CODE := 'MAILTEXT';
      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
         IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':Unidentified error in IBE_EMAIL_STYLE.Email_Style');
      END IF;

END Email_Style;

END IBE_EMAIL_STYLE;

/
