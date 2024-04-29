--------------------------------------------------------
--  DDL for Package Body IC_CLDR_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IC_CLDR_HDR_PKG" as
/* $Header: gmicldrb.pls 115.1 2002/10/31 19:11:13 jdiiorio noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORGN_CODE in VARCHAR2,
  X_FISCAL_YEAR in VARCHAR2,
  X_BEGIN_DATE in DATE,
  X_CLOSED_YEAR_IND in NUMBER,
  X_CURRENT_YEAR_IND in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_IN_USE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_CALENDAR_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IC_CLDR_HDR_B
    where ORGN_CODE = X_ORGN_CODE
    and FISCAL_YEAR = X_FISCAL_YEAR
    ;
begin
  insert into IC_CLDR_HDR_B (
    ORGN_CODE,
    FISCAL_YEAR,
    BEGIN_DATE,
    CLOSED_YEAR_IND,
    CURRENT_YEAR_IND,
    TEXT_CODE,
    IN_USE,
    DELETE_MARK,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ORGN_CODE,
    X_FISCAL_YEAR,
    X_BEGIN_DATE,
    X_CLOSED_YEAR_IND,
    X_CURRENT_YEAR_IND,
    X_TEXT_CODE,
    X_IN_USE,
    X_DELETE_MARK,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IC_CLDR_HDR_TL (
    CALENDAR_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORGN_CODE,
    FISCAL_YEAR,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CALENDAR_DESC,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ORGN_CODE,
    X_FISCAL_YEAR,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IC_CLDR_HDR_TL T
    where T.ORGN_CODE = X_ORGN_CODE
    and T.FISCAL_YEAR = X_FISCAL_YEAR
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
  X_ORGN_CODE in VARCHAR2,
  X_FISCAL_YEAR in VARCHAR2,
  X_BEGIN_DATE in DATE,
  X_CLOSED_YEAR_IND in NUMBER,
  X_CURRENT_YEAR_IND in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_IN_USE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_CALENDAR_DESC in VARCHAR2
) is
  cursor c is select
      BEGIN_DATE,
      CLOSED_YEAR_IND,
      CURRENT_YEAR_IND,
      TEXT_CODE,
      IN_USE,
      DELETE_MARK
    from IC_CLDR_HDR_B
    where ORGN_CODE = X_ORGN_CODE
    and FISCAL_YEAR = X_FISCAL_YEAR
    for update of ORGN_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CALENDAR_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IC_CLDR_HDR_TL
    where ORGN_CODE = X_ORGN_CODE
    and FISCAL_YEAR = X_FISCAL_YEAR
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ORGN_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.BEGIN_DATE = X_BEGIN_DATE)
      AND (recinfo.CLOSED_YEAR_IND = X_CLOSED_YEAR_IND)
      AND (recinfo.CURRENT_YEAR_IND = X_CURRENT_YEAR_IND)
      AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
      AND ((recinfo.IN_USE = X_IN_USE)
           OR ((recinfo.IN_USE is null) AND (X_IN_USE is null)))
      AND (recinfo.DELETE_MARK = X_DELETE_MARK)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CALENDAR_DESC = X_CALENDAR_DESC)
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
  X_ORGN_CODE in VARCHAR2,
  X_FISCAL_YEAR in VARCHAR2,
  X_BEGIN_DATE in DATE,
  X_CLOSED_YEAR_IND in NUMBER,
  X_CURRENT_YEAR_IND in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_IN_USE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_CALENDAR_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IC_CLDR_HDR_B set
    BEGIN_DATE = X_BEGIN_DATE,
    CLOSED_YEAR_IND = X_CLOSED_YEAR_IND,
    CURRENT_YEAR_IND = X_CURRENT_YEAR_IND,
    TEXT_CODE = X_TEXT_CODE,
    IN_USE = X_IN_USE,
    DELETE_MARK = X_DELETE_MARK,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ORGN_CODE = X_ORGN_CODE
  and FISCAL_YEAR = X_FISCAL_YEAR;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IC_CLDR_HDR_TL set
    CALENDAR_DESC = X_CALENDAR_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ORGN_CODE = X_ORGN_CODE
  and FISCAL_YEAR = X_FISCAL_YEAR
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ORGN_CODE in VARCHAR2,
  X_FISCAL_YEAR in VARCHAR2
) is
begin
/*****************
  delete from IC_CLDR_HDR_TL
  where ORGN_CODE = X_ORGN_CODE
  and FISCAL_YEAR = X_FISCAL_YEAR;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  ************************ */
  update IC_CLDR_HDR_B set delete_mark = 1
  where ORGN_CODE = X_ORGN_CODE
  and FISCAL_YEAR = X_FISCAL_YEAR;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IC_CLDR_HDR_TL T
  where not exists
    (select NULL
    from IC_CLDR_HDR_B B
    where B.ORGN_CODE = T.ORGN_CODE
    and B.FISCAL_YEAR = T.FISCAL_YEAR
    );

  update IC_CLDR_HDR_TL T set (
      CALENDAR_DESC
    ) = (select
      B.CALENDAR_DESC
    from IC_CLDR_HDR_TL B
    where B.ORGN_CODE = T.ORGN_CODE
    and B.FISCAL_YEAR = T.FISCAL_YEAR
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ORGN_CODE,
      T.FISCAL_YEAR,
      T.LANGUAGE
  ) in (select
      SUBT.ORGN_CODE,
      SUBT.FISCAL_YEAR,
      SUBT.LANGUAGE
    from IC_CLDR_HDR_TL SUBB, IC_CLDR_HDR_TL SUBT
    where SUBB.ORGN_CODE = SUBT.ORGN_CODE
    and SUBB.FISCAL_YEAR = SUBT.FISCAL_YEAR
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CALENDAR_DESC <> SUBT.CALENDAR_DESC
  ));

  insert into IC_CLDR_HDR_TL (
    CALENDAR_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORGN_CODE,
    FISCAL_YEAR,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CALENDAR_DESC,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.ORGN_CODE,
    B.FISCAL_YEAR,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IC_CLDR_HDR_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IC_CLDR_HDR_TL T
    where T.ORGN_CODE = B.ORGN_CODE
    and T.FISCAL_YEAR = B.FISCAL_YEAR
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end IC_CLDR_HDR_PKG;

/
