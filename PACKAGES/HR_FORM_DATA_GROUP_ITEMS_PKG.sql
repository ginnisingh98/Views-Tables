--------------------------------------------------------
--  DDL for Package HR_FORM_DATA_GROUP_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_DATA_GROUP_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: hrfgilct.pkh 115.2 2002/12/10 10:54:28 hjonnala noship $ */
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
);
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FORM_DATA_GROUP_ITEM_ID in NUMBER,
  X_FORM_DATA_GROUP_ID in NUMBER,
  X_FORM_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_FORM_DATA_GROUP_ITEM_ID in NUMBER,
  X_FORM_DATA_GROUP_ID in NUMBER,
  X_FORM_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);
procedure UPDATE_ROW (
  X_FORM_DATA_GROUP_ITEM_ID in NUMBER,
  X_FORM_DATA_GROUP_ID in NUMBER,
  X_FORM_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
--  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_FORM_DATA_GROUP_ITEM_ID in NUMBER
);
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_DATA_GROUP_NAME in VARCHAR2,
  X_FULL_ITEM_NAME in VARCHAR2,
  X_RADIO_BUTTON_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in VARCHAR2);

end HR_FORM_DATA_GROUP_ITEMS_PKG;

 

/