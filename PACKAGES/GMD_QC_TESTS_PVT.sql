--------------------------------------------------------
--  DDL for Package GMD_QC_TESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_TESTS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVTSTS.pls 115.4 2004/05/05 09:46:51 rboddu noship $ */

FUNCTION insert_row(p_qc_tests_rec IN OUT NOCOPY GMD_QC_TESTS%ROWTYPE) RETURN BOOLEAN;

PROCEDURE insert_row (
  X_ROWID in out NOCOPY ROWID,
  X_TEST_ID in out NOCOPY NUMBER,
  X_TEST_OPRN_LINE_ID in NUMBER,
  X_TEST_PROVIDER_CODE in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_TEST_CODE in VARCHAR2,
  X_TEST_METHOD_ID in NUMBER,
  X_TEST_CLASS in VARCHAR2,
  X_TEST_TYPE in VARCHAR2,
  X_TEST_UNIT in VARCHAR2,
  X_MIN_VALUE_NUM in NUMBER,
  X_MAX_VALUE_NUM in NUMBER,
  X_EXP_ERROR_TYPE in VARCHAR2,
  X_BELOW_SPEC_MIN in NUMBER,
  X_ABOVE_SPEC_MIN in NUMBER,
  X_BELOW_SPEC_MAX in NUMBER,
  X_ABOVE_SPEC_MAX in NUMBER,
  X_BELOW_MIN_ACTION_CODE in VARCHAR2,
  X_ABOVE_MIN_ACTION_CODE in VARCHAR2,
  X_BELOW_MAX_ACTION_CODE in VARCHAR2,
  X_ABOVE_MAX_ACTION_CODE in VARCHAR2,
  X_EXPRESSION in VARCHAR2,
  X_DISPLAY_PRECISION in NUMBER,
  X_REPORT_PRECISION in NUMBER,
  X_PRIORITY in VARCHAR2,
  X_TEST_OPRN_ID in NUMBER,
  X_TEST_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_TEST_GROUP_ORDER IN NUMBER DEFAULT NULL);

PROCEDURE lock_row (
  X_TEST_ID in NUMBER,
  X_TEST_OPRN_LINE_ID in NUMBER,
  X_TEST_PROVIDER_CODE in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_TEST_CODE in VARCHAR2,
  X_TEST_METHOD_ID in NUMBER,
  X_TEST_CLASS in VARCHAR2,
  X_TEST_TYPE in VARCHAR2,
  X_TEST_UNIT in VARCHAR2,
  X_MIN_VALUE_NUM in NUMBER,
  X_MAX_VALUE_NUM in NUMBER,
  X_EXP_ERROR_TYPE in VARCHAR2,
  X_BELOW_SPEC_MIN in NUMBER,
  X_ABOVE_SPEC_MIN in NUMBER,
  X_BELOW_SPEC_MAX in NUMBER,
  X_ABOVE_SPEC_MAX in NUMBER,
  X_BELOW_MIN_ACTION_CODE in VARCHAR2,
  X_ABOVE_MIN_ACTION_CODE in VARCHAR2,
  X_BELOW_MAX_ACTION_CODE in VARCHAR2,
  X_ABOVE_MAX_ACTION_CODE in VARCHAR2,
  X_EXPRESSION in VARCHAR2,
  X_DISPLAY_PRECISION in NUMBER,
  X_REPORT_PRECISION in NUMBER,
  X_PRIORITY in VARCHAR2,
  X_TEST_OPRN_ID in NUMBER,
  X_TEST_DESC in VARCHAR2,
  X_TEST_GROUP_ORDER IN NUMBER DEFAULT NULL
);

PROCEDURE update_row (
  X_TEST_ID in NUMBER,
  X_TEST_OPRN_LINE_ID in NUMBER,
  X_TEST_PROVIDER_CODE in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_TEST_CODE in VARCHAR2,
  X_TEST_METHOD_ID in NUMBER,
  X_TEST_CLASS in VARCHAR2,
  X_TEST_TYPE in VARCHAR2,
  X_TEST_UNIT in VARCHAR2,
  X_MIN_VALUE_NUM in NUMBER,
  X_MAX_VALUE_NUM in NUMBER,
  X_EXP_ERROR_TYPE in VARCHAR2,
  X_BELOW_SPEC_MIN in NUMBER,
  X_ABOVE_SPEC_MIN in NUMBER,
  X_BELOW_SPEC_MAX in NUMBER,
  X_ABOVE_SPEC_MAX in NUMBER,
  X_BELOW_MIN_ACTION_CODE in VARCHAR2,
  X_ABOVE_MIN_ACTION_CODE in VARCHAR2,
  X_BELOW_MAX_ACTION_CODE in VARCHAR2,
  X_ABOVE_MAX_ACTION_CODE in VARCHAR2,
  X_EXPRESSION in VARCHAR2,
  X_DISPLAY_PRECISION in NUMBER,
  X_REPORT_PRECISION in NUMBER,
  X_PRIORITY in VARCHAR2,
  X_TEST_OPRN_ID in NUMBER,
  X_TEST_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_TEST_GROUP_ORDER IN NUMBER DEFAULT NULL
);

PROCEDURE ADD_LANGUAGE;

FUNCTION fetch_row (
  p_gmd_qc_tests IN  gmd_qc_tests%ROWTYPE ,
  x_gmd_qc_tests OUT NOCOPY gmd_qc_tests%ROWTYPE
) RETURN BOOLEAN ;

FUNCTION lock_row (
  p_test_id   IN  NUMBER   DEFAULT NULL,
  p_test_code IN  VARCHAR2 DEFAULT NULL
) RETURN BOOLEAN ;

FUNCTION mark_for_delete (
  p_test_id   		IN  NUMBER   DEFAULT NULL,
  p_test_code 		IN  VARCHAR2 DEFAULT NULL,
  p_last_update_date 	IN  DATE     DEFAULT NULL,
  p_last_updated_by 	IN  NUMBER   DEFAULT NULL,
  p_last_update_login 	IN  NUMBER   DEFAULT NULL
) RETURN BOOLEAN ;

END gmd_qc_tests_pvt;

 

/
