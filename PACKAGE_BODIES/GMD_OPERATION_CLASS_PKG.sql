--------------------------------------------------------
--  DDL for Package Body GMD_OPERATION_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_OPERATION_CLASS_PKG" as
/* $Header: GMDOPCMB.pls 115.3 2002/10/24 21:54:37 santunes noship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY  VARCHAR2,
  X_OPRN_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_OPRN_CLASS_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMD_OPERATION_CLASS_B
    where OPRN_CLASS = X_OPRN_CLASS
    ;
begin
  insert into GMD_OPERATION_CLASS_B (
    OPRN_CLASS,
    TRANS_CNT,
    DELETE_MARK,
    TEXT_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OPRN_CLASS,
    X_TRANS_CNT,
    X_DELETE_MARK,
    X_TEXT_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMD_OPERATION_CLASS_TL (
    OPRN_CLASS,
    OPRN_CLASS_DESC,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OPRN_CLASS,
    X_OPRN_CLASS_DESC,
    X_CREATION_DATE,
    X_LAST_UPDATE_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMD_OPERATION_CLASS_TL T
    where T.OPRN_CLASS = X_OPRN_CLASS
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
  X_OPRN_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_OPRN_CLASS_DESC in VARCHAR2
) is
  cursor c is select
      TRANS_CNT,
      DELETE_MARK,
      TEXT_CODE
    from GMD_OPERATION_CLASS_B
    where OPRN_CLASS = X_OPRN_CLASS
    for update of OPRN_CLASS nowait;
  recinfo c%rowtype;

  cursor c1 is select
      OPRN_CLASS_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMD_OPERATION_CLASS_TL
    where OPRN_CLASS = X_OPRN_CLASS
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of OPRN_CLASS nowait;
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
      if (    (tlinfo.OPRN_CLASS_DESC = X_OPRN_CLASS_DESC)
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
  X_OPRN_CLASS in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_OPRN_CLASS_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMD_OPERATION_CLASS_B set
    TRANS_CNT = X_TRANS_CNT,
    DELETE_MARK = X_DELETE_MARK,
    TEXT_CODE = X_TEXT_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OPRN_CLASS = X_OPRN_CLASS;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMD_OPERATION_CLASS_TL set
    OPRN_CLASS_DESC = X_OPRN_CLASS_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OPRN_CLASS = X_OPRN_CLASS
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OPRN_CLASS in VARCHAR2
) is
begin

  UPDATE GMD_OPERATION_CLASS_B
  SET delete_mark = 1
  where OPRN_CLASS = X_OPRN_CLASS;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMD_OPERATION_CLASS_TL T
  where not exists
    (select NULL
    from GMD_OPERATION_CLASS_B B
    where B.OPRN_CLASS = T.OPRN_CLASS
    );

  update GMD_OPERATION_CLASS_TL T set (
      OPRN_CLASS_DESC
    ) = (select
      B.OPRN_CLASS_DESC
    from GMD_OPERATION_CLASS_TL B
    where B.OPRN_CLASS = T.OPRN_CLASS
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OPRN_CLASS,
      T.LANGUAGE
  ) in (select
      SUBT.OPRN_CLASS,
      SUBT.LANGUAGE
    from GMD_OPERATION_CLASS_TL SUBB, GMD_OPERATION_CLASS_TL SUBT
    where SUBB.OPRN_CLASS = SUBT.OPRN_CLASS
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.OPRN_CLASS_DESC <> SUBT.OPRN_CLASS_DESC
  ));

  insert into GMD_OPERATION_CLASS_TL (
    OPRN_CLASS,
    OPRN_CLASS_DESC,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.OPRN_CLASS,
    B.OPRN_CLASS_DESC,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMD_OPERATION_CLASS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMD_OPERATION_CLASS_TL T
    where T.OPRN_CLASS = B.OPRN_CLASS
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMD_OPERATION_CLASS_PKG;

/
