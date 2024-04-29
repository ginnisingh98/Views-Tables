--------------------------------------------------------
--  DDL for Package IEC_P_RES_GRP_CAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_P_RES_GRP_CAPS_PKG" AUTHID CURRENT_USER as
/* $Header: IECHRGCS.pls 115.12 2004/08/06 15:40:57 minwang ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RES_GROUP_CAP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CAP_CODE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_VALUE_LENGTH in VARCHAR2,
  X_CAP_NAME in VARCHAR2,
  X_CAP_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_RES_GROUP_CAP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CAP_CODE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_VALUE_LENGTH in VARCHAR2,
  X_CAP_NAME in VARCHAR2,
  X_CAP_DESCRIPTION in VARCHAR2
);

procedure UPDATE_ROW (
  X_RES_GROUP_CAP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CAP_CODE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_VALUE_LENGTH in VARCHAR2,
  X_CAP_NAME in VARCHAR2,
  X_CAP_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_RES_GROUP_CAP_ID in NUMBER
);

procedure LOAD_ROW (
  X_RES_GROUP_CAP_ID in NUMBER,
  X_CAP_CODE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_VALUE_LENGTH in VARCHAR2,
  X_CAP_NAME in VARCHAR2,
  X_CAP_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_RES_GROUP_CAP_ID in NUMBER,
  X_CAP_NAME in VARCHAR2,
  X_CAP_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
);
end IEC_P_RES_GRP_CAPS_PKG;


 

/