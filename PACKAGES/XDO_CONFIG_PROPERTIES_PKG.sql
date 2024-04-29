--------------------------------------------------------
--  DDL for Package XDO_CONFIG_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_CONFIG_PROPERTIES_PKG" AUTHID CURRENT_USER as
/* $Header: XDOCFGPS.pls 120.3 2006/05/23 19:51:08 jyeung noship $ */

procedure INSERT_ROW (
          P_PROPERTY_CODE in VARCHAR2,
          P_PROPERTY_NAME in VARCHAR2,
          P_CATEGORY      in VARCHAR2,
          P_XDO_CFG_NAME  in VARCHAR2,
          P_LOOKUP_TYPE   in VARCHAR2,
          P_SORT_ORDER    in NUMBER,
          P_CREATION_DATE in DATE,
          P_CREATED_BY in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure UPDATE_ROW (
          P_PROPERTY_CODE in VARCHAR2,
          P_PROPERTY_NAME in VARCHAR2,
          P_CATEGORY      in VARCHAR2,
          P_XDO_CFG_NAME  in VARCHAR2,
          P_LOOKUP_TYPE   in VARCHAR2,
          P_SORT_ORDER     in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure TRANSLATE_ROW (
          P_PROPERTY_CODE in VARCHAR2,
          P_PROPERTY_NAME in VARCHAR2,
          P_LAST_UPDATE_DATE in VARCHAR2,
          P_CUSTOM_MODE   in VARCHAR2,
          P_OWNER         in VARCHAR2
);

procedure LOAD_ROW (
          P_PROPERTY_CODE in VARCHAR2,
          P_PROPERTY_NAME in VARCHAR2,
          P_CATEGORY      in VARCHAR2,
          P_XDO_CFG_NAME  in VARCHAR2,
          P_LOOKUP_TYPE   in VARCHAR2,
          P_SORT_ORDER     in NUMBER,
          P_LAST_UPDATE_DATE in VARCHAR2,
          P_CUSTOM_MODE   in VARCHAR2,
          P_OWNER         in VARCHAR2
);

procedure ADD_LANGUAGE;

end XDO_CONFIG_PROPERTIES_PKG;

 

/
