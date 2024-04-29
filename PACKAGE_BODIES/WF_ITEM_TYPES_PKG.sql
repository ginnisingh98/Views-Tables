--------------------------------------------------------
--  DDL for Package Body WF_ITEM_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ITEM_TYPES_PKG" as
/* $Header: wfittb.pls 120.3 2005/10/04 05:13:04 rtodi ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_WF_SELECTOR in VARCHAR2,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_EXECUTE_ROLE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PERSISTENCE_TYPE in VARCHAR2,
  X_PERSISTENCE_DAYS in NUMBER
) is
  cursor C is select ROWID from WF_ITEM_TYPES
    where NAME = X_NAME
    ;
begin
  insert into WF_ITEM_TYPES (
    NAME,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    WF_SELECTOR,
    READ_ROLE,
    WRITE_ROLE,
    EXECUTE_ROLE,
    PERSISTENCE_TYPE,
    PERSISTENCE_DAYS
  ) values (
    X_NAME,
    X_PROTECT_LEVEL,
    X_CUSTOM_LEVEL,
    X_WF_SELECTOR,
    X_READ_ROLE,
    X_WRITE_ROLE,
    X_EXECUTE_ROLE,
    X_PERSISTENCE_TYPE,
    X_PERSISTENCE_DAYS
  );

  insert into WF_ITEM_TYPES_TL (
    NAME,
    DISPLAY_NAME,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_NAME,
    X_DISPLAY_NAME,
    X_PROTECT_LEVEL,
    X_CUSTOM_LEVEL,
    X_DESCRIPTION,
    L.CODE,
    userenv('LANG')
  from WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and not exists
    (select NULL
    from WF_ITEM_TYPES_TL T
    where T.NAME = X_NAME
    and T.LANGUAGE = L.CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

exception
  when others then
    wf_core.context('Wf_Item_Types_Pkg', 'Insert_Row', x_name);
    raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_WF_SELECTOR in VARCHAR2,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_EXECUTE_ROLE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      WF_SELECTOR,
      READ_ROLE,
      WRITE_ROLE,
      EXECUTE_ROLE
    from WF_ITEM_TYPES
    where NAME = X_NAME
    for update of NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION
    from WF_ITEM_TYPES_TL
    where NAME = X_NAME
    and LANGUAGE = userenv('LANG')
    for update of NAME nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    wf_core.raise('WF_RECORD_DELETED');
  end if;
  close c;
  if (    (recinfo.PROTECT_LEVEL = X_PROTECT_LEVEL)
      AND (recinfo.CUSTOM_LEVEL = X_CUSTOM_LEVEL)
      AND ((recinfo.WF_SELECTOR = X_WF_SELECTOR)
           OR ((recinfo.WF_SELECTOR is null) AND (X_WF_SELECTOR is null)))
      AND ((recinfo.READ_ROLE = X_READ_ROLE)
           OR ((recinfo.READ_ROLE is null) AND (X_READ_ROLE is null)))
      AND ((recinfo.WRITE_ROLE = X_WRITE_ROLE)
           OR ((recinfo.WRITE_ROLE is null) AND (X_WRITE_ROLE is null)))
      AND ((recinfo.EXECUTE_ROLE = X_EXECUTE_ROLE)
           OR ((recinfo.EXECUTE_ROLE is null) AND (X_EXECUTE_ROLE is null)))
  ) then
    null;
  else
    wf_core.raise('WF_RECORD_CHANGED');
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    wf_core.raise('WF_RECORD_CHANGED');
  end if;
  return;
exception
  when others then
    wf_core.context('Wf_Item_Types_Pkg', 'Lock_Row', x_name);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_WF_SELECTOR in VARCHAR2,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_EXECUTE_ROLE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PERSISTENCE_TYPE in VARCHAR2,
  X_PERSISTENCE_DAYS in NUMBER
) is
begin
  update WF_ITEM_TYPES set
    PROTECT_LEVEL = X_PROTECT_LEVEL,
    CUSTOM_LEVEL = X_CUSTOM_LEVEL,
    WF_SELECTOR = X_WF_SELECTOR,
    READ_ROLE = X_READ_ROLE,
    WRITE_ROLE = X_WRITE_ROLE,
    EXECUTE_ROLE = X_EXECUTE_ROLE,
    PERSISTENCE_TYPE = X_PERSISTENCE_TYPE,
    PERSISTENCE_DAYS = X_PERSISTENCE_DAYS
  where NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WF_ITEM_TYPES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    SOURCE_LANG = userenv('LANG')
  where NAME = X_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
exception
  when others then
    wf_core.context('Wf_Item_Types_Pkg', 'Update_Row', x_name);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_NAME in VARCHAR2
) is
begin
  delete from WF_ITEM_TYPES_TL
  where NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WF_ITEM_TYPES
  where NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Item_Types_Pkg', 'Delete_Row', x_name);
    raise;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from WF_ITEM_TYPES_TL T
  where not exists
    (select NULL
    from WF_ITEM_TYPES B
    where B.NAME = T.NAME
    );

  update WF_ITEM_TYPES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from WF_ITEM_TYPES_TL B
    where B.NAME = T.NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.NAME,
      T.LANGUAGE
  ) in (select
      SUBT.NAME,
      SUBT.LANGUAGE
    from WF_ITEM_TYPES_TL SUBB, WF_ITEM_TYPES_TL SUBT
    where SUBB.NAME = SUBT.NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));


*/
  insert into WF_ITEM_TYPES_TL (
    NAME,
    DISPLAY_NAME,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.NAME,
    B.DISPLAY_NAME,
    B.PROTECT_LEVEL,
    B.CUSTOM_LEVEL,
    B.DESCRIPTION,
    L.CODE,
    B.SOURCE_LANG
  from WF_ITEM_TYPES_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and (b.name,l.code) NOT IN
      (select /*+ hash_aj index_ffs(T,WF_ITEM_TYPES_TL_PK) */
       T.NAME,T.LANGUAGE
      from WF_ITEM_TYPES_TL T) ;

end ADD_LANGUAGE;

end WF_ITEM_TYPES_PKG;

/
