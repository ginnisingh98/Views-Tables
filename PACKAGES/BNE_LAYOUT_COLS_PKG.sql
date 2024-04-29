--------------------------------------------------------
--  DDL for Package BNE_LAYOUT_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_LAYOUT_COLS_PKG" AUTHID CURRENT_USER as
/* $Header: bnelaycols.pls 120.3 2005/08/18 07:45:04 dagroves noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_SEQ_NUM in NUMBER,
  X_STYLE_CLASS in VARCHAR2,
  X_HINT_STYLE in VARCHAR2,
  X_HINT_STYLE_CLASS in VARCHAR2,
  X_PROMPT_STYLE in VARCHAR2,
  X_PROMPT_STYLE_CLASS in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_WIDTH in NUMBER DEFAULT NULL,
  X_READ_ONLY_FLAG in VARCHAR2 DEFAULT NULL);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_SEQ_NUM in NUMBER,
  X_STYLE_CLASS in VARCHAR2,
  X_HINT_STYLE in VARCHAR2,
  X_HINT_STYLE_CLASS in VARCHAR2,
  X_PROMPT_STYLE in VARCHAR2,
  X_PROMPT_STYLE_CLASS in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_DISPLAY_WIDTH in NUMBER DEFAULT NULL,
  X_READ_ONLY_FLAG in VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_SEQ_NUM in NUMBER,
  X_STYLE_CLASS in VARCHAR2,
  X_HINT_STYLE in VARCHAR2,
  X_HINT_STYLE_CLASS in VARCHAR2,
  X_PROMPT_STYLE in VARCHAR2,
  X_PROMPT_STYLE_CLASS in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_WIDTH in NUMBER DEFAULT NULL,
  X_READ_ONLY_FLAG in VARCHAR2 DEFAULT NULL
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER,
  X_SEQUENCE_NUM in NUMBER
);
procedure ADD_LANGUAGE;
procedure LOAD_ROW(
  x_layout_asn                  in VARCHAR2,
  x_layout_code                 in VARCHAR2,
  x_block_id                    in VARCHAR2,
  x_sequence_num                in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_interface_asn               in VARCHAR2,
  x_interface_code              in VARCHAR2,
  x_interface_seq_num           in VARCHAR2,
  x_style_class                 in VARCHAR2,
  x_hint_style                  in VARCHAR2,
  x_hint_style_class            in VARCHAR2,
  x_prompt_style                in VARCHAR2,
  x_prompt_style_class          in VARCHAR2,
  x_default_type                in VARCHAR2,
  x_default_value               in VARCHAR2,
  x_style                       in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2,
  x_display_width               in VARCHAR2 DEFAULT NULL,
  x_read_only_flag              in VARCHAR2 DEFAULT NULL
);

end BNE_LAYOUT_COLS_PKG;

 

/
