--------------------------------------------------------
--  DDL for Package EDW_FLEX_SEG_MAPPING_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_FLEX_SEG_MAPPING_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: EDWFMLIS.pls 115.1 99/07/17 16:18:40 porting ship  $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_SEG_MAPPING_LINE_ID in NUMBER,
  X_INSTANCE_CODE in VARCHAR2,
  X_STRUCTURE_NUM in NUMBER,
  X_STRUCTURE_NAME in VARCHAR2,
  X_VALUE_SET_ID in NUMBER,
  X_SEGMENT_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_LEVEL_ID  in NUMBER,
  X_WH_DIMENSION_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);


procedure LOCK_ROW (
  X_SEG_MAPPING_LINE_ID in NUMBER,
  X_INSTANCE_CODE in VARCHAR2,
  X_STRUCTURE_NUM in NUMBER,
  X_STRUCTURE_NAME in VARCHAR2,
  X_VALUE_SET_ID in NUMBER,
  X_SEGMENT_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_LEVEL_ID  in NUMBER,
  X_WH_DIMENSION_NAME in VARCHAR2
);



procedure UPDATE_ROW (
  X_SEG_MAPPING_LINE_ID in NUMBER,
  X_INSTANCE_CODE in VARCHAR2,
  X_STRUCTURE_NUM in NUMBER,
  X_STRUCTURE_NAME in VARCHAR2,
  X_VALUE_SET_ID in NUMBER,
  X_SEGMENT_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_LEVEL_ID  in NUMBER,
  X_WH_DIMENSION_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);



procedure DELETE_ROW (
  X_SEG_MAPPING_LINE_ID in NUMBER
);


end EDW_FLEX_SEG_MAPPING_LINES_PKG;

 

/