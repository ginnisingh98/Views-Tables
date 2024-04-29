--------------------------------------------------------
--  DDL for Package Body AMS_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MESSAGES_PKG" as
/* $Header: amslmsgb.pls 115.4 2002/11/15 21:01:00 abhola ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_MESSAGE_ID in NUMBER,
  X_MESSAGE_TYPE_CODE in VARCHAR2,
  X_OWNER_USER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DATE_EFFECTIVE_FROM in DATE,
  X_DATE_EFFECTIVE_TO in DATE,
  X_ACTIVE_FLAG in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_MESSAGES_B
    where MESSAGE_ID = X_MESSAGE_ID
    ;
begin
  insert into AMS_MESSAGES_B (
    MESSAGE_TYPE_CODE,
    OWNER_USER_ID,
    MESSAGE_ID,
    OBJECT_VERSION_NUMBER,
    DATE_EFFECTIVE_FROM,
    DATE_EFFECTIVE_TO,
    ACTIVE_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MESSAGE_TYPE_CODE,
    X_OWNER_USER_ID,
    X_MESSAGE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_DATE_EFFECTIVE_FROM,
    X_DATE_EFFECTIVE_TO,
    X_ACTIVE_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMS_MESSAGES_TL (
    DESCRIPTION,
    MESSAGE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    MESSAGE_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DESCRIPTION,
    X_MESSAGE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_MESSAGE_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_MESSAGES_TL T
    where T.MESSAGE_ID = X_MESSAGE_ID
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
  X_MESSAGE_ID in NUMBER,
  X_MESSAGE_TYPE_CODE in VARCHAR2,
  X_OWNER_USER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DATE_EFFECTIVE_FROM in DATE,
  X_DATE_EFFECTIVE_TO in DATE,
  X_ACTIVE_FLAG in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      MESSAGE_TYPE_CODE,
      OWNER_USER_ID,
      OBJECT_VERSION_NUMBER,
      DATE_EFFECTIVE_FROM,
      DATE_EFFECTIVE_TO,
      ACTIVE_FLAG
    from AMS_MESSAGES_B
    where MESSAGE_ID = X_MESSAGE_ID
    for update of MESSAGE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MESSAGE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_MESSAGES_TL
    where MESSAGE_ID = X_MESSAGE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of MESSAGE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.MESSAGE_TYPE_CODE = X_MESSAGE_TYPE_CODE)
           OR ((recinfo.MESSAGE_TYPE_CODE is null) AND (X_MESSAGE_TYPE_CODE is null)))
      AND ((recinfo.OWNER_USER_ID = X_OWNER_USER_ID)
           OR ((recinfo.OWNER_USER_ID is null) AND (X_OWNER_USER_ID is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.DATE_EFFECTIVE_FROM = X_DATE_EFFECTIVE_FROM)
           OR ((recinfo.DATE_EFFECTIVE_FROM is null) AND (X_DATE_EFFECTIVE_FROM is null)))
      AND ((recinfo.DATE_EFFECTIVE_TO = X_DATE_EFFECTIVE_TO)
           OR ((recinfo.DATE_EFFECTIVE_TO is null) AND (X_DATE_EFFECTIVE_TO is null)))
      AND (recinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MESSAGE_NAME = X_MESSAGE_NAME)
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
  X_MESSAGE_ID in NUMBER,
  X_MESSAGE_TYPE_CODE in VARCHAR2,
  X_OWNER_USER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DATE_EFFECTIVE_FROM in DATE,
  X_DATE_EFFECTIVE_TO in DATE,
  X_ACTIVE_FLAG in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_MESSAGES_B set
    MESSAGE_TYPE_CODE = X_MESSAGE_TYPE_CODE,
    OWNER_USER_ID = X_OWNER_USER_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    DATE_EFFECTIVE_FROM = X_DATE_EFFECTIVE_FROM,
    DATE_EFFECTIVE_TO = X_DATE_EFFECTIVE_TO,
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where MESSAGE_ID = X_MESSAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_MESSAGES_TL set
    MESSAGE_NAME = X_MESSAGE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where MESSAGE_ID = X_MESSAGE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_MESSAGE_ID in NUMBER
) is
begin
  delete from AMS_MESSAGES_TL
  where MESSAGE_ID = X_MESSAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_MESSAGES_B
  where MESSAGE_ID = X_MESSAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_MESSAGES_TL T
  where not exists
    (select NULL
    from AMS_MESSAGES_B B
    where B.MESSAGE_ID = T.MESSAGE_ID
    );

  update AMS_MESSAGES_TL T set (
      MESSAGE_NAME,
      DESCRIPTION
    ) = (select
      B.MESSAGE_NAME,
      B.DESCRIPTION
    from AMS_MESSAGES_TL B
    where B.MESSAGE_ID = T.MESSAGE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MESSAGE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MESSAGE_ID,
      SUBT.LANGUAGE
    from AMS_MESSAGES_TL SUBB, AMS_MESSAGES_TL SUBT
    where SUBB.MESSAGE_ID = SUBT.MESSAGE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MESSAGE_NAME <> SUBT.MESSAGE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_MESSAGES_TL (
    DESCRIPTION,
    MESSAGE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    MESSAGE_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DESCRIPTION,
    B.MESSAGE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.MESSAGE_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_MESSAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_MESSAGES_TL T
    where T.MESSAGE_ID = B.MESSAGE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_MESSAGE_ID in NUMBER,
  X_MESSAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
)
is
begin
    update ams_messages_tl set
       message_name = nvl(x_message_name, message_name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  message_id = x_message_id
    and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

procedure LOAD_ROW(
  X_MESSAGE_ID in NUMBER,
  X_MESSAGE_TYPE_CODE in VARCHAR2,
  X_OWNER_USER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DATE_EFFECTIVE_FROM in DATE,
  X_DATE_EFFECTIVE_TO in DATE,
  X_ACTIVE_FLAG in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
)
is

  l_user_id    number := 0;
  l_version    number;
  l_msg_id     number;
  l_dummy_char varchar2(1);
  l_row_id     varchar2(100);

  cursor c_version is
  select object_version_number
  from   ams_messages_b
  where  message_id = X_MESSAGE_ID;

  cursor c_msg_exists is
  select 'x'
  from   ams_messages_b
  where  message_id = X_MESSAGE_ID;

  cursor c_msg_id is
  select ams_messages_b_s.nextval
  from   dual;

BEGIN

  open c_msg_exists;
  fetch c_msg_exists into l_dummy_char;
  if c_msg_exists%notfound then
    close c_msg_exists;
    if X_MESSAGE_ID is null then
      open c_msg_id;
      fetch c_msg_id into l_msg_id;
      close c_msg_id;
    else
       l_msg_id := X_MESSAGE_ID;
    end if;
    l_version := 1;
    AMS_MESSAGES_PKG.INSERT_ROW(
      X_ROWID	=> l_row_id,
      X_MESSAGE_ID => l_msg_id,
      X_OBJECT_VERSION_NUMBER => l_version,
      X_MESSAGE_TYPE_CODE => X_MESSAGE_TYPE_CODE,
      X_OWNER_USER_ID => X_OWNER_USER_ID,
      X_DATE_EFFECTIVE_FROM => X_DATE_EFFECTIVE_FROM,
      X_DATE_EFFECTIVE_TO => X_DATE_EFFECTIVE_TO,
      X_ACTIVE_FLAG => X_ACTIVE_FLAG,
      X_MESSAGE_NAME => X_MESSAGE_NAME,
      X_DESCRIPTION => X_DESCRIPTION,
      X_CREATION_DATE => SYSDATE,
      X_CREATED_BY => l_user_id,
      X_LAST_UPDATE_DATE => SYSDATE,
      X_LAST_UPDATED_BY => l_user_id,
      X_LAST_UPDATE_LOGIN	=> 0
    );
  else
    close c_msg_exists;
    open c_version;
    fetch c_version into l_version;
    close c_version;
    AMS_MESSAGES_PKG.UPDATE_ROW(
      X_MESSAGE_ID => X_MESSAGE_ID,
      X_OBJECT_VERSION_NUMBER => l_version + 1,
      X_MESSAGE_TYPE_CODE => X_MESSAGE_TYPE_CODE,
      X_OWNER_USER_ID => X_OWNER_USER_ID,
      X_DATE_EFFECTIVE_FROM => X_DATE_EFFECTIVE_FROM,
      X_DATE_EFFECTIVE_TO => X_DATE_EFFECTIVE_TO,
      X_ACTIVE_FLAG => X_ACTIVE_FLAG,
      X_MESSAGE_NAME => X_MESSAGE_NAME,
      X_DESCRIPTION => X_DESCRIPTION,
      X_LAST_UPDATE_DATE => SYSDATE,
      X_LAST_UPDATED_BY => l_user_id,
      X_LAST_UPDATE_LOGIN	=> 0
    );
  end if;
END LOAD_ROW;

end AMS_MESSAGES_PKG;

/
