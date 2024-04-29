--------------------------------------------------------
--  DDL for Package Body CUG_SR_TASK_ATTR_VALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_SR_TASK_ATTR_VALS_PKG" as
/* $Header: CUGSRTVB.pls 115.4 2002/11/28 21:49:28 pkesani noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SR_TASK_ATTR_VAL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TSK_TYP_ATTR_DEPEND_ID in NUMBER,
  X_TASK_TYPE_ATTR_MAP_ID in NUMBER,
  X_TASK_TYPE_ATTR_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CUG_SR_TASK_ATTR_VALS_B
    where SR_TASK_ATTR_VAL_ID = X_SR_TASK_ATTR_VAL_ID
    ;
begin
  insert into CUG_SR_TASK_ATTR_VALS_B (
    SR_TASK_ATTR_VAL_ID,
    OBJECT_VERSION_NUMBER,
    TSK_TYP_ATTR_DEPEND_ID,
    TASK_TYPE_ATTR_MAP_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SR_TASK_ATTR_VAL_ID,
    X_OBJECT_VERSION_NUMBER,
    X_TSK_TYP_ATTR_DEPEND_ID,
    X_TASK_TYPE_ATTR_MAP_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CUG_SR_TASK_ATTR_VALS_TL (
    SR_TASK_ATTR_VAL_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    TASK_TYPE_ATTR_VALUE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SR_TASK_ATTR_VAL_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_TASK_TYPE_ATTR_VALUE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CUG_SR_TASK_ATTR_VALS_TL T
    where T.SR_TASK_ATTR_VAL_ID = X_SR_TASK_ATTR_VAL_ID
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
  X_SR_TASK_ATTR_VAL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TSK_TYP_ATTR_DEPEND_ID in NUMBER,
  X_TASK_TYPE_ATTR_MAP_ID in NUMBER,
  X_TASK_TYPE_ATTR_VALUE in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      TSK_TYP_ATTR_DEPEND_ID,
      TASK_TYPE_ATTR_MAP_ID
    from CUG_SR_TASK_ATTR_VALS_B
    where SR_TASK_ATTR_VAL_ID = X_SR_TASK_ATTR_VAL_ID
    for update of SR_TASK_ATTR_VAL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TASK_TYPE_ATTR_VALUE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CUG_SR_TASK_ATTR_VALS_TL
    where SR_TASK_ATTR_VAL_ID = X_SR_TASK_ATTR_VAL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SR_TASK_ATTR_VAL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND (recinfo.TSK_TYP_ATTR_DEPEND_ID = X_TSK_TYP_ATTR_DEPEND_ID)
      AND (recinfo.TASK_TYPE_ATTR_MAP_ID = X_TASK_TYPE_ATTR_MAP_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TASK_TYPE_ATTR_VALUE = X_TASK_TYPE_ATTR_VALUE)
               OR ((tlinfo.TASK_TYPE_ATTR_VALUE is null) AND (X_TASK_TYPE_ATTR_VALUE is null)))
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
  X_SR_TASK_ATTR_VAL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TSK_TYP_ATTR_DEPEND_ID in NUMBER,
  X_TASK_TYPE_ATTR_MAP_ID in NUMBER,
  X_TASK_TYPE_ATTR_VALUE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CUG_SR_TASK_ATTR_VALS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    TSK_TYP_ATTR_DEPEND_ID = X_TSK_TYP_ATTR_DEPEND_ID,
    TASK_TYPE_ATTR_MAP_ID = X_TASK_TYPE_ATTR_MAP_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SR_TASK_ATTR_VAL_ID = X_SR_TASK_ATTR_VAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CUG_SR_TASK_ATTR_VALS_TL set
    TASK_TYPE_ATTR_VALUE = X_TASK_TYPE_ATTR_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SR_TASK_ATTR_VAL_ID = X_SR_TASK_ATTR_VAL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SR_TASK_ATTR_VAL_ID in NUMBER
) is
begin
  delete from CUG_SR_TASK_ATTR_VALS_TL
  where SR_TASK_ATTR_VAL_ID = X_SR_TASK_ATTR_VAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CUG_SR_TASK_ATTR_VALS_B
  where SR_TASK_ATTR_VAL_ID = X_SR_TASK_ATTR_VAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CUG_SR_TASK_ATTR_VALS_TL T
  where not exists
    (select NULL
    from CUG_SR_TASK_ATTR_VALS_B B
    where B.SR_TASK_ATTR_VAL_ID = T.SR_TASK_ATTR_VAL_ID
    );

  update CUG_SR_TASK_ATTR_VALS_TL T set (
      TASK_TYPE_ATTR_VALUE
    ) = (select
      B.TASK_TYPE_ATTR_VALUE
    from CUG_SR_TASK_ATTR_VALS_TL B
    where B.SR_TASK_ATTR_VAL_ID = T.SR_TASK_ATTR_VAL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SR_TASK_ATTR_VAL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SR_TASK_ATTR_VAL_ID,
      SUBT.LANGUAGE
    from CUG_SR_TASK_ATTR_VALS_TL SUBB, CUG_SR_TASK_ATTR_VALS_TL SUBT
    where SUBB.SR_TASK_ATTR_VAL_ID = SUBT.SR_TASK_ATTR_VAL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TASK_TYPE_ATTR_VALUE <> SUBT.TASK_TYPE_ATTR_VALUE
      or (SUBB.TASK_TYPE_ATTR_VALUE is null and SUBT.TASK_TYPE_ATTR_VALUE is not null)
      or (SUBB.TASK_TYPE_ATTR_VALUE is not null and SUBT.TASK_TYPE_ATTR_VALUE is null)
  ));

  insert into CUG_SR_TASK_ATTR_VALS_TL (
    SR_TASK_ATTR_VAL_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    TASK_TYPE_ATTR_VALUE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.SR_TASK_ATTR_VAL_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.TASK_TYPE_ATTR_VALUE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CUG_SR_TASK_ATTR_VALS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CUG_SR_TASK_ATTR_VALS_TL T
    where T.SR_TASK_ATTR_VAL_ID = B.SR_TASK_ATTR_VAL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CUG_SR_TASK_ATTR_VALS_PKG;

/
