--------------------------------------------------------
--  DDL for Package Body OKE_K_USER_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_USER_ATTRIBUTES_PKG" AS
/* $Header: OKEKUATB.pls 115.5 2002/11/20 20:28:54 who ship $ */
PROCEDURE INSERT_ROW
( X_ROWID                   IN OUT NOCOPY   VARCHAR2
, X_K_USER_ATTRIBUTE_ID     IN OUT NOCOPY   NUMBER
, X_RECORD_VERSION_NUMBER   IN OUT NOCOPY   NUMBER
, X_CREATION_DATE           IN        DATE
, X_CREATED_BY              IN        NUMBER
, X_LAST_UPDATE_DATE        IN        DATE
, X_LAST_UPDATED_BY         IN        NUMBER
, X_LAST_UPDATE_LOGIN       IN        NUMBER
, X_K_HEADER_ID             IN        NUMBER
, X_K_LINE_ID               IN        NUMBER
, X_USER_ATTRIBUTE_CONTEXT  IN        VARCHAR2
, X_USER_ATTRIBUTE01        IN        VARCHAR2
, X_USER_ATTRIBUTE02        IN        VARCHAR2
, X_USER_ATTRIBUTE03        IN        VARCHAR2
, X_USER_ATTRIBUTE04        IN        VARCHAR2
, X_USER_ATTRIBUTE05        IN        VARCHAR2
, X_USER_ATTRIBUTE06        IN        VARCHAR2
, X_USER_ATTRIBUTE07        IN        VARCHAR2
, X_USER_ATTRIBUTE08        IN        VARCHAR2
, X_USER_ATTRIBUTE09        IN        VARCHAR2
, X_USER_ATTRIBUTE10        IN        VARCHAR2
, X_USER_ATTRIBUTE11        IN        VARCHAR2
, X_USER_ATTRIBUTE12        IN        VARCHAR2
, X_USER_ATTRIBUTE13        IN        VARCHAR2
, X_USER_ATTRIBUTE14        IN        VARCHAR2
, X_USER_ATTRIBUTE15        IN        VARCHAR2
, X_USER_ATTRIBUTE16        IN        VARCHAR2
, X_USER_ATTRIBUTE17        IN        VARCHAR2
, X_USER_ATTRIBUTE18        IN        VARCHAR2
, X_USER_ATTRIBUTE19        IN        VARCHAR2
, X_USER_ATTRIBUTE20        IN        VARCHAR2
, X_USER_ATTRIBUTE21        IN        VARCHAR2
, X_USER_ATTRIBUTE22        IN        VARCHAR2
, X_USER_ATTRIBUTE23        IN        VARCHAR2
, X_USER_ATTRIBUTE24        IN        VARCHAR2
, X_USER_ATTRIBUTE25        IN        VARCHAR2
, X_USER_ATTRIBUTE26        IN        VARCHAR2
, X_USER_ATTRIBUTE27        IN        VARCHAR2
, X_USER_ATTRIBUTE28        IN        VARCHAR2
, X_USER_ATTRIBUTE29        IN        VARCHAR2
, X_USER_ATTRIBUTE30        IN        VARCHAR2
) IS

  CURSOR c IS
    SELECT rowid
    FROM   oke_k_user_attributes
    WHERE  k_user_attribute_id = X_K_USER_ATTRIBUTE_ID;

BEGIN

  SELECT oke_k_user_attributes_s.nextval
  ,      1
  INTO   X_K_USER_ATTRIBUTE_ID
  ,      X_RECORD_VERSION_NUMBER
  FROM   dual;

  INSERT INTO oke_k_user_attributes
  ( K_USER_ATTRIBUTE_ID
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , RECORD_VERSION_NUMBER
  , K_HEADER_ID
  , K_LINE_ID
  , USER_ATTRIBUTE_CONTEXT
  , USER_ATTRIBUTE01
  , USER_ATTRIBUTE02
  , USER_ATTRIBUTE03
  , USER_ATTRIBUTE04
  , USER_ATTRIBUTE05
  , USER_ATTRIBUTE06
  , USER_ATTRIBUTE07
  , USER_ATTRIBUTE08
  , USER_ATTRIBUTE09
  , USER_ATTRIBUTE10
  , USER_ATTRIBUTE11
  , USER_ATTRIBUTE12
  , USER_ATTRIBUTE13
  , USER_ATTRIBUTE14
  , USER_ATTRIBUTE15
  , USER_ATTRIBUTE16
  , USER_ATTRIBUTE17
  , USER_ATTRIBUTE18
  , USER_ATTRIBUTE19
  , USER_ATTRIBUTE20
  , USER_ATTRIBUTE21
  , USER_ATTRIBUTE22
  , USER_ATTRIBUTE23
  , USER_ATTRIBUTE24
  , USER_ATTRIBUTE25
  , USER_ATTRIBUTE26
  , USER_ATTRIBUTE27
  , USER_ATTRIBUTE28
  , USER_ATTRIBUTE29
  , USER_ATTRIBUTE30
  ) VALUES
  ( X_K_USER_ATTRIBUTE_ID
  , X_CREATION_DATE
  , X_CREATED_BY
  , X_LAST_UPDATE_DATE
  , X_LAST_UPDATED_BY
  , X_LAST_UPDATE_LOGIN
  , X_RECORD_VERSION_NUMBER
  , X_K_HEADER_ID
  , X_K_LINE_ID
  , X_USER_ATTRIBUTE_CONTEXT
  , X_USER_ATTRIBUTE01
  , X_USER_ATTRIBUTE02
  , X_USER_ATTRIBUTE03
  , X_USER_ATTRIBUTE04
  , X_USER_ATTRIBUTE05
  , X_USER_ATTRIBUTE06
  , X_USER_ATTRIBUTE07
  , X_USER_ATTRIBUTE08
  , X_USER_ATTRIBUTE09
  , X_USER_ATTRIBUTE10
  , X_USER_ATTRIBUTE11
  , X_USER_ATTRIBUTE12
  , X_USER_ATTRIBUTE13
  , X_USER_ATTRIBUTE14
  , X_USER_ATTRIBUTE15
  , X_USER_ATTRIBUTE16
  , X_USER_ATTRIBUTE17
  , X_USER_ATTRIBUTE18
  , X_USER_ATTRIBUTE19
  , X_USER_ATTRIBUTE20
  , X_USER_ATTRIBUTE21
  , X_USER_ATTRIBUTE22
  , X_USER_ATTRIBUTE23
  , X_USER_ATTRIBUTE24
  , X_USER_ATTRIBUTE25
  , X_USER_ATTRIBUTE26
  , X_USER_ATTRIBUTE27
  , X_USER_ATTRIBUTE28
  , X_USER_ATTRIBUTE29
  , X_USER_ATTRIBUTE30
  );

  OPEN c;
  FETCH c INTO X_ROWID;
  IF ( c%notfound ) THEN
    CLOSE c;
    RAISE no_data_found;
  END IF;
  CLOSE c;

END INSERT_ROW;


PROCEDURE LOCK_ROW
( X_ROWID                   IN        VARCHAR2
, X_RECORD_VERSION_NUMBER   IN        NUMBER
) IS

  CURSOR c IS
    SELECT record_version_number
    FROM   oke_k_user_attributes
    WHERE  ROWID = X_rowid
    FOR UPDATE OF record_version_number NOWAIT;
  RecInfo c%rowtype;

BEGIN

  OPEN c;
  FETCH c INTO RecInfo;
  IF ( c%notfound ) THEN
    CLOSE c;
    FND_MESSAGE.SET_NAME('FND' , 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE c;

  IF ( RecInfo.Record_Version_Number <> X_RECORD_VERSION_NUMBER ) THEN
    FND_MESSAGE.SET_NAME('FND' , 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  RETURN;

END LOCK_ROW;


PROCEDURE UPDATE_ROW
( X_K_USER_ATTRIBUTE_ID     IN        NUMBER
, X_RECORD_VERSION_NUMBER   IN OUT NOCOPY   NUMBER
, X_LAST_UPDATE_DATE        IN        DATE
, X_LAST_UPDATED_BY         IN        NUMBER
, X_LAST_UPDATE_LOGIN       IN        NUMBER
, X_K_HEADER_ID             IN        NUMBER
, X_K_LINE_ID               IN        NUMBER
, X_USER_ATTRIBUTE_CONTEXT  IN        VARCHAR2
, X_USER_ATTRIBUTE01        IN        VARCHAR2
, X_USER_ATTRIBUTE02        IN        VARCHAR2
, X_USER_ATTRIBUTE03        IN        VARCHAR2
, X_USER_ATTRIBUTE04        IN        VARCHAR2
, X_USER_ATTRIBUTE05        IN        VARCHAR2
, X_USER_ATTRIBUTE06        IN        VARCHAR2
, X_USER_ATTRIBUTE07        IN        VARCHAR2
, X_USER_ATTRIBUTE08        IN        VARCHAR2
, X_USER_ATTRIBUTE09        IN        VARCHAR2
, X_USER_ATTRIBUTE10        IN        VARCHAR2
, X_USER_ATTRIBUTE11        IN        VARCHAR2
, X_USER_ATTRIBUTE12        IN        VARCHAR2
, X_USER_ATTRIBUTE13        IN        VARCHAR2
, X_USER_ATTRIBUTE14        IN        VARCHAR2
, X_USER_ATTRIBUTE15        IN        VARCHAR2
, X_USER_ATTRIBUTE16        IN        VARCHAR2
, X_USER_ATTRIBUTE17        IN        VARCHAR2
, X_USER_ATTRIBUTE18        IN        VARCHAR2
, X_USER_ATTRIBUTE19        IN        VARCHAR2
, X_USER_ATTRIBUTE20        IN        VARCHAR2
, X_USER_ATTRIBUTE21        IN        VARCHAR2
, X_USER_ATTRIBUTE22        IN        VARCHAR2
, X_USER_ATTRIBUTE23        IN        VARCHAR2
, X_USER_ATTRIBUTE24        IN        VARCHAR2
, X_USER_ATTRIBUTE25        IN        VARCHAR2
, X_USER_ATTRIBUTE26        IN        VARCHAR2
, X_USER_ATTRIBUTE27        IN        VARCHAR2
, X_USER_ATTRIBUTE28        IN        VARCHAR2
, X_USER_ATTRIBUTE29        IN        VARCHAR2
, X_USER_ATTRIBUTE30        IN        VARCHAR2
) IS

BEGIN

  UPDATE oke_k_user_attributes
  SET K_USER_ATTRIBUTE_ID     = X_K_USER_ATTRIBUTE_ID
  ,   LAST_UPDATE_DATE        = X_LAST_UPDATE_DATE
  ,   LAST_UPDATED_BY         = X_LAST_UPDATED_BY
  ,   LAST_UPDATE_LOGIN       = X_LAST_UPDATE_LOGIN
  ,   RECORD_VERSION_NUMBER   = X_RECORD_VERSION_NUMBER + 1
  ,   K_HEADER_ID             = X_K_HEADER_ID
  ,   K_LINE_ID               = X_K_LINE_ID
  ,   USER_ATTRIBUTE_CONTEXT  = X_USER_ATTRIBUTE_CONTEXT
  ,   USER_ATTRIBUTE01        = X_USER_ATTRIBUTE01
  ,   USER_ATTRIBUTE02        = X_USER_ATTRIBUTE02
  ,   USER_ATTRIBUTE03        = X_USER_ATTRIBUTE03
  ,   USER_ATTRIBUTE04        = X_USER_ATTRIBUTE04
  ,   USER_ATTRIBUTE05        = X_USER_ATTRIBUTE05
  ,   USER_ATTRIBUTE06        = X_USER_ATTRIBUTE06
  ,   USER_ATTRIBUTE07        = X_USER_ATTRIBUTE07
  ,   USER_ATTRIBUTE08        = X_USER_ATTRIBUTE08
  ,   USER_ATTRIBUTE09        = X_USER_ATTRIBUTE09
  ,   USER_ATTRIBUTE10        = X_USER_ATTRIBUTE10
  ,   USER_ATTRIBUTE11        = X_USER_ATTRIBUTE11
  ,   USER_ATTRIBUTE12        = X_USER_ATTRIBUTE12
  ,   USER_ATTRIBUTE13        = X_USER_ATTRIBUTE13
  ,   USER_ATTRIBUTE14        = X_USER_ATTRIBUTE14
  ,   USER_ATTRIBUTE15        = X_USER_ATTRIBUTE15
  ,   USER_ATTRIBUTE16        = X_USER_ATTRIBUTE16
  ,   USER_ATTRIBUTE17        = X_USER_ATTRIBUTE17
  ,   USER_ATTRIBUTE18        = X_USER_ATTRIBUTE18
  ,   USER_ATTRIBUTE19        = X_USER_ATTRIBUTE19
  ,   USER_ATTRIBUTE20        = X_USER_ATTRIBUTE20
  ,   USER_ATTRIBUTE21        = X_USER_ATTRIBUTE21
  ,   USER_ATTRIBUTE22        = X_USER_ATTRIBUTE22
  ,   USER_ATTRIBUTE23        = X_USER_ATTRIBUTE23
  ,   USER_ATTRIBUTE24        = X_USER_ATTRIBUTE24
  ,   USER_ATTRIBUTE25        = X_USER_ATTRIBUTE25
  ,   USER_ATTRIBUTE26        = X_USER_ATTRIBUTE26
  ,   USER_ATTRIBUTE27        = X_USER_ATTRIBUTE27
  ,   USER_ATTRIBUTE28        = X_USER_ATTRIBUTE28
  ,   USER_ATTRIBUTE29        = X_USER_ATTRIBUTE29
  ,   USER_ATTRIBUTE30        = X_USER_ATTRIBUTE30
  WHERE k_user_attribute_id = X_K_USER_ATTRIBUTE_ID;

  IF ( sql%notfound ) THEN
    RAISE no_data_found;
  END IF;

  X_RECORD_VERSION_NUMBER := X_RECORD_VERSION_NUMBER + 1;

END UPDATE_ROW;


PROCEDURE DELETE_ROW (
  X_K_USER_ATTRIBUTE_ID     IN        NUMBER
) IS

BEGIN

  DELETE FROM oke_k_user_attributes
  WHERE k_user_attribute_id = X_K_USER_ATTRIBUTE_ID;

  IF ( sql%notfound ) THEN
    RAISE no_data_found;
  END IF;

END DELETE_ROW;

END OKE_K_USER_ATTRIBUTES_PKG;

/
