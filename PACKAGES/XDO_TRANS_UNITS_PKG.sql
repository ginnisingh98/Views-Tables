--------------------------------------------------------
--  DDL for Package XDO_TRANS_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_TRANS_UNITS_PKG" AUTHID CURRENT_USER as
/* $Header: XDOTRUTS.pls 120.1 2005/07/02 05:05:43 appldev noship $ */

procedure INSERT_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_LANGUAGE in VARCHAR2,
          X_TERRITORY in VARCHAR2,
          X_VALUE in VARCHAR2,
          X_NOTE in VARCHAR2,
          X_CREATION_DATE in DATE,
          X_CREATED_BY in NUMBER,
          X_LAST_UPDATE_DATE in DATE,
          X_LAST_UPDATED_BY in NUMBER,
          X_LAST_UPDATE_LOGIN in NUMBER
);

procedure UPDATE_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_LANGUAGE in VARCHAR2,
          X_TERRITORY in VARCHAR2,
          X_VALUE in VARCHAR2,
          X_NOTE in VARCHAR2,
          X_LAST_UPDATE_DATE in DATE,
          X_LAST_UPDATED_BY in NUMBER,
          X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2
);

procedure TRANSLATE_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_VALUE in VARCHAR2,
          X_CUSTOM_MODE in VARCHAR2,
          X_LAST_UPDATE_DATE in DATE,
          X_LAST_UPDATED_BY in VARCHAR2,
          X_LAST_UPDATE_LOGIN in VARCHAR2
);

procedure TRANSLATE_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_LANGUAGE in VARCHAR2,
          X_TERRITORY in VARCHAR2,
          X_VALUE in VARCHAR2,
          X_CUSTOM_MODE in VARCHAR2,
          X_LAST_UPDATE_DATE in DATE,
          X_LAST_UPDATED_BY in VARCHAR2,
          X_LAST_UPDATE_LOGIN in VARCHAR2
);

procedure LOAD_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_VALUE in VARCHAR2,
          X_NOTE in VARCHAR2,
          X_CUSTOM_MODE in VARCHAR2,
          X_LAST_UPDATE_DATE in DATE,
          X_OWNER in VARCHAR2
);

function LOAD_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_LANGUAGE in VARCHAR2,
          X_TERRITORY in VARCHAR2,
          X_VALUE in VARCHAR2,
          X_NOTE in VARCHAR2,
          X_CUSTOM_MODE in VARCHAR2,
          X_LAST_UPDATE_DATE in DATE,
          X_LAST_UPDATED_BY in VARCHAR2,
          X_LAST_UPDATE_LOGIN in VARCHAR2) return number;

procedure LOAD_TRANS_UNIT_PROP (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_PROP_TYPE in VARCHAR2,
          X_PROP_VALUE in VARCHAR2,
          X_CUSTOM_MODE in VARCHAR2,
          X_LAST_UPDATE_DATE in DATE,
          X_LAST_UPDATED_BY in VARCHAR2,
          X_LAST_UPDATE_LOGIN in VARCHAR2);

end XDO_TRANS_UNITS_PKG;

 

/
