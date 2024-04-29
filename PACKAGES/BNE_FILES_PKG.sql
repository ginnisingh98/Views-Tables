--------------------------------------------------------
--  DDL for Package BNE_FILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_FILES_PKG" AUTHID CURRENT_USER as
/* $Header: bnefiles.pls 120.2 2005/06/29 03:39:57 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_USER_FILE_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MIDDLE_TIER_FILE_NAME in VARCHAR2,
  X_START_LINE in NUMBER,
  X_COLUMN_DELIMITER_CHAR in VARCHAR2,
  X_IGNORE_CONSEC_DELIMS_FLAG in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_USER_FILE_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MIDDLE_TIER_FILE_NAME in VARCHAR2,
  X_START_LINE in NUMBER,
  X_COLUMN_DELIMITER_CHAR in VARCHAR2,
  X_IGNORE_CONSEC_DELIMS_FLAG in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_USER_FILE_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MIDDLE_TIER_FILE_NAME in VARCHAR2,
  X_START_LINE in NUMBER,
  X_COLUMN_DELIMITER_CHAR in VARCHAR2,
  X_IGNORE_CONSEC_DELIMS_FLAG in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_USER_FILE_NAME in VARCHAR2
);
procedure ADD_LANGUAGE;
procedure LOAD_ROW(
  x_content_asn                 in VARCHAR2,
  x_content_code                in VARCHAR2,
  x_user_file_name              in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_middle_tier_file_name       in VARCHAR2,
  x_start_line                  in VARCHAR2,
  x_column_delimiter_char       in VARCHAR2,
  x_ignore_consec_delims_flag   in VARCHAR2,
  x_sequence_num                in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
);

end BNE_FILES_PKG;

 

/
