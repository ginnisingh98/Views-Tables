--------------------------------------------------------
--  DDL for Package Body AR_DUNNING_LETTERS_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_DUNNING_LETTERS_CUSTOM_PKG" as
/* $Header: ARPDLCSB.pls 120.2.12000000.2 2007/05/16 11:37:36 tthangav ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DUNNING_LETTER_ID in NUMBER,
  X_PARAGRAPH_NUMBER in NUMBER,
  X_PARAGRAPH_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_DUNNING_LETTERS_CUSTOM_TL
    where DUNNING_LETTER_ID = X_DUNNING_LETTER_ID
    and PARAGRAPH_NUMBER = X_PARAGRAPH_NUMBER
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into AR_DUNNING_LETTERS_CUSTOM_TL (
    DUNNING_LETTER_ID,
    PARAGRAPH_NUMBER,
    PARAGRAPH_TEXT,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DUNNING_LETTER_ID,
    X_PARAGRAPH_NUMBER,
    X_PARAGRAPH_TEXT,
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AR_DUNNING_LETTERS_CUSTOM_TL T
    where T.DUNNING_LETTER_ID = X_DUNNING_LETTER_ID
    and T.PARAGRAPH_NUMBER = X_PARAGRAPH_NUMBER
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
  X_DUNNING_LETTER_ID in NUMBER,
  X_PARAGRAPH_NUMBER in NUMBER,
  X_PARAGRAPH_TEXT in VARCHAR2
) is
  cursor c1 is select
      PARAGRAPH_TEXT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AR_DUNNING_LETTERS_CUSTOM_TL
    where DUNNING_LETTER_ID = X_DUNNING_LETTER_ID
    and PARAGRAPH_NUMBER = X_PARAGRAPH_NUMBER
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DUNNING_LETTER_ID nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.PARAGRAPH_TEXT = X_PARAGRAPH_TEXT)
               OR ((tlinfo.PARAGRAPH_TEXT is null) AND (X_PARAGRAPH_TEXT is null)))
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
  X_DUNNING_LETTER_ID in NUMBER,
  X_PARAGRAPH_NUMBER in NUMBER,
  X_PARAGRAPH_TEXT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_DUNNING_LETTERS_CUSTOM_TL set
    PARAGRAPH_TEXT = X_PARAGRAPH_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DUNNING_LETTER_ID = X_DUNNING_LETTER_ID
  and PARAGRAPH_NUMBER = X_PARAGRAPH_NUMBER
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DUNNING_LETTER_ID in NUMBER,
  X_PARAGRAPH_NUMBER in NUMBER
) is
begin
  delete from AR_DUNNING_LETTERS_CUSTOM_TL
  where DUNNING_LETTER_ID = X_DUNNING_LETTER_ID
  and PARAGRAPH_NUMBER = X_PARAGRAPH_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update AR_DUNNING_LETTERS_CUSTOM_TL T set (
      PARAGRAPH_TEXT
    ) = (select
      B.PARAGRAPH_TEXT
    from AR_DUNNING_LETTERS_CUSTOM_TL B
    where B.DUNNING_LETTER_ID = T.DUNNING_LETTER_ID
    and B.PARAGRAPH_NUMBER = T.PARAGRAPH_NUMBER
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DUNNING_LETTER_ID,
      T.PARAGRAPH_NUMBER,
      T.LANGUAGE
  ) in (select
      SUBT.DUNNING_LETTER_ID,
      SUBT.PARAGRAPH_NUMBER,
      SUBT.LANGUAGE
    from AR_DUNNING_LETTERS_CUSTOM_TL SUBB, AR_DUNNING_LETTERS_CUSTOM_TL SUBT
    where SUBB.DUNNING_LETTER_ID = SUBT.DUNNING_LETTER_ID
    and SUBB.PARAGRAPH_NUMBER = SUBT.PARAGRAPH_NUMBER
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PARAGRAPH_TEXT <> SUBT.PARAGRAPH_TEXT
      or (SUBB.PARAGRAPH_TEXT is null and SUBT.PARAGRAPH_TEXT is not null)
      or (SUBB.PARAGRAPH_TEXT is not null and SUBT.PARAGRAPH_TEXT is null)
  ));

  insert into AR_DUNNING_LETTERS_CUSTOM_TL (
    DUNNING_LETTER_ID,
    PARAGRAPH_NUMBER,
    PARAGRAPH_TEXT,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DUNNING_LETTER_ID,
    B.PARAGRAPH_NUMBER,
    B.PARAGRAPH_TEXT,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AR_DUNNING_LETTERS_CUSTOM_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AR_DUNNING_LETTERS_CUSTOM_TL T
    where T.DUNNING_LETTER_ID = B.DUNNING_LETTER_ID
    and T.PARAGRAPH_NUMBER = B.PARAGRAPH_NUMBER
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_DUNNING_LETTER_ID in NUMBER,
  X_PARAGRAPH_NUMBER in NUMBER,
  X_PARAGRAPH_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);

  begin

      user_id := fnd_load_util.owner_id(X_OWNER);

     AR_DUNNING_LETTERS_CUSTOM_PKG.UPDATE_ROW (
        X_DUNNING_LETTER_ID => X_DUNNING_LETTER_ID,
        X_PARAGRAPH_NUMBER => X_PARAGRAPH_NUMBER,
        X_PARAGRAPH_TEXT => X_PARAGRAPH_TEXT,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN => 0);

    exception
       when NO_DATA_FOUND then
          AR_DUNNING_LETTERS_CUSTOM_PKG.INSERT_ROW (
             X_ROWID => row_id,
             X_DUNNING_LETTER_ID => X_DUNNING_LETTER_ID,
             X_PARAGRAPH_NUMBER => X_PARAGRAPH_NUMBER,
             X_PARAGRAPH_TEXT => X_PARAGRAPH_TEXT,
             X_CREATION_DATE => sysdate,
             X_CREATED_BY => user_id,
             X_LAST_UPDATE_DATE => sysdate,
             X_LAST_UPDATED_BY => user_id,
             X_LAST_UPDATE_LOGIN => 0);
   end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
   X_DUNNING_LETTER_ID in NUMBER,
   X_PARAGRAPH_NUMBER in NUMBER,
   X_PARAGRAPH_TEXT in VARCHAR2,
   X_OWNER in VARCHAR2) IS

begin

    -- only update rows that have not been altered by user

    update AR_DUNNING_LETTERS_CUSTOM_TL
    set paragraph_text = X_PARAGRAPH_TEXT,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        last_updated_by = fnd_load_util.owner_id(X_OWNER),
        last_update_login = 0
    where dunning_letter_id = X_DUNNING_LETTER_ID
    and   paragraph_number = X_PARAGRAPH_NUMBER
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

end AR_DUNNING_LETTERS_CUSTOM_PKG;

/
