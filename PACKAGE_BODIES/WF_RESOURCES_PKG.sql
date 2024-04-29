--------------------------------------------------------
--  DDL for Package Body WF_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_RESOURCES_PKG" as
/* $Header: wfresb.pls 120.1 2005/07/02 03:53:07 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_ID in NUMBER,
  X_TEXT in VARCHAR2
) is
  cursor C is select ROWID from WF_RESOURCES
    where NAME = X_NAME
    and TYPE = X_TYPE
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into WF_RESOURCES (
    TYPE,
    NAME,
    ID,
    TEXT,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TYPE,
    X_NAME,
    X_ID,
    REPLACE(X_TEXT, WF_CORE.CR),
    X_PROTECT_LEVEL,
    X_CUSTOM_LEVEL,
    L.CODE,
    userenv('LANG')
  from WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and not exists
    (select NULL
    from WF_RESOURCES T
    where T.NAME = X_NAME
    and T.TYPE = X_TYPE
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
    wf_core.context('Wf_Resources_Pkg', 'Insert_Row',
        x_name, x_type);
    raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_ID in NUMBER,
  X_TEXT in VARCHAR2
) is
  cursor c1 is select
      ID,
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      TEXT
    from WF_RESOURCES
    where NAME = X_NAME
    and TYPE = X_TYPE
    and LANGUAGE = userenv('LANG')
    for update of NAME nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    wf_core.raise('WF_RECORD_DELETED');
  end if;
  close c1;

  if (    (tlinfo.TEXT = X_TEXT)
      AND (tlinfo.ID = X_ID)
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
    wf_core.context('Wf_Resources_Pkg', 'Lock_Row',
        x_name, x_type);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_ID in NUMBER,
  X_TEXT in VARCHAR2
) is
begin
  update WF_RESOURCES set
    ID = X_ID,
    PROTECT_LEVEL = X_PROTECT_LEVEL,
    CUSTOM_LEVEL = X_CUSTOM_LEVEL,
    TEXT = REPLACE(X_TEXT, WF_CORE.CR),
    SOURCE_LANG = userenv('LANG')
  where NAME = X_NAME
  and TYPE = X_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Resources_Pkg', 'Update_Row',
        x_name, x_type);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2
) is
begin
  delete from WF_RESOURCES
  where NAME = X_NAME
  and TYPE = X_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Resources_Pkg', 'Delete_Row',
        x_name, x_type);
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

  update WF_RESOURCES T set (
      TEXT
    ) = (select
      B.TEXT
    from WF_RESOURCES B
    where B.NAME = T.NAME
    and B.TYPE = T.TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.NAME,
      T.TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.NAME,
      SUBT.TYPE,
      SUBT.LANGUAGE
    from WF_RESOURCES SUBB, WF_RESOURCES SUBT
    where SUBB.NAME = SUBT.NAME
    and SUBB.TYPE = SUBT.TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEXT <> SUBT.TEXT
  ));
*/

  insert into WF_RESOURCES (
    TYPE,
    NAME,
    ID,
    TEXT,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TYPE,
    B.NAME,
    B.ID,
    B.TEXT,
    B.PROTECT_LEVEL,
    B.CUSTOM_LEVEL,
    L.CODE,
    B.SOURCE_LANG
  from WF_RESOURCES B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and ( B.NAME ,B.TYPE ,L.CODE) NOT IN
      (select  /*+ hash_aj index_ffs(T,WF_RESOURCES_PK ) */
       T.NAME ,T.TYPE  , T.LANGUAGE
            from   WF_RESOURCES T);
end ADD_LANGUAGE;

end WF_RESOURCES_PKG;

/
