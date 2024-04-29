--------------------------------------------------------
--  DDL for Package Body GMA_SY_PARA_CDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_SY_PARA_CDS_PKG" AS
/* $Header: GMAPARAB.pls 115.6 2002/10/31 19:29:38 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_NONPRINTABLE_IND in NUMBER,
  X_PARA_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from SY_PARA_CDS_TL
    where TABLE_NAME = X_TABLE_NAME
    and LANG_CODE = X_LANG_CODE
    and PARAGRAPH_CODE = X_PARAGRAPH_CODE
    and SUB_PARACODE = X_SUB_PARACODE
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into SY_PARA_CDS_TL (
    TABLE_NAME,
    LANG_CODE,
    PARAGRAPH_CODE,
    SUB_PARACODE,
    PARA_DESC,
    NONPRINTABLE_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TABLE_NAME,
    X_LANG_CODE,
    X_PARAGRAPH_CODE,
    X_SUB_PARACODE,
    X_PARA_DESC,
    X_NONPRINTABLE_IND,
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
    from SY_PARA_CDS_TL T
    where T.TABLE_NAME = X_TABLE_NAME
    and T.LANG_CODE = X_LANG_CODE
    and T.PARAGRAPH_CODE = X_PARAGRAPH_CODE
    and T.SUB_PARACODE = X_SUB_PARACODE
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
  X_TABLE_NAME in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_NONPRINTABLE_IND in NUMBER,
  X_PARA_DESC in VARCHAR2
) is
  cursor c1 is select
      NONPRINTABLE_IND,
      PARA_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from SY_PARA_CDS_TL
    where TABLE_NAME = X_TABLE_NAME
    and LANG_CODE = X_LANG_CODE
    and PARAGRAPH_CODE = X_PARAGRAPH_CODE
    and SUB_PARACODE = X_SUB_PARACODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TABLE_NAME nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.PARA_DESC = X_PARA_DESC)
          AND (tlinfo.NONPRINTABLE_IND = X_NONPRINTABLE_IND)
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
  X_TABLE_NAME in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_NONPRINTABLE_IND in NUMBER,
  X_PARA_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update SY_PARA_CDS_TL set
    NONPRINTABLE_IND = X_NONPRINTABLE_IND,
    PARA_DESC = X_PARA_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TABLE_NAME = X_TABLE_NAME
  and LANG_CODE = X_LANG_CODE
  and PARAGRAPH_CODE = X_PARAGRAPH_CODE
  and SUB_PARACODE = X_SUB_PARACODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TABLE_NAME in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER
) is
begin
  delete from SY_PARA_CDS_TL
  where TABLE_NAME = X_TABLE_NAME
  and LANG_CODE = X_LANG_CODE
  and PARAGRAPH_CODE = X_PARAGRAPH_CODE
  and SUB_PARACODE = X_SUB_PARACODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update SY_PARA_CDS_TL T set (
      PARA_DESC
    ) = (select
      B.PARA_DESC
    from SY_PARA_CDS_TL B
    where B.TABLE_NAME = T.TABLE_NAME
    and B.LANG_CODE = T.LANG_CODE
    and B.PARAGRAPH_CODE = T.PARAGRAPH_CODE
    and B.SUB_PARACODE = T.SUB_PARACODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TABLE_NAME,
      T.LANG_CODE,
      T.PARAGRAPH_CODE,
      T.SUB_PARACODE,
      T.LANGUAGE
  ) in (select
      SUBT.TABLE_NAME,
      SUBT.LANG_CODE,
      SUBT.PARAGRAPH_CODE,
      SUBT.SUB_PARACODE,
      SUBT.LANGUAGE
    from SY_PARA_CDS_TL SUBB, SY_PARA_CDS_TL SUBT
    where SUBB.TABLE_NAME = SUBT.TABLE_NAME
    and SUBB.LANG_CODE = SUBT.LANG_CODE
    and SUBB.PARAGRAPH_CODE = SUBT.PARAGRAPH_CODE
    and SUBB.SUB_PARACODE = SUBT.SUB_PARACODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PARA_DESC <> SUBT.PARA_DESC
  ));

  insert into SY_PARA_CDS_TL (
    TABLE_NAME,
    LANG_CODE,
    PARAGRAPH_CODE,
    SUB_PARACODE,
    PARA_DESC,
    NONPRINTABLE_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TABLE_NAME,
    B.LANG_CODE,
    B.PARAGRAPH_CODE,
    B.SUB_PARACODE,
    B.PARA_DESC,
    B.NONPRINTABLE_IND,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from SY_PARA_CDS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from SY_PARA_CDS_TL T
    where T.TABLE_NAME = B.TABLE_NAME
    and T.LANG_CODE = B.LANG_CODE
    and T.PARAGRAPH_CODE = B.PARAGRAPH_CODE
    and T.SUB_PARACODE = B.SUB_PARACODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_TABLE_NAME in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_PARA_DESC in VARCHAR2
) IS
BEGIN
  update SY_PARA_CDS_TL set
    PARA_DESC = X_PARA_DESC,
    SOURCE_LANG   = userenv('LANG'),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = 0,
    LAST_UPDATE_LOGIN = 0
  where TABLE_NAME = X_TABLE_NAME
   and PARAGRAPH_CODE = X_PARAGRAPH_CODE
   and SUB_PARACODE = X_SUB_PARACODE
   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_TABLE_NAME in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_NONPRINTABLE_IND in NUMBER,
  X_PARA_DESC in VARCHAR2
) IS
 l_user_id number:=0;
 l_row_id VARCHAR2(64);
 BEGIN
  /*  IF (X_OWNER ='SEED') THEN */
        l_user_id :=1;
  /*  END IF; */

   GMA_SY_PARA_CDS_PKG.UPDATE_ROW (

     X_TABLE_NAME => X_TABLE_NAME,
     X_LANG_CODE => X_LANG_CODE,
     X_PARAGRAPH_CODE => X_PARAGRAPH_CODE,
     X_SUB_PARACODE => X_SUB_PARACODE,
     X_NONPRINTABLE_IND => X_NONPRINTABLE_IND,
     X_PARA_DESC => X_PARA_DESC,
     X_LAST_UPDATE_DATE => sysdate,
     X_LAST_UPDATED_BY => l_user_id,
     X_LAST_UPDATE_LOGIN => 0
                                   );


 EXCEPTION
    WHEN NO_DATA_FOUND THEN


  GMA_SY_PARA_CDS_PKG.INSERT_ROW (  X_ROWID => l_row_id,
                                    X_TABLE_NAME => X_TABLE_NAME,
                                    X_LANG_CODE => X_LANG_CODE,
                                    X_PARAGRAPH_CODE => X_PARAGRAPH_CODE,
                                    X_SUB_PARACODE => X_SUB_PARACODE,
                                    X_NONPRINTABLE_IND => X_NONPRINTABLE_IND,
                                    X_PARA_DESC => X_PARA_DESC,
                                    X_CREATION_DATE => sysdate,
				    X_CREATED_BY => l_user_id,
                                    X_LAST_UPDATE_DATE => sysdate,
                                    X_LAST_UPDATED_BY => l_user_id,
                                    X_LAST_UPDATE_LOGIN => 0
                                   );

END LOAD_ROW;


end GMA_SY_PARA_CDS_PKG;

/
