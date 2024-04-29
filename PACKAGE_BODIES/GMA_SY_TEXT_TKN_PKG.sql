--------------------------------------------------------
--  DDL for Package Body GMA_SY_TEXT_TKN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_SY_TEXT_TKN_PKG" AS
/* $Header: GMATKNB.pls 115.3 2002/11/20 18:09:07 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TEXT_KEY in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_TOKEN_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from SY_TEXT_TKN_TL
    where TEXT_KEY = X_TEXT_KEY
    and LANG_CODE = X_LANG_CODE
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into SY_TEXT_TKN_TL (
    TEXT_KEY,
    LANG_CODE,
    TEXT_CODE,
    TOKEN_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TEXT_KEY,
    X_LANG_CODE,
    X_TEXT_CODE,
    X_TOKEN_DESC,
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
    from SY_TEXT_TKN_TL T
    where T.TEXT_KEY = X_TEXT_KEY
    and T.LANG_CODE = X_LANG_CODE
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
  X_TEXT_KEY in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_TOKEN_DESC in VARCHAR2
) is
  cursor c1 is select
      TEXT_CODE,
      TOKEN_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from SY_TEXT_TKN_TL
    where TEXT_KEY = X_TEXT_KEY
    and LANG_CODE = X_LANG_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TEXT_KEY nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TOKEN_DESC = X_TOKEN_DESC)
          AND ((tlinfo.TEXT_CODE = X_TEXT_CODE)
               OR ((tlinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
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
  X_TEXT_KEY in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_TOKEN_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update SY_TEXT_TKN_TL set
    TEXT_CODE = X_TEXT_CODE,
    TOKEN_DESC = X_TOKEN_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TEXT_KEY = X_TEXT_KEY
  and LANG_CODE = X_LANG_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TEXT_KEY in VARCHAR2,
  X_LANG_CODE in VARCHAR2
) is
begin
  delete from SY_TEXT_TKN_TL
  where TEXT_KEY = X_TEXT_KEY
  and LANG_CODE = X_LANG_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update SY_TEXT_TKN_TL T set (
      TOKEN_DESC
    ) = (select
      B.TOKEN_DESC
    from SY_TEXT_TKN_TL B
    where B.TEXT_KEY = T.TEXT_KEY
    and B.LANG_CODE = T.LANG_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEXT_KEY,
      T.LANG_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.TEXT_KEY,
      SUBT.LANG_CODE,
      SUBT.LANGUAGE
    from SY_TEXT_TKN_TL SUBB, SY_TEXT_TKN_TL SUBT
    where SUBB.TEXT_KEY = SUBT.TEXT_KEY
    and SUBB.LANG_CODE = SUBT.LANG_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TOKEN_DESC <> SUBT.TOKEN_DESC
  ));

  insert into SY_TEXT_TKN_TL (
    TEXT_KEY,
    LANG_CODE,
    TEXT_CODE,
    TOKEN_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TEXT_KEY,
    B.LANG_CODE,
    B.TEXT_CODE,
    B.TOKEN_DESC,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from SY_TEXT_TKN_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from SY_TEXT_TKN_TL T
    where T.TEXT_KEY = B.TEXT_KEY
    and T.LANG_CODE = B.LANG_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW (
  X_TEXT_KEY in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_TOKEN_DESC in VARCHAR2,
  X_OWNER         in VARCHAR2
) IS
BEGIN

  update SY_TEXT_TKN_TL set
    TEXT_CODE = X_TEXT_CODE,
    TOKEN_DESC = X_TOKEN_DESC,
    SOURCE_LANG   = userenv('LANG'),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = decode(X_OWNER,'SEED',1,0),
    LAST_UPDATE_LOGIN = 0
  where TEXT_KEY = X_TEXT_KEY
  and LANG_CODE = X_LANG_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
end TRANSLATE_ROW;

procedure LOAD_ROW (
   X_TEXT_KEY in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_TOKEN_DESC in VARCHAR2,
  X_OWNER         in VARCHAR2
) IS
 l_text_key number(10);
 l_user_id number:=0;
 l_row_id VARCHAR2(64);
 BEGIN
    IF (X_OWNER ='SEED') THEN
        l_user_id :=1;
    END IF;

    SELECT text_key into l_text_key
    FROM   SY_TEXT_TKN_TL
    WHERE  TEXT_KEY = X_TEXT_KEY;


   GMA_SY_TEXT_TKN_PKG.UPDATE_ROW ( X_TEXT_KEY => X_TEXT_KEY,
                                    X_LANG_CODE => X_LANG_CODE,
                                    X_TEXT_CODE => X_TEXT_CODE,
                                    X_TOKEN_DESC => X_TOKEN_DESC,
                                    X_LAST_UPDATE_DATE => sysdate,
                                    X_LAST_UPDATED_BY => l_user_id,
                                    X_LAST_UPDATE_LOGIN => 0
                                   );




 EXCEPTION
    WHEN NO_DATA_FOUND THEN


  GMA_SY_TEXT_TKN_PKG.INSERT_ROW (  X_ROWID => l_row_id,
                                    X_TEXT_KEY => X_TEXT_KEY,
                                    X_LANG_CODE => X_LANG_CODE,
                                    X_TEXT_CODE => X_TEXT_CODE,
                                    X_TOKEN_DESC => X_TOKEN_DESC,
                                    X_CREATION_DATE => sysdate,
				    X_CREATED_BY => l_user_id,
                                    X_LAST_UPDATE_DATE => sysdate,
                                    X_LAST_UPDATED_BY => l_user_id,
                                    X_LAST_UPDATE_LOGIN => 0
                                   );
                    END LOAD_ROW;




end GMA_SY_TEXT_TKN_PKG;

/
