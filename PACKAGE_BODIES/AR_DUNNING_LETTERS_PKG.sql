--------------------------------------------------------
--  DDL for Package Body AR_DUNNING_LETTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_DUNNING_LETTERS_PKG" as
/* $Header: ARPADLSB.pls 120.2.12000000.2 2007/05/16 11:38:09 tthangav ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DUNNING_LETTER_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_REVIEW_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_LETTER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_DUNNING_LETTERS_B
    where DUNNING_LETTER_ID = X_DUNNING_LETTER_ID
    ;
begin
  insert into AR_DUNNING_LETTERS_B (
    DUNNING_LETTER_ID,
    STATUS,
    REVIEW_DATE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DUNNING_LETTER_ID,
    X_STATUS,
    X_REVIEW_DATE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AR_DUNNING_LETTERS_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DUNNING_LETTER_ID,
    DESCRIPTION,
    LETTER_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DUNNING_LETTER_ID,
    X_DESCRIPTION,
    X_LETTER_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AR_DUNNING_LETTERS_TL T
    where T.DUNNING_LETTER_ID = X_DUNNING_LETTER_ID
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
  X_STATUS in VARCHAR2,
  X_REVIEW_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_LETTER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      STATUS,
      REVIEW_DATE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    from AR_DUNNING_LETTERS_B
    where DUNNING_LETTER_ID = X_DUNNING_LETTER_ID
    for update of DUNNING_LETTER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LETTER_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AR_DUNNING_LETTERS_TL
    where DUNNING_LETTER_ID = X_DUNNING_LETTER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DUNNING_LETTER_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.STATUS = X_STATUS)
      AND ((recinfo.REVIEW_DATE = X_REVIEW_DATE)
           OR ((recinfo.REVIEW_DATE is null) AND (X_REVIEW_DATE is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.LETTER_NAME = X_LETTER_NAME)
               OR ((tlinfo.LETTER_NAME is null) AND (X_LETTER_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_STATUS in VARCHAR2,
  X_REVIEW_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_LETTER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_DUNNING_LETTERS_B set
    STATUS = X_STATUS,
    REVIEW_DATE = X_REVIEW_DATE,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DUNNING_LETTER_ID = X_DUNNING_LETTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AR_DUNNING_LETTERS_TL set
    LETTER_NAME = X_LETTER_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DUNNING_LETTER_ID = X_DUNNING_LETTER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DUNNING_LETTER_ID in NUMBER
) is
begin
  delete from AR_DUNNING_LETTERS_TL
  where DUNNING_LETTER_ID = X_DUNNING_LETTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AR_DUNNING_LETTERS_B
  where DUNNING_LETTER_ID = X_DUNNING_LETTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AR_DUNNING_LETTERS_TL T
  where not exists
    (select NULL
    from AR_DUNNING_LETTERS_B B
    where B.DUNNING_LETTER_ID = T.DUNNING_LETTER_ID
    );

  update AR_DUNNING_LETTERS_TL T set (
      LETTER_NAME,
      DESCRIPTION
    ) = (select
      B.LETTER_NAME,
      B.DESCRIPTION
    from AR_DUNNING_LETTERS_TL B
    where B.DUNNING_LETTER_ID = T.DUNNING_LETTER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DUNNING_LETTER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DUNNING_LETTER_ID,
      SUBT.LANGUAGE
    from AR_DUNNING_LETTERS_TL SUBB, AR_DUNNING_LETTERS_TL SUBT
    where SUBB.DUNNING_LETTER_ID = SUBT.DUNNING_LETTER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LETTER_NAME <> SUBT.LETTER_NAME
      or (SUBB.LETTER_NAME is null and SUBT.LETTER_NAME is not null)
      or (SUBB.LETTER_NAME is not null and SUBT.LETTER_NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AR_DUNNING_LETTERS_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DUNNING_LETTER_ID,
    DESCRIPTION,
    LETTER_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DUNNING_LETTER_ID,
    B.DESCRIPTION,
    B.LETTER_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AR_DUNNING_LETTERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AR_DUNNING_LETTERS_TL T
    where T.DUNNING_LETTER_ID = B.DUNNING_LETTER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_DUNNING_LETTER_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_REVIEW_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_LETTER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
BEGIN

  declare
     user_id            number := 0;
     row_id             varchar2(64);

  begin

      user_id := fnd_load_util.owner_id(X_OWNER);

     AR_DUNNING_LETTERS_PKG.UPDATE_ROW (
  	X_DUNNING_LETTER_ID => X_DUNNING_LETTER_ID,
  	X_STATUS => X_STATUS,
  	X_REVIEW_DATE => X_REVIEW_DATE,
  	X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
  	X_ATTRIBUTE1 => X_ATTRIBUTE1,
  	X_ATTRIBUTE2 => X_ATTRIBUTE2,
  	X_ATTRIBUTE3 => X_ATTRIBUTE3,
  	X_ATTRIBUTE4 => X_ATTRIBUTE4,
  	X_ATTRIBUTE5 => X_ATTRIBUTE5,
  	X_ATTRIBUTE6 => X_ATTRIBUTE6,
  	X_ATTRIBUTE7 => X_ATTRIBUTE7,
  	X_ATTRIBUTE8 => X_ATTRIBUTE8,
  	X_ATTRIBUTE9 => X_ATTRIBUTE9,
  	X_ATTRIBUTE10 => X_ATTRIBUTE10,
  	X_ATTRIBUTE11 => X_ATTRIBUTE11,
  	X_ATTRIBUTE12 => X_ATTRIBUTE12,
  	X_ATTRIBUTE13 => X_ATTRIBUTE13,
  	X_ATTRIBUTE14 => X_ATTRIBUTE14,
  	X_ATTRIBUTE15 => X_ATTRIBUTE15,
  	X_LETTER_NAME => X_LETTER_NAME,
  	X_DESCRIPTION => X_DESCRIPTION,
  	X_LAST_UPDATE_DATE => sysdate,
  	X_LAST_UPDATED_BY => user_id,
  	X_LAST_UPDATE_LOGIN => 0);

    exception
       when NO_DATA_FOUND then

          AR_DUNNING_LETTERS_PKG.INSERT_ROW(
  	   X_ROWID => row_id,
  	   X_DUNNING_LETTER_ID => X_DUNNING_LETTER_ID,
  	   X_STATUS => X_STATUS,
  	   X_REVIEW_DATE => X_REVIEW_DATE,
  	   X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
  	   X_ATTRIBUTE1 => X_ATTRIBUTE1,
  	   X_ATTRIBUTE2 => X_ATTRIBUTE2,
  	   X_ATTRIBUTE3 => X_ATTRIBUTE3,
  	   X_ATTRIBUTE4 => X_ATTRIBUTE4,
  	   X_ATTRIBUTE5 => X_ATTRIBUTE5,
  	   X_ATTRIBUTE6 => X_ATTRIBUTE6,
  	   X_ATTRIBUTE7 => X_ATTRIBUTE7,
  	   X_ATTRIBUTE8 => X_ATTRIBUTE8,
  	   X_ATTRIBUTE9 => X_ATTRIBUTE9,
  	   X_ATTRIBUTE10 => X_ATTRIBUTE10,
  	   X_ATTRIBUTE11 => X_ATTRIBUTE11,
  	   X_ATTRIBUTE12 => X_ATTRIBUTE12,
  	   X_ATTRIBUTE13 => X_ATTRIBUTE13,
  	   X_ATTRIBUTE14 => X_ATTRIBUTE14,
  	   X_ATTRIBUTE15 => X_ATTRIBUTE15,
  	   X_LETTER_NAME => X_LETTER_NAME,
  	   X_DESCRIPTION => X_DESCRIPTION,
           X_CREATION_DATE => sysdate,
           X_CREATED_BY => user_id,
           X_LAST_UPDATE_DATE => sysdate,
           X_LAST_UPDATED_BY => user_id,
           X_LAST_UPDATE_LOGIN => 0 );

    end;

END LOAD_ROW;

procedure TRANSLATE_ROW (
  X_DUNNING_LETTER_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LETTER_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is
BEGIN

    -- only update rows that have not been altered by user

    update AR_DUNNING_LETTERS_TL set
      letter_name = X_LETTER_NAME,
      description = X_DESCRIPTION,
      source_lang = userenv('LANG'),
      last_update_date = sysdate,
      last_updated_by = fnd_load_util.owner_id(X_OWNER),
      last_update_login = 0
    where dunning_letter_id = X_DUNNING_LETTER_ID
    and   userenv('LANG') in (language, source_lang);

END TRANSLATE_ROW;

end AR_DUNNING_LETTERS_PKG;

/
