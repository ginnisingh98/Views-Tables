--------------------------------------------------------
--  DDL for Package Body WF_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_LOOKUPS_PKG" as
/* $Header: wflucb.pls 120.1 2005/07/02 03:49:32 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor C is select ROWID from WF_LOOKUPS_TL
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LOOKUP_CODE = X_LOOKUP_CODE
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into WF_LOOKUPS_TL (
    LOOKUP_TYPE,
    LOOKUP_CODE,
    MEANING,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LOOKUP_TYPE,
    X_LOOKUP_CODE,
    X_MEANING,
    X_PROTECT_LEVEL,
    X_CUSTOM_LEVEL,
    X_DESCRIPTION,
    L.CODE,
    userenv('LANG')
  from WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and not exists
    (select NULL
    from WF_LOOKUPS_TL T
    where T.LOOKUP_TYPE = X_LOOKUP_TYPE
    and T.LOOKUP_CODE = X_LOOKUP_CODE
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
    wf_core.context('Wf_Lookups_Pkg', 'Insert_Row',
        x_lookup_type, x_lookup_code);
    raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c1 is select
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      MEANING,
      DESCRIPTION
    from WF_LOOKUPS_TL
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LOOKUP_CODE = X_LOOKUP_CODE
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

  if (    (tlinfo.MEANING = X_MEANING)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
    wf_core.context('Wf_Lookups_Pkg', 'Lock_Row',
        x_lookup_type, x_lookup_code);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
begin
  update WF_LOOKUPS_TL set
    PROTECT_LEVEL = X_PROTECT_LEVEL,
    CUSTOM_LEVEL = X_CUSTOM_LEVEL,
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    SOURCE_LANG = userenv('LANG')
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Lookups_Pkg', 'Update_Row',
        x_lookup_type, x_lookup_code);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2
) is
begin
  delete from WF_LOOKUPS_TL
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Lookups_Pkg', 'Delete_Row',
        x_lookup_type, x_lookup_code);
    raise;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  update WF_LOOKUPS_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from WF_LOOKUPS_TL B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    and B.LOOKUP_CODE = T.LOOKUP_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOOKUP_TYPE,
      T.LOOKUP_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.LOOKUP_TYPE,
      SUBT.LOOKUP_CODE,
      SUBT.LANGUAGE
    from WF_LOOKUPS_TL SUBB, WF_LOOKUPS_TL SUBT
    where SUBB.LOOKUP_TYPE = SUBT.LOOKUP_TYPE
    and SUBB.LOOKUP_CODE = SUBT.LOOKUP_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into WF_LOOKUPS_TL (
    LOOKUP_TYPE,
    LOOKUP_CODE,
    MEANING,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LOOKUP_TYPE,
    B.LOOKUP_CODE,
    B.MEANING,
    B.PROTECT_LEVEL,
    B.CUSTOM_LEVEL,
    B.DESCRIPTION,
    L.CODE,
    B.SOURCE_LANG
  from WF_LOOKUPS_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and (B.LOOKUP_TYPE ,B.LOOKUP_CODE ,L.CODE  ) NOT IN
    (select  /*+ hash_aj index_ffs(T,WF_LOOKUPS_TL_PK ) */
       T.LOOKUP_TYPE  ,  T.LOOKUP_CODE , T.LANGUAGE
            from  WF_LOOKUPS_TL T );

end ADD_LANGUAGE;

end WF_LOOKUPS_PKG;

/
