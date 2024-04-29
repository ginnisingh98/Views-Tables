--------------------------------------------------------
--  DDL for Package FND_SVC_COMP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SVC_COMP_TYPES_PKG" authid current_user as
/* $Header: AFSVCTTS.pls 115.2 2002/12/10 21:11:49 ankung noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_CLASS_NAME in VARCHAR2,
  X_CONFIG_UI_REGION in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER default 1,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE default sysdate,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE default sysdate,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_CLASS_NAME in VARCHAR2,
  X_CONFIG_UI_REGION in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);

procedure UPDATE_ROW (
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_CLASS_NAME in VARCHAR2,
  X_CONFIG_UI_REGION in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE default sysdate,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_COMPONENT_TYPE in VARCHAR2
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW (
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_CLASS_NAME in VARCHAR2,
  X_CONFIG_UI_REGION in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
);

procedure TRANSLATE_ROW (
  X_COMPONENT_TYPE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
);

end FND_SVC_COMP_TYPES_PKG;

 

/