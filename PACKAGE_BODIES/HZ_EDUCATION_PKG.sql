--------------------------------------------------------
--  DDL for Package Body HZ_EDUCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EDUCATION_PKG" as
/* $Header: ARHPEDTB.pls 120.6 2005/10/30 04:22:09 appldev ship $ */


PROCEDURE Insert_Row(
                  x_EDUCATION_ID                IN   OUT NOCOPY    NUMBER,
                  x_COURSE_MAJOR                IN        VARCHAR2,
                  x_PARTY_ID                    IN        NUMBER,
                  x_DEGREE_RECEIVED             IN        VARCHAR2,
                  x_LAST_DATE_ATTENDED          IN        DATE,
                  x_SCHOOL_ATTENDED_NAME        IN        VARCHAR2,
                  x_TYPE_OF_SCHOOL              IN        VARCHAR2,
                  x_START_DATE_ATTENDED         IN        DATE,
                  x_STATUS                      IN        VARCHAR2,
                  x_SCHOOL_PARTY_ID             IN        NUMBER,
    		  x_OBJECT_VERSION_NUMBER       IN        NUMBER,
    		  x_CREATED_BY_MODULE           IN        VARCHAR2,
    		  x_APPLICATION_ID              IN        NUMBER

 )IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN
WHILE l_success = 'N' LOOP
BEGIN
   INSERT INTO HZ_EDUCATION(
           EDUCATION_ID,
           COURSE_MAJOR,
           PARTY_ID,
           SCHOOL_PARTY_ID,
           DEGREE_RECEIVED,
           LAST_DATE_ATTENDED,
           SCHOOL_ATTENDED_NAME,
           TYPE_OF_SCHOOL,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           START_DATE_ATTENDED,
           STATUS,
           OBJECT_VERSION_NUMBER,
           CREATED_BY_MODULE,
           APPLICATION_ID

          ) VALUES (
           decode( x_EDUCATION_ID, FND_API.G_MISS_NUM, HZ_EDUCATION_S.NEXTVAL, NULL, HZ_EDUCATION_S.NEXTVAL, X_EDUCATION_ID ),
           decode( x_COURSE_MAJOR, FND_API.G_MISS_CHAR, NULL,x_COURSE_MAJOR),
           decode( x_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_PARTY_ID),
           decode( x_SCHOOL_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_SCHOOL_PARTY_ID),
           decode( x_DEGREE_RECEIVED, FND_API.G_MISS_CHAR, NULL,x_DEGREE_RECEIVED),
           decode( x_LAST_DATE_ATTENDED, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_DATE_ATTENDED),
           decode( x_SCHOOL_ATTENDED_NAME, FND_API.G_MISS_CHAR, NULL,x_SCHOOL_ATTENDED_NAME),
           decode( x_TYPE_OF_SCHOOL, FND_API.G_MISS_CHAR, NULL,x_TYPE_OF_SCHOOL),
	   HZ_UTILITY_V2PUB.CREATED_BY,
	   HZ_UTILITY_V2PUB.CREATION_DATE,
	   HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
	   HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
	   HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
	   HZ_UTILITY_V2PUB.REQUEST_ID,
	   HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
	   HZ_UTILITY_V2PUB.PROGRAM_ID,
	   HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
           decode( x_START_DATE_ATTENDED, FND_API.G_MISS_DATE, TO_DATE(NULL),x_START_DATE_ATTENDED),
           DECODE( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
           DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
           DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
           HZ_UTILITY_V2PUB.APPLICATION_ID

           )
             RETURNING
   	              EDUCATION_ID
   	          INTO
   	              X_EDUCATION_ID;

   	          l_success := 'Y';

   	      EXCEPTION
   	          WHEN DUP_VAL_ON_INDEX THEN
   	              IF INSTRB( SQLERRM, 'HZ_EDUCATION_U1' ) <> 0 OR
   	                 INSTRB( SQLERRM, 'HZ_EDUCATION_PK' ) <> 0
   	              THEN
   	              DECLARE
   	                  l_count             NUMBER;
   	                  l_dummy             VARCHAR2(1);
   	              BEGIN
   	                  l_count := 1;
   	                  WHILE l_count > 0 LOOP
   	                      SELECT HZ_EDUCATION_S.NEXTVAL
   	                      INTO X_EDUCATION_ID FROM dual;
   	                      BEGIN
   	                          SELECT 'Y' INTO l_dummy
   	                          FROM HZ_EDUCATION
   	                          WHERE EDUCATION_ID = EDUCATION_ID;
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




PROCEDURE Delete_Row(                  x_EDUCATION_ID                  NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_EDUCATION
    WHERE EDUCATION_ID = x_EDUCATION_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid      IN  OUT NOCOPY            VARCHAR2,
                  x_EDUCATION_ID                IN   OUT NOCOPY    NUMBER,
                  x_COURSE_MAJOR                IN        VARCHAR2,
                  x_PARTY_ID                    IN        NUMBER,
                  x_SCHOOL_PARTY_ID             IN        NUMBER,
                  x_DEGREE_RECEIVED             IN        VARCHAR2,
                  x_LAST_DATE_ATTENDED          IN        DATE,
                  x_SCHOOL_ATTENDED_NAME        IN        VARCHAR2,
                  x_TYPE_OF_SCHOOL              IN        VARCHAR2,
                  x_START_DATE_ATTENDED         IN        DATE,
                  x_STATUS                      IN        VARCHAR2,
    		  x_OBJECT_VERSION_NUMBER       IN        NUMBER,
    		  x_CREATED_BY_MODULE           IN        VARCHAR2,
    		  x_APPLICATION_ID              IN        NUMBER

 ) IS
 BEGIN
    Update HZ_EDUCATION
    SET
	     EDUCATION_ID = decode( x_EDUCATION_ID, NULL, EDUCATION_ID, FND_API.G_MISS_NUM, NULL, x_EDUCATION_ID),
             COURSE_MAJOR = decode( x_COURSE_MAJOR, NULL, COURSE_MAJOR, FND_API.G_MISS_CHAR,NULL, x_COURSE_MAJOR),
             PARTY_ID = decode( x_PARTY_ID, NULL, PARTY_ID, FND_API.G_MISS_NUM, NULL, x_PARTY_ID),
             SCHOOL_PARTY_ID = decode( x_SCHOOL_PARTY_ID, NULL, SCHOOL_PARTY_ID, FND_API.G_MISS_NUM, NULL, x_SCHOOL_PARTY_ID),
             DEGREE_RECEIVED = decode( x_DEGREE_RECEIVED, NULL, DEGREE_RECEIVED, FND_API.G_MISS_CHAR, NULL, x_DEGREE_RECEIVED),
             LAST_DATE_ATTENDED = decode( x_LAST_DATE_ATTENDED, NULL, LAST_DATE_ATTENDED, FND_API.G_MISS_DATE, NULL, x_LAST_DATE_ATTENDED),
             SCHOOL_ATTENDED_NAME = decode( x_SCHOOL_ATTENDED_NAME, NULL, SCHOOL_ATTENDED_NAME, FND_API.G_MISS_CHAR, NULL, x_SCHOOL_ATTENDED_NAME),
             TYPE_OF_SCHOOL = decode( x_TYPE_OF_SCHOOL, NULL, TYPE_OF_SCHOOL, FND_API.G_MISS_CHAR, NULL, x_TYPE_OF_SCHOOL),
           -- Bug 3032780
           --  CREATED_BY = HZ_UTILITY_V2PUB.CREATED_BY,
	   --  CREATION_DATE = HZ_UTILITY_V2PUB.CREATION_DATE,
	     LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
	     LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
	     LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
	     REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID,
	     PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
	     PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
             PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
             START_DATE_ATTENDED = decode( x_START_DATE_ATTENDED, NULL, START_DATE_ATTENDED, FND_API.G_MISS_DATE, NULL, x_START_DATE_ATTENDED),
             STATUS    =decode(x_STATUS, NULL, STATUS, FND_API.G_MISS_CHAR, NULL, x_STATUS),
             OBJECT_VERSION_NUMBER = DECODE( x_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
             CREATED_BY_MODULE = DECODE( x_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
             APPLICATION_ID = DECODE( x_APPLICATION_ID, NULL, APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID )
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;


PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_EDUCATION_ID                  NUMBER,
                  x_COURSE_MAJOR                  VARCHAR2,
                  x_PARTY_ID                      NUMBER,
                  x_SCHOOL_PARTY_ID               NUMBER,
                  x_DEGREE_RECEIVED               VARCHAR2,
                  x_LAST_DATE_ATTENDED            DATE,
                  x_SCHOOL_ATTENDED_NAME          VARCHAR2,
                  x_TYPE_OF_SCHOOL                VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                  x_START_DATE_ATTENDED           DATE,
                  x_STATUS                        VARCHAR2

 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_EDUCATION
         WHERE rowid = x_Rowid
         FOR UPDATE of EDUCATION_ID NOWAIT;
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
           (    ( Recinfo.EDUCATION_ID = x_EDUCATION_ID)
            OR (    ( Recinfo.EDUCATION_ID = NULL )
                AND (  x_EDUCATION_ID = NULL )))
       AND (    ( Recinfo.COURSE_MAJOR = x_COURSE_MAJOR)
            OR (    ( Recinfo.COURSE_MAJOR = NULL )
                AND (  x_COURSE_MAJOR = NULL )))
       AND (    ( Recinfo.PARTY_ID = x_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID = NULL )
                AND (  x_PARTY_ID = NULL )))
       AND (    ( Recinfo.SCHOOL_PARTY_ID = x_SCHOOL_PARTY_ID)
            OR (    ( Recinfo.SCHOOL_PARTY_ID = NULL )
                AND (  x_SCHOOL_PARTY_ID = NULL )))
       AND (    ( Recinfo.DEGREE_RECEIVED = x_DEGREE_RECEIVED)
            OR (    ( Recinfo.DEGREE_RECEIVED = NULL )
                AND (  x_DEGREE_RECEIVED = NULL )))
       AND (    ( Recinfo.LAST_DATE_ATTENDED = x_LAST_DATE_ATTENDED)
            OR (    ( Recinfo.LAST_DATE_ATTENDED = NULL )
                AND (  x_LAST_DATE_ATTENDED = NULL )))
       AND (    ( Recinfo.SCHOOL_ATTENDED_NAME = x_SCHOOL_ATTENDED_NAME)
            OR (    ( Recinfo.SCHOOL_ATTENDED_NAME = NULL )
                AND (  x_SCHOOL_ATTENDED_NAME = NULL )))
       AND (    ( Recinfo.TYPE_OF_SCHOOL = x_TYPE_OF_SCHOOL)
            OR (    ( Recinfo.TYPE_OF_SCHOOL = NULL )
                AND (  x_TYPE_OF_SCHOOL = NULL )))
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
       AND (    ( Recinfo.WH_UPDATE_DATE = x_WH_UPDATE_DATE)
            OR (    ( Recinfo.WH_UPDATE_DATE = NULL )
                AND (  x_WH_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.START_DATE_ATTENDED = x_START_DATE_ATTENDED)
            OR (    ( Recinfo.START_DATE_ATTENDED = NULL )
                AND (  x_START_DATE_ATTENDED = NULL )))

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
    x_education_id                          IN OUT NOCOPY NUMBER,
    x_course_major                          OUT    NOCOPY VARCHAR2,
    x_party_id                              OUT    NOCOPY NUMBER,
    x_school_party_id                       OUT    NOCOPY NUMBER,
    x_degree_received                       OUT    NOCOPY VARCHAR2,
    x_last_date_attended                    OUT    NOCOPY DATE,
    x_start_date_attended                   OUT    NOCOPY DATE,
    x_school_attended_name                  OUT    NOCOPY VARCHAR2,
    x_type_of_school                        OUT    NOCOPY VARCHAR2,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
      NVL(education_id, FND_API.G_MISS_NUM),
      NVL(course_major, FND_API.G_MISS_CHAR),
      NVL(party_id, FND_API.G_MISS_NUM),
      NVL(school_party_id, FND_API.G_MISS_NUM),
      NVL(degree_received, FND_API.G_MISS_CHAR),
      NVL(last_date_attended, FND_API.G_MISS_DATE),
      NVL(start_date_attended, FND_API.G_MISS_DATE),
      NVL(school_attended_name, FND_API.G_MISS_CHAR),
      NVL(type_of_school, FND_API.G_MISS_CHAR),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM),
      NVL(created_by_module, FND_API.G_MISS_CHAR)
    INTO
      x_education_id,
      x_course_major,
      x_party_id,
      x_school_party_id,
      x_degree_received,
      x_last_date_attended,
      x_start_date_attended,
      x_school_attended_name,
      x_type_of_school,
      x_status,
      x_application_id,
      x_created_by_module
    FROM HZ_EDUCATION
    WHERE education_id = x_education_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'education_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_education_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;


END HZ_EDUCATION_PKG;

/
