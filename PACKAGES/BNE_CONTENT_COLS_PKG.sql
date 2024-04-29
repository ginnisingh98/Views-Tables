--------------------------------------------------------
--  DDL for Package BNE_CONTENT_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_CONTENT_COLS_PKG" AUTHID CURRENT_USER as
/* $Header: bnecntcs.pls 120.3 2005/07/27 03:17:21 dagroves noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_COL_NAME in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2 DEFAULT NULL
);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_COL_NAME in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_COL_NAME in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2 DEFAULT NULL
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER
);
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW(
  x_content_asn           in VARCHAR2,
  x_content_code          in VARCHAR2,
  x_sequence_num          in VARCHAR2,
  x_user_name             in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2
);
procedure LOAD_ROW(
  x_content_asn           in VARCHAR2,
  x_content_code          in VARCHAR2,
  x_sequence_num          in VARCHAR2,
  x_object_version_number in VARCHAR2,
  x_col_name              in VARCHAR2,
  x_user_name             in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2,
  x_read_only_flag        in VARCHAR2 DEFAULT NULL
);

end BNE_CONTENT_COLS_PKG;

 

/
