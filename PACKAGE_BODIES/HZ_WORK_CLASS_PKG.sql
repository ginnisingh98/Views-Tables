--------------------------------------------------------
--  DDL for Package Body HZ_WORK_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_WORK_CLASS_PKG" as
/* $Header: ARHPWCTB.pls 120.8 2005/10/30 04:22:59 appldev ship $ */


PROCEDURE Insert_Row(
                 x_WORK_CLASS_ID             IN OUT NOCOPY    NUMBER,
	          x_LEVEL_OF_EXPERIENCE       IN    VARCHAR2,
	          x_WORK_CLASS_NAME           IN    VARCHAR2,
	          x_EMPLOYMENT_HISTORY_ID     IN    NUMBER,
	          x_STATUS                    IN    VARCHAR2,
	          x_OBJECT_VERSION_NUMBER     IN    NUMBER,
    		  x_CREATED_BY_MODULE         IN    VARCHAR2,
    		  x_application_id            IN    NUMBER
 ) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
   INSERT INTO HZ_WORK_CLASS(
           WORK_CLASS_ID,
           LEVEL_OF_EXPERIENCE,
           WORK_CLASS_NAME,
           CREATED_BY,
           EMPLOYMENT_HISTORY_ID,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           STATUS,
           OBJECT_VERSION_NUMBER,
           CREATED_BY_MODULE,
           APPLICATION_ID
          ) VALUES (
           DECODE( x_WORK_CLASS_ID, FND_API.G_MISS_NUM, HZ_WORK_CLASS_S.NEXTVAL, NULL, HZ_WORK_CLASS_S.NEXTVAL, X_WORK_CLASS_ID ),
           decode( x_LEVEL_OF_EXPERIENCE, FND_API.G_MISS_CHAR, NULL,x_LEVEL_OF_EXPERIENCE),
           decode( x_WORK_CLASS_NAME, FND_API.G_MISS_CHAR, NULL,x_WORK_CLASS_NAME),
           HZ_UTILITY_V2PUB.CREATED_BY,
           decode( x_EMPLOYMENT_HISTORY_ID, FND_API.G_MISS_NUM, NULL,x_EMPLOYMENT_HISTORY_ID),
           HZ_UTILITY_V2PUB.CREATION_DATE,
           HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
           HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
           HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
           HZ_UTILITY_V2PUB.REQUEST_ID,
           HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
           HZ_UTILITY_V2PUB.PROGRAM_ID,
           HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
           decode( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
           decode( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
           decode( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
           HZ_UTILITY_V2PUB.APPLICATION_ID
           )  RETURNING
            WORK_CLASS_ID
        INTO
            X_WORK_CLASS_ID;

        l_success := 'Y';

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            IF INSTRB( SQLERRM, 'HZ_WORK_CLASS_U1' ) <> 0 OR
               INSTRB( SQLERRM, 'HZ_WORK_CLASS_PK' ) <> 0
            THEN
            DECLARE
                l_count             NUMBER;
                l_dummy             VARCHAR2(1);
            BEGIN
                l_count := 1;
                WHILE l_count > 0 LOOP
                    SELECT HZ_WORK_CLASS_S.NEXTVAL
                    INTO X_WORK_CLASS_ID FROM dual;
                    BEGIN
                        SELECT 'Y' INTO l_dummy
                        FROM HZ_WORK_CLASS
                        WHERE WORK_CLASS_ID = X_WORK_CLASS_ID;
                        l_count := 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_count := 0;
                    END;
                END LOOP;
            END;
            ELSE
                RAISE;
            END IF;

    END;
    END LOOP;

END Insert_Row;




PROCEDURE Delete_Row(                  x_WORK_CLASS_ID                 NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_WORK_CLASS
    WHERE WORK_CLASS_ID = x_WORK_CLASS_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid         IN  OUT NOCOPY         VARCHAR2,
                  x_WORK_CLASS_ID             IN     NUMBER,
		  x_LEVEL_OF_EXPERIENCE       IN    VARCHAR2,
		  x_WORK_CLASS_NAME           IN    VARCHAR2,
		  x_EMPLOYMENT_HISTORY_ID     IN    NUMBER,
		  x_STATUS                    IN    VARCHAR2,
		  x_OBJECT_VERSION_NUMBER     IN    NUMBER,
		  x_CREATED_BY_MODULE         IN    VARCHAR2,
    		  x_application_id            IN    NUMBER
 ) IS
 BEGIN
    Update HZ_WORK_CLASS
    SET

            WORK_CLASS_ID = decode( x_WORK_CLASS_ID, NULL, WORK_CLASS_ID, FND_API.G_MISS_NUM, NULL, x_WORK_CLASS_ID),
             LEVEL_OF_EXPERIENCE = decode( x_LEVEL_OF_EXPERIENCE, NULL, LEVEL_OF_EXPERIENCE, FND_API.G_MISS_CHAR, NULL, x_LEVEL_OF_EXPERIENCE),
             WORK_CLASS_NAME = decode( x_WORK_CLASS_NAME, NULL, WORK_CLASS_NAME, FND_API.G_MISS_CHAR, NULL, x_WORK_CLASS_NAME),
             -- Bug 3032780
             -- CREATED_BY = HZ_UTILITY_V2PUB.CREATED_BY,
             EMPLOYMENT_HISTORY_ID = decode( x_EMPLOYMENT_HISTORY_ID, NULL, EMPLOYMENT_HISTORY_ID, FND_API.G_MISS_NUM,NULL, x_EMPLOYMENT_HISTORY_ID),
             -- Bug 3032780
             -- CREATION_DATE = HZ_UTILITY_V2PUB.CREATION_DATE,
             LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
             LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
             REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID,
             PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
             PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
             PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
             STATUS      =decode(x_STATUS, NULL,STATUS, FND_API.G_MISS_CHAR,NULL,x_STATUS),
             OBJECT_VERSION_NUMBER = DECODE( X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
	     CREATED_BY_MODULE = DECODE( X_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
             APPLICATION_ID=HZ_UTILITY_V2PUB.APPLICATION_ID
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_WORK_CLASS_ID                 NUMBER,
                  x_LEVEL_OF_EXPERIENCE           VARCHAR2,
                  x_WORK_CLASS_NAME               VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_EMPLOYMENT_HISTORY_ID         NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_STATUS                        VARCHAR2
 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_WORK_CLASS
         WHERE rowid = x_Rowid
         FOR UPDATE of WORK_CLASS_ID NOWAIT;
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
           (    ( Recinfo.WORK_CLASS_ID = x_WORK_CLASS_ID)
            OR (    ( Recinfo.WORK_CLASS_ID = NULL )
                AND (  x_WORK_CLASS_ID = NULL )))
       AND (    ( Recinfo.LEVEL_OF_EXPERIENCE = x_LEVEL_OF_EXPERIENCE)
            OR (    ( Recinfo.LEVEL_OF_EXPERIENCE = NULL )
                AND (  x_LEVEL_OF_EXPERIENCE = NULL )))
       AND (    ( Recinfo.WORK_CLASS_NAME = x_WORK_CLASS_NAME)
            OR (    ( Recinfo.WORK_CLASS_NAME = NULL )
                AND (  x_WORK_CLASS_NAME = NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY = NULL )
                AND (  x_CREATED_BY = NULL )))
       AND (    ( Recinfo.EMPLOYMENT_HISTORY_ID = x_EMPLOYMENT_HISTORY_ID)
            OR (    ( Recinfo.EMPLOYMENT_HISTORY_ID = NULL )
                AND (  x_EMPLOYMENT_HISTORY_ID = NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE = NULL )
                AND (  x_CREATION_DATE = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN = NULL )
                AND (  x_LAST_UPDATE_LOGIN = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE = NULL )
                AND (  x_LAST_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY = NULL )
                AND (  x_LAST_UPDATED_BY = NULL )))
       AND (    ( Recinfo.REQUEST_ID = x_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID = NULL )
                AND (  x_REQUEST_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = x_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID = NULL )
                AND (  x_PROGRAM_APPLICATION_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_ID = x_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID = NULL )
                AND (  x_PROGRAM_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = x_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE = NULL )
                AND (  x_PROGRAM_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.STATUS = x_STATUS)
            OR (    ( Recinfo.STATUS = NULL )
                AND (  x_STATUS = NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

PROCEDURE Select_Row (
    x_work_class_id                         IN OUT NOCOPY NUMBER,
    x_level_of_experience                   OUT    NOCOPY VARCHAR2,
    x_work_class_name                       OUT    NOCOPY VARCHAR2,
    x_employment_history_id                 OUT    NOCOPY NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
      NVL(work_class_id, FND_API.G_MISS_NUM),
      NVL(level_of_experience, FND_API.G_MISS_CHAR),
      NVL(work_class_name, FND_API.G_MISS_CHAR),
      NVL(employment_history_id, FND_API.G_MISS_NUM),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM),
      NVL(created_by_module, FND_API.G_MISS_CHAR)
    INTO
      x_work_class_id,
      x_level_of_experience,
      x_work_class_name,
      x_employment_history_id,
      x_status,
      x_application_id,
      x_created_by_module
    FROM HZ_WORK_CLASS
    WHERE work_class_id = x_work_class_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      --2890664, Changed this token
      FND_MESSAGE.SET_TOKEN('RECORD', 'WORK_CLASS_REC');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_work_class_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

END HZ_WORK_CLASS_PKG;

/
