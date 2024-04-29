--------------------------------------------------------
--  DDL for Package Body AMS_CHANNELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CHANNELS_PKG" AS
/* $Header: amslchab.pls 115.4 2002/11/16 01:44:21 dbiswas ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_CHANNEL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHANNEL_TYPE_CODE in VARCHAR2,
  X_ORDER_SEQUENCE in NUMBER,
  X_MANAGED_BY_PERSON_ID in NUMBER,
  X_OUTBOUND_FLAG in VARCHAR2,
  X_INBOUND_FLAG in VARCHAR2,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_RATING in VARCHAR2,
  X_PREFERRED_VENDOR_ID in NUMBER,
  X_PARTY_ID in NUMBER,
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
  X_CHANNEL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_CHANNELS_B
    where CHANNEL_ID = X_CHANNEL_ID
    ;
begin
  insert into AMS_CHANNELS_B (
    CHANNEL_ID,
    OBJECT_VERSION_NUMBER,
    CHANNEL_TYPE_CODE,
    ORDER_SEQUENCE,
    MANAGED_BY_PERSON_ID,
    OUTBOUND_FLAG,
    INBOUND_FLAG,
    ACTIVE_FROM_DATE,
    ACTIVE_TO_DATE,
    RATING,
    PREFERRED_VENDOR_ID,
    PARTY_ID ,
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
    X_CHANNEL_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CHANNEL_TYPE_CODE,
    X_ORDER_SEQUENCE,
    X_MANAGED_BY_PERSON_ID,
    X_OUTBOUND_FLAG,
    X_INBOUND_FLAG,
    X_ACTIVE_FROM_DATE,
    X_ACTIVE_TO_DATE,
    X_RATING,
    X_PREFERRED_VENDOR_ID,
    X_PARTY_ID,
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

  insert into AMS_CHANNELS_TL (
    CHANNEL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CHANNEL_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CHANNEL_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CHANNEL_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_CHANNELS_TL T
    where T.CHANNEL_ID = X_CHANNEL_ID
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
  X_CHANNEL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHANNEL_TYPE_CODE in VARCHAR2,
  X_ORDER_SEQUENCE in NUMBER,
  X_MANAGED_BY_PERSON_ID in NUMBER,
  X_OUTBOUND_FLAG in VARCHAR2,
  X_INBOUND_FLAG in VARCHAR2,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_RATING in VARCHAR2,
  X_PREFERRED_VENDOR_ID in NUMBER,
  X_PARTY_ID in NUMBER,
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
  X_CHANNEL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      CHANNEL_TYPE_CODE,
      ORDER_SEQUENCE,
      MANAGED_BY_PERSON_ID,
      OUTBOUND_FLAG,
      INBOUND_FLAG,
      ACTIVE_FROM_DATE,
      ACTIVE_TO_DATE,
      RATING,
      PREFERRED_VENDOR_ID,
      PARTY_ID ,
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
    from AMS_CHANNELS_B
    where CHANNEL_ID = X_CHANNEL_ID
    for update of CHANNEL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CHANNEL_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_CHANNELS_TL
    where CHANNEL_ID = X_CHANNEL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CHANNEL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND (recinfo.CHANNEL_TYPE_CODE = X_CHANNEL_TYPE_CODE)
      AND ((recinfo.ORDER_SEQUENCE = X_ORDER_SEQUENCE)
           OR ((recinfo.ORDER_SEQUENCE is null) AND (X_ORDER_SEQUENCE is null)))
      AND ((recinfo.MANAGED_BY_PERSON_ID = X_MANAGED_BY_PERSON_ID)
           OR ((recinfo.MANAGED_BY_PERSON_ID is null) AND (X_MANAGED_BY_PERSON_ID is null)))
      AND (recinfo.OUTBOUND_FLAG = X_OUTBOUND_FLAG)
      AND (recinfo.INBOUND_FLAG = X_INBOUND_FLAG)
      AND (recinfo.ACTIVE_FROM_DATE = X_ACTIVE_FROM_DATE)
      AND ((recinfo.ACTIVE_TO_DATE = X_ACTIVE_TO_DATE)
           OR ((recinfo.ACTIVE_TO_DATE is null) AND (X_ACTIVE_TO_DATE is null)))
      AND ((recinfo.RATING = X_RATING)
           OR ((recinfo.RATING is null) AND (X_RATING is null)))
      AND ((recinfo.PREFERRED_VENDOR_ID = X_PREFERRED_VENDOR_ID)
           OR ((recinfo.PREFERRED_VENDOR_ID is null) AND (X_PREFERRED_VENDOR_ID is null)))
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
      if (    (tlinfo.CHANNEL_NAME = X_CHANNEL_NAME)
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
  X_CHANNEL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHANNEL_TYPE_CODE in VARCHAR2,
  X_ORDER_SEQUENCE in NUMBER,
  X_MANAGED_BY_PERSON_ID in NUMBER,
  X_OUTBOUND_FLAG in VARCHAR2,
  X_INBOUND_FLAG in VARCHAR2,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_RATING in VARCHAR2,
  X_PREFERRED_VENDOR_ID in NUMBER,
  X_PARTY_ID in NUMBER,
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
  X_CHANNEL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_CHANNELS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    CHANNEL_TYPE_CODE = X_CHANNEL_TYPE_CODE,
    ORDER_SEQUENCE = X_ORDER_SEQUENCE,
    MANAGED_BY_PERSON_ID = X_MANAGED_BY_PERSON_ID,
    OUTBOUND_FLAG = X_OUTBOUND_FLAG,
    INBOUND_FLAG = X_INBOUND_FLAG,
    ACTIVE_FROM_DATE = X_ACTIVE_FROM_DATE,
    ACTIVE_TO_DATE = X_ACTIVE_TO_DATE,
    RATING = X_RATING,
    PREFERRED_VENDOR_ID = X_PREFERRED_VENDOR_ID,
    PARTY_ID =  X_PARTY_ID ,
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
  where CHANNEL_ID = X_CHANNEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_CHANNELS_TL set
    CHANNEL_NAME = X_CHANNEL_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHANNEL_ID = X_CHANNEL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CHANNEL_ID in NUMBER
) is
begin
  delete from AMS_CHANNELS_TL
  where CHANNEL_ID = X_CHANNEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_CHANNELS_B
  where CHANNEL_ID = X_CHANNEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_CHANNELS_TL T
  where not exists
    (select NULL
    from AMS_CHANNELS_B B
    where B.CHANNEL_ID = T.CHANNEL_ID
    );

  update AMS_CHANNELS_TL T set (
      CHANNEL_NAME,
      DESCRIPTION
    ) = (select
      B.CHANNEL_NAME,
      B.DESCRIPTION
    from AMS_CHANNELS_TL B
    where B.CHANNEL_ID = T.CHANNEL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHANNEL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHANNEL_ID,
      SUBT.LANGUAGE
    from AMS_CHANNELS_TL SUBB, AMS_CHANNELS_TL SUBT
    where SUBB.CHANNEL_ID = SUBT.CHANNEL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CHANNEL_NAME <> SUBT.CHANNEL_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_CHANNELS_TL (
    CHANNEL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CHANNEL_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CHANNEL_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CHANNEL_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_CHANNELS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_CHANNELS_TL T
    where T.CHANNEL_ID = B.CHANNEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW(
       x_channel_id    in NUMBER
     , x_channel_name  in VARCHAR2
     , x_description    in VARCHAR2
     , x_owner   in VARCHAR2
 ) is
 begin
    update AMS_CHANNELS_TL set
       channel_name = nvl(x_channel_name, channel_name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  channel_id = x_channel_id
    and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

procedure  LOAD_ROW(
  x_channel_ID   IN NUMBER,
  x_channel_TYPE_CODE in VARCHAR2 DEFAULT NULL,
  X_INBOUND_FLAG in VARCHAR2 DEFAULT 'N',
  X_OUTBOUND_FLAG in VARCHAR2  DEFAULT 'Y',
  X_ORDER_SEQUENCE  in NUMBER,
  X_MANAGED_BY_PERSON_ID in NUMBER,
  X_ACTIVE_FROM_DATE in  DATE DEFAULT SYSDATE,
  X_ACTIVE_TO_DATE in    DATE DEFAULT NULL,
  X_RATING  in   VARCHAR2,
  X_PREFERRED_VENDOR_ID in NUMBER,
  X_PARTY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2  DEFAULT NULL ,
  X_ATTRIBUTE2 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2  DEFAULT NULL,
  x_channel_NAME in VARCHAR2  DEFAULT NULL,
  X_DESCRIPTION in VARCHAR2  DEFAULT NULL ,
  X_Owner              VARCHAR2
) is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_chan_id   number;

cursor  c_obj_verno is
  select object_version_number
  from    AMS_CHANNELS_B
  where  CHANNEL_id =  x_channel_ID;

cursor c_chk_cha_exists is
  select 'x'
  from   AMS_CHANNELS_B
  where  channel_id = x_channel_ID;

cursor c_get_chanid is
   select AMS_CHANNELS_B_S.nextval
   from dual;

BEGIN

  if X_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_cha_exists;
 fetch c_chk_cha_exists into l_dummy_char;
 if c_chk_cha_exists%notfound
 then
    if X_CHANNEL_ID is null
    then
      open c_get_chanid;
      fetch c_get_chanid into l_chan_id;
      close c_get_chanid;
    else
       l_chan_id := X_CHANNEL_ID;
    end if;
    l_obj_verno := 1;
    AMS_CHANNElS_PKG.INSERT_ROW(
    X_ROWID             =>  l_row_id,
    x_channel_ID               => l_chan_id,
    X_OBJECT_VERSION_NUMBER     => l_obj_verno,
    x_channel_TYPE_CODE            => x_channel_TYPE_CODE,
    X_INBOUND_FLAG          => X_INBOUND_FLAG,
    X_OUTBOUND_FLAG         => X_OUTBOUND_FLAG,
    X_ORDER_SEQUENCE            => X_ORDER_SEQUENCE,
    X_MANAGED_BY_PERSON_ID      => X_MANAGED_BY_PERSON_ID,
    X_ACTIVE_FROM_DATE          => X_ACTIVE_FROM_DATE,
    X_ACTIVE_TO_DATE            => X_ACTIVE_TO_DATE,
    X_RATING                => X_RATING  ,
    X_PREFERRED_VENDOR_ID       => X_PREFERRED_VENDOR_ID,
    X_PARTY_ID   => X_PARTY_ID ,
    X_ATTRIBUTE_CATEGORY        =>  X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1            =>  X_ATTRIBUTE1,
    X_ATTRIBUTE2            =>  X_ATTRIBUTE2,
    X_ATTRIBUTE3            =>  X_ATTRIBUTE3,
    X_ATTRIBUTE4            =>  X_ATTRIBUTE4,
    X_ATTRIBUTE5            =>  X_ATTRIBUTE5,
    X_ATTRIBUTE6            =>  X_ATTRIBUTE6,
    X_ATTRIBUTE7            =>  X_ATTRIBUTE7,
    X_ATTRIBUTE8            =>  X_ATTRIBUTE8,
    X_ATTRIBUTE9            =>  X_ATTRIBUTE9,
    X_ATTRIBUTE10           =>  X_ATTRIBUTE10,
    X_ATTRIBUTE11           =>  X_ATTRIBUTE11,
    X_ATTRIBUTE12           =>  X_ATTRIBUTE12,
    X_ATTRIBUTE13           =>  X_ATTRIBUTE13,
    X_ATTRIBUTE14           =>  X_ATTRIBUTE14,
    X_ATTRIBUTE15           =>  X_ATTRIBUTE15,
    X_CHANNEL_NAME         =>  X_CHANNEL_NAME,
    X_DESCRIPTION           =>  X_DESCRIPTION,
    X_CREATION_DATE     =>  SYSDATE,
    X_CREATED_BY            =>  l_user_id,
    X_LAST_UPDATE_DATE  =>  SYSDATE,
    X_LAST_UPDATED_BY       =>  l_user_id,
    X_LAST_UPDATE_LOGIN =>  0
  );
else
   close c_chk_cha_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;
    AMS_CHANNELS_PKG.UPDATE_ROW(
    x_channel_ID                =>  x_channel_ID,
    X_OBJECT_VERSION_NUMBER  => l_obj_verno + 1,
    x_channel_TYPE_CODE            => x_channel_TYPE_CODE,
    X_INBOUND_FLAG          => X_INBOUND_FLAG,
    X_OUTBOUND_FLAG         => X_OUTBOUND_FLAG,
    X_ORDER_SEQUENCE            => X_ORDER_SEQUENCE,
    X_MANAGED_BY_PERSON_ID      => X_MANAGED_BY_PERSON_ID,
    X_ACTIVE_FROM_DATE          => X_ACTIVE_FROM_DATE,
    X_ACTIVE_TO_DATE            => X_ACTIVE_TO_DATE,
    X_RATING                => X_RATING  ,
    X_PREFERRED_VENDOR_ID       => X_PREFERRED_VENDOR_ID,
    X_PARTY_ID =>  X_PARTY_ID,
    X_ATTRIBUTE_CATEGORY        =>  X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1            =>  X_ATTRIBUTE1,
    X_ATTRIBUTE2            =>  X_ATTRIBUTE2,
    X_ATTRIBUTE3            =>  X_ATTRIBUTE3,
    X_ATTRIBUTE4            =>  X_ATTRIBUTE4,
    X_ATTRIBUTE5            =>  X_ATTRIBUTE5,
    X_ATTRIBUTE6            =>  X_ATTRIBUTE6,
    X_ATTRIBUTE7            =>  X_ATTRIBUTE7,
    X_ATTRIBUTE8            =>  X_ATTRIBUTE8,
    X_ATTRIBUTE9            =>  X_ATTRIBUTE9,
    X_ATTRIBUTE10           =>  X_ATTRIBUTE10,
    X_ATTRIBUTE11           =>  X_ATTRIBUTE11,
    X_ATTRIBUTE12           =>  X_ATTRIBUTE12,
    X_ATTRIBUTE13           =>  X_ATTRIBUTE13,
    X_ATTRIBUTE14           =>  X_ATTRIBUTE14,
    X_ATTRIBUTE15           =>  X_ATTRIBUTE15,
    x_channel_NAME             =>  x_channel_NAME,
    X_DESCRIPTION           =>  X_DESCRIPTION,
    X_LAST_UPDATE_DATE  =>  SYSDATE,
    X_LAST_UPDATED_BY       =>  l_user_id,
    X_LAST_UPDATE_LOGIN =>  0
  );
end if;
END LOAD_ROW;
end AMS_CHANNELS_PKG;

/
