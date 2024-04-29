--------------------------------------------------------
--  DDL for Package Body WF_ACTIVITY_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ACTIVITY_ATTRIBUTES_PKG" as
/* $Header: wfacab.pls 120.2 2005/07/02 03:41:27 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ACTIVITY_ITEM_TYPE in VARCHAR2,
  X_ACTIVITY_NAME in VARCHAR2,
  X_ACTIVITY_VERSION in NUMBER,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_SUBTYPE in VARCHAR2,
  X_FORMAT in VARCHAR2,
  X_TEXT_DEFAULT in VARCHAR2,
  X_NUMBER_DEFAULT in NUMBER,
  X_DATE_DEFAULT in DATE,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor C is select ROWID from WF_ACTIVITY_ATTRIBUTES
    where ACTIVITY_ITEM_TYPE = X_ACTIVITY_ITEM_TYPE
    and ACTIVITY_NAME = X_ACTIVITY_NAME
    and ACTIVITY_VERSION = X_ACTIVITY_VERSION
    and NAME = X_NAME
    ;
  old_version number default '';
begin
  insert into WF_ACTIVITY_ATTRIBUTES (
    ACTIVITY_ITEM_TYPE,
    ACTIVITY_NAME,
    ACTIVITY_VERSION,
    NAME,
    SEQUENCE,
    TYPE,
    VALUE_TYPE,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    SUBTYPE,
    FORMAT,
    TEXT_DEFAULT,
    NUMBER_DEFAULT,
    DATE_DEFAULT
  ) values (
    X_ACTIVITY_ITEM_TYPE,
    X_ACTIVITY_NAME,
    X_ACTIVITY_VERSION,
    X_NAME,
    X_SEQUENCE,
    X_TYPE,
    X_VALUE_TYPE,
    X_PROTECT_LEVEL,
    X_CUSTOM_LEVEL,
    X_SUBTYPE,
    X_FORMAT,
    X_TEXT_DEFAULT,
    X_NUMBER_DEFAULT,
    X_DATE_DEFAULT
  );

  -- *** VERSION CUSTOMIZATION
  -- Insert translations.  Default the translations for all but the
  -- current language from a previous version of this attribute, if one
  -- is available.
  -- Note: Use _VL instead of base table to prevent _tl integrity errors
  -- from propagating.
  select max(WAA.ACTIVITY_VERSION)
  into old_version
  from WF_ACTIVITY_ATTRIBUTES_TL WAA
  where WAA.NAME = X_NAME
  and WAA.ACTIVITY_ITEM_TYPE = X_ACTIVITY_ITEM_TYPE
  and WAA.ACTIVITY_NAME = X_ACTIVITY_NAME
  and WAA.ACTIVITY_VERSION < X_ACTIVITY_VERSION;

  if (old_version is not null) then

    insert into WF_ACTIVITY_ATTRIBUTES_TL (
      ACTIVITY_ITEM_TYPE,
      ACTIVITY_NAME,
      ACTIVITY_VERSION,
      NAME,
      DISPLAY_NAME,
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG
    ) select
      X_ACTIVITY_ITEM_TYPE,
      X_ACTIVITY_NAME,
      X_ACTIVITY_VERSION,
      X_NAME,
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
    from WF_LANGUAGES L, WF_ACTIVITY_ATTRIBUTES_TL OLD
    where L.INSTALLED_FLAG = 'Y'
    and OLD.ACTIVITY_ITEM_TYPE = X_ACTIVITY_ITEM_TYPE
    and OLD.ACTIVITY_NAME = X_ACTIVITY_NAME
    and OLD.ACTIVITY_VERSION = old_version
    and OLD.NAME = X_NAME
    and OLD.LANGUAGE = L.CODE
    and not exists
      (select NULL
      from WF_ACTIVITY_ATTRIBUTES_TL T
      where T.ACTIVITY_ITEM_TYPE = X_ACTIVITY_ITEM_TYPE
      and T.ACTIVITY_NAME = X_ACTIVITY_NAME
      and T.ACTIVITY_VERSION = X_ACTIVITY_VERSION
      and T.NAME = X_NAME
      and T.LANGUAGE = L.CODE);

  else

    insert into WF_ACTIVITY_ATTRIBUTES_TL (
      ACTIVITY_ITEM_TYPE,
      ACTIVITY_NAME,
      ACTIVITY_VERSION,
      NAME,
      DISPLAY_NAME,
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG
    ) select
      X_ACTIVITY_ITEM_TYPE,
      X_ACTIVITY_NAME,
      X_ACTIVITY_VERSION,
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
      from WF_ACTIVITY_ATTRIBUTES_TL T
      where T.ACTIVITY_ITEM_TYPE = X_ACTIVITY_ITEM_TYPE
      and T.ACTIVITY_NAME = X_ACTIVITY_NAME
      and T.ACTIVITY_VERSION = X_ACTIVITY_VERSION
      and T.NAME = X_NAME
      and T.LANGUAGE = L.CODE);

  end if;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

exception
  when others then
    wf_core.context('Wf_Activity_Attributes_Pkg', 'Insert_Row',
        x_activity_item_type, x_activity_name, to_char(x_activity_version),
        x_name);
    raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_ACTIVITY_ITEM_TYPE in VARCHAR2,
  X_ACTIVITY_NAME in VARCHAR2,
  X_ACTIVITY_VERSION in NUMBER,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_SUBTYPE in VARCHAR2,
  X_FORMAT in VARCHAR2,
  X_TEXT_DEFAULT in VARCHAR2,
  X_NUMBER_DEFAULT in NUMBER,
  X_DATE_DEFAULT in DATE,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      SEQUENCE,
      TYPE,
      VALUE_TYPE,
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      SUBTYPE,
      FORMAT,
      TEXT_DEFAULT,
      NUMBER_DEFAULT,
      DATE_DEFAULT
    from WF_ACTIVITY_ATTRIBUTES
    where ACTIVITY_ITEM_TYPE = X_ACTIVITY_ITEM_TYPE
    and ACTIVITY_NAME = X_ACTIVITY_NAME
    and ACTIVITY_VERSION = X_ACTIVITY_VERSION
    and NAME = X_NAME
    for update of ACTIVITY_ITEM_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION
    from WF_ACTIVITY_ATTRIBUTES_TL
    where ACTIVITY_ITEM_TYPE = X_ACTIVITY_ITEM_TYPE
    and ACTIVITY_NAME = X_ACTIVITY_NAME
    and ACTIVITY_VERSION = X_ACTIVITY_VERSION
    and NAME = X_NAME
    and LANGUAGE = userenv('LANG')
    for update of ACTIVITY_ITEM_TYPE nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    wf_core.raise('WF_RECORD_DELETED');
  end if;
  close c;
  if (    (recinfo.SEQUENCE = X_SEQUENCE)
      AND (recinfo.TYPE = X_TYPE)
      AND (recinfo.VALUE_TYPE = X_VALUE_TYPE)
      AND (recinfo.PROTECT_LEVEL = X_PROTECT_LEVEL)
      AND (recinfo.CUSTOM_LEVEL = X_CUSTOM_LEVEL)
      AND ((recinfo.SUBTYPE = X_SUBTYPE)
           OR ((recinfo.SUBTYPE is null) AND (X_SUBTYPE is null)))
      AND ((recinfo.FORMAT = X_FORMAT)
           OR ((recinfo.FORMAT is null) AND (X_FORMAT is null)))
      AND ((recinfo.TEXT_DEFAULT = X_TEXT_DEFAULT)
           OR ((recinfo.TEXT_DEFAULT is null) AND (X_TEXT_DEFAULT is null)))
      AND ((recinfo.NUMBER_DEFAULT = X_NUMBER_DEFAULT)
           OR ((recinfo.NUMBER_DEFAULT is null) AND (X_NUMBER_DEFAULT is null)))
      AND ((recinfo.DATE_DEFAULT = X_DATE_DEFAULT)
           OR ((recinfo.DATE_DEFAULT is null) AND (X_DATE_DEFAULT is null)))
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
    wf_core.context('Wf_Activity_Attributes_Pkg', 'Lock_Row',
        x_activity_item_type, x_activity_name, to_char(x_activity_version),
        x_name);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ACTIVITY_ITEM_TYPE in VARCHAR2,
  X_ACTIVITY_NAME in VARCHAR2,
  X_ACTIVITY_VERSION in NUMBER,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_SUBTYPE in VARCHAR2,
  X_FORMAT in VARCHAR2,
  X_TEXT_DEFAULT in VARCHAR2,
  X_NUMBER_DEFAULT in NUMBER,
  X_DATE_DEFAULT in DATE,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
begin
  update WF_ACTIVITY_ATTRIBUTES set
    SEQUENCE = X_SEQUENCE,
    TYPE = X_TYPE,
    VALUE_TYPE = X_VALUE_TYPE,
    PROTECT_LEVEL = X_PROTECT_LEVEL,
    CUSTOM_LEVEL = X_CUSTOM_LEVEL,
    SUBTYPE = X_SUBTYPE,
    FORMAT = X_FORMAT,
    TEXT_DEFAULT = X_TEXT_DEFAULT,
    NUMBER_DEFAULT = X_NUMBER_DEFAULT,
    DATE_DEFAULT = X_DATE_DEFAULT
  where ACTIVITY_ITEM_TYPE = X_ACTIVITY_ITEM_TYPE
  and ACTIVITY_NAME = X_ACTIVITY_NAME
  and ACTIVITY_VERSION = X_ACTIVITY_VERSION
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WF_ACTIVITY_ATTRIBUTES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    SOURCE_LANG = userenv('LANG')
  where ACTIVITY_ITEM_TYPE = X_ACTIVITY_ITEM_TYPE
  and ACTIVITY_NAME = X_ACTIVITY_NAME
  and ACTIVITY_VERSION = X_ACTIVITY_VERSION
  and NAME = X_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Activity_Attributes_Pkg', 'Update_Row',
        x_activity_item_type, x_activity_name, to_char(x_activity_version),
        x_name);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ACTIVITY_ITEM_TYPE in VARCHAR2,
  X_ACTIVITY_NAME in VARCHAR2,
  X_ACTIVITY_VERSION in NUMBER,
  X_NAME in VARCHAR2
) is
begin
  delete from WF_ACTIVITY_ATTRIBUTES_TL
  where ACTIVITY_ITEM_TYPE = X_ACTIVITY_ITEM_TYPE
  and ACTIVITY_NAME = X_ACTIVITY_NAME
  and ACTIVITY_VERSION = X_ACTIVITY_VERSION
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WF_ACTIVITY_ATTRIBUTES
  where ACTIVITY_ITEM_TYPE = X_ACTIVITY_ITEM_TYPE
  and ACTIVITY_NAME = X_ACTIVITY_NAME
  and ACTIVITY_VERSION = X_ACTIVITY_VERSION
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Activity_Attributes_Pkg', 'Delete_Row',
        x_activity_item_type, x_activity_name, to_char(x_activity_version),
        x_name);
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

  delete from WF_ACTIVITY_ATTRIBUTES_TL T
  where not exists
    (select NULL
    from WF_ACTIVITY_ATTRIBUTES B
    where B.ACTIVITY_ITEM_TYPE = T.ACTIVITY_ITEM_TYPE
    and B.ACTIVITY_NAME = T.ACTIVITY_NAME
    and B.ACTIVITY_VERSION = T.ACTIVITY_VERSION
    and B.NAME = T.NAME
    );

  update WF_ACTIVITY_ATTRIBUTES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from WF_ACTIVITY_ATTRIBUTES_TL B
    where B.ACTIVITY_ITEM_TYPE = T.ACTIVITY_ITEM_TYPE
    and B.ACTIVITY_NAME = T.ACTIVITY_NAME
    and B.ACTIVITY_VERSION = T.ACTIVITY_VERSION
    and B.NAME = T.NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ACTIVITY_ITEM_TYPE,
      T.ACTIVITY_NAME,
      T.ACTIVITY_VERSION,
      T.NAME,
      T.LANGUAGE
  ) in (select
      SUBT.ACTIVITY_ITEM_TYPE,
      SUBT.ACTIVITY_NAME,
      SUBT.ACTIVITY_VERSION,
      SUBT.NAME,
      SUBT.LANGUAGE
    from WF_ACTIVITY_ATTRIBUTES_TL SUBB, WF_ACTIVITY_ATTRIBUTES_TL SUBT
    where SUBB.ACTIVITY_ITEM_TYPE = SUBT.ACTIVITY_ITEM_TYPE
    and SUBB.ACTIVITY_NAME = SUBT.ACTIVITY_NAME
    and SUBB.ACTIVITY_VERSION = SUBT.ACTIVITY_VERSION
    and SUBB.NAME = SUBT.NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert  /*+ append parallel */ into WF_ACTIVITY_ATTRIBUTES_TL (
    ACTIVITY_ITEM_TYPE,
    ACTIVITY_NAME,
    ACTIVITY_VERSION,
    NAME,
    DISPLAY_NAME,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ACTIVITY_ITEM_TYPE,
    B.ACTIVITY_NAME,
    B.ACTIVITY_VERSION,
    B.NAME,
    B.DISPLAY_NAME,
    B.PROTECT_LEVEL,
    B.CUSTOM_LEVEL,
    B.DESCRIPTION,
    L.CODE,
    B.SOURCE_LANG
  from WF_ACTIVITY_ATTRIBUTES_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and (B.ACTIVITY_ITEM_TYPE, B.ACTIVITY_NAME, B.ACTIVITY_VERSION , B.NAME,
        L.CODE) NOT IN
    (select  /*+ hash_aj index_ffs(T,WF_ACTIVITY_ATTRIBUTES_TL_PK) */
           T.ACTIVITY_ITEM_TYPE ,T.ACTIVITY_NAME  ,T.ACTIVITY_VERSION , T.NAME  , T.LANGUAGE   from WF_ACTIVITY_ATTRIBUTES_TL T );
end ADD_LANGUAGE;

end WF_ACTIVITY_ATTRIBUTES_PKG;

/
