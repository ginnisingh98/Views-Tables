--------------------------------------------------------
--  DDL for Package Body BSC_SYS_LABELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_LABELS_PKG" as
/* $Header: BSCSLBSB.pls 115.6 2003/02/12 14:29:19 adeulgao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_LABEL_ID in NUMBER,
  X_LEFT_POSITION in NUMBER,
  X_TOP_POSITION in NUMBER,
  X_FONT_SIZE in NUMBER,
  X_FONT_STYLE in NUMBER,
  X_NAME in VARCHAR2
) is
  cursor C is select ROWID from BSC_SYS_LABELS_B
    where SOURCE_TYPE = X_SOURCE_TYPE
    and SOURCE_CODE = X_SOURCE_CODE
    and LABEL_ID = X_LABEL_ID
    ;
begin
  insert into BSC_SYS_LABELS_B (
    SOURCE_TYPE,
    SOURCE_CODE,
    LABEL_ID,
    LEFT_POSITION,
    TOP_POSITION,
    FONT_SIZE,
    FONT_STYLE
  ) values (
    X_SOURCE_TYPE,
    X_SOURCE_CODE,
    X_LABEL_ID,
    X_LEFT_POSITION,
    X_TOP_POSITION,
    X_FONT_SIZE,
    X_FONT_STYLE
  );

  insert into BSC_SYS_LABELS_TL (
    SOURCE_TYPE,
    SOURCE_CODE,
    LABEL_ID,
    NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SOURCE_TYPE,
    X_SOURCE_CODE,
    X_LABEL_ID,
    X_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_SYS_LABELS_TL T
    where T.SOURCE_TYPE = X_SOURCE_TYPE
    and T.SOURCE_CODE = X_SOURCE_CODE
    and T.LABEL_ID = X_LABEL_ID
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
  X_LABEL_ID in NUMBER,
  X_LEFT_POSITION in NUMBER,
  X_TOP_POSITION in NUMBER,
  X_FONT_SIZE in NUMBER,
  X_FONT_STYLE in NUMBER,
  X_NAME in VARCHAR2
) is
  cursor c is select
      LEFT_POSITION,
      TOP_POSITION,
      FONT_SIZE,
      FONT_STYLE
    from BSC_SYS_LABELS_B
    where SOURCE_TYPE = X_SOURCE_TYPE
    and SOURCE_CODE = X_SOURCE_CODE
    and LABEL_ID = X_LABEL_ID
    for update of SOURCE_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_SYS_LABELS_TL
    where SOURCE_TYPE = X_SOURCE_TYPE
    and SOURCE_CODE = X_SOURCE_CODE
    and LABEL_ID = X_LABEL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SOURCE_TYPE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.LEFT_POSITION = X_LEFT_POSITION)
           OR ((recinfo.LEFT_POSITION is null) AND (X_LEFT_POSITION is null)))
      AND ((recinfo.TOP_POSITION = X_TOP_POSITION)
           OR ((recinfo.TOP_POSITION is null) AND (X_TOP_POSITION is null)))
      AND ((recinfo.FONT_SIZE = X_FONT_SIZE)
           OR ((recinfo.FONT_SIZE is null) AND (X_FONT_SIZE is null)))
      AND ((recinfo.FONT_STYLE = X_FONT_STYLE)
           OR ((recinfo.FONT_STYLE is null) AND (X_FONT_STYLE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_LABEL_ID in NUMBER,
  X_LEFT_POSITION in NUMBER,
  X_TOP_POSITION in NUMBER,
  X_FONT_SIZE in NUMBER,
  X_FONT_STYLE in NUMBER,
  X_NAME in VARCHAR2
) is
begin
  update BSC_SYS_LABELS_B set
    LEFT_POSITION = X_LEFT_POSITION,
    TOP_POSITION = X_TOP_POSITION,
    FONT_SIZE = X_FONT_SIZE,
    FONT_STYLE = X_FONT_STYLE
  where SOURCE_TYPE = X_SOURCE_TYPE
  and SOURCE_CODE = X_SOURCE_CODE
  and LABEL_ID = X_LABEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BSC_SYS_LABELS_TL set
    NAME = X_NAME,
    SOURCE_LANG = userenv('LANG')
  where SOURCE_TYPE = X_SOURCE_TYPE
  and SOURCE_CODE = X_SOURCE_CODE
  and LABEL_ID = X_LABEL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SOURCE_TYPE in NUMBER,
  X_SOURCE_CODE in NUMBER,
  X_LABEL_ID in NUMBER
) is
begin
  delete from BSC_SYS_LABELS_TL
  where SOURCE_TYPE = X_SOURCE_TYPE
  and SOURCE_CODE = X_SOURCE_CODE
  and LABEL_ID = X_LABEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_SYS_LABELS_B
  where SOURCE_TYPE = X_SOURCE_TYPE
  and SOURCE_CODE = X_SOURCE_CODE
  and LABEL_ID = X_LABEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BSC_SYS_LABELS_TL T
  where not exists
    (select NULL
    from BSC_SYS_LABELS_B B
    where B.SOURCE_TYPE = T.SOURCE_TYPE
    and B.SOURCE_CODE = T.SOURCE_CODE
    and B.LABEL_ID = T.LABEL_ID
    );

  update BSC_SYS_LABELS_TL T set (
      NAME
    ) = (select
      B.NAME
    from BSC_SYS_LABELS_TL B
    where B.SOURCE_TYPE = T.SOURCE_TYPE
    and B.SOURCE_CODE = T.SOURCE_CODE
    and B.LABEL_ID = T.LABEL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SOURCE_TYPE,
      T.SOURCE_CODE,
      T.LABEL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SOURCE_TYPE,
      SUBT.SOURCE_CODE,
      SUBT.LABEL_ID,
      SUBT.LANGUAGE
    from BSC_SYS_LABELS_TL SUBB, BSC_SYS_LABELS_TL SUBT
    where SUBB.SOURCE_TYPE = SUBT.SOURCE_TYPE
    and SUBB.SOURCE_CODE = SUBT.SOURCE_CODE
    and SUBB.LABEL_ID = SUBT.LABEL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into BSC_SYS_LABELS_TL (
    SOURCE_TYPE,
    SOURCE_CODE,
    LABEL_ID,
    NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SOURCE_TYPE,
    B.SOURCE_CODE,
    B.LABEL_ID,
    B.NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_SYS_LABELS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_SYS_LABELS_TL T
    where T.SOURCE_TYPE = B.SOURCE_TYPE
    and T.SOURCE_CODE = B.SOURCE_CODE
    and T.LABEL_ID = B.LABEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_SYS_LABELS_PKG;

/
