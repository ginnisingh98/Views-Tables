--------------------------------------------------------
--  DDL for Package FEM_DIS_USR_DIM1_HIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIS_USR_DIM1_HIER_PKG" AUTHID CURRENT_USER as
/* $Header: fem_disusrd1_pkh.pls 120.0 2005/10/19 19:23:50 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_OBJECT_DEFINITION_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_LEVEL1_ID in NUMBER,
  X_LEVEL2_ID in NUMBER,
  X_LEVEL3_ID in NUMBER,
  X_LEVEL4_ID in NUMBER,
  X_LEVEL5_ID in NUMBER,
  X_LEVEL6_ID in NUMBER,
  X_LEVEL7_ID in NUMBER,
  X_LEVEL8_ID in NUMBER,
  X_LEVEL9_ID in NUMBER,
  X_LEVEL10_ID in NUMBER,
  X_LEVEL11_ID in NUMBER,
  X_LEVEL12_ID in NUMBER,
  X_LEVEL13_ID in NUMBER,
  X_LEVEL14_ID in NUMBER,
  X_LEVEL15_ID in NUMBER,
  X_LEVEL16_ID in NUMBER,
  X_LEVEL17_ID in NUMBER,
  X_LEVEL18_ID in NUMBER,
  X_LEVEL19_ID in NUMBER,
  X_LEVEL20_ID in NUMBER,
  X_LEVEL1_DISPLAY_CODE in VARCHAR2,
  X_LEVEL2_DISPLAY_CODE in VARCHAR2,
  X_LEVEL3_DISPLAY_CODE in VARCHAR2,
  X_LEVEL4_DISPLAY_CODE in VARCHAR2,
  X_LEVEL5_DISPLAY_CODE in VARCHAR2,
  X_LEVEL6_DISPLAY_CODE in VARCHAR2,
  X_LEVEL7_DISPLAY_CODE in VARCHAR2,
  X_LEVEL8_DISPLAY_CODE in VARCHAR2,
  X_LEVEL9_DISPLAY_CODE in VARCHAR2,
  X_LEVEL10_DISPLAY_CODE in VARCHAR2,
  X_LEVEL11_DISPLAY_CODE in VARCHAR2,
  X_LEVEL12_DISPLAY_CODE in VARCHAR2,
  X_LEVEL13_DISPLAY_CODE in VARCHAR2,
  X_LEVEL14_DISPLAY_CODE in VARCHAR2,
  X_LEVEL15_DISPLAY_CODE in VARCHAR2,
  X_LEVEL16_DISPLAY_CODE in VARCHAR2,
  X_LEVEL17_DISPLAY_CODE in VARCHAR2,
  X_LEVEL18_DISPLAY_CODE in VARCHAR2,
  X_LEVEL19_DISPLAY_CODE in VARCHAR2,
  X_LEVEL20_DISPLAY_CODE in VARCHAR2,
  X_LEVEL1_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL2_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL3_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL4_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL5_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL6_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL7_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL8_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL9_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL10_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL11_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL12_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL13_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL14_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL15_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL16_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL17_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL18_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL19_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL20_DISPLAY_ORDER_NUM in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_OBJECT_DEFINITION_NAME in VARCHAR2,
  X_LEVEL1_NAME in VARCHAR2,
  X_LEVEL2_NAME in VARCHAR2,
  X_LEVEL3_NAME in VARCHAR2,
  X_LEVEL4_NAME in VARCHAR2,
  X_LEVEL5_NAME in VARCHAR2,
  X_LEVEL6_NAME in VARCHAR2,
  X_LEVEL7_NAME in VARCHAR2,
  X_LEVEL8_NAME in VARCHAR2,
  X_LEVEL9_NAME in VARCHAR2,
  X_LEVEL10_NAME in VARCHAR2,
  X_LEVEL11_NAME in VARCHAR2,
  X_LEVEL12_NAME in VARCHAR2,
  X_LEVEL13_NAME in VARCHAR2,
  X_LEVEL14_NAME in VARCHAR2,
  X_LEVEL15_NAME in VARCHAR2,
  X_LEVEL16_NAME in VARCHAR2,
  X_LEVEL17_NAME in VARCHAR2,
  X_LEVEL18_NAME in VARCHAR2,
  X_LEVEL19_NAME in VARCHAR2,
  X_LEVEL20_NAME in VARCHAR2,
  X_LEVEL1_DESCRIPTION in VARCHAR2,
  X_LEVEL2_DESCRIPTION in VARCHAR2,
  X_LEVEL3_DESCRIPTION in VARCHAR2,
  X_LEVEL4_DESCRIPTION in VARCHAR2,
  X_LEVEL5_DESCRIPTION in VARCHAR2,
  X_LEVEL6_DESCRIPTION in VARCHAR2,
  X_LEVEL7_DESCRIPTION in VARCHAR2,
  X_LEVEL8_DESCRIPTION in VARCHAR2,
  X_LEVEL9_DESCRIPTION in VARCHAR2,
  X_LEVEL10_DESCRIPTION in VARCHAR2,
  X_LEVEL11_DESCRIPTION in VARCHAR2,
  X_LEVEL12_DESCRIPTION in VARCHAR2,
  X_LEVEL13_DESCRIPTION in VARCHAR2,
  X_LEVEL14_DESCRIPTION in VARCHAR2,
  X_LEVEL15_DESCRIPTION in VARCHAR2,
  X_LEVEL16_DESCRIPTION in VARCHAR2,
  X_LEVEL17_DESCRIPTION in VARCHAR2,
  X_LEVEL18_DESCRIPTION in VARCHAR2,
  X_LEVEL19_DESCRIPTION in VARCHAR2,
  X_LEVEL20_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_OBJECT_ID in NUMBER,
  X_OBJECT_DEFINITION_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_LEVEL1_ID in NUMBER,
  X_LEVEL2_ID in NUMBER,
  X_LEVEL3_ID in NUMBER,
  X_LEVEL4_ID in NUMBER,
  X_LEVEL5_ID in NUMBER,
  X_LEVEL6_ID in NUMBER,
  X_LEVEL7_ID in NUMBER,
  X_LEVEL8_ID in NUMBER,
  X_LEVEL9_ID in NUMBER,
  X_LEVEL10_ID in NUMBER,
  X_LEVEL11_ID in NUMBER,
  X_LEVEL12_ID in NUMBER,
  X_LEVEL13_ID in NUMBER,
  X_LEVEL14_ID in NUMBER,
  X_LEVEL15_ID in NUMBER,
  X_LEVEL16_ID in NUMBER,
  X_LEVEL17_ID in NUMBER,
  X_LEVEL18_ID in NUMBER,
  X_LEVEL19_ID in NUMBER,
  X_LEVEL20_ID in NUMBER,
  X_LEVEL1_DISPLAY_CODE in VARCHAR2,
  X_LEVEL2_DISPLAY_CODE in VARCHAR2,
  X_LEVEL3_DISPLAY_CODE in VARCHAR2,
  X_LEVEL4_DISPLAY_CODE in VARCHAR2,
  X_LEVEL5_DISPLAY_CODE in VARCHAR2,
  X_LEVEL6_DISPLAY_CODE in VARCHAR2,
  X_LEVEL7_DISPLAY_CODE in VARCHAR2,
  X_LEVEL8_DISPLAY_CODE in VARCHAR2,
  X_LEVEL9_DISPLAY_CODE in VARCHAR2,
  X_LEVEL10_DISPLAY_CODE in VARCHAR2,
  X_LEVEL11_DISPLAY_CODE in VARCHAR2,
  X_LEVEL12_DISPLAY_CODE in VARCHAR2,
  X_LEVEL13_DISPLAY_CODE in VARCHAR2,
  X_LEVEL14_DISPLAY_CODE in VARCHAR2,
  X_LEVEL15_DISPLAY_CODE in VARCHAR2,
  X_LEVEL16_DISPLAY_CODE in VARCHAR2,
  X_LEVEL17_DISPLAY_CODE in VARCHAR2,
  X_LEVEL18_DISPLAY_CODE in VARCHAR2,
  X_LEVEL19_DISPLAY_CODE in VARCHAR2,
  X_LEVEL20_DISPLAY_CODE in VARCHAR2,
  X_LEVEL1_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL2_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL3_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL4_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL5_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL6_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL7_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL8_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL9_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL10_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL11_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL12_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL13_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL14_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL15_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL16_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL17_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL18_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL19_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL20_DISPLAY_ORDER_NUM in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_OBJECT_DEFINITION_NAME in VARCHAR2,
  X_LEVEL1_NAME in VARCHAR2,
  X_LEVEL2_NAME in VARCHAR2,
  X_LEVEL3_NAME in VARCHAR2,
  X_LEVEL4_NAME in VARCHAR2,
  X_LEVEL5_NAME in VARCHAR2,
  X_LEVEL6_NAME in VARCHAR2,
  X_LEVEL7_NAME in VARCHAR2,
  X_LEVEL8_NAME in VARCHAR2,
  X_LEVEL9_NAME in VARCHAR2,
  X_LEVEL10_NAME in VARCHAR2,
  X_LEVEL11_NAME in VARCHAR2,
  X_LEVEL12_NAME in VARCHAR2,
  X_LEVEL13_NAME in VARCHAR2,
  X_LEVEL14_NAME in VARCHAR2,
  X_LEVEL15_NAME in VARCHAR2,
  X_LEVEL16_NAME in VARCHAR2,
  X_LEVEL17_NAME in VARCHAR2,
  X_LEVEL18_NAME in VARCHAR2,
  X_LEVEL19_NAME in VARCHAR2,
  X_LEVEL20_NAME in VARCHAR2,
  X_LEVEL1_DESCRIPTION in VARCHAR2,
  X_LEVEL2_DESCRIPTION in VARCHAR2,
  X_LEVEL3_DESCRIPTION in VARCHAR2,
  X_LEVEL4_DESCRIPTION in VARCHAR2,
  X_LEVEL5_DESCRIPTION in VARCHAR2,
  X_LEVEL6_DESCRIPTION in VARCHAR2,
  X_LEVEL7_DESCRIPTION in VARCHAR2,
  X_LEVEL8_DESCRIPTION in VARCHAR2,
  X_LEVEL9_DESCRIPTION in VARCHAR2,
  X_LEVEL10_DESCRIPTION in VARCHAR2,
  X_LEVEL11_DESCRIPTION in VARCHAR2,
  X_LEVEL12_DESCRIPTION in VARCHAR2,
  X_LEVEL13_DESCRIPTION in VARCHAR2,
  X_LEVEL14_DESCRIPTION in VARCHAR2,
  X_LEVEL15_DESCRIPTION in VARCHAR2,
  X_LEVEL16_DESCRIPTION in VARCHAR2,
  X_LEVEL17_DESCRIPTION in VARCHAR2,
  X_LEVEL18_DESCRIPTION in VARCHAR2,
  X_LEVEL19_DESCRIPTION in VARCHAR2,
  X_LEVEL20_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_OBJECT_ID in NUMBER,
  X_OBJECT_DEFINITION_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_LEVEL1_ID in NUMBER,
  X_LEVEL2_ID in NUMBER,
  X_LEVEL3_ID in NUMBER,
  X_LEVEL4_ID in NUMBER,
  X_LEVEL5_ID in NUMBER,
  X_LEVEL6_ID in NUMBER,
  X_LEVEL7_ID in NUMBER,
  X_LEVEL8_ID in NUMBER,
  X_LEVEL9_ID in NUMBER,
  X_LEVEL10_ID in NUMBER,
  X_LEVEL11_ID in NUMBER,
  X_LEVEL12_ID in NUMBER,
  X_LEVEL13_ID in NUMBER,
  X_LEVEL14_ID in NUMBER,
  X_LEVEL15_ID in NUMBER,
  X_LEVEL16_ID in NUMBER,
  X_LEVEL17_ID in NUMBER,
  X_LEVEL18_ID in NUMBER,
  X_LEVEL19_ID in NUMBER,
  X_LEVEL20_ID in NUMBER,
  X_LEVEL1_DISPLAY_CODE in VARCHAR2,
  X_LEVEL2_DISPLAY_CODE in VARCHAR2,
  X_LEVEL3_DISPLAY_CODE in VARCHAR2,
  X_LEVEL4_DISPLAY_CODE in VARCHAR2,
  X_LEVEL5_DISPLAY_CODE in VARCHAR2,
  X_LEVEL6_DISPLAY_CODE in VARCHAR2,
  X_LEVEL7_DISPLAY_CODE in VARCHAR2,
  X_LEVEL8_DISPLAY_CODE in VARCHAR2,
  X_LEVEL9_DISPLAY_CODE in VARCHAR2,
  X_LEVEL10_DISPLAY_CODE in VARCHAR2,
  X_LEVEL11_DISPLAY_CODE in VARCHAR2,
  X_LEVEL12_DISPLAY_CODE in VARCHAR2,
  X_LEVEL13_DISPLAY_CODE in VARCHAR2,
  X_LEVEL14_DISPLAY_CODE in VARCHAR2,
  X_LEVEL15_DISPLAY_CODE in VARCHAR2,
  X_LEVEL16_DISPLAY_CODE in VARCHAR2,
  X_LEVEL17_DISPLAY_CODE in VARCHAR2,
  X_LEVEL18_DISPLAY_CODE in VARCHAR2,
  X_LEVEL19_DISPLAY_CODE in VARCHAR2,
  X_LEVEL20_DISPLAY_CODE in VARCHAR2,
  X_LEVEL1_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL2_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL3_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL4_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL5_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL6_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL7_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL8_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL9_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL10_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL11_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL12_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL13_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL14_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL15_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL16_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL17_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL18_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL19_DISPLAY_ORDER_NUM in NUMBER,
  X_LEVEL20_DISPLAY_ORDER_NUM in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_OBJECT_DEFINITION_NAME in VARCHAR2,
  X_LEVEL1_NAME in VARCHAR2,
  X_LEVEL2_NAME in VARCHAR2,
  X_LEVEL3_NAME in VARCHAR2,
  X_LEVEL4_NAME in VARCHAR2,
  X_LEVEL5_NAME in VARCHAR2,
  X_LEVEL6_NAME in VARCHAR2,
  X_LEVEL7_NAME in VARCHAR2,
  X_LEVEL8_NAME in VARCHAR2,
  X_LEVEL9_NAME in VARCHAR2,
  X_LEVEL10_NAME in VARCHAR2,
  X_LEVEL11_NAME in VARCHAR2,
  X_LEVEL12_NAME in VARCHAR2,
  X_LEVEL13_NAME in VARCHAR2,
  X_LEVEL14_NAME in VARCHAR2,
  X_LEVEL15_NAME in VARCHAR2,
  X_LEVEL16_NAME in VARCHAR2,
  X_LEVEL17_NAME in VARCHAR2,
  X_LEVEL18_NAME in VARCHAR2,
  X_LEVEL19_NAME in VARCHAR2,
  X_LEVEL20_NAME in VARCHAR2,
  X_LEVEL1_DESCRIPTION in VARCHAR2,
  X_LEVEL2_DESCRIPTION in VARCHAR2,
  X_LEVEL3_DESCRIPTION in VARCHAR2,
  X_LEVEL4_DESCRIPTION in VARCHAR2,
  X_LEVEL5_DESCRIPTION in VARCHAR2,
  X_LEVEL6_DESCRIPTION in VARCHAR2,
  X_LEVEL7_DESCRIPTION in VARCHAR2,
  X_LEVEL8_DESCRIPTION in VARCHAR2,
  X_LEVEL9_DESCRIPTION in VARCHAR2,
  X_LEVEL10_DESCRIPTION in VARCHAR2,
  X_LEVEL11_DESCRIPTION in VARCHAR2,
  X_LEVEL12_DESCRIPTION in VARCHAR2,
  X_LEVEL13_DESCRIPTION in VARCHAR2,
  X_LEVEL14_DESCRIPTION in VARCHAR2,
  X_LEVEL15_DESCRIPTION in VARCHAR2,
  X_LEVEL16_DESCRIPTION in VARCHAR2,
  X_LEVEL17_DESCRIPTION in VARCHAR2,
  X_LEVEL18_DESCRIPTION in VARCHAR2,
  X_LEVEL19_DESCRIPTION in VARCHAR2,
  X_LEVEL20_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_OBJECT_ID in NUMBER,
  X_OBJECT_DEFINITION_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_LEVEL1_ID in NUMBER,
  X_LEVEL2_ID in NUMBER,
  X_LEVEL3_ID in NUMBER,
  X_LEVEL4_ID in NUMBER,
  X_LEVEL5_ID in NUMBER,
  X_LEVEL6_ID in NUMBER,
  X_LEVEL7_ID in NUMBER,
  X_LEVEL8_ID in NUMBER,
  X_LEVEL9_ID in NUMBER,
  X_LEVEL10_ID in NUMBER,
  X_LEVEL11_ID in NUMBER,
  X_LEVEL12_ID in NUMBER,
  X_LEVEL13_ID in NUMBER,
  X_LEVEL14_ID in NUMBER,
  X_LEVEL15_ID in NUMBER,
  X_LEVEL16_ID in NUMBER,
  X_LEVEL17_ID in NUMBER,
  X_LEVEL18_ID in NUMBER,
  X_LEVEL19_ID in NUMBER,
  X_LEVEL20_ID in NUMBER
);
procedure ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_OBJECT_ID in number,
        x_OBJECT_DEFINITION_ID in number,
        x_VALUE_SET_ID in number,
        x_LEVEL1_ID in number,
        x_LEVEL2_ID in number,
        x_LEVEL3_ID in number,
        x_LEVEL4_ID in number,
        x_LEVEL5_ID in number,
        x_LEVEL6_ID in number,
        x_LEVEL7_ID in number,
        x_LEVEL8_ID in number,
        x_LEVEL9_ID in number,
        x_LEVEL10_ID in number,
        x_LEVEL11_ID in number,
        x_LEVEL12_ID in number,
        x_LEVEL13_ID in number,
        x_LEVEL14_ID in number,
        x_LEVEL15_ID in number,
        x_LEVEL16_ID in number,
        x_LEVEL17_ID in number,
        x_LEVEL18_ID in number,
        x_LEVEL19_ID in number,
        x_LEVEL20_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_OBJECT_NAME in varchar2,
        x_OBJECT_DEFINITION_NAME in varchar2,
        x_LEVEL1_NAME in varchar2,
        x_LEVEL2_NAME in varchar2,
        x_LEVEL3_NAME in varchar2,
        x_LEVEL4_NAME in varchar2,
        x_LEVEL5_NAME in varchar2,
        x_LEVEL6_NAME in varchar2,
        x_LEVEL7_NAME in varchar2,
        x_LEVEL8_NAME in varchar2,
        x_LEVEL9_NAME in varchar2,
        x_LEVEL10_NAME in varchar2,
        x_LEVEL11_NAME in varchar2,
        x_LEVEL12_NAME in varchar2,
        x_LEVEL13_NAME in varchar2,
        x_LEVEL14_NAME in varchar2,
        x_LEVEL15_NAME in varchar2,
        x_LEVEL16_NAME in varchar2,
        x_LEVEL17_NAME in varchar2,
        x_LEVEL18_NAME in varchar2,
        x_LEVEL19_NAME in varchar2,
        x_LEVEL20_NAME in varchar2,
        x_custom_mode in varchar2);


end FEM_DIS_USR_DIM1_HIER_PKG;

 

/
