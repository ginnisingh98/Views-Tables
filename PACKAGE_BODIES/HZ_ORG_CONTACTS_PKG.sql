--------------------------------------------------------
--  DDL for Package Body HZ_ORG_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORG_CONTACTS_PKG" AS
/*$Header: ARHORCTB.pls 120.2 2005/07/29 01:26:26 jhuang ship $ */

PROCEDURE Insert_Row (
    X_ORG_CONTACT_ID                        IN OUT NOCOPY NUMBER,
    X_PARTY_RELATIONSHIP_ID                 IN     NUMBER,
    X_COMMENTS                              IN     VARCHAR2,
    X_CONTACT_NUMBER                        IN     VARCHAR2,
    X_DEPARTMENT_CODE                       IN     VARCHAR2,
    X_DEPARTMENT                            IN     VARCHAR2,
    X_TITLE                                 IN     VARCHAR2,
    X_JOB_TITLE                             IN     VARCHAR2,
    X_DECISION_MAKER_FLAG                   IN     VARCHAR2,
    X_JOB_TITLE_CODE                        IN     VARCHAR2,
    X_REFERENCE_USE_FLAG                    IN     VARCHAR2,
    X_RANK                                  IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
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
    X_ATTRIBUTE21                           IN     VARCHAR2,
    X_ATTRIBUTE22                           IN     VARCHAR2,
    X_ATTRIBUTE23                           IN     VARCHAR2,
    X_ATTRIBUTE24                           IN     VARCHAR2,
    X_PARTY_SITE_ID                         IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_STATUS                                IN     VARCHAR2
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN
    WHILE l_success = 'N' LOOP
    BEGIN
        INSERT INTO HZ_ORG_CONTACTS (
            ORG_CONTACT_ID,
            PARTY_RELATIONSHIP_ID,
            COMMENTS,
            CONTACT_NUMBER,
            DEPARTMENT_CODE,
            DEPARTMENT,
            JOB_TITLE,
            DECISION_MAKER_FLAG,
            JOB_TITLE_CODE,
            REFERENCE_USE_FLAG,
            RANK,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORIG_SYSTEM_REFERENCE,
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
            ATTRIBUTE21,
            ATTRIBUTE22,
            ATTRIBUTE23,
            ATTRIBUTE24,
            PARTY_SITE_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY_MODULE,
            APPLICATION_ID,
            STATUS
        )
        VALUES (
            DECODE( X_ORG_CONTACT_ID, FND_API.G_MISS_NUM, HZ_ORG_CONTACTS_S.NEXTVAL, NULL, HZ_ORG_CONTACTS_S.NEXTVAL, X_ORG_CONTACT_ID ),
            DECODE( X_PARTY_RELATIONSHIP_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_RELATIONSHIP_ID ),
            DECODE( X_COMMENTS, FND_API.G_MISS_CHAR, NULL, X_COMMENTS ),
            DECODE( X_CONTACT_NUMBER, FND_API.G_MISS_CHAR, NULL, X_CONTACT_NUMBER ),
            DECODE( X_DEPARTMENT_CODE, FND_API.G_MISS_CHAR, NULL, X_DEPARTMENT_CODE ),
            DECODE( X_DEPARTMENT, FND_API.G_MISS_CHAR, NULL, X_DEPARTMENT ),
            DECODE( X_JOB_TITLE, FND_API.G_MISS_CHAR, NULL, X_JOB_TITLE ),
            DECODE( X_DECISION_MAKER_FLAG, FND_API.G_MISS_CHAR, 'N', NULL, 'N', X_DECISION_MAKER_FLAG ),
            DECODE( X_JOB_TITLE_CODE, FND_API.G_MISS_CHAR, NULL, X_JOB_TITLE_CODE ),
            DECODE( X_REFERENCE_USE_FLAG, FND_API.G_MISS_CHAR, 'N', NULL, 'N', X_REFERENCE_USE_FLAG ),
            DECODE( X_RANK, FND_API.G_MISS_CHAR, NULL, X_RANK ),
            HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
            HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
            HZ_UTILITY_V2PUB.CREATION_DATE,
            HZ_UTILITY_V2PUB.CREATED_BY,
            HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
            HZ_UTILITY_V2PUB.REQUEST_ID,
            HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
            HZ_UTILITY_V2PUB.PROGRAM_ID,
            HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
            DECODE( X_ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR, TO_CHAR(NVL(X_ORG_CONTACT_ID,HZ_ORG_CONTACTS_S.CURRVAL)), NULL, TO_CHAR(NVL(X_ORG_CONTACT_ID,HZ_ORG_CONTACTS_S.CURRVAL)), X_ORIG_SYSTEM_REFERENCE ),
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
            DECODE( X_ATTRIBUTE21, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE21 ),
            DECODE( X_ATTRIBUTE22, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE22 ),
            DECODE( X_ATTRIBUTE23, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE23 ),
            DECODE( X_ATTRIBUTE24, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE24 ),
            DECODE( X_PARTY_SITE_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_SITE_ID ),
            DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
            DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
            DECODE( X_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID ),
            DECODE( X_STATUS, FND_API.G_MISS_CHAR, NULL, X_STATUS )
        ) RETURNING
            ORG_CONTACT_ID
        INTO
            X_ORG_CONTACT_ID;

        l_success := 'Y';

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            IF INSTRB( SQLERRM, 'HZ_ORG_CONTACTS_U1' ) <> 0 OR
               INSTRB( SQLERRM, 'HZ_ORG_CONTACTS_PK' ) <> 0
            THEN
            DECLARE
                l_count             NUMBER;
                l_dummy             VARCHAR2(1);
            BEGIN
                l_count := 1;
                WHILE l_count > 0 LOOP
                    SELECT HZ_ORG_CONTACTS_S.NEXTVAL
                    INTO X_ORG_CONTACT_ID FROM dual;
                    BEGIN
                        SELECT 'Y' INTO l_dummy
                        FROM HZ_ORG_CONTACTS
                        WHERE ORG_CONTACT_ID = X_ORG_CONTACT_ID;
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
    X_ORG_CONTACT_ID                        IN     NUMBER,
    X_PARTY_RELATIONSHIP_ID                 IN     NUMBER,
    X_COMMENTS                              IN     VARCHAR2,
    X_CONTACT_NUMBER                        IN     VARCHAR2,
    X_DEPARTMENT_CODE                       IN     VARCHAR2,
    X_DEPARTMENT                            IN     VARCHAR2,
    X_TITLE                                 IN     VARCHAR2,
    X_JOB_TITLE                             IN     VARCHAR2,
    X_DECISION_MAKER_FLAG                   IN     VARCHAR2,
    X_JOB_TITLE_CODE                        IN     VARCHAR2,
    X_REFERENCE_USE_FLAG                    IN     VARCHAR2,
    X_RANK                                  IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
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
    X_ATTRIBUTE21                           IN     VARCHAR2,
    X_ATTRIBUTE22                           IN     VARCHAR2,
    X_ATTRIBUTE23                           IN     VARCHAR2,
    X_ATTRIBUTE24                           IN     VARCHAR2,
    X_PARTY_SITE_ID                         IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_STATUS                                IN     VARCHAR2
) IS

BEGIN

    UPDATE HZ_ORG_CONTACTS SET
        ORG_CONTACT_ID = DECODE( X_ORG_CONTACT_ID, NULL, ORG_CONTACT_ID, FND_API.G_MISS_NUM, NULL, X_ORG_CONTACT_ID ),
        PARTY_RELATIONSHIP_ID = DECODE( X_PARTY_RELATIONSHIP_ID, NULL, PARTY_RELATIONSHIP_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_RELATIONSHIP_ID ),
        COMMENTS = DECODE( X_COMMENTS, NULL, COMMENTS, FND_API.G_MISS_CHAR, NULL, X_COMMENTS ),
        CONTACT_NUMBER = DECODE( X_CONTACT_NUMBER, NULL, CONTACT_NUMBER, FND_API.G_MISS_CHAR, NULL, X_CONTACT_NUMBER ),
        DEPARTMENT_CODE = DECODE( X_DEPARTMENT_CODE, NULL, DEPARTMENT_CODE, FND_API.G_MISS_CHAR, NULL, X_DEPARTMENT_CODE ),
        DEPARTMENT = DECODE( X_DEPARTMENT, NULL, DEPARTMENT, FND_API.G_MISS_CHAR, NULL, X_DEPARTMENT ),
        JOB_TITLE = DECODE( X_JOB_TITLE, NULL, JOB_TITLE, FND_API.G_MISS_CHAR, NULL, X_JOB_TITLE ),
        DECISION_MAKER_FLAG = DECODE( X_DECISION_MAKER_FLAG, NULL, DECISION_MAKER_FLAG, FND_API.G_MISS_CHAR, 'N', X_DECISION_MAKER_FLAG ),
        JOB_TITLE_CODE = DECODE( X_JOB_TITLE_CODE, NULL, JOB_TITLE_CODE, FND_API.G_MISS_CHAR, NULL, X_JOB_TITLE_CODE ),
        REFERENCE_USE_FLAG = DECODE( X_REFERENCE_USE_FLAG, NULL, REFERENCE_USE_FLAG, FND_API.G_MISS_CHAR, NULL, X_REFERENCE_USE_FLAG ),
        RANK = DECODE( X_RANK, NULL, RANK, FND_API.G_MISS_CHAR, NULL, X_RANK ),
        LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        CREATION_DATE = CREATION_DATE,
        CREATED_BY = CREATED_BY,
        LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID,
        PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        ORIG_SYSTEM_REFERENCE = DECODE( X_ORIG_SYSTEM_REFERENCE, NULL, ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR, ORIG_SYSTEM_REFERENCE, X_ORIG_SYSTEM_REFERENCE ),
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
        ATTRIBUTE21 = DECODE( X_ATTRIBUTE21, NULL, ATTRIBUTE21, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE21 ),
        ATTRIBUTE22 = DECODE( X_ATTRIBUTE22, NULL, ATTRIBUTE22, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE22 ),
        ATTRIBUTE23 = DECODE( X_ATTRIBUTE23, NULL, ATTRIBUTE23, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE23 ),
        ATTRIBUTE24 = DECODE( X_ATTRIBUTE24, NULL, ATTRIBUTE24, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE24 ),
        PARTY_SITE_ID = DECODE( X_PARTY_SITE_ID, NULL, PARTY_SITE_ID, FND_API.G_MISS_NUM, NULL, X_PARTY_SITE_ID ),
        OBJECT_VERSION_NUMBER = DECODE( X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
        CREATED_BY_MODULE = DECODE( X_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
        APPLICATION_ID = DECODE( X_APPLICATION_ID, NULL, APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID ),
        STATUS  = DECODE( X_STATUS, NULL, STATUS, FND_API.G_MISS_CHAR,NULL, X_STATUS )
    WHERE ROWID = X_RowId;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_ORG_CONTACT_ID                        IN     NUMBER,
    X_PARTY_RELATIONSHIP_ID                 IN     NUMBER,
    X_COMMENTS                              IN     VARCHAR2,
    X_CONTACT_NUMBER                        IN     VARCHAR2,
    X_DEPARTMENT_CODE                       IN     VARCHAR2,
    X_DEPARTMENT                            IN     VARCHAR2,
    X_TITLE                                 IN     VARCHAR2,
    X_JOB_TITLE                             IN     VARCHAR2,
    X_DECISION_MAKER_FLAG                   IN     VARCHAR2,
    X_JOB_TITLE_CODE                        IN     VARCHAR2,
    X_REFERENCE_USE_FLAG                    IN     VARCHAR2,
    X_RANK                                  IN     VARCHAR2,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_CREATED_BY                            IN     NUMBER,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
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
    X_ATTRIBUTE21                           IN     VARCHAR2,
    X_ATTRIBUTE22                           IN     VARCHAR2,
    X_ATTRIBUTE23                           IN     VARCHAR2,
    X_ATTRIBUTE24                           IN     VARCHAR2,
    X_PARTY_SITE_ID                         IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

    CURSOR C IS
        SELECT * FROM HZ_ORG_CONTACTS
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
        ( ( Recinfo.ORG_CONTACT_ID = X_ORG_CONTACT_ID )
        OR ( ( Recinfo.ORG_CONTACT_ID IS NULL )
            AND (  X_ORG_CONTACT_ID IS NULL ) ) )
    AND ( ( Recinfo.PARTY_RELATIONSHIP_ID = X_PARTY_RELATIONSHIP_ID )
        OR ( ( Recinfo.PARTY_RELATIONSHIP_ID IS NULL )
            AND (  X_PARTY_RELATIONSHIP_ID IS NULL ) ) )
    AND ( ( Recinfo.COMMENTS = X_COMMENTS )
        OR ( ( Recinfo.COMMENTS IS NULL )
            AND (  X_COMMENTS IS NULL ) ) )
    AND ( ( Recinfo.CONTACT_NUMBER = X_CONTACT_NUMBER )
        OR ( ( Recinfo.CONTACT_NUMBER IS NULL )
            AND (  X_CONTACT_NUMBER IS NULL ) ) )
    AND ( ( Recinfo.DEPARTMENT_CODE = X_DEPARTMENT_CODE )
        OR ( ( Recinfo.DEPARTMENT_CODE IS NULL )
            AND (  X_DEPARTMENT_CODE IS NULL ) ) )
    AND ( ( Recinfo.DEPARTMENT = X_DEPARTMENT )
        OR ( ( Recinfo.DEPARTMENT IS NULL )
            AND (  X_DEPARTMENT IS NULL ) ) )
    AND ( ( Recinfo.JOB_TITLE = X_JOB_TITLE )
        OR ( ( Recinfo.JOB_TITLE IS NULL )
            AND (  X_JOB_TITLE IS NULL ) ) )
    AND ( ( Recinfo.DECISION_MAKER_FLAG = X_DECISION_MAKER_FLAG )
        OR ( ( Recinfo.DECISION_MAKER_FLAG IS NULL )
            AND (  X_DECISION_MAKER_FLAG IS NULL ) ) )
    AND ( ( Recinfo.JOB_TITLE_CODE = X_JOB_TITLE_CODE )
        OR ( ( Recinfo.JOB_TITLE_CODE IS NULL )
            AND (  X_JOB_TITLE_CODE IS NULL ) ) )
    AND ( ( Recinfo.REFERENCE_USE_FLAG = X_REFERENCE_USE_FLAG )
        OR ( ( Recinfo.REFERENCE_USE_FLAG IS NULL )
            AND (  X_REFERENCE_USE_FLAG IS NULL ) ) )
    AND ( ( Recinfo.RANK = X_RANK )
        OR ( ( Recinfo.RANK IS NULL )
            AND (  X_RANK IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE )
        OR ( ( Recinfo.LAST_UPDATE_DATE IS NULL )
            AND (  X_LAST_UPDATE_DATE IS NULL ) ) )
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
    AND ( ( Recinfo.ORIG_SYSTEM_REFERENCE = X_ORIG_SYSTEM_REFERENCE )
        OR ( ( Recinfo.ORIG_SYSTEM_REFERENCE IS NULL )
            AND (  X_ORIG_SYSTEM_REFERENCE IS NULL ) ) )
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
    AND ( ( Recinfo.ATTRIBUTE21 = X_ATTRIBUTE21 )
        OR ( ( Recinfo.ATTRIBUTE21 IS NULL )
            AND (  X_ATTRIBUTE21 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE22 = X_ATTRIBUTE22 )
        OR ( ( Recinfo.ATTRIBUTE22 IS NULL )
            AND (  X_ATTRIBUTE22 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE23 = X_ATTRIBUTE23 )
        OR ( ( Recinfo.ATTRIBUTE23 IS NULL )
            AND (  X_ATTRIBUTE23 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE24 = X_ATTRIBUTE24 )
        OR ( ( Recinfo.ATTRIBUTE24 IS NULL )
            AND (  X_ATTRIBUTE24 IS NULL ) ) )
    AND ( ( Recinfo.PARTY_SITE_ID = X_PARTY_SITE_ID )
        OR ( ( Recinfo.PARTY_SITE_ID IS NULL )
            AND (  X_PARTY_SITE_ID IS NULL ) ) )
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
    X_ORG_CONTACT_ID                        IN OUT NOCOPY NUMBER,
    X_PARTY_RELATIONSHIP_ID                 OUT NOCOPY    NUMBER,
    X_COMMENTS                              OUT NOCOPY    VARCHAR2,
    X_CONTACT_NUMBER                        OUT NOCOPY    VARCHAR2,
    X_DEPARTMENT_CODE                       OUT NOCOPY    VARCHAR2,
    X_DEPARTMENT                            OUT NOCOPY    VARCHAR2,
    X_TITLE                                 OUT NOCOPY    VARCHAR2,
    X_JOB_TITLE                             OUT NOCOPY    VARCHAR2,
    X_DECISION_MAKER_FLAG                   OUT NOCOPY    VARCHAR2,
    X_JOB_TITLE_CODE                        OUT NOCOPY    VARCHAR2,
    X_REFERENCE_USE_FLAG                    OUT NOCOPY    VARCHAR2,
    X_RANK                                  OUT NOCOPY    VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 OUT NOCOPY    VARCHAR2,
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
    X_ATTRIBUTE21                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE22                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE23                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE24                           OUT NOCOPY    VARCHAR2,
    X_PARTY_SITE_ID                         OUT NOCOPY    NUMBER,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
) IS

BEGIN

    SELECT
        NVL( ORG_CONTACT_ID, FND_API.G_MISS_NUM ),
        NVL( PARTY_RELATIONSHIP_ID, FND_API.G_MISS_NUM ),
        NVL( COMMENTS, FND_API.G_MISS_CHAR ),
        NVL( CONTACT_NUMBER, FND_API.G_MISS_CHAR ),
        NVL( DEPARTMENT_CODE, FND_API.G_MISS_CHAR ),
        NVL( DEPARTMENT, FND_API.G_MISS_CHAR ),
        NVL( TITLE, FND_API.G_MISS_CHAR ),
        NVL( JOB_TITLE, FND_API.G_MISS_CHAR ),
        NVL( DECISION_MAKER_FLAG, FND_API.G_MISS_CHAR ),
        NVL( JOB_TITLE_CODE, FND_API.G_MISS_CHAR ),
        NVL( REFERENCE_USE_FLAG, FND_API.G_MISS_CHAR ),
        NVL( RANK, FND_API.G_MISS_CHAR ),
        NVL( ORIG_SYSTEM_REFERENCE, FND_API.G_MISS_CHAR ),
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
        NVL( ATTRIBUTE21, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE22, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE23, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE24, FND_API.G_MISS_CHAR ),
        NVL( PARTY_SITE_ID, FND_API.G_MISS_NUM ),
        NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR ),
        NVL( APPLICATION_ID, FND_API.G_MISS_NUM )
    INTO
        X_ORG_CONTACT_ID,
        X_PARTY_RELATIONSHIP_ID,
        X_COMMENTS,
        X_CONTACT_NUMBER,
        X_DEPARTMENT_CODE,
        X_DEPARTMENT,
        X_TITLE,
        X_JOB_TITLE,
        X_DECISION_MAKER_FLAG,
        X_JOB_TITLE_CODE,
        X_REFERENCE_USE_FLAG,
        X_RANK,
        X_ORIG_SYSTEM_REFERENCE,
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
        X_ATTRIBUTE21,
        X_ATTRIBUTE22,
        X_ATTRIBUTE23,
        X_ATTRIBUTE24,
        X_PARTY_SITE_ID,
        X_CREATED_BY_MODULE,
        X_APPLICATION_ID
    FROM HZ_ORG_CONTACTS
    WHERE ORG_CONTACT_ID = X_ORG_CONTACT_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'org_contact_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', TO_CHAR( X_ORG_CONTACT_ID ) );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    X_ORG_CONTACT_ID                        IN     NUMBER
) IS

BEGIN

    DELETE FROM HZ_ORG_CONTACTS
    WHERE ORG_CONTACT_ID = X_ORG_CONTACT_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_ORG_CONTACTS_PKG;

/
