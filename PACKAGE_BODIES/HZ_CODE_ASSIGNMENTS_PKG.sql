--------------------------------------------------------
--  DDL for Package Body HZ_CODE_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CODE_ASSIGNMENTS_PKG" AS
/*$Header: ARHCASTB.pls 120.8 2005/11/28 07:22:12 dmmehta ship $ */

-- SSM SST Integration and Extension
G_MISS_CONTENT_SOURCE_TYPE             CONSTANT VARCHAR2(30) := 'USER_ENTERED';

PROCEDURE Insert_Row (
    X_CODE_ASSIGNMENT_ID                    IN OUT NOCOPY NUMBER,
    X_OWNER_TABLE_NAME                      IN     VARCHAR2,
    X_OWNER_TABLE_ID                        IN     NUMBER,
    X_OWNER_TABLE_KEY_1                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_2                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_3                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_4                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_5                     IN     VARCHAR2,
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_CLASS_CODE                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_CONTENT_SOURCE_TYPE                   IN     VARCHAR2,
    X_START_DATE_ACTIVE                     IN     DATE,
    X_END_DATE_ACTIVE                       IN     DATE,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_RANK                                  IN     NUMBER,
    X_APPLICATION_ID                        IN     NUMBER,
    -- SSM SST Integration and Extension
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
        INSERT INTO HZ_CODE_ASSIGNMENTS (
            CODE_ASSIGNMENT_ID,
            OWNER_TABLE_NAME,
            OWNER_TABLE_ID,
            OWNER_TABLE_KEY_1,
            OWNER_TABLE_KEY_2,
            OWNER_TABLE_KEY_3,
            OWNER_TABLE_KEY_4,
            OWNER_TABLE_KEY_5,
            CLASS_CATEGORY,
            CLASS_CODE,
            PRIMARY_FLAG,
            CONTENT_SOURCE_TYPE,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            STATUS,
            OBJECT_VERSION_NUMBER,
            CREATED_BY_MODULE,
            RANK,
            APPLICATION_ID,
	    ACTUAL_CONTENT_SOURCE
        )
        VALUES (
            DECODE( X_CODE_ASSIGNMENT_ID, FND_API.G_MISS_NUM, HZ_CODE_ASSIGNMENTS_S.NEXTVAL, NULL, HZ_CODE_ASSIGNMENTS_S.NEXTVAL, X_CODE_ASSIGNMENT_ID ),
            DECODE( X_OWNER_TABLE_NAME, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_NAME ),
            DECODE( X_OWNER_TABLE_ID, FND_API.G_MISS_NUM, NULL, X_OWNER_TABLE_ID ),
            DECODE( X_OWNER_TABLE_KEY_1, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_KEY_1 ),
            DECODE( X_OWNER_TABLE_KEY_2, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_KEY_2 ),
            DECODE( X_OWNER_TABLE_KEY_3, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_KEY_3 ),
            DECODE( X_OWNER_TABLE_KEY_4, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_KEY_4 ),
            DECODE( X_OWNER_TABLE_KEY_5, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_KEY_5 ),
            DECODE( X_CLASS_CATEGORY, FND_API.G_MISS_CHAR, NULL, X_CLASS_CATEGORY ),
            DECODE( X_CLASS_CODE, FND_API.G_MISS_CHAR, NULL, X_CLASS_CODE ),
            DECODE( X_PRIMARY_FLAG, FND_API.G_MISS_CHAR, NULL, X_PRIMARY_FLAG ),
            DECODE( X_CONTENT_SOURCE_TYPE, FND_API.G_MISS_CHAR, HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE, NULL, HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE, X_CONTENT_SOURCE_TYPE ),
            DECODE( X_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE( NULL ), X_START_DATE_ACTIVE ),
            DECODE( X_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE( NULL ), X_END_DATE_ACTIVE ),
            HZ_UTILITY_V2PUB.CREATED_BY,
            HZ_UTILITY_V2PUB.CREATION_DATE,
            HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
            HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
            HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
            DECODE( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
            DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
            DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
            DECODE( X_RANK, FND_API.G_MISS_NUM, NULL, X_RANK ),
            DECODE( X_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID ),
	    DECODE( X_ACTUAL_CONTENT_SOURCE, FND_API.G_MISS_CHAR, G_MISS_CONTENT_SOURCE_TYPE,
	                                     NULL, G_MISS_CONTENT_SOURCE_TYPE,
	                                     X_ACTUAL_CONTENT_SOURCE)
        ) RETURNING
            CODE_ASSIGNMENT_ID
        INTO
            X_CODE_ASSIGNMENT_ID;

        l_success := 'Y';

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            IF INSTRB( SQLERRM, 'HZ_CODE_ASSIGNMENTS_U1' ) <> 0 OR
               INSTRB( SQLERRM, 'HZ_CODE_ASSIGNMENTS_PK' ) <> 0
            THEN
            DECLARE
                l_count             NUMBER;
                l_dummy             VARCHAR2(1);
            BEGIN
                l_count := 1;
                WHILE l_count > 0 LOOP
                    SELECT HZ_CODE_ASSIGNMENTS_S.NEXTVAL
                    INTO X_CODE_ASSIGNMENT_ID FROM dual;
                    BEGIN
                        SELECT 'Y' INTO l_dummy
                        FROM HZ_CODE_ASSIGNMENTS
                        WHERE CODE_ASSIGNMENT_ID = X_CODE_ASSIGNMENT_ID;
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
    X_CODE_ASSIGNMENT_ID                    IN     NUMBER,
    X_OWNER_TABLE_NAME                      IN     VARCHAR2,
    X_OWNER_TABLE_ID                        IN     NUMBER,
    X_OWNER_TABLE_KEY_1                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_2                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_3                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_4                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_5                     IN     VARCHAR2,
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_CLASS_CODE                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_CONTENT_SOURCE_TYPE                   IN     VARCHAR2,
    X_START_DATE_ACTIVE                     IN     DATE,
    X_END_DATE_ACTIVE                       IN     DATE,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_RANK                                  IN     NUMBER,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2
) IS

BEGIN

    UPDATE HZ_CODE_ASSIGNMENTS SET
        CODE_ASSIGNMENT_ID = DECODE( X_CODE_ASSIGNMENT_ID, NULL, CODE_ASSIGNMENT_ID, FND_API.G_MISS_NUM, NULL, X_CODE_ASSIGNMENT_ID ),
        OWNER_TABLE_NAME = DECODE( X_OWNER_TABLE_NAME, NULL, OWNER_TABLE_NAME, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_NAME ),
        OWNER_TABLE_ID = DECODE( X_OWNER_TABLE_ID, NULL, OWNER_TABLE_ID, FND_API.G_MISS_NUM, NULL, X_OWNER_TABLE_ID ),
        OWNER_TABLE_KEY_1 = DECODE( X_OWNER_TABLE_KEY_1, NULL, OWNER_TABLE_KEY_1, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_KEY_1 ),
        OWNER_TABLE_KEY_2 = DECODE( X_OWNER_TABLE_KEY_2, NULL, OWNER_TABLE_KEY_2, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_KEY_2 ),
        OWNER_TABLE_KEY_3 = DECODE( X_OWNER_TABLE_KEY_3, NULL, OWNER_TABLE_KEY_3, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_KEY_3 ),
        OWNER_TABLE_KEY_4 = DECODE( X_OWNER_TABLE_KEY_4, NULL, OWNER_TABLE_KEY_4, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_KEY_4 ),
        OWNER_TABLE_KEY_5 = DECODE( X_OWNER_TABLE_KEY_5, NULL, OWNER_TABLE_KEY_5, FND_API.G_MISS_CHAR, NULL, X_OWNER_TABLE_KEY_5 ),
        CLASS_CATEGORY = DECODE( X_CLASS_CATEGORY, NULL, CLASS_CATEGORY, FND_API.G_MISS_CHAR, NULL, X_CLASS_CATEGORY ),
        CLASS_CODE = DECODE( X_CLASS_CODE, NULL, CLASS_CODE, FND_API.G_MISS_CHAR, NULL, X_CLASS_CODE ),
        PRIMARY_FLAG = DECODE( X_PRIMARY_FLAG, NULL, PRIMARY_FLAG, FND_API.G_MISS_CHAR, NULL, X_PRIMARY_FLAG ),
        CONTENT_SOURCE_TYPE = DECODE( X_CONTENT_SOURCE_TYPE, NULL, CONTENT_SOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, X_CONTENT_SOURCE_TYPE ),
        START_DATE_ACTIVE = DECODE( X_START_DATE_ACTIVE, NULL, START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, X_START_DATE_ACTIVE ),
        END_DATE_ACTIVE = DECODE( X_END_DATE_ACTIVE, NULL, END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, X_END_DATE_ACTIVE ),
        CREATED_BY = CREATED_BY,
        CREATION_DATE = CREATION_DATE,
        LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        STATUS = DECODE( X_STATUS, NULL, STATUS, FND_API.G_MISS_CHAR, NULL, X_STATUS ),
        OBJECT_VERSION_NUMBER = DECODE( X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
        CREATED_BY_MODULE = DECODE( X_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
        RANK = DECODE( X_RANK, NULL, RANK, FND_API.G_MISS_NUM, NULL, X_RANK ),
        APPLICATION_ID = DECODE( X_APPLICATION_ID, NULL, APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID ),
--  Bug 4693719 : Allow update to ACS
	ACTUAL_CONTENT_SOURCE = DECODE ( X_ACTUAL_CONTENT_SOURCE, FND_API.G_MISS_CHAR, G_MISS_CONTENT_SOURCE_TYPE,
	                                                          NULL, ACTUAL_CONTENT_SOURCE,
								  X_ACTUAL_CONTENT_SOURCE)
    WHERE ROWID = X_RowId;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_CODE_ASSIGNMENT_ID                    IN     NUMBER,
    X_OWNER_TABLE_NAME                      IN     VARCHAR2,
    X_OWNER_TABLE_ID                        IN     NUMBER,
    X_OWNER_TABLE_KEY_1                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_2                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_3                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_4                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_5                     IN     VARCHAR2,
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_CLASS_CODE                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_CONTENT_SOURCE_TYPE                   IN     VARCHAR2,
    X_START_DATE_ACTIVE                     IN     DATE,
    X_END_DATE_ACTIVE                       IN     DATE,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_RANK                                  IN     NUMBER,
    X_APPLICATION_ID                        IN     NUMBER,
    -- SSM SST Integration and Extension
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2
) IS

    CURSOR C IS
        SELECT * FROM HZ_CODE_ASSIGNMENTS
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
        ( ( Recinfo.CODE_ASSIGNMENT_ID = X_CODE_ASSIGNMENT_ID )
        OR ( ( Recinfo.CODE_ASSIGNMENT_ID IS NULL )
            AND (  X_CODE_ASSIGNMENT_ID IS NULL ) ) )
    AND ( ( Recinfo.OWNER_TABLE_NAME = X_OWNER_TABLE_NAME )
        OR ( ( Recinfo.OWNER_TABLE_NAME IS NULL )
            AND (  X_OWNER_TABLE_NAME IS NULL ) ) )
    AND ( ( Recinfo.OWNER_TABLE_ID = X_OWNER_TABLE_ID )
        OR ( ( Recinfo.OWNER_TABLE_ID IS NULL )
            AND (  X_OWNER_TABLE_ID IS NULL ) ) )
    AND ( ( Recinfo.OWNER_TABLE_KEY_1 = X_OWNER_TABLE_KEY_1 )
        OR ( ( Recinfo.OWNER_TABLE_KEY_1 IS NULL )
            AND (  X_OWNER_TABLE_KEY_1 IS NULL ) ) )
    AND ( ( Recinfo.OWNER_TABLE_KEY_2 = X_OWNER_TABLE_KEY_2 )
        OR ( ( Recinfo.OWNER_TABLE_KEY_2 IS NULL )
            AND (  X_OWNER_TABLE_KEY_2 IS NULL ) ) )
    AND ( ( Recinfo.OWNER_TABLE_KEY_3 = X_OWNER_TABLE_KEY_3 )
        OR ( ( Recinfo.OWNER_TABLE_KEY_3 IS NULL )
            AND (  X_OWNER_TABLE_KEY_3 IS NULL ) ) )
    AND ( ( Recinfo.OWNER_TABLE_KEY_4 = X_OWNER_TABLE_KEY_4 )
        OR ( ( Recinfo.OWNER_TABLE_KEY_4 IS NULL )
            AND (  X_OWNER_TABLE_KEY_4 IS NULL ) ) )
    AND ( ( Recinfo.OWNER_TABLE_KEY_5 = X_OWNER_TABLE_KEY_5 )
        OR ( ( Recinfo.OWNER_TABLE_KEY_5 IS NULL )
            AND (  X_OWNER_TABLE_KEY_5 IS NULL ) ) )
    AND ( ( Recinfo.CLASS_CATEGORY = X_CLASS_CATEGORY )
        OR ( ( Recinfo.CLASS_CATEGORY IS NULL )
            AND (  X_CLASS_CATEGORY IS NULL ) ) )
    AND ( ( Recinfo.CLASS_CODE = X_CLASS_CODE )
        OR ( ( Recinfo.CLASS_CODE IS NULL )
            AND (  X_CLASS_CODE IS NULL ) ) )
    AND ( ( Recinfo.PRIMARY_FLAG = X_PRIMARY_FLAG )
        OR ( ( Recinfo.PRIMARY_FLAG IS NULL )
            AND (  X_PRIMARY_FLAG IS NULL ) ) )
    AND ( ( Recinfo.CONTENT_SOURCE_TYPE = X_CONTENT_SOURCE_TYPE )
        OR ( ( Recinfo.CONTENT_SOURCE_TYPE IS NULL )
            AND (  X_CONTENT_SOURCE_TYPE IS NULL ) ) )
    AND ( ( Recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE )
        OR ( ( Recinfo.START_DATE_ACTIVE IS NULL )
            AND (  X_START_DATE_ACTIVE IS NULL ) ) )
    AND ( ( Recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE )
        OR ( ( Recinfo.END_DATE_ACTIVE IS NULL )
            AND (  X_END_DATE_ACTIVE IS NULL ) ) )
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
    AND ( ( Recinfo.STATUS = X_STATUS )
        OR ( ( Recinfo.STATUS IS NULL )
            AND (  X_STATUS IS NULL ) ) )
    AND ( ( Recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER )
        OR ( ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
            AND (  X_OBJECT_VERSION_NUMBER IS NULL ) ) )
    AND ( ( Recinfo.CREATED_BY_MODULE = X_CREATED_BY_MODULE )
        OR ( ( Recinfo.CREATED_BY_MODULE IS NULL )
            AND (  X_CREATED_BY_MODULE IS NULL ) ) )
    AND ( ( Recinfo.RANK = X_RANK )
        OR ( ( Recinfo.RANK IS NULL )
            AND (  X_RANK IS NULL ) ) )
    AND ( ( Recinfo.APPLICATION_ID = X_APPLICATION_ID )
        OR ( ( Recinfo.APPLICATION_ID IS NULL )
            AND (  X_APPLICATION_ID IS NULL ) ) )
    AND ( ( Recinfo.ACTUAL_CONTENT_SOURCE = X_ACTUAL_CONTENT_SOURCE )
        OR ( ( Recinfo.ACTUAL_CONTENT_SOURCE IS NULL )
            AND (  X_ACTUAL_CONTENT_SOURCE IS NULL ) ) )
    ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    X_CODE_ASSIGNMENT_ID                    IN OUT NOCOPY NUMBER,
    X_OWNER_TABLE_NAME                      OUT NOCOPY    VARCHAR2,
    X_OWNER_TABLE_ID                        OUT NOCOPY    NUMBER,
    X_OWNER_TABLE_KEY_1                     OUT NOCOPY    VARCHAR2,
    X_OWNER_TABLE_KEY_2                     OUT NOCOPY    VARCHAR2,
    X_OWNER_TABLE_KEY_3                     OUT NOCOPY    VARCHAR2,
    X_OWNER_TABLE_KEY_4                     OUT NOCOPY    VARCHAR2,
    X_OWNER_TABLE_KEY_5                     OUT NOCOPY    VARCHAR2,
    X_CLASS_CATEGORY                        OUT NOCOPY    VARCHAR2,
    X_CLASS_CODE                            OUT NOCOPY    VARCHAR2,
    X_PRIMARY_FLAG                          OUT NOCOPY    VARCHAR2,
    X_CONTENT_SOURCE_TYPE                   OUT NOCOPY    VARCHAR2,
    X_START_DATE_ACTIVE                     OUT NOCOPY    DATE,
    X_END_DATE_ACTIVE                       OUT NOCOPY    DATE,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_RANK                                  OUT NOCOPY    NUMBER,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER,
    -- SSM SST Integration and Extension
    X_ACTUAL_CONTENT_SOURCE                 OUT NOCOPY    VARCHAR2
) IS

BEGIN

    SELECT
        NVL( CODE_ASSIGNMENT_ID, FND_API.G_MISS_NUM ),
        NVL( OWNER_TABLE_NAME, FND_API.G_MISS_CHAR ),
        NVL( OWNER_TABLE_ID, FND_API.G_MISS_NUM ),
        NVL( OWNER_TABLE_KEY_1, FND_API.G_MISS_CHAR ),
        NVL( OWNER_TABLE_KEY_2, FND_API.G_MISS_CHAR ),
        NVL( OWNER_TABLE_KEY_3, FND_API.G_MISS_CHAR ),
        NVL( OWNER_TABLE_KEY_4, FND_API.G_MISS_CHAR ),
        NVL( OWNER_TABLE_KEY_5, FND_API.G_MISS_CHAR ),
        NVL( CLASS_CATEGORY, FND_API.G_MISS_CHAR ),
        NVL( CLASS_CODE, FND_API.G_MISS_CHAR ),
        NVL( PRIMARY_FLAG, FND_API.G_MISS_CHAR ),
        NVL( CONTENT_SOURCE_TYPE, FND_API.G_MISS_CHAR ),
        NVL( START_DATE_ACTIVE, FND_API.G_MISS_DATE ),
        NVL( END_DATE_ACTIVE, FND_API.G_MISS_DATE ),
        NVL( STATUS, FND_API.G_MISS_CHAR ),
        NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR ),
        NVL( RANK, FND_API.G_MISS_NUM ),
        NVL( APPLICATION_ID, FND_API.G_MISS_NUM ),
	NVL( ACTUAL_CONTENT_SOURCE, FND_API.G_MISS_CHAR)
    INTO
        X_CODE_ASSIGNMENT_ID,
        X_OWNER_TABLE_NAME,
        X_OWNER_TABLE_ID,
        X_OWNER_TABLE_KEY_1,
        X_OWNER_TABLE_KEY_2,
        X_OWNER_TABLE_KEY_3,
        X_OWNER_TABLE_KEY_4,
        X_OWNER_TABLE_KEY_5,
        X_CLASS_CATEGORY,
        X_CLASS_CODE,
        X_PRIMARY_FLAG,
        X_CONTENT_SOURCE_TYPE,
        X_START_DATE_ACTIVE,
        X_END_DATE_ACTIVE,
        X_STATUS,
        X_CREATED_BY_MODULE,
        X_RANK,
        X_APPLICATION_ID,
	X_ACTUAL_CONTENT_SOURCE
    FROM HZ_CODE_ASSIGNMENTS
    WHERE CODE_ASSIGNMENT_ID = X_CODE_ASSIGNMENT_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'code_assignment_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', TO_CHAR( X_CODE_ASSIGNMENT_ID ) );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    X_CODE_ASSIGNMENT_ID                    IN     NUMBER
) IS

BEGIN

    DELETE FROM HZ_CODE_ASSIGNMENTS
    WHERE CODE_ASSIGNMENT_ID = X_CODE_ASSIGNMENT_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_CODE_ASSIGNMENTS_PKG;

/
