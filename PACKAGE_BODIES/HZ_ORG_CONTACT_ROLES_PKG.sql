--------------------------------------------------------
--  DDL for Package Body HZ_ORG_CONTACT_ROLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORG_CONTACT_ROLES_PKG" AS
/*$Header: ARHOCRTB.pls 115.9 2002/11/21 19:40:41 sponnamb ship $ */

PROCEDURE Insert_Row (
    X_ORG_CONTACT_ROLE_ID                   IN OUT NOCOPY NUMBER,
    X_ORG_CONTACT_ID                        IN     NUMBER,
    X_ROLE_TYPE                             IN     VARCHAR2,
    X_ROLE_LEVEL                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_PRIMARY_CON_PER_ROLE_TYPE             IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
        INSERT INTO HZ_ORG_CONTACT_ROLES (
            ORG_CONTACT_ROLE_ID,
            ORG_CONTACT_ID,
            ROLE_TYPE,
            CREATED_BY,
            ROLE_LEVEL,
            PRIMARY_FLAG,
            CREATION_DATE,
            ORIG_SYSTEM_REFERENCE,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            PRIMARY_CONTACT_PER_ROLE_TYPE,
            STATUS,
            OBJECT_VERSION_NUMBER,
            CREATED_BY_MODULE,
            APPLICATION_ID
        )
        VALUES (
            DECODE( X_ORG_CONTACT_ROLE_ID, FND_API.G_MISS_NUM, HZ_ORG_CONTACT_ROLES_S.NEXTVAL, NULL, HZ_ORG_CONTACT_ROLES_S.NEXTVAL, X_ORG_CONTACT_ROLE_ID ),
            DECODE( X_ORG_CONTACT_ID, FND_API.G_MISS_NUM, NULL, X_ORG_CONTACT_ID ),
            DECODE( X_ROLE_TYPE, FND_API.G_MISS_CHAR, NULL, X_ROLE_TYPE ),
            HZ_UTILITY_V2PUB.CREATED_BY,
            DECODE( X_ROLE_LEVEL, FND_API.G_MISS_CHAR, 'N', NULL, 'N', X_ROLE_LEVEL ),
            DECODE( X_PRIMARY_FLAG, FND_API.G_MISS_CHAR, 'N', NULL, 'N', X_PRIMARY_FLAG ),
            HZ_UTILITY_V2PUB.CREATION_DATE,
            DECODE( X_ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR, TO_CHAR(NVL(X_ORG_CONTACT_ROLE_ID,HZ_ORG_CONTACT_ROLES_S.CURRVAL)), NULL, TO_CHAR(NVL(X_ORG_CONTACT_ROLE_ID,HZ_ORG_CONTACT_ROLES_S.CURRVAL)), X_ORIG_SYSTEM_REFERENCE ),
            HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
            HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
            HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
            HZ_UTILITY_V2PUB.REQUEST_ID,
            HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
            HZ_UTILITY_V2PUB.PROGRAM_ID,
            HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
            DECODE( X_PRIMARY_CON_PER_ROLE_TYPE, FND_API.G_MISS_CHAR, 'N', NULL, 'N', X_PRIMARY_CON_PER_ROLE_TYPE ),
            DECODE( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
            DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
            DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
            DECODE( X_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID )
        ) RETURNING
            ORG_CONTACT_ROLE_ID
        INTO
            X_ORG_CONTACT_ROLE_ID;

        l_success := 'Y';

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            IF INSTRB( SQLERRM, 'HZ_ORG_CONTACT_ROLES_U1' ) <> 0 OR
               INSTRB( SQLERRM, 'HZ_ORG_CONTACT_ROLES_PK' ) <> 0
            THEN
            DECLARE
                l_count             NUMBER;
                l_dummy             VARCHAR2(1);
            BEGIN
                l_count := 1;
                WHILE l_count > 0 LOOP
                    SELECT HZ_ORG_CONTACT_ROLES_S.NEXTVAL
                    INTO X_ORG_CONTACT_ROLE_ID FROM dual;
                    BEGIN
                        SELECT 'Y' INTO l_dummy
                        FROM HZ_ORG_CONTACT_ROLES
                        WHERE ORG_CONTACT_ROLE_ID = X_ORG_CONTACT_ROLE_ID;
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
    X_ORG_CONTACT_ROLE_ID                   IN     NUMBER,
    X_ORG_CONTACT_ID                        IN     NUMBER,
    X_ROLE_TYPE                             IN     VARCHAR2,
    X_ROLE_LEVEL                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_PRIMARY_CON_PER_ROLE_TYPE             IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

BEGIN

    UPDATE HZ_ORG_CONTACT_ROLES SET
        ORG_CONTACT_ROLE_ID = DECODE( X_ORG_CONTACT_ROLE_ID, NULL, ORG_CONTACT_ROLE_ID, FND_API.G_MISS_NUM, NULL, X_ORG_CONTACT_ROLE_ID ),
        ORG_CONTACT_ID = DECODE( X_ORG_CONTACT_ID, NULL, ORG_CONTACT_ID, FND_API.G_MISS_NUM, NULL, X_ORG_CONTACT_ID ),
        ROLE_TYPE = DECODE( X_ROLE_TYPE, NULL, ROLE_TYPE, FND_API.G_MISS_CHAR, NULL, X_ROLE_TYPE ),
        CREATED_BY = CREATED_BY,
        ROLE_LEVEL = DECODE( X_ROLE_LEVEL, NULL, ROLE_LEVEL, FND_API.G_MISS_CHAR, 'N', X_ROLE_LEVEL ),
        PRIMARY_FLAG = DECODE( X_PRIMARY_FLAG, NULL, PRIMARY_FLAG, FND_API.G_MISS_CHAR, 'N', X_PRIMARY_FLAG ),
        CREATION_DATE = CREATION_DATE,
        ORIG_SYSTEM_REFERENCE = DECODE( X_ORIG_SYSTEM_REFERENCE, NULL, ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR, ORIG_SYSTEM_REFERENCE, X_ORIG_SYSTEM_REFERENCE ),
        LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID,
        PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        PRIMARY_CONTACT_PER_ROLE_TYPE = DECODE( X_PRIMARY_CON_PER_ROLE_TYPE, NULL, PRIMARY_CONTACT_PER_ROLE_TYPE, FND_API.G_MISS_CHAR, 'N', X_PRIMARY_CON_PER_ROLE_TYPE ),
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
    X_ORG_CONTACT_ROLE_ID                   IN     NUMBER,
    X_ORG_CONTACT_ID                        IN     NUMBER,
    X_ROLE_TYPE                             IN     VARCHAR2,
    X_CREATED_BY                            IN     NUMBER,
    X_ROLE_LEVEL                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_CREATION_DATE                         IN     DATE,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_PRIMARY_CON_PER_ROLE_TYPE             IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

    CURSOR C IS
        SELECT * FROM HZ_ORG_CONTACT_ROLES
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
        ( ( Recinfo.ORG_CONTACT_ROLE_ID = X_ORG_CONTACT_ROLE_ID )
        OR ( ( Recinfo.ORG_CONTACT_ROLE_ID IS NULL )
            AND (  X_ORG_CONTACT_ROLE_ID IS NULL ) ) )
    AND ( ( Recinfo.ORG_CONTACT_ID = X_ORG_CONTACT_ID )
        OR ( ( Recinfo.ORG_CONTACT_ID IS NULL )
            AND (  X_ORG_CONTACT_ID IS NULL ) ) )
    AND ( ( Recinfo.ROLE_TYPE = X_ROLE_TYPE )
        OR ( ( Recinfo.ROLE_TYPE IS NULL )
            AND (  X_ROLE_TYPE IS NULL ) ) )
    AND ( ( Recinfo.CREATED_BY = X_CREATED_BY )
        OR ( ( Recinfo.CREATED_BY IS NULL )
            AND (  X_CREATED_BY IS NULL ) ) )
    AND ( ( Recinfo.ROLE_LEVEL = X_ROLE_LEVEL )
        OR ( ( Recinfo.ROLE_LEVEL IS NULL )
            AND (  X_ROLE_LEVEL IS NULL ) ) )
    AND ( ( Recinfo.PRIMARY_FLAG = X_PRIMARY_FLAG )
        OR ( ( Recinfo.PRIMARY_FLAG IS NULL )
            AND (  X_PRIMARY_FLAG IS NULL ) ) )
    AND ( ( Recinfo.CREATION_DATE = X_CREATION_DATE )
        OR ( ( Recinfo.CREATION_DATE IS NULL )
            AND (  X_CREATION_DATE IS NULL ) ) )
    AND ( ( Recinfo.ORIG_SYSTEM_REFERENCE = X_ORIG_SYSTEM_REFERENCE )
        OR ( ( Recinfo.ORIG_SYSTEM_REFERENCE IS NULL )
            AND (  X_ORIG_SYSTEM_REFERENCE IS NULL ) ) )
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
    AND ( ( Recinfo.PRIMARY_CONTACT_PER_ROLE_TYPE = X_PRIMARY_CON_PER_ROLE_TYPE )
        OR ( ( Recinfo.PRIMARY_CONTACT_PER_ROLE_TYPE IS NULL )
            AND (  X_PRIMARY_CON_PER_ROLE_TYPE IS NULL ) ) )
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
    X_ORG_CONTACT_ROLE_ID                   IN OUT NOCOPY NUMBER,
    X_ORG_CONTACT_ID                        OUT NOCOPY    NUMBER,
    X_ROLE_TYPE                             OUT NOCOPY    VARCHAR2,
    X_ROLE_LEVEL                            OUT NOCOPY    VARCHAR2,
    X_PRIMARY_FLAG                          OUT NOCOPY    VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 OUT NOCOPY    VARCHAR2,
    X_PRIMARY_CON_PER_ROLE_TYPE             OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
) IS

BEGIN

    SELECT
        NVL( ORG_CONTACT_ROLE_ID, FND_API.G_MISS_NUM ),
        NVL( ORG_CONTACT_ID, FND_API.G_MISS_NUM ),
        NVL( ROLE_TYPE, FND_API.G_MISS_CHAR ),
        NVL( ROLE_LEVEL, FND_API.G_MISS_CHAR ),
        NVL( PRIMARY_FLAG, FND_API.G_MISS_CHAR ),
        NVL( ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR ),
        NVL( PRIMARY_CONTACT_PER_ROLE_TYPE, FND_API.G_MISS_CHAR ),
        NVL( STATUS, FND_API.G_MISS_CHAR ),
        NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR ),
        NVL( APPLICATION_ID, FND_API.G_MISS_NUM )
    INTO
        X_ORG_CONTACT_ROLE_ID,
        X_ORG_CONTACT_ID,
        X_ROLE_TYPE,
        X_ROLE_LEVEL,
        X_PRIMARY_FLAG,
        X_ORIG_SYSTEM_REFERENCE,
        X_PRIMARY_CON_PER_ROLE_TYPE,
        X_STATUS,
        X_CREATED_BY_MODULE,
        X_APPLICATION_ID
    FROM HZ_ORG_CONTACT_ROLES
    WHERE ORG_CONTACT_ROLE_ID = X_ORG_CONTACT_ROLE_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'org_contact_role_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', TO_CHAR( X_ORG_CONTACT_ROLE_ID ) );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    X_ORG_CONTACT_ROLE_ID                   IN     NUMBER
) IS

BEGIN

    DELETE FROM HZ_ORG_CONTACT_ROLES
    WHERE ORG_CONTACT_ROLE_ID = X_ORG_CONTACT_ROLE_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_ORG_CONTACT_ROLES_PKG;

/
