--------------------------------------------------------
--  DDL for Package XDO_CONFIG_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_CONFIG_VALUES_PKG" AUTHID CURRENT_USER as
/* $Header: XDOCFGVS.pls 120.0 2005/09/01 20:26:17 bokim noship $ */

procedure INSERT_ROW (
          P_VALUE_ID in NUMBER,
          P_CONFIG_LEVEL in NUMBER,
          P_APPLICATION_SHORT_NAME in VARCHAR2,
          P_DATA_SOURCE_CODE in VARCHAR2,
          P_TEMPLATE_CODE in VARCHAR2,
          P_PROPERTY_CODE in VARCHAR2,
          P_VALUE in VARCHAR2,
          P_BVALUE in RAW,
          P_CREATION_DATE in DATE,
          P_CREATED_BY in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure UPDATE_ROW (
          P_CONFIG_LEVEL in NUMBER,
          P_APPLICATION_SHORT_NAME in VARCHAR2,
          P_DATA_SOURCE_CODE in VARCHAR2,
          P_TEMPLATE_CODE in VARCHAR2,
          P_PROPERTY_CODE in VARCHAR2,
          P_VALUE in VARCHAR2,
          P_BVALUE in RAW,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
          P_CONFIG_LEVEL in NUMBER,
          P_APPLICATION_SHORT_NAME in VARCHAR2,
          P_DATA_SOURCE_CODE in VARCHAR2,
          P_TEMPLATE_CODE in VARCHAR2,
          P_PROPERTY_CODE in VARCHAR2
);

procedure LOAD_ROW (
          P_CONFIG_LEVEL in NUMBER,
          P_APPLICATION_SHORT_NAME in VARCHAR2,
          P_DATA_SOURCE_CODE in VARCHAR2,
          P_TEMPLATE_CODE in VARCHAR2,
          P_PROPERTY_CODE in VARCHAR2,
          P_VALUE in VARCHAR2,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

function GET_VALUE_ID (
          P_CONFIG_LEVEL in NUMBER,
          P_APPLICATION_SHORT_NAME in VARCHAR2,
          P_DATA_SOURCE_CODE in VARCHAR2,
          P_TEMPLATE_CODE in VARCHAR2,
          P_PROPERTY_CODE in VARCHAR2
) return number;

end XDO_CONFIG_VALUES_PKG;

 

/
