--------------------------------------------------------
--  DDL for Package Body GMD_TECH_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_TECH_PARAMETERS_PKG" AS
/* $Header: GMDTCPMB.pls 120.3 2005/11/16 05:44:22 srsriran noship $ */

PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_TECH_PARM_ID IN NUMBER,
  X_QCASSY_TYP_ID IN NUMBER,
  X_LAB_TYPE IN VARCHAR2,
  X_TECH_PARM_NAME IN VARCHAR2,
  X_DATA_TYPE IN NUMBER,
  X_SIGNIF_FIGURES IN NUMBER,
  X_LOWERBOUND_NUM IN NUMBER,
  X_UPPERBOUND_NUM IN NUMBER,
  X_LOWERBOUND_CHAR IN VARCHAR2,
  X_UPPERBOUND_CHAR IN VARCHAR2,
  X_MAX_LENGTH IN NUMBER,
  X_EXPRESSION_CHAR IN VARCHAR2,
  X_COST_SOURCE IN NUMBER,
  X_COST_TYPE IN VARCHAR2,
  X_COST_FUNCTION IN VARCHAR2,
  X_DEFAULT_COST_PARAMETER IN NUMBER,
  X_LM_UNIT_CODE IN VARCHAR2,
  X_DELETE_MARK IN NUMBER,
  X_TEXT_CODE IN NUMBER,
  X_IN_USE IN NUMBER,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  X_ATTRIBUTE20 IN VARCHAR2,
  X_ATTRIBUTE21 IN VARCHAR2,
  X_ATTRIBUTE22 IN VARCHAR2,
  X_ATTRIBUTE23 IN VARCHAR2,
  X_ATTRIBUTE24 IN VARCHAR2,
  X_ATTRIBUTE25 IN VARCHAR2,
  X_ATTRIBUTE26 IN VARCHAR2,
  X_ATTRIBUTE27 IN VARCHAR2,
  X_ATTRIBUTE28 IN VARCHAR2,
  X_ATTRIBUTE29 IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE30 IN VARCHAR2,
  X_ORGANIZATION_ID IN NUMBER,
  X_PARM_DESCRIPTION IN VARCHAR2,
  X_CREATION_DATE IN DATE,
  X_CREATED_BY IN NUMBER,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
) IS
 L_TECH_PARM_ID NUMBER;
  CURSOR C IS SELECT ROWID FROM GMD_TECH_PARAMETERS_B
    WHERE TECH_PARM_ID = L_TECH_PARM_ID
    ;

BEGIN

  IF (X_TECH_PARM_ID IS NULL) THEN
     SELECT GMD_TECH_PARM_ID_S.NEXTVAL INTO L_TECH_PARM_ID
     FROM SYS.DUAL;
  ELSE
     L_TECH_PARM_ID := X_TECH_PARM_ID;
  END IF;

  INSERT INTO GMD_TECH_PARAMETERS_B (
    TECH_PARM_ID,
    QCASSY_TYP_ID,
    LAB_TYPE,
    TECH_PARM_NAME,
    DATA_TYPE,
    SIGNIF_FIGURES,
    LOWERBOUND_NUM,
    UPPERBOUND_NUM,
    LOWERBOUND_CHAR,
    UPPERBOUND_CHAR,
    MAX_LENGTH,
    EXPRESSION_CHAR,
    COST_SOURCE,
    COST_TYPE,
    COST_FUNCTION,
    DEFAULT_COST_PARAMETER,
    LM_UNIT_CODE,
    DELETE_MARK,
    TEXT_CODE,
    IN_USE,
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
    ATTRIBUTE25,
    ATTRIBUTE26,
    ATTRIBUTE27,
    ATTRIBUTE28,
    ATTRIBUTE29,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE30,
    ORGANIZATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    l_TECH_PARM_ID,
    X_QCASSY_TYP_ID,
    X_LAB_TYPE,
    X_TECH_PARM_NAME,
    X_DATA_TYPE,
    X_SIGNIF_FIGURES,
    X_LOWERBOUND_NUM,
    X_UPPERBOUND_NUM,
    X_LOWERBOUND_CHAR,
    X_UPPERBOUND_CHAR,
    X_MAX_LENGTH,
    X_EXPRESSION_CHAR,
    X_COST_SOURCE,
    X_COST_TYPE,
    X_COST_FUNCTION,
    X_DEFAULT_COST_PARAMETER,
    X_LM_UNIT_CODE,
    X_DELETE_MARK,
    X_TEXT_CODE,
    X_IN_USE,
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
    X_ATTRIBUTE25,
    X_ATTRIBUTE26,
    X_ATTRIBUTE27,
    X_ATTRIBUTE28,
    X_ATTRIBUTE29,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE30,
    X_ORGANIZATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  INSERT INTO GMD_TECH_PARAMETERS_TL (
    TECH_PARM_ID,
    TECH_PARM_NAME,
    PARM_DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    L_TECH_PARM_ID,
    X_TECH_PARM_NAME,
    X_PARM_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    USERENV('LANG')
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM GMD_TECH_PARAMETERS_TL T
    WHERE T.TECH_PARM_ID = L_TECH_PARM_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);

  OPEN C;
  FETCH C INTO X_ROWID;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_TECH_PARM_ID IN NUMBER,
  X_QCASSY_TYP_ID IN NUMBER,
  X_LAB_TYPE IN VARCHAR2,
  X_TECH_PARM_NAME IN VARCHAR2,
  X_DATA_TYPE IN NUMBER,
  X_SIGNIF_FIGURES IN NUMBER,
  X_LOWERBOUND_NUM IN NUMBER,
  X_UPPERBOUND_NUM IN NUMBER,
  X_LOWERBOUND_CHAR IN VARCHAR2,
  X_UPPERBOUND_CHAR IN VARCHAR2,
  X_MAX_LENGTH IN NUMBER,
  X_EXPRESSION_CHAR IN VARCHAR2,
  X_COST_SOURCE IN NUMBER,
  X_COST_TYPE IN VARCHAR2,
  X_COST_FUNCTION IN VARCHAR2,
  X_DEFAULT_COST_PARAMETER IN NUMBER,
  X_LM_UNIT_CODE IN VARCHAR2,
  X_DELETE_MARK IN NUMBER,
  X_TEXT_CODE IN NUMBER,
  X_IN_USE IN NUMBER,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  X_ATTRIBUTE20 IN VARCHAR2,
  X_ATTRIBUTE21 IN VARCHAR2,
  X_ATTRIBUTE22 IN VARCHAR2,
  X_ATTRIBUTE23 IN VARCHAR2,
  X_ATTRIBUTE24 IN VARCHAR2,
  X_ATTRIBUTE25 IN VARCHAR2,
  X_ATTRIBUTE26 IN VARCHAR2,
  X_ATTRIBUTE27 IN VARCHAR2,
  X_ATTRIBUTE28 IN VARCHAR2,
  X_ATTRIBUTE29 IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE30 IN VARCHAR2,
  X_ORGANIZATION_ID IN NUMBER,
  X_PARM_DESCRIPTION IN VARCHAR2
) IS
  CURSOR C IS SELECT
      QCASSY_TYP_ID,
      LAB_TYPE,
      TECH_PARM_NAME,
      DATA_TYPE,
      SIGNIF_FIGURES,
      LOWERBOUND_NUM,
      UPPERBOUND_NUM,
      LOWERBOUND_CHAR,
      UPPERBOUND_CHAR,
      MAX_LENGTH,
      EXPRESSION_CHAR,
      COST_SOURCE,
      COST_TYPE,
      COST_FUNCTION,
      DEFAULT_COST_PARAMETER,
      LM_UNIT_CODE,
      DELETE_MARK,
      TEXT_CODE,
      IN_USE,
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
      ATTRIBUTE25,
      ATTRIBUTE26,
      ATTRIBUTE27,
      ATTRIBUTE28,
      ATTRIBUTE29,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE30,
      ORGANIZATION_ID
    FROM GMD_TECH_PARAMETERS_B
    WHERE TECH_PARM_ID = X_TECH_PARM_ID
    FOR UPDATE OF TECH_PARM_ID NOWAIT;
  RECINFO C%ROWTYPE;

  CURSOR C1 IS SELECT
      PARM_DESCRIPTION,
      DECODE(LANGUAGE, USERENV('LANG'), 'Y', 'N') BASELANG
    FROM GMD_TECH_PARAMETERS_TL
    WHERE TECH_PARM_ID = X_TECH_PARM_ID
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
    FOR UPDATE OF TECH_PARM_ID NOWAIT;
BEGIN
  OPEN C;
  FETCH C INTO RECINFO;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;
  IF (    ((RECINFO.QCASSY_TYP_ID = X_QCASSY_TYP_ID)
           OR ((RECINFO.QCASSY_TYP_ID IS NULL) AND (X_QCASSY_TYP_ID IS NULL)))
      AND ((RECINFO.LAB_TYPE = X_LAB_TYPE)
           OR ((RECINFO.LAB_TYPE IS NULL) AND (X_LAB_TYPE IS NULL)))
      AND (RECINFO.TECH_PARM_NAME = X_TECH_PARM_NAME)
      AND (RECINFO.DATA_TYPE = X_DATA_TYPE)
      AND ((RECINFO.SIGNIF_FIGURES = X_SIGNIF_FIGURES)
           OR ((RECINFO.SIGNIF_FIGURES IS NULL) AND (X_SIGNIF_FIGURES IS NULL)))
      AND ((RECINFO.LOWERBOUND_NUM = X_LOWERBOUND_NUM)
           OR ((RECINFO.LOWERBOUND_NUM IS NULL) AND (X_LOWERBOUND_NUM IS NULL)))
      AND ((RECINFO.UPPERBOUND_NUM = X_UPPERBOUND_NUM)
           OR ((RECINFO.UPPERBOUND_NUM IS NULL) AND (X_UPPERBOUND_NUM IS NULL)))
      AND ((RECINFO.LOWERBOUND_CHAR = X_LOWERBOUND_CHAR)
           OR ((RECINFO.LOWERBOUND_CHAR IS NULL) AND (X_LOWERBOUND_CHAR IS NULL)))
      AND ((RECINFO.UPPERBOUND_CHAR = X_UPPERBOUND_CHAR)
           OR ((RECINFO.UPPERBOUND_CHAR IS NULL) AND (X_UPPERBOUND_CHAR IS NULL)))
      AND ((RECINFO.MAX_LENGTH = X_MAX_LENGTH)
           OR ((RECINFO.MAX_LENGTH IS NULL) AND (X_MAX_LENGTH IS NULL)))
      AND ((RECINFO.EXPRESSION_CHAR = X_EXPRESSION_CHAR)
           OR ((RECINFO.EXPRESSION_CHAR IS NULL) AND (X_EXPRESSION_CHAR IS NULL)))
      AND ((RECINFO.COST_SOURCE = X_COST_SOURCE)
           OR ((RECINFO.COST_SOURCE IS NULL) AND (X_COST_SOURCE IS NULL)))
      AND ((RECINFO.COST_TYPE = X_COST_TYPE)
           OR ((RECINFO.COST_TYPE IS NULL) AND (X_COST_TYPE IS NULL)))
      AND ((RECINFO.COST_FUNCTION = X_COST_FUNCTION)
           OR ((RECINFO.COST_FUNCTION IS NULL) AND (X_COST_FUNCTION IS NULL)))
      AND ((RECINFO.DEFAULT_COST_PARAMETER = X_DEFAULT_COST_PARAMETER)
           OR ((RECINFO.DEFAULT_COST_PARAMETER IS NULL) AND (X_DEFAULT_COST_PARAMETER IS NULL)))
      AND ((RECINFO.LM_UNIT_CODE = X_LM_UNIT_CODE)
           OR ((RECINFO.LM_UNIT_CODE IS NULL) AND (X_LM_UNIT_CODE IS NULL)))
      AND (RECINFO.DELETE_MARK = X_DELETE_MARK)
      AND ((RECINFO.TEXT_CODE = X_TEXT_CODE)
           OR ((RECINFO.TEXT_CODE IS NULL) AND (X_TEXT_CODE IS NULL)))
      AND ((RECINFO.IN_USE = X_IN_USE)
           OR ((RECINFO.IN_USE IS NULL) AND (X_IN_USE IS NULL)))
      AND ((RECINFO.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((RECINFO.ATTRIBUTE1 IS NULL) AND (X_ATTRIBUTE1 IS NULL)))
      AND ((RECINFO.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((RECINFO.ATTRIBUTE2 IS NULL) AND (X_ATTRIBUTE2 IS NULL)))
      AND ((RECINFO.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((RECINFO.ATTRIBUTE3 IS NULL) AND (X_ATTRIBUTE3 IS NULL)))
      AND ((RECINFO.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((RECINFO.ATTRIBUTE4 IS NULL) AND (X_ATTRIBUTE4 IS NULL)))
      AND ((RECINFO.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((RECINFO.ATTRIBUTE5 IS NULL) AND (X_ATTRIBUTE5 IS NULL)))
      AND ((RECINFO.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((RECINFO.ATTRIBUTE6 IS NULL) AND (X_ATTRIBUTE6 IS NULL)))
      AND ((RECINFO.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((RECINFO.ATTRIBUTE7 IS NULL) AND (X_ATTRIBUTE7 IS NULL)))
      AND ((RECINFO.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((RECINFO.ATTRIBUTE8 IS NULL) AND (X_ATTRIBUTE8 IS NULL)))
      AND ((RECINFO.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((RECINFO.ATTRIBUTE9 IS NULL) AND (X_ATTRIBUTE9 IS NULL)))
      AND ((RECINFO.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((RECINFO.ATTRIBUTE10 IS NULL) AND (X_ATTRIBUTE10 IS NULL)))
      AND ((RECINFO.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((RECINFO.ATTRIBUTE11 IS NULL) AND (X_ATTRIBUTE11 IS NULL)))
      AND ((RECINFO.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((RECINFO.ATTRIBUTE12 IS NULL) AND (X_ATTRIBUTE12 IS NULL)))
      AND ((RECINFO.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((RECINFO.ATTRIBUTE13 IS NULL) AND (X_ATTRIBUTE13 IS NULL)))
      AND ((RECINFO.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((RECINFO.ATTRIBUTE14 IS NULL) AND (X_ATTRIBUTE14 IS NULL)))
      AND ((RECINFO.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((RECINFO.ATTRIBUTE15 IS NULL) AND (X_ATTRIBUTE15 IS NULL)))
      AND ((RECINFO.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((RECINFO.ATTRIBUTE16 IS NULL) AND (X_ATTRIBUTE16 IS NULL)))
      AND ((RECINFO.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR ((RECINFO.ATTRIBUTE17 IS NULL) AND (X_ATTRIBUTE17 IS NULL)))
      AND ((RECINFO.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR ((RECINFO.ATTRIBUTE18 IS NULL) AND (X_ATTRIBUTE18 IS NULL)))
      AND ((RECINFO.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR ((RECINFO.ATTRIBUTE19 IS NULL) AND (X_ATTRIBUTE19 IS NULL)))
      AND ((RECINFO.ATTRIBUTE20 = X_ATTRIBUTE20)
           OR ((RECINFO.ATTRIBUTE20 IS NULL) AND (X_ATTRIBUTE20 IS NULL)))
      AND ((RECINFO.ATTRIBUTE21 = X_ATTRIBUTE21)
           OR ((RECINFO.ATTRIBUTE21 IS NULL) AND (X_ATTRIBUTE21 IS NULL)))
      AND ((RECINFO.ATTRIBUTE22 = X_ATTRIBUTE22)
           OR ((RECINFO.ATTRIBUTE22 IS NULL) AND (X_ATTRIBUTE22 IS NULL)))
      AND ((RECINFO.ATTRIBUTE23 = X_ATTRIBUTE23)
           OR ((RECINFO.ATTRIBUTE23 IS NULL) AND (X_ATTRIBUTE23 IS NULL)))
      AND ((RECINFO.ATTRIBUTE24 = X_ATTRIBUTE24)
           OR ((RECINFO.ATTRIBUTE24 IS NULL) AND (X_ATTRIBUTE24 IS NULL)))
      AND ((RECINFO.ATTRIBUTE25 = X_ATTRIBUTE25)
           OR ((RECINFO.ATTRIBUTE25 IS NULL) AND (X_ATTRIBUTE25 IS NULL)))
      AND ((RECINFO.ATTRIBUTE26 = X_ATTRIBUTE26)
           OR ((RECINFO.ATTRIBUTE26 IS NULL) AND (X_ATTRIBUTE26 IS NULL)))
      AND ((RECINFO.ATTRIBUTE27 = X_ATTRIBUTE27)
           OR ((RECINFO.ATTRIBUTE27 IS NULL) AND (X_ATTRIBUTE27 IS NULL)))
      AND ((RECINFO.ATTRIBUTE28 = X_ATTRIBUTE28)
           OR ((RECINFO.ATTRIBUTE28 IS NULL) AND (X_ATTRIBUTE28 IS NULL)))
      AND ((RECINFO.ATTRIBUTE29 = X_ATTRIBUTE29)
           OR ((RECINFO.ATTRIBUTE29 IS NULL) AND (X_ATTRIBUTE29 IS NULL)))
      AND ((RECINFO.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((RECINFO.ATTRIBUTE_CATEGORY IS NULL) AND (X_ATTRIBUTE_CATEGORY IS NULL)))
      AND ((RECINFO.ATTRIBUTE30 = X_ATTRIBUTE30)
           OR ((RECINFO.ATTRIBUTE30 IS NULL) AND (X_ATTRIBUTE30 IS NULL)))
      AND ((RECINFO.ORGANIZATION_ID = X_ORGANIZATION_ID)
           OR ((RECINFO.ORGANIZATION_ID IS NULL) AND (X_ORGANIZATION_ID IS NULL)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  FOR tlinfo IN c1 LOOP
    IF (tlinfo.BASELANG = 'Y') THEN
      IF (    (tlinfo.PARM_DESCRIPTION = X_PARM_DESCRIPTION)
      ) THEN
        NULL;
      ELSE
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      END IF;
    END IF;
  END LOOP;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_TECH_PARM_ID IN NUMBER,
  X_QCASSY_TYP_ID IN NUMBER,
  X_LAB_TYPE IN VARCHAR2,
  X_TECH_PARM_NAME IN VARCHAR2,
  X_DATA_TYPE IN NUMBER,
  X_SIGNIF_FIGURES IN NUMBER,
  X_LOWERBOUND_NUM IN NUMBER,
  X_UPPERBOUND_NUM IN NUMBER,
  X_LOWERBOUND_CHAR IN VARCHAR2,
  X_UPPERBOUND_CHAR IN VARCHAR2,
  X_MAX_LENGTH IN NUMBER,
  X_EXPRESSION_CHAR IN VARCHAR2,
  X_COST_SOURCE IN NUMBER,
  X_COST_TYPE IN VARCHAR2,
  X_COST_FUNCTION IN VARCHAR2,
  X_DEFAULT_COST_PARAMETER IN NUMBER,
  X_LM_UNIT_CODE IN VARCHAR2,
  X_DELETE_MARK IN NUMBER,
  X_TEXT_CODE IN NUMBER,
  X_IN_USE IN NUMBER,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  X_ATTRIBUTE20 IN VARCHAR2,
  X_ATTRIBUTE21 IN VARCHAR2,
  X_ATTRIBUTE22 IN VARCHAR2,
  X_ATTRIBUTE23 IN VARCHAR2,
  X_ATTRIBUTE24 IN VARCHAR2,
  X_ATTRIBUTE25 IN VARCHAR2,
  X_ATTRIBUTE26 IN VARCHAR2,
  X_ATTRIBUTE27 IN VARCHAR2,
  X_ATTRIBUTE28 IN VARCHAR2,
  X_ATTRIBUTE29 IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE30 IN VARCHAR2,
  X_ORGANIZATION_ID IN NUMBER,
  X_PARM_DESCRIPTION IN VARCHAR2,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
) IS
BEGIN
  UPDATE GMD_TECH_PARAMETERS_B SET
    QCASSY_TYP_ID = X_QCASSY_TYP_ID,
    LAB_TYPE = X_LAB_TYPE,
    TECH_PARM_NAME = X_TECH_PARM_NAME,
    DATA_TYPE = X_DATA_TYPE,
    SIGNIF_FIGURES = X_SIGNIF_FIGURES,
    LOWERBOUND_NUM = X_LOWERBOUND_NUM,
    UPPERBOUND_NUM = X_UPPERBOUND_NUM,
    LOWERBOUND_CHAR = X_LOWERBOUND_CHAR,
    UPPERBOUND_CHAR = X_UPPERBOUND_CHAR,
    MAX_LENGTH = X_MAX_LENGTH,
    EXPRESSION_CHAR = X_EXPRESSION_CHAR,
    COST_SOURCE = X_COST_SOURCE,
    COST_TYPE = X_COST_TYPE,
    COST_FUNCTION = X_COST_FUNCTION,
    DEFAULT_COST_PARAMETER = X_DEFAULT_COST_PARAMETER,
    LM_UNIT_CODE = X_LM_UNIT_CODE,
    DELETE_MARK = X_DELETE_MARK,
    TEXT_CODE = X_TEXT_CODE,
    IN_USE = X_IN_USE,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE16 = X_ATTRIBUTE16,
    ATTRIBUTE17 = X_ATTRIBUTE17,
    ATTRIBUTE18 = X_ATTRIBUTE18,
    ATTRIBUTE19 = X_ATTRIBUTE19,
    ATTRIBUTE20 = X_ATTRIBUTE20,
    ATTRIBUTE21 = X_ATTRIBUTE21,
    ATTRIBUTE22 = X_ATTRIBUTE22,
    ATTRIBUTE23 = X_ATTRIBUTE23,
    ATTRIBUTE24 = X_ATTRIBUTE24,
    ATTRIBUTE25 = X_ATTRIBUTE25,
    ATTRIBUTE26 = X_ATTRIBUTE26,
    ATTRIBUTE27 = X_ATTRIBUTE27,
    ATTRIBUTE28 = X_ATTRIBUTE28,
    ATTRIBUTE29 = X_ATTRIBUTE29,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE30 = X_ATTRIBUTE30,
    ORGANIZATION_ID = X_ORGANIZATION_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  WHERE TECH_PARM_ID = X_TECH_PARM_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE GMD_TECH_PARAMETERS_TL SET
    PARM_DESCRIPTION = X_PARM_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = USERENV('LANG')
  WHERE TECH_PARM_ID = X_TECH_PARM_ID
  AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  X_TECH_PARM_ID IN NUMBER
) IS
BEGIN
  UPDATE GMD_TECH_PARAMETERS_B
  SET    DELETE_MARK = 1
  WHERE TECH_PARM_ID = X_TECH_PARM_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE FROM GMD_TECH_PARAMETERS_TL T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM GMD_TECH_PARAMETERS_B B
    WHERE B.TECH_PARM_ID = T.TECH_PARM_ID
    );

  UPDATE GMD_TECH_PARAMETERS_TL T SET (
      PARM_DESCRIPTION
    ) = (SELECT
      B.PARM_DESCRIPTION
    FROM GMD_TECH_PARAMETERS_TL B
    WHERE B.TECH_PARM_ID = T.TECH_PARM_ID
    AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.TECH_PARM_ID,
      T.LANGUAGE
  ) IN (SELECT
      SUBT.TECH_PARM_ID,
      SUBT.LANGUAGE
    FROM GMD_TECH_PARAMETERS_TL SUBB, GMD_TECH_PARAMETERS_TL SUBT
    WHERE SUBB.TECH_PARM_ID = SUBT.TECH_PARM_ID
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.PARM_DESCRIPTION <> SUBT.PARM_DESCRIPTION
  ));

  INSERT INTO GMD_TECH_PARAMETERS_TL (
    TECH_PARM_ID,
    TECH_PARM_NAME,
    PARM_DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    B.TECH_PARM_ID,
    B.TECH_PARM_NAME,
    B.PARM_DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM GMD_TECH_PARAMETERS_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM GMD_TECH_PARAMETERS_TL T
    WHERE T.TECH_PARM_ID = B.TECH_PARM_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;

END GMD_TECH_PARAMETERS_PKG;

/