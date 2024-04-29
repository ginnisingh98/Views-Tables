--------------------------------------------------------
--  DDL for Package Body WF_SOA_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_SOA_CTX_PKG" AS
    /* $Header: WFSOACTXB.pls 120.0.12010000.9 2009/07/26 07:09:15 snellepa noship $ */


    pAppsBaseLang  fnd_languages.nls_language%type;

/* private function to get apps base Language Code  */
function  getAppsBaseLang
return varchar2
is
begin

         IF WF_SOA_CTX_PKG.pAppsBaseLang IS NULL THEN
         	SELECT language_code
        	INTO   WF_SOA_CTX_PKG.pAppsBaseLang
        	FROM   fnd_languages
        	WHERE  Installed_flag = 'B';
         END IF;

         return WF_SOA_CTX_PKG.pAppsBaseLang;

end;
    /* private procedure to get User specific Language Details*/

    procedure getUserLang( userId Number, lang_code OUT NOCOPY  varchar2)
    is
    	pTemp fnd_languages.nls_language%type;
    begin
                            pTemp:=fnd_profile.value_specific('ICX_LANGUAGE',user_id=>userId);
                            SELECT language_code
                            INTO   lang_code
                            FROM   fnd_languages
                            WHERE  nls_language = pTemp
                            and Installed_flag in ('B','I');
    exception
    	WHEN No_Data_found THEN
    		lang_code :=WF_SOA_CTX_PKG.getAppsBaseLang;
    end;



PROCEDURE setNLSContext(userId       VARCHAR2,
                        languageCode VARCHAR2)
IS
        L_LANGUAGE           VARCHAR2(50);
        L_LANGUAGE_CODE      VARCHAR2(50);
        L_DATE_FORMAT        VARCHAR2(50);
        L_DATE_LANGUAGE      VARCHAR2(50);
        L_NUMERIC_CHARACTERS VARCHAR2(50);
        L_NLS_SORT           VARCHAR2(50);
        L_NLS_TERRITORY      VARCHAR2(50);
        L_LIMIT_TIME         NUMBER(15);
        L_LIMIT_CONNECTS     NUMBER(15);
        L_ORG_ID             VARCHAR2(50);
        L_TIMEOUT            NUMBER(15);
BEGIN
        -- get the parameters to be passed to fnd_global from fnd_session_management
        FND_SESSION_MANAGEMENT.SETUSERNLS(userId, languageCode, L_LANGUAGE, L_LANGUAGE_CODE, L_DATE_FORMAT, L_DATE_LANGUAGE, L_NUMERIC_CHARACTERS, L_NLS_SORT, L_NLS_TERRITORY, L_LIMIT_TIME, L_LIMIT_CONNECTS, L_ORG_ID, L_TIMEOUT);
        --- set the values through fnd_global
        FND_GLOBAL.SET_NLS_CONTEXT( L_LANGUAGE, L_DATE_FORMAT, L_DATE_LANGUAGE, L_NUMERIC_CHARACTERS, L_NLS_SORT, L_NLS_TERRITORY);
END setNLSContext ;
/* */
PROCEDURE SETCONTEXT_ID(pUserID      NUMBER,
                        pRespID      NUMBER,
                        pRespAppID   NUMBER,
                        pRespAppName VARCHAR2,
                        pSecGrpID      NUMBER,
                        pLangCode    VARCHAR2,
                        pOrgID       NUMBER)
IS

        pTemp       VARCHAR2(1);
BEGIN

        -- Initialize APPS
        FND_GLOBAL.APPS_INITIALIZE(pUserID, pRespID, pRespAppID, pSecGrpID);
        IF(pRespAppID <> -1) THEN
                MO_GLOBAL.Init(pRespAppName);
                -- Set MOAC Values
                IF pOrgID IS NOT NULL THEN
                        BEGIN
                                SELECT 'X'
                                INTO   pTemp
                                FROM   hr_operating_units
                                WHERE  usable_flag IS NULL
                                   AND ORGANIZATION_ID =pOrgID;

                                MO_GLOBAL.set_policy_context('S',pOrgID);
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                raise_application_error(-20001,'INVALID_ORGID');
                        END;
                END IF;
        END IF;
        --Set NLS
        setNLSContext(pUserID, pLangCode);
END SETCONTEXT_ID;
/* */
PROCEDURE GETCONTEXT_ID( pUserName            VARCHAR2,
                         pResp                VARCHAR2,
                         pRespApp             VARCHAR2,
                         pSecurityGroup       VARCHAR2,
                         pLang                VARCHAR2,
                         pIsLangCode          NUMBER default 0,
                         pUserID OUT NOCOPY          NUMBER,
                         pRespID OUT NOCOPY          NUMBER,
                         pRespAppID OUT NOCOPY       NUMBER,
                         pSecurityGroupID OUT NOCOPY NUMBER,
                         pLangCode OUT NOCOPY        VARCHAR2 ,
                         x_status_code OUT NOCOPY VARCHAR2,
                         x_error_code OUT NOCOPY VARCHAR2
                         )
IS
        pStage NUMBER;
        pTemp varchar2(100);
        nTemp NUMBER;
BEGIN
        --initialize to default values
        pUserID:=-1;
        pRespID:=-1;
        pRespAppID:=-1;
        pSecurityGroupID:=0;
        pLangCode:='US';

        x_status_code:='F'; -- Initially FAILURE
        x_error_code:=NULL;
        --Start Username->UserID
        IF pUserName IS NULL THEN
                raise_application_error(-20001,'INVALID_USER_NAME');
        END IF;
        pStage:=1;
        SELECT user_id
        INTO   pUserID
        FROM   fnd_user
        WHERE  user_name = upper(pUserName);

        --End Username->UserID
        pStage:=2;
        --Start LangCode
        IF ( pLang IS NULL ) THEN
                --No language specified get the details from profile, else default to US
                WF_SOA_CTX_PKG.getUserLang( pUserID, pLangCode);
        ELSE                        -- language is specifed
                IF pIsLangCode=1 THEN -- and it has been specified as Code
                        SELECT language_code
                        INTO   pLangCode
                        FROM   fnd_languages
                        WHERE  language_code = upper(pLang)
                        and Installed_flag in ('B','I');

                ELSE -- it has been specied as Name ( in English !!)
                        SELECT language_code
                        INTO   pLangCode
                        FROM   fnd_languages
                        WHERE  nls_language = upper(pLang)
                        and Installed_flag in ('B','I');


                END IF;
        END IF;
        --To derive Resp Name , we need App Name also..

        IF ( pRespApp IS NOT NULL ) THEN

		pStage:=3;
		 SELECT B.APPLICATION_ID
		 INTO   pRespAppID
		 FROM   FND_APPLICATION B
                WHERE  B.APPLICATION_SHORT_NAME=Upper(pRespApp);
        END IF;


        If pResp is NOT NULL Then

        	IF pRespAppID <> -1 Then
			pStage  :=4;
			IF ( InStr(pResp,'{key}')=1) THEN
				--get from key
				SELECT RESPONSIBILITY_ID
				INTO   pRespID
				FROM   fnd_responsibility
				WHERE  APPLICATION_ID    =pRespAppID
				   AND RESPONSIBILITY_KEY=SUBSTR(pResp,6);

			ELSE
				--get from name
				SELECT B.RESPONSIBILITY_ID
				INTO   pRespID
				FROM   FND_RESPONSIBILITY_TL T,
				       FND_RESPONSIBILITY B
				WHERE  B.RESPONSIBILITY_ID  = T.RESPONSIBILITY_ID
				   AND B.APPLICATION_ID     = T.APPLICATION_ID
				   AND T.LANGUAGE           = pLangCode
				   AND b.application_id     = pRespAppID
				   AND T.RESPONSIBILITY_NAME= pResp;

			END IF;
		ELSE

			--Start Resp name->ID
			pStage                  :=4;
			IF ( InStr(pResp,'{key}')=1) THEN
				--get from key
				SELECT count(*)
				INTO   nTemp
				FROM   fnd_responsibility
				WHERE  RESPONSIBILITY_KEY=SUBSTR(pResp,6);
				If nTemp =0 Then
					Raise No_data_Found;
				elsif nTemp=1 Then
					SELECT RESPONSIBILITY_ID,APPLICATION_ID
					INTO   pRespID, pRespAppID
					FROM   fnd_responsibility
					WHERE  RESPONSIBILITY_KEY=SUBSTR(pResp,6);
				else
					pStage:=3;
					Raise No_data_found;
				End If;

			ELSE

				--SELECT B.RESPONSIBILITY_ID
				SELECT COUNT(*)
				INTO   nTemp
				FROM   FND_RESPONSIBILITY_TL T,
				       FND_RESPONSIBILITY B
				WHERE  B.RESPONSIBILITY_ID  = T.RESPONSIBILITY_ID
				   AND B.APPLICATION_ID     = T.APPLICATION_ID
				   AND T.LANGUAGE           = pLangCode
				   AND T.RESPONSIBILITY_NAME= pResp;

				If nTemp =0 Then
					Raise No_data_Found;
				elsif nTemp=1 Then
					SELECT B.RESPONSIBILITY_ID, B.APPLICATION_ID
					INTO   pRespID, pRespAppID
					FROM   FND_RESPONSIBILITY_TL T,
					       FND_RESPONSIBILITY B
					WHERE  B.RESPONSIBILITY_ID  = T.RESPONSIBILITY_ID
					   AND B.APPLICATION_ID     = T.APPLICATION_ID
					   AND T.LANGUAGE           = pLangCode
					   AND T.RESPONSIBILITY_NAME= pResp;
				else
					pStage:=3;
					Raise No_data_found;
				End If;

			END IF;

                END IF;


         END IF;

         -- changing from security group name to security group key
         --  based on comments from Abhishek.verma

        pStage:=5;
        SELECT SECURITY_GROUP_ID
        INTO   pSecurityGroupID
        FROM   FND_SECURITY_GROUPS
        WHERE  upper(SECURITY_GROUP_KEY) = upper(nvl(pSecurityGroup,'STANDARD'));

        -- changes for bug 	8492785
        -- need to check for user-resp combination here
        -- as SOA Java code calls only getcontext_id
        pStage:=6;
        IF pRespID <> -1 THEN
        	If fnd_profile.value_specific('ENABLE_SECURITY_GROUPS',RESPONSIBILITY_ID=> pRespID, APPLICATION_ID=>pRespAppID )='Y' Then
		       SELECT 1
			INTO   nTemp
			FROM   FND_USER_RESP_GROUPS
			WHERE  user_id=pUserID
			   AND RESPONSIBILITY_ID=pRespID
			   and SECURITY_GROUP_ID=pSecurityGroupID
			   AND rownum <2;
		Else
			SELECT 1
			INTO   nTemp
			FROM   FND_USER_RESP_GROUPS
			WHERE  user_id=pUserID
			AND RESPONSIBILITY_ID=pRespID
			AND rownum <2;
		End if;

        END IF;

        If x_error_code is Null then
        	x_status_code:='S';
        End If;

EXCEPTION
WHEN No_Data_found THEN
        IF pStage=1 THEN
                x_error_code:='INVALID_USER_NAME';
        ELSIF pStage=2 THEN
                x_error_code:='INVALID_LANGCODE';
                WF_SOA_CTX_PKG.getUserLang( pUserID, pLangCode);
        ELSIF pStage=3 THEN
                x_error_code:='INVALID_RESP_APP_NAME';
        ELSIF pStage=4 THEN
                x_error_code:='INVALID_RESP_NAME';
        ELSIF pStage=5 THEN
                x_error_code:='INVALID_SECGRP';
        ELSIF pStage=6 THEN
               x_error_code:='RESP_NOT_ASSIGNED_TO_USER';
        END IF;
END GETCONTEXT_ID;

/* */
PROCEDURE setContext(pUserName      VARCHAR2,
                     pResp          VARCHAR2,
                     pRespApp       VARCHAR2,
                     pSecurityGroup VARCHAR2,
                     pnlslanguage   VARCHAR2,
                     pIsLangCode    NUMBER default 0,
                     pOrgId         NUMBER)
IS
        pLangCode fnd_languages.language_code%TYPE;
        pUserId fnd_user.user_id%TYPE;
        pAppId fnd_application.application_id%TYPE;
        pRespId fnd_responsibility.responsibility_id%TYPE;
        pSecGrpId fnd_security_groups.security_group_id%TYPE;
        x_status_code VARCHAR2(1);
        x_error_code varchar2(50);
BEGIN
        GETCONTEXT_ID(pUserName, pResp,pRespApp,pSecurityGroup, pnlslanguage,pIsLangCode, pUserId,pRespId,pAppId,pSecGrpId,pLangCode,x_status_code,x_error_code);
        IF x_status_code ='S' THEN
        	SETCONTEXT_ID(pUserId, pRespID, pAppId ,pRespApp, pSecGrpId , pLangCode , pOrgId);
        ELSE
        	RAISE_APPLICATION_ERROR(-20001,  x_error_code);
        END IF;
END setContext;





END WF_SOA_CTX_PKG;

/
