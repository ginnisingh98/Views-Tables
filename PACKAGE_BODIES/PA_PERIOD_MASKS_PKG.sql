--------------------------------------------------------
--  DDL for Package Body PA_PERIOD_MASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERIOD_MASKS_PKG" as
--$Header: PAFPPMTB.pls 120.2 2005/06/07 02:08:31 appldev  $
PROCEDURE INSERT_ROW(
         X_ROWID                   IN OUT NOCOPY rowid,
         X_PERIOD_MASK_ID          IN pa_period_masks_b.period_mask_id%type,
         X_EFFECTIVE_START_DATE    IN pa_period_masks_b.effective_start_date%type,
         X_EFFECTIVE_END_DATE      IN pa_period_masks_b.effective_end_date%type,
         X_TIME_PHASE_CODE         IN pa_period_masks_b.time_phase_code%type,
         X_CREATION_DATE           IN pa_period_masks_b.creation_date%type,
         X_CREATED_BY              IN pa_period_masks_b.created_by%type,
         X_LAST_UPDATE_LOGIN       IN pa_period_masks_b.last_update_login%type,
         X_LAST_UPDATED_BY         IN pa_period_masks_b.last_updated_by%type,
         X_LAST_UPDATE_DATE        IN pa_period_masks_b.last_update_date%type,
         X_RECORD_VERSION_NUMBER   IN pa_period_masks_b.record_version_number%type,
         X_PRE_DEFINED_FLAG        IN pa_period_masks_b.pre_defined_flag%type,
         X_NAME                    IN pa_period_masks_tl.name%type,
         X_DESCRIPTION             IN pa_period_masks_tl.description%type)
 IS

  l_period_mask_id pa_period_masks_b.period_mask_id%type;


  CURSOR C IS SELECT ROWID FROM PA_PERIOD_MASKS_B
    WHERE period_mask_id = l_period_mask_id;

BEGIN

  SELECT NVL(x_period_mask_id,pa_period_masks_s.nextval)
  INTO   l_period_mask_id
  FROM   DUAL;

  INSERT INTO PA_PERIOD_MASKS_B(
    period_mask_id,
    effective_start_date,
    effective_end_date,
    time_phase_code,
    creation_date,
    created_by,
    last_update_login,
    last_updated_by,
    last_update_date,
    record_version_number,
    pre_defined_flag
  ) VALUES (
    l_period_mask_id,
    X_EFFECTIVE_START_DATE,
    X_EFFECTIVE_END_DATE,
    X_TIME_PHASE_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_RECORD_VERSION_NUMBER,
    X_PRE_DEFINED_FLAG
  );

  INSERT INTO PA_PERIOD_MASKS_TL(
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    PERIOD_MASK_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L_PERIOD_MASK_ID,
    X_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    USERENV('LANG')
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG in ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
     FROM   PA_PERIOD_MASKS_TL ppmt
     WHERE  ppmt.period_mask_id  = l_period_mask_id
      AND   ppmt.language = l.language_code);

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE LOCK_ROW(
 X_PERIOD_MASK_ID IN pa_period_masks_b.period_mask_id%type
 ) IS
  CURSOR c IS SELECT
          period_mask_id
    FROM   pa_period_masks_b
    WHERE period_mask_id = x_period_mask_id
    FOR UPDATE of period_mask_id  NOWAIT;

  recinfo c%ROWTYPE;

  cursor c1 is SELECT
           NAME,
           DESCRIPTION,
           decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    FROM   PA_period_masks_tl
    WHERE  period_mask_id =  X_PERIOD_MASK_ID
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
    FOR UPDATE OF period_mask_id NOWAIT;

  recinfo1 c1%ROWTYPE;

BEGIN


  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;

  return;
END LOCK_ROW;



PROCEDURE UPDATE_ROW(
         X_PERIOD_MASK_ID          IN pa_period_masks_b.period_mask_id%type,
         X_EFFECTIVE_START_DATE    IN pa_period_masks_b.effective_start_date%type,
         X_EFFECTIVE_END_DATE      IN pa_period_masks_b.effective_end_date%type,
         X_TIME_PHASE_CODE         IN pa_period_masks_b.time_phase_code%type,
         X_CREATION_DATE           IN pa_period_masks_b.creation_date%type,
         X_CREATED_BY              IN pa_period_masks_b.created_by%type,
         X_LAST_UPDATE_LOGIN       IN pa_period_masks_b.last_update_login%type,
         X_LAST_UPDATED_BY         IN pa_period_masks_b.last_updated_by%type,
         X_LAST_UPDATE_DATE        IN pa_period_masks_b.last_update_date%type,
         X_RECORD_VERSION_NUMBER   IN pa_period_masks_b.record_version_number%type,
         X_PRE_DEFINED_FLAG        IN pa_period_masks_b.pre_defined_flag%type,
         X_NAME                    IN pa_period_masks_tl.name%type,
         X_DESCRIPTION             IN pa_period_masks_tl.description%type)
 IS
BEGIN

  UPDATE pa_period_masks_b
  SET    effective_start_date   =  X_EFFECTIVE_START_DATE,
         effective_end_date     =  X_EFFECTIVE_END_DATE,
         time_phase_code        =  X_TIME_PHASE_CODE,
         creation_date          =  X_CREATION_DATE,
         created_by             =  X_CREATED_BY,
         last_update_login      =  X_LAST_UPDATE_LOGIN,
         last_updated_by        =  X_LAST_UPDATED_BY,
         last_update_date       =  X_LAST_UPDATE_DATE,
         record_version_number  =  X_RECORD_VERSION_NUMBER,
         pre_defined_flag       =  X_PRE_DEFINED_FLAG
   where period_mask_id         =  X_PERIOD_MASK_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;

  UPDATE PA_PERIOD_MASKS_TL
  SET
         NAME              =  X_NAME,
         DESCRIPTION       =  X_DESCRIPTION,
         LAST_UPDATE_DATE  =  X_LAST_UPDATE_DATE,
         LAST_UPDATED_BY   =  X_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN =  X_LAST_UPDATE_LOGIN,
         SOURCE_LANG       =  USERENV('LANG')
  WHERE period_mask_id = X_PERIOD_MASK_ID
  AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);  /* 4397924: modified */

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;

END UPDATE_ROW;


PROCEDURE DELETE_ROW(
          X_PERIOD_MASK_ID IN pa_period_masks_b.period_mask_id%type
) IS
BEGIN

  DELETE FROM PA_PERIOD_MASKS_TL
  WHERE period_mask_id  = X_PERIOD_MASK_ID;
  /* 4397924: Commented the below AND condition as all the records
     have to be deleted from the _TL table
  AND   USERENV('LANG') IN (SELECT DISTINCT source_lang
                            FROM   pa_period_masks_tl); */

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;

  DELETE FROM PA_PERIOD_MASKS_B
  WHERE period_mask_id = X_PERIOD_MASK_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;

END DELETE_ROW;


PROCEDURE ADD_LANGUAGE IS

BEGIN

    DELETE FROM pa_period_masks_tl t
    WHERE  NOT EXISTS
          (SELECT null
           FROM   pa_period_masks_b b  /* 4397924: Referring to the base table */
           WHERE  b.period_mask_id = t.period_mask_id);

     UPDATE pa_period_masks_tl t
     SET (name,description) =
             (SELECT b.name,
                     b.description
              FROM   pa_period_masks_tl b
              WHERE  b.period_mask_id = t.period_mask_id
              AND    b.language = t.source_lang)
     WHERE (t.period_mask_id,
            t.language) IN (SELECT subt.period_mask_id,
                                   subt.language
                            FROM   pa_period_masks_tl subb,
                                   pa_period_masks_tl subt
                            WHERE  subb.period_mask_id = subt.period_mask_id
                            AND  subb.language = subt.source_lang
                            AND (subb.name <> subt.name
                                 OR subb.description <> subt.description
         OR (subb.description IS NULL AND subt.description IS NOT NULL)
       OR (subb.description IS NOT NULL AND subt.description IS NULL)));

      INSERT INTO pa_period_masks_tl(period_mask_id, /* 4397924: added the NOT NULL column */
                                     name,
                                     description,
                                     language,
                                     source_lang,
                                     last_update_date,
                                     last_updated_by,
                                     creation_date,
                                     created_by,
                                     last_update_login)
       SELECT period_mask_id, /* 4397924: added the NOT NULL column */
              name,
              description,
              l.language_code, /* 4397924: modified */
              source_lang,
              b.last_update_date,
              b.last_updated_by,
              b.creation_date,
              b.created_by,
              b.last_update_login
        FROM  pa_period_masks_tl b,
              fnd_languages l
        WHERE l.installed_flag in ('I','B')
        AND   b.language = userenv('LANG')
        AND NOT EXISTS (SELECT null
                        FROM   pa_period_masks_tl t
                        WHERE  t.period_mask_id = b.period_mask_id
                        AND   t.language = l.language_code);

END ADD_LANGUAGE;


PROCEDURE TRANSLATE_ROW(
         X_PERIOD_MASK_ID IN pa_period_masks_b.period_mask_id%type,
         X_OWNER          IN VARCHAR2,
         X_NAME           IN pa_period_masks_tl.name%type,
         X_DESCRIPTION    IN pa_period_masks_tl.description%type
) IS
BEGIN

  UPDATE       PA_PERIOD_MASKS_TL
   SET
         NAME                  =        X_NAME,
         DESCRIPTION           =        X_DESCRIPTION,
         LAST_UPDATE_DATE      =        sysdate,
         LAST_UPDATED_BY       =        decode(X_OWNER, 'SEED', 1, 0),
         LAST_UPDATE_LOGIN     =        0,
         SOURCE_LANG           =        USERENV('LANG')
  WHERE  PERIOD_MASK_ID        =        X_PERIOD_MASK_ID
  AND    USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;

END TRANSLATE_ROW;

PROCEDURE LOAD_ROW(
         X_PERIOD_MASK_ID          IN pa_period_masks_b.period_mask_id%type,
         X_EFFECTIVE_START_DATE    IN pa_period_masks_b.effective_start_date%type,
         X_EFFECTIVE_END_DATE      IN pa_period_masks_b.effective_end_date%type,
         X_TIME_PHASE_CODE         IN pa_period_masks_b.time_phase_code%type,
         X_CREATION_DATE           IN pa_period_masks_b.creation_date%type,
         X_CREATED_BY              IN pa_period_masks_b.created_by%type,
         X_LAST_UPDATE_LOGIN       IN pa_period_masks_b.last_update_login%type,
         X_LAST_UPDATED_BY         IN pa_period_masks_b.last_updated_by%type,
         X_LAST_UPDATE_DATE        IN pa_period_masks_b.last_update_date%type,
         X_RECORD_VERSION_NUMBER   IN pa_period_masks_b.record_version_number%type,
         X_PRE_DEFINED_FLAG        IN pa_period_masks_b.pre_defined_flag%type,
         X_NAME                    IN pa_period_masks_tl.name%type,
         X_DESCRIPTION             IN pa_period_masks_tl.description%type,
         X_OWNER                   IN VARCHAR2 )
 IS

  user_id NUMBER;
  X_ROWID ROWID;

BEGIN

  IF (X_OWNER = 'SEED') THEN
   user_id := 1;
  ELSE
   user_id :=0;
  END IF;

  PA_PERIOD_MASKS_PKG.UPDATE_ROW(
    X_PERIOD_MASK_ID                    =>    X_PERIOD_MASK_ID ,
    X_EFFECTIVE_START_DATE              =>    X_EFFECTIVE_START_DATE,
    X_EFFECTIVE_END_DATE                =>    X_EFFECTIVE_END_DATE,
    X_TIME_PHASE_CODE                   =>    X_TIME_PHASE_CODE,
    X_CREATION_DATE                     =>    X_CREATION_DATE,
    X_CREATED_BY                        =>    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN                 =>    0,         /* 4397924: modified */
    X_LAST_UPDATED_BY                   =>    user_id,   /* 4397924: modified */
    X_LAST_UPDATE_DATE                  =>    sysdate,   /* 4397924: modified */
    X_RECORD_VERSION_NUMBER             =>    X_RECORD_VERSION_NUMBER,
    X_PRE_DEFINED_FLAG                  =>    X_PRE_DEFINED_FLAG,
    X_NAME                              =>    X_NAME,
    X_DESCRIPTION                       =>    X_DESCRIPTION );

  EXCEPTION
    WHEN no_data_found THEN
        PA_PERIOD_MASKS_PKG.INSERT_ROW(
          X_ROWID                           =>  X_ROWID ,
          X_PERIOD_MASK_ID                  =>  X_PERIOD_MASK_ID,
          X_EFFECTIVE_START_DATE            =>  X_EFFECTIVE_START_DATE,
          X_EFFECTIVE_END_DATE              =>  X_EFFECTIVE_END_DATE,
          X_TIME_PHASE_CODE                 =>  X_TIME_PHASE_CODE,
          X_CREATION_DATE                   =>  sysdate,   /* 4397924: modified */
          X_CREATED_BY                      =>  user_id,   /* 4397924: modified */
          X_LAST_UPDATE_LOGIN               =>  0,         /* 4397924: modified */
          X_LAST_UPDATED_BY                 =>  user_id,   /* 4397924: modified */
          X_LAST_UPDATE_DATE                =>  sysdate,   /* 4397924: modified */
          X_RECORD_VERSION_NUMBER           =>  X_RECORD_VERSION_NUMBER,
          X_PRE_DEFINED_FLAG                =>  X_PRE_DEFINED_FLAG,
          X_NAME                            =>  X_NAME,
          X_DESCRIPTION                     =>  X_DESCRIPTION
       );

END LOAD_ROW;

END PA_PERIOD_MASKS_PKG;

/
