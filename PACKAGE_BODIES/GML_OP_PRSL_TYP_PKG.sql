--------------------------------------------------------
--  DDL for Package Body GML_OP_PRSL_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_OP_PRSL_TYP_PKG" as
/* $Header: GMLPRSLB.pls 115.8 2002/11/08 07:00:47 gmangari ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PRESALES_ORD_TYPE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_RELEASE_SCHED_REQD in NUMBER,
  X_PRICELIST_IND in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_PRESALES_ORD_CODE in VARCHAR2,
  X_PRESALES_ORD_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from OP_PRSL_TYP_B
    where PRESALES_ORD_TYPE = X_PRESALES_ORD_TYPE
    ;
begin
  insert into OP_PRSL_TYP_B (
    PRESALES_ORD_TYPE,
    LANG_CODE,
    RELEASE_SCHED_REQD,
    PRICELIST_IND,
    TRANS_CNT,
    TEXT_CODE,
    DELETE_MARK,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PRESALES_ORD_TYPE,
    X_LANG_CODE,
    X_RELEASE_SCHED_REQD,
    X_PRICELIST_IND,
    X_TRANS_CNT,
    X_TEXT_CODE,
    X_DELETE_MARK,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into OP_PRSL_TYP_TL (
    PRESALES_ORD_TYPE,
    PRESALES_ORD_CODE,
    PRESALES_ORD_DESC,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PRESALES_ORD_TYPE,
    X_PRESALES_ORD_CODE,
    X_PRESALES_ORD_DESC,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from OP_PRSL_TYP_TL T
    where T.PRESALES_ORD_TYPE = X_PRESALES_ORD_TYPE
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
  X_PRESALES_ORD_TYPE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_RELEASE_SCHED_REQD in NUMBER,
  X_PRICELIST_IND in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_PRESALES_ORD_CODE in VARCHAR2,
  X_PRESALES_ORD_DESC in VARCHAR2
) is
  cursor c is select
      LANG_CODE,
      RELEASE_SCHED_REQD,
      PRICELIST_IND,
      TRANS_CNT,
      TEXT_CODE,
      DELETE_MARK
    from OP_PRSL_TYP_B
    where PRESALES_ORD_TYPE = X_PRESALES_ORD_TYPE
    for update of PRESALES_ORD_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PRESALES_ORD_CODE,
      PRESALES_ORD_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from OP_PRSL_TYP_TL
    where PRESALES_ORD_TYPE = X_PRESALES_ORD_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PRESALES_ORD_TYPE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.LANG_CODE = X_LANG_CODE)
      AND (recinfo.RELEASE_SCHED_REQD = X_RELEASE_SCHED_REQD)
      AND (recinfo.PRICELIST_IND = X_PRICELIST_IND)
      AND (recinfo.TRANS_CNT = X_TRANS_CNT)
      AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
      AND (recinfo.DELETE_MARK = X_DELETE_MARK)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.PRESALES_ORD_CODE = X_PRESALES_ORD_CODE)
          AND (tlinfo.PRESALES_ORD_DESC = X_PRESALES_ORD_DESC)
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
  X_PRESALES_ORD_TYPE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_RELEASE_SCHED_REQD in NUMBER,
  X_PRICELIST_IND in NUMBER,
  X_TRANS_CNT in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_PRESALES_ORD_CODE in VARCHAR2,
  X_PRESALES_ORD_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update OP_PRSL_TYP_B set
    LANG_CODE = X_LANG_CODE,
    RELEASE_SCHED_REQD = X_RELEASE_SCHED_REQD,
    PRICELIST_IND = X_PRICELIST_IND,
    TRANS_CNT = X_TRANS_CNT,
    TEXT_CODE = X_TEXT_CODE,
    DELETE_MARK = X_DELETE_MARK,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PRESALES_ORD_TYPE = X_PRESALES_ORD_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update OP_PRSL_TYP_TL set
    PRESALES_ORD_CODE = X_PRESALES_ORD_CODE,
    PRESALES_ORD_DESC = X_PRESALES_ORD_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PRESALES_ORD_TYPE = X_PRESALES_ORD_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PRESALES_ORD_TYPE in NUMBER
) is
begin
  delete from OP_PRSL_TYP_TL
  where PRESALES_ORD_TYPE = X_PRESALES_ORD_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from OP_PRSL_TYP_B
  where PRESALES_ORD_TYPE = X_PRESALES_ORD_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from OP_PRSL_TYP_TL T
  where not exists
    (select NULL
    from OP_PRSL_TYP_B B
    where B.PRESALES_ORD_TYPE = T.PRESALES_ORD_TYPE
    );

  update OP_PRSL_TYP_TL T set (
      PRESALES_ORD_CODE,
      PRESALES_ORD_DESC
    ) = (select
      B.PRESALES_ORD_CODE,
      B.PRESALES_ORD_DESC
    from OP_PRSL_TYP_TL B
    where B.PRESALES_ORD_TYPE = T.PRESALES_ORD_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PRESALES_ORD_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.PRESALES_ORD_TYPE,
      SUBT.LANGUAGE
    from OP_PRSL_TYP_TL SUBB, OP_PRSL_TYP_TL SUBT
    where SUBB.PRESALES_ORD_TYPE = SUBT.PRESALES_ORD_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PRESALES_ORD_CODE <> SUBT.PRESALES_ORD_CODE
      or SUBB.PRESALES_ORD_DESC <> SUBT.PRESALES_ORD_DESC
  ));

  insert into OP_PRSL_TYP_TL (
    PRESALES_ORD_TYPE,
    PRESALES_ORD_CODE,
    PRESALES_ORD_DESC,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PRESALES_ORD_TYPE,
    B.PRESALES_ORD_CODE,
    B.PRESALES_ORD_DESC,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OP_PRSL_TYP_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OP_PRSL_TYP_TL T
    where T.PRESALES_ORD_TYPE = B.PRESALES_ORD_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
   X_PRESALES_ORD_TYPE      VARCHAR2 ,
   X_PRESALES_ORD_DESC       VARCHAR2
) IS

BEGIN
  update OP_PRSL_TYP_TL set
    PRESALES_ORD_DESC = X_PRESALES_ORD_DESC,
    SOURCE_LANG = userenv('LANG'),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = 0,
    LAST_UPDATE_LOGIN = 0
  where
    PRESALES_ORD_TYPE = X_PRESALES_ORD_TYPE and
    userenv('LANG') in (LANGUAGE,SOURCE_LANG);
end TRANSLATE_ROW;


procedure LOAD_ROW (
   X_PRESALES_ORD_TYPE      VARCHAR2 ,
   X_LANG_CODE              VARCHAR2,
   X_RELEASE_SCHED_REQD      VARCHAR2,
   X_PRICELIST_IND           VARCHAR2,
   X_PRESALES_ORD_CODE       VARCHAR2,
   X_TRANS_CNT               VARCHAR2,
   X_TEXT_CODE               VARCHAR2,
   X_DELETE_MARK             VARCHAR2,
   X_PRESALES_ORD_DESC       VARCHAR2
) IS

l_user_id       number :=0;
l_row_id        VARCHAR2(64);

BEGIN
        l_user_id :=1;
   GML_OP_PRSL_TYP_PKG.UPDATE_ROW (
       X_PRESALES_ORD_TYPE =>  X_PRESALES_ORD_TYPE,
       X_LANG_CODE => X_LANG_CODE,
       X_RELEASE_SCHED_REQD => X_RELEASE_SCHED_REQD,
       X_PRICELIST_IND => X_PRICELIST_IND,
       X_TRANS_CNT =>  X_TRANS_CNT,
       X_TEXT_CODE => X_TEXT_CODE,
       X_DELETE_MARK => X_DELETE_MARK ,
       X_PRESALES_ORD_CODE => X_PRESALES_ORD_CODE,
       X_PRESALES_ORD_DESC => X_PRESALES_ORD_DESC ,
       X_LAST_UPDATE_DATE => sysdate ,
       X_LAST_UPDATED_BY => l_user_id,
       X_LAST_UPDATE_LOGIN => 0
  );

EXCEPTION
  WHEN NO_DATA_FOUND THEN

GML_OP_PRSL_TYP_PKG.INSERT_ROW(
       X_ROWID => l_row_id,
       X_PRESALES_ORD_TYPE =>  X_PRESALES_ORD_TYPE,
       X_LANG_CODE => X_LANG_CODE,
       X_RELEASE_SCHED_REQD => X_RELEASE_SCHED_REQD,
       X_PRICELIST_IND => X_PRICELIST_IND,
       X_TRANS_CNT =>  X_TRANS_CNT,
       X_TEXT_CODE => X_TEXT_CODE,
       X_DELETE_MARK => X_DELETE_MARK ,
       X_PRESALES_ORD_CODE => X_PRESALES_ORD_CODE,
       X_PRESALES_ORD_DESC => X_PRESALES_ORD_DESC ,
       X_CREATION_DATE => sysdate,
       X_CREATED_BY => l_user_id,
       X_LAST_UPDATE_DATE => sysdate ,
       X_LAST_UPDATED_BY => l_user_id,
       X_LAST_UPDATE_LOGIN => 0
     );

END LOAD_ROW;

end GML_OP_PRSL_TYP_PKG;

/
