--------------------------------------------------------
--  DDL for Package Body GMD_TEST_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_TEST_VALUES_PKG" as
/* $Header: GMDGIAVB.pls 115.0 2002/03/12 12:54:34 pkm ship        $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_QCASSY_VAL_ID in NUMBER,
  X_QCASSY_TYP_ID in NUMBER,
  X_ORGN_CODE in VARCHAR2,
  X_ASSAY_CODE in VARCHAR2,
  X_ASSAY_VALUE in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_VALUE_NUM_MIN in NUMBER,
  X_VALUE_NUM_MAX in NUMBER,
  X_ASSAY_VALUE_RANGE_ORDER in NUMBER,
  X_VALUE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMD_TEST_VALUES_B
    where QCASSY_VAL_ID = X_QCASSY_VAL_ID
    ;
begin
  insert into GMD_TEST_VALUES_B (
    QCASSY_VAL_ID,
    QCASSY_TYP_ID,
    ORGN_CODE,
    ASSAY_CODE,
    ASSAY_VALUE,
    TEXT_CODE,
    VALUE_NUM_MIN,
    VALUE_NUM_MAX,
    ASSAY_VALUE_RANGE_ORDER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_QCASSY_VAL_ID,
    X_QCASSY_TYP_ID,
    X_ORGN_CODE,
    X_ASSAY_CODE,
    X_ASSAY_VALUE,
    X_TEXT_CODE,
    X_VALUE_NUM_MIN,
    X_VALUE_NUM_MAX,
    X_ASSAY_VALUE_RANGE_ORDER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMD_TEST_VALUES_TL (
    QCASSY_VAL_ID,
    QCASSY_TYP_ID,
    VALUE_DESC,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_QCASSY_VAL_ID,
    X_QCASSY_TYP_ID,
    X_VALUE_DESC,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMD_TEST_VALUES_TL T
    where T.QCASSY_VAL_ID = X_QCASSY_VAL_ID
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
  X_QCASSY_VAL_ID in NUMBER,
  X_QCASSY_TYP_ID in NUMBER,
  X_ORGN_CODE in VARCHAR2,
  X_ASSAY_CODE in VARCHAR2,
  X_ASSAY_VALUE in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_VALUE_NUM_MIN in NUMBER,
  X_VALUE_NUM_MAX in NUMBER,
  X_ASSAY_VALUE_RANGE_ORDER in NUMBER,
  X_VALUE_DESC in VARCHAR2
) is
  cursor c is select
      QCASSY_TYP_ID,
      ORGN_CODE,
      ASSAY_CODE,
      ASSAY_VALUE,
      TEXT_CODE,
      VALUE_NUM_MIN,
      VALUE_NUM_MAX,
      ASSAY_VALUE_RANGE_ORDER
    from GMD_TEST_VALUES_B
    where QCASSY_VAL_ID = X_QCASSY_VAL_ID
    for update of QCASSY_VAL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      VALUE_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMD_TEST_VALUES_TL
    where QCASSY_VAL_ID = X_QCASSY_VAL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of QCASSY_VAL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.QCASSY_TYP_ID = X_QCASSY_TYP_ID)
      AND ((recinfo.ORGN_CODE = X_ORGN_CODE)
           OR ((recinfo.ORGN_CODE is null) AND (X_ORGN_CODE is null)))
      AND (recinfo.ASSAY_CODE = X_ASSAY_CODE)
      AND (recinfo.ASSAY_VALUE = X_ASSAY_VALUE)
      AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
      AND ((recinfo.VALUE_NUM_MIN = X_VALUE_NUM_MIN)
           OR ((recinfo.VALUE_NUM_MIN is null) AND (X_VALUE_NUM_MIN is null)))
      AND ((recinfo.VALUE_NUM_MAX = X_VALUE_NUM_MAX)
           OR ((recinfo.VALUE_NUM_MAX is null) AND (X_VALUE_NUM_MAX is null)))
      AND ((recinfo.ASSAY_VALUE_RANGE_ORDER = X_ASSAY_VALUE_RANGE_ORDER)
           OR ((recinfo.ASSAY_VALUE_RANGE_ORDER is null) AND (X_ASSAY_VALUE_RANGE_ORDER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.VALUE_DESC = X_VALUE_DESC)
               OR ((tlinfo.VALUE_DESC is null) AND (X_VALUE_DESC is null)))
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
  X_QCASSY_VAL_ID in NUMBER,
  X_QCASSY_TYP_ID in NUMBER,
  X_ORGN_CODE in VARCHAR2,
  X_ASSAY_CODE in VARCHAR2,
  X_ASSAY_VALUE in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_VALUE_NUM_MIN in NUMBER,
  X_VALUE_NUM_MAX in NUMBER,
  X_ASSAY_VALUE_RANGE_ORDER in NUMBER,
  X_VALUE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMD_TEST_VALUES_B set
    ORGN_CODE = X_ORGN_CODE,
    ASSAY_CODE = X_ASSAY_CODE,
    ASSAY_VALUE = X_ASSAY_VALUE,
    TEXT_CODE = X_TEXT_CODE,
    VALUE_NUM_MIN = X_VALUE_NUM_MIN,
    VALUE_NUM_MAX = X_VALUE_NUM_MAX,
    ASSAY_VALUE_RANGE_ORDER = X_ASSAY_VALUE_RANGE_ORDER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where QCASSY_VAL_ID = X_QCASSY_VAL_ID
  and   QCASSY_TYP_ID = X_QCASSY_TYP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMD_TEST_VALUES_TL set
    VALUE_DESC = X_VALUE_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where QCASSY_VAL_ID = X_QCASSY_VAL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_QCASSY_VAL_ID in NUMBER
) is
begin
  delete from GMD_TEST_VALUES_TL
  where QCASSY_VAL_ID = X_QCASSY_VAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMD_TEST_VALUES_B
  where QCASSY_VAL_ID = X_QCASSY_VAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMD_TEST_VALUES_TL T
  where not exists
    (select NULL
    from GMD_TEST_VALUES_B B
    where B.QCASSY_VAL_ID = T.QCASSY_VAL_ID
    );

  update GMD_TEST_VALUES_TL T set (
      VALUE_DESC
    ) = (select
      B.VALUE_DESC
    from GMD_TEST_VALUES_TL B
    where B.QCASSY_VAL_ID = T.QCASSY_VAL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QCASSY_VAL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.QCASSY_VAL_ID,
      SUBT.LANGUAGE
    from GMD_TEST_VALUES_TL SUBB, GMD_TEST_VALUES_TL SUBT
    where SUBB.QCASSY_VAL_ID = SUBT.QCASSY_VAL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.VALUE_DESC <> SUBT.VALUE_DESC
      or (SUBB.VALUE_DESC is null and SUBT.VALUE_DESC is not null)
      or (SUBB.VALUE_DESC is not null and SUBT.VALUE_DESC is null)
  ));

  insert into GMD_TEST_VALUES_TL (
    QCASSY_VAL_ID,
    QCASSY_TYP_ID,
    VALUE_DESC,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.QCASSY_VAL_ID,
    B.QCASSY_TYP_ID,
    B.VALUE_DESC,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMD_TEST_VALUES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMD_TEST_VALUES_TL T
    where T.QCASSY_VAL_ID = B.QCASSY_VAL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMD_TEST_VALUES_PKG;

/
