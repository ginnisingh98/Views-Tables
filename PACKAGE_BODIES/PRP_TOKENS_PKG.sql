--------------------------------------------------------
--  DDL for Package Body PRP_TOKENS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRP_TOKENS_PKG" as
/* $Header: PRPTTKNB.pls 120.1 2005/10/21 17:39:17 hekkiral noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TOKEN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TOKEN_CODE in VARCHAR2,
  X_TOKEN_TYPE in VARCHAR2,
  X_NATIVE_OBJECT_TYPE in VARCHAR2,
  X_USER_DEFINED_OPTIONS in VARCHAR2,
  X_JAVA_PROGRAM_NAME in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_DISPLAY_LENGTH in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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
  X_TOKEN_NAME in VARCHAR2,
  X_TOKEN_PROMPT in VARCHAR2,
  X_TOKEN_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PRP_TOKENS_B
    where TOKEN_ID = X_TOKEN_ID
    ;
begin
  insert into PRP_TOKENS_B (
    ATTRIBUTE15,
    TOKEN_ID,
    OBJECT_VERSION_NUMBER,
    TOKEN_CODE,
    TOKEN_TYPE,
    NATIVE_OBJECT_TYPE,
    USER_DEFINED_OPTIONS,
    JAVA_PROGRAM_NAME,
    DATA_TYPE,
    DISPLAY_LENGTH,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTRIBUTE15,
    X_TOKEN_ID,
    X_OBJECT_VERSION_NUMBER,
    X_TOKEN_CODE,
    X_TOKEN_TYPE,
    X_NATIVE_OBJECT_TYPE,
    X_USER_DEFINED_OPTIONS,
    X_JAVA_PROGRAM_NAME,
    X_DATA_TYPE,
    X_DISPLAY_LENGTH,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
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
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PRP_TOKENS_TL (
    TOKEN_NAME,
    TOKEN_PROMPT,
    TOKEN_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    TOKEN_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TOKEN_NAME,
    X_TOKEN_PROMPT,
    X_TOKEN_DESC,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_TOKEN_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PRP_TOKENS_TL T
    where T.TOKEN_ID = X_TOKEN_ID
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
  X_TOKEN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TOKEN_CODE in VARCHAR2,
  X_TOKEN_TYPE in VARCHAR2,
  X_NATIVE_OBJECT_TYPE in VARCHAR2,
  X_USER_DEFINED_OPTIONS in VARCHAR2,
  X_JAVA_PROGRAM_NAME in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_DISPLAY_LENGTH in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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
  X_TOKEN_NAME in VARCHAR2,
  X_TOKEN_PROMPT in VARCHAR2,
  X_TOKEN_DESC in VARCHAR2
) is
  cursor c is select
      ATTRIBUTE15,
      OBJECT_VERSION_NUMBER,
      TOKEN_CODE,
      TOKEN_TYPE,
      NATIVE_OBJECT_TYPE,
      USER_DEFINED_OPTIONS,
      JAVA_PROGRAM_NAME,
      DATA_TYPE,
      DISPLAY_LENGTH,
      ATTRIBUTE_CATEGORY,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
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
      ATTRIBUTE14
    from PRP_TOKENS_B
    where TOKEN_ID = X_TOKEN_ID
    for update of TOKEN_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TOKEN_NAME,
      TOKEN_PROMPT,
      TOKEN_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PRP_TOKENS_TL
    where TOKEN_ID = X_TOKEN_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TOKEN_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.TOKEN_CODE = X_TOKEN_CODE)
      AND (recinfo.TOKEN_TYPE = X_TOKEN_TYPE)
      AND ((recinfo.NATIVE_OBJECT_TYPE = X_NATIVE_OBJECT_TYPE)
           OR ((recinfo.NATIVE_OBJECT_TYPE is null) AND (X_NATIVE_OBJECT_TYPE is null)))
      AND ((recinfo.USER_DEFINED_OPTIONS = X_USER_DEFINED_OPTIONS)
           OR ((recinfo.USER_DEFINED_OPTIONS is null) AND (X_USER_DEFINED_OPTIONS is null)))
      AND ((recinfo.JAVA_PROGRAM_NAME = X_JAVA_PROGRAM_NAME)
           OR ((recinfo.JAVA_PROGRAM_NAME is null) AND (X_JAVA_PROGRAM_NAME is null)))
      AND ((recinfo.DATA_TYPE = X_DATA_TYPE)
           OR ((recinfo.DATA_TYPE is null) AND (X_DATA_TYPE is null)))
      AND ((recinfo.DISPLAY_LENGTH = X_DISPLAY_LENGTH)
           OR ((recinfo.DISPLAY_LENGTH is null) AND (X_DISPLAY_LENGTH is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
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
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TOKEN_NAME = X_TOKEN_NAME)
          AND (tlinfo.TOKEN_PROMPT = X_TOKEN_PROMPT)
          AND ((tlinfo.TOKEN_DESC = X_TOKEN_DESC)
               OR ((tlinfo.TOKEN_DESC is null) AND (X_TOKEN_DESC is null)))
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
  X_TOKEN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TOKEN_CODE in VARCHAR2,
  X_TOKEN_TYPE in VARCHAR2,
  X_NATIVE_OBJECT_TYPE in VARCHAR2,
  X_USER_DEFINED_OPTIONS in VARCHAR2,
  X_JAVA_PROGRAM_NAME in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_DISPLAY_LENGTH in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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
  X_TOKEN_NAME in VARCHAR2,
  X_TOKEN_PROMPT in VARCHAR2,
  X_TOKEN_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PRP_TOKENS_B set
    ATTRIBUTE15 = X_ATTRIBUTE15,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    TOKEN_CODE = X_TOKEN_CODE,
    TOKEN_TYPE = X_TOKEN_TYPE,
    NATIVE_OBJECT_TYPE = X_NATIVE_OBJECT_TYPE,
    USER_DEFINED_OPTIONS = X_USER_DEFINED_OPTIONS,
    JAVA_PROGRAM_NAME = X_JAVA_PROGRAM_NAME,
    DATA_TYPE = X_DATA_TYPE,
    DISPLAY_LENGTH = X_DISPLAY_LENGTH,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
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
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TOKEN_ID = X_TOKEN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PRP_TOKENS_TL set
    TOKEN_NAME = X_TOKEN_NAME,
    TOKEN_PROMPT = X_TOKEN_PROMPT,
    TOKEN_DESC = X_TOKEN_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TOKEN_ID = X_TOKEN_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TOKEN_ID in NUMBER
) is
begin
  delete from PRP_TOKENS_TL
  where TOKEN_ID = X_TOKEN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PRP_TOKENS_B
  where TOKEN_ID = X_TOKEN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PRP_TOKENS_TL T
  where not exists
    (select NULL
    from PRP_TOKENS_B B
    where B.TOKEN_ID = T.TOKEN_ID
    );

  update PRP_TOKENS_TL T set (
      TOKEN_NAME,
      TOKEN_PROMPT,
      TOKEN_DESC
    ) = (select
      B.TOKEN_NAME,
      B.TOKEN_PROMPT,
      B.TOKEN_DESC
    from PRP_TOKENS_TL B
    where B.TOKEN_ID = T.TOKEN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TOKEN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TOKEN_ID,
      SUBT.LANGUAGE
    from PRP_TOKENS_TL SUBB, PRP_TOKENS_TL SUBT
    where SUBB.TOKEN_ID = SUBT.TOKEN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TOKEN_NAME <> SUBT.TOKEN_NAME
      or SUBB.TOKEN_PROMPT <> SUBT.TOKEN_PROMPT
      or SUBB.TOKEN_DESC <> SUBT.TOKEN_DESC
      or (SUBB.TOKEN_DESC is null and SUBT.TOKEN_DESC is not null)
      or (SUBB.TOKEN_DESC is not null and SUBT.TOKEN_DESC is null)
  ));

  insert into PRP_TOKENS_TL (
    TOKEN_NAME,
    TOKEN_PROMPT,
    TOKEN_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    TOKEN_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TOKEN_NAME,
    B.TOKEN_PROMPT,
    B.TOKEN_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.TOKEN_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PRP_TOKENS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PRP_TOKENS_TL T
    where T.TOKEN_ID = B.TOKEN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--
-- Should be called only from lct file
--+
procedure LOAD_ROW
  (
  p_owner                 IN VARCHAR2,
  p_token_id              IN NUMBER,
  p_object_version_number IN NUMBER,
  p_token_code            IN VARCHAR2,
  p_token_type            IN VARCHAR2,
  p_native_object_type    IN VARCHAR2,
  p_user_defined_options  IN VARCHAR2,
  p_java_program_name     IN VARCHAR2,
  p_data_type             IN VARCHAR2,
  p_display_length        IN NUMBER,
  p_start_date_active	 IN DATE,
  p_end_date_active       IN DATE,
  p_attribute_category    IN VARCHAR2,
  p_attribute1            IN VARCHAR2,
  p_attribute2            IN VARCHAR2,
  p_attribute3            IN VARCHAR2,
  p_attribute4            IN VARCHAR2,
  p_attribute5            IN VARCHAR2,
  p_attribute6            IN VARCHAR2,
  p_attribute7            IN VARCHAR2,
  p_attribute8            IN VARCHAR2,
  p_attribute9            IN VARCHAR2,
  p_attribute10           IN VARCHAR2,
  p_attribute11           IN VARCHAR2,
  p_attribute12           IN VARCHAR2,
  p_attribute13           IN VARCHAR2,
  p_attribute14           IN VARCHAR2,
  p_attribute15           IN VARCHAR2,
  p_token_name            IN VARCHAR2,
  p_token_prompt          IN VARCHAR2,
  p_token_desc            IN VARCHAR2
  )
is
  l_user_id                        NUMBER := 0;
  l_login_id                       NUMBER := 0;
  l_rowid                          VARCHAR2(256);
begin

    l_user_id := fnd_load_util.owner_id(p_owner);

  BEGIN

    update_row
      (
      X_TOKEN_ID               => p_token_id,
      X_OBJECT_VERSION_NUMBER  => p_object_version_number,
      X_TOKEN_CODE             => p_token_code,
      X_TOKEN_TYPE             => p_token_type,
      X_NATIVE_OBJECT_TYPE     => p_native_object_type,
      X_USER_DEFINED_OPTIONS   => p_user_defined_options,
      X_JAVA_PROGRAM_NAME      => p_java_program_name,
      X_DATA_TYPE              => p_data_type,
      X_DISPLAY_LENGTH         => p_display_length,
	 X_START_DATE_ACTIVE	 => p_start_date_active,
	 X_END_DATE_ACTIVE		 => p_end_date_active,
      X_ATTRIBUTE_CATEGORY     => p_attribute_category,
      X_ATTRIBUTE1             => p_attribute1,
      X_ATTRIBUTE2             => p_attribute2,
      X_ATTRIBUTE3             => p_attribute3,
      X_ATTRIBUTE4             => p_attribute4,
      X_ATTRIBUTE5             => p_attribute5,
      X_ATTRIBUTE6             => p_attribute6,
      X_ATTRIBUTE7             => p_attribute7,
      X_ATTRIBUTE8             => p_attribute8,
      X_ATTRIBUTE9             => p_attribute9,
      X_ATTRIBUTE10            => p_attribute10,
      X_ATTRIBUTE11            => p_attribute11,
      X_ATTRIBUTE12            => p_attribute12,
      X_ATTRIBUTE13            => p_attribute13,
      X_ATTRIBUTE14            => p_attribute14,
      X_ATTRIBUTE15            => p_attribute15,
      X_TOKEN_NAME             => p_token_name,
      X_TOKEN_PROMPT           => p_token_prompt,
      X_TOKEN_DESC             => p_token_desc,
      X_LAST_UPDATE_DATE       => sysdate,
      X_LAST_UPDATED_BY        => l_user_id,
      X_LAST_UPDATE_LOGIN      => l_login_id
      );

  EXCEPTION

     WHEN NO_DATA_FOUND THEN

       insert_row
       (
       X_ROWID                 => l_rowid,
       X_TOKEN_ID              => p_token_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_TOKEN_CODE            => p_token_code,
       X_TOKEN_TYPE            => p_token_type,
       X_NATIVE_OBJECT_TYPE    => p_native_object_type,
       X_USER_DEFINED_OPTIONS  => p_user_defined_options,
       X_JAVA_PROGRAM_NAME     => p_java_program_name,
       X_DATA_TYPE             => p_data_type,
       X_DISPLAY_LENGTH        => p_display_length,
	  X_START_DATE_ACTIVE	 => p_start_date_active,
	  X_END_DATE_ACTIVE		 => p_end_date_active,
       X_ATTRIBUTE_CATEGORY    => p_attribute_category,
       X_ATTRIBUTE1            => p_attribute1,
       X_ATTRIBUTE2            => p_attribute1,
       X_ATTRIBUTE3            => p_attribute1,
       X_ATTRIBUTE4            => p_attribute1,
       X_ATTRIBUTE5            => p_attribute1,
       X_ATTRIBUTE6            => p_attribute1,
       X_ATTRIBUTE7            => p_attribute1,
       X_ATTRIBUTE8            => p_attribute1,
       X_ATTRIBUTE9            => p_attribute1,
       X_ATTRIBUTE10           => p_attribute1,
       X_ATTRIBUTE11           => p_attribute1,
       X_ATTRIBUTE12           => p_attribute1,
       X_ATTRIBUTE13           => p_attribute1,
       X_ATTRIBUTE14           => p_attribute1,
       X_ATTRIBUTE15           => p_attribute1,
       X_TOKEN_NAME            => p_token_name,
       X_TOKEN_PROMPT          => p_token_prompt,
       X_TOKEN_DESC            => p_token_desc,
       X_CREATION_DATE         => sysdate,
       X_CREATED_BY            => l_user_id,
       X_LAST_UPDATE_DATE      => sysdate,
       X_LAST_UPDATED_BY       => l_user_id,
       X_LAST_UPDATE_LOGIN     => l_login_id
       );

  END;

end LOAD_ROW;

procedure TRANSLATE_ROW
  (
   p_owner                              IN VARCHAR2,
   p_token_id                           IN NUMBER,
   p_token_name                         IN VARCHAR2,
   p_token_prompt                       IN VARCHAR2,
   p_token_desc                         IN VARCHAR2
  )
IS
  l_login_id                       NUMBER := 0;
BEGIN

  UPDATE prp_tokens_tl
    SET token_name = p_token_name,
    token_prompt = p_token_prompt,
    token_desc = p_token_desc,
    last_update_date = sysdate,
    last_updated_by = decode(p_owner, 'SEED', 1, 0),
    last_update_login = l_login_id,
    source_lang = userenv('LANG')
    WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
    token_id = p_token_id;

end TRANSLATE_ROW;

end PRP_TOKENS_PKG;

/
