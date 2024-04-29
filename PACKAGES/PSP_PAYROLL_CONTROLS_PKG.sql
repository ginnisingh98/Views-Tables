--------------------------------------------------------
--  DDL for Package PSP_PAYROLL_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PAYROLL_CONTROLS_PKG" AUTHID CURRENT_USER AS
 /* $Header: PSPPIPCS.pls 120.3 2006/08/31 10:51:34 spchakra noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PAYROLL_CONTROL_ID in NUMBER,
  X_SUBLINES_DR_AMOUNT in NUMBER,
  X_SUBLINES_CR_AMOUNT in NUMBER,
  X_DIST_DR_AMOUNT in NUMBER,
  X_DIST_CR_AMOUNT in NUMBER,
  X_OGM_DR_AMOUNT in NUMBER,
  X_OGM_CR_AMOUNT in NUMBER,
  X_GL_DR_AMOUNT in NUMBER,
  X_GL_CR_AMOUNT in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_TOTAL_DR_AMOUNT in NUMBER,
  X_TOTAL_CR_AMOUNT in NUMBER,
  X_NUMBER_OF_CR in NUMBER,
  X_NUMBER_OF_DR in NUMBER,
  X_PAYROLL_SOURCE_CODE in VARCHAR2,
  X_SOURCE_TYPE in VARCHAR2,
  X_PAYROLL_ID in NUMBER,
  X_TIME_PERIOD_ID in NUMBER,
  X_BATCH_NAME in VARCHAR2,
  X_PAYROLL_ACTION_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R' ,
  X_GL_POSTING_OVERRIDE_DATE in DATE,
  X_GMS_POSTING_OVERRIDE_DATE in DATE,
  X_SET_OF_BOOKS_ID in  NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER ,
  X_GL_PHASE in VARCHAR2,
  X_GMS_PHASE in VARCHAR2,
  X_ADJ_SUM_BATCH_NAME in VARCHAR2,
  X_CURRENCY_CODE      in VARCHAR2,
  X_EXCHANGE_RATE_TYPE in VARCHAR2 ,
  X_PARENT_PAYROLL_CONTROL_ID in NUMBER DEFAULT NULL
  );
procedure LOCK_ROW (
  X_PAYROLL_CONTROL_ID in NUMBER,
  X_SUBLINES_DR_AMOUNT in NUMBER,
  X_SUBLINES_CR_AMOUNT in NUMBER,
  X_DIST_DR_AMOUNT in NUMBER,
  X_DIST_CR_AMOUNT in NUMBER,
  X_OGM_DR_AMOUNT in NUMBER,
  X_OGM_CR_AMOUNT in NUMBER,
  X_GL_DR_AMOUNT in NUMBER,
  X_GL_CR_AMOUNT in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_TOTAL_DR_AMOUNT in NUMBER,
  X_TOTAL_CR_AMOUNT in NUMBER,
  X_NUMBER_OF_CR in NUMBER,
  X_NUMBER_OF_DR in NUMBER,
  X_PAYROLL_SOURCE_CODE in VARCHAR2,
  X_SOURCE_TYPE in VARCHAR2,
  X_PAYROLL_ID in NUMBER,
  X_TIME_PERIOD_ID in NUMBER,
  X_BATCH_NAME in VARCHAR2,
  X_PAYROLL_ACTION_ID in NUMBER,
  X_GL_POSTING_OVERRIDE_DATE in DATE,
  X_GMS_POSTING_OVERRIDE_DATE in DATE,
  X_SET_OF_BOOKS_ID in  NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER ,
  X_GL_PHASE in VARCHAR2,
  X_GMS_PHASE in VARCHAR2,
  X_ADJ_SUM_BATCH_NAME in VARCHAR2,
  X_CURRENCY_CODE      in VARCHAR2,
  X_EXCHANGE_RATE_TYPE in VARCHAR2
);
procedure UPDATE_ROW (
  X_PAYROLL_CONTROL_ID in NUMBER,
  X_SUBLINES_DR_AMOUNT in NUMBER,
  X_SUBLINES_CR_AMOUNT in NUMBER,
  X_DIST_DR_AMOUNT in NUMBER,
  X_DIST_CR_AMOUNT in NUMBER,
  X_OGM_DR_AMOUNT in NUMBER,
  X_OGM_CR_AMOUNT in NUMBER,
  X_GL_DR_AMOUNT in NUMBER,
  X_GL_CR_AMOUNT in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_TOTAL_DR_AMOUNT in NUMBER,
  X_TOTAL_CR_AMOUNT in NUMBER,
  X_NUMBER_OF_CR in NUMBER,
  X_NUMBER_OF_DR in NUMBER,
  X_PAYROLL_SOURCE_CODE in VARCHAR2,
  X_SOURCE_TYPE in VARCHAR2,
  X_PAYROLL_ID in NUMBER,
  X_TIME_PERIOD_ID in NUMBER,
  X_BATCH_NAME in VARCHAR2,
  X_PAYROLL_ACTION_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_GL_POSTING_OVERRIDE_DATE in DATE,
  X_GMS_POSTING_OVERRIDE_DATE in DATE,
  X_SET_OF_BOOKS_ID in  NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER ,
  X_GL_PHASE in VARCHAR2,
  X_GMS_PHASE in VARCHAR2,
  X_ADJ_SUM_BATCH_NAME in VARCHAR2,
  X_CURRENCY_CODE      in VARCHAR2,
  X_EXCHANGE_RATE_TYPE in VARCHAR2
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PAYROLL_CONTROL_ID in NUMBER,
  X_SUBLINES_DR_AMOUNT in NUMBER,
  X_SUBLINES_CR_AMOUNT in NUMBER,
  X_DIST_DR_AMOUNT in NUMBER,
  X_DIST_CR_AMOUNT in NUMBER,
  X_OGM_DR_AMOUNT in NUMBER,
  X_OGM_CR_AMOUNT in NUMBER,
  X_GL_DR_AMOUNT in NUMBER,
  X_GL_CR_AMOUNT in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_TOTAL_DR_AMOUNT in NUMBER,
  X_TOTAL_CR_AMOUNT in NUMBER,
  X_NUMBER_OF_CR in NUMBER,
  X_NUMBER_OF_DR in NUMBER,
  X_PAYROLL_SOURCE_CODE in VARCHAR2,
  X_SOURCE_TYPE in VARCHAR2,
  X_PAYROLL_ID in NUMBER,
  X_TIME_PERIOD_ID in NUMBER,
  X_BATCH_NAME in VARCHAR2,
  X_PAYROLL_ACTION_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_GL_POSTING_OVERRIDE_DATE in DATE,
  X_GMS_POSTING_OVERRIDE_DATE in DATE,
  X_SET_OF_BOOKS_ID in  NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER ,
  X_GL_PHASE in VARCHAR2,
  X_GMS_PHASE in VARCHAR2,
  X_ADJ_SUM_BATCH_NAME in VARCHAR2,
  X_CURRENCY_CODE      in VARCHAR2,
  X_EXCHANGE_RATE_TYPE in VARCHAR2
  );
procedure DELETE_ROW (
  X_PAYROLL_CONTROL_ID in NUMBER
);
end PSP_PAYROLL_CONTROLS_PKG;

/