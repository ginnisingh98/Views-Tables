--------------------------------------------------------
--  DDL for Package Body JTM_LOOKUPS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_LOOKUPS_ACC_PKG" AS
/* $Header: jtmvluab.pls 120.1 2005/08/24 02:19:49 saradhak noship $ */
-- Start of Comments
--
-- NAME
--   JTM_LOOKUPS_ACC_PKG
--
-- PURPOSE
--   TABLE-LEVEL PACKAGE for JTM_FND_LOOKUPS_ACC.
--
--   PROCEDURES:
--
--
-- NOTES
--
--
-- HISTORY
--   04-09-2002 YOHUANG Created.
--
-- End of Comments
--
--
--
G_PKG_NAME            CONSTANT VARCHAR2(30) := 'JTM_LOOKUPS_ACC_PKG';
G_FILE_NAME           CONSTANT VARCHAR2(12) := 'jtmvluab.pls';
--
--
-- ACCESS_ID is generated from SEQUENCE. Later ACCESS_ID will be removed.
-- It handles the DUPLICATE_VALUE on INDEX Exception.
-- For Application Specific ACC tables, the counter is always 1.
PROCEDURE INSERT_ROW (
   X_LOOKUP_TYPE                     IN VARCHAR2 ,
   X_VIEW_APPLICATION_ID             IN NUMBER ,
   X_SECURITY_GROUP_ID               IN NUMBER ,
   X_APPLICATION_ID                  IN NUMBER ,
   X_ACCESS_ID                     OUT NOCOPY NUMBER
) IS

BEGIN

    SELECT JTM_FND_LOOKUPS_ACC_S.NEXTVAL
    INTO X_ACCESS_ID FROM DUAL;

    INSERT INTO JTM_FND_LOOKUPS_ACC (
            ACCESS_ID  ,
            LAST_UPDATE_DATE ,
            LAST_UPDATED_BY  ,
            CREATION_DATE    ,
            CREATED_BY       ,
            LOOKUP_TYPE      ,
            VIEW_APPLICATION_ID ,
            SECURITY_GROUP_ID,
            APPLICATION_ID   ,
            COUNTER
     )
     VALUES (
            X_ACCESS_ID ,
            SYSDATE,
            1,
            SYSDATE,
            1,
            X_LOOKUP_TYPE,
            X_VIEW_APPLICATION_ID,
            X_SECURITY_GROUP_ID,
            X_APPLICATION_ID,
            1
    );

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
         FND_MESSAGE.set_name('JTM', 'JTM_UNIQUE_INDEX_VIOLATION');
         FND_MSG_PUB.add;
         APP_EXCEPTION.raise_exception;
    WHEN OTHERS THEN
         RAISE;
END  INSERT_ROW;

-- For Application Specific ACC table, there won't be any update allowed.
PROCEDURE UPDATE_ROW (
   X_LOOKUP_TYPE                     IN VARCHAR2 ,
   X_VIEW_APPLICATION_ID             IN NUMBER ,
   X_SECURITY_GROUP_ID               IN NUMBER ,
   X_APPLICATION_ID                  IN NUMBER
) IS

BEGIN
    UPDATE JTM_FND_LOOKUPS_ACC
    SET LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY  = 1,
        CREATED_BY       = 1,
        CREATION_DATE    = CREATION_DATE,
        LOOKUP_TYPE = X_LOOKUP_TYPE ,
        VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID,
        SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
        APPLICATION_ID = X_APPLICATION_ID
    WHERE LOOKUP_TYPE = X_LOOKUP_TYPE
    AND   VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
    AND   SECURITY_GROUP_ID   = X_SECURITY_GROUP_ID
    AND   APPLICATION_ID      = X_APPLICATION_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END UPDATE_ROW;


-- For Deletion, later on we might need to add an "EXPRIATION_DATE" Column to support deletion
-- Through FNDLOADER
PROCEDURE DELETE_ROW (
   X_LOOKUP_TYPE                     IN VARCHAR2 ,
   X_VIEW_APPLICATION_ID             IN NUMBER ,
   X_SECURITY_GROUP_ID               IN NUMBER ,
   X_APPLICATION_ID                  IN NUMBER
) IS

BEGIN
    DELETE FROM JTM_FND_LOOKUPS_ACC
    WHERE LOOKUP_TYPE = X_LOOKUP_TYPE
    AND   VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
    AND   SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
    AND   APPLICATION_ID = X_APPLICATION_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END DELETE_ROW;

END JTM_LOOKUPS_ACC_PKG;

/
