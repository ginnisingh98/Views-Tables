--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_CLASS_PKG" as
/* $Header: GMDFMCLB.pls 115.2 2002/10/24 20:07:00 santunes noship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_FORMULA_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_FORMULA_CLASS_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMD_FORMULA_CLASS_B
    where FORMULA_CLASS = X_FORMULA_CLASS
    ;
begin
  insert into GMD_FORMULA_CLASS_B (
    FORMULA_CLASS,
    TRANS_CNT,
    DELETE_MARK,
    TEXT_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FORMULA_CLASS,
    X_TRANS_CNT,
    X_DELETE_MARK,
    X_TEXT_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMD_FORMULA_CLASS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    FORMULA_CLASS,
    FORMULA_CLASS_DESC,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_FORMULA_CLASS,
    X_FORMULA_CLASS_DESC,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMD_FORMULA_CLASS_TL T
    where T.FORMULA_CLASS = X_FORMULA_CLASS
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
  X_FORMULA_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_FORMULA_CLASS_DESC in VARCHAR2
) is
  cursor c is select
      TRANS_CNT,
      DELETE_MARK,
      TEXT_CODE
    from GMD_FORMULA_CLASS_B
    where FORMULA_CLASS = X_FORMULA_CLASS
    for update of FORMULA_CLASS nowait;
  recinfo c%rowtype;

  cursor c1 is select
      FORMULA_CLASS_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMD_FORMULA_CLASS_TL
    where FORMULA_CLASS = X_FORMULA_CLASS
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FORMULA_CLASS nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.TRANS_CNT = X_TRANS_CNT)
           OR ((recinfo.TRANS_CNT is null) AND (X_TRANS_CNT is null)))
      AND (recinfo.DELETE_MARK = X_DELETE_MARK)
      AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.FORMULA_CLASS_DESC = X_FORMULA_CLASS_DESC)
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
  X_FORMULA_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_FORMULA_CLASS_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMD_FORMULA_CLASS_B set
    TRANS_CNT = X_TRANS_CNT,
    DELETE_MARK = X_DELETE_MARK,
    TEXT_CODE = X_TEXT_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FORMULA_CLASS = X_FORMULA_CLASS;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMD_FORMULA_CLASS_TL set
    FORMULA_CLASS_DESC = X_FORMULA_CLASS_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FORMULA_CLASS = X_FORMULA_CLASS
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FORMULA_CLASS in VARCHAR2
) is
begin

 /* delete from GMD_FORMULA_CLASS_B
  where FORMULA_CLASS = X_FORMULA_CLASS;

  if (sql%notfound) then
    raise no_data_found;
  end if;
 */

  update GMD_FORMULA_CLASS_B
  set delete_mark = 1
  where FORMULA_CLASS = X_FORMULA_CLASS;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMD_FORMULA_CLASS_TL T
  where not exists
    (select NULL
    from GMD_FORMULA_CLASS_B B
    where B.FORMULA_CLASS = T.FORMULA_CLASS
    );

  update GMD_FORMULA_CLASS_TL T set (
      FORMULA_CLASS_DESC
    ) = (select
      B.FORMULA_CLASS_DESC
    from GMD_FORMULA_CLASS_TL B
    where B.FORMULA_CLASS = T.FORMULA_CLASS
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FORMULA_CLASS,
      T.LANGUAGE
  ) in (select
      SUBT.FORMULA_CLASS,
      SUBT.LANGUAGE
    from GMD_FORMULA_CLASS_TL SUBB, GMD_FORMULA_CLASS_TL SUBT
    where SUBB.FORMULA_CLASS = SUBT.FORMULA_CLASS
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.FORMULA_CLASS_DESC <> SUBT.FORMULA_CLASS_DESC
  ));

  insert into GMD_FORMULA_CLASS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    FORMULA_CLASS,
    FORMULA_CLASS_DESC,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.FORMULA_CLASS,
    B.FORMULA_CLASS_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMD_FORMULA_CLASS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMD_FORMULA_CLASS_TL T
    where T.FORMULA_CLASS = B.FORMULA_CLASS
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMD_FORMULA_CLASS_PKG;

/
