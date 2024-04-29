--------------------------------------------------------
--  DDL for Package Body HZ_CITIZENSHIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CITIZENSHIP_PKG" as
/* $Header: ARHPCITB.pls 120.5 2005/10/30 04:21:28 appldev ship $ */



PROCEDURE Insert_Row(
                  x_CITIZENSHIP_ID    IN  OUT NOCOPY     NUMBER,
                  x_BIRTH_OR_SELECTED           IN       VARCHAR2,
                  x_PARTY_ID                    IN       NUMBER,
                  x_COUNTRY_CODE                IN       VARCHAR2,
                  x_DATE_DISOWNED               IN       DATE,
                  x_DATE_RECOGNIZED             IN       DATE,
                  x_DOCUMENT_REFERENCE          IN       VARCHAR2,
                  x_DOCUMENT_TYPE               IN       VARCHAR2,
                  x_END_DATE                    IN       DATE,
                  x_STATUS                      IN       VARCHAR2,
                  x_OBJECT_VERSION_NUMBER       IN       NUMBER,
                  x_CREATED_BY_MODULE           IN       VARCHAR2,
                  x_APPLICATION_ID              IN       NUMBER

     ) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

   WHILE l_success = 'N' LOOP

   BEGIN

   INSERT INTO HZ_CITIZENSHIP(
           CITIZENSHIP_ID,
           BIRTH_OR_SELECTED,
           PARTY_ID,
           COUNTRY_CODE,
           DATE_DISOWNED,
           DATE_RECOGNIZED,
           DOCUMENT_REFERENCE,
           DOCUMENT_TYPE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           END_DATE,
           STATUS,
           OBJECT_VERSION_NUMBER,
           CREATED_BY_MODULE,
           APPLICATION_ID
          ) VALUES (
           decode( X_CITIZENSHIP_ID, FND_API.G_MISS_NUM, HZ_CITIZENSHIP_S.NEXTVAL, NULL, HZ_CITIZENSHIP_S.NEXTVAL, X_CITIZENSHIP_ID ),
           decode( x_BIRTH_OR_SELECTED, FND_API.G_MISS_CHAR, NULL,x_BIRTH_OR_SELECTED),
           decode( x_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_PARTY_ID),
           decode( x_COUNTRY_CODE, FND_API.G_MISS_CHAR, NULL,x_COUNTRY_CODE),
           decode( x_DATE_DISOWNED, FND_API.G_MISS_DATE, TO_DATE(NULL),x_DATE_DISOWNED),
           decode( x_DATE_RECOGNIZED, FND_API.G_MISS_DATE, TO_DATE(NULL),x_DATE_RECOGNIZED),
           decode( x_DOCUMENT_REFERENCE, FND_API.G_MISS_CHAR, NULL,x_DOCUMENT_REFERENCE),
           decode( x_DOCUMENT_TYPE, FND_API.G_MISS_CHAR, NULL,x_DOCUMENT_TYPE),
           HZ_UTILITY_V2PUB.CREATED_BY,
           HZ_UTILITY_V2PUB.CREATION_DATE,
           HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
           HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
           HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
           HZ_UTILITY_V2PUB.REQUEST_ID,
           HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
           HZ_UTILITY_V2PUB.PROGRAM_ID,
           HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
           decode( x_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_END_DATE),
           DECODE( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
           DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
           DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
           HZ_UTILITY_V2PUB.APPLICATION_ID
           )
          RETURNING
	              CITIZENSHIP_ID
	          INTO
	              X_CITIZENSHIP_ID;

	          l_success := 'Y';

	      EXCEPTION
	          WHEN DUP_VAL_ON_INDEX THEN
	              IF INSTRB( SQLERRM, 'HZ_CITIZENSHIP_U1' ) <> 0 OR
	                 INSTRB( SQLERRM, 'HZ_CITIZENSHIP_PK' ) <> 0
	              THEN
	              DECLARE
	                  l_count             NUMBER;
	                  l_dummy             VARCHAR2(1);
	              BEGIN
	                  l_count := 1;
	                  WHILE l_count > 0 LOOP
	                      SELECT HZ_CITIZENSHIP_S.NEXTVAL
	                      INTO X_CITIZENSHIP_ID FROM dual;
	                      BEGIN
	                          SELECT 'Y' INTO l_dummy
	                          FROM HZ_CITIZENSHIP
	                          WHERE CITIZENSHIP_ID = CITIZENSHIP_ID;
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


PROCEDURE Delete_Row(                  x_CITIZENSHIP_ID                NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_CITIZENSHIP
    WHERE CITIZENSHIP_ID = x_CITIZENSHIP_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;


PROCEDURE Update_Row(

                  x_Rowid              IN  OUT NOCOPY     VARCHAR2,
                  x_CITIZENSHIP_ID     IN  OUT NOCOPY     NUMBER,
                  x_BIRTH_OR_SELECTED         IN          VARCHAR2,
                  x_PARTY_ID                  IN          NUMBER,
                  x_COUNTRY_CODE              IN          VARCHAR2,
                  x_DATE_DISOWNED             IN          DATE,
                  x_DATE_RECOGNIZED           IN          DATE,
                  x_DOCUMENT_REFERENCE        IN          VARCHAR2,
                  x_DOCUMENT_TYPE             IN          VARCHAR2,
                  x_END_DATE                  IN          DATE,
                  x_STATUS                    IN          VARCHAR2,
		  x_OBJECT_VERSION_NUMBER     IN          NUMBER,
                  x_CREATED_BY_MODULE         IN          VARCHAR2,
                  x_APPLICATION_ID            IN     NUMBER

 ) IS
 BEGIN
    Update HZ_CITIZENSHIP
    SET

             CITIZENSHIP_ID = decode( x_CITIZENSHIP_ID, NULL, CITIZENSHIP_ID, FND_API.G_MISS_NUM, NULL, X_CITIZENSHIP_ID ),
             BIRTH_OR_SELECTED = decode( x_BIRTH_OR_SELECTED, NULL, BIRTH_OR_SELECTED, FND_API.G_MISS_CHAR, NULL, x_BIRTH_OR_SELECTED ),
             PARTY_ID = DECODE( X_PARTY_ID, NULL, PARTY_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_ID ),
             COUNTRY_CODE = DECODE( x_COUNTRY_CODE, NULL, COUNTRY_CODE, FND_API.G_MISS_CHAR, NULL, x_COUNTRY_CODE ),
             DATE_DISOWNED = decode( x_DATE_DISOWNED, NULL, DATE_DISOWNED, FND_API.G_MISS_DATE,NULL ,x_DATE_DISOWNED),
             DATE_RECOGNIZED = decode( x_DATE_RECOGNIZED, NULL, DATE_RECOGNIZED, FND_API.G_MISS_DATE, NULL, x_DATE_RECOGNIZED),
             DOCUMENT_REFERENCE = decode( x_DOCUMENT_REFERENCE, NULL, DOCUMENT_REFERENCE, FND_API.G_MISS_CHAR,NULL,x_DOCUMENT_REFERENCE),
             DOCUMENT_TYPE = decode( x_DOCUMENT_TYPE, NULL, DOCUMENT_TYPE, FND_API.G_MISS_CHAR,NULL, x_DOCUMENT_TYPE),
             -- Bug 3032780
             -- CREATED_BY = HZ_UTILITY_V2PUB.CREATED_BY,
             -- CREATION_DATE = HZ_UTILITY_V2PUB.CREATION_DATE,
             LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
             LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
             REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID,
             PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
             PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
             PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
             END_DATE = decode( x_END_DATE, NULL, END_DATE, FND_API.G_MISS_DATE, NULL, x_END_DATE),
             STATUS=decode(x_STATUS, NULL, STATUS, FND_API.G_MISS_CHAR, NULL,x_STATUS),
             OBJECT_VERSION_NUMBER = DECODE( X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
             CREATED_BY_MODULE = DECODE( X_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
             APPLICATION_ID=HZ_UTILITY_V2PUB.APPLICATION_ID

    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                     IN          VARCHAR2,
                  x_CITIZENSHIP_ID            IN          NUMBER,
                  x_BIRTH_OR_SELECTED         IN          VARCHAR2,
                  x_PARTY_ID                  IN          NUMBER,
                  x_COUNTRY_CODE              IN          VARCHAR2,
                  x_DATE_DISOWNED             IN          DATE,
                  x_DATE_RECOGNIZED           IN          DATE,
                  x_DOCUMENT_REFERENCE        IN          VARCHAR2,
                  x_DOCUMENT_TYPE             IN          VARCHAR2,
                  x_CREATED_BY                IN          NUMBER,
                  x_CREATION_DATE             IN          DATE,
                  x_LAST_UPDATE_LOGIN         IN          NUMBER,
                  x_LAST_UPDATE_DATE          IN          DATE,
                  x_LAST_UPDATED_BY           IN          NUMBER,
                  x_REQUEST_ID                IN          NUMBER,
                  x_PROGRAM_APPLICATION_ID    IN          NUMBER,
                  x_PROGRAM_ID                IN          NUMBER,
                  x_PROGRAM_UPDATE_DATE       IN          DATE,
                  x_WH_UPDATE_DATE            IN          DATE,
                  x_END_DATE                  IN          DATE,
                  x_STATUS                    IN          VARCHAR2
                  ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_CITIZENSHIP
         WHERE rowid = x_Rowid
         FOR UPDATE of CITIZENSHIP_ID NOWAIT;
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
           (    ( Recinfo.CITIZENSHIP_ID = x_CITIZENSHIP_ID)
            OR (    ( Recinfo.CITIZENSHIP_ID = NULL )
                AND (  x_CITIZENSHIP_ID = NULL )))
       AND (    ( Recinfo.BIRTH_OR_SELECTED = x_BIRTH_OR_SELECTED)
            OR (    ( Recinfo.BIRTH_OR_SELECTED = NULL )
                AND (  x_BIRTH_OR_SELECTED = NULL )))
       AND (    ( Recinfo.PARTY_ID = x_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID = NULL )
                AND (  x_PARTY_ID = NULL )))
       AND (    ( Recinfo.COUNTRY_CODE = x_COUNTRY_CODE)
            OR (    ( Recinfo.COUNTRY_CODE = NULL )
                AND (  x_COUNTRY_CODE = NULL )))
       AND (    ( Recinfo.DATE_DISOWNED = x_DATE_DISOWNED)
            OR (    ( Recinfo.DATE_DISOWNED = NULL )
                AND (  x_DATE_DISOWNED = NULL )))
       AND (    ( Recinfo.DATE_RECOGNIZED = x_DATE_RECOGNIZED)
            OR (    ( Recinfo.DATE_RECOGNIZED = NULL )
                AND (  x_DATE_RECOGNIZED = NULL )))
       AND (    ( Recinfo.DOCUMENT_REFERENCE = x_DOCUMENT_REFERENCE)
            OR (    ( Recinfo.DOCUMENT_REFERENCE = NULL )
                AND (  x_DOCUMENT_REFERENCE = NULL )))
       AND (    ( Recinfo.DOCUMENT_TYPE = x_DOCUMENT_TYPE)
            OR (    ( Recinfo.DOCUMENT_TYPE = NULL )
                AND (  x_DOCUMENT_TYPE = NULL )))
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
       AND (    ( Recinfo.END_DATE = x_END_DATE)
            OR (    ( Recinfo.END_DATE = NULL )
                AND (  x_END_DATE = NULL )))

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
    x_citizenship_id                        IN OUT NOCOPY NUMBER,
    x_birth_or_selected                     OUT    NOCOPY VARCHAR2,
    x_party_id                              OUT    NOCOPY NUMBER,
    x_country_code                          OUT    NOCOPY VARCHAR2,
    x_date_disowned                         OUT    NOCOPY DATE,
    x_date_recognized                       OUT    NOCOPY DATE,
    x_document_reference                    OUT    NOCOPY VARCHAR2,
    x_end_date                              OUT    NOCOPY DATE,
    x_document_type                         OUT    NOCOPY VARCHAR2,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
      NVL(citizenship_id, FND_API.G_MISS_NUM),
      NVL(birth_or_selected, FND_API.G_MISS_CHAR),
      NVL(party_id, FND_API.G_MISS_NUM),
      NVL(country_code, FND_API.G_MISS_CHAR),
      NVL(date_disowned, FND_API.G_MISS_DATE),
      NVL(date_recognized, FND_API.G_MISS_DATE),
      NVL(document_reference, FND_API.G_MISS_CHAR),
      NVL(end_date, FND_API.G_MISS_DATE),
      NVL(document_type, FND_API.G_MISS_CHAR),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM),
      NVL(created_by_module, FND_API.G_MISS_CHAR)
    INTO
      x_citizenship_id,
      x_birth_or_selected,
      x_party_id,
      x_country_code,
      x_date_disowned,
      x_date_recognized,
      x_document_reference,
      x_end_date,
      x_document_type,
      x_status,
      x_application_id,
      x_created_by_module
    FROM HZ_CITIZENSHIP
    WHERE citizenship_id = x_citizenship_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'citizenship_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_citizenship_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

END HZ_CITIZENSHIP_PKG;

/
