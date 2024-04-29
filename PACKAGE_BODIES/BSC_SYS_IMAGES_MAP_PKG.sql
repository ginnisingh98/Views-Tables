--------------------------------------------------------
--  DDL for Package Body BSC_SYS_IMAGES_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_IMAGES_MAP_PKG" as
/* $Header: BSCSSIMB.pls 115.7 2004/03/04 16:23:36 meastmon ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_TYPE in NUMBER,
  X_IMAGE_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BSC_SYS_IMAGES_MAP_TL
    where SOURCE_TYPE = X_SOURCE_TYPE
    and SOURCE_CODE = X_SOURCE_CODE
    and TYPE = X_TYPE
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into BSC_SYS_IMAGES_MAP_TL (
    SOURCE_TYPE,
    SOURCE_CODE,
    TYPE,
    IMAGE_ID,
    CREATION_DATE ,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY ,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
	  X_SOURCE_TYPE,
	  X_SOURCE_CODE,
	  X_TYPE,
	  X_IMAGE_ID,
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
    from BSC_SYS_IMAGES_MAP_TL T
    where T.SOURCE_TYPE = X_SOURCE_TYPE
    and T.SOURCE_CODE = X_SOURCE_CODE
    and T.TYPE = X_TYPE
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
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_TYPE in NUMBER,
  X_IMAGE_ID in NUMBER
) is
  cursor c1 is select
        IMAGE_ID,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_SYS_IMAGES_MAP_TL
    where SOURCE_TYPE = X_SOURCE_TYPE
    and SOURCE_CODE = X_SOURCE_CODE
    and TYPE = X_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SOURCE_TYPE nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.IMAGE_ID = X_IMAGE_ID)
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
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_TYPE in NUMBER,
  X_IMAGE_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BSC_SYS_IMAGES_MAP_TL set
     IMAGE_ID = X_IMAGE_ID,
     LAST_UPDATE_DATE = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_DATE,LAST_UPDATE_DATE),
     LAST_UPDATED_BY = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATED_BY,LAST_UPDATED_BY),
     LAST_UPDATE_LOGIN = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_LOGIN,LAST_UPDATE_LOGIN),
     SOURCE_LANG = userenv('LANG')
  where SOURCE_TYPE = X_SOURCE_TYPE
  and SOURCE_CODE = X_SOURCE_CODE
  and TYPE = X_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_TYPE in NUMBER
) is
begin
  delete from BSC_SYS_IMAGES_MAP_TL
  where SOURCE_TYPE = X_SOURCE_TYPE
  and SOURCE_CODE = X_SOURCE_CODE
  and TYPE = X_TYPE;

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

  update BSC_SYS_IMAGES_MAP_TL T set (
    IMAGE_ID
    ) = (select
      B.IMAGE_ID
    from BSC_SYS_IMAGES_MAP_TL B
    where B.SOURCE_TYPE = T.SOURCE_TYPE
    and B.SOURCE_CODE = T.SOURCE_CODE
    and B.TYPE = T.TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SOURCE_TYPE,
      T.SOURCE_CODE,
      T.TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.SOURCE_TYPE,
      SUBT.SOURCE_CODE,
      SUBT.TYPE,
      SUBT.LANGUAGE
    from BSC_SYS_IMAGES_MAP_TL SUBB, BSC_SYS_IMAGES_MAP_TL SUBT
    where SUBB.SOURCE_TYPE = SUBT.SOURCE_TYPE
    and SUBB.SOURCE_CODE = SUBT.SOURCE_CODE
    and SUBB.TYPE = SUBT.TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.IMAGE_ID <> SUBT.IMAGE_ID
  ));

  insert into BSC_SYS_IMAGES_MAP_TL (
    SOURCE_TYPE,
    SOURCE_CODE,
    TYPE,
    IMAGE_ID,
    CREATION_DATE ,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY ,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SOURCE_TYPE,
    B.SOURCE_CODE,
    B.TYPE,
      B.IMAGE_ID,
      SYSDATE,
    l_user,
    SYSDATE,
    l_user,
    l_user,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_SYS_IMAGES_MAP_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_SYS_IMAGES_MAP_TL T
    where T.SOURCE_TYPE = B.SOURCE_TYPE
    and T.SOURCE_CODE = B.SOURCE_CODE
    and T.TYPE = B.TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_SYS_IMAGES_MAP_PKG;

/
