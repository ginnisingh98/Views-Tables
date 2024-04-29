--------------------------------------------------------
--  DDL for Package Body WF_ITEM_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ITEM_ATTRIBUTES_PKG" as
/* $Header: wfitab.pls 120.1 2005/07/02 02:46:32 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ITEM_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_TYPE in VARCHAR2,
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
  cursor C is select ROWID from WF_ITEM_ATTRIBUTES
    where ITEM_TYPE = X_ITEM_TYPE
    and NAME = X_NAME
    ;
begin
  insert into WF_ITEM_ATTRIBUTES (
    ITEM_TYPE,
    NAME,
    SEQUENCE,
    TYPE,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    SUBTYPE,
    FORMAT,
    TEXT_DEFAULT,
    NUMBER_DEFAULT,
    DATE_DEFAULT
  ) values (
    X_ITEM_TYPE,
    X_NAME,
    X_SEQUENCE,
    X_TYPE,
    X_PROTECT_LEVEL,
    X_CUSTOM_LEVEL,
    X_SUBTYPE,
    X_FORMAT,
    X_TEXT_DEFAULT,
    X_NUMBER_DEFAULT,
    X_DATE_DEFAULT
  );

  insert into WF_ITEM_ATTRIBUTES_TL (
    ITEM_TYPE,
    NAME,
    DISPLAY_NAME,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ITEM_TYPE,
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
    from WF_ITEM_ATTRIBUTES_TL T
    where T.ITEM_TYPE = X_ITEM_TYPE
    and T.NAME = X_NAME
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
    wf_core.context('Wf_Item_Attributes_Pkg', 'Insert_Row',
        x_item_type, x_name);
    raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_ITEM_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_TYPE in VARCHAR2,
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
      PROTECT_LEVEL,
      CUSTOM_LEVEL,
      SUBTYPE,
      FORMAT,
      TEXT_DEFAULT,
      NUMBER_DEFAULT,
      DATE_DEFAULT
    from WF_ITEM_ATTRIBUTES
    where ITEM_TYPE = X_ITEM_TYPE
    and NAME = X_NAME
    for update of ITEM_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION
    from WF_ITEM_ATTRIBUTES_TL
    where ITEM_TYPE = X_ITEM_TYPE
    and NAME = X_NAME
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
  if (    (recinfo.SEQUENCE = X_SEQUENCE)
      AND (recinfo.TYPE = X_TYPE)
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
    wf_core.context('Wf_Item_Attributes_Pkg', 'Lock_Row',
        x_item_type, x_name);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ITEM_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_TYPE in VARCHAR2,
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
  update WF_ITEM_ATTRIBUTES set
    SEQUENCE = X_SEQUENCE,
    TYPE = X_TYPE,
    PROTECT_LEVEL = X_PROTECT_LEVEL,
    CUSTOM_LEVEL = X_CUSTOM_LEVEL,
    SUBTYPE = X_SUBTYPE,
    FORMAT = X_FORMAT,
    TEXT_DEFAULT = X_TEXT_DEFAULT,
    NUMBER_DEFAULT = X_NUMBER_DEFAULT,
    DATE_DEFAULT = X_DATE_DEFAULT
  where ITEM_TYPE = X_ITEM_TYPE
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WF_ITEM_ATTRIBUTES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    SOURCE_LANG = userenv('LANG')
  where ITEM_TYPE = X_ITEM_TYPE
  and NAME = X_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Item_Attributes_Pkg', 'Update_Row',
        x_item_type, x_name);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ITEM_TYPE in VARCHAR2,
  X_NAME in VARCHAR2
) is
begin
  delete from WF_ITEM_ATTRIBUTES_TL
  where ITEM_TYPE = X_ITEM_TYPE
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WF_ITEM_ATTRIBUTES
  where ITEM_TYPE = X_ITEM_TYPE
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Item_Attributes_Pkg', 'Delete_Row',
        x_item_type, x_name);
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

  delete from WF_ITEM_ATTRIBUTES_TL T
  where not exists
    (select NULL
    from WF_ITEM_ATTRIBUTES B
    where B.ITEM_TYPE = T.ITEM_TYPE
    and B.NAME = T.NAME
    );

  update WF_ITEM_ATTRIBUTES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from WF_ITEM_ATTRIBUTES_TL B
    where B.ITEM_TYPE = T.ITEM_TYPE
    and B.NAME = T.NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ITEM_TYPE,
      T.NAME,
      T.LANGUAGE
  ) in (select
      SUBT.ITEM_TYPE,
      SUBT.NAME,
      SUBT.LANGUAGE
    from WF_ITEM_ATTRIBUTES_TL SUBB, WF_ITEM_ATTRIBUTES_TL SUBT
    where SUBB.ITEM_TYPE = SUBT.ITEM_TYPE
    and SUBB.NAME = SUBT.NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/
  insert into WF_ITEM_ATTRIBUTES_TL (
    ITEM_TYPE,
    NAME,
    DISPLAY_NAME,
    PROTECT_LEVEL,
    CUSTOM_LEVEL,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ITEM_TYPE,
    B.NAME,
    B.DISPLAY_NAME,
    B.PROTECT_LEVEL,
    B.CUSTOM_LEVEL,
    B.DESCRIPTION,
    L.CODE,
    B.SOURCE_LANG
  from WF_ITEM_ATTRIBUTES_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and (B.ITEM_TYPE ,B.NAME ,L.CODE) NOT IN
   (select /*+ hash_aj index_ffs(T,WF_ITEM_ATTRIBUTES_TL_PK) */
      T.ITEM_TYPE  , T.NAME,T.LANGUAGE
   from WF_ITEM_ATTRIBUTES_TL T) ;


end ADD_LANGUAGE;

end WF_ITEM_ATTRIBUTES_PKG;

/
