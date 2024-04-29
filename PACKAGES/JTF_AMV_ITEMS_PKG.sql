--------------------------------------------------------
--  DDL for Package JTF_AMV_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AMV_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: jtfvitms.pls 120.3 2005/11/28 08:42:29 vimohan ship $ */
procedure Load_Row(
  X_ITEM_ID in VARCHAR2,
  x_object_version_number in varchar2,
  X_STATUS_CODE in VARCHAR2,
  X_EFFECTIVE_START_DATE in VARCHAR2,
  X_EXPIRATION_DATE in VARCHAR2,
  X_APPLICATION_ID in VARCHAR2,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_PRIORITY in VARCHAR2,
  X_PUBLICATION_DATE in VARCHAR2,
  X_LANGUAGE_CODE in VARCHAR2,
  X_ITEM_TYPE in VARCHAR2,
  X_URL_STRING in VARCHAR2,
  X_CONTENT_TYPE_ID in VARCHAR2,
  X_OWNER_ID in VARCHAR2,
  X_DEFAULT_APPROVER_ID in VARCHAR2,
  X_ITEM_DESTINATION_TYPE in VARCHAR2,
  X_ACCESS_NAME in VARCHAR2,
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_APPLICABLE_TO_CODE in VARCHAR2,
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
  X_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT_STRING in VARCHAR2,
  x_owner  in  varchar2,
  X_CUSTOM_MODE in varchar2 default NULL,
  x_last_update_date in varchar2 default NULL
) ;
procedure Translate_row (
  X_ITEM_ID in NUMBER,
  X_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT_STRING in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2 DEFAULT NULL,
  X_LAST_UPDATE_DATE in VARCHAR2 DEFAULT NULL
) ;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT_STRING in VARCHAR2,
  X_LANGUAGE_CODE in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_ITEM_TYPE in VARCHAR2,
  X_URL_STRING in VARCHAR2,
  X_PUBLICATION_DATE in DATE,
  X_PRIORITY in VARCHAR2,
  X_CONTENT_TYPE_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_DEFAULT_APPROVER_ID in NUMBER,
  X_ITEM_DESTINATION_TYPE in VARCHAR2,
  X_ACCESS_NAME in VARCHAR2,
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_APPLICABLE_TO_CODE in VARCHAR2,
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
  X_ATTRIBUTE15 in VARCHAR2
);
procedure LOCK_ROW (
  X_ITEM_ID in NUMBER,
  X_PRIORITY in VARCHAR2,
  X_ACCESS_NAME in VARCHAR2,
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_APPLICABLE_TO_CODE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT_STRING in VARCHAR2,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_PUBLICATION_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LANGUAGE_CODE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_ITEM_TYPE in VARCHAR2,
  X_URL_STRING in VARCHAR2,
  X_CONTENT_TYPE_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_DEFAULT_APPROVER_ID in NUMBER,
  X_ITEM_DESTINATION_TYPE in VARCHAR2,
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
  X_ATTRIBUTE15 in VARCHAR2
);
procedure UPDATE_ROW (
  X_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_EXTERNAL_ACCESS_FLAG in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT_STRING in VARCHAR2,
  X_LANGUAGE_CODE in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_EXPIRATION_DATE in DATE,
  X_ITEM_TYPE in VARCHAR2,
  X_URL_STRING in VARCHAR2,
  X_PUBLICATION_DATE in DATE,
  X_PRIORITY in VARCHAR2,
  X_CONTENT_TYPE_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_DEFAULT_APPROVER_ID in NUMBER,
  X_ITEM_DESTINATION_TYPE in VARCHAR2,
  X_ACCESS_NAME in VARCHAR2,
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_APPLICABLE_TO_CODE in VARCHAR2,
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
  X_ATTRIBUTE15 in VARCHAR2
);
procedure DELETE_ROW (
  X_ITEM_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure LOAD_SEED_ROW(
  x_upload_mode       in varchar2,
  x_item_id           in varchar2,
  x_item_name         in varchar2,
  x_description       in varchar2,
  x_text_string       in varchar2,
  x_owner             in varchar2,
  x_object_version_number in varchar2,
  x_status_code           in varchar2,
  x_effective_start_date  in varchar2,
  x_expiration_date   in varchar2,
  x_application_id    in varchar2,
  x_external_access_flag  in varchar2,
  x_priority          in varchar2,
  x_publication_date  in varchar2,
  x_language_code     in varchar2,
  x_item_type         in varchar2,
  x_url_string        in varchar2,
  x_content_type_id   in varchar2,
  x_owner_id          in varchar2,
  x_default_approver_id     in varchar2,
  x_item_destination_type   in varchar2,
  x_access_name             in varchar2,
  x_deliverable_type_code   in varchar2,
  x_applicable_to_code      in varchar2,
  x_attribute_category      in varchar2,
  x_attribute1  in varchar2,
  x_attribute2  in varchar2,
  x_attribute3  in varchar2,
  x_attribute4  in varchar2,
  x_attribute5  in varchar2,
  x_attribute6  in varchar2,
  x_attribute7  in varchar2,
  x_attribute8  in varchar2,
  x_attribute9  in varchar2,
  x_attribute10  in varchar2,
  x_attribute11  in varchar2,
  x_attribute12  in varchar2,
  x_attribute13  in varchar2,
  x_attribute14  in varchar2,
  x_attribute15  in varchar2,
  x_custom_mode             in varchar2,
  x_last_update_date        in varchar2
  );

end JTF_AMV_ITEMS_PKG;


 

/