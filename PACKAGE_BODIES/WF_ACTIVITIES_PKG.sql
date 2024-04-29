--------------------------------------------------------
--  DDL for Package Body WF_ACTIVITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ACTIVITIES_PKG" as
/* $Header: wfactb.pls 120.3 2006/08/24 06:59:16 hgandiko ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ITEM_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_VERSION in NUMBER,
  X_TYPE in VARCHAR2,
  X_RERUN in VARCHAR2,
  X_EXPAND_ROLE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_BEGIN_DATE in DATE,
  X_END_DATE in DATE,
  X_FUNCTION in VARCHAR2,
  X_FUNCTION_TYPE in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_COST in NUMBER,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_EXECUTE_ROLE in VARCHAR2,
  X_ICON_NAME in VARCHAR2,
  X_MESSAGE in VARCHAR2,
  X_ERROR_PROCESS in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ERROR_ITEM_TYPE in VARCHAR2,
  X_RUNNABLE_FLAG in VARCHAR2,
  X_EVENT_FILTER in VARCHAR2 ,
  X_EVENT_TYPE in VARCHAR2
) is
  cursor C is select ROWID from WF_ACTIVITIES
    where ITEM_TYPE = X_ITEM_TYPE
    and NAME = X_NAME
    and VERSION = X_VERSION
    ;
  old_version number default '';
  dummy number;
begin
  insert into WF_ACTIVITIES (
    ITEM_TYPE,
    NAME,
    VERSION,
    TYPE,
    RERUN,
    EXPAND_ROLE,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    BEGIN_DATE,
    END_DATE,
    FUNCTION,
    FUNCTION_TYPE,
    RESULT_TYPE,
    COST,
    READ_ROLE,
    WRITE_ROLE,
    EXECUTE_ROLE,
    ICON_NAME,
    MESSAGE,
    ERROR_PROCESS ,
    ERROR_ITEM_TYPE,
    RUNNABLE_FLAG,
    EVENT_NAME,
    DIRECTION
  ) values (
    X_ITEM_TYPE,
    X_NAME,
    X_VERSION,
    X_TYPE,
    X_RERUN,
    X_EXPAND_ROLE,
    X_PROTECT_LEVEL,
    X_CUSTOM_LEVEL,
    X_BEGIN_DATE,
    X_END_DATE,
    X_FUNCTION,
    X_FUNCTION_TYPE,
    X_RESULT_TYPE,
    X_COST,
    X_READ_ROLE,
    X_WRITE_ROLE,
    X_EXECUTE_ROLE,
    X_ICON_NAME,
    X_MESSAGE,
    X_ERROR_PROCESS,
    X_ERROR_ITEM_TYPE,
    X_RUNNABLE_FLAG,
    X_EVENT_FILTER,
    X_EVENT_TYPE
  );

  -- *** VERSION CUSTOMIZATION
  -- Insert translations.  Default the translations for all but the
  -- current language from a previous version of this activity, if one
  -- is available.
  -- Note: Use _VL instead of base table to prevent _tl integrity errors
  -- from propagating.
  select max(WA.VERSION)
  into old_version
  from WF_ACTIVITIES_VL WA
  where WA.ITEM_TYPE = X_ITEM_TYPE
  and WA.NAME = X_NAME
  and WA.VERSION < X_VERSION;

  if (old_version is not null) then
    insert into WF_ACTIVITIES_TL (
      ITEM_TYPE,
      NAME,
      VERSION,
      DISPLAY_NAME,
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG
    ) select
      X_ITEM_TYPE,
      X_NAME,
      X_VERSION,
      decode(L.CODE,
             userenv('LANG'), X_DISPLAY_NAME,
             OLD.DISPLAY_NAME),
      X_PROTECT_LEVEL,
      X_CUSTOM_LEVEL,
      decode(L.CODE,
             userenv('LANG'), X_DESCRIPTION,
             OLD.DESCRIPTION),
      L.CODE,
      decode(L.CODE,
             userenv('LANG'), L.CODE,
             OLD.SOURCE_LANG)
    from WF_LANGUAGES L, WF_ACTIVITIES_TL OLD
    where L.INSTALLED_FLAG = 'Y'
    and OLD.ITEM_TYPE = X_ITEM_TYPE
    and OLD.NAME = X_NAME
    and OLD.VERSION = old_version
    and OLD.LANGUAGE = L.CODE
    and not exists
      (select NULL
      from WF_ACTIVITIES_TL T
      where T.ITEM_TYPE = X_ITEM_TYPE
      and T.NAME = X_NAME
      and T.VERSION = X_VERSION
      and T.LANGUAGE = L.CODE);
  else
    -- No other versions, default translations for all languages from
    -- the current language.
    insert into WF_ACTIVITIES_TL (
      ITEM_TYPE,
      NAME,
      VERSION,
      DISPLAY_NAME,
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG
    ) select
      X_ITEM_TYPE,
      X_NAME,
      X_VERSION,
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
      from WF_ACTIVITIES_TL T
      where T.ITEM_TYPE = X_ITEM_TYPE
      and T.NAME = X_NAME
      and T.VERSION = X_VERSION
      and T.LANGUAGE = L.CODE);

  end if;

  -- *** VERSION CUSTOMIZATION
  --   Check rows just inserted for duplicate display_names among activities
  -- within this itemtype over all versions active during the time
  -- range of the version being added.
  --   It is not sufficient to rely on WF_ACTIVITIES_TL_U2 unique index,
  -- because versions may mask some duplicates.
  begin
    select /*+ leading(NEW,NEWTL,OLDTL,OLD) use_nl(NEWTL,OLDTL,OLD) */
           OLD.NAME||':'||OLDTL.LANGUAGE||':'||OLDTL.DISPLAY_NAME
      into Wf_Load.logbuf
      from WF_ACTIVITIES NEW, WF_ACTIVITIES OLD,
           WF_ACTIVITIES_TL NEWTL, WF_ACTIVITIES_TL OLDTL
      where NEW.ITEM_TYPE = NEWTL.ITEM_TYPE
      and NEW.NAME = NEWTL.NAME
      and NEW.VERSION = NEWTL.VERSION
      and OLD.ITEM_TYPE = OLDTL.ITEM_TYPE
      and OLD.NAME = OLDTL.NAME
      and OLD.VERSION = OLDTL.VERSION
      and NEW.ITEM_TYPE = x_item_type
      and NEW.NAME = x_name
      and NEW.VERSION = x_version
      and NEW.BEGIN_DATE < nvl(OLD.END_DATE, NEW.BEGIN_DATE+1)
      and nvl(NEW.END_DATE, OLD.BEGIN_DATE+1) > OLD.BEGIN_DATE
      and OLDTL.DISPLAY_NAME = NEWTL.DISPLAY_NAME
      and OLD.ITEM_TYPE = NEW.ITEM_TYPE
      and OLDTL.LANGUAGE = NEWTL.LANGUAGE
      and OLDTL.ROWID <> NEWTL.ROWID
      and rownum < 2;

  exception
    when no_data_found then
      null;
      -- No bad rows exist.  Joy.
  end;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

exception
  when others then
    wf_core.context('Wf_Activities_Pkg', 'Insert_Row', x_item_type,
        x_name, to_char(x_version));
    raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_ITEM_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_VERSION in NUMBER,
  X_TYPE in VARCHAR2,
  X_RERUN in VARCHAR2,
  X_EXPAND_ROLE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_BEGIN_DATE in DATE,
  X_END_DATE in DATE,
  X_FUNCTION in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_COST in NUMBER,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_EXECUTE_ROLE in VARCHAR2,
  X_ICON_NAME in VARCHAR2,
  X_MESSAGE in VARCHAR2,
  X_ERROR_PROCESS in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      TYPE,
      RERUN,
      EXPAND_ROLE,
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      BEGIN_DATE,
      END_DATE,
      FUNCTION,
      RESULT_TYPE,
      COST,
      READ_ROLE,
      WRITE_ROLE,
      EXECUTE_ROLE,
      ICON_NAME,
      MESSAGE,
      ERROR_PROCESS
    from WF_ACTIVITIES
    where ITEM_TYPE = X_ITEM_TYPE
    and NAME = X_NAME
    and VERSION = X_VERSION
    for update of ITEM_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION
    from WF_ACTIVITIES_TL
    where ITEM_TYPE = X_ITEM_TYPE
    and NAME = X_NAME
    and VERSION = X_VERSION
    and LANGUAGE = userenv('LANG')
    for update of ITEM_TYPE nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    wf_core.raise('WF_RECORD_DELETED');
  end if;
  close c;
  if (    (recinfo.TYPE = X_TYPE)
      AND (recinfo.RERUN = X_RERUN)
      AND (recinfo.EXPAND_ROLE = X_EXPAND_ROLE)
      AND (recinfo.PROTECT_LEVEL = X_PROTECT_LEVEL)
      AND (recinfo.CUSTOM_LEVEL = X_CUSTOM_LEVEL)
      AND (recinfo.BEGIN_DATE = X_BEGIN_DATE)
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.FUNCTION = X_FUNCTION)
           OR ((recinfo.FUNCTION is null) AND (X_FUNCTION is null)))
      AND ((recinfo.RESULT_TYPE = X_RESULT_TYPE)
           OR ((recinfo.RESULT_TYPE is null) AND (X_RESULT_TYPE is null)))
      AND ((recinfo.COST = X_COST)
           OR ((recinfo.COST is null) AND (X_COST is null)))
      AND ((recinfo.READ_ROLE = X_READ_ROLE)
           OR ((recinfo.READ_ROLE is null) AND (X_READ_ROLE is null)))
      AND ((recinfo.WRITE_ROLE = X_WRITE_ROLE)
           OR ((recinfo.WRITE_ROLE is null) AND (X_WRITE_ROLE is null)))
      AND ((recinfo.EXECUTE_ROLE = X_EXECUTE_ROLE)
           OR ((recinfo.EXECUTE_ROLE is null) AND (X_EXECUTE_ROLE is null)))
      AND ((recinfo.ICON_NAME = X_ICON_NAME)
           OR ((recinfo.ICON_NAME is null) AND (X_ICON_NAME is null)))
      AND ((recinfo.MESSAGE = X_MESSAGE)
           OR ((recinfo.MESSAGE is null) AND (X_MESSAGE is null)))
      AND ((recinfo.ERROR_PROCESS = X_ERROR_PROCESS)
           OR ((recinfo.ERROR_PROCESS is null) AND (X_ERROR_PROCESS is null)))
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
    wf_core.context('Wf_Activities_Pkg', 'Lock_Row', x_item_type,
        x_name, to_char(x_version));
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ITEM_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_VERSION in NUMBER,
  X_TYPE in VARCHAR2,
  X_RERUN in VARCHAR2,
  X_EXPAND_ROLE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_BEGIN_DATE in DATE,
  X_END_DATE in DATE,
  X_FUNCTION in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_COST in NUMBER,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_EXECUTE_ROLE in VARCHAR2,
  X_ICON_NAME in VARCHAR2,
  X_MESSAGE in VARCHAR2,
  X_ERROR_PROCESS in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
begin
  update WF_ACTIVITIES set
    TYPE = X_TYPE,
    RERUN = X_RERUN,
    EXPAND_ROLE = X_EXPAND_ROLE,
    PROTECT_LEVEL = X_PROTECT_LEVEL,
    CUSTOM_LEVEL = X_CUSTOM_LEVEL,
    BEGIN_DATE = X_BEGIN_DATE,
    END_DATE = X_END_DATE,
    FUNCTION = X_FUNCTION,
    RESULT_TYPE = X_RESULT_TYPE,
    COST = X_COST,
    READ_ROLE = X_READ_ROLE,
    WRITE_ROLE = X_WRITE_ROLE,
    EXECUTE_ROLE = X_EXECUTE_ROLE,
    ICON_NAME = X_ICON_NAME,
    MESSAGE = X_MESSAGE,
    ERROR_PROCESS = X_ERROR_PROCESS
  where ITEM_TYPE = X_ITEM_TYPE
  and NAME = X_NAME
  and VERSION = X_VERSION;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WF_ACTIVITIES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    SOURCE_LANG = userenv('LANG')
  where ITEM_TYPE = X_ITEM_TYPE
  and NAME = X_NAME
  and VERSION = X_VERSION
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Activities_Pkg', 'Update_Row', x_item_type,
        x_name, to_char(x_version));
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ITEM_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_VERSION in NUMBER
) is
begin
  delete from WF_ACTIVITIES_TL
  where ITEM_TYPE = X_ITEM_TYPE
  and NAME = X_NAME
  and VERSION = X_VERSION;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WF_ACTIVITIES
  where ITEM_TYPE = X_ITEM_TYPE
  and NAME = X_NAME
  and VERSION = X_VERSION;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Activities_Pkg', 'Delete_Row', x_item_type,
        x_name, to_char(x_version));
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

  delete from WF_ACTIVITIES_TL T
  where not exists
    (select NULL
    from WF_ACTIVITIES B
    where B.ITEM_TYPE = T.ITEM_TYPE
    and B.NAME = T.NAME
    and B.VERSION = T.VERSION
    );

  update WF_ACTIVITIES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from WF_ACTIVITIES_TL B
    where B.ITEM_TYPE = T.ITEM_TYPE
    and B.NAME = T.NAME
    and B.VERSION = T.VERSION
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ITEM_TYPE,
      T.NAME,
      T.VERSION,
      T.LANGUAGE
  ) in (select
      SUBT.ITEM_TYPE,
      SUBT.NAME,
      SUBT.VERSION,
      SUBT.LANGUAGE
    from WF_ACTIVITIES_TL SUBB, WF_ACTIVITIES_TL SUBT
    where SUBB.ITEM_TYPE = SUBT.ITEM_TYPE
    and SUBB.NAME = SUBT.NAME
    and SUBB.VERSION = SUBT.VERSION
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert  /*+ append parallel */ into WF_ACTIVITIES_TL (
    ITEM_TYPE,
    NAME,
    VERSION,
    DISPLAY_NAME,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ITEM_TYPE,
    B.NAME,
    B.VERSION,
    B.DISPLAY_NAME,
    B.PROTECT_LEVEL,
    B.CUSTOM_LEVEL,
    B.DESCRIPTION,
    L.CODE,
    B.SOURCE_LANG
  from WF_ACTIVITIES_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
and (B.ITEM_TYPE , b.name, B.VERSION , l.code) NOT IN
    (select  /*+ hash_aj index_ffs(T,WF_ACTIVITIES_TL_PK) */
         T.ITEM_TYPE , T.NAME , T.VERSION ,T.LANGUAGE from WF_ACTIVITIES_TL T );
end ADD_LANGUAGE;

end WF_ACTIVITIES_PKG;

/
