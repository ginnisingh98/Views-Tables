--------------------------------------------------------
--  DDL for Package Body CSP_DEDICATED_SITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_DEDICATED_SITES_PKG" as
/* $Header: csptdsib.pls 120.0.12010000.2 2010/04/18 23:17:33 ajosephg noship $ */
-- Start of Comments
-- Package name     : CSP_DEDICATED_SITES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_DEDICATED_SITES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptdsib.pls';

PROCEDURE Insert_Row(
px_DEDICATED_SITES_ID                       NUMBER
,p_PLANNING_PARAMETERS_ID                  NUMBER
,p_PARTY_SITE_ID                           NUMBER
,p_CREATED_BY                              NUMBER
,p_CREATION_DATE                           DATE
,p_LAST_UPDATED_BY                         NUMBER
,p_LAST_UPDATE_DATE                        DATE
,p_LAST_UPDATE_LOGIN                       NUMBER
)
IS

   p_DEDICATED_SITES_ID Number;
   CURSOR C2 IS SELECT csp_dedicated_sites_S1.nextval FROM sys.dual;
BEGIN

   If (px_DEDICATED_SITES_ID IS NULL) OR (px_DEDICATED_SITES_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO p_DEDICATED_SITES_ID;
       CLOSE C2;
   End If;


   INSERT INTO csp_dedicated_sites(
          DEDICATED_SITES_ID
          ,PLANNING_PARAMETERS_ID
          ,PARTY_SITE_ID
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ) VALUES (
           nvl(px_DEDICATED_SITES_ID,p_DEDICATED_SITES_ID)
          ,decode( p_PLANNING_PARAMETERS_ID, FND_API.G_MISS_NUM, NULL, p_PLANNING_PARAMETERS_ID)
          ,decode( p_PARTY_SITE_ID, FND_API.G_MISS_NUM, NULL, p_PARTY_SITE_ID)
          ,decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
          ,decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
          ,decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
          ,decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
          ,decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
          );
End Insert_Row;

PROCEDURE Update_Row(
p_DEDICATED_SITES_ID                       NUMBER
,p_PLANNING_PARAMETERS_ID                  NUMBER
,p_PARTY_SITE_ID                           NUMBER
,p_CREATED_BY                              NUMBER
,p_CREATION_DATE                           DATE
,p_LAST_UPDATED_BY                         NUMBER
,p_LAST_UPDATE_DATE                        DATE
,p_LAST_UPDATE_LOGIN                       NUMBER
) IS

BEGIN
    Update csp_dedicated_sites
    SET
        DEDICATED_SITES_ID = decode( p_DEDICATED_SITES_ID, FND_API.G_MISS_NUM, DEDICATED_SITES_ID, p_DEDICATED_SITES_ID)
       ,PLANNING_PARAMETERS_ID = decode( p_PLANNING_PARAMETERS_ID, FND_API.G_MISS_NUM, PLANNING_PARAMETERS_ID, p_PLANNING_PARAMETERS_ID)
       ,PARTY_SITE_ID = decode( p_PARTY_SITE_ID, FND_API.G_MISS_NUM, PARTY_SITE_ID, p_PARTY_SITE_ID)
       ,CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY)
       ,CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE)
       ,LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
       ,LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE)
       ,LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
    where DEDICATED_SITES_ID = p_DEDICATED_SITES_ID
    AND   PLANNING_PARAMETERS_ID = p_PLANNING_PARAMETERS_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
p_DEDICATED_SITES_ID                       NUMBER
,p_PLANNING_PARAMETERS_ID                  NUMBER
,p_PARTY_SITE_ID                           NUMBER
)
IS
BEGIN
    DELETE FROM csp_dedicated_sites
    where DEDICATED_SITES_ID = p_DEDICATED_SITES_ID
    AND   PLANNING_PARAMETERS_ID = p_PLANNING_PARAMETERS_ID
    AND   PARTY_SITE_ID  = P_PARTY_SITE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Delete_Row;

PROCEDURE Lock_Row(
p_DEDICATED_SITES_ID                       NUMBER
,p_PLANNING_PARAMETERS_ID                  NUMBER
,p_PARTY_SITE_ID                           NUMBER
,p_CREATED_BY                              NUMBER
,p_CREATION_DATE                           DATE
,p_LAST_UPDATED_BY                         NUMBER
,p_LAST_UPDATE_DATE                        DATE
,p_LAST_UPDATE_LOGIN                       NUMBER
)
 IS
   CURSOR C IS
       SELECT *
       FROM csp_dedicated_sites
       WHERE PARTY_SITE_ID = p_PARTY_SITE_ID
       FOR UPDATE of PARTY_SITE_ID NOWAIT;
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
           (   Recinfo.DEDICATED_SITES_ID = p_DEDICATED_SITES_ID
             and Recinfo.PLANNING_PARAMETERS_ID = p_PLANNING_PARAMETERS_ID )

       AND (    ( Recinfo.PARTY_SITE_ID = p_PARTY_SITE_ID)
            OR (    ( Recinfo.PARTY_SITE_ID IS NULL )
                AND (  p_PARTY_SITE_ID IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
        ) then
        return;
    else
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
END Lock_Row;
End CSP_DEDICATED_SITES_PKG;

/
