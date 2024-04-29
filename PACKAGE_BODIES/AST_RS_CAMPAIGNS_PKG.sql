--------------------------------------------------------
--  DDL for Package Body AST_RS_CAMPAIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_RS_CAMPAIGNS_PKG" as
/* $Header: asttrcab.pls 120.1 2005/06/01 04:20:54 appldev  $ */
-- Start of Comments
-- Package name     : AST_RS_CAMPAIGNS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AST_RS_CAMPAIGNS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asttrcab.pls';

PROCEDURE Insert_Row(
          px_RS_CAMPAIGN_ID   IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_CAMPAIGN_ID    NUMBER,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_STATUS    VARCHAR2,
          p_ENABLED_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    VARCHAR2)

 IS
   CURSOR C2 IS SELECT AST_RS_CAMPAIGNS_S.nextval FROM sys.dual;
   --
   l_count number := 0;
BEGIN
   If (px_RS_CAMPAIGN_ID IS NULL) OR (px_RS_CAMPAIGN_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_RS_CAMPAIGN_ID;
       CLOSE C2;
   End If;
   --
   -- Before insert rec, check dup rec;
   select count(rs_campaign_id)
	into l_count
	from ast_rs_campaigns
    where resource_id = p_resource_id
	 and campaign_id = p_campaign_id;
   --
   if (l_count > 0) then
	 return;
   end if;
   --
   INSERT INTO AST_RS_CAMPAIGNS(
           RS_CAMPAIGN_ID,
           RESOURCE_ID,
           CAMPAIGN_ID,
           START_DATE,
           END_DATE,
           STATUS,
           ENABLED_FLAG,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
          ) VALUES (
           px_RS_CAMPAIGN_ID,
           decode( p_RESOURCE_ID, FND_API.G_MISS_NUM, NULL, p_RESOURCE_ID),
           decode( p_CAMPAIGN_ID, FND_API.G_MISS_NUM, NULL, p_CAMPAIGN_ID),
           decode( p_START_DATE, FND_API.G_MISS_DATE, NULL, p_START_DATE),
           decode( p_END_DATE, FND_API.G_MISS_DATE, NULL, p_END_DATE),
           decode( p_STATUS, FND_API.G_MISS_CHAR, NULL, p_STATUS),
           decode( p_ENABLED_FLAG, FND_API.G_MISS_CHAR, NULL, p_ENABLED_FLAG),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_CHAR, NULL, p_LAST_UPDATE_LOGIN));
End Insert_Row;

PROCEDURE Update_Row(
          p_RS_CAMPAIGN_ID    NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_CAMPAIGN_ID    NUMBER,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_STATUS    VARCHAR2,
          p_ENABLED_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    VARCHAR2)

 IS
 BEGIN
    Update AST_RS_CAMPAIGNS
    SET
              RESOURCE_ID = decode( p_RESOURCE_ID, FND_API.G_MISS_NUM, RESOURCE_ID, p_RESOURCE_ID),
              CAMPAIGN_ID = decode( p_CAMPAIGN_ID, FND_API.G_MISS_NUM, CAMPAIGN_ID, p_CAMPAIGN_ID),
              START_DATE = decode( p_START_DATE, FND_API.G_MISS_DATE, START_DATE, p_START_DATE),
              END_DATE = decode( p_END_DATE, FND_API.G_MISS_DATE, END_DATE, p_END_DATE),
              STATUS = decode( p_STATUS, FND_API.G_MISS_CHAR, STATUS, p_STATUS),
              ENABLED_FLAG = decode( p_ENABLED_FLAG, FND_API.G_MISS_CHAR, ENABLED_FLAG, p_ENABLED_FLAG),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_CHAR, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
    where RS_CAMPAIGN_ID = p_RS_CAMPAIGN_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_RS_CAMPAIGN_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AST_RS_CAMPAIGNS
    WHERE RS_CAMPAIGN_ID = p_RS_CAMPAIGN_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_RS_CAMPAIGN_ID    NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_CAMPAIGN_ID    NUMBER,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_STATUS    VARCHAR2,
          p_ENABLED_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AST_RS_CAMPAIGNS
        WHERE RS_CAMPAIGN_ID =  p_RS_CAMPAIGN_ID
        FOR UPDATE of RS_CAMPAIGN_ID NOWAIT;
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
           (      Recinfo.RS_CAMPAIGN_ID = p_RS_CAMPAIGN_ID)
       AND (    ( Recinfo.RESOURCE_ID = p_RESOURCE_ID)
            OR (    ( Recinfo.RESOURCE_ID IS NULL )
                AND (  p_RESOURCE_ID IS NULL )))
       AND (    ( Recinfo.CAMPAIGN_ID = p_CAMPAIGN_ID)
            OR (    ( Recinfo.CAMPAIGN_ID IS NULL )
                AND (  p_CAMPAIGN_ID IS NULL )))
       AND (    ( Recinfo.START_DATE = p_START_DATE)
            OR (    ( Recinfo.START_DATE IS NULL )
                AND (  p_START_DATE IS NULL )))
       AND (    ( Recinfo.END_DATE = p_END_DATE)
            OR (    ( Recinfo.END_DATE IS NULL )
                AND (  p_END_DATE IS NULL )))
       AND (    ( Recinfo.STATUS = p_STATUS)
            OR (    ( Recinfo.STATUS IS NULL )
                AND (  p_STATUS IS NULL )))
       AND (    ( Recinfo.ENABLED_FLAG = p_ENABLED_FLAG)
            OR (    ( Recinfo.ENABLED_FLAG IS NULL )
                AND (  p_ENABLED_FLAG IS NULL )))
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

End AST_RS_CAMPAIGNS_PKG;

/
