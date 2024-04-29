--------------------------------------------------------
--  DDL for Package Body OKE_NUMBER_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_NUMBER_OPTIONS_PKG" AS
/* $Header: OKENMOPB.pls 115.5 2002/11/21 23:01:09 ybchen ship $ */
PROCEDURE INSERT_ROW
( X_ROWID                           IN OUT NOCOPY VARCHAR2
, X_K_TYPE_CODE                     IN        VARCHAR2
, X_BUY_OR_SELL                     IN        VARCHAR2
, X_CREATION_DATE                   IN        DATE
, X_CREATED_BY                      IN        NUMBER
, X_LAST_UPDATE_DATE                IN        DATE
, X_LAST_UPDATED_BY                 IN        NUMBER
, X_LAST_UPDATE_LOGIN               IN        NUMBER
, X_CONTRACT_NUM_MODE               IN        VARCHAR2
, X_MANUAL_CONTRACT_NUM_TYPE        IN        VARCHAR2
, X_NEXT_CONTRACT_NUM               IN        NUMBER
, X_CONTRACT_NUM_INCREMENT          IN        NUMBER
, X_CONTRACT_NUM_WIDTH              IN        NUMBER
, X_CHGREQ_NUM_MODE                 IN        VARCHAR2
, X_MANUAL_CHGREQ_NUM_TYPE          IN        VARCHAR2
, X_CHGREQ_NUM_START_NUMBER         IN        NUMBER
, X_CHGREQ_NUM_INCREMENT            IN        NUMBER
, X_CHGREQ_NUM_WIDTH                IN        NUMBER
, X_LINE_NUM_START_NUMBER           IN        NUMBER
, X_LINE_NUM_INCREMENT              IN        NUMBER
, X_LINE_NUM_WIDTH                  IN        NUMBER
, X_SUBLINE_NUM_START_NUMBER        IN        NUMBER
, X_SUBLINE_NUM_INCREMENT           IN        NUMBER
, X_SUBLINE_NUM_WIDTH               IN        NUMBER
, X_DELV_NUM_START_NUMBER           IN        NUMBER
, X_DELV_NUM_INCREMENT              IN        NUMBER
, X_DELV_NUM_WIDTH                  IN        NUMBER
, X_ATTRIBUTE_CATEGORY              IN        VARCHAR2
, X_ATTRIBUTE1                      IN        VARCHAR2
, X_ATTRIBUTE2                      IN        VARCHAR2
, X_ATTRIBUTE3                      IN        VARCHAR2
, X_ATTRIBUTE4                      IN        VARCHAR2
, X_ATTRIBUTE5                      IN        VARCHAR2
, X_ATTRIBUTE6                      IN        VARCHAR2
, X_ATTRIBUTE7                      IN        VARCHAR2
, X_ATTRIBUTE8                      IN        VARCHAR2
, X_ATTRIBUTE9                      IN        VARCHAR2
, X_ATTRIBUTE10                     IN        VARCHAR2
, X_ATTRIBUTE11                     IN        VARCHAR2
, X_ATTRIBUTE12                     IN        VARCHAR2
, X_ATTRIBUTE13                     IN        VARCHAR2
, X_ATTRIBUTE14                     IN        VARCHAR2
, X_ATTRIBUTE15                     IN        VARCHAR2
) IS

  CURSOR c IS
    SELECT ROWID
    FROM   OKE_NUMBER_OPTIONS
    WHERE  K_TYPE_CODE = X_K_TYPE_CODE
    AND    BUY_OR_SELL = X_BUY_OR_SELL;

BEGIN

  INSERT INTO OKE_NUMBER_OPTIONS
  ( K_TYPE_CODE
  , BUY_OR_SELL
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , CONTRACT_NUM_MODE
  , MANUAL_CONTRACT_NUM_TYPE
  , NEXT_CONTRACT_NUM
  , CONTRACT_NUM_INCREMENT
  , CONTRACT_NUM_WIDTH
  , CHGREQ_NUM_MODE
  , MANUAL_CHGREQ_NUM_TYPE
  , CHGREQ_NUM_START_NUMBER
  , CHGREQ_NUM_INCREMENT
  , CHGREQ_NUM_WIDTH
  , LINE_NUM_START_NUMBER
  , LINE_NUM_INCREMENT
  , LINE_NUM_WIDTH
  , SUBLINE_NUM_START_NUMBER
  , SUBLINE_NUM_INCREMENT
  , SUBLINE_NUM_WIDTH
  , DELV_NUM_START_NUMBER
  , DELV_NUM_INCREMENT
  , DELV_NUM_WIDTH
  , ATTRIBUTE_CATEGORY
  , ATTRIBUTE1
  , ATTRIBUTE2
  , ATTRIBUTE3
  , ATTRIBUTE4
  , ATTRIBUTE5
  , ATTRIBUTE6
  , ATTRIBUTE7
  , ATTRIBUTE8
  , ATTRIBUTE9
  , ATTRIBUTE10
  , ATTRIBUTE11
  , ATTRIBUTE12
  , ATTRIBUTE13
  , ATTRIBUTE14
  , ATTRIBUTE15
  )
  SELECT
    X_K_TYPE_CODE
  , X_BUY_OR_SELL
  , X_CREATION_DATE
  , X_CREATED_BY
  , X_LAST_UPDATE_DATE
  , X_LAST_UPDATED_BY
  , X_LAST_UPDATE_LOGIN
  , X_CONTRACT_NUM_MODE
  , X_MANUAL_CONTRACT_NUM_TYPE
  , X_NEXT_CONTRACT_NUM
  , X_CONTRACT_NUM_INCREMENT
  , X_CONTRACT_NUM_WIDTH
  , X_CHGREQ_NUM_MODE
  , X_MANUAL_CHGREQ_NUM_TYPE
  , X_CHGREQ_NUM_START_NUMBER
  , X_CHGREQ_NUM_INCREMENT
  , X_CHGREQ_NUM_WIDTH
  , X_LINE_NUM_START_NUMBER
  , X_LINE_NUM_INCREMENT
  , X_LINE_NUM_WIDTH
  , X_SUBLINE_NUM_START_NUMBER
  , X_SUBLINE_NUM_INCREMENT
  , X_SUBLINE_NUM_WIDTH
  , X_DELV_NUM_START_NUMBER
  , X_DELV_NUM_INCREMENT
  , X_DELV_NUM_WIDTH
  , X_ATTRIBUTE_CATEGORY
  , X_ATTRIBUTE1
  , X_ATTRIBUTE2
  , X_ATTRIBUTE3
  , X_ATTRIBUTE4
  , X_ATTRIBUTE5
  , X_ATTRIBUTE6
  , X_ATTRIBUTE7
  , X_ATTRIBUTE8
  , X_ATTRIBUTE9
  , X_ATTRIBUTE10
  , X_ATTRIBUTE11
  , X_ATTRIBUTE12
  , X_ATTRIBUTE13
  , X_ATTRIBUTE14
  , X_ATTRIBUTE15
  FROM DUAL
  WHERE NOT EXISTS
  (SELECT NULL
   FROM   OKE_NUMBER_OPTIONS
   WHERE  K_TYPE_CODE=X_K_TYPE_CODE
   AND    BUY_OR_SELL=X_BUY_OR_SELL);

  OPEN c;
  FETCH c INTO X_ROWID;
  IF ( c%notfound ) THEN
    CLOSE c;
    RAISE no_data_found;
  END IF;
  CLOSE c;

END INSERT_ROW;


PROCEDURE LOCK_ROW
( X_ROWID                           IN        VARCHAR2
, X_K_TYPE_CODE                     IN        VARCHAR2
, X_BUY_OR_SELL                     IN        VARCHAR2
, X_CREATION_DATE                   IN        DATE
, X_CREATED_BY                      IN        NUMBER
, X_LAST_UPDATE_DATE                IN        DATE
, X_LAST_UPDATED_BY                 IN        NUMBER
, X_LAST_UPDATE_LOGIN               IN        NUMBER
, X_CONTRACT_NUM_MODE               IN        VARCHAR2
, X_MANUAL_CONTRACT_NUM_TYPE        IN        VARCHAR2
, X_NEXT_CONTRACT_NUM               IN        NUMBER
, X_CONTRACT_NUM_INCREMENT          IN        NUMBER
, X_CONTRACT_NUM_WIDTH              IN        NUMBER
, X_CHGREQ_NUM_MODE                 IN        VARCHAR2
, X_MANUAL_CHGREQ_NUM_TYPE          IN        VARCHAR2
, X_CHGREQ_NUM_START_NUMBER         IN        NUMBER
, X_CHGREQ_NUM_INCREMENT            IN        NUMBER
, X_CHGREQ_NUM_WIDTH                IN        NUMBER
, X_LINE_NUM_START_NUMBER           IN        NUMBER
, X_LINE_NUM_INCREMENT              IN        NUMBER
, X_LINE_NUM_WIDTH                  IN        NUMBER
, X_SUBLINE_NUM_START_NUMBER        IN        NUMBER
, X_SUBLINE_NUM_INCREMENT           IN        NUMBER
, X_SUBLINE_NUM_WIDTH               IN        NUMBER
, X_DELV_NUM_START_NUMBER           IN        NUMBER
, X_DELV_NUM_INCREMENT              IN        NUMBER
, X_DELV_NUM_WIDTH                  IN        NUMBER
, X_ATTRIBUTE_CATEGORY              IN        VARCHAR2
, X_ATTRIBUTE1                      IN        VARCHAR2
, X_ATTRIBUTE2                      IN        VARCHAR2
, X_ATTRIBUTE3                      IN        VARCHAR2
, X_ATTRIBUTE4                      IN        VARCHAR2
, X_ATTRIBUTE5                      IN        VARCHAR2
, X_ATTRIBUTE6                      IN        VARCHAR2
, X_ATTRIBUTE7                      IN        VARCHAR2
, X_ATTRIBUTE8                      IN        VARCHAR2
, X_ATTRIBUTE9                      IN        VARCHAR2
, X_ATTRIBUTE10                     IN        VARCHAR2
, X_ATTRIBUTE11                     IN        VARCHAR2
, X_ATTRIBUTE12                     IN        VARCHAR2
, X_ATTRIBUTE13                     IN        VARCHAR2
, X_ATTRIBUTE14                     IN        VARCHAR2
, X_ATTRIBUTE15                     IN        VARCHAR2
) IS

  CURSOR C IS
    SELECT K_TYPE_CODE
    ,      BUY_OR_SELL
    ,      CONTRACT_NUM_MODE
    ,      MANUAL_CONTRACT_NUM_TYPE
    ,      NEXT_CONTRACT_NUM
    ,      CONTRACT_NUM_INCREMENT
    ,      CONTRACT_NUM_WIDTH
    ,      CHGREQ_NUM_MODE
    ,      MANUAL_CHGREQ_NUM_TYPE
    ,      CHGREQ_NUM_START_NUMBER
    ,      CHGREQ_NUM_INCREMENT
    ,      CHGREQ_NUM_WIDTH
    ,      LINE_NUM_START_NUMBER
    ,      LINE_NUM_INCREMENT
    ,      LINE_NUM_WIDTH
    ,      SUBLINE_NUM_START_NUMBER
    ,      SUBLINE_NUM_INCREMENT
    ,      SUBLINE_NUM_WIDTH
    ,      DELV_NUM_START_NUMBER
    ,      DELV_NUM_INCREMENT
    ,      DELV_NUM_WIDTH
    ,      ATTRIBUTE_CATEGORY
    ,      ATTRIBUTE1
    ,      ATTRIBUTE2
    ,      ATTRIBUTE3
    ,      ATTRIBUTE4
    ,      ATTRIBUTE5
    ,      ATTRIBUTE6
    ,      ATTRIBUTE7
    ,      ATTRIBUTE8
    ,      ATTRIBUTE9
    ,      ATTRIBUTE10
    ,      ATTRIBUTE11
    ,      ATTRIBUTE12
    ,      ATTRIBUTE13
    ,      ATTRIBUTE14
    ,      ATTRIBUTE15
    FROM OKE_NUMBER_OPTIONS
    WHERE ROWID = X_ROWID
    FOR UPDATE OF K_TYPE_CODE NOWAIT;
  CREC c%rowtype;

BEGIN

  OPEN c;
  FETCH c INTO crec;
  IF ( c%notfound ) THEN
    CLOSE c;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE c;

  IF (    (CREC.K_TYPE_CODE = X_K_TYPE_CODE)
      AND (CREC.BUY_OR_SELL = X_BUY_OR_SELL)
      AND ((CREC.CONTRACT_NUM_MODE = X_CONTRACT_NUM_MODE)
          OR ((CREC.CONTRACT_NUM_MODE IS NULL) AND (X_CONTRACT_NUM_MODE IS NULL)))
      AND ((CREC.MANUAL_CONTRACT_NUM_TYPE = X_MANUAL_CONTRACT_NUM_TYPE)
          OR ((CREC.MANUAL_CONTRACT_NUM_TYPE IS NULL) AND (X_MANUAL_CONTRACT_NUM_TYPE IS NULL)))
      AND ((CREC.NEXT_CONTRACT_NUM = X_NEXT_CONTRACT_NUM)
          OR ((CREC.NEXT_CONTRACT_NUM IS NULL) AND (X_NEXT_CONTRACT_NUM IS NULL)))
      AND ((CREC.CONTRACT_NUM_INCREMENT = X_CONTRACT_NUM_INCREMENT)
          OR ((CREC.CONTRACT_NUM_INCREMENT IS NULL) AND (X_CONTRACT_NUM_INCREMENT IS NULL)))
      AND ((CREC.CONTRACT_NUM_WIDTH = X_CONTRACT_NUM_WIDTH)
          OR ((CREC.CONTRACT_NUM_WIDTH IS NULL) AND (X_CONTRACT_NUM_WIDTH IS NULL)))
      AND ((CREC.CHGREQ_NUM_MODE = X_CHGREQ_NUM_MODE)
          OR ((CREC.CHGREQ_NUM_MODE IS NULL) AND (X_CHGREQ_NUM_MODE IS NULL)))
      AND ((CREC.MANUAL_CHGREQ_NUM_TYPE = X_MANUAL_CHGREQ_NUM_TYPE)
          OR ((CREC.MANUAL_CHGREQ_NUM_TYPE IS NULL) AND (X_MANUAL_CHGREQ_NUM_TYPE IS NULL)))
      AND ((CREC.CHGREQ_NUM_START_NUMBER = X_CHGREQ_NUM_START_NUMBER)
          OR ((CREC.CHGREQ_NUM_START_NUMBER IS NULL) AND (X_CHGREQ_NUM_START_NUMBER IS NULL)))
      AND ((CREC.CHGREQ_NUM_INCREMENT = X_CHGREQ_NUM_INCREMENT)
          OR ((CREC.CHGREQ_NUM_INCREMENT IS NULL) AND (X_CHGREQ_NUM_INCREMENT IS NULL)))
      AND ((CREC.CHGREQ_NUM_WIDTH = X_CHGREQ_NUM_WIDTH)
          OR ((CREC.CHGREQ_NUM_WIDTH IS NULL) AND (X_CHGREQ_NUM_WIDTH IS NULL)))
      AND ((CREC.LINE_NUM_START_NUMBER = X_LINE_NUM_START_NUMBER)
          OR ((CREC.LINE_NUM_START_NUMBER IS NULL) AND (X_LINE_NUM_START_NUMBER IS NULL)))
      AND ((CREC.LINE_NUM_INCREMENT = X_LINE_NUM_INCREMENT)
          OR ((CREC.LINE_NUM_INCREMENT IS NULL) AND (X_LINE_NUM_INCREMENT IS NULL)))
      AND ((CREC.LINE_NUM_WIDTH = X_LINE_NUM_WIDTH)
          OR ((CREC.LINE_NUM_WIDTH IS NULL) AND (X_LINE_NUM_WIDTH IS NULL)))
      AND ((CREC.SUBLINE_NUM_START_NUMBER = X_SUBLINE_NUM_START_NUMBER)
          OR ((CREC.SUBLINE_NUM_START_NUMBER IS NULL) AND (X_SUBLINE_NUM_START_NUMBER IS NULL)))
      AND ((CREC.SUBLINE_NUM_INCREMENT = X_SUBLINE_NUM_INCREMENT)
          OR ((CREC.SUBLINE_NUM_INCREMENT IS NULL) AND (X_SUBLINE_NUM_INCREMENT IS NULL)))
      AND ((CREC.SUBLINE_NUM_WIDTH = X_SUBLINE_NUM_WIDTH)
          OR ((CREC.SUBLINE_NUM_WIDTH IS NULL) AND (X_SUBLINE_NUM_WIDTH IS NULL)))
      AND ((CREC.DELV_NUM_START_NUMBER = X_DELV_NUM_START_NUMBER)
          OR ((CREC.DELV_NUM_START_NUMBER IS NULL) AND (X_DELV_NUM_START_NUMBER IS NULL)))
      AND ((CREC.DELV_NUM_INCREMENT = X_DELV_NUM_INCREMENT)
          OR ((CREC.DELV_NUM_INCREMENT IS NULL) AND (X_DELV_NUM_INCREMENT IS NULL)))
      AND ((CREC.DELV_NUM_WIDTH = X_DELV_NUM_WIDTH)
          OR ((CREC.DELV_NUM_WIDTH IS NULL) AND (X_DELV_NUM_WIDTH IS NULL)))
      AND ((CREC.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
          OR ((CREC.ATTRIBUTE_CATEGORY IS NULL) AND (X_ATTRIBUTE_CATEGORY IS NULL)))
      AND ((CREC.ATTRIBUTE1 = X_ATTRIBUTE1)
          OR ((CREC.ATTRIBUTE1 IS NULL) AND (X_ATTRIBUTE1 IS NULL)))
      AND ((CREC.ATTRIBUTE2 = X_ATTRIBUTE2)
          OR ((CREC.ATTRIBUTE2 IS NULL) AND (X_ATTRIBUTE2 IS NULL)))
      AND ((CREC.ATTRIBUTE3 = X_ATTRIBUTE3)
          OR ((CREC.ATTRIBUTE3 IS NULL) AND (X_ATTRIBUTE3 IS NULL)))
      AND ((CREC.ATTRIBUTE4 = X_ATTRIBUTE4)
          OR ((CREC.ATTRIBUTE4 IS NULL) AND (X_ATTRIBUTE4 IS NULL)))
      AND ((CREC.ATTRIBUTE5 = X_ATTRIBUTE5)
          OR ((CREC.ATTRIBUTE5 IS NULL) AND (X_ATTRIBUTE5 IS NULL)))
      AND ((CREC.ATTRIBUTE6 = X_ATTRIBUTE6)
          OR ((CREC.ATTRIBUTE6 IS NULL) AND (X_ATTRIBUTE6 IS NULL)))
      AND ((CREC.ATTRIBUTE7 = X_ATTRIBUTE7)
          OR ((CREC.ATTRIBUTE7 IS NULL) AND (X_ATTRIBUTE7 IS NULL)))
      AND ((CREC.ATTRIBUTE8 = X_ATTRIBUTE8)
          OR ((CREC.ATTRIBUTE8 IS NULL) AND (X_ATTRIBUTE8 IS NULL)))
      AND ((CREC.ATTRIBUTE9 = X_ATTRIBUTE9)
          OR ((CREC.ATTRIBUTE9 IS NULL) AND (X_ATTRIBUTE9 IS NULL)))
      AND ((CREC.ATTRIBUTE10 = X_ATTRIBUTE10)
          OR ((CREC.ATTRIBUTE10 IS NULL) AND (X_ATTRIBUTE10 IS NULL)))
      AND ((CREC.ATTRIBUTE11 = X_ATTRIBUTE11)
          OR ((CREC.ATTRIBUTE11 IS NULL) AND (X_ATTRIBUTE11 IS NULL)))
      AND ((CREC.ATTRIBUTE12 = X_ATTRIBUTE12)
          OR ((CREC.ATTRIBUTE12 IS NULL) AND (X_ATTRIBUTE12 IS NULL)))
      AND ((CREC.ATTRIBUTE13 = X_ATTRIBUTE13)
          OR ((CREC.ATTRIBUTE13 IS NULL) AND (X_ATTRIBUTE13 IS NULL)))
      AND ((CREC.ATTRIBUTE14 = X_ATTRIBUTE14)
          OR ((CREC.ATTRIBUTE14 IS NULL) AND (X_ATTRIBUTE14 IS NULL)))
      AND ((CREC.ATTRIBUTE15 = X_ATTRIBUTE15)
          OR ((CREC.ATTRIBUTE15 IS NULL) AND (X_ATTRIBUTE15 IS NULL)))

  ) THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  RETURN;

END LOCK_ROW;


PROCEDURE UPDATE_ROW
( X_K_TYPE_CODE                     IN        VARCHAR2
, X_BUY_OR_SELL                     IN        VARCHAR2
, X_LAST_UPDATE_DATE                IN        DATE
, X_LAST_UPDATED_BY                 IN        NUMBER
, X_LAST_UPDATE_LOGIN               IN        NUMBER
, X_CONTRACT_NUM_MODE               IN        VARCHAR2
, X_MANUAL_CONTRACT_NUM_TYPE        IN        VARCHAR2
, X_NEXT_CONTRACT_NUM               IN        NUMBER
, X_CONTRACT_NUM_INCREMENT          IN        NUMBER
, X_CONTRACT_NUM_WIDTH              IN        NUMBER
, X_CHGREQ_NUM_MODE                 IN        VARCHAR2
, X_MANUAL_CHGREQ_NUM_TYPE          IN        VARCHAR2
, X_CHGREQ_NUM_START_NUMBER         IN        NUMBER
, X_CHGREQ_NUM_INCREMENT            IN        NUMBER
, X_CHGREQ_NUM_WIDTH                IN        NUMBER
, X_LINE_NUM_START_NUMBER           IN        NUMBER
, X_LINE_NUM_INCREMENT              IN        NUMBER
, X_LINE_NUM_WIDTH                  IN        NUMBER
, X_SUBLINE_NUM_START_NUMBER        IN        NUMBER
, X_SUBLINE_NUM_INCREMENT           IN        NUMBER
, X_SUBLINE_NUM_WIDTH               IN        NUMBER
, X_DELV_NUM_START_NUMBER           IN        NUMBER
, X_DELV_NUM_INCREMENT              IN        NUMBER
, X_DELV_NUM_WIDTH                  IN        NUMBER
, X_ATTRIBUTE_CATEGORY              IN        VARCHAR2
, X_ATTRIBUTE1                      IN        VARCHAR2
, X_ATTRIBUTE2                      IN        VARCHAR2
, X_ATTRIBUTE3                      IN        VARCHAR2
, X_ATTRIBUTE4                      IN        VARCHAR2
, X_ATTRIBUTE5                      IN        VARCHAR2
, X_ATTRIBUTE6                      IN        VARCHAR2
, X_ATTRIBUTE7                      IN        VARCHAR2
, X_ATTRIBUTE8                      IN        VARCHAR2
, X_ATTRIBUTE9                      IN        VARCHAR2
, X_ATTRIBUTE10                     IN        VARCHAR2
, X_ATTRIBUTE11                     IN        VARCHAR2
, X_ATTRIBUTE12                     IN        VARCHAR2
, X_ATTRIBUTE13                     IN        VARCHAR2
, X_ATTRIBUTE14                     IN        VARCHAR2
, X_ATTRIBUTE15                     IN        VARCHAR2
) IS

BEGIN

  UPDATE OKE_NUMBER_OPTIONS
  SET LAST_UPDATE_DATE          = X_LAST_UPDATE_DATE
  ,   LAST_UPDATED_BY           = X_LAST_UPDATED_BY
  ,   LAST_UPDATE_LOGIN         = X_LAST_UPDATE_LOGIN
  ,   CONTRACT_NUM_MODE         = X_CONTRACT_NUM_MODE
  ,   MANUAL_CONTRACT_NUM_TYPE  = X_MANUAL_CONTRACT_NUM_TYPE
  ,   NEXT_CONTRACT_NUM         = X_NEXT_CONTRACT_NUM
  ,   CONTRACT_NUM_INCREMENT    = X_CONTRACT_NUM_INCREMENT
  ,   CONTRACT_NUM_WIDTH        = X_CONTRACT_NUM_WIDTH
  ,   CHGREQ_NUM_MODE           = X_CHGREQ_NUM_MODE
  ,   MANUAL_CHGREQ_NUM_TYPE    = X_MANUAL_CHGREQ_NUM_TYPE
  ,   CHGREQ_NUM_START_NUMBER   = X_CHGREQ_NUM_START_NUMBER
  ,   CHGREQ_NUM_INCREMENT      = X_CHGREQ_NUM_INCREMENT
  ,   CHGREQ_NUM_WIDTH          = X_CHGREQ_NUM_WIDTH
  ,   LINE_NUM_START_NUMBER     = X_LINE_NUM_START_NUMBER
  ,   LINE_NUM_INCREMENT        = X_LINE_NUM_INCREMENT
  ,   LINE_NUM_WIDTH            = X_LINE_NUM_WIDTH
  ,   SUBLINE_NUM_START_NUMBER  = X_SUBLINE_NUM_START_NUMBER
  ,   SUBLINE_NUM_INCREMENT     = X_SUBLINE_NUM_INCREMENT
  ,   SUBLINE_NUM_WIDTH         = X_SUBLINE_NUM_WIDTH
  ,   DELV_NUM_START_NUMBER     = X_DELV_NUM_START_NUMBER
  ,   DELV_NUM_INCREMENT        = X_DELV_NUM_INCREMENT
  ,   DELV_NUM_WIDTH            = X_DELV_NUM_WIDTH
  ,   ATTRIBUTE_CATEGORY        = X_ATTRIBUTE_CATEGORY
  ,   ATTRIBUTE1                = X_ATTRIBUTE1
  ,   ATTRIBUTE2                = X_ATTRIBUTE2
  ,   ATTRIBUTE3                = X_ATTRIBUTE3
  ,   ATTRIBUTE4                = X_ATTRIBUTE4
  ,   ATTRIBUTE5                = X_ATTRIBUTE5
  ,   ATTRIBUTE6                = X_ATTRIBUTE6
  ,   ATTRIBUTE7                = X_ATTRIBUTE7
  ,   ATTRIBUTE8                = X_ATTRIBUTE8
  ,   ATTRIBUTE9                = X_ATTRIBUTE9
  ,   ATTRIBUTE10               = X_ATTRIBUTE10
  ,   ATTRIBUTE11               = X_ATTRIBUTE11
  ,   ATTRIBUTE12               = X_ATTRIBUTE12
  ,   ATTRIBUTE13               = X_ATTRIBUTE13
  ,   ATTRIBUTE14               = X_ATTRIBUTE14
  ,   ATTRIBUTE15               = X_ATTRIBUTE15
  WHERE K_TYPE_CODE = X_K_TYPE_CODE
  AND   BUY_OR_SELL = X_BUY_OR_SELL;

  IF ( sql%notfound ) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

END OKE_NUMBER_OPTIONS_PKG;

/