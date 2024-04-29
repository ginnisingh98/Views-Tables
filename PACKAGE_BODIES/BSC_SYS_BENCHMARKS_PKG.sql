--------------------------------------------------------
--  DDL for Package Body BSC_SYS_BENCHMARKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_BENCHMARKS_PKG" as
/* $Header: BSCBMTLB.pls 120.1 2005/08/17 12:35:12 hcamacho noship $ */
PROCEDURE INSERT_ROW (
    X_BM_ID              IN   NUMBER
  , X_COLOR              IN   NUMBER
  , X_DATA_TYPE          IN   NUMBER
  , X_SOURCE_TYPE        IN   NUMBER
  , X_PERIODICITY_ID     IN   NUMBER
  , X_NO_DISPLAY_FLAG    IN   NUMBER
  , X_NAME               IN   VARCHAR2
) IS
BEGIN

    BSC_SYS_BENCHMARKS_PKG.INSERT_ROW
    (
        p_Bm_id             =>  X_BM_ID
      , p_Color             =>  X_COLOR
      , p_Data_type         =>  X_DATA_TYPE
      , p_Source_type       =>  X_SOURCE_TYPE
      , p_Periodicity_id    =>  X_PERIODICITY_ID
      , p_No_display_flag   =>  X_NO_DISPLAY_FLAG
      , p_Name              =>  X_NAME
      , p_Created_by        =>  FND_GLOBAL.USER_ID
      , p_Creation_date     =>  SYSDATE
      , p_Last_updated_by   =>  FND_GLOBAL.USER_ID
      , p_Last_update_date  =>  SYSDATE
      , p_Last_update_login =>  FND_GLOBAL.LOGIN_ID
    );

END INSERT_ROW;



PROCEDURE INSERT_ROW (
    p_Bm_id              IN     NUMBER
  , p_Color              IN     NUMBER
  , p_Data_type          IN     NUMBER
  , p_Source_type        IN     NUMBER
  , p_Periodicity_id     IN     NUMBER
  , p_No_display_flag    IN     NUMBER
  , p_Name               IN     VARCHAR2
  , p_Created_by         IN     NUMBER
  , p_Creation_date      IN     DATE
  , p_Last_updated_by    IN     NUMBER
  , p_Last_update_date   IN     DATE
  , p_Last_update_login  IN     NUMBER
) IS
BEGIN

  INSERT INTO bsc_sys_benchmarks_b (
      bm_id
    , color
    , data_type
    , source_type
    , periodicity_id
    , no_display_flag
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
   ) VALUES (
      p_Bm_id
    , p_Color
    , p_Data_type
    , p_Source_type
    , p_Periodicity_id
    , p_No_display_flag
    , p_Created_by
    , p_Creation_date
    , p_Last_updated_by
    , p_Last_update_date
    , NVL(p_Last_update_login,FND_GLOBAL.login_id)
  );

  INSERT INTO bsc_sys_benchmarks_tl (
      bm_id
    , name
    , language
    , source_lang
  ) SELECT
      p_Bm_id
    , p_Name
    , l.LANGUAGE_CODE
    , USERENV('LANG')
  FROM fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND NOT EXISTS
    ( SELECT NULL
      FROM  bsc_sys_benchmarks_tl t
      WHERE t.bm_id     = p_Bm_id
      AND   t.language  = l.language_code
    );

END INSERT_ROW;



PROCEDURE TRANSLATE_ROW
(
    p_Bm_id   IN NUMBER
  , p_Name    IN VARCHAR2
)IS
BEGIN
  UPDATE bsc_sys_benchmarks_tl
  SET    name = NVL(p_Name,name)
      ,  source_lang = USERENV('LANG')
  WHERE  USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
  AND    bm_id = p_Bm_id;

END TRANSLATE_ROW;

procedure LOCK_ROW (
  X_BM_ID in NUMBER,
  X_COLOR in NUMBER,
  X_DATA_TYPE in NUMBER,
  X_SOURCE_TYPE in NUMBER,
  X_PERIODICITY_ID in NUMBER,
  X_NO_DISPLAY_FLAG in NUMBER,
  X_NAME in VARCHAR2
) is
  cursor c is select
      COLOR,
      DATA_TYPE,
      SOURCE_TYPE,
      PERIODICITY_ID,
      NO_DISPLAY_FLAG
    from BSC_SYS_BENCHMARKS_B
    where BM_ID = X_BM_ID
    for update of BM_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_SYS_BENCHMARKS_TL
    where BM_ID = X_BM_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of BM_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.COLOR = X_COLOR)
      AND (recinfo.DATA_TYPE = X_DATA_TYPE)
      AND (recinfo.SOURCE_TYPE = X_SOURCE_TYPE)
      AND ((recinfo.PERIODICITY_ID = X_PERIODICITY_ID)
           OR ((recinfo.PERIODICITY_ID is null) AND (X_PERIODICITY_ID is null)))
      AND ((recinfo.NO_DISPLAY_FLAG = X_NO_DISPLAY_FLAG)
           OR ((recinfo.NO_DISPLAY_FLAG is null) AND (X_NO_DISPLAY_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

PROCEDURE UPDATE_ROW (
    p_Bm_id              IN     NUMBER
  , p_Color              IN     NUMBER
  , p_Data_type          IN     NUMBER
  , p_Source_type        IN     NUMBER
  , p_Periodicity_id     IN     NUMBER
  , p_No_display_flag    IN     NUMBER
  , p_Name               IN     VARCHAR2
  , p_Last_updated_by    IN     NUMBER
  , p_Last_update_date   IN     DATE
  , p_Last_update_login  IN     NUMBER
  , p_Custom_mode        IN     VARCHAR2
) IS
     l_prev_last_updated_by     BSC_SYS_BENCHMARKS_B.last_updated_by%TYPE;
     l_prev_last_update_date    BSC_SYS_BENCHMARKS_B.last_update_date%TYPE;
BEGIN

   SELECT NVL(last_updated_by,FND_GLOBAL.USER_ID)
        , NVL(last_update_date,SYSDATE)
   INTO   l_prev_last_updated_by,l_prev_last_update_date
   FROM   bsc_sys_benchmarks_b
   WHERE  bm_id = p_Bm_id;

   IF(SQL%NOTFOUND)THEN
    RAISE NO_DATA_FOUND;
   END IF;

   IF (FND_LOAD_UTIL.UPLOAD_TEST(p_Last_updated_by
                               , p_Last_update_date
                               , l_prev_last_updated_by
                               , l_prev_last_update_date
                               , p_Custom_mode)) THEN


      UPDATE bsc_sys_benchmarks_b
      SET   color            = p_Color
          , data_type        = p_Data_type
          , source_type      = p_Source_type
          , periodicity_id   = p_Periodicity_id
          , no_display_flag  = p_No_display_flag
          , last_updated_by  = p_Last_updated_by
          , last_update_date = p_Last_update_date
          , last_update_login= NVL(p_Last_update_login,FND_GLOBAL.LOGIN_ID)
      WHERE bm_id = p_Bm_id;

      IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
      END IF;

      UPDATE bsc_sys_benchmarks_tl
      SET    name = p_Name
          ,  source_lang = USERENV('LANG')
      WHERE  bm_id = p_Bm_id
      AND    USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

      IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
      END IF;
   END IF;
END UPDATE_ROW;


PROCEDURE DELETE_ROW (
  X_BM_ID in NUMBER
) is
begin
  delete from BSC_SYS_BENCHMARKS_TL
  where BM_ID = X_BM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_SYS_BENCHMARKS_B
  where BM_ID = X_BM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BSC_SYS_BENCHMARKS_TL T
  where not exists
    (select NULL
    from BSC_SYS_BENCHMARKS_B B
    where B.BM_ID = T.BM_ID
    );

  update BSC_SYS_BENCHMARKS_TL T set (
      NAME
    ) = (select
      B.NAME
    from BSC_SYS_BENCHMARKS_TL B
    where B.BM_ID = T.BM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BM_ID,
      SUBT.LANGUAGE
    from BSC_SYS_BENCHMARKS_TL SUBB, BSC_SYS_BENCHMARKS_TL SUBT
    where SUBB.BM_ID = SUBT.BM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into BSC_SYS_BENCHMARKS_TL (
    BM_ID,
    NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.BM_ID,
    B.NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_SYS_BENCHMARKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_SYS_BENCHMARKS_TL T
    where T.BM_ID = B.BM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END BSC_SYS_BENCHMARKS_PKG;

/
