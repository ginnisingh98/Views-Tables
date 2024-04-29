--------------------------------------------------------
--  DDL for Package Body CSC_PROF_MODULE_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_MODULE_GROUPS_PKG" as
/* $Header: csctpmgb.pls 120.3 2005/09/18 23:38:39 vshastry ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_MODULE_GROUPS_PKG
-- Purpose          :
-- History          :
--  03 Nov 00 axsubram Added load_row for NLS (# 1487333)
--  26 Nov 02 JAmose  Addition of NOCOPY and the Removal of Fnd_Api.G_MISS*
--                    from the definition for the performance reason
--  19 july 2005 tpalaniv Modified the logic in load_row API to fetch last_updated_by based on FND API as part
--                        of R12 ATG Project - Seed Data Versioning
-- 19-09-2005 vshastry Bug 4596220. Added condition in insert row
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_MODULE_GROUPS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctpmgb.pls';

PROCEDURE Insert_Row(
          px_MODULE_GROUP_ID   IN OUT NOCOPY NUMBER,
          p_FORM_FUNCTION_ID    NUMBER,
          p_FORM_FUNCTION_NAME  VARCHAR2,
          p_RESPONSIBILITY_ID    NUMBER,
          p_RESP_APPL_ID    NUMBER,
          p_PARTY_TYPE    VARCHAR2,
          p_GROUP_ID    NUMBER,
          p_DASHBOARD_GROUP_FLAG    VARCHAR2,
          p_CURRENCY_CODE    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG          VARCHAR2,
          p_APPLICATION_ID       NUMBER,
          p_DASHBOARD_GROUP_ID      NUMBER)

 IS
   CURSOR C2 IS SELECT CSC_PROF_MODULE_GROUPS_S.nextval FROM sys.dual;
   ps_SEEDED_FLAG    Varchar2(3);

BEGIN

   /* added the below 2 lines for bug 4596220 */
   ps_seeded_flag := p_seeded_flag;
   IF NVL(p_seeded_flag, 'N') <> 'Y' THEN

   /* Added This If Condition for Bug 1944040*/
      If p_Created_by=1 then
           ps_seeded_flag:='Y';
      Else
           ps_seeded_flag:='N';
      End If;
   END IF;

   If (px_MODULE_GROUP_ID IS NULL) OR (px_MODULE_GROUP_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_MODULE_GROUP_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSC_PROF_MODULE_GROUPS(
           MODULE_GROUP_ID,
           FORM_FUNCTION_ID,
           FORM_FUNCTION_NAME,
           RESPONSIBILITY_ID,
           RESP_APPL_ID,
           PARTY_TYPE,
           GROUP_ID,
           DASHBOARD_GROUP_FLAG,
           CURRENCY_CODE,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           SEEDED_FLAG,
           APPLICATION_ID,
           DASHBOARD_GROUP_ID
          ) VALUES (
           px_MODULE_GROUP_ID,
           decode( p_FORM_FUNCTION_ID, FND_API.G_MISS_NUM, NULL, p_FORM_FUNCTION_ID),
           decode( p_FORM_FUNCTION_NAME,FND_API.G_MISS_CHAR,NULL, p_FORM_FUNCTION_NAME),
           decode( p_RESPONSIBILITY_ID, FND_API.G_MISS_NUM, NULL, p_RESPONSIBILITY_ID),
           decode( p_RESP_APPL_ID, FND_API.G_MISS_NUM, NULL, p_RESP_APPL_ID),
           decode( p_PARTY_TYPE, FND_API.G_MISS_CHAR, NULL, p_PARTY_TYPE),
           decode( p_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_GROUP_ID),
           decode( p_DASHBOARD_GROUP_FLAG, FND_API.G_MISS_CHAR, NULL, p_DASHBOARD_GROUP_FLAG),
           decode( p_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, p_CURRENCY_CODE),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_SEEDED_FLAG,CSC_CORE_UTILS_PVT.G_MISS_CHAR, NULL, ps_SEEDED_FLAG),
           decode( p_APPLICATION_ID,CSC_CORE_UTILS_PVT.G_MISS_NUM, NULL, p_APPLICATION_ID),
           decode( p_DASHBOARD_GROUP_ID,CSC_CORE_UTILS_PVT.G_MISS_NUM,NULL, p_DASHBOARD_GROUP_ID));
End Insert_Row;

PROCEDURE Update_Row(
          p_MODULE_GROUP_ID    NUMBER,
          p_FORM_FUNCTION_ID    NUMBER,
          p_FORM_FUNCTION_NAME  VARCHAR2,
          p_RESPONSIBILITY_ID    NUMBER,
          p_RESP_APPL_ID    NUMBER,
          p_PARTY_TYPE    VARCHAR2,
          p_GROUP_ID    NUMBER,
          p_DASHBOARD_GROUP_FLAG    VARCHAR2,
          p_CURRENCY_CODE    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG            VARCHAR2,
          p_APPLICATION_ID         NUMBER,
          p_DASHBOARD_GROUP_ID      NUMBER)

 IS
 BEGIN
    Update CSC_PROF_MODULE_GROUPS
    SET
              FORM_FUNCTION_ID = p_FORM_FUNCTION_ID,
              RESPONSIBILITY_ID =p_RESPONSIBILITY_ID,
              RESP_APPL_ID =p_RESP_APPL_ID,
              FORM_FUNCTION_NAME=p_FORM_FUNCTION_NAME,
              PARTY_TYPE = p_PARTY_TYPE,
              GROUP_ID = p_GROUP_ID,
              DASHBOARD_GROUP_FLAG = p_DASHBOARD_GROUP_FLAG,
              CURRENCY_CODE = p_CURRENCY_CODE,
              LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
              LAST_UPDATED_BY = p_LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
              SEEDED_FLAG = p_SEEDED_FLAG,
              APPLICATION_ID = p_APPLICATION_ID,
              DASHBOARD_GROUP_ID = p_DASHBOARD_GROUP_ID
    where MODULE_GROUP_ID = p_MODULE_GROUP_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_MODULE_GROUP_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSC_PROF_MODULE_GROUPS
    WHERE MODULE_GROUP_ID = p_MODULE_GROUP_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_MODULE_GROUP_ID    NUMBER,
          p_FORM_FUNCTION_ID    NUMBER,
          p_FORM_FUNCTION_NAME  VARCHAR2,
          p_RESPONSIBILITY_ID    NUMBER,
          p_RESP_APPL_ID    NUMBER,
          p_PARTY_TYPE    VARCHAR2,
          p_GROUP_ID    NUMBER,
          p_DASHBOARD_GROUP_FLAG    VARCHAR2,
          p_CURRENCY_CODE    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG      VARCHAR2,
          p_APPLICATION_ID   NUMBER,
          p_DASHBOARD_GROUP_ID      NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM CSC_PROF_MODULE_GROUPS
        WHERE MODULE_GROUP_ID =  p_MODULE_GROUP_ID
        FOR UPDATE of MODULE_GROUP_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.MODULE_GROUP_ID = p_MODULE_GROUP_ID)
       AND (    ( Recinfo.FORM_FUNCTION_NAME = p_FORM_FUNCTION_NAME)
            OR (    ( Recinfo.FORM_FUNCTION_NAME IS NULL )
                AND (  p_FORM_FUNCTION_NAME IS NULL )))
       AND (    ( Recinfo.PARTY_TYPE = p_PARTY_TYPE)
            OR (    ( Recinfo.PARTY_TYPE IS NULL )
                AND (  p_PARTY_TYPE IS NULL )))
       AND (    ( Recinfo.GROUP_ID = p_GROUP_ID)
            OR (    ( Recinfo.GROUP_ID IS NULL )
                AND (  p_GROUP_ID IS NULL )))
       AND (    ( Recinfo.DASHBOARD_GROUP_ID = p_DASHBOARD_GROUP_ID)
             OR (    ( Recinfo.DASHBOARD_GROUP_ID IS NULL )
                AND (  p_DASHBOARD_GROUP_ID IS NULL )))
    /*   AND (    ( Recinfo.DASHBOARD_GROUP_FLAG = p_DASHBOARD_GROUP_FLAG)
            OR (    ( Recinfo.DASHBOARD_GROUP_FLAG IS NULL )
                AND (  p_DASHBOARD_GROUP_FLAG IS NULL )))   */
       AND (    ( Recinfo.CURRENCY_CODE = p_CURRENCY_CODE)
            OR (    ( Recinfo.CURRENCY_CODE IS NULL )
                AND (  p_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.SEEDED_FLAG = p_SEEDED_FLAG)
            OR (    ( Recinfo.SEEDED_FLAG IS NULL )
                AND (  p_SEEDED_FLAG IS NULL )))
       AND (    ( Recinfo.RESPONSIBILITY_ID  = p_RESPONSIBILITY_ID)
            OR (    ( Recinfo.RESPONSIBILITY_ID IS NULL )
                AND (  p_RESPONSIBILITY_ID  IS NULL )))
       AND (    ( Recinfo.RESP_APPL_ID  = p_RESP_APPL_ID)
            OR (    ( Recinfo.RESP_APPL_ID IS NULL )
                AND (  p_RESP_APPL_ID  IS NULL )))
       AND (    ( Recinfo.APPLICATION_ID  = p_APPLICATION_ID)
            OR (    ( Recinfo.APPLICATION_ID IS NULL )
                AND (  p_APPLICATION_ID  IS NULL )))
       )

       then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

PROCEDURE Load_Row(
          p_MODULE_GROUP_ID     NUMBER,
          p_FORM_FUNCTION_ID    NUMBER,
          p_FORM_FUNCTION_NAME  VARCHAR2,
          p_RESPONSIBILITY_ID    NUMBER := NULL,
          p_RESP_APPL_ID    NUMBER := NULL,
          p_PARTY_TYPE          VARCHAR2,
          p_GROUP_ID            NUMBER,
          p_DASHBOARD_GROUP_FLAG    VARCHAR2,
          p_CURRENCY_CODE       VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY     NUMBER,
          p_LAST_UPDATE_LOGIN   NUMBER,
          p_SEEDED_FLAG         VARCHAR2,
          p_APPLICATION_ID      NUMBER,
          p_DASHBOARD_GROUP_ID  NUMBER,
          P_Owner	        VARCHAR2)
   IS
	l_user_id				number := 0;
	l_module_group_id		number ;
    Begin

  	 l_module_group_id := p_module_group_id ;

	 Csc_Prof_Module_Groups_Pkg.Update_Row(
          	p_MODULE_GROUP_ID      => p_module_group_id,
          	p_FORM_FUNCTION_ID     => p_form_function_id,
          	p_FORM_FUNCTION_NAME   => p_form_function_name,
                p_RESPONSIBILITY_ID    => p_responsibility_id,
                p_RESP_APPL_ID    => p_resp_appl_id,
          	p_PARTY_TYPE           => p_party_type,
          	p_GROUP_ID             => p_group_id,
          	p_DASHBOARD_GROUP_FLAG => p_dashboard_group_flag,
          	p_CURRENCY_CODE        => p_currency_code,
          	p_LAST_UPDATE_DATE     => p_last_update_date,
          	p_LAST_UPDATED_BY      => p_last_updated_by,
          	p_LAST_UPDATE_LOGIN    => 0,
                p_SEEDED_FLAG          => p_seeded_flag,
                p_APPLICATION_ID       => p_application_id,
                p_DASHBOARD_GROUP_ID   => p_dashboard_group_id);

          EXCEPTION
             WHEN NO_DATA_FOUND THEN

		 Csc_Prof_Module_Groups_Pkg.Insert_Row(
          		px_MODULE_GROUP_ID     => l_module_group_id,
          		p_FORM_FUNCTION_ID     => p_form_function_id,
          		p_FORM_FUNCTION_NAME   => p_form_function_name,
                        p_RESPONSIBILITY_ID    => p_responsibility_id,
                        p_RESP_APPL_ID    => p_resp_appl_id,
          		p_PARTY_TYPE           => p_party_type,
          		p_GROUP_ID             => p_group_id,
          		p_DASHBOARD_GROUP_FLAG => p_dashboard_group_flag,
          		p_CURRENCY_CODE        => p_currency_code,
          		p_LAST_UPDATE_DATE     => p_last_update_date,
          		p_LAST_UPDATED_BY      => p_last_updated_by,
          		p_CREATION_DATE        => p_last_update_date,
          		p_CREATED_BY           => p_last_updated_by,
          		p_LAST_UPDATE_LOGIN    => 0,
                        p_SEEDED_FLAG          => p_seeded_flag,
                        p_APPLICATION_ID       => p_application_id,
                        p_DASHBOARD_GROUP_ID   => p_dashboard_group_id);

    End Load_Row;
End CSC_PROF_MODULE_GROUPS_PKG;

/
