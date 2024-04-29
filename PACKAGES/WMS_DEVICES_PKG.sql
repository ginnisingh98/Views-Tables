--------------------------------------------------------
--  DDL for Package WMS_DEVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_DEVICES_PKG" AUTHID CURRENT_USER as
/* $Header: WMSDEVDS.pls 120.1 2005/07/21 13:35:06 simran noship $ */
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
  X_ATTRIBUTE1 			in VARCHAR2,
  X_ATTRIBUTE2 			in VARCHAR2,
  X_ATTRIBUTE3 			in VARCHAR2,
  X_ATTRIBUTE4 			in VARCHAR2,
  X_ATTRIBUTE5 			in VARCHAR2,
  X_ATTRIBUTE6 			in VARCHAR2,
  X_ATTRIBUTE7 			in VARCHAR2,
  X_ATTRIBUTE8 			in VARCHAR2,
  X_ATTRIBUTE9 			in VARCHAR2,
  X_ATTRIBUTE10 		in VARCHAR2,
  X_ATTRIBUTE11 		in VARCHAR2,
  X_ATTRIBUTE12 		in VARCHAR2,
  X_ATTRIBUTE13 		in VARCHAR2,
  X_ATTRIBUTE14 		in VARCHAR2,
  X_ATTRIBUTE15 		in VARCHAR2,
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
  );


procedure LOCK_ROW (
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
  );


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
  X_ATTRIBUTE1 			in VARCHAR2,
  X_ATTRIBUTE2 			in VARCHAR2,
  X_ATTRIBUTE3 			in VARCHAR2,
  X_ATTRIBUTE4 			in VARCHAR2,
  X_ATTRIBUTE5 			in VARCHAR2,
  X_ATTRIBUTE6 			in VARCHAR2,
  X_ATTRIBUTE7 			in VARCHAR2,
  X_ATTRIBUTE8 			in VARCHAR2,
  X_ATTRIBUTE9 			in VARCHAR2,
  X_ATTRIBUTE10 		in VARCHAR2,
  X_ATTRIBUTE11 		in VARCHAR2,
  X_ATTRIBUTE12 		in VARCHAR2,
  X_ATTRIBUTE13 		in VARCHAR2,
  X_ATTRIBUTE14 		in VARCHAR2,
  X_ATTRIBUTE15 		in VARCHAR2,
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
  x_message_template_id    IN NUMBER
  );

procedure DELETE_ROW (
  X_DEVICE_ID 			in NUMBER);

procedure ADD_LANGUAGE;

FUNCTION is_wcs_enabled(p_org_id IN NUMBER)
   RETURN VARCHAR2;

FUNCTION is_device_multisignon(p_org_id IN NUMBER,
                               p_device_name VARCHAR2)
   RETURN VARCHAR2;

end WMS_DEVICES_PKG;

 

/