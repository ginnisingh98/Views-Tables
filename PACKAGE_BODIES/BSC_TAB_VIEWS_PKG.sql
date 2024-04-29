--------------------------------------------------------
--  DDL for Package Body BSC_TAB_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_TAB_VIEWS_PKG" as
/* $Header: BSCTBVWB.pls 115.6 2003/03/27 11:59:53 adeulgao ship $ */
PROCEDURE TRANSLATE_ROW
(
    X_TAB_ID            IN      NUMBER,
    X_TAB_VIEW_ID       IN      NUMBER,
    X_NAME              IN      VARCHAR2,
    X_HELP              IN      VARCHAR2,
    X_LAST_UPDATE_DATE  IN      DATE,
    X_LAST_UPDATED_BY   IN      NUMBER,
    X_LAST_UPDATE_LOGIN IN      NUMBER
) IS
    L_TAB           NUMBER := -1;
BEGIN
    SELECT COUNT(*) INTO L_TAB   FROM BSC_TAB_VIEWS_TL WHERE  TAB_ID = X_TAB_ID AND TAB_VIEW_ID = X_TAB_VIEW_ID;
    IF (L_TAB > 0) THEN
        UPDATE  BSC_TAB_VIEWS_TL SET
                NAME              =   NVL(X_NAME,            NAME),
                HELP              =   NVL(X_HELP,            HELP),
                LAST_UPDATE_DATE  =   NVL(X_LAST_UPDATE_DATE, SYSDATE),
                LAST_UPDATED_BY   =   X_LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN =   X_LAST_UPDATE_LOGIN,
                SOURCE_LANG       =   USERENV('LANG')
        WHERE   USERENV('LANG')   IN  (LANGUAGE, SOURCE_LANG)
        AND     TAB_ID            =   X_TAB_ID
        AND     TAB_VIEW_ID       =   X_TAB_VIEW_ID
        AND     LAST_UPDATE_DATE  <=  X_LAST_UPDATE_DATE;
    ELSE
        RAISE NO_DATA_FOUND;
    END IF;

END TRANSLATE_ROW;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TAB_ID in NUMBER,
  X_TAB_VIEW_ID in NUMBER,
  X_ENABLED_FLAG in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BSC_TAB_VIEWS_B
    where TAB_ID = X_TAB_ID
    and TAB_VIEW_ID = X_TAB_VIEW_ID
    ;
begin
  insert into BSC_TAB_VIEWS_B (
	  TAB_ID,
	  TAB_VIEW_ID,
	  ENABLED_FLAG,
	  CREATION_DATE ,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY ,
	  LAST_UPDATE_LOGIN
  ) values (
	  X_TAB_ID,
	  X_TAB_VIEW_ID,
	  X_ENABLED_FLAG,
	  NVL(X_CREATION_DATE, SYSDATE),
	  X_CREATED_BY,
	  NVL(X_LAST_UPDATE_DATE, SYSDATE),
	  X_LAST_UPDATED_BY ,
	  X_LAST_UPDATE_LOGIN
  );
  insert into BSC_TAB_VIEWS_TL (
	  TAB_ID,
	  TAB_VIEW_ID,
	  NAME,
	  HELP,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY ,
	  LAST_UPDATE_LOGIN,
    	  LANGUAGE,
	  SOURCE_LANG
  ) select
	X_TAB_ID,
	X_TAB_VIEW_ID,
	X_NAME,
	X_HELP,
	NVL(X_CREATION_DATE , SYSDATE),
	X_CREATED_BY,
	NVL(X_LAST_UPDATE_DATE, SYSDATE),
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_LOGIN,
        L.LANGUAGE_CODE,
        userenv('LANG')
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
      and not exists
        (select NULL
        from BSC_TAB_VIEWS_TL T
          where T.TAB_ID = X_TAB_ID
          and T.TAB_VIEW_ID = X_TAB_VIEW_ID
          and T.LANGUAGE = L.LANGUAGE_CODE);
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_TAB_ID in NUMBER,
  X_TAB_VIEW_ID in NUMBER,
  X_ENABLED_FLAG in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG
    from BSC_TAB_VIEWS_B
    where TAB_ID = X_TAB_ID
    and TAB_VIEW_ID = X_TAB_VIEW_ID
    for update of TAB_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      HELP,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_TAB_VIEWS_TL
    where TAB_ID = X_TAB_ID
    and TAB_VIEW_ID = X_TAB_VIEW_ID
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
  if (    (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND (tlinfo.HELP = X_HELP)
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

procedure UPDATE_ROW (
  X_TAB_ID in NUMBER,
  X_TAB_VIEW_ID in NUMBER,
  X_ENABLED_FLAG in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BSC_TAB_VIEWS_B
    SET     ENABLED_FLAG        =   NVL(X_ENABLED_FLAG, ENABLED_FLAG),
            LAST_UPDATE_DATE    =   NVL(X_LAST_UPDATE_DATE, SYSDATE),
            LAST_UPDATED_BY     =   NVL(X_LAST_UPDATED_BY, LAST_UPDATED_BY),
            LAST_UPDATE_LOGIN   =   NVL(X_LAST_UPDATE_LOGIN, LAST_UPDATE_LOGIN)
  where TAB_ID = X_TAB_ID
    AND     TAB_VIEW_ID         =   X_TAB_VIEW_ID
    AND     LAST_UPDATE_DATE   <=   NVL(X_LAST_UPDATE_DATE, SYSDATE);
  if (sql%notfound) then
    raise no_data_found;
  end if;
  update BSC_TAB_VIEWS_TL set
    NAME = NVL(X_NAME, NAME),
    HELP = NVL(X_HELP, HELP),
    SOURCE_LANG = userenv('LANG')
  where TAB_ID = X_TAB_ID
    and TAB_VIEW_ID = X_TAB_VIEW_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TAB_ID in NUMBER,
  X_TAB_VIEW_ID in NUMBER
) is
begin
  delete from BSC_TAB_VIEWS_TL
  where TAB_ID = X_TAB_ID
  and TAB_VIEW_ID = X_TAB_VIEW_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_TAB_VIEWS_B
  where TAB_ID = X_TAB_ID
  and TAB_VIEW_ID = X_TAB_VIEW_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
l_user NUMBER;
begin

  SELECT VS.USER#
  INTO  l_user
  FROM V$SESSION VS WHERE VS.AUDSID =USERENV('SESSIONID');

  delete from BSC_TAB_VIEWS_TL T
  where not exists
    (select NULL
    from BSC_TAB_VIEWS_B B
    where B.TAB_ID = T.TAB_ID
    and B.TAB_VIEW_ID = T.TAB_VIEW_ID
    );

  update BSC_TAB_VIEWS_TL T set (
      NAME,
      HELP
    ) = (select
      B.NAME,
      B.HELP
    from BSC_TAB_VIEWS_TL B
    where B.TAB_ID = T.TAB_ID
    and B.TAB_VIEW_ID = T.TAB_VIEW_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAB_ID,
      T.TAB_VIEW_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TAB_ID,
      SUBT.TAB_VIEW_ID,
      SUBT.LANGUAGE
    from BSC_TAB_VIEWS_TL SUBB, BSC_TAB_VIEWS_TL SUBT
    where SUBB.TAB_ID = SUBT.TAB_ID
    and SUBB.TAB_VIEW_ID = SUBT.TAB_VIEW_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.HELP <> SUBT.HELP
  ));

  insert into BSC_TAB_VIEWS_TL (
    TAB_ID,
    TAB_VIEW_ID,
    NAME,
    HELP,
    CREATION_DATE ,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY ,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TAB_ID,
    B.TAB_VIEW_ID,
    B.NAME,
    B.HELP,
    SYSDATE,
    l_user,
    SYSDATE,
    l_user,
    l_user,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_TAB_VIEWS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_TAB_VIEWS_TL T
    where T.TAB_ID = B.TAB_ID
    and T.TAB_VIEW_ID = B.TAB_VIEW_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_TAB_VIEWS_PKG;

/
