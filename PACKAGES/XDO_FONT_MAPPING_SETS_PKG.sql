--------------------------------------------------------
--  DDL for Package XDO_FONT_MAPPING_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_FONT_MAPPING_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: XDOFNTSS.pls 120.0 2005/09/01 20:26:20 bokim noship $ */

procedure INSERT_ROW (
          P_MAPPING_CODE in VARCHAR2,
          P_MAPPING_NAME in VARCHAR2,
          P_MAPPING_TYPE  in VARCHAR2,
          P_CREATION_DATE in DATE,
          P_CREATED_BY in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure UPDATE_ROW (
          P_MAPPING_CODE in VARCHAR2,
          P_MAPPING_NAME in VARCHAR2,
          P_MAPPING_TYPE  in VARCHAR2,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure TRANSLATE_ROW (
          P_MAPPING_CODE in VARCHAR2,
          P_MAPPING_NAME in VARCHAR2,
          P_LAST_UPDATE_DATE in DATE,
          P_CUSTOM_MODE   in VARCHAR2,
          P_OWNER         in VARCHAR2
);

procedure LOAD_ROW (
          P_MAPPING_CODE in VARCHAR2,
          P_MAPPING_NAME in VARCHAR2,
          P_MAPPING_TYPE  in VARCHAR2,
          P_LAST_UPDATE_DATE in DATE,
          P_CUSTOM_MODE   in VARCHAR2,
          P_OWNER         in VARCHAR2
);

procedure ADD_LANGUAGE;

end XDO_FONT_MAPPING_SETS_PKG;

 

/
