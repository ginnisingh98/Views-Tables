--------------------------------------------------------
--  DDL for Package Body BSC_SYS_DIM_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_DIM_GROUPS_PKG" as
/* $Header: BSCSDMGB.pls 120.0 2005/06/01 16:49:55 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DIM_GROUP_ID in NUMBER,
  X_SHORT_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BSC_SYS_DIM_GROUPS_TL
    where DIM_GROUP_ID = X_DIM_GROUP_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into BSC_SYS_DIM_GROUPS_TL (
    DIM_GROUP_ID,
    SHORT_NAME,
    NAME,
    LANGUAGE,
    SOURCE_LANG,
	  CREATION_DATE ,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY ,
	  LAST_UPDATE_LOGIN
  ) select
    X_DIM_GROUP_ID,
    X_SHORT_NAME,
    X_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG'),
	 X_CREATION_DATE ,
	  X_CREATED_BY,
	  X_LAST_UPDATE_DATE,
	  X_LAST_UPDATED_BY ,
	  X_LAST_UPDATE_LOGIN
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_SYS_DIM_GROUPS_TL T
    where T.DIM_GROUP_ID = X_DIM_GROUP_ID
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
  X_DIM_GROUP_ID in NUMBER,
  X_NAME in VARCHAR2
) is
  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_SYS_DIM_GROUPS_TL
    where DIM_GROUP_ID = X_DIM_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DIM_GROUP_ID nowait;
begin
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

procedure UPDATE_ROW (
  X_DIM_GROUP_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BSC_SYS_DIM_GROUPS_TL set
    NAME = X_NAME,
    SOURCE_LANG = userenv('LANG'),
    LAST_UPDATE_DATE = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_DATE,LAST_UPDATE_DATE),
    LAST_UPDATED_BY = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATED_BY,LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_LOGIN,LAST_UPDATE_LOGIN)
  where DIM_GROUP_ID = X_DIM_GROUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DIM_GROUP_ID in NUMBER
) is
begin
  delete from BSC_SYS_DIM_GROUPS_TL
  where DIM_GROUP_ID = X_DIM_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update BSC_SYS_DIM_GROUPS_TL T set (
      NAME
    ) = (select
      B.NAME
    from BSC_SYS_DIM_GROUPS_TL B
    where B.DIM_GROUP_ID = T.DIM_GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DIM_GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DIM_GROUP_ID,
      SUBT.LANGUAGE
    from BSC_SYS_DIM_GROUPS_TL SUBB, BSC_SYS_DIM_GROUPS_TL SUBT
    where SUBB.DIM_GROUP_ID = SUBT.DIM_GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into BSC_SYS_DIM_GROUPS_TL (
    DIM_GROUP_ID,
    SHORT_NAME,
    NAME,
    LANGUAGE,
    SOURCE_LANG,
    CREATION_DATE ,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) select
    B.DIM_GROUP_ID,
    B.SHORT_NAME,
    B.NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.CREATION_DATE ,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY
  from BSC_SYS_DIM_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_SYS_DIM_GROUPS_TL T
    where T.DIM_GROUP_ID = B.DIM_GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_SYS_DIM_GROUPS_PKG;

/
