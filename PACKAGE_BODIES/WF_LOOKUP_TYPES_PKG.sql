--------------------------------------------------------
--  DDL for Package Body WF_LOOKUP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_LOOKUP_TYPES_PKG" as
/* $Header: wflutb.pls 120.3 2005/10/04 23:24:11 rtodi ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_ITEM_TYPE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor C is select ROWID from WF_LOOKUP_TYPES_TL
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into WF_LOOKUP_TYPES_TL (
    LOOKUP_TYPE,
    DISPLAY_NAME,
    ITEM_TYPE,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LOOKUP_TYPE,
    X_DISPLAY_NAME,
    X_ITEM_TYPE,
    X_PROTECT_LEVEL,
    X_CUSTOM_LEVEL,
    X_DESCRIPTION,
    L.CODE,
    userenv('LANG')
  from WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and not exists
    (select NULL
    from WF_LOOKUP_TYPES_TL T
    where T.LOOKUP_TYPE = X_LOOKUP_TYPE
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
    wf_core.context('Wf_Lookup_Types_Pkg', 'Insert_Row', x_lookup_type);
    raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_ITEM_TYPE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c1 is select
      ITEM_TYPE,
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      DISPLAY_NAME,
      DESCRIPTION
    from WF_LOOKUP_TYPES_TL
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LANGUAGE = userenv('LANG')
    for update of LOOKUP_TYPE nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    wf_core.raise('WF_RECORD_DELETED');
  end if;
  close c1;

  if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      AND (tlinfo.ITEM_TYPE = X_ITEM_TYPE)
      AND (tlinfo.PROTECT_LEVEL = X_PROTECT_LEVEL)
      AND (tlinfo.CUSTOM_LEVEL = X_CUSTOM_LEVEL)
  ) then
    null;
  else
    wf_core.raise('WF_RECORD_CHANGED');
  end if;
  return;

exception
  when others then
    wf_core.context('Wf_Lookup_Types_Pkg', 'Lock_Row', x_lookup_type);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_ITEM_TYPE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
begin
  update WF_LOOKUP_TYPES_TL set
    ITEM_TYPE = X_ITEM_TYPE,
    PROTECT_LEVEL = X_PROTECT_LEVEL,
    CUSTOM_LEVEL = X_CUSTOM_LEVEL,
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    SOURCE_LANG = userenv('LANG')
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Lookup_Types_Pkg', 'Update_Row', x_lookup_type);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOOKUP_TYPE in VARCHAR2
) is
begin
  delete from WF_LOOKUP_TYPES_TL
  where LOOKUP_TYPE = X_LOOKUP_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Lookup_Types_Pkg', 'Delete_Row', x_lookup_type);
    raise;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* The following update statement is commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  update WF_LOOKUP_TYPES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from WF_LOOKUP_TYPES_TL B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOOKUP_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.LOOKUP_TYPE,
      SUBT.LANGUAGE
    from WF_LOOKUP_TYPES_TL SUBB, WF_LOOKUP_TYPES_TL SUBT
    where SUBB.LOOKUP_TYPE = SUBT.LOOKUP_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

*/

  insert into WF_LOOKUP_TYPES_TL (
    LOOKUP_TYPE,
    DISPLAY_NAME,
    ITEM_TYPE,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LOOKUP_TYPE,
    B.DISPLAY_NAME,
    B.ITEM_TYPE,
    B.PROTECT_LEVEL,
    B.CUSTOM_LEVEL,
    B.DESCRIPTION,
    L.CODE,
    B.SOURCE_LANG
  from WF_LOOKUP_TYPES_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and (B.LOOKUP_TYPE , L.CODE ) NOT IN
    (select  /*+ hash_aj index_ffs(T,WF_LOOKUP_TYPES_TL_PK ) */
       T.LOOKUP_TYPE  ,T.LANGUAGE
            from  WF_LOOKUP_TYPES_TL T);

end ADD_LANGUAGE;

end WF_LOOKUP_TYPES_PKG;

/
