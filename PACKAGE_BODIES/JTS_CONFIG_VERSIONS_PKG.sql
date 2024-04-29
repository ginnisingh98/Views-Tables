--------------------------------------------------------
--  DDL for Package Body JTS_CONFIG_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_CONFIG_VERSIONS_PKG" as
/* $Header: jtstcvrb.pls 115.1 2002/06/07 11:53:20 pkm ship    $ */


-- --------------------------------------------------------------------
-- Package name     : JTS_CONFIG_VERSIONS_PKG
-- Purpose          : Table Handler for JTS_CONFIG_VERSIONS_B AND _TL tables
-- History          : 06-Jun-02  SHuh  Created.
--
-- PROCEDURES
--    DELETE_ROW
--    LOAD_ROW
--    INSERT_ROW
--    UPDATE_ROW
--    ADD_LANGUAGE
-- --------------------------------------------------------------------

procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_VERSION_ID in NUMBER,
  X_VERSION_STATUS_CODE in VARCHAR2,
  X_REPLAY_STATUS_CODE in VARCHAR2,
  X_REPLAYED_ON in DATE,
  X_REPLAYED_BY in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VERSION_NAME in VARCHAR2,
  X_CONFIGURATION_ID in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_QUEUE_NAME in VARCHAR2,
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
  X_SECURITY_GROUP_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTS_CONFIG_VERSIONS_B
    where VERSION_ID = X_VERSION_ID
    ;
begin
  insert into JTS_CONFIG_VERSIONS_B (
    VERSION_STATUS_CODE,
    REPLAY_STATUS_CODE,
    REPLAYED_ON,
    REPLAYED_BY,
    VERSION_ID,
    OBJECT_VERSION_NUMBER,
    VERSION_NAME,
    CONFIGURATION_ID,
    VERSION_NUMBER,
    QUEUE_NAME,
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
    SECURITY_GROUP_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_VERSION_STATUS_CODE,
    X_REPLAY_STATUS_CODE,
    X_REPLAYED_ON,
    X_REPLAYED_BY,
    X_VERSION_ID,
    X_OBJECT_VERSION_NUMBER,
    X_VERSION_NAME,
    X_CONFIGURATION_ID,
    X_VERSION_NUMBER,
    X_QUEUE_NAME,
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
    X_SECURITY_GROUP_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTS_CONFIG_VERSIONS_TL (
    VERSION_ID,
    CONFIGURATION_ID,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_VERSION_ID,
    X_CONFIGURATION_ID,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTS_CONFIG_VERSIONS_TL T
    where T.VERSION_ID = X_VERSION_ID
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
  X_VERSION_ID in NUMBER,
  X_VERSION_STATUS_CODE in VARCHAR2,
  X_REPLAY_STATUS_CODE in VARCHAR2,
  X_REPLAYED_ON in DATE,
  X_REPLAYED_BY in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VERSION_NAME in VARCHAR2,
  X_CONFIGURATION_ID in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_QUEUE_NAME in VARCHAR2,
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
  X_SECURITY_GROUP_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      VERSION_STATUS_CODE,
      REPLAY_STATUS_CODE,
      REPLAYED_ON,
      REPLAYED_BY,
      OBJECT_VERSION_NUMBER,
      VERSION_NAME,
      CONFIGURATION_ID,
      VERSION_NUMBER,
      QUEUE_NAME,
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
      SECURITY_GROUP_ID
    from JTS_CONFIG_VERSIONS_B
    where VERSION_ID = X_VERSION_ID
    for update of VERSION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTS_CONFIG_VERSIONS_TL
    where VERSION_ID = X_VERSION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of VERSION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.VERSION_STATUS_CODE = X_VERSION_STATUS_CODE)
           OR ((recinfo.VERSION_STATUS_CODE is null) AND (X_VERSION_STATUS_CODE is null)))
      AND ((recinfo.REPLAY_STATUS_CODE = X_REPLAY_STATUS_CODE)
           OR ((recinfo.REPLAY_STATUS_CODE is null) AND (X_REPLAY_STATUS_CODE is null)))
      AND ((recinfo.REPLAYED_ON = X_REPLAYED_ON)
           OR ((recinfo.REPLAYED_ON is null) AND (X_REPLAYED_ON is null)))
      AND ((recinfo.REPLAYED_BY = X_REPLAYED_BY)
           OR ((recinfo.REPLAYED_BY is null) AND (X_REPLAYED_BY is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.VERSION_NAME = X_VERSION_NAME)
      AND (recinfo.CONFIGURATION_ID = X_CONFIGURATION_ID)
      AND (recinfo.VERSION_NUMBER = X_VERSION_NUMBER)
      AND ((recinfo.QUEUE_NAME = X_QUEUE_NAME)
           OR ((recinfo.QUEUE_NAME is null) AND (X_QUEUE_NAME is null)))
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
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_VERSION_ID in NUMBER,
  X_VERSION_STATUS_CODE in VARCHAR2,
  X_REPLAY_STATUS_CODE in VARCHAR2,
  X_REPLAYED_ON in DATE,
  X_REPLAYED_BY in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VERSION_NAME in VARCHAR2,
  X_CONFIGURATION_ID in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_QUEUE_NAME in VARCHAR2,
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
  X_SECURITY_GROUP_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTS_CONFIG_VERSIONS_B set
    VERSION_STATUS_CODE = X_VERSION_STATUS_CODE,
    REPLAY_STATUS_CODE = X_REPLAY_STATUS_CODE,
    REPLAYED_ON = X_REPLAYED_ON,
    REPLAYED_BY = X_REPLAYED_BY,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    VERSION_NAME = X_VERSION_NAME,
    CONFIGURATION_ID = X_CONFIGURATION_ID,
    VERSION_NUMBER = X_VERSION_NUMBER,
    QUEUE_NAME = X_QUEUE_NAME,
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
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where VERSION_ID = X_VERSION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTS_CONFIG_VERSIONS_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where VERSION_ID = X_VERSION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


-- Deletes a row from jts_config_versions
PROCEDURE DELETE_ROW(p_version_id	IN NUMBER
) IS
BEGIN
   DELETE FROM jts_config_versions_b
   WHERE  version_id = p_version_id;

   DELETE FROM jts_config_versions_tl
   WHERE  version_id = p_version_id;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTS_CONFIG_VERSIONS_TL T
  where not exists
    (select NULL
    from JTS_CONFIG_VERSIONS_B B
    where B.VERSION_ID = T.VERSION_ID
    );

  update JTS_CONFIG_VERSIONS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from JTS_CONFIG_VERSIONS_TL B
    where B.VERSION_ID = T.VERSION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.VERSION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.VERSION_ID,
      SUBT.LANGUAGE
    from JTS_CONFIG_VERSIONS_TL SUBB, JTS_CONFIG_VERSIONS_TL SUBT
    where SUBB.VERSION_ID = SUBT.VERSION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into JTS_CONFIG_VERSIONS_TL (
    VERSION_ID,
    CONFIGURATION_ID,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.VERSION_ID,
    B.CONFIGURATION_ID,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTS_CONFIG_VERSIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTS_CONFIG_VERSIONS_TL T
    where T.VERSION_ID = B.VERSION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

-------------------------------------------------
-- Translates the description
-------------------------------------------------
PROCEDURE TRANSLATE_ROW (
         p_version_id  		IN NUMBER,
         p_owner    		IN VARCHAR2,
         p_description		IN VARCHAR2
        )
IS
BEGIN
    update jts_config_versions_tl set
       description = nvl(p_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(p_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  version_id= p_version_id
    and    userenv('LANG') in (language, source_lang);

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END TRANSLATE_ROW;


END JTS_CONFIG_VERSIONS_PKG;

/
