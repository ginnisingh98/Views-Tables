--------------------------------------------------------
--  DDL for Package Body FUN_RULE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_DETAILS_PKG" AS
/*$Header: FUNXTMRULRDTTBB.pls 120.1 2005/12/05 12:32:13 ammishra noship $ */

PROCEDURE Insert_Row (
    X_ROWID                                 IN OUT NOCOPY VARCHAR2,
    X_RULE_DETAIL_ID                        IN     NUMBER,
    X_RULE_OBJECT_ID                        IN     NUMBER,
    X_RULE_NAME                             IN     VARCHAR2,
    X_SEQ                                   IN     NUMBER,
    X_OPERATOR                              IN     VARCHAR2,
    X_ENABLED_FLAG                          IN     VARCHAR2,
    X_RESULT_APPLICATION_ID                 IN     NUMBER,
    X_RESULT_VALUE                          IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2
   ) IS

BEGIN

    INSERT INTO FUN_RULE_DETAILS (
        RULE_DETAIL_ID,
        RULE_OBJECT_ID,
        RULE_NAME,
        SEQ,
        OPERATOR,
        ENABLED_FLAG,
        RESULT_APPLICATION_ID,
        RESULT_VALUE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        OBJECT_VERSION_NUMBER,
        CREATED_BY_MODULE
    )
    VALUES (
        NVL(X_RULE_DETAIL_ID,FUN_RULE_DETAILS_S.NEXTVAL),
        X_RULE_OBJECT_ID,
        X_RULE_NAME,
        NVL(FUN_RULE_UTILITY_PKG.GET_MAX_SEQ(X_RULE_OBJECT_ID),1),
        X_OPERATOR,
        X_ENABLED_FLAG,
        X_RESULT_APPLICATION_ID,
        X_RESULT_VALUE,
        FUN_RULE_UTILITY_PKG.CREATED_BY,
        FUN_RULE_UTILITY_PKG.CREATION_DATE,
        FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN,
        FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE,
        FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY,
        1,
        X_CREATED_BY_MODULE
       )RETURNING ROWID INTO X_ROWID;

END Insert_Row;

PROCEDURE Update_Row (
    X_RULE_DETAIL_ID                        IN     NUMBER,
    X_RULE_OBJECT_ID                        IN     NUMBER,
    X_RULE_NAME                             IN     VARCHAR2,
    X_SEQ                                   IN     NUMBER,
    X_OPERATOR                              IN     VARCHAR2,
    X_ENABLED_FLAG                          IN     VARCHAR2,
    X_RESULT_APPLICATION_ID                 IN     NUMBER,
    X_RESULT_VALUE                          IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2
) IS

X_ROWID      VARCHAR2(200);
BEGIN

    UPDATE FUN_RULE_DETAILS SET
        RULE_NAME = X_RULE_NAME,
        SEQ = X_SEQ,
        OPERATOR = X_OPERATOR,
        ENABLED_FLAG = X_ENABLED_FLAG,
        RESULT_APPLICATION_ID = X_RESULT_APPLICATION_ID,
        RESULT_VALUE = X_RESULT_VALUE,
        CREATED_BY = FUN_RULE_UTILITY_PKG.CREATED_BY,
        CREATION_DATE = FUN_RULE_UTILITY_PKG.CREATION_DATE,
        LAST_UPDATE_LOGIN = FUN_RULE_UTILITY_PKG.LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE = FUN_RULE_UTILITY_PKG.LAST_UPDATE_DATE,
        LAST_UPDATED_BY = FUN_RULE_UTILITY_PKG.LAST_UPDATED_BY,
        OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
        CREATED_BY_MODULE = X_CREATED_BY_MODULE
    WHERE RULE_DETAIL_ID = X_RULE_DETAIL_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NO_DATA_FOUND;

END Update_Row;

PROCEDURE Lock_Row (
    X_RULE_DETAIL_ID                        IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER
) IS

    CURSOR C IS
        SELECT OBJECT_VERSION_NUMBER FROM FUN_RULE_DETAILS
        WHERE  RULE_DETAIL_ID = X_RULE_DETAIL_ID
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

    IF ( Recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
    THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    X_RULE_NAME                             IN  OUT NOCOPY   VARCHAR2,
    X_RULE_DETAIL_ID                        IN  OUT NOCOPY     NUMBER,
    X_RULE_OBJECT_ID                        IN  OUT NOCOPY     NUMBER,
    X_SEQ                                   OUT NOCOPY     NUMBER,
    X_OPERATOR                              OUT NOCOPY     VARCHAR2,
    X_ENABLED_FLAG                          OUT NOCOPY     VARCHAR2,
    X_RESULT_APPLICATION_ID                 OUT NOCOPY     NUMBER,
    X_RESULT_VALUE                          OUT NOCOPY     VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY     VARCHAR2
) IS

BEGIN
    SELECT
        NVL( RULE_NAME, FND_API.G_MISS_CHAR ),
        NVL( RULE_DETAIL_ID, FND_API.G_MISS_NUM ),
        NVL( RULE_OBJECT_ID, FND_API.G_MISS_NUM ),
        NVL( SEQ, FND_API.G_MISS_NUM ),
        NVL( OPERATOR, FND_API.G_MISS_CHAR ),
        NVL( ENABLED_FLAG, FND_API.G_MISS_CHAR ),
        NVL( RESULT_APPLICATION_ID, FND_API.G_MISS_NUM ),
        NVL( RESULT_VALUE, FND_API.G_MISS_CHAR ),
        NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR )
    INTO
        X_RULE_NAME,
        X_RULE_DETAIL_ID,
        X_RULE_OBJECT_ID,
        X_SEQ,
        X_OPERATOR,
        X_ENABLED_FLAG,
        X_RESULT_APPLICATION_ID,
        X_RESULT_VALUE,
        X_CREATED_BY_MODULE
    FROM FUN_RULE_DETAILS
    WHERE RULE_DETAIL_ID = X_RULE_DETAIL_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'p_rule_details_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', X_RULE_NAME );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END Select_Row;

PROCEDURE Delete_Row (
    X_RULE_DETAIL_ID IN NUMBER
) IS

BEGIN

    DELETE FUN_RULE_DETAILS
    WHERE RULE_DETAIL_ID = X_RULE_DETAIL_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;


END Delete_Row;

END FUN_RULE_DETAILS_PKG;

/
