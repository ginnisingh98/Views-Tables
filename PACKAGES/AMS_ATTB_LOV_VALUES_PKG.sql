--------------------------------------------------------
--  DDL for Package AMS_ATTB_LOV_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ATTB_LOV_VALUES_PKG" AUTHID CURRENT_USER as
/* $Header: amstatvs.pls 120.1 2005/06/27 05:39:40 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_ATTB_LOV_VALUE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_VALUE_CODE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_VALUE_MEANING in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
);
procedure LOCK_ROW (
  X_ATTB_LOV_VALUE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_VALUE_CODE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_VALUE_MEANING in VARCHAR2,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
);
procedure UPDATE_ROW (
  X_ATTB_LOV_VALUE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_VALUE_CODE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_VALUE_MEANING in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
);
procedure DELETE_ROW (
  X_ATTB_LOV_VALUE_ID in NUMBER
);
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW(
  X_ATTB_LOV_VALUE_ID in NUMBER,
  X_VALUE_MEANING in VARCHAR2,
  x_owner   in VARCHAR2,
  x_custom_mode in VARCHAR2
 ) ;

 procedure LOAD_ROW (
  X_ATTB_LOV_VALUE_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_VALUE_CODE in VARCHAR2,
  X_VALUE_MEANING in VARCHAR2,
  X_OWNER in VARCHAR2,
  x_custom_mode in VARCHAR2
);


end AMS_ATTB_LOV_VALUES_PKG;

 

/
