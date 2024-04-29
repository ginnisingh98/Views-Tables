--------------------------------------------------------
--  DDL for Package Body AMV_C_CHANNELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_C_CHANNELS_PKG" as
/* $Header: amvtchab.pls 120.1 2005/06/29 10:28:03 appldev ship $ */
procedure LOAD_ROW (
  X_CHANNEL_ID in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in VARCHAR2,
  X_CHANNEL_TYPE in VARCHAR2,
  X_CHANNEL_CATEGORY_ID in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_OWNER_USER_ID in VARCHAR2,
  X_DEFAULT_APPROVER_USER_ID in VARCHAR2,
  X_EFFECTIVE_START_DATE in VARCHAR2,
  X_EXPIRATION_DATE in VARCHAR2,
  X_ACCESS_LEVEL_TYPE in VARCHAR2,
  X_PUB_NEED_APPROVAL_FLAG in VARCHAR2,
  X_SUB_NEED_APPROVAL_FLAG in VARCHAR2,
  X_MATCH_ON_ALL_CRITERIA_FLAG in VARCHAR2,
  X_MATCH_ON_KEYWORD_FLAG in VARCHAR2,
  X_MATCH_ON_AUTHOR_FLAG in VARCHAR2,
  X_MATCH_ON_PERSPECTIVE_FLAG in VARCHAR2,
  X_MATCH_ON_ITEM_TYPE_FLAG in VARCHAR2,
  X_MATCH_ON_CONTENT_TYPE_FLAG in VARCHAR2,
  X_MATCH_ON_TIME_FLAG in VARCHAR2,
  X_APPLICATION_ID in VARCHAR2,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_ITEM_MATCH_COUNT in VARCHAR2,
  X_LAST_MATCH_TIME in VARCHAR2,
  X_NOTIFICATION_INTERVAL_TYPE in VARCHAR2,
  X_LAST_NOTIFICATION_TIME in VARCHAR2,
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
  X_OWNER in VARCHAR2)
is
l_user_id           number := 0;
l_channel_id   number := 0;
l_object_version_number number := 0;
l_channel_category_id   number := 0;
l_owner_user_id   number := 0;
l_default_approver_user_id   number := 0;
l_application_id    number := 0;
l_item_match_count   number := 0;
l_effective_start_date date;
l_expiration_date date;
l_last_match_time date;
l_last_notification_time date;
l_row_id            varchar2(64);
begin
     if (X_OWNER = 'SEED') then
		l_user_id := 1;
	end if;
	l_channel_id  := to_number(x_channel_id);
	l_object_version_number := to_number(x_object_version_number);
	l_channel_category_id := to_number(x_channel_category_id);
	l_owner_user_id := to_number(x_owner_user_id);
	l_default_approver_user_id := to_number(x_default_approver_user_id);
	l_application_id := to_number(x_application_id);
	l_item_match_count := to_number(x_item_match_count);
	l_effective_start_date := to_date(x_effective_start_date, 'DD/MM/YYYY');
	l_expiration_date := to_date(x_expiration_date, 'DD/MM/YYYY');
	l_last_match_time := to_date(x_last_match_time, 'DD/MM/YYYY');
	l_last_notification_time :=to_date(x_last_notification_time,'DD/MM/YYYY');
	--
	AMV_C_CHANNELS_PKG.UPDATE_ROW (
  		X_CHANNEL_ID => l_channel_id,
 		X_OBJECT_VERSION_NUMBER => l_object_version_number,
  		X_CHANNEL_TYPE => x_channel_type,
  		X_CHANNEL_CATEGORY_ID => l_channel_category_id,
  		X_STATUS => x_status,
  		X_OWNER_USER_ID => l_owner_user_id,
  		X_DEFAULT_APPROVER_USER_ID => l_default_approver_user_id,
  		X_EFFECTIVE_START_DATE => l_effective_start_date,
  		X_EXPIRATION_DATE => l_expiration_date,
  		X_ACCESS_LEVEL_TYPE => x_access_level_type,
  		X_PUB_NEED_APPROVAL_FLAG => x_pub_need_approval_flag,
  		X_SUB_NEED_APPROVAL_FLAG => x_sub_need_approval_flag,
  		X_MATCH_ON_ALL_CRITERIA_FLAG => x_match_on_all_criteria_flag,
  		X_MATCH_ON_KEYWORD_FLAG => x_match_on_keyword_flag,
  		X_MATCH_ON_AUTHOR_FLAG => x_match_on_author_flag,
  		X_MATCH_ON_PERSPECTIVE_FLAG => x_match_on_perspective_flag,
  		X_MATCH_ON_ITEM_TYPE_FLAG => x_match_on_item_type_flag,
  		X_MATCH_ON_CONTENT_TYPE_FLAG => x_match_on_content_type_flag,
  		X_MATCH_ON_TIME_FLAG => x_match_on_time_flag,
  		X_APPLICATION_ID => l_application_id,
  		X_EXTERNAL_ACCESS_FLAG => x_external_access_flag,
  		X_ITEM_MATCH_COUNT => l_item_match_count,
  		X_LAST_MATCH_TIME => l_last_match_time,
  		X_NOTIFICATION_INTERVAL_TYPE => x_notification_interval_type,
  		X_LAST_NOTIFICATION_TIME => l_last_notification_time,
  		X_ATTRIBUTE_CATEGORY => x_attribute_category,
  		X_ATTRIBUTE1 => x_attribute1,
  		X_ATTRIBUTE2 => x_attribute2,
 		X_ATTRIBUTE3 => x_attribute3,
 		X_ATTRIBUTE4 => x_attribute4,
  		X_ATTRIBUTE5 => x_attribute5,
  		X_ATTRIBUTE6 => x_attribute6,
  		X_ATTRIBUTE7 => x_attribute7,
  		X_ATTRIBUTE8 => x_attribute8,
  		X_ATTRIBUTE9 => x_attribute9,
  		X_ATTRIBUTE10 => x_attribute10,
  		X_ATTRIBUTE11 => x_attribute11,
  		X_ATTRIBUTE12 => x_attribute12,
  		X_ATTRIBUTE13 => x_attribute13,
  		X_ATTRIBUTE14 => x_attribute14,
  		X_ATTRIBUTE15 => x_attribute15,
  		X_CHANNEL_NAME => x_channel_name,
		X_DESCRIPTION       => x_description,
		X_LAST_UPDATE_DATE  => sysdate,
		X_LAST_UPDATED_BY   => l_user_id,
		X_LAST_UPDATE_LOGIN => 0
		);
exception
	when NO_DATA_FOUND then
 	AMV_C_CHANNELS_PKG.INSERT_ROW (
  		X_ROWID => l_row_id,
  		X_CHANNEL_ID => l_channel_id,
 		X_OBJECT_VERSION_NUMBER => l_object_version_number,
  		X_CHANNEL_TYPE => x_channel_type,
  		X_CHANNEL_CATEGORY_ID => l_channel_category_id,
  		X_STATUS => x_status,
  		X_OWNER_USER_ID => l_owner_user_id,
  		X_DEFAULT_APPROVER_USER_ID => l_default_approver_user_id,
  		X_EFFECTIVE_START_DATE => l_effective_start_date,
  		X_EXPIRATION_DATE => l_expiration_date,
  		X_ACCESS_LEVEL_TYPE => x_access_level_type,
  		X_PUB_NEED_APPROVAL_FLAG => x_pub_need_approval_flag,
  		X_SUB_NEED_APPROVAL_FLAG => x_sub_need_approval_flag,
  		X_MATCH_ON_ALL_CRITERIA_FLAG => x_match_on_all_criteria_flag,
  		X_MATCH_ON_KEYWORD_FLAG => x_match_on_keyword_flag,
  		X_MATCH_ON_AUTHOR_FLAG => x_match_on_author_flag,
  		X_MATCH_ON_PERSPECTIVE_FLAG => x_match_on_perspective_flag,
  		X_MATCH_ON_ITEM_TYPE_FLAG => x_match_on_item_type_flag,
  		X_MATCH_ON_CONTENT_TYPE_FLAG => x_match_on_content_type_flag,
  		X_MATCH_ON_TIME_FLAG => x_match_on_time_flag,
  		X_APPLICATION_ID => l_application_id,
  		X_EXTERNAL_ACCESS_FLAG => x_external_access_flag,
  		X_ITEM_MATCH_COUNT => l_item_match_count,
  		X_LAST_MATCH_TIME => l_last_match_time,
  		X_NOTIFICATION_INTERVAL_TYPE => x_notification_interval_type,
  		X_LAST_NOTIFICATION_TIME => x_last_notification_time,
  		X_ATTRIBUTE_CATEGORY => x_attribute_category,
  		X_ATTRIBUTE1 => x_attribute1,
  		X_ATTRIBUTE2 => x_attribute2,
 		X_ATTRIBUTE3 => x_attribute3,
 		X_ATTRIBUTE4 => x_attribute4,
  		X_ATTRIBUTE5 => x_attribute5,
  		X_ATTRIBUTE6 => x_attribute6,
  		X_ATTRIBUTE7 => x_attribute7,
  		X_ATTRIBUTE8 => x_attribute8,
  		X_ATTRIBUTE9 => x_attribute9,
  		X_ATTRIBUTE10 => x_attribute10,
  		X_ATTRIBUTE11 => x_attribute11,
  		X_ATTRIBUTE12 => x_attribute12,
  		X_ATTRIBUTE13 => x_attribute13,
  		X_ATTRIBUTE14 => x_attribute14,
  		X_ATTRIBUTE15 => x_attribute15,
  		X_CHANNEL_NAME => x_channel_name,
		X_DESCRIPTION       => x_description,
		X_CREATION_DATE     => sysdate,
		X_CREATED_BY        => l_user_id,
		X_LAST_UPDATE_DATE  => sysdate,
		X_LAST_UPDATED_BY   => l_user_id,
		X_LAST_UPDATE_LOGIN => 0
		);
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_CHANNEL_ID in NUMBER,
  X_CHANNEL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2)
is
begin
	update AMV_C_CHANNELS_TL set
		CHANNEL_NAME = x_channel_name,
		DESCRIPTION       = x_description,
		LAST_UPDATE_DATE  = sysdate,
		LAST_UPDATED_BY   = decode(x_owner, 'SEED', 1, 0),
		LAST_UPDATE_LOGIN = 0,
		SOURCE_LANG = userenv('LANG')
	where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
	and CHANNEL_ID = x_channel_id;
end TRANSLATE_ROW;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CHANNEL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CHANNEL_TYPE in VARCHAR2,
  X_CHANNEL_CATEGORY_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_OWNER_USER_ID in NUMBER,
  X_DEFAULT_APPROVER_USER_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_ACCESS_LEVEL_TYPE in VARCHAR2,
  X_PUB_NEED_APPROVAL_FLAG in VARCHAR2,
  X_SUB_NEED_APPROVAL_FLAG in VARCHAR2,
  X_MATCH_ON_ALL_CRITERIA_FLAG in VARCHAR2,
  X_MATCH_ON_KEYWORD_FLAG in VARCHAR2,
  X_MATCH_ON_AUTHOR_FLAG in VARCHAR2,
  X_MATCH_ON_PERSPECTIVE_FLAG in VARCHAR2,
  X_MATCH_ON_ITEM_TYPE_FLAG in VARCHAR2,
  X_MATCH_ON_CONTENT_TYPE_FLAG in VARCHAR2,
  X_MATCH_ON_TIME_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_ITEM_MATCH_COUNT in NUMBER,
  X_LAST_MATCH_TIME in DATE,
  X_NOTIFICATION_INTERVAL_TYPE in VARCHAR2,
  X_LAST_NOTIFICATION_TIME in DATE,
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
  cursor C is select ROWID from AMV_C_CHANNELS_B
    where CHANNEL_ID = X_CHANNEL_ID
    ;
begin
  insert into AMV_C_CHANNELS_B (
    CHANNEL_ID,
    OBJECT_VERSION_NUMBER,
    CHANNEL_TYPE,
    CHANNEL_CATEGORY_ID,
    STATUS,
    OWNER_USER_ID,
    DEFAULT_APPROVER_USER_ID,
    EFFECTIVE_START_DATE,
    EXPIRATION_DATE,
    ACCESS_LEVEL_TYPE,
    PUB_NEED_APPROVAL_FLAG,
    SUB_NEED_APPROVAL_FLAG,
    MATCH_ON_ALL_CRITERIA_FLAG,
    MATCH_ON_KEYWORD_FLAG,
    MATCH_ON_AUTHOR_FLAG,
    MATCH_ON_PERSPECTIVE_FLAG,
    MATCH_ON_ITEM_TYPE_FLAG,
    MATCH_ON_CONTENT_TYPE_FLAG,
    MATCH_ON_TIME_FLAG,
    APPLICATION_ID,
    EXTERNAL_ACCESS_FLAG,
    ITEM_MATCH_COUNT,
    LAST_MATCH_TIME,
    NOTIFICATION_INTERVAL_TYPE,
    LAST_NOTIFICATION_TIME,
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
    X_CHANNEL_TYPE,
    X_CHANNEL_CATEGORY_ID,
    X_STATUS,
    X_OWNER_USER_ID,
    X_DEFAULT_APPROVER_USER_ID,
    X_EFFECTIVE_START_DATE,
    X_EXPIRATION_DATE,
    X_ACCESS_LEVEL_TYPE,
    X_PUB_NEED_APPROVAL_FLAG,
    X_SUB_NEED_APPROVAL_FLAG,
    X_MATCH_ON_ALL_CRITERIA_FLAG,
    X_MATCH_ON_KEYWORD_FLAG,
    X_MATCH_ON_AUTHOR_FLAG,
    X_MATCH_ON_PERSPECTIVE_FLAG,
    X_MATCH_ON_ITEM_TYPE_FLAG,
    X_MATCH_ON_CONTENT_TYPE_FLAG,
    X_MATCH_ON_TIME_FLAG,
    X_APPLICATION_ID,
    X_EXTERNAL_ACCESS_FLAG,
    X_ITEM_MATCH_COUNT,
    X_LAST_MATCH_TIME,
    X_NOTIFICATION_INTERVAL_TYPE,
    X_LAST_NOTIFICATION_TIME,
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

  insert into AMV_C_CHANNELS_TL (
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
    from AMV_C_CHANNELS_TL T
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
  X_CHANNEL_TYPE in VARCHAR2,
  X_CHANNEL_CATEGORY_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_OWNER_USER_ID in NUMBER,
  X_DEFAULT_APPROVER_USER_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_ACCESS_LEVEL_TYPE in VARCHAR2,
  X_PUB_NEED_APPROVAL_FLAG in VARCHAR2,
  X_SUB_NEED_APPROVAL_FLAG in VARCHAR2,
  X_MATCH_ON_ALL_CRITERIA_FLAG in VARCHAR2,
  X_MATCH_ON_KEYWORD_FLAG in VARCHAR2,
  X_MATCH_ON_AUTHOR_FLAG in VARCHAR2,
  X_MATCH_ON_PERSPECTIVE_FLAG in VARCHAR2,
  X_MATCH_ON_ITEM_TYPE_FLAG in VARCHAR2,
  X_MATCH_ON_CONTENT_TYPE_FLAG in VARCHAR2,
  X_MATCH_ON_TIME_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_ITEM_MATCH_COUNT in NUMBER,
  X_LAST_MATCH_TIME in DATE,
  X_NOTIFICATION_INTERVAL_TYPE in VARCHAR2,
  X_LAST_NOTIFICATION_TIME in DATE,
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
      CHANNEL_TYPE,
      CHANNEL_CATEGORY_ID,
      STATUS,
      OWNER_USER_ID,
      DEFAULT_APPROVER_USER_ID,
      EFFECTIVE_START_DATE,
      EXPIRATION_DATE,
      ACCESS_LEVEL_TYPE,
      PUB_NEED_APPROVAL_FLAG,
      SUB_NEED_APPROVAL_FLAG,
      MATCH_ON_ALL_CRITERIA_FLAG,
      MATCH_ON_KEYWORD_FLAG,
      MATCH_ON_AUTHOR_FLAG,
      MATCH_ON_PERSPECTIVE_FLAG,
      MATCH_ON_ITEM_TYPE_FLAG,
      MATCH_ON_CONTENT_TYPE_FLAG,
      MATCH_ON_TIME_FLAG,
      APPLICATION_ID,
      EXTERNAL_ACCESS_FLAG,
      ITEM_MATCH_COUNT,
      LAST_MATCH_TIME,
      NOTIFICATION_INTERVAL_TYPE,
      LAST_NOTIFICATION_TIME,
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
    from AMV_C_CHANNELS_B
    where CHANNEL_ID = X_CHANNEL_ID
    for update of CHANNEL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CHANNEL_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMV_C_CHANNELS_TL
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
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.CHANNEL_TYPE = X_CHANNEL_TYPE)
      AND (recinfo.CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID)
      AND (recinfo.STATUS = X_STATUS)
      AND (recinfo.OWNER_USER_ID = X_OWNER_USER_ID)
      AND (recinfo.DEFAULT_APPROVER_USER_ID = X_DEFAULT_APPROVER_USER_ID)
      AND (recinfo.EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE)
      AND ((recinfo.EXPIRATION_DATE = X_EXPIRATION_DATE)
           OR ((recinfo.EXPIRATION_DATE is null) AND (X_EXPIRATION_DATE is null)))
      AND (recinfo.ACCESS_LEVEL_TYPE = X_ACCESS_LEVEL_TYPE)
      AND (recinfo.PUB_NEED_APPROVAL_FLAG = X_PUB_NEED_APPROVAL_FLAG)
      AND (recinfo.SUB_NEED_APPROVAL_FLAG = X_SUB_NEED_APPROVAL_FLAG)
      AND (recinfo.MATCH_ON_ALL_CRITERIA_FLAG = X_MATCH_ON_ALL_CRITERIA_FLAG)
      AND (recinfo.MATCH_ON_KEYWORD_FLAG = X_MATCH_ON_KEYWORD_FLAG)
      AND (recinfo.MATCH_ON_AUTHOR_FLAG = X_MATCH_ON_AUTHOR_FLAG)
      AND (recinfo.MATCH_ON_PERSPECTIVE_FLAG = X_MATCH_ON_PERSPECTIVE_FLAG)
      AND (recinfo.MATCH_ON_ITEM_TYPE_FLAG = X_MATCH_ON_ITEM_TYPE_FLAG)
      AND (recinfo.MATCH_ON_CONTENT_TYPE_FLAG = X_MATCH_ON_CONTENT_TYPE_FLAG)
      AND (recinfo.MATCH_ON_TIME_FLAG = X_MATCH_ON_TIME_FLAG)
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      AND ((recinfo.EXTERNAL_ACCESS_FLAG = X_EXTERNAL_ACCESS_FLAG)
           OR ((recinfo.EXTERNAL_ACCESS_FLAG is null) AND (X_EXTERNAL_ACCESS_FLAG is null)))
      AND ((recinfo.ITEM_MATCH_COUNT = X_ITEM_MATCH_COUNT)
           OR ((recinfo.ITEM_MATCH_COUNT is null) AND (X_ITEM_MATCH_COUNT is null)))
      AND ((recinfo.LAST_MATCH_TIME = X_LAST_MATCH_TIME)
           OR ((recinfo.LAST_MATCH_TIME is null) AND (X_LAST_MATCH_TIME is null)))
      AND ((recinfo.NOTIFICATION_INTERVAL_TYPE = X_NOTIFICATION_INTERVAL_TYPE)
           OR ((recinfo.NOTIFICATION_INTERVAL_TYPE is null) AND (X_NOTIFICATION_INTERVAL_TYPE is null)))
      AND ((recinfo.LAST_NOTIFICATION_TIME = X_LAST_NOTIFICATION_TIME)
           OR ((recinfo.LAST_NOTIFICATION_TIME is null) AND (X_LAST_NOTIFICATION_TIME is null)))
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
  X_CHANNEL_TYPE in VARCHAR2,
  X_CHANNEL_CATEGORY_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_OWNER_USER_ID in NUMBER,
  X_DEFAULT_APPROVER_USER_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_ACCESS_LEVEL_TYPE in VARCHAR2,
  X_PUB_NEED_APPROVAL_FLAG in VARCHAR2,
  X_SUB_NEED_APPROVAL_FLAG in VARCHAR2,
  X_MATCH_ON_ALL_CRITERIA_FLAG in VARCHAR2,
  X_MATCH_ON_KEYWORD_FLAG in VARCHAR2,
  X_MATCH_ON_AUTHOR_FLAG in VARCHAR2,
  X_MATCH_ON_PERSPECTIVE_FLAG in VARCHAR2,
  X_MATCH_ON_ITEM_TYPE_FLAG in VARCHAR2,
  X_MATCH_ON_CONTENT_TYPE_FLAG in VARCHAR2,
  X_MATCH_ON_TIME_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_ITEM_MATCH_COUNT in NUMBER,
  X_LAST_MATCH_TIME in DATE,
  X_NOTIFICATION_INTERVAL_TYPE in VARCHAR2,
  X_LAST_NOTIFICATION_TIME in DATE,
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
  update AMV_C_CHANNELS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    CHANNEL_TYPE = X_CHANNEL_TYPE,
    CHANNEL_CATEGORY_ID = X_CHANNEL_CATEGORY_ID,
    STATUS = X_STATUS,
    OWNER_USER_ID = X_OWNER_USER_ID,
    DEFAULT_APPROVER_USER_ID = X_DEFAULT_APPROVER_USER_ID,
    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE,
    EXPIRATION_DATE = X_EXPIRATION_DATE,
    ACCESS_LEVEL_TYPE = X_ACCESS_LEVEL_TYPE,
    PUB_NEED_APPROVAL_FLAG = X_PUB_NEED_APPROVAL_FLAG,
    SUB_NEED_APPROVAL_FLAG = X_SUB_NEED_APPROVAL_FLAG,
    MATCH_ON_ALL_CRITERIA_FLAG = X_MATCH_ON_ALL_CRITERIA_FLAG,
    MATCH_ON_KEYWORD_FLAG = X_MATCH_ON_KEYWORD_FLAG,
    MATCH_ON_AUTHOR_FLAG = X_MATCH_ON_AUTHOR_FLAG,
    MATCH_ON_PERSPECTIVE_FLAG = X_MATCH_ON_PERSPECTIVE_FLAG,
    MATCH_ON_ITEM_TYPE_FLAG = X_MATCH_ON_ITEM_TYPE_FLAG,
    MATCH_ON_CONTENT_TYPE_FLAG = X_MATCH_ON_CONTENT_TYPE_FLAG,
    MATCH_ON_TIME_FLAG = X_MATCH_ON_TIME_FLAG,
    APPLICATION_ID = X_APPLICATION_ID,
    EXTERNAL_ACCESS_FLAG = X_EXTERNAL_ACCESS_FLAG,
    ITEM_MATCH_COUNT = X_ITEM_MATCH_COUNT,
    LAST_MATCH_TIME = X_LAST_MATCH_TIME,
    NOTIFICATION_INTERVAL_TYPE = X_NOTIFICATION_INTERVAL_TYPE,
    LAST_NOTIFICATION_TIME = X_LAST_NOTIFICATION_TIME,
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

  update AMV_C_CHANNELS_TL set
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
  delete from AMV_C_CHANNELS_TL
  where CHANNEL_ID = X_CHANNEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMV_C_CHANNELS_B
  where CHANNEL_ID = X_CHANNEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMV_C_CHANNELS_TL T
  where not exists
    (select NULL
    from AMV_C_CHANNELS_B B
    where B.CHANNEL_ID = T.CHANNEL_ID
    );

  update AMV_C_CHANNELS_TL T set (
      CHANNEL_NAME,
      DESCRIPTION
    ) = (select
      B.CHANNEL_NAME,
      B.DESCRIPTION
    from AMV_C_CHANNELS_TL B
    where B.CHANNEL_ID = T.CHANNEL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHANNEL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHANNEL_ID,
      SUBT.LANGUAGE
    from AMV_C_CHANNELS_TL SUBB, AMV_C_CHANNELS_TL SUBT
    where SUBB.CHANNEL_ID = SUBT.CHANNEL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CHANNEL_NAME <> SUBT.CHANNEL_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMV_C_CHANNELS_TL (
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
  from AMV_C_CHANNELS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMV_C_CHANNELS_TL T
    where T.CHANNEL_ID = B.CHANNEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AMV_C_CHANNELS_PKG;

/