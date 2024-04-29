--------------------------------------------------------
--  DDL for Package Body EAM_CONSTRUCTION_ESTIMATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CONSTRUCTION_ESTIMATES_PKG" AS
/* $Header: EAMTCESB.pls 120.0.12010000.2 2008/12/09 21:08:03 devijay noship $ */
-- Start of Comments
-- Package name     : EAM_CONSTRUCTION_ESTIMATES_PKG
-- Purpose          : Body of package EAM_CONSTRUCTION_ESTIMATES_PKG
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'EAM_CONSTRUCTION_ESTIMATES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'EAMTCESB.pls';

PROCEDURE INSERT_ROW(
          px_ESTIMATE_ID            IN OUT NOCOPY NUMBER,
          p_ORGANIZATION_ID         NUMBER,
          p_ESTIMATE_NUMBER         VARCHAR2,
          p_ESTIMATE_DESCRIPTION    VARCHAR2,
          p_GROUPING_OPTION         NUMBER,
          p_PARENT_WO_ID            NUMBER,
          p_CREATE_PARENT_WO_FLAG   VARCHAR2,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_ATTRIBUTE_CATEGORY      VARCHAR2,
          p_ATTRIBUTE1              VARCHAR2,
          p_ATTRIBUTE2              VARCHAR2,
          p_ATTRIBUTE3              VARCHAR2,
          p_ATTRIBUTE4              VARCHAR2,
          p_ATTRIBUTE5              VARCHAR2,
          p_ATTRIBUTE6              VARCHAR2,
          p_ATTRIBUTE7              VARCHAR2,
          p_ATTRIBUTE8              VARCHAR2,
          p_ATTRIBUTE9              VARCHAR2,
          p_ATTRIBUTE10             VARCHAR2,
          p_ATTRIBUTE11             VARCHAR2,
          p_ATTRIBUTE12             VARCHAR2,
          p_ATTRIBUTE13             VARCHAR2,
          p_ATTRIBUTE14             VARCHAR2,
          p_ATTRIBUTE15             VARCHAR2
          )
IS
  CURSOR C IS SELECT EAM_CONSTRUCTION_ESTIMATES_S.NEXTVAL FROM SYS.DUAL;
BEGIN
  IF (px_ESTIMATE_ID IS NULL) OR (px_ESTIMATE_ID = FND_API.G_MISS_NUM) THEN
    OPEN C;
    FETCH C INTO px_ESTIMATE_ID;
    CLOSE C;
  END IF;
  INSERT INTO EAM_CONSTRUCTION_ESTIMATES(
    ESTIMATE_ID,
    ORGANIZATION_ID,
    ESTIMATE_NUMBER,
    ESTIMATE_DESCRIPTION,
    GROUPING_OPTION,
    PARENT_WO_ID,
    CREATE_PARENT_WO_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY    ,
    ATTRIBUTE1            ,
    ATTRIBUTE2            ,
    ATTRIBUTE3            ,
    ATTRIBUTE4            ,
    ATTRIBUTE5            ,
    ATTRIBUTE6            ,
    ATTRIBUTE7            ,
    ATTRIBUTE8            ,
    ATTRIBUTE9            ,
    ATTRIBUTE10           ,
    ATTRIBUTE11           ,
    ATTRIBUTE12           ,
    ATTRIBUTE13           ,
    ATTRIBUTE14           ,
    ATTRIBUTE15
  ) VALUES (
    px_ESTIMATE_ID,
    decode(p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
    decode(P_ESTIMATE_NUMBER, FND_API.G_MISS_CHAR, NULL, p_ESTIMATE_NUMBER),
    decode(p_ESTIMATE_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_ESTIMATE_DESCRIPTION),
    decode(p_GROUPING_OPTION, FND_API.G_MISS_NUM, NULL, p_GROUPING_OPTION),
    decode(p_PARENT_WO_ID, FND_API.G_MISS_NUM, NULL, p_PARENT_WO_ID),
    decode(p_CREATE_PARENT_WO_FLAG, FND_API.G_MISS_CHAR, NULL, p_CREATE_PARENT_WO_FLAG),
    decode(p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
    decode(p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
    decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
    decode(p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
    decode(p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
    decode(p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
    decode(p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
    decode(p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
    decode(p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
    decode(p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
    decode(p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
    decode(p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
    decode(p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
    decode(p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
    decode(p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
    decode(p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
    decode(p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
    decode(p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
    decode(p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
    decode(p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
    decode(p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
  );
END INSERT_ROW;

PROCEDURE UPDATE_ROW(
          p_ESTIMATE_ID             NUMBER,
          p_ORGANIZATION_ID         NUMBER,
          p_ESTIMATE_NUMBER         VARCHAR2,
          p_ESTIMATE_DESCRIPTION    VARCHAR2,
          p_GROUPING_OPTION         NUMBER,
          p_PARENT_WO_ID            NUMBER,
          p_CREATE_PARENT_WO_FLAG   VARCHAR2,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_ATTRIBUTE_CATEGORY      VARCHAR2,
          p_ATTRIBUTE1              VARCHAR2,
          p_ATTRIBUTE2              VARCHAR2,
          p_ATTRIBUTE3              VARCHAR2,
          p_ATTRIBUTE4              VARCHAR2,
          p_ATTRIBUTE5              VARCHAR2,
          p_ATTRIBUTE6              VARCHAR2,
          p_ATTRIBUTE7              VARCHAR2,
          p_ATTRIBUTE8              VARCHAR2,
          p_ATTRIBUTE9              VARCHAR2,
          p_ATTRIBUTE10             VARCHAR2,
          p_ATTRIBUTE11             VARCHAR2,
          p_ATTRIBUTE12             VARCHAR2,
          p_ATTRIBUTE13             VARCHAR2,
          p_ATTRIBUTE14             VARCHAR2,
          p_ATTRIBUTE15             VARCHAR2
          )
IS
BEGIN
  UPDATE EAM_CONSTRUCTION_ESTIMATES
  SET ORGANIZATION_ID       = decode(p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
      ESTIMATE_NUMBER       = decode(p_ESTIMATE_NUMBER, FND_API.G_MISS_CHAR, ESTIMATE_NUMBER, p_ESTIMATE_NUMBER),
      ESTIMATE_DESCRIPTION  = decode(p_ESTIMATE_DESCRIPTION, FND_API.G_MISS_CHAR, ESTIMATE_DESCRIPTION, p_ESTIMATE_DESCRIPTION),
      GROUPING_OPTION       = decode(p_GROUPING_OPTION, FND_API.G_MISS_NUM, GROUPING_OPTION, p_GROUPING_OPTION),
      PARENT_WO_ID          = decode(p_PARENT_WO_ID, FND_API.G_MISS_NUM, PARENT_WO_ID, p_PARENT_WO_ID),
      CREATE_PARENT_WO_FLAG = decode(p_CREATE_PARENT_WO_FLAG, FND_API.G_MISS_CHAR, CREATE_PARENT_WO_FLAG, p_CREATE_PARENT_WO_FLAG),
      CREATION_DATE         = decode(p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
      CREATED_BY            = decode(p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
      LAST_UPDATE_DATE      = decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
      LAST_UPDATED_BY       = decode(p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
      LAST_UPDATE_LOGIN     = decode(p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
      ATTRIBUTE_CATEGORY    = decode(p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
      ATTRIBUTE1            = decode(p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
      ATTRIBUTE2            = decode(p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
      ATTRIBUTE3            = decode(p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
      ATTRIBUTE4            = decode(p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
      ATTRIBUTE5            = decode(p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
      ATTRIBUTE6            = decode(p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
      ATTRIBUTE7            = decode(p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
      ATTRIBUTE8            = decode(p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
      ATTRIBUTE9            = decode(p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
      ATTRIBUTE10           = decode(p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
      ATTRIBUTE11           = decode(p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
      ATTRIBUTE12           = decode(p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
      ATTRIBUTE13           = decode(p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
      ATTRIBUTE14           = decode(p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
      ATTRIBUTE15           = decode(p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15)
  WHERE ESTIMATE_ID         = p_ESTIMATE_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;

PROCEDURE LOCK_ROW(
          p_ESTIMATE_ID             NUMBER,
          p_ORGANIZATION_ID         NUMBER,
          p_ESTIMATE_NUMBER         VARCHAR2,
          p_ESTIMATE_DESCRIPTION    VARCHAR2,
          p_GROUPING_OPTION         NUMBER,
          p_PARENT_WO_ID            NUMBER,
          p_CREATE_PARENT_WO_FLAG   VARCHAR2,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_ATTRIBUTE_CATEGORY      VARCHAR2,
          p_ATTRIBUTE1              VARCHAR2,
          p_ATTRIBUTE2              VARCHAR2,
          p_ATTRIBUTE3              VARCHAR2,
          p_ATTRIBUTE4              VARCHAR2,
          p_ATTRIBUTE5              VARCHAR2,
          p_ATTRIBUTE6              VARCHAR2,
          p_ATTRIBUTE7              VARCHAR2,
          p_ATTRIBUTE8              VARCHAR2,
          p_ATTRIBUTE9              VARCHAR2,
          p_ATTRIBUTE10             VARCHAR2,
          p_ATTRIBUTE11             VARCHAR2,
          p_ATTRIBUTE12             VARCHAR2,
          p_ATTRIBUTE13             VARCHAR2,
          p_ATTRIBUTE14             VARCHAR2,
          p_ATTRIBUTE15             VARCHAR2
          )
IS
  CURSOR C IS
    SELECT *
    FROM EAM_CONSTRUCTION_ESTIMATES
    WHERE ESTIMATE_ID =  p_ESTIMATE_ID
    FOR UPDATE OF ESTIMATE_ID NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;

  IF ((Recinfo.ESTIMATE_ID = p_ESTIMATE_ID)
    AND ((Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID) OR ((Recinfo.ORGANIZATION_ID IS NULL) AND (p_ORGANIZATION_ID IS NULL)))
    AND ((Recinfo.ESTIMATE_NUMBER = p_ESTIMATE_NUMBER) OR ((Recinfo.ESTIMATE_NUMBER IS NULL) AND (p_ESTIMATE_NUMBER IS NULL)))
    AND ((Recinfo.ESTIMATE_DESCRIPTION = p_ESTIMATE_DESCRIPTION) OR ((Recinfo.ESTIMATE_DESCRIPTION IS NULL) AND (p_ESTIMATE_DESCRIPTION IS NULL)))
    AND ((Recinfo.GROUPING_OPTION = p_GROUPING_OPTION) OR ((Recinfo.GROUPING_OPTION IS NULL) AND (p_GROUPING_OPTION IS NULL)))
    AND ((Recinfo.PARENT_WO_ID = p_PARENT_WO_ID) OR ((Recinfo.PARENT_WO_ID IS NULL) AND (p_PARENT_WO_ID IS NULL)))
    AND ((Recinfo.CREATE_PARENT_WO_FLAG = p_CREATE_PARENT_WO_FLAG) OR ((Recinfo.CREATE_PARENT_WO_FLAG IS NULL) AND (p_CREATE_PARENT_WO_FLAG IS NULL)))
    AND ((Recinfo.CREATION_DATE = p_CREATION_DATE) OR ((Recinfo.CREATION_DATE IS NULL) AND (p_CREATION_DATE IS NULL)))
    AND ((Recinfo.CREATED_BY = p_CREATED_BY) OR ((Recinfo.CREATED_BY IS NULL) AND (p_CREATED_BY IS NULL)))
    AND ((Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE) OR ((Recinfo.LAST_UPDATE_DATE IS NULL) AND (p_LAST_UPDATE_DATE IS NULL)))
    AND ((Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY) OR ((Recinfo.LAST_UPDATED_BY IS NULL) AND (p_LAST_UPDATED_BY IS NULL)))
    AND ((Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN) OR ((Recinfo.LAST_UPDATE_LOGIN IS NULL) AND (p_LAST_UPDATE_LOGIN IS NULL)))
    )
  THEN
    RETURN;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
END LOCK_ROW;

PROCEDURE DELETE_ROW(
          p_ESTIMATE_ID             NUMBER
          )
IS
BEGIN
  DELETE FROM EAM_CONSTRUCTION_ESTIMATES
  WHERE ESTIMATE_ID = p_ESTIMATE_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

END EAM_CONSTRUCTION_ESTIMATES_PKG;

/