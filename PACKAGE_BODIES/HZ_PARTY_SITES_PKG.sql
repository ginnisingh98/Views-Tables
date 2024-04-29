--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_SITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_SITES_PKG" AS
/*$Header: ARHPSTTB.pls 120.4.12010000.2 2010/03/04 11:00:29 rgokavar ship $ */

G_MISS_CONTENT_SOURCE_TYPE                  CONSTANT VARCHAR2(30) := 'USER_ENTERED';

PROCEDURE Insert_Row (
    X_PARTY_SITE_ID                         IN OUT NOCOPY NUMBER,
    X_PARTY_ID                              IN     NUMBER,
    X_LOCATION_ID                           IN     NUMBER,
    X_PARTY_SITE_NUMBER                     IN OUT NOCOPY VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_ATTRIBUTE16                           IN     VARCHAR2,
    X_ATTRIBUTE17                           IN     VARCHAR2,
    X_ATTRIBUTE18                           IN     VARCHAR2,
    X_ATTRIBUTE19                           IN     VARCHAR2,
    X_ATTRIBUTE20                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_LANGUAGE                              IN     VARCHAR2,
    X_MAILSTOP                              IN     VARCHAR2,
    X_IDENTIFYING_ADDRESS_FLAG              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_PARTY_SITE_NAME                       IN     VARCHAR2,
    X_ADDRESSEE                             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2,
    X_GLOBAL_LOCATION_NUMBER                IN     VARCHAR2,
    X_DUNS_NUMBER_C                         IN     VARCHAR2 DEFAULT NULL
) IS

    l_success                               VARCHAR2(1) := 'N';
    l_debug_prefix                          VARCHAR2(30) := '';
BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
        INSERT INTO HZ_PARTY_SITES (
            PARTY_SITE_ID,
            PARTY_SITE_NUMBER,
            PARTY_ID,
            LOCATION_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            ATTRIBUTE16,
            ATTRIBUTE17,
            ATTRIBUTE18,
            ATTRIBUTE19,
            ATTRIBUTE20,
            ORIG_SYSTEM_REFERENCE,
            MAILSTOP,
            IDENTIFYING_ADDRESS_FLAG,
            STATUS,
            PARTY_SITE_NAME,
            ADDRESSEE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY_MODULE,
            APPLICATION_ID,
            ACTUAL_CONTENT_SOURCE,
            GLOBAL_LOCATION_NUMBER,
            DUNS_NUMBER_C
        )
        VALUES (
            DECODE( X_PARTY_SITE_ID, FND_API.G_MISS_NUM, HZ_PARTY_SITES_S.NEXTVAL, NULL, HZ_PARTY_SITES_S.NEXTVAL, X_PARTY_SITE_ID ),
            DECODE( X_PARTY_SITE_NUMBER, FND_API.G_MISS_CHAR, TO_CHAR( HZ_PARTY_SITE_NUMBER_S.NEXTVAL ), NULL, TO_CHAR( HZ_PARTY_SITE_NUMBER_S.NEXTVAL ), X_PARTY_SITE_NUMBER ),
            DECODE( X_PARTY_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_ID ),
            DECODE( X_LOCATION_ID, FND_API.G_MISS_NUM, NULL, X_LOCATION_ID ),
            HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
            HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
            HZ_UTILITY_V2PUB.CREATION_DATE,
            HZ_UTILITY_V2PUB.CREATED_BY,
            HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
            HZ_UTILITY_V2PUB.REQUEST_ID,
            HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
            HZ_UTILITY_V2PUB.PROGRAM_ID,
            HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
            DECODE( X_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE_CATEGORY ),
            DECODE( X_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE1 ),
            DECODE( X_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE2 ),
            DECODE( X_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE3 ),
            DECODE( X_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE4 ),
            DECODE( X_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE5 ),
            DECODE( X_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE6 ),
            DECODE( X_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE7 ),
            DECODE( X_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE8 ),
            DECODE( X_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE9 ),
            DECODE( X_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE10 ),
            DECODE( X_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE11 ),
            DECODE( X_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE12 ),
            DECODE( X_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE13 ),
            DECODE( X_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE14 ),
            DECODE( X_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE15 ),
            DECODE( X_ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE16 ),
            DECODE( X_ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE17 ),
            DECODE( X_ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE18 ),
            DECODE( X_ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE19 ),
            DECODE( X_ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE20 ),
            DECODE( X_ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR, TO_CHAR(NVL(X_PARTY_SITE_ID,HZ_PARTY_SITES_S.CURRVAL)), NULL, TO_CHAR(NVL(X_PARTY_SITE_ID,HZ_PARTY_SITES_S.CURRVAL)), X_ORIG_SYSTEM_REFERENCE ),
            DECODE( X_MAILSTOP, FND_API.G_MISS_CHAR, NULL, X_MAILSTOP ),
            DECODE( X_IDENTIFYING_ADDRESS_FLAG, FND_API.G_MISS_CHAR, 'N', NULL, 'N', X_IDENTIFYING_ADDRESS_FLAG ),
            DECODE( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
            DECODE( X_PARTY_SITE_NAME, FND_API.G_MISS_CHAR, NULL, X_PARTY_SITE_NAME ),
            DECODE( X_ADDRESSEE, FND_API.G_MISS_CHAR, NULL, X_ADDRESSEE ),
            DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
            DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
            DECODE( X_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID ),
            decode( X_ACTUAL_CONTENT_SOURCE,
                    FND_API.G_MISS_CHAR, G_MISS_CONTENT_SOURCE_TYPE,
                    NULL, G_MISS_CONTENT_SOURCE_TYPE, X_ACTUAL_CONTENT_SOURCE ),
            DECODE( X_GLOBAL_LOCATION_NUMBER, FND_API.G_MISS_CHAR, NULL, X_GLOBAL_LOCATION_NUMBER),
            DECODE( X_DUNS_NUMBER_C, FND_API.G_MISS_CHAR, NULL, X_DUNS_NUMBER_C )
        ) RETURNING
            PARTY_SITE_ID,
            PARTY_SITE_NUMBER
        INTO
            X_PARTY_SITE_ID,
            X_PARTY_SITE_NUMBER;

        l_success := 'Y';

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            IF INSTRB( SQLERRM, 'HZ_PARTY_SITES_U1' ) <> 0 OR
               INSTRB( SQLERRM, 'HZ_PARTY_SITES_PK' ) <> 0
            THEN
            DECLARE
                l_count             NUMBER;
                l_dummy             VARCHAR2(1);
            BEGIN
                l_count := 1;
                WHILE l_count > 0 LOOP
                    SELECT HZ_PARTY_SITES_S.NEXTVAL
                    INTO X_PARTY_SITE_ID FROM dual;
                    BEGIN
                        SELECT 'Y' INTO l_dummy
                        FROM HZ_PARTY_SITES
                        WHERE PARTY_SITE_ID = X_PARTY_SITE_ID;
                        l_count := 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_count := 0;
                    END;
                END LOOP;
            END;
            ELSIF INSTRB( SQLERRM, 'HZ_PARTY_SITES_U2' ) <> 0 THEN
            DECLARE
                l_count             NUMBER;
                l_dummy             VARCHAR2(1);
            BEGIN
            -- Debug info.
 	                 IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
 	                         hz_utility_v2pub.debug(p_message=>'DUP_VAL_ON_INDEX Error on HZ_PARTY_SITES_U2 Index',
 	                         p_prefix=>l_debug_prefix,
 	                         p_msg_level=>fnd_log.level_procedure);
 	                 END IF;
 	             --  Bug9394160 When Profile HZ: Generate Party Site Number set to NO
 	             --  System should not pick Sequence value and should raise
 	             --  Duplicate Party Site Number Error.
 	               IF fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER') = 'N' THEN

 	                    -- Debug info.
 	                    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
 	                         hz_utility_v2pub.debug(p_message=>'HZ: Generate Party Site Number set to NO so raising Dup val Error.',
 	                         p_prefix=>l_debug_prefix,
 	                         p_msg_level=>fnd_log.level_procedure);
 	                    END IF;

 	                    FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
 	                    FND_MESSAGE.SET_TOKEN('COLUMN', 'party_site_number');
 	                    FND_MSG_PUB.ADD;
 	                    RAISE FND_API.G_EXC_ERROR;
 	               ELSE
                     l_count := 1;
                    WHILE l_count > 0 LOOP
                        SELECT TO_CHAR( HZ_PARTY_SITE_NUMBER_S.NEXTVAL )
                        INTO X_PARTY_SITE_NUMBER FROM dual;
                        BEGIN
                            SELECT 'Y' INTO l_dummy
                            FROM HZ_PARTY_SITES
                            WHERE PARTY_SITE_NUMBER = X_PARTY_SITE_NUMBER;
                            l_count := 1;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                l_count := 0;
                        END;
                    END LOOP;
                   END IF;
                END;
            ELSE
                RAISE;
            END IF;

    END;
    END LOOP;

END Insert_Row;

PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_PARTY_SITE_ID                         IN     NUMBER,
    X_PARTY_ID                              IN     NUMBER,
    X_LOCATION_ID                           IN     NUMBER,
    X_PARTY_SITE_NUMBER                     IN     VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_ATTRIBUTE16                           IN     VARCHAR2,
    X_ATTRIBUTE17                           IN     VARCHAR2,
    X_ATTRIBUTE18                           IN     VARCHAR2,
    X_ATTRIBUTE19                           IN     VARCHAR2,
    X_ATTRIBUTE20                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_LANGUAGE                              IN     VARCHAR2,
    X_MAILSTOP                              IN     VARCHAR2,
    X_IDENTIFYING_ADDRESS_FLAG              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_PARTY_SITE_NAME                       IN     VARCHAR2,
    X_ADDRESSEE                             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2 DEFAULT NULL,
    X_GLOBAL_LOCATION_NUMBER                IN     VARCHAR2,
    X_DUNS_NUMBER_C                         IN     VARCHAR2 DEFAULT NULL
) IS

BEGIN

    UPDATE HZ_PARTY_SITES SET
        PARTY_SITE_ID = DECODE( X_PARTY_SITE_ID, NULL, PARTY_SITE_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_SITE_ID ),
        PARTY_ID = DECODE( X_PARTY_ID, NULL, PARTY_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_ID ),
        LOCATION_ID = DECODE( X_LOCATION_ID, NULL, LOCATION_ID, FND_API.G_MISS_NUM, NULL, X_LOCATION_ID ),
        LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        PARTY_SITE_NUMBER = DECODE( X_PARTY_SITE_NUMBER, NULL, PARTY_SITE_NUMBER, FND_API.G_MISS_CHAR, NULL, X_PARTY_SITE_NUMBER ),
        LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        CREATION_DATE = CREATION_DATE,
        CREATED_BY = CREATED_BY,
        LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID,
        PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        ATTRIBUTE_CATEGORY = DECODE( X_ATTRIBUTE_CATEGORY, NULL, ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE_CATEGORY ),
        ATTRIBUTE1 = DECODE( X_ATTRIBUTE1, NULL, ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE1 ),
        ATTRIBUTE2 = DECODE( X_ATTRIBUTE2, NULL, ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE2 ),
        ATTRIBUTE3 = DECODE( X_ATTRIBUTE3, NULL, ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE3 ),
        ATTRIBUTE4 = DECODE( X_ATTRIBUTE4, NULL, ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE4 ),
        ATTRIBUTE5 = DECODE( X_ATTRIBUTE5, NULL, ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE5 ),
        ATTRIBUTE6 = DECODE( X_ATTRIBUTE6, NULL, ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE6 ),
        ATTRIBUTE7 = DECODE( X_ATTRIBUTE7, NULL, ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE7 ),
        ATTRIBUTE8 = DECODE( X_ATTRIBUTE8, NULL, ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE8 ),
        ATTRIBUTE9 = DECODE( X_ATTRIBUTE9, NULL, ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE9 ),
        ATTRIBUTE10 = DECODE( X_ATTRIBUTE10, NULL, ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE10 ),
        ATTRIBUTE11 = DECODE( X_ATTRIBUTE11, NULL, ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE11 ),
        ATTRIBUTE12 = DECODE( X_ATTRIBUTE12, NULL, ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE12 ),
        ATTRIBUTE13 = DECODE( X_ATTRIBUTE13, NULL, ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE13 ),
        ATTRIBUTE14 = DECODE( X_ATTRIBUTE14, NULL, ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE14 ),
        ATTRIBUTE15 = DECODE( X_ATTRIBUTE15, NULL, ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE15 ),
        ATTRIBUTE16 = DECODE( X_ATTRIBUTE16, NULL, ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE16 ),
        ATTRIBUTE17 = DECODE( X_ATTRIBUTE17, NULL, ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE17 ),
        ATTRIBUTE18 = DECODE( X_ATTRIBUTE18, NULL, ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE18 ),
        ATTRIBUTE19 = DECODE( X_ATTRIBUTE19, NULL, ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE19 ),
        ATTRIBUTE20 = DECODE( X_ATTRIBUTE20, NULL, ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE20 ),
        ORIG_SYSTEM_REFERENCE = DECODE( X_ORIG_SYSTEM_REFERENCE, NULL, ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR, ORIG_SYSTEM_REFERENCE, X_ORIG_SYSTEM_REFERENCE ),
        MAILSTOP = DECODE( X_MAILSTOP, NULL, MAILSTOP, FND_API.G_MISS_CHAR, NULL, X_MAILSTOP ),
        IDENTIFYING_ADDRESS_FLAG = DECODE( X_IDENTIFYING_ADDRESS_FLAG, NULL, IDENTIFYING_ADDRESS_FLAG, FND_API.G_MISS_CHAR, 'N', X_IDENTIFYING_ADDRESS_FLAG ),
        STATUS = DECODE( X_STATUS, NULL, STATUS, FND_API.G_MISS_CHAR, 'A', X_STATUS ),
        PARTY_SITE_NAME = DECODE( X_PARTY_SITE_NAME, NULL, PARTY_SITE_NAME, FND_API.G_MISS_CHAR, NULL, X_PARTY_SITE_NAME ),
        ADDRESSEE = DECODE( X_ADDRESSEE, NULL, ADDRESSEE, FND_API.G_MISS_CHAR, NULL, X_ADDRESSEE ),
        OBJECT_VERSION_NUMBER = DECODE( X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
        CREATED_BY_MODULE = DECODE( X_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
        APPLICATION_ID = DECODE( X_APPLICATION_ID, NULL, APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID ),
        ACTUAL_CONTENT_SOURCE = DECODE( x_ACTUAL_CONTENT_SOURCE, NULL, ACTUAL_CONTENT_SOURCE,
                                        FND_API.G_MISS_CHAR, NULL, X_ACTUAL_CONTENT_SOURCE),
        GLOBAL_LOCATION_NUMBER = DECODE ( X_GLOBAL_LOCATION_NUMBER, NULL, GLOBAL_LOCATION_NUMBER, FND_API.G_MISS_CHAR, NULL, X_GLOBAL_LOCATION_NUMBER),
        DUNS_NUMBER_C = DECODE( X_DUNS_NUMBER_C, NULL, DUNS_NUMBER_C, FND_API.G_MISS_CHAR, NULL, X_DUNS_NUMBER_C )
    WHERE ROWID = X_RowId;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_PARTY_SITE_ID                         IN     NUMBER,
    X_PARTY_ID                              IN     NUMBER,
    X_LOCATION_ID                           IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_PARTY_SITE_NUMBER                     IN     VARCHAR2,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_CREATED_BY                            IN     NUMBER,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_ATTRIBUTE16                           IN     VARCHAR2,
    X_ATTRIBUTE17                           IN     VARCHAR2,
    X_ATTRIBUTE18                           IN     VARCHAR2,
    X_ATTRIBUTE19                           IN     VARCHAR2,
    X_ATTRIBUTE20                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_LANGUAGE                              IN     VARCHAR2,
    X_MAILSTOP                              IN     VARCHAR2,
    X_IDENTIFYING_ADDRESS_FLAG              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_PARTY_SITE_NAME                       IN     VARCHAR2,
    X_ADDRESSEE                             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2 DEFAULT NULL,
    X_GLOBAL_LOCATION_NUMBER                IN     VARCHAR2
) IS

    CURSOR C IS
        SELECT * FROM HZ_PARTY_SITES
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
        ( ( Recinfo.PARTY_SITE_ID = X_PARTY_SITE_ID )
        OR ( ( Recinfo.PARTY_SITE_ID IS NULL )
            AND (  X_PARTY_SITE_ID IS NULL ) ) )
    AND ( ( Recinfo.PARTY_ID = X_PARTY_ID )
        OR ( ( Recinfo.PARTY_ID IS NULL )
            AND (  X_PARTY_ID IS NULL ) ) )
    AND ( ( Recinfo.LOCATION_ID = X_LOCATION_ID )
        OR ( ( Recinfo.LOCATION_ID IS NULL )
            AND (  X_LOCATION_ID IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE )
        OR ( ( Recinfo.LAST_UPDATE_DATE IS NULL )
            AND (  X_LAST_UPDATE_DATE IS NULL ) ) )
    AND ( ( Recinfo.PARTY_SITE_NUMBER = X_PARTY_SITE_NUMBER )
        OR ( ( Recinfo.PARTY_SITE_NUMBER IS NULL )
            AND (  X_PARTY_SITE_NUMBER IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATED_BY = X_LAST_UPDATED_BY )
        OR ( ( Recinfo.LAST_UPDATED_BY IS NULL )
            AND (  X_LAST_UPDATED_BY IS NULL ) ) )
    AND ( ( Recinfo.CREATION_DATE = X_CREATION_DATE )
        OR ( ( Recinfo.CREATION_DATE IS NULL )
            AND (  X_CREATION_DATE IS NULL ) ) )
    AND ( ( Recinfo.CREATED_BY = X_CREATED_BY )
        OR ( ( Recinfo.CREATED_BY IS NULL )
            AND (  X_CREATED_BY IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN )
        OR ( ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
            AND (  X_LAST_UPDATE_LOGIN IS NULL ) ) )
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
    AND ( ( Recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY )
        OR ( ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
            AND (  X_ATTRIBUTE_CATEGORY IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE1 = X_ATTRIBUTE1 )
        OR ( ( Recinfo.ATTRIBUTE1 IS NULL )
            AND (  X_ATTRIBUTE1 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE2 = X_ATTRIBUTE2 )
        OR ( ( Recinfo.ATTRIBUTE2 IS NULL )
            AND (  X_ATTRIBUTE2 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE3 = X_ATTRIBUTE3 )
        OR ( ( Recinfo.ATTRIBUTE3 IS NULL )
            AND (  X_ATTRIBUTE3 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE4 = X_ATTRIBUTE4 )
        OR ( ( Recinfo.ATTRIBUTE4 IS NULL )
            AND (  X_ATTRIBUTE4 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE5 = X_ATTRIBUTE5 )
        OR ( ( Recinfo.ATTRIBUTE5 IS NULL )
            AND (  X_ATTRIBUTE5 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE6 = X_ATTRIBUTE6 )
        OR ( ( Recinfo.ATTRIBUTE6 IS NULL )
            AND (  X_ATTRIBUTE6 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE7 = X_ATTRIBUTE7 )
        OR ( ( Recinfo.ATTRIBUTE7 IS NULL )
            AND (  X_ATTRIBUTE7 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE8 = X_ATTRIBUTE8 )
        OR ( ( Recinfo.ATTRIBUTE8 IS NULL )
            AND (  X_ATTRIBUTE8 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE9 = X_ATTRIBUTE9 )
        OR ( ( Recinfo.ATTRIBUTE9 IS NULL )
            AND (  X_ATTRIBUTE9 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE10 = X_ATTRIBUTE10 )
        OR ( ( Recinfo.ATTRIBUTE10 IS NULL )
            AND (  X_ATTRIBUTE10 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE11 = X_ATTRIBUTE11 )
        OR ( ( Recinfo.ATTRIBUTE11 IS NULL )
            AND (  X_ATTRIBUTE11 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE12 = X_ATTRIBUTE12 )
        OR ( ( Recinfo.ATTRIBUTE12 IS NULL )
            AND (  X_ATTRIBUTE12 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE13 = X_ATTRIBUTE13 )
        OR ( ( Recinfo.ATTRIBUTE13 IS NULL )
            AND (  X_ATTRIBUTE13 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE14 = X_ATTRIBUTE14 )
        OR ( ( Recinfo.ATTRIBUTE14 IS NULL )
            AND (  X_ATTRIBUTE14 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE15 = X_ATTRIBUTE15 )
        OR ( ( Recinfo.ATTRIBUTE15 IS NULL )
            AND (  X_ATTRIBUTE15 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE16 = X_ATTRIBUTE16 )
        OR ( ( Recinfo.ATTRIBUTE16 IS NULL )
            AND (  X_ATTRIBUTE16 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE17 = X_ATTRIBUTE17 )
        OR ( ( Recinfo.ATTRIBUTE17 IS NULL )
            AND (  X_ATTRIBUTE17 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE18 = X_ATTRIBUTE18 )
        OR ( ( Recinfo.ATTRIBUTE18 IS NULL )
            AND (  X_ATTRIBUTE18 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE19 = X_ATTRIBUTE19 )
        OR ( ( Recinfo.ATTRIBUTE19 IS NULL )
            AND (  X_ATTRIBUTE19 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE20 = X_ATTRIBUTE20 )
        OR ( ( Recinfo.ATTRIBUTE20 IS NULL )
            AND (  X_ATTRIBUTE20 IS NULL ) ) )
    AND ( ( Recinfo.ORIG_SYSTEM_REFERENCE = X_ORIG_SYSTEM_REFERENCE )
        OR ( ( Recinfo.ORIG_SYSTEM_REFERENCE IS NULL )
            AND (  X_ORIG_SYSTEM_REFERENCE IS NULL ) ) )
    AND ( ( Recinfo.MAILSTOP = X_MAILSTOP )
        OR ( ( Recinfo.MAILSTOP IS NULL )
            AND (  X_MAILSTOP IS NULL ) ) )
    AND ( ( Recinfo.IDENTIFYING_ADDRESS_FLAG = X_IDENTIFYING_ADDRESS_FLAG )
        OR ( ( Recinfo.IDENTIFYING_ADDRESS_FLAG IS NULL )
            AND (  X_IDENTIFYING_ADDRESS_FLAG IS NULL ) ) )
    AND ( ( Recinfo.STATUS = X_STATUS )
        OR ( ( Recinfo.STATUS IS NULL )
            AND (  X_STATUS IS NULL ) ) )
    AND ( ( Recinfo.PARTY_SITE_NAME = X_PARTY_SITE_NAME )
        OR ( ( Recinfo.PARTY_SITE_NAME IS NULL )
            AND (  X_PARTY_SITE_NAME IS NULL ) ) )
    AND ( ( Recinfo.ADDRESSEE = X_ADDRESSEE )
        OR ( ( Recinfo.ADDRESSEE IS NULL )
            AND (  X_ADDRESSEE IS NULL ) ) )
    AND ( ( Recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER )
        OR ( ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
            AND (  X_OBJECT_VERSION_NUMBER IS NULL ) ) )
    AND ( ( Recinfo.CREATED_BY_MODULE = X_CREATED_BY_MODULE )
        OR ( ( Recinfo.CREATED_BY_MODULE IS NULL )
            AND (  X_CREATED_BY_MODULE IS NULL ) ) )
    AND ( ( Recinfo.APPLICATION_ID = X_APPLICATION_ID )
        OR ( ( Recinfo.APPLICATION_ID IS NULL )
            AND (  X_APPLICATION_ID IS NULL ) ) )
    AND ( ( Recinfo.ACTUAL_CONTENT_SOURCE = X_ACTUAL_CONTENT_SOURCE )
        OR ( ( Recinfo.ACTUAL_CONTENT_SOURCE IS NULL )
            AND (  X_ACTUAL_CONTENT_SOURCE IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_LOCATION_NUMBER = X_GLOBAL_LOCATION_NUMBER )
        OR ( ( Recinfo.GLOBAL_LOCATION_NUMBER IS NULL )
            AND (  X_GLOBAL_LOCATION_NUMBER IS NULL ) ) )
    ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    X_PARTY_SITE_ID                         IN OUT NOCOPY NUMBER,
    X_PARTY_ID                              OUT NOCOPY    NUMBER,
    X_LOCATION_ID                           OUT NOCOPY    NUMBER,
    X_PARTY_SITE_NUMBER                     OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE1                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE2                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE3                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE4                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE5                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE6                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE7                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE8                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE9                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE10                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE11                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE12                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE13                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE14                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE15                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE16                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE17                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE18                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE19                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE20                           OUT NOCOPY    VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 OUT NOCOPY    VARCHAR2,
    X_LANGUAGE                              OUT NOCOPY    VARCHAR2,
    X_MAILSTOP                              OUT NOCOPY    VARCHAR2,
    X_IDENTIFYING_ADDRESS_FLAG              OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_PARTY_SITE_NAME                       OUT NOCOPY    VARCHAR2,
    X_ADDRESSEE                             OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 OUT NOCOPY    VARCHAR2,
    X_GLOBAL_LOCATION_NUMBER                OUT NOCOPY    VARCHAR2,
    X_DUNS_NUMBER_C                         OUT NOCOPY    VARCHAR2
) IS

BEGIN

    SELECT
        NVL( PARTY_SITE_ID, FND_API.G_MISS_NUM ),
        NVL( PARTY_ID, FND_API.G_MISS_NUM ),
        NVL( LOCATION_ID, FND_API.G_MISS_NUM ),
        NVL( PARTY_SITE_NUMBER, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE1, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE2, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE3, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE4, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE5, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE6, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE7, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE8, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE9, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE10, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE11, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE12, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE13, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE14, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE15, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE16, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE17, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE18, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE19, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE20, FND_API.G_MISS_CHAR ),
        NVL( ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR ),
        NVL( LANGUAGE, FND_API.G_MISS_CHAR ),
        NVL( MAILSTOP, FND_API.G_MISS_CHAR ),
        NVL( IDENTIFYING_ADDRESS_FLAG, FND_API.G_MISS_CHAR ),
        NVL( STATUS, FND_API.G_MISS_CHAR ),
        NVL( PARTY_SITE_NAME, FND_API.G_MISS_CHAR ),
        NVL( ADDRESSEE, FND_API.G_MISS_CHAR ),
        NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR ),
        NVL( APPLICATION_ID, FND_API.G_MISS_NUM ),
        NVL( ACTUAL_CONTENT_SOURCE, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_LOCATION_NUMBER, FND_API.G_MISS_CHAR ),
        NVL( DUNS_NUMBER_C, FND_API.G_MISS_CHAR )
    INTO
        X_PARTY_SITE_ID,
        X_PARTY_ID,
        X_LOCATION_ID,
        X_PARTY_SITE_NUMBER,
        X_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1,
        X_ATTRIBUTE2,
        X_ATTRIBUTE3,
        X_ATTRIBUTE4,
        X_ATTRIBUTE5,
        X_ATTRIBUTE6,
        X_ATTRIBUTE7,
        X_ATTRIBUTE8,
        X_ATTRIBUTE9,
        X_ATTRIBUTE10,
        X_ATTRIBUTE11,
        X_ATTRIBUTE12,
        X_ATTRIBUTE13,
        X_ATTRIBUTE14,
        X_ATTRIBUTE15,
        X_ATTRIBUTE16,
        X_ATTRIBUTE17,
        X_ATTRIBUTE18,
        X_ATTRIBUTE19,
        X_ATTRIBUTE20,
        X_ORIG_SYSTEM_REFERENCE,
        X_LANGUAGE,
        X_MAILSTOP,
        X_IDENTIFYING_ADDRESS_FLAG,
        X_STATUS,
        X_PARTY_SITE_NAME,
        X_ADDRESSEE,
        X_CREATED_BY_MODULE,
        X_APPLICATION_ID,
        X_ACTUAL_CONTENT_SOURCE,
        X_GLOBAL_LOCATION_NUMBER,
        X_DUNS_NUMBER_C
    FROM HZ_PARTY_SITES
    WHERE PARTY_SITE_ID = X_PARTY_SITE_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'party_site_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', TO_CHAR( X_PARTY_SITE_ID ) );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    X_PARTY_SITE_ID                         IN     NUMBER
) IS

BEGIN

    DELETE FROM HZ_PARTY_SITES
    WHERE PARTY_SITE_ID = X_PARTY_SITE_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_PARTY_SITES_PKG;

/
