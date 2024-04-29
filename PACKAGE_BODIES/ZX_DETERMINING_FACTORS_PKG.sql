--------------------------------------------------------
--  DDL for Package Body ZX_DETERMINING_FACTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_DETERMINING_FACTORS_PKG" as
/* $Header: zxritrldetfactb.pls 120.14 2005/11/01 23:51:58 rsanthan ship $ */

  g_current_runtime_level CONSTANT  NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

PROCEDURE INSERT_ROW
     (X_ROWID                    IN OUT NOCOPY VARCHAR2,
      X_DETERMINING_FACTOR_ID                  NUMBER,
      X_DETERMINING_FACTOR_CODE                VARCHAR2,
      X_DETERMINING_FACTOR_CLASS_COD           VARCHAR2,
      X_VALUE_SET                              VARCHAR2,
      X_TAX_PARAMETER_CODE                     VARCHAR2,
      X_DATA_TYPE_CODE                         VARCHAR2,
      X_TAX_FUNCTION_CODE                      VARCHAR2,
      X_RECORD_TYPE_CODE                       VARCHAR2,
      X_TAX_REGIME_DET_FLAG                    VARCHAR2,
      X_TAX_SUMMARIZATION_FLAG                 VARCHAR2,
      X_TAX_RULES_FLAG                         VARCHAR2,
      X_TAXABLE_BASIS_FLAG                     VARCHAR2,
      X_TAX_CALCULATION_FLAG                   VARCHAR2,
      X_INTERNAL_FLAG                          VARCHAR2,
      X_RECORD_ONLY_FLAG                       VARCHAR2,
      X_REQUEST_ID                             NUMBER,
      X_DETERMINING_FACTOR_NAME                VARCHAR2,
      X_DETERMINING_FACTOR_DESC                VARCHAR2,
      X_CREATION_DATE                          DATE,
      X_CREATED_BY                             NUMBER,
      X_LAST_UPDATE_DATE                       DATE,
      X_LAST_UPDATED_BY                        NUMBER,
      X_LAST_UPDATE_LOGIN                      NUMBER,
      X_OBJECT_VERSION_NUMBER                  NUMBER) IS

    CURSOR C IS
      SELECT ROWID
      FROM ZX_DETERMINING_FACTORS_B
      WHERE DETERMINING_FACTOR_ID = X_DETERMINING_FACTOR_ID;

BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.INSERT_ROW.BEGIN',
                   'ZX_DETERMINING_FACTORS_PKG.INSERT_ROW (+)');
  END IF;

  INSERT INTO ZX_DETERMINING_FACTORS_B (DETERMINING_FACTOR_ID,
                                        DETERMINING_FACTOR_CODE,
                                        DETERMINING_FACTOR_CLASS_CODE,
                                        VALUE_SET,
                                        TAX_PARAMETER_CODE,
                                        DATA_TYPE_CODE,
                                        TAX_FUNCTION_CODE,
                                        RECORD_TYPE_CODE,
                                        TAX_REGIME_DET_FLAG,
                                        TAX_SUMMARIZATION_FLAG,
                                        TAX_RULES_FLAG,
                                        TAXABLE_BASIS_FLAG,
                                        TAX_CALCULATION_FLAG,
                                        INTERNAL_FLAG,
                                        RECORD_ONLY_FLAG,
                                        REQUEST_ID,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_LOGIN,
                                        OBJECT_VERSION_NUMBER)
                                values (X_DETERMINING_FACTOR_ID,
                                        X_DETERMINING_FACTOR_CODE,
                                        X_DETERMINING_FACTOR_CLASS_COD,
                                        X_VALUE_SET,
                                        X_TAX_PARAMETER_CODE,
                                        X_DATA_TYPE_CODE,
                                        X_TAX_FUNCTION_CODE,
                                        X_RECORD_TYPE_CODE,
                                        NVL(X_TAX_REGIME_DET_FLAG, 'N'),
                                        NVL(X_TAX_SUMMARIZATION_FLAG, 'N'),
                                        NVL(X_TAX_RULES_FLAG, 'N'),
                                        NVL(X_TAXABLE_BASIS_FLAG, 'N'),
                                        NVL(X_TAX_CALCULATION_FLAG, 'N'),
                                        NVL(X_INTERNAL_FLAG, 'N'),
                                        NVL(X_RECORD_ONLY_FLAG, 'N'),
                                        X_REQUEST_ID,
                                        X_CREATION_DATE,
                                        X_CREATED_BY,
                                        X_LAST_UPDATE_DATE,
                                        X_LAST_UPDATED_BY,
                                        X_LAST_UPDATE_LOGIN,
                                        X_OBJECT_VERSION_NUMBER);

  INSERT INTO ZX_DET_FACTORS_TL (DETERMINING_FACTOR_NAME,
                                         DETERMINING_FACTOR_DESC,
                                         CREATION_DATE,
                                         CREATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_LOGIN,
                                         DETERMINING_FACTOR_ID,
                                         LANGUAGE,
                                         SOURCE_LANG)
                                  SELECT X_DETERMINING_FACTOR_NAME,
                                         X_DETERMINING_FACTOR_DESC,
                                         X_CREATION_DATE,
                                         X_CREATED_BY,
                                         X_LAST_UPDATE_DATE,
                                         X_LAST_UPDATED_BY,
                                         X_LAST_UPDATE_LOGIN,
                                         X_DETERMINING_FACTOR_ID,
                                         L.LANGUAGE_CODE,
                                         userenv('LANG')
                                    FROM FND_LANGUAGES L
                                    WHERE L.INSTALLED_FLAG in ('I', 'B')
                                    AND NOT EXISTS (SELECT NULL
                                                    FROM ZX_DET_FACTORS_TL T
                                                    WHERE T.DETERMINING_FACTOR_ID = X_DETERMINING_FACTOR_ID
                                                    AND T.LANGUAGE = L.LANGUAGE_CODE);

  OPEN C;
  FETCH C INTO X_ROWID;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.INSERT_ROW.END',
                   'ZX_DETERMINING_FACTORS_PKG.INSERT_ROW (-)');
  END IF;
END INSERT_ROW;

PROCEDURE LOCK_ROW
     (X_DETERMINING_FACTOR_ID                  NUMBER,
      X_DETERMINING_FACTOR_CODE                VARCHAR2,
      X_DETERMINING_FACTOR_CLASS_COD           VARCHAR2,
      X_VALUE_SET                              VARCHAR2,
      X_TAX_PARAMETER_CODE                     VARCHAR2,
      X_DATA_TYPE_CODE                         VARCHAR2,
      X_TAX_FUNCTION_CODE                      VARCHAR2,
      X_RECORD_TYPE_CODE                       VARCHAR2,
      X_TAX_REGIME_DET_FLAG                    VARCHAR2,
      X_TAX_SUMMARIZATION_FLAG                 VARCHAR2,
      X_TAX_RULES_FLAG                         VARCHAR2,
      X_TAXABLE_BASIS_FLAG                     VARCHAR2,
      X_TAX_CALCULATION_FLAG                   VARCHAR2,
      X_INTERNAL_FLAG                          VARCHAR2,
      X_RECORD_ONLY_FLAG                       VARCHAR2,
      X_REQUEST_ID                             NUMBER,
      X_DETERMINING_FACTOR_NAME                VARCHAR2,
      X_DETERMINING_FACTOR_DESC                VARCHAR2,
      X_OBJECT_VERSION_NUMBER                  NUMBER) IS

  CURSOR C IS
    SELECT DETERMINING_FACTOR_CODE,
           DETERMINING_FACTOR_CLASS_CODE,
           VALUE_SET,
           TAX_PARAMETER_CODE,
           DATA_TYPE_CODE,
           TAX_FUNCTION_CODE,
           RECORD_TYPE_CODE,
           TAX_REGIME_DET_FLAG,
           TAX_SUMMARIZATION_FLAG,
           TAX_RULES_FLAG,
           TAXABLE_BASIS_FLAG,
           TAX_CALCULATION_FLAG,
           INTERNAL_FLAG,
           RECORD_ONLY_FLAG,
           REQUEST_ID,
           OBJECT_VERSION_NUMBER
      FROM ZX_DETERMINING_FACTORS_B
      WHERE DETERMINING_FACTOR_ID = X_DETERMINING_FACTOR_ID
      FOR UPDATE OF DETERMINING_FACTOR_ID NOWAIT;
  RECINFO C%ROWTYPE;

  CURSOR C1 IS
    SELECT DETERMINING_FACTOR_NAME,
           DETERMINING_FACTOR_DESC,
           DECODE(LANGUAGE, USERENV('LANG'), 'Y', 'N') BASELANG
    FROM ZX_DET_FACTORS_TL
    WHERE DETERMINING_FACTOR_ID = X_DETERMINING_FACTOR_ID
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
    FOR UPDATE OF DETERMINING_FACTOR_ID NOWAIT;

BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.LOCK_ROW.BEGIN',
                   'ZX_DETERMINING_FACTORS_PKG.LOCK_ROW (+)');
  END IF;

  OPEN C;
  FETCH C INTO RECINFO;
  IF (c%notfound) THEN
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE C;
  IF ((recinfo.DETERMINING_FACTOR_CODE = X_DETERMINING_FACTOR_CODE) AND
      (recinfo.DETERMINING_FACTOR_CLASS_CODE = X_DETERMINING_FACTOR_CLASS_COD) AND
      ((recinfo.VALUE_SET = X_VALUE_SET) OR
       ((recinfo.VALUE_SET is null) AND
        (X_VALUE_SET is null))) AND
      ((recinfo.TAX_PARAMETER_CODE = X_TAX_PARAMETER_CODE) OR
       ((recinfo.TAX_PARAMETER_CODE is null) AND
        (X_TAX_PARAMETER_CODE is null))) AND
      (recinfo.DATA_TYPE_CODE = X_DATA_TYPE_CODE) AND
      ((recinfo.TAX_FUNCTION_CODE = X_TAX_FUNCTION_CODE) OR
       ((recinfo.TAX_FUNCTION_CODE is null) AND
        (X_TAX_FUNCTION_CODE is null))) AND
      (recinfo.RECORD_TYPE_CODE = X_RECORD_TYPE_CODE) AND
      ((recinfo.TAX_REGIME_DET_FLAG = X_TAX_REGIME_DET_FLAG) OR
       ((recinfo.TAX_REGIME_DET_FLAG is null) AND
        (X_TAX_REGIME_DET_FLAG is null))) AND
      ((recinfo.TAX_SUMMARIZATION_FLAG = X_TAX_SUMMARIZATION_FLAG) OR
       ((recinfo.TAX_SUMMARIZATION_FLAG is null) AND
        (X_TAX_SUMMARIZATION_FLAG is null))) AND
      ((recinfo.TAX_RULES_FLAG = X_TAX_RULES_FLAG) OR
       ((recinfo.TAX_RULES_FLAG is null) AND
        (X_TAX_RULES_FLAG is null))) AND
      ((recinfo.TAXABLE_BASIS_FLAG = X_TAXABLE_BASIS_FLAG) OR
       ((recinfo.TAXABLE_BASIS_FLAG is null) AND
        (X_TAXABLE_BASIS_FLAG is null))) AND
      ((recinfo.TAX_CALCULATION_FLAG = X_TAX_CALCULATION_FLAG) OR
       ((recinfo.TAX_CALCULATION_FLAG is null) AND
        (X_TAX_CALCULATION_FLAG is null))) AND
      ((recinfo.INTERNAL_FLAG = X_INTERNAL_FLAG) OR
       ((recinfo.INTERNAL_FLAG is null) AND
        (X_INTERNAL_FLAG is null))) AND
      ((recinfo.RECORD_ONLY_FLAG = X_RECORD_ONLY_FLAG) OR
       ((recinfo.RECORD_ONLY_FLAG is null) AND
        (X_RECORD_ONLY_FLAG is null))) AND
      ((recinfo.REQUEST_ID = X_REQUEST_ID) OR
       ((recinfo.REQUEST_ID is null) AND
        (X_REQUEST_ID is null))))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)  THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  FOR tlinfo in c1 LOOP
    IF (tlinfo.BASELANG = 'Y') THEN
      IF ((tlinfo.DETERMINING_FACTOR_NAME = X_DETERMINING_FACTOR_NAME) AND
          ((tlinfo.DETERMINING_FACTOR_DESC = X_DETERMINING_FACTOR_DESC) OR
           ((tlinfo.DETERMINING_FACTOR_DESC is null) AND
            (X_DETERMINING_FACTOR_DESC is null)))) THEN
        NULL;
      ELSE
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      END IF;
    END IF;
  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.LOCK_ROW.END',
                   'ZX_DETERMINING_FACTORS_PKG.LOCK_ROW (-)');
  END IF;

  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW
     (X_DETERMINING_FACTOR_ID                  NUMBER,
      X_DETERMINING_FACTOR_CODE                VARCHAR2,
      X_DETERMINING_FACTOR_CLASS_COD           VARCHAR2,
      X_VALUE_SET                              VARCHAR2,
      X_TAX_PARAMETER_CODE                     VARCHAR2,
      X_DATA_TYPE_CODE                         VARCHAR2,
      X_TAX_FUNCTION_CODE                      VARCHAR2,
      X_RECORD_TYPE_CODE                       VARCHAR2,
      X_TAX_REGIME_DET_FLAG                    VARCHAR2,
      X_TAX_SUMMARIZATION_FLAG                 VARCHAR2,
      X_TAX_RULES_FLAG                         VARCHAR2,
      X_TAXABLE_BASIS_FLAG                     VARCHAR2,
      X_TAX_CALCULATION_FLAG                   VARCHAR2,
      X_INTERNAL_FLAG                          VARCHAR2,
      X_RECORD_ONLY_FLAG                       VARCHAR2,
      X_REQUEST_ID                             NUMBER,
      X_DETERMINING_FACTOR_NAME                VARCHAR2,
      X_DETERMINING_FACTOR_DESC                VARCHAR2,
      X_LAST_UPDATE_DATE                       DATE,
      X_LAST_UPDATED_BY                        NUMBER,
      X_LAST_UPDATE_LOGIN                      NUMBER,
      X_OBJECT_VERSION_NUMBER                  NUMBER) IS

BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.UPDATE_ROW.BEGIN',
                   'ZX_DETERMINING_FACTORS_PKG.UPDATE_ROW (+)');
  END IF;

  UPDATE ZX_DETERMINING_FACTORS_B
    SET DETERMINING_FACTOR_CODE = X_DETERMINING_FACTOR_CODE,
        DETERMINING_FACTOR_CLASS_CODE = X_DETERMINING_FACTOR_CLASS_COD,
        VALUE_SET = X_VALUE_SET,
        TAX_PARAMETER_CODE = X_TAX_PARAMETER_CODE,
        DATA_TYPE_CODE = X_DATA_TYPE_CODE,
        TAX_FUNCTION_CODE = X_TAX_FUNCTION_CODE,
        RECORD_TYPE_CODE = X_RECORD_TYPE_CODE,
        TAX_REGIME_DET_FLAG = NVL(X_TAX_REGIME_DET_FLAG, 'N'),
        TAX_SUMMARIZATION_FLAG = NVL(X_TAX_SUMMARIZATION_FLAG, 'N'),
        TAX_RULES_FLAG = NVL(X_TAX_RULES_FLAG, 'N'),
        TAXABLE_BASIS_FLAG = NVL(X_TAXABLE_BASIS_FLAG, 'N'),
        TAX_CALCULATION_FLAG = NVL(X_TAX_CALCULATION_FLAG, 'N'),
        INTERNAL_FLAG = NVL(X_INTERNAL_FLAG, 'N'),
        RECORD_ONLY_FLAG = NVL(X_RECORD_ONLY_FLAG, 'N'),
        REQUEST_ID = X_REQUEST_ID,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    WHERE DETERMINING_FACTOR_ID = X_DETERMINING_FACTOR_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE ZX_DET_FACTORS_TL
    SET DETERMINING_FACTOR_NAME = X_DETERMINING_FACTOR_NAME,
        DETERMINING_FACTOR_DESC = X_DETERMINING_FACTOR_DESC,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        SOURCE_LANG = userenv('LANG')
    WHERE DETERMINING_FACTOR_ID = X_DETERMINING_FACTOR_ID
    AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.UPDATE_ROW.END',
                   'ZX_DETERMINING_FACTORS_PKG.UPDATE_ROW (-)');
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW
     (X_DETERMINING_FACTOR_ID                  NUMBER) IS

BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.DELETE_ROW.BEGIN',
                   'ZX_DETERMINING_FACTORS_PKG.DELETE_ROW (+)');
  END IF;

  DELETE FROM ZX_DET_FACTORS_TL
  WHERE DETERMINING_FACTOR_ID = X_DETERMINING_FACTOR_ID;

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM ZX_DETERMINING_FACTORS_B
  WHERE DETERMINING_FACTOR_ID = X_DETERMINING_FACTOR_ID;

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.DELETE_ROW.END',
                   'ZX_DETERMINING_FACTORS_PKG.DELETE_ROW (-)');
  END IF;

END DELETE_ROW;

PROCEDURE ADD_LANGUAGE IS

BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.ADD_LANGUAGE.BEGIN',
                   'ZX_DETERMINING_FACTORS_PKG.ADD_LANGUAGE (+)');
  END IF;

  DELETE FROM ZX_DET_FACTORS_TL T
    WHERE NOT EXISTS (SELECT NULL
                      FROM ZX_DETERMINING_FACTORS_B B
                      WHERE B.DETERMINING_FACTOR_ID = T.DETERMINING_FACTOR_ID);

  UPDATE ZX_DET_FACTORS_TL T
    SET (DETERMINING_FACTOR_NAME,
         DETERMINING_FACTOR_DESC) = (SELECT B.DETERMINING_FACTOR_NAME,
                                            B.DETERMINING_FACTOR_DESC
                                     FROM ZX_DET_FACTORS_TL B
                                     WHERE B.DETERMINING_FACTOR_ID = T.DETERMINING_FACTOR_ID
                                     AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (T.DETERMINING_FACTOR_ID,
           T.LANGUAGE) IN (SELECT SUBT.DETERMINING_FACTOR_ID,
                                  SUBT.LANGUAGE
                           FROM ZX_DET_FACTORS_TL SUBB,
                                ZX_DET_FACTORS_TL SUBT
                           WHERE SUBB.DETERMINING_FACTOR_ID = SUBT.DETERMINING_FACTOR_ID
                           AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                           AND (SUBB.DETERMINING_FACTOR_NAME <> SUBT.DETERMINING_FACTOR_NAME OR
                                SUBB.DETERMINING_FACTOR_DESC <> SUBT.DETERMINING_FACTOR_DESC OR
                                (SUBB.DETERMINING_FACTOR_DESC IS NULL AND
                                 SUBT.DETERMINING_FACTOR_DESC IS NOT NULL) OR
                                (SUBB.DETERMINING_FACTOR_DESC IS NOT NULL AND
                                 SUBT.DETERMINING_FACTOR_DESC IS NULL)));

  INSERT INTO ZX_DET_FACTORS_TL (DETERMINING_FACTOR_NAME,
                                         DETERMINING_FACTOR_DESC,
                                         CREATION_DATE,
                                         CREATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_LOGIN,
                                         DETERMINING_FACTOR_ID,
                                         LANGUAGE,
                                         SOURCE_LANG)
                                  SELECT /*+ ORDERED */
                                         B.DETERMINING_FACTOR_NAME,
                                         B.DETERMINING_FACTOR_DESC,
                                         B.CREATION_DATE,
                                         B.CREATED_BY,
                                         B.LAST_UPDATE_DATE,
                                         B.LAST_UPDATED_BY,
                                         B.LAST_UPDATE_LOGIN,
                                         B.DETERMINING_FACTOR_ID,
                                         L.LANGUAGE_CODE,
                                         B.SOURCE_LANG
                                    FROM ZX_DET_FACTORS_TL B,
                                         FND_LANGUAGES L
                                    WHERE L.INSTALLED_FLAG IN ('I', 'B')
                                    AND B.LANGUAGE = USERENV('LANG')
                                    AND NOT EXISTS (SELECT NULL
                                                    FROM ZX_DET_FACTORS_TL T
                                                    WHERE T.DETERMINING_FACTOR_ID = B.DETERMINING_FACTOR_ID
                                                    AND T.LANGUAGE = L.LANGUAGE_CODE);

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.ADD_LANGUAGE.END',
                   'ZX_DETERMINING_FACTORS_PKG.ADD_LANGUAGE (-)');
  END IF;

END ADD_LANGUAGE;

PROCEDURE INSERT_GEOGRAPHY_ROW
     (X_DETERMINING_FACTOR_CLASS_COD            VARCHAR2,
      X_DETERMINING_FACTOR_CODE                 VARCHAR2,
      X_RECORD_TYPE_CODE                        VARCHAR2) IS
    L_DETERMINING_FACTOR_ID                     NUMBER;
    L_DET_FACTOR_NAME                           VARCHAR2(150);
    X_ROWID				        ROWID;
    CURSOR C IS
      SELECT	ROWID
      FROM 	ZX_DETERMINING_FACTORS_B
      WHERE 	DETERMINING_FACTOR_CLASS_CODE = X_DETERMINING_FACTOR_CLASS_COD
      AND 	DETERMINING_FACTOR_CODE = X_DETERMINING_FACTOR_CODE;
BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.INSERT_GEOGRAPHY_ROW.BEGIN',
                   'ZX_DETERMINING_FACTORS_PKG.INSERT_GEOGRAPHY_ROW (+)');
  END IF;

OPEN C;
  FETCH C INTO X_ROWID;
  IF (C%NOTFOUND) THEN
  BEGIN
    SELECT Zx_Determining_Factors_B_S.nextval INTO L_DETERMINING_FACTOR_ID FROM DUAL;
    /*Get the DETERMINING_FACTOR_NAME from HZ_GEOGRAPHIES for DETERMINING_FACTOR_CODE*/
    SELECT GEOGRAPHY_TYPE_NAME INTO L_DET_FACTOR_NAME FROM HZ_GEOGRAPHY_TYPES_VL
    WHERE GEOGRAPHY_TYPE = X_DETERMINING_FACTOR_CODE
    AND GEOGRAPHY_USE= (DECODE(X_DETERMINING_FACTOR_CLASS_COD, 'GEOGRAPHY', 'MASTER_REF', 'TAX'))
    AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
  END;
  INSERT_ROW(
	X_ROWID,
	L_DETERMINING_FACTOR_ID,
	X_DETERMINING_FACTOR_CODE,
	X_DETERMINING_FACTOR_CLASS_COD,
	null,
	null,
	'NUMERIC',
	null,
	X_RECORD_TYPE_CODE,
	'N',
	'N',
	'Y',
	'N',
	'N',
	'Y',
	'N',
	FND_GLOBAL.CONC_LOGIN_ID,
	L_DET_FACTOR_NAME,
	null,
	SYSDATE,
	FND_GLOBAL.USER_ID,
	SYSDATE,
	FND_GLOBAL.USER_ID,
	FND_GLOBAL.CONC_LOGIN_ID,
	1);
  END IF;
    CLOSE C;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_DETERMINING_FACTORS_PKG.INSERT_GEOGRAPHY_ROW.END',
                   'ZX_DETERMINING_FACTORS_PKG.INSERT_GEOGRAPHY_ROW (-)');
  END IF;

END INSERT_GEOGRAPHY_ROW;

END ZX_DETERMINING_FACTORS_PKG;

/
