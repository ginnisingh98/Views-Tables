--------------------------------------------------------
--  DDL for Package Body EAM_ESTIMATE_ASSOCIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ESTIMATE_ASSOCIATIONS_PKG" AS
/* $Header: EAMTESAB.pls 120.0.12010000.2 2008/12/24 02:31:52 devijay noship $ */
-- Start of Comments
-- Package name     : EAM_ESTIMATE_ASSOCIATIONS_PKG
-- Purpose          : Body of package EAM_ESTIMATE_ASSOCIATIONS_PKG
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'EAM_ESTIMATE_ASSOCIATIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'EAMTESAB.pls';

PROCEDURE INSERT_ROW(
          px_ESTIMATE_ASSOCIATION_ID  IN OUT NOCOPY NUMBER,
          p_ORGANIZATION_ID                         NUMBER,
          p_ESTIMATE_ID                             NUMBER,
          p_CU_ID                                   NUMBER,
          p_CU_QTY                                  NUMBER,
          p_ACCT_CLASS_CODE                         VARCHAR2,
          p_ACTIVITY_ID                             NUMBER,
          p_ACTIVITY_QTY                            NUMBER,
          p_DIFFICULTY_ID                           NUMBER,
          p_RESOURCE_MULTIPLIER                     NUMBER,
          p_CREATION_DATE                           DATE,
          p_CREATED_BY                              NUMBER,
          p_LAST_UPDATE_DATE                        DATE,
          p_LAST_UPDATED_BY                         NUMBER,
          p_LAST_UPDATE_LOGIN                       NUMBER
          )
IS
   CURSOR C IS SELECT EAM_ESTIMATE_ASSOCIATIONS_S.NEXTVAL FROM SYS.DUAL;
BEGIN
  IF (px_ESTIMATE_ASSOCIATION_ID IS NULL) OR (px_ESTIMATE_ASSOCIATION_ID = FND_API.G_MISS_NUM) THEN
    OPEN C;
    FETCH C INTO px_ESTIMATE_ASSOCIATION_ID;
    CLOSE C;
  END IF;
  INSERT INTO EAM_ESTIMATE_ASSOCIATIONS(
    ESTIMATE_ASSOCIATION_ID,
    ORGANIZATION_ID,
    ESTIMATE_ID,
    CU_ID,
    CU_QTY,
    ACCT_CLASS_CODE,
    ACTIVITY_ID,
    ACTIVITY_QTY,
    DIFFICULTY_ID,
    RESOURCE_MULTIPLIER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    px_ESTIMATE_ASSOCIATION_ID,
    decode(p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
    decode(P_ESTIMATE_ID, FND_API.G_MISS_NUM, NULL, p_ESTIMATE_ID),
    decode(p_CU_ID, FND_API.G_MISS_NUM, NULL, p_CU_ID),
    decode(p_CU_QTY, FND_API.G_MISS_NUM, NULL, p_CU_QTY),
    decode(p_ACCT_CLASS_CODE, FND_API.G_MISS_CHAR, NULL, p_ACCT_CLASS_CODE),
    decode(p_ACTIVITY_ID, FND_API.G_MISS_NUM, NULL, p_ACTIVITY_ID),
    decode(p_ACTIVITY_QTY, FND_API.G_MISS_NUM, NULL, p_ACTIVITY_QTY),
    decode(p_DIFFICULTY_ID, FND_API.G_MISS_NUM, NULL, p_DIFFICULTY_ID),
    decode(p_RESOURCE_MULTIPLIER, FND_API.G_MISS_NUM, NULL, p_RESOURCE_MULTIPLIER),
    decode(p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
    decode(p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
    decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
    decode(p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
    decode(p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
  );
END INSERT_ROW;

PROCEDURE UPDATE_ROW(
          p_ESTIMATE_ASSOCIATION_ID                 NUMBER,
          p_ORGANIZATION_ID                         NUMBER,
          p_ESTIMATE_ID                             NUMBER,
          p_CU_ID                                   NUMBER,
          p_CU_QTY                                  NUMBER,
          p_ACCT_CLASS_CODE                         VARCHAR2,
          p_ACTIVITY_ID                             NUMBER,
          p_ACTIVITY_QTY                            NUMBER,
          p_DIFFICULTY_ID                           NUMBER,
          p_RESOURCE_MULTIPLIER                     NUMBER,
          p_CREATION_DATE                           DATE,
          p_CREATED_BY                              NUMBER,
          p_LAST_UPDATE_DATE                        DATE,
          p_LAST_UPDATED_BY                         NUMBER,
          p_LAST_UPDATE_LOGIN                       NUMBER
          )
IS
BEGIN
  UPDATE EAM_ESTIMATE_ASSOCIATIONS
  SET ORGANIZATION_ID = decode(p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
      ESTIMATE_ID = decode(p_ESTIMATE_ID, FND_API.G_MISS_NUM, ESTIMATE_ID, p_ESTIMATE_ID),
      CU_ID = decode(p_CU_ID, FND_API.G_MISS_NUM, CU_ID, p_CU_ID),
      CU_QTY = decode(p_CU_QTY, FND_API.G_MISS_NUM, CU_QTY, p_CU_QTY),
      ACCT_CLASS_CODE = decode(p_ACCT_CLASS_CODE, FND_API.G_MISS_CHAR, ACCT_CLASS_CODE, p_ACCT_CLASS_CODE),
      ACTIVITY_ID = decode(p_ACTIVITY_ID, FND_API.G_MISS_NUM, ACTIVITY_ID, p_ACTIVITY_ID),
      ACTIVITY_QTY = decode(p_ACTIVITY_QTY, FND_API.G_MISS_NUM, ACTIVITY_QTY, p_ACTIVITY_QTY),
      DIFFICULTY_ID = decode(p_DIFFICULTY_ID, FND_API.G_MISS_NUM, DIFFICULTY_ID, p_DIFFICULTY_ID),
      RESOURCE_MULTIPLIER = decode(p_RESOURCE_MULTIPLIER, FND_API.G_MISS_NUM, RESOURCE_MULTIPLIER, p_RESOURCE_MULTIPLIER),
      CREATION_DATE = decode(p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
      CREATED_BY = decode(p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
      LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
      LAST_UPDATED_BY = decode(p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
      LAST_UPDATE_LOGIN = decode(p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
  WHERE ESTIMATE_ASSOCIATION_ID = p_ESTIMATE_ASSOCIATION_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;

PROCEDURE LOCK_ROW(
          p_ESTIMATE_ASSOCIATION_ID                 NUMBER,
          p_ORGANIZATION_ID                         NUMBER,
          p_ESTIMATE_ID                             NUMBER,
          p_CU_ID                                   NUMBER,
          p_CU_QTY                                  NUMBER,
          p_ACCT_CLASS_CODE                         VARCHAR2,
          p_ACTIVITY_ID                             NUMBER,
          p_ACTIVITY_QTY                            NUMBER,
          p_DIFFICULTY_ID                           NUMBER,
          p_RESOURCE_MULTIPLIER                     NUMBER,
          p_CREATION_DATE                           DATE,
          p_CREATED_BY                              NUMBER,
          p_LAST_UPDATE_DATE                        DATE,
          p_LAST_UPDATED_BY                         NUMBER,
          p_LAST_UPDATE_LOGIN                       NUMBER
          )
IS
  CURSOR C IS
    SELECT *
    FROM EAM_ESTIMATE_ASSOCIATIONS
    WHERE ESTIMATE_ASSOCIATION_ID =  p_ESTIMATE_ASSOCIATION_ID
    FOR UPDATE OF ESTIMATE_ASSOCIATION_ID NOWAIT;
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

  IF ((Recinfo.ESTIMATE_ASSOCIATION_ID = p_ESTIMATE_ASSOCIATION_ID)
    AND ((Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID) OR ((Recinfo.ORGANIZATION_ID IS NULL) AND (p_ORGANIZATION_ID IS NULL)))
    AND ((Recinfo.ESTIMATE_ID = p_ESTIMATE_ID) OR ((Recinfo.ESTIMATE_ID IS NULL) AND (p_ESTIMATE_ID IS NULL)))
    AND ((Recinfo.CU_ID = p_CU_ID) OR ((Recinfo.CU_ID IS NULL) AND (p_CU_ID IS NULL)))
    AND ((Recinfo.CU_QTY = p_CU_QTY) OR ((Recinfo.CU_QTY IS NULL) AND (p_CU_QTY IS NULL)))
    AND ((Recinfo.ACCT_CLASS_CODE = p_ACCT_CLASS_CODE) OR ((Recinfo.ACCT_CLASS_CODE IS NULL) AND (p_ACCT_CLASS_CODE IS NULL)))
    AND ((Recinfo.ACTIVITY_ID = p_ACTIVITY_ID) OR ((Recinfo.ACTIVITY_ID IS NULL) AND (p_ACTIVITY_ID IS NULL)))
    AND ((Recinfo.ACTIVITY_QTY = p_ACTIVITY_QTY) OR ((Recinfo.ACTIVITY_QTY IS NULL) AND (p_ACTIVITY_QTY IS NULL)))
    AND ((Recinfo.DIFFICULTY_ID = p_DIFFICULTY_ID) OR ((Recinfo.DIFFICULTY_ID IS NULL) AND (p_DIFFICULTY_ID IS NULL)))
    AND ((Recinfo.RESOURCE_MULTIPLIER = p_RESOURCE_MULTIPLIER) OR ((Recinfo.RESOURCE_MULTIPLIER IS NULL) AND (p_RESOURCE_MULTIPLIER IS NULL)))
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
          p_ESTIMATE_ASSOCIATION_ID                 NUMBER
          )
IS
BEGIN
  DELETE FROM EAM_ESTIMATE_ASSOCIATIONS
  WHERE ESTIMATE_ASSOCIATION_ID = p_ESTIMATE_ASSOCIATION_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

END EAM_ESTIMATE_ASSOCIATIONS_PKG;

/
