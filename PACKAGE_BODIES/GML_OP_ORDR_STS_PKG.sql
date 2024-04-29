--------------------------------------------------------
--  DDL for Package Body GML_OP_ORDR_STS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_OP_ORDR_STS_PKG" as
/* $Header: GMLOSTSB.pls 115.11 2002/11/08 06:02:24 gmangari ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORDER_STATUS in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_ORDER_STATUS_CODE in VARCHAR2,
  X_ORDER_STATUS_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from OP_ORDR_STS_B
    where ORDER_STATUS = X_ORDER_STATUS
    ;
begin
  insert into OP_ORDR_STS_B (
    ORDER_STATUS,
    LANG_CODE,
    TRANS_CNT,
    TEXT_CODE,
    DELETE_MARK,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ORDER_STATUS,
    X_LANG_CODE,
    X_TRANS_CNT,
    X_TEXT_CODE,
    X_DELETE_MARK,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into OP_ORDR_STS_TL (
    ORDER_STATUS,
    ORDER_STATUS_CODE,
    ORDER_STATUS_DESC,
    CREATED_BY,
    LAST_UPDATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ORDER_STATUS,
    X_ORDER_STATUS_CODE,
    X_ORDER_STATUS_DESC,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from OP_ORDR_STS_TL T
    where T.ORDER_STATUS = X_ORDER_STATUS
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
  X_ORDER_STATUS in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_ORDER_STATUS_CODE in VARCHAR2,
  X_ORDER_STATUS_DESC in VARCHAR2
) is
/* BUG 1272860 Changed table from OP_ORDR_STS_B to OP_ORDR_STS_VL in cursor c. */
  cursor c is select
      LANG_CODE,
      TRANS_CNT,
      TEXT_CODE,
      DELETE_MARK
    from OP_ORDR_STS_VL
    where ORDER_STATUS = X_ORDER_STATUS
    for update of ORDER_STATUS nowait;
/* BUG 1272860 End bug fix. */
  recinfo c%rowtype;

  cursor c1 is select
      ORDER_STATUS_CODE,
      ORDER_STATUS_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from OP_ORDR_STS_TL
    where ORDER_STATUS = X_ORDER_STATUS
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ORDER_STATUS nowait;
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
      if (    (tlinfo.ORDER_STATUS_CODE = X_ORDER_STATUS_CODE)
          AND (tlinfo.ORDER_STATUS_DESC = X_ORDER_STATUS_DESC)
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
  X_ORDER_STATUS in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_TRANS_CNT in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_ORDER_STATUS_CODE in VARCHAR2,
  X_ORDER_STATUS_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update OP_ORDR_STS_B set
    LANG_CODE = X_LANG_CODE,
    TRANS_CNT = X_TRANS_CNT,
    TEXT_CODE = X_TEXT_CODE,
    DELETE_MARK = X_DELETE_MARK,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ORDER_STATUS = X_ORDER_STATUS;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update OP_ORDR_STS_TL set
    ORDER_STATUS_CODE = X_ORDER_STATUS_CODE,
    ORDER_STATUS_DESC = X_ORDER_STATUS_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ORDER_STATUS = X_ORDER_STATUS
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ORDER_STATUS in NUMBER
) is
begin
  delete from OP_ORDR_STS_TL
  where ORDER_STATUS = X_ORDER_STATUS;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from OP_ORDR_STS_B
  where ORDER_STATUS = X_ORDER_STATUS;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from OP_ORDR_STS_TL T
  where not exists
    (select NULL
    from OP_ORDR_STS_B B
    where B.ORDER_STATUS = T.ORDER_STATUS
    );

  update OP_ORDR_STS_TL T set (
      ORDER_STATUS_CODE,
      ORDER_STATUS_DESC
    ) = (select
      B.ORDER_STATUS_CODE,
      B.ORDER_STATUS_DESC
    from OP_ORDR_STS_TL B
    where B.ORDER_STATUS = T.ORDER_STATUS
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ORDER_STATUS,
      T.LANGUAGE
  ) in (select
      SUBT.ORDER_STATUS,
      SUBT.LANGUAGE
    from OP_ORDR_STS_TL SUBB, OP_ORDR_STS_TL SUBT
    where SUBB.ORDER_STATUS = SUBT.ORDER_STATUS
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ORDER_STATUS_CODE <> SUBT.ORDER_STATUS_CODE
      or SUBB.ORDER_STATUS_DESC <> SUBT.ORDER_STATUS_DESC
  ));

  insert into OP_ORDR_STS_TL (
    ORDER_STATUS,
    ORDER_STATUS_CODE,
    ORDER_STATUS_DESC,
    CREATED_BY,
    LAST_UPDATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORDER_STATUS,
    B.ORDER_STATUS_CODE,
    B.ORDER_STATUS_DESC,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OP_ORDR_STS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OP_ORDR_STS_TL T
    where T.ORDER_STATUS = B.ORDER_STATUS
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
   X_ORDER_STATUS            VARCHAR2,
   X_ORDER_STATUS_DESC       VARCHAR2,
   X_ORDER_STATUS_CODE       VARCHAR2
) IS

BEGIN
  update OP_ORDR_STS_TL set
    ORDER_STATUS_DESC = X_ORDER_STATUS_DESC,
    ORDER_STATUS_CODE = X_ORDER_STATUS_CODE,
    SOURCE_LANG = userenv('LANG'),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = 0,
    LAST_UPDATE_LOGIN = 0
  where
    ORDER_STATUS  = X_ORDER_STATUS  and
    userenv('LANG') in (LANGUAGE,SOURCE_LANG);
end TRANSLATE_ROW;


procedure LOAD_ROW(
   X_ORDER_STATUS_CODE       VARCHAR2,
   X_ORDER_STATUS            VARCHAR2,
   X_LANG_CODE               VARCHAR2,
   X_TRANS_CNT               VARCHAR2,
   X_TEXT_CODE               VARCHAR2,
   X_DELETE_MARK             VARCHAR2,
   X_ORDER_STATUS_DESC       VARCHAR2
) IS

l_user_id       number :=0;
l_row_id        VARCHAR2(64);

BEGIN
        l_user_id :=1;

  GML_OP_ORDR_STS_PKG.UPDATE_ROW (
     X_ORDER_STATUS =>  X_ORDER_STATUS ,
     X_LANG_CODE =>  X_LANG_CODE ,
     X_TRANS_CNT => X_TRANS_CNT,
     X_TEXT_CODE => X_TEXT_CODE ,
     X_DELETE_MARK => X_DELETE_MARK,
     X_ORDER_STATUS_CODE => X_ORDER_STATUS_CODE ,
     X_ORDER_STATUS_DESC =>  X_ORDER_STATUS_DESC,
     X_LAST_UPDATE_DATE =>  sysdate ,
     X_LAST_UPDATED_BY => l_user_id,
     X_LAST_UPDATE_LOGIN => l_user_id
  );

EXCEPTION
  WHEN NO_DATA_FOUND THEN

GML_OP_ORDR_STS_PKG.INSERT_ROW(
     X_ROWID => l_row_id,
     X_ORDER_STATUS =>  X_ORDER_STATUS ,
     X_LANG_CODE =>  X_LANG_CODE ,
     X_TRANS_CNT => X_TRANS_CNT,
     X_TEXT_CODE => X_TEXT_CODE ,
     X_DELETE_MARK => X_DELETE_MARK,
     X_ORDER_STATUS_CODE => X_ORDER_STATUS_CODE ,
     X_ORDER_STATUS_DESC =>  X_ORDER_STATUS_DESC,
     X_CREATION_DATE => sysdate,
     X_CREATED_BY  => l_user_id,
     X_LAST_UPDATE_DATE =>  sysdate ,
     X_LAST_UPDATED_BY => l_user_id,
     X_LAST_UPDATE_LOGIN => 0
);

END LOAD_ROW;

end GML_OP_ORDR_STS_PKG;

/
