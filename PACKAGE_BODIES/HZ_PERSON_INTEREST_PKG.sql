--------------------------------------------------------
--  DDL for Package Body HZ_PERSON_INTEREST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PERSON_INTEREST_PKG" as
/* $Header: ARHPINTB.pls 120.8 2005/10/30 03:54:13 appldev ship $ */


PROCEDURE Insert_Row(
		  x_PERSON_INTEREST_ID         IN   OUT NOCOPY   NUMBER,
                  x_LEVEL_OF_INTEREST          IN     VARCHAR2,
                  x_PARTY_ID                   IN     NUMBER,
                  x_LEVEL_OF_PARTICIPATION     IN     VARCHAR2,
                  x_INTEREST_TYPE_CODE         IN     VARCHAR2,
                  x_SPORT_INDICATOR            IN     VARCHAR2,
                  x_INTEREST_NAME              IN     VARCHAR2,
                  x_COMMENTS                   IN     VARCHAR2,
                  x_SUB_INTEREST_TYPE_CODE     IN     VARCHAR2,
                  x_TEAM                       IN     VARCHAR2,
                  x_SINCE                      IN     DATE,
                  x_OBJECT_VERSION_NUMBER      IN     NUMBER,
                  x_STATUS                     IN     VARCHAR2,
                  x_CREATED_BY_MODULE          IN     VARCHAR2,
                  x_APPLICATION_ID             IN     NUMBER) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
   INSERT INTO HZ_PERSON_INTEREST(
           PERSON_INTEREST_ID,
           LEVEL_OF_INTEREST,
           PARTY_ID,
           LEVEL_OF_PARTICIPATION,
           INTEREST_TYPE_CODE,
           SPORT_INDICATOR,
           INTEREST_NAME,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           COMMENTS,
           SUB_INTEREST_TYPE_CODE,
           TEAM,
           SINCE,
           STATUS,
           OBJECT_VERSION_NUMBER,
           CREATED_BY_MODULE,
           APPLICATION_ID

          ) VALUES (
           DECODE( x_PERSON_INTEREST_ID, FND_API.G_MISS_NUM, HZ_PERSON_INTEREST_S.NEXTVAL, NULL, HZ_PERSON_INTEREST_S.NEXTVAL, X_PERSON_INTEREST_ID ),
           decode( x_LEVEL_OF_INTEREST, FND_API.G_MISS_CHAR, NULL,x_LEVEL_OF_INTEREST),
           decode( x_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_PARTY_ID),
           decode( x_LEVEL_OF_PARTICIPATION, FND_API.G_MISS_CHAR, NULL,x_LEVEL_OF_PARTICIPATION),
           decode( x_INTEREST_TYPE_CODE, FND_API.G_MISS_CHAR, NULL,x_INTEREST_TYPE_CODE),
           decode( x_SPORT_INDICATOR, FND_API.G_MISS_CHAR, NULL,x_SPORT_INDICATOR),
           decode( x_INTEREST_NAME, FND_API.G_MISS_CHAR, NULL,x_INTEREST_NAME),
           HZ_UTILITY_V2PUB.CREATED_BY,
           HZ_UTILITY_V2PUB.CREATION_DATE,
           HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
           HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
           HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
           HZ_UTILITY_V2PUB.REQUEST_ID,
           HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
           HZ_UTILITY_V2PUB.PROGRAM_ID,
           HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
           decode( x_COMMENTS, FND_API.G_MISS_CHAR, NULL,x_COMMENTS),
           decode( x_SUB_INTEREST_TYPE_CODE, FND_API.G_MISS_CHAR, NULL,x_SUB_INTEREST_TYPE_CODE),
           decode( x_TEAM, FND_API.G_MISS_CHAR, NULL,x_TEAM),
           decode( x_SINCE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_SINCE),
           DECODE( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
           decode( x_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, x_OBJECT_VERSION_NUMBER ),
           decode( x_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, x_CREATED_BY_MODULE ),
           HZ_UTILITY_V2PUB.APPLICATION_ID

       )  RETURNING
             PERSON_INTEREST_ID
         INTO
             X_PERSON_INTEREST_ID;

         l_success := 'Y';

     EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
             IF INSTRB( SQLERRM, 'HZ_PERSON_INTEREST_U1' ) <> 0 OR
                INSTRB( SQLERRM, 'HZ_PERSON_INTEREST_PK' ) <> 0
             THEN
             DECLARE
                 l_count             NUMBER;
                 l_dummy             VARCHAR2(1);
             BEGIN
                 l_count := 1;
                 WHILE l_count > 0 LOOP
                     SELECT HZ_PERSON_INTEREST_S.NEXTVAL
                     INTO X_PERSON_INTEREST_ID FROM dual;
                     BEGIN
                         SELECT 'Y' INTO l_dummy
                         FROM HZ_PERSON_INTEREST
                         WHERE PERSON_INTEREST_ID = X_PERSON_INTEREST_ID;
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


PROCEDURE Delete_Row(                  x_PERSON_INTEREST_ID            NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_PERSON_INTEREST
    WHERE PERSON_INTEREST_ID = x_PERSON_INTEREST_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                    x_Rowid         IN OUT NOCOPY          VARCHAR2,
                    x_PERSON_INTEREST_ID         IN     NUMBER,
 		   x_LEVEL_OF_INTEREST          IN     VARCHAR2,
 		   x_PARTY_ID                   IN     NUMBER,
 		   x_LEVEL_OF_PARTICIPATION     IN     VARCHAR2,
 		   x_INTEREST_TYPE_CODE         IN     VARCHAR2,
 		   x_SPORT_INDICATOR            IN     VARCHAR2,
 		   x_INTEREST_NAME              IN     VARCHAR2,
 		   x_COMMENTS                   IN     VARCHAR2,
 		   x_SUB_INTEREST_TYPE_CODE     IN     VARCHAR2,
 		   x_TEAM                       IN     VARCHAR2,
 		   x_SINCE                      IN     DATE,
 		   x_OBJECT_VERSION_NUMBER      IN     NUMBER,
 		   x_STATUS                     IN     VARCHAR2,
 		   x_CREATED_BY_MODULE          IN     VARCHAR2,
                   x_APPLICATION_ID             IN     NUMBER
 ) IS
 BEGIN
    Update HZ_PERSON_INTEREST
    SET
             PERSON_INTEREST_ID   = decode( x_PERSON_INTEREST_ID, NULL, PERSON_INTEREST_ID, FND_API.G_MISS_NUM, NULL, x_PERSON_INTEREST_ID),
             LEVEL_OF_INTEREST    = decode( x_LEVEL_OF_INTEREST, NULL , LEVEL_OF_INTEREST, FND_API.G_MISS_CHAR, NULL, x_LEVEL_OF_INTEREST),
             PARTY_ID 		= decode( x_PARTY_ID, NULL, PARTY_ID, FND_API.G_MISS_NUM, NULL, x_PARTY_ID),
             LEVEL_OF_PARTICIPATION = decode( x_LEVEL_OF_PARTICIPATION, NULL, LEVEL_OF_PARTICIPATION, FND_API.G_MISS_CHAR, NULL, x_LEVEL_OF_PARTICIPATION),
             INTEREST_TYPE_CODE = decode( x_INTEREST_TYPE_CODE, NULL, INTEREST_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, x_INTEREST_TYPE_CODE),
             SPORT_INDICATOR 	= decode( x_SPORT_INDICATOR, NULL, SPORT_INDICATOR, FND_API.G_MISS_CHAR, NULL, x_SPORT_INDICATOR),
             INTEREST_NAME 	= decode( x_INTEREST_NAME, NULL, INTEREST_NAME, FND_API.G_MISS_CHAR, NULL, x_INTEREST_NAME),
             -- Bug 3032780
             -- CREATED_BY 	= HZ_UTILITY_V2PUB.CREATED_BY,
             -- CREATION_DATE 	= HZ_UTILITY_V2PUB.CREATION_DATE,
             LAST_UPDATE_LOGIN 	= HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE 	= HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
             LAST_UPDATED_BY 	= HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
             REQUEST_ID 	= HZ_UTILITY_V2PUB.REQUEST_ID,
             PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
             PROGRAM_ID 	= HZ_UTILITY_V2PUB.PROGRAM_ID,
             PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
             COMMENTS 		= decode( x_COMMENTS, NULL, COMMENTS, FND_API.G_MISS_CHAR, NULL, x_COMMENTS),
             SUB_INTEREST_TYPE_CODE = decode( x_SUB_INTEREST_TYPE_CODE, NULL, SUB_INTEREST_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, x_SUB_INTEREST_TYPE_CODE),
             TEAM 		= decode( x_TEAM, NULL, TEAM, FND_API.G_MISS_CHAR, null, x_TEAM),
             SINCE 		= decode( x_SINCE, NULL, SINCE, FND_API.G_MISS_DATE, NULL, x_SINCE),
             STATUS		= decode(x_STATUS, NULL, STATUS, FND_API.G_MISS_CHAR,NULL,x_STATUS),
	     OBJECT_VERSION_NUMBER = DECODE( X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
	     CREATED_BY_MODULE 	= DECODE( X_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
             APPLICATION_ID 	= HZ_UTILITY_V2PUB.APPLICATION_ID


    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(

                  x_Rowid                       IN      VARCHAR2,
                  x_PERSON_INTEREST_ID          IN      NUMBER,
                  x_LEVEL_OF_INTEREST           IN      VARCHAR2,
                  x_PARTY_ID                    IN      NUMBER,
                  x_LEVEL_OF_PARTICIPATION      IN      VARCHAR2,
                  x_INTEREST_TYPE_CODE          IN      VARCHAR2,
                  x_SPORT_INDICATOR             IN      VARCHAR2,
                  x_INTEREST_NAME               IN      VARCHAR2,
                  x_CREATED_BY                  IN      NUMBER,
                  x_CREATION_DATE               IN      DATE,
                  x_LAST_UPDATE_LOGIN           IN      NUMBER,
                  x_LAST_UPDATE_DATE            IN      DATE,
                  x_LAST_UPDATED_BY             IN      NUMBER,
                  x_REQUEST_ID                  IN      NUMBER,
                  x_PROGRAM_APPLICATION_ID      IN      NUMBER,
                  x_PROGRAM_ID                  IN      NUMBER,
                  x_PROGRAM_UPDATE_DATE         IN      DATE,
                  x_COMMENTS                    IN      VARCHAR2,
                  x_SUB_INTEREST_TYPE_CODE      IN      VARCHAR2,
                  x_TEAM                        IN      VARCHAR2,
                  x_SINCE                       IN      DATE,
                  x_STATUS                      IN      VARCHAR2,
                  x_CREATED_BY_MODULE           IN      VARCHAR2
 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_PERSON_INTEREST
         WHERE rowid = x_Rowid
         FOR UPDATE of PERSON_INTEREST_ID NOWAIT;
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
           (    ( Recinfo.PERSON_INTEREST_ID = x_PERSON_INTEREST_ID)
            OR (    ( Recinfo.PERSON_INTEREST_ID = NULL )
                AND (  x_PERSON_INTEREST_ID = NULL )))
       AND (    ( Recinfo.LEVEL_OF_INTEREST = x_LEVEL_OF_INTEREST)
            OR (    ( Recinfo.LEVEL_OF_INTEREST = NULL )
                AND (  x_LEVEL_OF_INTEREST = NULL )))
       AND (    ( Recinfo.PARTY_ID = x_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID = NULL )
                AND (  x_PARTY_ID = NULL )))
       AND (    ( Recinfo.LEVEL_OF_PARTICIPATION = x_LEVEL_OF_PARTICIPATION)
            OR (    ( Recinfo.LEVEL_OF_PARTICIPATION = NULL )
                AND (  x_LEVEL_OF_PARTICIPATION = NULL )))
       AND (    ( Recinfo.INTEREST_TYPE_CODE = x_INTEREST_TYPE_CODE)
            OR (    ( Recinfo.INTEREST_TYPE_CODE = NULL )
                AND (  x_INTEREST_TYPE_CODE = NULL )))
       AND (    ( Recinfo.SPORT_INDICATOR = x_SPORT_INDICATOR)
            OR (    ( Recinfo.SPORT_INDICATOR = NULL )
                AND (  x_SPORT_INDICATOR = NULL )))
       AND (    ( Recinfo.INTEREST_NAME = x_INTEREST_NAME)
            OR (    ( Recinfo.INTEREST_NAME = NULL )
                AND (  x_INTEREST_NAME = NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY = NULL )
                AND (  x_CREATED_BY = NULL )))
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
       AND (    ( Recinfo.COMMENTS = x_COMMENTS)
            OR (    ( Recinfo.COMMENTS = NULL )
                AND (  x_COMMENTS = NULL )))
       AND (    ( Recinfo.SUB_INTEREST_TYPE_CODE = x_SUB_INTEREST_TYPE_CODE)
            OR (    ( Recinfo.SUB_INTEREST_TYPE_CODE = NULL )
                AND (  x_SUB_INTEREST_TYPE_CODE = NULL )))
       AND (    ( Recinfo.TEAM = x_TEAM)
            OR (    ( Recinfo.TEAM = NULL )
                AND (  x_TEAM = NULL )))
       AND (    ( Recinfo.SINCE = x_SINCE)
            OR (    ( Recinfo.SINCE = NULL )
                AND (  x_SINCE = NULL )))

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
    x_person_interest_id                    IN OUT NOCOPY NUMBER,
    x_level_of_interest                     OUT    NOCOPY VARCHAR2,
    x_party_id                              OUT    NOCOPY NUMBER,
    x_level_of_participation                OUT    NOCOPY VARCHAR2,
    x_interest_type_code                    OUT    NOCOPY VARCHAR2,
    x_comments                              OUT    NOCOPY VARCHAR2,
    x_sport_indicator                       OUT    NOCOPY VARCHAR2,
    x_sub_interest_type_code                OUT    NOCOPY VARCHAR2,
    x_interest_name                         OUT    NOCOPY VARCHAR2,
    x_team                                  OUT    NOCOPY VARCHAR2,
    x_since                                 OUT    NOCOPY DATE,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
      NVL(person_interest_id, FND_API.G_MISS_NUM),
      NVL(level_of_interest, FND_API.G_MISS_CHAR),
      NVL(party_id, FND_API.G_MISS_NUM),
      NVL(level_of_participation, FND_API.G_MISS_CHAR),
      NVL(interest_type_code, FND_API.G_MISS_CHAR),
      NVL(comments, FND_API.G_MISS_CHAR),
      NVL(sport_indicator, FND_API.G_MISS_CHAR),
      NVL(sub_interest_type_code, FND_API.G_MISS_CHAR),
      NVL(interest_name, FND_API.G_MISS_CHAR),
      NVL(team, FND_API.G_MISS_CHAR),
      NVL(since, FND_API.G_MISS_DATE),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM),
      NVL(created_by_module, FND_API.G_MISS_CHAR)
    INTO
      x_person_interest_id,
      x_level_of_interest,
      x_party_id,
      x_level_of_participation,
      x_interest_type_code,
      x_comments,
      x_sport_indicator,
      x_sub_interest_type_code,
      x_interest_name,
      x_team,
      x_since,
      x_status,
      x_application_id,
      x_created_by_module
    FROM HZ_PERSON_INTEREST
    WHERE person_interest_id = x_person_interest_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      --2890664, Changed this message token
      FND_MESSAGE.SET_TOKEN('RECORD', 'PERSON_INTEREST_REC');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_person_interest_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;


END HZ_PERSON_INTEREST_PKG;

/
