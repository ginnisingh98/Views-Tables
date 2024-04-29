--------------------------------------------------------
--  DDL for Package AMS_METRICS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_METRICS_ALL_PKG" AUTHID CURRENT_USER as
/* $Header: amslmtcs.pls 120.1 2005/08/16 13:24:45 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_METRICS_ALL_PKG
-- Purpose
--
-- History
--   03/06/2003  dmvincen  BUG2819067: Do not update if customized.
--   08/20/2003  dmvincen  Add Display_type
--   08/16/2005  dmvincen  Added Target_type, and denorm_code
--
-- NOTE
--
-- End of Comments
-- ===============================================================
procedure INSERT_ROW  (
  X_ROWID in VARCHAR2,
  X_METRIC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_METRIC_USED_FOR_OBJECT in VARCHAR2,
  X_METRIC_CALCULATION_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_METRIC_CATEGORY in NUMBER,
  X_ACCRUAL_TYPE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_SENSITIVE_DATA_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_METRIC_SUB_CATEGORY in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
  X_FUNCTION_TYPE in VARCHAR2,
  X_METRIC_PARENT_ID in NUMBER,
  X_SUMMARY_METRIC_ID in NUMBER,
  X_COMPUTE_USING_FUNCTION in VARCHAR2,
  X_DEFAULT_UOM_CODE in VARCHAR2,
  X_UOM_TYPE in VARCHAR2,
  X_FORMULA in VARCHAR2,
  X_DISPLAY_TYPE in VARCHAR2,
  X_METRICS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FORMULA_DISPLAY in VARCHAR2,
  X_TARGET_TYPE in VARCHAR2,
  X_DENORM_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_METRIC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_METRIC_USED_FOR_OBJECT in VARCHAR2,
  X_METRIC_CALCULATION_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_METRIC_CATEGORY in NUMBER,
  X_ACCRUAL_TYPE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_SENSITIVE_DATA_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_METRIC_SUB_CATEGORY in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
  X_FUNCTION_TYPE in VARCHAR2,
  X_METRIC_PARENT_ID in NUMBER,
  X_SUMMARY_METRIC_ID in NUMBER,
  X_COMPUTE_USING_FUNCTION in VARCHAR2,
  X_DEFAULT_UOM_CODE in VARCHAR2,
  X_UOM_TYPE in VARCHAR2,
  X_FORMULA in VARCHAR2,
  X_DISPLAY_TYPE in VARCHAR2,
  X_METRICS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FORMULA_DISPLAY in VARCHAR2,
  X_TARGET_TYPE in VARCHAR2,
  X_DENORM_CODE in VARCHAR2
);
procedure UPDATE_ROW (
  X_METRIC_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_METRIC_USED_FOR_OBJECT in VARCHAR2,
  X_METRIC_CALCULATION_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_METRIC_CATEGORY in NUMBER,
  X_ACCRUAL_TYPE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_SENSITIVE_DATA_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_METRIC_SUB_CATEGORY in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
  X_FUNCTION_TYPE in VARCHAR2,
  X_METRIC_PARENT_ID in NUMBER,
  X_SUMMARY_METRIC_ID in NUMBER,
  X_COMPUTE_USING_FUNCTION in VARCHAR2,
  X_DEFAULT_UOM_CODE in VARCHAR2,
  X_UOM_TYPE in VARCHAR2,
  X_FORMULA in VARCHAR2,
  X_DISPLAY_TYPE in VARCHAR2,
  X_METRICS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FORMULA_DISPLAY in VARCHAR2,
  X_TARGET_TYPE in VARCHAR2,
  X_DENORM_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_METRIC_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  x_metric_id    in NUMBER,
  X_METRICS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_owner   in VARCHAR2
 ) ;

 procedure  LOAD_ROW(
  X_METRIC_ID in NUMBER,
  X_ARC_METRIC_USED_FOR_OBJECT in VARCHAR2,
  X_METRIC_CALCULATION_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_METRIC_CATEGORY in NUMBER,
  X_ACCRUAL_TYPE in VARCHAR2,
  X_VALUE_TYPE in VARCHAR2,
  X_SENSITIVE_DATA_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_METRIC_SUB_CATEGORY in NUMBER,
  X_FUNCTION_NAME in VARCHAR2,
  X_FUNCTION_TYPE in VARCHAR2,
  X_METRIC_PARENT_ID in NUMBER,
  X_SUMMARY_METRIC_ID in NUMBER,
  X_COMPUTE_USING_FUNCTION in VARCHAR2,
  X_DEFAULT_UOM_CODE in VARCHAR2,
  X_UOM_TYPE in VARCHAR2,
  X_FORMULA in VARCHAR2,
  X_DISPLAY_TYPE in VARCHAR2,
  X_METRICS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FORMULA_DISPLAY in VARCHAR2,
  X_TARGET_TYPE in VARCHAR2,
  X_DENORM_CODE in VARCHAR2,
  X_Owner   IN VARCHAR2,
  X_CUSTOM_MODE IN VARCHAR2
);



end AMS_METRICS_ALL_PKG;

 

/
