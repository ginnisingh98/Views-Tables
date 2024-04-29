--------------------------------------------------------
--  DDL for Package Body AR_STANDARD_TEXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_STANDARD_TEXT_PKG" as
/* $Header: ARPASTSB.pls 115.6 2002/11/15 02:37:23 anukumar ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STANDARD_TEXT_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_NAME in VARCHAR2,
  X_TEXT_TYPE in VARCHAR2,
  X_TEXT_USE_TYPE in VARCHAR2,
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
  X_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_STANDARD_TEXT_B
    where STANDARD_TEXT_ID = X_STANDARD_TEXT_ID
    ;
begin
  insert into AR_STANDARD_TEXT_B (
    STANDARD_TEXT_ID,
    START_DATE,
    END_DATE,
    NAME,
    TEXT_TYPE,
    TEXT_USE_TYPE,
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
    X_STANDARD_TEXT_ID,
    X_START_DATE,
    X_END_DATE,
    X_NAME,
    X_TEXT_TYPE,
    X_TEXT_USE_TYPE,
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

  insert into AR_STANDARD_TEXT_TL (
    STANDARD_TEXT_ID,
    TEXT,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_STANDARD_TEXT_ID,
    X_TEXT,
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
    from AR_STANDARD_TEXT_TL T
    where T.STANDARD_TEXT_ID = X_STANDARD_TEXT_ID
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
  X_STANDARD_TEXT_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_NAME in VARCHAR2,
  X_TEXT_TYPE in VARCHAR2,
  X_TEXT_USE_TYPE in VARCHAR2,
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
  X_TEXT in VARCHAR2
) is
  cursor c is select
      START_DATE,
      END_DATE,
      NAME,
      TEXT_TYPE,
      TEXT_USE_TYPE,
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
    from AR_STANDARD_TEXT_B
    where STANDARD_TEXT_ID = X_STANDARD_TEXT_ID
    for update of STANDARD_TEXT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TEXT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AR_STANDARD_TEXT_TL
    where STANDARD_TEXT_ID = X_STANDARD_TEXT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STANDARD_TEXT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.START_DATE = X_START_DATE)
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND (recinfo.NAME = X_NAME)
      AND ((recinfo.TEXT_TYPE = X_TEXT_TYPE)
           OR ((recinfo.TEXT_TYPE is null) AND (X_TEXT_TYPE is null)))
      AND ((recinfo.TEXT_USE_TYPE = X_TEXT_USE_TYPE)
           OR ((recinfo.TEXT_USE_TYPE is null) AND (X_TEXT_USE_TYPE is null)))
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
      if (    ((tlinfo.TEXT = X_TEXT)
               OR ((tlinfo.TEXT is null) AND (X_TEXT is null)))
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
  X_STANDARD_TEXT_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_NAME in VARCHAR2,
  X_TEXT_TYPE in VARCHAR2,
  X_TEXT_USE_TYPE in VARCHAR2,
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
  X_TEXT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_STANDARD_TEXT_B set
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    NAME = X_NAME,
    TEXT_TYPE = X_TEXT_TYPE,
    TEXT_USE_TYPE = X_TEXT_USE_TYPE,
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
  where STANDARD_TEXT_ID = X_STANDARD_TEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AR_STANDARD_TEXT_TL set
    TEXT = X_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STANDARD_TEXT_ID = X_STANDARD_TEXT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STANDARD_TEXT_ID in NUMBER
) is
begin
  delete from AR_STANDARD_TEXT_TL
  where STANDARD_TEXT_ID = X_STANDARD_TEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AR_STANDARD_TEXT_B
  where STANDARD_TEXT_ID = X_STANDARD_TEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AR_STANDARD_TEXT_TL T
  where not exists
    (select NULL
    from AR_STANDARD_TEXT_B B
    where B.STANDARD_TEXT_ID = T.STANDARD_TEXT_ID
    );

  update AR_STANDARD_TEXT_TL T set (
      TEXT
    ) = (select
      B.TEXT
    from AR_STANDARD_TEXT_TL B
    where B.STANDARD_TEXT_ID = T.STANDARD_TEXT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STANDARD_TEXT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STANDARD_TEXT_ID,
      SUBT.LANGUAGE
    from AR_STANDARD_TEXT_TL SUBB, AR_STANDARD_TEXT_TL SUBT
    where SUBB.STANDARD_TEXT_ID = SUBT.STANDARD_TEXT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEXT <> SUBT.TEXT
      or (SUBB.TEXT is null and SUBT.TEXT is not null)
      or (SUBB.TEXT is not null and SUBT.TEXT is null)
  ));

  insert into AR_STANDARD_TEXT_TL (
    STANDARD_TEXT_ID,
    TEXT,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.STANDARD_TEXT_ID,
    B.TEXT,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AR_STANDARD_TEXT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AR_STANDARD_TEXT_TL T
    where T.STANDARD_TEXT_ID = B.STANDARD_TEXT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
     X_STANDARD_TEXT_ID in NUMBER,
     X_START_DATE in DATE,
     X_END_DATE in DATE,
     X_NAME in VARCHAR2,
     X_TEXT_TYPE in VARCHAR2,
     X_TEXT_USE_TYPE in VARCHAR2,
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
     X_TEXT in VARCHAR2,
     X_OWNER in VARCHAR2) IS
begin
  declare
     user_id            number := 0;
     row_id             varchar2(64);
     nmemo_line_id      number;

  begin

     if (X_OWNER = 'SEED') then
        user_id := -1;
     end if;

     begin
     AR_STANDARD_TEXT_PKG.UPDATE_ROW(
        X_STANDARD_TEXT_ID => X_STANDARD_TEXT_ID,
        X_START_DATE => X_START_DATE,
        X_END_DATE => X_END_DATE,
        X_NAME => X_NAME,
        X_TEXT_TYPE => X_TEXT_TYPE,
        X_TEXT_USE_TYPE => X_TEXT_USE_TYPE,
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
        X_TEXT => X_TEXT,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN => 0 );

      exception
       when NO_DATA_FOUND then
            AR_STANDARD_TEXT_PKG.INSERT_ROW (
                  X_ROWID => row_id,
                  X_STANDARD_TEXT_ID => X_STANDARD_TEXT_ID,
                  X_START_DATE => X_START_DATE,
                  X_END_DATE => X_END_DATE,
                  X_NAME => X_NAME,
                  X_TEXT_TYPE => X_TEXT_TYPE,
                  X_TEXT_USE_TYPE => X_TEXT_USE_TYPE,
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
                  X_TEXT => X_TEXT,
                  X_CREATION_DATE => sysdate,
                  X_CREATED_BY => user_id,
                  X_LAST_UPDATE_DATE => sysdate,
                  X_LAST_UPDATED_BY => user_id,
                  X_LAST_UPDATE_LOGIN => 0);
       end;
     end;

end LOAD_ROW;

procedure TRANSLATE_ROW (
     X_STANDARD_TEXT_ID in NUMBER,
     X_TEXT in VARCHAR2 ,
     X_OWNER in VARCHAR2 ) IS
begin

    -- only update rows that have not been altered by user

    update AR_STANDARD_TEXT_TL
    set text = X_TEXT,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        last_updated_by = decode(X_OWNER, 'SEED', -1, 0),
        last_update_login = 0
    where standard_text_id = X_STANDARD_TEXT_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

end AR_STANDARD_TEXT_PKG;

/
