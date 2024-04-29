--------------------------------------------------------
--  DDL for Package Body FPA_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_OBJECTS_PKG" as
/* $Header: FPASPRCB.pls 120.3 2006/01/19 12:05:45 sishanmu noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ID in NUMBER,
  X_OBJECT in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FPA_OBJECTS_TL
    where ID = X_ID
    and OBJECT = X_OBJECT
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into FPA_OBJECTS_TL (
    OBJECT,
    ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OBJECT,
    X_ID,
    X_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FPA_OBJECTS_TL T
    where T.ID = X_ID
    and T.OBJECT = X_OBJECT
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
  X_ID in NUMBER,
  X_OBJECT in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FPA_OBJECTS_TL
    where ID = X_ID
    and OBJECT = X_OBJECT
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ID nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_ID in NUMBER,
  X_OBJECT in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FPA_OBJECTS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ID = X_ID
  and OBJECT = X_OBJECT
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ID in NUMBER,
  X_OBJECT in VARCHAR2
) is
begin
  delete from FPA_OBJECTS_TL
  where ID = X_ID
  and OBJECT = X_OBJECT;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update FPA_OBJECTS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from FPA_OBJECTS_TL B
    where B.ID = T.ID
    and B.OBJECT = T.OBJECT
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ID,
      T.OBJECT,
      T.LANGUAGE
  ) in (select
      SUBT.ID,
      SUBT.OBJECT,
      SUBT.LANGUAGE
    from FPA_OBJECTS_TL SUBB, FPA_OBJECTS_TL SUBT
    where SUBB.ID = SUBT.ID
    and SUBB.OBJECT = SUBT.OBJECT
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FPA_OBJECTS_TL (
    OBJECT,
    ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.OBJECT,
    B.ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FPA_OBJECTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FPA_OBJECTS_TL T
    where T.ID = B.ID
    and T.OBJECT = B.OBJECT
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  P_OBJECT_ID in NUMBER,
  P_OBJECT_NAME in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_OWNER in VARCHAR2
) is
begin

  update fpa_objects_tl set
    NAME = P_NAME,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(P_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where ID = P_OBJECT_ID
  and OBJECT = P_OBJECT_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;

procedure LOAD_ROW(
  P_OBJECT_ID in NUMBER,
  P_OBJECT_NAME in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_OWNER in VARCHAR2
) is

  user_id NUMBER;
  l_rowid VARCHAR2(64);

begin

  if (P_OWNER = 'SEED')then
   user_id := 1;
  else
   user_id :=0;
  end if;

  FPA_OBJECTS_PKG.UPDATE_ROW (
    X_ID                 =>    P_OBJECT_ID,
    X_OBJECT             =>    P_OBJECT_NAME,
    X_NAME               =>    P_NAME,
    X_DESCRIPTION        =>    P_DESCRIPTION,
    X_LAST_UPDATE_DATE   =>    sysdate,
    X_LAST_UPDATED_BY    =>    user_id,
    X_LAST_UPDATE_LOGIN  =>    0);

  EXCEPTION
    WHEN no_data_found then
        FPA_OBJECTS_PKG.INSERT_ROW (
    X_ROWID              =>  l_rowid,
    X_ID                 =>    P_OBJECT_ID,
    X_OBJECT             =>    P_OBJECT_NAME,
    X_NAME               =>    P_NAME,
    X_DESCRIPTION        =>    P_DESCRIPTION,
    X_CREATION_DATE                   =>  sysdate               ,
    X_CREATED_BY                      =>  user_id               ,
    X_LAST_UPDATE_DATE                =>  sysdate               ,
    X_LAST_UPDATED_BY                 =>  user_id               ,
    X_LAST_UPDATE_LOGIN               =>  0                     );
end LOAD_ROW;

end FPA_OBJECTS_PKG;

/
