--------------------------------------------------------
--  DDL for Package Body WMS_DEVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_DEVICES_PKG" as
/* $Header: WMSDEVDB.pls 120.1 2005/07/21 13:35:49 simran noship $ */
procedure INSERT_ROW (
  X_ROWID 			in out nocopy VARCHAR2,
  X_DEVICE_ID 			in NUMBER,
  X_DEVICE_TYPE_ID 		in NUMBER,
  X_ENABLED_FLAG 		in VARCHAR2,
  X_LOT_SERIAL_CAPABLE 		in VARCHAR2,
  X_INPUT_METHOD_ID 		in NUMBER,
  X_OUTPUT_METHOD_ID 		in NUMBER,
  X_BATCH_LIMIT 		in NUMBER,
  X_OUT_DIRECTORY 		in VARCHAR2,
  X_OUT_FILE_PREFIX 		in VARCHAR2,
  X_SUBINVENTORY_CODE		in VARCHAR2,
  X_ORGANIZATION_ID		in NUMBER,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1			in VARCHAR2,
  X_ATTRIBUTE2			in VARCHAR2,
  X_ATTRIBUTE3			in VARCHAR2,
  X_ATTRIBUTE4			in VARCHAR2,
  X_ATTRIBUTE5			in VARCHAR2,
  X_ATTRIBUTE6			in VARCHAR2,
  X_ATTRIBUTE7			in VARCHAR2,
  X_ATTRIBUTE8			in VARCHAR2,
  X_ATTRIBUTE9			in VARCHAR2,
  X_ATTRIBUTE10			in VARCHAR2,
  X_ATTRIBUTE11			in VARCHAR2,
  X_ATTRIBUTE12			in VARCHAR2,
  X_ATTRIBUTE13			in VARCHAR2,
  X_ATTRIBUTE14			in VARCHAR2,
  X_ATTRIBUTE15			in VARCHAR2,
  X_NAME 			in VARCHAR2,
  X_DESCRIPTION 		in VARCHAR2,
  X_CREATION_DATE 		in DATE,
  X_CREATED_BY 			in NUMBER,
  X_LAST_UPDATE_DATE 		in DATE,
  X_LAST_UPDATED_BY 		in NUMBER,
  X_LAST_UPDATE_LOGIN 		in NUMBER,
  X_DEVICE_MODEL		in VARCHAR2,
  X_NOTIFICATION_FLAG		in VARCHAR2,
  X_FORCE_SIGN_ON_FLAG		in VARCHAR2,
  x_locator_id             IN number,
  x_multi_sign_on          IN VARCHAR2,
  x_message_template_id    IN NUMBER    --MHP
  ) is
  cursor C is select ROWID from WMS_DEVICES_B
    where DEVICE_ID = X_DEVICE_ID  ;
begin
  insert into WMS_DEVICES_B (
    DEVICE_ID,
    DEVICE_TYPE_ID,
    ENABLED_FLAG,
    LOT_SERIAL_CAPABLE,
    INPUT_METHOD_ID,
    OUTPUT_METHOD_ID,
    BATCH_LIMIT,
    OUT_DIRECTORY,
    OUT_FILE_PREFIX,
    SUBINVENTORY_CODE,
    ORGANIZATION_ID,
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
    LAST_UPDATE_LOGIN,
    DEVICE_MODEL,
    NOTIFICATION_FLAG,
    force_sign_on_flag,
    locator_id,
    multi_sign_on,
    message_template_id
  ) values (
    X_DEVICE_ID,
    X_DEVICE_TYPE_ID,
    X_ENABLED_FLAG,
    X_LOT_SERIAL_CAPABLE,
    X_INPUT_METHOD_ID,
    X_OUTPUT_METHOD_ID,
    X_BATCH_LIMIT,
    X_OUT_DIRECTORY,
    X_OUT_FILE_PREFIX,
    X_SUBINVENTORY_CODE,
    X_ORGANIZATION_ID,
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
    X_LAST_UPDATE_LOGIN,
    X_DEVICE_MODEL,
    X_NOTIFICATION_FLAG,
    x_force_sign_on_flag,
    x_locator_id,
    x_multi_sign_on,
    x_message_template_id);

  insert into WMS_DEVICES_TL(
    DEVICE_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  select
    X_DEVICE_ID,
    X_NAME,
    X_DESCRIPTION,
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
    from WMS_DEVICES_TL T
    where T.DEVICE_ID = X_DEVICE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW(
  X_DEVICE_ID 			in NUMBER,
  X_DEVICE_TYPE_ID 		in NUMBER,
  X_ENABLED_FLAG 		in VARCHAR2,
  X_LOT_SERIAL_CAPABLE 		in VARCHAR2,
  X_INPUT_METHOD_ID 		in NUMBER,
  X_OUTPUT_METHOD_ID 		in NUMBER,
  X_BATCH_LIMIT 		in NUMBER,
  X_OUT_DIRECTORY 		in VARCHAR2,
  X_OUT_FILE_PREFIX 		in VARCHAR2,
  X_SUBINVENTORY_CODE		in VARCHAR2,
  X_ORGANIZATION_ID		in NUMBER,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1			in VARCHAR2,
  X_ATTRIBUTE2			in VARCHAR2,
  X_ATTRIBUTE3			in VARCHAR2,
  X_ATTRIBUTE4			in VARCHAR2,
  X_ATTRIBUTE5			in VARCHAR2,
  X_ATTRIBUTE6			in VARCHAR2,
  X_ATTRIBUTE7			in VARCHAR2,
  X_ATTRIBUTE8			in VARCHAR2,
  X_ATTRIBUTE9			in VARCHAR2,
  X_ATTRIBUTE10			in VARCHAR2,
  X_ATTRIBUTE11			in VARCHAR2,
  X_ATTRIBUTE12			in VARCHAR2,
  X_ATTRIBUTE13			in VARCHAR2,
  X_ATTRIBUTE14			in VARCHAR2,
  X_ATTRIBUTE15			in VARCHAR2,
  X_NAME 			in VARCHAR2,
  X_DESCRIPTION 		in VARCHAR2,
  X_DEVICE_MODEL		in VARCHAR2,
  X_NOTIFICATION_FLAG		in VARCHAR2,
  X_FORCE_SIGN_ON_FLAG		in VARCHAR2,
  x_locator_id             IN number,
  x_multi_sign_on          IN VARCHAR2,
  x_message_template_id    IN NUMBER    --MHP
  ) is
  cursor c is select
      DEVICE_TYPE_ID,
      ENABLED_FLAG,
      LOT_SERIAL_CAPABLE,
      INPUT_METHOD_ID,
      OUTPUT_METHOD_ID,
      BATCH_LIMIT,
      OUT_DIRECTORY,
      OUT_FILE_PREFIX,
      SUBINVENTORY_CODE,
      ORGANIZATION_ID,
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
      DEVICE_MODEL,
      NOTIFICATION_FLAG,
      force_sign_on_flag,
      locator_id,
      multi_sign_on,
      message_template_id    --MHP
    from WMS_DEVICES_B
    where DEVICE_ID = X_DEVICE_ID
    for update of DEVICE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WMS_DEVICES_TL
    where DEVICE_ID = X_DEVICE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DEVICE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (     (recinfo.DEVICE_TYPE_ID = X_DEVICE_TYPE_ID)
      AND  (recinfo.OUTPUT_METHOD_ID = X_OUTPUT_METHOD_ID)
      AND ((recinfo.DEVICE_MODEL = X_DEVICE_MODEL)
				OR ((recinfo.DEVICE_MODEL is null) AND (X_DEVICE_MODEL is null)))
      AND ((recinfo.NOTIFICATION_FLAG = X_NOTIFICATION_FLAG)
            OR ((recinfo.NOTIFICATION_FLAG is null) AND (X_NOTIFICATION_FLAG is null)))
       AND ((recinfo.FORCE_SIGN_ON_FLAG = X_FORCE_SIGN_ON_FLAG)
            OR ((recinfo.FORCE_SIGN_ON_FLAG is null) AND (X_FORCE_SIGN_ON_FLAG is null)))
      AND ((recinfo.locator_id = X_locator_id)
	   OR ((recinfo.locator_id is null) AND (x_locator_id is null)))
      AND ((recinfo.multi_sign_on = x_multi_sign_on)
	         OR ((recinfo.multi_sign_on is null) AND (x_multi_sign_on is null)))
      AND ((recinfo.message_template_id = x_message_template_id)
	         OR ((recinfo.message_template_id is null) AND (x_message_template_id is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      	   OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.LOT_SERIAL_CAPABLE = X_LOT_SERIAL_CAPABLE)
      	   OR ((recinfo.LOT_SERIAL_CAPABLE is null) AND (X_LOT_SERIAL_CAPABLE is null)))
      AND ((recinfo.INPUT_METHOD_ID = X_INPUT_METHOD_ID)
           OR ((recinfo.INPUT_METHOD_ID is null) AND (X_INPUT_METHOD_ID is null)))
      AND ((recinfo.BATCH_LIMIT = X_BATCH_LIMIT)
           OR ((recinfo.BATCH_LIMIT is null) AND (X_BATCH_LIMIT is null)))
      AND ((recinfo.OUT_DIRECTORY = X_OUT_DIRECTORY)
      	   OR ((recinfo.OUT_DIRECTORY is null) AND (X_OUT_DIRECTORY is null)))
      AND ((recinfo.OUT_FILE_PREFIX = X_OUT_FILE_PREFIX)
      	   OR ((recinfo.OUT_FILE_PREFIX is null) AND (X_OUT_FILE_PREFIX is null)))
      AND ((recinfo.SUBINVENTORY_CODE = X_SUBINVENTORY_CODE)
            OR ((recinfo.SUBINVENTORY_CODE is null) AND (X_SUBINVENTORY_CODE is null)))
      AND ((recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
           OR ((recinfo.ORGANIZATION_ID is null) AND (X_ORGANIZATION_ID is null)))
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
      if (    (tlinfo.NAME = X_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR((tlinfo.description is null) and (x_description is null)))
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
  X_DEVICE_ID 			in NUMBER,
  X_DEVICE_TYPE_ID 		in NUMBER,
  X_ENABLED_FLAG 		in VARCHAR2,
  X_LOT_SERIAL_CAPABLE 		in VARCHAR2,
  X_INPUT_METHOD_ID 		in NUMBER,
  X_OUTPUT_METHOD_ID 		in NUMBER,
  X_BATCH_LIMIT 		in NUMBER,
  X_OUT_DIRECTORY 		in VARCHAR2,
  X_OUT_FILE_PREFIX 		in VARCHAR2,
  X_SUBINVENTORY_CODE		in VARCHAR2,
  X_ORGANIZATION_ID		in NUMBER,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1			in VARCHAR2,
  X_ATTRIBUTE2			in VARCHAR2,
  X_ATTRIBUTE3			in VARCHAR2,
  X_ATTRIBUTE4			in VARCHAR2,
  X_ATTRIBUTE5			in VARCHAR2,
  X_ATTRIBUTE6			in VARCHAR2,
  X_ATTRIBUTE7			in VARCHAR2,
  X_ATTRIBUTE8			in VARCHAR2,
  X_ATTRIBUTE9			in VARCHAR2,
  X_ATTRIBUTE10			in VARCHAR2,
  X_ATTRIBUTE11			in VARCHAR2,
  X_ATTRIBUTE12			in VARCHAR2,
  X_ATTRIBUTE13			in VARCHAR2,
  X_ATTRIBUTE14			in VARCHAR2,
  X_ATTRIBUTE15			in VARCHAR2,
  X_NAME 			in VARCHAR2,
  X_DESCRIPTION 		in VARCHAR2,
  X_LAST_UPDATE_DATE 		in DATE,
  X_LAST_UPDATED_BY 		in NUMBER,
  X_LAST_UPDATE_LOGIN 		in NUMBER,
  X_DEVICE_MODEL		in VARCHAR2,
  X_NOTIFICATION_FLAG		in VARCHAR2,
  X_FORCE_SIGN_ON_FLAG		in VARCHAR2,
  x_locator_id             IN number,
  x_multi_sign_on          IN VARCHAR2,
  x_message_template_id    IN NUMBER    --MHP
) is
begin
  update WMS_DEVICES_B set
    DEVICE_TYPE_ID 		= X_DEVICE_TYPE_ID,
    ENABLED_FLAG 		= X_ENABLED_FLAG,
    LOT_SERIAL_CAPABLE 		= X_LOT_SERIAL_CAPABLE,
    INPUT_METHOD_ID 		= X_INPUT_METHOD_ID,
    OUTPUT_METHOD_ID 		= X_OUTPUT_METHOD_ID,
    BATCH_LIMIT 		= X_BATCH_LIMIT,
    OUT_DIRECTORY 		= X_OUT_DIRECTORY,
    OUT_FILE_PREFIX 		= X_OUT_FILE_PREFIX,
    SUBINVENTORY_CODE		= X_SUBINVENTORY_CODE,
    ORGANIZATION_ID		= X_ORGANIZATION_ID,
    ATTRIBUTE_CATEGORY 		= X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1			= X_ATTRIBUTE1,
    ATTRIBUTE2			= X_ATTRIBUTE2,
    ATTRIBUTE3			= X_ATTRIBUTE3,
    ATTRIBUTE4			= X_ATTRIBUTE4,
    ATTRIBUTE5			= X_ATTRIBUTE5,
    ATTRIBUTE6			= X_ATTRIBUTE6,
    ATTRIBUTE7			= X_ATTRIBUTE7,
    ATTRIBUTE8			= X_ATTRIBUTE8,
    ATTRIBUTE9			= X_ATTRIBUTE9,
    ATTRIBUTE10			= X_ATTRIBUTE10,
    ATTRIBUTE11			= X_ATTRIBUTE11,
    ATTRIBUTE12			= X_ATTRIBUTE12,
    ATTRIBUTE13			= X_ATTRIBUTE13,
    ATTRIBUTE14			= X_ATTRIBUTE14,
    ATTRIBUTE15			= X_ATTRIBUTE15,
    LAST_UPDATE_DATE 		= X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY 		= X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN 		= X_LAST_UPDATE_LOGIN,
    DEVICE_MODEL		= X_DEVICE_MODEL,
    NOTIFICATION_FLAG		= X_NOTIFICATION_FLAG,
    FORCE_SIGN_ON_FLAG		= x_force_sign_on_flag,
    locator_id             = x_locator_id,
    multi_sign_on          = x_multi_sign_on,
    message_template_id    = x_message_template_id    --MHP
  where DEVICE_ID = X_DEVICE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WMS_DEVICES_TL set
    NAME 			= X_NAME,
    DESCRIPTION 		= X_DESCRIPTION,
    LAST_UPDATE_DATE 		= X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY 		= X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN 		= X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DEVICE_ID = X_DEVICE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DEVICE_ID in NUMBER
) is
begin
  delete from WMS_DEVICES_TL
  where DEVICE_ID = X_DEVICE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WMS_DEVICES_B
  where DEVICE_ID = X_DEVICE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from WMS_DEVICES_TL T
  where not exists
    (select NULL
    from WMS_DEVICES_B B
    where B.DEVICE_ID = T.DEVICE_ID
    );

  update WMS_DEVICES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from WMS_DEVICES_TL B
    where B.DEVICE_ID = T.DEVICE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DEVICE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DEVICE_ID,
      SUBT.LANGUAGE
    from WMS_DEVICES_TL SUBB, WMS_DEVICES_TL SUBT
    where SUBB.DEVICE_ID = SUBT.DEVICE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into WMS_DEVICES_TL (
    DEVICE_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DEVICE_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WMS_DEVICES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WMS_DEVICES_TL T
    where T.DEVICE_ID = B.DEVICE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

   FUNCTION is_wcs_enabled(p_org_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_is_wcs_enabled VARCHAR2(1);
   BEGIN
      SELECT nvl(wcs_enabled,'N')
         INTO l_is_wcs_enabled
         FROM mtl_parameters
         WHERE organization_id = p_org_id;
      RETURN l_is_wcs_enabled;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 'N';
   END is_wcs_enabled;

   FUNCTION is_device_multisignon(p_org_id IN NUMBER, p_device_name VARCHAR2)
      RETURN VARCHAR2
   IS
      l_is_dev_multisignon VARCHAR2(1);
   BEGIN
      SELECT nvl(multi_sign_on,'N')
         INTO l_is_dev_multisignon
         FROM wms_devices_vl
         WHERE organization_id = p_org_id
           AND name = p_device_name;
      RETURN l_is_dev_multisignon;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 'N';
   END is_device_multisignon;

end WMS_DEVICES_PKG;

/
