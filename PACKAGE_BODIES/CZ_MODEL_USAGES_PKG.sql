--------------------------------------------------------
--  DDL for Package Body CZ_MODEL_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_MODEL_USAGES_PKG" AS
  /* $Header: czmdlugb.pls 120.4 2007/12/24 16:20:02 skudryav ship $ */

PROCEDURE INSERT_ROW(x_rowid             IN OUT NOCOPY VARCHAR2,
                     p_model_usage_id    IN NUMBER,
                     p_name              IN VARCHAR2,
                     p_description       IN VARCHAR2,
                     p_note              IN VARCHAR2,
                     p_in_use            IN VARCHAR2,
                     p_created_by        IN NUMBER,
                     p_creation_date     IN DATE,
                     p_last_updated_by   IN NUMBER,
                     p_last_update_date  IN DATE,
                     p_last_update_login IN NUMBER) IS

  CURSOR l_rowid_cursor IS
      SELECT rowid, description
      FROM   cz_model_usages
      WHERE  model_usage_id = p_model_usage_id;
  l_model_usage_inserted BOOLEAN := FALSE;
  l_description CZ_MODEL_USAGES.description%TYPE := p_description;
BEGIN

  OPEN l_rowid_cursor;
  FETCH l_rowid_cursor INTO x_rowid,l_description;

  IF l_description IS NULL THEN
    l_description := p_name;
  END IF;

  IF l_rowid_cursor%NOTFOUND THEN
    INSERT INTO CZ_MODEL_USAGES
    (
      MODEL_USAGE_ID
      ,NAME
      ,DESCRIPTION
      ,NOTE
      ,IN_USE
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
      p_model_usage_id
      ,p_name
      ,p_description
      ,p_note
      ,p_in_use
      ,p_created_by
      ,p_creation_date
      ,p_last_updated_by
      ,p_last_update_date
      ,p_last_update_login
    );
    l_model_usage_inserted := TRUE;
  END IF;

  INSERT INTO cz_model_usages_tl(MODEL_USAGE_ID
                                ,LANGUAGE
                                ,SOURCE_LANG
                                ,DESCRIPTION
                                )
  SELECT p_model_usage_id
        ,L.LANGUAGE_CODE
        ,userenv('LANG')
        ,l_description
  FROM FND_LANGUAGES  L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS (SELECT NULL
                  FROM cz_model_usages_tl  T
                  WHERE T.model_usage_id = p_model_usage_id
                  AND T.LANGUAGE = L.LANGUAGE_CODE);

  IF l_rowid_cursor%NOTFOUND AND  l_model_usage_inserted=FALSE THEN
    CLOSE l_rowid_cursor;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE l_rowid_cursor;

  EXCEPTION
    WHEN OTHERS THEN
      IF l_rowid_cursor%ISOPEN THEN
        CLOSE l_rowid_cursor;
      END IF;
      RAISE;
END INSERT_ROW;

--------------------------------------------------------------------------------
PROCEDURE UPDATE_ROW(p_model_usage_id   IN NUMBER,
                     p_name              IN VARCHAR2,
                     p_description       IN VARCHAR2,
                     p_note              IN VARCHAR2,
                     p_last_updated_by   IN NUMBER,
                     p_last_update_date  IN DATE,
                     p_last_update_login IN NUMBER)
IS
  l_in_use  CZ_MODEL_USAGES.in_use%TYPE;
BEGIN

  SELECT NVL(in_use,'X') INTO l_in_use FROM CZ_MODEL_USAGES
   WHERE model_usage_id = p_model_usage_id;

  IF l_in_use = '1' THEN
    UPDATE cz_model_usages_tl
    SET description = p_description
    WHERE model_usage_id = p_model_usage_id AND
          source_lang <> language;
  ELSE
    UPDATE cz_model_usages
       SET name = p_name,
           note = p_note,
           last_updated_by = p_last_updated_by,
           last_update_date = p_last_update_date,
           last_update_login = p_last_update_login
     WHERE model_usage_id = p_model_usage_id;
    UPDATE cz_model_usages_tl
    SET description = p_description
      WHERE model_usage_id = p_model_usage_id;

    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END IF;

END UPDATE_ROW;

--------------------------------------------------------------------------------
PROCEDURE DELETE_ROW(p_model_usage_id IN NUMBER)
IS
BEGIN
  DELETE FROM cz_model_usages_tl
  WHERE model_usage_id = p_model_usage_id;

  IF SQL%NOTFOUND THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

--------------------------------------------------------------------------------
PROCEDURE ADD_LANGUAGE
IS

BEGIN
  INSERT INTO cz_model_usages_tl(MODEL_USAGE_ID
                                ,LANGUAGE
                                ,SOURCE_LANG
                                ,DESCRIPTION
                                )
  SELECT B.model_usage_id
        ,L.LANGUAGE_CODE
        ,B.SOURCE_LANG
        ,B.DESCRIPTION
  FROM  cz_model_usages_tl  B,
        FND_LANGUAGES       L
  WHERE L.INSTALLED_FLAG in ('I', 'B')
  AND B.LANGUAGE = userenv('LANG')
  AND NOT EXISTS (SELECT NULL
                  FROM cz_model_usages_tl  T
                  WHERE T.model_usage_id = B.model_usage_id
                  AND T.LANGUAGE = L.LANGUAGE_CODE);
  COMMIT;
END ADD_LANGUAGE;

--------------------------------------------------------------------------------
-- PROCEDURE LOCK_ROW(p_model_usage_id IN NUMBER)
-- IS
-- BEGIN
--   NULL;
-- END LOCK_ROW;

--------------------------------------------------------------------------------
PROCEDURE TRANSLATE_ROW(p_model_usage_id   IN NUMBER,
                        p_description      IN VARCHAR2) IS
BEGIN
  UPDATE cz_model_usages_tl
  SET description = p_description,
      source_lang = userenv('LANG')
  WHERE model_usage_id = p_model_usage_id
  AND userenv('LANG') IN (language, source_lang);

  IF SQL%NOTFOUND THEN
    RAISE NO_DATA_FOUND;
  END IF;
END TRANSLATE_ROW;

--------------------------------------------------------------------------------
PROCEDURE LOAD_ROW
(
 p_model_usage_id    IN NUMBER,
 p_name              IN VARCHAR2,
 p_description       IN VARCHAR2,
 p_note              IN VARCHAR2,
 p_in_use            IN VARCHAR2,
 p_owner             IN VARCHAR2,
 p_last_update_date  IN VARCHAR2
) IS
  CURSOR l_exists_cursor IS
      SELECT '1'
      FROM   cz_model_usages_tl
      WHERE  model_usage_id = p_model_usage_id
      AND    language = userenv('LANG');
  l_row_exists       VARCHAR2(1);
  l_rowid            VARCHAR2(64);
  l_last_update_date DATE;
  l_last_updated_by  NUMBER;
BEGIN

  -- Translate owner to file_last_updated_by
  l_last_updated_by := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  l_last_update_date := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  OPEN l_exists_cursor;
  FETCH l_exists_cursor INTO l_row_exists;

  IF l_exists_cursor%NOTFOUND THEN
    INSERT_ROW(l_rowid,
               p_model_usage_id,
               p_name,
               p_description,
               p_note,
               p_in_use,
               l_last_updated_by,
               l_last_update_date,
               l_last_updated_by,
               l_last_update_date,
               0);

  ELSE
    UPDATE_ROW(p_model_usage_id,
               p_name,
               p_description,
               p_note,
               l_last_updated_by,
               l_last_update_date,
               0);

  END IF;

  CLOSE l_exists_cursor;

END LOAD_ROW;

END CZ_MODEL_USAGES_PKG;

/
