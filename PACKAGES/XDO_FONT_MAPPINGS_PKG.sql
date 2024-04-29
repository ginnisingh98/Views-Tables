--------------------------------------------------------
--  DDL for Package XDO_FONT_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_FONT_MAPPINGS_PKG" AUTHID CURRENT_USER as
/* $Header: XDOFNTMS.pls 120.0 2005/09/01 20:26:18 bokim noship $ */

procedure INSERT_ROW (
          P_MAPPING_CODE in VARCHAR2,
          P_BASE_FONT in VARCHAR2,
          P_STYLE in VARCHAR2,
          P_WEIGHT in VARCHAR2,
          P_LANGUAGE in VARCHAR2,
          P_TERRITORY in VARCHAR2,
          P_TARGET_FONT_TYPE in VARCHAR2,
          P_TARGET_FONT in VARCHAR2,
          P_TTC_NUMBER in NUMBER,
          P_CREATION_DATE in DATE,
          P_CREATED_BY in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure UPDATE_ROW (
          P_MAPPING_CODE in VARCHAR2,
          P_BASE_FONT in VARCHAR2,
          P_STYLE in VARCHAR2,
          P_WEIGHT in VARCHAR2,
          P_LANGUAGE in VARCHAR2,
          P_TERRITORY in VARCHAR2,
          P_TARGET_FONT_TYPE in VARCHAR2,
          P_TARGET_FONT in VARCHAR2,
          P_TTC_NUMBER in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure LOAD_ROW (
          P_MAPPING_CODE in VARCHAR2,
          P_BASE_FONT in VARCHAR2,
          P_STYLE in VARCHAR2,
          P_WEIGHT in VARCHAR2,
          P_LANGUAGE in VARCHAR2,
          P_TERRITORY in VARCHAR2,
          P_TARGET_FONT_TYPE in VARCHAR2,
          P_TARGET_FONT in VARCHAR2,
          P_TTC_NUMBER in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

end XDO_FONT_MAPPINGS_PKG;

 

/
