--------------------------------------------------------
--  DDL for Package GMD_TEST_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_TEST_VALUES_PKG" AUTHID CURRENT_USER as
/* $Header: GMDGIAVS.pls 115.0 2002/03/12 12:55:58 pkm ship        $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_QCASSY_VAL_ID in NUMBER,
  X_QCASSY_TYP_ID in NUMBER,
  X_ORGN_CODE in VARCHAR2,
  X_ASSAY_CODE in VARCHAR2,
  X_ASSAY_VALUE in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_VALUE_NUM_MIN in NUMBER,
  X_VALUE_NUM_MAX in NUMBER,
  X_ASSAY_VALUE_RANGE_ORDER in NUMBER,
  X_VALUE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_QCASSY_VAL_ID in NUMBER,
  X_QCASSY_TYP_ID in NUMBER,
  X_ORGN_CODE in VARCHAR2,
  X_ASSAY_CODE in VARCHAR2,
  X_ASSAY_VALUE in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_VALUE_NUM_MIN in NUMBER,
  X_VALUE_NUM_MAX in NUMBER,
  X_ASSAY_VALUE_RANGE_ORDER in NUMBER,
  X_VALUE_DESC in VARCHAR2
);
procedure UPDATE_ROW (
  X_QCASSY_VAL_ID in NUMBER,
  X_QCASSY_TYP_ID in NUMBER,
  X_ORGN_CODE in VARCHAR2,
  X_ASSAY_CODE in VARCHAR2,
  X_ASSAY_VALUE in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_VALUE_NUM_MIN in NUMBER,
  X_VALUE_NUM_MAX in NUMBER,
  X_ASSAY_VALUE_RANGE_ORDER in NUMBER,
  X_VALUE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_QCASSY_VAL_ID in NUMBER
);
procedure ADD_LANGUAGE;
end GMD_TEST_VALUES_PKG;

 

/