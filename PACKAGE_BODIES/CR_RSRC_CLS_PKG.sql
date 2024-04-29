--------------------------------------------------------
--  DDL for Package Body CR_RSRC_CLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CR_RSRC_CLS_PKG" as
/* $Header: GMPRSCSB.pls 115.2 2002/10/25 20:25:18 sgidugu ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RESOURCE_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_RESOURCE_CLASS_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CR_RSRC_CLS_B
    where RESOURCE_CLASS = X_RESOURCE_CLASS
    ;
begin
  insert into CR_RSRC_CLS_B (
    RESOURCE_CLASS,
    TRANS_CNT,
    DELETE_MARK,
    TEXT_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RESOURCE_CLASS,
    X_TRANS_CNT,
    X_DELETE_MARK,
    X_TEXT_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CR_RSRC_CLS_TL (
    RESOURCE_CLASS,
    RESOURCE_CLASS_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_RESOURCE_CLASS,
    X_RESOURCE_CLASS_DESC,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CR_RSRC_CLS_TL T
    where T.RESOURCE_CLASS = X_RESOURCE_CLASS
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
  X_RESOURCE_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_RESOURCE_CLASS_DESC in VARCHAR2
) is
  cursor c is select
      TRANS_CNT,
      DELETE_MARK,
      TEXT_CODE
    from CR_RSRC_CLS_B
    where RESOURCE_CLASS = X_RESOURCE_CLASS
    for update of RESOURCE_CLASS nowait;
  recinfo c%rowtype;

  cursor c1 is select
      RESOURCE_CLASS_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CR_RSRC_CLS_TL
    where RESOURCE_CLASS = X_RESOURCE_CLASS
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RESOURCE_CLASS nowait;
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
      if (    (tlinfo.RESOURCE_CLASS_DESC = X_RESOURCE_CLASS_DESC)
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
  X_RESOURCE_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_RESOURCE_CLASS_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CR_RSRC_CLS_B set
    TRANS_CNT = X_TRANS_CNT,
    DELETE_MARK = X_DELETE_MARK,
    TEXT_CODE = X_TEXT_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RESOURCE_CLASS = X_RESOURCE_CLASS;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CR_RSRC_CLS_TL set
    RESOURCE_CLASS_DESC = X_RESOURCE_CLASS_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RESOURCE_CLASS = X_RESOURCE_CLASS
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RESOURCE_CLASS in VARCHAR2
) is
begin
/*****************
  delete from CR_RSRC_CLS_TL
  where RESOURCE_CLASS = X_RESOURCE_CLASS;

  if (sql%notfound) then
    raise no_data_found;
  end if;

*****************/
  update CR_RSRC_CLS_B set delete_mark = 1
  where RESOURCE_CLASS = X_RESOURCE_CLASS;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CR_RSRC_CLS_TL T
  where not exists
    (select NULL
    from CR_RSRC_CLS_B B
    where B.RESOURCE_CLASS = T.RESOURCE_CLASS
    );

  update CR_RSRC_CLS_TL T set (
      RESOURCE_CLASS_DESC
    ) = (select
      B.RESOURCE_CLASS_DESC
    from CR_RSRC_CLS_TL B
    where B.RESOURCE_CLASS = T.RESOURCE_CLASS
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RESOURCE_CLASS,
      T.LANGUAGE
  ) in (select
      SUBT.RESOURCE_CLASS,
      SUBT.LANGUAGE
    from CR_RSRC_CLS_TL SUBB, CR_RSRC_CLS_TL SUBT
    where SUBB.RESOURCE_CLASS = SUBT.RESOURCE_CLASS
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RESOURCE_CLASS_DESC <> SUBT.RESOURCE_CLASS_DESC
  ));

  insert into CR_RSRC_CLS_TL (
    RESOURCE_CLASS,
    RESOURCE_CLASS_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.RESOURCE_CLASS,
    B.RESOURCE_CLASS_DESC,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CR_RSRC_CLS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CR_RSRC_CLS_TL T
    where T.RESOURCE_CLASS = B.RESOURCE_CLASS
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CR_RSRC_CLS_PKG;

/
