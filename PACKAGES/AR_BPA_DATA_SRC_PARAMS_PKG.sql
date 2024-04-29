--------------------------------------------------------
--  DDL for Package AR_BPA_DATA_SRC_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BPA_DATA_SRC_PARAMS_PKG" AUTHID CURRENT_USER as
/* $Header: ARBPDSPS.pls 120.1 2004/12/03 01:45:07 orashid noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DATA_SOURCE_ID in NUMBER,
  X_PARAM_ID in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_SEQUENCE in NUMBER,
  X_PARAM_TYPE in VARCHAR2,
  X_PARAM_VALUE_SOURCE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ITEM_ID in NUMBER);

procedure UPDATE_ROW (
  X_DATA_SOURCE_ID in NUMBER,
  X_PARAM_ID in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_SEQUENCE in NUMBER,
  X_PARAM_TYPE in VARCHAR2,
  X_PARAM_VALUE_SOURCE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ITEM_ID in NUMBER
);
procedure DELETE_ROW (
  X_PARAM_ID in NUMBER
);

procedure LOAD_ROW (
        X_DATA_SOURCE_ID                 IN NUMBER,
        X_PARAM_ID                       IN NUMBER,
        X_PARAM_NAME                     IN VARCHAR2,
        X_PARAM_SEQUENCE                 IN NUMBER,
        X_PARAM_TYPE                     IN VARCHAR2,
        X_PARAM_VALUE_SOURCE             IN VARCHAR2,
        X_ITEM_ID 						 IN NUMBER,
        X_OWNER                 IN VARCHAR2 );
end AR_BPA_DATA_SRC_PARAMS_PKG;

 

/
