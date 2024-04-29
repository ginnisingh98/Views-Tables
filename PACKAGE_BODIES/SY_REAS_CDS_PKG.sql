--------------------------------------------------------
--  DDL for Package Body SY_REAS_CDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SY_REAS_CDS_PKG" as
/* $Header: gmareasb.pls 115.2 2002/10/31 20:38:41 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REASON_CODE in VARCHAR2,
  X_REASON_DESC2 in VARCHAR2,
  X_REASON_TYPE in NUMBER,
  X_FLOW_TYPE in NUMBER,
  X_AUTH_STRING in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_REASON_DESC1 in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from SY_REAS_CDS_B
    where REASON_CODE = X_REASON_CODE
    ;
begin
  insert into SY_REAS_CDS_B (
    REASON_CODE,
    REASON_DESC2,
    REASON_TYPE,
    FLOW_TYPE,
    AUTH_STRING,
    DELETE_MARK,
    TEXT_CODE,
    TRANS_CNT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_REASON_CODE,
    X_REASON_DESC2,
    X_REASON_TYPE,
    X_FLOW_TYPE,
    X_AUTH_STRING,
    X_DELETE_MARK,
    X_TEXT_CODE,
    X_TRANS_CNT,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into SY_REAS_CDS_TL (
    REASON_CODE,
    REASON_DESC1,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_REASON_CODE,
    X_REASON_DESC1,
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
    from SY_REAS_CDS_TL T
    where T.REASON_CODE = X_REASON_CODE
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
  X_REASON_CODE in VARCHAR2,
  X_REASON_DESC2 in VARCHAR2,
  X_REASON_TYPE in NUMBER,
  X_FLOW_TYPE in NUMBER,
  X_AUTH_STRING in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_REASON_DESC1 in VARCHAR2
) is
  cursor c is select
      REASON_DESC2,
      REASON_TYPE,
      FLOW_TYPE,
      AUTH_STRING,
      DELETE_MARK,
      TEXT_CODE,
      TRANS_CNT
    from SY_REAS_CDS_B
    where REASON_CODE = X_REASON_CODE
    for update of REASON_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      REASON_DESC1,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from SY_REAS_CDS_TL
    where REASON_CODE = X_REASON_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of REASON_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.REASON_DESC2 = X_REASON_DESC2)
           OR ((recinfo.REASON_DESC2 is null) AND (X_REASON_DESC2 is null)))
      AND (recinfo.REASON_TYPE = X_REASON_TYPE)
      AND (recinfo.FLOW_TYPE = X_FLOW_TYPE)
      AND ((recinfo.AUTH_STRING = X_AUTH_STRING)
           OR ((recinfo.AUTH_STRING is null) AND (X_AUTH_STRING is null)))
      AND (recinfo.DELETE_MARK = X_DELETE_MARK)
      AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
      AND ((recinfo.TRANS_CNT = X_TRANS_CNT)
           OR ((recinfo.TRANS_CNT is null) AND (X_TRANS_CNT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.REASON_DESC1 = X_REASON_DESC1)
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
  X_REASON_CODE in VARCHAR2,
  X_REASON_DESC2 in VARCHAR2,
  X_REASON_TYPE in NUMBER,
  X_FLOW_TYPE in NUMBER,
  X_AUTH_STRING in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_REASON_DESC1 in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update SY_REAS_CDS_B set
    REASON_DESC2 = X_REASON_DESC2,
    REASON_TYPE = X_REASON_TYPE,
    FLOW_TYPE = X_FLOW_TYPE,
    AUTH_STRING = X_AUTH_STRING,
    DELETE_MARK = X_DELETE_MARK,
    TEXT_CODE = X_TEXT_CODE,
    TRANS_CNT = X_TRANS_CNT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where REASON_CODE = X_REASON_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update SY_REAS_CDS_TL set
    REASON_DESC1 = X_REASON_DESC1,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REASON_CODE = X_REASON_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REASON_CODE in VARCHAR2
) is
begin
/*****************
  delete from SY_REAS_CDS_TL
  where REASON_CODE = X_REASON_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
  ************************ */

  update SY_REAS_CDS_B set delete_mark = 1
  where REASON_CODE = X_REASON_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from SY_REAS_CDS_TL T
  where not exists
    (select NULL
    from SY_REAS_CDS_B B
    where B.REASON_CODE = T.REASON_CODE
    );

  update SY_REAS_CDS_TL T set (
      REASON_DESC1
    ) = (select
      B.REASON_DESC1
    from SY_REAS_CDS_TL B
    where B.REASON_CODE = T.REASON_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REASON_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.REASON_CODE,
      SUBT.LANGUAGE
    from SY_REAS_CDS_TL SUBB, SY_REAS_CDS_TL SUBT
    where SUBB.REASON_CODE = SUBT.REASON_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.REASON_DESC1 <> SUBT.REASON_DESC1
  ));

  insert into SY_REAS_CDS_TL (
    REASON_CODE,
    REASON_DESC1,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.REASON_CODE,
    B.REASON_DESC1,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from SY_REAS_CDS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from SY_REAS_CDS_TL T
    where T.REASON_CODE = B.REASON_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end SY_REAS_CDS_PKG;

/
