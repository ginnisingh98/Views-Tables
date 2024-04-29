--------------------------------------------------------
--  DDL for Package Body FND_SOS_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SOS_SERVICE" AS
  /* $Header: fndsosb.pls 120.0.12010000.1 2009/08/17 03:07:14 snellepa noship $ */
        installed_languages VARCHAR2(3000);
        database_id VARCHAR2(4500);

PROCEDURE getAllInstalledlanguages
IS
        t1 varchar2(4);
        CURSOR c1 IS
                SELECT LANGUAGE_CODE
                FROM   fnd_languages
                WHERE  INSTALLED_FLAG='I';

 BEGIN
         FOR t1 IN c1
         LOOP
                 FND_SOS_SERVICE.installed_languages := t1.LANGUAGE_CODE || ':'|| FND_SOS_SERVICE.installed_languages   ;
         END LOOP;
 END getAllInstalledlanguages;


 procedure getDatabaseID
 is
 begin
 	database_id :=FND_WEB_CONFIG.DATABASE_ID;
 end;

PROCEDURE AUTHENTICATE( p_user_name IN VARCHAR2 ,
                        p_password  IN VARCHAR2 ,
                        login_status OUT NOCOPY VARCHAR2,
                        user_id OUT NOCOPY NUMBER,
                        description out NOCOPY VARCHAR2,
                        user_status OUT NOCOPY VARCHAR2,
                        languages OUT NOCOPY VARCHAR2,
                        session_id OUT NOCOPY NUMBER,
                        xsid OUT NOCOPY VARCHAR2 ,
                        apps_database_id out NOCOPY VARCHAR2

                       )
IS
        ret     VARCHAR2(1);
        uid     NUMBER;
        sess_id NUMBER;
	enc_pwd FND_USER.ENCRYPTED_USER_PASSWORD%TYPE;
	pwd_expired varchar2(1);
	p_lang fnd_languages.nls_language%type;

BEGIN
	--++++ validate login
        ret     :=fnd_web_sec.validate_login(p_user_name, p_password);
        IF( ret <>'Y') THEN
                login_status:='INVALID_LOGIN';
        END IF;

        login_status:='VALID_LOGIN';

	--+++ get user details


        SELECT user_id,description,ENCRYPTED_USER_PASSWORD
        INTO   user_id,description,enc_pwd
        FROM   fnd_user
        WHERE  UPPER(user_name)=UPPER(p_user_name);

        IF enc_pwd ='INVALID' THEN
		user_status:='LOCKED';
	ELSE
		fnd_signon.is_pwd_expired(user_id, pwd_expired);
		If pwd_expired ='Y' then
			user_status:='PASSWORD_EXPIRED';
		ELSE
        		user_status:='ACTIVE';
        	END IF;
        END IF;

        --+++get session details
        sess_id := fnd_session_management.createSession(p_user_id=>user_id ) ;
        SELECT xsid
        INTO   xsid
        FROM   icx_sessions
        WHERE  session_id=sess_id;

	session_id:=sess_id;

        --+++get language details
        p_lang:=fnd_profile.value_specific(NAME=>'ICX_LANGUAGE',USER_ID=>user_id);

        SELECT language_code
	INTO   languages
	FROM   fnd_languages
        WHERE  nls_language = upper(p_lang);

        IF installed_languages IS NULL THEN
                getAllInstalledlanguages;
        END IF;
        languages:=languages
        ||':'|| FND_SOS_SERVICE.installed_languages;

        --+++get database id
        If FND_SOS_SERVICE.database_id is Null Then
        	getDatabaseID;
        End If;
        apps_database_id:=FND_SOS_SERVICE.database_id;



END authenticate;

FUNCTION validate_user_cookie(p_user_name VARCHAR2 ,
                              p_password  VARCHAR2)
        RETURN VARCHAR2
IS
        retval  VARCHAR2(1) :='N';
        sess_id NUMBER;
        CURSOR check_cookie IS
                SELECT session_id
                FROM   icx_sessions
                WHERE  user_id=
                       (SELECT user_id
                       FROM    fnd_user
                       WHERE   user_name=UPPER(p_user_name)
                       )
           AND xsid         =p_password
           AND disabled_flag='N';

BEGIN
        OPEN check_cookie;
        FETCH check_cookie
        INTO  sess_id;

        IF check_cookie%notfound THEN
                retval:='N';
        ELSE
                retval:='Y';
        END IF;
        CLOSE check_cookie;
        RETURN retval;
END validate_user_cookie;


END fnd_sos_service;

/
