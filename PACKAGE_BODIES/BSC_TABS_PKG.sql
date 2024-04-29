--------------------------------------------------------
--  DDL for Package Body BSC_TABS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_TABS_PKG" as
/* $Header: BSCTABB.pls 115.9 2003/02/12 14:29:43 adeulgao ship $ */

PROCEDURE TRANSLATE_ROW
(
    X_SHORT_NAME              IN VARCHAR2,
    X_NAME                    IN VARCHAR2,
    X_HELP                    IN VARCHAR2,
    X_ADDITIONAL_INFO         IN VARCHAR2
)IS
BEGIN
    UPDATE BSC_TABS_TL SET
            NAME            =   NVL(X_NAME,            NAME),
            HELP            =   NVL(X_HELP,            HELP),
            ADDITIONAL_INFO =   NVL(X_ADDITIONAL_INFO, ADDITIONAL_INFO),
            SOURCE_LANG     =   USERENV('LANG')
    WHERE   USERENV('LANG') IN  (LANGUAGE, SOURCE_LANG)
    AND     TAB_ID          =   (SELECT TAB_ID FROM BSC_TABS_B WHERE SHORT_NAME = X_SHORT_NAME);

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END TRANSLATE_ROW;


PROCEDURE INSERT_ROW
(
    X_ROWID 		in out NOCOPY VARCHAR2,
    X_TAB_ID            IN      NUMBER,
    X_KPI_MODEL         IN      NUMBER,
    X_BSC_MODEL         IN      NUMBER,
    X_CROSS_MODEL       IN      NUMBER,
    X_DEFAULT_MODEL     IN      NUMBER,
    X_ZOOM_FACTOR       IN      NUMBER,
    X_CREATED_BY        IN      NUMBER,
    X_LAST_UPDATED_BY   IN      NUMBER,
    X_LAST_UPDATE_LOGIN IN      NUMBER,  /* DEFAULT 0  */
    X_PARENT_TAB_ID     IN      NUMBER,
    X_OWNER_ID          IN      NUMBER,
    X_SHORT_NAME        IN      VARCHAR2,
    X_NAME              IN      VARCHAR2,
    X_HELP              IN      VARCHAR2,
    X_ADDITIONAL_INFO   IN      VARCHAR2
) IS
    CURSOR C IS SELECT ROWID FROM BSC_TABS_B WHERE TAB_ID = X_TAB_ID;

BEGIN
        INSERT INTO BSC_TABS_B
        (
            TAB_ID,
            KPI_MODEL,
            BSC_MODEL,
            CROSS_MODEL,
            DEFAULT_MODEL,
            ZOOM_FACTOR,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            PARENT_TAB_ID,
            OWNER_ID,
            SHORT_NAME
        )
        VALUES
        (
            X_TAB_ID,
            X_KPI_MODEL,
            X_BSC_MODEL,
            X_CROSS_MODEL,
            X_DEFAULT_MODEL,
            X_ZOOM_FACTOR,
            SYSDATE,
            X_CREATED_BY,
            SYSDATE,
            X_LAST_UPDATED_BY,
            X_LAST_UPDATE_LOGIN,
            X_PARENT_TAB_ID,
            X_OWNER_ID,
            X_SHORT_NAME
        );
        INSERT INTO BSC_TABS_TL
        (
            TAB_ID,
            NAME,
            HELP,
            ADDITIONAL_INFO,
            LANGUAGE,
            SOURCE_LANG
        ) SELECT
            X_TAB_ID,
            X_NAME,
            X_HELP,
            X_ADDITIONAL_INFO,
            L.LANGUAGE_CODE,
            USERENV('LANG')
        FROM      FND_LANGUAGES L
        WHERE     L.INSTALLED_FLAG IN ('I', 'B')
        AND NOT EXISTS
        (
            SELECT NULL
            FROM    BSC_TABS_TL T
            WHERE   T.TAB_ID    = X_TAB_ID
            AND     T.LANGUAGE  = L.LANGUAGE_CODE
        );
    OPEN C;
        FETCH C INTO X_ROWID;
        IF (C%NOTFOUND) THEN
            CLOSE C;
            RAISE NO_DATA_FOUND;
        END IF;
    CLOSE C;

END INSERT_ROW;


procedure LOCK_ROW (
  X_TAB_ID in NUMBER,
  X_KPI_MODEL in NUMBER,
  X_BSC_MODEL in NUMBER,
  X_CROSS_MODEL in NUMBER,
  X_DEFAULT_MODEL in NUMBER,
  X_ZOOM_FACTOR in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor c is select
      KPI_MODEL,
      BSC_MODEL,
      CROSS_MODEL,
      DEFAULT_MODEL,
      ZOOM_FACTOR
    from BSC_TABS_B
    where TAB_ID = X_TAB_ID
    for update of TAB_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      HELP,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_TABS_TL
    where TAB_ID = X_TAB_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TAB_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.KPI_MODEL = X_KPI_MODEL)
           OR ((recinfo.KPI_MODEL is null) AND (X_KPI_MODEL is null)))
      AND ((recinfo.BSC_MODEL = X_BSC_MODEL)
           OR ((recinfo.BSC_MODEL is null) AND (X_BSC_MODEL is null)))
      AND ((recinfo.CROSS_MODEL = X_CROSS_MODEL)
           OR ((recinfo.CROSS_MODEL is null) AND (X_CROSS_MODEL is null)))
      AND ((recinfo.DEFAULT_MODEL = X_DEFAULT_MODEL)
           OR ((recinfo.DEFAULT_MODEL is null) AND (X_DEFAULT_MODEL is null)))
      AND ((recinfo.ZOOM_FACTOR = X_ZOOM_FACTOR)
           OR ((recinfo.ZOOM_FACTOR is null) AND (X_ZOOM_FACTOR is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND ((tlinfo.HELP = X_HELP)
               OR ((tlinfo.HELP is null) AND (X_HELP is null)))
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

PROCEDURE UPDATE_ROW
(
    X_TAB_ID                  IN NUMBER,
    X_SHORT_NAME              IN VARCHAR2,
    X_KPI_MODEL               IN NUMBER,
    X_BSC_MODEL               IN NUMBER,
    X_CROSS_MODEL             IN NUMBER,
    X_DEFAULT_MODEL           IN NUMBER,
    X_ZOOM_FACTOR             IN NUMBER,
    X_TAB_INDEX               IN NUMBER,
    X_PARENT_TAB_ID           IN NUMBER,
    X_OWNER_ID                IN NUMBER,
    X_LAST_UPDATE_DATE        IN DATE,     /*  DEFAULT SYSDATE */
    X_LAST_UPDATED_BY         IN NUMBER,
    X_NAME                    IN VARCHAR2,
    X_HELP                    IN VARCHAR2,
    X_LAST_UPDATE_LOGIN       IN NUMBER,
    X_ADDITIONAL_INFO         IN VARCHAR2
) IS

BEGIN

IF X_TAB_ID IS NULL THEN
  IF X_SHORT_NAME IS NOT NULL THEN
    UPDATE  BSC_TABS_B
    SET     KPI_MODEL               =   NVL(X_KPI_MODEL, KPI_MODEL),
            BSC_MODEL               =   NVL(X_BSC_MODEL, BSC_MODEL),
            CROSS_MODEL             =   NVL(X_CROSS_MODEL, CROSS_MODEL),
            DEFAULT_MODEL           =   NVL(X_DEFAULT_MODEL, DEFAULT_MODEL),
            ZOOM_FACTOR             =   NVL(X_ZOOM_FACTOR, ZOOM_FACTOR),
            TAB_INDEX               =   NVL(X_TAB_INDEX, TAB_INDEX),
            PARENT_TAB_ID           =   X_PARENT_TAB_ID,
            OWNER_ID                =   X_OWNER_ID,
            SHORT_NAME              =   X_SHORT_NAME,
            LAST_UPDATE_DATE        =   NVL(X_LAST_UPDATE_DATE, SYSDATE),
            LAST_UPDATED_BY         =   X_LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN       =   X_LAST_UPDATE_LOGIN
    WHERE   SHORT_NAME              =   X_SHORT_NAME
    AND     LAST_UPDATE_DATE        <   X_LAST_UPDATE_DATE;
    IF (NOT SQL%NOTFOUND) THEN
        UPDATE   BSC_TABS_TL
        SET      NAME                 =  NVL(X_NAME, NAME),
                 HELP                 =  X_HELP,
                 ADDITIONAL_INFO      =  X_ADDITIONAL_INFO,
                 SOURCE_LANG          =  USERENV('LANG')
        WHERE    TAB_ID               =  (SELECT TAB_ID FROM BSC_TABS_B WHERE SHORT_NAME = X_SHORT_NAME)
        AND      USERENV('LANG')     IN  (LANGUAGE, SOURCE_LANG);
    END IF;
  END IF;
ELSE

    UPDATE  BSC_TABS_B
    SET     KPI_MODEL               =   NVL(X_KPI_MODEL, KPI_MODEL),
            BSC_MODEL               =   NVL(X_BSC_MODEL, BSC_MODEL),
            CROSS_MODEL             =   NVL(X_CROSS_MODEL, CROSS_MODEL),
            DEFAULT_MODEL           =   NVL(X_DEFAULT_MODEL, DEFAULT_MODEL),
            ZOOM_FACTOR             =   NVL(X_ZOOM_FACTOR, ZOOM_FACTOR),
            TAB_INDEX               =   NVL(X_TAB_INDEX, TAB_INDEX),
            PARENT_TAB_ID           =   X_PARENT_TAB_ID,
            OWNER_ID                =   X_OWNER_ID,
            SHORT_NAME              =   X_SHORT_NAME,
            LAST_UPDATE_DATE        =   NVL(X_LAST_UPDATE_DATE, SYSDATE),
            LAST_UPDATED_BY         =   X_LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN       =   X_LAST_UPDATE_LOGIN
    WHERE   TAB_ID                  =   X_TAB_ID;
    IF (NOT SQL%NOTFOUND) THEN
        UPDATE   BSC_TABS_TL
        SET      NAME                 =  NVL(X_NAME, NAME),
                 HELP                 =  HELP,
                 ADDITIONAL_INFO      =  X_ADDITIONAL_INFO,
                 SOURCE_LANG          =  USERENV('LANG')
        WHERE    TAB_ID               =  X_TAB_ID
        AND      USERENV('LANG')     IN  (LANGUAGE, SOURCE_LANG);
    END IF;

END IF;

END UPDATE_ROW;

procedure DELETE_ROW (
  X_TAB_ID in NUMBER
) is
begin
  delete from BSC_TABS_TL
  where TAB_ID = X_TAB_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_TABS_B
  where TAB_ID = X_TAB_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BSC_TABS_TL T
  where not exists
    (select NULL
    from BSC_TABS_B B
    where B.TAB_ID = T.TAB_ID
    );

  update BSC_TABS_TL T set (
      NAME,
      HELP,
      ADDITIONAL_INFO
    ) = (select
      B.NAME,
      B.HELP,
      ADDITIONAL_INFO
    from BSC_TABS_TL B
    where B.TAB_ID = T.TAB_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAB_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TAB_ID,
      SUBT.LANGUAGE
    from BSC_TABS_TL SUBB, BSC_TABS_TL SUBT
    where SUBB.TAB_ID = SUBT.TAB_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.HELP <> SUBT.HELP
      or SUBB.ADDITIONAL_INFO <> SUBT.ADDITIONAL_INFO
      or (SUBB.HELP is null and SUBT.HELP is not null)
      or (SUBB.HELP is not null and SUBT.HELP is null)
      or (SUBB.ADDITIONAL_INFO is not null and SUBT.ADDITIONAL_INFO is null)
  ));

  insert into BSC_TABS_TL (
    TAB_ID,
    NAME,
    HELP,
    ADDITIONAL_INFO,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TAB_ID,
    B.NAME,
    B.HELP,
    ADDITIONAL_INFO,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_TABS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_TABS_TL T
    where T.TAB_ID = B.TAB_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_TABS_PKG;

/
