--------------------------------------------------------
--  DDL for Package Body HZ_LOC_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_LOC_ASSIGNMENTS_PKG" AS
/*$Header: ARHTLATB.pls 115.4 2002/11/21 19:44:33 sponnamb ship $ */

PROCEDURE Insert_Row (
    X_LOCATION_ID                           IN     NUMBER,
    X_LOC_ID                                IN     NUMBER,
    X_ORG_ID                                IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

BEGIN

    INSERT INTO HZ_LOC_ASSIGNMENTS (
        LOCATION_ID,
        LOC_ID,
        ORG_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY_MODULE,
        APPLICATION_ID
    )
    VALUES (
        DECODE( X_LOCATION_ID, FND_API.G_MISS_NUM, NULL, X_LOCATION_ID ),
        DECODE( X_LOC_ID, FND_API.G_MISS_NUM, NULL, X_LOC_ID ),
        DECODE( X_ORG_ID, FND_API.G_MISS_NUM, NULL, X_ORG_ID ),
        HZ_UTILITY_V2PUB.CREATED_BY,
        HZ_UTILITY_V2PUB.CREATION_DATE,
        HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        HZ_UTILITY_V2PUB.REQUEST_ID,
        HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        HZ_UTILITY_V2PUB.PROGRAM_ID,
        HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
        DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
        DECODE( X_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID )
    ) ;

END Insert_Row;


PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_LOCATION_ID                           IN     NUMBER,
    X_LOC_ID                                IN     NUMBER,
    X_ORG_ID                                IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

BEGIN

    UPDATE HZ_LOC_ASSIGNMENTS SET
        LOCATION_ID = DECODE( X_LOCATION_ID, NULL, LOCATION_ID, FND_API.G_MISS_NUM, NULL, X_LOCATION_ID ),
        LOC_ID = DECODE( X_LOC_ID, NULL, LOC_ID, FND_API.G_MISS_NUM, NULL, X_LOC_ID ),
        ORG_ID = DECODE( X_ORG_ID, NULL, ORG_ID, FND_API.G_MISS_NUM, NULL, X_ORG_ID ),
        CREATED_BY = CREATED_BY,
        CREATION_DATE = CREATION_DATE,
        LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID,
        PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
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
    X_LOCATION_ID                           IN     NUMBER,
    X_LOC_ID                                IN     NUMBER,
    X_ORG_ID                                IN     NUMBER,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

    CURSOR C IS
        SELECT * FROM HZ_LOC_ASSIGNMENTS
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
        ( ( Recinfo.LOCATION_ID = X_LOCATION_ID )
        OR ( ( Recinfo.LOCATION_ID IS NULL )
            AND (  X_LOCATION_ID IS NULL ) ) )
    AND ( ( Recinfo.LOC_ID = X_LOC_ID )
        OR ( ( Recinfo.LOC_ID IS NULL )
            AND (  X_LOC_ID IS NULL ) ) )
    AND ( ( Recinfo.ORG_ID = X_ORG_ID )
        OR ( ( Recinfo.ORG_ID IS NULL )
            AND (  X_ORG_ID IS NULL ) ) )
    AND ( ( Recinfo.CREATED_BY = X_CREATED_BY )
        OR ( ( Recinfo.CREATED_BY IS NULL )
            AND (  X_CREATED_BY IS NULL ) ) )
    AND ( ( Recinfo.CREATION_DATE = X_CREATION_DATE )
        OR ( ( Recinfo.CREATION_DATE IS NULL )
            AND (  X_CREATION_DATE IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN )
        OR ( ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
            AND (  X_LAST_UPDATE_LOGIN IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE )
        OR ( ( Recinfo.LAST_UPDATE_DATE IS NULL )
            AND (  X_LAST_UPDATE_DATE IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATED_BY = X_LAST_UPDATED_BY )
        OR ( ( Recinfo.LAST_UPDATED_BY IS NULL )
            AND (  X_LAST_UPDATED_BY IS NULL ) ) )
    AND ( ( Recinfo.REQUEST_ID = X_REQUEST_ID )
        OR ( ( Recinfo.REQUEST_ID IS NULL )
            AND (  X_REQUEST_ID IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID )
        OR ( ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
            AND (  X_PROGRAM_APPLICATION_ID IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_ID = X_PROGRAM_ID )
        OR ( ( Recinfo.PROGRAM_ID IS NULL )
            AND (  X_PROGRAM_ID IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE )
        OR ( ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
            AND (  X_PROGRAM_UPDATE_DATE IS NULL ) ) )
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
    X_LOCATION_ID                           IN OUT NOCOPY NUMBER,
    X_ORG_ID                                IN OUT NOCOPY NUMBER,
    X_LOC_ID                                OUT NOCOPY    NUMBER,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
) IS

BEGIN

    SELECT
        NVL( LOCATION_ID, FND_API.G_MISS_NUM ),
        NVL( LOC_ID, FND_API.G_MISS_NUM ),
        NVL( ORG_ID, FND_API.G_MISS_NUM ),
        NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR ),
        NVL( APPLICATION_ID, FND_API.G_MISS_NUM )
    INTO
        X_LOCATION_ID,
        X_LOC_ID,
        X_ORG_ID,
        X_CREATED_BY_MODULE,
        X_APPLICATION_ID
    FROM HZ_LOC_ASSIGNMENTS
    WHERE LOCATION_ID = X_LOCATION_ID
    AND   ORG_ID = X_ORG_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'loc_assignment_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', TO_CHAR( X_LOCATION_ID ) );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    X_LOCATION_ID                           IN     NUMBER
) IS

BEGIN

    DELETE FROM HZ_LOC_ASSIGNMENTS
    WHERE LOCATION_ID = X_LOCATION_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_LOC_ASSIGNMENTS_PKG;

/
