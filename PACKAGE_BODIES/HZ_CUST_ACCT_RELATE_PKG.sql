--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCT_RELATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCT_RELATE_PKG" AS
/*$Header: ARHAARTB.pls 120.9.12010000.2 2009/01/27 10:33:17 vsegu ship $ */

PROCEDURE Insert_Row (
    X_CUST_ACCOUNT_ID                       IN     NUMBER,
    X_RELATED_CUST_ACCOUNT_ID               IN     NUMBER,
    X_RELATIONSHIP_TYPE                     IN     VARCHAR2,
    X_COMMENTS                              IN     VARCHAR2,
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
    X_CUSTOMER_RECIPROCAL_FLAG              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_BILL_TO_FLAG                          IN     VARCHAR2,
    X_SHIP_TO_FLAG                          IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ORG_ID                                IN     NUMBER,
    X_CUST_ACCT_RELATE_ID                   IN OUT NOCOPY NUMBER   -- Bug 4529413
) IS

BEGIN

    INSERT INTO HZ_CUST_ACCT_RELATE_ALL (
        CUST_ACCOUNT_ID,
        RELATED_CUST_ACCOUNT_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        RELATIONSHIP_TYPE,
        COMMENTS,
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
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        CUSTOMER_RECIPROCAL_FLAG,
        STATUS,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        BILL_TO_FLAG,
        SHIP_TO_FLAG,
        OBJECT_VERSION_NUMBER,
        CREATED_BY_MODULE,
        APPLICATION_ID,
	ORG_ID,    -- Bug 3456489
        CUST_ACCT_RELATE_ID   -- Bug 4529413
    )
    VALUES (
        DECODE( X_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, X_CUST_ACCOUNT_ID ),
        DECODE( X_RELATED_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, X_RELATED_CUST_ACCOUNT_ID ),
        HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        HZ_UTILITY_V2PUB.CREATION_DATE,
        HZ_UTILITY_V2PUB.CREATED_BY,
        HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        DECODE( X_RELATIONSHIP_TYPE, FND_API.G_MISS_CHAR, NULL, X_RELATIONSHIP_TYPE ),
        DECODE( X_COMMENTS, FND_API.G_MISS_CHAR, NULL, X_COMMENTS ),
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
        HZ_UTILITY_V2PUB.REQUEST_ID,
        HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        HZ_UTILITY_V2PUB.PROGRAM_ID,
        HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        DECODE( X_CUSTOMER_RECIPROCAL_FLAG, FND_API.G_MISS_CHAR, 'N', NULL, 'N', X_CUSTOMER_RECIPROCAL_FLAG ),
        DECODE( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
        DECODE( X_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE11 ),
        DECODE( X_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE12 ),
        DECODE( X_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE13 ),
        DECODE( X_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE14 ),
        DECODE( X_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE15 ),
        DECODE( X_BILL_TO_FLAG, FND_API.G_MISS_CHAR, 'Y', NULL, 'Y', X_BILL_TO_FLAG ),
        DECODE( X_SHIP_TO_FLAG, FND_API.G_MISS_CHAR, 'Y', NULL, 'Y', X_SHIP_TO_FLAG ),
        DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
        DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
        DECODE( X_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID ),
	DECODE( X_ORG_ID, FND_API.G_MISS_NUM, NULL, X_ORG_ID ),  -- Bug 3456489
        DECODE( X_CUST_ACCT_RELATE_ID,FND_API.G_MISS_NUM,HZ_CUST_ACCT_RELATE_S.NEXTVAL, NULL ,HZ_CUST_ACCT_RELATE_S.NEXTVAL,X_CUST_ACCT_RELATE_ID)     --Bug 4529413
        )
  RETURNING
    CUST_ACCT_RELATE_ID
  INTO
    X_CUST_ACCT_RELATE_ID ;


END Insert_Row;

PROCEDURE Update_Row (
    X_CUST_ACCT_RELATE_ID                   IN OUT NOCOPY NUMBER,   --Bug 4529413
    X_CUST_ACCOUNT_ID                       IN     NUMBER,
    X_RELATED_CUST_ACCOUNT_ID               IN     NUMBER,
    X_RELATIONSHIP_TYPE                     IN     VARCHAR2,
    X_COMMENTS                              IN     VARCHAR2,
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
    X_CUSTOMER_RECIPROCAL_FLAG              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_BILL_TO_FLAG                          IN     VARCHAR2,
    X_SHIP_TO_FLAG                          IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

BEGIN

    UPDATE HZ_CUST_ACCT_RELATE_ALL SET   -- Bug 3456489
        CUST_ACCOUNT_ID = DECODE( X_CUST_ACCOUNT_ID, NULL, CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, X_CUST_ACCOUNT_ID ),
        RELATED_CUST_ACCOUNT_ID = DECODE( X_RELATED_CUST_ACCOUNT_ID, NULL, RELATED_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, X_RELATED_CUST_ACCOUNT_ID ),
        LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        CREATION_DATE = CREATION_DATE,
        CREATED_BY = CREATED_BY,
        LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        RELATIONSHIP_TYPE = DECODE( X_RELATIONSHIP_TYPE, NULL, RELATIONSHIP_TYPE, FND_API.G_MISS_CHAR, NULL, X_RELATIONSHIP_TYPE ),
        COMMENTS = DECODE( X_COMMENTS, NULL, COMMENTS, FND_API.G_MISS_CHAR, NULL, X_COMMENTS ),
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
        REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID,
        PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        CUSTOMER_RECIPROCAL_FLAG = DECODE( X_CUSTOMER_RECIPROCAL_FLAG, NULL, CUSTOMER_RECIPROCAL_FLAG, FND_API.G_MISS_CHAR, 'N', X_CUSTOMER_RECIPROCAL_FLAG ),
        STATUS = DECODE( X_STATUS, NULL, STATUS, FND_API.G_MISS_CHAR, 'A', X_STATUS ),
        ATTRIBUTE11 = DECODE( X_ATTRIBUTE11, NULL, ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE11 ),
        ATTRIBUTE12 = DECODE( X_ATTRIBUTE12, NULL, ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE12 ),
        ATTRIBUTE13 = DECODE( X_ATTRIBUTE13, NULL, ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE13 ),
        ATTRIBUTE14 = DECODE( X_ATTRIBUTE14, NULL, ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE14 ),
        ATTRIBUTE15 = DECODE( X_ATTRIBUTE15, NULL, ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE15 ),
        BILL_TO_FLAG = DECODE( X_BILL_TO_FLAG, NULL, BILL_TO_FLAG, FND_API.G_MISS_CHAR, 'Y', X_BILL_TO_FLAG ),
        SHIP_TO_FLAG = DECODE( X_SHIP_TO_FLAG, NULL, SHIP_TO_FLAG, FND_API.G_MISS_CHAR, 'Y', X_SHIP_TO_FLAG ),
        OBJECT_VERSION_NUMBER = DECODE( X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
        CREATED_BY_MODULE = DECODE( X_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
        APPLICATION_ID = DECODE( X_APPLICATION_ID, NULL, APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID )
    WHERE CUST_ACCT_RELATE_ID = X_CUST_ACCT_RELATE_ID;    --Bug 4529413

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_CUST_ACCOUNT_ID                       IN     NUMBER,
    X_RELATED_CUST_ACCOUNT_ID               IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_CREATED_BY                            IN     NUMBER,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_RELATIONSHIP_TYPE                     IN     VARCHAR2,
    X_COMMENTS                              IN     VARCHAR2,
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
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_CUSTOMER_RECIPROCAL_FLAG              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_BILL_TO_FLAG                          IN     VARCHAR2,
    X_SHIP_TO_FLAG                          IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
) IS

    CURSOR C IS
        SELECT * FROM HZ_CUST_ACCT_RELATE_ALL  -- Bug 3456489
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
        ( ( Recinfo.CUST_ACCOUNT_ID = X_CUST_ACCOUNT_ID )
        OR ( ( Recinfo.CUST_ACCOUNT_ID IS NULL )
            AND (  X_CUST_ACCOUNT_ID IS NULL ) ) )
    AND ( ( Recinfo.RELATED_CUST_ACCOUNT_ID = X_RELATED_CUST_ACCOUNT_ID )
        OR ( ( Recinfo.RELATED_CUST_ACCOUNT_ID IS NULL )
            AND (  X_RELATED_CUST_ACCOUNT_ID IS NULL ) ) )
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
    AND ( ( Recinfo.RELATIONSHIP_TYPE = X_RELATIONSHIP_TYPE )
        OR ( ( Recinfo.RELATIONSHIP_TYPE IS NULL )
            AND (  X_RELATIONSHIP_TYPE IS NULL ) ) )
    AND ( ( Recinfo.COMMENTS = X_COMMENTS )
        OR ( ( Recinfo.COMMENTS IS NULL )
            AND (  X_COMMENTS IS NULL ) ) )
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
    AND ( ( Recinfo.CUSTOMER_RECIPROCAL_FLAG = X_CUSTOMER_RECIPROCAL_FLAG )
        OR ( ( Recinfo.CUSTOMER_RECIPROCAL_FLAG IS NULL )
            AND (  X_CUSTOMER_RECIPROCAL_FLAG IS NULL ) ) )
    AND ( ( Recinfo.STATUS = X_STATUS )
        OR ( ( Recinfo.STATUS IS NULL )
            AND (  X_STATUS IS NULL ) ) )
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
    AND ( ( Recinfo.BILL_TO_FLAG = X_BILL_TO_FLAG )
        OR ( ( Recinfo.BILL_TO_FLAG IS NULL )
            AND (  X_BILL_TO_FLAG IS NULL ) ) )
    AND ( ( Recinfo.SHIP_TO_FLAG = X_SHIP_TO_FLAG )
        OR ( ( Recinfo.SHIP_TO_FLAG IS NULL )
            AND (  X_SHIP_TO_FLAG IS NULL ) ) )
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
    X_CUST_ACCOUNT_ID                       IN OUT NOCOPY NUMBER,
    X_RELATED_CUST_ACCOUNT_ID               IN OUT NOCOPY NUMBER,
    X_RELATIONSHIP_TYPE                     OUT NOCOPY    VARCHAR2,
    X_COMMENTS                              OUT NOCOPY    VARCHAR2,
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
    X_CUSTOMER_RECIPROCAL_FLAG              OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE11                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE12                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE13                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE14                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE15                           OUT NOCOPY    VARCHAR2,
    X_BILL_TO_FLAG                          OUT NOCOPY    VARCHAR2,
    X_SHIP_TO_FLAG                          OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER,
    X_ORG_ID                                IN OUT NOCOPY NUMBER, /* Bug 3456489 */
    X_CUST_ACCT_RELATE_ID                   IN OUT NOCOPY NUMBER  -- Bug 4529413
) IS




CURSOR c_sel_cust_acct_relate_pk IS   -- Bug 4529413

         SELECT
           NVL( CUST_ACCOUNT_ID, FND_API.G_MISS_NUM ),
           NVL( RELATED_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM ),
           NVL( RELATIONSHIP_TYPE, FND_API.G_MISS_CHAR ),
           NVL( COMMENTS, FND_API.G_MISS_CHAR ),
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
           NVL( CUSTOMER_RECIPROCAL_FLAG, FND_API.G_MISS_CHAR ),
           NVL( STATUS, FND_API.G_MISS_CHAR ),
           NVL( ATTRIBUTE11, FND_API.G_MISS_CHAR ),
           NVL( ATTRIBUTE12, FND_API.G_MISS_CHAR ),
           NVL( ATTRIBUTE13, FND_API.G_MISS_CHAR ),
           NVL( ATTRIBUTE14, FND_API.G_MISS_CHAR ),
           NVL( ATTRIBUTE15, FND_API.G_MISS_CHAR ),
           NVL( BILL_TO_FLAG, FND_API.G_MISS_CHAR ),
           NVL( SHIP_TO_FLAG, FND_API.G_MISS_CHAR ),
           NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR ),
           NVL( APPLICATION_ID, FND_API.G_MISS_NUM ),
	   NVL( ORG_ID, FND_API.G_MISS_NUM),  -- Bug 3456489
           NVL( CUST_ACCT_RELATE_ID, FND_API.G_MISS_NUM)  -- Bug 4529413
       FROM  HZ_CUST_ACCT_RELATE_ALL
       WHERE CUST_ACCT_RELATE_ID = X_CUST_ACCT_RELATE_ID;


CURSOR c_sel_cust_acct_relate IS


   SELECT *
   FROM
       (
       SELECT
           NVL( CUST_ACCOUNT_ID, FND_API.G_MISS_NUM ),
           NVL( RELATED_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM ),
           NVL( RELATIONSHIP_TYPE, FND_API.G_MISS_CHAR ),
           NVL( COMMENTS, FND_API.G_MISS_CHAR ),
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
           NVL( CUSTOMER_RECIPROCAL_FLAG, FND_API.G_MISS_CHAR ),
           NVL( STATUS, FND_API.G_MISS_CHAR ),
           NVL( ATTRIBUTE11, FND_API.G_MISS_CHAR ),
           NVL( ATTRIBUTE12, FND_API.G_MISS_CHAR ),
           NVL( ATTRIBUTE13, FND_API.G_MISS_CHAR ),
           NVL( ATTRIBUTE14, FND_API.G_MISS_CHAR ),
           NVL( ATTRIBUTE15, FND_API.G_MISS_CHAR ),
           NVL( BILL_TO_FLAG, FND_API.G_MISS_CHAR ),
           NVL( SHIP_TO_FLAG, FND_API.G_MISS_CHAR ),
           NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR ),
           NVL( APPLICATION_ID, FND_API.G_MISS_NUM ),
	   NVL( ORG_ID, FND_API.G_MISS_NUM),  -- Bug 3456489
           NVL( CUST_ACCT_RELATE_ID,FND_API.G_MISS_NUM)  -- Bug 4529413
       FROM  HZ_CUST_ACCT_RELATE_ALL
       WHERE CUST_ACCOUNT_ID = X_CUST_ACCOUNT_ID
       AND   RELATED_CUST_ACCOUNT_ID = X_RELATED_CUST_ACCOUNT_ID
       AND   ORG_ID = NVL(X_ORG_ID, ORG_ID)  -- Bug 3456489
       ORDER BY STATUS ASC,LAST_UPDATE_DATE DESC
       )
   WHERE ROWNUM = 1;

BEGIN
  IF X_CUST_ACCT_RELATE_ID IS NOT NULL THEN  -- Bug 4529413

    OPEN c_sel_cust_acct_relate_pk;
    FETCH c_sel_cust_acct_relate_pk
	INTO
        X_CUST_ACCOUNT_ID,
        X_RELATED_CUST_ACCOUNT_ID,
        X_RELATIONSHIP_TYPE,
        X_COMMENTS,
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
        X_CUSTOMER_RECIPROCAL_FLAG,
        X_STATUS,
        X_ATTRIBUTE11,
        X_ATTRIBUTE12,
        X_ATTRIBUTE13,
        X_ATTRIBUTE14,
        X_ATTRIBUTE15,
        X_BILL_TO_FLAG,
        X_SHIP_TO_FLAG,
        X_CREATED_BY_MODULE,
        X_APPLICATION_ID,
	X_ORG_ID,  -- Bug 3456489
        X_CUST_ACCT_RELATE_ID;

    IF c_sel_cust_acct_relate_pk%NOTFOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'cust_acct_relate_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', TO_CHAR( X_CUST_ACCT_RELATE_ID ));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE c_sel_cust_acct_relate_pk;

  ELSE

    OPEN c_sel_cust_acct_relate;
    FETCH c_sel_cust_acct_relate
	INTO
        X_CUST_ACCOUNT_ID,
        X_RELATED_CUST_ACCOUNT_ID,
        X_RELATIONSHIP_TYPE,
        X_COMMENTS,
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
        X_CUSTOMER_RECIPROCAL_FLAG,
        X_STATUS,
        X_ATTRIBUTE11,
        X_ATTRIBUTE12,
        X_ATTRIBUTE13,
        X_ATTRIBUTE14,
        X_ATTRIBUTE15,
        X_BILL_TO_FLAG,
        X_SHIP_TO_FLAG,
        X_CREATED_BY_MODULE,
        X_APPLICATION_ID,
	X_ORG_ID,  -- Bug 3456489
        X_CUST_ACCT_RELATE_ID;

    IF c_sel_cust_acct_relate%NOTFOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'cust_acct_relate_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', TO_CHAR( X_CUST_ACCOUNT_ID ) ||
                               ',' || TO_CHAR( X_RELATED_CUST_ACCOUNT_ID ) );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE c_sel_cust_acct_relate;
  END IF;
END Select_Row;


PROCEDURE Select_Row (
    X_CUST_ACCOUNT_ID                       OUT NOCOPY    NUMBER,
    X_RELATED_CUST_ACCOUNT_ID               OUT NOCOPY    NUMBER,
    X_RELATIONSHIP_TYPE                     OUT NOCOPY    VARCHAR2,
    X_COMMENTS                              OUT NOCOPY    VARCHAR2,
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
    X_CUSTOMER_RECIPROCAL_FLAG              OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE11                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE12                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE13                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE14                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE15                           OUT NOCOPY    VARCHAR2,
    X_BILL_TO_FLAG                          OUT NOCOPY    VARCHAR2,
    X_SHIP_TO_FLAG                          OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER,
    X_ORG_ID                                OUT NOCOPY    NUMBER,  -- Bug 3456489
    X_CUST_ACCT_RELATE_ID                   OUT NOCOPY    NUMBER, -- Bug 4529413
    X_ROWID                                 IN            ROWID
    ) IS

CURSOR c_sel_cust_acct_relate IS
    SELECT
        NVL( CUST_ACCOUNT_ID, FND_API.G_MISS_NUM ),
        NVL( RELATED_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM ),
        NVL( RELATIONSHIP_TYPE, FND_API.G_MISS_CHAR ),
        NVL( COMMENTS, FND_API.G_MISS_CHAR ),
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
        NVL( CUSTOMER_RECIPROCAL_FLAG, FND_API.G_MISS_CHAR ),
        NVL( STATUS, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE11, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE12, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE13, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE14, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE15, FND_API.G_MISS_CHAR ),
        NVL( BILL_TO_FLAG, FND_API.G_MISS_CHAR ),
        NVL( SHIP_TO_FLAG, FND_API.G_MISS_CHAR ),
        NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR ),
        NVL( APPLICATION_ID, FND_API.G_MISS_NUM ),
	NVL( ORG_ID, FND_API.G_MISS_NUM),
        NVL( CUST_ACCT_RELATE_ID,FND_API.G_MISS_NUM)
    FROM HZ_CUST_ACCT_RELATE_ALL
    WHERE ROWID = X_ROWID;

BEGIN
    OPEN c_sel_cust_acct_relate;
    FETCH c_sel_cust_acct_relate
    INTO
        X_CUST_ACCOUNT_ID,
        X_RELATED_CUST_ACCOUNT_ID,
        X_RELATIONSHIP_TYPE,
        X_COMMENTS,
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
        X_CUSTOMER_RECIPROCAL_FLAG,
        X_STATUS,
        X_ATTRIBUTE11,
        X_ATTRIBUTE12,
        X_ATTRIBUTE13,
        X_ATTRIBUTE14,
        X_ATTRIBUTE15,
        X_BILL_TO_FLAG,
        X_SHIP_TO_FLAG,
        X_CREATED_BY_MODULE,
        X_APPLICATION_ID,
	X_ORG_ID,  -- Bug 3456489
        X_CUST_ACCT_RELATE_ID;
    IF c_sel_cust_acct_relate%NOTFOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'cust_acct_relate_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE',  X_ROWID );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE c_sel_cust_acct_relate;
END Select_Row;



PROCEDURE Delete_Row (
    X_ROWID                       IN     ROWID
) IS

    l_customer_reciprocal_flag              HZ_CUST_ACCT_RELATE_ALL.customer_reciprocal_flag%TYPE;
    l_cust_account_id                       HZ_CUST_ACCT_RELATE_ALL.cust_account_id%TYPE;
    l_related_cust_account_id               HZ_CUST_ACCT_RELATE_ALL.related_cust_account_id%TYPE;
    l_org_id                                HZ_CUST_ACCT_RELATE_ALL.org_id%TYPE;
    l_status                                HZ_CUST_ACCT_RELATE_ALL.status%TYPE;

BEGIN

    SELECT CUST_ACCOUNT_ID,
           RELATED_CUST_ACCOUNT_ID,
	   CUSTOMER_RECIPROCAL_FLAG,
	   ORG_ID,
	   STATUS
    INTO   l_cust_account_id,
           l_related_cust_account_id,
	   l_customer_reciprocal_flag,
	   l_org_id,
	   l_status
    FROM HZ_CUST_ACCT_RELATE_ALL
    WHERE ROWID = X_ROWID;
/*    WHERE CUST_ACCOUNT_ID = X_CUST_ACCOUNT_ID
    AND RELATED_CUST_ACCOUNT_ID = X_RELATED_CUST_ACCOUNT_ID;*/

    DELETE FROM HZ_CUST_ACCT_RELATE
    WHERE ROWID = X_ROWID;
/*    WHERE CUST_ACCOUNT_ID = X_CUST_ACCOUNT_ID
    AND RELATED_CUST_ACCOUNT_ID = X_RELATED_CUST_ACCOUNT_ID;*/

    IF l_customer_reciprocal_flag = 'Y' AND l_status = 'A' THEN
        UPDATE HZ_CUST_ACCT_RELATE_ALL
        SET CUSTOMER_RECIPROCAL_FLAG = 'N'
        WHERE CUST_ACCOUNT_ID = l_related_cust_account_id
        AND RELATED_CUST_ACCOUNT_ID = l_cust_account_id
	AND ORG_ID = l_org_id;
    END IF;

END Delete_Row;

END HZ_CUST_ACCT_RELATE_PKG;

/