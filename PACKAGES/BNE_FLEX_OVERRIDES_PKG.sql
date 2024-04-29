--------------------------------------------------------
--  DDL for Package BNE_FLEX_OVERRIDES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_FLEX_OVERRIDES_PKG" AUTHID CURRENT_USER as
/* $Header: bneflexovers.pls 120.2 2005/06/29 03:39:58 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_OA_FLEX_APPLICATION_ID in NUMBER,
  X_OA_FLEX_CODE in VARCHAR2,
  X_OA_FLEX_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_OA_FLEX_APPLICATION_ID in NUMBER,
  X_OA_FLEX_CODE in VARCHAR2,
  X_OA_FLEX_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  X_OA_FLEX_APPLICATION_ID in NUMBER,
  X_OA_FLEX_CODE in VARCHAR2,
  X_OA_FLEX_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_OA_FLEX_APPLICATION_ID in NUMBER,
  X_OA_FLEX_CODE in VARCHAR2,
  X_OA_FLEX_NUM in NUMBER
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW(
  x_oa_flex_application_asn     in VARCHAR2,
  x_oa_flex_code                in VARCHAR2,
  x_oa_flex_num                 in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
);

end BNE_FLEX_OVERRIDES_PKG;

 

/
