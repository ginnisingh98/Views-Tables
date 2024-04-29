--------------------------------------------------------
--  DDL for Package Body BSC_SYS_PERIODICITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_PERIODICITIES_PKG" as
/* $Header: BSCSPERB.pls 115.7 2004/03/04 16:22:54 meastmon ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERIODICITY_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BSC_SYS_PERIODICITIES_TL
    where PERIODICITY_ID = X_PERIODICITY_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into BSC_SYS_PERIODICITIES_TL (
    PERIODICITY_ID,
    NAME,
    CREATION_DATE ,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY ,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
	  X_PERIODICITY_ID,
	  X_NAME,
	  X_CREATION_DATE ,
	  X_CREATED_BY,
	  X_LAST_UPDATE_DATE,
	  X_LAST_UPDATED_BY ,
	  X_LAST_UPDATE_LOGIN,
	  L.LANGUAGE_CODE,
	  userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_SYS_PERIODICITIES_TL T
    where T.PERIODICITY_ID = X_PERIODICITY_ID
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
  X_PERIODICITY_ID in NUMBER,
  X_NAME in VARCHAR2
) is
  cursor c1 is select
        NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_SYS_PERIODICITIES_TL
    where PERIODICITY_ID = X_PERIODICITY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PERIODICITY_ID nowait;
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
  X_PERIODICITY_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BSC_SYS_PERIODICITIES_TL set
     NAME = X_NAME,
     LAST_UPDATE_DATE = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_DATE,LAST_UPDATE_DATE),
     LAST_UPDATED_BY = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATED_BY,LAST_UPDATED_BY),
     LAST_UPDATE_LOGIN = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_LOGIN,LAST_UPDATE_LOGIN),
     SOURCE_LANG = userenv('LANG')
  where PERIODICITY_ID = X_PERIODICITY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PERIODICITY_ID in NUMBER
) is
begin
  delete from BSC_SYS_PERIODICITIES_TL
  where PERIODICITY_ID = X_PERIODICITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
l_user NUMBER;
begin

  -- Ref: bug#3482442 In corner cases this query can return more than one
  -- row and it will fail. AUDSID is not PK. After meeting with
  -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
  l_user := BSC_APPS.fnd_global_user_id;

  update BSC_SYS_PERIODICITIES_TL T set (
    NAME
    ) = (select
      B.NAME
    from BSC_SYS_PERIODICITIES_TL B
    where B.PERIODICITY_ID = T.PERIODICITY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PERIODICITY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PERIODICITY_ID,
      SUBT.LANGUAGE
    from BSC_SYS_PERIODICITIES_TL SUBB, BSC_SYS_PERIODICITIES_TL SUBT
    where SUBB.PERIODICITY_ID = SUBT.PERIODICITY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into BSC_SYS_PERIODICITIES_TL (
    PERIODICITY_ID,
    NAME,
    CREATION_DATE ,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY ,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PERIODICITY_ID,
    B.NAME,
    SYSDATE,
    l_user,
    SYSDATE,
    l_user,
    l_user,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_SYS_PERIODICITIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_SYS_PERIODICITIES_TL T
    where T.PERIODICITY_ID = B.PERIODICITY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_SYS_PERIODICITIES_PKG;

/
