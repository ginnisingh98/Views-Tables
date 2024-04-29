--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_SITE_USES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_SITE_USES_PKG" AS
/*$Header: ARHPSUTB.pls 115.9 2002/11/21 19:43:08 sponnamb ship $ */

PROCEDURE Insert_Row (
    X_PARTY_SITE_USE_ID                     IN OUT NOCOPY NUMBER,
    X_COMMENTS                              IN     VARCHAR2,
    X_PARTY_SITE_ID                         IN     NUMBER,
    X_SITE_USE_TYPE                         IN     VARCHAR2,
    X_PRIMARY_PER_TYPE                      IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
        INSERT INTO HZ_PARTY_SITE_USES (
            PARTY_SITE_USE_ID,
            COMMENTS,
            PARTY_SITE_ID,
            LAST_UPDATE_DATE,
            REQUEST_ID,
            LAST_UPDATED_BY,
            PROGRAM_APPLICATION_ID,
            CREATION_DATE,
            PROGRAM_ID,
            CREATED_BY,
            PROGRAM_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            SITE_USE_TYPE,
            PRIMARY_PER_TYPE,
            STATUS,
            OBJECT_VERSION_NUMBER,
            CREATED_BY_MODULE,
            APPLICATION_ID
        )
        VALUES (
            DECODE( X_PARTY_SITE_USE_ID, FND_API.G_MISS_NUM, HZ_PARTY_SITE_USES_S.NEXTVAL, NULL, HZ_PARTY_SITE_USES_S.NEXTVAL, X_PARTY_SITE_USE_ID ),
            DECODE( X_COMMENTS, FND_API.G_MISS_CHAR, NULL, X_COMMENTS ),
            DECODE( X_PARTY_SITE_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_SITE_ID ),
            HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
            HZ_UTILITY_V2PUB.REQUEST_ID,
            HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
            HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
            HZ_UTILITY_V2PUB.CREATION_DATE,
            HZ_UTILITY_V2PUB.PROGRAM_ID,
            HZ_UTILITY_V2PUB.CREATED_BY,
            HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
            HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
            DECODE( X_SITE_USE_TYPE, FND_API.G_MISS_CHAR, NULL, X_SITE_USE_TYPE ),
            DECODE( X_PRIMARY_PER_TYPE, FND_API.G_MISS_CHAR, 'N', NULL, 'N', X_PRIMARY_PER_TYPE ),
            DECODE( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
            DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
            DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
            DECODE( X_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID )
        ) RETURNING
            PARTY_SITE_USE_ID
        INTO
            X_PARTY_SITE_USE_ID;

        l_success := 'Y';

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            IF INSTRB( SQLERRM, 'HZ_PARTY_SITE_USES_U1' ) <> 0 OR
               INSTRB( SQLERRM, 'HZ_PARTY_SITE_USES_PK' ) <> 0
            THEN
            DECLARE
                l_count             NUMBER;
                l_dummy             VARCHAR2(1);
            BEGIN
                l_count := 1;
                WHILE l_count > 0 LOOP
                    SELECT HZ_PARTY_SITE_USES_S.NEXTVAL
                    INTO X_PARTY_SITE_USE_ID FROM dual;
                    BEGIN
                        SELECT 'Y' INTO l_dummy
                        FROM HZ_PARTY_SITE_USES
                        WHERE PARTY_SITE_USE_ID = X_PARTY_SITE_USE_ID;
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

PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_PARTY_SITE_USE_ID                     IN     NUMBER,
    X_COMMENTS                              IN     VARCHAR2,
    X_PARTY_SITE_ID                         IN     NUMBER,
    X_SITE_USE_TYPE                         IN     VARCHAR2,
    X_PRIMARY_PER_TYPE                      IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

BEGIN

    UPDATE HZ_PARTY_SITE_USES SET
        PARTY_SITE_USE_ID = DECODE( X_PARTY_SITE_USE_ID, NULL, PARTY_SITE_USE_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_SITE_USE_ID ),
        COMMENTS = DECODE( X_COMMENTS, NULL, COMMENTS, FND_API.G_MISS_CHAR, NULL, X_COMMENTS ),
        PARTY_SITE_ID = DECODE( X_PARTY_SITE_ID, NULL, PARTY_SITE_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_SITE_ID ),
        LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID,
        LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        CREATION_DATE = CREATION_DATE,
        PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        CREATED_BY = CREATED_BY,
        PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        SITE_USE_TYPE = DECODE( X_SITE_USE_TYPE, NULL, SITE_USE_TYPE, FND_API.G_MISS_CHAR, NULL, X_SITE_USE_TYPE ),
        PRIMARY_PER_TYPE = DECODE( X_PRIMARY_PER_TYPE, NULL, PRIMARY_PER_TYPE, FND_API.G_MISS_CHAR, 'N', X_PRIMARY_PER_TYPE ),
        STATUS = DECODE( X_STATUS, NULL, STATUS, FND_API.G_MISS_CHAR, 'A', X_STATUS ),
        OBJECT_VERSION_NUMBER = DECODE( X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
        CREATED_BY_MODULE = DECODE( X_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
        APPLICATION_ID = DECODE( X_APPLICATION_ID, NULL, APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID )
    WHERE ROWID = X_RowId;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_PARTY_SITE_USE_ID                     IN     NUMBER,
    X_COMMENTS                              IN     VARCHAR2,
    X_PARTY_SITE_ID                         IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_REQUEST_ID                            IN     NUMBER,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_PROGRAM_ID                            IN     NUMBER,
    X_CREATED_BY                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_SITE_USE_TYPE                         IN     VARCHAR2,
    X_PRIMARY_PER_TYPE                      IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

    CURSOR C IS
        SELECT * FROM HZ_PARTY_SITE_USES
        WHERE  ROWID = x_Rowid
        FOR UPDATE NOWAIT;
    Recinfo C%ROWTYPE;

BEGIN

    OPEN C;
    FETCH C INTO Recinfo;
    IF ( C%NOTFOUND ) THEN
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

    IF (
        ( ( Recinfo.PARTY_SITE_USE_ID = X_PARTY_SITE_USE_ID )
        OR ( ( Recinfo.PARTY_SITE_USE_ID IS NULL )
            AND (  X_PARTY_SITE_USE_ID IS NULL ) ) )
    AND ( ( Recinfo.COMMENTS = X_COMMENTS )
        OR ( ( Recinfo.COMMENTS IS NULL )
            AND (  X_COMMENTS IS NULL ) ) )
    AND ( ( Recinfo.PARTY_SITE_ID = X_PARTY_SITE_ID )
        OR ( ( Recinfo.PARTY_SITE_ID IS NULL )
            AND (  X_PARTY_SITE_ID IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE )
        OR ( ( Recinfo.LAST_UPDATE_DATE IS NULL )
            AND (  X_LAST_UPDATE_DATE IS NULL ) ) )
    AND ( ( Recinfo.REQUEST_ID = X_REQUEST_ID )
        OR ( ( Recinfo.REQUEST_ID IS NULL )
            AND (  X_REQUEST_ID IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATED_BY = X_LAST_UPDATED_BY )
        OR ( ( Recinfo.LAST_UPDATED_BY IS NULL )
            AND (  X_LAST_UPDATED_BY IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID )
        OR ( ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
            AND (  X_PROGRAM_APPLICATION_ID IS NULL ) ) )
    AND ( ( Recinfo.CREATION_DATE = X_CREATION_DATE )
        OR ( ( Recinfo.CREATION_DATE IS NULL )
            AND (  X_CREATION_DATE IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_ID = X_PROGRAM_ID )
        OR ( ( Recinfo.PROGRAM_ID IS NULL )
            AND (  X_PROGRAM_ID IS NULL ) ) )
    AND ( ( Recinfo.CREATED_BY = X_CREATED_BY )
        OR ( ( Recinfo.CREATED_BY IS NULL )
            AND (  X_CREATED_BY IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE )
        OR ( ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
            AND (  X_PROGRAM_UPDATE_DATE IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN )
        OR ( ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
            AND (  X_LAST_UPDATE_LOGIN IS NULL ) ) )
    AND ( ( Recinfo.SITE_USE_TYPE = X_SITE_USE_TYPE )
        OR ( ( Recinfo.SITE_USE_TYPE IS NULL )
            AND (  X_SITE_USE_TYPE IS NULL ) ) )
    AND ( ( Recinfo.PRIMARY_PER_TYPE = X_PRIMARY_PER_TYPE )
        OR ( ( Recinfo.PRIMARY_PER_TYPE IS NULL )
            AND (  X_PRIMARY_PER_TYPE IS NULL ) ) )
    AND ( ( Recinfo.STATUS = X_STATUS )
        OR ( ( Recinfo.STATUS IS NULL )
            AND (  X_STATUS IS NULL ) ) )
    AND ( ( Recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER )
        OR ( ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
            AND (  X_OBJECT_VERSION_NUMBER IS NULL ) ) )
    AND ( ( Recinfo.CREATED_BY_MODULE = X_CREATED_BY_MODULE )
        OR ( ( Recinfo.CREATED_BY_MODULE IS NULL )
            AND (  X_CREATED_BY_MODULE IS NULL ) ) )
    AND ( ( Recinfo.APPLICATION_ID = X_APPLICATION_ID )
        OR ( ( Recinfo.APPLICATION_ID IS NULL )
            AND (  X_APPLICATION_ID IS NULL ) ) )
    ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    X_PARTY_SITE_USE_ID                     IN OUT NOCOPY NUMBER,
    X_COMMENTS                              OUT NOCOPY    VARCHAR2,
    X_PARTY_SITE_ID                         OUT NOCOPY    NUMBER,
    X_SITE_USE_TYPE                         OUT NOCOPY    VARCHAR2,
    X_PRIMARY_PER_TYPE                      OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
) IS

BEGIN

    SELECT
        NVL( PARTY_SITE_USE_ID, FND_API.G_MISS_NUM ),
        NVL( COMMENTS, FND_API.G_MISS_CHAR ),
        NVL( PARTY_SITE_ID, FND_API.G_MISS_NUM ),
        NVL( SITE_USE_TYPE, FND_API.G_MISS_CHAR ),
        NVL( PRIMARY_PER_TYPE, FND_API.G_MISS_CHAR ),
        NVL( STATUS, FND_API.G_MISS_CHAR ),
        NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR ),
        NVL( APPLICATION_ID, FND_API.G_MISS_NUM )
    INTO
        X_PARTY_SITE_USE_ID,
        X_COMMENTS,
        X_PARTY_SITE_ID,
        X_SITE_USE_TYPE,
        X_PRIMARY_PER_TYPE,
        X_STATUS,
        X_CREATED_BY_MODULE,
        X_APPLICATION_ID
    FROM HZ_PARTY_SITE_USES
    WHERE PARTY_SITE_USE_ID = X_PARTY_SITE_USE_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'party_site_use_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', TO_CHAR( X_PARTY_SITE_USE_ID ) );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    X_PARTY_SITE_USE_ID                     IN     NUMBER
) IS

BEGIN

    DELETE FROM HZ_PARTY_SITE_USES
    WHERE PARTY_SITE_USE_ID = X_PARTY_SITE_USE_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_PARTY_SITE_USES_PKG;

/
